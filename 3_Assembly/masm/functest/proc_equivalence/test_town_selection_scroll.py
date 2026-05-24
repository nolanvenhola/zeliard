#!/usr/bin/env python3
"""MASM oracle for 106TOWN selection-window scroll branches."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
OFF_GVAR_FRAME_TIMER = 0xFF1A
OFF_GVAR_DLG_COLS = 0xFF52
OFF_GVAR_DLG_POS = 0xFF54
OFF_GVAR_SEL_ROW = 0xFF56
OFF_GVAR_SEL_XLAT = 0xFF58
OFF_GVAR_DLG_TIMER = 0xFF6A
OFF_GFX_SEL_INIT_FN = 0x301A
OFF_GFX_SEL_SCROLL_UP_FN = 0x301E
OFF_GFX_SEL_SCROLL_DN_FN = 0x3020

TICK_TOWN_FRAME = 0x7046
SEL_SCROLL_UP = 0x7398
SEL_SCROLL_DOWN = 0x7417
INIT_THUNK = 0x0200
SCROLL_UP_THUNK = 0x0210
SCROLL_DN_THUNK = 0x0220


def write_word_code(h: TasmHarness, offset: int, value: int) -> None:
    h.write_code(offset, [value & 0xFF, (value >> 8) & 0xFF])


def install_stubs(h: TasmHarness) -> None:
    write_word_code(h, OFF_GFX_SEL_INIT_FN, INIT_THUNK)
    write_word_code(h, OFF_GFX_SEL_SCROLL_UP_FN, SCROLL_UP_THUNK)
    write_word_code(h, OFF_GFX_SEL_SCROLL_DN_FN, SCROLL_DN_THUNK)
    h.write_code(TICK_TOWN_FRAME, [
        0xC6, 0x06,
        OFF_GVAR_FRAME_TIMER & 0xFF, OFF_GVAR_FRAME_TIMER >> 8,
        0x04,
        0xC3,
    ])


def seed_common(h: TasmHarness, dlg_pos: int, cols: int,
                timer: int, sel_row: int) -> None:
    h.write_data(OFF_GVAR_SEL_XLAT, bytes(range(0x80, 0xC0)))
    h.write_word(OFF_GVAR_DLG_POS, dlg_pos)
    h.write_byte(OFF_GVAR_DLG_COLS, cols)
    h.write_byte(OFF_GVAR_DLG_TIMER, timer)
    h.write_byte(OFF_GVAR_FRAME_TIMER, 0)
    h.write_byte(OFF_GVAR_SEL_ROW, sel_row)


def check_case(name: str, proc: int, scroll_thunk: int, initial_sel_row: int,
               visible_row: int, expected_sel_row: int,
               expected_al_sequence: list[int]) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    install_stubs(h)
    seed_common(h, dlg_pos=0x2000, cols=5, timer=7,
                sel_row=initial_sel_row)
    result = h.call_function(
        proc,
        regs={"bx": visible_row},
        stub_calls={INIT_THUNK: {}, scroll_thunk: {}},
        max_steps=1500,
    )

    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")

    got_sel_row = h.read_byte(OFF_GVAR_SEL_ROW)
    if got_sel_row != expected_sel_row:
        failures.append(
            f"{name}: sel_row {got_sel_row:#04x} != {expected_sel_row:#04x}")

    init_regs = [regs for regs in result["stub_regs"]
                 if regs["ip"] == INIT_THUNK]
    scroll_regs = [regs for regs in result["stub_regs"]
                   if regs["ip"] == scroll_thunk]
    if len(init_regs) != 1:
        failures.append(f"{name}: init calls {len(init_regs)} != 1")
    else:
        expected_init_al = 0x80 + expected_sel_row + visible_row
        got_init_al = init_regs[0]["ax"] & 0xFF
        if got_init_al != expected_init_al:
            failures.append(
                f"{name}: init AL {got_init_al:#04x} != {expected_init_al:#04x}")

    got_al = [regs["ax"] & 0xFF for regs in scroll_regs]
    if got_al != expected_al_sequence:
        failures.append(f"{name}: scroll AL sequence {got_al!r} != {expected_al_sequence!r}")

    expected_bx = 0x2000 + 0x0301
    expected_cx = (7 << 8) | ((5 * 10) - 2)
    for idx, regs in enumerate(scroll_regs):
        if regs["bx"] != expected_bx:
            failures.append(f"{name}: scroll {idx} BX {regs['bx']:#06x} != {expected_bx:#06x}")
        if regs["cx"] != expected_cx:
            failures.append(f"{name}: scroll {idx} CX {regs['cx']:#06x} != {expected_cx:#06x}")

    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += check_case(
        "scroll_up_top_visible", SEL_SCROLL_UP, SCROLL_UP_THUNK,
        initial_sel_row=2, visible_row=0, expected_sel_row=1,
        expected_al_sequence=list(range(9, -1, -1)))
    failures += check_case(
        "scroll_down_bottom_visible", SEL_SCROLL_DOWN, SCROLL_DN_THUNK,
        initial_sel_row=1, visible_row=4, expected_sel_row=2,
        expected_al_sequence=list(range(0, 10)))

    if failures:
        print("town selection-scroll oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town selection-scroll oracle: row update, init lookup, and 10-frame scroll params match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
