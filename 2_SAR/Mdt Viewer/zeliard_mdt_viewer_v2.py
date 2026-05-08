"""
Zeliard MDT Map Viewer  v2
──────────────────────────
Zeliard (Game Arts / Sierra On-Line, 1987)
Full MDT header parsing: map grid, doors, monsters, items.
Overlay labels D1/D2, M1/M2, I1/I2 — black bg, white text.
Hover tooltip shows entity details. All UI text in English.

MDT runtime memory layout (segment base = 0xC000):
  +0x00  descriptor ptr
  +0x02  map width (WORD)
  +0x04  vertical platforms ptr     (3 bytes/entry, stop=FFFF)
  +0x06  collapsing platforms ptr   (3 bytes/entry, stop=FFFF)
  +0x08  horizontal platforms ptr   (7 bytes/entry, stop=FFFF)
  +0x0A  doors ptr                  (12 bytes/entry, stop=FFFF)
  +0x0C  accomplished items ptr     (stop=FFFF)
  +0x0E  cavern name renderer ptr
  +0x10  monsters ptr               (16 bytes/entry, stop=FFFF)
  +0x12  cavern level (BYTE)
  +0x13  tear X  (WORD — door-to-boss X tile coordinate)
  +0x15  tear Y  (BYTE)
  +0x17  signs ptr
  +0x19  packed_map_end ptr
  +0x1B  packed map data  ← RLE tile grid starts here (column-major)

Door structure (12 bytes):
  [0-1] x0     WORD   source tile X
  [2]   y0     BYTE   source tile Y
  [3]   flags  BYTE   bit0=lion-key-required
  [4]   map_id BYTE   destination map index
  [5-6] x1     WORD   destination X
  [7-8] y1     WORD   destination Y  (0x00FF = town warp, no Y dimension)
  [9-10] unk   WORD
  [11]  flags2 BYTE

Monster/Item structure (16 bytes):
  [0-1]   currX     WORD
  [2]     currY     BYTE
  [3]     unk       BYTE   (usually 0xFF)
  [4]     type      BYTE   entity type code
  [5-10]  extra     6 bytes
  [11-12] spawnX    WORD
  [13]    spawnY    BYTE
  [14]    spawnType BYTE   0x00 = item,  else = monster type
  [15]    act       BYTE

Door map_id key:
  Non-town doors: 0-based index from MP10.MDT (STICK.BIN table offset 0x15)
  Town doors (y1==0xFF): separate town resource table
"""

import tkinter as tk
from tkinter import filedialog, messagebox
import struct, os
from collections import Counter

# ─── Constants ────────────────────────────────────────────────────────────────
SEG_BASE   = 0xC000   # MDT runtime segment base address
MAP_HEIGHT = 64       # All Zeliard dungeons are exactly 64 tiles tall

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

def _dung_name(mid):
    return _DUNG_MAPS[mid] if 0 <= mid < len(_DUNG_MAPS) else f'?[{mid:#04x}]'

def _town_name(mid):
    return _TOWN_MAPS.get(mid, f'?[{mid:#04x}]')

# ─── Monster type names (type field) ─────────────────────────────────────────
_MONSTER_TYPE_NAMES = {
    0x01: 'Snail/Slug',
    0x02: 'Frog',
}

# ─── Runtime pointer → file offset ───────────────────────────────────────────
def _ptr_off(ptr, file_size):
    if ptr == 0 or ptr == 0xFFFF:
        return None
    if ptr >= SEG_BASE:
        off = ptr - SEG_BASE
    else:
        off = ptr
    return off if off < file_size else None

# ─── MDT full decoder ─────────────────────────────────────────────────────────
def decode_mdt(data: bytes) -> dict:
    n = len(data)
    if n < 0x1D:
        raise ValueError(f'File too small: {n} bytes (need >= 29)')

    def word(o): return struct.unpack_from('<H', data, o)[0]
    def byte(o): return data[o] if o < n else 0

    mw = word(0x02)
    if not 1 <= mw <= 4096:
        raise ValueError(f'Invalid map width: {mw}')

    r = {
        'map_width':    mw,
        'map_height':   MAP_HEIGHT,
        'desc_ptr':     word(0x00),
        'vplat_ptr':    word(0x04),
        'cplat_ptr':    word(0x06),
        'hplat_ptr':    word(0x08),
        'doors_ptr':    word(0x0A),
        'achv_ptr':     word(0x0C),
        'name_ptr':     word(0x0E),
        'monsters_ptr': word(0x10),
        'level':        byte(0x12),
        'tear_x':       word(0x13) if n > 0x14 else 0,
        'tear_y':       byte(0x15),
        'signs_ptr':    word(0x17) if n > 0x18 else 0,
        'map_end_ptr':  word(0x19) if n > 0x1A else 0,
    }

    # Tile grid — column-major 2-bit opcode RLE
    si   = 0x1B
    grid = [[0] * mw for _ in range(MAP_HEIGHT)]
    for col in range(mw):
        row = 0; dl = 0; guard = 0
        while dl < 0x40:
            guard += 1
            if guard > 0xFFFF or si >= n: break
            b  = data[si]; op = (b >> 6) & 3
            if op == 0:                        # 00: long run
                rep = b + 1; si += 1
                if si >= n: break
                tile = data[si]
            elif op == 1:                      # 01: packed nibbles
                rep  = ((b >> 4) & 3) + 2
                tile = (b & 0x0F) + 1
            elif op == 2:                      # 10: empty run (tile 0)
                rep  = b & 0x3F; tile = 0
                if rep == 0: si += 1; continue
            else:                              # 11: single tile
                tile = b & 0x3F; rep = 1
            si += 1; dl += rep
            for _ in range(rep):
                if row < MAP_HEIGHT: grid[row][col] = tile; row += 1

    r['grid']        = grid
    r['consumed_si'] = si
    r['doors']       = _parse_doors(data, r['doors_ptr'], n)
    r['monsters'], r['items'] = _parse_monsters(data, r['monsters_ptr'], n)
    return r


