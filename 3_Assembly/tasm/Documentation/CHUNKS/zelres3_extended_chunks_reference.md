# ZELRES3 Extended Chunks Reference (40–95)

**Archive**: `zelres3.sar`
**Extended chunk range**: 40–95 (56 chunks; chunk_56 is code — see 356LVGRP.asm)
**Location in SAR**: Extended offset table at bytes 0xA0–0x17F (56 × 4-byte entries)
**Last Updated**: 2026-03-22

---

## Format Notes

The zelres3 extended table is 224 bytes (56 entries × 4 bytes) between the primary table end
(0xA0) and the first primary chunk (0x180). Content spans level modules, tile data, enemy
graphics, map attributes, and music.

---

## Chunks 40–50 — Level Code Modules

These contain level-specific runtime data with embedded ASCII strings identifying the area.
They use non-standard flag bytes (not fill_buffer), loaded directly into memory.

| Chunk | File | Size | Embedded String / Notes |
|-------|------|------|--------------------------|
| 40 | lvl_code40.bin | 4,784B | Level code module (no embedded string identified) |
| 41 | hut_code.bin | 431B | "In the Hut" — inn/hut room |
| 42 | calien.bin | 724B | "Cavern of Caliente" — fire cavern |
| 43 | tilemap43.bin | 7,298B | Multi-section: NEC 216B + VGA tilemap → 22,346B decompressed |
| 44 | tilemap44.bin | 7,459B | Multi-section: VGA tilemap → 7,233B decompressed |
| 45 | lvl_code45.bin | 5,577B | Level code module |
| 46 | lvl_code46.bin | 3,251B | Level code module |
| 47 | finalcvn.bin | 1,432B | "Cavern of Final" |
| 48 | absorcvn.bin | 661B | "Cavern of Absorption" |
| 49 | jashiin1.bin | 480B | "Jashiin's room" — final boss chamber, module 1 |
| 50 | jashiin2.bin | 1,015B | "Jashiin's room" — final boss chamber, module 2 |

Chunks 43 and 44 are genuine multi-section (NEC + VGA) with real VGA tilemap data.
The others use non-standard flag bytes consistent with raw-loaded level behavior tables.

---

## Chunks 51–55 — Tile System Data

### Chunk 51 — `tileani.bin` (5,463B → 8,176B decompressed)
**Type**: Tile animation frame index table
**Format**: fill_buffer opcode 6 (2-byte table RLE)
**Content**: Sequential tile indices (00, 01, 02…) separated by null bytes — tile frame
lookup table defining animation frames per tile type.

### Chunk 52 — `tilepal.bin` (4,816B → 5,952B decompressed)
**Type**: Tileset palette/attribute table
**Format**: fill_buffer opcode 6
**Content**: Palette index mapping pairs (key→value format). Same decompressed size as
zelres2/chunk_57 and zelres3/chunk_52, suggesting a shared attribute format.

### Chunk 53 — `dman.grp` (1,363B → ~1,728B decompressed)
**Original name**: DMAN.GRP
**Type**: Dungeon manager / player overworld sprite
**Format**: Escape-byte RLE (fill_buffer opcode 7)
**Dimensions**: ~48×144, 72×96, or 96×72 px (2-plane 1bpp GRP)

### Chunk 54 — `sprite54.grp` (1,669B → ~1,872B decompressed)
**Type**: Small character sprite
**Format**: Escape-byte RLE (fill_buffer opcode 7)
**Dimensions**: ~104×72 px

### Chunk 55 — `vgareg55.bin` (897B → ~891B)
**Type**: VGA register/palette data sequence
**Format**: Non-standard flag byte (opcode 1)
**Content**: Repeating `0xFF 0x2F` patterns + `0x60 0x00 0x20 0x00` sequences consistent
with VGA OUT instruction sequences for palette/register initialization.

---

## Chunk 56 — CODE (356LVGRP.asm)

**See**: `3_Assembly/tasm/working/zelres3/code/356LVGRP.asm`
Level graphics module. Contains INT 10h (BIOS video) calls. Compiles byte-perfect to 6,262 bytes.

---

## Chunks 57–64 — Enemy Encounter Screen Backgrounds (ENP*.GRP)

All use fill_buffer opcode 0 (raw copy). Decompressed sizes ~7,000–8,200 bytes.
These are the background images shown during enemy combat encounters.

