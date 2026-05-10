
PAGE  59,132

;==========================================================================
;
;  109GTHGC - Town Tiles HGC Renderer (zelres1 chunk 10, gthgc.bin)
;
;  Hercules-specific tilemap renderer for the town/overworld engine.
;  Loaded by game.bin into the game segment (gfx_mode_tbl_all entry,
;  mode 3) alongside 106TOWN (town.bin). Provides tile blit, scroll,
;  character cell rendering, and text-glyph functions exposed via
;  dispatch slots consumed by 106TOWN.
;
;  Connections:
;    Loads:        none (rendering primitives only)
;    Calls into:   render_fn_tbl_* (CS dispatch tables, set internally
;                  per tile type)
;    Called by:    game.bin LOAD_CHUNK chunk_ref_gthgc via gfx_mode_tbl_all
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
gvar_game_seg		equ	0FF2Ch			;* game segment selector word

; ----------------------------------------------------------------------
; Section 4: Shared dispatch slot references (file-local)
; ----------------------------------------------------------------------
drv_init_tbl		equ	0F435h			;* driver init dispatch table offset

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
; restored after factoring (per-file value, not in shared inc):
font_ptr_a               equ     0F502h
font_ptr_b               equ     0F504h
tile_alt_base		equ	4100h			;* tile alternate pixel data base
tile_bank2_base		equ	6000h			;* tile pixel data bank 2 base (external CS ref)
tile_mask_base		equ	0D000h			;* tile transparency mask data base
render_fn_tbl_a		equ	347Ah			;* render function pointer table A (word[N])
render_fn_tbl_b		equ	34D6h			;* render function pointer table B (word[N])
tile_row_data_a		equ	3737h			;* tile row source data A
tile_row_data_b		equ	38D5h			;* tile row source data B
tile_type_tbl		equ	3B1Dh			;* tile type dispatch table (word[N])
pixel_encode_tbl	equ	3C24h			;* pixel encoding lookup table
tile_hgc_ofs		equ	3CACh			;* current HGC framebuffer byte offset for tile row (word)
tile_row_ctr		equ	3CAEh			;* current tile row counter (byte, 0..1Ch)
tile_dest_ofs		equ	3CB0h			;* tile destination offset (word)
tile_col_ctr		equ	3CB5h			;* current tile column position counter (word)
bitplane_w0		equ	3CB7h			;* bitplane word 0
bitplane_w1		equ	3CB9h			;* bitplane word 1
bitplane_w2		equ	3CBBh			;* bitplane word 2
bitplane_w3		equ	3CBDh			;* bitplane word 3
far_ptr			equ	3CBFh			;* far pointer dword (seg:ofs) used with LDS
char_render_buf		equ	3CC3h			;* character/sprite render buffer
text_render_buf		equ	3CEBh			;* text glyph render buffer
tile_strip_a		equ	3E53h			;* tile strip render area A (column 0)
tile_strip_b		equ	3E83h			;* tile strip render area B (column 1)
tile_strip_c		equ	3EB3h			;* tile strip render area C (column 2)
tile_strip_d		equ	3EE3h			;* tile strip render area D (column 3)
tile_cache_tbl		equ	3F13h			;* tile HGC address cache table (word[N])
hgc_scan_cache		equ	50F1h			;* HGC scanline data cache
hgc_wrap_back		equ	5FA6h			;* HGC bank wrap-back adjustment (external ref)
hgc_bank_bdy		equ	6000h			;* HGC bank boundary = 6000h (external ref)
sprite_data_base	equ	0A000h			;* sprite data CS offset base
hgc_stride_a		equ	0A058h			;* HGC stride adjustment A (bank overflow fix)
hgc_stride		equ	0A05Ah			;* HGC interleave stride (0xA05A per scanline set)
hgc_cursor_ofs		equ	4FDh			; HGC cursor position offset
scroll_src_b		equ	34CFh			; scroll source offset B (right scroll)
scroll_src_a		equ	3506h			; scroll source offset A (left scroll)
hgc_bank_back		equ	5FA6h			; HGC bank wrap-back constant (= hgc_wrap_back)
hgc_bank_size		equ	6000h			; HGC bank size (24576 bytes = 0x6000)
hgc_wrap_fwd		equ	7FA6h			; HGC bank forward-wrap constant
hgc_stride_c		equ	0A058h			; HGC stride variant C (= hgc_stride_a)
hgc_stride_b		equ	0A05Ah			; HGC stride variant B (= hgc_stride)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
tile_idx_a		equ	3CAFh			;* tile index A (byte)
tile_idx_b		equ	3CB2h			;* tile index B (byte, 0FDh = none)

; SET_ES_DS_HGC
;   ES = DS = B000h (set both segments to HGC framebuffer).
SET_ES_DS_HGC	MACRO
		mov	ax, 0B000h
		mov	es, ax
		mov	ds, ax
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

run_gthgc_main		proc	far

; Driver initialization binary blob (0x00..0x3E):
; These 63 bytes are the function dispatch init table written by the game loader.
; Sourcer decodes the first bytes as x86 instructions (they are valid code),
; but the entire block is really a flat binary copied to drv_init_tbl (CS:0xF435).
; The loader then patches the game segment function pointer table from this data.
; Each LE word pair encodes a CS-relative offset to one of this module's entry points.

start:
		adc	dx,[bx+di]
		add	[bx+si],al
		or	al,3Ah			; ':'
		sub	[bx+si],dh
		push	di
		xor	ds:drv_init_tbl[bx+di],cl
		xor	ax,362Ch
		xchg	bp,ax
		db	 36h,0B3h, 32h,0C8h, 34h, 33h	; dispatch words: 36B3h, 32C8h, 3433h
		db	 35h, 8Eh, 34h,0CBh, 36h, 09h	; dispatch words: 358Eh, 34CBh, 3609h
		db	 37h, 83h, 37h, 49h, 37h, 44h	; dispatch words: 3783h, 3749h, 3744h
		db	 39h,0A6h, 39h, 23h, 38h,0CBh	; dispatch words: 39A6h, 3923h, 38CBh
		db	 3Ah, 48h, 3Ah, 1Eh,0BEh, 5Fh	; dispatch words: 3A48h, 3A1Eh + push ds; mov si,...
		db	 2Ch,0BFh, 00h,0A0h, 0Eh, 07h	; mov si,2C5Fh; mov di,0A000h; push cs; pop es
		db	0B8h, 00h,0B0h, 8Eh,0D8h,0B9h	; mov ax,0B000h; mov ds,ax; mov cx,...
		db	 1Ch, 00h			; mov cx,1Ch -> draw_map_col_outer

draw_map_col_outer:
							push	cx
							push	si
							mov	cx,18h

