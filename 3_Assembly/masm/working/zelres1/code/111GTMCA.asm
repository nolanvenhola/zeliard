
PAGE  59,132

;==========================================================================
;
;  111GTMCA - Town Tiles MCGA Renderer (zelres1 chunk 12, gtmcga.bin)
;
;  MCGA/VGA-specific tilemap renderer for the town/overworld engine.
;  Loaded by game.bin into the game segment (gfx_mode_tbl_all entry,
;  mode 4) alongside 106TOWN (town.bin). Provides tile blit, scroll,
;  character cell rendering, and text-glyph functions exposed via
;  dispatch slots consumed by 106TOWN. Uses VGA framebuffer at A000:0.
;
;  Connections:
;    Loads:        none (rendering primitives only)
;    Calls into:   render_fn_tbl_* (CS dispatch tables, set internally
;                  per tile type); VGA framebuffer writes to A000:0
;    Called by:    game.bin LOAD_CHUNK chunk_ref_gtmcga via gfx_mode_tbl_all
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
gvar_plystate	equ	0FF2Ah			;* global player state struct pointer
gvar_game_seg	equ	0FF2Ch			;* global game segment selector
gvar_flag57	equ	0FF57h			;* global boolean flag at FF57h

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
; restored after factoring (different value than zr1com.inc would supply):
font_ptr_a               equ     0F502h
; --- game segment data (DS = gvar_game_seg) ---
tile_cache_base	equ	8000h			;* tile graphics cache lookup table
map_overlay_ptr	equ	8004h			;* map overlay data pointer
tile_src_base	equ	8100h			;* tile source graphics data base
overlay_seg	equ	0D000h			;* overlay data segment
dispatch_tbl_a	equ	34D8h			;* scroll-mode function dispatch table A	;* DBG: DBG_CHUNK_BASE + offset dispatch_tbl_a_lbl
dispatch_tbl_b	equ	3534h			;* scroll-mode function dispatch table B	;* DBG: DBG_CHUNK_BASE + offset dispatch_tbl_b_lbl
char_glyph_base	equ	DBG_CHUNK_BASE + offset cursor_glyph		;* character glyph bitmap data base
border_glyph_ptr equ	392Ah			;* border glyph source pointer
dispatch_tbl_c	equ	3B4Bh			;* tile-type function dispatch table C	;* DBG: DBG_CHUNK_BASE + offset dispatch_tbl_c_lbl
tile_vga_ofs	equ	3C98h			;* current VGA tile destination offset (word)
tile_id_a	equ	3C9Bh			;* tile ID byte A (3-byte region)	;* DBG: DBG_CHUNK_BASE + offset tile_id_a_lbl
tile_id_b	equ	3C9Eh			;* tile ID byte B	;* DBG: DBG_CHUNK_BASE + offset tile_id_b_lbl
scroll_col	equ	3CA1h			;* scroll column position word	;* DBG: DBG_CHUNK_BASE + offset scroll_col_lbl
bitplane_0	equ	3CA3h			;* bitplane 0 shift register (word)	;* DBG: DBG_CHUNK_BASE + offset bitplane_0_lbl
bitplane_1	equ	3CA5h			;* bitplane 1 shift register (word)	;* DBG: DBG_CHUNK_BASE + offset bitplane_1_lbl
bitplane_2	equ	3CA7h			;* bitplane 2 shift register (word)	;* DBG: DBG_CHUNK_BASE + offset bitplane_2_lbl
bitplane_3	equ	3CA9h			;* bitplane 3 (alpha) shift register (word)	;* DBG: DBG_CHUNK_BASE + offset bitplane_3_lbl
glyph_far_ptr	equ	3CABh			;* far pointer (dword) to glyph source data	;* DBG: DBG_CHUNK_BASE + offset glyph_far_ptr_lbl
tile_bitbuf	equ	3CAFh			;* tile bitmask working buffer (~800 bytes)
glyph_outbuf	equ	3D4Fh			;* glyph decoded output buffer
glyph_rowbuf	equ	3DEFh			;* glyph row staging buffer
tileset_base	equ	4100h			;* tileset graphics base in game segment
tile_cache_tbl	equ	42EFh			;* tile VGA cache table (word array, 256 entries)	;* DBG: DBG_CHUNK_BASE + offset tile_cache_tbl_lbl
chunk0_base	equ	6000h			;* chunk 0 (opening scene) base offset
scroll_entry_ptr equ	0C00Fh			;* scroll/tilemap entry list pointer
npc_flag_ptr	equ	0E005h			;* NPC presence flag pointer
font_ptr_b	equ	0F502h			;* font B graphics pointer (see gmmcga font_ptr_b)
font_ptr_c	equ	0F504h			;* font C graphics pointer (see gmmcga font_ptr_c)
stride_minus_8	equ	138h			; 312: VGA stride minus 8 (skip row after 8px tile)
vga_stride	equ	140h			; 320: VGA mode 13h row stride in bytes
hud_vga_ofs	equ	11B0h			; VGA offset for HUD row (row 14, col 48)
hud_vga_ofs2	equ	128Eh			; VGA offset for second HUD element
tile_buf_ofs	equ	3200h			; scroll tile staging buffer offset
tile_id_mid	equ	3C9Ch			; middle byte of tile ID triplet (tile_id_a+1)
; --- on-screen VGA tile positions ---
vga_tile_left	equ	93B0h			; VGA offset: left tile column row 118, col 48
vga_tile_l2	equ	0B1B0h			; VGA offset: second left tile area row 142, col 48
vga_tile_r2	equ	0B28Eh			; VGA offset: second right tile area row 142, col 270
vga_tile_l3	equ	0BBB0h			; VGA offset: third left tile area row 150, col 48
vga_tile_r3	equ	0BC8Eh			; VGA offset: third right tile area row 150, col 270
; --- off-screen VGA tile work buffers (A000:FA00-FFFF) ---
tile_offscr_a	equ	0FA00h			; off-screen tile buffer A (col 0)
tile_offscr_b	equ	0FAC0h			; off-screen tile buffer B (col 192)
tile_offscr_c	equ	0FB80h			; off-screen tile buffer C (row+1)
tile_offscr_d	equ	0FC40h			; off-screen tile buffer D (row+2)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
tile_col_idx	equ	3C9Ah			;* tile column index counter (byte, 0..27)	;* DBG: DBG_CHUNK_BASE + offset tile_col_idx_lbl

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
; --- numeric constants (internal) ---
half_stride	equ	80h			; 128: half of VGA row stride

