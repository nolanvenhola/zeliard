#!/usr/bin/env python3
"""Release-byte oracle for Riza, Bosque, and the Pollo chamber handoff."""

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
    "forest_palette": (0x9C59, bytes((2, 77))),
    "forest_ai": (0x9CE8, bytes((2, 4))),
    "forest_sprites": (0x9DB9, bytes((2, 59))),
    "forest_music": (0x9E95, bytes((2, 88))),
    "pollo_code": (0x9CF3, bytes((2, 12))),
    "pollo_sprites": (0x9DC4, bytes((2, 67))),
}
HASHES = {
    "325MP30.mdt": "e8ac822b5c748a98eedcc691f24aa305c51595570eaeab127d8815fa56746feb",
    "326MP31.mdt": "4b54099bff4ab44ea5cae76fc554ad6c2c684a025a3d9922e330431fbe2b2ae3",
    "327MP3D.mdt": "b7a4df4e67ebff7ea3345701f5d1a25d2f0df645fa3b296a935ef9d4e99efd1e",
    "311TORI.bin": "a387232517b65a73853f57bf368a1c8b3a45ffe41607c38f056779267ec11aac",
    "366TORI.grp": "8681fe7105dcf38795407b08fc6dc822b7d13ae8567b41337ed3c59a7456ae5b",
}


def release_path(relative: str) -> Path:
    masm = MASM_ROOT / "bin" / relative
    tasm = MASM_ROOT.parent / "tasm" / "bin" / relative
    return masm if masm.exists() else tasm


def payload(path: Path) -> bytes:
    image = path.read_bytes()
    declared = struct.unpack_from("<I", image)[0]
    assert declared == len(image) - 4
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
         struct.unpack_from("<H", row, 5)[0],
         struct.unpack_from("<H", row, 7)[0])
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

    madera = images["325MP30.mdt"]
    riza = images["326MP31.mdt"]
    chamber = images["327MP3D.mdt"]
    riza_doors = doors(riza)
    topology = {
        "riza_to_madera": (19, 49, 0xC1, 5, 19, 49) in riza_doors,
        "madera_to_riza": any(row[3] == 6 for row in doors(madera)),
        "riza_to_bosque": (149, 13, 0x80, 3, 7, 255) in riza_doors,
        "pollo_door_left": (174, 4, 0xC2, 7, 52, 21) in riza_doors,
        "pollo_door_right": (188, 20, 0x01, 7, 17, 21) in riza_doors,
        "next_region_handoff": (192, 4, 0x40, 9, 99, 53) in riza_doors,
    }
    shape = (struct.unpack_from("<H", riza, 2)[0], riza[0x12],
             len(riza_doors), *object_shape(riza))
    chamber_shape = (struct.unpack_from("<H", chamber, 2)[0], chamber[0x12])
    links = linked_masks(riza)
    expected_links = [
        (0, 0x12, 0x02), (4, 0x12, 0x01), (20, 0x13, 0x80),
        (21, 0x13, 0x40), (34, 0x13, 0x20), (38, 0x13, 0x10),
    ]
    tori = images["311TORI.bin"]
    boss_contract = {
        "hero_crest_location": riza[0x13:0x16] == bytes.fromhex("bc0015"),
        # TORI applies BX damage to its 16-bit 500-point health word,
        # floors underflow to zero, then calls the release 200FIGHT
        # shutdown callback through DS:603Ch when death is armed.
        "damage_word": tori[0x5BA:0x5C6] ==
            bytes.fromhex("a176a72bc3730233c0a376a7"),
        "death_and_shutdown": tori[0x5D4:0x5DE] ==
            bytes.fromhex("c6062effff2eff163c60"),
        # The death animation increments A794 through exactly 0x28 states
        # before publishing the shared FF30 completion byte.
        "death_timer": tori[0x60A:0x614] ==
            bytes.fromhex("a094a73c287336c6062f"),
        "completion_write": tori[0x647:0x64D] ==
            bytes.fromhex("c60630ffffc3"),
        "shutdown_callback": fight[0x3C:0x3E] == bytes.fromhex("db83"),
        "pollo_name": b"\x05Pollo" in tori,
    }
    ok = refs_ok and hashes_ok and all(topology.values()) and \
        links == expected_links and all(boss_contract.values()) and \
        shape == (204, 3, 14, 36, 12, 0x0E) and \
        chamber_shape == (73, 3)

    print("fight_riza_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}"
                           for name, value in refs.items()))
    print("fight_riza_topology: " +
          ("PASS" if all(topology.values()) else "FAIL") + f" {topology}")
    print("fight_riza_map: " + ("PASS" if hashes_ok else "FAIL") +
          f" shape={shape} chamber={chamber_shape} links={links}")
    print("fight_pollo_handoff: " +
          ("PASS" if all(boss_contract.values()) else "FAIL") +
          f" {boss_contract}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Riza resources, routes, and Pollo handoff")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
