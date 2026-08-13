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
    'sword': [
        (0, 'none / fist'),
        (1, "Training Sword (starter)"),
        (2, "Wise Man's Sword"),
        (3, 'Spirit Sword'),
        (4, "Knight's Sword"),
        (5, 'Illumination Sword'),
        (6, 'Enchantment Sword'),
        (7, 'Sword of the Fairy Flame (secret)'),
    ],
    'selected_spell': [
        (0, 'none'),
        (1, 'Espada'),
        (2, 'Saeta'),
        (3, 'Fuego'),
        (4, 'Lanzar'),
        (5, 'Rascar'),
        (6, 'Agua'),
        (7, 'Guerra'),
    ],
    'shield': [
        (0, 'none'),
        (1, 'Clay Shield'),
        (2, "Wise Man's Shield"),
        (3, 'Stone Shield'),
        (4, 'Honor Shield'),
        (5, 'Light Shield'),
        (6, 'Titanium Shield'),
    ],
    'save_sage': [
        (0x80, "Felishika's Castle"),
        (0x81, 'Muralla'),
        (0x82, 'Satono'),
        (0x83, 'Bosque'),
        (0x84, 'Helada'),
        (0x85, 'Tumba'),
        (0x86, 'Dorado'),
        (0x87, 'Llama'),
        (0x88, 'Pureza'),
        (0x89, 'Esco'),
    ],
    'last_sage_visited': [
        (0x80, "Felishika's Castle"),
        (0x81, 'Muralla (DOS always shows this)'),
        (0x82, 'Satono'),
        (0x83, 'Bosque'),
        (0x84, 'Helada'),
        (0x85, 'Tumba'),
        (0x86, 'Dorado'),
        (0x87, 'Llama'),
        (0x88, 'Pureza'),
        (0x89, 'Esco'),
    ],
    'player_tileset': [
        (0, '0 — town'),
        (1, '1 — generic dungeon'),
        (2, '2 — forest'),
        (3, '3 — other'),
    ],
}

# ---------------------------------------------------------------------------
# Bitfield-byte definitions: a single byte's bits map to named items.
# Each entry: (bit_index 0..7, human label).  Unlisted bits are reserved.
# ---------------------------------------------------------------------------

SHOP_MAGIC_BITS = [
    (7, "Ken'ko Potion"),
    (6, "Juu-en Fruit"),
    (5, "Elixir of Kashi"),
    (4, "Chikara Powder"),
    (3, "Magia Stone"),
    (2, "Holy Water of Acero"),
    (1, "Sabre Oil"),
    (0, "Kioku Feather"),
]

SHOP_SWORD_BITS = [
    (7, "Training Sword"),
    (6, "Wise Man's Sword"),
    (5, "Spirit Sword"),
    (4, "Knight's Sword"),
    (3, "Illumination Sword"),
    (2, "Enchantment Sword"),
    # bits 1, 0 unused per TCRF
]

SHOP_SHIELD_BITS = [
    (7, "Clay Shield"),
    (6, "Wise Man's Shield"),
    (5, "Stone Shield"),
    (4, "Honor Shield"),
    (3, "Light Shield"),
    (2, "Titanium Shield"),
    # bits 1, 0 unused per TCRF
]

SAGES_SPOKEN_BITS = [
    (7, "Muralla"),
    (6, "Satono"),
    (5, "Bosque"),
    (4, "Helada"),
    (3, "Tumba"),
    (2, "Dorado"),
    (1, "Llama"),
    (0, "Pureza"),
]


def bits_for(name: str):
    """Return [(bit_idx, label), ...] for fields whose byte is a labeled bitfield, else None."""
    if name.startswith('shop_magic_'):
        return SHOP_MAGIC_BITS
    if name.startswith('shop_sword_'):
        return SHOP_SWORD_BITS
    if name.startswith('shop_shield_'):
        return SHOP_SHIELD_BITS
    if name == 'sages_spoken_bitmap':
        return SAGES_SPOKEN_BITS
    return None


