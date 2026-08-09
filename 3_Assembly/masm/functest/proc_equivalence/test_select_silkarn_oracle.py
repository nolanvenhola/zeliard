#!/usr/bin/env python3
"""Release-byte oracle for Silkarn ownership, equip, and slope traversal."""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402


def release_binary(key: str, name: str) -> bytes:
    built, _ = BIN_PATHS[key]
    working = MASM_ROOT / "working" / "zelres2" / "code" / name
    return (built if built.exists() else working).read_bytes()


def main() -> int:
    select = release_binary("select", "201SELCT.bin")
    fight = release_binary("fight", "200FIGHT.bin")

    owned_scan = bytes.fromhex(
        "be a1 00 bf 0a ae 32 c0 aa 32 c9 b5 05 ac 0a c0 74 03 aa fe c1"
    )
    equip_write = bytes.fromhex("bb 0a ae a0 fd ad d7 a2 9e 00")
    # combat_input_poll_step normally consumes hp_midpoint while processing
    # authored slope tiles. Selected wearable ID 3 returns before that
    # decrement, which is the exact Silkarn slope-traversal exception.
    slope_gate = bytes.fromhex("a0 9e 00 3c 03 75 01 c3 fe 0e 0c 9f")
    # entity_fn_e_6's Area-6 reward tuple stores wearable ID 3 and the Pirika-
    # table message pointer 9B7Fh used for the Silkarn acquisition message.
    reward_tuple = bytes.fromhex("03 7f 9b")
    checks = {
        "owned_wearable_compaction": select.count(owned_scan) == 1,
        "equip_writes_selected_accessory": select.count(equip_write) == 1,
        "silkarn_name": b"Silkarn\x00      shoes\x00" in select,
        "silkarn_pickup_message": b"You get the Silkarn shoes." in fight,
        "area6_reward_tuple": fight.count(reward_tuple) == 1,
        "silkarn_id3_slope_gate": fight.count(slope_gate) == 1,
    }
    for name, passed in checks.items():
        print(f"select_silkarn:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Silkarn acquisition, equip, and slope traversal")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
