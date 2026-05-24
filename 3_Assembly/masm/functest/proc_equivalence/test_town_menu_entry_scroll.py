#!/usr/bin/env python3
"""MASM oracle for 106TOWN poll_menu_input entry through scroll branches."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
OFF_GVAR_FRAME_TIMER = 0xFF1A
OFF_GVAR_SPACEBAR_STATE = 0xFF1D
OFF_GVAR_SKIP_FLAG2 = 0xFF1E
OFF_GVAR_DLG_COLS = 0xFF52
OFF_GVAR_DLG_ROWS = 0xFF53
OFF_GVAR_DLG_POS = 0xFF54
OFF_GVAR_SEL_ROW = 0xFF56
OFF_GVAR_SEL_XLAT = 0xFF58
OFF_GVAR_DLG_TIMER = 0xFF6A
OFF_GFX_SEL_INIT_FN = 0x301A
OFF_GFX_SEL_SCROLL_UP_FN = 0x301E
OFF_GFX_SEL_SCROLL_DN_FN = 0x3020

POLL_MENU_INPUT = 0x7348
SEL_POLL_JOY = 0x7378
TICK_TOWN_FRAME = 0x7046
DRAW_CURSOR_AT_DLG_ROW = 0x746D
INIT_THUNK = 0x0200
SCROLL_UP_THUNK = 0x0210
SCROLL_DN_THUNK = 0x0220


def write_word_code(h: TasmHarness, offset: int, value: int) -> None:
    h.write_code(offset, [value & 0xFF, (value >> 8) & 0xFF])


def patch_tick_town_frame(h: TasmHarness) -> None:
    h.write_code(TICK_TOWN_FRAME, [
        0xC6, 0x06,
        OFF_GVAR_FRAME_TIMER & 0xFF, OFF_GVAR_FRAME_TIMER >> 8,
        0x04,
        0xC6, 0x06,
        OFF_GVAR_SKIP_FLAG2 & 0xFF, OFF_GVAR_SKIP_FLAG2 >> 8,
        0x00,
        0xC6, 0x06,
        OFF_GVAR_SPACEBAR_STATE & 0xFF, OFF_GVAR_SPACEBAR_STATE >> 8,
        0x00,
        0xC3,
    ])


def patch_joystick_direction(h: TasmHarness, direction: int) -> None:
    h.write_code(SEL_POLL_JOY, [
        0xB0, direction & 0xFF,  # mov al, direction
        0x90, 0x90, 0x90, 0x90,  # replace mov ax/push/int61 setup
    ])


def install_scroll_stubs(h: TasmHarness) -> None:
    write_word_code(h, OFF_GFX_SEL_INIT_FN, INIT_THUNK)
    write_word_code(h, OFF_GFX_SEL_SCROLL_UP_FN, SCROLL_UP_THUNK)
    write_word_code(h, OFF_GFX_SEL_SCROLL_DN_FN, SCROLL_DN_THUNK)


def seed_common(h: TasmHarness, visible_row: int, sel_row: int) -> None:
    h.write_data(OFF_GVAR_SEL_XLAT, bytes(range(0x80, 0xC0)))
    h.write_word(OFF_GVAR_DLG_POS, 0x2000)
    h.write_byte(OFF_GVAR_DLG_COLS, 5)
    h.write_byte(OFF_GVAR_DLG_ROWS, 8)
    h.write_byte(OFF_GVAR_DLG_TIMER, 7)
    h.write_byte(OFF_GVAR_FRAME_TIMER, 0x66)
    h.write_byte(OFF_GVAR_SKIP_FLAG2, 0xAA)
    h.write_byte(OFF_GVAR_SPACEBAR_STATE, 0xBB)
    h.write_byte(OFF_GVAR_SEL_ROW, sel_row)
    h.write_byte(OFF_GVAR_SEL_XLAT + sel_row + visible_row, 0x80 + sel_row + visible_row)


def run_case(name: str, direction: int, visible_row: int, sel_row: int,
             scroll_thunk: int, expected_sel_row: int,
             expected_al_sequence: list[int]) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    patch_tick_town_frame(h)
    patch_joystick_direction(h, direction)
    install_scroll_stubs(h)
    seed_common(h, visible_row, sel_row)

    result = h.call_function(
        POLL_MENU_INPUT,
        regs={"bx": visible_row},
        stub_calls={
            DRAW_CURSOR_AT_DLG_ROW: {},
            INIT_THUNK: {},
            scroll_thunk: {},
        },
        max_steps=2000,
    )

    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")

    draw_regs = [regs for regs in result["stub_regs"]
                 if regs["ip"] == DRAW_CURSOR_AT_DLG_ROW]
    if len(draw_regs) != 1:
        failures.append(f"{name}: draw calls {len(draw_regs)} != 1")
    elif draw_regs[0]["bx"] != visible_row:
        failures.append(
            f"{name}: draw BX {draw_regs[0]['bx']:#06x} != {visible_row:#06x}")

    got_sel_row = h.read_byte(OFF_GVAR_SEL_ROW)
    if got_sel_row != expected_sel_row:
        failures.append(
            f"{name}: sel_row {got_sel_row:#04x} != {expected_sel_row:#04x}")

    init_regs = [regs for regs in result["stub_regs"] if regs["ip"] == INIT_THUNK]
    scroll_regs = [regs for regs in result["stub_regs"] if regs["ip"] == scroll_thunk]
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
        failures.append(
            f"{name}: scroll AL sequence {got_al!r} != {expected_al_sequence!r}")

    expected_bx = 0x2000 + 0x0301
    expected_cx = (7 << 8) | ((5 * 10) - 2)
    for idx, regs in enumerate(scroll_regs):
        if regs["bx"] != expected_bx:
            failures.append(
                f"{name}: scroll {idx} BX {regs['bx']:#06x} != {expected_bx:#06x}")
        if regs["cx"] != expected_cx:
            failures.append(
                f"{name}: scroll {idx} CX {regs['cx']:#06x} != {expected_cx:#06x}")

    if h.read_byte(OFF_GVAR_FRAME_TIMER) != 0:
        failures.append(
            f"{name}: frame timer {h.read_byte(OFF_GVAR_FRAME_TIMER):#04x} != 0")
    if h.read_byte(OFF_GVAR_SKIP_FLAG2) != 0:
        failures.append(f"{name}: skip flag was not cleared")
    if h.read_byte(OFF_GVAR_SPACEBAR_STATE) != 0:
        failures.append(f"{name}: spacebar state was not cleared")
    if (result["regs_after"]["bx"] & 0xFF) != visible_row:
        failures.append(
            f"{name}: final visible row {(result['regs_after']['bx'] & 0xFF):#04x} != {visible_row:#04x}")
    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += run_case(
        "entry_scroll_up", 1, 0, 2, SCROLL_UP_THUNK, 1,
        list(range(9, -1, -1)))
    failures += run_case(
        "entry_scroll_down", 2, 4, 2, SCROLL_DN_THUNK, 3,
        list(range(0, 10)))

    if failures:
        print("town menu-entry scroll oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town menu-entry scroll oracle: full entry feeds up/down selection-window scroll")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
