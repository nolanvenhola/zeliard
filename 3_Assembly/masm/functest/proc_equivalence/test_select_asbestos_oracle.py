#!/usr/bin/env python3
"""Release oracle for Asbestos Cape acquisition, equip, and heat protection."""

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


def payload(path: Path) -> bytes:
    data = path.read_bytes()
    size = int.from_bytes(data[:4], "little")
    return data[4:4 + size]


def main() -> int:
    select = release_binary("select", "201SELCT.bin")
    fight = release_binary("fight", "200FIGHT.bin")
    llama = payload(MASM_ROOT / "bin" / "zelres2" / "243LLMP.mdt")

    owned_scan = bytes.fromhex(
        "be a1 00 bf 0a ae 32 c0 aa 32 c9 b5 05 ac 0a c0 74 03 aa fe c1"
    )
    equip_write = bytes.fromhex("bb 0a ae a0 fd ad d7 a2 9e 00")
    # Area 7 increments the frame counter and subtracts 15 HP each 64 frames
    # unless selected_accessory is wearable ID 5, the Asbestos Cape.
    heat_gate = bytes.fromhex(
        "80 3e 12 c0 07 75 28 80 3e 9e 00 05 74 21 fe 06 25 9f "
        "f6 06 25 9f 3f 75 16"
    )
    checks = {
        "owned_wearable_compaction": select.count(owned_scan) == 1,
        "equip_writes_selected_accessory": select.count(equip_write) == 1,
        "asbestos_name": b"Asbestos\x00       cape\x00" in select,
        "llama_description":
            b"an Asbestos cape that will protect you from the heat" in llama,
        "llama_price": b"It will cost you 2500&almas" in llama,
        "asbestos_id5_heat_gate": fight.count(heat_gate) == 1,
    }
    for name, passed in checks.items():
        print(f"select_asbestos:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines Cape acquisition, equip, and Area-7 heat protection")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
