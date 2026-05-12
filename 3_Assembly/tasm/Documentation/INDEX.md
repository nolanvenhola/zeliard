# Zeliard reverse-engineering documentation index

Subsystem → topic-doc map.  Use this as the entry point for any
mechanic / code area you're investigating.

The **master checklist** lives in `MECHANICS_TO_UNDERSTAND.md`
(229/229 mechanics ✓ fully traced as of 2026-05-10).  Topic docs
below provide the deep walkthroughs for each subsystem.

---

## Architecture & boot

| Doc | What it covers |
|---|---|
| `ARCHITECTURE.md` | Boot order, segment layout, SAR loader, INT 60h services, chunk dispatch, main-loop structure |
| `BOOT_FLOW.md` | Runtime-verified `zeliad.exe` → `game.bin` → `fight.bin` handoff, with DOSBox-confirmed register/memory state at each step |
| `code_chunks_overview.md` | "Which chunk should I read for X?" — chunk dictionary across core/drivers/zelres1/2/3 |
| `SAR_DIRECTORY.md` | Canonical file_id → filename map for all 3 SARs (cross-referenced from `c:\projects\zeliard-brox\tools\MDTViewer\sar_reader.py`); map-id lookup tables for dungeon + town doors |

## Player + cavern mechanics

| Doc | What it covers |
|---|---|
| `PLAYER_PHYSICS.md` | Joystick→state dispatch, jump/fall/ladder/platform-raise, ice slide (Helada), tile collision, post-correction methodology notes |
| `TILE_PHYSICS.md` | Tile-byte format, `tile_type_map[16]` per-area damage, force-vulnerable bytes, per-area gate procs (Helada/Pureza accessories), one-way wall via lookup_move_slot_family |
| `TILE_PHYSICS.md` + `MdtViewer/decoder.py` | MDT format (cavern + town) — fully decoded in 4_Resources tool |

## Combat / enemies / bosses

| Doc | What it covers |
|---|---|
| `BOSS_AI.md` | Boss-arena architecture, 16-byte enemy slot record, 200FIGHT ↔ boss-chunk dispatch slot pattern, TAKO worked example |
| `BOSS_FSM_GRAPHS.md` | Per-boss state-variable inventory for CRAB/TORI/ZELA/MEDA/LEGA/ZEL2/DRGN/AKMA/MAO1/MAO2 (9 bosses) + common scan_slot_loop pattern |
| `MONSTER_TYPES.md` | Type-byte → enemy-name mapping per cavern level (tentative, slot-index based); chart of which type bytes appear in which MDT level |
| `GFX_PIPELINE.md` §3 | Sprite pixel format + `mca_sprite_blit` shift-mask decode (8×8 sprites, 48 B each, 6-bit packed) |

## Graphics / rendering

| Doc | What it covers |
|---|---|
| `GFX_PIPELINE.md` | Full per-frame rendering chain in MCGA mode, sprite/tile/HUD pixel formats, 14-slot dispatch table, port implications |
| `OPENING_CINEMATIC.md` | Opening slideshow + title-logo decoder (4-plane interleave) + per-driver palette setup |

## Inventory / items / spells

| Doc | What it covers |
|---|---|
| `INVENTORY_SYSTEM.md` | 201SELCT panels (weapons / spells / items), 8 item-use handlers, equip flow.  **TCRF-corrected name table at top.** |
| `SAVE_FORMAT.md` | 256-byte .USR player record byte map (TCRF authoritative), DOS 3Ch/40h/3Eh write path |

## NPCs / shops / scripts

| Doc | What it covers |
|---|---|
| `SCRIPT_INTERPRETER.md` | NPC bytecode VM at `cs:[6004]`, opcode dispatch, dialog services (`script_take_item`, `script_give_item`, `script_display_page`, `menu_show_list`, `menu_init`) |
| `working/TOWN_NPCS_DUMP.md` | Auto-generated: per-NPC dialog text for all 10 towns (via `dump_town_npcs.py`) |

## Audio

| Doc | What it covers |
|---|---|
| `MUSIC_SYSTEM.md` | mscmt.drv MT-32 driver, INT 60h music service (AX=3 CL=0xFF pause / CL=0 resume), gvar_sound_flag mute toggle |

## Save / load

| Doc | What it covers |
|---|---|
| `SAVE_FORMAT.md` | 256-byte .USR layout (TCRF authoritative byte map), Sage save trigger via DOS 3Ch/40h/3Eh |

## Audit / verification reports (auto-regenerated)

