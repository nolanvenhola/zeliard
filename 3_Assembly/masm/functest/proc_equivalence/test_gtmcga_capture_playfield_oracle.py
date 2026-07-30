#!/usr/bin/env python3
"""Release-MASM oracle for GTMCGA:3028 playfield capture."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS, UC_X86_REG_CX, UC_X86_REG_DI, UC_X86_REG_DS,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

BIN = MASM_ROOT / "working" / "zelres1" / "code" / "111GTMCA.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x8000, 0xA000
ENTRY, RET_SENTINEL = 0x3028, 0x0080
EXPECTED_BLOCK_FNV = 0xE6CF3F9146BCEB25
EXPECTED_GAME_FNV = 0x52BC8A8499A1A83D


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    mu.mem_write(CODE_SEG << 4,
                 bytes((index * 29 + 7) & 0xFF for index in range(0x10000)))
    chunk = BIN.read_bytes()
    mu.mem_write((CODE_SEG << 4) + 0x3000, chunk[4:])
    mu.mem_write(VGA_SEG << 4,
                 bytes((index * 17 + 3) & 0xFF for index in range(0x10000)))
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
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0, count=1_000_000)
    game = bytes(mu.mem_read(CODE_SEG << 4, 0x10000))
    registers = (
        mu.reg_read(UC_X86_REG_DS), mu.reg_read(UC_X86_REG_ES),
        mu.reg_read(UC_X86_REG_SI), mu.reg_read(UC_X86_REG_DI),
        mu.reg_read(UC_X86_REG_CX),
    )
    hashes = fnv1a64(game[0xA000:0xB500]), fnv1a64(game)
    ok = (mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL and
          registers == (CODE_SEG, CODE_SEG, 0x6290, 0xB500, 0) and
          hashes == (EXPECTED_BLOCK_FNV, EXPECTED_GAME_FNV))
    print(f"gtmcga_capture_playfield: {'PASS' if ok else 'FAIL'} "
          f"block={hashes[0]:016x} game={hashes[1]:016x} "
          f"regs={registers}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GTMCGA:3028 playfield capture")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
