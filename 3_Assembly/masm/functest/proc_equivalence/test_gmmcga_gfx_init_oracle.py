#!/usr/bin/env python3
"""Direct MASM oracle for the MCGA gfx_init_fn target at CS:2C01h."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS,
    UC_X86_REG_DS,
    UC_X86_REG_ES,
    UC_X86_REG_IP,
    UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT  # noqa: E402


GMMCGA_BIN = MASM_ROOT / "bin" / "gmmcga.bin"
CODE_SEG = 0x1000
STACK_SEG = 0x5000
VGA_SEG = 0xA000
DRIVER_LOAD_BASE = 0x2000
ENTRY_GFX_INIT = 0x2C01
RET_SENTINEL = 0x0080
FRAMEBUFFER_BYTES = 320 * 200
EXPECTED_FRAMEBUFFER_FNV = 0xDD14FCC6528CAB25
EXPECTED_VGA_FNV = 0xA87A818896F01F25


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
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    # GMMCGA is a raw driver image; byte zero is its dispatch table.
    mu.mem_write((CODE_SEG << 4) + DRIVER_LOAD_BASE, GMMCGA_BIN.read_bytes())
    mu.mem_write(VGA_SEG << 4,
                 bytes((index * 37 + 11) & 0xFF for index in range(0x10000)))

    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]))

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY_GFX_INIT,
                 (CODE_SEG << 4) + 0xFFFF)

    vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    framebuffer_fnv = fnv1a64(vga[:FRAMEBUFFER_BYTES])
    vga_fnv = fnv1a64(vga)
    ok = (framebuffer_fnv == EXPECTED_FRAMEBUFFER_FNV and
          vga_fnv == EXPECTED_VGA_FNV and
          mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL)
    print("gmmcga_gfx_init: " + ("PASS" if ok else "FAIL") +
          f" framebuffer={framebuffer_fnv:016x} vga={vga_fnv:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": gmmcga gfx_init matches MASM bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
