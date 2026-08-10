#!/usr/bin/env python3
"""Release-MASM oracle for the Wise Man's Sword equipment tier.

The native game stores one equipped sword byte at player offset 0092h.
Armory purchases replace that byte (and trade the previous tier); combat
indexes the six-entry power table with ``sword - 1``.  This fixture locks
the Wise Man tier's acquisition text/HUD name, replacement semantics,
attack input/audio latch, and base power 2 directly to release bytes.
"""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402

WEB_ASSETS = MASM_ROOT.parents[1] / "6_WebPort" / "engine" / "assets"
ARMORY_BIN = WEB_ASSETS / "armrpro.bin"
SELECT_BIN = BIN_PATHS["select"][0]
FIGHT_BIN = BIN_PATHS["fight"][0]


def main() -> int:
    armory = ARMORY_BIN.read_bytes()
    select = SELECT_BIN.read_bytes()
    fight = FIGHT_BIN.read_bytes()

    # 212ARMRP: new_item_flag -> player:sword (0092h), proving replacement
    # equipment rather than an independently owned sword collection.
    weapon_commit = bytes.fromhex(
        "a0 2f bc a2 92 00 3c 06 75 0d"
    )
    # 200FIGHT attack edge: state/subframe 2, one-shot audio latch, cue 4.
    attack_latch = bytes.fromhex(
        "c6 06 45 ff 02 c6 06 46 ff 02 f6 06 47 ff ff 74 03 "
        "e9 87 00 c6 06 47 ff ff c6 06 75 ff 04"
    )
    # Damage indexes by sword-1, adds experience, applies Sabre Oil, then
    # doubles only during action state 2. The immediately following table
    # gives native sword powers 1,2,4,8,32,127.
    power_path = bytes.fromhex(
        "8a 1e 92 00 fe cb 32 ff 8a 87 b8 98 8a 1e 8d 00 d0 eb "
        "02 c3 72 0c 8a 0e e4 00 fe c1 f6 e1 0a e4 74 02 b0 ff "
        "8a e0 80 3e 45 ff 02 74 01 c3 02 e4 72 01 c3 b4 ff c3 "
        "01 02 04 08 20 7f"
    )

    checks = {
        "armory_name": armory.count(b"Wise man\\s sword\0") == 1,
        "armory_replaces_equipped_tier": armory.count(weapon_commit) == 1,
        "inventory_hud_name":
            select.count(b"Wise man\\s\0      Sword\0") == 1,
        "attack_state_and_audio_edge": fight.count(attack_latch) == 1,
        "tier_2_base_power": fight.count(power_path) == 1,
    }
    for name, passed in checks.items():
        print(f"wise_man_sword:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Wise Man's Sword as equipped tier 2, power 2")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
