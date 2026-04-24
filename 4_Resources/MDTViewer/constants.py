"""
Zeliard MDT Viewer - Constants and lookup tables.
"""

import os

# ─── Runtime constants ────────────────────────────────────────────────────────
MDT_LOAD_ADDR   = 0xC000   # MDT runtime segment base address
DUNG_HEIGHT = 64       # All Zeliard dungeons are exactly 64 tiles tall
TOWN_HEIGHT = 8       # All Zeliard town maps are exactly 8 tiles tall

# ─── Tile color palette (golden-ratio HSV across 64 entries) ──────────────────
def _hsv(h, s, v):
    i = int(h*6) % 6; f = h*6 - int(h*6)
    p = v*(1-s); q = v*(1-f*s); t = v*(1-(1-f)*s)
    r, g, b = [(v,t,p),(q,v,p),(p,v,t),(p,q,v),(t,p,v),(v,p,q)][i]
    return '#{:02x}{:02x}{:02x}'.format(int(r*255), int(g*255), int(b*255))

PALETTE = {0: '#0c0c14'}
_h = 0.08
for _i in range(1, 64):
    _h = (_h + 0.618033988749895) % 1.0
    PALETTE[_i] = _hsv(_h, 0.55 + 0.30*((_i%4)/3.0), 0.50 + 0.40*(_i%2))

# ─── Map ID lookup tables ─────────────────────────────────────────────────────
# Dungeon/outdoor maps — map_id is 0-based from MP10.MDT (STICK.BIN index 0x15)
_DUNG_MAPS = [
    'MP10.MDT','MP1D.MDT','MP20.MDT','MP21.MDT','MP2D.MDT',
    'MP30.MDT','MP31.MDT','MP3D.MDT','MP40.MDT','MP41.MDT',
    'MP4D.MDT','MP50.MDT','MP51.MDT','MP5D.MDT','MP60.MDT',
    'MP60.MDT','MP61.MDT','MP62.MDT','MP6D.MDT','MP70.MDT',
    'MP71.MDT','MP72.MDT','MP73.MDT','MP7D.MDT','MP80.MDT',
    'MP81.MDT','MP82.MDT','MP83.MDT','MP84.MDT','MP8D.MDT',
    'MP90.MDT','MPA0.MDT',
]

# Town maps — destination y == 0x00FF means town warp (linear, no Y)
_TOWN_MAPS = {
    0x01: 'MRMP.MDT  (1. Muralla Town)',
    0x02: 'STMP.MDT  (2. Satono Town)',
    0x03: 'BSMP.MDT  (3. Bosque Village)',
    0x04: 'CMAP.MDT  (0. Felishika Castle)',
    0x05: 'HLMP.MDT  (4. Helada Town)',
    0x06: 'DRMP.MDT  (6. Dorado Town)',
    0x07: 'LLMP.MDT  (7. Llama Town)',
    0x08: 'PRMP.MDT  (8-1. Pureza Town)',
    0x09: 'ESMP.MDT  (8-2. Esco Village)',
    0x0A: 'TMMP.MDT  (5. Tumba Town)',
}

# Derive town stems for filename detection
_TOWN_STEMS = {v.split('.')[0] for v in _TOWN_MAPS.values()}

# ─── Monster type names (type field) ─────────────────────────────────────────
_MONSTER_TYPE_NAMES = {
    0x00: 'Bat',
    0x01: 'Snail/Slug',
    0x02: 'Frog',
    0x03: 'Rat/Lizard',
    0x04: 'Flying Eye',
    0x05: 'Skeleton',
    0x06: 'Ghost',
    0x07: 'Golem',
    0x08: 'Dragon',
    0x09: 'Witch',
    0x0A: 'Wizard',
    0x0B: 'Knight',
    0x0C: 'Demon',
}

