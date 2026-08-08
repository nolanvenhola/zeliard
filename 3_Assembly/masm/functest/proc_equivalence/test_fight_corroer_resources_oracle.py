#!/usr/bin/env python3
"""Release-byte oracle for Corroer topology, persistence, and Pirika protection."""

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
    "grave_sprites": (0x9DE5, bytes((2, 61))),
    "grave_music": (0x9EAB, bytes((2, 90))),
}
HASHES = {
    "331MP50.mdt": "ab94a37b64917f7a10a54b9fb199dcdaab05d4c089d0fc88054bedbb854bb325",
    "332MP51.mdt": "c8ffd7c7a14f09b09617b18ba4c24c4e7526b8c88efe338ab82937cb89c4f106",
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
    corroer_doors = doors(corroer)
    cementar_doors = doors(cementar)
    expected_doors = [
        (9, 25, 0xC2, 12, 9, 25),
        (25, 14, 0xC2, 10, 47, 14),
        (88, 34, 0xC3, 12, 88, 34),
        (94, 10, 0x80, 133, 4, 255),
        (100, 59, 0xC4, 12, 100, 59),
        (131, 9, 0xC0, 133, 264, 255),
        (131, 53, 0x42, 12, 131, 53),
        (141, 62, 0xC2, 12, 141, 62),
        (206, 39, 0xC4, 12, 206, 39),
    ]
    expected_reverse_doors = [
        (9, 25, 0x82, 11, 9, 25),
        (88, 34, 0x83, 11, 88, 34),
        (100, 59, 0x84, 11, 100, 59),
        (131, 53, 0x82, 11, 131, 53),
        (141, 62, 0x82, 11, 141, 62),
        (206, 39, 0x84, 11, 206, 39),
    ]
    reverse_pairs = all(row in cementar_doors
                        for row in expected_reverse_doors)
    shape = (struct.unpack_from("<H", corroer, 2)[0], corroer[0x12],
             len(corroer_doors), *object_shape(corroer))
    links = linked_masks(corroer)
    expected_links = [
        (1, 0x22, 0x80), (18, 0x22, 0x40), (30, 0x22, 0x20),
        (44, 0x22, 0x10), (45, 0x22, 0x08), (50, 0x22, 0x04),
        (53, 0x22, 0x02), (56, 0x22, 0x01),
    ]

    # 200FIGHT:scan_outer_slot_match immediately returns for wearable ID 2.
    # That is the Pirika protection used by contact hazards such as Gelroid.
    pirika_gate = fight[0x14A0:0x14A8]
    pirika_ok = pirika_gate == bytes.fromhex("803e9e00027501c3")
    area5_slots = (bytes.fromhex("803e12c005") in fight and
                   fight.count(bytes.fromhex("803e12c005")) >= 2)
    contract = {
        "name": b"Cavern of Corroer" in corroer,
        "exact_doors": corroer_doors == expected_doors,
        "cementar_reverse_pairs": reverse_pairs,
        "pirika_id2_gate": pirika_ok,
        "area5_gelroid_slots": area5_slots,
    }
    ok = refs_ok and hashes_ok and all(contract.values()) and \
        links == expected_links and shape == (240, 5, 9, 49, 24, 0x1E)

    print("fight_corroer_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}"
                           for name, value in refs.items()))
    print("fight_corroer_topology: " +
          ("PASS" if all(contract.values()) else "FAIL") + f" {contract}")
    print("fight_corroer_map: " + ("PASS" if hashes_ok else "FAIL") +
          f" shape={shape} doors={corroer_doors} links={links}")
    print("fight_corroer_pirika: " + ("PASS" if pirika_ok else "FAIL") +
          f" gate={pirika_gate.hex()}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Corroer resources, routes, persistence, and hazards")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
