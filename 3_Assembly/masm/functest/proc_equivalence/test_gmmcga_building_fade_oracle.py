#!/usr/bin/env python3
"""Release-MASM oracle for the GMMCGA:2130 building fade to black."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS, UC_X86_REG_CX, UC_X86_REG_DS, UC_X86_REG_ES,
    UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

BIN = MASM_ROOT / "bin" / "gmmcga.bin"
if not BIN.exists():
    BIN = MASM_ROOT / "working" / "drivers" / "gmmcga.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x5000, 0xA000
ENTRY, PASS_CHECKPOINT, RET_SENTINEL = 0x2130, 0x2187, 0x0080
EXPECTED_PASSES = (
    0x72AEEC8CE08F84E5, 0x5EFAA6927F6A62E5,
    0x07D8F5540EA329C5, 0x977857E682AAD705,
    0xDAEABA86ED6BA7E5, 0x146EB61A440439A5,
    0xC54918C143A086A5, 0x4B4535E7677CB325,
)
EXPECTED_FINAL_VGA = 0xDBAAD528760DFB25


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

    pass_hashes = []

    def trace(uc, _address, _size, _user):
        ip = uc.reg_read(UC_X86_REG_IP)
        if ip == PASS_CHECKPOINT and uc.reg_read(UC_X86_REG_CX) == 0x1F40:
            frame = bytes(uc.mem_read(VGA_SEG << 4, 320 * 200))
            pass_hashes.append(fnv1a64(frame))
        elif ip == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, trace)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)
    final_vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    print("gmmcga_building_fade: passes=" +
          ",".join(f"{value:016x}" for value in pass_hashes) +
          f" final={fnv1a64(final_vga):016x}")
    ok = (tuple(pass_hashes) == EXPECTED_PASSES and
          fnv1a64(final_vga) == EXPECTED_FINAL_VGA and
          mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL)
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GMMCGA:2130 building fade")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
