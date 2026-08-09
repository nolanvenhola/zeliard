# Zeliard tile-byte format + cavern physics

Item #4 from MECHANICS_TO_UNDERSTAND.md.  How the cavern map's tile
bytes drive contact-damage, blocking, and surface effects.

---

## Tile byte format (8-bit per cavern tile)

Each tile in the cavern map is stored as a single byte read from the
VGA framebuffer (or from the live map area) via `vga_operation4`,
`_5`, `_6`, `_9` (gfx-driver dispatch slots that read map cells).
The byte's bits encode multiple semantics:

```
  bit 7      bit 6      bits 5..4      bits 3..0
  +-----+   +-----+   +-----+-----+   +-----+-----+-----+-----+
  |     |   | dec |   |  hi nib   |   |     low nibble        |
  +-----+   +-----+   +-----+-----+   +-----+-----+-----+-----+
   ?         decor.    sprite/anim     tile-type index  -> tile_type_map[i]
             skip      flags?
```

| Bit / range | Meaning | Used by |
|---|---|---|
| `bit 6` (0x40) | "decoration" — skip in tile-type physics scan | `accumulate_tile_type` (200FIGHT:3576): `test al, 40h; jnz tile_down2` |
| `byte in [0x40 .. 0x48]` | **special "force-vulnerable" tile** (instant zero of `invul_timer`) | `combat_step_dispatch` (200FIGHT:1085): if tile in this band, invul cleared |
| `byte >= 0x49` | **classified as "known entity" by `is_entity_known_type`** → blocks movement | `game_func_128` and the collision-check chain |
| `byte < 0x49` AND not in [0x40..0x48] | regular walkable surface | default path |
| `low nibble` (bits 0..3, 16 values) | **tile-type index** into `tile_type_map[16]` | `accumulate_tile_type`: `mov al, ds:tile_type_map[bx]; add ds:tile_type_sum, ax` |

The low nibble (0..15) lets each cavern map up to 16 distinct
"surfaces" through the per-area `tile_type_map`.

---

## tile_type_map at DS:0xA010 — per-area damage table

A 16-byte (or 32-byte word-pair?) table at DS:0xA010 in the game
segment.  Indexed by the low-nibble of each scanned tile.  Each entry
gives a **damage value** that's added to `tile_type_sum` (DS:0x9F12).

The table is **loaded per area** by the level-init code (the
`game_init_fn` chain in mole.bin, called at boot/cavern-entry by
game.asm:303).  The exact load site for the table data hasn't been
pinpointed in the cleaned source; it's likely one of the per-area
data chunks (.mdt or related) copied into game-segment data area on
area transition.  For port purposes, the **table layout is what
matters**: 16 entries indexed by `tile_byte & 0x0F`.

Common interpretation across caverns (from manual + Playthrough.txt):
- entry 0: walkable (damage = 0)
- low entries: floor / decoration (damage = 0)
- mid entries: slow surfaces (slime/ooze) — likely small damage value
- high entries: hazards (lava/spikes) — damage values 1..N

The PER-AREA values vary — Helada cavern has ice tiles (likely 0-damage
but movement-modifier), Llama cavern has lava tiles (high damage),
Pureza cavern has acid pools.

---

## Per-frame damage scan

Each game tick the player's position scans the 4 surrounding tile
slots and applies any accumulated contact damage.  See 200FIGHT:3380
("check_flag2e_b") for the entry; below is the simplified flow:

