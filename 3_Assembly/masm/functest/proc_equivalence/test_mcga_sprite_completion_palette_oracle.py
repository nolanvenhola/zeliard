#!/usr/bin/env python3
"""Prove the released 105GDMCA sprite proc restores palette AX=2.

The fixture executes scene_sprite_a through every 1Eh frame wait.  It stops
after the final ``mov ax,2`` and verifies that all nine object records are
inactive, making this the MASM contract for the NEC/HOU -> DMAOU handoff.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_HOOK_INSN, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_INS_IN, UC_X86_INS_OUT, UC_X86_REG_AX, UC_X86_REG_CS,
    UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI,
    UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402


GDMCA = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
OPDMO = MASM_ROOT / "bin" / "zelres1" / "100OPDMO.bin"
CODE, WORK, STACK, VGA = 0x1000, 0x4000, 0x5000, 0xA000
GDMCA_LOAD_BASE, OPDMO_LOAD_BASE = 0x2FFC, 0x6000
ENTRY, FRAME_WAIT, PALETTE_2_READY = 0x3437, 0x3544, 0x3593
SCENE_SPRITE_A, OBJECT_TABLE = 0x9060, 0xA000


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for base in (0, CODE << 4, WORK << 4, STACK << 4, VGA << 4):
        mu.mem_map(base, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE << 4) + GDMCA_LOAD_BASE, GDMCA.read_bytes())
    mu.mem_write((CODE << 4) + OPDMO_LOAD_BASE, OPDMO.read_bytes()[4:])
    mu.mem_write((0x40 << 4) + 0x63, bytes((0xD4, 0x03)))
    mu.mem_write((CODE << 4) + 0xFF2C, bytes((CODE & 0xFF, CODE >> 8)))

    for reg, value in (
        (UC_X86_REG_CS, CODE), (UC_X86_REG_DS, CODE),
        (UC_X86_REG_ES, CODE), (UC_X86_REG_SS, STACK),
        (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_SI, SCENE_SPRITE_A),
    ):
        mu.reg_write(reg, value)

    waits = 0

    def hook_code(uc, _address, _size, _user):
        nonlocal waits
        ip = uc.reg_read(UC_X86_REG_IP)
        if ip == FRAME_WAIT:
            waits += 1
            uc.mem_write((CODE << 4) + 0xFF1A, b"\x1e")
        elif ip == PALETTE_2_READY:
            uc.emu_stop()

    def hook_in(_uc, _port, _size, _user):
        return 0

    def hook_out(_uc, _port, _size, _value, _user):
        return None

    mu.hook_add(UC_HOOK_CODE, hook_code)
    mu.hook_add(UC_HOOK_INSN, hook_in, None, 1, 0, UC_X86_INS_IN)
    mu.hook_add(UC_HOOK_INSN, hook_out, None, 1, 0, UC_X86_INS_OUT)

    try:
        mu.emu_start((CODE << 4) + ENTRY, 0, count=20_000_000)
    except Exception as exc:
        print(f"mcga_sprite_completion_palette: FAIL error={exc}")
        print("VERDICT: FAIL: released sprite completion did not execute")
        return 1

    records = bytes(mu.mem_read((CODE << 4) + OBJECT_TABLE, 9 * 15))
    active = [records[index * 15] for index in range(9)]
    ax = mu.reg_read(UC_X86_REG_AX)
    ip = mu.reg_read(UC_X86_REG_IP)
    ok = waits == 12 and ip == PALETTE_2_READY and ax == 2 and not any(active)
    print("mcga_sprite_completion_palette: " + ("PASS" if ok else "FAIL") +
          f" waits={waits} ip={ip:04x} ax={ax:04x} active={active}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": released sprite completion restores AX=2")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
