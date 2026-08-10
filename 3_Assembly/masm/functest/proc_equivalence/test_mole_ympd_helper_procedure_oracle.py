#!/usr/bin/env python3
"""Exact release-byte procedure oracles for 207MOLE/208YMPD helpers."""

from __future__ import annotations

from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BP, UC_X86_REG_BX, UC_X86_REG_CS,
    UC_X86_REG_CX, UC_X86_REG_DI, UC_X86_REG_DS, UC_X86_REG_DX,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

MASM_ROOT = Path(__file__).resolve().parents[2]
MOLE = MASM_ROOT / "bin" / "zelres2" / "207MOLE.bin"
YMPD = MASM_ROOT / "bin" / "zelres2" / "208YMPD.bin"
CODE_SEG, DATA_SEG, STACK_SEG = 0x1000, 0x2000, 0x8000
RET = 0x7FF0

MCGA_UNPACK, MONO_SCAN, EXTRACT = 0x0315, 0x03E1, 0x0407
EGA_ROWS, PIXEL_CGA, COPY_28, PIXEL_CGA_ALT = 0x33BC, 0x3553, 0x3639, 0x389D


class Machine:
    def __init__(self) -> None:
        self.mu = Uc(UC_ARCH_X86, UC_MODE_16)
        self.mu.mem_map(0, 0x100000, UC_PROT_ALL)
        self.mu.mem_write(CODE_SEG << 4, MOLE.read_bytes()[4:])
        self.mu.mem_write((CODE_SEG << 4) + 0x3300, YMPD.read_bytes()[4:])
        self.mu.hook_add(UC_HOOK_CODE, self._stop)

    def _stop(self, uc: Uc, _address: int, _size: int, _user: object) -> None:
        if (uc.reg_read(UC_X86_REG_IP) & 0xFFFF) == RET:
            uc.emu_stop()

    def call(self, entry: int, **values: int) -> None:
        self.mu.reg_write(UC_X86_REG_CS, CODE_SEG)
        self.mu.reg_write(UC_X86_REG_DS, CODE_SEG)
        self.mu.reg_write(UC_X86_REG_ES, DATA_SEG)
        self.mu.reg_write(UC_X86_REG_SS, STACK_SEG)
        self.mu.reg_write(UC_X86_REG_SP, 0xFFFC)
        self.mu.mem_write((STACK_SEG << 4) + 0xFFFC, RET.to_bytes(2, "little"))
        regs = {"ax": UC_X86_REG_AX, "bx": UC_X86_REG_BX, "cx": UC_X86_REG_CX,
                "dx": UC_X86_REG_DX, "si": UC_X86_REG_SI, "di": UC_X86_REG_DI,
                "bp": UC_X86_REG_BP, "ds": UC_X86_REG_DS, "es": UC_X86_REG_ES}
        for name, value in values.items():
            self.mu.reg_write(regs[name], value)
        self.mu.emu_start((CODE_SEG << 4) + entry, 0, count=1_000_000)

    def reg(self, reg: int) -> int:
        return self.mu.reg_read(reg) & 0xFFFF

    def read(self, seg: int, off: int, size: int) -> bytes:
        return bytes(self.mu.mem_read((seg << 4) + off, size))

    def write(self, seg: int, off: int, data: bytes) -> None:
        self.mu.mem_write((seg << 4) + off, data)


def expand_reference(dh: int, dl: int, lut: bytes) -> int:
    result = 0
    for _ in range(2):
        nibble = 0
        for source in ("h", "l", "h", "l"):
            if source == "h":
                bit, dh = (dh >> 7) & 1, (dh << 1) & 0xFF
            else:
                bit, dl = (dl >> 7) & 1, (dl << 1) & 0xFF
            nibble = ((nibble << 1) | bit) & 0x0F
        result = ((result << 4) | lut[nibble]) & 0xFF
    return result


def extract_reference(value: int, dl: int, dh: int, lut: bytes) -> tuple[int, int]:
    if dl:
        return value, dl
    high, low = value >> 4, value & 0x0F
    merged = ((lut[high] << 4) | lut[low]) & 0xFF
    if high:
        return merged, dl
    return (value, 0xFF) if dh else (merged, dl)