blit_tile_row_loop:
												movsw				; Mov [si] to es:[di]
												add	si,1FFEh
												cmp	si,6000h
												jb	blit_tile_row_wrap			; Jump if below
												add	si,hgc_stride

blit_tile_row_wrap:
												loop	blit_tile_row_loop		; Loop if cx > 0

							pop	si
							pop	cx
							inc	si
							inc	si
							loop	draw_map_col_outer		; Loop if cx > 0

		pop	ds
		retn

; Init tile cache, then render all 8 tile columns for the current town row (dispatch target)

draw_tilemap:				;* No entry point to code
		push	cs
		pop	es
		mov	di,tile_cache_tbl
		xor	ax,ax			; Zero register
		mov	cx,100h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,ds:gvar_map_ptr
		cmp	byte ptr [si+1Dh],0FDh
		jne	draw_map_no_multiply			; Jump if not equal
		call	blit_sprite_alt_hgc

draw_map_no_multiply:
		mov	word ptr ds:tile_hgc_ofs,2C5Fh
		mov	si,ds:gvar_map_ptr
		add	si,20h
		push	cs
		pop	es
		mov	di,0E000h
		mov	byte ptr ds:tile_row_ctr,0

draw_map_col_loop:
							call	match_tile_by_dx_hgc
							xor	bl,bl			; Zero register
							cmpsb				; Cmp [si] to es:[di]
							jz	draw_col_1_done			; Jump if zero
							call	mark_tile_FE_hgc

draw_col_1_done:
							inc	bl
							cmpsb				; Cmp [si] to es:[di]
							jz	draw_col_2_done			; Jump if zero
							call	mark_tile_FE_hgc

draw_col_2_done:
							inc	bl
							cmpsb				; Cmp [si] to es:[di]
							jz	draw_col_3_done			; Jump if zero
							call	mark_tile_FE_hgc

draw_col_3_done:
							inc	bl
							cmpsb				; Cmp [si] to es:[di]
							jz	draw_col_4_done			; Jump if zero
							call	render_tile_entry_hgc

draw_col_4_done:
							inc	bl
							cmpsb				; Cmp [si] to es:[di]
							jz	draw_col_5_done			; Jump if zero
							call	render_tile_entry_hgc

draw_col_5_done:
							inc	bl
							cmpsb				; Cmp [si] to es:[di]
							jz	draw_col_6_done			; Jump if zero
							call	render_tile_if_marked_hgc

draw_col_6_done:
							inc	bl
							cmpsb				; Cmp [si] to es:[di]
							jz	draw_col_7_done			; Jump if zero
							call	render_tile_entry_hgc

draw_col_7_done:
							inc	bl
							cmpsb				; Cmp [si] to es:[di]
							jz	draw_col_8_done			; Jump if zero
							call	render_tile_entry_hgc

draw_col_8_done:
							add	word ptr ds:tile_hgc_ofs,2
							inc	byte ptr ds:tile_row_ctr
							cmp	byte ptr ds:tile_row_ctr,1Ch
							jne	draw_map_col_loop			; Jump if not equal
		retn

run_gthgc_main		endp

match_tile_by_dx_hgc		proc	near
		cmp	byte ptr ds:tile_row_ctr,1Bh
		jne	scan_check_pos			; Jump if not equal
		retn

scan_check_pos:
		mov	al,byte ptr ds:[screen_position]
		cmp	ds:tile_row_ctr,al
		je	scan_do_render			; Jump if equal
		retn

scan_do_render:
		push	di
		push	es
		push	si
		mov	al,byte ptr ds:[screen_position]
		add	al,al
		xor	ah,ah			; Zero register
		mov	di,ax
		add	di,hgc_scan_cache
		mov	ax,0B000h
		mov	es,ax
		mov	si,tile_strip_a
		mov	cx,2

scan_render_loop:
							push	cx
							push	di
							call	init_status_row_24_hgc
							pop	di
							inc	di
							inc	di
							pop	cx
							loop	scan_render_loop		; Loop if cx > 0

		pop	si
		pop	es
		pop	di
		retn

match_tile_by_dx_hgc		endp

render_tile_if_marked_hgc		proc	near
		cmp	byte ptr [si-1],0FDh
		jne	func2_not_door			; Jump if not equal
		jmp	handle_door_tile

render_tile_if_marked_hgc		endp

render_tile_entry_hgc		proc	near

func2_not_door:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	func2_do_draw			; Jump if not zero
		retn

func2_do_draw:
		dec	di
		dec	si
		mov	dl,[si]
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,ds:tile_hgc_ofs
		or	bl,bl			; Zero ?
		jz	tile_draw_check_cache			; Jump if zero

hgc_col_advance_loop:
							add	di,40B4h
							cmp	di,6000h
							jb	hgc_col_advance_wrap			; Jump if below
							add	di,hgc_stride_b

hgc_col_advance_wrap:
							dec	bl
							jnz	hgc_col_advance_loop			; Jump if not zero

tile_draw_check_cache:
		mov	bl,dl
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:tile_cache_tbl[bx],0FFFFh
		jnz	tile_draw_cached			; Jump if not zero
		mov	ds:tile_cache_tbl[bx],di
		mov	ax,10h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,tile_pixel_base
		mov	ds,cs:gvar_game_seg
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

tile_blit_new_loop:
							movsw				; Mov [si] to es:[di]
							add	di,1FFEh
							cmp	di,hgc_bank_size
							jb	tile_blit_new_wrap			; Jump if below
							mov	ax,[si-2]
							stosw				; Store ax to es:[di]
							add	di,hgc_stride_c

tile_blit_new_wrap:
							loop	tile_blit_new_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

tile_draw_cached:
		mov	si,ds:tile_cache_tbl[bx]
		SET_ES_DS_HGC
		mov	cx,8

tile_blit_cached_loop:
							movsw				; Mov [si] to es:[di]
							add	di,1FFEh
							cmp	di,hgc_bank_size
							jb	tile_blit_cached_di_wrap			; Jump if below
							mov	ax,[si-2]
							stosw				; Store ax to es:[di]
							add	di,hgc_stride_a

tile_blit_cached_di_wrap:
							add	si,1FFEh
							cmp	si,6000h
							jb	tile_blit_cached_si_wrap			; Jump if below
							add	si,hgc_stride

tile_blit_cached_si_wrap:
							loop	tile_blit_cached_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

render_tile_entry_hgc		endp

mark_tile_FE_hgc		proc	near
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	func4_do_draw			; Jump if not zero
		retn

func4_do_draw:
		push	bx
		push	es
		mov	dl,[si-1]
		mov	bl,dl
		xor	bh,bh			; Zero register
		mov	es,cs:gvar_game_seg
		add	bx,es:tileset_buf_a
		mov	dh,es:[bx]
		pop	es
		pop	bx
		or	dh,dh			; Zero ?
		jnz	func4_has_mask			; Jump if not zero
		jmp	func2_not_door

