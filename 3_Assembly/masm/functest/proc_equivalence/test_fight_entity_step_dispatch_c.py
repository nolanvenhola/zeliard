#!/usr/bin/env python3
"""
test_fight_entity_step_dispatch_c.py

Probe for `entity_step_dispatch_c`.

The proc:
  - if [si+5] bit 6 is set, calls update_entity_dir_from_path
  - if that update returns CF=1, returns immediately
  - otherwise computes BX=2*([si+5]&7)
  - calls entity_fn_tbl_c[BX]
  - masks [si+1] with 0x3F after the handler returns

The test points all C-table entries at a tiny near-RET thunk so the
indirect call returns normally and the post-dispatch mask is observable.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, resolve_proc, stub_video_drivers  # noqa: E402

ENTITY_FN_TBL_C = 0x85C2
RET_THUNK = 0x0200


def seed_table(h: TasmHarness) -> None:
    h.write_code(RET_THUNK, [0xC3])
    for i in range(8):
        h.write_word(ENTITY_FN_TBL_C + i * 2, RET_THUNK)


def run_case(h: TasmHarness, proc: int, update_dir: int, *, state: int,
             pos_byte: int, stub_update, expected_pos: int,
             expected_bx, expected_update_calls: int, label: str) -> bool:
    SI = 0x1500
    h.write_data(SI, [0] * 8)
    h.write_byte(SI + 1, pos_byte)
    h.write_byte(SI + 5, state)
    seed_table(h)
    stubs = {}
    if stub_update is not None:
        stubs[update_dir] = {'cf': 1 if stub_update else 0}
    snap = h.snapshot()
    r = h.call_function(proc, regs={'si': SI, 'bx': 0}, stub_calls=stubs, max_steps=80)
    pos_after = h.read_byte(SI + 1)
    bx_after = r['regs_after']['bx']
    update_calls = r['stubs_fired'].count(update_dir)
    h.restore(snap)

    ok = (
        r['stopped_reason'] == 'returned_to_sentinel'
        and pos_after == expected_pos
        and update_calls == expected_update_calls
        and (expected_bx is None or bx_after == expected_bx)
    )
    print(f'{label}: state=0x{state:02X} [si+1]=0x{pos_byte:02X}')
    print(f'  stopped={r["stopped_reason"]}')
    print(f'  update calls={update_calls} expected {expected_update_calls}')
    print(f'  BX=0x{bx_after:04X} expected {"any" if expected_bx is None else f"0x{expected_bx:04X}"}')
    print(f'  [si+1]=0x{pos_after:02X} expected 0x{expected_pos:02X}')
    print(f'  -> {"OK" if ok else "FAIL"}')
    return ok


def main() -> int:
    flat, base = BIN_PATHS['fight']
    proc = base + resolve_proc(
        'fight', 'entity_step_dispatch_c', fallback_names=('game_func_97',)
    )
    update_dir = base + resolve_proc(
        'fight', 'update_entity_dir_from_path', fallback_names=('game_func_98',)
    )
    h = TasmHarness(flat, base)
    stub_video_drivers(h)

    ok = True
    ok &= run_case(
        h, proc, update_dir,
        state=0x05, pos_byte=0xFF, stub_update=None,
        expected_pos=0x3F, expected_bx=0x000A, expected_update_calls=0,
        label='Probe A bit6 clear',
    )
    ok &= run_case(
        h, proc, update_dir,
        state=0x45, pos_byte=0xFF, stub_update=True,
        expected_pos=0xFF, expected_bx=None, expected_update_calls=1,
        label='Probe B bit6 set update blocks',
    )
    ok &= run_case(
        h, proc, update_dir,
        state=0x45, pos_byte=0xFF, stub_update=False,
        expected_pos=0x3F, expected_bx=0x000A, expected_update_calls=1,
        label='Probe C bit6 set update allows',
    )

    if ok:
        print('\nVERDICT: PASS: entity_step_dispatch_c gates optional path '
              'update on bit-6, returns early on update CF=1, otherwise '
              'dispatches via entity_fn_tbl_c and masks [si+1] with 0x3F.')
        return 0
    print('\nVERDICT: REFUTED: entity_step_dispatch_c behavior diverged.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
