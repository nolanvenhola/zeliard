# Master section inventory � all .asm files

63 files. Each section listed once. Use `[ ]` checkboxes to track which need their true name/nature determined.

## working/core/game.asm  (19 sections)

- [x] L213   `run_game_main`  *(proc)*
- [x] L460   `ref_font_grp`  *(data)*
- [x] L461   `ref_mole`  *(data)*
- [x] L462   `ref_itemp`  *(data)*
- [x] L463   `ref_select`  *(data)*
- [x] L464   `ref_magic`  *(data)*
- [x] L465   `ref_sword`  *(data)*
- [x] L466   `ref_fight`  *(data)*
- [x] L467   `ref_town`  *(data)*
- [x] L468   `ref_opdemo`  *(data)*
- [x] L472   `gfx_mode_tbl_ega_lbl`  *(label word)*
- [x] L538   `has_tracks`  *(label word)*
- [x] L533   `load_music_tracks`  *(proc)*
- [x] L554   `not_bg_music`  *(label word)*
- [x] L589   `set_vga_palette`  *(proc)*
- [x] L609   `ega_palette_handler`  *(label word)*
- [x] L697   `tga_palette_handler`  *(label byte)*
- [x] L700   `hgc_palette_handler`  *(label dword)*
- [x] L700   `hgc_palette_handler`  *(label word)*

## working/core/zeliad.asm  (55 sections)

- [x] L133   `run_zeliad_main`  *(proc)*
- [x] L523   `flush_keyboard`  *(proc)*
- [x] L543   `read_config_line`  *(proc)*
- [x] L591   `parse_graphics_mode`  *(proc)*
- [x] L650   `mode_4char_table`  *(data)*
- [x] L652   `mode_3char_table`  *(data)*
- [x] L663   `parse_music_driver`  *(proc)*
- [x] L688   `str_mscmt_drv`  *(data)*
- [x] L694   `parse_joystick_name`  *(proc)*
- [x] L714   `parse_joystick_enable`  *(proc)*
- [x] L737   `str_yes`  *(data)*
- [x] L738   `str_no`  *(data)*
- [x] L754   `find_colon_in_line`  *(proc)*
- [x] L779   `load_driver_file`  *(proc)*
- [x] L819   `display_file_error`  *(proc)*
- [x] L882   `set_video_mode`  *(proc)*
- [x] L888   `video_mode_table`  *(data)*
- [x] L958   `hgc_crt_params`  *(data)*
- [x] L965   `ctrl_c_handler`  *(proc)*
- [x] L975   `parse_command_line`  *(proc)*
- [x] L1029  `str_game_title`  *(data)*
- [x] L1035  `str_not_supported`  *(data)*
- [x] L1036  `str_special_mode`  *(data)*
- [x] L1037  `str_not_enough_mem`  *(data)*
- [x] L1039  `str_memory_error`  *(data)*
- [x] L1040  `str_thank_you`  *(data)*
- [x] L1042  `str_file_error`  *(data)*
- [x] L1043  `str_error_type`  *(data)*
- [x] L1044  `str_file_not_found`  *(data)*
- [x] L1045  `str_disk_error`  *(data)*
- [x] L1046  `str_user_file_error`  *(data)*
- [x] L1047  `str_cfg_error`  *(data)*
- [x] L1054  `hex_digits_hi`  *(data)*
- [x] L1055  `hex_digits_lo`  *(data)*
- [x] L1057  `cfg_filename`  *(data)*
- [x] L1058  `mtinit_filename`  *(data)*
- [x] L1061  `driver_offset_table`  *(data)*
- [x] L1101  `cmdline_savefile`  *(data)*
- [x] L1104  `music_driver_name`  *(data)*
- [x] L1107  `joystick_driver_name`  *(data)*
- [x] L1110  `game_entry_ofs`  *(data)*
- [x] L1111  `game_entry_seg`  *(data)*
- [x] L1113  `saved_int08_ofs`  *(data)*
- [x] L1114  `saved_int09_ofs`  *(data)*
- [x] L1115  `saved_int60_ofs`  *(data)*
- [x] L1116  `saved_int61_ofs`  *(data)*
- [x] L1117  `saved_int61_seg`  *(data)*
- [x] L1119  `has_savefile`  *(data)*
- [x] L1120  `saved_sp`  *(data)*
- [x] L1121  `saved_ss`  *(data)*
- [x] L1141  `graphics_mode`  *(data)*
- [x] L1142  `mt32_enabled`  *(data)*
- [x] L1149  `joystick_enabled`  *(data)*
- [x] L1150  `cfg_line_length`  *(data)*
- [x] L1151  `cfg_line_buffer`  *(data)*

## working/drivers/gmcga.asm  (19 sections)

- [x] L136   `run_gmcga_main`  *(proc)*
- [x] L228   `fill_horizontal_line`  *(proc)*
- [x] L252   `clear_screen`  *(proc)*
- [x] L438   `plot_pixel`  *(proc)*
- [x] L605   `calc_text_width`  *(proc)*
- [x] L628   `fill_vertical_line`  *(proc)*
- [x] L729   `render_text_char`  *(proc)*
- [x] L869   `init_timestamp`  *(proc)*
- [x] L890   `convert_time_to_bcd`  *(proc)*
- [x] L917   `modulo_divide_bcd`  *(proc)*
- [x] L942   `int_divide_bcd`  *(proc)*
- [x] L952   `render_tilemap_large`  *(proc)*
- [x] L993   `decode_bitplane_tile`  *(proc)*
- [x] L1257  `render_tilemap_small`  *(proc)*
- [x] L1323  `extract_bitplane_pixels`  *(proc)*
- [x] L1363  `render_text_char_alt`  *(proc)*
- [x] L1435  `expand_font_bits`  *(proc)*
- [x] L1721  `fill_rectangle`  *(proc)*
- [x] L1933  `process_sprite_row`  *(proc)*

## working/drivers/gmega.asm  (16 sections)

- [x] L129   `run_gmega_main`  *(proc)*
- [x] L220   `fill_horizontal_line`  *(proc)*
- [x] L284   `clear_screen`  *(proc)*
- [x] L486   `plot_pixel`  *(proc)*
- [x] L680   `calc_text_width`  *(proc)*
- [x] L703   `fill_vertical_line`  *(proc)*
- [x] L796   `render_text_char`  *(proc)*
- [x] L942   `init_timestamp`  *(proc)*
- [x] L965   `convert_time_to_bcd`  *(proc)*
- [x] L992   `modulo_divide_bcd`  *(proc)*
- [x] L1017  `int_divide_bcd`  *(proc)*
- [x] L1027  `render_tilemap_large`  *(proc)*
- [x] L1062  `decode_bitplane_tile`  *(proc)*
- [x] L1342  `render_tilemap_small`  *(proc)*
- [x] L1439  `render_text_char_alt`  *(proc)*
- [x] L1809  `fill_rectangle`  *(proc)*

## working/drivers/gmhgc.asm  (22 sections)

- [x] L127   `run_gmhgc_main`  *(proc)*
- [x] L221   `fill_horizontal_line`  *(proc)*
- [x] L259   `clear_screen`  *(proc)*
- [x] L281   `clear_screen_row`  *(proc)*
- [x] L403   `fade_screen_row`  *(proc)*
- [x] L489   `plot_pixel`  *(proc)*
- [x] L666   `calc_text_width`  *(proc)*
- [x] L689   `fill_vertical_line`  *(proc)*
- [x] L778   `render_text_char`  *(proc)*
- [x] L924   `init_timestamp`  *(proc)*
- [x] L946   `convert_time_to_bcd`  *(proc)*
- [x] L973   `modulo_divide_bcd`  *(proc)*
- [x] L998   `int_divide_bcd`  *(proc)*
- [x] L1008  `render_tilemap_large`  *(proc)*
- [x] L1047  `decode_bitplane_tile`  *(proc)*
- [x] L1324  `render_tilemap_small`  *(proc)*
- [x] L1395  `extract_bitplane_pixels`  *(proc)*
- [x] L1433  `render_text_char_alt`  *(proc)*
- [x] L1519  `expand_char_bits_2x`  *(proc)*
- [x] L1789  `fill_rectangle`  *(proc)*
- [x] L1933  `calc_hgc_address`  *(proc)*
- [x] L1984  `process_sprite_row`  *(proc)*

## working/drivers/gmmcga.asm  (20 sections)

- [x] L122   `run_gmmcga_main`  *(proc)*
- [x] L223   `fill_horizontal_line`  *(proc)*
- [x] L303   `font_render_code`  *(data)*
- [x] L407   `plot_pixel`  *(proc)*
- [x] L539   `calc_text_width`  *(proc)*
- [x] L554   `fill_vertical_line`  *(proc)*
- [x] L635   `render_text_char`  *(proc)*
- [x] L747   `init_timestamp`  *(proc)*
- [x] L768   `convert_time_to_bcd`  *(proc)*
- [x] L795   `modulo_divide_bcd`  *(proc)*
- [x] L820   `int_divide_bcd`  *(proc)*
- [x] L830   `render_tilemap_large`  *(proc)*
- [x] L878   `decode_bitplane_tile`  *(proc)*
- [x] L1111  `render_tilemap_small`  *(proc)*
- [x] L1152  `extract_bitplane_pixels`  *(proc)*
- [x] L1177  `render_text_char_alt`  *(proc)*
- [x] L1455  `fill_rectangle`  *(proc)*
- [x] L1649  `process_sprite_row`  *(proc)*
- [x] L1671  `decode_bitplane_to_pixels`  *(proc)*
- [x] L1696  `extract_bitplane_bit`  *(proc)*

## working/drivers/gmtga.asm  (19 sections)

- [x] L95    `run_gmtga_main`  *(proc)*
- [x] L187   `fill_horizontal_line`  *(proc)*
- [x] L211   `clear_screen`  *(proc)*
- [x] L437   `plot_pixel`  *(proc)*
- [x] L618   `calc_text_width`  *(proc)*
- [x] L641   `fill_vertical_line`  *(proc)*
- [x] L742   `render_text_char`  *(proc)*
- [x] L838   `extract_bitplane_bit`  *(proc)*
- [x] L963   `convert_time_to_bcd`  *(proc)*
- [x] L990   `modulo_divide_bcd`  *(proc)*
- [x] L1015  `int_divide_bcd`  *(proc)*
- [x] L1025  `render_tilemap_large`  *(proc)*
- [x] L1065  `decode_bitplane_tile`  *(proc)*
- [x] L1327  `render_tilemap_small`  *(proc)*
- [x] L1384  `extract_bitplane_pixels`  *(proc)*
- [x] L1430  `render_text_char_alt`  *(proc)*
- [x] L1773  `fill_rectangle`  *(proc)*
- [x] L1973  `process_sprite_row`  *(proc)*
- [x] L2002  `decode_bitplane_to_pixels`  *(proc)*

## working/drivers/stdply.asm  (97 sections)