def _parse_doors(data, doors_ptr, n):
    doors = []; file_size = len(data)
    off = _ptr_off(doors_ptr, file_size)
    if off is None: return doors
    idx = 1
    while off + 2 <= n:
        if data[off] == 0xFF and data[off+1] == 0xFF: break
        if off + 12 > n: break
        x0     = struct.unpack_from('<H', data, off)[0]
        y0     = data[off+2]
        flags  = data[off+3]
        map_id = data[off+4]
        x1     = struct.unpack_from('<H', data, off+5)[0]
        y1     = struct.unpack_from('<H', data, off+7)[0]
        unk    = struct.unpack_from('<H', data, off+9)[0]
        flags2 = data[off+11]
        is_town  = (y1 == 0x00FF)
        key_req  = bool(flags & 0x01)
        dest     = _town_name(map_id) if is_town else _dung_name(map_id)
        if is_town:   dtype = 'Town Warp'
        elif key_req: dtype = 'Locked Door  (Lion Key required)'
        else:         dtype = 'Regular Door'
        doors.append({
            'label': f'D{idx}', 'x': x0, 'y': y0,
            'flags': flags, 'map_id': map_id, 'x1': x1, 'y1': y1,
            'unk': unk, 'flags2': flags2,
            'is_town': is_town, 'needs_key': key_req,
            'dest': dest, 'dtype': dtype,
        })
        idx += 1; off += 12
    return doors


def _parse_monsters(data, monsters_ptr, n):
    mon = []; itm = []; file_size = len(data); mid = iid = 1
    off = _ptr_off(monsters_ptr, file_size)
    if off is None: return mon, itm
    while off + 2 <= n:
        if data[off] == 0xFF and data[off+1] == 0xFF: break
        if off + 16 > n: break
        cx     = struct.unpack_from('<H', data, off)[0]
        cy     = data[off+2]
        unk3   = data[off+3]
        ttype  = data[off+4]
        extra  = data[off+5:off+11]
        sx     = struct.unpack_from('<H', data, off+11)[0]
        sy     = data[off+13]
        stype  = data[off+14]
        act    = data[off+15]
        raw    = ' '.join(f'{b:02X}' for b in data[off:off+16])
        e = {'x': cx, 'y': cy, 'type': ttype, 'unk3': unk3,
             'spwn_x': sx, 'spwn_y': sy, 'spwn_type': stype, 'act': act, 'raw': raw}
        if stype == 0:   # spawn type 0 = item
            e['label'] = f'I{iid}'; itm.append(e); iid += 1
        else:            # spawn type != 0 = monster
            e['label'] = f'M{mid}'; mon.append(e); mid += 1
        off += 16
    return mon, itm

# ─── Tooltip window ───────────────────────────────────────────────────────────
class Tooltip:
    def __init__(self, root):
        self._root = root; self._win = None; self._lbl = None

    def show(self, rx, ry, text):
        if not self._win:
            self._win = tk.Toplevel(self._root)
            self._win.wm_overrideredirect(True)
            self._win.attributes('-topmost', True)
            self._lbl = tk.Label(
                self._win, justify='left',
                bg='#12121e', fg='#e0e0f0',
                font=('Consolas', 8),
                relief='solid', bd=1, padx=10, pady=7)
            self._lbl.pack()
        self._lbl.config(text=text)
        self._win.wm_geometry(f'+{rx+20}+{ry+20}')
        self._win.deiconify(); self._win.lift()

    def hide(self):
        if self._win: self._win.withdraw()


