#!/usr/bin/env python3
"""Release-byte oracle for Magia Stone and Sabre Oil item effects.

201SELCT item IDs are one-based. Its dispatch slots prove that ID 5 enters
the four-record Magia orbit initializer and ID 7 enters the Sabre Oil power
increment. 200FIGHT then advances/renders those records and applies E4h+1 as
the sword offensive-power multiplier.
"""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402

SELECT_BUILT, _ = BIN_PATHS["select"]
SELECT_WORKING = MASM_ROOT / "working" / "zelres2" / "code" / "201SELCT.bin"
SELECT_BIN = SELECT_BUILT if SELECT_BUILT.exists() else SELECT_WORKING
FIGHT_BUILT, _ = BIN_PATHS["fight"]
FIGHT_WORKING = MASM_ROOT / "working" / "zelres2" / "code" / "200FIGHT.bin"
FIGHT_BIN = FIGHT_BUILT if FIGHT_BUILT.exists() else FIGHT_WORKING


def main() -> int:
    select = SELECT_BIN.read_bytes()
    fight = FIGHT_BIN.read_bytes()

    # Dispatch entries for item IDs 5/6/7: A52C Magia, A4EA Holy Water,
    # A4DB Sabre Oil. The binary table is little-endian.
    dispatch = bytes.fromhex("2c a5 ea a4 db a4")
    # Sabre Oil posts cue 0Eh and increments the temporary power byte E4h.
    oil_increment = bytes.fromhex("c6 06 75 ff 0e fe 06 e4 00")
    # Magia seeds its first record at EB60h from A584h after setting phase 0
    # and direction +1; the handler repeats this for phases 4, 8, and 12.
    magia_start = bytes.fromhex(
        "0e 07 c6 06 75 ff 0e c6 06 84 a5 00 c6 06 85 a5 01"
    )
    first_orbit_copy = bytes.fromhex("be 84 a5 bf 60 eb b9 07 00 f3 a4")
    # Sword power multiplies by E4h+1. Two fight loops scan four records at
    # EB60h: one advances their phases and one draws them around the hero.
    oil_consumer = bytes.fromhex("8a 0e e4 00 fe c1 f6 e1")
    orbit_scan = bytes.fromhex("be 60 eb b9 04 00")

    checks = {
        "item_5_6_7_dispatch": select.count(dispatch) == 1,
        "sabre_oil_increment": select.count(oil_increment) == 1,
        "magia_initializer": select.count(magia_start) == 1,
        "magia_first_record": select.count(first_orbit_copy) == 1,
        "sabre_oil_fight_multiplier": fight.count(oil_consumer) == 1,
        "magia_fight_advance_and_draw": fight.count(orbit_scan) == 2,
    }
    for name, passed in checks.items():
        print(f"select_item_effect:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Magia orbit and Sabre Oil sword power")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
