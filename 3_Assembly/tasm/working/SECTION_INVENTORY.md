# Master section inventory � all .asm files

63 files. Each section listed once. Use `[ ]` checkboxes to track which need their true name/nature determined.

## working/core/game.asm  (20 sections)

- [ ] L213   `game`  *(proc)*
- [ ] L460   `ref_font_grp`  *(data)*
- [ ] L461   `ref_mole`  *(data)*
- [ ] L462   `ref_itemp`  *(data)*
- [ ] L463   `ref_select`  *(data)*
- [ ] L464   `ref_magic`  *(data)*
- [ ] L465   `ref_sword`  *(data)*
- [ ] L466   `ref_fight`  *(data)*
- [ ] L467   `ref_town`  *(data)*
- [ ] L468   `ref_opdemo`  *(data)*
- [ ] L472   `gfx_mode_tbl_ega_lbl`  *(label word)*
- [ ] L488   `gfx_mode_tbl_cga_lbl`  *(label word)*
- [ ] L504   `gfx_mode_tbl_all_lbl`  *(label word)*
- [ ] L533   `load_music_tracks`  *(proc)*
- [ ] L570   `music_track_ref_tbl_lbl`  *(label word)*
- [ ] L589   `set_vga_palette`  *(proc)*
- [ ] L599   `palette_handler_jmp_tbl_lbl`  *(label word)*
- [ ] L685   `palette_base_tbl_lbl`  *(label byte)*
- [ ] L703   `game_init_fn_lbl`  *(label dword)*
- [ ] L707   `save_mode_flag_lbl`  *(label word)*

## working/core/zeliad.asm  (55 sections)

- [ ] L133   `zeliad`  *(proc)*
- [ ] L523   `flush_keyboard`  *(proc)*
- [ ] L543   `read_config_line`  *(proc)*
- [ ] L591   `parse_graphics_mode`  *(proc)*
- [ ] L650   `mode_4char_table`  *(data)*
- [ ] L652   `mode_3char_table`  *(data)*
- [ ] L663   `parse_music_driver`  *(proc)*
- [ ] L688   `str_mscmt_drv`  *(data)*
- [ ] L694   `parse_joystick_name`  *(proc)*
- [ ] L714   `parse_joystick_enable`  *(proc)*
- [ ] L737   `str_yes`  *(data)*
- [ ] L738   `str_no`  *(data)*
- [ ] L754   `find_colon_in_line`  *(proc)*
- [ ] L779   `load_driver_file`  *(proc)*
- [ ] L819   `display_file_error`  *(proc)*
- [ ] L882   `set_video_mode`  *(proc)*
- [ ] L888   `video_mode_table`  *(data)*
- [ ] L958   `hgc_crt_params`  *(data)*
- [ ] L965   `ctrl_c_handler`  *(proc)*
- [ ] L975   `parse_command_line`  *(proc)*
- [ ] L1029  `str_game_title`  *(data)*
- [ ] L1035  `str_not_supported`  *(data)*
- [ ] L1036  `str_special_mode`  *(data)*
- [ ] L1037  `str_not_enough_mem`  *(data)*
- [ ] L1039  `str_memory_error`  *(data)*
- [ ] L1040  `str_thank_you`  *(data)*
- [ ] L1042  `str_file_error`  *(data)*
- [ ] L1043  `str_error_type`  *(data)*
- [ ] L1044  `str_file_not_found`  *(data)*
- [ ] L1045  `str_disk_error`  *(data)*
- [ ] L1046  `str_user_file_error`  *(data)*
- [ ] L1047  `str_cfg_error`  *(data)*
- [ ] L1054  `hex_digits_hi`  *(data)*
- [ ] L1055  `hex_digits_lo`  *(data)*
- [ ] L1057  `cfg_filename`  *(data)*
- [ ] L1058  `mtinit_filename`  *(data)*
- [ ] L1061  `driver_offset_table`  *(data)*
- [ ] L1101  `cmdline_savefile`  *(data)*
- [ ] L1104  `music_driver_name`  *(data)*
- [ ] L1107  `joystick_driver_name`  *(data)*
- [ ] L1110  `game_entry_ofs`  *(data)*
- [ ] L1111  `game_entry_seg`  *(data)*
- [ ] L1113  `saved_int08_ofs`  *(data)*
- [ ] L1114  `saved_int09_ofs`  *(data)*
- [ ] L1115  `saved_int60_ofs`  *(data)*
- [ ] L1116  `saved_int61_ofs`  *(data)*
- [ ] L1117  `saved_int61_seg`  *(data)*
- [ ] L1119  `has_savefile`  *(data)*
- [ ] L1120  `saved_sp`  *(data)*
- [ ] L1121  `saved_ss`  *(data)*
- [ ] L1141  `graphics_mode`  *(data)*
- [ ] L1142  `mt32_enabled`  *(data)*
- [ ] L1149  `joystick_enabled`  *(data)*
- [ ] L1150  `cfg_line_length`  *(data)*
- [ ] L1151  `cfg_line_buffer`  *(data)*

## working/drivers/gmcga.asm  (19 sections)

- [ ] L136   `gmcga`  *(proc)*
- [ ] L228   `fill_horizontal_line`  *(proc)*
- [ ] L252   `clear_screen`  *(proc)*
- [ ] L438   `plot_pixel`  *(proc)*
- [ ] L605   `calc_text_width`  *(proc)*
- [ ] L628   `fill_vertical_line`  *(proc)*
- [ ] L729   `render_text_char`  *(proc)*
- [ ] L869   `init_timestamp`  *(proc)*
- [ ] L890   `time_to_bcd`  *(proc)*
- [ ] L917   `modulo_divide_bcd`  *(proc)*
- [ ] L942   `int_divide_bcd`  *(proc)*
- [ ] L952   `render_tilemap_large`  *(proc)*
- [ ] L993   `decode_bitplane_tile`  *(proc)*
- [ ] L1257  `render_tilemap_small`  *(proc)*
- [ ] L1323  `extract_bitplane_pixels`  *(proc)*
- [ ] L1363  `render_text_char_alt`  *(proc)*
- [ ] L1435  `expand_font_bits`  *(proc)*
- [ ] L1721  `fill_rectangle`  *(proc)*
- [ ] L1933  `process_sprite_row`  *(proc)*

## working/drivers/gmega.asm  (16 sections)

- [ ] L129   `gmega`  *(proc)*
- [ ] L220   `fill_horizontal_line`  *(proc)*
- [ ] L284   `clear_screen`  *(proc)*
- [ ] L486   `plot_pixel`  *(proc)*
- [ ] L680   `calc_text_width`  *(proc)*
- [ ] L703   `fill_vertical_line`  *(proc)*
- [ ] L796   `render_text_char`  *(proc)*
- [ ] L942   `init_timestamp`  *(proc)*
- [ ] L965   `time_to_bcd`  *(proc)*
- [ ] L992   `modulo_divide_bcd`  *(proc)*
- [ ] L1017  `int_divide_bcd`  *(proc)*
- [ ] L1027  `render_tilemap_large`  *(proc)*
- [ ] L1062  `decode_bitplane_tile`  *(proc)*
- [ ] L1342  `render_tilemap_small`  *(proc)*
- [ ] L1439  `render_text_char_alt`  *(proc)*
- [ ] L1809  `fill_rectangle`  *(proc)*

## working/drivers/gmhgc.asm  (22 sections)

- [ ] L127   `gmhgc`  *(proc)*
- [ ] L221   `fill_horizontal_line`  *(proc)*
- [ ] L259   `clear_screen`  *(proc)*
- [ ] L281   `clear_screen_row`  *(proc)*
- [ ] L403   `fade_screen_row`  *(proc)*
- [ ] L489   `plot_pixel`  *(proc)*
- [ ] L666   `calc_text_width`  *(proc)*
- [ ] L689   `fill_vertical_line`  *(proc)*
- [ ] L778   `render_text_char`  *(proc)*
- [ ] L924   `init_timestamp`  *(proc)*
- [ ] L946   `time_to_bcd`  *(proc)*
- [ ] L973   `modulo_divide_bcd`  *(proc)*
- [ ] L998   `int_divide_bcd`  *(proc)*
- [ ] L1008  `render_tilemap_large`  *(proc)*
- [ ] L1047  `decode_bitplane_tile`  *(proc)*
- [ ] L1324  `render_tilemap_small`  *(proc)*
- [ ] L1395  `extract_bitplane_pixels`  *(proc)*
- [ ] L1433  `render_text_char_alt`  *(proc)*
- [ ] L1519  `double_char_bits`  *(proc)*
- [ ] L1789  `fill_rectangle`  *(proc)*
- [ ] L1933  `calc_hgc_address`  *(proc)*
- [ ] L1984  `process_sprite_row`  *(proc)*

## working/drivers/gmmcga.asm  (21 sections)

- [ ] L122   `gmmcga`  *(proc)*
- [ ] L223   `fill_horizontal_line`  *(proc)*
- [ ] L252   `clear_screen`  *(proc)*
- [ ] L303   `font_render_code`  *(data)*
- [ ] L407   `plot_pixel`  *(proc)*
- [ ] L539   `calc_text_width`  *(proc)*
- [ ] L554   `fill_vertical_line`  *(proc)*
- [ ] L635   `render_text_char`  *(proc)*
- [ ] L747   `init_timestamp`  *(proc)*
- [ ] L768   `time_to_bcd`  *(proc)*
- [ ] L795   `modulo_divide_bcd`  *(proc)*
- [ ] L820   `int_divide_bcd`  *(proc)*
- [ ] L830   `render_tilemap_large`  *(proc)*
- [ ] L878   `decode_bitplane_tile`  *(proc)*
- [ ] L1111  `render_tilemap_small`  *(proc)*
- [ ] L1152  `extract_bitplane_pixels`  *(proc)*
- [ ] L1177  `render_text_char_alt`  *(proc)*
- [ ] L1455  `fill_rectangle`  *(proc)*
- [ ] L1649  `process_sprite_row`  *(proc)*
- [ ] L1671  `bitplane_to_pixels`  *(proc)*
- [ ] L1696  `extract_bitplane_bit`  *(proc)*

## working/drivers/gmtga.asm  (20 sections)

- [ ] L95    `gmtga`  *(proc)*
- [ ] L187   `fill_horizontal_line`  *(proc)*
- [ ] L211   `clear_screen`  *(proc)*
- [ ] L437   `plot_pixel`  *(proc)*
- [ ] L618   `calc_text_width`  *(proc)*
- [ ] L641   `fill_vertical_line`  *(proc)*
- [ ] L742   `render_text_char`  *(proc)*
- [ ] L838   `extract_bitplane_bit`  *(proc)*
- [ ] L942   `init_timestamp`  *(proc)*
- [ ] L963   `time_to_bcd`  *(proc)*
- [ ] L990   `modulo_divide_bcd`  *(proc)*
- [ ] L1015  `int_divide_bcd`  *(proc)*
- [ ] L1025  `render_tilemap_large`  *(proc)*
- [ ] L1065  `decode_bitplane_tile`  *(proc)*
- [ ] L1327  `render_tilemap_small`  *(proc)*
- [ ] L1384  `extract_bitplane_pixels`  *(proc)*
- [ ] L1430  `render_text_char_alt`  *(proc)*
- [ ] L1773  `fill_rectangle`  *(proc)*
- [ ] L1973  `process_sprite_row`  *(proc)*
- [ ] L2002  `bitplane_to_pixels`  *(proc)*

## working/drivers/stdply.asm  (97 sections)

- [ ] L53    `stdply`  *(proc)*
- [ ] L64    `key_map_table`  *(data)*
- [x] L87    `starting_position_in_town`  *(data)*
- [ ] L88    `map_scroll_row`  *(data)*
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
- [ ] L259   `boss_intro_flag`  *(data)*
- [x] L271   `save_sage`  *(data)*
- [x] L272   `last_sage_visited`  *(data)*
- [ ] L276   `heal_pulse_count`  *(data)*
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
- [ ] L333   `key_count`  *(data)*
- [x] L334   `sages_spoken_bitmap`  *(data)*
- [ ] L335   `scene_trans_request`  *(data)*
- [ ] L336   `gvar_pose_idx`  *(data)*
- [ ] L337   `init_complete_flag`  *(data)*

## working/drivers/stick.asm  (37 sections)

