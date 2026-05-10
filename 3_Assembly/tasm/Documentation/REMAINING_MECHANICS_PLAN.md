# Plan: Close the remaining 23 ❌ items in MECHANICS_TO_UNDERSTAND.md

State as of 2026-05-10 (post-batch-4 + GRP characterization):
- 178 ✓ / 28 ⚠ / 23 ❌ (78% fully traced)

The 23 remaining items split into 5 phases by methodology — earlier
phases are pure source-trace work (fastest, highest leverage), later
phases need binary/runtime inspection.

---

## Phase 1 — Pure asm code-trace (10 items)

No DOSBox or external tools needed; everything is in the working tree.

| # | Item | Approach |
|---|---|---|
| 1a | Cavern entry from town | Trace `scene_trans_request` (DS:0xE6) writers in 106TOWN → cavern-side reader in 200FIGHT module-init.  Identify which byte values map to which cavern_idx. |
| 1b | Cavern → town return | Reverse of 1a — find scene_trans_request write paths in 200FIGHT (boss-defeat, exit-door) and the town-side reader in 106TOWN init. |
| 1c | Cavern → cavern transition | `current_level_idx` (DS:0xC8) increment site; boss-defeat → next-area chain; chunk_ref_tbl_base[idx*11] table lookup in game.asm. |
| 1d | Boss room entry | gvar_state-machine flip from "cavern" to "arena"; per-boss 209BOSQE/EAI handler hand-off; `boss_intro_flag` (DS:0xC3) bit-6. |
| 1e | Doors and locks (cavern side) | `try_door_transition` (106TOWN.asm:1875) already mostly traced for towns; cavern-side door records in `.mdt` doors table (12B each) + collision-test in 200FIGHT. |
| 1f | Per-shop pricing | Find per-shop price tables: 212ARMRP for weapons/shields, 215DRUGP for potions, 213BANKP for exchange rates (already documented). Tables are DS-resident, indexed by gvar_menu_sel. |
| 1g | Music stop/pause/resume | Find INT 60h AX-value dispatcher for music control: track `mscmt.drv` calls in stick.asm + per-chunk music load/stop paths. |
| 1h | Ctrl-R restart | Mark ✓ REFUTED — bit 0x404 has no test in stick.asm; already documented. |
| 1i | Boss intro animations | Per-boss chunk's "intro" state in 309-319; trigger via `gvar_state` switch when boss_intro_flag set; sprite animation loop. |
| 1j | Ending sequence | Trace 211OMOYP `end_demo_transition` → loads enddemo.bin → 250ENDMO; identify trigger condition (gvar_completion set + final boss kill). |

**Phase 1 deliverable**: 10 ❌ → ✓ (or ✓ REFUTED).  Resolves all
purely-source items.  No external tooling required.

---

## Phase 2 — MDT format inspection + cavern asm cross-trace (4 items)

Requires extending the Python tooling to inspect .mdt records, then
matching offsets against cavern-side 200FIGHT consumers.

| # | Item | Approach |
|---|---|---|
| 2a | Moving platforms | MDT pointer at offset 0x08 = h_platforms (7B each); 0x04 = v_platforms (3B each).  Build `4_Resources/MdtViewer/mdt_inspect.py` dumper, cross-reference with `entity_fn_e_*` handlers in 200FIGHT that read h/v_platform records. |
| 2b | Loot boxes (visible) | MDT pointer at 0x0C = items table.  Decode item record format (likely `{world_x, row, item_id, ??}`); find pickup handler in 200FIGHT. |
| 2c | Secret loot (hidden tiles) | Likely same `items` table as 2b with a "hidden" flag bit per record; trigger requires player to break/touch specific tile.  Cross-reference with `tile_type_map` for the secret-tile byte. |
| 2d | Doors and locks (cavern records) | MDT pointer at 0x0A = doors table (12B each).  Decode record: `{world_x, row, lock_type, key_required, dest_world_x, dest_row, ??}`.  Cross-reference with `try_door_transition` and key-consume path in 200FIGHT (line 4509-4515 `dec keys_normal`). |

