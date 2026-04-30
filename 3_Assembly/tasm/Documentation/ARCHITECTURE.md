# Zeliard runtime architecture

Counterpart to `code_chunks_overview.md` (which enumerates each chunk's
contents).  This document is the **control-flow narrative**: how
zeliad.exe boots, how chunks are loaded into memory, how the per-frame
ISR + main loop dispatch work, and how cross-chunk callbacks are wired.

Reading order: §1 boot → §2 memory layout → §3 SAR loader → §4 frame
loop → §5 dispatch slots → §6 phase walkthrough.

---

## 1. Boot sequence — `zeliad.exe` to first chunk

```
DOS COMMAND.COM
  └─> zeliad.exe  (MZ executable, see core/zeliad.asm)
        ├─ DOS-version check (require >= 2.0)
        ├─ Parse RESOURCE.CFG: graphics mode, music driver, joystick
        ├─ DOS allocate ~256 KB → game_entry_seg
        ├─ EXEC MTINIT.COM (music device init)
        ├─ Save original int 08/09/60/61 vectors
        ├─ Initialize gvar_* state at game_seg:0xFFxx
        ├─ Load driver files in order:
        │    1. stdply.bin  →  game_entry_seg:0x0000   (player config)
        │    2. stick.bin   →  game_entry_seg:0x0100   (input/timer ISRs)
        │    3. game.bin    →  game_entry_seg:0xA000   (main engine)
        │    4. gm{ega,cga,hgc,tga,mcga}.bin  →  driver_offset_table[mode]
        │    5. music driver  →  game_entry_seg+0xFF0:0
        │    6. joystick driver  →  same +0xFF0 segment
        ├─ Install ISRs (pulled from stick.bin):
        │    int 08h → isr_timer
        │    int 09h → isr_keyboard
        │    int 24h → isr_critical
        │    int 60h → isr_timer (game-services slot)
        │    int 61h → isr_music
        ├─ Reprogram 8253 timer 0 to ~65.5 Hz (0x13B1 = 5041 ticks)
        └─ jmp dword ptr cs:game_entry_ofs   ← enters game.bin
```

Once control reaches `game.bin`, the next layer begins:

```
game.bin (core/game.asm) at game_seg:0xA000
  ├─ AX = 0 (new game) or 0xFFFF (load save) — passed by zeliad.exe
  ├─ Load font.grp (zelres1 ch 13) compressed → CS:0xF500
  ├─ Fix up font.grp's loaded jump table (3 pointers)
  ├─ Call CS:[120h]  (font.grp init — also installs sar_loader_fn at 0x10C)
  ├─ Zero ~16 game-state flags
  ├─ Load gfx-mode driver (gd*.bin) from zelres3 → CS:0x3000
  ├─ Call CS:0x3000  (graphics-driver init)
  ├─ if save_mode == load:  jmp opdemo (zelres3) → save loader
  ├─ if save_mode == new:
  │    ├─ Load town.bin (zelres1) → CS:0x6000
  │    ├─ Load tile-mode gfx → ES:0x9000  (segment+0x2000)
  │    ├─ Load fight.bin (zelres2 ch1) → CS:0xC000
  │    ├─ Load select.bin (zelres2 ch2) → +0x1000 segment, 0xC000
  │    ├─ Load itemp.grp (compressed)   → +0x1000 segment, 0xE200
  │    ├─ Fix up enemy-system jump table (7 pointers)
  │    ├─ Load magic.grp / sword.grp (compressed) into +0x2000 segment
  │    ├─ Fix up input-system jump table (3 pointers)
  │    ├─ Load main level data (function 4 of sar_loader_fn)
  │    ├─ Load mole.bin (level system) → +0x3000 segment, 0x0000
  │    ├─ Call game_init_fn  (level setup; far call into +0x3000 seg)
  │    ├─ load_music_tracks — installs music tracks via gfx_call_a/b/c
  │    ├─ Load level tileset + level map
  │    └─ jmp ds:loaded_code_b_fn   ← enters fight.bin per-frame loop
```

