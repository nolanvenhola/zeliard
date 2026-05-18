# Shared-buffer audit

Addresses with **multiple distinct EQU names across chunks** —
prime suspects for "write here / consume there" mistakes where
the local symbol grep misses the cross-chunk consumer.

Total addresses with ≥2 distinct names: **318**

Run via `python shared_buffer_audit.py` in `3_Assembly/tasm/`.

---

## 0x6000 — 14 distinct names across 12 chunks

Names: `bos_limit_6000`, `cga_wrap_limit`, `chunk0_base`, `framebuffer_b`, `game_data_base`, `gvar_game_seg_b`, `hgc_bank1_end`, `hgc_bank_bdy`, `hgc_bank_size`, `hgc_wrap_limit`, `loaded_code_b`, `tile_bank2_base`, `tile_src_a`, `vga_limit`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `loaded_code_b` (L125) |
| `drivers/gmhgc.asm` | `hgc_bank_size` (L94) |
| `zelres1/code/100OPDMO.asm` | `framebuffer_b` (L70) |
| `zelres1/code/103GDHGC.asm` | `hgc_bank1_end` (L73) |
| `zelres1/code/109GTHGC.asm` | `tile_bank2_base` (L49), `hgc_bank_bdy` (L75), `hgc_bank_size` (L83) |
| `zelres1/code/111GTMCA.asm` | `chunk0_base` (L68) |
| `zelres1/code/zr1com.inc` | `tile_src_a` (L189) |
| `zelres2/code/204GFHGC.asm` | `gvar_game_seg_b` (L46), `hgc_wrap_limit` (L84) |
| `zelres2/code/207MOLE.asm` | `vga_limit` (L75) |
| `zelres2/code/208YMPD.asm` | `cga_wrap_limit` (L98) |
| `zelres2/code/209CKPD.asm` | `bos_limit_6000` (L107) |
| `zelres2/code/zr2com.inc` | `game_data_base` (L228) |

## 0x8000 — 12 distinct names across 11 chunks

Names: `chunk_load_buf`, `drgn_buf_tile_src`, `enemy_id_table`, `screen_buf_1`, `script_src_a`, `script_src_b`, `sprite_buf_ofs`, `sprite_src_base`, `tga_work_buf`, `tile_cache_base`, `tileset_buf_a`, `tileset_index`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/100OPDMO.asm` | `screen_buf_1` (L82) |
| `zelres1/code/104GDTGA.asm` | `tga_work_buf` (L66) |
| `zelres1/code/108GTCGA.asm` | `tileset_index` (L89) |
| `zelres1/code/111GTMCA.asm` | `tile_cache_base` (L45) |
| `zelres1/code/zr1com.inc` | `tileset_buf_a` (L191) |
| `zelres2/code/200FIGHT.asm` | `enemy_id_table` (L251) |
| `zelres2/code/202GFEGA.asm` | `sprite_src_base` (L93) |
| `zelres2/code/212ARMRP.asm` | `chunk_load_buf` (L60) |
| `zelres2/code/250ENDMO.asm` | `script_src_a` (L125), `script_src_b` (L127) |
| `zelres2/code/zr2com.inc` | `sprite_buf_ofs` (L230) |
| `zelres3/code/316DRGN.asm` | `drgn_buf_tile_src` (L54) |

## 0x80A0 — 11 distinct names across 6 chunks

Names: `bos_limit_wrap`, `mcga_wrap_b`, `tga_bank_wrap`, `tga_buf_wrap`, `tga_seg`, `tga_vram_wrap`, `tga_vram_wrap_b`, `tga_vram_wrap_c`, `tga_work_buf_p2`, `tga_wrap`, `tga_wrap2`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmtga.asm` | `tga_wrap` (L69), `tga_seg` (L77) |
| `zelres1/code/104GDTGA.asm` | `tga_bank_wrap` (L62), `tga_work_buf_p2` (L67), `tga_buf_wrap` (L68) |
| `zelres1/code/110GTTGA.asm` | `tga_wrap` (L66), `tga_wrap2` (L74) |
| `zelres2/code/205GFTGA.asm` | `tga_vram_wrap` (L46), `tga_vram_wrap_b` (L72), `tga_vram_wrap_c` (L74) |
| `zelres2/code/207MOLE.asm` | `mcga_wrap_b` (L76) |
| `zelres2/code/209CKPD.asm` | `bos_limit_wrap` (L108) |

## 0x00A0 — 10 distinct names across 11 chunks

Names: `ANIM_A0`, `SCR_ATTR_RST`, `cga_col_stride`, `char_width_half`, `gvar_roka_scene`, `music_track_count`, `spells_learned_count`, `stat_XA0`, `tears_of_esmesanti_count`, `tga_row_stride`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `spells_learned_count` (L47), `music_track_count` (L48) |
| `drivers/gmmcga.asm` | `char_width_half` (L96) |
| `drivers/stdply.inc` | `tears_of_esmesanti_count` (L198), `spells_learned_count` (L199), `music_track_count` (L200), `stat_XA0` (L201) |
| `zelres1/code/100OPDMO.asm` | `SCR_ATTR_RST` (L196) |
| `zelres1/code/zr1com.inc` | `tears_of_esmesanti_count` (L205) |
| `zelres2/code/203GFCGA.asm` | `cga_col_stride` (L160) |
| `zelres2/code/205GFTGA.asm` | `tga_row_stride` (L93) |
| `zelres2/code/250ENDMO.asm` | `ANIM_A0` (L192) |
| `zelres2/code/zr2com.inc` | `tears_of_esmesanti_count` (L239) |
| `zelres3/code/300ROKAD.asm` | `gvar_roka_scene` (L119) |
| `zelres3/code/zr3com.inc` | `tears_of_esmesanti_count` (L126) |

## 0x4000 — 9 distinct names across 7 chunks

Names: `cga_work_buf`, `ega_wrap_limit`, `framebuf_a`, `framebuf_b`, `framebuffer_a`, `hgc_work_buf`, `scene_framebuf`, `sprite_gfx_base`, `sprite_load_dest`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/100OPDMO.asm` | `framebuffer_a` (L68), `scene_framebuf` (L122) |
| `zelres1/code/102GDCGA.asm` | `cga_work_buf` (L72) |
| `zelres1/code/103GDHGC.asm` | `hgc_work_buf` (L70) |
| `zelres2/code/200FIGHT.asm` | `sprite_load_dest` (L287) |
| `zelres2/code/208YMPD.asm` | `ega_wrap_limit` (L99) |
| `zelres2/code/250ENDMO.asm` | `framebuf_a` (L122), `framebuf_b` (L126) |
| `zelres2/code/zr2com.inc` | `sprite_gfx_base` (L227) |

## 0xA000 — 9 distinct names across 12 chunks

Names: `GAME_CODE_BASE`, `ega_seg`, `game_fn_vtable`, `mca_seg`, `misdec_A000`, `sprite_data_base`, `sprite_obj_tbl`, `vga_seg`, `vga_seg_A000`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `GAME_CODE_BASE` (L141) |
| `core/zeliard.inc` | `GAME_CODE_BASE` (L15) |
| `drivers/gmega.asm` | `ega_seg` (L57) |
| `drivers/gmmcga.asm` | `vga_seg` (L81) |
| `zelres1/code/106TOWN.asm` | `vga_seg_A000` (L159) |
| `zelres1/code/109GTHGC.asm` | `sprite_data_base` (L76) |
| `zelres1/code/zr1com.inc` | `sprite_obj_tbl` (L118), `vga_seg` (L119) |
| `zelres2/code/200FIGHT.asm` | `game_fn_vtable` (L348) |
| `zelres2/code/202GFEGA.asm` | `ega_seg` (L94) |
| `zelres2/code/206GFMCA.asm` | `mca_seg` (L104) |
| `zelres2/code/207MOLE.asm` | `misdec_A000` (L97) |
| `zelres2/code/250ENDMO.asm` | `vga_seg` (L143) |

## 0xA05A — 9 distinct names across 5 chunks

Names: `cga_wrap_55e`, `cga_wrap_c`, `hgc_bank2_wrap`, `hgc_bank2_wrap_b`, `hgc_row_addend`, `hgc_stride`, `hgc_stride_b`, `hgc_wrap_add_b`, `sprite_src_c`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmhgc.asm` | `hgc_row_addend` (L71) |
| `zelres1/code/103GDHGC.asm` | `hgc_bank2_wrap` (L68), `hgc_bank2_wrap_b` (L75) |
| `zelres1/code/109GTHGC.asm` | `hgc_stride` (L78), `hgc_stride_b` (L86) |
| `zelres2/code/204GFHGC.asm` | `sprite_src_c` (L79), `hgc_wrap_add_b` (L86) |
| `zelres2/code/209CKPD.asm` | `cga_wrap_c` (L94), `cga_wrap_55e` (L109) |

## 0xC050 — 9 distinct names across 7 chunks

Names: `bos_wrap_c050`, `cga_bank2_wrap`, `cga_row_addend`, `cga_wrap`, `cga_wrap2`, `cga_wrap_add`, `ega_wrap_addend`, `vga_wrap_adj`, `wrap_delta`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmcga.asm` | `cga_row_addend` (L44) |
| `zelres1/code/102GDCGA.asm` | `cga_bank2_wrap` (L70) |
| `zelres1/code/108GTCGA.asm` | `cga_wrap` (L73), `cga_wrap2` (L84) |
| `zelres2/code/203GFCGA.asm` | `vga_wrap_adj` (L78), `cga_wrap_add` (L82) |
| `zelres2/code/207MOLE.asm` | `wrap_delta` (L74) |
| `zelres2/code/208YMPD.asm` | `ega_wrap_addend` (L97) |
| `zelres2/code/209CKPD.asm` | `bos_wrap_c050` (L110) |

## 0xD000 — 9 distinct names across 8 chunks

Names: `cga_sprite_mid`, `ext_seg_d000`, `ext_segment`, `hgc_extended_src`, `mca_pattern_base`, `overlay_seg`, `pattern_buf_d000`, `tile_mask_base`, `tile_mask_data`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/100OPDMO.asm` | `ext_segment` (L74), `ext_seg_d000` (L115) |
| `zelres1/code/109GTHGC.asm` | `tile_mask_base` (L50) |
| `zelres1/code/111GTMCA.asm` | `overlay_seg` (L48) |
| `zelres1/code/zr1com.inc` | `tile_mask_data` (L179) |
| `zelres2/code/203GFCGA.asm` | `cga_sprite_mid` (L53) |
| `zelres2/code/204GFHGC.asm` | `hgc_extended_src` (L56) |
| `zelres2/code/205GFTGA.asm` | `pattern_buf_d000` (L50) |
| `zelres2/code/206GFMCA.asm` | `mca_pattern_base` (L73) |

## 0xB000 — 8 distinct names across 10 chunks

Names: `aux_buf_seg`, `cga_sprite_src`, `ega_sprite_src`, `herc_video_seg`, `hgc_seg`, `hgc_sprite_src`, `mca_sprite_src_b`, `sprite_src_base`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmhgc.asm` | `hgc_seg` (L103) |
| `drivers/stick.asm` | `herc_video_seg` (L70) |
| `drivers/stick.inc` | `herc_video_seg` (L30) |
| `zelres1/code/100OPDMO.asm` | `aux_buf_seg` (L113) |
| `zelres1/code/103GDHGC.asm` | `hgc_seg` (L44) |
| `zelres2/code/202GFEGA.asm` | `ega_sprite_src` (L65) |
| `zelres2/code/203GFCGA.asm` | `cga_sprite_src` (L51) |
| `zelres2/code/204GFHGC.asm` | `hgc_sprite_src` (L54), `hgc_seg` (L88) |
| `zelres2/code/205GFTGA.asm` | `sprite_src_base` (L48) |
| `zelres2/code/206GFMCA.asm` | `mca_sprite_src_b` (L71) |

## 0xC010 — 8 distinct names across 7 chunks

Names: `akma_sprite_attr_ptr`, `drgn_sprite_attr_ptr`, `enemy_attr_base`, `fight_slot_list`, `mao1_sprite_attr_ptr`, `mao2_sprite_attr_ptr`, `object_list_ptr`, `sprite_attr_base`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `object_list_ptr` (L360) |
| `zelres2/code/zr2com.inc` | `sprite_attr_base` (L215) |
| `zelres3/code/316DRGN.asm` | `drgn_sprite_attr_ptr` (L77) |
| `zelres3/code/317AKMA.asm` | `akma_sprite_attr_ptr` (L84) |
| `zelres3/code/318MAO1.asm` | `mao1_sprite_attr_ptr` (L86) |
| `zelres3/code/319MAO2.asm` | `mao2_sprite_attr_ptr` (L116) |
| `zelres3/code/zr3com.inc` | `enemy_attr_base` (L44), `fight_slot_list` (L45) |

## 0xED20 — 8 distinct names across 7 chunks

Names: `akma_sprite_xlat_tbl`, `char_lookup`, `drgn_sprite_xlat_tbl`, `enemy_data_ext`, `mao1_sprite_xlat_tbl`, `mao2_sprite_xlat_tbl`, `sprite_idx_table`, `sprite_xlat_tbl`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `enemy_data_ext` (L376) |
| `zelres2/code/zr2com.inc` | `char_lookup` (L220) |
| `zelres3/code/316DRGN.asm` | `drgn_sprite_xlat_tbl` (L78) |
| `zelres3/code/317AKMA.asm` | `akma_sprite_xlat_tbl` (L85) |
| `zelres3/code/318MAO1.asm` | `mao1_sprite_xlat_tbl` (L88) |
| `zelres3/code/319MAO2.asm` | `mao2_sprite_xlat_tbl` (L117) |
| `zelres3/code/zr3com.inc` | `sprite_xlat_tbl` (L48), `sprite_idx_table` (L49), `enemy_data_ext` (L50) |

## 0x2000 — 7 distinct names across 12 chunks

Names: `driver_base`, `drv_fill_rect`, `gfx_fill_fn`, `gfx_fillrect_fn`, `gfx_screen_base`, `level_seg_ofs`, `mao1_drv_load_chunk`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmcga.asm` | `driver_base` (L80) |
| `drivers/gmega.asm` | `driver_base` (L72) |
| `drivers/gmhgc.asm` | `driver_base` (L102) |
| `drivers/gmmcga.asm` | `driver_base` (L80) |
| `drivers/gmtga.asm` | `driver_base` (L76) |
| `drivers/stick.inc` | `gfx_screen_base` (L17) |
| `zelres1/code/106TOWN.asm` | `gfx_fill_fn` (L85) |
| `zelres1/code/zr1com.inc` | `drv_fill_rect` (L89) |
| `zelres2/code/204GFHGC.asm` | `level_seg_ofs` (L87) |
| `zelres2/code/zr2com.inc` | `drv_fill_rect` (L91) |
| `zelres3/code/300ROKAD.asm` | `gfx_fillrect_fn` (L106) |
| `zelres3/code/318MAO1.asm` | `mao1_drv_load_chunk` (L58) |

## 0xC002 — 7 distinct names across 6 chunks

Names: `akma_sprite_attr_cnt`, `fight_state_max`, `gvar_proj_cnt`, `mao2_sprite_attr_max`, `map_width`, `town_map_width`, `zel2_sprite_attr_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `town_map_width` (L163) |
| `zelres2/code/200FIGHT.asm` | `map_width` (L354) |
| `zelres3/code/315ZEL2.asm` | `zel2_sprite_attr_ptr` (L62) |
| `zelres3/code/317AKMA.asm` | `akma_sprite_attr_cnt` (L106) |
| `zelres3/code/319MAO2.asm` | `mao2_sprite_attr_max` (L154) |
| `zelres3/code/zr3com.inc` | `fight_state_max` (L42), `gvar_proj_cnt` (L43) |

## 0x2022 — 6 distinct names across 7 chunks

Names: `bos_var_25e`, `cga_dispatch_fn`, `drv_render_char`, `gfx_draw_char_fn`, `gfx_fn_setup`, `hgc_dispatch_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stick.inc` | `gfx_fn_setup` (L18) |
| `zelres1/code/102GDCGA.asm` | `cga_dispatch_fn` (L46) |
| `zelres1/code/103GDHGC.asm` | `hgc_dispatch_fn` (L46) |
| `zelres1/code/106TOWN.asm` | `gfx_draw_char_fn` (L97) |
| `zelres1/code/zr1com.inc` | `drv_render_char` (L104) |
| `zelres2/code/209CKPD.asm` | `bos_var_25e` (L123) |
| `zelres2/code/zr2com.inc` | `drv_render_char` (L117) |

## 0xFF57 — 6 distinct names across 7 chunks

Names: `flag_buy_mode`, `gvar_flag57`, `gvar_item_flag`, `gvar_scroll_flag`, `gvar_sel_flag`, `gvar_ui_misc_byte`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_sel_flag` (L62) |
| `zelres1/code/108GTCGA.asm` | `gvar_scroll_flag` (L36) |
| `zelres1/code/111GTMCA.asm` | `gvar_flag57` (L37) |
| `zelres1/code/zr1com.inc` | `gvar_sel_flag` (L148), `gvar_item_flag` (L149) |
| `zelres2/code/212ARMRP.asm` | `gvar_sel_flag` (L53) |
| `zelres2/code/213BANKP.asm` | `gvar_ui_misc_byte` (L52) |
| `zelres2/code/215DRUGP.asm` | `flag_buy_mode` (L83) |

