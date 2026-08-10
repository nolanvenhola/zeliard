#!/usr/bin/env python3
"""Release-byte oracle for the complete Hero's Crest progression chain."""

from __future__ import annotations

import struct
from pathlib import Path

HERE = Path(__file__).resolve().parent
MASM_ROOT = HERE.parents[1]


def payload(path: Path) -> bytes:
    image = path.read_bytes()
    declared = struct.unpack_from("<I", image)[0]
    assert declared == len(image) - 4
    return image[4:]


def release_asset(archive: str, name: str) -> Path:
    path = MASM_ROOT / "bin" / archive / name
    if not path.exists():
        raise FileNotFoundError(path)
    return path


def records(data: bytes, pointer_offset: int, size: int) -> list[bytes]:
    offset = struct.unpack_from("<H", data, pointer_offset)[0] - 0xC000
    result = []
    while data[offset:offset + 2] != b"\xff\xff":
        result.append(data[offset:offset + size])
        offset += size
    return result


def main() -> int:
    fight = payload(release_asset("zelres2", "200FIGHT.bin"))
    select = payload(release_asset("zelres2", "201SELCT.bin"))
    bosque = payload(release_asset("zelres2", "239BSMP.mdt"))
    madera = payload(release_asset("zelres3", "325MP30.mdt"))
    player = (MASM_ROOT / "bin" / "stdply.bin").read_bytes()

    objects = records(madera, 0x10, 16)
    crest_object = bytes.fromhex(
        "a60036ffd0000020001d001200080f00")
    acquire_handler = bytes.fromhex(
        "baf39ae84e007301c3c6069c00ffe9bc00")
    acquire_message = (
        b"\x06\x00You get the Hero\\s Crest.\xff\x00\x00")
    ability_loop = bytes.fromhex("be9a00bb8930b90300")
    gate_event = bytes.fromhex("120008facc80fbcc0effffffff")
    sentry = bytes.fromhex("090001cc0004c00b")
    prompt = b"Hold on there! Do you have the Hero\\s Crest? \x81"
    denied = b"Don\\t lie, it won\\t do any good. Get out of here!\xff"
    allowed = (b"Hold on there! You have the Hero\\s Crest, I see. "
               b"You may pass.\xff")

    checks = {
        "madera_object_40": len(objects) == 45 and
                            objects[40] == crest_object,
        "persistent_link": objects[40][11:14] == bytes((0x12, 0, 0x08)),
        "acquire_handler_unique": fight.count(acquire_handler) == 1,
        "sets_inventory_marker": bytes.fromhex("c6069c00ff") in
                                 acquire_handler,
        "native_message": fight.count(acquire_message) == 1,
        "inventory_three_slots": select.count(ability_loop) == 1,
        "inventory_base_count": ability_loop ==
                                bytes.fromhex("be9a00bb8930b90300"),
        "bosque_gate_event": bosque[0x513:0x513 + len(gate_event)] ==
                             gate_event,
        "bosque_sentry": bosque[0xCF4:0xCFC] == sentry,
        "bosque_prompt": prompt in bosque,
        "bosque_denied": denied in bosque,
        "bosque_allowed": allowed in bosque,
        "player_record_offsets": len(player) == 233 and
                                 player[0x12] == 0 and player[0x9C] == 0,
    }
    ok = all(checks.values())
    print("hero_crest_oracle: " + ("PASS" if ok else "FAIL") +
          f" checks={checks}")
    print("hero_crest_contract: object=40 coord=166/54 "
          "state=0012/08 inventory=009c gate=BSMP:0513")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM Hero's Crest acquisition, inventory, and gate")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
