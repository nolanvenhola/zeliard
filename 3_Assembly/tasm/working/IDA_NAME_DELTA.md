# IDA-vs-Cleaned Name Delta Report

Cross-check: same address defined in both our cleaned `.inc` files and the
friend's IDA decompilation `.inc` files. Where names differ, the IDA name is
almost certainly more accurate (derived from runtime IDA debugging).

- Addresses in both: **142**
- Only in our source: 26
- Only in IDA: 200

## Name agreements / disagreements at shared addresses

| Address | Our names | IDA names | Status |
|---|---|---|---|
| `0x0` | `cga_buf_start`, `zero_offset` | `Cangrejo_Defeated`, `InitTitleScreen_proc`, `magic_grp_sprites` | **rename?** |
| `0x80` | `ply_walk_speed` | `proximity_map_left_col_x` | **rename?** |
| `0x83` | `ply_accel` | `hero_x_in_viewport` | **rename?** |
| `0x85` | `drv_timer_flag` | `hero_gold_hi` | **rename?** |
| `0x86` | `drv_time_param_a` | `hero_gold_lo` | **rename?** |
| `0x8B` | `drv_time_param_b` | `hero_almas` | **rename?** |
| `0x90` | `drv_text_src` | `hero_HP` | **rename?** |
| `0x92` | `ply_jump_flag` | `sword_type` | **rename?** |
| `0x93` | `drv_sprite_flag` | `shield_type` | **rename?** |
| `0x94` | `drv_time_param_c` | `shield_HP` | **rename?** |
| `0x9D` | `drv_frame_idx` | `current_magic_spell` | **rename?** |
| `0xAB` | `drv_color_lut` | `spells_espada` | **rename?** |
| `0x100` | `ISR_STUBS_BASE`, `isr_keyboard` | `int9_new_proc` | **rename?** |
| `0x103` | `isr_timer` | `int8_new_proc` | **rename?** |
| `0x106` | `isr_critical` | `int24_new_proc` | **rename?** |
| `0x109` | `isr_music` | `int61_new_proc` | **rename?** |
| `0x10C` | `sar_loader_fn` | `res_dispatcher_proc` | **rename?** |
| `0x2000` | `drv_fill_rect`, `gfx_screen_base` | `Draw_Bordered_Rectangle_proc` | **rename?** |
| `0x2002` | `drv_screen_init_a` | `Clear_Viewport_proc` | **rename?** |
| `0x2008` | `drv_palette_push` | `Draw_Hero_Health_proc` | **rename?** |
| `0x200C` | `fight_cb_prep` | `Draw_Boss_Health_proc` | **rename?** |
| `0x2010` | `drv_load_msg_header` | `Render_Pascal_String_1_proc` | **rename?** |
| `0x2012` | `drv_screen_init_b` | `Clear_Place_Enemy_Bar_proc` | **rename?** |
| `0x2016` | `drv_frame_commit` | `Print_Gold_Decimal_proc` | **rename?** |
| `0x2018` | `drv_anim_step` | `Print_Magic_Left_Decimal_proc` | **rename?** |
| `0x2022` | `drv_render_char`, `gfx_fn_setup` | `Render_Font_Glyph_proc` | **rename?** |
| `0x2026` | `gfx_fn_draw` | `Capture_Screen_Rect_to_seg3_proc` | **rename?** |
| `0x2028` | `gfx_fn_restore` | `Put_Image_proc` | **rename?** |
| `0x202A` | `gfx_fn_clear` | `Render_String_FF_Terminated_proc` | **rename?** |
| `0x2040` | `drv_return_to_caller` | `Fade_To_Black_Dithered_proc` | **rename?** |
| `0x2044` | `drv_ds_copy` | `Reassemble_3_Planes_To_Packed_Bitmap_proc` | **rename?** |
| `0x3016` | `drv_draw_glyph` | `Load_Tiles_From_Small_Block_proc`, `Update_Local_Attribute_Cache_proc`, `draw_tile_to_screen_proc` | **rename?** |
| `0x4000` | `sprite_gfx_base` | `mman_cman_gfx` | **rename?** |
| `0x6000` | `game_data_base`, `tile_src_a` | `Cavern_Game_Init_proc`, `fman_gfx`, `or_blit_buffer`, `tman_gfx`, `town_entry_normal_proc` | **rename?** |
| `0x6004` | `fight_cb_range`, `script_step` | `monster_move_in_direction_proc`, `render_menu_dialog_proc` | **rename?** |
| `0x6006` | `fight_cb_alt_b`, `script_format_num` | `Check_collision_in_direction_proc`, `convert_ax_to_decimal_proc` | **rename?** |
| `0x6008` | `fight_cb_step_neg`, `script_display_page` | `move_monster_E_proc`, `show_yes_no_dialog_proc` | **rename?** |
| `0x600A` | `fight_cb_step_neg_2`, `script_take_item` | `check_gold_sufficient_proc`, `move_monster_NE_proc` | **rename?** |
| `0x600C` | `fight_cb_map_fwd`, `script_give_item` | `add_gold_to_hero_proc`, `move_monster_N_proc` | **rename?** |
| `0x600E` | `fight_cb_map_back` | `move_monster_NW_proc`, `render_menu_string_list_proc` | **rename?** |
| `0x6010` | `fight_cb_step_pos` | `move_monster_W_proc`, `select_from_menu_proc` | **rename?** |
| `0x6012` | `fight_cb_step_pos_2` | `move_monster_SW_proc`, `render_menu_list_scrolling_proc` | **rename?** |
| `0x6014` | `fight_cb_blocked` | `houseCursorShow_proc`, `move_monster_S_proc` | **rename?** |
| `0x6016` | `fight_cb_dist_check` | `move_monster_SE_proc`, `npcAnimation_proc` | **rename?** |
| `0x6018` | `fight_cb_aux_18` | `check_collision_E2_proc`, `houseCursorUp_proc` | **rename?** |
| `0x601A` | `fight_cb_aux_1a` | `check_collision_W2_proc`, `houseCursorDown_proc` | **rename?** |
| `0x601C` | `fight_cb_aux_1c` | `check_collision_N2_proc`, `restore_game_proc` | **rename?** |
| `0x6028` | `fight_cb_record_ofs` | `coords_in_ax_to_proximity_map_offset_in_di_proc` | **rename?** |
| `0x602A` | `fight_cb_mark_adj` | `wrap_map_from_above_proc` | **rename?** |
| `0x602C` | `fight_cb_tile_index` | `wrap_map_from_below_proc` | **rename?** |
| `0x602E` | `fight_cb_cmp_tile` | `if_passable_set_ZF_proc` | **rename?** |
| `0x6030` | `fight_cb_alt` | `Check_Monster_Ids_Two_Rows_Below_Monster_proc` | **rename?** |
| `0x6032` | `fight_cb_spawn` | `Check_Vertical_Distance_Between_Hero_And_Monster_proc` | **rename?** |
| `0x6034` | `fight_cb_fire` | `Hero_Hits_monster_proc` | **rename?** |
| `0x6036` | `fight_cb_anim_step` | `HorizDistToHero_35_proc` | **rename?** |
| `0x6038` | `fight_cb_hit_check` | `Get_Stats_proc` | **rename?** |
| `0x603A` | `fight_cb_despawn` | `Add_Projectile_To_Array_proc` | **rename?** |
| `0x603C` | `fight_cb_shutdown` | `Browse_Projectiles_proc` | **rename?** |
| `0x603E` | `fight_cb_spawn_alt` | `Find_Monsters_Near_Hero_proc` | **rename?** |
| `0x6040` | `fight_cb_aux_40` | `Move_Monster_NWE_Depending_On_Whats_Below_proc` | **rename?** |
| `0x8000` | `sprite_buf_ofs`, `tileset_buf_a` | `and_blit_buffer`, `packed_tile_ptr`, `tile_anim_count_table` | **rename?** |
| `0x8004` | `tileset_buf_b` | `tile_animation_replacement_table` | **rename?** |
| `0x8100` | `tile_pixel_base` | `packed_tile_graphics` | **rename?** |
| `0xA000` | `GAME_CODE_BASE`, `sprite_obj_tbl`, `vga_seg` | `Inventory_Screen_proc`, `Monster_AI_proc`, `word_A000` | **rename?** |
| `0xB000` | `herc_video_seg` | `sword_animation_gfx` | **rename?** |
| `0xC002` | `fight_state_max`, `gvar_proj_cnt` | `mapWidth`, `town_map_width` | **rename?** |
| `0xC00A` | `entity_list_ptr` | `doors_table_addr` | **rename?** |
| `0xC00F` | `tile_list_ptr` | `npc_array_addr` | **rename?** |
| `0xC010` | `enemy_attr_base`, `fight_slot_list`, `sprite_attr_base` | `monsters_table_addr` | **rename?** |
| `0xC012` | `sprite_attr_b` | `cavern_level` | **rename?** |
| `0xD000` | `tile_mask_data` | `sprite_transparency_masks` | **rename?** |
| `0xE000` | `pattern_base` | `proximity_map`, `viewport_buffer` | **rename?** |
| `0xE005` | `marker_buf` | `cache_bytes_ptr` | **rename?** |
| `0xE900` | `sprite_buf` | `viewport_buffer_28x19` | **rename?** |
| `0xED20` | `char_lookup`, `enemy_data_ext`, `sprite_idx_table`, `sprite_xlat_tbl` | `proximity_second_layer` | **rename?** |
| `0xEDA0` | `projectile_list` | `is_boss_dead` | **rename?** |
| `0xFF00` | `gvar_chunk_load_fn` | `fn_exit_far_ptr` | **rename?** |
| `0xFF04` | `gvar_old_int08_ofs` | `fn_timer_chain_ptr` | **rename?** |
| `0xFF08` | `gvar_timer_ticks` | `heartbeat_volume` | **rename?** |
| `0xFF09` | `gvar_key_released` | `exit_pending_flag` | **rename?** |
| `0xFF0A` | `gvar_last_key` | `joystick_enabled_flag` | **rename?** |
| `0xFF0B` | `gvar_key_state` | `byte_FF0B` | **rename?** |
| `0xFF0C` | `gvar_input_fn_ofs` | `fn_per_tick_callback` | **rename?** |
| `0xFF10` | `gvar_gfx_fn_ofs` | `fn_per_tick_callback2` | **rename?** |
| `0xFF14` | `gvar_gfx_mode` | `video_drv_id` | **rename?** |
| `0xFF15` | `gvar_game_phase` | `mt32_enabled` | **rename?** |
| `0xFF16` | `gvar_skip_flag` | `____Alt_Space` | **rename?** |
| `0xFF17` | `gvar_timer_flag` | `____right_left_down_up` | **rename?** |
| `0xFF18` | `gvar_timer_counter` | `F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter` | **rename?** |
| `0xFF1A` | `frame_timer`, `gvar_frame_timer`, `gvar_timer_byte`, `gvar_timer_lo`, `gvar_timer_ticks` | `frame_timer` | agree |
| `0xFF1B` | `gvar_anim_timer` | `anim_timer` | **rename?** |
| `0xFF1D` | `gvar_skip_input`, `gvar_state_a` | `spacebar_latch` | **rename?** |
| `0xFF1E` | `gvar_state_b` | `altkey_latch` | **rename?** |
| `0xFF1F` | `gvar_state_c` | `fn_per_tick_user_ptr` | **rename?** |
| `0xFF24` | `gvar_state_flag` | `byte_FF24` | **rename?** |
| `0xFF26` | `gvar_enable_all` | `byte_FF26` | **rename?** |
| `0xFF27` | `gvar_sound_flag` | `sound_fx_toggle_by_f2` | **rename?** |
| `0xFF28` | `gvar_key_pressed` | `music_channel_param` | **rename?** |
| `0xFF29` | `gvar_enter_key` | `Current_ASCII_Char` | **rename?** |
| `0xFF2A` | `gvar_map_ptr` | `proximity_start_tiles` | **rename?** |
| `0xFF2C` | `game_seg`, `gvar_game_seg` | `seg1` | **rename?** |
| `0xFF2E` | `gvar_death_flag` | `boss_being_hit` | **rename?** |
| `0xFF2F` | `flag_shadow`, `gvar_dir_toggle` | `sprite_flash_flag` | **rename?** |
| `0xFF30` | `gvar_completion` | `boss_is_dead` | **rename?** |
| `0xFF31` | `sprite_data_ptr` | `viewport_left_top_addr` | **rename?** |
| `0xFF33` | `anim_speed`, `gvar_save_filename`, `gvar_save_flag` | `speed_const` | **rename?** |
| `0xFF34` | `flag_equip_b` | `is_boss_cavern` | **rename?** |
| `0xFF35` | `enemy_counter`, `gvar_frame_cnt` | `hero_y_absolute` | **rename?** |
| `0xFF36` | `color_sel`, `gvar_enemy_cnt` | `hero_damage_this_frame` | **rename?** |
| `0xFF37` | `redraw_lock` | `hero_sprite_hidden` | **rename?** |
| `0xFF38` | `flag_shield`, `gvar_music_flag_a` | `squat_flag` | **rename?** |
| `0xFF39` | `flag_climbing`, `gvar_music_flag_b` | `on_rope_flags` | **rename?** |
| `0xFF3A` | `flag_riding`, `gvar_music_flag_c` | `hero_hidden_flag` | **rename?** |
| `0xFF3B` | `gvar_music_flag_d` | `joystick_calibrated_flag` | **rename?** |
| `0xFF3C` | `gvar_palette_flag` | `spell_active_flag` | **rename?** |
| `0xFF3D` | `equip_byte` | `jump_phase_flags` | **rename?** |
| `0xFF3F` | `hero_frame` | `shield_anim_phase` | **rename?** |
| `0xFF40` | `flag_hero_state`, `gvar_debug_mode` | `shield_anim_active` | **rename?** |
| `0xFF41` | `weapon_state` | `shield_variant_index` | **rename?** |
| `0xFF42` | `gvar_debug_val`, `shield_sel` | `slope_direction` | **rename?** |
| `0xFF43` | `gvar_joystick_flag`, `scroll_active` | `sword_swing_flag` | **rename?** |
| `0xFF44` | `restore_pending` | `ui_element_dirty` | **rename?** |
| `0xFF45` | `scroll_phase` | `sword_hit_type` | **rename?** |
| `0xFF46` | `scroll_step` | `sword_movement_phase` | **rename?** |
| `0xFF48` | `gvar_joy_cal_x` | `joystick_direction_bits` | **rename?** |
| `0xFF49` | `gvar_joy_cal_y` | `joystick_button_bits` | **rename?** |
| `0xFF4A` | `gvar_sub_frame` | `monster_index` | **rename?** |
| `0xFF4C` | `gvar_script_ip`, `gvar_script_ptr`, `gvar_state_ptr`, `script_cur_ptr` | `dialog_string_ptr` | **rename?** |
| `0xFF4E` | `gvar_init_flag_a`, `gvar_state_flg1`, `gvar_text_x`, `shop_flag_a` | `dialog_cursor_x` | **rename?** |
| `0xFF4F` | `gvar_init_flag_b`, `gvar_state_flg2`, `gvar_text_y`, `shop_flag_b` | `dialog_scroll_counter` | **rename?** |
| `0xFF50` | `gvar_credits_pos`, `gvar_frame_count`, `gvar_menu_step`, `gvar_timer_word`, `menu_frame_timer` | `tick_counter` | **rename?** |
| `0xFF52` | `gvar_col_byte`, `gvar_dlg_cols`, `gvar_name_maxlen`, `menu_item_count` | `menu_item_count` | agree |
| `0xFF53` | `gvar_dlg_rows`, `gvar_name_opt`, `gvar_row_byte`, `inventory_count` | `menu_max_items` | **rename?** |
| `0xFF54` | `gvar_dlg_pos`, `gvar_ui_dst_word`, `gvar_ui_pos`, `menu_pos_base` | `menu_base_addr` | **rename?** |
| `0xFF57` | `gvar_item_flag` | `menu_digits_render_flag` | **rename?** |
| `0xFF68` | `gvar_text_ofs` | `numeric_display_x_offset` | **rename?** |
| `0xFF6A` | `gvar_copy_width`, `gvar_tile_width` | `string_width_bytes` | **rename?** |
| `0xFF6C` | `gvar_save_name_buf` | `save_name` | **rename?** |
| `0xFF74` | `gvar_volume_a` | `keyboard_alt_mode_flag` | **rename?** |
| `0xFF75` | `gvar_spawn_fx_flag`, `gvar_volume`, `gvar_volume_b` | `soundFX_request` | **rename?** |
| `0xFF78` | `gvar_old_int09_raw` | `disk_swap_suppressed` | **rename?** |
| `0xFF79` | `gvar_old_int09_ofs` | `fn_kbd_chain_ptr` | **rename?** |

