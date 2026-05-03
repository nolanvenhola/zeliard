
PAGE  59,132

;==========================================================================
;
;  GMEGA.BIN - EGA 16-Color Graphics Driver (Mode 0Eh, 640x200)
;
;  EGA variant of the graphics driver API. Uses EGA planar memory
;  at 0xA000 with Map Mask and Bit Mask registers for pixel access.
;
;  Connections:
;    Loads:        none (pure renderer; loaded chunks fight/select read tile
;                  src buffers from driver_base + offset tile_src_base)
;    Calls into:   music_fn_ptr (DS:0xDEA2 - music/timer in game seg),
;                  EGA plot dispatch tables (ega_plot_tbl_a..f at A523/BB23/...)
;    Called by:    zeliad.exe loader (when RESOURCE.CFG selects EGA mode);
;                  game.bin invokes via gfx_call_a/b/c at game_seg:0x201C/E/2020;
;                  fight.bin/town.bin call gfx_* dispatch entries
;    Reads/writes: gvar_game_seg (FF2C) [zeliad-owned], gvar_volume_b (FF77),
;                  anim_ptr_0..4 (E200/E202/E206/E20A/E20C, fight-owned),
;                  font_ptr_a/b/c (F500/F502/F504, font.grp-owned)
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  stdply.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
gvar_game_seg	equ	0FF2Ch			;*
gvar_volume_b	equ	0FF77h			;*

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
tile_src_base	equ	27BBh			;* tilemap source base (default SI)
anim_ptr_0	equ	0E200h			;*
anim_ptr_1	equ	0E202h			;*
anim_ptr_2	equ	0E206h			;*
anim_ptr_3	equ	0E20Ah			;*
anim_ptr_4	equ	0E20Ch			;*
tile_src_base_b	equ	21C0h			;* hud mask tile source B
text_vga_ofs_a	equ	256Ah			;* VGA offset for text function A
text_vga_ofs_b	equ	256Bh			;* VGA offset for text function B
text_vga_ofs_c	equ	256Dh			;* VGA offset for text function C
sprite_anim_tbl	equ	2D27h			;* sprite animation frame pointer table
tile_fg_mask	equ	2E93h			;* tile foreground color/map mask byte
tile_bg_mask	equ	2E94h			;* tile background color/map mask byte
char_col_ptr	equ	2E95h			;* text cursor column word (BX)
char_row_ptr	equ	2E97h			;* text cursor row byte (CL), +8 per newline
dispatch_tbl	equ	4526h			;*
ega_seg		equ	0A000h			;* EGA framebuffer segment
ega_plot_tbl_a	equ	0A523h			;*
ega_plot_tbl_b	equ	0BB23h			;*
ega_plot_tbl_c	equ	0C821h			;*
ega_plot_tbl_d	equ	0D92Bh			;*
music_fn_ptr	equ	0DEA2h			;* music/timer function pointer (game seg)
ega_plot_tbl_e	equ	0E52Ah			;*
font_ptr_a	equ	0F500h			;*
font_ptr_b	equ	0F502h			;*
font_ptr_c	equ	0F504h			;*
ega_plot_tbl_f	equ	0F828h			;*
ega_col_stride	equ	0FE71h			;* EGA text column stride (-399; net +1 after 5-row char)
ega_pixel_ofs	equ	316Ch			;* initial EGA byte offset for pixel plot
ega_hud_ofs	equ	46Ch			;* HUD area starting offset in EGA framebuffer
driver_base	equ	2000h			; driver loads at game_seg:2000h

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
plot_mode	equ	22DEh			;* plot mode flag byte

; Set ES to the EGA framebuffer segment (0xA000)
SET_EGA_ES	MACRO
		mov	ax, ega_seg
		mov	es, ax
		ENDM

; EGA sprite blit prologue: ES->A000, seq mask=0F (all planes write enabled),
; graphics controller mode = 5 (write mode 1, fast block copy). Identical
; 7-instruction sequence appears 6 times in render_text_char_alt and
; tile/sprite/font drawing fns.
EGA_BLIT_PRO	MACRO
		mov	ax, ega_seg
		mov	es, ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		ENDM

; EGA blit epilogue: graphics controller mode register reset to 5 (write
; mode 1) and bitmask register reset to 0xFF (all bits writable). Same
; 4-instruction sequence appears 5 times at fn return points.
EGA_BLIT_END	MACRO
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		ENDM

; Select EGA sequencer map mask register (3C4h index 2), leaving DX = 3C5h
; ready for the data write. Repeats 6 times in plot_pixel sub-paths.
EGA_SEL_MASK	MACRO
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

gmega		proc	far

start:
; Function dispatch table (35 word entries) followed by dispatch mechanism code.
; Entries are CS-relative addresses (driver loads at game_seg:2000h).
; First 70 bytes = 35 dw pointers; remaining = dispatch mechanism code.
		dw	2046h			; fn  0
		dw	211Eh			; fn  1
		dw	21C8h			; fn  2
		dw	22DFh			; fn  3
		dw	231Ch			; fn  4
		dw	22E9h			; fn  5
		dw	2326h			; fn  6
		dw	23A5h			; fn  7
		dw	23B3h			; fn  8
		dw	24BBh			; fn  9
		dw	24C5h			; fn 10
		dw	24E2h			; fn 11
		dw	2502h			; fn 12
		dw	252Bh			; fn 13
		dw	26BEh			; fn 14
		dw	2745h			; fn 15
		dw	275Fh			; fn 16
		dw	2958h			; fn 17
		dw	29E9h			; fn 18
		dw	2A33h			; fn 19
		dw	2A8Bh			; fn 20
		dw	2AE5h			; fn 21
		dw	2B3Ah			; fn 22
		dw	2B8Eh			; fn 23
		dw	25D9h			; fn 24
		dw	2570h			; fn 25
		dw	2779h			; fn 26
		dw	279Ah			; fn 27
		dw	23C1h			; fn 28
		dw	287Bh			; fn 29
		dw	2893h			; fn 30
		dw	2BF8h			; fn 31
		dw	214Eh			; fn 32
		dw	2E63h			; fn 33
		dw	2E92h			; fn 34
; Dispatch mechanism: AL=fn#, BL=col, BH=row. Computes DI=col*80+row.
; fn 0 (AL=0) jumps directly to clear_screen (init only path).
; fn 1+ PUSHes DI then falls through to border-draw setup at border_draw_setup.

