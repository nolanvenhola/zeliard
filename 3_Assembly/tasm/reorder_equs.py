#!/usr/bin/env python3
"""
Reorder EQU declarations within a TASM .asm file into 7 stable sections.

Layout assumptions:
- File starts with `target equ 'T2'` then `include` directives.
- A run of EQU declarations follows (sometimes with blank lines / comments
  / extra includes / MACRO blocks interleaved).
- Then `seg_a segment` begins the code body.

Strategy:
- Identify the "header block" between (target line + 1) and (seg_a line).
- Within it, classify each non-blank, non-comment line:
    * include -> clustered at top (after target)
    * MACRO ... ENDM -> kept verbatim, placed at bottom (just before seg_a)
    * EQU -> categorized into one of 6 sections (2..7) and topo-sorted
- Comments immediately above an EQU (no blank line in between) are kept
  attached to that EQU and travel with it.
- Comments above a MACRO travel with the MACRO.
- Other comments (free-floating) are dropped from the EQU rewrite zone.
- Bit-perfect: all output is identical sequence of EQUs/macros, only reordered.

Sections (top to bottom):
  1. Includes (target + include)
  2. Module-local exports (rare — usually empty)
  3. Game-segment globals (gvar_*) NOT in shared inc
  4. Shared dispatch slot references (file-local overrides)
  5. File-internal data table addresses (label-based EQUs, table refs)
  6. File-internal state variables (per-module byte/word state)
  7. Constants (numeric literals, control codes)

Usage:
    python reorder_equs.py [--apply] <path/to/file.asm> ...
    python reorder_equs.py [--apply] --auto      # process all 21 default files

Without --apply: dry-run, prints planned section counts only.
With --apply: rewrites files in place.
"""
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent
WORKING = ROOT / 'working'

EQU_RE = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*)\s+equ\s+(.+?)\s*$', re.IGNORECASE)
TARGET_RE = re.compile(r'^target\s+EQU\s+', re.IGNORECASE)
INCLUDE_RE = re.compile(r'^\s*include\s+', re.IGNORECASE)
SEG_RE = re.compile(r'^seg_a\s+segment\b', re.IGNORECASE)
MACRO_START_RE = re.compile(r'^\s*([A-Za-z_]\w*)\s+MACRO\b', re.IGNORECASE)
MACRO_END_RE = re.compile(r'^\s*ENDM\b', re.IGNORECASE)


def hex_value(expr):
    """Return integer value of a simple numeric EQU expression, or None."""
    expr = expr.split(';', 1)[0].strip()
    m = re.match(r'^0?([0-9A-Fa-f]+)h\s*$', expr)
    if m:
        try:
            return int(m.group(1), 16)
        except ValueError:
            return None
    m = re.match(r'^(\d+)\s*$', expr)
    if m:
        return int(m.group(1))
    m = re.match(r'^0[xX]([0-9A-Fa-f]+)\s*$', expr)
    if m:
        return int(m.group(1), 16)
    return None