; SET_ES_DS_VGA
;   ES = DS = A000h (set both segments to VGA framebuffer).
SET_ES_DS_VGA	MACRO
		mov	ax, 0A000h
		mov	es, ax
		mov	ds, ax
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

run_gtmca_main		proc	far

start:
; Init block: 11 bytes prefix + 34 bytes dispatch table + 16 bytes VGA setup
; Bytes [0-10]: garbage decode (Sourcer misidentified as instructions; actual data)
; Bytes [11-44]: 17 big-endian word pairs = game_seg function pointers for dispatch tables
;   (initialized into dispatch_tbl_a/dispatch_tbl_b/dispatch_tbl_c by game engine at load)
;   dw 3677h, 36A4h, 36F1h, 36FCh, 3226h, 359Ah, 35ECh, 341Ch
;   dw 3785h, 3705h, 38CCh, 3799h, 39EFh, 398Eh, 38F9h, 3A71h, 3A1Eh
; Bytes [45-60]: VGA setup: mov si,61B0h; mov di,0A000h; push cs; pop es; mov ax,0A000h; mov ds,ax; mov cx,28
		out	dx,ax			; (data byte EFh -- part of dispatch init block)
		adc	al,0
		add	[bx+di+3Ah],al
		sub	[bx+si],dh
		push	cx
		xor	[bx+si],ch
		db	 36h, 77h, 36h,0A4h, 36h,0F1h	; dispatch words: 3677h, 36A4h, 36F1h
		db	 36h,0FCh, 32h, 26h, 35h, 9Ah	; dispatch words: 36FCh, 3226h, 359Ah
		db	 35h,0ECh, 34h, 1Ch, 37h, 85h	; dispatch words: 35ECh, 341Ch, 3785h
		db	 37h, 05h, 38h,0CCh, 37h, 99h	; dispatch words: 3705h, 38CCh, 3799h
		db	 39h,0EFh, 39h, 8Eh, 38h,0F9h	; dispatch words: 39EFh, 398Eh, 38F9h
		db	 3Ah, 71h, 3Ah, 1Eh,0BEh,0B0h	; last 2 words (3A71h,3A1Eh) + MOV SI,61B0h start
		db	 61h,0BFh, 00h,0A0h, 0Eh, 07h	; MOV DI,0A000h; PUSH CS; POP ES
		db	0B8h, 00h,0A0h, 8Eh,0D8h,0B9h	; MOV AX,0A000h; MOV DS,AX; MOV CX,...
		db	 1Ch, 00h			; ...28 (0x1C)

copy_tile_row_loop:
					push	cx
					push	si
					mov	cx,18h

copy_tile_cols_loop:
								movsw				; Mov [si] to es:[di]
								movsw				; Mov [si] to es:[di]
								movsw				; Mov [si] to es:[di]
								movsw				; Mov [si] to es:[di]
								add	si,138h
								loop	copy_tile_cols_loop		; Loop if cx > 0

					pop	si
					pop	cx
					add	si,8
					loop	copy_tile_row_loop		; Loop if cx > 0

		pop	ds
		retn

; Called via dispatch_tbl_a to initialize tile cache and render tilemap column

init_and_render_col:			;* No entry point to code
		push	cs
		pop	es
		mov	di,tile_cache_tbl
		xor	ax,ax			; Zero register
		mov	cx,100h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,ds:[gvar_plystate]
		cmp	byte ptr [si+1Dh],0FDh
		jne	check_scroll_tile			; Jump if not equal
		call	save_state_then_blit_mca

check_scroll_tile:
		mov	word ptr ds:[tile_vga_ofs],61B0h
		mov	si,ds:[gvar_plystate]
		add	si,20h
		push	cs
		pop	es
		mov	di,0E000h
		mov	byte ptr ds:[tile_col_idx],0

render_col_loop:
					call	run_render_passes_gtmca
					xor	bl,bl			; Zero register
					cmpsb				; Cmp [si] to es:[di]
					jz	tile_skip_0			; Jump if zero
					call	mark_tile_FE_mca

tile_skip_0:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	tile_skip_1			; Jump if zero
					call	mark_tile_FE_mca

tile_skip_1:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	tile_skip_2			; Jump if zero
					call	mark_tile_FE_mca

tile_skip_2:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	tile_skip_3			; Jump if zero
					call	render_tile_entry_mca

tile_skip_3:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	tile_skip_4			; Jump if zero
					call	render_tile_entry_mca

tile_skip_4:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	tile_skip_5			; Jump if zero
					call	render_tile_if_marked_mca

tile_skip_5:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	tile_skip_6			; Jump if zero
					call	render_tile_entry_mca

tile_skip_6:
					inc	bl
					cmpsb				; Cmp [si] to es:[di]
					jz	tile_skip_7			; Jump if zero
					call	render_tile_entry_mca

tile_skip_7:
					add	word ptr ds:[tile_vga_ofs],8
					inc	byte ptr ds:[tile_col_idx]
					cmp	byte ptr ds:[tile_col_idx],1Ch
					jne	render_col_loop			; Jump if not equal
		retn

run_gtmca_main		endp

run_render_passes_gtmca		proc	near
		cmp	byte ptr ds:[tile_col_idx],1Bh
		jne	vga_op_not_last			; Jump if not equal
		retn

vga_op_not_last:
		mov	al,byte ptr ds:[screen_position]
		cmp	ds:[tile_col_idx],al
		je	vga_op_do_copy			; Jump if equal
		retn

vga_op_do_copy:
		push	di
		push	es
		push	si
		push	ds
		mov	al,byte ptr ds:[screen_position]
		add	al,al
		add	al,al
		add	al,al
		xor	ah,ah			; Zero register
		mov	di,ax
		add	di,vga_tile_left
		SET_ES_DS_VGA
		mov	si,tile_offscr_a
		mov	cx,2

blit_pair_loop:
					push	cx
					push	di
					call	init_4E_loop_mca
					pop	di
					add	di,8
					pop	cx
					loop	blit_pair_loop		; Loop if cx > 0

		pop	ds
		pop	si
		pop	es
		pop	di
		retn

