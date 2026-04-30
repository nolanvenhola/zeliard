## Functional-test index

Catalog of harness-driven tests.  Counterpart to `working/AUDIT_TODO.md`
(static-audit todos) — this file tracks what has been **functionally
verified at runtime** via the Unicorn harness in `harness.py`.

Each test file is a self-contained probe: setup state → call function →
observe byte-level mutations → derive (or refute) a label.  No SAR
rebuilds; no source edits.  Verdicts here can feed back into AUDIT_TODO
as evidence for follow-up renames.

---

### Categories

- **`placeholder_id/`** — pin down the identity of a placeholder byte by
  watching what mutates it / what reads it.  Each test answers "is this
  byte at DS:`<addr>` actually `<hypothesized name>`?" or "is this an
  N-bit field, not a 1-byte field?".

- **`proc_equivalence/`** — pin down what a procedure DOES at a known
  address (or at a dispatch-slot target).  Validates / refutes IDA-
  derived names by behavioral fingerprint, independent of any label.

- **`regression/`** — fixed-input fixed-output tests for procs whose
  semantics are already pinned down; guard against future static
  refactors silently changing behavior.  (Empty for now.)

---

### Index

| Category | File | Verifies |
|---|---|---|
| placeholder_id | [test_player_stats_word_layout.py](placeholder_id/test_player_stats_word_layout.py) | DS:0x90/0x8B/0x94 are 16-bit fields (`hero_HP`, `hero_almas`, `shield_HP`), not bytes |
| placeholder_id | [test_stdply_stat_X9C.py](placeholder_id/test_stdply_stat_X9C.py) | DS:0x9C is **VESTIGIAL** — `entity_fn_e_4` writes 0xFF, no reader observed in writer subtree |
| placeholder_id | [test_stdply_stat_X9F.py](placeholder_id/test_stdply_stat_X9F.py) | DS:0x9F is **VESTIGIAL** — town frame_update zero-clears it every frame, no reader |
| placeholder_id | [test_fight_state_byte_C017.py](placeholder_id/test_fight_state_byte_C017.py) | DS:0xC017 is a **data-table base word** (`bx = 2*idx + word_at_C017` in start_boss_scroll); rename → `world_tile_base` |
| placeholder_id | [test_town_player_col_X83.py](placeholder_id/test_town_player_col_X83.py) | DS:0x83 is **`town_player_col`** (screen column counter, walk_right_move increments by 1); the `ply_accel db 0Ah,0Ah` declaration was bogus |
| placeholder_id | [test_stdply_hero_bank_X88.py](placeholder_id/test_stdply_hero_bank_X88.py) | DS:0x88..0x8A is **`hero_bank_hi/lo`** — 24-bit banked gold accumulator (add+adc+carry confirmed in BANKPRO.BIN) |
| proc_equivalence | [test_fight_dispatch_8slots_fingerprint.py](proc_equivalence/test_fight_dispatch_8slots_fingerprint.py) | All 8 fight-bin move-monster slots (0x6008..0x6016) grouped into N/S/E/W families by mutation fingerprint |
| proc_equivalence | [test_fight_dispatch_slot_6008.py](proc_equivalence/test_fight_dispatch_slot_6008.py) | Fight slot 0x6008 target (0x91E5) reads `[SI+3]`, branches on `<34`, IDA-name `move_monster_E` cross-checked |
| proc_equivalence | [test_town_dispatch_slot_600A.py](proc_equivalence/test_town_dispatch_slot_600A.py) | Town slot 0x600A target (0x7570) reads gold at DS:0x85+0x86..0x87 — confirms hero_gold_hi/_lo layout |
| proc_equivalence | [test_town_dispatch_slot_600C.py](proc_equivalence/test_town_dispatch_slot_600C.py) | Town slot 0x600C target adds AX into DS:0x86 word, propagates carry into DS:0x85 byte |
| proc_equivalence | [test_fight_game_func_138.py](proc_equivalence/test_fight_game_func_138.py) | `game_func_138` → **`is_entity_known_type`** — entity-ID classifier; ZF=1 iff AL is in enemy_id_table OR in 0x49..0x7F. 18 callers. |
| proc_equivalence | [test_fight_game_func_89.py](proc_equivalence/test_fight_game_func_89.py) | `game_func_89` → **`entity_slot_write_tagged`** — bit-7 tagged slot write to [di] direct or `enemy_data_ext[idx]`. 8 callers. |
| proc_equivalence | [test_fight_game_func_141.py](proc_equivalence/test_fight_game_func_141.py) | `game_func_141` → **`world_x_to_screen_x`** — world-X → screen-X with map-wrap (constant 0x23 = 35-tile width). 6 callers. |
| proc_equivalence | [test_fight_game_func_42.py](proc_equivalence/test_fight_game_func_42.py) | `game_func_42` → **`is_entity_id_lax`** — variant of is_entity_known_type that accepts AL>=0x80 as known. 5 callers. |
| proc_equivalence | [test_fight_game_func_87.py](proc_equivalence/test_fight_game_func_87.py) | `game_func_87` → **`world_x_to_inner_screen_x`** — same shape as world_x_to_screen_x but constant 0x21 (33-tile inner region). 5 callers. |
| proc_equivalence | [test_fight_game_func_63.py](proc_equivalence/test_fight_game_func_63.py) | `game_func_63` → **`lookup_move_slot_family`** — scan AL across 3 4-entry tables; CL = family idx 0/1/2 or 0xFF. 5 callers. |
| proc_equivalence | [test_fight_game_func_120.py](proc_equivalence/test_fight_game_func_120.py) | `game_func_120` → **`hero_almas_add`** — adds AX to hero_almas with 0xFFFF cap + HUD redraw. 4 callers. |
| proc_equivalence | [test_fight_game_func_93.py](proc_equivalence/test_fight_game_func_93.py) | `game_func_93` → **`enemy_sprite_blit`** — gates on [di]>=0xFC, then game_multiply_4 + vga_operation4 + gfx_fn_78. 4 callers. |
| proc_equivalence | [test_fight_game_func_60.py](proc_equivalence/test_fight_game_func_60.py) | `game_func_60` → **`hero_HP_subtract`** — subtract AX from hero_HP word with 0-clamp + HP-bar HUD redraw. 4 callers. |
| proc_equivalence | [test_fight_game_func_19.py](proc_equivalence/test_fight_game_func_19.py) | `game_func_19` → **`is_non_area7_slot_b_entity`** — CF=1 iff area_num != 7 AND entity in move_slot_b. 2 callers. |
| proc_equivalence | [test_fight_game_func_82.py](proc_equivalence/test_fight_game_func_82.py) | `game_func_82` → **`match_dl_within_3`** — match [si] against {DL, DL+1, DL+2}; DH = (1, 0, -1). 3 callers. |
| proc_equivalence | [test_fight_game_func_92.py](proc_equivalence/test_fight_game_func_92.py) | `game_func_92` → **`prep_dirty_blit`** — gates on bit-15 of [si+7]; clears flag + falls through to enemy_sprite_blit. 2 callers. |
| proc_equivalence | [test_fight_game_func_106.py](proc_equivalence/test_fight_game_func_106.py) | `game_func_106` → **`try_place_tile_id_49`** — 4-gate tile placement (counter + vga_op9 + 2 bit-5 flags). 3 callers. |
| proc_equivalence | [test_fight_game_func_70.py](proc_equivalence/test_fight_game_func_70.py) | `game_func_70` → **`compute_scroll_pos`** — derive map_scroll_col/row from scroll_count, scroll_dir, player_y. 2 callers. |
| proc_equivalence | [test_fight_game_func_129.py](proc_equivalence/test_fight_game_func_129.py) | `game_func_129` → **`is_unknown_or_area5_slot_b`** — CF=1 iff entity unknown OR (area==5 AND in slot_b). 2 callers. |
| proc_equivalence | [test_fight_game_func_131.py](proc_equivalence/test_fight_game_func_131.py) | `game_func_131` → **`is_unknown_or_area5_slot_c`** — twin of 129 but slot_c family. 2 callers. |

