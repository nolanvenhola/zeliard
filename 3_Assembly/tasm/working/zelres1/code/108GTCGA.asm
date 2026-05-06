
PAGE  59,132

;==========================================================================
;
;  108GTCGA - Town Tiles CGA Renderer (zelres1 chunk 9, gtcga.bin)
;
;  CGA-specific tilemap renderer for the town/overworld engine. Loaded
;  by game.bin into the game segment (gfx_mode_tbl_all entries, modes 1
;  and 2) alongside 106TOWN (town.bin). Provides tile blit, scroll,
;  character cell rendering, and text-glyph functions exposed via
;  dispatch slots consumed by 106TOWN.
;
;  Connections:
;    Loads:        none (rendering primitives only)
;    Calls into:   render_fn_tbl_* (CS dispatch tables, set internally
;                  per tile type)
;    Called by:    game.bin LOAD_CHUNK chunk_ref_gtcga via gfx_mode_tbl_all
;                  (gfx-driver init at loaded_code_a CS:0x3000); 106TOWN
;                  invokes gfx_draw_tile/draw_player/render_*/scroll_*/
;                  text_layout/draw_str/draw_char etc. through this chunk
;    Reads/writes: gvar_game_seg (FF2C) [zeliad-owned]; tile flag bytes
;                  in town-owned segment range
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr1com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
gvar_game_seg		equ	0FF2Ch			;*  global: game data segment selector
gvar_scroll_flag	equ	0FF57h			;*  global: scroll/redraw flag

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
; restored after factoring (different value than zr1com.inc would supply):
font_ptr_a               equ     0F502h
font_ptr_b               equ     0F504h
tile_subst_tbl_ptr	equ	8004h			;* pointer to tile substitution table
tile_pixels		equ	8100h			;* tile pixel source data base
cga_tile_dest_ofs	equ	127Ch			;*  CGA tile blit destination offset
dispatch_init_tbl	equ	2135h			;*  init dispatch word-pair table
dispatch_tbl_a		equ	3568h			;*  draw-cell dispatch table A
dispatch_tbl_b		equ	35C4h			;*  draw-cell dispatch table B
tile_gfx_data		equ	3811h			;*  tile graphics row data
status_buf		equ	39B3h			;*  time/status display buffer (7 bytes)
anim_frame_data		equ	39B4h			;*  animation frame data table (byte 1 of status_buf)
tile_render_disp	equ	3C04h			;*  tile type render dispatch table
color_lut		equ	3D0Bh			;*  color lookup table (bitplane index->CGA color)
tile_col_x		equ	3D6Dh			;*  current tile column x position (word)
tile_char_a		equ	3D70h			;*  tile char slot A (byte)
tile_map_arr		equ	3D71h			;*  tile map working array
tile_char_b		equ	3D73h			;*  tile char slot B (byte, checked for 0FDh)
tile_row_ctr		equ	3D76h			;*  tile row/scan counter (word)
bitplane_0		equ	3D78h			;*  bitplane word 0 for tile color encode
bitplane_1		equ	3D7Ah			;*  bitplane word 1 for tile color encode
bitplane_2		equ	3D7Ch			;*  bitplane word 2 for tile color encode
bitplane_3		equ	3D7Eh			;*  bitplane word 3 (transparent mask)
far_ptr_tmp		equ	3D80h			;*  temporary far pointer (dword)
glyph_buf		equ	3D84h			;*  glyph render working buffer
text_render_dst		equ	3DACh			;*  text glyph render destination
cga_row_buf_a		equ	3F14h			;*  CGA tile row buffer A
cga_row_buf_b		equ	3F74h			;*  CGA tile row buffer B
cga_row_buf_c		equ	3FA4h			;*  CGA tile row buffer C
cga_wrap_si		equ	3FB0h			;*  CGA interleave wrap add for SI
tile_cache		equ	3FD4h			;*  tile pixel cache table (indexed by tile id)
entity_tbl_ptr		equ	0C00Fh			;*  NPC/entity table pointer
cga_wrap		equ	0C050h			;*  CGA interleave wrap offset (B800:0 -> B800:2000+C050)
hud_status_ptr		equ	0E005h			;*  HUD/status byte pointer
font_data_tbl		equ	0F502h			;*  font glyph data table
font_char_data		equ	0F504h			;*  font character pixel data
cga_hud_ofs_l		equ	23Ch			; CGA HUD area offset left column
cga_hud_ofs_r		equ	273h			; CGA HUD area offset right column
cga_tilemap_b0		equ	163Ch			; CGA tilemap base row 0 even bank
cga_tilemap_b1		equ	1673h			; CGA tilemap base row 1 even bank
cga_tilemap_b2		equ	177Ch			; CGA tilemap base row 2 even bank
cga_tilemap_b3		equ	17B3h			; CGA tilemap base row 3 even bank
cga_wrap_si2		equ	3FB0h			; CGA interleave wrap add for SI (dup of cga_wrap_si)
cga_wrap2		equ	0C050h			; CGA interleave wrap offset (dup of cga_wrap)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
tileset_index		equ	8000h			;* tileset index table (game_seg:8000h)
tile_col_idx		equ	3D6Fh			;*  current tile column counter (byte, 0..1Bh)

; CGA_PIXEL_ADDR
;   Compute CGA byte/bank offset into DI from BL (row).
;   bit0 of BL selects bank (0/2000h); high bits index 80-byte rows.
CGA_PIXEL_ADDR	MACRO
		shr	bl, 1
		sbb	di, di
		and	di, 2000h
		mov	al, 50h
		mul	bl
		add	di, ax
		ENDM
; SET_ES_DS_CGA
;   ES = DS = B800h (set both segments to CGA framebuffer).
SET_ES_DS_CGA	MACRO
		mov	ax, 0B800h
		mov	es, ax
		mov	ds, ax
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

zr1_08		proc	far

start:
;*		aam	11h			; undocumented inst
		db	0D4h, 11h		;  Fixup - byte match
		add	[bx+si],al
		cmc				; Complement carry
		cmp	ch,[bx+si]
		xor	[bx+30h],dl
		ja	copy_tile_word_loop		; Jump if above
