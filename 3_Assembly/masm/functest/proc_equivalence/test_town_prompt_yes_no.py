#!/usr/bin/env python3
"""MASM oracle for 106TOWN prompt_yes_no wrapper behavior."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
OFF_GVAR_DLG_COLS = 0xFF52
OFF_GVAR_DLG_ROWS = 0xFF53
OFF_GVAR_SEL_ROW = 0xFF56

YES_NO_STRING = 0x7513
PROMPT_YES_NO = 0x74D7
CLEAR_N_DIALOG_ROWS = 0x751E
POLL_MENU_INPUT = 0x7348


def run_case(name: str, poll_cf: bool, expected_yes: bool) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)

    h.write_byte(OFF_GVAR_DLG_COLS, 5)
    h.write_byte(OFF_GVAR_DLG_ROWS, 8)
    h.write_byte(OFF_GVAR_SEL_ROW, 3)

    result = h.call_function(
        PROMPT_YES_NO,
        regs={"bx": 0x7702},
        stub_calls={
            CLEAR_N_DIALOG_ROWS: {},
            POLL_MENU_INPUT: {"cf": 1 if poll_cf else 0},
        },
        max_steps=300,
    )

    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")

    if result["stubs_fired"] != [CLEAR_N_DIALOG_ROWS, POLL_MENU_INPUT]:
        failures.append(f"{name}: stubs {result['stubs_fired']} not clear->poll")

    clear_regs = [regs for regs in result["stub_regs"]
                  if regs["ip"] == CLEAR_N_DIALOG_ROWS]
    if len(clear_regs) != 1:
        failures.append(f"{name}: clear calls {len(clear_regs)} != 1")
    else:
        if clear_regs[0]["cx"] != 2:
            failures.append(f"{name}: clear CX {clear_regs[0]['cx']:#06x} != 0x0002")
        if clear_regs[0]["si"] != YES_NO_STRING:
            failures.append(
                f"{name}: clear SI {clear_regs[0]['si']:#06x} != {YES_NO_STRING:#06x}")
        if h.read_byte(OFF_GVAR_DLG_COLS) != 5:
            failures.append(f"{name}: dialog cols not restored")
        if h.read_byte(OFF_GVAR_DLG_ROWS) != 8:
            failures.append(f"{name}: dialog rows not restored")

    poll_regs = [regs for regs in result["stub_regs"]
                 if regs["ip"] == POLL_MENU_INPUT]
    if len(poll_regs) != 1:
        failures.append(f"{name}: poll calls {len(poll_regs)} != 1")
    else:
        if (poll_regs[0]["bx"] & 0xFF) != 0:
            failures.append(
                f"{name}: poll BL {poll_regs[0]['bx'] & 0xFF:#04x} != 0")

    if h.read_byte(OFF_GVAR_SEL_ROW) != 3:
        failures.append(f"{name}: selection row not restored")
    if result["flags_after"]["CF"] is not expected_yes:
        failures.append(f"{name}: CF {result['flags_after']['CF']} != {expected_yes}")
    if ((result["regs_after"]["bx"] & 0xFF) != (1 if expected_yes else 0)):
        failures.append(
            f"{name}: final BL {result['regs_after']['bx'] & 0xFF:#04x} != {1 if expected_yes else 0:#04x}")
    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += run_case("yes_path", poll_cf=True, expected_yes=True)
    failures += run_case("no_path", poll_cf=False, expected_yes=False)

    if failures:
        print("town prompt-yes-no oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town prompt-yes-no oracle: temporary 2x2 menu state, restore, and carry result match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
