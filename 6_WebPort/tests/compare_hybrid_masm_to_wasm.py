#!/usr/bin/env python3
"""Compare native 320x200 MASM/v86 frames with deterministic C/WASM frames."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageChops


def read_ppm(path: Path) -> Image.Image:
    with Image.open(path) as image:
        return image.convert("RGB")


def difference_bbox(diff: Image.Image) -> list[int] | None:
    bbox = diff.getbbox()
    return list(bbox) if bbox else None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--masm-dir", type=Path, required=True)
    parser.add_argument("--wasm-dir", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    args = parser.parse_args()

    masm_manifest = json.loads((args.masm_dir / "manifest.json").read_text())
    wasm_log = json.loads((args.wasm_dir / "wasm_capture_log.json").read_text())
    wasm_by_id = {sample["id"]: sample for sample in wasm_log}
    args.out_dir.mkdir(parents=True, exist_ok=True)

    rows = []
    for masm in masm_manifest["samples"]:
        sample_id = masm["id"]
        wasm = wasm_by_id.get(sample_id)
        if wasm is None:
            raise SystemExit(f"WASM capture is missing checkpoint {sample_id}")

        masm_image = read_ppm(args.masm_dir / masm["ppm_file"])
        wasm_image = read_ppm(Path(wasm["path"]))
        if masm_image.size != (320, 200) or wasm_image.size != (320, 200):
            raise SystemExit(f"{sample_id}: expected native 320x200 frames")

        diff = ImageChops.difference(masm_image, wasm_image)
        channels = diff.tobytes()
        mismatched = sum(
            channels[offset] != 0
            or channels[offset + 1] != 0
            or channels[offset + 2] != 0
            for offset in range(0, len(channels), 3)
        )
        absolute_error = sum(channels)
        maximum_error = max(channels, default=0)
        diff_file = f"{sample_id}_diff.png"
        pair_file = f"{sample_id}_masm_wasm.png"

        enhanced = diff.point(lambda value: min(255, value * 4))
        enhanced.save(args.out_dir / diff_file)
        pair = Image.new("RGB", (640, 200))
        pair.paste(masm_image, (0, 0))
        pair.paste(wasm_image, (320, 0))
        pair.save(args.out_dir / pair_file)

        comparison = masm.get("comparison", "exact")
        if comparison == "anchor":
            verdict = "ANCHOR"
        elif comparison == "animated_window":
            verdict = "WINDOW"
        else:
            verdict = "PASS" if mismatched == 0 else "FAIL"

        rows.append({
            "id": sample_id,
            "comparison": comparison,
            "alignment": masm.get("alignment", "wall_clock"),
            "masm_ms": masm["actual_after_mcga_ms"],
            "requested_masm_ms": masm["after_mcga_ms"],
            "wasm_ms": wasm.get("wasm_ms", wasm.get("after_mcga_ms")),
            "wasm_phase": wasm.get("phase"),
            "wasm_phase_elapsed_ms": wasm.get("phase_elapsed_ms"),
            "mismatched_pixels": mismatched,
            "mismatch_percent": round(mismatched * 100.0 / (320 * 200), 6),
            "absolute_rgb_error": absolute_error,
            "maximum_channel_error": maximum_error,
            "difference_bbox": difference_bbox(diff),
            "diff_file": diff_file,
            "pair_file": pair_file,
            "verdict": verdict,
        })

    report = {
        "source": "v86 MASM release versus deterministic C/WASM opening",
        "frame_size": [320, 200],
        "checkpoints": rows,
        "first_failure": next((row["id"] for row in rows if row["verdict"] == "FAIL"), None),
        "passed": sum(row["verdict"] == "PASS" for row in rows),
        "failed": sum(row["verdict"] == "FAIL" for row in rows),
        "anchors": sum(row["verdict"] == "ANCHOR" for row in rows),
        "animated_windows": sum(row["verdict"] == "WINDOW" for row in rows),
    }
    (args.out_dir / "report.json").write_text(json.dumps(report, indent=2) + "\n")

    markdown = [
        "# MASM vs C/WASM Opening Parity",
        "",
        "| Checkpoint | Alignment | MASM ms | C phase | Mismatched pixels | Difference bbox | Verdict |",
        "|---|---|---:|---:|---:|---|---|",
    ]
    for row in rows:
        markdown.append(
            f"| {row['id']} | {row['alignment']} | {row['masm_ms']} | {row['wasm_phase']} | "
            f"{row['mismatched_pixels']} ({row['mismatch_percent']:.3f}%) | "
            f"{row['difference_bbox']} | {row['verdict']} |"
        )
    markdown.extend([
        "",
        f"First failure: `{report['first_failure']}`",
        "",
        "For `frame_state` checkpoints, MASM ms is diagnostic arrival time only; "
        "the executing release build is matched by ordered framebuffer identity.",
        "",
        "Pair images place MASM on the left and C/WASM on the right. "
        "Difference images amplify channel differences by 4x.",
    ])
    (args.out_dir / "report.md").write_text("\n".join(markdown) + "\n")

    print(
        f"VERDICT: {'PASS' if report['failed'] == 0 else 'FAIL'} "
        f"({report['passed']} passed, {report['failed']} failed; "
        f"first={report['first_failure']})"
    )
    return 0 if report["failed"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
