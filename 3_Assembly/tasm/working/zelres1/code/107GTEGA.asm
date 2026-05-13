
PAGE  59,132

;==========================================================================
;
;  107GTEGA - Town Tiles EGA Renderer (zelres1 chunk 8, gtega.bin)
;
;  EGA-specific tilemap renderer for the town/overworld engine. Loaded
;  by game.bin into the game segment (gfx_mode_tbl_all entry, mode 0)
;  alongside 106TOWN (town.bin). Provides tile blit, scroll, character
;  cell rendering, and text-glyph functions exposed via dispatch slots
;  consumed by 106TOWN.
;
;  Connections:
;    Loads:        none (rendering primitives only)
;    Calls into:   render_fn_tbl_a/b (CS:0x35BE/0x361A dispatch tables,
;                  set internally per tile type)
;    Called by:    game.bin LOAD_CHUNK chunk_ref_gtega via gfx_mode_tbl_all
;                  (gfx-driver init at loaded_code_a CS:0x3000); 106TOWN
;                  invokes gfx_draw_tile/draw_player/render_*/scroll_*/
;                  text_layout/draw_str/draw_char etc. through this chunk
;    Reads/writes: gvar_game_seg (FF2C) [zeliad-owned]; tile_flip_flag
;                  (C583, town-owned)
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr1com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
gvar_game_seg	equ	0FF2Ch			;* game segment selector word

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
; restored after factoring (per-file value, not in shared inc):
font_ptr_a               equ     0F502h
font_ptr_b               equ     0F504h
tile_type_tbl	equ	32EBh			;* tile type dispatch table (word[4])
render_fn_tbl_a	equ	35BEh			;* render function pointer table A (word[N])
render_fn_tbl_b	equ	361Ah			;* render function pointer table B (word[N])
tile_row_data	equ	38B9h			;* tile row source data pointer
icon_seq_tbl	equ	3A32h			;* icon/status sequence table
tile_vga_ofs	equ	3BB1h			;* current tile row VGA byte offset (word)
tile_row_ctr	equ	3BB3h			;* current tile row counter (byte, 0..1Ch)
tile_col_ctr	equ	3BBAh			;* current tile column counter (word)
char_render_buf	equ	3BBCh			;* character/sprite render buffer
text_render_buf	equ	3BE4h			;* text glyph render buffer
tile_cache_tbl	equ	3D4Ch			;* tile VGA address cache table (word[N])
tile_disp_tbl	equ	3E80h			;* tile column displacement table (word[N]) ;*
ega_hud_top	equ	46Ch			; EGA framebuffer HUD top-left offset
ega_hud_b	equ	4A3h			; EGA framebuffer HUD area B offset
ega_mid_ofs	equ	0C80h			; EGA framebuffer middle column offset constant
tile_dest_ofs	equ	24ECh			; tile blit destination EGA offset
scroll_left_a	equ	2C6Ch			; scroll-left source offset A
scroll_left_b	equ	2CA3h			; scroll-left source offset B
scroll_right_a	equ	2EECh			; scroll-right source offset A
scroll_right_b	equ	2F23h			; scroll-right source offset B
tile_work_ptr	equ	3BB5h			; tile work buffer destination pointer
tile_buf_a	equ	3E80h			; tile render buffer A (column 0)
tile_buf_b	equ	3EB0h			; tile render buffer B (column 1)
tile_buf_c	equ	3EE0h			; tile render buffer C (column 2)
tile_buf_d	equ	3F10h			; tile render buffer D (column 3)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
tile_state_flag	equ	3628h			;* tile state flag byte
tile_idx_a	equ	3BB4h			;* tile index A (byte)
tile_idx_b	equ	3BB7h			;* tile index B (byte, 0FDh = none)
tile_flip_flag	equ	0C583h			;* tile flip/mirror flag byte

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
ega_row_stride	equ	4Eh			; EGA bytes per row (78 = 640/8)

; EGA_SETUP_702_105
;   EGA mode-setup for tile rendering: sequencer map-mask=07, graphics mode=01.
EGA_SETUP_702_105	MACRO
		mov	dx, 3C4h
		mov	ax, 702h
		out	dx, ax
		mov	dx, 3CEh
		mov	ax, 105h
		out	dx, ax
		ENDM
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

run_gtega_main		proc	far

; Module init block: word-pair dispatch table + EGA setup prologue.
; Called by the loader to register entry points and initialize EGA planes.
; Format: 16 dw offsets (function table), then inline EGA init code.
;   Dispatch entries (word offsets into this segment):
;     [0]=scroll_left_entry  [1]=scroll_down_entry  [2]=scroll_up_entry
;     [3]=plane_mix_a_entry  [4]=plane_mix_b_entry  [5]=plane_mix_c_entry
;     [6]=plane_clear_entry  [7]=tile_col6_render    [8]=tile_disp_entry
;     [9]=render_tile_flip_entry  [A]=render_tile_wide_entry
;     [B]=render_via_proc_loop2_ega  [C]=status_render_entry  [D]=decode_entity_slot_byte_ega
;     [E]=scroll_right_entry  [F]=scroll_right_entry (same)
;   Inline EGA init: push ds; mov si,186Ch; mov di,0A000h; push cs; pop es;
;                   mov ax,0A000h; mov ds,ax; mov dx,3CEh; mov al,4; out dx,al;
;                   inc dx; mov cx,1Ch  -> falls into tile_col_scan_loop