## 0x0080 — 5 distinct names across 8 chunks

Names: `ANIM_80`, `PSP_cmd_size`, `half_stride`, `start_pos_in_town`, `starting_position_in_town`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `PSP_cmd_size` (L113) |
| `drivers/stdply.inc` | `starting_position_in_town` (L31), `start_pos_in_town` (L32) |
| `zelres1/code/100OPDMO.asm` | `ANIM_80` (L143) |
| `zelres1/code/111GTMCA.asm` | `half_stride` (L100) |
| `zelres1/code/zr1com.inc` | `starting_position_in_town` (L20) |
| `zelres2/code/250ENDMO.asm` | `ANIM_80` (L177) |
| `zelres2/code/zr2com.inc` | `starting_position_in_town` (L19) |
| `zelres3/code/zr3com.inc` | `starting_position_in_town` (L101) |

## 0x009A — 5 distinct names across 6 chunks

Names: `ANIM_9A`, `crest_elf`, `player_abilities`, `player_ability_1`, `stat_X9A`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `crest_elf` (L162), `player_ability_1` (L163), `player_abilities` (L164), `stat_X9A` (L165) |
| `zelres1/code/100OPDMO.asm` | `ANIM_9A` (L169) |
| `zelres1/code/zr1com.inc` | `crest_elf` (L40), `player_ability_1` (L41) |
| `zelres2/code/201SELCT.asm` | `player_abilities` (L132) |
| `zelres2/code/zr2com.inc` | `crest_elf` (L75), `player_ability_1` (L76) |
| `zelres3/code/zr3com.inc` | `crest_elf` (L121) |

## 0x023C — 5 distinct names across 5 chunks

Names: `cga_hud_ofs`, `cga_hud_ofs_l`, `cga_mountain_dst`, `cga_src_23c`, `hud_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmcga.asm` | `cga_hud_ofs` (L77) |
| `zelres1/code/108GTCGA.asm` | `cga_hud_ofs_l` (L77) |
| `zelres2/code/203GFCGA.asm` | `hud_ofs` (L80) |
| `zelres2/code/208YMPD.asm` | `cga_mountain_dst` (L93) |
| `zelres2/code/209CKPD.asm` | `cga_src_23c` (L116) |

## 0x2026 — 5 distinct names across 5 chunks

Names: `drv_fn_19`, `drv_fn_blit_on`, `gfx_blit_fn`, `gfx_fn_draw`, `gfx_text_layout_a_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stick.inc` | `gfx_fn_draw` (L19) |
| `zelres1/code/106TOWN.asm` | `gfx_text_layout_a_fn` (L99) |
| `zelres2/code/201SELCT.asm` | `drv_fn_19` (L62) |
| `zelres2/code/217KENJP.asm` | `drv_fn_blit_on` (L83) |
| `zelres3/code/300ROKAD.asm` | `gfx_blit_fn` (L107) |

## 0x2028 — 5 distinct names across 5 chunks

Names: `drv_fn_20`, `drv_fn_blit_off`, `gfx_blit_fn_b`, `gfx_fn_restore`, `gfx_text_layout_b_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stick.inc` | `gfx_fn_restore` (L20) |
| `zelres1/code/106TOWN.asm` | `gfx_text_layout_b_fn` (L100) |
| `zelres2/code/201SELCT.asm` | `drv_fn_20` (L63) |
| `zelres2/code/217KENJP.asm` | `drv_fn_blit_off` (L84) |
| `zelres3/code/300ROKAD.asm` | `gfx_blit_fn_b` (L108) |

## 0x202A — 5 distinct names across 6 chunks

Names: `drv_fn_21`, `drv_fn_draw_str`, `gfx_draw_str_fn`, `gfx_fn_clear`, `mao1_drv_blit_render`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stick.inc` | `gfx_fn_clear` (L21) |
| `zelres1/code/106TOWN.asm` | `gfx_draw_str_fn` (L101) |
| `zelres1/code/zr1com.inc` | `drv_fn_21` (L105) |
| `zelres2/code/217KENJP.asm` | `drv_fn_draw_str` (L85) |
| `zelres2/code/zr2com.inc` | `drv_fn_21` (L106) |
| `zelres3/code/318MAO1.asm` | `mao1_drv_blit_render` (L60) |

## 0xB17E — 5 distinct names across 5 chunks

Names: `cga_plane_alt`, `ega_plane_alt`, `hgc_plane_alt`, `mca_plane_alt`, `plane_alt_b17e`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/202GFEGA.asm` | `ega_plane_alt` (L66) |
| `zelres2/code/203GFCGA.asm` | `cga_plane_alt` (L52) |
| `zelres2/code/204GFHGC.asm` | `hgc_plane_alt` (L55) |
| `zelres2/code/205GFTGA.asm` | `plane_alt_b17e` (L49) |
| `zelres2/code/206GFMCA.asm` | `mca_plane_alt` (L72) |

## 0xC000 — 5 distinct names across 3 chunks

Names: `map_data_ptr`, `save_data_base`, `town_desc_0C000`, `town_walk_hdr`, `world_state_base`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `save_data_base` (L159) |
| `zelres1/code/106TOWN.asm` | `town_desc_0C000` (L84), `town_walk_hdr` (L162) |
| `zelres2/code/200FIGHT.asm` | `world_state_base` (L286), `map_data_ptr` (L353) |

## 0xC006 — 5 distinct names across 6 chunks

Names: `cur_shop_id`, `gvar_menu_sel`, `gvar_sage_id`, `map_bot_ptr`, `town_npc_state`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `map_bot_ptr` (L356) |
| `zelres2/code/212ARMRP.asm` | `town_npc_state` (L108) |
| `zelres2/code/213BANKP.asm` | `gvar_menu_sel` (L50) |
| `zelres2/code/215DRUGP.asm` | `cur_shop_id` (L60) |
| `zelres2/code/216INNAP.asm` | `gvar_menu_sel` (L42) |
| `zelres2/code/217KENJP.asm` | `gvar_sage_id` (L67) |

## 0xFF30 — 5 distinct names across 6 chunks

Names: `gvar_completion`, `gvar_flag_FF30`, `gvar_state_ff30`, `mao2_gvar_state_d`, `zel2_state_ff30`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `gvar_completion` (L115), `gvar_flag_FF30` (L116) |
| `zelres3/code/315ZEL2.asm` | `zel2_state_ff30` (L52) |
| `zelres3/code/316DRGN.asm` | `gvar_state_ff30` (L60) |
| `zelres3/code/317AKMA.asm` | `gvar_state_ff30` (L70) |
| `zelres3/code/319MAO2.asm` | `mao2_gvar_state_d` (L94) |
| `zelres3/code/zr3com.inc` | `gvar_completion` (L27) |

## 0xFF33 — 5 distinct names across 6 chunks

Names: `anim_speed`, `gvar_anim_frames`, `gvar_anim_speed`, `gvar_save_filename`, `gvar_save_flag`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `gvar_save_filename` (L76), `gvar_save_flag` (L77) |
| `core/zeliard.inc` | `gvar_save_filename` (L94), `gvar_save_flag` (L95) |
| `zelres1/code/106TOWN.asm` | `gvar_anim_frames` (L54) |
| `zelres2/code/200FIGHT.asm` | `gvar_save_flag` (L118) |
| `zelres2/code/zr2com.inc` | `gvar_save_flag` (L151), `anim_speed` (L152) |
| `zelres3/code/300ROKAD.asm` | `gvar_anim_speed` (L124) |

## 0xFF4C — 5 distinct names across 2 chunks

Names: `gvar_dialog_ptr`, `gvar_script_ip`, `gvar_script_ptr`, `gvar_state_ptr`, `script_cur_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_dialog_ptr` (L55) |
| `zelres2/code/zr2com.inc` | `gvar_script_ip` (L169), `gvar_script_ptr` (L170), `gvar_state_ptr` (L171), `script_cur_ptr` (L172) |

## 0xFF50 — 5 distinct names across 3 chunks

Names: `gvar_credits_pos`, `gvar_frame_count`, `gvar_menu_step`, `gvar_timer_word`, `menu_frame_timer`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `gvar_frame_count` (L140) |
| `zelres2/code/250ENDMO.asm` | `gvar_credits_pos` (L93) |
| `zelres2/code/zr2com.inc` | `gvar_timer_word` (L181), `gvar_credits_pos` (L182), `gvar_menu_step` (L183), `menu_frame_timer` (L184) |

## 0xFF68 — 5 distinct names across 2 chunks

Names: `gvar_char_y_ofs`, `gvar_ff68`, `gvar_scroll_idx`, `gvar_text_ofs`, `menu_col_width`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/zr1com.inc` | `gvar_text_ofs` (L156), `gvar_char_y_ofs` (L157), `gvar_scroll_idx` (L158), `menu_col_width` (L159) |
| `zelres2/code/zr2com.inc` | `gvar_text_ofs` (L199), `menu_col_width` (L200), `gvar_ff68` (L201) |

## 0xFF6A — 5 distinct names across 5 chunks

Names: `gvar_copy_width`, `gvar_dlg_timer`, `gvar_tile_width`, `gvar_ui_delay`, `menu_row_count`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_dlg_timer` (L64) |
| `zelres1/code/zr1com.inc` | `gvar_dlg_timer` (L165), `gvar_copy_width` (L166), `gvar_tile_width` (L167) |
| `zelres2/code/212ARMRP.asm` | `gvar_dlg_timer` (L55) |
| `zelres2/code/215DRUGP.asm` | `menu_row_count` (L53) |
| `zelres2/code/217KENJP.asm` | `gvar_ui_delay` (L75) |

## 0xFF75 — 5 distinct names across 12 chunks

Names: `gvar_spawn_fx_flag`, `gvar_volume`, `gvar_volume_b`, `mao1_gvar_state_byte`, `mao2_gvar_phase_byte`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `gvar_volume_b` (L98) |
| `core/zeliard.inc` | `gvar_volume_b` (L126) |
| `zelres1/code/100OPDMO.asm` | `gvar_volume_b` (L49) |
| `zelres1/code/106TOWN.asm` | `gvar_volume` (L67) |
| `zelres2/code/200FIGHT.asm` | `gvar_volume_b` (L245) |
| `zelres2/code/201SELCT.asm` | `gvar_volume_b` (L51) |
| `zelres2/code/250ENDMO.asm` | `gvar_volume_b` (L94) |
| `zelres2/code/zr2com.inc` | `gvar_volume_b` (L208), `gvar_volume` (L209) |
| `zelres3/code/300ROKAD.asm` | `gvar_volume_b` (L125) |
| `zelres3/code/318MAO1.asm` | `mao1_gvar_state_byte` (L71) |
| `zelres3/code/319MAO2.asm` | `mao2_gvar_phase_byte` (L95) |
| `zelres3/code/zr3com.inc` | `gvar_spawn_fx_flag` (L36) |

## 0x0083 — 4 distinct names across 7 chunks

Names: `ANIM_83`, `player_accel`, `screen_position`, `town_town_player_col`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `screen_position` (L48), `player_accel` (L51) |
| `zelres1/code/100OPDMO.asm` | `ANIM_83` (L146) |
| `zelres1/code/106TOWN.asm` | `town_town_player_col` (L204) |
| `zelres1/code/zr1com.inc` | `screen_position` (L22) |
| `zelres2/code/250ENDMO.asm` | `ANIM_83` (L180) |
| `zelres2/code/zr2com.inc` | `screen_position` (L21) |
| `zelres3/code/zr3com.inc` | `screen_position` (L103) |

## 0x008D — 4 distinct names across 6 chunks

Names: `ANIM_8D`, `hero_level`, `item_qty_count`, `stat_X8D`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `hero_level` (L81), `item_qty_count` (L82), `stat_X8D` (L83) |
| `zelres1/code/100OPDMO.asm` | `ANIM_8D` (L156) |
| `zelres1/code/zr1com.inc` | `item_qty_count` (L30), `hero_level` (L201) |
| `zelres2/code/201SELCT.asm` | `item_qty_count` (L138) |
| `zelres2/code/zr2com.inc` | `item_qty_count` (L29), `hero_level` (L235) |
| `zelres3/code/zr3com.inc` | `hero_level` (L112) |

## 0x008E — 4 distinct names across 6 chunks

Names: `ANIM_8E`, `experience`, `item_effect_val`, `stat_X8E`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `experience` (L86), `item_effect_val` (L87), `stat_X8E` (L88) |
| `zelres1/code/100OPDMO.asm` | `ANIM_8E` (L157) |
| `zelres1/code/zr1com.inc` | `item_effect_val` (L31), `experience` (L202) |
| `zelres2/code/201SELCT.asm` | `item_effect_val` (L139) |
| `zelres2/code/zr2com.inc` | `item_effect_val` (L30), `experience` (L236) |
| `zelres3/code/zr3com.inc` | `experience` (L113) |

## 0x0098 — 4 distinct names across 7 chunks

Names: `ANIM_98`, `keys_normal`, `player_speed`, `stat_X98`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `keys_normal` (L128), `player_speed` (L129), `stat_X98` (L130) |
| `zelres1/code/100OPDMO.asm` | `ANIM_98` (L167) |
| `zelres1/code/zr1com.inc` | `player_speed` (L37), `keys_normal` (L203) |
| `zelres2/code/201SELCT.asm` | `player_speed` (L130) |
| `zelres2/code/250ENDMO.asm` | `ANIM_98` (L191) |
| `zelres2/code/zr2com.inc` | `player_speed` (L36), `keys_normal` (L237) |
| `zelres3/code/zr3com.inc` | `keys_normal` (L119) |

## 0x0099 — 4 distinct names across 6 chunks

Names: `ANIM_99`, `keys_lion`, `player_power`, `stat_X99`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `keys_lion` (L134), `player_power` (L135), `stat_X99` (L136) |
| `zelres1/code/100OPDMO.asm` | `ANIM_99` (L168) |
| `zelres1/code/zr1com.inc` | `player_power` (L38), `keys_lion` (L204) |
| `zelres2/code/201SELCT.asm` | `player_power` (L131) |
| `zelres2/code/zr2com.inc` | `player_power` (L37), `keys_lion` (L238) |
| `zelres3/code/zr3com.inc` | `keys_lion` (L120) |

## 0x009B — 4 distinct names across 5 chunks

Names: `ANIM_9B`, `crest_glory`, `player_ability_2`, `stat_X9B`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `crest_glory` (L166), `player_ability_2` (L167), `stat_X9B` (L168) |
| `zelres1/code/100OPDMO.asm` | `ANIM_9B` (L170) |
| `zelres1/code/zr1com.inc` | `crest_glory` (L42), `player_ability_2` (L43) |
| `zelres2/code/zr2com.inc` | `crest_glory` (L77), `player_ability_2` (L78) |
| `zelres3/code/zr3com.inc` | `crest_glory` (L122) |

## 0x009C — 4 distinct names across 5 chunks

Names: `ANIM_9C`, `crest_hero`, `player_ability_3`, `stat_X9C`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `crest_hero` (L169), `player_ability_3` (L170), `stat_X9C` (L171) |
| `zelres1/code/100OPDMO.asm` | `ANIM_9C` (L171) |
| `zelres1/code/zr1com.inc` | `crest_hero` (L44), `player_ability_3` (L45) |
| `zelres2/code/zr2com.inc` | `crest_hero` (L79), `player_ability_3` (L80) |
| `zelres3/code/zr3com.inc` | `crest_hero` (L123) |

## 0x009D — 4 distinct names across 7 chunks