- [x] L53    `run_stdply_main`  *(proc)*
- [x] L64    `key_map_table`  *(data)*
- [x] L87    `starting_position_in_town`  *(data)*
- [x] L88    `map_scroll_row`  *(data)*
- [x] L103   `screen_position`  *(data)*
- [ ] L104   `fight_player_col`  *(data)*
- [x] L109   `gold_carried_x65536`  *(data)*
- [x] L110   `gold_carried_x1`  *(data)*
- [x] L111   `gold_carried_x256`  *(data)*
- [x] L117   `gold_in_bank_x65536`  *(data)*
- [x] L118   `gold_in_bank_x1`  *(data)*
- [x] L123   `player_almas`  *(data)*
- [x] L128   `hero_level`  *(data)*
- [x] L130   `experience`  *(data)*
- [x] L137   `player_HP`  *(data)*
- [x] L138   `sword`  *(data)*
- [x] L139   `shield`  *(data)*
- [x] L147   `shield_HP`  *(data)*
- [x] L153   `shield_max_HP`  *(data)*
- [x] L155   `keys_normal`  *(data)*
- [x] L156   `keys_lion`  *(data)*
- [x] L157   `crest_elf`  *(data)*
- [x] L158   `crest_glory`  *(data)*
- [x] L159   `crest_hero`  *(data)*
- [x] L166   `selected_spell`  *(data)*
- [x] L170   `selected_accessory`  *(data)*
- [ ] L171   `stat_X9F`  *(data)*
- [x] L177   `tears_of_esmesanti_count`  *(data)*
- [x] L184   `accessory_slot_1`  *(data)*
- [x] L185   `accessory_slot_2`  *(data)*
- [x] L186   `accessory_slot_3`  *(data)*
- [x] L187   `accessory_slot_4`  *(data)*
- [x] L188   `accessory_slot_5`  *(data)*
- [x] L195   `item_slot_1`  *(data)*
- [x] L196   `item_slot_2`  *(data)*
- [x] L197   `item_slot_3`  *(data)*
- [x] L198   `item_slot_4`  *(data)*
- [x] L199   `item_slot_5`  *(data)*
- [x] L214   `spell_charge_espada`  *(data)*
- [x] L215   `spell_charge_saeta`  *(data)*
- [x] L216   `spell_charge_fuego`  *(data)*
- [x] L217   `spell_charge_lanzar`  *(data)*
- [x] L218   `spell_charge_rascar`  *(data)*
- [x] L219   `spell_charge_agua`  *(data)*
- [x] L220   `spell_charge_guerra`  *(data)*
- [x] L228   `spell_charge_max_espada`  *(data)*
- [x] L229   `spell_charge_max_saeta`  *(data)*
- [x] L230   `spell_charge_max_fuego`  *(data)*
- [x] L231   `spell_charge_max_lanzar`  *(data)*
- [x] L232   `spell_charge_max_rascar`  *(data)*
- [x] L233   `spell_charge_max_agua`  *(data)*
- [x] L234   `spell_charge_max_guerra`  *(data)*
- [x] L251   `spell_known_espada`  *(data)*
- [x] L252   `spell_known_saeta`  *(data)*
- [x] L253   `spell_known_fuego`  *(data)*
- [x] L254   `spell_known_lanzar`  *(data)*
- [x] L255   `spell_known_rascar`  *(data)*
- [x] L256   `spell_known_agua`  *(data)*
- [x] L257   `spell_known_guerra`  *(data)*
- [x] L258   `facing_direction`  *(data)*
- [x] L259   `boss_intro_flag`  *(data)*
- [x] L271   `save_sage`  *(data)*
- [x] L272   `last_sage_visited`  *(data)*
- [x] L276   `heal_pulse_count`  *(data)*
- [ ] L278   `current_level_idx`  *(data)*
- [x] L295   `magic_shop_inventory_muralla`  *(data)*
- [x] L296   `magic_shop_inventory_satono`  *(data)*
- [x] L297   `magic_shop_inventory_bosque`  *(data)*
- [x] L298   `magic_shop_inventory_helada`  *(data)*
- [x] L299   `magic_shop_inventory_tumba`  *(data)*
- [x] L300   `magic_shop_inventory_dorado`  *(data)*
- [x] L301   `magic_shop_inventory_llama`  *(data)*
- [x] L302   `magic_shop_inventory_pureza`  *(data)*
- [x] L303   `magic_shop_inventory_esco`  *(data)*
- [x] L308   `weapon_shop_swords_muralla`  *(data)*
- [x] L309   `weapon_shop_swords_satono`  *(data)*
- [x] L310   `weapon_shop_swords_bosque`  *(data)*
- [x] L311   `weapon_shop_swords_helada`  *(data)*
- [x] L312   `weapon_shop_swords_tumba`  *(data)*
- [x] L313   `weapon_shop_swords_dorado`  *(data)*
- [x] L314   `weapon_shop_swords_llama`  *(data)*
- [x] L315   `weapon_shop_swords_pureza`  *(data)*
- [x] L316   `weapon_shop_swords_esco`  *(data)*
- [x] L319   `weapon_shop_shields_muralla`  *(data)*
- [x] L320   `weapon_shop_shields_satono`  *(data)*
- [x] L321   `weapon_shop_shields_bosque`  *(data)*
- [x] L322   `weapon_shop_shields_helada`  *(data)*
- [x] L323   `weapon_shop_shields_tumba`  *(data)*
- [x] L324   `weapon_shop_shields_dorado`  *(data)*
- [x] L325   `weapon_shop_shields_llama`  *(data)*
- [x] L326   `weapon_shop_shields_pureza`  *(data)*
- [x] L327   `weapon_shop_shields_esco`  *(data)*
- [x] L333   `key_count`  *(data)*
- [x] L334   `sages_spoken_bitmap`  *(data)*
- [ ] L335   `scene_trans_request`  *(data)*
- [ ] L336   `gvar_pose_idx`  *(data)*
- [x] L337   `init_complete_flag`  *(data)*

## working/drivers/stick.asm  (33 sections)

- [x] L142   `run_stick_main`  *(proc)*
- [x] L167   `handle_pause_key`  *(proc)*
- [x] L204   `poll_joystick_buttons`  *(proc)*
- [x] L220   `decode_joystick_bits`  *(proc)*
- [x] L266   `handle_special_keys`  *(proc)*
- [x] L346   `tis_chain_int08`  *(label byte)*
- [x] L360   `kbd_irq_handler`  *(label byte)*
- [x] L423   `process_scancode`  *(proc)*
- [x] L637   `dispatch_extended_key`  *(proc)*
- [x] L704   `calibrate_joystick`  *(proc)*
- [x] L761   `calc_joystick_deadzone`  *(proc)*
- [x] L923   `draw_screen_element`  *(proc)*
- [x] L1000  `wait_for_digit_or_esc`  *(proc)*
- [x] L1038  `joy_calibrate_request`  *(proc)*
- [x] L1154  `enter_pause_menu_and_draw`  *(proc)*
- [x] L1158  `draw_pause_menu_box`  *(proc)*
- [x] L1170  `restore_pause_menu_bg`  *(proc)*
- [x] L1178  `flush_dos_kbd_buffer`  *(proc)*
- [x] L1277  `int60_dispatch_active`  *(label word)*
- [x] L1420  `herc_seg_table`  *(data)*
- [x] L1516  `fio_open_savefile_retry`  *(proc)*
- [x] L1653  `fio_read_done`  *(label byte)*
- [x] L1684  `fio_rw_done`  *(label byte)*
- [x] L1675  `fio_read_write_block`  *(proc)*
- [x] L1689  `fio_close_file`  *(proc)*
- [x] L1713  `fio_load_decompressed`  *(proc)*
- [x] L1751  `decompress_anchor_loop_a`  *(proc)*
- [x] L1819  `decompress_anchor_loop_b`  *(proc)*
- [x] L1906  `decompress_anchor_loop_c`  *(proc)*
- [x] L2033  `savefile_desc_ptr`  *(data)*
- [x] L2034  `file_read_buf_ptr`  *(data)*
- [x] L2035  `file_read_count`  *(data)*
- [x] L2036  `file_sector_ptr`  *(data)*

## working/zelres1/code/100OPDMO.asm  (44 sections)

- [x] L259   `run_opening_demo_main`  *(proc)*
- [x] L458   `play_sprite_anim_script`  *(proc)*
- [x] L488   `char_render_proc`  *(proc)*
- [x] L543   `animate_scanline`  *(proc)*
- [x] L591   `timer_wait_loop`  *(proc)*
- [x] L604   `interrupt_handler_cascade`  *(proc)*
- [x] L653   `scene_transition_wait`  *(proc)*
- [x] L679   `credits_scroll_display`  *(proc)*
- [x] L999   `wait_story_scene_timer`  *(proc)*
- [x] L1010  `story_scene_input_handler`  *(proc)*
- [x] L1058  `run_script_interpreter`  *(proc)*
- [x] L1357  `calc_text_width`  *(proc)*
- [x] L1414  `animate_scanline_alt`  *(proc)*
- [x] L1471  `decompress_image`  *(proc)*
- [x] L1475  `decode_rle_stream`  *(proc)*
- [x] L1564  `decode_rle_to_es_di`  *(proc)*
- [x] L1600  `palette_lookup`  *(proc)*
- [x] L1626  `render_font_row_double`  *(proc)*
- [x] L1638  `render_font_row_inverse`  *(proc)*
- [x] L1650  `blit_rect_to_sprite_cache`  *(proc)*
- [x] L1677  `busy_wait_delay`  *(proc)*
- [x] L1693  `cycle_palette_colors`  *(proc)*
- [x] L1720  `apply_palette_blend`  *(proc)*
- [x] L1771  `xor_mask_render`  *(proc)*
- [x] L1817  `merge_gfx_planes`  *(proc)*
- [x] L2012  `jashiin_speech_2`  *(data)*
- [x] L2021  `narration_stone_scene`  *(data)*
- [x] L2500  `jashiin_disappear_text`  *(data)*
- [x] L2502  `anim_fn_wipe`  *(data)*
- [x] L2503  `anim_fn_fade`  *(data)*
- [x] L2504  `anim_fn_draw`  *(data)*
- [x] L2515  `disp_game_fn`  *(data)*
- [x] L2516  `disp_data_6F59`  *(data)*
- [x] L2517  `disp_narr_chap2`  *(data)*
- [x] L2518  `disp_chap2_call`  *(data)*
- [x] L2519  `disp_drv_seg_3`  *(data)*
- [x] L2520  `disp_narr_chap3`  *(data)*
- [x] L2521  `disp_narr_open`  *(data)*
- [x] L2522  `disp_set_drv_seg`  *(data)*
- [x] L2523  `disp_font_inv`  *(data)*
- [x] L2524  `disp_data_7420`  *(data)*
- [x] L2525  `disp_load_setup`  *(data)*
- [x] L2526  `disp_script_area`  *(data)*
- [x] L2528  `disp_narr_chap4`  *(data)*

## working/zelres1/code/101GDEGA.asm  (24 sections)

- [x] L96    `run_imgctl_main_ega`  *(proc)*
- [x] L327   `blit_2plane_sprite_ega`  *(proc)*
- [x] L357   `run_render_passes_ega`  *(proc)*
- [x] L410   `fill_plane_via_dma_ega`  *(proc)*
- [x] L438   `mask_write_loop_ega`  *(proc)*
- [x] L581   `copy_buf_with_plane_select_ega`  *(proc)*
- [x] L865   `copy_si_to_es_di_ega`  *(proc)*
- [x] L886   `copy_to_di_ega`  *(proc)*
- [x] L907   `blit_via_di_ega`  *(proc)*
- [x] L1003  `copy_32_words_ega`  *(proc)*
- [x] L1077  `compute_tile_vram_offset_ega`  *(proc)*
- [x] L1436  `lookup_palette_entry_ega`  *(proc)*
- [x] L1623  `program_seq_map_mask_ega`  *(proc)*
- [x] L1788  `fill_with_pattern_3F_ega`  *(proc)*
- [x] L1814  `draw_border_top_bottom_ega`  *(proc)*
- [x] L1858  `program_grfx_FF_then_zero_ega`  *(proc)*
- [x] L1989  `copy_with_plane_1_ega`  *(proc)*
- [x] L2016  `copy_with_plane_1_alt_ega`  *(proc)*
- [x] L2067  `seed_status_pattern_ega`  *(proc)*
- [x] L2123  `fill_status_byte_24x_ega`  *(proc)*
- [x] L2166  `blit_3plane_scroll_ega`  *(proc)*
- [x] L2284  `blit_2plane_scroll_ega`  *(proc)*
- [x] L2360  `decode_scroll_byte_ega`  *(proc)*
- [x] L2435  `hscroll_plane4_buf`  *(data)*

## working/zelres1/code/102GDCGA.asm  (22 sections)

- [x] L114   `run_imgctl_main_cga`  *(proc)*
- [x] L305   `run_render_passes_cga`  *(proc)*
- [x] L527   `build_pixel_pair_cga`  *(proc)*
- [x] L871   `copy_pixel_row_cga`  *(proc)*
- [x] L897   `copy_to_di_cga`  *(proc)*
- [x] L923   `blit_sprite_cga`  *(proc)*
- [x] L976   `plane_mix_word`  *(data)*
- [x] L1056  `compute_tile_vram_offset_cga`  *(proc)*
- [x] L1333  `blit_sprite_clipped_cga`  *(proc)*
- [x] L1519  `extract_pixel_bits_cga`  *(proc)*
- [x] L1617  `init_status_buf_cga`  *(proc)*
- [x] L1630  `clear_status_buf_rows_cga`  *(proc)*
- [x] L1660  `write_status_pattern_0_cga`  *(proc)*
- [x] L1787  `init_status_row_28_cga`  *(proc)*
- [x] L1806  `init_status_row_11_cga`  *(proc)*
- [x] L1857  `seed_status_pattern_cga`  *(proc)*
- [x] L1913  `fill_status_byte_24x_cga`  *(proc)*
- [x] L1956  `extract_pixel_pair_cga`  *(proc)*
- [x] L2028  `disp_frame_render3`  *(data)*
- [x] L2057  `extract_pixel_pair_alt_cga`  *(proc)*
- [x] L2280  `frame_plane_b_tbl`  *(data)*
- [x] L2500  `copy_status_loop_cga`  *(proc)*

## working/zelres1/code/103GDHGC.asm  (24 sections)

