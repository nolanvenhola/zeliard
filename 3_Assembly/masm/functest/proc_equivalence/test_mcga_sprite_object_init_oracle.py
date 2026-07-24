#!/usr/bin/env python3
"""Direct MASM oracle for 105GDMCA:3437 sprite-object initialization."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS,
    UC_X86_REG_DS,
    UC_X86_REG_ES,
    UC_X86_REG_IP,
    UC_X86_REG_SI,
    UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT  # noqa: E402


GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
OPDMO_BIN = MASM_ROOT / "bin" / "zelres1" / "100OPDMO.bin"
CODE_SEG = 0x1000
STACK_SEG = 0x5000
GDMCA_LOAD_BASE = 0x2FFC
OPDMO_LOAD_BASE = 0x6000
ENTRY_SPRITE_OBJECT_INIT = 0x3437
SPRITE_FRAME_LOOP = 0x3465
SCENE_SPRITE_A = 0x9060
SPRITE_OBJECT_TABLE = 0xA000
SPRITE_OBJECT_BYTES = 9 * 15
RET_SENTINEL = 0x0080
EXPECTED_FNV = 0xC21FE918B5101768


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, STACK_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + GDMCA_LOAD_BASE, GDMCA_BIN.read_bytes())

    opdmo = OPDMO_BIN.read_bytes()
    mu.mem_write((CODE_SEG << 4) + OPDMO_LOAD_BASE, opdmo[4:])
    # The object initializer has completed at this label. Return instead of
    # running the frame-timed animation loop that follows it.
    mu.mem_write((CODE_SEG << 4) + SPRITE_FRAME_LOOP, bytes([0xC3]))

    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.reg_write(UC_X86_REG_SI, SCENE_SPRITE_A)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]))

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY_SPRITE_OBJECT_INIT,
                 (CODE_SEG << 4) + 0xFFFF)

    objects = bytes(mu.mem_read((CODE_SEG << 4) + SPRITE_OBJECT_TABLE,
                                SPRITE_OBJECT_BYTES))
    actual = fnv1a64(objects)
    ok = actual == EXPECTED_FNV and mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL
    print("mcga_sprite_object_init: " + ("PASS" if ok else "FAIL") +
          f" bytes={len(objects)} fnv={actual:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": MCGA sprite-object initialization matches MASM bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
