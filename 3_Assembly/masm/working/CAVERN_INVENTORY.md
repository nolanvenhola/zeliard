# Cavern inventory dump

Per-cavern enemies / items / doors / platforms decoded from
each MDT in `working/zelres3/data/`.  Uses brox's `decode_mdt()`
(after stripping the 4-byte SAR length prefix).

Map-ID lookup (door records reference these by `map_id` byte):
see `Documentation/SAR_DIRECTORY.md` "Dungeon map ID lookup".

Each cavern's **monsters + items** share the same MDT+0x10
table (16 B/entry); `spawn_type` byte at +0x0E distinguishes
item (0) vs monster (≠0).

---

## Observations

**Boss-arena dungeons are empty MDTs.**  Maps with `D` suffix
(MP1D, MP2D, MP3D, MP4D, MP5D, MP6D, MP7D, MP8D) all decode
with 0 doors / 0 monsters / 0 items.  Also MP90 (Pureza) and
MPA0 (Esco) are empty.  These are the boss arenas — terrain
only.  Enemies + boss spawn come from the per-boss code chunk
(309CRAB, 310TAKO, etc.) loaded into game_seg:0xA000 when the
`current_area_id` sign bit triggers `check_c3` boss-intro path.

**Map width pattern**: outdoor/town-adjacent maps are 192-320
tiles wide; sub-areas are 70-128; boss arenas are 42-73.

**Cavern level byte** at MDT+0x12: 0x01 (start area) through
0x09 (Pureza) — matches the canonical 9-step chapter
progression (Felishika → Muralla → Satono → Bosque → Helada
→ Tumba → Dorado → Llama → Pureza).

**Monster type bytes**:
- 0x01 = Snail/Slug (per brox)
- 0x02 = Frog (per brox)
- 0x03-0xFF = per-area enemy types (not yet catalogued; would
  need per-EAI chunk inspection of how the type byte selects
  sprite + AI handler)

**Door flag bits** (per brox/MDTViewer/models.py:Door.from_bytes):
- `flags & 0x01` → "needs Lion Key"
- `y1 == 0x00FF` → town warp (the y1 word is sentinel-set to FF)
- Other bits unknown — observed values: 0x00, 0x01, 0x83, 0xC0,
  0xC2, 0xC3, 0xFF + many more across all caverns

**Spawn fields (spwn_x/spwn_y/spwn_type)**: when the monster
is at (x,y), `spwn_*` typically matches; for some monsters
`spwn_type` differs from `type` — interpretation TBD (likely
"despawn-and-respawn" trigger info for off-screen monsters).

---

## Summary

| File | Role | Width | Level | Doors | Monsters | Items |
|---|---|---:|---:|---:|---:|---:|
| 320MP10.mdt | 0. Felishika start area / opening | 240 | 0x01 | 6 | 36 | 18 |
| 321MP1D.mdt | 0-D. (dungeon variant) | 73 | 0x01 | 0 | 0 | 0 |
| 322MP20.mdt | 1. Muralla outdoor | 224 | 0x02 | 6 | 45 | 11 |
| 323MP21.mdt | 1-A. Muralla sub-area | 96 | 0x02 | 4 | 7 | 2 |
| 324MP2D.mdt | 1-D. Muralla cavern (Cangrejo boss) | 52 | 0x02 | 0 | 0 | 0 |
| 325MP30.mdt | 2. Satono outdoor | 204 | 0x03 | 12 | 30 | 15 |
| 326MP31.mdt | 2-A. Satono sub-area | 204 | 0x03 | 14 | 36 | 12 |
| 327MP3D.mdt | 2-D. Satono cavern (Pulpo boss) | 73 | 0x03 | 0 | 0 | 0 |
| 328MP40.mdt | 3. Bosque outdoor | 320 | 0x04 | 6 | 38 | 31 |
| 329MP41.mdt | 3-A. Bosque sub-area | 192 | 0x04 | 6 | 14 | 22 |
| 330MP4D.mdt | 3-D. Bosque cavern (Pollo boss) | 73 | 0x04 | 0 | 0 | 0 |
| 331MP50.mdt | 4. Helada outdoor | 240 | 0x05 | 9 | 49 | 24 |
| 332MP51.mdt | 4-A. Helada sub-area | 240 | 0x05 | 7 | 36 | 34 |
| 333MP5D.mdt | 4-D. Helada cavern (ice; Ruzeria gates) | 73 | 0x05 | 0 | 0 | 0 |
| 334MP60.mdt | 5. Tumba outdoor / 5-A. Tumba sub-area | 320 | 0x06 | 14 | 45 | 16 |
| 335MP61.mdt | 5-B. Tumba sub-area | 256 | 0x06 | 15 | 40 | 20 |
| 336MP62.mdt | 5-C. Tumba sub-area | 73 | 0x06 | 2 | 0 | 28 |
| 337MP6D.mdt | 5-D. Tumba cavern (slime/graveyard) | 73 | 0x06 | 0 | 0 | 0 |
| 338MP70.mdt | 6. Dorado outdoor | 208 | 0x07 | 14 | 19 | 10 |
| 339MP71.mdt | 6-A. Dorado sub-area | 196 | 0x07 | 7 | 25 | 10 |
| 340MP72.mdt | 6-B. Dorado sub-area | 128 | 0x07 | 5 | 14 | 3 |
| 341MP73.mdt | 6-C. Dorado sub-area | 73 | 0x01 | 0 | 0 | 0 |
| 342MP7D.mdt | 6-D. Dorado cavern (gold/Silkarn) | 70 | 0x07 | 0 | 0 | 0 |
| 343MP80.mdt | 7. Llama outdoor | 256 | 0x08 | 11 | 45 | 15 |
| 344MP81.mdt | 7-A. Llama sub-area | 256 | 0x08 | 13 | 58 | 11 |
| 345MP82.mdt | 7-B. Llama sub-area | 192 | 0x08 | 7 | 33 | 6 |
| 346MP83.mdt | 7-C. Llama sub-area | 128 | 0x08 | 3 | 7 | 0 |
| 347MP84.mdt | 7-D. Llama dungeon | 64 | 0x08 | 2 | 0 | 1 |
| 348MP8D.mdt | 7-D. Llama cavern (Dragon boss) | 70 | 0x08 | 0 | 0 | 0 |
| 349MP90.mdt | 8-1. Pureza cavern (acid; Cape gates) | 42 | 0x09 | 0 | 0 | 0 |
| 350MPA0.mdt | 8-2. Esco final approach | 73 | 0x0A | 0 | 0 | 0 |

---

## 320MP10.mdt — 0. Felishika start area / opening

- **width**: 240 tiles (height fixed at 64)
- **cavern level**: 0x01 (1)
- **tear coords**: (26, 16)
- **doors**: 6, **monsters**: 36, **items**: 18

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 26 | 15 | 0x01 | MP1D.MDT | Locked Door  (Lion Key required) |
| D2 | 61 | 6 | 0xC0 | MRMP.MDT  (1. Muralla Town) | Town Warp |
| D3 | 95 | 50 | 0x83 | MP21.MDT | Locked Door  (Lion Key required) |
| D4 | 128 | 32 | 0x00 | STMP.MDT  (2. Satono Town) | Town Warp |
| D5 | 141 | 32 | 0xC2 | MP1D.MDT | Regular Door |
| D6 | 159 | 50 | 0xC3 | MP21.MDT | Locked Door  (Lion Key required) |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 12 | 33 | 0x01 | Toad | 0x00 | (12, 33, 0x01) |
| M2 | 22 | 60 | 0x02 | Slug | 0x00 | (22, 60, 0x02) |
| M3 | 26 | 5 | 0x02 | Slug | 0x00 | (26, 5, 0x02) |
| M4 | 30 | 23 | 0x01 | Toad | 0x00 | (30, 23, 0x01) |
| M5 | 42 | 32 | 0x03 | Bat | 0x00 | (42, 32, 0x03) |
| M6 | 42 | 41 | 0x02 | Slug | 0x00 | (42, 41, 0x02) |
| M7 | 60 | 32 | 0x02 | Slug | 0x00 | (60, 32, 0x02) |
| M8 | 64 | 41 | 0x02 | Slug | 0x00 | (64, 41, 0x02) |
| M9 | 74 | 52 | 0x01 | Toad | 0x00 | (74, 52, 0x01) |
| M10 | 75 | 19 | 0x02 | Slug | 0x00 | (75, 19, 0x02) |
| M11 | 81 | 60 | 0x01 | Toad | 0x00 | (81, 60, 0x01) |
| M12 | 82 | 41 | 0x01 | Toad | 0x00 | (82, 41, 0x01) |
| M13 | 83 | 8 | 0x02 | Slug | 0x00 | (83, 8, 0x02) |
| M14 | 84 | 32 | 0x01 | Toad | 0x00 | (84, 32, 0x01) |
| M15 | 85 | 52 | 0x02 | Slug | 0x00 | (85, 52, 0x02) |
| M16 | 89 | 19 | 0x02 | Slug | 0x00 | (89, 19, 0x02) |
| M17 | 91 | 61 | 0x02 | Slug | 0x00 | (91, 61, 0x02) |
| M18 | 100 | 8 | 0x02 | Slug | 0x00 | (100, 8, 0x02) |
| M19 | 110 | 52 | 0x03 | Bat | 0x00 | (110, 52, 0x03) |
| M20 | 124 | 21 | 0x01 | Toad | 0x00 | (124, 21, 0x01) |
| M21 | 128 | 43 | 0x01 | Toad | 0x00 | (128, 43, 0x01) |
| M22 | 133 | 52 | 0x01 | Toad | 0x00 | (133, 52, 0x01) |
| M23 | 149 | 3 | 0x01 | Toad | 0x00 | (149, 3, 0x01) |
| M24 | 168 | 3 | 0x02 | Slug | 0x00 | (168, 3, 0x02) |
| M25 | 172 | 45 | 0x01 | Toad | 0x00 | (172, 45, 0x01) |
| M26 | 184 | 15 | 0x02 | Slug | 0x00 | (184, 15, 0x02) |
| M27 | 188 | 27 | 0x02 | Slug | 0x00 | (188, 27, 0x02) |
| M28 | 189 | 38 | 0x02 | Slug | 0x00 | (189, 38, 0x02) |
| M29 | 195 | 3 | 0x03 | Bat | 0x00 | (195, 3, 0x03) |
| M30 | 196 | 15 | 0x02 | Slug | 0x00 | (196, 15, 0x02) |
| M31 | 198 | 27 | 0x01 | Toad | 0x00 | (198, 27, 0x01) |
| M32 | 198 | 38 | 0x01 | Toad | 0x00 | (198, 38, 0x01) |
| M33 | 198 | 53 | 0x01 | Toad | 0x00 | (198, 53, 0x01) |
| M34 | 220 | 15 | 0x03 | Bat | 0x00 | (220, 15, 0x03) |
| M35 | 222 | 53 | 0x03 | Bat | 0x00 | (222, 53, 0x03) |
| M36 | 224 | 5 | 0x01 | Toad | 0x00 | (224, 5, 0x01) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 26 | 23 | 0x73 | 0x00 | `1A 00 17 FF 73 00 01 20 00 00 00 02 00 80 00 00` |
| I2 | 76 | 47 | 0x00 | 0x00 | `4C 00 2F FF 00 00 00 00 00 00 00 4C 00 2F 00 00` |
| I3 | 83 | 47 | 0x00 | 0x00 | `53 00 2F FF 00 00 00 00 00 00 00 53 00 2F 00 00` |
| I4 | 88 | 47 | 0x00 | 0x00 | `58 00 2F FF 00 00 00 00 00 00 00 58 00 2F 00 00` |
| I5 | 99 | 31 | 0x73 | 0x00 | `63 00 1F FF 73 00 00 20 00 18 00 02 00 40 00 00` |
| I6 | 99 | 41 | 0x76 | 0x00 | `63 00 29 FF 76 00 00 20 00 00 00 02 00 20 00 00` |
| I7 | 126 | 48 | 0x00 | 0x00 | `7E 00 30 FF 00 00 00 00 00 00 00 7E 00 30 00 00` |
| I8 | 131 | 48 | 0x00 | 0x00 | `83 00 30 FF 00 00 00 00 00 00 00 83 00 30 00 00` |
| I9 | 140 | 14 | 0x00 | 0x00 | `8C 00 0E FF 00 00 00 00 00 00 00 8C 00 0E 00 00` |
| I10 | 145 | 14 | 0x00 | 0x00 | `91 00 0E FF 00 00 00 00 00 00 00 91 00 0E 00 00` |
| I11 | 148 | 15 | 0x00 | 0x00 | `94 00 0F FF 00 00 00 00 00 00 00 94 00 0F 00 00` |
| I12 | 195 | 59 | 0x00 | 0x00 | `C3 00 3B FF 00 00 00 00 00 00 00 C3 00 3B 00 00` |
| I13 | 197 | 60 | 0x00 | 0x00 | `C5 00 3C FF 00 00 00 00 00 00 00 C5 00 3C 00 00` |
| I14 | 199 | 46 | 0x00 | 0x00 | `C7 00 2E FF 00 00 00 00 00 00 00 C7 00 2E 00 00` |
| I15 | 199 | 61 | 0x00 | 0x00 | `C7 00 3D FF 00 00 00 00 00 00 00 C7 00 3D 00 00` |
| I16 | 201 | 60 | 0x00 | 0x00 | `C9 00 3C FF 00 00 00 00 00 00 00 C9 00 3C 00 00` |
| I17 | 209 | 47 | 0x00 | 0x00 | `D1 00 2F FF 00 00 00 00 00 00 00 D1 00 2F 00 00` |
| I18 | 224 | 36 | 0xD0 | 0x00 | `E0 00 24 FF D0 00 00 20 00 19 00 02 00 10 00 00` |

## 321MP1D.mdt — 0-D. (dungeon variant)

- **width**: 73 tiles (height fixed at 64)
- **cavern level**: 0x01 (1)
- **tear coords**: (65535, 0)
- **doors**: 0, **monsters**: 0, **items**: 0

## 322MP20.mdt — 1. Muralla outdoor