start:
		dec	sp
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bx+si],al
		db	'f;(0\0&7'	; dispatch table entries 0-3 (word offsets)
		db	 7Fh, 37h,0B7h, 37h, 0Eh, 38h	; entries 4-6
		db	0B6h, 33h, 0Ch, 36h, 69h, 36h	; entries 7-9
		db	0D2h, 35h, 44h, 38h, 8Ch, 38h	; entries A-C
		db	0FEh, 38h,0CBh, 38h,0A1h, 3Ah	; entries D-F
		db	 09h, 3Bh, 8Eh, 39h,0B0h, 3Bh	; entries 10-12
		db	0B0h, 3Bh		; entry 13 (scroll_right, repeated)
		; inline EGA init: push ds; mov si,186Ch; mov di,0A000h
		db	1Eh,0BEh, 6Ch, 18h	; push ds; mov si,186Ch
		db	0BFh, 00h,0A0h		; push cs; pop es; mov ax,0A000h
		db	 0Eh, 07h,0B8h		; (continued) mov ax,0A000h opcode prefix
		db	 00h,0A0h, 8Eh,0D8h	; mov ds,ax; mov dx,3CEh
		db	0BAh,0CEh		; (continued) mov dx,3CEh operand
		db	 03h,0B0h, 04h,0EEh	; mov al,4; out dx,al; inc dx
		db	 42h,0B9h		; (continued) mov cx,... opcode prefix
		db	 1Ch, 00h		; mov cx,1Ch -> fall into tile_col_scan_loop

tile_col_scan_loop:
						push	cx
						push	si
						mov	cx,18h

tile_plane_out_loop:
										mov	al,0
										out	dx,al			; port 0, DMA-1 bas&add ch 0
										movsw				; Mov [si] to es:[di]
										dec	si
										dec	si
										mov	al,2
										out	dx,al			; port 0, DMA-1 bas&add ch 0
										movsw				; Mov [si] to es:[di]
										add	si,4Eh
										loop	tile_plane_out_loop		; Loop if cx > 0

						pop	si
						pop	cx
						inc	si
						inc	si
						loop	tile_col_scan_loop		; Loop if cx > 0

		pop	ds
		retn

; Entry: render_tile_row - clear tile cache, then render all tile rows
			                        ;* No entry point to code

render_tile_row:
		push	cs
		pop	es
		mov	di,tile_cache_tbl
		xor	ax,ax			; Zero register
		mov	cx,100h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,ds:gvar_map_ptr
		cmp	byte ptr [si+1Dh],0FDh
		jne	skip_double_tile			; Jump if not equal
		call	save_state_then_blit_ega

skip_double_tile:
		mov	word ptr ds:tile_vga_ofs,186Ch
		mov	si,ds:gvar_map_ptr
		add	si,20h
		push	cs
		pop	es
		mov	di,0E000h
		mov	byte ptr ds:tile_row_ctr,0

tile_row_loop:
						call	run_render_passes_gtega
						xor	bl,bl			; Zero register
						cmpsb				; Cmp [si] to es:[di]
						jz	tile_col0_ok			; Jump if zero
						call	mark_tile_FE_ega

tile_col0_ok:
						inc	bl
						cmpsb				; Cmp [si] to es:[di]
						jz	tile_col1_ok			; Jump if zero
						call	mark_tile_FE_ega

tile_col1_ok:
						inc	bl
						cmpsb				; Cmp [si] to es:[di]
						jz	tile_col2_ok			; Jump if zero
						call	mark_tile_FE_ega

tile_col2_ok:
						inc	bl
						cmpsb				; Cmp [si] to es:[di]
						jz	tile_col3_ok			; Jump if zero
						call	render_tile_entry_ega

tile_col3_ok:
						inc	bl
						cmpsb				; Cmp [si] to es:[di]
						jz	tile_col4_ok			; Jump if zero
						call	render_tile_entry_ega

tile_col4_ok:
						inc	bl
						cmpsb				; Cmp [si] to es:[di]
						jz	tile_col5_ok			; Jump if zero
						call	render_tile_if_marked_ega

tile_col5_ok:
						inc	bl
						cmpsb				; Cmp [si] to es:[di]
						jz	tile_col6_ok			; Jump if zero
						call	render_tile_entry_ega

tile_col6_ok:
						inc	bl
						cmpsb				; Cmp [si] to es:[di]
						jz	tile_col7_ok			; Jump if zero
						call	render_tile_entry_ega

tile_col7_ok:
						add	word ptr ds:tile_vga_ofs,2
						inc	byte ptr ds:tile_row_ctr
						cmp	byte ptr ds:tile_row_ctr,1Ch
						jne	tile_row_loop			; Jump if not equal
		retn

run_gtega_main		endp

run_render_passes_gtega		proc	near
		cmp	byte ptr ds:tile_row_ctr,1Bh
		jne	check_not_last_row			; Jump if not equal
		retn

check_not_last_row:
		mov	al,byte ptr ds:[screen_position]
		cmp	ds:tile_row_ctr,al
		je	do_tile_blit			; Jump if equal
		retn

do_tile_blit:
		push	di
		push	es
		push	si
		push	ds
		mov	al,byte ptr ds:[screen_position]
		add	al,al
		xor	ah,ah			; Zero register
		mov	di,ax
		add	di,tile_dest_ofs
		SET_ES_DS_VGA
		mov	si,tile_buf_a
		EGA_SETUP_702_105
						;  al = 5, mode
		mov	cx,2

blit_pass_loop:
						push	cx
						call	init_4E_loop_ega
						add	di,0F882h
						pop	cx
						loop	blit_pass_loop		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		pop	si
		pop	es
		pop	di
		retn

