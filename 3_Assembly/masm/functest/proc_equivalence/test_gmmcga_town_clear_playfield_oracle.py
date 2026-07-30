#!/usr/bin/env python3
"""Release-MASM oracle for the town playfield clear at GMMCGA:2106."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP,
    UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

BIN = MASM_ROOT / "bin" / "gmmcga.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x5000, 0xA000
ENTRY, RET_SENTINEL = 0x2106, 0x0080
EXPECTED_VGA_FNV = 0xDBAAD528760DFB25
EXPECTED_FRAMEBUFFER_FNV = 0x4B4535E7677CB325


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE_SEG << 4) + 0x2000, BIN.read_bytes())
    mu.mem_write(VGA_SEG << 4,
                 bytes((index * 29 + 7) & 0xFF for index in range(0x10000)))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_SP, 0xFFFC)):
        mu.reg_write(reg, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)
    vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    full_hash = fnv1a64(vga)
    framebuffer_hash = fnv1a64(vga[:320 * 200])
    ok = (mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL and
          full_hash == EXPECTED_VGA_FNV and
          framebuffer_hash == EXPECTED_FRAMEBUFFER_FNV)
    print(f"gmmcga_town_clear_playfield: {'PASS' if ok else 'FAIL'} "
          f"framebuffer={framebuffer_hash:016x} vga={full_hash:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GMMCGA:2106 town playfield clear")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
