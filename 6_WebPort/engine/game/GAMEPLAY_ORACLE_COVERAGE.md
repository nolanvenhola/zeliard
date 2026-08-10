# Gameplay Oracle Coverage

This file tracks which `gameplay_state.c` primitives are backed by MASM
behavior probes. "Oracle-backed" means there is a MASM-side functest and a
native C parity case using the same scenario name or a direct manifest mirror.

Canonical player-record coverage:

| C primitive | Status | MASM oracle |
| --- | --- | --- |
| `zeliard_player_state_bind` / `snapshot` / `import` | Oracle-backed | `regression/test_player_record_contract.py`, `proc_equivalence/test_sword_knight_oracle.py`, `test_elf_crest_oracle.py`; exact release `stdply.bin` SHA-256, web-asset identity, 256-byte initialization and opaque-tail preservation, including Glory Crest bytes 24h/9Bh and Paguro/Elf Crest bytes 30h/31h/34h/9Ah through save/load, cavern handoff, and death/Sage recovery |
| `zeliard_player_read/write_u8/u16/u24` | Oracle-backed | `regression/test_player_record_contract.py`; complete MASM before/after diff allowlists for byte state, HP word, and carried-gold 24-bit layout |
| `zeliard_king_select_script` | Oracle-backed | `proc_equivalence/test_felishika_room_frames_oracle.py`; all four `210KINGP:select_script_branch` outcomes |