run_render_passes_gtmca		endp

render_tile_if_marked_mca		proc	near
		cmp	byte ptr [si-1],0FDh
		jne	render_tile			; Jump if not equal
		jmp	handle_scroll_tile

render_tile_if_marked_mca		endp

render_tile_entry_mca		proc	near

render_tile:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	tile_changed			; Jump if not zero
		retn

tile_changed:
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
		add	bx,bx
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:[tile_vga_ofs]
		mov	di,ax
		pop	dx
		mov	bl,dl
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:[tile_cache_tbl][bx],0FFFFh
		jnz	tile_cached			; Jump if not zero
		mov	ds:[tile_cache_tbl][bx],di
		mov	ax,30h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,tile_src_base
		mov	ds,cs:[gvar_game_seg]
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

blit_8rows_loop:
					push	cx
					mov	cx,2

blit_3planes_loop:
								lodsw				; String [si] to ax
								mov	dx,ax
								lodsb				; String [si] to al
								mov	bl,al
								mov	bh,dl
								shr	dx,1			; Shift w/zeros fill
								shr	dx,1			; Shift w/zeros fill
								mov	es:[di],dh
								shr	dl,1			; Shift w/zeros fill
								shr	dl,1			; Shift w/zeros fill
								mov	es:[di+1],dl
								add	bx,bx
								add	bx,bx
								and	bh,3Fh			; '?'
								mov	es:[di+2],bh
								and	al,3Fh			; '?'
								mov	es:[di+3],al
								add	di,4
								loop	blit_3planes_loop		; Loop if cx > 0

					add	di,stride_minus_8
					pop	cx
					loop	blit_8rows_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

tile_cached:
		mov	si,ds:[tile_cache_tbl][bx]
		SET_ES_DS_VGA
		mov	cx,8

blit_cached_loop:
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					add	di,138h
					add	si,138h
					loop	blit_cached_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

render_tile_entry_mca		endp

mark_tile_FE_mca		proc	near
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	render_tile_overlay			; Jump if not zero
		retn

render_tile_overlay:
		push	bx
		push	es
		mov	dl,[si-1]
		mov	bl,dl
		xor	bh,bh			; Zero register
		mov	es,cs:[gvar_game_seg]
		add	bx,es:[tile_cache_base]
		mov	dh,es:[bx]
		pop	es
		pop	bx
		or	dh,dh			; Zero ?
		jnz	tile_ov_changed			; Jump if not zero
		jmp	render_tile

tile_ov_changed:
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
		add	bx,bx
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:[tile_vga_ofs]
		mov	di,ax
		pop	dx
		mov	ax,8
		mul	dl			; ax = reg * al
		mov	bp,ax
		mov	ax,30h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,tile_src_base
		add	bp,overlay_seg
		mov	ax,0C0h
		mul	byte ptr ds:[tile_col_idx]	; ax = data * al
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ax
		add	bx,vga_seg
		mov	ds,cs:[gvar_game_seg]
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

blit_ov_8rows:
					push	cx
					mov	ah,ds:[bp]
					inc	bp
					mov	cx,2

blit_ov_3planes:
								push	cx
								lodsb				; String [si] to al
								mov	dl,al
								lodsb				; String [si] to al
								mov	dh,al
								lodsb				; String [si] to al
								mov	cl,al
								mov	ch,dl
								shr	dx,1			; Shift w/zeros fill
								shr	dx,1			; Shift w/zeros fill
								add	ah,ah
								jnc	ovl_plane0			; Jump if carry=0
								mov	dh,cs:[bx]

ovl_plane0:
								inc	bx
								mov	es:[di],dh
								shr	dl,1			; Shift w/zeros fill
								shr	dl,1			; Shift w/zeros fill
								add	ah,ah
								jnc	ovl_plane1			; Jump if carry=0
								mov	dl,cs:[bx]

ovl_plane1:
								inc	bx
								mov	es:[di+1],dl
								add	cx,cx
								add	cx,cx
								and	ch,3Fh			; '?'
								add	ah,ah
								jnc	ovl_plane2			; Jump if carry=0
								mov	ch,cs:[bx]

ovl_plane2:
								inc	bx
								mov	es:[di+2],ch
								and	al,3Fh			; '?'
								add	ah,ah
								jnc	ovl_plane3			; Jump if carry=0
								mov	al,cs:[bx]

ovl_plane3:
								inc	bx
								mov	es:[di+3],al
								add	di,4
								pop	cx
								loop	blit_ov_3planes		; Loop if cx > 0

					pop	cx
					add	di,138h
					loop	blit_ov_8rows		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	ah,[di-1]
		or	ah,ah			; Zero ?
		jnz	check_anim			; Jump if not zero
		retn

check_anim:
		cmp	ah,19h
		jb	has_anim			; Jump if below
		retn

has_anim:
		push	di
		push	es
		mov	es,cs:[gvar_game_seg]
		mov	di,es:[map_overlay_ptr]
		mov	cl,es:[di]
		or	cl,cl			; Zero ?
		jz	anim_done			; Jump if zero
		inc	di

find_anim_loop:
					mov	al,es:[di]
					cmp	al,0FFh
					je	anim_done			; Jump if equal
					cmp	ah,al
					jne	anim_next			; Jump if not equal
					mov	al,es:[di+1]
					mov	[si-1],al
					jmp	short anim_done

anim_next:
					inc	di
					inc	di
					dec	cl
					jnz	find_anim_loop			; Jump if not zero

anim_done:
		pop	es
		pop	di
		retn

mark_tile_FE_mca		endp
; Dispatch entry: set DI=tile_offscr_a then fall through to save_cs_then_op_mca

set_cx_alt_mca	proc	near
		mov	di,tile_offscr_a	; = 0FA00h
set_cx_alt_mca	endp

set_cx_6_mca		proc	near
		mov	cx,6
set_cx_6_mca		endp

save_cs_then_op_mca		proc	near
		mov	ax,0A000h
		mov	es,ax

blit_n_tiles_loop:
					push	cx
					lodsb				; String [si] to al
					push	ds
					push	si
					mov	cl,30h			; '0'
					mul	cl			; ax = reg * al
					mov	si,ax
					add	si,tile_src_base
					mov	ds,cs:[gvar_game_seg]
					mov	cx,10h

