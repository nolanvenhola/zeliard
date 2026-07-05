#!/usr/bin/env python3
"""Bind exact MASM opening service calls to byte-exact decoded frame artifacts."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).parent
REPO = HERE.parents[1]
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(REPO / "3_Assembly" / "masm" / "functest"))

import opening_oracle  # noqa: E402
import opdemo_trace  # noqa: E402


EXPECTED_PIPELINE = [
    ("sar_load", "ttl3.grp"),
    ("disp_narr_chap3", None),
    ("sar_load", "nec.grp"),
    ("sar_load", "hou.grp"),
    ("gfx_draw", None),
    ("disp_game", None),
    ("sar_load", "dmaou.grp"),
    ("gfx_update", None),
]

FRAME_NAMES = [
    "ttl3_logo_bbox",
    "nec_scene_bbox",
    "opening_nec_hou_composite",
    "dmaou_scene_bbox",
]


def export_contract() -> dict:
    trace = opdemo_trace.export_trace()
    events = [e for e in trace["events"] if e["checkpoint"] == "initial_visual_pipeline"]
    cursor = 0
    evidence = []
    for service, asset in EXPECTED_PIPELINE:
        while cursor < len(events) and events[cursor]["service"] != service:
            cursor += 1
        if cursor >= len(events):
            raise RuntimeError(f"missing {service} in initial MASM visual pipeline")
        event = events[cursor]
        if asset is not None and event.get("asset") != asset:
            raise RuntimeError(f"{service} selected {event.get('asset')}, expected {asset}")
        evidence.append({
            "event_index": event["index"],
            "service": service,
            **({"asset": asset} if asset else {}),
            "regs": event["regs"],
        })
        cursor += 1

    manifest = opening_oracle.compute_manifest()
    scenarios = opening_oracle.scenario_by_name(manifest)
    frames = []
    for name in FRAME_NAMES:
        scenario = scenarios[name]
        frames.append({
            "name": name,
            "framebuffer_sha256": scenario["framebuffer_sha256"],
            "framebuffer_fnv1a64": scenario["framebuffer_fnv1a64"],
        })
    return {
        "schema": "zeliard.opdemo.frame_contract.v1",
        "source_trace_sha256": next(
            s["event_sha256"] for s in trace["segments"]
            if s["name"] == "initial_visual_pipeline"
        ),
        "service_evidence": evidence,
        "frames": frames,
        "limitations": [
            "Frame bytes are produced by the byte-exact reference decoders.",
            "MASM execution proves asset selection, order, and draw-service arguments.",
            "The external graphics driver is not yet executed inside Unicorn.",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path)
    parser.add_argument("--check", type=Path)
    args = parser.parse_args()
    encoded = json.dumps(export_contract(), indent=2) + "\n"
    if args.check:
        if encoded != args.check.read_text(encoding="utf-8"):
            print(f"VERDICT: FAIL: frame contract differs from {args.check}")
            return 1
        print(f"VERDICT: PASS: frame contract matches {args.check}")
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