dispatch_call:
		push	ax
		mov	ax, 50h
		mul	bl
		mov	bl, bh
		db	32h, 0FFh		; xor bh, bh  (alt encoding: 32h r,r/m vs 30h r/m,r)
		add	ax, bx
		mov	di, ax
		pop	ax
		db	0Ah, 0C0h		; or al, al  (alt encoding: 0Ah r,r/m vs 08h r/m,r)
		jnz	dispatch_call_do
		jmp	near ptr clear_screen	; fn 0: init mode only, jump to clear_screen

dispatch_call_do:
		push	di

border_draw_setup:
		sub	cl,4
		add	di,0A0h
		call	clear_screen
		pop	di
		mov	ax,0F00Fh
		call	fill_horizontal_line
		mov	ax,0FC3Fh
		call	fill_horizontal_line
		push	cx
		push	bx
		mov	bl,ch
		dec	bl
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

locloop_2:
									mov	byte ptr es:[di],0F0h
									mov	byte ptr es:[bx+di],0Fh
									add	di,50h
									loop	locloop_2		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0FC3Fh
		call	fill_horizontal_line
		mov	ax,0F00Fh

gmega		endp

fill_horizontal_line		proc	near
		push	ax
		mov	dx,3CEh
		mov	ax,803h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		pop	ax
		push	ax
		push	di
		not	ax
		xchg	es:[di],al
		inc	di
		mov	bh,ch
		sub	bh,2

hline_clear_left_loop:
									xor	al,al			; Zero register
									xchg	es:[di],al
									inc	di
									dec	bh
									jnz	hline_clear_left_loop			; Jump if not zero
		xchg	es:[di],ah
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		test	byte ptr cs:gvar_volume_b,0FFh
		jz	hline_after_volume_check			; Jump if zero
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register

hline_after_volume_check:
		mov	dx,3CEh
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		pop	di
		pop	ax
		xchg	es:[di],al
		inc	di
		mov	bh,ch
		sub	bh,2

hline_fill_right_loop:
									mov	al,0FFh
									xchg	es:[di],al
									inc	di
									dec	bh
									jnz	hline_fill_right_loop			; Jump if not zero
		mov	al,ah
		xchg	es:[di],al
		inc	di
		add	di,bx
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		retn

fill_horizontal_line		endp

clear_screen		proc	near
		SET_EGA_ES
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	bl,50h			; 'P'
		sub	bl,ch
		xor	bh,bh			; Zero register
		mov	ah,cl

clear_row_loop:
									push	cx
									mov	cl,ch
									xor	ch,ch			; Zero register
									xor	al,al			; Zero register
									rep	stosb			; Rep when cx >0 Store al to es:[di]
									pop	cx
									add	di,bx
									dec	ah
									jnz	clear_row_loop			; Jump if not zero
		retn

clear_screen		endp

ega_vram_init:
		SET_EGA_ES
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	di,ega_hud_ofs
		mov	cx,8

locloop_7:
									push	cx
									push	di
									mov	cx,12h

locloop_8:
																push	cx
																push	di
																mov	cx,38h
																xor	al,al			; Zero register
																rep	stosb			; Rep when cx >0 Store al to es:[di]
																pop	di
																add	di,280h
																pop	cx
																loop	locloop_8		; Loop if cx > 0

									pop	di
									add	di,50h
									pop	cx
									loop	locloop_7		; Loop if cx > 0

		retn

ega_write_mode2_init:
		SET_EGA_ES
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	si,tile_src_base_b
		mov	cx,8

fn_1:

locloop_9:
									push	cx
									mov	di,ega_hud_ofs
									lodsb				; String [si] to al
									mov	ah,al
									push	di
									mov	cx,48h

locloop_10:
																push	cx
																mov	al,8
																out	dx,ax			; port 3CEh, EGA graphic index
																				;  al = 8, data bit mask
																mov	cx,38h

locloop_11:
																xor	al,al			; Zero register
																xchg	es:[di],al
																inc	di
																loop	locloop_11		; Loop if cx > 0

																rol	ah,1			; Rotate
																rol	ah,1			; Rotate
																rol	ah,1			; Rotate
																pop	cx
																add	di,68h
																loop	locloop_10		; Loop if cx > 0

									pop	di
									add	di,50h
									mov	cx,48h

locloop_12:
																push	cx

fn_32:
																mov	al,8
																out	dx,ax			; port 3CEh, EGA graphic index
																				;  al = 8, data bit mask
																mov	cx,38h

locloop_13:
																xor	al,al			; Zero register
																xchg	es:[di],al
																inc	di
																loop	locloop_13		; Loop if cx > 0

																rol	al,1			; Rotate
																rol	al,1			; Rotate
																rol	al,1			; Rotate
																pop	cx
																add	di,68h
																loop	locloop_12		; Loop if cx > 0

									mov	cx,3E80h

locloop_14:
																loop	locloop_14		; Loop if cx > 0

									pop	cx
									loop	locloop_9		; Loop if cx > 0

		EGA_BLIT_END
		retn

music_update_trampoline:
		add	[bx+di],dx
		adc	ax,5755h
		ja	plot_default_path			; Jump if above
		jmp	dword ptr ds:music_fn_ptr

calc_ega_pixel_pos:
		and	bh,ds:ega_seg[bx+si]
		mov	es,ax
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	di,ax
		mov	dl,bh
		and	bh,3
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		xor	dh,dh			; Zero register
		add	di,dx
		add	di,ega_pixel_ofs
		mov	cl,bh
		add	cl,cl
		mov	ax,0FF3Fh
		shr	ah,cl			; Shift w/zeros fill
		shr	al,cl			; Shift w/zeros fill
		neg	bh
		add	bh,3
		sub	ch,bh
		push	cx
		call	plot_pixel
		pop	cx
		inc	di
		mov	cl,ch
		shr	cl,1			; Shift w/zeros fill
		shr	cl,1			; Shift w/zeros fill
		test	cl,0FFh
		jz	pixel_line_check_tail			; Jump if zero

pixel_line_mid_loop:
									push	cx
									mov	ax,0FFFFh
									call	plot_pixel
									pop	cx
									inc	di
									dec	cl
									jnz	pixel_line_mid_loop			; Jump if not zero

pixel_line_check_tail:
		and	ch,3
		jnz	pixel_line_tail_pixels			; Jump if not zero
		retn

