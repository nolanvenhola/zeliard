#!/usr/bin/env python3
"""Export the exact MASM ancient-prologue animate_scanline protocol."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).parent
REPO = HERE.parents[1]
sys.path.insert(0, str(REPO / "3_Assembly" / "masm" / "functest"))

import opdemo_trace  # noqa: E402


def read_entry(source: bytes, runtime_si: int) -> dict:
    pos = 4 + runtime_si - 0x6000
    start = pos
    while source[pos] not in (0x0D, 0xFF):
        pos += 1
    terminator = source[pos]
    raw = source[start:pos]
    return {
        "runtime_si": f"{runtime_si:04X}",
        "text": raw.decode("ascii"),
        "terminator": f"{terminator:02X}",
    }


def export_segment(trace: dict, source: bytes, checkpoint: str) -> dict:
    events = [
        event for event in trace["events"]
        if event["checkpoint"] == checkpoint
    ]
    fades = [event for event in events if event["service"] == "anim_fade"]
    draws = [event for event in events if event["service"] == "anim_draw"]
    waits = [event for event in events if event["service"] == "timer_wait"]
    entries = [read_entry(source, int(event["regs"]["si"], 16)) for event in fades]
    entry_draw_count = len(fades) * 10
    return {
        "source_trace_sha256": next(
            segment["event_sha256"] for segment in trace["segments"]
            if segment["name"] == checkpoint
        ),
        "wipe": {
            "count": sum(event["service"] == "anim_wipe" for event in events),
            "bx": events[0]["regs"]["bx"],
            "cx": events[0]["regs"]["cx"],
        },
        "entries": entries,
        "entry_count": len(entries),
        "entry_draw_count": entry_draw_count,
        "entry_draw_al": [int(event["regs"]["ax"], 16) & 0xFF for event in draws[:10]],
        "exit_draw_count": len(draws) - entry_draw_count,
        "exit_draw_al_values": sorted({
            int(event["regs"]["ax"], 16) & 0xFF for event in draws[entry_draw_count:]
        }),
        "draw_bx_values": sorted({event["regs"]["bx"] for event in draws}),
        "draw_cx_values": sorted({event["regs"]["cx"] for event in draws}),
        "wait_count": len(waits),
        "wait_al_values": sorted({
            int(event["regs"]["ax"], 16) & 0xFF for event in waits
        }),
        "entries_sha256": hashlib.sha256(
            b"\x00".join(entry["text"].encode("ascii") for entry in entries)
        ).hexdigest(),
    }


def export_contract() -> dict:
    trace = opdemo_trace.export_trace()
    source = (REPO / "3_Assembly" / "masm" / "bin" / "zelres1" / "100OPDMO.bin").read_bytes()
    return {
        "schema": "zeliard.opdemo.scanline_contract.v2",
        "ancient_prologue": export_segment(
            trace, source, "ancient_prologue_scanline"
        ),
        "staff_credits": export_segment(trace, source, "credits_scroll"),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path)
    parser.add_argument("--check", type=Path)
    args = parser.parse_args()
    encoded = json.dumps(export_contract(), indent=2) + "\n"
    if args.check:
        if encoded != args.check.read_text(encoding="utf-8"):
            print(f"VERDICT: FAIL: scanline contract differs from {args.check}")
            return 1
        print(f"VERDICT: PASS: scanline contract matches {args.check}")
        return 0
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
        print(f"wrote {args.output}")
    else:
        print(encoded, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
