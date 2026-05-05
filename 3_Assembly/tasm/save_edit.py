#!/usr/bin/env python3
"""
save_edit.py — Zeliard .USR save game editor.

Decode and modify named fields in a 256-byte .USR save file.  Bytes outside
the named fields are preserved verbatim (icon data, BLK signature, tail
code, unknown regions are all left untouched).

USAGE
-----

  # Inspect a save:
  python save_edit.py bin/Bosque.usr --dump
  python save_edit.py bin/Bosque.usr --get player_HP

  # Edit a single field (writes to <stem>_edit.usr by default):
  python save_edit.py bin/Bosque.usr --set player_HP=999
  python save_edit.py bin/Bosque.usr --set crest_hero=1 --set boss_kill_pollo=1
  python save_edit.py bin/Bosque.usr --set player_gold=50000 -o bin/Rich.usr

  # List all known fields:
  python save_edit.py --fields

VALIDATION WORKFLOW
-------------------

To confirm a name hypothesis (e.g. that 0x47 = Alguien-cleared flag):
  1. python save_edit.py bin/Pureza.usr --set alguien_cleared=1 -o bin/Test.usr
     (or use the raw form: --set @47=ff)
  2. cd 1_OriginalGame; ./zeliad.exe TEST.USR
  3. Observe: does the game treat Alguien as defeated?

FIELD TYPES
-----------
  b   = uint8 (single byte)
  w   = uint16 little-endian
  24  = 24-bit integer with (hi, lo, mid) byte layout (Zeliard gold/bank)
  bool= boolean stored as 0x00 or 0xFF (any non-zero input becomes 0xFF)
  raw= passthrough hex string for arbitrary bytes
"""
import sys
import argparse
import re
from pathlib import Path
from typing import Tuple, Union


# ---------------------------------------------------------------------------
# Field map — single source of truth for save-file layout.
# Keep this synced with stdply.inc EQUs and the per-cavern progression.
# ---------------------------------------------------------------------------

