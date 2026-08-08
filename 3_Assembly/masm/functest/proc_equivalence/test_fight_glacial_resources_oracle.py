#!/usr/bin/env python3
"""Release-byte oracle for Glacial and the Agar chamber handoff."""

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
    "ice_palette": (0x9C64, bytes((2, 78))),
    "ice_ai": (0x9CFE, bytes((2, 5))),
    "agar_code": (0x9D09, bytes((2, 13))),
    "ice_sprites": (0x9DCF, bytes((2, 60))),
    "agar_sprites": (0x9DDA, bytes((2, 68))),
    "ice_music": (0x9EA0, bytes((2, 89))),
    "boss_music": (0x9ED7, bytes((2, 94))),
}
HASHES = {
    "328MP40.mdt": "45b8011d17f6be5207f87040ae5bbb3f0ec3349ea87ae91526f36171fdc042fc",
    "330MP4D.mdt": "f6d72154c8bc0f379511516235b50096b5feb23295600c89ad891358772f2df2",
    "312ZELA.bin": "93fe0e0b96810082867875884b142ed75548617e47491fa7f7c518bb43c8f875",
    "367ZELA.grp": "ff2ec29b24d111d28b9d1727ffc7ae93b7c1cb193e97036b84a3d155c424d99f",
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

    glacial = images["328MP40.mdt"]
    chamber = images["330MP4D.mdt"]
    glacial_doors = doors(glacial)
    topology = {
        "helada_exit": (86, 21, 0x80, 4, 4, 255) in glacial_doors,
        "agar_door": (224, 18, 0x01, 10, 27, 14) in glacial_doors,
        "escarcha_a": (22, 9, 0x83, 9, 56, 55) in glacial_doors,
        "escarcha_b": (119, 21, 0x83, 9, 16, 34) in glacial_doors,
        "escarcha_c": (245, 53, 0x84, 9, 174, 51) in glacial_doors,
    }
    shape = (struct.unpack_from("<H", glacial, 2)[0], glacial[0x12],
             len(glacial_doors), *object_shape(glacial))
    chamber_shape = (struct.unpack_from("<H", chamber, 2)[0], chamber[0x12])
    links = linked_masks(glacial)
    expected_links = [
        (0, 0x1A, 0x80), (6, 0x1A, 0x40), (14, 0x1A, 0x20),
        (26, 0x1A, 0x10), (31, 0x1A, 0x08), (38, 0x1A, 0x04),
        (42, 0x1A, 0x02), (45, 0x1A, 0x01),
    ]
    agar = images["312ZELA.bin"]
    boss_contract = {
        "completion_write": bytes.fromhex("c60630ffff") in agar,
        "encounter_resource": fight[0x9BF1 - LOAD_BASE:
                                    0x9BF3 - LOAD_BASE] == bytes((2, 56)),
        # MP4D retains the parent cavern label in the authored HUD record;
        # Agar's identity comes from the ZELA boss module/resource dispatch.
        "chamber_name": b"Cavern of Glacial" in chamber,
    }
    ok = refs_ok and hashes_ok and all(topology.values()) and \
        links == expected_links and all(boss_contract.values()) and \
        shape == (320, 4, 6, 38, 31, 0x1E) and chamber_shape == (73, 4)

    print("fight_glacial_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}"
                           for name, value in refs.items()))
    print("fight_glacial_topology: " +
          ("PASS" if all(topology.values()) else "FAIL") + f" {topology}")
    print("fight_glacial_map: " + ("PASS" if hashes_ok else "FAIL") +
          f" shape={shape} chamber={chamber_shape} links={links}")
    print("fight_agar_handoff: " +
          ("PASS" if all(boss_contract.values()) else "FAIL") +
          f" {boss_contract}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Glacial resources, persistence, and Agar handoff")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
