"""fixtures.py — shared test fixtures for the functest harness.

Pull the boilerplate every test re-derives (bin paths + load bases,
player-record layout, dispatch-table seeding, video-driver stubs) into
one module so individual tests can be ~30 lines, declarative.

Conventions
-----------
* All fixtures take a `TasmHarness` instance and mutate it in place
  (write_data / install_farcall_thunk).  No fixture allocates a harness.
* Player-struct field offsets here MUST match `working/drivers/stdply.inc`
  canonical EQUs — when stdply.inc gains a new EQU, mirror it here.
"""
from pathlib import Path

# ---------- BIN paths --------------------------------------------------
# Prefer freshly-built `bin/zelresN/CHUNK.bin` (output of TasmRunner from
# our cleaned source) — that's what `coverage.csv` addresses match.  Fall
# back to `research/flatfiles/*` (older IDA-native dumps, no SAR header)
# when no current bin exists.
#
# CRITICAL: do NOT mix the two for one chunk — sizes/offsets differ.
# `fight.bin` (flat) is 7 bytes shorter than `200FIGHT.bin` (rebuild),
# so addresses don't line up across them.  classify.py + LST → coverage.csv
# uses our cleaned-source LST offsets, so test addresses must come from
# the same-source bin.
TASM_ROOT = Path(__file__).resolve().parent.parent
BIN       = TASM_ROOT / 'bin'
FLAT      = TASM_ROOT / 'research' / 'flatfiles'

BIN_PATHS: dict[str, tuple[Path, int]] = {
    # Chunks with rebuilt bin (use these — match coverage.csv addresses):
    'fight':  (BIN / 'zelres2' / '200FIGHT.bin', 0x6000),
    'select': (BIN / 'zelres2' / '201SELCT.bin', 0xA000),
    'bank':   (BIN / 'zelres2' / '213BANKP.bin', 0xA000),
    # Chunks without an LST/bin yet — fall back to flat file:
    'town':   (FLAT / 'ZELRES1' / 'town.bin',    0x6000),
    'mole':   (FLAT / 'ZELRES2' / 'mole.bin',    0x0100),
    'crab':   (FLAT / 'ZELRES3' / 'CRAB.BIN',    0xA000),
    'eai1':   (FLAT / 'ZELRES3' / 'EAI1.BIN',    0xA000),
    'gmmcga': (FLAT / 'ZELRES1' / 'gmmcga.bin',  0x2000),
    'gdmcga': (FLAT / 'ZELRES1' / 'gdmcga.bin',  0x3000),
    'gfmcga': (FLAT / 'ZELRES2' / 'gfmcga.bin',  0x3000),
    'gtmcga': (FLAT / 'ZELRES1' / 'gtmcga.bin',  0x3000),
    'ckpd':   (FLAT / 'ZELRES2' / 'CKPD.BIN',    0x0100),
    'ympd':   (FLAT / 'ZELRES2' / 'YMPD.BIN',    0x0100),
}


# ---------- player record (DS:0x80..0xCF) -----------------------------
# Field offsets per working/drivers/stdply.inc canonical EQUs.
# When stdply.inc adds a new field, mirror it here.
PLAYER_FIELDS = {
    # offset       size  kind   description
    'map_scroll_col':       (0x80, 2, 'word'),
    'map_scroll_row':       (0x82, 2, 'word'),
    'ply_accel':            (0x83, 2, 'word'),  # 2 bytes, semantics TBD
    'hero_gold_hi':         (0x85, 1, 'byte'),
    'hero_gold_lo':         (0x86, 2, 'word'),  # low word at 0x86..0x87
    'stat_X88_hi':          (0x88, 1, 'byte'),
    'stat_X88_lo':          (0x89, 2, 'word'),
    'hero_almas':           (0x8B, 2, 'word'),
    'item_qty_count':       (0x8D, 1, 'byte'),
    'item_effect_val':      (0x8E, 1, 'byte'),
    'hero_HP':              (0x90, 2, 'word'),
    'shield_HP':            (0x94, 2, 'word'),
    'char_exp_cap':         (0x96, 2, 'word'),
    'char_speed':           (0x98, 1, 'byte'),
    'char_power':           (0x99, 1, 'byte'),
    'char_abilities':       (0x9A, 1, 'byte'),
    'trade_marker_flag':    (0x9B, 1, 'byte'),
    'music_track_count':    (0xA0, 1, 'byte'),
    'player_facing':        (0xC2, 1, 'byte'),
    'boss_intro_flag':      (0xC3, 1, 'byte'),
    'ply_level':            (0xC4, 1, 'byte'),
    'heal_pulse_count':     (0xC6, 2, 'word'),
    'ply_tileset':          (0xC8, 1, 'byte'),
    'cur_magic_idx':        (0xCE, 1, 'byte'),
    'key_count':            (0xCF, 1, 'byte'),
    'ply_hitbox':           (0xD2, 1, 'byte'),
    'gvar_pose_idx':        (0xE7, 1, 'byte'),
    'init_complete_flag':   (0xE8, 1, 'byte'),
    'scene_trans_request':  (0xE6, 1, 'byte'),
}


def make_player_record(harness, **fields) -> None:
    """Seed DS:0x80..0xCF with a player struct.  Pass any subset of
    field names from PLAYER_FIELDS as kwargs; unspecified fields stay
    zero (the data segment was already zero-initialized by the harness).

    Example:
        make_player_record(h, hero_HP=150, hero_gold_hi=0,
                           hero_gold_lo=1234, player_facing=1)
    """
    for fname, value in fields.items():
        if fname not in PLAYER_FIELDS:
            raise KeyError(f'unknown player field: {fname!r}')
        offset, size, _kind = PLAYER_FIELDS[fname]
        if size == 1:
            harness.write_byte(offset, value)
        elif size == 2:
            harness.write_word(offset, value)
        else:
            raw = value.to_bytes(size, 'little')
            harness.write_data(offset, raw)


# ---------- dispatch table seeding ------------------------------------
# Pre-known dispatch-slot ranges that procs commonly reach into.
# 0x2000..0x204E is the gfx-driver export table (fight/town/etc. all
# call far through here).  0x6000..0x603E is fight.bin's local dispatch.
GFX_DRIVER_SLOTS = list(range(0x2000, 0x204E, 2))
FIGHT_LOCAL_SLOTS = list(range(0x6000, 0x6040, 2))


def seed_dispatch_table(harness, slots, thunk_offset_start=0x100) -> None:
    """Install RETF thunks at every CS dispatch slot in `slots` so the
    function under test can far-call any of them without crashing.
    Each thunk gets a unique offset starting at `thunk_offset_start`,
    so a stub_calls map can later distinguish which slot fired.

    Returns dict mapping slot_offset -> thunk_offset for stub_calls
    integration.

    Example:
        thunks = seed_dispatch_table(h, [0x2000, 0x2002, 0x2010])
        # call word ptr cs:[2000h] now safely RETFs
    """
    out: dict[int, int] = {}
    cur_thunk = thunk_offset_start
    for slot in slots:
        harness.install_farcall_thunk(slot, cur_thunk)
        out[slot] = cur_thunk
        cur_thunk += 1   # 1 byte per RETF; thunks tile compactly
    return out


def stub_video_drivers(harness, thunk_offset_start=0x100) -> dict[int, int]:
    """Convenience for tests that call ANY proc touching the gfx driver
    dispatch.  Installs RETF thunks at every slot in 0x2000..0x204E.
    Returns the slot->thunk map.
    """
    return seed_dispatch_table(
        harness, GFX_DRIVER_SLOTS, thunk_offset_start
    )
