# ZELRES2 Extended Chunks Reference (40â€“57)

**Archive**: `zelres2.sar`
**Extended chunk range**: 40â€“57 (18 chunks; chunk_50 is code â€” see 250ENDMO.asm)
**Location in SAR**: Extended offset table at bytes 0xA0â€“0xE7 (18 Ã— 4-byte entries)
**Last Updated**: 2026-03-22

---

## Format Notes

These chunks are accessed via the SAR extended offset table â€” a second set of 4-byte offsets
located between the primary 40-entry table (0xA0) and the first primary chunk.

Chunks are loaded differently from primary code/data chunks:
- **NPC data** (40â€“45): multi-section format â€” NEC PC-98 section + optional VGA section
- **Music** (46â€“49): raw AL=3 load â€” MSD sequencer format, flag byte is first data byte
- **Graphics** (51â€“57): fill_buffer compressed GRP images (various opcodes)

---

## Chunk 40 â€” `npc_nec40.bin` (3,588 bytes)

**Type**: NEC PC-98 NPC behavior data (no VGA equivalent)
**Format**: Multi-section; NEC section only â€” dense 0xC7/0xC8 byte patterns
**Purpose**: Town NPC behavior tables for NEC PC-98 hardware. No VGA content means
this data is skipped on VGA/DOS platforms.

---

## Chunk 41 â€” `npc_dlg41.bin` (4,082 bytes)

**Type**: Bilingual NPC dialogue
**Format**: Multi-section â€” NEC section (Japanese, 3784 bytes) + VGA section (English, ~289 compressed â†’ ~167 bytes)
**Confirmed English text**: "Isn't that the Crest of Glory? Please take it quickly to the
owner of the weapons store. . . . . ."

This is the only zelres2 extended chunk with a VGA (English) section confirming this format
was used for hardware-specific localization.

---

## Chunks 42â€“45 â€” NEC PC-98 NPC Data

| Chunk | File | Raw Size | Notes |
|-------|------|----------|-------|
| 42 | npc_nec42.bin | 3,642B | NEC-only NPC behavior, no VGA |
| 43 | npc_nec43.bin | 4,377B | NEC-only NPC behavior |
| 44 | npc_nec44.bin | 4,287B | NEC-only NPC behavior |
| 45 | npc_nec45.bin | 2,566B | NEC-only NPC behavior (smaller) |

All use the multi-section format with only a NEC section and 0-byte VGA section.

---

## Chunks 46â€“49 â€” Music Sequences (MSD Format)

**Format**: Raw AL=3 load. MSD (Music Sequence Data) â€” Zeliard's proprietary music format.
**Magic identifier**: bytes 12â€“15 = `01 1F 00 02` in all MSD files.
**Sequencer opcodes**: `0xF0, 0xE9, 0xE5, 0xE6, 0xE2` = Zeliard music events.

| Chunk | File | Size | Track |
|-------|------|------|-------|
| 46 | mgt1.msd | 3,565B | MGT1 â€” Town BGM track 1 |
| 47 | mgt2.msd | 3,292B | MGT2 â€” Town BGM track 2 |
| 48 | ugm1.msd | 4,042B | UGM1 â€” Underground/dungeon BGM 1 |
| 49 | ugm2.msd | 1,784B | UGM2 â€” Underground/dungeon BGM 2 (short) |

---

## Chunk 50 â€” CODE (250ENDMO.asm)

**See**: `3_Assembly/tasm/working/zelres2/code/250ENDMO.asm`
Gameplay engine module. Calls chunk loader CS:[10Ch] and driver functions CS:[3004h/3008h].
Compiles byte-perfect to 8,687 bytes.

---

## Chunk 51 â€” `chunk_51.bin` (4,904 bytes â†’ 10,720 decompressed)

**Original name**: FMAN.GRP
**Type**: Field NPC character sprites
**Format**: fill_buffer opcode 6 (2-byte table RLE, 39-entry decode table)
**Decompressed size**: 10,720 bytes
**Dimensions** (2-plane 1bpp GRP): ~536Ã—80 px or ~670Ã—64 px
**Purpose**: Overworld/town NPC sprites (FMAN = Field Manager characters)

---

## Chunks 52â€“57 â€” GRP Images

| Chunk | File | Raw Size | Original Name | Content |
|-------|------|----------|---------------|---------|
| 52 | roka.grp | 10,518B | ROKA.GRP | Corridor/hallway background art |
| 53 | image53.grp | 11,488B | â€” | Large background art |
| 54 | dchr.grp | 11,159B | DCHR.GRP | Dungeon character sprites |
| 55 | encnt.grp | 11,533B | ENCNT.GRP | Encounter screen background |
| 56 | image56.grp | 2,185B | â€” | Small sprite/icon graphic |
| 57 | roka2.grp | 4,816B | ROKA2.GRP | Second corridor background variant |

Chunks 52, 54, 56 are raw (flag=0x00, fill_buffer opcode 0 = copy verbatim).
Chunks 53, 55 use non-standard flag bytes (multi-section or alternate RLE).
Chunk 57 uses fill_buffer opcode 6 (2-byte table RLE, decompresses to 5,952B).
