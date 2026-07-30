#!/usr/bin/env python3
"""Release-MASM oracle for GMMCGA town numeric HUD services."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP,
    UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

BIN = MASM_ROOT / "working" / "drivers" / "gmmcga.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x8000, 0xA000
RET_SENTINEL = 0x0080
ENTRIES = (0x238F, 0x23AC, 0x23CC, 0x23F5)
EXPECTED = (
    0x493B33F0AD38F70D,
    0xF361E65421F56679,
    0x34E71A370A27FF42,
    0xFEF9AC4EA582B005,
)
EXPECTED_DIGITS = (
    "ffff0102030405", "01010903000406", "ffffffffff0707",
    "ffffff04030201",
)
EXPECTED_NO_SPELL_FNV = 0x5CA562D8E09D063E


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
    mu.mem_write((CODE_SEG << 4) + 0xF502, bytes((0x00, 0x80)))
    font = bytearray(16 * 8)
    for digit in range(16):
        for row in range(8):
            font[digit * 8 + row] = (digit * 31 + row * 23 + 0x41) & 0xFF
    mu.mem_write((CODE_SEG << 4) + 0x8000, bytes(font))
    mu.mem_write((CODE_SEG << 4) + 0x24EB, b"\x2a")
    mu.mem_write((CODE_SEG << 4) + 0x008B, bytes((0x39, 0x30)))  # almas 12345
    mu.mem_write((CODE_SEG << 4) + 0x0085, bytes((0x12, 0x56, 0x34)))
    mu.mem_write((CODE_SEG << 4) + 0x0093, b"\x03")
    mu.mem_write((CODE_SEG << 4) + 0x0094, bytes((0xE1, 0x10)))
    mu.mem_write((CODE_SEG << 4) + 0x009D, b"\x03")
    mu.mem_write((CODE_SEG << 4) + 0x00AD, b"\x4d")
    mu.mem_write(VGA_SEG << 4,
                 bytes((index * 7 + 3) & 0xFF for index in range(0x10000)))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG)):
        mu.reg_write(reg, value)

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    hashes = []
    digits = []
    for entry in ENTRIES:
        call(mu, entry)
        hashes.append(fnv1a64(bytes(mu.mem_read(VGA_SEG << 4, 0x10000))))
        digits.append(bytes(mu.mem_read((CODE_SEG << 4) + 0x2433, 7)).hex())

    actual = tuple(hashes)
    actual_digits = tuple(digits)
    mu.mem_write((CODE_SEG << 4) + 0x009D, b"\x00")
    mu.mem_write((CODE_SEG << 4) + 0x01AA, b"\x58")
    initial_vga = bytes((index * 7 + 3) & 0xFF for index in range(0x10000))
    mu.mem_write(VGA_SEG << 4, initial_vga)
    call(mu, 0x23CC)
    no_spell_hash = fnv1a64(bytes(mu.mem_read(VGA_SEG << 4, 0x10000)))
    mu.mem_write((CODE_SEG << 4) + 0x0093, b"\x00")
    before_no_shield = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    call(mu, 0x23F5)
    no_shield_unchanged = bytes(mu.mem_read(VGA_SEG << 4, 0x10000)) == before_no_shield
    ok = (actual == EXPECTED and actual_digits == EXPECTED_DIGITS and
          no_spell_hash == EXPECTED_NO_SPELL_FNV and no_shield_unchanged)
    print("gmmcga_town_numeric_hud: " + ("PASS" if ok else "FAIL"))
    for entry, value, digit_bytes in zip(ENTRIES, hashes, digits):
        print(f"  {entry:04x}: vga={value:016x} digits={digit_bytes}")
    print(f"  selected=0: vga={no_spell_hash:016x} "
          f"shield=0 unchanged={no_shield_unchanged}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GMMCGA numeric HUD services")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
