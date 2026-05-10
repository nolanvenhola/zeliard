#!/usr/bin/env python3
"""sync_inventory_names.py - update SECTION_INVENTORY.md proc-name entries
to match the current .asm file contents.

After a large rename pass, the inventory's name field becomes stale --
the inventory still says `vga_operation0` but the asm file now has
`rebuild_scroll_buf` at the same line.  This propagates to
SECTION_AUDIT.csv as PENDING rows because audit_section.py looks up
the inventory name and can't find a match.

Strategy:
  - Walk SECTION_INVENTORY.md.  Each row has the form:
        - [x|<space>] L<num>   `name`  *(kind)*
  - Group rows by their parent file (`## working/.../X.asm` headers).
  - For each row, parse line number and read the asm file at that line.
  - If the asm file has a `<name> proc <near|far>` declaration at that
    line whose name differs from the inventory's name, update the row.

Only proc-kind rows get updated -- data labels, dw entries etc. stay
as-is (their lines may have shifted but tracking that is out of scope).
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
INVENTORY = WORKING / 'SECTION_INVENTORY.md'

FILE_HEADER_RE = re.compile(r'^## (working/[^\s]+\.asm)\s+\(\d+ sections\)')
ENTRY_RE = re.compile(
    r'^(?P<prefix>- \[(?:x| )\] L)(?P<line>\d+)(?P<sep>\s+`)'
    r'(?P<name>[^`]+)(?P<suffix>`\s+\*\((?P<kind>[^)]+)\)\*\s*)$'
)
PROC_RE = re.compile(r'^(?P<name>\w+)\s+proc\s+(near|far)\b', re.IGNORECASE)
# Match either a labeled data/equ line, OR a bare label-only line.
# `data_42 db 1`  -> kind=data
# `foo equ 0x100` -> kind=data (same; equ counts as data)
# `foo:`           -> kind=label (we'll keep the existing inventory kind
# subtype since the asm doesn't tell us byte/word/dword from `foo:` alone).
DATA_RE = re.compile(
    r'^(?P<name>\w+)\s+(?P<kind>db|dw|dd|equ)\b', re.IGNORECASE,
)
LABEL_RE = re.compile(
    r'^(?P<name>\w+)(?::|\s+label\s+(?:byte|word|dword|near|far)\b)',
    re.IGNORECASE,
)


_FILE_CACHE: dict[Path, list[str]] = {}


def _read_lines(asm_path: Path) -> list[str] | None:
    if asm_path in _FILE_CACHE:
        return _FILE_CACHE[asm_path]
    if not asm_path.exists():
        return None
    try:
        text = asm_path.read_text(encoding='utf-8', errors='replace')
    except OSError:
        return None
    lines = text.splitlines()
    _FILE_CACHE[asm_path] = lines
    return lines


def _match_for_kind(kind: str):
    """Return the regex appropriate for an inventory kind."""
    if kind == 'proc':
        return PROC_RE
    if kind == 'data':
        return DATA_RE
    if kind.startswith('label'):
        return LABEL_RE
    return None


def load_name_at_line(asm_path: Path, line_num: int,
                      kind: str) -> str | None:
    """Read line N of asm_path; return the symbol name there, or None."""
    pat = _match_for_kind(kind)
    if pat is None:
        return None
    lines = _read_lines(asm_path)
    if lines is None or line_num < 1 or line_num > len(lines):
        return None
    m = pat.match(lines[line_num - 1])
    return m.group('name') if m else None


def find_by_old_name(asm_path: Path, old_name: str,
                     kind: str) -> tuple[str, int] | None:
    """If old_name still exists in the file as the given kind, return
    (old_name, current_line).  Used when the recorded line has drifted
    but the symbol is still named the same."""
    pat = _match_for_kind(kind)
    if pat is None:
        return None
    lines = _read_lines(asm_path)
    if lines is None:
        return None
    if kind == 'proc':
        anchor = re.compile(
            rf'^{re.escape(old_name)}\s+proc\s+(near|far)\b', re.IGNORECASE)
    elif kind == 'data':
        anchor = re.compile(
            rf'^{re.escape(old_name)}\s+(db|dw|dd|equ)\b', re.IGNORECASE)
    elif kind.startswith('label'):
        anchor = re.compile(
            rf'^{re.escape(old_name)}(?::|\s+label\s+'
            rf'(?:byte|word|dword|near|far)\b)',
            re.IGNORECASE,
        )
    else:
        return None
    for ln, line in enumerate(lines, start=1):
        if anchor.match(line):
            return (old_name, ln)
    return None


def find_near_line(asm_path: Path, line_num: int, kind: str,
                   radius: int = 50) -> tuple[str, int] | None:
    """Search for any symbol of the given kind within ±radius lines.
    Returns the closest match or None."""
    pat = _match_for_kind(kind)
    if pat is None:
        return None
    lines = _read_lines(asm_path)
    if lines is None:
        return None
    best: tuple[int, str, int] | None = None
    lo = max(1, line_num - radius)
    hi = min(len(lines), line_num + radius)
    for ln in range(lo, hi + 1):
        m = pat.match(lines[ln - 1])
        if m:
            dist = abs(ln - line_num)
            if best is None or dist < best[0]:
                best = (dist, m.group('name'), ln)
    if best is None:
        return None
    return (best[1], best[2])


def main() -> int:
    text = INVENTORY.read_text(encoding='utf-8')
    out_lines: list[str] = []
    current_asm: Path | None = None
    updated = 0
    skipped = 0
    not_found = 0
    deleted = 0
    # Stale-stripped pattern: was an auto-generated `data_NN` label that
    # got removed by strip_unreferenced_data_labels.py.  These no longer
    # exist anywhere in the asm.
    stale_stripped_re = re.compile(r'^data_\d+$')

    for line in text.splitlines():
        # File header?
        h = FILE_HEADER_RE.match(line)
        if h:
            current_asm = ROOT / h.group(1)
            out_lines.append(line)
            continue

        # Entry row?
        m = ENTRY_RE.match(line)
        if not m or current_asm is None:
            out_lines.append(line)
            continue

        kind = m.group('kind').strip()
        # Kinds we know how to track: proc, data, label byte/word/dword.
        if kind not in ('proc', 'data') and not kind.startswith('label'):
            out_lines.append(line)
            continue

        # Normalise label* -> 'label' for the lookup helpers.
        lookup_kind = 'label' if kind.startswith('label') else kind

        line_num = int(m.group('line'))
        old_name = m.group('name')

        # 1. Direct lookup at recorded line.
        cur_name = load_name_at_line(current_asm, line_num, lookup_kind)
        new_line_num = line_num

        # 2. If no symbol at that line, search for the old name (line drift).
        if cur_name is None:
            hit = find_by_old_name(current_asm, old_name, lookup_kind)
            if hit is not None:
                cur_name, new_line_num = hit

        # 3. Still nothing -- search nearby lines for any symbol of the
        # same kind.  Wide radius because rename-batches can shift many lines.
        if cur_name is None:
            hit = find_near_line(current_asm, line_num, lookup_kind,
                                  radius=50)
            if hit is not None:
                cur_name, new_line_num = hit

        if cur_name is None:
            # Symbol gone entirely.  If it was a `data_NN` placeholder,
            # it was stripped by strip_unreferenced_data_labels.py;
            # remove the inventory row.
            if stale_stripped_re.match(old_name):
                deleted += 1
                continue  # skip the row -- don't append
            not_found += 1
            if not_found <= 10:
                rel = current_asm.relative_to(ROOT).as_posix()
                print(f'  not found: {rel}:{line_num} ({lookup_kind}) '
                      f'`{old_name}`')
            out_lines.append(line)
            continue

        if cur_name == old_name and new_line_num == line_num:
            skipped += 1
            out_lines.append(line)
            continue

        # Rebuild row with possibly-updated line and name.
        new_line = (
            m.group('prefix')
            + str(new_line_num)
            + m.group('sep')
            + cur_name
            + m.group('suffix').rstrip()
        )
        out_lines.append(new_line)
        updated += 1

    INVENTORY.write_text('\n'.join(out_lines) + '\n', encoding='utf-8')
    print(f'Updated:   {updated}  rows renamed/relocated to current asm')
    print(f'Skipped:   {skipped}  rows already matched current asm')
    print(f'Deleted:   {deleted}  stale `data_NN` rows '
          f'(stripped by strip_unreferenced_data_labels.py)')
    print(f'Not found: {not_found}  rows whose symbol could not be located')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
