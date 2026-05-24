#!/usr/bin/env python3
"""
test_fight_game_func_42.py

Probe of 200FIGHT.bin's `game_func_42` at CPU 0x6E20 — 32 bytes,
5 callers (rank 4 in PHASE3_PRIORITY.md).

Static body (200FIGHT.asm:2481):
    game_func_42 proc near
        cmp  al, 49h
        jb   scan_enemy_table_b
        cmp  al, al                ; ZF=1, CF=0
        retn
    scan_enemy_table_b:
        push di / push cx
        mov  es, cs:gvar_game_seg
        mov  di, enemy_id_table
        mov  cx, 18h
        repne scasb
        pop  cx / pop di
        jnz  not_in_table_b
        retn                       ; in-table: ZF=1
    not_in_table_b:
        and  al, 80h
        cmp  al, 80h
        retn

Cousin of `is_entity_known_type` (was game_func_138) but LAX about high
IDs: any AL >= 0x49 returns ZF=1 unconditionally (no further check on
bit-7).  In the not-in-table path, the `and al,80h ; cmp al,80h` is
dead code — by the time we get there AL < 0x49 < 0x80, so the AND
always yields 0 and the CMP always sets ZF=0.

Net classification:
  - AL < 0x49 AND in enemy_id_table  : ZF = 1
  - AL < 0x49 AND NOT in table       : ZF = 0
  - AL >= 0x49                       : ZF = 1 (always, including 0x80+)

Verdict
-------
  PASS-RENAME  iff all four probes match.  Recommendation:
    `is_entity_id_lax` (vs the existing strict `is_entity_known_type`).
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness, DATA_SEG  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

CHUNK = 'fight'
ENEMY_ID_TABLE_OFFS = 0x8000
GVAR_GAME_SEG_OFFS  = 0xFF2C


def probe(h, proc, al):
    snap = h.snapshot()
    result = h.call_function(
        proc,
        regs={'ax': al & 0xFF},
        max_steps=200,
    )
    zf = result['flags_after']['ZF']
    h.restore(snap)
    return zf


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    proc = load_base + resolve_proc('fight', 'is_entity_id_lax',
                                    fallback_names=('game_func_42',))
    if not flat_path.exists():
        print('VERDICT: INCONCLUSIVE: flat-file artefact missing')
        return 1

    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)
    h.write_code(GVAR_GAME_SEG_OFFS, [DATA_SEG & 0xFF, (DATA_SEG >> 8) & 0xFF])
    h.write_data(ENEMY_ID_TABLE_OFFS,
                 bytes([0x10, 0x20, 0x30, 0x40, 0x05] + [0] * 19))

    print(f'is_entity_id_lax @ CPU 0x{proc:04X}')
    print()

    cases = [
        ('A', 0x20, True,  'in low table'),
        ('B', 0x08, False, 'low, NOT in table'),
        ('C', 0x60, True,  'mid range >= 0x49 (auto-pass)'),
        ('D', 0x90, True,  'high signed >= 0x80 (LAX: still ZF=1)'),
    ]
    all_ok = True
    for label, al, expected_zf, desc in cases:
        got = probe(h, proc, al)
        ok = (got is expected_zf)
        all_ok = all_ok and ok
        print(f'Probe {label}: AL=0x{al:02X} ({desc})')
        print(f'  ZF={got}  expected ZF={expected_zf}  {"OK" if ok else "FAIL"}')

    if all_ok:
        print('\nVERDICT: PASS: game_func_42 is the LAX entity-ID validator '
              "(cousin of is_entity_known_type/game_func_138 but doesn't "
              'reject high IDs).  ZF=1 iff AL is in low table OR AL >= 0x49.  '
              '5 callers use it where high entity IDs (boss/special types) '
              'must still be accepted.  Rename recommendation: '
              '`is_entity_id_lax`.')
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