# ---------------------------------------------------------------------------
# TCRF per-byte bit names for the dungeon/town event handler region
# (save offsets 0x00..0x4F).  Source:
#   4_Resources/Save Game Format/Save-Game-Format.html
#
# Entry shapes:
#   list                  → named bitfield (TCRF documented bits, rendered
#                            as labeled checkboxes)
#   ('word_bool', label)  → 16-bit boss-defeated flag spanning this byte
#                            and the next (00 00 = no, FF FF = yes); high
#                            byte is implicit and skipped in render
#   ('bool', label)        → whole-byte 00/FF flag (single checkbox)
#
# Bytes without an entry are reserved per TCRF (confirmed all-zero across
# all 17 sample saves) — the renderer skips them.
# ---------------------------------------------------------------------------
EVENT_BITS = {
    # ── Cavern 1: Cangrejo / Malicia ──────────────────────────────────────
    0x00: ('word_bool', 'Cangrejo defeated'),  # spans 0x00..0x01
    0x02: [(7, 'Chest, 50 Golds'),    (6, 'Chest, Red Potion'),
           (5, 'Muralla Key 1'),       (4, 'Wall, Blue Potion'),
           (3, "Key, Cangrejo's Lair")],
    0x03: [(7, 'Door to Cangrejo open'), (6, 'Door to Satono open'),
           (5, 'Tear of Esmesanti')],
    0x05: ('bool', 'Spoke to the King (gates 1000-Gold gift)'),
    0x06: ('bool', 'Entered caverns first time (overrides spoke_king)'),
    # ── Cavern 2: Pulpo / Peligro ─────────────────────────────────────────
    0x08: ('word_bool', 'Pulpo defeated'),  # spans 0x08..0x09
    0x0A: [(7, 'Chest, Blue Potion (One-time Bat)'),
           (6, 'Key, Under Locked Door'),
           (5, 'Key, Under Blue Open Door'),
           (4, 'Wall, Red Potion (Far)'),
           (3, 'Chest, 50 Gold (Under Satono)'),
           (2, 'Empty Chest'),
           (1, 'Wall, 100 almas'),
           (0, 'Chest, Red Potion')],
    0x0B: [(7, 'Open 1st Locked Blue Door'),
           (6, 'Open Locked Red Door'),
           (5, 'Open Locked Door to 3rd Dungeon'),
           (4, "Key, Pulpo's Lair"),
           (3, 'Tear of Esmesanti'),
           (2, 'Wall, Red Potion (Near Satono)')],
    # ── Cavern 3: Pollo / Madera + Riza ───────────────────────────────────
    0x10: ('word_bool', 'Pollo defeated'),  # spans 0x10..0x11
    0x12: [(7, 'Red Potion (Small tree)'),
           (6, 'Key'),
           (5, "Chest, Red Potion (near Hero's Crest)"),
           (4, 'Wall, Red Potion (Largest Tree)'),
           (3, "Hero's Crest (gates Pollo encounter)"),
           (2, '50 Gold (Under Bosque)'),
           (1, 'Blue Potion (in Riza)'),
           (0, 'Red Potion (in Riza)')],
    0x13: [(7, 'Red Potion'),
           (6, 'Chest, Blue Potion'),
           (5, 'Empty Chest'),
           (4, '100 Gold'),
           (3, 'Open Locked Red Door'),
           (2, "Key, Pollo's Lair"),
           (1, 'Tear of Esmesanti'),
           (0, 'Open Locked Door to 4th Dungeon')],
    # ── Cavern 4: Agar / Glacial + Escarcha ───────────────────────────────
    0x18: ('word_bool', 'Agar defeated'),  # spans 0x18..0x19
    0x1A: [(7, 'Key'),
           (6, 'Red Potion (Near locked door)'),
           (5, 'Red Potion (Near Ruzeria Shoes)'),
           (4, 'Ruzeria Shoes'),
           (3, 'Blue Potion (Near Ruzeria Shoes)'),
           (2, 'Blue Potion (By Boss Door)'),
           (1, 'Red Potion (Beside 100 Golds)'),
           (0, '100 Golds')],
    0x1B: [(7, 'Open 1st Locked Door'),
           (6, "Open locked door to Agar's Domain"),
           (5, 'Chest, 50 Golds'),
           (4, 'Chest, Blue Potion (By Helada Key)'),
           (3, 'Key (To Helada)'),
           (2, 'Red Potion (Near Helada)'),
           (1, 'Blue Potion (Near Boss Key)'),
           (0, 'Key (To Boss Lair)')],
    0x1C: [(7, 'Wall, Blue Potion (Beside Purple door)'),
           (6, 'Wall, Red Potion (Near Boss Key)'),
           (5, 'Open door to Helada'),
           (4, 'Tear of Esmesanti')],
    # ── Cavern 5: Vista / Corroer + Cementar ──────────────────────────────
    0x20: ('word_bool', 'Vista defeated'),  # spans 0x20..0x21
    0x22: [(7, 'Chest, Red Potion'),
           (6, 'Wall, Red Potion (Near Tumba 1st entrance)'),
           (5, 'Chest, 500 Golds (Nowhere near Gelroid)'),
           (4, 'Chest, Blue Potion (On way to boss)'),
           (3, 'Chest, 500 Golds (On way to boss)'),
           (2, 'Chest, 50 Golds'),
           (1, 'Chest, Pirika Shoes'),
           (0, 'Chest, 100 Golds')],
    0x23: [(7, 'Open locked door to Cementar'),
           (6, 'Wall, Blue Potion (right pair)'),
           (5, 'Chest, 1000 Golds'),
           (4, 'Key (1st locked door)'),
           (3, 'Chest, 50 Golds'),
           (2, "Chest, Blue Potion (Outside Vista's Lair)"),
           (1, 'Key (To Boss Lair)'),
           (0, 'Chest, Red Potion')],
    0x24: [(7, 'Crest of Glory'),
           (6, 'Wall, 100 Almas (glitched)'),
           (5, 'Chest, Blue Potion (left pair)'),
           (4, 'Open locked door to Vista'),
           (3, "Blue Potion (in Vista's Lair)"),
           (2, 'Tear of Esmesanti'),
           (1, "Returned Crest of Glory (-16 to 0xD6, removes Knight's Sword)")],
    # ── Cavern 6: Tarso / Tesoro + Plata + Arrugia secret ────────────────
    0x28: ('word_bool', 'Tarso defeated'),  # spans 0x28..0x29
    0x2A: [(7, 'Chest, Red Potion'),
           (6, 'Empty Chest'),
           (5, 'Key, Near Silkarn Shoes'),
           (4, 'Wall, Blue Potion (Near Silkarn Shoes)'),
           (3, 'Chest, 1000 Golds (Near Silkarn Shoes)'),
           (2, 'Silkarn Shoes'),
           (1, 'Chest, Blue Potion (left pair)'),
           (0, 'Chest, Blue Potion (right pair)')],
    0x2B: [(7, 'Chest, 1000 Golds (Tesoro, near 2 Blue Potions)'),
           (6, 'Key (Tesoro, To Dorado Town)'),
           (5, 'Open locked door to Cavern of Caliente (7th dungeon)'),
           (4, 'Open locked door to Cavern of Arrugia (lion-key door)'),
           (3, 'Open locked door to Tarso'),
           (2, 'Open locked door to Dorado Town'),
           (1, 'Wall, Blue Potion (On way to boss)'),
           (0, 'Chest, 500 Golds')],
    0x2C: [(7, 'Chest, Red Potion'),
           (6, 'Wall, Blue Potion (near fire pit, leading to Silkarn)'),
           (5, 'Wall, Blue Potion'),
           (4, 'Wall, Red Potion (Near Fire pit)'),
           (3, 'Enchantment Sword (Arrugia)'),
           (2, 'Feruza Shoes (Arrugia)'),
           (1, '1000 Golds (Arrugia, 3rd one)'),
           (0, '1000 Golds (Arrugia, 2nd one)')],
    0x2D: [(7, '1000 Golds (Arrugia, 1st one)'),
           (6, 'Blue Potion (Arrugia)'),
           (5, "Key, Tarso's Lair"),
           (4, 'Tear of Esmesanti')],
    # ── Llama Town: Paguro + Cavern of Caliente / Dragon ─────────────────
    0x30: ('word_bool', 'Paguro defeated (gates Llama Town NPC dialog)'),  # spans 0x30..0x31
    0x32: ('word_bool', 'Dragon defeated'),  # spans 0x32..0x33
    0x34: [(7, 'Spoke to the girl after defeating Paguro'),
           (6, 'Purchased the Asbestos Cape'),
           (5, 'Open locked door (1st)'),
           (4, "Open locked door to Dragon's lair"),
           (3, 'Chest, Blue Potion (Requires platform)'),
           (2, 'Key (1st)'),
           (1, 'Chest, Blue Potion (By vertical wind tunnel)'),
           (0, 'Key (2nd)')],
    0x35: [(7, "Chest, Blue Potion (Next to Dragon's door)"),
           (6, 'Chest, 1000 Golds'),
           (5, 'Open locked door (2nd)'),
           (4, 'Chest, Blue Potion (Reaccion)'),
           (3, 'Chest, 500 Golds (Reaccion)'),
           (2, 'Chest, Blue Potion'),
           (1, 'Chest, Key (Correr, 3rd)'),
           (0, 'Chest, 1000 Golds (Correr)')],
    0x36: [(7, 'Tear of Esmesanti')],
    # ── Cavern of Absor + Cavern of Final ─────────────────────────────────
    0x42: [(7, 'Ceiling, Blue Potion (left of below)'),
           (6, "Ceiling, Blue Potion (Near Dragon's Lair exit)"),
           (5, 'Ceiling, Blue Potion (Near Glowing Pit)'),
           (4, 'Chest, 500 Golds (Near Lion Key)'),
           (3, "Lion's Head Key"),
           (2, 'Chest, 1000 Golds'),
           (1, 'Chest, 1000 Golds (On way to Cavern of Falter)'),
           (0, 'Empty Chest')],
    0x43: [(7, 'Chest, 500 Golds (Far from Lion Key, Absor)'),
           (6, 'Open 1st locked door (Absor)'),
           (5, 'Chest, 1000 Golds'),
           (4, 'Ceiling, Blue Potion (Above Glowing Pit)'),
           (3, 'Ceiling, Blue Potion (Near 2nd key)'),
           (2, 'Key (2nd Door)'),
           (1, 'Key (Boss Door)'),
           (0, 'Ceiling, Blue Potion (Near Esco Village)')],
    0x44: [(7, 'Chest, 1000 Golds (Milagro)'),
           (6, 'Wall, Blue Potion (Beside Boss Door)'),
           (5, "Open 3rd locked door (Milagro, Alguien's Boss Door)"),
           (4, 'Open 2nd locked door (Milagro)'),
           (3, 'Key'),
           (2, 'Ceiling, Blue Potion (After Crazy Current)'),
           (1, 'Ceiling, Blue Potion (Above Air Current)'),
           (0, 'Ceiling, Blue Potion (Below Air Current)')],
    0x45: [(7, 'Travel back to Dorado Town (building in back)'),
           (6, 'Tear of Esmesanti'),
           (5, "Open final locked door (Jashiin's Lair)"),
           (4, 'Key (Final)')],
    # 0x46..0x4F: reserved per TCRF; cavern_bits_alguien (0x40..0x47) covers
    # 0x46/0x47 but they have no documented semantic.  cavern_bits_unknown_*
    # slots dropped from FIELDS entirely.  Bytes preserved verbatim.
}


