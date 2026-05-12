# Monster type-byte reference (per-cavern)

Authoritative reference for the `type` byte at offset +0x04 of each
16-byte monster record in the MDT.  Names are from
`4_Resources/FAQ.html` (Alan Franciškovic's GameFAQs walkthrough,
section 4 "Description of underlings") with cross-references to per-
cavern Spanish names + Almas values from the same FAQ.

## Architecture

The `type` byte is a **per-area slot index** (0x01..0x04).  Each
cavern's `enemy_id_table` (loaded at game_seg:0x8000 from a per-area
SAR chunk via `LOAD_CHUNK_ES enemy_id_table, 02h` at 200FIGHT.asm:4113)
translates the slot index to a sprite_id + AI handler.

**EAI1** (`301EAI1.asm`, zelres3 chunk 0x02) is the **shared regular-
enemy AI handler** used by *all* caverns.  Generic state machine
(4 states: main / attack_a / attack_b / pincer per `crab_ai_dispatch_tbl`
at offset 0xA266, indexed by `[si+4] & 0xF`).  Per-enemy frame-pointer
tables (`slug_walk_right_frames`, `bat_fly_frames`, etc.) at chunk
header determine which sprite gets used.

**EAI2..EAI8** are **per-boss helper AI** paired with the corresponding
boss chunks (TAKO/TORI/ZELA/MEDA/LEGA/Dragon/Akma/Mao2 helpers).

---

## Per-cavern enemy table

Slot ordering is tentative (FAQ list order assumed) until per-EAI
frame-table inspection confirms each slot's sprite+AI assignment.

### MDT level 0x01 — Felishika start area (prologue)

Uses Muralla's enemy AI but with only 3 slots used (no Rat).

| Slot | Enemy | Almas (1) | Almas (2) | Behavior |
|---:|---|---:|---:|---|
| 0x01 | Toad | 1 | — | Fast hopping contact (also "Frog" in DB) |
| 0x02 | Slug | 1 | — | Slow ground contact ("persistent and not easily destroyed") |
| 0x03 | Bat | 1 | 10 | Aerial swooper from ceiling |

### MDT level 0x02 — Muralla "Cavern of Malicia"

| Slot | Enemy | Almas (1) | Almas (2) | Behavior |
|---:|---|---:|---:|---|
| 0x01 | Toad | 1 | — | Fast contact attack |
| 0x02 | Slug | 1 | — | Slow / endurable |
| 0x03 | Bat | 1 | 10 | Swoop from ceiling, follows player until hits ceiling/player |
| 0x04 | Rat | 10 | — | Even faster than Toad; either 10 Almas or none |

### MDT level 0x03 — Satono "Cavern of Peligro"

| Slot | Enemy | Almas (1) | Almas (2) | Behavior |
|---:|---|---:|---:|---|
| 0x01 | Blue Slime | 1 | — | Confused movement, easy to kill |
| 0x02 | Bat | 1 | 10 | Like Malicia bats but more endurable, larger numbers |
| 0x03 | Red Toad | 1 | 10 | Shoots low spittle (more dangerous than Green Toad) |
| 0x04 | Troll | 10 | — | Runs away, shoots small axes (ranged coward) |

Special types `0x73`, `0x7C`, `0xD0` (4 total instances): scripted /
cinematic spawns in Satono outdoor map.  Likely NPCs that turn hostile
or unique encounters.

### MDT level 0x04 — Bosque "Cavern of Madera/Riza"

| Slot | Enemy | Almas (1) | Almas (2) | Behavior |
|---:|---|---:|---:|---|
| 0x01 | Earthworm | 1 | — | Burrowed = invisible/untouchable; shoots spit when surfaced |
| 0x02 | Bug | 1 | 10 | Most powerful here; jumps and causes unforeseeable damage |
| 0x03 | Crab | 10 | — | Comes after player when approached; guards doors |
| 0x04 | Clay Ball | 1 | — | Walks on walls/ceilings, drops on player |

### MDT level 0x05 — Helada "Cavern of Escarcha/Glacial"

| Slot | Enemy | Almas (1) | Almas (2) | Behavior |
|---:|---|---:|---:|---|
| 0x01 | Turtle | 1 | 10 | Jumps when in shell; collides with player; very hard to kill |
| 0x02 | Green Slime | 1 | — | Reproduces when hit (Fuego prevents); endurable |
| 0x03 | Arrow | 1 | 10 | Circles small ground pieces at great speed; very painful |
| 0x04 | (4th enemy) | ? | ? | FAQ §4.4 only lists 3 enemies; MDT shows slot 4 used (26 instances).  Possibly a Helada variant not enumerated in FAQ. |

### MDT level 0x06 — Tumba "Cavern of Corroer/Cementar" (Gelroid)

The **Gelroid** is a blue fluid that drains HP while standing in it;
crossing requires Pirika Shoes.  Red Slimes inhabit the Gelroid.