# Each entry: (name, offset, type, description)
FIELDS = [
    # ─── Per-cavern collected-item bitmaps (10 slots × 8 bytes each) ─────
    ('cavern_bits_malicia',  0x00, ('raw', 8), 'Cavern of Malicia (cavern 1) collected-items bitmap'),
    ('cavern_bits_peligro',  0x08, ('raw', 8), 'Cavern of Peligro (cavern 2) collected-items bitmap'),
    ('cavern_bits_riza',     0x10, ('raw', 8), 'Cavern of Riza (cavern 3) collected-items bitmap'),
    ('cavern_bits_glacial',  0x18, ('raw', 8), 'Cavern of Glacial (cavern 4) collected-items bitmap'),
    ('cavern_bits_cementar', 0x20, ('raw', 8), 'Cavern of Cementar (cavern 5) collected-items bitmap'),
    ('cavern_bits_tesoro',   0x28, ('raw', 8), 'Cavern of Tesoro (cavern 6) collected-items bitmap'),
    ('cavern_bits_caliente', 0x30, ('raw', 8), 'Cavern of Caliente (cavern 7, Dragon) collected-items bitmap'),
    ('cavern_bits_slot7',    0x38, ('raw', 8), 'Slot 7 — always zero in observed saves; reserved/unused'),
    ('cavern_bits_absor',    0x40, ('raw', 8), 'Cavern of Absor (cavern 9, Alguien) collected-items + 0x47 = post-Alguien flag (hypothesis)'),
    ('cavern_bits_final',    0x48, ('raw', 8), 'Cavern of Final (cavern 10, Jashiin); 0x48=0xFF observed only in post-Jashiin saves (hypothesis)'),

    # Hypothetical special-boss flags (single bytes within slots 8/9):
    ('alguien_cleared',      0x47, 'bool', 'Hypothesis: post-Alguien flag (last byte of slot 8). 0xFF only in 4 ALMAS-class saves.'),
    ('jashiin_cleared',      0x48, 'bool', 'Hypothesis: post-Jashiin flag (first byte of slot 9). 0xFF only in 4 ALMAS-class saves.'),

    # ─── Player record (0x80..0xC1) ──────────────────────────────────────
    ('map_scroll_col',       0x80, 'w',  'Cavern X scroll column (16-bit)'),
    ('map_scroll_row',       0x82, 'b',  'Cavern Y scroll row'),
    ('town_player_col',      0x83, 'b',  'Player screen column in town (range 0..0x10)'),
    ('fight_player_col',     0x84, 'b',  'Player screen column in fight (range 0..7)'),
    ('player_gold',          0x85, '24', 'Gold on hand (24-bit, hi/lo/mid layout). Spent at shops.'),
    ('player_bank',          0x88, '24', 'Banked gold (24-bit, hi/lo/mid). Stored at bank, withdrawable.'),
    ('player_almas',         0x8B, 'w',  'Almas (16-bit, capped 0xFFFF). Cavern-drop currency, exchanged at bank for gold.'),
    ('item_qty_count',       0x8D, 'b',  'Item quantity counter'),
    ('item_effect_val',      0x8E, 'w',  'Item effect value (16-bit)'),
    ('player_HP',            0x90, 'w',  'Current HP (16-bit). Game caps at 80 by default; storage allows higher.'),
    ('equipped_weapon',      0x92, 'b',  'Equipped weapon idx (1=Training, 2=WiseMan, 3=Spirit, 4=Knight, 5=Illumination, 6=Enchantment, 7=secret)'),
    ('shield_type',          0x93, 'b',  'Equipped shield tier (1..6: Clay/WiseMan/Stone/Honor/Light/Titanium)'),
    ('shield_HP',            0x94, 'w',  'Current shield HP (16-bit)'),
    ('shield_max_HP',        0x96, 'w',  'Shield HP cap (16-bit)'),
    ('player_speed',         0x98, 'b',  'Speed flag (0/1). Possibly "speed-shoes equipped" boolean.'),
    ('player_power',         0x99, 'b',  'Power flag (always 0 in saves). Possibly "cape equipped" boolean.'),
    ('crest_elf',            0x9A, 'bool', 'Elf Crest (set after defeating Paguro in Llama Hut)'),
    ('crest_glory',          0x9B, 'bool', 'Glory Crest (Cementar pickup; consumed by 212ARMRP Tumba shop trade for Knight\'s Sword)'),
    ('crest_hero',           0x9C, 'bool', 'Hero\'s Crest (Cavern of Riza; required to encounter Pollo)'),
    ('weapon_tier_max',      0x9D, 'b',  'Highest weapon ID owned (== weapon-tier cap in inventory; NOT the same as equipped_weapon, which is the SELECTED one).'),
    ('selected_spell',       0x9E, 'b',  'Currently selected spell ID (1=Espada..7=Guerra; only one spell active at a time — game has no spell-slot mechanic).'),
    ('spells_learned_count', 0xA0, 'b',  'Count of spells learned == popcount(spell_known_* @ 0xBB..0xC1).  Cached counter.'),
    # 0xA1..0xA5 — list of WEARABLE IDs in acquisition order (4 shoes + 1 cape).
    # Per playthrough §6.3 + user correction.  ID mapping derived from save
    # data (which wearable is added in which town): 1=Feruza, 2=Pirika,
    # 3=Silkarn, 4=Ruzeria, 5=AsbestosCape; 0=empty.
    ('wear_1',       0xA1, 'b',  '1st wearable acquired (ID: 1=Feruza Shoes, 2=Pirika, 3=Silkarn, 4=Ruzeria, 5=Asbestos Cape; 0=empty)'),
    ('wear_2',       0xA2, 'b',  '2nd wearable acquired'),
    ('wear_3',       0xA3, 'b',  '3rd wearable acquired'),
    ('wear_4',       0xA4, 'b',  '4th wearable acquired'),
    ('wear_5',       0xA5, 'b',  '5th wearable acquired'),
    # 0xA6..0xAA — fixed-position stock counters for the first 5 magic items
    # in playthrough §5.3.1 listing order.  Each byte = stock count (0..8 per
    # §5.3.2 cap).  No "slot" mechanic — each consumable has its own counter.
    ('kenko_stock',          0xA6, 'b',  "Ken'ko Potion stock count (0..8)"),
    ('juuen_stock',          0xA7, 'b',  'Juu-en Fruit stock count (0..8)'),
    ('magia_stock',          0xA8, 'b',  'Magia Stone stock count (0..8)'),
    ('sabre_oil_stock',      0xA9, 'b',  'Sabre Oil stock count (0..8)'),
    ('kioku_stock',          0xAA, 'b',  'Kioku Feather stock count (0..8)'),
    ('weap_dur_cur_1',       0xAB, 'b',  'Weapon durability current — slot 1'),
    ('weap_dur_cur_2',       0xAC, 'b',  'Weapon durability current — slot 2'),
    ('weap_dur_cur_3',       0xAD, 'b',  'Weapon durability current — slot 3'),
    ('weap_dur_cur_4',       0xAE, 'b',  'Weapon durability current — slot 4'),
    ('weap_dur_cur_5',       0xAF, 'b',  'Weapon durability current — slot 5'),
    ('weap_dur_cur_6',       0xB0, 'b',  'Weapon durability current — slot 6'),
    ('weap_dur_cur_7',       0xB1, 'b',  'Weapon durability current — slot 7'),
    ('player_hp_max',        0xB2, 'w',  'HP ceiling (overlays anim_color_lut frame 8; init 80)'),
    ('weap_dur_max_1',       0xB4, 'b',  'Weapon durability max — slot 1'),
    ('weap_dur_max_2',       0xB5, 'b',  'Weapon durability max — slot 2'),
    ('weap_dur_max_3',       0xB6, 'b',  'Weapon durability max — slot 3'),
    ('weap_dur_max_4',       0xB7, 'b',  'Weapon durability max — slot 4'),
    ('weap_dur_max_5',       0xB8, 'b',  'Weapon durability max — slot 5'),
    ('weap_dur_max_6',       0xB9, 'b',  'Weapon durability max — slot 6'),
    ('weap_dur_max_7',       0xBA, 'b',  'Weapon durability max — slot 7'),

    # Spell availability flags (7 spells, taught by Sages — playthrough §6.1).
    # Earlier interpretation as boss_kill_<boss> was wrong: BB-C1 actually
    # tracks SPELL knowledge.  The per-town progression matches because both
    # boss kills and spell learning happen at the same rate (one per town
    # transition).  Distinct from magic_flags (0xA1..0xA5) which is the
    # 5-slot current inventory.  Byte-to-spell mapping pending in-game
    # validation; below uses playthrough §6.1 listing order.
    ('spell_known_espada',   0xBB, 'bool', 'Spell 1: Espada (weak sword throw). Also overlays anim_color_lut frame 17.'),
    ('spell_known_saeta',    0xBC, 'bool', 'Spell 2: Saeta (arrow shot, long range). Useful for breaking walls in Gold Caverns.'),
    ('spell_known_fuego',    0xBD, 'bool', 'Spell 3: Fuego (fire). Useful in Graveyard against red slimes.'),
    ('spell_known_lanzar',   0xBE, 'bool', 'Spell 4: Lanzar (flame jet). Useful against parrot-man in Burning Inferno.'),
    ('spell_known_rascar',   0xBF, 'bool', 'Spell 5: Rascar (falling rocks).'),
    ('spell_known_agua',     0xC0, 'bool', 'Spell 6: Agua (water). Strong vs Burning Inferno enemies.'),
    ('spell_known_guerra',   0xC1, 'bool', 'Spell 7: Guerra (lightning ultimate, massive damage).'),

    # Player flags / hitbox tail:
    ('player_facing',        0xC2, 'b',  'Facing/anim flag bits (87 byte_tests in stdply)'),
    ('boss_intro_flag',      0xC3, 'b',  'Boss intro-side flag (bit 6 from boss data)'),
    ('current_area_id',      0xC4, 'b',  'Current town/area: 0x80 | town_idx (1..8) when in town. Kioku Feather destination.'),
    ('stat_XC5',             0xC5, 'b',  'Always 0x81 in observed saves'),
    ('heal_pulse_count',     0xC6, 'w',  'HP heal-pulse counter (16-bit)'),
    ('player_tileset',       0xC8, 'b',  'Visual tileset index (0..3)'),
    ('key_count',            0xE4, 'b',  'Player\'s collected-key count'),
    ('scene_trans_request',  0xE6, 'b',  'Scene-transition request flag'),
    ('gvar_pose_idx',        0xE7, 'b',  'Player pose state (bit7=mode, low7=pose idx)'),
    ('init_complete_flag',   0xE8, 'b',  'Post-init steady-state flag'),
]

