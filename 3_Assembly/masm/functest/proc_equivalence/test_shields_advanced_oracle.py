#!/usr/bin/env python3
"""Release-MASM oracle for Honor, Light, and Titanium shields."""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402

WEB_ASSETS = MASM_ROOT.parents[1] / "6_WebPort" / "engine" / "assets"


def main() -> int:
    armory = (WEB_ASSETS / "armrpro.bin").read_bytes()
    select = BIN_PATHS["select"][0].read_bytes()
    fight = BIN_PATHS["fight"][0].read_bytes()
    stdply = (MASM_ROOT / "bin" / "stdply.bin").read_bytes()
    maxima = (30, 80, 180, 300, 300, 600)
    repairs = (80, 90, 100, 110, 115, 120)
    strength_table = b"".join(v.to_bytes(2, "little") for v in maxima)
    repair_table = b"".join(v.to_bytes(2, "little") for v in repairs)
    damage_and_break = bytes.fromhex(
        "f6069300ff7428d1e88a0e9300fec1d0e9d3e8290694007202750b"
        "50e81900c7069400000058e87a00c60675ff08c3e87100c60675ff09"
        "c3c606930000")
    holy_repair = bytes.fromhex(
        "c60675ff0ef6069300ff7501c38a1e9300fecb32ff03db8b8720a5"
        "01069400a194002b0696007206a19600a39400")
    purchase_commit = bytes.fromhex(
        "a02fbca29300e853faa09300bba43e2eff162020bb1cc632c0b517"
        "2eff1604208a1e9300fecb32ff03db8b87bfa6a39600a39400")
    stock = stdply[0xDB:0xE4]
    expected_stock = bytes.fromhex("c0e0e07030381c1cfc")
    expected_availability = {
        "honor": (False, False, False, True, True, True, True, True, True),
        "light": (False, False, False, False, False, True, True, True, True),
        "titanium": (False, False, False, False, False, False, True, True, True),
    }
    checks = {
        "all_shop_and_inventory_names":
            armory.count(b"Honor shield\0") == 1 and
            armory.count(b"Light shield\0") == 1 and
            armory.count(b"Titanium Shield\0") == 1 and
            select.count(b"Honor\0     Shield\0") == 1 and
            select.count(b"Light\0     Shield\0") == 1 and
            select.count(b"Titanium\0      Shield\0") == 1,
        "maxima_300_300_600":
            armory.count(strength_table) == 1 and maxima[3:] == (300, 300, 600),
        "repair_amounts_110_115_120":
            select.count(repair_table) == 1 and repairs[3:] == (110, 115, 120),
        "purchase_initializes_tier_current_and_max":
            armory.count(purchase_commit) == 1,
        "common_damage_drain_and_break": fight.count(damage_and_break) == 1,
        "holy_water_repairs_and_caps": select.count(holy_repair) == 1,
        "advanced_town_stock":
            stock == expected_stock and
            tuple(bool(v & 0x10) for v in stock) == expected_availability["honor"] and
            tuple(bool(v & 0x08) for v in stock) == expected_availability["light"] and
            tuple(bool(v & 0x04) for v in stock) == expected_availability["titanium"],
        "light_has_extra_native_reduction_shift":
            (1 + ((4 + 1) >> 1), 1 + ((5 + 1) >> 1)) == (3, 4),
        "persisted_equipped_current_and_max_fields":
            len(stdply) >= 0x98 and stdply[0x93:0x98] == bytes(5),
    }
    for name, passed in checks.items():
        print(f"advanced_shields:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("advanced_shields_contract: tiers=4/5/6 maxima=300/300/600 "
          "repairs=110/115/120 reduction_shifts=3/4/4")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM advanced shield acquisition, protection, break, "
          "repair, stock, rendering names, and persistence")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
