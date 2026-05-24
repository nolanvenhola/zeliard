#!/usr/bin/env python3
"""
test_fight_game_func_63.py

Probe of 200FIGHT.bin's `game_func_63` at CPU 0x76FB — 88 bytes, 5 callers.

Static body (200FIGHT.asm:3619): scans three 4-entry tables for the
input AL byte:
    move_slot_a_table @ 8024h
    move_slot_b_table @ 8028h
    move_slot_c_table @ 802Ch
returns:
    CL = 0 if found in slot_a
    CL = 1 if found in slot_b
    CL = 2 if found in slot_c
    CL = 0xFF if not found
ZF=1 on miss (`or cl,cl` in slot_not_found path); ZF varies on hit
(based on `cmp al, bh` exit which fires on equality).

The labels `move_slot_*_table` suggest these are MOVE TYPE tables —
entity move types grouped into 3 families.  game_func_63 returns the
family index for a given entity ID.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness, DATA_SEG  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

CHUNK = 'fight'
GVAR_GAME_SEG_OFFS = 0xFF2C

TABLE_A = 0x8024
TABLE_B = 0x8028
TABLE_C = 0x802C


def setup_tables(h):
    h.write_data(TABLE_A, bytes([0x10, 0x11, 0x12, 0x13]))
    h.write_data(TABLE_B, bytes([0x20, 0x21, 0x22, 0x23]))
    h.write_data(TABLE_C, bytes([0x30, 0x31, 0x32, 0x33]))


def probe(h, proc, al):
    snap = h.snapshot()
    setup_tables(h)
    result = h.call_function(proc, regs={'ax': al & 0xFF}, max_steps=200)
    cl = result['regs_after']['cx'] & 0xFF
    h.restore(snap)
    return cl


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    proc = load_base + resolve_proc('fight', 'lookup_move_slot_family',
                                    fallback_names=('game_func_63',))
    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)
    h.write_code(GVAR_GAME_SEG_OFFS, [DATA_SEG & 0xFF, (DATA_SEG >> 8) & 0xFF])

    print(f'lookup_move_slot_family @ CPU 0x{proc:04X}')

    cases = [
        ('A', 0x11, 0x00, 'in table A'),
        ('B', 0x22, 0x01, 'in table B'),
        ('C', 0x32, 0x02, 'in table C'),
        ('D', 0x99, 0xFF, 'not in any table'),
        ('E', 0x00, 0xFF, 'AL=0 short-circuits to slot_not_found'),
    ]
    all_ok = True
    for label, al, expected_cl, desc in cases:
        cl = probe(h, proc, al)
        ok = cl == expected_cl
        all_ok = all_ok and ok
        print(f'Probe {label}: AL=0x{al:02X} ({desc})  '
              f'CL=0x{cl:02X}  expected 0x{expected_cl:02X}  '
              f'{"OK" if ok else "FAIL"}')

    if all_ok:
        print('\nVERDICT: PASS: game_func_63 returns CL = move-slot family '
              "index (0/1/2) if AL found in move_slot_{a,b,c}_table, "
              'else CL = 0xFF.  Rename: `lookup_move_slot_family`.')
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