func4_has_mask:
		dec	di
		dec	si
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,ds:tile_hgc_ofs
		or	bl,bl			; Zero ?
		jz	func4_draw_tile			; Jump if zero
		push	bx

func4_col_advance_loop:
							add	di,40B4h
							cmp	di,6000h
							jb	func4_col_advance_wrap			; Jump if below
							add	di,hgc_stride_b

func4_col_advance_wrap:
							dec	bl
							jnz	func4_col_advance_loop			; Jump if not zero
		pop	bx

func4_draw_tile:
		mov	ax,10h
		mul	dl			; ax = reg * al
		mov	si,ax
		mov	bp,ax
		add	si,tile_pixel_base
		add	bp,tile_mask_base
		mov	ax,30h
		mul	byte ptr ds:tile_row_ctr	; ax = data * al
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ax
		add	bx,sprite_data_base
		mov	ds,cs:gvar_game_seg
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

tile_mask_blit_loop:
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
							cmp	di,hgc_bank_size
							jb	tile_mask_blit_wrap			; Jump if below
							stosw				; Store ax to es:[di]
							add	di,hgc_stride_a

tile_mask_blit_wrap:
							loop	tile_mask_blit_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	ah,[di-1]
		or	ah,ah			; Zero ?
		jnz	tile_check_overlay			; Jump if not zero
		retn

tile_check_overlay:
		cmp	ah,19h
		jb	tile_has_overlay			; Jump if below
		retn

tile_has_overlay:
		push	di
		push	es
		mov	es,cs:gvar_game_seg
		mov	di,es:tileset_buf_b
		mov	cl,es:[di]
		or	cl,cl			; Zero ?
		jz	tile_overlay_done			; Jump if zero
		inc	di

tile_find_overlay:
							mov	al,es:[di]
							cmp	al,0FFh
							je	tile_overlay_done			; Jump if equal
							cmp	ah,al
							jne	tile_overlay_next			; Jump if not equal
							mov	al,es:[di+1]
							mov	[si-1],al
							jmp	short tile_overlay_done

tile_overlay_next:
							inc	di
							inc	di
							dec	cl
							jnz	tile_find_overlay			; Jump if not zero

tile_overlay_done:
		pop	es
		pop	di
		retn

mark_tile_FE_hgc		endp
		db	0BFh, 53h, 3Eh		; mov di,3E53h (dispatch table stub: render_fn_b1 entry bytes)

set_cx_6_hgc		proc	near
		mov	cx,6
set_cx_6_hgc		endp

save_cs_then_op_hgc		proc	near
		push	cs
		pop	es

copy_tile_pixels_loop:
							push	cx
							lodsb				; String [si] to al
							push	ds
							push	si
							mov	cl,10h
							mul	cl			; ax = reg * al
							mov	si,ax
							add	si,tile_pixel_base
							mov	ds,cs:gvar_game_seg
							movsw				; Mov [si] to es:[di]
							movsw				; Mov [si] to es:[di]
							movsw				; Mov [si] to es:[di]
							movsw				; Mov [si] to es:[di]
							movsw				; Mov [si] to es:[di]
							movsw				; Mov [si] to es:[di]
							movsw				; Mov [si] to es:[di]
							movsw				; Mov [si] to es:[di]
							pop	si
							pop	ds
							pop	cx
							loop	copy_tile_pixels_loop		; Loop if cx > 0

		retn

save_cs_then_op_hgc		endp

handle_door_tile:
		push	ds
		push	si
		push	es
		push	di
		mov	di,tile_dest_ofs
		movsw				; Mov [si] to es:[di]
		add	si,5
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dl,cs:tile_row_ctr
		add	dl,4
		xor	dh,dh			; Zero register
		add	dx,word ptr cs:[starting_position_in_town]
		mov	ds:tile_col_ctr,dx
		call	load_tile_list_then_use_hgc
		mov	es:tile_idx_a,al
		cmp	byte ptr es:tile_idx_b,0FDh
		jne	door_no_second			; Jump if not equal
		inc	dx
		call	load_tile_list_then_use_hgc
		mov	es:tile_idx_b,al

door_no_second:
		mov	si,3CAFh
		mov	di,3EB3h
		call	set_cx_6_hgc
		mov	si,cs:tile_list_ptr

door_find_loop:
							call	render_2_col_iter_hgc
							or	bl,bl			; Zero ?
							jz	door_no_match			; Jump if zero
							push	si
							push	bx
							call	decode_entity_slot_byte_hgc
							pop	bx
							mov	es,cs:gvar_game_seg
							mov	si,tile_idx_a
							call	save_di_via_bp_hgc
							pop	si

door_no_match:
							add	si,8
;*		cmp	word ptr [si],0FFFFh
							db	 83h, 3Ch,0FFh		;  Fixup - byte match
							jnz	door_find_loop			; Jump if not zero
		pop	di
		pop	es
		mov	ch,es:[di-1]
		mov	cl,es:[di+7]
		push	es
		push	di
		push	cx
		mov	di,cs:tile_hgc_ofs
		mov	bl,5

door_col_advance_loop:
							add	di,40B4h
							cmp	di,6000h
							jb	door_col_advance_wrap			; Jump if below
							add	di,hgc_stride

door_col_advance_wrap:
							dec	bl
							jnz	door_col_advance_loop			; Jump if not zero
		push	di
		mov	si,tile_strip_c
		mov	ax,0B000h
		mov	es,ax
		inc	ch
		jz	door_blit_top			; Jump if zero
		call	init_status_row_24_hgc

door_blit_top:
		pop	di
		pop	cx
		cmp	byte ptr cs:tile_row_ctr,1Bh
		je	door_blit_done			; Jump if equal
		mov	si,tile_strip_d
		inc	di
		inc	di
		inc	cl
		jz	door_blit_done			; Jump if zero
		call	init_status_row_24_hgc

door_blit_done:
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

blit_sprite_alt_hgc		proc	near
		push	es
		push	ds
		mov	si,ds:gvar_map_ptr
		add	si,25h
		mov	di,tile_idx_a
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dx,word ptr ds:[starting_position_in_town]
		add	dx,3
		mov	ds:tile_col_ctr,dx
		cmp	byte ptr ds:tile_idx_a,0FDh
		jne	multiply_no_door			; Jump if not equal
		inc	dx
		call	load_tile_list_then_use_hgc
		mov	ds:tile_idx_a,al

multiply_no_door:
		mov	si,3CAFh
		mov	di,3EB3h
		mov	cx,3
		call	save_cs_then_op_hgc
		mov	si,cs:tile_list_ptr