;*		aam	36h			; '6' undocumented inst
		db	0D4h, 36h		;  Fixup - byte match
		add	ax,6037h
		aaa				; Ascii adjust
		dec	di
		xor	si,ss:dispatch_init_tbl[bp]
		; Driver dispatch init table: word-pair entries (function_id, handler_offset)
		; Installed by loader into the driver dispatch table at dispatch_init_tbl
		db	 36h, 7Ch, 35h, 8Fh, 37h,0D8h	; dw 7C36h,358Fh,37D8h (dispatch entries)
		db	 37h, 62h, 38h, 23h, 38h, 23h	; dw 3762h,3823h,3823h
		db	 3Ah, 88h, 3Ah, 02h, 39h,0B2h	; dw 3A88h,3A02h,39B2h
		db	 3Bh, 2Fh, 3Bh, 1Eh,0BEh, 3Ch	; dw 3B2Fh,3B1Eh,3CBEh
		db	 0Ch,0BFh, 00h,0A0h, 0Eh, 07h	; dw BF0Ch,A000h,070Eh
		db	0B8h, 00h,0B8h, 8Eh,0D8h,0B9h	; dw 00B8h,8EB8h,B9D8h
		db	 1Ch, 00h				; dw 001Ch

copy_tile_row_outer:
					push	cx
					push	si
					mov	cx,18h

copy_tile_word_loop:
								movsw				; Mov [si] to es:[di]
								add	si,1FFEh
								cmp	si,4000h
								jb	skip_cga_wrap			; Jump if below
								add	si,cga_wrap

skip_cga_wrap:
								loop	copy_tile_word_loop		; Loop if cx > 0

					pop	si
					pop	cx
					inc	si
					inc	si
					loop	copy_tile_row_outer		; Loop if cx > 0

		pop	ds
		retn

; Render all town tile columns (dispatch target: init tile cache, draw all columns)

render_tile_columns:				;* No entry point to code
		push	cs
		pop	es
		mov	di,tile_cache
		xor	ax,ax			; Zero register
		mov	cx,100h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,ds:gvar_map_ptr
		cmp	byte ptr [si+1Dh],0FDh
		jne	skip_init_call			; Jump if not equal
		call	draw_door_init

skip_init_call:
		mov	word ptr ds:tile_col_x,0C3Ch
		mov	si,ds:gvar_map_ptr
		add	si,20h
		push	cs
		pop	es
		mov	di,0E000h
		mov	byte ptr ds:tile_col_idx,0

draw_col_loop:
					call	cga_check_blit_col
					xor	bl,bl			; Zero register
					cmpsb				; Cmp [si] to es:[di]
					jz	skip_draw_0			; Jump if zero
					call	draw_masked_tile

skip_draw_0:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	skip_draw_1			; Jump if zero
					call	draw_masked_tile

skip_draw_1:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	skip_draw_2			; Jump if zero
					call	draw_masked_tile

skip_draw_2:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	skip_draw_3			; Jump if zero
					call	draw_opaque_tile

skip_draw_3:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	skip_draw_4			; Jump if zero
					call	draw_opaque_tile

skip_draw_4:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	skip_draw_5			; Jump if zero
					call	draw_door_tile

skip_draw_5:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	skip_draw_6			; Jump if zero
					call	draw_opaque_tile

skip_draw_6:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	next_col			; Jump if zero
					call	draw_opaque_tile

next_col:
					add	word ptr ds:tile_col_x,2
					inc	byte ptr ds:tile_col_idx
					cmp	byte ptr ds:tile_col_idx,1Ch
					jne	draw_col_loop			; Jump if not equal
		retn

zr1_08		endp

cga_check_blit_col		proc	near
		cmp	byte ptr ds:tile_col_idx,1Bh
		jne	check_col_pos			; Jump if not equal
		retn

check_col_pos:
		mov	al,byte ptr ds:[town_player_col]
		cmp	ds:tile_col_idx,al
		je	blit_tile_col			; Jump if equal
		retn

blit_tile_col:
		push	di
		push	es
		push	si
		mov	al,byte ptr ds:[town_player_col]
		add	al,al
		xor	ah,ah			; Zero register
		mov	di,ax
		add	di,cga_tile_dest_ofs
		mov	ax,0B800h
		mov	es,ax
		mov	si,cga_row_buf_a
		mov	cx,2

blit_tile_pair_loop:
					push	cx
					push	di
					call	blit_3rows_to_cga
					pop	di
					inc	di
					inc	di
					pop	cx
					loop	blit_tile_pair_loop		; Loop if cx > 0

		pop	si
		pop	es
		pop	di
		retn

cga_check_blit_col		endp

draw_door_tile		proc	near
		cmp	byte ptr [si-1],0FDh
		jne	check_tile_state			; Jump if not equal
		jmp	handle_fd_tile

draw_door_tile		endp

draw_opaque_tile	proc	near

check_tile_state:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	do_tile_blit			; Jump if not zero
		retn

do_tile_blit:
		dec	di
		dec	si
		mov	dl,[si]
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		push	dx
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		mov	ax,50h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:tile_col_x
		mov	di,ax
		pop	dx
		mov	bl,dl
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:tile_cache[bx],0FFFFh
		jnz	tile_cached			; Jump if not zero
		mov	ds:tile_cache[bx],di
		mov	ax,10h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,tile_pixels
		mov	ds,cs:gvar_game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	cx,4

copy_tile_row_loop:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	skip_wrap_di_a			; Jump if below
					add	di,cga_wrap2

skip_wrap_di_a:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	skip_wrap_di_b			; Jump if below
					add	di,cga_wrap2

skip_wrap_di_b:
					loop	copy_tile_row_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

tile_cached:
		mov	si,ds:tile_cache[bx]
		SET_ES_DS_CGA
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	skip_wrap_di_c			; Jump if below
		add	di,cga_wrap2

skip_wrap_di_c:
		add	si,1FFEh
		cmp	si,4000h
		jb	skip_wrap_si_c			; Jump if below
		add	si,cga_wrap2

skip_wrap_si_c:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	skip_wrap_di_d			; Jump if below
		add	di,cga_wrap2

skip_wrap_di_d:
		add	si,1FFEh
		cmp	si,4000h
		jb	skip_wrap_si_d			; Jump if below
		add	si,cga_wrap2

skip_wrap_si_d:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	skip_wrap_di_e			; Jump if below
		add	di,cga_wrap2

skip_wrap_di_e:
		add	si,1FFEh
		cmp	si,4000h
		jb	skip_wrap_si_e			; Jump if below
		add	si,cga_wrap2

skip_wrap_si_e:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	skip_wrap_di_f			; Jump if below
		add	di,cga_wrap2

skip_wrap_di_f:
		add	si,1FFEh
		cmp	si,4000h
		jb	skip_wrap_si_f			; Jump if below
		add	si,cga_wrap2

skip_wrap_si_f:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	skip_wrap_di_g			; Jump if below
		add	di,cga_wrap2

