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
; Driver dispatch slots (CS-relative, far call via [cs:NNNNh])
; ----------------------------------------------------------------------
drv_fill_rect            equ     2000h         ; fn  0: fill rectangle
drv_screen_init_a        equ     2002h         ; fn  1: screen/work-area init A
drv_palette_push         equ     2008h         ; fn  4: palette push / refresh
drv_load_msg_header      equ     2010h         ; fn  8: load/draw message header
drv_screen_init_b        equ     2012h         ; fn  9: screen init B
drv_frame_commit         equ     2016h         ; fn  B: commit/wait refresh
drv_anim_step            equ     2018h         ; fn  C: advance animation / palette upd
drv_render_char          equ     2022h         ; fn 11h: render text char / dialog box
drv_return_to_caller     equ     2040h         ; fn 20h: exit / far return
drv_ds_copy              equ     2044h         ; fn 22h: ds copy (cx bytes from si)
drv_draw_glyph           equ     3016h         ; fn2 B: draw glyph/tile

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
frame_timer              equ     0FF1Ah        ; alias
gvar_timer_byte          equ     0FF1Ah        ; alias
gvar_timer_lo            equ     0FF1Ah        ; alias
gvar_timer_ticks         equ     0FF1Ah        ; alias
game_seg                 equ     0FF2Ch        ; 5 files
flag_shadow              equ     0FF2Fh        ; 5 files
sprite_data_ptr          equ     0FF31h        ; 5 files
anim_speed               equ     0FF33h        ; 5 files
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
gvar_volume              equ     0FF75h        ; 2 files

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