**Agreements: 2** | **Disagreements: 140**

## Disagreement summary (rename candidates)

Where IDA has a name our source doesn't use, consider adopting the IDA name
as primary (as alias) in the relevant shared .inc:

- `0x0`: `cga_buf_start, zero_offset` → consider IDA name `Cangrejo_Defeated, InitTitleScreen_proc, magic_grp_sprites`
- `0x80`: `ply_walk_speed` → consider IDA name `proximity_map_left_col_x`
- `0x83`: `ply_accel` → consider IDA name `hero_x_in_viewport`
- `0x85`: `drv_timer_flag` → consider IDA name `hero_gold_hi`
- `0x86`: `drv_time_param_a` → consider IDA name `hero_gold_lo`
- `0x8B`: `drv_time_param_b` → consider IDA name `hero_almas`
- `0x90`: `drv_text_src` → consider IDA name `hero_HP`
- `0x92`: `ply_jump_flag` → consider IDA name `sword_type`
- `0x93`: `drv_sprite_flag` → consider IDA name `shield_type`
- `0x94`: `drv_time_param_c` → consider IDA name `shield_HP`
- `0x9D`: `drv_frame_idx` → consider IDA name `current_magic_spell`
- `0xAB`: `drv_color_lut` → consider IDA name `spells_espada`
- `0x100`: `ISR_STUBS_BASE, isr_keyboard` → consider IDA name `int9_new_proc`
- `0x103`: `isr_timer` → consider IDA name `int8_new_proc`
- `0x106`: `isr_critical` → consider IDA name `int24_new_proc`
- `0x109`: `isr_music` → consider IDA name `int61_new_proc`
- `0x10C`: `sar_loader_fn` → consider IDA name `res_dispatcher_proc`
- `0x2000`: `drv_fill_rect, gfx_screen_base` → consider IDA name `Draw_Bordered_Rectangle_proc`
- `0x2002`: `drv_screen_init_a` → consider IDA name `Clear_Viewport_proc`
- `0x2008`: `drv_palette_push` → consider IDA name `Draw_Hero_Health_proc`
- `0x200C`: `fight_cb_prep` → consider IDA name `Draw_Boss_Health_proc`
- `0x2010`: `drv_load_msg_header` → consider IDA name `Render_Pascal_String_1_proc`
- `0x2012`: `drv_screen_init_b` → consider IDA name `Clear_Place_Enemy_Bar_proc`
- `0x2016`: `drv_frame_commit` → consider IDA name `Print_Gold_Decimal_proc`
- `0x2018`: `drv_anim_step` → consider IDA name `Print_Magic_Left_Decimal_proc`
- `0x2022`: `drv_render_char, gfx_fn_setup` → consider IDA name `Render_Font_Glyph_proc`
- `0x2026`: `gfx_fn_draw` → consider IDA name `Capture_Screen_Rect_to_seg3_proc`
- `0x2028`: `gfx_fn_restore` → consider IDA name `Put_Image_proc`
- `0x202A`: `gfx_fn_clear` → consider IDA name `Render_String_FF_Terminated_proc`
- `0x2040`: `drv_return_to_caller` → consider IDA name `Fade_To_Black_Dithered_proc`
- `0x2044`: `drv_ds_copy` → consider IDA name `Reassemble_3_Planes_To_Packed_Bitmap_proc`
- `0x3016`: `drv_draw_glyph` → consider IDA name `Load_Tiles_From_Small_Block_proc, Update_Local_Attribute_Cache_proc, draw_tile_to_screen_proc`
- `0x4000`: `sprite_gfx_base` → consider IDA name `mman_cman_gfx`
- `0x6000`: `game_data_base, tile_src_a` → consider IDA name `Cavern_Game_Init_proc, fman_gfx, or_blit_buffer, tman_gfx, town_entry_normal_proc`
- `0x6004`: `fight_cb_range, script_step` → consider IDA name `monster_move_in_direction_proc, render_menu_dialog_proc`
- `0x6006`: `fight_cb_alt_b, script_format_num` → consider IDA name `Check_collision_in_direction_proc, convert_ax_to_decimal_proc`
- `0x6008`: `fight_cb_step_neg, script_display_page` → consider IDA name `move_monster_E_proc, show_yes_no_dialog_proc`
- `0x600A`: `fight_cb_step_neg_2, script_take_item` → consider IDA name `check_gold_sufficient_proc, move_monster_NE_proc`
- `0x600C`: `fight_cb_map_fwd, script_give_item` → consider IDA name `add_gold_to_hero_proc, move_monster_N_proc`
- `0x600E`: `fight_cb_map_back` → consider IDA name `move_monster_NW_proc, render_menu_string_list_proc`
- `0x6010`: `fight_cb_step_pos` → consider IDA name `move_monster_W_proc, select_from_menu_proc`
- `0x6012`: `fight_cb_step_pos_2` → consider IDA name `move_monster_SW_proc, render_menu_list_scrolling_proc`
- `0x6014`: `fight_cb_blocked` → consider IDA name `houseCursorShow_proc, move_monster_S_proc`
- `0x6016`: `fight_cb_dist_check` → consider IDA name `move_monster_SE_proc, npcAnimation_proc`
- `0x6018`: `fight_cb_aux_18` → consider IDA name `check_collision_E2_proc, houseCursorUp_proc`
- `0x601A`: `fight_cb_aux_1a` → consider IDA name `check_collision_W2_proc, houseCursorDown_proc`
- `0x601C`: `fight_cb_aux_1c` → consider IDA name `check_collision_N2_proc, restore_game_proc`
- `0x6028`: `fight_cb_record_ofs` → consider IDA name `coords_in_ax_to_proximity_map_offset_in_di_proc`
- `0x602A`: `fight_cb_mark_adj` → consider IDA name `wrap_map_from_above_proc`
- `0x602C`: `fight_cb_tile_index` → consider IDA name `wrap_map_from_below_proc`
- `0x602E`: `fight_cb_cmp_tile` → consider IDA name `if_passable_set_ZF_proc`
- `0x6030`: `fight_cb_alt` → consider IDA name `Check_Monster_Ids_Two_Rows_Below_Monster_proc`
- `0x6032`: `fight_cb_spawn` → consider IDA name `Check_Vertical_Distance_Between_Hero_And_Monster_proc`
- `0x6034`: `fight_cb_fire` → consider IDA name `Hero_Hits_monster_proc`
- `0x6036`: `fight_cb_anim_step` → consider IDA name `HorizDistToHero_35_proc`
- `0x6038`: `fight_cb_hit_check` → consider IDA name `Get_Stats_proc`
- `0x603A`: `fight_cb_despawn` → consider IDA name `Add_Projectile_To_Array_proc`
- `0x603C`: `fight_cb_shutdown` → consider IDA name `Browse_Projectiles_proc`
- `0x603E`: `fight_cb_spawn_alt` → consider IDA name `Find_Monsters_Near_Hero_proc`
- `0x6040`: `fight_cb_aux_40` → consider IDA name `Move_Monster_NWE_Depending_On_Whats_Below_proc`
- `0x8000`: `sprite_buf_ofs, tileset_buf_a` → consider IDA name `and_blit_buffer, packed_tile_ptr, tile_anim_count_table`
- `0x8004`: `tileset_buf_b` → consider IDA name `tile_animation_replacement_table`
- `0x8100`: `tile_pixel_base` → consider IDA name `packed_tile_graphics`
- `0xA000`: `GAME_CODE_BASE, sprite_obj_tbl, vga_seg` → consider IDA name `Inventory_Screen_proc, Monster_AI_proc, word_A000`
- `0xB000`: `herc_video_seg` → consider IDA name `sword_animation_gfx`
- `0xC002`: `fight_state_max, gvar_proj_cnt` → consider IDA name `mapWidth, town_map_width`
- `0xC00A`: `entity_list_ptr` → consider IDA name `doors_table_addr`
- `0xC00F`: `tile_list_ptr` → consider IDA name `npc_array_addr`
- `0xC010`: `enemy_attr_base, fight_slot_list, sprite_attr_base` → consider IDA name `monsters_table_addr`
- `0xC012`: `sprite_attr_b` → consider IDA name `cavern_level`
- `0xD000`: `tile_mask_data` → consider IDA name `sprite_transparency_masks`
- `0xE000`: `pattern_base` → consider IDA name `proximity_map, viewport_buffer`
- `0xE005`: `marker_buf` → consider IDA name `cache_bytes_ptr`
- `0xE900`: `sprite_buf` → consider IDA name `viewport_buffer_28x19`
- `0xED20`: `char_lookup, enemy_data_ext, sprite_idx_table, sprite_xlat_tbl` → consider IDA name `proximity_second_layer`
- `0xEDA0`: `projectile_list` → consider IDA name `is_boss_dead`
- `0xFF00`: `gvar_chunk_load_fn` → consider IDA name `fn_exit_far_ptr`
- `0xFF04`: `gvar_old_int08_ofs` → consider IDA name `fn_timer_chain_ptr`
- `0xFF08`: `gvar_timer_ticks` → consider IDA name `heartbeat_volume`
- `0xFF09`: `gvar_key_released` → consider IDA name `exit_pending_flag`
- `0xFF0A`: `gvar_last_key` → consider IDA name `joystick_enabled_flag`
- `0xFF0B`: `gvar_key_state` → consider IDA name `byte_FF0B`
- `0xFF0C`: `gvar_input_fn_ofs` → consider IDA name `fn_per_tick_callback`
- `0xFF10`: `gvar_gfx_fn_ofs` → consider IDA name `fn_per_tick_callback2`
- `0xFF14`: `gvar_gfx_mode` → consider IDA name `video_drv_id`
- `0xFF15`: `gvar_game_phase` → consider IDA name `mt32_enabled`
- `0xFF16`: `gvar_skip_flag` → consider IDA name `____Alt_Space`
- `0xFF17`: `gvar_timer_flag` → consider IDA name `____right_left_down_up`
- `0xFF18`: `gvar_timer_counter` → consider IDA name `F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter`
- `0xFF1B`: `gvar_anim_timer` → consider IDA name `anim_timer`
- `0xFF1D`: `gvar_skip_input, gvar_state_a` → consider IDA name `spacebar_latch`
- `0xFF1E`: `gvar_state_b` → consider IDA name `altkey_latch`
- `0xFF1F`: `gvar_state_c` → consider IDA name `fn_per_tick_user_ptr`
- `0xFF24`: `gvar_state_flag` → consider IDA name `byte_FF24`
- `0xFF26`: `gvar_enable_all` → consider IDA name `byte_FF26`
- `0xFF27`: `gvar_sound_flag` → consider IDA name `sound_fx_toggle_by_f2`
- `0xFF28`: `gvar_key_pressed` → consider IDA name `music_channel_param`
- `0xFF29`: `gvar_enter_key` → consider IDA name `Current_ASCII_Char`
- `0xFF2A`: `gvar_map_ptr` → consider IDA name `proximity_start_tiles`
- `0xFF2C`: `game_seg, gvar_game_seg` → consider IDA name `seg1`
- `0xFF2E`: `gvar_death_flag` → consider IDA name `boss_being_hit`
- `0xFF2F`: `flag_shadow, gvar_dir_toggle` → consider IDA name `sprite_flash_flag`
- `0xFF30`: `gvar_completion` → consider IDA name `boss_is_dead`
- `0xFF31`: `sprite_data_ptr` → consider IDA name `viewport_left_top_addr`
- `0xFF33`: `anim_speed, gvar_save_filename, gvar_save_flag` → consider IDA name `speed_const`
- `0xFF34`: `flag_equip_b` → consider IDA name `is_boss_cavern`
- `0xFF35`: `enemy_counter, gvar_frame_cnt` → consider IDA name `hero_y_absolute`
- `0xFF36`: `color_sel, gvar_enemy_cnt` → consider IDA name `hero_damage_this_frame`
- `0xFF37`: `redraw_lock` → consider IDA name `hero_sprite_hidden`
- `0xFF38`: `flag_shield, gvar_music_flag_a` → consider IDA name `squat_flag`
- `0xFF39`: `flag_climbing, gvar_music_flag_b` → consider IDA name `on_rope_flags`
- `0xFF3A`: `flag_riding, gvar_music_flag_c` → consider IDA name `hero_hidden_flag`
- `0xFF3B`: `gvar_music_flag_d` → consider IDA name `joystick_calibrated_flag`
- `0xFF3C`: `gvar_palette_flag` → consider IDA name `spell_active_flag`
- `0xFF3D`: `equip_byte` → consider IDA name `jump_phase_flags`
- `0xFF3F`: `hero_frame` → consider IDA name `shield_anim_phase`
- `0xFF40`: `flag_hero_state, gvar_debug_mode` → consider IDA name `shield_anim_active`
- `0xFF41`: `weapon_state` → consider IDA name `shield_variant_index`
- `0xFF42`: `gvar_debug_val, shield_sel` → consider IDA name `slope_direction`
- `0xFF43`: `gvar_joystick_flag, scroll_active` → consider IDA name `sword_swing_flag`
- `0xFF44`: `restore_pending` → consider IDA name `ui_element_dirty`
- `0xFF45`: `scroll_phase` → consider IDA name `sword_hit_type`
- `0xFF46`: `scroll_step` → consider IDA name `sword_movement_phase`
- `0xFF48`: `gvar_joy_cal_x` → consider IDA name `joystick_direction_bits`
- `0xFF49`: `gvar_joy_cal_y` → consider IDA name `joystick_button_bits`
- `0xFF4A`: `gvar_sub_frame` → consider IDA name `monster_index`
- `0xFF4C`: `gvar_script_ip, gvar_script_ptr, gvar_state_ptr, script_cur_ptr` → consider IDA name `dialog_string_ptr`
- `0xFF4E`: `gvar_init_flag_a, gvar_state_flg1, gvar_text_x, shop_flag_a` → consider IDA name `dialog_cursor_x`
- `0xFF4F`: `gvar_init_flag_b, gvar_state_flg2, gvar_text_y, shop_flag_b` → consider IDA name `dialog_scroll_counter`
- `0xFF50`: `gvar_credits_pos, gvar_frame_count, gvar_menu_step, gvar_timer_word, menu_frame_timer` → consider IDA name `tick_counter`
- `0xFF53`: `gvar_dlg_rows, gvar_name_opt, gvar_row_byte, inventory_count` → consider IDA name `menu_max_items`
- `0xFF54`: `gvar_dlg_pos, gvar_ui_dst_word, gvar_ui_pos, menu_pos_base` → consider IDA name `menu_base_addr`
- `0xFF57`: `gvar_item_flag` → consider IDA name `menu_digits_render_flag`
- `0xFF68`: `gvar_text_ofs` → consider IDA name `numeric_display_x_offset`
- `0xFF6A`: `gvar_copy_width, gvar_tile_width` → consider IDA name `string_width_bytes`
- `0xFF6C`: `gvar_save_name_buf` → consider IDA name `save_name`
- `0xFF74`: `gvar_volume_a` → consider IDA name `keyboard_alt_mode_flag`
- `0xFF75`: `gvar_spawn_fx_flag, gvar_volume, gvar_volume_b` → consider IDA name `soundFX_request`
- `0xFF78`: `gvar_old_int09_raw` → consider IDA name `disk_swap_suppressed`
- `0xFF79`: `gvar_old_int09_ofs` → consider IDA name `fn_kbd_chain_ptr`

