#!/usr/bin/env python3
"""MASM oracle for 106TOWN poll_menu_input entry setup."""

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
OFF_GVAR_VOLUME = 0xFF75

POLL_MENU_INPUT = 0x7348
TICK_TOWN_FRAME = 0x7046
DRAW_CURSOR_AT_DLG_ROW = 0x746D


def patch_tick_town_frame(h: TasmHarness, *, skip_flag: int,
                          spacebar_state: int) -> None:
    h.write_code(TICK_TOWN_FRAME, [
        0xC6, 0x06,
        OFF_GVAR_FRAME_TIMER & 0xFF, OFF_GVAR_FRAME_TIMER >> 8,
        0x04,
        0xC6, 0x06,
        OFF_GVAR_SKIP_FLAG2 & 0xFF, OFF_GVAR_SKIP_FLAG2 >> 8,
        skip_flag,
        0xC6, 0x06,
        OFF_GVAR_SPACEBAR_STATE & 0xFF, OFF_GVAR_SPACEBAR_STATE >> 8,
        spacebar_state,
        0xC3,
    ])


def run_case(name: str, tick_skip: int, tick_spacebar: int,
             expected_cf: bool, expected_volume: int) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    patch_tick_town_frame(h, skip_flag=tick_skip,
                          spacebar_state=tick_spacebar)
    h.write_byte(OFF_GVAR_FRAME_TIMER, 0x66)
    h.write_byte(OFF_GVAR_SKIP_FLAG2, 0xAA)
    h.write_byte(OFF_GVAR_SPACEBAR_STATE, 0xBB)
    h.write_byte(OFF_GVAR_VOLUME, 0x55)

    result = h.call_function(
        POLL_MENU_INPUT,
        regs={"bx": 3},
        stub_calls={DRAW_CURSOR_AT_DLG_ROW: {}},
        max_steps=200,
    )

    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")

    draw_regs = [regs for regs in result["stub_regs"]
                 if regs["ip"] == DRAW_CURSOR_AT_DLG_ROW]
    if len(draw_regs) != 1:
        failures.append(f"{name}: draw calls {len(draw_regs)} != 1")
    elif draw_regs[0]["bx"] != 3:
        failures.append(f"{name}: draw BX {draw_regs[0]['bx']:#06x} != 0x0003")

    if result["regs_after"]["bx"] != 3:
        failures.append(
            f"{name}: final BX {result['regs_after']['bx']:#06x} != 0x0003")
    if h.read_byte(OFF_GVAR_FRAME_TIMER) != 0:
        failures.append(
            f"{name}: frame timer {h.read_byte(OFF_GVAR_FRAME_TIMER):#04x} != 0")
    if h.read_byte(OFF_GVAR_SKIP_FLAG2) != tick_skip:
        failures.append(
            f"{name}: skip flag {h.read_byte(OFF_GVAR_SKIP_FLAG2):#04x} != {tick_skip:#04x}")
    if h.read_byte(OFF_GVAR_SPACEBAR_STATE) != tick_spacebar:
        failures.append(
            f"{name}: spacebar {h.read_byte(OFF_GVAR_SPACEBAR_STATE):#04x} != {tick_spacebar:#04x}")
    if result["flags_after"]["CF"] is not expected_cf:
        failures.append(f"{name}: CF {result['flags_after']['CF']} != {expected_cf}")
    if h.read_byte(OFF_GVAR_VOLUME) != expected_volume:
        failures.append(
            f"{name}: volume {h.read_byte(OFF_GVAR_VOLUME):#04x} != {expected_volume:#04x}")
    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += run_case("entry_tick_sets_skip", 1, 0, True, 0x55)
    failures += run_case("entry_tick_sets_spacebar", 0, 1, False, 0x1F)

    if failures:
        print("town menu-entry setup oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town menu-entry setup oracle: clear/call/tick/frame/result sequence matches")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
