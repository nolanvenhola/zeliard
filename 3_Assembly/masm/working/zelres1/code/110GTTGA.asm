
PAGE  59,132

;==========================================================================
;
;  110GTTGA - Town Tiles TGA Renderer (zelres1 chunk 11, gttga.bin)
;
;  Tandy-specific tilemap renderer for the town/overworld engine. Loaded
;  by game.bin into the game segment (gfx_mode_tbl_all entry, mode 5)
;  alongside 106TOWN (town.bin). Provides tile blit, scroll, character
;  cell rendering, and text-glyph functions exposed via dispatch slots
;  consumed by 106TOWN.
;
;  Connections:
;    Loads:        none (rendering primitives only)
;    Calls into:   render_fn_tbl_* (CS dispatch tables, set internally
;                  per tile type)
;    Called by:    game.bin LOAD_CHUNK chunk_ref_gttga via gfx_mode_tbl_all
;                  (gfx-driver init at loaded_code_a CS:0x3000); 106TOWN
;                  invokes gfx_draw_tile/draw_player/render_*/scroll_*/
;                  text_layout/draw_str/draw_char etc. through this chunk
;    Reads/writes: gvar_game_seg (FF2C) [zeliad-owned]; tile flag bytes
;                  in town-owned segment range
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

DBG_CHUNK_BASE		EQU	2FFCh		; runtime base = load_addr - 4

include  srmacros.inc
include  zr1com.inc


; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
gvar_game_seg		equ	0FF2Ch			;* global: game data segment selector

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
; restored after factoring (per-file value, not in shared inc):
font_ptr_a               equ     0F502h
font_ptr_b               equ     0F504h
dispatch_tbl_a		equ	35BAh			;* draw-cell dispatch function table A (word[N])	;* DBG: DBG_CHUNK_BASE + offset dispatch_tbl_a_lbl
dispatch_tbl_b		equ	3616h			;* draw-cell dispatch function table B (word[N])	;* DBG: DBG_CHUNK_BASE + offset dispatch_tbl_b_lbl
tile_gfx_data		equ	386Ch			;* tile graphics row source data
anim_frame_data		equ	3A20h			;* animation / icon frame data table
tile_render_disp	equ	3C68h			;* tile type render dispatch table (word[N])	;* DBG: DBG_CHUNK_BASE + offset tile_render_disp_lbl
color_lut		equ	3DCBh			;* color lookup table (bitplane index -> TGA nibble)	;* DBG: DBG_CHUNK_BASE + offset color_lut_lbl
tile_col_x		equ	3E64h			;* current tile column TGA byte offset (word)
tile_char_a		equ	3E67h			;* tile char slot A (byte)	;* DBG: DBG_CHUNK_BASE + offset tile_char_a_lbl
tile_map_arr		equ	3E68h			;* tile map working array (2 bytes)
tile_char_b		equ	3E6Ah			;* tile char slot B (byte, 0FDh = none)	;* DBG: DBG_CHUNK_BASE + offset tile_char_b_lbl
tile_row_ctr		equ	3E6Dh			;* current tile row/scan counter (word)	;* DBG: DBG_CHUNK_BASE + offset tile_row_ctr_lbl
bitplane_0		equ	3E6Fh			;* bitplane word 0 for tile color encode	;* DBG: DBG_CHUNK_BASE + offset bitplane_0_lbl
bitplane_1		equ	3E71h			;* bitplane word 1 for tile color encode	;* DBG: DBG_CHUNK_BASE + offset bitplane_1_lbl
bitplane_2		equ	3E73h			;* bitplane word 2 for tile color encode	;* DBG: DBG_CHUNK_BASE + offset bitplane_2_lbl
bitplane_3		equ	3E75h			;* bitplane word 3 (transparent mask)	;* DBG: DBG_CHUNK_BASE + offset bitplane_3_lbl
far_ptr_tmp		equ	3E77h			;* temporary far pointer (dword, seg:offset)
glyph_buf		equ	3E7Bh			;* glyph render working buffer (190h words)
tga_row_buf_a		equ	419Bh			;* TGA tile row buffer A (column 0)
tga_row_buf_b		equ	425Bh			;* TGA tile row buffer B (column 1)
tga_row_buf_c		equ	42BBh			;* TGA tile row buffer C (column 2)
tile_cache_tbl		equ	431Bh			;* tile VGA address cache table (indexed by tile id)	;* DBG: DBG_CHUNK_BASE + offset tile_cache_tbl_lbl
scroll_dst_ofs		equ	5238h			;* scroll destination offset in TGA buffer
tga_wrap_sub		equ	7F60h			;* TGA segment wrap: add when di/si wraps past 8000h
tga_wrap		equ	80A0h			;* TGA segment base (Tandy B800 wrap constant)
tga_hud_ofs		equ	41F8h			; TGA HUD area top-left offset in B800 segment
scroll_r16_src		equ	4266h			; scroll-right 16-wide source offset
scroll_l8_src_b		equ	55F8h			; scroll-left 8-wide source offset B
scroll_l16_src		equ	5666h			; scroll-left 16-wide source offset
scroll_r8_src_a		equ	5738h			; scroll-right 8-wide source offset A
scroll_r8_src_b		equ	57A6h			; scroll-right 8-wide source offset B
tga_wrap_sub2		equ	7F60h			; TGA segment wrap subtraction (dup of tga_wrap_sub)
tga_wrap2		equ	80A0h			; TGA segment wrap constant (dup of tga_wrap)
bcd_time_buf	equ	DBG_CHUNK_BASE + offset bcd_time_buf_lbl		; 7-byte BCD time buffer (tens-hours/hours/mins/secs/frames)
glyph_render_ofs	equ	3ECBh			; render start offset within glyph_buf (glyph_buf + 50h)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
tile_col_idx		equ	3E66h			;* current tile column counter (byte, 0..1Ch)	;* DBG: DBG_CHUNK_BASE + offset tile_col_idx_lbl

; SET_ES_DS_TGA
;   ES = DS = B800h (set both segments to Tandy/CGA framebuffer).
SET_ES_DS_TGA	MACRO
		mov	ax, 0B800h
		mov	es, ax
		mov	ds, ax
		ENDM

; TGA_DI_WRAP_STEP <merge_label>
;   Two-word movsw burst followed by DI advance + wrap check.  TGA framebuffer
;   has 32KB visible at B000:0000 with the next 32KB at C000:0000; +0x1FFC per
;   pair-of-words may cross the 0x8000 boundary, in which case tga_wrap2
;   (0x80A0) re-aligns.
;
TGA_DI_WRAP_STEP	MACRO	merge
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	merge			; Jump if below
		add	di,tga_wrap2
merge:
		ENDM

; TGA_SI_WRAP_STEP <merge_label>
;   Same +0x1FFC / wrap check applied to SI when source pointer crosses
;   the plane boundary.
;
TGA_SI_WRAP_STEP	MACRO	merge
		add	si,1FFCh
		cmp	si,8000h
		jb	merge			; Jump if below
		add	si,tga_wrap2