## Symbols only in IDA (potential coverage gaps in our .inc files)

IDA defines these names at addresses we don't have any name for. Adopting
them would extend our shared-symbol coverage.

- `(48+14*320)`: `viewport_top_left_vram_addr`
- `0x2`: `malicia_items`
- `0x3`: `malicia_items_1`
- `0x4`: `byte_4`
- `0x5`: `spoke_to_king`
- `0x6`: `entered_cavern_first_time`
- `0x8`: `Pulpo_Defeated`
- `0x9`: `peligro_items`
- `0xA`: `peligro_items_1`
- `0x10`: `Pollo_Defeated`
- `0x12`: `madera_items`
- `0x13`: `riza_items`
- `0x18`: `Agar_Defeated`
- `0x1A`: `glacial_items`
- `0x1B`: `escarcha_items`
- `0x1C`: `escarcha_items_1`
- `0x20`: `Vista_Defeated`
- `0x22`: `corroer_items`
- `0x23`: `cementar_items`
- `0x24`: `cementar_items_1`
- `0x28`: `Tarso_Defeated`
- `0x2A`: `tesoro_items`
- `0x2B`: `plata_items`
- `0x2C`: `plata_items_1`
- `0x2D`: `plata_items_2`
- `0x30`: `Paguro_Defeated`
- `0x32`: `Dragon_Defeated`
- `0x34`: `caliente_items`
- `0x35`: `caliente_items_1`
- `0x36`: `caliente_items_2`
- `0x42`: `absor_items`
- `0x43`: `milagro_items`
- `0x44`: `desleal_items`
- `0x45`: `falter_items`
- `0x49`: `is_death_already_processed`
- `0x7F`: `hero_invincibility`
- `0x82`: `viewport_top_row_y`
- `0x84`: `hero_head_y_in_viewport`
- `0x88`: `bank_gold_hi`
- `0x89`: `bank_gold_lo`
- `0x8D`: `hero_level`
- `0x8E`: `hero_xp`
- `0x96`: `shield_max_HP`
- `0x98`: `keys_amount`
- `0x99`: `lion_head_keys`
- `0x9A`: `elf_crest`
- `0x9B`: `crest_of_glory`
- `0x9C`: `hero_crest`
- `0x9E`: `current_accessory`
- `0x9F`: `byte_9F`
- `0xA0`: `Tears_of_Esmesanti_count`
- `0xA1`: `Feruza_Shoes`
- `0xA2`: `Pirika_Shoes`
- `0xA3`: `Silkarn_Shoes`
- `0xA4`: `Ruzeria_Shoes`
- `0xA5`: `Asbestos_Cape`
- `0xA6`: `magic_items`
- `0xAC`: `spells_saeta`
- `0xAD`: `spells_fuego`
- `0xAE`: `spells_lanzar`
- `0xAF`: `spells_rascar`
- `0xB0`: `spells_agua`
- `0xB1`: `spells_guerra`
- `0xB2`: `heroMaxHp`
- `0xB4`: `espada_count`
- `0xB5`: `saeta_count`
- `0xB6`: `fuego_count`
- `0xB7`: `lanzar_count`
- `0xB8`: `rascar_count`
- `0xB9`: `agua_count`
- `0xBA`: `guerra_count`
- `0xBB`: `espada_active`
- `0xBC`: `saeta_active`
- `0xBD`: `fuego_active`
- `0xBE`: `lanzar_active`
- `0xBF`: `rascar_active`
- `0xC0`: `agua_active`
- `0xC1`: `guerra_active`
- `0xC2`: `facing_direction`
- `0xC3`: `is_left_run`
- ...and 120 more