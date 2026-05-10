#!/usr/bin/env python3
"""
test_fight_game_process_loop_2.py — Tier-3 probe for game_process_loop_2.

Body (200FIGHT.asm:3691):
    mov byte ptr ds:escape_flag, 0
    call scroll_si_from_player    ; SI = scroll_buf addr for player
    add  si, 49h                  ; move 2 rows down + 1 col right
    call scroll_si_wrap_high      ; wrap if past hud_buf
    mov  cx, 3
process_loop_3:
    push cx
    call tail_dispatch_by_slot_family
    sub  si, 24h                  ; back up one row (24h = row stride)
    call scroll_si_wrap_low
    pop  cx
    loop process_loop_3
    retn

Effect:  Visit 3 cells in the column 1 to the RIGHT of the player,
starting 2 rows below and walking upward to same row.  At each cell,
tail-dispatch entity-handling via slot family.

Probe asserts:
  - escape_flag is zeroed.
  - tail_dispatch_by_slot_family is called 3 times.
  - SI ends at player_pos+0x49 - 3*0x24 = player_pos+0x49-0x6C = player-0x23
    (after wrap_low has run to keep SI in the scroll buffer range).
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers, resolve_proc  # noqa: E402

LOAD_BASE = BIN_PATHS['fight'][1]

ESCAPE_FLAG     = 0xC014   # ds:escape_flag — let's discover from grep
SCROLL_BUF      = 0xE000
HUD_BUF         = 0xE900
GVAR_SCROLL_POS = 0xFF31
FIGHT_PLAYER_COL = 0x84
SCREEN_POSITION  = 0x83


def main() -> int:
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)

    addr_proc = LOAD_BASE + resolve_proc(
        'fight', 'game_process_loop_2',
        fallback_names=('tick_right_col_entities',))
    addr_dispatch = LOAD_BASE + resolve_proc(
        'fight', 'tail_dispatch_by_slot_family')
    print(f'game_process_loop_2 @ 0x{addr_proc:04X}')
    print(f'tail_dispatch_by_slot_family @ 0x{addr_dispatch:04X}')

    # Find escape_flag offset from EQU
    asm = (Path(__file__).parents[2] / 'working' / 'zelres2' / 'code'
           / '200FIGHT.asm').read_text(encoding='cp437', errors='replace')
    import re
    m = re.search(r'^escape_flag\s+equ\s+(0?[0-9A-Fa-f]+)h\b', asm,
                  re.MULTILINE | re.IGNORECASE)
    if not m:
        print('Could not locate escape_flag EQU; aborting probe')
        return 1
    escape_off = int(m.group(1), 16)
    print(f'escape_flag @ 0x{escape_off:04X}')

    # Player state: place player at fight_col=2, screen_pos=0,
    # gvar_scroll_pos=SCROLL_BUF.  This makes scroll_si_from_player
    # return SCROLL_BUF + 2*0x24 + 4 = SCROLL_BUF + 0x4C.
    h.write_byte(FIGHT_PLAYER_COL, 2)
    h.write_byte(SCREEN_POSITION, 0)
    h.write_word(GVAR_SCROLL_POS, SCROLL_BUF)
    # Mark escape_flag as 0xFF so we can see it cleared.
    h.write_byte(escape_off, 0xFF)

    snap = h.snapshot()
    r = h.call_function(
        addr_proc, regs={},
        stub_calls={addr_dispatch: {}},
        max_steps=200,
    )

    dispatch_calls = r.get('stubs_fired', []).count(addr_dispatch)
    escape_after = h.read_byte(escape_off)
    si_after = r['regs_after']['si']

    print(f'\nProbe: escape_flag was 0xFF, '
          f'tail_dispatch stubbed RET-only')
    print(f'  escape_flag after:  0x{escape_after:02X}  '
          f'expect 0x00  '
          f'{"OK" if escape_after == 0 else "FAIL"}')
    print(f'  dispatch calls:     {dispatch_calls}  expect 3  '
          f'{"OK" if dispatch_calls == 3 else "FAIL"}')

    # Initial SI from scroll_si_from_player =
    #   fight_player_col*0x24 + (screen_pos+4) + gvar_scroll_pos
    # = 2*0x24 + 4 + SCROLL_BUF = 0x4C + SCROLL_BUF = 0xE04C
    # After +0x49 -> 0xE095, then 3 iterations of (-0x24): 0xE071, 0xE04D, 0xE029
    # No wraps needed (none of these go below SCROLL_BUF or above HUD_BUF).
    expected_si = SCROLL_BUF + 2*0x24 + 4 + 0x49 - 3*0x24
    print(f'  SI after:           0x{si_after:04X}  '
          f'expect 0x{expected_si:04X}  '
          f'{"OK" if si_after == expected_si else "FAIL"}')

    h.restore(snap)

    if (escape_after == 0 and dispatch_calls == 3 and
            si_after == expected_si):
        print('\nVERDICT: PASS — game_process_loop_2 walks 3 cells in '
              'the column right of the player (2/1/0 rows below) and '
              'tail-dispatches entity handling at each.  Rename: '
              '`tick_right_col_entities`.')
        return 0
    print('\nVERDICT: FAIL')
    return 1


if __name__ == '__main__':
    sys.exit(main())
