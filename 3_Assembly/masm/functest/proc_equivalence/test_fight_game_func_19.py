#!/usr/bin/env python3
"""
test_fight_game_func_19.py — game_func_19 at CPU 0x6947, 24 bytes, 2 callers.

Body: gate on area_num == 7 (returns CF=0 if in area 7), else look up
entity ID at [si] via lookup_move_slot_family; returns CF=1 iff cl-1 == 0
(entity is in move_slot_b family).  Used to identify entities that need
special handling outside area 7.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness, DATA_SEG  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

AREA_NUM = 0xC012
GVAR_GAME_SEG = 0xFF2C
TABLE_A = 0x8024
TABLE_B = 0x8028
TABLE_C = 0x802C


def setup(h):
    h.write_data(TABLE_A, bytes([0x10, 0x11, 0x12, 0x13]))
    h.write_data(TABLE_B, bytes([0x20, 0x21, 0x22, 0x23]))
    h.write_data(TABLE_C, bytes([0x30, 0x31, 0x32, 0x33]))


def probe(h, proc, area, entity_id):
    h.write_byte(AREA_NUM, area)
    h.write_byte(0x1000, entity_id)
    setup(h)
    snap = h.snapshot()
    r = h.call_function(proc, regs={'si': 0x1000}, max_steps=200)
    cf = r['flags_after']['CF']
    h.restore(snap)
    return cf


def main() -> int:
    flat, base = BIN_PATHS['fight']
    proc = base + resolve_proc('fight', 'is_non_area7_slot_b_entity',
                               fallback_names=('game_func_19',))
    h = TasmHarness(flat, base)
    stub_video_drivers(h)
    h.write_code(GVAR_GAME_SEG, [DATA_SEG & 0xFF, (DATA_SEG >> 8) & 0xFF])

    cases = [
        ('A', 7, 0x21, False, 'area=7 -> CF=0 (early skip)'),
        ('B', 3, 0x21, True,  'area!=7, entity in slot_b -> CF=1'),
        ('C', 3, 0x11, False, 'area!=7, entity in slot_a -> CF=0'),
        ('D', 3, 0x99, False, 'area!=7, entity unknown -> CF=0'),
    ]
    ok = True
    for label, area, eid, expect, desc in cases:
        cf = probe(h, proc, area, eid)
        match = cf is expect
        ok = ok and match
        print(f'{label}: area={area}, AL=0x{eid:02X} ({desc})  '
              f'CF={cf}  expected {expect}  {"OK" if match else "FAIL"}')

    if ok:
        print('\nVERDICT: PASS: game_func_19 returns CF=1 iff area_num != 7 '
              'AND entity ID at [si] is in move_slot_b family.  Rename: '
              "`is_non_area7_slot_b_entity`.")
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