- [ ] L142   `stick`  *(proc)*
- [ ] L167   `handle_pause_key`  *(proc)*
- [ ] L204   `poll_joystick_buttons`  *(proc)*
- [ ] L220   `decode_joystick_bits`  *(proc)*
- [ ] L266   `handle_special_keys`  *(proc)*
- [ ] L351   `subsample_ctr_lbl`  *(label byte)*
- [ ] L354   `chain_int_ctr_lbl`  *(label byte)*
- [ ] L357   `pause_key_state_lbl`  *(label byte)*
- [ ] L423   `process_scancode`  *(proc)*
- [ ] L637   `dispatch_extended_key`  *(proc)*
- [ ] L704   `calibrate_joystick`  *(proc)*
- [ ] L761   `calc_joystick_deadzone`  *(proc)*
- [ ] L923   `draw_screen_element`  *(proc)*
- [ ] L1000  `wait_for_digit_or_esc`  *(proc)*
- [ ] L1038  `joy_calibrate_request`  *(proc)*
- [ ] L1154  `enter_pause_menu_and_draw`  *(proc)*
- [ ] L1158  `draw_pause_menu_box`  *(proc)*
- [ ] L1170  `restore_pause_menu_bg`  *(proc)*
- [ ] L1178  `flush_dos_kbd_buffer`  *(proc)*
- [ ] L1268  `scan_data_lbl`  *(label word)*
- [ ] L1420  `herc_seg_table`  *(data)*
- [ ] L1516  `fio_open_savefile_retry`  *(proc)*
- [ ] L1657  `fio_filename_lbl`  *(label byte)*
- [ ] L1660  `fio_disk_msg_lbl`  *(label byte)*
- [ ] L1666  `fio_slot_flag_lbl`  *(label byte)*
- [ ] L1669  `fio_seek_buf_lbl`  *(label byte)*
- [ ] L1672  `fio_default_name_lbl`  *(label byte)*
- [ ] L1675  `fio_read_write_block`  *(proc)*
- [ ] L1689  `fio_close_file`  *(proc)*
- [ ] L1713  `fio_load_decompressed`  *(proc)*
- [ ] L1751  `dcmp_loop_anchor_a`  *(proc)*
- [ ] L1819  `dcmp_loop_anchor_b`  *(proc)*
- [ ] L1906  `dcmp_loop_anchor_c`  *(proc)*
- [ ] L2033  `savefile_desc_ptr`  *(data)*
- [ ] L2034  `file_read_buf_ptr`  *(data)*
- [ ] L2035  `file_read_count`  *(data)*
- [ ] L2036  `file_sector_ptr`  *(data)*

## working/zelres1/code/100OPDMO.asm  (44 sections)

- [ ] L259   `opening_scene_main`  *(proc)*
- [ ] L458   `sprite_anim_proc`  *(proc)*
- [ ] L488   `char_render_proc`  *(proc)*
- [ ] L543   `animate_scanline`  *(proc)*
- [ ] L591   `timer_wait_loop`  *(proc)*
- [ ] L604   `interrupt_handler_cascade`  *(proc)*
- [ ] L653   `scene_transition_wait`  *(proc)*
- [ ] L679   `credits_scroll_display`  *(proc)*
- [ ] L999   `story_scene_timer_loop`  *(proc)*
- [ ] L1010  `story_scene_input_handler`  *(proc)*
- [ ] L1058  `script_interpreter`  *(proc)*
- [ ] L1357  `calc_text_width`  *(proc)*
- [ ] L1414  `animate_scanline_alt`  *(proc)*
- [ ] L1471  `decompress_image`  *(proc)*
- [ ] L1475  `rle_unpack_core`  *(proc)*
- [ ] L1564  `fill_buffer`  *(proc)*
- [ ] L1600  `palette_lookup`  *(proc)*
- [ ] L1626  `render_font_row_double`  *(proc)*
- [ ] L1638  `render_font_row_inverse`  *(proc)*
- [ ] L1650  `copy_buffer`  *(proc)*
- [ ] L1677  `busy_wait_delay`  *(proc)*
- [ ] L1693  `color_rotation`  *(proc)*
- [ ] L1720  `palette_blend`  *(proc)*
- [ ] L1771  `xor_mask_render`  *(proc)*
- [ ] L1817  `merge_gfx_planes`  *(proc)*
- [ ] L2012  `jashiin_speech_2`  *(data)*
- [ ] L2021  `narration_stone_scene`  *(data)*
- [ ] L2500  `jashiin_disappear_text`  *(data)*
- [ ] L2502  `anim_fn_wipe`  *(data)*
- [ ] L2503  `anim_fn_fade`  *(data)*
- [ ] L2504  `anim_fn_draw`  *(data)*
- [ ] L2515  `disp_game_fn`  *(data)*
- [ ] L2516  `disp_data_6F59`  *(data)*
- [ ] L2517  `disp_narr_chap2`  *(data)*
- [ ] L2518  `disp_chap2_call`  *(data)*
- [ ] L2519  `disp_drv_seg_3`  *(data)*
- [ ] L2520  `disp_narr_chap3`  *(data)*
- [ ] L2521  `disp_narr_open`  *(data)*
- [ ] L2522  `disp_set_drv_seg`  *(data)*
- [ ] L2523  `disp_font_inv`  *(data)*
- [ ] L2524  `disp_data_7420`  *(data)*
- [ ] L2525  `disp_load_setup`  *(data)*
- [ ] L2526  `disp_script_area`  *(data)*
- [ ] L2528  `disp_narr_chap4`  *(data)*

## working/zelres1/code/101GDEGA.asm  (24 sections)

- [ ] L96    `imgctl_module`  *(proc)*
- [ ] L327   `imgctl_multiply`  *(proc)*
- [ ] L357   `vga_operation`  *(proc)*
- [ ] L410   `imgctl_process_loop`  *(proc)*
- [ ] L438   `imgctl_process_loop_2`  *(proc)*
- [ ] L581   `copy_vga_buffer`  *(proc)*
- [x] L865   `copy_buffer`  *(proc)*
- [x] L886   `copy_buffer_2`  *(proc)*
- [ ] L907   `imgctl_process_loop_3`  *(proc)*
- [ ] L1003  `copy_buffer_3`  *(proc)*
- [ ] L1077  `imgctl_multiply_2`  *(proc)*
- [ ] L1436  `imgctl_func_11`  *(proc)*
- [ ] L1623  `imgctl_multiply_3`  *(proc)*
- [ ] L1788  `imgctl_process_loop_4`  *(proc)*
- [ ] L1814  `imgctl_process_loop_5`  *(proc)*
- [ ] L1858  `imgctl_func_15`  *(proc)*
- [ ] L1989  `copy_buffer_4`  *(proc)*
- [ ] L2016  `copy_buffer_5`  *(proc)*
- [ ] L2067  `imgctl_process_loop_6`  *(proc)*
- [x] L2123  `fill_buffer`  *(proc)*
- [ ] L2166  `vga_operation0`  *(proc)*
- [ ] L2284  `vga_operation2`  *(proc)*
- [ ] L2360  `vga_operation4`  *(proc)*
- [ ] L2435  `hscroll_plane4_buf`  *(data)*

## working/zelres1/code/102GDCGA.asm  (22 sections)

- [ ] L114   `cga_imgctl_module`  *(proc)*
- [ ] L305   `equip_func_1`  *(proc)*
- [ ] L527   `equip_process_loop`  *(proc)*
- [x] L871   `copy_buffer`  *(proc)*
- [x] L897   `copy_buffer_2`  *(proc)*
- [ ] L923   `equip_multiply`  *(proc)*
- [ ] L976   `plane_mix_word`  *(data)*
- [ ] L1056  `equip_multiply_2`  *(proc)*
- [ ] L1333  `equip_func_7`  *(proc)*
- [ ] L1519  `extract_bits`  *(proc)*
- [x] L1617  `fill_buffer`  *(proc)*
- [x] L1630  `clear_buffer`  *(proc)*
- [ ] L1660  `equip_get_value`  *(proc)*
- [ ] L1787  `equip_process_loop_2`  *(proc)*
- [ ] L1806  `equip_process_loop_3`  *(proc)*
- [ ] L1857  `equip_process_loop_4`  *(proc)*
- [x] L1913  `fill_buffer_2`  *(proc)*
- [ ] L1956  `extract_bits_2`  *(proc)*
- [ ] L2028  `disp_frame_render3`  *(data)*
- [ ] L2057  `extract_bits_3`  *(proc)*
- [ ] L2280  `frame_plane_b_tbl`  *(data)*
- [ ] L2500  `equip_process_loop_5`  *(proc)*

## working/zelres1/code/103GDHGC.asm  (24 sections)

- [ ] L147   `hgc_gfx_driver`  *(proc)*
- [ ] L313   `imgdec_func_1`  *(proc)*
- [ ] L552   `imgdec_process_loop`  *(proc)*
- [ ] L638   `imgdec_process_loop_2`  *(proc)*
- [x] L911   `copy_buffer`  *(proc)*
- [x] L935   `copy_buffer_2`  *(proc)*
- [ ] L969   `imgdec_multiply`  *(proc)*
- [ ] L996   `imgdec_process_loop_3`  *(proc)*
- [ ] L1026  `data_3`  *(data)*
- [ ] L1108  `imgdec_multiply_2`  *(proc)*
- [ ] L1463  `imgdec_func_9`  *(proc)*
- [ ] L1633  `imgdec_multiply_3`  *(proc)*
- [x] L1752  `fill_buffer`  *(proc)*
- [x] L1779  `clear_buffer`  *(proc)*
- [ ] L1819  `imgdec_get_value`  *(proc)*
- [ ] L1941  `imgdec_scan_loop`  *(proc)*
- [ ] L1968  `imgdec_scan_loop_2`  *(proc)*
- [ ] L2043  `imgdec_process_loop_4`  *(proc)*
- [x] L2099  `fill_buffer_2`  *(proc)*
- [ ] L2142  `imgdec_multiply_4`  *(proc)*
- [ ] L2270  `imgdec_multiply_5`  *(proc)*
- [ ] L2452  `data_40`  *(data)*
- [ ] L2728  `imgdec_process_loop_5`  *(proc)*
- [ ] L2806  `math_calc`  *(proc)*

## working/zelres1/code/104GDTGA.asm  (27 sections)

- [ ] L109   `zr1_04`  *(proc)*
- [ ] L316   `stats_func_1`  *(proc)*
- [ ] L566   `stats_func_2`  *(proc)*
- [x] L893   `copy_buffer`  *(proc)*
- [x] L917   `copy_buffer_2`  *(proc)*
- [ ] L941   `stats_multiply`  *(proc)*
- [ ] L996   `xor3_plane2_off`  *(data)*
- [ ] L1028  `face_panel2_anchor`  *(data)*
- [ ] L1117  `stats_multiply_2`  *(proc)*
- [ ] L1430  `stats_func_7`  *(proc)*
- [ ] L1482  `extract_bits`  *(proc)*
- [ ] L1652  `stats_multiply_3`  *(proc)*
- [x] L1751  `fill_buffer`  *(proc)*
- [x] L1763  `clear_buffer`  *(proc)*
- [ ] L1790  `stats_get_value`  *(proc)*
- [ ] L1913  `stats_process_loop`  *(proc)*
- [ ] L1937  `stats_process_loop_2`  *(proc)*
- [ ] L1993  `stats_process_loop_3`  *(proc)*
- [x] L2049  `fill_buffer_2`  *(proc)*
- [ ] L2092  `stats_multiply_4`  *(proc)*
- [ ] L2196  `stats_fill_buf`  *(proc)*
- [ ] L2383  `face_color_lut`  *(data)*
- [ ] L2602  `stats_process_loop_4`  *(proc)*
- [ ] L2640  `stats_func_20`  *(proc)*
- [ ] L2714  `extract_bits_2`  *(proc)*
- [ ] L2735  `palette_xlat_jmp`  *(data)*
- [ ] L2737  `plane3_merge_buf`  *(data)*

## working/zelres1/code/105GDMCA.asm  (25 sections)

- [ ] L113   `mcga_imgctl_module`  *(proc)*
- [ ] L319   `vga_operation`  *(proc)*
- [ ] L522   `pal_func_2`  *(proc)*
- [x] L860   `copy_buffer`  *(proc)*
- [x] L879   `copy_buffer_2`  *(proc)*
- [ ] L898   `pal_multiply`  *(proc)*
- [ ] L956   `scroll_a_plane_b`  *(data)*
- [ ] L1078  `pal_multiply_2`  *(proc)*
- [ ] L1401  `pal_func_7`  *(proc)*
- [ ] L1446  `extract_bits`  *(proc)*
- [ ] L1620  `pal_multiply_3`  *(proc)*
- [x] L1715  `fill_buffer`  *(proc)*
- [x] L1725  `clear_buffer`  *(proc)*
- [ ] L1748  `vga_operation2`  *(proc)*
- [ ] L1873  `vga_operation3`  *(proc)*
- [ ] L1901  `vga_operation4`  *(proc)*
- [ ] L1965  `vga_operation5`  *(proc)*
- [x] L2021  `fill_buffer_2`  *(proc)*
- [ ] L2064  `vga_operation7`  *(proc)*
- [ ] L2172  `vga_operation8`  *(proc)*
- [ ] L2241  `vga_operation9`  *(proc)*
- [ ] L2384  `pal_process_loop`  *(proc)*
- [ ] L2413  `pal_func_21`  *(proc)*
- [ ] L2439  `pal_multiply_4`  *(proc)*
- [ ] L2455  `pixel_plane_c_buf`  *(data)*

