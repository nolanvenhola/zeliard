#!/usr/bin/env python3
"""Real-title-asset oracle for the 105GDMCA 3732/37B4 sweep layer."""

from __future__ import annotations

import argparse
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
# zeliad.asm stores game_entry_seg + 1000h in gvar_game_seg.  The MCGA
# title tile routines use CS + 2000h, while 3088/30FC use CS + 3000h.
CODE, GAME, TILE_WORK, RENDER_WORK, STACK, VGA = (
    0x1000, 0x2000, 0x3000, 0x4000, 0x5000, 0xA000
)
SEED, UPDATE, FULL, TILEMAP, TILE, RET, TABLE = 0x3707, 0x3088, 0x30FC, 0x3732, 0x37B4, 0x0080, 0x912B
EXPECTED = {
    1: 0x4B6ABE8700A52CCB,
    10: 0x20D0D89D09409F6B,
    50: 0x0F6C2F786608267A,
    100: 0xE00EEDCDF0C76410,
}
EXPECTED_VISIBLE = {
    "seed": 0x10C1DBF72FB2AB25,
    "update": 0x35893EEBB0CA0BDC,
    "full": 0xE6682F4DCC5FD4CB,
}


def write_mcga_ppm(path: Path, framebuffer: bytes, driver: bytes, ax: int) -> None:
    regs_at = (0x4289 - 0x2FFC) + ax * 0x30
    regs = driver[regs_at:regs_at + 0x30]

    def dac_to_rgb(value: int) -> int:
        value = min(value & 0xFF, 0x3F)
        return (value << 2) | (3 if value & 1 else 0)

    palette = []
    for row in range(16):
        for col in range(16):
            palette.append(tuple(
                dac_to_rgb(regs[row * 3 + channel] +
                           regs[col * 3 + channel])
                for channel in range(3)
            ))
    rgb = bytearray()
    for pixel in framebuffer[:320 * 200]:
        rgb.extend(palette[pixel])
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(b"P6\n320 200\n255\n" + rgb)


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
    parser = argparse.ArgumentParser()
    parser.add_argument("--dump-dir", type=Path)
    args = parser.parse_args()
    spec = importlib.util.spec_from_file_location("sar", ROOT / "2_SAR" / "Tools" / "decompress_sar.py")
    sar = importlib.util.module_from_spec(spec); assert spec.loader; spec.loader.exec_module(sar)
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE, GAME, TILE_WORK, RENDER_WORK, STACK, VGA):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)
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
    mu.mem_write((GAME << 4) + 0x4000, decoded_assets["ttl1.grp"])
    call(mu, UPDATE, bx=0x0B48, cx=0x3180, di=0x4000, es=GAME)
    visible["update"] = fnv1a64(bytes(mu.mem_read(VGA << 4, 0xFA00)))
    mu.mem_write((GAME << 4) + 0x4000, decoded_assets["ttl3.grp"])
    call(mu, FULL, bx=0x070F, cx=0x4170, di=0x4000, es=GAME)
    visible["full"] = fnv1a64(bytes(mu.mem_read(VGA << 4, 0xFA00)))
    if args.dump_dir:
        full_vga = bytes(mu.mem_read(VGA << 4, 0x10000))
        for palette_ax in range(10):
            write_mcga_ppm(args.dump_dir /
                           f"title_full_ax{palette_ax}.ppm",
                           full_vga, GDMCA.read_bytes(), palette_ax)
    mu.mem_write((GAME << 4) + 0x4000, decoded_assets["ttl2.grp"])
    call(mu, TILEMAP, si=TABLE, ds=CODE)
    print(f"mcga_title_sweep_assets: game={fnv1a64(bytes(mu.mem_read(GAME << 4, 0x10000))):016x}")
    print(f"mcga_title_sweep_assets: tile-work={fnv1a64(bytes(mu.mem_read(TILE_WORK << 4, 0x10000))):016x}")
    print(f"mcga_title_sweep_assets: render-work={fnv1a64(bytes(mu.mem_read(RENDER_WORK << 4, 0x10000))):016x}")
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
            if args.dump_dir:
                write_mcga_ppm(args.dump_dir /
                               f"title_sweep_{step + 1:03d}_ax4.ppm",
                               vga, GDMCA.read_bytes(), 4)
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
          ": release title handoff executes 3707/3088/30FC/3732/37B4")
    return 0 if ok else 1


if __name__ == "__main__": raise SystemExit(main())