| C primitive | Status | MASM oracle |
| --- | --- | --- |
| `zeliard_subtract_from_player_hp` | Oracle-backed | `regression/test_arithmetic_24bit_and_word.py` |
| `zeliard_hero_almas_add` | Oracle-backed | `regression/test_arithmetic_24bit_and_word.py` |
| `zeliard_gold_add` | Oracle-backed | `proc_equivalence/test_town_dispatch_slot_600C.py` |
| `zeliard_gold_insufficient` | Oracle-backed | `proc_equivalence/test_town_dispatch_slot_600A.py` |
| `zeliard_bank_add` | Oracle-backed | `regression/test_arithmetic_24bit_and_word.py` |
| `zeliard_town_walk_right_col` | Oracle-backed partial | `placeholder_id/test_town_player_col_X83.py`; legacy bounded-column wrapper |
| `zeliard_town_walk_right_col_full` | Oracle-backed | `proc_equivalence/test_town_walk_right_col.py` |
| `zeliard_town_walk_left_col` | Oracle-backed | `proc_equivalence/test_town_walk_left_col.py` |
| `zeliard_town_frame_clear_stat_x9f` | Oracle-backed | `placeholder_id/test_stdply_stat_X9F.py` |
| `zeliard_entity_success_mark_stat_x9c` | Oracle-backed | `proc_equivalence/test_hero_crest_oracle.py`, `placeholder_id/test_stdply_stat_X9C.py`; exact MP30 object 40 link, 200FIGHT acquisition write/message, and 201SELCT Hero's Crest render slot |
| `zeliard_inc_map_pos` | Oracle-backed | `regression/test_movement_helpers.py` |
| `zeliard_dec_map_pos` | Oracle-backed | `regression/test_movement_helpers.py` |
| `zeliard_inc_row` | Oracle-backed | `regression/test_movement_helpers.py` |
| `zeliard_dec_row` | Oracle-backed | `regression/test_movement_helpers.py` |
| `zeliard_entity_move_direction` | Oracle-backed | `regression/test_movement_helpers.py` |
| `zeliard_tick_decrement_enemy_counters` | Oracle-backed | `regression/test_enemy_tick_iterators.py` |
| `zeliard_tick_increment_enemy_counters` | Oracle-backed | `regression/test_enemy_tick_iterators.py` |
| `zeliard_town_measure_word_width` | Oracle-backed | `proc_equivalence/test_town_measure_word_width.py` |
| `zeliard_town_count_wrapped_lines` | Oracle-backed | `proc_equivalence/test_town_count_wrapped_lines.py` |
| `zeliard_town_dialog_cursor_pos` | Oracle-backed | `proc_equivalence/test_town_draw_cursor_at_dlg_row.py` |
| `zeliard_town_cursor_anim_positions` | Oracle-backed | `proc_equivalence/test_town_cursor_anim.py` |
| `zeliard_town_selection_scroll_plan` | Oracle-backed | `proc_equivalence/test_town_selection_scroll.py` |
| `zeliard_town_menu_input_decision` | Oracle-backed | `proc_equivalence/test_town_menu_input_decision.py` |
| `zeliard_town_menu_pre_joy_result` | Oracle-backed | `proc_equivalence/test_town_menu_result_flags.py` |
| `zeliard_town_menu_entry_after_tick` | Oracle-backed | `proc_equivalence/test_town_menu_entry_setup.py` |
| `zeliard_town_menu_entry_joystick_result` | Oracle-backed | `proc_equivalence/test_town_menu_entry_joystick.py` |
| `zeliard_town_menu_entry_scroll_result` | Oracle-backed | `proc_equivalence/test_town_menu_entry_scroll.py` |
| `zeliard_town_prompt_yes_no_result` | Oracle-backed | `proc_equivalence/test_town_prompt_yes_no.py` |
| `zeliard_town_clear_dialog_rows_plan` | Oracle-backed | `proc_equivalence/test_town_clear_n_dialog_rows.py` |
| `zeliard_town_shop_selection_anim_plan` | Oracle-backed | `proc_equivalence/test_town_shop_selection_anim_loop.py` |
| `zeliard_town_menu_items_column_plan` | Oracle-backed | `proc_equivalence/test_town_draw_menu_items_column.py` |
| `zeliard_town_check_save_name_is_new` / `zeliard_town_clear_save_name_if_new` | Oracle-backed | `proc_equivalence/test_town_save_name_new_flag.py` |
| `zeliard_town_save_name_cursor_update` / `zeliard_town_save_name_redraw` | Oracle-backed | `proc_equivalence/test_town_save_name_cursor.py` |
| `zeliard_town_save_name_backspace` | Oracle-backed | `proc_equivalence/test_town_save_name_backspace.py` |
| `zeliard_town_save_name_append_char` | Oracle-backed | `proc_equivalence/test_town_save_name_append_char.py` |
| `zeliard_gate_spell_fx_active` | Oracle-backed | `regression/test_gate_classifier_procs.py`; active branch uses fall-through stub |
| `zeliard_is_entity_known_type` | Oracle-backed | `regression/test_gate_classifier_procs.py` |
| `zeliard_is_entity_id_lax` | Oracle-backed | `regression/test_gate_classifier_procs.py` |
| `zeliard_lookup_move_slot_family` | Oracle-backed indirectly | classifier probes cover all three slot families |
| `zeliard_is_non_area7_slot_b_entity` | Oracle-backed | `regression/test_gate_classifier_procs.py` |
| `zeliard_is_unknown_or_area5_slot_b` | Oracle-backed | `regression/test_gate_classifier_procs.py` |
| `zeliard_is_unknown_or_area5_slot_c` | Oracle-backed | `regression/test_gate_classifier_procs.py` |
| `zeliard_reset_combat_state` | Oracle-backed | `regression/test_reset_combat_state.py` |
| `zeliard_compute_scroll_pos` | Oracle-backed | `regression/test_compute_scroll_offset_b.py` |
| `zeliard_compute_scroll_offset_b` | Oracle-backed | `regression/test_compute_scroll_offset_b.py` |
| `zeliard_match_dl_within_3` | Oracle-backed | `regression/test_compute_scroll_offset_b.py` |
| `zeliard_convert_world_x_to_inner_screen_x` | Oracle-backed | `regression/test_compute_scroll_offset_b.py` |
| `zeliard_convert_world_x_to_screen_x` | Oracle-backed | `regression/test_compute_scroll_offset_b.py` |
| `zeliard_entity_slot_write_tagged` | Oracle-backed | `proc_equivalence/test_fight_game_func_82.py` |
| `zeliard_prep_dirty_blit` | Oracle-backed | `proc_equivalence/test_fight_prep_boss_dirty_blit.py` |
| `zeliard_enemy_sprite_blit_gate` | Oracle-backed partial | `proc_equivalence/test_fight_vga_operations.py`; host blit itself is abstracted |
| `zeliard_prep_boss_dirty_blit` | Oracle-backed | `proc_equivalence/test_fight_prep_boss_dirty_blit.py` |
| `zeliard_entity_fn_dispatch_b_prepare` | Oracle-backed | `proc_equivalence/test_fight_entity_fn_dispatch_b.py` |
| `zeliard_entity_step_dispatch_c_prepare` | Oracle-backed | `proc_equivalence/test_fight_entity_step_dispatch_c.py` |
| `zeliard_scroll_dispatch_table_offset` | Oracle-backed | `proc_equivalence/test_fight_game_func_70.py` |
| `zeliard_scroll_buf_offset` | Oracle-backed | `proc_equivalence/test_fight_game_func_70.py` |
| `zeliard_scroll_si_wrap_high` | Oracle-backed | `proc_equivalence/test_fight_game_func_70.py` |
| `zeliard_scroll_si_wrap_low` | Oracle-backed | `proc_equivalence/test_fight_game_func_70.py` |
| `zeliard_gate_area4_no_accessory4` | Oracle-backed | `regression/test_gate_classifier_procs.py` |
| `zeliard_scroll_si_from_player` | Oracle-backed | `proc_equivalence/test_fight_game_process_loop_2.py` |
| `zeliard_world_tile_entry_address` | Oracle-backed | `placeholder_id/test_fight_state_byte_C017.py` |
| `zeliard_get_object_state_at_cell` | Oracle-backed | `proc_equivalence/test_fight_game_func_120.py` |
| `zeliard_try_place_tile_id_49` | Oracle-backed | `proc_equivalence/test_fight_game_func_129.py` |
| `zeliard_tick_right_col_entities` | Oracle-backed | `proc_equivalence/test_fight_game_process_loop_2.py` |
| `zeliard_try_place_3cell_entity_row` | Oracle-backed | `proc_equivalence/test_fight_try_place_3cell_entity_row.py` |

