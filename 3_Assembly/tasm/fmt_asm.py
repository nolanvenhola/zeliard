#!/usr/bin/env python3
"""
fmt_asm.py - Format a Zeliard TASM .asm file in-place.

Changes made (all cosmetic — assembled output is identical):
  1. Removes Sourcer boilerplate: non-ASCII comment lines (box-drawing
     separator lines) and the '; SUBROUTINE' header blocks they wrap.
  2. Collapses 2+ consecutive blank lines to one blank line.
  3. Adds one blank line before every code label line
     (lines of the form: identifier: or identifier proc/endp/label).
  4. Indents loop bodies +1 tab stop (capped at 2 levels) for:
       - `loop target`
       - backward conditional jumps (jnz/jz/jc/jnc/je/jne/... where
         the target label was already seen = backward jump)
       - `jmp short target` where target was already seen

Usage:
  python fmt_asm.py working/drivers/gmcga.asm
  python fmt_asm.py working/core/game.asm
"""

import re
import sys
from pathlib import Path

LABEL_RE = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*)(\s+(proc|endp|label)\b|:)')
LOOP_RE  = re.compile(r'^\s+(loop|loope|loopne|loopz|loopnz)\s+(\S+)', re.IGNORECASE)
JMP_SHORT_RE = re.compile(r'^\s+jmp\s+short\s+(\S+)', re.IGNORECASE)
# Conditional short-jump mnemonics (all 1-byte-displacement forms)
COND_JMP_RE  = re.compile(
    r'^\s+(j[a-z]+)\s+(\S+)',
    re.IGNORECASE
)
COND_MNEMONICS = {
    'jz','jnz','je','jne','jc','jnc','jo','jno','js','jns',
    'ja','jae','jb','jbe','jg','jge','jl','jle',
    'jpe','jpo','jp','jnp',
}


def is_label_line(line: str) -> bool:
    """Return True if the line defines a label (not a comment, not blank)."""
    stripped = line.strip()
    if not stripped or stripped.startswith(';'):
        return False
    return bool(LABEL_RE.match(stripped))


def is_nonascii_comment(line: str) -> bool:
    """True for Sourcer separator/banner comment lines containing non-ASCII chars.

    Catches both:
    - Pure box-drawing lines: ';████████' (all chars after ; are non-ASCII)
    - Mixed banner lines:     ';╔══ External Entry into Subroutine ══╗'
      (starts with non-ASCII, or contains non-ASCII box chars alongside ASCII text)
    """
    s = line.strip()
    if not s.startswith(';'):
        return False
    content = s[1:]
    if not content:
        return False
    # Pure non-ASCII comment
    if all(ord(c) > 127 for c in content):
        return True
    # Mixed: first non-whitespace char after ';' is non-ASCII (Sourcer banner pattern)
    first_nonws = content.lstrip()
    if first_nonws and ord(first_nonws[0]) > 127:
        return True
    return False


def ascii_clean_comment(line: str) -> str:
    """Replace non-ASCII characters in inline comments with ASCII equivalents."""
    # Common substitutions seen in Sourcer/agent output
    subs = [
        ('\x86\x92', '->'),   # CP437 right arrow →
        ('\x80\x94', '--'),   # CP437 em dash —
        ('\xe2\x86\x92', '->'),  # UTF-8 →
        ('\xe2\x80\x94', '--'),  # UTF-8 —
    ]
    result = line
    for bad, good in subs:
        result = result.replace(bad, good)
    # Generic fallback: replace any remaining non-ASCII with '?'
    result = result.encode('ascii', errors='replace').decode('ascii')
    return result


def strip_boilerplate(lines: list[str]) -> list[str]:
    """Remove Sourcer subroutine header blocks:
       [non-ASCII comment] + [;...SUBROUTINE...] + [non-ASCII comment]
    Also removes any standalone non-ASCII comment lines.
    Also sanitises inline non-ASCII characters in regular lines."""
    SUBR_RE = re.compile(r';\s*SUBROUTINE\s*$', re.IGNORECASE)
    out = []
    i = 0
    while i < len(lines):
        # 3-line block: non-ASCII + SUBROUTINE + non-ASCII
        if (i + 2 < len(lines)
                and is_nonascii_comment(lines[i])
                and SUBR_RE.search(lines[i + 1])
                and is_nonascii_comment(lines[i + 2])):
            i += 3  # drop all three lines
            continue
        # Standalone non-ASCII comment line
        if is_nonascii_comment(lines[i]):
            i += 1
            continue
        # Sanitise any remaining non-ASCII in regular lines
        line = lines[i]
        if any(ord(c) > 127 for c in line):
            line = ascii_clean_comment(line)
        out.append(line)
        i += 1
    return out