- **width**: 224 tiles (height fixed at 64)
- **cavern level**: 0x02 (2)
- **tear coords**: (171, 55)
- **doors**: 6, **monsters**: 45, **items**: 11

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 6 | 61 | 0xC0 | STMP.MDT  (2. Satono Town) | Town Warp |
| D2 | 95 | 35 | 0x42 | MP21.MDT | Regular Door |
| D3 | 146 | 35 | 0x82 | MP21.MDT | Regular Door |
| D4 | 171 | 54 | 0x01 | MP2D.MDT | Locked Door  (Lion Key required) |
| D5 | 190 | 47 | 0xC2 | MP2D.MDT | Regular Door |
| D6 | 205 | 47 | 0x40 | MP30.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 2 | 19 | 0x04 | Rat | 0x00 | (2, 19, 0x04) |
| M2 | 11 | 50 | 0x02 | Slug | 0x00 | (11, 50, 0x02) |
| M3 | 12 | 11 | 0x02 | Slug | 0x00 | (12, 11, 0x02) |
| M4 | 16 | 25 | 0x03 | Bat | 0x00 | (16, 25, 0x03) |
| M5 | 20 | 40 | 0x02 | Slug | 0x00 | (20, 40, 0x02) |
| M6 | 32 | 40 | 0x02 | Slug | 0x00 | (32, 40, 0x02) |
| M7 | 33 | 27 | 0x03 | Bat | 0x00 | (33, 27, 0x03) |
| M8 | 36 | 55 | 0x02 | Slug | 0x00 | (36, 55, 0x02) |
| M9 | 38 | 13 | 0x02 | Slug | 0x00 | (38, 13, 0x02) |
| M10 | 52 | 55 | 0x02 | Slug | 0x00 | (52, 55, 0x02) |
| M11 | 55 | 13 | 0x03 | Bat | 0x00 | (55, 13, 0x03) |
| M12 | 56 | 44 | 0x02 | Slug | 0x00 | (56, 44, 0x02) |
| M13 | 68 | 44 | 0x01 | Toad | 0x00 | (68, 44, 0x01) |
| M14 | 71 | 13 | 0x02 | Slug | 0x00 | (71, 13, 0x02) |
| M15 | 71 | 23 | 0x02 | Slug | 0x00 | (71, 23, 0x02) |
| M16 | 82 | 55 | 0x02 | Slug | 0x00 | (82, 55, 0x02) |
| M17 | 83 | 19 | 0x04 | Rat | 0x00 | (83, 19, 0x04) |
| M18 | 89 | 49 | 0x04 | Rat | 0x00 | (89, 49, 0x04) |
| M19 | 93 | 14 | 0x03 | Bat | 0x00 | (93, 14, 0x03) |
| M20 | 107 | 25 | 0x01 | Toad | 0x00 | (107, 25, 0x01) |
| M21 | 109 | 14 | 0x02 | Slug | 0x00 | (109, 14, 0x02) |
| M22 | 130 | 31 | 0x04 | Rat | 0x00 | (130, 31, 0x04) |
| M23 | 130 | 37 | 0x02 | Slug | 0x00 | (130, 37, 0x02) |
| M24 | 137 | 46 | 0x04 | Rat | 0x00 | (137, 46, 0x04) |
| M25 | 142 | 56 | 0x02 | Slug | 0x00 | (142, 56, 0x02) |
| M26 | 143 | 28 | 0x04 | Rat | 0x00 | (143, 28, 0x04) |
| M27 | 147 | 14 | 0x02 | Slug | 0x00 | (147, 14, 0x02) |
| M28 | 152 | 7 | 0x04 | Rat | 0x00 | (152, 7, 0x04) |
| M29 | 156 | 50 | 0x04 | Rat | 0x00 | (156, 50, 0x04) |
| M30 | 156 | 56 | 0x03 | Bat | 0x00 | (156, 56, 0x03) |
| M31 | 162 | 51 | 0x04 | Rat | 0x00 | (162, 51, 0x04) |
| M32 | 163 | 2 | 0x03 | Bat | 0x00 | (163, 2, 0x03) |
| M33 | 164 | 9 | 0x04 | Rat | 0x00 | (164, 9, 0x04) |
| M34 | 168 | 24 | 0x03 | Bat | 0x00 | (168, 24, 0x03) |
| M35 | 172 | 34 | 0x04 | Rat | 0x00 | (172, 34, 0x04) |
| M36 | 176 | 32 | 0x04 | Rat | 0x00 | (176, 32, 0x04) |
| M37 | 179 | 2 | 0x03 | Bat | 0x00 | (179, 2, 0x03) |
| M38 | 184 | 24 | 0x02 | Slug | 0x00 | (184, 24, 0x02) |
| M39 | 195 | 63 | 0x02 | Slug | 0x00 | (195, 63, 0x02) |
| M40 | 198 | 5 | 0x04 | Rat | 0x00 | (198, 5, 0x04) |
| M41 | 210 | 37 | 0x02 | Slug | 0x00 | (210, 37, 0x02) |
| M42 | 211 | 11 | 0x02 | Slug | 0x00 | (211, 11, 0x02) |
| M43 | 211 | 25 | 0x01 | Toad | 0x00 | (211, 25, 0x01) |
| M44 | 216 | 38 | 0x02 | Slug | 0x00 | (216, 38, 0x02) |
| M45 | 222 | 25 | 0x03 | Bat | 0x00 | (222, 25, 0x03) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 47 | 63 | 0xD0 | 0x00 | `2F 00 3F FF D0 00 00 20 00 18 00 0B 00 04 00 00` |
| I2 | 67 | 34 | 0x7C | 0x00 | `43 00 22 FF 7C 00 00 00 00 00 00 FF FF FF 00 00` |
| I3 | 68 | 42 | 0x00 | 0x00 | `44 00 2A FF 00 00 00 10 00 00 00 44 00 2A 00 00` |
| I4 | 71 | 34 | 0x73 | 0x00 | `47 00 22 FF 73 00 00 29 00 05 00 0A 00 80 00 00` |
| I5 | 89 | 44 | 0x76 | 0x00 | `59 00 2C FF 76 00 00 20 00 00 00 0A 00 40 00 00` |
| I6 | 107 | 23 | 0x00 | 0x00 | `6B 00 17 FF 00 00 00 10 00 00 00 6B 00 17 00 00` |
| I7 | 149 | 44 | 0x76 | 0x00 | `95 00 2C FF 76 00 00 20 00 00 00 0A 00 20 00 00` |
| I8 | 179 | 24 | 0xD0 | 0x00 | `B3 00 18 FF D0 00 00 20 00 18 00 0A 00 10 00 00` |
| I9 | 185 | 11 | 0x73 | 0x00 | `B9 00 0B FF 73 00 01 20 00 00 00 0A 00 08 00 00` |
| I10 | 201 | 37 | 0x73 | 0x00 | `C9 00 25 FF 73 00 03 20 00 00 00 0A 00 04 00 00` |
| I11 | 211 | 23 | 0x00 | 0x00 | `D3 00 17 FF 00 00 00 10 00 00 00 D3 00 17 00 00` |

## 323MP21.mdt — 1-A. Muralla sub-area

- **width**: 96 tiles (height fixed at 64)
- **cavern level**: 0x02 (2)
- **tear coords**: (65535, 0)
- **doors**: 4, **monsters**: 7, **items**: 2

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 15 | 35 | 0x82 | MP20.MDT | Regular Door |
| D2 | 15 | 50 | 0xC3 | MP10.MDT | Locked Door  (Lion Key required) |
| D3 | 66 | 35 | 0xC2 | MP20.MDT | Regular Door |
| D4 | 79 | 50 | 0x83 | MP10.MDT | Locked Door  (Lion Key required) |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 7 | 6 | 0x02 | Slug | 0x00 | (7, 6, 0x02) |
| M2 | 14 | 26 | 0x04 | Rat | 0x00 | (14, 26, 0x04) |
| M3 | 15 | 15 | 0x02 | Slug | 0x00 | (15, 15, 0x02) |
| M4 | 43 | 31 | 0x04 | Rat | 0x00 | (43, 31, 0x04) |
| M5 | 46 | 24 | 0x02 | Slug | 0x00 | (46, 24, 0x02) |
| M6 | 78 | 30 | 0x02 | Slug | 0x00 | (78, 30, 0x02) |
| M7 | 88 | 3 | 0x03 | Bat | 0x00 | (88, 3, 0x03) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 17 | 43 | 0xD0 | 0x00 | `11 00 2B FF D0 00 00 20 00 1B 00 0A 00 02 00 00` |
| I2 | 80 | 61 | 0x73 | 0x00 | `50 00 3D FF 73 00 00 20 00 18 00 0A 00 01 00 00` |

## 324MP2D.mdt — 1-D. Muralla cavern (Cangrejo boss)

- **width**: 52 tiles (height fixed at 64)
- **cavern level**: 0x02 (2)
- **tear coords**: (65535, 0)
- **doors**: 0, **monsters**: 0, **items**: 0

## 325MP30.mdt — 2. Satono outdoor

- **width**: 204 tiles (height fixed at 64)
- **cavern level**: 0x03 (3)
- **tear coords**: (65535, 0)
- **doors**: 12, **monsters**: 30, **items**: 15

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 19 | 49 | 0x81 | MP31.MDT | Locked Door  (Lion Key required) |
| D2 | 21 | 6 | 0x80 | MP20.MDT | Regular Door |
| D3 | 22 | 23 | 0x83 | MP31.MDT | Locked Door  (Lion Key required) |
| D4 | 47 | 14 | 0x81 | MP31.MDT | Locked Door  (Lion Key required) |
| D5 | 52 | 37 | 0x82 | MP31.MDT | Regular Door |
| D6 | 86 | 47 | 0x84 | MP31.MDT | Regular Door |
| D7 | 88 | 6 | 0x83 | MP31.MDT | Locked Door  (Lion Key required) |
| D8 | 114 | 6 | 0x83 | MP31.MDT | Locked Door  (Lion Key required) |
| D9 | 118 | 28 | 0x84 | MP31.MDT | Regular Door |
| D10 | 153 | 43 | 0x82 | MP31.MDT | Regular Door |
| D11 | 185 | 18 | 0xC0 | BSMP.MDT  (3. Bosque Village) | Town Warp |
| D12 | 186 | 46 | 0x82 | MP31.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 10 | 49 | 0x01 | Blue Slime | 0x00 | (10, 49, 0x01) |
| M2 | 13 | 25 | 0x02 | Bat | 0x00 | (13, 25, 0x02) |
| M3 | 29 | 52 | 0x03 | Red Toad | 0x00 | (29, 52, 0x03) |
| M4 | 38 | 39 | 0x03 | Red Toad | 0x00 | (38, 39, 0x03) |
| M5 | 38 | 61 | 0x03 | Red Toad | 0x00 | (38, 61, 0x03) |
| M6 | 56 | 57 | 0x01 | Blue Slime | 0x00 | (56, 57, 0x01) |
| M7 | 62 | 16 | 0x02 | Bat | 0x00 | (62, 16, 0x02) |
| M8 | 63 | 39 | 0x02 | Bat | 0x00 | (63, 39, 0x02) |
| M9 | 64 | 27 | 0x01 | Blue Slime | 0x00 | (64, 27, 0x01) |
| M10 | 67 | 58 | 0x02 | Bat | 0x00 | (67, 58, 0x02) |
| M11 | 69 | 8 | 0x02 | Bat | 0x00 | (69, 8, 0x02) |
| M12 | 71 | 49 | 0x03 | Red Toad | 0x00 | (71, 49, 0x03) |
| M13 | 76 | 16 | 0x01 | Blue Slime | 0x00 | (76, 16, 0x01) |
| M14 | 97 | 28 | 0x03 | Red Toad | 0x00 | (97, 28, 0x03) |
| M15 | 97 | 49 | 0x03 | Red Toad | 0x00 | (97, 49, 0x03) |
| M16 | 106 | 31 | 0x03 | Red Toad | 0x00 | (106, 31, 0x03) |
| M17 | 118 | 55 | 0x01 | Blue Slime | 0x00 | (118, 55, 0x01) |
| M18 | 121 | 45 | 0x01 | Blue Slime | 0x00 | (121, 45, 0x01) |
| M19 | 126 | 8 | 0x02 | Bat | 0x00 | (126, 8, 0x02) |
| M20 | 139 | 30 | 0x02 | Bat | 0x00 | (139, 30, 0x02) |
| M21 | 142 | 13 | 0x02 | Bat | 0x00 | (142, 13, 0x02) |
| M22 | 150 | 2 | 0x02 | Bat | 0x00 | (150, 2, 0x02) |
| M23 | 157 | 2 | 0x01 | Blue Slime | 0x00 | (157, 2, 0x01) |
| M24 | 158 | 55 | 0x02 | Bat | 0x00 | (158, 55, 0x02) |
| M25 | 163 | 13 | 0x01 | Blue Slime | 0x00 | (163, 13, 0x01) |
| M26 | 164 | 46 | 0x7C | special-7C | 0x00 | (65535, 255, 0x0F) |
| M27 | 166 | 54 | 0xD0 | special-D0 | 0x00 | (18, 8, 0x0F) |
| M28 | 188 | 63 | 0x01 | Blue Slime | 0x00 | (188, 63, 0x01) |
| M29 | 198 | 63 | 0x02 | Bat | 0x00 | (198, 63, 0x02) |
| M30 | 201 | 48 | 0x02 | Bat | 0x00 | (201, 48, 0x02) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 38 | 45 | 0x00 | 0x00 | `26 00 2D FF 00 00 00 00 00 00 00 26 00 2D 00 00` |
| I2 | 40 | 2 | 0x00 | 0x00 | `28 00 02 FF 00 00 00 00 00 00 00 28 00 02 00 00` |
| I3 | 96 | 13 | 0x00 | 0x00 | `60 00 0D FF 00 00 00 00 00 00 00 60 00 0D 00 00` |
| I4 | 97 | 56 | 0x00 | 0x00 | `61 00 38 FF 00 00 00 00 00 00 00 61 00 38 00 00` |
| I5 | 99 | 28 | 0xD0 | 0x00 | `63 00 1C FF D0 00 00 20 00 18 00 12 00 80 00 00` |
| I6 | 106 | 13 | 0x00 | 0x00 | `6A 00 0D FF 00 00 00 00 00 00 00 6A 00 0D 00 00` |
| I7 | 106 | 37 | 0x00 | 0x00 | `6A 00 25 FF 00 00 00 00 00 00 00 6A 00 25 00 00` |
| I8 | 106 | 61 | 0x00 | 0x00 | `6A 00 3D FF 00 00 00 00 00 00 00 6A 00 3D 00 00` |
| I9 | 133 | 55 | 0x76 | 0x00 | `85 00 37 FF 76 00 00 20 00 00 00 12 00 40 00 00` |
| I10 | 141 | 55 | 0x73 | 0x00 | `8D 00 37 FF 73 00 00 20 00 18 00 12 00 20 00 00` |
| I11 | 157 | 7 | 0x00 | 0x00 | `9D 00 07 FF 00 00 00 00 00 00 00 9D 00 07 00 00` |
| I12 | 162 | 52 | 0x00 | 0x00 | `A2 00 34 FF 00 00 00 00 00 00 00 A2 00 34 00 00` |
| I13 | 164 | 60 | 0x00 | 0x00 | `A4 00 3C FF 00 00 00 00 00 00 00 A4 00 3C 00 00` |
| I14 | 166 | 31 | 0xD0 | 0x00 | `A6 00 1F FF D0 00 00 20 00 18 00 12 00 10 00 00` |
| I15 | 176 | 51 | 0x73 | 0x00 | `B0 00 33 FF 73 00 01 20 00 00 00 12 00 04 00 00` |

## 326MP31.mdt — 2-A. Satono sub-area

