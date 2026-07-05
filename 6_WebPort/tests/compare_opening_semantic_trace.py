#!/usr/bin/env python3
"""Compare a C opening service trace with semantic fields from the MASM trace."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


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


def masm_lines(trace: dict) -> list[str]:
    lines = []
    for event in trace["events"]:
        checkpoint = event["checkpoint"]
        service = event["service"]
        if checkpoint not in CHECKPOINTS:
            continue
        values = []
        for field in FIELDS[service]:
            if field == "al":
                values.append(f"al=00{event['regs']['ax'][2:]}")
            else:
                values.append(f"{field}={event['regs'][field]}")
        if "asset" in event:
            values.append(f"asset={event['asset']}")
        lines.append(f"{checkpoint}|{service}|{','.join(values)}")
    return lines


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("reference", type=Path)
    parser.add_argument("candidate", type=Path)
    args = parser.parse_args()

    expected = masm_lines(json.loads(args.reference.read_text(encoding="utf-8")))
    got = [
        line.strip()
        for line in args.candidate.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    for index, (ref, candidate) in enumerate(zip(expected, got)):
        if ref != candidate:
            print(f"VERDICT: FAIL: semantic opening trace diverges at event {index}")
            print(f"MASM: {ref}")
            print(f"C:    {candidate}")
            return 1
    if len(expected) != len(got):
        print(f"VERDICT: FAIL: semantic event count MASM={len(expected)} C={len(got)}")
        return 1
    print(f"VERDICT: PASS: {len(expected)} C opening service events match MASM")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