merge:
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

run_gttga_main	proc	far

; Module initialization block (Sourcer byte-match fixups):
; The loader reads this header and patches the driver dispatch table before
; calling into the module. Bytes decode as address pairs and setup instructions:
;   Offset table entries (word pairs) referencing dispatch_tbl_a/b, tile_gfx_data,
;   anim_frame_data, tile_render_disp, color_lut, and state variable addresses.
;   Tail: mov si,4BF8h; mov di,0A000h; push cs; pop es;
;         mov ax,0B800h; mov ds,ax; mov cx,1Ch  <- set up for col_blit_loop

start:
		sbb	dx,[di]
		add	[bx+si],al
		inc	di
		cmp	bp,[bx+si]
		xor	[bx+di+30h],bl
		in	al,36h			; port 36h ??I/O Non-standard
		inc	dx
		aaa				; Ascii adjust
;*		jz	loc_3			;*Jump if zero
		db	 74h, 37h		;  Fixup - byte match
;*		sal	byte ptr [bx],1		; Shift w/zeros fill
		db	0D0h, 37h		;  Fixup - byte match
		xchg	bx,ax
		xor	cx,[bx+si]
		db	 36h, 77h, 36h,0CEh, 35h, 00h	; dispatch words: 3677h, 36CEh, 3500h
		db	 38h, 3Fh, 38h,0C2h, 38h, 90h	; dispatch words: 383Fh, 38C2h, 3890h
		db	 38h, 8Fh, 3Ah,0E7h, 3Ah, 83h	; dispatch words: 388Fh, 3AE7h, 3A83h
		db	 39h, 16h, 3Ch, 81h, 3Bh, 1Eh	; dispatch words: 3916h, 3C81h, 3B1Eh + push ds
		db	0BEh,0F8h, 4Bh,0BFh, 00h,0A0h	; mov si,4BF8h; mov di,0A000h
		db	 0Eh, 07h,0B8h, 00h,0B8h, 8Eh	; push cs; pop es; mov ax,0B800h; mov ds,...
		db	0D8h,0B9h, 1Ch, 00h		; mov ds,ax; mov cx,1Ch -> col_blit_loop

col_blit_loop:
									push	cx
									push	si
									mov	cx,18h

row_blit_loop:
																movsw				; Mov [si] to es:[di]
																movsw				; Mov [si] to es:[di]
																add	si,1FFCh
																cmp	si,8000h
																jb	row_wrap_ok			; Jump if below
																add	si,tga_wrap

row_wrap_ok:
																loop	row_blit_loop		; Loop if cx > 0

									pop	si
									pop	cx
									add	si,4
									loop	col_blit_loop		; Loop if cx > 0

		pop	ds
		retn

; fn_draw_tiles: clear tile cache then render all tile columns (called via driver dispatch)

fn_draw_tiles:
		push	cs
		pop	es
		mov	di,tile_cache_tbl
		xor	ax,ax			; Zero register
		mov	cx,100h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,ds:[gvar_map_ptr]
		cmp	byte ptr [si+1Dh],0FDh
		jne	draw_init_start			; Jump if not equal
		call	save_state_then_blit_tga

draw_init_start:
		mov	word ptr ds:[tile_col_x],4BF8h
		mov	si,ds:[gvar_map_ptr]
		add	si,20h
		push	cs
		pop	es
		mov	di,0E000h
		mov	byte ptr ds:[tile_col_idx],0

draw_col_loop:
									call	match_tile_by_dx_tga
									xor	bl,bl			; Zero register
									cmpsb				; Cmp [si] to es:[di]
									jz	skip_func4_a			; Jump if zero
									call	mark_tile_FE_tga

skip_func4_a:
									inc	bl
									cmpsb				; Cmp [si] to es:[di]
									jz	skip_func4_b			; Jump if zero
									call	mark_tile_FE_tga

skip_func4_b:
									inc	bl
									cmpsb				; Cmp [si] to es:[di]
									jz	skip_func4_c			; Jump if zero
									call	mark_tile_FE_tga

skip_func4_c:
									inc	bl
									cmpsb				; Cmp [si] to es:[di]
									jz	skip_func3_a			; Jump if zero
									call	render_tile_entry_tga

skip_func3_a:
									inc	bl
									cmpsb				; Cmp [si] to es:[di]
									jz	skip_func3_b			; Jump if zero
									call	render_tile_entry_tga

skip_func3_b:
									inc	bl
									cmpsb				; Cmp [si] to es:[di]
									jz	skip_multiply			; Jump if zero
									call	render_tile_if_marked_tga

skip_multiply:
									inc	bl
									cmpsb				; Cmp [si] to es:[di]
									jz	skip_func3_c			; Jump if zero
									call	render_tile_entry_tga

skip_func3_c:
									inc	bl
									cmpsb				; Cmp [si] to es:[di]
									jz	draw_col_next			; Jump if zero
									call	render_tile_entry_tga

draw_col_next:
									add	word ptr ds:[tile_col_x],4
									inc	byte ptr ds:[tile_col_idx]
									cmp	byte ptr ds:[tile_col_idx],1Ch
									jne	draw_col_loop			; Jump if not equal
		retn

run_gttga_main	endp

match_tile_by_dx_tga		proc	near
		cmp	byte ptr ds:[tile_col_idx],1Bh
		jne	scan_not_last			; Jump if not equal
		retn

scan_not_last:
		mov	al,byte ptr ds:[screen_position]
		cmp	ds:[tile_col_idx],al
		je	scan_col_match			; Jump if equal
		retn

scan_col_match:
		push	di
		push	es
		push	si
		xor	ax,ax			; Zero register
		mov	al,byte ptr ds:[screen_position]
		add	ax,ax
		add	ax,ax
		mov	di,ax
		add	di,scroll_dst_ofs
		mov	ax,0B800h
		mov	es,ax
		mov	si,tga_row_buf_a
		mov	cx,2

scan_state_loop:
									push	cx
									push	di
									call	check_tile_state_tga
									pop	di
									add	di,4
									pop	cx
									loop	scan_state_loop		; Loop if cx > 0

		pop	si
		pop	es
		pop	di
		retn

match_tile_by_dx_tga		endp

render_tile_if_marked_tga		proc	near
		cmp	byte ptr [si-1],0FDh
		jne	draw_cell_start			; Jump if not equal
		jmp	draw_anim_tile

render_tile_if_marked_tga		endp

render_tile_entry_tga		proc	near

draw_cell_start:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	draw_cell_new			; Jump if not zero
		retn

draw_cell_new:
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
		mov	ax,0A0h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:[tile_col_x]
		mov	di,ax
		pop	dx
		mov	bl,dl
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:[tile_cache_tbl][bx],0FFFFh
		jnz	draw_tile_cached			; Jump if not zero
		mov	ds:[tile_cache_tbl][bx],di
		mov	ax,20h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,tile_pixel_base
		mov	ds,cs:[gvar_game_seg]
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

