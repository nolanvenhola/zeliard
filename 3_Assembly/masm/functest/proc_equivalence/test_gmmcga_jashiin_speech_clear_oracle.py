#!/usr/bin/env python3
"""Release-MASM oracle for GMMCGA:2046 AL=0 speech-field clear."""

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
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x5000, 0xA000
ENTRY, RET_SENTINEL = 0x2046, 0x0080
EXPECTED_FNV = 0x9A550041FF6558A5
EXPECTED_KING_PROMPT_FNV = 0x18ADDA5D7FCDF1E5


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def run(bx: int, cx: int) -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE_SEG << 4) + 0x2000, BIN.read_bytes())
    mu.mem_write(VGA_SEG << 4, bytes((index * 17 + 3) & 0xFF
                                     for index in range(0x10000)))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, 0),
                       (UC_X86_REG_BX, bx), (UC_X86_REG_CX, cx)):
        mu.reg_write(reg, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)
    assert mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL
    return fnv1a64(bytes(mu.mem_read(VGA_SEG << 4, 0x10000)))


def main() -> int:
    actual = run(0x0094, 0x501E)
    king_prompt = run(0x278B, 0x020A)
    speech_ok = actual == EXPECTED_FNV
    prompt_ok = king_prompt == EXPECTED_KING_PROMPT_FNV
    ok = speech_ok and prompt_ok
    print(f"gmmcga_jashiin_speech_clear: {'PASS' if speech_ok else 'FAIL'} "
          f"vga={actual:016x}")
    print(f"gmmcga_king_prompt_clear: {'PASS' if prompt_ok else 'FAIL'} "
          f"vga={king_prompt:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GMMCGA 2046 AL=0 speech-field clear")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
