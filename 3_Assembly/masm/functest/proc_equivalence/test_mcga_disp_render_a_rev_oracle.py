#!/usr/bin/env python3
"""Release-byte oracle for 105GDMCA:30E4 disp_render_a_rev."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX, UC_X86_REG_DI,
    UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

GDMCA = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
CODE, GAME, STACK, VGA = 0x1000, 0x3000, 0x5000, 0xA000
ENTRY, RET = 0x30E4, 0x0080
EXPECTED = {
    0x00: 0xE035E5066B84BB25,
    0xFF: 0xE035E5066B84BB25,
}


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value = ((value ^ byte) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def run_case(render_mode: int) -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE, GAME, STACK, VGA):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE << 4) + 0x2FFC, GDMCA.read_bytes())
    mu.mem_write((CODE << 4) + 0x4508, bytes((render_mode,)))
    mu.mem_write((CODE << 4) + 0xFF1A, b"\x14")
    mu.mem_write((GAME << 4),
                 bytes((i * 17 + 29) & 0xFF for i in range(0x10000)))
    mu.mem_write((VGA << 4),
                 bytes((i * 37 + 11) & 0xFF for i in range(0x10000)))
    mu.reg_write(UC_X86_REG_CS, CODE)
    mu.reg_write(UC_X86_REG_DS, CODE)
    mu.reg_write(UC_X86_REG_ES, GAME)
    mu.reg_write(UC_X86_REG_SS, STACK)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.reg_write(UC_X86_REG_BX, 0x1720)
    mu.reg_write(UC_X86_REG_CX, 0x2270)
    mu.reg_write(UC_X86_REG_DI, 0x3000)
    mu.mem_write((STACK << 4) + 0xFFFC, b"\x80\x00")

    def stop(uc, _address, _size, _user):
        ip = uc.reg_read(UC_X86_REG_IP) & 0xFFFF
        if ip == 0x322D:
            uc.mem_write((CODE << 4) + 0xFF1A, b"\x14")
        elif ip == RET:
            uc.emu_stop()

    hook = mu.hook_add(UC_HOOK_CODE, stop)
    mu.emu_start((CODE << 4) + ENTRY, 0)
    mu.hook_del(hook)
    result = fnv1a64(bytes(mu.mem_read(VGA << 4, 0x10000)))
    print(f"mcga_disp_render_a_rev:{render_mode:02x}: vga={result:016x}")
    return result


def main() -> int:
    results = {mode: run_case(mode) for mode in EXPECTED}
    ok = results == EXPECTED
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": 105GDMCA 30E4 masked/nonzero modes match release bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