def categorize(name, expr):
    """Return section number 2..7 for an EQU."""
    name_lc = name.lower()
    val = hex_value(expr)

    # Section 3: gvar_* (game-segment globals not already in shared inc)
    if name_lc.startswith('gvar_'):
        return 3

    # Section 4: dispatch slot overrides
    # - prefix drv_, script_step/format/display/take/give
    # - or numeric value in 0x6000-0x603F range with cb_/dispatch/_fn naming
    if name_lc.startswith('drv_'):
        return 4
    if name_lc.startswith(('script_step', 'script_format', 'script_display',
                           'script_take', 'script_give')):
        return 4
    if val is not None and 0x6000 <= val <= 0x603F:
        if any(s in name_lc for s in ('_fn', 'cb_', 'dispatch', 'callback', 'slot')):
            return 4

    # Section 7: constants — small numeric, ALL_CAPS, common prefixes
    if val is not None and val <= 0xFF and not name_lc.startswith('gvar_'):
        return 7
    if re.match(r'^[A-Z][A-Z0-9_]+$', name) and name not in (
            'GAME_CODE_BASE', 'ISR_STUBS_BASE'):
        return 7
    # ALL-CAPS prefix-style constants (SCR_*, ANIM_*, KEY_*, CMD_*, OPC_*, etc.)
    if re.match(r'^[A-Z][A-Z0-9_]*$', name):
        if any(name.startswith(p) for p in ('SCR_', 'ANIM_', 'KEY_', 'KP_',
                                              'FLAG_CONST_', 'CMD_', 'OPC_',
                                              'MISDEC_')):
            return 7
    if name_lc.startswith('misdec_'):
        return 7

    # Section 3: addresses in 0xFFxx range without gvar_ prefix
    # (still game-segment globals, just not named gvar_)
    if val is not None and 0xFF00 <= val <= 0xFFFF:
        return 3

    # Function-pointer suffix => not state, treat as table/data address
    if name_lc.endswith('_fn') or name_lc.endswith('_fn_ptr') \
            or name_lc.endswith('_callback') or name_lc.endswith('_handler'):
        return 5

    # State markers (state, flag, idx, cnt, phase, timer, mode)
    state_markers = ('_flag', '_byte', '_word', '_state', '_cnt', '_counter',
                     '_var', '_idx', '_index', '_phase', '_timer', '_mode',
                     '_step', '_pos', '_dir', '_bits', '_frame')
    table_markers = ('_tbl', '_table', '_buf', '_dst', '_src', '_ptr',
                     '_base', '_data', '_dest', '_map', '_lookup',
                     '_ref', '_seq', '_xlat', '_lut', '_seg', '_ofs',
                     '_filename', '_msg', '_record', '_list')
    has_table = any(m in name_lc for m in table_markers)
    has_state = any(m in name_lc for m in state_markers)
    if has_state and not has_table:
        return 6
    if has_table:
        return 5

    # Section 2: module-local exports — most files have none.
    # Heuristic: numeric values in 0x1000-0x9FFF range without other markers
    # we leave in section 5 by default.

    # Default: section 5 (file-internal data table addresses)
    return 5


def topo_sort(equs):
    """
    Stable topological sort: each EQU placed after all EQUs (in this set)
    that it references in its expression.

    equs: list of (name, expr, raw_line, leading_comments) tuples.
    Returns reordered list.
    """
    if not equs:
        return []
    name_set_lc = {e[0].lower() for e in equs}
    deps = {}
    for name, expr, _line, _cmts in equs:
        # Strip trailing ;-comment from expression before scanning
        expr_clean = expr.split(';', 1)[0]
        refs = set()
        for tok in re.findall(r'[A-Za-z_][A-Za-z0-9_]*', expr_clean):
            tl = tok.lower()
            if tl != name.lower() and tl in name_set_lc:
                refs.add(tl)
        deps[name.lower()] = refs

    by_name = {e[0].lower(): e for e in equs}
    order = [e[0].lower() for e in equs]
    result = []
    placed = set()
    iterations = 0
    while len(result) < len(equs) and iterations < len(equs) + 5:
        progressed = False
        for nm in order:
            if nm in placed:
                continue
            if all(d in placed for d in deps[nm]):
                result.append(by_name[nm])
                placed.add(nm)
                progressed = True
        if not progressed:
            for nm in order:
                if nm not in placed:
                    result.append(by_name[nm])
                    placed.add(nm)
            break
        iterations += 1
    return result


def parse_header(lines):
    """Find target_idx and seg_idx (line indices)."""
    target_idx = None
    seg_idx = None
    for i, ln in enumerate(lines):
        if target_idx is None and TARGET_RE.match(ln.lstrip()):
            target_idx = i
        if SEG_RE.match(ln.lstrip()):
            seg_idx = i
            break
    return target_idx, seg_idx


