#!/usr/bin/env python3
"""Direct MASM oracle for stick.asm:swap_overlay_blocks.

The loader-side routine enters stick.asm:swap_overlay_blocks at runtime CS:0C01h.  It
exchanges 0x7000 bytes between CS:3000h and (CS+2000h):9000h, then tail-jumps
through CS:[BX].  This isolates that memory service from DOS file I/O and
records the real release-byte result used by the C runtime parity test.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_BX,
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


STICK_BIN = MASM_ROOT / "bin" / "stick.bin"
CODE_SEG = 0x1000
HIGH_SEG = CODE_SEG + 0x2000
STACK_SEG = 0x5000
STICK_LOAD_BASE = 0x0100
ENTRY_SWAP_OVERLAY = 0x0C01
RET_SENTINEL = 0x0080
LOW_OFFSET = 0x3000
HIGH_OFFSET = 0x9000
SWAP_BYTES = 0x7000
EXPECTED_LOW_FNV = 0x76D5A1593E8D4325
EXPECTED_HIGH_FNV = 0xF4BBE72FACF04325


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, HIGH_SEG, STACK_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + STICK_LOAD_BASE, STICK_BIN.read_bytes())

    low = bytes((index * 13 + 7) & 0xFF for index in range(SWAP_BYTES))
    high = bytes((index * 37 + 11) & 0xFF for index in range(SWAP_BYTES))
    mu.mem_write((CODE_SEG << 4) + LOW_OFFSET, low)
    mu.mem_write((HIGH_SEG << 4) + HIGH_OFFSET, high)
    mu.mem_write((CODE_SEG << 4) + 0x70,
                 bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]))

    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_SP, 0xFFFE)
    mu.reg_write(UC_X86_REG_BX, 0x70)

    def stop_at_tail_target(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_at_tail_target)
    mu.emu_start((CODE_SEG << 4) + ENTRY_SWAP_OVERLAY,
                 (CODE_SEG << 4) + 0xFFFF)

    low_after = bytes(mu.mem_read((CODE_SEG << 4) + LOW_OFFSET, SWAP_BYTES))
    high_after = bytes(mu.mem_read((HIGH_SEG << 4) + HIGH_OFFSET, SWAP_BYTES))
    low_fnv = fnv1a64(low_after)
    high_fnv = fnv1a64(high_after)
    ok = (low_fnv == EXPECTED_LOW_FNV and high_fnv == EXPECTED_HIGH_FNV and
          mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL)
    print("stick_overlay_swap_blocks: " + ("PASS" if ok else "FAIL") +
          f" low={low_fnv:016x} high={high_fnv:016x} "
          f"ip={mu.reg_read(UC_X86_REG_IP):04x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": stick overlay swap matches MASM bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
