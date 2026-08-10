#!/usr/bin/env python3
"""Release-byte oracle for the Holy Water of Acero item contract."""

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
    repair_handler = bytes.fromhex(
        "c6 06 75 ff 0e f6 06 93 00 ff 75 01 c3 8a 1e 93 00 "
        "fe cb 32 ff 03 db 8b 87 20 a5 01 06 94 00 a1 94 00 "
        "2b 06 96 00 72 06 a1 96 00 a3 94 00"
    )
    tier_amounts = bytes.fromhex(
        "50 00 5a 00 64 00 6e 00 73 00 78 00"
    )
    price_record = bytes.fromhex(
        "00 32 00 00 f0 00 00 3c 00 00 40 01 "
        "00 e8 03 00 64 00 00 b0 04 00 5e 01"
    )
    checks = {
        "inventory_name": b"Holy Water\x00" in select,
        "item_id6_dispatches_a4ea": select.count(dispatch) == 1,
        "no_shield_return_and_max_cap": select.count(repair_handler) == 1,
        "six_tier_repair_amounts_80_to_120": select.count(tier_amounts) == 1,
        "shop_name": b"Holy Water of Acero\x00" in drugp,
        "shop_description": b"shield weakened by battle" in drugp,
        "witchcraft_price100_record": drugp.count(price_record) >= 1,
    }
    for name, passed in checks.items():
        print(f"item_holy_water:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Holy Water item 6, tier repairs, cap, and no-shield consumption")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
