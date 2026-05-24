#!/usr/bin/env python3
"""MASM oracle for 106TOWN menu input movement decisions."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
OFF_GVAR_FRAME_TIMER = 0xFF1A
OFF_GVAR_DLG_COLS = 0xFF52
OFF_GVAR_DLG_ROWS = 0xFF53
OFF_GVAR_DLG_POS = 0xFF54
OFF_GVAR_SEL_ROW = 0xFF56
OFF_GVAR_SEL_XLAT = 0xFF58
OFF_GVAR_DLG_TIMER = 0xFF6A
OFF_GFX_SEL_INIT_FN = 0x301A
OFF_GFX_SEL_SCROLL_UP_FN = 0x301E
OFF_GFX_SEL_SCROLL_DN_FN = 0x3020

SEL_AFTER_JOY_POLL = 0x737E
TICK_TOWN_FRAME = 0x7046
ANIMATE_CURSOR_LEFT_10COLS = 0x747F
ANIMATE_CURSOR_RIGHT_10COLS = 0x74AB
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


def run_case(name: str, direction: int, visible_row: int, sel_row: int,
             dlg_cols: int, dlg_rows: int, expected_visible_row: int,
             expected_sel_row: int, expected_left_calls: int,
             expected_right_calls: int, expected_scroll_calls: int) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    install_stubs(h)
    h.write_data(OFF_GVAR_SEL_XLAT, bytes(range(0x80, 0xC0)))
    h.write_word(OFF_GVAR_DLG_POS, 0x2000)
    h.write_byte(OFF_GVAR_DLG_COLS, dlg_cols)
    h.write_byte(OFF_GVAR_DLG_ROWS, dlg_rows)
    h.write_byte(OFF_GVAR_SEL_ROW, sel_row)
    h.write_byte(OFF_GVAR_DLG_TIMER, 7)
    h.write_byte(OFF_GVAR_FRAME_TIMER, 0)

    result = h.call_function(
        SEL_AFTER_JOY_POLL,
        regs={"ax": direction, "bx": visible_row},
        stub_calls={
            ANIMATE_CURSOR_LEFT_10COLS: {},
            ANIMATE_CURSOR_RIGHT_10COLS: {},
            INIT_THUNK: {},
            SCROLL_UP_THUNK: {},
            SCROLL_DN_THUNK: {},
        },
        max_steps=2000,
    )
    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")

    got_visible_row = result["regs_after"]["bx"] & 0xFF
    got_sel_row = h.read_byte(OFF_GVAR_SEL_ROW)
    left_calls = result["stubs_fired"].count(ANIMATE_CURSOR_LEFT_10COLS)
    right_calls = result["stubs_fired"].count(ANIMATE_CURSOR_RIGHT_10COLS)
    scroll_calls = (
        result["stubs_fired"].count(SCROLL_UP_THUNK) +
        result["stubs_fired"].count(SCROLL_DN_THUNK)
    )
    if got_visible_row != expected_visible_row:
        failures.append(
            f"{name}: visible_row {got_visible_row:#04x} != {expected_visible_row:#04x}")
    if got_sel_row != expected_sel_row:
        failures.append(
            f"{name}: sel_row {got_sel_row:#04x} != {expected_sel_row:#04x}")
    if left_calls != expected_left_calls:
        failures.append(f"{name}: left calls {left_calls} != {expected_left_calls}")
    if right_calls != expected_right_calls:
        failures.append(f"{name}: right calls {right_calls} != {expected_right_calls}")
    if scroll_calls != expected_scroll_calls:
        failures.append(f"{name}: scroll calls {scroll_calls} != {expected_scroll_calls}")
    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += run_case("up_visible", 1, 2, 3, 5, 8, 1, 3, 1, 0, 0)
    failures += run_case("up_top_no_scroll", 1, 0, 0, 5, 8, 0, 0, 0, 0, 0)
    failures += run_case("up_top_scroll", 1, 0, 2, 5, 8, 0, 1, 0, 0, 10)
    failures += run_case("down_visible", 2, 2, 1, 5, 8, 3, 1, 0, 1, 0)
    failures += run_case("down_bottom_no_scroll", 2, 4, 3, 5, 8, 4, 3, 0, 0, 0)
    failures += run_case("down_bottom_scroll", 2, 4, 2, 5, 8, 4, 3, 0, 0, 10)
    failures += run_case("neutral", 0, 2, 1, 5, 8, 2, 1, 0, 0, 0)

    if failures:
        print("town menu-input decision oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town menu-input decision oracle: visible move, scroll, and no-op branches match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