- **width**: 204 tiles (height fixed at 64)
- **cavern level**: 0x03 (3)
- **tear coords**: (188, 21)
- **doors**: 14, **monsters**: 36, **items**: 12

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 19 | 49 | 0xC1 | MP30.MDT | Locked Door  (Lion Key required) |
| D2 | 22 | 23 | 0xC3 | MP30.MDT | Locked Door  (Lion Key required) |
| D3 | 47 | 14 | 0xC1 | MP30.MDT | Locked Door  (Lion Key required) |
| D4 | 52 | 37 | 0xC2 | MP30.MDT | Regular Door |
| D5 | 86 | 47 | 0xC4 | MP30.MDT | Regular Door |
| D6 | 88 | 6 | 0xC3 | MP30.MDT | Locked Door  (Lion Key required) |
| D7 | 114 | 6 | 0xC3 | MP30.MDT | Locked Door  (Lion Key required) |
| D8 | 118 | 28 | 0xC4 | MP30.MDT | Regular Door |
| D9 | 149 | 13 | 0x80 | BSMP.MDT  (3. Bosque Village) | Town Warp |
| D10 | 153 | 43 | 0xC2 | MP30.MDT | Regular Door |
| D11 | 174 | 4 | 0xC2 | MP3D.MDT | Regular Door |
| D12 | 186 | 46 | 0xC2 | MP30.MDT | Regular Door |
| D13 | 188 | 20 | 0x01 | MP3D.MDT | Locked Door  (Lion Key required) |
| D14 | 192 | 4 | 0x40 | MP41.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 4 | 35 | 0x73 | special-73 | 0x00 | (18, 2, 0x0F) |
| M2 | 4 | 51 | 0x03 | Red Toad | 0x00 | (4, 51, 0x03) |
| M3 | 7 | 35 | 0x03 | Red Toad | 0x00 | (7, 35, 0x03) |
| M4 | 13 | 9 | 0x02 | Bat | 0x00 | (13, 9, 0x02) |
| M5 | 19 | 61 | 0x02 | Bat | 0x00 | (19, 61, 0x02) |
| M6 | 33 | 16 | 0x02 | Bat | 0x00 | (33, 16, 0x02) |
| M7 | 45 | 51 | 0x01 | Blue Slime | 0x00 | (45, 51, 0x01) |
| M8 | 48 | 30 | 0x01 | Blue Slime | 0x00 | (48, 30, 0x01) |
| M9 | 53 | 30 | 0x02 | Bat | 0x00 | (53, 30, 0x02) |
| M10 | 62 | 51 | 0x03 | Red Toad | 0x00 | (62, 51, 0x03) |
| M11 | 63 | 16 | 0x03 | Red Toad | 0x00 | (63, 16, 0x03) |
| M12 | 63 | 63 | 0x03 | Red Toad | 0x00 | (63, 63, 0x03) |
| M13 | 65 | 51 | 0xD0 | special-D0 | 0x00 | (65535, 255, 0x0F) |
| M14 | 72 | 8 | 0x03 | Red Toad | 0x00 | (72, 8, 0x03) |
| M15 | 72 | 25 | 0x03 | Red Toad | 0x00 | (72, 25, 0x03) |
| M16 | 82 | 17 | 0x02 | Bat | 0x00 | (82, 17, 0x02) |
| M17 | 82 | 40 | 0x02 | Bat | 0x00 | (82, 40, 0x02) |
| M18 | 83 | 59 | 0x02 | Bat | 0x00 | (83, 59, 0x02) |
| M19 | 95 | 59 | 0x03 | Red Toad | 0x00 | (95, 59, 0x03) |
| M20 | 103 | 8 | 0x02 | Bat | 0x00 | (103, 8, 0x02) |
| M21 | 110 | 40 | 0x02 | Bat | 0x00 | (110, 40, 0x02) |
| M22 | 111 | 18 | 0x02 | Bat | 0x00 | (111, 18, 0x02) |
| M23 | 118 | 59 | 0x02 | Bat | 0x00 | (118, 59, 0x02) |
| M24 | 125 | 59 | 0x01 | Blue Slime | 0x00 | (125, 59, 0x01) |
| M25 | 131 | 18 | 0x03 | Red Toad | 0x00 | (131, 18, 0x03) |
| M26 | 140 | 29 | 0x01 | Blue Slime | 0x00 | (140, 29, 0x01) |
| M27 | 140 | 45 | 0x03 | Red Toad | 0x00 | (140, 45, 0x03) |
| M28 | 142 | 56 | 0x03 | Red Toad | 0x00 | (142, 56, 0x03) |
| M29 | 149 | 56 | 0x02 | Bat | 0x00 | (149, 56, 0x02) |
| M30 | 160 | 29 | 0x02 | Bat | 0x00 | (160, 29, 0x02) |
| M31 | 161 | 56 | 0x01 | Blue Slime | 0x00 | (161, 56, 0x01) |
| M32 | 164 | 15 | 0x02 | Bat | 0x00 | (164, 15, 0x02) |
| M33 | 179 | 22 | 0x02 | Bat | 0x00 | (179, 22, 0x02) |
| M34 | 179 | 37 | 0x02 | Bat | 0x00 | (179, 37, 0x02) |
| M35 | 195 | 48 | 0x02 | Bat | 0x00 | (195, 48, 0x02) |
| M36 | 199 | 37 | 0x03 | Red Toad | 0x00 | (199, 37, 0x03) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 19 | 9 | 0xD0 | 0x00 | `13 00 09 FF D0 00 00 20 00 18 00 12 00 01 00 00` |
| I2 | 55 | 58 | 0x00 | 0x00 | `37 00 3A FF 00 00 00 00 00 00 00 37 00 3A 00 00` |
| I3 | 88 | 59 | 0xD0 | 0x00 | `58 00 3B FF D0 00 00 20 00 18 00 13 00 80 00 00` |
| I4 | 93 | 59 | 0x73 | 0x00 | `5D 00 3B FF 73 00 00 20 00 19 00 13 00 40 00 00` |
| I5 | 103 | 1 | 0x00 | 0x00 | `67 00 01 FF 00 00 00 00 00 00 00 67 00 01 00 00` |
| I6 | 128 | 35 | 0x00 | 0x00 | `80 00 23 FF 00 00 00 00 00 00 00 80 00 23 00 00` |
| I7 | 130 | 23 | 0x00 | 0x00 | `82 00 17 FF 00 00 00 00 00 00 00 82 00 17 00 00` |
| I8 | 130 | 46 | 0x00 | 0x00 | `82 00 2E FF 00 00 00 00 00 00 00 82 00 2E 00 00` |
| I9 | 131 | 2 | 0x00 | 0x00 | `83 00 02 FF 00 00 00 00 00 00 00 83 00 02 00 00` |
| I10 | 131 | 40 | 0x73 | 0x00 | `83 00 28 FF 73 00 03 20 00 00 00 13 00 20 00 00` |
| I11 | 133 | 30 | 0xD0 | 0x00 | `85 00 1E FF D0 00 00 00 00 00 00 FF FF FF 00 00` |
| I12 | 140 | 56 | 0x73 | 0x00 | `8C 00 38 FF 73 00 02 20 00 00 00 13 00 10 00 00` |

## 327MP3D.mdt — 2-D. Satono cavern (Pulpo boss)

- **width**: 73 tiles (height fixed at 64)
- **cavern level**: 0x03 (3)
- **tear coords**: (65535, 0)
- **doors**: 0, **monsters**: 0, **items**: 0

## 328MP40.mdt — 3. Bosque outdoor

- **width**: 320 tiles (height fixed at 64)
- **cavern level**: 0x04 (4)
- **tear coords**: (224, 19)
- **doors**: 6, **monsters**: 38, **items**: 31

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 22 | 9 | 0x83 | MP41.MDT | Locked Door  (Lion Key required) |
| D2 | 86 | 9 | 0x02 | MP41.MDT | Regular Door |
| D3 | 86 | 21 | 0x80 | CMAP.MDT  (0. Felishika Castle) | Town Warp |
| D4 | 119 | 21 | 0x83 | MP41.MDT | Locked Door  (Lion Key required) |
| D5 | 224 | 18 | 0x01 | MP4D.MDT | Locked Door  (Lion Key required) |
| D6 | 245 | 53 | 0x84 | MP41.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 24 | 46 | 0x02 | Bug | 0x00 | (24, 46, 0x02) |
| M2 | 61 | 56 | 0x04 | Clay Ball | 0x00 | (61, 56, 0x04) |
| M3 | 76 | 45 | 0x04 | Clay Ball | 0x00 | (76, 45, 0x04) |
| M4 | 102 | 52 | 0x01 | Earthworm | 0x00 | (102, 52, 0x01) |
| M5 | 111 | 5 | 0x03 | Crab | 0x00 | (111, 5, 0x03) |
| M6 | 122 | 9 | 0x01 | Earthworm | 0x00 | (122, 9, 0x01) |
| M7 | 123 | 59 | 0x03 | Crab | 0x00 | (123, 59, 0x03) |
| M8 | 128 | 28 | 0x03 | Crab | 0x00 | (128, 28, 0x03) |
| M9 | 137 | 34 | 0x01 | Earthworm | 0x00 | (137, 34, 0x01) |
| M10 | 147 | 39 | 0x02 | Bug | 0x00 | (147, 39, 0x02) |
| M11 | 150 | 28 | 0x03 | Crab | 0x00 | (150, 28, 0x03) |
| M12 | 152 | 22 | 0x01 | Earthworm | 0x00 | (152, 22, 0x01) |
| M13 | 153 | 49 | 0x02 | Bug | 0x00 | (153, 49, 0x02) |
| M14 | 154 | 11 | 0x02 | Bug | 0x00 | (154, 11, 0x02) |
| M15 | 156 | 63 | 0x03 | Crab | 0x00 | (156, 63, 0x03) |
| M16 | 159 | 5 | 0x01 | Earthworm | 0x00 | (159, 5, 0x01) |
| M17 | 165 | 28 | 0x03 | Crab | 0x00 | (165, 28, 0x03) |
| M18 | 168 | 44 | 0x01 | Earthworm | 0x00 | (168, 44, 0x01) |
| M19 | 180 | 62 | 0x03 | Crab | 0x00 | (180, 62, 0x03) |
| M20 | 182 | 28 | 0x03 | Crab | 0x00 | (182, 28, 0x03) |
| M21 | 201 | 55 | 0x01 | Earthworm | 0x00 | (201, 55, 0x01) |
| M22 | 209 | 25 | 0x03 | Crab | 0x00 | (209, 25, 0x03) |
| M23 | 210 | 43 | 0x02 | Bug | 0x00 | (210, 43, 0x02) |
| M24 | 213 | 20 | 0x01 | Earthworm | 0x00 | (213, 20, 0x01) |
| M25 | 218 | 55 | 0x03 | Crab | 0x00 | (218, 55, 0x03) |
| M26 | 222 | 38 | 0x01 | Earthworm | 0x00 | (222, 38, 0x01) |
| M27 | 230 | 57 | 0x02 | Bug | 0x00 | (230, 57, 0x02) |
| M28 | 231 | 48 | 0x01 | Earthworm | 0x00 | (231, 48, 0x01) |
| M29 | 239 | 7 | 0x02 | Bug | 0x00 | (239, 7, 0x02) |
| M30 | 240 | 60 | 0x02 | Bug | 0x00 | (240, 60, 0x02) |
| M31 | 242 | 38 | 0x03 | Crab | 0x00 | (242, 38, 0x03) |
| M32 | 245 | 36 | 0x02 | Bug | 0x00 | (245, 36, 0x02) |
| M33 | 248 | 44 | 0x01 | Earthworm | 0x00 | (248, 44, 0x01) |
| M34 | 262 | 15 | 0x04 | Clay Ball | 0x00 | (262, 15, 0x04) |
| M35 | 274 | 60 | 0x03 | Crab | 0x00 | (274, 60, 0x03) |
| M36 | 280 | 49 | 0x03 | Crab | 0x00 | (280, 49, 0x03) |
| M37 | 286 | 36 | 0x03 | Crab | 0x00 | (286, 36, 0x03) |
| M38 | 292 | 49 | 0x02 | Bug | 0x00 | (292, 49, 0x02) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 7 | 30 | 0x76 | 0x00 | `07 00 1E FF 76 00 00 20 00 00 00 1A 00 80 00 00` |
| I2 | 9 | 51 | 0x00 | 0x00 | `09 00 33 FF 00 00 00 00 00 00 00 09 00 33 00 00` |
| I3 | 24 | 41 | 0x00 | 0x00 | `18 00 29 FF 00 00 00 00 00 00 00 18 00 29 00 00` |
| I4 | 68 | 30 | 0x00 | 0x00 | `44 00 1E FF 00 00 00 00 00 00 00 44 00 1E 00 00` |
| I5 | 70 | 16 | 0xD0 | 0x00 | `46 00 10 FF D0 00 00 20 00 18 00 1A 00 40 00 00` |
| I6 | 114 | 52 | 0x00 | 0x00 | `72 00 34 FF 00 00 00 00 00 00 00 72 00 34 00 00` |
| I7 | 132 | 22 | 0xD0 | 0x00 | `84 00 16 FF D0 00 00 20 00 18 00 1A 00 20 00 00` |
| I8 | 136 | 22 | 0x00 | 0x00 | `88 00 16 FF 00 00 00 00 00 00 00 88 00 16 00 00` |
| I9 | 177 | 13 | 0x7A | 0x00 | `B1 00 0D FF 7A 00 00 20 00 00 00 1A 00 10 00 00` |
| I10 | 190 | 36 | 0x00 | 0x00 | `BE 00 24 FF 00 00 00 00 00 00 00 BE 00 24 00 00` |
| I11 | 206 | 55 | 0xD0 | 0x00 | `CE 00 37 FF D0 00 00 20 00 19 00 1A 00 08 00 00` |
| I12 | 220 | 48 | 0x00 | 0x00 | `DC 00 30 FF 00 00 00 00 00 00 00 DC 00 30 00 00` |
| I13 | 230 | 29 | 0x73 | 0x00 | `E6 00 1D FF 73 00 00 20 00 19 00 1A 00 04 00 00` |
| I14 | 231 | 38 | 0xD0 | 0x00 | `E7 00 26 FF D0 00 00 00 00 00 00 FF FF FF 00 00` |
| I15 | 236 | 46 | 0xD0 | 0x00 | `EC 00 2E FF D0 00 00 20 00 18 00 1A 00 02 00 00` |
| I16 | 239 | 29 | 0x00 | 0x00 | `EF 00 1D FF 00 00 00 00 00 00 00 EF 00 1D 00 00` |
| I17 | 240 | 44 | 0x73 | 0x00 | `F0 00 2C FF 73 00 02 20 00 00 00 1A 00 01 00 00` |
| I18 | 257 | 54 | 0x00 | 0x00 | `01 01 36 FF 00 00 00 00 00 00 00 01 01 36 00 00` |
| I19 | 267 | 7 | 0x00 | 0x00 | `0B 01 07 FF 00 00 00 00 00 00 00 0B 01 07 00 00` |
| I20 | 270 | 29 | 0x00 | 0x00 | `0E 01 1D FF 00 00 00 00 00 00 00 0E 01 1D 00 00` |
| I21 | 279 | 43 | 0x00 | 0x00 | `17 01 2B FF 00 00 00 00 00 00 00 17 01 2B 00 00` |
| I22 | 294 | 21 | 0x00 | 0x00 | `26 01 15 FF 00 00 00 00 00 00 00 26 01 15 00 00` |
| I23 | 318 | 61 | 0x00 | 0x00 | `3E 01 3D FF 00 00 00 00 00 00 00 3E 01 3D 00 00` |
| I24 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I25 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I26 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I27 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I28 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I29 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I30 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I31 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |

## 329MP41.mdt — 3-A. Bosque sub-area

