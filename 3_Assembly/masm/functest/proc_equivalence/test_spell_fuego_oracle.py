#!/usr/bin/env python3
"""Release-byte oracle for Fuego teaching, selection, and ground-fire behavior."""

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
    # Fuego dispatches through the shared initializer to 8B09h. Its ground
    # fire persists for twelve ticks; after tick four it advances animation
    # direction and checks the two ground cells before dropping one row.
    fuego_step = bytes.fromhex(
        "fe 44 04 80 7c 04 0c 72 03 e9 a0 00 80 7c 04 04 73 05 "
        "e8 b2 00 eb 41 80 64 05 03 fe 44 05"
    )
    object_marker = bytes.fromhex(
        "8a 47 05 0c 40 24 e0 8a 26 9d 00 fe c4 0a c4 88 47 05"
    )
    checks = {
        "chiriga_dialog": b"Spell of Fire: Fuego." in kenjp,
        "fuego_award_id3": kenjp.count(award) == 1,
        "fuego_name": b"Fuego\x00" in select,
        "learned_only_selection": select.count(learned_scan) == 1,
        "selection_writes_9d": select.count(select_write) == 1,
        "one_charge": fight.count(consume_one) == 1,
        "fuego_dispatch_884d": fight.count(dispatch_table) == 1,
        "fuego_twelve_step_ground_fire": fight.count(fuego_step) == 1,
        "selected_spell_damage_marker": fight.count(object_marker) == 1,
    }
    for name, passed in checks.items():
        print(f"spell_fuego:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Fuego teaching, charge, ground motion, and damage marker")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
