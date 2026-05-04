#!/usr/bin/env python3
"""
save_editor_gui.py — Tkinter GUI for the Zeliard .USR save editor.

A graphical wrapper over save_edit.py.  Open a save file, manipulate any
named field, then write back to the same file or a new one.  Bytes
outside the named fields are preserved verbatim.

Usage:
  python save_editor_gui.py
  python save_editor_gui.py bin/Bosque.usr   # open at startup
"""
import sys
import os
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from pathlib import Path

# Reuse the field map and codec from save_edit.py
import save_edit


# ---------------------------------------------------------------------------
# Enumerated value choices — render as comboboxes instead of raw text entries.
# Sources: playthrough.txt §5.2.1 (swords/shields), §5.3.1 (items),
#          §6.1 (spells), §2.1 (towns).
# ---------------------------------------------------------------------------

ENUMS: dict[str, list[tuple[int, str]]] = {
    'equipped_weapon': [
        (0, 'none / fist'),
        (1, "Training Sword (starter)"),
        (2, "Wise Man's Sword"),
        (3, 'Spirit Sword'),
        (4, "Knight's Sword"),
        (5, 'Illumination Sword'),
        (6, 'Enchantment Sword'),
        (7, 'Sword of the Fairy Flame (secret)'),
    ],
    'cur_weapon_idx': [
        (0, 'none / fist'),
        (1, 'Training'),
        (2, "Wise Man's"),
        (3, 'Spirit'),
        (4, "Knight's"),
        (5, 'Illumination'),
        (6, 'Enchantment'),
        (7, 'Fairy Flame (secret)'),
    ],
    'shield_type': [
        (0, 'none'),
        (1, 'Clay Shield'),
        (2, "Wise Man's Shield"),
        (3, 'Stone Shield'),
        (4, 'Honor Shield'),
        (5, 'Light Shield'),
        (6, 'Titanium Shield'),
    ],
    'current_area_id': [
        (0x00, 'in cavern (high bit clear)'),
        (0x80, 'sentinel (init value)'),
        (0x81, '1 — Muralla Town'),
        (0x82, '2 — Satono Town'),
        (0x83, '3 — Bosque Village'),
        (0x84, '4 — Helada Town'),
        (0x85, '5 — Tumba Town'),
        (0x86, '6 — Dorado Town'),
        (0x87, '7 — Llama Town'),
        (0x88, '8 — Pureza Town'),
        (0x89, '9 — Esco Village (secret)'),
    ],
    'cur_magic_idx': [
        (0, 'none'),
        (1, 'spell 1'),
        (2, 'spell 2'),
        (3, 'spell 3'),
        (4, 'spell 4'),
        (5, 'spell 5'),
        (6, 'spell 6'),
        (7, 'spell 7'),
    ],
    'player_tileset': [
        (0, '0 — town'),
        (1, '1 — generic dungeon'),
        (2, '2 — forest'),
        (3, '3 — other'),
    ],
}

SPELL_CHOICES = [
    (0, 'empty'),
    (1, 'Espada (sword throw)'),
    (2, 'Saeta (arrows)'),
    (3, 'Fuego (fire)'),
    (4, 'Lanzar (flame jet)'),
    (5, 'Rascar (falling rocks)'),
    (6, 'Agua (water)'),
    (7, 'Guerra (lightning ult)'),
]

ITEM_CHOICES = [
    (0, 'empty'),
    (1, "Ken'ko Potion"),
    (2, 'Juu-en Fruit'),
    (3, 'Elixir of Kashi'),
    (4, 'Chikara Powder'),
    (5, 'Magia Stone'),
    (6, 'Holy Water of Acero'),
    (7, 'Sabre Oil'),
    (8, 'Kioku Feather'),
]


def enum_for(name: str):
    """Return [(value, label), ...] for a field name, or None if not enum."""
    if name in ENUMS:
        return ENUMS[name]
    if name.startswith('spell_slot_'):
        return SPELL_CHOICES
    if name.startswith('item_slot_'):
        return ITEM_CHOICES
    return None


