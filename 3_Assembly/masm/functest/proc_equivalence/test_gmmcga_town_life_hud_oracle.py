#!/usr/bin/env python3
"""Release-MASM oracle for the GMMCGA town LIFE HUD services."""

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

BIN = MASM_ROOT / "working" / "drivers" / "gmmcga.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x8000, 0xA000
RET_SENTINEL = 0x0080
LIFE_SCALE, LIFE_MAX, LIFE_CURRENT = 0x2385, 0x2227, 0x2256


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def call(mu: Uc, entry: int) -> None:
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))
    mu.emu_start((CODE_SEG << 4) + entry, 0, count=1_000_000)
    assert mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    mu.mem_write((CODE_SEG << 4) + 0x2000, BIN.read_bytes())
    mu.mem_write((CODE_SEG << 4) + 0x0090, bytes((0x45, 0x02)))
    mu.mem_write((CODE_SEG << 4) + 0x00B2, bytes((0x20, 0x03)))
    mu.mem_write(VGA_SEG << 4,
                 bytes((index * 13 + 5) & 0xFF for index in range(0x10000)))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_AX, 0x0500), (UC_X86_REG_BX, 0xBEEF),
                       (UC_X86_REG_CX, 0xCAFE)):
        mu.reg_write(reg, value)

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    call(mu, LIFE_SCALE)
    scale = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    scale_hash = fnv1a64(scale)
    call(mu, LIFE_MAX)
    maximum = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    maximum_hash = fnv1a64(maximum)
    call(mu, LIFE_CURRENT)
    current = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    current_hash = fnv1a64(current)

    expected = (
        0xCC1710A9629B2445,
        0x8922D9FFA5978415,
        0xB98E2BD56673813D,
    )
    actual = (scale_hash, maximum_hash, current_hash)
    ok = actual == expected
    print(f"gmmcga_town_life_hud: {'PASS' if ok else 'FAIL'} "
          f"scale={scale_hash:016x} max={maximum_hash:016x} "
          f"current={current_hash:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GMMCGA town LIFE HUD services")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
