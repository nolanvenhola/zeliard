# Zeliard Project — CLAUDE.md

Zeliard (Game Arts 1987 / Sierra On-Line 1990) reverse-engineering project.
Goal: bit-perfect assembly reconstruction, full mechanics documentation,
and a behaviorally-faithful web port.

---

## Quick Build

```bash
# TASM (reference build — verify any asm changes here first)
cd 3_Assembly/tasm
python build_all.py --verify        # full rebuild + SAR diff
python verify1.py zelres1/code/100OPDMO.asm  # single-file check (<2 s)

# MASM 5.1 (working build — supports --debug flag)
cd 3_Assembly/masm
python build_masm.py --verify       # full rebuild + SAR diff
python build_masm.py --debug        # debug build → bin_debug/
python verify1.py zelres1/code/100OPDMO.asm
```

Both builds must produce:
```
zelres1.sar: BIT-PERFECT (256,952 bytes)
zelres2.sar: BIT-PERFECT (345,218 bytes)
zelres3.sar: BIT-PERFECT (342,434 bytes)
```

---

## Directory Layout

```
1_OriginalGame/          Original DOS binaries (zeliad.exe + 3 SAR archives). Never modify.
2_SAR/
  Tools/                 extract_sar.py, decompress_sar.py, grp_viewer.py
  ExtractedChunks/       Raw extracted chunks (40+58+96 = 194 files)
3_Assembly/
  tasm/                  REFERENCE build — TASM 2.01, bit-perfect, do not break
    working/             Source files (core/, drivers/, zelres1-3/)
    bin/                 Release output (matches 1_OriginalGame binaries)
    bin_debug/           Debug output (DEBUG_BUILD=1, larger binaries)
    Documentation/       MECHANICS_TO_UNDERSTAND.md + 11 topic docs
    build_all.py         Batch build + SAR pack
    verify1.py           Single-file fast verify
    pack_tasm_sar.py     SAR packer
  masm/                  WORKING build — MASM 5.1, same source adapted
    working/             MASM-adapted source (same 60 files)
    bin/                 Release output (bit-perfect vs tasm/bin)
    bin_debug/           Debug output
    build_masm.py        Batch build + SAR pack (parallel, 8 workers)
    verify1.py           Single-file fast verify
4_Resources/             Manual, maps, MIDI, sprites, FAQ
5_MonoGame/              Archived C# prototype — do not extend
6_WebPort/               Active web port (C engine + TypeScript shell)
  engine/                C source (core/, load/, render/, game/, audio/, platform/)
  shell/                 TypeScript browser host (Vite + WebGL2)
  opening_demo_flow.md   Step-by-step trace of 100OPDMO.asm for web port reference
6_DOSBoxMCP/             DOSBox-X MCP server — CURRENTLY BROKEN, do not use
```

---

## Source Tree Layout (both tasm/ and masm/ working/)

```
core/       zeliad.asm (DOS loader), game.asm (main init + resource loader)
drivers/    gmcga/ega/hgc/tga/mca.asm (CGA/EGA/HGC/TGA/MCGA graphics)
            stdply.asm (player record), stick.asm (INT 60h driver)
zelres1/
  code/     100OPDMO (opening cinematic), 101-105 GD-drivers, 106TOWN, 107-111 GT-drivers
  data/     28 .grp/.msd files
zelres2/
  code/     200FIGHT (cavern engine), 201SELCT (inventory), 202-206 GF-drivers,
            207MOLE, 208-217 NPC programs, 250ENDMO
  data/     38 .grp/.msd/.mdt files
zelres3/
  code/     300ROKAD, 301-308 EAI1-EAI8 enemy AI, 309-319 bosses
  data/     76 .grp/.msd/.mdt files
```

---

## Critical Architecture Facts

### Game Segment Memory Map
At runtime everything lives in one 64 KB segment (CS = DS throughout):

| CS offset | Contents |
|---|---|
| 0x0000 | stdply.bin (player record, 233 B) |
| 0x0100 | stick.bin (INT 60h driver, ~4 KB) |
| 0x3000 | Graphics driver (GD*/GF*/GT*, loaded at runtime) |
| 0x6000 | Active chunk (opening/town/fight, loaded at runtime) |
| 0xA000 | game.bin (init + resource loader) |
| 0xF500 | font.grp data |
| 0xFF00–0xFF7F | gvar_* globals (shared by all modules) |

### SAR Chunk Loading
- **AL=2**: fill_buffer-compressed load; SAR entry = `[4-byte size][compressed data]`
- **AL=3**: raw load; SAR entry = `[4-byte size][raw data]`
- Both: the loader **strips the 4-byte size header** and loads the raw data at ES:DI
- The 4-byte header bytes `29 36 00 00` are deliberately chosen to decode as `sub word ptr ds:[0], si` — harmless junk executed before real code at offset +4