```
init: tile_type_sum = 0

scan 4 tile slots around player (slot0..slot3):
  for each slot:
    call entity_fn (queries tile/entity at this slot)
    if tile holds an ENTITY:
      call game_func_56 (entity-contact damage path)
    else:
      call accumulate_tile_type
        // reads VGA map cell at slot via vga_operation9
        // if (al & 0x40): bail (decoration tile)
        // else: ax = tile_type_map[al & 0x0F]
        //       tile_type_sum += ax
  // certain slot-positions also call game_func_57 to flush damage

after scan:
  game_func_57 → apply damage to player
    ax = tile_type_sum
    if (player_facing & 1):  branch one way
    else: branch other way
    if shield_type != 0:
      ax >>= 1
      cl = (shield_type + 1) / 2
      ax >>= cl                           // shield reduces damage
      shield_HP -= ax
      if shield_HP underflows:
        ax = residual
        shield_HP = 0
        hero_HP_subtract(ax)              // residual to HP
        gvar_volume_b = 8 (combat audio cue)
    else:
      hero_HP_subtract(ax)                // raw damage
      gvar_volume_b = 9 (different cue)
```

Key state mutations:
- `tile_type_sum` (DS:0x9F12, 16-bit) — the per-frame damage accumulator
- `shield_HP` (DS:0x94, 16-bit) — depleted before HP
- `hero_HP` (DS:0x90, 16-bit) — final damage sink

---

## Movement collision

When the player or an entity tries to move into a tile, the tile is
classified via `is_entity_known_type`:

```
game_func_128:                  ; "can move east?" check (used by entity_move_east)
  read ax = [si+2]              ; current map column word
  call vga_operation4           ; sets up the read pointer
  inc di / inc di               ; advance to neighbour column
  call is_unknown_or_area5_slot_b
  if CF=0 (entity at slot):
    return — BLOCKED
  ; check the row above too (for 2-tile-tall obstacles)
  swap si/di
  sub si, 24h
  call vga_operation6
  call is_unknown_or_area5_slot_b
  if CF=0:
    return — BLOCKED
  ; sweep up two more rows; OR all reads
  return — CLEAR (carry-out via add al, al)
```

`is_unknown_or_area5_slot_b` (Phase 3 rename) calls
`is_entity_known_type` (also Phase 3), which considers a tile byte as
"known entity" iff:
- byte < 0x49 AND byte appears in the 24-entry `enemy_id_table` at
  DS:0x8000, OR
- 0x49 ≤ byte < 0x80 (the "mid range" auto-pass)

So tile bytes >= 0x49 (low or mid range) typically read as walls /
obstacles.  Tile bytes < 0x49 are usually walkable, with their
LOW NIBBLE driving the damage lookup.

---

## What's pinned down (2026-05-10 update)

| Aspect | Status | Notes |
|---|:---:|---|
| Per-area tile_type_map[16] values | ⚠ | Per-area init copies into DS:0xA010 from each cavern's data section.  Specific values per cavern still need enumeration but the FRAMEWORK is fully decoded.  Use `4_Resources/MdtViewer/` GUI to inspect per-cavern tile bytes. |
| **Ice sliding (Helada)** | ✓ | `gate_area4_no_accessory4` (200FIGHT.asm:2463) returns AL=0xFF if `area_num==4` AND `cur_magic_idx==4` (Ruzeria equipped), else AL=0.  Walk paths write `move_axis` (DS:0x9F23) + `pending_invul` (DS:0x9F21); `check_move_axis` (line 1170) forces continued scroll per the recorded axis bit — that's the slide.  Ruzeria bypasses the gate.  See PLAYER_PHYSICS.md §"Resolved post-2026-05-10" #4. |
| **Slime / ooze (time-based HP drain)** | ✓ | Standard `tile_type_sum` chain — `accumulate_tile_type` (200FIGHT.asm:3645) reads `tile_type_map[low_nibble]` and adds to `tile_type_sum`; `apply_combat_damage_with_absorb` (line 3570) drains via shield then HP.  Slime tiles have a per-area damage value; player takes continuous damage while on hazard.  Manual's "slow movement" is actually per-frame damage interrupting forward progress, NOT a speed modifier. |
| **Water (time-based HP drain)** | ✓ | Same as slime — `tile_type_sum` chain.  No buoyancy/submersion physics; no separate water flag bit. |
| **Acid pools (Pureza, requires Cape)** | ✓ | Per-area `cmp area_num,7` + `cmp cur_magic_idx,5` (Asbestos Cape) gate at 200FIGHT.asm:2885-2895.  When wearing Cape → skip damage; otherwise every 64 frames `subtract_from_player_HP(15)` + red flash + sound. |
| **One-way walls / direction-class collision** | ✓ | Area-specific via `lookup_move_slot_family` (returns tile-family code per area).  `is_unknown_or_area5_slot_b/_c` (line 7436+) for area 5 treats family 1+2 as passable; `check_area_7_boundary` (line 1545) for area 7 treats family 2 as passable.  Different per-area tile-family interpretations create "one-way" feel. |
| **Air-flow passages (push player)** | ✓ | Executable `200FIGHT` probes at the authored Caliente/Correr current zones pin the resulting horizontal/vertical displacement. Do **not** decode MDT +0x06 as air: the release layout is +0x04 vertical-platform rows, +0x06 collapsing-platform rows, and +0x08 horizontal-platform records. The exact current behavior remains owned by the release fight VM and map collision topology; see `environmental_mechanics_native.c` and `test_fight_environmental_mechanics_oracle.py`. |
| Lava (continuous damage) | ✓ | tile_type_map mechanism above |
| Spike / instant-damage tiles | ✓ | tile_type_map (high values) |
| Force-vulnerable tiles (0x40..0x48) | ✓ | `invul_timer` reset on contact |
| Wall blocking | ✓ | `is_entity_known_type` classifier (tile_byte >= 0x49) |

