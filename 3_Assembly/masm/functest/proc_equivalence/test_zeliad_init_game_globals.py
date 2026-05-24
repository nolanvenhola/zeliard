#!/usr/bin/env python3
"""Runtime oracle for zeliad.asm's pre-game global initialization block."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from harness import CODE_SEG, DATA_SEG, TasmHarness  # noqa: E402
from masm_image import materialize_mz_image  # noqa: E402


MASM_ROOT = HERE.parents[1]
ZELIAD_BIN = materialize_mz_image(MASM_ROOT / "bin" / "zeliad.exe",
                                  "masm_zeliad")

INIT_GAME_GLOBALS = 0x00F4
STOP_BEFORE_LOAD_DRIVER_FILES = 0x0205

OFF_CMDLINE_SAVEFILE = 0x0869
OFF_GAME_ENTRY_SEG = 0x08AF
OFF_SAVED_INT08 = 0x08B1
OFF_SAVED_INT09 = 0x08B5
OFF_GRAPHICS_MODE = 0x08E7
OFF_MT32_ENABLED = 0x08E8
OFF_JOYSTICK_ENABLED = 0x08E9


def seed_word(h: TasmHarness, offset: int, value: int) -> None:
    h.write_code(offset, [value & 0xFF, (value >> 8) & 0xFF])


def read_globals(h: TasmHarness, offset: int, length: int) -> bytes:
    return h.read_data(offset, length)


def read_byte(h: TasmHarness, offset: int) -> int:
    return read_globals(h, offset, 1)[0]


def read_word(h: TasmHarness, offset: int) -> int:
    raw = read_globals(h, offset, 2)
    return raw[0] | (raw[1] << 8)


def seed_case(h: TasmHarness, save_name: bytes, graphics_mode: int,
              mt32_enabled: int, joystick_enabled: int) -> None:
    seed_word(h, OFF_GAME_ENTRY_SEG, DATA_SEG)
    seed_word(h, OFF_SAVED_INT08, 0x1111)
    seed_word(h, OFF_SAVED_INT08 + 2, 0x2222)
    seed_word(h, OFF_SAVED_INT09, 0x3333)
    seed_word(h, OFF_SAVED_INT09 + 2, 0x4444)
    h.write_code(OFF_CMDLINE_SAVEFILE, save_name + b"\x00")
    h.write_code(OFF_GRAPHICS_MODE, [graphics_mode & 0xFF])
    h.write_code(OFF_MT32_ENABLED, [mt32_enabled & 0xFF])
    h.write_code(OFF_JOYSTICK_ENABLED, [joystick_enabled & 0xFF])


def run_case(save_name: bytes, graphics_mode: int, mt32_enabled: int,
             joystick_enabled: int) -> TasmHarness:
    h = TasmHarness(ZELIAD_BIN, 0x0000)
    h.write_code(STOP_BEFORE_LOAD_DRIVER_FILES, [0xC3])
    seed_case(h, save_name, graphics_mode, mt32_enabled, joystick_enabled)
    result = h.call_function(INIT_GAME_GLOBALS, regs={"ds": CODE_SEG})
    if result["stopped_reason"] != "returned_to_sentinel":
        raise AssertionError(f"{save_name!r}: {result['stopped_reason']}")
    return h


def expect_eq(failures: list[str], label: str, got: int | bytes, want: int | bytes) -> None:
    if got != want:
        failures.append(f"{label}: got={got!r} want={want!r}")


def check_common_globals(failures: list[str], h: TasmHarness, graphics_mode: int,
                         mt32_enabled: int, joystick_enabled: int) -> None:
    expect_eq(failures, "chunk_load_fn", read_word(h, 0xFF00), 0x02D9)
    expect_eq(failures, "chunk_load_seg", read_word(h, 0xFF02), CODE_SEG)
    expect_eq(failures, "old_int08_ofs", read_word(h, 0xFF04), 0x1111)
    expect_eq(failures, "old_int08_seg", read_word(h, 0xFF06), 0x2222)
    expect_eq(failures, "old_int09_ofs", read_word(h, 0xFF79), 0x3333)
    expect_eq(failures, "old_int09_seg", read_word(h, 0xFF7B), 0x4444)
    expect_eq(failures, "gvar_enable_all", read_byte(h, 0xFF26), 0xFF)
    expect_eq(failures, "gvar_key_released", read_byte(h, 0xFF09), 0xFF)
    expect_eq(failures, "gvar_save_flag", read_byte(h, 0xFF33), 0x05)
    expect_eq(failures, "gvar_last_key", read_byte(h, 0xFF0A), joystick_enabled)
    expect_eq(failures, "gvar_game_phase", read_byte(h, 0xFF15), mt32_enabled)
    expect_eq(failures, "gvar_gfx_mode", read_byte(h, 0xFF14), graphics_mode)
    expect_eq(failures, "gvar_game_seg", read_word(h, 0xFF2C), DATA_SEG + 0x1000)

    zero_offsets = [
        0xFF08, 0xFF0B, 0xFF16, 0xFF17, 0xFF18, 0xFF19, 0xFF1D, 0xFF1E,
        0xFF1F, 0xFF20, 0xFF27, 0xFF28, 0xFF34, 0xFF38, 0xFF39, 0xFF3A,
        0xFF3B, 0xFF3C, 0xFF40, 0xFF42, 0xFF43, 0xFF74, 0xFF75, 0xFF78,
    ]
    for offset in zero_offsets:
        expect_eq(failures, f"zero_{offset:04X}", read_byte(h, offset), 0)


def main() -> int:
    failures: list[str] = []

    h = run_case(b"hero.USR", 4, 0xFF, 0xFF)
    check_common_globals(failures, h, 4, 0xFF, 0xFF)
    expect_eq(failures, "save_name_upper_until_dot",
              read_globals(h, 0xFF6C, 8), b"HERO\x00\x00\x00\x00")

    h = run_case(b"MiXeD.USR", 1, 0x00, 0x00)
    check_common_globals(failures, h, 1, 0x00, 0x00)
    expect_eq(failures, "save_name_mixed_upper",
              read_globals(h, 0xFF6C, 8), b"MIXED\x00\x00\x00")

    h = run_case(b"abcdefghijk", 5, 0xFF, 0x00)
    check_common_globals(failures, h, 5, 0xFF, 0x00)
    expect_eq(failures, "save_name_8byte_clamp",
              read_globals(h, 0xFF6C, 8), b"ABCDEFGH")

    if failures:
        print("zeliad init-global oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("zeliad init-global oracle: pre-game globals, flags, vectors, game seg, and save-name copy match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
