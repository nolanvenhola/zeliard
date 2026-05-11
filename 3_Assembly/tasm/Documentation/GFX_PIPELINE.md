# Zeliard graphics pipeline (MCGA reference)

Comprehensive walkthrough of the per-frame rendering chain in
gameplay (200FIGHT.asm + 206GFMCA.asm).  MCGA is the canonical
reference because it's the simplest path (chunky 1-byte-per-pixel
VGA mode 13h, no bit-planes); the other 4 drivers (EGA/CGA/HGC/TGA)
implement the same dispatch slots with mode-specific bit-plane
unpacking.

For port targets, MCGA is the most direct mapping — every dispatch
slot's MCGA implementation is a pure 320×200 chunky-pixel write to
the VGA framebuffer at 0xA000.

---

## 1. Architecture overview

```
┌─────────────────────────────────────────────────────────────────┐
│  200FIGHT.asm (per-frame logic)                                 │
│   ├─ fill_hud_buf_with_FD       — clear HUD buffer              │
│   ├─ render_entity_list_to_hud  — write enemy markers           │
│   ├─ mark_player_pos_on_hud     — write player marker (0xFF)    │
│   ├─ process_active_sprites     — walk 4-slot sprite_work_buf   │
│   │   └─ prep_dirty_blit        — extract coords from slot      │
│   │       └─ enemy_sprite_blit                                  │
│   │           └─ jmp cs:gfx_fn_78 ──┐                           │
│   ├─ scroll updates                  │                          │
│   └─ gfx_fn_render_tile (slot)       │  (per-mode dispatch)     │
└──────────────────────────────────────┼──────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────┐
│  206GFMCA.asm (MCGA driver — resident at game_seg:0x9000)       │
│   ├─ mca_sprite_blit            ← gfx_fn_78 target              │
│   ├─ hero_sprite_col_blit       ← gfx_fn_player_scroll target   │
│   ├─ draw_ui_tiles              ← gfx_fn_hud_draw target        │
│   ├─ bg_tile_blit               ← per-cell background blit      │
│   ├─ mca_sprite_render_solid    ← no-blend variant              │
│   ├─ mca_sprite_render_xor      ← XOR-blend variant (transparency)│
│   └─ writes → ES:DI = 0xA000:vga_offset                         │
└─────────────────────────────────────────────────────────────────┘
                                       │
                                       ▼
                          VGA framebuffer 0xA000:0
                          (320×200 chunky 1 byte/pixel,
                           palette set per scene via DAC ports)
```

---

## 2. Buffer map

| Address | Name | Size | Purpose |
|---:|---|---:|---|
| `game_seg:0x4000` | tile_pixel_base | ~5 KB | 8×8 tile graphics, 16 bytes/tile (4 bpp packed) |
| `game_seg:0x8000` | enemy_id_table | 0x80 | Per-area 24-slot enemy roster (loaded per cavern) |
| `game_seg:0x8030` | sprite_src_base | ~12 KB | Per-entity 8×8 sprite tiles, 48 bytes/sprite (6-bit packed) |
| `game_seg:0x9000` | (driver resident) | 5-8 KB | The active gf*.bin driver lives here |
| `game_seg:0xA000` | sprite_obj_tbl | varies | Per-entity attribute records (16 B each) |
| `game_seg:0xC000` | world_state_base | 0x1000 | Cavern state + .MDT data |
| `game_seg:0xC010` | sprite_attr_base | varies | Per-sprite attribute records (16 B each) |
| `game_seg:0xE000` | scroll_buf | 0x900 | Composed scroll/world bitmap |
| `game_seg:0xEB60` | sprite_work_buf | 28 B | 4 active sprite-job slots (7 B each) — shared with 201SELCT's `anim_spr_tbl` for Sabre Oil aura |
| `game_seg:0xEB80` | enemy_data_buf | 0x220 | 16-byte enemy slot records |
| `game_seg:0xED20` | enemy_data_ext | varies | Enemy data extension (per-boss alias: `sprite_xlat_tbl`) |
| `CS:0xE900` | hud_buf | 0x214 (532) | HUD mini-map: 28 col × 19 row × 1 byte/cell |
| `CS:0xE921` | hud_enemy_area | (inside hud_buf) | Enemy-row sub-region (18 bytes wide) |
| `CS:0xE939` | hud_player_area | (inside hud_buf) | Player-row sub-region (26 bytes wide) |

---

## 3. Sprite pixel formats

### 3a — 8×8 sprite tile (mca_sprite_blit input)