- [x] L147   `run_hgc_gfx_driver_main`  *(proc)*
- [x] L313   `run_render_passes_hgc`  *(proc)*
- [x] L552   `build_pixel_pair_hgc`  *(proc)*
- [x] L638   `mask_write_loop_hgc`  *(proc)*
- [x] L911   `copy_pixel_row_hgc`  *(proc)*
- [x] L935   `copy_to_di_hgc`  *(proc)*
- [x] L969   `blit_sprite_hgc`  *(proc)*
- [x] L996   `blit_via_di_hgc`  *(proc)*
- [x] L1026  `hgc_lookup_data_3`  *(data)*
- [x] L1108  `compute_tile_vram_offset_hgc`  *(proc)*
- [x] L1463  `blit_clipped_alt_hgc`  *(proc)*
- [x] L1633  `blit_sprite_clipped_hgc`  *(proc)*
- [x] L1752  `init_status_buf_hgc`  *(proc)*
- [x] L1779  `clear_status_buf_rows_hgc`  *(proc)*
- [x] L1819  `write_status_pattern_0_hgc`  *(proc)*
- [x] L1941  `init_status_row_28_hgc`  *(proc)*
- [x] L1968  `init_status_row_11_hgc`  *(proc)*
- [x] L2043  `seed_status_pattern_hgc`  *(proc)*
- [x] L2099  `fill_status_byte_24x_hgc`  *(proc)*
- [x] L2142  `extract_pixel_pair_hgc`  *(proc)*
- [x] L2270  `extract_pixel_pair_alt_hgc`  *(proc)*
- [x] L2452  `hgc_lookup_data_40`  *(data)*
- [x] L2728  `copy_status_loop_hgc`  *(proc)*
- [x] L2806  `math_calc`  *(proc)*

## working/zelres1/code/104GDTGA.asm  (27 sections)

- [x] L109   `run_gdtga_main`  *(proc)*
- [x] L316   `run_render_passes_tga`  *(proc)*
- [x] L566   `build_pixel_pair_tga`  *(proc)*
- [x] L893   `copy_pixel_row_tga`  *(proc)*
- [x] L917   `copy_to_di_tga`  *(proc)*
- [x] L941   `blit_sprite_tga`  *(proc)*
- [x] L996   `xor3_plane2_off`  *(data)*
- [x] L1028  `face_panel2_anchor`  *(data)*
- [x] L1117  `compute_tile_vram_offset_tga`  *(proc)*
- [x] L1430  `lookup_palette_entry_tga`  *(proc)*
- [x] L1482  `extract_pixel_bits_tga`  *(proc)*
- [x] L1652  `blit_sprite_clipped_tga`  *(proc)*
- [x] L1751  `init_status_buf_tga`  *(proc)*
- [x] L1763  `clear_status_buf_rows_tga`  *(proc)*
- [x] L1790  `write_status_pattern_4444_tga`  *(proc)*
- [x] L1913  `init_status_row_28_tga`  *(proc)*
- [x] L1937  `init_status_row_11_tga`  *(proc)*
- [x] L1993  `seed_status_pattern_tga`  *(proc)*
- [x] L2049  `fill_status_byte_24x_tga`  *(proc)*
- [x] L2092  `compute_vram_xy_offset_tga`  *(proc)*
- [x] L2196  `stats_fill_buf`  *(proc)*
- [x] L2383  `face_color_lut`  *(data)*
- [x] L2602  `copy_status_loop_tga`  *(proc)*
- [x] L2640  `rotate_mask_word_tga`  *(proc)*
- [x] L2714  `compute_tga_framebuf_offset`  *(proc)*
- [x] L2735  `palette_xlat_jmp`  *(data)*
- [x] L2737  `plane3_merge_buf`  *(data)*

## working/zelres1/code/105GDMCA.asm  (25 sections)

- [x] L113   `run_mcga_imgctl_main`  *(proc)*
- [x] L319   `run_render_passes_mcga`  *(proc)*
- [x] L522   `build_pixel_pair_mcga`  *(proc)*
- [x] L860   `copy_pixel_row_mcga`  *(proc)*
- [x] L879   `copy_to_di_mcga`  *(proc)*
- [x] L898   `blit_sprite_mcga`  *(proc)*
- [x] L956   `scroll_a_plane_b`  *(data)*
- [x] L1078  `compute_tile_vram_offset_mcga`  *(proc)*
- [x] L1401  `lookup_palette_entry_mcga`  *(proc)*
- [x] L1446  `extract_pixel_bits_mcga`  *(proc)*
- [x] L1620  `blit_sprite_clipped_mcga`  *(proc)*
- [x] L1715  `init_status_buf_mcga`  *(proc)*
- [x] L1725  `clear_status_buf_rows_mcga`  *(proc)*
- [x] L1748  `write_status_pattern_202_mcga`  *(proc)*
- [x] L1873  `init_status_row_28_mcga`  *(proc)*
- [x] L1901  `init_status_row_11_mcga`  *(proc)*
- [x] L1965  `seed_status_pattern_mcga`  *(proc)*
- [x] L2021  `fill_status_byte_24x_mcga`  *(proc)*
- [x] L2064  `index_status_row_47_mcga`  *(proc)*
- [x] L2172  `index_status_row_47_alt_mcga`  *(proc)*
- [x] L2241  `write_palette_byte_mcga`  *(proc)*
- [x] L2384  `pal_process_loop`  *(proc)*
- [x] L2413  `rotate_mask_word_mcga`  *(proc)*
- [x] L2439  `compute_vram_xy_offset_mcga`  *(proc)*
- [x] L2455  `pixel_plane_c_buf`  *(data)*

## working/zelres1/code/106TOWN.asm  (58 sections)

- [x] L232   `run_town_main_loop`  *(proc)*
- [x] L240   `hw_probe_pushds_byte`  *(data)*
- [x] L466   `try_take_facing_item`  *(proc)*
- [x] L550   `try_talk_to_facing_npc`  *(proc)*
- [x] L610   `render_dialog_text`  *(proc)*
- [x] L648   `set_pose_dirty`  *(proc)*
- [x] L654   `draw_dialog_typewriter`  *(proc)*
- [x] L870   `wait_for_text_continue`  *(proc)*
- [x] L911   `measure_word_width`  *(proc)*
- [x] L941   `count_wrapped_lines`  *(proc)*
- [x] L1077  `prompt_take_no_take`  *(proc)*
- [x] L1103  `math_calc`  *(proc)*
- [x] L1252  `player_scan_loop`  *(proc)*
- [x] L1277  `find_npc_at_bx_with_flag40`  *(proc)*
- [x] L1299  `tick_npcs_then_pump`  *(proc)*
- [x] L1303  `draw_and_pump_input`  *(proc)*
- [x] L1331  `run_town_input_frame`  *(proc)*
- [x] L1353  `player_process_loop`  *(proc)*
- [x] L1369  `mark_player_col_in_cursor_buf`  *(proc)*
- [x] L1397  `render_town_actors`  *(proc)*
- [x] L1513  `find_npc_col_slot`  *(proc)*
- [x] L1536  `find_npc_dx`  *(proc)*
- [x] L1540  `find_npc_dx_inner`  *(proc)*
- [x] L1553  `load_pattern_then_play_music`  *(proc)*
- [x] L1557  `play_current_music`  *(proc)*
- [x] L1566  `player_load_chunk`  *(proc)*
- [x] L1596  `process_town_event_table`  *(proc)*
- [x] L1638  `tick_npcs_dispatch`  *(proc)*
- [x] L1786  `stamp_npcs_save_tiles`  *(proc)*
- [x] L1810  `restore_tiles_under_npcs`  *(proc)*
- [x] L1836  `load_town_hud_icons`  *(proc)*
- [x] L1874  `try_door_transition`  *(proc)*
- [x] L1938  `load_area_assets`  *(proc)*
- [x] L1983  `load_town_pattern_chunk`  *(proc)*
- [x] L2012  `load_town_door_table`  *(proc)*
- [x] L2230  `tick_town_frame`  *(proc)*
- [x] L2387  `advance_dialog_line`  *(proc)*
- [x] L2406  `scroll_dlg_text_up`  *(proc)*
- [x] L2438  `dlg_draw_prompt_then_clear`  *(proc)*
- [x] L2453  `wait_for_spacebar_or_skip`  *(proc)*
- [x] L2479  `measure_dialog_word_width`  *(proc)*
- [x] L2525  `count_dialog_wrapped_lines`  *(proc)*
- [x] L2644  `div_24bit_emit_digit`  *(proc)*
- [x] L2673  `div_16bit_emit_digit`  *(proc)*
- [x] L2687  `poll_menu_input`  *(proc)*
- [x] L2840  `draw_cursor_at_dlg_row`  *(proc)*
- [x] L2850  `animate_cursor_left_10cols`  *(proc)*
- [x] L2877  `animate_cursor_right_10cols`  *(proc)*
- [x] L2904  `prompt_yes_no`  *(proc)*
- [x] L2941  `clear_n_dialog_rows`  *(proc)*
- [x] L3020  `enter_savegame_dialog`  *(proc)*
- [x] L3116  `prepare_save_name_screen`  *(proc)*
- [x] L3258  `check_save_name_is_new`  *(proc)*
- [x] L3276  `clear_save_name_if_new`  *(proc)*
- [x] L3294  `draw_menu_items_column`  *(proc)*
- [x] L3325  `player_copy_buf`  *(proc)*
- [x] L3610  `update_save_name_cursor`  *(proc)*
- [x] L3661  `redraw_save_name_at_cursor`  *(proc)*

## working/zelres1/code/107GTEGA.asm  (26 sections)

- [x] L105   `run_gtega_main`  *(proc)*
- [x] L251   `run_render_passes_gtega`  *(proc)*
- [x] L296   `render_tile_if_marked_ega`  *(proc)*
- [x] L303   `render_tile_entry_ega`  *(proc)*
- [x] L433   `mark_tile_FE_ega`  *(proc)*
- [x] L688   `tile_col6_render`  *(proc)*
- [x] L692   `set_cx_6_ega`  *(proc)*
- [x] L696   `set_es_to_vga_ega`  *(proc)*
- [x] L835   `save_state_then_blit_ega`  *(proc)*
- [x] L903   `load_tile_list_then_use_ega`  *(proc)*
- [x] L920   `load_tile_list_ptr_ega`  *(proc)*
- [x] L924   `match_tile_by_dx_ega`  *(proc)*
- [x] L937   `init_4E_loop_ega`  *(proc)*
- [x] L972   `compute_col_decrement_ega`  *(proc)*
- [x] L994   `decode_entity_slot_byte_ega`  *(proc)*
- [x] L1018  `render_2_col_iter_ega`  *(proc)*
- [x] L1073  `render_3_tile_cols_ega`  *(proc)*
- [x] L1135  `set_seq_map_mask_7_ega`  *(proc)*
- [x] L1549  `init_text_render_buf_ega`  *(proc)*
- [x] L1575  `compute_glyph_index_ega`  *(proc)*
- [x] L1636  `render_via_proc_loop2_ega`  *(proc)*
- [x] L1668  `step_text_char_loop_ega`  *(proc)*
- [x] L1704  `step_text_char_loop2_ega`  *(proc)*
- [x] L1725  `div_24bit_emit_digit_ega`  *(proc)*
- [x] L1752  `div_16bit_emit_digit_ega`  *(proc)*
- [x] L1777  `div_16bit_emit_digit_alt_ega`  *(proc)*

## working/zelres1/code/108GTCGA.asm  (27 sections)

- [x] L116   `run_gtcga_main`  *(proc)*
- [x] L247   `cga_check_blit_col`  *(proc)*
- [x] L289   `draw_door_tile`  *(proc)*
- [x] L296   `draw_opaque_tile`  *(proc)*
- [x] L467   `draw_masked_tile`  *(proc)*
- [x] L592   `load_6tiles_to_buf`  *(proc)*
- [x] L596   `load_tiles_to_buf`  *(proc)*
- [x] L711   `draw_door_init`  *(proc)*
- [x] L775   `find_nonfd_entry`  *(proc)*
- [x] L792   `scan_entity_tbl`  *(proc)*
- [x] L796   `scan_entity_next`  *(proc)*
- [x] L809   `blit_3rows_to_cga`  *(proc)*
- [x] L875   `dispatch_via_tbl_a_cga`  *(proc)*
- [x] L897   `calc_tile_cga_ofs`  *(proc)*
- [x] L923   `find_entity_at_row`  *(proc)*
- [x] L964   `load_tiles_3_from_b`  *(proc)*
- [x] L1033  `blend_tile_planes`  *(proc)*
- [x] L1364  `render_string`  *(proc)*
- [x] L1390  `render_char_glyph`  *(proc)*
- [x] L1460  `render_char_set`  *(proc)*
- [x] L1492  `render_char_row`  *(proc)*
- [x] L1537  `init_status_buf`  *(proc)*
- [x] L1558  `convert_time_bcd`  *(proc)*
- [x] L1585  `bcd_extract_sub`  *(proc)*
- [x] L1610  `bcd_extract_div`  *(proc)*
- [x] L1996  `encode_bitplanes_cga`  *(proc)*
- [x] L2036  `encode_mask_cga`  *(proc)*

