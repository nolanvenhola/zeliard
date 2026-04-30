#!/usr/bin/env python3
"""
test_fight_game_func_89.py

Probe of 200FIGHT.bin's `game_func_89` at CPU 0x8354 — 20 bytes, 8 callers
(rank 2 in PHASE3_PRIORITY.md).

Static body (200FIGHT.asm:5090):
    game_func_89 proc near
        test [di], 80h        ; bit-7 = "indirect" tag
        jnz  obj_slot_write   ; tag set: write to enemy_data_ext[idx]
        mov  [di], dl
        retn
    obj_slot_write:
        mov  bl, [di]
        and  bl, 7Fh          ; clear bit 7 -> 7-bit index
        xor  bh, bh
        mov  ds:enemy_data_ext[bx], dl   ; ds:[ED20h + bx] = dl
        retn

`enemy_data_ext` is at 0xED20.  Hypothesis: tagged-slot write — DI
points to a "slot" byte; bit 7 of that byte tags whether the slot is a
direct value (write DL into [di]) or an index into the auxiliary
`enemy_data_ext` table.  Used for variable-length entity records.

Verdict
-------
  PASS  iff Probe A writes [di] directly AND Probe B/C write the
        ext-table entry without touching [di].
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

CHUNK = 'fight'
GAME_FUNC_89 = 0x8354
ENEMY_DATA_EXT = 0xED20
SLOT_AT = 0x1000


def probe(h, slot_byte_value, dl):
    h.write_byte(SLOT_AT, slot_byte_value)
    # Clear ext-table region we care about so we can detect a write
    h.write_data(ENEMY_DATA_EXT, bytes([0] * 0x80))
    snap = h.snapshot()
    result = h.call_function(
        GAME_FUNC_89,
        regs={'di': SLOT_AT, 'dx': dl & 0xFF},
        max_steps=50,
    )
    slot_after = h.read_byte(SLOT_AT)
    ext_byte = h.read_byte(ENEMY_DATA_EXT + (slot_byte_value & 0x7F))
    h.restore(snap)
    return slot_after, ext_byte, result


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print('VERDICT: INCONCLUSIVE: flat-file artefact missing')
        return 1

    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    print(f'game_func_89 @ CPU 0x{GAME_FUNC_89:04X}')
    print()

    # Probe A: bit-7 clear -> direct write
    slot, ext, _ = probe(h, slot_byte_value=0x05, dl=0x42)
    a_ok = (slot == 0x42 and ext == 0)
    print(f'Probe A: [di]=0x05 (bit-7 clear), write DL=0x42')
    print(f'  [di] after: 0x{slot:02X}    expected 0x42  {"OK" if slot==0x42 else "FAIL"}')
    print(f'  ext[5]:    0x{ext:02X}    expected 0x00  {"OK" if ext==0 else "FAIL"}')

    # Probe B: bit-7 set, index 5 -> ext[5] write
    slot, ext, _ = probe(h, slot_byte_value=0x85, dl=0x42)
    b_ok = (slot == 0x85 and ext == 0x42)
    print(f'\nProbe B: [di]=0x85 (bit-7 set, idx=5), write DL=0x42')
    print(f'  [di] after: 0x{slot:02X}    expected 0x85 (untouched)  {"OK" if slot==0x85 else "FAIL"}')
    print(f'  ext[5]:    0x{ext:02X}    expected 0x42  {"OK" if ext==0x42 else "FAIL"}')

    # Probe C: bit-7 set, index 0x7F (high) -> ext[0x7F] write
    slot, ext, _ = probe(h, slot_byte_value=0xFF, dl=0x99)
    c_ok = (slot == 0xFF and ext == 0x99)
    print(f'\nProbe C: [di]=0xFF (bit-7 set, idx=0x7F), write DL=0x99')
    print(f'  [di] after: 0x{slot:02X}    expected 0xFF  {"OK" if slot==0xFF else "FAIL"}')
    print(f'  ext[0x7F]: 0x{ext:02X}    expected 0x99  {"OK" if ext==0x99 else "FAIL"}')

    if a_ok and b_ok and c_ok:
        print('\nVERDICT: PASS: game_func_89 is `entity_slot_write_tagged` — '
              'writes DL to either [di] (bit-7 clear: direct slot) or to '
              'enemy_data_ext[[di]&7Fh] (bit-7 set: indirected slot via '
              '7-bit index).  Used by 8 callers across 200FIGHT for '
              'variable-length entity-record field updates.  Rename '
              'recommendation: `entity_slot_write_tagged`.')
        return 0
    print('\nVERDICT: REFUTED: tagged-slot semantics did not hold.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