| Doc | Source | What it covers |
|---|---|---|
| `working/CAVERN_INVENTORY.md` | `python dump_cavern_inventory.py` | **Per-cavern enemies/items/doors/platforms** for all 31 MDTs — uses brox decode_mdt() after stripping 4B SAR prefix |
| `working/TOWN_NPCS_DUMP.md` | `python dump_town_npcs.py` | Per-town NPC roster + dialog text + unreferenced sign strings for all 10 towns |
| `working/SHARED_BUFFER_AUDIT.md` | `python shared_buffer_audit.py` | Cross-chunk EQU aliasing — finds Sabre-Oil-style hidden consumers |
| `working/MISSING_EQUS.md` | `python find_missing_equs.py` | Raw-hex memory operands without symbolic names (currently 0) |
| `working/NAME_CLARITY_AUDIT.md` | `python name_clarity_audit.py` | Procs failing the verb+noun naming rule |
| `working/SECTION_INVENTORY.md` | `python audit_section.py` | Per-section walkthrough audit |
| `working/SYMBOL_INDEX.md` | `python generate_symbol_index.py` | All EQUs + procs across the working tree, linkable |
| `working/DATA_PATTERN_VERIFY.md` | `python data_pattern_verify.py` | Data-pattern annotations validation |
| `working/DRIVER_SIGNATURE_VERIFY.md` | `python driver_signature_verify.py` | Per-driver dispatch-slot signature check |
| `working/NAME_PATTERN_VERIFY.md` | `python name_pattern_verify.py` | Name-pattern structural verification |
| `working/PAIR_CONSISTENCY_REPORT.md` | `python check_pair_consistency.py` | EAI ↔ Sprite-pair consistency |

## Planning / status

| Doc | What it covers |
|---|---|
| `MECHANICS_TO_UNDERSTAND.md` | **Master tracker** — 229 mechanics, status (all ✓ as of 2026-05-10), per-row code citations |
| `REMAINING_MECHANICS_PLAN.md` | Historical: Phase 1-10 plan that drove the closeout pass |

## Game-data references (in `4_Resources/`)

| Doc | What it covers |
|---|---|
| `4_Resources/GameData/GAME_DATA_REFERENCE.md` | Game-data tables (sword names, item effects, enemy stats, etc.) |
| `4_Resources/Documentation/` | Original game manual + playthrough notes (PDF) |
| `4_Resources/MdtViewer/` | Python+Avalonia tool to inspect .mdt cavern/town maps |

## Sibling-repo cross-references (zeliard-brox)

The `c:\projects\zeliard-brox` repo (web-port project) has tools we've
cross-referenced to validate / extend our docs:

| Brox path | What it provides | Our doc |
|---|---|---|
| `tools/MDTViewer/decoder.py` | Full `unpack()` for all 8 fill_buffer methods; map-id tables | ported into `2_SAR/Tools/decompress_sar.py` |
| `tools/MDTViewer/sar_reader.py` | Authoritative `file_id → filename` map for all 3 SARs | `SAR_DIRECTORY.md` |
| `tools/MDTViewer/constants.py` | MCGA palette (64 entries) + dungeon/town map-id lookups | `GFX_PIPELINE.md` §8 + `SAR_DIRECTORY.md` |
| `tools/MDTViewer/tile_graphics.py` | Pattern-tile decoder + transparency conventions | `GFX_PIPELINE.md` §5b |
| `tools/GrpViewer/grp_viewer.py` | 13-mode GRP-file descriptor + per-cavern mppN.grp layouts + sword color tiers | `GFX_PIPELINE.md` §5b |
| `tools/SFXRipper/` | OPL/AdLib sound-effect ripper | (not yet integrated; MUSIC_SYSTEM.md TBD extension) |
| `tools/SpriteEditor/` | Sprite-edit tool (similar to MdtViewer) | n/a |

---

## Reading order for new contributors

1. **`MECHANICS_TO_UNDERSTAND.md`** — get a sense of what's documented
2. **`ARCHITECTURE.md`** — boot order + segment layout
3. **`code_chunks_overview.md`** — which chunk does what
4. **`PLAYER_PHYSICS.md` + `TILE_PHYSICS.md`** — how the cavern game loop works
5. **`BOSS_AI.md`** — combat architecture (TAKO worked example)
6. **`GFX_PIPELINE.md`** — rendering chain (port-relevant)
7. **`SAVE_FORMAT.md`** — persistent-state byte map
8. **Pick your subsystem** — drop into the matching topic doc

---

## Methodology lessons captured to memory

In `~/.claude/projects/c--Projects-Zeliard/memory/`:
- `feedback_per_area_gate_procs.md` — per-area effects are gate-proc-driven, not table-driven
- `feedback_shared_buffer_aliases.md` — same DS addr can have different EQU names per chunk; grep by literal hex
- `feedback_mechanics_doc_workflow.md` — every ✓ promotion must be backed by asm trace
- `feedback_naming_rule_verb_noun.md` — every proc must be verb+noun
- `feedback_dos83_filenames.md`, `feedback_dosbox_mcp_broken.md`, etc.

Plus reference notes:
- `reference_zeliard_save_format_tcrf.md` — TCRF authoritative save-format byte map
- `reference_save_format_naming_unified.md` — 2026-05-05 reconciliation
- `reference_keyboard_scan_code_mapping.md` — F1=skip, F2=music, F7=restore, F9=speed
- `reference_mechanics_doc_progress.md` — coverage snapshot