**Phase 2 deliverable**: 4 ❌ → ✓.  Adds `4_Resources/MdtViewer/mdt_inspect.py`.

---

## Phase 3 — Per-tile-type physics-modifier mapping (4 items)

The `tile_type_map[16]` exists per area (loaded with map data).  Need
to find the per-tile-type physics-modifier table (likely a parallel
16-entry table indexed by tile_type).

| # | Item | Approach |
|---|---|---|
| 3a | Surface effects: ice (Helada cavern) | Find Helada-area tile_type_map; trace which tile_type triggers what proc.  Look for a "skid" / horizontal-drift modifier in player physics dispatch (200FIGHT state5/9_branch / try_combat_advance). |
| 3b | Surface effects: slime/ooze | Same — find which tile_type bytes flag as slime; look for speed-reduction or HP-drain modifier. |
| 3c | Surface effects: water | Likely a separate flag bit in tile byte (not just tile_type); check for `test al, 0x20` or similar bit-tests in the per-frame tile scan (line 1245-1250 area). |
| 3d | One-way walls + one-way air-flow walls | Direction-gated tile bit; check tile_type_map entries with `tile_byte & 0xF0` for direction flags.  Cross-reference with `range_check_si_byte` + `entity_type_quick_check`. |

**Phase 3 deliverable**: 4 ❌ → ✓ (or ⚠ if specific per-area
parameters need DOSBox to enumerate).

---

## Phase 4 — Per-item finalization (4 items)

Per-item handlers + entity-trigger addresses for cavern pickups not
yet pinned.

| # | Item | Approach |
|---|---|---|
| 4a | Shoes (Ruzeria/Pirika/Silkarn/Asbestos cape/Feruza) | 5 shoe/cape types.  Find entity-trigger addresses in 200FIGHT (similar to crest pickups at 9AF3h/9B2Ch).  Pickup handler likely writes to a "shoes" byte in player record (TBD address). |
| 4b | Damage to "magic clothing" types (Asbestos cape vs lava) | Once shoes byte is located, find tile-damage path that reads it.  Likely `subtract_from_player_HP` has a pre-check that scales by clothing type. |
| 4c | Blue-potion invulnerability | Find entity-trigger address that sets `invul_timer` to a large value (not the 0x0A hit-recovery value).  Likely sets it to 0xFF (255 frames ≈ 14 sec). |
| 4d | Sabre Oil (sword temporary boost) | Already substantially refuted.  Re-check: maybe a timed flag set on use, consumed by `select_player_sprite_frame` damage path.  Could end up ✓ REFUTED if no buff mechanism exists. |

**Phase 4 deliverable**: 3-4 ❌ → ✓ (or ✓ REFUTED).

---

## Phase 5 — Misc cleanup (1 item)

| # | Item | Approach |
|---|---|---|
| 5a | Restart Ctrl-R (Misc/QoL duplicate) | Cross-reference to §14 like other duplicates; mark ✓ REFUTED. |

**Phase 5 deliverable**: 1 ❌ → ✓ REFUTED.

---

## Expected outcome

| Phase | Items | Method | Effort |
|---|---|---|---|
| 1 | 10 | Pure source trace | 1 working session |
| 2 | 4 | MDT inspector + asm cross-trace | 1 session (incl. tool build) |
| 3 | 4 | Per-area tile-type table trace | 1 session |
| 4 | 4 | Cavern entity-trigger trace | 0.5 session |
| 5 | 1 | Doc cross-reference | trivial |

**Target**: 23 → 0 ❌; coverage 78% → ~95-100% ✓.

Items that may genuinely require DOSBox observation (and would end up
⚠ until then) are the **per-area tile-type effect parameters** (how
slow does slime make you?  how much does ice slide?  how much HP/sec
does lava drain on a specific cavern?).  Those quantitative values
can land in `TILE_PHYSICS.md` as a separate runtime-observation pass.

