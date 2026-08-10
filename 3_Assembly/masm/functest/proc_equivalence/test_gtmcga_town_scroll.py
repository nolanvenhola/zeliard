#!/usr/bin/env python3
"""MASM release-byte oracle for all four GTMCGA town scroll services."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from harness import TasmHarness  # noqa: E402


MASM_ROOT = HERE.parent.parent
DRIVER = MASM_ROOT / "bin" / "zelres1" / "111GTMCA.bin"
SCROLL_LEFT = 0x3628
SCROLL_UP = 0x3677
SCROLL_RIGHT = 0x36A4
SCROLL_DOWN = 0x36F1


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def run_scroll(address: int) -> tuple[str, int]:
    harness = TasmHarness(DRIVER, 0x2FFC)
    source = bytes((index * 37 + 11) & 0xFF for index in range(0x10000))
    harness.write_vga(0, source)
    result = harness.call_function(address, max_steps=10000)
    return result["stopped_reason"], fnv1a64(harness.read_vga(0, 0x10000))


def main() -> int:
    if not DRIVER.exists():
        print("VERDICT: INCONCLUSIVE: 111GTMCA.bin missing")
        return 1
    left_reason, left_hash = run_scroll(SCROLL_LEFT)
    up_reason, up_hash = run_scroll(SCROLL_UP)
    right_reason, right_hash = run_scroll(SCROLL_RIGHT)
    down_reason, down_hash = run_scroll(SCROLL_DOWN)
    expected_left = 0x3FC2021C15FF0B25
    expected_up = 0x0E277A925CBE2525
    expected_right = 0x402C490240B31725
    expected_down = 0x67D9469BE4272325
    ok = left_reason == up_reason == right_reason == down_reason == "returned_to_sentinel"
    ok &= (left_hash == expected_left and up_hash == expected_up and
           right_hash == expected_right and down_hash == expected_down)
    print(f"GTMCGA scroll: left={left_hash:016x} up={up_hash:016x} "
          f"right={right_hash:016x} down={down_hash:016x}")
    print(f"VERDICT: {'PASS' if ok else 'FAIL'}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