| Chunk | File | Raw Size | Approx Dimensions | Notes |
|-------|------|----------|-------------------|-------|
| 57 | enp1.grp | 6,820B | ~680×48 or ~408×80 | Encounter BG 1 |
| 58 | enp2.grp | 6,101B | ~496×64 or ~248×128 | Encounter BG 2 |
| 59 | enp3.grp | 5,705B | ~520×56 | Encounter BG 3 |
| 60 | enp4.grp | 6,706B | ~680×48 | Encounter BG 4 |
| 61 | enp5.grp | 6,482B | ~680×48 | Encounter BG 5 |
| 62 | enp6.grp | 6,897B | ~1016×32 | Encounter BG 6 |
| 63 | enp7.grp | 6,673B | ~584×56 | Encounter BG 7 |
| 64 | enp8.grp | 5,324B | ~584×56 | Encounter BG 8 |

---

## Chunks 65–73 — Enemy Combat Sprites

All use fill_buffer opcode 6 (2-byte table RLE). Decompressed sizes 6,000–8,200 bytes.
These are the enemy sprites displayed during battle encounters.

| Chunk | File | Raw Size | Enemy Name | Notes |
|-------|------|----------|-----------|-------|
| 65 | crab.grp | 5,615B | CRAB — Crab | |
| 66 | tako.grp | 4,297B | TAKO — Octopus | tako = Japanese for octopus |
| 67 | tori.grp | 5,108B | TORI — Bird | tori = Japanese for bird |
| 68 | zela.grp | 6,661B | ZELA — Zeliard-type | |
| 69 | meda.grp | 5,459B | MEDA — Medusa | |
| 70 | lega.grp | 6,525B | LEGA | |
| 71 | drgn.grp | 6,719B | DRGN — Dragon | |
| 72 | akma.grp | 5,377B | AKMA — Akuma/Devil | akuma = Japanese for demon |
| 73 | mao1.grp | 6,728B | MAO1 — Jashiin phase 1 | Maoh = Demon King (final boss) |

---

## Chunks 74–84 — Map Page Tile Attributes (MPP*.GRP)

All use fill_buffer opcode 0 (raw). These define tile visual/collision attributes per map page.

| Chunk | File | Size | Decomp | Notes |
|-------|------|------|--------|-------|
| 74 | mpp1.grp | 1,171B | 1,248B | Map page 1 |
| 75 | mpp2.grp | 1,597B | 1,680B | Map page 2 |
| 76 | mpp3.grp | 1,755B | 2,112B | Map page 3 — sequential tile IDs (' !"#$%&') |
| 77 | mpp4.grp | 1,005B | 1,056B | Map page 4 (small) |
| 78 | mpp5.grp | 2,458B | 2,544B | Map page 5 |
| 79 | mpp6.grp | 1,624B | 1,776B | Map page 6 |
| 80 | mpp7.grp | 2,386B | 2,976B | Map page 7 |
| 81 | mpp8.grp | 1,876B | 2,112B | Map page 8 |
| 82 | mpp9.grp | 1,549B | 1,872B | Map page 9 |
| 83 | mppa.grp | 825B | 1,008B | Map page A |
| 84 | mppb.grp | 199B | 193B | Map page B (tiny — VGA register data) |

---

## Chunks 85–95 — Music Sequences (MSD Format)

**Format**: Raw AL=3 load. MSD (Music Sequence Data) — Zeliard proprietary format.
**Magic**: bytes 12–15 = `01 1F 00 02` in all MSD files.
**Sequencer opcodes**: `0xF0, 0xE9, 0xE5, 0xE6, 0xE2`.

| Chunk | File | Size | Track |
|-------|------|------|-------|
| 85 | mus1.msd | 3,623B | MUS1 — Dungeon music track 1 |
| 86 | mus2.msd | 4,047B | MUS2 — Dungeon music track 2 |
| 87 | mus3.msd | 3,392B | MUS3 — Dungeon music track 3 |
| 88 | mus4.msd | 4,045B | MUS4 — Dungeon music track 4 |
| 89 | mus5.msd | 2,339B | MUS5 — Dungeon music track 5 |
| 90 | mus6.msd | 5,561B | MUS6 — Dungeon music track 6 (longest) |
| 91 | mus7.msd | 4,201B | MUS7 — Dungeon music track 7 |
| 92 | mus8.msd | 3,642B | MUS8 — Dungeon music track 8 |
| 93 | mbos.msd | 2,500B | MBOS — Boss battle theme |
| 94 | mfan.msd | 531B | MFAN — Fanfare/level clear jingle (very short) |
| 95 | mmao.msd | 3,517B | MMAO — Jashiin final boss theme |
