#!/usr/bin/env python3
"""Direct release-byte oracle for 105GDMCA dispatch target CS:3707h."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP,
    UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x5000, 0xA000
GDMCA_LOAD_BASE, HEADER_SIZE = 0x3000, 4
ENTRY, RET_SENTINEL = 0x3707, 0x0080
VISIBLE_BYTES = 320 * 200
EXPECTED_VISIBLE_FNV = 0x10C1DBF72FB2AB25
EXPECTED_VGA_FNV = 0x65718FD904161F25


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value = ((value ^ byte) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + GDMCA_LOAD_BASE - HEADER_SIZE,
                 GDMCA_BIN.read_bytes())
    mu.mem_write(VGA_SEG << 4,
                 bytes((index * 37 + 11) & 0xFF for index in range(0x10000)))
    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC, b"\x80\x00")

    def stop_on_return(uc, _address, _size, _user):
        if (uc.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)
    vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    visible = fnv1a64(vga[:VISIBLE_BYTES])
    full = fnv1a64(vga)
    ok = (visible == EXPECTED_VISIBLE_FNV and full == EXPECTED_VGA_FNV and
          vga[:4] == bytes((0, 0x10, 0, 0x10)) and
          vga[320:324] == bytes((0x10, 0, 0x10, 0)) and
          (mu.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET_SENTINEL)
    print("mcga_disp_drv_seg_3: " + ("PASS" if ok else "FAIL") +
          f" visible={visible:016x} full={full:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": 105GDMCA CS:3707 matches release bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
