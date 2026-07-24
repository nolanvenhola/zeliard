#!/usr/bin/env python3
"""Standalone release-MASM oracle for 105GDMCA:3E35 disp_script_area."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX,
    UC_X86_REG_DI, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP,
    UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402


GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
ASSET = MASM_ROOT.parent.parent / "6_WebPort" / "engine" / "assets" / "maop.grp"
CODE_SEG, DATA_SEG, WORK_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x2000, 0x4000, 0x5000, 0xA000
LOAD_BASE, ENTRY, RET_SENTINEL = 0x2FFC, 0x3E35, 0x0080
FRAME_TIMER = 0xFF1A
EXPECTED_FNV = 0x61C201EF93BF9D39


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def run() -> bytes:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, DATA_SEG, WORK_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, GDMCA_BIN.read_bytes())
    from test_mcga_render_entries_oracle import asset_source
    source = asset_source("maop.grp")
    mu.mem_write((DATA_SEG << 4) + 0x8000, source[:0x8000])
    mu.mem_write(VGA_SEG << 4, bytes(0x10000))
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, DATA_SEG),
                       (UC_X86_REG_ES, DATA_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, 8),
                       (UC_X86_REG_BX, 0x1618), (UC_X86_REG_CX, 0x315D),
                       (UC_X86_REG_DI, 0x8000)):
        mu.reg_write(reg, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))

    def hook(uc, _address, _size, _user):
        uc.mem_write((CODE_SEG << 4) + FRAME_TIMER, b"\xff")
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, hook)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)
    assert mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL
    return bytes(mu.mem_read(VGA_SEG << 4, 0x10000))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--capture", action="store_true")
    args = parser.parse_args()
    vga = run()
    actual = fnv1a64(vga)
    if args.capture:
        print(f"capture fnv={actual:016x}")
        return 0
    ok = actual == EXPECTED_FNV
    print(f"mcga_disp_script_area: {'PASS' if ok else 'FAIL'} fnv={actual:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM 3E35 MAOP script-area renderer")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
