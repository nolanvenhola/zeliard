#!/usr/bin/env python3
"""Release-MASM oracle for Muralla's first multi-page NPC dialog."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX,
    UC_X86_REG_DI, UC_X86_REG_DS, UC_X86_REG_DX, UC_X86_REG_ES,
    UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
MASM_ROOT = HERE.parents[1]
REPO_ROOT = MASM_ROOT.parents[1]
sys.path.insert(0, str(REPO_ROOT / "2_SAR" / "Tools"))
from decompress_sar import decompress_sar_chunk  # noqa: E402

from test_town_first_dialog_oracle import (  # noqa: E402
    DRAW_AND_PUMP_INPUT, GAME_SEG, GMM_DRAW_CHAR, RETURN_IP, STACK_SEG,
    TICK_NPCS_THEN_PUMP, TRY_TAKE_FACING_ITEM, VGA_SEG, fnv1a64,
    payload, simulate_ret, write_u16,
)


def main() -> int:
    paths = {
        "town": MASM_ROOT / "bin" / "zelres1" / "106TOWN.bin",
        "gmm": MASM_ROOT / "working" / "drivers" / "gmmcga.bin",
        "mrmp": MASM_ROOT / "bin" / "zelres2" / "237MRMP.mdt",
        "font": MASM_ROOT / "bin" / "zelres1" / "112FONTG.grp",
    }
    if any(not path.exists() for path in paths.values()):
        print("VERDICT: INCONCLUSIVE: Muralla dialog release asset missing")
        return 1

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    base = GAME_SEG << 4
    mu.mem_write(base + 0x2000, paths["gmm"].read_bytes())
    mu.mem_write(base + 0x6000, payload(paths["town"]))
    mu.mem_write(base + 0xC000, payload(paths["mrmp"]))
    font = bytes(decompress_sar_chunk(paths["font"].read_bytes()))
    mu.mem_write(base + 0xF500, font)
    for offset in range(0, 6, 2):
        value = int.from_bytes(
            bytes(mu.mem_read(base + 0xF500 + offset, 2)), "little")
        write_u16(mu, 0xF500 + offset, (value + 0xF500) & 0xFFFF)

    # Player world X=007Fh makes Muralla's first NPC at 0082h the third
    # right-facing candidate in try_take_facing_item.
    write_u16(mu, 0x0080, 0x0070)
    mu.mem_write(base + 0x0083, b"\x0B")
    mu.mem_write(base + 0x00C2, b"\x00")
    write_u16(mu, 0xFF2A, 0xD000)
    write_u16(mu, 0xFF2C, GAME_SEG)
    mu.mem_write(base + 0xFF1D, b"\xFF")
    mu.mem_write(base + 0xFF1E, b"\x00")
    mu.mem_write(base + 0xD095, b"\xFD")

    background = bytes((index * 13 + 7) & 0xFF for index in range(0x10000))
    mu.mem_write(VGA_SEG << 4, background)
    for register, value in (
        (UC_X86_REG_CS, GAME_SEG), (UC_X86_REG_DS, GAME_SEG),
        (UC_X86_REG_ES, GAME_SEG), (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, 0),
        (UC_X86_REG_BX, 0), (UC_X86_REG_CX, 0),
        (UC_X86_REG_DX, 0), (UC_X86_REG_SI, 0), (UC_X86_REG_DI, 0),
    ):
        mu.reg_write(register, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RETURN_IP & 0xFF, RETURN_IP >> 8)))

    pages: list[int] = []
    glyphs: list[tuple[int, int, int]] = []

    def code_hook(uc: Uc, address: int, _size: int, _user: object) -> None:
        ip = address - base
        if uc.reg_read(UC_X86_REG_IP) == RETURN_IP:
            uc.emu_stop()
            return
        if ip == DRAW_AND_PUMP_INPUT:
            simulate_ret(uc)
            return
        if ip == TICK_NPCS_THEN_PUMP:
            pages.append(fnv1a64(bytes(uc.mem_read(VGA_SEG << 4, 0x10000))))
            uc.mem_write(base + 0xFF1D, b"\xFF")
            simulate_ret(uc)
            return
        if ip == GMM_DRAW_CHAR:
            glyphs.append((uc.reg_read(UC_X86_REG_AX) & 0xFFFF,
                           uc.reg_read(UC_X86_REG_BX) & 0xFFFF,
                           uc.reg_read(UC_X86_REG_CX) & 0xFFFF))

    mu.hook_add(UC_HOOK_CODE, code_hook)
    mu.emu_start(base + TRY_TAKE_FACING_ITEM, 0, count=10_000_000)

    final_vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    npc = bytes(mu.mem_read(base + 0xCEAF, 8))
    text_pc = int.from_bytes(bytes(mu.mem_read(base + 0x7C58, 2)), "little")
    page_hashes = [f"{value:016x}" for value in pages]
    ok = (
        mu.reg_read(UC_X86_REG_IP) == RETURN_IP
        and final_vga == background
        and npc == bytes.fromhex("8200022503030006")
        and len(glyphs) == 207
        and pages == [0x2CE6A7710F269E11, 0xB95556613E17D5DA]
        and text_pc == 0xCD23
    )
    print(f"town_muralla_dialog: pages={page_hashes} glyphs={len(glyphs)} "
          f"text_pc={text_pc:04x} final={fnv1a64(final_vga):016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
