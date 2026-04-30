#!/usr/bin/env python3
"""phase3_queue.py — produce the prioritized work-list for Phase 3 of
PLAN.md (the game_func_N identity sweep).

Reads:
  functest/coverage.csv           (from classify.py)
  working/IDA_NAME_DELTA.md       (cross-name comparison report)
Writes:
  functest/PHASE3_PRIORITY.md     (sorted work-list, bucketed by chunk)

Algorithm (per PLAN §4.1):
  1. Filter coverage.csv to category == 'B' (placeholder identity).
  2. Sort by n_calls_in DESC (callees with the most callers carry the
     most leverage; resolving them clarifies more sites at once).
  3. For each row, look up the entry_addr in IDA_NAME_DELTA.md's
     "Only in IDA" section to seed a hypothesis name.
  4. Bucket by chunk so a contributor working through one chunk
     amortises harness setup cost.
"""
import csv
import re
from collections import defaultdict
from pathlib import Path

ROOT       = Path(__file__).resolve().parents[1]
COVERAGE   = Path(__file__).parent / 'coverage.csv'
IDA_DELTA  = ROOT / 'working' / 'IDA_NAME_DELTA.md'
OUT        = Path(__file__).parent / 'PHASE3_PRIORITY.md'

# entry_addr in coverage.csv is the LST-offset (= file offset).  IDA
# addresses are CPU-form (load_base + file offset).  Add the chunk's
# load_base to convert before looking up.  Mirror of fixtures.BIN_PATHS.
CHUNK_LOAD_BASE = {
    '200FIGHT':  0x6000,
    '201SELCT':  0xA000,
    '106TOWN':   0x6000,    # NOTE: 106TOWN has no LST yet so won't appear
    '100OPDMO':  0x0000,
    '202GFEGA':  0x3000, '203GFCGA': 0x3000, '204GFHGC': 0x3000,
    '205GFTGA':  0x3000, '206GFMCA': 0x3000,
    '207MOLE':   0x0100,
    '210KINGP':  0xA000, '211OMOYP': 0xA000, '212ARMRP': 0xA000,
    '213BANKP':  0xA000, '214CHURP': 0xA000, '215DRUGP': 0xA000,
    '216INNAP':  0xA000, '217INNBP': 0xA000, '218BARP':  0xA000,
    '219INNCP':  0xA000,
    # Enemy chunks load at 0xA000 (per fixtures.BIN_PATHS for crab/eai1)
    '300ROKAD':  0xA000, '301EAI1': 0xA000, '302EAI2': 0xA000,
    '303EAI3':   0xA000, '304EAI4': 0xA000, '305EAI5': 0xA000,
    '306EAI6':   0xA000, '307EAI7': 0xA000, '308EAI8': 0xA000,
    '309CRAB':   0xA000, '310MEDA': 0xA000, '311TORI': 0xA000,
    '312ZELA':   0xA000, '313GALR': 0xA000, '314LEGA': 0xA000,
    '315ZEL2':   0xA000, '316DRGN': 0xA000, '317AKMA': 0xA000,
    '318MAO1':   0xA000, '319MAO2': 0xA000,
}


def parse_ida_only_names() -> dict[int, list[str]]:
    """Return {addr_int: [ida_names]} for symbols only IDA names."""
    out: dict[int, list[str]] = defaultdict(list)
    if not IDA_DELTA.exists():
        return out
    text = IDA_DELTA.read_text(encoding='utf-8')
    # Section 1: "Name agreements / disagreements" — table rows like
    #   | `0x83` | `ply_accel` | `hero_x_in_viewport` | **rename?** |
    for m in re.finditer(
        r'^\|\s*`0x([0-9A-Fa-f]+)`\s*\|\s*([^|]*)\|\s*([^|]*)\|',
        text, re.MULTILINE,
    ):
        addr = int(m.group(1), 16)
        ida_cell = m.group(3).strip().strip('`')
        for name in re.split(r'`?,\s*`?|`\s+`', ida_cell):
            name = name.strip().strip('`')
            if name and not name.startswith('**'):
                out[addr].append(name)
    # Section 3: "Symbols only in IDA" — bullet list:
    #   - `0x18`: `Agar_Defeated`
    sec3_marker = '## Symbols only in IDA'
    if sec3_marker in text:
        sec3 = text.split(sec3_marker, 1)[1]
        for m in re.finditer(
            r'^-\s*`0x([0-9A-Fa-f]+)`:\s*`([^`]+)`',
            sec3, re.MULTILINE,
        ):
            addr = int(m.group(1), 16)
            out[addr].append(m.group(2).strip())
    return out


