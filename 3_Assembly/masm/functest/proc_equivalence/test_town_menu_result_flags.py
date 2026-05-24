#!/usr/bin/env python3
"""MASM oracle for 106TOWN menu skip/accept result flags."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
OFF_GVAR_SPACEBAR_STATE = 0xFF1D
OFF_GVAR_SKIP_FLAG2 = 0xFF1E
OFF_GVAR_VOLUME = 0xFF75

MENU_POST_FRAME_RESULT = 0x7361


def run_case(name: str, skip_flag: int, spacebar_state: int,
             initial_volume: int, expected_cf: bool,
             expected_volume: int) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    h.write_byte(OFF_GVAR_SKIP_FLAG2, skip_flag)
    h.write_byte(OFF_GVAR_SPACEBAR_STATE, spacebar_state)
    h.write_byte(OFF_GVAR_VOLUME, initial_volume)

    result = h.call_function(MENU_POST_FRAME_RESULT, max_steps=50)

    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")

    got_cf = result["flags_after"]["CF"]
    got_volume = h.read_byte(OFF_GVAR_VOLUME)
    if got_cf is not expected_cf:
        failures.append(f"{name}: CF {got_cf} != {expected_cf}")
    if got_volume != expected_volume:
        failures.append(
            f"{name}: volume {got_volume:#04x} != {expected_volume:#04x}")
    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += run_case(
        "skip_flag_returns_carry", skip_flag=1, spacebar_state=0,
        initial_volume=0x55, expected_cf=True, expected_volume=0x55)
    failures += run_case(
        "spacebar_accepts", skip_flag=0, spacebar_state=1,
        initial_volume=0x55, expected_cf=False, expected_volume=0x1F)

    if failures:
        print("town menu-result flag oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town menu-result flag oracle: skip carry and spacebar accept match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
