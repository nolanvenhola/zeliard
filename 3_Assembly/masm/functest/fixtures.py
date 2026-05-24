"""fixtures.py — shared test fixtures for the functest harness.

Pull the boilerplate every test re-derives (bin paths + load bases,
player-record layout, dispatch-table seeding, video-driver stubs) into
one module so individual tests can be ~30 lines, declarative.

Conventions
-----------
* All fixtures take a `TasmHarness` instance and mutate it in place
  (write_data / install_farcall_thunk).  No fixture allocates a harness.
  `TasmHarness` is a historical class name; new tests live in the MASM tree.
* Player-struct field offsets here MUST match `working/drivers/stdply.inc`
  canonical EQUs — when stdply.inc gains a new EQU, mirror it here.
"""
from pathlib import Path

# ---------- BIN paths --------------------------------------------------
# Prefer freshly-built `bin/zelresN/CHUNK.bin` (MASM build output from
# our cleaned source) — that's what `coverage.csv` addresses match.  Fall
# back to `research/flatfiles/*` (older IDA-native dumps, no SAR header)
# when no current bin exists.
#
# CRITICAL: do NOT mix the two for one chunk — sizes/offsets differ.
# `fight.bin` (flat) is 7 bytes shorter than `200FIGHT.bin` (rebuild),
# so addresses don't line up across them.  classify.py + LST → coverage.csv
# uses our cleaned-source LST offsets, so test addresses must come from
# the same-source bin.
MASM_ROOT = Path(__file__).resolve().parent.parent
BIN       = MASM_ROOT / 'bin'
FLAT      = MASM_ROOT / 'research' / 'flatfiles'

