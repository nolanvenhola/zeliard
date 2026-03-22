#!/usr/bin/env python3
"""
grp_viewer.py - Interactive viewer for Zeliard SAR chunk image data

Usage:
  python grp_viewer.py zelres1 14          # chunk 14 of zelres1.sar (nec.grp)
  python grp_viewer.py zelres2 19          # chunk 19 of zelres2.sar
  python grp_viewer.py zelres1 13-20       # view chunks 13-20
  python grp_viewer.py myfile.bin          # view raw binary file directly

Controls:
  Left/Right arrows  : prev/next chunk
  +/-                : zoom in/out
  W/S                : increase/decrease row width (bytes)
  Mouse wheel        : scroll vertically
"""

import sys
import struct
import os
import argparse
from pathlib import Path
import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk, ImageDraw

# Add Tools dir to path for decompress_sar
sys.path.insert(0, str(Path(__file__).parent))
from decompress_sar import read_sar_chunk, decompress_sar_chunk

SAR_PATHS = {
    'zelres1': 'c:/Projects/Zeliard/1_OriginalGame/zelres1.sar',
    'zelres2': 'c:/Projects/Zeliard/1_OriginalGame/zelres2.sar',
    'zelres3': 'c:/Projects/Zeliard/1_OriginalGame/zelres3.sar',
}

PALETTE_JSON = 'c:/Projects/Zeliard/3_Assembly/dumps/palette_rows.json'

def _load_vga_palettes():
    """
    Load captured VGA palettes from DOSBox-X debug overlay screenshots.
    Returns dict: name -> list of 256 (R,G,B) tuples (8-bit, already scaled by DOSBox-X).
    Format: RPAL6[0-63] + EPAL6[64-127] + ACPAL[128-191] + CSPAL[192-255].
    """
    import json, os
    if not os.path.exists(PALETTE_JSON):
        return {}
    with open(PALETTE_JSON) as f:
        raw = json.load(f)
    result = {}
    for name, rows in raw.items():
        flat = [tuple(c) for row in rows for c in row]  # 4 rows × 64 entries = 256
        result[name] = flat
    return result

VGA_PALETTES = _load_vga_palettes()

# Canonical names for the UI
VGA_PAL_NAMES = {
    'opening': 'P1_Opening',
    'title':   'P2_Title',
    'gameplay':'P3_Gameplay',
}

def get_vga_palette(name):
    """Return 256-entry (R,G,B) list for the named scene, or a fallback grayscale."""
    key = VGA_PAL_NAMES.get(name, name)
    if key in VGA_PALETTES:
        return VGA_PALETTES[key]
    return [(i, i, i) for i in range(256)]

