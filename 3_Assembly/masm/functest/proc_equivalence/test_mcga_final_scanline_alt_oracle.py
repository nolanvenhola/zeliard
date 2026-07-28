#!/usr/bin/env python3
"""Release-MASM oracle for OPDMO animate_scanline_alt at runtime 7338h."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent))

from harness import CODE_SEG  # noqa: E402
import test_opdemo_opening_sequence as opdmo  # noqa: E402


RECORDS, FRAMES_PER_RECORD, EXIT_FRAMES = 7, 10, 0xA0
EXPECTED_TRACE = 0x89EB5E37FB8C8177
EXPECTED_FINAL_VISIBLE = 0xDD14FCC6528CAB25
EXPECTED_FINAL_WORK = 0x9609F325A52F2190
CHECKPOINT_DRAWS = (10, 30, 60, 70)
EXPECTED_CHECKPOINTS = {
    10: (0x84DB69BD1AF40875, 0xD4C47EF84D43FF5D),
    30: (0x7921BCCDD8C1E423, 0xE5D43A94A1E16B3E),
    60: (0xB2BC3E6F10A17715, 0x89CF96916920FE73),
    70: (0x675A3CCD9E0E5715, 0x75B3B1D9B3713A73),
}


def fnv_update(value: int, data: bytes) -> int:
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def sample(harness) -> tuple[int, int]:
    return (
        opdmo.fnv1a64(harness.read_vga(0, 0xFA00)),
        opdmo.fnv1a64(bytes(harness.mu.mem_read(
            (CODE_SEG + 0x2000) << 4, 0x10000))),
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--capture", action="store_true")
    args = parser.parse_args()
    harness, stubs = opdmo.setup_story_2_to_3_mcga_harness()
    opdmo.install_font_segment(harness)
    si = opdmo.ANIM_FADE_TBL_SCENE
    digest = 0xCBF29CE484222325
    draws = 0
    checkpoints: dict[int, tuple[int, int]] = {}
    failures: list[str] = []

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
                      "bx": 0x0014, "cx": 0x50A0},
                stub_calls=stubs, max_steps=1_000_000)
            if result["stopped_reason"] != "returned_to_sentinel":
                failures.append(f"record {record} frame {frame}: 332C did not return")
                break
            visible, work = sample(harness)
            digest = fnv_update(digest, visible.to_bytes(8, "little"))
            digest = fnv_update(digest, work.to_bytes(8, "little"))
            draws += 1
            if draws in CHECKPOINT_DRAWS:
                checkpoints[draws] = (visible, work)
        if failures:
            break

    if not failures:
        for frame in range(EXIT_FRAMES):
            result = harness.call_function(
                opdmo.GDMCA_OPDMO_ANIM_TARGETS[opdmo.ANIM_FN_DRAW_SLOT],
                regs={"ds": CODE_SEG, "es": CODE_SEG, "ax": 0,
                      "bx": 0x0014, "cx": 0x50A0},
                stub_calls=stubs, max_steps=1_000_000)
            if result["stopped_reason"] != "returned_to_sentinel":
                failures.append(f"exit frame {frame}: 332C did not return")
                break
            visible, work = sample(harness)
            digest = fnv_update(digest, visible.to_bytes(8, "little"))
            digest = fnv_update(digest, work.to_bytes(8, "little"))
            draws += 1

    final_visible, final_work = sample(harness)
    if args.capture:
        for checkpoint_draws in CHECKPOINT_DRAWS:
            visible, work = checkpoints[checkpoint_draws]
            print(f"capture draw={checkpoint_draws} visible={visible:016x} "
                  f"work={work:016x}")
        print(f"capture trace={digest:016x} final_visible={final_visible:016x} "
              f"final_work={final_work:016x} draws={draws}")
        return 0 if not failures else 1

    if draws != RECORDS * FRAMES_PER_RECORD + EXIT_FRAMES:
        failures.append(f"draw count {draws} changed")
    for checkpoint_draws, expected in EXPECTED_CHECKPOINTS.items():
        if checkpoints.get(checkpoint_draws) != expected:
            failures.append(
                f"draw {checkpoint_draws} checkpoint "
                f"{checkpoints.get(checkpoint_draws)} changed")
    if digest != EXPECTED_TRACE:
        failures.append(f"trace {digest:016x} changed")
    if final_visible != EXPECTED_FINAL_VISIBLE:
        failures.append(f"final A000 {final_visible:016x} changed")
    if final_work != EXPECTED_FINAL_WORK:
        failures.append(f"final work {final_work:016x} changed")
    if failures:
        print("MCGA final scanline-alt stream oracle mismatches:")
        for failure in failures:
            print(f" - {failure}")
        print("VERDICT: FAIL: release-MASM final scanline-alt stream")
        return 1
    print("VERDICT: PASS: release-MASM final scanline-alt MCGA stream")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