# ─── Item type names (type field) ────────────────────────────────────────────
_ITEM_TYPE_NAMES = {
    0x00: 'Coin/Gold',
    0x25: '[HALT]',
    0x45: '[HALT]',
    0x65: '[HALT]',
    0x66: '[HALT]',
    0x67: '[FORCE QUIT]',
    0x68: '[Sprite: Explode]',
    0x69: '[Sprite: Explode -> Almas]',
    0x6A: '[Sprite: Explode]',
    0x6B: '[Sprite: Explode + Almas chest loop]',
    0x6C: '[Sprite: Explode]',
    0x6D: '[Sprite: Explode]',
    0x6E: '[Sprite: Explode]',
    0x6F: '[Sprite: Explode / Breakable wall (hero only)]',
    0x70: 'Passthrough Wall (hero only)',
    0x71: 'Block',
    0x72: '(none)',
    0x73: 'Chest',
    0x74: '1 Almas',
    0x75: '10 Almas',
    0x76: 'Key',
    0x77: 'Lion Key  (no sprite)',
    0x78: 'Red Potion (HP)',
    0x79: 'Blue Potion (MP)',
    0x7A: 'Ruzeria Shoes  (duplicate — may conflict)',  # 7a = Ruzeria Shoes
    0x7B: '100 Almas  (broken sprite)',
    0x7C: 'Empty Dialog Box',
    0x7D: "Hero's Helmet  (no sprite)",
    0x7E: 'Pureza Boots  (no sprite)',
    0x7F: '[HALT — corrupted sprite]',
    0x80: 'Bat',
    0x81: 'Snail',
    0xC0: '[Crash on entry]',
    0xCF: '[Sprite: Explode]',
    0xD0: 'Breakable Wall (hit only, floor-safe)',
    0xD1: 'Breakable Wall (hit + jump breaks)',
    0xD2: '[Crash on entry]',
    0xD3: '[Crash on entry]',
    0xFF: '[BROKEN — corrupted sprite]',
}

# ─── Helper functions ─────────────────────────────────────────────────────────
def _dung_name(mid):
    """Get dungeon map name from map_id."""
    return _DUNG_MAPS[mid] if 0 <= mid < len(_DUNG_MAPS) else f'?[{mid:#04x}]'


def _town_name(mid):
    """Get town map name from map_id."""
    return _TOWN_MAPS.get(mid, f'?[{mid:#04x}]')


def _ptr_off(ptr, file_size):
    """Convert runtime pointer to file offset."""
    if ptr == 0 or ptr == 0xFFFF:
        return None
    if ptr >= MDT_LOAD_ADDR:
        off = ptr - MDT_LOAD_ADDR
    else:
        off = ptr
    return off if off < file_size else None


# Alias for compatibility
_ptr_off_safe = _ptr_off


def is_town_mdt(filename: str) -> bool:
    """Return True if the filename matches a known Zeliard town MDT."""
    stem = os.path.splitext(os.path.basename(filename))[0].upper()
    return stem in _TOWN_STEMS


def get_map_type_info(filename: str) -> str:
    """Get human-readable map type description from filename."""
    fn = os.path.splitext(os.path.basename(filename))[0].upper().replace('.MDT', '')
    if fn.startswith('MP') and len(fn) >= 3:
        rest = fn[2:]
        if rest.endswith('D'):
            return f'Dungeon (world {rest[:-1]})'
        else:
            return f'Outdoor map (world {rest})'
    else:
        return {
            'CMAP':'0. Felishika Castle',
            'MRMP':'1. Muralla Town',
            'STMP':'2. Satono Town',
            'BSMP':'3. Bosque Village',
            'HLMP':'4. Helada Town',
            'TMMP':'5. Tumba Town',
            'DRMP':'6. Dorado Town',
            'LLMP':'7. Llama Town',
            'PRMP':'8-1. Pureza Town',
            'ESMP':'8-2. Esco Village',
        }.get(fn, 'Unknown / Resource')


