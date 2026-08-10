#!/usr/bin/env python3
"""Release-MASM oracle for the Clay Shield equipment tier."""

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
STDPLY_BIN = MASM_ROOT / "bin" / "stdply.bin"


def main() -> int:
    armory = ARMORY_BIN.read_bytes()
    select = SELECT_BIN.read_bytes()
    fight = FIGHT_BIN.read_bytes()
    stdply = STDPLY_BIN.read_bytes()

    strength_table = bytes.fromhex("1e005000b4002c012c015802")
    purchase_commit = bytes.fromhex(
        "a02fbca29300e853faa09300bba43e2eff162020bb1cc632c0b517"
        "2eff1604208a1e9300fecb32ff03db8b87bfa6a39600a39400"
    )
    damage_and_break = bytes.fromhex(
        "f6069300ff7428d1e88a0e9300fec1d0e9d3e8290694007202750b"
        "50e81900c7069400000058e87a00c60675ff08c3e87100c60675ff09"
        "c3c606930000"
    )
    holy_repair = bytes.fromhex(
        "c60675ff0ef6069300ff7501c38a1e9300fecb32ff03db8b8720a5"
        "01069400a194002b0696007206a19600a39400"
    )
    repair_amounts = bytes.fromhex("50005a0064006e0073007800")
    stock = stdply[0xDB:0xE4]
    expected_stock = bytes.fromhex("c0e0e07030381c1cfc")

    checks = {
        "shop_and_inventory_names":
            armory.count(b"Clay shield\0") == 1 and
            select.count(b"Clay\0     Shield\0") == 1,
        "tier_1_max_strength_30":
            armory.count(strength_table) == 1 and
            int.from_bytes(strength_table[0:2], "little") == 30,
        "purchase_replaces_and_fills_current_max":
            armory.count(purchase_commit) == 1,
        "native_town_stock_bits":
            stock == expected_stock and
            tuple(bool(value & 0x80) for value in stock) ==
            (True, True, True, False, False, False, False, False, True),
        "tier_reduction_damage_and_break": fight.count(damage_and_break) == 1,
        "holy_water_tier_1_repairs_80_and_caps":
            select.count(holy_repair) == 1 and
            select.count(repair_amounts) == 1 and
            int.from_bytes(repair_amounts[0:2], "little") == 80,
        "persisted_equipped_current_and_max_fields":
            len(stdply) >= 0x98 and stdply[0x93:0x98] == bytes(5),
    }
    for name, passed in checks.items():
        print(f"clay_shield:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Clay Shield tier 1, 30 strength, town "
          "stock, purchase/equip, damage/break, persistence fields, and "
          "80-point capped Holy Water repair")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
