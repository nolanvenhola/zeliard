#!/usr/bin/env python3
"""MASM release-byte oracles for the 106TOWN live frame primitives."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import CODE_SEG, DATA_SEG, TasmHarness  # noqa: E402


# The rebuilt .BIN includes the four-byte SAR header, and TasmHarness maps
# byte zero at 6000h. These addresses therefore include that four-byte bias.
PROCESS_TOWN_EVENT_TABLE = 0x6AF1
TICK_NPCS_DISPATCH = 0x6B20
PLAYER_SCAN_LOOP = 0x6872
MARK_PLAYER_COL = 0x6954


def event_table_cases(h: TasmHarness) -> list[str]:
    failures: list[str] = []
    # [flag pointer][mask], repeated [destination pointer][value], FFFF;
    # an outer FFFF terminates the table.
    h.write_word(0xC015, 0x4000)
    h.write_data(0x4000, [
        0x00, 0x41, 0x04,
        0x00, 0x42, 0xAA,
        0x01, 0x42, 0x55,
        0xFF, 0xFF,
        0xFF, 0xFF,
    ])
    h.write_byte(0x4100, 0x04)
    result = h.call_function(PROCESS_TOWN_EVENT_TABLE, max_steps=200)
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"event active: {result['stopped_reason']}")
    if h.read_data(0x4200, 2) != bytes([0xAA, 0x55]):
        failures.append("event active: destination writes differ")

    h.write_data(0x4200, [0x11, 0x22])
    h.write_byte(0x4100, 0)
    result = h.call_function(PROCESS_TOWN_EVENT_TABLE, max_steps=200)
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"event inactive: {result['stopped_reason']}")
    if h.read_data(0x4200, 2) != bytes([0x11, 0x22]):
        failures.append("event inactive: writes were not skipped")
    return failures


def npc_tick_cases(h: TasmHarness) -> list[str]:
    failures: list[str] = []
    # The embedded dispatch words are release runtime addresses. TasmHarness
    # retains the SAR header, so patch their isolated-test copies by +4.
    npc_targets = [0x6B55, 0x6B70, 0x6BAA, 0x6BBB,
                   0x6BD6, 0x6BF0, 0x6C1D, 0x6C2E]
    dispatch = []
    for target in npc_targets:
        dispatch += [target & 0xFF, target >> 8]
    h.write_data(0x6B41, dispatch)
    h.write_word(0xC00F, 0x4300)
    h.write_word(0xC011, 0x4400)
    h.write_word(0x4400, 0x0000)
    h.write_word(0x4402, 0x0040)
    # position, direction/entity, saved tile, animation, type, flags, text
    h.write_data(0x4300, [
        0x10, 0x00, 0x80, 0x22, 0x00, 0x01, 0x00, 0x00,
        0xFF, 0xFF,
    ])
    h.write_byte(0xC01C + 0x10 * 8, 0xFD)
    h.write_byte(0xC01C + 0x0F * 8, 0x33)

    first = h.call_function(TICK_NPCS_DISPATCH, max_steps=500)
    if first["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"npc tick 1: {first['stopped_reason']}")
    if h.read_word(0x4300) != 0x0010 or h.read_byte(0x4304) != 0x10:
        failures.append("npc tick 1: position/animation differs")
    if h.read_byte(0xC01C + 0x10 * 8) != 0xFD:
        failures.append("npc tick 1: occupied tile was not stamped")

    second = h.call_function(TICK_NPCS_DISPATCH, max_steps=500)
    if second["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"npc tick 2: {second['stopped_reason']}")
    second_pos = h.read_word(0x4300)
    second_anim = h.read_byte(0x4304)
    if second_pos != 0x000F or second_anim != 0x01:
        failures.append(
            f"npc tick 2: pos={second_pos:#06x} anim={second_anim:#04x}")
    if h.read_byte(0xC01C + 0x10 * 8) != 0x22:
        failures.append("npc tick 2: old tile was not restored")
    if h.read_byte(0xC01C + 0x0F * 8) != 0xFD or h.read_byte(0x4303) != 0x33:
        failures.append("npc tick 2: new tile stamp/save differs")

    seed_anim = [0x30, 0x10, 0x30, 0x55, 0x30, 0x10, 0x30, 0x55]
    expected_position = [0x20, 0x1F, 0x1F, 0x20, 0x20, 0x1F, 0x1F, 0x20]
    expected_anim = [0x01, 0x01, 0x01, 0x55, 0x01, 0x01, 0x01, 0x55]
    for npc_type in range(8):
        h.write_word(0xC00F, 0x4300)
        h.write_word(0xC011, 0x4400)
        h.write_word(0x4400, 0)
        h.write_word(0x4402, 0x40)
        h.write_word(0x0080, 0)
        h.write_byte(0x0083, 0x0A)
        h.write_data(0x4300, [
            0x20, 0x00, 0x80, 0x22, seed_anim[npc_type], npc_type, 0, 0,
            0xFF, 0xFF,
        ])
        h.write_byte(0xC01C + 0x20 * 8, 0xFD)
        h.write_byte(0xC01C + 0x1F * 8, 0x33)
        result = h.call_function(TICK_NPCS_DISPATCH, max_steps=500)
        if result["stopped_reason"] != "returned_to_sentinel":
            failures.append(f"npc type {npc_type}: {result['stopped_reason']}")
            continue
        position = h.read_word(0x4300)
        animation = h.read_byte(0x4304)
        if position != expected_position[npc_type] or \
           animation != expected_anim[npc_type]:
            failures.append(
                f"npc type {npc_type}: pos={position:#06x} anim={animation:#04x}")
    return failures


def scan_and_cursor_cases(h: TasmHarness) -> list[str]:
    failures: list[str] = []
    h.write_code(0xFF2C, [DATA_SEG & 0xFF, DATA_SEG >> 8])
    h.write_word(0x8002, 0x4500)
    h.write_data(0x4500, [2, 0x17, 0x2A])
    blocked = h.call_function(PLAYER_SCAN_LOOP, regs={"ax": 0x17}, max_steps=100)
    if not blocked["flags_after"]["ZF"]:
        failures.append("player scan: listed tile was not blocked")
    clear = h.call_function(PLAYER_SCAN_LOOP, regs={"ax": 0x18}, max_steps=100)
    if clear["flags_after"]["ZF"]:
        failures.append("player scan: unlisted tile was blocked")

    h.write_code(0xE000, [0xFE] * 0xE0)
    h.write_byte(0x0083, 3)
    result = h.call_function(MARK_PLAYER_COL, max_steps=100)
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"cursor mark: {result['stopped_reason']}")
    expected = bytes([0xFF, 0xFF, 0xFF])
    cursor_a = bytes(h.mu.mem_read((CODE_SEG << 4) + 0xE000 + 3 * 8 + 5, 3))
    cursor_b = bytes(h.mu.mem_read((CODE_SEG << 4) + 0xE000 + 3 * 8 + 13, 3))
    if cursor_a != expected or cursor_b != expected:
        failures.append("cursor mark: six FF bytes differ")
    return failures


def main() -> int:
    flat_path, load_base = BIN_PATHS["town"]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1
    h = TasmHarness(flat_path, load_base)
    failures = event_table_cases(h) + npc_tick_cases(h) + scan_and_cursor_cases(h)
    if failures:
        print("town live-loop primitive mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1
    print("town live-loop oracles: events, NPC ticks, passability, cursor mark match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
