#!/usr/bin/env python3
"""
test_fight_game_func_141.py

Probe of 200FIGHT.bin's `game_func_141` at CPU 0x96A8 — 32 bytes,
6 callers (rank 3 in PHASE3_PRIORITY.md).

Static body (200FIGHT.asm:7797):
    game_func_141 proc near
        mov  bx, ax
        sub  ax, [80h]            ; ax -= map_scroll_col
        jnc  pos_to_screen        ; on no-underflow, normal path
        mov  ax, 23h              ; (left-edge wrap) ax = 0x23
        sub  ax, bx               ; ax = 0x23 - input_ax
        jnc  check_left_bound     ; if 0x23 >= input_ax, take wrap branch
        retn                      ; both underflowed: return ax negative
    check_left_bound:
        mov  ax, ds:map_width
        sub  ax, [80h]
        add  ax, bx               ; ax = (map_width - scroll_col) + input
    pos_to_screen:                ; (the inner label is named in source!)
        xchg bx, ax
        mov  ax, 23h
        sub  ax, bx               ; ax = 0x23 - bx
        retn

The inner label `pos_to_screen` reveals the function's intent:
WORLD-X → SCREEN-X transform.  Output AX = 0x23 - screen_col (mirrored
left-to-right; 0x23 = 35 is the on-screen tile width).

Two probes confirm the two main paths:
  A. Normal in-screen world position (input >= map_scroll_col)
  B. Off-left-edge with map-width wrap

Verdict
-------
  PASS-RENAME  iff outputs match the predicted formulae:
    Path A: ax_out = 0x23 - (input_ax - scroll_col)
    Path B: ax_out = 0x23 - (map_width - scroll_col + input_ax)
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

CHUNK = 'fight'


def probe(h, proc, input_ax, scroll_col, map_w):
    h.write_word(0x80, scroll_col)        # map_scroll_col
    h.write_word(0xC002, map_w)           # map_width (data segment 0xC002)
    snap = h.snapshot()
    result = h.call_function(
        proc,
        regs={'ax': input_ax & 0xFFFF},
        max_steps=50,
    )
    ax_out = result['regs_after']['ax']
    h.restore(snap)
    return ax_out


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    proc = load_base + resolve_proc('fight', 'convert_world_x_to_screen_x',
                                    fallback_names=('game_func_141',))
    if not flat_path.exists():
        print('VERDICT: INCONCLUSIVE: flat-file artefact missing')
        return 1

    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    print(f'convert_world_x_to_screen_x @ CPU 0x{proc:04X}')
    print()

    # Probe A: input=20, scroll_col=10, map_w=40
    # Path 1: ax = 20 - 10 = 10 (CF=0). pos_to_screen.
    # xchg bx, ax -> bx=10, ax=20.  mov ax,0x23. sub ax,bx -> 0x23-10 = 0x19 = 25
    expect_a = 0x23 - (20 - 10)
    got_a = probe(h, proc, 20, 10, 40)
    a_ok = (got_a == expect_a)
    print(f'Probe A: input=20, scroll_col=10 (in-screen normal path)')
    print(f'  ax_out = 0x{got_a:04X}    expected 0x{expect_a:04X}  {"OK" if a_ok else "FAIL"}')

    # Probe B: input=2, scroll_col=5, map_w=40
    # Path 2: ax = 2 - 5 = -3 (CF=1). Skip jnc.
    # mov ax,0x23. sub ax,bx (=2) = 0x21 (CF=0). jnc fires -> check_left_bound.
    # ax = map_width(40) - scroll(5) = 35. add ax,bx (=2) -> 37.
    # pos_to_screen: xchg -> bx=37, ax=2.  mov ax,0x23. sub ax,37 = 0xFFFE
    expect_b = (0x23 - (40 - 5 + 2)) & 0xFFFF
    got_b = probe(h, proc, 2, 5, 40)
    b_ok = (got_b == expect_b)
    print(f'\nProbe B: input=2, scroll_col=5, map_w=40 (off-left-edge wrap)')
    print(f'  ax_out = 0x{got_b:04X}    expected 0x{expect_b:04X}  {"OK" if b_ok else "FAIL"}')

    # Probe C: input=10, scroll_col=10 (boundary; ax-scroll = 0, CF=0)
    expect_c = 0x23 - 0
    got_c = probe(h, proc, 10, 10, 40)
    c_ok = (got_c == expect_c)
    print(f'\nProbe C: input=scroll_col=10 (boundary; in-screen)')
    print(f'  ax_out = 0x{got_c:04X}    expected 0x{expect_c:04X}  {"OK" if c_ok else "FAIL"}')

    if a_ok and b_ok and c_ok:
        print('\nVERDICT: PASS: game_func_141 transforms world-X to screen-X.  '
              'In-screen path: ax_out = 0x23 - (input - scroll_col).  '
              'Off-left wrap path: ax_out = 0x23 - (map_width - scroll_col + input).  '
              'The 0x23 (35-tile screen-width) and inner-label `pos_to_screen` '
              'confirm the role.  Rename recommendation: `world_x_to_screen_x`.')
        return 0
    print('\nVERDICT: REFUTED: outputs did not match predicted formulae.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