Names: `ANIM_9D`, `cur_weapon_idx`, `selected_spell`, `weapon_tier_max`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `selected_spell` (L53), `weapon_tier_max` (L54), `cur_weapon_idx` (L55) |
| `drivers/stdply.inc` | `selected_spell` (L177), `weapon_tier_max` (L178), `cur_weapon_idx` (L179) |
| `zelres1/code/100OPDMO.asm` | `ANIM_9D` (L172) |
| `zelres1/code/zr1com.inc` | `selected_spell` (L47), `weapon_tier_max` (L48), `cur_weapon_idx` (L49) |
| `zelres2/code/201SELCT.asm` | `cur_weapon_idx` (L136) |
| `zelres2/code/zr2com.inc` | `selected_spell` (L41), `weapon_tier_max` (L42), `cur_weapon_idx` (L43) |
| `zelres3/code/zr3com.inc` | `selected_spell` (L124) |

## 0x009E — 4 distinct names across 6 chunks

Names: `ANIM_9E`, `cur_magic_idx`, `selected_accessory`, `stat_X9E`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `selected_accessory` (L186), `stat_X9E` (L187), `cur_magic_idx` (L188) |
| `zelres1/code/100OPDMO.asm` | `ANIM_9E` (L173) |
| `zelres1/code/zr1com.inc` | `selected_accessory` (L51), `stat_X9E` (L52), `cur_magic_idx` (L53) |
| `zelres2/code/201SELCT.asm` | `cur_magic_idx` (L137) |
| `zelres2/code/zr2com.inc` | `selected_accessory` (L45), `stat_X9E` (L46), `cur_magic_idx` (L47) |
| `zelres3/code/zr3com.inc` | `selected_accessory` (L125) |

## 0x00A1 — 4 distinct names across 6 chunks

Names: `ANIM_A1`, `accessory_slot_1`, `magic_flags`, `spell_slot_1`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `accessory_slot_1` (L223), `magic_flags` (L228), `spell_slot_1` (L229) |
| `zelres1/code/zr1com.inc` | `accessory_slot_1` (L206) |
| `zelres2/code/201SELCT.asm` | `magic_flags` (L121) |
| `zelres2/code/250ENDMO.asm` | `ANIM_A1` (L193) |
| `zelres2/code/zr2com.inc` | `accessory_slot_1` (L240) |
| `zelres3/code/zr3com.inc` | `accessory_slot_1` (L127) |

## 0x00A2 — 4 distinct names across 6 chunks

Names: `ANIM_A2`, `SCR_ATTR_RST2`, `accessory_slot_2`, `spell_slot_2`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `accessory_slot_2` (L224), `spell_slot_2` (L230) |
| `zelres1/code/100OPDMO.asm` | `SCR_ATTR_RST2` (L197) |
| `zelres1/code/zr1com.inc` | `accessory_slot_2` (L207) |
| `zelres2/code/250ENDMO.asm` | `ANIM_A2` (L194) |
| `zelres2/code/zr2com.inc` | `accessory_slot_2` (L241) |
| `zelres3/code/zr3com.inc` | `accessory_slot_2` (L128) |

## 0x0140 — 4 distinct names across 5 chunks

Names: `ega_row_stride`, `ega_row_w`, `vga_row_stride`, `vga_stride`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmmcga.asm` | `vga_stride` (L74) |
| `zelres1/code/105GDMCA.asm` | `vga_row_stride` (L68) |
| `zelres1/code/111GTMCA.asm` | `vga_stride` (L74) |
| `zelres1/code/zr1com.inc` | `ega_row_w` (L183) |
| `zelres2/code/202GFEGA.asm` | `ega_row_stride` (L85) |

## 0x046C — 4 distinct names across 4 chunks

Names: `ega_hud_ofs`, `ega_hud_top`, `hud_ofs`, `rle_src_46c`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmega.asm` | `ega_hud_ofs` (L71) |
| `zelres1/code/107GTEGA.asm` | `ega_hud_top` (L55) |
| `zelres2/code/202GFEGA.asm` | `hud_ofs` (L87) |
| `zelres2/code/209CKPD.asm` | `rle_src_46c` (L111) |

## 0x29DC — 4 distinct names across 4 chunks

Names: `cga_plane2_buf`, `cga_plane3_buf`, `ega_plane3_buf`, `hgc_plane3_buf`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/102GDCGA.asm` | `cga_plane3_buf` (L48) |
| `zelres1/code/103GDHGC.asm` | `hgc_plane3_buf` (L48) |
| `zelres1/code/104GDTGA.asm` | `cga_plane2_buf` (L44) |
| `zelres1/code/105GDMCA.asm` | `ega_plane3_buf` (L46) |

## 0x3000 — 4 distinct names across 4 chunks

Names: `drv_fn2_init`, `gfx_plane_b`, `level_seg_ofs`, `loaded_code_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `loaded_code_a` (L122) |
| `drivers/gmcga.asm` | `level_seg_ofs` (L83) |
| `zelres1/code/100OPDMO.asm` | `gfx_plane_b` (L66) |
| `zelres2/code/217KENJP.asm` | `drv_fn2_init` (L88) |

## 0x3006 — 4 distinct names across 4 chunks

Names: `gfx_mode_fn`, `gfx_scroll_left_fn`, `gfx_update_fn`, `loaded_gfx_dispatch_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/100OPDMO.asm` | `gfx_mode_fn` (L58) |
| `zelres1/code/106TOWN.asm` | `gfx_scroll_left_fn` (L108) |
| `zelres2/code/211OMOYP.asm` | `loaded_gfx_dispatch_fn` (L67) |
| `zelres2/code/250ENDMO.asm` | `gfx_update_fn` (L111) |

## 0x3E80 — 4 distinct names across 2 chunks

Names: `sprite_tmp2`, `sprite_tmp_buf`, `tile_buf_a`, `tile_disp_tbl`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/107GTEGA.asm` | `tile_disp_tbl` (L54), `tile_buf_a` (L64) |
| `zelres2/code/202GFEGA.asm` | `sprite_tmp_buf` (L68), `sprite_tmp2` (L90) |

## 0x4100 — 4 distinct names across 4 chunks

Names: `tile_alt_base`, `tile_src_b`, `tileset_base`, `town_base_4100`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `town_base_4100` (L82) |
| `zelres1/code/109GTHGC.asm` | `tile_alt_base` (L48) |
| `zelres1/code/111GTMCA.asm` | `tileset_base` (L66) |
| `zelres1/code/zr1com.inc` | `tile_src_b` (L188) |

## 0x6333 — 4 distinct names across 4 chunks

Names: `cga_sprite_base`, `hgc_src_base2`, `mca_sprite_src`, `scroll_tile_src`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `scroll_tile_src` (L392) |
| `zelres2/code/203GFCGA.asm` | `cga_sprite_base` (L48) |
| `zelres2/code/204GFHGC.asm` | `hgc_src_base2` (L51) |
| `zelres2/code/206GFMCA.asm` | `mca_sprite_src` (L70) |

## 0xA058 — 4 distinct names across 3 chunks

Names: `hgc_bank2_wrap_w`, `hgc_stride_a`, `hgc_stride_c`, `hgc_wrap_add_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/103GDHGC.asm` | `hgc_bank2_wrap_w` (L76) |
| `zelres1/code/109GTHGC.asm` | `hgc_stride_a` (L77), `hgc_stride_c` (L85) |
| `zelres2/code/204GFHGC.asm` | `hgc_wrap_add_a` (L85) |

## 0xC00F — 4 distinct names across 4 chunks

Names: `entity_tbl_ptr`, `npc_obj_list`, `scroll_entry_ptr`, `tile_list_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `npc_obj_list` (L169) |
| `zelres1/code/108GTCGA.asm` | `entity_tbl_ptr` (L72) |
| `zelres1/code/111GTMCA.asm` | `scroll_entry_ptr` (L69) |
| `zelres1/code/zr1com.inc` | `tile_list_ptr` (L172) |

## 0xE000 — 4 distinct names across 4 chunks

Names: `cursor_buf`, `gvar_save_buf`, `pattern_base`, `scroll_buf`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `cursor_buf` (L173) |
| `zelres2/code/200FIGHT.asm` | `scroll_buf` (L367) |
| `zelres2/code/217KENJP.asm` | `gvar_save_buf` (L68) |
| `zelres2/code/zr2com.inc` | `pattern_base` (L217) |

## 0xFF1D — 4 distinct names across 7 chunks

Names: `gvar_key_flag`, `gvar_script_skip`, `gvar_spacebar_state`, `gvar_state_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `gvar_spacebar_state` (L68), `gvar_state_a` (L69) |
| `core/zeliard.inc` | `gvar_spacebar_state` (L86), `gvar_state_a` (L87) |
| `zelres1/code/100OPDMO.asm` | `gvar_spacebar_state` (L43) |
| `zelres1/code/106TOWN.asm` | `gvar_spacebar_state` (L47) |
| `zelres2/code/200FIGHT.asm` | `gvar_spacebar_state` (L76) |
| `zelres2/code/211OMOYP.asm` | `gvar_script_skip` (L60) |
| `zelres2/code/217KENJP.asm` | `gvar_key_flag` (L70) |

## 0xFF24 — 4 distinct names across 4 chunks

Names: `gvar_display_mode`, `gvar_scene_mode`, `gvar_state_FF24`, `gvar_state_flag`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/zr1com.inc` | `gvar_scene_mode` (L138), `gvar_state_flag` (L139) |
| `zelres2/code/200FIGHT.asm` | `gvar_scene_mode` (L82), `gvar_state_FF24` (L83) |
| `zelres2/code/201SELCT.asm` | `gvar_scene_mode` (L52), `gvar_display_mode` (L53) |
| `zelres2/code/zr2com.inc` | `gvar_scene_mode` (L142) |

## 0xFF2E — 4 distinct names across 4 chunks

Names: `gvar_death_flag`, `gvar_flag_FF2E`, `gvar_rng_state`, `mao2_gvar_state_b`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `gvar_death_flag` (L95), `gvar_flag_FF2E` (L96) |
| `zelres3/code/301EAI1.asm` | `gvar_rng_state` (L109) |
| `zelres3/code/319MAO2.asm` | `mao2_gvar_state_b` (L92) |
| `zelres3/code/zr3com.inc` | `gvar_death_flag` (L25) |

## 0xFF2F — 4 distinct names across 4 chunks

Names: `flag_shadow`, `gvar_dir_toggle`, `gvar_flag_FF2F`, `mao2_gvar_state_c`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `gvar_dir_toggle` (L106), `gvar_flag_FF2F` (L107) |
| `zelres2/code/zr2com.inc` | `flag_shadow` (L145) |
| `zelres3/code/319MAO2.asm` | `mao2_gvar_state_c` (L93) |
| `zelres3/code/zr3com.inc` | `gvar_dir_toggle` (L26) |

## 0xFF35 — 4 distinct names across 6 chunks

Names: `enemy_counter`, `gvar_frame_cnt`, `gvar_hero_x`, `gvar_save_flag_2`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `enemy_counter` (L129), `gvar_save_flag_2` (L130) |
| `zelres2/code/zr2com.inc` | `enemy_counter` (L154) |
| `zelres3/code/306EAI6.asm` | `gvar_hero_x` (L102) |
| `zelres3/code/307EAI7.asm` | `gvar_hero_x` (L111) |
| `zelres3/code/308EAI8.asm` | `gvar_hero_x` (L108) |
| `zelres3/code/zr3com.inc` | `gvar_frame_cnt` (L28) |

## 0xFF4E — 4 distinct names across 2 chunks

Names: `gvar_init_flag_a`, `gvar_state_flg1`, `gvar_text_x`, `shop_flag_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_text_x` (L56) |
| `zelres2/code/zr2com.inc` | `gvar_text_x` (L173), `gvar_init_flag_a` (L174), `gvar_state_flg1` (L175), `shop_flag_a` (L176) |

## 0xFF4F — 4 distinct names across 2 chunks

Names: `gvar_init_flag_b`, `gvar_state_flg2`, `gvar_text_y`, `shop_flag_b`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_text_y` (L57) |
| `zelres2/code/zr2com.inc` | `gvar_text_y` (L177), `gvar_init_flag_b` (L178), `gvar_state_flg2` (L179), `shop_flag_b` (L180) |

## 0xFF52 — 4 distinct names across 2 chunks

Names: `gvar_col_byte`, `gvar_dlg_cols`, `gvar_name_maxlen`, `menu_item_count`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_dlg_cols` (L58) |
| `zelres2/code/zr2com.inc` | `gvar_dlg_cols` (L185), `gvar_col_byte` (L186), `gvar_name_maxlen` (L187), `menu_item_count` (L188) |

## 0xFF53 — 4 distinct names across 2 chunks

Names: `gvar_dlg_rows`, `gvar_name_opt`, `gvar_row_byte`, `inventory_count`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_dlg_rows` (L59) |
| `zelres2/code/zr2com.inc` | `gvar_dlg_rows` (L189), `gvar_name_opt` (L190), `gvar_row_byte` (L191), `inventory_count` (L192) |

## 0xFF54 — 4 distinct names across 2 chunks

Names: `gvar_dlg_pos`, `gvar_ui_dst_word`, `gvar_ui_pos`, `menu_pos_base`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_dlg_pos` (L60) |
| `zelres2/code/zr2com.inc` | `gvar_dlg_pos` (L193), `gvar_ui_dst_word` (L194), `gvar_ui_pos` (L195), `menu_pos_base` (L196) |

## 0x0081 — 3 distinct names across 4 chunks

Names: `ANIM_81`, `PSP_cmd_line`, `stat_X81`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `PSP_cmd_line` (L114) |
| `drivers/stdply.inc` | `stat_X81` (L33) |
| `zelres1/code/100OPDMO.asm` | `ANIM_81` (L144) |
| `zelres2/code/250ENDMO.asm` | `ANIM_81` (L178) |

## 0x0082 — 3 distinct names across 6 chunks

Names: `ANIM_82`, `map_scroll_row`, `stat_X82`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `map_scroll_row` (L34), `stat_X82` (L35) |
| `zelres1/code/100OPDMO.asm` | `ANIM_82` (L145) |
| `zelres1/code/zr1com.inc` | `map_scroll_row` (L21) |
| `zelres2/code/250ENDMO.asm` | `ANIM_82` (L179) |
| `zelres2/code/zr2com.inc` | `map_scroll_row` (L20) |
| `zelres3/code/zr3com.inc` | `map_scroll_row` (L102) |

## 0x0084 — 3 distinct names across 6 chunks

Names: `ANIM_84`, `fight_player_col`, `stat_X84`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `fight_player_col` (L49), `stat_X84` (L50) |
| `zelres1/code/100OPDMO.asm` | `ANIM_84` (L147) |
| `zelres1/code/zr1com.inc` | `fight_player_col` (L23) |
| `zelres2/code/250ENDMO.asm` | `ANIM_84` (L181) |
| `zelres2/code/zr2com.inc` | `fight_player_col` (L22) |
| `zelres3/code/zr3com.inc` | `fight_player_col` (L104) |

## 0x0088 — 3 distinct names across 5 chunks

Names: `ANIM_88`, `gold_in_bank_x65536`, `stat_X88_hi`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `gold_in_bank_x65536` (L68), `stat_X88_hi` (L70) |
| `zelres1/code/100OPDMO.asm` | `ANIM_88` (L151) |
| `zelres1/code/zr1com.inc` | `gold_in_bank_x65536` (L27) |
| `zelres2/code/zr2com.inc` | `gold_in_bank_x65536` (L26) |
| `zelres3/code/zr3com.inc` | `gold_in_bank_x65536` (L108) |

## 0x0089 — 3 distinct names across 5 chunks

Names: `ANIM_89`, `gold_in_bank_x1`, `stat_X88_lo`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `gold_in_bank_x1` (L69), `stat_X88_lo` (L71) |
| `zelres1/code/100OPDMO.asm` | `ANIM_89` (L152) |
| `zelres1/code/zr1com.inc` | `gold_in_bank_x1` (L28) |
| `zelres2/code/zr2com.inc` | `gold_in_bank_x1` (L27) |
| `zelres3/code/zr3com.inc` | `gold_in_bank_x1` (L109) |

## 0x0096 — 3 distinct names across 7 chunks

