#!/usr/bin/env python3
"""Release-byte oracle for Espada teaching, selection, and combat dispatch."""

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

    # Sage 2 selects spell ID 1 before the common award path stores 9Dh and
    # marks spell_known[0] at BBh. The seven handlers are contiguous.
    award = bytes.fromhex(
        "b0 01 eb 18 b0 02 eb 14 b0 03 eb 10 b0 04 eb 0c "
        "b0 05 eb 08 b0 06 eb 04 b0 07 eb 00"
    )
    award_common = bytes.fromhex(
        "50 bb 1c aa 32 c0 b5 17 2e ff 16 04 20 58 a2 9d 00 "
        "8a d8 fe cb 32 ff c6 87 bb 00 ff"
    )
    # 201SELCT compacts only learned spell IDs and writes the selected ID at
    # 9Dh from that compact table, preventing selection of an empty slot.
    learned_scan = bytes.fromhex("be bb 00 bf 03 ae")
    select_write = bytes.fromhex("bb 03 ae a0 fb ad d7 a2 9d 00")
    # Combat tests the selected spell's ABh charge, consumes exactly one,
    # emits cue 18h, marks FF3Eh active, then dispatches through 883Fh. The
    # first four spells share the projectile initializer at 884Dh.
    consume_dispatch = bytes.fromhex(
        "8a 1e 9d 00 fe cb 32 ff f6 87 ab 00 ff 75 01 c3 "
        "fe 8f ab 00 2e ff 16 18 20 c6 06 75 ff 18 be 15 eb "
        "c6 06 3e ff ff 8a 1e 9d 00 fe cb 32 ff 03 db ff a7 3f 88"
    )
    dispatch_table = bytes.fromhex(
        "4d 88 4d 88 4d 88 4d 88 a8 88 f8 88 18 89"
    )
    # Espada's per-frame target (8AD4h) expires after five steps, advances in
    # the facing direction, scans collisions, and marks the projectile dead.
    espada_step = bytes.fromhex(
        "f6 44 03 80 74 03 e9 d8 00 fe 44 04 80 7c 04 05 "
        "72 03 e9 cc 00 e8 d6 00 e8 08 01 73 01 c3 80 4c 03 80 c3"
    )
    checks = {
        "yasmin_dialog": b"Magic Spell of Throwing Swords: Espada." in kenjp,
        "seven_spell_awards": kenjp.count(award) == 1,
        "award_selected_and_known": kenjp.count(award_common) == 1,
        "espada_name": b"Espada\x00" in select,
        "learned_only_selection": select.count(learned_scan) == 1,
        "selection_writes_9d": select.count(select_write) == 1,
        "one_charge_then_dispatch": fight.count(consume_dispatch) == 1,
        "espada_dispatch_884d": fight.count(dispatch_table) == 1,
        "espada_five_step_collision": fight.count(espada_step) == 1,
    }
    for name, passed in checks.items():
        print(f"spell_espada:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Espada teaching, selection, charge, and projectile")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