48 bytes per sprite, stored at `sprite_src_base + (sprite_id-1) * 0x30`.

Each sprite is 8 rows × 6 source bytes / row × 8 rows = 48 bytes.
Each row is read as 2 word-pairs.  Each word-pair (3 source bytes)
produces 4 destination pixels via bit-extraction:

```
  src word    src byte                          dst pixels (4×8 bits)
   ┌────────┐ ┌────────┐                       ┌──┬──┬──┬──┐
   │ DX     │ │ AL=BL  │ ──────decode───────►  │P0│P1│P2│P3│
   └────────┘ └────────┘                       └──┴──┴──┴──┘
       │            │
       │            └─ AL & 0x3F → P3  (low 6 bits)
       │            └─ BX <<= 2; BH & 0x3F → P2
       │
       ├─ DX >>= 2; DH → P0
       └─ DL >>= 2; DL → P1
```

Each pixel is a 6-bit palette index (& 0x3F mask), written directly
to the VGA framebuffer (chunky pixels).

206GFMCA.asm:485 (`mca_sprite_blit`).  The same decoder body appears
inline at 206GFMCA.asm:1104 (`mca_sprite_render_solid`).

**Sprite cache** (`sprite_cache_tbl`): on first blit of sprite_id N,
caches the VGA write position; on subsequent blits, copies VGA→VGA
from cache instead of re-decoding source bytes.  Big win for
repeating sprites (e.g. animation frames replaying).

### 3b — Hero/enemy multi-cell sprite (hero_sprite_col_blit input)

Hero is 3×3 = 9 cells of 8×8 each → 24×24 pixel sprite.

206GFMCA.asm:2412 (`hero_sprite_col_blit`):
- Source: `sprite_tmp_buf` (pre-decoded into chunky VGA bytes)
- Dest:   `scroll_vga_ofs` (computed VGA position)
- Inner: 3 cells × `mca_blit_2bytes_8rows` (= 64 bytes copied per cell, 8×8 pixels)
- After each cell, DI += 8 (next cell horizontally)
- After each row of 3 cells, DI += 0x9E8 (next cell-row vertically — 320×8 byte stride minus the 24-byte cell row width)

Bosses use 5×5 or larger configurations of the same 8×8 cell unit.

### 3c — Per-entity sprite attribute record (sprite_attr_base)

16-byte record at `sprite_attr_base + sprite_id × 16` (game_seg:0xC010).
Resolved by `sprite_src_setup` (206GFMCA.asm:1148):

| Offset | Field | Notes |
|---:|---|---|
| +0..+3 | ??? | Likely position / bbox info (TBD) |
| +4 | palette/variant | low 5 bits = index into `[SI+BL*2]` palette swap table |
| +5 | flags | bit 7 = use `sprite_src_base` vs `0xA070`; bit 5 = palette offset |
| +6 | anim frame | low 4 bits = current animation frame, ×5 = source byte offset |
| +7..+0xF | ??? | TBD |

`char_lookup` (= `enemy_data_ext` at 0xED20, alias) is the cross-chunk
sprite-id remap table; bosses overlay it with their own per-boss
`sprite_xlat_tbl`.

---

## 4. Tile graphics (UI strip)

### draw_ui_tiles (206GFMCA.asm:3075)

Renders the 5-row × 28-column UI tile strip at the top of the screen
(the HUD background).  Source: `ui_tile_index_tbl` (CS-resident at
line 3140, 140 bytes = 5 rows × 28 tiles).

For each tile index N:
- SI = (N << 4) + 0x4000 (in game seg)
- 16 bytes per tile = 8 word reads
- Each word's 4 nibbles → expanded via `mca_expand_nibble` into 4 pixels
- Writes 8 pixels per row × 8 rows = 64 pixels per tile (8×8 cell in VGA)
- DI advances by `+0x140` per row (= 320 byte stride)
- After 28 cells in a row, DI += `0x920` (= 5×320 - 28×8 = 1600-224 = 1376 = 0x560? — needs verification)

So **tile format**: 8×8 pixels at 4 bits/pixel (1 nibble per pixel),
16 bytes per tile, stored sequentially starting at `game_seg:0x4000`.

The active per-area tileset chunk gets loaded into 0x4000 by 200FIGHT's
`copy_combat_flags_and_tileset` during area entry/transition.

---

## 5. HUD layout (hud_buf at CS:0xE900)

The HUD is a **byte-per-cell mini-map** of the cavern, 28 cols × ~19 rows
(0x214 bytes total).  Each cell holds either a special marker or an
enemy ID; the gfx driver scans the buffer and renders each non-FD cell
as a HUD tile.

