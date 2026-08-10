#!/usr/bin/env python3
"""Direct release-byte oracles for the remaining stick.asm procedures."""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import (UC_ARCH_X86, UC_HOOK_CODE, UC_HOOK_INSN, UC_HOOK_INTR,
                     UC_MODE_16, UC_PROT_ALL, Uc)
from unicorn.x86_const import (
    UC_X86_INS_IN, UC_X86_INS_OUT, UC_X86_REG_AL, UC_X86_REG_AX,
    UC_X86_REG_BP, UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX,
    UC_X86_REG_DI, UC_X86_REG_DS, UC_X86_REG_DX, UC_X86_REG_EFLAGS,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

CODE_SEG, DATA_SEG, STACK_SEG = 0x1000, 0x3000, 0x5000
LOAD_BASE, RET_SENTINEL = 0x0100, 0x0080

POLL, DECODE = 0x017C, 0x0197
CALIBRATE, DEADZONE = 0x05CA, 0x0630
FIO_OPEN, FIO_RW, FIO_CLOSE, FIO_DECOMP = 0x0C42, 0x0D84, 0x0D93, 0x0DAD
ANCHOR_A, ANCHOR_B, ANCHOR_C = 0x0DE0, 0x0E43, 0x0ECF

BTN_A, BTN_B = 0x02C0, 0x02C1
JOY_X, JOY_Y = 0x04C6, 0x04C8
SAVE_DESC, READ_BUF, READ_COUNT, SECTOR_PTR = 0x0F5C, 0x0F60, 0x0F64, 0x0F66
DISPATCH = 0x0CBC
LAST_KEY, SPACE, STATE_B = 0xFF0A, 0xFF1D, 0xFF1E
MUSIC, JOY_DIR, JOY_BUTTONS, DISK_SUPPRESS = 0xFF3B, 0xFF48, 0xFF49, 0xFF78


class Machine:
    def __init__(self, port_values: list[int] | None = None,
                 int21_results: list[tuple[int, bool, bytes]] | None = None) -> None:
        binary = MASM_ROOT / "bin" / "stick.bin"
        if not binary.exists():
            binary = MASM_ROOT.parent.parent / "1_OriginalGame" / "stick.bin"
        self.mu = Uc(UC_ARCH_X86, UC_MODE_16)
        for seg in (CODE_SEG, DATA_SEG, STACK_SEG):
            self.mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
        self.mu.mem_write((CODE_SEG << 4) + LOAD_BASE, binary.read_bytes())
        for reg, value in ((UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, DATA_SEG),
                           (UC_X86_REG_ES, DATA_SEG), (UC_X86_REG_SS, STACK_SEG)):
            self.mu.reg_write(reg, value)
        self.port_values = list(port_values or [])
        self.port_reads: list[int] = []
        self.port_writes: list[tuple[int, int, int]] = []
        self.int21_results = list(int21_results or [])
        self.int21_calls: list[tuple[int, int, int, int]] = []
        self.stop_ips: set[int] = {RET_SENTINEL}
        self.mu.hook_add(UC_HOOK_CODE, self._code)
        self.mu.hook_add(UC_HOOK_INTR, self._interrupt)
        self.mu.hook_add(UC_HOOK_INSN, self._in, None, 1, 0, UC_X86_INS_IN)
        self.mu.hook_add(UC_HOOK_INSN, self._out, None, 1, 0, UC_X86_INS_OUT)

    def _code(self, uc: Uc, _addr: int, _size: int, _user: object) -> None:
        if (uc.reg_read(UC_X86_REG_IP) & 0xFFFF) in self.stop_ips:
            uc.emu_stop()

    def _in(self, _uc: Uc, port: int, _size: int, _user: object) -> int:
        self.port_reads.append(port)
        return self.port_values.pop(0) if self.port_values else 0

    def _out(self, _uc: Uc, port: int, size: int, value: int,
             _user: object) -> None:
        self.port_writes.append((port, size, value))

    def _interrupt(self, uc: Uc, number: int, _user: object) -> None:
        if number != 0x21:
            raise AssertionError(f"unexpected interrupt {number:02x}")
        ax, bx, cx, dx = (uc.reg_read(r) & 0xFFFF for r in
                          (UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CX, UC_X86_REG_DX))
        self.int21_calls.append((ax, bx, cx, dx))
        result, carry, payload = self.int21_results.pop(0)
        if payload:
            ds = uc.reg_read(UC_X86_REG_DS) & 0xFFFF
            uc.mem_write((ds << 4) + dx, payload)
        uc.reg_write(UC_X86_REG_AX, result)
        flags = uc.reg_read(UC_X86_REG_EFLAGS)
        uc.reg_write(UC_X86_REG_EFLAGS, (flags | 1) if carry else (flags & ~1))

    def call(self, entry: int, **regs: int) -> None:
        sp = 0xFFFC
        self.mu.mem_write((STACK_SEG << 4) + sp, RET_SENTINEL.to_bytes(2, "little"))
        self.mu.reg_write(UC_X86_REG_SP, sp)
        regmap = {"ax": UC_X86_REG_AX, "bx": UC_X86_REG_BX, "cx": UC_X86_REG_CX,
                  "dx": UC_X86_REG_DX, "si": UC_X86_REG_SI, "di": UC_X86_REG_DI,
                  "bp": UC_X86_REG_BP, "ds": UC_X86_REG_DS, "es": UC_X86_REG_ES,
                  "al": UC_X86_REG_AL}
        for name, value in regs.items():
            self.mu.reg_write(regmap[name], value)
        self.mu.emu_start((CODE_SEG << 4) + entry, (CODE_SEG << 4) + 0xFFFF,
                          count=100000)

    def reg(self, reg: int) -> int:
        return self.mu.reg_read(reg) & 0xFFFF

    def byte(self, off: int, seg: int = CODE_SEG) -> int:
        return self.mu.mem_read((seg << 4) + off, 1)[0]

    def word(self, off: int, seg: int = CODE_SEG) -> int:
        return int.from_bytes(self.mu.mem_read((seg << 4) + off, 2), "little")

    def put(self, off: int, data: bytes, seg: int = CODE_SEG) -> None:
        self.mu.mem_write((seg << 4) + off, data)

    def put_word(self, off: int, value: int, seg: int = CODE_SEG) -> None:
        self.put(off, value.to_bytes(2, "little"), seg)

    def put_far(self, off: int, ptr_off: int, ptr_seg: int) -> None:
        self.put(off, ptr_off.to_bytes(2, "little") + ptr_seg.to_bytes(2, "little"))


def joystick_oracles() -> bool:
    ok = True
    m = Machine()
    m.call(DECODE, al=0x10)
    ok &= m.byte(BTN_A) == 0xFF and m.byte(SPACE) == 0
    m.call(DECODE, al=0)
    ok &= m.byte(BTN_A) == 0 and m.byte(SPACE) == 0xFF

    gated = Machine([0x30])
    gated.call(POLL)
    ok &= not gated.port_reads
    gated.put(MUSIC, b"\xff"); gated.put(LAST_KEY, b"\xff")
    gated.call(POLL)
    ok &= gated.byte(BTN_A) == 0xFF and gated.byte(BTN_B) == 0xFF
    gated.port_values.append(0)
    gated.call(POLL)
    ok &= gated.byte(SPACE) == 0xFF and gated.byte(STATE_B) == 0xFF

    cal = Machine([3, 3, 3, 0])
    cal.call(CALIBRATE)
    ok &= cal.reg(UC_X86_REG_SI) == 2 and cal.reg(UC_X86_REG_DI) == 2
    ok &= cal.port_writes and all(p == 0x201 for p in cal.port_reads)

    # Replace only the called calibration dependency; DEADZONE itself remains
    # byte-for-byte release code. mov si,40; mov di,5; ret.
    dz = Machine([0xCF])
    dz.put(CALIBRATE, bytes((0xBE, 40, 0, 0xBF, 5, 0, 0xC3)))
    dz.put_word(JOY_X, 20); dz.put_word(JOY_Y, 20)
    dz.call(DEADZONE)
    ok &= dz.byte(JOY_DIR) == 8 and dz.byte(JOY_BUTTONS) == 3
    return ok


def file_oracles() -> bool:
    ok = True
    rw = Machine(int21_results=[(4, False, b"DATA")])
    rw.put_far(READ_BUF, 0x0200, DATA_SEG)
    rw.call(FIO_RW, bx=7, cx=4)
    ok &= rw.int21_calls == [(0x3F00, 7, 4, 0x0200)]
    ok &= bytes(rw.mu.mem_read((DATA_SEG << 4) + 0x0200, 4)) == b"DATA"

    close = Machine(int21_results=[(0, False, b"")])
    close.call(FIO_CLOSE, bx=7)
    ok &= close.int21_calls == [(0x3E00, 7, 0, 0)]

    direct = Machine(int21_results=[(9, False, b"")])
    direct.put(0x0100, b"\x00\x00SAVE.USR\x00", DATA_SEG)
    direct.put_far(SAVE_DESC, 0x0100, DATA_SEG)
    direct.call(FIO_OPEN)
    ok &= direct.reg(UC_X86_REG_AX) == 9 and direct.word(READ_COUNT) == 0xFFFF
    ok &= [x[0] >> 8 for x in direct.int21_calls] == [0x3D]

    slot = Machine(int21_results=[
        (9, False, b""), (0, False, b""), (4, False, b"\x34\x12\x00\x00"),
        (0, False, b""), (4, False, b"\x78\x56\x9a\xbc")])
    slot.put(0x0100, b"\x00\x02SAVE.USR\x00", DATA_SEG)
    slot.put_far(SAVE_DESC, 0x0100, DATA_SEG)
    slot.call(FIO_OPEN)
    ok &= [x[0] >> 8 for x in slot.int21_calls] == [0x3D, 0x42, 0x3F, 0x42, 0x3F]
    ok &= slot.word(READ_COUNT) == 0x5678 and slot.word(SECTOR_PTR) == 0xBC9A

    declined = Machine(int21_results=[(2, True, b""), (0, False, b""),
                                      (0, False, b"")])
    declined.put(0x0100, b"\x00\x00SAVE.USR\x00", DATA_SEG)
    declined.put_far(SAVE_DESC, 0x0100, DATA_SEG)
    declined.put(DISK_SUPPRESS, b"\xff")
    declined.call(FIO_OPEN)
    ok &= [x[0] >> 8 for x in declined.int21_calls] == [0x3D, 0x0D, 0x10]
    ok &= bool(declined.reg(UC_X86_REG_EFLAGS) & 1)
    return ok


def decompressor_oracles() -> bool:
    ok = True
    base = Machine()
    # The resident driver is entered at +100h, while this CS-relative table
    # operand retains its pre-load address. Mirror the release table at that
    # address exactly as the DOS loader's resident image presents it.
    table_bytes = bytes(base.mu.mem_read((CODE_SEG << 4) + DISPATCH + LOAD_BASE, 16))
    base.put(DISPATCH, table_bytes)
    targets = [base.word(DISPATCH + 2 * i) for i in range(8)]
    for opcode, target in enumerate(targets):
        m = Machine()
        m.put(DISPATCH, table_bytes)
        m.put(0x0200, bytes((0xA8 | opcode,)), DATA_SEG)
        m.stop_ips.add(target)
        m.call(FIO_DECOMP, ds=DATA_SEG, si=0x0200, dx=9)
        ok &= (m.reg(UC_X86_REG_IP) == target and m.reg(UC_X86_REG_BX) == opcode * 2
               and m.reg(UC_X86_REG_SI) == 0x0201 and m.reg(UC_X86_REG_DX) == 8)

    a = Machine(); a.put(0x0300, b"\xa0\x55\x01\x00", DATA_SEG)
    a.call(ANCHOR_A, ds=DATA_SEG, bp=0x0300, al=0xA3)
    ok &= a.reg(UC_X86_REG_CX) == 5 and (a.reg(UC_X86_REG_AX) & 0xFF) == 0x55
    am = Machine(); am.put(0x0300, b"\x01\x00", DATA_SEG)
    am.call(ANCHOR_A, ds=DATA_SEG, bp=0x0300, al=0xA3)
    ok &= am.reg(UC_X86_REG_CX) == 1 and (am.reg(UC_X86_REG_AX) & 0xFF) == 0xA3

    b = Machine(); b.put(0x0300, b"\x03\x66\xf0\x00", DATA_SEG)
    b.call(ANCHOR_B, ds=DATA_SEG, bp=0x0300, al=0x43)
    ok &= b.reg(UC_X86_REG_CX) == 6 and (b.reg(UC_X86_REG_AX) & 0xFF) == 0x66
    bm = Machine(); bm.put(0x0300, b"\xf0\x00", DATA_SEG)
    bm.call(ANCHOR_B, ds=DATA_SEG, bp=0x0300, al=0x43)
    ok &= bm.reg(UC_X86_REG_CX) == 1 and (bm.reg(UC_X86_REG_AX) & 0xFF) == 0x43

    c = Machine(); c.put(0x0300, b"\x44\x77\xff\xff", DATA_SEG)
    c.put(0x0400, b"\x05", DATA_SEG)
    c.call(ANCHOR_C, ds=DATA_SEG, bp=0x0300, si=0x0400, dx=9, al=0x44)
    ok &= c.reg(UC_X86_REG_CX) == 7 and (c.reg(UC_X86_REG_AX) & 0xFF) == 0x77
    ok &= c.reg(UC_X86_REG_SI) == 0x0401 and c.reg(UC_X86_REG_DX) == 8
    cm = Machine(); cm.put(0x0300, b"\xff\xff", DATA_SEG)
    cm.call(ANCHOR_C, ds=DATA_SEG, bp=0x0300, si=0x0400, dx=9, al=0x44)
    ok &= cm.reg(UC_X86_REG_CX) == 1 and (cm.reg(UC_X86_REG_AX) & 0xFF) == 0x44
    return ok


def main() -> int:
    groups = {"joystick": joystick_oracles(), "file_io": file_oracles(),
              "decompressor": decompressor_oracles()}
    for name, passed in groups.items():
        print(f"stick_remaining/{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(groups.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": 11 stick.asm procedures execute from release bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
