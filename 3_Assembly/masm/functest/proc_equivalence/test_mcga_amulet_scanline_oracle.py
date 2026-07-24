#!/usr/bin/env python3
"""Release-MASM oracle for the complete OPDMO ancient-prologue stream.

100OPDMO:animate_scanline decodes 31 records from CS:6FF0 and renders ten
105GDMCA:332C frames per record, followed by its 78h-frame AX=0 exit.  The
digest covers every A000/work-buffer pair, so it detects a wrong intermediate
frame even when the final clear happens to match.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent))

from harness import CODE_SEG  # noqa: E402
import test_opdemo_opening_sequence as opdmo  # noqa: E402


RECORDS, FRAMES_PER_RECORD, EXIT_FRAMES = 31, 10, 0x78
EXPECTED_TRACE = 0xB4395F092CA68BE0
EXPECTED_FINAL_VISIBLE = 0xDD14FCC6528CAB25
EXPECTED_FINAL_WORK = 0xB65F2BB82806E676


def fnv_update(value: int, data: bytes) -> int:
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def sample(harness) -> tuple[int, int]:
    visible = opdmo.fnv1a64(harness.read_vga(0, 0xFA00))
    work = opdmo.fnv1a64(bytes(harness.mu.mem_read(
        (CODE_SEG + 0x2000) << 4, 0x10000)))
    return visible, work


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--capture", action="store_true",
                        help="print release values for updating this oracle")
    args = parser.parse_args()

    harness, stubs = opdmo.setup_story_2_to_3_mcga_harness()
    opdmo.install_font_segment(harness)
    failures: list[str] = []
    stream_digest = 0xCBF29CE484222325
    si = 0x6FF0
    draws = 0

    for record in range(RECORDS):
        decoded = harness.call_function(
            opdmo.GDMCA_ANIM_FADE_TARGET,
            regs={"ds": CODE_SEG, "es": CODE_SEG, "si": si},
            stub_calls=stubs, max_steps=1_000_000)
        if decoded["stopped_reason"] != "returned_to_sentinel":
            failures.append(f"record {record}: 32C9 did not return")
            break
        si = decoded["regs_after"]["si"]
        for frame in range(FRAMES_PER_RECORD):
            result = harness.call_function(
                opdmo.GDMCA_OPDMO_ANIM_TARGETS[opdmo.ANIM_FN_DRAW_SLOT],
                regs={"ds": CODE_SEG, "es": CODE_SEG, "ax": frame,
                      "bx": 0x20, "cx": 0x5078},
                stub_calls=stubs, max_steps=1_000_000)
            if result["stopped_reason"] != "returned_to_sentinel":
                failures.append(f"record {record} frame {frame}: 332C did not return")
                break
            visible, work = sample(harness)
            stream_digest = fnv_update(stream_digest, visible.to_bytes(8, "little"))
            stream_digest = fnv_update(stream_digest, work.to_bytes(8, "little"))
            draws += 1
        if failures:
            break

    if not failures:
        for frame in range(EXIT_FRAMES):
            result = harness.call_function(
                opdmo.GDMCA_OPDMO_ANIM_TARGETS[opdmo.ANIM_FN_DRAW_SLOT],
                regs={"ds": CODE_SEG, "es": CODE_SEG, "ax": 0,
                      "bx": 0x20, "cx": 0x5078},
                stub_calls=stubs, max_steps=1_000_000)
            if result["stopped_reason"] != "returned_to_sentinel":
                failures.append(f"exit frame {frame}: 332C did not return")
                break
            visible, work = sample(harness)
            stream_digest = fnv_update(stream_digest, visible.to_bytes(8, "little"))
            stream_digest = fnv_update(stream_digest, work.to_bytes(8, "little"))
            draws += 1

    final_visible, final_work = sample(harness)
    if args.capture:
        print(f"capture trace={stream_digest:016x} final_visible={final_visible:016x} "
              f"final_work={final_work:016x} draws={draws}")
        return 0 if not failures else 1

    if draws != RECORDS * FRAMES_PER_RECORD + EXIT_FRAMES:
        failures.append(f"draw count {draws} changed")
    if stream_digest != EXPECTED_TRACE:
        failures.append(f"trace {stream_digest:016x} changed")
    if final_visible != EXPECTED_FINAL_VISIBLE:
        failures.append(f"final A000 {final_visible:016x} changed")
    if final_work != EXPECTED_FINAL_WORK:
        failures.append(f"final work {final_work:016x} changed")

    if failures:
        print("MCGA ancient-prologue stream oracle mismatches:")
        for failure in failures:
            print(f" - {failure}")
        print("VERDICT: FAIL: release-MASM complete ancient-prologue stream")
        return 1
    print("VERDICT: PASS: release-MASM complete ancient-prologue MCGA stream")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
