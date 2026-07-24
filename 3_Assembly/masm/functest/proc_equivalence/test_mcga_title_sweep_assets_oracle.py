#!/usr/bin/env python3
"""Real-title-asset oracle for the 105GDMCA 3732/37B4 sweep layer."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CX,
                               UC_X86_REG_CS, UC_X86_REG_DI, UC_X86_REG_DS,
                               UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI,
                               UC_X86_REG_SP, UC_X86_REG_SS)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

ROOT = MASM_ROOT.parent.parent
ASSETS = ROOT / "6_WebPort" / "engine" / "assets"
GDMCA = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
OPDMO = MASM_ROOT / "bin" / "zelres1" / "100OPDMO.bin"
CODE, GAME, WORK, STACK, VGA = 0x1000, 0x3000, 0x4000, 0x5000, 0xA000
SEED, UPDATE, FULL, TILEMAP, TILE, RET, TABLE = 0x3707, 0x3032, 0x30FC, 0x3732, 0x37B4, 0x0080, 0x912B
EXPECTED = {
    1: 0x1182E5A740AFAE7B,
    10: 0xA4B31E6E705A1097,
    50: 0x1C44F974C82A1B19,
    100: 0xEAAF226D3A11E2EC,
}
EXPECTED_VISIBLE = {
    "seed": 0x10C1DBF72FB2AB25,
    "update": 0xBA926958F64C6A78,
    "full": 0x973216D07E72267B,
}


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value = ((value ^ byte) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def decode_6de1(src: bytes) -> bytes:
    out = bytearray(); i = 0
    while i < len(src):
        first = src[i]; i += 1
        if first & 0x40:
            if i >= len(src): break
            word = (first << 8) | src[i]; i += 1
            if word == 0xFFFF: break
            count = word & 0x3FFF
            repeat = word & 0x8000
        else:
            count, repeat = first & 0x3F, first & 0x80
        if repeat:
            if i >= len(src): break
            out.extend([src[i]] * count); i += 1
        else:
            out.extend(src[i:i + count]); i += count
    return bytes(out)


def call(mu: Uc, entry: int, *, ax: int = 0, bx: int = 0, cx: int = 0,
         si: int = 0, di: int = 0, ds: int = CODE, es: int = CODE) -> None:
    mu.reg_write(UC_X86_REG_DS, ds); mu.reg_write(UC_X86_REG_ES, es)
    mu.reg_write(UC_X86_REG_AX, ax); mu.reg_write(UC_X86_REG_BX, bx)
    mu.reg_write(UC_X86_REG_CX, cx); mu.reg_write(UC_X86_REG_SI, si)
    mu.reg_write(UC_X86_REG_DI, di)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.mem_write((STACK << 4) + 0xFFFC, b"\x80\x00")
    def stop(uc, _address, _size, _user):
        ip = uc.reg_read(UC_X86_REG_IP) & 0xFFFF
        if ip == 0x322D:
            uc.mem_write((CODE << 4) + 0xFF1A, b"\x14")
        elif ip == RET:
            uc.emu_stop()
    hook = mu.hook_add(UC_HOOK_CODE, stop)
    mu.emu_start((CODE << 4) + entry, 0); mu.hook_del(hook)


def main() -> int:
    spec = importlib.util.spec_from_file_location("sar", ROOT / "2_SAR" / "Tools" / "decompress_sar.py")
    sar = importlib.util.module_from_spec(spec); assert spec.loader; spec.loader.exec_module(sar)
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE, GAME, WORK, STACK, VGA): mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
    mu.mem_write((CODE << 4) + 0x2FFC, GDMCA.read_bytes())
    mu.mem_write((CODE << 4) + 0x5FFC, OPDMO.read_bytes())
    mu.mem_write((CODE << 4) + 0xFF2C, bytes((GAME & 0xFF, GAME >> 8)))
    decoded_assets = {}
    for name in ("ttl1.grp", "ttl3.grp", "ttl2.grp"):
        stream = bytes(sar.decompress_sar_chunk((ASSETS / name).read_bytes()))
        decoded = decode_6de1(stream)
        decoded_assets[name] = decoded
    mu.mem_write(VGA << 4, bytes(0x10000))
    mu.reg_write(UC_X86_REG_CS, CODE); mu.reg_write(UC_X86_REG_SS, STACK)
    call(mu, SEED)
    visible = {"seed": fnv1a64(bytes(mu.mem_read(VGA << 4, 0xFA00)))}
    mu.mem_write((GAME << 4) + 0x9000, decoded_assets["ttl1.grp"])
    call(mu, UPDATE, bx=0x0B48, cx=0x3180, di=0x9000, es=GAME)
    visible["update"] = fnv1a64(bytes(mu.mem_read(VGA << 4, 0xFA00)))
    mu.mem_write((GAME << 4) + 0x9000, decoded_assets["ttl3.grp"])
    call(mu, FULL, bx=0x070F, cx=0x4170, di=0x9000, es=GAME)
    visible["full"] = fnv1a64(bytes(mu.mem_read(VGA << 4, 0xFA00)))
    mu.mem_write((GAME << 4) + 0x4000, decoded_assets["ttl2.grp"])
    call(mu, TILEMAP, si=TABLE, ds=CODE)
    print(f"mcga_title_sweep_assets: work={fnv1a64(bytes(mu.mem_read(GAME << 4, 0x10000))):016x}")
    checkpoints = []
    visible_checkpoints = []
    al, ah = 0xC7, 0x00
    for step in range(100):
        call(mu, TILE, ax=al); call(mu, TILE, ax=ah)
        if step + 1 in (1, 10, 11, 29, 50, 100):
            vga = bytes(mu.mem_read(VGA << 4, 0x10000))
            checkpoints.append((step + 1, fnv1a64(vga)))
            visible_checkpoints.append((step + 1,
                                        fnv1a64(bytes(mu.mem_read(VGA << 4, 0xFA00)))))
        al = (al - 2) & 0xFF; ah = (ah + 2) & 0xFF
    ok = (all(EXPECTED[n] == h for n, h in checkpoints if n in EXPECTED) and
          all(EXPECTED_VISIBLE[n] == h for n, h in visible.items()))
    print("mcga_title_sweep_assets: visible " +
          " ".join(f"{n}={h:016x}" for n, h in visible.items()))
    print("mcga_title_sweep_assets: " + ("PASS" if ok else "FAIL") + " " +
          " ".join(f"{n}={h:016x}" for n, h in checkpoints))
    print("mcga_title_sweep_assets: visible-sweep " +
          " ".join(f"{n}={h:016x}" for n, h in visible_checkpoints))
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release title handoff executes 3707/3032/30FC/3732/37B4")
    return 0 if ok else 1


if __name__ == "__main__": raise SystemExit(main())
