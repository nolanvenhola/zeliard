#!/usr/bin/env python3
"""
test_fight_game_func_106.py — try_place_tile_id_49 (was game_func_106).

Body: 4-gate placement function.  All gates must open for the action to
fire:
    1. [si+2] != 0     (charge counter not exhausted)
    2. vga_operation9 returns CF=0   (placement check succeeded)
    3. [bx+4] bit 5 == 0
    4. [bx+5] bit 5 == 0
On success: [bx+5] = ([bx+5] & 0xE0) | 0x49 ; [si+2] -= 1

The 0x49 ('I') value going into [bx+5]'s low 5 bits with high 3 bits
preserved looks like setting a tile-ID with priority/layer flags
preserved.  Plausible role: place sword/projectile sprite at slot [bx]
and consume one charge from counter [si+2].
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers, resolve_proc  # noqa: E402

# Address resolver: pick up the current CPU offset, regardless of
# rename history or source-line drift.
GAME_FUNC_106 = (
    BIN_PATHS['fight'][1]                    # load base = 0x6000
    + resolve_proc('fight', 'try_place_tile_id_49',
                   fallback_names=('game_func_106',))
)
VGA_OPERATION9 = (
    BIN_PATHS['fight'][1]
    + resolve_proc('fight', 'vga_operation9')
)


def setup_open_gates(h, *, charges=3, bx_4=0, bx_5=0):
    SI = 0x1000
    BX = 0x2000
    h.write_byte(SI + 2, charges)
    h.write_byte(BX + 4, bx_4)
    h.write_byte(BX + 5, bx_5)
    return SI, BX


def main() -> int:
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)

    print(f'game_func_106 @ CPU 0x{GAME_FUNC_106:04X}')

    # Probe A: all gates open -> placement happens
    SI, BX = setup_open_gates(h, charges=3, bx_4=0, bx_5=0xC0)  # high bits set
    snap = h.snapshot()
    r = h.call_function(GAME_FUNC_106, regs={'si': SI, 'bx': BX, 'di': 0x3000},
                        stub_calls={VGA_OPERATION9: {'cf': 0}}, max_steps=200)
    bx5 = h.read_byte(BX + 5)
    si2 = h.read_byte(SI + 2)
    a_ok = (bx5 == (0xC0 | 0x49) and si2 == 2)  # high bits preserved + 0x49 set
    print(f'\nProbe A: all gates open, charges=3, [bx+5]=0xC0')
    print(f'  [bx+5] after: 0x{bx5:02X}  expected 0xC9 (0xC0|0x49)  '
          f'{"OK" if bx5==0xC9 else "FAIL"}')
    print(f'  [si+2] after: 0x{si2:02X}  expected 2 (decremented)  '
          f'{"OK" if si2==2 else "FAIL"}')
    h.restore(snap)

    # Probe B: charges=0 -> early skip, no changes
    SI, BX = setup_open_gates(h, charges=0, bx_4=0, bx_5=0xC0)
    snap = h.snapshot()
    r = h.call_function(GAME_FUNC_106, regs={'si': SI, 'bx': BX, 'di': 0x3000},
                        stub_calls={VGA_OPERATION9: {'cf': 0}}, max_steps=200)
    bx5 = h.read_byte(BX + 5)
    si2 = h.read_byte(SI + 2)
    b_ok = (bx5 == 0xC0 and si2 == 0)
    print(f'\nProbe B: charges=0 -> skip')
    print(f'  [bx+5] unchanged: 0x{bx5:02X} (expect 0xC0)  '
          f'{"OK" if bx5==0xC0 else "FAIL"}')
    h.restore(snap)

    # Probe C: vga_operation9 returns CF=1 -> skip
    SI, BX = setup_open_gates(h, charges=3, bx_4=0, bx_5=0xC0)
    snap = h.snapshot()
    r = h.call_function(GAME_FUNC_106, regs={'si': SI, 'bx': BX, 'di': 0x3000},
                        stub_calls={VGA_OPERATION9: {'cf': 1}}, max_steps=200)
    bx5 = h.read_byte(BX + 5)
    c_ok = bx5 == 0xC0
    print(f'\nProbe C: vga_operation9 returns CF=1 -> skip')
    print(f'  [bx+5] unchanged: 0x{bx5:02X} (expect 0xC0)  '
          f'{"OK" if bx5==0xC0 else "FAIL"}')
    h.restore(snap)

    # Probe D: [bx+4] bit 5 set -> skip
    SI, BX = setup_open_gates(h, charges=3, bx_4=0x20, bx_5=0xC0)
    snap = h.snapshot()
    r = h.call_function(GAME_FUNC_106, regs={'si': SI, 'bx': BX, 'di': 0x3000},
                        stub_calls={VGA_OPERATION9: {'cf': 0}}, max_steps=200)
    bx5 = h.read_byte(BX + 5)
    d_ok = bx5 == 0xC0
    print(f'\nProbe D: [bx+4] bit 5 set -> skip')
    print(f'  [bx+5] unchanged: 0x{bx5:02X} (expect 0xC0)  '
          f'{"OK" if bx5==0xC0 else "FAIL"}')

    if a_ok and b_ok and c_ok and d_ok:
        print('\nVERDICT: PASS: game_func_106 is `try_place_tile_id_49` — '
              'gated tile placement, sets [bx+5] low 5 bits to 0x49 with '
              'high bits preserved and consumes one charge from [si+2].  '
              'Rename: `try_place_tile_id_49`.')
        return 0
    print('\nVERDICT: REFUTED.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
