#!/usr/bin/env python3
"""
test_fight_game_func_131.py — at CPU 0x9348, 33 bytes, 2 callers.

Sibling of game_func_129 (now `is_unknown_or_area5_slot_b`) but the slot
check uses `dec cl; dec cl` so it tests cl-2==0 (slot_c family) instead
of cl-1==0 (slot_b).  Net: CF=1 iff (entity NOT known) OR (area==5 AND
entity in move_slot_c family).
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness, DATA_SEG  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

GVAR_GAME_SEG = 0xFF2C


def setup(h):
    h.write_data(0x8000, bytes([0x10, 0x21, 0x31, 0x99]) + bytes([0]*0x14))
    h.write_data(0x8024, bytes([0x40, 0x41, 0x42, 0x43]))
    h.write_data(0x8028, bytes([0x20, 0x21, 0x22, 0x23]))
    h.write_data(0x802C, bytes([0x30, 0x31, 0x32, 0x33]))


def probe(h, proc, area, di_eid):
    h.write_byte(0xC012, area)
    h.write_byte(0x1000, di_eid)
    setup(h)
    snap = h.snapshot()
    r = h.call_function(proc, regs={'di': 0x1000, 'si': 0x3000},
                        max_steps=200)
    h.restore(snap)
    return r['flags_after']['CF']


def main() -> int:
    flat, base = BIN_PATHS['fight']
    proc = base + resolve_proc('fight', 'is_unknown_or_area5_slot_c',
                               fallback_names=('game_func_131',))
    h = TasmHarness(flat, base)
    stub_video_drivers(h)
    h.write_code(GVAR_GAME_SEG, [DATA_SEG & 0xFF, (DATA_SEG >> 8) & 0xFF])

    print(f'is_unknown_or_area5_slot_c @ CPU 0x{proc:04X}')
    cases = [
        ('A', 5, 0x31, True,  'known + area5 + in slot_c -> CF=1'),
        ('B', 5, 0x21, False, 'known + area5 + in slot_b -> CF=0'),
        ('C', 3, 0x31, False, 'known but area!=5 -> CF=0'),
        ('D', 5, 0x05, True,  'NOT known -> CF=1 early'),
    ]
    ok = True
    for label, area, di_e, exp, desc in cases:
        cf = probe(h, proc, area, di_e)
        match = cf is exp
        ok = ok and match
        print(f'{label}: area={area}, [di]=0x{di_e:02X} ({desc})  '
              f'CF={cf}  expected {exp}  {"OK" if match else "FAIL"}')

    if ok:
        print('\nVERDICT: PASS: game_func_131 = `is_unknown_or_area5_slot_c`. '
              'Twin of game_func_129 but slot_c family check.  Rename: '
              '`is_unknown_or_area5_slot_c`.')
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
