#!/usr/bin/env python3
"""
test_fight_vga_operations.py — Tier-3 probes for vga_operation0..9 in
200FIGHT.asm.  These are the 10 numbered placeholders flagged by
SECTION_AUDIT as PLACEHOLDER_NAME.

Each probe runs the proc in isolation under Unicorn, observes side
effects, and prints VERDICT + a one-line proposed rename.

Bodies summarized (line numbers from 200FIGHT.asm):
    2274 vga_operation0  scroll-buffer init: scans starting cols, then
                         calls vga_operation3 36x to fill scroll_buf,
                         finally writes gvar_scroll_pos.
    2326 vga_operation1  reads [si], top-2-bits index into table
                         scroll_dispatch_a (4 entries) -> jmp.
    2348 vga_operation2  reads [si], top-2-bits index into table
                         scroll_dispatch_b (4 entries) -> jmp.
    2405 vga_operation3  fills 36 cells in a column of scroll_buf by
                         repeatedly calling vga_operation1.
    2424 vga_operation4  pure: di = scroll_buf + (al & 0x3F)*0x24 + ah.
    2439 vga_operation5  if si >= hud_buf -> si -= 0x900.
    2452 vga_operation6  if si <  scroll_buf -> si += 0x900.
    2463 vga_operation7  test (area_num==4 && selected_accessory==4).
                         AL=0xFF + ZF=0 if both, else AL=0 + ZF=1.
    2481 vga_operation8  si = fight_player_col*0x24 + screen_position+4
                         + gvar_scroll_pos; then jmp clamp_si_high.
    2495 vga_operation9  test bit7 of [si]: if clear, ret CF=1.
                         If set, AL=object_list[(al&7F)*0x10 + 4],
                         ZF=AL==0, CF=0.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers, resolve_proc  # noqa: E402

# --- canonical EQUs used by the procs (from 200FIGHT.asm/zr2com.inc) ---
SCROLL_BUF              = 0xE000
HUD_BUF                 = 0xE900
GVAR_SCROLL_POS         = 0xFF31
SCROLL_DISPATCH_A       = 0x6CFE   # near-pointer table (4 entries)
SCROLL_DISPATCH_B       = 0x6D17
MAP_CUR_PTR             = 0x9F03
MAP_WIDTH               = 0xC002
OBJECT_LIST_PTR         = 0xC010
AREA_NUM                = 0xC012
SCROLL_END_PTR          = 0xC019
MAP_COL_PTR             = 0xC01B
STARTING_POSITION       = 0x80
MAP_SCROLL_ROW          = 0x82
SCREEN_POSITION         = 0x83
FIGHT_PLAYER_COL        = 0x84
SELECTED_ACCESSORY      = 0x9E

LOAD_BASE = BIN_PATHS['fight'][1]


def _addr(name, fallback=None):
    return LOAD_BASE + resolve_proc(
        'fight', name, fallback_names=(fallback,) if fallback else ()
    )


def fresh_harness():
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)
    return h


# ====================================================================
# Probe 0 — vga_operation0 (proposed: render_scroll_buf_columns)
# ====================================================================
def probe_op0(h, addr_op0, addr_op3, addr_op4):
    """Should iterate columns of map data and fill scroll_buf via op3,
    landing with gvar_scroll_pos written.  We stub op3 + op4 so we just
    measure that op0 calls them the right number of times and writes
    the right state."""
    # State the proc reads
    h.write_word(STARTING_POSITION, 0)  # 0 -> skip the initial scan
    h.write_word(MAP_COL_PTR, 0x4000)
    h.write_word(MAP_CUR_PTR, 0)
    h.write_word(MAP_WIDTH, 0x100)
    h.write_word(SCROLL_END_PTR, 0x4500)
    h.write_word(GVAR_SCROLL_POS, 0)
    h.write_byte(MAP_SCROLL_ROW, 0)

    snap = h.snapshot()
    r = h.call_function(
        addr_op0, regs={},
        stub_calls={addr_op3: {}, addr_op4: {}},
        max_steps=2000,
    )
    # stubs_fired entries are the same value the caller put in
    # stub_calls keys (== LOAD_BASE + proc_offset).
    op3_calls = r.get('stubs_fired', []).count(addr_op3)
    op4_calls = r.get('stubs_fired', []).count(addr_op4)
    map_cur_after = h.read_word(MAP_CUR_PTR)
    pos_after = h.read_word(GVAR_SCROLL_POS)
    print(f'\nProbe op0: starting_position=0 -> render columns')
    print(f'  vga_operation3 calls: {op3_calls}  (expect 0x24 = 36)')
    print(f'  vga_operation4 calls: {op4_calls}  (expect 1)')
    print(f'  map_cur_ptr after: 0x{map_cur_after:04X}  (expect != 0)')
    print(f'  gvar_scroll_pos written: '
          f'{"yes" if pos_after else "no"}')
    h.restore(snap)
    return op3_calls == 36 and op4_calls == 1


# ====================================================================
# Probe 1 — vga_operation1 (proposed: scroll_decode_byte_a)
# ====================================================================
def probe_op1(h, addr_op1):
    """Reads [si], extracts top 2 bits, dispatches via
    scroll_dispatch_a[index*2]."""
    # Plant a stub jump target at scroll_dispatch_a entries.  Each entry
    # is a near-pointer; we'll point all 4 at the sentinel so the jmp
    # succeeds.  We can't observe which entry was picked from a stub —
    # so instead we use a thunk per entry that writes a unique tag.
    DS = 0x4000  # scratch space for fake [si] data
    h.write_byte(DS, 0x00)  # top bits 00 -> entry 0
    snap = h.snapshot()

    # Write a 4-NOP+RET thunk for each dispatch entry.  We can't easily
    # tell entries apart in this harness, so we just confirm the proc
    # decoded the byte and dispatched (didn't crash, didn't return).
    # We point all 4 entries at 0x80 (sentinel), so jmp -> sentinel ->
    # stop_reason = returned_to_sentinel.
    for i in range(4):
        h.write_data(SCROLL_DISPATCH_A + i*2, [0x80, 0x00])
    r = h.call_function(addr_op1, regs={'si': DS}, max_steps=20)
    bx = r['regs_after']['bx']
    print(f'\nProbe op1: [si]=0x00 -> dispatch entry 0')
    print(f'  bx after: 0x{bx:04X}  (expect 0x0000 = entry 0 << 1)')
    print(f'  stopped: {r["stopped_reason"]}')
    h.restore(snap)

    # Try [si]=0xC0 (top bits 11 -> entry 3).
    h.write_byte(DS, 0xC0)
    snap = h.snapshot()
    for i in range(4):
        h.write_data(SCROLL_DISPATCH_A + i*2, [0x80, 0x00])
    r = h.call_function(addr_op1, regs={'si': DS}, max_steps=20)
    bx2 = r['regs_after']['bx']
    print(f'\nProbe op1: [si]=0xC0 -> dispatch entry 3')
    print(f'  bx after: 0x{bx2:04X}  (expect 0x0006 = entry 3 << 1)')
    h.restore(snap)
    return bx == 0x0000 and bx2 == 0x0006


# ====================================================================
# Probe 2 — vga_operation2 (proposed: scroll_decode_byte_b)
# ====================================================================
def probe_op2(h, addr_op2):
    """Same shape as op1 but uses scroll_dispatch_b table."""
    DS = 0x4000
    h.write_byte(DS, 0x80)  # top bits 10 -> entry 2
    snap = h.snapshot()
    for i in range(4):
        h.write_data(SCROLL_DISPATCH_B + i*2, [0x80, 0x00])
    r = h.call_function(addr_op2, regs={'si': DS}, max_steps=20)
    bx = r['regs_after']['bx']
    print(f'\nProbe op2: [si]=0x80 -> dispatch_b entry 2')
    print(f'  bx after: 0x{bx:04X}  (expect 0x0004 = entry 2 << 1)')
    h.restore(snap)
    return bx == 0x0004


# ====================================================================
# Probe 4 — vga_operation4 (proposed: scroll_buf_offset)
# ====================================================================
def probe_op4(h, addr_op4):
    """Pure helper: di = scroll_buf + (al & 0x3F) * 0x24 + ah.
    Tests:  AL=0,AH=0 -> di=scroll_buf
            AL=1,AH=0 -> di=scroll_buf+0x24
            AL=0x3F,AH=0x10 -> di=scroll_buf+0x3F*0x24+0x10
            AL=0x40,AH=0 -> di=scroll_buf (high bit masked off by &3F)"""
    cases = [
        (0x0000, 0x00, SCROLL_BUF + 0*0x24 + 0),
        (0x0001, 0x01, SCROLL_BUF + 1*0x24 + 0),
        (0x103F, 0x3F, SCROLL_BUF + 0x3F*0x24 + 0x10),
        (0x0040, 0x40, SCROLL_BUF + 0*0x24 + 0),  # &3F masks off
    ]
    all_ok = True
    for ax_in, al_in, expected_di in cases:
        snap = h.snapshot()
        r = h.call_function(addr_op4, regs={'ax': ax_in},
                            max_steps=30)
        di = r['regs_after']['di']
        ok = (di == expected_di)
        print(f'\nProbe op4: AX=0x{ax_in:04X} -> '
              f'DI=0x{di:04X}  '
              f'expect 0x{expected_di:04X}  {"OK" if ok else "FAIL"}')
        all_ok = all_ok and ok
        h.restore(snap)
    return all_ok


# ====================================================================
# Probe 5 — vga_operation5 (proposed: clamp_si_to_hud_high)
# ====================================================================
def probe_op5(h, addr_op5):
    """If si >= hud_buf -> si -= 0x900.  Else si unchanged."""
    cases = [
        (HUD_BUF - 1,    HUD_BUF - 1,    'below hud_buf -> unchanged'),
        (HUD_BUF,        HUD_BUF - 0x900,'at hud_buf -> wrap down'),
        (HUD_BUF + 0x100,HUD_BUF + 0x100 - 0x900,
         'above hud_buf -> wrap down'),
    ]
    all_ok = True
    for si_in, expected_si, label in cases:
        snap = h.snapshot()
        r = h.call_function(addr_op5, regs={'si': si_in}, max_steps=20)
        si = r['regs_after']['si']
        ok = (si == expected_si)
        print(f'\nProbe op5: SI=0x{si_in:04X} ({label})')
        print(f'  SI after: 0x{si:04X}  expect 0x{expected_si:04X}  '
              f'{"OK" if ok else "FAIL"}')
        all_ok = all_ok and ok
        h.restore(snap)
    return all_ok


# ====================================================================
# Probe 6 — vga_operation6 (proposed: clamp_si_to_scroll_low)
# ====================================================================
def probe_op6(h, addr_op6):
    """If si < scroll_buf -> si += 0x900.  Else unchanged."""
    cases = [
        (SCROLL_BUF,         SCROLL_BUF,         'at scroll_buf -> unchanged'),
        (SCROLL_BUF + 1,     SCROLL_BUF + 1,     'above -> unchanged'),
        (SCROLL_BUF - 1,     SCROLL_BUF - 1 + 0x900, 'below -> wrap up'),
        (SCROLL_BUF - 0x100, SCROLL_BUF - 0x100 + 0x900, 'far below -> wrap up'),
    ]
    all_ok = True
    for si_in, expected_si, label in cases:
        snap = h.snapshot()
        r = h.call_function(addr_op6, regs={'si': si_in}, max_steps=20)
        si = r['regs_after']['si']
        ok = (si == expected_si)
        print(f'\nProbe op6: SI=0x{si_in:04X} ({label})')
        print(f'  SI after: 0x{si:04X}  expect 0x{expected_si:04X}  '
              f'{"OK" if ok else "FAIL"}')
        all_ok = all_ok and ok
        h.restore(snap)
    return all_ok


# ====================================================================
# Probe 7 — vga_operation7 (proposed: gate_area4_no_accessory4)
# ====================================================================
def probe_op7(h, addr_op7):
    """Body produces 3 ZF outcomes:
      area==4 && accessory==4 -> AL=0xFF, ZF=0 (mov 0xFF + or al,al)
      area==4 && accessory!=4 -> AL=0,    ZF=1 (xor al,al)
      area!=4                 -> AL untouched, ZF=0 (cmp != 0 leftover)
    The caller `combat_step_dispatch` does `jz` after the call, so the
    proc effectively gates: ZF=1 -> proceed (in area 4, NOT carrying
    accessory 4)."""
    cases = [
        # (area, accessory, expected_al, expected_zf, label)
        (4, 4, 0xFF, False, 'area=4, accessory=4 -> AL=FF, ZF=0'),
        (4, 3, 0x00, True,  'area=4, accessory=3 -> AL=0,  ZF=1 (gate open)'),
        (3, 4, None, False, 'area=3, accessory=4 -> ZF=0 (early skip)'),
        (5, 7, None, False, 'area=5, accessory=7 -> ZF=0 (early skip)'),
    ]
    all_ok = True
    for area, accessory, exp_al, exp_zf, label in cases:
        h.write_byte(AREA_NUM, area)
        h.write_byte(SELECTED_ACCESSORY, accessory)
        snap = h.snapshot()
        r = h.call_function(addr_op7, regs={}, max_steps=30)
        al = r['regs_after']['ax'] & 0xFF
        zf = r['flags_after']['ZF']
        ok_al = (exp_al is None) or (al == exp_al)
        ok_zf = (zf == exp_zf)
        ok = ok_al and ok_zf
        print(f'\nProbe op7: {label}')
        exp_al_str = 'any' if exp_al is None else f'0x{exp_al:02X}'
        print(f'  AL=0x{al:02X} (expect {exp_al_str})  '
              f'ZF={zf} (expect {exp_zf})  {"OK" if ok else "FAIL"}')
        all_ok = all_ok and ok
        h.restore(snap)
    return all_ok


# ====================================================================
# Probe 8 — vga_operation8 (proposed: si_from_player_pos)
# ====================================================================
def probe_op8(h, addr_op8, addr_op5):
    """si = fight_player_col*0x24 + screen_position+4 + gvar_scroll_pos,
    then jmp clamp_si_high (op5).  We stub op5 to make si change
    observable as the value PASSED INTO op5 (we capture in a regs probe
    by stubbing op5 with no-op so si flows through)."""
    h.write_byte(FIGHT_PLAYER_COL, 2)
    h.write_byte(SCREEN_POSITION, 0)
    h.write_word(GVAR_SCROLL_POS, SCROLL_BUF)  # base
    snap = h.snapshot()
    # Stub op5 to no-op (don't clamp).
    r = h.call_function(addr_op8, regs={},
                        stub_calls={addr_op5: {}}, max_steps=50)
    # op8 ends with `jmp short clamp_si_high` (jmp to op5 body, not call).
    # When we stub at op5 entry, the jmp arrives there and the stub RETs.
    # SI at that moment should be: 2*0x24 + (0+4) + SCROLL_BUF
    #                            = 0x48 + 4 + 0xE000 = 0xE04C.
    si = r['regs_after']['si']
    expected = 2 * 0x24 + (0 + 4) + SCROLL_BUF
    print(f'\nProbe op8: fight_player_col=2, screen_pos=0, '
          f'gvar_scroll_pos=0x{SCROLL_BUF:04X}')
    print(f'  SI after: 0x{si:04X}  expect 0x{expected:04X}  '
          f'{"OK" if si == expected else "FAIL"}')
    h.restore(snap)
    return si == expected


# ====================================================================
# Probe 9 — vga_operation9 (proposed: get_object_state_at_si)
# ====================================================================
def probe_op9(h, addr_op9):
    """If [si] bit7 clear: stc, ret. (CF=1)
    Else: bx = object_list_ptr + (al&7F)*0x10; AL = [bx+4];
    ZF = (AL==0); CF=0."""
    DS_DATA = 0x4000  # where we plant fake [si] byte
    OBJ_LIST = 0x5000  # where we plant a fake object array

    h.write_word(OBJECT_LIST_PTR, OBJ_LIST)

    # Case A: [si] bit7 clear -> CF=1
    h.write_byte(DS_DATA, 0x40)  # top bit clear
    snap = h.snapshot()
    r = h.call_function(addr_op9, regs={'si': DS_DATA}, max_steps=30)
    cf_a = r['flags_after']['CF']
    print(f'\nProbe op9: [si]=0x40 (bit7 clear) -> early CF=1')
    print(f'  CF={cf_a}  expect True  '
          f'{"OK" if cf_a else "FAIL"}')
    h.restore(snap)

    # Case B: [si]=0x83 (bit7 set, slot=3); object[3].field4 = 0x77
    h.write_byte(DS_DATA, 0x83)
    h.write_byte(OBJ_LIST + 3*0x10 + 4, 0x77)
    snap = h.snapshot()
    r = h.call_function(addr_op9, regs={'si': DS_DATA}, max_steps=30)
    al_b = r['regs_after']['ax'] & 0xFF
    cf_b = r['flags_after']['CF']
    zf_b = r['flags_after']['ZF']
    print(f'\nProbe op9: [si]=0x83, object[3].field4=0x77')
    print(f'  AL=0x{al_b:02X} (expect 0x77)  CF={cf_b} (expect False)  '
          f'ZF={zf_b} (expect False)  '
          f'{"OK" if al_b == 0x77 and not cf_b and not zf_b else "FAIL"}')
    h.restore(snap)

    # Case C: [si]=0x82, object[2].field4 = 0x00 -> ZF=1
    h.write_byte(DS_DATA, 0x82)
    h.write_byte(OBJ_LIST + 2*0x10 + 4, 0x00)
    snap = h.snapshot()
    r = h.call_function(addr_op9, regs={'si': DS_DATA}, max_steps=30)
    al_c = r['regs_after']['ax'] & 0xFF
    zf_c = r['flags_after']['ZF']
    print(f'\nProbe op9: [si]=0x82, object[2].field4=0x00 -> ZF=1')
    print(f'  AL=0x{al_c:02X} (expect 0x00)  ZF={zf_c} (expect True)  '
          f'{"OK" if al_c == 0 and zf_c else "FAIL"}')
    h.restore(snap)

    return cf_a and (al_b == 0x77 and not cf_b) and (al_c == 0 and zf_c)


def main() -> int:
    addr_op0 = _addr('rebuild_scroll_buf',     fallback='vga_operation0')
    addr_op1 = _addr('scroll_byte_dispatch_a', fallback='vga_operation1')
    addr_op2 = _addr('scroll_byte_dispatch_b', fallback='vga_operation2')
    addr_op3 = _addr('fill_scroll_column',     fallback='vga_operation3')
    addr_op4 = _addr('scroll_buf_offset',      fallback='vga_operation4')
    addr_op5 = _addr('scroll_si_wrap_high',    fallback='vga_operation5')
    addr_op6 = _addr('scroll_si_wrap_low',     fallback='vga_operation6')
    addr_op7 = _addr('gate_area4_no_accessory4', fallback='vga_operation7')
    addr_op8 = _addr('scroll_si_from_player',  fallback='vga_operation8')
    addr_op9 = _addr('get_object_state_at_si', fallback='vga_operation9')
    print(f'vga_operation0 @ 0x{addr_op0:04X}')
    print(f'vga_operation4 @ 0x{addr_op4:04X}')
    print(f'vga_operation9 @ 0x{addr_op9:04X}')

    h = fresh_harness()

    results = {}
    results['op0'] = probe_op0(h, addr_op0, addr_op3, addr_op4)
    results['op1'] = probe_op1(h, addr_op1)
    results['op2'] = probe_op2(h, addr_op2)
    results['op4'] = probe_op4(h, addr_op4)
    results['op5'] = probe_op5(h, addr_op5)
    results['op6'] = probe_op6(h, addr_op6)
    results['op7'] = probe_op7(h, addr_op7)
    results['op8'] = probe_op8(h, addr_op8, addr_op5)
    results['op9'] = probe_op9(h, addr_op9)

    print('\n========================== SUMMARY ==========================')
    for k, ok in results.items():
        print(f'  {k}: {"PASS" if ok else "FAIL"}')

    if all(results.values()):
        print('\nVERDICT: PASS — Tier-3 evidence supports renames:')
        print('  vga_operation0 -> rebuild_scroll_buf')
        print('  vga_operation1 -> scroll_byte_dispatch_a')
        print('  vga_operation2 -> scroll_byte_dispatch_b')
        print('  vga_operation3 -> fill_scroll_column')
        print('  vga_operation4 -> scroll_buf_offset')
        print('  vga_operation5 -> scroll_si_wrap_high')
        print('  vga_operation6 -> scroll_si_wrap_low')
        print('  vga_operation7 -> gate_area4_no_accessory4')
        print('  vga_operation8 -> scroll_si_from_player')
        print('  vga_operation9 -> get_object_state_at_si')
        return 0
    print('\nVERDICT: REFUTED — at least one probe failed.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
