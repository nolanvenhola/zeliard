#!/usr/bin/env python3
"""MASM oracle for 106TOWN save-name backspace path."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import CODE_SEG, TasmHarness  # noqa: E402


CHUNK = "town"
OFF_SAVE_NAME_LEN = 0x7C5E
OFF_SAVE_NAME_MAXLEN = 0x7C5F
OFF_SAVE_CURSOR_X = 0x7C60
OFF_SAVE_CURSOR_Y = 0x7C62
OFF_SAVE_NEW_FLAG = 0x7C64
OFF_SAVE_NAME_BUF = 0x7C67
OFF_GFX_FILL_FN = 0x2000
OFF_GFX_DRAW_CHAR_FN = 0x2022
OFF_GFX_DRAW_STR_FN = 0x202A

BACKSPACE_EXEC = 0x7B48
FILL_THUNK = 0x0200
DRAW_CHAR_THUNK = 0x0210
DRAW_STR_THUNK = 0x0220


def write_word_code(h: TasmHarness, offset: int, value: int) -> None:
    h.write_code(offset, [value & 0xFF, (value >> 8) & 0xFF])


def install_stubs(h: TasmHarness) -> None:
    write_word_code(h, OFF_GFX_FILL_FN, FILL_THUNK)
    write_word_code(h, OFF_GFX_DRAW_CHAR_FN, DRAW_CHAR_THUNK)
    write_word_code(h, OFF_GFX_DRAW_STR_FN, DRAW_STR_THUNK)


def read_code(h: TasmHarness, offset: int, length: int) -> bytes:
    return bytes(h.mu.mem_read((CODE_SEG << 4) + offset, length))


def check_case(name: str, save_name: bytes, save_len: int, maxlen: int,
               expected_name: bytes, expected_len: int,
               expected_maxlen: int) -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    install_stubs(h)
    h.write_byte(OFF_SAVE_NAME_LEN, save_len)
    h.write_byte(OFF_SAVE_NAME_MAXLEN, maxlen)
    h.write_word(OFF_SAVE_CURSOR_X, 0x0060)
    h.write_byte(OFF_SAVE_CURSOR_Y, 0x56)
    h.write_byte(OFF_SAVE_NEW_FLAG, 0)
    h.write_data(OFF_SAVE_NAME_BUF, save_name)
    h.write_code(OFF_SAVE_NAME_BUF, save_name)
    h.write_code(OFF_SAVE_NEW_FLAG, [0])

    result = h.call_function(
        BACKSPACE_EXEC,
        regs={"si": 0x1234},
        stub_calls={FILL_THUNK: {}, DRAW_CHAR_THUNK: {}, DRAW_STR_THUNK: {}},
        max_steps=700,
    )

    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")
    actual_name = read_code(h, OFF_SAVE_NAME_BUF, len(expected_name))
    if actual_name != expected_name:
        failures.append(
            f"{name}: save_name {actual_name!r} != {expected_name!r}")
    if h.read_byte(OFF_SAVE_NAME_LEN) != expected_len:
        failures.append(
            f"{name}: save_name_len {h.read_byte(OFF_SAVE_NAME_LEN):#04x} != {expected_len:#04x}")
    if h.read_byte(OFF_SAVE_NAME_MAXLEN) != expected_maxlen:
        failures.append(
            f"{name}: save_name_maxlen {h.read_byte(OFF_SAVE_NAME_MAXLEN):#04x} != {expected_maxlen:#04x}")
    if read_code(h, OFF_SAVE_NEW_FLAG, 1)[0] != 0:
        failures.append(f"{name}: save_new_flag was not cleared")

    fill_regs = [regs for regs in result["stub_regs"] if regs["ip"] == FILL_THUNK]
    draw_char_regs = [regs for regs in result["stub_regs"]
                      if regs["ip"] == DRAW_CHAR_THUNK]
    draw_str_regs = [regs for regs in result["stub_regs"]
                     if regs["ip"] == DRAW_STR_THUNK]
    if len(fill_regs) != 2:
        failures.append(f"{name}: fill calls {len(fill_regs)} != 2")
    else:
        expected_clear_bx = (0x185E + (save_len << 9)) & 0xFFFF
        if fill_regs[0]["bx"] != expected_clear_bx:
            failures.append(
                f"{name}: cursor clear BX {fill_regs[0]['bx']:#06x} != {expected_clear_bx:#06x}")
        if fill_regs[1]["bx"] != 0x1856:
            failures.append(
                f"{name}: redraw clear BX {fill_regs[1]['bx']:#06x} != 0x1856")
    if len(draw_char_regs) != 1:
        failures.append(f"{name}: draw-char calls {len(draw_char_regs)} != 1")
    else:
        expected_draw_bx = 0x0060 + (expected_len * 8)
        if draw_char_regs[0]["bx"] != expected_draw_bx:
            failures.append(
                f"{name}: draw-char BX {draw_char_regs[0]['bx']:#06x} != {expected_draw_bx:#06x}")
    if len(draw_str_regs) != 1:
        failures.append(f"{name}: draw-str calls {len(draw_str_regs)} != 1")
    else:
        if draw_str_regs[0]["si"] != OFF_SAVE_NAME_BUF:
            failures.append(
                f"{name}: draw-str SI {draw_str_regs[0]['si']:#06x} != {OFF_SAVE_NAME_BUF:#06x}")
    if result["regs_after"]["si"] != 0x1234:
        failures.append(f"{name}: SI was not preserved")
    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures: list[str] = []
    failures += check_case("normal", b"ABCDEFG`", 3, 5,
                           b"ABDEFG``", 2, 4)
    failures += check_case("empty", b"ABCDEFG`", 0, 5,
                           b"BCDEFG``", 0, 4)

    if failures:
        print("town save-name backspace oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town save-name backspace oracle: buffer shift and redraw sequence match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
