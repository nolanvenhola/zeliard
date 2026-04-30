#!/usr/bin/env python3
"""
test_fight_game_func_129.py — at CPU 0x92F2, 31 bytes, 2 callers.

Body chain:
    is_entity_known_type([di])  ; ZF=1 if known
    if ZF=0 -> stc; retn (return CF=1 = "skip" or "ok")
    cmp area_num, 5
    if !=5 -> clc; retn (CF=0)
    lookup_move_slot_family([si])
    dec cl  (cl was 0/1/2/0xFF; cl-1 == 0 means slot_b)
    if zf -> stc; retn (CF=1 = "in slot_b family")
    else -> clc; retn (CF=0)

Net: CF=1 iff (entity NOT known) OR (area==5 AND in slot_b family).
The "not known" path returns CF=1 via stc/retn — this might be a
caller convention where CF=1 = "skip/abort".
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness, DATA_SEG  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

GAME_FUNC_129 = 0x92F2
AREA_NUM = 0xC012
GVAR_GAME_SEG = 0xFF2C


def setup(h):
    # enemy_id_table: include the IDs we use as "known"
    h.write_data(0x8000, bytes([0x10, 0x21, 0x41, 0x99]) + bytes([0]*0x14))
    # Slot tables — 0x21 in slot_b, 0x41 in slot_a, 0x10 in NEITHER (so dec cl
    # in the slot path returns "not slot_b").
    h.write_data(0x8024, bytes([0x40, 0x41, 0x42, 0x43]))  # slot_a
    h.write_data(0x8028, bytes([0x20, 0x21, 0x22, 0x23]))  # slot_b
    h.write_data(0x802C, bytes([0x30, 0x31, 0x32, 0x33]))  # slot_c


def probe(h, area, di_eid):
    h.write_byte(AREA_NUM, area)
    h.write_byte(0x1000, di_eid)
    setup(h)
    snap = h.snapshot()
    r = h.call_function(GAME_FUNC_129, regs={'di': 0x1000, 'si': 0x3000},
                        max_steps=200)
    h.restore(snap)
    return r['flags_after']['CF']


def main() -> int:
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)
    h.write_code(GVAR_GAME_SEG, [DATA_SEG & 0xFF, (DATA_SEG >> 8) & 0xFF])

    print(f'game_func_129 @ CPU 0x{GAME_FUNC_129:04X}')
    cases = [
        # AL = [di] is used for BOTH classification and slot lookup
        ('A', 5, 0x21, True,  'known + area5 + in slot_b -> CF=1'),
        ('B', 5, 0x41, False, 'known + area5 + in slot_a -> CF=0'),
        ('C', 3, 0x21, False, 'known but area!=5 -> CF=0'),
        ('D', 5, 0x05, True,  'AL not in enemy_id_table -> CF=1 early'),
    ]
    ok = True
    for label, area, di_e, exp, desc in cases:
        cf = probe(h, area, di_e)
        match = cf is exp
        ok = ok and match
        print(f'{label}: area={area}, [di]=0x{di_e:02X} '
              f'({desc})  CF={cf}  expected {exp}  {"OK" if match else "FAIL"}')

    if ok:
        print('\nVERDICT: PASS: game_func_129 returns CF=1 iff '
              '(entity at [di] NOT known type) OR (area_num==5 AND entity '
              'at [si] in move_slot_b family).  Used by 2 callers as a '
              "skip/abort flag.  Rename: `is_unknown_or_area5_slot_b`.")
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