## working/zelres1/code/109GTHGC.asm  (34 sections)

- [x] L107   `run_gthgc_main`  *(proc)*
- [x] L239   `match_tile_by_dx_hgc`  *(proc)*
- [x] L281   `render_tile_if_marked_hgc`  *(proc)*
- [x] L288   `render_tile_entry_hgc`  *(proc)*
- [x] L388   `mark_tile_FE_hgc`  *(proc)*
- [x] L524   `set_cx_6_hgc`  *(proc)*
- [x] L528   `save_cs_then_op_hgc`  *(proc)*
- [x] L659   `blit_sprite_alt_hgc`  *(proc)*
- [x] L723   `load_tile_list_then_use_hgc`  *(proc)*
- [x] L740   `load_tile_list_ptr_hgc`  *(proc)*
- [x] L744   `noop_helper_hgc`  *(proc)*
- [x] L757   `init_status_row_24_hgc`  *(proc)*
- [x] L776   `save_di_via_bp_hgc`  *(proc)*
- [x] L803   `decode_entity_slot_byte_hgc`  *(proc)*
- [x] L827   `render_2_col_iter_hgc`  *(proc)*
- [x] L881   `render_via_multiply3_hgc`  *(proc)*
- [x] L952   `save_ds_then_process_hgc`  *(proc)*
- [x] L1020  `copy_pixel_row_v1_hgc`  *(proc)*
- [x] L1035  `copy_pixel_row_v2_hgc`  *(proc)*
- [x] L1075  `copy_pixel_row_v3_hgc`  *(proc)*
- [x] L1124  `copy_pixel_row_v4_hgc`  *(proc)*
- [x] L1139  `copy_pixel_row_v5_hgc`  *(proc)*
- [x] L1177  `copy_pixel_row_v6_hgc`  *(proc)*
- [x] L1342  `init_text_render_buf_hgc`  *(proc)*
- [x] L1368  `compute_glyph_index_hgc`  *(proc)*
- [x] L1438  `render_via_text_decimal_hgc`  *(proc)*
- [x] L1470  `step_render_alt_hgc`  *(proc)*
- [x] L1515  `render_text_decimal_hgc`  *(proc)*
- [x] L1536  `div_24bit_emit_digit_hgc`  *(proc)*
- [x] L1563  `div_16bit_emit_digit_hgc`  *(proc)*
- [x] L1588  `div_16bit_emit_digit_alt_hgc`  *(proc)*
- [x] L1992  `init_8_byte_loop_hgc`  *(proc)*
- [x] L2034  `step_scan_alt_hgc`  *(proc)*
- [x] L2057  `math_calc`  *(proc)*

## working/zelres1/code/110GTTGA.asm  (30 sections)

- [x] L96    `run_gttga_main`  *(proc)*
- [x] L234   `match_tile_by_dx_tga`  *(proc)*
- [x] L276   `render_tile_if_marked_tga`  *(proc)*
- [x] L283   `render_tile_entry_tga`  *(proc)*
- [x] L455   `mark_tile_FE_tga`  *(proc)*
- [x] L615   `set_cx_6_tga`  *(proc)*
- [x] L619   `save_cs_then_op_tga`  *(proc)*
- [x] L733   `save_state_then_blit_tga`  *(proc)*
- [x] L797   `load_tile_list_then_use_tga`  *(proc)*
- [x] L814   `load_tile_list_ptr_tga`  *(proc)*
- [x] L818   `noop_helper_tga`  *(proc)*
- [x] L831   `check_tile_state_tga`  *(proc)*
- [x] L911   `save_di_via_bp_tga`  *(proc)*
- [x] L932   `render_via_multiply3_tga`  *(proc)*
- [x] L956   `init_status_row_alt_tga`  *(proc)*
- [x] L1009  `render_via_multiply4_tga`  *(proc)*
- [x] L1084  `save_ds_then_process_tga`  *(proc)*
- [x] L1423  `init_text_render_buf_tga`  *(proc)*
- [x] L1449  `compute_glyph_index_tga`  *(proc)*
- [x] L1500  `init_2_iter_loop_tga`  *(proc)*
- [x] L1540  `render_via_text_decimal_tga`  *(proc)*
- [x] L1568  `step_render_alt_tga`  *(proc)*
- [x] L1600  `render_text_decimal_tga`  *(proc)*
- [x] L1624  `div_24bit_emit_digit_tga`  *(proc)*
- [x] L1651  `div_16bit_emit_digit_tga`  *(proc)*
- [x] L1676  `div_16bit_emit_digit_alt_tga`  *(proc)*
- [x] L2107  `init_4_byte_loop_tga`  *(proc)*
- [x] L2150  `step_scan_alt_tga`  *(proc)*
- [x] L2173  `extract_bits`  *(proc)*
- [x] L2191  `init_4_byte_loop_alt_tga`  *(proc)*

## working/zelres1/code/111GTMCA.asm  (29 sections)

- [x] L115   `run_gtmca_main`  *(proc)*
- [x] L243   `run_render_passes_gtmca`  *(proc)*
- [x] L287   `render_tile_if_marked_mca`  *(proc)*
- [x] L294   `render_tile_entry_mca`  *(proc)*
- [x] L397   `mark_tile_FE_mca`  *(proc)*
- [x] L566   `set_cx_alt_mca`  *(proc)*
- [x] L570   `set_cx_6_mca`  *(proc)*
- [x] L574   `save_cs_then_op_mca`  *(proc)*
- [x] L708   `save_state_then_blit_mca`  *(proc)*
- [x] L771   `load_tile_list_then_use_mca`  *(proc)*
- [x] L788   `load_tile_list_ptr_mca`  *(proc)*
- [x] L792   `match_tile_by_dx_mca`  *(proc)*
- [x] L805   `init_4E_loop_mca`  *(proc)*
- [x] L820   `compute_col_decrement_mca`  *(proc)*
- [x] L846   `decode_entity_slot_byte_mca`  *(proc)*
- [x] L870   `render_2_col_iter_mca`  *(proc)*
- [x] L920   `render_3_tile_cols_mca`  *(proc)*
- [x] L999   `init_alt_setup_mca`  *(proc)*
- [x] L1356  `init_text_render_buf_mca`  *(proc)*
- [x] L1378  `extract_bits`  *(proc)*
- [x] L1438  `render_via_proc_loop2_mca`  *(proc)*
- [x] L1466  `step_text_char_loop_mca`  *(proc)*
- [x] L1502  `step_text_char_loop2_mca`  *(proc)*
- [x] L1523  `div_24bit_emit_digit_mca`  *(proc)*
- [x] L1550  `div_16bit_emit_digit_mca`  *(proc)*
- [x] L1575  `div_16bit_emit_digit_alt_mca`  *(proc)*
- [x] L1957  `step_text_char_loop3_mca`  *(proc)*
- [x] L1982  `pack_2plane_pixel_mca`  *(proc)*
- [x] L1993  `simg_scan_loop`  *(proc)*

## working/zelres2/code/200FIGHT.asm  (145 sections)

- [x] L631   `run_fight_main_loop`  *(proc)*
- [x] L756   `render_vga_pass_loop`  *(proc)*
- [x] L940   `combat_input_dispatcher`  *(proc)*
- [x] L1025  `decide_scroll_direction`  *(proc)*
- [x] L1063  `process_combat_update_step`  *(proc)*
- [x] L1144  `combat_step_dispatch`  *(proc)*
- [x] L1191  `apply_pending_invul`  *(proc)*
- [x] L1284  `try_combat_advance`  *(proc)*
- [x] L1337  `scroll_up_and_advance_state`  *(proc)*
- [x] L1401  `scan_obj_tiles_advancing`  *(proc)*
- [x] L1545  `check_area_7_boundary`  *(proc)*
- [x] L1610  `toggle_c2_bit_pose`  *(proc)*
- [x] L1635  `scan_obj_tiles_4ahead`  *(proc)*
- [x] L1771  `is_non_area7_slot_b_entity`  *(proc)*
- [x] L1793  `combat_step_advance`  *(proc)*
- [x] L1938  `combat_input_poll_step`  *(proc)*
- [x] L1994  `try_advance_with_anim`  *(proc)*
- [x] L2043  `scroll_pos_advance`  *(proc)*
- [x] L2081  `check_3tile_clearance`  *(proc)*
- [x] L2133  `range_check_si_byte`  *(proc)*
- [x] L2141  `find_fire_slot_for_id`  *(proc)*
- [x] L2181  `process_map_seg_updates`  *(proc)*
- [x] L2222  `init_scroll_system`  *(proc)*
- [x] L2244  `init_arena_visuals`  *(proc)*
- [x] L2274  `rebuild_scroll_buf`  *(proc)*
- [x] L2326  `scroll_byte_dispatch_a`  *(proc)*
- [x] L2348  `scroll_byte_dispatch_b`  *(proc)*
- [x] L2405  `fill_scroll_column`  *(proc)*
- [x] L2424  `scroll_buf_offset`  *(proc)*
- [x] L2439  `scroll_si_wrap_high`  *(proc)*
- [x] L2452  `scroll_si_wrap_low`  *(proc)*
- [x] L2463  `gate_area4_no_accessory4`  *(proc)*
- [x] L2481  `scroll_si_from_player`  *(proc)*
- [x] L2495  `get_object_state_at_si`  *(proc)*
- [x] L2514  `entity_type_quick_check`  *(proc)*
- [x] L2522  `is_entity_known_type_alt`  *(proc)*
- [x] L2557  `is_entity_id_lax`  *(proc)*
- [x] L2617  `combat_input_handler`  *(proc)*
- [x] L2736  `select_player_sprite_frame`  *(proc)*
- [x] L2811  `update_combat_frame_state`  *(proc)*
- [x] L2908  `save_combat_action_state`  *(proc)*
- [x] L3059  `fill_hud_enemy_area`  *(proc)*
- [x] L3150  `swap_world_state_buffers`  *(proc)*
- [x] L3238  `fill_hud_buf_with_FD`  *(proc)*
- [x] L3251  `find_atk_slot_for_id`  *(proc)*
- [x] L3278  `init_combat_arena`  *(proc)*
- [x] L3302  `draw_combat_hud_layout`  *(proc)*
- [x] L3361  `mark_player_pos_on_hud`  *(proc)*
- [x] L3386  `scan_outer_slot_match`  *(proc)*
- [x] L3557  `apply_passive_damage`  *(proc)*
- [x] L3570  `apply_combat_damage_with_absorb`  *(proc)*
- [x] L3611  `clear_secondary_pool_and_redraw`  *(proc)*
- [x] L3645  `accumulate_tile_type`  *(proc)*
- [x] L3676  `subtract_from_player_HP`  *(proc)*
- [x] L3691  `tick_right_col_entities`  *(proc)*
- [x] L3715  `tail_dispatch_by_slot_family`  *(proc)*
- [x] L3759  `lookup_move_slot_family`  *(proc)*
- [x] L3824  `compute_target_dist`  *(proc)*
- [x] L3903  `enter_level_via_ref_a`  *(proc)*
- [x] L3909  `render_entity_list_to_hud`  *(proc)*
- [x] L3998  `copy_si_to_di_if_unmarked`  *(proc)*
- [x] L4010  `convert_convert_world_x_to_screen_x_w27`  *(proc)*
- [x] L4130  `check_3tile_J_pattern`  *(proc)*
- [x] L4458  `compute_scroll_pos`  *(proc)*
- [x] L4476  `compute_scroll_offset_b`  *(proc)*
- [x] L4505  `decrement_speed_or_power`  *(proc)*
- [x] L4540  `reset_combat_state`  *(proc)*
- [x] L4587  `refresh_scene_assets`  *(proc)*
- [x] L4650  `wait_anim_cycle`  *(proc)*
- [x] L4670  `scan_top_map_objects`  *(proc)*
- [x] L4700  `try_top_scroll_direction`  *(proc)*
- [x] L4799  `try_top_combat_step`  *(proc)*
- [x] L4893  `find_and_blit_map_entry`  *(proc)*
- [x] L4931  `match_dl_within_3`  *(proc)*
- [x] L4952  `scan_bot_map_objects`  *(proc)*
- [x] L4982  `bot_path_check`  *(proc)*
- [x] L5001  `scan_extra_map_objects`  *(proc)*
- [x] L5166  `check_entity_collision_pos`  *(proc)*
- [x] L5212  `convert_world_x_to_inner_screen_x`  *(proc)*
- [x] L5271  `entity_slot_write_tagged`  *(proc)*
- [x] L5286  `scan_enemy_data_buf`  *(proc)*
- [x] L5347  `process_dirty_enemies`  *(proc)*
- [x] L5365  `prep_dirty_blit`  *(proc)*
- [x] L5378  `enemy_sprite_blit`  *(proc)*
- [x] L5443  `process_sprite_step`  *(proc)*
- [x] L5575  `entity_fn_dispatch_b`  *(proc)*
- [x] L5619  `entity_step_dispatch_c`  *(proc)*
- [x] L5664  `update_entity_dir_from_path`  *(proc)*
- [x] L5711  `tick_decrement_enemy_counters`  *(proc)*
- [x] L5731  `tick_increment_enemy_counters`  *(proc)*
- [x] L5751  `calc_hud_buf_offset`  *(proc)*
- [x] L5765  `process_active_sprites`  *(proc)*
- [x] L5817  `prep_boss_dirty_blit`  *(proc)*
- [x] L5831  `update_sprite_work_buf`  *(proc)*
- [x] L5867  `place_3_tile_49_pattern`  *(proc)*
- [x] L5887  `try_place_tile_id_49`  *(proc)*
- [x] L6132  `scan_boss_entries_render`  *(proc)*
- [x] L6251  `render_boss_dirty_blits`  *(proc)*
- [x] L6307  `gate_spell_fx_active`  *(proc)*
- [x] L6451  `cycle_dir_and_advance`  *(proc)*
- [x] L6486  `draw_entity_3x3_at_pos`  *(proc)*
- [x] L6544  `try_paint_obj_cell`  *(proc)*
- [x] L6581  `scan_obj_list_render`  *(proc)*
- [x] L6647  `update_obj_slot_flags`  *(proc)*
- [x] L6932  `gfx_fn_enemy_scroll`  *(data)*
- [x] L6933  `gfx_fn_combat_fx`  *(data)*
- [x] L6934  `gfx_fn_render_tile`  *(data)*
- [x] L6935  `gfx_fn_render_col`  *(data)*
- [x] L6936  `gfx_fn_hud_draw`  *(data)*
- [x] L6937  `gfx_fn_77`  *(data)*
- [x] L6939  `gfx_fn_78`  *(data)*
- [x] L6940  `gfx_fn_player_scroll`  *(data)*
- [x] L6941  `gfx_fn_init`  *(data)*
- [x] L6942  `gfx_fn_map_load`  *(data)*
- [x] L6943  `gfx_fn_render_bg`  *(data)*
- [x] L6944  `gfx_fn_83`  *(data)*
- [x] L6945  `gfx_fn_palette`  *(data)*
- [x] L6946  `gfx_fn_clear`  *(data)*
- [x] L6947  `gfx_fn_blit`  *(data)*
- [x] L6948  `gfx_fn_map_ref`  *(data)*
- [x] L6952  `gfx_fn_memcpy`  *(data)*
- [x] L6953  `gfx_fn_map_scroll`  *(data)*
- [x] L7146  `hero_almas_add`  *(proc)*
- [x] L7159  `check_entity_in_view`  *(proc)*
- [x] L7216  `entity_move_east`  *(proc)*
- [x] L7250  `entity_move_north`  *(proc)*
- [x] L7290  `entity_move_west`  *(proc)*
- [x] L7322  `entity_move_south`  *(proc)*
- [x] L7361  `inc_map_pos_helper`  *(proc)*
- [x] L7379  `dec_map_pos_helper`  *(proc)*
- [x] L7406  `check_above_3rows_clear`  *(proc)*
- [x] L7436  `is_unknown_or_area5_slot_b`  *(proc)*
- [x] L7464  `check_below_3rows_clear`  *(proc)*
- [x] L7494  `is_unknown_or_area5_slot_c`  *(proc)*
- [x] L7523  `check_north_movement`  *(proc)*
- [x] L7556  `check_south_movement`  *(proc)*
- [x] L7581  `check_tiles_upper_right_quad`  *(proc)*
- [x] L7625  `check_tiles_lower_right_quad`  *(proc)*
- [x] L7663  `check_tiles_upper_left_quad`  *(proc)*
- [x] L7755  `is_entity_known_type`  *(proc)*
- [x] L7779  `check_entity_slot_validity`  *(proc)*
- [x] L7941  `reset_enemy_data_ext_and_objs`  *(proc)*
- [x] L8039  `item_effect_val_add`  *(proc)*
- [x] L8207  `compute_action_anim_idx`  *(proc)*
- [x] L8405  `next_level_start`  *(label word)*

