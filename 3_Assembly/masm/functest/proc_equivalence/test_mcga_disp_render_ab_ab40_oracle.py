#!/usr/bin/env python3
"""Direct release-byte oracle for 105GDMCA:364F disp_render_ab_ab40."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES,
    UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402


GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
CODE_SEG, GAME_SEG, WORK_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x3000, 0x4000, 0x5000, 0xA000
GDMCA_LOAD_BASE, ENTRY, RET_SENTINEL = 0x2FFC, 0x364F, 0x0080
GVAR_GAME_SEG, PAGE_BASE, PAGE_SIZE = 0xFF2C, 0xAB40, 0x0CC0
EXPECTED = [
    (0x7A54E6F497D6E940, 0xDC34BD70D74EF260),
    (0x049B72555A9F1598, 0x1B7024E43DADFE28),
    (0x1F645FFBCC732120, 0x502D12C6680EBD80),
    (0x9582ADE0B3C3EDD8, 0x3AB55AAD4C798D48),
    (0x7A54E6F497D6E940, 0xDC34BD70D74EF260),
]
EXPECTED_OPENING_BX1720 = [
    (0x1F645FFBCC732120, 0x3EC8FB9DAE26AA6C),
    (0x9582ADE0B3C3EDD8, 0x8C57CCF6305FA3A4),
]


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def run_page(page: int, bx: int = 0) -> tuple[int, int]:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, GAME_SEG, WORK_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE_SEG << 4) + GDMCA_LOAD_BASE, GDMCA_BIN.read_bytes())
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * GDMCA_LOAD_BASE)
    mu.mem_write((CODE_SEG << 4) + GVAR_GAME_SEG,
                 bytes((GAME_SEG & 0xFF, GAME_SEG >> 8)))
    game = bytearray(0x10000)
    for i in range(PAGE_SIZE * 5):
        game[PAGE_BASE + i] = (i * 29 + 0x53) & 0xFF
    mu.mem_write(GAME_SEG << 4, bytes(game))
    mu.mem_write(VGA_SEG << 4, bytes((i * 13 + 0x31) & 0xFF for i in range(0x10000)))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, GAME_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, page),
                       (UC_X86_REG_BX, bx)):
        mu.reg_write(reg, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)
    assert mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL
    return (fnv1a64(bytes(mu.mem_read(WORK_SEG << 4, 0x10000))),
            fnv1a64(bytes(mu.mem_read(VGA_SEG << 4, 0x10000))))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--capture", action="store_true")
    args = parser.parse_args()
    actual = [run_page(page) for page in range(5)]
    opening_actual = [run_page(page, 0x1720) for page in (2, 3)]
    if args.capture:
        for page, (work, vga) in enumerate(actual):
            print(f"({work:#018x}, {vga:#018x}),  # page {page}")
        for page, (work, vga) in zip((2, 3), opening_actual):
            print(f"({work:#018x}, {vga:#018x}),  # page {page}, BX=1720")
        return 0
    ok = actual == EXPECTED and opening_actual == EXPECTED_OPENING_BX1720
    for page, (work, vga) in enumerate(actual):
        expected = EXPECTED[page] if page < len(EXPECTED) else (0, 0)
        print(f"mcga_disp_render_ab_ab40 page={page}: "
           f"{'PASS' if (work, vga) == expected else 'FAIL'} "
           f"work={work:016x} vga={vga:016x}")
    for page, (work, vga), expected in zip(
            (2, 3), opening_actual, EXPECTED_OPENING_BX1720):
        print(f"mcga_disp_render_ab_ab40 page={page} bx=1720: "
              f"{'PASS' if (work, vga) == expected else 'FAIL'} "
              f"work={work:016x} vga={vga:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM 364F page renderer")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
