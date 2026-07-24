#!/usr/bin/env python3
"""Direct release-byte oracle for 105GDMCA:37B4 disp_tile_render."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX,
    UC_X86_REG_DI, UC_X86_REG_DS, UC_X86_REG_DX, UC_X86_REG_ES,
    UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
CODE_SEG, HIGH_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x3000, 0x5000, 0xA000
GDMCA_LOAD_BASE, HEADER_SIZE = 0x3000, 4
ENTRY, RET_SENTINEL = 0x37B4, 0x0080
OFF_GAME_SEG, SCRATCH_OFF, SCRATCH_SIZE = 0xFF2C, 0x5191, 0x44
EXPECTED_SCRATCH_FNV = 0xC6CB27A7C8FA9A48
EXPECTED_VGA_FNV = 0x2E48564BCD87489A
EXPECTED_VISIBLE_FNV = 0x7D858614A475149A


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value = ((value ^ byte) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, HIGH_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + GDMCA_LOAD_BASE - HEADER_SIZE,
                 GDMCA_BIN.read_bytes())
    mu.mem_write(HIGH_SEG << 4,
                 bytes((index * 17 + 29) & 0xFF for index in range(0x10000)))
    mu.mem_write(VGA_SEG << 4,
                 bytes((index * 37 + 11) & 0xFF for index in range(0x10000)))
    mu.mem_write((CODE_SEG << 4) + OFF_GAME_SEG,
                 bytes((CODE_SEG & 0xFF, CODE_SEG >> 8)))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, 0x00C7)):
        mu.reg_write(reg, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC, b"\x80\x00")

    def stop_on_return(uc, _address, _size, _user):
        if (uc.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)

    scratch = bytes(mu.mem_read((CODE_SEG << 4) + SCRATCH_OFF, SCRATCH_SIZE))
    vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    regs_ok = (
        mu.reg_read(UC_X86_REG_AX) & 0xFFFF == 0x000E and
        mu.reg_read(UC_X86_REG_BX) & 0xFFFF == 0xD834 and
        mu.reg_read(UC_X86_REG_CX) & 0xFFFF == 0 and
        mu.reg_read(UC_X86_REG_DX) & 0xFFFF == 0xD8FF and
        mu.reg_read(UC_X86_REG_SI) & 0xFFFF == 0x51B3 and
        mu.reg_read(UC_X86_REG_DI) & 0xFFFF == 0xF970 and
        mu.reg_read(UC_X86_REG_DS) & 0xFFFF == CODE_SEG and
        mu.reg_read(UC_X86_REG_ES) & 0xFFFF == VGA_SEG
    )
    ok = (fnv1a64(scratch) == EXPECTED_SCRATCH_FNV and
          fnv1a64(vga) == EXPECTED_VGA_FNV and
          fnv1a64(vga[:64000]) == EXPECTED_VISIBLE_FNV and regs_ok and
          (mu.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET_SENTINEL)
    print("mcga_disp_tile_render: " + ("PASS" if ok else "FAIL") +
          f" scratch={fnv1a64(scratch):016x} vga={fnv1a64(vga):016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": 105GDMCA CS:37B4 matches release bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
