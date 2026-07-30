#!/usr/bin/env python3
"""Release-MASM oracle for the fixed castle frame background renderers."""

import os
from pathlib import Path

from unicorn import (
    UC_ARCH_X86, UC_HOOK_CODE, UC_HOOK_MEM_WRITE, UC_MODE_16, UC_PROT_ALL, Uc,
)
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES,
    UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS,
)

MASM_ROOT = Path(__file__).resolve().parents[2]
MOLE_BIN = MASM_ROOT / "bin" / "zelres2" / "207MOLE.bin"
YMPD_BIN = MASM_ROOT / "bin" / "zelres2" / "208YMPD.bin"
CODE_SEG = 0x1000
STACK_SEG = 0x8000
RETURN_IP = 0x0080
EXPECTED_MOLE_FNV = 0xEF69F3CFFCC4FE6E
EXPECTED_COMBINED_FNV = 0x14093BAEA087B3AD
EXPECTED_SCRATCH_FNV = 0x7102E40B2CF1F6DF


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def execute_far_proc(mu: Uc, offset: int, ax: int) -> None:
    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_SP, 0xFFF8)
    mu.reg_write(UC_X86_REG_AX, ax)
    mu.mem_write((STACK_SEG << 4) + 0xFFF8,
                 bytes((RETURN_IP, 0, CODE_SEG & 0xFF, CODE_SEG >> 8)))

    def stop_before_retf(uc: Uc, address: int, _size: int, _user: object) -> None:
        if bytes(uc.mem_read(address, 1)) == b"\xcb":
            uc.emu_stop()

    hook = mu.hook_add(UC_HOOK_CODE, stop_before_retf)
    mu.emu_start((CODE_SEG << 4) + offset, 0, count=10_000_000)
    mu.hook_del(hook)


def main() -> int:
    if not MOLE_BIN.exists() or not YMPD_BIN.exists():
        print("VERDICT: INCONCLUSIVE: 207MOLE/208YMPD release binaries missing")
        return 0

    mole_data = MOLE_BIN.read_bytes()
    ympd_data = YMPD_BIN.read_bytes()
    if len(mole_data) < 5 or len(ympd_data) < 5:
        print("VERDICT: FAIL: fixed-frame release binary truncated")
        return 1

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    mu.mem_write(CODE_SEG << 4, mole_data[4:])
    mask_writes = []
    if os.environ.get("ZELIARD_TRACE_MASK"):
        def trace_mask(uc: Uc, _access: int, address: int, size: int,
                       value: int, _user: object) -> None:
            ip = uc.reg_read(UC_X86_REG_IP)
            if 0x038C <= ip <= 0x03D2 and 0xA0000 <= address < 0xB0000:
                mask_writes.append((ip, address - 0xA0000, size, value))

        mu.hook_add(UC_HOOK_MEM_WRITE, trace_mask)
    execute_far_proc(mu, 0, 4)
    mole_frame = bytes(mu.mem_read(0xA0000, 0x10000))

    mu.mem_write((CODE_SEG << 4) + 0x3300, ympd_data[4:])
    execute_far_proc(mu, 0x3300, 4)
    combined_frame = bytes(mu.mem_read(0xA0000, 0x10000))
    scratch = bytes(mu.mem_read((CODE_SEG + 0x1000) << 4, 0x4D00))

    if os.environ.get("ZELIARD_DUMP"):
        dump_dir = MASM_ROOT / "functest" / "build"
        dump_dir.mkdir(exist_ok=True)
        (dump_dir / "mole-frame.bin").write_bytes(mole_frame)
        (dump_dir / "mole-ympd-frame.bin").write_bytes(combined_frame)
    if mask_writes:
        for ip, address, size, value in mask_writes:
            print(f"mask_write ip={ip:04x} address={address:04x} "
                  f"size={size} value={value:02x}")

    hashes = (fnv1a64(mole_frame), fnv1a64(combined_frame), fnv1a64(scratch))
    expected = (EXPECTED_MOLE_FNV, EXPECTED_COMBINED_FNV, EXPECTED_SCRATCH_FNV)
    ok = hashes == expected
    print(f"mole_ympd_mcga_frame: {'PASS' if ok else 'FAIL'} "
          f"mole={hashes[0]:016x} combined={hashes[1]:016x} "
          f"scratch={hashes[2]:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM fixed castle frame background")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