blit_tile_3planes:
								lodsw				; String [si] to ax
								mov	dx,ax
								lodsb				; String [si] to al
								mov	bl,al
								mov	bh,dl
								shr	dx,1			; Shift w/zeros fill
								shr	dx,1			; Shift w/zeros fill
								mov	es:[di],dh
								shr	dl,1			; Shift w/zeros fill
								shr	dl,1			; Shift w/zeros fill
								mov	es:[di+1],dl
								add	bx,bx
								add	bx,bx
								and	bh,3Fh			; '?'
								mov	es:[di+2],bh
								and	al,3Fh			; '?'
								mov	es:[di+3],al
								add	di,4
								loop	blit_tile_3planes		; Loop if cx > 0

					pop	si
					pop	ds
					pop	cx
					loop	blit_n_tiles_loop		; Loop if cx > 0

		retn

save_cs_then_op_mca		endp

handle_scroll_tile:
		push	ds
		push	si
		push	es
		push	di
		mov	di,tile_id_mid
		movsw				; Mov [si] to es:[di]
		add	si,5
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dl,cs:[tile_col_idx]
		add	dl,4
		xor	dh,dh			; Zero register
		add	dx,word ptr cs:[starting_position_in_town]
		mov	ds:[scroll_col],dx
		call	load_tile_list_then_use_mca
		mov	es:[tile_id_a],al
		cmp	byte ptr es:[tile_id_b],0FDh
		jne	scroll_no_second			; Jump if not equal
		inc	dx
		call	load_tile_list_then_use_mca
		mov	es:[tile_id_b],al

scroll_no_second:
		mov	si,3C9Bh
		mov	di,0FB80h
		call	set_cx_6_mca
		mov	si,cs:[scroll_entry_ptr]

scroll_entry_loop:
					call	render_2_col_iter_mca
					or	bl,bl			; Zero ?
					jz	scroll_next_entry			; Jump if zero
					push	si
					push	bx
					call	decode_entity_slot_byte_mca
					pop	bx
					mov	es,cs:[gvar_game_seg]
					mov	si,tile_id_a
					call	compute_col_decrement_mca
					pop	si

scroll_next_entry:
					add	si,8
;*		cmp	word ptr [si],0FFFFh
					db	 83h, 3Ch,0FFh		;  Fixup - byte match
					jnz	scroll_entry_loop			; Jump if not zero
		pop	di
		pop	es
		mov	ch,es:[di-1]
		mov	cl,es:[di+7]
		push	es
		push	di
		push	cx
		mov	di,cs:[tile_vga_ofs]
		add	di,tile_buf_ofs
		push	di
		mov	si,tile_offscr_c
		SET_ES_DS_VGA
		inc	ch
		jz	blit_top_skip			; Jump if zero
		call	init_4E_loop_mca

blit_top_skip:
		pop	di
		pop	cx
		cmp	byte ptr cs:[tile_col_idx],1Bh
		je	blit_bot_done			; Jump if equal
		mov	si,tile_offscr_d
		add	di,8
		inc	cl
		jz	blit_bot_done			; Jump if zero
		call	init_4E_loop_mca

blit_bot_done:
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

save_state_then_blit_mca		proc	near
		push	es
		push	ds
		mov	si,ds:[gvar_plystate]
		add	si,25h
		mov	di,tile_id_a
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dx,word ptr ds:[starting_position_in_town]
		add	dx,3
		mov	ds:[scroll_col],dx
		cmp	byte ptr ds:[tile_id_a],0FDh
		jne	no_scroll2			; Jump if not equal
		inc	dx
		call	load_tile_list_then_use_mca
		mov	ds:[tile_id_a],al

no_scroll2:
		mov	si,3C9Bh
		mov	di,0FB80h
		mov	cx,3
		call	save_cs_then_op_mca
		mov	si,cs:[scroll_entry_ptr]

scroll2_entry_loop:
					call	render_2_col_iter_mca
					or	bl,bl			; Zero ?
					jz	scroll2_next_entry			; Jump if zero
					push	si
					dec	bl
					mov	al,3
					mul	bl			; ax = reg * al
					push	ax
					call	decode_entity_slot_byte_mca
					pop	ax
					add	di,ax
					mov	bp,di
					mov	es,cs:[gvar_game_seg]
					mov	si,3C9Bh
					mov	di,0FB80h
					call	render_3_tile_cols_mca
					pop	si

scroll2_next_entry:
					add	si,8
;*		cmp	word ptr [si],0FFFFh
					db	 83h, 3Ch,0FFh		;  Fixup - byte match
					jnz	scroll2_entry_loop			; Jump if not zero
		mov	di,vga_tile_left
		mov	si,tile_offscr_c
		SET_ES_DS_VGA
		call	init_4E_loop_mca
		pop	ds
		pop	es
		mov	di,npc_flag_ptr
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn

save_state_then_blit_mca		endp

load_tile_list_then_use_mca		proc	near
		call	load_tile_list_ptr_mca
		mov	al,[si+3]
		cmp	al,0FDh
		je	find_scroll_again			; Jump if equal
		retn

find_scroll_again:
					add	si,8
					call	match_tile_by_dx_mca
					mov	al,[si+3]
					cmp	al,0FDh
					je	find_scroll_again			; Jump if equal
		retn

load_tile_list_then_use_mca		endp

load_tile_list_ptr_mca		proc	near
		mov	si,ds:[scroll_entry_ptr]
load_tile_list_ptr_mca		endp

match_tile_by_dx_mca		proc	near

scan_col_match:
					cmp	dx,[si]
					jne	col_next			; Jump if not equal
					retn

col_next:
					add	si,8
					jmp	short scan_col_match

match_tile_by_dx_mca		endp

init_4E_loop_mca		proc	near
		mov	cx,18h

blit_8x8_loop:
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					add	di,138h
					loop	blit_8x8_loop		; Loop if cx > 0

		retn

init_4E_loop_mca		endp

compute_col_decrement_mca		proc	near
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:[dispatch_tbl_a][bx]	;*
		retn

compute_col_decrement_mca		endp

; Dispatch entries for dispatch_tbl_a: scroll-mode tile blitters to off-screen buffers C and D
; scroll_blit_c: IN AL,34h; ESC,[SI] (preamble); MOV DI,tile_offscr_c; CALL render_3_tile_cols_mca; JMP render_3cells
; scroll_blit_d: ADD SI,3; MOV DI,tile_offscr_d; JMP render_3cells

