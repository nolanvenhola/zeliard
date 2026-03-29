# Zeliard Reverse Engineering Project

Complete reverse engineering of Zeliard (Game Arts, 1987/1990) â€” a DOS action-RPG. The primary goal is a fully reconstructed, bit-perfect assembly source tree that compiles back to the original game binaries.

## Current State

- **58 ASM source files** compile bit-perfect to their original binaries
- **All three SAR archives** (zelres1/2/3.sar) rebuild bit-perfect from source
- **Full virtual filesystem** mapped â€” every chunk identified by original filename
- **Single-command build**: `python3 build_all.py --verify` compiles everything in one DOSBox-X session and verifies the results

## Quick Build

```bash
cd 3_Assembly/tasm
python3 build_all.py --verify
```

Compiles all 58 ASM files in a single DOSBox-X session, copies data files, packs zelres1/2/3.sar, and verifies bit-perfect output.

## Project Structure

### 1_OriginalGame/
Original unmodified DOS game files.
- `zeliad.exe` â€” main loader
- `game.bin`, `gmmcga.bin`, `gmcga.bin`, etc. â€” driver/engine binaries
- `zelres1.sar`, `zelres2.sar`, `zelres3.sar` â€” resource archives (290 total chunks)

### 2_SAR/
SAR archive tools and extracted chunks.
- `Tools/extract_sar.py` â€” extracts all chunks using size-field headers
- `Tools/pack_sar.py` â€” repacks chunks into SAR archives
- `ExtractedChunks/zelres{1,2,3}_extracted/` â€” raw extracted chunks

### 3_Assembly/tasm/
The primary work area. All assembly source and compiled output.

```
working/
  core/           zeliad.asm, game.asm
  drivers/        gmcga, gmega, gmhgc, gmmcga, gmtga, stdply, stick
  zelres1/code/   14 ASM files (100OPDMO through 130UTILB)
  zelres1/data/   28 data files (.grp, .msd)
  zelres2/code/   21 ASM files (200FIGHT through 250ENDMO)
  zelres2/data/   38 data files (.grp, .msd, .mdt)
  zelres3/code/   12 ASM files (300LVLLD, MP10 maps, 356LVGRP)
  zelres3/data/   69 data files (.grp, .msd, .mdt)

bin/
  zeliad.exe, game.bin, gm*.bin, stdply.bin, stick.bin
  zelres1/        40 compiled chunks
  zelres2/        58 compiled chunks (40 primary + 18 extended)
  zelres3/        96 compiled chunks (40 primary + 56 extended)
  zelres1/2/3.sar rebuilt archives
```

**File naming convention**: `X##PPPPP.ext`
- `X` = resource archive (1=zelres1, 2=zelres2, 3=zelres3)
- `##` = chunk index (00-95)
- `PPPPP` = purpose abbreviation
- `.ext` = `.bin` (code/data), `.grp` (graphics), `.msd` (music), `.mdt` (dungeon map)

### 3_Assembly/tasm/TasmRunner/
C# app that drives TASM 2.01 inside DOSBox-X.

### 3_Assembly/tasm/SourcerRunner/
C# app that drives Sourcer 8.01 disassembler inside DOSBox-X.

### 3_Assembly/tasm/Documentation/
- `CHUNKS/` â€” chunk walkthroughs, format docs, complete chunk index
- `mdt_dungeon_format.md` â€” dungeon map file format (.MDT)
- Driver and core module walkthroughs

### 4_Resources/
Reference materials â€” game manual (PDF), maps (BMP), MIDI music, sprites, playthrough notes.

### 6_DOSBoxMCP/
MCP server for live DOSBox-X control from Claude Code (breakpoints, memory inspection).

## SAR Virtual Filesystem

References inside game binaries: `[archive_index] [chunk_1indexed] 'FILENAME.EXT' 0x00`

