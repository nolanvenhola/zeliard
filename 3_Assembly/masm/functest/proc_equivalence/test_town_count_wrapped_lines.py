#!/usr/bin/env python3
"""MASM oracle for 106TOWN count_wrapped_lines."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
TEXT_FIXTURE = 0x1200
COUNT_WRAPPED_LINES = 0x660D
CHAR_GLYPH_TBL = 0x7BE2

GLYPH_WIDTHS = bytes([
    0, 3, 1, 0, 5, 4, 4, 4, 6, 8, 5, 3, 4, 4, 6, 6,
    6, 5, 6, 8, 7, 5, 7, 7, 7, 7, 7, 7, 7, 7, 3, 4,
    6, 6, 6, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5, 8, 8,
    8, 8, 8, 8, 8, 8, 8, 8, 7, 8, 8, 8, 8, 8, 7, 5,
    3, 5, 6, 7, 7, 8, 8, 7, 8, 7, 7, 8, 8, 5, 6, 8,
    5, 8, 7, 7, 8, 8, 8, 7, 6, 8, 8, 8, 7, 7, 7, 4,
])


def run_case(h: TasmHarness, name: str, raw: bytes,
             expected_lines: int, expected_consumed: int) -> list[str]:
    h.write_data(CHAR_GLYPH_TBL, GLYPH_WIDTHS)
    h.write_data(TEXT_FIXTURE, raw)
    result = h.call_function(COUNT_WRAPPED_LINES, regs={"si": TEXT_FIXTURE},
                             max_steps=1000)
    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")
    got_lines = result["regs_after"]["cx"]
    got_consumed = (result["regs_after"]["si"] - TEXT_FIXTURE) & 0xFFFF
    if got_lines != expected_lines:
        failures.append(f"{name}: lines {got_lines:#06x} != {expected_lines:#06x}")
    if got_consumed != expected_consumed:
        failures.append(
            f"{name}: consumed {got_consumed:#06x} != {expected_consumed:#06x}")
    return failures


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    h = TasmHarness(flat_path, load_base)
    failures: list[str] = []
    failures += run_case(h, "single_line", b"ABC\x80", 1, 4)
    failures += run_case(h, "slash_break", b"ABC/DE\x80", 2, 7)
    failures += run_case(h, "space_no_wrap", (b"A" * 26) + b" B\x80", 1, 29)
    failures += run_case(h, "space_wrap_equal_168", (b"A" * 27) + b" B\x80", 2, 30)
    failures += run_case(h, "empty_highbit", bytes([0x80]), 0, 1)

    if failures:
        print("town count-wrapped-lines oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town count-wrapped-lines oracle: slash breaks, space wrap, and high-bit end match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
