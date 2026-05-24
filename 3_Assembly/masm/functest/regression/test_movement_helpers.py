#!/usr/bin/env python3
"""
Phase-4 batch 4c regression: lock in the 4 direction-movement helpers
that the entity_move_* family tail-jumps to.  These ARE the actual
computational primitives (column-with-wrap, row-with-mask).

  inc_map_pos  (CPU 0x9286): [si]++; [si+3]++; with map_width wrap; CLC
  dec_map_pos  (CPU 0x929A): [si]--; [si+3]--; with 0->map_width wrap; CLC
  inc_row      (CPU 0x92AB): [si+2]++; [si+2] &= 0x3F; retn
  dec_row      (CPU 0x92B3): [si+2]--; [si+2] &= 0x3F; retn
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers, check_regression, resolve_proc  # noqa: E402

MAP_WIDTH = 0xC002


def main() -> int:
    flat, base = BIN_PATHS['fight']
    inc_map_pos = base + resolve_proc('fight', 'inc_map_pos_helper')
    dec_map_pos_helper = base + resolve_proc('fight', 'dec_map_pos_helper')
    dec_map_pos = dec_map_pos_helper
    inc_row = dec_map_pos_helper + 0x11
    dec_row = dec_map_pos_helper + 0x19
    h = TasmHarness(flat, base)
    stub_video_drivers(h)
    h.write_word(MAP_WIDTH, 100)

    SI = 0x1000
    failures = []

    # inc_map_pos: in-bounds increment (no wrap)
    h.write_word(SI, 50); h.write_byte(SI + 3, 5)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, inc_map_pos, regs={'si': SI},
        expected_diffs=[(SI, 50, 51), (SI + 3, 5, 6)],
        expected_flags={'CF': False},
        label='inc_map_pos:in_bounds')
    print(msg);  failures += [] if ok else ['inc_map_pos:in_bounds']
    h.restore(snap)

    # inc_map_pos: at boundary -> wrap (map_width is 100, so 99->100 then -=100 = 0)
    h.write_word(SI, 99); h.write_byte(SI + 3, 5)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, inc_map_pos, regs={'si': SI},
        expected_diffs=[(SI, 99, 0), (SI + 3, 5, 6)],
        expected_flags={'CF': False},
        label='inc_map_pos:wrap')
    print(msg);  failures += [] if ok else ['inc_map_pos:wrap']
    h.restore(snap)

    # dec_map_pos: in-bounds decrement
    h.write_word(SI, 50); h.write_byte(SI + 3, 5)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, dec_map_pos, regs={'si': SI},
        expected_diffs=[(SI, 50, 49), (SI + 3, 5, 4)],
        expected_flags={'CF': False},
        label='dec_map_pos:in_bounds')
    print(msg);  failures += [] if ok else ['dec_map_pos:in_bounds']
    h.restore(snap)

    # dec_map_pos: from 0 -> wraps to map_width-1 (= 99)
    h.write_word(SI, 0); h.write_byte(SI + 3, 5)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, dec_map_pos, regs={'si': SI},
        expected_diffs=[(SI, 0, 99), (SI + 3, 5, 4)],
        expected_flags={'CF': False},
        label='dec_map_pos:wrap')
    print(msg);  failures += [] if ok else ['dec_map_pos:wrap']
    h.restore(snap)

    # inc_row: simple
    h.write_byte(SI + 2, 10)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, inc_row, regs={'si': SI},
        expected_diffs=[(SI + 2, 10, 11)],
        label='inc_row:simple')
    print(msg);  failures += [] if ok else ['inc_row:simple']
    h.restore(snap)

    # inc_row: 0x3F wraps to 0 (mask 0x3F)
    h.write_byte(SI + 2, 0x3F)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, inc_row, regs={'si': SI},
        expected_diffs=[(SI + 2, 0x3F, 0)],
        label='inc_row:wrap_3F')
    print(msg);  failures += [] if ok else ['inc_row:wrap_3F']
    h.restore(snap)

    # dec_row: simple
    h.write_byte(SI + 2, 10)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, dec_row, regs={'si': SI},
        expected_diffs=[(SI + 2, 10, 9)],
        label='dec_row:simple')
    print(msg);  failures += [] if ok else ['dec_row:simple']
    h.restore(snap)

    # dec_row: 0 -> 0x3F (mask wraps -1)
    h.write_byte(SI + 2, 0)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, dec_row, regs={'si': SI},
        expected_diffs=[(SI + 2, 0, 0x3F)],
        label='dec_row:wrap_0')
    print(msg);  failures += [] if ok else ['dec_row:wrap_0']
    h.restore(snap)

    if failures:
        print(f'\nVERDICT: FAIL: {failures}')
        return 1
    print('\nVERDICT: PASS: all 8 movement-helper scenarios green.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