## working/zelres1/code/106TOWN.asm  (58 sections)

- [ ] L232   `townb_main`  *(proc)*
- [ ] L240   `data_5`  *(data)*
- [ ] L466   `player_func_1`  *(proc)*
- [ ] L550   `player_func_2`  *(proc)*
- [ ] L610   `player_func_3`  *(proc)*
- [ ] L648   `player_multiply`  *(proc)*
- [ ] L654   `player_func_5`  *(proc)*
- [ ] L870   `player_func_6`  *(proc)*
- [ ] L911   `player_func_7`  *(proc)*
- [ ] L941   `player_func_8`  *(proc)*
- [ ] L1077  `player_func_9`  *(proc)*
- [ ] L1103  `math_calc`  *(proc)*
- [ ] L1252  `player_scan_loop`  *(proc)*
- [ ] L1277  `player_func_12`  *(proc)*
- [ ] L1299  `player_multiply_2`  *(proc)*
- [ ] L1303  `player_func_14`  *(proc)*
- [ ] L1331  `fill_buffer`  *(proc)*
- [ ] L1353  `player_process_loop`  *(proc)*
- [ ] L1369  `player_func_17`  *(proc)*
- [ ] L1397  `player_func_18`  *(proc)*
- [ ] L1513  `player_scan_loop_2`  *(proc)*
- [ ] L1536  `player_func_20`  *(proc)*
- [ ] L1540  `player_func_21`  *(proc)*
- [ ] L1553  `player_func_22`  *(proc)*
- [ ] L1557  `player_func_23`  *(proc)*
- [ ] L1566  `player_load_chunk`  *(proc)*
- [ ] L1593  `player_func_25`  *(proc)*
- [ ] L1635  `player_func_26`  *(proc)*
- [ ] L1783  `player_func_27`  *(proc)*
- [ ] L1807  `player_func_28`  *(proc)*
- [ ] L1833  `player_func_29`  *(proc)*
- [ ] L1871  `player_func_30`  *(proc)*
- [ ] L1935  `player_func_31`  *(proc)*
- [ ] L1978  `player_func_32`  *(proc)*
- [ ] L2007  `player_func_33`  *(proc)*
- [ ] L2227  `player_func_34`  *(proc)*
- [ ] L2384  `player_scan_loop_3`  *(proc)*
- [ ] L2403  `player_func_36`  *(proc)*
- [ ] L2435  `player_func_37`  *(proc)*
- [ ] L2450  `player_func_38`  *(proc)*
- [ ] L2476  `player_check_state`  *(proc)*
- [ ] L2522  `player_check_state_2`  *(proc)*
- [ ] L2641  `player_func_41`  *(proc)*
- [ ] L2670  `player_func_42`  *(proc)*
- [ ] L2684  `player_func_43`  *(proc)*
- [ ] L2837  `player_multiply_3`  *(proc)*
- [ ] L2847  `player_multiply_4`  *(proc)*
- [ ] L2874  `player_multiply_5`  *(proc)*
- [ ] L2901  `player_func_47`  *(proc)*
- [ ] L2938  `player_multiply_6`  *(proc)*
- [ ] L3017  `clear_buffer`  *(proc)*
- [ ] L3109  `copy_buffer`  *(proc)*
- [ ] L3250  `player_func_51`  *(proc)*
- [ ] L3268  `fill_buffer_2`  *(proc)*
- [ ] L3286  `player_process_loop_2`  *(proc)*
- [ ] L3317  `player_copy_buf`  *(proc)*
- [ ] L3602  `player_func_55`  *(proc)*
- [ ] L3653  `player_func_56`  *(proc)*

## working/zelres1/code/107GTEGA.asm  (26 sections)

- [ ] L105   `zr1_07`  *(proc)*
- [ ] L251   `vga_operation`  *(proc)*
- [ ] L296   `vgadec_multiply`  *(proc)*
- [ ] L303   `vgadec_func_3`  *(proc)*
- [ ] L433   `vgadec_func_4`  *(proc)*
- [ ] L688   `tile_col6_render`  *(proc)*
- [ ] L692   `vgadec_func_5`  *(proc)*
- [ ] L696   `vgadec_func_6`  *(proc)*
- [ ] L835   `vgadec_multiply_2`  *(proc)*
- [ ] L903   `vgadec_func_8`  *(proc)*
- [ ] L920   `vgadec_func_9`  *(proc)*
- [ ] L924   `vga_operation0`  *(proc)*
- [ ] L937   `vga_operation1`  *(proc)*
- [ ] L972   `vga_operation2`  *(proc)*
- [ ] L994   `vga_operation3`  *(proc)*
- [ ] L1018  `vga_operation4`  *(proc)*
- [ ] L1073  `vga_operation_2`  *(proc)*
- [ ] L1135  `vga_operation6`  *(proc)*
- [ ] L1549  `vga_operation7`  *(proc)*
- [ ] L1575  `vga_operation8`  *(proc)*
- [ ] L1636  `vga_operation9`  *(proc)*
- [ ] L1668  `vgadec_process_loop`  *(proc)*
- [ ] L1704  `vgadec_process_loop_2`  *(proc)*
- [ ] L1725  `vgadec_func_22`  *(proc)*
- [ ] L1752  `vgadec_func_23`  *(proc)*
- [ ] L1777  `vgadec_func_24`  *(proc)*

## working/zelres1/code/108GTCGA.asm  (27 sections)

- [ ] L116   `zr1_08`  *(proc)*
- [ ] L247   `cga_check_blit_col`  *(proc)*
- [ ] L289   `draw_door_tile`  *(proc)*
- [ ] L296   `draw_opaque_tile`  *(proc)*
- [ ] L467   `draw_masked_tile`  *(proc)*
- [ ] L592   `load_6tiles_to_buf`  *(proc)*
- [ ] L596   `load_tiles_to_buf`  *(proc)*
- [ ] L711   `draw_door_init`  *(proc)*
- [ ] L775   `find_nonfd_entry`  *(proc)*
- [ ] L792   `scan_entity_tbl`  *(proc)*
- [ ] L796   `scan_entity_next`  *(proc)*
- [ ] L809   `blit_3rows_to_cga`  *(proc)*
- [ ] L875   `dispatch_draw_value`  *(proc)*
- [ ] L897   `calc_tile_cga_ofs`  *(proc)*
- [ ] L923   `find_entity_at_row`  *(proc)*
- [ ] L964   `load_tiles_3_from_b`  *(proc)*
- [ ] L1033  `blend_tile_planes`  *(proc)*
- [ ] L1364  `render_string`  *(proc)*
- [ ] L1390  `render_char_glyph`  *(proc)*
- [ ] L1460  `render_char_set`  *(proc)*
- [ ] L1492  `render_char_row`  *(proc)*
- [ ] L1537  `init_status_buf`  *(proc)*
- [ ] L1558  `convert_time_bcd`  *(proc)*
- [ ] L1585  `bcd_extract_sub`  *(proc)*
- [ ] L1610  `bcd_extract_div`  *(proc)*
- [ ] L1996  `encode_bitplanes_cga`  *(proc)*
- [ ] L2036  `encode_mask_cga`  *(proc)*

## working/zelres1/code/109GTHGC.asm  (34 sections)

- [ ] L107   `zr1_09`  *(proc)*
- [ ] L239   `decb_scan_loop`  *(proc)*
- [ ] L281   `decb_func_2`  *(proc)*
- [ ] L288   `decb_func_3`  *(proc)*
- [ ] L388   `decb_func_4`  *(proc)*
- [ ] L524   `decb_func_5`  *(proc)*
- [ ] L528   `decb_func_6`  *(proc)*
- [ ] L659   `decb_multiply`  *(proc)*
- [ ] L723   `decb_func_8`  *(proc)*
- [ ] L740   `decb_func_9`  *(proc)*
- [ ] L744   `decb_func_10`  *(proc)*
- [ ] L757   `decb_scan_loop_2`  *(proc)*
- [ ] L776   `decb_get_value`  *(proc)*
- [ ] L803   `decb_multiply_2`  *(proc)*
- [ ] L827   `decb_scan_loop_3`  *(proc)*
- [ ] L881   `decb_multiply_3`  *(proc)*
- [ ] L952   `decb_process_loop`  *(proc)*
- [ ] L1020  `copy_buffer`  *(proc)*
- [ ] L1035  `copy_buffer_2`  *(proc)*
- [ ] L1075  `copy_buffer_3`  *(proc)*
- [ ] L1124  `copy_buffer_4`  *(proc)*
- [ ] L1139  `copy_buffer_5`  *(proc)*
- [ ] L1177  `copy_buffer_6`  *(proc)*
- [ ] L1342  `decb_func_23`  *(proc)*
- [ ] L1368  `decb_func_24`  *(proc)*
- [ ] L1438  `decb_process_loop_2`  *(proc)*
- [ ] L1470  `decb_process_loop_3`  *(proc)*
- [ ] L1515  `decb_process_loop_4`  *(proc)*
- [ ] L1536  `decb_func_28`  *(proc)*
- [ ] L1563  `decb_func_29`  *(proc)*
- [ ] L1588  `decb_func_30`  *(proc)*
- [ ] L1992  `decb_process_loop_5`  *(proc)*
- [ ] L2034  `decb_scan_loop_4`  *(proc)*
- [ ] L2057  `math_calc`  *(proc)*

## working/zelres1/code/110GTTGA.asm  (30 sections)

- [ ] L96    `tga_module_entry`  *(proc)*
- [ ] L234   `limg_scan_loop`  *(proc)*
- [ ] L276   `limg_multiply`  *(proc)*
- [ ] L283   `limg_func_3`  *(proc)*
- [ ] L455   `limg_func_4`  *(proc)*
- [ ] L615   `limg_func_5`  *(proc)*
- [ ] L619   `limg_func_6`  *(proc)*
- [ ] L733   `limg_multiply_2`  *(proc)*
- [ ] L797   `limg_func_8`  *(proc)*
- [ ] L814   `limg_func_9`  *(proc)*
- [ ] L818   `limg_func_10`  *(proc)*
- [ ] L831   `limg_check_state`  *(proc)*
- [ ] L911   `limg_get_value`  *(proc)*
- [ ] L932   `limg_multiply_3`  *(proc)*
- [ ] L956   `limg_scan_loop_2`  *(proc)*
- [ ] L1009  `limg_multiply_4`  *(proc)*
- [ ] L1084  `limg_process_loop`  *(proc)*
- [ ] L1423  `limg_func_17`  *(proc)*
- [ ] L1449  `limg_func_18`  *(proc)*
- [ ] L1500  `limg_func_19`  *(proc)*
- [ ] L1540  `limg_process_loop_2`  *(proc)*
- [ ] L1568  `limg_process_loop_3`  *(proc)*
- [ ] L1600  `limg_process_loop_4`  *(proc)*
- [ ] L1624  `limg_func_23`  *(proc)*
- [ ] L1651  `limg_func_24`  *(proc)*
- [ ] L1676  `limg_func_25`  *(proc)*
- [ ] L2107  `limg_process_loop_5`  *(proc)*
- [ ] L2150  `limg_scan_loop_3`  *(proc)*
- [ ] L2173  `extract_bits`  *(proc)*
- [ ] L2191  `limg_process_loop_6`  *(proc)*

## working/zelres1/code/111GTMCA.asm  (29 sections)

- [ ] L115   `zr1_11`  *(proc)*
- [ ] L243   `vga_operation`  *(proc)*
- [ ] L287   `simg_multiply`  *(proc)*
- [ ] L294   `simg_func_3`  *(proc)*
- [ ] L397   `simg_func_4`  *(proc)*
- [ ] L566   `simg_func_5_alt`  *(proc)*
- [ ] L570   `simg_func_5`  *(proc)*
- [ ] L574   `simg_func_6`  *(proc)*
- [ ] L708   `simg_multiply_2`  *(proc)*
- [ ] L771   `simg_func_8`  *(proc)*
- [ ] L788   `simg_func_9`  *(proc)*
- [ ] L792   `vga_operation0`  *(proc)*
- [ ] L805   `vga_operation1`  *(proc)*
- [ ] L820   `vga_operation2`  *(proc)*
- [ ] L846   `vga_operation3`  *(proc)*
- [ ] L870   `vga_operation4`  *(proc)*
- [ ] L920   `vga_operation_2`  *(proc)*
- [ ] L999   `vga_operation6`  *(proc)*
- [ ] L1356  `vga_operation7`  *(proc)*
- [ ] L1378  `extract_bits`  *(proc)*
- [ ] L1438  `vga_operation9`  *(proc)*
- [ ] L1466  `simg_process_loop`  *(proc)*
- [ ] L1502  `simg_process_loop_2`  *(proc)*
- [ ] L1523  `simg_func_22`  *(proc)*
- [ ] L1550  `simg_func_23`  *(proc)*
- [ ] L1575  `simg_func_24`  *(proc)*
- [ ] L1957  `simg_process_loop_3`  *(proc)*
- [ ] L1982  `simg_func_26`  *(proc)*
- [ ] L1993  `simg_scan_loop`  *(proc)*

