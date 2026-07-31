#!/usr/bin/env python3
"""Release-MASM oracle for the first Felishika castle frame service span."""

import os
import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_BX, UC_X86_REG_CS, UC_X86_REG_CX,
    UC_X86_REG_DI, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI,
    UC_X86_REG_SP, UC_X86_REG_SS,
)

MASM_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = MASM_ROOT.parents[1]
sys.path.insert(0, str(REPO_ROOT / "2_SAR" / "Tools"))
from decompress_sar import decompress_sar_chunk  # noqa: E402

GAME_SEG = 0x1000
YMPD_SEG = 0x3000
MOLE_SEG = 0x4000
STACK_SEG = 0x8000
VGA_SEG = 0xA000
RETURN_IP = 0x0080
EXPECTED_FRAME_FNV = 0x1FA483016782AFEC
EXPECTED_CAPTURE_FNV = 0xF2C3F82A0F93D06D
EXPECTED_STATE_FNV = 0xE75DC3416036703F
EXPECTED_BACKGROUND_FNV = 0x14093BAEA087B3AD
EXPECTED_ACTOR_FNV = 0x14D37DE120D41703
EXPECTED_CURSOR_FNV = 0x5808FD95919F54F5
EXPECTED_ACTOR_FRAME_FNV = 0xE0E164284EA685FA
EXPECTED_CPAT_PIXEL_FNV = 0x639503FA794A154F
EXPECTED_CPAT_ALPHA_FNV = 0x2AE75F00707E7659
EXPECTED_IDLE_FRAME_FNVS = (0x26D0E4434D4F9C14, 0xE3CDA193615CB7A5)
EXPECTED_IDLE_NPC_FNVS = (0x7AEF6E1921E0C970, 0x04FCC161ECC110A0)
EXPECTED_OVERLAP_FRAME_FNVS = (
    0xC7A9AAD199FEB82E, 0x2DF829B1230E73A3,
    0x312DDFEB392959C3, 0xC2202A1FE9149790,
)


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def write_u16(mu: Uc, segment: int, offset: int, value: int) -> None:
    mu.mem_write((segment << 4) + offset,
                 bytes((value & 0xFF, (value >> 8) & 0xFF)))


def call_near(mu: Uc, entry: int, *, ax: int = 0, bx: int = 0,
              cx: int = 0, si: int = 0, di: int = 0,
              ds: int = GAME_SEG, es: int = GAME_SEG) -> None:
    for register, value in (
        (UC_X86_REG_CS, GAME_SEG), (UC_X86_REG_DS, ds),
        (UC_X86_REG_ES, es), (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, ax),
        (UC_X86_REG_BX, bx), (UC_X86_REG_CX, cx), (UC_X86_REG_SI, si),
        (UC_X86_REG_DI, di),
    ):
        mu.reg_write(register, value)
    write_u16(mu, STACK_SEG, 0xFFFC, RETURN_IP)

    def stop(uc: Uc, _address: int, _size: int, _user: object) -> None:
        if uc.reg_read(UC_X86_REG_IP) == RETURN_IP:
            uc.emu_stop()

    hook = mu.hook_add(UC_HOOK_CODE, stop)
    mu.emu_start((GAME_SEG << 4) + entry, 0, count=2_000_000)
    mu.hook_del(hook)


def call_far(mu: Uc, segment: int, entry: int, ax: int) -> None:
    for register, value in (
        (UC_X86_REG_CS, segment), (UC_X86_REG_DS, segment),
        (UC_X86_REG_ES, segment), (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFF8), (UC_X86_REG_AX, ax),
    ):
        mu.reg_write(register, value)
    mu.mem_write((STACK_SEG << 4) + 0xFFF8,
                 bytes((RETURN_IP, 0, segment & 0xFF, segment >> 8)))

    def stop(uc: Uc, address: int, _size: int, _user: object) -> None:
        if bytes(uc.mem_read(address, 1)) == b"\xcb":
            uc.emu_stop()

    hook = mu.hook_add(UC_HOOK_CODE, stop)
    mu.emu_start((segment << 4) + entry, 0, count=10_000_000)
    mu.hook_del(hook)


