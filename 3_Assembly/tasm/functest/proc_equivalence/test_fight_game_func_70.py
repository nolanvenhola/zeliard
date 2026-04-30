#!/usr/bin/env python3
"""
test_fight_game_func_70.py — game_func_70 at CPU 0x7DC3, 32 bytes, 2 callers.

Computes scroll-position state from scroll_count, scroll_dir, player_y:
  ax = scroll_count + 0xFFF0 (= scroll_count - 16)
  if ax goes negative (sign bit), ax += map_width
  [80h] (map_scroll_col) = ax
  [82h] (map_scroll_row) = (scroll_dir + 1 - player_y) & 0x3F

Rename: `compute_scroll_pos`.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

GAME_FUNC_70 = 0x7DC3


def probe(h, scroll_count, scroll_dir, player_y, map_w):
    h.write_word(0x9F1A, scroll_count)
    h.write_byte(0x9F1C, scroll_dir)
    h.write_byte(0xC016, player_y)
    h.write_word(0xC002, map_w)
    snap = h.snapshot()
    r = h.call_function(GAME_FUNC_70, max_steps=100)
    col = h.read_word(0x80)
    row = h.read_byte(0x82)
    h.restore(snap)
    return col, row


def main() -> int:
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)
    print(f'game_func_70 @ CPU 0x{GAME_FUNC_70:04X}')

    # Probe A: scroll_count > 16, no underflow
    col, row = probe(h, scroll_count=100, scroll_dir=10, player_y=5, map_w=200)
    expect_col = (100 + 0xFFF0) & 0xFFFF
    # If expect_col has high bit set (signed negative), add map_width
    if expect_col & 0x8000:
        expect_col = (expect_col + 200) & 0xFFFF
    expect_row = (10 + 1 - 5) & 0x3F
    a_ok = (col == expect_col and row == expect_row)
    print(f'\nProbe A: count=100, dir=10, py=5, mw=200')
    print(f'  [80] col=0x{col:04X}  expected 0x{expect_col:04X}  '
          f'{"OK" if col==expect_col else "FAIL"}')
    print(f'  [82] row=0x{row:02X}  expected 0x{expect_row:02X}  '
          f'{"OK" if row==expect_row else "FAIL"}')

    # Probe B: scroll_count < 16, underflow path -> wrap with map_width
    col, row = probe(h, scroll_count=5, scroll_dir=20, player_y=10, map_w=200)
    expect_col = (5 + 0xFFF0) & 0xFFFF
    if expect_col & 0x8000:
        expect_col = (expect_col + 200) & 0xFFFF
    expect_row = (20 + 1 - 10) & 0x3F
    b_ok = (col == expect_col and row == expect_row)
    print(f'\nProbe B: count=5 (underflow), dir=20, py=10, mw=200')
    print(f'  [80] col=0x{col:04X}  expected 0x{expect_col:04X}  '
          f'{"OK" if col==expect_col else "FAIL"}')
    print(f'  [82] row=0x{row:02X}  expected 0x{expect_row:02X}  '
          f'{"OK" if row==expect_row else "FAIL"}')

    if a_ok and b_ok:
        print('\nVERDICT: PASS: game_func_70 computes scroll position from '
              'scroll_count - 16 (with map-width wrap) and (scroll_dir+1-'
              'player_y) & 0x3F.  Stores into map_scroll_col [80h] and '
              "map_scroll_row [82h].  Rename: `compute_scroll_pos`.")
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
