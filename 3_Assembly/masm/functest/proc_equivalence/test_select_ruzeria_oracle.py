#!/usr/bin/env python3
"""Release-byte oracle for Ruzeria ownership, equip, and ice traction."""

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

    # The owned-wearable scan seeds AE0Ah with the unequipped ID, compacts
    # nonzero A1h..A5h IDs after it, and counts the leading choice.
    owned_scan = bytes.fromhex(
        "be a1 00 bf 0a ae 32 c0 aa 32 c9 b5 05 ac 0a c0 74 03 aa fe c1"
    )
    # Cursor movement XLATs the compact table and writes the equipped ID to
    # selected_accessory at 009Eh immediately, before returning to gameplay.
    equip_write = bytes.fromhex("bb 0a ae a0 fd ad d7 a2 9e 00")
    # Area 4 returns FF only for equipped wearable ID 4, preventing the
    # move-axis/pending-inertia writes that implement continued ice sliding.
    ice_gate = bytes.fromhex(
        "80 3e 12 c0 04 74 01 c3 80 3e 9e 00 04 75 05 b0 ff 0a c0 c3"
    )
    checks = {
        "owned_wearable_compaction": select.count(owned_scan) == 1,
        "equip_writes_selected_accessory": select.count(equip_write) == 1,
        "ruzeria_name": b"Ruzeria\x00      shoes\x00" in select,
        "ruzeria_pickup_message": b"You get the Ruzeria shoes." in fight,
        "area4_ice_gate": fight.count(ice_gate) == 1,
    }
    for name, passed in checks.items():
        print(f"select_ruzeria:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Ruzeria acquisition, equip, and traction")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