pixel_line_tail_pixels:
		mov	cl,ch
		shl	cl,1			; Shift w/zeros fill
		mov	ah,0FFh
		shr	ah,cl			; Shift w/zeros fill
		not	ah
		mov	al,ah
		call	plot_pixel
		mov	dx,3CEh
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

plot_pixel		proc	near
		mov	cx,ax
		test	byte ptr cs:plot_mode,0FFh
		jnz	plot_modal_path			; Jump if not zero
		mov	dx,3CEh
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask

plot_default_path:
		EGA_SEL_MASK
		push	di
		mov	al,7
		out	dx,al			; port 3C5h, EGA sequencr func
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,50h
		mov	ch,8

plot_default_row_loop:
									mov	al,7
									out	dx,al			; port 3C5h, EGA sequencr func
									xor	al,al			; Zero register
									xchg	es:[di],al
									mov	al,5
									out	dx,al			; port 3C5h, EGA sequencr func
									mov	al,cl
									and	al,0AAh
									xchg	es:[di],al
									add	di,50h
									dec	ch
									jnz	plot_default_row_loop			; Jump if not zero
		mov	al,7
		out	dx,al			; port 3C5h, EGA sequencr func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,5
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	al,cl
		xchg	es:[di],al
		pop	di
		retn

plot_modal_path:
		cmp	byte ptr cs:plot_mode,80h
		je	plot_clear_path			; Jump if equal
		mov	dx,3CEh
		mov	ah,cl
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		EGA_SEL_MASK
		push	di
		mov	ch,0Ah

plot_and_mode_row_loop:
									mov	al,7
									out	dx,al			; port 3C5h, EGA sequencr func
									xor	al,al			; Zero register
									xchg	es:[di],al
									mov	al,1
									out	dx,al			; port 3C5h, EGA sequencr func
									mov	al,cl
									and	al,0AAh
									xchg	es:[di],al
									add	di,50h
									dec	ch
									jnz	plot_and_mode_row_loop			; Jump if not zero
		pop	di
		retn

plot_clear_path:
		mov	dx,3CEh
		mov	ah,cl
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		EGA_SEL_MASK
		mov	al,7
		out	dx,al			; port 3C5h, EGA sequencr func
		push	di
		mov	ch,0Ah

plot_clear_row_loop:
									xor	al,al			; Zero register
									xchg	es:[di],al
									add	di,50h
									dec	ch
									jnz	plot_clear_row_loop			; Jump if not zero
		pop	di
		retn

plot_pixel		endp

; plot_mode opcode byte lives here (CS:22DEh); set_plot_mode patches it to
; change the pixel operation applied to the EGA text field.

plot_mode_fn:
		add	byte ptr [bx+3305h],bh		; opcode patched by set_plot_mode
		mov	bx,cs:[0B2h]
		jmp	short draw_text_field_common

draw_text_field_alt:
		mov	di,36C5h			; alt EGA text field offset
		jmp	short draw_text_field_common

draw_text_field_common:
		SET_EGA_ES
		mov	dx,3C4h
		mov	ax,0202h
		out	dx,ax				; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		call	calc_text_width
		push	ax

dtfc_column_fill_loop:
									or	bl,bl			; Zero ?
									jz	dtfc_after_columns			; Jump if zero
									mov	bh,6
									mov	al,0FFh
									call	fill_vertical_line
									dec	bl
									add	di,0FE21h
									jmp	short dtfc_column_fill_loop

dtfc_after_columns:
		pop	ax
		or	al,al			; Zero ?
		jnz	dtfc_trailing_column			; Jump if not zero
		retn

dtfc_trailing_column:
		mov	bh,6
		jmp	fvl_loop

draw_text_field_ega:
		mov	di,3305h
		mov	bx,word ptr cs:[90h]
		jmp	short dtf_ega_body
		mov	di,36C5h			; alt EGA text field offset (entry B)
		jmp	short dtf_ega_body

dtf_ega_body:
		SET_EGA_ES
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		call	calc_text_width
		push	ax
		push	bx

dtf_ega_column_loop:
									or	bl,bl			; Zero ?
									jz	dtf_ega_after_columns			; Jump if zero
									mov	bh,5
									mov	al,0FFh
									call	fill_vertical_line
									dec	bl
									add	di,ega_col_stride
									jmp	short dtf_ega_column_loop

fn_4:

dtf_ega_after_columns:
		pop	bx
		pop	ax

fn_6:
		or	al,al			; Zero ?
		jz	dtf_ega_check_trailing			; Jump if zero
		mov	bh,5
		call	fill_vertical_line
		add	di,ega_col_stride
		inc	bl

dtf_ega_check_trailing:
		mov	bh,19h
		sub	bh,bl
		jnz	dtf_ega_back_fill_setup			; Jump if not zero
		retn

dtf_ega_back_fill_setup:
		mov	bl,bh

dtf_ega_back_fill_loop:
									mov	bh,5
									xor	al,al			; Zero register
									call	fill_vertical_line
									add	di,0FE71h
									dec	bl
									jnz	dtf_ega_back_fill_loop			; Jump if not zero
		retn

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	ctw_overflow			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	cl,bl
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		and	cl,7
		mov	al,0FFh
		shr	al,cl			; Shift w/zeros fill
		not	al
		retn

ctw_overflow:
		mov	bx,19h
		xor	al,al			; Zero register
		retn

calc_text_width		endp

fill_vertical_line		proc	near

fvl_loop:
									stosb				; Store al to es:[di]
									add	di,4Fh
									dec	bh
									jnz	fvl_loop			; Jump if not zero
		retn

fill_vertical_line		endp

set_tile_color_a:
		mov	byte ptr cs:tile_fg_mask,3
		mov	byte ptr cs:tile_bg_mask,2
		jmp	short set_tile_color_blit_setup

set_tile_color_b:
		mov	byte ptr cs:tile_fg_mask,1
		mov	byte ptr cs:tile_bg_mask,5
		jmp	short set_tile_color_blit_setup

set_tile_color_c:
		mov	byte ptr cs:tile_fg_mask,1
		mov	byte ptr cs:tile_bg_mask,0
		xor	dh,dh			; Zero register
		mov	dl,bh
		mov	di,dx
		mov	al,bl
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	di,ax
		mov	bl,cl
		EGA_BLIT_PRO

fn_7:

dtsc_next_char:
									lodsb				; String [si] to al
									or	al,al			; Zero ?
									jz	dtsc_done			; Jump if zero
									push	bx
									push	ds
									push	si

fn_8:
									and	bl,3
									call	render_text_char
									pop	si
									pop	ds

fn_28:
									pop	bx
									inc	bl
									jmp	short dtsc_next_char

dtsc_done:
		EGA_BLIT_END
		retn

set_tile_color_blit_setup:
		lodsb				; String [si] to al
		xor	dh,dh			; Zero register
		mov	dl,al
		mov	di,dx
		lodsb				; String [si] to al
		mov	cl,50h			; 'P'
		mul	cl			; ax = reg * al
		add	di,ax
		lodsb				; String [si] to al
		mov	bl,al
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		EGA_BLIT_PRO

locloop_39:
									push	cx
									lodsb				; String [si] to al
									push	bx
									push	ds
									push	si
									and	bl,3
									call	render_text_char
									pop	si
									pop	ds
									pop	bx
									inc	bl
									pop	cx
									loop	locloop_39		; Loop if cx > 0

		EGA_BLIT_END
		retn

render_text_char		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:font_ptr_c
		add	bl,bl
		mov	cl,bl
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		push	di
		mov	bl,8

rtc_row_loop:
									push	bx
									lodsb				; String [si] to al
									xor	bl,bl			; Zero register
									mov	bh,al
									shr	bx,cl			; Shift w/zeros fill
									push	bx
									shr	bx,1			; Shift w/zeros fill
									shr	bx,1			; Shift w/zeros fill
									mov	al,bh
									out	dx,al			; port 3CFh, EGA graphic func
									mov	al,cs:tile_bg_mask
									xchg	es:[di],al
									mov	al,bl
									out	dx,al			; port 3CFh, EGA graphic func
									mov	al,cs:tile_bg_mask
									xchg	es:[di+1],al
									pop	bx
									mov	al,bh
									out	dx,al			; port 3CFh, EGA graphic func
									mov	al,cs:tile_fg_mask
									xchg	es:[di],al
									mov	al,bl
									out	dx,al			; port 3CFh, EGA graphic func
									mov	al,cs:tile_fg_mask
									xchg	es:[di+1],al
									add	di,50h
									pop	bx
									dec	bl
									jnz	rtc_row_loop			; Jump if not zero
		dec	dx
		pop	di
		inc	di
		cmp	cl,6
		je	rtc_inc_di_for_six			; Jump if equal
		retn

rtc_inc_di_for_six:
		inc	di
		retn

render_text_char		endp

sprite_anim_init:
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,88h
;*		jmp	loc_15			;*
		db	0E9h, 03h,0FDh		;  jmp near ptr 0x01CAh  (E9h rel16; disp=0xFD03=-763)

render_tilemap_row_b:
		push	ds
		mov	ax,word ptr cs:[8Bh]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,text_vga_ofs_b
		mov	cx,105h
		mov	ax,26BBh
		mov	bx,0FF01h
		call	render_tilemap_large
		pop	ds
		retn

render_tilemap_row_a:
		push	ds
		mov	ax,word ptr cs:[86h]
		mov	dl,byte ptr cs:[85h]
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,text_vga_ofs_a
		mov	cx,106h
		mov	ax,13BBh
		mov	bx,0FF01h

fn_9:
		call	render_tilemap_large
		pop	ds
		retn

render_animated_tile:
		push	ds
		xor	bx,bx			; Zero register
		mov	bl,byte ptr cs:[9Dh]
		dec	bl

fn_10:
		mov	al,byte ptr cs:[0ABh][bx]
		xor	ah,ah			; Zero register
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,text_vga_ofs_c
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,0FF01h
		call	render_tilemap_large
		pop	ds
		retn

fn_11:

render_if_enabled:
		test	byte ptr cs:[93h],0FFh
		jnz	rie_render			; Jump if not zero
		retn

rie_render:
		push	ds
		mov	ax,word ptr cs:[94h]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,text_vga_ofs_c
		mov	cx,103h

fn_12:
		mov	ax,3EBBh
		mov	bx,0FF01h
		call	render_tilemap_large
		pop	ds
		retn

init_timestamp		proc	near
		mov	di,2569h
		call	time_to_bcd
		mov	cx,6

locloop_43:
									test	byte ptr cs:[di],0FFh
									jz	it_clear_byte			; Jump if zero
									retn

it_clear_byte:
									mov	byte ptr cs:[di],0FFh

fn_13:
									inc	di
									loop	locloop_43		; Loop if cx > 0

		retn

init_timestamp		endp

		db	7 dup (0)

time_to_bcd		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	modulo_divide_bcd
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	modulo_divide_bcd
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	modulo_divide_bcd
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	int_divide_bcd
		mov	cs:[di+3],dh
		mov	bx,64h
		call	int_divide_bcd
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	int_divide_bcd
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn

time_to_bcd		endp

modulo_divide_bcd		proc	near
		xor	dh,dh			; Zero register

mdb_iter_loop:
									sub	dl,cl
									jc	mdb_done			; Jump if carry Set
									sub	ax,bx
									jnc	mdb_inc_dh			; Jump if carry=0
									or	dl,dl			; Zero ?
									jz	mdb_zero_underflow			; Jump if zero
									dec	dl

mdb_inc_dh:
									inc	dh
									jmp	short mdb_iter_loop

mdb_zero_underflow:
		add	ax,bx

mdb_done:
		add	dl,cl
		retn

modulo_divide_bcd		endp

int_divide_bcd		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn

int_divide_bcd		endp

render_tilemap_large		proc	near
		mov	cs:tile_fg_mask,bl
		mov	cs:tile_bg_mask,bh
		mov	bl,ah
		mov	ah,50h			; 'P'
		mul	ah			; ax = reg * al
		xor	bh,bh			; Zero register
		add	bx,ax
		EGA_BLIT_PRO

rtl_outer_loop:
									mov	al,[di]
									inc	di
									push	bx
									push	cx
									push	di
									push	ds
									mov	di,bx
									call	decode_bitplane_tile
									pop	ds
									pop	di
									pop	cx
									pop	bx
									mov	al,ch
									and	ax,1
									add	bx,ax
									inc	bx
									inc	ch
									dec	cl
									jnz	rtl_outer_loop			; Jump if not zero
		EGA_BLIT_END
		retn

render_tilemap_large		endp

