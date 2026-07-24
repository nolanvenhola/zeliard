#!/usr/bin/env python3
"""Direct release-byte oracle for 105GDMCA:36AB disp_render_ab_gseg.

100OPDMO:play_sprite_anim_script reaches this through CS:[3016] whenever a
script byte is below five.  AL selects one 0x480-byte two-plane page beginning
at game_seg:97C0h; the driver builds its CS+3000h work buffer and copies the
result to A000h.  This is intentionally a driver-level probe, not a scene
approximation.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES,
    UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402


GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
CODE_SEG, GAME_SEG, WORK_SEG, STACK_SEG, VGA_SEG = 0x1000, 0x3000, 0x4000, 0x5000, 0xA000
GDMCA_LOAD_BASE = 0x2FFC
ENTRY = 0x36AB
RET_SENTINEL = 0x0080
GVAR_GAME_SEG = 0xFF2C
SCENE_BASE = 0x97C0
PAGE_SIZE = 0x480


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def run_page(page: int) -> tuple[int, int]:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, GAME_SEG, WORK_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE_SEG << 4) + GDMCA_LOAD_BASE, GDMCA_BIN.read_bytes())
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * GDMCA_LOAD_BASE)
    mu.mem_write((CODE_SEG << 4) + GVAR_GAME_SEG,
                 bytes((GAME_SEG & 0xFF, GAME_SEG >> 8)))
    # The selected page is deliberately nonuniform; the other pages are also
    # populated so an AL/page-address regression cannot pass accidentally.
    game = bytearray(0x10000)
    for i in range(PAGE_SIZE * 4):
        game[SCENE_BASE + i] = (i * 37 + 11) & 0xFF
    mu.mem_write(GAME_SEG << 4, bytes(game))
    mu.mem_write(VGA_SEG << 4, bytes((i * 19 + 7) & 0xFF for i in range(0x10000)))

    for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
                       (UC_X86_REG_ES, GAME_SEG), (UC_X86_REG_SS, STACK_SEG),
                       (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, page)):
        mu.reg_write(reg, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_on_return)
    mu.emu_start((CODE_SEG << 4) + ENTRY, 0)
    assert mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL
    return (fnv1a64(bytes(mu.mem_read(WORK_SEG << 4, 0x10000))),
            fnv1a64(bytes(mu.mem_read(VGA_SEG << 4, 0x10000))))


def main() -> int:
    actual = [run_page(page) for page in range(4)]
    # Filled from release MASM execution. Keep all four AL selectors pinned.
    expected = [
        (0xEA54490A87ACB88A, 0xB4F706EFEF059AD2),
        (0xB87AD8B93A57264A, 0xD0CD568D834E7852),
        (0xEA54490A87ACB88A, 0xB4F706EFEF059AD2),
        (0xB87AD8B93A57264A, 0xD0CD568D834E7852),
    ]
    ok = actual == expected
    for page, (work_hash, vga_hash) in enumerate(actual):
        print(f"mcga_disp_render_ab_gseg page={page}: "
              f"{'PASS' if (work_hash, vga_hash) == expected[page] else 'FAIL'} "
              f"work={work_hash:016x} vga={vga_hash:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM 36AB page renderer")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
