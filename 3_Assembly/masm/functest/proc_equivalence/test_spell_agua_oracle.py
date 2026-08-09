#!/usr/bin/env python3
"""Release-byte oracle for Agua teaching, selection, and water projectiles."""

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
    kenjp = (MASM_ROOT / "bin" / "zelres2" / "217KENJP.bin").read_bytes()

    award = bytes.fromhex(
        "b0 01 eb 18 b0 02 eb 14 b0 03 eb 10 b0 04 eb 0c "
        "b0 05 eb 08 b0 06 eb 04 b0 07 eb 00"
    )
    learned_scan = bytes.fromhex("be bb 00 bf 03 ae")
    select_write = bytes.fromhex("bb 03 ae a0 fb ad d7 a2 9d 00")
    consume_one = bytes.fromhex(
        "8a 1e 9d 00 fe cb 32 ff f6 87 ab 00 ff 75 01 c3 "
        "fe 8f ab 00 2e ff 16 18 20"
    )
    dispatch_table = bytes.fromhex(
        "4d 88 4d 88 4d 88 4d 88 a8 88 f8 88 18 89"
    )
    secondary_table = bytes.fromhex(
        "d4 8a f7 8a 09 8b f7 8a 64 8b 83 8b 9c 8b"
    )
    three_water_initializer = bytes.fromhex(
        "56 b9 03 00 51 e8 4d ff 83 c6 10 59 e2 f6 5e "
        "80 6c 02 02 80 64 02 3f 80 44 12 02 80 64 12 3f c3"
    )
    three_water_step = bytes.fromhex(
        "fe 44 04 80 7c 04 0a 73 19 b9 03 00 51 e8 2f 00 "
        "e8 61 00 83 c6 10 59 e2 f3 c3"
    )
    object_marker = bytes.fromhex(
        "8a 47 05 0c 40 24 e0 8a 26 9d 00 fe c4 0a c4 88 47 05"
    )
    checks = {
        "saied_dialog": b"ll of Water: Agua." in kenjp,
        "agua_award_id6": kenjp.count(award) == 1,
        "agua_name": b"Agua\x00" in select,
        "learned_only_selection": select.count(learned_scan) == 1,
        "selection_writes_9d": select.count(select_write) == 1,
        "one_charge": fight.count(consume_one) == 1,
        "agua_primary_88f8": fight.count(dispatch_table) == 1,
        "agua_secondary_8b83": fight.count(secondary_table) == 1,
        "three_vertical_water_slots": fight.count(three_water_initializer) == 1,
        "three_directional_water_steps": fight.count(three_water_step) == 1,
        "selected_spell_damage_marker": fight.count(object_marker) == 1,
    }
    for name, passed in checks.items():
        print(f"spell_agua:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Agua teaching, charge, three-shot geometry, travel, and damage")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