Names: `ANIM_96`, `shield_max_HP`, `stat_X96`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `shield_max_HP` (L124), `stat_X96` (L125) |
| `zelres1/code/100OPDMO.asm` | `ANIM_96` (L165) |
| `zelres1/code/zr1com.inc` | `shield_max_HP` (L36) |
| `zelres2/code/201SELCT.asm` | `shield_max_HP` (L129) |
| `zelres2/code/250ENDMO.asm` | `ANIM_96` (L189) |
| `zelres2/code/zr2com.inc` | `shield_max_HP` (L35) |
| `zelres3/code/zr3com.inc` | `shield_max_HP` (L118) |

## 0x00A3 — 3 distinct names across 5 chunks

Names: `ANIM_A3`, `accessory_slot_3`, `spell_slot_3`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `accessory_slot_3` (L225), `spell_slot_3` (L231) |
| `zelres1/code/zr1com.inc` | `accessory_slot_3` (L208) |
| `zelres2/code/250ENDMO.asm` | `ANIM_A3` (L195) |
| `zelres2/code/zr2com.inc` | `accessory_slot_3` (L242) |
| `zelres3/code/zr3com.inc` | `accessory_slot_3` (L129) |

## 0x00A4 — 3 distinct names across 5 chunks

Names: `ANIM_A4`, `accessory_slot_4`, `spell_slot_4`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `accessory_slot_4` (L226), `spell_slot_4` (L232) |
| `zelres1/code/zr1com.inc` | `accessory_slot_4` (L209) |
| `zelres2/code/250ENDMO.asm` | `ANIM_A4` (L196) |
| `zelres2/code/zr2com.inc` | `accessory_slot_4` (L243) |
| `zelres3/code/zr3com.inc` | `accessory_slot_4` (L130) |

## 0x00A5 — 3 distinct names across 5 chunks

Names: `ANIM_A5`, `accessory_slot_5`, `spell_slot_5`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `accessory_slot_5` (L227), `spell_slot_5` (L233) |
| `zelres1/code/zr1com.inc` | `accessory_slot_5` (L210) |
| `zelres2/code/250ENDMO.asm` | `ANIM_A5` (L197) |
| `zelres2/code/zr2com.inc` | `accessory_slot_5` (L244) |
| `zelres3/code/zr3com.inc` | `accessory_slot_5` (L131) |

## 0x00AB — 3 distinct names across 4 chunks

Names: `drv_color_lut`, `spell_charge_espada`, `weap_dur_cur`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_charge_espada` (L256), `drv_color_lut` (L492), `weap_dur_cur` (L493) |
| `zelres1/code/zr1com.inc` | `weap_dur_cur` (L55) |
| `zelres2/code/201SELCT.asm` | `weap_dur_cur` (L133) |
| `zelres2/code/zr2com.inc` | `weap_dur_cur` (L38) |

## 0x00B4 — 3 distinct names across 5 chunks

Names: `ANIM_B4`, `spell_charge_max_espada`, `weap_dur_max`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_charge_max_espada` (L271), `weap_dur_max` (L278) |
| `zelres1/code/zr1com.inc` | `weap_dur_max` (L57) |
| `zelres2/code/201SELCT.asm` | `weap_dur_max` (L134) |
| `zelres2/code/250ENDMO.asm` | `ANIM_B4` (L202) |
| `zelres2/code/zr2com.inc` | `weap_dur_max` (L39) |

## 0x00BB — 3 distinct names across 2 chunks

Names: `boss_kill_cangrejo`, `spell_known_espada`, `weapon_flags`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_known_espada` (L304), `boss_kill_cangrejo` (L317) |
| `zelres2/code/201SELCT.asm` | `weapon_flags` (L123) |

## 0x00C0 — 3 distinct names across 2 chunks

Names: `ANIM_C0`, `boss_kill_tarso`, `spell_known_agua`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_known_agua` (L309), `boss_kill_tarso` (L322) |
| `zelres2/code/250ENDMO.asm` | `ANIM_C0` (L207) |

## 0x00C1 — 3 distinct names across 2 chunks

Names: `ANIM_C1`, `boss_kill_dragon`, `spell_known_guerra`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_known_guerra` (L310), `boss_kill_dragon` (L323) |
| `zelres2/code/250ENDMO.asm` | `ANIM_C1` (L208) |

## 0x00C4 — 3 distinct names across 5 chunks

Names: `current_area_id`, `player_level`, `save_sage`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `current_area_id` (L56), `player_level` (L57) |
| `drivers/stdply.inc` | `save_sage` (L338), `current_area_id` (L339), `player_level` (L340) |
| `zelres1/code/zr1com.inc` | `current_area_id` (L60), `player_level` (L61), `save_sage` (L212) |
| `zelres2/code/zr2com.inc` | `current_area_id` (L50), `player_level` (L51), `save_sage` (L246) |
| `zelres3/code/zr3com.inc` | `save_sage` (L136) |

## 0x00C8 — 3 distinct names across 5 chunks

Names: `current_level_idx`, `player_tileset`, `stat_XC8`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `player_tileset` (L58) |
| `drivers/stdply.inc` | `current_level_idx` (L357), `player_tileset` (L358), `stat_XC8` (L359) |
| `zelres1/code/zr1com.inc` | `player_tileset` (L63), `current_level_idx` (L214) |
| `zelres2/code/zr2com.inc` | `player_tileset` (L53), `current_level_idx` (L248) |
| `zelres3/code/zr3com.inc` | `current_level_idx` (L139) |

## 0x0100 — 3 distinct names across 2 chunks

Names: `ISR_STUBS_BASE`, `isr_keyboard`, `stick_input_fn_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `stick_input_fn_ofs` (L107) |
| `core/zeliard.inc` | `ISR_STUBS_BASE` (L145), `isr_keyboard` (L146) |

## 0x11B0 — 3 distinct names across 4 chunks

Names: `cga_src_11b0`, `hud_vga_ofs`, `mca_vga_base_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmmcga.asm` | `hud_vga_ofs` (L78) |
| `zelres1/code/111GTMCA.asm` | `hud_vga_ofs` (L75) |
| `zelres2/code/206GFMCA.asm` | `mca_vga_base_ofs` (L101) |
| `zelres2/code/209CKPD.asm` | `cga_src_11b0` (L113) |

## 0x163C — 3 distinct names across 3 chunks

Names: `cga_ground_dst`, `cga_tilemap_b0`, `vga_dst_163c`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/108GTCGA.asm` | `cga_tilemap_b0` (L79) |
| `zelres2/code/208YMPD.asm` | `cga_ground_dst` (L92) |
| `zelres2/code/209CKPD.asm` | `vga_dst_163c` (L117) |

## 0x2004 — 3 distinct names across 4 chunks

Names: `drv_fn_2`, `gfx_draw_tile_fn`, `gfx_set_color_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_draw_tile_fn` (L87) |
| `zelres1/code/zr1com.inc` | `drv_fn_2` (L91) |
| `zelres2/code/212ARMRP.asm` | `gfx_set_color_fn` (L61) |
| `zelres2/code/zr2com.inc` | `drv_fn_2` (L93) |

## 0x2006 — 3 distinct names across 4 chunks

Names: `drv_fn_3`, `drv_fn_palette_a`, `gfx_render_a_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_render_a_fn` (L88) |
| `zelres1/code/zr1com.inc` | `drv_fn_3` (L92) |
| `zelres2/code/217KENJP.asm` | `drv_fn_palette_a` (L82) |
| `zelres2/code/zr2com.inc` | `drv_fn_3` (L94) |

## 0x2014 — 3 distinct names across 4 chunks

Names: `bank_drv_2014`, `drv_fn_10`, `gfx_render_c_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_render_c_fn` (L93) |
| `zelres1/code/zr1com.inc` | `drv_fn_10` (L99) |
| `zelres2/code/213BANKP.asm` | `bank_drv_2014` (L63) |
| `zelres2/code/zr2com.inc` | `drv_fn_10` (L101) |

## 0x201A — 3 distinct names across 5 chunks

Names: `drv_fn_13`, `gfx_draw_icon_b_fn`, `gfx_present_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_draw_icon_b_fn` (L96) |
| `zelres1/code/zr1com.inc` | `drv_fn_13` (L102) |
| `zelres2/code/201SELCT.asm` | `drv_fn_13` (L58) |
| `zelres2/code/212ARMRP.asm` | `gfx_present_fn` (L62) |
| `zelres2/code/zr2com.inc` | `drv_fn_13` (L104) |

## 0x201C — 3 distinct names across 5 chunks

Names: `drv_fn_14`, `gfx_call_a`, `gfx_render_scene_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gfx_call_a` (L118) |
| `zelres1/code/zr1com.inc` | `drv_fn_14` (L103) |
| `zelres2/code/201SELCT.asm` | `drv_fn_14` (L59) |
| `zelres2/code/212ARMRP.asm` | `gfx_render_scene_fn` (L63) |
| `zelres2/code/zr2com.inc` | `drv_fn_14` (L105) |

## 0x2020 — 3 distinct names across 3 chunks

Names: `drv_fn_16`, `gfx_call_c`, `gfx_draw_hud_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gfx_call_c` (L120) |
| `zelres2/code/201SELCT.asm` | `drv_fn_16` (L61) |
| `zelres2/code/212ARMRP.asm` | `gfx_draw_hud_fn` (L64) |

## 0x2050 — 3 distinct names across 3 chunks

Names: `cga_plane2_buf`, `ega_plane2_buf`, `hgc_plane2_buf`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/101GDEGA.asm` | `ega_plane2_buf` (L41) |
| `zelres1/code/102GDCGA.asm` | `cga_plane2_buf` (L47) |
| `zelres1/code/103GDHGC.asm` | `hgc_plane2_buf` (L47) |

## 0x2A80 — 3 distinct names across 2 chunks

Names: `cga_plane_stride`, `ega_plane_stride`, `hgc_plane_stride`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/103GDHGC.asm` | `hgc_plane_stride` (L49) |
| `zelres1/code/zr1com.inc` | `cga_plane_stride` (L124), `ega_plane_stride` (L125) |

## 0x2C6C — 3 distinct names across 3 chunks

Names: `cga_dst_2c6c`, `ega_ground_dst_0`, `scroll_left_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/107GTEGA.asm` | `scroll_left_a` (L59) |
| `zelres2/code/208YMPD.asm` | `ega_ground_dst_0` (L90) |
| `zelres2/code/209CKPD.asm` | `cga_dst_2c6c` (L115) |

## 0x3004 — 3 distinct names across 4 chunks

Names: `drv2_fn_2`, `gfx_draw_fn`, `gfx_update_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/100OPDMO.asm` | `gfx_update_fn` (L57) |
| `zelres1/code/106TOWN.asm` | `gfx_update_fn` (L107) |
| `zelres2/code/250ENDMO.asm` | `gfx_draw_fn` (L110) |
| `zelres2/code/zr2com.inc` | `drv2_fn_2` (L121) |

## 0x3008 — 3 distinct names across 3 chunks

Names: `drv2_fn_4`, `gfx_palette_fn`, `gfx_scroll_right_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/100OPDMO.asm` | `gfx_palette_fn` (L59) |
| `zelres1/code/106TOWN.asm` | `gfx_scroll_right_fn` (L109) |
| `zelres2/code/250ENDMO.asm` | `drv2_fn_4` (L102), `gfx_palette_fn` (L112) |

## 0x3010 — 3 distinct names across 2 chunks

Names: `drv2_fn_8`, `gfx_blit_fn`, `gfx_npc_update_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_npc_update_fn` (L113) |
| `zelres2/code/250ENDMO.asm` | `drv2_fn_8` (L103), `gfx_blit_fn` (L113) |

## 0x301C — 3 distinct names across 3 chunks

Names: `drv_draw_string`, `drv_fn2_text_render`, `gfx_sel_draw_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_sel_draw_fn` (L118) |
| `zelres2/code/213BANKP.asm` | `drv_draw_string` (L57) |
| `zelres2/code/217KENJP.asm` | `drv_fn2_text_render` (L90) |

## 0x301E — 3 distinct names across 3 chunks

Names: `drv2_fn_15`, `drv_fn2_cursor_draw`, `gfx_sel_scroll_up_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_sel_scroll_up_fn` (L119) |
| `zelres2/code/217KENJP.asm` | `drv_fn2_cursor_draw` (L91) |
| `zelres2/code/zr2com.inc` | `drv2_fn_15` (L123) |

## 0x3020 — 3 distinct names across 3 chunks

Names: `drv_fn2_cursor_clear`, `gfx_scene_fn1`, `gfx_sel_scroll_dn_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_sel_scroll_dn_fn` (L120) |
| `zelres2/code/217KENJP.asm` | `drv_fn2_cursor_clear` (L92) |
| `zelres2/code/250ENDMO.asm` | `gfx_scene_fn1` (L114) |

## 0x3022 — 3 distinct names across 3 chunks

Names: `drv_set_text_pos`, `gfx_scene_fn2`, `gfx_sprite_plot`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/213BANKP.asm` | `drv_set_text_pos` (L58) |
| `zelres2/code/250ENDMO.asm` | `gfx_scene_fn2` (L115) |
| `zelres3/code/300ROKAD.asm` | `gfx_sprite_plot` (L110) |

## 0x3024 — 3 distinct names across 3 chunks

Names: `gfx_palette_fn`, `gfx_ret_fn`, `gfx_scene_fn3`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_ret_fn` (L121) |
| `zelres2/code/250ENDMO.asm` | `gfx_scene_fn3` (L116) |
| `zelres3/code/300ROKAD.asm` | `gfx_palette_fn` (L111) |

## 0x3028 — 3 distinct names across 3 chunks

Names: `drv2_fn_20`, `gfx_decode_fn`, `gfx_sprite_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/250ENDMO.asm` | `gfx_sprite_fn` (L117) |
| `zelres2/code/zr2com.inc` | `drv2_fn_20` (L124) |
| `zelres3/code/300ROKAD.asm` | `gfx_decode_fn` (L113) |

## 0x41F8 — 3 distinct names across 4 chunks

Names: `tga_hud_ofs`, `tga_vram_buf`, `vga_dst_41f8`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmtga.asm` | `tga_hud_ofs` (L75) |
| `zelres1/code/110GTTGA.asm` | `tga_hud_ofs` (L67) |
| `zelres2/code/205GFTGA.asm` | `tga_vram_buf` (L73) |
| `zelres2/code/209CKPD.asm` | `vga_dst_41f8` (L118) |

## 0x5FA6 — 3 distinct names across 2 chunks

Names: `hgc_bank1_end_m1`, `hgc_bank_back`, `hgc_wrap_back`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/103GDHGC.asm` | `hgc_bank1_end_m1` (L67) |
| `zelres1/code/109GTHGC.asm` | `hgc_wrap_back` (L74), `hgc_bank_back` (L82) |

## 0x600E — 3 distinct names across 3 chunks

Names: `fight_cb_map_back`, `menu_init_fn`, `show_menu_items`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/212ARMRP.asm` | `menu_init_fn` (L65) |
| `zelres2/code/213BANKP.asm` | `show_menu_items` (L64) |
| `zelres3/code/zr3com.inc` | `fight_cb_map_back` (L72) |

## 0x6010 — 3 distinct names across 3 chunks

Names: `fight_cb_step_pos`, `menu_nav_fn`, `menu_show_list`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/212ARMRP.asm` | `menu_nav_fn` (L66) |
| `zelres2/code/215DRUGP.asm` | `menu_show_list` (L58) |
| `zelres3/code/zr3com.inc` | `fight_cb_step_pos` (L73) |

## 0x6012 — 3 distinct names across 3 chunks

Names: `fight_cb_step_pos_2`, `menu_init`, `menu_render_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/212ARMRP.asm` | `menu_render_fn` (L67) |
| `zelres2/code/215DRUGP.asm` | `menu_init` (L59) |
| `zelres3/code/zr3com.inc` | `fight_cb_step_pos_2` (L74) |

## 0x6014 — 3 distinct names across 3 chunks

Names: `fight_cb_blocked`, `save_draw_fn`, `script_fn_menu_init`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `save_draw_fn` (L75) |
| `zelres2/code/217KENJP.asm` | `script_fn_menu_init` (L99) |
| `zelres3/code/zr3com.inc` | `fight_cb_blocked` (L75) |

## 0x6016 — 3 distinct names across 3 chunks

Names: `fight_cb_dist_check`, `omoyp_script_6016`, `script_fn_menu_poll`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/211OMOYP.asm` | `omoyp_script_6016` (L66) |
| `zelres2/code/217KENJP.asm` | `script_fn_menu_poll` (L100) |
| `zelres3/code/zr3com.inc` | `fight_cb_dist_check` (L76) |

## 0x6018 — 3 distinct names across 3 chunks

