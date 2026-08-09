#!/usr/bin/env python3
"""Release-byte oracle for Pirika ownership, equip, and contact protection."""

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

    # The inventory owns wearables in A1h..A5h, compacts every nonzero ID
    # behind an implicit unequipped zero, and keeps only owned entries usable.
    owned_scan = bytes.fromhex(
        "be a1 00 bf 0a ae 32 c0 aa 32 c9 b5 05 ac 0a c0 74 03 aa fe c1"
    )
    # Moving the accessory cursor XLATs that compact table and immediately
    # writes its ID to selected_accessory (009Eh).
    equip_write = bytes.fromhex("bb 0a ae a0 fd ad d7 a2 9e 00")
    # scan_outer_slot_match returns immediately only for Pirika ID 2. This is
    # the native contact-hazard/Gelroid protection; other hazard branches use
    # their own wearable IDs and must not be widened to Pirika.
    contact_gate = bytes.fromhex("80 3e 9e 00 02 75 01 c3")
    checks = {
        "owned_wearable_compaction": select.count(owned_scan) == 1,
        "equip_writes_selected_accessory": select.count(equip_write) == 1,
        "pirika_name": b"Pirika\x00      shoes\x00" in select,
        "pirika_pickup_message": b"You get the Pirika shoes." in fight,
        "pirika_id2_contact_gate": fight.count(contact_gate) == 1,
    }
    for name, passed in checks.items():
        print(f"select_pirika:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Pirika acquisition, equip, and contact protection")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
