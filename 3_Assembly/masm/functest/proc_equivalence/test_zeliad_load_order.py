#!/usr/bin/env python3
"""Runtime oracle for zeliad.asm's driver/file load order."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from harness import CODE_SEG, TasmHarness  # noqa: E402
from masm_image import materialize_mz_image  # noqa: E402


MASM_ROOT = HERE.parents[1]
ZELIAD_BIN = materialize_mz_image(MASM_ROOT / "bin" / "zeliad.exe",
                                  "masm_zeliad")

LOAD_DRIVER_FILES = 0x0205
STOP_BEFORE_INT_INSTALL = 0x0264
LOAD_DRIVER_FILE = 0x04EF

OFF_GAME_ENTRY_SEG = 0x08AF
OFF_HAS_SAVEFILE = 0x08C1
OFF_CMDLINE_SAVEFILE = 0x0869
OFF_GRAPHICS_MODE = 0x08E7
OFF_MUSIC_DRIVER_NAME = 0x088B
OFF_JOYSTICK_DRIVER_NAME = 0x089D

GAME_ENTRY_SEG = 0x3000


def write_code_word(h: TasmHarness, offset: int, value: int) -> None:
    h.write_code(offset, [value & 0xFF, (value >> 8) & 0xFF])


def write_c_string(h: TasmHarness, offset: int, value: str, cap: int) -> None:
    raw = value.encode("ascii")
    if len(raw) >= cap:
        raise ValueError(value)
    h.write_code(offset, raw + b"\x00")


def read_code(h: TasmHarness, offset: int, length: int) -> bytes:
    return bytes(h.mu.mem_read((CODE_SEG << 4) + offset, length))


def read_entry(h: TasmHarness, di: int) -> tuple[int, str]:
    load_ofs = int.from_bytes(read_code(h, di, 2), "little")
    raw = read_code(h, di + 2, 32)
    filename = raw.split(b"\x00", 1)[0].decode("ascii")
    return load_ofs, filename


def run_load_order(graphics_mode: int, has_savefile: bool) -> list[tuple[int, int, int, str]]:
    h = TasmHarness(ZELIAD_BIN, 0x0000)
    h.write_code(STOP_BEFORE_INT_INSTALL, [0xC3])
    write_code_word(h, OFF_GAME_ENTRY_SEG, GAME_ENTRY_SEG)
    h.write_code(OFF_HAS_SAVEFILE, [0xFF if has_savefile else 0x00])
    h.write_code(OFF_GRAPHICS_MODE, [graphics_mode])
    write_c_string(h, OFF_CMDLINE_SAVEFILE, "CUSTOM.USR", 32)
    write_c_string(h, OFF_MUSIC_DRIVER_NAME, "mscstd.drv", 16)
    write_c_string(h, OFF_JOYSTICK_DRIVER_NAME, "joydrv.bin", 16)

    result = h.call_function(LOAD_DRIVER_FILES, stub_calls={LOAD_DRIVER_FILE: {}})
    if result["stopped_reason"] != "returned_to_sentinel":
        raise AssertionError(result["stopped_reason"])
    loads: list[tuple[int, int, int, str]] = []
    for regs in result["stub_regs"]:
        load_ofs, filename = read_entry(h, regs["di"])
        loads.append((regs["es"], regs["di"], load_ofs, filename))
    return loads


def expect_eq(failures: list[str], label: str, got, want) -> None:
    if got != want:
        failures.append(f"{label}: got={got!r} want={want!r}")


def main() -> int:
    failures: list[str] = []
    gfx_cases = [
        (0, "gmega.bin"),
        (1, "gmcga.bin"),
        (2, "gmcga.bin"),
        (3, "gmhgc.bin"),
        (4, "gmmcga.bin"),
        (5, "gmtga.bin"),
    ]

    for mode, gfx_name in gfx_cases:
        loads = run_load_order(mode, has_savefile=False)
        expected = [
            (GAME_ENTRY_SEG, 0x085A, 0x0000, "stdply.bin"),
            (GAME_ENTRY_SEG, 0x0806, 0x0100, "stick.bin"),
            (GAME_ENTRY_SEG, 0x084F, 0xA000, "game.bin"),
            (GAME_ENTRY_SEG, {0: 0x0812, 1: 0x081E, 2: 0x081E,
                              3: 0x082A, 4: 0x0836, 5: 0x0843}[mode],
             0x2000, gfx_name),
            (GAME_ENTRY_SEG + 0x0FF0, 0x0889, 0x0100, "mscstd.drv"),
            (GAME_ENTRY_SEG + 0x0FF0, 0x089B, 0x1100, "joydrv.bin"),
        ]
        expect_eq(failures, f"mode_{mode}_load_order", loads, expected)

    loads = run_load_order(4, has_savefile=True)
    expect_eq(failures, "savefile_first_entry", loads[0],
              (GAME_ENTRY_SEG, 0x0867, 0x0000, "CUSTOM.USR"))

    if failures:
        print("zeliad load-order oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("zeliad load-order oracle: MASM loader entries resolve to the logical file/offset plan")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
