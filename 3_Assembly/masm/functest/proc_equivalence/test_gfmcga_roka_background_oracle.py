#!/usr/bin/env python3
"""Release-MASM oracle for the 200FIGHT ROKA transition background."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_CS, UC_X86_REG_CX, UC_X86_REG_DS,
    UC_X86_REG_ES,
    UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

REPO_ROOT = MASM_ROOT.parents[1]
sys.path.insert(0, str(REPO_ROOT / "2_SAR" / "Tools"))
from decompress_sar import decompress_sar_chunk  # noqa: E402

BIN = MASM_ROOT / "working" / "zelres2" / "code" / "206GFMCA.bin"
GMMCGA = MASM_ROOT / "working" / "drivers" / "gmmcga.bin"
ROKA = MASM_ROOT / "working" / "zelres3" / "data" / "352ROKA.grp"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x8000, 0xA000
RET_SENTINEL = 0x0080
ENTRY_UI_TILE_BLIT_INIT = 0x4614
ENTRY_GMMCGA_DS_COPY = 0x2C2A
EXPECTED_PLAYFIELD_FNV = 0xEAA9FF9A250BC759


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    # The SAR header remains at 2FFCh, so its stripped payload starts at
    # the original driver's runtime address 3000h.
    mu.mem_write((CODE_SEG << 4) + 0x2FFC, BIN.read_bytes())
    mu.mem_write((CODE_SEG << 4) + 0x2000, GMMCGA.read_bytes())
    roka = bytes(decompress_sar_chunk(ROKA.read_bytes()))
    assert len(roka) == 0x7C * 0x30
    mu.mem_write((CODE_SEG << 4) + 0x8000, roka)
    mu.mem_write((CODE_SEG << 4) + 0xFF2C,
                 bytes((CODE_SEG & 0xFF, CODE_SEG >> 8)))

    def call(entry: int, registers=()):
        mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                     bytes((RET_SENTINEL, 0)))
        for reg, value in (
            (UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
            (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG),
            (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, 0),
            (UC_X86_REG_SI, 0), (UC_X86_REG_IP, entry), *registers,
        ):
            mu.reg_write(reg, value)

        def stop_on_return(uc, _address, _size, _user):
            if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
                uc.emu_stop()

        hook = mu.hook_add(UC_HOOK_CODE, stop_on_return)
        try:
            mu.emu_start((CODE_SEG << 4) + entry, 0, count=20_000_000)
        finally:
            mu.hook_del(hook)
        assert mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL

    call(ENTRY_GMMCGA_DS_COPY, (
        (UC_X86_REG_SI, 0x8000), (UC_X86_REG_CX, 0x80),
    ))
    call(ENTRY_UI_TILE_BLIT_INIT)
    vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    playfield = b"".join(
        vga[row * 320 + 48:row * 320 + 272] for row in range(14, 158)
    )
    actual = fnv1a64(playfield)
    ok = actual == EXPECTED_PLAYFIELD_FNV
    print(f"gfmcga_roka_background: {'PASS' if ok else 'FAIL'} "
          f"playfield={actual:016x} nonzero={sum(bool(x) for x in playfield)}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM 200FIGHT ROKA MCGA background")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
