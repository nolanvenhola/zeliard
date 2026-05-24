#!/usr/bin/env python3
"""MASM oracle for 106TOWN draw_cursor_at_dlg_row."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import RET_SENTINEL, TasmHarness  # noqa: E402


CHUNK = "town"
DRAW_CURSOR_AT_DLG_ROW = 0x746D
OFF_GVAR_DLG_POS = 0xFF54
OFF_GFX_CURSOR_FN = 0x3018


def run_case(h: TasmHarness, name: str, dlg_pos: int, row: int,
             expected_bx: int) -> list[str]:
    h.write_word(OFF_GVAR_DLG_POS, dlg_pos)
    h.write_code(OFF_GFX_CURSOR_FN, [RET_SENTINEL & 0xFF, RET_SENTINEL >> 8])
    result = h.call_function(DRAW_CURSOR_AT_DLG_ROW, regs={"bx": row},
                             max_steps=40)
    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")
    got_bx = result["regs_after"]["bx"]
    if got_bx != expected_bx:
        failures.append(f"{name}: bx {got_bx:#06x} != {expected_bx:#06x}")
    return failures


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    h = TasmHarness(flat_path, load_base)
    failures: list[str] = []
    failures += run_case(h, "row0", 0x343B, 0, 0x353B)
    failures += run_case(h, "row1", 0x343B, 1, 0x3545)
    failures += run_case(h, "row5", 0x2000, 5, 0x2132)
    failures += run_case(h, "word_wrap", 0xFF00, 3, 0x001E)

    if failures:
        print("town draw-cursor-at-dialog-row oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town draw-cursor-at-dialog-row oracle: BX = dlg_pos + 0x100 + 10*row")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
