#!/usr/bin/env python3
"""
save_decode.py — decode .USR save files using the player-record EQU map.

Save file layout (empirically determined from 17 saves):
  0x00..0x4F   mystery flag header (per-cavern/per-area progression bitmaps?)
  0x50..0x7F   zero padding
  0x80..0xC1   PLAYER RECORD (matches stdply.inc EQUs at the same offsets)
  0xC2..0xCF   trailer + 'BLK' signature
  0xD0..0xE3   constant sprite/icon data
  0xE4..0xFF   tail x86 code (save-format machinery)

This tool prints a per-save table with named fields for the player record,
plus a separate report for the mystery flag header.
"""
from pathlib import Path
import sys

SAVE_DIR = Path(__file__).parent / "bin"


# Player record fields (offset, name, format) — copied from stdply.inc
# format: 'b' = 1-byte unsigned, 'w' = 2-byte LE word, '24' = 3-byte 24-bit LE
PLAYER_RECORD = [
    (0x80, "map_scroll_col",  "w"),
    (0x82, "map_scroll_row",  "b"),
    (0x83, "town_player_col", "b"),
    (0x84, "fight_player_col","b"),
    (0x85, "player_gold",     "24"),  # 3 bytes
    (0x88, "player_bank",     "24"),  # 3 bytes (88 hi + 89/8A lo word)
    (0x8B, "player_almas",    "w"),
    (0x8D, "item_qty_count",  "b"),
    (0x8E, "item_effect_val", "w"),
    (0x90, "player_HP",       "w"),
    (0x92, "equipped_weapon", "b"),
    (0x93, "shield_type",     "b"),
    (0x94, "shield_HP",       "w"),
    (0x96, "shield_max_HP",   "w"),
    (0x98, "player_speed",    "b"),
    (0x99, "player_power",    "b"),
    (0x9A, "player_ability_1","b"),
    (0x9B, "player_ability_2","b"),
    (0x9C, "player_ability_3","b"),
    (0x9D, "weapon_tier_max", "b"),    # was: cur_weapon_idx (highest owned, NOT equipped)
    (0x9E, "selected_spell",  "b"),    # was: cur_magic_idx (only one spell active)
    (0x9F, "stat_X9F",        "b"),
    (0xA0, "spells_learned_count", "b"),  # was: music_track_count (== popcount of spell_known_*)
    (0xA1, "wear_list",       "5b"),   # was: magic_flags — 4 shoes + 1 cape, list of acquired IDs (user-named "wear_*")
    (0xA6, "item_slots",      "5b"),   # 5 inventory slots; each byte = item ID 0..8 (multiple of same allowed)
    (0xAB, "weap_dur_cur",    "7b"),  # 7-byte durability table
    (0xB2, "player_hp_max",   "w"),
    (0xB4, "weap_dur_max",    "7b"),  # 7-byte durability max table
    # Spell availability flags (7 spells, playthrough §6.1).  User-corrected
    # from earlier boss_kill_<boss> interpretation: BB-C1 tracks spells
    # taught by sages, not boss kills (both progress at one per town
    # transition, so the per-save fill pattern was ambiguous).
    (0xBB, "spell_known_espada", "b"),  # spell 1: weak sword throw
    (0xBC, "spell_known_saeta",  "b"),  # spell 2: arrow shot
    (0xBD, "spell_known_fuego",  "b"),  # spell 3: fire
    (0xBE, "spell_known_lanzar", "b"),  # spell 4: flame jet
    (0xBF, "spell_known_rascar", "b"),  # spell 5: falling rocks
    (0xC0, "spell_known_agua",   "b"),  # spell 6: water
    (0xC1, "spell_known_guerra", "b"),  # spell 7: lightning ult
]


def load_saves():
    return {p.stem: p.read_bytes() for p in sorted(SAVE_DIR.glob("*.[Uu][Ss][Rr]"))}


def read_field(data, offset, fmt):
    if fmt == "b":
        return data[offset]
    if fmt == "w":
        return data[offset] | (data[offset + 1] << 8)
    if fmt == "24":
        # Layout per stdply.inc: byte[0]=hi, byte[1]=lo (low byte of low word),
        # byte[2]=mid (high byte of low word).  So:
        #   value = (hi << 16) | (mid << 8) | lo
        hi  = data[offset]
        lo  = data[offset + 1]
        mid = data[offset + 2]
        return (hi << 16) | (mid << 8) | lo
    if fmt.endswith("b"):
        n = int(fmt[:-1])
        return tuple(data[offset:offset + n])
    raise ValueError(f"unknown format {fmt}")


