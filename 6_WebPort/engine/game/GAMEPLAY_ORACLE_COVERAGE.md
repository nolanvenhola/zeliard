# Gameplay Oracle Coverage

This file tracks which `gameplay_state.c` primitives are backed by MASM
behavior probes. "Oracle-backed" means there is a MASM-side functest and a
native C parity case using the same scenario name or a direct manifest mirror.

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
| `zeliard_entity_success_mark_stat_x9c` | Oracle-backed | `placeholder_id/test_stdply_stat_X9C.py` |
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
| `zeliard_game_resolve_music_plan` | Oracle-backed | `proc_equivalence/test_game_load_music_tracks.py` |
| `zeliard_game_resolve_palette_plan` | Oracle-backed | `proc_equivalence/test_game_set_vga_palette.py` |

Next gaps to close:

- Extend the dialog/menu cluster from movement decisions into full
  spacebar/skip result handling.
