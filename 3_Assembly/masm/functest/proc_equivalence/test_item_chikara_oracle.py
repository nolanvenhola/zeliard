#!/usr/bin/env python3
"""Release-byte oracle for the Witchcraft Chikara Powder contract."""

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
    restore_all = bytes.fromhex(
        "c6 06 75 ff 0e 0e 07 be b4 00 bf ab 00 b9 07 00 f3 a4"
    )
    price_record = bytes.fromhex(
        "00 32 00 00 f0 00 00 3c 00 00 40 01 "
        "00 e8 03 00 64 00 00 b0 04 00 5e 01"
    )
    checks = {
        "inventory_name": b"Chikara\x00      Powder\x00" in select,
        "item_id4_dispatches_a4be": select.count(dispatch) == 1,
        "copies_all_seven_maxima_without_learned_filter":
            select.count(restore_all) == 1,
        "shop_name": b"Chikara Powder\x00" in drugp,
        "shop_description": b"fully restore your magical powers" in drugp,
        "witchcraft_price320_record": drugp.count(price_record) >= 1,
    }
    for name, passed in checks.items():
        print(f"item_chikara:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Chikara as item 4 and copies all seven maximum charges")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