decode_bitplane_tile		proc	near
		mov	bx,0FFF0h
		test	ch,1
		jz	test_tile_bg_mask			; Jump if zero
		mov	bx,0FFFh

test_tile_bg_mask:
		test	byte ptr ds:tile_bg_mask,0FFh
		jz	dbt_check_terminator			; Jump if zero
		push	di
		push	cx
		push	ax
		mov	al,8
		mov	cx,7

locloop_51:
									mov	ah,bh
									out	dx,ax			; port 3CEh, EGA graphic index
													;  al = 8, data bit mask
									xor	ah,ah			; Zero register
									xchg	es:[di],ah
									mov	ah,bl
									out	dx,ax			; port 3CEh, EGA graphic index
													;  al = 8, data bit mask
									xor	ah,ah			; Zero register
									xchg	es:[di+1],ah
									mov	ah,bh
									and	ah,0AAh
									out	dx,ax			; port 3CEh, EGA graphic index
													;  al = 8, data bit mask
									mov	ah,5
									xchg	es:[di],ah
									mov	ah,bl
									and	ah,0AAh
									out	dx,ax			; port 3CEh, EGA graphic index
													;  al = 8, data bit mask
									mov	ah,5
									xchg	es:[di+1],ah
									add	di,50h
									loop	locloop_51		; Loop if cx > 0

		pop	ax
		pop	cx
		pop	di

dbt_check_terminator:
		inc	al
		jnz	dbt_render_glyph			; Jump if not zero
		retn

dbt_render_glyph:
		dec	al
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,cs:font_ptr_b
		mov	si,ax
		push	cs
		pop	ds
		mov	cl,7

dbt_glyph_row_loop:
									lodsw				; String [si] to ax
									xchg	ah,al
									test	ch,1
									jnz	dbt_apply_mask			; Jump if not zero
									shl	ax,1			; Shift w/zeros fill
									shl	ax,1			; Shift w/zeros fill
									shl	ax,1			; Shift w/zeros fill
									shl	ax,1			; Shift w/zeros fill

dbt_apply_mask:
									mov	bl,al
									mov	al,8
									out	dx,ax			; port 3CEh, EGA graphic index
													;  al = 8, data bit mask
									mov	ah,cs:tile_fg_mask
									xchg	es:[di],ah
									mov	ah,bl
									out	dx,ax			; port 3CEh, EGA graphic index
													;  al = 8, data bit mask
									mov	ah,cs:tile_fg_mask
									xchg	es:[di+1],ah
									add	di,50h
									dec	cl
									jnz	dbt_glyph_row_loop			; Jump if not zero
		retn

decode_bitplane_tile		endp

render_sprite_anim0:
		push	ds
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,10Eh
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_0
		mov	si,ax
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bp,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bp,bx
		SET_EGA_ES
		EGA_SEL_MASK
		mov	cx,12h

locloop_56:
									mov	al,1
									out	dx,al			; port 3C5h, EGA sequencr func
									lodsw				; String [si] to ax
									mov	es:[bp],al
									mov	es:[bp+1],ah
									lodsw				; String [si] to ax
									mov	es:[bp+2],al
									mov	es:[bp+3],ah
									lodsb				; String [si] to al
									mov	es:[bp+4],al
									mov	al,2
									out	dx,al			; port 3C5h, EGA sequencr func
									lodsw				; String [si] to ax
									mov	es:[bp+4],al
									mov	es:[bp+3],ah
									lodsw				; String [si] to ax
									mov	es:[bp+2],al
									mov	es:[bp+1],ah
									lodsb				; String [si] to al
									mov	es:[bp],al
									mov	al,4
									out	dx,al			; port 3C5h, EGA sequencr func
									lodsw				; String [si] to ax
									mov	es:[bp],al
									mov	es:[bp+1],ah
									lodsw				; String [si] to ax
									mov	es:[bp+2],al
									mov	es:[bp+3],ah
									lodsb				; String [si] to al
									mov	es:[bp+4],al
									add	bp,50h
									loop	locloop_56		; Loop if cx > 0

		pop	ds
		retn

render_small_tile_anim2:
		push	ds
		mov	ds,cs:gvar_game_seg

fn_14:
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_2
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn

render_small_tile_anim1:
		push	ds
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_1
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn

render_small_tile_anim4:
		push	ds
		mov	si,tile_src_base
		or	al,al			; Zero ?
		jz	call_render_tilemap_small			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_4
		mov	si,ax

call_render_tilemap_small:
		call	render_tilemap_small
		pop	ds
		retn

render_small_tile_anim3:
		push	ds
		mov	si,tile_src_base
		or	al,al			; Zero ?
		jz	call_render_tilemap_small_58			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_3
		mov	si,ax

call_render_tilemap_small_58:
		call	render_tilemap_small
		pop	ds
		retn
; Referenced as tile_src_base by render_tilemap_large.
; Each tile entry: 2 rows x 6 bytes = [plane0_lo, plane0_hi, plane1_lo, plane1_hi, plane2_lo, plane2_hi]
; 'TUUUUUUT' = EGA bit-mask table boundary marker (8 bytes separating bitplane sets)

tile_src_base_lbl:
		db	0, 0, 0, 0			; (4-byte null entry)

fn_15:
		db	'TUUUUUUT'			; EGA plane boundary marker
		db	 00h, 00h, 00h, 00h, 02h, 00h	; row  0 even
		db	 00h, 80h, 80h, 00h, 00h, 02h	; row  0 odd
		db	 06h, 30h, 18h, 00h, 02h, 00h	; row  1 even
		db	 00h, 80h, 9Eh,0F3h,0F8h, 02h	; row  1 odd
		db	 03h, 31h, 8Ch, 00h, 02h, 00h	; row  2 even
		db	 00h, 80h, 9Fh,0F7h,0BCh, 02h	; row  2 odd
		db	 05h, 31h, 8Ch, 00h, 02h, 00h	; row  3 even
		db	 00h, 80h, 9Fh,0F7h,0BCh, 02h	; row  3 odd
		db	 06h, 31h, 8Ch, 00h, 02h, 00h	; row  4 even
		db	 00h, 80h, 9Fh,0F7h,0BCh, 02h	; row  4 odd
		db	 06h, 30h, 18h, 00h, 02h, 00h	; row  5 even

