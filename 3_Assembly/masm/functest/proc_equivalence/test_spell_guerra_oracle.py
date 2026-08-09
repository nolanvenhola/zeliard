#!/usr/bin/env python3
"""Release-byte oracle for Guerra teaching, selection, and screen lightning."""

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
    screen_lightning_scan = bytes.fromhex(
        "c6 06 ed 9e ff c6 06 ee 9e ff f6 06 34 ff ff 74 07 "
        "f6 06 2e ff ff 75 24 8b 36 31 ff 83 ee 24 e8 54 e4 "
        "b9 13 00 51 b9 24 00 51 f6 04 80 74 03 e8 05 03 "
        "46 59 e2 f3 e8 31 e4 59 e2 e9"
    )
    immediate_finish_and_cue = bytes.fromhex(
        "c6 06 3e ff 00 c6 06 75 ff 19 2e ff 16 18 30 "
        "c6 06 1e ff 00 e8 48 ea e9 2d e6"
    )
    checks = {
        "indihar_dialog": b"l of Lightning: Guerra." in kenjp,
        "guerra_award_id7": kenjp.count(award) == 1,
        "guerra_name": b"Guerra\x00" in select,
        "learned_only_selection": select.count(learned_scan) == 1,
        "selection_writes_9d": select.count(select_write) == 1,
        "one_charge": fight.count(consume_one) == 1,
        "guerra_primary_8918": fight.count(dispatch_table) == 1,
        "guerra_secondary_is_return_8b9c": fight.count(secondary_table) == 1,
        "screen_wide_19x36_scan": fight.count(screen_lightning_scan) == 1,
        "immediate_finish_and_sound19": fight.count(immediate_finish_and_cue) == 1,
    }
    for name, passed in checks.items():
        print(f"spell_guerra:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Guerra teaching, charge, immediate full-screen scan, and lightning cue")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
