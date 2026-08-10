#!/usr/bin/env python3
"""Release-MASM oracle for Stone Shield tier 3."""

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

    strength_table = bytes.fromhex(
        "1e 00 50 00 b4 00 2c 01 2c 01 58 02"
    )
    purchase_commit = bytes.fromhex(
        "a0 2f bc a2 93 00 e8 53 fa a0 93 00 bb a4 3e "
        "2e ff 16 20 20 bb 1c c6 32 c0 b5 17 2e ff 16 04 20 "
        "8a 1e 93 00 fe cb 32 ff 03 db 8b 87 bf a6 "
        "a3 96 00 a3 94 00"
    )
    damage_and_break = bytes.fromhex(
        "f6 06 93 00 ff 74 28 d1 e8 8a 0e 93 00 fe c1 d0 e9 "
        "d3 e8 29 06 94 00 72 02 75 0b 50 e8 19 00 "
        "c7 06 94 00 00 00 58 e8 7a 00 c6 06 75 ff 08 c3 "
        "e8 71 00 c6 06 75 ff 09 c3 c6 06 93 00 00"
    )
    holy_repair = bytes.fromhex(
        "c6 06 75 ff 0e f6 06 93 00 ff 75 01 c3 8a 1e 93 00 "
        "fe cb 32 ff 03 db 8b 87 20 a5 01 06 94 00 a1 94 00 "
        "2b 06 96 00 72 06 a1 96 00 a3 94 00"
    )
    repair_amounts = bytes.fromhex(
        "50 00 5a 00 64 00 6e 00 73 00 78 00"
    )
    stock = stdply[0xDB:0xE4]
    expected_stock = bytes.fromhex("c0 e0 e0 70 30 38 1c 1c fc")

    checks = {
        "shop_and_inventory_names":
            armory.count(b"Stone shield\0") == 1 and
            select.count(b"Stone\0     Shield\0") == 1,
        "tier_3_max_strength_180":
            armory.count(strength_table) == 1 and
            int.from_bytes(strength_table[4:6], "little") == 180,
        "purchase_replaces_and_fills_current_max":
            armory.count(purchase_commit) == 1,
        "native_town_stock_bits":
            stock == expected_stock and
            tuple(bool(value & 0x20) for value in stock) ==
            (False, True, True, True, True, True, False, False, True),
        "tier_reduction_damage_and_break": fight.count(damage_and_break) == 1,
        "holy_water_tier_3_repairs_100_and_caps":
            select.count(holy_repair) == 1 and
            select.count(repair_amounts) == 1 and
            int.from_bytes(repair_amounts[4:6], "little") == 100,
        "persisted_player_fields_are_contiguous":
            len(stdply) >= 0x98 and stdply[0x93:0x98] == bytes(5),
    }
    for name, passed in checks.items():
        print(f"stone_shield:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Stone Shield tier 3, 180 strength, "
          "town stock, purchase/equip, damage/break, persistence fields, "
          "and 100-point capped Holy Water repair")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