### Cell-marker conventions

| Byte | Meaning |
|---|---|
| `0xFD` | Empty (HUD background) — set by `fill_hud_buf_with_FD` |
| `0xFE` | Animated marker (toggled by anim_ctr) — used during scroll |
| `0xFC` | Pre-animated/dormant marker (will become FE next anim tick) |
| `0xFF` | Player position marker — 3×3 cell block via `mark_player_pos_on_hud` |
| `0x01..0xFB` | Enemy/object marker — interpretable as sprite_id |

### Sub-regions

| Address | Region | Size | Purpose |
|---:|---|---|---|
| `0xE900` | hud_buf base | 33 B | HUD strip leading bytes (left margin / generic) |
| `0xE921` | hud_enemy_area | 18 B × scroll_row_cnt | Enemy mini-map cells, refreshed when player_scroll_flag set |
| `0xE939` | hud_player_area | 26 B × 2 rows | Player-row cells, refreshed when enemy_scroll_flag set |
| `0xE939+...` | rest | balance | Remaining mini-map cells (interior of the cavern view) |

### calc_hud_buf_offset (200FIGHT.asm:5751)

Converts (column AL, row AH) → byte offset within hud_buf:
```
offset = (AL & 0x3F) × 28 + (AH - 4)
ptr    = hud_buf + offset
```

So **HUD row stride is 28 bytes** (matches the UI tile-grid 28-column
width), and column 4 is the left edge (AH range starts at 4).

### Per-widget rendering

Individual widgets (HP bar, gold, almas count, key count, equipped
item slot, equipped magic slot, tears count) are rendered by per-element
procs that compute their hud_buf offset based on widget-specific (col, row)
constants and write either tile indices or rendered glyph bytes.

For port purposes: rendering is layered:
1. Fill background with 0xFD (one-shot per scene change)
2. Each per-frame widget update writes its cell range
3. Final pass: gfx driver walks hud_buf, looks up each cell value in
   tile graphics, blits to VGA top-strip region

---

## 5b. GRP file format catalog (cross-referenced from brox)

The `c:\projects\zeliard-brox\tools\GrpViewer\grp_viewer.py` enumerates
13 distinct GRP modes used across the game.  Each mode has specific
pixel encoding + tile dimensions.  Reproduced here for port reference:

| Mode | Dim (W×H) | Stride | Bytes | Type | Used by |
|---:|---:|---:|---:|---|---|
| 0 | 20×18 | 15 | 270 | sprite (3-plane MCGA) | itemp.grp first frame |
| 1 | 16×16 | 12 | 192 | sprite (3-plane MCGA) | itemp.grp frames 1..6, font.grp |
| 2 | 8×8 | 1 | 8 | font glyph (1bpp) | font.grp |
| 3 | 16×16 | 8 | 192 | magic sprite (3-plane, 48-B block reassembly) | magic.grp |
| 4 | 32×32 | (variable) | (variable) | sword macro-tile (2bpp bit-plane assembly) | sword.grp |
| 5 | 16×24 | — | — | NPC sprite | mman.grp, cman.grp |
| 6 | 16×24 | — | — | hero-in-town sprite | tman.grp |
| 7 | 8×8 | 6 | 48 | pattern tile (3-plane) | mpat/dpat/cpat.grp |
| 8 | 16×8 | 4 | 32 | hero-in-dungeon sprite | fman.grp |
| 9 | 8×8 | 6 | 48 | roka background tile | roka.grp |
| 10 | 8×8 | 6 | 48 | static dungeon tile | dchr.grp, mppN.grp |
| 11 | 16×8 | 4 | 32 | per-world enemy sprite | enpN.grp |
| 12 | 16×8 | 4 | 32 | boss sprite tile | crab.grp + 9 other boss .grp files |
| 13 | 16×8 | 4 | 32 | rokademo sprite | dman.grp |

### Per-cavern tile patterns (mppN.grp)

Each cavern has its own pattern bank (mode 10).  brox's grp_viewer
documents the per-cavern tile arrangement:

| File | Tile layout (groups + counts) |
|---|---|
| `mpp1.grp` (Muralla) | `[[1,1,1], [1,1,1,1,1,1,1,1], [1,1], [1,1,1,5,5]]` |
| `mpp2.grp` (Satono) | `[[1,1,1], [4,9], [1,1], [1,1,1,5], [1,1,1,1,1,1,1,1,1]]` |
| `mpp3.grp` (Bosque) | `[[1,1], [9], [16], [1,1], [1,1,1,1,1], [5], [1,1,1,1,1]]` |
| `mpp4.grp` (Helada) | `[[1,1,1], [10], [1,1], [5], [1,1]]` |
| `mpp5.grp` (Tumba) | `[[1,1,1], [10], [13], [4,3], [1,1], [4], [2], [4], [3], [1,1,1,1,1]]` |
| `mpp6.grp` (Dorado) | `[[1,1,1], [3], [1], [2], [5], [9], [1], [1,1], [3], [6], [1,1]]` |
| `mpp7.grp` (Llama) | `[[1,1,1], [27], [1], [4], [1], [4,3], [1,1,1], [1], [1,1], [2], [11]]` |
| `mpp8.grp` (Pureza) | `[[1,1,1], [10], [2], [1,1,3], [1,1,1,1,1,1,1,1,1], [5], [3], [1,1,1,1,1,1,1]]` |
| `mpp9.grp` (Esco) | `[[1,8], [5,3,2], [20]]` |
| `mppa.grp` (final) | `[[1,2,2,4], [6], [1,1], [3]]` |
| `mppb.grp` (Jashiin) | `[[1,3], [1,1]]` |

Each numeric list is a "group" of tile cells; brox's viewer renders
them in nested groupings for visual inspection.

### Sword color tiers (sword.grp mode 4)

Per brox: 3 mega-groups of swords with explicit `(high_color, low_color)`
VGA-palette index pairs:

| Group | Swords | (Hi, Lo) tiers |
|---:|---|---|
| 0 | Training, Wise Man's, Spirit | `(0x09, 0x01)`, `(0x24, 0x04)`, `(0x1B, 0x03)` |
| 1 | Knight's, Illumination | `(0x09, 0x01)`, `(0x24, 0x04)` |
| 2 | Enchantment | `(0x36, 0x06)` |

So the 6 swords in our `sword.grp` frame 0 (at 120×54 pixel render —
see GFX_PIPELINE §3a worked example) are colored by these tier pairs.

---

## 6. Per-frame pipeline (200FIGHT main_loop)

```
1. combat_input_handler          — read joystick, set FSM
2. combat_step_dispatch          — per-direction movement (state5/9_branch)
3. update_combat_frame_state     — HUD updates (calls fill_hud_enemy_area,
                                    apply_combat_damage_with_absorb)
4. sub_27B4                      — spell-cast check
5. decide_scroll_direction       — pick scroll dir based on enemy positions
6. process_combat_update_step    — per-enemy AI tick + scan
   ├─ scan_obj_tiles_advancing/4ahead  — entity/tile collision scan
   └─ tick_increment_enemy_counters
7. process_active_sprites        — walk sprite_work_buf (4 slots)
   └─ prep_boss_dirty_blit       — extract coords from each slot
       └─ enemy_sprite_blit      — compute hud_buf offset + dispatch to
           └─ jmp cs:gfx_fn_78   — per-mode driver's sprite blit (mca_sprite_blit)
8. gfx_fn_render_tile (slot)     — driver's per-frame VGA scroll + tile redraw
9. step_active_sprite_buffers    — advance animation counters in enemy_data_buf
10. update_sprite_work_buf       — process sprite_work_buf (Sabre Oil aura etc.)
11. gfx_fn_render_col (slot)     — driver's per-column scroll catch-up
12. mark_player_pos_on_hud       — write 0xFF marker block
13. render_entity_list_to_hud    — write enemy markers
14. fill_hud_enemy_area          — refresh enemy/player mini-rows on scroll
15. gfx_fn_palette / drv_palette_push — palette update for damage flash etc.
```

---

## 7. Mapping to other gfx drivers

For each gf*.asm driver (EGA/CGA/HGC/TGA/MCGA), the same dispatch
slot indices (CS:0x2000..0x303C) point to mode-specific implementations
of the same logical operations:

| Slot | MCGA equiv (206GFMCA) | Notes |
|---|---|---|
| `gfx_fn_clear` | clear VGA region | Per-mode framebuffer wipe |
| `gfx_fn_render_bg` | bg tile blit pass | Each driver unpacks tiles per its bit-plane layout |
| `gfx_fn_render_tile` | tile + sprite composite | Per-frame VGA write |
| `gfx_fn_player_scroll` | hero_sprite_col_blit | Player sprite blit (3×3 cells = 24×24px) |
| `gfx_fn_enemy_scroll` | mca_sprite_blit family | Per-enemy 8×8 blit |
| `gfx_fn_hud_draw` | draw_ui_tiles | 5×28 UI tile strip |
| `gfx_fn_palette` | DAC palette update (MCGA only) | EGA/CGA palette-pair update; HGC monochrome no-op |
| `gfx_fn_78` | mca_sprite_blit | enemy_sprite_blit's dispatch target |