fn_16:
		db	 00h, 80h, 9Eh,0F3h,0F8h, 02h	; row  5 odd
		db	 00h, 00h, 00h, 00h, 02h, 00h	; row  6 even
		db	 00h, 80h, 80h, 00h, 00h, 02h	; row  6 odd
		db	 00h, 00h, 00h, 00h, 02h, 00h	; row  7 even
		db	 00h, 80h, 80h, 00h, 00h, 02h	; row  7 odd
		db	 03h, 18h, 0Ch, 0Ch, 02h, 00h	; row  8 even
		db	 00h, 80h, 8Fh, 7Bh,0FFh,0FEh	; row  8 odd
		db	 03h, 19h, 80h,0C0h, 02h, 00h	; row  9 even
		db	 00h, 80h, 8Fh, 7Fh, 83h,0C2h	; row  9 odd
		db	 03h, 18h, 18h, 18h, 02h, 00h	; row 10 even
		db	 00h, 80h, 8Fh, 7Bh,0FBh,0FAh	; row 10 odd
		db	 03h, 18h, 0Ch,0C0h, 02h, 00h	; row 11 even

fn_26:
		db	 00h, 80h, 8Fh, 78h, 3Fh,0C2h	; row 11 odd
		db	 00h, 30h, 18h, 0Ch, 02h, 00h	; row 12 even
		db	 00h, 80h, 87h,0F7h,0FBh,0FEh	; row 12 odd
		db	 00h, 00h, 00h, 00h, 02h, 00h	; row 13 even
		db	 00h, 80h, 80h, 00h, 00h, 02h	; row 13 odd
		db	 00h, 00h, 00h, 00h			; (4-byte null entry)
		db	'TUUUUUUT'			; EGA plane boundary marker
; Sprite source selector A: SI = row*192 + game_seg:[0E208h], calls render_tilemap_small
		push	ds
		mov	ds,word ptr cs:[gvar_game_seg]
		db	32h, 0E4h			; xor ah,ah  (alt encoding)
		mov	cx,0C0h
		mul	cx				; ax = row * 0xC0
		add	ax,word ptr ds:[0E208h]
		mov	si,ax
		call	render_tilemap_small

fn_27:
		pop	ds
		retn
; Sprite source selector B: SI = row*192 + game_seg:[0E204h], calls render_tilemap_small
		push	ds
		mov	ds,word ptr cs:[gvar_game_seg]
		db	32h, 0E4h			; xor ah,ah  (alt encoding)
		mov	cx,0C0h
		mul	cx				; ax = row * 0xC0
		add	ax,word ptr ds:[0E204h]
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn

render_tilemap_small		proc	near
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bp,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bp,bx
		SET_EGA_ES
		EGA_SEL_MASK
		mov	cx,10h

rts_outer_loop:
		push	cx
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	di,ax
		lodsw				; String [si] to ax
		xchg	al,ah
		xor	bl,bl			; Zero register
		mov	cx,4

locloop_60:
									shr	di,1			; Shift w/zeros fill
									rcr	ax,1			; Rotate thru carry
									rcr	bl,1			; Rotate thru carry
									loop	locloop_60		; Loop if cx > 0

		xchg	di,ax
		mov	es:[bp],ah

fn_29:
		mov	es:[bp+1],al
		xchg	di,ax
		mov	es:[bp+2],ah
		mov	es:[bp+3],al

fn_30:
		mov	es:[bp+4],bl
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	di,ax
		lodsw				; String [si] to ax
		xor	bl,bl			; Zero register
		mov	cx,4

locloop_61:
									shr	ax,1			; Shift w/zeros fill
									rcr	di,1			; Rotate thru carry
									rcr	bl,1			; Rotate thru carry
									loop	locloop_61		; Loop if cx > 0

		mov	es:[bp],ah
		mov	es:[bp+1],al
		xchg	di,ax
		mov	es:[bp+2],ah
		mov	es:[bp+3],al
		mov	es:[bp+4],bl
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	di,ax
		lodsw				; String [si] to ax
		xchg	al,ah
		xor	bl,bl			; Zero register
		mov	cx,4

locloop_62:
									shr	di,1			; Shift w/zeros fill
									rcr	ax,1			; Rotate thru carry
									rcr	bl,1			; Rotate thru carry
									loop	locloop_62		; Loop if cx > 0

		xchg	di,ax
		mov	es:[bp],ah
		mov	es:[bp+1],al
		xchg	di,ax
		mov	es:[bp+2],ah
		mov	es:[bp+3],al
		mov	es:[bp+4],bl
		add	bp,50h
		pop	cx
		loop	locloop_63		; Loop if cx > 0

		jmp	short loc_ret_64

locloop_63:
		jmp	rts_outer_loop

loc_ret_64:
		retn

render_tilemap_small		endp

render_text_char_alt		proc	near
		push	ds
		push	cs
		pop	ds
		mov	ds:tile_fg_mask,ah
		xor	ah,ah			; Zero register
		sub	al,20h			; ' '
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:font_ptr_a
		push	ax
		mov	al,bl
		and	al,3
		add	al,al
		mov	ds:tile_bg_mask,al
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	al,50h			; 'P'
		mul	cl			; ax = reg * al
		add	ax,bx
		mov	di,ax
		pop	si
		EGA_BLIT_PRO
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	bp,4Eh
		mov	cx,8

locloop_65:
									push	cx
									lodsw				; String [si] to ax
									mov	bh,al
									xor	bl,bl			; Zero register
									mov	cl,cs:tile_bg_mask
									shr	bx,cl			; Shift w/zeros fill
									xor	al,al			; Zero register
									shr	ax,cl			; Shift w/zeros fill
									or	bl,ah
									mov	ah,al
									mov	al,bh
									out	dx,al			; port 3CFh, EGA graphic func
									mov	al,cs:tile_fg_mask
									xchg	es:[di],al
									inc	di
									mov	al,bl
									out	dx,al			; port 3CFh, EGA graphic func
									mov	al,cs:tile_fg_mask
									xchg	es:[di],al
									inc	di
									mov	al,ah
									out	dx,al			; port 3CFh, EGA graphic func
									mov	al,cs:tile_fg_mask
									xchg	es:[di],al
									add	di,4Eh
									pop	cx
									loop	locloop_65		; Loop if cx > 0

		dec	dx
		EGA_BLIT_END
		pop	ds
		retn

render_text_char_alt		endp

