#!/usr/bin/env python3
"""Release-MASM oracle for 200FIGHT's level/town handoff selector.

The exit-trigger path copies an object target into player byte 00C4h, marks
door targets with bit 7, and calls the resident loader with AL=1.  The web
port uses that observable boundary to distinguish a normal cavern load from
a return to town, so keep the classifier anchored to the release bytes.
"""

from __future__ import annotations

import struct
import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX,
    UC_X86_REG_CS,
    UC_X86_REG_DS,
    UC_X86_REG_IP,
    UC_X86_REG_SI,
    UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402

BUILT_BIN, _ = BIN_PATHS["fight"]
WORKING_BIN = MASM_ROOT / "working" / "zelres2" / "code" / "200FIGHT.bin"
BIN = BUILT_BIN if BUILT_BIN.exists() else WORKING_BIN
CODE_SEG = 0x1000
STACK_SEG = 0x8000
LOAD_BASE = 0x6000
ENTRY_HANDOFF = 0x7B5D
LOADER_SLOT = 0x010C
LOADER_STUB = 0x5000
OBJECT_PTR = 0x4000
# STDPLY 00h..7Fh carries the authored cavern item/stash state masks; the
# ordinary player stats follow at 85h.  Anchor the entire pre-selector record
# so host handoffs cannot silently preserve stats while losing world state.
PERSISTENT_START = 0x0000
PERSISTENT_END = 0x00C2

CASES = (
    ("town_return", 0x01, 0xFF, 0x81),
    ("death_return", 0x00, 0xFF, 0x80),
    ("malicia_to_connector", 0x03, 0x00, 0x03),
    ("connector_to_peligro", 0x02, 0x00, 0x02),
)


def run_case(target: int, door_marker: int) -> dict[str, object]:
    image = BIN.read_bytes()
    assert image[:4] == b"\x2e\x3f\x00\x00"

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    segment = CODE_SEG << 4
    mu.mem_write(segment + LOAD_BASE, image[4:])
    mu.mem_write(segment + LOADER_SLOT, struct.pack("<H", LOADER_STUB))

    persistent = bytes(
        ((offset * 37 + 11) & 0xFF)
        for offset in range(PERSISTENT_START, PERSISTENT_END)
    )
    mu.mem_write(segment + PERSISTENT_START, persistent)
    obj = bytearray(16)
    obj[3] = 0x40
    obj[4] = target
    obj[7] = door_marker
    obj[8] = 0xA5
    mu.mem_write(segment + OBJECT_PTR, bytes(obj))

    for reg, value in (
        (UC_X86_REG_CS, CODE_SEG),
        (UC_X86_REG_DS, CODE_SEG),
        (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFFE),
        (UC_X86_REG_SI, OBJECT_PTR),
        (UC_X86_REG_IP, ENTRY_HANDOFF),
    ):
        mu.reg_write(reg, value)

    reached_loader = False

    def stop_at_loader(uc, address, _size, _user):
        nonlocal reached_loader
        if address == segment + LOADER_STUB:
            reached_loader = True
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_at_loader)
    mu.emu_start(segment + ENTRY_HANDOFF, 0, count=100)

    ax = mu.reg_read(UC_X86_REG_AX)
    return {
        "reached_loader": reached_loader,
        "al": ax & 0xFF,
        "ah": (ax >> 8) & 0xFF,
        "selector": mu.mem_read(segment + 0x00C4, 1)[0],
        "facing": mu.mem_read(segment + 0x00C3, 1)[0],
        "trigger_state": mu.mem_read(segment + 0x9F1D, 1)[0],
        "persistent_unchanged": bytes(mu.mem_read(
            segment + PERSISTENT_START, len(persistent))) == persistent,
    }


def main() -> int:
    ok = True
    for name, target, door_marker, expected_selector in CASES:
        actual = run_case(target, door_marker)
        case_ok = actual == {
            "reached_loader": True,
            "al": 1,
            "ah": expected_selector,
            "selector": expected_selector,
            "facing": 0x40,
            "trigger_state": 0xA5,
            "persistent_unchanged": True,
        }
        ok &= case_ok
        print(f"fight_level_handoff:{name}: "
              f"{'PASS' if case_ok else 'FAIL'} {actual}")

    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM fight handoff selectors and persistent state")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
