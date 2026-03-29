#!/usr/bin/env python3
"""
grp_view2.py - Clean Zeliard GRP image viewer for loose files.

Loads any .grp file (with or without SAR 4-byte size header) and renders
it through the authentic GRP decode pipeline:
  fill_buffer → 0x6DE1 RLE → 4-plane interleaver → VGA blit

Three render modes:
  grp_decode  - Pre-blit nibble-pair render buffer (full native width)
  vga_scale   - Exact VGA blit output with pure-nibble color snapping
  anti_alias  - Exact VGA blit output with full palette lookup (smooth)

Usage:
  python grp_view2.py path/to/file.grp
  python grp_view2.py path/to/file.grp --cl 112

Controls:
  +/-    zoom in/out
  W/S    increase/decrease CL (plane width in bytes)
"""

import sys
import struct
import argparse
from pathlib import Path
import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk

# ── palette ───────────────────────────────────────────────────────────────────

PALETTE_JSON = 'c:/Projects/Zeliard/3_Assembly/dumps/palette_rows.json'

def _load_vga_palette(name='P2_Title'):
    import json, os
    if not os.path.exists(PALETTE_JSON):
        return [(i, i, i) for i in range(256)]
    with open(PALETTE_JSON) as f:
        raw = json.load(f)
    if name in raw:
        return [tuple(c) for row in raw[name] for c in row]
    return [(i, i, i) for i in range(256)]

VGA_PAL = _load_vga_palette('P2_Title')

def _nibble_pal():
    lut = {}
    for b in range(256):
        hi, lo = (b >> 4) & 0xF, b & 0xF
        c1, c2 = VGA_PAL[hi * 17], VGA_PAL[lo * 17]
        lut[b] = ((c1[0]+c2[0])//2, (c1[1]+c2[1])//2, (c1[2]+c2[2])//2)
    lut[0] = VGA_PAL[0]
    return lut

NIBBLE_PAL = _nibble_pal()

# ── decoding pipeline ─────────────────────────────────────────────────────────

def _detect_and_strip_header(data: bytes) -> bytes:
    """
    If the file has a SAR chunk header (first 4 bytes LE uint32 + 4 == file size),
    strip it. Also skip the fill_buffer opcode byte if present (byte 4 = flag/opcode).
    Returns the payload suitable for decode_6de1.
    """
    if len(data) < 5:
        return data
    hdr = struct.unpack_from('<I', data, 0)[0]
    if hdr + 4 == len(data):
        # Has 4-byte size header — skip header + flag byte (fill_buffer opcode)
        # fill_buffer opcode byte is at data[4]; the actual 6DE1 payload follows
        # For opcode=0 (verbatim): payload starts at byte 5
        # For other opcodes: format 3/6/7 — not applicable here (image data uses 6DE1)
        return data[5:]   # skip 4-byte header + 1-byte flag
    # No SAR header — data starts directly (VFSExtractor format)
    return data


def decode_6de1(src: bytes) -> bytes:
    """041F:6DE1 RLE image decoder."""
    out = bytearray()
    i = 0
    while i < len(src):
        b = src[i]
        if b & 0x40:
            if i + 1 >= len(src): break
            word = (b << 8) | src[i + 1]; i += 2
            if word == 0xFFFF: break
            count = word & 0x3FFF
            if word & 0x8000:
                if i < len(src): out.extend([src[i]] * count); i += 1
            else:
                out.extend(src[i:i + count]); i += count
        else:
            count = b & 0x3F; i += 1
            if b & 0x80:
                if i < len(src): out.extend([src[i]] * count); i += 1
            else:
                out.extend(src[i:i + count]); i += count
    return bytes(out)


def interleave_4plane(src: bytes, rows: int, cl: int) -> bytes:
    """041F:30FC 4-plane interleaver: 2-plane 1bpp → nibble-packed."""
    BP = rows * cl
    out = bytearray()
    si = 0
    for _ in range(BP // 2):
        bi = BP + si
        bx = (src[bi] << 8 | (src[bi+1] if bi+1 < len(src) else 0)) if bi < len(src) else 0
        ax = (src[si] << 8 | (src[si+1] if si+1 < len(src) else 0)) if si < len(src) else 0
        si += 2
        dx = (~(bx & ax)) & 0xFFFF
        cx = (bx | ax) & 0xFFFF
        ax = ax & dx
        bx = bx & dx
        planes = [cx, bx, ax, 0]
        for _ in range(4):
            pw = list(planes); acc = 0
            for _ in range(2):
                for _ in range(2):
                    for j in range(4):
                        msb = pw[j] >> 15
                        pw[j] = ((pw[j] << 1) & 0xFFFF) | msb
                        acc = ((acc << 1) | msb) & 0xFFFF
            planes = pw
            acc = ((acc & 0xFF) << 8) | ((acc >> 8) & 0xFF)
            out.extend([acc & 0xFF, (acc >> 8) & 0xFF])
    return bytes(out)


def apply_exact_blit(src: bytes, blit_calls: int = 112, call_size: int = 260,
                     outer_passes: int = 8, antialias: bool = True) -> Image.Image:
    """041F:3277 exact blit with 8 outer passes OR'd. Verified vs VGA dump."""
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

    img = Image.new('RGB', (call_size, blit_calls), (0, 0, 0))
    px = img.load()
    for n in range(blit_calls):
        for i in range(call_size):
            b = vga[n * call_size + i]
            if b:
                px[i, n] = VGA_PAL[b] if antialias else VGA_PAL[(b >> 4) * 17]
    return img


def decode_grp(data: bytes, cl: int):
    """Full pipeline: detect header → 6DE1 → 4-plane → interleaved nibble buffer."""
    payload = _detect_and_strip_header(data)
    decoded = decode_6de1(payload)
    if not decoded or cl <= 0:
        return None, 0, 0
    rows = len(decoded) // (cl * 2)
    if rows < 1:
        return None, 0, 0
    interleaved = interleave_4plane(decoded, rows, cl)
    return interleaved, rows, cl


def render_grp_decode(interleaved: bytes, rows: int, cl: int) -> Image.Image:
    """Pre-blit nibble-pair render buffer view."""
    w_bytes = cl * 4
    w_px = w_bytes * 2
    img = Image.new('RGB', (w_px, rows), (0, 0, 0))
    px = img.load()
    for y in range(rows):
        for x in range(w_bytes):
            idx = y * w_bytes + x
            if idx < len(interleaved):
                b = interleaved[idx]
                px[x * 2,     y] = NIBBLE_PAL.get(b & 0xF0, (0,0,0))
                px[x * 2 + 1, y] = NIBBLE_PAL.get(b & 0x0F, (0,0,0))
    return img


# ── viewer app ────────────────────────────────────────────────────────────────

class GrpViewer:
    def __init__(self, root, filepath: str, cl: int):
        self.root = root
        self.filepath = filepath
        self.cl = cl
        self.zoom = 2
        self._photo_decode = None
        self._photo_vga = None
        self._interleaved = None
        self._rows = 0

        self.data = Path(filepath).read_bytes()
        root.title(f'GRP Viewer — {Path(filepath).name}')

        self._build_ui()
        self._decode()
        self._redraw()
        root.bind('+', lambda e: self._set_zoom(self.zoom + 1))
        root.bind('=', lambda e: self._set_zoom(self.zoom + 1))
        root.bind('-', lambda e: self._set_zoom(self.zoom - 1))
        root.bind('w', lambda e: self._set_cl(self.cl + 4))
        root.bind('s', lambda e: self._set_cl(max(4, self.cl - 4)))

    def _build_ui(self):
        top = tk.Frame(self.root)
        top.pack(side=tk.TOP, fill=tk.X, padx=4, pady=2)

        self.antialias_var = tk.BooleanVar(value=True)
        tk.Checkbutton(top, text='Anti-alias', variable=self.antialias_var,
                       command=self._redraw).pack(side=tk.LEFT)

        tk.Label(top, text='  CL:').pack(side=tk.LEFT)
        self.cl_var = tk.StringVar(value=str(self.cl))
        cl_entry = tk.Entry(top, textvariable=self.cl_var, width=5)
        cl_entry.pack(side=tk.LEFT)
        cl_entry.bind('<Return>', lambda e: self._on_cl_change())

        tk.Label(top, text='  Zoom:').pack(side=tk.LEFT)
        self.zoom_var = tk.StringVar(value=str(self.zoom))
        zoom_entry = tk.Entry(top, textvariable=self.zoom_var, width=3)
        zoom_entry.pack(side=tk.LEFT)
        zoom_entry.bind('<Return>', lambda e: self._redraw())

        tk.Button(top, text='Save PNG', command=self._save_png).pack(side=tk.RIGHT)

        self.status = tk.Label(self.root, text='', anchor='w', relief=tk.SUNKEN)
        self.status.pack(side=tk.BOTTOM, fill=tk.X)

        # Two panels side by side: grp_decode (left) and vga_scale (right)
        panels = tk.Frame(self.root)
        panels.pack(fill=tk.BOTH, expand=True)

        left = tk.LabelFrame(panels, text='grp_decode', bg='#1a1a1a', fg='white')
        left.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.canvas_decode = tk.Canvas(left, bg='#1a1a1a')
        vsb_l = ttk.Scrollbar(left, orient=tk.VERTICAL, command=self.canvas_decode.yview)
        self.canvas_decode.configure(yscrollcommand=vsb_l.set)
        vsb_l.pack(side=tk.RIGHT, fill=tk.Y)
        self.canvas_decode.pack(fill=tk.BOTH, expand=True)
        self.canvas_decode.bind('<MouseWheel>', lambda e: self.canvas_decode.yview_scroll(-1*(e.delta//120), 'units'))

        right = tk.LabelFrame(panels, text='vga_scale', bg='#1a1a1a', fg='white')
        right.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.canvas_vga = tk.Canvas(right, bg='#1a1a1a')
        vsb_r = ttk.Scrollbar(right, orient=tk.VERTICAL, command=self.canvas_vga.yview)
        self.canvas_vga.configure(yscrollcommand=vsb_r.set)
        vsb_r.pack(side=tk.RIGHT, fill=tk.Y)
        self.canvas_vga.pack(fill=tk.BOTH, expand=True)
        self.canvas_vga.bind('<MouseWheel>', lambda e: self.canvas_vga.yview_scroll(-1*(e.delta//120), 'units'))

    def _decode(self):
        self._interleaved, self._rows, _ = decode_grp(self.data, self.cl)
        if self._interleaved:
            self.status.config(text=f'CL={self.cl}  rows={self._rows}  '
                                    f'interleaved={len(self._interleaved)} bytes')
        else:
            self.status.config(text='Decode failed — try different CL value')

    def _redraw(self):
        try:
            self.zoom = max(1, min(8, int(self.zoom_var.get())))
        except ValueError:
            pass

        if self._interleaved is None:
            for c in (self.canvas_decode, self.canvas_vga):
                c.delete('all')
                c.create_text(10, 10, text='No image', fill='white', anchor='nw')
            return

        z = self.zoom

        # grp_decode panel
        img_d = render_grp_decode(self._interleaved, self._rows, self.cl)
        if img_d:
            w, h = img_d.size[0] * z, img_d.size[1] * z
            scaled = img_d.resize((w, h), Image.NEAREST)
            self._photo_decode = ImageTk.PhotoImage(scaled)
            self.canvas_decode.delete('all')
            self.canvas_decode.create_image(0, 0, anchor='nw', image=self._photo_decode)
            self.canvas_decode.configure(scrollregion=(0, 0, w, h))

        # vga_scale panel
        antialias = self.antialias_var.get()
        img_v = apply_exact_blit(self._interleaved, antialias=antialias)
        if img_v:
            w, h = img_v.size[0] * z, img_v.size[1] * z
            scaled = img_v.resize((w, h), Image.NEAREST)
            self._photo_vga = ImageTk.PhotoImage(scaled)
            self.canvas_vga.delete('all')
            self.canvas_vga.create_image(0, 0, anchor='nw', image=self._photo_vga)
            self.canvas_vga.configure(scrollregion=(0, 0, w, h))

    def _on_cl_change(self):
        try:
            self.cl = max(1, int(self.cl_var.get()))
        except ValueError:
            return
        self._decode()
        self._redraw()

    def _set_zoom(self, z):
        self.zoom = max(1, min(8, z))
        self.zoom_var.set(str(self.zoom))
        self._redraw()

    def _set_cl(self, cl):
        self.cl = cl
        self.cl_var.set(str(cl))
        self._decode()
        self._redraw()

    def _save_png(self):
        import tkinter.filedialog as fd
        stem = Path(self.filepath).stem
        path = fd.asksaveasfilename(defaultextension='.png',
                                    filetypes=[('PNG', '*.png')],
                                    initialfile=f'{stem}_vgascale.png')
        if not path:
            return
        antialias = self.antialias_var.get()
        img = apply_exact_blit(self._interleaved, antialias=antialias)
        if img:
            img.save(path)
            self.status.config(text=f'Saved {path}')


# ── entry point ───────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description='Zeliard GRP viewer (loose files)')
    parser.add_argument('file', help='Path to .grp file')
    parser.add_argument('--cl', type=int, default=112,
                        help='Plane width in bytes (default: 112 for title images)')
    parser.add_argument('--zoom', type=int, default=2)
    args = parser.parse_args()

    root = tk.Tk()
    app = GrpViewer(root, args.file, args.cl)
    app._set_zoom(args.zoom)
    root.mainloop()


if __name__ == '__main__':
    main()
