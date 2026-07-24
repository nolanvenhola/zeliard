#!/usr/bin/env python3
"""Direct release-byte oracle for 105GDMCA:30FC disp_render_a_full."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX,
    UC_X86_REG_DI, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP,
    UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

GDMCA = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
CODE, GAME, WORK, STACK, VGA = 0x1000, 0x3000, 0x4000, 0x5000, 0xA000
ENTRY, RET = 0x30FC, 0x0080
EXPECTED_WORK = 0x21D1042FD1AD5D0F
EXPECTED_VGA = 0xCC1B898574C695CB
EXPECTED_VISIBLE = 0x904E7CFBDDD771CB
EXPECTED_PASSES = (
    0x4B65CF9E0219777D, 0xB471A139458E6E5D,
    0x09AA2183A7236BCD, 0x240C7FC08BFC603D,
    0xCBEF8AEBF3DCCADB, 0xD8992B64DCF8E6DB,
    0xF72957AF4854EA83, 0x21F995DF91097113,
    0xBCFCE4C43AC64D0B, 0x26BA7106C6C4952E,
    0x13DD98572E4C59CE, 0x8269D4D101C5A826,
    0x149A659953C296F2, 0x6BB13268B0698F87,
    0xC9F52E6D6666E9A3, 0x904E7CFBDDD771CB,
)


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value = ((value ^ byte) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE, GAME, WORK, STACK, VGA):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE << 4) + 0x2FFC, GDMCA.read_bytes())
    mu.mem_write(GAME << 4, bytes((i * 17 + 29) & 0xFF for i in range(0x10000)))
    mu.mem_write(VGA << 4, bytes((i * 37 + 11) & 0xFF for i in range(0x10000)))
    mu.reg_write(UC_X86_REG_CS, CODE)
    mu.reg_write(UC_X86_REG_DS, CODE)
    mu.reg_write(UC_X86_REG_ES, GAME)
    mu.reg_write(UC_X86_REG_SS, STACK)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.reg_write(UC_X86_REG_AX, 0)
    mu.reg_write(UC_X86_REG_BX, 0x070F)
    mu.reg_write(UC_X86_REG_CX, 0x4170)
    mu.reg_write(UC_X86_REG_DI, 0x9000)
    mu.mem_write((STACK << 4) + 0xFFFC, b"\x80\x00")

    checkpoints = []
    def service_timer_or_return(uc, _address, _size, _user):
        ip = uc.reg_read(UC_X86_REG_IP) & 0xFFFF
        if ip == 0x322D:
            checkpoints.append(fnv1a64(bytes(uc.mem_read(VGA << 4, 0xFA00))))
            uc.mem_write((CODE << 4) + 0xFF1A, b"\x14")
        elif ip == RET:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, service_timer_or_return)
    mu.emu_start((CODE << 4) + ENTRY, 0)
    work = bytes(mu.mem_read(WORK << 4, 0x10000))
    vga = bytes(mu.mem_read(VGA << 4, 0x10000))
    work_hash, vga_hash, visible_hash = fnv1a64(work), fnv1a64(vga), fnv1a64(vga[:0xFA00])
    ok = (work_hash == EXPECTED_WORK and vga_hash == EXPECTED_VGA and
          visible_hash == EXPECTED_VISIBLE and tuple(checkpoints) == EXPECTED_PASSES and
          (mu.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET)
    print("mcga_disp_render_a_full: " + ("PASS" if ok else "FAIL") +
          f" work={work_hash:016x} vga={vga_hash:016x} visible={visible_hash:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": 105GDMCA CS:30FC matches release bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
