"""
Zeliard MDT Viewer - Main application.
"""

import os
import tkinter as tk
from tkinter import filedialog, messagebox
from collections import Counter
from typing import Optional, Dict, Any, List

from .constants import PALETTE, TOWN_HEIGHT, _MONSTER_TYPE_NAMES, get_map_type_info, _ptr_off_safe
from .models import MdtData
from .decoder import decode_mdt_file, is_town_mdt
from .widgets import Tooltip, InfoBox, ScrollFrame


class MDTViewer(tk.Tk):
    """Main MDT Viewer application window."""

    # Color scheme (Catppuccin-inspired)
    C_BG0 = '#0a0a10'
    C_BG1 = '#11111b'
    C_BG2 = '#181825'
    C_BG3 = '#1e1e2e'
    C_PANEL = '#24243a'
    C_SURF = '#313244'
    C_FG = '#cdd6f4'
    C_DIM = '#6c7086'
    C_BLUE = '#89b4fa'
    C_GREEN = '#a6e3a1'
    C_RED = '#f38ba8'
    C_YELL = '#f9e2af'
    C_CYAN = '#89dceb'
    C_PINK = '#f5c2e7'

    BLK_MIN = 2
    BLK_MAX = 40
    BLK_DEF = 10

    def __init__(self):
        super().__init__()
        self.title('Zeliard MDT Viewer  v3.1')
        self.geometry('1400x880')
        self.minsize(980, 660)
        self.configure(bg=self.C_BG2)

        self.block_size = self.BLK_DEF
        self.mdt: Optional[MdtData] = None
        self.current_file: Optional[str] = None
        self.file_data: Optional[bytes] = None
        self.show_overlay = tk.BooleanVar(value=True)
        self.overlay_ids: List[int] = []
        self.hover_txt = tk.StringVar()
        self.tooltip: Optional[Tooltip] = None

        self._build_ui()

    # ── UI Construction ───────────────────────────────────────────────────────
    def _build_ui(self):
        """Build the complete UI."""
        self._build_toolbar()
        self._build_body()

    def _build_toolbar(self):
        """Build the top toolbar."""
        tb = tk.Frame(self, bg=self.C_BG0, height=46)
        tb.pack(fill='x')
        tb.pack_propagate(False)

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

        btn('Open', self.open_file).pack(side='left', padx=(8, 2), pady=6)
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
                 font=('Consolas', 8)).pack(side='left', padx=(2, 0))
        btn('-', self.zoom_out, fg=self.C_RED, px=8)
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
        """Build the main body with map canvas and info panel."""
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

        self.canvas.bind('<Motion>', self._on_motion)
        self.canvas.bind('<Leave>', self._on_leave)
        self.canvas.bind('<MouseWheel>', self._on_wheel)
        self.canvas.bind('<Button-4>', self._on_wheel)
        self.canvas.bind('<Button-5>', self._on_wheel)

        # NPC speech panel — hidden initially, shown for town maps
        self.npc_panel = tk.Frame(left, bg=self.C_BG0)
        npc_hdr = tk.Frame(self.npc_panel, bg=self.C_SURF)
        npc_hdr.pack(fill='x')
        tk.Label(npc_hdr, text='NPC DIALOGUE', bg=self.C_SURF, fg=self.C_BLUE,
                 font=('Consolas', 9, 'bold'), anchor='w', padx=6, pady=3
                 ).pack(side='left')
        self.npc_speech_lbl = tk.Label(
            npc_hdr, text='', bg=self.C_SURF, fg=self.C_DIM,
            font=('Consolas', 8), anchor='w', padx=6)
        self.npc_speech_lbl.pack(side='left')
        self.npc_speech_txt = tk.Text(
            self.npc_panel, bg=self.C_PANEL, fg=self.C_FG,
            font=('Consolas', 9), relief='flat', state='disabled',
            wrap='word', height=4, selectbackground=self.C_SURF,
            padx=8, pady=4)
        self.npc_speech_txt.pack(fill='x')

        # Status bar
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

    def _build_info_panel(self, parent: tk.Widget):
        """Build the right-side info panel with multiple info boxes."""
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

        # Configure text tags
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

    # ── File Operations ───────────────────────────────────────────────────────
    def open_file(self):
        """Open an MDT file via file dialog."""
        path = filedialog.askopenfilename(
            title='Open MDT File',
            filetypes=[('MDT map files', '*.mdt *.MDT'), ('All files', '*.*')])
        if not path:
            return
        try:
            self.file_data = open(path, 'rb').read()
            self.mdt = decode_mdt_file(path)
            self.current_file = path
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

            # Show NPC speech panel only for town maps
            if self.mdt.is_town:
                self.npc_panel.pack(fill='x', before=self.cf)
                self._set_npc_speech(None)
            else:
                self.npc_panel.pack_forget()

        except Exception as e:
            messagebox.showerror('Load Error', str(e))

    # ── Map Rendering ─────────────────────────────────────────────────────────
    def _draw_map(self):
        """Draw the tile grid on the canvas."""
        self.canvas.delete('all')
        self.overlay_ids = []
        if not self.mdt:
            return

        bs = self.block_size
        mw = self.mdt.map_width
        mh = self.mdt.map_height
        grid = self.mdt.grid
        W, H = mw * bs, mh * bs
        self.canvas.configure(scrollregion=(0, 0, W, H))

        ol = self.C_BG1 if bs >= 6 else ''
        ow = 1 if bs >= 6 else 0

        for r in range(mh):
            for c in range(mw):
                t = grid[r][c]
                x0 = c * bs
                y0 = r * bs
                self.canvas.create_rectangle(
                    x0, y0, x0 + bs, y0 + bs,
                    fill=PALETTE[t % 64], outline=ol, width=ow)

        # 16-tile alignment guides
        if bs >= 4:
            for c in range(0, mw + 1, 16):
                self.canvas.create_line(c * bs, 0, c * bs, H, fill='#ffffff', stipple='gray25', width=1)
            for r in range(0, mh + 1, 16):
                self.canvas.create_line(0, r * bs, W, r * bs, fill='#ffffff', stipple='gray25', width=1)

    def _draw_overlays(self):
        """Draw entity labels (D1, M1, I1, N1, etc.) on the map."""
        for iid in self.overlay_ids:
            self.canvas.delete(iid)
        self.overlay_ids = []
        if not self.mdt or not self.show_overlay.get():
            return

        bs = self.block_size
        fs = max(6, min(10, bs - 1))
        font = ('Consolas', fs, 'bold')
        pad = max(1, bs // 6)

        def place(x, y, text):
            cx = x * bs + bs // 2
            cy = y * bs + bs // 2
            tid = self.canvas.create_text(
                cx, cy, text=text, fill='#ffffff', font=font, anchor='center')
            bb = self.canvas.bbox(tid)
            if bb:
                rid = self.canvas.create_rectangle(
                    bb[0] - pad, bb[1] - pad, bb[2] + pad, bb[3] + pad,
                    fill='#000000', outline='#555555', width=1)
                self.canvas.tag_raise(tid)
                self.overlay_ids += [rid, tid]
            else:
                self.overlay_ids.append(tid)

        # Dungeon entities
        for d in self.mdt.doors:
            place(d.x, d.y, d.label)
        for m in self.mdt.monsters:
            place(m.x, m.y, m.label)
        for i in self.mdt.items:
            place(i.x, i.y, i.label)

        # Town entities: place at ground level (row 7)
        if self.mdt.is_town:
            ground_row = TOWN_HEIGHT - 1
            for td in self.mdt.town_doors:
                place(td.x, ground_row, td.label)
            for npc in self.mdt.npcs:
                place(npc.x, ground_row, npc.label)

    def _toggle_overlay(self):
        """Toggle overlay visibility."""
        self.show_overlay.set(not self.show_overlay.get())
        on = self.show_overlay.get()
        self.ov_btn.config(
            text=f'Overlay  {"ON " if on else "OFF"}',
            fg=self.C_YELL if on else self.C_DIM)
        self._draw_overlays()

    # ── NPC Speech ────────────────────────────────────────────────────────────
    def _set_npc_speech(self, npc):
        """Update the NPC speech panel."""
        txt = self.npc_speech_txt
        txt.config(state='normal')
        txt.delete('1.0', 'end')
        if npc is None:
            self.npc_speech_lbl.config(
                text='  hover over an NPC to read their dialogue', fg=self.C_DIM)
        else:
            npc_id = npc.npc_id
            texts = self.mdt.npc_texts if self.mdt else {}
            speech = texts.get(npc_id, '')
            self.npc_speech_lbl.config(
                text=f'  {npc.label}  (id={npc_id:#04x})', fg=self.C_YELL)
            if speech:
                txt.insert('end', speech)
            else:
                txt.insert('end', '(no dialogue found)')
        txt.config(state='disabled')

    # ── Info Panel Update ─────────────────────────────────────────────────────
    def _update_info(self):
        """Update all info boxes with current map data."""
        m = self.mdt
        d = self.file_data
        if not m or not d:
            return

        mw, mh = m.map_width, m.map_height
        total = mw * mh
        flat = [m.grid[r][c] for r in range(mh) for c in range(mw)]
        cnt = Counter(flat)
        fname = os.path.basename(self.current_file) if self.current_file else ''

        mtype = get_map_type_info(self.current_file) if self.current_file else 'Unknown'

        for txt in [self.info_txt1, self.info_txt2, self.info_txt3, self.info_txt4]:
            txt.config(state='normal')
            txt.delete('1.0', 'end')

        T = self.info_txt1

        def kv(key, val, vt='v'):
            T.insert('end', f'  {key:<18}', 'k')
            T.insert('end', f'{val}\n', vt)

        def sep():
            T.insert('end', '  ' + '-' * 34 + '\n', 's')

        def sec(title):
            T.insert('end', f'\n  [ {title} ]\n', 'sec')

        # Box 1: File Info, Map Structure, Compression / Map data
        sec('File Info')
        kv('Filename', fname)
        kv('File size', f'{len(d):,} bytes')
        kv('Map type', mtype)
        if m.is_town and m.town_name:
            kv('Town name', m.town_name, 'y')
        sep()

        sec('Map Structure')
        kv('Width', f'{mw} tiles')
        height_note = '(fixed — town)' if m.is_town else '(fixed)'
        kv('Height', f'{mh} tiles  {height_note}')
        kv('Total tiles', f'{total:,}')
        kv('Unique tiles', f'{len(cnt)} types')
        sep()

        if m.is_town:
            sec('Map Storage')
            kv('Format', 'Unpacked  (column-major)')
            kv('Map offset', '+0x17')
            kv('Map bytes', f'{mw * TOWN_HEIGHT}')
        else:
            cbytes = max(0, m.consumed_si - 0x1B)
            sec('Compression')
            kv('Packed bytes', f'{cbytes}')
            ratio = cbytes / total if total else 0
            kv('Bytes / tile', f'{ratio:.3f}')
            saving = (1 - ratio) * 100 if ratio < 1 else 0
            kv('Space saved', f'{saving:.1f}%', 'g' if saving > 50 else 'v')

        # Box 2: Header Pointers, Raw Header
        T = self.info_txt2

        def ptr_row(lbl, ptr):
            off = _ptr_off_safe(ptr, len(d))
            s = (f'{ptr:#06x}  ->  +{off:#06x}' if off is not None
                 else f'{ptr:#06x}  (invalid)')
            kv(lbl, s, 'c')

        if m.is_town:
            sec('Town Header Pointers  (runtime -> file offset)')
            kv('Width (raw)', f'{m.map_width}  tiles', 'y')
            ptr_row('Name info', m.name_ptr)
            ptr_row('Doors', m.doors_ptr)
            ptr_row('NPC texts', m.npc_texts_ptr)
            ptr_row('NPCs', m.npc_ptr)
            kv('Map data', '+0x17  (unpacked tiles)', 'c')
        else:
            sec('Header Pointers  (runtime -> file offset)')
            ptr_row('Descriptor', m.desc_ptr)
            ptr_row('V-Platforms', m.vplat_ptr)
            ptr_row('C-Platforms', m.cplat_ptr)
            ptr_row('H-Platforms', m.hplat_ptr)
            ptr_row('Doors', m.doors_ptr)
            ptr_row('Achv-Items', m.achv_ptr)
            ptr_row('Name renderer', m.name_ptr)
            ptr_row('Monsters', m.monsters_ptr)
            ptr_row('Signs', m.signs_ptr)
            ptr_row('Map end', m.map_end_ptr)
            kv('Level', str(m.level), 'y')
            kv('Tear X', f'{m.tear_x:#06x}  ({m.tear_x})', 'y')
            kv('Tear Y', f'{m.tear_y:#04x}  ({m.tear_y})', 'y')

        sep()
        sec('Raw Header  +0x00..+0x1A')
        for o in range(0, min(0x1B, len(d)), 4):
            chunk = d[o:o + 4]
            hexs = ' '.join(f'{b:02X}' for b in chunk)
            ascs = ''.join(chr(b) if 0x20 <= b < 0x7F else '.' for b in chunk)
            T.insert('end', f'  +{o:02X}  {hexs:<11}  {ascs}\n', 'd')

        # Box 3: Entities (differs between town and dungeon)
        T = self.info_txt3

        if m.is_town:
            town_doors = m.town_doors
            sec(f'Town Doors  ({len(town_doors)})')
            for td in town_doors:
                T.insert('end', f'  {td.label:<5}', 'p')
                T.insert('end', f'type={td.door_type:#04x}\n', 'y')
                T.insert('end', f'    Column X  {td.x}\n', 'd')
            if not town_doors:
                T.insert('end', '  (none found)\n', 'd')
            sep()

            npcs = m.npcs
            sec(f'NPCs  ({len(npcs)})')
            for npc in npcs:
                T.insert('end', f'  {npc.label:<5}', 'g')
                T.insert('end', f'id={npc.npc_id:#04x}  ({npc.npc_id})\n', 'v')
                T.insert('end', f'    Column X  {npc.x}\n', 'd')
            if not npcs:
                T.insert('end', '  (none found)\n', 'd')
        else:
            sec(f'Doors  ({len(m.doors)})')
            for dr in m.doors:
                icon = '[KEY]' if dr.needs_key else ('[TWN]' if dr.is_town else '[   ]')
                T.insert('end', f'  {dr.label:<5}', 'p')
                T.insert('end', f'{icon} {dr.dtype}\n', 'y')
                T.insert('end', f'    From  ({dr.x}, {dr.y})\n', 'd')
                dest_y = 'town' if dr.is_town else str(dr.y1)
                T.insert('end', f'    To    ({dr.x1}, {dest_y})\n', 'd')
                T.insert('end', f'    Dest  {dr.dest}\n', 'd')
                T.insert('end',
                         f'    flags {dr.flags:#04x}  '
                         f'f2={dr.flags2:#04x}  '
                         f'unk={dr.unk:#06x}\n', 'd')
            if not m.doors:
                T.insert('end', '  (none found)\n', 'd')
            sep()

            sec(f'Monsters  ({len(m.monsters)})')
            for mo in m.monsters:
                name = _MONSTER_TYPE_NAMES.get(mo.type, '')
                name_str = f'  ({name})' if name else ''
                T.insert('end', f'  {mo.label:<5}', 'r')
                T.insert('end', f'type={mo.type:#04x}  act={mo.act:#04x}{name_str}\n', 'v')
                T.insert('end',
                         f'    pos=({mo.x},{mo.y})'
                         f'  spawn=({mo.spwn_x},{mo.spwn_y})'
                         f'  stype={mo.spwn_type:#04x}\n', 'd')
            if not m.monsters:
                T.insert('end', '  (none found)\n', 'd')
            sep()

            sec(f'Items  ({len(m.items)})')
            for it in m.items:
                T.insert('end', f'  {it.label:<5}', 'g')
                T.insert('end', f'type={it.type:#04x}\n', 'v')
                T.insert('end',
                         f'    pos=({it.x},{it.y})'
                         f'  spawn=({it.spwn_x},{it.spwn_y})\n', 'd')
            if not m.items:
                T.insert('end', '  (none found)\n', 'd')

        # Box 4: Tile Frequency
        T = self.info_txt4
        sec('Tile Frequency  Top 15')
        for tile, count in cnt.most_common(15):
            pct = count / total * 100
            T.insert('end',
                     f'  #{tile:2d}  {count:6d}  {pct:5.1f}%  {PALETTE[tile % 64]}\n', 'd')

        for txt in [self.info_txt1, self.info_txt2, self.info_txt3, self.info_txt4]:
            txt.config(state='disabled')

    # ── Mouse Events ──────────────────────────────────────────────────────────
    def _on_motion(self, event):
        """Handle mouse motion over the canvas."""
        if not self.mdt:
            return
        bs = self.block_size
        cx = self.canvas.canvasx(event.x)
        cy = self.canvas.canvasy(event.y)
        col = int(cx // bs)
        row = int(cy // bs)
        mw, mh = self.mdt.map_width, self.mdt.map_height
        if 0 <= col < mw and 0 <= row < mh:
            tile = self.mdt.grid[row][col]
            self.hover_txt.set(
                f'  col:{col:4d}  row:{row:3d}  '
                f'tile:{tile:2d}   {PALETTE[tile % 64]}')
        else:
            self.hover_txt.set('')

        entity = self._hit_entity(cx, cy)
        if entity and self.tooltip:
            rx = self.winfo_pointerx()
            ry = self.winfo_pointery()
            self.tooltip.show(rx, ry, self._make_tip(entity))
        elif self.tooltip:
            self.tooltip.hide()

        # Update NPC speech panel when hovering an NPC on a town map
        if self.mdt and self.mdt.is_town:
            npc = entity if (entity and hasattr(entity, 'label') and entity.label.startswith('N')) else None
            self._set_npc_speech(npc)

    def _on_leave(self, event):
        """Handle mouse leaving the canvas."""
        self.hover_txt.set('')
        if self.tooltip:
            self.tooltip.hide()
        if self.mdt and self.mdt.is_town:
            self._set_npc_speech(None)

    def _on_wheel(self, event):
        """Handle mouse wheel for scrolling and zooming."""
        if event.state & 0x4:  # Ctrl held - zoom
            if event.delta > 0 or event.num == 4:
                self.zoom_in()
            else:
                self.zoom_out()
            return
        if event.num == 4:
            self.canvas.yview_scroll(-3, 'units')
        elif event.num == 5:
            self.canvas.yview_scroll(3, 'units')
        else:
            self.canvas.yview_scroll(-1 * (event.delta // 120), 'units')

    def _hit_entity(self, cx, cy):
        """Find entity at canvas coordinates."""
        if not self.mdt or not self.show_overlay.get():
            return None
        bs = self.block_size
        thresh = (max(bs, 8) * 0.9) ** 2
        best = None
        best_d = thresh
        is_town = self.mdt.is_town
        ground_row = TOWN_HEIGHT - 1 if is_town else 0

        all_entities = list(self.mdt.doors) + list(self.mdt.monsters) + list(self.mdt.items)
        if is_town:
            all_entities.extend(self.mdt.town_doors)
            all_entities.extend(self.mdt.npcs)

        for e in all_entities:
            ex = e.x * bs + bs // 2
            # Town entities have y=0 but labels drawn at ground level (row 7)
            ey = (ground_row if is_town else e.y) * bs + bs // 2
            d = (cx - ex) ** 2 + (cy - ey) ** 2
            if d < best_d:
                best_d = d
                best = e
        return best

    def _make_tip(self, e) -> str:
        """Generate tooltip text for an entity."""
        lbl = e.label
        line = '-' * 30
        tip = [f'  {lbl}', f'  {line}']

        if lbl.startswith('D'):
            if hasattr(e, 'door_type'):
                # Town door (3-byte format)
                tip += [
                    f'  Type      {e.dtype}',
                    f'  Column X  {e.x}',
                    f'  Door type {e.door_type:#04x}',
                ]
            else:
                # Dungeon/outdoor door (12-byte format)
                tip += [
                    f'  Type      {e.dtype}',
                    f'  From      ({e.x}, {e.y})',
                    f'  Dest map  {e.dest}',
                    f'  To        ({e.x1}, {"town" if e.is_town else e.y1})',
                    f'  Lion Key  {"required" if e.needs_key else "not required"}',
                    f'  flags     {e.flags:#04x}   flags2  {e.flags2:#04x}',
                    f'  map_id    {e.map_id:#04x}   unk  {e.unk:#06x}',
                ]
        elif lbl.startswith('N'):
            # Town NPC
            tip += [
                f'  NPC id    {e.npc_id:#04x}  ({e.npc_id})',
                f'  Column X  {e.x}',
            ]
        elif lbl.startswith('M'):
            name = _MONSTER_TYPE_NAMES.get(e.type, '')
            name_str = f' ({name})' if name else ''
            tip += [
                f'  Type      {e.type:#04x}{name_str}',
                f'  Position  ({e.x}, {e.y})',
                f'  Spawn     ({e.spwn_x}, {e.spwn_y})',
                f'  SType     {e.spwn_type:#04x}',
                f'  Act       {e.act:#04x}',
                f'  Raw:  {e.raw}',
            ]
        elif lbl.startswith('I'):
            tip += [
                f'  Type      {e.type:#04x}  ({e.type})',
                f'  Position  ({e.x}, {e.y})',
                f'  Spawn     ({e.spwn_x}, {e.spwn_y})',
                f'  Raw:  {e.raw}',
            ]
        else:
            tip.append('  Unknown entity')
        return '\n'.join(tip)

    # ── Zoom ──────────────────────────────────────────────────────────────────
    def zoom_in(self):
        """Zoom in the map view."""
        if self.block_size < self.BLK_MAX:
            self.block_size = min(self.block_size + 2, self.BLK_MAX)
            self.zoom_lbl.config(text=f'{self.block_size}px')
            if self.mdt:
                self._draw_map()
                self._draw_overlays()

    def zoom_out(self):
        """Zoom out the map view."""
        if self.block_size > self.BLK_MIN:
            self.block_size = max(self.block_size - 2, self.BLK_MIN)
            self.zoom_lbl.config(text=f'{self.block_size}px')
            if self.mdt:
                self._draw_map()
                self._draw_overlays()

    # ── Save Functions ────────────────────────────────────────────────────────
    def save_png(self):
        """Export map as PNG image."""
        if not self.mdt:
            messagebox.showwarning('Warning', 'Open a file first.')
            return
        try:
            from PIL import Image, ImageDraw
        except ImportError:
            messagebox.showerror('Pillow Required',
                                 'PNG export requires Pillow:\n\n  pip install Pillow')
            return

        init = os.path.splitext(os.path.basename(self.current_file))[0] + '.png'
        path = filedialog.asksaveasfilename(
            defaultextension='.png',
            filetypes=[('PNG image', '*.png')], initialfile=init)
        if not path:
            return
        try:
            bs = max(self.block_size, 4)
            mw, mh = self.mdt.map_width, self.mdt.map_height
            img = Image.new('RGB', (mw * bs, mh * bs), self.C_BG1)
            draw = ImageDraw.Draw(img)
            for r in range(mh):
                for c in range(mw):
                    t = self.mdt.grid[r][c]
                    x0, y0 = c * bs, r * bs
                    draw.rectangle([x0, y0, x0 + bs - 1, y0 + bs - 1], fill=PALETTE[t % 64])
            img.save(path)
            messagebox.showinfo('Saved', f'PNG saved:\n{path}')
        except Exception as e:
            messagebox.showerror('Save Error', str(e))

    def save_txt(self):
        """Export map as text file."""
        if not self.mdt:
            messagebox.showwarning('Warning', 'Open a file first.')
            return
        init = os.path.splitext(os.path.basename(self.current_file))[0] + '.txt'
        path = filedialog.asksaveasfilename(
            defaultextension='.txt',
            filetypes=[('Text file', '*.txt')], initialfile=init)
        if not path:
            return
        try:
            m = self.mdt
            with open(path, 'w', encoding='utf-8') as f:
                f.write(f'; Zeliard MDT:  {os.path.basename(self.current_file)}\n')
                f.write(f'; Width={m.map_width}  Height={m.map_height}\n')
                if m.is_town:
                    f.write(f'; Town name={m.town_name}  '
                            f'Doors={len(m.town_doors)}  '
                            f'NPCs={len(m.npcs)}\n;\n')
                else:
                    f.write(f'; Level={m.level}  Tear=({m.tear_x},{m.tear_y})\n')
                    f.write(f'; Doors={len(m.doors)}  '
                            f'Monsters={len(m.monsters)}  '
                            f'Items={len(m.items)}\n;\n')
                for row in m.grid:
                    f.write(''.join(chr(t + 0x20) for t in row) + '\n')
            messagebox.showinfo('Saved', f'TXT saved:\n{path}')
        except Exception as e:
            messagebox.showerror('Save Error', str(e))
