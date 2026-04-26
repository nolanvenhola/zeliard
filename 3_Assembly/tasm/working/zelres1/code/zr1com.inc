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
gvar_item_flag           equ     0FF57h        ; 3 files
gvar_text_ofs            equ     0FF68h        ; 3 files
gvar_copy_width          equ     0FF6Ah        ; 3 files
gvar_tile_width          equ     0FF6Ah        ; 2 files

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

