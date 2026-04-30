# Zeliard code-chunks overview

What each code chunk in the cleaned tree actually IS.  This file is
the chunk dictionary — a quick "which chunk should I read for X?" map.
For control-flow narrative see `ARCHITECTURE.md`; for the master
investigation checklist see `MECHANICS_TO_UNDERSTAND.md`.

**Tree**: `3_Assembly/tasm/working/{core,drivers,zelres1,zelres2,zelres3}/code/*.asm`
**Build**: every chunk compiles to a BIT-PERFECT match against the
original SAR archive payload via `verify1.py <relpath>` and
`build_all.py --verify`.

---

## Boot tier — `core/` + `drivers/`

These are loaded as the EXE itself + driver overlays before any SAR
chunk is touched.  See ARCHITECTURE.md §1 for the full boot order.

| File | Bin size | Role |
|---|---:|---|
| `core/zeliad.asm` | 2,544 B | **The MZ executable.**  Parses RESOURCE.CFG, allocates memory, EXECs MTINIT.COM, saves int 08/09/60/61 vectors, loads stdply/stick/game.bin + the gfx-mode driver, installs ISRs, reprograms the 8253 timer, jumps into game.bin.  Owner of the gvar_* globals at FF00–FF7B. |
| `core/game.asm` | 1,142 B | **The main-game initialiser.**  Loads font.grp, the gfx-mode chunk, town.bin, fight.bin, select.bin, itemp.grp, magic.grp, sword.grp, the level data, and the music tracks.  Tail-jumps into fight.bin's per-frame loop. |
| `drivers/stdply.asm` | 233 B | **Player state record at game_seg:0x0000.**  29 canonical EQUs covering the player struct (DS:0x80–0xCF + 0xE6–0xE8): `town_player_col`, `fight_player_col`, `hero_gold_hi/lo`, `hero_bank_hi/lo`, `hero_almas`, `hero_HP`, `shield_HP`, char stats, `gvar_pose_idx`, etc.  No procs, only `db`/`dw` declarations. |
| `drivers/stick.asm` | 4,150 B | **Input-driver chunk.**  Hosts `isr_timer` (int 08h hook that bumps `gvar_frame_timer`), `isr_keyboard` (int 09h scancode reader), `isr_critical`, `isr_music`, plus the SAR loader stub installed at CS:0x010C.  Joystick polling lives here too. |
| `drivers/gmega.asm`, `gmcga.asm`, `gmhgc.asm`, `gmtga.asm`, `gmmcga.asm` | 3.5–8 KB each | **Per-mode menu/UI graphics drivers.**  Selected at boot from RESOURCE.CFG via `gvar_gfx_mode`.  Provide the CS:0x2000–0x204E driver-dispatch slots used during opening / title / inventory / shop UI rendering. |

---

## ZELRES1 — opening, title, town, GD/GT graphics drivers (12 code chunks)

| Chunk | File | Bin size | Role |
|---|---|---:|---|
| 0 | `100OPDMO.asm` | 13,869 B | **Opening-cinematic / demo / save-loader.**  Slideshow of `nec.grp`/`dmaou.grp`/`hime.grp`/`ttl1-3.grp` with story text from the embedded prose at file offset 0x0FF3.  ENTER skips delays via the check at routine 0x03AF.  When zeliad.exe is re-execed with a savefile, this chunk also handles the LOAD path (game.asm:218). |
| 1 | `101GDEGA.asm` | 5,508 B | **GD (game-display) driver, EGA mode.**  Tile / sprite / scroll primitives for the cavern-walking phase under EGA. |
| 2 | `102GDCGA.asm` | 7,708 B | GD driver, CGA mode (interleaved 2-plane B800h framebuffer). |
| 3 | `103GDHGC.asm` | 8,142 B | GD driver, Hercules mode. |
| 4 | `104GDTGA.asm` | 8,862 B | GD driver, Tandy mode. |
| 5 | `105GDMCA.asm` | 8,665 B | GD driver, MCGA mode. |
| 6 | `106TOWN.asm` | 7,304 B | **Town walking + building dispatch.**  Hosts `frame_update`, `walk_left/right_move`, `walk_left/right_scroll`, `walk_left/right_audio`, the per-tile interactable trigger, and the building-dispatch fan-out to the shop chunks (210-219).  Reads/writes `town_player_col` (DS:0x83), `gvar_skip_input`, `gvar_pose_idx`, `gvar_text_ofs`, plus a long `[FF1A]`-driven anim wait loop. |
| 7 | `107GTEGA.asm` | 3,920 B | **GT (game-text/inventory) driver, EGA.**  Selected when the inventory or NPC-dialog screen is drawn. |
| 8 | `108GTCGA.asm` | 4,568 B | GT driver, CGA. |
| 9 | `109GTHGC.asm` | 4,375 B | GT driver, Hercules. |
| 10 | `110GTTGA.asm` | 5,407 B | GT driver, Tandy. |
| 11 | `111GTMCA.asm` | 5,363 B | GT driver, MCGA. |

