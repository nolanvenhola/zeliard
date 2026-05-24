#!/usr/bin/env python3
"""
test_fight_game_func_138.py

Probe of 200FIGHT.bin's `game_func_138` at CPU 0x94E8 — a 30-byte proc
called by 18 distinct sites, the highest-leverage placeholder identified
by the Phase-3 priority queue.

Static body (200FIGHT.asm:7564):

    game_func_138 proc near
        cmp al, 49h            ; 'I' = 0x49
        jb  scan_enemy_tbl_b   ; AL < 0x49: scan the table
        or  al, al             ; ZF/SF on AL
        jns entity_type_valid  ; AL >= 0 (i.e. AL < 0x80): valid mid range
        retn                   ; AL >= 0x80: return (ZF=0 from `or al,al`)
    entity_type_valid:
        cmp al, al             ; ZF=1, CF=0 (al == al)
        retn
    scan_enemy_tbl_b:
        push di / push cx
        mov  es, cs:gvar_game_seg
        mov  di, enemy_id_table   ; 8000h
        mov  cx, 18h              ; 24 entries
        repne scasb               ; scan ES:[DI..DI+24] for AL; ZF=1 iff found
        pop  cx / pop di
        retn

Hypothesis: this is `is_entity_known_type` — a classifier returning the
flags that callers test:
  - AL <  0x49           : ZF = (AL is in enemy_id_table)
  - 0x49 <= AL < 0x80    : ZF = 1   (mid-range = "known")
  - AL >= 0x80           : ZF = 0   (sign-bit-set = "unknown")

The four probes below cover the three branches plus an in-table hit and miss.

Verdict
-------
  PASS   iff all four probes match the predicted ZF state.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness, DATA_SEG  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

CHUNK = 'fight'
ENEMY_ID_TABLE_OFFS = 0x8000
GVAR_GAME_SEG_OFFS  = 0xFF2C   # CS:[FF2C] holds the game segment value


def probe(h, proc, al_value):
    snap = h.snapshot()
    result = h.call_function(
        proc,
        regs={'ax': al_value & 0xFF},
        max_steps=200,
    )
    zf = result['flags_after']['ZF']
    cf = result['flags_after']['CF']
    sf = result['flags_after']['SF']
    h.restore(snap)
    return zf, cf, sf, result


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    proc = load_base + resolve_proc('fight', 'is_entity_known_type',
                                    fallback_names=('game_func_138',))
    if not flat_path.exists():
        print('VERDICT: INCONCLUSIVE: flat-file artefact missing')
        return 1

    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    # The proc reads the game-segment register from CS:[FF2C] before
    # the SCASB.  Make `mov es, cs:[FF2C]` produce ES = DATA_SEG so the
    # subsequent ES:[8000h] lookup hits our seeded table.
    h.write_code(GVAR_GAME_SEG_OFFS,
                 [DATA_SEG & 0xFF, (DATA_SEG >> 8) & 0xFF])

    # Seed the 24-entry enemy_id_table at DS:8000 with known IDs.
    table = bytes([0x10, 0x20, 0x30, 0x40, 0x05] + [0x00] * 19)
    h.write_data(ENEMY_ID_TABLE_OFFS, table)

    print(f'is_entity_known_type @ CPU 0x{proc:04X}')
    print(f'enemy_id_table seeded at DS:0x{ENEMY_ID_TABLE_OFFS:04X}: '
          f'{[f"0x{b:02X}" for b in table[:5]]}...')
    print()

    # ---- Probe A: AL=0x20, IN low-range table -> ZF=1
    zf, cf, sf, _ = probe(h, proc, 0x20)
    a_ok = (zf is True)
    print(f'Probe A: AL=0x20 (in low-range table)')
    print(f'  ZF={zf}  CF={cf}  SF={sf}    expected ZF=True   {"OK" if a_ok else "FAIL"}')

    # ---- Probe B: AL=0x08, low range NOT in our seeded table -> ZF=0
    zf, cf, sf, _ = probe(h, proc, 0x08)
    b_ok = (zf is False)
    print(f'\nProbe B: AL=0x08 (low range, NOT in table)')
    print(f'  ZF={zf}  CF={cf}  SF={sf}    expected ZF=False  {"OK" if b_ok else "FAIL"}')

    # ---- Probe C: AL=0x60, mid-range 0x49..0x7F -> ZF=1 from `cmp al,al`
    zf, cf, sf, _ = probe(h, proc, 0x60)
    c_ok = (zf is True and cf is False)
    print(f'\nProbe C: AL=0x60 (mid range 0x49..0x7F via cmp al,al)')
    print(f'  ZF={zf}  CF={cf}  SF={sf}    expected ZF=True,CF=False  {"OK" if c_ok else "FAIL"}')

    # ---- Probe D: AL=0x90, sign bit set -> ZF=0 (or al,al; jns falls thru)
    zf, cf, sf, _ = probe(h, proc, 0x90)
    d_ok = (zf is False and sf is True)
    print(f'\nProbe D: AL=0x90 (high signed; or al,al sets SF=1, then retn)')
    print(f'  ZF={zf}  CF={cf}  SF={sf}    expected ZF=False,SF=True  {"OK" if d_ok else "FAIL"}')

    if a_ok and b_ok and c_ok and d_ok:
        print('\nVERDICT: PASS: game_func_138 is `is_entity_known_type` / '
              '`classify_entity_id`.  AL is an entity-ID byte; returns '
              'ZF=1 iff the ID is "known": found in the 24-entry low-range '
              'enemy_id_table (AL < 0x49) OR in the 0x49..0x7F mid range.  '
              'AL >= 0x80 (sign bit set) returns ZF=0.  18 callers across '
              "200FIGHT use this to gate further entity processing on the "
              "returned ZF.  Rename recommendation: `is_entity_known_type`.")
        return 0
    print('\nVERDICT: REFUTED or INCONCLUSIVE: one or more probes did not '
          'match the predicted classifier behavior.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
