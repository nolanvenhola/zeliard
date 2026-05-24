#!/usr/bin/env python3
"""
Regression oracle for `compute_scroll_offset_b`.

The helper has three observable exits:
  - near-end path: AX = scroll_count - 17, BX = 0x000D
  - start-wrap path: AX = 0, BL = scroll_count - 4
  - far-end path: AX = map_width - 36, BL = scroll_count - map_width + 32

The far-end path intentionally depends on the carry produced by
`add ax,0FFDCh` before `sbb cx,ax`, so this test locks the resulting
registers rather than re-deriving them from comments.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, check_regression, resolve_proc, stub_video_drivers  # noqa: E402

SCROLL_COUNT = 0x9F1A
MAP_WIDTH = 0xC002


def run_case(h, proc, label, scroll_count, map_width, ax, bx):
    h.write_word(SCROLL_COUNT, scroll_count)
    h.write_word(MAP_WIDTH, map_width)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, proc,
        expected_regs={'ax': ax, 'bx': bx},
        max_steps=100,
        label=label,
    )
    print(msg)
    h.restore(snap)
    return ok


def main() -> int:
    flat, base = BIN_PATHS['fight']
    proc = base + resolve_proc('fight', 'compute_scroll_offset_b')
    h = TasmHarness(flat, base)
    stub_video_drivers(h)

    cases = [
        ('scroll_offset_b:near', 100, 200, 0x0053, 0x000D),
        ('scroll_offset_b:start_wrap', 5, 200, 0x0000, 0x0001),
        ('scroll_offset_b:near_edge', 187, 200, 0x00AA, 0x000D),
        ('scroll_offset_b:far_end', 195, 200, 0x00A4, 0x001B),
        ('scroll_offset_b:far_edge', 188, 200, 0x00A4, 0x0014),
    ]

    failures = []
    for label, scroll_count, map_width, ax, bx in cases:
        if not run_case(h, proc, label, scroll_count, map_width, ax, bx):
            failures.append(label)

    if failures:
        print(f'\nVERDICT: FAIL: {failures}')
        return 1
    print('\nVERDICT: PASS: compute_scroll_offset_b register oracle green.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