The "fight.bin" entry is the main game loop — Zeliard runs from here
for the rest of the session, swapping in/out other chunks (town, shop,
enemy AI) via `sar_loader_fn` as the player navigates between scenes.

---

## 2. Memory layout

Three segment tiers, plus DOS / hardware:

```
                           ┌──────────────────────────────────────────┐
  +0x000:0000 (DOS PSP)    │                                          │
                           │     (DOS / TSRs / disk buffers)          │
                           │                                          │
  game_entry_seg:0000      ├──────────────────────────────────────────┤
                           │  stdply.bin   (player config)            │
  game_entry_seg:0100      │  stick.bin   (input/timer ISRs, 0x010C   │
                           │               sar_loader_fn after font   │
                           │               init)                      │
  game_entry_seg:1100      │  stdply gfx fn entry (1100h)             │
  game_entry_seg:3000      │  gd*.bin       (gfx-mode driver, init    │
                           │               at offset 0)               │
  game_entry_seg:6000      │  town.bin / fight.bin / boss chunks      │
                           │  swapped here as game phase changes      │
  game_entry_seg:A000      │  game.bin    (main engine entry)         │
  game_entry_seg:C000      │  fight.bin   (combat engine, 200FIGHT)   │
  game_entry_seg:F500      │  font.grp    (loaded by game.bin init)   │
                           ├──────────────────────────────────────────┤
  gvar_game_seg:0000       │ (= game_entry_seg + 0x1000, the "data    │
                           │  segment" — DS for most chunks)          │
  gvar_game_seg:8000       │   sprite_obj_tbl, enemy_id_table, etc.   │
  gvar_game_seg:A000       │   game-data tables, callbacks, dispatch  │
  gvar_game_seg:C000       │   fight-engine state, level data         │
  gvar_game_seg:E000       │   enemy_data_buf (EB80h), buffers        │
  gvar_game_seg:FF00       │   gvar_*  (game-state flags 0xFF00..7B)  │
                           ├──────────────────────────────────────────┤
  +0x0FF0 segment          │   music driver / joystick driver         │
  vga_seg = 0xA000         │   VGA framebuffer (320x200, mode 13h)    │
                           └──────────────────────────────────────────┘
```

Two distinct "0xC000" addresses cause confusion:
- **CS:0xC000** in fight.bin's namespace is the on-screen tile-data
  region (`world_tile_base` and the table that follows).
- **DS:0xC000** is the same physical memory as CS:0xC000 since CS=DS=
  game_entry_seg for most code; this is where loaded chunks dump their
  data.  Reads via `ds:state_byte_C017` (now `world_tile_base`) hit
  the first word of that table.

The `sar_loader_fn` at `cs:0x010C` is **not** part of the original
zeliad.exe — it's installed at runtime by font.grp's init code.  Until
font.grp loads, no chunk swap is possible.

---

## 3. SAR loader mechanics

`sar_loader_fn` (CS:0x010C) is the runtime workhorse for chunk swaps.
Calling convention:

```
input:  AL = function code
        SI = ptr to chunk reference record (for AL=2/3)
        ES:DI = destination (for AL=2/3)
        AH = level/area number (for AL=4/1)
output: chunk loaded, data installed at destination
```

Function codes (from CALL sites + comments in game.asm):
- `AL=1` Load level chunks (uses AH = area number)
- `AL=2` Load chunk + decompress via `fill_buffer` decoder
- `AL=3` Load chunk RAW (no decompression — for code chunks)
- `AL=4` Load main level data via [92h] index

Chunk reference record (2 bytes at `chunk_ref_*`):
- Byte 0: archive index (0=zelres1, 1=zelres2, 2=zelres3)
- Byte 1: chunk ID (1-indexed within the archive)

The loader seeks to `(chunk_id - 1) * 4` in the archive's directory,
reads the entry, and either copies the data raw or runs it through
`fill_buffer` (the format-3/6/7 RLE decoder, see CLAUDE.md notes).

After load, multiple chunks need their internal jump tables FIXED UP
(self-relocating offset additions) before they can be called:

```asm
add es:[di],   di           ; Each loaded entry is a relative offset;
add es:[di+2], di           ; add the load offset to make it absolute.
add es:[di+4], di
```

This pattern appears 3 times in game.bin (font init: 3 entries; enemy
system: 7 entries; input system: 3 entries).

---

## 4. Per-frame loop & ISRs

### Hardware timer: ~65.5 Hz

zeliad.exe reprograms 8253 timer-0 to count 0x13B1 = 5041 PIT cycles
per tick.  At 1.193 MHz PIT clock that's ~236.6 Hz — but the original
timer rate was 18.2 Hz, and the gameplay simulation runs at the
DEFAULT 18.2 Hz.  The 65.5 Hz value here suggests the 5041 figure
sub-divides further inside isr_timer (in stick.bin) before bumping
gvar_frame_timer.

### isr_timer (in stick.bin, hooked at int 08h)

```
isr_timer:
   inc cs:gvar_frame_timer    ; the 18.2 Hz tick the game samples
   ... (other counters)
   jmp dword ptr cs:gvar_old_int08_ofs   ; chain to original handler
```

The game-side main loop reads `cs:gvar_frame_timer` to pace per-frame
work.  Combat ticks are gated on bit checks of this byte.

### isr_keyboard / isr_music

`isr_keyboard` (int 09h) updates `gvar_key_state` / `gvar_last_key` /
`gvar_key_pressed`; the game reads these in the input handler.

`isr_music` (int 61h) is the music tick — drives the music driver's
note advance, palette flicker (via `gvar_palette_flag`), and the
fight engine's `gvar_combat_audio_latch` gate at FF47.

### Main-loop dispatcher

The frame loop is implicit in fight.bin's `loaded_code_b_fn` (offset
0x6002 in the loaded chunk's segment).  It cycles:

1. Wait for the next gvar_frame_timer tick
2. Call gfx_fn_render_a / _b (CS:0x2026 / 0x2028)
3. Process entity list (entity_data_buf at EB80, 13 bytes/entry,
   0xFF terminator)
4. For each active entity:
   - `is_entity_known_type` (gates further processing)
   - If alive: dispatch via `entity_fn_tbl_*` based on entity ID
   - Move via `entity_move_{east,north,west,south}` (col/row +- 1)
   - Render via `enemy_sprite_blit`
5. Process active sprites (`process_active_sprites`)
6. Render HUD (HP bar, almas, gold)
7. Read input (`int 61h`-driven joystick or `gvar_key_pressed`)
8. Update player position / animation state
9. Commit frame (CS:0x2016 = drv_frame_commit)
10. Loop

Step (3) is gated by `gvar_skip_input` (FF1D); if set, the entity
update is skipped and the scene-change code at the bottom of the
loop runs (loading the next chunk via `sar_loader_fn`).

---

## 5. Cross-chunk dispatch slots

Three families of indirect calls glue the chunks together.  Each
slot is a CS-relative far pointer; the loaded driver chunk fills it
in during init, and game logic far-calls through it.

### 0x010C — SAR loader (1 slot)

Installed by font.grp init.  The single most-important indirection
in the game.

### 0x2000–0x204E — Graphics driver dispatch (~30 slots)

Filled in by the graphics-mode driver (gm{ega,cga,hgc,tga,mcga}.bin).
Each slot holds the driver-specific pixel-mode implementation.  The
SAME slot points at DIFFERENT functions depending on which driver is
loaded.  Per-chunk source aliases (e.g. `gfx_draw_char_fn` in
106TOWN, `drv_render_char` in zr2com.inc) reflect each chunk's
LOCAL meaning, not synonyms.