scroll_blit_c:				;* No entry point to code
		in	al,34h			; read custom port 34h (preamble before tile_offscr_c blit)
		db	0DCh, 34h		; ESC 6,[SI] -- x87 no-op / align
		mov	di,tile_offscr_c	; = 0FB80h
		call	render_3_tile_cols_mca		; blit 3 cells to tile_offscr_c
		jmp	short render_3cells	; done

scroll_blit_d:
		add	si,3			; advance SI past 3 scroll bytes
		mov	di,tile_offscr_d	; = 0FC40h
		jmp	short render_3cells

decode_entity_slot_byte_mca		proc	near
		mov	al,[si+2]
		mov	ch,al
		and	al,7Fh
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,4000h
		mov	di,ax
		xor	dl,dl			; Zero register
		or	ch,ch			; Zero ?
		js	overlay_right			; Jump if sign=1
		mov	dl,4

overlay_right:
		mov	al,[si+4]
		and	al,3
		add	al,dl
		mov	cl,6
		mul	cl			; ax = reg * al
		add	di,ax
		retn

decode_entity_slot_byte_mca		endp

render_2_col_iter_mca		proc	near
		mov	cx,2
		mov	dx,ds:[scroll_col]

find_entry_loop:
					mov	bl,cl
					cmp	[si],dx
					jne	entry_not_match			; Jump if not equal
					retn

entry_not_match:
					inc	dx
					loop	find_entry_loop		; Loop if cx > 0

		mov	bl,cl
		retn

render_2_col_iter_mca		endp

	; Called via dispatch_tbl_a: dispatch to scroll-mode sub-handler via dispatch_tbl_b

scroll_dispatch_b:			;* No entry point to code
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:[dispatch_tbl_b][bx]	;*
		retn
; Scroll blit entry A: adjust scroll position, blit to tile_offscr_a

scroll_blit_a:				;* No entry point to code
		dec	dx
		xor	ax,3542h
		cmp	dh,[di]
		add	bp,3
		mov	di,0FA00h
		jmp	short render_3cells
; Scroll blit entry: blit from scroll_entry to tile_offscr_a via render_3_tile_cols_mca

scroll_blit_a2:				;* No entry point to code
		mov	di,0FA00h
		call	render_3_tile_cols_mca
		jmp	short render_3cells
; Scroll blit entry B: advance SI by 3, blit to tile_offscr_b

scroll_blit_b:				;* No entry point to code
		mov	di,tile_offscr_b
		add	si,3
		jmp	short render_3cells

render_3_tile_cols_mca		proc	near

render_3cells:
		mov	cx,3

render_cell_loop:
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
					push	ax
					mov	cl,30h			; '0'
					mul	cl			; ax = reg * al
					mov	si,ax
					add	si,tileset_base
					pop	ax
					mov	cl,8
					mul	cl			; ax = reg * al
					add	ax,7000h
					mov	cs:[glyph_far_ptr],ax
					mov	ax,cs
					add	ax,2000h
					mov	word ptr cs:[glyph_far_ptr]+2,ax
					mov	ds,cs:[gvar_game_seg]
					mov	ax,0A000h
					mov	es,ax
					call	init_alt_setup_mca
					pop	bp
					pop	es
					pop	si
					pop	ds
					pop	cx
					loop	render_cell_loop		; Loop if cx > 0

		retn

render_3_tile_cols_mca		endp

	; Called via dispatch_tbl_a: initialize 6 tile glyphs from chunk0 into off-screen buffer

init_6tiles:				;* No entry point to code
		mov	di,tile_offscr_a
		mov	cx,6

init_6tiles_loop:
					push	cx
					lodsb				; String [si] to al
					push	ds
					push	si
					push	ax
					mov	cl,30h			; '0'
					mul	cl			; ax = reg * al
					mov	si,ax
					add	si,chunk0_base
					pop	ax
					mov	cl,8
					mul	cl			; ax = reg * al
					add	ax,8000h
					mov	cs:[glyph_far_ptr],ax
					mov	ax,cs
					add	ax,2000h
					mov	word ptr cs:[glyph_far_ptr]+2,ax
					mov	ds,cs:[gvar_game_seg]
					mov	ax,0A000h
					mov	es,ax
					call	init_alt_setup_mca
					pop	si
					pop	ds
					pop	cx
					loop	init_6tiles_loop		; Loop if cx > 0

		retn

init_alt_setup_mca		proc	near
		push	ds
		push	si
		push	di
		lds	si,dword ptr cs:[glyph_far_ptr]	; Load seg:offset ptr
		mov	cx,8

blit_glyph_rows:
					push	cx
					lodsb				; String [si] to al
					mov	cx,8

blit_glyph_bits:
								add	al,al
								sbb	ah,ah
								and	es:[di],ah
								inc	di
								loop	blit_glyph_bits		; Loop if cx > 0

					pop	cx
					loop	blit_glyph_rows		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		mov	cx,10h

blit_glyph_planes:
					lodsw				; String [si] to ax
					mov	dx,ax
					lodsb				; String [si] to al
					mov	bl,al
					mov	bh,dl
					shr	dx,1			; Shift w/zeros fill
					shr	dx,1			; Shift w/zeros fill
					or	es:[di],dh
					shr	dl,1			; Shift w/zeros fill
					shr	dl,1			; Shift w/zeros fill
					or	es:[di+1],dl
					add	bx,bx
					add	bx,bx
					and	bh,3Fh			; '?'
					or	es:[di+2],bh
					and	al,3Fh			; '?'
					or	es:[di+3],al
					add	di,4
					loop	blit_glyph_planes		; Loop if cx > 0

		retn

init_alt_setup_mca		endp

	; Called via dispatch_tbl_c (tile type 0): scroll VGA viewport left by 8 pixels

scroll_left:				;* No entry point to code
		push	ds
		SET_ES_DS_VGA
		std				; Set direction flag
		mov	si,vga_tile_r2
		mov	al,8

scroll_left_body:
					push	si
					mov	di,si
					sub	si,8
					mov	cx,6Ch
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					add	si,78h
					mov	cx,4
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					add	si,140h
					dec	al
					jnz	scroll_left_body			; Jump if not zero
		mov	si,vga_tile_r3
		mov	al,8

