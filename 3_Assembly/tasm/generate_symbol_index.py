#!/usr/bin/env python3
"""
generate_symbol_index.py - Build a global cross-reference of every label,
proc, EQU, and macro across the cleaned Zeliard ASM source tree.

Output: working/SYMBOL_INDEX.md

For each symbol:
  - Where it's defined (file + line)
  - Where it's referenced from (cross-references)

This is Item 11 of CLEANUP_ROADMAP.md.
"""

import re
import os
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
OUT = WORKING / 'SYMBOL_INDEX.md'

# Directories that hold .asm we care about
ASM_DIRS = ['core', 'drivers', 'zelres1/code', 'zelres2/code', 'zelres3/code']

# What to skip (boilerplate)
SKIP_NAMES = {'target', 'seg_a', 'start'}


def parse_file(path):
    """Yield (kind, name, line_num, raw_line) for every definition+reference."""
    rel = str(path.relative_to(WORKING)).replace('\\', '/')
    with open(path, encoding='utf-8') as f:
        lines = f.readlines()

    for i, raw in enumerate(lines, 1):
        # Strip comments
        no_comment = re.sub(r';.*$', '', raw).rstrip()
        if not no_comment.strip():
            continue

        # 1) EQU definition: name equ <value>
        m = re.match(r'^([a-zA-Z_]\w*)\s+equ\s+', no_comment)
        if m:
            yield ('def_equ', m.group(1), i, rel, raw.rstrip())
            continue

        # 2) Proc definition: name proc near|far
        m = re.match(r'^([a-zA-Z_]\w*)\s+proc\s+(?:near|far)', no_comment)
        if m:
            yield ('def_proc', m.group(1), i, rel, raw.rstrip())
            continue

        # 3) Macro definition: NAME MACRO ...
        m = re.match(r'^([a-zA-Z_]\w*)\s+MACRO\s', no_comment)
        if m:
            yield ('def_macro', m.group(1), i, rel, raw.rstrip())
            continue

        # 4) Plain label: name:
        m = re.match(r'^([a-zA-Z_]\w*):\s*$', no_comment)
        if m:
            yield ('def_label', m.group(1), i, rel, raw.rstrip())
            continue

        # 5) Plain `name label word|byte` declaration
        m = re.match(r'^([a-zA-Z_]\w*)\s+label\s+(byte|word)', no_comment)
        if m:
            yield ('def_label', m.group(1), i, rel, raw.rstrip())
            continue

        # References — we look for word boundaries against any identifier-like
        # token in the rest of the line. This is a heuristic — it'll catch
        # operands and instruction-target uses.
        for ref in re.findall(r'\b([a-zA-Z_]\w*)\b', no_comment):
            if ref in SKIP_NAMES:
                continue
            yield ('ref', ref, i, rel, raw.rstrip())


def main():
    defs = defaultdict(list)   # name -> [(kind, file, line, raw)]
    refs = defaultdict(list)   # name -> [(file, line, raw)]

    for d in ASM_DIRS:
        full = WORKING / d
        if not full.exists():
            continue
        for asm in sorted(full.glob('*.asm')):
            for kind, name, line, rel, raw in parse_file(asm):
                if kind.startswith('def_'):
                    defs[name].append((kind, rel, line, raw))
                else:
                    refs[name].append((rel, line, raw))

    # Build index
    all_names = set(defs.keys()) | set(refs.keys())

    # Filter out things that are clearly x86 mnemonics, register names, directives —
    # only keep names that are DEFINED somewhere (so refs to mov/ax/etc are dropped).
    # Also skip symbols that are only used as `db` data (no actual references) —
    # these clutter the index without adding navigation value.
    indexed = sorted(n for n in all_names if n in defs and (n in refs or any(k != 'def_label' for k, _, _, _ in defs[n])))

    # Write the index
    with open(OUT, 'w', encoding='utf-8') as f:
        f.write('# Zeliard Symbol Index\n\n')
        f.write('Auto-generated cross-reference of every defined symbol across the\n')
        f.write('cleaned ASM source tree. Each entry shows where the symbol is\n')
        f.write('defined and where it is referenced.\n\n')
        f.write(f'Total defined symbols: **{len(indexed)}**.\n\n')
        f.write('Regenerate: `python 3_Assembly/tasm/generate_symbol_index.py`\n\n')
        f.write('---\n\n')

        # Compact one-line-per-symbol format grouped by first letter.
        f.write('| Symbol | Kind | Defined | Refs |\n')
        f.write('|--------|------|---------|------|\n')
        for name in indexed:
            kinds = sorted(set(k.replace('def_', '') for k, _, _, _ in defs[name]))
            kind_label = '/'.join(kinds)
            # First definition only (most symbols have one; show count if >1)
            d_first = defs[name][0]
            d_link = f'[{d_first[1]}:{d_first[2]}]({d_first[1]}#L{d_first[2]})'
            if len(defs[name]) > 1:
                d_link += f' (+{len(defs[name]) - 1})'
            n_refs = len(refs.get(name, []))
            f.write(f'| `{name}` | {kind_label} | {d_link} | {n_refs} |\n')

    # Summary
    file_count = sum(1 for d in ASM_DIRS for _ in (WORKING / d).glob('*.asm') if (WORKING / d).exists())
    print(f'Wrote {OUT}')
    print(f'  symbols defined: {len(indexed)}')
    print(f'  files scanned:   {file_count}')


if __name__ == '__main__':
    main()
