#!/usr/bin/env python3
"""find_missing_equs.py - scan all .asm files for raw-hex memory operands
and report which need an EQU name.

Two reports:
  MISSING  - raw hex used >= MIN_REFS times but no `equ` defined anywhere
             in the cleaned source.  Symbolic naming would help.
  UNUSED   - raw hex used >= 1 time despite an `equ` existing for the
             same address.  Replacing the literal with the symbol makes
             the source self-consistent.

Output: working/MISSING_EQUS.md
"""
from __future__ import annotations

import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
OUT = WORKING / 'MISSING_EQUS.md'

MIN_REFS = 2  # only report MISSING when >= this many refs

# Operand patterns we look for: `ds:[1234h]`, `cs:[1234h]`, `es:[1234h]`,
# `ss:[1234h]`, and bare `[1234h]` (without segment prefix).
# We accept optional indexing like `cs:[1234h][bx]` -- still the same base.
HEX_OPERAND_RE = re.compile(
    r'(?:(?:ds|cs|es|ss):)?\[\s*0?([0-9A-Fa-f]+)h\s*\]',
)
# `equ` definitions
EQU_RE = re.compile(
    r'^(?P<name>\w+)\s+equ\s+0?(?P<addr>[0-9A-Fa-f]+)h?\s*(?:;.*)?$',
    re.IGNORECASE | re.MULTILINE,
)
# Strip comments before matching operands (don't count `; was: cs:[110h]`)
COMMENT_RE = re.compile(r';.*$')


def scan_file(path: Path):
    """Return (raw_uses_by_addr, equ_names_by_addr).

    raw_uses_by_addr: {addr_int: [(line_num, sample_text), ...]}
    equ_names_by_addr: {addr_int: [name, ...]}
    """
    raw_uses: dict[int, list[tuple[int, str]]] = defaultdict(list)
    equ_names: dict[int, list[str]] = defaultdict(list)
    try:
        text = path.read_text(encoding='utf-8', errors='replace')
    except OSError:
        return raw_uses, equ_names
    for ln, line in enumerate(text.splitlines(), start=1):
        # Track EQU definitions first
        m = EQU_RE.match(line)
        if m:
            try:
                a = int(m.group('addr'), 16)
                equ_names[a].append(m.group('name'))
            except ValueError:
                pass
            continue
        # Strip trailing comments, then look for hex operands
        stripped = COMMENT_RE.sub('', line)
        for m2 in HEX_OPERAND_RE.finditer(stripped):
            try:
                a = int(m2.group(1), 16)
                raw_uses[a].append((ln, line.rstrip()))
            except ValueError:
                pass
    return raw_uses, equ_names


def main() -> int:
    asm_files = sorted(WORKING.rglob('*.asm'))
    # Aggregate across all files.
    global_equs: dict[int, set[str]] = defaultdict(set)
    global_raws: dict[int, list[tuple[Path, int, str]]] = defaultdict(list)

    for f in asm_files:
        raw_uses, equ_names = scan_file(f)
        for addr, names in equ_names.items():
            for n in names:
                global_equs[addr].add(n)
        for addr, uses in raw_uses.items():
            for ln, txt in uses:
                global_raws[addr].append((f, ln, txt))

    # Classify each address
    missing: list[tuple[int, int, tuple[Path, int, str]]] = []
    unused: list[tuple[int, list[str], int, tuple[Path, int, str]]] = []
    for addr, uses in global_raws.items():
        n_refs = len(uses)
        sample = uses[0]
        names = sorted(global_equs.get(addr, set()))
        if names:
            unused.append((addr, names, n_refs, sample))
        elif n_refs >= MIN_REFS:
            missing.append((addr, n_refs, sample))

    missing.sort(key=lambda x: (-x[1], x[0]))
    unused.sort(key=lambda x: (-x[2], x[0]))

    out: list[str] = []
    out.append('# Missing-EQU Report')
    out.append('')
    out.append(f'Scanned {sum(len(v) for v in global_raws.values())} '
               f'raw-hex memory operands across the cleaned source.')
    out.append(f'Range: 0x0000..0xFFFF.  Min refs to flag MISSING: '
               f'{MIN_REFS}.')
    out.append('')
    out.append(f'- **MISSING (no EQU exists)**: {len(missing)} addresses')
    out.append(f'- **UNUSED (EQU exists, raw hex used anyway)**: '
               f'{len(unused)} addresses')
    out.append('')
    out.append('## MISSING EQU symbols')
    out.append('')
    out.append('Each address below has at least {} raw-hex memory '
               'references but no `equ` definition anywhere in the '
               'cleaned source.'.format(MIN_REFS))
    out.append('')
    out.append('| Address | Refs | Sample call site |')
    out.append('|---|---|---|')
    for addr, n_refs, (path, ln, txt) in missing:
        rel = path.relative_to(ROOT).as_posix()
        # Trim long sample lines
        sample = txt.strip()
        if len(sample) > 90:
            sample = sample[:87] + '...'
        out.append(f'| `0x{addr:04X}` | {n_refs} | '
                   f'`{rel}:{ln}` — `{sample}` |')
    out.append('')
    out.append('## UNUSED EQU symbols (raw hex used despite name existing)')
    out.append('')
    out.append('These addresses have a symbolic name in the EQU map but '
               'at least one reference site still uses the raw hex '
               'literal.  Replacing the literal with the symbol makes '
               'the source self-consistent.')
    out.append('')
    out.append('| Address | EQU name(s) | Raw-hex sites | Sample |')
    out.append('|---|---|---|---|')
    for addr, names, n_refs, (path, ln, txt) in unused:
        rel = path.relative_to(ROOT).as_posix()
        sample = txt.strip()
        if len(sample) > 70:
            sample = sample[:67] + '...'
        names_str = ', '.join(f'`{n}`' for n in names)
        out.append(f'| `0x{addr:04X}` | {names_str} | {n_refs} | '
                   f'`{rel}:{ln}` — `{sample}` |')
    out.append('')

    OUT.write_text('\n'.join(out), encoding='utf-8')
    print(f'Wrote {OUT}')
    print(f'  MISSING: {len(missing)} addresses')
    print(f'  UNUSED:  {len(unused)} addresses')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