def enum_label(value: int, choices) -> str:
    """Format an enum value as 'N — label'.  Falls back if value unknown."""
    for v, lbl in choices:
        if v == value:
            return f"{v} — {lbl}"
    return f"{value} — (custom)"


def enum_parse(s: str) -> int:
    """Parse the integer prefix from a 'N — label' string."""
    s = s.strip()
    if '—' in s:
        s = s.split('—', 1)[0].strip()
    elif ' - ' in s:
        s = s.split(' - ', 1)[0].strip()
    return save_edit.parse_int(s)


# ---------------------------------------------------------------------------
# Section grouping for the form (purely visual)
# ---------------------------------------------------------------------------

SECTIONS = [
    # More-specific predicates first; section_for() returns the first match.
    ("Special boss-flag candidates",         lambda f: f[1] in (0x47, 0x48)),
    ("Per-cavern bitmaps (save 0x00..0x4F)", lambda f: f[1] < 0x50 and f[2] != 'bool'),
    ("Crests",                               lambda f: f[0].startswith('crest_')),
    ("Boss-kill flags",                      lambda f: f[0].startswith('boss_kill_')),
    ("Player record — position / state",     lambda f: f[1] in (0x80, 0x82, 0x83, 0x84)),
    ("Player record — economy",              lambda f: f[1] in (0x85, 0x88, 0x8B)),
    ("Player record — stats",                lambda f: f[1] in (0x90, 0xB2, 0x98, 0x99,
                                                                  0x8D, 0x8E,
                                                                  0xC2, 0xC3, 0xC5, 0xC6,
                                                                  0xE4, 0xE6, 0xE7, 0xE8)),
    ("Equipment / inventory",                lambda f: 0x92 <= f[1] <= 0xAA),
    ("Weapon durability tables",             lambda f: 0xAB <= f[1] <= 0xBA and f[1] != 0xB2),
    ("Area / scene",                         lambda f: f[0] in ('current_area_id', 'player_tileset')),
]


def section_for(field):
    for label, pred in SECTIONS:
        if pred(field):
            return label
    return "Other"


# ---------------------------------------------------------------------------
# GUI app
# ---------------------------------------------------------------------------