draw_tile_row_loop:
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									add	di,1FFCh
									cmp	di,8000h
									jb	draw_tile_wrap_ok			; Jump if below
									add	di,tga_wrap2

draw_tile_wrap_ok:
									loop	draw_tile_row_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

draw_tile_cached:
		mov	si,ds:[tile_cache_tbl][bx]
		SET_ES_DS_TGA
		TGA_DI_WRAP_STEP cached_r1_di_ok
		TGA_SI_WRAP_STEP cached_r1_si_ok
		TGA_DI_WRAP_STEP cached_r2_di_ok
		TGA_SI_WRAP_STEP cached_r2_si_ok
		TGA_DI_WRAP_STEP cached_r3_di_ok
		TGA_SI_WRAP_STEP cached_r3_si_ok
		TGA_DI_WRAP_STEP cached_r4_di_ok
		TGA_SI_WRAP_STEP cached_r4_si_ok
		TGA_DI_WRAP_STEP cached_r5_di_ok
		TGA_SI_WRAP_STEP cached_r5_si_ok
		TGA_DI_WRAP_STEP cached_r6_di_ok
		TGA_SI_WRAP_STEP cached_r6_si_ok
		TGA_DI_WRAP_STEP cached_r7_di_ok
		TGA_SI_WRAP_STEP cached_r7_si_ok
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

render_tile_entry_tga		endp

mark_tile_FE_tga		proc	near
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	draw_fg_nonzero			; Jump if not zero
		retn

draw_fg_nonzero:
		push	bx
		push	es
		mov	dl,[si-1]
		mov	bl,dl
		xor	bh,bh			; Zero register
		mov	es,cs:[gvar_game_seg]
		add	bx,es:[tileset_buf_a]
		mov	dh,es:[bx]
		pop	es
		pop	bx
		or	dh,dh			; Zero ?
		jnz	draw_fg_masked			; Jump if not zero
		jmp	draw_cell_start

draw_fg_masked:
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
		mov	ax,0A0h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:[tile_col_x]
		mov	di,ax
		pop	dx
		mov	ax,20h
		mul	dl			; ax = reg * al
		mov	si,ax
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bp,ax
		add	si,8100h
		add	bp,tile_mask_data
		mov	ax,60h
		mul	byte ptr ds:[tile_col_idx]	; ax = data * al
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ax
		add	bx,0A000h
		mov	ds,cs:[gvar_game_seg]
		mov	ax,0B800h
		mov	es,ax
		cmp	dh,4
		je	draw_fg_opaque			; Jump if equal
		mov	cx,8

draw_fg_row_loop:
									push	cx
									mov	al,ds:[bp]
									call	init_4_byte_loop_alt_tga
									mov	cl,al
									mov	ax,cs:[bx]
									and	ax,dx
									or	ax,[si]
									stosw				; Store ax to es:[di]
									mov	al,cl
									call	init_4_byte_loop_alt_tga
									mov	ax,cs:[bx+2]
									and	ax,dx
									or	ax,[si+2]
									stosw				; Store ax to es:[di]
									inc	bp
									add	bx,4
									add	si,4
									add	di,1FFCh
									cmp	di,8000h
									jb	draw_fg_wrap_ok			; Jump if below
									add	di,tga_wrap2

draw_fg_wrap_ok:
									pop	cx
									loop	draw_fg_row_loop		; Loop if cx > 0

		jmp	short draw_fg_done

draw_fg_opaque:
		mov	cx,8

draw_fg_opaque_loop:
									push	cx
									mov	ax,cs:[bx]
									stosw				; Store ax to es:[di]
									mov	ax,cs:[bx+2]
									stosw				; Store ax to es:[di]
									add	bx,4
									add	di,1FFCh
									cmp	di,8000h
									jb	draw_fg_opaque_wrap			; Jump if below
									add	di,tga_wrap

draw_fg_opaque_wrap:
									pop	cx
									loop	draw_fg_opaque_loop		; Loop if cx > 0

draw_fg_done:
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	ah,[di-1]
		or	ah,ah			; Zero ?
		jnz	draw_fg_subst_chk			; Jump if not zero
		retn

draw_fg_subst_chk:
		cmp	ah,19h
		jb	draw_fg_subst_scan			; Jump if below
		retn

draw_fg_subst_scan:
		push	di
		push	es
		mov	es,cs:[gvar_game_seg]
		mov	di,es:[tileset_buf_b]
		mov	cl,es:[di]
		or	cl,cl			; Zero ?
		jz	subst_done			; Jump if zero
		inc	di

subst_scan_loop:
									mov	al,es:[di]
									cmp	al,0FFh
									je	subst_done			; Jump if equal
									cmp	ah,al
									jne	subst_scan_next			; Jump if not equal
									mov	al,es:[di+1]
									mov	[si-1],al
									jmp	short subst_done

subst_scan_next:
									inc	di
									inc	di
									dec	cl
									jnz	subst_scan_loop			; Jump if not zero

subst_done:
		pop	es
		pop	di
		retn

mark_tile_FE_tga		endp
		db	0BFh, 9Bh, 41h		; mov di,419Bh  (dispatch entry: set di=tga_row_buf_a then fall to set_cx_6_tga)

set_cx_6_tga		proc	near
		mov	cx,6
set_cx_6_tga		endp

save_cs_then_op_tga		proc	near
		push	cs
		pop	es

copy_tile_loop:
									push	cx
									lodsb				; String [si] to al
									push	ds
									push	si
									mov	cl,20h			; ' '
									mul	cl			; ax = reg * al
									mov	si,ax
									add	si,tile_pixel_base
									mov	ds,cs:[gvar_game_seg]
									mov	cx,10h
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									pop	ds
									pop	cx
									loop	copy_tile_loop		; Loop if cx > 0

		retn

save_cs_then_op_tga		endp

draw_anim_tile:
		push	ds
		push	si
		push	es
		push	di
		mov	di,tile_map_arr
		movsw				; Mov [si] to es:[di]
		add	si,5
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dl,cs:[tile_col_idx]
		add	dl,4
		xor	dh,dh			; Zero register
		add	dx,word ptr cs:[starting_position_in_town]
		mov	ds:[tile_row_ctr],dx
		call	load_tile_list_then_use_tga
		mov	es:[tile_char_a],al
		cmp	byte ptr es:[tile_char_b],0FDh
		jne	draw_anim_no_b			; Jump if not equal
		inc	dx
		call	load_tile_list_then_use_tga
		mov	es:[tile_char_b],al

draw_anim_no_b:
		mov	si,tile_char_a
		mov	di,tga_row_buf_b
		call	set_cx_6_tga
		mov	si,cs:[tile_list_ptr]

draw_anim_scan_loop:
									call	init_status_row_alt_tga
									or	bl,bl			; Zero ?
									jz	draw_anim_skip			; Jump if zero
									push	si
									push	bx
									call	render_via_multiply3_tga
									pop	bx
									mov	es,cs:[gvar_game_seg]
									mov	si,tile_char_a
									call	save_di_via_bp_tga
									pop	si

draw_anim_skip:
									add	si,8