To locate a file in a SAR:
1. `offset = (chunk_1indexed - 1) * 4`
2. `data_start = dword at sar[offset]`
3. `length = dword at sar[data_start]`
4. `content = sar[data_start+4 .. data_start+4+length]`

## Chunk Map Summary

### zelres1 (40 chunks)
| Range | Contents |
|---|---|
| 00-11 | Core code: opening scene, image system, player, palette, VGA decoder |
| 12-39 | Opening cinematic graphics (.grp), animation table, music (.msd) |

### zelres2 (58 chunks: 40 primary + 18 extended)
| Range | Contents |
|---|---|
| 00-06 | Core gameplay engine: main loop, combat, sprites, physics, animation, AI dispatcher |
| 07 | Muralla section AI |
| 08-17 | Town building programs: YMPD, CKPD, KINGPRO, OMOYPRO, ARMRPRO, BANKPRO, CHURPRO, DRUGPRO, INNAPRO, KENJPRO |
| 18-35 | Gameplay sprite sets |
| 36-45 | Town overworld maps: CMAP, MRMP, STMP, BSMP, HLMP, TMMP, DRMP, LLMP, PRMP, ESMP (.mdt) |
| 46-49 | Music: MGT1, MGT2, UGM1, UGM2 (.msd) |
| 50 | Gameplay engine module 2 (250ENDMO) |
| 51-57 | Gameplay sprite data (.grp) |

### zelres3 (96 chunks: 40 primary + 56 extended)
| Range | Contents |
|---|---|
| 00 | Demo/attract mode (ROKADEMO) |
| 01-08 | Enemy AI per world: EAI1-EAI8 (Muralla, Satono, Bosque, Helada, Tumba, Dorado, Llama, Pureza) |
| 09-19 | Boss code: Cangrejo, Pulpo, Pollo, Zela, Meda, Lega, ZEL2, Dragon, Akma, Mao1, Mao2 |
| 20-50 | Dungeon maps: MP10-MPA0 (.mdt, loaded at segment 0xC000) |
| 51-84 | Boss/NPC/environment sprites (.grp) |
| 85-95 | Music: MUS1-MUS8, MBOS, MFAN, MMAO (.msd) |

## Dungeon Map Format (.MDT)

Files loaded at segment offset `0xC000`. 9-word pointer table at start:

| Offset | Field | Notes |
|---|---|---|
| 0x00 | unknown | |
| 0x02 | width | Dungeon width in tiles (height always 64) |
| 0x04 | v_platforms | 3B each, 0xFFFF stop |
| 0x06 | objects | Air streams â€” 3B each, 0xFFFF stop |
| 0x08 | h_platforms | 7B each, 0xFFFF stop |
| 0x0A | doors | 12B each, 0xFFFF stop |
| 0x0C | items | Accomplished items, 0xFFFF stop |
| 0x0E | name | Cavern name renderer |
| 0x10 | monsters | 16B each (some enemies use 2 records), 0xFFFF stop |

## Key Tools

| Tool | Purpose |
|---|---|
| `3_Assembly/tasm/build_all.py` | Full build pipeline: compile + pack + verify |
| `2_SAR/Tools/extract_sar.py` | Extract chunks from SAR archives |
| `2_SAR/Tools/pack_sar.py` | Pack chunks back into SAR archives |
| `3_Assembly/tasm/TasmRunner/` | TASM 2.01 runner via DOSBox-X |
| `3_Assembly/tasm/SourcerRunner/` | Sourcer 8.01 disassembler runner via DOSBox-X |

## Game Information

- **Title**: Zeliard
- **Developer**: Game Arts
- **Publisher**: Sierra On-Line (English), Game Arts (Japanese)
- **Year**: 1987 (PC-98/Japan), 1990 (DOS/English)
- **Genre**: Action RPG / Platformer

## Copyright

Original game Â© 1987, 1990 Game Arts / Â© 1990 Sierra On-Line.
This repository contains only assembly reconstructions and tooling â€” no original game assets.
