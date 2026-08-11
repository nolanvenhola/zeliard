#!/usr/bin/env python3
"""Canonical guest-video captures and diagnostics for Zeliard parity tests.

The on-disk contract deliberately stores palette indices separately from the
DAC.  A visually identical RGB image is not sufficient evidence: changing an
unused DAC entry must still be visible, and changing indices to equivalent RGB
colours must still fail the index comparison.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
import zlib
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

SCHEMA_VERSION = 1
WIDTH = 320
HEIGHT = 200


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _png_chunk(kind: bytes, payload: bytes) -> bytes:
    body = kind + payload
    return struct.pack(">I", len(payload)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)


def write_rgb_png(path: Path, width: int, height: int, rgb: bytes) -> None:
    if len(rgb) != width * height * 3:
        raise ValueError("RGB payload has the wrong size")
    rows = bytearray()
    stride = width * 3
    for y in range(height):
        rows.append(0)  # PNG filter: None
        rows.extend(rgb[y * stride:(y + 1) * stride])
    png = b"\x89PNG\r\n\x1a\n"
    png += _png_chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    png += _png_chunk(b"IDAT", zlib.compress(bytes(rows), 9))
    png += _png_chunk(b"IEND", b"")
    path.write_bytes(png)


def read_indexed_png(path: Path, target_width: int = WIDTH,
                     target_height: int = HEIGHT) -> tuple[bytes, bytes]:
    """Read DOSBox-X's 8-bit ``raw1.png`` and remove integer scan doubling.

    The downsample is intentionally strict: every host-side duplicate in a
    guest pixel block must carry the same palette index. A filtered/scaled
    screenshot is rejected rather than silently becoming parity evidence.
    """
    data = path.read_bytes()
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("not a PNG file")
    at, width, height, palette, compressed = 8, 0, 0, b"", bytearray()
    while at < len(data):
        length = struct.unpack(">I", data[at:at + 4])[0]
        kind = data[at + 4:at + 8]
        payload = data[at + 8:at + 8 + length]
        at += 12 + length
        if kind == b"IHDR":
            width, height, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", payload)
            if (depth, color, compression, filtering, interlace) != (8, 3, 0, 0, 0):
                raise ValueError("capture must be a non-interlaced 8-bit indexed PNG")
        elif kind == b"PLTE":
            palette = payload
        elif kind == b"IDAT":
            compressed.extend(payload)
        elif kind == b"IEND":
            break
    if not width or not height or not palette:
        raise ValueError("indexed PNG is missing IHDR or PLTE")
    raw = zlib.decompress(bytes(compressed))
    stride = width
    if len(raw) != (stride + 1) * height:
        raise ValueError("unexpected indexed PNG scanline size")
    pixels = bytearray(width * height)
    previous = bytearray(stride)
    for y in range(height):
        start = y * (stride + 1)
        filter_type = raw[start]
        encoded = raw[start + 1:start + 1 + stride]
        row = bytearray(stride)
        for x, value in enumerate(encoded):
            left = row[x - 1] if x else 0
            up = previous[x]
            upper_left = previous[x - 1] if x else 0
            if filter_type == 0:
                predictor = 0
            elif filter_type == 1:
                predictor = left
            elif filter_type == 2:
                predictor = up
            elif filter_type == 3:
                predictor = (left + up) // 2
            elif filter_type == 4:
                p = left + up - upper_left
                distances = (abs(p - left), abs(p - up), abs(p - upper_left))
                predictor = (left, up, upper_left)[distances.index(min(distances))]
            else:
                raise ValueError(f"unsupported PNG filter {filter_type}")
            row[x] = (value + predictor) & 0xFF
        pixels[y * width:(y + 1) * width] = row
        previous = row
    if width % target_width or height % target_height:
        raise ValueError(f"capture {width}x{height} is not an integer multiple of the guest surface")
    scale_x, scale_y = width // target_width, height // target_height
    indices = bytearray(target_width * target_height)
    for y in range(target_height):
        for x in range(target_width):
            value = pixels[(y * scale_y) * width + x * scale_x]
            for dy in range(scale_y):
                begin = (y * scale_y + dy) * width + x * scale_x
                if any(sample != value for sample in pixels[begin:begin + scale_x]):
                    raise ValueError("DOSBox-X capture contains scaled or filtered pixels")
            indices[y * target_width + x] = value
    return bytes(indices), palette.ljust(256 * 3, b"\0")[:256 * 3]


def dac6_to_rgb8(dac: bytes) -> bytes:
    """Expand VGA 6-bit DAC components using the hardware-faithful mapping."""
    return bytes(((value & 0x3F) << 2) | ((value & 0x3F) >> 4) for value in dac)


def normalize_mcga(memory: bytes, width: int = WIDTH, height: int = HEIGHT) -> bytes:
    needed = width * height
    if len(memory) < needed:
        raise ValueError(f"MCGA dump needs {needed} bytes, got {len(memory)}")
    return memory[:needed]


def normalize_planar(memory: bytes, planes: int = 4, width: int = WIDTH,
                     height: int = HEIGHT, plane_stride: int | None = None) -> bytes:
    """Decode sequential MSB-first EGA-style bit planes to palette indices.

    Each plane is a complete 1bpp image. ``plane_stride`` can include padding;
    when omitted it is exactly ``ceil(width / 8) * height``. Plane zero is the
    least-significant palette-index bit, matching the EGA graphics controller.
    """
    row_bytes = (width + 7) // 8
    stride = plane_stride or row_bytes * height
    needed = stride * planes
    if len(memory) < needed:
        raise ValueError(f"planar dump needs {needed} bytes, got {len(memory)}")
    out = bytearray(width * height)
    for plane in range(planes):
        base = plane * stride
        mask_value = 1 << plane
        for y in range(height):
            row = base + y * row_bytes
            for x in range(width):
                if memory[row + x // 8] & (0x80 >> (x & 7)):
                    out[y * width + x] |= mask_value
    return bytes(out)


def indexed_to_rgb(indices: bytes, palette: bytes) -> bytes:
    if len(palette) % 3:
        raise ValueError("palette must contain RGB triples")
    colors = len(palette) // 3
    out = bytearray(len(indices) * 3)
    for pos, index in enumerate(indices):
        if index >= colors:
            raise ValueError(f"palette index {index} exceeds {colors} entries")
        out[pos * 3:pos * 3 + 3] = palette[index * 3:index * 3 + 3]
    return bytes(out)


def _is_masked(pixel: int, width: int, masks: Sequence[dict]) -> bool:
    x, y = pixel % width, pixel // width
    return any(mask["x"] <= x < mask["x"] + mask["width"] and
               mask["y"] <= y < mask["y"] + mask["height"] for mask in masks)


def changed_bounds(a: bytes, b: bytes, width: int, height: int,
                   masks: Sequence[dict] = ()) -> dict | None:
    changed = [i for i, pair in enumerate(zip(a, b))
               if pair[0] != pair[1] and not _is_masked(i, width, masks)]
    if len(a) != len(b):
        raise ValueError("buffers must have equal lengths")
    if not changed:
        return None
    xs = [i % width for i in changed]
    ys = [i // width for i in changed]
    return {"x": min(xs), "y": min(ys), "width": max(xs) - min(xs) + 1,
            "height": max(ys) - min(ys) + 1, "pixels": len(changed)}


def trace_signature(events: Sequence[dict]) -> list[tuple]:
    """Keep order-sensitive render semantics while ignoring commentary fields."""
    return [(event.get("op"), event.get("x"), event.get("y"),
             event.get("width"), event.get("height"), event.get("hash"),
             event.get("paletteHash"))
            for event in events]


@dataclass(frozen=True)
class Capture:
    checkpoint: str
    runtime: str
    indices: bytes
    palette: bytes
    width: int = WIDTH
    height: int = HEIGHT
    mode: str = "mcga-320x200x8"
    trace: tuple[dict, ...] = ()
    masked_rects: tuple[dict, ...] = ()

    def write(self, directory: Path) -> Path:
        if len(self.indices) != self.width * self.height:
            raise ValueError("indexed framebuffer has the wrong size")
        if len(self.palette) != 256 * 3:
            raise ValueError("canonical palette must contain 256 RGB triples")
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "framebuffer.bin").write_bytes(self.indices)
        (directory / "palette.rgb").write_bytes(self.palette)
        if self.trace:
            (directory / "render-trace.jsonl").write_text(
                "".join(json.dumps(event, sort_keys=True) + "\n" for event in self.trace),
                encoding="utf-8")
        write_rgb_png(directory / "frame.png", self.width, self.height,
                      indexed_to_rgb(self.indices, self.palette))
        manifest = {
            "schemaVersion": SCHEMA_VERSION,
            "checkpoint": self.checkpoint,
            "runtime": self.runtime,
            "videoMode": self.mode,
            "width": self.width,
            "height": self.height,
            "indexSha256": _sha256(self.indices),
            "paletteSha256": _sha256(self.palette),
            "traceSha256": _sha256(json.dumps(list(self.trace), sort_keys=True).encode()),
            "maskedRects": list(self.masked_rects),
            "files": {"indices": "framebuffer.bin", "palette": "palette.rgb",
                      "image": "frame.png", "trace": "render-trace.jsonl" if self.trace else None},
        }
        path = directory / "manifest.json"
        path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
        return path

    @classmethod
    def read(cls, directory: Path) -> "Capture":
        manifest = json.loads((directory / "manifest.json").read_text(encoding="utf-8"))
        if manifest["schemaVersion"] != SCHEMA_VERSION:
            raise ValueError(f"unsupported visual schema {manifest['schemaVersion']}")
        trace_path = directory / "render-trace.jsonl"
        trace = tuple(json.loads(line) for line in trace_path.read_text(encoding="utf-8").splitlines()) if trace_path.exists() else ()
        return cls(manifest["checkpoint"], manifest["runtime"],
                   (directory / "framebuffer.bin").read_bytes(),
                   (directory / "palette.rgb").read_bytes(), manifest["width"],
                   manifest["height"], manifest["videoMode"], trace,
                   tuple(manifest.get("maskedRects", ())))


def compare(reference: Capture, candidate: Capture, output: Path) -> dict:
    if (reference.width, reference.height) != (candidate.width, candidate.height):
        raise ValueError("capture dimensions differ")
    output.mkdir(parents=True, exist_ok=True)
    width, height = reference.width, reference.height
    bounds = changed_bounds(reference.indices, candidate.indices, width, height)
    masks = reference.masked_rects
    masked_bounds = changed_bounds(reference.indices, candidate.indices, width, height, masks)
    palette_entries = [i for i in range(256)
                       if reference.palette[i * 3:i * 3 + 3] != candidate.palette[i * 3:i * 3 + 3]]
    trace_equal = trace_signature(reference.trace) == trace_signature(candidate.trace)
    ref_rgb = indexed_to_rgb(reference.indices, reference.palette)
    candidate_rgb = indexed_to_rgb(candidate.indices, candidate.palette)
    diff_rgb = bytearray(width * height * 3)
    for pixel in range(width * height):
        changed = (reference.indices[pixel] != candidate.indices[pixel] or
                   ref_rgb[pixel * 3:pixel * 3 + 3] != candidate_rgb[pixel * 3:pixel * 3 + 3])
        diff_rgb[pixel * 3:pixel * 3 + 3] = b"\xff\x00\xff" if changed else b"\x00\x00\x00"
    write_rgb_png(output / "reference.png", width, height, ref_rgb)
    write_rgb_png(output / "candidate.png", width, height, candidate_rgb)
    write_rgb_png(output / "diff.png", width, height, bytes(diff_rgb))
    report = {
        "schemaVersion": SCHEMA_VERSION,
        "checkpoint": reference.checkpoint,
        "indexEqual": reference.indices == candidate.indices,
        "maskedIndexEqual": masked_bounds is None,
        "paletteEqual": not palette_entries,
        "traceEqual": trace_equal,
        "changedPixelBounds": bounds,
        "unmaskedChangedPixelBounds": masked_bounds,
        "maskedRects": list(masks),
        "paletteDiffEntries": palette_entries,
        "reference": {"runtime": reference.runtime, "indexSha256": _sha256(reference.indices),
                      "paletteSha256": _sha256(reference.palette)},
        "candidate": {"runtime": candidate.runtime, "indexSha256": _sha256(candidate.indices),
                      "paletteSha256": _sha256(candidate.palette)},
    }
    (output / "report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    return report


def _main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    capture = sub.add_parser("capture", help="normalize raw guest memory into an artifact")
    capture.add_argument("--mode", choices=("mcga", "ega-planar", "dosboxx-indexed-png"), required=True)
    capture.add_argument("--memory", type=Path, required=True)
    capture.add_argument("--palette", type=Path)
    capture.add_argument("--dac6", action="store_true")
    capture.add_argument("--checkpoint", required=True)
    capture.add_argument("--runtime", required=True)
    capture.add_argument("--output", type=Path, required=True)
    diff = sub.add_parser("compare")
    diff.add_argument("reference", type=Path)
    diff.add_argument("candidate", type=Path)
    diff.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.command == "capture":
        if args.mode == "dosboxx-indexed-png":
            indices, palette = read_indexed_png(args.memory)
        else:
            if not args.palette:
                parser.error("--palette is required for raw memory captures")
            raw = args.memory.read_bytes()
            indices = normalize_mcga(raw) if args.mode == "mcga" else normalize_planar(raw)
            palette = args.palette.read_bytes()
            if args.dac6:
                palette = dac6_to_rgb8(palette)
        Capture(args.checkpoint, args.runtime, indices, palette,
                mode="ega-planar-320x200x4" if args.mode == "ega-planar" else "mcga-320x200x8").write(args.output)
        return 0
    report = compare(Capture.read(args.reference), Capture.read(args.candidate), args.output)
    print(json.dumps(report, indent=2))
    return 0 if report["indexEqual"] and report["paletteEqual"] and report["traceEqual"] else 1


if __name__ == "__main__":
    raise SystemExit(_main())
