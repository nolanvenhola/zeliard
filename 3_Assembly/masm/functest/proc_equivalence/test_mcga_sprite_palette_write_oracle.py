#!/usr/bin/env python3
"""Oracle for the AX=0 MCGA palette path used by sprite_pal_update_loop.

100OPDMO's NEC/HOU sprite loop changes pal_r_reg/pal_g_reg/pal_b_reg, then
calls 105GDMCA.write_palette_byte_mcga with AX=0.  This test captures the
real DAC protocol from the released MASM bytes: 16 palettes x 16 entries,
with one 3C8 index write and three 3C9 component writes per entry.
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
LOAD_BASE = 0x2FFC
RET_SENTINEL = 0x0080
ENTRY_WRITE_PALETTE = 0x4221
PAL_R_REG = 0x4289

# Seed the sprite RGB adjustment triple with values that make the observed
# component stream sensitive to byte order and signed wraparound.
SPRITE_RGB = (0x05, 0x12, 0x1F)
EXPECTED_DAC_SHA256 = "dc45941ff97c70bb1c7a5cdccf150ac034cdbb06c7a3e23d81bf3bac0130f821"


def capture() -> tuple[list[tuple[int, int]], list[tuple[int, int]]]:
    data = GDMCA_BIN.read_bytes()
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    # Unicorn's real-mode BIOS page must be mapped first.
    for base in (0, CODE_SEG << 4, STACK_SEG << 4):
        mu.mem_map(base, 0x10000, UC_PROT_ALL)
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, data)
    # BIOS 40:63 is the CRT base port; the driver reads it then samples 3DA.
    mu.mem_write((0x40 << 4) + 0x63, bytes([0xD4, 0x03]))
    mu.mem_write((CODE_SEG << 4) + PAL_R_REG, bytes(SPRITE_RGB))

    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_AX, 0)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC, bytes([RET_SENTINEL, 0]))

    indices: list[tuple[int, int]] = []
    components: list[tuple[int, int]] = []

    def hook_code(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    def hook_out(_uc, port, _size, value, _user):
        if port == 0x3C8:
            indices.append((port, value & 0xFF))
        elif port == 0x3C9:
            components.append((port, value & 0xFF))

    def hook_in(_uc, _port, _size, _user):
        return 0

    mu.hook_add(UC_HOOK_CODE, hook_code)
    mu.hook_add(UC_HOOK_INSN, hook_out, None, 1, 0, UC_X86_INS_OUT)
    mu.hook_add(UC_HOOK_INSN, hook_in, None, 1, 0, UC_X86_INS_IN)
    mu.emu_start((CODE_SEG << 4) + ENTRY_WRITE_PALETTE, 0)
    return indices, components


def main() -> int:
    indices, components = capture()
    payload = bytes(v for _, v in indices + components)
    digest = hashlib.sha256(payload).hexdigest()
    failures: list[str] = []

    if len(indices) != 256:
        failures.append(f"expected 256 DAC index writes, got {len(indices)}")
    if len(components) != 768:
        failures.append(f"expected 768 DAC component writes, got {len(components)}")
    expected_indices = list(range(256))
    if [v for _, v in indices] != expected_indices:
        failures.append("3C8 index sequence is not the full 0..255 palette")
    if not all(port == 0x3C9 for port, _ in components):
        failures.append("non-3C9 component write observed")
    if EXPECTED_DAC_SHA256 and digest != EXPECTED_DAC_SHA256:
        failures.append(f"DAC stream hash drift: {digest}")

    print(f"mcga_sprite_palette_ax0: {'PASS' if not failures else 'FAIL'} "
          f"indices={len(indices)} components={len(components)} sha256={digest}")
    if failures:
        print("VERDICT: FAIL: " + "; ".join(failures))
        return 1
    print("VERDICT: PASS: sprite AX=0 palette write matches MASM DAC protocol")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
