#!/usr/bin/env python3
"""Release-byte oracle for Peligro assets and the MP21 connector.

This pins the 200FIGHT resource-reference slots used by level 2, plus the
authored MP10 -> MP21 -> MP20 door chain.  It deliberately reads verified
release artifacts; names and routing must not come from host assumptions.
"""

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
    "peligro_palette": (0x9C4E, bytes((2, 76))),
    "peligro_ai": (0x9CD2, bytes((2, 3))),
    "peligro_sprites": (0x9DA3, bytes((2, 58))),
    "peligro_music": (0x9E8A, bytes((2, 87))),
    "pulpo_code": (0x9CDD, bytes((2, 11))),
    "pulpo_sprites": (0x9DAE, bytes((2, 66))),
    "boss_victory_overlay": (0x9C1E, bytes((2, 1))),
    "boss_encounter_art": (0x9BF1, bytes((2, 56))),
}
MAP_HASHES = {
    "320MP10.mdt": "5f27a710ed0470de24d2aa5c3c8b13b9269dee47585fa2e4385961451d1ed66a",
    "322MP20.mdt": "60de08ec157a335362b85017d38e8b3de31643ec32cff2ff80076731a615f5c2",
    "323MP21.mdt": "0151fac5e295f9ed3d59c59aabe804c5db8a6dc6e209199296c1347c176f0868",
    "324MP2D.mdt": "f541aa1655be55aa5b5c38fdff380e1ebb920d71871b06d5bacf5825b7e8650f",
}
BOSS_VICTORY_HASHES = {
    "300ROKAD.bin": "07236ac426e926d2bf73eccf750101614fb1f04fdc80745dc1a2982cc05ca500",
    "353DMAN.grp": "687faa9cc9ee9dc7217caf9709c343f28453e4bcbe602418b581b5f8698e8a9e",
    "394MFAN.msd": "87b5ec7f3ee8ea5f4086a3198076fc06e1de28d05811159eb8e9f5a829a80dff",
}
ENCOUNTER_HASH = "fd9fd239d60cca4418d042a5785f2f8924685f4edd03ae4768209e4ae0be1e5b"


def release_path(relative: str) -> Path:
    masm = MASM_ROOT / "bin" / relative
    tasm = MASM_ROOT.parent / "tasm" / "bin" / relative
    return masm if masm.exists() else tasm


def payload(path: Path) -> bytes:
    image = path.read_bytes()
    declared = struct.unpack_from("<I", image)[0]
    assert declared == len(image) - 4
    return image[4:]


def doors(data: bytes) -> list[tuple[int, int, int, int, int]]:
    offset = struct.unpack_from("<H", data, 0x0A)[0] - 0xC000
    result = []
    while data[offset:offset + 2] != b"\xff\xff":
        x0 = struct.unpack_from("<H", data, offset)[0]
        y0 = data[offset + 2]
        target = data[offset + 4]
        x1 = struct.unpack_from("<H", data, offset + 5)[0]
        y1 = struct.unpack_from("<H", data, offset + 7)[0]
        result.append((x0, y0, target, x1, y1))
        offset += 12
    return result


def object_families(data: bytes) -> tuple[int, int, int]:
    offset = struct.unpack_from("<H", data, 0x10)[0] - 0xC000
    monsters = items = families = 0
    while data[offset:offset + 2] != b"\xff\xff":
        record = data[offset:offset + 16]
        if record[14]:
            monsters += 1
            if 1 <= record[4] <= 4:
                families |= 1 << record[4]
        else:
            items += 1
        offset += 16
    return monsters, items, families


def linked_object_masks(data: bytes) -> list[tuple[int, int, int]]:
    """Return (record index, STDPLY destination, mask) for persistent objects."""
    offset = struct.unpack_from("<H", data, 0x10)[0] - 0xC000
    result = []
    index = 0
    while data[offset:offset + 2] != b"\xff\xff":
        record = data[offset:offset + 16]
        if record[7] & 0x20:
            result.append((index, struct.unpack_from("<H", record, 0x0B)[0],
                           record[0x0D]))
        index += 1
        offset += 16
    return result