run_render_passes_gtega		endp

render_tile_if_marked_ega		proc	near
		cmp	byte ptr [si-1],0FDh
		jne	tile_render_entry			; Jump if not equal
		jmp	door_tile_handler

render_tile_if_marked_ega		endp

render_tile_entry_ega		proc	near

tile_render_entry:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	tile_not_empty			; Jump if not zero
		retn

tile_not_empty:
		dec	di
		dec	si
		mov	dl,[si]
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	ax,50h
		mul	bl			; ax = reg * al
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,ds:tile_vga_ofs
		mov	di,ax
		mov	bl,dl
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:tile_cache_tbl[bx],0FFFFh
		jnz	tile_cached			; Jump if not zero
		mov	ds:tile_cache_tbl[bx],di
		mov	ax,30h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,tile_pixel_base
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	ds,cs:gvar_game_seg
		mov	ax,0A000h
		mov	es,ax
		mov	bx,4Eh
		mov	cx,4

tile_plane_write_loop:
						mov	al,1
						out	dx,al			; port 3C5h, EGA sequencr func
						movsw				; Mov [si] to es:[di]
						mov	al,2
						out	dx,al			; port 3C5h, EGA sequencr func
						lodsw				; String [si] to ax
						mov	es:[di-2],ax
						dec	di
						dec	di
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						movsw				; Mov [si] to es:[di]
						add	di,bx
						mov	al,1
						out	dx,al			; port 3C5h, EGA sequencr func
						movsw				; Mov [si] to es:[di]
						mov	al,2
						out	dx,al			; port 3C5h, EGA sequencr func
						lodsw				; String [si] to ax
						mov	es:[di-2],ax
						dec	di
						dec	di
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						movsw				; Mov [si] to es:[di]
						add	di,bx
						loop	tile_plane_write_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

tile_cached:
		mov	si,ds:tile_cache_tbl[bx]
		EGA_SETUP_702_105
		SET_ES_DS_VGA
		mov	bx,ega_row_stride
		REPT 7
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		ENDM
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

render_tile_entry_ega		endp

mark_tile_FE_ega		proc	near
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	do_tile_lookup			; Jump if not zero
		retn

do_tile_lookup:
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
		jnz	tile_found_in_set			; Jump if not zero
		jmp	tile_render_entry

tile_found_in_set:
		dec	di
		dec	si
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		xor	ah,ah			; Zero register
		mov	al,dh
		dec	al
		and	al,3
		add	al,al
		mov	di,ax
		mov	ax,ds:tile_type_tbl[di]
		push	ax
		mov	ax,50h
		mul	bl			; ax = reg * al
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,ds:tile_vga_ofs
		mov	di,ax
		mov	ax,30h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,8100h
		mov	ax,60h
		mul	byte ptr ds:tile_row_ctr	; ax = data * al
		shl	bl,1			; Shift w/zeros fill
		shl	bl,1			; Shift w/zeros fill
		shl	bl,1			; Shift w/zeros fill
		shl	bl,1			; Shift w/zeros fill
		shl	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		add	bx,ax
		add	bx,0A000h
		mov	bp,bx
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	ds,cs:gvar_game_seg
;*		mov	ax,offset vgadec_func_25	;*
		db	0B8h, 00h,0A0h		;  Fixup - byte match
		mov	es,ax
		pop	ax
		call	ax			;*
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	ah,[di-1]
		or	ah,ah			; Zero ?
		jnz	tile_remap_check			; Jump if not zero
		retn

tile_remap_check:
		cmp	ah,19h
		jb	do_tile_remap			; Jump if below
		retn

do_tile_remap:
		push	di
		push	es
		mov	es,cs:gvar_game_seg
		mov	di,es:tileset_buf_b
		mov	cl,es:[di]
		or	cl,cl			; Zero ?
		jz	remap_done			; Jump if zero
		inc	di

remap_search_loop:
						mov	al,es:[di]
						cmp	al,0FFh
						je	remap_done			; Jump if equal
						cmp	ah,al
						jne	remap_next			; Jump if not equal
						mov	al,es:[di+1]
						mov	[si-1],al
						jmp	short remap_done

remap_next:
						inc	di
						inc	di
						dec	cl
						jnz	remap_search_loop			; Jump if not zero

remap_done:
		pop	es
		pop	di
		retn

; render_fn_tbl_a: word table of EGA plane-mix render functions (4 entries)
; [0]=plane_mix_a_entry [1]=plane_mix_b_entry [2]=plane_mix_c_entry [3]=plane_clear_entry
			                        ;* No entry point to code
		db	0F3h, 32h, 27h, 33h, 62h, 33h	; word table: 32F3h, 3327h, 3362h
		db	 94h, 33h			; word table entry: 3394h

; plane_mix_a_entry: called via render_fn_tbl_a[0], sets cx=8 then mixes planes
			                        ;* No entry point to code

plane_mix_a_entry:
		db	0B9h, 08h, 00h			; mov cx,8

plane_mix_loop_a:
						push	cx
						mov	al,2
						out	dx,al			; port 3C5h, EGA sequencr func
						lodsw				; String [si] to ax
						mov	bx,ax
						movsw				; Mov [si] to es:[di]
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						lodsw				; String [si] to ax
						mov	cx,ax
						mov	ax,cs:[bp+2]
						and	ax,cx
						mov	es:[di-2],ax
						mov	al,1
						out	dx,al			; port 3C5h, EGA sequencr func
						mov	ax,cs:[bp]
						and	ax,cx
						or	ax,bx
						mov	es:[di-2],ax
						add	di,4Eh
						add	bp,4
						pop	cx
						loop	plane_mix_loop_a		; Loop if cx > 0

		retn

