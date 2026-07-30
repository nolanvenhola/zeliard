#!/usr/bin/env python3
"""Release-MASM oracle for the three initial GMMCGA:2195 town lines."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX,
    UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

BIN = MASM_ROOT / "bin" / "gmmcga.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x8000, 0xA000
ENTRY, RET_SENTINEL = 0x2195, 0x0080
EXPECTED_VGA_FNV = 0x0F433DB68B152D2A
EXPECTED_FRAMEBUFFER_FNV = 0x4305C733A644D52A


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    mu.mem_write((CODE_SEG << 4) + 0x2000, BIN.read_bytes())
    mu.mem_write(VGA_SEG << 4,
                 bytes((index * 13 + 5) & 0xFF for index in range(0x10000)))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG)):
        mu.reg_write(reg, value)

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    for bx, ch in ((0x0204, 0x21), (0x021C, 0x42), (0x481C, 0x42)):
        mu.reg_write(UC_X86_REG_SP, 0xFFFC)
        mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                     bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))
        mu.reg_write(UC_X86_REG_AX, 0)
        mu.reg_write(UC_X86_REG_BX, bx)
        mu.reg_write(UC_X86_REG_CX, ch << 8)
        mu.emu_start((CODE_SEG << 4) + ENTRY, 0, count=1_000_000)

    vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    hashes = fnv1a64(vga), fnv1a64(vga[:320 * 200])
    ok = hashes == (EXPECTED_VGA_FNV, EXPECTED_FRAMEBUFFER_FNV)
    print(f"gmmcga_town_status_lines: {'PASS' if ok else 'FAIL'} "
          f"vga={hashes[0]:016x} framebuffer={hashes[1]:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GMMCGA:2195 initial town status lines")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
