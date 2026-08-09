#!/usr/bin/env python3
"""Release-byte oracle for merged-cavern environmental mechanics."""

from __future__ import annotations

import struct
import sys
from collections import Counter
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402
from test_mcga_render_entries_oracle import fill_buffer_decompress  # noqa: E402
from test_mcga_title_sweep_assets_oracle import decode_6de1  # noqa: E402

REPO_ROOT = HERE.parents[3]
sys.path.insert(0, str(REPO_ROOT))
from importlib import import_module  # noqa: E402

decode_mdt = import_module("4_Resources.MdtViewer.decoder").decode_mdt


def release_path(relative: str) -> Path:
    masm = MASM_ROOT / "bin" / relative
    tasm = MASM_ROOT.parent / "tasm" / "bin" / relative
    return masm if masm.exists() else tasm


def payload(path: Path) -> bytes:
    image = path.read_bytes()
    assert struct.unpack_from("<I", image)[0] == len(image) - 4
    return image[4:]


def records(data: bytes, pointer_offset: int, size: int) -> list[bytes]:
    offset = struct.unpack_from("<H", data, pointer_offset)[0] - 0xC000
    result = []
    while data[offset:offset + 2] != b"\xff\xff":
        result.append(data[offset:offset + size])
        offset += size
    return result


def components(grid: list[list[int]], tile_ids: set[int]) -> list[tuple]:
    height, width = len(grid), len(grid[0])
    seen: set[tuple[int, int]] = set()
    result = []
    for y in range(height):
        for x in range(width):
            if (x, y) in seen or grid[y][x] not in tile_ids:
                continue
            todo = [(x, y)]
            seen.add((x, y))
            points = []
            while todo:
                point = todo.pop()
                points.append(point)
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    neighbour = ((point[0] + dx) % width,
                                 (point[1] + dy) % height)
                    if (neighbour not in seen and
                            grid[neighbour[1]][neighbour[0]] in tile_ids):
                        seen.add(neighbour)
                        todo.append(neighbour)
            xs = [point[0] for point in points]
            ys = [point[1] for point in points]
            families = tuple(sorted(Counter(
                grid[py][px] for px, py in points).items()))
            result.append((len(points), (min(xs), min(ys), max(xs), max(ys)),
                           families))
    return sorted(result, key=lambda row: (row[1][1], row[1][0]))


def main() -> int:
    names = {
        "caliente": "338MP70.mdt",
        "correr": "340MP72.mdt",
        "corroer": "331MP50.mdt",
        "cementar": "332MP51.mdt",
        "riza": "326MP31.mdt",
    }
    maps = {name: payload(release_path(f"zelres3/{filename}"))
            for name, filename in names.items()}
    decoded = {name: decode_mdt(data) for name, data in maps.items()}

    mpp7 = decode_6de1(fill_buffer_decompress(
        release_path("zelres3/380MPP7.grp").read_bytes()))
    mpp5 = decode_6de1(fill_buffer_decompress(
        release_path("zelres3/378MPP5.grp").read_bytes()))
    family_tables = {
        # The GRP decoder includes the four bytes stripped by the loader
        # before the image is placed at ES:8000, so VM 8024 maps to 0x20.
        "area7": mpp7[0x20:0x2C].hex(),
        "area5": mpp5[0x20:0x2C].hex(),
    }
    family_ok = family_tables == {
        "area7": "2a0000002900000028000000",
        "area5": "000000002526000023240000",
    }

    correr_components = components(
        decoded["correr"].grid, {0x28, 0x29, 0x2A})
    correr_boxes = [row[1] for row in correr_components]
    expected_correr_boxes = [
        (10,4,13,11), (61,5,67,12), (42,6,45,11), (97,6,101,11),
        (119,6,122,11), (34,18,38,27), (60,20,64,27), (86,20,90,27),
        (0,22,127,27), (23,22,27,27), (107,27,111,39), (17,38,20,43),
        (45,38,49,43), (71,38,75,43), (122,38,126,43), (94,51,97,59),
        (111,51,115,59), (34,53,38,59), (123,54,127,59),
    ]
    correr_ok = (correr_boxes == expected_correr_boxes and
                  sum(row[0] for row in correr_components) == 600)

    corroer_components = components(
        decoded["corroer"].grid, {0x23, 0x24, 0x25, 0x26})
    corroer_contract = [(row[0], row[1]) for row in corroer_components]
    corroer_ok = corroer_contract == [
        (6, (17,26,18,28)), (6, (48,37,49,39)),
        (6, (48,46,49,48)), (6, (117,60,118,62)),
    ]

    platform_contract = {
        "caliente_vertical": [row.hex() for row in records(maps["caliente"], 4, 3)],
        "caliente_collapsing": [row.hex() for row in records(maps["caliente"], 6, 3)],
        "cementar_horizontal": [row.hex() for row in records(maps["cementar"], 8, 7)],
        "riza_horizontal": [row.hex() for row in records(maps["riza"], 8, 7)],
    }
    platforms_ok = platform_contract == {
        "caliente_vertical": ["070006","0e0003","170003","1c003f","1f003f",
                               "2d0019","40003f","5a0005","ba0004","c30031"],
        "caliente_collapsing": ["1a0027","1d0026","200024"],
        "cementar_horizontal": ["0480b9e7000b00","0940a604000e00",
                                  "0a408c06000c00","19803812002000",
                                  "2280b01b002800","2a80b823003100",
                                  "2b80a021003400","3740852e003f00",
                                  "70809a63007900","bd8085b600c000"],
        "riza_horizontal": ["6040aa5d006300"],
    }

    ok = family_ok and correr_ok and corroer_ok and platforms_ok
    print("fight_environment: " + ("PASS" if family_ok else "FAIL") +
          f" move_slots={family_tables}")
    print("fight_environment_correr: " + ("PASS" if correr_ok else "FAIL") +
          f" components={len(correr_components)} cells={sum(r[0] for r in correr_components)}")
    print("fight_environment_corroer: " + ("PASS" if corroer_ok else "FAIL") +
          f" paths={corroer_contract}")
    print("fight_environment_platforms: " + ("PASS" if platforms_ok else "FAIL") +
          f" contract={platform_contract}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM environmental movement and hidden-path topology")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