; plane_mix_b_entry: called via render_fn_tbl_a[1], sets cx=8

plane_mix_b_entry:
		db	0B9h, 08h, 00h			; mov cx,8

plane_mix_loop_b:
						push	cx
						lodsw				; String [si] to ax
						mov	bx,ax
						lodsw				; String [si] to ax
						mov	cx,ax
						mov	al,1
						out	dx,al			; port 3C5h, EGA sequencr func
						mov	ax,cs:[bp]
						and	ax,cx
						or	ax,bx
						stosw				; Store ax to es:[di]
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						lodsw				; String [si] to ax
						mov	bx,ax
						mov	ax,cs:[bp+2]
						and	ax,cx
						or	ax,bx
						mov	es:[di-2],ax
						mov	al,2
						out	dx,al			; port 3C5h, EGA sequencr func
						mov	word ptr es:[di-2],0
						add	di,4Eh
						add	bp,4
						pop	cx
						loop	plane_mix_loop_b		; Loop if cx > 0

		retn

; plane_mix_c_entry: called via render_fn_tbl_a[2], sets cx=8

plane_mix_c_entry:
		db	0B9h, 08h, 00h			; mov cx,8

plane_mix_loop_c:
						push	cx
						lodsw				; String [si] to ax
						mov	bx,ax
						mov	al,2
						out	dx,al			; port 3C5h, EGA sequencr func
						movsw				; Mov [si] to es:[di]
						mov	al,1
						out	dx,al			; port 3C5h, EGA sequencr func
						mov	ax,cs:[bp]
						and	ax,bx
						mov	es:[di-2],ax
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						lodsw				; String [si] to ax
						mov	cx,cs:[bp+2]
						and	cx,bx
						or	cx,ax
						mov	es:[di-2],cx
						add	di,4Eh
						add	bp,4
						pop	cx
						loop	plane_mix_loop_c		; Loop if cx > 0

		retn

; plane_clear_entry: called via render_fn_tbl_a[3], copies CS tile data clearing plane2
			                        ;* No entry point to code

plane_clear_entry:
		push	ds
		push	cs
		pop	ds
		mov	si,bp
		mov	cx,8

plane_clear_loop:
						mov	al,1
						out	dx,al			; port 3C5h, EGA sequencr func
						movsw				; Mov [si] to es:[di]
						mov	al,2
						out	dx,al			; port 3C5h, EGA sequencr func
						mov	word ptr es:[di-2],0
						dec	di
						dec	di
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						movsw				; Mov [si] to es:[di]
						add	di,4Eh
						loop	plane_clear_loop		; Loop if cx > 0

		pop	ds
		retn

mark_tile_FE_ega		endp

; tile_col6_render: called with di=tile_buf_a, cx=6, renders 6 tile columns to EGA

tile_col6_render	proc	near
		db	0BFh, 80h, 3Eh			; mov di,tile_buf_a (3E80h)
tile_col6_render	endp

set_cx_6_ega		proc	near
		mov	cx,6
set_cx_6_ega		endp

set_es_to_vga_ega		proc	near
		mov	ax,0A000h
		mov	es,ax

tile_col_loop:
						push	cx
						lodsb				; String [si] to al
						push	ds
						push	si
						mov	cl,30h			; '0'
						mul	cl			; ax = reg * al
						mov	si,ax
						add	si,tile_pixel_base
						mov	ds,cs:gvar_game_seg
						mov	dx,3C4h
						mov	al,2
						out	dx,al			; port 3C4h, EGA sequencr index
										;  al = 2, map mask register
						inc	dx
						mov	cx,8

tile_plane_loop:
										mov	al,1
										out	dx,al			; port 3C5h, EGA sequencr func
										movsw				; Mov [si] to es:[di]
										mov	al,2
										out	dx,al			; port 3C5h, EGA sequencr func
										lodsw				; String [si] to ax
										mov	es:[di-2],ax
										dec	di
										dec	di
										mov	al,4
										out	dx,al			; port 3C5h, EGA sequencr func
										movsw				; Mov [si] to es:[di]
										loop	tile_plane_loop		; Loop if cx > 0

						pop	si
						pop	ds
						pop	cx
						loop	tile_col_loop		; Loop if cx > 0

		retn

set_es_to_vga_ega		endp

door_tile_handler:
		push	ds
		push	si
		push	es
		push	di
		mov	di,tile_work_ptr
		movsw				; Mov [si] to es:[di]
		add	si,5
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dl,cs:tile_row_ctr
		add	dl,4
		xor	dh,dh			; Zero register
		add	dx,word ptr cs:[starting_position_in_town]
		mov	ds:tile_col_ctr,dx
		call	load_tile_list_then_use_ega
		mov	es:tile_idx_a,al
		cmp	byte ptr es:tile_idx_b,0FDh
		jne	door_check_idx_b			; Jump if not equal
		inc	dx
		call	load_tile_list_then_use_ega
		mov	es:tile_idx_b,al

door_check_idx_b:
		mov	si,3BB4h
		mov	di,3EE0h
		call	set_cx_6_ega
		mov	si,cs:tile_list_ptr

door_list_loop:
						call	render_2_col_iter_ega
						or	bl,bl			; Zero ?
						jz	door_list_next			; Jump if zero
						push	si
						push	bx
						call	decode_entity_slot_byte_ega
						pop	bx
						mov	es,cs:gvar_game_seg
						mov	si,tile_idx_a
						call	compute_col_decrement_ega
						pop	si

