#!/usr/bin/env python3
"""
test_fight_try_place_3cell_entity_row.py — Tier-3 probe for the proc
formerly known as `game_process_loop_3` (deferred per AUDIT_TODO.md).

Body (200FIGHT.asm:4743):
    push dx
    call find_and_blit_map_entry      ; produces map entry state (stubbed)
    pop  dx
    mov  bx, si                       ; save current scroll-buf SI
    add  si, 23h                      ; SI := SI + 0x23 (next row + 0x23-0x24=-1 col)
    call scroll_si_wrap_high
    test byte ptr [si], 80h
    clc                                ; CF := 0
    jz   check_3slots                  ; bit 7 clear -> try placement
    retn                                ; bit 7 set: return CF=0 (no placement)

check_3slots:
    mov  cx, 3
check_3_slots:
    inc  si
    test byte ptr [si], 0FFh
    jz   slot_empty_ok                 ; ZF=1 (slot is 0): continue
    retn                                ; non-zero: return CF=0 (no placement)
slot_empty_ok:
    loop check_3_slots

    mov  si, bx                        ; restore base SI
    add  si, 24h                       ; advance one row
    call scroll_si_wrap_high
    push di
    mov  di, si
    mov  cx, 3
draw_3_cells:
    push dx; push bx
    call entity_slot_write_tagged     ; write tagged entity at DI
    pop  bx; xchg di, bx
    push bx
    xor  dl, dl
    call entity_slot_write_tagged     ; second write
    pop  bx; xchg di, bx
    inc  di; inc bx
    pop  dx; inc dl
    loop draw_3_cells

    pop  di
    inc  byte ptr [di+2]
    and  byte ptr [di+2], 3Fh
    stc                                ; CF := 1 (placement succeeded)
    retn

Caller `try_top_scroll_direction` semantics:
    call try_place_3cell_entity_row
    jnc  check_vga9                    ; CF=0: continue normally
    pop  ax                            ; CF=1: deep abort, end of frame
    mov  [gvar_pose_idx], 80h
    jmp  process_loop_end

So:
    CF=1 = SUCCESSFUL placement (3 cells were empty; entity was written)
    CF=0 = NO placement (cell at SI+0x23 had bit 7 set, OR one of next 3
           cells was non-zero)

This resolves the AUDIT_TODO ambiguity: the body's `clc` placement is
NOT reversed — every early-retn path returns CF=0; only the all-clear
path falls through to `stc; retn`.  The caller treats CF=1 as "abort
the frame loop" because once a new entity is placed we don't need to
keep scanning for more.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers, resolve_proc  # noqa: E402

LOAD_BASE = BIN_PATHS['fight'][1]

# Scroll buffer base (so SI lands inside writable scroll-buf range)
SCROLL_BUF = 0xE000


def fresh():
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)
    return h


def main() -> int:
    proc_addr = LOAD_BASE + resolve_proc(
        'fight', 'try_place_3cell_entity_row',
        fallback_names=('game_process_loop_3',))
    find_blit_addr = LOAD_BASE + resolve_proc(
        'fight', 'find_and_blit_map_entry')
    wrap_high_addr = LOAD_BASE + resolve_proc(
        'fight', 'scroll_si_wrap_high')
    entity_write_addr = LOAD_BASE + resolve_proc(
        'fight', 'entity_slot_write_tagged')

    print(f'try_place_3cell_entity_row @ 0x{proc_addr:04X}')
    print(f'  find_and_blit_map_entry  @ 0x{find_blit_addr:04X}')
    print(f'  scroll_si_wrap_high      @ 0x{wrap_high_addr:04X}')
    print(f'  entity_slot_write_tagged @ 0x{entity_write_addr:04X}')

    SI_BASE = SCROLL_BUF + 0x100  # somewhere mid-buffer, room for +0x23 offset

    stubs = {
        find_blit_addr: {},
        wrap_high_addr: {},
        entity_write_addr: {},
    }

    results = {}

    # ----- Probe A: cell at SI+0x23 has bit 7 SET (cell occupied) ----
    # Expected: early retn at line 4753 with CF=0 (no placement)
    h = fresh()
    h.write_byte(SI_BASE + 0x23, 0x80)         # bit 7 set
    snap = h.snapshot()
    r = h.call_function(proc_addr,
                        regs={'si': SI_BASE, 'di': 0x3000},
                        stub_calls=stubs, max_steps=200)
    cf = r['flags_after']['CF']
    write_calls = r.get('stubs_fired', []).count(entity_write_addr)
    print(f'\nProbe A: [SI+0x23]=0x80 (bit 7 set, cell occupied)')
    print(f'  CF after: {cf}  expect False (no placement)  '
          f'{"OK" if cf is False else "FAIL"}')
    print(f'  entity_slot_write_tagged calls: {write_calls}  expect 0  '
          f'{"OK" if write_calls == 0 else "FAIL"}')
    results['A'] = (cf is False and write_calls == 0)
    h.restore(snap)

    # ----- Probe B: [SI+0x23]=0; first slot ([SI+0x24]) non-zero ----
    # Expected: enters check_3slots, but first inc-si then test [si] != 0,
    # so retn at line 4762 with CF=0 (no placement).
    h = fresh()
    h.write_byte(SI_BASE + 0x23, 0x00)         # bit 7 clear
    h.write_byte(SI_BASE + 0x24, 0x42)         # non-zero in first slot
    snap = h.snapshot()
    r = h.call_function(proc_addr,
                        regs={'si': SI_BASE, 'di': 0x3000},
                        stub_calls=stubs, max_steps=200)
    cf = r['flags_after']['CF']
    write_calls = r.get('stubs_fired', []).count(entity_write_addr)
    print(f'\nProbe B: [SI+0x23]=0, [SI+0x24]=0x42 (first slot non-zero)')
    print(f'  CF after: {cf}  expect False  '
          f'{"OK" if cf is False else "FAIL"}')
    print(f'  entity_slot_write_tagged calls: {write_calls}  expect 0  '
          f'{"OK" if write_calls == 0 else "FAIL"}')
    results['B'] = (cf is False and write_calls == 0)
    h.restore(snap)

    # ----- Probe C: [SI+0x23]=0, all 3 slots zero, 0x24 row ----
    # Expected: full path, entity_slot_write_tagged called 6 times
    # (3 iterations of draw_3_cells, each iteration makes 2 calls),
    # CF=1 (stc at end).
    h = fresh()
    h.write_byte(SI_BASE + 0x23, 0x00)  # bit 7 clear
    # Slots [SI+0x24], [SI+0x25], [SI+0x26] already zero (DS is zeroed)
    snap = h.snapshot()
    r = h.call_function(proc_addr,
                        regs={'si': SI_BASE, 'di': 0x3000},
                        stub_calls=stubs, max_steps=400)
    cf = r['flags_after']['CF']
    write_calls = r.get('stubs_fired', []).count(entity_write_addr)
    print(f'\nProbe C: [SI+0x23]=0, all 3 slots zero -> placement happens')
    print(f'  CF after: {cf}  expect True (placement succeeded)  '
          f'{"OK" if cf is True else "FAIL"}')
    print(f'  entity_slot_write_tagged calls: {write_calls}  expect 6  '
          f'(3 iterations * 2 calls each)  '
          f'{"OK" if write_calls == 6 else "FAIL"}')
    results['C'] = (cf is True and write_calls == 6)
    h.restore(snap)

    # ----- Probe D: [SI+0x23]=0, [SI+0x26]=0xFF (third slot non-zero) ----
    # Expected: loop runs 2 iterations OK, on 3rd inc si, test fails,
    # retn with CF=0.
    h = fresh()
    h.write_byte(SI_BASE + 0x23, 0x00)
    h.write_byte(SI_BASE + 0x26, 0xFF)
    snap = h.snapshot()
    r = h.call_function(proc_addr,
                        regs={'si': SI_BASE, 'di': 0x3000},
                        stub_calls=stubs, max_steps=200)
    cf = r['flags_after']['CF']
    write_calls = r.get('stubs_fired', []).count(entity_write_addr)
    print(f'\nProbe D: [SI+0x23]=0, [SI+0x26]=0xFF (third slot non-zero)')
    print(f'  CF after: {cf}  expect False  '
          f'{"OK" if cf is False else "FAIL"}')
    print(f'  entity_slot_write_tagged calls: {write_calls}  expect 0  '
          f'{"OK" if write_calls == 0 else "FAIL"}')
    results['D'] = (cf is False and write_calls == 0)
    h.restore(snap)

    # ---------- summary ----------
    print('\n========================== SUMMARY ==========================')
    for k, ok in results.items():
        print(f'  Probe {k}: {"PASS" if ok else "FAIL"}')

    if all(results.values()):
        print('\nVERDICT: PASS — try_place_3cell_entity_row semantics confirmed:')
        print('  CF=1 -> successful placement (3 cells were empty, '
              'entity_slot_write_tagged called 6 times)')
        print('  CF=0 -> no placement (cell at SI+0x23 bit 7 set, OR one '
              'of next 3 cells non-zero)')
        print('  Body\'s `clc` placement is NOT reversed: every early-retn '
              'path returns CF=0; only the all-clear path falls through to '
              '`stc; retn`.')
        print('  Caller `try_top_scroll_direction` treats CF=1 as '
              '"abort frame loop because new entity was placed."')
        return 0
    print('\nVERDICT: REFUTED — at least one probe failed.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
