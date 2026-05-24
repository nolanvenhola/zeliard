#!/usr/bin/env python3
"""MASM oracle for 106TOWN cursor slide animation positions."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
OFF_GVAR_FRAME_TIMER = 0xFF1A
OFF_GVAR_DLG_POS = 0xFF54
OFF_GFX_CURSOR_FN = 0x3018
TICK_TOWN_FRAME = 0x7046
ANIMATE_CURSOR_LEFT_10COLS = 0x747F
ANIMATE_CURSOR_RIGHT_10COLS = 0x74AB
CURSOR_THUNK = 0x0200


def write_word_code(h: TasmHarness, offset: int, value: int) -> None:
    h.write_code(offset, [value & 0xFF, (value >> 8) & 0xFF])


def install_stubs(h: TasmHarness) -> None:
    write_word_code(h, OFF_GFX_CURSOR_FN, CURSOR_THUNK)
    h.write_code(TICK_TOWN_FRAME, [
        0xC6, 0x06,
        OFF_GVAR_FRAME_TIMER & 0xFF, OFF_GVAR_FRAME_TIMER >> 8,
        0x04,
        0xC3,
    ])


def run_case(h: TasmHarness, name: str, proc: int, dlg_pos: int,
             row: int, expected_bx: list[int]) -> list[str]:
    h.write_word(OFF_GVAR_DLG_POS, dlg_pos)
    h.write_byte(OFF_GVAR_FRAME_TIMER, 0)
    result = h.call_function(proc, regs={"bx": row},
                             stub_calls={CURSOR_THUNK: {}},
                             max_steps=1000)
    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")
    got_bx = [regs["bx"] for regs in result["stub_regs"]]
    if got_bx != expected_bx:
        failures.append(f"{name}: bx sequence {got_bx!r} != {expected_bx!r}")
    return failures


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    h = TasmHarness(flat_path, load_base)
    install_stubs(h)

    base = 0x343B + 0x100 + 10
    failures: list[str] = []
    failures += run_case(
        h, "left_row1", ANIMATE_CURSOR_LEFT_10COLS, 0x343B, 1,
        list(range(base - 1, base - 11, -1)))
    failures += run_case(
        h, "right_row1", ANIMATE_CURSOR_RIGHT_10COLS, 0x343B, 1,
        list(range(base + 1, base + 11)))

    if failures:
        print("town cursor animation oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town cursor animation oracle: ten 1-column cursor calls per slide match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
