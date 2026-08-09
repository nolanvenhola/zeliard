#!/usr/bin/env python3
"""Release-byte oracle for Feruza ownership, equip, and jump height."""

from __future__ import annotations

import struct
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402


def release_binary(key: str, name: str) -> bytes:
    built, _ = BIN_PATHS[key]
    working = MASM_ROOT / "working" / "zelres2" / "code" / name
    return (built if built.exists() else working).read_bytes()


def map_records(name: str) -> list[bytes]:
    raw = (MASM_ROOT / "bin" / "zelres3" / name).read_bytes()[4:]
    at = struct.unpack_from("<H", raw, 0x10)[0] - 0xC000
    rows = []
    while raw[at:at + 2] != b"\xff\xff":
        rows.append(raw[at:at + 16])
        at += 16
    return rows


def main() -> int:
    select = release_binary("select", "201SELCT.bin")
    fight = release_binary("fight", "200FIGHT.bin")
    arrugia = map_records("336MP62.mdt")

    owned_scan = bytes.fromhex(
        "be a1 00 bf 0a ae 32 c0 aa 32 c9 b5 05 ac 0a c0 74 03 aa fe c1"
    )
    equip_write = bytes.fromhex("bb 0a ae a0 fd ad d7 a2 9e 00")
    # update_combat_frame_state chooses a normal jump limit of 2, but writes
    # 4 to hp_max when selected_accessory is Feruza ID 1.
    jump_gate = bytes.fromhex("b0 02 80 3e 9e 00 01 75 02 b0 04 a2 0d 9f")
    # entity_fn_e_5 is Arrugia's fixed wearable reward: message 9B63h and
    # wearable ID 1. Authored function-5 records are persistent map objects.
    reward_handler = bytes.fromhex("ba 63 9b e8 3d 00 73 01 c3 b0 01")
    checks = {
        "owned_wearable_compaction": select.count(owned_scan) == 1,
        "equip_writes_selected_accessory": select.count(equip_write) == 1,
        "feruza_name": b"Feruza\x00      shoes\x00" in select,
        "feruza_pickup_message": b"You get the Feruza shoes." in fight,
        "arrugia_function5_object": any(row[6] == 5 for row in arrugia),
        "feruza_id1_reward_handler": fight.count(reward_handler) == 1,
        "feruza_id1_double_jump_gate": fight.count(jump_gate) == 1,
    }
    for name, passed in checks.items():
        print(f"select_feruza:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Feruza acquisition, equip, and doubled jump limit")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