# ─── MDT → GRP tileset mapping ───────────────────────────────────────────────
# Maps each MDT filename (upper) to the appropriate .grp pattern file.
#
# dpat.grp  : Dungeon tile patterns  (mp?d.mdt — all dungeon levels)
# mpat.grp  : Outdoor / town tile patterns (mp?0-3.mdt — field + non-castle towns)
# cpat.grp  : Castle / common tile patterns (cmap.mdt — Felishika Castle, plus
#             some town/field areas that share the castle palette)
#
# Source evidence:
#   cmap.mdt = Felishika Castle  → user confirmed cpat.grp
#   mp?d.mdt = Dungeon maps      → dpat.grp  (obvious: "d" suffix = dungeon)
#   mrmp, stmp, bsmp, hlmp, tmmp, drmp, llmp, prmp, esmp = town maps → mpat.grp
#   mp?0-3.mdt = Outdoor/field   → mpat.grp
#   mpa0.mdt   = World A (final) → dpat.grp (boss area, dungeon-style)
_MDT_TILESET: dict = {
    # ── Felishika Castle ─────────────────────────
    'CMAP.MDT': 'cpat.grp',    # 0. Felishika's Castle  (user-confirmed)

    # ── Town maps ─────────────────────────────────
    'MRMP.MDT': 'mpat.grp',    # 1. Muralla Town
    'STMP.MDT': 'mpat.grp',    # 2. Satono Town
    'BSMP.MDT': 'mpat.grp',    # 3. Bosque Village
    'HLMP.MDT': 'mpat.grp',    # 4. Helada Town
    'TMMP.MDT': 'mpat.grp',    # 5. Tumba Town
    'DRMP.MDT': 'mpat.grp',    # 6. Dorado Town
    'LLMP.MDT': 'mpat.grp',    # 7. Llama Town
    'PRMP.MDT': 'mpat.grp',    # 8-1. Pureza Town
    'ESMP.MDT': 'mpat.grp',    # 8-2. Esco Village

    # ── World dungeon maps (mp?d suffix) ─────────
    'MP1D.MDT': 'dpat.grp',
    'MP2D.MDT': 'dpat.grp',
    'MP3D.MDT': 'dpat.grp',
    'MP4D.MDT': 'dpat.grp',
    'MP5D.MDT': 'dpat.grp',
    'MP6D.MDT': 'dpat.grp',
    'MP7D.MDT': 'dpat.grp',
    'MP8D.MDT': 'dpat.grp',
    'MP90.MDT': 'dpat.grp',    # World 9 — single dungeon-style map
    'MPA0.MDT': 'dpat.grp',    # World A (final boss) — dungeon-style

    # ── Outdoor / field maps (mp?0-3) ────────────
    'MP10.MDT': 'mpat.grp',
    'MP20.MDT': 'mpat.grp',
    'MP21.MDT': 'mpat.grp',
    'MP30.MDT': 'mpat.grp',
    'MP31.MDT': 'mpat.grp',
    'MP40.MDT': 'mpat.grp',
    'MP41.MDT': 'mpat.grp',
    'MP50.MDT': 'mpat.grp',
    'MP51.MDT': 'mpat.grp',
    'MP60.MDT': 'mpat.grp',
    'MP61.MDT': 'mpat.grp',
    'MP62.MDT': 'mpat.grp',
    'MP70.MDT': 'mpat.grp',
    'MP71.MDT': 'mpat.grp',
    'MP72.MDT': 'mpat.grp',
    'MP73.MDT': 'mpat.grp',
    'MP80.MDT': 'mpat.grp',
    'MP81.MDT': 'mpat.grp',
    'MP82.MDT': 'mpat.grp',
    'MP83.MDT': 'mpat.grp',
    'MP84.MDT': 'mpat.grp',
}


def get_mdt_tileset(filename: str) -> str:
    """
    Return the GRP pattern file name for the given MDT filename.
    Fallback logic for unrecognised names:
      - name ends with 'D.MDT'  → dpat.grp  (dungeon)
      - name starts with 'MP'   → mpat.grp  (outdoor/field)
      - is_town_mdt()           → mpat.grp  (town)
      - otherwise               → cpat.grp  (common/castle)
    """
    stem_upper = os.path.splitext(os.path.basename(filename))[0].upper() + '.MDT'
    if stem_upper in _MDT_TILESET:
        return _MDT_TILESET[stem_upper]
    # Fallback rules
    base = os.path.basename(filename).upper()
    if base.endswith('D.MDT'):
        return 'dpat.grp'
    if base.startswith('MP'):
        return 'mpat.grp'
    if is_town_mdt(filename):
        return 'mpat.grp'
    return 'cpat.grp'
