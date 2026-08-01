#!/usr/bin/env python3
"""Release-MASM oracle for the Felishika castle music load/start path."""

from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_HOOK_INTR, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_CS, UC_X86_REG_DI, UC_X86_REG_DS,
    UC_X86_REG_ES, UC_X86_REG_IP, UC_X86_REG_SI, UC_X86_REG_SP,
    UC_X86_REG_SS,
)

MASM_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = MASM_ROOT.parents[1]
GAME_SEG = 0x1000
GAME_DATA_SEG = 0x2000
STACK_SEG = 0x8000
TOWN_LOAD_BASE = 0x6000
GAME_LOAD_BASE = 0xA000
SAR_HEADER_SIZE = 4
LOADER_SLOT = 0x010C
LOADER_STUB = 0x0200
INITIAL_SCORE_SELECT_ENTRY = 0xA1E0
UGM2_LOAD_ENTRY = 0x6FC8
CASTLE_MUSIC_START_ENTRY = 0x60A9


def write_u16(mu: Uc, segment: int, offset: int, value: int) -> None:
    mu.mem_write((segment << 4) + offset,
                 bytes((value & 0xFF, (value >> 8) & 0xFF)))


def release_town_bin() -> Path:
    generated = MASM_ROOT / "bin" / "zelres1" / "106TOWN.bin"
    if generated.exists():
        return generated
    return REPO_ROOT / "3_Assembly" / "tasm" / "bin" / "zelres1" / "106TOWN.bin"


def release_asset(relative: str) -> Path:
    generated = MASM_ROOT / "bin" / relative
    if generated.exists():
        return generated
    return REPO_ROOT / "3_Assembly" / "tasm" / "bin" / relative


def sar_payload(path: Path) -> bytes:
    binary = path.read_bytes()
    declared = int.from_bytes(binary[:SAR_HEADER_SIZE], "little")
    payload = binary[SAR_HEADER_SIZE:SAR_HEADER_SIZE + declared]
    if len(payload) != declared:
        raise AssertionError(f"short release payload: {path}")
    return payload


def make_machine() -> Uc:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    mu.mem_map(0, 0x100000, UC_PROT_ALL)
    mu.mem_write((GAME_SEG << 4) + TOWN_LOAD_BASE,
                 sar_payload(release_town_bin()))
    write_u16(mu, GAME_SEG, 0xFF2C, GAME_DATA_SEG)
    for register, value in (
        (UC_X86_REG_CS, GAME_SEG), (UC_X86_REG_DS, GAME_SEG),
        (UC_X86_REG_ES, GAME_SEG), (UC_X86_REG_SS, STACK_SEG),
        (UC_X86_REG_SP, 0xFFFC),
    ):
        mu.reg_write(register, value)
    return mu


def capture_initial_castle_load() -> tuple[int, int, int, int, bytes, int]:
    """Execute game.asm's release bytes that select the initial score."""
    mu = make_machine()
    mu.mem_write((GAME_SEG << 4) + GAME_LOAD_BASE,
                 release_asset("game.bin").read_bytes())
    mu.mem_write((GAME_SEG << 4) + 0xC000,
                 sar_payload(release_asset("zelres2/236CMAP.mdt")))
    write_u16(mu, GAME_SEG, LOADER_SLOT, LOADER_STUB)
    captured = None

    def stop_at_loader(uc: Uc, _address: int, _size: int, _user: object) -> None:
        nonlocal captured
        if uc.reg_read(UC_X86_REG_IP) != LOADER_STUB:
            return
        si = uc.reg_read(UC_X86_REG_SI)
        captured = (
            si, uc.reg_read(UC_X86_REG_ES), uc.reg_read(UC_X86_REG_DI),
            uc.reg_read(UC_X86_REG_AX) & 0xFF,
            bytes(uc.mem_read((GAME_SEG << 4) + si, 11)),
            bytes(uc.mem_read((GAME_SEG << 4) + 0x00C8, 1))[0],
        )
        uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_at_loader)
    mu.emu_start((GAME_SEG << 4) + INITIAL_SCORE_SELECT_ENTRY, 0, count=100)
    if captured is None:
        raise AssertionError("initial castle score loader call was not reached")
    return captured


