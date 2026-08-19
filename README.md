# Zeliard — Bit-Perfect Reconstruction and Complete Web Port

**[Play the complete game in your browser](https://nolanvenhola.github.io/zeliard/)**

A complete reverse engineering and preservation project for **Zeliard**
(Game Arts, 1987; Sierra On-Line, 1990), the classic action RPG/platformer.
The repository contains a bit-perfect MASM reconstruction of the DOS game,
mechanics documentation, format and archive tooling, behavioral test oracles,
and a complete C/WebAssembly port playable from beginning to end in a modern
browser.

## Play Zeliard in Your Browser

**[Play the complete game](https://nolanvenhola.github.io/zeliard/)** — no
installation or DOS emulator required.

The web edition is a behaviorally faithful reimplementation rather than a DOS
emulator wrapper. Its portable C engine compiles to WebAssembly, with a
TypeScript browser host providing display, audio, input, gamepad, and save-file
integration. It runs the full adventure through the ending and uses resources
reconstructed from the canonical MASM source tree.

## Current State

- **Complete browser port** — fully playable from the opening cinematic to the ending
- **Portable C/WebAssembly engine** with a TypeScript/Vite browser shell
- **Original-compatible 256-byte `.USR` saves** import and export between DOS and web editions
- **Oracle-driven compatibility suite** covering gameplay, rendering, input, transitions, and audio
- **60 ASM source files** — all compile bit-perfect to original binaries
- **All three SAR archives** (zelres1/2/3.sar) rebuild bit-perfect from source
- **Zero raw-hex memory operands** without symbolic EQU names (`find_missing_equs.py` reports 0 MISSING + 0 UNUSED)
- **Zero unannotated bare-db lines** across all 60 files
- **TCRF save-format unification** applied — `keys_normal`, `hero_level`, `tears_of_esmesanti_count`, etc. match the canonical Zeliard wiki layout

## Quick Build

```bash
cd 3_Assembly/masm
python build_masm.py --verify
```

Compiles all 60 canonical MASM source files, copies data, packs
zelres1/2/3.sar, and verifies bit-perfect output. Required success output:

```
zelres1.sar: BIT-PERFECT (256,952 bytes)
zelres2.sar: BIT-PERFECT (345,218 bytes)
zelres3.sar: BIT-PERFECT (342,434 bytes)
```

For single-file iteration: `python verify1.py <relpath>` (sub-second
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

### 3_Assembly/masm/ — Canonical Reconstruction and Behavior Oracle

The MASM 5.1 tree is the authoritative reconstruction, the active
reverse-engineering source, and the sole behavioral reference for the web port.
Release builds reproduce the original binaries and all three SAR archives
bit-for-bit; debug builds and function tests provide instrumented behavior
oracles without changing the canonical release output.

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

bin/          release output identical to 1_OriginalGame/
bin_debug/    instrumented behavior-oracle builds
functest/     MASM-backed behavior and equivalence probes
```

**File naming convention** (8.3, DOSBox-compatible): `X##PPPPP.ext`
- `X` = resource archive (1, 2, or 3)
- `##` = chunk index (00-95)
- `PPPPP` = 5-char purpose abbreviation (matches the original
  `resource_name_table` in 200FIGHT.asm where known — e.g. `309CRAB`
  for the Cangrejo boss = Spanish "crab")

### MASM Tooling

| Tool | Purpose |
|---|---|
| `build_masm.py --verify` | Parallel full build, SAR repack, and bit-perfect verification |
| `build_masm.py --debug` | Build the instrumented behavior-oracle binaries |
| `verify1.py <relpath>` | Fast verification of one reconstructed source file |
| `functest/run.py --ci` | Run MASM behavior probes with PASS/FAIL/INCONCLUSIVE verdicts |
| `functest/proc_equivalence/` | Controlled procedure-level equivalence and behavior tests |

### 3_Assembly/tasm/ — Historical Compatibility Build

The TASM 2.01 tree remains bit-perfect as a historical compatibility build. It
is not the active reconstruction and is not a source of truth for porting
decisions. New reverse-engineering work, symbol changes, debug instrumentation,
and behavior probes belong in `3_Assembly/masm/`.

### 4_Resources/
Reference materials — game manual (PDF), maps (BMP), MIDI music,
sprites, playthrough notes. Includes `MdtViewer/` (Avalonia UI for
.MDT dungeon maps).

### 6_WebPort/
Complete, start-to-finish playable browser port. A portable C engine implements
the game while the TypeScript/Vite shell supplies the web platform, audio,
display, input, gamepad, save-file, automated-playthrough, and deployment layers.

## SAR Virtual Filesystem

References inside game binaries: `[archive_index] [chunk_1indexed] 'FILENAME.EXT' 0x00`

To locate a file in a SAR:
1. `offset = (chunk_1indexed - 1) * 4`
2. `data_start = dword at sar[offset]`
3. `length = dword at sar[data_start]` (only for SAR-loaded chunks; DOS-loaded files like game.bin/stick.bin have no length header)
4. `content = sar[data_start+4 .. data_start+4+length]`

SAR-loaded chunks are also fill_buffer-compressed when loaded with
`AL=2`; raw chunks (`AL=3`) skip decompression. See
`2_SAR/Tools/decompress_sar.py` and the canonical loader in
`3_Assembly/masm/working/core/game.asm`.

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

## Workflow Highlights

- **Symbol sweeps** — codebase-wide rename passes (player-record / gvar
  / driver-dispatch / hardcoded-operand). Each rename verified by
  `verify1.py` + `build_masm.py --verify`. See
  `.claude/skills/symbol-sweep/SKILL.md` for the recipe.
- **Tier-3 probes** — Unicorn-based proc-equivalence tests
  (`functest/proc_equivalence/`). Used to resolve PLACEHOLDER_NAME
  procs by replaying them under controlled inputs and verifying the
  observable side-effects match a hypothesis.
- **TCRF save-format unification** (2026-05-05) — reconciled
  stdply.inc canonical names against the TCRF wiki layout; canonical
  names are SSOT, earlier misnomers retained as deprecated alias EQUs
  with a comment explaining why they were wrong.

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
