# Zeliard Reverse Engineering Project

Complete reverse engineering of Zeliard (Game Arts, 1987/1990) — a DOS
action-RPG. Primary goal: a fully reconstructed, bit-perfect assembly
source tree that compiles back to the original game binaries, with
every byte and every mechanic explained.

## Current State

- **60 ASM source files** — all compile bit-perfect to original binaries
- **All three SAR archives** (zelres1/2/3.sar) rebuild bit-perfect from source
- **Zero raw-hex memory operands** without symbolic EQU names (`find_missing_equs.py` reports 0 MISSING + 0 UNUSED)
- **Zero unannotated bare-db lines** across all 60 files
- **Game mechanics**: 178/229 (78%) fully code-traced; remainder partial or method-bound (GRP/DOSBox)
- **TCRF save-format unification** applied — `keys_normal`, `hero_level`, `tears_of_esmesanti_count`, etc. match the canonical Zeliard wiki layout

## Quick Build

```bash
cd 3_Assembly/tasm
python3 build_all.py --verify
```

Compiles all 60 ASM files in a single DOSBox-X session, copies data,
packs zelres1/2/3.sar, and verifies bit-perfect output. Required success
output:

```
zelres1.sar: BIT-PERFECT (256,952 bytes)
zelres2.sar: BIT-PERFECT (345,218 bytes)
zelres3.sar: BIT-PERFECT (342,434 bytes)
```

For single-file iteration: `python3 verify1.py <relpath>` (sub-second
per file) before running the full SAR rebuild.

## Project Structure

### 1_OriginalGame/
Original unmodified DOS game files.
- `zeliad.exe` — main loader (2,544 B)
- `game.bin`, `gmmcga.bin`, `gmcga.bin`, `gmega.bin`, `gmhgc.bin`,
  `gmtga.bin`, `stdply.bin`, `stick.bin` — driver/engine binaries
- `zelres1.sar` (256 KB, 40 chunks)
- `zelres2.sar` (345 KB, 58 chunks)
- `zelres3.sar` (342 KB, 96 chunks)

### 2_SAR/
SAR archive tools, extracted chunks, and the .grp image viewer.
- `Tools/extract_sar.py` — extracts all chunks using size-field headers
- `Tools/pack_sar.py` — repacks chunks into SAR archives
- `Tools/decompress_sar.py` — decompresses chunk payload (fill_buffer)
- `Tools/grp_viewer.py` — interactive viewer for .grp sprite/image data
- `ExtractedChunks/zelres{1,2,3}_extracted/` — raw extracted chunks

### 3_Assembly/tasm/
Primary work area — all assembly source, compiled output, and tooling.

```
working/
  core/           zeliad.asm, game.asm
  drivers/        gmcga, gmega, gmhgc, gmmcga, gmtga, stdply, stick
  zelres1/code/   12 ASM files (100OPDMO + 5 GD drivers + 106TOWN + 5 GT drivers)
  zelres1/data/   28 data files (.grp, .msd, font.bin)
  zelres2/code/   19 ASM files (200FIGHT, 201SELCT, 5 GF drivers, MOLE, YMPD,
                                  CKPD, 8 NPC programs, 250ENDMO)
  zelres2/data/   38 data files (.grp, .msd, .mdt)
  zelres3/code/   20 ASM files (300ROKAD demo, 301-308 EAI1-EAI8,
                                  309-319 boss/sub-boss handlers)
  zelres3/data/   76 data files (.grp, .msd, .mdt — 31 maps + 45 sprites)

bin/    output binaries identical to 1_OriginalGame/
```

**File naming convention** (8.3, DOSBox-compatible): `X##PPPPP.ext`
- `X` = resource archive (1, 2, or 3)
- `##` = chunk index (00-95)
- `PPPPP` = 5-char purpose abbreviation (matches the original
  `resource_name_table` in 200FIGHT.asm where known — e.g. `309CRAB`
  for the Cangrejo boss = Spanish "crab")

### 3_Assembly/tasm/Documentation/
Mechanics walkthroughs and the master investigation tracker.

