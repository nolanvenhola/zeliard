#!/usr/bin/env python3
"""
test_fight_game_func_120.py

Probe of `game_func_120` at CPU 0x9183 — 20 bytes, 4 callers.
Static body: `add word [8Bh], ax; jnc +6; mov word [8Bh], FFFFh; ...
push si; call word ptr cs:[2014h]; pop si; retn`.

DS:[8B] is `hero_almas` (16-bit field, confirmed by existing
test_player_stats_word_layout.py).  This proc adds AX to almas with a
0xFFFF cap, then calls the far HUD-redraw at CS:[2014h] (the almas
display update).
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

CHUNK = 'fight'


def probe(h, proc, almas_initial, ax_in):
    h.write_word(0x8B, almas_initial)
    snap = h.snapshot()
    result = h.call_function(proc, regs={'ax': ax_in},
                             max_steps=200)
    almas_after = h.read_word(0x8B)
    h.restore(snap)
    return almas_after, result


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    proc = load_base + resolve_proc('fight', 'hero_almas_add',
                                    fallback_names=('game_func_120',))
    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    print(f'hero_almas_add @ CPU 0x{proc:04X}')

    cases = [
        ('A', 100, 50,    150,    'simple add'),
        ('B', 0xFFF0, 0x10, 0xFFFF, 'overflow capped to 0xFFFF'),
        ('C', 0, 0xFFFF, 0xFFFF, 'add to 0 saturates with FFFF input'),
        ('D', 0x8000, 0x8000, 0xFFFF, 'overflow to capped'),
    ]
    all_ok = True
    for label, init, ax_in, expected, desc in cases:
        almas, _ = probe(h, proc, init, ax_in)
        ok = almas == expected
        all_ok = all_ok and ok
        print(f'Probe {label}: almas={init:5d}, AX={ax_in:5d} ({desc})  '
              f'-> almas=0x{almas:04X}  expected 0x{expected:04X}  '
              f'{"OK" if ok else "FAIL"}')

    if all_ok:
        print('\nVERDICT: PASS: game_func_120 adds AX to hero_almas with '
              "0xFFFF cap, then triggers the almas HUD redraw via far "
              "CS:[2014h].  Rename: `hero_almas_add`.")
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
