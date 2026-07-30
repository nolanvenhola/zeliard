#!/usr/bin/env python3
"""Release-MASM oracle for GMMCGA:22CD structured town HUD text."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP,
    UC_X86_REG_SI, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

BIN = MASM_ROOT / "working" / "drivers" / "gmmcga.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x8000, 0xA000
ENTRY, RET_SENTINEL = 0x22CD, 0x0080
EXPECTED_VGA_FNV = 0x9ECCC715238D7787
EXPECTED_RECORD_FNV = 0x084A7707B4FFE4EB


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
    mu.mem_write((CODE_SEG << 4) + 0xF504, bytes((0x00, 0x80)))
    glyphs = bytearray(96 * 8)
    for char_index in range(96):
        for row in range(8):
            glyphs[char_index * 8 + row] = (
                char_index * 37 + row * 19 + 0x53) & 0xFF
    mu.mem_write((CODE_SEG << 4) + 0x8000, bytes(glyphs))
    record = bytes((0x0E, 0xA3, 0x00, 0x05)) + b"LIFE!"
    mu.mem_write((CODE_SEG << 4) + 0x9000, record)
    mu.mem_write(VGA_SEG << 4,
                 bytes((index * 11 + 9) & 0xFF for index in range(0x10000)))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_SI, 0x9000)):
        mu.reg_write(reg, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0, count=1_000_000)
    assert mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL
    vga_hash = fnv1a64(bytes(mu.mem_read(VGA_SEG << 4, 0x10000)))
    memory = bytes(mu.mem_read((CODE_SEG << 4) + 0x2CBD, 2))
    memory_hash = fnv1a64(memory)
    ok = (vga_hash, memory_hash) == (EXPECTED_VGA_FNV, EXPECTED_RECORD_FNV)
    print(f"gmmcga_town_text_record: {'PASS' if ok else 'FAIL'} "
          f"vga={vga_hash:016x} state={memory.hex()}:{memory_hash:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GMMCGA:22CD town text record")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