skip_wrap_di_g:
		add	si,1FFEh
		cmp	si,4000h
		jb	skip_wrap_si_g			; Jump if below
		add	si,cga_wrap2

skip_wrap_si_g:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	skip_wrap_di_h			; Jump if below
		add	di,cga_wrap2

skip_wrap_di_h:
		add	si,1FFEh
		cmp	si,4000h
		jb	skip_wrap_si_h			; Jump if below
		add	si,cga_wrap2

skip_wrap_si_h:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	skip_wrap_di_i			; Jump if below
		add	di,cga_wrap2

skip_wrap_di_i:
		add	si,1FFEh
		cmp	si,4000h
		jb	skip_wrap_si_i			; Jump if below
		add	si,cga_wrap2

skip_wrap_si_i:
		movsw				; Mov [si] to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

draw_opaque_tile	endp

draw_masked_tile	proc	near
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	lookup_tile_index			; Jump if not zero
		retn

lookup_tile_index:
		push	bx
		push	es
		mov	dl,[si-1]
		mov	bl,dl
		xor	bh,bh			; Zero register
		mov	es,cs:gvar_game_seg
		add	bx,es:tileset_index
		mov	dh,es:[bx]
		pop	es
		pop	bx
		or	dh,dh			; Zero ?
		jnz	do_masked_blit			; Jump if not zero
		jmp	check_tile_state

do_masked_blit:
		dec	di
		dec	si
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		push	dx
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		mov	ax,50h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:tile_col_x
		mov	di,ax
		pop	dx
		mov	ax,10h
		mul	dl			; ax = reg * al
		mov	si,ax
		mov	bp,ax
		add	si,tile_pixels
		add	bp,tile_mask_data
		mov	ax,30h
		mul	byte ptr ds:tile_col_idx	; ax = data * al
		add	bx,bx
		add	bx,bx
		add	bx,ax
		add	bx,vga_seg
		mov	ds,cs:gvar_game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

masked_blit_loop:
					mov	ax,cs:[bx]
					inc	bx
					inc	bx
					and	ax,ds:[bp]
					inc	bp
					inc	bp
					or	ax,[si]
					inc	si
					inc	si
					stosw				; Store ax to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	masked_wrap_di			; Jump if below
					add	di,cga_wrap

masked_wrap_di:
					loop	masked_blit_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	ah,[di-1]
		or	ah,ah			; Zero ?
		jnz	check_animated			; Jump if not zero
		retn

check_animated:
		cmp	ah,19h
		jb	do_subst_lookup			; Jump if below
		retn

do_subst_lookup:
		push	di
		push	es
		mov	es,cs:gvar_game_seg
		mov	di,es:tile_subst_tbl_ptr
		mov	cl,es:[di]
		or	cl,cl			; Zero ?
		jz	subst_done			; Jump if zero
		inc	di

scan_subst_loop:
					mov	al,es:[di]
					cmp	al,0FFh
					je	subst_done			; Jump if equal
					cmp	ah,al
					jne	next_subst_entry			; Jump if not equal
					mov	al,es:[di+1]
					mov	[si-1],al
					jmp	short subst_done

next_subst_entry:
					inc	di
					inc	di
					dec	cl
					jnz	scan_subst_loop			; Jump if not zero

subst_done:
		pop	es
		pop	di
		retn

draw_masked_tile	endp
		db	0BFh, 14h, 3Fh		; mov di,cga_row_buf_a -- alternate entry prologue

load_6tiles_to_buf	proc	near
		mov	cx,6
load_6tiles_to_buf	endp

load_tiles_to_buf	proc	near
		push	cs
		pop	es

copy_tileset_loop:
					push	cx
					lodsb				; String [si] to al
					push	ds
					push	si
					mov	cl,10h
					mul	cl			; ax = reg * al
					mov	si,ax
					add	si,tile_pixels
					mov	ds,cs:gvar_game_seg
					mov	cx,8
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					pop	ds
					pop	cx
					loop	copy_tileset_loop		; Loop if cx > 0

		retn

load_tiles_to_buf	endp

handle_fd_tile:
		push	ds
		push	si
		push	es
		push	di
		mov	di,tile_map_arr
		movsw				; Mov [si] to es:[di]
		add	si,5
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dl,cs:tile_col_idx
		add	dl,4
		xor	dh,dh			; Zero register
		add	dx,word ptr cs:[map_scroll_col]
		mov	ds:tile_row_ctr,dx
		call	find_nonfd_entry
		mov	es:tile_char_a,al
		cmp	byte ptr es:tile_char_b,0FDh
		jne	skip_char_b_remap			; Jump if not equal
		inc	dx
		call	find_nonfd_entry
		mov	es:tile_char_b,al

skip_char_b_remap:
		mov	si,3D70h
		mov	di,3F74h
		call	load_6tiles_to_buf
		mov	si,cs:entity_tbl_ptr

scan_entity_loop:
					call	find_entity_at_row
					or	bl,bl			; Zero ?
					jz	next_entity			; Jump if zero
					push	si
					push	bx
					call	calc_tile_cga_ofs
					pop	bx
					mov	es,cs:gvar_game_seg
					mov	si,tile_char_a
					call	dispatch_draw_value
					pop	si

next_entity:
					add	si,8
;*		cmp	word ptr [si],0FFFFh
					db	 83h, 3Ch,0FFh		;  Fixup - byte match
					jnz	scan_entity_loop			; Jump if not zero
		pop	di
		pop	es
		mov	ch,es:[di-1]
		mov	cl,es:[di+7]
		push	es
		push	di
		push	cx
		mov	di,cs:tile_col_x
		add	di,640h
		push	di
		mov	si,cga_row_buf_b
		mov	ax,0B800h
		mov	es,ax
		inc	ch
		jz	skip_top_row			; Jump if zero
		call	blit_3rows_to_cga

skip_top_row:
		pop	di
		pop	cx
		cmp	byte ptr cs:tile_col_idx,1Bh
		je	blit_cleanup			; Jump if equal
		mov	si,cga_row_buf_c
		inc	di
		inc	di
		inc	cl
		jz	blit_cleanup			; Jump if zero
		call	blit_3rows_to_cga

blit_cleanup:
		pop	di
		pop	es
		mov	al,0FFh
		mov	byte ptr es:[di-1],0FEh
		mov	es:[di],al
		mov	es:[di+1],al
		mov	es:[di+7],al
		mov	es:[di+8],al
		mov	es:[di+9],al
		pop	si
		pop	ds
		retn

