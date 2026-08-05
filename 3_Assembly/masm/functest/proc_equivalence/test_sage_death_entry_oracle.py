#!/usr/bin/env python3
"""Release-byte oracle for 217KENJP's distinct death and door entries."""

from pathlib import Path

HERE = Path(__file__).resolve().parent
MASM_ROOT = HERE.parents[1]
BIN = MASM_ROOT / "bin" / "zelres2" / "217KENJP.bin"


def main() -> int:
    image = BIN.read_bytes()
    ok = image[:4] == b"\x3d\x1b\x00\x00"
    payload = image[4:]

    # A000 is a dispatch table: normal=A027, music/data=AB47, death=A006.
    dispatch_ok = payload[:6] == bytes.fromhex("27a047ab06a0")
    # Death code A006 loads KENJA.GRP and selects centered origin 0E17.
    death_entry = payload[0x06:0x0F]
    death_ok = death_entry == bytes.fromhex("e85100c70612bb170e")
    wake_text = payload[0x1A67:]
    wake_ok = wake_text.startswith(
        b"\x0cWhile you were unconscious, the spirits brought you here./")

    # Ordinary door entry A027 instead loads/draws the sage room and calls
    # sage_intro_dispatch, which eventually leads to the command menu.
    normal_entry = payload[0x27:0x30]
    normal_ok = normal_entry == bytes.fromhex("e83000c70612bb1707")
    ok &= dispatch_ok and death_ok and wake_ok and normal_ok

    print("sage_death_entry:death_A006: " +
          ("PASS" if dispatch_ok and death_ok and wake_ok else "FAIL") +
          " dispatch_slot=A004 origin=0E17 script=BA67 unconscious_text=1")
    print("sage_death_entry:normal_A027: " +
          ("PASS" if normal_ok else "FAIL") +
          " loader_prologue=1")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM sage death entry bypasses the normal menu")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
