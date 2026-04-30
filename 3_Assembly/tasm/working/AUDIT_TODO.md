# Label-Audit TODO

Running list of placeholder labels still in the cleaned tasm source.
Worked through with the `/label-audit` skill — see
`.claude/skills/label-audit/SKILL.md` for the workflow.

Format: each row is a single audit. Mark `[x]` when complete, with the
canonical name in the rightmost column.  Multi-row blocks (e.g. paired
bytes) can be done in one audit pass.

After every audit:
1. `verify1.py <changed-files>` — fast per-edit check.
2. Re-grep the placeholder name AND raw `[<HEX>h]` operands across the
   tree; both must come up clean (only the alias-EQU line + db/dw payloads
   are allowed).
3. End of session: `build_all.py --verify` — all 3 SARs BIT-PERFECT.

---

## High priority — 4 audits, ~30 min

The largest unaudited placeholders.  Probable archetypes 4c (derive
semantics from usage) or 4a (canonical name lurking in another file).

| Done | Address | Placeholder | Sites | Notes | Canonical |
|:---:|---|---|---|---|---|
| [x] | `0xFF3E` | `gvar_flag_FF3E` | 7 | Set in `decrement_ab` (spell cast); gates combat round | **`spell_fx_active`** |
| [x] | `0x9F29` | `state_byte_9F29` | 4 | Game-over outer-phase tick | **`gameover_outer_tick`** |
| [x] | `0x9F28` | `state_byte_9F28` | 3 | Game-over inner-phase tick | **`gameover_inner_tick`** |
| [x] | `0x9F2A` | `state_byte_9F2A` | 3 | game_scan_loop_9 mark-flag (parallel to scan_match_flag) | **`obj_mark_flag`** |

---

## Medium priority — 10 audits, ~90 min

### Remaining `state_byte_9F??` and `state_word_9F??`

| Done | Address | Placeholder | Sites | Notes | Canonical |
|:---:|---|---|---|---|---|
| [x] | `0x9F12` | `state_word_9F12` | 4 | Tile-type sum accumulator (16-bit) | **`tile_type_sum`** |
| [x] | `0x9F16` | `state_byte_9F16` | 2 | 0..3 cyclical post-inc counter; INT 61h every 4 ticks | **`quad_frame_tick`** |
| [x] | `0x9F1D` | `state_byte_9F1D` | 2 | Bit 7 = "boss spawn data armed" | **`boss_init_flag`** |
| [x] | `0x9F07` | `state_byte_9F07` | 1 | Extra-list iteration counter (single inc) | **`extra_iter_tick`** |
| [x] | `0x9F10` | `state_word_9F10` | 1 | Last-entity-hit data ptr | **`last_hit_entity`** |
| [x] | `0xC017` | `state_byte_C017` | 1 | Read at `start_boss_scroll` as `add bx, ds:[C017]` — bx then used as table-pointer index. Runtime probe confirms `bx = 2*idx + word_at_C017` exactly. NOT a state byte — first word of a tile/world data table | **`world_tile_base`** (recommended) |

### `gvar_flag_FF??`

| Done | Address | Placeholder | Sites | Notes | Canonical |
|:---:|---|---|---|---|---|
| [x] | `0xFF4B` | `gvar_flag_FF4B` | 2 | 201SELCT names it gvar_item_result; level transitions on `cmp [FF4B], 8` | **`gvar_item_result`** |

### Multi-name addresses (canonicalize the existing canonical, alias the rest)