multiply_find_loop:
							call	render_2_col_iter_hgc
							or	bl,bl			; Zero ?
							jz	multiply_no_match			; Jump if zero
							push	si
							dec	bl
							mov	al,3
							mul	bl			; ax = reg * al
							push	ax
							call	decode_entity_slot_byte_hgc
							pop	ax
							add	di,ax
							mov	bp,di
							mov	es,cs:gvar_game_seg
							mov	si,3CAFh
							mov	di,3EB3h
							call	render_via_multiply3_hgc
							pop	si

multiply_no_match:
							add	si,8
;*		cmp	word ptr [si],0FFFFh
							db	 83h, 3Ch,0FFh		;  Fixup - byte match
							jnz	multiply_find_loop			; Jump if not zero
		mov	di,hgc_scan_cache
		mov	si,tile_strip_c
		mov	ax,0B000h
		mov	es,ax
		call	init_status_row_24_hgc
		pop	ds
		pop	es
		mov	di,marker_buf
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn

blit_sprite_alt_hgc		endp

load_tile_list_then_use_hgc		proc	near
		call	load_tile_list_ptr_hgc
		mov	al,[si+3]
		cmp	al,0FDh
		je	func8_follow_chain			; Jump if equal
		retn

func8_follow_chain:
							add	si,8
							call	noop_helper_hgc
							mov	al,[si+3]
							cmp	al,0FDh
							je	func8_follow_chain			; Jump if equal
		retn

load_tile_list_then_use_hgc		endp

load_tile_list_ptr_hgc		proc	near
		mov	si,ds:tile_list_ptr
load_tile_list_ptr_hgc		endp

noop_helper_hgc		proc	near

func9_search_loop:
							cmp	dx,[si]
							jne	func9_no_match			; Jump if not equal
							retn

func9_no_match:
							add	si,8
							jmp	short func9_search_loop

noop_helper_hgc		endp

init_status_row_24_hgc		proc	near
		mov	cx,18h

scan2_blit_loop:
							movsw				; Mov [si] to es:[di]
							add	di,1FFEh
							cmp	di,hgc_bank_size
							jb	scan2_blit_wrap			; Jump if below
							mov	ax,[si-2]
							stosw				; Store ax to es:[di]
							add	di,0A058h

scan2_blit_wrap:
							loop	scan2_blit_loop		; Loop if cx > 0

		retn

init_status_row_24_hgc		endp

save_di_via_bp_hgc		proc	near
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:render_fn_tbl_a[bx]	;*
		retn

save_di_via_bp_hgc		endp

; Render fn A, index 0: conditional redirect then render to tile_strip_c (dispatch target)

render_fn_a0:				;* No entry point to code
		xchg	[si],dh
;*		jle	loc_58			;*Jump if < or =
		db	 7Eh, 34h		;  Fixup - byte match
		mov	di,3EB3h
		call	render_via_multiply3_hgc
		jmp	short multiply3_render

; Render fn A, index 1: skip 3 bytes, render to tile_strip_d (dispatch target)

render_fn_a1:				;* No entry point to code
		add	si,3
		mov	di,3EE3h
		jmp	short multiply3_render

decode_entity_slot_byte_hgc		proc	near
		mov	al,[si+2]
		mov	ch,al
		and	al,7Fh
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,4000h
		mov	di,ax
		xor	dl,dl			; Zero register
		or	ch,ch			; Zero ?
		js	multiply2_no_offset			; Jump if sign=1
		mov	dl,4

multiply2_no_offset:
		mov	al,[si+4]
		and	al,3
		add	al,dl
		mov	cl,6
		mul	cl			; ax = reg * al
		add	di,ax
		retn

decode_entity_slot_byte_hgc		endp

render_2_col_iter_hgc		proc	near
		mov	cx,2
		mov	dx,ds:tile_col_ctr

scan3_search_loop:
							mov	bl,cl
							cmp	[si],dx
							jne	scan3_no_match			; Jump if not equal
							retn

scan3_no_match:
							inc	dx
							loop	scan3_search_loop		; Loop if cx > 0

		mov	bl,cl
		retn

render_2_col_iter_hgc		endp

; Secondary dispatch: save pos, call render_fn_tbl_b[bl], return (dispatch target)

get_value_b:				;* No entry point to code
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:render_fn_tbl_b[bx]	;*
		retn

; Render fn B, index 0: XOR-decode tile data, render to tile_strip_a (dispatch target)

render_fn_b0:				;* No entry point to code
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		xor	al,0E4h
		xor	al,0DCh
		xor	al,83h
		lds	ax,dword ptr [bp+di]	; Load seg:offset ptr
		mov	di,3E53h
		jmp	short multiply3_render

; Render fn B, index 1: render to tile_strip_a (dispatch target)

render_fn_b1:				;* No entry point to code
		mov	di,3E53h
		call	render_via_multiply3_hgc
		jmp	short multiply3_render

; Render fn B, index 2: skip 3 bytes, render to tile_strip_b (dispatch target)

render_fn_b2:				;* No entry point to code
		mov	di,tile_strip_b
		add	si,3
		jmp	short multiply3_render

render_via_multiply3_hgc		proc	near

multiply3_render:
		mov	cx,3

multiply3_process_loop:
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
							add	si,tile_alt_base
							add	ax,7000h
							mov	cs:far_ptr,ax
							mov	ax,cs
							add	ax,2000h
							mov	word ptr cs:far_ptr+2,ax
							mov	ds,cs:gvar_game_seg
							push	cs
							pop	es
							call	save_ds_then_process_hgc
							pop	bp
							pop	es
							pop	si
							pop	ds
							pop	cx
							loop	multiply3_process_loop		; Loop if cx > 0

		retn

render_via_multiply3_hgc		endp

; Load 6-tile pixel bank from SI into tile_strip_a buffer (dispatch target)

load_tile_bank:				;* No entry point to code
		push	cs
		pop	es
		mov	di,tile_strip_a
		mov	cx,6

load_tile_bank_loop:
							push	cx
							lodsb				; String [si] to al
							push	ds
							push	si
							mov	cl,10h
							mul	cl			; ax = reg * al
							mov	si,ax
							add	si,tile_bank2_base
							add	ax,8000h
							mov	cs:far_ptr,ax
							mov	ax,cs
							add	ax,2000h
							mov	word ptr cs:far_ptr+2,ax
							mov	ds,cs:gvar_game_seg
							call	save_ds_then_process_hgc
							pop	si
							pop	ds
							pop	cx
							loop	load_tile_bank_loop		; Loop if cx > 0

		retn

save_ds_then_process_hgc		proc	near
		push	ds
		push	si
		push	di
		lds	si,dword ptr cs:far_ptr	; Load seg:offset ptr
		mov	cx,8

