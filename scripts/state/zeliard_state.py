#!/usr/bin/env python3
"""Canonical Zeliard .USR fixtures and semantic state comparison.

Offsets are resolved from the MASM ``stdply.inc`` file on every run.  The
tables below only add serialization widths, legal boundaries, and names for
the progression bits which MASM stores in the first 0x50 bytes.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[2]
STDPly_INC = ROOT / "3_Assembly/masm/working/drivers/stdply.inc"
STDPly_BIN = ROOT / "3_Assembly/masm/working/drivers/stdply.bin"
RECORD_SIZE = 0x100


@dataclass(frozen=True)
class Field:
    name: str
    kind: str
    offset: int
    minimum: int = 0
    maximum: int = 0xFF

    @property
    def width(self) -> int:
        return {"u8": 1, "bool": 1, "u16": 2, "u24": 3}[self.kind]


# name, kind, inclusive minimum, inclusive maximum.  Offsets come only from
# stdply.inc.  Aliases are deliberately omitted.
FIELD_RULES = (
    ("starting_position_in_town", "u8", 0, 0xFF),
    ("map_scroll_row", "u8", 0, 0xFF),
    ("screen_position", "u8", 0, 0x1A),
    # The shipped stdply.bin initializes this to 0x0A.  Runtime fight code
    # later normalizes it for a specific map, so save fixtures must permit it.
    ("fight_player_col", "u8", 0, 0xFF),
    ("gold_carried_x65536", "u24", 0, 0xFFFFFF),
    ("gold_in_bank_x65536", "u24", 0, 0xFFFFFF),
    ("player_almas", "u16", 0, 0xFFFF),
    ("hero_level", "u8", 0, 0xFF),
    ("experience", "u16", 0, 0xFFFF),
    ("player_HP", "u16", 0, 0xFFFF),
    ("sword", "u8", 0, 7),
    ("shield", "u8", 0, 6),
    ("shield_HP", "u16", 0, 0xFFFF),
    ("shield_max_HP", "u16", 0, 0xFFFF),
    ("keys_normal", "u8", 0, 0xFF),
    ("keys_lion", "u8", 0, 0xFF),
    ("crest_elf", "bool", 0, 0xFF),
    ("crest_glory", "bool", 0, 0xFF),
    ("crest_hero", "bool", 0, 0xFF),
    ("selected_spell", "u8", 0, 7),
    ("selected_accessory", "u8", 0, 5),
    ("tears_of_esmesanti_count", "u8", 0, 9),
    *((f"accessory_slot_{n}", "u8", 0, 5) for n in range(1, 6)),
    *((f"item_slot_{n}", "u8", 0, 8) for n in range(1, 6)),
    ("spell_charge_espada", "u8", 0, 0xFF),
    ("spell_charge_saeta", "u8", 0, 0xFF),
    ("spell_charge_fuego", "u8", 0, 0xFF),
    ("spell_charge_lanzar", "u8", 0, 0xFF),
    ("spell_charge_rascar", "u8", 0, 0xFF),
    ("spell_charge_agua", "u8", 0, 0xFF),
    ("spell_charge_guerra", "u8", 0, 0xFF),
    ("player_hp_max", "u16", 1, 0xFFFF),
    ("spell_charge_max_espada", "u8", 0, 0xFF),
    ("spell_charge_max_saeta", "u8", 0, 0xFF),
    ("spell_charge_max_fuego", "u8", 0, 0xFF),
    ("spell_charge_max_lanzar", "u8", 0, 0xFF),
    ("spell_charge_max_rascar", "u8", 0, 0xFF),
    ("spell_charge_max_agua", "u8", 0, 0xFF),
    ("spell_charge_max_guerra", "u8", 0, 0xFF),
    ("spell_known_espada", "bool", 0, 0xFF),
    ("spell_known_saeta", "bool", 0, 0xFF),
    ("spell_known_fuego", "bool", 0, 0xFF),
    ("spell_known_lanzar", "bool", 0, 0xFF),
    ("spell_known_rascar", "bool", 0, 0xFF),
    ("spell_known_agua", "bool", 0, 0xFF),
    ("spell_known_guerra", "bool", 0, 0xFF),
    ("facing_direction", "u8", 0, 0xFF),
    ("boss_intro_flag", "u8", 0, 0xFF),
    ("save_sage", "u8", 0x80, 0x89),
    ("last_sage_visited", "u8", 0x80, 0x89),
    ("heal_pulse_count", "u16", 0, 0xFFFF),
    ("current_level_idx", "u8", 0, 31),
    *((f"magic_shop_inventory_{town}", "u8", 0, 0xFF) for town in
      ("muralla", "satono", "bosque", "helada", "tumba", "dorado", "llama", "pureza", "esco")),
    *((f"weapon_shop_swords_{town}", "u8", 0, 0xFC) for town in
      ("muralla", "satono", "bosque", "helada", "tumba", "dorado", "llama", "pureza", "esco")),
    *((f"weapon_shop_shields_{town}", "u8", 0, 0xFC) for town in
      ("muralla", "satono", "bosque", "helada", "tumba", "dorado", "llama", "pureza", "esco")),
    ("sabre_oil_power", "u8", 0, 0xFF),
    ("sages_spoken_bitmap", "u8", 0, 0xFF),
    ("scene_trans_request", "u8", 0, 0xFF),
    ("gvar_pose_idx", "u8", 0, 0xFF),
    ("init_complete_flag", "u8", 0, 0xFF),
)


# offset, bit, canonical semantic name.  These labels are the documented TCRF
# meanings, reconciled with the MASM cavern object handlers.
EVENT_BITS = (
    (0x02, 7, "malicia.chest_50_gold"), (0x02, 6, "malicia.chest_red_potion"),
    (0x02, 5, "malicia.muralla_key"), (0x02, 4, "malicia.wall_blue_potion"),
    (0x02, 3, "malicia.cangrejo_key"), (0x03, 7, "malicia.cangrejo_door_open"),
    (0x03, 6, "malicia.satono_door_open"), (0x03, 5, "malicia.tear"),
    (0x0A, 7, "peligro.chest_blue_potion_bat"), (0x0A, 6, "peligro.key_locked_door"),
    (0x0A, 5, "peligro.key_blue_door"), (0x0A, 4, "peligro.wall_red_potion_far"),
    (0x0A, 3, "peligro.chest_50_gold"), (0x0A, 2, "peligro.empty_chest"),
    (0x0A, 1, "peligro.wall_100_almas"), (0x0A, 0, "peligro.chest_red_potion"),
    (0x0B, 7, "peligro.blue_door_open"), (0x0B, 6, "peligro.red_door_open"),
    (0x0B, 5, "peligro.third_dungeon_open"), (0x0B, 4, "peligro.pulpo_key"),
    (0x0B, 3, "peligro.tear"), (0x0B, 2, "peligro.wall_red_potion_near"),
    (0x12, 7, "madera.red_potion_small_tree"), (0x12, 6, "madera.key"),
    (0x12, 5, "madera.chest_red_potion_crest"), (0x12, 4, "madera.wall_red_potion_large_tree"),
    (0x12, 3, "riza.hero_crest_gate"), (0x12, 2, "madera.gold_50"),
    (0x12, 1, "riza.blue_potion"), (0x12, 0, "riza.red_potion"),
    (0x13, 7, "riza.red_potion_2"), (0x13, 6, "riza.chest_blue_potion"),
    (0x13, 5, "riza.empty_chest"), (0x13, 4, "riza.gold_100"),
    (0x13, 3, "riza.red_door_open"), (0x13, 2, "riza.pollo_key"),
    (0x13, 1, "riza.tear"), (0x13, 0, "riza.fourth_dungeon_open"),
    (0x1A, 7, "glacial.key"), (0x1A, 6, "glacial.red_potion_door"),
    (0x1A, 5, "glacial.red_potion_ruzeria"), (0x1A, 4, "glacial.ruzeria_shoes"),
    (0x1A, 3, "glacial.blue_potion_ruzeria"), (0x1A, 2, "glacial.blue_potion_boss"),
    (0x1A, 1, "glacial.red_potion_gold"), (0x1A, 0, "glacial.gold_100"),
    (0x1B, 7, "escarcha.first_door_open"), (0x1B, 6, "escarcha.agar_door_open"),
    (0x1B, 5, "escarcha.chest_50_gold"), (0x1B, 4, "escarcha.chest_blue_potion"),
    (0x1B, 3, "escarcha.helada_key"), (0x1B, 2, "escarcha.red_potion"),
    (0x1B, 1, "escarcha.blue_potion_boss_key"), (0x1B, 0, "escarcha.boss_key"),
    (0x1C, 7, "escarcha.wall_blue_potion"), (0x1C, 6, "escarcha.wall_red_potion"),
    (0x1C, 5, "escarcha.helada_door_open"), (0x1C, 4, "escarcha.tear"),
    (0x22, 7, "corroer.chest_red_potion"), (0x22, 6, "corroer.wall_red_potion"),
    (0x22, 5, "corroer.chest_500_gold_far"), (0x22, 4, "corroer.chest_blue_potion"),
    (0x22, 3, "cementar.chest_500_gold"), (0x22, 2, "cementar.chest_50_gold_entry"),
    (0x22, 1, "cementar.pirika_shoes"), (0x22, 0, "cementar.chest_100_gold"),
    (0x23, 7, "corroer.cementar_door_open"), (0x23, 6, "cementar.wall_blue_potion_right"),
    (0x23, 5, "cementar.chest_1000_gold"), (0x23, 4, "cementar.first_key"),
    (0x23, 3, "cementar.chest_50_gold_boss_route"), (0x23, 2, "cementar.chest_blue_potion_vista"),
    (0x23, 1, "cementar.boss_key"), (0x23, 0, "cementar.chest_red_potion"),
    (0x24, 7, "cementar.crest_glory"), (0x24, 6, "cementar.wall_100_almas"),
    (0x24, 5, "cementar.wall_blue_potion_left"), (0x24, 4, "cementar.vista_door_open"),
    (0x24, 3, "cementar.vista_blue_potion"), (0x24, 2, "cementar.tear"),
    (0x24, 1, "cementar.crest_glory_returned"),
    (0x2A, 7, "tesoro.chest_red_potion"), (0x2A, 6, "tesoro.empty_chest"),
    (0x2A, 5, "tesoro.silkarn_key"), (0x2A, 4, "tesoro.wall_blue_potion"),
    (0x2A, 3, "tesoro.chest_1000_gold"), (0x2A, 2, "tesoro.silkarn_shoes"),
    (0x2A, 1, "tesoro.chest_blue_potion_left"), (0x2A, 0, "tesoro.chest_blue_potion_right"),
    (0x2B, 7, "tesoro.chest_1000_gold_2"), (0x2B, 6, "tesoro.dorado_key"),
    (0x2B, 5, "tesoro.caliente_door_open"), (0x2B, 4, "tesoro.arrugia_door_open"),
    (0x2B, 3, "tesoro.tarso_door_open"), (0x2B, 2, "tesoro.dorado_door_open"),
    (0x2B, 1, "tesoro.wall_blue_potion_boss"), (0x2B, 0, "tesoro.chest_500_gold"),
    (0x2C, 7, "plata.chest_red_potion"), (0x2C, 6, "plata.wall_blue_potion_fire"),
    (0x2C, 5, "plata.wall_blue_potion"), (0x2C, 4, "plata.wall_red_potion"),
    (0x2C, 3, "arrugia.enchantment_sword"), (0x2C, 2, "arrugia.feruza_shoes"),
    (0x2C, 1, "arrugia.gold_1000_3"), (0x2C, 0, "arrugia.gold_1000_2"),
    (0x2D, 7, "arrugia.gold_1000_1"), (0x2D, 6, "arrugia.blue_potion"),
    (0x2D, 5, "plata.tarso_key"), (0x2D, 4, "plata.tear"),
    (0x34, 7, "llama.spoke_to_girl"), (0x34, 6, "llama.asbestos_cape"),
    (0x34, 5, "caliente.first_door_open"), (0x34, 4, "caliente.dragon_door_open"),
    (0x34, 3, "caliente.chest_blue_potion_platform"), (0x34, 2, "caliente.key_1"),
    (0x34, 1, "caliente.chest_blue_potion_wind"), (0x34, 0, "caliente.key_2"),
    (0x35, 7, "caliente.chest_blue_potion_dragon"), (0x35, 6, "caliente.chest_1000_gold"),
    (0x35, 5, "caliente.second_door_open"), (0x35, 4, "reaccion.chest_blue_potion"),
    (0x35, 3, "reaccion.chest_500_gold"), (0x35, 2, "correr.chest_blue_potion"),
    (0x35, 1, "correr.key_3"), (0x35, 0, "correr.chest_1000_gold"),
    (0x36, 7, "caliente.tear"),
    (0x42, 7, "absor.ceiling_blue_potion_left"), (0x42, 6, "absor.ceiling_blue_potion_dragon"),
    (0x42, 5, "absor.ceiling_blue_potion_pit"), (0x42, 4, "absor.chest_500_gold"),
    (0x42, 3, "absor.lion_key"), (0x42, 2, "absor.chest_1000_gold"),
    (0x42, 1, "absor.chest_1000_gold_falter"), (0x42, 0, "absor.empty_chest"),
    (0x43, 7, "absor.chest_500_gold_far"), (0x43, 6, "absor.first_door_open"),
    (0x43, 5, "absor.chest_1000_gold_2"), (0x43, 4, "absor.ceiling_blue_potion_above"),
    (0x43, 3, "absor.ceiling_blue_potion_key"), (0x43, 2, "absor.key_2"),
    (0x43, 1, "absor.boss_key"), (0x43, 0, "absor.ceiling_blue_potion_esco"),
    (0x44, 7, "milagro.chest_1000_gold"), (0x44, 6, "milagro.wall_blue_potion"),
    (0x44, 5, "milagro.third_door_open"), (0x44, 4, "milagro.second_door_open"),
    (0x44, 3, "milagro.key"), (0x44, 2, "milagro.ceiling_blue_potion_current"),
    (0x44, 1, "milagro.ceiling_blue_potion_above"), (0x44, 0, "milagro.ceiling_blue_potion_below"),
    (0x45, 7, "esco.teleport_to_dorado"), (0x45, 6, "falter.tear"),
    (0x45, 5, "final.jashiin_door_open"), (0x45, 4, "final.key"),
)

BOSS_WORDS = (
    (0x00, "boss.cangrejo_defeated"), (0x08, "boss.pulpo_defeated"),
    (0x10, "boss.pollo_defeated"), (0x18, "boss.agar_defeated"),
    (0x20, "boss.vista_defeated"), (0x28, "boss.tarso_defeated"),
    (0x30, "boss.paguro_defeated"), (0x32, "boss.dragon_defeated"),
)

WHOLE_BYTE_FLAGS = (
    (0x05, "story.spoke_to_king"),
    (0x06, "story.entered_caverns_first_time"),
)


def parse_masm_equates(path: Path = STDPly_INC) -> dict[str, int]:
    equates: dict[str, int] = {}
    pattern = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s+equ\s+([0-9A-Fa-f]+)h\b", re.I)
    for line in path.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line)
        if match:
            equates[match.group(1)] = int(match.group(2), 16)
    return equates


def fields() -> tuple[Field, ...]:
    equates = parse_masm_equates()
    missing = [name for name, *_ in FIELD_RULES if name not in equates]
    if missing:
        raise ValueError(f"stdply.inc is missing canonical fields: {', '.join(missing)}")
    result = tuple(Field(name, kind, equates[name], low, high)
                   for name, kind, low, high in FIELD_RULES)
    for field in result:
        if field.offset + field.width > RECORD_SIZE:
            raise ValueError(f"{field.name} exceeds the 256-byte player record")
    return result


def read_value(record: bytes, field: Field) -> int:
    if field.kind == "u24":
        return (record[field.offset] << 16) | int.from_bytes(
            record[field.offset + 1:field.offset + 3], "little")
    return int.from_bytes(record[field.offset:field.offset + field.width], "little")


def write_value(record: bytearray, field: Field, value: int) -> None:
    if not field.minimum <= value <= field.maximum:
        raise ValueError(f"{field.name}={value} outside {field.minimum}..{field.maximum}")
    if field.kind == "bool" and value not in (0, 0xFF):
        raise ValueError(f"{field.name} must be 0x00 or 0xFF")
    if field.kind == "u24":
        record[field.offset] = (value >> 16) & 0xFF
        record[field.offset + 1:field.offset + 3] = (value & 0xFFFF).to_bytes(2, "little")
    else:
        record[field.offset:field.offset + field.width] = value.to_bytes(field.width, "little")


def validate(record: bytes, *, strict: bool = True) -> list[str]:
    errors: list[str] = []
    if len(record) != RECORD_SIZE:
        return [f"record length is {len(record)}, expected {RECORD_SIZE}"]
    if record[0x81] != 0:
        errors.append(f"reserved crash byte 0x81 is 0x{record[0x81]:02X}, expected 0x00")
    for field in fields():
        value = read_value(record, field)
        if not field.minimum <= value <= field.maximum:
            errors.append(f"{field.name} at 0x{field.offset:02X}=0x{value:X} outside "
                          f"0x{field.minimum:X}..0x{field.maximum:X}")
        if field.kind == "bool" and value not in (0, 0xFF):
            errors.append(f"{field.name} at 0x{field.offset:02X} is not 00/FF")
    by_name = {field.name: field for field in fields()}
    if strict:
        hp = read_value(record, by_name["player_HP"])
        hp_max = read_value(record, by_name["player_hp_max"])
        shield = read_value(record, by_name["shield_HP"])
        shield_max = read_value(record, by_name["shield_max_HP"])
        if hp > hp_max:
            errors.append(f"player_HP {hp} exceeds player_hp_max {hp_max}")
        if shield > shield_max:
            errors.append(f"shield_HP {shield} exceeds shield_max_HP {shield_max}")
    return errors


def base_record() -> bytearray:
    raw = STDPly_BIN.read_bytes()
    if len(raw) != 233:
        raise ValueError(f"authoritative stdply.bin is {len(raw)} bytes, expected 233")
    return bytearray(raw + bytes(RECORD_SIZE - len(raw)))


def set_all_documented_progression(record: bytearray, enabled: bool) -> None:
    value = 0xFF if enabled else 0
    for offset, _ in BOSS_WORDS:
        record[offset:offset + 2] = value.to_bytes(1, "little") * 2
    for offset, _ in WHOLE_BYTE_FLAGS:
        record[offset] = value
    for offset, bit, _ in EVENT_BITS:
        mask = 1 << bit
        record[offset] = (record[offset] | mask) if enabled else (record[offset] & ~mask)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def generate_fixture_records() -> tuple[dict[str, bytes], dict[str, bytes]]:
    canonical = {field.name: field for field in fields()}
    base = base_record()

    clear = bytearray(base)
    set_all_documented_progression(clear, False)

    progressed = bytearray(base)
    set_all_documented_progression(progressed, True)
    write_value(progressed, canonical["tears_of_esmesanti_count"], 9)
    for name in ("crest_elf", "crest_glory", "crest_hero"):
        write_value(progressed, canonical[name], 0xFF)

    boundary = bytearray(base)
    boundary_values = {
        "gold_carried_x65536": 0xFFFFFF, "gold_in_bank_x65536": 0xFFFFFF,
        "player_almas": 0xFFFF, "hero_level": 0xFF, "experience": 0xFFFF,
        "player_HP": 0xFFFF, "player_hp_max": 0xFFFF, "sword": 7,
        "shield": 6, "shield_HP": 0xFFFF, "shield_max_HP": 0xFFFF,
        "keys_normal": 0xFF, "keys_lion": 0xFF, "selected_spell": 7,
        "selected_accessory": 5, "tears_of_esmesanti_count": 9,
        "save_sage": 0x89, "last_sage_visited": 0x89, "current_level_idx": 31,
    }
    for name, value in boundary_values.items():
        write_value(boundary, canonical[name], value)
    for n in range(1, 6):
        write_value(boundary, canonical[f"accessory_slot_{n}"], n)
        write_value(boundary, canonical[f"item_slot_{n}"], n + 3)
    for field in fields():
        if field.name.startswith("spell_charge_"):
            write_value(boundary, field, 0xFF)
        elif field.name.startswith("spell_known_"):
            write_value(boundary, field, 0xFF)

    transient = bytearray(base)
    for name, value in (("scene_trans_request", 0xFF), ("gvar_pose_idx", 0xA5),
                        ("init_complete_flag", 0xFF), ("boss_intro_flag", 0x40),
                        ("heal_pulse_count", 0x1234)):
        write_value(transient, canonical[name], value)

    invalid_81 = bytearray(base)
    invalid_81[0x81] = 1
    short = bytes(base[:-1])
    invalid_enum = bytearray(base)
    invalid_enum[canonical["selected_spell"].offset] = 8
    invalid_sage = bytearray(base)
    invalid_sage[canonical["save_sage"].offset] = 1
    invalid_bool = bytearray(base)
    invalid_bool[canonical["crest_hero"].offset] = 1
    invalid_hp = bytearray(base)
    write_value(invalid_hp, canonical["player_HP"], 81)
    write_value(invalid_hp, canonical["player_hp_max"], 80)

    valid = {
        "BASE.USR": bytes(base), "CLEAR.USR": bytes(clear),
        "PROGRESS.USR": bytes(progressed), "BOUNDARY.USR": bytes(boundary),
        "LEAKAGE.USR": bytes(transient),
    }
    malformed = {
        "SHORT255.USR": short, "X81BAD.USR": bytes(invalid_81),
        "LONG257.USR": bytes(base) + b"\x00", "BADSPELL.USR": bytes(invalid_enum),
        "BADSAGE.USR": bytes(invalid_sage), "BADBOOL.USR": bytes(invalid_bool),
        "BADHP.USR": bytes(invalid_hp),
    }
    return valid, malformed


def coverage_entries() -> list[dict[str, object]]:
    entries = [
        {"name": name, "offset": offset, "mask": "0xFFFF", "set": "PROGRESS.USR",
         "clear": "CLEAR.USR", "round_trip": True}
        for offset, name in BOSS_WORDS
    ]
    entries.extend(
        {"name": name, "offset": offset, "mask": "0xFF", "set": "PROGRESS.USR",
         "clear": "CLEAR.USR", "round_trip": True}
        for offset, name in WHOLE_BYTE_FLAGS
    )
    entries.extend(
        {"name": name, "offset": offset, "mask": f"0x{1 << bit:02X}",
         "set": "PROGRESS.USR", "clear": "CLEAR.USR", "round_trip": True}
        for offset, bit, name in EVENT_BITS
    )
    return entries


def generate(output: Path) -> dict[str, object]:
    valid, malformed = generate_fixture_records()
    valid_dir = output / "valid"
    malformed_dir = output / "malformed"
    valid_dir.mkdir(parents=True, exist_ok=True)
    malformed_dir.mkdir(parents=True, exist_ok=True)
    for name, data in valid.items():
        (valid_dir / name).write_bytes(data)
    for name, data in malformed.items():
        (malformed_dir / name).write_bytes(data)
    manifest = {
        "format": "zeliard-usr-fixtures-v1",
        "generator": "scripts/state/zeliard_state.py",
        "authoritative_layout": str(STDPly_INC.relative_to(ROOT)).replace("\\", "/"),
        "authoritative_seed_sha256": sha256(STDPly_BIN.read_bytes()),
        "fixtures": {
            "valid": {name: {"size": len(data), "sha256": sha256(data)}
                      for name, data in sorted(valid.items())},
            "malformed": {name: {"size": len(data), "sha256": sha256(data),
                                  "must_not_run_in_dosbox": True}
                          for name, data in sorted(malformed.items())},
        },
        "persistent_coverage": coverage_entries(),
        "scalar_coverage": [
            {"name": field.name, "offset": field.offset,
             "width": field.width, "minimum": field.minimum,
             "maximum": field.maximum, "round_trip": "unit:min+max"}
            for field in fields()
        ],
    }
    (output / "manifest.json").write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return manifest


def semantic_diff(expected: bytes, actual: bytes) -> list[dict[str, object]]:
    if len(expected) != RECORD_SIZE or len(actual) != RECORD_SIZE:
        raise ValueError("semantic diff requires two 256-byte records")
    differences: list[dict[str, object]] = []
    consumed: set[int] = set()
    for offset, name in BOSS_WORDS:
        before = int.from_bytes(expected[offset:offset + 2], "little")
        after = int.from_bytes(actual[offset:offset + 2], "little")
        consumed.update((offset, offset + 1))
        if before != after:
            differences.append({"offset": f"0x{offset:02X}", "mask": "0xFFFF",
                                "name": name, "expected": f"0x{before:04X}",
                                "actual": f"0x{after:04X}"})
    for offset, name in WHOLE_BYTE_FLAGS:
        consumed.add(offset)
        if expected[offset] != actual[offset]:
            differences.append({"offset": f"0x{offset:02X}", "mask": "0xFF",
                                "name": name, "expected": f"0x{expected[offset]:02X}",
                                "actual": f"0x{actual[offset]:02X}"})
    bits_by_offset: dict[int, list[tuple[int, str]]] = {}
    for offset, bit, name in EVENT_BITS:
        bits_by_offset.setdefault(offset, []).append((bit, name))
    for offset, bit_specs in bits_by_offset.items():
        consumed.add(offset)
        changed = expected[offset] ^ actual[offset]
        known_mask = 0
        for bit, name in bit_specs:
            mask = 1 << bit
            known_mask |= mask
            if changed & mask:
                differences.append({"offset": f"0x{offset:02X}", "mask": f"0x{mask:02X}",
                                    "name": name, "expected": 1 if expected[offset] & mask else 0,
                                    "actual": 1 if actual[offset] & mask else 0})
        unknown = changed & ~known_mask & 0xFF
        if unknown:
            differences.append({"offset": f"0x{offset:02X}", "mask": f"0x{unknown:02X}",
                                "name": f"reserved_progression_0x{offset:02X}",
                                "expected": f"0x{expected[offset] & unknown:02X}",
                                "actual": f"0x{actual[offset] & unknown:02X}"})
    for field in fields():
        span = set(range(field.offset, field.offset + field.width))
        consumed.update(span)
        before = read_value(expected, field)
        after = read_value(actual, field)
        if before != after:
            differences.append({"offset": f"0x{field.offset:02X}",
                                "mask": f"0x{(1 << (field.width * 8)) - 1:0{field.width * 2}X}",
                                "name": field.name, "expected": before, "actual": after})
    for offset, (before, after) in enumerate(zip(expected, actual)):
        if offset not in consumed and before != after:
            differences.append({"offset": f"0x{offset:02X}", "mask": "0xFF",
                                "name": f"reserved_0x{offset:02X}",
                                "expected": f"0x{before:02X}", "actual": f"0x{after:02X}"})
    return differences


def decoded(record: bytes) -> dict[str, object]:
    result: dict[str, object] = {field.name: read_value(record, field) for field in fields()}
    result["progression"] = {
        name: int.from_bytes(record[offset:offset + 2], "little") != 0
        for offset, name in BOSS_WORDS
    }
    result["progression"].update({name: record[offset] != 0 for offset, name in WHOLE_BYTE_FLAGS})
    result["progression"].update({name: bool(record[offset] & (1 << bit))
                                  for offset, bit, name in EVENT_BITS})
    return result


def write_snapshot(record_path: Path, output: Path, context: dict[str, object]) -> None:
    record = record_path.read_bytes()
    errors = validate(record, strict=False)
    snapshot = {
        "format": "zeliard-state-checkpoint-v1", "checkpoint": context,
        "record": {"path": record_path.name, "size": len(record), "sha256": sha256(record),
                   "semantic": decoded(record) if not errors else None},
        "validation_errors": errors,
    }
    output.write_text(json.dumps(snapshot, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    gen = sub.add_parser("generate")
    gen.add_argument("--output", type=Path, default=Path(__file__).with_name("fixtures"))
    check = sub.add_parser("validate")
    check.add_argument("record", type=Path)
    decode = sub.add_parser("decode")
    decode.add_argument("record", type=Path)
    diff = sub.add_parser("diff")
    diff.add_argument("expected", type=Path)
    diff.add_argument("actual", type=Path)
    capture = sub.add_parser("capture")
    capture.add_argument("record", type=Path)
    capture.add_argument("--output", type=Path, required=True)
    capture.add_argument("--scene", required=True)
    capture.add_argument("--owner", required=True)
    capture.add_argument("--rng", default="unknown")
    capture.add_argument("--timers", default="{}", help="JSON object of timer values")
    args = parser.parse_args(list(argv) if argv is not None else None)

    if args.command == "generate":
        manifest = generate(args.output)
        print(json.dumps({"valid": len(manifest["fixtures"]["valid"]),
                          "malformed": len(manifest["fixtures"]["malformed"]),
                          "persistent_bits": len(manifest["persistent_coverage"])}))
        return 0
    if args.command == "validate":
        errors = validate(args.record.read_bytes())
        if errors:
            print("\n".join(errors), file=sys.stderr)
            return 1
        print(f"{args.record}: valid")
        return 0
    if args.command == "decode":
        record = args.record.read_bytes()
        errors = validate(record, strict=False)
        if errors:
            print("\n".join(errors), file=sys.stderr)
            return 1
        print(json.dumps(decoded(record), indent=2, sort_keys=True))
        return 0
    if args.command == "diff":
        changes = semantic_diff(args.expected.read_bytes(), args.actual.read_bytes())
        print(json.dumps(changes, indent=2))
        return 1 if changes else 0
    if args.command == "capture":
        try:
            timers = json.loads(args.timers)
        except json.JSONDecodeError as exc:
            parser.error(f"--timers must be JSON: {exc}")
        write_snapshot(args.record, args.output,
                       {"scene": args.scene, "owner": args.owner,
                        "rng": args.rng, "timers": timers})
        return 0
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
