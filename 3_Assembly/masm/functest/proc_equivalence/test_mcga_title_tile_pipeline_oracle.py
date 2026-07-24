#!/usr/bin/env python3
"""Release-byte integration oracle for 105GDMCA:3732 then 37B4 title pair."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (UC_X86_REG_AX, UC_X86_REG_CS, UC_X86_REG_DS,
                               UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI,
                               UC_X86_REG_SP, UC_X86_REG_SS)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
CODE, GAME, STACK, VGA = 0x1000, 0x3000, 0x5000, 0xA000
TILEMAP, TILE, RET, TABLE = 0x3732, 0x37B4, 0x0080, 0x912B
EXPECTED_WORK = 0x8BED70B70EB897BA
EXPECTED_VGA = 0xD7E1E0FD7E6B87AB


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value = ((value ^ byte) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def call(mu: Uc, entry: int, ax: int = 0, si: int = 0, ds: int = CODE) -> None:
    mu.reg_write(UC_X86_REG_DS, ds)
    mu.reg_write(UC_X86_REG_ES, CODE)
    mu.reg_write(UC_X86_REG_AX, ax)
    mu.reg_write(UC_X86_REG_SI, si)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.mem_write((STACK << 4) + 0xFFFC, b"\x80\x00")

    def stop(uc, _address, _size, _user):
        if (uc.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET:
            uc.emu_stop()

    hook = mu.hook_add(UC_HOOK_CODE, stop)
    mu.emu_start((CODE << 4) + entry, 0)
    mu.hook_del(hook)


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE, GAME, STACK, VGA):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE << 4) + 0x2FFC, GDMCA_BIN.read_bytes())
    mu.mem_write((GAME << 4) + 0x4000,
                 bytes((i * 17 + 29) & 0xFF for i in range(0xC000)))
    mu.mem_write((GAME << 4) + TABLE,
                 bytes((i * 37 + 11) & 0xFF for i in range(0x19 * 0x22)))
    mu.mem_write((CODE << 4) + 0xFF2C, bytes((GAME & 0xFF, GAME >> 8)))
    mu.mem_write(VGA << 4, bytes((i * 37 + 11) & 0xFF for i in range(0x10000)))
    mu.reg_write(UC_X86_REG_CS, CODE)
    mu.reg_write(UC_X86_REG_SS, STACK)
    call(mu, TILEMAP, si=TABLE, ds=GAME)
    work = bytes(mu.mem_read(GAME << 4, 0x10000))
    call(mu, TILE, ax=0x00C7)
    call(mu, TILE, ax=0x0000)
    vga = bytes(mu.mem_read(VGA << 4, 0x10000))
    work_hash, vga_hash = fnv1a64(work), fnv1a64(vga)
    ok = work_hash == EXPECTED_WORK and vga_hash == EXPECTED_VGA
    print(f"mcga_title_tile_pipeline: {'PASS' if ok else 'FAIL'} work={work_hash:016x} vga={vga_hash:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": 105GDMCA 3732->37B4 title pair matches release bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
