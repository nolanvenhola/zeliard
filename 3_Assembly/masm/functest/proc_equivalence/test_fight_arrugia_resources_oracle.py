#!/usr/bin/env python3
"""Release-byte oracle for Arrugia topology, treasure, and persistence."""

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
    "336MP62.mdt": "3248ca6fc3d05ef72e42ca3db29e2d0622c20b653f5d08f9e86b5eeec7060402",
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


def linked_records(data: bytes) -> list[tuple[int, int, int, int, int, int, int]]:
    return [
        (index, struct.unpack_from("<H", row)[0], row[2], row[6], row[9],
         struct.unpack_from("<H", row, 11)[0], row[13])
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
    arrugia = images["336MP62.mdt"]
    arrugia_doors = doors(arrugia)
    tesoro_doors = doors(tesoro)
    expected_doors = [
        (40, 37, 0x80, 23, 57, 57),
        (62, 13, 0x83, 14, 31, 5),
    ]
    links = linked_records(arrugia)
    expected_links = [
        (22, 18, 26, 7, 0, 0x2C, 0x08),
        (23, 27, 26, 0, 0x1E, 0x2C, 0x04),
        (24, 44, 52, 5, 0, 0x2C, 0x02),
        (25, 46, 52, 5, 0, 0x2C, 0x01),
        (26, 48, 52, 5, 0, 0x2D, 0x80),
        (27, 55, 39, 0, 0x19, 0x2D, 0x40),
    ]
    shape = (struct.unpack_from("<H", arrugia, 2)[0], arrugia[0x12],
             len(arrugia_doors), *object_shape(arrugia))

    # entity_fn_e_6 indexes this three-byte table by area_num-4.  Area 6's
    # exact tuple is wearable ID 3 and the Silkarn message at 9B7Fh.
    area6_wearable = fight[0x90D0 - LOAD_BASE:0x90D3 - LOAD_BASE]
    contract = {
        "name": b"Cavern of Arrugia" in arrugia,
        "exact_doors": arrugia_doors == expected_doors,
        "tesoro_entry": (31, 5, 0x43, 16, 62, 13) in tesoro_doors,
        "free_return": (62, 13, 0x83, 14, 31, 5) in arrugia_doors,
        "forward_boundary": (40, 37, 0x80, 23, 57, 57) in arrugia_doors,
        "silkarn_reward": area6_wearable == bytes.fromhex("037f9b") and
                          b"You get the Silkarn shoes." in fight,
        "enchantment_reward": b"Get the Enchantment sword." in fight and
                              bytes.fromhex("c606920006b006bbab18") in fight,
        "lion_key_message": b"Get the lion\\s head Key." in fight,
    }
    ok = refs_ok and hashes_ok and all(contract.values()) and \
        links == expected_links and shape == (73, 6, 2, 0, 28, 0)

    print("fight_arrugia_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}"
                           for name, value in refs.items()))
    print("fight_arrugia_topology: " +
          ("PASS" if all(contract.values()) else "FAIL") + f" {contract}")
    print("fight_arrugia_map: " + ("PASS" if hashes_ok else "FAIL") +
          f" shape={shape} doors={arrugia_doors} links={links} "
          f"wearable={area6_wearable.hex()}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Arrugia routes, treasure, and persistence")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