draw_door_init		proc	near
		push	es
		push	ds
		mov	si,ds:gvar_map_ptr
		add	si,25h
		mov	di,tile_char_a
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dx,word ptr ds:[map_scroll_col]
		add	dx,3
		mov	ds:tile_row_ctr,dx
		cmp	byte ptr ds:tile_char_a,0FDh
		jne	skip_char_a_remap			; Jump if not equal
		inc	dx
		call	find_nonfd_entry
		mov	ds:tile_char_a,al

skip_char_a_remap:
		mov	si,3D70h
		mov	di,3F74h
		mov	cx,3
		call	load_tiles_to_buf
		mov	si,cs:entity_tbl_ptr

scan_entity2_loop:
					call	find_entity_at_row
					or	bl,bl			; Zero ?
					jz	next_entity2			; Jump if zero
					push	si
					dec	bl
					mov	al,3
					mul	bl			; ax = reg * al
					push	ax
					call	calc_tile_cga_ofs
					pop	ax
					add	di,ax
					mov	bp,di
					mov	es,cs:gvar_game_seg
					mov	si,3D70h
					mov	di,cga_row_buf_b
					call	load_tiles_3_from_b
					pop	si

next_entity2:
					add	si,8
;*		cmp	word ptr [si],0FFFFh
					db	 83h, 3Ch,0FFh		;  Fixup - byte match
					jnz	scan_entity2_loop			; Jump if not zero
		mov	di,cga_tile_dest_ofs
		mov	si,cga_row_buf_b
		mov	ax,0B800h
		mov	es,ax
		call	blit_3rows_to_cga
		pop	ds
		pop	es
		mov	di,hud_status_ptr
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn

draw_door_init		endp

find_nonfd_entry		proc	near
		call	scan_entity_tbl
		mov	al,[si+3]
		cmp	al,0FDh
		je	seek_next_entry			; Jump if equal
		retn

seek_next_entry:
					add	si,8
					call	scan_entity_next
					mov	al,[si+3]
					cmp	al,0FDh
					je	seek_next_entry			; Jump if equal
		retn

find_nonfd_entry		endp

scan_entity_tbl		proc	near
		mov	si,ds:entity_tbl_ptr
scan_entity_tbl		endp

scan_entity_next	proc	near

find_entry_loop:
					cmp	dx,[si]
					jne	advance_entry			; Jump if not equal
					retn

advance_entry:
					add	si,8
					jmp	short find_entry_loop

scan_entity_next	endp

blit_3rows_to_cga		proc	near
		mov	cx,3

blit_8row_loop:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	skip_wrap_r0			; Jump if below
					add	di,cga_wrap2

skip_wrap_r0:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	skip_wrap_r1			; Jump if below
					add	di,cga_wrap2

skip_wrap_r1:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	skip_wrap_r2			; Jump if below
					add	di,cga_wrap2

skip_wrap_r2:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	skip_wrap_r3			; Jump if below
					add	di,cga_wrap2

skip_wrap_r3:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	skip_wrap_r4			; Jump if below
					add	di,cga_wrap2

skip_wrap_r4:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	skip_wrap_r5			; Jump if below
					add	di,cga_wrap2

skip_wrap_r5:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	skip_wrap_r6			; Jump if below
					add	di,cga_wrap2

skip_wrap_r6:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	skip_wrap_r7			; Jump if below
					add	di,0C050h

skip_wrap_r7:
					loop	blit_8row_loop		; Loop if cx > 0

		retn

blit_3rows_to_cga		endp

dispatch_draw_value		proc	near
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:dispatch_tbl_a[bx]	;*
		retn

dispatch_draw_value		endp

; Dispatch handler A: call dispatch_tbl_a entry, followed by dispatch jump table words

dispatch_handler_a:				;* No entry point to code
		jz	add_offset			; Jump if zero
		db	 6Ch, 35h			; dw 356Ch -- dispatch_tbl_a entry: handler at 356Ch
		db	0BFh, 74h, 3Fh			; mov di, cga_row_buf_b (3F74h)
		db	0E8h, 70h, 00h			; call near +70h
		db	0EBh, 6Eh			; jmp short +6Eh
		db	 83h,0C6h, 03h			; add si, 3
		db	0BFh,0A4h, 3Fh			; mov di, cga_row_buf_c (3FA4h)
		db	0EBh, 66h			; jmp short +66h

calc_tile_cga_ofs		proc	near
		mov	al,[si+2]
		mov	ch,al
		and	al,7Fh
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,4000h
		mov	di,ax
		xor	dl,dl			; Zero register
		or	ch,ch			; Zero ?
		js	lower_half			; Jump if sign=1
		mov	dl,4

lower_half:
		mov	al,[si+4]
		and	al,3
		add	al,dl
		mov	cl,6
		mul	cl			; ax = reg * al

add_offset:
		add	di,ax
		retn

calc_tile_cga_ofs		endp

find_entity_at_row		proc	near
		mov	cx,2
		mov	dx,ds:tile_row_ctr

find_row_loop:
					mov	bl,cl
					cmp	[si],dx
					jne	try_next_row			; Jump if not equal
					retn

try_next_row:
					inc	dx
					loop	find_row_loop		; Loop if cx > 0

		mov	bl,cl
		retn

find_entity_at_row		endp

; Dispatch handler B: save position, call dispatch_tbl_b[bl], followed by jump table words

dispatch_handler_b:				;* No entry point to code
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:dispatch_tbl_b[bx]	;*
		retn
		db	0DAh, 35h			; dw 35DAh -- dispatch_tbl_b entry 0: handler at 35DAh
		db	0D2h, 35h			; dw 35D2h -- dispatch_tbl_b entry 1: handler at 35D2h
		db	0CAh, 35h			; dw 35CAh -- dispatch_tbl_b entry 2: handler at 35CAh
		db	 83h,0C5h, 03h			; add bp, 3
		db	0BFh, 14h, 3Fh			; mov di, cga_row_buf_a (3F14h)
		db	0EBh, 10h			; jmp short +10h
		db	0BFh, 14h, 3Fh			; mov di, cga_row_buf_a (3F14h)
		db	0E8h, 0Ah, 00h			; call near +0Ah
		db	0EBh, 08h			; jmp short +8h
		db	0BFh, 44h, 3Fh			; mov di, 3F44h (cga_row_buf_a + 30h, mid-buffer)
		db	 83h,0C6h, 03h			; add si, 3
		db	0EBh, 00h			; jmp short +0 (fall-through)

load_tiles_3_from_b		proc	near
		mov	cx,3

