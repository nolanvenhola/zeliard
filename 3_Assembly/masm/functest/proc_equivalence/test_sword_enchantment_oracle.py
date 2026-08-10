#!/usr/bin/env python3
"""Release-MASM oracle for the Enchantment/Fairy Flame sword tier."""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402

SELECT_BIN = BIN_PATHS["select"][0]
FIGHT_BIN = BIN_PATHS["fight"][0]
GFMCGA_BIN = MASM_ROOT / "bin" / "zelres2" / "206GFMCA.bin"


def main() -> int:
    select = SELECT_BIN.read_bytes()
    fight = FIGHT_BIN.read_bytes()
    gfmcga = GFMCGA_BIN.read_bytes()

    reward_commit = bytes.fromhex(
        "ba 9c 9b e8 57 e4 56 2e ff 16 04 30 c6 06 92 00 06 "
        "b0 06 bb ab 18 2e ff 16 1c 20 8a 26 92 00 b0 04 "
        "2e ff 16 0c 01 5e c3"
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
        "arrugia_reward_dialog":
            fight.count(b"Get the Enchantment sword.") == 1,
        "arrugia_reward_commit": fight.count(reward_commit) == 1,
        "inventory_hud_name":
            select.count(b"Enchantment\0       Sword\0") == 1,
        "attack_state_and_audio_edge": fight.count(attack_latch) == 1,
        "tier_6_base_power_127_and_saturation":
            fight.count(power_path) == 1 and power_path[-1] == 0x7F and
            bytes.fromhex("72 01 c3 b4 ff c3") in power_path,
        "mcga_tier_6_color_pair": gfmcga.count(mcga_color_pairs) == 1 and
            mcga_color_pairs[10:12] == bytes((0x06, 0x36)),
        "mcga_longest_reach_renderer_family":
            gfmcga.count(mcga_copy_routines) == 1 and
            mcga_copy_routines[10:12] == bytes((0xF1, 0x4A)),
        "mcga_tier_6_geometry": gfmcga.count(mcga_tier_geometry) == 1 and
            mcga_tier_geometry[10:12] == bytes((0xC8, 0x4F)),
    }
    for name, passed in checks.items():
        print(f"enchantment_sword:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines the Arrugia Enchantment Sword reward, "
          "tier-6 inventory/HUD resources, attack latch, base table value "
          "127, overflow saturation, and longest-reach renderer")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