;*		cmp	word ptr [si],0FFFFh
									db	 83h, 3Ch,0FFh		;  Fixup - byte match
									jnz	draw_anim_scan_loop			; Jump if not zero
		pop	di
		pop	es
		mov	ch,es:[di-1]
		mov	cl,es:[di+7]
		push	es
		push	di
		push	cx
		mov	di,cs:[tile_col_x]
		add	di,640h
		push	di
		mov	si,tga_row_buf_b
		mov	ax,0B800h
		mov	es,ax
		inc	ch
		jz	draw_anim_no_above			; Jump if zero
		call	check_tile_state_tga

draw_anim_no_above:
		pop	di
		pop	cx
		cmp	byte ptr cs:[tile_col_idx],1Bh
		je	draw_anim_done			; Jump if equal
		mov	si,tga_row_buf_c
		add	di,4
		inc	cl
		jz	draw_anim_done			; Jump if zero
		call	check_tile_state_tga

draw_anim_done:
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

save_state_then_blit_tga		proc	near
		push	es
		push	ds
		mov	si,ds:[gvar_map_ptr]
		add	si,25h
		mov	di,tile_char_a
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dx,word ptr ds:[starting_position_in_town]
		add	dx,3
		mov	ds:[tile_row_ctr],dx
		cmp	byte ptr ds:[tile_char_a],0FDh
		jne	anim2_no_fd			; Jump if not equal
		inc	dx
		call	load_tile_list_then_use_tga
		mov	ds:[tile_char_a],al

anim2_no_fd:
		mov	si,tile_char_a
		mov	di,tga_row_buf_b
		mov	cx,3
		call	save_cs_then_op_tga
		mov	si,cs:[tile_list_ptr]

anim2_scan_loop:
									call	init_status_row_alt_tga
									or	bl,bl			; Zero ?
									jz	anim2_skip			; Jump if zero
									push	si
									dec	bl
									mov	al,3
									mul	bl			; ax = reg * al
									push	ax
									call	render_via_multiply3_tga
									pop	ax
									add	di,ax
									mov	bp,di
									mov	es,cs:[gvar_game_seg]
									mov	si,tile_char_a
									mov	di,tga_row_buf_b
									call	render_via_multiply4_tga
									pop	si

anim2_skip:
									add	si,8
;*		cmp	word ptr [si],0FFFFh
									db	 83h, 3Ch,0FFh		;  Fixup - byte match
									jnz	anim2_scan_loop			; Jump if not zero
		mov	di,scroll_dst_ofs
		mov	si,tga_row_buf_b
		mov	ax,0B800h
		mov	es,ax
		call	check_tile_state_tga
		pop	ds
		pop	es
		mov	di,marker_buf
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn

save_state_then_blit_tga		endp

load_tile_list_then_use_tga		proc	near
		call	load_tile_list_ptr_tga
		mov	al,[si+3]
		cmp	al,0FDh
		je	func8_next_entry			; Jump if equal
		retn

func8_next_entry:
									add	si,8
									call	noop_helper_tga
									mov	al,[si+3]
									cmp	al,0FDh
									je	func8_next_entry			; Jump if equal
		retn

load_tile_list_then_use_tga		endp

load_tile_list_ptr_tga		proc	near
		mov	si,ds:[tile_list_ptr]
load_tile_list_ptr_tga		endp

noop_helper_tga		proc	near

scan_entry_loop:
									cmp	dx,[si]
									jne	scan_entry_next			; Jump if not equal
									retn

scan_entry_next:
									add	si,8
									jmp	short scan_entry_loop

noop_helper_tga		endp

check_tile_state_tga		proc	near
		mov	cx,3

check_row_top:
		TGA_DI_WRAP_STEP check_r1_ok
		TGA_DI_WRAP_STEP check_r2_ok
		TGA_DI_WRAP_STEP check_r3_ok
		TGA_DI_WRAP_STEP check_r4_ok
		TGA_DI_WRAP_STEP check_r5_ok
		TGA_DI_WRAP_STEP check_r6_ok
		TGA_DI_WRAP_STEP check_r7_ok
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	check_row_loop_end			; Jump if below
		add	di,80A0h

check_row_loop_end:
		loop	check_row_loop		; Loop if cx > 0

		jmp	short check_state_ret

check_row_loop:
		jmp	check_row_top

check_state_ret:
		retn

check_tile_state_tga		endp

save_di_via_bp_tga		proc	near
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:[dispatch_tbl_a][bx]	;*
		retn

save_di_via_bp_tga		endp

; dispatch_tbl_a entries (Sourcer byte-match fixups):
;   db  C6h              -- padding byte
;   xor ax, 35BEh        -- entry 0: di=tga_row_buf_b (425Bh), then call mul4_loop entry
;   mov di, tga_row_buf_b; call +0x70; jmp mul4_start
;   add si, 3; mov di, tga_row_buf_c; jmp mul4_start  -- entry 2: advance si, set di=tga_row_buf_c
		db	0C6h, 35h,0BEh, 35h,0BFh, 5Bh	; entry 0: mov si,35BEh; mov di,425Bh
		db	 42h,0E8h, 70h, 00h,0EBh, 6Eh	; (cont) call rel +70h; jmp +6Eh (mul4_start)
		db	 83h,0C6h, 03h,0BFh,0BBh, 42h	; entry 2: add si,3; mov di,42BBh
		db	0EBh					; jmp short ...
		db	66h					; ...rel offset (continues into mul4_start)

render_via_multiply3_tga		proc	near
		mov	al,[si+2]
		mov	ch,al
		and	al,7Fh
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,4000h
		mov	di,ax
		xor	dl,dl			; Zero register
		or	ch,ch			; Zero ?
		js	mul3_is_back			; Jump if sign=1
		mov	dl,4

mul3_is_back:
		mov	al,[si+4]
		and	al,3
		add	al,dl
		mov	cl,6
		mul	cl			; ax = reg * al
		add	di,ax
		retn

render_via_multiply3_tga		endp

init_status_row_alt_tga		proc	near
		mov	cx,2
		mov	dx,ds:[tile_row_ctr]

scan2_match_loop:
									mov	bl,cl
									cmp	[si],dx
									jne	scan2_no_match			; Jump if not equal
									retn

scan2_no_match:
									inc	dx
									loop	scan2_match_loop		; Loop if cx > 0

		mov	bl,cl
		retn

init_status_row_alt_tga		endp

	; fn_get_val_b: dispatch-tbl_b trampoline -- saves bp=di, calls dispatch_tbl_b[bl-1]

fn_get_val_b:
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:[dispatch_tbl_b][bx]	;*
		retn

; fn_draw_type0: dispatch_tbl_b entry 0 -- adjust al by 0x36 then jump to mul4_start

fn_draw_type0:
		sub	al,36h			; '6'
		and	al,36h			; '6'
		sbb	al,36h			; '6'
		add	bp,3
		mov	di,tga_row_buf_a
		jmp	short mul4_start

