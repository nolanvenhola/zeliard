#!/usr/bin/env python3
"""
find_missing_equs.py

Scans every .asm/.inc under working/ for memory operands written as raw
hex literals (e.g.  `mov al, ds:[0FF77h]`  or  `cmp byte ptr [0E7h], al`).
For each such literal, checks whether any EQU symbol resolves to that
address.  Reports:

  - EQU MISSING:    the address has zero EQU definitions anywhere — a real
                    naming gap.
  - EQU UNUSED:     the address has an EQU but the reference uses raw hex
                    instead of the symbolic name — inconsistent usage.

Output: a markdown report at working/MISSING_EQUS.md listing each gap and
a sample reference site.

The point: every numeric literal in a memory operand that lives in the
DS-resident data area is a candidate for a missing label.  The report
gives a concrete worklist.
"""

import os, re, argparse
from collections import defaultdict
from pathlib import Path

ROOT = Path('c:/Projects/Zeliard/3_Assembly/tasm/working')

# Match a memory operand whose body is a hex literal.  The leading
# `[`, `cs:`, `ds:`, etc. ensure we don't catch immediate values.
# CRITICAL: the trailing `h` must NOT be followed by another word char,
# otherwise `cs:char_src_ptr` matches as `cs:ch` with addr=0x0C.
LITERAL_OPERAND = re.compile(
    r'(?:'
        # Bracketed: cs:[NNh] or [NNh]
        r'(?:ds|cs|es|ss|fs|gs):\[(?P<a1>[0-9A-Fa-f]+)h\]'
        r'|'
        r'\[(?P<a2>[0-9A-Fa-f]+)h\]'
        r'|'
        # Bare: cs:NNh — must end at word boundary
        r'(?:ds|cs|es|ss|fs|gs):(?P<a3>[0-9A-Fa-f]+)h(?!\w)'
    r')'
)

EQU_DEFN = re.compile(
    r'^\s*([a-zA-Z_]\w*)\s+equ\s+([0-9A-Fa-f]+)h\s*(?:;.*)?$'
)


def build_equ_map():
    """Return name -> set of addresses, and addr -> set of names."""
    name_to_addr = defaultdict(set)
    addr_to_name = defaultdict(set)
    for p in ROOT.rglob('*'):
        if p.suffix.lower() not in ('.asm', '.inc'):
            continue
        try:
            txt = p.read_text(encoding='utf-8', errors='replace')
        except OSError:
            continue
        for line in txt.splitlines():
            no_c = re.sub(r';.*', '', line)
            m = EQU_DEFN.match(no_c)
            if m:
                try:
                    addr = int(m.group(2), 16)
                except ValueError:
                    continue
                name_to_addr[m.group(1)].add(addr)
                addr_to_name[addr].add(m.group(1))
    return name_to_addr, addr_to_name


def find_literal_refs():
    """Return a list of (path, line_num, line, addr) for every memory
    operand written as a hex literal."""
    out = []
    for p in ROOT.rglob('*'):
        if p.suffix.lower() not in ('.asm', '.inc'):
            continue
        try:
            txt = p.read_text(encoding='utf-8', errors='replace')
        except OSError:
            continue
        for ln, line in enumerate(txt.splitlines(), 1):
            no_c = re.sub(r';.*', '', line)
            stripped = no_c.strip().lower()
            # Skip data declarations (db/dw/dd) — those literal hex values
            # are PAYLOADS, not memory references.
            if stripped.startswith(('db ', 'dw ', 'dd ', 'db\t', 'dw\t', 'dd\t')):
                continue
            for m in LITERAL_OPERAND.finditer(no_c):
                ah = m.group('a1') or m.group('a2') or m.group('a3')
                try:
                    addr = int(ah, 16)
                except (ValueError, TypeError):
                    continue
                out.append((p, ln, line.rstrip(), addr))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--range', nargs=2, metavar=('LO', 'HI'),
                    help='Restrict to address range (hex)')
    ap.add_argument('--threshold', type=int, default=2,
                    help='Only flag MISSING addresses with at least this many '
                         'reference sites (default: 2)')
    args = ap.parse_args()
    lo = int(args.range[0], 16) if args.range else 0x0000
    hi = int(args.range[1], 16) if args.range else 0xFFFF

    name_to_addr, addr_to_name = build_equ_map()
    refs = find_literal_refs()

    # addr -> list of (path, ln, line)
    addr_refs = defaultdict(list)
    for path, ln, line, addr in refs:
        if lo <= addr <= hi:
            addr_refs[addr].append((path, ln, line))

    missing = {}    # addr where there is NO equ at all
    unused  = {}    # addr where there is an equ but at least one site uses raw hex
    for addr, sites in addr_refs.items():
        if addr in addr_to_name:
            unused[addr] = sites
        else:
            if len(sites) >= args.threshold:
                missing[addr] = sites

    out_lines = []
    out_lines.append('# Missing-EQU Report')
    out_lines.append('')
    out_lines.append(
        f'Scanned {len(refs)} raw-hex memory operands across the cleaned'
        f' source.\n'
        f'Range: 0x{lo:04X}..0x{hi:04X}.  Min refs to flag MISSING: '
        f'{args.threshold}.\n'
    )
    out_lines.append(f'- **MISSING (no EQU exists)**: {len(missing)} addresses')
    out_lines.append(f'- **UNUSED (EQU exists, raw hex used anyway)**: '
                     f'{len(unused)} addresses')
    out_lines.append('')

    out_lines.append('## MISSING EQU symbols')
    out_lines.append('')
    out_lines.append('Each address below has at least 2 raw-hex memory references')
    out_lines.append('but no `equ` definition anywhere in the cleaned source.')
    out_lines.append('Adopting a symbolic name would make the call sites self-')
    out_lines.append('documenting.  Sorted by reference count (descending).')
    out_lines.append('')
    out_lines.append('| Address | Refs | Sample call site |')
    out_lines.append('|---|---|---|')
    for addr, sites in sorted(missing.items(),
                               key=lambda kv: (-len(kv[1]), kv[0])):
        s = sites[0]
        loc = f'{s[0].name}:{s[1]}'
        snippet = s[2].strip()[:80].replace('|', '\\|')
        out_lines.append(f'| `0x{addr:04X}` | {len(sites)} | '
                         f'`{loc}` — `{snippet}` |')

    out_lines.append('')
    out_lines.append('## UNUSED EQU symbols (raw hex used despite name existing)')
    out_lines.append('')
    out_lines.append('These addresses have a symbolic name in the EQU map but')
    out_lines.append('at least one reference site still uses the raw hex literal.')
    out_lines.append('Replacing the literal with the symbol makes the source self-')
    out_lines.append('consistent.')
    out_lines.append('')
    out_lines.append('| Address | EQU name(s) | Raw-hex sites | Sample |')
    out_lines.append('|---|---|---|---|')
    for addr, sites in sorted(unused.items(), key=lambda kv: -len(kv[1])):
        names = ', '.join(f'`{n}`' for n in sorted(addr_to_name[addr]))
        s = sites[0]
        loc = f'{s[0].name}:{s[1]}'
        snippet = s[2].strip()[:80].replace('|', '\\|')
        out_lines.append(f'| `0x{addr:04X}` | {names} | {len(sites)} | '
                         f'`{loc}` — `{snippet}` |')

    out_path = ROOT / 'MISSING_EQUS.md'
    out_path.write_text('\n'.join(out_lines), encoding='utf-8')
    print(f'Wrote {out_path}')
    print(f'  MISSING addresses: {len(missing)}')
    print(f'  UNUSED  addresses: {len(unused)}')


if __name__ == '__main__':
    main()
