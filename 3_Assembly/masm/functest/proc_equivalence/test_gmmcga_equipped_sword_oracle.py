#!/usr/bin/env python3
"""Release-MASM oracle for GMMCGA's equipped-sword renderer at 254Ch."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_DS,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

TOOLS = MASM_ROOT.parents[1] / "2_SAR" / "Tools"
sys.path.insert(0, str(TOOLS))
from decompress_sar import decompress_sar_chunk  # noqa: E402

BIN = MASM_ROOT / "working" / "drivers" / "gmmcga.bin"
ITEMP = MASM_ROOT.parents[1] / "6_WebPort" / "engine" / "assets" / "itemp.grp"
CODE_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x8000, 0xA000
ENTRY, RET_SENTINEL = 0x254C, 0x0080
EXPECTED_RECTS = (
    0xACE1EEC895369B0A, 0x077A65ACB967926D,
    0xA8A66214ADC1AFD1, 0xD8DEE0CB628E0F10,
    0xD6DAEEAFE2A0B1FA, 0xDA10261D04E42AC4,
)


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def render_sword(sword: int) -> tuple[int, int, bool]:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    mu.mem_write((CODE_SEG << 4) + 0x2000, BIN.read_bytes())

    itemp = bytearray(decompress_sar_chunk(ITEMP.read_bytes()))
    for offset in range(0, 14, 2):
        value = itemp[offset] | itemp[offset + 1] << 8
        value = (value + 0xE200) & 0xFFFF
        itemp[offset] = value & 0xFF
        itemp[offset + 1] = value >> 8
    mu.mem_write((CODE_SEG << 4) + 0xE200, bytes(itemp))
    mu.mem_write((CODE_SEG << 4) + 0xFF2C,
                 bytes((CODE_SEG & 0xFF, CODE_SEG >> 8)))
    mu.mem_write(VGA_SEG << 4, bytes(0x10000))

    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG)):
        mu.reg_write(reg, value)
    mu.reg_write(UC_X86_REG_AX, sword)
    mu.reg_write(UC_X86_REG_BX, 0x18AB)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL, 0)))

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0, count=1_000_000)
    frame = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    rect = b"".join(frame[(171 + row) * 320 + 192:
                          (171 + row) * 320 + 212] for row in range(18))
    frame_hash, rect_hash = fnv1a64(frame), fnv1a64(rect)
    return frame_hash, rect_hash, mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL


def main() -> int:
    results = [render_sword(sword) for sword in range(1, 7)]
    ok = all(returned and rect == EXPECTED_RECTS[index]
             for index, (_frame, rect, returned) in enumerate(results))
    print("gmmcga_equipped_sword: " + ("PASS" if ok else "FAIL") +
          " rects=" + ",".join(f"{rect:016x}"
                                 for _frame, rect, _returned in results))
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GMMCGA equipped-sword renderer")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
