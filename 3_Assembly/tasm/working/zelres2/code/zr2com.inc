;==========================================================================
;
;  zr2com.inc - Shared runtime addresses for zelres2 chunks
;
;  Each chunk in zelres2 is loaded into the game segment at runtime by
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
map_scroll_col          equ     80h     ; cavern X scroll column, 16-bit (canonical in stdply.inc)
map_scroll_row          equ     82h     ; cavern Y scroll row (canonical in stdply.inc)
town_player_col         equ     83h     ; player screen column in town (canonical in stdply.inc)
fight_player_col        equ     84h     ; player screen column in fight (canonical in stdply.inc)
player_gold_hi          equ     85h     ; gold high byte (24-bit) (canonical in stdply.inc)
player_gold_lo          equ     86h     ; gold low byte (canonical in stdply.inc)
player_gold_mid         equ     87h     ; gold low word's high byte (canonical in stdply.inc)
player_bank_hi          equ     88h     ; banked-gold high byte (canonical in stdply.inc)
player_bank_lo          equ     89h     ; banked-gold low word (canonical in stdply.inc)
player_almas            equ     8Bh     ; alt currency (16-bit) (canonical in stdply.inc)
item_qty_count          equ     8Dh     ; item quantity counter (canonical in stdply.inc)
item_effect_val         equ     8Eh     ; item effect value (16-bit) (canonical in stdply.inc)
player_HP               equ     90h     ; current HP (16-bit) (canonical in stdply.inc)
equipped_weapon         equ     92h     ; equipped weapon idx (canonical in stdply.inc)
shield_type             equ     93h     ; shield tier (canonical in stdply.inc; gates apply_combat_damage_with_absorb)
shield_HP               equ     94h     ; current shield HP, 16-bit (canonical in stdply.inc)
shield_max_HP           equ     96h     ; shield max HP cap, 16-bit (canonical in stdply.inc)
player_speed            equ     98h     ; character speed stat (canonical in stdply.inc)
player_power            equ     99h     ; character power stat (canonical in stdply.inc)
weap_dur_cur            equ     0ABh    ; per-weapon durability table base (7 bytes; canonical in stdply.inc)
weap_dur_max            equ     0B4h    ; weapon durability max table base (7 bytes; canonical in stdply.inc)
cur_weapon_idx          equ     9Dh     ; cached selected weapon idx (canonical in stdply.inc)
cur_magic_idx           equ     9Eh     ; currently selected magic idx (canonical in stdply.inc)
player_hp_max           equ     0B2h    ; HP ceiling (canonical in stdply.inc; overlays anim_color_lut)
player_facing           equ     0C2h    ; facing/anim flag bits (canonical in stdply.inc; 80+ uses)
player_level            equ     0C4h    ; level/area number (canonical in stdply.inc)
stat_XC5                equ     0C5h    ; placeholder — byte field used by 200FIGHT (set 0x80, read as ah)
player_tileset          equ     0C8h    ; level tileset index (canonical in stdply.inc)
key_count               equ     0E4h    ; player's collected-key count (canonical in stdply.inc)