## Order of execution

1. Phase 1f + 1h + 1g + 5a — quickest wins (~30 min, 4 items)
2. Phase 1a-1e + 1i + 1j — cavern-side asm trace (~1.5 hr, 7 items)
3. Phase 2 — MDT inspector + matching (~2 hr, 4 items)
4. Phase 3 — tile-type physics (~1 hr, 4 items)
5. Phase 4 — per-item entity-trigger pins (~30 min, 4 items)

Each phase ends with a commit that updates MECHANICS_TO_UNDERSTAND.md
and bumps the coverage summary.

---

# Phases 1-5 outcome (2026-05-10) + post-Sabre-Oil retrospective

All 5 original phases executed.  Result: 23 → 0 ❌; 198 ✓ / 31 ⚠.

**Two user corrections during execution** exposed methodology gaps:

1. **Ice sliding (Ruzeria shoes)** — claimed REFUTED based on "no
   horizontal-drift code", but ice slide exists via per-area gate
   procs (`gate_area4_no_accessory4` + `move_axis`).  Lesson:
   per-area mechanisms are gate-proc-driven, not table-driven.

2. **Sabre Oil (sword aura)** — claimed REFUTED based on "no buff
   state byte", but Sabre Oil creates a damage-tile aura via the
   shared buffer at 0xEB60 (`anim_spr_tbl` in 201SELCT ==
   `sprite_work_buf` in 200FIGHT).  Lesson: same DS address can
   have different EQU names per chunk; grep by literal hex
   address, not local symbol.

Both lessons saved to `memory:feedback_per_area_gate_procs.md` and
`memory:feedback_shared_buffer_aliases.md`.

---

# Phase 6 — Cross-chunk shared-buffer audit (preventive)

Goal: catch the next Sabre-Oil-style mistake **before** the user has
to correct me.  Build a script that finds DS addresses with multiple
different EQU names across chunks — those are the prime suspects for
"write-here-consume-there" semantics that local symbol grep misses.

Steps:
1. Extract every `<symbol> equ <hex>` from every `.asm` and `.inc`
   in `working/`.
2. Group by hex address; flag addresses with ≥ 2 distinct symbol
   names.
3. For each flagged address, list:
   - Which chunks define which name
   - Which chunks have read/write sites
4. Output a report at `working/SHARED_BUFFER_AUDIT.md`.
5. Manually inspect the top-N most-distinct-named addresses and
   document the canonical "what is this buffer actually for" for
   each.

Expected to surface 5-15 multi-aliased buffers.  Each one is a
potential mechanic I might have under-traced because the consumer
chunk's local name differed from the writer chunk's local name.

**Phase 6 deliverable**: `working/SHARED_BUFFER_AUDIT.md` +
re-examined mechanic claims where shared buffers are involved.

---

# Phase 7 — Re-investigate `⚠` items via the corrected methodology

Many ⚠ items have notes like "...likely a per-area gate proc..." or
"...possibly emergent...".  Apply the two new methodology lessons:

