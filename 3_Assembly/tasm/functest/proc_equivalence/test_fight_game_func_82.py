#!/usr/bin/env python3
"""
test_fight_game_func_82.py — game_func_82 at CPU 0x814E, 23 bytes, 3 callers.

Tests if [si] equals DL, DL+1, or DL+2.  Returns DH:
    1  if [si] == DL          (exact match)
    0  if [si] == DL + 1      (one off)
   -1  if [si] == DL + 2      (two off; or no match: CF/ZF reflect DL+2 vs [si])

Probably a "is target adjacent within 3 tiles" check.  Rename: `match_dl_within_3`.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

GAME_FUNC_82 = 0x814E


def probe(h, si_byte, dl):
    h.write_byte(0x1000, si_byte)
    snap = h.snapshot()
    r = h.call_function(GAME_FUNC_82, regs={'si': 0x1000, 'dx': dl},
                        max_steps=50)
    dh = (r['regs_after']['dx'] >> 8) & 0xFF
    h.restore(snap)
    return dh


def main() -> int:
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)
    print(f'game_func_82 @ CPU 0x{GAME_FUNC_82:04X}')

    cases = [
        ('A', 0x10, 0x10, 1,    'exact match: DH=1'),
        ('B', 0x11, 0x10, 0,    'DL+1 match: DH=0'),
        ('C', 0x12, 0x10, 0xFF, 'DL+2 match: DH=-1'),
        ('D', 0x99, 0x10, 0xFF, 'no match: DH=-1 (cmp final)'),
    ]
    ok = True
    for label, sib, dl, expect, desc in cases:
        dh = probe(h, sib, dl)
        match = dh == expect
        ok = ok and match
        print(f'{label}: [si]=0x{sib:02X}, DL=0x{dl:02X} ({desc})  '
              f'DH=0x{dh:02X}  expected 0x{expect:02X}  '
              f'{"OK" if match else "FAIL"}')

    if ok:
        print('\nVERDICT: PASS: game_func_82 matches [si] against {DL, DL+1, '
              'DL+2}; DH = (1, 0, -1) for the 3 hit cases or -1 if no match. '
              "Rename: `match_dl_within_3`.")
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
