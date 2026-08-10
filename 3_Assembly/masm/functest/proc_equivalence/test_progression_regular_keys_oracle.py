#!/usr/bin/env python3
"""Release-MASM oracle for normal cavern-key acquisition and doors."""

from __future__ import annotations

import struct
from pathlib import Path

HERE = Path(__file__).resolve().parent
MASM_ROOT = HERE.parents[1]


def payload(archive: str, name: str) -> bytes:
    image = (MASM_ROOT / "bin" / archive / name).read_bytes()
    declared = struct.unpack_from("<I", image)[0]
    assert declared == len(image) - 4
    return image[4:]


def records(data: bytes, pointer: int, size: int) -> list[bytes]:
    offset = struct.unpack_from("<H", data, pointer)[0] - 0xC000
    result = []
    while data[offset:offset + 2] != b"\xff\xff":
        result.append(data[offset:offset + size])
        offset += size
    return result


def main() -> int:
    fight = payload("zelres2", "200FIGHT.bin")
    select = payload("zelres2", "201SELCT.bin")
    player = (MASM_ROOT / "bin" / "stdply.bin").read_bytes()
    maps = {
        path.name: payload("zelres3", path.name)
        for path in (MASM_ROOT / "bin" / "zelres3").glob("*MP*.mdt")
    }

    pickup_records = {
        (name, index, row)
        for name, data in maps.items()
        for index, row in enumerate(records(data, 0x10, 16))
        if row[14] == 0 and (row[6] & 0x0F) == 4
    }
    expected_pickups = {
        ("331MP50.mdt", 30, bytes.fromhex("73002bff730004200000002200200000")),
        ("331MP50.mdt", 45, bytes.fromhex("af0034ff730004200000002200080000")),
        ("335MP61.mdt", 1, bytes.fromhex("060016ff730004200000002b00010000")),
        ("339MP71.mdt", 32, bytes.fromhex("c10039ff730004200000003500080000")),
        ("343MP80.mdt", 24, bytes.fromhex("750034ff730004200000004200100000")),
        ("343MP80.mdt", 49, bytes.fromhex("d1002aff730004200000004300800000")),
    }

    locked_regular = {
        (name, index, struct.unpack_from("<H", row)[0], row[2],
         struct.unpack_from("<H", row, 9)[0], row[11])
        for name, data in maps.items()
        for index, row in enumerate(records(data, 0x0A, 12))
        if not (row[3] & 0x80) and not (row[8] & 1) and
        struct.unpack_from("<H", row, 9)[0] != 0xFFFF
    }
    expected_regular = {
        ("320MP10.mdt", 0, 26, 15, 0x03, 0x80),
        ("320MP10.mdt", 3, 128, 32, 0x03, 0x40),
        ("322MP20.mdt", 1, 95, 35, 0x0B, 0x80),
        ("322MP20.mdt", 3, 171, 54, 0x0B, 0x40),
        ("322MP20.mdt", 5, 205, 47, 0x0B, 0x20),
        ("326MP31.mdt", 12, 188, 20, 0x13, 0x08),
        ("326MP31.mdt", 13, 192, 4, 0x13, 0x01),
        ("328MP40.mdt", 1, 86, 9, 0x1B, 0x80),
        ("328MP40.mdt", 4, 224, 18, 0x1B, 0x40),
        ("329MP41.mdt", 1, 16, 21, 0x1C, 0x20),
        ("331MP50.mdt", 6, 131, 53, 0x23, 0x80),
        ("332MP51.mdt", 5, 157, 16, 0x24, 0x10),
        ("334MP60.mdt", 0, 11, 41, 0x2B, 0x20),
        ("334MP60.mdt", 12, 309, 41, 0x2B, 0x08),
        ("334MP60.mdt", 13, 315, 48, 0x2B, 0x04),
        ("338MP70.mdt", 9, 165, 43, 0x34, 0x20),
        ("338MP70.mdt", 11, 199, 33, 0x34, 0x10),
        ("339MP71.mdt", 2, 103, 33, 0x35, 0x20),
        ("343MP80.mdt", 1, 57, 15, 0x43, 0x40),
        ("344MP81.mdt", 8, 222, 19, 0x44, 0x20),
        ("344MP81.mdt", 11, 236, 4, 0x44, 0x10),
        ("347MP84.mdt", 1, 30, 5, 0x45, 0x20),
    }

    acquisition = bytes.fromhex(
        "ba729ae8e5007301c3fe069800e95401")
    unlock = bytes.fromhex(
        "8a5c0880e301751ff6069800fff97501c3fe0e9800"
        "c60675ff15804c03808b5c098a440b0807c3")
    inventory = bytes.fromhex(
        "f6069800ff7428bb752e32c02eff163a20bbc800b17eb05e"
        "b4012eff162220a0980032e4b90100b301ba7e34e8c401")

    checks = {
        "save_field_0098": len(player) == 233 and player[0x98] == 0,
        "six_persistent_pickups": pickup_records == expected_pickups,
        "pickup_message_and_increment":
            fight.count(b"You get a Key.\xff") == 1 and
            fight.count(acquisition) == 1,
        "twenty_two_regular_locked_doors":
            locked_regular == expected_regular,
        "zero_key_blocks_without_mutation": fight.count(unlock) == 1 and
            bytes.fromhex("f6069800fff97501c3") in unlock,
        "one_key_consumed_and_door_persisted":
            bytes.fromhex("fe0e9800c60675ff15") in unlock and
            bytes.fromhex("804c03808b5c098a440b0807") in unlock,
        "regular_and_lion_key_separation":
            bytes.fromhex("8a5c0880e301751f") in unlock,
        "inventory_reads_0098": select.count(inventory) == 1,
    }
    ok = all(checks.values())
    print("regular_keys_oracle: " + ("PASS" if ok else "FAIL") +
          f" checks={checks}")
    print(f"regular_keys_contract: pickups={len(pickup_records)} "
          f"doors={len(locked_regular)} count=0098 cue=15")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM normal-key pickup, inventory, consumption, and "
          "persistent regular-door pool")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
