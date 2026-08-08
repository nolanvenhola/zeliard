#!/usr/bin/env python3
"""Release-MASM oracle for Satono's first stable town frame."""

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

# Filled from the release-byte execution below and deliberately pinned so a
# later C implementation cannot silently redefine the Satono contract.
EXPECTED_FRAME_FNV = 0x6C183B551150BDCF
EXPECTED_PLAYFIELD_FNV = 0x2B037379CC51F013
EXPECTED_CAPTURE_FNV = 0xF2C3F82A0F93D06D
EXPECTED_STATE_FNV = 0xA4825ECC9A8D201D
EXPECTED_NPC_FNV = 0xA7B3561BCB693B5F
EXPECTED_DPAT_PIXEL_FNV = 0x3F819F76329F575E
EXPECTED_DPAT_ALPHA_FNV = 0x597550E40F08BCB6
EXPECTED_CMAN_PIXEL_FNV = 0x44D254E063EEEC7D
EXPECTED_CMAN_MASK_FNV = 0x4F2D17A7A7837D5F


def relocate_words(mu: Uc, segment: int, offset: int, count: int) -> None:
    base = segment << 4
    for word_offset in range(0, count * 2, 2):
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
        "stmp": MASM_ROOT / "bin" / "zelres2" / "238STMP.mdt",
        "font": MASM_ROOT / "bin" / "zelres1" / "112FONTG.grp",
        "items": MASM_ROOT / "bin" / "zelres2" / "227ITMSG.grp",
        "dpat": MASM_ROOT / "bin" / "zelres2" / "235DPATG.grp",
        "cman": MASM_ROOT / "bin" / "zelres2" / "230CMANG.grp",
        "tman": MASM_ROOT / "bin" / "zelres2" / "231TMANG.grp",
    }
    if any(not path.exists() for path in paths.values()):
        print("VERDICT: INCONCLUSIVE: Satono release asset missing")
        return 0

    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    game_base = GAME_SEG << 4
    mu.mem_write(game_base, paths["stdply"].read_bytes())
    mu.mem_write(game_base + 0x2000, paths["gmm"].read_bytes())
    mu.mem_write(game_base + 0x3000, payload(paths["gt"]))
    mu.mem_write(game_base + 0x6000, payload(paths["town"]))
    mu.mem_write(game_base + 0xC000, payload(paths["stmp"]))

    font = bytes(decompress_sar_chunk(paths["font"].read_bytes()))
    mu.mem_write(game_base + 0xF500, font)
    relocate_words(mu, GAME_SEG, 0xF500, 3)

    # game.asm installs the shared item bank and invokes both equipment HUD
    # entries after MOLE initializes the frame.  Keep these calls in the town
    # oracle so its full-frame contract includes the real game-level wrapper,
    # not just 106TOWN's playfield.
    items = bytes(decompress_sar_chunk(paths["items"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0xE200, items)
    relocate_words(mu, 0x2000, 0xE200, 7)

    dpat = bytes(decompress_sar_chunk(paths["dpat"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0x8000, dpat)
    relocate_words(mu, 0x2000, 0x8000, 3)
    write_u16(mu, GAME_SEG, 0xFF2C, 0x2000)
    call_near(mu, 0x3AF9)

    cman = bytes(decompress_sar_chunk(paths["cman"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0x4000, cman)
    call_near(mu, 0x3A71, cx=0xA4, si=0x4100, di=0x7000,
              ds=0x2000, es=0x3000)
    tman = bytes(decompress_sar_chunk(paths["tman"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0x6000, tman)
    call_near(mu, 0x3A71, cx=0x2E, si=0x6000, di=0x8000,
              ds=0x2000, es=0x3000)

    mu.mem_write(MOLE_SEG << 4, payload(paths["mole"]))
    mu.mem_write((YMPD_SEG << 4) + 0x3300, payload(paths["ympd"]))
    mu.mem_write(game_base + 0x0092, b"\x01\x01\x1e\x00\x1e\x00")
    call_far(mu, MOLE_SEG, 0, 4)
    call_near(mu, 0x254C, ax=1, bx=0x18AB)
    call_near(mu, 0x25FC, ax=1, bx=0x3EA4)
    call_near(mu, 0x2106)
    call_far(mu, YMPD_SEG, 0x3300, 4)
    call_near(mu, 0x3028)

    # 200FIGHT:level_start computes these from STMP width D7h and target 5Ch.
    mu.mem_write(game_base + 0x00C4, b"\x82")
    mu.mem_write(game_base + 0x0080, b"\x4b\x00")
    mu.mem_write(game_base + 0x0082, b"\x00")
    mu.mem_write(game_base + 0x0083, b"\x0d")
    mu.mem_write(game_base + 0x7C45, b"\x01\x02")
    mu.mem_write(game_base + 0xFF1D, b"\x00\x00")
    mu.mem_write(game_base + 0x00E4, b"\x00")
    mu.mem_write(game_base + 0x009F, b"\x00")
    write_u16(mu, GAME_SEG, 0xFF2A, 0xC26F)

    for bx, ch in ((0x0204, 0x21), (0x021C, 0x42), (0x481C, 0x42)):
        call_near(mu, 0x2195, bx=bx, cx=ch << 8)
    call_near(mu, 0x2385)
    for address in (0x6C93, 0x6C9B, 0x6CA4, 0x6CAC):
        call_near(mu, 0x22BF, si=address)
    for entry in (0x2227, 0x2256, 0x238F, 0x23AC):
        call_near(mu, entry)
    call_near(mu, 0x2195, bx=0xC61C, cx=0x1700)
    call_near(mu, 0x23F5)
    call_near(mu, 0x22CD, si=0xC6D8)
    mu.mem_write(game_base + 0xE000, b"\xfe" * 0xE0)
    call_near(mu, 0x6C2B)
    call_near(mu, 0x6975)
    call_near(mu, 0x6950)
    call_near(mu, 0x3051)

    frame = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    capture = bytes(mu.mem_read(game_base + 0xA000, 0x1500))
    state = selected_state(mu)
    npc_bytes = npc_state(mu)
    frame_hash = fnv1a64(frame)
    playfield_hash = fnv1a64(frame[:160 * 320])
    capture_hash = fnv1a64(capture)
    state_hash = fnv1a64(state)
    npc_hash = fnv1a64(npc_bytes)
    dpat_pixel_hash = fnv1a64(bytes(mu.mem_read(
        (0x2000 << 4) + 0x8100, 0x2EE0)))
    dpat_alpha_hash = fnv1a64(bytes(mu.mem_read(
        (0x2000 << 4) + 0xD000, 0x07D0)))
    cman_pixel_hash = fnv1a64(bytes(mu.mem_read(
        (0x2000 << 4) + 0x4100, 0x1EC0)))
    cman_mask_hash = fnv1a64(bytes(mu.mem_read(
        (0x3000 << 4) + 0x7000, 0x0520)))
    descriptor = bytes(mu.mem_read(game_base + 0xC000, 0x17))
    door_bytes = bytes(mu.mem_read(game_base + 0xC6EF, 0x11))

    expected_descriptor = bytes.fromhex(
        "d3c6d700d8c602e7c6efc600c70cc772cccfc65c000ac7")
    expected_doors = bytes.fromhex(
        "2c00045c0002800007940006b90003ffff")
    ok = descriptor == expected_descriptor and door_bytes == expected_doors
    expected_hashes = (
        EXPECTED_FRAME_FNV, EXPECTED_PLAYFIELD_FNV, EXPECTED_CAPTURE_FNV,
        EXPECTED_STATE_FNV, EXPECTED_NPC_FNV, EXPECTED_DPAT_PIXEL_FNV,
        EXPECTED_DPAT_ALPHA_FNV,
        EXPECTED_CMAN_PIXEL_FNV, EXPECTED_CMAN_MASK_FNV,
    )
    actual_hashes = (
        frame_hash, playfield_hash, capture_hash, state_hash, npc_hash,
        dpat_pixel_hash, dpat_alpha_hash,
        cman_pixel_hash, cman_mask_hash,
    )
    if all(expected_hashes):
        ok &= actual_hashes == expected_hashes

    if os.environ.get("ZELIARD_DUMP"):
        dump_dir = MASM_ROOT / "functest" / "build"
        dump_dir.mkdir(exist_ok=True)
        (dump_dir / "town-satono-masm-frame.bin").write_bytes(frame)

    print("town_first_satono_frame: " + ("PASS" if ok else "FAIL") +
          f" frame={frame_hash:016x} playfield={playfield_hash:016x} "
          f"capture={capture_hash:016x} state={state.hex()}:{state_hash:016x} "
          f"npc={npc_hash:016x}")
    print(f"town_dpat_banks: pixels={dpat_pixel_hash:016x} "
          f"alpha={dpat_alpha_hash:016x}")
    print(f"town_cman_banks: pixels={cman_pixel_hash:016x} "
          f"masks={cman_mask_hash:016x}")
    print(f"town_satono_descriptor: {descriptor.hex()} "
          f"doors={door_bytes.hex()} npcs={npc_bytes.hex()}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM first stable Satono frame")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
