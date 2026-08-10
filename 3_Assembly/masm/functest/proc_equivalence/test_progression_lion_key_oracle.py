#!/usr/bin/env python3
"""Release-MASM oracle for the Lion Head's Key progression contract."""

from __future__ import annotations

import struct
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402


def payload(path: Path) -> bytes:
    image = path.read_bytes()
    assert struct.unpack_from("<I", image)[0] == len(image) - 4
    return image[4:]


def records(data: bytes, pointer_offset: int, size: int) -> list[bytes]:
    offset = struct.unpack_from("<H", data, pointer_offset)[0] - 0xC000
    result = []
    while data[offset:offset + 2] != b"\xff\xff":
        result.append(data[offset:offset + size])
        offset += size
    return result


def main() -> int:
    fight = payload(BIN_PATHS["fight"][0])
    select = payload(BIN_PATHS["select"][0])
    stdply = (MASM_ROOT / "bin" / "stdply.bin").read_bytes()
    absor = payload(MASM_ROOT / "bin" / "zelres3" / "343MP80.mdt")
    tesoro = payload(MASM_ROOT / "bin" / "zelres3" / "334MP60.mdt")
    arrugia = payload(MASM_ROOT / "bin" / "zelres3" / "336MP62.mdt")
    pureza = payload(MASM_ROOT / "bin" / "zelres2" / "244PRMP.mdt")

    lion_object = records(absor, 0x10, 16)[32]
    tesoro_doors = records(tesoro, 0x0A, 12)
    arrugia_doors = records(arrugia, 0x0A, 12)
    acquisition = bytes.fromhex(
        "ba cb 9b e8 d5 00 73 01 c3 fe 06 99 00 e9 44 01"
    )
    lion_unlock = bytes.fromhex(
        "f6 06 99 00 ff f9 75 01 c3 fe 0e 99 00 "
        "c6 06 75 ff 15 80 4c 03 80 8b 5c 09 8a 44 0b 08 07 c3"
    )
    inventory_draw = bytes.fromhex(
        "f6 06 99 00 ff 74 28 bb 75 3a b0 01 2e ff 16 3a 20 "
        "bb f8 00 b1 7e b0 5e b4 01 2e ff 16 22 20 a0 99 00 "
        "32 e4 b9 01 00 b3 01 ba 7e 40"
    )

    checks = {
        "save_field_0099": len(stdply) > 0x99 and stdply[0x99] == 0,
        "absor_hidden_slab_object":
            (struct.unpack_from("<H", lion_object)[0], lion_object[2],
             lion_object[4], lion_object[6], lion_object[7], lion_object[9],
             struct.unpack_from("<H", lion_object, 11)[0], lion_object[13]) ==
            (150, 7, 119, 0, 0x20, 0, 0x42, 0x08),
        "acquisition_message_and_increment":
            fight.count(b"Get the lion\\s head Key.") == 1 and
            fight.count(acquisition) == 1,
        "inventory_uses_distinct_0099_count": select.count(inventory_draw) == 1,
        "unlock_consumes_once_and_persists": fight.count(lion_unlock) == 1,
        "tesoro_keyed_arrugia_door": bytes.fromhex(
            "1f000543103e000d012b0010") in tesoro_doors,
        "arrugia_free_reverse_door": bytes.fromhex(
            "3e000d830e1f000500ffffff") in arrugia_doors,
        "pureza_before_and_after_dialogs":
            b"lion\\s head key but it was stolen" in pureza and
            b"key that was entrusted to me by the Spirits" in pureza,
        "downstream_rewards":
            b"You get the Feruza shoes." in fight and
            b"Get the Enchantment sword." in fight,
    }
    for name, passed in checks.items():
        print(f"lion_key:{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(checks.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release MASM defines the Absor hidden-slab reward, distinct "
          "0099h key count, inventory display, one-time Tesoro unlock, "
          "persistent 002Bh/10h door, free Arrugia return, and rewards")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
