#!/usr/bin/env python3
"""Release-MASM combined oracle for the initial 106TOWN HUD call span."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX,
    UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI,
    UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

BIN = MASM_ROOT / "working" / "drivers" / "gmmcga.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x8000, 0xA000
RET_SENTINEL = 0x0080
EXPECTED_VGA_FNV = 0x760C14598E9E15D6
EXPECTED_STATE_FNV = 0x36F73C3154C60582


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
    mu.mem_write((CODE_SEG << 4) + 0xF502, bytes((0x00, 0x80, 0x00, 0x90)))
    for base, count in ((0x8000, 16), (0x9000, 96)):
        data = bytearray(count * 8)
        for char_index in range(count):
            for row in range(8):
                data[char_index * 8 + row] = (
                    char_index * 31 + row * 23 + base // 0x100) & 0xFF
        mu.mem_write((CODE_SEG << 4) + base, bytes(data))
    records = (
        (0x6C93, bytes((0x0E, 0xA3, 0x00, 0x04)) + b"LIFE"),
        (0x6C9B, bytes((0x1E, 0xBB, 0x03, 0x05)) + b"ALMAS"),
        (0x6CA4, bytes((0x0D, 0xBB, 0x01, 0x04)) + b"GOLD"),
        (0x6CAC, bytes((0x0D, 0xAF, 0x01, 0x05)) + b"PLACE"),
        (0x9800, bytes((0x08, 0xAF, 0x02, 0x06)) + b"CASTLE"),
    )
    for address, record in records:
        mu.mem_write((CODE_SEG << 4) + address, record)
    mu.mem_write((CODE_SEG << 4) + 0x24EB, b"\x2a")
    mu.mem_write((CODE_SEG << 4) + 0x008B, bytes((0x39, 0x30)))
    mu.mem_write((CODE_SEG << 4) + 0x0085, bytes((0x12, 0x56, 0x34)))
    mu.mem_write((CODE_SEG << 4) + 0x0090, bytes((0x45, 0x02)))
    mu.mem_write((CODE_SEG << 4) + 0x0093, b"\x03")
    mu.mem_write((CODE_SEG << 4) + 0x0094, bytes((0xE1, 0x10)))
    mu.mem_write((CODE_SEG << 4) + 0x009D, b"\x03")
    mu.mem_write((CODE_SEG << 4) + 0x00AD, b"\x4d")
    mu.mem_write((CODE_SEG << 4) + 0x00B2, bytes((0x20, 0x03)))
    mu.mem_write(VGA_SEG << 4,
                 bytes((index * 13 + 5) & 0xFF for index in range(0x10000)))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG)):
        mu.reg_write(reg, value)

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    for bx, ch in ((0x0204, 0x21), (0x021C, 0x42), (0x481C, 0x42)):
        mu.reg_write(UC_X86_REG_AX, 0)
        mu.reg_write(UC_X86_REG_BX, bx)
        mu.reg_write(UC_X86_REG_CX, ch << 8)
        call(mu, 0x2195)
    call(mu, 0x2385)
    for address, _record in records[:4]:
        mu.reg_write(UC_X86_REG_SI, address)
        call(mu, 0x22BF)
    for entry in (0x2227, 0x2256, 0x238F, 0x23AC, 0x23CC):
        call(mu, entry)
    # 106TOWN draws the beveled shield-strength field before dispatching
    # GMMCGA:23F5.  BX=C61C/CH=17 produces the black top/left edges, blue
    # interior, and light-blue bottom edge visible in the released game.
    if mu.mem_read((CODE_SEG << 4) + 0x0093, 1)[0] != 0:
        mu.reg_write(UC_X86_REG_AX, 0)
        mu.reg_write(UC_X86_REG_BX, 0xC61C)
        mu.reg_write(UC_X86_REG_CX, 0x1700)
        call(mu, 0x2195)
        call(mu, 0x23F5)
    mu.reg_write(UC_X86_REG_SI, 0x9800)
    call(mu, 0x22CD)

    vga_hash = fnv1a64(bytes(mu.mem_read(VGA_SEG << 4, 0x10000)))
    state = (bytes(mu.mem_read((CODE_SEG << 4) + 0x2433, 7)) +
             bytes(mu.mem_read((CODE_SEG << 4) + 0x2CBD, 2)))
    state_hash = fnv1a64(state)
    ok = (vga_hash, state_hash) == (EXPECTED_VGA_FNV, EXPECTED_STATE_FNV)
    print(f"gmmcga_town_first_frame_hud: {'PASS' if ok else 'FAIL'} "
          f"vga={vga_hash:016x} state={state.hex()}:{state_hash:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM initial 106TOWN HUD call span")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
