#!/usr/bin/env python3
"""MASM oracle for 106TOWN draw_menu_items_column."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
OFF_GVAR_DLG_POS = 0xFF54
OFF_GFX_SEL_INIT_FN = 0x301A
OFF_GFX_SEL_DRAW_FN = 0x301C

SEL_INIT_THUNK = 0x0200
SEL_DRAW_THUNK = 0x0210
DRAW_MENU_ITEMS_COLUMN = 0x780B


def write_word_code(h: TasmHarness, offset: int, value: int) -> None:
    h.write_code(offset, [value & 0xFF, (value >> 8) & 0xFF])


def check_case(name: str, start_al: int, count: int,
               dialog_pos: int) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    write_word_code(h, OFF_GFX_SEL_INIT_FN, SEL_INIT_THUNK)
    write_word_code(h, OFF_GFX_SEL_DRAW_FN, SEL_DRAW_THUNK)
    h.write_word(OFF_GVAR_DLG_POS, dialog_pos)

    result = h.call_function(
        DRAW_MENU_ITEMS_COLUMN,
        regs={"ax": (0x9900 | start_al), "cx": count,
              "si": 0x1234, "di": 0x5678},
        stub_calls={SEL_INIT_THUNK: {}, SEL_DRAW_THUNK: {}},
        max_steps=1000,
    )

    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")

    init_regs = [regs for regs in result["stub_regs"]
                 if regs["ip"] == SEL_INIT_THUNK]
    draw_regs = [regs for regs in result["stub_regs"]
                 if regs["ip"] == SEL_DRAW_THUNK]
    if len(init_regs) != count:
        failures.append(f"{name}: init calls {len(init_regs)} != {count}")
    if len(draw_regs) != count:
        failures.append(f"{name}: draw calls {len(draw_regs)} != {count}")

    for idx, regs in enumerate(init_regs[:count]):
        expected_al = (start_al + idx) & 0xFF
        if (regs["ax"] & 0xFF) != expected_al:
            failures.append(
                f"{name}: init {idx} AL {regs['ax'] & 0xFF:#04x} != {expected_al:#04x}")

    for idx, regs in enumerate(draw_regs[:count]):
        expected_bx = (dialog_pos + 0x0300 + (idx * 10)) & 0xFFFF
        expected_cx = count - idx
        if regs["bx"] != expected_bx:
            failures.append(
                f"{name}: draw {idx} BX {regs['bx']:#06x} != {expected_bx:#06x}")
        if regs["cx"] != expected_cx:
            failures.append(
                f"{name}: draw {idx} CX {regs['cx']:#06x} != {expected_cx:#06x}")

    expected_ax = (((count & 0xFF) << 8) | ((start_al + count) & 0xFF))
    if result["regs_after"]["ax"] != expected_ax:
        failures.append(
            f"{name}: final AX {result['regs_after']['ax']:#06x} != {expected_ax:#06x}")
    if result["regs_after"]["cx"] != 0:
        failures.append(f"{name}: final CX {result['regs_after']['cx']:#06x} != 0")
    if result["regs_after"]["si"] != 0x1234:
        failures.append(f"{name}: SI was not preserved")
    if result["regs_after"]["di"] != 0x5678:
        failures.append(f"{name}: DI was not preserved")

    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += check_case("three_items", start_al=2, count=3,
                           dialog_pos=0x2000)
    failures += check_case("one_item", start_al=5, count=1,
                           dialog_pos=0x3450)

    if failures:
        print("town draw-menu-items-column oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town draw-menu-items-column oracle: direct item init/draw sequence matches")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