scroll_left2_body:
					push	si
					mov	di,si
					sub	si,10h
					mov	cx,68h
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					add	si,half_stride
					mov	cx,8
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					add	si,140h
					dec	al
					jnz	scroll_left2_body			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn
	; Called via dispatch_tbl_c (tile type 1): scroll VGA viewport up by 4 pixels

scroll_up:				;* No entry point to code
		push	ds
		SET_ES_DS_VGA
		std				; Set direction flag
		mov	si,hud_vga_ofs2
		mov	al,10h

scroll_up_body:
					push	si
					mov	di,si
					sub	si,4
					mov	cx,6Eh
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					add	si,74h
					mov	cx,2
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					add	si,140h
					dec	al
					jnz	scroll_up_body			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn
	; Called via dispatch_tbl_c (tile type 2): scroll VGA viewport right by 8 pixels

scroll_right:				;* No entry point to code
		push	ds
		SET_ES_DS_VGA
		mov	si,vga_tile_l2
		mov	al,8

scroll_right_body:
					push	si
					mov	di,si
					add	si,8
					mov	cx,6Ch
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					sub	si,78h
					mov	cx,4
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					add	si,140h
					dec	al
					jnz	scroll_right_body			; Jump if not zero
		mov	si,vga_tile_l3
		mov	al,8

scroll_right2_body:
					push	si
					mov	di,si
					add	si,10h
					mov	cx,68h
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					sub	si,80h
					mov	cx,8
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					add	si,140h
					dec	al
					jnz	scroll_right2_body			; Jump if not zero
		pop	ds
		retn
	; Called via dispatch_tbl_c (tile type 3): scroll VGA viewport down by 4 pixels

scroll_down:				;* No entry point to code
		push	ds
		SET_ES_DS_VGA
		mov	si,hud_vga_ofs
		mov	al,10h

scroll_down_body:
					push	si
					mov	di,si
					add	si,4
					mov	cx,6Eh
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					sub	si,74h
					mov	cx,2
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					add	si,140h
					dec	al
					jnz	scroll_down_body			; Jump if not zero
		pop	ds
		retn
	; Called via dispatch_tbl_c (tile type 4): draw tile from tile_cache_base to VGA

draw_tile_cached:			;* No entry point to code
		push	ds
		push	si
		mov	dl,30h			; '0'
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,tile_cache_base
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,di
		add	di,ax
		mov	ds,cs:[gvar_game_seg]
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

draw_8rows_loop:
					push	cx
					mov	cx,2

draw_3planes_loop:
								lodsw				; String [si] to ax
								mov	dx,ax
								lodsb				; String [si] to al
								mov	bl,al
								mov	bh,dl
								shr	dx,1			; Shift w/zeros fill
								shr	dx,1			; Shift w/zeros fill
								mov	es:[di],dh
								shr	dl,1			; Shift w/zeros fill
								shr	dl,1			; Shift w/zeros fill
								mov	es:[di+1],dl
								add	bx,bx
								add	bx,bx
								and	bh,3Fh			; '?'
								mov	es:[di+2],bh
								and	al,3Fh			; '?'
								mov	es:[di+3],al
								add	di,4
								loop	draw_3planes_loop		; Loop if cx > 0

					add	di,stride_minus_8
					pop	cx
					loop	draw_8rows_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn
	; Called via dispatch_tbl_a: draw a character glyph from char_glyph_base to VGA

draw_char_glyph:			;* No entry point to code
		push	ds
		push	si
		push	di
		push	cs
		pop	ds
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	si,char_glyph_base
		mov	cx,9

draw_glyph_rows:
					push	cx
					lodsb				; String [si] to al
					mov	ah,al
					mov	cx,8

draw_glyph_bits:
								add	ah,ah
								sbb	al,al
								and	al,12h
								stosb				; Store al to es:[di]
								loop	draw_glyph_bits		; Loop if cx > 0

					add	di,138h
					pop	cx
					loop	draw_glyph_rows		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		retn
; 9-byte cursor/selection glyph bitmask (diamond shape, 9 rows x 8 pixels):

cursor_glyph:
		db	 00h, 60h, 70h, 78h, 7Ch, 78h	; rows 0-5: 00000000 01100000 01110000 01111000 01111100 01111000
		db	 70h, 60h, 00h			; rows 6-8: 01110000 01100000 00000000
; Entry point called via dispatch_tbl_a: set up VGA draw for 9-row character blit

draw_char_entry:
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		mov	si,tile_bitbuf		; SI = tile_bitbuf (3CAFh)
		mov	ax,0A000h
		mov	es,ax			; ES = VGA segment
		mov	cx,9			; CX = 9 rows

draw_char_rows:
					push	cx
					push	di
					push	si
					mov	cx,ds:[gvar_tile_width]
					add	cx,cx
					add	cx,cx
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					add	si,0A0h
					pop	di
					add	di,140h
					pop	cx
					loop	draw_char_rows		; Loop if cx > 0

		retn
	; Called via dispatch_tbl_a: render HUD element -- clear tile_bitbuf, draw glyph overlay

render_hud_element:			;* No entry point to code
		push	si
		push	di
		push	di
		xor	ah,ah			; Zero register
		push	ax
		push	cs
		pop	es
		mov	di,tile_bitbuf
		xor	ax,ax			; Zero register
		mov	cx,320h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		push	ax
		add	ax,ax
		add	si,ax
		mov	si,[si]
		call	init_text_render_buf_mca
		pop	ax
		pop	di
		test	byte ptr ds:[gvar_flag57],0FFh
		jz	has_overlay_data			; Jump if zero
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	di,ax
		mov	dl,[di]
		mov	ax,[di+1]
		call	render_via_proc_loop2_mca

has_overlay_data:
		pop	di
		pop	si
		retn

init_text_render_buf_mca		proc	near
		push	cs
		pop	es
		mov	di,glyph_outbuf
		xor	bl,bl			; Zero register

glyph_char_loop:
					lodsb				; String [si] to al
					or	al,al			; Zero ?
					jnz	glyph_nonzero			; Jump if not zero
					retn

glyph_nonzero:
					push	ds
					push	si
					call	extract_bits
					pop	si
					pop	ds
					jmp	short glyph_char_loop

init_text_render_buf_mca		endp

