"""
tile_graphics.py — Zeliard Tile + NPC Graphics Decoder  (v29-fixed)

Key fix from MdtViewer_ reference:
  Visibility condition for modes 1-3:
    visible = NOT (sel == 0x03)   ← correct
    (our previous code had it backwards)

  Transparent pixels rendered with background color index 5 (dark blue),
  not fully transparent, matching Zeliard's actual rendering.
"""

import os
from typing import Optional, Dict, List

# ---------------------------------------------------------------------------
# MCGA palette  (64 entries, r/g/b scaled ×4 to 0-255)
# ---------------------------------------------------------------------------
def _build_palette():
    raw = [
        (0,0,0),(31,31,31),(31,0,0),(0,31,0),(0,31,31),(0,0,31),(31,31,0),(31,0,31),
        (31,31,31),(62,62,62),(62,31,31),(31,62,31),(31,62,62),(31,31,62),(62,62,31),(62,31,62),
        (31,0,0),(62,31,31),(62,0,0),(31,31,0),(31,31,31),(31,0,31),(62,31,0),(62,0,31),
        (0,31,0),(31,62,31),(31,31,0),(0,62,0),(0,62,31),(0,31,31),(31,62,0),(31,31,31),
        (0,31,31),(31,62,62),(31,31,31),(0,62,31),(0,62,62),(0,31,62),(31,62,31),(31,31,62),
        (0,0,31),(31,31,62),(31,0,31),(0,31,31),(0,31,62),(0,0,62),(31,31,31),(31,0,62),
        (31,31,0),(62,62,31),(62,31,0),(31,62,0),(31,62,31),(31,31,31),(62,62,0),(62,31,31),
        (31,0,31),(62,31,62),(62,0,31),(31,31,31),(31,31,62),(31,0,62),(62,31,31),(62,0,62),
    ]
    return [(r*4, g*4, b*4) for r, g, b in raw]

_PAL_RGB = _build_palette()                          # 64 × (r,g,b)
_PAL_HEX = [f'#{r:02x}{g:02x}{b:02x}' for r,g,b in _PAL_RGB]
# Index 5 = dark blue — used as background/transparent fill
_BG_IDX  = 5
_BG_HEX  = _PAL_HEX[_BG_IDX]

# ---------------------------------------------------------------------------
# GRP decompression (methods 0-7)
# ---------------------------------------------------------------------------
def _unpack(src: bytes) -> bytes:
    if not src:
        return b''
    si  = 0
    out = bytearray()
    dx  = len(src)

    def lodsb():
        nonlocal si; b = src[si]; si += 1; return b
    def lodsw():
        nonlocal si; lo = src[si]; hi = src[si+1]; si += 2; return lo|(hi<<8)
    def rep(b, n): out.extend([b]*n)

    method = lodsb() & 0x07
    dx -= 1

    if method == 0:
        out.extend(src[si:si+dx])
    elif method == 1:
        bp = si
        while lodsb() != 0xFF: si += 1
        dx = len(src)-si
        while dx > 0:
            al=lodsb(); dx-=1; ah=al&0xF0; cx=1; tbp=bp
            while True:
                ek=src[tbp]
                if (ek&0x0F)!=0: break
                if ah==ek: cx=(al&0x0F)+2; al=src[tbp+1]; break
                tbp+=2
            rep(al,cx)
    elif method == 2:
        marker=lodsb(); dx-=1; ah=marker
        while dx>0:
            al=lodsb(); dx-=1; cx=1
            if (al&0xF0)==ah: cx=(al&0x0F)+3; al=lodsb(); dx-=1
            rep(al,cx)
    elif method == 3:
        bp=si
        while lodsb()!=0xFF: si+=1
        dx=len(src)-si
        while dx>0:
            al=lodsb(); dx-=1; ah=al&0x0F; cx=1; tbp=bp
            while True:
                ek=src[tbp]
                if (ek&0xF0)!=0: break
                if ah==ek: cx=(al>>4)+2; al=src[tbp+1]; break
                tbp+=2
            rep(al,cx)
    elif method == 4:
        marker=lodsb(); dx-=1; ah=marker
        while dx>0:
            al=lodsb(); dx-=1; cx=1
            if (al&0x0F)==ah: cx=(al>>4)+3; al=lodsb(); dx-=1
            rep(al,cx)
    elif method == 5:
        while dx>0:
            al=lodsb(); cx=1
            if si<len(src) and src[si]==al:
                cx=src[si+1]+2; si+=2; dx-=2
            rep(al,cx); dx-=1
    elif method == 6:
        bp=si
        while lodsw()!=0xFFFF: pass
        dx=len(src)-si
        while dx>0:
            al=lodsb(); dx-=1; cx=1; tbp=bp
            while True:
                tl=src[tbp]; th=src[tbp+1]
                if tl==0xFF and th==0xFF: break
                if tl==al: dx-=1; cx=lodsb()+2; al=th; break
                tbp+=2
            rep(al,cx)
    elif method == 7:
        ah=lodsb(); dx-=1
        while dx>0:
            al=lodsb(); cx=1
            if al==ah: al=lodsb(); cx=lodsb()+3; dx-=2
            rep(al,cx); dx-=1

    return bytes(out)