door_list_next:
						add	si,8
;*		cmp	word ptr [si],0FFFFh
						db	 83h, 3Ch,0FFh		;  Fixup - byte match
						jnz	door_list_loop			; Jump if not zero
		pop	di
		pop	es
		mov	ch,es:[di-1]
		mov	cl,es:[di+7]
		push	es
		push	di
		push	cx
		mov	di,cs:tile_vga_ofs
		add	di,ega_mid_ofs
		push	di
		mov	si,tile_buf_c
		SET_ES_DS_VGA
		EGA_SETUP_702_105
						;  al = 5, mode
		inc	ch
		jz	door_skip_top			; Jump if zero
		call	init_4E_loop_ega

door_skip_top:
		pop	di
		pop	cx
		cmp	byte ptr cs:tile_row_ctr,1Bh
		je	door_blit_done			; Jump if equal
		mov	si,tile_buf_d
		inc	di
		inc	di
		inc	cl
		jz	door_blit_done			; Jump if zero
		call	init_4E_loop_ega

door_blit_done:
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
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

save_state_then_blit_ega		proc	near
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
		jne	skip_door_remap			; Jump if not equal
		inc	dx
		call	load_tile_list_then_use_ega
		mov	ds:tile_idx_a,al

skip_door_remap:
		mov	si,tile_idx_a
		mov	di,3EE0h
		mov	cx,3
		call	set_es_to_vga_ega
		mov	si,cs:tile_list_ptr

door_list_loop_2:
						call	render_2_col_iter_ega
						or	bl,bl			; Zero ?
						jz	door_list_next_2			; Jump if zero
						push	si
						dec	bl
						mov	al,3
						mul	bl			; ax = reg * al
						push	ax
						call	decode_entity_slot_byte_ega
						pop	ax
						add	di,ax
						mov	bp,di
						mov	es,cs:gvar_game_seg
						mov	si,tile_idx_a
						mov	di,3EE0h
						call	render_3_tile_cols_ega
						pop	si

door_list_next_2:
						add	si,8
;*		cmp	word ptr [si],0FFFFh
						db	 83h, 3Ch,0FFh		;  Fixup - byte match
						jnz	door_list_loop_2			; Jump if not zero
		mov	di,tile_dest_ofs
		mov	si,tile_buf_c
		SET_ES_DS_VGA
		EGA_SETUP_702_105
						;  al = 5, mode
		call	init_4E_loop_ega
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		pop	es
		mov	di,marker_buf
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn

save_state_then_blit_ega		endp

load_tile_list_then_use_ega		proc	near
		call	load_tile_list_ptr_ega
		mov	al,[si+3]
		cmp	al,0FDh
		je	door_chain_next			; Jump if equal
		retn

door_chain_next:
						add	si,8
						call	match_tile_by_dx_ega
						mov	al,[si+3]
						cmp	al,0FDh
						je	door_chain_next			; Jump if equal
		retn

load_tile_list_then_use_ega		endp

load_tile_list_ptr_ega		proc	near
		mov	si,ds:tile_list_ptr
load_tile_list_ptr_ega		endp

match_tile_by_dx_ega		proc	near

tile_match_check:
						cmp	dx,[si]
						jne	tile_match_next			; Jump if not equal
						retn

tile_match_next:
						add	si,8
						jmp	short tile_match_check

match_tile_by_dx_ega		endp

init_4E_loop_ega		proc	near
		mov	bx,4Eh
		mov	cx,3

tile_row_blit_loop:
						REPT 8
						movsb				; Mov [si] to es:[di]
						movsb				; Mov [si] to es:[di]
						add	di,bx
						ENDM
						loop	tile_row_blit_loop		; Loop if cx > 0

		retn

init_4E_loop_ega		endp

compute_col_decrement_ega		proc	near
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:render_fn_tbl_a[bx]	;*
		retn

compute_col_decrement_ega		endp

; Orphan code stubs (no entry point known; all target tile_render_cols / render_3_tile_cols_ega).
; Preserved verbatim; byte offsets 5C2h-5D5h in segment.
			                        ;* No entry point to code
		retf	0C235h			; retf 0C235h  (alt encoding: far return adj SP -- unreachable)
			                        ;* No entry point to code
		xor	ax,0E0BFh		; xor ax,0E0BFh  (alt encoding: purpose unknown)
		db	 3Eh,0E8h, 70h, 00h	; ds: call tile_render_cols  (DS-prefixed near call, alt encoding)
		db	0EBh, 6Eh		; jmp tile_render_cols  (alt encoding)
		db	 83h,0C6h, 03h		; add si,3  (alt encoding)
		db	0BFh, 10h, 3Fh		; mov di,tile_buf_d  (3F10h, alt encoding)
		db	0EBh, 66h		; jmp tile_render_cols  (alt encoding)

decode_entity_slot_byte_ega		proc	near
		mov	al,[si+2]
		mov	ch,al
		and	al,7Fh
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,4000h
		mov	di,ax
		xor	dl,dl			; Zero register
		or	ch,ch			; Zero ?
		js	set_dl_4			; Jump if sign=1
		mov	dl,4

set_dl_4:
		mov	al,[si+4]
		and	al,3
		add	al,dl
		mov	cl,6
		mul	cl			; ax = reg * al
		add	di,ax
		retn

decode_entity_slot_byte_ega		endp

render_2_col_iter_ega		proc	near
		mov	cx,2
		mov	dx,ds:tile_col_ctr

