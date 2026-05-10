#!/usr/bin/env python3
"""strip_unreferenced_data_labels.py - delete `data_NN` labels that are
auto-generated artifacts with no real use.

Sourcer emits `data_NN db|dw <value>` labels at every byte/word it
couldn't immediately classify.  Most of these are never referenced from
code -- they're just position markers.  This script:

1. Scans each .asm file for all `data_NN` labels.
2. Counts references to each label (excluding the definition line).
3. For labels with zero external references, strips the label prefix
   from the line, leaving just the `db|dw <value>` directive.

The byte output is unchanged: TASM emits the same bytes whether or not
a label is on a line.  Verified by build_all.py --verify after running.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'

# Match `data_NN db|dw|dd <rest>` with optional whitespace, capturing
# the leading whitespace (if any) and the directive part.
LABEL_RE = re.compile(
    r'^(?P<lws>\s*)(?P<name>data_\d+)(?P<gap>\s+)(?P<rest>(?:db|dw|dd|equ)\b.*)$',
    re.IGNORECASE,
)


def process_file(path: Path, *, dry_run: bool = False) -> tuple[int, int]:
    """Return (kept, stripped) counts for this file."""
    text = path.read_text(encoding='utf-8', errors='replace')

    # Find all data_NN labels in the file.
    all_labels = set(re.findall(r'^(data_\d+)\b', text, re.MULTILINE))
    if not all_labels:
        return (0, 0)

    # Count refs per label (excluding the definition line).
    refs: dict[str, int] = {}
    for label in all_labels:
        pat = re.compile(rf'\b{re.escape(label)}\b')
        # Refs = total occurrences - 1 (def line)
        refs[label] = max(0, len(pat.findall(text)) - 1)

    # Strip definition lines for zero-reference labels.
    new_lines: list[str] = []
    stripped = 0
    kept = 0
    for line in text.splitlines():
        m = LABEL_RE.match(line)
        if m and refs.get(m.group('name'), 0) == 0:
            # Replace the label + gap with just whitespace (preserve
            # original column alignment as much as possible).
            new_line = m.group('lws') + m.group('rest')
            new_lines.append(new_line)
            stripped += 1
        else:
            if m:
                kept += 1
            new_lines.append(line)

    if not dry_run and stripped:
        path.write_text('\n'.join(new_lines) + '\n', encoding='utf-8')
    return (kept, stripped)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--filter', default=None,
                    help='only files whose path contains substring')
    ap.add_argument('--dry-run', action='store_true',
                    help='report what would be stripped, do not write')
    args = ap.parse_args()

    asm_files = sorted(WORKING.rglob('*.asm'))
    if args.filter:
        asm_files = [f for f in asm_files if args.filter in str(f)]

    grand_kept = grand_stripped = 0
    files_changed = 0
    for f in asm_files:
        kept, stripped = process_file(f, dry_run=args.dry_run)
        if stripped:
            files_changed += 1
            print(f'  {f.relative_to(ROOT).as_posix():<48s}  '
                  f'kept={kept:>3}  stripped={stripped}')
        grand_kept += kept
        grand_stripped += stripped

    mode = '(dry run)' if args.dry_run else ''
    print(f'\nFiles changed: {files_changed}')
    print(f'Total labels kept (still referenced): {grand_kept}')
    print(f'Total labels stripped (unreferenced): {grand_stripped}  {mode}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