| Doc | Coverage |
|---|---|
| `MECHANICS_TO_UNDERSTAND.md` | 178/229 (78%) checklist of every game mechanic; ✓ items have asm trace + code citations |
| `ARCHITECTURE.md` | Boot order, segment layout, INT 60h service dispatch, SAR chunk loader |
| `PLAYER_PHYSICS.md` | Joystick → state dispatch, jump/fall/ladder/platform-raise, tile collision |
| `TILE_PHYSICS.md` | Tile-type → physics (lava damage, force-vulnerable bytes, walkable bytes) |
| `BOSS_AI.md` | Two-chunk architecture, 16-byte slot record, per-boss state-machine pattern |
| `INVENTORY_SYSTEM.md` | 201SELCT panels, 8 item-use handlers, equip/un-equip flow |
| `MUSIC_SYSTEM.md` | mscmt.drv MT-32 driver, INT 60h dispatch, gvar_sound_flag |
| `SAVE_FORMAT.md` | 256-byte .USR layout (TCRF authoritative); INT 21h 3Ch/40h/3Eh write path |
| `SCRIPT_INTERPRETER.md` | NPC bytecode VM at cs:[6004], opcode dispatch table, dialog services |
| `BOOT_FLOW.md` | zeliad.exe → game.bin → fight.bin handoff |
| `OPENING_CINEMATIC.md` | 100OPDMO slideshow, image_22 decoder, title-logo render |
| `code_chunks_overview.md` | "Which chunk should I read for X?" dictionary |

### 3_Assembly/tasm/ — Tooling

24 Python helpers covering build, verify, audit, and migration:

| Tool | Purpose |
|---|---|
| `build_all.py --verify` | Full SAR rebuild + bit-perfect check |
| `verify1.py <relpath>` | Per-file fast verify (<2 s) |
| `find_missing_equs.py` | Audit for raw-hex operands without EQU names |
| `name_clarity_audit.py` | Flag procs failing the verb+noun naming rule |
| `generate_symbol_index.py` | Rebuild `working/SYMBOL_INDEX.md` |
| `audit_section.py` | Per-section walkthrough audit (proc/data/macro) |
| `evidence_check.py` | Evidence-weight scoring for symbol-sweep decisions |
| `save_edit.py` / `save_decode.py` / `save_diff.py` | .USR save-file tools (GUI + CLI) |
| `pack_tasm_sar.py` | Pack .bin chunks back into a SAR archive |
| `data_pattern_verify.py` | Verify data-pattern annotations across all chunks |
| `functest/` | Unicorn-based proc-equivalence probes (24 written) |

### 3_Assembly/tasm/TasmRunner/
C# host app that drives TASM 2.01 inside DOSBox-X (batch assembly).

### 3_Assembly/tasm/SourcerRunner/
C# host app that drives Sourcer 8.01 disassembler inside DOSBox-X.

### 4_Resources/
Reference materials — game manual (PDF), maps (BMP), MIDI music,
sprites, playthrough notes. Includes `MdtViewer/` (Avalonia UI for
.MDT dungeon maps).

### 5_MonoGame/MONOGAME_AUTHENTIC/
Active C# port using MonoGame. Loads real SAR data and renders via
the same nibble-pair palette system the original game uses. Status:
opening cinematic + title screen working; gameplay scenes WIP.

### 6_DOSBoxMCP/
MCP server for live DOSBox-X control from Claude Code (breakpoints,
memory inspection). Currently broken — manual DOSBox-X debugger only.

## SAR Virtual Filesystem

References inside game binaries: `[archive_index] [chunk_1indexed] 'FILENAME.EXT' 0x00`

To locate a file in a SAR:
1. `offset = (chunk_1indexed - 1) * 4`
2. `data_start = dword at sar[offset]`
3. `length = dword at sar[data_start]` (only for SAR-loaded chunks; DOS-loaded files like game.bin/stick.bin have no length header)
4. `content = sar[data_start+4 .. data_start+4+length]`

SAR-loaded chunks are also fill_buffer-compressed when loaded with
`AL=2`; raw chunks (`AL=3`) skip decompression. See
`2_SAR/Tools/decompress_sar.py` and the fill_buffer notes in
`3_Assembly/tasm/Documentation/ARCHITECTURE.md`.

## Chunk Map Summary

### zelres1 (40 chunks, 12 code + 28 data)
| Range | Contents |
|---|---|
| 00-11 | Code: opening cinematic (100OPDMO), 5 GD-drivers (GDEGA/CGA/HGC/TGA/MCA), town engine (106TOWN), 5 GT-drivers (GTEGA/CGA/HGC/TGA/MCA) |
| 12-39 | Data: font.bin, opening images (nec/hou/dmaou/ttl1-3/hime/oui/sei/yuu1-4/yuup/oup/maop), waku.grp window frame, zopn.msd / zend.msd music |