---

### Conventions for adding a new test

1. **Pick the category by what the test PROVES**, not where the code
   lives.  A probe that touches fight.bin to disambiguate a stdply byte
   goes in `placeholder_id/`, not `proc_equivalence/`.

2. **Filename**: `test_<area>_<short-noun>.py` — area is the chunk family
   or symbol prefix, short-noun is the thing being verified.  Examples:
   `test_stdply_init_complete_flag.py`, `test_fight_arena_setup.py`.

3. **Imports**: at the top of every test (paths are 1 level deep):

   ```python
   import sys
   from pathlib import Path
   HERE = Path(__file__).parent
   sys.path.insert(0, str(HERE.parent))   # find harness.py at functest root
   from harness import TasmHarness  # noqa: E402
   ```

4. **Output format**: human-readable PASS/FAIL with the byte deltas
   that justified the verdict.  No silent passes.  Tests should print
   the diff (e.g. `DS:0x86 0x00->0x64`) so a reader who doesn't trust
   the verdict can re-derive it from the trace.

5. **Update this index** when the test lands.  One row per file.

6. **Feed verdicts back to `working/AUDIT_TODO.md`** — when a runtime
   probe confirms or refutes a static guess, mark the relevant row
   there (or move it from "Functional-probe required" to "Done").

