;==========================================================================
;
;  zr1com.inc - Shared runtime addresses for zelres1 chunks
;
;  Each chunk in zelres1 is loaded into the game segment at runtime by
;  the SAR loader.  EQUs below are addresses that >=2 chunks in this
;  archive reference at the same value -- usually shared driver function
;  pointers, sprite tables, or game-state byte addresses.
;
;==========================================================================

; ----------------------------------------------------------------------
; Player-record fields (DS-relative; canonical home is stdply.inc/asm,
; re-declared here so chunks that don't include stdply.inc can use
; symbolic names instead of raw hex literals).  Value MUST match
; stdply.inc's canonical EQU; TASM accepts duplicate equates with the
; same value.
; ----------------------------------------------------------------------
captured_flag           equ     49h     ; player-captured / game-over gate (200FIGHT)
map_scroll_col          equ     80h     ; cavern X scroll column, 16-bit
map_scroll_row          equ     82h     ; cavern Y scroll row
town_player_col         equ     83h     ; player screen column in town (canonical in stdply.inc)
fight_player_col        equ     84h     ; player screen column in fight
player_gold_hi          equ     85h     ; gold high byte (24-bit field)
player_gold_lo          equ     86h     ; gold low byte
player_gold_mid         equ     87h     ; gold low word's high byte
player_bank_hi          equ     88h     ; banked-gold high byte (canonical in stdply.inc)
player_bank_lo          equ     89h     ; banked-gold low word (canonical in stdply.inc)
player_almas            equ     8Bh     ; alt currency (16-bit)
item_qty_count          equ     8Dh     ; item quantity counter
item_effect_val         equ     8Eh     ; item effect value (16-bit)
player_HP               equ     90h     ; current HP (16-bit)
equipped_weapon         equ     92h     ; equipped weapon idx (1-based; 0 = none)
shield_type             equ     93h     ; shield tier (1-based; 0 = no shield)
shield_HP               equ     94h     ; current shield HP (16-bit)
shield_max_HP           equ     96h     ; shield max HP cap (16-bit)
player_speed            equ     98h     ; character speed stat
player_power            equ     99h     ; character power stat
; Crests (3 boolean possessions, validated against playthrough §6.4 + 17 saves):
crest_elf               equ     09Ah    ; Elf Crest (set after defeating Paguro)
player_ability_1        equ     09Ah    ; alias — earlier name
crest_glory             equ     09Bh    ; Glory Crest (Cementar pickup; consumed by Tumba shop trade for Knight's Sword)
player_ability_2        equ     09Bh    ; alias — earlier name
crest_hero              equ     09Ch    ; Hero's Crest (Cavern of Riza pickup; required to encounter Pollo)
player_ability_3        equ     09Ch    ; alias — earlier name
; 0x9D = currently selected spell ID (user-corrected; not weapon-related).
selected_spell          equ     9Dh     ; currently chosen spell ID (0=none, 1..7)
weapon_tier_max         equ     9Dh     ; alias — earlier (wrong) name
cur_weapon_idx          equ     9Dh     ; alias — earlier (wrong) name
; 0x9E = currently equipped wearable ID (0..5 per wear_* enum).
selected_wearable       equ     9Eh     ; equipped shoe-or-cape ID
stat_X9E                equ     9Eh     ; alias — earlier placeholder
cur_magic_idx           equ     9Eh     ; alias — earlier (wrong) name
stat_X9F                equ     9Fh     ; VESTIGIAL placeholder (per-frame zero-clear, no reader observed)
weap_dur_cur            equ     0ABh    ; per-weapon durability table base (7 bytes)
player_hp_max           equ     0B2h    ; HP ceiling (overlays anim_color_lut frame 8)
weap_dur_max            equ     0B4h    ; weapon durability max table base (7 bytes)
player_facing           equ     0C2h    ; facing/anim flag bits (canonical in stdply.inc; 80+ uses)
boss_intro_flag         equ     0C3h    ; boss intro-side flag (canonical in stdply.inc)
current_area_id         equ     0C4h    ; current area (high bit=in-town, low 7=town/sage idx 1..8); Kioku Feather destination
player_level            equ     0C4h    ; alias — earlier name (was misnomer)
heal_pulse_count        equ     0C6h    ; HP heal-pulse counter, 16-bit (canonical in stdply.inc)
player_tileset          equ     0C8h    ; level tileset index
key_count               equ     0E4h    ; player's collected-key count
scene_trans_request     equ     0E6h    ; scene-transition request (canonical in stdply.inc)
gvar_pose_idx           equ     0E7h    ; player pose state (canonical in stdply.inc)
init_complete_flag      equ     0E8h    ; post-init steady-state (canonical in stdply.inc)

; ----------------------------------------------------------------------
; stick.bin dispatch slots installed at game_seg:0x010C-0x0120 — function
; pointers in stick.bin's driver_init_data block.  Each slot points to a
; proc in stick.asm that fires when gvar_timer_counter (FF18) hits a
; specific value (these are INT 60h game-state subfunction handlers).
; ----------------------------------------------------------------------
sar_loader_fn               equ 10Ch ; SAR chunk loader entry (cs:0x0A84)
stick_exit_dlg_handler      equ 110h ; -> exit_dlg_handler (stick.asm:816, fires on timer==0x14)
stick_pause_dlg_handler     equ 112h ; -> pause-menu handler (stick.asm:~863, fires on timer&8)
stick_speed_change_handler  equ 114h ; -> speed_change_handler (stick.asm:934, fires on timer&0x8000)
stick_joy_cal_handler       equ 116h ; -> joy_cal_handler (stick.asm:1010, fires on timer==0x104)
stick_joy_detect_handler    equ 118h ; -> joy_detect_handler (stick.asm:1068, fires on timer==0x804)
stick_subsample_tick_handler equ 11Ah ; -> update_subsample_accumulator (stick.asm:~1086, per-tick)
stick_savefile_scan_handler equ 11Ch ; -> scan_savefile_dir (stick.asm:1180)
stick_restore_dlg_handler   equ 11Eh ; -> restore_game_confirm_dlg (stick.asm:1097, fires on timer==0x4000)
stick_joy_poll_handler      equ 120h ; -> poll_joystick_buttons (stick.asm:190)

; ----------------------------------------------------------------------
; Graphics driver dispatch slots (CS-relative, far call via [cs:NNNNh])
; ----------------------------------------------------------------------
drv_fill_rect           equ     2000h   ; fn  0: fill rectangle
drv_screen_init_a       equ     2002h   ; fn  1: screen/work-area init A
drv_fn_2                equ     2004h   ; fn  2: (TBD)
drv_fn_3                equ     2006h   ; fn  3: (TBD)
drv_palette_push        equ     2008h   ; fn  4: palette push / refresh
drv_fn_5                equ     200Ah   ; fn  5: (TBD)
drv_fn_6                equ     200Ch   ; fn  6: (TBD)
drv_fn_7                equ     200Eh   ; fn  7: (TBD)
drv_load_msg_header     equ     2010h   ; fn  8: load/draw message header
drv_screen_init_b       equ     2012h   ; fn  9: screen init B
drv_fn_10               equ     2014h   ; fn  A: (TBD)
drv_frame_commit        equ     2016h   ; fn  B: commit/wait refresh
drv_anim_step           equ     2018h   ; fn  C: advance animation
drv_fn_13               equ     201Ah   ; fn  D: (TBD)
drv_fn_14               equ     201Ch   ; fn  E: (TBD)
drv_render_char         equ     2022h   ; fn 11: render text char / dialog box
drv_fn_21               equ     202Ah   ; fn 15: (TBD)
drv_fn_22               equ     202Ch   ; fn 16: (TBD)
drv_return_to_caller    equ     2040h   ; fn 20: exit / far return
drv_ds_copy             equ     2044h   ; fn 22: ds copy (cx bytes from si)

; ----------------------------------------------------------------------
; Game state globals (DS:0xFFxx) - canonical in zeliard.inc
; ----------------------------------------------------------------------
gvar_frame_timer        equ     0FF1Ah  ; frame timer (canonical, ISR-incremented)

; ----------------------------------------------------------------------
; Hardware segments
; ----------------------------------------------------------------------
sprite_obj_tbl           equ     0A000h        ; 5 files
vga_seg                  equ     0A000h        ; 5 files

; ----------------------------------------------------------------------
; Driver dispatch (drv_*)
; ----------------------------------------------------------------------
cga_plane_stride         equ     2A80h         ; 2 files
ega_plane_stride         equ     2A80h         ; 2 files

; ----------------------------------------------------------------------
; Game state globals (DS:0xFFxx)
; ----------------------------------------------------------------------
; FF24: scene-mode byte.  Written across 4 chunks with distinct values:
;   100OPDMO: 8    (opening cinematic → gameplay transition)
;   106TOWN:  4    (entering shop, door_type_shop)
;   200FIGHT: 0Ah  (combat init), 8 (fade_out)
;   201SELCT: 8    (item-select screen, "set before save")
; No readers in any cleaned chunk — likely consumed by zeliad.exe's save
; handler to know which scene to restore.  Was misnamed gvar_state_flag /
; gvar_state_FF24 / gvar_display_mode in earlier passes.
gvar_scene_mode          equ     0FF24h        ; scene/mode indicator (save-state); written before each scene transition
gvar_state_flag          equ     0FF24h        ; alias — earlier name
gvar_map_ptr             equ     0FF2Ah        ; 4 files
; 0xFF57: shared menu/selection state byte used differently per chunk.
; 106TOWN and town shops set/clear it during selection ('gvar_sel_flag'
; semantic, 4 refs); 215DRUGP uses it as buy-mode toggle ('flag_buy_mode',
; 3 refs); 107GTEGA tests it during item display ('gvar_item_flag', 3 refs);
; 213BANKP treats it as misc UI byte.  No single canonical role; the byte
; is multi-purpose menu state.  Keep `gvar_sel_flag` (most-common, also
; in 106TOWN/212ARMRP) as primary but acknowledge the others as valid.
gvar_sel_flag            equ     0FF57h        ; canonical: shared menu/selection state
gvar_item_flag           equ     0FF57h        ; alias — used by item-display contexts
; 0xFF68: multi-purpose word.  108GTCGA reads it as `gvar_char_y_ofs`
; (character Y row offset), 111GTMCA as `gvar_scroll_idx` (scroll index
; word), 212ARMRP as a placeholder `gvar_ff68`, 215DRUGP as
; `menu_col_width`.  3+ chunks read it as `gvar_text_ofs` (text/state
; offset).  Same byte used for different per-context purposes; canonical
; is `gvar_text_ofs` (most generic), per-chunk semantic names retained.
gvar_text_ofs            equ     0FF68h        ; canonical (most-common semantic)
gvar_char_y_ofs          equ     0FF68h        ; alias — char Y row offset (108GTCGA)
gvar_scroll_idx          equ     0FF68h        ; alias — scroll idx (111GTMCA)
menu_col_width           equ     0FF68h        ; alias — menu column width (215DRUGP)
; 0xFF6A: shared word-sized state.  106TOWN/212ARMRP read it as
; gvar_dlg_timer (8 refs — dialog display delay); 107GTEGA writes it
; as gvar_copy_width (7 refs — graphics copy width); 108GTCGA as
; gvar_tile_width (4 refs).  Multi-purpose word; pick gvar_dlg_timer
; as canonical (most-used semantic) and acknowledge graphics aliases.
gvar_dlg_timer           equ     0FF6Ah        ; canonical: dialog display timer / multi-purpose word
gvar_copy_width          equ     0FF6Ah        ; alias — gfx copy width (107GTEGA et al)
gvar_tile_width          equ     0FF6Ah        ; alias — tile width (108GTCGA)

; ----------------------------------------------------------------------
; Game data (DS:0xC000-0xEFFF)
; ----------------------------------------------------------------------
tile_list_ptr            equ     0C00Fh        ; 3 files
marker_buf               equ     0E005h        ; 3 files

; ----------------------------------------------------------------------
; Constants / control codes
; ----------------------------------------------------------------------
font_ctrl_byte           equ     0BF07h        ; 2 files
tile_mask_data           equ     0D000h        ; 2 files
; NOTE: `font_ptr_a` is NOT shared — GD drivers (101-105) use 0F500h
; while GT drivers (107-111) use 0F502h; kept per-file to avoid
; redefinition.  Corresponding GT `font_ptr_b` at 0F504h likewise per-file.
ega_row_w                equ     140h          ; 2 files
scroll_plane2_off        equ     14EEh         ; 2 files
sprite_plane_b_off       equ     1A6Eh         ; 5 files
cga_plane2_off           equ     240h          ; 3 files
hscroll_plane_off        equ     3CDh          ; 2 files
tile_src_b               equ     4100h         ; 2 files
tile_src_a               equ     6000h         ; 2 files
bios_crt_port_off        equ     63h           ; 2 files
tileset_buf_a            equ     8000h         ; 3 files
tileset_buf_b            equ     8004h         ; 3 files
tile_pixel_base          equ     8100h         ; 3 files

; Other
cga_buf_start            equ     0             ; 2 files
zero_offset              equ     0             ; 4 files

; --- Canonical player-record EQUs (mirrored from stdply.inc for chunk-side use) ---
player_almas_hi                equ     08Ch
hero_level                     equ     08Dh
experience                     equ     08Eh
keys_normal                    equ     098h
keys_lion                      equ     099h
tears_of_esmesanti_count       equ     0A0h
wear_1                         equ     0A1h
wear_2                         equ     0A2h
wear_3                         equ     0A3h
wear_4                         equ     0A4h
wear_5                         equ     0A5h
item_slot_1                    equ     0A6h
save_sage                      equ     0C4h
last_sage_visited              equ     0C5h
current_level_idx              equ     0C8h
sages_spoken                   equ     0E5h