BIN_PATHS: dict[str, tuple[Path, int]] = {
    # Chunks with rebuilt bin (use these — match coverage.csv addresses):
    'fight':  (BIN / 'zelres2' / '200FIGHT.bin', 0x6000),
    'select': (BIN / 'zelres2' / '201SELCT.bin', 0xA000),
    'bank':   (BIN / 'zelres2' / '213BANKP.bin', 0xA000),
    'town':   (BIN / 'zelres1' / '106TOWN.bin',  0x6000),
    # Chunks without an LST/bin yet — fall back to flat file:
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


# ---------- proc-name -> CPU address resolver -------------------------
# After many renames + structural edits, the absolute CPU offsets of
# named procs shift over time.  Hardcoded addresses in tests
# break.  This resolver reads the LST file (Turbo Assembler listing)
# for a given chunk and extracts {proc_name: cpu_address}, so tests
# can do `addr = resolve_proc('200FIGHT', 'try_place_tile_id_49')`
# instead of hard-coding 0x876C.

_LST_CACHE: dict[str, dict[str, int]] = {}


def _regen_lst_if_stale(lst_path: Path, asm_path: Path) -> bool:
    """If the LST is older than the asm or missing, regenerate it via the
    legacy TasmRunner helper.  Returns True if regeneration happened.
    """
    import subprocess
    import tempfile
    import shutil
    if lst_path.exists() and asm_path.exists():
        if lst_path.stat().st_mtime >= asm_path.stat().st_mtime:
            return False
    runner = MASM_ROOT / 'TasmRunner' / 'bin' / 'Debug' / 'net8.0' / 'TasmRunner.exe'
    if not runner.exists():
        return False
    with tempfile.TemporaryDirectory(prefix='lstgen_') as tmp:
        try:
            subprocess.run(
                [str(runner), str(asm_path), '--bin', '--lst', '--output', tmp],
                capture_output=True, timeout=120,
            )
        except Exception:
            return False
        new_lst = Path(tmp) / asm_path.with_suffix('.LST').name
        if not new_lst.exists():
            new_lst = Path(tmp) / asm_path.with_suffix('.lst').name
        if new_lst.exists():
            shutil.copy(new_lst, lst_path)
            return True
    return False


def _lst_path_for(chunk_label: str) -> Path:
    """Map a chunk label (e.g. 'fight', '200FIGHT') to its .LST file."""
    # Map shorthand chunk labels -> canonical chunk filename stem.
    chunk_map = {
        'fight':  '200FIGHT',
        'select': '201SELCT',
        'bank':   '213BANKP',
        'town':   '106TOWN',
        'mole':   '207MOLE',
        'crab':   '309CRAB',
        'eai1':   '301EAI1',
        'gmmcga': 'gmmcga',
        'gmega':  'gmega',
        'gmcga':  'gmcga',
        'gmhgc':  'gmhgc',
        'gmtga':  'gmtga',
        'stdply': 'stdply',
        'stick':  'stick',
        'opdmo':  '100OPDMO',
        'opdemo': '100OPDMO',
    }
    stem = chunk_map.get(chunk_label, chunk_label)

    # Find the .LST under working/.
    for sub in ('drivers', 'core', 'zelres1/code', 'zelres2/code',
                'zelres3/code'):
        candidate = MASM_ROOT / 'working' / sub / f'{stem}.LST'
        if candidate.exists():
            return candidate
        candidate = MASM_ROOT / 'working' / sub / f'{stem}.lst'
        if candidate.exists():
            return candidate
    raise FileNotFoundError(
        f'No LST found for chunk {chunk_label!r} (stem {stem!r}). '
        f'Run TasmRunner with --lst to generate one.'
    )


def _parse_lst_proc_addresses(lst_path: Path) -> dict[str, int]:
    """Parse a TASM .LST file and return {proc_name: hex_offset}.

    LST line format (TASM 2.01):
        <linenum> <offset>  <opcode-bytes>+  <source>
    proc declarations look like:
        1234	5678  ...  proc_name proc near
    """
    import re
    out: dict[str, int] = {}
    text = lst_path.read_text(encoding='cp437', errors='replace')
    # Match `<offset>  ...  <name> proc (near|far)`
    proc_re = re.compile(
        r'^\s*\d+\s+([0-9A-Fa-f]+)\s.*?\b(\w+)\s+proc\s+(?:near|far)\b',
        re.IGNORECASE,
    )
    for line in text.splitlines():
        m = proc_re.match(line)
        if m:
            offset = int(m.group(1), 16)
            name = m.group(2)
            out[name] = offset
    return out


def resolve_proc(chunk_label: str, proc_name: str,
                 fallback_names: tuple[str, ...] = ()) -> int:
    """Return the current CPU offset of `proc_name` in the chunk's LST.

    The chunk_label is a short tag (e.g. 'fight') or full stem
    ('200FIGHT').  The fallback_names tuple lets callers handle the
    common case where a proc has been renamed since the test was
    written:

        # Test was originally for game_func_106; renamed to try_place_tile_id_49
        addr = resolve_proc('fight', 'try_place_tile_id_49',
                            fallback_names=('game_func_106',))

    Raises KeyError if neither the primary name nor any fallback is
    found in the chunk's LST.
    """
    if chunk_label not in _LST_CACHE:
        lst_path = _lst_path_for(chunk_label)
        # Regen if stale relative to .asm
        asm_path = lst_path.with_suffix('.asm')
        if not asm_path.exists():
            asm_path = lst_path.with_suffix('.ASM')
        _regen_lst_if_stale(lst_path, asm_path)
        _LST_CACHE[chunk_label] = _parse_lst_proc_addresses(lst_path)
    table = _LST_CACHE[chunk_label]
    for candidate in (proc_name,) + fallback_names:
        if candidate in table:
            return table[candidate]
    raise KeyError(
        f'No proc named {proc_name!r} (or any fallback) in {chunk_label}.LST. '
        f'Available procs: {sorted(table.keys())[:10]}...'
    )


# ---------- player record (DS:0x80..0xCF) -----------------------------
# Field offsets per working/drivers/stdply.inc canonical EQUs.
# When stdply.inc adds a new field, mirror it here.
PLAYER_FIELDS = {
    # offset       size  kind   description
    'starting_position_in_town':       (0x80, 2, 'word'),
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
    'facing_direction':        (0xC2, 1, 'byte'),
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
                           hero_gold_lo=1234, facing_direction=1)
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


# ---------- regression-test helper -------------------------------------
def check_regression(
    harness, func_addr, *,
    regs=None, stub_calls=None, max_steps=200,
    expected_diffs=None, expected_flags=None, expected_regs=None,
    label='',
):
    """Run a function and compare its observable effects against a
    captured golden.  Returns (ok, msg) where `ok` is True iff every
    `expected_*` field present matched what the function produced.

    Designed for `regression/` tests where the goal is "the function
    still behaves exactly as it did when we last looked", not "what
    does the function do".  Pass only the fields you want to assert —
    e.g. just expected_diffs to lock in memory writes without caring
    about register state.

    Parameters
    ----------
    expected_diffs : list[(offset, before_byte, after_byte)] or None
        If provided, must match `result['mem_diffs']` exactly.
    expected_flags : dict[str, bool] or None
        Subset of {'CF', 'ZF', 'SF', 'OF'} -> bool.  Each named flag
        must equal the post-call flag value.
    expected_regs : dict[str, int] or None
        Subset of {'ax','bx','cx','dx','si','di','bp','sp'} -> int.

    Returns
    -------
    (ok, msg) : bool, str
        On mismatch, msg describes the divergence with concrete bytes.
    """
    result = harness.call_function(
        func_addr,
        regs=regs or {}, stub_calls=stub_calls or {},
        max_steps=max_steps,
    )
    fails = []
    if expected_diffs is not None:
        actual = sorted(result['mem_diffs'])
        want = sorted(expected_diffs)
        if actual != want:
            fails.append(f'  diffs mismatch:\n'
                         f'    actual:   {actual}\n'
                         f'    expected: {want}')
    if expected_flags is not None:
        actual = result['flags_after']
        for fname, fval in expected_flags.items():
            if actual.get(fname) is not fval:
                fails.append(f'  flag {fname}: actual={actual.get(fname)} '
                             f'expected={fval}')
    if expected_regs is not None:
        actual = result['regs_after']
        for rname, rval in expected_regs.items():
            if actual.get(rname) != (rval & 0xFFFF):
                fails.append(f'  reg {rname}: actual=0x{actual.get(rname, 0):04X} '
                             f'expected=0x{rval & 0xFFFF:04X}')
    if not fails:
        return True, f'{label}: PASS'
    return False, f'{label}: FAIL\n' + '\n'.join(fails)