Names: `fight_cb_aux_18`, `save_scroll_up_fn`, `script_fn_menu_up`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `save_scroll_up_fn` (L76) |
| `zelres2/code/217KENJP.asm` | `script_fn_menu_up` (L101) |
| `zelres3/code/zr3com.inc` | `fight_cb_aux_18` (L77) |

## 0x601A — 3 distinct names across 3 chunks

Names: `fight_cb_aux_1a`, `save_scroll_dn_fn`, `script_fn_menu_dn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `save_scroll_dn_fn` (L77) |
| `zelres2/code/217KENJP.asm` | `script_fn_menu_dn` (L102) |
| `zelres3/code/zr3com.inc` | `fight_cb_aux_1a` (L78) |

## 0x8004 — 3 distinct names across 3 chunks

Names: `map_overlay_ptr`, `tile_subst_tbl_ptr`, `tileset_buf_b`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/108GTCGA.asm` | `tile_subst_tbl_ptr` (L44) |
| `zelres1/code/111GTMCA.asm` | `map_overlay_ptr` (L46) |
| `zelres1/code/zr1com.inc` | `tileset_buf_b` (L192) |

## 0x8100 — 3 distinct names across 3 chunks

Names: `tile_pixel_base`, `tile_pixels`, `tile_src_base`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/108GTCGA.asm` | `tile_pixels` (L45) |
| `zelres1/code/111GTMCA.asm` | `tile_src_base` (L47) |
| `zelres1/code/zr1com.inc` | `tile_pixel_base` (L193) |

## 0xA030 — 3 distinct names across 3 chunks

Names: `sprite_src_b`, `sprite_src_base`, `sprite_src_base_ds`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/203GFCGA.asm` | `sprite_src_base_ds` (L77) |
| `zelres2/code/206GFMCA.asm` | `sprite_src_base` (L97) |
| `zelres2/code/zr2com.inc` | `sprite_src_b` (L226) |

## 0xA4EA — 3 distinct names across 3 chunks

Names: `enemy_spawn_tile_lo`, `tori_tbl_a`, `zela_xlat_tbl`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/303EAI3.asm` | `tori_tbl_a` (L75) |
| `zelres3/code/306EAI6.asm` | `enemy_spawn_tile_lo` (L110) |
| `zelres3/code/312ZELA.asm` | `zela_xlat_tbl` (L67) |

## 0xA606 — 3 distinct names across 3 chunks

Names: `meda_tile_src_b`, `zel2_render_attr_a`, `zela_phase_active`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/312ZELA.asm` | `zela_phase_active` (L85) |
| `zelres3/code/313MEDA.asm` | `meda_tile_src_b` (L51) |
| `zelres3/code/315ZEL2.asm` | `zel2_render_attr_a` (L91) |

## 0xB800 — 3 distinct names across 4 chunks

Names: `cga_seg`, `cga_text_seg`, `tga_vram_seg`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmcga.asm` | `cga_seg` (L79) |
| `zelres1/code/100OPDMO.asm` | `cga_text_seg` (L114) |
| `zelres1/code/104GDTGA.asm` | `tga_vram_seg` (L64) |
| `zelres2/code/203GFCGA.asm` | `cga_seg` (L83) |

## 0xBB23 — 3 distinct names across 3 chunks

Names: `ega_plot_tbl_b`, `hgc_reg_a`, `state_name_box_y`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmega.asm` | `ega_plot_tbl_b` (L59) |
| `drivers/gmhgc.asm` | `hgc_reg_a` (L97) |
| `zelres2/code/217KENJP.asm` | `state_name_box_y` (L132) |

## 0xE005 — 3 distinct names across 3 chunks

Names: `hud_status_ptr`, `marker_buf`, `npc_flag_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/108GTCGA.asm` | `hud_status_ptr` (L74) |
| `zelres1/code/111GTMCA.asm` | `npc_flag_ptr` (L70) |
| `zelres1/code/zr1com.inc` | `marker_buf` (L173) |

## 0xF502 — 3 distinct names across 10 chunks

Names: `font_data_tbl`, `font_ptr_a`, `font_ptr_b`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmcga.asm` | `font_ptr_b` (L75) |
| `drivers/gmega.asm` | `font_ptr_b` (L65) |
| `drivers/gmhgc.asm` | `font_ptr_b` (L99) |
| `drivers/gmmcga.asm` | `font_ptr_b` (L72) |
| `drivers/gmtga.asm` | `font_ptr_b` (L73) |
| `zelres1/code/107GTEGA.asm` | `font_ptr_a` (L41) |
| `zelres1/code/108GTCGA.asm` | `font_ptr_a` (L42), `font_data_tbl` (L75) |
| `zelres1/code/109GTHGC.asm` | `font_ptr_a` (L46) |
| `zelres1/code/110GTTGA.asm` | `font_ptr_a` (L41) |
| `zelres1/code/111GTMCA.asm` | `font_ptr_a` (L43), `font_ptr_b` (L71) |

## 0xF504 — 3 distinct names across 10 chunks

Names: `font_char_data`, `font_ptr_b`, `font_ptr_c`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmcga.asm` | `font_ptr_c` (L76) |
| `drivers/gmega.asm` | `font_ptr_c` (L66) |
| `drivers/gmhgc.asm` | `font_ptr_c` (L100) |
| `drivers/gmmcga.asm` | `font_ptr_c` (L73) |
| `drivers/gmtga.asm` | `font_ptr_c` (L74) |
| `zelres1/code/107GTEGA.asm` | `font_ptr_b` (L42) |
| `zelres1/code/108GTCGA.asm` | `font_ptr_b` (L43), `font_char_data` (L76) |
| `zelres1/code/109GTHGC.asm` | `font_ptr_b` (L47) |
| `zelres1/code/110GTTGA.asm` | `font_ptr_b` (L42) |
| `zelres1/code/111GTMCA.asm` | `font_ptr_c` (L72) |

## 0xFA00 — 3 distinct names across 2 chunks

Names: `mca_temp_buf`, `mca_temp_buf_a`, `tile_offscr_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/111GTMCA.asm` | `tile_offscr_a` (L86) |
| `zelres2/code/206GFMCA.asm` | `mca_temp_buf` (L98), `mca_temp_buf_a` (L102) |

## 0xFF18 — 3 distinct names across 6 chunks

Names: `gvar_joy_state`, `gvar_timer_counter`, `kenjp_timer_ff18`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `gvar_timer_counter` (L67) |
| `core/zeliard.inc` | `gvar_timer_counter` (L85) |
| `zelres1/code/106TOWN.asm` | `gvar_joy_state` (L45) |
| `zelres2/code/200FIGHT.asm` | `gvar_timer_counter` (L74) |
| `zelres2/code/201SELCT.asm` | `gvar_timer_counter` (L48) |
| `zelres2/code/217KENJP.asm` | `kenjp_timer_ff18` (L148) |

## 0xFF1E — 3 distinct names across 5 chunks

Names: `gvar_enter_flag`, `gvar_skip_flag2`, `gvar_state_b`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `gvar_state_b` (L70) |
| `core/zeliard.inc` | `gvar_state_b` (L88) |
| `zelres1/code/106TOWN.asm` | `gvar_skip_flag2` (L48) |
| `zelres2/code/200FIGHT.asm` | `gvar_state_b` (L77) |
| `zelres2/code/217KENJP.asm` | `gvar_enter_flag` (L71) |

## 0xFF2A — 3 distinct names across 3 chunks

Names: `gvar_map_ptr`, `gvar_plystate`, `gvar_tile_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_tile_ptr` (L52) |
| `zelres1/code/111GTMCA.asm` | `gvar_plystate` (L35) |
| `zelres1/code/zr1com.inc` | `gvar_map_ptr` (L140) |

## 0xFF36 — 3 distinct names across 4 chunks

Names: `color_sel`, `gvar_enemy_cnt`, `gvar_save_flag_3`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gvar_enemy_cnt` (L65) |
| `zelres2/code/200FIGHT.asm` | `color_sel` (L131), `gvar_save_flag_3` (L132) |
| `zelres2/code/zr2com.inc` | `color_sel` (L155) |
| `zelres3/code/zr3com.inc` | `gvar_enemy_cnt` (L29) |

## 0xFF3E — 3 distinct names across 2 chunks

Names: `gvar_flag_FF3E`, `gvar_palette_b`, `spell_fx_active`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gvar_palette_b` (L80) |
| `zelres2/code/200FIGHT.asm` | `spell_fx_active` (L155), `gvar_flag_FF3E` (L156) |

## 0xFF45 — 3 distinct names across 2 chunks

Names: `gvar_combat_action_state`, `gvar_flag_FF45`, `scroll_phase`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `gvar_combat_action_state` (L212), `gvar_flag_FF45` (L217) |
| `zelres2/code/zr2com.inc` | `scroll_phase` (L167) |

## 0xFF46 — 3 distinct names across 2 chunks

Names: `gvar_combat_anim_subindex`, `gvar_flag_FF46`, `scroll_step`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `gvar_combat_anim_subindex` (L213), `gvar_flag_FF46` (L218) |
| `zelres2/code/zr2com.inc` | `scroll_step` (L168) |

## 0xFF4A — 3 distinct names across 2 chunks

Names: `gvar_flag_FF4A`, `gvar_sub_frame`, `obj_scan_index`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `obj_scan_index` (L235), `gvar_flag_FF4A` (L236) |
| `zelres3/code/zr3com.inc` | `gvar_sub_frame` (L35) |

## 0xFF56 — 3 distinct names across 4 chunks

Names: `gvar_name_page`, `gvar_sel_row`, `menu_start_idx`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_sel_row` (L61) |
| `zelres2/code/212ARMRP.asm` | `gvar_sel_row` (L52) |
| `zelres2/code/215DRUGP.asm` | `menu_start_idx` (L82) |
| `zelres2/code/217KENJP.asm` | `gvar_name_page` (L74) |

## 0xFF6C — 3 distinct names across 4 chunks

Names: `gvar_name_prev`, `gvar_save_name`, `gvar_save_name_buf`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `gvar_save_name_buf` (L96) |
| `core/zeliard.inc` | `gvar_save_name_buf` (L119) |
| `zelres1/code/106TOWN.asm` | `gvar_save_name` (L65) |
| `zelres2/code/217KENJP.asm` | `gvar_name_prev` (L76) |

## 0x0085 — 2 distinct names across 6 chunks

Names: `ANIM_85`, `gold_carried_x65536`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `gold_carried_x65536` (L59) |
| `zelres1/code/100OPDMO.asm` | `ANIM_85` (L148) |
| `zelres1/code/zr1com.inc` | `gold_carried_x65536` (L24) |
| `zelres2/code/250ENDMO.asm` | `ANIM_85` (L182) |
| `zelres2/code/zr2com.inc` | `gold_carried_x65536` (L23) |
| `zelres3/code/zr3com.inc` | `gold_carried_x65536` (L105) |

## 0x0086 — 2 distinct names across 5 chunks

Names: `ANIM_86`, `gold_carried_x1`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `gold_carried_x1` (L60) |
| `zelres1/code/100OPDMO.asm` | `ANIM_86` (L149) |
| `zelres1/code/zr1com.inc` | `gold_carried_x1` (L25) |
| `zelres2/code/zr2com.inc` | `gold_carried_x1` (L24) |
| `zelres3/code/zr3com.inc` | `gold_carried_x1` (L106) |

## 0x0087 — 2 distinct names across 5 chunks

Names: `ANIM_87`, `gold_carried_x256`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `gold_carried_x256` (L61) |
| `zelres1/code/100OPDMO.asm` | `ANIM_87` (L150) |
| `zelres1/code/zr1com.inc` | `gold_carried_x256` (L26) |
| `zelres2/code/zr2com.inc` | `gold_carried_x256` (L25) |
| `zelres3/code/zr3com.inc` | `gold_carried_x256` (L107) |

## 0x008B — 2 distinct names across 5 chunks

Names: `ANIM_8B`, `player_almas`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `player_almas` (L76) |
| `zelres1/code/100OPDMO.asm` | `ANIM_8B` (L154) |
| `zelres1/code/zr1com.inc` | `player_almas` (L29) |
| `zelres2/code/zr2com.inc` | `player_almas` (L28) |
| `zelres3/code/zr3com.inc` | `player_almas` (L110) |

## 0x008C — 2 distinct names across 5 chunks

Names: `ANIM_8C`, `player_almas_hi`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `player_almas_hi` (L77) |
| `zelres1/code/100OPDMO.asm` | `ANIM_8C` (L155) |
| `zelres1/code/zr1com.inc` | `player_almas_hi` (L200) |
| `zelres2/code/zr2com.inc` | `player_almas_hi` (L234) |
| `zelres3/code/zr3com.inc` | `player_almas_hi` (L111) |

## 0x0090 — 2 distinct names across 7 chunks

Names: `ANIM_90`, `player_HP`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `player_HP` (L93) |
| `zelres1/code/100OPDMO.asm` | `ANIM_90` (L159) |
| `zelres1/code/zr1com.inc` | `player_HP` (L32) |
| `zelres2/code/201SELCT.asm` | `player_HP` (L126) |
| `zelres2/code/250ENDMO.asm` | `ANIM_90` (L183) |
| `zelres2/code/zr2com.inc` | `player_HP` (L31) |
| `zelres3/code/zr3com.inc` | `player_HP` (L114) |

## 0x0091 — 2 distinct names across 3 chunks

Names: `ANIM_91`, `player_HP_hi`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `player_HP_hi` (L94) |
| `zelres1/code/100OPDMO.asm` | `ANIM_91` (L160) |
| `zelres2/code/250ENDMO.asm` | `ANIM_91` (L184) |

## 0x0092 — 2 distinct names across 8 chunks

Names: `ANIM_92`, `sword`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `sword` (L50) |
| `drivers/stdply.inc` | `sword` (L96) |
| `zelres1/code/100OPDMO.asm` | `ANIM_92` (L161) |
| `zelres1/code/zr1com.inc` | `sword` (L33) |
| `zelres2/code/201SELCT.asm` | `sword` (L124) |
| `zelres2/code/250ENDMO.asm` | `ANIM_92` (L185) |
| `zelres2/code/zr2com.inc` | `sword` (L32) |
| `zelres3/code/zr3com.inc` | `sword` (L115) |

## 0x0093 — 2 distinct names across 8 chunks

Names: `ANIM_93`, `shield`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `shield` (L51) |
| `drivers/stdply.inc` | `shield` (L117) |
| `zelres1/code/100OPDMO.asm` | `ANIM_93` (L162) |
| `zelres1/code/zr1com.inc` | `shield` (L34) |
| `zelres2/code/201SELCT.asm` | `shield` (L125) |
| `zelres2/code/250ENDMO.asm` | `ANIM_93` (L186) |
| `zelres2/code/zr2com.inc` | `shield` (L33) |
| `zelres3/code/zr3com.inc` | `shield` (L116) |

## 0x0094 — 2 distinct names across 7 chunks

Names: `ANIM_94`, `shield_HP`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `shield_HP` (L118) |
| `zelres1/code/100OPDMO.asm` | `ANIM_94` (L163) |
| `zelres1/code/zr1com.inc` | `shield_HP` (L35) |
| `zelres2/code/201SELCT.asm` | `shield_HP` (L128) |
| `zelres2/code/250ENDMO.asm` | `ANIM_94` (L187) |
| `zelres2/code/zr2com.inc` | `shield_HP` (L34) |
| `zelres3/code/zr3com.inc` | `shield_HP` (L117) |

## 0x0095 — 2 distinct names across 3 chunks

Names: `ANIM_95`, `shield_HP_hi`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `shield_HP_hi` (L119) |
| `zelres1/code/100OPDMO.asm` | `ANIM_95` (L164) |
| `zelres2/code/250ENDMO.asm` | `ANIM_95` (L188) |

## 0x009F — 2 distinct names across 3 chunks

Names: `ANIM_9F`, `stat_X9F`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `stat_X9F` (L190) |
| `zelres1/code/100OPDMO.asm` | `ANIM_9F` (L174) |
| `zelres1/code/zr1com.inc` | `stat_X9F` (L54) |

## 0x00A6 — 2 distinct names across 5 chunks

Names: `item_flags`, `item_slot_1`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `item_slot_1` (L240), `item_flags` (L245) |
| `zelres1/code/zr1com.inc` | `item_slot_1` (L211) |
| `zelres2/code/201SELCT.asm` | `item_flags` (L122) |
| `zelres2/code/zr2com.inc` | `item_slot_1` (L245) |
| `zelres3/code/zr3com.inc` | `item_slot_1` (L132) |

## 0x00B0 — 2 distinct names across 2 chunks

Names: `ANIM_B0`, `spell_charge_agua`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_charge_agua` (L261) |
| `zelres2/code/250ENDMO.asm` | `ANIM_B0` (L198) |

