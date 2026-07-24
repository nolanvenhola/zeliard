#!/usr/bin/env python3
"""Direct release-byte oracle for 105GDMCA:3732 disp_tilemap_render."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES,
                               UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP,
                               UC_X86_REG_SS)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
CODE_SEG, HIGH_SEG, STACK_SEG = 0x1000, 0x3000, 0x5000
ENTRY, RET_SENTINEL, TABLE = 0x3732, 0x0080, 0x912B
EXPECTED_WORK_FNV = 0x46103A7E1CD5E485


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value = ((value ^ byte) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, HIGH_SEG, STACK_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE_SEG << 4) + 0x2FFC, GDMCA_BIN.read_bytes())
    # The driver is already resident before 100OPDMO decodes ttl1 into
    # game:4000h and supplies its scene_sprite_d tile table at 912Bh.
    mu.mem_write((CODE_SEG << 4) + 0x4000,
                 bytes((index * 17 + 29) & 0xFF for index in range(0xC000)))
    mu.mem_write((CODE_SEG << 4) + TABLE,
                 bytes((index * 37 + 11) & 0xFF for index in range(0x19 * 0x22)))
    mu.mem_write((CODE_SEG << 4) + 0xFF2C,
                 bytes((CODE_SEG & 0xFF, CODE_SEG >> 8)))
    mu.mem_write(HIGH_SEG << 4, bytes((index * 7 + 3) & 0xFF
                                       for index in range(0x10000)))
    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.reg_write(UC_X86_REG_SI, TABLE)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC, b"\x80\x00")

    def stop_on_return(uc, _address, _size, _user):
        if (uc.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)
    work = bytes(mu.mem_read(HIGH_SEG << 4, 0x10000))
    actual = fnv1a64(work)
    ok = actual == EXPECTED_WORK_FNV and (mu.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET_SENTINEL
    print(f"mcga_disp_tilemap_render: {'PASS' if ok else 'FAIL'} work={actual:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": 105GDMCA CS:3732 matches release bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