def extract_blocks(lines, start, end):
    """
    Walk lines[start:end], emit a list of typed blocks:
      ('include', line)
      ('equ', name, expr, line, comments)   -- comments = list of comment lines
      ('macro', [lines])                    -- full block including comments before
      ('comment_only', [lines])             -- standalone comment block (dropped on rewrite)

    Comments and blank lines are aggregated and attached to the next equ/macro.
    """
    blocks = []
    pending_comments = []
    pending_blanks = 0
    i = start
    while i < end:
        line = lines[i]
        stripped = line.strip()

        # Macro block
        if MACRO_START_RE.match(line):
            # Macro takes pending_comments
            macro_lines = list(pending_comments) + [line]
            pending_comments = []
            pending_blanks = 0
            i += 1
            while i < end:
                macro_lines.append(lines[i])
                if MACRO_END_RE.match(lines[i]):
                    i += 1
                    break
                i += 1
            blocks.append(('macro', macro_lines))
            continue

        # blank line
        if stripped == '':
            # blank line resets pending comments (they become free-floating)
            if pending_comments:
                blocks.append(('comment_only', pending_comments))
                pending_comments = []
            pending_blanks += 1
            i += 1
            continue

        # Comment line
        if stripped.startswith(';'):
            pending_comments.append(line)
            i += 1
            continue

        # Include
        if INCLUDE_RE.match(line):
            # Includes don't keep leading comments attached (they go top-cluster)
            if pending_comments:
                blocks.append(('comment_only', pending_comments))
                pending_comments = []
            pending_blanks = 0
            blocks.append(('include', line))
            i += 1
            continue

        # EQU
        m = EQU_RE.match(stripped)
        if m:
            name = m.group(1)
            expr = m.group(2)
            blocks.append(('equ', name, expr, line, list(pending_comments)))
            pending_comments = []
            pending_blanks = 0
            i += 1
            continue

        # Other content (e.g., a directive like PAGE) — preserve verbatim
        # in place but with leading comments
        if pending_comments:
            blocks.append(('comment_only', pending_comments))
            pending_comments = []
        blocks.append(('other', line))
        pending_blanks = 0
        i += 1

    if pending_comments:
        blocks.append(('comment_only', pending_comments))
    return blocks


def build_new_header(target_line, blocks):
    """
    Construct new header text from parsed blocks.

    Output order:
      target_line
      <blank>
      includes (in original order)
      <blank>
      Section 2 banner + items   (only if non-empty)
      <blank>
      Section 3 banner + items
      ...
      Section 7
      <blank>
      Macros (in original order, with their leading comments)
      <blank>
      [other lines preserved at end]
    """
    includes = []
    macros = []
    others = []
    sections = {2: [], 3: [], 4: [], 5: [], 6: [], 7: []}

    # First pass: assign each EQU to its initial section
    initial_sec = {}
    all_equs = []
    for b in blocks:
        kind = b[0]
        if kind == 'include':
            includes.append(b[1])
        elif kind == 'macro':
            macros.append(b[1])
        elif kind == 'equ':
            _, name, expr, line, cmts = b
            sec = categorize(name, expr)
            initial_sec[name.lower()] = sec
            all_equs.append((name, expr, line, cmts))
        elif kind == 'other':
            others.append(b[1])
        # 'comment_only' is dropped (free-floating chatter)

    # Cross-section dependency fix-up:
    # If A depends on B (A's expr references B), then A must appear
    # in the same OR later section than B. If A's section < B's section,
    # promote A to B's section. Iterate until fixed point.
    name_set_lc = {e[0].lower() for e in all_equs}
    deps_global = {}
    for name, expr, _line, _cmts in all_equs:
        expr_clean = expr.split(';', 1)[0]
        refs = set()
        for tok in re.findall(r'[A-Za-z_][A-Za-z0-9_]*', expr_clean):
            tl = tok.lower()
            if tl != name.lower() and tl in name_set_lc:
                refs.add(tl)
        deps_global[name.lower()] = refs

    changed = True
    max_iter = len(all_equs) + 10
    safety = 0
    while changed and safety < max_iter:
        changed = False
        safety += 1
        for name, expr, _line, _cmts in all_equs:
            nlc = name.lower()
            for d in deps_global[nlc]:
                if initial_sec[d] > initial_sec[nlc]:
                    # dep is in a later section; promote this equ to dep's section
                    initial_sec[nlc] = initial_sec[d]
                    changed = True

    # Bucket equs into final sections
    for e in all_equs:
        sections[initial_sec[e[0].lower()]].append(e)

    # topo-sort each section
    for s in sections:
        sections[s] = topo_sort(sections[s])

    out = []
    # Target
    out.append(target_line)
    if not target_line.endswith('\n'):
        out.append('\n')
    # blank
    out.append('\n')
    # Includes
    for inc in includes:
        out.append(inc if inc.endswith('\n') else inc + '\n')

    # Sections
    bar = "; " + "-" * 70 + "\n"
    titles = {
        2: "Section 2: Module-local exports",
        3: "Section 3: Game-segment globals (gvar_*) not in shared inc",
        4: "Section 4: Shared dispatch slot references (file-local)",
        5: "Section 5: File-internal data table addresses",
        6: "Section 6: File-internal state variables",
        7: "Section 7: Constants",
    }
    for s in [2, 3, 4, 5, 6, 7]:
        items = sections[s]
        if not items:
            continue
        out.append('\n')
        out.append(bar)
        out.append(f"; {titles[s]}\n")
        out.append(bar)
        for name, expr, line, cmts in items:
            for c in cmts:
                out.append(c if c.endswith('\n') else c + '\n')
            out.append(line if line.endswith('\n') else line + '\n')

    # Macros
    if macros:
        out.append('\n')
        for ml in macros:
            for line in ml:
                out.append(line if line.endswith('\n') else line + '\n')

    # Others
    if others:
        out.append('\n')
        for o in others:
            out.append(o if o.endswith('\n') else o + '\n')

    out.append('\n')
    return out


