#!/usr/bin/env python3
"""Compare every captured DOSBox opening frame with the browser/WASM timeline."""

from __future__ import annotations

import argparse
import base64
import hashlib
import heapq
import json
import math
import subprocess
from pathlib import Path

from PIL import Image, ImageChops


WIDTH = 320
HEIGHT = 200
RGB_BYTES = WIDTH * HEIGHT * 3
COARSE_SIZE = (20, 10)


def load_wasm_timeline(path: Path) -> tuple[dict, list[dict]]:
    metadata: dict | None = None
    frames: list[dict] = []
    with path.open("r", encoding="utf-8") as stream:
        for line in stream:
            row = json.loads(line)
            if row.get("type") == "metadata":
                metadata = row
            elif row.get("type") == "frame":
                row["coarse_rgb"] = base64.b64decode(row.pop("coarse_rgb_base64"))
                frames.append(row)
    if metadata is None or not frames:
        raise SystemExit(f"{path} does not contain a WASM hash timeline")
    return metadata, frames


def dhash_rgb(pixels: bytes) -> int:
    value = 0
    bit = 0
    for y in range(8):
        sy = int((y + 0.5) * HEIGHT / 8)
        previous = 0
        for x in range(9):
            sx = int((x + 0.5) * WIDTH / 9)
            offset = (sy * WIDTH + sx) * 3
            gray = pixels[offset] * 299 + pixels[offset + 1] * 587 + pixels[offset + 2] * 114
            if x:
                if previous > gray:
                    value |= 1 << bit
                bit += 1
            previous = gray
    return value


def coarse_rgb(pixels: bytes) -> bytes:
    image = Image.frombytes("RGB", (WIDTH, HEIGHT), pixels)
    return image.resize(COARSE_SIZE, Image.Resampling.BOX).tobytes()


def signature_metrics(wasm: bytes, reference: bytes) -> tuple[float, float]:
    absolute = 0
    squared = 0
    for left, right in zip(wasm, reference):
        delta = int(left) - int(right)
        absolute += abs(delta)
        squared += delta * delta
    count = len(wasm)
    return absolute / count, math.sqrt(squared / count)


