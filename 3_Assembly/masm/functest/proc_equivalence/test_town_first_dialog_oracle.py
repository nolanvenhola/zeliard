#!/usr/bin/env python3
"""Release-MASM oracle for the first Felishika castle NPC dialog."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_HOOK_MEM_WRITE, UC_MODE_16, UC_PROT_ALL, Uc
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


GAME_SEG = 0x1000
STACK_SEG = 0x8000
VGA_SEG = 0xA000
RETURN_IP = 0x0080
TRY_TAKE_FACING_ITEM = 0x623F
TICK_NPCS_THEN_PUMP = 0x68AC
DRAW_AND_PUMP_INPUT = 0x68AF
GMM_DRAW_CHAR = 0x27E9


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def payload(path: Path) -> bytes:
    data = path.read_bytes()
    declared = int.from_bytes(data[:4], "little")
    assert declared <= len(data) - 4
    return data[4:4 + declared]


def write_u16(mu: Uc, offset: int, value: int) -> None:
    mu.mem_write((GAME_SEG << 4) + offset,
                 bytes((value & 0xFF, (value >> 8) & 0xFF)))


def simulate_ret(mu: Uc) -> None:
    sp = mu.reg_read(UC_X86_REG_SP) & 0xFFFF
    linear = (mu.reg_read(UC_X86_REG_SS) << 4) + sp
    target = int.from_bytes(bytes(mu.mem_read(linear, 2)), "little")
    mu.reg_write(UC_X86_REG_SP, (sp + 2) & 0xFFFF)
    mu.reg_write(UC_X86_REG_IP, target)


def main() -> int:
    paths = {
        "town": MASM_ROOT / "bin" / "zelres1" / "106TOWN.bin",
        "gmm": MASM_ROOT / "working" / "drivers" / "gmmcga.bin",
        "cmap": MASM_ROOT / "bin" / "zelres2" / "236CMAP.mdt",
        "font": MASM_ROOT / "bin" / "zelres1" / "112FONTG.grp",
    }
    if any(not path.exists() for path in paths.values()):
        print("VERDICT: INCONCLUSIVE: first-dialog release asset missing")
        return 1

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    base = GAME_SEG << 4
    mu.mem_write(base + 0x2000, paths["gmm"].read_bytes())
    mu.mem_write(base + 0x6000, payload(paths["town"]))
    mu.mem_write(base + 0xC000, payload(paths["cmap"]))
    font = bytes(decompress_sar_chunk(paths["font"].read_bytes()))
    mu.mem_write(base + 0xF500, font)
    for offset in range(0, 6, 2):
        value = int.from_bytes(bytes(mu.mem_read(base + 0xF500 + offset, 2)),
                               "little")
        write_u16(mu, 0xF500 + offset, (value + 0xF500) & 0xFFFF)

    # One MASM right step from the new-game fixture puts the player at
    # world X=45; NPC 1 at X=48 is then the third right-facing candidate.
    write_u16(mu, 0x0080, 0x001E)
    mu.mem_write(base + 0x0083, b"\x0B")
    mu.mem_write(base + 0x00C2, b"\x00")
    write_u16(mu, 0xFF2A, 0xC107)
    write_u16(mu, 0xFF2C, GAME_SEG)
    mu.mem_write(base + 0xFF1D, b"\xFF")
    mu.mem_write(base + 0xFF1E, b"\x00")
    # NPC stamping normally writes this during the live loop.
    mu.mem_write(base + 0xC19C, b"\xFD")

    # A deterministic non-zero background proves the GMMCGA 289A/28D9
    # save/restore pair encloses the dialog exactly.
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

    page_hashes: list[int] = []
    glyphs: list[tuple[int, int, int, int]] = []
    cues: list[int] = []

    def code_hook(uc: Uc, address: int, _size: int, _user: object) -> None:
        ip = address - base
        if uc.reg_read(UC_X86_REG_IP) == RETURN_IP:
            uc.emu_stop()
            return
        if ip == DRAW_AND_PUMP_INPUT:
            simulate_ret(uc)
            return
        if ip == TICK_NPCS_THEN_PUMP:
            page_hashes.append(fnv1a64(bytes(uc.mem_read(VGA_SEG << 4, 0x10000))))
            uc.mem_write(base + 0xFF1D, b"\xFF")
            simulate_ret(uc)
            return
        if ip == GMM_DRAW_CHAR:
            glyphs.append((uc.reg_read(UC_X86_REG_AX) & 0xFFFF,
                           uc.reg_read(UC_X86_REG_BX) & 0xFFFF,
                           uc.reg_read(UC_X86_REG_CX) & 0xFFFF,
                           uc.reg_read(UC_X86_REG_SI) & 0xFFFF))

    def write_hook(_uc: Uc, _access: int, address: int, _size: int,
                   value: int, _user: object) -> None:
        if address == base + 0xFF75:
            cues.append(value & 0xFF)

    mu.hook_add(UC_HOOK_CODE, code_hook)
    mu.hook_add(UC_HOOK_MEM_WRITE, write_hook)
    mu.emu_start(base + TRY_TAKE_FACING_ITEM, 0, count=5_000_000)

    final_vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    npc = bytes(mu.mem_read(base + 0xC89C, 8))
    text_pc = int.from_bytes(bytes(mu.mem_read(base + 0x7C58, 2)), "little")
    expected_page_hashes = [0x886C34A52FF3FEE5]
    expected_glyph_count = 161
    ok = (
        mu.reg_read(UC_X86_REG_IP) == RETURN_IP
        and final_vga == background
        and npc == bytes.fromhex("3000811801000000")
        and text_pc == 0xC4AC
        and cues == [0x1E]
        and len(glyphs) == expected_glyph_count
        and page_hashes == expected_page_hashes
    )
    print(f"town_first_dialog: pages={[f'{value:016x}' for value in page_hashes]} "
          f"glyphs={len(glyphs)} text_pc={text_pc:04x} cues="
          f"{','.join(f'{value:02x}' for value in cues)} "
          f"final={fnv1a64(final_vga):016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
