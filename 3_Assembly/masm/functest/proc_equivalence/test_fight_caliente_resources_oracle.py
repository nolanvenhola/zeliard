#!/usr/bin/env python3
"""Release-byte oracle for Caliente heat, persistence, and Dragon handoff."""

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
    "dragon_code": (0x9D4B, bytes((2, 17))),
    "paguro_code": (0x9D82, bytes((2, 16))),
    "inferno_sprites": (0x9E11, bytes((2, 63))),
    "dragon_sprites": (0x9E1C, bytes((2, 71))),
    "inferno_music": (0x9EC1, bytes((2, 92))),
}
HASHES = {
    "307EAI7.bin": "40eb8d98ce4eaaed8f4c3d231bb7e369f5b5b2870b5b579e3b4a5cc61d52c21e",
    "316DRGN.bin": "c03672dff738c3220d86c164a9520361fabc9ae3f5434bab8c07b5a200b49f86",
    "315ZEL2.bin": "71ae2d4bc7bcf3c24bfbb055099016cd4330deb5d512bbfa179ff7a45c033579",
    "338MP70.mdt": "1d2247ca9584eb627c7c0582e60b2e44b1bfafeccdc88a26dff38dc81a497094",
    "339MP71.mdt": "c1ab0694efd43ef1d5c4f40be33059a81d34ba02604d0a2bb68da749446f9b61",
    "340MP72.mdt": "b1a78a9d6ea7dc4f4b3867b05d14622d2cef953842d03a8726d53c1e40386522",
    "341MP73.mdt": "a9ce3cf74e2a491ed00ee4040af0730d7e9deb4b8881b67716807228d2548686",
    "342MP7D.mdt": "20beabad8ed3b592395a8c690ba6ef76d7e9282b7e2e9e2fc8a5899b86c07e68",
    "362ENP7.grp": "21cd44fff5a86165b6d2bfd66fae001fd79421471561aca836960314e6acdef1",
    "370DRGN.grp": "08cad787630482e422152df806de61f22c227f0362cbf63bc904b2ffa98b0f49",
    "380MPP7.grp": "2f8a8f2207be3deb686e520e11530d60a71fff1f0c628cb92397173217be75c9",
    "391MUS7.msd": "e0404d16eaad567e7ed932690f4f1c16f7246875413b463cb4be086c95213c4a",
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
    chamber = images["342MP7D.mdt"]
    paguro_room = images["341MP73.mdt"]
    objects = records(caliente, 0x10, 16)
    monsters = sum(bool(row[14]) for row in objects)
    items = len(objects) - monsters
    families = 0
    for row in objects:
        if row[14] and 1 <= row[4] <= 8:
            families |= 1 << row[4]
    links = [(index, struct.unpack_from("<H", row, 11)[0], row[13])
             for index, row in enumerate(objects) if row[7] & 0x20]
    expected_links = [(7, 0x34, 0x08), (12, 0x34, 0x04),
                      (14, 0x34, 0x02), (22, 0x34, 0x01),
                      (26, 0x35, 0x80), (28, 0x35, 0x40)]
    caliente_doors = doors(caliente)
    contract = {
        "name": b"Cavern of Caliente" in caliente,
        "llama_exit": (1, 21, 0xC0, 7, 269, 255) in caliente_doors,
        "tesoro_reverse": (127, 7, 0x80, 14, 11, 41) in caliente_doors,
        "reaccion_routes": sum(row[3] == 20 for row in caliente_doors) == 4,
        "correr_boundary": (199, 33, 0x01, 22, 21, 14) in caliente_doors,
        "dragon_chamber": b"Cavern of Caliente" in chamber,
    }
    # 200FIGHT:update_combat_frame_state: Area 7 bypasses periodic 15-HP
    # heat damage only when selected_accessory == 5 (Asbestos Cape).
    heat_gate = bytes.fromhex(
        "803e12c0077528803e9e00057421fe06259ff606259f3f7516")
    heat_ok = fight[0x704F - LOAD_BASE:0x704F - LOAD_BASE + len(heat_gate)] == heat_gate
    shape = (struct.unpack_from("<H", caliente, 2)[0], caliente[0x12],
             len(caliente_doors), monsters, items, families)
    chamber_shape = (struct.unpack_from("<H", chamber, 2)[0], chamber[0x12],
                     len(doors(chamber)), len(records(chamber, 0x10, 16)))
    paguro_descriptor = struct.unpack_from("<H", paguro_room)[0] - 0xC000
    paguro_shape = (
        struct.unpack_from("<H", paguro_room, 2)[0],
        len(doors(paguro_room)), len(records(paguro_room, 0x10, 16)),
        paguro_room[paguro_descriptor:paguro_descriptor + 5],
        paguro_room[paguro_descriptor + 16:paguro_descriptor + 20],
    )
    paguro = images["315ZEL2.bin"]
    paguro_contract = {
        "hut_name": b"In the Hut" in paguro_room,
        "damage_floor": paguro[0x55D:0x569] ==
            bytes.fromhex("a1e2a52bc3730233c0a3e2a5"),
        "death_shutdown": paguro[0x577:0x58B] ==
            bytes.fromhex("c6062effffc60601a600c606f7a5002eff263c60"),
        "death_timer": paguro[0x58B:0x59B] ==
            bytes.fromhex("803e01a6287347c6062ffffffe0601a6"),
        "completion_write": paguro[0x5D9:0x5DF] ==
            bytes.fromhex("c60630ffffc3"),
        "name": b"aguro" in paguro,
    }
    ok = refs_ok and hashes_ok and heat_ok and all(contract.values()) and \
        links == expected_links and shape == (208, 7, 14, 19, 10, 0x1E) and \
        chamber_shape == (70, 7, 0, 0) and \
        paguro_shape == (73, 0, 0, bytes.fromhex("99000a12ff"),
                          bytes.fromhex("3000ffff")) and \
        all(paguro_contract.values())

    print("fight_caliente_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}" for name, value in refs.items()))
    print("fight_caliente_heat: " + ("PASS" if heat_ok else "FAIL") +
          f" gate={heat_gate.hex()}")
    print("fight_caliente_map: " + ("PASS" if hashes_ok else "FAIL") +
          f" shape={shape} chamber={chamber_shape} links={links} contract={contract}")
    print("fight_paguro_handoff: " +
          ("PASS" if all(paguro_contract.values()) else "FAIL") +
          f" shape={paguro_shape} contract={paguro_contract}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Caliente, Paguro hut, persistence, and Dragon handoff")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