load_tile_3_loop:
					push	cx
					mov	byte ptr [si],0FFh
					inc	si
					push	ds
					push	si
					mov	al,es:[bp]
					inc	bp
					push	es
					push	bp
					dec	al
					mov	cl,10h
					mul	cl			; ax = reg * al
					mov	si,ax
					add	si,tile_src_b
					add	ax,7000h
					mov	cs:far_ptr_tmp,ax
					mov	ax,cs
					add	ax,2000h
					mov	word ptr cs:far_ptr_tmp+2,ax
					mov	ds,cs:gvar_game_seg
					push	cs
					pop	es
					call	blend_tile_planes
					pop	bp
					pop	es
					pop	si
					pop	ds
					pop	cx
					loop	load_tile_3_loop		; Loop if cx > 0

		retn

load_tiles_3_from_b		endp

; Load 6-tile set from tile_src_a into cga_row_buf_a (dispatch target: load 6 tiles)

load_tiles_6:					;* No entry point to code
		push	cs
		pop	es
		mov	di,cga_row_buf_a
		mov	cx,6

load_tile_6_loop:
					push	cx
					lodsb				; String [si] to al
					push	ds
					push	si
					mov	cl,10h
					mul	cl			; ax = reg * al
					mov	si,ax
					add	si,tile_src_a
					add	ax,8000h
					mov	cs:far_ptr_tmp,ax
					mov	ax,cs
					add	ax,2000h
					mov	word ptr cs:far_ptr_tmp+2,ax
					mov	ds,cs:gvar_game_seg
					call	blend_tile_planes
					pop	si
					pop	ds
					pop	cx
					loop	load_tile_6_loop		; Loop if cx > 0

		retn

blend_tile_planes		proc	near
		push	ds
		push	si
		push	di
		lds	si,dword ptr cs:far_ptr_tmp	; Load seg:offset ptr
		mov	cx,8

and_plane_loop:
					lodsw				; String [si] to ax
					and	es:[di],ax
					inc	di
					inc	di
					loop	and_plane_loop		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		mov	cx,8

or_plane_loop:
					lodsw				; String [si] to ax
					or	es:[di],ax
					inc	di
					inc	di
					loop	or_plane_loop		; Loop if cx > 0

		retn

blend_tile_planes		endp

; Scroll tilemap left 2 bytes (dispatch target: shift tile columns left)

scroll_tiles_left:				;* No entry point to code
		push	ds
		SET_ES_DS_CGA
		std				; Set direction flag
		mov	si,cga_tilemap_b1
		mov	al,8

scroll_left_b1_loop:
					push	si
					mov	di,si
					dec	si
					dec	si
					mov	cx,36h
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					add	si,1Eh
					movsb				; Mov [si] to es:[di]
					movsb				; Mov [si] to es:[di]
					pop	si
					add	si,2000h
					cmp	si,4000h
					jb	sl_b1_wrap			; Jump if below
					add	si,0C050h

sl_b1_wrap:
					dec	al
					jnz	scroll_left_b1_loop			; Jump if not zero
		mov	si,cga_tilemap_b3
		mov	al,8

scroll_left_b3_loop:
					push	si
					mov	di,si
					sub	si,4
					mov	cx,34h
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					add	si,20h
					movsb				; Mov [si] to es:[di]
					movsb				; Mov [si] to es:[di]
					movsb				; Mov [si] to es:[di]
					movsb				; Mov [si] to es:[di]
					pop	si
					add	si,2000h
					cmp	si,4000h
					jb	sl_b3_wrap			; Jump if below
					add	si,0C050h

sl_b3_wrap:
					dec	al
					jnz	scroll_left_b3_loop			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn
; Scroll HUD left 1 byte (dispatch target: shift HUD column left by 1)

scroll_hud_left:				;* No entry point to code
		push	ds
		SET_ES_DS_CGA
		std				; Set direction flag
		mov	si,cga_hud_ofs_r
		mov	al,10h

scroll_left_hud_loop:
					push	si
					mov	di,si
					dec	si
					mov	cx,37h
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					add	si,1Dh
					movsb				; Mov [si] to es:[di]
					pop	si
					add	si,2000h
					cmp	si,4000h
					jb	sl_hud_wrap			; Jump if below
					add	si,0C050h

sl_hud_wrap:
					dec	al
					jnz	scroll_left_hud_loop			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn

; Scroll tilemap right 2 bytes (dispatch target: shift tile columns right)

scroll_tiles_right:				;* No entry point to code
		push	ds
		SET_ES_DS_CGA
		mov	si,cga_tilemap_b0
		mov	al,8

scroll_right_b0_loop:
					push	si
					mov	di,si
					inc	si
					inc	si
					mov	cx,36h
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					sub	si,1Eh
					movsb				; Mov [si] to es:[di]
					movsb				; Mov [si] to es:[di]
					pop	si
					add	si,2000h
					cmp	si,4000h
					jb	sr_b0_wrap			; Jump if below
					add	si,0C050h

sr_b0_wrap:
					dec	al
					jnz	scroll_right_b0_loop			; Jump if not zero
		mov	si,cga_tilemap_b2
		mov	al,8

scroll_right_b2_loop:
					push	si
					mov	di,si
					add	si,4
					mov	cx,34h
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					sub	si,20h
					movsb				; Mov [si] to es:[di]
					movsb				; Mov [si] to es:[di]
					movsb				; Mov [si] to es:[di]
					movsb				; Mov [si] to es:[di]
					pop	si
					add	si,2000h
					cmp	si,4000h
					jb	sr_b2_wrap			; Jump if below
					add	si,0C050h

sr_b2_wrap:
					dec	al
					jnz	scroll_right_b2_loop			; Jump if not zero
		pop	ds
		retn

; Scroll HUD right 1 byte (dispatch target: shift HUD column right by 1)

scroll_hud_right:				;* No entry point to code
		push	ds
		SET_ES_DS_CGA
		mov	si,cga_hud_ofs_l
		mov	al,10h

scroll_right_hud_loop:
					push	si
					mov	di,si
					inc	si
					mov	cx,37h
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					sub	si,1Dh
					movsb				; Mov [si] to es:[di]
					pop	si
					add	si,2000h
					cmp	si,4000h
					jb	sr_hud_wrap			; Jump if below
					add	si,0C050h

sr_hud_wrap:
					dec	al
					jnz	scroll_right_hud_loop			; Jump if not zero
		pop	ds
		retn

; Blit one tile from tileset_index to CGA at (bl=col, bh=row, al=tile_id) (dispatch target)

