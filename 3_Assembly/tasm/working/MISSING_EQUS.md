# Missing-EQU Report

Scanned 965 raw-hex memory operands across the cleaned source.
Range: 0x0000..0xFFFF.  Min refs to flag MISSING: 2.

- **MISSING (no EQU exists)**: 27 addresses
- **UNUSED (EQU exists, raw hex used anyway)**: 77 addresses

## MISSING EQU symbols

Each address below has at least 2 raw-hex memory references
but no `equ` definition anywhere in the cleaned source.
Adopting a symbolic name would make the call sites self-
documenting.  Sorted by reference count (descending).

| Address | Refs | Sample call site |
|---|---|---|
| `0x011A` | 31 | `314LEGA.asm:372` — `call	word ptr cs:[11Ah]	; was: call word ptr cs:data_6 (fn ptr at offset 11Ah)` |
| `0x0110` | 15 | `200FIGHT.asm:2624` — `call	word ptr cs:[110h]` |
| `0x0112` | 14 | `200FIGHT.asm:2625` — `call	word ptr cs:[112h]` |
| `0x0116` | 12 | `200FIGHT.asm:2627` — `call	word ptr cs:[116h]` |
| `0x0118` | 12 | `200FIGHT.asm:2628` — `call	word ptr cs:[118h]` |
| `0x00C4` | 9 | `game.asm:323` — `mov	ah,byte ptr cs:[0C4h]	; Level/area number` |
| `0x0114` | 9 | `200FIGHT.asm:2626` — `call	word ptr cs:[114h]` |
| `0x00C8` | 6 | `game.asm:337` — `mov	byte ptr cs:[0C8h],al	; Store level tileset index` |
| `0x05C4` | 6 | `stick.asm:395` — `mov	byte ptr cs:[5C4h],0` |
| `0x05C2` | 5 | `stick.asm:393` — `mov	byte ptr cs:[5C2h],0` |
| `0x05C3` | 5 | `stick.asm:394` — `mov	byte ptr cs:[5C3h],0` |
| `0x05C1` | 4 | `stick.asm:392` — `mov	byte ptr cs:[5C1h],0` |
| `0x00C3` | 3 | `200FIGHT.asm:3837` — `mov	byte ptr ds:[0C3h],al` |
| `0x011E` | 3 | `200FIGHT.asm:2629` — `call	word ptr cs:[11Eh]` |
| `0x05C5` | 3 | `stick.asm:626` — `mov	byte ptr cs:[5C5h],0FFh` |
| `0x05C6` | 3 | `stick.asm:752` — `mov	cx,word ptr cs:[5C6h]` |
| `0x05C8` | 3 | `stick.asm:775` — `mov	cx,word ptr cs:[5C8h]` |
| `0x068E` | 3 | `213BANKP.asm:123` — `sub	byte ptr ds:[68Eh][bx],ah` |
| `0x0034` | 2 | `106TOWN.asm:1010` — `or	byte ptr ds:[34h],80h` |
| `0x0045` | 2 | `106TOWN.asm:2140` — `test	byte ptr ds:[45h],80h` |
| `0x00C5` | 2 | `200FIGHT.asm:7959` — `mov	byte ptr ds:[0C5h],80h` |
| `0x00D2` | 2 | `212ARMRP.asm:532` — `or	byte ptr ds:[0D2h][bx],al` |
| `0x01AA` | 2 | `207MOLE.asm:366` — `or	dl,byte ptr ds:[1AAh][bx]   ; LUT at 0x01AA: 4bpp->CGA 2bpp` |
| `0x0444` | 2 | `207MOLE.asm:820` — `mov	al,byte ptr cs:[444h][bx]	; LUT: high nibble -> 4 pixels` |
| `0x06F7` | 2 | `stick.asm:858` — `jmp	dword ptr ds:[6F7h]		; far jmp through DS:[0x06F7] pointer (exit dispatch)` |
| `0x092B` | 2 | `stick.asm:1092` — `add	ax,word ptr cs:[92Bh]` |
| `0xEB15` | 2 | `200FIGHT.asm:385` — `mov	word ptr ds:[0EB15h],ax` |

## UNUSED EQU symbols (raw hex used despite name existing)

These addresses have a symbolic name in the EQU map but
at least one reference site still uses the raw hex literal.
Replacing the literal with the symbol makes the source self-
consistent.