### zelres2 (58 chunks, 19 code + 38 data)
| Range | Contents |
|---|---|
| 00-06 | Core gameplay: 200FIGHT (cavern engine), 201SELCT (inventory), 5 GF-drivers |
| 07 | 207MOLE — generic graphics-init module |
| 08-17 | Town NPC programs: YMPD, CKPD, KINGPRO, OMOYPRO (+ end-demo trigger), ARMRPRO, BANKPRO, CHURPRO, DRUGPRO, INNAPRO, KENJPRO (Sage) |
| 18-35 | Gameplay sprite sets (.grp / .bin) |
| 36-45 | Town maps: CMAP, MRMP, STMP, BSMP, HLMP, TMMP, DRMP, LLMP, PRMP, ESMP (.mdt) |
| 46-49 | Music: MGT1, MGT2, UGM1, UGM2 (.msd) |
| 50 | 250ENDMO — ending cinematic module |
| 51-57 | Extended sprite data (.grp) |

### zelres3 (96 chunks, 20 code + 76 data)
| Range | Contents |
|---|---|
| 00 | 300ROKAD — demo/attract mode |
| 01-08 | Enemy AI per world: EAI1-EAI8 (Muralla, Satono, Bosque, Helada, Tumba, Dorado, Llama, Pureza) |
| 09-19 | Boss code: CRAB (Cangrejo), TAKO (Pulpo), TORI (Pollo), ZELA, MEDA, LEGA, ZEL2, DRGN (Dragon), AKMA, MAO1, MAO2 |
| 20-50 | Dungeon maps: MP10-MPA0 (.mdt, loaded at game_seg:0xC000) |
| 51-84 | Boss/NPC/environment sprites: FMAN, ROKA, DMAN, DCHR, ENCNT, ENP1-N, MPP1-B, sprites (.grp) |
| 85-95 | Music: MUS1-MUS8, MBOS, MFAN, MMAO (.msd) |

## Dungeon Map Format (.MDT)

Files loaded at `game_seg:0xC000`. 9-word pointer table at start:

| Offset | Field | Notes |
|---|---|---|
| 0x00 | unknown | |
| 0x02 | width | Dungeon width in tiles (height always 64) |
| 0x04 | v_platforms | 3B each, 0xFFFF stop |
| 0x06 | objects | Air streams — 3B each, 0xFFFF stop |
| 0x08 | h_platforms | 7B each, 0xFFFF stop |
| 0x0A | doors | 12B each, 0xFFFF stop |
| 0x0C | items | Pickup records, 0xFFFF stop |
| 0x0E | name | Cavern name renderer |
| 0x10 | monsters | 16B each (some enemies use 2 records), 0xFFFF stop |

See `3_Assembly/tasm/Documentation/code_chunks_overview.md` for the
per-cavern map → boss mapping.

## Workflow Highlights

- **Symbol sweeps** — codebase-wide rename passes (player-record / gvar
  / driver-dispatch / hardcoded-operand). Each rename verified by
  `verify1.py` + `build_all.py --verify`. See
  `.claude/skills/symbol-sweep/SKILL.md` for the recipe.
- **Tier-3 probes** — Unicorn-based proc-equivalence tests
  (`functest/proc_equivalence/`). Used to resolve PLACEHOLDER_NAME
  procs by replaying them under controlled inputs and verifying the
  observable side-effects match a hypothesis.
- **TCRF save-format unification** (2026-05-05) — reconciled
  stdply.inc canonical names against the TCRF wiki layout; canonical
  names are SSOT, earlier misnomers retained as deprecated alias EQUs
  with a comment explaining why they were wrong.
- **Mechanics doc workflow** — every ✓ promotion in
  `MECHANICS_TO_UNDERSTAND.md` must be backed by an actual asm trace
  with code citations. No promotions from user testimony alone.

## Game Information

- **Title**: Zeliard
- **Developer**: Game Arts
- **Publisher**: Sierra On-Line (English), Game Arts (Japanese)
- **Year**: 1987 (PC-98/Japan), 1990 (DOS/English)
- **Genre**: Action RPG / platformer

## Copyright

Original game © 1987, 1990 Game Arts / © 1990 Sierra On-Line.
This repository contains only assembly reconstructions and tooling —
no original game assets ship with the source. Build artifacts in
`1_OriginalGame/` come from the user's legally-owned copy of the game.