col_search_loop:
						mov	bl,cl
						cmp	[si],dx
						jne	col_no_match			; Jump if not equal
						retn

col_no_match:
						inc	dx
						loop	col_search_loop		; Loop if cx > 0

		mov	bl,cl
		retn

render_2_col_iter_ega		endp

; tile_disp_entry: dispatch via render_fn_tbl_b[bl-1], set bp=di as dest
			                        ;* No entry point to code

tile_disp_entry:
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:render_fn_tbl_b[bx]	;*
		retn

; render_fn_tbl_b[0]: flip/mirror tile - apply state+flip flags, add column displacement
			                        ;* No entry point to code

render_tile_flip_entry:
		xor	ds:tile_state_flag,dh
		and	ds:tile_flip_flag,dh
		add	di,ds:tile_disp_tbl[bx]
		jmp	short tile_render_cols

; render_fn_tbl_b[1]: wide tile - render from tile_buf_a via render_3_tile_cols_ega
			                        ;* No entry point to code

render_tile_wide_entry:
		mov	di,3E80h
		call	render_3_tile_cols_ega
		jmp	short tile_render_cols

; render_fn_tbl_b[2]: alt column tile - advance si by 3, use tile_buf_b
			                        ;* No entry point to code

render_tile_alt_entry:
		mov	di,tile_buf_b
		add	si,3
		jmp	short tile_render_cols

render_3_tile_cols_ega		proc	near

tile_render_cols:
		mov	cx,3

col_render_loop:
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
						mov	cl,30h			; '0'
						mul	cl			; ax = reg * al
						add	ax,4100h
						mov	si,ax
						mov	ds,cs:gvar_game_seg
						mov	ax,0A000h
						mov	es,ax
						call	set_seq_map_mask_7_ega
						pop	bp
						pop	es
						pop	si
						pop	ds
						pop	cx
						loop	col_render_loop		; Loop if cx > 0

		retn

render_3_tile_cols_ega		endp

; tile_rerender_entry: re-render 6 tile columns into EGA from tile_buf_a
			                        ;* No entry point to code

tile_rerender_entry:
		mov	di,tile_buf_a
		mov	cx,6

tile_rerender_loop:
						push	cx
						lodsb				; String [si] to al
						push	ds
						push	si
						mov	cl,30h			; '0'
						mul	cl			; ax = reg * al
						add	ax,6000h
						mov	si,ax
						mov	ds,cs:gvar_game_seg
						mov	ax,0A000h
						mov	es,ax
						call	set_seq_map_mask_7_ega
						pop	si
						pop	ds
						pop	cx
						loop	tile_rerender_loop		; Loop if cx > 0

		retn

set_seq_map_mask_7_ega		proc	near
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,8

glyph_row_loop:
						push	cx
						mov	ax,3
						out	dx,ax			; port 3CEh, EGA graphic index
										;  al = 3, data rotate
						mov	al,8
						out	dx,al			; port 3CEh, EGA graphic index
										;  al = 8, data bit mask
						inc	dx
						lodsw				; String [si] to ax
						mov	cx,ax
						lodsw				; String [si] to ax
						mov	bx,ax
						lodsw				; String [si] to ax
						mov	bp,ax
						or	ax,bx
						or	ax,cx
						out	dx,al			; port 3CFh, EGA graphic func
						xor	al,al			; Zero register
						xchg	es:[di],al
						mov	al,ah
						out	dx,al			; port 3CFh, EGA graphic func
						xor	al,al			; Zero register
						xchg	es:[di+1],al
						mov	ax,bp
						and	ax,bx
						and	ax,cx
						xchg	cx,ax
						push	ax
						dec	dx
						mov	ax,1003h
						out	dx,ax			; port 3CEh, EGA graphic index
										;  al = 3, data rotate
						mov	al,8
						out	dx,al			; port 3CEh, EGA graphic index
										;  al = 8, data bit mask
						inc	dx
						pop	ax
						xor	al,cl
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,1
						xchg	es:[di],al
						xor	ah,ch
						mov	al,ah
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,1
						xchg	es:[di+1],al
						mov	ax,bx
						xor	al,cl
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,2
						xchg	es:[di],al
						xor	ah,ch
						mov	al,ah
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,2
						xchg	es:[di+1],al
						mov	ax,bp
						xor	al,cl
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,4
						xchg	es:[di],al
						xor	ah,ch
						mov	al,ah
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,4
						xchg	es:[di+1],al
						dec	dx
						inc	di
						inc	di
						pop	cx
						loop	glyph_row_loop		; Loop if cx > 0

		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

set_seq_map_mask_7_ega		endp

; scroll_left_entry: scroll EGA viewport one pixel left
		                        ;* No entry point to code

scroll_left_entry:
		push	ds
		EGA_SETUP_702_105
		SET_ES_DS_VGA
		std				; Set direction flag
		mov	si,scroll_left_b
		mov	al,8

scroll_left_row_a:
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
						add	si,50h
						dec	al
						jnz	scroll_left_row_a			; Jump if not zero
		mov	si,scroll_right_b
		mov	al,8

scroll_left_row_b:
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
						add	si,50h
						dec	al
						jnz	scroll_left_row_b			; Jump if not zero
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		cld				; Clear direction
		retn

; scroll_down_entry: scroll EGA viewport one pixel down (std, from ega_hud_b)
			                        ;* No entry point to code

scroll_down_entry:
		push	ds
		EGA_SETUP_702_105
		SET_ES_DS_VGA
		std				; Set direction flag
		mov	si,ega_hud_b
		mov	al,10h

