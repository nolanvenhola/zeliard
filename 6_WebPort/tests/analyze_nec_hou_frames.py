#!/usr/bin/env python3
"""Match captured NEC/HOU frames to the twelve MASM sprite-A states.

The MCGA driver writes the DAC while the display is scanning.  A captured
frame can therefore have several solid background bands even though its
foreground geometry belongs to one sprite state.  This tool removes each
row's most common color before matching geometry, keeping movement timing
separate from the DAC-race analysis.
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path

from PIL import Image


WIDTH = 320
HEIGHT = 200


def load_rgb(path: Path) -> list[tuple[int, int, int]]:
    image = Image.open(path).convert("RGB")
    if image.size != (WIDTH, HEIGHT):
        image = image.resize((WIDTH, HEIGHT), Image.Resampling.NEAREST)
    return list(image.getdata())


def foreground_mask(pixels: list[tuple[int, int, int]]) -> bytearray:
    mask = bytearray(WIDTH * HEIGHT)
    for y in range(HEIGHT):
        row = pixels[y * WIDTH:(y + 1) * WIDTH]
        background = Counter(row).most_common(1)[0][0]
        for x, color in enumerate(row):
            mask[y * WIDTH + x] = color != background
    return mask


def mask_distance(left: bytearray, right: bytearray) -> int:
    return sum(a != b for a, b in zip(left, right))


def background_runs(pixels: list[tuple[int, int, int]]) -> list[dict]:
    rows = [Counter(pixels[y * WIDTH:(y + 1) * WIDTH]).most_common(1)[0][0]
            for y in range(HEIGHT)]
    runs: list[dict] = []
    start = 0
    for y in range(1, HEIGHT + 1):
        if y == HEIGHT or rows[y] != rows[start]:
            runs.append({
                "y0": start,
                "y1": y,
                "rgb": list(rows[start]),
            })
            start = y
    return runs


def numbered_frames(directory: Path, pattern: str) -> list[Path]:
    frames = sorted(directory.glob(pattern))
    if not frames:
        raise SystemExit(f"no frames match {directory / pattern}")
    return frames


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reference-dir", type=Path, required=True)
    parser.add_argument("--state-dir", type=Path, required=True)
    parser.add_argument("--reference-pattern", default="ref_*.ppm")
    parser.add_argument("--state-pattern", default="web_state_*.ppm")
    parser.add_argument("--first-reference-frame", type=int, default=0)
    parser.add_argument("--fps", type=float, default=60.0)
    parser.add_argument("--reference-start-sec", type=float, default=0.0)
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()

    references = numbered_frames(args.reference_dir, args.reference_pattern)
    states = numbered_frames(args.state_dir, args.state_pattern)
    state_masks = [foreground_mask(load_rgb(path)) for path in states]

    observations = []
    for index, path in enumerate(references):
        if index < args.first_reference_frame:
            continue
        pixels = load_rgb(path)
        mask = foreground_mask(pixels)
        distances = [mask_distance(mask, state) for state in state_masks]
        absolute_frame = index
        time_sec = args.reference_start_sec + absolute_frame / args.fps
        observations.append({
            "reference_frame": absolute_frame,
            "reference_sec": round(time_sec, 6),
            "distances": distances,
            "background_runs": background_runs(pixels),
        })

    # MASM can retain a state or advance exactly one state between captured
    # frames.  Dynamic programming prevents a palette collision from making
    # a solid-color frame appear to jump several movement states.
    infinity = 1 << 60
    costs = [infinity] * len(states)
    costs[0] = observations[0]["distances"][0]
    history: list[list[int]] = []
    for observation in observations[1:]:
        next_costs = [infinity] * len(states)
        parent = [0] * len(states)
        for state in range(len(states)):
            candidates = [(costs[state], state)]
            if state:
                candidates.append((costs[state - 1], state - 1))
            previous_cost, previous_state = min(candidates)
            next_costs[state] = previous_cost + observation["distances"][state]
            parent[state] = previous_state
        costs = next_costs
        history.append(parent)

    state = len(states) - 1
    path = [state]
    for parent in reversed(history):
        state = parent[state]
        path.append(state)
    path.reverse()

    matches = []
    previous_state = None
    boundaries = []
    for observation, state in zip(observations, path):
        match = dict(observation)
        distances = match.pop("distances")
        match["state"] = state
        match["mask_distance"] = distances[state]
        matches.append(match)
        if state != previous_state:
            boundaries.append({
                "reference_frame": match["reference_frame"],
                "reference_sec": match["reference_sec"],
                "state": state,
            })
            previous_state = state

    report = {
        "schema": "zeliard.nec-hou-frame-analysis.v1",
        "source": "100OPDMO scene_sprite_a / 105GDMCA disp_sprite_obj_init",
        "fps": args.fps,
        "state_count": len(states),
        "boundaries": boundaries,
        "frames": matches,
    }
    rendered = json.dumps(report, indent=2) + "\n"
    print(rendered, end="")
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(rendered, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