class SaveEditorApp:
    def __init__(self, root: tk.Tk, initial_path: str | None = None):
        self.root = root
        root.title("Zeliard Save Editor")
        root.geometry("1100x800")

        self.current_path: Path | None = None
        self.original_data: bytes | None = None
        # widgets keyed by field name → (var_or_list, type, choices_or_None)
        # For 'bitmap8' fields, var_or_list is a list of (byte_var, bit_vars[8]).
        self.field_vars: dict[str, tuple] = {}
        # Suppresses recursive trace callbacks while the GUI updates one of
        # the dual byte/bit views from the other.
        self._suppress_trace = False

        self._build_ui()

        if initial_path:
            self._load_file(Path(initial_path))

    # ---------------------------------------------------------------- UI build

    def _build_ui(self):
        # Top toolbar
        toolbar = ttk.Frame(self.root, padding=(8, 6))
        toolbar.pack(side=tk.TOP, fill=tk.X)

        ttk.Button(toolbar, text="Open…",      command=self.open_file).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Reload",     command=self.reload).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Save",       command=self.save_in_place).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Save As…",   command=self.save_as).pack(side=tk.LEFT, padx=2)
        ttk.Separator(toolbar, orient=tk.VERTICAL).pack(side=tk.LEFT, fill=tk.Y, padx=8)
        ttk.Button(toolbar, text="Revert all", command=self.revert_all).pack(side=tk.LEFT, padx=2)

        self.status = tk.StringVar(value="No file loaded.")
        ttk.Label(toolbar, textvariable=self.status, foreground="gray30").pack(side=tk.RIGHT, padx=8)

        # Main split: form on left, hex view on right
        main = ttk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        main.pack(fill=tk.BOTH, expand=True)

        # ── Left pane: scrollable form ───────────────────────────────────
        form_outer = ttk.Frame(main)
        main.add(form_outer, weight=3)

        canvas = tk.Canvas(form_outer, highlightthickness=0)
        vsb = ttk.Scrollbar(form_outer, orient=tk.VERTICAL, command=canvas.yview)
        canvas.configure(yscrollcommand=vsb.set)
        canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        vsb.pack(side=tk.RIGHT, fill=tk.Y)

        form = ttk.Frame(canvas, padding=(8, 4))
        form_window = canvas.create_window((0, 0), window=form, anchor="nw")

        def _on_form_configure(_e):
            canvas.configure(scrollregion=canvas.bbox("all"))
        form.bind("<Configure>", _on_form_configure)

        def _on_canvas_configure(e):
            canvas.itemconfigure(form_window, width=e.width)
        canvas.bind("<Configure>", _on_canvas_configure)

        def _on_mouse_wheel(e):
            canvas.yview_scroll(int(-e.delta / 120), "units")
        canvas.bind_all("<MouseWheel>", _on_mouse_wheel)

        # Group fields by section
        grouped: dict[str, list] = {}
        for f in save_edit.FIELDS:
            grouped.setdefault(section_for(f), []).append(f)

        # Render groups in SECTIONS order, then any leftover
        ordered_sections = [s for s, _ in SECTIONS] + [
            s for s in grouped if s not in {x[0] for x in SECTIONS}
        ]
        for section_label in ordered_sections:
            fields = grouped.get(section_label, [])
            if not fields:
                continue
            if section_label.startswith("Per-cavern bitmaps"):
                self._render_bitmap_section(form, section_label, fields)
            else:
                self._render_section(form, section_label, fields)

        # ── Right pane: hex view + diff highlight ────────────────────────
        right = ttk.Frame(main, padding=(4, 4))
        main.add(right, weight=2)

        ttk.Label(right, text="Raw bytes (red = changed from disk)",
                  font=('TkDefaultFont', 9, 'bold')).pack(anchor=tk.W, pady=(0, 4))

        self.hex_text = tk.Text(right, font=('Consolas', 10), wrap=tk.NONE,
                                state=tk.DISABLED, bg='#1e1e1e', fg='#d0d0d0',
                                insertbackground='#d0d0d0')
        self.hex_text.tag_configure('changed', background='#552222', foreground='#ffe0e0')
        self.hex_text.tag_configure('addr', foreground='#888')
        self.hex_text.tag_configure('ascii', foreground='#9aa')
        self.hex_text.pack(fill=tk.BOTH, expand=True)

    def _render_bitmap_section(self, parent, label, fields):
        """Render the 10 cavern_bits_* fields as 10 byte-and-bit grids.
        Each field becomes a sub-LabelFrame with 8 rows (one per byte);
        each row has an offset label, a hex byte entry, and 8 bit
        checkboxes (bit 7 leftmost, bit 0 rightmost — standard convention).
        """
        outer = ttk.LabelFrame(parent, text=label, padding=(8, 4))
        outer.pack(fill=tk.X, pady=(6, 2), padx=2)

        for name, base_off, typ, desc in fields:
            self._render_one_bitmap(outer, name, base_off, desc)

    def _render_one_bitmap(self, parent, name: str, base_off: int, desc: str):
        title = f"{name}  (save 0x{base_off:02X}..0x{base_off + 7:02X})"
        frame = ttk.LabelFrame(parent, text=title, padding=(6, 2))
        frame.pack(fill=tk.X, pady=(2, 4), padx=2)

        if desc:
            ttk.Label(frame, text=desc, foreground='gray45',
                      wraplength=900, justify=tk.LEFT).grid(
                row=0, column=0, columnspan=12, sticky=tk.W, padx=(0, 0), pady=(0, 4))

        # Header row: bit position labels
        ttk.Label(frame, text='offset', foreground='gray', width=7).grid(row=1, column=0, sticky=tk.W)
        ttk.Label(frame, text='hex',    foreground='gray', width=4).grid(row=1, column=1, sticky=tk.W)
        for b in range(8):
            ttk.Label(frame, text=f'b{7 - b}', foreground='gray', width=3).grid(
                row=1, column=2 + b, sticky=tk.W)

        byte_vars = []
        bit_vars_2d = []  # bit_vars_2d[byte_idx][bit_idx 7..0]

        for byte_idx in range(8):
            byte_off = base_off + byte_idx
            row = 2 + byte_idx

            # Offset label (right-click reverts this whole bitmap field)
            off_lbl = ttk.Label(frame, text=f'0x{byte_off:02X}', foreground='gray40')
            off_lbl.grid(row=row, column=0, sticky=tk.W, padx=(0, 4))
            off_lbl.bind('<Button-3>', lambda _e, n=name: self._revert_field(n))

            # Hex byte entry
            byte_var = tk.IntVar()
            byte_vars.append(byte_var)

            ent = ttk.Entry(frame, font=('Consolas', 10), width=4,
                            justify=tk.CENTER)
            ent.grid(row=row, column=1, sticky=tk.W, padx=(0, 4))
            # Use textvariable proxy: we keep IntVar as truth, sync StringVar for the entry.
            string_proxy = tk.StringVar()
            ent.configure(textvariable=string_proxy)

            def _on_byte_string_change(*_a, bv=byte_var, sp=string_proxy, n=name):
                if self._suppress_trace:
                    return
                txt = sp.get().strip()
                if not txt:
                    return
                try:
                    val = save_edit.parse_int(txt) & 0xFF
                except ValueError:
                    return  # invalid entry while typing — ignore
                if val != bv.get():
                    self._suppress_trace = True
                    try:
                        bv.set(val)
                    finally:
                        self._suppress_trace = False
                self._refresh_hex(self._safe_compose())
            string_proxy.trace_add('write', _on_byte_string_change)

            # When byte_var changes (e.g. from bit toggle or populate),
            # update both string_proxy (visible hex) and the 8 bit checkboxes.
            bit_vars_row = []
            for bit_idx in range(7, -1, -1):  # bit 7 leftmost
                bv_chk = tk.IntVar()
                bit_vars_row.append(bv_chk)
                cb = ttk.Checkbutton(frame, variable=bv_chk)
                cb.grid(row=row, column=2 + (7 - bit_idx), sticky=tk.W, padx=1)

                def _on_bit_change(*_a, bv=byte_var, sp=string_proxy, chk=bv_chk, b=bit_idx):
                    if self._suppress_trace:
                        return
                    cur = bv.get()
                    if chk.get():
                        new = cur | (1 << b)
                    else:
                        new = cur & ~(1 << b)
                    if new != cur:
                        self._suppress_trace = True
                        try:
                            bv.set(new)
                            sp.set(f'{new:02X}')
                        finally:
                            self._suppress_trace = False
                    self._refresh_hex(self._safe_compose())
                bv_chk.trace_add('write', _on_bit_change)
            # bit_vars_row is in [bit7, bit6, ..., bit0] order.  Reorder to bit_idx 0..7
            bit_vars_2d.append(list(reversed(bit_vars_row)))

            # Trace on byte_var: keep string + bits in sync when set programmatically.
            def _on_byte_int_change(*_a, bv=byte_var, sp=string_proxy, bits=bit_vars_2d[-1]):
                if self._suppress_trace:
                    return
                v = bv.get() & 0xFF
                self._suppress_trace = True
                try:
                    sp.set(f'{v:02X}')
                    for i in range(8):
                        bits[i].set((v >> i) & 1)
                finally:
                    self._suppress_trace = False
                self._refresh_hex(self._safe_compose())
            byte_var.trace_add('write', _on_byte_int_change)

        # Store under field name with a marker type
        self.field_vars[name] = (byte_vars, ('bitmap8', base_off), bit_vars_2d)

    def _render_section(self, parent, label, fields):
        section = ttk.LabelFrame(parent, text=label, padding=(8, 4))
        section.pack(fill=tk.X, pady=(6, 2), padx=2)
        section.grid_columnconfigure(2, weight=1)

        # Header row
        ttk.Label(section, text="off",  foreground='gray', width=6).grid(row=0, column=0, sticky=tk.W)
        ttk.Label(section, text="name", foreground='gray', width=24).grid(row=0, column=1, sticky=tk.W)
        ttk.Label(section, text="value", foreground='gray').grid(row=0, column=2, sticky=tk.W)

        for r, (name, off, typ, desc) in enumerate(fields, start=1):
            off_lbl = ttk.Label(section, text=f"0x{off:02X}", foreground='gray40')
            off_lbl.grid(row=r, column=0, sticky=tk.W, padx=(0, 4))
            name_lbl = ttk.Label(section, text=name)
            name_lbl.grid(row=r, column=1, sticky=tk.W, padx=(0, 8))

            # Right-click on the offset/name reverts THAT field to disk value.
            def _revert(_e, n=name):
                self._revert_field(n)
            off_lbl.bind('<Button-3>', _revert)
            name_lbl.bind('<Button-3>', _revert)

            choices = enum_for(name)

            if typ == 'bool':
                bvar = tk.IntVar()
                cb = ttk.Checkbutton(section, variable=bvar,
                                     command=lambda n=name: self._on_field_change(n))
                cb.grid(row=r, column=2, sticky=tk.W)
                self.field_vars[name] = (bvar, typ, None)

            elif choices is not None:
                # Enumerated value -> dropdown.  Underlying type stays the
                # original byte/word; we just pre-fill with named options.
                var = tk.StringVar()
                values = [enum_label(v, choices) for v, _ in choices]
                cb = ttk.Combobox(section, textvariable=var, values=values,
                                  width=30)  # NOT readonly: user can type custom value
                cb.grid(row=r, column=2, sticky=tk.W)
                # trace_add fires on every text change -> live hex update
                var.trace_add('write',
                              lambda *_a, n=name: self._on_field_change(n, silent=True))
                self.field_vars[name] = (var, typ, choices)

            elif isinstance(typ, tuple) and typ[0] == 'raw':
                var = tk.StringVar()
                ent = ttk.Entry(section, textvariable=var,
                                font=('Consolas', 10), width=40)
                ent.grid(row=r, column=2, sticky=tk.EW)
                var.trace_add('write',
                              lambda *_a, n=name: self._on_field_change(n, silent=True))
                ent.bind('<Return>',   lambda _e, n=name: self._on_field_change(n))
                self.field_vars[name] = (var, typ, None)

            else:
                var = tk.StringVar()
                ent = ttk.Entry(section, textvariable=var, width=20)
                ent.grid(row=r, column=2, sticky=tk.W)
                var.trace_add('write',
                              lambda *_a, n=name: self._on_field_change(n, silent=True))
                ent.bind('<Return>',   lambda _e, n=name: self._on_field_change(n))
                self.field_vars[name] = (var, typ, None)

            # Description in small grey font
            ttk.Label(section, text=desc, foreground='gray45',
                      wraplength=520, justify=tk.LEFT).grid(
                row=r, column=3, sticky=tk.W, padx=(8, 0))

    # ---------------------------------------------------------------- File ops

    def open_file(self):
        path = filedialog.askopenfilename(
            title="Open Zeliard save",
            initialdir=str(Path(__file__).parent / "bin"),
            filetypes=[("Zeliard save", "*.usr *.USR"), ("All files", "*")])
        if path:
            self._load_file(Path(path))

    def reload(self):
        if self.current_path:
            self._load_file(self.current_path)

    def revert_all(self):
        if not self.original_data:
            return
        self._populate_fields(self.original_data)
        self._refresh_hex(self.original_data)

    def _load_file(self, path: Path):
        try:
            data = path.read_bytes()
        except OSError as e:
            messagebox.showerror("Open failed", str(e))
            return

        if len(data) != 256:
            if not messagebox.askyesno(
                "Unexpected size",
                f"File is {len(data)} bytes (expected 256). Open anyway?"):
                return

        self.current_path = path
        self.original_data = data
        self.root.title(f"Zeliard Save Editor — {path.name}")
        self.status.set(f"Loaded {path.name} ({len(data)} bytes)")
        self._populate_fields(data)
        self._refresh_hex(data)

    def save_in_place(self):
        if not self.current_path:
            self.save_as()
            return
        self._write(self.current_path)

    def save_as(self):
        if not self.current_path:
            messagebox.showwarning("No file", "Open a save file first.")
            return
        path = filedialog.asksaveasfilename(
            title="Save Zeliard save",
            initialdir=str(self.current_path.parent),
            initialfile=self.current_path.stem + "_edit.usr",
            defaultextension=".usr",
            filetypes=[("Zeliard save", "*.usr *.USR"), ("All files", "*")])
        if path:
            self._write(Path(path))

    def _write(self, path: Path):
        try:
            data = self._compose_bytes()
        except ValueError as e:
            messagebox.showerror("Invalid value", str(e))
            return
        try:
            path.write_bytes(data)
        except OSError as e:
            messagebox.showerror("Write failed", str(e))
            return
        self.status.set(f"Wrote {path.name} ({len(data)} bytes)")
        # If we wrote to the current file, update originals for diff highlighting
        if path == self.current_path:
            self.original_data = data
        self._refresh_hex(data)

    # ---------------------------------------------------------------- Field plumbing

    def _populate_fields(self, data: bytes):
        for name, (var_or_list, typ, choices) in self.field_vars.items():
            # Bitmap8: var_or_list is list of 8 IntVars (one per byte);
            # choices holds the 8x8 bit-checkbox vars.
            if isinstance(typ, tuple) and typ[0] == 'bitmap8':
                base = typ[1]
                self._suppress_trace = True
                try:
                    for i, bv in enumerate(var_or_list):
                        v = data[base + i]
                        bv.set(v)
                        # Manually sync the bit checkboxes since we
                        # suppressed traces.
                        for b in range(8):
                            choices[i][b].set((v >> b) & 1)
                    # Sync the visible hex StringVar by setting once more
                    # without suppression so the byte trace fires?  No —
                    # we already updated bits manually; the hex entry's
                    # StringVar update is only via the byte_var trace.
                    # Trigger it now:
                    self._suppress_trace = False
                    for bv in var_or_list:
                        # forced retrigger via set() with same value
                        cur = bv.get()
                        bv.set(cur)
                finally:
                    self._suppress_trace = False
                continue

            try:
                _, off, _, _ = save_edit.lookup(name)
                val = save_edit.decode_field(data, off, typ)
            except (KeyError, IndexError):
                continue

            if typ == 'bool':
                var_or_list.set(1 if val else 0)
            elif choices is not None:
                var_or_list.set(enum_label(val, choices))
            elif isinstance(typ, tuple) and typ[0] == 'raw':
                var_or_list.set(str(val))
            else:
                var_or_list.set(str(val))

    def _compose_bytes(self) -> bytes:
        if self.original_data is None:
            raise ValueError('no file loaded')
        out = bytearray(self.original_data)
        for name, (var_or_list, typ, choices) in self.field_vars.items():
            if isinstance(typ, tuple) and typ[0] == 'bitmap8':
                base = typ[1]
                for i, bv in enumerate(var_or_list):
                    out[base + i] = bv.get() & 0xFF
                continue

            _, off, _, _ = save_edit.lookup(name)
            if typ == 'bool':
                encoded = save_edit.encode_field(typ, var_or_list.get())
            elif choices is not None:
                txt = var_or_list.get().strip()
                if not txt:
                    continue
                value = enum_parse(txt)
                encoded = save_edit.encode_field(typ, value)
            else:
                txt = var_or_list.get().strip()
                if not txt:
                    continue
                encoded = save_edit.encode_field(typ, txt)
            out[off:off + len(encoded)] = encoded
        return bytes(out)

    def _on_field_change(self, name: str, silent: bool = False):
        """Refresh hex view; on Enter/blur (silent=False) show errors."""
        var, typ, choices = self.field_vars[name]
        # Bitmap fields manage their own traces internally.
        if isinstance(typ, tuple) and typ[0] == 'bitmap8':
            self._refresh_hex(self._safe_compose())
            return
        # Validate this one field eagerly
        try:
            if typ == 'bool':
                save_edit.encode_field(typ, var.get())
            elif choices is not None:
                txt = var.get().strip()
                if txt:
                    save_edit.encode_field(typ, enum_parse(txt))
            else:
                txt = var.get().strip()
                if txt:
                    save_edit.encode_field(typ, txt)
        except ValueError as e:
            if not silent:
                messagebox.showerror("Invalid value", f"{name}: {e}")
                _, off, _, _ = save_edit.lookup(name)
                old = save_edit.decode_field(self.original_data, off, typ)
                if choices is not None:
                    var.set(enum_label(old, choices))
                else:
                    var.set(str(old))
            return
        self._refresh_hex(self._safe_compose())

    def _safe_compose(self) -> bytes:
        try:
            return self._compose_bytes()
        except ValueError:
            return self.original_data or b''

    def _revert_field(self, name: str):
        """Reset one field to its on-disk value."""
        if not self.original_data:
            return
        var, typ, choices = self.field_vars[name]
        if isinstance(typ, tuple) and typ[0] == 'bitmap8':
            base = typ[1]
            for i, bv in enumerate(var):
                bv.set(self.original_data[base + i])  # trace will resync hex+bits
            return
        _, off, _, _ = save_edit.lookup(name)
        old = save_edit.decode_field(self.original_data, off, typ)
        if typ == 'bool':
            var.set(1 if old else 0)
        elif choices is not None:
            var.set(enum_label(old, choices))
        else:
            var.set(str(old))
        self._refresh_hex(self._safe_compose())

    # ---------------------------------------------------------------- Hex view

    def _refresh_hex(self, data: bytes):
        self.hex_text.configure(state=tk.NORMAL)
        self.hex_text.delete('1.0', tk.END)

        baseline = self.original_data or data

        for i in range(0, len(data), 16):
            self.hex_text.insert(tk.END, f"{i:04x}  ", ('addr',))
            row_bytes = data[i:i + 16]
            row_base = baseline[i:i + 16] if baseline else row_bytes

            for j, b in enumerate(row_bytes):
                if j < len(row_base) and b != row_base[j]:
                    self.hex_text.insert(tk.END, f"{b:02x} ", ('changed',))
                else:
                    self.hex_text.insert(tk.END, f"{b:02x} ")
                if j == 7:
                    self.hex_text.insert(tk.END, " ")

            # Pad if last row short
            for _ in range(16 - len(row_bytes)):
                self.hex_text.insert(tk.END, "   ")

            ascii_repr = "".join(
                chr(b) if 32 <= b < 127 else "." for b in row_bytes)
            self.hex_text.insert(tk.END, " |", ('ascii',))
            self.hex_text.insert(tk.END, ascii_repr, ('ascii',))
            self.hex_text.insert(tk.END, "|\n", ('ascii',))

        self.hex_text.configure(state=tk.DISABLED)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    root = tk.Tk()
    initial = sys.argv[1] if len(sys.argv) > 1 else None
    SaveEditorApp(root, initial)
    root.mainloop()


if __name__ == '__main__':
    main()
