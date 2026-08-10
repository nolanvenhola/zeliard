#!/usr/bin/env python3
"""Release-byte oracle for the Kioku Feather and last-Sage handoff."""

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
    drugp = (MASM_ROOT / "bin" / "zelres2" / "215DRUGP.bin").read_bytes()
    dispatch = bytes.fromhex(
        "62 a4 83 a4 96 a4 be a4 2c a5 ea a4 db a4 8b a5"
    )
    feather_handler = bytes.fromhex(
        "c6 06 75 ff 0f e8 47 00 e8 1e 00 58 58 c6 06 24 "
        "ff 08 c6 06 1a ff 00 80 3e 1a ff 78 72 f9 2e ff "
        "16 40 20 b8 01 00 cd 60 c3"
    )
    fight_result_gate = bytes.fromhex("80 3e 4b ff 08 75 03 e9")
    reload_last_sage = bytes.fromhex(
        "c6 06 08 ff 00 8a 26 c5 00 88 26 c4 00 b0 01"
    )
    price_record = bytes.fromhex(
        "00 32 00 00 f0 00 00 3c 00 00 40 01 "
        "00 e8 03 00 64 00 00 b0 04 00 5e 01"
    )
    checks = {
        "inventory_name": b"Kioku\x00     feather\x00" in select,
        "item_id8_dispatches_a58b": select.count(dispatch) == 1,
        "cue_scene8_timer120_fade_and_int60":
            select.count(feather_handler) == 1,
        "fight_recognizes_result8": fight.count(fight_result_gate) == 1,
        "fight_reloads_current_area_from_last_sage_c5":
            fight.count(reload_last_sage) == 1,
        "shop_name": b"Kioku Feather\x00" in drugp,
        "shop_description": b"last wise man who spoke to you" in drugp,
        "witchcraft_price350_record": drugp.count(price_record) >= 1,
    }
    for name, passed in checks.items():
        print(f"item_kioku:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Kioku item 8, timed fade, and C5 last-Sage reload")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
