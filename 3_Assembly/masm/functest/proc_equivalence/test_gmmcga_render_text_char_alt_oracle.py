#!/usr/bin/env python3
"""Release-MASM oracle for GMMCGA:27E9 render_text_char_alt.

105GDMCA:44DE dispatches here through the base MCGA table at CS:2022 during
OPDMO's char_render_proc. The cinematic flag changes AH selectors 2 and 7
into VGA colors 22h and 77h respectively.
"""

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
LOAD_BASE, ENTRY, RET_SENTINEL = 0x2000, 0x27E9, 0x0080
FONT_PTR_A, CINEMATIC_FLAG = 0xF500, 0xFF77


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def run(selector: int) -> tuple[int, int, int]:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    # GMMCGA is a raw driver image: its first word is dispatch-table data.
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, BIN.read_bytes())
    mu.mem_write((CODE_SEG << 4) + FONT_PTR_A, bytes((0x00, 0x80)))
    # P (0x50) glyph at 8000h + (0x50-0x20)*8. A non-symmetric pattern
    # catches both source-bit order and row/column placement.
    glyph = bytes((0xA5, 0x3C, 0x81, 0x42, 0x18, 0xE7, 0x00, 0x7E))
    mu.mem_write((CODE_SEG << 4) + 0x8180, glyph)
    mu.mem_write((CODE_SEG << 4) + CINEMATIC_FLAG, b"\xFF")
    mu.mem_write((VGA_SEG << 4), bytes(0x10000))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, VGA_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_SP, 0xFFFC),
                       (UC_X86_REG_AX, (selector << 8) | ord("P")),
                       (UC_X86_REG_BX, 0x0004), (UC_X86_REG_CX, 0x008F)):
        mu.reg_write(reg, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)
    vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    return fnv1a64(vga), vga[0x8F * 0x140 + 4], mu.reg_read(UC_X86_REG_IP)


def main() -> int:
    actual = [run(2), run(7)]
    expected = [
        (0x09E8C98B7168FE2D, 0x22, RET_SENTINEL),
        (0xFFD7FB96FC8CEDE3, 0x77, RET_SENTINEL),
    ]
    ok = actual == expected
    for index, (selector, (vga_hash, pixel, ip)) in enumerate(zip((2, 7), actual)):
        print(f"gmmcga_render_text_char_alt selector={selector}: "
              f"{'PASS' if (vga_hash, pixel, ip) == expected[index] else 'FAIL'} "
              f"vga={vga_hash:016x} pixel={pixel:02x} ip={ip:04x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GMMCGA 27E9 cinematic glyph renderer")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
