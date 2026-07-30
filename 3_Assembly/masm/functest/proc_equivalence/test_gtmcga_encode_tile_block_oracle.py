#!/usr/bin/env python3
"""Release-MASM oracle for GTMCGA:3A71 tile packing and alpha masks."""

from __future__ import annotations

import struct
import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS, UC_X86_REG_CX, UC_X86_REG_DI, UC_X86_REG_DS,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

BIN = MASM_ROOT / "bin" / "zelres1" / "111GTMCA.bin"
CODE_SEG, WORK_SEG, SCRATCH_SEG, STACK_SEG = 0x1000, 0x3000, 0x4000, 0x8000
ENTRY, RET_SENTINEL = 0x3A71, 0x0080
EXPECTED_PACKED_FNV = 0x67F69B87D30BB04F
EXPECTED_MASK_FNV = 0x13E086083EC42BBE
EXPECTED_SCRATCH_FNV = 0xF772DBD58E946932


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    source = bytearray(3 * 0x30)
    for index in range(0x30):
        source[0x30 + index] = (index * 37 + 11) & 0xFF
    for row in range(8):
        struct.pack_into("<HHH", source, 0x60 + row * 6,
                         1 << (row * 2), 1 << (row * 2 + 1),
                         0x8000 >> row)

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    chunk = BIN.read_bytes()
    mu.mem_write((CODE_SEG << 4) + 0x3000, chunk[4:])
    mu.mem_write((CODE_SEG << 4) + 0x4100, bytes(source))
    mu.mem_write((WORK_SEG << 4) + 0x7000, bytes([0xA5]) * 24)
    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, WORK_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_SI, 0x4100),
                       (UC_X86_REG_DI, 0x7000), (UC_X86_REG_CX, 3)):
        mu.reg_write(reg, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0, count=2_000_000)
    packed = bytes(mu.mem_read((CODE_SEG << 4) + 0x4100, 144))
    masks = bytes(mu.mem_read((WORK_SEG << 4) + 0x7000, 24))
    scratch = bytes(mu.mem_read(SCRATCH_SEG << 4, 144))
    hashes = fnv1a64(packed), fnv1a64(masks), fnv1a64(scratch)
    ok = (mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL and
          hashes == (EXPECTED_PACKED_FNV, EXPECTED_MASK_FNV,
                     EXPECTED_SCRATCH_FNV))
    print(f"gtmcga_encode_tile_block: {'PASS' if ok else 'FAIL'} "
          f"packed={hashes[0]:016x} masks={hashes[1]:016x} "
          f"scratch={hashes[2]:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GTMCGA:3A71 tile encoder")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