def build_nibble_pair_pal(vga_name='gameplay'):
    """
    Build the nibble-pair byte→RGB lookup from a 256-entry VGA palette.
    In mode 13h the byte value IS the palette index.
    Pure nibble N → byte (N<<4)|N = N*17 → palette[N*17].
    Mixed bytes (hi≠lo) → average of palette[hi*17] and palette[lo*17].
    """
    pal = get_vga_palette(vga_name)
    lut = {}
    for byte_val in range(256):
        hi = (byte_val >> 4) & 0xF
        lo = byte_val & 0xF
        c1 = pal[hi * 17]
        c2 = pal[lo * 17]
        lut[byte_val] = ((c1[0]+c2[0])//2, (c1[1]+c2[1])//2, (c1[2]+c2[2])//2)
    lut[0] = pal[0]  # byte 0x00 → palette index 0 (exact)
    return lut

def build_2plane_colors(vga_name='gameplay'):
    """
    4 colors for the 2-plane render from VGA palette:
      idx 0    → (A=0,B=0) background
      idx 0x88 → (A=1,B=1) both planes
      idx 0xAA → (A=1,B=0) plane A only
      idx 0xCC → (A=0,B=1) plane B only
    """
    pal = get_vga_palette(vga_name)
    return [pal[0], pal[0xAA], pal[0xCC], pal[0x88]]

# 4-color palettes for 2-plane mode
# Index order: [background, planeA, planeB, both] → nibbles [0, 0xA, 0xC, 0x8]
PALETTES = {
    'gray':    [(0,0,0), (85,85,85), (170,170,170), (255,255,255)],
    'amber':   [(0,0,0), (160,80,0), (220,150,0), (255,220,80)],
    'green':   [(0,0,0), (0,100,0), (0,180,0), (100,255,100)],
    'opening': build_2plane_colors('opening'),
    'title':   build_2plane_colors('title'),
    'gameplay':build_2plane_colors('gameplay'),
}


def load_chunk_data(archive_or_file, chunk_idx, raw=False):
    """Load and optionally decompress a chunk."""
    if archive_or_file.endswith('.bin') or archive_or_file.endswith('.BIN'):
        # Raw binary file — return bytes as-is, never attempt SAR decompression
        with open(archive_or_file, 'rb') as f:
            return f.read()

    sar_path = SAR_PATHS.get(archive_or_file.lower())
    if not sar_path or not os.path.exists(sar_path):
        raise FileNotFoundError(f"SAR file not found: {sar_path}")

    chunk_data = read_sar_chunk(sar_path, chunk_idx)
    if raw:
        return chunk_data
    return bytes(decompress_sar_chunk(chunk_data))


def auto_widths(data_len):
    """Return list of byte widths that divide evenly into data_len."""
    common = [8, 10, 16, 20, 24, 32, 40, 48, 56, 64, 72, 80, 88, 96, 112, 128, 160, 200, 256]
    good = []
    for w in common:
        rows = data_len // w
        if rows > 0:
            good.append(w)
    # also try half-widths for 2-plane
    if data_len % 2 == 0:
        half = data_len // 2
        for w in common:
            rows = half // w
            if rows > 0 and w not in good:
                good.append(w)
    return sorted(set(good))


def render_raw_bytes(data, width_bytes, offset=0, palette_name='gray'):
    """Render raw bytes as a grayscale image (each byte = 1 pixel)."""
    n = len(data) - offset
    if n <= 0:
        return None
    rows = max(1, n // width_bytes)
    img = Image.new('RGB', (width_bytes, rows), (20, 20, 20))
    px = img.load()
    for y in range(rows):
        for x in range(width_bytes):
            idx = offset + y * width_bytes + x
            if idx < len(data):
                v = data[idx]
                px[x, y] = (v, v, v)
    return img


def render_1bpp(data, width_bytes, offset=0, fg=(255,255,255), bg=(0,0,0)):
    """Render 1-bit-per-pixel: each byte = 8 pixels."""
    n = len(data) - offset
    if n <= 0:
        return None
    width_px = width_bytes * 8
    rows = max(1, n // width_bytes)
    img = Image.new('RGB', (width_px, rows), bg)
    px = img.load()
    for y in range(rows):
        for bx in range(width_bytes):
            idx = offset + y * width_bytes + bx
            if idx < len(data):
                byte = data[idx]
                for bit in range(8):
                    px[bx * 8 + (7 - bit), y] = fg if (byte >> bit) & 1 else bg
    return img


def render_2plane(data, width_bytes, offset=0, palette_name='gray'):
    """
    Render as 2-plane 1bpp image.
    Plane A: data[offset : offset+plane_size]
    Plane B: data[offset+plane_size : offset+2*plane_size]
    Each bit-pair (A,B) -> one of 4 colors.
    """
    pal = PALETTES[palette_name]
    available = len(data) - offset
    if available <= 0:
        return None

    plane_size = available // 2
    rows = plane_size // width_bytes
    if rows == 0:
        return None

    width_px = width_bytes * 8
    plane_a = data[offset:offset + plane_size]
    plane_b = data[offset + plane_size:offset + plane_size * 2]

    img = Image.new('RGB', (width_px, rows), (20, 20, 20))
    px = img.load()
    for y in range(rows):
        for bx in range(width_bytes):
            ai = y * width_bytes + bx
            a_byte = plane_a[ai] if ai < len(plane_a) else 0
            b_byte = plane_b[ai] if ai < len(plane_b) else 0
            for bit in range(8):
                a_bit = (a_byte >> (7 - bit)) & 1
                b_bit = (b_byte >> (7 - bit)) & 1
                # (0,0)->0, (1,0)->1, (0,1)->2, (1,1)->3
                color_idx = a_bit | (b_bit << 1)
                px[bx * 8 + bit, y] = pal[color_idx]
    return img


def render_nibble_pair(data, width_bytes, offset=0, nibble_pal=None):
    """
    Render nibble-pair packed format (Zeliard VGA output format).
    Each byte = 2 pixels: hi nibble = pixel 0, lo nibble = pixel 1.
    width_bytes = bytes per row (image is width_bytes*2 pixels wide).
    Use width_bytes=320 for the VGA framebuffer dump (320 bytes/row = 640 pixels).
    Use width_bytes=448 for the 4-plane render buffer (896 pixels).
    nibble_pal: dict mapping nibble (0-15) to RGB tuple; defaults to NIBBLE_PAIR_PAL.
    """
    if nibble_pal is None:
        nibble_pal = NIBBLE_PAIR_PAL
    n = len(data) - offset
    if n <= 0:
        return None
    width_px = width_bytes * 2
    rows = max(1, n // width_bytes)
    img = Image.new('RGB', (width_px, rows), (0, 0, 0))
    px = img.load()
    for y in range(rows):
        for bx in range(width_bytes):
            idx = offset + y * width_bytes + bx
            if idx < len(data):
                byte = data[idx]
                hi = (byte >> 4) & 0xF
                lo = byte & 0xF
                px[bx * 2,     y] = nibble_pal.get(hi, (255, 0, 255))
                px[bx * 2 + 1, y] = nibble_pal.get(lo, (255, 0, 255))
    return img


def render_nibble(data, width_bytes, offset=0):
    """Render 4-bits-per-pixel (nibble): 2 pixels per byte."""
    n = len(data) - offset
    if n <= 0:
        return None
    width_px = width_bytes * 2  # 2 pixels per byte
    rows = max(1, n // width_bytes)
    # Use EGA default 16-color palette
    ega = [
        (0,0,0), (0,0,170), (0,170,0), (0,170,170),
        (170,0,0), (170,0,170), (170,85,0), (170,170,170),
        (85,85,85), (85,85,255), (85,255,85), (85,255,255),
        (255,85,85), (255,85,255), (255,255,85), (255,255,255),
    ]
    img = Image.new('RGB', (width_px, rows), (20, 20, 20))
    px = img.load()
    for y in range(rows):
        for bx in range(width_bytes):
            idx = offset + y * width_bytes + bx
            if idx < len(data):
                byte = data[idx]
                hi = (byte >> 4) & 0xF
                lo = byte & 0xF
                px[bx * 2,     y] = ega[hi]
                px[bx * 2 + 1, y] = ega[lo]
    return img


def decode_6de1(src: bytes) -> bytes:
    """
    041F:6DE1 RLE decoder for image source data (NOT fill_buffer).
    Input: raw chunk bytes starting after the 4-byte size header.
    1-byte mode (bit6=0): count=b&0x3F; bit7=1→fill, else→copy
    2-byte mode (bit6=1): count=(bigendian_word)&0x3FFF; bit15=fill; 0xFFFF=end
    """
    out = bytearray()
    i = 0
    while i < len(src):
        b = src[i]
        if b & 0x40:  # 2-byte mode
            if i + 1 >= len(src): break
            word = (b << 8) | src[i + 1]; i += 2
            if word == 0xFFFF: break
            count = word & 0x3FFF
            if word & 0x8000:
                if i < len(src): out.extend([src[i]] * count); i += 1
            else:
                out.extend(src[i:i + count]); i += count
        else:  # 1-byte mode
            count = b & 0x3F; i += 1
            if b & 0x80:
                if i < len(src): out.extend([src[i]] * count); i += 1
            else:
                out.extend(src[i:i + count]); i += count
    return bytes(out)


def interleave_4plane(src: bytes, rows: int, cl: int) -> bytes:
    """
    041F:30FC / 041F:4469 — 4-plane interleaver.
    Converts 2-plane 1bpp source (rows×cl bytes/plane × 2 planes) to nibble-packed output.
    BP = rows*cl (plane size); source: plane A at [0..BP-1], plane B at [BP..2*BP-1].
    Output: nibble-packed, 2 pixels/byte, rows×(cl*4) bytes total.
    Each source word pair → 4 calls to 4469 → 8 output bytes (16 pixels).
    """
    BP = rows * cl
    out = bytearray()
    si = 0
    for _ in range(BP // 2):
        bi = BP + si
        bx = (src[bi] << 8 | (src[bi+1] if bi+1 < len(src) else 0)) if bi < len(src) else 0
        ax = (src[si] << 8 | (src[si+1] if si+1 < len(src) else 0)) if si < len(src) else 0
        si += 2
        dx = (~(bx & ax)) & 0xFFFF
        cx = (bx | ax) & 0xFFFF   # P3 = A|B
        ax = ax & dx               # P1 = A&~B
        bx = bx & dx               # P2 = B&~A
        planes = [cx, bx, ax, 0]   # [P3, P2, P1, P0]
        for _call in range(4):
            pw = list(planes); acc = 0
            # Assembly body: (P3,P2,P1,P0)×2 per body × CX=2 bodies = 4 rolls/plane/call
            for _body in range(2):
                for _rep in range(2):
                    for j in range(4):
                        msb = pw[j] >> 15
                        pw[j] = ((pw[j] << 1) & 0xFFFF) | msb
                        acc = ((acc << 1) | msb) & 0xFFFF
            planes = pw
            acc = ((acc & 0xFF) << 8) | ((acc >> 8) & 0xFF)  # xchg AH,AL
            out.extend([acc & 0xFF, (acc >> 8) & 0xFF])       # stos word (little-endian)
    return bytes(out)


def render_2plane_direct(decoded: bytes, cl: int,
                         colors=None) -> Image.Image:
    """
    Render 2-plane 1bpp source directly to 4-color image — no interleaver.
    decoded: output of decode_6de1 (plane A at [0..BP-1], plane B at [BP..2*BP-1]).
    cl: bytes per row per plane (CL). Output is cl*8 pixels wide.
    This is the cleanest way to view the raw art.
    """
    if colors is None:
        colors = [
            (0, 0, 0),       # (A=0,B=0) = background
            (240, 200, 0),   # (A=1,B=0) = yellow
            (200, 60, 60),   # (A=0,B=1) = red/outline
            (0, 100, 180),   # (A=1,B=1) = dark blue
        ]
    BP = len(decoded) // 2
    rows = BP // cl
    W = cl * 8
    img = Image.new('RGB', (W, rows), (0, 0, 0))
    px = img.load()
    for row in range(rows):
        for byte_i in range(cl):
            a = decoded[row * cl + byte_i]
            b = decoded[BP + row * cl + byte_i]
            for bit in range(8):
                a_bit = (a >> (7 - bit)) & 1
                b_bit = (b >> (7 - bit)) & 1
                px[byte_i * 8 + bit, row] = colors[a_bit | (b_bit << 1)]
    return img


def apply_exact_blit(src: bytes, blit_calls: int = 112, call_size: int = 260,
                     outer_passes: int = 8, vga_pal=None,
                     antialias: bool = True) -> Image.Image:
    """
    Apply exact integer blit (041F:3277) with all outer-outer passes OR'd together.
    The game runs BP=8 outer-outer passes, each with row_counter 0..7 cycling the masks.
    All passes write to the same VGA region (DI restored between passes).
    Combined via OR they cover all mod-8 pixel positions → complete clean image.
    Verified: single pass 100% matches VGA dump; 8 passes reconstruct full logo.
    Masks from CS:0x32B9=[0x80,0x20,0x08,0x02,0x40,0x10,0x04,0x01]
             CS:0x32C1=[0x01,0x04,0x10,0x40,0x02,0x08,0x20,0x80]
    vga_pal: list of 256 RGB tuples (full VGA DAC palette).
    antialias: if True, each byte is looked up directly as a palette index (vga_pal[b]).
               if False, byte is snapped to its pure high-nibble color (vga_pal[(b>>4)*17]).
    """
    mask1 = [0x80, 0x20, 0x08, 0x02, 0x40, 0x10, 0x04, 0x01]
    mask2 = [0x01, 0x04, 0x10, 0x40, 0x02, 0x08, 0x20, 0x80]

    def _wp(M):
        bl = M
        for s in range(8):
            cf = (bl >> 7) & 1; bl = ((bl << 1) & 0xFF) | cf
            if cf: return s
        return -1

    m1p = [_wp(mask1[k]) for k in range(8)]
    m2p = [_wp(mask2[k]) for k in range(8)]

    # Accumulate all outer_passes with OR
    vga = bytearray(call_size * blit_calls)
    for start_k in range(outer_passes):
        k = start_k
        for n in range(blit_calls):
            wp = m1p[k % 8] if n % 2 == 0 else m2p[k % 8]
            for i in range(call_size):
                if i % 8 == wp:
                    b = src[n * call_size + i] if n * call_size + i < len(src) else 0
                    vga[n * call_size + i] |= b
            k += 1

    if vga_pal is None:
        vga_pal = get_vga_palette('title')
    img = Image.new('RGB', (call_size, blit_calls), (0, 0, 0))
    px = img.load()
    for n in range(blit_calls):
        for i in range(call_size):
            b = vga[n * call_size + i]
            if b:
                px[i, n] = vga_pal[b] if antialias else vga_pal[(b >> 4) * 17]
    return img


def render_grp_decode(raw_chunk: bytes, cl_bytes: int, offset: int = 0,
                      vga_scale: bool = True, nibble_pal=None, vga_pal=None,
                      antialias: bool = True) -> Image.Image:
    """
    Full GRP decode pipeline: 0x6DE1 RLE → 4-plane interleaver → nibble-pair render.
    raw_chunk: raw SAR chunk bytes (including 4-byte size header).
    cl_bytes: source plane width in bytes (CL). Set via Width control. 112 = title image.
    vga_scale: if True and CL=112, apply the exact title blit (verified vs VGA dump).
               For all other CL values, shows the full native render-buffer view (2px/byte).
    nibble_pal: nibble (0-15) → RGB dict; used for the pre-blit buffer view.
    vga_pal: list of 256 RGB tuples; used for the blit output.
    antialias: passed to apply_exact_blit; True = direct pal[byte], False = snap to pure nibble.
    """
    if nibble_pal is None:
        nibble_pal = NIBBLE_PAIR_PAL
    decoded = decode_6de1(raw_chunk[4 + offset:])
    if not decoded or cl_bytes <= 0:
        return None

    rows = len(decoded) // (cl_bytes * 2)
    if rows < 1:
        return None
    interleaved = interleave_4plane(decoded, rows, cl_bytes)

    if vga_scale and cl_bytes == 112:
        return apply_exact_blit(interleaved, vga_pal=vga_pal, antialias=antialias)

    # Pre-blit render buffer view: each byte = 2 pixels (nibble-pair format)
    w_in = cl_bytes * 4   # bytes per row in interleaved output
    w_px = w_in * 2       # pixels wide
    img = Image.new('RGB', (w_px, rows), (0, 0, 0))
    px = img.load()
    for y in range(rows):
        for x in range(w_in):
            idx = y * w_in + x
            if idx < len(interleaved):
                b = interleaved[idx]
                px[x * 2,     y] = nibble_pal.get((b >> 4) & 0xF, (0, 0, 0))
                px[x * 2 + 1, y] = nibble_pal.get(b & 0xF, (0, 0, 0))
    return img


RENDER_MODES = ['raw_bytes', '1bpp', '2plane', 'nibble_pair', 'nibble_4bpp', 'grp_decode']

# Default nibble-pair palette: computed from captured VGA gameplay palette
# Nibble N -> palette index N*17 -> RGB; byte value = (hi<<4)|lo = average of two entries
NIBBLE_PAIR_PAL = build_nibble_pair_pal('gameplay')


class GrpViewerApp:
    def __init__(self, root, archive, chunks, initial_chunk=0, raw_mode=False):
        self.root = root
        self.archive = archive
        self.chunks = chunks       # list of (chunk_idx, label) tuples
        self.chunk_pos = initial_chunk
        self.raw_mode = raw_mode

        self.data = b''
        self._raw_chunk = b''
        self.vga_scale = True
        self.zoom = 2
        self.width_bytes = 40
        self.offset = 0
        self.mode = '2plane'
        self.palette = 'gray'
        self._photo = None

        self._build_ui()
        self._load_current(auto_suggest=True)
        self.root.bind('<Left>',  lambda e: self._prev_chunk())
        self.root.bind('<Right>', lambda e: self._next_chunk())
        self.root.bind('<plus>',  lambda e: self._zoom(1))
        self.root.bind('<minus>', lambda e: self._zoom(-1))
        self.root.bind('<equal>', lambda e: self._zoom(1))
        self.root.bind('w', lambda e: self._change_width(4))
        self.root.bind('s', lambda e: self._change_width(-4))
        self.canvas.bind('<MouseWheel>', self._on_scroll)

    def _build_ui(self):
        self.root.title('Zeliard GRP Viewer')
        self.root.geometry('1000x700')

        # Top controls
        ctrl = tk.Frame(self.root, bg='#2a2a2a')
        ctrl.pack(side=tk.TOP, fill=tk.X, padx=4, pady=4)

        tk.Label(ctrl, text='Mode:', bg='#2a2a2a', fg='white').pack(side=tk.LEFT, padx=4)
        self.mode_var = tk.StringVar(value=self.mode)
        for m in RENDER_MODES:
            tk.Radiobutton(ctrl, text=m, variable=self.mode_var, value=m,
                           bg='#2a2a2a', fg='white', selectcolor='#555',
                           command=self._redraw).pack(side=tk.LEFT)

        tk.Label(ctrl, text='  Width:', bg='#2a2a2a', fg='white').pack(side=tk.LEFT, padx=4)
        self.width_var = tk.StringVar(value=str(self.width_bytes))
        self.width_spin = tk.Spinbox(ctrl, from_=1, to=512, increment=4,
                                     textvariable=self.width_var, width=5,
                                     command=self._on_width_change)
        self.width_spin.pack(side=tk.LEFT)

        tk.Label(ctrl, text='  Zoom:', bg='#2a2a2a', fg='white').pack(side=tk.LEFT, padx=4)
        self.zoom_var = tk.StringVar(value=str(self.zoom))
        tk.Spinbox(ctrl, from_=1, to=8, textvariable=self.zoom_var, width=3,
                   command=self._on_zoom_change).pack(side=tk.LEFT)

        tk.Label(ctrl, text='  Offset:', bg='#2a2a2a', fg='white').pack(side=tk.LEFT, padx=4)
        self.offset_var = tk.StringVar(value='0')
        tk.Entry(ctrl, textvariable=self.offset_var, width=6).pack(side=tk.LEFT)
        tk.Button(ctrl, text='Go', command=self._on_offset_change,
                  bg='#444', fg='white').pack(side=tk.LEFT, padx=2)

        self.vga_scale_var = tk.BooleanVar(value=self.vga_scale)
        tk.Checkbutton(ctrl, text='VGA scale', variable=self.vga_scale_var,
                       bg='#2a2a2a', fg='white', selectcolor='#555',
                       command=self._redraw).pack(side=tk.LEFT, padx=4)

        self.antialias_var = tk.BooleanVar(value=True)
        tk.Checkbutton(ctrl, text='Anti-alias', variable=self.antialias_var,
                       bg='#2a2a2a', fg='white', selectcolor='#555',
                       command=self._redraw).pack(side=tk.LEFT, padx=4)

        tk.Button(ctrl, text='Save PNG', command=self._save_png,
                  bg='#2a5a2a', fg='white').pack(side=tk.LEFT, padx=4)

        tk.Label(ctrl, text='  Palette:', bg='#2a2a2a', fg='white').pack(side=tk.LEFT, padx=4)
        self.pal_var = tk.StringVar(value=self.palette)
        for p in PALETTES:
            tk.Radiobutton(ctrl, text=p, variable=self.pal_var, value=p,
                           bg='#2a2a2a', fg='white', selectcolor='#555',
                           command=self._redraw).pack(side=tk.LEFT)

        # Second control row: VGA palette selector (for nibble_pair and grp_decode modes)
        ctrl2 = tk.Frame(self.root, bg='#222')
        ctrl2.pack(side=tk.TOP, fill=tk.X, padx=4, pady=2)
        tk.Label(ctrl2, text='VGA palette:', bg='#222', fg='#aaa').pack(side=tk.LEFT, padx=4)
        self.vga_pal_var = tk.StringVar(value='gameplay')
        for name in ('opening', 'title', 'gameplay'):
            tk.Radiobutton(ctrl2, text=name, variable=self.vga_pal_var, value=name,
                           bg='#222', fg='#ddd', selectcolor='#555',
                           command=self._redraw).pack(side=tk.LEFT)
        tk.Label(ctrl2, text='  (used by nibble_pair and grp_decode modes)',
                 bg='#222', fg='#666').pack(side=tk.LEFT, padx=4)

        # Middle: chunk nav
        nav = tk.Frame(self.root, bg='#333')
        nav.pack(side=tk.TOP, fill=tk.X)
        tk.Button(nav, text='<< Prev', command=self._prev_chunk,
                  bg='#444', fg='white').pack(side=tk.LEFT, padx=4)
        self.chunk_label = tk.Label(nav, text='', bg='#333', fg='#aef', font=('Courier', 10))
        self.chunk_label.pack(side=tk.LEFT, expand=True)
        tk.Button(nav, text='Next >>', command=self._next_chunk,
                  bg='#444', fg='white').pack(side=tk.RIGHT, padx=4)

        # Canvas with scrollbar
        frame = tk.Frame(self.root)
        frame.pack(fill=tk.BOTH, expand=True)
        self.vscroll = tk.Scrollbar(frame, orient=tk.VERTICAL)
        self.vscroll.pack(side=tk.RIGHT, fill=tk.Y)
        self.canvas = tk.Canvas(frame, bg='#111', yscrollcommand=self.vscroll.set)
        self.canvas.pack(fill=tk.BOTH, expand=True)
        self.vscroll.config(command=self.canvas.yview)

        # Status bar
        self.status = tk.Label(self.root, text='', bg='#1a1a1a', fg='#888',
                                font=('Courier', 9), anchor='w')
        self.status.pack(side=tk.BOTTOM, fill=tk.X)

        # Detect good widths on canvas click
        self.canvas.bind('<Button-1>', self._on_canvas_click)

    def _load_current(self, auto_suggest=False):
        if not self.chunks:
            return
        chunk_idx, label = self.chunks[self.chunk_pos]
        try:
            self.data = load_chunk_data(self.archive, chunk_idx, self.raw_mode)
            # Also keep raw bytes for grp_decode mode
            if self.archive.endswith('.bin') or self.archive.endswith('.BIN'):
                self._raw_chunk = self.data
            else:
                self._raw_chunk = load_chunk_data(self.archive, chunk_idx, raw=True)
            self.chunk_label.config(text=f'{label}  |  {len(self.data)} bytes decompressed')
            if auto_suggest:
                self._suggest_width()
            self._redraw()
        except Exception as e:
            self.chunk_label.config(text=f'Error loading {label}: {e}')
            self.status.config(text=str(e))

    def _suggest_width(self):
        """Try to pick a sensible default width based on common PC-98 image sizes."""
        n = len(self.data)
        # Raw chunk with opcode=0 (flag=0, first data byte=0x00) → likely grp_decode candidate
        raw = self._raw_chunk
        if len(raw) >= 6 and raw[4] == 0 and (raw[5] & 7) == 0:
            dec = decode_6de1(raw[4:])
            half = len(dec) // 2
            # Prefer CL that divides the plane size evenly; fall back to first with >=4 rows
            best_cl = None
            for cl in [112, 80, 64, 56, 48, 40, 32]:
                rows = half // cl
                if rows >= 4:
                    if half % cl == 0:
                        best_cl = cl
                        break
                    if best_cl is None:
                        best_cl = cl
            if best_cl:
                self.width_bytes = best_cl
                self.width_var.set(str(best_cl))
                self.mode_var.set('grp_decode')
                return
        # VGA framebuffer dump: exactly 64000 bytes = 320x200
        if n == 64000:
            self.width_bytes = 320
            self.width_var.set('320')
            self.mode_var.set('nibble_pair')
            return
        # PC-98: 640px wide / 8 = 80 bytes/row for full-screen 1bpp
        # VGA:   320px wide / 8 = 40 bytes/row
        # Try 2-plane first (works even if not exactly divisible — just clips last row)
        for w in [80, 40, 48, 64, 56, 96, 112]:
            plane = n // 2
            rows = plane // w
            if rows >= 4:
                self.width_bytes = w
                self.width_var.set(str(w))
                self.mode_var.set('2plane')
                return
        # Fall back to 1bpp
        for w in [80, 40, 48, 64, 56]:
            rows = n // w
            if rows >= 4:
                self.width_bytes = w
                self.width_var.set(str(w))
                self.mode_var.set('1bpp')
                return

    def _redraw(self):
        self.mode = self.mode_var.get()
        self.palette = self.pal_var.get()
        try:
            self.width_bytes = max(1, int(self.width_var.get()))
        except ValueError:
            pass

        img = self._render()
        if img is None:
            self.status.config(text='No image to render')
            return

        # Scale
        w, h = img.size
        sw, sh = w * self.zoom, h * self.zoom
        if self.zoom > 1:
            img = img.resize((sw, sh), Image.NEAREST)

        self._photo = ImageTk.PhotoImage(img)
        self.canvas.delete('all')
        self.canvas.create_image(0, 0, anchor='nw', image=self._photo)
        self.canvas.config(scrollregion=(0, 0, sw, sh))

        info = (f'mode={self.mode}  width={self.width_bytes}B  '
                f'zoom={self.zoom}x  offset={self.offset}  '
                f'size={len(self.data)}B  img={w}x{h}px')
        self.status.config(text=info)

    def _render(self):
        mode = self.mode_var.get()
        wb = self.width_bytes
        off = self.offset
        pal = self.palette
        vga_name = self.vga_pal_var.get()
        nibble_pal = build_nibble_pair_pal(vga_name)
        vga_pal = get_vga_palette(vga_name)
        if mode == 'raw_bytes':
            return render_raw_bytes(self.data, wb, off)
        elif mode == '1bpp':
            return render_1bpp(self.data, wb, off)
        elif mode == '2plane':
            return render_2plane(self.data, wb, off, pal)
        elif mode == 'nibble_pair':
            return render_nibble_pair(self.data, wb, off, nibble_pal=nibble_pal)
        elif mode == 'nibble_4bpp':
            return render_nibble(self.data, wb, off)
        elif mode == 'grp_decode':
            return render_grp_decode(self._raw_chunk, wb, 0,
                                     vga_scale=self.vga_scale_var.get(),
                                     nibble_pal=nibble_pal, vga_pal=vga_pal,
                                     antialias=self.antialias_var.get())
        return None

    def _prev_chunk(self):
        if self.chunk_pos > 0:
            self.chunk_pos -= 1
            self.offset = 0
            self.offset_var.set('0')
            self._load_current()

    def _next_chunk(self):
        if self.chunk_pos < len(self.chunks) - 1:
            self.chunk_pos += 1
            self.offset = 0
            self.offset_var.set('0')
            self._load_current()

    def _zoom(self, delta):
        self.zoom = max(1, min(8, self.zoom + delta))
        self.zoom_var.set(str(self.zoom))
        self._redraw()

    def _change_width(self, delta):
        self.width_bytes = max(1, self.width_bytes + delta)
        self.width_var.set(str(self.width_bytes))
        self._redraw()

    def _on_width_change(self):
        try:
            self.width_bytes = max(1, int(self.width_var.get()))
        except ValueError:
            pass
        self._redraw()

    def _on_zoom_change(self):
        try:
            self.zoom = max(1, int(self.zoom_var.get()))
        except ValueError:
            pass
        self._redraw()

    def _on_offset_change(self):
        try:
            v = self.offset_var.get()
            self.offset = int(v, 16) if v.startswith('0x') or any(c in v for c in 'abcdefABCDEF') else int(v)
        except ValueError:
            self.offset = 0
        self._redraw()

    def _save_png(self):
        """Export the current view as a PNG file."""
        import tkinter.filedialog as fd
        chunk_idx, label = self.chunks[self.chunk_pos]
        default = f'{label.replace(" ", "_").replace("/", "_")}.png'
        path = fd.asksaveasfilename(
            defaultextension='.png', filetypes=[('PNG', '*.png'), ('All', '*.*')],
            initialfile=default, title='Save PNG')
        if not path:
            return
        mode = self.mode_var.get()
        if mode == 'grp_decode':
            # Export: exact blit output (260×112, 100% VGA-accurate)
            img = render_grp_decode(self._raw_chunk, self.width_bytes, 0, vga_scale=True)
        else:
            img = self._render()
        if img:
            img.save(path)
            self.status.config(text=f'Saved {path}  ({img.size[0]}×{img.size[1]}px)')

    def _on_scroll(self, event):
        self.canvas.yview_scroll(-1 * (event.delta // 120), 'units')

    def _on_canvas_click(self, event):
        """Show byte value at clicked pixel."""
        x = int(self.canvas.canvasx(event.x)) // self.zoom
        y = int(self.canvas.canvasy(event.y)) // self.zoom
        mode = self.mode_var.get()
        if mode == 'raw_bytes':
            idx = self.offset + y * self.width_bytes + x
        elif mode in ('1bpp', '2plane'):
            bx = int(x) // 8
            bit = 7 - (int(x) % 8)
            idx = self.offset + int(y) * self.width_bytes + bx
        else:
            idx = self.offset + int(y) * self.width_bytes + int(x) // 2
        if 0 <= idx < len(self.data):
            val = self.data[idx]
            self.status.config(text=f'offset=0x{idx:04X}({idx})  byte=0x{val:02X}({val})')


def parse_chunk_range(s):
    """Parse '14' or '13-20' into list of indices."""
    if '-' in s:
        a, b = s.split('-', 1)
        return list(range(int(a), int(b) + 1))
    return [int(s)]


def main():
    parser = argparse.ArgumentParser(description='Zeliard GRP chunk viewer')
    parser.add_argument('archive', help='zelres1/zelres2/zelres3 or path to .bin file')
    parser.add_argument('chunks', nargs='?', default='13-38',
                        help='chunk index or range like 13-20 (default: 13-38)')
    parser.add_argument('--raw', action='store_true', help='no decompression')
    parser.add_argument('--width', type=int, default=0, help='initial row width in bytes')
    parser.add_argument('--mode', default='2plane',
                        choices=RENDER_MODES, help='initial render mode')
    parser.add_argument('--zoom', type=int, default=2)
    args = parser.parse_args()

    # Build chunk list
    if args.archive.endswith('.bin') or args.archive.endswith('.BIN'):
        chunks = [(0, Path(args.archive).name)]
    else:
        indices = parse_chunk_range(args.chunks)
        chunks = [(i, f'{args.archive} chunk {i:02d}') for i in indices]

    root = tk.Tk()
    app = GrpViewerApp(root, args.archive, chunks, raw_mode=args.raw)

    if args.width:
        app.width_bytes = args.width
        app.width_var.set(str(args.width))
    app.mode_var.set(args.mode)
    app.zoom = args.zoom
    app.zoom_var.set(str(args.zoom))

    # Re-render with CLI-applied settings (no auto_suggest — respect explicit args)
    app._redraw()
    root.mainloop()


if __name__ == '__main__':
    main()