; fn_draw_type1: dispatch_tbl_b entry 1 -- call render_via_multiply4_tga then jump to mul4_start

fn_draw_type1:
		mov	di,tga_row_buf_a
		call	render_via_multiply4_tga
		jmp	short mul4_start

; fn_draw_type2: dispatch_tbl_b entry 2 -- advance si by 3, jump to mul4_start

fn_draw_type2:
		mov	di,41FBh		; tga_hud_ofs + 3 (HUD tile area byte offset)
		add	si,3
		jmp	short mul4_start

render_via_multiply4_tga		proc	near

mul4_start:
		mov	cx,3

mul4_loop:
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
									mov	cl,20h			; ' '
									mul	cl			; ax = reg * al
									mov	si,ax
									add	si,tile_src_b
									shr	ax,1			; Shift w/zeros fill
									shr	ax,1			; Shift w/zeros fill
									add	ax,7000h
									mov	cs:[far_ptr_tmp],ax
									mov	ax,cs
									add	ax,2000h
									mov	word ptr cs:[far_ptr_tmp]+2,ax
									mov	ds,cs:[gvar_game_seg]
									push	cs
									pop	es
									call	save_ds_then_process_tga
									pop	bp
									pop	es
									pop	si
									pop	ds
									pop	cx
									loop	mul4_loop		; Loop if cx > 0

		retn

render_via_multiply4_tga		endp

; fn_load_tiles_a: load 6 tiles from tile_src_a (bank A at 6000h) into render buffer

fn_load_tiles_a:
		push	cs
		pop	es
		mov	di,tga_row_buf_a
		mov	cx,6

tile_load_loop:
									push	cx
									lodsb				; String [si] to al
									push	ds
									push	si
									mov	cl,20h			; ' '
									mul	cl			; ax = reg * al
									mov	si,ax
									add	si,tile_src_a
									shr	ax,1			; Shift w/zeros fill
									shr	ax,1			; Shift w/zeros fill
									add	ax,8000h
									mov	cs:[far_ptr_tmp],ax
									mov	ax,cs
									add	ax,2000h
									mov	word ptr cs:[far_ptr_tmp]+2,ax
									mov	ds,cs:[gvar_game_seg]
									call	save_ds_then_process_tga
									pop	si
									pop	ds
									pop	cx
									loop	tile_load_loop		; Loop if cx > 0

		retn

save_ds_then_process_tga		proc	near
		push	ds
		push	si
		push	di
		lds	si,dword ptr cs:[far_ptr_tmp]	; Load seg:offset ptr
		mov	cx,8

proc_mask_loop:
									push	cx
									lodsb				; String [si] to al
									call	init_4_byte_loop_alt_tga
									and	es:[di],dx
									call	init_4_byte_loop_alt_tga
									and	es:[di+2],dx
									add	di,4
									pop	cx
									loop	proc_mask_loop		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		mov	cx,8

proc_or_loop:
									lodsw				; String [si] to ax
									or	es:[di],ax
									lodsw				; String [si] to ax
									or	es:[di+2],ax
									add	di,4
									loop	proc_or_loop		; Loop if cx > 0

		retn

save_ds_then_process_tga		endp

; fn_scroll_left: scroll-left 16-wide then 8-wide rows in TGA B800 segment

fn_scroll_left:
		push	ds
		SET_ES_DS_TGA
		std				; Set direction flag
		mov	si,scroll_l16_src
		mov	al,8

scroll_l16_row:
									push	si
									mov	di,si
									sub	si,4
									mov	cx,36h
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									add	si,3Ch
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									pop	si
									add	si,2000h
									cmp	si,8000h
									jb	scroll_l16_wrap			; Jump if below
									add	si,80A0h

scroll_l16_wrap:
									dec	al
									jnz	scroll_l16_row			; Jump if not zero
		mov	si,scroll_r8_src_b
		mov	al,8

scroll_l8_row:
									push	si
									mov	di,si
									sub	si,8
									mov	cx,34h
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									add	si,40h
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									pop	si
									add	si,2000h
									cmp	si,8000h
									jb	scroll_l8_wrap			; Jump if below
									add	si,80A0h

scroll_l8_wrap:
									dec	al
									jnz	scroll_l8_row			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn

; fn_scroll_right_16: scroll-right 16-wide rows (16 rows, std direction)

fn_scroll_right_16:
		push	ds
		SET_ES_DS_TGA
		std				; Set direction flag
		mov	si,scroll_r16_src
		mov	al,10h

scroll_r16_row:
									push	si
									mov	di,si
									dec	si
									dec	si
									mov	cx,37h
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									add	si,3Ah
									movsw				; Mov [si] to es:[di]
									pop	si
									add	si,2000h
									cmp	si,8000h
									jb	scroll_r16_wrap			; Jump if below
									add	si,80A0h

scroll_r16_wrap:
									dec	al
									jnz	scroll_r16_row			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn
; fn_scroll_right_8: scroll-right 8-wide rows (8 rows, forward direction)

fn_scroll_right_8:
		push	ds
		SET_ES_DS_TGA
		mov	si,scroll_l8_src_b
		mov	al,8

scroll_r8a_row:
									push	si
									mov	di,si
									add	si,4
									mov	cx,36h
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									sub	si,3Ch
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									pop	si
									add	si,2000h
									cmp	si,8000h
									jb	scroll_r8a_wrap			; Jump if below
									add	si,80A0h

scroll_r8a_wrap:
									dec	al
									jnz	scroll_r8a_row			; Jump if not zero
		mov	si,scroll_r8_src_a
		mov	al,8

scroll_r8b_row:
									push	si
									mov	di,si
									add	si,8
									mov	cx,34h
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									sub	si,40h
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									pop	si
									add	si,2000h
									cmp	si,8000h
									jb	scroll_r8b_wrap			; Jump if below
									add	si,80A0h

scroll_r8b_wrap:
									dec	al
									jnz	scroll_r8b_row			; Jump if not zero
		pop	ds
		retn
	; fn_scroll_right_16b: scroll-right 16-wide rows from HUD offset (16 rows, forward)

fn_scroll_right_16b:
		push	ds
		SET_ES_DS_TGA
		mov	si,tga_hud_ofs
		mov	al,10h

scroll_r16b_row:
									push	si
									mov	di,si
									inc	si
									inc	si
									mov	cx,37h
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									sub	si,3Ah
									movsw				; Mov [si] to es:[di]
									pop	si
									add	si,2000h
									cmp	si,8000h
									jb	scroll_r16b_wrap			; Jump if below
									add	si,80A0h

scroll_r16b_wrap:
									dec	al
									jnz	scroll_r16b_row			; Jump if not zero
		pop	ds
		retn
; fn_blit_tile_seg: blit tile from game_seg:8000h to TGA B800 via extract_bits

fn_blit_tile_seg:
		push	ds
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,8000h
		add	bh,bh
		add	bh,bh
		call	extract_bits
		mov	di,ax
		mov	ds,cs:[gvar_game_seg]
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

