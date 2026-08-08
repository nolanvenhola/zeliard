#!/usr/bin/env python3
"""Release-byte oracle for Cementar and the Vista chamber handoff."""

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
    "grave_palette": (0x9C6F, bytes((2, 79))),
    "grave_ai": (0x9D14, bytes((2, 6))),
    "vista_code": (0x9D1F, bytes((2, 14))),
    "grave_sprites": (0x9DE5, bytes((2, 61))),
    "vista_sprites": (0x9DF0, bytes((2, 69))),
    "grave_music": (0x9EAB, bytes((2, 90))),
    "boss_music": (0x9ED7, bytes((2, 94))),
}
HASHES = {
    "331MP50.mdt": "ab94a37b64917f7a10a54b9fb199dcdaab05d4c089d0fc88054bedbb854bb325",
    "332MP51.mdt": "c8ffd7c7a14f09b09617b18ba4c24c4e7526b8c88efe338ab82937cb89c4f106",
    "333MP5D.mdt": "5163eb116c039b3b92cad56b0ece00b3af1a935a075b5bc80fbf7626239514f9",
    "305EAI5.bin": "1da372b13d26b4a70607a9a0d54d7db505dd6486bc22173b6d874b3f6bbe9410",
    "313MEDA.bin": "2aae9bee5cf6581507c2f1a5aca63b9083bb6dd6635e5dca69addb51d4e16c5c",
    "360ENP5.grp": "5489c7b79f6a061d3351a04f0d7d6dd19f5b2dc90c9659c50b564b41466559f8",
    "368MEDA.grp": "6822616f1c7e71e9b340e8c54f8100f1962fcc7c33772548bf822d60c2b2baaa",
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

    corroer = images["331MP50.mdt"]
    cementar = images["332MP51.mdt"]
    chamber = images["333MP5D.mdt"]
    cementar_doors = doors(cementar)
    corroer_doors = doors(corroer)
    topology = {
        "corroer_a": (9, 25, 0x82, 11, 9, 25) in cementar_doors,
        "corroer_b": (88, 34, 0x83, 11, 88, 34) in cementar_doors,
        "corroer_c": (100, 59, 0x84, 11, 100, 59) in cementar_doors,
        "corroer_d": (131, 53, 0x82, 11, 131, 53) in cementar_doors,
        "corroer_e": (206, 39, 0x84, 11, 206, 39) in cementar_doors,
        "reverse_a": (9, 25, 0xC2, 12, 9, 25) in corroer_doors,
        "vista_door": (157, 16, 0x01, 13, 17, 21) in cementar_doors,
    }
    shape = (struct.unpack_from("<H", cementar, 2)[0], cementar[0x12],
             len(cementar_doors), *object_shape(cementar))
    chamber_shape = (struct.unpack_from("<H", chamber, 2)[0], chamber[0x12])
    links = linked_masks(cementar)
    expected_links = [
        (7, 0x23, 0x40), (21, 0x23, 0x20), (26, 0x23, 0x10),
        (44, 0x23, 0x08), (47, 0x23, 0x04), (49, 0x23, 0x02),
        (53, 0x23, 0x01), (55, 0x24, 0x80), (60, 0x24, 0x20),
        (61, 0x24, 0x40),
    ]
    vista = images["313MEDA.bin"]
    boss_contract = {
        "completion_write": bytes.fromhex("c60630ffff") in vista,
        "vista_name": b"Vista" in vista,
        "encounter_resource": fight[0x9BF1 - LOAD_BASE:
                                    0x9BF3 - LOAD_BASE] == bytes((2, 56)),
        "chamber_name": b"Cavern of Cementar" in chamber,
    }
    ok = refs_ok and hashes_ok and all(topology.values()) and \
        links == expected_links and all(boss_contract.values()) and \
        shape == (240, 5, 7, 36, 34, 0x1E) and chamber_shape == (73, 5)

    print("fight_cementar_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}"
                           for name, value in refs.items()))
    print("fight_cementar_topology: " +
          ("PASS" if all(topology.values()) else "FAIL") + f" {topology}")
    print("fight_cementar_map: " + ("PASS" if hashes_ok else "FAIL") +
          f" shape={shape} chamber={chamber_shape} links={links}")
    print("fight_vista_handoff: " +
          ("PASS" if all(boss_contract.values()) else "FAIL") +
          f" {boss_contract}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Cementar resources, persistence, and Vista handoff")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
