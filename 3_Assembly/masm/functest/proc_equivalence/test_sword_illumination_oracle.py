#!/usr/bin/env python3
"""Release-MASM oracle for the Illumination Sword equipment tier."""

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
GFMCGA_BIN = MASM_ROOT / "bin" / "zelres2" / "206GFMCA.bin"


def main() -> int:
    armory = ARMORY_BIN.read_bytes()
    select = SELECT_BIN.read_bytes()
    fight = FIGHT_BIN.read_bytes()
    gfmcga = GFMCGA_BIN.read_bytes()

    weapon_commit = bytes.fromhex("a0 2f bc a2 92 00 3c 06 75 0d")
    tier_asset_reload = bytes.fromhex(
        "8a 26 92 00 b0 04 2e ff 16 0c 01 a0 92 00 bb ab 18"
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
    mcga_color_pairs = bytes.fromhex(
        "01 09 04 24 03 1b 01 09 04 24 06 36"
    )
    mcga_copy_routines = bytes.fromhex(
        "31 4a 31 4a 31 4a 91 4a 91 4a f1 4a"
    )
    mcga_tier_geometry = bytes.fromhex(
        "98 4f a8 4f b8 4f c8 4f d8 4f c8 4f"
    )

    checks = {
        "armory_name": armory.count(b"Illumination sword\0") == 1,
        "armory_replaces_equipped_tier": armory.count(weapon_commit) == 1,
        "tier_5_resource_and_hud_redraw":
            armory.count(tier_asset_reload) == 1,
        "inventory_hud_name":
            select.count(b"Illumination\0       Sword\0") == 1,
        "attack_state_and_audio_edge": fight.count(attack_latch) == 1,
        "tier_5_base_power_32": fight.count(power_path) == 1 and
            power_path[-6:][4] == 0x20,
        "mcga_tier_color_pair": gfmcga.count(mcga_color_pairs) == 1 and
            mcga_color_pairs[8:10] == bytes((0x04, 0x24)),
        "mcga_long_reach_renderer_family":
            gfmcga.count(mcga_copy_routines) == 1 and
            mcga_copy_routines[8:10] == bytes((0x91, 0x4A)),
        "mcga_tier_5_geometry": gfmcga.count(mcga_tier_geometry) == 1 and
            mcga_tier_geometry[8:10] == bytes((0xD8, 0x4F)),
    }
    for name, passed in checks.items():
        print(f"illumination_sword:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Illumination Sword as tier 5, base power "
          "32, with tier-indexed long-reach geometry/color visuals")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
