# Zeliard boss-AI architecture (10 bosses)

Item #5 from MECHANICS_TO_UNDERSTAND.md.  How each of Zeliard's 10
bosses is implemented — the chunk pairings, shared infrastructure,
state-machine pattern, and per-boss specifics.

---

## Boss roster (per Playthrough.txt §2)

| Boss | Cavern | Spanish name | Tear | Chunk(s) |
|---|---|---|---|---|
| 1 | Muralla / Malicia | Cangrejo (Crab) | Yes | **309CRAB** (self-contained) |
| 2 | Satono / Peligro | Pulpo (Octopus) | Yes | 302EAI2 (AI) + **310TAKO** (arena) |
| 3 | Bosque / Madera | Pollo (Bird) | Yes | 303EAI3 (AI) + **311TORI** (arena) |
| 4 | Helada / Escarcha | Agar (Jelly) | Yes | 304EAI4 (AI) + **312ZELA** (arena) |
| 5 | Tumba / Corroer | Vista (Eyeball) | Yes | 305EAI5 (AI) + **313MEDA** (arena) |
| 6 | Dorado / Tesoro | Tarso (Crab-leg) | Yes | 307EAI7 (AI) + **314LEGA** (arena) |
| 7 | Llama / Caliente | Paguro (Hermit Crab — non-Tear, gives Elf Crest) | — | **315ZEL2** (self-contained per arena structure) |
| 8 | Pureza / Absor | Dragon | Yes | 308EAI8 (AI) + **316DRGN** (arena) |
| 9 | Pureza / Faltar | Alguien | Yes | 308EAI8 (AI) + **317AKMA** (arena) |
| 10 | Pureza / Final | Jashiin (final boss, 2 phases) | Final tear | **318MAO1** + **319MAO2** (both self-contained) |

(`301EAI1` is a generic enemy-AI base used by multiple chunks; it is NOT
boss-specific despite the EAI numbering pattern.)

---

## Two-chunk architecture (most bosses)

Most bosses split their implementation across two paired chunks:

```
                          ┌──────────────────────────────────────┐
                          │  EAI handler (per-enemy AI logic)    │
                          │   ── 302EAI2 / 303EAI3 / etc.        │
                          │   ── reads enemy slot record         │
                          │      ([si+0..16h] — 16 bytes)        │
                          │   ── runs state machine              │
                          │   ── calls fight_cb_* via cs:[60xx]  │
                          └──────────────┬───────────────────────┘
                                         │ (paired at runtime —
                                         │  loaded together by
                                         │  200FIGHT for the boss)
                                         │
                          ┌──────────────▼───────────────────────┐
                          │  Arena chunk (sprites / tile / scan) │
                          │   ── 310TAKO / 311TORI / 312ZELA / … │
                          │   ── per-frame slot scan loop        │
                          │   ── boss-specific sprite frame data │
                          │   ── tile/render tables              │
                          │   ── per-boss state vars at A4xx-A7xx│
                          │   ── 8-char Spanish name tag         │
                          └──────────────────────────────────────┘
```

Three bosses are **self-contained** (no separate EAI module):
- **309CRAB** — Cangrejo (the first boss; AI inline)
- **315ZEL2** — Paguro (the bonus/Elf-Crest boss; AI inline)
- **318MAO1 + 319MAO2** — Jashiin (final boss; two-phase fight,
  each phase its own self-contained chunk)

---

## Shared infrastructure: the `fight_cb_*` callback table