extract_bits		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:[font_ptr_c]
		push	di
		mov	bl,8

glyph_row_loop:
					push	bx
					lodsb				; String [si] to al
					push	di
					mov	dh,al
					mov	dl,4

glyph_bit_loop:
								add	dh,dh
								sbb	bl,bl
								and	bl,9
								mov	es:[di],bl
								inc	di
								dec	dl
								jnz	glyph_bit_loop			; Jump if not zero
					pop	di
					add	di,0A0h
					pop	bx
					dec	bl
					jnz	glyph_row_loop			; Jump if not zero
		pop	di
		add	di,5
		retn

extract_bits		endp

	; Called via dispatch_tbl_a: render border glyph -- clear tile_bitbuf, draw border

render_border_glyph:			;* No entry point to code
		push	dx
		push	ax
		push	cs
		pop	es
		mov	di,tile_bitbuf
		xor	ax,ax			; Zero register
		mov	cx,320h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		pop	dx
		call	step_text_char_loop2_mca
		mov	di,3DEFh
		mov	si,3929h
		mov	cx,7
		mov	bl,1
		mov	word ptr ds:[gvar_tile_width],0Bh
		jmp	short draw_border_loop

render_via_proc_loop2_mca		proc	near
		call	step_text_char_loop2_mca
		push	cs
		pop	es
		mov	di,glyph_rowbuf
		mov	ax,ds:[gvar_scroll_idx]
		add	ax,ax
		add	ax,ax
		add	di,ax
		mov	si,border_glyph_ptr
		mov	cx,6

draw_border_loop:
					push	cx
					push	di
					lodsb				; String [si] to al
					push	si
					call	step_text_char_loop_mca
					pop	si
					pop	di
					add	di,6
					pop	cx
					loop	draw_border_loop		; Loop if cx > 0

		retn

render_via_proc_loop2_mca		endp

step_text_char_loop_mca		proc	near
		inc	al
		jnz	glyph_valid			; Jump if not zero
		retn

glyph_valid:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:[font_ptr_b]
		mov	si,ax
		mov	cx,7

draw_glyph_cols:
					lodsb				; String [si] to al
					add	al,al
					add	al,al
					mov	ah,6

glyph_6bits:
								add	al,al
								sbb	bl,bl
								and	bl,9
								mov	es:[di],bl
								inc	di
								dec	ah
								jnz	glyph_6bits			; Jump if not zero
					add	di,9Ah
					loop	draw_glyph_cols		; Loop if cx > 0

		retn

step_text_char_loop_mca		endp

step_text_char_loop2_mca		proc	near
		mov	di,3929h
		call	div_24bit_emit_digit_mca
		mov	cx,6

check_slot_loop:
					test	byte ptr cs:[di],0FFh
					jz	slot_mark			; Jump if zero
					retn

slot_mark:
					mov	byte ptr cs:[di],0FFh
					inc	di
					loop	check_slot_loop		; Loop if cx > 0

		retn

step_text_char_loop2_mca		endp

		db	7 dup (0)			; 7-byte alignment padding

div_24bit_emit_digit_mca		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	div_16bit_emit_digit_mca
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	div_16bit_emit_digit_mca
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	div_16bit_emit_digit_mca
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	div_16bit_emit_digit_alt_mca
		mov	cs:[di+3],dh
		mov	bx,64h
		call	div_16bit_emit_digit_alt_mca
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	div_16bit_emit_digit_alt_mca
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn

div_24bit_emit_digit_mca		endp

div_16bit_emit_digit_mca		proc	near
		xor	dh,dh			; Zero register

div_sub_loop:
					sub	dl,cl
					jc	div_done			; Jump if carry Set
					sub	ax,bx
					jnc	div_inc			; Jump if carry=0
					or	dl,dl			; Zero ?
					jz	div_rem_adj			; Jump if zero
					dec	dl

div_inc:
					inc	dh
					jmp	short div_sub_loop

div_rem_adj:
		add	ax,bx

div_done:
		add	dl,cl
		retn

div_16bit_emit_digit_mca		endp

div_16bit_emit_digit_alt_mca		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn

div_16bit_emit_digit_alt_mca		endp

	; Called via dispatch_tbl_a: copy tile rows upward (scroll up helper)

copy_rows_up:				;* No entry point to code
		push	ds
		push	ax
		add	bl,cl
		dec	bl
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		mov	si,di
		sub	si,140h
		SET_ES_DS_VGA
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		xor	ch,ch			; Zero register

copy_up_rows:
					push	cx
					push	di
					push	si
					mov	cx,bx
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					pop	di
					sub	si,140h
					sub	di,140h
					pop	cx
					loop	copy_up_rows		; Loop if cx > 0

		pop	ax
		mov	dl,0A0h
		mul	dl			; ax = reg * al
		add	ax,3CAFh
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
	; Called via dispatch_tbl_a: copy tile rows downward (scroll down helper)

copy_rows_down:				;* No entry point to code
		push	ds
		push	ax
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		mov	si,di
		add	si,vga_stride
		SET_ES_DS_VGA
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		xor	ch,ch			; Zero register

copy_down_rows:
					push	cx
					push	di
					push	si
					mov	cx,bx
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					pop	di
					add	si,140h
					add	di,vga_stride
					pop	cx
					loop	copy_down_rows		; Loop if cx > 0

		pop	ax
		mov	dl,0A0h
		mul	dl			; ax = reg * al
		add	ax,3CAFh
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
	; Called via dispatch_tbl_a: XOR-flash the tile grid area (visual effect)

xor_tile_flash:				;* No entry point to code
		mov	ax,0A000h
		mov	es,ax
		mov	di,hud_vga_ofs
		mov	cx,8

xor_col_outer:
					push	cx
					push	di
					mov	cx,12h

xor_row_loop:
								push	cx
								push	di
								mov	ax,3636h
								mov	cx,70h

xor_pixels_loop:
								xor	es:[di],ax
								inc	di
								inc	di
								loop	xor_pixels_loop		; Loop if cx > 0

								pop	di
								add	di,0A00h
								pop	cx
								loop	xor_row_loop		; Loop if cx > 0

					pop	di
					add	di,140h
					pop	cx
					loop	xor_col_outer		; Loop if cx > 0

		retn
	; Called via dispatch_tbl_a: encode tile bitplane data from CS+3000h segment

