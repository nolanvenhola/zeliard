# MDT Dungeon Map File Format

**Source**: Confirmed by binary analysis against `MP10.MDT` (Cavern of Malicia)
**Verified**: Cavern name string "Cavern of Malicia" found at expected offset, all pointer values match.

---

## Overview

`.MDT` files are dungeon map data files loaded at segment offset `0xC000` at runtime.
All pointer values stored in the header are **absolute offsets within the loaded segment**
(i.e. a pointer value of `0xD555` means segment offset `0xD555`, which is file offset `0xD555 - 0xC000 = 0x1555`).

Dungeon height is always **64 tiles**. Width varies per dungeon.

---

## Header (18 bytes at file offset 0x0000 = segment offset 0xC000)

| File Offset | Seg Offset | Size | Description |
|-------------|------------|------|-------------|
| 0x00 | 0xC000 | 2 | Pointer → Dungeon descriptor (see below) |
| 0x02 | 0xC002 | 2 | Dungeon width in tiles (height always = 64) |
| 0x04 | 0xC004 | 2 | Pointer → vertical platforms array |
| 0x06 | 0xC006 | 2 | Pointer → collapsing platforms array |
| 0x08 | 0xC008 | 2 | Pointer → horizontal platforms array |
| 0x0A | 0xC00A | 2 | Pointer → doors array |
| 0x0C | 0xC00C | 2 | Pointer → accomplished items check array |
| 0x0E | 0xC00E | 2 | Pointer → cavern name renderer data |
| 0x10 | 0xC010 | 2 | Pointer → monsters array |
| 0x12 | 0xC012 | 1 | Cavern level |
| 0x13 | 0xC013 | 2 | x-coord of Tear (door to boss) |
| 0x15 | 0xC015 | 1 | y-coord of Tear |
| 0x16 | 0xC016 | 1 | y-coord of hero head in viewport |
| 0x17 | 0xC017 | 2 | Pointer → text signs inside cavern array |

---

## Data Sections

All arrays are terminated with a `0xFFFF` stop marker word.

### Dungeon Descriptor
**Variable size**

Contain indices for choosing sprites, music, enemy AI for the dungeon.

| Offset | Size | Description |
|--------|------|-------------|
| 0 | 1 | bit 7: 1 = boss dungeon, 0 = regular dungeon |
|   |   | bit 6: unknown |
|   |   | bits 1-5: music file index |
|   |   | bit 0: unknown |


### Vertical Platforms
**Entry size: 3 bytes**

| Offset | Size | Description |
|--------|------|-------------|
| 0 | 2 | X tile position |
| 2 | 1 | Y tile position |

### Collapsing Platforms (only exist in caverns 7+)
**Entry size: 3 bytes**

| Offset | Size | Description |
|--------|------|-------------|
| 0 | 2 | X tile position |
| 2 | 1 | Y tile position |

### Horizontal Platforms
**Entry size: 7 bytes**

| Offset | Size | Description |
|--------|------|-------------|
| 0 | 1 | X tile position |
| 1 | 1 | Speed (0x80 = fast, 0x40 = normal) |
| 2 | 1 | bits 0-5: Y tile position, bit 6: paused, bit 7: direction (0=R, 1=L) |
| 3 | 2 | X min tile position |
| 5 | 2 | X max tile position |

### Doors
**Entry size: 12 bytes** — exact field layout TBD

| Offset | Size | Description |
|--------|------|-------------|
| 0 | 2 | X0 tile position |
| 2 | 1 | Y0 tile position |
| 3 | 2 | Flags, TBD |
| 5 | 2 | X1 (destination) |
| 7 | 1 | Y1 (destination), if 0xFF then leads to town |
| 8 | 1 | Flags: bit0 = 1 if Lion Head key needed |
| 9-11 | 3 | Unknown |

### Accomplished Items Check
**Entry size: variable** — TBD, stop marker = `0xFFFF`

### Cavern Name Renderer
Contains the ASCII cavern name string (null-terminated) plus rendering parameters.
Confirmed: `MP10.MDT` contains "Cavern of Malicia\t" at file offset 0x1617.

### Monsters/Items (potions, chests, signs etc.)
**Entry size: 16 bytes** — some monsters occupy 2 consecutive records (32 bytes total).
Stop marker = `0xFFFF`.
`MP10.MDT` (Cavern of Malicia) has 54 monster entries.

| Offset | Size | Description |
|--------|------|-------------|
| 0 | 2 | X current tile position |
| 2 | 1 | Y current tile position |
| 3-10 | 8 | Unknown |
| 11 | 2 | Spawn X tile position |
| 13 | 1 | Spawn Y tile position and flags |
| 14 | 1 | Type |
| 15 | 1 | Unknown |

