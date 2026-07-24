"""Release-MASM contract for 100OPDMO:char_render_proc.

The driver service at CS:[3030] is stateful, so this test intentionally locks
the OPDMO-side boundary: arguments forwarded to the service and OPDMO's own
render-state effects.  The service itself is separately exercised only from a
live driver setup.
"""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT, resolve_proc  # noqa: E402
from harness import CODE_SEG, TasmHarness  # noqa: E402


OPDMO_BIN = MASM_ROOT / "bin" / "zelres1" / "100OPDMO.bin"
LOAD_BASE = 0x6000
HEADER_SIZE = 4
DISP_NARR_CHAP4_SLOT = 0x3030
DISP_NARR_CHAP4_THUNK = 0x021E
RENDER_STATE_A = 0x653D
RENDER_STATE_B = 0x653F
VOLUME_B = 0xFF75


def word_bytes(value: int) -> bytes:
    return bytes((value & 0xFF, (value >> 8) & 0xFF))


def read_word(harness: TasmHarness, offset: int) -> int:
    data = harness.mu.mem_read((CODE_SEG << 4) + offset, 2)
    return data[0] | (data[1] << 8)


def read_byte(harness: TasmHarness, offset: int) -> int:
    return harness.mu.mem_read((CODE_SEG << 4) + offset, 1)[0]


def fixture() -> tuple[TasmHarness, int]:
    harness = TasmHarness(str(OPDMO_BIN), LOAD_BASE)
    harness.write_code(LOAD_BASE, OPDMO_BIN.read_bytes()[HEADER_SIZE:])
    harness.write_code(DISP_NARR_CHAP4_SLOT, word_bytes(DISP_NARR_CHAP4_THUNK))
    entry = LOAD_BASE + resolve_proc("opdmo", "char_render_proc") - HEADER_SIZE
    return harness, entry


def calls(result: dict) -> list[tuple[int, int, int, int]]:
    return [
        (entry["ax"] & 0xFF, (entry["ax"] >> 8) & 0xFF,
         entry["bx"], entry["cx"])
        for entry in result.get("stub_regs", [])
        if entry["ip"] == DISP_NARR_CHAP4_THUNK
    ]


def main() -> int:
    failures: list[str] = []

    glyph, entry = fixture()
    glyph.write_code(RENDER_STATE_A, word_bytes(0x0004))
    glyph.write_code(RENDER_STATE_B, bytes((0x8F,)))
    glyph.write_code(VOLUME_B, bytes((0,)))
    result = glyph.call_function(
        entry, regs={"ds": CODE_SEG, "es": CODE_SEG, "ax": ord("P")},
        stub_calls={DISP_NARR_CHAP4_THUNK: {}}, max_steps=1000)
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append("glyph case did not return")
    if calls(result) != [(ord("P"), 2, 6, 0x0090),
                         (ord("P"), 7, 4, 0x008F)]:
        failures.append(f"glyph calls {calls(result)!r} changed")
    if read_word(glyph, RENDER_STATE_A) != 0x000C:
        failures.append("glyph case did not advance render_state_a by eight")
    if read_byte(glyph, VOLUME_B) != 0x3F:
        failures.append("glyph case did not set gvar_volume_b=3F")

    space, entry = fixture()
    space.write_code(RENDER_STATE_A, word_bytes(0x0010))
    space.write_code(RENDER_STATE_B, bytes((0x20,)))
    space.write_code(VOLUME_B, bytes((0xA5,)))
    result = space.call_function(
        entry, regs={"ds": CODE_SEG, "es": CODE_SEG, "ax": ord(" ")},
        stub_calls={DISP_NARR_CHAP4_THUNK: {}}, max_steps=1000)
    if calls(result) != [(ord(" "), 2, 0x12, 0x0021),
                         (ord(" "), 7, 0x10, 0x0020)]:
        failures.append(f"space calls {calls(result)!r} changed")
    if read_word(space, RENDER_STATE_A) != 0x0018:
        failures.append("space case did not advance render_state_a by eight")
    if read_byte(space, VOLUME_B) != 0xA5:
        failures.append("space case changed gvar_volume_b")

    command, entry = fixture()
    command.write_code(RENDER_STATE_A, word_bytes(0x1234))
    command.write_code(RENDER_STATE_B, bytes((0x50,)))
    command.write_code(0x7000, bytes((1, 0x17)))
    result = command.call_function(
        entry, regs={"ds": CODE_SEG, "es": CODE_SEG, "ax": 0x00FF,
                     "si": 0x7000},
        stub_calls={DISP_NARR_CHAP4_THUNK: {}}, max_steps=1000)
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append("animation command did not return")
    if calls(result):
        failures.append("animation command unexpectedly called chapter-4 service")
    if read_word(command, RENDER_STATE_A) != 0x00B8:
        failures.append("animation command render_state_a was not 17h*8")
    if read_byte(command, RENDER_STATE_B) != 0x5A:
        failures.append("animation command render_state_b was not incremented by 10h")

    if failures:
        print("OPDMO char_render_proc oracle mismatches:")
        for failure in failures:
            print(" -", failure)
        print("VERDICT: FAIL: release-MASM char_render_proc")
        return 1
    print("VERDICT: PASS: release-MASM char_render_proc boundary")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