(Chunks 12-23 in zelres1 are **data**: font.bin, image_*.grp, ttl1-3.grp,
hime.grp, sprites.bin, animation tables, opening/ending music — not
listed here.  See `ndisasm/output/` for raw disassembly if needed.)

---

## ZELRES2 — fight engine, character select, GF graphics drivers, shops, ending (21 code chunks)

| Chunk | File | Bin size | Role |
|---|---|---:|---|
| 0 | `200FIGHT.asm` | 16,181 B | **THE main combat engine.**  Hosts the entity-list scan, sprite-blit pipeline, hit detection, HP/almas/gold arithmetic, scene-transition dispatch, the 27-slot fight-engine callback table at 0x6000–0x603E, and the 4-direction enemy-movement family.  Most heavily-renamed chunk in the project — see PHASE3 notes in AUDIT_TODO.  Key procs: `is_entity_known_type`, `entity_slot_write_tagged`, `world_x_to_screen_x`, `lookup_move_slot_family`, `enemy_sprite_blit`, `hero_HP_subtract`, `hero_almas_add`, `reset_combat_state`, `entity_move_{east,north,west,south}`, `compute_scroll_pos`. |
| 1 | `201SELCT.asm` | 3,631 B | **Character-select / inventory screen.**  Hosts `item_qty_count`, `item_effect_val`, `cur_magic_idx`, `key_count` field handling.  The Inventory screen the user opens with [Enter] is rendered from here. |
| 2 | `202GFEGA.asm` | 8,472 B | **GF (game-fight) driver, EGA.**  Sprite-fill / blit driver for the combat-phase framebuffer.  Macro-folded in 2026-04-30 cleanup. |
| 3 | `203GFCGA.asm` | 8,897 B | GF driver, CGA.  Most heavily macro-folded (30 inline blocks → macro calls). |
| 4 | `204GFHGC.asm` | 8,764 B | GF driver, Hercules. |
| 5 | `205GFTGA.asm` | 9,769 B | GF driver, Tandy. |
| 6 | `206GFMCA.asm` | 8,931 B | GF driver, MCGA. |
| 7 | `207MOLE.asm` | 10,538 B | **Level / world-system loader.**  Loaded at game_seg+0x3000 by game.asm:296.  Handles per-area init: tileset selection, map data, music tracks per area, level-state setup. |
| 8 | `208YMPD.asm` | 9,577 B | **Sub-area / map-handler chunk** (zelres2 ch 8).  Loaded by 207MOLE.  Per-area tile-attribute and physics tables. |
| 9 | `209CKPD.asm` | 8,105 B | **Boss-state / cavern-end-card chunk.**  Boss-state machine glue (loaded into game segment for boss arenas). |
| 10 | `210KINGP.asm` | 1,958 B | **King NPC dialog (story progression).**  Tumba-castle King Felishika dialog — gates Holy-Spirit story progression. |
| 11 | `211OMOYP.asm` | 599 B | **Tiny dialog chunk** (Pope / Bishop / similar — the "give-the-quest" NPC). |
| 12 | `212ARMRP.asm` | 7,243 B | **Weapons-master shop.**  Sword + shield purchase, shield repair.  Calls `check_gold_sufficient` (probe-tested). |
| 13 | `213BANKP.asm` | 3,388 B | **Bank shop.**  Deposit/withdraw via `script_take_item` / `script_give_item`.  24-bit `hero_bank_hi/lo` add+adc probe-tested. |
| 14 | `214CHURP.asm` | 1,002 B | **Church (resurrection NPC).** |
| 15 | `215DRUGP.asm` | 4,650 B | **Magic-brewer shop.**  8 magic items (Ken'ko Potion, Juu-en Fruit, Elixir of Kashi, Chikara Powder, Magia Stone, Holy Water of Acero, Sabre Oil, Kioku Feather). |
| 16 | `216INNAP.asm` | 1,300 B | **Inn (rest, HP restore).**  Per-town rate documented in TOWNS_AND_NPCS.md. |
| 17 | `217KENJP.asm` | 6,977 B | **Sage (level-up + spell grant + save trigger).**  Reads char_exp_cap to gate level-up; writes save state. |
| 18 | `236CMAP.asm` | 2,241 B | **Map-data chunk** (combat map / arena layout — Sourcer disasm exists). |
| 19 | `238STMP.asm` | (data) | **Map-data chunk.** |
| 20 | `239BSMP.asm` | (data) | **Boss-map data.** |
| 21 | `250ENDMO.asm` | 8,687 B | **Ending cinematic / endmo (end-movie).**  Final cutscene playback after Jashiin defeat. |

---

## ZELRES3 — enemy AI + boss AI (20 code chunks)

These are the per-enemy / per-boss handler chunks loaded into the game
segment when the player enters a cavern that uses them.  All extend
the fight-engine via the `fight_cb_*` callback table at 0x6000–0x603E
(see `zr3com.inc`).

| Chunk | File | Bin size | Role |
|---|---|---:|---|
| 0 | `300ROKAD.asm` | 1,452 B | **ROKAD enemy** — basic test enemy; small handler. |
| 1–8 | `301EAI1.asm`..`308EAI8.asm` | 1.8–2.7 KB each | **Generic enemy-AI handlers EAI1..EAI8.**  Eight reusable AI shapes that 200FIGHT instances against the per-area enemy_id_table.  Each contains ~6 entity-handler entries dispatched via the move-slot family lookup. |
| 9 | `309CRAB.asm` | 2,034 B | **Boss: Cangrejo** (Crab — Muralla / Malicia boss).  Per-Playthrough §2.3.1. |
| 10 | `310TAKO.asm` | 2,726 B | **Boss: Pulpo** (Octopus — Satono / Peligro boss; "tako" = octopus). |
| 11 | `311TORI.asm` | 2,024 B | **Boss: Pollo** (Bird — Bosque / Madera boss; "tori" = bird).  Most heavily-renamed boss chunk.  Procs: `tori_render_sprite_row`, `tori_swoop_tick`, `tori_apply_damage`, `tori_hp_dec_if_ge_D`, etc. |
| 12 | `312ZELA.asm` | 1,580 B | **Boss: Agar** (Helada / Escarcha boss; "zela" = jelly?). |
| 13 | `313MEDA.asm` | 2,188 B | **Boss: Vista** (Tumba / Corroer boss — the eyeball boss; "meda" = eyeball/medusa). |
| 14 | `314LEGA.asm` | 2,077 B | **Boss: Tarso** (Dorado / Tesoro boss; "lega" = leg/tarsal segment).  Has a stack-frame coincidence with FF3C documented in `gvar_unk_ff3c`. |
| 15 | `315ZEL2.asm` | 1,567 B | **Boss: Paguro** (Hermit Crab — Llama / Caliente; "zel2" = second jelly variant?).  Per-Playthrough this is a non-Tear boss who gives the Elf Crest. |
| 16 | `316DRGN.asm` | 2,989 B | **Boss: Dragon** (Pureza / Absor; literally `dragon`). |
| 17 | `317AKMA.asm` | 2,814 B | **Boss: Alguien** (penultimate boss; "akma" = demon/devil — Japanese 悪魔). |
| 18 | `318MAO1.asm` | 1,441 B | **Final-boss arena part 1: Jashiin** (first phase; "mao" = demon king — Japanese 魔王). |
| 19 | `319MAO2.asm` | 3,187 B | **Final-boss arena part 2: Jashiin** (second/transformed phase). |

(Chunks 20+ in zelres3 are **data**: per-enemy sprite sheets, the
ENPx pattern tables, music chunks MUSx, the per-area MPPx maps.)

---

## How chunks are reached at runtime

```
                              ┌──────────────────────────────────────┐
zeliad.exe ─────► game.bin ──►│  Title screen (100OPDMO + ttl1-3)    │
                              │           │                          │
                              │           ▼                          │
                              │   New / Load select                  │
                              │           │                          │
                              │   ┌───────┴────────┐                 │
                              │   ▼                ▼                 │
                              │ 106TOWN ◄──────► 200FIGHT (cavern)   │
                              │   │ │             │                  │
                              │   │ │             ▼                  │
                              │   │ │           Enemy AI: 30x EAIN   │
                              │   │ │             │                  │
                              │   │ │             ▼                  │
                              │   │ │           Boss arena:          │
                              │   │ │           309CRAB / 310TAKO /  │
                              │   │ │           311TORI / 312ZELA /  │
                              │   │ │           313MEDA / 314LEGA /  │
                              │   │ │           315ZEL2 / 316DRGN /  │
                              │   │ │           317AKMA / 318MAO1 /  │
                              │   │ │           319MAO2              │
                              │   │ │             │                  │
                              │   │ │             ▼                  │
                              │   │ ▼           250ENDMO (after final│
                              │   │  Shop chunks (Felicia rescue)    │
                              │   │  210-219                         │
                              │   ▼                                  │
                              │ Inventory screen (201SELCT)          │
                              └──────────────────────────────────────┘
```

Every chunk except 100OPDMO and 250ENDMO is loaded INTO an existing
game segment via `sar_loader_fn` at CS:0x010C — the loader fixes up
their internal jump tables and they execute in-place.  See
ARCHITECTURE.md §3 for loader call ABI.

---

## Cross-references

- **ARCHITECTURE.md** — full boot trace + per-frame loop + dispatch slots
- **MECHANICS_TO_UNDERSTAND.md** — what each chunk's mechanics still need investigation
- **`zr1com.inc` / `zr2com.inc` / `zr3com.inc`** — shared EQUs across each archive's chunks
- **`stdply.inc`** — canonical player-record field definitions
- **`functest/INDEX.md`** — runtime-test catalog (which chunks have probe tests)

_Last updated 2026-04-30, after the cleanup pass that removed the
46 per-chunk walkthrough files (their content was either obsoleted by
Phase 2-3 renames or now lives directly in the chunks' .asm headers
as canonical EQU + comment blocks).  The .asm source itself is now
the single source of truth for chunk semantics._