def mole_helpers() -> bool:
    ok = True
    m = Machine()
    lut = m.read(CODE_SEG, 0x033E, 16)
    for dx in (0x0000, 0x1234, 0x80FF, 0xA55A, 0xFFFF):
        m.call(MCGA_UNPACK, dx=dx, bx=0xCAFE)
        ok &= (m.reg(UC_X86_REG_AX) & 0xFF) == expand_reference(dx >> 8, dx & 0xFF, lut)
        ok &= m.reg(UC_X86_REG_CX) == 0

    lut4 = m.read(CODE_SEG, 0x0444, 16)
    for value, dl, dh in ((0xA5, 0xFF, 0), (0xA5, 0, 0), (0x05, 0, 0),
                          (0x05, 0, 0xFF)):
        m.call(EXTRACT, ax=value, dx=(dh << 8) | dl)
        expected_al, expected_dl = extract_reference(value, dl, dh, lut4)
        ok &= (m.reg(UC_X86_REG_AX) & 0xFF) == expected_al
        ok &= (m.reg(UC_X86_REG_DX) & 0xFF) == expected_dl

    # Five rows of four bytes, with the CGA interlace/wrap address rule.
    start = 0x0100
    original = bytes((i * 13 + 7) & 0xFF for i in range(0x9000))
    m.write(DATA_SEG, 0, original)
    expected = bytearray(original)
    di, dl, dh = start, 0, 0xFF
    for _ in range(5):
        row = di
        dl = 0
        for _ in range(4):
            expected[di], dl = extract_reference(expected[di], dl, dh, lut4)
            di += 1
        di = row + 0x2000
        if di >= 0x8000:
            di = (di + 0x80A0) & 0xFFFF
    m.call(MONO_SCAN, es=DATA_SEG, di=start, dx=0xFF00)
    ok &= m.read(DATA_SEG, 0, len(expected)) == bytes(expected)
    ok &= m.reg(UC_X86_REG_DI) == di and m.reg(UC_X86_REG_CX) == 0
    return ok


def ympd_helpers() -> bool:
    ok = True
    m = Machine()
    # The fixed helper copies 88 rows of 56 bytes into 80-byte EGA strides.
    source = bytes((i * 29 + 3) & 0xFF for i in range(88 * 56))
    m.write(CODE_SEG, 0x6000, source)
    m.call(EGA_ROWS, si=0x6000, es=DATA_SEG)
    frame = m.read(DATA_SEG, 0, 0x2200)
    for row in range(88):
        off = 0x046C + row * 0x50
        ok &= frame[off:off + 56] == source[row * 56:(row + 1) * 56]
        ok &= frame[off + 56:off + 80] == bytes(24)
    ok &= m.reg(UC_X86_REG_SI) == 0x6000 + len(source)
    ok &= m.reg(UC_X86_REG_DI) == 0x046C + 88 * 0x50

    lut = m.read(CODE_SEG, 0x357D, 16)
    for dx in (0, 0x1234, 0xA55A, 0xFFFF):
        m.call(PIXEL_CGA, dx=dx)
        ok &= (m.reg(UC_X86_REG_AX) & 0xFF) == expand_reference(dx >> 8, dx & 0xFF, lut)

    payload = bytes(range(28))
    m.write(CODE_SEG, 0x7000, payload)
    m.call(COPY_28, si=0x7000, di=0x0200, es=DATA_SEG, cx=0xBEEF)
    ok &= m.read(DATA_SEG, 0x0200, 28) == payload
    ok &= m.reg(UC_X86_REG_SI) == 0x701C and m.reg(UC_X86_REG_DI) == 0x0200
    ok &= m.reg(UC_X86_REG_CX) == 0xBEEF

    for bp in (0x38C7, 0x38D7):
        alt_lut = m.read(CODE_SEG, bp, 16)
        for dx in (0, 0x1234, 0xA55A, 0xFFFF):
            m.call(PIXEL_CGA_ALT, dx=dx, bp=bp)
            ok &= (m.reg(UC_X86_REG_AX) & 0xFF) == expand_reference(
                dx >> 8, dx & 0xFF, alt_lut)
    return ok


def main() -> int:
    groups = {"207MOLE": mole_helpers(), "208YMPD": ympd_helpers()}
    for name, passed in groups.items():
        print(f"mole_ympd_helpers/{name}: {'PASS' if passed else 'FAIL'}")
    ok = all(groups.values())
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": seven executable non-MCGA helpers run from exact release bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