def payload(path: Path) -> bytes:
    data = path.read_bytes()
    declared = int.from_bytes(data[:4], "little")
    assert declared <= len(data) - 4
    return data[4:4 + declared]


def selected_state(mu: Uc) -> bytes:
    base = GAME_SEG << 4
    ranges = ((0x009F, 1), (0x00E4, 1), (0x2433, 7), (0x2CBD, 2),
              (0x7C45, 2), (0xFF1D, 2), (0xFF2A, 2))
    return b"".join(bytes(mu.mem_read(base + offset, size))
                    for offset, size in ranges)


def npc_state(mu: Uc) -> bytes:
    base = GAME_SEG << 4
    start = int.from_bytes(bytes(mu.mem_read(base + 0xC00F, 2)), "little")
    size = 2
    while start + size + 8 <= 0x10000:
        position = int.from_bytes(
            bytes(mu.mem_read(base + start + size - 2, 2)), "little")
        if position == 0xFFFF:
            break
        size += 8
    return bytes(mu.mem_read(base + start, size))


def main() -> int:
    paths = {
        "stdply": MASM_ROOT / "bin" / "stdply.bin",
        "town": MASM_ROOT / "bin" / "zelres1" / "106TOWN.bin",
        "gmm": MASM_ROOT / "working" / "drivers" / "gmmcga.bin",
        "gt": MASM_ROOT / "bin" / "zelres1" / "111GTMCA.bin",
        "mole": MASM_ROOT / "bin" / "zelres2" / "207MOLE.bin",
        "ympd": MASM_ROOT / "bin" / "zelres2" / "208YMPD.bin",
        "cmap": MASM_ROOT / "bin" / "zelres2" / "236CMAP.mdt",
        "font": MASM_ROOT / "bin" / "zelres1" / "112FONTG.grp",
        "cpat": MASM_ROOT / "bin" / "zelres2" / "233CPATG.grp",
        "mman": MASM_ROOT / "bin" / "zelres2" / "229MMANG.grp",
        "tman": MASM_ROOT / "bin" / "zelres2" / "231TMANG.grp",
    }
    if any(not path.exists() for path in paths.values()):
        print("VERDICT: INCONCLUSIVE: first-castle release asset missing")
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
    for offset in range(0, 6, 2):
        value = int.from_bytes(bytes(mu.mem_read(game_base + 0xF500 + offset, 2)),
                               "little")
        write_u16(mu, GAME_SEG, 0xF500 + offset, (value + 0xF500) & 0xFFFF)
    mu.mem_write((YMPD_SEG << 4) + 0x3300, payload(paths["ympd"]))
    cpat = bytes(decompress_sar_chunk(paths["cpat"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0x8000, cpat)
    for offset in range(0, 6, 2):
        value = int.from_bytes(bytes(mu.mem_read(
            (0x2000 << 4) + 0x8000 + offset, 2)), "little")
        write_u16(mu, 0x2000, 0x8000 + offset, (value + 0x8000) & 0xFFFF)
    # 106TOWN:load_town_pattern_chunk tail-jumps through CS:[3024], whose
    # release-MCGA target is GTMCGA:3AF9. This converts all 250 CPAT tiles
    # in place and builds the alpha bank at gvar_game_seg:D000.
    write_u16(mu, GAME_SEG, 0xFF2C, 0x2000)
    call_near(mu, 0x3AF9)
    cpat_pixels = bytes(mu.mem_read((0x2000 << 4) + 0x8100, 0x2EE0))
    cpat_alpha = bytes(mu.mem_read((0x2000 << 4) + 0xD000, 0x07D0))
    mman = bytes(decompress_sar_chunk(paths["mman"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0x4000, mman)
    call_near(mu, 0x3A71, cx=0xA4, si=0x4100, di=0x7000,
              ds=0x2000, es=0x3000)
    tman = bytes(decompress_sar_chunk(paths["tman"].read_bytes()))
    mu.mem_write((0x2000 << 4) + 0x6000, tman)
    call_near(mu, 0x3A71, cx=0x2E, si=0x6000, di=0x8000,
              ds=0x2000, es=0x3000)
    write_u16(mu, GAME_SEG, 0xFF2C, 0x2000)
    mu.mem_write(MOLE_SEG << 4, payload(paths["mole"]))

    call_far(mu, MOLE_SEG, 0, 4)
    call_near(mu, 0x2106)
    call_far(mu, YMPD_SEG, 0x3300, 4)
    # GTMCGA:3028 snapshots the completed YMPD scenery for the transparent
    # pixels in the upper CPAT rows.
    call_near(mu, 0x3028)
    background = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))

    mu.mem_write(game_base + 0x7C45, b"\x00\x00")
    mu.mem_write(game_base + 0xFF1D, b"\x00\x00")
    mu.mem_write(game_base + 0x00E4, b"\x00")
    mu.mem_write(game_base + 0x009F, b"\x00")
    start_position = int.from_bytes(
        bytes(mu.mem_read(game_base + 0x0080, 2)), "little")
    write_u16(mu, GAME_SEG, 0xFF2A,
              (0xC017 + ((start_position & 0xFF) << 3)) & 0xFFFF)
    for bx, ch in ((0x0204, 0x21), (0x021C, 0x42), (0x481C, 0x42)):
        call_near(mu, 0x2195, bx=bx, cx=ch << 8)
    call_near(mu, 0x2385)
    for address in (0x6C93, 0x6C9B, 0x6CA4, 0x6CAC):
        call_near(mu, 0x22BF, si=address)
    for entry in (0x2227, 0x2256, 0x238F, 0x23AC, 0x23CC, 0x23F5):
        call_near(mu, entry)
    call_near(mu, 0x22CD, si=0xC3B0)

    # 106TOWN:frame_update then reaches NPC stamping and the first actor pass.
    mu.mem_write(game_base + 0xE000, b"\xfe" * 0xE0)
    call_near(mu, 0x6C2B)
    call_near(mu, 0x6975)
    actor_tiles = bytes(mu.mem_read((VGA_SEG << 4) + 0xFA00, 0x180))
    actor_frame = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    call_near(mu, 0x6950)
    cursor = bytes(mu.mem_read(game_base + 0xE000, 0xE0))
    call_near(mu, 0x3051)

    frame = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    capture = bytes(mu.mem_read(game_base + 0xA000, 0x1500))
    state = selected_state(mu)

    # Hold the NPC state fixed and move Duke across the first castle NPC's
    # three-column compositor span. This isolates GTMCGA's overlap behavior
    # from 106TOWN's NPC movement tick.
    overlap_base_state = bytes(mu.mem_read(game_base, 0x10000))
    overlap_base_vga = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
    overlap_hashes = []
    overlap_frames = []
    for column in range(0x0C, 0x10):
        mu.mem_write(game_base, overlap_base_state)
        mu.mem_write(VGA_SEG << 4, overlap_base_vga)
        mu.mem_write(game_base + 0x0083, bytes((column,)))
        mu.mem_write(game_base + 0xE000, b"\xfe" * 0xE0)
        call_near(mu, 0x6975)
        call_near(mu, 0x6950)
        call_near(mu, 0x3051)
        overlap_frame = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
        overlap_frames.append(overlap_frame)
        overlap_hashes.append(fnv1a64(overlap_frame))
    mu.mem_write(game_base, overlap_base_state)
    mu.mem_write(VGA_SEG << 4, overlap_base_vga)

    # First two idle iterations of 106TOWN:draw_and_pump_input. The release
    # addresses below retain the real call order: events, NPC tick, actor
    # composition, cursor marking, then GTMCGA:3051 dirty update.
    idle_hashes = []
    idle_npc_hashes = []
    idle_frames = []
    idle_states = []
    for _ in range(2):
        call_near(mu, 0x6AED)
        call_near(mu, 0x6B1C)
        call_near(mu, 0x6975)
        call_near(mu, 0x6950)
        call_near(mu, 0x3051)
        idle_frame = bytes(mu.mem_read(VGA_SEG << 4, 0x10000))
        idle_frames.append(idle_frame)
        idle_states.append(bytes(mu.mem_read(game_base, 0x10000)))
        idle_hashes.append(fnv1a64(idle_frame))
        idle_npc_hashes.append(fnv1a64(npc_state(mu)))
        # 106TOWN:dispatch_right is the no-horizontal-input return path.
        # It marks the standing pose after the completed draw, affecting the
        # next frame but not the checkpoint just captured.
        pose = bytes(mu.mem_read(game_base + 0x00E7, 1))[0]
        mu.mem_write(game_base + 0x00E7, bytes((pose | 1,)))
    frame_hash = fnv1a64(frame)
    capture_hash = fnv1a64(capture)
    state_hash = fnv1a64(state)
    background_hash = fnv1a64(background)
    if os.environ.get("ZELIARD_DUMP"):
        dump_dir = MASM_ROOT / "functest" / "build"
        dump_dir.mkdir(exist_ok=True)
        (dump_dir / "town-background-cleared-frame.bin").write_bytes(background)
        (dump_dir / "town-first-frame.bin").write_bytes(frame)
        (dump_dir / "town-game-data.bin").write_bytes(
            bytes(mu.mem_read(0x2000 << 4, 0x10000)))
        for index, idle_frame in enumerate(idle_frames, 1):
            (dump_dir / f"town-idle-frame-{index}.bin").write_bytes(idle_frame)
            (dump_dir / f"town-idle-state-{index}.bin").write_bytes(
                idle_states[index - 1])
        for column, overlap_frame in zip(range(0x0C, 0x10), overlap_frames):
            (dump_dir / f"town-overlap-col{column:02x}.bin").write_bytes(
                overlap_frame)
    ok = (frame_hash, capture_hash, state_hash, background_hash,
          fnv1a64(actor_tiles), fnv1a64(cursor), fnv1a64(actor_frame)) == (
        EXPECTED_FRAME_FNV, EXPECTED_CAPTURE_FNV, EXPECTED_STATE_FNV,
        EXPECTED_BACKGROUND_FNV, EXPECTED_ACTOR_FNV, EXPECTED_CURSOR_FNV,
        EXPECTED_ACTOR_FRAME_FNV) and \
        fnv1a64(cpat_pixels) == EXPECTED_CPAT_PIXEL_FNV and \
        fnv1a64(cpat_alpha) == EXPECTED_CPAT_ALPHA_FNV and \
        tuple(idle_hashes) == EXPECTED_IDLE_FRAME_FNVS and \
        tuple(idle_npc_hashes) == EXPECTED_IDLE_NPC_FNVS and \
        tuple(overlap_hashes) == EXPECTED_OVERLAP_FRAME_FNVS
    print(f"town_first_castle_frame: {'PASS' if ok else 'FAIL'} "
          f"background={background_hash:016x} frame={frame_hash:016x} "
          f"capture={capture_hash:016x} "
          f"actor={fnv1a64(actor_tiles):016x} cursor={fnv1a64(cursor):016x} "
          f"actor_frame={fnv1a64(actor_frame):016x} "
          f"state={state.hex()}:{state_hash:016x}")
    print("town_castle_idle_frames: " + " ".join(
        f"frame{i + 1}={frame_hash:016x}/npc={npc_hash:016x}"
        for i, (frame_hash, npc_hash) in
        enumerate(zip(idle_hashes, idle_npc_hashes))))
    print("town_castle_actor_overlap: " + " ".join(
        f"col{column:02x}={frame_hash:016x}"
        for column, frame_hash in zip(range(0x0C, 0x10), overlap_hashes)))
    print("town_mman_banks: "
          f"pixels={fnv1a64(bytes(mu.mem_read((0x2000 << 4) + 0x4100, 0x1EC0))):016x} "
          f"masks={fnv1a64(bytes(mu.mem_read((0x3000 << 4) + 0x7000, 0x0520))):016x}")
    print("town_cpat_banks: "
          f"pixels={fnv1a64(cpat_pixels):016x} "
          f"alpha={fnv1a64(cpat_alpha):016x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM first stable Felishika castle frame")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