## working/zelres2/code/200FIGHT.asm  (151 sections)

- [ ] L631   `zr2_00`  *(proc)*
- [ ] L756   `vga_operation`  *(proc)*
- [ ] L941   `combat_input_dispatcher`  *(proc)*
- [ ] L1026  `decide_scroll_direction`  *(proc)*
- [ ] L1064  `process_combat_update_step`  *(proc)*
- [ ] L1145  `combat_step_dispatch`  *(proc)*
- [ ] L1192  `apply_pending_invul`  *(proc)*
- [ ] L1285  `try_combat_advance`  *(proc)*
- [ ] L1338  `scroll_up_and_advance_state`  *(proc)*
- [ ] L1402  `try_scroll_advance`  *(proc)*
- [ ] L1546  `check_area_7_boundary`  *(proc)*
- [ ] L1611  `toggle_c2_bit_pose`  *(proc)*
- [ ] L1636  `game_process_loop`  *(proc)*
- [ ] L1772  `is_non_area7_slot_b_entity`  *(proc)*
- [ ] L1794  `combat_step_advance`  *(proc)*
- [ ] L1939  `combat_input_poll_step`  *(proc)*
- [ ] L1995  `try_advance_with_anim`  *(proc)*
- [ ] L2044  `scroll_pos_advance`  *(proc)*
- [ ] L2082  `check_3tile_clearance`  *(proc)*
- [ ] L2134  `game_get_value`  *(proc)*
- [ ] L2142  `find_fire_slot_for_id`  *(proc)*
- [ ] L2182  `process_map_seg_updates`  *(proc)*
- [ ] L2223  `game_get_value_2`  *(proc)*
- [ ] L2245  `init_arena_visuals`  *(proc)*
- [ ] L2275  `vga_operation0`  *(proc)*
- [ ] L2327  `vga_operation1`  *(proc)*
- [ ] L2349  `vga_operation2`  *(proc)*
- [ ] L2406  `vga_operation3`  *(proc)*
- [ ] L2425  `vga_operation4`  *(proc)*
- [ ] L2440  `vga_operation5`  *(proc)*
- [ ] L2453  `vga_operation6`  *(proc)*
- [ ] L2464  `vga_operation7`  *(proc)*
- [ ] L2482  `vga_operation8`  *(proc)*
- [ ] L2496  `vga_operation9`  *(proc)*
- [ ] L2515  `entity_type_quick_check`  *(proc)*
- [ ] L2523  `is_entity_known_type_alt`  *(proc)*
- [ ] L2558  `is_entity_id_lax`  *(proc)*
- [ ] L2618  `combat_input_handler`  *(proc)*
- [ ] L2737  `select_player_sprite_frame`  *(proc)*
- [ ] L2812  `update_combat_frame_state`  *(proc)*
- [ ] L2909  `save_combat_action_state`  *(proc)*
- [ ] L3060  `fill_hud_enemy_area`  *(proc)*
- [ ] L3151  `swap_world_state_buffers`  *(proc)*
- [ ] L3239  `fill_buffer`  *(proc)*
- [ ] L3252  `find_atk_slot_for_id`  *(proc)*
- [ ] L3279  `init_combat_arena`  *(proc)*
- [ ] L3304  `draw_combat_hud_layout`  *(proc)*
- [ ] L3363  `mark_player_pos_on_hud`  *(proc)*
- [ ] L3388  `scan_outer_slot_match`  *(proc)*
- [ ] L3559  `apply_passive_damage`  *(proc)*
- [ ] L3572  `apply_combat_damage_with_absorb`  *(proc)*
- [ ] L3613  `clear_secondary_pool_and_redraw`  *(proc)*
- [ ] L3647  `accumulate_tile_type`  *(proc)*
- [ ] L3678  `player_HP_subtract`  *(proc)*
- [ ] L3693  `game_process_loop_2`  *(proc)*
- [ ] L3717  `tail_dispatch_by_slot_family`  *(proc)*
- [ ] L3761  `lookup_move_slot_family`  *(proc)*
- [ ] L3826  `compute_target_dist`  *(proc)*
- [ ] L3905  `enter_level_via_ref_a`  *(proc)*
- [ ] L3911  `render_entity_list_to_hud`  *(proc)*
- [ ] L4000  `game_get_value_3`  *(proc)*
- [ ] L4012  `world_x_to_screen_x_w27`  *(proc)*
- [ ] L4098  `check_3tile_J_pattern`  *(proc)*
- [ ] L4426  `compute_scroll_pos`  *(proc)*
- [ ] L4444  `compute_scroll_offset_b`  *(proc)*
- [ ] L4473  `decrement_speed_or_power`  *(proc)*
- [ ] L4508  `reset_combat_state`  *(proc)*
- [ ] L4531  `copy_buffer`  *(proc)*
- [ ] L4555  `vga_operation_2`  *(proc)*
- [ ] L4618  `wait_anim_cycle`  *(proc)*
- [ ] L4638  `scan_top_map_objects`  *(proc)*
- [ ] L4668  `try_top_scroll_direction`  *(proc)*
- [ ] L4711  `game_process_loop_3`  *(proc)*
- [ ] L4767  `try_top_combat_step`  *(proc)*
- [ ] L4861  `find_and_blit_map_entry`  *(proc)*
- [ ] L4899  `match_dl_within_3`  *(proc)*
- [ ] L4920  `scan_bot_map_objects`  *(proc)*
- [ ] L4950  `bot_path_check`  *(proc)*
- [ ] L4969  `scan_extra_map_objects`  *(proc)*
- [ ] L5134  `check_entity_collision_pos`  *(proc)*
- [ ] L5180  `world_x_to_inner_screen_x`  *(proc)*
- [ ] L5206  `world_x_to_screen_x_w25`  *(proc)*
- [ ] L5239  `entity_slot_write_tagged`  *(proc)*
- [ ] L5254  `scan_enemy_data_buf`  *(proc)*
- [ ] L5315  `process_dirty_enemies`  *(proc)*
- [ ] L5333  `prep_dirty_blit`  *(proc)*
- [ ] L5346  `enemy_sprite_blit`  *(proc)*
- [ ] L5364  `copy_buffer_2`  *(proc)*
- [ ] L5411  `process_sprite_step`  *(proc)*
- [ ] L5543  `entity_fn_dispatch_b`  *(proc)*
- [ ] L5587  `entity_step_dispatch_c`  *(proc)*
- [ ] L5632  `update_entity_dir_from_path`  *(proc)*
- [ ] L5679  `tick_decrement_enemy_counters`  *(proc)*
- [ ] L5699  `tick_increment_enemy_counters`  *(proc)*
- [ ] L5719  `calc_hud_buf_offset`  *(proc)*
- [ ] L5733  `process_active_sprites`  *(proc)*
- [ ] L5785  `prep_boss_dirty_blit`  *(proc)*
- [ ] L5799  `update_sprite_work_buf`  *(proc)*
- [ ] L5835  `place_3_tile_49_pattern`  *(proc)*
- [ ] L5855  `try_place_tile_id_49`  *(proc)*
- [ ] L6101  `scan_boss_entries_render`  *(proc)*
- [ ] L6220  `render_boss_dirty_blits`  *(proc)*
- [ ] L6276  `gate_spell_fx_active`  *(proc)*
- [ ] L6420  `cycle_dir_and_advance`  *(proc)*
- [ ] L6455  `draw_entity_3x3_at_pos`  *(proc)*
- [ ] L6513  `try_paint_obj_cell`  *(proc)*
- [ ] L6550  `scan_obj_list_render`  *(proc)*
- [ ] L6616  `update_obj_slot_flags`  *(proc)*
- [ ] L6901  `gfx_fn_enemy_scroll`  *(data)*
- [ ] L6902  `gfx_fn_combat_fx`  *(data)*
- [ ] L6903  `gfx_fn_render_tile`  *(data)*
- [ ] L6904  `gfx_fn_render_col`  *(data)*
- [ ] L6905  `gfx_fn_hud_draw`  *(data)*
- [ ] L6906  `gfx_fn_77`  *(data)*
- [ ] L6908  `gfx_fn_78`  *(data)*
- [ ] L6909  `gfx_fn_player_scroll`  *(data)*
- [ ] L6910  `gfx_fn_init`  *(data)*
- [ ] L6911  `gfx_fn_map_load`  *(data)*
- [ ] L6912  `gfx_fn_render_bg`  *(data)*
- [ ] L6913  `gfx_fn_83`  *(data)*
- [ ] L6914  `gfx_fn_palette`  *(data)*
- [ ] L6915  `gfx_fn_clear`  *(data)*
- [ ] L6916  `gfx_fn_blit`  *(data)*
- [ ] L6917  `gfx_fn_map_ref`  *(data)*
- [ ] L6921  `gfx_fn_memcpy`  *(data)*
- [ ] L6922  `gfx_fn_map_scroll`  *(data)*
- [ ] L7115  `hero_almas_add`  *(proc)*
- [ ] L7128  `check_entity_in_view`  *(proc)*
- [ ] L7185  `entity_move_east`  *(proc)*
- [ ] L7219  `entity_move_north`  *(proc)*
- [ ] L7259  `entity_move_west`  *(proc)*
- [ ] L7291  `entity_move_south`  *(proc)*
- [ ] L7330  `inc_map_pos_helper`  *(proc)*
- [ ] L7348  `dec_map_pos_helper`  *(proc)*
- [ ] L7375  `check_above_3rows_clear`  *(proc)*
- [ ] L7405  `is_unknown_or_area5_slot_b`  *(proc)*
- [ ] L7433  `check_below_3rows_clear`  *(proc)*
- [ ] L7463  `is_unknown_or_area5_slot_c`  *(proc)*
- [ ] L7492  `check_north_movement`  *(proc)*
- [ ] L7525  `check_south_movement`  *(proc)*
- [ ] L7550  `check_movement_var_134`  *(proc)*
- [ ] L7594  `check_movement_var_135`  *(proc)*
- [ ] L7632  `check_movement_var_136`  *(proc)*
- [ ] L7676  `check_movement_var_137`  *(proc)*
- [ ] L7724  `is_entity_known_type`  *(proc)*
- [ ] L7748  `check_entity_slot_validity`  *(proc)*
- [ ] L7910  `clear_buffer`  *(proc)*
- [ ] L7948  `world_x_to_screen_x`  *(proc)*
- [ ] L8008  `item_effect_val_add`  *(proc)*
- [ ] L8176  `compute_action_anim_idx`  *(proc)*
- [ ] L8406  `gfx_fn_hitbox_data`  *(label word)*

## working/zelres2/code/201SELCT.asm  (31 sections)

- [ ] L149   `selct_main`  *(proc)*
- [ ] L312   `draw_weapon_cursor`  *(proc)*
- [ ] L345   `show_weapon_portrait`  *(proc)*
- [ ] L426   `draw_magic_cursor`  *(proc)*
- [ ] L460   `show_magic_portrait`  *(proc)*
- [ ] L567   `draw_item_cursor`  *(proc)*
- [ ] L601   `show_item_portrait`  *(proc)*
- [ ] L842   `init_item_panel`  *(proc)*
- [ ] L860   `draw_item_detail`  *(proc)*
- [ ] L890   `show_portrait_box`  *(proc)*
- [ ] L904   `hide_portrait_box`  *(proc)*
- [ ] L918   `rebuild_item_idx`  *(proc)*
- [ ] L948   `draw_item_panel`  *(proc)*
- [ ] L1002  `draw_magic_panel`  *(proc)*
- [ ] L1169  `draw_exp_bar`  *(proc)*
- [ ] L1188  `draw_key_count`  *(proc)*
- [ ] L1217  `draw_weapon_panel`  *(proc)*
- [ ] L1350  `fmt_number`  *(proc)*
- [ ] L1370  `draw_portrait_tabs`  *(proc)*
- [ ] L1466  `check_joy_neutral`  *(proc)*
- [ ] L1482  `str_empty_lbl`  *(label word)*
- [ ] L1485  `str_no_use_notice_lbl`  *(label word)*
- [ ] L1489  `str_item_used_count_lbl`  *(label word)*
- [ ] L1492  `str_item_used_total_lbl`  *(label word)*
- [ ] L1495  `str_item_detail_hdr_lbl`  *(label word)*
- [ ] L1498  `spell_name_ptrs_lbl`  *(label word)*
- [ ] L1521  `shoe_name_ptrs_lbl`  *(label word)*
- [ ] L1544  `item_detail_ptrs_lbl`  *(label word)*
- [ ] L1570  `item_name_ptrs_lbl`  *(label word)*
- [ ] L1605  `weapon_detail_ptrs_lbl`  *(label word)*
- [ ] L1631  `shield_detail_ptrs_lbl`  *(label word)*