## working/zelres2/code/201SELCT.asm  (25 sections)

- [x] L149   `run_selct_main`  *(proc)*
- [x] L312   `draw_weapon_cursor`  *(proc)*
- [x] L344   `show_weapon_portrait`  *(proc)*
- [x] L425   `draw_magic_cursor`  *(proc)*
- [x] L457   `show_magic_portrait`  *(proc)*
- [x] L564   `draw_item_cursor`  *(proc)*
- [x] L596   `show_item_portrait`  *(proc)*
- [x] L836   `init_item_panel`  *(proc)*
- [x] L854   `draw_item_detail`  *(proc)*
- [x] L882   `show_portrait_box`  *(proc)*
- [x] L896   `hide_portrait_box`  *(proc)*
- [x] L910   `rebuild_item_idx`  *(proc)*
- [x] L940   `draw_item_panel`  *(proc)*
- [x] L992  `draw_magic_panel`  *(proc)*
- [x] L1156  `draw_exp_bar`  *(proc)*
- [x] L1175  `draw_key_count`  *(proc)*
- [x] L1204  `draw_weapon_panel`  *(proc)*
- [x] L1355  `draw_portrait_tabs`  *(proc)*
- [x] L1450  `check_joy_neutral`  *(proc)*
- [x] L1458  `joy_has_dir`  *(label word)*
- [x] L1505  `shoe_name_ptrs_lbl`  *(label word)*
- [x] L1544  `item_det_str_chikara`  *(label word)*
- [x] L1554  `item_name_ptrs_lbl`  *(label word)*
- [x] L1589  `weapon_detail_ptrs_lbl`  *(label word)*
- [x] L1615  `shield_detail_ptrs_lbl`  *(label word)*

## working/zelres2/code/202GFEGA.asm  (40 sections)

- [x] L158   `run_gfega_main`  *(proc)*
- [x] L198   `ega_row_ofs`  *(data)*
- [x] L280   `sprite_state_update`  *(proc)*
- [x] L490   `ega_sprite_blit`  *(proc)*
- [x] L685   `sprite_slot_init`  *(proc)*
- [x] L719   `sprite_blit_dispatch`  *(proc)*
- [x] L751   `sprite_wide_row_render`  *(proc)*
- [x] L940   `step_sprite_pos_pair`  *(proc)*
- [x] L975   `sprite_cell_render`  *(proc)*
- [x] L1031  `ega_sprite_blit_ex`  *(proc)*
- [x] L1045  `ega_sprite_render_blended`  *(proc)*
- [x] L1124  `ega_sprite_render_solid`  *(proc)*
- [x] L1181  `ega_blit_2bytes_8rows`  *(proc)*
- [x] L1220  `ega_3plane_copy`  *(proc)*
- [x] L1247  `ega_clear_16bytes`  *(proc)*
- [x] L1265  `sprite_get_value`  *(proc)*
- [x] L1273  `sprite_src_setup`  *(proc)*
- [x] L1312  `projectile_spawn_check`  *(proc)*
- [x] L1965  `hero_sprite_col_blit`  *(proc)*
- [x] L2005  `hero_tier_get`  *(proc)*
- [x] L2104  `scroll_pos_load`  *(proc)*
- [x] L2131  `render_frame_rows`  *(proc)*
- [x] L2284  `restore_background_pixels`  *(proc)*
- [x] L2306  `save_background_pixels`  *(proc)*
- [x] L2341  `restore_background_pixels_impl`  *(proc)*
- [x] L2376  `scroll_cache_invalidate`  *(proc)*
- [x] L2594  `tile_blit_3x3`  *(proc)*
- [x] L2783  `ega_tile_anim_update`  *(proc)*
- [x] L2849  `ega_plane_write_2row`  *(proc)*
- [x] L2898  `ega_clear_pixel_pair`  *(proc)*
- [x] L2908  `phase_ptr_advance`  *(proc)*
- [x] L3000  `fade_gradient_loop`  *(proc)*
- [x] L3042  `ega_fade_blit`  *(proc)*
- [x] L3080  `ega_fill_bit_range`  *(proc)*
- [x] L3154  `ega_fill_bit_range_wide`  *(proc)*
- [x] L3282  `ega_row_addr_calc`  *(proc)*
- [x] L3291  `frame_wait_loop`  *(proc)*
- [x] L3417  `wrap_scroll_si_low`  *(proc)*
- [x] L3577  `ega_bg_tile_blit`  *(proc)*
- [x] L3717  `ega_col_write_loop`  *(proc)*

## working/zelres2/code/203GFCGA.asm  (43 sections)

- [x] L167   `run_gfcga_main`  *(proc)*
- [x] L201   `cga_row_ofs`  *(data)*
- [x] L283   `sprite_state_update`  *(proc)*
- [x] L489   `cga_sprite_blit`  *(proc)*
- [x] L631   `sprite_slot_init`  *(proc)*
- [x] L665   `sprite_blit_dispatch`  *(proc)*
- [x] L697   `sprite_wide_row_render`  *(proc)*
- [x] L886   `step_sprite_pos_pair`  *(proc)*
- [x] L921   `sprite_cell_render`  *(proc)*
- [x] L985   `cga_sprite_blit_ex`  *(proc)*
- [x] L1002  `cga_sprite_render_blended`  *(proc)*
- [x] L1021  `cga_sprite_render_solid`  *(proc)*
- [x] L1034  `sprite_bit_extract`  *(proc)*
- [x] L1076  `cga_blit_2rows_stride`  *(proc)*
- [x] L1096  `sprite_copy_8words`  *(proc)*
- [x] L1103  `sprite_clear_8words`  *(proc)*
- [x] L1111  `sprite_get_value`  *(proc)*
- [x] L1119  `sprite_src_setup`  *(proc)*
- [x] L1158  `projectile_spawn_check`  *(proc)*
- [x] L1773  `sprite_col_render_loop`  *(proc)*
- [x] L1815  `hero_tier_get`  *(proc)*
- [x] L1944  `render_frame_rows`  *(proc)*
- [x] L2097  `restore_scroll_pixels`  *(proc)*
- [x] L2117  `save_background_pixels`  *(proc)*
- [x] L2145  `restore_background_pixels`  *(proc)*
- [x] L2169  `scroll_pos_load`  *(proc)*
- [x] L2302  `bg_tile_restore_3x3`  *(proc)*
- [x] L2443  `bg_col_blit_row`  *(proc)*
- [x] L2502  `col_write_inner`  *(proc)*
- [x] L2539  `cga_clear_2rows`  *(proc)*
- [x] L2549  `row_ofs_advance`  *(proc)*
- [x] L2597  `cga_inner_fade`  *(proc)*
- [x] L2673  `cga_fade_blit`  *(proc)*
- [x] L2774  `cga_fill_bit_range_wide`  *(proc)*
- [x] L2897  `cga_row_addr_calc`  *(proc)*
- [x] L2909  `frame_wait_loop`  *(proc)*
- [x] L2931  `hud_clear`  *(proc)*
- [x] L3018  `wrap_scroll_si_low`  *(proc)*
- [x] L3135  `cga_plane_mask_2bit`  *(proc)*
- [x] L3188  `bg_tile_blit_inner`  *(proc)*
- [x] L3219  `cga_plane_mask_combine`  *(proc)*
- [x] L3710  `cga_nibble_mask_advance`  *(proc)*
- [x] L3739  `cga_nibble_mask_alt`  *(proc)*

## working/zelres2/code/204GFHGC.asm  (47 sections)

