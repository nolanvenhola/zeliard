#!/usr/bin/env python3
"""Compare selected C opening frames against the captured DOSBox video.

This is a visual parity workbench, not yet a hard CI gate.  The reference
video is a window capture, so each frame is cropped to the DOS viewport and
downscaled to the engine's 320x200 framebuffer before comparison.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import shutil
import socket
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
WEBPORT = ROOT / "6_WebPort"
ENGINE = WEBPORT / "engine"
VIDEO = ROOT / "3_Assembly" / "masm" / "bin" / "capture" / "OpeningDemo-Capture.mp4"
OUT = WEBPORT / "tests" / "artifacts" / "opening_video_compare"
ANCHORS = WEBPORT / "tests" / "opening_video_anchors.json"


@dataclass(frozen=True)
class Checkpoint:
    name: str
    video_sec: float
    phase: int
    elapsed_ms: int
    note: str


@dataclass(frozen=True)
class SweepTarget:
    name: str
    video_sec: float
    phases: tuple[int, ...]
    start_ms: int
    end_ms: int
    step_ms: int


@dataclass(frozen=True)
class IndexRect:
    name: str
    x: int
    y: int
    w: int
    h: int


@dataclass(frozen=True)
class CropRect:
    x: int
    y: int
    w: int
    h: int


CHECKPOINTS = [
    Checkpoint("jashiin_eyes", 440.0, 9, 54000,
               "Blue/red Jashiin eye panel; current C timing may not line up yet."),
    Checkpoint("guardian_spirit", 580.0, 9, 6000,
               "Guardian spirit panel used to expose split-frame artifacts."),
    Checkpoint("stone_princess_king", 500.0, 6, 9000,
               "Stone Felicia/king panel; checks WAKU + story image colors."),
    Checkpoint("duke_jashiin_portraits", 780.0, 10, 6000,
               "Late portrait panel; current phase mapping is expected to drift."),
]


SWEEP_TARGETS = [
    SweepTarget("jashiin_eyes", 440.0, (5, 6, 7, 8, 9, 10), 0, 90000, 3000),
    SweepTarget("guardian_spirit", 580.0, (6, 7, 8, 9, 10), 0, 90000, 3000),
    SweepTarget("duke_jashiin_portraits", 780.0, (8, 9, 10, 11), 0, 120000, 3000),
]


INDEX_RECTS = [
    IndexRect("yuu_left_split", 0x0B * 4, 0x18, 0x18 * 4, 0x58),
    IndexRect("yuu_right_split", 0x2D * 4, 0x18, 0x18 * 4, 0x58),
    IndexRect("script_right_portrait_small", 0x33 * 4, 0x50, 0x0E * 4, 0x20),
    IndexRect("script_right_portrait_large", 0x33 * 4, 0x38, 0x0B * 4, 0x10),
    IndexRect("script_left_portrait_small", 0x13 * 4, 0x50, 0x09 * 4, 0x20),
    IndexRect("script_left_portrait_large", 0x12 * 4, 0x38, 0x0B * 4, 0x10),
]


INDEX_TARGETS = [
    ("guardian_spirit", 580.0, 9, 0),
    ("jashiin_eyes", 440.0, 10, 21000),
    ("duke_jashiin_portraits", 780.0, 8, 0),
]


def run(cmd: list[str], cwd: Path | None = None, quiet: bool = False) -> None:
    subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        check=True,
        stdout=subprocess.DEVNULL if quiet else None,
        stderr=subprocess.DEVNULL if quiet else None,
    )


def run_capture(cmd: list[str], cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


def wsl_path(path: Path) -> str:
    p = path.resolve()
    return "/mnt/" + p.drive[0].lower() + str(p)[2:].replace("\\", "/")


def ensure_native_dumper(distro: str) -> None:
    cmd = (
        f"cd {wsl_path(ENGINE)} && "
        "node ../scripts/copy_assets.mjs >/dev/null && "
        "make build/opening-frame-dump-native"
    )
    run(["wsl", "-d", distro, "--", "bash", "-lc", cmd])


def dump_c_frame(distro: str, cp: Checkpoint, out_path: Path) -> None:
    dump_c_frame_values(distro, cp.phase, cp.elapsed_ms, out_path)


def dump_c_frame_values(distro: str, phase: int, elapsed_ms: int, out_path: Path,
                        yuu_variant: int | None = None) -> None:
    variant_arg = "" if yuu_variant is None else f" --yuu-variant {yuu_variant}"
    cmd = (
        f"cd {wsl_path(ENGINE)} && "
        f"./build/opening-frame-dump-native {phase} {elapsed_ms} {wsl_path(out_path)}{variant_arg}"
    )
    run(["wsl", "-d", distro, "--", "bash", "-lc", cmd], quiet=True)


def dump_c_indices_values(distro: str, phase: int, elapsed_ms: int, out_path: Path,
                          yuu_variant: int | None = None) -> None:
    variant_arg = "" if yuu_variant is None else f" --yuu-variant {yuu_variant}"
    cmd = (
        f"cd {wsl_path(ENGINE)} && "
        f"./build/opening-frame-dump-native {phase} {elapsed_ms} {wsl_path(out_path)} --indices{variant_arg}"
    )
    run(["wsl", "-d", distro, "--", "bash", "-lc", cmd], quiet=True)


def crop_filter(crop: CropRect) -> str:
    return (
        f"crop={crop.w}:{crop.h}:{crop.x}:{crop.y},"
        "scale=320:200:flags=neighbor,format=rgb24"
    )


def parse_crop(value: str | None) -> CropRect | None:
    if value is None:
        return None
    if value.lower() == "auto":
        return None
    parts = value.replace(",", ":").split(":")
    if len(parts) != 4:
        raise ValueError("crop must be x:y:w:h or auto")
    x, y, w, h = [int(part, 0) for part in parts]
    return CropRect(x, y, w, h)


def load_anchor(anchor_id: str) -> dict[str, object]:
    data = json.loads(ANCHORS.read_text(encoding="utf-8"))
    for anchor in data.get("anchors", []):
        if anchor.get("id") == anchor_id:
            return anchor
    known = ", ".join(str(anchor.get("id")) for anchor in data.get("anchors", []))
    raise SystemExit(f"unknown anchor {anchor_id!r}; known anchors: {known}")


def list_anchors() -> None:
    data = json.loads(ANCHORS.read_text(encoding="utf-8"))
    for anchor in data.get("anchors", []):
        video_sec = float(anchor["video_sec"])
        wasm_ms = int(anchor["wasm_ms"])
        origin = video_sec - wasm_ms / 1000.0
        print(
            f"{anchor['id']}: video={video_sec:.3f}s wasm={wasm_ms}ms "
            f"origin={origin:.3f}s phase={anchor.get('phase_id', anchor.get('phase'))}"
        )


def extract_ref_frame(cp: Checkpoint, out_path: Path,
                      crop: CropRect = CropRect(1, 64, 640, 400)) -> None:
    # DOSBox-X capture is usually 642x464 with a 640x400 doubled game viewport.
    vf = crop_filter(crop)
    run([
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
        "-ss", f"{cp.video_sec:.3f}", "-i", str(VIDEO),
        "-frames:v", "1", "-vf", vf, "-f", "image2", "-vcodec", "ppm",
        str(out_path),
    ])


def extract_full_ref_frame(video_sec: float, out_path: Path) -> None:
    run([
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
        "-ss", f"{video_sec:.3f}", "-i", str(VIDEO),
        "-frames:v", "1", "-vf", "format=rgb24", "-f", "image2",
        "-vcodec", "ppm", str(out_path),
    ])


def convert_ppm_to_png(ppm_path: Path) -> Path:
    png_path = ppm_path.with_suffix(".png")
    run([
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
        "-i", str(ppm_path), str(png_path),
    ])
    return png_path


def read_ppm_any(path: Path) -> tuple[int, int, bytes]:
    data = path.read_bytes()
    if not data.startswith(b"P6\n"):
        raise ValueError(f"{path} is not binary PPM")
    idx = 3
    tokens: list[bytes] = []
    while len(tokens) < 3:
        while data[idx:idx + 1].isspace():
            idx += 1
        if data[idx:idx + 1] == b"#":
            idx = data.index(b"\n", idx) + 1
            continue
        end = idx
        while not data[end:end + 1].isspace():
            end += 1
        tokens.append(data[idx:end])
        idx = end
    while data[idx:idx + 1].isspace():
        idx += 1
    width, height, maxval = map(int, tokens)
    if maxval != 255:
        raise ValueError(f"{path} has unexpected PPM maxval {maxval}")
    pixels = data[idx:]
    if len(pixels) != width * height * 3:
        raise ValueError(f"{path} has {len(pixels)} pixel bytes")
    return width, height, pixels


def read_ppm(path: Path) -> bytes:
    width, height, pixels = read_ppm_any(path)
    if (width, height) != (320, 200):
        raise ValueError(f"{path} has unexpected PPM header {width}x{height}/255")
    return pixels


def write_ppm(path: Path, pixels: bytes, width: int = 320, height: int = 200) -> None:
    if len(pixels) != width * height * 3:
        raise ValueError(f"cannot write {path}: wrong pixel byte count")
    path.write_bytes(f"P6\n{width} {height}\n255\n".encode("ascii") + pixels)


def detect_crop(video_sec: float, work_dir: Path) -> CropRect:
    full = work_dir / "crop_probe_full.ppm"
    extract_full_ref_frame(video_sec, full)
    width, height, pixels = read_ppm_any(full)
    if width < 640 or height < 400:
        raise ValueError(f"video frame {width}x{height} is too small for 640x400 viewport")
    if (width, height) == (642, 464):
        return CropRect(1, 64, 640, 400)

    best: tuple[int, int, int] | None = None
    max_x = width - 640
    max_y = height - 400
    # The DOS viewport is a 2x nearest-neighbor image. Search all plausible
    # 640x400 windows and choose the one with the strongest 2x2 block coherence.
    for y0 in range(max_y + 1):
        for x0 in range(max_x + 1):
            score = 0
            samples = 0
            for y in range(0, 400, 8):
                row0 = ((y0 + y) * width + x0) * 3
                row1 = ((y0 + y + 1) * width + x0) * 3
                for x in range(0, 640, 8):
                    a = row0 + x * 3
                    b = a + 3
                    c = row1 + x * 3
                    for channel in range(3):
                        av = pixels[a + channel]
                        score += abs(av - pixels[b + channel])
                        score += abs(av - pixels[c + channel])
                    samples += 1
            candidate = (score // max(samples, 1), x0, y0)
            if best is None or candidate < best:
                best = candidate
    if best is None:
        raise ValueError("could not detect crop")
    _, x, y = best
    return CropRect(x, y, 640, 400)


def read_pgm(path: Path) -> bytes:
    data = path.read_bytes()
    if not data.startswith(b"P5\n"):
        raise ValueError(f"{path} is not binary PGM")
    idx = 3
    tokens: list[bytes] = []
    while len(tokens) < 3:
        while data[idx:idx + 1].isspace():
            idx += 1
        if data[idx:idx + 1] == b"#":
            idx = data.index(b"\n", idx) + 1
            continue
        end = idx
        while not data[end:end + 1].isspace():
            end += 1
        tokens.append(data[idx:end])
        idx = end
    while data[idx:idx + 1].isspace():
        idx += 1
    width, height, maxval = map(int, tokens)
    if (width, height, maxval) != (320, 200, 255):
        raise ValueError(f"{path} has unexpected PGM header {width}x{height}/{maxval}")
    pixels = data[idx:]
    if len(pixels) != 320 * 200:
        raise ValueError(f"{path} has {len(pixels)} pixel bytes")
    return pixels


def rect_histogram(indices: bytes, rect: IndexRect) -> dict[str, int]:
    counts: dict[int, int] = {}
    for y in range(rect.y, rect.y + rect.h):
        if y < 0 or y >= 200:
            continue
        row = y * 320
        for x in range(rect.x, rect.x + rect.w):
            if x < 0 or x >= 320:
                continue
            value = indices[row + x]
            counts[value] = counts.get(value, 0) + 1
    return {f"{k:02x}": v for k, v in sorted(counts.items(), key=lambda item: (-item[1], item[0]))[:16]}


def rect_rgb_histogram(rgb: bytes, rect: IndexRect) -> dict[str, int]:
    counts: dict[tuple[int, int, int], int] = {}
    for y in range(rect.y, rect.y + rect.h):
        if y < 0 or y >= 200:
            continue
        row = y * 320 * 3
        for x in range(rect.x, rect.x + rect.w):
            if x < 0 or x >= 320:
                continue
            off = row + x * 3
            key = (rgb[off], rgb[off + 1], rgb[off + 2])
            counts[key] = counts.get(key, 0) + 1
    return {
        f"#{r:02x}{g:02x}{b:02x}": v
        for (r, g, b), v in sorted(counts.items(), key=lambda item: (-item[1], item[0]))[:16]
    }


def compare_rgb(a: bytes, b: bytes) -> dict[str, float]:
    if len(a) != len(b):
        raise ValueError("frame sizes differ")
    abs_sum = 0
    sq_sum = 0
    max_abs = 0
    nonzero = 0
    for av, bv in zip(a, b):
        d = abs(av - bv)
        abs_sum += d
        sq_sum += d * d
        max_abs = max(max_abs, d)
        if d:
            nonzero += 1
    n = len(a)
    return {
        "mae": abs_sum / n,
        "rmse": math.sqrt(sq_sum / n),
        "max_abs": max_abs,
        "changed_channel_ratio": nonzero / n,
    }


def diff_rgb(a: bytes, b: bytes, scale: int = 4) -> bytes:
    if len(a) != len(b):
        raise ValueError("frame sizes differ")
    out = bytearray(len(a))
    for i, (av, bv) in enumerate(zip(a, b)):
        out[i] = min(255, abs(av - bv) * scale)
    return bytes(out)


def contact_sheet_rgb(ref: bytes, wasm: bytes, diff: bytes) -> bytes:
    width = 320
    height = 200
    gap = 4
    out_width = width * 3 + gap * 2
    out = bytearray(out_width * height * 3)
    for y in range(height):
        dst_row = y * out_width * 3
        src_row = y * width * 3
        for panel, pixels in enumerate((ref, wasm, diff)):
            x0 = panel * (width + gap)
            dst = dst_row + x0 * 3
            out[dst:dst + width * 3] = pixels[src_row:src_row + width * 3]
    return bytes(out)


def find_free_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return int(s.getsockname()[1])


def start_vite_server(port: int) -> subprocess.Popen:
    npm = "npm.cmd" if os.name == "nt" else "npm"
    out_log = WEBPORT / "shell" / f"vite-compare-{port}.out.log"
    err_log = WEBPORT / "shell" / f"vite-compare-{port}.err.log"
    out = out_log.open("wb")
    err = err_log.open("wb")
    proc = subprocess.Popen(
        [npm, "run", "dev", "--", "--host", "127.0.0.1", "--port", str(port)],
        cwd=str(WEBPORT / "shell"),
        stdout=out,
        stderr=err,
    )
    deadline = time.time() + 20
    while time.time() < deadline:
        if proc.poll() is not None:
            raise RuntimeError(
                f"Vite exited early; see {out_log} and {err_log}"
            )
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=0.2):
                return proc
        except OSError:
            time.sleep(0.2)
    proc.terminate()
    raise RuntimeError(f"Vite did not start on port {port}; see {out_log} and {err_log}")


def convert_image_to_ppm(src: Path, dst: Path) -> None:
    run([
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
        "-i", str(src), "-vf", "scale=320:200:flags=neighbor,format=rgb24",
        "-f", "image2", "-vcodec", "ppm", str(dst),
    ])


def capture_wasm_frames(url: str, schedule_path: Path, out_dir: Path, tick_step_ms: float) -> None:
    run([
        "node", "capture_opening_wasm_frames.mjs",
        "--url", url,
        "--schedule", str(schedule_path.resolve()),
        "--out-dir", str(out_dir.resolve()),
        "--tick-step-ms", str(tick_step_ms),
        "--raw-ppm",
        "--quiet",
    ], cwd=WEBPORT / "shell")


def decode_nec_hou_sprite_debug(word: object, slots_word: object) -> dict[str, object]:
    if not isinstance(word, int) or word >= 0xFFFFFFFE:
        return {}
    if not isinstance(slots_word, int):
        slots_word = 0
    band_count = (word >> 24) & 0xFF
    slots = []
    for i in range(min(band_count, 8)):
        slot = (slots_word >> (i * 4)) & 0xF
        slots.append(-1 if slot == 0xF else slot)
    return {
        "wasm_sprite_frame": word & 0xFF,
        "wasm_sprite_frame_elapsed_ms": (word >> 8) & 0xFFFF,
        "wasm_dac_band_count": band_count,
        "wasm_dac_slots": slots,
    }


def run_sweep(distro: str, out_dir: Path) -> None:
    sweep_dir = out_dir / "sweep"
    sweep_dir.mkdir(parents=True, exist_ok=True)
    results = []

    for target in SWEEP_TARGETS:
        ref_ppm = sweep_dir / f"{target.name}_ref.ppm"
        extract_ref_frame(
            Checkpoint(target.name, target.video_sec, 0, 0, "sweep reference"),
            ref_ppm,
        )
        ref_pixels = read_ppm(ref_ppm)
        best: dict[str, object] | None = None
        for phase in target.phases:
            for elapsed_ms in range(target.start_ms, target.end_ms + 1, target.step_ms):
                c_ppm = sweep_dir / f"{target.name}_p{phase:02d}_{elapsed_ms:06d}.ppm"
                dump_c_frame_values(distro, phase, elapsed_ms, c_ppm)
                metrics = compare_rgb(read_ppm(c_ppm), ref_pixels)
                candidate = {
                    "name": target.name,
                    "video_sec": target.video_sec,
                    "phase": phase,
                    "elapsed_ms": elapsed_ms,
                    **metrics,
                    "c_frame": str(c_ppm),
                    "reference_frame": str(ref_ppm),
                }
                if best is None or metrics["rmse"] < float(best["rmse"]):
                    best = candidate
        if best is not None:
            convert_ppm_to_png(Path(str(best["c_frame"])))
            convert_ppm_to_png(ref_ppm)
            best["c_preview"] = str(Path(str(best["c_frame"])).with_suffix(".png"))
            best["reference_preview"] = str(ref_ppm.with_suffix(".png"))
            results.append(best)
            print(
                f"sweep {target.name}: best phase={best['phase']} "
                f"elapsed={best['elapsed_ms']}ms RMSE={best['rmse']:.2f}"
            )

    (sweep_dir / "summary.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
    print(f"wrote {sweep_dir / 'summary.json'}")


def run_index_report(distro: str, out_dir: Path) -> None:
    index_dir = out_dir / "indices"
    index_dir.mkdir(parents=True, exist_ok=True)
    report = []

    for name, video_sec, phase, elapsed_ms in INDEX_TARGETS:
        out_pgm = index_dir / f"{name}_p{phase:02d}_{elapsed_ms:06d}.pgm"
        c_ppm = index_dir / f"{name}_p{phase:02d}_{elapsed_ms:06d}.ppm"
        ref_ppm = index_dir / f"{name}_ref.ppm"
        dump_c_indices_values(distro, phase, elapsed_ms, out_pgm)
        dump_c_frame_values(distro, phase, elapsed_ms, c_ppm)
        extract_ref_frame(Checkpoint(name, video_sec, phase, elapsed_ms, "index report reference"),
                          ref_ppm)
        indices = read_pgm(out_pgm)
        c_rgb = read_ppm(c_ppm)
        ref_rgb = read_ppm(ref_ppm)
        item = {
            "name": name,
            "video_sec": video_sec,
            "phase": phase,
            "elapsed_ms": elapsed_ms,
            "index_frame": str(out_pgm),
            "c_frame": str(c_ppm),
            "reference_frame": str(ref_ppm),
            "rects": {
                rect.name: {
                    "x": rect.x,
                    "y": rect.y,
                    "w": rect.w,
                    "h": rect.h,
                    "top_indices": rect_histogram(indices, rect),
                    "top_c_rgb": rect_rgb_histogram(c_rgb, rect),
                    "top_reference_rgb": rect_rgb_histogram(ref_rgb, rect),
                }
                for rect in INDEX_RECTS
            },
        }
        report.append(item)
        print(f"indices {name}: wrote {out_pgm}")

    (index_dir / "summary.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(f"wrote {index_dir / 'summary.json'}")


def run_yuu_variant_sweep(distro: str, out_dir: Path) -> None:
    variant_dir = out_dir / "yuu_variants"
    variant_dir.mkdir(parents=True, exist_ok=True)
    results = []

    for name, video_sec, phase, elapsed_ms in INDEX_TARGETS:
        ref_ppm = variant_dir / f"{name}_ref.ppm"
        extract_ref_frame(Checkpoint(name, video_sec, phase, elapsed_ms, "YUU variant reference"),
                          ref_ppm)
        ref_pixels = read_ppm(ref_ppm)
        best: dict[str, object] | None = None
        for variant in range(9):
            c_ppm = variant_dir / f"{name}_variant{variant}_p{phase:02d}_{elapsed_ms:06d}.ppm"
            dump_c_frame_values(distro, phase, elapsed_ms, c_ppm, yuu_variant=variant)
            metrics = compare_rgb(read_ppm(c_ppm), ref_pixels)
            candidate = {
                "name": name,
                "video_sec": video_sec,
                "phase": phase,
                "elapsed_ms": elapsed_ms,
                "variant": variant,
                **metrics,
                "c_frame": str(c_ppm),
                "reference_frame": str(ref_ppm),
            }
            results.append(candidate)
            if best is None or metrics["rmse"] < float(best["rmse"]):
                best = candidate
        if best is not None:
            convert_ppm_to_png(Path(str(best["c_frame"])))
            convert_ppm_to_png(ref_ppm)
            best["c_preview"] = str(Path(str(best["c_frame"])).with_suffix(".png"))
            best["reference_preview"] = str(ref_ppm.with_suffix(".png"))
            print(
                f"variant {name}: best variant={best['variant']} "
                f"RMSE={best['rmse']:.2f}"
            )

    (variant_dir / "summary.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
    print(f"wrote {variant_dir / 'summary.json'}")


def run_wasm_timeline(args: argparse.Namespace) -> None:
    out_dir = args.out / "wasm_timeline"
    ref_dir = out_dir / "ref"
    wasm_dir = out_dir / "wasm"
    diff_dir = out_dir / "diff"
    sheet_dir = out_dir / "contact"
    for directory in (ref_dir, wasm_dir, diff_dir, sheet_dir):
        directory.mkdir(parents=True, exist_ok=True)

    requested_crop = parse_crop(args.crop)
    crop = requested_crop
    if crop is None:
        crop = detect_crop(args.video_start_sec + args.crop_probe_sec, out_dir)
    crop_info = {"x": crop.x, "y": crop.y, "w": crop.w, "h": crop.h}
    print(f"video crop: x={crop.x} y={crop.y} w={crop.w} h={crop.h}")

    step_ms = 1000.0 / args.fps
    total_samples = int(math.floor(args.duration_sec * args.fps)) + 1
    if args.max_samples > 0:
        total_samples = min(total_samples, args.max_samples)
    samples = []
    for i in range(total_samples):
        wasm_ms = int(round(args.start_ms + i * step_ms))
        samples.append({
            "index": i,
            "wasm_ms": wasm_ms,
            "video_sec": args.video_start_sec + wasm_ms / 1000.0,
            "file": f"wasm_{i:04d}_{wasm_ms:08d}.ppm",
        })

    schedule_path = out_dir / "wasm_schedule.json"
    schedule_path.write_text(json.dumps({"samples": samples}, indent=2), encoding="utf-8")

    vite_proc: subprocess.Popen | None = None
    url = args.url
    try:
        if args.start_server:
            port = args.port or find_free_port()
            vite_proc = start_vite_server(port)
            url = f"http://127.0.0.1:{port}/"
            print(f"started Vite on {url}")

        capture_wasm_frames(url, schedule_path, wasm_dir, args.tick_step_ms)

        capture_log_path = wasm_dir / "wasm_capture_log.json"
        capture_log = {}
        if capture_log_path.exists():
            for row in json.loads(capture_log_path.read_text(encoding="utf-8")):
                capture_log[int(row["index"])] = row

        results = []
        worst: list[dict[str, object]] = []
        for sample in samples:
            idx = int(sample["index"])
            wasm_ms = int(sample["wasm_ms"])
            video_sec = float(sample["video_sec"]) + args.video_offset_ms / 1000.0
            stem = f"{idx:04d}_{wasm_ms:08d}"
            ref_ppm = ref_dir / f"ref_{stem}.ppm"
            wasm_ppm = wasm_dir / f"wasm_{stem}.ppm"
            diff_ppm = diff_dir / f"diff_{stem}.ppm"
            sheet_ppm = sheet_dir / f"sheet_{stem}.ppm"

            extract_ref_frame(
                Checkpoint(stem, video_sec, 0, wasm_ms, "timeline reference"),
                ref_ppm,
                crop,
            )
            captured_wasm = wasm_dir / str(sample["file"])
            if captured_wasm.suffix.lower() == ".ppm":
                if captured_wasm.resolve() != wasm_ppm.resolve():
                    shutil.copyfile(captured_wasm, wasm_ppm)
            else:
                convert_image_to_ppm(captured_wasm, wasm_ppm)
            ref_pixels = read_ppm(ref_ppm)
            wasm_pixels = read_ppm(wasm_ppm)
            metrics = compare_rgb(wasm_pixels, ref_pixels)
            diff_pixels = diff_rgb(wasm_pixels, ref_pixels, args.diff_scale)
            write_ppm(diff_ppm, diff_pixels)
            write_ppm(sheet_ppm, contact_sheet_rgb(ref_pixels, wasm_pixels, diff_pixels),
                      width=968, height=200)
            convert_ppm_to_png(ref_ppm)
            convert_ppm_to_png(wasm_ppm)
            convert_ppm_to_png(diff_ppm)
            convert_ppm_to_png(sheet_ppm)

            item = {
                "index": idx,
                "wasm_ms": wasm_ms,
                "video_sec": video_sec,
                "crop": crop_info,
                **metrics,
                "reference_frame": str(ref_ppm),
                "wasm_frame": str(wasm_ppm),
                "diff_frame": str(diff_ppm),
                "contact_sheet": str(sheet_ppm),
            }
            if idx in capture_log:
                item.update({
                    "wasm_scene": capture_log[idx].get("scene"),
                    "wasm_phase": capture_log[idx].get("phase"),
                    "wasm_phase_elapsed_ms": capture_log[idx].get("phase_elapsed_ms"),
                })
                item.update(decode_nec_hou_sprite_debug(
                    capture_log[idx].get("nec_hou_sprite_debug_word"),
                    capture_log[idx].get("nec_hou_sprite_debug_slots"),
                ))
            results.append(item)
            worst.append(item)
            worst = sorted(worst, key=lambda row: float(row["rmse"]), reverse=True)[:args.keep_worst]
            print(
                f"{idx:04d} wasm={wasm_ms:8d}ms video={video_sec:9.3f}s "
                f"RMSE={metrics['rmse']:7.2f} MAE={metrics['mae']:6.2f}"
            )

        summary = {
            "video": str(VIDEO),
            "url": url,
            "fps": args.fps,
            "start_ms": args.start_ms,
            "duration_sec": args.duration_sec,
            "video_start_sec": args.video_start_sec,
            "video_offset_ms": args.video_offset_ms,
            "tick_step_ms": args.tick_step_ms,
            "crop": crop_info,
            "sample_count": len(results),
            "worst": worst,
            "wasm_phase_coverage": sorted({
                f"{row.get('wasm_scene')}:{row.get('wasm_phase')}"
                for row in results
                if row.get("wasm_scene") is not None and row.get("wasm_phase") is not None
            }),
            "frames": results,
        }
        (out_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
        print(f"wrote {out_dir / 'summary.json'}")
    finally:
        if vite_proc is not None and vite_proc.poll() is None:
            vite_proc.terminate()
            try:
                vite_proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                vite_proc.kill()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--distro", default="Ubuntu-24.04")
    parser.add_argument("--out", type=Path, default=OUT)
    parser.add_argument("--sweep", action="store_true",
                        help="search current C phase/time values for closest video-frame matches")
    parser.add_argument("--index-report", action="store_true",
                        help="dump raw framebuffer indices and rectangle histograms for suspect regions")
    parser.add_argument("--yuu-variant-sweep", action="store_true",
                        help="compare experimental YUU plane mappings against captured video frames")
    parser.add_argument("--wasm-timeline", action="store_true",
                        help="compare browser/WASM opening frames against cropped DOSBox video frames")
    parser.add_argument("--anchor",
                        help="named anchor from 6_WebPort/tests/opening_video_anchors.json")
    parser.add_argument("--list-anchors", action="store_true",
                        help="list available video/WASM alignment anchors")
    parser.add_argument("--url", default="http://127.0.0.1:5173/",
                        help="Vite URL for WASM capture")
    parser.add_argument("--start-server", action="store_true",
                        help="start a temporary Vite server for --wasm-timeline")
    parser.add_argument("--port", type=int, default=0,
                        help="port for --start-server; 0 chooses a free port")
    parser.add_argument("--crop", default="auto",
                        help="video crop as x:y:w:h, or auto for 640x400 viewport detection")
    parser.add_argument("--crop-probe-sec", type=float, default=1.0,
                        help="seconds after video_start_sec used for auto-crop probing")
    parser.add_argument("--video-start-sec", type=float, default=0.0,
                        help="video timestamp corresponding to WASM opening time 0")
    parser.add_argument("--video-offset-ms", type=float, default=0.0,
                        help="extra offset added to video timestamps during comparison")
    parser.add_argument("--start-ms", type=int,
                        help="WASM opening time for first sample")
    parser.add_argument("--duration-sec", type=float,
                        help="timeline duration to sample")
    parser.add_argument("--fps", type=float,
                        help="sample rate; 18.2065 approximates the DOS timer cadence")
    parser.add_argument("--pit-cadence", action="store_true",
                        help="sample at the DOS PIT cadence, 18.2065 Hz")
    parser.add_argument("--window-video-sec", type=float,
                        help="center a local comparison window on this source-video timestamp")
    parser.add_argument("--window-before-sec", type=float, default=2.0,
                        help="seconds before --window-video-sec to include")
    parser.add_argument("--window-after-sec", type=float, default=2.0,
                        help="seconds after --window-video-sec to include")
    parser.add_argument("--tick-step-ms", type=float, default=10.0,
                        help="deterministic WASM tick quantum during capture")
    parser.add_argument("--max-samples", type=int,
                        help="cap samples for quick runs; 0 means no cap")
    parser.add_argument("--diff-scale", type=int, default=4,
                        help="brightness multiplier for absolute-difference images")
    parser.add_argument("--keep-worst", type=int, default=20,
                        help="number of worst frames summarized at top level")
    args = parser.parse_args()
    max_samples_was_cli = "--max-samples" in sys.argv

    if args.list_anchors:
        list_anchors()
        return 0

    if args.anchor:
        anchor = load_anchor(args.anchor)
        anchor_video_sec = float(anchor["video_sec"])
        anchor_wasm_ms = int(anchor["wasm_ms"])
        args.video_start_sec = anchor_video_sec - anchor_wasm_ms / 1000.0
        defaults = anchor.get("comparison_defaults", {})
        if args.start_ms is None:
            args.start_ms = int(defaults.get("start_ms", anchor_wasm_ms))
        if args.duration_sec is None:
            args.duration_sec = float(defaults.get("duration_sec", 10.0))
        if args.fps is None:
            args.fps = float(defaults.get("fps", 18.2065))
        if args.max_samples is None:
            args.max_samples = int(defaults.get("max_samples", 120))
    if args.start_ms is None:
        args.start_ms = 0
    if args.duration_sec is None:
        args.duration_sec = 10.0
    if args.pit_cadence:
        args.fps = 18.2065
    if args.fps is None:
        args.fps = 18.2065
    if args.window_video_sec is not None:
        center_wasm_ms = int(round(
            (args.window_video_sec - args.video_start_sec - args.video_offset_ms / 1000.0) * 1000.0
        ))
        args.start_ms = max(0, int(round(center_wasm_ms - args.window_before_sec * 1000.0)))
        args.duration_sec = args.window_before_sec + args.window_after_sec
        if not max_samples_was_cli:
            args.max_samples = 0
    if args.max_samples is None:
        args.max_samples = 120

    if not VIDEO.exists():
        raise SystemExit(f"missing reference video: {VIDEO}")
    if shutil.which("ffmpeg") is None:
        raise SystemExit("ffmpeg not found on PATH")

    args.out.mkdir(parents=True, exist_ok=True)
    if args.wasm_timeline:
        run_wasm_timeline(args)
        return 0

    ensure_native_dumper(args.distro)
    if args.sweep:
        run_sweep(args.distro, args.out)
        return 0
    if args.index_report:
        run_index_report(args.distro, args.out)
        return 0
    if args.yuu_variant_sweep:
        run_yuu_variant_sweep(args.distro, args.out)
        return 0

    results = []
    for cp in CHECKPOINTS:
        c_ppm = args.out / f"{cp.name}_c.ppm"
        ref_ppm = args.out / f"{cp.name}_ref.ppm"
        dump_c_frame(args.distro, cp, c_ppm)
        extract_ref_frame(cp, ref_ppm)
        c_png = convert_ppm_to_png(c_ppm)
        ref_png = convert_ppm_to_png(ref_ppm)
        metrics = compare_rgb(read_ppm(c_ppm), read_ppm(ref_ppm))
        result = {
            "name": cp.name,
            "video_sec": cp.video_sec,
            "phase": cp.phase,
            "elapsed_ms": cp.elapsed_ms,
            "note": cp.note,
            **metrics,
            "c_frame": str(c_ppm),
            "reference_frame": str(ref_ppm),
            "c_preview": str(c_png),
            "reference_preview": str(ref_png),
        }
        results.append(result)
        print(
            f"{cp.name}: MAE={metrics['mae']:.2f} "
            f"RMSE={metrics['rmse']:.2f} max={metrics['max_abs']} "
            f"changed={metrics['changed_channel_ratio']:.3f}"
        )

    (args.out / "summary.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
    print(f"wrote {args.out / 'summary.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
