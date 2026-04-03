"""
Zeliard MDT Viewer - Constants and lookup tables.
"""

import os

# ─── Runtime constants ────────────────────────────────────────────────────────
SEG_BASE   = 0xC000   # MDT runtime segment base address
MAP_HEIGHT = 64       # All Zeliard dungeons are exactly 64 tiles tall
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
}

# Derive town stems for filename detection
_TOWN_STEMS = {v.split('.')[0] for v in _TOWN_MAPS.values()}

# ─── Monster type names (type field) ─────────────────────────────────────────
_MONSTER_TYPE_NAMES = {
    0x01: 'Snail/Slug',
    0x02: 'Frog',
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
    if ptr >= SEG_BASE:
        off = ptr - SEG_BASE
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
