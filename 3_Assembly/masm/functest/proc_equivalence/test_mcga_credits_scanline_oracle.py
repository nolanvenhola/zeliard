"""Release-MASM oracle for early and mid-stream 100OPDMO credits records.

``credits_scroll_display`` starts its 52-record stream at 100OPDMO:742F.
This locks the real 105GDMCA 32C9 decode and early/mid-stream 332C checkpoints before
the browser-facing C runtime is allowed to claim credits parity.
"""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent))

from harness import CODE_SEG  # noqa: E402
import test_opdemo_opening_sequence as opdmo  # noqa: E402


EXPECTED_VISIBLE = (
    0xDD14FCC6528CAB25, 0x8ED187DBCE325DE5,
    0xAA89D2C673E1D5F5, 0xD39904DC673281E3,
    0xE7AD1871E6F07705, 0xDF32DD85341A3283,
    0x5490C643A8E61F23, 0xFD082378D7EBDBF5,
    0x2BE85E085AAB6833, 0x5B9B26AB19E52E33,
    0x227C7FA8847CF433, 0xE6D2607FE9F73895,
    0xA09CA3EC4A3B2FF5, 0x4599526D6152E4D3,
    0xD0314AD8E0FDA975, 0xB1D9D1AC98F9F645,
    0x8741B15435518F63, 0xDEFC1C2BF57895B5,
    0xF57FC27ACE0965B5, 0x00E1AF4E66AA35B5,
)
EXPECTED_WORK = (
    0xEAA64BA4798DE35F, 0xEC196A3C6381710B,
    0x9C180A02A651E692, 0xD87A68999DD94BBD,
    0xEF6FD6E5B8530874, 0x1F5DB548A6E3C4A0,
    0x8AE1B4E0A15995F9, 0x7CEAD5602081DFC8,
    0x0C8CCA4828064EC8, 0x5D9D1B8D1FF5BDC8,
    0xC68A2E759A01C007, 0x359C33546C31F279,
    0x8191A96368EE451C, 0x24663034F9415A87,
    0xAEB577AF2D275F31, 0xE4A83A99EA068036,
    0x8C89B84345D482A5, 0xFD52A86D10D202A5,
    0x41A3A6056F4F82A5, 0x1648880DE14D02A5,
)


def main() -> int:
    harness, stubs = opdmo.setup_story_2_to_3_mcga_harness()
    opdmo.install_font_segment(harness)
    failures: list[str] = []
    si = 0x742F
    for record in range(27):
        decoded = harness.call_function(
            opdmo.GDMCA_ANIM_FADE_TARGET,
            regs={"ds": CODE_SEG, "es": CODE_SEG, "si": si},
            stub_calls=stubs, max_steps=1_000_000)
        if decoded["stopped_reason"] != "returned_to_sentinel":
            failures.append(f"105GDMCA:32C9 did not decode credits record {record}")
        si = decoded["regs_after"]["si"]
        for frame in range(10):
            index = record * 10 + frame
            result = harness.call_function(
                opdmo.GDMCA_OPDMO_ANIM_TARGETS[opdmo.ANIM_FN_DRAW_SLOT],
                regs={"ds": CODE_SEG, "es": CODE_SEG, "ax": frame,
                      "bx": 0x20, "cx": 0x5078},
                stub_calls=stubs, max_steps=1_000_000)
            visible = opdmo.fnv1a64(harness.read_vga(0, 0xFA00))
            work = opdmo.fnv1a64(bytes(harness.mu.mem_read(
                (CODE_SEG + 0x2000) << 4, 0x10000)))
            if result["stopped_reason"] != "returned_to_sentinel":
                failures.append(f"frame {index}: 105GDMCA:332C did not return")
            if index < len(EXPECTED_VISIBLE) and visible != EXPECTED_VISIBLE[index]:
                failures.append(f"frame {index}: A000 {visible:016x} changed")
            if index < len(EXPECTED_WORK) and work != EXPECTED_WORK[index]:
                failures.append(f"frame {index}: work {work:016x} changed")
            if index == 139 and visible != 0xE9B957AA11F8ECB3:
                failures.append(f"frame 139: A000 {visible:016x} changed")
            if index == 139 and work != 0x3BBA3D5D2B6FC1B8:
                failures.append(f"frame 139: work {work:016x} changed")
            if index == 269 and visible != 0x7EC968257BB31D13:
                failures.append(f"frame 269: A000 {visible:016x} changed")
            if index == 269 and work != 0x8AE7AB4BB782BCAE:
                failures.append(f"frame 269: work {work:016x} changed")

    if failures:
        print("MCGA credits scanline oracle mismatches:")
        for failure in failures:
            print(" -", failure)
        print("VERDICT: FAIL: release-MASM credits first-record oracle")
        return 1
    print("VERDICT: PASS: release-MASM credits early/mid-stream MCGA oracle")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
