#!/usr/bin/env python3
"""Runtime probes for zeliad.asm's RESOURCE.CFG parser helpers.

These procs are part of the DOS loader, not gameplay chunks. They are still
good oracle targets because they are pure enough to run directly: they operate
on zeliad's own CS data buffer and return without DOS/BIOS calls for valid
inputs.
"""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from harness import CODE_SEG, TasmHarness  # noqa: E402
from masm_image import materialize_mz_image  # noqa: E402


MASM_ROOT = HERE.parents[1]
ZELIAD_BIN = materialize_mz_image(MASM_ROOT / "bin" / "zeliad.exe",
                                  "masm_zeliad")

LOAD_BASE = 0x0000

PARSE_GRAPHICS_MODE = 0x03CC
PARSE_MUSIC_DRIVER = 0x0443
PARSE_JOYSTICK_NAME = 0x047C
PARSE_JOYSTICK_ENABLE = 0x0493

OFF_MUSIC_DRIVER_NAME = 0x088B
OFF_JOYSTICK_DRIVER_NAME = 0x089D
OFF_GRAPHICS_MODE = 0x08E7
OFF_MT32_ENABLED = 0x08E8
OFF_JOYSTICK_ENABLED = 0x08E9
OFF_CFG_LINE_LENGTH = 0x08EA
OFF_CFG_LINE_BUFFER = 0x08EB


def read_code(h: TasmHarness, offset: int, length: int) -> bytes:
    return bytes(h.mu.mem_read((CODE_SEG << 4) + offset, length))


def read_c_string(h: TasmHarness, offset: int, limit: int = 32) -> str:
    raw = read_code(h, offset, limit)
    return raw.split(b"\x00", 1)[0].decode("ascii")


def seed_cfg_line(h: TasmHarness, line: str) -> None:
    raw = line.encode("ascii")
    h.write_code(OFF_CFG_LINE_LENGTH, [len(raw)])
    h.write_code(OFF_CFG_LINE_BUFFER, raw + b"\x00")


def run_parser(proc: int, line: str) -> TasmHarness:
    h = TasmHarness(ZELIAD_BIN, LOAD_BASE)
    seed_cfg_line(h, line)
    result = h.call_function(proc)
    if result["stopped_reason"] != "returned_to_sentinel":
        raise AssertionError(f"{line}: {result['stopped_reason']}")
    return h


def main() -> int:
    failures: list[str] = []

    graphics_cases = {
        "video:ega": 0,
        "video:cga": 1,
        "video:cga2": 2,
        "video:hgc": 3,
        "video:mcga": 4,
        "video:tga": 5,
    }
    for line, expected in graphics_cases.items():
        h = run_parser(PARSE_GRAPHICS_MODE, line)
        actual = read_code(h, OFF_GRAPHICS_MODE, 1)[0]
        if actual != expected:
            failures.append(f"{line}: graphics_mode {actual:#04x} != {expected:#04x}")

    h = run_parser(PARSE_MUSIC_DRIVER, "music:mscmt.drv")
    if read_c_string(h, OFF_MUSIC_DRIVER_NAME, 16) != "mscmt.drv":
        failures.append("music:mscmt.drv did not copy driver name")
    if read_code(h, OFF_MT32_ENABLED, 1)[0] != 0xFF:
        failures.append("music:mscmt.drv did not set mt32 flag")

    h = run_parser(PARSE_MUSIC_DRIVER, "music:mscstd.drv")
    if read_c_string(h, OFF_MUSIC_DRIVER_NAME, 16) != "mscstd.drv":
        failures.append("music:mscstd.drv did not copy driver name")
    if read_code(h, OFF_MT32_ENABLED, 1)[0] != 0x00:
        failures.append("music:mscstd.drv unexpectedly set mt32 flag")

    h = run_parser(PARSE_JOYSTICK_NAME, "joy:abcdefghijklmnopqr")
    if read_c_string(h, OFF_JOYSTICK_DRIVER_NAME, 16) != "abcdefghijklmno":
        failures.append("joystick driver name was not clamped to 15 bytes")

    h = run_parser(PARSE_JOYSTICK_ENABLE, "joy:yes")
    if read_code(h, OFF_JOYSTICK_ENABLED, 1)[0] != 0xFF:
        failures.append("joy:yes did not set joystick_enabled")

    h = run_parser(PARSE_JOYSTICK_ENABLE, "joy:no")
    if read_code(h, OFF_JOYSTICK_ENABLED, 1)[0] != 0x00:
        failures.append("joy:no did not clear joystick_enabled")

    if failures:
        print("zeliad config parser oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("zeliad config parser oracle: graphics, music, joystick-name, joystick-enable scenarios match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