## 0x00B1 — 2 distinct names across 2 chunks

Names: `ANIM_B1`, `spell_charge_guerra`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_charge_guerra` (L262) |
| `zelres2/code/250ENDMO.asm` | `ANIM_B1` (L199) |

## 0x00B2 — 2 distinct names across 6 chunks

Names: `ANIM_B2`, `player_hp_max`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `player_hp_max` (L267) |
| `zelres1/code/zr1com.inc` | `player_hp_max` (L56) |
| `zelres2/code/201SELCT.asm` | `player_hp_max` (L127) |
| `zelres2/code/250ENDMO.asm` | `ANIM_B2` (L200) |
| `zelres2/code/zr2com.inc` | `player_hp_max` (L48) |
| `zelres3/code/zr3com.inc` | `player_hp_max` (L133) |

## 0x00B5 — 2 distinct names across 2 chunks

Names: `ANIM_B5`, `spell_charge_max_saeta`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_charge_max_saeta` (L272) |
| `zelres2/code/250ENDMO.asm` | `ANIM_B5` (L203) |

## 0x00B6 — 2 distinct names across 2 chunks

Names: `ANIM_B6`, `spell_charge_max_fuego`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_charge_max_fuego` (L273) |
| `zelres2/code/250ENDMO.asm` | `ANIM_B6` (L204) |

## 0x00B7 — 2 distinct names across 2 chunks

Names: `ANIM_B7`, `spell_charge_max_lanzar`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_charge_max_lanzar` (L274) |
| `zelres2/code/250ENDMO.asm` | `ANIM_B7` (L205) |

## 0x00B8 — 2 distinct names across 2 chunks

Names: `ANIM_B8`, `spell_charge_max_rascar`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `spell_charge_max_rascar` (L275) |
| `zelres2/code/250ENDMO.asm` | `ANIM_B8` (L206) |

## 0x00C3 — 2 distinct names across 4 chunks

Names: `boss_intro_flag`, `stat_XC3`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `boss_intro_flag` (L331), `stat_XC3` (L332) |
| `zelres1/code/zr1com.inc` | `boss_intro_flag` (L59) |
| `zelres2/code/zr2com.inc` | `boss_intro_flag` (L81) |
| `zelres3/code/zr3com.inc` | `boss_intro_flag` (L135) |

## 0x00C5 — 2 distinct names across 4 chunks

Names: `last_sage_visited`, `stat_XC5`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `last_sage_visited` (L346), `stat_XC5` (L347) |
| `zelres1/code/zr1com.inc` | `last_sage_visited` (L213) |
| `zelres2/code/zr2com.inc` | `stat_XC5` (L52), `last_sage_visited` (L247) |
| `zelres3/code/zr3com.inc` | `last_sage_visited` (L137) |

## 0x00C6 — 2 distinct names across 4 chunks

Names: `heal_pulse_count`, `stat_XC6`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `heal_pulse_count` (L425), `stat_XC6` (L426) |
| `zelres1/code/zr1com.inc` | `heal_pulse_count` (L62) |
| `zelres2/code/zr2com.inc` | `heal_pulse_count` (L82) |
| `zelres3/code/zr3com.inc` | `heal_pulse_count` (L138) |

## 0x00D2 — 2 distinct names across 2 chunks

Names: `player_hitbox`, `weapon_shop_swords_muralla`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `weapon_shop_swords_muralla` (L390), `player_hitbox` (L399) |
| `zelres2/code/zr2com.inc` | `weapon_shop_swords_muralla` (L266) |

## 0x00E0 — 2 distinct names across 3 chunks

Names: `char_width`, `weapon_shop_shields_dorado`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmmcga.asm` | `char_width` (L95) |
| `drivers/stdply.inc` | `weapon_shop_shields_dorado` (L410) |
| `zelres2/code/zr2com.inc` | `weapon_shop_shields_dorado` (L280) |

## 0x00E4 — 2 distinct names across 5 chunks

Names: `key_count`, `stat_XE4`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `key_count` (L429), `stat_XE4` (L430) |
| `zelres1/code/zr1com.inc` | `key_count` (L64) |
| `zelres2/code/201SELCT.asm` | `key_count` (L135) |
| `zelres2/code/zr2com.inc` | `key_count` (L54) |
| `zelres3/code/zr3com.inc` | `key_count` (L140) |

## 0x00E6 — 2 distinct names across 4 chunks

Names: `scene_trans_request`, `stat_XE6`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `scene_trans_request` (L441), `stat_XE6` (L442) |
| `zelres1/code/zr1com.inc` | `scene_trans_request` (L65) |
| `zelres2/code/zr2com.inc` | `scene_trans_request` (L83) |
| `zelres3/code/zr3com.inc` | `scene_trans_request` (L142) |

## 0x00E7 — 2 distinct names across 6 chunks

Names: `gvar_pose_idx`, `stat_XE7`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gvar_pose_idx` (L59) |
| `drivers/stdply.inc` | `gvar_pose_idx` (L459), `stat_XE7` (L460) |
| `zelres1/code/zr1com.inc` | `gvar_pose_idx` (L66) |
| `zelres2/code/zr2com.inc` | `gvar_pose_idx` (L84) |
| `zelres3/code/300ROKAD.asm` | `gvar_pose_idx` (L120) |
| `zelres3/code/zr3com.inc` | `gvar_pose_idx` (L143) |

## 0x00E8 — 2 distinct names across 4 chunks

Names: `init_complete_flag`, `stat_XE8`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/stdply.inc` | `init_complete_flag` (L467), `stat_XE8` (L468) |
| `zelres1/code/zr1com.inc` | `init_complete_flag` (L67) |
| `zelres2/code/zr2com.inc` | `init_complete_flag` (L85) |
| `zelres3/code/zr3com.inc` | `init_complete_flag` (L144) |

## 0x0110 — 2 distinct names across 4 chunks

Names: `stick_disp_110`, `stick_exit_dlg_handler`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_disp_110` (L36) |
| `zelres1/code/zr1com.inc` | `stick_exit_dlg_handler` (L76) |
| `zelres2/code/250ENDMO.asm` | `stick_exit_dlg_handler` (L98) |
| `zelres2/code/zr2com.inc` | `stick_exit_dlg_handler` (L64) |

## 0x0112 — 2 distinct names across 4 chunks

Names: `stick_disp_112`, `stick_pause_dlg_handler`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_disp_112` (L37) |
| `zelres1/code/zr1com.inc` | `stick_pause_dlg_handler` (L77) |
| `zelres2/code/250ENDMO.asm` | `stick_pause_dlg_handler` (L99) |
| `zelres2/code/zr2com.inc` | `stick_pause_dlg_handler` (L65) |

## 0x0114 — 2 distinct names across 3 chunks

Names: `stick_disp_114`, `stick_speed_change_handler`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_disp_114` (L38) |
| `zelres1/code/zr1com.inc` | `stick_speed_change_handler` (L78) |
| `zelres2/code/zr2com.inc` | `stick_speed_change_handler` (L66) |

## 0x0116 — 2 distinct names across 4 chunks

Names: `stick_disp_116`, `stick_joy_cal_handler`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_disp_116` (L39) |
| `zelres1/code/zr1com.inc` | `stick_joy_cal_handler` (L79) |
| `zelres2/code/250ENDMO.asm` | `stick_joy_cal_handler` (L100) |
| `zelres2/code/zr2com.inc` | `stick_joy_cal_handler` (L67) |

## 0x0118 — 2 distinct names across 4 chunks

Names: `stick_disp_118`, `stick_joy_detect_handler`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_disp_118` (L40) |
| `zelres1/code/zr1com.inc` | `stick_joy_detect_handler` (L80) |
| `zelres2/code/250ENDMO.asm` | `stick_joy_detect_handler` (L101) |
| `zelres2/code/zr2com.inc` | `stick_joy_detect_handler` (L68) |

## 0x011A — 2 distinct names across 4 chunks

Names: `stick_disp_11A`, `stick_subsample_tick_handler`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_disp_11A` (L41) |
| `zelres1/code/zr1com.inc` | `stick_subsample_tick_handler` (L81) |
| `zelres2/code/zr2com.inc` | `stick_subsample_tick_handler` (L69) |
| `zelres3/code/zr3com.inc` | `stick_subsample_tick_handler` (L22) |

## 0x011C — 2 distinct names across 3 chunks

Names: `stick_disp_11C`, `stick_savefile_scan_handler`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_disp_11C` (L42) |
| `zelres1/code/zr1com.inc` | `stick_savefile_scan_handler` (L82) |
| `zelres2/code/zr2com.inc` | `stick_savefile_scan_handler` (L70) |

## 0x011E — 2 distinct names across 3 chunks

Names: `stick_disp_11E`, `stick_restore_dlg_handler`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_disp_11E` (L43) |
| `zelres1/code/zr1com.inc` | `stick_restore_dlg_handler` (L83) |
| `zelres2/code/zr2com.inc` | `stick_restore_dlg_handler` (L71) |

## 0x0120 — 2 distinct names across 4 chunks

Names: `stick_disp_120`, `stick_joy_poll_handler`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `stick_joy_poll_handler` (L49) |
| `core/zeliard.inc` | `stick_disp_120` (L44) |
| `zelres1/code/zr1com.inc` | `stick_joy_poll_handler` (L84) |
| `zelres2/code/zr2com.inc` | `stick_joy_poll_handler` (L72) |

## 0x0138 — 2 distinct names across 2 chunks

Names: `mca_row_stride`, `stride_minus_8`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/111GTMCA.asm` | `stride_minus_8` (L73) |
| `zelres2/code/206GFMCA.asm` | `mca_row_stride` (L99) |

## 0x0240 — 2 distinct names across 2 chunks

Names: `cga_plane2_off`, `hgc_plane2_off`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/103GDHGC.asm` | `hgc_plane2_off` (L45) |
| `zelres1/code/zr1com.inc` | `cga_plane2_off` (L186) |

## 0x0280 — 2 distinct names across 2 chunks

Names: `ega_2row_stride`, `skip_2_rows`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmmcga.asm` | `skip_2_rows` (L75) |
| `zelres2/code/202GFEGA.asm` | `ega_2row_stride` (L86) |

## 0x04FD — 2 distinct names across 3 chunks

Names: `hgc_cursor_ofs`, `hgc_hud_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmhgc.asm` | `hgc_cursor_ofs` (L101) |
| `zelres1/code/109GTHGC.asm` | `hgc_cursor_ofs` (L79) |
| `zelres2/code/204GFHGC.asm` | `hgc_hud_ofs` (L81) |

## 0x0504 — 2 distinct names across 2 chunks

Names: `data_word_504`, `screen_start_off`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/101GDEGA.asm` | `screen_start_off` (L68) |
| `zelres2/code/200FIGHT.asm` | `data_word_504` (L285) |

## 0x05C1 — 2 distinct names across 2 chunks

Names: `input_dir_lo`, `stick_scratch_5C1`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_scratch_5C1` (L52) |
| `drivers/stick.asm` | `input_dir_lo` (L84) |

## 0x05C2 — 2 distinct names across 2 chunks

Names: `input_dir_hi`, `stick_scratch_5C2`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_scratch_5C2` (L53) |
| `drivers/stick.asm` | `input_dir_hi` (L85) |

## 0x05C3 — 2 distinct names across 2 chunks

Names: `input_btn_lo`, `stick_scratch_5C3`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_scratch_5C3` (L54) |
| `drivers/stick.asm` | `input_btn_lo` (L86) |

## 0x05C4 — 2 distinct names across 2 chunks

Names: `input_btn_hi`, `stick_scratch_5C4`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_scratch_5C4` (L55) |
| `drivers/stick.asm` | `input_btn_hi` (L87) |

## 0x05C5 — 2 distinct names across 2 chunks

Names: `ext_key_flag`, `stick_scratch_5C5`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_scratch_5C5` (L56) |
| `drivers/stick.asm` | `ext_key_flag` (L88) |

## 0x05C6 — 2 distinct names across 2 chunks

Names: `joy_cal_x`, `stick_scratch_5C6`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_scratch_5C6` (L57) |
| `drivers/stick.asm` | `joy_cal_x` (L89) |

## 0x05C8 — 2 distinct names across 2 chunks

Names: `joy_cal_y`, `stick_scratch_5C8`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `stick_scratch_5C8` (L58) |
| `drivers/stick.asm` | `joy_cal_y` (L90) |

## 0x2002 — 2 distinct names across 3 chunks

Names: `drv_screen_init_a`, `gfx_clear_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_clear_fn` (L86) |
| `zelres1/code/zr1com.inc` | `drv_screen_init_a` (L90) |
| `zelres2/code/zr2com.inc` | `drv_screen_init_a` (L92) |

## 0x2008 — 2 distinct names across 3 chunks

Names: `drv_palette_push`, `gfx_render_b_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_render_b_fn` (L89) |
| `zelres1/code/zr1com.inc` | `drv_palette_push` (L93) |
| `zelres2/code/zr2com.inc` | `drv_palette_push` (L95) |

## 0x200C — 2 distinct names across 3 chunks

Names: `drv_fn_6`, `fight_cb_prep`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/zr1com.inc` | `drv_fn_6` (L95) |
| `zelres2/code/zr2com.inc` | `drv_fn_6` (L97) |
| `zelres3/code/zr3com.inc` | `fight_cb_prep` (L66) |

## 0x200E — 2 distinct names across 3 chunks

Names: `drv_fn_7`, `gfx_load_img_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_load_img_fn` (L90) |
| `zelres1/code/zr1com.inc` | `drv_fn_7` (L96) |
| `zelres2/code/zr2com.inc` | `drv_fn_7` (L98) |

## 0x2010 — 2 distinct names across 3 chunks

Names: `drv_load_msg_header`, `gfx_draw_map_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_draw_map_fn` (L91) |
| `zelres1/code/zr1com.inc` | `drv_load_msg_header` (L97) |
| `zelres2/code/zr2com.inc` | `drv_load_msg_header` (L99) |

## 0x2012 — 2 distinct names across 3 chunks

Names: `drv_screen_init_b`, `gfx_draw_player_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_draw_player_fn` (L92) |
| `zelres1/code/zr1com.inc` | `drv_screen_init_b` (L98) |
| `zelres2/code/zr2com.inc` | `drv_screen_init_b` (L100) |

## 0x2016 — 2 distinct names across 3 chunks

Names: `drv_frame_commit`, `gfx_render_d_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_render_d_fn` (L94) |
| `zelres1/code/zr1com.inc` | `drv_frame_commit` (L100) |
| `zelres2/code/zr2com.inc` | `drv_frame_commit` (L102) |

## 0x2018 — 2 distinct names across 3 chunks

Names: `drv_anim_step`, `gfx_draw_icon_a_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_draw_icon_a_fn` (L95) |
| `zelres1/code/zr1com.inc` | `drv_anim_step` (L101) |
| `zelres2/code/zr2com.inc` | `drv_anim_step` (L103) |

## 0x201E — 2 distinct names across 2 chunks

Names: `drv_fn_15`, `gfx_call_b`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gfx_call_b` (L119) |
| `zelres2/code/201SELCT.asm` | `drv_fn_15` (L60) |

## 0x2038 — 2 distinct names across 2 chunks

Names: `drv_fn_28`, `gfx_clear_row_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_clear_row_fn` (L102) |
| `zelres2/code/201SELCT.asm` | `drv_fn_28` (L69) |

## 0x203E — 2 distinct names across 2 chunks

Names: `gfx_scene_fn`, `sound_load_track_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `sound_load_track_fn` (L121) |
| `zelres3/code/300ROKAD.asm` | `gfx_scene_fn` (L109) |

## 0x2040 — 2 distinct names across 3 chunks

Names: `drv_return_to_caller`, `gfx_blit_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_blit_fn` (L103) |
| `zelres1/code/zr1com.inc` | `drv_return_to_caller` (L107) |
| `zelres2/code/zr2com.inc` | `drv_return_to_caller` (L118) |

## 0x2042 — 2 distinct names across 2 chunks

Names: `gfx_init_fn`, `gfx_refresh_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/100OPDMO.asm` | `gfx_init_fn` (L55) |
| `zelres1/code/106TOWN.asm` | `gfx_refresh_fn` (L104) |

