#!/usr/bin/env python3
"""
test_fight_prep_boss_dirty_blit.py

Probe for `prep_boss_dirty_blit`, the boss/sprite-work-buffer sibling of
`prep_dirty_blit`.

Body:
  - tests bit 15 of word [si+3]
  - if clear: returns immediately
  - if set: clears bit 15, loads DX=[si+3], AH=[si+5], AL=[si+6], then
    jumps into the shared enemy_blit_loop

Verdict:
  PASS iff the clear path is inert and the dirty path clears [si+3],
  loads DX/AH/AL from the sprite-work record, and reaches the shared blit
  loop.  The dirty probe seeds [DI]=0xFC so the shared loop returns before
  consuming AL.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402


def main() -> int:
    flat, base = BIN_PATHS['fight']
    prep_boss_dirty_blit = base + resolve_proc(
        'fight', 'prep_boss_dirty_blit', fallback_names=('game_func_103',)
    )
    calc_hud_buf_offset = base + resolve_proc('fight', 'calc_hud_buf_offset')
    scroll_buf_offset = base + resolve_proc(
        'fight', 'scroll_buf_offset', fallback_names=('vga_operation4',)
    )

    h = TasmHarness(flat, base)
    stub_video_drivers(h)

    SI = 0x1200

    # Probe A: dirty bit clear -> immediate return, no blit helpers.
    h.write_word(SI + 3, 0x2345)
    h.write_byte(SI + 5, 0x33)
    h.write_byte(SI + 6, 0x42)
    snap = h.snapshot()
    r = h.call_function(
        prep_boss_dirty_blit,
        regs={'si': SI},
        stub_calls={calc_hud_buf_offset: {}, scroll_buf_offset: {}},
        max_steps=100,
    )
    a_ok = (
        r['stopped_reason'] == 'returned_to_sentinel'
        and h.read_word(SI + 3) == 0x2345
        and r['stubs_fired'] == []
    )
    print('Probe A: bit-15 clear -> immediate retn')
    print(f'  stopped={r["stopped_reason"]}, [si+3]=0x{h.read_word(SI+3):04X}, '
          f'stubs={r["stubs_fired"]}  {"OK" if a_ok else "FAIL"}')
    h.restore(snap)

    # Probe B: dirty bit set -> clear bit, load registers, enter blit loop.
    h.write_word(SI + 3, 0xA345)
    h.write_byte(SI + 5, 0x33)
    h.write_byte(SI + 6, 0x42)
    h.write_byte(SI, 0xFC)
    h.write_byte(0x82, 0)
    snap = h.snapshot()
    r = h.call_function(
        prep_boss_dirty_blit,
        regs={'si': SI, 'di': SI},
        stub_calls={calc_hud_buf_offset: {}, scroll_buf_offset: {}},
        max_steps=100,
    )
    cleared = h.read_word(SI + 3)
    dx_after = r['regs_after']['dx']
    ax_after = r['regs_after']['ax']
    b_ok = (
        cleared == 0x2345
        and dx_after == 0x2345
        and (ax_after & 0xFFFF) == 0x3342
        and calc_hud_buf_offset in r['stubs_fired']
    )
    print('Probe B: bit-15 set -> clear bit + load + jump to blit loop')
    print(f'  [si+3] cleared: 0x{cleared:04X} expected 0x2345')
    print(f'  DX after:       0x{dx_after:04X} expected 0x2345')
    print(f'  AX after:       0x{ax_after:04X} expected 0x3342')
    print(f'  stubs fired:    {r["stubs_fired"]} (expect calc_hud_buf_offset)')
    print(f'  -> {"OK" if b_ok else "FAIL"}')
    h.restore(snap)

    if a_ok and b_ok:
        print('\nVERDICT: PASS: prep_boss_dirty_blit gates on bit-15 of '
              '[si+3]; if set, it clears the bit and pre-loads DX/AH/AL '
              'for enemy_blit_loop.')
        return 0

    print('\nVERDICT: REFUTED: prep_boss_dirty_blit did not match the dirty-bit oracle.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
