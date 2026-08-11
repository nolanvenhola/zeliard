import struct
import tempfile
import unittest
import zlib
from pathlib import Path

from scripts.visual.parity_artifact import (
    Capture, HEIGHT, WIDTH, compare, dac6_to_rgb8, normalize_mcga,
    normalize_planar, read_indexed_png,
)


class VisualParityTests(unittest.TestCase):
    def setUp(self):
        self.indices = bytes((x // 20 + y // 25) & 15 for y in range(HEIGHT) for x in range(WIDTH))
        self.palette = bytes(component for i in range(256) for component in (i, 255 - i, i // 2))

    def test_known_mcga_frame_decodes_320_by_200(self):
        raw = self.indices + bytes(1536)
        self.assertEqual(normalize_mcga(raw), self.indices)

    def test_dosboxx_raw_indexed_scan_doubling_decodes_guest_frame(self):
        width, height = 640, 400
        doubled = bytes(self.indices[(y // 2) * WIDTH + (x // 2)]
                        for y in range(height) for x in range(width))
        rows = b"".join(b"\0" + doubled[y * width:(y + 1) * width] for y in range(height))
        def chunk(kind, payload):
            body = kind + payload
            return struct.pack(">I", len(payload)) + body + struct.pack(">I", zlib.crc32(body) & 0xffffffff)
        png = b"\x89PNG\r\n\x1a\n"
        png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 3, 0, 0, 0))
        png += chunk(b"PLTE", self.palette)
        png += chunk(b"IDAT", zlib.compress(rows)) + chunk(b"IEND", b"")
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "zeliad_000.raw1.png"
            path.write_bytes(png)
            indices, palette = read_indexed_png(path)
        self.assertEqual(indices, self.indices)
        self.assertEqual(palette, self.palette)

    def test_planar_normalization_is_msb_first_and_plane_zero_is_lsb(self):
        planes = bytearray(4 * 8000)
        # Pixel 0 is colour 5 (planes 0 and 2); pixel 319 is colour 10.
        planes[0] |= 0x80
        planes[2 * 8000] |= 0x80
        planes[8000 + 7999] |= 0x01
        planes[3 * 8000 + 7999] |= 0x01
        decoded = normalize_planar(bytes(planes))
        self.assertEqual(decoded[0], 5)
        self.assertEqual(decoded[-1], 10)

    def test_palette_only_change_fails_independently(self):
        changed = bytearray(self.palette)
        changed[7 * 3] ^= 1
        with tempfile.TemporaryDirectory() as temp:
            report = compare(Capture("town", "masm", self.indices, self.palette),
                             Capture("town", "wasm", self.indices, bytes(changed)), Path(temp))
            self.assertTrue(report["indexEqual"])
            self.assertFalse(report["paletteEqual"])
            self.assertEqual(report["paletteDiffEntries"], [7])

    def test_repaired_final_frame_still_fails_wrong_draw_order(self):
        correct = ({"op": "background", "x": 0, "y": 0, "width": 8, "height": 8, "hash": "a"},
                   {"op": "sprite", "x": 2, "y": 2, "width": 2, "height": 2, "hash": "b"})
        wrong = (correct[1], correct[0], correct[1])
        with tempfile.TemporaryDirectory() as temp:
            report = compare(Capture("draw", "masm", self.indices, self.palette, trace=correct),
                             Capture("draw", "wasm", self.indices, self.palette, trace=wrong), Path(temp))
            self.assertTrue(report["indexEqual"])
            self.assertFalse(report["traceEqual"])

    def test_forensics_include_bounds_and_images(self):
        changed = bytearray(self.indices)
        changed[12 * WIDTH + 9] ^= 1
        changed[15 * WIDTH + 14] ^= 1
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp)
            report = compare(Capture("checkpoint-7", "masm", self.indices, self.palette),
                             Capture("checkpoint-7", "wasm", bytes(changed), self.palette), out)
            self.assertEqual(report["checkpoint"], "checkpoint-7")
            self.assertEqual(report["changedPixelBounds"], {"x": 9, "y": 12, "width": 6, "height": 4, "pixels": 2})
            for name in ("reference.png", "candidate.png", "diff.png", "report.json"):
                self.assertTrue((out / name).is_file())

    def test_animation_masks_are_diagnostic_not_exact_hash_exceptions(self):
        changed = bytearray(self.indices)
        changed[12 * WIDTH + 9] ^= 1
        mask = ({"x": 8, "y": 11, "width": 3, "height": 3},)
        with tempfile.TemporaryDirectory() as temp:
            report = compare(Capture("animated", "masm", self.indices, self.palette,
                                     masked_rects=mask),
                             Capture("animated", "wasm", bytes(changed), self.palette), Path(temp))
        self.assertFalse(report["indexEqual"])
        self.assertTrue(report["maskedIndexEqual"])

    def test_dac_expansion_uses_all_eight_bits(self):
        self.assertEqual(dac6_to_rgb8(bytes((0, 1, 63))), bytes((0, 4, 255)))


if __name__ == "__main__":
    unittest.main()
