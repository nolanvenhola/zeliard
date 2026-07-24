#!/usr/bin/env python3
"""Capture the real 105GDMCA sprite-frame DAC write boundaries.

This is deliberately lower-level than a screenshot: it enters the released
sprite-object driver with the real 100OPDMO NEC fixture, executes through the
nine sprite palette updates, and records the instruction ordinal at each
palette transaction.  A host scanout model can consume these boundaries
without inventing scene-specific bands.
"""

from __future__ import annotations

import hashlib
import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_HOOK_INSN, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_INS_IN, UC_X86_INS_OUT, UC_X86_REG_CS, UC_X86_REG_DS,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402


GDMCA = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
OPDMO = MASM_ROOT / "bin" / "zelres1" / "100OPDMO.bin"
CODE, WORK, STACK, VGA = 0x1000, 0x4000, 0x5000, 0xA000
GDMCA_LOAD_BASE, OPDMO_LOAD_BASE = 0x2FFC, 0x6000
ENTRY = 0x3437
SCENE_NEC = 0x9060
PALETTE_WRITES = 9 * 256

# Updated only when the released MASM bytes or the intended fixture changes.
EXPECTED_BOUNDARIES_SHA256 = "e9acd1465bce2105188f63e8dd9cb984cf070623be088055843f9a1ae4f09148"
EXPECTED_SLOT_DAC_SHA256 = (
    "839639ee91b09393c8bfe0beb24542c90a9f3f9441103faa708877833e6d1dbf",
    "30206f54ef699d857412d6fded118fc2febcf05fc0ee08b02392194c32881ae3",
    "a4c3ffd31abd9d0c681ecff492f9f682732bf8b48a92f716f77efbcf703c5fd5",
    "8cfa09f4636ddc7beecbcc3a46301e07fa151478e6cecdd303b9c45fa652d9be",
    "93e6c65cf4d4316f5b75007eba6b96a1fa662f73a89c113f9bb3230fb8bfae00",
    "584a67d7cd1d48ee9057c9c6d4b0afd93723389dddfc79717ec02db866855d47",
    "1afacfa1984174ad7a8ee0a9116c7da807d204421c57f37caa18fe8efdd71872",
    "5035ae0d0ea0edbd21adc3420a279f77071671a136424c7b3b00ccde11ee369d",
    "839639ee91b09393c8bfe0beb24542c90a9f3f9441103faa708877833e6d1dbf",
)


def capture_boundaries() -> tuple[list[int], list[int]]:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for base in (0, CODE << 4, WORK << 4, STACK << 4, VGA << 4):
        mu.mem_map(base, 0x10000, UC_PROT_ALL)
    mu.mem_write(CODE << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE << 4) + GDMCA_LOAD_BASE, GDMCA.read_bytes())
    # The opener chunk is loaded after its four-byte SAR header is stripped.
    mu.mem_write((CODE << 4) + OPDMO_LOAD_BASE, OPDMO.read_bytes()[4:])
    # BIOS data area: 40:63 points at CRT controller 3D4h -> status 3DAh.
    mu.mem_write((0x40 << 4) + 0x63, bytes([0xD4, 0x03]))
    # In the full game this holds the resident game segment.  The oracle
    # co-locates it with the reconstructed code/data image.
    mu.mem_write((CODE << 4) + 0xFF2C, bytes([CODE & 0xFF, CODE >> 8]))

    mu.reg_write(UC_X86_REG_CS, CODE)
    mu.reg_write(UC_X86_REG_DS, CODE)
    mu.reg_write(UC_X86_REG_ES, CODE)
    mu.reg_write(UC_X86_REG_SS, STACK)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.reg_write(UC_X86_REG_SI, SCENE_NEC)

    instructions = 0
    index_writes = 0
    boundaries: list[int] = []
    components: list[int] = []

    def hook_code(_uc, _address, _size, _user):
        nonlocal instructions
        instructions += 1

    def hook_out(uc, port, _size, value, _user):
        nonlocal index_writes
        if port == 0x3C8:
            if index_writes % 256 == 0:
                boundaries.append(instructions)
            index_writes += 1
            return
        if port == 0x3C9:
            components.append(value & 0xFF)
            if len(components) == PALETTE_WRITES * 3:
                uc.emu_stop()

    def hook_in(_uc, _port, _size, _user):
        return 0

    mu.hook_add(UC_HOOK_CODE, hook_code)
    mu.hook_add(UC_HOOK_INSN, hook_out, None, 1, 0, UC_X86_INS_OUT)
    mu.hook_add(UC_HOOK_INSN, hook_in, None, 1, 0, UC_X86_INS_IN)
    mu.emu_start((CODE << 4) + ENTRY, 0, count=2_000_000)

    if index_writes != PALETTE_WRITES:
        raise RuntimeError(f"stopped after {index_writes} palette indices, expected {PALETTE_WRITES}")
    if len(components) != PALETTE_WRITES * 3:
        raise RuntimeError(f"captured {len(components)} DAC components")
    return boundaries, components


def main() -> int:
    try:
        boundaries, components = capture_boundaries()
    except Exception as exc:
        print(f"mcga_sprite_palette_timing: FAIL error={exc}")
        print("VERDICT: FAIL: could not execute released sprite palette loop")
        return 1

    payload = b"".join(value.to_bytes(4, "little") for value in boundaries)
    digest = hashlib.sha256(payload).hexdigest()
    slot_hashes = tuple(
        hashlib.sha256(bytes(components[index * 768:(index + 1) * 768])).hexdigest()
        for index in range(9)
    )
    ok = (len(boundaries) == 9 and
          (not EXPECTED_BOUNDARIES_SHA256 or digest == EXPECTED_BOUNDARIES_SHA256) and
          (not EXPECTED_SLOT_DAC_SHA256 or slot_hashes == EXPECTED_SLOT_DAC_SHA256))
    print("mcga_sprite_palette_timing: " + ("PASS" if ok else "FAIL") +
          f" boundaries={boundaries} sha256={digest} slot_sha256={list(slot_hashes)}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": released sprite-frame DAC boundaries captured")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
