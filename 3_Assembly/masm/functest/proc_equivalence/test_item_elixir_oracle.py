#!/usr/bin/env python3
"""Release-byte oracle for the Witchcraft Elixir of Kashi contract."""

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
    restore_selected_to_max = bytes.fromhex(
        "c6 06 75 ff 0e f6 06 9d 00 ff 75 01 c3 8a 1e 9d 00 "
        "fe cb 32 ff 8a 87 b4 00 88 87 ab 00"
    )
    price_record = bytes.fromhex(
        "00 32 00 00 f0 00 00 3c 00 00 40 01 "
        "00 e8 03 00 64 00 00 b0 04 00 5e 01"
    )
    checks = {
        "inventory_name": b"Elixir\x00    of Kashi\x00" in select,
        "item_id3_dispatches_a496": select.count(dispatch) == 1,
        "selected_spell_required_and_restored_to_max":
            select.count(restore_selected_to_max) == 1,
        "shop_name": b"Elixir of Kashi\x00" in drugp,
        "shop_description": b"It restores magical powers." in drugp,
        "witchcraft_price60_record": drugp.count(price_record) >= 1,
    }
    for name, passed in checks.items():
        print(f"item_elixir:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Elixir as item 3 and restores selected spell to maximum")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