def event_bits_for(off: int):
    """Return the TCRF bit spec for a byte at `off` in 0x00..0x4F.
    May be:
      * a list of (bit_idx, label) tuples — named bitfield byte;
      * ('word_bool', label) — single 16-bit boss flag spanning off..off+1;
      * ('bool', label)      — whole-byte 00/FF flag;
      * None — reserved / undocumented byte; renderer skips the row.
    """
    return EVENT_BITS.get(off)


WEARABLE_CHOICES = [
    (0, 'empty'),
    (1, 'Feruza Shoes (secret cavern)'),
    (2, 'Pirika Shoes (Tumba/Graveyard)'),
    (3, 'Silkarn Shoes (Dorado/Gold)'),
    (4, 'Ruzeria Shoes (Helada/Ice)'),
    (5, 'Asbestos Cape (bought at Llama)'),
]

# Item inventory IDs (5 slots × 8 possible item types per playthrough §5.3.1).
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
    if name.startswith('wear_') or name == 'selected_accessory':
        return WEARABLE_CHOICES
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
    ("Per-cavern bitmaps (save 0x00..0x4F)", lambda f: f[1] < 0x50 and f[2] != 'bool'),
    ("Crests",                               lambda f: f[0].startswith('crest_')),
    ("Spells learned (toggle to give/remove a spell)",
                                              lambda f: f[0].startswith('spell_known_')),
    ("Player record — position / state",     lambda f: f[1] in (0x80, 0x82, 0x83, 0x84)),
    ("Player record — economy",              lambda f: f[1] in (0x85, 0x88, 0x8B)),
    ("Player record — stats",                lambda f: f[1] in (0x90, 0xB2, 0x98, 0x99,
                                                                  0x8D, 0x8E,
                                                                  0xC2, 0xC3, 0xC6, 0xC7, 0xC8,
                                                                  0xE4, 0xE6, 0xE7, 0xE8)),
    ("Wearables (4 shoes + cape, in acquisition order)",
                                              lambda f: f[0].startswith('wear_')),
    ("Item inventory (5 slots, magic items 1..8)",
                                              lambda f: f[0].startswith('item_slot_')),
    ("Equipment + selected weapon/spell",     lambda f: 0x92 <= f[1] <= 0xAA),
    ("Spell charges (current and max, per spell)",
                                              lambda f: f[0].startswith('charges_')),
    ("Sages",                                 lambda f: f[0] in ('save_sage', 'last_sage_visited', 'sages_spoken_bitmap')),
    ("Magic shop inventory (per town, bitfield)",
                                              lambda f: f[0].startswith('shop_magic_')),
    ("Weapon shop — swords (per town, bitfield)",
                                              lambda f: f[0].startswith('shop_sword_')),
    ("Weapon shop — shields (per town, bitfield)",
                                              lambda f: f[0].startswith('shop_shield_')),
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
        """Render a single 8-byte cavern bitmap as 8 rows, each with:
            offset | hex byte | labeled bit controls | [set 00] [set FF]
        byte_var is the single source of truth for each byte.  Editing any
        of (hex entry, bit checkboxes, all/clear buttons) calls
        _set_byte_value() which then fans the new value out to every other
        view synchronously.
        """
        title = f"{name}  (save 0x{base_off:02X}..0x{base_off + 7:02X})"
        frame = ttk.LabelFrame(parent, text=title, padding=(6, 2))
        frame.pack(fill=tk.X, pady=(2, 4), padx=2)

        if desc:
            ttk.Label(frame, text=desc, foreground='gray45',
                      wraplength=900, justify=tk.LEFT).grid(
                row=0, column=0, columnspan=14, sticky=tk.W, pady=(0, 4))

        # Header row (compact since per-byte rows now have inline named bits)
        ttk.Label(frame, text='offset', foreground='gray', width=11).grid(row=1, column=0, sticky=tk.W)
        ttk.Label(frame, text='hex',    foreground='gray', width=4).grid(row=1, column=1, sticky=tk.W)
        ttk.Label(frame, text='bits / TCRF labels', foreground='gray').grid(
            row=1, column=2, columnspan=10, sticky=tk.W, padx=(8, 0))
        ttk.Label(frame, text='actions', foreground='gray').grid(
            row=1, column=12, columnspan=2, sticky=tk.W, padx=(8, 0))

        byte_vars = []
        bit_vars_2d = []     # bit_vars_2d[byte_idx][bit_idx 0..7] = IntVar
        string_vars = []     # one StringVar per byte (the hex entry display)
        whole_checks = {}    # byte_idx -> (checkbox IntVar, byte span)

        def _sync_whole_checks(values):
            """Refresh whole-byte/word checkboxes after a suppressed load."""
            for byte_idx, (check_var, span) in whole_checks.items():
                check_var.set(1 if all(values[byte_idx + i] == 0xFF
                                       for i in range(span)) else 0)

        # Per-byte propagation: writing one of (byte_var, string_var, bit_vars)
        # fans out to the other two via trace callbacks.  _suppress_trace breaks
        # recursion.  Defined once over byte_vars/string_vars/bit_vars_2d.
        def _set_byte(byte_idx: int, value: int):
            value &= 0xFF
            if self._suppress_trace:
                return
            self._suppress_trace = True
            try:
                byte_vars[byte_idx].set(value)
                string_vars[byte_idx].set(f'{value:02X}')
                for b in range(8):
                    bit_vars_2d[byte_idx][b].set((value >> b) & 1)
                _sync_whole_checks([bv.get() for bv in byte_vars])
            finally:
                self._suppress_trace = False
            self._refresh_hex(self._safe_compose())

        # word_bool spans byte_idx and byte_idx+1; both bytes get the same
        # value (0x00 or 0xFF) atomically.
        def _set_word_bool(byte_idx: int, checked: bool):
            if self._suppress_trace:
                return
            value = 0xFF if checked else 0x00
            self._suppress_trace = True
            try:
                for i in (byte_idx, byte_idx + 1):
                    byte_vars[i].set(value)
                    string_vars[i].set(f'{value:02X}')
                    for b in range(8):
                        bit_vars_2d[i][b].set((value >> b) & 1)
                _sync_whole_checks([bv.get() for bv in byte_vars])
            finally:
                self._suppress_trace = False
            self._refresh_hex(self._safe_compose())

        # First pass: create byte_vars/string_vars/bit_vars_2d for ALL 8 bytes
        # so the lists are correctly indexed regardless of which rows render.
        for byte_idx in range(8):
            byte_vars.append(tk.IntVar(value=0))
            string_vars.append(tk.StringVar(value='00'))
            bit_vars_2d.append([tk.IntVar(value=0) for _ in range(8)])

        # Second pass: render rows.  Skip:
        #   - the high byte of a word_bool (the checkbox on the low-byte row
        #     controls both bytes), and
        #   - bytes with no documented TCRF semantic (unknown / reserved
        #     bytes are confirmed all-zero across all 17 sample saves; no
        #     reason to give them UI).  Bytes still preserved verbatim
        #     through compose_bytes.
        prev_was_word_bool = False
        display_row = 2
        for byte_idx in range(8):
            byte_off = base_off + byte_idx

            if prev_was_word_bool:
                prev_was_word_bool = False
                continue

            tcrf = event_bits_for(byte_off)

            # Skip undocumented bytes entirely.
            if tcrf is None:
                continue

            row = display_row
            display_row += 1

            byte_var = byte_vars[byte_idx]
            string_var = string_vars[byte_idx]
            bit_vars_row = bit_vars_2d[byte_idx]

            is_word_bool = isinstance(tcrf, tuple) and tcrf[0] == 'word_bool'
            is_bool      = isinstance(tcrf, tuple) and tcrf[0] == 'bool'

            # Offset label — right-click reverts the whole bitmap field
            off_text = (f'0x{byte_off:02X}..0x{byte_off + 1:02X}'
                        if is_word_bool else f'0x{byte_off:02X}')
            off_lbl = ttk.Label(frame, text=off_text, foreground='gray40')
            off_lbl.grid(row=row, column=0, sticky=tk.W, padx=(0, 4))
            off_lbl.bind('<Button-3>', lambda _e, n=name: self._revert_field(n))

            # Hex byte entry — suppressed for word_bool (binary toggle only).
            if not is_word_bool:
                ent = ttk.Entry(frame, textvariable=string_var, font=('Consolas', 10),
                                width=4, justify=tk.CENTER)
                ent.grid(row=row, column=1, sticky=tk.W, padx=(0, 4))

                def _on_string_change(*_a, sv=string_var, byte_idx=byte_idx):
                    if self._suppress_trace:
                        return
                    txt = sv.get().strip()
                    if not txt:
                        return
                    # Bitmap byte entry: always parse as hex (so 'AB' -> 0xAB).
                    t = txt
                    if t.lower().startswith('0x'):
                        t = t[2:]
                    elif t.lower().endswith('h'):
                        t = t[:-1]
                    try:
                        val = int(t, 16) & 0xFF
                    except ValueError:
                        return  # mid-typing partial, ignore silently
                    _set_byte(byte_idx, val)
                string_var.trace_add('write', _on_string_change)

            sub = ttk.Frame(frame)
            sub.grid(row=row, column=2, columnspan=10, sticky=tk.W, padx=(4, 0))

            if is_word_bool:
                # 16-bit boss-defeated flag: single checkbox toggling both bytes.
                # Drive the checkbox from byte_var (0xFF=on, 0x00=off) so it
                # stays in sync if either byte changes externally.
                chk_var = tk.IntVar(value=1 if byte_var.get() == 0xFF else 0)
                cb = ttk.Checkbutton(sub, text=tcrf[1], variable=chk_var)
                cb.pack(side=tk.LEFT, padx=(0, 8))

                def _on_chk(*_a, cv=chk_var, byte_idx=byte_idx):
                    _set_word_bool(byte_idx, bool(cv.get()))
                chk_var.trace_add('write', _on_chk)

                def _on_byte_change(*_a, bv=byte_var, cv=chk_var):
                    if self._suppress_trace:
                        return
                    desired = 1 if bv.get() == 0xFF else 0
                    if cv.get() != desired:
                        # Re-entry guarded by chk_var.trace below;
                        # _set_word_bool is no-op when value already matches.
                        cv.set(desired)
                byte_var.trace_add('write', _on_byte_change)
                whole_checks[byte_idx] = (chk_var, 2)

                prev_was_word_bool = True

            elif is_bool:
                # Whole-byte 00/FF flag: single checkbox.
                chk_var = tk.IntVar(value=1 if byte_var.get() == 0xFF else 0)
                cb = ttk.Checkbutton(sub, text=tcrf[1], variable=chk_var)
                cb.pack(side=tk.LEFT, padx=(0, 8))

                def _on_chk(*_a, cv=chk_var, byte_idx=byte_idx):
                    if self._suppress_trace:
                        return
                    _set_byte(byte_idx, 0xFF if cv.get() else 0x00)
                chk_var.trace_add('write', _on_chk)

                def _on_byte_change(*_a, bv=byte_var, cv=chk_var):
                    if self._suppress_trace:
                        return
                    desired = 1 if bv.get() == 0xFF else 0
                    if cv.get() != desired:
                        cv.set(desired)
                byte_var.trace_add('write', _on_byte_change)
                whole_checks[byte_idx] = (chk_var, 1)

            elif isinstance(tcrf, list):
                # Named bitfield: render labeled checkboxes for documented
                # bits in TCRF order; trailing row of "b{N}" boxes for any
                # undocumented bits.
                documented = {bit_idx for bit_idx, _ in tcrf}
                inline_col = 0
                for bit_idx, label in tcrf:
                    bv_chk = bit_vars_row[bit_idx]
                    cb = ttk.Checkbutton(sub, text=label, variable=bv_chk)
                    cb.grid(row=inline_col // 2, column=inline_col % 2,
                            sticky=tk.W, padx=(0, 8))
                    inline_col += 1
                    def _on_bit_change(*_a, b=bit_idx, chk=bv_chk, byte_idx=byte_idx):
                        if self._suppress_trace:
                            return
                        cur = byte_vars[byte_idx].get()
                        new = (cur | (1 << b)) if chk.get() else (cur & ~(1 << b))
                        if new != cur:
                            _set_byte(byte_idx, new)
                    bv_chk.trace_add('write', _on_bit_change)
                if undoc := [b for b in range(7, -1, -1) if b not in documented]:
                    tail = ttk.Frame(sub)
                    tail.grid(row=(inline_col + 1) // 2, column=0, columnspan=2,
                              sticky=tk.W, pady=(2, 0))
                    ttk.Label(tail, text='unlabeled bits:', foreground='gray60'
                              ).pack(side=tk.LEFT, padx=(0, 4))
                    for b in undoc:
                        bv_chk = bit_vars_row[b]
                        cb = ttk.Checkbutton(tail, text=f'b{b}', variable=bv_chk)
                        cb.pack(side=tk.LEFT, padx=(0, 4))
                        def _on_bit_change(*_a, bb=b, chk=bv_chk, byte_idx=byte_idx):
                            if self._suppress_trace:
                                return
                            cur = byte_vars[byte_idx].get()
                            new = (cur | (1 << bb)) if chk.get() else (cur & ~(1 << bb))
                            if new != cur:
                                _set_byte(byte_idx, new)
                        bv_chk.trace_add('write', _on_bit_change)

            # (Bytes with tcrf is None are skipped earlier — no fallback
            # branch is needed here.  Only word_bool / bool / list reach
            # this point.)

            # Per-byte quick-set buttons (skipped for word_bool — binary
            # toggle).
            if not is_word_bool:
                ttk.Button(frame, text='set 00', width=6,
                           command=lambda byte_idx=byte_idx: _set_byte(byte_idx, 0x00)
                           ).grid(row=row, column=12, sticky=tk.W, padx=(8, 1))
                ttk.Button(frame, text='set FF', width=6,
                           command=lambda byte_idx=byte_idx: _set_byte(byte_idx, 0xFF)
                           ).grid(row=row, column=13, sticky=tk.W, padx=1)

        # Whole-bitmap quick-set buttons (row below the byte rows)
        actions = ttk.Frame(frame)
        actions.grid(row=display_row, column=0, columnspan=14, sticky=tk.W, pady=(4, 0))
        ttk.Label(actions, text='whole field:', foreground='gray45').pack(side=tk.LEFT, padx=(0, 6))

        def _fill_all(value: int):
            # Use _set_byte equivalent inline while keeping the update atomic.
            self._suppress_trace = True
            try:
                for i in range(8):
                    byte_vars[i].set(value)
                    string_vars[i].set(f'{value:02X}')
                    for b in range(8):
                        bit_vars_2d[i][b].set((value >> b) & 1)
                _sync_whole_checks([value] * 8)
            finally:
                self._suppress_trace = False
            self._refresh_hex(self._safe_compose())

        ttk.Button(actions, text='clear (all 00)',  command=lambda: _fill_all(0x00)).pack(side=tk.LEFT, padx=2)
        ttk.Button(actions, text='set (all FF)',    command=lambda: _fill_all(0xFF)).pack(side=tk.LEFT, padx=2)
        ttk.Button(actions, text='revert this slot', command=lambda n=name: self._revert_field(n)).pack(side=tk.LEFT, padx=2)

        # Store under field name.  byte_vars is the source of truth for the
        # bytes; string_vars and bit_vars_2d are display-side mirrors that
        # _populate_fields / _revert_field must also keep in sync.
        self.field_vars[name] = (byte_vars, ('bitmap8', base_off),
                                 {'strings': string_vars, 'bits': bit_vars_2d,
                                  'whole_checks': whole_checks})

    def _render_bitfield_byte(self, section, name: str, row: int, bits: list):
        """Render a single byte as: [hex entry] + N named bit checkboxes
        (4 per row), all sync'd via a _set_byte helper.  Used for the
        magic/sword/shield shop inventories and sages_spoken_bitmap bitmap.
        """
        sub = ttk.Frame(section)
        sub.grid(row=row, column=2, columnspan=2, sticky=tk.W)

        byte_var = tk.IntVar(value=0)
        string_var = tk.StringVar(value='00')
        bit_vars = {}  # bit_idx -> IntVar

        def _set_byte(value: int):
            if self._suppress_trace:
                return
            value &= 0xFF
            self._suppress_trace = True
            try:
                byte_var.set(value)
                string_var.set(f'{value:02X}')
                for bit_idx, _ in bits:
                    bit_vars[bit_idx].set((value >> bit_idx) & 1)
            finally:
                self._suppress_trace = False
            self._refresh_hex(self._safe_compose())

        # Hex byte entry
        ent = ttk.Entry(sub, textvariable=string_var, width=4,
                        font=('Consolas', 10), justify=tk.CENTER)
        ent.pack(side=tk.LEFT, padx=(0, 12))

        def _on_string_change(*_a, sv=string_var):
            if self._suppress_trace:
                return
            txt = sv.get().strip()
            if not txt:
                return
            t = txt
            if t.lower().startswith('0x'):
                t = t[2:]
            elif t.lower().endswith('h'):
                t = t[:-1]
            try:
                val = int(t, 16) & 0xFF
            except ValueError:
                return
            _set_byte(val)
        string_var.trace_add('write', _on_string_change)

        # Bit checkboxes — 4 per row, named.
        bit_grid = ttk.Frame(sub)
        bit_grid.pack(side=tk.LEFT)
        for i, (bit_idx, label) in enumerate(bits):
            bv = tk.IntVar(value=0)
            bit_vars[bit_idx] = bv
            cb = ttk.Checkbutton(bit_grid, text=label, variable=bv)
            cb.grid(row=i // 4, column=i % 4, sticky=tk.W, padx=(0, 6))

            def _on_bit(*_a, b=bit_idx, bv=bv):
                if self._suppress_trace:
                    return
                cur = byte_var.get()
                new = (cur | (1 << b)) if bv.get() else (cur & ~(1 << b))
                if new != cur:
                    _set_byte(new)
            bv.trace_add('write', _on_bit)

        # Store under field name with marker so populate/compose can find it.
        self.field_vars[name] = (byte_var, ('bitfield_byte',),
                                 {'string': string_var, 'bits': bit_vars,
                                  'bit_specs': bits})

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
            named_bits = bits_for(name)

            if typ == 'bool':
                bvar = tk.IntVar()
                cb = ttk.Checkbutton(section, variable=bvar,
                                     command=lambda n=name: self._on_field_change(n))
                cb.grid(row=r, column=2, sticky=tk.W)
                self.field_vars[name] = (bvar, typ, None)

            elif named_bits is not None:
                # Bitfield byte with NAMED bits → 1 hex entry + N labeled checkboxes
                self._render_bitfield_byte(section, name, r, named_bits)

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
            # Bitmap8: var_or_list = byte_vars; choices = {'strings', 'bits'}
            if isinstance(typ, tuple) and typ[0] == 'bitmap8':
                base = typ[1]
                self._suppress_trace = True
                try:
                    for i, byte_var in enumerate(var_or_list):
                        v = data[base + i]
                        byte_var.set(v)
                        choices['strings'][i].set(f'{v:02X}')
                        for b in range(8):
                            choices['bits'][i][b].set((v >> b) & 1)
                    for byte_idx, (check_var, span) in \
                            choices.get('whole_checks', {}).items():
                        check_var.set(1 if all(
                            data[base + byte_idx + i] == 0xFF
                            for i in range(span)) else 0)
                finally:
                    self._suppress_trace = False
                continue

            # Bitfield byte (named bits): var_or_list = byte_var (single IntVar);
            # choices = {'string', 'bits' (dict by bit_idx), 'bit_specs'}.
            if isinstance(typ, tuple) and typ[0] == 'bitfield_byte':
                _, off, _, _ = save_edit.lookup(name)
                v = data[off]
                self._suppress_trace = True
                try:
                    var_or_list.set(v)
                    choices['string'].set(f'{v:02X}')
                    for bit_idx, _lbl in choices['bit_specs']:
                        choices['bits'][bit_idx].set((v >> bit_idx) & 1)
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

            if isinstance(typ, tuple) and typ[0] == 'bitfield_byte':
                _, off, _, _ = save_edit.lookup(name)
                out[off] = var_or_list.get() & 0xFF
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
        # Bitmap / bitfield fields manage their own traces internally.
        if isinstance(typ, tuple) and typ[0] in ('bitmap8', 'bitfield_byte'):
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
            self._suppress_trace = True
            try:
                for i, byte_var in enumerate(var):
                    v = self.original_data[base + i]
                    byte_var.set(v)
                    choices['strings'][i].set(f'{v:02X}')
                    for b in range(8):
                        choices['bits'][i][b].set((v >> b) & 1)
                for byte_idx, (check_var, span) in \
                        choices.get('whole_checks', {}).items():
                    check_var.set(1 if all(
                        self.original_data[base + byte_idx + i] == 0xFF
                        for i in range(span)) else 0)
            finally:
                self._suppress_trace = False
            self._refresh_hex(self._safe_compose())
            return

        if isinstance(typ, tuple) and typ[0] == 'bitfield_byte':
            _, off, _, _ = save_edit.lookup(name)
            v = self.original_data[off]
            self._suppress_trace = True
            try:
                var.set(v)
                choices['string'].set(f'{v:02X}')
                for bit_idx, _lbl in choices['bit_specs']:
                    choices['bits'][bit_idx].set((v >> bit_idx) & 1)
            finally:
                self._suppress_trace = False
            self._refresh_hex(self._safe_compose())
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
