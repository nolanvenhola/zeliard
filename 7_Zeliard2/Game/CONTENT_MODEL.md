# Zeliard 2 Content Model

Issue #240 establishes the authored-data contract shared by the game and Zeliard Creator.

## Identity and references

Every top-level definition has a stable lowercase `kind:name` ID, such as `room:verdant_gate`. The prefix must match its schema kind. References store that ID and the schema derives the expected target kind. Paths are an authoring detail: moving or renaming a `.tres` file does not change identity or break references.

The catalog indexes definitions by ID. Graph validation rejects malformed or duplicate IDs, missing targets, and references to the wrong content kind. It does not silently repair authored data.

## Definition domains

| Definition | Owns | References |
|---|---|---|
| Campaign | Campaign entry points | Regions and player actor |
| Region | Ordered room set | Rooms and optional music asset |
| Room | Logical size, entries, exits, placements | Region, rooms, actors, enemies, events |
| Actor | Starting health and loadout | Items, abilities, sprite asset |
| Enemy | Combat baseline | Abilities and sprite asset |
| Item | Item type and value | Granted ability and icon asset |
| Ability | Power, range, and logical cooldown | Optional event, animation, and audio assets |
| Dialogue | Ordered, locally identified lines | Speaking actors |
| Quest | Ordered, locally identified stages | Quests, completion events, reward items |
| Asset | Modern source asset and authoring notes | Imported Godot resource path |
| Event | Trigger and ordered typed actions | Dialogue, items, quests, or destination rooms |

Small nested Resources represent placements, exits, dialogue lines, quest stages, and event steps. They belong to their top-level definition and do not receive global IDs.

## Definitions are not state

Definitions are immutable design facts loaded from `res://content`: maximum health, room topology, dialogue text, and similar authored values. Mutable runtime and save facts—current health, player location, inventory ownership, quest progress, defeated enemies, and event flags—must live in separate state objects keyed by stable content IDs.

Do not add mutable playthrough fields to these Resources. Save schemas, versioning, recovery, and migrations belong to issue #241.

## Source-control rules

- Prefer one top-level definition per text `.tres` file.
- Keep ordered nested records explicit; do not hide authored behavior in opaque dictionaries.
- Never use a file path as the identity of gameplay content.
- Never place original Zeliard resources or converted legacy assets under production content.
- Run `tools/validate_project.ps1` before review; the headless suite loads and validates the complete graph.