| Done | Address | Notes | Canonical |
|:---:|---|---|---|
| [x] | `0xFF57` | 7 names; selection-state byte multi-purposed across town shops; consolidated comment in zr1com.inc | **`gvar_sel_flag`** |
| [x] | `0xFF33` | Dual semantics: zeliad treats as save-flag (init=5), gf*.asm reads same value as anim_speed; consolidated in zr2com.inc | **`gvar_save_flag`** |
| [x] | `0xFF4C` | Already canonical in zr2com.inc (script_ip 103 refs); no change needed | **`gvar_script_ip`** (was already canonical) |
| [x] | `0xFF50` | Already canonical in zr2com.inc (timer_word 12 refs); no change needed | **`gvar_timer_word`** (was already canonical) |
| [x] | `0xFF6A` | Multi-purpose word; consolidated in zr1com.inc | **`gvar_dlg_timer`** |
| [x] | `0xFF75` | gvar_volume_b dominates with 63 refs; consolidated in zr2com.inc; gvar_spawn_fx_flag (39 refs in enemies) acknowledged as dual-use | **`gvar_volume_b`** |

---

## Low priority — synonym cleanups + tail items

### Synonym cleanups (all names are correct, just consolidate)

| Done | Address | Notes | Canonical |
|:---:|---|---|---|
| [x] | `0xFF1A` | Was 4 truly-synonymous names; canonicalized on `gvar_frame_timer`.  `frame_timer`, `gvar_timer_byte`, `gvar_timer_lo`, `gvar_timer_ticks` use sites all renamed; alias EQUs dropped from zr2com.inc.  WATCH-OUT: `gvar_timer_ticks` was ALSO used at FF08 in zeliad.asm/game.asm — those sites preserved, NOT moved | **`gvar_frame_timer`** |
| [x] | `0x2022` | Aliases (`gfx_fn_setup`, `cga_dispatch_fn`, `hgc_dispatch_fn`, `gfx_draw_char_fn`, `bos_var_25e`) are NOT synonyms — they reflect different runtime semantics depending on which gfx driver is loaded.  Documented as multi-purpose driver-dispatch slot in zr2com.inc.  Per-chunk local names retained | **`drv_render_char`** (canonical for shared use; per-chunk names valid in context) |
| [x] | `0x2026` | Same multi-purpose pattern (driver-dependent dispatch).  Documented in zr2com.inc | **per-chunk** (no shared canonical that fits all contexts) |
| [x] | `0x2028` | Same | **per-chunk** |
| [x] | `0x202A` | Same | **per-chunk** |
| [x] | `0xFF68` | Multi-purpose word; canonical `gvar_text_ofs` plus aliases (`gvar_char_y_ofs`, `gvar_scroll_idx`, `menu_col_width`) consolidated in zr1com.inc + zr2com.inc; local EQUs dropped from 108GTCGA / 111GTMCA / 212ARMRP / 215DRUGP | **`gvar_text_ofs`** |

### Single-site mao*/gvar_unk* placeholders

| Done | Address | Placeholder | Notes | Canonical |
|:---:|---|---|---|---|
| [x] | `0xFF21` | `mao2_gvar_state_a` | initial alias to `gvar_skip_input` was REVERTED — canonical `gvar_skip_input` is at `0FF1Dh` (zeliard.inc / stick.asm), not FF21; kept as module-local placeholder with explanatory comment | **kept local** (no shared canonical) |
| [x] | `0xFF30` | `mao2_gvar_state_d` | aliased to gvar_completion (200FIGHT canonical) | **alias of `gvar_completion`** |
| [x] | `0xFF78` | `gvar_unk_FF78` | aliased to gvar_old_int09_raw (zeliard.inc canonical) | **alias of `gvar_old_int09_raw`** |
| [x] | `0xFF3C` | `gvar_unk_ff3c` | 314LEGA's "use" is actually a stack-frame ref `ss:[bp+di+0FF3C]`, NOT the global byte; EQU kept as alias with note; use site reverted to placeholder name | **alias-only** (314LEGA site is a stack ref, not the global) |

---

## Functional-probe required (8 fields)

These `stat_X??` placeholders in stdply have NO canonical name found
anywhere in the codebase.  Each is a single `db` declaration with no
non-EQU usage sites (the byte is referenced via raw `[<HEX>h]` form, if
at all).  Static analysis alone won't crack these — needs Unicorn
functional probe via `functest/harness.py` or runtime tracing.

