#!/usr/bin/env python3
"""Release-byte oracle for Reaccion and the complete Area-8 cavern chain."""

from __future__ import annotations

import hashlib
import struct
import sys
from collections import Counter
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402

LOAD_BASE = 0x6000
RESOURCE_REFS = {
    "area7_palette": (0x9C85, bytes((2, 81))),
    "area7_ai": (0x9D40, bytes((2, 8))),
    "area7_sprites": (0x9E11, bytes((2, 63))),
    "area7_music": (0x9EC1, bytes((2, 92))),
    "area8_palette": (0x9C90, bytes((2, 82))),
    "area8_ai": (0x9D56, bytes((2, 9))),
    "area8_sprites": (0x9E27, bytes((2, 64))),
    "area8_music": (0x9ECC, bytes((2, 93))),
    "alguien_code": (0x9D61, bytes((2, 18))),
    "alguien_sprites": (0x9E32, bytes((2, 72))),
    "boss_music": (0x9ED7, bytes((2, 94))),
    "boss_victory_overlay": (0x9C1E, bytes((2, 1))),
    "boss_encounter_art": (0x9BF1, bytes((2, 56))),
}
HASHES = {
    "308EAI8.bin": "dd014b53e0108527bcf55b5514f23601063086dc73aabe81b80fc3134965ee7a",
    "339MP71.mdt": "c1ab0694efd43ef1d5c4f40be33059a81d34ba02604d0a2bb68da749446f9b61",
    "341MP73.mdt": "a9ce3cf74e2a491ed00ee4040af0730d7e9deb4b8881b67716807228d2548686",
    "343MP80.mdt": "688f9a3b6d194cb0968d0cadf89eb77fb5bb477537fc5198b0445c3369ad2b76",
    "344MP81.mdt": "f0d6da6d3b527b03c10b364bcb0c5cbbcdae1b58b0ad7480c195466ebde923f8",
    "345MP82.mdt": "915a9ee1cccf93e2972b463aeb1e8759d12d2551124eb300daffc56f50499edd",
    "346MP83.mdt": "faafc62dfa83169a304c3a22a61d5a896f0ceddc666cdb11db75c971499612e9",
    "347MP84.mdt": "adaedb8c3a834976d986917faa222359b2c1ecb2c589026db8e54b06b1d3d97c",
    "348MP8D.mdt": "2a6ffe29b8b4cc955cb30e45ced4a23ce87a30776e1251d59696d03cc23d0589",
    "349MP90.mdt": "b33d5880f8e37686a31acb8c0dd891525992d3a4f35a2b7acad3361571122d8e",
    "350MPA0.mdt": "cabc22c986da57f7181699c80a4886a9265679ebe4d19f6e045b9e356a8d7a56",
    "300ROKAD.bin": "07236ac426e926d2bf73eccf750101614fb1f04fdc80745dc1a2982cc05ca500",
    "317AKMA.bin": "cea5025222dc6bb039607a81347ee1cecff17042dc7558dc8cc75c1755973c87",
    "353DMAN.grp": "687faa9cc9ee9dc7217caf9709c343f28453e4bcbe602418b581b5f8698e8a9e",
    "355ENCNT.grp": "fd9fd239d60cca4418d042a5785f2f8924685f4edd03ae4768209e4ae0be1e5b",
    "371AKMA.grp": "6fa2640e7f506bf4e834dad8c32e41b1addb0efacacbae3e67d5b2cd5592d014",
    "394MFAN.msd": "87b5ec7f3ee8ea5f4086a3198076fc06e1de28d05811159eb8e9f5a829a80dff",
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


def map_contract(data: bytes) -> tuple:
    objects = records(data, 0x10, 16)
    monsters = [row for row in objects if row[14]]
    items = [row for row in objects if not row[14]]
    families = sorted({row[4] for row in monsters if 1 <= row[4] <= 8})
    links = [(index, struct.unpack_from("<H", row, 11)[0], row[13])
             for index, row in enumerate(objects) if row[7] & 0x20]
    doors = records(data, 0x0A, 12)
    targets = Counter(row[4] for row in doors)
    return (struct.unpack_from("<H", data, 2)[0], data[0x12], len(doors),
            len(monsters), len(items), tuple(families), tuple(links), targets)


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

    cases = {
        "Reaccion": ("339MP71.mdt", (196, 7, 7, 25, 10, (1, 2, 3, 4),
            ((9, 0x35, 0x10), (32, 0x35, 0x08)), Counter({18: 6, 20: 1}))),
        "Absor": ("343MP80.mdt", (256, 8, 11, 45, 15, (1, 2, 3, 4),
            ((7, 0x42, 0x80), (13, 0x42, 0x40), (20, 0x42, 0x20),
             (24, 0x42, 0x10), (32, 0x42, 0x08), (36, 0x42, 0x04),
             (41, 0x42, 0x02), (48, 0x42, 0x01), (49, 0x43, 0x80)),
            Counter({24: 4, 25: 3, 22: 1, 16: 1, 8: 1, 26: 1}))),
        "Milagro": ("344MP81.mdt", (256, 8, 13, 58, 11, (1, 2, 3, 4),
            ((3, 0x43, 0x20), (4, 0x43, 0x10), (21, 0x43, 0x08),
             (28, 0x43, 0x04), (35, 0x43, 0x01), (42, 0x44, 0x80),
             (64, 0x43, 0x02), (65, 0x44, 0x40)),
            Counter({23: 4, 25: 4, 26: 2, 9: 1, 28: 1, 24: 1}))),
        "Desleal": ("345MP82.mdt", (192, 8, 7, 33, 6, (1, 2, 3, 4),
            ((3, 0x44, 0x08), (19, 0x44, 0x04), (24, 0x44, 0x02),
             (32, 0x44, 0x01)), Counter({24: 4, 23: 3}))),
        "Falter": ("346MP83.mdt", (128, 8, 3, 7, 0, (3,), (),
            Counter({24: 2, 23: 1}))),
        "Final": ("347MP84.mdt", (64, 8, 2, 0, 1, (),
            ((0, 0x45, 0x10),), Counter({28: 1, 29: 1}))),
    }
    actual = {name: map_contract(images[filename])
              for name, (filename, _expected) in cases.items()}
    maps_ok = all(actual[name] == expected
                  for name, (_filename, expected) in cases.items())
    connector = map_contract(images["341MP73.mdt"])
    connector_ok = connector == (73, 1, 0, 0, 0, (), (), Counter())
    alguien_room = images["348MP8D.mdt"]
    alguien_descriptor = struct.unpack_from("<H", alguien_room)[0] - 0xC000
    alguien_shape = (
        struct.unpack_from("<H", alguien_room, 2)[0], alguien_room[0x12],
        len(records(alguien_room, 0x0A, 12)),
        len(records(alguien_room, 0x10, 16)),
        alguien_room[alguien_descriptor:alguien_descriptor + 22],
    )
    alguien = images["317AKMA.bin"]
    roka = images["300ROKAD.bin"]
    alguien_contract = {
        "milagro_boss_door": bytes.fromhex(
            "de0013011c15000e00440020") in images["344MP81.mdt"],
        "name": b"Alguien" in alguien,
        "death_arm": alguien[0x9A0:0x9B0] == bytes.fromhex(
            "c60629aa00c60625aa00c6062effffc3"),
        "death_timer": alguien[0x9B0:0x9B7] == bytes.fromhex(
            "a029aa3c287349"),
        "death_fx": alguien[0x9EB:0x9F0] == bytes.fromhex(
            "c60675ff37"),
        "completion_write": alguien[0xA00:0xA06] == bytes.fromhex(
            "c60630ffffc3"),
        "victory_increment": bytes.fromhex("fe06a000") in roka,
        "raised_sword_pose": bytes.fromhex("c606e70005") in roka,
        "crystal_launch": bytes.fromhex("c6069ca594c6069da550") in roka,
    }
    names_ok = all(f"Cavern of {name}".encode() in images[filename]
                   for name, (filename, _expected) in cases.items())
    ok = refs_ok and hashes_ok and maps_ok and names_ok and connector_ok and \
        alguien_shape == (70, 8, 0, 0, bytes.fromhex(
            "9900070fff0f0e0e10c07dc20ac03bc27fc200ffffff")) and \
        all(alguien_contract.values())
    print("fight_remaining_refs: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}" for name, value in refs.items()))
    for name in cases:
        print(f"fight_remaining_map:{name}: " +
              ("PASS" if actual[name] == cases[name][1] else "FAIL") +
              f" contract={actual[name]}")
    print("fight_remaining_connector: " +
          ("PASS" if connector_ok else "FAIL") + f" contract={connector}")
    print("fight_alguien_contract: " +
          ("PASS" if all(alguien_contract.values()) else "FAIL") +
          f" shape={alguien_shape} contract={alguien_contract}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Reaccion and complete Area-8 cavern chain")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