process_and_loop:
							lodsw				; String [si] to ax
							and	es:[di],ax
							inc	di
							inc	di
							loop	process_and_loop		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		mov	cx,8

process_or_loop:
							lodsw				; String [si] to ax
							or	es:[di],ax
							inc	di
							inc	di
							loop	process_or_loop		; Loop if cx > 0

		retn

save_ds_then_process_hgc		endp

; Scroll tilemap left: shift tile rows left 2px using copy_pixel_row_v1_hgc (dispatch target)

scroll_left:				;* No entry point to code
		push	ds
		SET_ES_DS_HGC
		std				; Set direction flag
		mov	si,53F8h
		mov	al,8

scroll_left_row_loop:
							call	copy_pixel_row_v1_hgc
							add	si,2000h
							cmp	si,6000h
							jb	scroll_left_wrap			; Jump if below
							call	copy_pixel_row_v1_hgc
							add	si,0A05Ah

scroll_left_wrap:
							dec	al
							jnz	scroll_left_row_loop			; Jump if not zero
		mov	si,scroll_src_a
		mov	al,8

scroll_left2_row_loop:
							call	copy_pixel_row_v2_hgc
							add	si,2000h
							cmp	si,hgc_bank_size
							jb	scroll_left2_wrap			; Jump if below
							call	copy_pixel_row_v2_hgc
							add	si,hgc_stride_b

scroll_left2_wrap:
							dec	al
							jnz	scroll_left2_row_loop			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn

copy_pixel_row_v1_hgc		proc	near
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
		retn

copy_pixel_row_v1_hgc		endp

copy_pixel_row_v2_hgc		proc	near
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
		retn

copy_pixel_row_v2_hgc		endp

; Scroll tilemap right: shift tile rows right 1px using copy_pixel_row_v1_hgc (dispatch target)

scroll_right:				;* No entry point to code
		push	ds
		SET_ES_DS_HGC
		std				; Set direction flag
		mov	si,534h
		mov	al,10h

scroll_right_row_loop:
							call	copy_pixel_row_v3_hgc
							add	si,2000h
							cmp	si,6000h
							jb	scroll_right_wrap			; Jump if below
							call	copy_pixel_row_v3_hgc
							add	si,hgc_stride_b

scroll_right_wrap:
							dec	al
							jnz	scroll_right_row_loop			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn

copy_pixel_row_v3_hgc		proc	near
		push	si
		mov	di,si
		dec	si
		mov	cx,37h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,1Dh
		movsb				; Mov [si] to es:[di]
		pop	si
		retn

copy_pixel_row_v3_hgc		endp

; Scroll tilemap up: shift tile rows up 1 row using copy_pixel_row_v4_hgc/5 (dispatch target)

scroll_up:				;* No entry point to code
		push	ds
		SET_ES_DS_HGC
		mov	si,53C1h
		mov	al,8

scroll_up_row_loop:
							call	copy_pixel_row_v4_hgc
							add	si,2000h
							cmp	si,6000h
							jb	scroll_up_wrap			; Jump if below
							call	copy_pixel_row_v4_hgc
							add	si,0A05Ah

scroll_up_wrap:
							dec	al
							jnz	scroll_up_row_loop			; Jump if not zero
		mov	si,scroll_src_b
		mov	al,8

scroll_up2_row_loop:
							call	copy_pixel_row_v5_hgc
							add	si,2000h
							cmp	si,hgc_bank_size
							jb	scroll_up2_wrap			; Jump if below
							call	copy_pixel_row_v5_hgc
							add	si,hgc_stride_b

scroll_up2_wrap:
							dec	al
							jnz	scroll_up2_row_loop			; Jump if not zero
		pop	ds
		retn

copy_pixel_row_v4_hgc		proc	near
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
		retn

copy_pixel_row_v4_hgc		endp

copy_pixel_row_v5_hgc		proc	near
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
		retn

copy_pixel_row_v5_hgc		endp

; Scroll tilemap down: shift tile rows down 1 row using copy_pixel_row_v6_hgc (dispatch target)

scroll_down:				;* No entry point to code
		push	ds
		SET_ES_DS_HGC
		mov	si,4FDh
		mov	al,10h

scroll_down_row_loop:
							call	copy_pixel_row_v6_hgc
							add	si,2000h
							cmp	si,6000h
							jb	scroll_down_wrap			; Jump if below
							call	copy_pixel_row_v6_hgc
							add	si,hgc_stride_b

scroll_down_wrap:
							dec	al
							jnz	scroll_down_row_loop			; Jump if not zero
		pop	ds
		retn

copy_pixel_row_v6_hgc		proc	near
		push	si
		mov	di,si
		inc	si
		mov	cx,37h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,1Dh
		movsb				; Mov [si] to es:[di]
		pop	si
		retn

copy_pixel_row_v6_hgc		endp

; Blit one tile to HGC from game-seg tile_pixel_base (AL=tile_id, BH=col) (dispatch target)

blit_tile_sprite:			;* No entry point to code
		push	ds
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,8000h
		add	bh,bh
		call	math_calc
		mov	di,ax
		mov	ds,cs:gvar_game_seg
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

blit_sprite_row_loop:
							movsw				; Mov [si] to es:[di]
							add	di,1FFEh
							cmp	di,hgc_bank_size
							jb	blit_sprite_row_wrap			; Jump if below
							mov	ax,[si-2]
							stosw				; Store ax to es:[di]
							add	di,0A058h

blit_sprite_row_wrap:
							loop	blit_sprite_row_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn

; Blit 9-row tile from tile_row_data_a to HGC at computed column offset (dispatch target)

blit_tile9:				;* No entry point to code
		push	ds
		push	si
		push	di
		push	cs
		pop	ds
		call	math_calc
		mov	di,ax
		mov	ax,0B000h
		mov	es,ax
		mov	si,tile_row_data_a
		mov	cx,9

blit_tile9_row_loop:
							movsw				; Mov [si] to es:[di]
							add	di,1FFEh
							cmp	di,hgc_bank_size
							jb	blit_tile9_row_wrap			; Jump if below
							mov	ax,[si-2]
							stosw				; Store ax to es:[di]
							add	di,hgc_stride_a

blit_tile9_row_wrap:
							loop	blit_tile9_row_loop		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		retn

; Pixel row mask table (9 words): scanline intensity pattern for blit_tile9

tile9_row_mask:
		db	 00h, 00h, 28h, 00h, 2Ah, 00h	; row 0-2: 0x0000, 0x0028, 0x002A
		db	 2Ah, 80h, 2Ah,0A0h, 2Ah, 80h	; row 3-5: 0x802A, 0xA02A, 0x802A
		db	 2Ah, 00h, 28h, 00h, 00h, 00h	; row 6-8: 0x002A, 0x0028, 0x0000