blit_tile_from_index:				;* No entry point to code
		push	ds
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,tileset_index
		CGA_PIXEL_ADDR
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	di,bx
		mov	ds,cs:gvar_game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

blit_tile_row_loop:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	blit_row_wrap			; Jump if below
					add	di,cga_wrap2

blit_row_wrap:
					loop	blit_tile_row_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn

; Blit HUD border tile from tile_gfx_data to CGA at (bl=col, bh=row) (dispatch target)

blit_hud_border_tile:				;* No entry point to code
		push	ds
		push	si
		push	di
		push	cs
		pop	ds
		CGA_PIXEL_ADDR
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	ax,0B800h
		mov	es,ax
		mov	si,tile_gfx_data
		mov	cx,9

blit_hborder_loop:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	blit_hborder_wrap			; Jump if below
					add	di,cga_wrap

blit_hborder_wrap:
					loop	blit_hborder_loop		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		retn
		; CGA scanline offset table (9 words): row Y-offsets for interleaved scanlines
		db	 00h, 00h, 28h, 00h, 2Ah, 00h	; dw 0000h,0028h,002Ah
		db	 2Ah, 80h, 2Ah,0A0h, 2Ah, 80h	; dw 802Ah,A02Ah,802Ah
		db	 2Ah, 00h, 28h, 00h, 00h, 00h	; dw 002Ah,0028h,0000h
		; Inline code: blit_hud_border_tile entry stub (continues into copy_row_span_loop)
		db	0D0h,0EBh, 1Bh,0FFh, 81h,0E7h	; shr bl,1; jmp short ...; and di,2000h
		db	 00h, 20h,0B0h, 50h,0F6h,0E3h	; (cont); mov al,50h; mul bl
		db	 03h,0F8h, 8Ah,0DFh, 32h,0FFh	; add di,ax; mov bl,bh; xor bh,bh
		db	 03h,0FBh,0BEh, 84h, 3Dh,0B8h	; add di,bx; mov si,3D84h; mov ax,...
		db	 00h,0B8h, 8Eh,0C0h,0B9h, 09h	; 0B800h; mov es,ax; mov cx,9
		db	 00h				; (cx high byte)

copy_row_span_loop:
					push	cx
					push	di
					push	si
					mov	cx,ds:gvar_tile_width
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					add	si,28h
					pop	di
					add	di,2000h
					cmp	di,4000h
					jb	row_span_wrap			; Jump if below
					add	di,0C050h

row_span_wrap:
					pop	cx
					loop	copy_row_span_loop		; Loop if cx > 0

		retn

; Render text string to glyph buffer, optionally blit digit (dispatch target)

render_text_string:				;* No entry point to code
		push	si
		push	di
		push	di
		xor	ah,ah			; Zero register
		push	ax
		push	cs
		pop	es
		mov	di,glyph_buf
		xor	ax,ax			; Zero register
		mov	cx,0C8h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		push	ax
		add	ax,ax
		add	si,ax
		mov	si,[si]
		call	render_string
		pop	ax
		pop	di
		test	byte ptr ds:gvar_scroll_flag,0FFh
		jz	skip_digit_draw			; Jump if zero
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	di,ax
		mov	dl,[di]
		mov	ax,[di+1]
		call	render_char_set

skip_digit_draw:
		pop	di
		pop	si
		retn

render_string		proc	near
		push	cs
		pop	es
		mov	di,text_render_dst
		xor	bl,bl			; Zero register

scan_char_loop:
					lodsb				; String [si] to al
					or	al,al			; Zero ?
					jnz	draw_char			; Jump if not zero
					retn

draw_char:
					push	bx
					push	ds
					push	si
					and	bl,3
					call	render_char_glyph
					pop	si
					pop	ds
					pop	bx
					inc	bl
					jmp	short scan_char_loop

render_string		endp

render_char_glyph		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:font_char_data
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8

draw_char_row_loop:
					push	bx
					lodsb				; String [si] to al
					mov	dl,4

shift_bits_loop:
								add	ax,ax
								add	ah,ah
								dec	dl
								jnz	shift_bits_loop			; Jump if not zero
					mov	al,ah
					shr	ah,1			; Shift w/zeros fill
					or	al,ah
					xor	bl,bl			; Zero register
					mov	bh,al
					shr	bx,cl			; Shift w/zeros fill
					or	es:[di],bh
					or	es:[di+1],bl
					add	di,28h
					pop	bx
					dec	bl
					jnz	draw_char_row_loop			; Jump if not zero
		pop	di
		inc	di
		cmp	cl,6
		je	wide_char			; Jump if equal
		retn

wide_char:
		inc	di
		retn

render_char_glyph		endp

; Render digit to glyph buffer at position (ax=digit, dx=?) and blit 7 chars (dispatch target)

render_digit:					;* No entry point to code
		push	dx
		push	ax
		push	cs
		pop	es
		mov	di,glyph_buf
		xor	ax,ax			; Zero register
		mov	cx,0C8h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		pop	dx
		call	init_status_buf
		mov	di,text_render_dst
		mov	si,status_buf
		mov	cx,7
		mov	bl,1
		mov	word ptr ds:gvar_tile_width,0Bh
		jmp	short render_chars_loop

render_char_set		proc	near
		call	init_status_buf
		push	cs
		pop	es
		mov	di,text_render_dst
		add	di,ds:gvar_char_y_ofs
		mov	si,anim_frame_data
		mov	cx,6
		mov	bl,1

render_chars_loop:
					push	cx
					push	bx
					push	di
					lodsb				; String [si] to al
					push	si
					call	render_char_row
					pop	si
					pop	di
					pop	bx
					mov	al,bl
					inc	di
					and	ax,1
					add	di,ax
					inc	bl
					pop	cx
					loop	render_chars_loop		; Loop if cx > 0

		retn

render_char_set		endp

render_char_row		proc	near
		inc	al
		jnz	decode_glyph			; Jump if not zero
		retn

decode_glyph:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:font_data_tbl
		mov	si,ax
		mov	cx,7

glyph_byte_loop:
					lodsb				; String [si] to al
					mov	ah,8

shift_glyph_bits:
								add	al,al
								adc	dx,dx
								add	dx,dx
								dec	ah
								jnz	shift_glyph_bits			; Jump if not zero
					mov	ax,dx
					shr	dx,1			; Shift w/zeros fill
					or	ax,dx
					test	bl,1
					jnz	write_glyph_nibble			; Jump if not zero
					add	ax,ax
					add	ax,ax
					add	ax,ax
					add	ax,ax

