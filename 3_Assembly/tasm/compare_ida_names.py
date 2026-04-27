#!/usr/bin/env python3
"""
compare_ida_names.py - Cross-check our cleaned source's symbol names against
the friend's IDA decompilation in 3_Assembly/ida/.

The IDA work uses semantic names derived from running the actual game in
the IDA debugger. Where the same address has different names in our source
vs IDA, the IDA name is almost certainly more accurate.

This script:
1. Parses every EQU in our shared .inc files
   (core/zeliard.inc, drivers/stick.inc, drivers/stdply.inc,
    zelres1/code/zr1com.inc, zelres2/code/zr2com.inc, zelres3/code/zr3com.inc)
2. Parses every EQU in the IDA shared .inc files
   (3_Assembly/ida/common.inc, dungeon.inc, town.inc, gdmcga.inc, mole.inc)
3. Joins by address and reports name deltas.

Output: working/IDA_NAME_DELTA.md with proposed renames.
"""

import re
import os
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
IDA = ROOT.parent / 'ida'

OUR_INCS = [
    WORKING / 'core' / 'zeliard.inc',
    WORKING / 'drivers' / 'stick.inc',
    WORKING / 'drivers' / 'stdply.inc',
    WORKING / 'zelres1' / 'code' / 'zr1com.inc',
    WORKING / 'zelres2' / 'code' / 'zr2com.inc',
    WORKING / 'zelres3' / 'code' / 'zr3com.inc',
]

IDA_INCS = [
    IDA / 'common.inc',
    IDA / 'dungeon.inc',
    IDA / 'town.inc',
    IDA / 'gdmcga.inc',
    IDA / 'mole.inc',
]


def parse_inc(path):
    """Return list of (name, value, line) for EQU declarations."""
    out = []
    if not path.exists():
        return out
    for ln, line in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
        # Strip comments
        s = re.sub(r';.*', '', line).rstrip()
        m = re.match(r'^\s*([a-zA-Z_]\w*)\s+equ\s+(\S+)', s)
        if m:
            name = m.group(1)
            val = m.group(2).rstrip(',').strip()
            out.append((name, val, ln))
    return out


def normalize(val):
    """Normalize hex like 010Ch / 0x10C / 10Ch to canonical form."""
    val = val.upper().replace('0X', '').rstrip('H')
    # Strip leading zeros but keep at least one digit
    val = val.lstrip('0') or '0'
    # Verify it parses as hex; otherwise keep raw
    try:
        n = int(val, 16)
        return f'0x{n:X}'
    except ValueError:
        return val


def main():
    # Build address → list of (name, source_file) for both sides
    our_by_addr = defaultdict(list)
    ida_by_addr = defaultdict(list)

    for inc in OUR_INCS:
        for name, val, ln in parse_inc(inc):
            addr = normalize(val)
            our_by_addr[addr].append((name, inc.name, ln))

    for inc in IDA_INCS:
        for name, val, ln in parse_inc(inc):
            addr = normalize(val)
            ida_by_addr[addr].append((name, inc.name, ln))

    # Find addresses in both
    common = sorted(set(our_by_addr) & set(ida_by_addr),
                    key=lambda a: int(a[2:], 16) if a.startswith('0x') else 0)

    only_ours = sorted(set(our_by_addr) - set(ida_by_addr),
                       key=lambda a: int(a[2:], 16) if a.startswith('0x') else 0)
    only_ida = sorted(set(ida_by_addr) - set(our_by_addr),
                      key=lambda a: int(a[2:], 16) if a.startswith('0x') else 0)

    out_lines = []
    out_lines.append('# IDA-vs-Cleaned Name Delta Report')
    out_lines.append('')
    out_lines.append('Cross-check: same address defined in both our cleaned `.inc` files and the')
    out_lines.append('friend\'s IDA decompilation `.inc` files. Where names differ, the IDA name is')
    out_lines.append('almost certainly more accurate (derived from runtime IDA debugging).')
    out_lines.append('')
    out_lines.append(f'- Addresses in both: **{len(common)}**')
    out_lines.append(f'- Only in our source: {len(only_ours)}')
    out_lines.append(f'- Only in IDA: {len(only_ida)}')
    out_lines.append('')
    out_lines.append('## Name agreements / disagreements at shared addresses')
    out_lines.append('')
    out_lines.append('| Address | Our names | IDA names | Status |')
    out_lines.append('|---|---|---|---|')

    agree = disagree = 0
    rename_candidates = []
    for addr in common:
        ours = sorted(set(n for n, _, _ in our_by_addr[addr]))
        idas = sorted(set(n for n, _, _ in ida_by_addr[addr]))
        # Are any of our names in IDA's names (exact match)?
        if set(ours) & set(idas):
            status = 'agree'
            agree += 1
        else:
            status = '**rename?**'
            disagree += 1
            rename_candidates.append((addr, ours, idas))
        ours_str = ', '.join(f'`{n}`' for n in ours)
        idas_str = ', '.join(f'`{n}`' for n in idas)
        out_lines.append(f'| `{addr}` | {ours_str} | {idas_str} | {status} |')

    out_lines.append('')
    out_lines.append(f'**Agreements: {agree}** | **Disagreements: {disagree}**')
    out_lines.append('')
    out_lines.append('## Disagreement summary (rename candidates)')
    out_lines.append('')
    out_lines.append('Where IDA has a name our source doesn\'t use, consider adopting the IDA name')
    out_lines.append('as primary (as alias) in the relevant shared .inc:')
    out_lines.append('')
    for addr, ours, idas in rename_candidates:
        ours_str = ', '.join(ours)
        idas_str = ', '.join(idas)
        out_lines.append(f'- `{addr}`: `{ours_str}` → consider IDA name `{idas_str}`')

    out_lines.append('')
    out_lines.append('## Symbols only in IDA (potential coverage gaps in our .inc files)')
    out_lines.append('')
    out_lines.append('IDA defines these names at addresses we don\'t have any name for. Adopting')
    out_lines.append('them would extend our shared-symbol coverage.')
    out_lines.append('')
    for addr in only_ida[:80]:  # cap
        names = ', '.join(f'`{n}`' for n, _, _ in ida_by_addr[addr][:3])
        out_lines.append(f'- `{addr}`: {names}')
    if len(only_ida) > 80:
        out_lines.append(f'- ...and {len(only_ida) - 80} more')

    out = WORKING / 'IDA_NAME_DELTA.md'
    out.write_text('\n'.join(out_lines), encoding='utf-8')
    print(f'Wrote {out}')
    print(f'  Shared addresses: {len(common)} ({agree} agree, {disagree} disagree)')
    print(f'  IDA-only: {len(only_ida)}')
    print(f'  Ours-only: {len(only_ours)}')


if __name__ == '__main__':
    main()
