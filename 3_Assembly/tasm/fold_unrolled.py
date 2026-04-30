#!/usr/bin/env python3
"""fold_unrolled.py - replace inline unrolled-loop blocks in the GF
graphics-fill drivers with single-line macro calls.

Patterns folded (each replaced by one macro-call line):
  SPRITE_SLOT_SCAN_STEP   (test [si],80h ; jz <merge> ; call init ; merge: inc si ; inc bx)
  SPRITE_STATE_SCAN_STEP  (cmpsb ; jz <merge> ; call update ; merge: inc bx)
  DI_WRAP_STEP / SI_WRAP_STEP  (CGA-only: add reg,1FFEh ; cmp ...4000h ; jb <merge> ; add reg,wrap ; merge:)

Run AFTER the macro definitions are added at the top of the file.
Verify BIT-PERFECT after.

Usage:  python fold_unrolled.py <file.asm>
"""
import re
import sys
from pathlib import Path

# Each pattern: (regex, replacement_template_lambda)

PAT_SPRITE_SLOT = re.compile(
    r'(?P<lead>^[ \t]*)test\s+byte\s+ptr\s+\[si\],80h\s*$'
    r'\n(?P=lead)jz\s+(?P<merge>[a-zA-Z_][\w]*)[^\n]*$'
    r'\n(?P=lead)call\s+sprite_slot_init\s*$'
    r'\n\n(?P=merge):\s*$'
    r'\n(?P=lead)inc\s+si\s*$'
    r'\n(?P=lead)inc\s+bx\s*$',
    re.MULTILINE,
)

PAT_SPRITE_STATE = re.compile(
    r'(?P<lead>^[ \t]*)cmpsb[^\n]*$'
    r'\n(?P=lead)jz\s+(?P<merge>[a-zA-Z_][\w]*)[^\n]*$'
    r'\n(?P=lead)call\s+sprite_state_update\s*$'
    r'\n\n(?P=merge):\s*$'
    r'\n(?P=lead)inc\s+bx\s*$',
    re.MULTILINE,
)

PAT_WRAP = re.compile(
    r'(?P<lead>^[ \t]*)add\s+(?P<reg>di|si),1FFEh\s*$'
    r'\n(?P=lead)cmp\s+(?P=reg),4000h\s*$'
    r'\n(?P=lead)jb\s+(?P<merge>[a-zA-Z_][\w]*)[^\n]*$'
    r'\n(?P=lead)add\s+(?P=reg),cga_wrap_add\s*$'
    r'\n\n(?P=merge):\s*$',
    re.MULTILINE,
)


def fold_all(text: str) -> tuple[str, dict[str, int]]:
    counts = {}

    text, n = PAT_SPRITE_SLOT.subn(
        lambda m: f"{m.group('lead')}SPRITE_SLOT_SCAN_STEP {m.group('merge')}",
        text,
    )
    counts['SPRITE_SLOT_SCAN_STEP'] = n

    text, n = PAT_SPRITE_STATE.subn(
        lambda m: f"{m.group('lead')}SPRITE_STATE_SCAN_STEP {m.group('merge')}",
        text,
    )
    counts['SPRITE_STATE_SCAN_STEP'] = n

    text, n = PAT_WRAP.subn(
        lambda m: f"{m.group('lead')}{m.group('reg').upper()}_WRAP_STEP {m.group('merge')}",
        text,
    )
    counts['WRAP_STEP'] = n

    return text, counts


def main() -> int:
    if len(sys.argv) < 2:
        print('Usage: fold_unrolled.py <file.asm>')
        return 1
    p = Path(sys.argv[1])
    text = p.read_text(encoding='utf-8')
    new, counts = fold_all(text)
    total = sum(counts.values())
    if total == 0:
        print(f'{p.name}: no patterns matched')
        return 0
    p.write_text(new, encoding='utf-8')
    print(f'{p.name}: {total} blocks folded  ({counts})')
    return 0


if __name__ == '__main__':
    sys.exit(main())
