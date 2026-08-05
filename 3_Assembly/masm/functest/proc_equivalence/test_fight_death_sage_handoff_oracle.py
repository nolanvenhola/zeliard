#!/usr/bin/env python3
"""Release-MASM oracle for 200FIGHT's post-death sage handoff.

The game-over tail restores HP from player_hp_max, copies stat_XC5 (the last
sage destination) into current_area_id, and invokes the resident loader with
AL=1/AH=destination.  The web port must redraw that town and enter its sage
program instead of resuming the cavern-mutated outdoor framebuffer.
"""

from __future__ import annotations

import struct
import sys
from pathlib import Path

from unicorn import (UC_ARCH_X86, UC_HOOK_CODE, UC_HOOK_INTR, UC_MODE_16,
                     UC_PROT_ALL, Uc)
from unicorn.x86_const import (
    UC_X86_REG_AX,
    UC_X86_REG_BX,
    UC_X86_REG_CS,
    UC_X86_REG_DS,
    UC_X86_REG_IP,
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
ENTRY_SETUP_NEXT_LEVEL = 0x99D8
ENTRY_LEVEL_START = 0x7D85
LOADER_SLOT = 0x010C
LOADER_STUB = 0x5000
WIPE_CONTRACT = bytes.fromhex(
    "c60624ff08"          # mov byte ptr [FF24],8 (fade interval/mode)
    "b91e00"              # mov cx,30 wipe passes
    "51e804d659"          # push cx; call update frame; pop cx
    "8ac12401fec8"        # alternating redraw-lock value from CL
    "a237ff"              # mov [FF37],al
    "e2f0"                # loop fade_step_loop
    "b80100cd60"          # INT 60h AX=1 boundary
    "2eff164020"          # call [2040] = drv_fade_to_black
)


def run_muralla_level_start() -> dict[str, int | bool]:
    """Run release 200FIGHT's coordinate calculation on release MRMP."""
    image = BIN.read_bytes()
    mrmp_file = MASM_ROOT / "bin" / "zelres2" / "237MRMP.mdt"
    mrmp = mrmp_file.read_bytes()
    declared = int.from_bytes(mrmp[:4], "little")
    descriptor = mrmp[4:4 + declared]

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    segment = CODE_SEG << 4
    mu.mem_write(segment + LOAD_BASE, image[4:])
    mu.mem_write(segment + 0xC000, descriptor)
    mu.mem_write(segment + LOADER_SLOT, struct.pack("<H", LOADER_STUB))
    mu.mem_write(segment + 0x0082, b"\x0e")
    target = struct.unpack("<H", descriptor[0x13:0x15])[0]
    mu.mem_write(segment + 0x9F1A, struct.pack("<H", target))

    for reg, value in (
        (UC_X86_REG_CS, CODE_SEG),
        (UC_X86_REG_DS, CODE_SEG),
        (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFFE),
        (UC_X86_REG_BX, 0x6002),
        (UC_X86_REG_IP, ENTRY_LEVEL_START),
    ):
        mu.reg_write(reg, value)

    reached_loader = False

    def stop_at_loader(uc, address, _size, _user):
        nonlocal reached_loader
        if address == segment + LOADER_STUB:
            reached_loader = True
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_at_loader)
    mu.hook_add(UC_HOOK_INTR, lambda _uc, _intno, _user: None)
    mu.emu_start(segment + ENTRY_LEVEL_START, 0, count=100)
    start = struct.unpack("<H", mu.mem_read(segment + 0x0080, 2))[0]
    screen = mu.mem_read(segment + 0x0083, 1)[0]
    return {
        "reached_loader": reached_loader,
        "map_width": struct.unpack("<H", descriptor[2:4])[0],
        "target": target,
        "start": start,
        "map_scroll_row": mu.mem_read(segment + 0x0082, 1)[0],
        "screen": screen,
        "world_position": start + screen + 4,
    }


def run_case(last_sage: int) -> dict[str, int | bool]:
    image = BIN.read_bytes()
    assert image[:4] == b"\x2e\x3f\x00\x00"
    # Anchor the entry to the release bytes: mov ax,[00B2]; mov [0090],ax.
    assert image[0x39DC:0x39E2] == b"\xA1\xB2\x00\xA3\x90\x00"

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    segment = CODE_SEG << 4
    mu.mem_write(segment + LOAD_BASE, image[4:])
    mu.mem_write(segment + LOADER_SLOT, struct.pack("<H", LOADER_STUB))
    mu.mem_write(segment + 0x0090, struct.pack("<H", 1))
    mu.mem_write(segment + 0x00B2, struct.pack("<H", 0x3456))
    mu.mem_write(segment + 0x00C4, b"\x00")
    mu.mem_write(segment + 0x00C5, bytes((last_sage,)))

    for reg, value in (
        (UC_X86_REG_CS, CODE_SEG),
        (UC_X86_REG_DS, CODE_SEG),
        (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFFE),
        (UC_X86_REG_IP, ENTRY_SETUP_NEXT_LEVEL),
    ):
        mu.reg_write(reg, value)

    reached_loader = False

    def stop_at_loader(uc, address, _size, _user):
        nonlocal reached_loader
        if address == segment + LOADER_STUB:
            reached_loader = True
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_at_loader)
    mu.emu_start(segment + ENTRY_SETUP_NEXT_LEVEL, 0, count=40)
    ax = mu.reg_read(UC_X86_REG_AX)
    return {
        "reached_loader": reached_loader,
        "hp": struct.unpack("<H", mu.mem_read(segment + 0x0090, 2))[0],
        "area": mu.mem_read(segment + 0x00C4, 1)[0],
        "al": ax & 0xFF,
        "ah": (ax >> 8) & 0xFF,
    }


def main() -> int:
    ok = True
    image = BIN.read_bytes()
    wipe_count = image.count(WIPE_CONTRACT)
    wipe_ok = wipe_count == 1
    ok &= wipe_ok
    print("fight_death_sage_handoff:fade_wipe: "
          f"{'PASS' if wipe_ok else 'FAIL'} passes=30 interval=8 "
          f"release_matches={wipe_count}")
    level_start = run_muralla_level_start()
    expected_level_start = {
        "reached_loader": True,
        "map_width": 0x00D7,
        "target": 0x00AC,
        "start": 0x009B,
        "map_scroll_row": 0x0E,
        "screen": 0x0D,
        "world_position": 0x00AC,
    }
    level_start_ok = level_start == expected_level_start
    ok &= level_start_ok
    print("fight_death_sage_handoff:muralla_level_start: "
          f"{'PASS' if level_start_ok else 'FAIL'} {level_start}")
    for name, last_sage in (("muralla_sage", 0x81),
                            ("captured_fallback", 0x80)):
        actual = run_case(last_sage)
        expected = {
            "reached_loader": True,
            "hp": 0x3456,
            "area": last_sage,
            "al": 1,
            "ah": last_sage,
        }
        case_ok = actual == expected
        ok &= case_ok
        print(f"fight_death_sage_handoff:{name}: "
              f"{'PASS' if case_ok else 'FAIL'} {actual}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM death restores HP and selects the last sage")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