- **width**: 192 tiles (height fixed at 64)
- **cavern level**: 0x04 (4)
- **tear coords**: (65535, 0)
- **doors**: 6, **monsters**: 14, **items**: 22

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 16 | 9 | 0xC2 | MP40.MDT | Regular Door |
| D2 | 16 | 21 | 0x40 | CMAP.MDT  (0. Felishika Castle) | Town Warp |
| D3 | 16 | 34 | 0xC3 | MP40.MDT | Locked Door  (Lion Key required) |
| D4 | 56 | 55 | 0xC3 | MP40.MDT | Locked Door  (Lion Key required) |
| D5 | 99 | 53 | 0x80 | MP31.MDT | Regular Door |
| D6 | 174 | 51 | 0xC4 | MP40.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 15 | 62 | 0x01 | Earthworm | 0x00 | (15, 62, 0x01) |
| M2 | 19 | 52 | 0x02 | Bug | 0x00 | (19, 52, 0x02) |
| M3 | 23 | 62 | 0x01 | Earthworm | 0x00 | (23, 62, 0x01) |
| M4 | 29 | 36 | 0x01 | Earthworm | 0x00 | (29, 36, 0x01) |
| M5 | 42 | 63 | 0x03 | Crab | 0x00 | (42, 63, 0x03) |
| M6 | 98 | 25 | 0x03 | Crab | 0x00 | (98, 25, 0x03) |
| M7 | 103 | 38 | 0x02 | Bug | 0x00 | (103, 38, 0x02) |
| M8 | 105 | 38 | 0x03 | Crab | 0x00 | (105, 38, 0x03) |
| M9 | 107 | 38 | 0x02 | Bug | 0x00 | (107, 38, 0x02) |
| M10 | 116 | 42 | 0x01 | Earthworm | 0x00 | (116, 42, 0x01) |
| M11 | 131 | 52 | 0x04 | Clay Ball | 0x00 | (131, 52, 0x04) |
| M12 | 138 | 14 | 0x03 | Crab | 0x00 | (138, 14, 0x03) |
| M13 | 142 | 42 | 0x01 | Earthworm | 0x00 | (142, 42, 0x01) |
| M14 | 149 | 10 | 0x03 | Crab | 0x00 | (149, 10, 0x03) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 42 | 30 | 0x00 | 0x00 | `2A 00 1E FF 00 00 00 00 00 00 00 2A 00 1E 00 00` |
| I2 | 51 | 18 | 0x73 | 0x00 | `33 00 12 FF 73 00 01 20 00 00 00 1B 00 20 00 00` |
| I3 | 72 | 22 | 0x73 | 0x00 | `48 00 16 FF 73 00 00 20 00 19 00 1B 00 10 00 00` |
| I4 | 75 | 30 | 0x00 | 0x00 | `4B 00 1E FF 00 00 00 00 00 00 00 4B 00 1E 00 00` |
| I5 | 78 | 22 | 0x76 | 0x00 | `4E 00 16 FF 76 00 00 20 00 00 00 1B 00 08 00 00` |
| I6 | 81 | 42 | 0x00 | 0x00 | `51 00 2A FF 00 00 00 00 00 00 00 51 00 2A 00 00` |
| I7 | 99 | 17 | 0x00 | 0x00 | `63 00 11 FF 00 00 00 00 00 00 00 63 00 11 00 00` |
| I8 | 116 | 30 | 0x73 | 0x00 | `74 00 1E FF 73 00 00 20 00 18 00 1B 00 04 00 00` |
| I9 | 122 | 56 | 0x73 | 0x00 | `7A 00 38 FF 73 00 00 20 00 19 00 1B 00 02 00 00` |
| I10 | 154 | 51 | 0x76 | 0x00 | `9A 00 33 FF 76 00 00 20 00 00 00 1B 00 01 00 00` |
| I11 | 183 | 53 | 0xD0 | 0x00 | `B7 00 35 FF D0 00 00 20 00 19 00 1C 00 80 00 00` |
| I12 | 184 | 42 | 0x00 | 0x00 | `B8 00 2A FF 00 00 00 00 00 00 00 B8 00 2A 00 00` |
| I13 | 185 | 17 | 0xD0 | 0x00 | `B9 00 11 FF D0 00 00 20 00 18 00 1C 00 40 00 00` |
| I14 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I15 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I16 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I17 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I18 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I19 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I20 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I21 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I22 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |

## 330MP4D.mdt — 3-D. Bosque cavern (Pollo boss)

- **width**: 73 tiles (height fixed at 64)
- **cavern level**: 0x04 (4)
- **tear coords**: (65535, 0)
- **doors**: 0, **monsters**: 0, **items**: 0

## 331MP50.mdt — 4. Helada outdoor

- **width**: 240 tiles (height fixed at 64)
- **cavern level**: 0x05 (5)
- **tear coords**: (65535, 255)
- **doors**: 9, **monsters**: 49, **items**: 24

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 9 | 25 | 0xC2 | MP51.MDT | Regular Door |
| D2 | 25 | 14 | 0xC2 | MP4D.MDT | Regular Door |
| D3 | 88 | 34 | 0xC3 | MP51.MDT | Locked Door  (Lion Key required) |
| D4 | 94 | 10 | 0x80 | ?[0x85] | Town Warp |
| D5 | 100 | 59 | 0xC4 | MP51.MDT | Regular Door |
| D6 | 131 | 9 | 0xC0 | ?[0x85] | Town Warp |
| D7 | 131 | 53 | 0x42 | MP51.MDT | Regular Door |
| D8 | 141 | 62 | 0xC2 | MP51.MDT | Regular Door |
| D9 | 206 | 39 | 0xC4 | MP51.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 3 | 47 | 0x04 | (4th enemy) | 0x00 | (3, 47, 0x04) |
| M2 | 9 | 16 | 0x02 | Green Slime | 0x00 | (9, 16, 0x02) |
| M3 | 11 | 2 | 0x01 | Turtle | 0x00 | (11, 2, 0x01) |
| M4 | 11 | 21 | 0x04 | (4th enemy) | 0x00 | (11, 21, 0x04) |
| M5 | 14 | 34 | 0x04 | (4th enemy) | 0x00 | (14, 34, 0x04) |
| M6 | 14 | 40 | 0x03 | Arrow | 0x00 | (14, 40, 0x03) |
| M7 | 22 | 2 | 0x03 | Arrow | 0x00 | (22, 2, 0x03) |
| M8 | 26 | 40 | 0x02 | Green Slime | 0x00 | (26, 40, 0x02) |
| M9 | 27 | 27 | 0x01 | Turtle | 0x00 | (27, 27, 0x01) |
| M10 | 27 | 51 | 0x03 | Arrow | 0x00 | (27, 51, 0x03) |
| M11 | 30 | 34 | 0x04 | (4th enemy) | 0x00 | (30, 34, 0x04) |
| M12 | 32 | 58 | 0x04 | (4th enemy) | 0x00 | (32, 58, 0x04) |
| M13 | 40 | 58 | 0x04 | (4th enemy) | 0x00 | (40, 58, 0x04) |
| M14 | 47 | 16 | 0x03 | Arrow | 0x00 | (47, 16, 0x03) |
| M15 | 49 | 2 | 0x03 | Arrow | 0x00 | (49, 2, 0x03) |
| M16 | 74 | 31 | 0x04 | (4th enemy) | 0x00 | (74, 31, 0x04) |
| M17 | 82 | 22 | 0x02 | Green Slime | 0x00 | (82, 22, 0x02) |
| M18 | 86 | 4 | 0x04 | (4th enemy) | 0x00 | (86, 4, 0x04) |
| M19 | 87 | 31 | 0x04 | (4th enemy) | 0x00 | (87, 31, 0x04) |
| M20 | 88 | 51 | 0x02 | Green Slime | 0x00 | (88, 51, 0x02) |
| M21 | 90 | 57 | 0x04 | (4th enemy) | 0x00 | (90, 57, 0x04) |
| M22 | 94 | 22 | 0x02 | Green Slime | 0x00 | (94, 22, 0x02) |
| M23 | 101 | 51 | 0x02 | Green Slime | 0x00 | (101, 51, 0x02) |
| M24 | 110 | 7 | 0x04 | (4th enemy) | 0x00 | (110, 7, 0x04) |
| M25 | 129 | 22 | 0x04 | (4th enemy) | 0x00 | (129, 22, 0x04) |
| M26 | 130 | 0 | 0x03 | Arrow | 0x00 | (130, 0, 0x03) |
| M27 | 134 | 0 | 0x02 | Green Slime | 0x00 | (134, 0, 0x02) |
| M28 | 134 | 29 | 0x02 | Green Slime | 0x00 | (134, 29, 0x02) |
| M29 | 136 | 42 | 0x02 | Green Slime | 0x00 | (136, 42, 0x02) |
| M30 | 138 | 21 | 0x04 | (4th enemy) | 0x00 | (138, 21, 0x04) |
| M31 | 141 | 29 | 0x03 | Arrow | 0x00 | (141, 29, 0x03) |
| M32 | 144 | 42 | 0x02 | Green Slime | 0x00 | (144, 42, 0x02) |
| M33 | 149 | 22 | 0x04 | (4th enemy) | 0x00 | (149, 22, 0x04) |
| M34 | 152 | 9 | 0x04 | (4th enemy) | 0x00 | (152, 9, 0x04) |
| M35 | 155 | 62 | 0x02 | Green Slime | 0x00 | (155, 62, 0x02) |
| M36 | 166 | 8 | 0x04 | (4th enemy) | 0x00 | (166, 8, 0x04) |
| M37 | 169 | 17 | 0x02 | Green Slime | 0x00 | (169, 17, 0x02) |
| M38 | 179 | 17 | 0x02 | Green Slime | 0x00 | (179, 17, 0x02) |
| M39 | 179 | 37 | 0x04 | (4th enemy) | 0x00 | (179, 37, 0x04) |
| M40 | 182 | 30 | 0x02 | Green Slime | 0x00 | (182, 30, 0x02) |
| M41 | 191 | 43 | 0x02 | Green Slime | 0x00 | (191, 43, 0x02) |
| M42 | 193 | 1 | 0x02 | Green Slime | 0x00 | (193, 1, 0x02) |
| M43 | 208 | 0 | 0x03 | Arrow | 0x00 | (208, 0, 0x03) |
| M44 | 208 | 52 | 0x01 | Turtle | 0x00 | (208, 52, 0x01) |
| M45 | 214 | 28 | 0x03 | Arrow | 0x00 | (214, 28, 0x03) |
| M46 | 216 | 17 | 0x02 | Green Slime | 0x00 | (216, 17, 0x02) |
| M47 | 224 | 0 | 0x03 | Arrow | 0x00 | (224, 0, 0x03) |
| M48 | 233 | 16 | 0x01 | Turtle | 0x00 | (233, 16, 0x01) |
| M49 | 233 | 40 | 0x01 | Turtle | 0x00 | (233, 40, 0x01) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 7 | 51 | 0x73 | 0x00 | `07 00 33 FF 73 00 00 20 00 18 00 22 00 80 00 00` |
| I2 | 11 | 0 | 0x00 | 0x00 | `0B 00 00 FF 00 00 00 10 00 00 00 0B 00 00 00 00` |
| I3 | 27 | 25 | 0x00 | 0x00 | `1B 00 19 FF 00 00 00 10 00 00 00 1B 00 19 00 00` |
| I4 | 65 | 27 | 0xD0 | 0x00 | `41 00 1B FF D0 00 00 20 00 18 00 22 00 40 00 00` |
| I5 | 78 | 14 | 0xF1 | 0x00 | `4E 00 0E FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I6 | 84 | 14 | 0xF1 | 0x00 | `54 00 0E FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I7 | 115 | 43 | 0x73 | 0x00 | `73 00 2B FF 73 00 04 20 00 00 00 22 00 20 00 00` |
| I8 | 170 | 29 | 0x73 | 0x00 | `AA 00 1D FF 73 00 00 20 00 19 00 22 00 10 00 00` |
| I9 | 175 | 52 | 0x73 | 0x00 | `AF 00 34 FF 73 00 04 20 00 00 00 22 00 08 00 00` |
| I10 | 192 | 52 | 0x73 | 0x00 | `C0 00 34 FF 73 00 01 20 00 00 00 22 00 04 00 00` |
| I11 | 208 | 27 | 0x73 | 0x00 | `D0 00 1B FF 73 00 00 20 00 1A 00 22 00 02 00 00` |
| I12 | 208 | 50 | 0x00 | 0x00 | `D0 00 32 FF 00 00 00 10 00 00 00 D0 00 32 00 00` |
| I13 | 209 | 16 | 0x73 | 0x00 | `D1 00 10 FF 73 00 02 20 00 00 00 22 00 01 00 00` |
| I14 | 233 | 14 | 0x00 | 0x00 | `E9 00 0E FF 00 00 00 10 00 00 00 E9 00 0E 00 00` |
| I15 | 233 | 38 | 0x00 | 0x00 | `E9 00 26 FF 00 00 00 10 00 00 00 E9 00 26 00 00` |
| I16 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I17 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I18 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I19 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I20 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I21 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I22 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I23 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I24 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |

## 332MP51.mdt — 4-A. Helada sub-area