def capture_ugm2_load() -> tuple[int, int, int, int, bytes]:
    mu = make_machine()
    write_u16(mu, GAME_SEG, LOADER_SLOT, LOADER_STUB)
    captured = None

    def stop_at_loader(uc: Uc, _address: int, _size: int, _user: object) -> None:
        nonlocal captured
        if uc.reg_read(UC_X86_REG_IP) != LOADER_STUB:
            return
        captured = (
            uc.reg_read(UC_X86_REG_SI), uc.reg_read(UC_X86_REG_ES),
            uc.reg_read(UC_X86_REG_DI), uc.reg_read(UC_X86_REG_AX) & 0xFF,
        )
        uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_at_loader)
    mu.emu_start((GAME_SEG << 4) + UGM2_LOAD_ENTRY, 0, count=100)
    if captured is None:
        raise AssertionError("UGM2 loader call was not reached")
    resource = bytes(mu.mem_read((GAME_SEG << 4) + captured[0], 11))
    return (*captured, resource)


def capture_castle_music_start() -> tuple[int, int, int, int]:
    mu = make_machine()
    captured = None

    def stop_at_interrupt(uc: Uc, number: int, _user: object) -> None:
        nonlocal captured
        captured = (
            number, uc.reg_read(UC_X86_REG_AX), uc.reg_read(UC_X86_REG_DS),
            uc.reg_read(UC_X86_REG_SI),
        )
        uc.emu_stop()

    mu.hook_add(UC_HOOK_INTR, stop_at_interrupt)
    mu.emu_start((GAME_SEG << 4) + CASTLE_MUSIC_START_ENTRY, 0, count=100)
    if captured is None:
        raise AssertionError("castle music interrupt was not reached")
    return captured


def main() -> int:
    required = (release_town_bin(), release_asset("game.bin"),
                release_asset("zelres2/236CMAP.mdt"))
    if any(not path.exists() for path in required):
        print("VERDICT: INCONCLUSIVE: castle release binary/asset missing")
        return 0

    initial = capture_initial_castle_load()
    transition = capture_ugm2_load()
    start = capture_castle_music_start()
    expected_initial = b"\x01\x2fMGT1.MSD\x00"
    expected_transition = b"\x01\x32UGM2.MSD\x00"
    expected_initial_tuple = (0xA363, GAME_SEG, 0x3000, 5,
                              expected_initial, 0)
    expected_transition_tuple = (0x6FED, GAME_DATA_SEG, 0x3000, 5,
                                 expected_transition)
    ok = initial == expected_initial_tuple and \
        transition == expected_transition_tuple and \
        start == (0x60, 0, GAME_DATA_SEG, 0x3000)

    print("game_initial_castle_music_load: "
          f"{'PASS' if initial == expected_initial_tuple else 'FAIL'} "
          f"si={initial[0]:04x} es={initial[1]:04x} di={initial[2]:04x} "
          f"al={initial[3]:02x} resource={initial[4]!r} "
          f"level_idx={initial[5]:02x}")
    print("town_ugm2_transition_load: "
          f"{'PASS' if transition == expected_transition_tuple else 'FAIL'} "
          f"si={transition[0]:04x} es={transition[1]:04x} "
          f"di={transition[2]:04x} al={transition[3]:02x} "
          f"resource={transition[4]!r}")
    print("town_castle_music_start: "
          f"{'PASS' if start == (0x60, 0, GAME_DATA_SEG, 0x3000) else 'FAIL'} "
          f"int={start[0]:02x} ax={start[1]:04x} ds={start[2]:04x} si={start[3]:04x}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Felishika castle MGT1 load/start contract")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
