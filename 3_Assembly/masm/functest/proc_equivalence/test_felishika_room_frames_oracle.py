#!/usr/bin/env python3
"""Release-MASM stable-frame oracles for Felishika building rooms."""

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc, UcError
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES,
    UC_X86_REG_DI, UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS,
)

MASM_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = MASM_ROOT.parents[1]
sys.path.insert(0, str(REPO_ROOT / "2_SAR" / "Tools"))
from decompress_sar import decompress_sar_chunk  # noqa: E402

GAME_SEG = 0x1000
DATA_SEG = 0x2000
STACK_SEG = 0x8000
VGA_SEG = 0xA000
SAR_STUB = 0x0500
EXPECTED_KING_FRAME = 0xC3F7143FE6C981F1
EXPECTED_KING_STATE = 0xE7DDFAC9C8C12A2C
EXPECTED_SAGE_FRAME = 0xA6873B3AD33ACEC7
EXPECTED_SAGE_STATE = 0x567C3F23BB5AFFE0
EXPECTED_OMOYA_FRAME = 0x1C86E94322A50C57
EXPECTED_OMOYA_STATE = 0x68BB9C561C4E851E
EXPECTED_OMOYA_ARTWORK = 0x33207D5A3E0A63EF


def fnv1a64(data: bytes) -> int:
    value = 0xCBF29CE484222325
    for byte in data:
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def frame_rect(data: bytes, x: int, y: int, width: int, height: int) -> bytes:
    return b"".join(data[(y + row) * 320 + x:(y + row) * 320 + x + width]
                    for row in range(height))


def payload(path: Path) -> bytes:
    data = path.read_bytes()
    declared = int.from_bytes(data[:4], "little")
    assert declared <= len(data) - 4
    return data[4:4 + declared]


def write_u16(mu: Uc, offset: int, value: int) -> None:
    mu.mem_write((GAME_SEG << 4) + offset,
                 bytes((value & 0xFF, value >> 8)))


def build_machine(program: Path, graphic: Path) -> Uc:
    paths = {
        "stdply": MASM_ROOT / "bin" / "stdply.bin",
        "gmm": MASM_ROOT / "working" / "drivers" / "gmmcga.bin",
        "gt": MASM_ROOT / "bin" / "zelres1" / "111GTMCA.bin",
        "town": MASM_ROOT / "bin" / "zelres1" / "106TOWN.bin",
        "font": MASM_ROOT / "bin" / "zelres1" / "112FONTG.grp",
    }
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    base = GAME_SEG << 4
    mu.mem_write(base, paths["stdply"].read_bytes())
    mu.mem_write(base + 0x2000, paths["gmm"].read_bytes())
    mu.mem_write(base + 0x3000, payload(paths["gt"]))
    mu.mem_write(base + 0x6000, payload(paths["town"]))
    mu.mem_write(base + 0xA000, payload(program))
    decoded_graphic = bytes(decompress_sar_chunk(graphic.read_bytes()))
    font = bytes(decompress_sar_chunk(paths["font"].read_bytes()))
    mu.mem_write(base + 0xF500, font)
    for offset in range(0, 6, 2):
        value = int.from_bytes(bytes(mu.mem_read(base + 0xF500 + offset, 2)),
                               "little")
        write_u16(mu, 0xF500 + offset, (value + 0xF500) & 0xFFFF)
    write_u16(mu, 0x010C, SAR_STUB)
    write_u16(mu, 0xFF2C, DATA_SEG)
    mu.mem_write(base + SAR_STUB, b"\xc3")

    def load_graphic(uc: Uc, address: int, _size: int, _user: object) -> None:
        if address != base + SAR_STUB:
            return
        destination = (uc.reg_read(UC_X86_REG_ES) << 4) + \
            uc.reg_read(UC_X86_REG_DI)
        uc.mem_write(destination, decoded_graphic)

    # Keep the callback alive with the Unicorn instance. The RET at the stub
    # then resumes the room prologue exactly as the real SAR loader does.
    mu._room_loader_hook = mu.hook_add(UC_HOOK_CODE, load_graphic)
    return mu


def run_until_boundary(mu: Uc, entry: int, boundary: int,
                       ax: int = 1) -> None:
    for register, value in (
        (UC_X86_REG_CS, GAME_SEG), (UC_X86_REG_DS, GAME_SEG),
        (UC_X86_REG_ES, DATA_SEG), (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, ax),
    ):
        mu.reg_write(register, value)

    reached = False
    last = [0, 0]

    def stop(uc: Uc, address: int, size: int, _user: object) -> None:
        nonlocal reached
        last[:] = (address, size)
        if uc.reg_read(UC_X86_REG_CS) == GAME_SEG and \
                uc.reg_read(UC_X86_REG_IP) == boundary:
            reached = True
            uc.emu_stop()

    hook = mu.hook_add(UC_HOOK_CODE, stop)
    try:
        mu.emu_start((GAME_SEG << 4) + entry, 0, count=20_000_000)
    except UcError as error:
        code = bytes(mu.mem_read(last[0], 8)).hex()
        raise RuntimeError(
            f"room execution failed at {last[0]:05x} ({code}): {error}") from error
    mu.hook_del(hook)
    if not reached:
        raise RuntimeError(f"room program did not reach {boundary:04x}")