- **width**: 240 tiles (height fixed at 64)
- **cavern level**: 0x05 (5)
- **tear coords**: (157, 17)
- **doors**: 7, **monsters**: 36, **items**: 34

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 9 | 25 | 0x82 | MP50.MDT | Regular Door |
| D2 | 88 | 34 | 0x83 | MP50.MDT | Locked Door  (Lion Key required) |
| D3 | 100 | 59 | 0x84 | MP50.MDT | Regular Door |
| D4 | 131 | 53 | 0x82 | MP50.MDT | Regular Door |
| D5 | 141 | 62 | 0x82 | MP50.MDT | Regular Door |
| D6 | 157 | 16 | 0x01 | MP5D.MDT | Locked Door  (Lion Key required) |
| D7 | 206 | 39 | 0x84 | MP50.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 3 | 43 | 0x02 | Green Slime | 0x00 | (3, 43, 0x02) |
| M2 | 5 | 59 | 0x02 | Green Slime | 0x00 | (5, 59, 0x02) |
| M3 | 8 | 17 | 0x03 | Arrow | 0x00 | (8, 17, 0x03) |
| M4 | 15 | 43 | 0x02 | Green Slime | 0x00 | (15, 43, 0x02) |
| M5 | 18 | 60 | 0x03 | Arrow | 0x00 | (18, 60, 0x03) |
| M6 | 23 | 23 | 0x04 | (4th enemy) | 0x00 | (23, 23, 0x04) |
| M7 | 25 | 3 | 0x04 | (4th enemy) | 0x00 | (25, 3, 0x04) |
| M8 | 31 | 60 | 0x03 | Arrow | 0x00 | (31, 60, 0x03) |
| M9 | 33 | 3 | 0x04 | (4th enemy) | 0x00 | (33, 3, 0x04) |
| M10 | 36 | 36 | 0x01 | Turtle | 0x00 | (36, 36, 0x01) |
| M11 | 44 | 17 | 0x03 | Arrow | 0x00 | (44, 17, 0x03) |
| M12 | 58 | 8 | 0x02 | Green Slime | 0x00 | (58, 8, 0x02) |
| M13 | 59 | 54 | 0x02 | Green Slime | 0x00 | (59, 54, 0x02) |
| M14 | 72 | 36 | 0x01 | Turtle | 0x00 | (72, 36, 0x01) |
| M15 | 81 | 46 | 0x03 | Arrow | 0x00 | (81, 46, 0x03) |
| M16 | 83 | 24 | 0x02 | Green Slime | 0x00 | (83, 24, 0x02) |
| M17 | 88 | 3 | 0x04 | (4th enemy) | 0x00 | (88, 3, 0x04) |
| M18 | 93 | 55 | 0x04 | (4th enemy) | 0x00 | (93, 55, 0x04) |
| M19 | 96 | 7 | 0x03 | Arrow | 0x00 | (96, 7, 0x03) |
| M20 | 99 | 46 | 0x03 | Arrow | 0x00 | (99, 46, 0x03) |
| M21 | 100 | 36 | 0x03 | Arrow | 0x00 | (100, 36, 0x03) |
| M22 | 109 | 30 | 0x02 | Green Slime | 0x00 | (109, 30, 0x02) |
| M23 | 120 | 16 | 0x03 | Arrow | 0x00 | (120, 16, 0x03) |
| M24 | 141 | 38 | 0x02 | Green Slime | 0x00 | (141, 38, 0x02) |
| M25 | 144 | 9 | 0x03 | Arrow | 0x00 | (144, 9, 0x03) |
| M26 | 147 | 56 | 0x02 | Green Slime | 0x00 | (147, 56, 0x02) |
| M27 | 150 | 24 | 0x01 | Turtle | 0x00 | (150, 24, 0x01) |
| M28 | 152 | 5 | 0x04 | (4th enemy) | 0x00 | (152, 5, 0x04) |
| M29 | 167 | 46 | 0x03 | Arrow | 0x00 | (167, 46, 0x03) |
| M30 | 172 | 36 | 0x02 | Green Slime | 0x00 | (172, 36, 0x02) |
| M31 | 185 | 27 | 0x02 | Green Slime | 0x00 | (185, 27, 0x02) |
| M32 | 191 | 56 | 0x02 | Green Slime | 0x00 | (191, 56, 0x02) |
| M33 | 195 | 24 | 0x04 | (4th enemy) | 0x00 | (195, 24, 0x04) |
| M34 | 207 | 50 | 0x04 | (4th enemy) | 0x00 | (207, 50, 0x04) |
| M35 | 211 | 18 | 0x01 | Turtle | 0x00 | (211, 18, 0x01) |
| M36 | 224 | 14 | 0x04 | (4th enemy) | 0x00 | (224, 14, 0x04) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 26 | 35 | 0xD0 | 0x00 | `1A 00 23 FF D0 00 00 20 00 19 00 23 00 40 00 00` |
| I2 | 28 | 19 | 0xF1 | 0x00 | `1C 00 13 FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I3 | 30 | 19 | 0xF1 | 0x00 | `1E 00 13 FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I4 | 32 | 19 | 0xF1 | 0x00 | `20 00 13 FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I5 | 36 | 34 | 0x00 | 0x00 | `24 00 22 FF 00 00 00 10 00 00 00 24 00 22 00 00` |
| I6 | 72 | 34 | 0x00 | 0x00 | `48 00 22 FF 00 00 00 10 00 00 00 48 00 22 00 00` |
| I7 | 82 | 54 | 0x73 | 0x00 | `52 00 36 FF 73 00 05 20 00 00 00 23 00 20 00 00` |
| I8 | 97 | 16 | 0x76 | 0x00 | `61 00 10 FF 76 00 00 20 00 00 00 23 00 10 00 00` |
| I9 | 125 | 2 | 0xF1 | 0x00 | `7D 00 02 FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I10 | 133 | 40 | 0xF1 | 0x00 | `85 00 28 FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I11 | 135 | 40 | 0xF1 | 0x00 | `87 00 28 FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I12 | 137 | 40 | 0xF1 | 0x00 | `89 00 28 FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I13 | 143 | 40 | 0xF1 | 0x00 | `8F 00 28 FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I14 | 145 | 40 | 0xF1 | 0x00 | `91 00 28 FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I15 | 147 | 40 | 0xF1 | 0x00 | `93 00 28 FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I16 | 150 | 22 | 0x00 | 0x00 | `96 00 16 FF 00 00 00 10 00 00 00 96 00 16 00 00` |
| I17 | 158 | 24 | 0x73 | 0x00 | `9E 00 18 FF 73 00 01 20 00 00 00 23 00 08 00 00` |
| I18 | 181 | 18 | 0x73 | 0x00 | `B5 00 12 FF 73 00 00 20 00 19 00 23 00 04 00 00` |
| I19 | 191 | 18 | 0x76 | 0x00 | `BF 00 12 FF 76 00 00 20 00 00 00 23 00 02 00 00` |
| I20 | 206 | 11 | 0xF1 | 0x00 | `CE 00 0B FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I21 | 207 | 31 | 0x73 | 0x00 | `CF 00 1F FF 73 00 00 20 00 18 00 23 00 01 00 00` |
| I22 | 208 | 9 | 0x73 | 0x00 | `D0 00 09 FF 73 00 06 20 00 00 00 24 00 80 00 00` |
| I23 | 208 | 11 | 0xF1 | 0x00 | `D0 00 0B FF F1 00 00 00 00 00 00 FF FF FF 00 00` |
| I24 | 211 | 16 | 0x00 | 0x00 | `D3 00 10 FF 00 00 00 10 00 00 00 D3 00 10 00 00` |
| I25 | 226 | 41 | 0x73 | 0x00 | `E2 00 29 FF 73 00 00 20 00 19 00 24 00 20 00 00` |
| I26 | 226 | 60 | 0xD0 | 0x00 | `E2 00 3C FF D0 00 00 20 00 1B 00 24 00 40 00 00` |
| I27 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I28 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I29 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I30 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I31 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I32 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I33 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |
| I34 | 65280 | 0 | 0x00 | 0x00 | `00 FF 00 FF 00 00 00 00 00 00 00 FF FF 00 00 00` |

## 333MP5D.mdt — 4-D. Helada cavern (ice; Ruzeria gates)

- **width**: 73 tiles (height fixed at 64)
- **cavern level**: 0x05 (5)
- **tear coords**: (65535, 0)
- **doors**: 0, **monsters**: 0, **items**: 0

## 334MP60.mdt — 5. Tumba outdoor / 5-A. Tumba sub-area

- **width**: 320 tiles (height fixed at 64)
- **cavern level**: 0x06 (6)
- **tear coords**: (309, 42)
- **doors**: 14, **monsters**: 45, **items**: 16

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 11 | 41 | 0x40 | MP6D.MDT | Regular Door |
| D2 | 12 | 27 | 0xC1 | MP60.MDT | Locked Door  (Lion Key required) |
| D3 | 14 | 5 | 0xC2 | MP5D.MDT | Regular Door |
| D4 | 28 | 46 | 0xC2 | MP62.MDT | Regular Door |
| D5 | 30 | 28 | 0xC4 | MP60.MDT | Regular Door |
| D6 | 31 | 5 | 0x43 | MP61.MDT | Locked Door  (Lion Key required) |
| D7 | 90 | 37 | 0xC4 | MP60.MDT | Regular Door |
| D8 | 131 | 30 | 0xC2 | MP60.MDT | Regular Door |
| D9 | 150 | 30 | 0xC2 | MP60.MDT | Regular Door |
| D10 | 169 | 30 | 0xC2 | MP60.MDT | Regular Door |
| D11 | 188 | 30 | 0xC1 | MP60.MDT | Locked Door  (Lion Key required) |
| D12 | 249 | 15 | 0xC4 | MP60.MDT | Regular Door |
| D13 | 309 | 41 | 0x01 | MP62.MDT | Locked Door  (Lion Key required) |
| D14 | 315 | 48 | 0x40 | DRMP.MDT  (6. Dorado Town) | Town Warp |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 9 | 59 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (9, 59, 0x03) |
| M2 | 15 | 12 | 0x04 | Bat | 0x00 | (15, 12, 0x04) |
| M3 | 17 | 52 | 0x04 | Bat | 0x00 | (17, 52, 0x04) |
| M4 | 36 | 10 | 0x04 | Bat | 0x00 | (36, 10, 0x04) |
| M5 | 51 | 25 | 0x04 | Bat | 0x00 | (51, 25, 0x04) |
| M6 | 56 | 60 | 0x02 | Eyeball | 0x00 | (56, 60, 0x02) |
| M7 | 63 | 0 | 0x04 | Bat | 0x00 | (63, 0, 0x04) |
| M8 | 85 | 45 | 0x04 | Bat | 0x00 | (85, 45, 0x04) |
| M9 | 86 | 17 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (86, 17, 0x03) |
| M10 | 92 | 22 | 0x04 | Bat | 0x00 | (92, 22, 0x04) |
| M11 | 97 | 41 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (97, 41, 0x03) |
| M12 | 100 | 30 | 0x02 | Eyeball | 0x00 | (100, 30, 0x02) |
| M13 | 109 | 56 | 0x02 | Eyeball | 0x00 | (109, 56, 0x02) |
| M14 | 111 | 34 | 0x04 | Bat | 0x00 | (111, 34, 0x04) |
| M15 | 114 | 17 | 0x01 | Red Slime | 0x00 | (114, 17, 0x01) |
| M16 | 118 | 30 | 0x02 | Eyeball | 0x00 | (118, 30, 0x02) |
| M17 | 125 | 41 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (125, 41, 0x03) |
| M18 | 125 | 45 | 0x04 | Bat | 0x00 | (125, 45, 0x04) |
| M19 | 131 | 56 | 0x02 | Eyeball | 0x00 | (131, 56, 0x02) |
| M20 | 133 | 3 | 0x01 | Red Slime | 0x00 | (133, 3, 0x01) |
| M21 | 142 | 24 | 0x01 | Red Slime | 0x00 | (142, 24, 0x01) |
| M22 | 147 | 8 | 0x04 | Bat | 0x00 | (147, 8, 0x04) |
| M23 | 150 | 3 | 0x02 | Eyeball | 0x00 | (150, 3, 0x02) |
| M24 | 155 | 35 | 0x04 | Bat | 0x00 | (155, 35, 0x04) |
| M25 | 163 | 40 | 0x01 | Red Slime | 0x00 | (163, 40, 0x01) |
| M26 | 168 | 45 | 0x04 | Bat | 0x00 | (168, 45, 0x04) |
| M27 | 173 | 8 | 0x04 | Bat | 0x00 | (173, 8, 0x04) |
| M28 | 173 | 57 | 0x04 | Bat | 0x00 | (173, 57, 0x04) |
| M29 | 174 | 51 | 0x02 | Eyeball | 0x00 | (174, 51, 0x02) |
| M30 | 179 | 24 | 0x01 | Red Slime | 0x00 | (179, 24, 0x01) |
| M31 | 190 | 3 | 0x02 | Eyeball | 0x00 | (190, 3, 0x02) |
| M32 | 195 | 7 | 0x04 | Bat | 0x00 | (195, 7, 0x04) |
| M33 | 203 | 30 | 0x01 | Red Slime | 0x00 | (203, 30, 0x01) |
| M34 | 203 | 60 | 0x04 | Bat | 0x00 | (203, 60, 0x04) |
| M35 | 211 | 34 | 0x04 | Bat | 0x00 | (211, 34, 0x04) |
| M36 | 218 | 61 | 0x02 | Eyeball | 0x00 | (218, 61, 0x02) |
| M37 | 226 | 24 | 0x04 | Bat | 0x00 | (226, 24, 0x04) |
| M38 | 230 | 10 | 0x04 | Bat | 0x00 | (230, 10, 0x04) |
| M39 | 230 | 19 | 0x04 | Bat | 0x00 | (230, 19, 0x04) |
| M40 | 234 | 6 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (234, 6, 0x03) |
| M41 | 238 | 61 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (238, 61, 0x03) |
| M42 | 279 | 59 | 0x04 | Bat | 0x00 | (279, 59, 0x04) |
| M43 | 281 | 55 | 0x02 | Eyeball | 0x00 | (281, 55, 0x02) |
| M44 | 301 | 31 | 0x02 | Eyeball | 0x00 | (301, 31, 0x02) |
| M45 | 303 | 3 | 0x02 | Eyeball | 0x00 | (303, 3, 0x02) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 41 | 52 | 0x73 | 0x00 | `29 00 34 FF 73 00 00 20 00 18 00 2A 00 80 00 00` |
| I2 | 114 | 15 | 0x00 | 0x00 | `72 00 0F FF 00 00 00 10 00 00 00 72 00 0F 00 00` |
| I3 | 119 | 13 | 0x73 | 0x00 | `77 00 0D FF 73 00 03 20 00 00 00 2A 00 40 00 00` |
| I4 | 133 | 1 | 0x00 | 0x00 | `85 00 01 FF 00 00 00 10 00 00 00 85 00 01 00 00` |
| I5 | 140 | 14 | 0x76 | 0x00 | `8C 00 0E FF 76 00 00 20 00 00 00 2A 00 20 00 00` |
| I6 | 142 | 22 | 0x00 | 0x00 | `8E 00 16 FF 00 00 00 10 00 00 00 8E 00 16 00 00` |
| I7 | 161 | 40 | 0xD0 | 0x00 | `A1 00 28 FF D0 00 00 20 00 19 00 2A 00 10 00 00` |
| I8 | 163 | 38 | 0x00 | 0x00 | `A3 00 26 FF 00 00 00 10 00 00 00 A3 00 26 00 00` |
| I9 | 179 | 22 | 0x00 | 0x00 | `B3 00 16 FF 00 00 00 10 00 00 00 B3 00 16 00 00` |
| I10 | 180 | 14 | 0x73 | 0x00 | `B4 00 0E FF 73 00 05 20 00 00 00 2A 00 08 00 00` |
| I11 | 201 | 13 | 0x73 | 0x00 | `C9 00 0D FF 73 00 00 20 00 1A 00 2A 00 04 00 00` |
| I12 | 203 | 28 | 0x00 | 0x00 | `CB 00 1C FF 00 00 00 10 00 00 00 CB 00 1C 00 00` |
| I13 | 242 | 24 | 0x73 | 0x00 | `F2 00 18 FF 73 00 00 20 00 19 00 2A 00 02 00 00` |
| I14 | 260 | 35 | 0x73 | 0x00 | `04 01 23 FF 73 00 00 20 00 19 00 2A 00 01 00 00` |
| I15 | 267 | 14 | 0x73 | 0x00 | `0B 01 0E FF 73 00 05 20 00 00 00 2B 00 80 00 00` |
| I16 | 319 | 7 | 0x76 | 0x00 | `3F 01 07 FF 76 00 00 20 00 00 00 2B 00 40 00 00` |

## 335MP61.mdt — 5-B. Tumba sub-area

- **width**: 256 tiles (height fixed at 64)
- **cavern level**: 0x06 (6)
- **tear coords**: (65535, 255)
- **doors**: 15, **monsters**: 40, **items**: 20

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 12 | 27 | 0x81 | MP60.MDT | Locked Door  (Lion Key required) |
| D2 | 30 | 28 | 0x84 | MP60.MDT | Regular Door |
| D3 | 31 | 5 | 0x80 | DRMP.MDT  (6. Dorado Town) | Town Warp |
| D4 | 90 | 37 | 0x84 | MP60.MDT | Regular Door |
| D5 | 128 | 41 | 0x81 | MP60.MDT | Locked Door  (Lion Key required) |
| D6 | 143 | 62 | 0xC4 | MP60.MDT | Regular Door |
| D7 | 146 | 10 | 0xC2 | MP60.MDT | Regular Door |
| D8 | 150 | 30 | 0x82 | MP60.MDT | Regular Door |
| D9 | 169 | 30 | 0x82 | MP60.MDT | Regular Door |
| D10 | 176 | 57 | 0xC1 | MP60.MDT | Locked Door  (Lion Key required) |
| D11 | 177 | 17 | 0x84 | MP60.MDT | Regular Door |
| D12 | 188 | 30 | 0x81 | MP60.MDT | Locked Door  (Lion Key required) |
| D13 | 213 | 50 | 0x82 | MP60.MDT | Regular Door |
| D14 | 221 | 1 | 0x82 | MP60.MDT | Regular Door |
| D15 | 249 | 15 | 0x84 | MP60.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 11 | 22 | 0x01 | Red Slime | 0x00 | (11, 22, 0x01) |
| M2 | 29 | 17 | 0x04 | Bat | 0x00 | (29, 17, 0x04) |
| M3 | 35 | 14 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (35, 14, 0x03) |
| M4 | 36 | 22 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (36, 22, 0x03) |
| M5 | 38 | 35 | 0x04 | Bat | 0x00 | (38, 35, 0x04) |
| M6 | 44 | 17 | 0x04 | Bat | 0x00 | (44, 17, 0x04) |
| M7 | 68 | 30 | 0x02 | Eyeball | 0x00 | (68, 30, 0x02) |
| M8 | 76 | 56 | 0x02 | Eyeball | 0x00 | (76, 56, 0x02) |
| M9 | 78 | 60 | 0x04 | Bat | 0x00 | (78, 60, 0x04) |
| M10 | 88 | 30 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (88, 30, 0x03) |
| M11 | 95 | 53 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (95, 53, 0x03) |
| M12 | 108 | 38 | 0x04 | Bat | 0x00 | (108, 38, 0x04) |
| M13 | 110 | 12 | 0x02 | Eyeball | 0x00 | (110, 12, 0x02) |
| M14 | 113 | 33 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (113, 33, 0x03) |
| M15 | 118 | 2 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (118, 2, 0x03) |
| M16 | 130 | 38 | 0x04 | Bat | 0x00 | (130, 38, 0x04) |
| M17 | 132 | 17 | 0x04 | Bat | 0x00 | (132, 17, 0x04) |
| M18 | 132 | 34 | 0x02 | Eyeball | 0x00 | (132, 34, 0x02) |
| M19 | 134 | 2 | 0x01 | Red Slime | 0x00 | (134, 2, 0x01) |
| M20 | 134 | 12 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (134, 12, 0x03) |
| M21 | 134 | 51 | 0x02 | Eyeball | 0x00 | (134, 51, 0x02) |
| M22 | 139 | 12 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (139, 12, 0x03) |
| M23 | 141 | 30 | 0x02 | Eyeball | 0x00 | (141, 30, 0x02) |
| M24 | 144 | 58 | 0x04 | Bat | 0x00 | (144, 58, 0x04) |
| M25 | 155 | 15 | 0x02 | Eyeball | 0x00 | (155, 15, 0x02) |
| M26 | 156 | 3 | 0x01 | Red Slime | 0x00 | (156, 3, 0x01) |
| M27 | 176 | 32 | 0x01 | Red Slime | 0x00 | (176, 32, 0x01) |
| M28 | 176 | 49 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (176, 49, 0x03) |
| M29 | 177 | 6 | 0x04 | Bat | 0x00 | (177, 6, 0x04) |
| M30 | 189 | 23 | 0x04 | Bat | 0x00 | (189, 23, 0x04) |
| M31 | 192 | 44 | 0x02 | Eyeball | 0x00 | (192, 44, 0x02) |
| M32 | 196 | 9 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (196, 9, 0x03) |
| M33 | 197 | 12 | 0x04 | Bat | 0x00 | (197, 12, 0x04) |
| M34 | 212 | 60 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (212, 60, 0x03) |
| M35 | 214 | 37 | 0x02 | Eyeball | 0x00 | (214, 37, 0x02) |
| M36 | 222 | 10 | 0x02 | Eyeball | 0x00 | (222, 10, 0x02) |
| M37 | 222 | 27 | 0x03 | Bluish Person (Evil Woman) | 0x00 | (222, 27, 0x03) |
| M38 | 230 | 27 | 0x02 | Eyeball | 0x00 | (230, 27, 0x02) |
| M39 | 232 | 55 | 0x01 | Red Slime | 0x00 | (232, 55, 0x01) |
| M40 | 244 | 55 | 0x02 | Eyeball | 0x00 | (244, 55, 0x02) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 0 | 55 | 0xD0 | 0x00 | `00 00 37 FF D0 00 00 20 00 19 00 2B 00 02 00 00` |
| I2 | 6 | 22 | 0x73 | 0x00 | `06 00 16 FF 73 00 04 20 00 00 00 2B 00 01 00 00` |
| I3 | 11 | 20 | 0x00 | 0x00 | `0B 00 14 FF 00 00 00 10 00 00 00 0B 00 14 00 00` |
| I4 | 60 | 2 | 0x73 | 0x00 | `3C 00 02 FF 73 00 00 20 00 18 00 2C 00 80 00 00` |
| I5 | 77 | 22 | 0xD0 | 0x00 | `4D 00 16 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I6 | 89 | 22 | 0xD0 | 0x00 | `59 00 16 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I7 | 95 | 30 | 0xD0 | 0x00 | `5F 00 1E FF D0 00 00 20 00 19 00 2C 00 40 00 00` |
| I8 | 134 | 0 | 0x00 | 0x00 | `86 00 00 FF 00 00 00 10 00 00 00 86 00 00 00 00` |
| I9 | 136 | 12 | 0xD0 | 0x00 | `88 00 0C FF D0 00 00 20 00 19 00 2C 00 20 00 00` |
| I10 | 154 | 49 | 0xD0 | 0x00 | `9A 00 31 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I11 | 156 | 1 | 0x00 | 0x00 | `9C 00 01 FF 00 00 00 10 00 00 00 9C 00 01 00 00` |
| I12 | 176 | 30 | 0x00 | 0x00 | `B0 00 1E FF 00 00 00 10 00 00 00 B0 00 1E 00 00` |
| I13 | 178 | 39 | 0xD0 | 0x00 | `B2 00 27 FF D0 00 00 20 00 18 00 2C 00 10 00 00` |
| I14 | 205 | 28 | 0xD0 | 0x00 | `CD 00 1C FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I15 | 208 | 15 | 0xD0 | 0x00 | `D0 00 0F FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I16 | 208 | 17 | 0xD0 | 0x00 | `D0 00 11 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I17 | 216 | 15 | 0xD0 | 0x00 | `D8 00 0F FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I18 | 216 | 17 | 0xD0 | 0x00 | `D8 00 11 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I19 | 222 | 17 | 0xD0 | 0x00 | `DE 00 11 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I20 | 232 | 53 | 0x00 | 0x00 | `E8 00 35 FF 00 00 00 10 00 00 00 E8 00 35 00 00` |