## 0x24EC — 2 distinct names across 2 chunks

Names: `text_vga_ofs_b`, `tile_dest_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `drivers/gmcga.asm` | `text_vga_ofs_b` (L59) |
| `zelres1/code/107GTEGA.asm` | `tile_dest_ofs` (L58) |

## 0x2F2E — 2 distinct names across 2 chunks

Names: `mao1_drv_misc_callback`, `mao2_drv_anim_cb`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/318MAO1.asm` | `mao1_drv_misc_callback` (L62) |
| `zelres3/code/319MAO2.asm` | `mao2_drv_anim_cb` (L74) |

## 0x301A — 2 distinct names across 2 chunks

Names: `drv_fn2_text_setup`, `gfx_sel_init_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_sel_init_fn` (L117) |
| `zelres2/code/217KENJP.asm` | `drv_fn2_text_setup` (L89) |

## 0x3026 — 2 distinct names across 2 chunks

Names: `gfx_copy_fn`, `gfx_tile_draw`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gfx_copy_fn` (L122) |
| `zelres3/code/300ROKAD.asm` | `gfx_tile_draw` (L112) |

## 0x32AF — 2 distinct names across 2 chunks

Names: `cga_blit_fn_c`, `mask_tbl_b`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/101GDEGA.asm` | `mask_tbl_b` (L43) |
| `zelres1/code/102GDCGA.asm` | `cga_blit_fn_c` (L51) |

## 0x3637 — 2 distinct names across 2 chunks

Names: `pal_cycle_tbl`, `sprite_frame_tbl`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/102GDCGA.asm` | `sprite_frame_tbl` (L55) |
| `zelres1/code/105GDMCA.asm` | `pal_cycle_tbl` (L70) |

## 0x3CAF — 2 distinct names across 2 chunks

Names: `tile_bitbuf`, `tile_idx_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/109GTHGC.asm` | `tile_idx_a` (L91) |
| `zelres1/code/111GTMCA.asm` | `tile_bitbuf` (L63) |

## 0x4050 — 2 distinct names across 2 chunks

Names: `cga_work_buf_p2`, `hgc_work_buf_p2`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/102GDCGA.asm` | `cga_work_buf_p2` (L73) |
| `zelres1/code/103GDHGC.asm` | `hgc_work_buf_p2` (L71) |

## 0x4F86 — 2 distinct names across 2 chunks

Names: `hero_gfx_tbl`, `sprite_row_buf`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/103GDHGC.asm` | `sprite_row_buf` (L66) |
| `zelres2/code/204GFHGC.asm` | `hero_gfx_tbl` (L65) |

## 0x4FEB — 2 distinct names across 2 chunks

Names: `col_idx`, `vga_row_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/204GFHGC.asm` | `col_idx` (L95) |
| `zelres2/code/206GFMCA.asm` | `vga_row_ptr` (L85) |

## 0x4FED — 2 distinct names across 2 chunks

Names: `palette_byte`, `scroll_vga_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/204GFHGC.asm` | `palette_byte` (L97) |
| `zelres2/code/206GFMCA.asm` | `scroll_vga_ofs` (L86) |

## 0x4FEF — 2 distinct names across 2 chunks

Names: `rle_tmp_a`, `scroll_src_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/204GFHGC.asm` | `scroll_src_ofs` (L69) |
| `zelres2/code/206GFMCA.asm` | `rle_tmp_a` (L87) |

## 0x4FF1 — 2 distinct names across 2 chunks

Names: `row_counter`, `scroll_gfx_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/204GFHGC.asm` | `scroll_gfx_ptr` (L70) |
| `zelres2/code/206GFMCA.asm` | `row_counter` (L109) |

## 0x4FF3 — 2 distinct names across 2 chunks

Names: `row_idx`, `scroll_delta`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/204GFHGC.asm` | `scroll_delta` (L71) |
| `zelres2/code/206GFMCA.asm` | `row_idx` (L111) |

## 0x4FF5 — 2 distinct names across 2 chunks

Names: `rle_tmp_b`, `shift_count`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/204GFHGC.asm` | `shift_count` (L72) |
| `zelres2/code/206GFMCA.asm` | `rle_tmp_b` (L88) |

## 0x4FF7 — 2 distinct names across 2 chunks

Names: `anim_phase`, `scroll_src_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/204GFHGC.asm` | `anim_phase` (L106) |
| `zelres2/code/206GFMCA.asm` | `scroll_src_ofs` (L89) |

## 0x4FF9 — 2 distinct names across 2 chunks

Names: `scroll_gfx_ptr`, `sprite_row_buf`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/204GFHGC.asm` | `sprite_row_buf` (L73) |
| `zelres2/code/206GFMCA.asm` | `scroll_gfx_ptr` (L90) |

## 0x506B — 2 distinct names across 2 chunks

Names: `cur_color_pair`, `scroll_vga_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/202GFEGA.asm` | `scroll_vga_ofs` (L77) |
| `zelres2/code/203GFCGA.asm` | `cur_color_pair` (L62) |

## 0x506D — 2 distinct names across 2 chunks

Names: `row_counter`, `vga_row_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/202GFEGA.asm` | `row_counter` (L99) |
| `zelres2/code/203GFCGA.asm` | `vga_row_ptr` (L63) |

## 0x506F — 2 distinct names across 2 chunks

Names: `row_idx`, `scroll_vga_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/202GFEGA.asm` | `row_idx` (L101) |
| `zelres2/code/203GFCGA.asm` | `scroll_vga_ofs` (L64) |

## 0x5071 — 2 distinct names across 2 chunks

Names: `bitmask_byte`, `cga_ofs_5071`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/202GFEGA.asm` | `bitmask_byte` (L103) |
| `zelres2/code/203GFCGA.asm` | `cga_ofs_5071` (L65) |

## 0x5074 — 2 distinct names across 2 chunks

Names: `col_idx`, `scroll_gfx_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/202GFEGA.asm` | `scroll_gfx_ptr` (L79) |
| `zelres2/code/203GFCGA.asm` | `col_idx` (L89) |

## 0x5076 — 2 distinct names across 2 chunks

Names: `palette_byte`, `scroll_delta`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/202GFEGA.asm` | `scroll_delta` (L80) |
| `zelres2/code/203GFCGA.asm` | `palette_byte` (L91) |

## 0x5078 — 2 distinct names across 2 chunks

Names: `anim_phase`, `scroll_src_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/202GFEGA.asm` | `anim_phase` (L112) |
| `zelres2/code/203GFCGA.asm` | `scroll_src_ofs` (L66) |

## 0x507A — 2 distinct names across 2 chunks

Names: `scroll_gfx_ptr`, `sprite_row_buf`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/202GFEGA.asm` | `sprite_row_buf` (L82) |
| `zelres2/code/203GFCGA.asm` | `scroll_gfx_ptr` (L67) |

## 0x5238 — 2 distinct names across 2 chunks

Names: `col_idx`, `scroll_dst_ofs`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/110GTTGA.asm` | `scroll_dst_ofs` (L64) |
| `zelres2/code/205GFTGA.asm` | `col_idx` (L80) |

## 0x5255 — 2 distinct names across 2 chunks

Names: `sprite_row_buf`, `sprite_state_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/104GDTGA.asm` | `sprite_row_buf` (L61) |
| `zelres2/code/205GFTGA.asm` | `sprite_state_a` (L85) |

## 0x6004 — 2 distinct names across 2 chunks

Names: `fight_cb_range`, `script_step`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/zr2com.inc` | `script_step` (L129) |
| `zelres3/code/zr3com.inc` | `fight_cb_range` (L67) |

## 0x6006 — 2 distinct names across 2 chunks

Names: `fight_cb_alt_b`, `script_format_num`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/zr2com.inc` | `script_format_num` (L130) |
| `zelres3/code/zr3com.inc` | `fight_cb_alt_b` (L68) |

## 0x6008 — 2 distinct names across 2 chunks

Names: `fight_cb_step_neg`, `script_display_page`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/zr2com.inc` | `script_display_page` (L131) |
| `zelres3/code/zr3com.inc` | `fight_cb_step_neg` (L69) |

## 0x600A — 2 distinct names across 2 chunks

Names: `fight_cb_step_neg_2`, `script_take_item`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/zr2com.inc` | `script_take_item` (L132) |
| `zelres3/code/zr3com.inc` | `fight_cb_step_neg_2` (L70) |

## 0x600C — 2 distinct names across 2 chunks

Names: `fight_cb_map_fwd`, `script_give_item`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/zr2com.inc` | `script_give_item` (L133) |
| `zelres3/code/zr3com.inc` | `fight_cb_map_fwd` (L71) |

## 0x601C — 2 distinct names across 2 chunks

Names: `fight_cb_aux_1c`, `level_ref_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `level_ref_a` (L391) |
| `zelres3/code/zr3com.inc` | `fight_cb_aux_1c` (L79) |

## 0x8640 — 2 distinct names across 2 chunks

Names: `hgc_plane_buf_a`, `save_background_pixels_buf_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/203GFCGA.asm` | `save_background_pixels_buf_a` (L49) |
| `zelres2/code/204GFHGC.asm` | `hgc_plane_buf_a` (L52) |

## 0x8690 — 2 distinct names across 2 chunks

Names: `save_background_pixels_buf_b`, `sprite_src_base`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/203GFCGA.asm` | `save_background_pixels_buf_b` (L50) |
| `zelres2/code/204GFHGC.asm` | `sprite_src_base` (L53) |

## 0x97C0 — 2 distinct names across 3 chunks

Names: `scene_data_i`, `sprite_img_base`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/100OPDMO.asm` | `scene_data_i` (L112) |
| `zelres1/code/101GDEGA.asm` | `sprite_img_base` (L40) |
| `zelres1/code/105GDMCA.asm` | `sprite_img_base` (L42) |

## 0xA002 — 2 distinct names across 2 chunks

Names: `obj_data_ptr`, `player_draw_fn`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `player_draw_fn` (L160) |
| `zelres2/code/200FIGHT.asm` | `obj_data_ptr` (L349) |

## 0xA004 — 2 distinct names across 2 chunks

Names: `player_jump_fn`, `shop_entry_probe`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `player_jump_fn` (L161) |
| `zelres2/code/211OMOYP.asm` | `shop_entry_probe` (L68) |

## 0xA078 — 2 distinct names across 2 chunks

Names: `dispatch_tbl_base`, `opcode_dispatch_tbl`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/210KINGP.asm` | `dispatch_tbl_base` (L62) |
| `zelres2/code/214CHURP.asm` | `opcode_dispatch_tbl` (L53) |

## 0xA41B — 2 distinct names across 2 chunks

Names: `lega_tbl_a41b`, `meda_tbl_e`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/305EAI5.asm` | `meda_tbl_e` (L104) |
| `zelres3/code/314LEGA.asm` | `lega_tbl_a41b` (L62) |

## 0xA59A — 2 distinct names across 2 chunks

Names: `cur_pose_y`, `mao1_phase_dir`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/300ROKAD.asm` | `cur_pose_y` (L139) |
| `zelres3/code/318MAO1.asm` | `mao1_phase_dir` (L95) |

## 0xA59B — 2 distinct names across 2 chunks

Names: `cur_pose_x`, `mao1_phase_step`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/300ROKAD.asm` | `cur_pose_x` (L140) |
| `zelres3/code/318MAO1.asm` | `mao1_phase_step` (L96) |

## 0xA59C — 2 distinct names across 2 chunks

Names: `bres_pos_y`, `mao1_phase_substate`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/300ROKAD.asm` | `bres_pos_y` (L141) |
| `zelres3/code/318MAO1.asm` | `mao1_phase_substate` (L97) |

## 0xA5A1 — 2 distinct names across 2 chunks

Names: `bres_dy`, `mao1_attr_tmp`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/300ROKAD.asm` | `bres_dy` (L146) |
| `zelres3/code/318MAO1.asm` | `mao1_attr_tmp` (L98) |

## 0xA5A3 — 2 distinct names across 2 chunks

Names: `bres_error`, `tori_tbl_c`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/300ROKAD.asm` | `bres_error` (L148) |
| `zelres3/code/303EAI3.asm` | `tori_tbl_c` (L77) |

## 0xA5F9 — 2 distinct names across 2 chunks

Names: `crab_anim_tbl_c`, `zel2_death_handler_flag`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/309CRAB.asm` | `crab_anim_tbl_c` (L67) |
| `zelres3/code/315ZEL2.asm` | `zel2_death_handler_flag` (L81) |

## 0xA603 — 2 distinct names across 2 chunks

Names: `zel2_render_buf`, `zela_tile_phase`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/312ZELA.asm` | `zela_tile_phase` (L82) |
| `zelres3/code/315ZEL2.asm` | `zel2_render_buf` (L61) |

## 0xA60C — 2 distinct names across 2 chunks

Names: `zel2_render_attr_b`, `zela_anim_byte`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/312ZELA.asm` | `zela_anim_byte` (L91) |
| `zelres3/code/315ZEL2.asm` | `zel2_render_attr_b` (L92) |

## 0xA613 — 2 distinct names across 2 chunks

Names: `meda_tile_src_c`, `zela_tile_field_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/312ZELA.asm` | `zela_tile_field_a` (L95) |
| `zelres3/code/313MEDA.asm` | `meda_tile_src_c` (L52) |

## 0xA64D — 2 distinct names across 2 chunks

Names: `sprite_pat_tbl`, `sprite_pat_tbl_b`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/310TAKO.asm` | `sprite_pat_tbl_b` (L73) |
| `zelres3/code/311TORI.asm` | `sprite_pat_tbl` (L68) |

## 0xA666 — 2 distinct names across 2 chunks

Names: `enemy_spawn_tile_hi`, `mao2_handler_step_tbl`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/308EAI8.asm` | `enemy_spawn_tile_hi` (L115) |
| `zelres3/code/319MAO2.asm` | `mao2_handler_step_tbl` (L102) |

## 0xA682 — 2 distinct names across 2 chunks

Names: `glide_table_a`, `meda_tile_src_f`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/311TORI.asm` | `glide_table_a` (L69) |
| `zelres3/code/313MEDA.asm` | `meda_tile_src_f` (L55) |

## 0xA6C8 — 2 distinct names across 2 chunks

Names: `intro_tile_map`, `lega_unk_a6c8`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/213BANKP.asm` | `intro_tile_map` (L66) |
| `zelres3/code/314LEGA.asm` | `lega_unk_a6c8` (L77) |

## 0xA723 — 2 distinct names across 2 chunks

Names: `crab_rotate_a`, `dir_xlat_table`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/301EAI1.asm` | `crab_rotate_a` (L118) |
| `zelres3/code/308EAI8.asm` | `dir_xlat_table` (L119) |

## 0xA72F — 2 distinct names across 2 chunks

Names: `crab_rotate_b`, `meda_phase_dir`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/301EAI1.asm` | `crab_rotate_b` (L119) |
| `zelres3/code/313MEDA.asm` | `meda_phase_dir` (L73) |

## 0xA766 — 2 distinct names across 2 chunks

Names: `dir_xlat_table`, `tori_spawn_tile`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/306EAI6.asm` | `dir_xlat_table` (L112) |
| `zelres3/code/311TORI.asm` | `tori_spawn_tile` (L73) |

## 0xA7A0 — 2 distinct names across 2 chunks

Names: `face_mode_flag`, `lega_scroll_x`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/210KINGP.asm` | `face_mode_flag` (L77) |
| `zelres3/code/314LEGA.asm` | `lega_scroll_x` (L78) |

## 0xA7C3 — 2 distinct names across 2 chunks

Names: `fight_hp`, `lega_anim2_x`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/309CRAB.asm` | `fight_hp` (L77) |
| `zelres3/code/314LEGA.asm` | `lega_anim2_x` (L94) |

## 0xA7C5 — 2 distinct names across 2 chunks

Names: `crab_phase_base`, `lega_anim2_y`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/309CRAB.asm` | `crab_phase_base` (L69) |
| `zelres3/code/314LEGA.asm` | `lega_anim2_y` (L95) |

## 0xA7C6 — 2 distinct names across 2 chunks

Names: `crab_phase_limit`, `lega_anim2_frame`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres3/code/309CRAB.asm` | `crab_phase_limit` (L78) |
| `zelres3/code/314LEGA.asm` | `lega_anim2_frame` (L96) |

## 0xA8FD — 2 distinct names across 2 chunks

Names: `drgn_phase_bp_tbl_d`, `shield_price_tbl_end`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/212ARMRP.asm` | `shield_price_tbl_end` (L78) |
| `zelres3/code/316DRGN.asm` | `drgn_phase_bp_tbl_d` (L73) |

