#!/usr/bin/env python3
"""MASM oracle for the 106TOWN walk-right column/scroll body."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import TasmHarness  # noqa: E402


CHUNK = "town"
WALK_RIGHT_MOVE = 0x6828

OFF_STARTING_POSITION = 0x0080
OFF_TOWN_PLAYER_COL = 0x0083
OFF_FACING_DIRECTION = 0x00C2
OFF_GVAR_POSE_IDX = 0x00E7
OFF_GVAR_TILE_PTR = 0xFF2A
OFF_TOWN_MAP_WIDTH = 0xC002
OFF_TOWN_MAP_SIDE = 0x7C45

GFX_SCROLL_RIGHT2_FN = 0x300A
GFX_SCROLL_LEFT2_FN = 0x300C
NEAR_RET_THUNK = 0x0200


def install_near_ret_thunk(h: TasmHarness) -> None:
    h.write_code(NEAR_RET_THUNK, [0xC3])
    thunk = [NEAR_RET_THUNK & 0xFF, (NEAR_RET_THUNK >> 8) & 0xFF]
    h.write_code(GFX_SCROLL_RIGHT2_FN, thunk)
    h.write_code(GFX_SCROLL_LEFT2_FN, thunk)


def seed_case(h: TasmHarness, col: int, start: int, tile_ptr: int,
              map_width: int, pose: int = 0, facing: int = 1) -> None:
    h.write_byte(OFF_TOWN_PLAYER_COL, col)
    h.write_word(OFF_STARTING_POSITION, start)
    h.write_word(OFF_GVAR_TILE_PTR, tile_ptr)
    h.write_word(OFF_TOWN_MAP_WIDTH, map_width)
    h.write_byte(OFF_GVAR_POSE_IDX, pose)
    h.write_byte(OFF_FACING_DIRECTION, facing)
    h.write_byte(OFF_TOWN_MAP_SIDE, 0)


def run_case(h: TasmHarness, name: str, col: int, start: int, tile_ptr: int,
             map_width: int, expected_col: int, expected_start: int,
             expected_tile_ptr: int, expected_facing: int) -> list[str]:
    seed_case(h, col, start, tile_ptr, map_width)
    result = h.call_function(WALK_RIGHT_MOVE, max_steps=200)
    failures: list[str] = []
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"{name}: {result['stopped_reason']}")
    actual_col = h.read_byte(OFF_TOWN_PLAYER_COL)
    actual_start = h.read_word(OFF_STARTING_POSITION)
    actual_tile = h.read_word(OFF_GVAR_TILE_PTR)
    actual_pose = h.read_byte(OFF_GVAR_POSE_IDX)
    actual_facing = h.read_byte(OFF_FACING_DIRECTION)
    if actual_col != expected_col:
        failures.append(f"{name}: col {actual_col:#04x} != {expected_col:#04x}")
    if actual_start != expected_start:
        failures.append(f"{name}: start {actual_start:#06x} != {expected_start:#06x}")
    if actual_tile != expected_tile_ptr:
        failures.append(f"{name}: tile {actual_tile:#06x} != {expected_tile_ptr:#06x}")
    if actual_pose != 1:
        failures.append(f"{name}: pose {actual_pose:#04x} != 0x01")
    if actual_facing != expected_facing:
        failures.append(f"{name}: facing {actual_facing:#04x} != {expected_facing:#04x}")
    return failures


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    h = TasmHarness(flat_path, load_base)
    install_near_ret_thunk(h)

    failures: list[str] = []
    failures += run_case(h, "inside", 0x0F, 0x0020, 0x1234, 0x0064,
                         0x10, 0x0020, 0x1234, 0x00)
    failures += run_case(h, "scroll", 0x10, 0x0003, 0x1234, 0x0064,
                         0x10, 0x0004, 0x123C, 0x00)
    failures += run_case(h, "far_edge", 0x10, 0x0003, 0x1234, 0x0027,
                         0x11, 0x0003, 0x1234, 0x00)

    if failures:
        print("town walk-right oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town walk-right oracle: column increment, edge clamp, and scroll-side effects match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