## 336MP62.mdt — 5-C. Tumba sub-area

- **width**: 73 tiles (height fixed at 64)
- **cavern level**: 0x06 (6)
- **tear coords**: (65535, 0)
- **doors**: 2, **monsters**: 0, **items**: 28

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 40 | 37 | 0x80 | MP7D.MDT | Regular Door |
| D2 | 62 | 13 | 0x83 | MP60.MDT | Locked Door  (Lion Key required) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 8 | 20 | 0xD0 | 0x00 | `08 00 14 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I2 | 8 | 22 | 0xD0 | 0x00 | `08 00 16 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I3 | 8 | 24 | 0xF1 | 0x00 | `08 00 18 FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I4 | 8 | 26 | 0xF1 | 0x00 | `08 00 1A FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I5 | 8 | 28 | 0xF1 | 0x00 | `08 00 1C FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I6 | 8 | 30 | 0xF1 | 0x00 | `08 00 1E FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I7 | 8 | 32 | 0xF1 | 0x00 | `08 00 20 FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I8 | 8 | 34 | 0xF1 | 0x00 | `08 00 22 FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I9 | 10 | 20 | 0xD0 | 0x00 | `0A 00 14 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I10 | 10 | 22 | 0xD0 | 0x00 | `0A 00 16 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I11 | 10 | 24 | 0xF1 | 0x00 | `0A 00 18 FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I12 | 10 | 26 | 0xF1 | 0x00 | `0A 00 1A FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I13 | 10 | 28 | 0xF1 | 0x00 | `0A 00 1C FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I14 | 10 | 30 | 0xF1 | 0x00 | `0A 00 1E FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I15 | 10 | 32 | 0xF1 | 0x00 | `0A 00 20 FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I16 | 10 | 34 | 0xF1 | 0x00 | `0A 00 22 FF F1 00 00 00 00 00 00 FF FF 00 00 00` |
| I17 | 12 | 20 | 0xD0 | 0x00 | `0C 00 14 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I18 | 12 | 22 | 0xD0 | 0x00 | `0C 00 16 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I19 | 14 | 20 | 0xD0 | 0x00 | `0E 00 14 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I20 | 14 | 22 | 0xD0 | 0x00 | `0E 00 16 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I21 | 16 | 20 | 0xD0 | 0x00 | `10 00 14 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I22 | 16 | 22 | 0xD0 | 0x00 | `10 00 16 FF D0 00 00 00 00 00 00 FF FF 00 00 00` |
| I23 | 18 | 26 | 0x73 | 0x00 | `12 00 1A FF 73 00 07 20 00 00 00 2C 00 08 00 00` |
| I24 | 27 | 26 | 0x73 | 0x00 | `1B 00 1A FF 73 00 00 20 00 1E 00 2C 00 04 00 00` |
| I25 | 44 | 52 | 0x73 | 0x00 | `2C 00 34 FF 73 00 05 20 00 00 00 2C 00 02 00 00` |
| I26 | 46 | 52 | 0x73 | 0x00 | `2E 00 34 FF 73 00 05 20 00 00 00 2C 00 01 00 00` |
| I27 | 48 | 52 | 0x73 | 0x00 | `30 00 34 FF 73 00 05 20 00 00 00 2D 00 80 00 00` |
| I28 | 55 | 39 | 0x73 | 0x00 | `37 00 27 FF 73 00 00 20 00 19 00 2D 00 40 00 00` |

## 337MP6D.mdt — 5-D. Tumba cavern (slime/graveyard)

- **width**: 73 tiles (height fixed at 64)
- **cavern level**: 0x06 (6)
- **tear coords**: (65535, 0)
- **doors**: 0, **monsters**: 0, **items**: 0

## 338MP70.mdt — 6. Dorado outdoor

- **width**: 208 tiles (height fixed at 64)
- **cavern level**: 0x07 (7)
- **tear coords**: (199, 34)
- **doors**: 14, **monsters**: 19, **items**: 10

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 1 | 21 | 0xC0 | LLMP.MDT  (7. Llama Town) | Town Warp |
| D2 | 49 | 59 | 0xC2 | MP70.MDT | Regular Door |
| D3 | 83 | 1 | 0xC2 | MP71.MDT | Regular Door |
| D4 | 92 | 41 | 0xC1 | MP71.MDT | Locked Door  (Lion Key required) |
| D5 | 94 | 17 | 0xC1 | MP70.MDT | Locked Door  (Lion Key required) |
| D6 | 104 | 53 | 0xC4 | MP70.MDT | Regular Door |
| D7 | 120 | 22 | 0xC3 | MP70.MDT | Locked Door  (Lion Key required) |
| D8 | 127 | 7 | 0x80 | MP60.MDT | Regular Door |
| D9 | 152 | 6 | 0x80 | LLMP.MDT  (7. Llama Town) | Town Warp |
| D10 | 165 | 43 | 0x41 | MP70.MDT | Locked Door  (Lion Key required) |
| D11 | 176 | 43 | 0xC1 | MP71.MDT | Locked Door  (Lion Key required) |
| D12 | 199 | 33 | 0x01 | MP73.MDT | Locked Door  (Lion Key required) |
| D13 | 202 | 60 | 0xC2 | MP70.MDT | Regular Door |
| D14 | 205 | 45 | 0xC3 | MP71.MDT | Locked Door  (Lion Key required) |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 4 | 7 | 0x02 | Kondor | 0x00 | (4, 7, 0x02) |
| M2 | 4 | 9 | 0x03 | Evil Woman | 0x00 | (4, 9, 0x03) |
| M3 | 11 | 47 | 0x01 | Red Ghost | 0x00 | (11, 47, 0x01) |
| M4 | 17 | 7 | 0x02 | Kondor | 0x00 | (17, 7, 0x02) |
| M5 | 17 | 9 | 0x03 | Evil Woman | 0x00 | (17, 9, 0x03) |
| M6 | 20 | 23 | 0x04 | (4th enemy) | 0x00 | (20, 23, 0x04) |
| M7 | 36 | 23 | 0x04 | (4th enemy) | 0x00 | (36, 23, 0x04) |
| M8 | 48 | 47 | 0x04 | (4th enemy) | 0x00 | (48, 47, 0x04) |
| M9 | 61 | 61 | 0x01 | Red Ghost | 0x00 | (61, 61, 0x01) |
| M10 | 69 | 3 | 0x04 | (4th enemy) | 0x00 | (69, 3, 0x04) |
| M11 | 83 | 55 | 0x01 | Red Ghost | 0x00 | (83, 55, 0x01) |
| M12 | 85 | 30 | 0x01 | Red Ghost | 0x00 | (85, 30, 0x01) |
| M13 | 115 | 55 | 0x04 | (4th enemy) | 0x00 | (115, 55, 0x04) |
| M14 | 138 | 55 | 0x04 | (4th enemy) | 0x00 | (138, 55, 0x04) |
| M15 | 149 | 45 | 0x04 | (4th enemy) | 0x00 | (149, 45, 0x04) |
| M16 | 161 | 17 | 0x02 | Kondor | 0x00 | (161, 17, 0x02) |
| M17 | 161 | 19 | 0x03 | Evil Woman | 0x00 | (161, 19, 0x03) |
| M18 | 182 | 30 | 0x04 | (4th enemy) | 0x00 | (182, 30, 0x04) |
| M19 | 197 | 9 | 0x04 | (4th enemy) | 0x00 | (197, 9, 0x04) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 11 | 45 | 0x00 | 0x00 | `0B 00 2D FF 00 00 00 10 00 00 00 0B 00 2D 00 00` |
| I2 | 23 | 53 | 0x73 | 0x00 | `17 00 35 FF 73 00 00 20 00 19 00 34 00 08 00 00` |
| I3 | 61 | 59 | 0x00 | 0x00 | `3D 00 3B FF 00 00 00 10 00 00 00 3D 00 3B 00 00` |
| I4 | 62 | 14 | 0x76 | 0x00 | `3E 00 0E FF 76 00 00 20 00 00 00 34 00 04 00 00` |
| I5 | 71 | 47 | 0x73 | 0x00 | `47 00 2F FF 73 00 00 20 00 19 00 34 00 02 00 00` |
| I6 | 83 | 53 | 0x00 | 0x00 | `53 00 35 FF 00 00 00 10 00 00 00 53 00 35 00 00` |
| I7 | 85 | 28 | 0x00 | 0x00 | `55 00 1C FF 00 00 00 10 00 00 00 55 00 1C 00 00` |
| I8 | 160 | 30 | 0x76 | 0x00 | `A0 00 1E FF 76 00 00 20 00 00 00 34 00 01 00 00` |
| I9 | 193 | 35 | 0x73 | 0x00 | `C1 00 23 FF 73 00 00 20 00 19 00 35 00 80 00 00` |
| I10 | 204 | 9 | 0x73 | 0x00 | `CC 00 09 FF 73 00 05 20 00 00 00 35 00 40 00 00` |

## 339MP71.mdt — 6-A. Dorado sub-area