blit_seg_row_loop:
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									add	di,1FFCh
									cmp	di,8000h
									jb	blit_seg_wrap_ok			; Jump if below
									add	di,80A0h

blit_seg_wrap_ok:
									loop	blit_seg_row_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn
; fn_blit_icon: blit icon glyph data from CS segment to TGA B800

fn_blit_icon:
		push	ds
		push	si
		push	di
		push	cs
		pop	ds
		add	bh,bh
		call	extract_bits
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	si,tile_gfx_data
		mov	cx,9

icon_blit_loop:
									movsw				; Mov [si] to es:[di]
									movsw				; Mov [si] to es:[di]
									add	di,1FFCh
									cmp	di,8000h
									jb	icon_blit_wrap_ok			; Jump if below
									add	di,tga_wrap

icon_blit_wrap_ok:
									loop	icon_blit_loop		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		retn
; Static icon/cursor pattern data (6 bytes/row x 6 rows, TGA nibble-packed):
; Row 0: 00 00 00 00 0C C0  (blank, then 2 lit pixels)
; Row 1: 00 00 0C CC 00 00  (middle filled)
; Row 2: 0C CC C0 00 0C CC  ...
; Row 3: CC 00 0C CC C0 00
; Row 4: 0C CC 00 00 0C C0
; Row 5: 00 00 00 00 00 00  (blank)
		db	 00h, 00h, 00h, 00h, 0Ch,0C0h	; row 0
		db	 00h, 00h, 0Ch,0CCh, 00h, 00h	; row 1
		db	 0Ch,0CCh,0C0h, 00h, 0Ch,0CCh	; row 2
		db	0CCh, 00h, 0Ch,0CCh,0C0h, 00h	; row 3
		db	 0Ch,0CCh, 00h, 00h, 0Ch,0C0h	; row 4
		db	 00h, 00h, 00h, 00h, 00h, 00h	; row 5
; Setup code for movsw_rep_loop: call +0x598; mov di,ax; mov si,glyph_buf; mov ax,0B800h; mov es,ax; mov cx,9
		db	 02h,0FFh,0E8h, 98h, 05h, 8Bh	; opcodes: 02FFh; call +0598h; mov ...
		db	0F8h,0BEh, 7Bh, 3Eh,0B8h, 00h	; mov di,ax; mov si,3E7Bh; mov ax,...
		db	0B8h, 8Eh,0C0h,0B9h, 09h, 00h	; ...0B8h; mov es,ax; mov cx,9

movsw_rep_loop:
									push	cx
									push	di
									push	si
									mov	cx,ds:[gvar_copy_width]
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									add	si,50h
									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	movsw_wrap_ok			; Jump if below
									add	di,80A0h

movsw_wrap_ok:
									pop	cx
									loop	movsw_rep_loop		; Loop if cx > 0

		retn
; fn_draw_char: render string char-by-char into glyph_buf, optionally with item overlay

fn_draw_char:
		push	si
		push	di
		push	di
		xor	ah,ah			; Zero register
		push	ax
		push	cs
		pop	es
		mov	di,glyph_buf
		xor	ax,ax			; Zero register
		mov	cx,190h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		push	ax
		add	ax,ax
		add	si,ax
		mov	si,[si]
		call	init_text_render_buf_tga
		pop	ax
		pop	di
		test	byte ptr ds:[gvar_item_flag],0FFh
		jz	ploop2_no_item			; Jump if zero
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	di,ax
		mov	dl,[di]
		mov	ax,[di+1]
		call	render_via_text_decimal_tga

ploop2_no_item:
		pop	di
		pop	si
		retn

init_text_render_buf_tga		proc	near
		push	cs
		pop	es
		mov	di,glyph_render_ofs
		xor	bl,bl			; Zero register

func17_loop:
									lodsb				; String [si] to al
									or	al,al			; Zero ?
									jnz	func17_nonzero			; Jump if not zero
									retn

func17_nonzero:
									push	bx
									push	ds
									push	si
									and	bl,1
									call	compute_glyph_index_tga
									pop	si
									pop	ds
									pop	bx
									inc	bl
									jmp	short func17_loop

init_text_render_buf_tga		endp

compute_glyph_index_tga		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:[font_ptr_b]
		add	bl,bl
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8

func18_bit_loop:
									push	bx
									lodsb				; String [si] to al
									call	init_2_iter_loop_tga
									push	ax
									call	init_2_iter_loop_tga
									pop	bx
									mov	bl,ah
									mov	dh,bl
									xor	dl,dl			; Zero register
									shr	bx,cl			; Shift w/zeros fill
									shr	dx,cl			; Shift w/zeros fill
									mov	dh,dl
									xor	dl,dl			; Zero register
									xchg	bh,bl
									xchg	dh,dl
									or	es:[di],bx
									or	es:[di+2],dx
									add	di,50h
									pop	bx
									dec	bl
									jnz	func18_bit_loop			; Jump if not zero
		pop	di
		inc	di
		inc	di
		cmp	cl,4
		je	func18_wide			; Jump if equal
		retn

func18_wide:
		inc	di
		retn

compute_glyph_index_tga		endp

init_2_iter_loop_tga		proc	near
		xor	ah,ah			; Zero register
		mov	dl,2

func19_bit_loop:
									add	al,al
									sbb	dh,dh
									and	dh,0Fh
									add	ah,ah
									add	ah,ah
									add	ah,ah
									add	ah,ah
									or	ah,dh
									dec	dl
									jnz	func19_bit_loop			; Jump if not zero
		retn

init_2_iter_loop_tga		endp

; fn_draw_char_alt: alternate draw-char entry (dx:ax args), uses render_via_text_decimal_tga

fn_draw_char_alt:
		push	dx
		push	ax
		push	cs
		pop	es
		mov	di,glyph_buf
		xor	ax,ax			; Zero register
		mov	cx,190h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		pop	dx
		call	render_text_decimal_tga
		mov	di,glyph_render_ofs
		mov	si,bcd_time_buf
		mov	cx,7
		mov	bl,1
		mov	word ptr ds:[gvar_copy_width],0Bh
		jmp	short proc2_col_loop

render_via_text_decimal_tga		proc	near
		call	render_text_decimal_tga
		push	cs
		pop	es
		mov	di,glyph_render_ofs
		mov	ax,ds:[gvar_text_ofs]
		add	ax,ax
		add	di,ax
		inc	di
		mov	si,anim_frame_data
		mov	cx,6

proc2_col_loop:
									push	cx
									push	di
									lodsb				; String [si] to al
									push	si
									call	step_render_alt_tga
									pop	si
									pop	di
									add	di,3
									pop	cx
									loop	proc2_col_loop		; Loop if cx > 0

		retn

render_via_text_decimal_tga		endp

step_render_alt_tga		proc	near
		inc	al
		jnz	proc3_nonzero			; Jump if not zero
		retn

proc3_nonzero:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:[font_ptr_a]
		mov	si,ax
		mov	cx,7

