#!/usr/bin/env python3
"""Release-MASM checkpoint for one 105GDMCA:3437 sprite frame.

The probe starts with OPDMO's scene_sprite_a records, deterministic game/A000
fixtures, and stops at 3544h immediately before the first FF1A >= 1Eh wait.
It locks the object state, A000 output, and CS+3000h backup surface used by
the mechanical C frame-loop translation.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP,
    UC_X86_REG_SI, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

CODE, GAME, WORK, STACK, VGA = 0x1000, 0x2000, 0x4000, 0x5000, 0xA000
ENTRY, WAIT = 0x3437, 0x3544
EXPECTED = (0x15198061EF16CC51, 0x74AA23386B36F366, 0x879CFABB32DD5D25)


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value = ((value ^ byte) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    root = MASM_ROOT
    driver = (root / "bin" / "zelres1" / "105GDMCA.bin").read_bytes()
    opdmo = (root / "bin" / "zelres1" / "100OPDMO.bin").read_bytes()
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    # write_palette_byte_mcga reads the DOS BIOS data area through 0040h.
    mu.mem_map(0, 0x10000, UC_PROT_ALL)
    for seg in (CODE, GAME, WORK, STACK, VGA):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE << 4) + 0x2FFC, driver)
    mu.mem_write((CODE << 4) + 0x6000, opdmo[4:])
    mu.mem_write(GAME << 4, bytes((i * 17 + 29) & 0xFF for i in range(0x10000)))
    mu.mem_write(VGA << 4, bytes((i * 37 + 11) & 0xFF for i in range(0x10000)))
    mu.mem_write((CODE << 4) + 0xFF2C, bytes((GAME & 0xFF, GAME >> 8)))
    for reg, value in ((UC_X86_REG_CS, CODE), (UC_X86_REG_DS, CODE),
                       (UC_X86_REG_ES, CODE), (UC_X86_REG_SS, STACK),
                       (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_SI, 0x9060)):
        mu.reg_write(reg, value)

    def stop_at_wait(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == WAIT:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_at_wait)
    mu.emu_start((CODE << 4) + ENTRY, 0)
    actual = (
        fnv1a64(bytes(mu.mem_read((CODE << 4) + 0xA000, 9 * 15))),
        fnv1a64(bytes(mu.mem_read(VGA << 4, 320 * 200))),
        fnv1a64(bytes(mu.mem_read(WORK << 4, 0x10000))),
    )
    ok = actual == EXPECTED and mu.reg_read(UC_X86_REG_IP) == WAIT
    print("mcga_sprite_frame_prepare: " + ("PASS" if ok else "FAIL") +
          " objects=%016x vga=%016x work=%016x" % actual)
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": MCGA sprite frame prepare matches release bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