Game-loader orchestration covered outside `gameplay_state.c`:

| C primitive | Status | MASM oracle |
| --- | --- | --- |
| `zeliard_game_resolve_bootstrap_plan` | Oracle-backed | `proc_equivalence/test_game_bootstrap_sequence.py`; includes bootstrap state clear list, all-mode GD/GT/GF driver tables, compressed-table relocations, `game_init_fn` segment patch, new/saved load order, optional equipment driver calls, and music init |
| `zeliard_game_execute_bootstrap` | Oracle-backed | `game_loader_parity_native`: executes both `AX=0` and OPDMO `AX=FFFFh` paths against four real-mode segments; verifies SAR-header stripping, fill-buffer loads, memory writes, relocations, `CS:A472` patch, service calls, event order, and final branch |
| `zeliard_game_resolve_music_plan` | Oracle-backed | `proc_equivalence/test_game_load_music_tracks.py` |
| `zeliard_game_resolve_palette_plan` | Oracle-backed | `proc_equivalence/test_game_set_vga_palette.py` |

Town live-runtime coverage:

| C primitive | Status | MASM oracle |
| --- | --- | --- |
| `zeliard_town_advance_pit` | Oracle-backed composition | `proc_equivalence/test_town_live_loop_primitives.py`, walk-left/right oracles, `town_runtime_native` scripted frame hashes |
| `zeliard_town_detect_facing_targets` | Oracle-backed | `106TOWN` target-scan branches mirrored by `town_facing_targets:right` native fixture |
| `process_town_event_table` / `tick_npcs_dispatch` | Oracle-backed | `proc_equivalence/test_town_live_loop_primitives.py`, `test_hero_crest_oracle.py`, `test_elf_crest_oracle.py`; release-byte memory diffs over active/inactive events and two NPC ticks plus Bosque's byte-12h/mask-08h sentry mutation and Llama's Paguro/one-time Elf Crest dialog mutations |
| `zeliard_room_enter` / `zeliard_room_leave` | Oracle-backed stable frames and transitions | `proc_equivalence/test_felishika_room_frames_oracle.py`, `test_gmmcga_building_fade_oracle.py`; release `210KINGP`/`211OMOYP`/`217KENJP` prologues plus both `106TOWN` building-boundary fades |
| `zeliard_room_masm_vm` Sage menu, hints, power, spells, and exit | Release-byte executed and oracle-backed | `proc_equivalence/test_felishika_room_frames_oracle.py`; pure tier outputs and all seven spell handlers, plus `felishika_rooms_native` full command flows, first/repeat visits, level/HP/experience/charge diffs |
| Sage `Record Experience` DOS proxy | Release-byte executed and oracle-backed | `felishika_rooms_native`; exact 8-character editor path, `.usr` suffix, INT 21h create/write/close, 256-byte payload identity, persisted-file identity, and write-failure retry |
| `zeliard_load_record` saved-game restore | Oracle-backed integration | `main_controls_native`, `regression/test_player_record_contract.py`, `proc_equivalence/test_game_bootstrap_sequence.py`; strict 256-byte validation and existing `AX=FFFFh` bootstrap with progression/equipment/NPC-state round trip |