def fmt(path: Path) -> None:
    text = path.read_text(encoding='latin-1')
    lines = text.splitlines()

    # Pass 0: remove Sourcer boilerplate headers
    lines = strip_boilerplate(lines)

    # Pass 1: collect all label names and their line indices (for backward detection)
    label_lines: set[int] = set()
    label_first_line: dict[str, int] = {}
    for i, line in enumerate(lines):
        m = LABEL_RE.match(line.strip())
        if m:
            name = m.group(1).lower()
            label_lines.add(i)
            if name not in label_first_line:
                label_first_line[name] = i

    # Pass 2: insert blank lines before labels
    out: list[str] = []
    for i, line in enumerate(lines):
        if is_label_line(line) and out and out[-1].strip():
            out.append('')
        out.append(line)
    lines = out

    # Pass 3: collapse runs of 2+ blank lines to 1
    out = []
    blank_run = 0
    for line in lines:
        if line.strip() == '':
            blank_run += 1
            if blank_run <= 1:
                out.append(line)
        else:
            blank_run = 0
            out.append(line)
    lines = out

    # Pass 4: indentation of loop bodies
    # Strategy: track indent level per line.
    # When we see a loop/jmp-short-backward/cond-jmp-backward that targets a
    # label we've already emitted, the NEXT line increases indent by 1 (max 2).
    # The indent resets when we hit the target label itself.
    #
    # We use a simple heuristic: for each loop-closing instruction, mark the
    # range from (target_label_line+1) to (loop_instruction_line) as +1 indent.
    # We handle this by scanning backwards.

    # Build label->line-index map in output (after pass 3)
    label_line_map: dict[str, int] = {}
    for i, line in enumerate(lines):
        m = LABEL_RE.match(line.strip())
        if m:
            label_line_map[m.group(1).lower()] = i

    # Find loop ranges: list of (start_line_idx, end_line_idx) to indent +1
    indent_ranges: list[tuple[int, int]] = []

    for i, line in enumerate(lines):
        target = None

        m = LOOP_RE.match(line)
        if m:
            target = m.group(2).rstrip(',;').lower()

        if target is None:
            m = JMP_SHORT_RE.match(line)
            if m:
                target = m.group(1).rstrip(',;').lower()

        if target is None:
            m = COND_JMP_RE.match(line)
            if m and m.group(1).lower() in COND_MNEMONICS:
                target = m.group(2).rstrip(',;').lower()

        if target and target in label_line_map:
            target_idx = label_line_map[target]
            if target_idx < i:  # backward jump = loop body
                indent_ranges.append((target_idx + 1, i))

    # Build per-line indent delta (0 or positive)
    indent_delta = [0] * len(lines)
    for (start, end) in indent_ranges:
        for j in range(start, end + 1):
            indent_delta[j] = min(indent_delta[j] + 1, 2)

    # Apply indent (only to non-blank, non-label lines that already have leading tab)
    TAB = '\t'
    out = []
    for i, line in enumerate(lines):
        delta = indent_delta[i]
        if delta > 0 and line.startswith(TAB) and line.strip() and not is_label_line(line):
            line = TAB * delta + line
        out.append(line)
    lines = out

    path.write_text('\n'.join(lines) + '\n', encoding='latin-1')
    print(f'Formatted {path}  ({len(lines)} lines)')


def main():
    if len(sys.argv) < 2:
        print('Usage: fmt_asm.py <working/path/to/file.asm>', file=sys.stderr)
        sys.exit(1)

    root = Path(__file__).parent
    for arg in sys.argv[1:]:
        p = Path(arg)
        if not p.is_absolute():
            p = root / p
        if not p.exists():
            print(f'Not found: {p}', file=sys.stderr)
            sys.exit(1)
        fmt(p)


if __name__ == '__main__':
    main()
