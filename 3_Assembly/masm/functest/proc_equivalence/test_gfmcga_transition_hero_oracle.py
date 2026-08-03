#!/usr/bin/env python3
"""Release-MASM oracle for shield-aware check_c3 hero composition."""

from __future__ import annotations

import struct
import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_BP, UC_X86_REG_CS, UC_X86_REG_CX, UC_X86_REG_DS,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

REPO_ROOT = MASM_ROOT.parents[1]
sys.path.insert(0, str(REPO_ROOT / "2_SAR" / "Tools"))
from decompress_sar import decompress_sar_chunk  # noqa: E402

BIN = MASM_ROOT / "working" / "zelres2" / "code" / "206GFMCA.bin"
FMAN = MASM_ROOT / "working" / "zelres3" / "data" / "351FMAN.grp"
CODE_SEG, STACK_SEG = 0x1000, 0x8000
RET_SENTINEL = 0x0080
ENTRY_PREPROCESS_FMAN = 0x4EDD
ENTRY_COMPOSE_HERO = 0x39A3
EXPECTED = {
    (0, 0): (0xBFC85115E00A5F6B, 0x51FB025D18001B0A,
             0xD7A6BC1D6AA4A904, 0x16A349B328945A09),
    (0, 1): (0x5748A2F80C4C6A9A, 0x0441ED68C8DF6678,
             0xD84C9852DA1E42D1, 0x0EE27763B99365B6),
    (1, 0): (0x4E8328D801C2F89B, 0x825EFEE9677010D6,
             0x51E81E55648CB3CB, 0xBD3D9913B19E7B82),
    (1, 1): (0x289B30DA7218A7C6, 0x486AAD227B69F1D2,
             0x6CE49FAD7D3C9070, 0x18BD73799858BB81),
}


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def call(mu: Uc, entry: int, registers: tuple[tuple[int, int], ...] = ()) -> None:
    mu.mem_write((STACK_SEG << 4) + 0xFFFC,
                 struct.pack("<H", RET_SENTINEL))
    for reg, value in (
        (UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
        (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_IP, entry),
        *registers,
    ):
        mu.reg_write(reg, value)

    def stop_on_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    hook = mu.hook_add(UC_HOOK_CODE, stop_on_return)
    try:
        mu.emu_start((CODE_SEG << 4) + entry, 0, count=20_000_000)
    finally:
        mu.hook_del(hook)
    assert mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL


def main() -> int:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    mu.mem_write((CODE_SEG << 4) + 0x2FFC, BIN.read_bytes())
    fman = bytes(decompress_sar_chunk(FMAN.read_bytes()))
    assert len(fman) == 8176
    mu.mem_write((CODE_SEG << 4) + 0x6000, fman)
    mu.mem_write((CODE_SEG << 4) + 0xFF2C,
                 struct.pack("<H", CODE_SEG))
    call(mu, ENTRY_PREPROCESS_FMAN, (
        (UC_X86_REG_SI, 0x6333), (UC_X86_REG_CX, 0xE6),
        (UC_X86_REG_BP, 0xD000),
    ))

    ok = True
    for facing, shield in EXPECTED:
        actual_cycle = []
        for pose in range(1, 5):
            mu.mem_write((CODE_SEG << 4) + 0x5000, bytes(0x400))
            state = {
                0x0083: 0, 0x0084: 0, 0x0092: 1, 0x0093: shield,
                0x00C2: facing, 0x00E7: pose, 0x00E8: 0,
                0xFF34: 0, 0xFF35: 0, 0xFF36: 0, 0xFF37: 0,
                0xFF38: 0, 0xFF39: 0, 0xFF3A: 0, 0xFF3D: 0,
                0xFF3F: 0, 0xFF40: 0, 0xFF41: 0, 0xFF42: 0,
            }
            for offset, value in state.items():
                mu.mem_write((CODE_SEG << 4) + offset, bytes((value,)))
            call(mu, ENTRY_COMPOSE_HERO)
            actual_cycle.append(fnv1a64(bytes(mu.mem_read(
                (CODE_SEG << 4) + 0x511D, 9 * 64))))
        actual = tuple(actual_cycle)
        case_ok = actual == EXPECTED[(facing, shield)]
        ok &= case_ok
        hashes = ", ".join(f"{value:016x}" for value in actual)
        print(f"gfmcga_transition_hero facing={facing} shield={shield}: "
              f"{'PASS' if case_ok else 'FAIL'} cycle=({hashes})")

    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM shield-aware check_c3 hero cells")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
