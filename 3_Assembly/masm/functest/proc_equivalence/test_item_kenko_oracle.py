#!/usr/bin/env python3
"""Release-byte oracle for the Witchcraft Ken'ko Potion contract."""

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
    drugp = (MASM_ROOT / "bin" / "zelres2" / "215DRUGP.bin").read_bytes()

    dispatch = bytes.fromhex(
        "62 a4 83 a4 96 a4 be a4 2c a5 ea a4 db a4 8b a5"
    )
    consume_selected = bytes.fromhex(
        "c6 47 ff 00 e8 05 02 a0 ff ad a2 4b ff 8a 1e ff ad "
        "fe cb 32 ff 03 db ff a7"
    )
    heal_80_and_cap = bytes.fromhex(
        "c6 06 75 ff 0e 83 06 90 00 50 a1 90 00 "
        "2b 06 b2 00 72 06 a1 b2 00 a3 90 00"
    )
    shop_price_record = bytes.fromhex(
        "00 32 00 00 f0 00 00 3c 00 00 40 01 "
        "00 e8 03 00 64 00 00 b0 04 00 5e 01"
    )
    checks = {
        "inventory_name": b"Ken\\ko\x00      Potion\x00" in select,
        "item_id1_dispatches_a462": select.count(dispatch) == 1,
        "selected_item_consumed_before_handler":
            select.count(consume_selected) == 1,
        "heals_80_and_caps_at_max": select.count(heal_80_and_cap) == 1,
        "shop_name": b"Ken\\ko Potion\x00" in drugp,
        "shop_description":
            b"low in price and as a mild heal" in drugp,
        "witchcraft_price50_record": drugp.count(shop_price_record) >= 1,
    }
    for name, passed in checks.items():
        print(f"item_kenko:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Ken'ko as item 1, +80 HP capped, consumed even at full life")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