ega_copy_region:
		push	ds
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		mov	di,ax
		mov	si,di
		add	si,50h
		SET_EGA_ES
		mov	ds,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_66:
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
									loop	locloop_66		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn

ega_read_region:
		push	ds
		add	di,0
		mov	bl,ah
		mov	bh,50h			; 'P'
		mul	bh			; ax = reg * al
		mov	si,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	si,bx
		mov	ax,cs
		add	ax,3000h
		mov	es,ax

fn_18:
		mov	ax,0A000h
		mov	ds,ax
		mov	dx,3CEh
		mov	al,4
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		inc	dx
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

locloop_67:
									push	cx
									push	si
									mov	al,0
									out	dx,al			; port 3CFh, EGA graphic func
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									push	si
									mov	al,1
									out	dx,al			; port 3CFh, EGA graphic func
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									push	si
									mov	al,2
									out	dx,al			; port 3CFh, EGA graphic func
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									push	si
									mov	al,3
									out	dx,al			; port 3CFh, EGA graphic func
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									add	si,50h
									pop	cx
									loop	locloop_67		; Loop if cx > 0

		pop	ds
		retn

ega_copy_to_level:
		push	ds
		mov	si,di
		add	si,0

fn_19:
		mov	bl,ah
		mov	bh,50h			; 'P'
		mul	bh			; ax = reg * al
		mov	di,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	di,bx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		SET_EGA_ES
		EGA_SEL_MASK
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

locloop_68:
									push	cx
									push	di
									mov	al,1
									out	dx,al			; port 3C5h, EGA sequencr func
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	di
									push	di
									mov	al,2
									out	dx,al			; port 3C5h, EGA sequencr func
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	di
									push	di
									mov	al,4
									out	dx,al			; port 3C5h, EGA sequencr func
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	di
									push	di
									mov	al,8
									out	dx,al			; port 3C5h, EGA sequencr func
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	di
									add	di,50h
									pop	cx
									loop	locloop_68		; Loop if cx > 0

		pop	ds
		retn

render_char_string:
		mov	cs:char_col_ptr,bx
		mov	cs:char_row_ptr,cl

fn_20:
		mov	al,1
		test	byte ptr cs:gvar_volume_b,0FFh
		jz	rcs_set_fg_mask			; Jump if zero
		mov	al,7

rcs_set_fg_mask:
		mov	cs:tile_fg_mask,al

rcs_next_char:
																lodsb				; String [si] to al
																cmp	al,0FFh
																jne	rcs_check_special			; Jump if not equal
																retn

rcs_check_special:
																cmp	al,0Dh
																je	rcs_handle_newline			; Jump if equal
																or	al,al			; Zero ?
																js	rcs_handle_color_code			; Jump if sign=1
																push	cx
																push	bx
																push	si
																mov	ah,cs:tile_fg_mask
																call	render_text_char_alt
																pop	si
																pop	bx
																pop	cx
																add	bx,8
																jmp	short rcs_next_char

rcs_handle_newline:
																add	byte ptr cs:char_row_ptr,8
																mov	cl,cs:char_row_ptr
																mov	bx,cs:char_col_ptr
																jmp	short rcs_next_char

rcs_handle_color_code:
									and	al,7
									mov	cs:tile_fg_mask,al
									jmp	short rcs_next_char

ega_copy_xy_region:
		push	ds
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		mov	si,ax
		mov	ax,50h
		mul	dl			; ax = reg * al
		mov	dl,dh
		xor	dh,dh			; Zero register
		add	dx,dx
		add	ax,dx
		mov	di,ax

fn_21:
		SET_EGA_ES
		mov	ds,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_74:
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
									loop	locloop_74		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn

ega_pattern_fill:
		push	ds
		push	cs
		pop	ds

fn_22:
		mov	ds:tile_fg_mask,al
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		EGA_BLIT_PRO
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		call	fill_rectangle
		mov	cx,10h

locloop_75:
									mov	al,0F0h
									out	dx,al			; port 3CFh, EGA graphic func
									mov	al,ds:tile_fg_mask
									xchg	es:[di],al
									mov	al,0Fh
									out	dx,al			; port 3CFh, EGA graphic func
									mov	al,ds:tile_fg_mask
									xchg	es:[di+4],al
									add	di,50h
									loop	locloop_75		; Loop if cx > 0

		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		call	fill_rectangle
		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn

fill_rectangle		proc	near
		mov	cx,2

fn_23:

locloop_76:
									push	cx
									mov	al,ds:tile_fg_mask
									mov	cx,5
									rep	stosb			; Rep when cx >0 Store al to es:[di]
									add	di,4Bh
									pop	cx
									loop	locloop_76		; Loop if cx > 0

		retn

fill_rectangle		endp

render_font_ext:
		push	ds
		push	si
		push	cs
		pop	ds
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	si,ax
		mov	si,ds:sprite_anim_tbl[si]
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		EGA_BLIT_PRO
		mov	cx,0Dh

render_font_outer_loop:
		push	cx
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	bx,[si]
		mov	bp,bx
		mov	ax,[si+6]
		xchg	al,ah
		or	bx,ax
		and	bp,ax
		or	bx,[si+8]
		and	bp,[si+8]
		not	bp
		push	bp
		mov	cx,[si+2]
		mov	bp,cx
		mov	ax,[si+4]
		xchg	al,ah
		or	cx,ax
		and	bp,ax
		or	cx,[si+0Ah]
		and	bp,[si+0Ah]
		not	bp
		mov	al,bl
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,bh

fn_31:
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di+1],al
		mov	al,cl
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di+2],al
		mov	al,ch
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di+3],al
		mov	cx,bp
		pop	bx
		dec	dx
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	ax,bx
		and	ax,[si]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di+1],al
		mov	ax,cx
		and	ax,[si+2]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di+2],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di+3],al
		mov	ax,[si+6]
		xchg	al,ah
		and	ax,bx
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di+1],al
		mov	ax,[si+4]
		xchg	al,ah
		and	ax,cx
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di+2],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di+3],al
		mov	ax,bx
		and	ax,[si+8]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di+1],al
		mov	ax,cx
		and	ax,[si+0Ah]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di+2],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di+3],al
		dec	dx
		add	si,0Ch
		add	di,50h
		pop	cx
		loop	locloop_78		; Loop if cx > 0

		jmp	short render_font_cleanup

locloop_78:
		jmp	render_font_outer_loop

render_font_cleanup:
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	si
		pop	ds
		retn