---

### Static-evidence renames (no test artifact)

These were renamed based on static analysis only (small/trivial procs
where a runtime test would be ceremonial).  Listed for traceability.

| Old name | New name | Chunk | Notes |
|---|---|---|---|
| `game_func_27` | `process_map_seg_updates` | 200FIGHT | map_seg_ptr scanner with conditional copy |
| `game_func_41` | `is_entity_known_type_alt` | 200FIGHT | third variant of entity classifier (handles 0x9F mask) |
| `game_func_51` | `init_combat_arena` | 200FIGHT | sets anim_ctr_x/y + enemy_scroll_flag, gfx fill/clear |
| `game_func_59` | `accumulate_tile_type` | 200FIGHT | tile-type lookup → adds to tile_type_sum |
| `game_func_62` | `tail_dispatch_by_slot_family` | 200FIGHT | pops 2 frames + tail-dispatch via entity_dispatch_tbl |
| `game_func_65` | `enter_level_via_ref_a` | 200FIGHT | trivial wrapper: `mov bx, level_ref_a; jmp level_start` |
| `game_func_68` | `world_x_to_screen_x_w27` | 200FIGHT | coord transform variant (constant 0x27) |
| `game_func_71` | `compute_scroll_offset_b` | 200FIGHT | scroll-position calc variant |
| `game_func_72` | `decrement_speed_or_power` | 200FIGHT | dual-state counter decrementer (char_speed/_power) |
| `game_func_73` | `reset_combat_state` | 200FIGHT | zeros ~15 game-state flags + jmp hud_fill |
| `game_func_81` | `find_and_blit_map_entry` | 200FIGHT | 3-byte-entry map-table search + vga_operation4 blit |
| `game_func_84` | `bot_path_check` | 200FIGHT | match_dl_within_3 + game_process_loop_3 chain |
| `game_func_88` | `world_x_to_screen_x_w25` | 200FIGHT | coord transform variant (constant 0x25) |
| `game_func_91` | `process_dirty_enemies` | 200FIGHT | scan enemy_data_buf calling prep_dirty_blit |
| `game_func_96` | `entity_fn_dispatch_b` | 200FIGHT | jmp via entity_fn_tbl_b[[si+5]&7] |
| `game_func_97` | `entity_step_dispatch_c` | 200FIGHT | gates [si+5] bit-6 + dispatch via entity_fn_tbl_c |
| `game_func_98` | `update_entity_dir_from_path` | 200FIGHT | reads path-table byte, updates [si+5] direction bits |
| `game_func_99` | `tick_decrement_enemy_counters` | 200FIGHT | scan enemy_data_buf decrementing first byte |
| `game_func_100` | `tick_increment_enemy_counters` | 200FIGHT | sibling that increments instead |
| `game_func_102` | `process_active_sprites` | 200FIGHT | sprite_work_buf scanner with prep_boss_dirty_blit |
| `game_func_103` | `prep_boss_dirty_blit` | 200FIGHT | bit-15 dirty flag prep for boss-sprite blit |
| `game_func_111` | `gate_spell_fx_active` | 200FIGHT | trivial guard: `test [spell_fx_active]; jnz +3; retn` |
| `game_func_112` | `cycle_dir_and_advance` | 200FIGHT | inc [si+5] mod 3, advance column with map-wrap |
| `game_func_115` | `try_paint_obj_cell` | 200FIGHT | 3x3 cell renderer worker (vga_operation9 + bit checks) |
| `game_func_122` | `entity_move_east` | 200FIGHT | bounded col=0x22, jmp inc_map_pos |
| `game_func_123` | `entity_move_north` | 200FIGHT | bounded AL!={0,0x23}, jmp dec_row |
| `game_func_124` | `entity_move_west` | 200FIGHT | bounded col>=2, jmp dec_map_pos |
| `game_func_125` | `entity_move_south` | 200FIGHT | bounded AL!={0,0x23}, jmp inc_row |
| `game_func_126` | `inc_map_pos_helper` | 200FIGHT | column++ with map-width wrap |
| `game_func_127` | `dec_map_pos_helper` | 200FIGHT | column-- + inc/dec_row helpers (multi-fragment) |
| `game_func_132`–`137` | `check_north_movement`, `check_south_movement`, `check_movement_var_134`–`137` | 200FIGHT | tile-collision checks called by entity_move_* family |
| `game_func_143` | `item_effect_val_add` | 200FIGHT | adds AX to item_effect_val with 0xFFFF cap |

### Documented placeholders (kept by design)

`game_func_56` and `game_func_23` retained as Sourcer-glued multi-
fragment clusters with explanatory comment blocks in 200FIGHT.asm.
Renaming would obscure their cross-proc-jump-target nature.