Every boss chunk calls back into 200FIGHT via a fixed set of
dispatch slots at CS:0x6028..0x603E (CS = the boss-arena segment
when loaded; resolves into 200FIGHT's loaded segment):

| Slot | Canonical name | Used for |
|---|---|---|
| `0x200C` | `fight_cb_prep` | per-frame prep (clear flags, set up frame) |
| `0x6028` | `fight_cb_record_ofs` | compute enemy-record address from tile coords |
| `0x6036` | `fight_cb_anim_step` | advance animation frame for current entity |
| `0x6038` | `fight_cb_hit_check` | test if player attack hits this entity |
| `0x603A` | `fight_cb_despawn` | remove entity from active list |
| `0x603C` | `fight_cb_shutdown` | finalize / cleanup (boss-defeat hook) |
| (others 6004..6034) | various | per-direction step, range, alt-pathing, spawn |

(The full 27-slot table is documented in `zr3com.inc` and
`ARCHITECTURE.md` §5.)

---

## Shared chunk layout (per boss arena chunk)

All boss arena chunks (309-319) follow the same physical layout:

```
file offset
0x000..0x003   file-size header word + padding
                 (Sourcer mis-decodes as data — NOT executable)
0x004..0x007   init src/dst pointers
                 (relocation hints used at load time)
0x008..0x013   12 zero bytes (initial state buffer)
0x014..~0x050  template bytes (per-slot default state values)
~0x034..       sprite frame pointer tables (e.g. crab_frame_ptr_tbl_a/b)
~0x05C..0x300  raw sprite frame data
                 (45-50 byte rows of tile indices, multiple frames)
~0x300+        executable code starts (entry: scan_slot_loop)
~0x7D8..0x7E7  8-byte Spanish name tag
                 ('Cangrejo','Pulpo','Pollo','Agar','Vista','Tarso',
                  'Paguro','Dragon','Alguien','Jashiin')
```

The "scan_slot_loop" entry iterates `fight_slot_list` (DS:0xC010,
the active enemy slot list maintained by 200FIGHT) and dispatches
per-slot updates via the fight_cb table.

---

## Enemy slot record (16 bytes per active entity)

Per the 302EAI2 header (which documents this contract for the
TAKO/octopus boss but applies to all enemies):

```
SI = active enemy slot record at game_seg:0xC010 + 16*idx

[si+0..1]   X position (word)
[si+2]      tile-X / row coord (frame counter axis)
[si+3]      tile-Y / col coord
[si+4]      primary state index (low nibble selects state-machine entry)
[si+5]      attribute byte: bit7=facing, bit5=hit, bit6=visible
[si+6]      animation phase / sub-counter (high+low nibbles)
[si+7]      ?
[si+8]      attack cooldown
[si+9]      state/substate (rotated nibbles -> dispatch index)
[si+0Ah]    secondary phase counter
[si+10h]    mirror of [si+0..1] (X position cache)
[si+13h]    tile counter (kept in sync with [si+3])
[si+15h]    persistent attribute (bit6=hit/visible)
[si+16h]    animation frame mirror of [si+6]
```

Each EAI handler reads from this record and runs a state machine
based on `[si+4] & 0x0F` (primary state index, 0..15).  A boss's
"AI" is the fixed-size dispatch table that maps each state-index to
a handler proc.

---

## State-machine pattern (worked example: TAKO)

302EAI2's state machine for the TAKO octopus boss:

```
PRIMARY DISPATCH    [si+4] & 0x0F   ->   tako_state_dispatch[bx]
                                          (table at DS:0xA37B)

  idx 2 or 3   ->  tako_ai_main_entry     (idle / swim / attack)
  idx 4        ->  tako_alt_state_a       (tentacle launch A, cooldown=4)
  idx 5        ->  tako_alt_state_b       (tentacle launch B, cooldown=2)
  idx 6 or 7   ->  tako_seek_state        (4-substate seek dispatcher)

MAIN ENTRY FLOW (idx 2/3):

   ┌─ check_hit ([si+15h] & 0x40)  --hit-->  enter_hide_state
   │
   ▼
   step_swim_y  (vertical drift)
   │
   ▼
   if ([si+9] & 1):
       state_swim_active
         phase 6: launch tentacles
         phase 8: finish
   else:
       state_idle_branch
         distance_check_5(player vs boss):
           close: aim toward hero, set_swim_targets, [si+9] |= 1
           far:   phase advance, step pos/neg
```

Every boss has a state machine of similar shape: a primary index
selects a phase handler; each phase runs sub-state logic from a
small set of internal counters; transitions are gated by hit
detection (via `fight_cb_hit_check`), distance checks, animation
phase, and per-boss specific timers.

---

## Common state writes (every boss)

All boss chunks write to the same set of game-state flags as part
of their per-frame loop:

| Address | Field | Set by boss when... |
|---|---|---|
| `DS:0xFF2E` | `gvar_death_flag` | boss is defeated (HP reaches 0) |
| `DS:0xFF2F` | `gvar_dir_toggle` | direction changes / facing flip |
| `DS:0xFF30` | `gvar_completion` | boss arena cleared / Tear obtained |
| `DS:0xFF75` | `gvar_spawn_fx_flag` | boss spawn effect triggers |

These are read by 200FIGHT's main loop to decide arena-exit
transition (back to cavern map or onward to next boss).

---

## Per-boss summaries

(Source: each chunk's header docblock, plus Phase-3 renames where
applied.  See each chunk's .asm for full details.)

### 309CRAB — Cangrejo (Muralla)

- Self-contained AI in 309CRAB.bin (no separate EAI handler)
- 5 procs total
- State vars at 0xA481-0xA7E4: spawn_limit, anim_tbl_a/b/c, pos_tbl, fight_hp, phase bytes
- Sprite frame pointer tables at 0x034 (9 frames) + 0x054 (5 frames)
- 14 sprite frame data rows
- Helpers: `hp_dec` / `hp_inc` (adjust fight_hp), `emit_sprite_rows`

### 310TAKO — Pulpo (Satono)

- AI handler: 302EAI2 (PAIRED)
- 2 procs in arena chunk; 12 fight_cb refs
- Sprite tables: sprite_pat_tbl_a (0xA57D), sprite_pat_tbl_b (0xA64Dh)
- 5 main states: ai_main_entry, alt_state_a/b, seek_state (4 substates),
  hide_state
- Multi-tentacle attack dispatch
- Distance-based seek/hide

### 311TORI — Pollo (Bosque) — most heavily renamed

- AI handler: 303EAI3 (PAIRED)
- 7 procs (renamed in Phase 3): `tori_render_sprite_row`,
  `tori_swoop_tick`, `tori_apply_damage`, `tori_hp_dec_if_ge_D`,
  `tori_hp_dec_if_ge_11`, `tori_hp_inc_if_below_30`
- Bird flight / glide / swoop attack pattern
- 3 glide tables (A/B/C) at 0xA682..0xA68E for path control
- AI column table at 0xA6CB

### 312ZELA — Agar (Helada)

- AI handler: 304EAI4 (PAIRED)
- 6 procs in arena chunk; 14 fight_cb refs
- Segmented body — multi-part collision
- Sprite/render tables at A5xx-A7xx

### 313MEDA — Vista (Tumba)

- AI handler: 305EAI5 (PAIRED)
- 10 procs (most complex non-final boss)
- Tile/render tables: meda_tile_src_a..h (0xA5DC-0xA6C7)
- Per-state animation xlat at 0xA6ED
- 336-byte tile render buffer at 0xA738
- Phasing/jellyfish behaviour with NPC-cell scan

### 314LEGA — Tarso (Dorado)

- AI handler: 307EAI7 (PAIRED)
- 5 procs; 11 fight_cb refs
- Has the documented stack-frame coincidence at FF3C
  (referenced as `gvar_unk_ff3c`)

### 315ZEL2 — Paguro (Llama, non-Tear bonus boss)

- Self-contained (no EAI pairing per chunk header)
- 6 procs; 14 fight_cb refs
- Gives the Elf Crest, not a Tear of Esmesanty
- Hermit-crab visual, similar shape to ZELA

### 316DRGN — Dragon (Pureza)

- AI handler: 308EAI8 (PAIRED)
- 5 procs; 11 fight_cb refs

### 317AKMA — Alguien (Pureza/Faltar)

- AI handler: 308EAI8 (PAIRED — same handler as DRGN)
- 6 procs; 12 fight_cb refs
- "akma" = 悪魔 (Japanese for demon/devil)

### 318MAO1 — Jashiin phase 1 (Pureza/Final)

- Self-contained (no EAI pairing)
- 1 proc; 6 fight_cb refs (smallest active-fight chunk)
- 2-byte state at 0xFF75 aliased `mao1_gvar_state_byte` (per Phase-3 audit)
- "mao" = 魔王 (Japanese for demon king)

### 319MAO2 — Jashiin phase 2 (final form)

- Self-contained
- 10 procs (most procs of any chunk — complex final phase)
- 14 fight_cb refs
- mao2_gvar_state_a/b/c/d at FF21/2E/2F/30
- Phase byte at FF75 (gvar_spawn_fx_flag aliased)

---

## Boss-defeat death sequence (common across all)

When a boss's HP reaches 0 (most bosses use a per-boss `_hp` byte
similar to TORI's `tori_hp` at 0xA773 or CRAB's `fight_hp` at
0xA7C3):

```
1. Boss-specific "apply_damage" (e.g. tori_apply_damage):
     if ax (current row word) - bx (damage) underflows:
       force ax = 0
     call fight_cb_prep to validate
     if ax == 0:
       gvar_death_flag = 0xFF
       call fight_cb_shutdown
       reset boss-specific phase/altitude/dive flags

2. Next-frame 200FIGHT main loop sees gvar_death_flag set:
     transition arena out, fade music, show "boss defeated" cue
     gvar_completion = 0xFF (if a Tear was earned)

3. 200FIGHT's level-end code runs the appropriate transition
   (back to cavern, or forward to next boss for Jashiin)
```

This is the same chain for all 10 bosses; only the per-boss "apply_damage"
helper differs in its specific HP arithmetic.

---

## What this gives a port

- **Boss roster + Spanish names** matched to chunk filenames
- **Two-chunk architecture** (most bosses have AI + arena)
- **Enemy slot record format** (16 bytes; field semantics)
- **State-machine pattern** (primary index dispatch, sub-state counters)
- **Common death sequence** (gvar_death_flag → completion → transition)
- **fight_cb_* contract** (callbacks back into the engine — already
  documented in ARCHITECTURE.md §5)

A port that wants to faithfully reproduce a boss can:
1. Re-implement the engine's entity-slot scan loop + fight_cb services
2. For each boss, port the AI handler's state machine + the arena
   chunk's per-frame scan loop
3. The sprite frame data (raw bytes 0x34..0x300 of each chunk) can be
   extracted as bitmap atlases

Or, more pragmatically, port each boss as **native code** mirroring
the documented state machine — using the original chunk's data tables
(positions, frame pointers, glide curves) as data-driven inputs.

---

## Status (per MECHANICS_TO_UNDERSTAND.md)

Promotions:
- Boss AI (overall family) — was ⚠ → now ✓ (architecture documented)
- Per-boss state machines — ⚠ (TAKO documented as worked example;
  others still need per-chunk reverse-engineering for full state
  graph, but the FRAMEWORK is uniform)
- Boss intro flag (`boss_intro_flag` at DS:0xC3) — was ⚠ → ✓
- Boss HP / damage / Almas reward — ⚠ (per-boss values in
  BOSSES_DATABASE.md; runtime read path through `fight_cb_*` documented)
- Enemy-trigger flow (entity_fn_e_4) — ⚠ (named earlier; integration
  with boss arena documented here)

Per-boss DEEP state-graph extraction (every state, every transition,
every sub-counter) remains a separate chunk-by-chunk workstream —
each boss is ~1-3 hours of focused tracing.  The framework here lets
that work be done one boss at a time without re-deriving the
common infrastructure.
