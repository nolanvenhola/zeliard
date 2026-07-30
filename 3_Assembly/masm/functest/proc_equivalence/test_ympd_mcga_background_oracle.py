#!/usr/bin/env python3
"""Release-MASM oracle for the 208YMPD MCGA background renderer."""

from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES,
    UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS,
)

MASM_ROOT = Path(__file__).resolve().parents[2]
BIN = MASM_ROOT / "bin" / "zelres2" / "208YMPD.bin"
CODE_SEG = 0x1000
STACK_SEG = 0x8000
LOAD_OFFSET = 0x3300
RETURN_IP = 0x0080
EXPECTED_VGA_FNV = 0x9FB90E4C7DD0A3A6
EXPECTED_SCRATCH_FNV = 0x7102E40B2CF1F6DF


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def main() -> int:
    if not BIN.exists():
        print("VERDICT: INCONCLUSIVE: 208YMPD release binary missing")
        return 0

    file_data = BIN.read_bytes()
    if len(file_data) < 5:
        print("VERDICT: FAIL: 208YMPD release binary truncated")
        return 1

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    # The SAR service strips the four-byte size header before loading at 3300h.
    mu.mem_write((CODE_SEG << 4) + LOAD_OFFSET, file_data[4:])
    for register, value in (
        (UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
        (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFF8), (UC_X86_REG_AX, 4),
    ):
        mu.reg_write(register, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFF8,
                 bytes((RETURN_IP, 0, CODE_SEG & 0xFF, CODE_SEG >> 8)))

    def stop_before_retf(uc: Uc, address: int, _size: int, _user: object) -> None:
        if bytes(uc.mem_read(address, 1)) == b"\xcb":
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_before_retf)
    mu.emu_start((CODE_SEG << 4) + LOAD_OFFSET, 0, count=10_000_000)

    vga = bytes(mu.mem_read(0xA0000, 0x10000))
    scratch = bytes(mu.mem_read((CODE_SEG + 0x1000) << 4, 0x4D00))
    vga_hash = fnv1a64(vga)
    scratch_hash = fnv1a64(scratch)
    ok = (vga_hash, scratch_hash) == (EXPECTED_VGA_FNV, EXPECTED_SCRATCH_FNV)
    print(f"ympd_mcga_background: {'PASS' if ok else 'FAIL'} "
          f"vga={vga_hash:016x} scratch={scratch_hash:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM 208YMPD MCGA background")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