| Slot | Common-family canonical | Note |
|---:|---|---|
| 0x2000 | `drv_fill_rect` | fill rectangle (fn 0) |
| 0x2002 | `drv_screen_init_a` | screen/work-area init |
| 0x2008 | `drv_palette_push` | palette push/refresh |
| 0x2010 | `drv_load_msg_header` | load/draw message header |
| 0x2012 | `drv_screen_init_b` | screen init B |
| 0x2016 | `drv_frame_commit` | commit/wait refresh |
| 0x2018 | `drv_anim_step` | advance animation/palette |
| 0x2022 | `drv_render_char` (multi) | text/dialog/screen-setup |
| 0x2026 | (multi) | text-layout/blit-on/draw |
| 0x2028 | (multi) | text-layout-b/blit-off/restore |
| 0x202A | (multi) | draw-string/blit-render/clear |
| 0x2040 | `drv_return_to_caller` | exit/far return |
| 0x2044 | `drv_ds_copy` | DS-segment copy |
| 0x3016 | `drv_draw_glyph` | glyph/tile draw |

### 0x6000–0x603E — Fight engine dispatch (`fight_cb_*`)

Loaded into fight.bin's segment when fight.bin is swapped in.  ~27
distinct slots used by enemy-AI chunks (zelres3 300-319) to call
back into the fight engine without knowing fight.bin's actual
addresses.  See zr3com.inc `fight_cb_prep`, `fight_cb_step_neg`,
`fight_cb_anim_step`, etc.

### 0x6004–0x600C — Town/shop script-step dispatch

Same slot range, but in town.bin's segment when town is loaded:
`script_step`, `script_format_num`, `script_display_page`,
`script_take_item`, `script_give_item`.  The shops (210-219) all
call into these.

---

## 6. Phase walkthrough — town to fight transition

```
[Town walking]
  ├─ Per-frame: town.bin's frame_update reads input, scrolls map,
  │             draws character, polls for interactable tiles
  ├─ Trigger: player walks into a fight-spawn tile or scripted event
  ├─ Town scrolls in `gvar_skip_input` (FF1D) = 0xFF (skip-flag)
  ├─ Town calls scene_trans_request (FFE6) write
  └─ Returns to its outer dispatcher

[Transition]
  ├─ Outer dispatcher checks scene_trans_request != 0
  ├─ Calls reset_combat_state (zeroes 11 flags + 4 sentinels in 200FIGHT)
  ├─ LOAD_CHUNK fight.bin / fight-tileset / level map via sar_loader_fn
  └─ jmp into fight.bin's entry

[Fight active]
  ├─ Per-frame loop: §4 above
  ├─ Entity tick: tick_decrement_enemy_counters / tick_increment_*
  ├─ Player input: combat_step_dispatch reads joystick, sets FF45/46/47
  ├─ Boss handling: prep_boss_dirty_blit, mao1/mao2 specific procs
  ├─ Damage: hero_HP_subtract / hero_almas_add etc.
  ├─ Win/loss: gvar_completion (FF30) set; gameover_outer_tick advances
  └─ Eventually reset_combat_state runs and we return to town

[Save / load]
  ├─ Triggered by menu (kingp / inn)
  ├─ Save: gvar_save_filename → game-save MZ header writer → DOS write
  ├─ Load: zeliad.exe re-exec'd with savefile arg in command line
  └─ Save state covers HP, gold, almas, bank, key_count, area, etc.
```

---

## 7. What this document does NOT cover

- **Pixel-level blit semantics** for any specific gfx mode driver —
  see `gm{ega,cga,hgc,tga,mcga}_walkthrough.md`.
- **Music tracker mechanics** — int 61h handler chain, note advance,
  PCM playback.  Out of scope until someone reverse-engineers the
  music driver internals.
- **Per-enemy AI** — the 309CRAB through 319MAO2 chunks each have
  their own AI loop; documented (where built) in code_chunks_overview.md.
- **Save-file format** — the .SAV layout, what's in each byte.
  Decodable from the save-load routine in opdemo (zelres3 chunk).

These are independent investigations.  This document gives you the
control-flow scaffolding to know WHICH file to look in for any
given subsystem.

---

_Generated 2026-04-30 from boot-trace through `core/zeliad.asm`,
`core/game.asm`, and the dispatch tables in `zr1com.inc`/`zr2com.inc`/
`zr3com.inc`.  Refresh after any cross-chunk EQU changes._
