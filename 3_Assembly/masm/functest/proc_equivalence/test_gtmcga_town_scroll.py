#!/usr/bin/env python3
"""MASM release-byte oracle for GTMCGA horizontal town scrolling."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from harness import TasmHarness  # noqa: E402


MASM_ROOT = HERE.parent.parent
DRIVER = MASM_ROOT / "bin" / "zelres1" / "111GTMCA.bin"
SCROLL_LEFT = 0x3628
SCROLL_RIGHT = 0x36A4


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
    right_reason, right_hash = run_scroll(SCROLL_RIGHT)
    expected_left = 0x3FC2021C15FF0B25
    expected_right = 0x402C490240B31725
    ok = left_reason == right_reason == "returned_to_sentinel"
    ok &= left_hash == expected_left and right_hash == expected_right
    print(f"GTMCGA scroll: left={left_hash:016x} right={right_hash:016x}")
    print(f"VERDICT: {'PASS' if ok else 'FAIL'}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