; copy_tile_strip dispatch entry (alt encoding):
; call math_calc     (alt encoding)
; mov di, ax        (alt encoding)
; mov si, 3CC3h     (alt encoding)
; mov ax, 0B000h    (alt encoding)
; mov es, ax        (alt encoding)
; mov cx, 9         (alt encoding)
; [fall through to copy_tile_strip_loop]

copy_tile_strip:			;* Dispatch table entry (alt encoding of 6 instructions)
		db	0E8h, 3Ah, 05h, 8Bh,0F8h,0BEh	; call math_calc; mov di,ax; mov si,3CC3h  (alt encoding)
		db	0C3h, 3Ch,0B8h, 00h,0B0h, 8Eh	; mov ax,0B000h; mov es,ax  (alt encoding)
		db	0C0h,0B9h, 09h, 00h		; mov cx,9  (alt encoding)

copy_tile_strip_loop:
							push	cx
							push	di
							push	si
							mov	cx,ds:gvar_copy_width
							rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
							pop	si
							pop	di
							add	di,2000h
							cmp	di,hgc_bank_bdy
							jb	copy_tile_strip_wrap			; Jump if below
							push	si
							push	di
							mov	cx,ds:gvar_copy_width
							rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
							pop	di
							pop	si
							add	di,0A05Ah

copy_tile_strip_wrap:
							add	si,28h
							pop	cx
							loop	copy_tile_strip_loop		; Loop if cx > 0

		retn

; Draw string character: clear glyph buffer, render char, optionally apply overlay (dispatch target)

draw_str_char:				;* No entry point to code
		push	si
		push	di
		push	di
		xor	ah,ah			; Zero register
		push	ax
		push	cs
		pop	es
		mov	di,char_render_buf
		xor	ax,ax			; Zero register
		mov	cx,0C8h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		push	ax
		add	ax,ax
		add	si,ax
		mov	si,[si]
		call	init_text_render_buf_hgc
		pop	ax
		pop	di
		test	byte ptr ds:gvar_item_flag,0FFh
		jz	text_no_overlay			; Jump if zero
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	di,ax
		mov	dl,[di]
		mov	ax,[di+1]
		call	render_via_text_decimal_hgc

text_no_overlay:
		pop	di
		pop	si
		retn

init_text_render_buf_hgc		proc	near
		push	cs
		pop	es
		mov	di,text_render_buf
		xor	bl,bl			; Zero register

render_glyph_loop:
							lodsb				; String [si] to al
							or	al,al			; Zero ?
							jnz	render_glyph_draw			; Jump if not zero
							retn

render_glyph_draw:
							push	bx
							push	ds
							push	si
							and	bl,3
							call	compute_glyph_index_hgc
							pop	si
							pop	ds
							pop	bx
							inc	bl
							jmp	short render_glyph_loop

init_text_render_buf_hgc		endp

compute_glyph_index_hgc		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:font_ptr_b
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8

render_glyph_row_loop:
							push	bx
							lodsb				; String [si] to al
							mov	dl,4

render_pixel_shift_loop:
												add	ax,ax
												add	ah,ah
												dec	dl
												jnz	render_pixel_shift_loop			; Jump if not zero
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
							jnz	render_glyph_row_loop			; Jump if not zero
		pop	di
		inc	di
		cmp	cl,6
		je	render_glyph_wide			; Jump if equal
		retn

render_glyph_wide:
		inc	di
		retn

compute_glyph_index_hgc		endp

; Draw number: DX:AX = value, clear glyph buf, BCD-convert and render digits (dispatch target)

draw_number:				;* No entry point to code
		push	dx
		push	ax
		push	cs
		pop	es
		mov	di,char_render_buf
		xor	ax,ax			; Zero register
		mov	cx,0C8h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		pop	dx
		call	render_text_decimal_hgc
		mov	di,3CEBh
		mov	si,38D4h
		mov	cx,7
		mov	bl,1
		mov	word ptr ds:gvar_copy_width,0Bh
		jmp	short render_char_cols_loop

render_via_text_decimal_hgc		proc	near
		call	render_text_decimal_hgc
		push	cs
		pop	es
		mov	di,text_render_buf
		add	di,ds:gvar_text_ofs
		mov	si,tile_row_data_b
		mov	cx,6
		mov	bl,1

render_char_cols_loop:
							push	cx
							push	bx
							push	di
							lodsb				; String [si] to al
							push	si
							call	step_render_alt_hgc
							pop	si
							pop	di
							pop	bx
							mov	al,bl
							inc	di
							and	ax,1
							add	di,ax
							inc	bl
							pop	cx
							loop	render_char_cols_loop		; Loop if cx > 0

		retn

render_via_text_decimal_hgc		endp

step_render_alt_hgc		proc	near
		inc	al
		jnz	process3_do_render			; Jump if not zero
		retn

process3_do_render:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:font_ptr_a
		mov	si,ax
		mov	cx,7

process3_pixel_loop:
							lodsb				; String [si] to al
							mov	ah,8

process3_shift_loop:
												add	al,al
												adc	dx,dx
												add	dx,dx
												dec	ah
												jnz	process3_shift_loop			; Jump if not zero
							mov	ax,dx
							shr	dx,1			; Shift w/zeros fill
							or	ax,dx
							test	bl,1
							jnz	process3_odd_col			; Jump if not zero
							add	ax,ax
							add	ax,ax
							add	ax,ax
							add	ax,ax

process3_odd_col:
							or	es:[di],ah
							or	es:[di+1],al
							add	di,28h
							loop	process3_pixel_loop		; Loop if cx > 0

		retn

step_render_alt_hgc		endp

render_text_decimal_hgc		proc	near
		mov	di,38D4h
		call	div_24bit_emit_digit_hgc
		mov	cx,6

process4_fill_loop:
							test	byte ptr cs:[di],0FFh
							jz	process4_write_ff			; Jump if zero
							retn

process4_write_ff:
							mov	byte ptr cs:[di],0FFh
							inc	di
							loop	process4_fill_loop		; Loop if cx > 0

		retn

render_text_decimal_hgc		endp

		db	7 dup (0)		; BCD time digit storage (7 bytes: HH MM SS.tenth)

div_24bit_emit_digit_hgc		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	div_16bit_emit_digit_hgc
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	div_16bit_emit_digit_hgc
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	div_16bit_emit_digit_hgc
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	div_16bit_emit_digit_alt_hgc
		mov	cs:[di+3],dh
		mov	bx,64h
		call	div_16bit_emit_digit_alt_hgc
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	div_16bit_emit_digit_alt_hgc
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn

div_24bit_emit_digit_hgc		endp

div_16bit_emit_digit_hgc		proc	near
		xor	dh,dh			; Zero register