scroll_down_row:
						push	si
						mov	di,si
						dec	si
						mov	cx,37h
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						add	si,1Dh
						movsb				; Mov [si] to es:[di]
						pop	si
						add	si,50h
						dec	al
						jnz	scroll_down_row			; Jump if not zero
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		cld				; Clear direction
		retn

; scroll_right_entry: scroll EGA viewport one pixel right (from scroll_left_a)
			                        ;* No entry point to code

scroll_right_entry:
		push	ds
		EGA_SETUP_702_105
		SET_ES_DS_VGA
		mov	si,scroll_left_a
		mov	al,8

scroll_right_row_a:
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
						add	si,50h
						dec	al
						jnz	scroll_right_row_a			; Jump if not zero
		mov	si,scroll_right_a
		mov	al,8

scroll_right_row_b:
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
						add	si,50h
						dec	al
						jnz	scroll_right_row_b			; Jump if not zero
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn

; scroll_up_entry: scroll EGA viewport one pixel up (from ega_hud_top)
			                        ;* No entry point to code

scroll_up_entry:
		push	ds
		EGA_SETUP_702_105
		SET_ES_DS_VGA
		mov	si,ega_hud_top
		mov	al,10h

scroll_up_row:
						push	si
						mov	di,si
						inc	si
						mov	cx,37h
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						sub	si,1Dh
						movsb				; Mov [si] to es:[di]
						pop	si
						add	si,50h
						dec	al
						jnz	scroll_up_row			; Jump if not zero
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn

; tile_blit_entry: blit one tile (al=tile_index, bl=col, bh=row) to EGA
			                        ;* No entry point to code

tile_blit_entry:
		push	ds
		push	si
		mov	dl,30h			; '0'
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,tileset_buf_a
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		mov	di,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	ds,cs:gvar_game_seg
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

tile_plane_blit_loop:
						mov	al,1
						out	dx,al			; port 3C5h, EGA sequencr func
						movsw				; Mov [si] to es:[di]
						mov	al,2
						out	dx,al			; port 3C5h, EGA sequencr func
						lodsw				; String [si] to ax
						mov	es:[di-2],ax
						dec	di
						dec	di
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						movsw				; Mov [si] to es:[di]
						add	di,4Eh
						loop	tile_plane_blit_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn

; sprite_blit_entry: blit sprite row from CS tile data (al=row, bl=col) to EGA plane 1
			                        ;* No entry point to code

sprite_blit_entry:
		push	ds
		push	si
		push	di
		push	cs
		pop	ds
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	dx,3C4h
		mov	ax,202h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	ax,0A000h
		mov	es,ax
		mov	si,tile_row_data
		mov	cx,9

sprite_row_blit_loop:
						movsw				; Mov [si] to es:[di]
						add	di,4Eh
						loop	sprite_row_blit_loop		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		retn
		db	0, 0			; 2 padding bytes before dispatch_tbl_start

dispatch_tbl_start:
						jo	$+2			; delay for I/O
						jle	$+2			; delay for I/O
;*		jg	loc_60			;*Jump if >
						db	 7Fh,0C0h		;  Fixup - byte match
						jg	dispatch_tbl_start			; Jump if >
;*		jg	loc_61			;*Jump if >
		db	 7Fh,0C0h		;  Fixup - byte match
		jle	$+2			; delay for I/O
		jo	$+2			; delay for I/O
		add	[bx+si],al
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	si,char_render_buf
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	cx,9

char_row_copy_loop:
						push	cx
						push	di
						push	si
						mov	cx,ds:gvar_copy_width
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	si
						add	si,28h
						pop	di
						add	di,50h
						pop	cx
						loop	char_row_copy_loop		; Loop if cx > 0

		retn

; char_render_entry: render string at EGA position (ax=char_index, si=string_tbl_ptr)
			                        ;* No entry point to code

char_render_entry:
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
		call	init_text_render_buf_ega
		pop	ax
		pop	di
		test	byte ptr ds:gvar_item_flag,0FFh
		jz	no_item_render			; Jump if zero
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	di,ax
		mov	dl,[di]
		mov	ax,[di+1]
		call	render_via_proc_loop2_ega

no_item_render:
		pop	di
		pop	si
		retn

init_text_render_buf_ega		proc	near
		push	cs
		pop	es
		mov	di,text_render_buf
		xor	bl,bl			; Zero register

char_next_loop:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jnz	char_not_done			; Jump if not zero
						retn

char_not_done:
						push	bx
						push	ds
						push	si
						and	bl,3
						call	compute_glyph_index_ega
						pop	si
						pop	ds
						pop	bx
						inc	bl
						jmp	short char_next_loop

init_text_render_buf_ega		endp

compute_glyph_index_ega		proc	near
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

char_bit_shift_loop:
						push	bx
						lodsb				; String [si] to al
						xor	bl,bl			; Zero register
						mov	bh,al
						shr	bx,cl			; Shift w/zeros fill
						or	es:[di],bh
						or	es:[di+1],bl
						add	di,28h
						pop	bx
						dec	bl
						jnz	char_bit_shift_loop			; Jump if not zero
		pop	di
		inc	di
		cmp	cl,6
		je	char_second_byte			; Jump if equal
		retn

char_second_byte:
		inc	di
		retn

compute_glyph_index_ega		endp

; status_render_entry: render all status icons (clears char_render_buf, renders 7 slots)
			                        ;* No entry point to code