; ----------------------------------------------------------------------
; stick.bin dispatch slots installed at game_seg:0x010C-0x0120
; (function pointers populated by stick.bin's driver_init_data block)
; ----------------------------------------------------------------------
; stick.bin dispatch slots — function pointers to procs in stick.asm.
; Each slot fires when gvar_timer_counter (FF18) hits a specific value
; (these are INT 60h game-state subfunction handlers).
sar_loader_fn               equ 10Ch ; SAR chunk loader entry (stick.asm cs:0x0A84)
stick_exit_dlg_handler      equ 110h ; -> exit_dlg_handler (timer==0x14)
stick_pause_dlg_handler     equ 112h ; -> pause-menu handler (timer&8)
stick_speed_change_handler  equ 114h ; -> speed_change_handler (timer&0x8000)
stick_joy_cal_handler       equ 116h ; -> joy_cal_handler (timer==0x104)
stick_joy_detect_handler    equ 118h ; -> joy_detect_handler (timer==0x804)
stick_subsample_tick_handler equ 11Ah ; -> update_subsample_accumulator (per-tick)
stick_savefile_scan_handler equ 11Ch ; -> scan_savefile_dir
stick_restore_dlg_handler   equ 11Eh ; -> restore_game_confirm_dlg (timer==0x4000)
stick_joy_poll_handler      equ 120h ; -> poll_joystick_buttons
; 0x9A..0x9C: 3-byte player_abilities table (canonical in stdply.inc).
; 201SELCT draw_abilities iterates the 3 bytes.  Each slot's specific
; ability is TBD (see AUDIT_TODO.md).
player_ability_1        equ     09Ah    ; ability slot 1
player_ability_2        equ     09Bh    ; ability slot 2 (212ARMRP gates trade dialog on this; that's one specific consequence of the ability)
player_ability_3        equ     09Ch    ; ability slot 3 (set by 200FIGHT entity_fn_e_4 on 9AF3)
boss_intro_flag         equ     0C3h    ; boss intro-side flag (canonical in stdply.inc)
heal_pulse_count        equ     0C6h    ; HP heal-pulse counter, 16-bit (canonical in stdply.inc)
scene_trans_request     equ     0E6h    ; scene-transition request (canonical in stdply.inc)
gvar_pose_idx           equ     0E7h    ; player pose state (canonical in stdply.inc)
init_complete_flag      equ     0E8h    ; post-init steady-state (canonical in stdply.inc)

; ----------------------------------------------------------------------
; Driver dispatch slots (CS-relative, far call via [cs:NNNNh])
; Each slot N (= function index N) is at offset 0x2000 + N*2.
; ----------------------------------------------------------------------
drv_fill_rect            equ     2000h         ; fn  0: fill rectangle
drv_screen_init_a        equ     2002h         ; fn  1: screen/work-area init A
drv_fn_2                 equ     2004h         ; fn  2: (TBD)
drv_fn_3                 equ     2006h         ; fn  3: (TBD)
drv_palette_push         equ     2008h         ; fn  4: palette push / refresh
drv_fn_5                 equ     200Ah         ; fn  5: (TBD)
drv_fn_6                 equ     200Ch         ; fn  6: (TBD)
drv_fn_7                 equ     200Eh         ; fn  7: (TBD)
drv_load_msg_header      equ     2010h         ; fn  8: load/draw message header
drv_screen_init_b        equ     2012h         ; fn  9: screen init B
drv_fn_10                equ     2014h         ; fn  A: (TBD)
drv_frame_commit         equ     2016h         ; fn  B: commit/wait refresh
drv_anim_step            equ     2018h         ; fn  C: advance animation / palette upd
drv_fn_13                equ     201Ah         ; fn  D: (TBD)
drv_fn_14                equ     201Ch         ; fn  E: (TBD)
drv_fn_21                equ     202Ah         ; fn 15: (TBD)
drv_fn_22                equ     202Ch         ; fn 16: (TBD)
; 0x2022, 0x2026, 0x2028, 0x202A: multi-purpose driver-dispatch slots.
; The function pointer at each slot changes when a different graphics
; driver is loaded (gmega/gmcga/gmhgc/gmtga/gmmcga); per-chunk names
; reflect what THAT chunk calls the slot for, all referring to the same
; CS:[NNNNh] far-call indirection.  Not synonyms — context-specific
; labels.  Per-chunk EQUs are kept in their own .asm files so collisions
; with file-local data labels (e.g. 200FIGHT's `gfx_fn_clear dw ...`
; data slot) are avoided.  Only the most-shared canonical is exposed
; here for chunks that don't carry a local name.
drv_render_char          equ     2022h         ; fn 11h: render text char / dialog box (5+ chunks)
drv_return_to_caller     equ     2040h         ; fn 20h: exit / far return
drv_ds_copy              equ     2044h         ; fn 22h: ds copy (cx bytes from si)
; Second driver dispatch table (3000-30xx range)
drv2_fn_2                equ     3004h         ; (TBD — second dispatch table fn 2)
drv_draw_glyph           equ     3016h         ; fn2 B: draw glyph/tile
drv2_fn_15               equ     301Eh         ; (TBD)
drv2_fn_20               equ     3028h         ; (TBD)

; ----------------------------------------------------------------------
; Script interpreter dispatch slots
; ----------------------------------------------------------------------
script_step              equ     6004h         ; next script byte / dispatch
script_format_num        equ     6006h         ; format number dl:ax at di
script_display_page      equ     6008h         ; display next page (CF=cancel)
script_take_item         equ     600Ah         ; take item / price check
script_give_item         equ     600Ch         ; give item / commit transaction

; ----------------------------------------------------------------------
; Game state globals (DS:0xFFxx)
; ----------------------------------------------------------------------
gvar_frame_timer         equ     0FF1Ah        ; canonical: frame timer (ISR-incremented)
game_seg                 equ     0FF2Ch        ; 5 files
flag_shadow              equ     0FF2Fh        ; 5 files
sprite_data_ptr          equ     0FF31h        ; 5 files
; 0xFF33: zeliad/zeliard.inc owns this as gvar_save_flag (init=5 by zeliad).
; gf*.asm reads it as anim_speed because the same byte's value (5) ALSO
; tunes graphics-driver animation pacing.  Single byte, dual semantics
; depending on subsystem: save-state-id by core, frames-per-anim by gfx.
gvar_save_flag           equ     0FF33h        ; canonical (save-state slot id; init 5)
anim_speed               equ     0FF33h        ; alias — same byte; gfx interprets the value as anim pacing
flag_equip_b             equ     0FF34h        ; 5 files
enemy_counter            equ     0FF35h        ; 3 files
color_sel                equ     0FF36h        ; 5 files
redraw_lock              equ     0FF37h        ; 5 files
flag_shield              equ     0FF38h        ; 5 files
flag_climbing            equ     0FF39h        ; 5 files
flag_riding              equ     0FF3Ah        ; 5 files
equip_byte               equ     0FF3Dh        ; 5 files
hero_frame               equ     0FF3Fh        ; 5 files
flag_hero_state          equ     0FF40h        ; 5 files
weapon_state             equ     0FF41h        ; 5 files
shield_sel               equ     0FF42h        ; 5 files
scroll_active            equ     0FF43h        ; 5 files
restore_pending          equ     0FF44h        ; 5 files
scroll_phase             equ     0FF45h        ; 5 files
scroll_step              equ     0FF46h        ; 5 files
gvar_script_ip           equ     0FF4Ch        ; canonical: current script ptr (word)
gvar_script_ptr          equ     0FF4Ch        ; alias
gvar_state_ptr           equ     0FF4Ch        ; alias
script_cur_ptr           equ     0FF4Ch        ; alias
gvar_text_x              equ     0FF4Eh        ; canonical: text/state flag A byte
gvar_init_flag_a         equ     0FF4Eh        ; alias
gvar_state_flg1          equ     0FF4Eh        ; alias
shop_flag_a              equ     0FF4Eh        ; alias
gvar_text_y              equ     0FF4Fh        ; canonical: text/state flag B byte
gvar_init_flag_b         equ     0FF4Fh        ; alias
gvar_state_flg2          equ     0FF4Fh        ; alias
shop_flag_b              equ     0FF4Fh        ; alias
gvar_timer_word          equ     0FF50h        ; canonical: menu/credits timer (word)
gvar_credits_pos         equ     0FF50h        ; alias
gvar_menu_step           equ     0FF50h        ; alias
menu_frame_timer         equ     0FF50h        ; alias
gvar_dlg_cols            equ     0FF52h        ; canonical: dialog window columns byte
gvar_col_byte            equ     0FF52h        ; alias
gvar_name_maxlen         equ     0FF52h        ; alias
menu_item_count          equ     0FF52h        ; alias
gvar_dlg_rows            equ     0FF53h        ; canonical: dialog window rows byte
gvar_name_opt            equ     0FF53h        ; alias
gvar_row_byte            equ     0FF53h        ; alias
inventory_count          equ     0FF53h        ; alias
gvar_dlg_pos             equ     0FF54h        ; canonical: dialog window position word
gvar_ui_dst_word         equ     0FF54h        ; alias
gvar_ui_pos              equ     0FF54h        ; alias
menu_pos_base            equ     0FF54h        ; alias
; 0xFF68: multi-purpose word — see zr1com.inc for canonical comment.
; 212ARMRP uses a placeholder name; 215DRUGP uses `menu_col_width`.
gvar_text_ofs            equ     0FF68h        ; canonical
menu_col_width           equ     0FF68h        ; alias — menu column width (215DRUGP)
gvar_ff68                equ     0FF68h        ; alias — placeholder (212ARMRP)
; 0xFF75: zeliard.inc owns gvar_volume_b as canonical (63 refs across
; the codebase — audio mix level, written by every subsystem to bump the
; current mix).  zelres3 enemy chunks use the same byte as
; `gvar_spawn_fx_flag` (39 refs in zr3com.inc) to trigger spawn effects;
; functionally the same write — different value triggers different
; downstream audio behaviour.  zr2com's `gvar_volume` is just an alias.
gvar_volume_b            equ     0FF75h        ; canonical (audio mix level; zeliard.inc)
gvar_volume              equ     0FF75h        ; alias (3 zelres2 chunks)

; ----------------------------------------------------------------------
; Game data (DS:0xC000-0xEFFF)
; ----------------------------------------------------------------------
entity_list_ptr          equ     0C00Ah        ; 2 files
sprite_attr_base         equ     0C010h        ; 5 files
sprite_attr_b            equ     0C012h        ; 5 files
pattern_base             equ     0E000h        ; 5 files
sprite_buf               equ     0E900h        ; 5 files
sprite_buf_b             equ     0E91Bh        ; 5 files
char_lookup              equ     0ED20h        ; 5 files
projectile_list          equ     0EDA0h        ; 5 files

; ----------------------------------------------------------------------
; Constants / control codes
; ----------------------------------------------------------------------
sprite_src_b             equ     0A030h        ; 3 files
sprite_gfx_base          equ     4000h         ; 5 files
game_data_base           equ     6000h         ; 5 files
sprite_lookup_base       equ     625Ch         ; 5 files
sprite_buf_ofs           equ     8000h         ; 3 files
bg_copy_dst              equ     9350h         ; 2 files