- **width**: 196 tiles (height fixed at 64)
- **cavern level**: 0x07 (7)
- **tear coords**: (65535, 255)
- **doors**: 7, **monsters**: 25, **items**: 10

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 9 | 55 | 0x82 | MP6D.MDT | Regular Door |
| D2 | 20 | 9 | 0xC3 | MP71.MDT | Locked Door  (Lion Key required) |
| D3 | 103 | 33 | 0x02 | MP6D.MDT | Regular Door |
| D4 | 109 | 46 | 0x84 | MP6D.MDT | Regular Door |
| D5 | 127 | 46 | 0x83 | MP6D.MDT | Locked Door  (Lion Key required) |
| D6 | 149 | 58 | 0x81 | MP6D.MDT | Locked Door  (Lion Key required) |
| D7 | 171 | 32 | 0x81 | MP6D.MDT | Locked Door  (Lion Key required) |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 5 | 45 | 0x02 | Kondor | 0x00 | (5, 45, 0x02) |
| M2 | 5 | 47 | 0x03 | Evil Woman | 0x00 | (5, 47, 0x03) |
| M3 | 20 | 33 | 0x02 | Kondor | 0x00 | (20, 33, 0x02) |
| M4 | 20 | 35 | 0x03 | Evil Woman | 0x00 | (20, 35, 0x03) |
| M5 | 23 | 61 | 0x01 | Red Ghost | 0x00 | (23, 61, 0x01) |
| M6 | 25 | 45 | 0x02 | Kondor | 0x00 | (25, 45, 0x02) |
| M7 | 25 | 47 | 0x03 | Evil Woman | 0x00 | (25, 47, 0x03) |
| M8 | 30 | 35 | 0x04 | (4th enemy) | 0x00 | (30, 35, 0x04) |
| M9 | 61 | 32 | 0x04 | (4th enemy) | 0x00 | (61, 32, 0x04) |
| M10 | 69 | 30 | 0x02 | Kondor | 0x00 | (69, 30, 0x02) |
| M11 | 69 | 32 | 0x03 | Evil Woman | 0x00 | (69, 32, 0x03) |
| M12 | 82 | 23 | 0x01 | Red Ghost | 0x00 | (82, 23, 0x01) |
| M13 | 89 | 60 | 0x02 | Kondor | 0x00 | (89, 60, 0x02) |
| M14 | 89 | 62 | 0x03 | Evil Woman | 0x00 | (89, 62, 0x03) |
| M15 | 92 | 48 | 0x01 | Red Ghost | 0x00 | (92, 48, 0x01) |
| M16 | 111 | 23 | 0x01 | Red Ghost | 0x00 | (111, 23, 0x01) |
| M17 | 123 | 7 | 0x01 | Red Ghost | 0x00 | (123, 7, 0x01) |
| M18 | 127 | 58 | 0x02 | Kondor | 0x00 | (127, 58, 0x02) |
| M19 | 127 | 60 | 0x03 | Evil Woman | 0x00 | (127, 60, 0x03) |
| M20 | 139 | 48 | 0x04 | (4th enemy) | 0x00 | (139, 48, 0x04) |
| M21 | 148 | 25 | 0x01 | Red Ghost | 0x00 | (148, 25, 0x01) |
| M22 | 165 | 34 | 0x04 | (4th enemy) | 0x00 | (165, 34, 0x04) |
| M23 | 174 | 53 | 0x01 | Red Ghost | 0x00 | (174, 53, 0x01) |
| M24 | 179 | 23 | 0x04 | (4th enemy) | 0x00 | (179, 23, 0x04) |
| M25 | 194 | 35 | 0x01 | Red Ghost | 0x00 | (194, 35, 0x01) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 23 | 59 | 0x00 | 0x00 | `17 00 3B FF 00 00 00 10 00 00 00 17 00 3B 00 00` |
| I2 | 40 | 7 | 0x73 | 0x00 | `28 00 07 FF 73 00 00 20 00 19 00 35 00 10 00 00` |
| I3 | 82 | 21 | 0x00 | 0x00 | `52 00 15 FF 00 00 00 10 00 00 00 52 00 15 00 00` |
| I4 | 92 | 46 | 0x00 | 0x00 | `5C 00 2E FF 00 00 00 10 00 00 00 5C 00 2E 00 00` |
| I5 | 111 | 21 | 0x00 | 0x00 | `6F 00 15 FF 00 00 00 10 00 00 00 6F 00 15 00 00` |
| I6 | 123 | 5 | 0x00 | 0x00 | `7B 00 05 FF 00 00 00 10 00 00 00 7B 00 05 00 00` |
| I7 | 148 | 23 | 0x00 | 0x00 | `94 00 17 FF 00 00 00 10 00 00 00 94 00 17 00 00` |
| I8 | 174 | 51 | 0x00 | 0x00 | `AE 00 33 FF 00 00 00 10 00 00 00 AE 00 33 00 00` |
| I9 | 193 | 57 | 0x73 | 0x00 | `C1 00 39 FF 73 00 04 20 00 00 00 35 00 08 00 00` |
| I10 | 194 | 33 | 0x00 | 0x00 | `C2 00 21 FF 00 00 00 10 00 00 00 C2 00 21 00 00` |

## 340MP72.mdt — 6-B. Dorado sub-area

- **width**: 128 tiles (height fixed at 64)
- **cavern level**: 0x07 (7)
- **tear coords**: (65535, 255)
- **doors**: 5, **monsters**: 14, **items**: 3

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 25 | 40 | 0x83 | MP70.MDT | Locked Door  (Lion Key required) |
| D2 | 50 | 8 | 0x82 | MP6D.MDT | Regular Door |
| D3 | 76 | 8 | 0x81 | MP6D.MDT | Locked Door  (Lion Key required) |
| D4 | 101 | 56 | 0x81 | MP6D.MDT | Locked Door  (Lion Key required) |
| D5 | 127 | 8 | 0x83 | MP6D.MDT | Locked Door  (Lion Key required) |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 2 | 42 | 0x04 | (4th enemy) | 0x00 | (2, 42, 0x04) |
| M2 | 17 | 26 | 0x04 | (4th enemy) | 0x00 | (17, 26, 0x04) |
| M3 | 18 | 58 | 0x04 | (4th enemy) | 0x00 | (18, 58, 0x04) |
| M4 | 24 | 10 | 0x04 | (4th enemy) | 0x00 | (24, 10, 0x04) |
| M5 | 43 | 58 | 0x04 | (4th enemy) | 0x00 | (43, 58, 0x04) |
| M6 | 46 | 26 | 0x04 | (4th enemy) | 0x00 | (46, 26, 0x04) |
| M7 | 54 | 42 | 0x04 | (4th enemy) | 0x00 | (54, 42, 0x04) |
| M8 | 70 | 26 | 0x04 | (4th enemy) | 0x00 | (70, 26, 0x04) |
| M9 | 75 | 58 | 0x04 | (4th enemy) | 0x00 | (75, 58, 0x04) |
| M10 | 78 | 42 | 0x04 | (4th enemy) | 0x00 | (78, 42, 0x04) |
| M11 | 84 | 10 | 0x04 | (4th enemy) | 0x00 | (84, 10, 0x04) |
| M12 | 102 | 26 | 0x04 | (4th enemy) | 0x00 | (102, 26, 0x04) |
| M13 | 102 | 42 | 0x04 | (4th enemy) | 0x00 | (102, 42, 0x04) |
| M14 | 106 | 10 | 0x04 | (4th enemy) | 0x00 | (106, 10, 0x04) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 28 | 10 | 0x73 | 0x00 | `1C 00 0A FF 73 00 00 20 00 19 00 35 00 04 00 00` |
| I2 | 58 | 10 | 0x73 | 0x00 | `3A 00 0A FF 73 00 00 20 00 16 00 35 00 02 00 00` |
| I3 | 119 | 58 | 0x73 | 0x00 | `77 00 3A FF 73 00 05 20 00 00 00 35 00 01 00 00` |

## 341MP73.mdt — 6-C. Dorado sub-area

- **width**: 73 tiles (height fixed at 64)
- **cavern level**: 0x01 (1)
- **tear coords**: (65535, 0)
- **doors**: 0, **monsters**: 0, **items**: 0

## 342MP7D.mdt — 6-D. Dorado cavern (gold/Silkarn)

- **width**: 70 tiles (height fixed at 64)
- **cavern level**: 0x07 (7)
- **tear coords**: (65535, 0)
- **doors**: 0, **monsters**: 0, **items**: 0

## 343MP80.mdt — 7. Llama outdoor

- **width**: 256 tiles (height fixed at 64)
- **cavern level**: 0x08 (8)
- **tear coords**: (65535, 255)
- **doors**: 11, **monsters**: 45, **items**: 15

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 57 | 5 | 0xC2 | MP73.MDT | Regular Door |
| D2 | 57 | 15 | 0x03 | MP81.MDT | Locked Door  (Lion Key required) |
| D3 | 57 | 34 | 0x81 | MP80.MDT | Locked Door  (Lion Key required) |
| D4 | 57 | 46 | 0x84 | MP80.MDT | Regular Door |
| D5 | 57 | 57 | 0xC0 | MP61.MDT | Regular Door |
| D6 | 111 | 20 | 0x80 | PRMP.MDT  (8-1. Pureza Town) | Town Warp |
| D7 | 117 | 31 | 0x83 | MP80.MDT | Locked Door  (Lion Key required) |
| D8 | 166 | 30 | 0x84 | MP81.MDT | Regular Door |
| D9 | 169 | 18 | 0x80 | MP80.MDT | Regular Door |
| D10 | 185 | 1 | 0x81 | MP82.MDT | Locked Door  (Lion Key required) |
| D11 | 250 | 31 | 0x80 | MP81.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 2 | 38 | 0x02 | Troll | 0x00 | (2, 38, 0x02) |
| M2 | 4 | 4 | 0x01 | Fire Creature | 0x00 | (4, 4, 0x01) |
| M3 | 10 | 38 | 0x02 | Troll | 0x00 | (10, 38, 0x02) |
| M4 | 18 | 22 | 0x01 | Fire Creature | 0x00 | (18, 22, 0x01) |
| M5 | 19 | 12 | 0x02 | Troll | 0x00 | (19, 12, 0x02) |
| M6 | 21 | 7 | 0xD0 | special-D0 | 0x00 | (66, 128, 0x0D) |
| M7 | 21 | 36 | 0x03 | Rat | 0x00 | (21, 36, 0x03) |
| M8 | 33 | 59 | 0x03 | Rat | 0x00 | (33, 59, 0x03) |
| M9 | 39 | 55 | 0x04 | (4th enemy) | 0x00 | (39, 55, 0x04) |
| M10 | 41 | 36 | 0x03 | Rat | 0x00 | (41, 36, 0x03) |
| M11 | 41 | 59 | 0x03 | Rat | 0x00 | (41, 59, 0x03) |
| M12 | 46 | 1 | 0xD0 | special-D0 | 0x00 | (66, 64, 0x0D) |
| M13 | 47 | 48 | 0x01 | Fire Creature | 0x00 | (47, 48, 0x01) |
| M14 | 48 | 17 | 0x03 | Rat | 0x00 | (48, 17, 0x03) |
| M15 | 51 | 26 | 0x03 | Rat | 0x00 | (51, 26, 0x03) |
| M16 | 59 | 26 | 0x03 | Rat | 0x00 | (59, 26, 0x03) |
| M17 | 68 | 17 | 0x03 | Rat | 0x00 | (68, 17, 0x03) |
| M18 | 77 | 39 | 0x03 | Rat | 0x00 | (77, 39, 0x03) |
| M19 | 85 | 39 | 0x03 | Rat | 0x00 | (85, 39, 0x03) |
| M20 | 104 | 11 | 0x03 | Rat | 0x00 | (104, 11, 0x03) |
| M21 | 119 | 40 | 0x04 | (4th enemy) | 0x00 | (119, 40, 0x04) |
| M22 | 121 | 22 | 0x03 | Rat | 0x00 | (121, 22, 0x03) |
| M23 | 125 | 33 | 0x03 | Rat | 0x00 | (125, 33, 0x03) |
| M24 | 128 | 0 | 0x02 | Troll | 0x00 | (128, 0, 0x02) |
| M25 | 131 | 42 | 0x04 | (4th enemy) | 0x00 | (131, 42, 0x04) |
| M26 | 136 | 0 | 0x03 | Rat | 0x00 | (136, 0, 0x03) |
| M27 | 147 | 22 | 0x03 | Rat | 0x00 | (147, 22, 0x03) |
| M28 | 153 | 22 | 0x03 | Rat | 0x00 | (153, 22, 0x03) |
| M29 | 162 | 0 | 0x03 | Rat | 0x00 | (162, 0, 0x03) |
| M30 | 169 | 51 | 0x03 | Rat | 0x00 | (169, 51, 0x03) |
| M31 | 179 | 32 | 0x02 | Troll | 0x00 | (179, 32, 0x02) |
| M32 | 183 | 32 | 0x02 | Troll | 0x00 | (183, 32, 0x02) |
| M33 | 186 | 12 | 0x01 | Fire Creature | 0x00 | (186, 12, 0x01) |
| M34 | 187 | 41 | 0x03 | Rat | 0x00 | (187, 41, 0x03) |
| M35 | 191 | 31 | 0x02 | Troll | 0x00 | (191, 31, 0x02) |
| M36 | 197 | 4 | 0x02 | Troll | 0x00 | (197, 4, 0x02) |
| M37 | 199 | 31 | 0x02 | Troll | 0x00 | (199, 31, 0x02) |
| M38 | 203 | 4 | 0x02 | Troll | 0x00 | (203, 4, 0x02) |
| M39 | 208 | 49 | 0x04 | (4th enemy) | 0x00 | (208, 49, 0x04) |
| M40 | 211 | 12 | 0x03 | Rat | 0x00 | (211, 12, 0x03) |
| M41 | 213 | 4 | 0x01 | Fire Creature | 0x00 | (213, 4, 0x01) |
| M42 | 219 | 51 | 0x03 | Rat | 0x00 | (219, 51, 0x03) |
| M43 | 228 | 60 | 0x01 | Fire Creature | 0x00 | (228, 60, 0x01) |
| M44 | 235 | 42 | 0x03 | Rat | 0x00 | (235, 42, 0x03) |
| M45 | 255 | 51 | 0x03 | Rat | 0x00 | (255, 51, 0x03) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 4 | 2 | 0x00 | 0x00 | `04 00 02 FF 00 00 00 10 00 00 00 04 00 02 00 00` |
| I2 | 18 | 20 | 0x00 | 0x00 | `12 00 14 FF 00 00 00 10 00 00 00 12 00 14 00 00` |
| I3 | 47 | 46 | 0x00 | 0x00 | `2F 00 2E FF 00 00 00 10 00 00 00 2F 00 2E 00 00` |
| I4 | 73 | 43 | 0xD0 | 0x00 | `49 00 2B FF D0 00 00 20 00 19 00 42 00 20 00 00` |
| I5 | 117 | 52 | 0x73 | 0x00 | `75 00 34 FF 73 00 04 20 00 00 00 42 00 10 00 00` |
| I6 | 150 | 7 | 0x77 | 0x00 | `96 00 07 FF 77 00 00 20 00 00 00 42 00 08 00 00` |
| I7 | 170 | 41 | 0x73 | 0x00 | `AA 00 29 FF 73 00 05 20 00 00 00 42 00 04 00 00` |
| I8 | 186 | 10 | 0x00 | 0x00 | `BA 00 0A FF 00 00 00 10 00 00 00 BA 00 0A 00 00` |
| I9 | 187 | 25 | 0x73 | 0x00 | `BB 00 19 FF 73 00 05 20 00 00 00 42 00 02 00 00` |
| I10 | 209 | 20 | 0x73 | 0x00 | `D1 00 14 FF 73 00 03 20 00 00 00 42 00 01 00 00` |
| I11 | 209 | 42 | 0x73 | 0x00 | `D1 00 2A FF 73 00 04 20 00 00 00 43 00 80 00 00` |
| I12 | 213 | 2 | 0x00 | 0x00 | `D5 00 02 FF 00 00 00 10 00 00 00 D5 00 02 00 00` |
| I13 | 228 | 58 | 0x00 | 0x00 | `E4 00 3A FF 00 00 00 10 00 00 00 E4 00 3A 00 00` |
| I14 | 229 | 22 | 0xD0 | 0x00 | `E5 00 16 FF D0 00 00 00 00 00 00 FF FF FF 00 00` |
| I15 | 252 | 13 | 0xD0 | 0x00 | `FC 00 0D FF D0 00 00 00 00 00 00 FF FF FF 00 00` |

## 344MP81.mdt — 7-A. Llama sub-area