; Sprite bitplane data (EGA 4-plane): 19 rows x 6 bytes + 4 bytes terminator
; Each row: [plane0_lo, plane0_hi, plane1_lo, plane1_hi, plane2_lo, plane2_hi]
; 80h = background fill, 00h = transparent/action, other = colour mask

sprite_anim_data:
		db	 2Bh, 2Dh,0C7h, 2Dh, 00h, 0Fh	; row  0
		db	0F3h, 00h, 00h,0F3h, 0Fh, 00h	; row  1
		db	 00h, 0Fh,0F3h, 00h, 00h, 7Ah	; row  2
		db	 8Fh, 00h, 00h, 7Fh, 75h, 00h	; row  3
		db	 00h, 70h, 0Fh, 00h, 00h, 77h	; row  4
		db	0F3h, 00h, 00h, 2Fh, 68h, 00h	; row  5
		db	 00h, 60h, 23h, 00h, 00h,0EFh	; row  6
		db	0F9h, 00h, 00h, 17h,0D0h, 00h	; row  7
		db	 00h,0C0h, 39h, 00h, 00h,0DFh	; row  8
		db	0FCh, 80h, 80h, 2Bh,0A8h, 00h	; row  9
		db	 00h, 98h, 7Ch, 80h, 00h,0DFh	; row 10
		db	0FCh, 80h, 80h, 17h,0B5h, 00h	; row 11
		db	 00h, 9Fh,0FCh, 80h, 00h, 9Fh	; row 12
		db	0FCh, 80h, 80h,0ABh,0EAh, 00h	; row 13
		db	 00h, 9Fh,0FCh, 80h, 00h, 4Fh	; row 14
		db	0F9h, 00h, 00h, 17h, 74h, 00h	; row 15
		db	 00h, 4Fh,0F9h, 00h, 00h, 67h	; row 16
		db	0F3h, 00h, 00h, 1Fh, 7Ch, 00h	; row 17
		db	 00h, 67h,0F3h, 00h, 00h, 78h	; row 18
		db	 0Fh, 00h, 00h,0FFh		; (4-byte terminator)

delay_anchor_dead:
									jg	$+2			; delay for I/O
									add	[bx+si+0Fh],bh
									add	[bx+si],al
									ja	delay_anchor_dead			; Jump if above
		add	[bx+si],al
;*		div	word ptr [bx+0]		; ax,dxrem=dx:ax/data
		db	0F7h, 77h, 00h		;  div word ptr [bx+0]  (F7h /6 with ModRM 77h; alt encoding)
		db	 00h, 77h,0F7h		; (3 dead-code bytes)
		db	26 dup (0)
; Sprite bitplane data (EGA 4-plane): 25 rows x 6 bytes + partial row 25 (5 bytes)
; Each row: [plane0_lo, plane0_hi, plane1_lo, plane1_hi, plane2_lo, plane2_hi]
; 80h = background fill, 00h = transparent/action, other = colour mask

sprite_anim_data_b:
		db	0FFh,0FFh, 00h, 00h, 3Fh,0E0h	; row  0
		db	 00h, 00h,0E0h, 07h, 00h, 03h	; row  1
		db	0FFh,0FFh,0C0h,0C0h,0FFh, 0Fh	; row  2
		db	 03h, 03h, 0Fh,0F4h,0C0h, 07h	; row  3
		db	0FFh,0FFh,0E0h,0E0h,0BFh, 74h	; row  4
		db	 04h, 04h, 74h,0BEh,0A0h, 0Fh	; row  5
		db	0FFh,0FFh,0F0h,0F0h,0F7h,0C2h	; row  6
		db	 08h, 08h,0C2h,0F7h, 50h, 1Fh	; row  7
		db	0FFh,0FFh,0F8h,0F8h,0FDh, 83h	; row  8
		db	 11h, 11h, 83h,0FDh,0A8h, 1Fh	; row  9
		db	0FFh,0AFh,0F8h,0D8h,0FFh, 1Fh	; row 10
		db	 13h, 13h, 1Fh,0AFh,0C8h, 1Fh	; row 11
		db	0FDh, 55h, 78h,0D8h,0FFh,0BFh	; row 12
		db	 13h, 13h,0BDh, 55h, 48h, 1Fh	; row 13
		db	0EAh, 02h,0F8h, 98h,0FFh,0BFh	; row 14
		db	 13h, 11h,0AAh, 02h, 88h, 0Fh	; row 15
		db	0B4h, 01h,0F0h, 10h,0FFh,0DFh	; row 16
		db	 0Bh, 08h, 94h, 01h, 10h, 07h	; row 17
		db	0EBh, 03h,0E0h, 20h,0FEh,0F6h	; row 18
		db	 05h, 04h, 62h, 02h, 20h, 03h	; row 19
		db	0FBh, 5Fh,0C0h,0C0h,0F8h,0FFh	; row 20
		db	 03h, 03h, 2Bh, 58h,0C0h, 00h	; row 21
		db	0FFh,0FFh, 00h, 00h,0DFh,0F7h	; row 22
		db	 00h, 00h,0E5h, 57h, 00h, 00h	; row 23
		db	 1Fh,0F8h, 00h, 00h,0F8h, 1Fh	; row 24
		db	 00h, 00h, 1Fh,0F8h, 00h	; row 25 (5 bytes; next byte starts vga_vram_init)

; VGA VRAM init stub: SET_EGA_ES, enable all-plane write, zero DI, load CX=8,
; then falls into locloop_81 to clear the EGA framebuffer.

vga_vram_init:
		SET_EGA_ES
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax				; port 3C4h, map mask: enable all 4 planes
		xor	di,di				; DI = 0 (VGA buffer start)
		mov	cx,8				; CX = 8 (outer loop count)

locloop_81:
									push	cx
									push	di
									mov	cx,19h

locloop_82:
																push	cx
																push	di
																mov	cx,50h
																xor	al,al			; Zero register
																rep	stosb			; Rep when cx >0 Store al to es:[di]
																pop	di
																add	di,280h
																pop	cx
																loop	locloop_82		; Loop if cx > 0

									pop	di
									add	di,50h
									pop	cx
									loop	locloop_81		; Loop if cx > 0

		retn
		db	0C3h, 00h, 00h, 00h, 00h, 00h	; C3h = retn + 5 zero-bytes padding

seg_a		ends

		end	start

fn_34:
