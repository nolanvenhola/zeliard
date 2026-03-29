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

BIN_ROOT = Path('c:/Projects/Zeliard/3_Assembly/tasm/bin')
ZELRES_FOLDERS = {
    'zelres1': BIN_ROOT / 'zelres1',
    'zelres2': BIN_ROOT / 'zelres2',
    'zelres3': BIN_ROOT / 'zelres3',
}

# (CH, CL) pairs extracted from mov cx,XXXXh call sites in the assembly code.
# Used to match decompressed GRP size -> candidate CL values.
_KNOWN_DIMS = [
    (2,8),(4,8),(5,8),(7,8),(16,8),(3,16),(16,16),(11,16),(39,16),(4,16),(28,16),
    (17,16),(8,16),(52,16),(30,16),(2,20),(4,20),(6,24),(10,24),(7,24),(9,24),(2,24),
    (18,32),(9,32),(6,32),(1,32),(14,32),(3,32),(26,36),(37,36),(50,36),(28,36),
    (56,40),(16,40),(30,40),(34,48),(15,60),(80,60),(1,64),(16,64),(31,64),(66,64),
    (6,64),(56,72),(22,80),(24,88),(47,88),(22,88),(49,96),(127,96),(26,100),(28,100),
    (36,104),(44,104),(72,104),(65,112),(34,112),(84,112),(80,120),(4,128),(49,128),(62,128),
    (2,128),(80,136),(1,144),(134,160),(80,160),(63,176),(64,192),(15,192),(80,200),
    (31,216),(46,224),(3,232),
]

_KNOWN_DIMS_SET = set(_KNOWN_DIMS)

def candidate_cls(decoded_size: int) -> list[int]:
    """
    Return candidate CL values for a decoded GRP image buffer.
    Primary: (CH, CL) pairs from the known ASM table that fit within decoded_size.
    Fallback: CL values that evenly divide decoded_size/2 into a reasonable row count.
    """
    # Primary: exact match from known dimension table (±64 byte padding)
    primary = sorted({cl for (ch, cl) in _KNOWN_DIMS
                      if 0 <= decoded_size - ch * cl * 2 < 64})
    if primary:
        return primary
    # Fallback: any CL divisor of decoded_size//2 with 1–256 rows
    half = decoded_size // 2
    return sorted({cl for cl in range(8, 257, 4)
                   if half % cl == 0 and 1 <= half // cl <= 256})

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


def render_grp(interleaved: bytes, rows: int, cl: int, antialias: bool = True) -> Image.Image:
    """
    Reconstruct the image using the game's 8-pass blit mask logic.

    blit_calls = cl  (one blit call per pixel-column group)
    call_size  = rows * 4  (bytes per blit call)

    This formula is derived from the verified TTL3G parameters:
      CH=65, CL=112 → blit_calls=112=CL, call_size=260=CH*4

    antialias=True:  full VGA palette lookup per byte (smooth mixed colors)
    antialias=False: snap to pure nibble color (crisp 4-color look)
    """
    mask1 = [0x80, 0x20, 0x08, 0x02, 0x40, 0x10, 0x04, 0x01]
    mask2 = [0x01, 0x04, 0x10, 0x40, 0x02, 0x08, 0x20, 0x80]

    def _wp(M):
        bl = M
        for s in range(8):
            cf = (bl >> 7) & 1; bl = ((bl << 1) & 0xFF) | cf
            if cf: return s
        return -1

    blit_calls = cl
    call_size  = rows * 4
    m1p = [_wp(mask1[k]) for k in range(8)]
    m2p = [_wp(mask2[k]) for k in range(8)]

    vga = bytearray(call_size * blit_calls)
    for start_k in range(8):
        k = start_k
        for n in range(blit_calls):
            wp = m1p[k % 8] if n % 2 == 0 else m2p[k % 8]
            for i in range(call_size):
                if i % 8 == wp:
                    src_idx = n * call_size + i
                    if src_idx < len(interleaved):
                        vga[src_idx] |= interleaved[src_idx]
            k += 1

    img = Image.new('RGB', (call_size, blit_calls), (0, 0, 0))
    px = img.load()
    for n in range(blit_calls):
        for i in range(call_size):
            b = vga[n * call_size + i]
            if b:
                px[i, n] = VGA_PAL[b] if antialias else VGA_PAL[(b >> 4) * 17]
    return img



# ── viewer app ────────────────────────────────────────────────────────────────

class GrpViewer:
    def __init__(self, root, filepath: str, cl: int):
        self.root = root
        self.filepath = Path(filepath)
        self.folder = self.filepath.parent
        self.cl = cl
        self.zoom = 2
        self._photo = None
        self._interleaved = None
        self._rows = 0
        self.data = b''

        root.title('GRP Viewer')

        self._build_ui()
        self._populate_file_list()
        self._load_file(self.filepath)
        root.bind('+', lambda e: self._set_zoom(self.zoom + 1))
        root.bind('=', lambda e: self._set_zoom(self.zoom + 1))
        root.bind('-', lambda e: self._set_zoom(self.zoom - 1))
        root.bind('w', lambda e: self._set_cl(self.cl + 4))
        root.bind('s', lambda e: self._set_cl(max(4, self.cl - 4)))

    def _build_ui(self):
        # Toolbar
        top = tk.Frame(self.root)
        top.pack(side=tk.TOP, fill=tk.X, padx=4, pady=2)

        tk.Button(top, text='Browse…', command=self._browse_folder).pack(side=tk.LEFT)

        self.antialias_var = tk.BooleanVar(value=True)
        tk.Checkbutton(top, text='Anti-alias', variable=self.antialias_var,
                       command=self._redraw).pack(side=tk.LEFT, padx=(8, 0))

        tk.Label(top, text='  CL:').pack(side=tk.LEFT)
        self.cl_var = tk.StringVar(value=str(self.cl))
        self.cl_combo = ttk.Combobox(top, textvariable=self.cl_var, width=7,
                                     state='normal')
        self.cl_combo.pack(side=tk.LEFT)
        self.cl_combo.bind('<<ComboboxSelected>>', lambda e: self._on_cl_change())
        self.cl_combo.bind('<Return>', lambda e: self._on_cl_change())

        tk.Label(top, text='  Zoom:').pack(side=tk.LEFT)
        self.zoom_var = tk.StringVar(value=str(self.zoom))
        zoom_entry = tk.Entry(top, textvariable=self.zoom_var, width=3)
        zoom_entry.pack(side=tk.LEFT)
        zoom_entry.bind('<Return>', lambda e: self._redraw())

        tk.Button(top, text='Save PNG', command=self._save_png).pack(side=tk.RIGHT)

        # Status bar
        self.status = tk.Label(self.root, text='', anchor='w', relief=tk.SUNKEN)
        self.status.pack(side=tk.BOTTOM, fill=tk.X)

        # Main area: file list (left) + canvas (right)
        main = tk.Frame(self.root)
        main.pack(fill=tk.BOTH, expand=True)

        # File list panel
        list_frame = tk.Frame(main, width=180)
        list_frame.pack(side=tk.LEFT, fill=tk.Y)
        list_frame.pack_propagate(False)

        # Quick-switch buttons for zelres1/2/3
        zr_frame = tk.Frame(list_frame)
        zr_frame.pack(fill=tk.X, padx=2, pady=2)
        for name, path in ZELRES_FOLDERS.items():
            tk.Button(zr_frame, text=name, width=6,
                      command=lambda p=path: self._switch_folder(p)
                      ).pack(side=tk.LEFT, padx=1)

        self.folder_label = tk.Label(list_frame, text='', anchor='w',
                                     font=('TkDefaultFont', 8), wraplength=175)
        self.folder_label.pack(fill=tk.X, padx=2, pady=2)

        vsb_list = ttk.Scrollbar(list_frame, orient=tk.VERTICAL)
        self.file_list = tk.Listbox(list_frame, yscrollcommand=vsb_list.set,
                                    selectmode=tk.SINGLE, activestyle='dotbox',
                                    bg='#2a2a2a', fg='white', selectbackground='#4a7aaf',
                                    font=('Consolas', 9))
        vsb_list.config(command=self.file_list.yview)
        vsb_list.pack(side=tk.RIGHT, fill=tk.Y)
        self.file_list.pack(fill=tk.BOTH, expand=True)
        self.file_list.bind('<<ListboxSelect>>', self._on_list_select)

        # Canvas panel
        canvas_frame = tk.Frame(main)
        canvas_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.canvas = tk.Canvas(canvas_frame, bg='#1a1a1a')
        vsb = ttk.Scrollbar(canvas_frame, orient=tk.VERTICAL, command=self.canvas.yview)
        hsb = ttk.Scrollbar(canvas_frame, orient=tk.HORIZONTAL, command=self.canvas.xview)
        self.canvas.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        vsb.pack(side=tk.RIGHT, fill=tk.Y)
        hsb.pack(side=tk.BOTTOM, fill=tk.X)
        self.canvas.pack(fill=tk.BOTH, expand=True)
        self.canvas.bind('<MouseWheel>',
                         lambda e: self.canvas.yview_scroll(-1*(e.delta//120), 'units'))

    def _populate_file_list(self):
        self.file_list.delete(0, tk.END)
        files = sorted(self.folder.glob('*.grp')) + sorted(self.folder.glob('*.GRP'))
        self._files = files
        for f in files:
            self.file_list.insert(tk.END, f.name)
        self.folder_label.config(text=str(self.folder))
        # Select current file
        try:
            idx = [f.name.lower() for f in files].index(self.filepath.name.lower())
            self.file_list.selection_set(idx)
            self.file_list.see(idx)
        except ValueError:
            pass

    def _on_list_select(self, event):
        sel = self.file_list.curselection()
        if sel and self._files:
            self._load_file(self._files[sel[0]])

    def _switch_folder(self, path: Path):
        self.folder = path
        self._populate_file_list()
        # Auto-load first file if list is not empty
        if self._files:
            self._load_file(self._files[0])

    def _browse_folder(self):
        import tkinter.filedialog as fd
        folder = fd.askdirectory(initialdir=str(self.folder), title='Select GRP folder')
        if folder:
            self.folder = Path(folder)
            self._populate_file_list()

    def _load_file(self, path: Path):
        self.filepath = path
        self.root.title(f'GRP Viewer — {path.name}')
        try:
            self.data = path.read_bytes()
        except OSError as e:
            self.status.config(text=str(e))
            return
        self._decode()
        self._redraw()

    def _decode(self):
        # Compute candidate CLs from known assembly dimension table
        payload = _detect_and_strip_header(self.data)
        decoded_len = len(decode_6de1(payload))
        candidates = candidate_cls(decoded_len)
        if candidates:
            self.cl_combo['values'] = [str(c) for c in candidates]
            # Auto-select if current CL not in candidates
            if self.cl not in candidates:
                self.cl = candidates[0]
                self.cl_var.set(str(self.cl))
        else:
            self.cl_combo['values'] = []

        self._interleaved, self._rows, _ = decode_grp(self.data, self.cl)
        if self._interleaved:
            self.status.config(text=f'CL={self.cl}  rows={self._rows}  '
                                    f'{self.cl*8}px wide  '
                                    f'decoded={decoded_len} bytes')
        else:
            self.status.config(text=f'Decode failed — decoded={decoded_len}B, '
                                    f'candidates={candidates}')

    def _redraw(self):
        try:
            self.zoom = max(1, min(8, int(self.zoom_var.get())))
        except ValueError:
            pass

        if self._interleaved is None:
            self.canvas.delete('all')
            self.canvas.create_text(10, 10, text='No image', fill='white', anchor='nw')
            return

        antialias = self.antialias_var.get()
        img = render_grp(self._interleaved, self._rows, self.cl, antialias=antialias)
        if img:
            z = self.zoom
            w, h = img.size[0] * z, img.size[1] * z
            scaled = img.resize((w, h), Image.NEAREST)
            self._photo = ImageTk.PhotoImage(scaled)
            self.canvas.delete('all')
            self.canvas.create_image(0, 0, anchor='nw', image=self._photo)
            self.canvas.configure(scrollregion=(0, 0, w, h))

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
        path = fd.asksaveasfilename(defaultextension='.png',
                                    filetypes=[('PNG', '*.png')],
                                    initialfile=f'{self.filepath.stem}_vgascale.png')
        if not path:
            return
        antialias = self.antialias_var.get()
        img = render_grp(self._interleaved, self._rows, self.cl, antialias=antialias)
        if img:
            img.save(path)
            self.status.config(text=f'Saved {path}')


# ── entry point ───────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description='Zeliard GRP viewer (loose files)')
    parser.add_argument('file', nargs='?',
                        default='c:/Projects/Zeliard/3_Assembly/tasm/bin/zelres1/131TTL3G.grp',
                        help='Path to .grp file (default: 131TTL3G.grp)')
    parser.add_argument('--cl', type=int, default=112,
                        help='Plane width in bytes (default: 112)')
    parser.add_argument('--zoom', type=int, default=2)
    args = parser.parse_args()

    root = tk.Tk()
    root.geometry('900x500')
    app = GrpViewer(root, args.file, args.cl)
    app._set_zoom(args.zoom)
    root.mainloop()


if __name__ == '__main__':
    main()
