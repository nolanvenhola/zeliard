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
; Driver dispatch (drv_*)
; ----------------------------------------------------------------------
drv_fill_rect            equ     2000h         ; 3 files
drv_fn_dispatch          equ     2000h         ; 2 files
gfx_fill_rect            equ     2000h         ; 2 files
drv_screen_init_a        equ     2002h         ; 3 files
gfx_init_a               equ     2002h         ; 2 files
drv_load_msg_header      equ     2010h         ; 3 files
drv_screen_init_b        equ     2012h         ; 3 files
gfx_init_b               equ     2012h         ; 2 files
drv_frame_commit         equ     2016h         ; 2 files
gfx_wait_refresh         equ     2016h         ; 2 files
drv_return_to_caller     equ     2040h         ; 3 files
gfx_return               equ     2040h         ; 2 files
drv_ds_copy              equ     2044h         ; 3 files
gfx_copy_buffer          equ     2044h         ; 2 files
draw_glyph_tile          equ     3016h         ; 2 files
drv_draw_glyph           equ     3016h         ; 3 files

; ----------------------------------------------------------------------
; Game state globals (DS:0xFFxx)
; ----------------------------------------------------------------------
frame_timer              equ     0FF1Ah        ; 5 files
gvar_timer_byte          equ     0FF1Ah        ; 2 files
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
gvar_script_ip           equ     0FF4Ch        ; 2 files
gvar_script_ptr          equ     0FF4Ch        ; 3 files
gvar_init_flag_a         equ     0FF4Eh        ; 3 files
gvar_text_x              equ     0FF4Eh        ; 2 files
gvar_init_flag_b         equ     0FF4Fh        ; 3 files
gvar_text_y              equ     0FF4Fh        ; 2 files
gvar_menu_step           equ     0FF50h        ; 2 files
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
script_read_byte         equ     6004h         ; 2 files
sprite_lookup_base       equ     625Ch         ; 5 files
sprite_buf_ofs           equ     8000h         ; 3 files
bg_copy_dst              equ     9350h         ; 2 files

