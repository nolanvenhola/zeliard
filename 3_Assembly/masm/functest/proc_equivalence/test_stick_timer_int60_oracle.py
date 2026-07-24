#!/usr/bin/env python3
"""Release-byte oracle for the timer ISR used by the opening's INT 60h call.

zeliad.asm installs stick.bin's timer entry at both INT 08h and INT 60h.
100OPDMO invokes INT 60h with AX=0/SI=3000h as a timer-service call; it is
not the overlay exchange.  This probe executes the installed release handler
with only its two far callback slots proxied, and records the state mutation
that the title path relies on.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS,
    UC_X86_REG_DS,
    UC_X86_REG_ES,
    UC_X86_REG_IP,
    UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT  # noqa: E402


STICK_BIN = MASM_ROOT / "bin" / "stick.bin"
CODE_SEG = 0x1000
STACK_SEG = 0x5000
STICK_LOAD_BASE = 0x0100
INT60_VECTOR_ENTRY = 0x0103
RET_SENTINEL = 0x0080
FAR_CALLBACK = 0x0800

GVAR_INPUT_FN = 0xFF0C
GVAR_GFX_FN = 0xFF10
GVAR_FRAME_TIMER = 0xFF1A
GVAR_ANIM_TIMER = 0xFF1B
GVAR_STATE_C = 0xFF1F
GVAR_FRAME_COUNT = 0xFF50
SUBSAMPLE_CTR = 0x02BC
CHAIN_INT_CTR = 0x02BD
FRAME_CTR8 = 0x02C4


def write_word(mu: Uc, offset: int, value: int) -> None:
    mu.mem_write((CODE_SEG << 4) + offset,
                 bytes((value & 0xFF, (value >> 8) & 0xFF)))


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, STACK_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + STICK_LOAD_BASE, STICK_BIN.read_bytes())

    # The release ISR calls the graphics and input callbacks before updating
    # its counters.  RETF stubs preserve that order without replacing ISR code.
    mu.mem_write((CODE_SEG << 4) + FAR_CALLBACK, b"\xCB")
    for slot in (GVAR_INPUT_FN, GVAR_GFX_FN):
        write_word(mu, slot, FAR_CALLBACK)
        write_word(mu, slot + 2, CODE_SEG)
    write_word(mu, GVAR_STATE_C, 0)
    mu.mem_write((CODE_SEG << 4) + GVAR_FRAME_TIMER, b"\x00")
    write_word(mu, GVAR_ANIM_TIMER, 0x1234)
    write_word(mu, GVAR_FRAME_COUNT, 0xFFFE)
    mu.mem_write((CODE_SEG << 4) + SUBSAMPLE_CTR, b"\x02")
    mu.mem_write((CODE_SEG << 4) + CHAIN_INT_CTR, b"\x02")
    mu.mem_write((CODE_SEG << 4) + FRAME_CTR8, b"\x00")

    # Model the hardware INT stack frame: IRET pops IP, CS, then FLAGS.
    initial_sp = 0xFFF8
    write_stack = (STACK_SEG << 4) + initial_sp
    mu.mem_write(write_stack, bytes((RET_SENTINEL, 0, CODE_SEG & 0xFF,
                                     CODE_SEG >> 8, 0x02, 0x02)))
    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_SP, initial_sp)

    callbacks = 0

    def stop_after_iret(uc, _address, _size, _user):
        nonlocal callbacks
        ip = uc.reg_read(UC_X86_REG_IP) & 0xFFFF
        if ip == FAR_CALLBACK:
            callbacks += 1
        if ip == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_after_iret)
    mu.emu_start((CODE_SEG << 4) + INT60_VECTOR_ENTRY, 0)

    def byte_at(offset: int) -> int:
        return mu.mem_read((CODE_SEG << 4) + offset, 1)[0]

    def word_at(offset: int) -> int:
        raw = mu.mem_read((CODE_SEG << 4) + offset, 2)
        return raw[0] | (raw[1] << 8)

    ok = (
        callbacks == 2 and
        byte_at(GVAR_FRAME_TIMER) == 1 and
        word_at(GVAR_ANIM_TIMER) == 0x1235 and
        word_at(GVAR_FRAME_COUNT) == 0xFFFF and
        byte_at(SUBSAMPLE_CTR) == 1 and
        byte_at(CHAIN_INT_CTR) == 1 and
        byte_at(FRAME_CTR8) == 1 and
        (mu.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET_SENTINEL and
        (mu.reg_read(UC_X86_REG_SP) & 0xFFFF) == 0xFFFE
    )
    print("stick_int60_timer_vector: " + ("PASS" if ok else "FAIL") +
          f" callbacks={callbacks} frame={byte_at(GVAR_FRAME_TIMER):02x}"
          f" anim={word_at(GVAR_ANIM_TIMER):04x}"
          f" count={word_at(GVAR_FRAME_COUNT):04x}"
          f" ip={mu.reg_read(UC_X86_REG_IP) & 0xFFFF:04x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": INT 60h title timer vector matches release stick.bin ISR")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