- [x] L138   `run_gfhgc_main`  *(proc)*
- [x] L177   `hgc_row_ofs`  *(data)*
- [x] L264   `sprite_state_update`  *(proc)*
- [x] L469   `hgc_plane_or_blit`  *(proc)*
- [x] L571   `sprite_slot_remove`  *(proc)*
- [x] L608   `sprite_slot_init`  *(proc)*
- [x] L642   `sprite_blit_dispatch`  *(proc)*
- [x] L674   `sprite_wide_row_render`  *(proc)*
- [x] L881   `sprite_pair_blit`  *(proc)*
- [x] L916   `hgc_sprite_blit`  *(proc)*
- [x] L980   `merge_sprite_into_cache`  *(proc)*
- [x] L997   `mask_blit_into_sprite_cache`  *(proc)*
- [x] L1016  `plane_copy_process`  *(proc)*
- [x] L1029  `hgc_extract_4bits`  *(proc)*
- [x] L1071  `plane_scan_blit`  *(proc)*
- [x] L1090  `copy_8words`  *(proc)*
- [x] L1097  `clear_8words`  *(proc)*
- [x] L1105  `decode_char_glyph`  *(proc)*
- [x] L1113  `sprite_src_setup`  *(proc)*
- [x] L1152  `check_spawn_projectile`  *(proc)*
- [x] L1809  `sprite_write_range`  *(proc)*
- [x] L1851  `get_step_direction`  *(proc)*
- [x] L1953  `build_sprite_refs`  *(proc)*
- [x] L1980  `render_frame_rows`  *(proc)*
- [x] L2176  `dispatch_background_restore`  *(proc)*
- [x] L2196  `save_bg_rows`  *(proc)*
- [x] L2224  `restore_bg_rows`  *(proc)*
- [x] L2261  `clear_sprite_cache_block`  *(proc)*
- [x] L2391  `load_bg_to_cache`  *(proc)*
- [x] L2540  `anim_refresh_tile`  *(proc)*
- [x] L2600  `hgc_write_row_masked`  *(proc)*
- [x] L2649  `hgc_clear_row_masked`  *(proc)*
- [x] L2680  `set_pixel_stride_offset`  *(proc)*
- [x] L2712  `fade_radius_loop`  *(proc)*
- [x] L2788  `hgc_fade_blit`  *(proc)*
- [x] L2891  `hgc_fill_bit_range_wide`  *(proc)*
- [x] L3014  `hgc_row_addr_calc`  *(proc)*
- [x] L3025  `frame_wait_loop`  *(proc)*
- [x] L3047  `hgc_xor_fill_region`  *(proc)*
- [x] L3135  `wrap_scroll_si_low`  *(proc)*
- [x] L3146  `wrap_scroll_si_high`  *(proc)*
- [x] L3281  `hgc_fade_blit_entry`  *(proc)*
- [x] L3313  `rol_extract_loop`  *(proc)*
- [x] L3643  `shift_extract_loop`  *(proc)*
- [x] L3770  `hgc_pixel_addr_calc`  *(proc)*
- [x] L3855  `rotate_plane_pair_loop`  *(proc)*
- [x] L3884  `dispatch_shape_fill`  *(proc)*

## working/zelres2/code/205GFTGA.asm  (48 sections)

- [x] L124   `run_gftga_main`  *(proc)*
- [x] L159   `tga_row_ofs`  *(data)*
- [x] L248   `sprite_state_update`  *(proc)*
- [x] L458   `tga_sprite_blit`  *(proc)*
- [x] L695   `sprite_slot_remove`  *(proc)*
- [x] L732   `sprite_slot_init`  *(proc)*
- [x] L767   `sprite_blit_dispatch`  *(proc)*
- [x] L799   `sprite_wide_row_render`  *(proc)*
- [x] L991   `step_sprite_pos_pair`  *(proc)*
- [x] L1025  `sprite_cell_render`  *(proc)*
- [x] L1091  `tga_sprite_render_blended`  *(proc)*
- [x] L1108  `tile_blend_inner_loop`  *(proc)*
- [x] L1135  `tga_sprite_inner_blit`  *(proc)*
- [x] L1151  `color_nibble_expand`  *(proc)*
- [x] L1193  `tga_blit_2bytes_8rows`  *(proc)*
- [x] L1256  `copy_16words`  *(proc)*
- [x] L1263  `fill_16words_zero`  *(proc)*
- [x] L1271  `sprite_get_value`  *(proc)*
- [x] L1279  `sprite_src_setup`  *(proc)*
- [x] L1318  `projectile_spawn_check`  *(proc)*
- [x] L1974  `tga_sprite_render_solid`  *(proc)*
- [x] L2018  `hero_tier_get`  *(proc)*
- [x] L2152  `render_frame_rows`  *(proc)*
- [x] L2306  `restore_background_pixels`  *(proc)*
- [x] L2326  `save_background_pixels`  *(proc)*
- [x] L2354  `restore_background_pixels_impl`  *(proc)*
- [x] L2378  `scroll_cache_invalidate`  *(proc)*
- [x] L2508  `tga_plane_decode`  *(proc)*
- [x] L2594  `hero_sprite_col_blit`  *(proc)*
- [x] L2741  `tga_tile_anim_update`  *(proc)*
- [x] L2801  `tile_blend_row_pair`  *(proc)*
- [x] L2838  `tga_row_mask_clear`  *(proc)*
- [x] L2848  `tga_vram_advance_az`  *(proc)*
- [x] L2896  `fade_concentric`  *(proc)*
- [x] L2972  `fade_h_range`  *(proc)*
- [x] L3061  `fade_pixel_range`  *(proc)*
- [x] L3160  `phase_ptr_advance`  *(proc)*
- [x] L3180  `fade_gradient_loop`  *(proc)*
- [x] L3202  `anim_refresh_all`  *(proc)*
- [x] L3292  `wrap_scroll_si_low`  *(proc)*
- [x] L3303  `wrap_scroll_si_high`  *(proc)*
- [x] L3432  `bg_tile_blit_init`  *(proc)*
- [x] L3466  `plane_word_expand`  *(proc)*
- [x] L3882  `ega_fill_bit_range_wide`  *(proc)*
- [x] L4065  `rotate_plane_pair_tga`  *(proc)*
- [x] L4083  `dither_bit_expand`  *(proc)*
- [x] L4106  `nibble_pack_ax`  *(proc)*
- [x] L4125  `ega_row_addr_calc`  *(proc)*

## working/zelres2/code/206GFMCA.asm  (56 sections)

- [x] L151   `run_gfmca_main`  *(proc)*
- [x] L181   `mov_cx_80h_imm`  *(data)*
- [x] L187   `inc_byte_opcode_patch`  *(data)*
- [x] L198   `mca_row_ofs`  *(data)*
- [x] L279   `sprite_state_update`  *(proc)*
- [x] L485   `mca_sprite_blit`  *(proc)*
- [x] L596   `sprite_slot_remove`  *(proc)*
- [x] L633   `sprite_slot_init`  *(proc)*
- [x] L669   `sprite_blit_dispatch`  *(proc)*
- [x] L701   `sprite_wide_row_render`  *(proc)*
- [x] L896   `step_sprite_pos_pair`  *(proc)*
- [x] L930   `sprite_cell_render`  *(proc)*
- [x] L992   `mca_sprite_blit_ex`  *(proc)*
- [x] L1009  `step_mca_plane_3`  *(proc)*
- [x] L1027  `step_mca_plane_nibble`  *(proc)*
- [x] L1044  `mca_plane_copy_16rows`  *(proc)*
- [x] L1060  `mca_plane_copy_4px`  *(proc)*
- [x] L1073  `mca_fetch_color_lut`  *(proc)*
- [x] L1089  `mca_blit_2bytes_8rows`  *(proc)*
- [x] L1104  `mca_sprite_render_solid`  *(proc)*
- [x] L1132  `mca_sprite_clear_cell`  *(proc)*
- [x] L1140  `sprite_get_value`  *(proc)*
- [x] L1148  `sprite_src_setup`  *(proc)*
- [x] L1187  `projectile_spawn_check`  *(proc)*
- [x] L1372  `loc_92`  *(label byte)*
- [x] L1828  `render_frame_rows`  *(proc)*
- [x] L1872  `shield_state_get`  *(proc)*
- [x] L1976  `load_sprite_pos`  *(proc)*
- [x] L2003  `frame_row_dispatcher`  *(proc)*
- [x] L2158  `restore_scroll_pixels`  *(proc)*
- [x] L2178  `scroll_buf_restore`  *(proc)*
- [x] L2200  `scroll_buf_save`  *(proc)*
- [x] L2222  `scroll_clear_cache`  *(proc)*
- [x] L2412  `hero_sprite_col_blit`  *(proc)*
- [x] L2569  `mca_tile_half_blit`  *(proc)*
- [x] L2633  `mca_tile_half_blit_rows`  *(proc)*
- [x] L2692  `mca_tile_half_clear`  *(proc)*
- [x] L2704  `mca_tile_addr_calc`  *(proc)*
- [x] L2742  `fade_gradient_rect`  *(proc)*
- [x] L2818  `fade_gradient_line`  *(proc)*
- [x] L2889  `fade_horizontal_line`  *(proc)*
- [x] L2930  `mca_vga_row_calc`  *(proc)*
- [x] L2942  `anim_frame_wait`  *(proc)*
- [x] L2964  `fade_xor_block`  *(proc)*
- [x] L3049  `wrap_scroll_si_low`  *(proc)*
- [x] L3060  `wrap_scroll_si_high`  *(proc)*
- [x] L3172  `ui_tile_blit_init`  *(label byte)*
- [x] L3199  `bg_tile_blit`  *(proc)*
- [x] L3223  `mca_sprite_2block_render`  *(proc)*
- [x] L3293  `ah_xform_6to3`  *(label word)*
- [x] L3374  `loc_237`  *(label byte)*
- [x] L3489  `mca_plane_4bit_scan`  *(proc)*
- [x] L3581  `gf_mca_proj_sprite_a`  *(label byte)*
- [x] L3832  `mca_word_shift_4`  *(proc)*
- [x] L3850  `mca_bit_pair_scan`  *(proc)*
- [x] L3863  `loc_248`  *(label byte)*

## working/zelres2/code/207MOLE.asm  (21 sections)

- [x] L109   `module_init`  *(proc)*
- [x] L248   `dispatch_decode_table_a`  *(proc)*
- [x] L274   `ega_plane_blit`  *(label word)*
- [x] L387   `cga_row_continue`  *(label byte)*
- [x] L542   `vga_pixel_unpack`  *(proc)*
- [x] L570   `cga_hires_blit`  *(label byte)*
- [x] L621   `mcga_pixel_unpack`  *(proc)*
- [x] L625   `mcga_nibble_loop`  *(label byte)*
- [x] L655   `dispatch_decode_table_b`  *(proc)*
- [x] L683   `ega_decode_b`  *(label word)*
- [x] L695   `mole_video_addr_BF00`  *(data)*
- [x] L726   `decode_5col_blit_loop`  *(proc)*
- [x] L745   `decode_4bit_unpack`  *(proc)*
- [x] L778   `mono_scan_loop`  *(proc)*
- [x] L812   `extract_bits`  *(proc)*
- [x] L843   `extract_first_write`  *(label byte)*
- [x] L904   `unpack_emit_run`  *(label byte)*
- [x] L982   `mole_dispatch_24B_anchor`  *(data)*
- [x] L1168  `mole_sprite_chunk_128A`  *(data)*
- [x] L1946  `write_dma_port_then_pad`  *(proc)*
- [x] L1962  `sprite_data_row_2`  *(label byte)*

## working/zelres2/code/208YMPD.asm  (10 sections)

- [x] L124   `run_satono_bg_main`  *(proc)*
- [x] L175   `rle_decode_mountain_88x56`  *(proc)*
- [x] L209   `render_mountains`  *(proc)*
- [x] L251   `ega_mtn_blit_88_rows`  *(proc)*
- [x] L442   `pixel_expand_mcga`  *(proc)*
- [x] L500   `pixel_expand_cga`  *(proc)*
- [x] L538   `rle_decode_ground_28`  *(proc)*
- [x] L568   `render_ground`  *(proc)*
- [x] L649   `copy_28b_ega`  *(proc)*
- [x] L1021  `pixel_expand_cgaalt`  *(proc)*

## working/zelres2/code/209CKPD.asm  (13 sections)

- [x] L159   `bos_render_main`  *(proc)*
- [x] L222   `bos_frame_dispatch`  *(proc)*
- [x] L484   `vga_row_copy`  *(proc)*
- [x] L551   `nibble_expand_8`  *(proc)*
- [x] L630   `decode_nibble_pair`  *(proc)*
- [x] L660   `sprite_rle_decode`  *(proc)*
- [x] L700   `render_dispatch_layer2`  *(proc)*
- [x] L952   `nibble_expand_8_b`  *(proc)*
- [x] L1022  `decode_nibble_pair_alt`  *(proc)*
- [x] L1159  `ckpd_raw_region_anchor_a`  *(data)*
- [x] L1487  `ckpd_pattern_dst_buf`  *(data)*
- [x] L1600  `ckpd_obfuscated_value`  *(data)*
- [x] L1726  `ckpd_raw_region_anchor_b`  *(data)*

