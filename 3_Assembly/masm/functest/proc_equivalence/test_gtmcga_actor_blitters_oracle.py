#!/usr/bin/env python3
"""Release-MASM oracle for GTMCGA NPC/player six-tile blitters."""

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_CS, UC_X86_REG_CX, UC_X86_REG_DS,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

MASM_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = MASM_ROOT.parents[1]
sys.path.insert(0, str(REPO_ROOT / "2_SAR" / "Tools"))
from decompress_sar import decompress_sar_chunk  # noqa: E402

CODE_SEG = 0x1000
DATA_SEG = 0x2000
MASK_SEG = 0x3000
STACK_SEG = 0x8000
VGA_SEG = 0xA000
RETURN_IP = 0x0080


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def write_u16(mu: Uc, segment: int, offset: int, value: int) -> None:
    mu.mem_write((segment << 4) + offset,
                 bytes((value & 0xFF, (value >> 8) & 0xFF)))


def call_near(mu: Uc, entry: int, si: int) -> None:
    for register, value in (
        (UC_X86_REG_CS, CODE_SEG), (UC_X86_REG_DS, CODE_SEG),
        (UC_X86_REG_ES, CODE_SEG), (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, 0),
        (UC_X86_REG_CX, 0), (UC_X86_REG_SI, si),
    ):
        mu.reg_write(register, value)
    write_u16(mu, STACK_SEG, 0xFFFC, RETURN_IP)

    def stop(uc: Uc, _address: int, _size: int, _user: object) -> None:
        if uc.reg_read(UC_X86_REG_IP) == RETURN_IP:
            uc.emu_stop()

    hook = mu.hook_add(UC_HOOK_CODE, stop)
    mu.emu_start((CODE_SEG << 4) + entry, 0, count=1_000_000)
    mu.hook_del(hook)


def payload(path: Path) -> bytes:
    data = path.read_bytes()
    declared = int.from_bytes(data[:4], "little")
    assert declared <= len(data) - 4
    return data[4:4 + declared]


def main() -> int:
    paths = {
        "gt": MASM_ROOT / "bin" / "zelres1" / "111GTMCA.bin",
        "cpat": MASM_ROOT / "bin" / "zelres2" / "233CPATG.grp",
        "mman": MASM_ROOT / "bin" / "zelres2" / "229MMANG.grp",
    }
    if any(not path.exists() for path in paths.values()):
        print("VERDICT: INCONCLUSIVE: GTMCGA actor asset missing")
        return 0

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    code_base = CODE_SEG << 4
    data_base = DATA_SEG << 4
    mask_base = MASK_SEG << 4
    vga_base = VGA_SEG << 4
    mu.mem_write(code_base + 0x3000, payload(paths["gt"]))
    write_u16(mu, CODE_SEG, 0xFF2C, DATA_SEG)
    ids = bytes((0, 1, 2, 3, 4, 5))
    mu.mem_write(code_base + 0x5000, ids)

    cpat = bytes(decompress_sar_chunk(paths["cpat"].read_bytes()))
    mu.mem_write(data_base + 0x8000, cpat)
    mu.mem_write(vga_base + 0xFA00, b"\x2d" * 0x180)
    call_near(mu, 0x32FC, 0x5000)
    npc = bytes(mu.mem_read(vga_base + 0xFA00, 0x180))

    mman = bytes(decompress_sar_chunk(paths["mman"].read_bytes()))
    mu.mem_write(data_base + 0x6000, mman[:0x120])
    mu.mem_write(mask_base + 0x8000, cpat[:0x30])
    mu.mem_write(vga_base + 0xFA00, bytes((i * 13 + 7) & 0x3F
                                        for i in range(0x180)))
    call_near(mu, 0x359A, 0x5000)
    player = bytes(mu.mem_read(vga_base + 0xFA00, 0x180))

    npc_hash = fnv1a64(npc)
    player_hash = fnv1a64(player)
    expected = (0x077B30A88E854340, 0x9CCD07B60E989122)
    ok = (npc_hash, player_hash) == expected
    print(f"gtmcga_actor_blitters: {'PASS' if ok else 'FAIL'} "
          f"npc={npc_hash:016x} player={player_hash:016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM GTMCGA actor blitters")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
