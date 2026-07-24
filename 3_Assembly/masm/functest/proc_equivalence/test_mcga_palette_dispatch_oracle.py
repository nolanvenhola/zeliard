#!/usr/bin/env python3
"""MCGA palette-dispatch oracle for the opening driver.

Executes the MASM-built 105GDMCA.bin palette dispatch entry used by
100OPDMO's gfx_palette_fn slot and captures final VGA DAC writes.
"""

from __future__ import annotations

import hashlib
import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_HOOK_INSN, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_INS_IN,
    UC_X86_INS_OUT,
    UC_X86_REG_AX,
    UC_X86_REG_CS,
    UC_X86_REG_DS,
    UC_X86_REG_ES,
    UC_X86_REG_IP,
    UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT  # noqa: E402


GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"

CODE_SEG = 0x1000
STACK_SEG = 0x6000
VGA_SEG = 0xA000
LOAD_BASE = 0x2FFC
RET_SENTINEL = 0x0080

# 100OPDMO gfx_palette_fn is CS:3008. With the SAR loader's -4 byte placement,
# that slot reads the 105GDMCA dispatch word at file offset 0x0C -> 4221h.
ENTRY_GFX_PALETTE = 0x4221

EXPECTED_SHA256 = {
    0: "597ff4826e8f3d0539cf25039be4e9ca358b1e8164688dc28899bc4c68e79f74",
    1: "c99a7424ce56b334e4254477cd4fa22aa4529daf947ab5b7039fcfe2a8c8ce10",
    2: "4aa68c13e8b188629a598c97cf8e08e9a2e40eb28287ddc4f497c2765467eb21",
    3: "052cc882fece8a3e4b1616c0042e18e6dbeb81b036edebcb7c3b71885b2c4f53",
    4: "da23ba5b99a15a9cc1aab1b90e08459233207f30548be6075fcd081cf7b05521",
    5: "7babf52b0edf8c35a258999ba1936088008d8184a82b5b66813ed6fa14348129",
    6: "91ada4ff7e9265c06ad5c0f9d581e5f5973edd37caf9dc58105dd539303a7c28",
    7: "37c9179a2dd3f641604bfdb85cce4b3c833b34c0580794b74e084972865cb64d",
    8: "d3e46459d9cc245b7943099ff824f330f20fdfa97d8b4770eba3b1ff9cca1db4",
    9: "558b53c3e8173e2d2ce8166b7484097ee5690503b2877b6c3500e9457c4dd37f",
}


def capture_palette_dac(ax: int) -> bytes:
    data = GDMCA_BIN.read_bytes()
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for base in (0, CODE_SEG << 4, STACK_SEG << 4, VGA_SEG << 4):
        mu.mem_map(base, 0x10000, UC_PROT_ALL)

    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, data)
    # BIOS data area 40:63 = CRT controller base. Palette code reads +6.
    mu.mem_write((0x40 << 4) + 0x63, bytes([0xD4, 0x03]))

    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_AX, ax)
    sp = 0xFFFC
    mu.reg_write(UC_X86_REG_SP, sp)
    mu.mem_write((STACK_SEG << 4) + sp,
                 bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]))

    current_index: int | None = None
    dac_values: list[tuple[int | None, int]] = []

    def hook_code(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    def hook_out(_uc, port, _size, value, _user):
        nonlocal current_index
        value &= 0xFF
        if port == 0x3C8:
            current_index = value
        elif port == 0x3C9:
            dac_values.append((current_index, value))

    def hook_in(_uc, _port, _size, _user):
        return 0

    mu.hook_add(UC_HOOK_CODE, hook_code)
    mu.hook_add(UC_HOOK_INSN, hook_out, None, 1, 0, UC_X86_INS_OUT)
    mu.hook_add(UC_HOOK_INSN, hook_in, None, 1, 0, UC_X86_INS_IN)
    mu.emu_start((CODE_SEG << 4) + ENTRY_GFX_PALETTE,
                 (CODE_SEG << 4) + 0xFFFF)

    per_index: list[list[int]] = [[] for _ in range(256)]
    for index, value in dac_values:
        if index is not None:
            per_index[index].append(value)

    final = bytearray()
    for values in per_index:
        final.extend(values[-3:] if len(values) >= 3 else (0, 0, 0))
    return bytes(final)


def main() -> int:
    failures: list[str] = []
    for ax, expected in EXPECTED_SHA256.items():
        palette = capture_palette_dac(ax)
        actual = hashlib.sha256(palette).hexdigest()
        ok = actual == expected
        print(f"mcga_palette_ax{ax:02d}: {'PASS' if ok else 'FAIL'} sha256={actual}")
        if not ok:
            failures.append(f"AX={ax}")

    if failures:
        print("VERDICT: FAIL: MCGA palette dispatch drift: " + ", ".join(failures))
        return 1
    print("VERDICT: PASS: MCGA palette dispatch matches MASM DAC writes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
