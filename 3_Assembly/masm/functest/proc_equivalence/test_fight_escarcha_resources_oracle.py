#!/usr/bin/env python3
"""Release-byte oracle for Escarcha resources, routes, and ice movement."""

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
    "ice_sprites": (0x9DCF, bytes((2, 60))),
    "ice_music": (0x9EA0, bytes((2, 89))),
}
MAP_HASHES = {
    "328MP40.mdt": "45b8011d17f6be5207f87040ae5bbb3f0ec3349ea87ae91526f36171fdc042fc",
    "329MP41.mdt": "8e30300abec8aa83ad5acc8c7cc24699e19254741a4e5a831c44b934caea6ff0",
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


def doors(data: bytes) -> list[tuple[int, int, int, int, int]]:
    return [
        (struct.unpack_from("<H", row)[0], row[2], row[4],
         struct.unpack_from("<H", row, 5)[0], row[7])
        for row in records(data, 0x0A, 12)
    ]


def object_shape(data: bytes) -> tuple[int, int, int]:
    monsters = items = families = 0
    for row in records(data, 0x10, 16):
        if row[14]:
            monsters += 1
            if 1 <= row[4] <= 4:
                families |= 1 << row[4]
        else:
            items += 1
    return monsters, items, families


def persistent_links(data: bytes) -> list[tuple[int, int, int]]:
    return [
        (index, struct.unpack_from("<H", row, 11)[0], row[13])
        for index, row in enumerate(records(data, 0x10, 16))
        if row[7] & 0x20
    ]


def main() -> int:
    fight_path, _ = BIN_PATHS["fight"]
    fight = payload(fight_path)
    refs = {
        name: fight[address - LOAD_BASE:address - LOAD_BASE + 2]
        for name, (address, _expected) in RESOURCE_REFS.items()
    }
    refs_ok = all(refs[name] == expected
                  for name, (_address, expected) in RESOURCE_REFS.items())

    maps = {}
    hashes_ok = True
    for name, expected in MAP_HASHES.items():
        path = release_path(f"zelres3/{name}")
        hashes_ok &= hashlib.sha256(path.read_bytes()).hexdigest() == expected
        maps[name] = payload(path)

    mp40 = maps["328MP40.mdt"]
    mp41 = maps["329MP41.mdt"]
    mp40_doors = doors(mp40)
    mp41_doors = doors(mp41)
    topology = {
        "helada_left_entry": (86, 21, 4, 4, 255) in mp40_doors,
        "escarcha_to_glacial_a": (22, 9, 9, 56, 55) in mp40_doors,
        "escarcha_to_glacial_b": (119, 21, 9, 16, 34) in mp40_doors,
        "escarcha_to_glacial_c": (245, 53, 9, 174, 51) in mp40_doors,
        "glacial_to_escarcha_a": (56, 55, 8, 22, 9) in mp41_doors,
        "glacial_to_escarcha_b": (16, 34, 8, 119, 21) in mp41_doors,
        "glacial_to_escarcha_c": (174, 51, 8, 245, 53) in mp41_doors,
    }
    mp40_shape = (struct.unpack_from("<H", mp40, 2)[0], mp40[0x12],
                  *object_shape(mp40))
    mp41_shape = (struct.unpack_from("<H", mp41, 2)[0], mp41[0x12],
                  *object_shape(mp41))
    links40 = persistent_links(mp40)
    links41 = persistent_links(mp41)
    links_ok = links40 == [
        (0, 0x1A, 0x80), (6, 0x1A, 0x40), (14, 0x1A, 0x20),
        (26, 0x1A, 0x10), (31, 0x1A, 0x08), (38, 0x1A, 0x04),
        (42, 0x1A, 0x02), (45, 0x1A, 0x01),
    ] and links41 == [
        (6, 0x1B, 0x20), (7, 0x1B, 0x10), (9, 0x1B, 0x08),
        (16, 0x1B, 0x04), (18, 0x1B, 0x02), (23, 0x1B, 0x01),
        (24, 0x1C, 0x80), (26, 0x1C, 0x40),
    ]

    # 200FIGHT:gate_area4_no_accessory4 checks C012h==4 and selected
    # accessory 009Eh==4.  Ruzeria returns nonzero; bare ice returns zero.
    ice_gate = bytes.fromhex(
        "803e12c0047401c3803e9e00047505b0ff0ac0c332c0c3")
    ice_gate_ok = fight[0x6D9A - LOAD_BASE:0x6DB1 - LOAD_BASE] == ice_gate
    names_ok = b"Cavern of Glacial" in mp40 and \
        b"Cavern of Escarcha" in mp41

    ok = refs_ok and hashes_ok and all(topology.values()) and links_ok and \
        ice_gate_ok and names_ok and mp40_shape == (320, 4, 38, 31, 0x1E) and \
        mp41_shape == (192, 4, 14, 22, 0x1E)
    print("fight_escarcha_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}"
                           for name, value in refs.items()))
    print("fight_escarcha_routes: " +
          ("PASS" if all(topology.values()) else "FAIL") + f" {topology}")
    print("fight_escarcha_maps: " + ("PASS" if hashes_ok else "FAIL") +
          f" mp40=Glacial/{mp40_shape} mp41=Escarcha/{mp41_shape} names={names_ok}")
    print("fight_escarcha_persistence: " +
          ("PASS" if links_ok else "FAIL") + f" {links40} {links41}")
    print("fight_escarcha_ruzeria_gate: " +
          ("PASS" if ice_gate_ok else "FAIL") +
          f" bytes={ice_gate.hex()}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Escarcha resources, routes, persistence, and ice")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