### DBG_CHUNK_BASE (MASM debug builds only)
When `DEBUG_BUILD EQU 1` is compiled into a chunk:
- The SAR loader strips 4 bytes → binary offset N lands at CS:(CHUNK_LOAD_BASE - 4 + N)
- `DBG_CHUNK_BASE EQU (CHUNK_LOAD_BASE - 4)` corrects this for debug string addressing
- All symbolic EQUs use `DBG_CHUNK_BASE + offset label_name` so they auto-update when inline debug macros shift the binary
- Defined per-file in masm/working/zelres*/code/*.asm

### Dispatch Slot Addresses (100OPDMO.asm specifically)
Function pointers are **NOT** in a normal table — they are embedded as text bytes.
Labels like `disp_game_fn`, `disp_narr_chap3` etc. are at binary offsets whose
numeric values happen to be valid CS addresses pointing to function pointers.
`call word ptr cs:[disp_game_fn]` reads from CS:binary_offset_of_label.

**Problem**: when debug code shifts the binary, these label offsets change and the
call targets wrong memory — causing restart loops.

**Fix**: every `cs:[data_label]` dispatch call must use a hardcoded EQU:
```asm
disp_narr_chap3_slot  equ  2425h   ; binary offset of label in RELEASE bin
...
call word ptr cs:[disp_narr_chap3_slot]   ; always reads CS:0x2425
```
See `3_Assembly/masm/working/zelres1/code/100OPDMO.asm` lines 99-124 for the full list.

### GRP Image Format
Two-plane 1bpp → 4-plane interleave → nibble-packed blit.
Palette: nibble 0=black, 0xA=red (or yellow), 0xC=teal (or outline), 0x8=dark.
See `2_SAR/Tools/grp_viewer.py` for complete decode logic.

### Save File (.USR)
256-byte little-endian record at game_seg:0. Canonical layout in
`tasm/working/drivers/stdply.inc`. TCRF authoritative names apply.

---

## Two Build Trees — Which to Edit?

| Task | Edit | Why |
|---|---|---|
| RE work, symbol renames, mechanic docs | `tasm/working/` | This is the canonical source |
| Web port reference | `tasm/working/` | Read-only spec for C port |
| Debug output, testing code changes | `masm/working/` | Has debug infrastructure |

The MASM tree is a MASM 5.1–adapted copy of the TASM sources. Changes made in
`tasm/working/` need to be mirrored to `masm/working/` manually if they affect
debug builds. The two trees are not auto-synced.

---

## Debug Build Workflow (MASM)

```bash
cd 3_Assembly/masm
python build_masm.py --debug        # patches DEBUG_BUILD 0→1, builds, restores
```

Run debug binary:
```
3_Assembly/masm/bin_debug/zelplay_debug.bat
```

Port 0xE9 output appears in the console (requires `bochs debug port e9 = true`
in the DOSBox-X config — zelplay_debug.bat already sets this).

**If DEBUG_BUILD gets stuck at 1**: the restore failed. Manually reset:
```python
# In each affected file:
DEBUG_BUILD\tEQU\t1  →  DEBUG_BUILD\tEQU\t0
```

---

## Web Port Status (6_WebPort/)

C engine + TypeScript shell targeting WebGL2 + WebAudio.

```
engine/
  core/         memory.c, timer.c, input.c, assets.c
  load/         grp.c/h (GRP decoder), fill_buffer.c/h, img_open.c/h
  render/       (in progress)
  game/         (in progress)
  audio/        (in progress)
  platform/     platform.h
  main.c        WASM entry point
shell/src/
  main.ts       Boot, asset fetch, engine instantiation
```

Primary reference doc: `6_WebPort/opening_demo_flow.md` — step-by-step
trace of `100OPDMO.asm` for implementing the opening cinematic.

Build:
```bash
cd 6_WebPort/engine && make wasm    # requires Emscripten
cd 6_WebPort/shell && npm run dev
```

---

## Current Work State

- **TASM build**: all 60 files, 3 SARs BIT-PERFECT ✓
- **MASM build**: all 60 files, 3 SARs BIT-PERFECT ✓; debug infrastructure present in game.asm + 100OPDMO.asm
- **Mechanics**: 178/229 (78%) fully code-traced in `tasm/Documentation/MECHANICS_TO_UNDERSTAND.md`
- **Web port**: C engine scaffolding + GRP decoder in place; rendering pipeline WIP
- **5_MonoGame**: archived prototype, do not extend

---

## What NOT to Do

- **DOSBox-X MCP** (`6_DOSBoxMCP/`) is broken — do not propose MCP-based workflows
- **Spice86** traces are stale — do not propose new traces
- **IDA names** are LLM-guessed — do not use as evidence for symbol renames
- **Mark mechanics ✓** in MECHANICS_TO_UNDERSTAND.md without an asm trace with code citations
- **Break TASM bit-perfect** — every change to `tasm/working/` must pass `build_all.py --verify`
- **Use --serial** in build commands unless debugging a single failure
- **Add debug code to tasm/working/** — debug infrastructure lives in masm/working/ only

---

## Key File Locations

| What | Where |
|---|---|
| Player record layout | `tasm/working/drivers/stdply.inc` |
| All gvar_* globals | `tasm/working/core/zeliard.inc` |
| Cavern engine (fight/combat) | `tasm/working/zelres2/code/200FIGHT.asm` |
| Town engine | `tasm/working/zelres1/code/106TOWN.asm` |
| Opening cinematic | `tasm/working/zelres1/code/100OPDMO.asm` |
| Enemy AI (8 worlds) | `tasm/working/zelres3/code/301-308EAI*.asm` |
| Boss handlers | `tasm/working/zelres3/code/309-319*.asm` |
| Mechanics checklist | `tasm/Documentation/MECHANICS_TO_UNDERSTAND.md` |
| Chunk directory | `tasm/Documentation/code_chunks_overview.md` |
| Opening cinematic trace | `6_WebPort/opening_demo_flow.md` |
| MASM debug macros | `masm/working/zelres1/code/debug.inc` |
| SAR packer | `tasm/pack_tasm_sar.py` (also `masm/` copy) |