def _load_grp(raw: bytes) -> bytes:
    if not raw:
        return b''
    if raw[0] == 0:
        payload = raw[1:]
    else:
        skip    = int.from_bytes(raw[1:3], 'little')
        payload = raw[5+skip:]
    return _unpack(payload)

# ---------------------------------------------------------------------------
# Pixel decoder (rol16 chain)
# ---------------------------------------------------------------------------
def _rol16(w, n=1):
    w &= 0xFFFF
    c  = 0
    for _ in range(n):
        c = (w>>15)&1
        w = ((w<<1)|c)&0xFFFF
    return w, c

def _decode4(p1, p2, p3):
    pxs = []
    for _ in range(4):
        ax = 0
        p3,c=_rol16(p3); ax=(ax<<1)|c
        p2,c=_rol16(p2); ax=(ax<<1)|c
        p1,c=_rol16(p1); ax=(ax<<1)|c
        p3,c=_rol16(p3); ax=(ax<<1)|c
        p2,c=_rol16(p2); ax=(ax<<1)|c
        p1,c=_rol16(p1); ax=(ax<<1)|c
        pxs.append(ax & 0x3F)
    return p1, p2, p3, pxs

# ---------------------------------------------------------------------------
# Pattern tile decoder  (mode 7, 48 bytes per tile)
#
# FIXED: visibility = NOT (sel == 0x03)  (matches MdtViewer_ reference)
#         transparent pixels → background color index 5 (dark blue)
# ---------------------------------------------------------------------------
def _decode_pat_tile(td: bytes, fm: int) -> List[int]:
    """
    Decode 48-byte pattern tile → 64 palette indices.
    -1 means 'transparent' (will be rendered as background color).
    """
    pixels: List[int] = []
    for ry in range(8):
        b  = td[ry*6:ry*6+6]
        w0 = (b[0]<<8)|b[1]
        w1 = (b[2]<<8)|b[3]
        w2 = (b[4]<<8)|b[5]

        if   fm == 0: pr,pg,pb,pm = w0,w1,w2,0x0000
        elif fm == 1: pr,pg,pb,pm = w0,w1,0,  w2
        elif fm == 2: pr,pg,pb,pm = w0,0,  w2, w1
        elif fm == 3: pr,pg,pb,pm = 0, w1, w2, w0
        else:         pr,pg,pb,pm = w0,w1,w2,0xFFFF  # mode 4

        p1,p2,p3,px1 = _decode4(pr,pg,pb)
        _, _, _, px2  = _decode4(p1,p2,p3)

        for rx, pidx in enumerate(px1 + px2):
            if fm == 0 or fm == 4:
                vis = True
            else:
                sel = (pm >> (14 - rx*2)) & 0x03
                # FIX: visible when sel != 0x03  (NOT the mask pattern)
                vis = not (sel == 0x03)
            pixels.append(pidx if vis else -1)
    return pixels