For port purposes: implement MCGA semantics in C# (chunky bytes →
texture pixels with palette LUT).  Other modes can be skipped unless
authenticity to specific video modes is needed.

---

## 8. Color palette

VGA mode 13h: 256-color, 6-bit-per-channel DAC.  Palette loaded by
`gfx_fn_palette` slot (MCGA driver writes to ports 0x3C8/0x3C9 for
DAC index + RGB triples).

Per-area palette switching: `palette_apply` (Sage) and `set_palette_ff`
(spell cast) trigger palette transitions.  Sprite pixel values are
6-bit indices (& 0x3F mask), so the active palette tier uses only
64 of the 256 DAC entries — the other 192 entries are HUD/UI/text
glyph colors set at boot.

See MEMORY.md "Palette System (CRITICAL)" + captured P1/P2/P3
palette files in `3_Assembly/dumps/`.

### 64-entry sprite palette (brox-confirmed)

Per `brox/MDTViewer/tile_graphics.py`, the **first 64 entries** of
the VGA DAC palette (used for sprite/tile pixel values 0x00..0x3F)
are hardcoded as `(r, g, b)` triples scaled ×4 to 0-255.  Pattern:
8 rows × 8 columns, each row a hue family with varying saturation
and brightness:

```
Row 0 (0x00..07):  (0,0,0) (31,31,31) (31,0,0) (0,31,0) (0,31,31) (0,0,31) (31,31,0) (31,0,31)
Row 1 (0x08..0F):  (31,31,31) (62,62,62) (62,31,31) (31,62,31) (31,62,62) (31,31,62) (62,62,31) (62,31,62)
Row 2 (0x10..17):  (31,0,0) (62,31,31) (62,0,0) (31,31,0) (31,31,31) (31,0,31) (62,31,0) (62,0,31)
Row 3 (0x18..1F):  (0,31,0) (31,62,31) (31,31,0) (0,62,0) (0,62,31) (0,31,31) (31,62,0) (31,31,31)
Row 4 (0x20..27):  (0,31,31) (31,62,62) (31,31,31) (0,62,31) (0,62,62) (0,31,62) (31,62,31) (31,31,62)
Row 5 (0x28..2F):  (0,0,31) (31,31,62) (31,0,31) (0,31,31) (0,31,62) (0,0,62) (31,31,31) (31,0,62)
Row 6 (0x30..37):  (31,31,0) (62,62,31) (62,31,0) (31,62,0) (31,62,31) (31,31,31) (62,62,0) (62,31,31)
Row 7 (0x38..3F):  (31,0,31) (62,31,62) (62,0,31) (31,31,31) (31,31,62) (31,0,62) (62,31,31) (62,0,62)
```

(Values are 6-bit DAC × 4 = 0-248 8-bit RGB.)

**Index 5 (0x05) = `(0, 0, 31)` = dark blue** is the canonical
"background / transparent" pixel color in brox's render — used as
fill for nibble value 0 / unmasked sprite pixels.

This 64-entry palette is **constant** across the game; the
RPAL6/EPAL6/ACPAL/CSPAL row blocks captured in
`3_Assembly/dumps/palette_rows.json` are the FULL 256-entry palette
that includes scene-specific overrides (e.g. opening-cinematic
reds/pinks) in the upper 192 entries.

---

## 9. Port implications

For the MonoGame port:
- **Sprite source**: keep at-source-byte format (48 B per tile or
  16 B per UI tile); decode on load into RGBA texture sheets.
- **HUD buffer**: implement as a 28×19 byte mini-grid; each cell maps
  to one of: `0xFD` (transparent), `0xFE`/`0xFC` (anim marker), `0xFF`
  (player), or `0x01..0xFB` (enemy/item — lookup table to sprite).
- **Tile graphics**: load `tile_pixel_base` (0x4000) as a 16-byte/tile
  array; expand 4-bpp nibbles to a per-area palette LUT.
- **Per-mode**: only need to implement MCGA pipeline; other drivers
  are bit-plane variants of the same logical operations.

Per-tile and per-sprite pixel data lives in the loaded SAR chunks
(per-area sprite bank loaded into 0x8030+, per-area tileset into
0x4000).  These get refreshed on cavern transition via the standard
`LOAD_CHUNK_REF` + `drv_ds_copy` sequence already documented in
ARCHITECTURE.md.