Town MCGA dispatch coverage:

| C primitive | Status | MASM oracle |
| --- | --- | --- |
| `zeliard_gmmcga_resolve_town_dispatch` | Release-byte backed | `town_mcga_dispatch_native`; all 20 live `106TOWN` resident slots checked against `gmmcga.bin` |
| `zeliard_gtmcga_resolve_town_dispatch` | Release-byte backed | `town_mcga_dispatch_native`; all 17 live `106TOWN` slots checked against `111GTMCA.bin` |
| `zeliard_gmmcga_clear_playfield` | Oracle-backed | `proc_equivalence/test_gmmcga_town_clear_playfield_oracle.py`; full VGA and visible framebuffer hashes |
| `zeliard_gmmcga_building_fade_pass` | Oracle-backed | `proc_equivalence/test_gmmcga_building_fade_oracle.py`; all eight GMMCGA:2130 framebuffer masks and full VGA hash |
| `zeliard_gmmcga_draw_status_line` | Oracle-backed | `proc_equivalence/test_gmmcga_town_status_lines_oracle.py`; exact initial three-call register sequence and framebuffer hashes |
| `zeliard_gmmcga_draw_life_scale` / `draw_life_max` / `draw_life_current` | Oracle-backed | `proc_equivalence/test_gmmcga_town_life_hud_oracle.py`; staged full-VGA hashes from `2385/2227/2256` |
| `zeliard_gmmcga_draw_hud_label` | Oracle-backed | `proc_equivalence/test_gmmcga_town_hud_label_oracle.py`; `22BF` record and color-state hash |
| `zeliard_gmmcga_draw_town_text_record` | Oracle-backed | `proc_equivalence/test_gmmcga_town_text_record_oracle.py`; `22CD` record and color-state hash |
| `zeliard_gmmcga_draw_almas` / `draw_gold` / `draw_spell_charge` / `draw_shield_hp` | Oracle-backed | `proc_equivalence/test_gmmcga_town_numeric_hud_oracle.py`; staged decimal-state and VGA hashes |
| `zeliard_gmmcga_draw_first_frame_hud` | Oracle-backed | `proc_equivalence/test_gmmcga_town_first_frame_hud_oracle.py`; exact initial `frame_update` HUD order and combined state/VGA hash |
| `zeliard_gmmcga_draw_collected_tears` | Oracle-backed | `proc_equivalence/test_gmmcga_collected_tears_oracle.py`; exact GAME:A3A6 slot order plus GMMCGA:2A1C normal/final sprites for every 0- through 9-Tear save state |
| `zeliard_gtmcga_encode_tile_block` | Oracle-backed | `proc_equivalence/test_gtmcga_encode_tile_block_oracle.py`; packed source, alpha masks, and scratch hashes |
| `zeliard_gtmcga_capture_playfield` | Oracle-backed | `proc_equivalence/test_gtmcga_capture_playfield_oracle.py`; captured segment and exit registers |
| `zeliard_gtmcga_scroll_view_left` / `scroll_view_right` | Oracle-backed | `proc_equivalence/test_gtmcga_town_scroll.py`; full 64K VGA hashes from release `111GTMCA.bin` |
| `zeliard_gmmcga_prepare_room_tiles` | Oracle-backed | `proc_equivalence/test_felishika_room_frames_oracle.py`; exact GMMCGA:2C2A 256-tile banks for King, Omoya, and Sage assets |
| `zeliard_gtmcga_draw_room_glyph` / `draw_room_tile_grid` | Oracle-backed | `proc_equivalence/test_felishika_room_frames_oracle.py`; exact GTMCGA:371C 8x12 and 16x17 room frame composition |

Next gaps to close:

- Execute item/NPC dialog bodies after the now-oracle-backed facing scans.
- Execute building-specific script command dispatch and animated dialogue after the now-oracle-backed King/Sage room prologues.
