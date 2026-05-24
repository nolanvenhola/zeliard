#!/usr/bin/env python3
"""MASM oracle for 106TOWN measure_word_width."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
TEXT_FIXTURE = 0x1200
MEASURE_WORD_WIDTH = 0x65EA


def run_case(h: TasmHarness, proc: int, name: str, raw: bytes,
             expected_width: int, expected_consumed: int) -> list[str]:
    h.write_data(TEXT_FIXTURE, raw)
    result = h.call_function(proc, regs={"si": TEXT_FIXTURE}, max_steps=200)
    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")
    got_width = result["regs_after"]["cx"]
    got_consumed = (result["regs_after"]["si"] - TEXT_FIXTURE) & 0xFFFF
    if got_width != expected_width:
        failures.append(f"{name}: width {got_width:#06x} != {expected_width:#06x}")
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
    proc = MEASURE_WORD_WIDTH

    failures: list[str] = []
    failures += run_case(h, proc, "abc_space", b"ABC rest\x80", 19, 4)
    failures += run_case(h, proc, "hi_slash", b"Hi/there\x80", 15, 3)
    failures += run_case(h, proc, "control_then_a", bytes([0x1F]) + b"A \x80", 6, 3)
    failures += run_case(h, proc, "highbit_immediate", bytes([0x80, ord("A")]), 0, 1)

    if failures:
        print("town measure-word-width oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town measure-word-width oracle: stop chars, control skip, and glyph sums match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