# ---------------------------------------------------------------------------
# Encode / decode a single field
# ---------------------------------------------------------------------------

def field_size(typ) -> int:
    if isinstance(typ, tuple) and typ[0] == 'raw':
        return typ[1]
    return {'b': 1, 'w': 2, '24': 3, 'bool': 1}[typ]


def decode_field(data: bytes, offset: int, typ) -> Union[int, str]:
    if isinstance(typ, tuple) and typ[0] == 'raw':
        return ' '.join(f'{b:02x}' for b in data[offset:offset + typ[1]])
    if typ == 'b':
        return data[offset]
    if typ == 'w':
        return data[offset] | (data[offset + 1] << 8)
    if typ == '24':
        # (hi, lo, mid) layout — see stdply.inc
        hi  = data[offset]
        lo  = data[offset + 1]
        mid = data[offset + 2]
        return (hi << 16) | (mid << 8) | lo
    if typ == 'bool':
        return 1 if data[offset] != 0 else 0
    raise ValueError(f'unknown type {typ}')


def encode_field(typ, value: Union[int, str]) -> bytes:
    if isinstance(typ, tuple) and typ[0] == 'raw':
        n = typ[1]
        # value is a hex string like "ff 00 80 ..."
        if isinstance(value, int):
            raise ValueError('raw fields require a hex string value')
        cleaned = re.sub(r'\s+', '', value)
        if cleaned.startswith('0x'):
            cleaned = cleaned[2:]
        out = bytes.fromhex(cleaned)
        if len(out) != n:
            raise ValueError(f'raw field needs {n} bytes; got {len(out)}')
        return out

    if isinstance(value, str):
        value = parse_int(value)

    if typ == 'b':
        if not 0 <= value <= 0xFF:
            raise ValueError(f'byte out of range: {value}')
        return bytes([value])
    if typ == 'w':
        if not 0 <= value <= 0xFFFF:
            raise ValueError(f'word out of range: {value}')
        return bytes([value & 0xFF, (value >> 8) & 0xFF])
    if typ == '24':
        if not 0 <= value <= 0xFFFFFF:
            raise ValueError(f'24-bit out of range: {value}')
        hi  = (value >> 16) & 0xFF
        mid = (value >> 8)  & 0xFF
        lo  =  value        & 0xFF
        return bytes([hi, lo, mid])
    if typ == 'bool':
        return bytes([0xFF if value else 0x00])
    raise ValueError(f'unknown type {typ}')


