#!/usr/bin/env python3
"""Compare a C opening service trace with semantic fields from the MASM trace.

MASM is the sole behavioral authority.  The candidate trace is diagnostic
output only; this tool deliberately derives its expected stream directly from
the checked MASM trace artifact.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from dataclasses import dataclass


CHECKPOINTS = {
    "title_asset_reload",
    "title_display_handoff",
    "opening_next_scene",
    "trans_exit_to_story",
    "post_title_story_setup",
    "post_title_hime_transition",
    "post_title_dmaou_transition",
    "post_title_apparition_overlay",
    "post_title_apparition_remove_isi",
    "post_title_isi_reveal",
    "post_title_yuu_setup",
    "post_title_yuu_split",
    "post_title_maop_setup",
    "post_title_yuu2_setup",
    "post_title_final_scene",
}

FIELDS = {
    "jashiin_speech": ("al", "bx", "cx"),
    "sar_load": ("al", "di"),
    "decode_rle_to_es_di": ("si", "di"),
    "gfx_mode": ("al", "bx", "cx"),
    "gfx_palette": ("ax",),
    "disp_drv_seg_3": ("ax", "si"),
    "timer_wait": ("al",),
    "gfx_update": ("al", "bx", "cx", "di"),
    "disp_narr_chap3": ("bx", "cx", "di"),
    "disp_narr_open": ("si",),
    "gfx_init": (),
    "credits_scroll_display": (),
    "decompress_image": ("si", "di"),
    "disp_game": ("al", "bx", "cx", "di"),
    "disp_font_inv": ("ax",),
    "disp_data_7420": ("al", "bx", "cx", "di"),
    "busy_wait": ("al",),
    "story_timer_wait": ("al",),
    "disp_load_setup": ("bx", "cx"),
    "disp_script_area": ("bx", "cx", "di"),
    "gfx_draw": ("al", "bx", "cx", "di"),
    "merge_gfx_planes": ("bx", "cx", "di"),
    "xor_mask_render": ("si", "di"),
    "animate_scanline_alt": ("si",),
}


@dataclass(frozen=True)
class Event:
    checkpoint: str
    service: str
    fields: tuple[tuple[str, str], ...]

    def render(self) -> str:
        values = ",".join(f"{name}={value}" for name, value in self.fields)
        return f"{self.checkpoint}|{self.service}|{values}"


def parse_candidate_line(line: str) -> Event:
    parts = line.strip().split("|", 2)
    if len(parts) != 3:
        raise ValueError(f"expected checkpoint|service|fields, got {line!r}")
    fields = []
    if parts[2]:
        for item in parts[2].split(","):
            if "=" not in item:
                raise ValueError(f"expected name=value in {line!r}")
            name, value = item.split("=", 1)
            fields.append((name, value.upper() if name != "asset" else value))
    return Event(parts[0], parts[1], tuple(fields))


def masm_events(trace: dict) -> list[Event]:
    events = []
    for event in trace["events"]:
        checkpoint = event["checkpoint"]
        service = event["service"]
        if checkpoint not in CHECKPOINTS:
            continue
        values = []
        for field in FIELDS[service]:
            if field == "al":
                values.append(("al", f"00{event['regs']['ax'][2:]}"))
            else:
                values.append((field, event["regs"][field]))
        if "asset" in event:
            values.append(("asset", event["asset"]))
        events.append(Event(checkpoint, service, tuple(values)))
    return events


def describe_difference(expected: Event, got: Event) -> list[str]:
    differences = []
    if expected.checkpoint != got.checkpoint:
        differences.append(
            f"checkpoint: MASM={expected.checkpoint} C={got.checkpoint}"
        )
    if expected.service != got.service:
        differences.append(f"service: MASM={expected.service} C={got.service}")
    expected_fields = dict(expected.fields)
    got_fields = dict(got.fields)
    for name in expected_fields.keys() | got_fields.keys():
        if expected_fields.get(name) != got_fields.get(name):
            differences.append(
                f"field {name}: MASM={expected_fields.get(name, '<missing>')} "
                f"C={got_fields.get(name, '<missing>')}"
            )
    return differences


def print_context(expected: list[Event], got: list[Event], index: int) -> None:
    start = max(0, index - 2)
    stop = min(max(len(expected), len(got)), index + 3)
    print("context:")
    for current in range(start, stop):
        marker = ">" if current == index else " "
        ref = expected[current].render() if current < len(expected) else "<end>"
        candidate = got[current].render() if current < len(got) else "<end>"
        print(f"{marker} {current:04d} MASM {ref}")
        print(f"{marker} {current:04d} C    {candidate}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("reference", type=Path)
    parser.add_argument("candidate", type=Path)
    args = parser.parse_args()

    expected = masm_events(json.loads(args.reference.read_text(encoding="utf-8")))
    try:
        got = [
            parse_candidate_line(line)
        for line in args.candidate.read_text(encoding="utf-8").splitlines()
        if line.strip()
        ]
    except ValueError as error:
        print(f"VERDICT: FAIL: malformed C trace: {error}")
        return 1
    for index, (ref, candidate) in enumerate(zip(expected, got)):
        if ref != candidate:
            print(f"VERDICT: FAIL: semantic opening trace diverges at event {index}")
            for difference in describe_difference(ref, candidate):
                print(difference)
            print_context(expected, got, index)
            return 1
    if len(expected) != len(got):
        print(f"VERDICT: FAIL: semantic event count MASM={len(expected)} C={len(got)}")
        print_context(expected, got, min(len(expected), len(got)))
        return 1
    print(f"VERDICT: PASS: {len(expected)} C opening service events match MASM")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
