#!/usr/bin/env python3
"""Procedure-granular release-byte oracles for 209CKPD.

The full mode-4 pass proves the live MCGA path and records every procedure
entry it reaches. Separate deterministic calls cover the four decoder/copy
helpers selected only by the non-MCGA frame handlers.
"""

from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CX, UC_X86_REG_CS,
    UC_X86_REG_DS, UC_X86_REG_DX, UC_X86_REG_ES, UC_X86_REG_IP,
    UC_X86_REG_SI, UC_X86_REG_DI, UC_X86_REG_SP, UC_X86_REG_SS,
)

MASM_ROOT = Path(__file__).resolve().parents[2]
BIN = MASM_ROOT / "bin" / "zelres2" / "209CKPD.bin"
CODE_SEG = 0x1000
STACK_SEG = 0x8000
LOAD_OFFSET = 0x3300
SENTINEL = 0x0080
PROCEDURES = {
    "bos_render_main": 0x3300,
    "bos_frame_dispatch": 0x3389,
    "vga_row_copy": 0x353B,
    "nibble_expand_8": 0x35AB,
    "decode_nibble_pair": 0x362B,
    "sprite_rle_decode": 0x3664,
    "render_dispatch_layer2": 0x3695,
    "nibble_expand_8_b": 0x383A,
    "decode_nibble_pair_alt": 0x38A6,
}
MCGA_REACHED = {
    "bos_render_main", "bos_frame_dispatch", "nibble_expand_8",
    "sprite_rle_decode", "render_dispatch_layer2", "nibble_expand_8_b",
}
EXPECTED_VGA_FNV = 0x0D4FE90212FE1D11
EXPECTED_SCRATCH_FNV = 0x41B5B8D64CE6F12E


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def new_machine(payload: bytes) -> Uc:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    mu.mem_write((CODE_SEG << 4) + LOAD_OFFSET, payload)
    return mu


def push_return(mu: Uc, far: bool) -> None:
    sp = 0xFFF8 if far else 0xFFFA
    raw = bytes((SENTINEL, 0))
    if far:
        raw += bytes((CODE_SEG & 0xFF, CODE_SEG >> 8))
    mu.mem_write((STACK_SEG << 4) + sp, raw)
    mu.reg_write(UC_X86_REG_SP, sp)


def configure(mu: Uc, ds: int = CODE_SEG, es: int = CODE_SEG) -> None:
    for register, value in (
        (UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, ds),
        (UC_X86_REG_ES, es), (UC_X86_REG_SS, STACK_SEG),
    ):
        mu.reg_write(register, value)


def run_full(payload: bytes) -> tuple[int, int, set[str]]:
    mu = new_machine(payload)
    configure(mu)
    mu.reg_write(UC_X86_REG_AX, 4)
    push_return(mu, True)
    addresses = {value: name for name, value in PROCEDURES.items()}
    reached: set[str] = set()

    def trace(uc: Uc, address: int, _size: int, _user: object) -> None:
        ip = uc.reg_read(UC_X86_REG_IP)
        if ip in addresses:
            reached.add(addresses[ip])
        if bytes(uc.mem_read(address, 1)) == b"\xcb":
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, trace)
    mu.emu_start((CODE_SEG << 4) + LOAD_OFFSET, 0, count=10_000_000)
    return (
        fnv1a64(bytes(mu.mem_read(0xA0000, 0x10000))),
        fnv1a64(bytes(mu.mem_read((CODE_SEG + 0x1000) << 4, 0x1F80))),
        reached,
    )


def call_helper(payload: bytes, name: str) -> tuple[int, ...]:
    mu = new_machine(payload)
    address = PROCEDURES[name]
    if name == "vga_row_copy":
        source = bytes((index * 13 + 7) & 0xFF for index in range(0x10000))
        mu.mem_write(0xA0000, source)
        configure(mu, 0xA000, 0xA000)
        mu.reg_write(UC_X86_REG_SI, 0x0100)
    else:
        configure(mu)
        mu.reg_write(UC_X86_REG_DX, 0xA53C)
        mu.reg_write(UC_X86_REG_BX, 0)
    push_return(mu, False)

    def stop(uc: Uc, _address: int, _size: int, _user: object) -> None:
        if uc.reg_read(UC_X86_REG_IP) == SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop)
    mu.emu_start((CODE_SEG << 4) + address, 0, count=100_000)
    if name == "vga_row_copy":
        return (fnv1a64(bytes(mu.mem_read(0xA0000, 0x10000))),
                mu.reg_read(UC_X86_REG_SI), mu.reg_read(UC_X86_REG_DI))
    return tuple(mu.reg_read(register) for register in (
        UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CX, UC_X86_REG_DX,
    ))


def main() -> int:
    if not BIN.exists():
        print("VERDICT: INCONCLUSIVE: 209CKPD release binary missing")
        return 0
    data = BIN.read_bytes()
    if len(data) < 5:
        print("VERDICT: FAIL: 209CKPD release binary truncated")
        return 1
    payload = data[4:]
    vga_hash, scratch_hash, reached = run_full(payload)
    helpers = {
        name: call_helper(payload, name)
        for name in ("vga_row_copy", "nibble_expand_8",
                     "decode_nibble_pair", "nibble_expand_8_b",
                     "decode_nibble_pair_alt")
    }
    expected_helpers = {
        "vga_row_copy": (0x45BB9F465DB8BAC5, 0x0100, 0x0138),
        "nibble_expand_8": (0x0020, 0, 0, 0x94F0),
        "decode_nibble_pair": (0x0036, 0x000D, 0, 0x50C0),
        "nibble_expand_8_b": (0x0020, 0, 0, 0x94F0),
        "decode_nibble_pair_alt": (0x0097, 0x000D, 0, 0x50C0),
    }
    ok = (vga_hash, scratch_hash) == (EXPECTED_VGA_FNV, EXPECTED_SCRATCH_FNV)
    ok &= reached == MCGA_REACHED
    ok &= helpers == expected_helpers
    print(f"ckpd_mcga: vga={vga_hash:016x} scratch={scratch_hash:016x} "
          f"reached={','.join(sorted(reached))}")
    for name, result in helpers.items():
        print(f"ckpd_helper: {name}={','.join(f'{value:016x}' for value in result)}")
    print(f"VERDICT: {'PASS' if ok else 'FAIL'}: release-MASM 209CKPD procedures")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
