#!/usr/bin/env python3
"""rename_loc_labels.py - heuristic loc_N -> semantic-name renamer.

For each `loc_N:` label, look at the first 1-2 instructions following
the label, then generate a contextual name based on what those
instructions do.  Goal: replace anonymous Sourcer decoration with
names a human reader can scan quickly.

Conservative — when the heuristic doesn't have high confidence, leaves
the label as `loc_N`.  Run, then `verify1.py` to confirm bit-perfect.

Usage:  python rename_loc_labels.py <path/to/file.asm> [--apply]

Without --apply: dry-run, prints proposed renames.
With --apply: writes the renamed file.
"""
import re
import sys
from pathlib import Path
from collections import OrderedDict


def first_real_instruction(lines, label_idx):
    """Find the first non-blank/non-comment line after a label."""
    for i in range(label_idx + 1, min(label_idx + 6, len(lines))):
        ln = lines[i].split(';', 1)[0].strip()
        if not ln:
            continue
        return i, ln
    return None, ''


def derive_name(loc_n, label_line, lines, label_idx):
    """Heuristic: generate a name from the first instruction(s) after the label."""
    _i, instr = first_real_instruction(lines, label_idx)
    if not instr:
        return None

    # Patterns ordered by specificity:

    # mov word ptr ds:gvar_script_ptr, ADDR  ->  script_ADDR
    m = re.search(r'mov\s+word\s+ptr\s+ds:gvar_script_ptr\s*,\s*0?([0-9A-Fa-f]+)h?',
                  instr, re.IGNORECASE)
    if m:
        return f'script_{m.group(1).upper()}'

    # mov word ptr ds:VAR, ADDR  ->  set_VAR_ADDR
    m = re.search(r'mov\s+word\s+ptr\s+ds:(\w+)\s*,\s*0?([0-9A-Fa-f]+)h?',
                  instr, re.IGNORECASE)
    if m and not m.group(1).startswith('['):
        return f'set_{m.group(1)}_{m.group(2).upper()}'

    # mov byte ptr ds:VAR, IMM  ->  set_VAR_IMM
    m = re.search(r'mov\s+byte\s+ptr\s+ds:(\w+)\s*,\s*0?([0-9A-Fa-f]+)h?',
                  instr, re.IGNORECASE)
    if m and not m.group(1).startswith('['):
        return f'set_{m.group(1)}_{m.group(2).upper()}'

    # cmp byte ptr ds:VAR, IMM  ->  check_VAR_eq_IMM
    m = re.search(r'cmp\s+(?:byte|word)\s+ptr\s+ds:(\w+)\s*,\s*0?([0-9A-Fa-f]+)h?',
                  instr, re.IGNORECASE)
    if m and not m.group(1).startswith('['):
        return f'check_{m.group(1)}_eq_{m.group(2).upper()}'

    # test byte ptr ds:VAR, IMM  ->  test_VAR
    m = re.search(r'test\s+(?:byte|word)\s+ptr\s+ds:(\w+)', instr, re.IGNORECASE)
    if m and not m.group(1).startswith('['):
        return f'test_{m.group(1)}'

    # call FUNC                       ->  call_FUNC
    m = re.search(r'^call\s+(?!word\b)(?!dword\b)(\w+)', instr, re.IGNORECASE)
    if m:
        return f'call_{m.group(1)}'

    # call word ptr cs:NAME  ->  drv_NAME
    m = re.search(r'call\s+word\s+ptr\s+cs:(\w+)', instr, re.IGNORECASE)
    if m:
        return f'drv_{m.group(1)}'

    # jmp word ptr cs:NAME   ->  chain_to_NAME
    m = re.search(r'jmp\s+word\s+ptr\s+cs:(\w+)', instr, re.IGNORECASE)
    if m:
        return f'chain_to_{m.group(1)}'

    # ret/retn  -> early_exit
    if re.match(r'ret(n|f)?\s*$', instr, re.IGNORECASE):
        return 'early_exit'

    return None


def main() -> int:
    if len(sys.argv) < 2:
        print('Usage: rename_loc_labels.py <file.asm> [--apply]')
        return 1
    path = Path(sys.argv[1])
    apply = '--apply' in sys.argv[2:]

    text = path.read_text(encoding='utf-8')
    lines = text.splitlines()

    # First pass: collect proposed renames keyed by `loc_N`
    label_pat = re.compile(r'^(loc_\d+):\s*$')
    proposed: OrderedDict[str, str] = OrderedDict()
    used_names: set[str] = set()

    for i, line in enumerate(lines):
        m = label_pat.match(line)
        if not m:
            continue
        loc_n = m.group(1)
        if loc_n in proposed:
            continue
        candidate = derive_name(loc_n, line, lines, i)
        if candidate is None:
            continue
        # Disambiguate collisions by appending the loc number
        n_suffix = loc_n.split('_')[1]
        final = candidate
        if final in used_names:
            final = f'{candidate}_{n_suffix}'
        if final in used_names:
            continue   # Give up on this one
        used_names.add(final)
        proposed[loc_n] = final

    # Second pass: apply renames as exact-word replacements
    print(f'{path.name}: {len(proposed)} proposed renames')
    for old, new in proposed.items():
        print(f'  {old:10} -> {new}')

    if not apply:
        print('\n(dry-run; pass --apply to write)')
        return 0

    new_text = text
    for old, new in proposed.items():
        new_text = re.sub(rf'\b{re.escape(old)}\b', new, new_text)

    path.write_text(new_text, encoding='utf-8')
    print(f'\nWrote {path}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