## working/zelres2/code/210KINGP.asm  (9 sections)

- [x] L91    `run_kingp_main`  *(proc)*
- [x] L134   `script_cmd_dispatch`  *(proc)*
- [x] L252   `short_wait`  *(proc)*
- [x] L263   `render_portrait`  *(proc)*
- [x] L297   `render_portrait_variant`  *(proc)*
- [x] L390   `face_anim_tick`  *(proc)*
- [x] L402   `face_mode_update`  *(proc)*
- [x] L525   `select_script_branch`  *(proc)*
- [x] L610   `data_portrait_tail`  *(data)*

## working/zelres2/code/211OMOYP.asm  (8 sections)

- [x] L80    `run_omoyp_main`  *(proc)*
- [x] L177   `ref_enddemo`  *(data)*
- [x] L139   `end_demo_transition`  *(label word)*
- [x] L240   `banner_row_loop`  *(label byte)*
- [x] L235   `draw_hut_banner`  *(proc)*
- [x] L244   `banner_col_loop`  *(label byte)*
- [x] L316   `ref_omoya_grp`  *(data)*
- [x] L320   `banner_msg_header`  *(label byte)*

## working/zelres2/code/212ARMRP.asm  (10 sections)

- [x] L150   `run_armrp_main`  *(proc)*
- [x] L216   `build_mouth_bitmap_a`  *(proc)*
- [x] L246   `build_mouth_bitmap_b`  *(proc)*
- [x] L276   `shop_menu_dispatch`  *(proc)*
- [x] L552   `install_knight_sword_hook_a`  *(proc)*
- [x] L889   `wait_frame_delay`  *(proc)*
- [x] L924   `install_knight_sword_hook_b`  *(proc)*
- [x] L948   `clear_menu_rect`  *(proc)*
- [x] L956   `shopkeeper_anim_tick`  *(proc)*
- [x] L1054  `render_shopkeeper_frame`  *(proc)*

## working/zelres2/code/213BANKP.asm  (9 sections)

- [x] L118   `run_bank_main`  *(proc)*
- [x] L182   `script_opcode_dispatch`  *(proc)*
- [x] L208   `script_step_entry_word`  *(data)*
- [x] L633   `clear_dialog_area`  *(proc)*
- [x] L641   `apply_amount_input_adjust`  *(proc)*
- [x] L697   `draw_intro_12x8`  *(proc)*
- [x] L745   `anim_scroll_step`  *(proc)*
- [x] L767   `draw_banner_8x5`  *(proc)*
- [x] L830   `iter_wait_msg_list`  *(proc)*

## working/zelres2/code/214CHURP.asm  (7 sections)

- [x] L71    `run_church_main`  *(proc)*
- [x] L124   `script_opcode_dispatch`  *(proc)*
- [x] L156   `rest_wait_loop`  *(data)*
- [x] L250   `draw_intro_12x8`  *(proc)*
- [x] L293   `anim_scroll_step`  *(proc)*
- [x] L314   `anim_draw_a`  *(proc)*
- [x] L409   `pick_welcome_text`  *(proc)*

## working/zelres2/code/215DRUGP.asm  (10 sections)

- [x] L105   `run_drugstore_main`  *(proc)*
- [x] L159   `wizard_process_loop`  *(proc)*
- [x] L189   `dispatch_shop_cmd`  *(proc)*
- [x] L200   `shop_cmd1_lo_byte`  *(data)*
- [x] L229   `drugp_continuation_jmp`  *(data)*
- [x] L514   `pack_shop_inv_for_dialog`  *(proc)*
- [x] L618   `clear_shop_inner_box`  *(proc)*
- [x] L626   `draw_shop_banner`  *(proc)*
- [x] L674   `animate_wizard_glyphs`  *(proc)*
- [x] L736   `wizard_scan_loop`  *(proc)*

## working/zelres2/code/216INNAP.asm  (20 sections)

- [x] L61    `run_inn_main`  *(proc)*
- [x] L114   `draw_intro_banner`  *(proc)*
- [x] L130   `inn_opcode_dispatch`  *(proc)*
- [x] L155   `inn_patch_slot_1`  *(data)*
- [x] L156   `inn_patch_slot_2`  *(data)*
- [x] L162   `inn_patch_slot_3`  *(data)*
- [x] L165   `inn_patch_flag`  *(data)*
- [x] L169   `inn_handler_dst_buf`  *(data)*
- [x] L171   `inn_patch_word_6`  *(data)*
- [x] L172   `inn_handler_src_buf`  *(data)*
- [x] L213   `inn_anim_scan_fn_ptr`  *(data)*
- [x] L265   `inn_wait_long`  *(proc)*
- [x] L280   `inn_wait_short`  *(proc)*
- [x] L296   `inn_anim_step`  *(proc)*
- [x] L332   `draw_intro_tile_map`  *(proc)*
- [x] L341   `intro_map_inner`  *(label byte)*
- [x] L391   `anim_scan_active`  *(label byte)*
- [x] L386   `inn_anim_scan`  *(proc)*
- [x] L437   `inn_tile_map_tail`  *(label word)*
- [x] L474   `ref_inn_grp`  *(data)*

## working/zelres2/code/217KENJP.asm  (22 sections)

- [x] L166   `run_kenja_main`  *(proc)*
- [x] L201   `load_sage_chunk`  *(proc)*
- [x] L226   `kenja_cmd_dispatch`  *(proc)*
- [x] L238   `kenj_inplace_buf`  *(data)*
- [x] L249   `kenj_input_flags`  *(data)*
- [x] L266   `kenj_dispatch_fn_ptr`  *(data)*
- [x] L329   `scan_blessing_attrs`  *(proc)*
- [x] L379   `check_hp_exp_tier`  *(proc)*
- [x] L629   `wait_frames_140`  *(proc)*
- [x] L644   `log_experience_entry`  *(proc)*
- [x] L762   `draw_char_row`  *(proc)*
- [x] L793   `wait_name_input`  *(proc)*
- [x] L1052  `update_name_cursor`  *(proc)*
- [x] L1103  `render_name_field`  *(proc)*
- [x] L1249  `clear_sage_region`  *(proc)*
- [x] L1257  `draw_sage_tile_grid`  *(proc)*
- [x] L1299  `render_glyph_32`  *(proc)*
- [x] L1386  `anim_tick`  *(proc)*
- [x] L1460  `kenj_phase_inc_table`  *(data)*
- [x] L1464  `sage_intro_dispatch`  *(proc)*
- [x] L1576  `kenj_str_outside_at_7`  *(data)*
- [x] L1588  `kenj_str_spirits_anchor`  *(data)*

## working/zelres2/code/236CMAP.mdt  (data passthrough -- no .asm sections)

(file moved to data/ as MDT passthrough; no inventory items)

## working/zelres2/code/238STMP.mdt  (data passthrough -- no .asm sections)


## working/zelres2/code/239BSMP.mdt  (data passthrough -- no .asm sections)


## working/zelres2/code/250ENDMO.asm  (17 sections)

- [x] L240   `run_ending_scene_main`  *(proc)*
- [x] L456   `timer_wait_loop`  *(proc)*
- [x] L467   `gfx_driver_tick_full`  *(proc)*
- [x] L480   `render_narration_page`  *(proc)*
- [x] L841   `measure_script_word_width`  *(proc)*
- [x] L938   `run_credits_loop_main`  *(proc)*
- [x] L1081  `put_credits_char`  *(proc)*
- [x] L1214  `credits_wait_tick`  *(proc)*
- [x] L1225  `credits_driver_tick`  *(proc)*
- [x] L1238  `rle_blit_pair`  *(proc)*
- [x] L1244  `rle_decode_plane`  *(proc)*
- [x] L1359  `fill_credits_triplane`  *(proc)*
- [x] L1862  `bitmap_row_byte`  *(data)*
- [x] L2121  `full_scroll_fn_ptr`  *(data)*
- [x] L2193  `ref_waku_grp`  *(data)*
- [x] L2195  `ref_sei_grp`  *(data)*
- [x] L2197  `ref_yuup_grp`  *(data)*

## working/zelres3/code/300ROKAD.asm  (10 sections)

- [x] L160   `run_roka_demo_main`  *(proc)*
- [x] L445   `draw_pose_3x3`  *(proc)*
- [x] L554   `frame_wait`  *(label byte)*
- [x] L549   `wait_frame`  *(proc)*
- [x] L562   `bres_setup`  *(proc)*
- [x] L613   `bres_step`  *(proc)*
- [x] L655   `bres_step_y_done`  *(label byte)*
- [x] L655   `bres_step_y_done`  *(label word)*
- [x] L713   `ref_mfan_msd`  *(label byte)*
- [x] L718   `ref_6dman_grp`  *(label byte)*

## working/zelres3/code/301EAI1.asm  (8 sections)

- [x] L127   `run_crab_ai_main`  *(proc)*
- [x] L144   `crab_ai_init_src`  *(label word)*
- [x] L207   `crab_frame_00`  *(label word)*
- [x] L236   `crab_facing_fn_ptr`  *(data)*
- [x] L305   `crab_anim_phase_marker`  *(data)*
- [x] L562   `phase_advance_helper`  *(proc)*
- [x] L706   `distance_check_8`  *(proc)*
- [x] L971   `distance_check_6`  *(proc)*

## working/zelres3/code/302EAI2.asm  (21 sections)

- [x] L129   `run_tako_ai_main`  *(proc)*
- [x] L145   `tako_init_src_dst`  *(label word)*
- [x] L212   `tako_frame_data`  *(label word)*
- [x] L212   `tako_frame_data`  *(label byte)*
- [x] L192   `eai2_offset_anchor`  *(data)*
- [x] L241   `eai2_bc_string_anchor`  *(data)*
- [x] L274   `tako_frame_A1B9`  *(label byte)*
- [x] L283   `tako_frame_A1E1`  *(label byte)*
- [x] L300   `tako_frame_A23B`  *(label byte)*
- [x] L370   `tako_aux_records`  *(label byte)*
- [x] L370   `tako_aux_records`  *(label word)*
- [x] L600   `tako_tentacle_mask_a`  *(data)*
- [x] L601   `tako_tentacle_mask_b`  *(data)*
- [x] L607   `step_pos_x`  *(proc)*
- [x] L636   `collide_check_right`  *(proc)*
- [x] L671   `step_neg_x`  *(proc)*
- [x] L699   `collide_check_left`  *(proc)*
- [x] L734   `step_swim_y`  *(proc)*
- [x] L761   `collide_check_y`  *(proc)*
- [x] L1061  `distance_check_5`  *(proc)*
- [x] L1303  `phase_advance_helper`  *(proc)*

## working/zelres3/code/303EAI3.asm  (6 sections)

- [x] L89    `run_tori_ai_main`  *(proc)*
- [x] L104   `file_header`  *(label word)*
- [x] L153   `tori_frame_00`  *(label word)*
- [x] L298   `tori_aux_records`  *(label word)*
- [x] L809   `tori_dist_check_5`  *(proc)*
- [x] L942   `tori_dist_check_6`  *(proc)*

## working/zelres3/code/304EAI4.asm  (7 sections)

- [x] L96    `run_zela_ai_main`  *(proc)*
- [x] L146   `zela_anim_state_marker`  *(data)*
- [x] L178   `zela_rng_fn_ptr`  *(data)*
- [x] L182   `zela_phase_marker`  *(data)*
- [x] L215   `zela_anim_phase_idx`  *(data)*
- [x] L814   `collide_check_dist`  *(proc)*
- [x] L917   `zela_lookup_state`  *(proc)*

## working/zelres3/code/305EAI5.asm  (13 sections)

- [x] L122   `run_meda_ai_main`  *(proc)*
- [x] L195   `meda_collide_marker`  *(data)*
- [x] L197   `meda_anim_state_ref`  *(data)*
- [x] L237   `meda_rng_fn_ptr`  *(data)*
- [x] L263   `meda_anim_idx_a`  *(data)*
- [x] L266   `meda_anim_idx_b`  *(data)*
- [x] L607   `phase_step_fwd`  *(proc)*
- [x] L636   `collide_check_fwd`  *(proc)*
- [x] L671   `phase_step_back`  *(proc)*
- [x] L699   `collide_check_back`  *(proc)*
- [x] L734   `check_collide_outer_eai5`  *(proc)*
- [x] L761   `check_collide_inner_eai5`  *(proc)*
- [x] L790   `distance_check_4`  *(proc)*

## working/zelres3/code/306EAI6.asm  (14 sections)

