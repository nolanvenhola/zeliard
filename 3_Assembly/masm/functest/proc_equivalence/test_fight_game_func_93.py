#!/usr/bin/env python3
"""
test_fight_game_func_93.py

Probe of `game_func_93` at CPU 0x840B — 25 bytes, 4 callers.
Internal labels (`enemy_blit_loop`, `enemy_do_blit`) already strongly
suggest enemy-sprite blitting.  Body:
    push ax
    call calc_hud_buf_offset
    pop  ax
    cmp  byte ptr [di], 0FCh   ; FC..FF = empty/sentinel slot
    jb   enemy_do_blit
    retn                       ; empty slot: skip blit
enemy_do_blit:
    add  al, byte ptr ds:[82h] ; +map_scroll_row
    call scroll_buf_offset
    mov  al, [di]
    jmp  word ptr cs:gfx_fn_78

We probe the [di] short-circuit gate: empty slot returns without
calling scroll_buf_offset.  Stub calc_hud_buf_offset and scroll_buf_offset as
near-call no-ops; track which stubs fire.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

CHUNK = 'fight'


def probe(h, proc, calc_hud_buf_offset, scroll_buf_offset, di_value):
    h.write_byte(0x82, 0)         # map_scroll_row
    h.write_byte(0x1000, di_value)  # data at DS:[di]
    snap = h.snapshot()
    result = h.call_function(
        proc,
        regs={'di': 0x1000},
        stub_calls={
            calc_hud_buf_offset: {},  # near no-op
            scroll_buf_offset: {},    # near no-op
        },
        max_steps=200,
    )
    h.restore(snap)
    return result


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    proc = load_base + resolve_proc('fight', 'enemy_sprite_blit',
                                    fallback_names=('game_func_93',))
    calc_hud_buf_offset = load_base + resolve_proc('fight', 'calc_hud_buf_offset')
    scroll_buf_offset = load_base + resolve_proc('fight', 'scroll_buf_offset',
                                                 fallback_names=('vga_operation4',))
    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    print(f'enemy_sprite_blit @ CPU 0x{proc:04X}')

    # Probe A: empty slot ([di]=0xFC) -> short-circuit, only multiply stub fires
    res = probe(h, proc, calc_hud_buf_offset, scroll_buf_offset, 0xFC)
    stubs = res.get('stubs_fired', [])
    a_ok = (calc_hud_buf_offset in stubs and scroll_buf_offset not in stubs)
    print(f'\nProbe A: [di]=0xFC (empty slot)')
    print(f'  stubs fired: {[hex(s) for s in stubs]}')
    print(f'  expected: only calc_hud_buf_offset  '
          f'{"OK" if a_ok else "FAIL"}')

    # Probe B: occupied ([di]=0x10) -> both stubs fire, jmps to gfx_fn_78
    # (which is unmapped → invalid_mem_access)
    res = probe(h, proc, calc_hud_buf_offset, scroll_buf_offset, 0x10)
    stubs = res.get('stubs_fired', [])
    b_ok = (calc_hud_buf_offset in stubs and scroll_buf_offset in stubs)
    print(f'\nProbe B: [di]=0x10 (occupied slot)')
    print(f'  stubs fired: {[hex(s) for s in stubs]}')
    print(f'  expected: both calc_hud_buf_offset + scroll_buf_offset  '
          f'{"OK" if b_ok else "FAIL"}')

    if a_ok and b_ok:
        print('\nVERDICT: PASS: game_func_93 is `enemy_sprite_blit`.  '
              'Calls calc_hud_buf_offset, gates on '
              '[di] >= 0xFC for empty-slot skip, otherwise adjusts AL '
              'by map_scroll_row and blits via scroll_buf_offset.  '
              'Rename: `enemy_sprite_blit`.')
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
