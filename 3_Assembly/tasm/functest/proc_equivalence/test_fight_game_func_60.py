#!/usr/bin/env python3
"""
test_fight_game_func_60.py — game_func_60 at CPU 0x768A.

Body subtracts AX from word [90h] (hero_HP), clamps to 0 on underflow,
then far-calls CS:[2008h] (HUD HP-bar redraw).  Same shape as the
HP-damage probe in test_player_stats_word_layout.py.  4 callers.
Rename: `hero_HP_subtract`.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

GAME_FUNC_60 = 0x768A


def probe(h, hp, dmg):
    h.write_word(0x90, hp)
    snap = h.snapshot()
    r = h.call_function(GAME_FUNC_60, regs={'ax': dmg}, max_steps=200)
    after = h.read_word(0x90)
    h.restore(snap)
    return after


def main() -> int:
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)
    print(f'game_func_60 @ CPU 0x{GAME_FUNC_60:04X}')

    cases = [(50, 20, 30, 'normal'),
             (10, 50, 0,  'underflow clamps to 0'),
             (0xFFFF, 1, 0xFFFE, 'no underflow')]
    ok = True
    for hp, dmg, expect, desc in cases:
        got = probe(h, hp, dmg)
        match = got == expect
        ok = ok and match
        print(f'  hp={hp}, dmg={dmg} ({desc}) -> hp_after=0x{got:04X} '
              f'expected 0x{expect:04X}  {"OK" if match else "FAIL"}')

    if ok:
        print('\nVERDICT: PASS: game_func_60 is `hero_HP_subtract` — '
              'subtract AX from hero_HP word, clamp to 0 on underflow, '
              'trigger HP-bar HUD redraw via CS:[2008h].')
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
