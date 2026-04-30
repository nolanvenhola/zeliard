#!/usr/bin/env python3
"""
test_fight_game_func_92.py — game_func_92 at CPU 0x83F5, 22 bytes, 2 callers.

Body: tests bit-15 of word [si+7] (dirty flag).  If clear: retn.  If set:
clear bit-15, load DX = [si+7] (now without dirty bit), AL=[si+0Ch],
AH=[si+0Bh], then FALLS THROUGH (no retn) into game_func_93/enemy_sprite_blit.

So game_func_92 is `prep_dirty_blit` — sets up the blit registers for the
next-immediate enemy_sprite_blit when the dirty bit is set.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

GAME_FUNC_92 = 0x83F5
GAME_MULTIPLY_4 = 0x866A
VGA_OPERATION4  = 0x6D73


def main() -> int:
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)

    # Probe A: dirty bit clear -> immediate retn
    SI = 0x1000
    h.write_word(SI + 7, 0x1234)   # bit-15 clear
    snap = h.snapshot()
    r = h.call_function(GAME_FUNC_92, regs={'si': SI},
                        stub_calls={GAME_MULTIPLY_4: {}, VGA_OPERATION4: {}},
                        max_steps=100)
    a_ok = (r['stopped_reason'] == 'returned_to_sentinel'
            and h.read_word(SI + 7) == 0x1234
            and r['stubs_fired'] == [])
    print(f'Probe A: bit-15 clear -> immediate retn  '
          f'stops={r["stopped_reason"]}, [si+7]=0x{h.read_word(SI+7):04X}, '
          f'stubs={r["stubs_fired"]}  {"OK" if a_ok else "FAIL"}')
    h.restore(snap)

    # Probe B: dirty bit set -> clears bit, loads DX, falls into blit
    h.write_word(SI + 7, 0x9234)   # bit-15 set
    h.write_byte(SI + 0xC, 0x42)
    h.write_byte(SI + 0xB, 0x33)
    h.write_byte(0x82, 0)
    snap = h.snapshot()
    r = h.call_function(GAME_FUNC_92, regs={'si': SI, 'di': SI},
                        stub_calls={GAME_MULTIPLY_4: {}, VGA_OPERATION4: {}},
                        max_steps=100)
    cleared = h.read_word(SI + 7)
    dx_after = r['regs_after']['dx']
    b_ok = (cleared == 0x1234 and dx_after == 0x1234
            and GAME_MULTIPLY_4 in r['stubs_fired'])
    print(f'Probe B: bit-15 set -> clear bit + load + fall-through to blit')
    print(f'  [si+7] cleared: 0x{cleared:04X} expected 0x1234')
    print(f'  DX after: 0x{dx_after:04X} expected 0x1234')
    print(f'  stubs fired: {r["stubs_fired"]} (expect game_multiply_4)')
    print(f'  -> {"OK" if b_ok else "FAIL"}')
    h.restore(snap)

    if a_ok and b_ok:
        print('\nVERDICT: PASS: game_func_92 is `prep_dirty_blit` — gates on '
              "bit-15 of [si+7]; if set, clears the bit and pre-loads "
              "DX/AL/AH for the immediately-following enemy_sprite_blit "
              '(falls through, no retn).  Rename: `prep_dirty_blit`.')
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