| Done | Address | Placeholder | Static signal | Canonical |
|:---:|---|---|---|---|
| [x] | `0x9B` | `stat_X9B` | `mov [9Bh], 0FFh` set/clear pattern across town/shop sites | **`trade_marker_flag`** |
| [x] | `0x9C` | `stat_X9C` | 1 write in `entity_fn_e_4` (sets to 0xFF on game_func_118 success), 0 reads anywhere; runtime probe (functest 2026-04-29) confirms write-only with no reader in writer subtree | **VESTIGIAL — write-only flag** |
| [x] | `0x9F` | `stat_X9F` | 1 write in 106TOWN frame_update prologue (cleared every frame), 0 reads anywhere; runtime probe confirms vestigial | **VESTIGIAL — per-frame zero-clear, no reader** |
| [x] | `0xA0` | `stat_XA0` | track count counter (inc/cmp wrap pattern) | **`music_track_count`** |
| [x] | `0xC3` | `stat_XC3` | bit-6 carry-in from boss data, gates intro side | **`boss_intro_flag`** |
| [x] | `0xC6` | `stat_XC6` | 16-bit field; +8 HP/tick heal pulse counter | **`heal_pulse_count`** |
| [x] | `0xE6` | `stat_XE6` | scene-transition request (test FFh / or pattern) | **`scene_trans_request`** |
| [x] | `0xE8` | `stat_XE8` | post-init steady-state flag (20 tests gating one-time init) | **`init_complete_flag`** |

---

## Speculative single-purpose labels (kept honest with comments)

These already have a name, but the evidence is thin and the comment
should reflect that.  Re-audit when more usage sites become available.

| Done | Address | Label | Status |
|:---:|---|---|---|
| [x] | `0x83/0x84` | `ply_accel db 0Ah, 0Ah` | Runtime probe (functest 2026-04-29): split into two independent screen-column counters. **0x83 → `town_player_col`** (range 0..0x10, walk_left/right inc/dec); **0x84 → `fight_player_col`** (range 0..7 in 200FIGHT). The `ply_accel` declaration is bogus — these bytes are NOT a 16-bit pair |
| [x] | `0x88..0x8A` | `stat_X88_hi`, `stat_X88_lo` | Runtime probe confirms 24-bit add/adc/carry-propagation pattern identical to hero_gold. Used in **213BANKP.asm** as the bank deposit accumulator. **0x88 → `hero_bank_hi`**, **0x89..0x8A → `hero_bank_lo`** (24-bit banked gold) |

---

## Out of scope for this skill (different audit type)

These are tracked here for visibility but the `/label-audit` skill
isn't designed for them — they need a different recipe.

- **`game_func_N` proc names** — 198 sites across 93 distinct names.
  Procs need a "trace what they do" workflow, not a "what's the byte
  for" workflow.  Could be a future `/proc-audit` skill.
- **Sourcer-generated `sub_N` / `loc_N` labels** — pure mechanical
  decoration, replaced by an `/asm-cleanup` pass per file.

---

## Already done (reference)

For prose patterns of completed audits, see SKILL.md "Worked examples".
Quick recap:

| Address | From | To |
|---|---|---|
| `0x80..0x82` | `ply_walk_speed` + reserved | `map_scroll_col` (dw) + `map_scroll_row` |
| `0x85..0x87` | hero_gold_hi/lo + reserved | hero_gold_hi/lo/mid (24-bit field) |
| `0x88..0x8A` | reserved | `stat_X88_hi/lo` (24-bit, semantics TBD) |
| `0x8B..0x8C` | hero_almas (1 byte) | hero_almas (word) |
| `0x8D` / `0x8E` | placeholders | `item_qty_count` / `item_effect_val` |
| `0x90..0x91` / `0x94..0x95` | hero_HP / shield_HP (1 byte) | both 16-bit (functional probe) |
| `0x96..0x9A`, `0x9E`, `0xE4` | placeholders | `char_exp_cap`, `char_speed`, `char_power`, `char_abilities`, `cur_magic_idx`, `key_count` |
| `0xC2` | reserved | `player_facing` (87 byte_tests, hottest byte in stdply) |
| `0xC4`, `0xC8`, `0xD2` | local labels only | EQUs added: ply_level, ply_tileset, ply_hitbox |
| `0xC9..0xCF` | "unknown player state" | annotated as **vestigial** (no refs anywhere) |
| `0xE7` | `stat_XE7` | `gvar_pose_idx` (player pose state, 64 raw refs replaced + canonical EQU in zr1com/zr2com/game.asm) |
| `0xFF2E` / `FF2F` / `FF30` | `gvar_flag_FFNN` placeholders | `gvar_death_flag`, `gvar_dir_toggle`, `gvar_completion` |
| `0xFF3F` / `FF41` | placeholders | `hero_frame`, `weapon_state` |
| `0xFF44` | `gvar_joy_data` (misnomer) | `restore_pending` (bg_restore flag, 21 refs in gf*.asm) |
| `0xFF45..47` | placeholders | `gvar_combat_action_state` / `_anim_subindex` / `_audio_latch` (combat input FSM) |
| `0xFF4A` | placeholder | `obj_scan_index` (object-list iteration counter) |
| `0x9F08` / `9F17` / `9F18` / `9F19` / `9F1E` / `9F1F` / `9F2B` | placeholders | `step_counter`, `scan_match_flag`, `hp_regen_tick`, `hit_snd_played`, `warp_pending`, `sprite_buf_count`, `palette_fade_ctr` |

**Cumulative**: 33+ placeholders renamed canonically, all SARs BIT-PERFECT.

---

## Session-of-2026-04-28 batch (this run)

| Address | Old | New |
|---|---|---|
| `0xFF3E` | `gvar_flag_FF3E` (+ misnomer `gvar_palette_b`) | `spell_fx_active` |
| `0x9F28` | `state_byte_9F28` | `gameover_inner_tick` |
| `0x9F29` | `state_byte_9F29` | `gameover_outer_tick` |
| `0x9F2A` | `state_byte_9F2A` | `obj_mark_flag` |
| `0x9F12` | `state_word_9F12` | `tile_type_sum` |
| `0x9F16` | `state_byte_9F16` | `quad_frame_tick` |
| `0x9F1D` | `state_byte_9F1D` | `boss_init_flag` |
| `0x9F07` | `state_byte_9F07` | `extra_iter_tick` |
| `0x9F10` | `state_word_9F10` | `last_hit_entity` |
| `0xFF4B` | `gvar_flag_FF4B` (+ `gvar_joy_count`) | `gvar_item_result` |
| `0xFF21` / `0xFF30` / `0xFF78` / `0xFF3C` | `mao2_gvar_state_a/d`, `gvar_unk_FF78`, `gvar_unk_ff3c` | aliases of canonical names |
| `0xFF33` / `0xFF57` / `0xFF6A` / `0xFF75` | multi-name consolidation in shared includes | comments only |

**Result**: 11 new canonical renames + 4 single-site aliases + 4 multi-name consolidations.  All 3 SARs **BIT-PERFECT** at end-of-batch.

---

## Session-of-2026-04-28 batch 2: stdply stat_X* sweep + alias cleanup

| Address | Old | New |
|---|---|---|
| `0x9B` | `stat_X9B` | `trade_marker_flag` (canonical EQU in stdply.inc, propagated to zr1com/zr2com via duplicate EQU) |
| `0xA0` | `stat_XA0` | `music_track_count` (canonical in stdply.inc) |
| `0xC3` | `stat_XC3` | `boss_intro_flag` (canonical in stdply.inc, propagated to zr1com/zr2com) |
| `0xC6` | `stat_XC6` | `heal_pulse_count` (canonical in stdply.inc, 16-bit) |
| `0xE6` | `stat_XE6` | `scene_trans_request` (canonical in stdply.inc, propagated to zr1com/zr2com) |
| `0xE8` | `stat_XE8` | `init_complete_flag` (canonical in stdply.inc, propagated to zr1com/zr2com) |
| `0xFF21` (mao2) | speculative `gvar_skip_input` alias | reverted to local `mao2_gvar_state_a` — FF21 has no shared canonical; the FF1D byte is the real `gvar_skip_input` |
| `0xFF3C` (lega) | speculative `gvar_palette_flag` use-site rename | reverted use-site to `gvar_unk_ff3c` — site is a stack-frame ref, not the global |
| `0xFF75` (mao1/mao2) | speculative `gvar_volume_b` alias | retargeted to `gvar_spawn_fx_flag` (zr3com.inc canonical for FF75 in zelres3 fight context) |

