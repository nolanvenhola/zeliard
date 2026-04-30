#!/usr/bin/env python3
"""
test_fight_game_func_93.py

Probe of `game_func_93` at CPU 0x840B — 25 bytes, 4 callers.
Internal labels (`enemy_blit_loop`, `enemy_do_blit`) already strongly
suggest enemy-sprite blitting.  Body:
    push ax
    call game_multiply_4
    pop  ax
    cmp  byte ptr [di], 0FCh   ; FC..FF = empty/sentinel slot
    jb   enemy_do_blit
    retn                       ; empty slot: skip blit
enemy_do_blit:
    add  al, byte ptr ds:[82h] ; +map_scroll_row
    call vga_operation4
    mov  al, [di]
    jmp  word ptr cs:gfx_fn_78

We probe the [di] short-circuit gate: empty slot returns without
calling vga_operation4.  Stub game_multiply_4 and vga_operation4 as
near-call no-ops; track which stubs fire.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

CHUNK = 'fight'
GAME_FUNC_93 = 0x840B
GAME_MULTIPLY_4 = 0x866A
VGA_OPERATION4  = 0x6D73


def probe(h, di_value):
    h.write_byte(0x82, 0)         # map_scroll_row
    h.write_byte(0x1000, di_value)  # data at DS:[di]
    snap = h.snapshot()
    result = h.call_function(
        GAME_FUNC_93,
        regs={'di': 0x1000},
        stub_calls={
            GAME_MULTIPLY_4: {},     # near no-op
            VGA_OPERATION4:  {},     # near no-op
        },
        max_steps=200,
    )
    h.restore(snap)
    return result


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    print(f'game_func_93 @ CPU 0x{GAME_FUNC_93:04X}')

    # Probe A: empty slot ([di]=0xFC) -> short-circuit, only multiply stub fires
    res = probe(h, 0xFC)
    stubs = res.get('stubs_fired', [])
    a_ok = (GAME_MULTIPLY_4 in stubs and VGA_OPERATION4 not in stubs)
    print(f'\nProbe A: [di]=0xFC (empty slot)')
    print(f'  stubs fired: {[hex(s) for s in stubs]}')
    print(f'  expected: only game_multiply_4  '
          f'{"OK" if a_ok else "FAIL"}')

    # Probe B: occupied ([di]=0x10) -> both stubs fire, jmps to gfx_fn_78
    # (which is unmapped → invalid_mem_access)
    res = probe(h, 0x10)
    stubs = res.get('stubs_fired', [])
    b_ok = (GAME_MULTIPLY_4 in stubs and VGA_OPERATION4 in stubs)
    print(f'\nProbe B: [di]=0x10 (occupied slot)')
    print(f'  stubs fired: {[hex(s) for s in stubs]}')
    print(f'  expected: both game_multiply_4 + vga_operation4  '
          f'{"OK" if b_ok else "FAIL"}')

    if a_ok and b_ok:
        print('\nVERDICT: PASS: game_func_93 is `enemy_sprite_blit`.  '
              'Calls game_multiply_4 (sprite-coord scaling), gates on '
              '[di] >= 0xFC for empty-slot skip, otherwise adjusts AL '
              'by map_scroll_row and blits via vga_operation4.  '
              'Rename: `enemy_sprite_blit`.')
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