def main() -> int:
    king_program = MASM_ROOT / "bin" / "zelres2" / "210KINGP.bin"
    king_graphic = MASM_ROOT / "bin" / "zelres2" / "218KINGG.grp"
    if not king_program.exists() or not king_graphic.exists():
        print("VERDICT: INCONCLUSIVE: Felishika room release asset missing")
        return 0

    king = build_machine(king_program, king_graphic)
    # 210KINGP script_loop, immediately before the first CS:[6004] call.
    run_until_boundary(king, 0xA000, 0xA05A)
    base = GAME_SEG << 4
    king_frame = bytes(king.mem_read(VGA_SEG << 4, 0x10000))
    king_state = bytes(king.mem_read(base + 0xA79D, 5)) + bytes(
        king.mem_read(base + 0xFF4C, 4))
    print(f"felishika_king_room: frame={fnv1a64(king_frame):016x} "
          f"state={king_state.hex()}:{fnv1a64(king_state):016x}")

    omoya_program = MASM_ROOT / "bin" / "zelres2" / "211OMOYP.bin"
    omoya_graphic = MASM_ROOT / "bin" / "zelres2" / "219OMOYG.grp"
    if not omoya_program.exists() or not omoya_graphic.exists():
        print("VERDICT: INCONCLUSIVE: Felishika viewing-room release asset missing")
        return 0
    omoya = build_machine(omoya_program, omoya_graphic)
    # Raw-file offsets 09h and 4Dh land at runtime A005h and A049h after the
    # SAR loader strips the four-byte chunk header. Stop immediately before
    # the first shared 106TOWN script-service call.
    run_until_boundary(omoya, 0xA005, 0xA049)
    omoya_frame = bytes(omoya.mem_read(VGA_SEG << 4, 0x10000))
    omoya_state = bytes(omoya.mem_read(base + 0xFF1D, 2)) + bytes(
        omoya.mem_read(base + 0xFF4C, 4)) + bytes(
        omoya.mem_read((DATA_SEG << 4) + 0x8000, 0x100))
    omoya_artwork = frame_rect(omoya_frame, 96, 30, 136, 128)
    print(f"felishika_omoya_room: frame={fnv1a64(omoya_frame):016x} "
          f"state={fnv1a64(omoya_state):016x} "
          f"artwork={fnv1a64(omoya_artwork):016x}")

    sage_program = MASM_ROOT / "bin" / "zelres2" / "217KENJP.bin"
    sage_graphic = MASM_ROOT / "bin" / "zelres2" / "225KNJYG.grp"
    if not sage_program.exists() or not sage_graphic.exists():
        print("VERDICT: INCONCLUSIVE: Felishika Sage release asset missing")
        return 0
    sage = build_machine(sage_program, sage_graphic)
    write_u16(sage, 0xC006, 1)
    # 217KENJP's release entry A027 is the path that loads KENJA.GRP and
    # initializes a newly entered Sage room. Stop at script_run_loop.
    run_until_boundary(sage, 0xA027, 0xA047, ax=0)
    sage_frame = bytes(sage.mem_read(VGA_SEG << 4, 0x10000))
    sage_state = bytes(sage.mem_read(base + 0xBB12, 0x0E)) + bytes(
        sage.mem_read(base + 0xFF4C, 4))
    print(f"felishika_sage_room: frame={fnv1a64(sage_frame):016x} "
          f"state={sage_state.hex()}:{fnv1a64(sage_state):016x}")
    ok = fnv1a64(king_frame) == EXPECTED_KING_FRAME and \
        fnv1a64(king_state) == EXPECTED_KING_STATE and \
        fnv1a64(omoya_frame) == EXPECTED_OMOYA_FRAME and \
        fnv1a64(omoya_state) == EXPECTED_OMOYA_STATE and \
        fnv1a64(omoya_artwork) == EXPECTED_OMOYA_ARTWORK and \
        fnv1a64(sage_frame) == EXPECTED_SAGE_FRAME and \
        fnv1a64(sage_state) == EXPECTED_SAGE_STATE
    print(f"VERDICT: {'PASS' if ok else 'FAIL'}: "
          "release-MASM Felishika room stable frames")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