## working/zelres2/code/202GFEGA.asm  (40 sections)

- [ ] L158   `gfega_main`  *(proc)*
- [ ] L198   `ega_row_ofs`  *(data)*
- [ ] L280   `sprite_state_update`  *(proc)*
- [ ] L490   `ega_sprite_blit`  *(proc)*
- [ ] L685   `sprite_slot_init`  *(proc)*
- [ ] L719   `sprite_blit_dispatch`  *(proc)*
- [ ] L751   `sprite_wide_row_render`  *(proc)*
- [ ] L940   `sprite_pos_pair_iter`  *(proc)*
- [ ] L975   `sprite_cell_render`  *(proc)*
- [ ] L1031  `ega_sprite_blit_ex`  *(proc)*
- [ ] L1045  `ega_sprite_render_blended`  *(proc)*
- [ ] L1124  `ega_sprite_render_solid`  *(proc)*
- [ ] L1181  `ega_blit_2bytes_8rows`  *(proc)*
- [ ] L1220  `ega_3plane_copy`  *(proc)*
- [ ] L1247  `ega_clear_16bytes`  *(proc)*
- [x] L1265  `sprite_get_value`  *(proc)*
- [ ] L1273  `sprite_src_setup`  *(proc)*
- [ ] L1312  `projectile_spawn_check`  *(proc)*
- [ ] L1965  `hero_sprite_col_blit`  *(proc)*
- [ ] L2005  `hero_tier_get`  *(proc)*
- [ ] L2104  `scroll_pos_load`  *(proc)*
- [ ] L2131  `frame_row_driver`  *(proc)*
- [ ] L2284  `bg_restore`  *(proc)*
- [ ] L2306  `bg_save`  *(proc)*
- [ ] L2341  `bg_restore_impl`  *(proc)*
- [ ] L2376  `scroll_cache_invalidate`  *(proc)*
- [ ] L2594  `tile_blit_3x3`  *(proc)*
- [ ] L2783  `ega_tile_anim_update`  *(proc)*
- [ ] L2849  `ega_plane_write_2row`  *(proc)*
- [ ] L2898  `ega_clear_pixel_pair`  *(proc)*
- [ ] L2908  `phase_ptr_advance`  *(proc)*
- [ ] L3000  `fade_gradient_loop`  *(proc)*
- [ ] L3042  `ega_fade_blit`  *(proc)*
- [ ] L3080  `ega_fill_bit_range`  *(proc)*
- [ ] L3154  `ega_fill_bit_range_wide`  *(proc)*
- [ ] L3282  `ega_row_addr_calc`  *(proc)*
- [ ] L3291  `frame_wait_loop`  *(proc)*
- [x] L3417  `si_wrap_hi`  *(proc)*
- [ ] L3577  `ega_bg_tile_blit`  *(proc)*
- [ ] L3717  `ega_col_write_loop`  *(proc)*

## working/zelres2/code/203GFCGA.asm  (43 sections)

- [ ] L167   `gfcga_main`  *(proc)*
- [ ] L201   `cga_row_ofs`  *(data)*
- [ ] L283   `sprite_state_update`  *(proc)*
- [ ] L489   `cga_sprite_blit`  *(proc)*
- [ ] L631   `sprite_slot_init`  *(proc)*
- [ ] L665   `sprite_blit_dispatch`  *(proc)*
- [ ] L697   `sprite_wide_row_render`  *(proc)*
- [ ] L886   `sprite_pos_pair_iter`  *(proc)*
- [ ] L921   `sprite_cell_render`  *(proc)*
- [ ] L985   `cga_sprite_blit_ex`  *(proc)*
- [ ] L1002  `cga_sprite_render_blended`  *(proc)*
- [ ] L1021  `cga_sprite_render_solid`  *(proc)*
- [ ] L1034  `sprite_bit_extract`  *(proc)*
- [ ] L1076  `cga_blit_2rows_stride`  *(proc)*
- [ ] L1096  `sprite_copy_8words`  *(proc)*
- [ ] L1103  `sprite_clear_8words`  *(proc)*
- [x] L1111  `sprite_get_value`  *(proc)*
- [ ] L1119  `sprite_src_setup`  *(proc)*
- [ ] L1158  `projectile_spawn_check`  *(proc)*
- [ ] L1773  `sprite_col_render_loop`  *(proc)*
- [ ] L1815  `hero_tier_get`  *(proc)*
- [ ] L1944  `frame_row_driver`  *(proc)*
- [ ] L2097  `scroll_restore`  *(proc)*
- [ ] L2117  `bg_save`  *(proc)*
- [ ] L2145  `bg_restore`  *(proc)*
- [ ] L2169  `scroll_pos_load`  *(proc)*
- [ ] L2302  `bg_tile_restore_3x3`  *(proc)*
- [ ] L2443  `bg_col_blit_row`  *(proc)*
- [ ] L2502  `col_write_inner`  *(proc)*
- [ ] L2539  `cga_clear_2rows`  *(proc)*
- [ ] L2549  `row_ofs_advance`  *(proc)*
- [ ] L2597  `cga_inner_fade`  *(proc)*
- [ ] L2673  `cga_fade_blit`  *(proc)*
- [ ] L2774  `cga_fill_bit_range_wide`  *(proc)*
- [ ] L2897  `cga_row_addr_calc`  *(proc)*
- [ ] L2909  `frame_wait_loop`  *(proc)*
- [ ] L2931  `hud_clear`  *(proc)*
- [x] L3018  `si_wrap_hi`  *(proc)*
- [ ] L3135  `cga_plane_mask_2bit`  *(proc)*
- [ ] L3188  `bg_tile_blit_inner`  *(proc)*
- [ ] L3219  `cga_plane_mask_combine`  *(proc)*
- [ ] L3703  `cga_nibble_mask_advance`  *(proc)*
- [ ] L3732  `cga_nibble_mask_alt`  *(proc)*

## working/zelres2/code/204GFHGC.asm  (47 sections)

- [ ] L138   `gfhgc_main`  *(proc)*
- [ ] L177   `hgc_row_ofs`  *(data)*
- [ ] L264   `sprite_state_update`  *(proc)*
- [ ] L469   `hgc_plane_or_blit`  *(proc)*
- [ ] L571   `sprite_slot_remove`  *(proc)*
- [ ] L608   `sprite_slot_init`  *(proc)*
- [ ] L642   `sprite_blit_dispatch`  *(proc)*
- [ ] L674   `sprite_wide_row_render`  *(proc)*
- [ ] L881   `sprite_pair_blit`  *(proc)*
- [ ] L916   `hgc_sprite_blit`  *(proc)*
- [ ] L980   `sprite_or_into_cache`  *(proc)*
- [ ] L997   `physics_func_11`  *(proc)*
- [ ] L1016  `plane_copy_process`  *(proc)*
- [ ] L1029  `hgc_extract_4bits`  *(proc)*
- [ ] L1071  `plane_scan_blit`  *(proc)*
- [ ] L1090  `copy_8words`  *(proc)*
- [ ] L1097  `zero_8words`  *(proc)*
- [ ] L1105  `translate_char`  *(proc)*
- [ ] L1113  `sprite_src_setup`  *(proc)*
- [ ] L1152  `check_spawn_projectile`  *(proc)*
- [ ] L1809  `sprite_write_range`  *(proc)*
- [ ] L1851  `get_step_direction`  *(proc)*
- [ ] L1953  `build_sprite_refs`  *(proc)*
- [ ] L1980  `frame_row_driver`  *(proc)*
- [ ] L2176  `bg_restore_dispatch`  *(proc)*
- [ ] L2196  `save_bg_rows`  *(proc)*
- [ ] L2224  `restore_bg_rows`  *(proc)*
- [ ] L2261  `clear_sprite_cache_block`  *(proc)*
- [ ] L2391  `load_bg_to_cache`  *(proc)*
- [ ] L2540  `anim_refresh_tile`  *(proc)*
- [ ] L2600  `hgc_write_row_masked`  *(proc)*
- [ ] L2649  `hgc_clear_row_masked`  *(proc)*
- [ ] L2680  `set_pixel_stride_offset`  *(proc)*
- [ ] L2712  `fade_radius_loop`  *(proc)*
- [ ] L2788  `hgc_fade_blit`  *(proc)*
- [ ] L2891  `hgc_fill_bit_range_wide`  *(proc)*
- [ ] L3014  `hgc_row_addr_calc`  *(proc)*
- [ ] L3025  `frame_wait_loop`  *(proc)*
- [ ] L3047  `hgc_xor_fill_region`  *(proc)*
- [x] L3135  `si_wrap_hi`  *(proc)*
- [ ] L3146  `si_wrap_lo`  *(proc)*
- [ ] L3281  `hgc_fade_blit_entry`  *(proc)*
- [ ] L3313  `rol_extract_loop`  *(proc)*
- [ ] L3634  `shift_extract_loop`  *(proc)*
- [ ] L3761  `hgc_pixel_addr_calc`  *(proc)*
- [ ] L3846  `plane_pair_rol_loop`  *(proc)*
- [ ] L3875  `dispatch_shape_fill`  *(proc)*

## working/zelres2/code/205GFTGA.asm  (48 sections)

- [ ] L124   `gftga_main`  *(proc)*
- [ ] L159   `tga_row_ofs`  *(data)*
- [ ] L248   `sprite_state_update`  *(proc)*
- [ ] L458   `tga_sprite_blit`  *(proc)*
- [ ] L695   `sprite_slot_remove`  *(proc)*
- [ ] L732   `sprite_slot_init`  *(proc)*
- [ ] L767   `sprite_blit_dispatch`  *(proc)*
- [ ] L799   `sprite_wide_row_render`  *(proc)*
- [ ] L991   `sprite_pos_pair_iter`  *(proc)*
- [ ] L1025  `sprite_cell_render`  *(proc)*
- [ ] L1091  `tga_sprite_render_blended`  *(proc)*
- [ ] L1108  `tile_blend_inner_loop`  *(proc)*
- [ ] L1135  `tga_sprite_inner_blit`  *(proc)*
- [ ] L1151  `color_nibble_expand`  *(proc)*
- [ ] L1193  `tga_blit_2bytes_8rows`  *(proc)*
- [ ] L1256  `copy_16words`  *(proc)*
- [ ] L1263  `fill_16words_zero`  *(proc)*
- [x] L1271  `sprite_get_value`  *(proc)*
- [ ] L1279  `sprite_src_setup`  *(proc)*
- [ ] L1318  `projectile_spawn_check`  *(proc)*
- [ ] L1974  `tga_sprite_render_solid`  *(proc)*
- [ ] L2018  `hero_tier_get`  *(proc)*
- [ ] L2152  `frame_row_driver`  *(proc)*
- [ ] L2306  `bg_restore`  *(proc)*
- [ ] L2326  `bg_save`  *(proc)*
- [ ] L2354  `bg_restore_impl`  *(proc)*
- [ ] L2378  `scroll_cache_invalidate`  *(proc)*
- [ ] L2508  `tga_plane_decode`  *(proc)*
- [ ] L2594  `hero_sprite_col_blit`  *(proc)*
- [ ] L2741  `tga_tile_anim_update`  *(proc)*
- [ ] L2801  `tile_blend_row_pair`  *(proc)*
- [ ] L2838  `tga_row_mask_clear`  *(proc)*
- [ ] L2848  `tga_vram_advance_az`  *(proc)*
- [ ] L2896  `fade_concentric`  *(proc)*
- [ ] L2972  `fade_h_range`  *(proc)*
- [ ] L3061  `fade_pixel_range`  *(proc)*
- [ ] L3160  `phase_ptr_advance`  *(proc)*
- [ ] L3180  `fade_gradient_loop`  *(proc)*
- [ ] L3202  `anim_refresh_all`  *(proc)*
- [x] L3292  `si_wrap_hi`  *(proc)*
- [ ] L3303  `si_wrap_lo`  *(proc)*
- [ ] L3432  `bg_tile_blit_init`  *(proc)*
- [ ] L3466  `plane_word_expand`  *(proc)*
- [ ] L3874  `ega_fill_bit_range_wide`  *(proc)*
- [ ] L4057  `plane_pair_rol`  *(proc)*
- [ ] L4075  `dither_bit_expand`  *(proc)*
- [ ] L4098  `nibble_pack_ax`  *(proc)*
- [ ] L4117  `ega_row_addr_calc`  *(proc)*

## working/zelres2/code/206GFMCA.asm  (56 sections)