proc3_row_loop:
									lodsb				; String [si] to al
									add	al,al
									add	al,al
									call	init_2_iter_loop_tga
									or	es:[di],ah
									call	init_2_iter_loop_tga
									or	es:[di+1],ah
									call	init_2_iter_loop_tga
									or	es:[di+2],ah
									add	di,50h
									loop	proc3_row_loop		; Loop if cx > 0

		retn

step_render_alt_tga		endp

render_text_decimal_tga		proc	near
		mov	di,bcd_time_buf
		call	div_24bit_emit_digit_tga
		mov	cx,6

proc4_check_loop:
									test	byte ptr cs:[di],0FFh
									jz	proc4_write_ff			; Jump if zero
									retn

proc4_write_ff:
									mov	byte ptr cs:[di],0FFh
									inc	di
									loop	proc4_check_loop		; Loop if cx > 0

		retn

bcd_time_buf_lbl:
render_text_decimal_tga		endp

; bcd_time_buf: 7-byte BCD time buffer at CS:3A1Fh (written by div_24bit_emit_digit_tga)
; Fields: [0]=tens-of-hours [1]=hours [2]=tens-of-minutes [3]=minutes
;         [4]=tens-of-seconds [5]=seconds [6]=frames
		db	7 dup (0)

div_24bit_emit_digit_tga		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	div_16bit_emit_digit_tga
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	div_16bit_emit_digit_tga
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	div_16bit_emit_digit_tga
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	div_16bit_emit_digit_alt_tga
		mov	cs:[di+3],dh
		mov	bx,64h
		call	div_16bit_emit_digit_alt_tga
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	div_16bit_emit_digit_alt_tga
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn

div_24bit_emit_digit_tga		endp

div_16bit_emit_digit_tga		proc	near
		xor	dh,dh			; Zero register

func24_div_loop:
									sub	dl,cl
									jc	func24_done			; Jump if carry Set
									sub	ax,bx
									jnc	func24_inc_dh			; Jump if carry=0
									or	dl,dl			; Zero ?
									jz	func24_add_back			; Jump if zero
									dec	dl

func24_inc_dh:
									inc	dh
									jmp	short func24_div_loop

func24_add_back:
		add	ax,bx

func24_done:
		add	dl,cl
		retn

div_16bit_emit_digit_tga		endp

div_16bit_emit_digit_alt_tga		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn

div_16bit_emit_digit_alt_tga		endp

; fn_scroll_back: scroll one tile column backward in TGA B800 (bh/bl coords, ch=width)

fn_scroll_back:
		push	ds
		push	ax
		add	bh,bh
		add	bl,cl
		dec	bl
		call	extract_bits
		mov	di,ax
		mov	si,ax
		sub	si,2000h
		jnc	scrollback_si_ok			; Jump if carry=0
		add	si,tga_wrap_sub2

scrollback_si_ok:
		SET_ES_DS_TGA
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

scrollback_row_loop:
									push	cx
									push	di
									push	si
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									pop	di
									sub	si,2000h
									jnc	scrollback_si_wrap			; Jump if carry=0
									add	si,tga_wrap_sub

scrollback_si_wrap:
									sub	di,2000h
									jnc	scrollback_di_wrap			; Jump if carry=0
									add	di,tga_wrap_sub2

scrollback_di_wrap:
									pop	cx
									loop	scrollback_row_loop		; Loop if cx > 0

		pop	ax
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,3E7Bh
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
; fn_scroll_fwd: scroll one tile column forward in TGA B800 (bh/bl coords, ch=width)

fn_scroll_fwd:
		push	ds
		push	ax
		add	bh,bh
		call	extract_bits
		mov	di,ax
		mov	si,ax
		add	si,2000h
		cmp	si,8000h
		jb	scrollfwd_si_ok			; Jump if below
		add	si,tga_wrap2

scrollfwd_si_ok:
		SET_ES_DS_TGA
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

scrollfwd_row_loop:
									push	cx
									push	di
									push	si
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									pop	di
									add	si,2000h
									cmp	si,8000h
									jb	scrollfwd_si_wrap			; Jump if below
									add	si,tga_wrap

scrollfwd_si_wrap:
									add	di,2000h
									cmp	di,8000h
									jb	scrollfwd_di_wrap			; Jump if below
									add	di,tga_wrap2

scrollfwd_di_wrap:
									pop	cx
									loop	scrollfwd_row_loop		; Loop if cx > 0

		pop	ax
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,3E7Bh
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
; fn_flash_screen: XOR-flash HUD area with 0xEEEE pattern (8 TGA pages x 18 rows)

fn_flash_screen:
		mov	ax,0B800h
		mov	es,ax
		mov	di,tga_hud_ofs
		mov	cx,8

flash_page_loop:
									push	cx
									push	di
									mov	cx,12h

flash_row_loop:
																push	cx
																push	di
																mov	cx,38h
																mov	ax,0EEEEh

flash_col_loop:
																xor	es:[di],ax
																inc	di
																inc	di
																loop	flash_col_loop		; Loop if cx > 0

																pop	di
																add	di,140h
																pop	cx
																loop	flash_row_loop		; Loop if cx > 0

									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	flash_page_wrap			; Jump if below
									add	di,80A0h

flash_page_wrap:
									pop	cx
									loop	flash_page_loop		; Loop if cx > 0

		retn
; fn_encode_tiles: encode tile pixel data into TGA nibble format (cs+3000h dest)

fn_encode_tiles:
		mov	cs:[far_ptr_tmp],di
		mov	word ptr cs:[far_ptr_tmp]+2,es
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

encode_page_loop:
									push	cx
									mov	cx,8

encode_tile_loop:
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
																xchg	dh,dl
																mov	cs:[bitplane_0],dx
																xchg	ch,cl
																mov	cs:[bitplane_1],cx
																xchg	bh,bl
																mov	cs:[bitplane_2],bx
																xchg	ah,al
																not	ax
																mov	cs:[bitplane_3],ax
																call	init_4_byte_loop_tga
																mov	ax,dx
																xchg	ah,al
																stosw				; Store ax to es:[di]
																call	init_4_byte_loop_tga
																mov	ax,dx
																xchg	ah,al
																stosw				; Store ax to es:[di]
																push	es
																push	di
																les	di,dword ptr cs:[far_ptr_tmp]	; Load seg:offset ptr
																call	step_scan_alt_tga
																mov	al,dl
																stosb				; Store al to es:[di]
																mov	cs:[far_ptr_tmp],di
																pop	di
																pop	es
																pop	cx
																loop	encode_tile_loop		; Loop if cx > 0

									pop	cx
									loop	encode_page_loop		; Loop if cx > 0

		retn
; fn_load_tile_pixels: copy tile pixel data from game_seg then dispatch encode by tile type

fn_load_tile_pixels:
		push	ds
		mov	ds,cs:[gvar_game_seg]
		mov	si,tile_pixel_base
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	cx,2EE0h
		mov	di,zero_offset
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	es,cs:[gvar_game_seg]
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,0
		mov	di,8100h
		mov	bx,es:[tileset_buf_a]
		mov	bp,0D000h
		mov	cx,0FAh

