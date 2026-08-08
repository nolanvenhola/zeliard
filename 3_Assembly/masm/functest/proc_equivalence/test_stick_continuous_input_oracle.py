#!/usr/bin/env python3
"""Release-byte oracle for stick.asm continuous keyboard state.

Executes process_scancode, handle_pause_key, and handle_special_keys from the
bit-perfect release stick.bin. Hardware callbacks are outside this probe; the
observable contract is the resident input bytes shared with game code.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_HOOK_INTR, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AL, UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES,
    UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402


CODE_SEG = 0x1000
STACK_SEG = 0x5000
LOAD_BASE = 0x0100
RET_SENTINEL = 0x0080

# Runtime addresses in the release image, pinned by the bit-perfect bytes.
PROCESS_SCANCODE = 0x0326
HANDLE_PAUSE_KEY = 0x0122
HANDLE_SPECIAL_KEYS = 0x01E3

PAUSE_LATCH = 0x02BE
MUSIC_LATCH = 0x02C2
SFX_LATCH = 0x02C3
DIR_LO = 0x05C1
SKIP_FLAG = 0xFF16
INPUT_DIRECTION = 0xFF17
TIMER_COUNTER = 0xFF18
SPACE_ACTION = 0xFF1D
SOUND_FLAG = 0xFF27
ASCII_ACTION = 0xFF29
VOLUME_B = 0xFF75


class StickMachine:
    def __init__(self) -> None:
        binary = MASM_ROOT / "bin" / "stick.bin"
        if not binary.exists():
            binary = MASM_ROOT.parent.parent / "1_OriginalGame" / "stick.bin"
        self.mu = Uc(UC_ARCH_X86, UC_MODE_16)
        for seg in (CODE_SEG, STACK_SEG):
            self.mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
        self.mu.mem_write(CODE_SEG << 4, bytes(0x10000))
        self.mu.mem_write((CODE_SEG << 4) + LOAD_BASE, binary.read_bytes())
        self.mu.reg_write(UC_X86_REG_CS, CODE_SEG)
        self.mu.reg_write(UC_X86_REG_DS, CODE_SEG)
        self.mu.reg_write(UC_X86_REG_ES, CODE_SEG)
        self.mu.reg_write(UC_X86_REG_SS, STACK_SEG)
        self.interrupts: list[int] = []
        self.mu.hook_add(UC_HOOK_INTR, self._interrupt)
        self.mu.hook_add(UC_HOOK_CODE, self._stop_at_sentinel)

    def _interrupt(self, _uc: Uc, number: int, _user: object) -> None:
        self.interrupts.append(number)

    def _stop_at_sentinel(self, uc: Uc, _addr: int, _size: int,
                          _user: object) -> None:
        if (uc.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET_SENTINEL:
            uc.emu_stop()

    def call(self, entry: int, al: int | None = None) -> None:
        sp = 0xFFFC
        self.mu.mem_write((STACK_SEG << 4) + sp,
                          bytes((RET_SENTINEL, 0)))
        self.mu.reg_write(UC_X86_REG_SP, sp)
        if al is not None:
            self.mu.reg_write(UC_X86_REG_AL, al)
        self.mu.emu_start((CODE_SEG << 4) + entry,
                          (CODE_SEG << 4) + 0xFFFF)

    def byte(self, off: int) -> int:
        return self.mu.mem_read((CODE_SEG << 4) + off, 1)[0]

    def word(self, off: int) -> int:
        raw = self.mu.mem_read((CODE_SEG << 4) + off, 2)
        return raw[0] | (raw[1] << 8)

    def set_byte(self, off: int, value: int) -> None:
        self.mu.mem_write((CODE_SEG << 4) + off, bytes((value,)))


def main() -> int:
    m = StickMachine()
    ok = True

    # Enhanced-key E0 prefix suppresses ASCII translation; make/break updates
    # the held direction immediately and leaves it stable between timer polls.
    m.call(PROCESS_SCANCODE, 0xE0)
    m.call(PROCESS_SCANCODE, 0x4D)
    ok &= m.byte(DIR_LO) == 8 and m.byte(INPUT_DIRECTION) == 8
    m.call(PROCESS_SCANCODE, 0xE0)
    m.call(PROCESS_SCANCODE, 0xCD)
    ok &= m.byte(DIR_LO) == 0 and m.byte(INPUT_DIRECTION) == 0

    # Enter is an immediate ASCII action and its timer bit is level-held.
    m.call(PROCESS_SCANCODE, 0x1C)
    ok &= m.byte(ASCII_ACTION) == 0x0D and m.word(TIMER_COUNTER) == 1
    m.call(PROCESS_SCANCODE, 0x9C)
    ok &= m.byte(ASCII_ACTION) == 0x0D and m.word(TIMER_COUNTER) == 0

    # The sampled Space edge is armed while released, then emitted on press.
    m.call(HANDLE_PAUSE_KEY)
    ok &= m.byte(PAUSE_LATCH) == 0xFF
    m.call(PROCESS_SCANCODE, 0x39)
    m.call(HANDLE_PAUSE_KEY)
    ok &= (m.byte(SKIP_FLAG) == 1 and m.byte(SPACE_ACTION) == 0xFF and
           m.byte(PAUSE_LATCH) == 0)
    m.call(PROCESS_SCANCODE, 0xB9)
    m.call(HANDLE_PAUSE_KEY)
    ok &= m.byte(SKIP_FLAG) == 0 and m.byte(PAUSE_LATCH) == 0xFF

    # F1/F2 are one-shot sampled latches and require an exact timer word.
    m.call(HANDLE_SPECIAL_KEYS)
    ok &= m.byte(MUSIC_LATCH) == 0xFF and m.byte(SFX_LATCH) == 0xFF
    m.call(PROCESS_SCANCODE, 0x3B)
    m.call(HANDLE_SPECIAL_KEYS)
    ok &= (m.byte(MUSIC_LATCH) == 0 and m.byte(VOLUME_B) == 1 and
           m.interrupts == [0x60])
    m.call(PROCESS_SCANCODE, 0xBB)
    m.call(HANDLE_SPECIAL_KEYS)
    ok &= m.byte(MUSIC_LATCH) == 0xFF

    m.set_byte(SOUND_FLAG, 0xFF)
    m.call(PROCESS_SCANCODE, 0x3C)
    m.call(HANDLE_SPECIAL_KEYS)
    ok &= m.byte(SFX_LATCH) == 0 and m.byte(SOUND_FLAG) == 0
    m.call(PROCESS_SCANCODE, 0xBC)
    m.call(HANDLE_SPECIAL_KEYS)
    ok &= m.byte(SFX_LATCH) == 0xFF

    # F9 is a level-held 8000h timer bit.  The game loops dispatch the
    # resident speed_change_handler while it is set, then wait for release.
    m.call(PROCESS_SCANCODE, 0x43)
    ok &= m.word(TIMER_COUNTER) == 0x8000
    m.call(PROCESS_SCANCODE, 0xC3)
    ok &= m.word(TIMER_COUNTER) == 0

    print("stick_continuous_input: " + ("PASS" if ok else "FAIL") +
          f" dir={m.byte(INPUT_DIRECTION):02x} skip={m.byte(SKIP_FLAG):02x}" +
          f" timer={m.word(TIMER_COUNTER):04x} ascii={m.byte(ASCII_ACTION):02x}" +
          f" music={m.byte(MUSIC_LATCH):02x} sfx={m.byte(SFX_LATCH):02x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": stick.asm make/break and sampled key latches")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