- [ ] L151   `gfmca_main`  *(proc)*
- [ ] L181   `data_8`  *(data)*
- [ ] L187   `data_9`  *(data)*
- [ ] L198   `mca_row_ofs`  *(data)*
- [ ] L279   `sprite_state_update`  *(proc)*
- [ ] L485   `mca_sprite_blit`  *(proc)*
- [ ] L596   `sprite_slot_remove`  *(proc)*
- [ ] L633   `sprite_slot_init`  *(proc)*
- [ ] L669   `sprite_blit_dispatch`  *(proc)*
- [ ] L701   `sprite_wide_row_render`  *(proc)*
- [ ] L896   `sprite_pos_pair_iter`  *(proc)*
- [ ] L930   `sprite_cell_render`  *(proc)*
- [ ] L992   `mca_sprite_blit_ex`  *(proc)*
- [ ] L1009  `mca_plane_3_iter`  *(proc)*
- [ ] L1027  `mca_plane_nibble_iter`  *(proc)*
- [ ] L1044  `mca_plane_copy_16rows`  *(proc)*
- [ ] L1060  `mca_plane_copy_4px`  *(proc)*
- [ ] L1073  `mca_fetch_color_lut`  *(proc)*
- [ ] L1089  `mca_blit_2bytes_8rows`  *(proc)*
- [ ] L1104  `mca_sprite_render_solid`  *(proc)*
- [ ] L1132  `mca_sprite_clear_cell`  *(proc)*
- [x] L1140  `sprite_get_value`  *(proc)*
- [ ] L1148  `sprite_src_setup`  *(proc)*
- [ ] L1187  `projectile_spawn_check`  *(proc)*
- [ ] L1380  `sprite_shape_tbl`  *(label byte)*
- [ ] L1828  `frame_row_driver`  *(proc)*
- [ ] L1872  `shield_state_get`  *(proc)*
- [ ] L1976  `load_sprite_pos`  *(proc)*
- [ ] L2003  `frame_row_dispatcher`  *(proc)*
- [ ] L2158  `scroll_restore`  *(proc)*
- [ ] L2178  `scroll_buf_restore`  *(proc)*
- [ ] L2200  `scroll_buf_save`  *(proc)*
- [ ] L2222  `scroll_clear_cache`  *(proc)*
- [ ] L2412  `hero_sprite_col_blit`  *(proc)*
- [ ] L2569  `mca_tile_half_blit`  *(proc)*
- [ ] L2633  `mca_tile_half_blit_rows`  *(proc)*
- [ ] L2692  `mca_tile_half_clear`  *(proc)*
- [ ] L2704  `mca_tile_addr_calc`  *(proc)*
- [ ] L2742  `fade_gradient_rect`  *(proc)*
- [ ] L2818  `fade_gradient_line`  *(proc)*
- [ ] L2889  `fade_horizontal_line`  *(proc)*
- [ ] L2930  `mca_vga_row_calc`  *(proc)*
- [ ] L2942  `anim_frame_wait`  *(proc)*
- [ ] L2964  `fade_xor_block`  *(proc)*
- [x] L3049  `si_wrap_hi`  *(proc)*
- [ ] L3060  `si_wrap_lo`  *(proc)*
- [ ] L3140  `ui_tile_index_tbl`  *(label byte)*
- [ ] L3199  `bg_tile_blit`  *(proc)*
- [ ] L3223  `mca_sprite_2block_render`  *(proc)*
- [ ] L3284  `ah_xform_dispatch_tbl`  *(label word)*
- [ ] L3381  `anim_seq_tbl`  *(label byte)*
- [ ] L3480  `mca_plane_4bit_scan`  *(proc)*
- [ ] L3563  `shift_blit_data_a`  *(label byte)*
- [ ] L3823  `mca_word_shift_4`  *(proc)*
- [ ] L3841  `mca_bit_pair_scan`  *(proc)*
- [ ] L3869  `mca_pixel_lookup_tbls`  *(label byte)*

## working/zelres2/code/207MOLE.asm  (75 sections)

- [ ] L109   `module_init`  *(proc)*
- [ ] L248   `dispatch_decode_a`  *(proc)*
- [ ] L263   `jmp_tbl_decode_a`  *(label word)*
- [ ] L397   `nibble_to_2bpp_lut`  *(label byte)*
- [ ] L542   `vga_pixel_unpack`  *(proc)*
- [ ] L561   `nibble_to_vga_lut`  *(label byte)*
- [ ] L621   `mcga_pixel_unpack`  *(proc)*
- [ ] L650   `nibble_to_mcga_lut`  *(label byte)*
- [ ] L655   `dispatch_decode_b`  *(proc)*
- [ ] L674   `jmp_tbl_decode_b`  *(label word)*
- [ ] L695   `data_15`  *(data)*
- [ ] L726   `decode_5col_blit_loop`  *(proc)*
- [ ] L745   `decode_4bit_unpack`  *(proc)*
- [ ] L778   `mono_scan_loop`  *(proc)*
- [ ] L812   `extract_bits`  *(proc)*
- [ ] L853   `nibble_to_4px_lut`  *(label byte)*
- [ ] L914   `sprite_data_start`  *(label byte)*
- [ ] L935   `sprite_data_row_0`  *(label byte)*
- [ ] L982   `data_20`  *(data)*
- [ ] L1071  `data_21`  *(data)*
- [ ] L1077  `data_22`  *(data)*
- [ ] L1083  `data_23`  *(data)*
- [ ] L1085  `data_25`  *(data)*
- [ ] L1096  `data_26`  *(data)*
- [ ] L1104  `data_27`  *(data)*
- [ ] L1165  `data_28`  *(data)*
- [ ] L1168  `data_29`  *(data)*
- [ ] L1170  `data_31`  *(data)*
- [ ] L1174  `data_32`  *(data)*
- [ ] L1181  `data_33`  *(data)*
- [ ] L1193  `data_34`  *(data)*
- [ ] L1195  `data_35`  *(data)*
- [ ] L1198  `data_36`  *(data)*
- [ ] L1202  `data_37`  *(data)*
- [ ] L1205  `data_38`  *(data)*
- [ ] L1222  `data_39`  *(data)*
- [ ] L1232  `data_40`  *(data)*
- [ ] L1393  `data_41`  *(data)*
- [ ] L1395  `data_42`  *(data)*
- [ ] L1482  `data_43`  *(data)*
- [ ] L1483  `data_44`  *(data)*
- [ ] L1485  `data_45`  *(data)*
- [ ] L1490  `data_46`  *(data)*
- [ ] L1496  `data_47`  *(data)*
- [ ] L1497  `data_49`  *(data)*
- [ ] L1510  `data_50`  *(data)*
- [ ] L1512  `data_51`  *(data)*
- [ ] L1514  `data_53`  *(data)*
- [ ] L1519  `data_55`  *(data)*
- [ ] L1521  `data_56`  *(data)*
- [ ] L1523  `data_57`  *(data)*
- [ ] L1527  `data_58`  *(data)*
- [ ] L1546  `data_59`  *(data)*
- [ ] L1570  `data_60`  *(data)*
- [ ] L1795  `data_61`  *(data)*
- [ ] L1946  `misdec_port_stub`  *(proc)*
- [ ] L1962  `sprite_data_row_2`  *(label byte)*
- [ ] L2170  `data_62`  *(data)*
- [ ] L2171  `data_63`  *(data)*
- [ ] L2178  `data_64`  *(data)*
- [ ] L2179  `data_65`  *(data)*
- [ ] L2180  `data_66`  *(data)*
- [ ] L2182  `data_67`  *(data)*
- [ ] L2192  `data_68`  *(data)*
- [ ] L2199  `data_69`  *(data)*
- [ ] L2202  `data_70`  *(data)*
- [ ] L2265  `data_71`  *(data)*
- [ ] L2271  `data_72`  *(data)*
- [ ] L2274  `data_73`  *(data)*
- [ ] L2286  `data_74`  *(data)*
- [ ] L2289  `data_75`  *(data)*
- [ ] L2534  `data_77`  *(data)*
- [ ] L2536  `data_78`  *(data)*
- [ ] L2555  `data_79`  *(data)*
- [ ] L2568  `data_80`  *(data)*

## working/zelres2/code/208YMPD.asm  (10 sections)

- [ ] L124   `satono_bg_main`  *(proc)*
- [ ] L175   `rle_decode_mountain_88x56`  *(proc)*
- [ ] L209   `render_mountains`  *(proc)*
- [ ] L251   `ega_mtn_blit_88_rows`  *(proc)*
- [ ] L442   `pixel_expand_mcga`  *(proc)*
- [ ] L500   `pixel_expand_cga`  *(proc)*
- [ ] L538   `rle_decode_ground_28`  *(proc)*
- [ ] L568   `render_ground`  *(proc)*
- [ ] L649   `copy_28b_ega`  *(proc)*
- [ ] L1021  `pixel_expand_cgaalt`  *(proc)*

## working/zelres2/code/209CKPD.asm  (22 sections)

- [ ] L159   `bos_render_main`  *(proc)*
- [ ] L222   `bos_frame_dispatch`  *(proc)*
- [ ] L484   `vga_row_copy`  *(proc)*
- [ ] L551   `nibble_expand_8`  *(proc)*
- [ ] L630   `nibble_decode_inner`  *(proc)*
- [ ] L660   `sprite_rle_decode`  *(proc)*
- [ ] L700   `render_dispatch_2`  *(proc)*
- [ ] L952   `nibble_expand_8_b`  *(proc)*
- [ ] L1022  `nibble_decode_inner_2`  *(proc)*
- [ ] L1159  `data_10`  *(data)*
- [ ] L1180  `data_11`  *(data)*
- [ ] L1243  `data_12`  *(data)*
- [ ] L1412  `data_13`  *(data)*
- [ ] L1487  `data_14`  *(data)*
- [ ] L1543  `data_15`  *(data)*
- [ ] L1545  `data_16`  *(data)*
- [ ] L1567  `data_17`  *(data)*
- [ ] L1579  `data_18`  *(data)*
- [ ] L1587  `data_19`  *(data)*
- [ ] L1597  `data_20`  *(data)*
- [ ] L1600  `data_21`  *(data)*
- [ ] L1726  `data_22`  *(data)*

## working/zelres2/code/210KINGP.asm  (9 sections)

- [ ] L91    `kingp_main`  *(proc)*
- [ ] L134   `script_cmd_dispatch`  *(proc)*
- [ ] L252   `short_wait`  *(proc)*
- [ ] L263   `render_portrait`  *(proc)*
- [ ] L297   `render_portrait_variant`  *(proc)*
- [ ] L390   `face_anim_tick`  *(proc)*
- [ ] L402   `face_mode_update`  *(proc)*
- [ ] L525   `select_script_branch`  *(proc)*
- [ ] L610   `data_portrait_tail`  *(data)*

## working/zelres2/code/211OMOYP.asm  (12 sections)

- [ ] L80    `omoyp`  *(proc)*
- [ ] L177   `ref_enddemo`  *(data)*
- [ ] L186   `gfx_driver_ref_tbl_lbl`  *(label word)*
- [ ] L199   `ref_gdega_lbl`  *(label byte)*
- [ ] L204   `ref_gdcga_lbl`  *(label byte)*
- [ ] L209   `ref_gdhgc_lbl`  *(label byte)*
- [ ] L214   `ref_gdmcga_lbl`  *(label byte)*
- [ ] L219   `ref_gdtga_lbl`  *(label byte)*
- [ ] L235   `draw_hut_banner`  *(proc)*
- [ ] L271   `banner_tile_grid_lbl`  *(label byte)*
- [ ] L316   `ref_omoya_grp`  *(data)*
- [ ] L320   `banner_msg_header`  *(label byte)*

## working/zelres2/code/212ARMRP.asm  (10 sections)

- [ ] L150   `armrp_main`  *(proc)*
- [ ] L216   `build_mouth_bitmap_a`  *(proc)*
- [ ] L246   `build_mouth_bitmap_b`  *(proc)*
- [ ] L276   `shop_menu_dispatch`  *(proc)*
- [ ] L552   `knight_sword_hook_a`  *(proc)*
- [ ] L889   `frame_delay`  *(proc)*
- [ ] L924   `knight_sword_hook_b`  *(proc)*
- [ ] L948   `clear_menu_rect`  *(proc)*
- [ ] L956   `shopkeeper_anim_tick`  *(proc)*
- [ ] L1054  `render_shopkeeper_frame`  *(proc)*

## working/zelres2/code/213BANKP.asm  (9 sections)

- [ ] L118   `bank_main`  *(proc)*
- [ ] L182   `script_opcode_dispatch`  *(proc)*
- [ ] L208   `data_7`  *(data)*
- [ ] L633   `clear_dialog_area`  *(proc)*
- [ ] L641   `adjust_amount_by_input`  *(proc)*
- [ ] L697   `draw_intro_12x8`  *(proc)*
- [ ] L745   `anim_scroll_step`  *(proc)*
- [ ] L767   `draw_banner_8x5`  *(proc)*
- [ ] L830   `iter_wait_msg_list`  *(proc)*

