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
    # ─── Dungeon and town event handlers (TCRF 0x00..0x4F) ───────────────
    # Each 8-byte slot is named after the BOSS gating that region (since each
    # main boss has a 16-bit "defeated" word at the start of the slot).  The
    # slot covers everything TCRF documents in that range, not just one
    # cavern — see EVENT_BITS in save_editor_gui.py for the per-byte map.
    ('cavern_bits_cangrejo',       0x00, ('raw', 8), 'Cangrejo region (TCRF 0x00..0x07): Cangrejo defeated word + Cavern of Malicia bits + Spoke-King + Entered-Caverns first time'),
    ('cavern_bits_pulpo',          0x08, ('raw', 8), 'Pulpo region (TCRF 0x08..0x0F): Pulpo defeated word + Cavern of Peligro bits (#1, #2)'),
    ('cavern_bits_pollo',          0x10, ('raw', 8), 'Pollo region (TCRF 0x10..0x17): Pollo defeated word + Cavern of Madera + Cavern of Riza bits'),
    ('cavern_bits_agar',           0x18, ('raw', 8), 'Agar region (TCRF 0x18..0x1F): Agar defeated word + Cavern of Glacial + Cavern of Escarcha (#1, #2) bits'),
    ('cavern_bits_vista',          0x20, ('raw', 8), 'Vista region (TCRF 0x20..0x27): Vista defeated word + Cavern of Corroer + Cavern of Cementar (#1, #2) bits'),
    ('cavern_bits_tarso',          0x28, ('raw', 8), 'Tarso region (TCRF 0x28..0x2F): Tarso defeated word + Cavern of Tesoro + Cavern of Plata (#1, #2, #3) bits — also covers Arrugia secret'),
    ('cavern_bits_paguro_dragon',  0x30, ('raw', 8), 'Paguro/Dragon region (TCRF 0x30..0x37): Paguro defeated word + Dragon defeated word + Cavern of Caliente (#1, #2, #3) bits'),
    # 0x38..0x3F and 0x48..0x4F: TCRF says "Unknown (all 00 in normal play)";
    # confirmed all-zero across all 17 sample saves.  No UI field — bytes are
    # preserved verbatim through compose_bytes (untouched memory).
    ('cavern_bits_alguien',        0x40, ('raw', 8), 'Alguien region (TCRF 0x40..0x47): Cavern of Absor + Cavern of Milagro + Cavern of Desleal + Cavern of Falter/Final bits.  Gates Alguien path.  TCRF documents 0x42..0x45 only; 0x40, 0x41, 0x46, 0x47 listed as Unknown.'),

    # ─── Player record (0x80..0xC1) ──────────────────────────────────────
    # 0x80 / 0x81: TCRF says 0x80 is "starting position in town" (1 byte; tile
    # coord, per-town max table) and 0x81 is "do not edit, any non-00 value
    # crashes the game".  Asm code in 200FIGHT.asm reads [80h] as a 16-bit
    # cavern X scroll word (54 word-ptr refs); stdply.inc names it map_scroll_col.
    # Same byte, two lenses: save-file (TCRF) vs runtime (asm).  We expose them
    # as separate single-byte fields so the editor matches the save-file view
    # AND the user can't accidentally write a non-00 value into 0x81.
    # 0x80..0x84: asm-canonical names (matching stdply.inc) since the asm
    # has stronger evidence (54 word refs at [80h], 19 byte refs at [82h],
    # functest-validated 0x83/0x84 counters) than TCRF's "unknown"/"start
    # pos" labels.  TCRF aliases (start_pos_in_town, stat_X81/82/84) live
    # in stdply.inc for save-format consumers.
    ('map_scroll_col',       0x80, 'b',  'Cavern X scroll column (asm: 16-bit word at 0x80..0x81; save: only low byte ever non-zero).  TCRF: "starting position in town" (per-town tile-coord max table); the runtime semantic is the cavern-engine scroll register.  Same byte, two lenses.'),
    # 0x81: high byte of the 16-bit cavern X scroll word; always 00 in saves.
    # TCRF warns any non-00 value crashes the game.  Not exposed in the
    # editor — preserved verbatim through compose_bytes.
    ('map_scroll_row',       0x82, 'b',  'Cavern Y scroll row (asm: 19 byte refs in 200FIGHT scroll routines).'),
    ('town_player_col',      0x83, 'b',  'Player screen column in town (range 0..0x10; 0x0D = center, >0x1A can crash).  Values depend on 0x80.'),
    ('fight_player_col',     0x84, 'b',  'Player screen column in fight (independent counter in 200FIGHT, range 0..7; functest-validated).'),
    ('player_gold',          0x85, '24', 'Gold on hand (24-bit, hi/lo/mid layout). Spent at shops.'),
    ('player_bank',          0x88, '24', 'Banked gold (24-bit, hi/lo/mid). Stored at bank, withdrawable.'),
    ('player_almas',         0x8B, 'w',  'Almas (16-bit, capped 0xFFFF). Cavern-drop currency, exchanged at bank for gold.'),
    ('hero_level',           0x8D, 'b',  'Hero level 0..FF — affects bonus damage in DOS version (TCRF).'),
    ('experience',           0x8E, 'w',  'Experience points (16-bit LE; TCRF).'),
    ('player_HP',            0x90, 'w',  'Current HP (16-bit).  Decreases on damage, increases on healing.  Capped by player_hp_max at 0xB2.  Initial 80 at game start; cap grows when the player crosses XP milestones at sages (217KENJP.asm:512-514 sets [B2h]=new max and [90h]=new max in one shot — full heal at the blessing).'),
    ('equipped_weapon',      0x92, 'b',  'Equipped weapon idx (1=Training, 2=WiseMan, 3=Spirit, 4=Knight, 5=Illumination, 6=Enchantment, 7=secret)'),
    ('shield_type',          0x93, 'b',  'Equipped shield tier (1..6: Clay/WiseMan/Stone/Honor/Light/Titanium)'),
    ('shield_HP',            0x94, 'w',  'Current shield HP (16-bit)'),
    ('shield_max_HP',        0x96, 'w',  'Shield HP cap (16-bit)'),
    ('keys_normal',          0x98, 'b',  'Normal key count.  >9 carryable but only 1 digit shown in HUD (TCRF).'),
    ('keys_lion',            0x99, 'b',  "Lion's Head Key count.  Opens special doors in Cavern of Tesoro and Cavern of Final (TCRF)."),
    ('crest_elf',            0x9A, 'bool', 'Elf Crest (00=No, FF=Yes).  TCRF emphasises this DOES NOT trigger Llama Town NPC dialog — that gate is the Paguro-defeated word at 0x30..0x31.  Set as a side-effect of beating Paguro, but not what the NPCs check.'),
    ('crest_glory',          0x9B, 'bool', 'Glory Crest (Cementar pickup; consumed by 212ARMRP Tumba shop trade for Knight\'s Sword)'),
    ('crest_hero',           0x9C, 'bool', "Hero's Crest in inventory (00=No, FF=Yes).  TCRF: this is NOT the gate for the crazy guard in Bosque — that gate is 0x12 bit 3 (\"Hero's Crest collected\" event flag).  This 0x9C byte is just the inventory marker."),
    ('selected_spell',       0x9D, 'b',  'Currently selected spell ID (1=Espada..7=Guerra; only one spell active at a time — user-confirmed at 0x9D, NOT 0x9E).'),
    ('selected_wearable',    0x9E, 'b',  'Currently selected wearable ID (0=none, 1=Feruza, 2=Pirika, 3=Silkarn, 4=Ruzeria, 5=Asbestos Cape).  User-confirmed: byte holds the item ID directly.'),
    ('tears_of_esmesanti_count', 0xA0, 'b',  'Tears of Esmesanti collected (0..9).  Each main cavern hides one Tear; collecting all is the win condition (TCRF).'),
    # 0xA1..0xA5 — list of WEARABLE IDs in acquisition order (4 shoes + 1 cape).
    # Per playthrough §6.3 + user correction.  ID mapping derived from save
    # data (which wearable is added in which town): 1=Feruza, 2=Pirika,
    # 3=Silkarn, 4=Ruzeria, 5=AsbestosCape; 0=empty.
    ('wear_1',       0xA1, 'b',  '1st wearable acquired (ID: 1=Feruza Shoes, 2=Pirika, 3=Silkarn, 4=Ruzeria, 5=Asbestos Cape; 0=empty)'),
    ('wear_2',       0xA2, 'b',  '2nd wearable acquired'),
    ('wear_3',       0xA3, 'b',  '3rd wearable acquired'),
    ('wear_4',       0xA4, 'b',  '4th wearable acquired'),
    ('wear_5',       0xA5, 'b',  '5th wearable acquired'),
    # 0xA6..0xAA — 5 ITEM INVENTORY SLOTS.  Each byte holds the ID of the item
    # placed in that slot (0 = empty; otherwise item ID 1..8 per playthrough
    # §5.3.1).  Same item ID can appear in multiple slots (Helada save shows
    # 5,5,5,5,0 = four Magia Stones in four slots).  Items HAVE slots in the
    # game (unlike spells, which have a single selected_spell).
    ('item_slot_1',          0xA6, 'b',  'Inventory slot 1 (0=empty; ID: 1=Kenko 2=Juuen 3=Elixir 4=Chikara 5=Magia 6=HolyWater 7=SabreOil 8=Kioku)'),
    ('item_slot_2',          0xA7, 'b',  'Inventory slot 2 (same ID enum)'),
    ('item_slot_3',          0xA8, 'b',  'Inventory slot 3'),
    ('item_slot_4',          0xA9, 'b',  'Inventory slot 4'),
    ('item_slot_5',          0xAA, 'b',  'Inventory slot 5'),
    # 0xAB..0xB1 = current spell charges (one byte per spell, in §6.1 order).
    ('charges_espada',       0xAB, 'b',  'Espada charges remaining (default 0Ch = 12)'),
    ('charges_saeta',        0xAC, 'b',  'Saeta charges remaining (default 06h)'),
    ('charges_fuego',        0xAD, 'b',  'Fuego charges remaining (default 08h)'),
    ('charges_lanzar',       0xAE, 'b',  'Lanzar charges remaining (default 04h)'),
    ('charges_rascar',       0xAF, 'b',  'Rascar charges remaining (default 03h)'),
    ('charges_agua',         0xB0, 'b',  'Agua charges remaining (default 04h)'),
    ('charges_guerra',       0xB1, 'b',  'Guerra charges remaining (default 03h)'),
    ('player_hp_max',        0xB2, 'w',  'Max HP / LIFE cap (16-bit).  Initial 80 (per manual).  Grows when sages grant a blessing at XP milestones — see 217KENJP.asm:505-514 (also increments hero_level at 0x8D and refills spell charges at 0xAB-0xB1, and heals current HP at 0x90 to the new cap).  Cross-save: Muralla 200, Helada 460, Pureza 680, Esco 800 — cap roughly doubles per major story step.'),
    # 0xB4..0xBA = max spell charges (cap; refilled by sage).
    # NB: TCRF text labels both 0xAB..B1 and 0xB4..BA as "Spell Count
    # (Remaining Spells)" with identical defaults — the wiki doesn't
    # disambiguate.  We split into current vs max because that's what the
    # in-game refill behaviour requires (you can spend charges down toward
    # 0; the sage refills back to a saved cap).  Defaults match 0xAB..B1.
    ('charges_max_espada',   0xB4, 'b',  'Espada max charges (cap; default 0Ch).  TCRF labels this "Remaining Spells" again — same wording as 0xAB..B1; we infer it is the cap.'),
    ('charges_max_saeta',    0xB5, 'b',  'Saeta max charges (cap; default 06h).'),
    ('charges_max_fuego',    0xB6, 'b',  'Fuego max charges (cap; default 08h).'),
    ('charges_max_lanzar',   0xB7, 'b',  'Lanzar max charges (cap; default 04h).'),
    ('charges_max_rascar',   0xB8, 'b',  'Rascar max charges (cap; default 03h).'),
    ('charges_max_agua',     0xB9, 'b',  'Agua max charges (cap; default 04h).'),
    ('charges_max_guerra',   0xBA, 'b',  'Guerra max charges (cap; default 03h).'),

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

    # Player flags / hitbox tail.  Names below match stdply.inc canonical
    # symbols where the asm has runtime evidence (readers in cleaned source).
    # TCRF-side context kept in descriptions for save-format users.
    ('player_facing',        0xC2, 'b',  'Player facing/anim flags (asm: 87 byte_tests — most-tested byte).  Direction on respawn: 00,02=Right; 01,03=Left.'),
    ('boss_intro_flag',      0xC3, 'b',  'Boss intro-side flag (asm: 200FIGHT line 4068 sets it as `[si+3] & 40h` from boss-init data; tested in `check_c3` line 4153).'),
    ('save_sage',            0xC4, 'b',  'Sage where game was saved (0x80=Castle, 0x81=Muralla..0x89=Esco).  HIGH BIT MUST BE SET or game crashes.'),
    ('last_sage_visited',    0xC5, 'b',  "Last sage visited (Kioku Feather destination).  DOS version doesn't update on save, so always Muralla (0x81)."),
    ('heal_pulse_count',     0xC6, 'w',  'HP heal-pulse counter (asm: 200FIGHT line 2806; +8 HP/tick while non-zero, clamped to player_hp_max; 16-bit at 0xC6..0xC7).'),
    ('current_level_idx',    0xC8, 'b',  "Current level/cavern chunk index (0..31).  Drives bg + music + sprite + tileset + map chunk loading via an 11-byte-per-entry chunk-ref table.  game.asm:407-409 derives this from save_data_base via `(byte >> 1) & 0x1F`; 200FIGHT.asm:4281 uses the same byte AS the music_track_id directly.  Distinct from save_sage at 0xC4 (which tracks sage-town for Kioku Feather)."),
    # 0xC9..0xD1 — magic shop inventory per town (bitfield).
    ('shop_magic_muralla',   0xC9, 'b',  "Magic shop stock at Muralla (default 8A; bitfield: +128=Ken'ko +64=Juu-en +32=Elixir +16=Chikara +8=Magia +4=HolyWater +2=SabreOil +1=Kioku; FF=full)."),
    ('shop_magic_satono',    0xCA, 'b',  'Magic shop stock at Satono (default A6).'),
    ('shop_magic_bosque',    0xCB, 'b',  'Magic shop stock at Bosque (default 6B).'),
    ('shop_magic_helada',    0xCC, 'b',  'Magic shop stock at Helada (default 75).'),
    ('shop_magic_tumba',     0xCD, 'b',  'Magic shop stock at Tumba (default 42).'),
    ('shop_magic_dorado',    0xCE, 'b',  'Magic shop stock at Dorado (default 4C).'),
    ('shop_magic_llama',     0xCF, 'b',  'Magic shop stock at Llama (default 4B).'),
    ('shop_magic_pureza',    0xD0, 'b',  'Magic shop stock at Pureza (default 01).'),
    ('shop_magic_esco',      0xD1, 'b',  'Magic shop stock at Esco (default FF).'),
    # 0xD2..0xDA — weapon shop sword inventory per town.
    ('shop_sword_muralla',   0xD2, 'b',  'Sword stock at Muralla (default C0; bitfield: +128=Training +64=WiseMan +32=Spirit +16=Knight +8=Illumination +4=Enchantment).'),
    ('shop_sword_satono',    0xD3, 'b',  'Sword stock at Satono (default C0).'),
    ('shop_sword_bosque',    0xD4, 'b',  'Sword stock at Bosque (default E0).'),
    ('shop_sword_helada',    0xD5, 'b',  'Sword stock at Helada (default E0).'),
    ('shop_sword_tumba',     0xD6, 'b',  "Sword stock at Tumba (default 70).  Glory Crest trade reduces by 16 (gives Knight's Sword)."),
    ('shop_sword_dorado',    0xD7, 'b',  'Sword stock at Dorado (default 38).'),
    ('shop_sword_llama',     0xD8, 'b',  'Sword stock at Llama (default 38).'),
    ('shop_sword_pureza',    0xD9, 'b',  'Sword stock at Pureza (default F8).'),
    ('shop_sword_esco',      0xDA, 'b',  'Sword stock at Esco (default F8; FC includes Enchantment).'),
    # 0xDB..0xE3 — weapon shop shield inventory per town.
    ('shop_shield_muralla',  0xDB, 'b',  'Shield stock at Muralla (default C0; bitfield: +128=Clay +64=WiseMan +32=Stone +16=Honor +8=Light +4=Titanium).'),
    ('shop_shield_satono',   0xDC, 'b',  'Shield stock at Satono (default E0).'),
    ('shop_shield_bosque',   0xDD, 'b',  'Shield stock at Bosque (default E0).'),
    ('shop_shield_helada',   0xDE, 'b',  'Shield stock at Helada (default 70).'),
    ('shop_shield_tumba',    0xDF, 'b',  'Shield stock at Tumba (default 30).'),
    ('shop_shield_dorado',   0xE0, 'b',  'Shield stock at Dorado (default 38).'),
    ('shop_shield_llama',    0xE1, 'b',  'Shield stock at Llama (default 1C).'),
    ('shop_shield_pureza',   0xE2, 'b',  'Shield stock at Pureza (default 1C).'),
    ('shop_shield_esco',     0xE3, 'b',  'Shield stock at Esco (default FC).'),
    ('key_count',            0xE4, 'b',  "Player's collected-key count (asm: 11 readers; 201SELCT inc + test + read)."),
    ('sages_spoken',         0xE5, 'b',  'Sages spoken-with bitmap (+128=Muralla +64=Satono +32=Bosque +16=Helada +8=Tumba +4=Dorado +2=Llama +1=Pureza).'),
    ('scene_trans_request',  0xE6, 'b',  'Scene-transition request flag (asm: 200FIGHT main_loop_body line 712 polls `test [E6h], 0FFh; jnz scene_transition`; 6 readers).'),
    ('gvar_pose_idx',        0xE7, 'b',  'Player pose state (asm: 85 readers — most-accessed byte in stdply chunk; bit7=mode flag, low7=pose index).'),
    ('init_complete_flag',   0xE8, 'b',  'Post-init steady-state flag (asm: 30 readers; set to 0xFF after first frame init; cleared on area_load_flag).'),
    # 0xE9..0xFF (23 bytes): uninitialized memory gap between stdply.bin
    # (233 bytes, ends at 0xE8) and stick.bin (loads at game_seg:0x0100).
    # The save routine (217KENJP.asm:1181) writes 256 bytes from game_seg:0
    # verbatim, so the gap is captured but has no gameplay meaning.  Not
    # exposed in the editor — bytes are still preserved through compose_bytes
    # because the editor starts from a bytearray copy of the original_data
    # and only overwrites mapped fields.
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
