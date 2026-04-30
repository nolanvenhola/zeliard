#!/usr/bin/env python3
"""
Phase-4 batch 4d regression: lock in the enemy_data_buf tick iterators.

  tick_decrement_enemy_counters  (CPU 0x8640): scan EB80, dec [si] if !=0
  tick_increment_enemy_counters  (CPU 0x8655): scan EB80, inc [si] if !=0

Each entry is 0x0D bytes; loop terminates when first byte == 0xFF.
Bytes already at 0 are skipped (or al,al; jz next).
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers, check_regression  # noqa: E402

TICK_DEC = 0x8640
TICK_INC = 0x8655
ENEMY_DATA_BUF = 0xEB80
ENTRY_STRIDE = 0x0D


def setup_buf(h, first_bytes):
    """Seed enemy_data_buf with `first_bytes` for entry-0 first-byte
    of each successive entry, terminated by 0xFF."""
    for i, b in enumerate(first_bytes):
        h.write_byte(ENEMY_DATA_BUF + i * ENTRY_STRIDE, b)
    # Terminator
    h.write_byte(ENEMY_DATA_BUF + len(first_bytes) * ENTRY_STRIDE, 0xFF)


def main() -> int:
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)

    failures = []

    # tick_dec: 3 active entries
    setup_buf(h, [10, 5, 20])
    snap = h.snapshot()
    ok, msg = check_regression(
        h, TICK_DEC,
        expected_diffs=[
            (ENEMY_DATA_BUF + 0 * ENTRY_STRIDE, 10, 9),
            (ENEMY_DATA_BUF + 1 * ENTRY_STRIDE, 5,  4),
            (ENEMY_DATA_BUF + 2 * ENTRY_STRIDE, 20, 19),
        ],
        max_steps=300,
        label='tick_dec:3_active')
    print(msg);  failures += [] if ok else ['tick_dec:3_active']
    h.restore(snap)

    # tick_dec: zeros skipped
    setup_buf(h, [0, 5, 0, 7])
    snap = h.snapshot()
    ok, msg = check_regression(
        h, TICK_DEC,
        expected_diffs=[
            (ENEMY_DATA_BUF + 1 * ENTRY_STRIDE, 5, 4),
            (ENEMY_DATA_BUF + 3 * ENTRY_STRIDE, 7, 6),
        ],
        max_steps=300,
        label='tick_dec:zeros_skipped')
    print(msg);  failures += [] if ok else ['tick_dec:zeros_skipped']
    h.restore(snap)

    # tick_dec: empty buffer (immediate FF)
    h.write_byte(ENEMY_DATA_BUF, 0xFF)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, TICK_DEC,
        expected_diffs=[],
        max_steps=50,
        label='tick_dec:empty')
    print(msg);  failures += [] if ok else ['tick_dec:empty']
    h.restore(snap)

    # tick_inc: 3 active entries
    setup_buf(h, [10, 5, 20])
    snap = h.snapshot()
    ok, msg = check_regression(
        h, TICK_INC,
        expected_diffs=[
            (ENEMY_DATA_BUF + 0 * ENTRY_STRIDE, 10, 11),
            (ENEMY_DATA_BUF + 1 * ENTRY_STRIDE, 5,  6),
            (ENEMY_DATA_BUF + 2 * ENTRY_STRIDE, 20, 21),
        ],
        max_steps=300,
        label='tick_inc:3_active')
    print(msg);  failures += [] if ok else ['tick_inc:3_active']
    h.restore(snap)

    # tick_inc: zeros skipped (zero stays zero — `or al,al; jz next`
    # skips the inc, but mov al,[si] reads first; result: zero-byte
    # entries unchanged)
    setup_buf(h, [0, 5, 0])
    snap = h.snapshot()
    ok, msg = check_regression(
        h, TICK_INC,
        expected_diffs=[(ENEMY_DATA_BUF + 1 * ENTRY_STRIDE, 5, 6)],
        max_steps=300,
        label='tick_inc:zeros_skipped')
    print(msg);  failures += [] if ok else ['tick_inc:zeros_skipped']
    h.restore(snap)

    if failures:
        print(f'\nVERDICT: FAIL: {failures}')
        return 1
    print('\nVERDICT: PASS: all 5 enemy-tick scenarios green.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