func29_div_loop:
							sub	dl,cl
							jc	func29_done			; Jump if carry Set
							sub	ax,bx
							jnc	func29_borrow			; Jump if carry=0
							or	dl,dl			; Zero ?
							jz	func29_add_back			; Jump if zero
							dec	dl

func29_borrow:
							inc	dh
							jmp	short func29_div_loop

func29_add_back:
		add	ax,bx

func29_done:
		add	dl,cl
		retn

div_16bit_emit_digit_hgc		endp

div_16bit_emit_digit_alt_hgc		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn

div_16bit_emit_digit_alt_hgc		endp

; Copy tile row upward in HGC (BL+CL=dst row, CH=width, copies row above) (dispatch target)

copy_tile_up:				;* No entry point to code
		push	ds
		push	ax
		add	bl,cl
		dec	bl
		call	math_calc
		mov	di,ax
		mov	si,di
		sub	si,2000h
		jnc	copy_up_si_nowrap			; Jump if carry=0
		add	si,hgc_bank_back

copy_up_si_nowrap:
		SET_ES_DS_HGC
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

copy_up_row_loop:
							push	cx
							push	di
							push	si
							mov	cx,bx
							rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
							pop	si
							pop	di
							sub	di,2000h
							jnc	copy_up_di_wrap			; Jump if carry=0
							push	di
							push	si
							add	di,hgc_wrap_fwd
							mov	cx,bx
							rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
							pop	si
							pop	di
							add	di,hgc_bank_back

copy_up_di_wrap:
							sub	si,2000h
							jnc	copy_up_si_wrap			; Jump if carry=0
							add	si,hgc_wrap_back

copy_up_si_wrap:
							pop	cx
							loop	copy_up_row_loop		; Loop if cx > 0

		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,3CC3h
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn

; Copy tile row downward in HGC (BL=dst row, CH=width, copies row below) (dispatch target)

copy_tile_down:				;* No entry point to code
		push	ds
		push	ax
		call	math_calc
		mov	di,ax
		mov	si,di
		add	si,2000h
		cmp	si,6000h
		jb	copy_dn_si_nowrap			; Jump if below
		add	si,hgc_stride_b

copy_dn_si_nowrap:
		SET_ES_DS_HGC
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

copy_dn_row_loop:
							push	cx
							push	di
							push	si
							mov	cx,bx
							rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
							pop	si
							pop	di
							add	di,2000h
							cmp	di,hgc_bank_size
							jb	copy_dn_di_wrap			; Jump if below
							push	di
							push	si
							mov	cx,bx
							rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
							pop	si
							pop	di
							add	di,hgc_stride_b

copy_dn_di_wrap:
							add	si,2000h
							cmp	si,6000h
							jb	copy_dn_si_wrap			; Jump if below
							add	si,hgc_stride

copy_dn_si_wrap:
							pop	cx
							loop	copy_dn_row_loop		; Loop if cx > 0

		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,3CC3h
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn

; Invert (XOR 0xFFFF) a 28-pixel wide area for 0x90 rows at hgc_cursor_ofs (dispatch target)

invert_screen:				;* No entry point to code
		mov	ax,0B000h
		mov	es,ax
		mov	di,hgc_cursor_ofs
		mov	cx,90h

invert_rows_outer:
							push	cx
							push	di
							mov	ax,0FFFFh
							mov	cx,1Ch

invert_scan_loop:
												xor	es:[di],ax
												inc	di
												inc	di
												loop	invert_scan_loop		; Loop if cx > 0

							pop	di
							add	di,2000h
							cmp	di,hgc_bank_size
							jb	invert_bank_wrap			; Jump if below
							push	di
							mov	ax,0FFFFh
							mov	cx,1Ch

invert_bank2_scan:
												xor	es:[di],ax
												inc	di
												inc	di
												loop	invert_bank2_scan		; Loop if cx > 0

							pop	di
							add	di,0A05Ah

invert_bank_wrap:
							pop	cx
							loop	invert_rows_outer		; Loop if cx > 0

		retn

; Encode CX tiles: copy tile rows to temp seg, compute HGC bitplane words (dispatch target)

encode_tiles:				;* No entry point to code
		mov	cs:far_ptr,di
		mov	word ptr cs:far_ptr+2,es
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

encode_tile_rows_loop:
							push	cx
							mov	cx,8

encode_tile_pixels_loop:
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
												mov	cs:bitplane_w0,dx
												mov	cs:bitplane_w1,cx
												mov	cs:bitplane_w2,bx
												not	ax
												mov	cs:bitplane_w3,ax
												call	init_8_byte_loop_hgc
												mov	ax,dx
												stosw				; Store ax to es:[di]
												push	es
												push	di
												les	di,dword ptr cs:far_ptr	; Load seg:offset ptr
												call	step_scan_alt_hgc
												mov	ax,dx
												stosw				; Store ax to es:[di]
												mov	cs:far_ptr,di
												pop	di
												pop	es
												pop	cx
												loop	encode_tile_pixels_loop		; Loop if cx > 0

							pop	cx
							loop	encode_tile_rows_loop		; Loop if cx > 0

		retn

; Reload tile pixels from game seg to encode buf, then render tilemap (dispatch target)

reload_tile_pixels:			;* No entry point to code
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,tile_pixel_base
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
		mov	bx,es:tileset_buf_a
		mov	bp,0D000h
		mov	cx,0FAh

render_tilemap_loop:
							push	cx
							mov	al,es:[bx]
							cmp	al,5
							jb	render_tile_clamp			; Jump if below
							xor	al,al			; Zero register

render_tile_clamp:
							push	bx
							xor	bx,bx			; Zero register
							mov	bl,al
							add	bx,bx
							call	word ptr cs:tile_type_tbl[bx]	;*
							pop	bx
							inc	bx
							pop	cx
							loop	render_tilemap_loop		; Loop if cx > 0

		pop	ds
		retn

; Tile type render dispatch entry + init data: daa/cmp are dispatch table word bytes

render_tile_type_entry:		;* No entry point to code
		daa				; Decimal adjust
		cmp	cx,[si+3Bh]
;*		jns	loc_119			;*Jump if not sign
		db	 79h, 3Bh		;  Fixup - byte match
		cmpsb				; Cmp [si] to es:[di]
		cmp	dx,bx
		db	3Bh, 0B9h, 08h, 00h		; cmp di, word ptr [bx+di+8] (16-bit disp)

render_opaque_loop:
							push	cx
							lodsw				; String [si] to ax
							mov	cs:bitplane_w0,ax
							lodsw				; String [si] to ax
							mov	cs:bitplane_w1,ax
							lodsw				; String [si] to ax
							mov	cs:bitplane_w2,ax
							call	init_8_byte_loop_hgc
							mov	ax,dx
							stosw				; Store ax to es:[di]
							mov	word ptr es:[bp],0
							inc	bp
							inc	bp
							pop	cx
							loop	render_opaque_loop		; Loop if cx > 0

		retn