- **width**: 256 tiles (height fixed at 64)
- **cavern level**: 0x08 (8)
- **tear coords**: (222, 20)
- **doors**: 13, **monsters**: 58, **items**: 11

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 10 | 52 | 0xC4 | MP7D.MDT | Regular Door |
| D2 | 35 | 43 | 0xC1 | MP7D.MDT | Locked Door  (Lion Key required) |
| D3 | 53 | 17 | 0x83 | MP81.MDT | Locked Door  (Lion Key required) |
| D4 | 95 | 49 | 0x83 | MP81.MDT | Locked Door  (Lion Key required) |
| D5 | 123 | 5 | 0xC0 | ESMP.MDT  (8-2. Esco Village) | Town Warp |
| D6 | 151 | 15 | 0xC2 | MP81.MDT | Regular Door |
| D7 | 153 | 44 | 0xC3 | MP7D.MDT | Locked Door  (Lion Key required) |
| D8 | 179 | 35 | 0x82 | MP82.MDT | Regular Door |
| D9 | 222 | 19 | 0x01 | MP84.MDT | Locked Door  (Lion Key required) |
| D10 | 227 | 59 | 0xC2 | MP80.MDT | Regular Door |
| D11 | 228 | 49 | 0x82 | MP82.MDT | Regular Door |
| D12 | 236 | 4 | 0x40 | MP7D.MDT | Regular Door |
| D13 | 250 | 38 | 0x84 | MP81.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 2 | 3 | 0x03 | Rat | 0x00 | (2, 3, 0x03) |
| M2 | 2 | 40 | 0x03 | Rat | 0x00 | (2, 40, 0x03) |
| M3 | 11 | 3 | 0x03 | Rat | 0x00 | (11, 3, 0x03) |
| M4 | 22 | 40 | 0x01 | Fire Creature | 0x00 | (22, 40, 0x01) |
| M5 | 25 | 9 | 0x03 | Rat | 0x00 | (25, 9, 0x03) |
| M6 | 30 | 0 | 0x03 | Rat | 0x00 | (30, 0, 0x03) |
| M7 | 31 | 54 | 0x03 | Rat | 0x00 | (31, 54, 0x03) |
| M8 | 37 | 30 | 0x02 | Troll | 0x00 | (37, 30, 0x02) |
| M9 | 59 | 9 | 0x02 | Troll | 0x00 | (59, 9, 0x02) |
| M10 | 61 | 62 | 0x03 | Rat | 0x00 | (61, 62, 0x03) |
| M11 | 66 | 19 | 0x03 | Rat | 0x00 | (66, 19, 0x03) |
| M12 | 69 | 30 | 0x03 | Rat | 0x00 | (69, 30, 0x03) |
| M13 | 73 | 9 | 0x02 | Troll | 0x00 | (73, 9, 0x02) |
| M14 | 74 | 40 | 0x03 | Rat | 0x00 | (74, 40, 0x03) |
| M15 | 81 | 62 | 0x03 | Rat | 0x00 | (81, 62, 0x03) |
| M16 | 83 | 19 | 0x03 | Rat | 0x00 | (83, 19, 0x03) |
| M17 | 85 | 9 | 0x02 | Troll | 0x00 | (85, 9, 0x02) |
| M18 | 85 | 51 | 0x02 | Troll | 0x00 | (85, 51, 0x02) |
| M19 | 98 | 9 | 0x03 | Rat | 0x00 | (98, 9, 0x03) |
| M20 | 98 | 19 | 0x02 | Troll | 0x00 | (98, 19, 0x02) |
| M21 | 117 | 51 | 0x02 | Troll | 0x00 | (117, 51, 0x02) |
| M22 | 121 | 61 | 0x02 | Troll | 0x00 | (121, 61, 0x02) |
| M23 | 125 | 61 | 0x02 | Troll | 0x00 | (125, 61, 0x02) |
| M24 | 126 | 26 | 0x03 | Rat | 0x00 | (126, 26, 0x03) |
| M25 | 133 | 17 | 0x03 | Rat | 0x00 | (133, 17, 0x03) |
| M26 | 134 | 26 | 0x03 | Rat | 0x00 | (134, 26, 0x03) |
| M27 | 134 | 37 | 0x03 | Rat | 0x00 | (134, 37, 0x03) |
| M28 | 138 | 7 | 0x03 | Rat | 0x00 | (138, 7, 0x03) |
| M29 | 142 | 55 | 0x02 | Troll | 0x00 | (142, 55, 0x02) |
| M30 | 144 | 46 | 0x03 | Rat | 0x00 | (144, 46, 0x03) |
| M31 | 150 | 29 | 0x03 | Rat | 0x00 | (150, 29, 0x03) |
| M32 | 153 | 38 | 0x04 | (4th enemy) | 0x00 | (153, 38, 0x04) |
| M33 | 158 | 29 | 0x03 | Rat | 0x00 | (158, 29, 0x03) |
| M34 | 159 | 55 | 0x03 | Rat | 0x00 | (159, 55, 0x03) |
| M35 | 170 | 17 | 0x03 | Rat | 0x00 | (170, 17, 0x03) |
| M36 | 177 | 17 | 0x03 | Rat | 0x00 | (177, 17, 0x03) |
| M37 | 179 | 55 | 0x03 | Rat | 0x00 | (179, 55, 0x03) |
| M38 | 182 | 47 | 0x03 | Rat | 0x00 | (182, 47, 0x03) |
| M39 | 191 | 22 | 0x04 | (4th enemy) | 0x00 | (191, 22, 0x04) |
| M40 | 196 | 19 | 0x04 | (4th enemy) | 0x00 | (196, 19, 0x04) |
| M41 | 200 | 26 | 0x04 | (4th enemy) | 0x00 | (200, 26, 0x04) |
| M42 | 204 | 46 | 0x03 | Rat | 0x00 | (204, 46, 0x03) |
| M43 | 209 | 39 | 0x02 | Troll | 0x00 | (209, 39, 0x02) |
| M44 | 212 | 3 | 0x04 | (4th enemy) | 0x00 | (212, 3, 0x04) |
| M45 | 213 | 27 | 0x04 | (4th enemy) | 0x00 | (213, 27, 0x04) |
| M46 | 214 | 39 | 0x02 | Troll | 0x00 | (214, 39, 0x02) |
| M47 | 216 | 61 | 0x02 | Troll | 0x00 | (216, 61, 0x02) |
| M48 | 220 | 5 | 0x04 | (4th enemy) | 0x00 | (220, 5, 0x04) |
| M49 | 220 | 51 | 0x03 | Rat | 0x00 | (220, 51, 0x03) |
| M50 | 222 | 29 | 0x04 | (4th enemy) | 0x00 | (222, 29, 0x04) |
| M51 | 223 | 39 | 0x03 | Rat | 0x00 | (223, 39, 0x03) |
| M52 | 226 | 39 | 0x03 | Rat | 0x00 | (226, 39, 0x03) |
| M53 | 229 | 39 | 0x03 | Rat | 0x00 | (229, 39, 0x03) |
| M54 | 219 | 33 | 0x01 | Fire Creature | 0x00 | (219, 33, 0x01) |
| M55 | 235 | 21 | 0xD0 | special-D0 | 0x00 | (68, 64, 0x0D) |
| M56 | 250 | 54 | 0x03 | Rat | 0x00 | (250, 54, 0x03) |
| M57 | 255 | 0 | 0x04 | (4th enemy) | 0x00 | (255, 0, 0x04) |
| M58 | 198 | 39 | 0x03 | Rat | 0x00 | (198, 39, 0x03) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 14 | 40 | 0x73 | 0x00 | `0E 00 28 FF 73 00 05 20 00 00 00 43 00 20 00 00` |
| I2 | 18 | 14 | 0xD0 | 0x00 | `12 00 0E FF D0 00 00 20 00 19 00 43 00 10 00 00` |
| I3 | 22 | 38 | 0x00 | 0x00 | `16 00 26 FF 00 00 00 10 00 00 00 16 00 26 00 00` |
| I4 | 93 | 46 | 0xD0 | 0x00 | `5D 00 2E FF D0 00 00 20 00 19 00 43 00 08 00 00` |
| I5 | 109 | 5 | 0x00 | 0x00 | `6D 00 05 FF 00 00 00 10 00 00 00 6D 00 05 00 00` |
| I6 | 109 | 7 | 0x01 | 0x00 | `6D 00 07 FF 01 00 00 10 00 00 00 6D 00 07 00 00` |
| I7 | 125 | 37 | 0x76 | 0x00 | `7D 00 25 FF 76 00 00 20 00 00 00 43 00 04 00 00` |
| I8 | 139 | 41 | 0xD0 | 0x00 | `8B 00 29 FF D0 00 00 20 00 19 00 43 00 01 00 00` |
| I9 | 162 | 1 | 0x73 | 0x00 | `A2 00 01 FF 73 00 05 20 00 00 00 44 00 80 00 00` |
| I10 | 219 | 31 | 0x00 | 0x00 | `DB 00 1F FF 00 00 00 10 00 00 00 DB 00 1F 00 00` |
| I11 | 232 | 39 | 0x76 | 0x00 | `E8 00 27 FF 76 00 00 20 00 00 00 43 00 02 00 00` |

## 345MP82.mdt — 7-B. Llama sub-area

- **width**: 192 tiles (height fixed at 64)
- **cavern level**: 0x08 (8)
- **tear coords**: (65535, 255)
- **doors**: 7, **monsters**: 33, **items**: 6

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 20 | 9 | 0xC0 | MP7D.MDT | Regular Door |
| D2 | 26 | 18 | 0xC4 | MP7D.MDT | Regular Door |
| D3 | 73 | 25 | 0xC3 | MP80.MDT | Locked Door  (Lion Key required) |
| D4 | 88 | 34 | 0xC4 | MP80.MDT | Regular Door |
| D5 | 102 | 53 | 0xC3 | MP7D.MDT | Locked Door  (Lion Key required) |
| D6 | 119 | 24 | 0xC3 | MP80.MDT | Locked Door  (Lion Key required) |
| D7 | 174 | 9 | 0xC2 | MP80.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 5 | 1 | 0x02 | Troll | 0x00 | (5, 1, 0x02) |
| M2 | 22 | 38 | 0x03 | Rat | 0x00 | (22, 38, 0x03) |
| M3 | 25 | 1 | 0x03 | Rat | 0x00 | (25, 1, 0x03) |
| M4 | 34 | 38 | 0x03 | Rat | 0x00 | (34, 38, 0x03) |
| M5 | 41 | 27 | 0x02 | Troll | 0x00 | (41, 27, 0x02) |
| M6 | 46 | 20 | 0x02 | Troll | 0x00 | (46, 20, 0x02) |
| M7 | 50 | 27 | 0x02 | Troll | 0x00 | (50, 27, 0x02) |
| M8 | 60 | 3 | 0x03 | Rat | 0x00 | (60, 3, 0x03) |
| M9 | 60 | 12 | 0x01 | Fire Creature | 0x00 | (60, 12, 0x01) |
| M10 | 71 | 20 | 0x04 | (4th enemy) | 0x00 | (71, 20, 0x04) |
| M11 | 73 | 55 | 0x01 | Fire Creature | 0x00 | (73, 55, 0x01) |
| M12 | 77 | 36 | 0x03 | Rat | 0x00 | (77, 36, 0x03) |
| M13 | 86 | 27 | 0x03 | Rat | 0x00 | (86, 27, 0x03) |
| M14 | 94 | 45 | 0x03 | Rat | 0x00 | (94, 45, 0x03) |
| M15 | 106 | 45 | 0x03 | Rat | 0x00 | (106, 45, 0x03) |
| M16 | 108 | 11 | 0x03 | Rat | 0x00 | (108, 11, 0x03) |
| M17 | 112 | 34 | 0x03 | Rat | 0x00 | (112, 34, 0x03) |
| M18 | 116 | 11 | 0x03 | Rat | 0x00 | (116, 11, 0x03) |
| M19 | 117 | 1 | 0x02 | Troll | 0x00 | (117, 1, 0x02) |
| M20 | 118 | 34 | 0x03 | Rat | 0x00 | (118, 34, 0x03) |
| M21 | 128 | 26 | 0x02 | Troll | 0x00 | (128, 26, 0x02) |
| M22 | 137 | 1 | 0x02 | Troll | 0x00 | (137, 1, 0x02) |
| M23 | 138 | 26 | 0x02 | Troll | 0x00 | (138, 26, 0x02) |
| M24 | 140 | 13 | 0x03 | Rat | 0x00 | (140, 13, 0x03) |
| M25 | 141 | 55 | 0x03 | Rat | 0x00 | (141, 55, 0x03) |
| M26 | 144 | 13 | 0x03 | Rat | 0x00 | (144, 13, 0x03) |
| M27 | 145 | 34 | 0x03 | Rat | 0x00 | (145, 34, 0x03) |
| M28 | 157 | 1 | 0x02 | Troll | 0x00 | (157, 1, 0x02) |
| M29 | 157 | 19 | 0x02 | Troll | 0x00 | (157, 19, 0x02) |
| M30 | 175 | 46 | 0x03 | Rat | 0x00 | (175, 46, 0x03) |
| M31 | 177 | 1 | 0x02 | Troll | 0x00 | (177, 1, 0x02) |
| M32 | 183 | 46 | 0x03 | Rat | 0x00 | (183, 46, 0x03) |
| M33 | 186 | 26 | 0x03 | Rat | 0x00 | (186, 26, 0x03) |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 26 | 48 | 0x76 | 0x00 | `1A 00 30 FF 76 00 00 20 00 00 00 44 00 08 00 00` |
| I2 | 60 | 10 | 0x00 | 0x00 | `3C 00 0A FF 00 00 00 10 00 00 00 3C 00 0A 00 00` |
| I3 | 73 | 53 | 0x00 | 0x00 | `49 00 35 FF 00 00 00 10 00 00 00 49 00 35 00 00` |
| I4 | 111 | 6 | 0xD0 | 0x00 | `6F 00 06 FF D0 00 00 20 00 19 00 44 00 04 00 00` |
| I5 | 124 | 30 | 0xD0 | 0x00 | `7C 00 1E FF D0 00 00 20 00 19 00 44 00 02 00 00` |
| I6 | 147 | 50 | 0xD0 | 0x00 | `93 00 32 FF D0 00 00 20 00 19 00 44 00 01 00 00` |

## 346MP83.mdt — 7-C. Llama sub-area

- **width**: 128 tiles (height fixed at 64)
- **cavern level**: 0x08 (8)
- **tear coords**: (65535, 255)
- **doors**: 3, **monsters**: 7, **items**: 0

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 6 | 13 | 0xC2 | MP80.MDT | Regular Door |
| D2 | 29 | 52 | 0xC1 | MP7D.MDT | Locked Door  (Lion Key required) |
| D3 | 86 | 6 | 0xC2 | MP80.MDT | Regular Door |

### Monsters
| # | x | y | type | name (tentative) | act | spwn (x,y,type) |
|---|---:|---:|---:|---|---:|---|
| M1 | 6 | 0 | 0x03 | Rat | 0x00 | (6, 0, 0x03) |
| M2 | 12 | 29 | 0x03 | Rat | 0x00 | (12, 29, 0x03) |
| M3 | 21 | 54 | 0x03 | Rat | 0x00 | (21, 54, 0x03) |
| M4 | 33 | 15 | 0x03 | Rat | 0x00 | (33, 15, 0x03) |
| M5 | 70 | 13 | 0x03 | Rat | 0x00 | (70, 13, 0x03) |
| M6 | 99 | 36 | 0x03 | Rat | 0x00 | (99, 36, 0x03) |
| M7 | 113 | 15 | 0x03 | Rat | 0x00 | (113, 15, 0x03) |

## 347MP84.mdt — 7-D. Llama dungeon

- **width**: 64 tiles (height fixed at 64)
- **cavern level**: 0x08 (8)
- **tear coords**: (30, 6)
- **doors**: 2, **monsters**: 0, **items**: 1

### Doors
| # | x | y | flags | dest map | type |
|---|---:|---:|---:|---|---|
| D1 | 16 | 51 | 0x42 | MP84.MDT | Regular Door |
| D2 | 30 | 5 | 0x00 | MP8D.MDT | Regular Door |

### Items
| # | x | y | type | act | raw |
|---|---:|---:|---|---:|---|
| I1 | 60 | 53 | 0x76 | 0x00 | `3C 00 35 FF 76 00 00 20 00 00 00 45 00 10 00 00` |

## 348MP8D.mdt — 7-D. Llama cavern (Dragon boss)

- **width**: 70 tiles (height fixed at 64)
- **cavern level**: 0x08 (8)
- **tear coords**: (65535, 255)
- **doors**: 0, **monsters**: 0, **items**: 0

## 349MP90.mdt — 8-1. Pureza cavern (acid; Cape gates)

- **width**: 42 tiles (height fixed at 64)
- **cavern level**: 0x09 (9)
- **tear coords**: (65535, 255)
- **doors**: 0, **monsters**: 0, **items**: 0

## 350MPA0.mdt — 8-2. Esco final approach

- **width**: 73 tiles (height fixed at 64)
- **cavern level**: 0x0A (10)
- **tear coords**: (65535, 255)
- **doors**: 0, **monsters**: 0, **items**: 0
