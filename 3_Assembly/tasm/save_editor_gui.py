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
        # widgets keyed by field name → (var, widget, type)
        self.field_vars: dict[str, tuple] = {}

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

    def _render_section(self, parent, label, fields):
        section = ttk.LabelFrame(parent, text=label, padding=(8, 4))
        section.pack(fill=tk.X, pady=(6, 2), padx=2)
        section.grid_columnconfigure(2, weight=1)

        # Header row
        ttk.Label(section, text="off",  foreground='gray', width=6).grid(row=0, column=0, sticky=tk.W)
        ttk.Label(section, text="name", foreground='gray', width=24).grid(row=0, column=1, sticky=tk.W)
        ttk.Label(section, text="value", foreground='gray').grid(row=0, column=2, sticky=tk.W)

        for r, (name, off, typ, desc) in enumerate(fields, start=1):
            ttk.Label(section, text=f"0x{off:02X}", foreground='gray40').grid(
                row=r, column=0, sticky=tk.W, padx=(0, 4))
            ttk.Label(section, text=name).grid(
                row=r, column=1, sticky=tk.W, padx=(0, 8))

            var = tk.StringVar()
            if typ == 'bool':
                bvar = tk.IntVar()
                cb = ttk.Checkbutton(section, variable=bvar,
                                     command=lambda n=name, v=bvar: self._on_bool_change(n, v))
                cb.grid(row=r, column=2, sticky=tk.W)
                var = bvar
            elif isinstance(typ, tuple) and typ[0] == 'raw':
                ent = ttk.Entry(section, textvariable=var,
                                font=('Consolas', 10), width=40)
                ent.grid(row=r, column=2, sticky=tk.EW)
                ent.bind('<FocusOut>', lambda _e, n=name: self._on_text_change(n))
                ent.bind('<Return>',   lambda _e, n=name: self._on_text_change(n))
            else:
                ent = ttk.Entry(section, textvariable=var, width=20)
                ent.grid(row=r, column=2, sticky=tk.W)
                ent.bind('<FocusOut>', lambda _e, n=name: self._on_text_change(n))
                ent.bind('<Return>',   lambda _e, n=name: self._on_text_change(n))

            self.field_vars[name] = (var, typ)

            # Description below in small grey font
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
        for name, (var, typ) in self.field_vars.items():
            try:
                _, off, _, _ = save_edit.lookup(name)
                val = save_edit.decode_field(data, off, typ)
            except (KeyError, IndexError):
                continue

            if typ == 'bool':
                var.set(1 if val else 0)
            elif isinstance(typ, tuple) and typ[0] == 'raw':
                var.set(str(val))
            elif typ == '24':
                var.set(str(val))
            elif typ == 'w':
                var.set(str(val))
            else:
                var.set(str(val))

    def _compose_bytes(self) -> bytes:
        out = bytearray(self.original_data)
        for name, (var, typ) in self.field_vars.items():
            _, off, _, _ = save_edit.lookup(name)
            if typ == 'bool':
                encoded = save_edit.encode_field(typ, var.get())
            else:
                txt = var.get().strip()
                if not txt:
                    continue
                encoded = save_edit.encode_field(typ, txt)
            out[off:off + len(encoded)] = encoded
        return bytes(out)

    def _on_bool_change(self, name, var):
        self._refresh_hex(self._safe_compose())

    def _on_text_change(self, name):
        # Validate this one field; reset to old value if invalid.
        var, typ = self.field_vars[name]
        try:
            save_edit.encode_field(typ, var.get())
        except ValueError as e:
            messagebox.showerror("Invalid value", f"{name}: {e}")
            # Restore from original
            _, off, _, _ = save_edit.lookup(name)
            old = save_edit.decode_field(self.original_data, off, typ)
            var.set(str(old))
            return
        self._refresh_hex(self._safe_compose())

    def _safe_compose(self) -> bytes:
        try:
            return self._compose_bytes()
        except ValueError:
            return self.original_data or b''

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