**Result**: 6 new canonical renames + 3 use-site corrections after the bulk-alias pass introduced wrong canonicals.  All touched files individually `verify1.py BIT-PERFECT`; SAR-level verify confirms `zelres1/2/3.sar` all BIT-PERFECT.

---

## Session-of-2026-04-29: Phase-2 runtime probes (functional probe required → resolved)

| Address | Old | Verdict | Canonical |
|---|---|---|---|
| `0x9C` | `stat_X9C` | runtime probe: 1 write in `entity_fn_e_4`, 0 reads observed (consistent with grep) | **VESTIGIAL — write-only flag** |
| `0x9F` | `stat_X9F` | runtime probe: per-frame zero-clear in 106TOWN, 0 reads observed | **VESTIGIAL — per-frame clear, no reader** |
| `0xC017` | `state_byte_C017` | runtime probe: `bx = 2*idx + word_at_C017` confirmed; word is value-bearing | **`world_tile_base` (data-table base; rename recommended)** |
| `0x83/0x84` | `ply_accel db 0Ah, 0Ah` | runtime probe: walk_right_move increments [83h] by exactly 1 | **`town_player_col` (0x83) + `fight_player_col` (0x84)** — split bogus 2-byte declaration |
| `0x88..0x8A` | `stat_X88_hi/lo` | runtime probe: 24-bit add+adc+carry behavior identical to hero_gold; bank chunk uses it | **`hero_bank_hi/lo` (24-bit banked gold)** |

**Result**: 5 placeholders resolved at runtime; static-side AUDIT_TODO "Functional-probe required" section now empty.  Test artifacts:
- `functest/placeholder_id/test_stdply_stat_X9C.py`
- `functest/placeholder_id/test_stdply_stat_X9F.py`
- `functest/placeholder_id/test_fight_state_byte_C017.py`
- `functest/placeholder_id/test_town_player_col_X83.py`
- `functest/placeholder_id/test_stdply_hero_bank_X88.py`

All 10 functests PASS via `functest/run.py --ci`.  No source edits required to land verdicts (the runtime evidence stands; static renames are an independent commit pending user direction).

---

## Session-of-2026-04-29 (cont'd): Phase-3 sweep — game_func_* identity renames

Followed `functest/PHASE3_PRIORITY.md` priority queue (47 category-B
procs in 200FIGHT, sorted by `n_calls_in DESC`).  Net result:

- **45 game_func_\* renamed** in 200FIGHT.asm (all 47 cat-B except 2)
- **2 retained as Sourcer-glued multi-fragment clusters** (game_func_56,
  game_func_23) with explanatory comments
- **6 movement-family + 6 collision-check procs** (122-127, 132-137)
  also renamed despite being category C/D — their roles were obvious
  from static analysis and they unblocked the cat-B chain
- **16 runtime tests** authored under `functest/proc_equivalence/` for
  the high-leverage / non-trivial procs; the rest are static-evidence
  renames (small/trivial procs documented in `functest/INDEX.md`'s
  "Static-evidence renames" table)

Full list in `functest/INDEX.md`.  Rename categories:

| Function class | Renamed | Examples |
|---|---:|---|
| Entity-ID classifiers | 4 | is_entity_known_type, is_entity_id_lax, is_entity_known_type_alt, is_non_area7_slot_b_entity |
| Coordinate transforms | 4 | world_x_to_screen_x, world_x_to_inner_screen_x, world_x_to_screen_x_w25, world_x_to_screen_x_w27 |
| Slot/table lookups | 3 | lookup_move_slot_family, tail_dispatch_by_slot_family, find_and_blit_map_entry |
| Sprite/blit pipeline | 5 | enemy_sprite_blit, prep_dirty_blit, prep_boss_dirty_blit, process_dirty_enemies, process_active_sprites |
| Stat / inventory math | 3 | hero_HP_subtract, hero_almas_add, item_effect_val_add |
| Entity slot writes | 2 | entity_slot_write_tagged, update_entity_dir_from_path |
| Combat state | 4 | reset_combat_state, init_combat_arena, combat_step_dispatch, accumulate_tile_type |
| Movement family | 4 | entity_move_{east,north,west,south} |
| Movement helpers | 8 | inc/dec_map_pos_helper, check_north/south_movement, check_movement_var_134..137 |
| Tile placement | 2 | try_place_tile_id_49, try_paint_obj_cell |
| Misc utilities | 8 | match_dl_within_3, compute_scroll_pos, compute_scroll_offset_b, decrement_speed_or_power, gate_spell_fx_active, entity_fn_dispatch_b, entity_step_dispatch_c, cycle_dir_and_advance |
| Iterators | 2 | tick_decrement_enemy_counters, tick_increment_enemy_counters |
| Trivial wrappers | 2 | enter_level_via_ref_a, process_map_seg_updates |
| Identity check + slot family | 2 | is_unknown_or_area5_slot_b, is_unknown_or_area5_slot_c |
| Misc | 2 | bot_path_check, toggle_c2_bit_pose |

**Verification**: every per-file `verify1.py` BIT-PERFECT; full
`build_all.py --verify` confirms all 3 SARs BIT-PERFECT; 25 of 26
functests PASS (1 NO-VERDICT by design — the dispatch-fingerprint test
groups by behavior rather than asserting PASS/FAIL).

---

## Session-of-2026-04-29 (cont'd): Synonym cleanups + tail items

Resolved the 6 "Low priority synonym cleanup" rows:

| Address | Action | Result |
|---|---|---|
| `0xFF1A` | Canonicalized on `gvar_frame_timer`; renamed `gvar_timer_lo`, `gvar_timer_byte`, `gvar_timer_ticks` use sites + dropped alias EQUs from zr2com.inc | True synonyms — consolidated.  Caveat: `gvar_timer_ticks` was ALSO defined at FF08 in zeliad.asm/zeliard.inc — that's a SEPARATE byte (timer counter, not frame timer), preserved as-is |
| `0xFF68` | Canonicalized on `gvar_text_ofs` in zr1com.inc + zr2com.inc with multi-purpose comment; dropped 4 local EQUs (108GTCGA, 111GTMCA, 212ARMRP, 215DRUGP) | Multi-purpose word; aliases declared in shared headers |
| `0x2022, 0x2026, 0x2028, 0x202A` | Documented in zr2com.inc as multi-purpose driver-dispatch slots; per-chunk local names retained (NOT synonyms — function pointer changes by loaded gfx driver) | No forced consolidation; comment block prevents future re-litigation |

11 source files touched; all individually `verify1.py` BIT-PERFECT; full
`build_all.py --verify` confirms all 3 SARs **BIT-PERFECT**.

Files modified:
- `core/zeliad.asm`, `core/game.asm` (revert wrong `gvar_timer_ticks` rename)
- `zelres1/code/{100OPDMO, 108GTCGA, 111GTMCA, 106TOWN}.asm`
- `zelres2/code/{200FIGHT, 212ARMRP, 213BANKP, 214CHURP, 215DRUGP, 216INNAP, 217KENJP, 250ENDMO}.asm`
- `zelres3/code/300ROKAD.asm`
- `zelres1/code/zr1com.inc`, `zelres2/code/zr2com.inc`
