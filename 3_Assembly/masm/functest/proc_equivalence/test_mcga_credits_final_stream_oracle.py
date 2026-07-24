"""Long-form release-MASM oracle for the complete OPDMO credits stream."""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent))

from harness import CODE_SEG  # noqa: E402
import test_opdemo_opening_sequence as opdmo  # noqa: E402


EXPECTED_RECORD_51_VISIBLE = 0x597DE699E50D0FB3
EXPECTED_RECORD_51_WORK = 0xAA34C8574162890A
EXPECTED_EXIT_VISIBLE = 0xDD14FCC6528CAB25
EXPECTED_EXIT_WORK = 0xD6C423A74583C8E0


def hashes(harness) -> tuple[int, int]:
    return (
        opdmo.fnv1a64(harness.read_vga(0, 0xFA00)),
        opdmo.fnv1a64(bytes(harness.mu.mem_read(
            (CODE_SEG + 0x2000) << 4, 0x10000))),
    )


def main() -> int:
    harness, stubs = opdmo.setup_story_2_to_3_mcga_harness()
    opdmo.install_font_segment(harness)
    failures: list[str] = []
    si = 0x742F

    for record in range(52):
        decoded = harness.call_function(
            opdmo.GDMCA_ANIM_FADE_TARGET,
            regs={"ds": CODE_SEG, "es": CODE_SEG, "si": si},
            stub_calls=stubs, max_steps=1_000_000)
        if decoded["stopped_reason"] != "returned_to_sentinel":
            failures.append(f"record {record}: 32C9 did not return")
            break
        si = decoded["regs_after"]["si"]
        for frame in range(10):
            result = harness.call_function(
                opdmo.GDMCA_OPDMO_ANIM_TARGETS[opdmo.ANIM_FN_DRAW_SLOT],
                regs={"ds": CODE_SEG, "es": CODE_SEG, "ax": frame,
                      "bx": 0x20, "cx": 0x5078},
                stub_calls=stubs, max_steps=1_000_000)
            if result["stopped_reason"] != "returned_to_sentinel":
                failures.append(f"record {record} frame {frame}: 332C did not return")
                break
        if failures:
            break

    visible, work = hashes(harness)
    if visible != EXPECTED_RECORD_51_VISIBLE:
        failures.append(f"record 51 frame 9 A000 {visible:016x} changed")
    if work != EXPECTED_RECORD_51_WORK:
        failures.append(f"record 51 frame 9 work {work:016x} changed")

    if not failures:
        for frame in range(120):
            result = harness.call_function(
                opdmo.GDMCA_OPDMO_ANIM_TARGETS[opdmo.ANIM_FN_DRAW_SLOT],
                regs={"ds": CODE_SEG, "es": CODE_SEG, "ax": 0,
                      "bx": 0x20, "cx": 0x5078},
                stub_calls=stubs, max_steps=1_000_000)
            if result["stopped_reason"] != "returned_to_sentinel":
                failures.append(f"exit frame {frame}: 332C did not return")
                break

    visible, work = hashes(harness)
    if visible != EXPECTED_EXIT_VISIBLE:
        failures.append(f"exit frame 119 A000 {visible:016x} changed")
    if work != EXPECTED_EXIT_WORK:
        failures.append(f"exit frame 119 work {work:016x} changed")

    if failures:
        print("MCGA complete credits-stream oracle mismatches:")
        for failure in failures:
            print(" -", failure)
        print("VERDICT: FAIL: release-MASM complete credits MCGA stream")
        return 1
    print("VERDICT: PASS: release-MASM complete credits MCGA stream")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
