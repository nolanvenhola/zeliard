#!/usr/bin/env python3
"""MASM oracle for 106TOWN clear_n_dialog_rows gfx call plan."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
OFF_GVAR_DLG_POS = 0xFF54
OFF_GFX_CLEAR_ROW_FN = 0x2038

CLEAR_N_DIALOG_ROWS = 0x751E
CLEAR_ROW_THUNK = 0x0200


def write_word_code(h: TasmHarness, offset: int, value: int) -> None:
    h.write_code(offset, [value & 0xFF, (value >> 8) & 0xFF])


def check_case(name: str, row_count: int, dialog_pos: int,
               initial_dx: int, expected_bx: list[int]) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    write_word_code(h, OFF_GFX_CLEAR_ROW_FN, CLEAR_ROW_THUNK)
    h.write_word(OFF_GVAR_DLG_POS, dialog_pos)

    result = h.call_function(
        CLEAR_N_DIALOG_ROWS,
        regs={"cx": row_count, "dx": initial_dx, "si": 0x7513},
        stub_calls={CLEAR_ROW_THUNK: {}},
        max_steps=500,
    )

    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")

    got_calls = [regs for regs in result["stub_regs"]
                 if regs["ip"] == CLEAR_ROW_THUNK]
    if len(got_calls) != len(expected_bx):
        failures.append(
            f"{name}: clear calls {len(got_calls)} != {len(expected_bx)}")

    for idx, regs in enumerate(got_calls):
        if idx >= len(expected_bx):
            break
        if regs["bx"] != expected_bx[idx]:
            failures.append(
                f"{name}: call {idx} BX {regs['bx']:#06x} != {expected_bx[idx]:#06x}")
        if regs["cx"] != 0:
            failures.append(f"{name}: call {idx} CX {regs['cx']:#06x} != 0")
        if regs["ax"] != expected_bx[idx]:
            failures.append(
                f"{name}: call {idx} AX {regs['ax']:#06x} != {expected_bx[idx]:#06x}")
        if (regs["dx"] & 0xFF) != idx:
            failures.append(
                f"{name}: call {idx} DL {regs['dx'] & 0xFF:#04x} != {idx:#04x}")

    expected_final_dx = (initial_dx & 0xFF00) | (row_count & 0xFF)
    if result["regs_after"]["dx"] != expected_final_dx:
        failures.append(
            f"{name}: final DX {result['regs_after']['dx']:#06x} != {expected_final_dx:#06x}")
    if result["regs_after"]["cx"] != 0:
        failures.append(f"{name}: final CX {result['regs_after']['cx']:#06x} != 0")
    if result["regs_after"]["si"] != 0x7513:
        failures.append(f"{name}: SI was not preserved")

    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += check_case(
        "three_rows", row_count=3, dialog_pos=0x2000, initial_dx=0xAA55,
        expected_bx=[0x2301, 0x230B, 0x2315])
    failures += check_case(
        "one_row", row_count=1, dialog_pos=0x3450, initial_dx=0x1200,
        expected_bx=[0x3751])

    if failures:
        print("town clear-n-dialog-rows oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town clear-n-dialog-rows oracle: gfx clear-row call sequence matches")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