tile_type_loop:
									push	cx
									mov	al,es:[bx]
									cmp	al,5
									jb	tile_type_clamp			; Jump if below
									xor	al,al			; Zero register

tile_type_clamp:
									push	bx
									xor	bx,bx			; Zero register
									mov	bl,al
									add	bx,bx
									call	word ptr cs:[tile_render_disp][bx]	;*
									pop	bx
									inc	bx
									pop	cx
									loop	tile_type_loop		; Loop if cx > 0

		pop	ds
		retn
; fn_encode_mode: dispatch to encode_modeN loop based on tile color mode (carry flag)

fn_encode_mode:
		jc	encode_mode1_top			; Jump if carry Set
		movsw				; Mov [si] to es:[di]
		cmp	al,0E1h
		cmp	al,1Dh
		cmp	ax,3D59h
		mov	cx,8

encode_mode0_loop:
									push	cx
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_0],ax
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_1],ax
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_2],ax
									call	init_4_byte_loop_tga
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									call	init_4_byte_loop_tga
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									mov	byte ptr es:[bp],0
									inc	bp
									pop	cx
									loop	encode_mode0_loop		; Loop if cx > 0

		retn
		db	0B9h			; first byte of: mov cx,8 (entry for encode_mode1 + encode_mode0)

encode_mode1_top:
		or	[bx+si],al

encode_mode1_loop:
									push	cx
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_0],ax
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_1],ax
									mov	word ptr cs:[bitplane_2],0
									lodsw				; String [si] to ax
									xchg	al,ah
									mov	cs:[bitplane_3],ax
									call	init_4_byte_loop_tga
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									call	init_4_byte_loop_tga
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									call	step_scan_alt_tga
									mov	es:[bp],dl
									inc	bp
									pop	cx
									loop	encode_mode1_loop		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h		; mov cx,8  (loop init for encode_mode2_loop)

encode_mode2_loop:
									push	cx
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_0],ax
									lodsw				; String [si] to ax
									xchg	al,ah
									mov	cs:[bitplane_3],ax
									mov	word ptr cs:[bitplane_1],0
									lodsw				; String [si] to ax
									xchg	al,ah
									mov	cs:[bitplane_2],ax
									call	init_4_byte_loop_tga
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									call	init_4_byte_loop_tga
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									call	step_scan_alt_tga
									mov	es:[bp],dl
									inc	bp
									pop	cx
									loop	encode_mode2_loop		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h		; mov cx,8  (loop init for encode_mode3_loop)

encode_mode3_loop:
									push	cx
									lodsw				; String [si] to ax
									xchg	al,ah
									mov	cs:[bitplane_3],ax
									mov	word ptr cs:[bitplane_0],0
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_1],ax
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_2],ax
									call	init_4_byte_loop_tga
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									call	init_4_byte_loop_tga
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									call	step_scan_alt_tga
									mov	es:[bp],dl
									inc	bp
									pop	cx
									loop	encode_mode3_loop		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h		; mov cx,8  (loop init for encode_mode4_loop)

encode_mode4_loop:
									push	cx
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_0],ax
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_1],ax
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:[bitplane_2],ax
									call	init_4_byte_loop_tga
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									call	init_4_byte_loop_tga
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									mov	byte ptr es:[bp],0FFh
									inc	bp
									pop	cx
									loop	encode_mode4_loop		; Loop if cx > 0

		retn

init_4_byte_loop_tga		proc	near
		mov	cx,4

proc5_nibble_loop:
									xor	bx,bx			; Zero register
									rol	word ptr cs:[bitplane_2],1	; Rotate
									adc	bx,bx
									rol	word ptr cs:[bitplane_1],1	; Rotate
									adc	bx,bx
									rol	word ptr cs:[bitplane_0],1	; Rotate
									adc	bx,bx
									rol	word ptr cs:[bitplane_2],1	; Rotate
									adc	bx,bx
									rol	word ptr cs:[bitplane_1],1	; Rotate
									adc	bx,bx
									rol	word ptr cs:[bitplane_0],1	; Rotate
									adc	bx,bx
									add	dx,dx
									add	dx,dx
									add	dx,dx
									add	dx,dx
									or	dl,cs:[color_lut][bx]
									loop	proc5_nibble_loop		; Loop if cx > 0

		retn

init_4_byte_loop_tga		endp

; color_lut_data: 62-entry bitplane-index to TGA 4-bit color lookup table (color_lut equ 3DCBh)
; Indexed by 6-bit bitplane combination [bp2:bp1:bp0] x 2 passes; maps to TGA nibble color.
		db	 00h, 07h, 04h, 02h, 03h, 01h	; color_lut[ 0..5]
		db	 08h, 05h, 07h, 0Fh, 0Ch, 0Eh	; color_lut[ 6..11]
		db	 0Bh, 09h, 0Eh, 0Dh, 04h, 0Ch	; color_lut[12..17]
		db	 0Ch, 0Eh, 07h, 05h, 06h, 0Ch	; color_lut[18..23]
		db	 02h, 0Eh, 0Eh, 0Ah, 0Ah, 03h	; color_lut[24..29]
		db	 0Ah, 07h, 03h, 0Bh, 07h, 0Ah	; color_lut[30..35]
		db	 0Bh, 09h, 0Ah, 09h, 01h, 09h	; color_lut[36..41]
		db	 05h, 03h, 09h, 09h, 07h, 05h	; color_lut[42..47]
		db	 08h, 0Eh, 06h, 0Ah, 0Ah, 07h	; color_lut[48..53]
		db	 0Eh, 0Ch, 05h, 0Dh, 0Ch, 07h	; color_lut[54..59]
		db	 09h, 05h			; color_lut[60..61]
		db	 0Ch, 0Dh			; color_lut[62..63] (continued)

step_scan_alt_tga		proc	near
		mov	cx,8

scan3_bit_loop:
									xor	al,al			; Zero register
									rol	word ptr cs:[bitplane_3],1	; Rotate
									adc	al,al
									rol	word ptr cs:[bitplane_3],1	; Rotate
									adc	al,al
									cmp	al,3
									je	scan3_is_3			; Jump if equal
									xor	al,al			; Zero register

scan3_is_3:
									and	al,1
									add	dl,dl
									or	dl,al
									loop	scan3_bit_loop		; Loop if cx > 0

		retn

step_scan_alt_tga		endp

extract_bits		proc	near
		mov	dh,bl
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		mov	ax,0A0h
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		mul	bl			; ax = reg * al
		add	ax,dx
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		retn

extract_bits		endp

init_4_byte_loop_alt_tga		proc	near
		mov	cx,4

proc6_bit_loop:
									add	al,al
									sbb	ah,ah
									and	ah,0Fh
									add	dx,dx
									add	dx,dx
									add	dx,dx
									add	dx,dx
									or	dl,ah
									loop	proc6_bit_loop		; Loop if cx > 0

		xchg	dh,dl
		retn

init_4_byte_loop_alt_tga		endp

		db	1719 dup (0)

seg_a		ends

		end	start