# ─── Info Box Widget ─────────────────────────────────────────────────────────
class InfoBox(tk.Frame):
    def __init__(self, parent, title, bg_header, fg_header, **kwargs):
        super().__init__(parent, bg=parent.cget('bg'), **kwargs)
        self._title = title
        self._bg_header = bg_header
        self._fg_header = fg_header
        self._build_box()
        self._txt = None
        self._tags_configured = False

    def _build_box(self):
        self._header = tk.Frame(self, bg=self._bg_header, relief='solid', bd=1)
        self._header.pack(fill='x')
        tk.Label(self._header, text=self._title, bg=self._bg_header, fg=self._fg_header,
                 font=('Consolas', 10, 'bold')).pack(side='left', padx=5, pady=3)
        self._content = tk.Frame(self, bg=self._bg_header)
        self._content.pack(fill='both', expand=True)

    def set_text_widget(self, txt):
        self._txt = txt
        self._txt.pack(in_=self._content, fill='both', expand=True)

    def config_tags(self, tags):
        if self._txt and not self._tags_configured:
            for tag, color in tags:
                self._txt.tag_config(tag, foreground=color)
            self._tags_configured = True

    def hide(self):
        if self._win: self._win.withdraw()


# ─── Scrollable Frame ────────────────────────────────────────────────────────
class ScrollFrame(tk.Frame):
    def __init__(self, parent, *args, **kwargs):
        tk.Frame.__init__(self, parent, *args, **kwargs)
        self.canvas = tk.Canvas(self, bg=self.cget('bg'), highlightthickness=0)
        self.scrollbar = tk.Scrollbar(self, orient='vertical', command=self.canvas.yview,
                                      bg=self.master.cget('bg'))
        self.canvas.configure(yscrollcommand=self.scrollbar.set)
        self.scrollbar.pack(side='right', fill='y')
        self.canvas.pack(side='left', fill='both', expand=True)
        self.interior = tk.Frame(self.canvas, bg=self.cget('bg'))
        self.canvas_window = self.canvas.create_window((0, 0), window=self.interior, anchor='nw')
        self.interior.bind('<Configure>', self._on_configure)
        self.canvas.bind('<Configure>', self._on_canvas_configure)

    def _on_configure(self, event=None):
        self.canvas.configure(scrollregion=self.canvas.bbox('all'))

    def _on_canvas_configure(self, event):
        self.canvas.itemconfig(self.canvas_window, width=event.width)