## 0xAC39 — 2 distinct names across 2 chunks

Names: `mao2_clear_buf`, `sage_intro_lo`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/217KENJP.asm` | `sage_intro_lo` (L116) |
| `zelres3/code/319MAO2.asm` | `mao2_clear_buf` (L111) |

## 0xB1B0 — 2 distinct names across 2 chunks

Names: `mcga_mountain_row_ptr`, `vga_tile_l2`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/111GTMCA.asm` | `vga_tile_l2` (L81) |
| `zelres2/code/208YMPD.asm` | `mcga_mountain_row_ptr` (L94) |

## 0xBBB0 — 2 distinct names across 2 chunks

Names: `mcga_ground_dst`, `vga_tile_l3`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/111GTMCA.asm` | `vga_tile_l3` (L83) |
| `zelres2/code/208YMPD.asm` | `mcga_ground_dst` (L96) |

## 0xBF07 — 2 distinct names across 2 chunks

Names: `font_ctrl_byte`, `tga_color_reg`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/104GDTGA.asm` | `tga_color_reg` (L63) |
| `zelres1/code/zr1com.inc` | `font_ctrl_byte` (L178) |

## 0xC004 — 2 distinct names across 2 chunks

Names: `map_top_ptr`, `town_tile_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `town_tile_ptr` (L164) |
| `zelres2/code/200FIGHT.asm` | `map_top_ptr` (L355) |

## 0xC012 — 2 distinct names across 2 chunks

Names: `area_num`, `sprite_attr_b`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `area_num` (L361) |
| `zelres2/code/zr2com.inc` | `sprite_attr_b` (L216) |

## 0xC015 — 2 distinct names across 2 chunks

Names: `target_y`, `town_key_event`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `town_key_event` (L171) |
| `zelres2/code/200FIGHT.asm` | `target_y` (L363) |

## 0xE001 — 2 distinct names across 2 chunks

Names: `cursor_buf_cnt`, `scroll_buf_p1`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `cursor_buf_cnt` (L174) |
| `zelres2/code/200FIGHT.asm` | `scroll_buf_p1` (L368) |

## 0xE900 — 2 distinct names across 2 chunks

Names: `hud_buf`, `sprite_buf`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `hud_buf` (L371) |
| `zelres2/code/zr2com.inc` | `sprite_buf` (L218) |

## 0xE939 — 2 distinct names across 2 chunks

Names: `hud_player_area`, `mao1_text_dst`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `hud_player_area` (L373) |
| `zelres3/code/318MAO1.asm` | `mao1_text_dst` (L87) |

## 0xEB60 — 2 distinct names across 2 chunks

Names: `anim_spr_tbl`, `sprite_work_buf`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `sprite_work_buf` (L374) |
| `zelres2/code/201SELCT.asm` | `anim_spr_tbl` (L141) |

## 0xEDA0 — 2 distinct names across 2 chunks

Names: `enemy_data_buf2`, `projectile_list`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `enemy_data_buf2` (L377) |
| `zelres2/code/zr2com.inc` | `projectile_list` (L221) |

## 0xF500 — 2 distinct names across 11 chunks

Names: `font_grp_dest`, `font_ptr_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `font_grp_dest` (L126) |
| `drivers/gmcga.asm` | `font_ptr_a` (L74) |
| `drivers/gmega.asm` | `font_ptr_a` (L64) |
| `drivers/gmhgc.asm` | `font_ptr_a` (L98) |
| `drivers/gmmcga.asm` | `font_ptr_a` (L71) |
| `drivers/gmtga.asm` | `font_ptr_a` (L72) |
| `zelres1/code/101GDEGA.asm` | `font_ptr_a` (L63) |
| `zelres1/code/102GDCGA.asm` | `font_ptr_a` (L71) |
| `zelres1/code/103GDHGC.asm` | `font_ptr_a` (L69) |
| `zelres1/code/104GDTGA.asm` | `font_ptr_a` (L65) |
| `zelres1/code/105GDMCA.asm` | `font_ptr_a` (L67) |

## 0xFF00 — 2 distinct names across 3 chunks

Names: `gvar_chunk_load_fn`, `gvar_fn_tbl`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `gvar_chunk_load_fn` (L51) |
| `core/zeliard.inc` | `gvar_chunk_load_fn` (L69) |
| `zelres1/code/106TOWN.asm` | `gvar_fn_tbl` (L44) |

## 0xFF08 — 2 distinct names across 5 chunks

Names: `gvar_timer_ff08`, `gvar_timer_ticks`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gvar_timer_ticks` (L63) |
| `core/zeliad.asm` | `gvar_timer_ticks` (L55) |
| `core/zeliard.inc` | `gvar_timer_ticks` (L73) |
| `zelres2/code/200FIGHT.asm` | `gvar_timer_ticks` (L72), `gvar_timer_ff08` (L73) |
| `zelres2/code/zr2com.inc` | `gvar_timer_ticks` (L138) |

## 0xFF14 — 2 distinct names across 5 chunks

Names: `gvar_gfx_mode`, `gvar_music_idx`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gvar_gfx_mode` (L64) |
| `core/zeliad.asm` | `gvar_gfx_mode` (L63) |
| `core/zeliard.inc` | `gvar_gfx_mode` (L81) |
| `zelres1/code/106TOWN.asm` | `gvar_music_idx` (L69) |
| `zelres2/code/211OMOYP.asm` | `gvar_gfx_mode` (L59) |

## 0xFF17 — 2 distinct names across 3 chunks

Names: `gvar_input_timer`, `gvar_timer_flag`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `gvar_timer_flag` (L66) |
| `core/zeliard.inc` | `gvar_timer_flag` (L84) |
| `zelres1/code/106TOWN.asm` | `gvar_input_timer` (L70) |

## 0xFF21 — 2 distinct names across 2 chunks

Names: `credits_skip_flag`, `mao2_gvar_state_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/250ENDMO.asm` | `credits_skip_flag` (L87) |
| `zelres3/code/319MAO2.asm` | `mao2_gvar_state_a` (L85) |

## 0xFF29 — 2 distinct names across 4 chunks

Names: `gvar_enter_key`, `gvar_key_code`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliard.inc` | `gvar_enter_key` (L137) |
| `zelres1/code/100OPDMO.asm` | `gvar_enter_key` (L45) |
| `zelres1/code/106TOWN.asm` | `gvar_enter_key` (L50) |
| `zelres2/code/217KENJP.asm` | `gvar_key_code` (L72) |

## 0xFF2C — 2 distinct names across 31 chunks

Names: `game_seg`, `gvar_game_seg`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `gvar_game_seg` (L75) |
| `core/zeliard.inc` | `gvar_game_seg` (L93) |
| `drivers/gmcga.asm` | `gvar_game_seg` (L35) |
| `drivers/gmega.asm` | `gvar_game_seg` (L33) |
| `drivers/gmhgc.asm` | `gvar_game_seg` (L65) |
| `drivers/gmmcga.asm` | `gvar_game_seg` (L45) |
| `drivers/gmtga.asm` | `gvar_game_seg` (L45) |
| `zelres1/code/100OPDMO.asm` | `gvar_game_seg` (L48) |
| `zelres1/code/101GDEGA.asm` | `gvar_game_seg` (L34) |
| `zelres1/code/102GDCGA.asm` | `gvar_game_seg` (L35) |
| `zelres1/code/103GDHGC.asm` | `gvar_game_seg` (L36) |
| `zelres1/code/104GDTGA.asm` | `gvar_game_seg` (L36) |
| `zelres1/code/105GDMCA.asm` | `gvar_game_seg` (L36) |
| `zelres1/code/106TOWN.asm` | `gvar_game_seg` (L53) |
| `zelres1/code/107GTEGA.asm` | `gvar_game_seg` (L35) |
| `zelres1/code/108GTCGA.asm` | `gvar_game_seg` (L35) |
| `zelres1/code/109GTHGC.asm` | `gvar_game_seg` (L35) |
| `zelres1/code/110GTTGA.asm` | `gvar_game_seg` (L35) |
| `zelres1/code/111GTMCA.asm` | `gvar_game_seg` (L36) |
| `zelres2/code/200FIGHT.asm` | `gvar_game_seg` (L84) |
| `zelres2/code/210KINGP.asm` | `gvar_game_seg` (L57) |
| `zelres2/code/211OMOYP.asm` | `gvar_game_seg` (L61) |
| `zelres2/code/212ARMRP.asm` | `gvar_game_seg` (L51) |
| `zelres2/code/213BANKP.asm` | `gvar_game_seg` (L51) |
| `zelres2/code/214CHURP.asm` | `gvar_game_seg` (L48) |
| `zelres2/code/215DRUGP.asm` | `gvar_game_seg` (L51) |
| `zelres2/code/216INNAP.asm` | `gvar_game_seg` (L43) |
| `zelres2/code/217KENJP.asm` | `gvar_game_seg` (L73) |
| `zelres2/code/250ENDMO.asm` | `gvar_game_seg` (L92) |
| `zelres2/code/zr2com.inc` | `game_seg` (L144) |
| `zelres3/code/300ROKAD.asm` | `gvar_game_seg` (L123) |

## 0xFF31 — 2 distinct names across 2 chunks

Names: `gvar_scroll_pos`, `sprite_data_ptr`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `gvar_scroll_pos` (L117) |
| `zelres2/code/zr2com.inc` | `sprite_data_ptr` (L146) |

## 0xFF34 — 2 distinct names across 2 chunks

Names: `flag_equip_b`, `gvar_save_flag_1`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `flag_equip_b` (L127), `gvar_save_flag_1` (L128) |
| `zelres2/code/zr2com.inc` | `flag_equip_b` (L153) |

## 0xFF37 — 2 distinct names across 2 chunks

Names: `gvar_save_flag_4`, `redraw_lock`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `redraw_lock` (L133), `gvar_save_flag_4` (L134) |
| `zelres2/code/zr2com.inc` | `redraw_lock` (L156) |

## 0xFF38 — 2 distinct names across 5 chunks

Names: `flag_shield`, `gvar_music_flag_a`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `flag_shield` (L71), `gvar_music_flag_a` (L72) |
| `core/zeliad.asm` | `flag_shield` (L82), `gvar_music_flag_a` (L83) |
| `core/zeliard.inc` | `flag_shield` (L100), `gvar_music_flag_a` (L101) |
| `zelres2/code/200FIGHT.asm` | `flag_shield` (L135), `gvar_music_flag_a` (L136) |
| `zelres2/code/zr2com.inc` | `flag_shield` (L157) |

## 0xFF39 — 2 distinct names across 5 chunks

Names: `flag_climbing`, `gvar_music_flag_b`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `flag_climbing` (L73), `gvar_music_flag_b` (L74) |
| `core/zeliad.asm` | `flag_climbing` (L84), `gvar_music_flag_b` (L85) |
| `core/zeliard.inc` | `flag_climbing` (L102), `gvar_music_flag_b` (L103) |
| `zelres2/code/200FIGHT.asm` | `flag_climbing` (L137), `gvar_music_flag_b` (L138) |
| `zelres2/code/zr2com.inc` | `flag_climbing` (L158) |

## 0xFF3A — 2 distinct names across 5 chunks

Names: `flag_riding`, `gvar_music_flag_c`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `flag_riding` (L75), `gvar_music_flag_c` (L76) |
| `core/zeliad.asm` | `flag_riding` (L86), `gvar_music_flag_c` (L87) |
| `core/zeliard.inc` | `flag_riding` (L104), `gvar_music_flag_c` (L105) |
| `zelres2/code/200FIGHT.asm` | `flag_riding` (L139), `gvar_music_flag_c` (L140) |
| `zelres2/code/zr2com.inc` | `flag_riding` (L159) |

## 0xFF3C — 2 distinct names across 5 chunks

Names: `gvar_palette_flag`, `gvar_unk_ff3c`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gvar_palette_flag` (L77) |
| `core/zeliad.asm` | `gvar_palette_flag` (L89) |
| `core/zeliard.inc` | `gvar_palette_flag` (L107) |
| `zelres2/code/200FIGHT.asm` | `gvar_palette_flag` (L141) |
| `zelres3/code/314LEGA.asm` | `gvar_unk_ff3c` (L55) |

## 0xFF3D — 2 distinct names across 3 chunks

Names: `equip_byte`, `gvar_combat_ff3D`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `equip_byte` (L78) |
| `zelres2/code/200FIGHT.asm` | `equip_byte` (L142), `gvar_combat_ff3D` (L143) |
| `zelres2/code/zr2com.inc` | `equip_byte` (L160) |

## 0xFF3F — 2 distinct names across 2 chunks

Names: `gvar_flag_FF3F`, `hero_frame`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `hero_frame` (L165), `gvar_flag_FF3F` (L166) |
| `zelres2/code/zr2com.inc` | `hero_frame` (L161) |

## 0xFF40 — 2 distinct names across 5 chunks

Names: `flag_hero_state`, `gvar_debug_mode`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `flag_hero_state` (L84), `gvar_debug_mode` (L85) |
| `core/zeliad.asm` | `gvar_debug_mode` (L90) |
| `core/zeliard.inc` | `flag_hero_state` (L110), `gvar_debug_mode` (L111) |
| `zelres2/code/200FIGHT.asm` | `flag_hero_state` (L171), `gvar_debug_mode` (L172) |
| `zelres2/code/zr2com.inc` | `flag_hero_state` (L162) |

## 0xFF41 — 2 distinct names across 2 chunks

Names: `gvar_flag_FF41`, `weapon_state`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres2/code/200FIGHT.asm` | `weapon_state` (L179), `gvar_flag_FF41` (L180) |
| `zelres2/code/zr2com.inc` | `weapon_state` (L163) |

## 0xFF42 — 2 distinct names across 5 chunks

Names: `gvar_debug_val`, `shield_sel`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gvar_debug_val` (L86) |
| `core/zeliad.asm` | `gvar_debug_val` (L91) |
| `core/zeliard.inc` | `gvar_debug_val` (L112) |
| `zelres2/code/200FIGHT.asm` | `gvar_debug_val` (L190) |
| `zelres2/code/zr2com.inc` | `shield_sel` (L164) |

## 0xFF43 — 2 distinct names across 5 chunks

Names: `gvar_joystick_flag`, `scroll_active`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `scroll_active` (L90), `gvar_joystick_flag` (L91) |
| `core/zeliad.asm` | `scroll_active` (L94), `gvar_joystick_flag` (L95) |
| `core/zeliard.inc` | `scroll_active` (L117), `gvar_joystick_flag` (L118) |
| `zelres2/code/200FIGHT.asm` | `scroll_active` (L195), `gvar_joystick_flag` (L196) |
| `zelres2/code/zr2com.inc` | `scroll_active` (L165) |

## 0xFF44 — 2 distinct names across 3 chunks

Names: `gvar_flag_FF44`, `restore_pending`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `restore_pending` (L95) |
| `zelres2/code/200FIGHT.asm` | `gvar_flag_FF44` (L200) |
| `zelres2/code/zr2com.inc` | `restore_pending` (L166) |

## 0xFF4B — 2 distinct names across 3 chunks

Names: `gvar_flag_FF4B`, `gvar_item_result`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/game.asm` | `gvar_item_result` (L96) |
| `zelres2/code/200FIGHT.asm` | `gvar_item_result` (L243), `gvar_flag_FF4B` (L244) |
| `zelres2/code/201SELCT.asm` | `gvar_item_result` (L50) |

## 0xFF58 — 2 distinct names across 3 chunks

Names: `gvar_sel_xlat`, `inventory_list`

| Chunk | Symbol name(s) (line) |
|---|---|
| `zelres1/code/106TOWN.asm` | `gvar_sel_xlat` (L63) |
| `zelres2/code/212ARMRP.asm` | `gvar_sel_xlat` (L54) |
| `zelres2/code/215DRUGP.asm` | `inventory_list` (L52) |

## 0xFF78 — 2 distinct names across 3 chunks

Names: `gvar_disk_swap_suppressed`, `gvar_load_flag`

| Chunk | Symbol name(s) (line) |
|---|---|
| `core/zeliad.asm` | `gvar_disk_swap_suppressed` (L99) |
| `core/zeliard.inc` | `gvar_disk_swap_suppressed` (L127) |
| `zelres1/code/106TOWN.asm` | `gvar_load_flag` (L68) |