def _decode_pat_grp(data: bytes) -> Dict[int, List[int]]:
    HEADER, TILE = 256, 48
    indices   = data[6:HEADER]
    tile_bank = data[HEADER:]
    total     = min(len(tile_bank)//TILE, len(indices))
    tiles: Dict[int, List[int]] = {}
    for i in range(total):
        fm = indices[i]
        if fm > 4: fm = 0
        tiles[i] = _decode_pat_tile(tile_bank[i*TILE:(i+1)*TILE], fm)
    return tiles

# ---------------------------------------------------------------------------
# NPC sprite decoder  (mode 5/6, 48 bytes per 8×8 tile)
# ---------------------------------------------------------------------------
_HERO_INDICES = [
    0x00,0x02,0x04,0x01,0x03,0x05,
    0x06,0x08,0x0A,0x07,0x09,0x0B,
    0x00,0x0C,0x0E,0x01,0x0D,0x0F,
    0x06,0x10,0x12,0x07,0x11,0x13,
    0x14,0x16,0x18,0x15,0x17,0x19,
    0x1A,0x1C,0x1E,0x1B,0x1D,0x1F,
    0x20,0x22,0x24,0x21,0x23,0x25,
    0x1A,0x26,0x28,0x1B,0x27,0x29,
    0x20,0x2A,0x2C,0x21,0x2B,0x2D,
    0x14,0x16,0x18,0x15,0x17,0x19,
]

def _decode_npc_tile(td: bytes) -> List[int]:
    pixels: List[int] = []
    for ry in range(8):
        b  = td[ry*6:ry*6+6]
        p1 = (b[0]<<8)|b[1]
        p2 = (b[2]<<8)|b[3]
        p3 = (b[4]<<8)|b[5]
        wh = p1&p2&p3
        p1 &= ~wh&0xFFFF
        p2 &= ~wh&0xFFFF
        p3 &= ~wh&0xFFFF
        p1,p2,p3,px1 = _decode4(p1,p2,p3)
        _, _, _,  px2 = _decode4(p1,p2,p3)
        pixels.extend(px1+px2)
    return [i if i!=0 else -1 for i in pixels]


def _decode_npc_grp(data: bytes, is_hero: bool=False) -> Dict[int, List[int]]:
    TABLE     = 0 if is_hero else 256
    TILE      = 48
    NPC_COUNT = 10 if is_hero else 40
    tile_bank = data[TABLE:]
    idx_src   = _HERO_INDICES if is_hero else data
    sprites: Dict[int, List[int]] = {}

    for ni in range(NPC_COUNT):
        base    = ni*6
        indices = idx_src[base:base+6]
        sprite  = [-1]*(16*24)
        for col in range(2):
            for row in range(3):
                ti = indices[col*3+row]
                if not is_hero:
                    ti -= 1
                if ti < 0:
                    continue
                off = ti*TILE
                if off+TILE > len(tile_bank):
                    continue
                tp = _decode_npc_tile(tile_bank[off:off+TILE])
                for ry in range(8):
                    for rx in range(8):
                        px = col*8+rx
                        py = row*8+ry
                        sprite[py*16+px] = tp[ry*8+rx]
        sprites[ni] = sprite
    return sprites

# ---------------------------------------------------------------------------
# PhotoImage factory  (PIL preferred, tk fallback)
#   -1 pixels → background color index 5 (dark blue), matching the game
# ---------------------------------------------------------------------------
def _px_color(p: int) -> tuple:
    """(r,g,b) for a pixel index.  -1 → background color."""
    return _PAL_RGB[_BG_IDX] if p < 0 else _PAL_RGB[p & 0x3F]

def _px_hex(p: int) -> str:
    return _BG_HEX if p < 0 else _PAL_HEX[p & 0x3F]


def _to_photo_pil(pixels: List[int], w: int, h: int, out_w: int, out_h: int):
    from PIL import Image, ImageTk
    rgb = bytearray(w*h*3)
    for i, p in enumerate(pixels):
        r,g,b = _px_color(p)
        rgb[i*3]=r; rgb[i*3+1]=g; rgb[i*3+2]=b
    img = Image.frombytes('RGB', (w, h), bytes(rgb))
    img = img.resize((out_w, out_h), Image.NEAREST)
    return ImageTk.PhotoImage(img)


def _to_photo_tk(pixels: List[int], w: int, h: int, out_w: int, out_h: int):
    import tkinter as tk
    img = tk.PhotoImage(width=w, height=h)
    for y in range(h):
        row = [_px_hex(pixels[y*w+x]) for x in range(w)]
        img.put('{'+' '.join(row)+'}', to=(0,y))
    if out_w != w or out_h != h:
        zx = max(1, out_w//w)
        zy = max(1, out_h//h)
        if zx>1 or zy>1:
            img = img.zoom(zx,zy)
        sx = max(1,(w*zx)//out_w)
        sy = max(1,(h*zy)//out_h)
        if sx>1 or sy>1:
            img = img.subsample(sx,sy)
    return img


def _make_photo(pixels: List[int], w: int, h: int, out_w: int, out_h: int):
    if not pixels:
        return None
    try:
        return _to_photo_pil(pixels, w, h, out_w, out_h)
    except ImportError:
        pass
    try:
        return _to_photo_tk(pixels, w, h, out_w, out_h)
    except Exception:
        return None

# ---------------------------------------------------------------------------
# TileGraphics class
# ---------------------------------------------------------------------------
TILE_W = 8
TILE_H = 8
NPC_W  = 16
NPC_H  = 24


class TileGraphics:
    def __init__(self):
        self._pat:   Dict[str, Dict[int, List[int]]] = {}
        self._npc:   Dict[str, Dict[int, List[int]]] = {}
        self._cache: Dict[tuple, object]              = {}
        self.loaded        = False
        self.missing_files: List[str] = []

    # ── Loading ──────────────────────────────────────────────────────────

    def load_from_sar(self, sar_path: str) -> List[str]:
        from .sar_reader import SarArchive
        try:
            sar = SarArchive(sar_path)
        except Exception as e:
            self.missing_files = [str(e)]
            return self.missing_files

        missing = []
        for grp in ('dpat.grp','mpat.grp','cpat.grp'):
            if sar.contains(grp):
                try:
                    self._pat[grp] = _decode_pat_grp(_load_grp(sar.read(grp)))
                except Exception as e:
                    missing.append(f'{grp}({e})')
            else:
                missing.append(grp)

        for grp, hero in (('mman.grp',False),('cman.grp',False),('tman.grp',True)):
            if sar.contains(grp):
                try:
                    self._npc[grp] = _decode_npc_grp(_load_grp(sar.read(grp)), hero)
                except Exception as e:
                    missing.append(f'{grp}({e})')
            else:
                missing.append(grp)

        self.loaded = bool(self._pat)
        self.missing_files = missing
        return missing

    def load_from_dir(self, directory: str) -> List[str]:
        for name in ('zelres2.sar','zelres1.sar','ZELRES2.SAR','ZELRES1.SAR'):
            p = os.path.join(directory, name)
            if os.path.exists(p):
                return self.load_from_sar(p)
        self.missing_files = ['zelres2.sar not found']
        return self.missing_files

    # ── PhotoImage API ────────────────────────────────────────────────────

    def get_tile_photo(self, tile_id: int, block_size: int,
                       tile_set: str = 'dungeon'):
        if not self.loaded:
            return None
        grp_map = {'dungeon':'dpat.grp','town':'mpat.grp','common':'cpat.grp'}
        grp = grp_map.get(tile_set, 'dpat.grp')
        tiles = (self._pat.get(grp)
                 or self._pat.get('cpat.grp')
                 or next(iter(self._pat.values()), None))
        if not tiles:
            return None
        n   = len(tiles)
        idx = tile_id % n if n else 0
        key = ('t', grp, idx, block_size)
        if key in self._cache:
            return self._cache[key]
        px = tiles.get(idx)
        if px is None:
            return None
        photo = _make_photo(px, TILE_W, TILE_H, block_size, block_size)
        if photo:
            self._cache[key] = photo
        return photo

    def get_npc_photo(self, npc_id: int, block_size: int,
                      grp_name: str = 'mman.grp'):
        sprites = self._npc.get(grp_name)
        if not sprites:
            return None
        n   = len(sprites)
        idx = npc_id % n if n else 0
        key = ('n', grp_name, idx, block_size)
        if key in self._cache:
            return self._cache[key]
        px = sprites.get(idx)
        if px is None:
            return None
        out_w = block_size*NPC_W//TILE_W
        out_h = block_size*NPC_H//TILE_H
        photo = _make_photo(px, NPC_W, NPC_H, out_w, out_h)
        if photo:
            self._cache[key] = photo
        return photo

    def clear_cache(self):
        self._cache.clear()

    def get_status(self) -> str:
        if self.loaded:
            return (f'Tiles: {", ".join(self._pat.keys())}  '
                    f'NPC: {", ".join(self._npc.keys())}')
        if self.missing_files:
            return f'Missing: {", ".join(self.missing_files[:3])}'
        return 'Not loaded'


_tile_graphics: Optional[TileGraphics] = None

def get_tile_graphics() -> TileGraphics:
    global _tile_graphics
    if _tile_graphics is None:
        _tile_graphics = TileGraphics()
    return _tile_graphics
