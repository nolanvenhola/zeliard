#!/usr/bin/env python3
"""Release-byte oracle for Madera and the Peligro/Madera boundary."""

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
    "madera_palette": (0x9C59, bytes((2, 77))),
    "madera_ai": (0x9CE8, bytes((2, 4))),
    "madera_sprites": (0x9DB9, bytes((2, 59))),
    "madera_music": (0x9E95, bytes((2, 88))),
}
MAP_HASHES = {
    "322MP20.mdt": "60de08ec157a335362b85017d38e8b3de31643ec32cff2ff80076731a615f5c2",
    "325MP30.mdt": "e8ac822b5c748a98eedcc691f24aa305c51595570eaeab127d8815fa56746feb",
    "326MP31.mdt": "4b54099bff4ab44ea5cae76fc554ad6c2c684a025a3d9922e330431fbe2b2ae3",
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


def doors(data: bytes) -> list[tuple[int, int, int, int, int]]:
    return [
        (struct.unpack_from("<H", row)[0], row[2], row[4],
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

    maps = {}
    hashes_ok = True
    for name, expected in MAP_HASHES.items():
        path = release_path(f"zelres3/{name}")
        hashes_ok &= hashlib.sha256(path.read_bytes()).hexdigest() == expected
        maps[name] = payload(path)

    peligro_doors = doors(maps["322MP20.mdt"])
    madera = maps["325MP30.mdt"]
    riza = maps["326MP31.mdt"]
    madera_doors = doors(madera)
    riza_doors = doors(riza)
    topology = {
        "peligro_to_madera": (205, 47, 5, 21, 6) in peligro_doors,
        "madera_to_peligro": (21, 6, 2, 205, 47) in madera_doors,
        "madera_to_riza": (19, 49, 6, 19, 49) in madera_doors,
        "riza_to_madera": (19, 49, 5, 19, 49) in riza_doors,
        "madera_to_bosque": (185, 18, 3, 142, 255) in madera_doors,
    }
    shape = (struct.unpack_from("<H", madera, 2)[0], madera[0x12],
             len(madera_doors), *object_shape(madera))
    links = linked_masks(madera)
    links_ok = links == [
        (19, 0x12, 0x80), (27, 0x12, 0x40), (29, 0x12, 0x20),
        (39, 0x12, 0x10), (40, 0x12, 0x08), (41, 0x12, 0x04),
    ]
    ok = refs_ok and hashes_ok and all(topology.values()) and links_ok and \
        shape == (204, 3, 12, 30, 15, 0x0E)

    print("fight_madera_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}"
                           for name, value in refs.items()))
    print("fight_madera_topology: " +
          ("PASS" if all(topology.values()) else "FAIL") + f" {topology}")
    print("fight_madera_map: " + ("PASS" if hashes_ok else "FAIL") +
          f" shape={shape} links={links}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Madera resources and authored boundaries")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