def parse_int(s: str) -> int:
    s = s.strip()
    if s.lower() in ('true', 'on', 'yes'):
        return 1
    if s.lower() in ('false', 'off', 'no'):
        return 0
    if s.startswith('0x') or s.startswith('0X'):
        return int(s, 16)
    if s.endswith('h') or s.endswith('H'):
        return int(s[:-1], 16)
    return int(s)


# ---------------------------------------------------------------------------
# Field lookup
# ---------------------------------------------------------------------------

def lookup(name: str) -> Tuple[str, int, str, str]:
    """Find a named field. Raises KeyError if not found."""
    for entry in FIELDS:
        if entry[0] == name:
            return entry
    raise KeyError(f'unknown field: {name}')


def parse_offset(spec: str) -> int:
    """Parse an @hex offset spec like @47 or @0x47."""
    if not spec.startswith('@'):
        raise ValueError(f'expected @<hex>, got {spec!r}')
    return parse_int(spec[1:] if spec[1:].startswith('0x') else '0x' + spec[1:])


# ---------------------------------------------------------------------------
# Modes
# ---------------------------------------------------------------------------

def cmd_dump(data: bytes) -> int:
    if len(data) != 256:
        print(f'WARNING: save is {len(data)} bytes, expected 256')

    print(f'{"field":<24} {"offset":<8} {"type":<6} {"value":<20} description')
    print('-' * 100)
    for name, off, typ, desc in FIELDS:
        try:
            val = decode_field(data, off, typ)
        except IndexError:
            val = '<short>'
        if isinstance(typ, tuple):
            tdesc = f'raw{typ[1]}'
        else:
            tdesc = typ
        if isinstance(val, int):
            if typ == 'bool':
                vstr = 'set' if val else 'clear'
            elif typ == '24':
                vstr = f'{val:7d} (0x{val:06x})'
            elif typ == 'w':
                vstr = f'{val:5d} (0x{val:04x})'
            else:
                vstr = f'{val:3d} (0x{val:02x})'
        else:
            vstr = str(val)
        print(f'{name:<24} 0x{off:02x}    {tdesc:<6} {vstr:<20} {desc}')
    return 0