write_glyph_nibble:
					or	es:[di],ah
					or	es:[di+1],al
					add	di,28h
					loop	glyph_byte_loop		; Loop if cx > 0

		retn

render_char_row		endp

init_status_buf		proc	near
		mov	di,status_buf
		call	convert_time_bcd
		mov	cx,6

clear_status_loop:
					test	byte ptr cs:[di],0FFh
					jz	status_already_set			; Jump if zero
					retn

status_already_set:
					mov	byte ptr cs:[di],0FFh
					inc	di
					loop	clear_status_loop		; Loop if cx > 0

		retn

init_status_buf		endp

		db	7 dup (0)		; 7-byte status buffer (cleared by clear_status_loop)

convert_time_bcd		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	bcd_extract_sub
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	bcd_extract_sub
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	bcd_extract_sub
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	bcd_extract_div
		mov	cs:[di+3],dh
		mov	bx,64h
		call	bcd_extract_div
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	bcd_extract_div
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn

convert_time_bcd		endp

bcd_extract_sub		proc	near
		xor	dh,dh			; Zero register

div_loop:
					sub	dl,cl
					jc	div_done			; Jump if carry Set
					sub	ax,bx
					jnc	inc_quotient			; Jump if carry=0
					or	dl,dl			; Zero ?
					jz	adjust_remainder			; Jump if zero
					dec	dl

inc_quotient:
					inc	dh
					jmp	short div_loop

adjust_remainder:
		add	ax,bx

div_done:
		add	dl,cl
		retn

bcd_extract_sub		endp

bcd_extract_div		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn

bcd_extract_div		endp

; Copy tile row to previous CGA scanline (dispatch target: scroll row up)

copy_row_to_prev:				;* No entry point to code
		push	ds
		push	ax
		add	bl,cl
		dec	bl
		CGA_PIXEL_ADDR
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	si,di
		sub	si,2000h
		jnc	si_nowrap			; Jump if carry=0
		add	si,cga_wrap_si2

si_nowrap:
		SET_ES_DS_CGA
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

copy_row_prev_loop:
					push	cx
					push	di
					push	si
					mov	cx,bx
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					pop	di
					sub	si,2000h
					jnc	src_nowrap			; Jump if carry=0
					add	si,cga_wrap_si

src_nowrap:
					sub	di,2000h
					jnc	dst_nowrap			; Jump if carry=0
					add	di,cga_wrap_si2

dst_nowrap:
					pop	cx
					loop	copy_row_prev_loop		; Loop if cx > 0

		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,glyph_buf
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn

; Copy tile row to next CGA scanline (dispatch target: scroll row down)

copy_row_to_next:				;* No entry point to code
		push	ds
		push	ax
		CGA_PIXEL_ADDR
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	si,di
		add	si,2000h
		cmp	si,4000h
		jb	si_advance_nowrap			; Jump if below
		add	si,cga_wrap2

si_advance_nowrap:
		SET_ES_DS_CGA
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

copy_row_next_loop:
					push	cx
					push	di
					push	si
					mov	cx,bx
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					pop	di
					add	si,2000h
					cmp	si,4000h
					jb	next_src_nowrap			; Jump if below
					add	si,cga_wrap

next_src_nowrap:
					add	di,2000h
					cmp	di,4000h
					jb	next_dst_nowrap			; Jump if below
					add	di,cga_wrap2

next_dst_nowrap:
					pop	cx
					loop	copy_row_next_loop		; Loop if cx > 0

		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,glyph_buf
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn

; XOR-flash tile area (8 scanlines x 18 rows x 28 words) at HUD left offset (dispatch target)

xor_flash_tiles:				;* No entry point to code
		mov	ax,0B800h
		mov	es,ax
		mov	di,cga_hud_ofs_l
		mov	cx,8

xor_tile_outer_loop:
					push	cx
					push	di
					mov	cx,12h

xor_tile_row_loop:
								push	cx
								push	di
								mov	ax,0FFFFh
								mov	cx,1Ch

xor_tile_word_loop:
								xor	es:[di],ax
								inc	di
								inc	di
								loop	xor_tile_word_loop		; Loop if cx > 0

								pop	di
								add	di,140h
								pop	cx
								loop	xor_tile_row_loop		; Loop if cx > 0

					pop	di
					add	di,2000h
					cmp	di,4000h
					jb	xor_tile_wrap			; Jump if below
					add	di,0C050h

xor_tile_wrap:
					pop	cx
					loop	xor_tile_outer_loop		; Loop if cx > 0

		retn

; Convert tile bitplane data: copy cx rows to level segment and encode (dispatch target)

convert_tile_planes:				;* No entry point to code
		mov	cs:far_ptr_tmp,di
		mov	word ptr cs:far_ptr_tmp+2,es
		push	cx
		push	ds
		push	si
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,30h
		mul	cx			; dx:ax = reg * ax
		mov	cx,ax
		mov	di,zero_offset
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,zero_offset

tile_convert_outer:
					push	cx
					mov	cx,8

tile_convert_inner:
								push	cx
								lodsw				; String [si] to ax
								mov	dx,ax
								lodsw				; String [si] to ax
								mov	cx,ax
								lodsw				; String [si] to ax
								mov	bx,ax
								mov	bp,ax
								or	ax,cx
								or	ax,dx
								and	bp,cx
								and	bp,dx
								not	bp
								and	dx,bp
								and	cx,bp
								and	bx,bp
								mov	cs:bitplane_0,dx
								mov	cs:bitplane_1,cx
								mov	cs:bitplane_2,bx
								not	ax
								mov	cs:bitplane_3,ax
								call	encode_bitplanes_cga
								mov	ax,dx
								stosw				; Store ax to es:[di]
								push	es
								push	di
								les	di,dword ptr cs:far_ptr_tmp	; Load seg:offset ptr
								call	encode_mask_cga
								mov	ax,dx
								stosw				; Store ax to es:[di]
								mov	cs:far_ptr_tmp,di
								pop	di
								pop	es
								pop	cx
								loop	tile_convert_inner		; Loop if cx > 0

					pop	cx
					loop	tile_convert_outer		; Loop if cx > 0

		retn

; Prepare tile pixel data: copy all tile_pixels to level segment, encode map (dispatch target)

prepare_tile_data:				;* No entry point to code
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,tile_pixels
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	cx,2EE0h
		mov	di,zero_offset
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	es,cs:gvar_game_seg
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,0
		mov	di,8100h
		mov	bx,es:tileset_index
		mov	bp,0D000h
		mov	cx,0FAh