### Cavern level
**Entry size: 1 byte (immediate value)**
Matches the digit in the cavern filename after 'MP'

### Tear of Esmesanti coords (above dor to the boss)
**Entry size: 3 bytes (immediate values)**
2 bytes for X coord
1 byte for Y coord

### Hero head Y coord in viewport
**Entry size: 1 byte (immediate value)**
Distance from screen top to hero head in tiles

### Text signs inside cavern
**Entry size: variable** — TBD, terminator = `0xFF`
(Peligro example):
D72d: array of pointers; indexed by monster struct byte at offset 6
D72F - single pointer (no more signs in Peligro)
0x01, 0x03, 0x2C, 'Danger!!/ Don\t open/', 0x14, 'the box ahead.', 0xFF

---

## Map Index (from stick.bin reference table)

| File | zelres | chunk | Town | Cavern |
|------|--------|-------|------|--------|
| MP10.MDT | zelres3 | 20 | Muralla | Malicia |
| MP1D.MDT | zelres3 | 21 | ? | Malicia boss |
| MP20.MDT | zelres3 | 22 | Satono | Peligro |
| MP21.MDT | zelres3 | 23 | ? | Peligro1 |
| MP2D.MDT | zelres3 | 24 | ? | Peligro boss |
| MP30.MDT | zelres3 | 25 | Bosque | Madera/Riza |
| MP31.MDT | zelres3 | 26 | ? | ? |
| MP3D.MDT | zelres3 | 27 | ? | ? |
| MP40.MDT | zelres3 | 28 | Helada | Escarcha/Glacial |
| MP41.MDT | zelres3 | 29 | ? | ? |
| MP4D.MDT | zelres3 | 30 | ? | ? |
| MP50.MDT | zelres3 | 31 | Tumba | Corroer/Cementar |
| MP51.MDT | zelres3 | 32 | ? | ? |
| MP5D.MDT | zelres3 | 33 | ? | ? |
| MP60.MDT | zelres3 | 34 | Dorado | Tesoro/Plata |
| MP61.MDT | zelres3 | 35 | ? | ? |
| MP62.MDT | zelres3 | 36 | ? | ? |
| MP6D.MDT | zelres3 | 37 | ? | ? |
| MP70.MDT | zelres3 | 38 | Llama | Caliente/Reaccion/Corroer |
| MP71.MDT | zelres3 | 39 | ? | ? |
| MP72.MDT | zelres3 | 40 | ? | ? |
| MP73.MDT | zelres3 | 41 | ? | ? |
| MP7D.MDT | zelres3 | 42 | ? | ? |
| MP80.MDT | zelres3 | 43 | Pureza | Absor/Millagro/Desleal/Faltar/Final |
| MP81.MDT | zelres3 | 44 | ? | ? |
| MP82.MDT | zelres3 | 45 | ? | ? |
| MP83.MDT | zelres3 | 46 | ? | ? |
| MP84.MDT | zelres3 | 47 | ? | ? |
| MP8D.MDT | zelres3 | 48 | ? | ? |
| MP90.MDT | zelres3 | 49 | Esco | Final |
| MPA0.MDT | zelres3 | 50 | ? | ? |

### Overworld Town Maps (zelres2)

| File | zelres | chunk | Town |
|------|--------|-------|------|
| CMAP.MDT | zelres2 | 36 | ? (Castillo?) |
| MRMP.MDT | zelres2 | 37 | Muralla |
| STMP.MDT | zelres2 | 38 | Satono |
| BSMP.MDT | zelres2 | 39 | Bosque |
| HLMP.MDT | zelres2 | 40 | Helada |
| TMMP.MDT | zelres2 | 41 | Tumba |
| DRMP.MDT | zelres2 | 42 | Dorado |
| LLMP.MDT | zelres2 | 43 | Llama |
| PRMP.MDT | zelres2 | 44 | Pureza |
| ESMP.MDT | zelres2 | 45 | Esco |

---

## Notes

- The map index prefix encodes world/section: `1x` = Muralla, `2x` = Satono, `3x` = Bosque,
  `4x` = Helada, `5x` = Tumba, `6x` = Dorado, `7x` = Llama, `8x` = Pureza, `9x` = Esco, `Ax` = ?
- The suffix digit (0, 1, 2, 3, D) likely indicates sub-area type within a world
  (`D` may = "dungeon exit" or "deep" section)
- Overworld town maps (xxMP.MDT) may use a different internal format from dungeon maps
