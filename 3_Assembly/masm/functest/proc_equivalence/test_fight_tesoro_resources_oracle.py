#!/usr/bin/env python3
"""Release-byte oracle for Tesoro topology, persistence, and Tarso handoff."""

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
    "tarso_code": (0x9D35, bytes((2, 15))),
    "gold_sprites": (0x9DFB, bytes((2, 62))),
    "tarso_sprites": (0x9E06, bytes((2, 70))),
    "gold_music": (0x9EB6, bytes((2, 91))),
}
HASHES = {
    "334MP60.mdt": "fb7edfcf4e17c0f9c0a7004644af603d85bcc4023c66ed34fba8a32dbb2ad766",
    "335MP61.mdt": "b6368328e0e88ee3f4e64868a79127f30985aa5f5ab90fc461600e38ce61ac66",
    "337MP6D.mdt": "534d5fe2dd647ba2bb6c49ba365931c2931155102cb2a0d8cb5405e6c88f01d3",
    "306EAI6.bin": "87e10d8c62ad709f981f3c77e48f83074439779b0542a271523ac3dc7305541e",
    "314LEGA.bin": "8f660070d9c78a535862ce0afb9ec8dfb0c01a766bfd2e42fe74ed28a8dc0e7c",
    "361ENP6.grp": "6df8b6d5ac7ccf37d78fbea9d3928e72277356ddc1ac4736fbdfe959f6405ec7",
    "369LEGA.grp": "96b25f7bea9dd369c8088b947388bb20b2b3b79928b0f0f42700cd5f8171535e",
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
    chamber = images["337MP6D.mdt"]
    tesoro_doors = doors(tesoro)
    plata_doors = doors(plata)
    expected_doors = [
        (11, 41, 0x40, 18, 127, 7),
        (12, 27, 0xC1, 15, 12, 27),
        (14, 5, 0xC2, 13, 52, 21),
        (28, 46, 0xC2, 17, 47, 14),
        (30, 28, 0xC4, 15, 30, 28),
        (31, 5, 0x43, 16, 62, 13),
        (90, 37, 0xC4, 15, 90, 37),
        (131, 30, 0xC2, 15, 221, 1),
        (150, 30, 0xC2, 15, 150, 30),
        (169, 30, 0xC2, 15, 169, 30),
        (188, 30, 0xC1, 15, 188, 30),
        (249, 15, 0xC4, 15, 249, 15),
        (309, 41, 0x01, 17, 27, 14),
        (315, 48, 0x40, 6, 209, 255),
    ]
    expected_reverse = [
        (12, 27, 0x81, 14, 12, 27),
        (30, 28, 0x84, 14, 30, 28),
        (90, 37, 0x84, 14, 90, 37),
        (221, 1, 0x82, 14, 131, 30),
        (150, 30, 0x82, 14, 150, 30),
        (169, 30, 0x82, 14, 169, 30),
        (188, 30, 0x81, 14, 188, 30),
        (249, 15, 0x84, 14, 249, 15),
    ]
    expected_links = [
        (4, 0x2A, 0x80), (18, 0x2A, 0x40), (24, 0x2A, 0x20),
        (30, 0x2A, 0x10), (39, 0x2A, 0x08), (42, 0x2A, 0x04),
        (53, 0x2A, 0x02), (54, 0x2A, 0x01), (55, 0x2B, 0x80),
        (60, 0x2B, 0x40),
    ]
    links = linked_masks(tesoro)
    shape = (struct.unpack_from("<H", tesoro, 2)[0], tesoro[0x12],
             len(tesoro_doors), *object_shape(tesoro))
    chamber_shape = (struct.unpack_from("<H", chamber, 2)[0],
                     chamber[0x12], len(doors(chamber)),
                     *object_shape(chamber))
    contract = {
        "tesoro_name": b"Cavern of Tesoro" in tesoro,
        "exact_doors": tesoro_doors == expected_doors,
        "plata_reverse_links": all(row in plata_doors
                                    for row in expected_reverse),
        "tarso_door": (309, 41, 0x01, 17, 27, 14) in tesoro_doors,
        "dorado_exit": (315, 48, 0x40, 6, 209, 255) in tesoro_doors,
        "tarso_chamber": b"Cavern of Tesoro" in chamber,
    }
    tarso = images["314LEGA.bin"]
    boss_contract = {
        "damage_word": tarso[0x644:0x650] ==
            bytes.fromhex("a1a3a72bc3730233c0a3a3a7"),
        # LEGA resets both death animation states before arming FF2E. Unlike
        # earlier modules it returns directly; 200FIGHT observes FF2E next.
        "death_arm": tarso[0x65E:0x66E] ==
            bytes.fromhex("c606b8a700c606c2a700c6062effffc3"),
        "death_timer": tarso[0x66E:0x67E] ==
            bytes.fromhex("803eb8a728734dc6062ffffffe06b8a7"),
        "completion_write": tarso[0x6C2:0x6C8] ==
            bytes.fromhex("c60630ffffc3"),
        "tarso_name": b"Tarso" in tarso,
    }
    ok = refs_ok and hashes_ok and all(contract.values()) and \
        all(boss_contract.values()) and \
        links == expected_links and shape == (320, 6, 14, 45, 16, 0x1E) and \
        chamber_shape == (73, 6, 0, 0, 0, 0)

    print("fight_tesoro_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}"
                           for name, value in refs.items()))
    print("fight_tesoro_topology: " +
          ("PASS" if all(contract.values()) else "FAIL") + f" {contract}")
    print("fight_tarso_handoff: " +
          ("PASS" if all(boss_contract.values()) else "FAIL") +
          f" {boss_contract}")
    print("fight_tesoro_map: " + ("PASS" if hashes_ok else "FAIL") +
          f" shape={shape} chamber={chamber_shape} "
          f"doors={tesoro_doors} links={links}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Tesoro resources, persistence, and Tarso handoff")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
