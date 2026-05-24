#!/usr/bin/env python3
"""Runtime probes for zeliad.asm PSP command-line save-file parsing."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from harness import CODE_SEG, DATA_SEG, TasmHarness  # noqa: E402
from masm_image import materialize_mz_image  # noqa: E402


MASM_ROOT = HERE.parents[1]
ZELIAD_BIN = materialize_mz_image(MASM_ROOT / "bin" / "zeliad.exe",
                                  "masm_zeliad")

PARSE_COMMAND_LINE = 0x05F9

PSP_CMD_SIZE = 0x80
PSP_CMD_LINE = 0x81

OFF_CMDLINE_SAVEFILE = 0x0869
OFF_HAS_SAVEFILE = 0x08C1


def read_code(h: TasmHarness, offset: int, length: int) -> bytes:
    return bytes(h.mu.mem_read((CODE_SEG << 4) + offset, length))


def read_c_string(h: TasmHarness, offset: int, limit: int = 40) -> str:
    raw = read_code(h, offset, limit)
    return raw.split(b"\x00", 1)[0].decode("ascii")


def run_case(command_tail: bytes) -> TasmHarness:
    h = TasmHarness(ZELIAD_BIN, 0x0000)
    h.write_data(PSP_CMD_SIZE, [len(command_tail)])
    h.write_data(PSP_CMD_LINE, command_tail)
    result = h.call_function(PARSE_COMMAND_LINE, regs={"ds": CODE_SEG, "es": DATA_SEG})
    if result["stopped_reason"] != "returned_to_sentinel":
        raise AssertionError(f"{command_tail!r}: {result['stopped_reason']}")
    return h


def main() -> int:
    failures: list[str] = []

    h = run_case(b"")
    if read_code(h, OFF_HAS_SAVEFILE, 1)[0] != 0x00:
        failures.append("empty command tail set has_savefile")
    if read_c_string(h, OFF_CMDLINE_SAVEFILE) != "":
        failures.append("empty command tail wrote save filename")

    h = run_case(b"   ")
    if read_code(h, OFF_HAS_SAVEFILE, 1)[0] != 0x00:
        failures.append("spaces-only command tail set has_savefile")

    h = run_case(b"  hero")
    if read_code(h, OFF_HAS_SAVEFILE, 1)[0] != 0xFF:
        failures.append("leading-space command tail did not set has_savefile")
    if read_c_string(h, OFF_CMDLINE_SAVEFILE) != "hero.USR":
        failures.append("leading-space command tail did not append .USR")

    h = run_case(b"foo bar")
    if read_c_string(h, OFF_CMDLINE_SAVEFILE) != "foobar.USR":
        failures.append("embedded spaces were not skipped/compacted as assembly does")

    h = run_case(b"MiXeD")
    if read_c_string(h, OFF_CMDLINE_SAVEFILE) != "MiXeD.USR":
        failures.append("parse_command_line unexpectedly changed argument case")

    if failures:
        print("zeliad command-line oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("zeliad command-line oracle: empty, spaces, .USR append, space compaction, and case preservation match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