| Address | EQU name(s) | Raw-hex sites | Sample |
|---|---|---|---|
| `0x00C2` | `facing_direction` | 87 | `300ROKAD.asm:205` — `and	byte ptr ds:[0C2h],0FEh` |
| `0x0083` | `ANIM_83`, `player_col`, `ply_accel` | 76 | `200FIGHT.asm:488` — `mov	byte ptr ds:[83h],5` |
| `0x00E7` | `gvar_pose_idx`, `stat_XE7` | 64 | `game.asm:182` — `mov	byte ptr ds:[0E7h],al	; Unknown state var` |
| `0x0080` | `ANIM_80`, `PSP_cmd_size`, `half_stride`, `ply_walk_speed` | 54 | `200FIGHT.asm:487` — `mov	word ptr ds:[80h],29h` |
| `0x010C` | `sar_loader_fn` | 49 | `300ROKAD.asm:181` — `call	word ptr cs:[10Ch]` |
| `0x0084` | `ANIM_84` | 49 | `200FIGHT.asm:834` — `inc	byte ptr ds:[84h]` |
| `0x00E8` | `stat_XE8` | 28 | `200FIGHT.asm:1539` — `test	byte ptr ds:[0E8h],0FFh` |
| `0x0093` | `ANIM_93`, `equipped_magic`, `shield` | 23 | `game.asm:307` — `test	byte ptr ds:[93h],0FFh` |
| `0x0092` | `ANIM_92`, `sword`, `sword_type` | 22 | `game.asm:273` — `mov	ah,byte ptr ds:[92h]	; Archive number from config` |
| `0x009D` | `ANIM_9D`, `cur_weapon_idx`, `current_magic_spell` | 19 | `game.asm:314` — `test	byte ptr ds:[9Dh],0FFh` |
| `0x0082` | `ANIM_82` | 19 | `200FIGHT.asm:1035` — `dec	byte ptr ds:[82h]` |
| `0x0086` | `ANIM_86`, `hero_gold_lo` | 17 | `gmega.asm:879` — `mov	ax,word ptr cs:[86h]` |
| `0x0085` | `ANIM_85`, `hero_gold_hi` | 17 | `gmega.asm:880` — `mov	dl,byte ptr cs:[85h]` |
| `0x00B2` | `ANIM_B2`, `char_hp_max` | 14 | `gmcga.asm:495` — `mov	bx,cs:[00B2h]		; load BX from driver variable` |
| `0x0090` | `ANIM_90`, `char_hp`, `hero_HP` | 14 | `gmcga.asm:532` — `mov	bx,word ptr cs:[90h]` |
| `0x0089` | `ANIM_89`, `stat_X88_lo` | 14 | `213BANKP.asm:411` — `add	word ptr ds:[89h],ax` |
| `0x0088` | `ANIM_88`, `stat_X88_hi` | 14 | `213BANKP.asm:412` — `adc	byte ptr ds:[88h],dl` |
| `0x008B` | `ANIM_8B`, `hero_almas` | 13 | `gmega.asm:864` — `mov	ax,word ptr cs:[8Bh]` |
| `0x1028` | `sprite_backbuf_plane_sz` | 12 | `103GDHGC.asm:1833` — `and	al,byte ptr es:[1028h][di]` |
| `0x008D` | `ANIM_8D`, `item_qty_count`, `stat_X8D` | 11 | `200FIGHT.asm:7782` — `mov	ah,byte ptr ds:[8Dh]` |
| `0xFF1A` | `frame_timer`, `gvar_frame_timer`, `gvar_timer_byte`, `gvar_timer_lo`, `gvar_timer_ticks` | 10 | `213BANKP.asm:155` — `mov	byte ptr ds:[0FF1Ah],0` |
| `0x0094` | `ANIM_94`, `char_exp`, `shield_HP` | 9 | `gmega.asm:924` — `mov	ax,word ptr cs:[94h]` |
| `0x2000` | `driver_base`, `drv_fill_rect`, `gfx_fill_fn`, `gfx_fillrect_fn`, `gfx_screen_base`, `level_seg_ofs`, `mao1_drv_load_chunk` | 8 | `200FIGHT.asm:429` — `call	word ptr cs:[2000h]` |
| `0x2044` | `drv_ds_copy` | 8 | `200FIGHT.asm:516` — `call	word ptr cs:[2044h]` |
| `0x008E` | `ANIM_8E`, `item_effect_val`, `stat_X8E` | 8 | `200FIGHT.asm:7614` — `add	word ptr ds:[8Eh],ax` |
| `0x0049` | `area_load_flag` | 7 | `200FIGHT.asm:551` — `test	byte ptr ds:[49h],0FFh` |
| `0x00AB` | `drv_color_lut`, `weap_dur_cur` | 6 | `gmega.asm:901` — `mov	al,byte ptr cs:[0ABh][bx]` |
| `0x2008` | `drv_palette_push`, `gfx_render_b_fn` | 5 | `200FIGHT.asm:479` — `call	word ptr cs:[2008h]` |
| `0x00E6` | `stat_XE6` | 5 | `200FIGHT.asm:481` — `test	byte ptr ds:[0E6h],0FFh` |
| `0x009E` | `ANIM_9E`, `cur_magic_idx`, `stat_X9E` | 5 | `200FIGHT.asm:1673` — `mov	al,byte ptr ds:[9Eh]` |
| `0x2004` | `gfx_draw_tile_fn`, `gfx_set_color_fn` | 5 | `200FIGHT.asm:1937` — `call	word ptr cs:[2004h]` |
| `0xE208` | `anim_ptr_6` | 4 | `gmcga.asm:1235` — `add	ax,ds:[0E208h]` |
| `0xE204` | `anim_ptr_5` | 4 | `gmcga.asm:1243` — `add	ax,ds:[0E204h]		; + sprite base B in game segment` |
| `0x00C6` | `stat_XC6` | 4 | `200FIGHT.asm:2579` — `mov	ax,word ptr ds:[0C6h]` |
| `0x2002` | `drv_screen_init_a`, `gfx_clear_fn` | 4 | `200FIGHT.asm:2763` — `call	word ptr cs:[2002h]` |
| `0x0024` | `sprite_record_size` | 4 | `212ARMRP.asm:196` — `test	byte ptr ds:[24h],2` |
| `0xA7BA` | `lega_phase_dir_b` | 3 | `314LEGA.asm:392` — `mov	byte ptr ds:[0A7BAh],al` |
| `0x200E` | `gfx_load_img_fn` | 3 | `200FIGHT.asm:1913` — `call	word ptr cs:[200Eh]` |
| `0x0098` | `ANIM_98`, `char_speed`, `stat_X98` | 3 | `200FIGHT.asm:4100` — `test	byte ptr ds:[98h],0FFh` |
| `0x009B` | `ANIM_9B`, `stat_X9B` | 3 | `200FIGHT.asm:6461` — `mov	byte ptr ds:[9Bh],0FFh` |
| `0x0096` | `ANIM_96`, `char_exp_cap`, `stat_X96` | 3 | `212ARMRP.asm:344` — `mov	ax,word ptr ds:[96h]` |
| `0x00A0` | `ANIM_A0`, `SCR_ATTR_RST`, `cga_col_stride`, `char_width_half`, `gvar_roka_scene`, `stat_XA0`, `tga_row_stride` | 2 | `game.asm:450` — `test	byte ptr ds:[0A0h],0FFh` |
| `0x8E8D` | `zela_ext_byte_b` | 2 | `312ZELA.asm:203` — `add	cl,byte ptr ds:[8E8Dh][si]	; final mis-decoded insn before cell-records cont` |
| `0x2010` | `drv_load_msg_header`, `gfx_draw_map_fn` | 2 | `200FIGHT.asm:460` — `call	word ptr cs:[2010h]` |
| `0x2016` | `drv_frame_commit`, `gfx_render_d_fn` | 2 | `200FIGHT.asm:475` — `call	word ptr cs:[2016h]` |
| `0x2014` | `bank_drv_2014`, `gfx_render_c_fn` | 2 | `200FIGHT.asm:480` — `call	word ptr cs:[2014h]` |
| `0x0099` | `ANIM_99`, `char_power`, `stat_X99` | 2 | `200FIGHT.asm:4115` — `test	byte ptr ds:[99h],0FFh` |
| `0xFF75` | `gvar_spawn_fx_flag`, `gvar_volume`, `gvar_volume_b`, `mao1_gvar_state_byte`, `mao2_gvar_phase_byte` | 2 | `200FIGHT.asm:6303` — `mov	byte ptr ds:[0FF75h],12h` |
| `0x00E4` | `key_count`, `stat_XE4` | 2 | `200FIGHT.asm:7823` — `mov	cl,byte ptr ds:[0E4h]` |
| `0x9302` | `zela_ext_byte_c` | 1 | `312ZELA.asm:189` — `xchg	byte ptr ds:[9302h][bx],al` |
| `0xA2A1` | `zela_ext_far_d` | 1 | `312ZELA.asm:193` — `add	bl,byte ptr ds:[0A2A1h]` |
| `0x8802` | `zela_ext_word_a` | 1 | `312ZELA.asm:194` — `mov	word ptr ds:[8802h],ax` |
| `0x200C` | `fight_cb_prep` | 1 | `200FIGHT.asm:467` — `call	word ptr cs:[200Ch]` |
| `0x2012` | `drv_screen_init_b`, `gfx_draw_player_fn` | 1 | `200FIGHT.asm:471` — `call	word ptr cs:[2012h]` |
| `0x2006` | `drv_fn_palette_a`, `gfx_render_a_fn` | 1 | `200FIGHT.asm:478` — `call	word ptr cs:[2006h]` |
| `0x202A` | `drv_fn_draw_str`, `gfx_draw_str_fn`, `gfx_fn_clear`, `mao1_drv_blit_render` | 1 | `200FIGHT.asm:2935` — `call	word ptr cs:[202Ah]` |
| `0x2022` | `bos_var_25e`, `cga_dispatch_fn`, `drv_render_char`, `gfx_draw_char_fn`, `gfx_fn_setup`, `hgc_dispatch_fn` | 1 | `200FIGHT.asm:2985` — `call	word ptr cs:[2022h]` |
| `0x201A` | `drv_fn_13`, `gfx_draw_icon_b_fn`, `gfx_present_fn` | 1 | `200FIGHT.asm:3180` — `call	word ptr cs:[201Ah]` |
| `0xFF3A` | `flag_riding`, `gvar_music_c`, `gvar_music_flag_c` | 1 | `200FIGHT.asm:3688` — `mov	byte ptr ds:[0FF3Ah],0` |
| `0x3028` | `gfx_decode_fn`, `gfx_sprite_fn` | 1 | `200FIGHT.asm:3699` — `call	word ptr cs:[3028h]` |
| `0x301E` | `drv_fn2_cursor_draw`, `gfx_sel_scroll_up_fn` | 1 | `200FIGHT.asm:3714` — `call	word ptr cs:[301Eh]` |
| `0x0504` | `screen_start_off` | 1 | `200FIGHT.asm:5513` — `add	ax,word ptr ds:[504h]` |
| `0x2018` | `drv_anim_step`, `gfx_draw_icon_a_fn` | 1 | `200FIGHT.asm:5574` — `call	word ptr cs:[2018h]` |
| `0x3004` | `gfx_draw_fn`, `gfx_update_fn` | 1 | `200FIGHT.asm:6466` — `call	word ptr cs:[3004h]` |
| `0x201C` | `drv_fn_14`, `gfx_call_a`, `gfx_render_scene_fn` | 1 | `200FIGHT.asm:6470` — `call	word ptr cs:[201Ch]` |
| `0x009C` | `ANIM_9C`, `stat_X9C` | 1 | `200FIGHT.asm:6585` — `mov	byte ptr ds:[9Ch],0FFh` |
| `0x2040` | `drv_return_to_caller`, `gfx_blit_fn` | 1 | `200FIGHT.asm:7956` — `call	word ptr cs:[2040h]` |
| `0x00F0` | `SCR_RESET` | 1 | `202GFEGA.asm:1586` — `add	byte ptr ds:[0F0h],cl` |
| `0x0078` | `timer_wait_feather` | 1 | `202GFEGA.asm:1592` — `add	byte ptr ds:[78h],cl` |
| `0xFF35` | `enemy_counter`, `gvar_frame_cnt`, `gvar_hero_x`, `gvar_save_flag_2` | 1 | `205GFTGA.asm:1625` — `mov	dl,byte ptr ds:[0FF35h]	; enemy_counter` |
| `0x0497` | `dispatch_flag_1` | 1 | `207MOLE.asm:870` — `cmp	ah,byte ptr ds:[497h]	; dispatch_flag_1` |
| `0x0498` | `dispatch_flag_2` | 1 | `207MOLE.asm:886` — `test	byte ptr ds:[498h],0FFh	; dispatch_flag_2 set?` |
| `0x3006` | `gfx_mode_fn`, `gfx_scroll_left_fn`, `gfx_update_fn` | 1 | `211OMOYP.asm:161` — `call	word ptr cs:[3006h]		; loaded gfx driver fn` |
| `0xFF77` | `gvar_volume_b` | 1 | `211OMOYP.asm:162` — `mov	byte ptr cs:[0FF77h],0FFh	; set demo-active flag` |
| `0x6000` | `bos_limit_6000`, `cga_wrap_limit`, `chunk0_base`, `framebuffer_b`, `game_data_base`, `gvar_game_seg_b`, `hgc_bank1_end`, `hgc_bank_bdy`, `hgc_bank_size`, `hgc_wrap_limit`, `loaded_code_b`, `tile_bank2_base`, `tile_src_a`, `vga_limit` | 1 | `211OMOYP.asm:163` — `jmp	word ptr ds:[6000h]		; jump into loaded enddemo` |
| `0x009F` | `ANIM_9F`, `stat_X9F` | 1 | `106TOWN.asm:313` — `mov	byte ptr ds:[9Fh],al` |
| `0x009A` | `ANIM_9A`, `char_abilities`, `stat_X9A` | 1 | `106TOWN.asm:1011` — `mov	byte ptr ds:[9Ah],0FFh` |