## working/zelres2/code/214CHURP.asm  (7 sections)

- [ ] L71    `church_main`  *(proc)*
- [ ] L124   `script_opcode_dispatch`  *(proc)*
- [ ] L155   `rest_wait_loop`  *(data)*
- [ ] L249   `draw_intro_12x8`  *(proc)*
- [ ] L292   `anim_scroll_step`  *(proc)*
- [ ] L313   `anim_draw_a`  *(proc)*
- [ ] L408   `pick_welcome_text`  *(proc)*

## working/zelres2/code/215DRUGP.asm  (10 sections)

- [ ] L105   `zr2_15`  *(proc)*
- [ ] L159   `wizard_process_loop`  *(proc)*
- [ ] L189   `wizard_func_2`  *(proc)*
- [ ] L200   `data_4`  *(data)*
- [ ] L229   `data_5`  *(data)*
- [ ] L514   `wizard_process_loop_2`  *(proc)*
- [ ] L618   `wizard_func_4`  *(proc)*
- [ ] L626   `wizard_process_loop_3`  *(proc)*
- [ ] L674   `wizard_multiply`  *(proc)*
- [ ] L736   `wizard_scan_loop`  *(proc)*

## working/zelres2/code/216INNAP.asm  (20 sections)

- [ ] L61    `inn_main`  *(proc)*
- [ ] L114   `draw_intro_banner`  *(proc)*
- [ ] L130   `inn_opcode_dispatch`  *(proc)*
- [ ] L155   `data_1`  *(data)*
- [ ] L156   `data_2`  *(data)*
- [ ] L162   `data_3`  *(data)*
- [ ] L165   `data_4`  *(data)*
- [ ] L169   `data_5`  *(data)*
- [ ] L171   `data_6`  *(data)*
- [ ] L172   `data_7`  *(data)*
- [ ] L213   `data_8`  *(data)*
- [ ] L265   `inn_wait_long`  *(proc)*
- [ ] L280   `inn_wait_short`  *(proc)*
- [ ] L296   `inn_anim_step`  *(proc)*
- [ ] L332   `draw_intro_tile_map`  *(proc)*
- [ ] L366   `intro_glyph_row_a`  *(label byte)*
- [ ] L376   `intro_glyph_row_b`  *(label byte)*
- [ ] L386   `inn_anim_scan`  *(proc)*
- [ ] L458   `inn_delay_tbl`  *(label word)*
- [ ] L474   `ref_inn_grp`  *(data)*

## working/zelres2/code/217KENJP.asm  (23 sections)

- [ ] L166   `kenja_main`  *(proc)*
- [ ] L201   `load_sage_chunk`  *(proc)*
- [ ] L226   `kenja_cmd_dispatch`  *(proc)*
- [ ] L238   `data_9`  *(data)*
- [ ] L240   `data_10`  *(data)*
- [ ] L249   `data_11`  *(data)*
- [ ] L266   `data_13`  *(data)*
- [ ] L329   `scan_blessing_attrs`  *(proc)*
- [ ] L379   `check_hp_exp_tier`  *(proc)*
- [ ] L629   `wait_frames_140`  *(proc)*
- [ ] L644   `record_experience_entry`  *(proc)*
- [ ] L762   `draw_char_row`  *(proc)*
- [ ] L793   `name_input_loop`  *(proc)*
- [ ] L1052  `update_name_cursor`  *(proc)*
- [ ] L1103  `redraw_name_field`  *(proc)*
- [ ] L1249  `clear_sage_region`  *(proc)*
- [ ] L1257  `draw_sage_tile_grid`  *(proc)*
- [ ] L1299  `render_glyph_32`  *(proc)*
- [ ] L1386  `anim_tick`  *(proc)*
- [ ] L1460  `data_17`  *(data)*
- [ ] L1464  `sage_intro_dispatch`  *(proc)*
- [ ] L1576  `data_18`  *(data)*
- [ ] L1588  `data_21`  *(data)*

## working/zelres2/code/236CMAP.asm  (3 sections)

- [ ] L66    `zr2_36`  *(proc)*
- [ ] L75    `hdr_ptr_tbl`  *(label word)*
- [ ] L170   `cell_boundary`  *(data)*

## working/zelres2/code/238STMP.asm  (0 sections)


## working/zelres2/code/239BSMP.asm  (0 sections)


## working/zelres2/code/250ENDMO.asm  (17 sections)

- [ ] L240   `ending_scene_main`  *(proc)*
- [ ] L456   `timer_wait_loop`  *(proc)*
- [ ] L467   `gfx_driver_tick_full`  *(proc)*
- [ ] L480   `render_narration_page`  *(proc)*
- [ ] L841   `measure_script_word_width`  *(proc)*
- [ ] L938   `credits_loop_main`  *(proc)*
- [ ] L1081  `credits_putchar`  *(proc)*
- [ ] L1214  `credits_wait_tick`  *(proc)*
- [ ] L1225  `credits_driver_tick`  *(proc)*
- [ ] L1238  `rle_blit_pair`  *(proc)*
- [ ] L1244  `rle_decode_plane`  *(proc)*
- [ ] L1359  `fill_credits_triplane`  *(proc)*
- [ ] L1862  `bitmap_row_byte`  *(data)*
- [ ] L2121  `full_scroll_fn_ptr`  *(data)*
- [ ] L2193  `ref_waku_grp`  *(data)*
- [ ] L2195  `ref_sei_grp`  *(data)*
- [ ] L2197  `ref_yuup_grp`  *(data)*

## working/zelres3/code/300ROKAD.asm  (10 sections)

- [ ] L160   `roka_demo_main`  *(proc)*
- [ ] L445   `draw_pose_3x3`  *(proc)*
- [ ] L508   `pose_tile_data`  *(label byte)*
- [ ] L549   `wait_frame`  *(proc)*
- [ ] L562   `bres_setup`  *(proc)*
- [ ] L613   `bres_step`  *(proc)*
- [ ] L690   `pose_palette_dat`  *(label byte)*
- [ ] L694   `pose_target_tbl`  *(label word)*
- [ ] L713   `ref_mfan_msd`  *(label byte)*
- [ ] L718   `ref_6dman_grp`  *(label byte)*

## working/zelres3/code/301EAI1.asm  (11 sections)

- [ ] L127   `crab_ai_main`  *(proc)*
- [ ] L163   `crab_frame_ptr_tbl_a`  *(label word)*
- [ ] L170   `crab_frame_ptr_tbl_b`  *(label word)*
- [ ] L177   `crab_frame_ptr_tbl_c`  *(label word)*
- [ ] L182   `crab_frame_ptr_tbl_d`  *(label word)*
- [ ] L187   `crab_frame_ptr_tbl_e`  *(label word)*
- [ ] L236   `crab_facing_fn_ptr`  *(data)*
- [ ] L305   `crab_anim_phase_marker`  *(data)*
- [ ] L562   `phase_advance_helper`  *(proc)*
- [ ] L706   `distance_check_8`  *(proc)*
- [ ] L971   `distance_check_6`  *(proc)*

## working/zelres3/code/302EAI2.asm  (28 sections)

- [ ] L129   `tako_ai_main`  *(proc)*
- [ ] L163   `tako_frame_ptr_tbl_a`  *(label word)*
- [ ] L171   `tako_frame_ptr_tbl_b`  *(label word)*
- [ ] L181   `tako_frame_ptr_tbl_c`  *(label word)*
- [ ] L186   `tako_frame_ptr_tbl_d`  *(label word)*
- [ ] L191   `tako_frame_ptr_tbl_e_marker`  *(label byte)*
- [ ] L192   `data_3`  *(data)*
- [ ] L216   `tako_frame_A0D8`  *(label byte)*
- [ ] L225   `tako_frame_A100`  *(label byte)*
- [ ] L240   `tako_helper_anchor`  *(label byte)*
- [ ] L241   `data_6`  *(data)*
- [ ] L274   `tako_frame_A1B9`  *(label byte)*
- [ ] L283   `tako_frame_A1E1`  *(label byte)*
- [ ] L300   `tako_frame_A23B`  *(label byte)*
- [ ] L322   `tako_frame_A2B3`  *(label byte)*
- [ ] L329   `tako_frame_A2D1`  *(label byte)*
- [ ] L341   `tako_frame_A30D`  *(label byte)*
- [ ] L362   `tako_aux_ptr_tbl`  *(label word)*
- [ ] L600   `tako_tentacle_mask_a`  *(data)*
- [ ] L601   `tako_tentacle_mask_b`  *(data)*
- [ ] L607   `step_pos_x`  *(proc)*
- [ ] L636   `collide_check_right`  *(proc)*
- [ ] L671   `step_neg_x`  *(proc)*
- [ ] L699   `collide_check_left`  *(proc)*
- [ ] L734   `step_swim_y`  *(proc)*
- [ ] L761   `collide_check_y`  *(proc)*
- [ ] L1061  `distance_check_5`  *(proc)*
- [ ] L1303  `phase_advance_helper`  *(proc)*

## working/zelres3/code/303EAI3.asm  (9 sections)

- [ ] L89    `tori_ai_main`  *(proc)*
- [ ] L115   `tori_frame_ptr_tbl_a`  *(label word)*
- [ ] L122   `tori_frame_ptr_tbl_b`  *(label word)*
- [ ] L129   `tori_frame_ptr_tbl_c`  *(label word)*
- [ ] L134   `tori_frame_ptr_tbl_d`  *(label word)*
- [ ] L139   `tori_frame_ptr_tbl_e`  *(label word)*
- [ ] L292   `tori_aux_ptr_tbl`  *(label word)*
- [ ] L809   `tori_dist_check_5`  *(proc)*
- [ ] L942   `tori_dist_check_6`  *(proc)*

## working/zelres3/code/304EAI4.asm  (7 sections)

- [ ] L96    `zela_ai_main`  *(proc)*
- [ ] L146   `zela_anim_state_marker`  *(data)*
- [ ] L178   `zela_rng_fn_ptr`  *(data)*
- [ ] L182   `zela_phase_marker`  *(data)*
- [ ] L215   `zela_anim_phase_idx`  *(data)*
- [ ] L814   `collide_check_dist`  *(proc)*
- [ ] L917   `zela_lookup_state`  *(proc)*

## working/zelres3/code/305EAI5.asm  (13 sections)

- [ ] L122   `meda_ai_main`  *(proc)*
- [ ] L195   `meda_collide_marker`  *(data)*
- [ ] L197   `meda_anim_state_ref`  *(data)*
- [ ] L237   `meda_rng_fn_ptr`  *(data)*
- [ ] L263   `meda_anim_idx_a`  *(data)*
- [ ] L266   `meda_anim_idx_b`  *(data)*
- [ ] L607   `phase_step_fwd`  *(proc)*
- [ ] L636   `collide_check_fwd`  *(proc)*
- [ ] L671   `phase_step_back`  *(proc)*
- [ ] L699   `collide_check_back`  *(proc)*
- [ ] L734   `sub01_collide_outer`  *(proc)*
- [ ] L761   `sub01_collide_inner`  *(proc)*
- [ ] L790   `distance_check_4`  *(proc)*

## working/zelres3/code/306EAI6.asm  (14 sections)

- [ ] L120   `eai6_main`  *(proc)*
- [ ] L145   `eai6_anim_phase`  *(data)*
- [ ] L149   `eai6_collide_marker`  *(data)*
- [ ] L174   `eai6_rng_fn_ptr`  *(data)*
- [ ] L433   `distance_check_4`  *(proc)*
- [ ] L471   `phase_step_fwd`  *(proc)*
- [ ] L500   `collide_check_fwd`  *(proc)*
- [ ] L535   `phase_step_back`  *(proc)*
- [ ] L563   `collide_check_back`  *(proc)*
- [ ] L598   `sub01_collide_outer`  *(proc)*
- [ ] L625   `sub01_collide_inner`  *(proc)*
- [ ] L841   `distance_check_8`  *(proc)*
- [ ] L987   `sub02_flip_to_state2`  *(proc)*
- [ ] L1008  `sub02_block_or_advance`  *(proc)*

## working/zelres3/code/307EAI7.asm  (12 sections)

- [ ] L142   `eai7_main`  *(proc)*
- [ ] L179   `eai7_collide_marker`  *(data)*
- [ ] L208   `eai7_rng_fn_ptr`  *(data)*
- [ ] L227   `eai7_anim_state_ref`  *(data)*
- [ ] L500   `phase_step_fwd`  *(proc)*
- [ ] L529   `collide_check_fwd`  *(proc)*
- [ ] L564   `phase_step_back`  *(proc)*
- [ ] L592   `collide_check_back`  *(proc)*
- [ ] L627   `sub01_collide_outer`  *(proc)*
- [ ] L654   `sub01_collide_inner`  *(proc)*
- [ ] L692   `distance_check_5`  *(proc)*
- [ ] L1032  `distance_check_6`  *(proc)*

