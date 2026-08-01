#!/usr/bin/env python3
"""Oracle for GAME.BIN run_game_main bootstrap orchestration.

This does not emulate DOS, SAR decompression, or the loaded drivers.  It runs
the MASM-built GAME.BIN bytes with those dependencies stubbed and records the
observable call sequence that game.asm issues before transferring control to
opdemo.bin or the saved-game main loop.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_PROT_ALL

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from fixtures import MASM_ROOT, resolve_proc  # noqa: E402
from harness import CODE_SEG, RET_SENTINEL, TasmHarness  # noqa: E402


GAME_BIN = MASM_ROOT / "bin" / "game.bin"
LOAD_BASE = 0xA000

SAR_LOADER_SLOT = 0x010C
STICK_JOY_SLOT = 0x0120
GFX_CALL_A_SLOT = 0x201C
GFX_CALL_B_SLOT = 0x201E
GFX_CALL_C_SLOT = 0x2020
SOUND_LOAD_SLOT = 0x203E
LOADED_CODE_A_SLOT = 0x3000
LOADED_CODE_B_SLOT = 0x6000
LOADED_CODE_B_FN_SLOT = 0x6002

SAR_THUNK = 0x0200
STICK_THUNK = 0x0202
GFX_A_THUNK = 0x0204
GFX_B_THUNK = 0x0206
GFX_C_THUNK = 0x0208
SOUND_THUNK = 0x020A
DRIVER_INIT_THUNK = 0x020C

OFF_GFX_MODE = 0xFF14
OFF_SWORD = 0x0092
OFF_SHIELD = 0x0093
OFF_SELECTED_SPELL = 0x009D
OFF_MUSIC_TRACK_COUNT = 0x00A0
OFF_CURRENT_AREA = 0x00C4
OFF_CURRENT_LEVEL_IDX = 0x00C8
OFF_CINEMATIC_ACTIVE = 0xFF77
OFF_SAVE_DATA_PTR = 0xC000
OFF_GAME_INIT_FN = 0xA470
SAVE_RECORD_FIXTURE = 0x5000

RELOC_SENTINELS = (0x0010, 0x0100, 0x1234, 0x7FFF, 0x8000, 0xABCD, 0xFFF0)
RELOC_FONT = (0x0000, 0xF500, 3, 0xF500)
RELOC_ITEMP = (0x1000, 0xE200, 7, 0xE200)
RELOC_SWORD = (0x2000, 0x1800, 3, 0x1800)
DRIVER_TABLE_EXPECTED = (
    (0, "gdega.bin", "gtega.bin", "gfega.bin"),
    (1, "gdcga.bin", "gtcga.bin", "gfcga.bin"),
    (2, "gdcga.bin", "gtcga.bin", "gfcga.bin"),
    (3, "gdhgc.bin", "gthgc.bin", "gfhgc.bin"),
    (4, "gdmcga.bin", "gtmcga.bin", "gfmcga.bin"),
    (5, "gdtga.bin", "gttga.bin", "gftga.bin"),
)

BOOT_CLEAR_OFFSETS = (
    0xFF39,  # flag_climbing
    0xFF3A,  # flag_riding
    0xFF43,  # scroll_active
    0xFF44,  # restore_pending
    0xFF3C,  # gvar_palette_flag
    0xFF3D,  # equip_byte
    0xFF38,  # flag_shield
    0xFF36,  # gvar_enemy_cnt
    0xFF3E,  # gvar_palette_b
    0xFF4B,  # gvar_item_result
    0xFF08,  # gvar_timer_ticks
    0x00E7,  # gvar_pose_idx
    0xFF74,  # gvar_input_lock
    0xFF77,  # gvar_cinematic_active
    0xFF40,  # flag_hero_state
    0xFF42,  # gvar_debug_val
)


def word_bytes(value: int) -> list[int]:
    return [value & 0xFF, (value >> 8) & 0xFF]


def setup_harness() -> TasmHarness:
    h = TasmHarness(str(GAME_BIN), load_base=LOAD_BASE)

    # game.asm uses ES=CS+0x1000 and ES=CS+0x3000 during saved-game setup.
    # The normal harness maps CS, CS+0x2000 (DATA_SEG), and stack; add the two
    # extra game-relative segments and put a RETF thunk at CS+0x3000:0000 for
    # the far call through game_init_fn.
    h.mu.mem_map(0x20000, 0x10000, UC_PROT_ALL)
    h.mu.mem_map(0x40000, 0x10000, UC_PROT_ALL)
    h.mu.mem_write(0x40000, b"\xCB")

    for slot, thunk in (
        (SAR_LOADER_SLOT, SAR_THUNK),
        (STICK_JOY_SLOT, STICK_THUNK),
        (GFX_CALL_A_SLOT, GFX_A_THUNK),
        (GFX_CALL_B_SLOT, GFX_B_THUNK),
        (GFX_CALL_C_SLOT, GFX_C_THUNK),
        (SOUND_LOAD_SLOT, SOUND_THUNK),
        (LOADED_CODE_A_SLOT, DRIVER_INIT_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))

    h.write_code(LOADED_CODE_B_SLOT, word_bytes(RET_SENTINEL))
    h.write_code(LOADED_CODE_B_FN_SLOT, word_bytes(RET_SENTINEL))
    return h


def read_code(h: TasmHarness, offset: int, length: int) -> bytes:
    return bytes(h.mu.mem_read((CODE_SEG << 4) + offset, length))


def read_code_byte(h: TasmHarness, offset: int) -> int:
    return read_code(h, offset, 1)[0]


def segment_linear(es_delta: int, offset: int) -> int:
    return ((CODE_SEG + es_delta) << 4) + offset


def read_segment_word(h: TasmHarness, es_delta: int, offset: int) -> int:
    b = bytes(h.mu.mem_read(segment_linear(es_delta, offset), 2))
    return b[0] | (b[1] << 8)


def write_segment_word(h: TasmHarness, es_delta: int, offset: int, value: int) -> None:
    h.mu.mem_write(segment_linear(es_delta, offset), bytes(word_bytes(value)))


def seed_relocation_table(h: TasmHarness, relocation: tuple[int, int, int, int]) -> None:
    es_delta, offset, count, _addend = relocation
    for i in range(count):
        write_segment_word(h, es_delta, offset + i * 2, RELOC_SENTINELS[i])


def read_ref_name(h: TasmHarness, offset: int) -> str:
    raw = bytearray()
    pos = offset + 2
    while True:
        b = read_code_byte(h, pos)
        if b == 0:
            return raw.decode("ascii", errors="replace")
        raw.append(b)
        pos += 1


def sar_records(h: TasmHarness, result: dict) -> list[dict[str, int | str]]:
    out: list[dict[str, int | str]] = []
    for regs in result.get("stub_regs", []):
        if regs["ip"] != SAR_THUNK:
            continue
        si = regs["si"]
        ax = regs["ax"]
        record: dict[str, int | str] = {
            "al": ax & 0xFF,
            "ah": (ax >> 8) & 0xFF,
            "di": regs["di"],
            "es_delta": ((regs["es"] - CODE_SEG) & 0xFFFF),
            "si": si,
        }
        if LOAD_BASE <= si < 0x10000:
            record["archive"] = read_code_byte(h, si)
            record["chunk"] = read_code_byte(h, si + 1)
            record["name"] = read_ref_name(h, si)
        else:
            record["name"] = "<register-call>"
        out.append(record)
    return out


def run_bootstrap(ax: int, gfx_mode: int, *, saved_fixture: bool,
                  sword: int = 0, shield: int = 0, selected_spell: int = 0,
                  music_track_count: int = 0,
                  stub_palette: bool = False) -> tuple[TasmHarness, dict, list[dict[str, int | str]]]:
    h = setup_harness()
    if stub_palette:
        h.write_code(resolve_proc("game", "set_vga_palette") + LOAD_BASE, [0xC3])
    for offset in BOOT_CLEAR_OFFSETS:
        h.write_code(offset, [0xA5])
    seed_relocation_table(h, RELOC_FONT)
    if saved_fixture:
        seed_relocation_table(h, RELOC_ITEMP)
        seed_relocation_table(h, RELOC_SWORD)
    h.write_code(OFF_GFX_MODE, [gfx_mode])
    h.write_code(OFF_SWORD, [sword])
    h.write_code(OFF_SHIELD, [shield])
    h.write_code(OFF_SELECTED_SPELL, [selected_spell])
    h.write_code(OFF_MUSIC_TRACK_COUNT, [music_track_count])
    h.write_code(OFF_CURRENT_AREA, [3])
    if saved_fixture:
        h.write_code(OFF_SAVE_DATA_PTR, word_bytes(SAVE_RECORD_FIXTURE))
        # First byte -> score/current-level index after SHR/AND.
        # Second byte -> MMAN/CMAN town sprite-bank index.
        h.write_code(SAVE_RECORD_FIXTURE, [0x0A, 0x03])

    proc = resolve_proc("game", "run_game_main") + LOAD_BASE
    stubs = {
        SAR_THUNK: {},
        STICK_THUNK: {},
        GFX_A_THUNK: {},
        GFX_B_THUNK: {},
        GFX_C_THUNK: {},
        SOUND_THUNK: {},
        DRIVER_INIT_THUNK: {},
    }
    result = h.call_function(proc, regs={"ax": ax}, stub_calls=stubs, max_steps=5000)
    return h, result, sar_records(h, result)


def expect(condition: bool, failures: list[str], message: str) -> None:
    if not condition:
        failures.append(message)


def assert_record(failures: list[str], records: list[dict[str, int | str]], index: int,
                  name: str, al: int, di: int, es_delta: int) -> None:
    if index >= len(records):
        failures.append(f"missing SAR record {index}: {name}")
        return
    rec = records[index]
    expect(rec["name"] == name, failures, f"SAR[{index}] name {rec['name']!r} != {name!r}")
    expect(rec["al"] == al, failures, f"SAR[{index}] AL {rec['al']:02X} != {al:02X}")
    expect(rec["di"] == di, failures, f"SAR[{index}] DI {rec['di']:04X} != {di:04X}")
    expect(rec["es_delta"] == es_delta, failures,
           f"SAR[{index}] ES delta {rec['es_delta']:04X} != {es_delta:04X}")


def assert_boot_clear_block(failures: list[str], h: TasmHarness, *, new_game: bool) -> None:
    for offset in BOOT_CLEAR_OFFSETS:
        got = read_code_byte(h, offset)
        if new_game and offset == OFF_CINEMATIC_ACTIVE:
            expect(got == 0xFF, failures,
                   f"new-game cinematic flag {got:02X} != FF after clear+opdemo branch")
        else:
            expect(got == 0, failures,
                   f"boot clear offset {offset:04X} remained {got:02X}")


def assert_relocation(failures: list[str], h: TasmHarness,
                      relocation: tuple[int, int, int, int], label: str) -> None:
    es_delta, offset, count, addend = relocation
    for i in range(count):
        got = read_segment_word(h, es_delta, offset + i * 2)
        want = (RELOC_SENTINELS[i] + addend) & 0xFFFF
        expect(got == want, failures,
               f"{label}[{i}] {got:04X} != {want:04X}")


def stub_regs(result: dict, thunk: int) -> list[dict[str, int]]:
    return [regs for regs in result.get("stub_regs", []) if regs["ip"] == thunk]


def assert_driver_table_modes(failures: list[str]) -> None:
    for mode, gd_name, gt_name, gf_name in DRIVER_TABLE_EXPECTED:
        _new_h, new_result, new_records = run_bootstrap(
            0x0000, mode, saved_fixture=False, stub_palette=True)
        expect(new_result["stopped_reason"] == "returned_to_sentinel", failures,
               f"new-game mode {mode} did not reach sentinel: {new_result['stopped_reason']}")
        assert_record(failures, new_records, 1, gd_name, 3, 0x3000, 0x0000)

        _saved_h, saved_result, saved_records = run_bootstrap(
            0xFFFF, mode, saved_fixture=True, stub_palette=True)
        expect(saved_result["stopped_reason"] == "returned_to_sentinel", failures,
               f"saved-game mode {mode} did not reach sentinel: {saved_result['stopped_reason']}")
        assert_record(failures, saved_records, 1, gd_name, 3, 0x3000, 0x0000)
        assert_record(failures, saved_records, 2, gt_name, 3, 0x3000, 0x0000)
        assert_record(failures, saved_records, 4, gf_name, 3, 0x9000, 0x2000)


def main() -> int:
    failures: list[str] = []

    new_h, new_result, new_records = run_bootstrap(0x0000, 4, saved_fixture=False)
    expect(new_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"new-game bootstrap did not transfer to sentinel: {new_result['stopped_reason']}")
    expect(len(new_records) == 3, failures, f"new-game SAR calls {len(new_records)} != 3")
    assert_record(failures, new_records, 0, "font.grp", 2, 0xF500, 0x0000)
    assert_record(failures, new_records, 1, "gdmcga.bin", 3, 0x3000, 0x0000)
    assert_record(failures, new_records, 2, "opdemo.bin", 3, 0x6000, 0x0000)
    expect(read_code_byte(new_h, OFF_CINEMATIC_ACTIVE) == 0xFF, failures,
           "new-game cinematic flag was not set to 0xFF")
    assert_boot_clear_block(failures, new_h, new_game=True)
    assert_relocation(failures, new_h, RELOC_FONT, "font relocation")

    saved_h, saved_result, saved_records = run_bootstrap(0xFFFF, 1, saved_fixture=True)
    expect(saved_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"saved-game bootstrap did not transfer to sentinel: {saved_result['stopped_reason']}")
    expect(len(saved_records) == 15, failures, f"saved-game SAR calls {len(saved_records)} != 15")
    for idx, name, al, di, es_delta in (
        (0, "font.grp", 2, 0xF500, 0x0000),
        (1, "gdcga.bin", 3, 0x3000, 0x0000),
        (2, "gtcga.bin", 3, 0x3000, 0x0000),
        (3, "town.bin", 3, 0x6000, 0x0000),
        (4, "gfcga.bin", 3, 0x9000, 0x2000),
        (5, "fight.bin", 3, 0xC000, 0x2000),
        (6, "select.bin", 3, 0xC000, 0x1000),
        (7, "itemp.grp", 2, 0xE200, 0x1000),
        (8, "magic.grp", 2, 0x0000, 0x2000),
        (9, "sword.grp", 2, 0x1800, 0x2000),
        (11, "mole.bin", 3, 0x0000, 0x3000),
    ):
        assert_record(failures, saved_records, idx, name, al, di, es_delta)

    if len(saved_records) > 10:
        rec = saved_records[10]
        expect(rec["al"] == 4 and rec["ah"] == 0, failures,
               f"archive-load call AX {rec['ah']:02X}{rec['al']:02X} != 0004")
    if len(saved_records) > 12:
        rec = saved_records[12]
        expect(rec["al"] == 1 and rec["ah"] == 3, failures,
               f"level-load call AX {rec['ah']:02X}{rec['al']:02X} != 0301")
    if len(saved_records) > 14:
        level_music = saved_records[13]
        town_sprite = saved_records[14]
        expect(level_music["al"] == 5 and level_music["di"] == 0x3000 and level_music["es_delta"] == 0x1000,
               failures, "level-music load did not use AL=5, DI=3000, ES=CS+1000")
        expect(town_sprite["al"] == 2 and town_sprite["di"] == 0x4000 and town_sprite["es_delta"] == 0x1000,
               failures, "town-sprite load did not use AL=2, DI=4000, ES=CS+1000")

    expect(read_code_byte(saved_h, OFF_CURRENT_LEVEL_IDX) == 5, failures,
           f"current_level_idx {read_code_byte(saved_h, OFF_CURRENT_LEVEL_IDX):02X} != 05")
    expect(read_code_byte(saved_h, OFF_CINEMATIC_ACTIVE) == 0, failures,
           "saved-game cinematic flag was not cleared")
    assert_boot_clear_block(failures, saved_h, new_game=False)
    assert_relocation(failures, saved_h, RELOC_FONT, "font relocation")
    assert_relocation(failures, saved_h, RELOC_ITEMP, "itemp relocation")
    assert_relocation(failures, saved_h, RELOC_SWORD, "sword relocation")
    expect(read_segment_word(saved_h, 0, OFF_GAME_INIT_FN + 2) == CODE_SEG + 0x3000,
           failures, "game_init_fn segment was not patched to CS+3000")

    _opt_h, opt_result, opt_records = run_bootstrap(
        0xFFFF,
        1,
        saved_fixture=True,
        sword=0x12,
        shield=0x34,
        selected_spell=0x56,
        music_track_count=3,
    )
    expect(opt_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"optional saved-game bootstrap did not transfer to sentinel: {opt_result['stopped_reason']}")
    expect(len(opt_records) == 15, failures,
           f"optional saved-game SAR calls {len(opt_records)} != 15")
    if len(opt_records) > 10:
        rec = opt_records[10]
        expect(rec["al"] == 4 and rec["ah"] == 0x12, failures,
               f"optional archive-load call AX {rec['ah']:02X}{rec['al']:02X} != 1204")

    sound = stub_regs(opt_result, SOUND_THUNK)
    expect([(r["dx"], r["bx"], r["ax"] & 0xFF) for r in sound] == [
        (0, 0x0F00, 0),
        (1, 0x3D00, 0),
        (2, 0x1500, 0),
    ], failures, "optional music track calls did not match first-three plan")

    gfx_a = stub_regs(opt_result, GFX_A_THUNK)
    gfx_b = stub_regs(opt_result, GFX_B_THUNK)
    gfx_c = stub_regs(opt_result, GFX_C_THUNK)
    expect([(r["ax"] & 0xFF, r["bx"]) for r in gfx_a] == [(0x12, 0x18AB)],
           failures, "optional sword/gfx_call_a did not use AL=12 BX=18AB")
    expect([(r["ax"] & 0xFF, r["bx"]) for r in gfx_c] == [(0x34, 0x3EA4)],
           failures, "optional shield/gfx_call_c did not use AL=34 BX=3EA4")
    expect([(r["ax"] & 0xFF, r["bx"]) for r in gfx_b] == [(0x56, 0x37A4)],
           failures, "optional spell/gfx_call_b did not use AL=56 BX=37A4")

    assert_driver_table_modes(failures)

    if failures:
        print("game bootstrap sequence oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("game bootstrap sequence oracle: boot clears, relocations, driver tables, new/saved paths, and optional music/equipment match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