status_render_entry:
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
		call	step_text_char_loop2_ega
		mov	di,3BE4h
		mov	si,3A31h
		mov	cx,7
		mov	bl,1
		mov	word ptr ds:gvar_copy_width,0Bh
		jmp	short icon_slot_loop

render_via_proc_loop2_ega		proc	near
		call	step_text_char_loop2_ega
		push	cs
		pop	es
		mov	di,text_render_buf
		add	di,ds:gvar_text_ofs
		mov	si,icon_seq_tbl
		mov	cx,6
		mov	bl,1

icon_slot_loop:
						push	cx
						push	bx
						push	di
						lodsb				; String [si] to al
						push	si
						call	step_text_char_loop_ega
						pop	si
						pop	di
						pop	bx
						mov	al,bl
						inc	di
						and	ax,1
						add	di,ax
						inc	bl
						pop	cx
						loop	icon_slot_loop		; Loop if cx > 0

		retn

render_via_proc_loop2_ega		endp

step_text_char_loop_ega		proc	near
		inc	al
		jnz	char_not_null			; Jump if not zero
		retn

char_not_null:
		dec	al
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,cs:font_ptr_a
		mov	si,ax
		mov	cx,7

char_row_render_loop:
						lodsw				; String [si] to ax
						xchg	ah,al
						test	bl,1
						jnz	char_no_shift			; Jump if not zero
						shl	ax,1			; Shift w/zeros fill
						shl	ax,1			; Shift w/zeros fill
						shl	ax,1			; Shift w/zeros fill
						shl	ax,1			; Shift w/zeros fill

char_no_shift:
						or	es:[di],ah
						or	es:[di+1],al
						add	di,28h
						loop	char_row_render_loop		; Loop if cx > 0

		retn

step_text_char_loop_ega		endp

step_text_char_loop2_ega		proc	near
		mov	di,3A31h
		call	div_24bit_emit_digit_ega
		mov	cx,6

marker_scan_loop:
						test	byte ptr cs:[di],0FFh
						jz	marker_slot_empty			; Jump if zero
						retn

marker_slot_empty:
						mov	byte ptr cs:[di],0FFh
						inc	di
						loop	marker_scan_loop		; Loop if cx > 0

		retn

step_text_char_loop2_ega		endp

		db	7 dup (0)

div_24bit_emit_digit_ega		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	div_16bit_emit_digit_ega
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	div_16bit_emit_digit_ega
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	div_16bit_emit_digit_ega
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	div_16bit_emit_digit_alt_ega
		mov	cs:[di+3],dh
		mov	bx,64h
		call	div_16bit_emit_digit_alt_ega
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	div_16bit_emit_digit_alt_ega
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn

div_24bit_emit_digit_ega		endp

div_16bit_emit_digit_ega		proc	near
		xor	dh,dh			; Zero register

div_subtract_loop:
						sub	dl,cl
						jc	div_done			; Jump if carry Set
						sub	ax,bx
						jnc	div_inc_digit			; Jump if carry=0
						or	dl,dl			; Zero ?
						jz	div_add_back			; Jump if zero
						dec	dl

div_inc_digit:
						inc	dh
						jmp	short div_subtract_loop

div_add_back:
		add	ax,bx

div_done:
		add	dl,cl
		retn

div_16bit_emit_digit_ega		endp

div_16bit_emit_digit_alt_ega		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn

div_16bit_emit_digit_alt_ega		endp

; scroll_region_up_entry: scroll a rectangular region of EGA up by one row
			                        ;* No entry point to code

scroll_region_up_entry:
		push	ds
		push	ax
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	si,di
		sub	si,50h
		mov	al,50h			; 'P'
		mul	cl			; ax = reg * al
		sub	ax,50h
		add	si,ax
		add	di,ax
		SET_ES_DS_VGA
		EGA_SETUP_702_105
						;  al = 5, mode
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

scroll_up_row_loop:
						push	cx
						push	di
						push	si
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	si
						pop	di
						sub	si,50h
						sub	di,50h
						pop	cx
						loop	scroll_up_row_loop		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,3BBCh
		mov	si,ax
		push	cs
		pop	ds
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn

; scroll_region_dn_entry: scroll a rectangular region of EGA down by one row
			                        ;* No entry point to code

scroll_region_dn_entry:
		push	ds
		push	ax
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	si,di
		add	si,50h
		SET_ES_DS_VGA
		EGA_SETUP_702_105
						;  al = 5, mode
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

scroll_dn_row_loop:
						push	cx
						push	di
						push	si
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	si
						pop	di
						add	si,50h
						add	di,50h
						pop	cx
						loop	scroll_dn_row_loop		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,3BBCh
		mov	si,ax
		push	cs
		pop	ds
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn

; fill_region_entry: fill EGA region with color 6 using ROP XOR mode
			                        ;* No entry point to code

fill_region_entry:
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,1803h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	di,ega_hud_top
		mov	cx,8

fill_col_loop:
						push	cx
						push	di
						mov	cx,12h

fill_row_loop:
										push	cx
										push	di
										mov	cx,38h

fill_byte_loop:
										mov	al,6
										xchg	es:[di],al
										inc	di
										loop	fill_byte_loop		; Loop if cx > 0

										pop	di
										add	di,280h
										pop	cx
										loop	fill_row_loop		; Loop if cx > 0

						pop	di
						add	di,50h
						pop	cx
						loop	fill_col_loop		; Loop if cx > 0

		mov	dx,3CEh
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		retn
		db	0C3h			; extra retn byte (duplicate, never executed)
		db	923 dup (0)		; zero-fill to end of segment (0xF50 total)

seg_a		ends

		end	start
