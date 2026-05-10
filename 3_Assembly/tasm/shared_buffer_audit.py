#!/usr/bin/env python3
"""Cross-chunk shared-buffer audit.

Finds DS addresses that have multiple distinct EQU names across the
working/ tree.  Those are prime suspects for "writer chunk uses one
name, consumer chunk uses another" mistakes — the same trap that hid
Sabre Oil's damage mechanism (0xEB60 = anim_spr_tbl in 201SELCT ==
sprite_work_buf in 200FIGHT).

Output: working/SHARED_BUFFER_AUDIT.md
"""
import re
from pathlib import Path
from collections import defaultdict

WORKING = Path(__file__).parent / 'working'

# Match: <name> equ <hex>h    or    <name> equ 0x<hex>
EQU_RE = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s+equ\s+0?([0-9A-Fa-f]+)h\b', re.MULTILINE)

# Track address → list of (chunk_relpath, symbol_name, line_no)
address_map = defaultdict(list)

def scan_file(asm_path: Path):
    relpath = asm_path.relative_to(WORKING).as_posix()
    text = asm_path.read_text(encoding='utf-8', errors='replace')
    for line_no, line in enumerate(text.splitlines(), 1):
        m = EQU_RE.match(line)
        if not m:
            continue
        name = m.group(1)
        addr = int(m.group(2), 16)
        # Skip addresses outside the data-area range we care about:
        # 0x80-0xFF (player record), 0xC000-0xFFFF (game seg shared)
        # Also include 0x100-0x10000 (general working area)
        if addr < 0x80:
            continue
        address_map[addr].append((relpath, name, line_no))


def main():
    # Walk all .asm and .inc files in working/
    for p in sorted(WORKING.rglob('*.asm')):
        scan_file(p)
    for p in sorted(WORKING.rglob('*.inc')):
        scan_file(p)

    # Filter to addresses with >= 2 DISTINCT symbol names
    multi = {}
    for addr, entries in address_map.items():
        distinct_names = set(e[1] for e in entries)
        # Skip if all sites use the same name (well-coordinated EQU)
        if len(distinct_names) < 2:
            continue
        multi[addr] = (entries, distinct_names)

    # Rank by distinct-name count (most-aliased first)
    ranked = sorted(multi.items(), key=lambda kv: (-len(kv[1][1]), kv[0]))

    out_lines = [
        '# Shared-buffer audit',
        '',
        'Addresses with **multiple distinct EQU names across chunks** —',
        'prime suspects for "write here / consume there" mistakes where',
        'the local symbol grep misses the cross-chunk consumer.',
        '',
        f'Total addresses with ≥2 distinct names: **{len(multi)}**',
        '',
        'Run via `python shared_buffer_audit.py` in `3_Assembly/tasm/`.',
        '',
        '---',
        '',
    ]

    for addr, (entries, distinct_names) in ranked:
        # Group entries by chunk → list of names
        by_chunk = defaultdict(list)
        for relpath, name, lineno in entries:
            by_chunk[relpath].append((name, lineno))

        # If this address has only one chunk source, skip (false positive
        # from same-chunk alias declarations)
        chunks_involved = set(e[0] for e in entries)
        if len(chunks_involved) < 2:
            continue

        out_lines.append(f'## 0x{addr:04X} — {len(distinct_names)} distinct names across {len(chunks_involved)} chunks')
        out_lines.append('')
        out_lines.append('Names: ' + ', '.join(f'`{n}`' for n in sorted(distinct_names)))
        out_lines.append('')
        out_lines.append('| Chunk | Symbol name(s) (line) |')
        out_lines.append('|---|---|')
        for relpath in sorted(by_chunk):
            cell = ', '.join(f'`{n}` (L{ln})' for n, ln in by_chunk[relpath])
            out_lines.append(f'| `{relpath}` | {cell} |')
        out_lines.append('')

    out_path = WORKING / 'SHARED_BUFFER_AUDIT.md'
    out_path.write_text('\n'.join(out_lines), encoding='utf-8')
    print(f'Wrote {out_path} ({len(ranked)} addresses, '
          f'{sum(1 for _, (es, _) in ranked if len(set(e[0] for e in es)) >= 2)} cross-chunk)')


if __name__ == '__main__':
    main()
