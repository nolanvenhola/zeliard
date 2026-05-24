#!/usr/bin/env python3
"""MASM oracle for 106TOWN save-name cursor draw helpers."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
OFF_SAVE_NAME_LEN = 0x7C5E
OFF_SAVE_NAME_MAXLEN = 0x7C5F
OFF_SAVE_CURSOR_X = 0x7C60
OFF_SAVE_CURSOR_Y = 0x7C62
OFF_SAVE_NAME_BUF = 0x7C67
OFF_GFX_FILL_FN = 0x2000
OFF_GFX_DRAW_CHAR_FN = 0x2022
OFF_GFX_DRAW_STR_FN = 0x202A

UPDATE_SAVE_NAME_CURSOR = 0x7AB1
REDRAW_SAVE_NAME_AT_CURSOR = 0x7B1E
FILL_THUNK = 0x0200
DRAW_CHAR_THUNK = 0x0210
DRAW_STR_THUNK = 0x0220


def write_word_code(h: TasmHarness, offset: int, value: int) -> None:
    h.write_code(offset, [value & 0xFF, (value >> 8) & 0xFF])


def install_stubs(h: TasmHarness) -> None:
    write_word_code(h, OFF_GFX_FILL_FN, FILL_THUNK)
    write_word_code(h, OFF_GFX_DRAW_CHAR_FN, DRAW_CHAR_THUNK)
    write_word_code(h, OFF_GFX_DRAW_STR_FN, DRAW_STR_THUNK)


def seed_common(h: TasmHarness, cursor_x: int = 0x0060,
                cursor_y: int = 0x56) -> None:
    h.write_word(OFF_SAVE_CURSOR_X, cursor_x)
    h.write_byte(OFF_SAVE_CURSOR_Y, cursor_y)
    h.write_data(OFF_SAVE_NAME_BUF, b"ABCDEFGH")


def check_update_case(name: str, initial_len: int, maxlen: int,
                      delta: int, expected_len: int) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    install_stubs(h)
    seed_common(h)
    h.write_byte(OFF_SAVE_NAME_LEN, initial_len)
    h.write_byte(OFF_SAVE_NAME_MAXLEN, maxlen)
    result = h.call_function(
        UPDATE_SAVE_NAME_CURSOR,
        regs={"ax": delta, "si": 0x1234},
        stub_calls={FILL_THUNK: {}, DRAW_CHAR_THUNK: {}},
        max_steps=300,
    )

    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")
    if h.read_byte(OFF_SAVE_NAME_LEN) != expected_len:
        failures.append(
            f"{name}: save_name_len {h.read_byte(OFF_SAVE_NAME_LEN):#04x} != {expected_len:#04x}")

    fill_regs = [regs for regs in result["stub_regs"] if regs["ip"] == FILL_THUNK]
    draw_regs = [regs for regs in result["stub_regs"] if regs["ip"] == DRAW_CHAR_THUNK]
    if len(fill_regs) != 1:
        failures.append(f"{name}: fill calls {len(fill_regs)} != 1")
    else:
        expected_clear_bx = (0x185E + (initial_len << 9)) & 0xFFFF
        if fill_regs[0]["bx"] != expected_clear_bx:
            failures.append(
                f"{name}: fill BX {fill_regs[0]['bx']:#06x} != {expected_clear_bx:#06x}")
        if fill_regs[0]["cx"] != 0x0208:
            failures.append(f"{name}: fill CX {fill_regs[0]['cx']:#06x} != 0x0208")
        if fill_regs[0]["ax"] != 0:
            failures.append(f"{name}: fill AX {fill_regs[0]['ax']:#06x} != 0")
    if len(draw_regs) != 1:
        failures.append(f"{name}: draw-char calls {len(draw_regs)} != 1")
    else:
        expected_draw_bx = 0x0060 + (expected_len * 8)
        if draw_regs[0]["bx"] != expected_draw_bx:
            failures.append(
                f"{name}: draw BX {draw_regs[0]['bx']:#06x} != {expected_draw_bx:#06x}")
        if draw_regs[0]["cx"] != 0x025E:
            failures.append(f"{name}: draw CX {draw_regs[0]['cx']:#06x} != 0x025e")
        if draw_regs[0]["ax"] != 0x067F:
            failures.append(f"{name}: draw AX {draw_regs[0]['ax']:#06x} != 0x067f")
    if result["regs_after"]["si"] != 0x1234:
        failures.append(f"{name}: SI was not preserved")
    return failures


def check_redraw_case() -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    install_stubs(h)
    seed_common(h)
    result = h.call_function(
        REDRAW_SAVE_NAME_AT_CURSOR,
        regs={"si": 0x1234},
        stub_calls={FILL_THUNK: {}, DRAW_STR_THUNK: {}},
        max_steps=300,
    )

    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"redraw: {result['stopped_reason']}")
    fill_regs = [regs for regs in result["stub_regs"] if regs["ip"] == FILL_THUNK]
    draw_regs = [regs for regs in result["stub_regs"] if regs["ip"] == DRAW_STR_THUNK]
    if len(fill_regs) != 1:
        failures.append(f"redraw: fill calls {len(fill_regs)} != 1")
    else:
        if fill_regs[0]["bx"] != 0x1856:
            failures.append(f"redraw: fill BX {fill_regs[0]['bx']:#06x} != 0x1856")
        if fill_regs[0]["cx"] != 0x1008:
            failures.append(f"redraw: fill CX {fill_regs[0]['cx']:#06x} != 0x1008")
        if fill_regs[0]["ax"] != 0:
            failures.append(f"redraw: fill AX {fill_regs[0]['ax']:#06x} != 0")
    if len(draw_regs) != 1:
        failures.append(f"redraw: draw-str calls {len(draw_regs)} != 1")
    else:
        if draw_regs[0]["bx"] != 0x0060:
            failures.append(f"redraw: draw BX {draw_regs[0]['bx']:#06x} != 0x0060")
        if draw_regs[0]["cx"] != 0x1056:
            failures.append(f"redraw: draw CX {draw_regs[0]['cx']:#06x} != 0x1056")
        if draw_regs[0]["si"] != OFF_SAVE_NAME_BUF:
            failures.append(
                f"redraw: draw SI {draw_regs[0]['si']:#06x} != {OFF_SAVE_NAME_BUF:#06x}")
    if result["regs_after"]["si"] != 0x1234:
        failures.append("redraw: SI was not preserved")
    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += check_update_case("update_forward", 2, 5, 1, 3)
    failures += check_update_case("update_underflow", 0, 5, 0xFF, 0)
    failures += check_update_case("update_max_clamp", 5, 5, 2, 5)
    failures += check_redraw_case()
    if failures:
        print("town save-name cursor oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town save-name cursor oracle: fill/draw calls and length clamping match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