def main() -> int:
    if not COVERAGE.exists():
        print(f'MISSING: {COVERAGE} — run classify.py first')
        return 1

    ida_names = parse_ida_only_names()
    print(f'Parsed {sum(len(v) for v in ida_names.values())} IDA name '
          f'hints across {len(ida_names)} addresses.')

    rows: list[dict] = []
    skipped_sub: list[dict] = []
    with COVERAGE.open(encoding='utf-8') as fp:
        for r in csv.DictReader(fp):
            if r['category'] != 'B':
                continue
            # Per PLAN §6: Sourcer-generated `sub_NN` are out of scope —
            # they get cleaned by /asm-cleanup, not runtime probing.
            if re.match(r'^sub_\d+$', r['name']):
                skipped_sub.append(r)
                continue
            r['n_calls_in']  = int(r['n_calls_in']  or 0)
            r['n_calls_out'] = int(r['n_calls_out'] or 0)
            r['size_bytes']  = int(r['size_bytes']  or 0)
            r['far_calls']   = int(r['far_calls']   or 0)
            try:
                file_off = int(r['entry_addr'], 16) if r['entry_addr'] else None
            except ValueError:
                file_off = None
            base = CHUNK_LOAD_BASE.get(r['chunk'], 0)
            r['_addr_int']  = (file_off + base) if file_off is not None else None
            r['_cpu_addr']  = f'0x{r["_addr_int"]:04X}' if r['_addr_int'] is not None else ''
            r['_ida_hints'] = ida_names.get(r['_addr_int'], []) if r['_addr_int'] else []
            rows.append(r)

    # Priority sort: high n_calls_in first; tie-break by smaller size_bytes
    # (smaller procs are faster to probe and unlock cascade renames).
    rows.sort(key=lambda r: (-r['n_calls_in'], r['size_bytes']))

    # Bucket by chunk
    by_chunk: dict[str, list[dict]] = defaultdict(list)
    for r in rows:
        by_chunk[r['chunk']].append(r)

    # Build markdown
    lines: list[str] = []
    lines.append('# Phase-3 priority queue — game_func_N identity sweep')
    lines.append('')
    lines.append(f'_Auto-generated by `phase3_queue.py` from `coverage.csv` + '
                 f'`IDA_NAME_DELTA.md`._')
    lines.append('')
    lines.append(f'Total category-B (placeholder identity) procs: **{len(rows)}**')
    lines.append('')
    lines.append('## Priority order (top 30)')
    lines.append('')
    lines.append('Sorted by `n_calls_in DESC`, tie-break by smaller size.  '
                 'Higher n_calls_in = more callers = resolving this proc '
                 'clarifies more downstream sites at once.')
    lines.append('')
    lines.append('| Rank | Name | Chunk | Addr | Size | Calls in | Calls out | IDA hint |')
    lines.append('|---:|---|---|---|---:|---:|---:|---|')
    for i, r in enumerate(rows[:30], 1):
        ida = ', '.join(f'`{n}`' for n in r['_ida_hints']) or '_(none)_'
        addr = r['_cpu_addr'] or '_(no LST)_'
        lines.append(
            f'| {i} | `{r["name"]}` | {r["chunk"]} | {addr} | '
            f'{r["size_bytes"]} | {r["n_calls_in"]} | '
            f'{r["n_calls_out"]} | {ida} |'
        )
    lines.append('')

    lines.append('## By chunk (every B-category proc, grouped)')
    lines.append('')
    lines.append('Same data, bucketed for batch-mode probing — doing all of '
                 'one chunk in a session amortises harness setup cost '
                 '(BIN_PATHS lookup, video-driver stub install, fixture seed).')
    lines.append('')
    for chunk in sorted(by_chunk):
        chunk_rows = by_chunk[chunk]
        n_with_ida = sum(1 for r in chunk_rows if r['_ida_hints'])
        lines.append(f'### {chunk} ({len(chunk_rows)} procs, '
                     f'{n_with_ida} with IDA hints)')
        lines.append('')
        lines.append('| Name | Addr | Size | Calls in | Calls out | Far calls | IDA hint |')
        lines.append('|---|---|---:|---:|---:|---:|---|')
        # Within chunk, also sort by n_calls_in DESC
        chunk_rows.sort(key=lambda r: (-r['n_calls_in'], r['size_bytes']))
        for r in chunk_rows:
            ida = ', '.join(f'`{n}`' for n in r['_ida_hints']) or '_(none)_'
            addr = r['_cpu_addr'] or '_(no LST)_'
            lines.append(
                f'| `{r["name"]}` | {addr} | {r["size_bytes"]} | '
                f'{r["n_calls_in"]} | {r["n_calls_out"]} | '
                f'{r["far_calls"]} | {ida} |'
            )
        lines.append('')

    if skipped_sub:
        lines.append(f'## Excluded: {len(skipped_sub)} Sourcer `sub_NN` procs')
        lines.append('')
        lines.append('Per PLAN.md §6, `sub_NN` placeholders are mechanical '
                     'Sourcer decoration and get cleaned by a separate '
                     '`/asm-cleanup` pass, not runtime probing.  Listed here '
                     'for visibility only — not part of the Phase-3 work-list.')
        lines.append('')
        for r in sorted(skipped_sub, key=lambda x: (x['chunk'], x['name'])):
            lines.append(f'- `{r["name"]}` in {r["chunk"]} '
                         f'(size={r["size_bytes"]}, calls_in={r["n_calls_in"]})')
        lines.append('')

    lines.append('## Authoring loop (per PLAN §4.2)')
    lines.append('')
    lines.append('1. Pick the top unfinished row.  Note its entry_addr and '
                 'IDA hint (if any).')
    lines.append('2. Read the proc body in the chunk\'s .asm — eyeball '
                 'the prologue: does it `cmp [SI+N], const`?  Branch on '
                 'CF from a stubbed callee?  Touch a fixed DS offset?')
    lines.append('3. Stamp a test:')
    lines.append('   ```')
    lines.append('   python new.py <chunk> 0x<addr> --name <short> '
                 '--hyp "<IDA-hint or static-derived guess>"')
    lines.append('   ```')
    lines.append('4. Edit the stamped test — typically 2–4 probes covering '
                 'distinct branches.  Use `make_player_record` and '
                 '`stub_video_drivers` from fixtures.py.')
    lines.append('5. Run it: `python run.py --filter test_<chunk>_<short>.py`.')
    lines.append('6. Commit a `VERDICT: PASS|REFUTED|...` line; update '
                 '`INDEX.md` with the test row.')
    lines.append('7. If the proc has an IDA hint and the verdict CONFIRMS '
                 'it, add a static rename in the chunk\'s `.asm` (the '
                 'proc declaration + every `call`-site).  Re-verify '
                 'bit-perfect.')
    lines.append('')

    OUT.write_text('\n'.join(lines), encoding='utf-8')
    print(f'Wrote {OUT}')
    print(f'Top 5 by n_calls_in:')
    for r in rows[:5]:
        ida = ', '.join(r['_ida_hints']) or '(no IDA hint)'
        print(f'  {r["n_calls_in"]:3d} callers  {r["name"]:20s}  '
              f'in {r["chunk"]:10s}  -> {ida}')
    return 0


if __name__ == '__main__':
    import sys
    sys.exit(main())
