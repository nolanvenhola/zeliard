#!/usr/bin/env python3
"""Release-MASM oracle for GAME:A3A6 + GMMCGA:2A1C tear HUD rendering."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CS,
                               UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP,
                               UC_X86_REG_SP, UC_X86_REG_SS)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

BIN = MASM_ROOT / "working" / "drivers" / "gmmcga.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x8000, 0xA000
RET_SENTINEL = 0x0080
COORDS = (0x0F00, 0x3D00, 0x1500, 0x3700, 0x1B00,
          0x3100, 0x2100, 0x2B00, 0x2600)
EXPECTED = {2: 0x78CE592EA8B5637D, 9: 0xED19D671A07BBED3}


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def render(count: int) -> int:
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
    for index, bx in enumerate(COORDS[:count]):
        mu.reg_write(UC_X86_REG_SP, 0xFFFC)
        mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                     bytes((RET_SENTINEL, 0)))
        mu.reg_write(UC_X86_REG_AX, 1 if index == 8 else 0)
        mu.reg_write(UC_X86_REG_BX, bx)
        mu.emu_start((CODE_SEG << 4) + 0x2A1C, 0, count=100_000)
        assert mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL
    return fnv1a64(bytes(mu.mem_read(VGA_SEG << 4, 0x10000)))


def main() -> int:
    actual = {count: render(count) for count in EXPECTED}
    ok = actual == EXPECTED
    print("gmmcga_collected_tears: " + ("PASS" if ok else "FAIL") + " " +
          " ".join(f"count{count}={value:016x}"
                   for count, value in actual.items()))
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM collected Tear HUD order and sprites")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
