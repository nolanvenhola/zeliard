#!/usr/bin/env python3
"""Release-MASM oracle for Satono's inn artwork and 30-gold tier."""

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from test_felishika_room_frames_oracle import (  # noqa: E402
    GAME_SEG, MASM_ROOT, VGA_SEG, build_machine, fnv1a64, frame_rect,
    run_until_boundary,
)

EXPECTED_FRAME_FNV = 0x358068FD44815BAF
EXPECTED_ARTWORK_FNV = 0x29D1D75A84BBBD3B
EXPECTED_PRICE_TABLE = bytes.fromhex(
    "00001e003200460064009600c8009001")


def main() -> int:
    program = MASM_ROOT / "bin" / "zelres2" / "216INNAP.bin"
    graphic = MASM_ROOT / "bin" / "zelres2" / "224SPRTS.grp"
    if not program.exists() or not graphic.exists():
        print("VERDICT: INCONCLUSIVE: missing release Satono inn assets")
        return 0

    payload = program.read_bytes()[4:]
    # 216INNAP's prologue completes the artwork and intro banner before this
    # authored `mov [FF4C], A2F6` initializes its first dialog script.
    boundary_pattern = bytes.fromhex("c7064cff")
    pattern_at = payload.find(boundary_pattern)
    if pattern_at < 0:
        print("VERDICT: FAIL: Satono inn script boundary missing")
        return 1

    machine = build_machine(program, graphic)
    base = GAME_SEG << 4
    machine.mem_write(base + 0xC006, b"\x02")
    boundary = 0xA000 + pattern_at + 6
    run_until_boundary(machine, 0xA000, boundary)
    frame = bytes(machine.mem_read(VGA_SEG << 4, 0x10000))
    frame_hash = fnv1a64(frame)
    artwork_hash = fnv1a64(frame_rect(frame, 56, 23, 208, 128))
    price_table = payload[0x2D1:0x2E1]
    # Handler A decrements C006 before indexing this word table, making town
    # selector 2 (Satono) select the second word: 001Eh / 30 gold.
    satono_price = int.from_bytes(price_table[2:4], "little")
    ok = (frame_hash == EXPECTED_FRAME_FNV and
          artwork_hash == EXPECTED_ARTWORK_FNV and
          price_table == EXPECTED_PRICE_TABLE and satono_price == 30)
    print(f"satono_inn_frame: {'PASS' if ok else 'FAIL'} "
          f"boundary={boundary:04x} frame={frame_hash:016x} "
          f"artwork={artwork_hash:016x} price={satono_price}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM Satono inn frame and price tier")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
