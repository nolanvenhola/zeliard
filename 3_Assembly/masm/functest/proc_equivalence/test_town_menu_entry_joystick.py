#!/usr/bin/env python3
"""MASM oracle for 106TOWN poll_menu_input entry through joystick decisions."""

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
OFF_GVAR_SEL_ROW = 0xFF56

POLL_MENU_INPUT = 0x7348
SEL_POLL_JOY = 0x7378
TICK_TOWN_FRAME = 0x7046
DRAW_CURSOR_AT_DLG_ROW = 0x746D
ANIMATE_CURSOR_LEFT_10COLS = 0x747F
ANIMATE_CURSOR_RIGHT_10COLS = 0x74AB


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


def run_case(name: str, direction: int, visible_row: int, sel_row: int,
             expected_visible_row: int, expected_left_calls: int,
             expected_right_calls: int) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    patch_tick_town_frame(h)
    patch_joystick_direction(h, direction)
    h.write_byte(OFF_GVAR_FRAME_TIMER, 0x66)
    h.write_byte(OFF_GVAR_SKIP_FLAG2, 0xAA)
    h.write_byte(OFF_GVAR_SPACEBAR_STATE, 0xBB)
    h.write_byte(OFF_GVAR_DLG_COLS, 5)
    h.write_byte(OFF_GVAR_DLG_ROWS, 8)
    h.write_byte(OFF_GVAR_SEL_ROW, sel_row)

    result = h.call_function(
        POLL_MENU_INPUT,
        regs={"bx": visible_row},
        stub_calls={
            DRAW_CURSOR_AT_DLG_ROW: {},
            ANIMATE_CURSOR_LEFT_10COLS: {},
            ANIMATE_CURSOR_RIGHT_10COLS: {},
        },
        max_steps=500,
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

    got_visible_row = result["regs_after"]["bx"] & 0xFF
    if got_visible_row != expected_visible_row:
        failures.append(
            f"{name}: visible row {got_visible_row:#04x} != {expected_visible_row:#04x}")

    left_calls = result["stubs_fired"].count(ANIMATE_CURSOR_LEFT_10COLS)
    right_calls = result["stubs_fired"].count(ANIMATE_CURSOR_RIGHT_10COLS)
    if left_calls != expected_left_calls:
        failures.append(f"{name}: left calls {left_calls} != {expected_left_calls}")
    if right_calls != expected_right_calls:
        failures.append(f"{name}: right calls {right_calls} != {expected_right_calls}")
    if h.read_byte(OFF_GVAR_FRAME_TIMER) != 0:
        failures.append(
            f"{name}: frame timer {h.read_byte(OFF_GVAR_FRAME_TIMER):#04x} != 0")
    if h.read_byte(OFF_GVAR_SKIP_FLAG2) != 0:
        failures.append(f"{name}: skip flag was not cleared")
    if h.read_byte(OFF_GVAR_SPACEBAR_STATE) != 0:
        failures.append(f"{name}: spacebar state was not cleared")
    if h.read_byte(OFF_GVAR_SEL_ROW) != sel_row:
        failures.append(
            f"{name}: sel row {h.read_byte(OFF_GVAR_SEL_ROW):#04x} != {sel_row:#04x}")
    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += run_case("entry_joystick_up_visible", 1, 2, 3, 1, 1, 0)
    failures += run_case("entry_joystick_up_top_no_scroll", 1, 0, 0, 0, 0, 0)
    failures += run_case("entry_joystick_down_visible", 2, 2, 1, 3, 0, 1)
    failures += run_case("entry_joystick_down_bottom_no_scroll", 2, 4, 3, 4, 0, 0)
    failures += run_case("entry_joystick_neutral", 0, 2, 1, 2, 0, 0)

    if failures:
        print("town menu-entry joystick oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town menu-entry joystick oracle: full entry feeds visible move, bounded no-op, and neutral decisions")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
