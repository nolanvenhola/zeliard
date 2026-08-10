#!/usr/bin/env python3
"""Release-MASM oracle for the Knight's Sword and Glory Crest exchange."""

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

    # The special offer requires trade bit clear, Tumba (town 5), and the
    # Glory Crest byte at 009Bh. It replaces the ordinary shop script.
    exchange_gate = bytes.fromhex(
        "f6 06 24 00 02 75 19 80 3e 06 c0 05 75 12 "
        "f6 06 9b 00 ff 74 0b c7 06 4c ff a2 b2 c6 06 23 bc 00"
    )
    # Accepting equips tier 4, consumes the crest, redraws the sword, removes
    # Tumba stock bit 10h, marks the exchange, and loads tier-4 sword assets.
    exchange_commit = bytes.fromhex(
        "c6 06 92 00 04 c6 06 9b 00 00 b0 04 bb ab 18 "
        "2e ff 16 1c 20 80 26 d6 00 ef 80 0e 24 00 02 "
        "8a 26 92 00 b0 04 2e ff 16 0c 01 c3"
    )
    attack_latch = bytes.fromhex(
        "c6 06 45 ff 02 c6 06 46 ff 02 f6 06 47 ff ff 74 03 "
        "e9 87 00 c6 06 47 ff ff c6 06 75 ff 04"
    )
    power_path = bytes.fromhex(
        "8a 1e 92 00 fe cb 32 ff 8a 87 b8 98 8a 1e 8d 00 d0 eb "
        "02 c3 72 0c 8a 0e e4 00 fe c1 f6 e1 0a e4 74 02 b0 ff "
        "8a e0 80 3e 45 ff 02 74 01 c3 02 e4 72 01 c3 b4 ff c3 "
        "01 02 04 08 20 7f"
    )

    checks = {
        "armory_name": armory.count(b"Knight\\s sword\0") == 1,
        "glory_crest_tumba_gate": armory.count(exchange_gate) == 1,
        "exchange_dialog":
            rb"Might I trade you a knight\s sword for it?" in armory and
            rb"here is your knight\s sword" in armory,
        "atomic_exchange_and_tier_asset_load":
            armory.count(exchange_commit) == 1,
        "inventory_hud_name":
            select.count(b"Knight\\s\0    Sword\0") == 1,
        "attack_state_and_audio_edge": fight.count(attack_latch) == 1,
        "tier_4_base_power": fight.count(power_path) == 1 and
            power_path[-6:][3] == 8,
    }
    for name, passed in checks.items():
        print(f"knight_sword:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines the one-time Glory Crest exchange for "
          "Knight's Sword tier 4, power 8")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
