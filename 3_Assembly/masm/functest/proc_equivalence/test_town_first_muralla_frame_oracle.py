#!/usr/bin/env python3
"""Release-MASM oracle for Muralla's first stable town frame."""

import os
import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_MODE_16, UC_PROT_ALL, Uc

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from test_town_first_castle_frame_oracle import (  # noqa: E402
    GAME_SEG, MOLE_SEG, VGA_SEG, YMPD_SEG, call_far, call_near, fnv1a64,
    npc_state, payload, selected_state, write_u16,
)

MASM_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = MASM_ROOT.parents[1]
sys.path.insert(0, str(REPO_ROOT / "2_SAR" / "Tools"))
from decompress_sar import decompress_sar_chunk  # noqa: E402

EXPECTED_FRAME_FNV = 0x74E6D6021C8D82A9
EXPECTED_CAPTURE_FNV = 0xF2C3F82A0F93D06D
EXPECTED_STATE_FNV = 0xDAFA2316E327632F
EXPECTED_NPC_FNV = 0x928392278D0A2B4A
EXPECTED_PLAYFIELD_FNV = 0x2DF9ABEBE695245F
EXPECTED_MPAT_PIXEL_FNV = 0x057549E40BE35E14
EXPECTED_MPAT_ALPHA_FNV = 0x68EDAA05B46B4C6E
EXPECTED_CASTLE_RETURN_PLAYFIELD_FNV = 0x254DCDB105A9AE44


def relocate_three_words(mu: Uc, segment: int, offset: int) -> None:
    base = segment << 4
    for word_offset in range(0, 6, 2):
        value = int.from_bytes(bytes(mu.mem_read(base + offset + word_offset, 2)),
                               "little")
        write_u16(mu, segment, offset + word_offset, (value + offset) & 0xFFFF)