| Slot | Enemy | Almas (1) | Almas (2) | Behavior |
|---:|---|---:|---:|---|
| 0x01 | Red Slime | 1 | 10 | Reproduces on contact with sword/spell (except Fuego/Lanzar); Magia Stone makes it worse; only Enchantment Sword kills with regular hits |
| 0x02 | Eyeball | 1 | 10 | Speed-doubles randomly; Lanzar kills at long range |
| 0x03 | Bluish Person (Evil Woman) | 10 | 100 | First 100-Almas enemy; shoots spit; must hit head (attack down doesn't work) |
| 0x04 | Bat | 1 | 10 | More powerful than earlier bats; different swoop pattern |

### MDT level 0x07 — Dorado "Cavern of Tesoro/Plata/Arrugia"

| Slot | Enemy | Almas (1) | Almas (2) | Behavior |
|---:|---|---:|---:|---|
| 0x01 | Red Ghost | 10 | — | Disappears briefly when hit with Knight's Sword; need Illumination Sword |
| 0x02 | Kondor | 10 | — | Can speed-double at any time |
| 0x03 | Evil Woman | 100 | — | Worst enemy here; disappears after shooting heart; prettier than Tumba's; needs 2 unmissed Illumination Sword hits to kill |
| 0x04 | (4th enemy) | ? | ? | FAQ §4.6 lists only 3; MDT shows slot 4 with 28 instances (most common Dorado enemy). |

### MDT level 0x08 — Llama "Cavern of Caliente/Reaccion/Corroer"

| Slot | Enemy | Almas (1) | Almas (2) | Behavior |
|---:|---|---:|---:|---|
| 0x01 | Fire Creature | 10 | 100 | Strongest here; shoots harmful projectile; must hit head |
| 0x02 | Troll | 10 | 100 | Far more powerful than Satono trolls; shoots many darts quickly |
| 0x03 | Rat | 10 | 100 | Very fast and valuable; large numbers in "Corroer" labyrinth |
| 0x04 | (4th enemy) | ? | ? | FAQ §4.7 lists 3; MDT shows 14 instances of slot 4. |

Special type `0xD0` (3 instances): scripted Llama spawn.

### MDT level 0x09 — Pureza "Cavern of Absor/Millagro/Desleal/Faltar/Final"

| Slot | Enemy | Almas (1) | Almas (2) | Behavior |
|---:|---|---:|---:|---|
| 0x01 | Lava Slime | 10 | 100 | Shoots green spit left + red spit right (red more painful); slow but ranged; Enchantment Sword 1-shot |
| 0x02 | Bug | 10 | — | "Wacky looks"; pretty harmful |
| 0x03 | Medusa | ? | ? | Must hit head; backstab = ~5 hits to kill player; even damages Titanium Shield greatly |
| 0x04 | Blue Ghost | 10 | 100 | Like Dorado's Red Ghost but more powerful; harmful and slow |
| (extra) | Octopus | 100 | — | Listed in FAQ §4.2 Almas summary but NOT in §4.8 enemy detail.  Likely the boss-arena "Alguien" minion or an unenumerated Pureza enemy. |

Note: MP90 (Pureza cavern map) decodes 0 monsters in the MDT — Pureza
enemies must be spawned via per-frame area scan from EAI code, not
from MDT records.

---

## Special findings

### Magical Bat is a chest-spawn

Per the DB and FAQ: appears when opening certain chests; attacks once
and flies away.  100 almas / 255 XP.  Mechanism is via the MDT items
table's spawn-on-open trigger, NOT a roster monster slot.

### Red Slime is unkillable by regular swords

FAQ §4.5.1: "swords don't harm them. Upon close range, to kill them,
two Fuego Spells are required. The Magia Stone only acts like ordinary
swords and makes it much worse. Only the Fairy Flame Enchantment Sword
can kill them (besides the two spells)."

So the AI handler short-circuits the sword-strike hit-test for slot 1
in level 6 — only the spell-cast damage path (Fuego / Lanzar) writes
to the slot's HP byte.  This is a per-AI-handler hardcoded immunity.

### Lava Slime has directional shots

FAQ §4.8.1: "shoot on two sides. On the left, green spit, and on the
right, red, which is much more painful."  So the Lava Slime AI fires
2 projectiles per attack-tick with different damage values based on
relative player position.

### Special type bytes 0x73, 0x7C, 0xD0

These appear sporadically and are likely:
- **Cinematic-trigger spawns** — characters that appear at specific
  points in story progression (NPCs that "turn hostile" or scripted
  fight setups)
- **Chest-trigger spawns** — Magical-Bat-like enemies that appear
  when interacting with specific MDT-item records

Cross-reference with `entity_fn_e_*` handlers in 200FIGHT (lines 6755+).

---

## How to fully verify

1. **Read each `eaiN.bin` frame-pointer table** — match handler signatures
   (hop / crawl / fly / shoot) to FAQ enemy descriptions.
2. **DOSBox observation per chapter** — load save, walk into each MDT
   monster placement, observe the rendered sprite + behavior.
3. **Cross-reference the 4th-slot enemies for Helada / Dorado / Llama** —
   FAQ omits them but they ARE used in MDT data.

---

## Cross-references

- `working/CAVERN_INVENTORY.md` — per-cavern monster placements with names
- `working/TOWN_NPCS_DUMP.md` — town NPC dialog (non-hostile)
- `4_Resources/FAQ.html` §4 — authoritative enemy descriptions
- `4_Resources/GameData/ENEMIES_DATABASE.md` — older curated enemy DB
- `4_Resources/Documentation/Zeliard_Enemies.pdf` — official enemy art
- `BOSS_AI.md` + `BOSS_FSM_GRAPHS.md` — boss-specific (separate from regular monsters)
