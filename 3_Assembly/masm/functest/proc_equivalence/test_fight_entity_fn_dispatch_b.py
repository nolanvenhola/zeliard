#!/usr/bin/env python3
"""
test_fight_entity_fn_dispatch_b.py

Probe for `entity_fn_dispatch_b`.

The proc:
  - reads [si+5]
  - masks it to a 0..7 dispatch family
  - doubles it into BX for a word table offset
  - masks AL to 0x3F
  - jumps through entity_fn_tbl_b[BX]

The test seeds every table entry with the harness return sentinel, so the
jump target is safe and the final BX/AL values are directly observable.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

ENTITY_FN_TBL_B = 0x8581
RET_SENTINEL = 0x0080


def seed_table(h: TasmHarness) -> None:
    for i in range(8):
        h.write_word(ENTITY_FN_TBL_B + i * 2, RET_SENTINEL)


def probe(h: TasmHarness, proc: int, state: int, ax: int,
          expected_bx: int, expected_al: int, label: str) -> bool:
    SI = 0x1400
    h.write_data(SI, [0] * 8)
    h.write_byte(SI + 5, state)
    seed_table(h)
    snap = h.snapshot()
    r = h.call_function(proc, regs={'si': SI, 'ax': ax, 'bx': 0}, max_steps=30)
    bx = r['regs_after']['bx']
    al = r['regs_after']['ax'] & 0xFF
    h.restore(snap)
    ok = (
        r['stopped_reason'] == 'returned_to_sentinel'
        and bx == expected_bx
        and al == expected_al
    )
    print(f'{label}: state=0x{state:02X} AX=0x{ax:04X}')
    print(f'  stopped={r["stopped_reason"]}')
    print(f'  BX=0x{bx:04X} expected 0x{expected_bx:04X}')
    print(f'  AL=0x{al:02X} expected 0x{expected_al:02X}')
    print(f'  -> {"OK" if ok else "FAIL"}')
    return ok


def main() -> int:
    flat, base = BIN_PATHS['fight']
    proc = base + resolve_proc(
        'fight', 'entity_fn_dispatch_b', fallback_names=('game_func_96',)
    )
    h = TasmHarness(flat, base)
    stub_video_drivers(h)

    ok = True
    ok &= probe(h, proc, state=0x05, ax=0x00FF,
                expected_bx=0x000A, expected_al=0x3F,
                label='Probe A')
    ok &= probe(h, proc, state=0x0B, ax=0x0042,
                expected_bx=0x0006, expected_al=0x02,
                label='Probe B')
    ok &= probe(h, proc, state=0xF8, ax=0x1234,
                expected_bx=0x0000, expected_al=0x34,
                label='Probe C')

    if ok:
        print('\nVERDICT: PASS: entity_fn_dispatch_b computes '
              'BX=2*([si+5]&7), masks AL with 0x3F, then dispatches '
              'through entity_fn_tbl_b.')
        return 0
    print('\nVERDICT: REFUTED: entity_fn_dispatch_b dispatch math diverged.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
