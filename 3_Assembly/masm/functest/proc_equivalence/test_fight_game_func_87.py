#!/usr/bin/env python3
"""
test_fight_game_func_87.py

Probe of 200FIGHT.bin's `game_func_87` at CPU 0x82FA — 39 bytes, 5 callers.
Sibling of `world_x_to_screen_x` (was game_func_141) — same world->screen
transform but uses 0x21 (33) as the screen-width constant instead of 0x23 (35).

Two-tile narrower → likely the inner play-region transform vs the
outer/cavern region.  All three internal labels (`screen_left_check`,
`screen_wrap_right`) confirm the world→screen role.

Verdict: PASS-RENAME → `world_x_to_inner_screen_x` (or `_w21`).
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

CHUNK = 'fight'


def probe(h, proc, input_ax, scroll_col, map_w):
    h.write_word(0x80, scroll_col)
    h.write_word(0xC002, map_w)
    snap = h.snapshot()
    result = h.call_function(proc,
                              regs={'ax': input_ax & 0xFFFF}, max_steps=50)
    ax_out = result['regs_after']['ax']
    h.restore(snap)
    return ax_out


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    proc = load_base + resolve_proc('fight', 'convert_world_x_to_inner_screen_x',
                                    fallback_names=('game_func_87',))
    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    print(f'convert_world_x_to_inner_screen_x @ CPU 0x{proc:04X}')

    # Same shape as game_func_141 but constant is 0x21
    expect_a = 0x21 - (20 - 10)
    got_a = probe(h, proc, 20, 10, 40)
    a_ok = got_a == expect_a
    print(f'\nProbe A: input=20, scroll=10  '
          f'ax_out=0x{got_a:04X}  expected 0x{expect_a:04X}  '
          f'{"OK" if a_ok else "FAIL"}')

    expect_b = (0x21 - (40 - 5 + 2)) & 0xFFFF
    got_b = probe(h, proc, 2, 5, 40)
    b_ok = got_b == expect_b
    print(f'Probe B: off-left wrap  '
          f'ax_out=0x{got_b:04X}  expected 0x{expect_b:04X}  '
          f'{"OK" if b_ok else "FAIL"}')

    expect_c = 0x21
    got_c = probe(h, proc, 10, 10, 40)
    c_ok = got_c == expect_c
    print(f'Probe C: boundary  '
          f'ax_out=0x{got_c:04X}  expected 0x{expect_c:04X}  '
          f'{"OK" if c_ok else "FAIL"}')

    if a_ok and b_ok and c_ok:
        print('\nVERDICT: PASS: game_func_87 is world_x_to_screen_x with '
              '0x21 (narrower 33-tile) screen region.  Same transform shape '
              "as game_func_141 (which uses 0x23).  Rename: "
              '`world_x_to_inner_screen_x`.')
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
