#!/usr/bin/env python3
"""Release-byte oracle for Plata resources, topology, and persistence."""

from __future__ import annotations

import hashlib
import struct
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402

LOAD_BASE = 0x6000
RESOURCE_REFS = {
    "gold_palette": (0x9C7A, bytes((2, 80))),
    "gold_ai": (0x9D2A, bytes((2, 7))),
    "gold_sprites": (0x9DFB, bytes((2, 62))),
    "gold_music": (0x9EB6, bytes((2, 91))),
}
HASHES = {
    "334MP60.mdt": "fb7edfcf4e17c0f9c0a7004644af603d85bcc4023c66ed34fba8a32dbb2ad766",
    "335MP61.mdt": "b6368328e0e88ee3f4e64868a79127f30985aa5f5ab90fc461600e38ce61ac66",
    "306EAI6.bin": "87e10d8c62ad709f981f3c77e48f83074439779b0542a271523ac3dc7305541e",
    "361ENP6.grp": "6df8b6d5ac7ccf37d78fbea9d3928e72277356ddc1ac4736fbdfe959f6405ec7",
}


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


def doors(data: bytes) -> list[tuple[int, int, int, int, int, int]]:
    return [
        (struct.unpack_from("<H", row)[0], row[2], row[3], row[4],
         struct.unpack_from("<H", row, 5)[0], row[7])
        for row in records(data, 0x0A, 12)
    ]


def object_shape(data: bytes) -> tuple[int, int, int]:
    monsters = items = families = 0
    for row in records(data, 0x10, 16):
        if row[14]:
            monsters += 1
            if 1 <= row[4] <= 8:
                families |= 1 << row[4]
        else:
            items += 1
    return monsters, items, families


def linked_masks(data: bytes) -> list[tuple[int, int, int]]:
    return [
        (index, struct.unpack_from("<H", row, 11)[0], row[13])
        for index, row in enumerate(records(data, 0x10, 16))
        if row[7] & 0x20
    ]


def main() -> int:
    fight_path, _ = BIN_PATHS["fight"]
    if not fight_path.exists():
        fight_path = release_path("zelres2/200FIGHT.bin")
    fight = payload(fight_path)
    refs = {
        name: fight[address - LOAD_BASE:address - LOAD_BASE + 2]
        for name, (address, _expected) in RESOURCE_REFS.items()
    }
    refs_ok = all(refs[name] == expected
                  for name, (_address, expected) in RESOURCE_REFS.items())

    images = {}
    hashes_ok = True
    for name, expected in HASHES.items():
        path = release_path(f"zelres3/{name}")
        hashes_ok &= hashlib.sha256(path.read_bytes()).hexdigest() == expected
        images[name] = payload(path)

    tesoro = images["334MP60.mdt"]
    plata = images["335MP61.mdt"]
    plata_doors = doors(plata)
    tesoro_doors = doors(tesoro)
    expected_doors = [
        (12, 27, 0x81, 14, 12, 27),
        (30, 28, 0x84, 14, 30, 28),
        (31, 5, 0x80, 6, 4, 255),
        (90, 37, 0x84, 14, 90, 37),
        (128, 41, 0x81, 15, 176, 57),
        (143, 62, 0xC4, 15, 177, 17),
        (146, 10, 0xC2, 15, 213, 50),
        (150, 30, 0x82, 14, 150, 30),
        (169, 30, 0x82, 14, 169, 30),
        (176, 57, 0xC1, 15, 128, 41),
        (177, 17, 0x84, 15, 143, 62),
        (188, 30, 0x81, 14, 188, 30),
        (213, 50, 0x82, 15, 146, 10),
        (221, 1, 0x82, 14, 131, 30),
        (249, 15, 0x84, 14, 249, 15),
    ]
    expected_reverse = [
        (12, 27, 0xC1, 15, 12, 27),
        (30, 28, 0xC4, 15, 30, 28),
        (90, 37, 0xC4, 15, 90, 37),
        (131, 30, 0xC2, 15, 221, 1),
        (150, 30, 0xC2, 15, 150, 30),
        (169, 30, 0xC2, 15, 169, 30),
        (188, 30, 0xC1, 15, 188, 30),
        (249, 15, 0xC4, 15, 249, 15),
    ]
    links = linked_masks(plata)
    expected_links = [
        (0, 0x2B, 0x02), (1, 0x2B, 0x01), (9, 0x2C, 0x80),
        (16, 0x2C, 0x40), (29, 0x2C, 0x20), (41, 0x2C, 0x10),
    ]
    shape = (struct.unpack_from("<H", plata, 2)[0], plata[0x12],
             len(plata_doors), *object_shape(plata))
    contract = {
        "plata_name": b"Cavern of Plata" in plata,
        "tesoro_name": b"Cavern of Tesoro" in tesoro,
        "exact_doors": plata_doors == expected_doors,
        "tesoro_reverse_links": all(row in tesoro_doors
                                    for row in expected_reverse),
        "dorado_exit": (31, 5, 0x80, 6, 4, 255) in plata_doors,
    }
    ok = refs_ok and hashes_ok and all(contract.values()) and \
        links == expected_links and shape == (256, 6, 15, 40, 20, 0x1E)

    print("fight_plata_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}"
                           for name, value in refs.items()))
    print("fight_plata_topology: " +
          ("PASS" if all(contract.values()) else "FAIL") + f" {contract}")
    print("fight_plata_map: " + ("PASS" if hashes_ok else "FAIL") +
          f" shape={shape} doors={plata_doors} links={links}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Plata resources, persistence, and Tesoro routes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