# ─── Application ─────────────────────────────────────────────────────────────
class MDTViewer(tk.Tk):
    C_BG0  = '#0a0a10'; C_BG1 = '#11111b'; C_BG2 = '#181825'; C_BG3 = '#1e1e2e'
    C_PANEL= '#24243a'; C_SURF = '#313244'
    C_FG   = '#cdd6f4'; C_DIM  = '#6c7086'
    C_BLUE = '#89b4fa'; C_GREEN= '#a6e3a1'; C_RED  = '#f38ba8'
    C_YELL = '#f9e2af'; C_CYAN = '#89dceb'; C_PINK = '#f5c2e7'

    BLK_MIN = 2; BLK_MAX = 40; BLK_DEF = 10

    def __init__(self):
        super().__init__()
        self.title('Zeliard MDT Viewer  v2')
        self.geometry('1400x880')
        self.minsize(980, 660)
        self.configure(bg=self.C_BG2)
        self.block_size   = self.BLK_DEF
        self.mdt          = None
        self.current_file = None
        self.file_data    = None
        self.show_overlay = tk.BooleanVar(value=True)
        self.overlay_ids  = []
        self.hover_txt    = tk.StringVar()
        self.tooltip      = None
        self._build_ui()

    # ── UI ────────────────────────────────────────────────────────────────────
    def _build_ui(self):
        self._build_toolbar()
        self._build_body()

    def _build_toolbar(self):
        tb = tk.Frame(self, bg=self.C_BG0, height=46)
        tb.pack(fill='x'); tb.pack_propagate(False)

        def btn(text, cmd, fg=None, px=10):
            b = tk.Button(
                tb, text=text, command=cmd,
                bg=self.C_SURF, fg=fg or self.C_FG,
                activebackground='#45475a', activeforeground=self.C_FG,
                relief='flat', bd=0, cursor='hand2',
                font=('Consolas', 9), padx=px, pady=7)
            b.pack(side='left', padx=2, pady=6)
            return b

        def sep():
            tk.Frame(tb, bg=self.C_SURF, width=1).pack(
                side='left', fill='y', pady=8, padx=5)

        btn('Open', self.open_file).pack(side='left', padx=(8,2), pady=6)
        sep()
        btn('Save PNG', self.save_png, fg=self.C_GREEN)
        btn('Save TXT', self.save_txt, fg=self.C_BLUE)
        sep()

        self.ov_btn = tk.Button(
            tb, text='Overlay  ON', command=self._toggle_overlay,
            bg='#2a2a45', fg=self.C_YELL,
            activebackground='#45475a', activeforeground=self.C_FG,
            relief='flat', bd=0, cursor='hand2',
            font=('Consolas', 9), padx=10, pady=7)
        self.ov_btn.pack(side='left', padx=2, pady=6)
        sep()

        tk.Label(tb, text='Zoom', bg=self.C_BG0, fg=self.C_DIM,
                 font=('Consolas', 8)).pack(side='left', padx=(2,0))
        btn('-', self.zoom_out, fg=self.C_RED,   px=8)
        self.zoom_lbl = tk.Label(
            tb, text=f'{self.block_size}px',
            bg=self.C_BG0, fg=self.C_FG,
            font=('Consolas', 9), width=5)
        self.zoom_lbl.pack(side='left')
        btn('+', self.zoom_in, fg=self.C_GREEN, px=8)
        sep()

        self.file_lbl = tk.Label(
            tb, text='',
            bg=self.C_BG0, fg=self.C_DIM, font=('Consolas', 9))
        self.file_lbl.pack(side='left', padx=8)

    def _build_body(self):
        pane = tk.PanedWindow(self, orient='horizontal',
                              bg=self.C_BG2, sashwidth=5, sashrelief='flat')
        pane.pack(fill='both', expand=True)

        # Left: map canvas
        left = tk.Frame(pane, bg=self.C_BG2)
        pane.add(left, minsize=650, stretch='always')

        self.hint = tk.Label(
            left,
            text='Open an MDT file\n\n'
                 'Level maps:  MP10.MDT  through  MPA0.MDT\n'
                 'Resources:   CMAP / STMP / BSMP / MRMP / ...',
            bg=self.C_BG1, fg=self.C_DIM,
            font=('Consolas', 12), justify='center')
        self.hint.pack(fill='both', expand=True)

        self.cf = tk.Frame(left, bg=self.C_BG1)
        self.canvas = tk.Canvas(self.cf, bg=self.C_BG1,
                                highlightthickness=0, cursor='crosshair')
        vsb = tk.Scrollbar(self.cf, orient='vertical',
                           command=self.canvas.yview,
                           bg=self.C_SURF, troughcolor=self.C_BG2, width=10)
        hsb = tk.Scrollbar(self.cf, orient='horizontal',
                           command=self.canvas.xview,
                           bg=self.C_SURF, troughcolor=self.C_BG2, width=10)
        self.canvas.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        vsb.pack(side='right', fill='y')
        hsb.pack(side='bottom', fill='x')
        self.canvas.pack(fill='both', expand=True)

        self.canvas.bind('<Motion>',     self._on_motion)
        self.canvas.bind('<Leave>',      self._on_leave)
        self.canvas.bind('<MouseWheel>', self._on_wheel)
        self.canvas.bind('<Button-4>',   self._on_wheel)
        self.canvas.bind('<Button-5>',   self._on_wheel)

        status_frame = tk.Frame(left, bg=self.C_BG0)
        status_frame.pack(fill='x', side='bottom')

        self.file_lbl_status = tk.Label(
            status_frame,
            text='No file',
            bg=self.C_BG0, fg=self.C_YELL,
            font=('Consolas', 8), anchor='w', padx=10, pady=3)
        self.file_lbl_status.pack(side='left')

        sep_frame = tk.Frame(status_frame, bg=self.C_SURF, width=1)
        sep_frame.pack(side='left', fill='y', pady=2)

        self.status = tk.Label(
            status_frame, textvariable=self.hover_txt,
            bg=self.C_BG0, fg=self.C_DIM,
            font=('Consolas', 8), anchor='w', padx=10, pady=3)
        self.status.pack(side='left', fill='x', expand=True)

        # Right: info panel
        right = tk.Frame(pane, bg=self.C_BG3)
        pane.add(right, minsize=315, stretch='never')
        self._build_info_panel(right)

    def _build_info_panel(self, parent):
        hdr = tk.Frame(parent, bg=self.C_SURF, pady=4)
        hdr.pack(fill='x')

        scroll_frame = ScrollFrame(parent, bg=self.C_BG3)
        scroll_frame.pack(fill='both', expand=True)

        self.info_box1 = InfoBox(scroll_frame.interior, 'MAP INFORMATION', self.C_SURF, self.C_BLUE)
        self.info_box1.pack(fill='x', padx=5, pady=3)

        self.info_box2 = InfoBox(scroll_frame.interior, 'HEADER INFORMATION', self.C_SURF, self.C_BLUE)
        self.info_box2.pack(fill='x', padx=5, pady=3)

        self.info_box3 = InfoBox(scroll_frame.interior, 'OVERLAY INFORMATION', self.C_SURF, self.C_BLUE)
        self.info_box3.pack(fill='x', padx=5, pady=3)
        inner = tk.Frame(self.info_box3._content, bg=self.C_BG0)
        inner.pack(fill='x', padx=5, pady=3)
        tk.Label(inner, text='D = Door', bg=self.C_BG0, fg='#d8accf',
                 font=('Consolas', 8, 'bold')).pack(side='left')
        tk.Label(inner, text='    M = Monster', bg=self.C_BG0, fg='#DF819d',
                 font=('Consolas', 8, 'bold')).pack(side='left')
        tk.Label(inner, text='    I = Item', bg=self.C_BG0, fg='#6bc08c',
                 font=('Consolas', 8, 'bold')).pack(side='left')

        self.info_box4 = InfoBox(scroll_frame.interior, 'TILE INFORMATION', self.C_SURF, self.C_BLUE)
        self.info_box4.pack(fill='x', padx=5, pady=3)

        self.info_txt1 = tk.Text(self.info_box1._content, bg=self.C_PANEL, fg=self.C_FG,
                                font=('Consolas', 8), relief='flat', state='disabled',
                                width=40, wrap='none', selectbackground=self.C_SURF, height=5)
        self.info_box1.set_text_widget(self.info_txt1)

        self.info_txt2 = tk.Text(self.info_box2._content, bg=self.C_PANEL, fg=self.C_FG,
                                font=('Consolas', 8), relief='flat', state='disabled',
                                width=40, wrap='none', selectbackground=self.C_SURF, height=5)
        self.info_box2.set_text_widget(self.info_txt2)

        self.info_txt3 = tk.Text(self.info_box3._content, bg=self.C_PANEL, fg=self.C_FG,
                                font=('Consolas', 8), relief='flat', state='disabled',
                                width=40, wrap='none', selectbackground=self.C_SURF, height=10)
        self.info_box3.set_text_widget(self.info_txt3)

        self.info_txt4 = tk.Text(self.info_box4._content, bg=self.C_PANEL, fg=self.C_FG,
                                font=('Consolas', 8), relief='flat', state='disabled',
                                width=40, wrap='none', selectbackground=self.C_SURF, height=5)
        self.info_box4.set_text_widget(self.info_txt4)

        tags = [
            ('k', self.C_BLUE), ('v', self.C_FG), ('d', self.C_DIM),
            ('g', self.C_GREEN), ('r', self.C_RED), ('y', self.C_YELL),
            ('c', self.C_CYAN), ('p', self.C_PINK), ('s', self.C_SURF),
        ]
        for txt in [self.info_txt1, self.info_txt2, self.info_txt3, self.info_txt4]:
            for tag, color in tags:
                txt.tag_config(tag, foreground=color)
            txt.tag_config('sec', foreground=self.C_FG, background=self.C_SURF)
            txt.tag_config('leg_d', foreground='#ffffff', background=self.C_BG0)
            txt.tag_config('leg_m', foreground='#ffffff', background=self.C_BG0)
            txt.tag_config('leg_i', foreground='#ffffff', background=self.C_BG0)

    # ── Open ──────────────────────────────────────────────────────────────────
    def open_file(self):
        path = filedialog.askopenfilename(
            title='Open MDT File',
            filetypes=[('MDT map files', '*.mdt *.MDT'), ('All files', '*.*')])
        if not path: return
        try:
            with open(path, 'rb') as f:
                data = f.read()
            mdt = decode_mdt(data)
            self.current_file = path
            self.file_data    = data
            self.mdt          = mdt
            fname = os.path.basename(path)
            self.title(f'Zeliard MDT Viewer  —  {fname}')
            self.file_lbl.config(text=fname, fg=self.C_FG)
            self.file_lbl_status.config(text=fname)
            self.hint.pack_forget()
            self.cf.pack(fill='both', expand=True)
            if self.tooltip is None:
                self.tooltip = Tooltip(self)
            self._draw_map()
            self._draw_overlays()
            self._update_info()
        except Exception as e:
            messagebox.showerror('Load Error', str(e))

    # ── Map rendering ─────────────────────────────────────────────────────────
    def _draw_map(self):
        self.canvas.delete('all')
        self.overlay_ids = []
        if not self.mdt: return
        bs   = self.block_size
        mw   = self.mdt['map_width']
        mh   = self.mdt['map_height']
        grid = self.mdt['grid']
        W, H = mw*bs, mh*bs
        self.canvas.configure(scrollregion=(0, 0, W, H))

        ol = self.C_BG1 if bs >= 6 else ''
        ow = 1 if bs >= 6 else 0

        for r in range(mh):
            for c in range(mw):
                t  = grid[r][c]
                x0 = c*bs; y0 = r*bs
                self.canvas.create_rectangle(
                    x0, y0, x0+bs, y0+bs,
                    fill=PALETTE[t % 64], outline=ol, width=ow)

        # 16-tile alignment guides
        if bs >= 4:
            for c in range(0, mw+1, 16):
                self.canvas.create_line(c*bs, 0, c*bs, H, fill='#ffffff', stipple='gray25', width=1)
            for r in range(0, mh+1, 16):
                self.canvas.create_line(0, r*bs, W, r*bs, fill='#ffffff', stipple='gray25', width=1)

    # ── Overlay labels — black bg, white text ─────────────────────────────────
    def _draw_overlays(self):
        for iid in self.overlay_ids:
            self.canvas.delete(iid)
        self.overlay_ids = []
        if not self.mdt or not self.show_overlay.get(): return

        bs   = self.block_size
        fs   = max(6, min(10, bs - 1))
        font = ('Consolas', fs, 'bold')
        pad  = max(1, bs // 6)

        def place(x, y, text):
            cx = x * bs + bs // 2
            cy = y * bs + bs // 2
            tid = self.canvas.create_text(
                cx, cy, text=text, fill='#ffffff', font=font, anchor='center')
            bb = self.canvas.bbox(tid)
            if bb:
                rid = self.canvas.create_rectangle(
                    bb[0]-pad, bb[1]-pad, bb[2]+pad, bb[3]+pad,
                    fill='#000000', outline='#555555', width=1)
                self.canvas.tag_raise(tid)
                self.overlay_ids += [rid, tid]
            else:
                self.overlay_ids.append(tid)

        for d in self.mdt['doors']:
            place(d['x'], d['y'], d['label'])
        for m in self.mdt['monsters']:
            place(m['x'], m['y'], m['label'])
        for i in self.mdt['items']:
            place(i['x'], i['y'], i['label'])

    def _toggle_overlay(self):
        self.show_overlay.set(not self.show_overlay.get())
        on = self.show_overlay.get()
        self.ov_btn.config(
            text=f'Overlay  {"ON " if on else "OFF"}',
            fg=self.C_YELL if on else self.C_DIM)
        self._draw_overlays()

    # ── Info panel ────────────────────────────────────────────────────────────
    def _update_info(self):
        m = self.mdt; d = self.file_data
        if not m or not d: return

        mw, mh = m['map_width'], m['map_height']
        total  = mw * mh
        flat   = [m['grid'][r][c] for r in range(mh) for c in range(mw)]
        cnt    = Counter(flat)
        cbytes = max(0, m['consumed_si'] - 0x1B)
        fname  = os.path.basename(self.current_file)
        fn     = fname.upper().replace('.MDT', '')

        if fn.startswith('MP') and len(fn) >= 3:
            rest  = fn[2:]
            mtype = (f'Dungeon (world {rest[:-1]})' if rest.endswith('D')
                     else f'Outdoor map (world {rest})')
        else:
            mtype = {
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

        for txt in [self.info_txt1, self.info_txt2, self.info_txt3, self.info_txt4]:
            txt.config(state='normal'); txt.delete('1.0', 'end')

        T = self.info_txt1

        def kv(key, val, vt='v'):
            T.insert('end', f'  {key:<18}', 'k')
            T.insert('end', f'{val}\n', vt)

        def sep():
            T.insert('end', '  ' + '-'*34 + '\n', 's')

        def sec(title):
            T.insert('end', f'\n  [ {title} ]\n', 'sec')

        # Box 1: File Info, Map Structure, Compression
        sec('File Info')
        kv('Filename',    fname)
        kv('File size',   f'{len(d):,} bytes')
        kv('Map type',    mtype)
        sep()

        sec('Map Structure')
        kv('Width',       f'{mw} tiles')
        kv('Height',      f'{mh} tiles  (fixed)')
        kv('Total tiles', f'{total:,}')
        kv('Unique tiles',f'{len(cnt)} types')
        sep()

        sec('Compression')
        kv('Packed bytes', f'{cbytes}')
        ratio  = cbytes / total if total else 0
        kv('Bytes / tile', f'{ratio:.3f}')
        saving = (1 - ratio)*100 if ratio < 1 else 0
        kv('Space saved',  f'{saving:.1f}%', 'g' if saving > 50 else 'v')

        # Box 2: Header Pointers, Raw Header
        T = self.info_txt2

        sec('Header Pointers  (runtime -> file offset)')
        def ptr_row(lbl, ptr):
            off = _ptr_off(ptr, len(d))
            s   = (f'{ptr:#06x}  ->  +{off:#06x}' if off is not None
                   else f'{ptr:#06x}  (invalid)')
            kv(lbl, s, 'c')

        ptr_row('Descriptor',     m['desc_ptr'])
        ptr_row('V-Platforms',    m['vplat_ptr'])
        ptr_row('C-Platforms',    m['cplat_ptr'])
        ptr_row('H-Platforms',    m['hplat_ptr'])
        ptr_row('Doors',          m['doors_ptr'])
        ptr_row('Achv-Items',     m['achv_ptr'])
        ptr_row('Name renderer',  m['name_ptr'])
        ptr_row('Monsters',       m['monsters_ptr'])
        ptr_row('Signs',          m['signs_ptr'])
        ptr_row('Map end',        m['map_end_ptr'])
        kv('Level',   str(m['level']), 'y')
        kv('Tear X',  f'{m["tear_x"]:#06x}  ({m["tear_x"]})', 'y')
        kv('Tear Y',  f'{m["tear_y"]:#04x}  ({m["tear_y"]})', 'y')
        sep()

        sec('Raw Header  +0x00..+0x1A')
        for o in range(0, min(0x1B, len(d)), 4):
            chunk = d[o:o+4]
            hexs  = ' '.join(f'{b:02X}' for b in chunk)
            ascs  = ''.join(chr(b) if 0x20 <= b < 0x7F else '.' for b in chunk)
            T.insert('end', f'  +{o:02X}  {hexs:<11}  {ascs}\n', 'd')

        # Box 3: Doors, Monsters, Items
        T = self.info_txt3

        sec(f'Doors  ({len(m["doors"])})')
        for dr in m['doors']:
            icon = '[KEY]' if dr['needs_key'] else ('[TWN]' if dr['is_town'] else '[   ]')
            T.insert('end', f'  {dr["label"]:<5}', 'p')
            T.insert('end', f'{icon} {dr["dtype"]}\n', 'y')
            T.insert('end', f'    From  ({dr["x"]}, {dr["y"]})\n', 'd')
            dest_y = 'town' if dr['is_town'] else str(dr['y1'])
            T.insert('end', f'    To    ({dr["x1"]}, {dest_y})\n', 'd')
            T.insert('end', f'    Dest  {dr["dest"]}\n', 'd')
            T.insert('end',
                f'    flags {dr["flags"]:#04x}  '
                f'f2={dr["flags2"]:#04x}  '
                f'unk={dr["unk"]:#06x}\n', 'd')
        if not m['doors']:
            T.insert('end', '  (none found)\n', 'd')
        sep()

        sec(f'Monsters  ({len(m["monsters"])})')
        for mo in m['monsters']:
            name = _MONSTER_TYPE_NAMES.get(mo['type'], '')
            name_str = f'  ({name})' if name else ''
            T.insert('end', f'  {mo["label"]:<5}', 'r')
            T.insert('end', f'type={mo["type"]:#04x}  act={mo["act"]:#04x}{name_str}\n', 'v')
            T.insert('end',
                f'    pos=({mo["x"]},{mo["y"]})'
                f'  spawn=({mo["spwn_x"]},{mo["spwn_y"]})'
                f'  stype={mo["spwn_type"]:#04x}\n', 'd')
        if not m['monsters']:
            T.insert('end', '  (none found)\n', 'd')
        sep()

        sec(f'Items  ({len(m["items"])})')
        for it in m['items']:
            T.insert('end', f'  {it["label"]:<5}', 'g')
            T.insert('end', f'type={it["type"]:#04x}\n', 'v')
            T.insert('end',
                f'    pos=({it["x"]},{it["y"]})'
                f'  spawn=({it["spwn_x"]},{it["spwn_y"]})\n', 'd')
        if not m['items']:
            T.insert('end', '  (none found)\n', 'd')

        # Box 4: Tile Frequency
        T = self.info_txt4
        sec('Tile Frequency  Top 15')
        for tile, count in cnt.most_common(15):
            pct = count / total * 100
            T.insert('end',
                f'  #{tile:2d}  {count:6d}  {pct:5.1f}%  {PALETTE[tile%64]}\n', 'd')

        for txt in [self.info_txt1, self.info_txt2, self.info_txt3, self.info_txt4]:
            txt.config(state='disabled')

    # ── Mouse ─────────────────────────────────────────────────────────────────
    def _on_motion(self, event):
        if not self.mdt: return
        bs  = self.block_size
        cx  = self.canvas.canvasx(event.x)
        cy  = self.canvas.canvasy(event.y)
        col = int(cx // bs); row = int(cy // bs)
        mw, mh = self.mdt['map_width'], self.mdt['map_height']
        if 0 <= col < mw and 0 <= row < mh:
            tile = self.mdt['grid'][row][col]
            self.hover_txt.set(
                f'  col:{col:4d}  row:{row:3d}  '
                f'tile:{tile:2d}   {PALETTE[tile%64]}')
        else:
            self.hover_txt.set('')

        entity = self._hit_entity(cx, cy)
        if entity and self.tooltip:
            rx = self.winfo_pointerx(); ry = self.winfo_pointery()
            self.tooltip.show(rx, ry, self._make_tip(entity))
        elif self.tooltip:
            self.tooltip.hide()

    def _on_leave(self, event):
        self.hover_txt.set('')
        if self.tooltip: self.tooltip.hide()

    def _on_wheel(self, event):
        if event.state & 0x4:
            if event.delta > 0 or event.num == 4: self.zoom_in()
            else:                                  self.zoom_out()
            return
        if event.num == 4:   self.canvas.yview_scroll(-3, 'units')
        elif event.num == 5: self.canvas.yview_scroll(3, 'units')
        else: self.canvas.yview_scroll(-1*(event.delta//120), 'units')

    def _hit_entity(self, cx, cy):
        if not self.mdt or not self.show_overlay.get(): return None
        bs     = self.block_size
        thresh = (max(bs, 8) * 0.9) ** 2
        best   = None; best_d = thresh
        for e in self.mdt['doors'] + self.mdt['monsters'] + self.mdt['items']:
            ex = e['x']*bs + bs//2
            ey = e['y']*bs + bs//2
            d  = (cx-ex)**2 + (cy-ey)**2
            if d < best_d: best_d = d; best = e
        return best

    def _make_tip(self, e):
        lbl  = e['label']
        line = '-' * 30
        tip  = [f'  {lbl}', f'  {line}']
        if lbl.startswith('D'):
            tip += [
                f'  Type      {e["dtype"]}',
                f'  From      ({e["x"]}, {e["y"]})',
                f'  Dest map  {e["dest"]}',
                f'  To        ({e["x1"]}, {"town" if e["is_town"] else e["y1"]})',
                f'  Lion Key  {"required" if e["needs_key"] else "not required"}',
                f'  flags     {e["flags"]:#04x}   flags2  {e["flags2"]:#04x}',
                f'  map_id    {e["map_id"]:#04x}   unk  {e["unk"]:#06x}',
            ]
        elif lbl.startswith('M'):
            name = _MONSTER_TYPE_NAMES.get(e['type'], '')
            name_str = f' ({name})' if name else ''
            tip += [
                f'  Type      {e["type"]:#04x}{name_str}',
                f'  Position  ({e["x"]}, {e["y"]})',
                f'  Spawn     ({e["spwn_x"]}, {e["spwn_y"]})',
                f'  SType     {e["spwn_type"]:#04x}',
                f'  Act       {e["act"]:#04x}',
                f'  Raw:  {e["raw"]}',
            ]
        elif lbl.startswith('I'):
            tip += [
                f'  Type      {e["type"]:#04x}  ({e["type"]})',
                f'  Position  ({e["x"]}, {e["y"]})',
                f'  Spawn     ({e["spwn_x"]}, {e["spwn_y"]})',
                f'  Raw:  {e["raw"]}',
            ]
        else:
            tip.append('  Unknown entity')
        return '\n'.join(tip)

    # ── Zoom ──────────────────────────────────────────────────────────────────
    def zoom_in(self):
        if self.block_size < self.BLK_MAX:
            self.block_size = min(self.block_size + 2, self.BLK_MAX)
            self.zoom_lbl.config(text=f'{self.block_size}px')
            if self.mdt: self._draw_map(); self._draw_overlays()

    def zoom_out(self):
        if self.block_size > self.BLK_MIN:
            self.block_size = max(self.block_size - 2, self.BLK_MIN)
            self.zoom_lbl.config(text=f'{self.block_size}px')
            if self.mdt: self._draw_map(); self._draw_overlays()

    # ── Save ──────────────────────────────────────────────────────────────────
    def save_png(self):
        if not self.mdt:
            messagebox.showwarning('Warning', 'Open a file first.'); return
        try:
            from PIL import Image, ImageDraw
        except ImportError:
            messagebox.showerror('Pillow Required',
                'PNG export requires Pillow:\n\n  pip install Pillow'); return
        init = os.path.splitext(os.path.basename(self.current_file))[0] + '.png'
        path = filedialog.asksaveasfilename(
            defaultextension='.png',
            filetypes=[('PNG image', '*.png')], initialfile=init)
        if not path: return
        try:
            bs = max(self.block_size, 4)
            mw, mh = self.mdt['map_width'], self.mdt['map_height']
            img  = Image.new('RGB', (mw*bs, mh*bs), self.C_BG1)
            draw = ImageDraw.Draw(img)
            for r in range(mh):
                for c in range(mw):
                    t = self.mdt['grid'][r][c]
                    x0, y0 = c*bs, r*bs
                    draw.rectangle([x0, y0, x0+bs-1, y0+bs-1], fill=PALETTE[t%64])
            img.save(path)
            messagebox.showinfo('Saved', f'PNG saved:\n{path}')
        except Exception as e:
            messagebox.showerror('Save Error', str(e))

    def save_txt(self):
        if not self.mdt:
            messagebox.showwarning('Warning', 'Open a file first.'); return
        init = os.path.splitext(os.path.basename(self.current_file))[0] + '.txt'
        path = filedialog.asksaveasfilename(
            defaultextension='.txt',
            filetypes=[('Text file', '*.txt')], initialfile=init)
        if not path: return
        try:
            m = self.mdt
            with open(path, 'w', encoding='utf-8') as f:
                f.write(f'; Zeliard MDT:  {os.path.basename(self.current_file)}\n')
                f.write(f'; Width={m["map_width"]}  Height={m["map_height"]}\n')
                f.write(f'; Level={m["level"]}  Tear=({m["tear_x"]},{m["tear_y"]})\n')
                f.write(f'; Doors={len(m["doors"])}  '
                        f'Monsters={len(m["monsters"])}  '
                        f'Items={len(m["items"])}\n;\n')
                for row in m['grid']:
                    f.write(''.join(chr(t + 0x20) for t in row) + '\n')
            messagebox.showinfo('Saved', f'TXT saved:\n{path}')
        except Exception as e:
            messagebox.showerror('Save Error', str(e))


# ─── Entry ────────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    MDTViewer().mainloop()