def ffmpeg_raw_frames(video: Path) -> subprocess.Popen:
    return subprocess.Popen(
        [
            "ffmpeg", "-hide_banner", "-loglevel", "error", "-i", str(video),
            "-vf", "crop=640:400:1:64,scale=320:200:flags=neighbor,format=rgb24",
            "-f", "rawvideo", "-pix_fmt", "rgb24", "-",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )


def read_exact(stream, size: int) -> bytes:
    chunks = bytearray()
    while len(chunks) < size:
        chunk = stream.read(size - len(chunks))
        if not chunk:
            break
        chunks.extend(chunk)
    return bytes(chunks)


def phase_spans(frames: list[dict]) -> list[dict]:
    spans: list[dict] = []
    start = 0
    for index in range(1, len(frames) + 1):
        boundary = index == len(frames)
        if not boundary:
            boundary = (frames[index]["scene"], frames[index]["phase"]) != (
                frames[start]["scene"], frames[start]["phase"])
        if boundary:
            spans.append({
                "scene": frames[start]["scene"],
                "phase": frames[start]["phase"],
                "start_frame": start,
                "end_frame": index - 1,
                "start_wasm_ms": frames[start]["wasm_ms"],
                "end_wasm_ms": frames[index - 1]["wasm_ms"],
            })
            start = index
    return spans


def phase_metrics(rows: list[dict]) -> list[dict]:
    groups: list[list[dict]] = []
    for row in rows:
        if not groups or (groups[-1][0]["scene"], groups[-1][0]["phase"]) != (row["scene"], row["phase"]):
            groups.append([])
        groups[-1].append(row)
    results = []
    for group in groups:
        rmses = sorted(float(row["coarse_rmse"]) for row in group)
        maes = [float(row["coarse_mae"]) for row in group]
        dhashes = [int(row["dhash_hamming"]) for row in group]
        p95_index = min(len(rmses) - 1, int(math.floor(len(rmses) * 0.95)))
        results.append({
            "scene": group[0]["scene"],
            "phase": group[0]["phase"],
            "start_frame": group[0]["index"],
            "end_frame": group[-1]["index"],
            "frame_count": len(group),
            "mean_coarse_mae": round(sum(maes) / len(maes), 6),
            "mean_coarse_rmse": round(sum(rmses) / len(rmses), 6),
            "p95_coarse_rmse": round(rmses[p95_index], 6),
            "mean_dhash_hamming": round(sum(dhashes) / len(dhashes), 6),
        })
    return results


def best_local_offset(index: int, reference: bytes, wasm_frames: list[dict], radius: int) -> dict:
    first = max(0, index - radius)
    last = min(len(wasm_frames) - 1, index + radius)
    best: tuple[float, int, float] | None = None
    for candidate in range(first, last + 1):
        mae, rmse = signature_metrics(wasm_frames[candidate]["coarse_rgb"], reference)
        score = rmse
        if best is None or score < best[0]:
            best = (score, candidate, mae)
    assert best is not None
    return {
        "reference_frame": index,
        "best_wasm_frame": best[1],
        "offset_frames": best[1] - index,
        "offset_ms": round((best[1] - index) * 1000 / 30, 3),
        "coarse_mae": round(best[2], 6),
        "coarse_rmse": round(best[0], 6),
    }


def extract_reference_frame(video: Path, frame: int, output: Path) -> None:
    subprocess.run(
        [
            "ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(video),
            "-vf", f"select=eq(n\\,{frame}),crop=640:400:1:64,scale=320:200:flags=neighbor",
            "-frames:v", "1", str(output),
        ],
        check=True,
    )


def capture_retained_wasm(url: str, shell: Path, schedule: Path, output: Path) -> None:
    subprocess.run(
        [
            "node", "capture_opening_wasm_frames.mjs", "--schedule", str(schedule),
            "--out-dir", str(output), "--url", url, "--raw-ppm", "--quiet",
        ],
        cwd=shell,
        check=True,
    )


def materialize_frames(video: Path, url: str, out_dir: Path, rows: list[dict],
                       spans: list[dict], shell: Path) -> None:
    retained = {int(row["index"]) for row in rows}
    retained.update(int(span["start_frame"]) for span in spans)
    retained_indices = sorted(retained)
    retained_dir = out_dir / "retained"
    wasm_dir = retained_dir / "wasm"
    reference_dir = retained_dir / "reference"
    report_dir = retained_dir / "report"
    for directory in (wasm_dir, reference_dir, report_dir):
        directory.mkdir(parents=True, exist_ok=True)

    schedule = out_dir / "retained_schedule.json"
    schedule.write_text(json.dumps({"samples": [
        {
            "id": f"frame_{index:05d}",
            "index": index,
            "wasm_ms": rows_by_index[index]["wasm_ms"],
            "file": f"wasm_{index:05d}.ppm",
        }
        for index in retained_indices
    ]}, indent=2) + "\n", encoding="utf-8")
    capture_retained_wasm(url, shell, schedule, wasm_dir)

    for index in retained_indices:
        reference = reference_dir / f"reference_{index:05d}.png"
        extract_reference_frame(video, index, reference)
        wasm = wasm_dir / f"wasm_{index:05d}.ppm"
        with Image.open(reference) as ref_image, Image.open(wasm) as wasm_image:
            ref_rgb = ref_image.convert("RGB")
            wasm_rgb = wasm_image.convert("RGB")
            expected = rows_by_index[index]
            reference_hash = hashlib.sha256(ref_rgb.tobytes()).hexdigest()
            wasm_hash = hashlib.sha256(wasm_rgb.tobytes()).hexdigest()
            if reference_hash != expected["reference_rgb_sha256"]:
                raise RuntimeError(f"retained reference frame {index} changed hash")
            if wasm_hash != expected["wasm_rgb_sha256"]:
                raise RuntimeError(f"retained WASM frame {index} changed hash")
            diff = ImageChops.difference(ref_rgb, wasm_rgb)
            enhanced = diff.point(lambda value: min(255, value * 4))
            pair = Image.new("RGB", (WIDTH * 2, HEIGHT))
            pair.paste(ref_rgb, (0, 0))
            pair.paste(wasm_rgb, (WIDTH, 0))
            enhanced.save(report_dir / f"diff_{index:05d}.png")
            pair.save(report_dir / f"pair_{index:05d}.png")


rows_by_index: dict[int, dict] = {}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--video", type=Path, required=True)
    parser.add_argument("--wasm-timeline", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    parser.add_argument("--url", default="http://127.0.0.1:5173/")
    parser.add_argument("--keep-worst", type=int, default=20)
    parser.add_argument("--drift-radius-frames", type=int, default=90)
    parser.add_argument("--boundary-drift-radius-frames", type=int, default=900)
    parser.add_argument("--no-materialize", action="store_true")
    args = parser.parse_args()

    args.video = args.video.resolve()
    args.wasm_timeline = args.wasm_timeline.resolve()
    args.out_dir = args.out_dir.resolve()

    metadata, wasm_frames = load_wasm_timeline(args.wasm_timeline)
    args.out_dir.mkdir(parents=True, exist_ok=True)
    process = ffmpeg_raw_frames(args.video)
    assert process.stdout is not None

    exact_matches = 0
    total_mae = 0.0
    total_rmse = 0.0
    worst_heap: list[tuple[float, int, dict]] = []
    frame_rows: list[dict] = []
    reference_coarse: list[bytes] = []
    reference_hashes: set[str] = set()
    compared = 0
    try:
        for index, wasm in enumerate(wasm_frames):
            pixels = read_exact(process.stdout, RGB_BYTES)
            if len(pixels) != RGB_BYTES:
                break
            rgb_hash = hashlib.sha256(pixels).hexdigest()
            reference_hashes.add(rgb_hash)
            coarse = coarse_rgb(pixels)
            reference_coarse.append(coarse)
            mae, rmse = signature_metrics(wasm["coarse_rgb"], coarse)
            hamming = (int(wasm["dhash"], 16) ^ dhash_rgb(pixels)).bit_count()
            exact = rgb_hash == wasm["rgb_sha256"]
            exact_matches += int(exact)
            total_mae += mae
            total_rmse += rmse
            row = {
                "index": index,
                "video_sec": round(index * metadata["fps_den"] / metadata["fps_num"], 6),
                "wasm_ms": wasm["wasm_ms"],
                "scene": wasm["scene"],
                "phase": wasm["phase"],
                "phase_elapsed_ms": wasm["phase_elapsed_ms"],
                "reference_rgb_sha256": rgb_hash,
                "wasm_rgb_sha256": wasm["rgb_sha256"],
                "exact_rgb_match": exact,
                "coarse_mae": round(mae, 6),
                "coarse_rmse": round(rmse, 6),
                "dhash_hamming": hamming,
            }
            frame_rows.append(row)
            compared += 1
            candidate = (rmse, index, row)
            if len(worst_heap) < args.keep_worst:
                heapq.heappush(worst_heap, candidate)
            elif candidate > worst_heap[0]:
                heapq.heapreplace(worst_heap, candidate)
            if compared % 900 == 0:
                print(f"reference comparison {compared}/{len(wasm_frames)}")
    finally:
        if process.stdout:
            process.stdout.close()
        process.wait()

    if compared == 0:
        raise SystemExit("reference video produced no frames")
    wasm_frames = wasm_frames[:compared]
    frame_rows = frame_rows[:compared]
    global rows_by_index
    rows_by_index = {row["index"]: {**row, "wasm_ms": wasm_frames[row["index"]]["wasm_ms"]}
                     for row in frame_rows}
    spans = phase_spans(wasm_frames)
    per_phase = phase_metrics(frame_rows)
    worst = [item[2] for item in sorted(worst_heap, reverse=True)]
    drift = [
        best_local_offset(index, reference_coarse[index], wasm_frames,
                          args.drift_radius_frames)
        for index in range(0, compared, 30)
    ]
    boundary_drift = [
        {
            "scene": span["scene"],
            "phase": span["phase"],
            **best_local_offset(
                int(span["start_frame"]),
                reference_coarse[int(span["start_frame"])],
                wasm_frames,
                args.boundary_drift_radius_frames,
            ),
        }
        for span in spans
    ]

    report = {
        "schema": "zeliard.opening.full_timeline.v1",
        "reference_video": str(args.video),
        "wasm_timeline": str(args.wasm_timeline),
        "alignment": {
            "video_start_sec": 0.0,
            "wasm_origin_ms": metadata["wasm_origin_ms"],
            "scale": 1.0,
            "note": "Only the capture-start anchor is applied; later drift is not corrected.",
        },
        "fps": [metadata["fps_num"], metadata["fps_den"]],
        "frames_requested": len(wasm_frames),
        "frames_compared": compared,
        "exact_rgb_matches": exact_matches,
        "exact_rgb_match_percent": round(exact_matches * 100.0 / compared, 6),
        "distinct_reference_rgb_hashes": len(reference_hashes),
        "distinct_wasm_rgb_hashes": len({frame["rgb_sha256"] for frame in wasm_frames}),
        "mean_coarse_mae": round(total_mae / compared, 6),
        "mean_coarse_rmse": round(total_rmse / compared, 6),
        "phase_spans": spans,
        "phase_metrics": per_phase,
        "drift_samples": drift,
        "boundary_drift_samples": boundary_drift,
        "worst_frames": worst,
        "frames": frame_rows,
    }
    report_path = args.out_dir / "report.json"
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    markdown = [
        "# Full Opening Timeline Comparison",
        "",
        f"- Frames compared: {compared}",
        f"- Exact normalized RGB hashes: {exact_matches}/{compared}",
        f"- Distinct reference/WASM frames: {report['distinct_reference_rgb_hashes']} / {report['distinct_wasm_rgb_hashes']}",
        f"- Mean coarse RGB MAE/RMSE: {report['mean_coarse_mae']:.3f} / {report['mean_coarse_rmse']:.3f}",
        "- Alignment: video 0.0s = WASM 1360ms, scale 1.0",
        "",
        "Exact RGB hashes are retained for auditing but are not expected to match a lossy YUV420 MP4.",
        "The coarse RGB and difference-hash columns measure compression-tolerant visual agreement.",
        "",
        "## Phase Spans",
        "",
        "| Scene | Phase | First frame | Last frame | WASM start | WASM end |",
        "|---:|---:|---:|---:|---:|---:|",
    ]
    for span in spans:
        markdown.append(
            f"| {span['scene']} | {span['phase']} | {span['start_frame']} | {span['end_frame']} | "
            f"{span['start_wasm_ms']} | {span['end_wasm_ms']} |"
        )
    markdown.extend([
        "",
        "## Per-Phase Error",
        "",
        "| Scene | Phase | Frames | Mean RMSE | P95 RMSE | Mean dHash distance |",
        "|---:|---:|---:|---:|---:|---:|",
    ])
    for phase in per_phase:
        markdown.append(
            f"| {phase['scene']} | {phase['phase']} | {phase['frame_count']} | "
            f"{phase['mean_coarse_rmse']:.3f} | {phase['p95_coarse_rmse']:.3f} | "
            f"{phase['mean_dhash_hamming']:.3f} |"
        )
    markdown.extend([
        "",
        "## Phase-Boundary Alignment Probe",
        "",
        "Positive offset means the closest WASM frame occurs later than the same-index reference frame.",
        "",
        "| Scene | Phase | Reference frame | Best WASM frame | Offset ms | RMSE |",
        "|---:|---:|---:|---:|---:|---:|",
    ])
    for boundary in boundary_drift:
        markdown.append(
            f"| {boundary['scene']} | {boundary['phase']} | {boundary['reference_frame']} | "
            f"{boundary['best_wasm_frame']} | {boundary['offset_ms']:.3f} | "
            f"{boundary['coarse_rmse']:.3f} |"
        )
    markdown.extend([
        "",
        "## Worst Frames",
        "",
        "| Frame | Video s | Phase | Coarse RMSE | dHash distance |",
        "|---:|---:|---:|---:|---:|",
    ])
    for row in worst:
        markdown.append(
            f"| {row['index']} | {row['video_sec']:.3f} | {row['phase']} | "
            f"{row['coarse_rmse']:.3f} | {row['dhash_hamming']} |"
        )
    (args.out_dir / "report.md").write_text("\n".join(markdown) + "\n", encoding="utf-8")

    if not args.no_materialize:
        shell = Path(__file__).resolve().parents[1] / "shell"
        materialize_frames(args.video, args.url, args.out_dir, worst, spans, shell)

    print(f"VERDICT: COMPLETE: {compared} full-timeline frames compared")
    print(f"Report: {report_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