map_render_loop:
					push	cx
					mov	al,es:[bx]
					cmp	al,5
					jb	clamp_tile_type			; Jump if below
					xor	al,al			; Zero register

clamp_tile_type:
					push	bx
					xor	bx,bx			; Zero register
					mov	bl,al
					add	bx,bx
					call	word ptr cs:tile_render_disp[bx]	;*
					pop	bx
					inc	bx
					pop	cx
					loop	map_render_loop		; Loop if cx > 0

		pop	ds
		retn

; Tile render dispatch: tile_render_disp table + encoder entry stubs (dispatch target)

tile_render_dispatch:				;* No entry point to code
		push	cs
		cmp	al,33h			; dispatch table word: 0x3C0E (push cs stub)
		cmp	al,60h			; dispatch table word: 0x3C3C
		cmp	al,8Dh			; dispatch table word: 0x603C
		cmp	al,0BAh			; dispatch table word: 0x8D3C
		cmp	al,0B9h			; dispatch table word: 0xBA3C
		or	[bx+si],al		; dispatch table word: 0xB93C / 0x083Ch

encode_tile_3plane:
					push	cx
					lodsw				; String [si] to ax
					mov	cs:bitplane_0,ax
					lodsw				; String [si] to ax
					mov	cs:bitplane_1,ax
					lodsw				; String [si] to ax
					mov	cs:bitplane_2,ax
					call	encode_bitplanes_cga
					mov	ax,dx
					stosw				; Store ax to es:[di]
					mov	word ptr es:[bp],0
					inc	bp
					inc	bp
					pop	cx
					loop	encode_tile_3plane		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h		; mov cx,8 -- encode_tile_ab entry prologue

encode_tile_ab:
					push	cx
					lodsw				; String [si] to ax
					mov	cs:bitplane_0,ax
					lodsw				; String [si] to ax
					mov	cs:bitplane_1,ax
					mov	word ptr cs:bitplane_2,0
					lodsw				; String [si] to ax
					mov	cs:bitplane_3,ax
					call	encode_bitplanes_cga
					mov	ax,dx
					stosw				; Store ax to es:[di]
					call	encode_mask_cga
					mov	es:[bp],dx
					inc	bp
					inc	bp
					pop	cx
					loop	encode_tile_ab		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h		; mov cx,8 -- encode_tile_ac entry prologue

encode_tile_ac:
					push	cx
					lodsw				; String [si] to ax
					mov	cs:bitplane_0,ax
					lodsw				; String [si] to ax
					mov	cs:bitplane_3,ax
					mov	word ptr cs:bitplane_1,0
					lodsw				; String [si] to ax
					mov	cs:bitplane_2,ax
					call	encode_bitplanes_cga
					mov	ax,dx
					stosw				; Store ax to es:[di]
					call	encode_mask_cga
					mov	es:[bp],dx
					inc	bp
					inc	bp
					pop	cx
					loop	encode_tile_ac		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h		; mov cx,8 -- encode_tile_bc entry prologue

encode_tile_bc:
					push	cx
					lodsw				; String [si] to ax
					mov	cs:bitplane_3,ax
					mov	word ptr cs:bitplane_0,0
					lodsw				; String [si] to ax
					mov	cs:bitplane_1,ax
					lodsw				; String [si] to ax
					mov	cs:bitplane_2,ax
					call	encode_bitplanes_cga
					mov	ax,dx
					stosw				; Store ax to es:[di]
					call	encode_mask_cga
					mov	es:[bp],dx
					inc	bp
					inc	bp
					pop	cx
					loop	encode_tile_bc		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h		; mov cx,8 -- encode_tile_blank entry prologue

encode_tile_blank:
					push	cx
					add	si,6
					xor	ax,ax			; Zero register
					stosw				; Store ax to es:[di]
					mov	word ptr es:[bp],0FFFFh
					inc	bp
					inc	bp
					pop	cx
					loop	encode_tile_blank		; Loop if cx > 0

		retn

encode_bitplanes_cga		proc	near
		mov	cx,8

bitplane_encode_loop:
					xor	bx,bx			; Zero register
					rol	word ptr cs:bitplane_2,1	; Rotate
					adc	bx,bx
					rol	word ptr cs:bitplane_1,1	; Rotate
					adc	bx,bx
					rol	word ptr cs:bitplane_0,1	; Rotate
					adc	bx,bx
					rol	word ptr cs:bitplane_2,1	; Rotate
					adc	bx,bx
					rol	word ptr cs:bitplane_1,1	; Rotate
					adc	bx,bx
					rol	word ptr cs:bitplane_0,1	; Rotate
					adc	bx,bx
					add	dx,dx
					add	dx,dx
					or	dl,cs:color_lut[bx]
					loop	bitplane_encode_loop		; Loop if cx > 0

		retn

encode_bitplanes_cga		endp

		; color_lut (64 bytes): 3-bitplane index -> CGA color code (0-3)
		; Indexed as [plane2_bit<<3 | plane1_bit<<2 | plane0_bit<<1 | plane_pair]
		db	0, 1, 0, 1, 1, 0	; color_lut[ 0..5]
		db	3, 2, 1, 3, 2, 3	; color_lut[ 6..11]
		db	1, 3, 3, 2, 2, 2	; color_lut[12..17]
		db	2, 1, 1, 2, 2, 2	; color_lut[18..23]
		db	1, 3, 1, 3, 1, 1	; color_lut[24..29]
		db	2, 2, 1, 1, 1, 1	; color_lut[30..35]
		db	1, 1, 3, 2, 0, 3	; color_lut[36..41]
		db	2, 1, 1, 1, 3, 2	; color_lut[42..47]
		db	3, 3, 2, 2, 3, 3	; color_lut[48..53]
		db	3, 2, 1, 2, 2, 2	; color_lut[54..59]
		db	2, 2, 2, 2		; color_lut[60..63]

encode_mask_cga		proc	near
		mov	cx,8

mask_encode_loop:
					xor	al,al			; Zero register
					rol	word ptr cs:bitplane_3,1	; Rotate
					adc	al,al
					rol	word ptr cs:bitplane_3,1	; Rotate
					adc	al,al
					cmp	al,3
					je	mask_pair_match			; Jump if equal
					xor	al,al			; Zero register

mask_pair_match:
					add	dx,dx
					add	dx,dx
					or	dl,al
					loop	mask_encode_loop		; Loop if cx > 0

		retn

encode_mask_cga		endp

		db	1127 dup (0)		; padding / BSS-style zero data area

seg_a		ends

		end	start
