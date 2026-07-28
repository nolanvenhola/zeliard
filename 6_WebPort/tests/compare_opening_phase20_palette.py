#!/usr/bin/env python3
"""Targeted phase-20 palette comparison against the captured DOS reference.

The full opening timeline has accumulated timing drift before phase 20.  A
global frame-to-frame comparison therefore reports a false palette regression
at the NEC/HOU sprite entry.  This gate anchors on the first palette mutation
inside phase 20, then compares the first two stable raster states in a small,
bounded reference window.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image

from compare_opening_full_timeline import (
    COARSE_SIZE,
    RGB_BYTES,
    coarse_rgb,
    dhash_rgb,
    ffmpeg_raw_frames,
    load_wasm_timeline,
    read_exact,
    signature_metrics,
)


PHASE = 20
SEARCH_RADIUS = 15
MAX_ANCHOR_RMSE = 5.0
MAX_SECOND_RMSE = 6.0
MAX_OFFSET_DELTA = 2
MAX_ABSOLUTE_OFFSET = 2


def reference_signatures(video: Path, count: int) -> list[tuple[bytes, int]]:
    process = ffmpeg_raw_frames(video)
    assert process.stdout is not None
    frames: list[tuple[bytes, int]] = []
    try:
        for _ in range(count):
            pixels = read_exact(process.stdout, RGB_BYTES)
            if len(pixels) != RGB_BYTES:
                break
            frames.append((coarse_rgb(pixels), dhash_rgb(pixels)))
    finally:
        process.stdout.close()
        process.wait()
    return frames


def best_reference(wasm: dict, references: list[tuple[bytes, int]],
                   center: int) -> dict:
    first = max(0, center - SEARCH_RADIUS)
    last = min(len(references) - 1, center + SEARCH_RADIUS)
    best: tuple[float, int, float, int] | None = None
    for index in range(first, last + 1):
        reference, reference_dhash = references[index]
        mae, rmse = signature_metrics(wasm["coarse_rgb"], reference)
        hamming = (int(wasm["dhash"], 16) ^ reference_dhash).bit_count()
        candidate = (rmse, index, mae, hamming)
        if best is None or candidate < best:
            best = candidate
    assert best is not None
    return {
        "wasm_frame": wasm["index"],
        "wasm_ms": wasm["wasm_ms"],
        "phase_elapsed_ms": wasm["phase_elapsed_ms"],
        "reference_frame": best[1],
        "reference_sec": round(best[1] / 30.0, 6),
        "offset_frames": best[1] - wasm["index"],
        "coarse_mae": round(best[2], 6),
        "coarse_rmse": round(best[0], 6),
        "dhash_hamming": best[3],
    }


def write_coarse_pair(path: Path, wasm: dict, reference: bytes) -> None:
    reference_image = Image.frombytes("RGB", COARSE_SIZE, reference).resize(
        (320, 200), Image.Resampling.NEAREST)
    wasm_image = Image.frombytes("RGB", COARSE_SIZE, wasm["coarse_rgb"]).resize(
        (320, 200), Image.Resampling.NEAREST)
    pair = Image.new("RGB", (640, 200))
    pair.paste(reference_image, (0, 0))
    pair.paste(wasm_image, (320, 0))
    pair.save(path)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--video", type=Path, required=True)
    parser.add_argument("--wasm-timeline", type=Path, required=True)
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()

    _, frames = load_wasm_timeline(args.wasm_timeline.resolve())
    phase_frames = [frame for frame in frames if frame["phase"] == PHASE]
    if not phase_frames:
        raise SystemExit("WASM timeline has no phase-20 frames")

    base_palette = phase_frames[0]["palette_sha256"]
    mutation = next(
        (index for index, frame in enumerate(phase_frames)
         if frame["palette_sha256"] != base_palette),
        None,
    )
    if mutation is None or mutation + 1 >= len(phase_frames):
        raise SystemExit("phase 20 has no complete sprite palette transaction")

    # The mutation frame may straddle the palette transaction.  The following
    # sample is the first stable raster state.  The second checkpoint is the
    # next complete AX=0 palette produced by the sprite-object loop.
    first = phase_frames[mutation + 1]
    second = next(
        (frame for frame in phase_frames[mutation + 2:]
         if frame["palette_sha256"] != first["palette_sha256"]),
        None,
    )
    if second is None:
        raise SystemExit("phase 20 has no second sprite palette state")

    reference_count = min(len(frames), second["index"] + SEARCH_RADIUS + 1)
    references = reference_signatures(args.video.resolve(), reference_count)
    first_result = best_reference(first, references, first["index"])

    projected_second = second["index"] + first_result["offset_frames"]
    second_result = best_reference(second, references, projected_second)
    offset_delta = abs(second_result["offset_frames"] - first_result["offset_frames"])

    passed = (
        first_result["coarse_rmse"] <= MAX_ANCHOR_RMSE
        and second_result["coarse_rmse"] <= MAX_SECOND_RMSE
        and offset_delta <= MAX_OFFSET_DELTA
        and abs(first_result["offset_frames"]) <= MAX_ABSOLUTE_OFFSET
        and abs(second_result["offset_frames"]) <= MAX_ABSOLUTE_OFFSET
    )
    report = {
        "schema": "zeliard.phase20-palette-comparison.v1",
        "source": "100OPDMO sprite-A entry plus 105GDMCA AX=0 DAC writes",
        "phase": PHASE,
        "search_radius_frames": SEARCH_RADIUS,
        "thresholds": {
            "first_rmse": MAX_ANCHOR_RMSE,
            "second_rmse": MAX_SECOND_RMSE,
            "offset_delta_frames": MAX_OFFSET_DELTA,
            "absolute_offset_frames": MAX_ABSOLUTE_OFFSET,
        },
        "first_palette_state": first_result,
        "second_palette_state": second_result,
        "offset_delta_frames": offset_delta,
        "verdict": "PASS" if passed else "FAIL",
    }
    rendered = json.dumps(report, indent=2) + "\n"
    print(rendered, end="")
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(rendered, encoding="utf-8")
        write_coarse_pair(
            args.out.parent / "first_palette_state_coarse_pair.png",
            first,
            references[first_result["reference_frame"]][0],
        )
        write_coarse_pair(
            args.out.parent / "second_palette_state_coarse_pair.png",
            second,
            references[second_result["reference_frame"]][0],
        )
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