## working/zelres3/code/308EAI8.asm  (8 sections)

- [ ] L133   `eai8_main`  *(proc)*
- [ ] L212   `eai8_rng_fn_ptr`  *(data)*
- [ ] L415   `collide_check_fwd`  *(proc)*
- [ ] L482   `collide_check_back`  *(proc)*
- [ ] L709   `rng_pick_facing`  *(proc)*
- [ ] L771   `phase_advance_helper`  *(proc)*
- [ ] L870   `distance_check_8`  *(proc)*
- [ ] L910   `distance_check_5`  *(proc)*

## working/zelres3/code/309CRAB.asm  (9 sections)

- [ ] L102   `crab_main`  *(proc)*
- [ ] L131   `crab_frame_ptr_tbl_a`  *(label word)*
- [ ] L137   `crab_frame_ptr_tbl_b`  *(label word)*
- [ ] L192   `crab_const_2600`  *(data)*
- [ ] L232   `crab_const_2692`  *(data)*
- [ ] L549   `hp_dec`  *(proc)*
- [ ] L567   `hp_inc`  *(proc)*
- [ ] L874   `emit_sprite_rows_proc`  *(proc)*
- [ ] L998   `prep_phase`  *(proc)*

## working/zelres3/code/310TAKO.asm  (7 sections)

- [ ] L102   `tako_main`  *(proc)*
- [ ] L135   `tako_frame_ptr_tbl_a`  *(label word)*
- [ ] L140   `tako_frame_ptr_tbl_b`  *(label word)*
- [ ] L659   `hp_dec`  *(proc)*
- [ ] L759   `tako_row_data_ptrs`  *(label word)*
- [ ] L1121  `tako_pattern_ptr_tbl`  *(label word)*
- [ ] L1138  `tako_sprite_patterns`  *(label word)*

## working/zelres3/code/311TORI.asm  (13 sections)

- [ ] L110   `tori_main`  *(proc)*
- [ ] L141   `tori_frame_ptr_tbl_a`  *(label word)*
- [ ] L221   `tori_scan_acc_a`  *(data)*
- [ ] L223   `tori_scan_acc_b`  *(data)*
- [ ] L228   `tori_glyph_tbl`  *(data)*
- [ ] L293   `tori_extern_fn_ptr`  *(data)*
- [ ] L780   `tori_render_sprite_row`  *(proc)*
- [ ] L816   `tori_swoop_tick`  *(proc)*
- [ ] L834   `tori_hp_dec_if_ge_D`  *(proc)*
- [ ] L850   `tori_hp_dec_if_ge_11`  *(proc)*
- [ ] L867   `tori_hp_inc_if_below_30`  *(proc)*
- [ ] L887   `tori_apply_damage`  *(proc)*
- [ ] L1010  `tori_const_ptr_tbl`  *(label word)*

## working/zelres3/code/312ZELA.asm  (8 sections)

- [ ] L106   `_312MAPST`  *(proc)*
- [ ] L153   `zela_const_word_8`  *(data)*
- [ ] L186   `zela_rng_fn_ptr`  *(data)*
- [ ] L409   `scroll_phase_dec`  *(proc)*
- [ ] L645   `init_tile_slots`  *(proc)*
- [ ] L671   `bound_xpos_inc`  *(proc)*
- [ ] L684   `bound_xpos_dec`  *(proc)*
- [ ] L714   `scroll_apply`  *(proc)*

## working/zelres3/code/313MEDA.asm  (13 sections)

- [ ] L89    `_313MAPBT`  *(proc)*
- [ ] L116   `header_tile_row_a`  *(data)*
- [ ] L127   `header_const_word_a`  *(data)*
- [ ] L129   `header_text_table`  *(data)*
- [ ] L368   `phase_dir_compute`  *(proc)*
- [ ] L424   `phase_clear_cells`  *(proc)*
- [ ] L455   `phase_dec_clamped`  *(proc)*
- [ ] L462   `phase_inc_clamped`  *(proc)*
- [ ] L470   `bound_xpos_inc`  *(proc)*
- [ ] L482   `bound_xpos_dec`  *(proc)*
- [ ] L493   `render_tiles_main`  *(proc)*
- [ ] L603   `render_tile_row`  *(proc)*
- [ ] L646   `scroll_step_finalize`  *(proc)*

## working/zelres3/code/314LEGA.asm  (15 sections)

- [ ] L107   `lega_main`  *(proc)*
- [ ] L122   `lega_hdr_fill_a`  *(data)*
- [ ] L123   `lega_hdr_const_50`  *(data)*
- [ ] L124   `lega_hdr_const_0a_pair`  *(data)*
- [ ] L126   `lega_tile_data_block_a`  *(data)*
- [ ] L131   `lega_ptr_table_a`  *(data)*
- [ ] L153   `lega_tile_data_block_b`  *(data)*
- [ ] L155   `lega_tile_data_block_c`  *(data)*
- [ ] L423   `lega_phase_step_tbl_a`  *(data)*
- [ ] L425   `lega_phase_step_tbl_b`  *(data)*
- [ ] L430   `lega_scroll_dec_step`  *(proc)*
- [ ] L444   `lega_scroll_inc_step`  *(proc)*
- [ ] L656   `lega_render_anim2_cell`  *(proc)*
- [ ] L691   `lega_scroll_finalize`  *(proc)*
- [ ] L735   `lega_idle_xlat_tbl`  *(data)*

## working/zelres3/code/315ZEL2.asm  (11 sections)

- [ ] L102   `_315MAPHT`  *(proc)*
- [ ] L136   `zel2_scroll_target_base`  *(data)*
- [ ] L143   `zel2_data_word_3115`  *(data)*
- [ ] L181   `zel2_rng_fn_ptr`  *(data)*
- [ ] L374   `zel2_phase_step_dec`  *(proc)*
- [ ] L596   `zel2_anim_delta_tbl`  *(label byte)*
- [ ] L600   `zel2_setup_anim_segment`  *(proc)*
- [ ] L626   `zel2_scroll_inc_step`  *(proc)*
- [ ] L639   `zel2_scroll_dec_step`  *(proc)*
- [ ] L663   `zel2_scroll_finalize`  *(proc)*
- [ ] L748   `zel2_trailer_word`  *(data)*

## working/zelres3/code/316DRGN.asm  (12 sections)

- [ ] L119   `drgn_main`  *(proc)*
- [ ] L156   `drgn_tile_data_a`  *(data)*
- [ ] L159   `drgn_tile_data_b`  *(data)*
- [ ] L166   `drgn_tile_data_c`  *(data)*
- [ ] L175   `drgn_tile_data_d`  *(data)*
- [ ] L204   `drgn_tile_dispatch_word`  *(data)*
- [ ] L541   `drgn_scroll_dec`  *(proc)*
- [ ] L556   `drgn_scroll_inc`  *(proc)*
- [ ] L812   `drgn_render_col_pack`  *(proc)*
- [ ] L852   `drgn_data_trailer`  *(label byte)*
- [ ] L965   `drgn_phase_step_cb`  *(proc)*
- [ ] L1030  `drgn_trailer_data`  *(label byte)*

## working/zelres3/code/317AKMA.asm  (11 sections)

- [ ] L114   `_317MAPA4`  *(proc)*
- [ ] L143   `akma_data_word_a`  *(data)*
- [ ] L145   `akma_data_byte_b`  *(data)*
- [ ] L153   `akma_data_byte_c`  *(data)*
- [ ] L472   `akma_scroll_dec`  *(proc)*
- [ ] L488   `akma_scroll_inc`  *(proc)*
- [ ] L813   `akma_render_emit_cell`  *(proc)*
- [ ] L842   `akma_render_col_pack`  *(proc)*
- [ ] L885   `akma_data_trailer`  *(label byte)*
- [ ] L994   `akma_phase_step_cb`  *(proc)*
- [ ] L1066  `akma_module_trailer`  *(label byte)*

## working/zelres3/code/318MAO1.asm  (26 sections)

- [ ] L106   `_318MAPA5`  *(proc)*
- [ ] L125   `mao1_layout_data`  *(label byte)*
- [ ] L127   `mao1_layout_ptr_tbl`  *(label word)*
- [ ] L132   `mao1_layout_cells`  *(label byte)*
- [ ] L149   `mao1_data_word_a`  *(data)*
- [ ] L153   `mao1_data_word_b`  *(data)*
- [ ] L157   `mao1_data_word_c`  *(data)*
- [ ] L167   `mao1_data_byte_d`  *(data)*
- [ ] L173   `mao1_data_byte_e`  *(data)*
- [ ] L175   `mao1_layout_cells_ext`  *(label byte)*
- [ ] L210   `mao1_layout_data_a`  *(label byte)*
- [ ] L248   `mao1_layout_cells_tail`  *(label byte)*
- [ ] L264   `mao1_layout_cells_tail_end`  *(label byte)*
- [ ] L481   `mao1_trailer_data`  *(label byte)*
- [ ] L486   `mao1_xlat_row_c0_a`  *(label byte)*
- [ ] L492   `mao1_xlat_row_c0_b`  *(label byte)*
- [ ] L497   `mao1_xlat_row_c0_c`  *(label byte)*
- [ ] L502   `mao1_dialog_lo_tbl_data`  *(label byte)*
- [ ] L506   `mao1_dialog_lead_in`  *(label byte)*
- [ ] L512   `mao1_dialog_jashiin`  *(label byte)*
- [ ] L523   `mao1_dialog_handler_tbl`  *(label word)*
- [ ] L536   `mao1_dialog_data_b`  *(label byte)*
- [ ] L608   `mao1_arena_ptr_tbl`  *(label byte)*
- [ ] L614   `mao1_glyph_atlas`  *(label byte)*
- [ ] L626   `mao1_arena_init_params`  *(label byte)*
- [ ] L633   `mao1_speaker_jashiin`  *(label byte)*

## working/zelres3/code/319MAO2.asm  (40 sections)

- [ ] L162   `_319MAPA6`  *(proc)*
- [ ] L173   `mao2_hdr_byte_5`  *(data)*
- [ ] L179   `mao2_layout_extended`  *(data)*
- [ ] L181   `mao2_layout_ptr_tbl_a`  *(label byte)*
- [ ] L186   `mao2_layout_ptr_tbl_b`  *(label byte)*
- [ ] L189   `mao2_layout_count_a`  *(data)*
- [ ] L191   `mao2_layout_count_b`  *(data)*
- [ ] L193   `mao2_layout_cells_a`  *(label byte)*
- [ ] L219   `mao2_layout_cells_a_tail`  *(data)*
- [ ] L220   `mao2_dispatch_ptr`  *(data)*
- [ ] L222   `mao2_layout_cells_b`  *(label byte)*
- [ ] L242   `mao2_main_dispatch`  *(proc)*
- [ ] L255   `mao2_layout_cells_c`  *(label byte)*
- [ ] L261   `mao2_layout_data_b`  *(data)*
- [ ] L263   `mao2_layout_cells_d`  *(label byte)*
- [ ] L299   `mao2_layout_cells_e`  *(label byte)*
- [ ] L315   `mao2_layout_cells_f`  *(label byte)*
- [ ] L324   `mao2_npc_scan_init`  *(label byte)*
- [ ] L492   `mao2_phase_ofs_data`  *(label byte)*
- [ ] L495   `mao2_phase_ofs_data_end`  *(data)*
- [ ] L497   `mao2_pick_target_idx`  *(proc)*
- [ ] L716   `mao2_handler_step_data`  *(label byte)*
- [ ] L724   `mao2_handler_step_data_end`  *(data)*
- [ ] L726   `mao2_target_dec`  *(proc)*
- [ ] L742   `mao2_target_inc`  *(proc)*
- [ ] L989   `mao2_dlg_a_init`  *(proc)*
- [ ] L1006  `mao2_dlg_b_init`  *(proc)*
- [ ] L1024  `mao2_unpack_bp_to_buf`  *(proc)*
- [ ] L1061  `mao2_dlg_data_block_a`  *(label byte)*
- [ ] L1125  `mao2_dlg_msg_data_a`  *(label byte)*
- [ ] L1129  `mao2_dlg_msg_ptr_tbl_a`  *(label byte)*
- [ ] L1137  `mao2_dlg_state_xlat`  *(label byte)*
- [ ] L1157  `mao2_dlg_state_xlat_tail`  *(label byte)*
- [ ] L1161  `mao2_dlg_handler_tbl_a`  *(label byte)*
- [ ] L1168  `mao2_dlg_step_recs_a`  *(label byte)*
- [ ] L1184  `mao2_dlg_handler_tbl_b`  *(label byte)*
- [ ] L1191  `mao2_dlg_step_recs_b`  *(label byte)*
- [ ] L1208  `mao2_pos_sub`  *(proc)*
- [ ] L1238  `mao2_pos_step`  *(proc)*
- [ ] L1296  `mao2_alt_state_trailer`  *(label byte)*