The framework + the per-area gate mechanisms are now fully decoded.
What remains is per-cavern enumeration of exact tile_type_map values
(needs DOSBox observation OR per-area data-chunk decode).

**Methodology lesson** (see memory:feedback_per_area_gate_procs.md):
absence of a global modifier table doesn't mean an effect doesn't
exist.  Zeliard uses per-area gate procs (`gate_area{N}_no_accessory{M}`)
for cavern-specific effects beyond the standard tile-damage chain.

---

## How a port should approach this

1. **Parse the .mdt cavern map** (tile bytes per cell — format is one byte
   per tile in row-major order; resolution per cavern varies).
2. **Maintain tile_type_map[16]** as a per-area config (16 small
   integers — damage values).  Initially set entries:
   - `0` for floor
   - `0` for decoration / walkable
   - small positive (1-2) for slime/ooze
   - large positive (4-8) for lava/spikes
3. **On each game tick**, sample the 4 tiles around the player and
   accumulate `tile_type_sum`.  Apply via the shield-then-HP chain.
4. **For wall collisions**, if `tile_byte >= 0x49` block the move;
   otherwise allow.
5. **For force-vulnerable zones** (`tile_byte` in [0x40..0x48]),
   reset the player's invulnerability timer to 0 so they can take
   subsequent damage immediately.
6. **For ice/slime/water** — you'll need additional per-tile-type
   metadata.  The original game's exact mapping needs DOSBox
   observation.  A reasonable starting heuristic:
   - Ice tile-types: zero damage, but apply a "slip" velocity that
     decays slowly (the sliding effect)
   - Slime tile-types: small damage + reduced movement speed
   - Water tile-types: zero damage + jump disabled

The `tile_type_map` mechanism is general enough to accommodate any
of these as long as you treat the 16 indices as "surface kinds" and
attach per-kind physics to each.

---

## Status (per MECHANICS_TO_UNDERSTAND.md)

Promotions:
- Cavern map data (.mdt files): ⚠ → ✓ (byte-per-tile format documented)
- Map scrolling: ⚠ → ⚠ (already documented via world_x_to_screen_x;
  unchanged here)
- Map width / wrap: ✓ (was already)
- Tile types (walkable, wall, lava, ice, water, slime, ooze): ❌ → ⚠
  (framework documented; per-kind values per area still TBD)
- Per-cavern enemy spawn list: ⚠ (unchanged — separate from tile types)

Damage/HP arithmetic on contact tiles is fully traced through the
`tile_type_map → tile_type_sum → shield → hero_HP` chain.