| ⚠ item | Re-investigation approach |
|---|---|
| Surface effects: slime/ooze | Search for `gate_area*_no_accessory*` procs for areas other than 4 + 7; candidate accessory: Pirika (cur_magic_idx==2) in Tumba.  Look for `cmp area_num, X` + `cmp cur_magic_idx, 2` patterns. |
| Surface effects: water | Same — likely Silkarn Shoes (3) in Dorado (per stdply.inc).  Search `cmp cur_magic_idx, 3`. |
| Sword falling-bonus | Re-check `entity_ptr_loop` in `select_player_sprite_frame` for whether SI advancement during fall multiplies hit-tests.  Also cross-check 0xEB60-style aliased buffers used by combat. |
| Damage formula (per-enemy AX computation) | Find the per-enemy attack callbacks that compute the damage AX before `subtract_from_player_HP`.  These live in zelres3 EAI/boss chunks. |
| Special entry barriers (Esco hidden, Pureza requires X) | Search 106TOWN's `door_type_special` for flag checks (likely `boss_kill_*` byte tests).  Esco's "hidden" entry is probably a check against a story flag set by a specific NPC dialog. |
| Tear of Esmesanti pickup | Search zelres3 boss chunks (309-319) for `inc byte ptr ds:[0A0h]` or `inc tears_of_esmesanti_count`.  Likely fires in the per-boss death cleanup. |
| Spell grant per level | Trace 217KENJP's `sage_cmd_dispatch` for paths that write to magic-slot bytes (DS:A1..A5 spell_slot_*).  Per-sage spell grant likely uses `sage_intro_tbl[sage_id]` dispatch. |
| Story progression flags | Cross-reference `boss_kill_*` byte writes across all chunks — find non-boss-defeat writers (those are story-flag setters that happen to overload the same byte range). |
| Area unlock gating | Search 106TOWN's `try_door_transition` for `test boss_kill_<N>, FFh` patterns gating cavern entry. |

**Phase 7 deliverable**: ~5-8 ⚠ → ✓ promotions, with code citations.

---

# Phase 8 — Per-chunk RE for the remaining ⚠ items

Items that genuinely need per-chunk deep RE (not just cross-chunk
search):

| ⚠ item | Approach |
|---|---|
| Per-boss state machines (9 remaining bosses) | Already TAKO documented as worked-example in BOSS_AI.md.  Replicate for the other 9 in 309-319 chunks.  ~30 min per boss = 4-5 hours total.  Could be a follow-up "per-boss deep-dive" doc series. |
| Tile graphics: per-tile semantics | Match tileset chunks (zelres3 per-area sprites) against gfx-driver tile-render fns.  Requires matching each tile_byte value to its visual interpretation per cavern. |
| Sprite graphics: per-entity sprite tables (blit fn) | Trace `prep_dirty_blit` + `enemy_sprite_blit` to identify the actual sprite-byte format and how each `sprite_obj_tbl` 6-byte entry maps to screen pixels. |
| Player sprite rendering pipeline | Already partially traced via `select_player_sprite_frame`; remaining gap is the per-frame blit fn that consumes the chosen entity_ptr_table[bx] entry. |
| HUD rendering layout | Per-element offset map within hud_buf — needs documentation pass listing each HUD widget's byte range. |
| Volume control bytes (FF74/75 vs FF74/77) | Resolve address discrepancy; verify whether they're truly "audio cue trigger" bytes or something else. |
| Map scrolling (h+v internals) | Trace gfx_scroll_left/right_fn slot targets per gfx driver (CGA/EGA/HGC/TGA/MCGA). |
| Ctrl-Q / Ctrl-J / Ctrl-K | Specific Ctrl+letter handlers in stick.asm or zeliad.asm; require finding the bit-pattern test (e.g. `test gvar_timer_counter, 0x14` for Ctrl+Q). |

**Phase 8 deliverable**: most ⚠ items closed; final state targets
220+ ✓ / <10 ⚠ / 0 ❌.  Items that remain ⚠ after Phase 8 are
genuinely DOSBox-observation-bound (e.g. per-area exact slime damage
value, exact ice slide distance).

---

# Order of execution (Phases 6-8)

1. **Phase 6** first (~30 min, automated) — the cross-chunk shared-
   buffer audit catches mistakes systematically + may resolve several
   ⚠ items as side effect.
2. **Phase 7** (~1.5 hr, search-driven) — re-investigate the ⚠
   items most likely to have hidden mechanisms (surface effects,
   spell grant, story flags).
3. **Phase 8** (~3-4 hr, per-chunk deep RE) — closing pass for the
   remaining ⚠ items that need targeted source reading.

Each phase ends with a commit + push.