def fmt_value(v, fmt):
    if isinstance(v, tuple):
        return " ".join(f"{x:02x}" for x in v)
    if fmt == "b":
        return f"{v:3d} (0x{v:02x})"
    if fmt == "w":
        return f"{v:5d} (0x{v:04x})"
    if fmt == "24":
        return f"{v:8d} (0x{v:06x})"
    return str(v)


def decode_player_record(saves):
    print("=== PLAYER RECORD (save offset 0x80..0xC1 = stdply.inc EQUs) ===")
    print()
    # Print as a table: rows = fields, columns = saves
    save_names = sorted(saves.keys())
    # Header
    name_width = max(len(n) for n in save_names) + 2
    field_width = max(len(name) for _, name, _ in PLAYER_RECORD) + 4
    print(f"{'field':<{field_width}}", end="")
    for s in save_names:
        print(f"{s:<{name_width}}", end="")
    print()
    print("-" * (field_width + name_width * len(save_names)))

    for offset, name, fmt in PLAYER_RECORD:
        # Compute all values
        vals = {s: read_field(d, offset, fmt) for s, d in saves.items()}
        # Find unique values to highlight constant fields
        uniq = set(vals.values())
        marker = "  " if len(uniq) == 1 else "* "  # * = varies
        print(f"{marker}{name:<{field_width - 2}}", end="")
        for s in save_names:
            v = vals[s]
            if isinstance(v, tuple):
                txt = " ".join(f"{x:02x}" for x in v)
            elif fmt == "b":
                txt = f"{v:3d}"
            elif fmt == "w":
                txt = f"{v:5d}"
            elif fmt == "24":
                txt = f"{v:7d}"
            else:
                txt = str(v)
            print(f"{txt:<{name_width}}", end="")
        print()
    print()


def decode_mystery_header(saves):
    print("=== MYSTERY FLAG HEADER (save offset 0x00..0x4F) ===")
    print("(Likely per-cavern/per-area progression flags. Values shown as hex bytes;")
    print(" '.' = same as Muralla baseline, 'X' = different from Muralla.)")
    print()

    save_names = sorted(saves.keys())
    if "Muralla" not in saves:
        baseline_name = save_names[0]
    else:
        baseline_name = "Muralla"
    baseline = saves[baseline_name]

    print(f"Baseline: {baseline_name}")
    print()

    # Identify offsets in 0x00..0x4F that vary
    varying_offsets = []
    for off in range(0x50):
        vals = {s: d[off] for s, d in saves.items()}
        if len(set(vals.values())) > 1:
            varying_offsets.append(off)

    if not varying_offsets:
        print("(no varying bytes in header)")
        return

    # Table: row = save, col = varying offset
    name_width = max(len(n) for n in save_names) + 2
    print(f"{'save':<{name_width}}", end="")
    for off in varying_offsets:
        print(f"{off:02x} ", end="")
    print()
    print("-" * (name_width + 3 * len(varying_offsets)))

    for s in save_names:
        d = saves[s]
        print(f"{s:<{name_width}}", end="")
        for off in varying_offsets:
            print(f"{d[off]:02x} ", end="")
        print()
    print()


def decode_byte_46_4F(saves):
    """Special focus on bytes 0x46..0x4F which look like a save-name string."""
    print("=== Save-name-ish region (0x46..0x4F) — ASCII view ===")
    save_names = sorted(saves.keys())
    name_width = max(len(n) for n in save_names) + 2
    for s in save_names:
        d = saves[s]
        chunk = d[0x46:0x50]
        ascii_repr = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
        hex_repr = " ".join(f"{b:02x}" for b in chunk)
        print(f"{s:<{name_width}}{hex_repr}  |{ascii_repr}|")
    print()


def main():
    saves = load_saves()
    if not saves:
        print(f"No save files in {SAVE_DIR}")
        return 1

    decode_player_record(saves)
    decode_mystery_header(saves)
    decode_byte_46_4F(saves)
    return 0


if __name__ == "__main__":
    sys.exit(main())