- [x] L120   `run_eai6_main`  *(proc)*
- [x] L145   `eai6_anim_phase`  *(data)*
- [x] L149   `eai6_collide_marker`  *(data)*
- [x] L174   `eai6_rng_fn_ptr`  *(data)*
- [x] L433   `distance_check_4`  *(proc)*
- [x] L471   `phase_step_fwd`  *(proc)*
- [x] L500   `collide_check_fwd`  *(proc)*
- [x] L535   `phase_step_back`  *(proc)*
- [x] L563   `collide_check_back`  *(proc)*
- [x] L598   `check_collide_outer_eai6`  *(proc)*
- [x] L625   `check_collide_inner_eai6`  *(proc)*
- [x] L841   `distance_check_8`  *(proc)*
- [x] L987   `sub02_flip_to_state2`  *(proc)*
- [x] L1008  `sub02_block_or_advance`  *(proc)*

## working/zelres3/code/307EAI7.asm  (12 sections)

- [x] L142   `run_eai7_main`  *(proc)*
- [x] L179   `eai7_collide_marker`  *(data)*
- [x] L208   `eai7_rng_fn_ptr`  *(data)*
- [x] L227   `eai7_anim_state_ref`  *(data)*
- [x] L500   `phase_step_fwd`  *(proc)*
- [x] L529   `collide_check_fwd`  *(proc)*
- [x] L564   `phase_step_back`  *(proc)*
- [x] L592   `collide_check_back`  *(proc)*
- [x] L627   `check_collide_outer_eai7`  *(proc)*
- [x] L654   `check_collide_inner_eai7`  *(proc)*
- [x] L692   `distance_check_5`  *(proc)*
- [x] L1032  `distance_check_6`  *(proc)*

## working/zelres3/code/308EAI8.asm  (8 sections)

- [x] L133   `run_eai8_main`  *(proc)*
- [x] L212   `eai8_rng_fn_ptr`  *(data)*
- [x] L415   `collide_check_fwd`  *(proc)*
- [x] L482   `collide_check_back`  *(proc)*
- [x] L709   `rng_pick_facing`  *(proc)*
- [x] L771   `phase_advance_helper`  *(proc)*
- [x] L870   `distance_check_8`  *(proc)*
- [x] L910   `distance_check_5`  *(proc)*

## working/zelres3/code/309CRAB.asm  (8 sections)

- [x] L102   `run_crab_main`  *(proc)*
- [x] L117   `crab_init_src_dst`  *(label word)*
- [x] L192   `crab_const_2600`  *(data)*
- [x] L232   `crab_const_2692`  *(data)*
- [x] L549   `subtract_hp_amount`  *(proc)*
- [x] L567   `add_hp_amount`  *(proc)*
- [x] L874   `emit_sprite_rows_proc`  *(proc)*
- [x] L998   `prep_phase`  *(proc)*

## working/zelres3/code/310TAKO.asm  (5 sections)

- [x] L102   `run_tako_main`  *(proc)*
- [x] L123   `tako_state_template`  *(label word)*
- [x] L659   `subtract_hp_amount`  *(proc)*
- [x] L737   `tako_sprite_src_init`  *(label word)*
- [x] L1153  `tako_proj_pattern`  *(label word)*

## working/zelres3/code/311TORI.asm  (13 sections)

- [x] L110   `run_tori_main`  *(proc)*
- [x] L131   `tori_state_template`  *(label word)*
- [x] L221   `tori_scan_acc_a`  *(data)*
- [x] L223   `tori_scan_acc_b`  *(data)*
- [x] L228   `tori_glyph_tbl`  *(data)*
- [x] L293   `tori_extern_fn_ptr`  *(data)*
- [x] L780   `tori_render_sprite_row`  *(proc)*
- [x] L816   `tori_swoop_tick`  *(proc)*
- [x] L834   `tori_hp_dec_if_ge_D`  *(proc)*
- [x] L850   `tori_hp_dec_if_ge_11`  *(proc)*
- [x] L867   `tori_hp_inc_if_below_30`  *(proc)*
- [x] L887   `tori_apply_damage`  *(proc)*
- [x] L1024  `tori_const_table`  *(label word)*

## working/zelres3/code/312ZELA.asm  (8 sections)

- [x] L106   `run_mapst_main`  *(proc)*
- [x] L153   `zela_const_word_8`  *(data)*
- [x] L186   `zela_rng_fn_ptr`  *(data)*
- [x] L409   `scroll_phase_dec`  *(proc)*
- [x] L645   `init_tile_slots`  *(proc)*
- [x] L671   `bound_xpos_inc`  *(proc)*
- [x] L684   `bound_xpos_dec`  *(proc)*
- [x] L714   `apply_scroll_offset`  *(proc)*

## working/zelres3/code/313MEDA.asm  (13 sections)

- [x] L89    `run_mapbt_main`  *(proc)*
- [x] L116   `header_tile_row_a`  *(data)*
- [x] L127   `header_const_word_a`  *(data)*
- [x] L129   `header_text_table`  *(data)*
- [x] L368   `phase_dir_compute`  *(proc)*
- [x] L424   `phase_clear_cells`  *(proc)*
- [x] L455   `phase_dec_clamped`  *(proc)*
- [x] L462   `phase_inc_clamped`  *(proc)*
- [x] L470   `bound_xpos_inc`  *(proc)*
- [x] L482   `bound_xpos_dec`  *(proc)*
- [x] L493   `render_tiles_main`  *(proc)*
- [x] L603   `render_tile_row`  *(proc)*
- [x] L646   `scroll_step_finalize`  *(proc)*

## working/zelres3/code/314LEGA.asm  (15 sections)

- [x] L107   `run_lega_main`  *(proc)*
- [x] L122   `lega_hdr_fill_a`  *(data)*
- [x] L123   `lega_hdr_const_50`  *(data)*
- [x] L124   `lega_hdr_const_0a_pair`  *(data)*
- [x] L126   `lega_tile_data_block_a`  *(data)*
- [x] L131   `lega_ptr_table_a`  *(data)*
- [x] L153   `lega_tile_data_block_b`  *(data)*
- [x] L155   `lega_tile_data_block_c`  *(data)*
- [x] L423   `lega_phase_step_tbl_a`  *(data)*
- [x] L425   `lega_phase_step_tbl_b`  *(data)*
- [x] L430   `lega_scroll_dec_step`  *(proc)*
- [x] L444   `lega_scroll_inc_step`  *(proc)*
- [x] L656   `lega_render_anim2_cell`  *(proc)*
- [x] L691   `lega_scroll_finalize`  *(proc)*
- [x] L735   `lega_idle_xlat_tbl`  *(data)*

## working/zelres3/code/315ZEL2.asm  (11 sections)

- [x] L102   `run_mapht_main`  *(proc)*
- [x] L136   `zel2_scroll_target_base`  *(data)*
- [x] L143   `zel2_data_word_3115`  *(data)*
- [x] L181   `zel2_rng_fn_ptr`  *(data)*
- [x] L374   `zel2_phase_step_dec`  *(proc)*
- [x] L584   `zel2_npc_render_advance`  *(label byte)*
- [x] L600   `zel2_setup_anim_segment`  *(proc)*
- [x] L626   `zel2_scroll_inc_step`  *(proc)*
- [x] L639   `zel2_scroll_dec_step`  *(proc)*
- [x] L663   `zel2_scroll_finalize`  *(proc)*
- [x] L748   `zel2_trailer_word`  *(data)*

## working/zelres3/code/316DRGN.asm  (12 sections)

- [x] L119   `run_drgn_main`  *(proc)*
- [x] L156   `drgn_tile_data_a`  *(data)*
- [x] L159   `drgn_tile_data_b`  *(data)*
- [x] L166   `drgn_tile_data_c`  *(data)*
- [x] L175   `drgn_tile_data_d`  *(data)*
- [x] L204   `drgn_tile_dispatch_word`  *(data)*
- [x] L541   `drgn_scroll_dec`  *(proc)*
- [x] L556   `drgn_scroll_inc`  *(proc)*
- [x] L812   `drgn_render_col_pack`  *(proc)*
- [x] L854   `drgn_phase_si_tbl_words`  *(label byte)*
- [x] L965   `drgn_phase_step_cb`  *(proc)*
- [x] L1019  `drgn_death_finish`  *(label byte)*

## working/zelres3/code/317AKMA.asm  (11 sections)

- [x] L114   `run_mapa4_main`  *(proc)*
- [x] L143   `akma_data_word_a`  *(data)*
- [x] L145   `akma_data_byte_b`  *(data)*
- [x] L153   `akma_data_byte_c`  *(data)*
- [x] L472   `akma_scroll_dec`  *(proc)*
- [x] L488   `akma_scroll_inc`  *(proc)*
- [x] L813   `akma_render_emit_cell`  *(proc)*
- [x] L842   `akma_render_col_pack`  *(proc)*
- [x] L860   `akma_pack_skip`  *(label byte)*
- [x] L994   `akma_phase_step_cb`  *(proc)*
- [x] L1053  `akma_death_finish`  *(label byte)*

## working/zelres3/code/318MAO1.asm  (18 sections)

- [x] L106   `run_mapa5_main`  *(proc)*
- [x] L115   `start`  *(label byte)*
- [x] L115   `start`  *(label word)*
- [x] L149   `mao1_data_word_a`  *(data)*
- [x] L153   `mao1_data_word_b`  *(data)*
- [x] L157   `mao1_data_word_c`  *(data)*
- [x] L167   `mao1_data_byte_d`  *(data)*
- [x] L173   `mao1_data_byte_e`  *(data)*
- [x] L175   `mao1_layout_cells_ext`  *(label byte)*
- [x] L210   `mao1_layout_data_a`  *(label byte)*
- [x] L274   `mao1_npc_scan_loop`  *(label byte)*
- [x] L464   `mao1_text_fill_loop`  *(label byte)*
- [x] L523   `mao1_dialog_handler_tbl`  *(label word)*
- [x] L536   `mao1_dialog_data_b`  *(label byte)*
- [x] L608   `mao1_arena_ptr_tbl`  *(label byte)*
- [x] L614   `mao1_glyph_atlas`  *(label byte)*
- [x] L626   `mao1_arena_init_params`  *(label byte)*
- [x] L633   `mao1_speaker_jashiin`  *(label byte)*

## working/zelres3/code/319MAO2.asm  (34 sections)

- [x] L162   `run_mapa6_main`  *(proc)*
- [x] L173   `mao2_hdr_byte_5`  *(data)*
- [x] L179   `mao2_layout_extended`  *(data)*
- [x] L171   `start`  *(label byte)*
- [x] L189   `mao2_layout_count_a`  *(data)*
- [x] L191   `mao2_layout_count_b`  *(data)*
- [x] L219   `mao2_layout_cells_a_tail`  *(data)*
- [x] L220   `mao2_dispatch_ptr`  *(data)*
- [x] L222   `mao2_layout_cells_b`  *(label byte)*
- [x] L242   `mao2_main_dispatch`  *(proc)*
- [x] L255   `mao2_layout_cells_c`  *(label byte)*
- [x] L261   `mao2_layout_data_b`  *(data)*
- [x] L263   `mao2_layout_cells_d`  *(label byte)*
- [x] L329   `mao2_npc_scan_loop`  *(label byte)*
- [x] L488   `mao2_phase_step_finish`  *(label byte)*
- [x] L495   `mao2_phase_ofs_data_end`  *(data)*
- [x] L497   `mao2_pick_target_idx`  *(proc)*
- [x] L702   `mao2_handler_step_done`  *(label byte)*
- [x] L724   `mao2_handler_step_data_end`  *(data)*
- [x] L726   `mao2_target_dec`  *(proc)*
- [x] L742   `mao2_target_inc`  *(proc)*
- [x] L989   `mao2_dlg_a_init`  *(proc)*
- [x] L1006  `mao2_dlg_b_init`  *(proc)*
- [x] L1024  `mao2_unpack_bp_to_buf`  *(proc)*
- [x] L1039  `mao2_unpack_skip`  *(label byte)*
- [x] L1125  `mao2_dlg_msg_data_a`  *(label byte)*
- [x] L1129  `mao2_dlg_msg_ptr_tbl_a`  *(label byte)*
- [x] L1137  `mao2_dlg_state_xlat`  *(label byte)*
- [x] L1157  `mao2_dlg_state_xlat_tail`  *(label byte)*
- [x] L1161  `mao2_dlg_handler_tbl_a`  *(label byte)*
- [x] L1214  `mao2_pos_sub_clamp`  *(label byte)*
- [x] L1208  `compute_mao2_pos`  *(proc)*
- [x] L1238  `mao2_pos_step`  *(proc)*
- [x] L1284  `mao2_skip_anim_done`  *(label byte)*

