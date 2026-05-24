"""Helpers for using MASM-built EXE images with the existing flat-bin harness."""

from __future__ import annotations

import atexit
import tempfile
from pathlib import Path


_TEMP_FILES: list[Path] = []


def _cleanup() -> None:
    for path in _TEMP_FILES:
        try:
            path.unlink()
        except OSError:
            pass


atexit.register(_cleanup)


def materialize_mz_image(exe_path: Path, stem: str) -> Path:
    """Strip an MZ header and write the load image to a temporary flat file."""
    data = exe_path.read_bytes()
    if len(data) < 0x20 or data[:2] != b"MZ":
        raise ValueError(f"not an MZ executable: {exe_path}")
    header_paragraphs = int.from_bytes(data[8:10], "little")
    image_offset = header_paragraphs * 16
    image = data[image_offset:]
    with tempfile.NamedTemporaryFile(
            delete=False, prefix=f"{stem}_", suffix=".bin") as out_file:
        out_file.write(image)
        out = Path(out_file.name)
    _TEMP_FILES.append(out)
    return out
