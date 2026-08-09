#!/usr/bin/env python3
"""Release-byte oracle for Correr movement, topology, and persistence."""

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
    "inferno_palette": (0x9C85, bytes((2, 81))),
    "inferno_ai": (0x9D40, bytes((2, 8))),
    "inferno_sprites": (0x9E11, bytes((2, 63))),
    "inferno_music": (0x9EC1, bytes((2, 92))),
}
HASHES = {
    "307EAI7.bin": "40eb8d98ce4eaaed8f4c3d231bb7e369f5b5b2870b5b579e3b4a5cc61d52c21e",
    "338MP70.mdt": "1d2247ca9584eb627c7c0582e60b2e44b1bfafeccdc88a26dff38dc81a497094",
    "339MP71.mdt": "c1ab0694efd43ef1d5c4f40be33059a81d34ba02604d0a2bb68da749446f9b61",
    "340MP72.mdt": "b1a78a9d6ea7dc4f4b3867b05d14622d2cef953842d03a8726d53c1e40386522",
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
    return [(struct.unpack_from("<H", row)[0], row[2], row[3], row[4],
             struct.unpack_from("<H", row, 5)[0], row[7])
            for row in records(data, 0x0A, 12)]


def main() -> int:
    fight_path, _ = BIN_PATHS["fight"]
    if not fight_path.exists():
        fight_path = release_path("zelres2/200FIGHT.bin")
    fight = payload(fight_path)
    refs = {name: fight[address - LOAD_BASE:address - LOAD_BASE + 2]
            for name, (address, _expected) in RESOURCE_REFS.items()}
    refs_ok = all(refs[name] == expected
                  for name, (_address, expected) in RESOURCE_REFS.items())

    images = {}
    hashes_ok = True
    for name, expected in HASHES.items():
        path = release_path(f"zelres3/{name}")
        hashes_ok &= hashlib.sha256(path.read_bytes()).hexdigest() == expected
        images[name] = payload(path)

    caliente = images["338MP70.mdt"]
    reaccion = images["339MP71.mdt"]
    correr = images["340MP72.mdt"]
    correr_doors = doors(correr)
    expected_doors = [
        (25, 40, 0x83, 19, 20, 9),
        (50, 8, 0x82, 18, 83, 1),
        (76, 8, 0x81, 18, 92, 41),
        (101, 56, 0x81, 18, 176, 43),
        (127, 8, 0x83, 18, 205, 45),
    ]
    expected_caliente_reverse = [
        (83, 1, 0xC2, 20, 50, 8),
        (92, 41, 0xC1, 20, 76, 8),
        (176, 43, 0xC1, 20, 101, 56),
        (205, 45, 0xC3, 20, 127, 8),
    ]
    objects = records(correr, 0x10, 16)
    monsters = [row for row in objects if row[14]]
    items = [row for row in objects if not row[14]]
    links = [(index, struct.unpack_from("<H", row, 11)[0], row[13])
             for index, row in enumerate(objects) if row[7] & 0x20]

    eai7 = images["307EAI7.bin"]
    dispatch = eai7[0x2F1:0x30A]
    family4_dispatch = struct.unpack_from("<H", eai7, 0x307)[0]
    double_step_neg = bytes.fromhex("2eff1608602eff160860") in eai7
    double_step_pos = bytes.fromhex("2eff1610602eff161060") in eai7
    movement_ok = (dispatch.startswith(bytes.fromhex("8a5c0480e30f32ff03dbffa7ffa2")) and
                   family4_dispatch == 0xA749 and double_step_neg and
                   double_step_pos)
    contract = {
        "name": b"Cavern of Correr" in correr,
        "exact_doors": correr_doors == expected_doors,
        "reaccion_reverse": (20, 9, 0xC3, 20, 25, 40) in doors(reaccion),
        "caliente_reverse": all(row in doors(caliente)
                                 for row in expected_caliente_reverse),
        "family4_only": len(monsters) == 14 and
                        all(row[4] == 4 for row in monsters),
    }
    shape = (struct.unpack_from("<H", correr, 2)[0], correr[0x12],
             len(correr_doors), len(monsters), len(items))
    ok = refs_ok and hashes_ok and movement_ok and all(contract.values()) and \
        links == [(4, 0x35, 0x04), (8, 0x35, 0x02),
                  (16, 0x35, 0x01)] and shape == (128, 7, 5, 14, 3)

    print("fight_correr_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}" for name, value in refs.items()))
    print("fight_correr_movement: " + ("PASS" if movement_ok else "FAIL") +
          f" family4={family4_dispatch:04x} double={double_step_neg}/{double_step_pos}")
    print("fight_correr_map: " + ("PASS" if hashes_ok else "FAIL") +
          f" shape={shape} doors={correr_doors} links={links} contract={contract}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Correr movement, routes, and persistence")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
