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
town_player_col         equ     83h     ; player screen column in town (canonical in stdply.inc)
hero_bank_hi            equ     88h     ; banked-gold high byte (canonical in stdply.inc)
hero_bank_lo            equ     89h     ; banked-gold low word (canonical in stdply.inc)
trade_marker_flag       equ     09Bh    ; trade-event marker (canonical in stdply.inc)
boss_intro_flag         equ     0C3h    ; boss intro-side flag (canonical in stdply.inc)
heal_pulse_count        equ     0C6h    ; HP heal-pulse counter, 16-bit (canonical in stdply.inc)
scene_trans_request     equ     0E6h    ; scene-transition request (canonical in stdply.inc)
gvar_pose_idx           equ     0E7h    ; player pose state (canonical in stdply.inc)
init_complete_flag      equ     0E8h    ; post-init steady-state (canonical in stdply.inc)

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
gvar_state_flag          equ     0FF24h        ; 2 files
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