def reorder_file(path, dry_run=False):
    p = Path(path)
    raw = p.read_bytes()
    # Detect line ending (preserve)
    text = raw.decode('latin-1')
    if '\r\n' in text:
        # Normalize for processing, restore at end
        nl_kind = '\r\n'
        text_n = text.replace('\r\n', '\n')
    else:
        nl_kind = '\n'
        text_n = text

    lines = text_n.splitlines(keepends=True)
    target_idx, seg_idx = parse_header(lines)
    if target_idx is None or seg_idx is None:
        return ('skip', 'no target/seg_a found', {})

    # Header rewrite zone: lines[target_idx + 1 : seg_idx]
    # We replace this entire zone (and re-emit target line first)
    target_line = lines[target_idx]
    blocks = extract_blocks(lines, target_idx + 1, seg_idx)

    # Count EQUs
    equ_count = sum(1 for b in blocks if b[0] == 'equ')
    inc_count = sum(1 for b in blocks if b[0] == 'include')
    macro_count = sum(1 for b in blocks if b[0] == 'macro')

    if equ_count == 0:
        return ('skip', f'no EQUs ({inc_count} includes, {macro_count} macros)', {})

    new_header = build_new_header(target_line, blocks)

    # Compute section counts for reporting
    counts = {}
    for b in blocks:
        if b[0] == 'equ':
            sec = categorize(b[1], b[2])
            counts[sec] = counts.get(sec, 0) + 1

    if dry_run:
        return ('dry', f'{equ_count} EQUs, {inc_count} includes, {macro_count} macros', counts)

    # Build full new file content
    new_lines = lines[:target_idx] + new_header + lines[seg_idx:]
    new_text = ''.join(new_lines)
    # Restore CRLF if needed
    if nl_kind == '\r\n':
        new_text = new_text.replace('\r\n', '\n').replace('\n', '\r\n')

    p.write_bytes(new_text.encode('latin-1'))
    return ('written', f'{equ_count} EQUs reordered', counts)


DEFAULT_FILES = [
    'core/game.asm',
    'core/zeliad.asm',
    'drivers/gmcga.asm',
    'drivers/gmega.asm',
    'drivers/gmhgc.asm',
    'drivers/gmmcga.asm',
    'drivers/gmtga.asm',
    'drivers/stdply.asm',
    'drivers/stick.asm',
    'zelres1/code/100OPDMO.asm',
    'zelres1/code/101GDEGA.asm',
    'zelres1/code/102GDCGA.asm',
    'zelres1/code/103GDHGC.asm',
    'zelres1/code/104GDTGA.asm',
    'zelres1/code/105GDMCA.asm',
    'zelres1/code/106TOWN.asm',
    'zelres1/code/107GTEGA.asm',
    'zelres1/code/108GTCGA.asm',
    'zelres1/code/109GTHGC.asm',
    'zelres1/code/110GTTGA.asm',
    'zelres1/code/111GTMCA.asm',
]


def main():
    args = sys.argv[1:]
    dry = True
    files = []
    for a in args:
        if a == '--apply':
            dry = False
        elif a == '--dry-run':
            dry = True
        elif a == '--auto':
            files.extend(DEFAULT_FILES)
        else:
            files.append(a)
    if not files:
        files = DEFAULT_FILES

    for rel in files:
        p = WORKING / rel if not Path(rel).is_absolute() else Path(rel)
        status, msg, counts = reorder_file(p, dry_run=dry)
        sec_str = ' '.join(f's{s}={c}' for s, c in sorted(counts.items())) if counts else ''
        print(f"  [{status}] {rel}: {msg} {sec_str}")


if __name__ == '__main__':
    main()