def main() -> int:
    paths = {
        "stdply": MASM_ROOT / "bin" / "stdply.bin",
        "town": MASM_ROOT / "bin" / "zelres1" / "106TOWN.bin",
        "gmm": MASM_ROOT / "working" / "drivers" / "gmmcga.bin",
        "gt": MASM_ROOT / "bin" / "zelres1" / "111GTMCA.bin",
        "mole": MASM_ROOT / "bin" / "zelres2" / "207MOLE.bin",
        "ympd": MASM_ROOT / "bin" / "zelres2" / "208YMPD.bin",
        "cmap": MASM_ROOT / "bin" / "zelres2" / "236CMAP.mdt",
        "mrmp": MASM_ROOT / "bin" / "zelres2" / "237MRMP.mdt",
        "font": MASM_ROOT / "bin" / "zelres1" / "112FONTG.grp",
        "cpat": MASM_ROOT / "bin" / "zelres2" / "233CPATG.grp",
        "mpat": MASM_ROOT / "bin" / "zelres2" / "234MPATG.grp",
        "mman": MASM_ROOT / "bin" / "zelres2" / "229MMANG.grp",
        "tman": MASM_ROOT / "bin" / "zelres2" / "231TMANG.grp",
    }
    if any(not path.exists() for path in paths.values()):
        print("VERDICT: INCONCLUSIVE: Muralla release asset missing")
        return 0

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    game_base = GAME_SEG << 4
    mu.mem_write(game_base, paths["stdply"].read_bytes())
    mu.mem_write(game_base + 0x2000, paths["gmm"].read_bytes())
    mu.mem_write(game_base + 0x3000, payload(paths["gt"]))
    mu.mem_write(game_base + 0x6000, payload(paths["town"]))
    mu.mem_write(game_base + 0xC000, payload(paths["cmap"]))

    font = bytes(decompress_sar_chunk(paths["font"].read_bytes()))
    mu.mem_write(game_base + 0xF500, font)
    relocate_three_words(mu, GAME_SEG, 0xF500)

    cpat = bytes(decompress_sar_chunk(paths["cpat"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0x8000, cpat)
    relocate_three_words(mu, 0x2000, 0x8000)
    write_u16(mu, GAME_SEG, 0xFF2C, 0x2000)
    call_near(mu, 0x3AF9)

    mman = bytes(decompress_sar_chunk(paths["mman"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0x4000, mman)
    call_near(mu, 0x3A71, cx=0xA4, si=0x4100, di=0x7000,
              ds=0x2000, es=0x3000)
    tman = bytes(decompress_sar_chunk(paths["tman"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0x6000, tman)
    call_near(mu, 0x3A71, cx=0x2E, si=0x6000, di=0x8000,
              ds=0x2000, es=0x3000)

    mu.mem_write(MOLE_SEG << 4, payload(paths["mole"]))
    mu.mem_write((YMPD_SEG << 4) + 0x3300, payload(paths["ympd"]))
    call_far(mu, MOLE_SEG, 0, 4)
    call_near(mu, 0x2106)
    call_far(mu, YMPD_SEG, 0x3300, 4)
    call_near(mu, 0x3028)

    # Render the stable Felishika frame which is physically present when the
    # right-edge path enters 106TOWN:load_area_assets.
    mu.mem_write(game_base + 0x7C45, b"\x00\x00")
    mu.mem_write(game_base + 0xFF1D, b"\x00\x00")
    mu.mem_write(game_base + 0x00E4, b"\x00")
    mu.mem_write(game_base + 0x009F, b"\x00")
    castle_start = int.from_bytes(
        bytes(mu.mem_read(game_base + 0x0080, 2)), "little")
    write_u16(mu, GAME_SEG, 0xFF2A,
              (0xC017 + ((castle_start & 0xFF) << 3)) & 0xFFFF)
    for bx, ch in ((0x0204, 0x21), (0x021C, 0x42), (0x481C, 0x42)):
        call_near(mu, 0x2195, bx=bx, cx=ch << 8)
    call_near(mu, 0x2385)
    for address in (0x6C93, 0x6C9B, 0x6CA4, 0x6CAC):
        call_near(mu, 0x22BF, si=address)
    for entry in (0x2227, 0x2256, 0x238F, 0x23AC, 0x23CC, 0x23F5):
        call_near(mu, entry)
    call_near(mu, 0x22CD, si=0xC3B0)
    mu.mem_write(game_base + 0xE000, b"\xfe" * 0xE0)
    call_near(mu, 0x6C2B)
    call_near(mu, 0x6975)
    call_near(mu, 0x6950)
    call_near(mu, 0x3051)

    # The edge frame is rendered before try_door_transition sees column 1Ch.
    mu.mem_write(game_base + 0x0080, b"\x4e\x00")
    mu.mem_write(game_base + 0x0083, b"\x1c")
    write_u16(mu, GAME_SEG, 0xFF2A, 0xC287)
    call_near(mu, 0x6AED)
    call_near(mu, 0x6B1C)
    call_near(mu, 0x6975)
    call_near(mu, 0x6950)
    call_near(mu, 0x3051)

    # Loader mode 1 replaces the active descriptor; palette selector 1 then
    # makes load_town_pattern_chunk replace CPAT with MPAT.
    mu.mem_write(game_base + 0xC000, payload(paths["mrmp"]))
    mpat = bytes(decompress_sar_chunk(paths["mpat"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0x8000, mpat)
    relocate_three_words(mu, 0x2000, 0x8000)
    call_near(mu, 0x3AF9)

    mu.mem_write(game_base + 0x00C4, b"\x81")
    mu.mem_write(game_base + 0x0080, b"\x00\x00")
    mu.mem_write(game_base + 0x0083, b"\x00")
    mu.mem_write(game_base + 0x7C45, b"\x00\x01")
    mu.mem_write(game_base + 0xFF1D, b"\x00\x00")
    mu.mem_write(game_base + 0x00E4, b"\x00")
    mu.mem_write(game_base + 0x009F, b"\x00")
    write_u16(mu, GAME_SEG, 0xFF2A, 0xC017)

    for bx, ch in ((0x0204, 0x21), (0x021C, 0x42), (0x481C, 0x42)):
        call_near(mu, 0x2195, bx=bx, cx=ch << 8)
    call_near(mu, 0x2385)
    for address in (0x6C93, 0x6C9B, 0x6CA4, 0x6CAC):
        call_near(mu, 0x22BF, si=address)
    for entry in (0x2227, 0x2256, 0x238F, 0x23AC, 0x23CC, 0x23F5):
        call_near(mu, entry)
    call_near(mu, 0x22CD, si=0xC6D8)

    mu.mem_write(game_base + 0xE000, b"\xfe" * 0xE0)
    call_near(mu, 0x6C2B)
    call_near(mu, 0x6975)
    call_near(mu, 0x6950)
    call_near(mu, 0x3051)

    frame = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    capture = bytes(mu.mem_read(game_base + 0xA000, 0x1500))
    state = selected_state(mu)
    frame_hash = fnv1a64(frame)
    playfield_hash = fnv1a64(frame[:160 * 320])
    capture_hash = fnv1a64(capture)
    state_hash = fnv1a64(state)
    npc_hash = fnv1a64(npc_state(mu))
    mpat_pixel_hash = fnv1a64(bytes(mu.mem_read(
        (0x2000 << 4) + 0x8100, 0x2EE0)))
    mpat_alpha_hash = fnv1a64(bytes(mu.mem_read(
        (0x2000 << 4) + 0xD000, 0x07D0)))
    descriptor = bytes(mu.mem_read(game_base + 0xC000, 0x17))
    door_bytes = bytes(mu.mem_read(game_base + 0xC6EC, 0x14))
    npc_bytes = npc_state(mu)

    # Muralla's left-edge record returns to CMAP at width-24h, column 1Ah.
    # The old Muralla edge frame is committed before the descriptor swap.
    mu.mem_write(game_base + 0x0083, b"\xff")
    call_near(mu, 0x6AED)
    call_near(mu, 0x6B1C)
    call_near(mu, 0x6975)
    call_near(mu, 0x6950)
    call_near(mu, 0x3051)
    mu.mem_write(game_base + 0xC000, payload(paths["cmap"]))
    mu.mem_write((0x2000 << 4) + 0x8000, cpat)
    relocate_three_words(mu, 0x2000, 0x8000)
    call_near(mu, 0x3AF9)
    mu.mem_write(game_base + 0x00C4, b"\x80")
    mu.mem_write(game_base + 0x0080, b"\x4e\x00")
    mu.mem_write(game_base + 0x0083, b"\x1a")
    mu.mem_write(game_base + 0x7C45, b"\x00\x00")
    mu.mem_write(game_base + 0xFF1D, b"\x00\x00")
    mu.mem_write(game_base + 0x00E4, b"\x00")
    mu.mem_write(game_base + 0x009F, b"\x00")
    write_u16(mu, GAME_SEG, 0xFF2A, 0xC287)
    for bx, ch in ((0x0204, 0x21), (0x021C, 0x42), (0x481C, 0x42)):
        call_near(mu, 0x2195, bx=bx, cx=ch << 8)
    call_near(mu, 0x2385)
    for address in (0x6C93, 0x6C9B, 0x6CA4, 0x6CAC):
        call_near(mu, 0x22BF, si=address)
    for entry in (0x2227, 0x2256, 0x238F, 0x23AC, 0x23CC, 0x23F5):
        call_near(mu, entry)
    call_near(mu, 0x22CD, si=0xC3B0)
    mu.mem_write(game_base + 0xE000, b"\xfe" * 0xE0)
    call_near(mu, 0x6C2B)
    call_near(mu, 0x6975)
    call_near(mu, 0x6950)
    call_near(mu, 0x3051)
    castle_return_frame = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    castle_return_playfield_hash = fnv1a64(
        castle_return_frame[:160 * 320])
    return_cpat_pixel_hash = fnv1a64(bytes(mu.mem_read(
        (0x2000 << 4) + 0x8100, 0x2EE0)))
    return_cpat_alpha_hash = fnv1a64(bytes(mu.mem_read(
        (0x2000 << 4) + 0xD000, 0x07D0)))

    expected_descriptor = bytes.fromhex(
        "d3c6d700d8c601e8c6ecc600c707c7afce cfc6ac0005c7".replace(" ", ""))
    expected_doors = bytes.fromhex(
        "2700033b00056f00048a0006ac0002cd0008ffff")
    if os.environ.get("ZELIARD_DUMP"):
        dump_dir = MASM_ROOT / "functest" / "build"
        dump_dir.mkdir(exist_ok=True)
        (dump_dir / "town-muralla-masm-frame.bin").write_bytes(frame)
    ok = descriptor == expected_descriptor and door_bytes == expected_doors
    if EXPECTED_FRAME_FNV:
        ok &= (frame_hash, capture_hash, state_hash, npc_hash) == (
            EXPECTED_FRAME_FNV, EXPECTED_CAPTURE_FNV,
            EXPECTED_STATE_FNV, EXPECTED_NPC_FNV)
        ok &= playfield_hash == EXPECTED_PLAYFIELD_FNV
        if EXPECTED_MPAT_PIXEL_FNV:
            ok &= (mpat_pixel_hash, mpat_alpha_hash) == (
                EXPECTED_MPAT_PIXEL_FNV, EXPECTED_MPAT_ALPHA_FNV)
        if EXPECTED_CASTLE_RETURN_PLAYFIELD_FNV:
            ok &= castle_return_playfield_hash == \
                EXPECTED_CASTLE_RETURN_PLAYFIELD_FNV

    print("town_first_muralla_frame: " + ("PASS" if ok else "FAIL") +
          f" frame={frame_hash:016x} playfield={playfield_hash:016x} "
          f"capture={capture_hash:016x} "
          f"state={state.hex()}:{state_hash:016x} npc={npc_hash:016x}")
    print(f"town_mpat_banks: pixels={mpat_pixel_hash:016x} "
          f"alpha={mpat_alpha_hash:016x}")
    print(f"town_castle_return: playfield="
          f"{castle_return_playfield_hash:016x} cpat="
          f"{return_cpat_pixel_hash:016x}/{return_cpat_alpha_hash:016x}")
    print(f"town_muralla_descriptor: {descriptor.hex()} doors={door_bytes.hex()} "
          f"npcs={npc_bytes.hex()}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM first stable Muralla frame")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
