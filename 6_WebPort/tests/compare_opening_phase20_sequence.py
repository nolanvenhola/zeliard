#!/usr/bin/env python3
"""Analyze every captured frame in the NEC/HOU sprite-A sequence.

This is diagnostic rather than a visual golden.  It maps each DOS capture
frame to the closest deterministic WASM phase-20 state and reports changes in
the mechanically translated sprite frame, frame-wait position, and DAC-band
count.  MASM oracles remain authoritative for the state contents.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from compare_opening_full_timeline import (
    RGB_BYTES,
    coarse_rgb,
    ffmpeg_raw_frames,
    load_wasm_timeline,
    read_exact,
    signature_metrics,
)


def decode_debug_word(value: int) -> tuple[int, int, int]:
    value &= 0xFFFFFFFF
    return value & 0xFF, (value >> 8) & 0xFFFF, (value >> 24) & 0xFF


def quantize_component(value: int) -> int:
    levels = (0, 64, 128, 192, 255)
    return min(levels, key=lambda level: abs(level - value))


def reference_row_profile(pixels: bytes) -> list[list[object]]:
    colors = []
    for y in range(200):
        totals = [0, 0, 0]
        count = 0
        for x in (*range(0, 16), *range(304, 320)):
            offset = (y * 320 + x) * 3
            for component in range(3):
                totals[component] += pixels[offset + component]
            count += 1
        colors.append(tuple(
            quantize_component(round(total / count)) for total in totals))

    runs: list[list[object]] = []
    for y, color in enumerate(colors):
        if not runs or runs[-1][1] != color:
            runs.append([y, color])
    return runs


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--video", type=Path, required=True)
    parser.add_argument("--wasm-timeline", type=Path, required=True)
    parser.add_argument("--start-sec", type=float, default=51.0)
    parser.add_argument("--end-sec", type=float, default=54.5)
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()

    _, wasm = load_wasm_timeline(args.wasm_timeline.resolve())
    phase = [row for row in wasm if row["phase"] == 20]
    if not phase:
        raise SystemExit("WASM timeline has no phase-20 frames")

    first_reference = round(args.start_sec * 30)
    last_reference = round(args.end_sec * 30)
    process = ffmpeg_raw_frames(args.video.resolve())
    assert process.stdout is not None
    references: list[tuple[int, bytes, list[list[object]]]] = []
    try:
        for index in range(last_reference + 1):
            pixels = read_exact(process.stdout, RGB_BYTES)
            if len(pixels) != RGB_BYTES:
                break
            if index >= first_reference:
                references.append((
                    index, coarse_rgb(pixels), reference_row_profile(pixels)))
    finally:
        process.stdout.close()
        process.wait()

    phase_by_index = {int(row["index"]): row for row in phase}
    reference_by_index = {
        index: (coarse, profile) for index, coarse, profile in references
    }
    alignments = []
    for offset in range(-15, 16):
        metrics = []
        for reference_index, reference, _profile in references:
            candidate = phase_by_index.get(reference_index + offset)
            if candidate is None:
                continue
            metrics.append(signature_metrics(candidate["coarse_rgb"], reference))
        if metrics:
            alignments.append((
                sum(item[1] for item in metrics) / len(metrics),
                sum(item[0] for item in metrics) / len(metrics),
                -len(metrics), offset,
            ))
    if not alignments:
        raise SystemExit("reference window does not overlap phase 20")
    mean_rmse, mean_mae, negative_count, alignment_offset = min(alignments)

    rows = []
    for reference_index in sorted(reference_by_index):
        candidate = phase_by_index.get(reference_index + alignment_offset)
        if candidate is None:
            continue
        reference, row_profile = reference_by_index[reference_index]
        mae, rmse = signature_metrics(candidate["coarse_rgb"], reference)
        sprite_frame, frame_elapsed, band_count = decode_debug_word(
            int(candidate["nec_hou_sprite_debug_word"]))
        rows.append({
            "reference_frame": reference_index,
            "reference_sec": round(reference_index / 30.0, 6),
            "wasm_frame": candidate["index"],
            "wasm_ms": candidate["wasm_ms"],
            "phase_elapsed_ms": candidate["phase_elapsed_ms"],
            "sprite_frame": sprite_frame,
            "sprite_frame_elapsed_ms": frame_elapsed,
            "band_count": band_count,
            "reference_row_profile": row_profile,
            "coarse_mae": round(mae, 6),
            "coarse_rmse": round(rmse, 6),
        })

    runs = []
    previous_state = None
    for row in rows:
        state = (row["sprite_frame"], tuple(
            (run[0], tuple(run[1])) for run in row["reference_row_profile"]))
        if state != previous_state:
            runs.append({
                "sprite_frame": row["sprite_frame"],
                "reference_row_profile": row["reference_row_profile"],
                "first_reference_frame": row["reference_frame"],
                "first_reference_sec": row["reference_sec"],
                "best_wasm_frame": row["wasm_frame"],
                "best_phase_elapsed_ms": row["phase_elapsed_ms"],
                "sprite_frame_elapsed_ms": row["sprite_frame_elapsed_ms"],
                "coarse_rmse": row["coarse_rmse"],
            })
            previous_state = state

    report = {
        "schema": "zeliard.phase20-sequence-analysis.v1",
        "source": "released MASM capture plus deterministic WASM timeline",
        "reference_window": [args.start_sec, args.end_sec],
        "alignment": {
            "wasm_minus_reference_frames": alignment_offset,
            "milliseconds": round(alignment_offset * 1000 / 30, 3),
            "frame_count": -negative_count,
            "mean_coarse_mae": round(mean_mae, 6),
            "mean_coarse_rmse": round(mean_rmse, 6),
        },
        "frame_count": len(rows),
        "runs": runs,
        "frames": rows,
    }
    rendered = json.dumps(report, indent=2) + "\n"
    print(rendered, end="")
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(rendered, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