def main() -> int:
    fight_path, _ = BIN_PATHS["fight"]
    fight = payload(fight_path)
    actual_refs = {
        name: fight[address - LOAD_BASE:address - LOAD_BASE + 2]
        for name, (address, _expected) in RESOURCE_REFS.items()
    }
    refs_ok = all(actual_refs[name] == expected
                  for name, (_address, expected) in RESOURCE_REFS.items())

    maps = {}
    hashes_ok = True
    for name, expected_hash in MAP_HASHES.items():
        path = release_path(f"zelres3/{name}")
        image = path.read_bytes()
        hashes_ok &= hashlib.sha256(image).hexdigest() == expected_hash
        maps[name] = payload(path)

    mp10_doors = doors(maps["320MP10.mdt"])
    connector_doors = doors(maps["323MP21.mdt"])
    peligro = maps["322MP20.mdt"]
    pulpo = maps["324MP2D.mdt"]
    peligro_doors = doors(peligro)
    persistent_links = {
        name: linked_object_masks(maps[name])
        for name in ("320MP10.mdt", "322MP20.mdt", "323MP21.mdt")
    }
    persistent_links_ok = all(persistent_links.values()) and all(
        destination < 0x80 and mask != 0
        for links in persistent_links.values()
        for _index, destination, mask in links)
    persistent_links_ok &= (21, 0x0002, 0x40) in \
        persistent_links["320MP10.mdt"]
    tako = payload(release_path("zelres3/310TAKO.bin"))
    topology = {
        "malicia_to_connector": (95, 50, 3, 15, 50) in mp10_doors,
        "connector_to_peligro_a": (15, 35, 2, 95, 35) in connector_doors,
        "connector_to_peligro_b": (66, 35, 2, 146, 35) in connector_doors,
        "connector_return_a": (15, 50, 0, 95, 50) in connector_doors,
        "connector_return_b": (79, 50, 0, 159, 50) in connector_doors,
        "peligro_return_a": (95, 35, 3, 15, 35) in peligro_doors,
        "peligro_return_b": (146, 35, 3, 66, 35) in peligro_doors,
        "peligro_to_pulpo_a": (171, 54, 4, 24, 18) in peligro_doors,
        "peligro_to_pulpo_b": (190, 47, 4, 41, 18) in peligro_doors,
        "peligro_green_door": (205, 47, 5, 21, 6) in peligro_doors,
    }
    peligro_shape = (
        struct.unpack_from("<H", peligro, 0x02)[0], peligro[0x12],
        len(doors(peligro)), *object_families(peligro))
    pulpo_shape = (struct.unpack_from("<H", pulpo, 0x02)[0], pulpo[0x12])
    completion_write = tako[0x577:0x57C] == bytes.fromhex("c60630ffff")
    boss_hashes_ok = all(
        hashlib.sha256(release_path(f"zelres3/{name}").read_bytes()).hexdigest()
        == expected for name, expected in BOSS_VICTORY_HASHES.items())
    roka = payload(release_path("zelres3/300ROKAD.bin"))
    victory_contract = {
        "increment_tear_counter": bytes.fromhex("fe06a000") in roka,
        "raised_sword_pose": bytes.fromhex("c606e70005") in roka,
        "crystal_launch_y": bytes.fromhex("c6069ca594") in roka,
        "crystal_launch_x": bytes.fromhex("c6069da550") in roka,
        "fanfare_interrupt": bytes.fromhex("cd60") in roka,
    }
    encounter_hash_ok = hashlib.sha256(
        release_path("zelres3/355ENCNT.grp").read_bytes()).hexdigest() == ENCOUNTER_HASH
    encounter_contract = {
        "copy_entity_direction_bit": bytes.fromhex("8a44032440a2c300") in fight,
        "branch_on_intro_direction": bytes.fromhex("f606c300ff") in fight,
        "left_to_right_26_steps": bytes.fromhex("bb6e0ab91a00") in fight,
        "right_to_left_26_steps": bytes.fromhex("bb6e40b91a00") in fight,
    }
    ok = refs_ok and hashes_ok and all(topology.values()) and \
        persistent_links_ok and \
        completion_write and boss_hashes_ok and all(victory_contract.values()) and \
        encounter_hash_ok and all(encounter_contract.values()) and \
        peligro_shape == (224, 2, 6, 45, 11, 0x1E) and \
        pulpo_shape == (52, 2)

    print("fight_peligro_resources: " + ("PASS" if refs_ok else "FAIL") +
          " " + " ".join(f"{name}={value.hex()}"
                           for name, value in actual_refs.items()))
    print("fight_peligro_connector: " +
          ("PASS" if all(topology.values()) else "FAIL") + f" {topology}")
    print("fight_cavern_persistent_links: " +
          ("PASS" if persistent_links_ok else "FAIL") +
          f" {persistent_links}")
    print("fight_peligro_maps: " +
          ("PASS" if hashes_ok else "FAIL") +
          f" peligro={peligro_shape} pulpo={pulpo_shape}")
    print("fight_pulpo_completion: " +
          ("PASS" if completion_write else "FAIL") +
          f" offset=0577 bytes={tako[0x577:0x57C].hex()} target=FF30")
    print("fight_pulpo_victory: " +
          ("PASS" if boss_hashes_ok and all(victory_contract.values()) else "FAIL") +
          f" hashes={boss_hashes_ok} contract={victory_contract}")
    print("fight_pulpo_encounter: " +
          ("PASS" if encounter_hash_ok and all(encounter_contract.values()) else "FAIL") +
          f" hash={encounter_hash_ok} contract={encounter_contract}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Peligro resources and MP21 route")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