encode_tile_block:			;* No entry point to code
		mov	cs:[glyph_far_ptr],di
		mov	word ptr cs:[glyph_far_ptr]+2,es
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

encode_tiles_outer:
					push	cx
					mov	cx,8

encode_tiles_inner:
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
								call	step_text_char_loop3_mca
								push	es
								push	di
								les	di,dword ptr cs:[glyph_far_ptr]	; Load seg:offset ptr
								call	simg_scan_loop
								mov	al,dl
								stosb				; Store al to es:[di]
								mov	cs:[glyph_far_ptr],di
								pop	di
								pop	es
								pop	cx
								loop	encode_tiles_inner		; Loop if cx > 0

					pop	cx
					loop	encode_tiles_outer		; Loop if cx > 0

		retn
	; Called via dispatch_tbl_a: copy tile_src_base to CS+3000h, then process all tiles

load_and_process_tiles:			;* No entry point to code
		push	ds
		mov	ds,cs:[gvar_game_seg]
		mov	si,tile_src_base
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
		mov	bx,es:[tile_cache_base]
		mov	bp,0D000h
		mov	cx,0FAh

process_tiles_loop:
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
					call	word ptr cs:[dispatch_tbl_c][bx]	;*
					pop	bx
					inc	bx
					pop	cx
					loop	process_tiles_loop		; Loop if cx > 0

		pop	ds
		retn
	; Called via dispatch_tbl_c: encode tile type 0 row (all black/opaque)
; Preceded by init bytes that set up BP/DI/CX for the encode_row loops

encode_row_dispatch:			;* No entry point to code
		push	bp
		cmp	di,[bp+di+3Bh]
		stosb				; Store al to es:[di]
		cmp	bx,cx
		cmp	cx,[bx+si]
		cmp	al,0B9h
		or	[bx+si],al

encode_row_a:
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
					call	step_text_char_loop3_mca
					mov	byte ptr es:[bp],0
					inc	bp
					pop	cx
					loop	encode_row_a		; Loop if cx > 0

		retn

encode_row_b_entry:				; dispatch_tbl_c entry point (MOV CX,8 then push cx loop)
		mov	cx,8

encode_row_b:
					push	cx
					lodsw				; String [si] to ax
					xchg	ah,al
					mov	cs:[bitplane_0],ax
					lodsw				; String [si] to ax
					xchg	ah,al
					mov	cs:[bitplane_1],ax
					mov	word ptr cs:[bitplane_2],0
					lodsw				; String [si] to ax
					xchg	ah,al
					mov	cs:[bitplane_3],ax
					call	step_text_char_loop3_mca
					call	simg_scan_loop
					mov	es:[bp],dl
					inc	bp
					pop	cx
					loop	encode_row_b		; Loop if cx > 0

		retn

encode_row_c_entry:
		mov	cx,8

encode_row_c:
					push	cx
					lodsw				; String [si] to ax
					xchg	ah,al
					mov	cs:[bitplane_0],ax
					lodsw				; String [si] to ax
					xchg	ah,al
					mov	cs:[bitplane_3],ax
					mov	word ptr cs:[bitplane_1],0
					lodsw				; String [si] to ax
					xchg	ah,al
					mov	cs:[bitplane_2],ax
					call	step_text_char_loop3_mca
					call	simg_scan_loop
					mov	es:[bp],dl
					inc	bp
					pop	cx
					loop	encode_row_c		; Loop if cx > 0

		retn

encode_row_d_entry:
		mov	cx,8

encode_row_d:
					push	cx
					lodsw				; String [si] to ax
					xchg	ah,al
					mov	cs:[bitplane_3],ax
					mov	word ptr cs:[bitplane_0],0
					lodsw				; String [si] to ax
					xchg	al,ah
					mov	cs:[bitplane_1],ax
					lodsw				; String [si] to ax
					xchg	al,ah
					mov	cs:[bitplane_2],ax
					call	step_text_char_loop3_mca
					call	simg_scan_loop
					mov	es:[bp],dl
					inc	bp
					pop	cx
					loop	encode_row_d		; Loop if cx > 0

		retn

encode_row_e_entry:
		mov	cx,8

encode_row_e:
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
					call	step_text_char_loop3_mca
					mov	byte ptr es:[bp],0FFh
					inc	bp
					pop	cx
					loop	encode_row_e		; Loop if cx > 0

		retn

step_text_char_loop3_mca		proc	near
		mov	cx,2

pack_planes_loop:
					call	pack_2plane_pixel_mca
					call	pack_2plane_pixel_mca
					call	pack_2plane_pixel_mca
					call	pack_2plane_pixel_mca
					call	pack_2plane_pixel_mca
					rol	word ptr cs:[bitplane_2],1	; Rotate
					adc	ax,ax
					stosw				; Store ax to es:[di]
					rol	word ptr cs:[bitplane_1],1	; Rotate
					adc	ax,ax
					rol	word ptr cs:[bitplane_0],1	; Rotate
					adc	ax,ax
					call	pack_2plane_pixel_mca
					call	pack_2plane_pixel_mca
					stosb				; Store al to es:[di]
					loop	pack_planes_loop		; Loop if cx > 0

		retn

step_text_char_loop3_mca		endp

pack_2plane_pixel_mca		proc	near
		rol	word ptr cs:[bitplane_2],1	; Rotate
		adc	ax,ax
		rol	word ptr cs:[bitplane_1],1	; Rotate
		adc	ax,ax
		rol	word ptr cs:[bitplane_0],1	; Rotate
		adc	ax,ax
		retn

pack_2plane_pixel_mca		endp

simg_scan_loop		proc	near
		mov	cx,8

scan_alpha_loop:
					xor	al,al			; Zero register
					rol	word ptr cs:[bitplane_3],1	; Rotate
					adc	al,al
					rol	word ptr cs:[bitplane_3],1	; Rotate
					adc	al,al
					cmp	al,3
					je	alpha_is_3			; Jump if equal
					xor	al,al			; Zero register

alpha_is_3:
					and	al,1
					add	dl,dl
					or	dl,al
					loop	scan_alpha_loop		; Loop if cx > 0

		retn

simg_scan_loop		endp

		db	2135 dup (0)			; zero-fill to end of segment (dispatch tables and data buffers follow in game_seg)

seg_a		ends

		end	start