def cmd_get(data: bytes, name: str) -> int:
    if name.startswith('@'):
        off = parse_offset(name)
        if off >= len(data):
            print(f'offset 0x{off:02x} out of range')
            return 1
        print(f'@{off:02x} = 0x{data[off]:02x} ({data[off]})')
        return 0
    try:
        _, off, typ, _ = lookup(name)
    except KeyError as e:
        print(str(e))
        return 1
    val = decode_field(data, off, typ)
    if isinstance(val, int):
        print(f'{name} (0x{off:02x}, {typ}) = {val} (0x{val:x})')
    else:
        print(f'{name} (0x{off:02x}, {typ}) = {val}')
    return 0


def cmd_set(data: bytes, assignments: list) -> bytes:
    """Apply a list of 'name=value' assignments and return modified bytes."""
    out = bytearray(data)
    for assign in assignments:
        if '=' not in assign:
            raise ValueError(f'expected name=value, got {assign!r}')
        name, value = assign.split('=', 1)
        name = name.strip()
        value = value.strip()
        if name.startswith('@'):
            off = parse_offset(name)
            v = parse_int(value)
            if not 0 <= v <= 0xFF:
                raise ValueError(f'byte value out of range at {name}: {value}')
            out[off] = v
            print(f'  set @{off:02x} = 0x{v:02x}')
        else:
            try:
                _, off, typ, _ = lookup(name)
            except KeyError:
                raise ValueError(f'unknown field: {name}')
            encoded = encode_field(typ, value)
            out[off:off + len(encoded)] = encoded
            print(f'  set {name} (0x{off:02x}) = {value}')
    return bytes(out)


def cmd_list_fields() -> int:
    print(f'{"field":<24} {"offset":<8} {"type":<6} description')
    print('-' * 100)
    for name, off, typ, desc in FIELDS:
        if isinstance(typ, tuple):
            tdesc = f'raw{typ[1]}'
        else:
            tdesc = typ
        print(f'{name:<24} 0x{off:02x}    {tdesc:<6} {desc}')
    return 0


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(
        description='Zeliard save game editor',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    ap.add_argument('save', nargs='?', help='input .USR save file')
    ap.add_argument('--dump', action='store_true', help='show all decoded fields')
    ap.add_argument('--get',  metavar='FIELD', help='print one named field')
    ap.add_argument('--set',  metavar='NAME=VAL', action='append', default=[],
                    help='set field (repeatable). Use @47 for raw byte offsets.')
    ap.add_argument('-o', '--output', metavar='PATH',
                    help='output path (default: <stem>_edit.usr next to source)')
    ap.add_argument('--fields', action='store_true', help='list all known fields and exit')

    args = ap.parse_args()

    if args.fields:
        return cmd_list_fields()

    if not args.save:
        ap.error('save file required (or use --fields)')

    src = Path(args.save)
    if not src.exists():
        print(f'not found: {src}')
        return 1
    data = src.read_bytes()

    if args.dump:
        return cmd_dump(data)

    if args.get:
        return cmd_get(data, args.get)

    if args.set:
        new_data = cmd_set(data, args.set)
        if new_data == data:
            print('(no changes)')
            return 0
        out = Path(args.output) if args.output else src.with_name(src.stem + '_edit.usr')
        out.write_bytes(new_data)
        print(f'written: {out} ({len(new_data)} bytes)')
        return 0

    ap.print_help()
    return 0


if __name__ == '__main__':
    sys.exit(main())
