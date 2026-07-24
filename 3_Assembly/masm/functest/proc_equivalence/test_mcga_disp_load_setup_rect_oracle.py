#!/usr/bin/env python3
"""Release-byte oracle for 105GDMCA:3D79, OPDMO's disp_load_setup slot."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import Uc, UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL
from unicorn.x86_const import (
    UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX, UC_X86_REG_DS,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x5000, 0xA000
LOAD_BASE, DISP_LOAD_SETUP, RET_SENTINEL = 0x2FFC, 0x3D79, 0x0080
FRAMEBUFFER_BYTES = 320 * 200

EXPECTED = {
    (0x0A15, 0x1A5D): "82f852300d0ccbd9",
    (0x2C15, 0x1A5D): "df07fffb511e6959",
    (0x1515, 0x315D): "e4769151bb374b11",
}


def fnv1a64(data: bytes) -> str:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return f"{value:016x}"


def run_disp_load_setup(bx: int, cx: int) -> bytes:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for segment in (CODE_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(segment << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, GDMCA_BIN.read_bytes())
    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, VGA_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_BX, bx)
    mu.reg_write(UC_X86_REG_CX, cx)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC, bytes([RET_SENTINEL, 0]))

    def hook_code(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, hook_code)
    mu.emu_start((CODE_SEG << 4) + DISP_LOAD_SETUP, (CODE_SEG << 4) + 0xFFFF)
    return bytes(mu.mem_read(VGA_SEG << 4, FRAMEBUFFER_BYTES))


def main() -> int:
    failures: list[str] = []
    for (bx, cx), expected in EXPECTED.items():
        actual = fnv1a64(run_disp_load_setup(bx, cx))
        ok = actual == expected
        print(f"mcga_disp_load_setup_bx{bx:04x}_cx{cx:04x}: "
              f"{'PASS' if ok else 'FAIL'} hash={actual}")
        if not ok:
            failures.append(f"BX={bx:04x}/CX={cx:04x}")
    if failures:
        print("VERDICT: FAIL: MCGA disp_load_setup mismatch for " + ", ".join(failures))
        return 1
    print("VERDICT: PASS: MCGA disp_load_setup oracle matches MASM bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
