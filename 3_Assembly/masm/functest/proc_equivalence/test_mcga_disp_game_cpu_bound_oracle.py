#!/usr/bin/env python3
"""Release-MASM contract for OPDMO's HOU disp_game call.

100OPDMO calls CS:[3010] with BX=2048h/CX=1040h/DI=75A0h after the
NEC GFX_BLIT.  In the MCGA release driver that dispatch target is 33B7h.
It is CPU-bound decode/copy work: unlike run_render_passes_mcga it must not
poll or reset gvar_frame_timer.  This distinction prevents the C timeline
from turning the direct call into an invented timed render transition.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import (UC_ARCH_X86, UC_HOOK_CODE, UC_HOOK_MEM_READ,
                     UC_HOOK_MEM_WRITE, UC_MODE_16, UC_PROT_ALL, Uc)
from unicorn.x86_const import (UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX,
                                UC_X86_REG_DI, UC_X86_REG_DS, UC_X86_REG_ES,
                                UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT  # noqa: E402


GDMCA = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
CODE, WORK, STACK, VGA = 0x1000, 0x4000, 0x5000, 0xA000
LOAD_BASE, ENTRY, RET_SENTINEL = 0x2FFC, 0x33B7, 0x0080
FRAME_TIMER = 0xFF1A
EXPECTED_INSTRUCTIONS = 94766


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for base in (0, CODE << 4, WORK << 4, STACK << 4, VGA << 4):
        mu.mem_map(base, 0x10000, UC_PROT_ALL)
    mu.mem_write(CODE << 4, bytes(0x10000))
    mu.mem_write((CODE << 4) + LOAD_BASE, GDMCA.read_bytes())

    mu.reg_write(UC_X86_REG_CS, CODE)
    mu.reg_write(UC_X86_REG_DS, CODE)
    mu.reg_write(UC_X86_REG_ES, CODE)
    mu.reg_write(UC_X86_REG_SS, STACK)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.mem_write((STACK << 4) + 0xFFFC, bytes((RET_SENTINEL, 0)))
    mu.reg_write(UC_X86_REG_BX, 0x2048)
    mu.reg_write(UC_X86_REG_CX, 0x1040)
    mu.reg_write(UC_X86_REG_DI, 0x75A0)

    instructions = 0
    timer_reads = 0
    timer_writes = 0
    timer_address = (CODE << 4) + FRAME_TIMER

    def on_code(uc, _address, _size, _user):
        nonlocal instructions
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()
        else:
            instructions += 1

    def on_read(_uc, _access, address, _size, _value, _user):
        nonlocal timer_reads
        if address == timer_address:
            timer_reads += 1

    def on_write(_uc, _access, address, _size, _value, _user):
        nonlocal timer_writes
        if address == timer_address:
            timer_writes += 1

    mu.hook_add(UC_HOOK_CODE, on_code)
    mu.hook_add(UC_HOOK_MEM_READ, on_read)
    mu.hook_add(UC_HOOK_MEM_WRITE, on_write)
    mu.emu_start((CODE << 4) + ENTRY, 0, count=2_000_000)

    ok = (mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL and
          instructions == EXPECTED_INSTRUCTIONS and
          timer_reads == 0 and timer_writes == 0)
    print("mcga_disp_game_cpu_bound: " + ("PASS" if ok else "FAIL") +
          f" instructions={instructions} timer_reads={timer_reads} "
          f"timer_writes={timer_writes}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": 105GDMCA:33B7 is CPU-bound, not a frame-timer wait")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
