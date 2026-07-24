#!/usr/bin/env python3
"""Release-MASM oracle for GMMCGA:291A streamed narration."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX, UC_X86_REG_DS,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402


BIN = MASM_ROOT / "bin" / "gmmcga.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x5000, 0xA000
LOAD_BASE, ENTRY, RET_SENTINEL = 0x2000, 0x291A, 0x0080
FONT_PTR_A, CINEMATIC_FLAG = 0xF500, 0xFF77
EXPECTED_FNV = 0x82CF53E05B4BA4F3


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def run() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    # GMMCGA is a raw driver image, not a SAR chunk with a size header.
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, BIN.read_bytes())
    mu.mem_write((CODE_SEG << 4) + FONT_PTR_A, bytes((0x00, 0x80)))
    glyph = bytes((0xA5, 0x3C, 0x81, 0x42, 0x18, 0xE7, 0x00, 0x7E))
    for ch in (ord("A"), ord("B"), ord("C")):
        mu.mem_write((CODE_SEG << 4) + 0x8000 + (ch - 0x20) * 8, glyph)
    mu.mem_write((CODE_SEG << 4) + CINEMATIC_FLAG, b"\xff")
    mu.mem_write((CODE_SEG << 4) + 0x9000,
                 bytes((ord("A"), 0x82, ord("B"), 0x0D, ord("C"), 0xFF)))
    mu.mem_write(VGA_SEG << 4, bytes(0x10000))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, VGA_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_SI, 0x9000),
                       (UC_X86_REG_BX, 4), (UC_X86_REG_CX, 0x008F)):
        mu.reg_write(reg, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))

    def hook(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, hook)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)
    assert mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL
    return fnv1a64(bytes(mu.mem_read(VGA_SEG << 4, 0x10000)))


def main() -> int:
    actual = run()
    ok = actual == EXPECTED_FNV
    print(f"gmmcga_narration_stream: {'PASS' if ok else 'FAIL'} vga={actual:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GMMCGA 291A narration stream")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