render_masked_entry:			;* tile_type_tbl[1] dispatch entry: mov cx,8 then loop body  (alt encoding)
		db	0B9h, 08h, 00h		; mov cx, 8  (alt encoding)

render_masked_loop:
							push	cx
							lodsw				; String [si] to ax
							mov	cs:bitplane_w0,ax
							lodsw				; String [si] to ax
							mov	cs:bitplane_w1,ax
							mov	word ptr cs:bitplane_w2,0
							lodsw				; String [si] to ax
							mov	cs:bitplane_w3,ax
							call	init_8_byte_loop_hgc
							mov	ax,dx
							stosw				; Store ax to es:[di]
							call	step_scan_alt_hgc
							mov	es:[bp],dx
							inc	bp
							inc	bp
							pop	cx
							loop	render_masked_loop		; Loop if cx > 0

		retn

render_trans_entry:			;* tile_type_tbl[2] dispatch entry: mov cx,8 then loop body  (alt encoding)
		db	0B9h, 08h, 00h		; mov cx, 8  (alt encoding)

render_trans_loop:
							push	cx
							lodsw				; String [si] to ax
							mov	cs:bitplane_w0,ax
							lodsw				; String [si] to ax
							mov	cs:bitplane_w3,ax
							mov	word ptr cs:bitplane_w1,0
							lodsw				; String [si] to ax
							mov	cs:bitplane_w2,ax
							call	init_8_byte_loop_hgc
							mov	ax,dx
							stosw				; Store ax to es:[di]
							call	step_scan_alt_hgc
							mov	es:[bp],dx
							inc	bp
							inc	bp
							pop	cx
							loop	render_trans_loop		; Loop if cx > 0

		retn

render_neg_entry:			;* tile_type_tbl[3] dispatch entry: mov cx,8 then loop body  (alt encoding)
		db	0B9h, 08h, 00h		; mov cx, 8  (alt encoding)

render_neg_loop:
							push	cx
							lodsw				; String [si] to ax
							mov	cs:bitplane_w3,ax
							mov	word ptr cs:bitplane_w0,0
							lodsw				; String [si] to ax
							mov	cs:bitplane_w1,ax
							lodsw				; String [si] to ax
							mov	cs:bitplane_w2,ax
							call	init_8_byte_loop_hgc
							mov	ax,dx
							stosw				; Store ax to es:[di]
							call	step_scan_alt_hgc
							mov	es:[bp],dx
							inc	bp
							inc	bp
							pop	cx
							loop	render_neg_loop		; Loop if cx > 0

		retn

render_blank_entry:			;* tile_type_tbl[4] dispatch entry: mov cx,8 then loop body  (alt encoding)
		db	0B9h, 08h, 00h		; mov cx, 8  (alt encoding)

render_blank_loop:
							push	cx
							add	si,6
							xor	ax,ax			; Zero register
							stosw				; Store ax to es:[di]
							mov	word ptr es:[bp],0FFFFh
							inc	bp
							inc	bp
							pop	cx
							loop	render_blank_loop		; Loop if cx > 0

		retn

init_8_byte_loop_hgc		proc	near
		mov	cx,8

pixel_encode_loop:
							xor	bx,bx			; Zero register
							rol	word ptr cs:bitplane_w2,1	; Rotate
							adc	bx,bx
							rol	word ptr cs:bitplane_w1,1	; Rotate
							adc	bx,bx
							rol	word ptr cs:bitplane_w0,1	; Rotate
							adc	bx,bx
							rol	word ptr cs:bitplane_w2,1	; Rotate
							adc	bx,bx
							rol	word ptr cs:bitplane_w1,1	; Rotate
							adc	bx,bx
							rol	word ptr cs:bitplane_w0,1	; Rotate
							adc	bx,bx
							add	dx,dx
							add	dx,dx
							or	dl,cs:pixel_encode_tbl[bx]
							loop	pixel_encode_loop		; Loop if cx > 0

		retn

init_8_byte_loop_hgc		endp

; pixel_encode_tbl (CS:3C24h): 64-entry 2-bit HGC pixel encoding lookup
; Each entry maps a 6-bit (3 bitplane pairs) index to a 2-bit HGC pixel value (0-3)

pixel_encode_tbl_data:
		db	0, 1, 0, 1, 1, 0	; pixel_encode_tbl[ 0..5]
		db	3, 2, 1, 3, 2, 3	; pixel_encode_tbl[ 6..11]
		db	1, 3, 3, 2, 2, 2	; pixel_encode_tbl[12..17]
		db	2, 1, 1, 2, 2, 2	; pixel_encode_tbl[18..23]
		db	1, 3, 1, 3, 1, 1	; pixel_encode_tbl[24..29]
		db	2, 2, 1, 1, 1, 1	; pixel_encode_tbl[30..35]
		db	1, 1, 3, 2, 0, 3	; pixel_encode_tbl[36..41]
		db	2, 1, 1, 1, 3, 2	; pixel_encode_tbl[42..47]
		db	3, 3, 2, 2, 3, 3	; pixel_encode_tbl[48..53]
		db	3, 2, 1, 2, 2, 2	; pixel_encode_tbl[54..59]
		db	2, 2, 2, 2		; pixel_encode_tbl[60..63]

step_scan_alt_hgc		proc	near
		mov	cx,8

bitplane_decode_loop:
							xor	al,al			; Zero register
							rol	word ptr cs:bitplane_w3,1	; Rotate
							adc	al,al
							rol	word ptr cs:bitplane_w3,1	; Rotate
							adc	al,al
							cmp	al,3
							je	bitplane_has_mask			; Jump if equal
							xor	al,al			; Zero register

bitplane_has_mask:
							add	dx,dx
							add	dx,dx
							or	dl,al
							loop	bitplane_decode_loop		; Loop if cx > 0

		retn

step_scan_alt_hgc		endp

math_calc		proc	near
		xor	ax,ax			; Zero register
		mov	al,bl
		add	ax,1Ch
		mov	bl,3
		div	bl			; al, ah rem = ax/reg
		mov	bl,ah
		ror	bl,1			; Rotate
		ror	bl,1			; Rotate
		ror	bl,1			; Rotate
		and	bl,60h			; '`'
		mov	ah,5Ah			; 'Z'
		mul	ah			; ax = reg * al
		add	ah,bl
		add	bh,5
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		retn

math_calc		endp

		db	1127 dup (0)		; BSS: zero-initialized data areas (tile bufs, render state, etc.)

seg_a		ends

		end	start
