
PAGE  59,132

;==========================================================================
;
;  GMMCGA.BIN - MCGA/VGA 256-Color Graphics Driver (Mode 13h, 320x200)
;
;  Graphics primitives for VGA framebuffer at 0xA000:0000:
;  - Screen clear, pixel plot, line fill (horizontal/vertical)
;  - Rectangle fill
;  - Text character rendering (8x8 with color)
;  - Tilemap rendering (large 6x7 glyphs from font_ptr_b, small 16x16 sprites)
;  - 3-bitplane sprite decoding (3 bits per pixel, 8 colors)
;  - Time/BCD formatting utilities
;
;  VGA row stride: 320 bytes (0x140)
;
;  Code type: zero start
;  Created:   16-Feb-26
;  Passes:    9          Analysis Options on: none
;
;  Connections:
;    Loads:        none (pure renderer; loaded chunks fight/select read tile
;                  src buffers from driver_base + offset tile_src_base_lbl)
;    Calls into:   internal CS dispatch slots only (no external call thunks);
;                  VGA framebuffer writes to A000:0
;    Called by:    zeliad.exe loader (when RESOURCE.CFG selects MCGA/VGA);
;                  game.bin invokes via gfx_call_a/b/c at game_seg:0x201C/E/2020;
;                  fight.bin/town.bin call gfx_* dispatch entries
;    Reads/writes: gvar_game_seg (FF2C) [zeliad-owned], anim_ptr_0..4
;                  (E200/E202/E206/E20A/E20C, fight-owned), font_ptr_a/b/c
;                  (F500/F502/F504, font.grp-owned), VGA palette via DAC ports
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  stdply.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
palette_state	equ	0FF01h			;*
gvar_game_seg	equ	0FF2Ch			;*
gvar_cinematic_active	equ	0FF77h			;*

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
stride_minus_20		equ	12Ch
anim_ptr_0		equ	0E200h			;*
anim_ptr_1		equ	0E202h			;*
anim_ptr_2		equ	0E206h			;*
anim_ptr_3		equ	0E20Ah			;*
anim_ptr_4		equ	0E20Ch			;*
text_vga_ofs_a	equ	2434h			;*
text_vga_ofs_b	equ	2435h			;*
text_vga_ofs_c	equ	2437h			;*
tile_color_tbl	equ	24EAh			;*
tile_offset_tbl	equ	2A5Dh			;*
tile_color	equ	2CBDh			;*
char_color	equ	2CBFh			;*
char_src_ptr	equ	2CC0h			;*
bitplane_0	equ	2CC3h			;*
bitplane_1	equ	2CC5h			;*
bitplane_2	equ	2CC7h			;*
dispatch_tbl	equ	9521h			;*
font_ptr_a	equ	0F500h			;*
font_ptr_b	equ	0F502h			;*
font_ptr_c	equ	0F504h			;*
vga_stride	equ	140h			; VGA mode 13h row stride (320 bytes)
skip_2_rows	equ	280h			; VGA offset to skip 2 rows (2 * 320)
skip_8_rows	equ	0A00h			; VGA offset to skip 8 rows (8 * 320)
char_row_advance equ	1A0h			; VGA advance to next character row (320+96 bytes)
hud_vga_ofs	equ	11B0h			; VGA offset for HUD row (row 14, col 48)
text_field_vga_ofs equ	0CC14h			; VGA offset for timer/text field (row 163, col 84)
driver_base	equ	2000h			; driver loads at game_seg:2000h
vga_seg		equ	0A000h			; VGA framebuffer segment
tile_src_base		equ	driver_base + (offset tile_src_base_lbl)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
plot_mode	equ	2226h			;*
tile_row_idx	equ	2CBEh			;*
char_bit_idx	equ	2CC2h			;*

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
zero_offset	equ	0			;*
char_width	equ	0E0h			; character/tile render width in pixels (224)
char_width_half	equ	0A0h			; half character render width (160)

; Set ES to the VGA framebuffer segment (0xA000)
SET_VGA_ES	MACRO
		mov	ax, vga_seg
		mov	es, ax
		ENDM

; Compute VGA row*320 byte offset starting from packed BH/AH coords:
; (bh = row, ah = col-high). After the 6 instructions: AX = row*320,
; (sp) = col packed (caller pops). Same prologue at 8 of the 9 plot
; entry points (152 and 364 use slight variants). 9 sites.
vga_row_offset	MACRO
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,vga_stride
		mul	bx			; dx:ax = reg * ax
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

gmmcga		proc	far

start:
		; Function dispatch table (36 CS-relative word pointers, driver loads at game_seg:2000h).
		dw	2046h			; fn  0
		dw	2106h			; fn  1
		dw	2195h			; fn  2
		dw	2227h			; fn  3  (alt entry: MOV DI,text_field_vga_ofs; draw text field std)
		dw	2256h			; fn  4
		dw	2231h			; fn  5  (alt entry: MOV DI,draw_text_field_alt; draw text field alt)
		dw	2260h			; fn  6
		dw	22BFh			; fn  7
		dw	22CDh			; fn  8
		dw	2385h			; fn  9
		dw	238Fh			; fn 10
		dw	23ACh			; fn 11
		dw	23CCh			; fn 12
		dw	23F5h			; fn 13
		dw	254Ch			; fn 14
		dw	25E2h			; fn 15
		dw	25FCh			; fn 16
		dw	27E9h			; fn 17
		dw	2857h			; fn 18
		dw	289Ah			; fn 19
		dw	28D9h			; fn 20
		dw	291Ah			; fn 21
		dw	296Fh			; fn 22
		dw	29C3h			; fn 23
		dw	24A3h			; fn 24
		dw	243Ah			; fn 25
		dw	2616h			; fn 26
		dw	2637h			; fn 27
		dw	22DBh			; fn 28
		dw	2718h			; fn 29
		dw	2730h			; fn 30
		dw	2A1Ch			; fn 31
		dw	2130h			; fn 32
		dw	2C01h			; fn 33  (alt entry: mid process_sprite_row)
		dw	2C2Ah			; fn 34
		dw	3350h			; fn 35 (external)

dispatch_call:
; Coordinate dispatch: AL=fn#, BH=row, AH=col; computes VGA row offset and branches.
		db	0C0h			; alternate opcode byte (alt encoding)
		mov	al,bh			; AL = row
		mov	bh,ah			; BH = col high byte
		push	ax
		mov	ax,vga_stride		; 320 bytes per row
		mul	bx			; AX = row * 320
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		pop	ax
		or	al,al
		jnz	volume_param_branch
		jmp	clear_screen_init

volume_param_branch:
		mov	dx,909h
		test	byte ptr cs:gvar_cinematic_active,0FFh
		jz	clear_screen_entry			; Jump if zero
		mov	dx,0FFFFh

clear_screen_entry:
		push	di
		sub	cl,4
		add	di,skip_2_rows
		call	clear_screen
		pop	di
		xor	ax,ax			; Zero register
		xor	bx,bx			; Zero register
		call	fill_horizontal_line
		mov	ax,0FF00h
		mov	bx,0FFh
		call	fill_horizontal_line
		push	cx
		push	bx
		mov	bl,ch
		dec	bl
		add	bx,bx
		add	bx,bx
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

draw_border_loop:
								mov	es:[di],dx
								mov	es:[bx+di+2],dx
								add	di,vga_stride
								loop	draw_border_loop		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0FF00h
		mov	bx,0FFh
		call	fill_horizontal_line
		xor	ax,ax			; Zero register
		xor	bx,bx			; Zero register

gmmcga		endp

fill_horizontal_line		proc	near
		push	di
		push	cx
		not	ax
		and	es:[di],ax
		not	ax
		and	ax,dx
		or	es:[di],ax
		inc	di
		inc	di
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		sub	cx,4
		mov	al,dl
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		not	bx
		and	es:[di],bx
		not	bx
		and	bx,dx
		or	es:[di],bx
		pop	cx
		pop	di
		add	di,vga_stride
		retn

fill_horizontal_line		endp

clear_screen		proc	near

clear_screen_init:
		SET_VGA_ES
		push	cx
		xor	ax,ax			; Zero register

clear_row_loop:
								push	di
								push	cx
								mov	cl,ch
								xor	ch,ch			; Zero register
								add	cx,cx
								rep	stosw			; Rep when cx >0 Store ax to es:[di]
								pop	cx
								pop	di
								add	di,vga_stride
								dec	cl
								jnz	clear_row_loop			; Jump if not zero
		pop	cx
		retn

clear_screen		endp

			                        ;* No entry point to code
		SET_VGA_ES
		mov	di,hud_vga_ofs
		mov	cx,8

clear_block_outer_loop:
								push	cx
								push	di
								mov	cx,12h

clear_block_inner_loop:
														push	cx
														push	di
														mov	cx,char_width
														xor	al,al			; Zero register
														rep	stosb			; Rep when cx >0 Store al to es:[di]
														pop	di
														add	di,skip_8_rows
														pop	cx
														loop	clear_block_inner_loop		; Loop if cx > 0

								pop	di
								add	di,vga_stride
								pop	cx
								loop	clear_block_outer_loop		; Loop if cx > 0

		retn
font_render_code		db	0B8h
		db	 00h,0A0h, 8Eh,0C0h
		db	0BEh, 8Dh, 21h,0B9h, 08h, 00h

font_render_loop:
								push	cx
								mov	di,11B0h
								lodsb				; String [si] to al
								push	di
								mov	cx,48h

font_row_loop:
														push	cx
														mov	cx,char_width

font_bit_loop:
														rol	al,1			; Rotate
														jnc	font_skip_pixel			; Jump if carry=0
														mov	byte ptr es:[di],0

font_skip_pixel:
														inc	di
														loop	font_bit_loop		; Loop if cx > 0

														ror	al,1			; Rotate
														ror	al,1			; Rotate
														ror	al,1			; Rotate
														pop	cx
														add	di,char_row_advance
														loop	font_row_loop		; Loop if cx > 0

								pop	di
								add	di,vga_stride
								mov	cx,48h

font_row_loop_b:
														push	cx
														mov	cx,char_width

font_bit_loop_b:
														ror	al,1			; Rotate
														jnc	font_skip_pixel_b			; Jump if carry=0
														mov	byte ptr es:[di],0

font_skip_pixel_b:
														inc	di
														loop	font_bit_loop_b		; Loop if cx > 0

														rol	al,1			; Rotate
														rol	al,1			; Rotate
														rol	al,1			; Rotate
														pop	cx
														add	di,char_row_advance
														loop	font_row_loop_b		; Loop if cx > 0

								mov	cx,1F40h

delay_loop:
														loop	delay_loop		; Loop if cx > 0

								pop	cx
								loop	font_render_loop		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		add	[bp+di],ax
		pop	es
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		pop	ds
		aas				; Ascii adjust
		db	 7Fh,0FFh

set_plot_mode:
		mov	cs:plot_mode,al
		SET_VGA_ES
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		add	bx,9Eh
		mov	ax,vga_stride
		mul	bx			; dx:ax = reg * ax
		pop	bx
		add	ax,bx
		add	ax,30h
		mov	di,ax
		push	cx
		xor	ax,ax			; Zero register
		call	plot_pixel
		pop	cx
		inc	di
		mov	cl,ch

plot_white_pixels_loop:
								push	cx
								mov	ax,0FFFFh
								call	plot_pixel
								pop	cx
								inc	di
								dec	cl
								jnz	plot_white_pixels_loop			; Jump if not zero
		retn

plot_pixel		proc	near
		test	byte ptr cs:plot_mode,0FFh
		jnz	check_mode			; Jump if not zero
		push	di
		and	ah,5
		and	al,2Dh			; '-'
		mov	byte ptr es:[di],0
		add	di,vga_stride
		mov	cx,8

fill_col_loop:
								mov	es:[di],ah
								add	di,vga_stride
								loop	fill_col_loop		; Loop if cx > 0

		mov	es:[di],al
		pop	di
		retn

check_mode:
		cmp	byte ptr cs:plot_mode,80h
		je	inverted_blend_entry			; Jump if equal
		push	di
		mov	ah,al
		not	ah
		and	al,1
		mov	cx,0Ah

blend_loop:
								and	es:[di],ah
								or	es:[di],al
								add	di,vga_stride
								loop	blend_loop		; Loop if cx > 0

		pop	di
		retn

inverted_blend_entry:
		push	di
		not	al
		mov	cx,0Ah

inverted_blend_loop:
								and	es:[di],al
								add	di,vga_stride
								loop	inverted_blend_loop		; Loop if cx > 0

		pop	di
		retn

plot_pixel		endp

; plot_mode opcode byte lives here (CS:2226h); set_plot_mode patches it to
; change the pixel operation (ADD/OR/AND/SUB) applied to the VGA text field.

plot_mode_fn:
		add	byte ptr [bx+text_field_vga_ofs],bh	; opcode patched by set_plot_mode
		mov	bx,cs:[0B2h]
		jmp	short draw_text_field_common

draw_text_field_alt:
		mov	di,0DB14h			; alt VGA row offset (row 175, col 84)
		jmp	short draw_text_field_common

draw_text_field_common:
		SET_VGA_ES
		call	calc_text_width
		mov	cx,bx
		or	cx,cx
		jnz	vertical_line_loop
		retn

vertical_line_loop:
								push	cx
								push	di
								mov	bh,6
								mov	al,12h
								mov	ah,2Dh			; '-'
								call	fill_vertical_line
								pop	di
								inc	di
								pop	cx
								loop	vertical_line_loop		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	di,text_field_vga_ofs
		mov	bx,word ptr cs:[hero_HP]
		jmp	short calc_width_entry
		db	0BFh, 14h,0DBh,0EBh, 00h

calc_width_entry:
		SET_VGA_ES
		call	calc_text_width
		push	bx
		mov	cx,bx
		or	cx,cx			; Zero ?
		jz	calc_remaining_width			; Jump if zero

draw_text_cols_loop:
								push	cx
								push	di
								mov	bh,5
								mov	al,9
								mov	ah,12h
								call	fill_vertical_line
								pop	di
								inc	di
								pop	cx
								loop	draw_text_cols_loop		; Loop if cx > 0

calc_remaining_width:
		pop	bx
		mov	cx,64h
		sub	cx,bx
		jnz	fill_blank_cols_loop		; Jump if not zero
		retn

fill_blank_cols_loop:
								push	cx
								push	di
								mov	bh,5
								xor	al,al			; Zero register
								mov	ah,12h
								call	fill_vertical_line
								pop	di
								inc	di
								pop	cx
								loop	fill_blank_cols_loop		; Loop if cx > 0

		retn

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	text_width_clamped			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		retn

text_width_clamped:
		mov	bx,64h
		retn

calc_text_width		endp

fill_vertical_line		proc	near

fill_vline_loop:
								and	es:[di],ah
								or	es:[di],al
								add	di,vga_stride
								dec	bh
								jnz	fill_vline_loop			; Jump if not zero
		retn

fill_vertical_line		endp

			                        ;* No entry point to code
		mov	byte ptr cs:tile_color,1Bh
		mov	byte ptr cs:tile_row_idx,12h
		jmp	short text_data_entry
			                        ;* No entry point to code
		mov	byte ptr cs:tile_color,9
		mov	byte ptr cs:tile_row_idx,2Dh	; '-'
		jmp	short text_data_entry
			                        ;* No entry point to code
		mov	byte ptr cs:tile_color,9
		mov	byte ptr cs:tile_row_idx,0
		vga_row_offset
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		xor	ch,ch			; Zero register
		add	di,cx
		SET_VGA_ES

char_stream_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jnz	render_char_entry			; Jump if not zero
								retn

render_char_entry:
								push	ds
								push	si
								call	render_text_char
								pop	si
								pop	ds
								jmp	short char_stream_loop

text_data_entry:
		lodsb				; String [si] to al
		mov	dl,al
		xor	dh,dh			; Zero register
		push	dx
		lodsb				; String [si] to al
		xor	ah,ah			; Zero register
		mov	bx,vga_stride
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		lodsb				; String [si] to al
		xor	ah,ah			; Zero register
		mov	bl,al
		add	di,ax
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		SET_VGA_ES

render_line_loop:
								push	cx
								lodsb				; String [si] to al
								push	ds
								push	si
								call	render_text_char
								pop	si
								pop	ds
								pop	cx
								loop	render_line_loop		; Loop if cx > 0

		retn

render_text_char		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		add	si,ds:font_ptr_c
		push	di
		mov	bl,8

char_row_loop:
								push	bx
								lodsb				; String [si] to al
								push	di
								mov	dh,al
								mov	dl,4

char_pixel_loop:
														add	dh,dh
														jnc	char_next_pixel			; Jump if carry=0
														mov	al,ds:tile_row_idx
														mov	es:[di+1],al
														mov	ah,ds:tile_color
														mov	es:[di],ah

char_next_pixel:
														inc	di
														dec	dl
														jnz	char_pixel_loop			; Jump if not zero
								pop	di
								add	di,vga_stride
								pop	bx
								dec	bl
								jnz	char_row_loop			; Jump if not zero
		pop	di
		add	di,5
		retn

render_text_char		endp

			                        ;* No entry point to code
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,88h
		jmp	set_plot_mode
			                        ;* No entry point to code
		push	ds
		mov	ax,word ptr cs:[8Bh]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,text_vga_ofs_b
		mov	cx,105h
		mov	ax,26BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,word ptr cs:[86h]
		mov	dl,byte ptr cs:[85h]
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,text_vga_ofs_a
		mov	cx,106h
		mov	ax,13BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		xor	bx,bx			; Zero register
		mov	bl,byte ptr cs:[9Dh]
		dec	bl
		mov	al,byte ptr cs:[0ABh][bx]
		xor	ah,ah			; Zero register
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,text_vga_ofs_c
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		test	byte ptr cs:[93h],0FFh
		jnz	draw_timer_entry			; Jump if not zero
		retn

draw_timer_entry:
		push	ds
		mov	ax,word ptr cs:[94h]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,text_vga_ofs_c
		mov	cx,103h
		mov	ax,3EBBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn

init_timestamp		proc	near
		mov	di,2433h
		call	time_to_bcd
		mov	cx,6

check_filled_loop:
								test	byte ptr cs:[di],0FFh
								jz	mark_slot_filled			; Jump if zero
								retn

mark_slot_filled:
								mov	byte ptr cs:[di],0FFh
								inc	di
								loop	check_filled_loop		; Loop if cx > 0

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

bcd_div_loop:
								sub	dl,cl
								jc	bcd_adjust			; Jump if carry Set
								sub	ax,bx
								jnc	bcd_increment			; Jump if carry=0
								or	dl,dl			; Zero ?
								jz	bcd_restore			; Jump if zero
								dec	dl

bcd_increment:
								inc	dh
								jmp	short bcd_div_loop

bcd_restore:
		add	ax,bx

bcd_adjust:
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
		mov	ds:tile_row_idx,bh
		xor	bh,bh			; Zero register
		mov	dl,ds:tile_color_tbl[bx]
		mov	ds:tile_color,dl
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,bh
		push	bx
		mov	bx,vga_stride
		mul	bx			; dx:ax = reg * ax
		pop	bx
		add	bx,bx
		add	bx,bx
		add	bx,ax
		shr	ch,1			; Shift w/zeros fill
		sbb	ax,ax
		and	ax,2
		add	bx,ax
		SET_VGA_ES

tile_render_loop:
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
								add	bx,6
								dec	cl
								jnz	tile_render_loop			; Jump if not zero
		retn

render_tilemap_large		endp

; Tile column byte offsets (8 entries, stride 9): 0,9,18,27,36,45,54,63
; Indexed by column number to get byte offset within a tile row

tile_col_offsets:
		db	 00h, 09h, 12h
		db	 1Bh, 24h, 2Dh, 36h, 3Fh

decode_bitplane_tile		proc	near
		test	byte ptr ds:tile_row_idx,0FFh
		jz	check_blank_tile			; Jump if zero
		push	ax
		push	di
		mov	ax,505h
		mov	cx,7

blit_tile_pattern:
								push	cx
								push	di
								mov	cx,3
								rep	stosw			; Rep when cx >0 Store ax to es:[di]
								pop	di
								add	di,vga_stride
								pop	cx
								loop	blit_tile_pattern		; Loop if cx > 0

		pop	di
		pop	ax

check_blank_tile:
		inc	al
		jnz	render_font_tile			; Jump if not zero
		retn

render_font_tile:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:font_ptr_b
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,7

font_byte_loop:
								lodsb				; String [si] to al
								add	al,al
								add	al,al
								mov	ah,6

font_bit_loop_tile:
														add	al,al
														jnc	font_next_pixel_tile			; Jump if carry=0
														mov	bl,cs:tile_color
														mov	es:[di],bl

font_next_pixel_tile:
														inc	di
														dec	ah
														jnz	font_bit_loop_tile			; Jump if not zero
								add	di,13Ah
								loop	font_byte_loop		; Loop if cx > 0

		retn

decode_bitplane_tile		endp

			                        ;* No entry point to code
		push	ds
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,10Eh
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_0
		mov	si,ax
		vga_row_offset
		pop	bp
		add	bp,bp
		add	bp,bp
		add	bp,bp
		add	bp,ax
		SET_VGA_ES
		mov	cx,12h

tilemap_large_loop:
								push	cx
								mov	ax,[si]
								xchg	ah,al
								mov	cs:bitplane_0,ax
								mov	ax,[si+8]
								mov	cs:bitplane_1,ax
								mov	ax,[si+0Ah]
								xchg	ah,al
								mov	cs:bitplane_2,ax
								call	extract_bitplane_pixels
								call	extract_bitplane_pixels
								mov	ax,[si+2]
								xchg	ah,al
								mov	cs:bitplane_0,ax
								mov	ax,[si+6]
								mov	cs:bitplane_1,ax
								mov	ax,[si+0Ch]
								xchg	ah,al
								mov	cs:bitplane_2,ax
								call	extract_bitplane_pixels
								call	extract_bitplane_pixels
								xor	al,al			; Zero register
								mov	ah,[si+4]
								mov	cs:bitplane_0,ax
								mov	ah,[si+5]
								mov	cs:bitplane_1,ax
								mov	ah,[si+0Eh]
								mov	cs:bitplane_2,ax
								call	extract_bitplane_pixels
								add	si,0Fh
								add	bp,stride_minus_20
								pop	cx
								loop	tilemap_large_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_2
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
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
			                        ;* No entry point to code
		push	ds
		mov	si,tile_src_base
		or	al,al			; Zero ?
		jz	render_tilemap_branch			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_4
		mov	si,ax

render_tilemap_branch:
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,tile_src_base
		or	al,al			; Zero ?
		jz	render_animated_tile			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_3
		mov	si,ax

render_animated_tile:
		call	render_tilemap_small
		pop	ds
		retn
; VGA tile bitmap (16 rows x 12 bytes = 192 bytes). Each row = even+odd VGA scanlines.
; Referenced as tile_src_base by render_tilemap_large.

tile_src_base_lbl:
		db	 00h, 00h, 00h, 00h,0FCh,0FFh	; row  0 even
		db	0FFh, 3Fh, 2Ah,0AAh,0AAh,0A8h	; row  0 odd
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row  1 even
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row  1 odd
		db	 0Eh, 38h,0F8h, 00h, 03h, 00h	; row  2 even
		db	 00h,0C0h, 82h, 08h, 08h, 02h	; row  2 odd
		db	 0Fh,0BBh, 8Eh, 00h, 03h, 00h	; row  3 even
		db	 00h,0C0h, 80h, 88h, 82h, 02h	; row  3 odd
		db	 0Fh,0FBh, 8Eh, 00h, 03h, 00h	; row  4 even
		db	 00h,0C0h, 80h, 08h, 82h, 02h	; row  4 odd
		db	 0Eh,0FBh, 8Eh, 00h, 03h, 00h	; row  5 even
		db	 00h,0C0h, 82h, 08h, 82h, 02h	; row  5 odd
		db	 0Eh, 38h,0F8h, 00h, 03h, 00h	; row  6 even
		db	 00h,0C0h, 82h, 08h, 08h, 02h	; row  6 odd
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row  7 even
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row  7 odd
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row  8 even
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row  8 odd
		db	 0Eh, 38h,0FBh,0F8h, 03h, 00h	; row  9 even
		db	 00h,0C0h, 82h, 08h, 08h, 0Ah	; row  9 odd
		db	 0Eh, 3Bh, 83h, 80h, 03h, 00h	; row 10 even
		db	 00h,0C0h, 82h, 08h, 80h, 82h	; row 10 odd
		db	 0Eh, 38h,0E3h,0C0h, 03h, 00h	; row 11 even
		db	 00h,0C0h, 82h, 08h, 20h, 02h	; row 11 odd
		db	 0Eh, 38h, 3Bh, 80h, 03h, 00h	; row 12 even
		db	 00h,0C0h, 82h, 08h, 08h, 82h	; row 12 odd
		db	 03h,0E3h,0E3h,0F8h, 03h, 00h	; row 13 even
		db	 00h,0C0h, 80h, 20h, 20h, 0Ah	; row 13 odd
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row 14 even
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row 14 odd
		db	 00h, 00h, 00h, 00h,0FCh,0FFh	; row 15 even
		db	0FFh, 3Fh, 2Ah,0AAh,0AAh,0A8h	; row 15 odd
; Sprite source selector A: SI = row*192 + game_seg:[0E208h], calls render_tilemap_small
		push	ds
		mov	ds,cs:[gvar_game_seg]
		xor	ah,ah
		mov	cx,0C0h
		mul	cx
		add	ax,ds:[0E208h]
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn
; Sprite source selector B: SI = row*192 + game_seg:[0E204h], calls render_tilemap_small
		push	ds
		mov	ds,cs:[gvar_game_seg]
		xor	ah,ah
		mov	cx,0C0h
		mul	cx
		add	ax,ds:[0E204h]
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn

render_tilemap_small		proc	near
		vga_row_offset
		pop	bp
		add	bp,bp
		add	bp,bp
		add	bp,2
		add	bp,ax
		SET_VGA_ES
		mov	cx,10h

tilemap_small_loop:
								push	cx
								mov	ax,[si]
								xchg	ah,al
								mov	cs:bitplane_0,ax
								mov	ax,[si+6]
								mov	cs:bitplane_1,ax
								mov	ax,[si+8]
								xchg	ah,al
								mov	cs:bitplane_2,ax
								call	extract_bitplane_pixels
								call	extract_bitplane_pixels
								mov	dx,[si+2]
								xchg	dh,dl
								mov	cs:bitplane_0,dx
								mov	dx,[si+4]
								mov	cs:bitplane_1,dx
								mov	dx,[si+0Ah]
								xchg	dh,dl
								mov	cs:bitplane_2,dx
								call	extract_bitplane_pixels
								call	extract_bitplane_pixels
								add	si,0Ch
								add	bp,130h
								pop	cx
								loop	tilemap_small_loop		; Loop if cx > 0

		retn

render_tilemap_small		endp

extract_bitplane_pixels		proc	near
		mov	cx,4

bitplane_bits_loop:
								xor	ax,ax			; Zero register
								rol	word ptr cs:bitplane_2,1	; Rotate
								adc	ax,ax
								rol	word ptr cs:bitplane_1,1	; Rotate
								adc	ax,ax
								rol	word ptr cs:bitplane_0,1	; Rotate
								adc	ax,ax
								rol	word ptr cs:bitplane_2,1	; Rotate
								adc	ax,ax
								rol	word ptr cs:bitplane_1,1	; Rotate
								adc	ax,ax
								rol	word ptr cs:bitplane_0,1	; Rotate
								adc	ax,ax
								mov	es:[bp],al
								inc	bp
								loop	bitplane_bits_loop		; Loop if cx > 0

		retn

extract_bitplane_pixels		endp

render_text_char_alt		proc	near
		push	ds
		push	cs
		pop	ds
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,ds:tile_color_tbl[bx]
		test	byte ptr cs:gvar_cinematic_active,0FFh
		jz	store_render_color			; Jump if zero
		mov	ah,bl
		add	ah,ah
		add	ah,ah
		add	ah,ah
		add	ah,ah
		or	ah,bl

store_render_color:
		mov	ds:tile_color,ah
		pop	bx
		xor	ah,ah			; Zero register
		sub	al,20h			; ' '
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:font_ptr_a
		push	ax
		mov	al,bl
		and	al,3
		add	al,al
		mov	ds:tile_row_idx,al
		mov	ax,vga_stride
		xor	ch,ch			; Zero register
		mul	cx			; dx:ax = reg * ax
		add	ax,bx
		mov	di,ax
		pop	si
		SET_VGA_ES
		mov	cx,8

alt_char_row_loop:
								push	cx
								lodsb				; String [si] to al
								mov	cx,8

alt_char_pixel_loop:
														add	al,al
														jnc	alt_char_next_pixel			; Jump if carry=0
														mov	dl,cs:tile_color
														mov	es:[di],dl

alt_char_next_pixel:
														inc	di
														loop	alt_char_pixel_loop		; Loop if cx > 0

								pop	cx
								add	di,138h
								loop	alt_char_row_loop		; Loop if cx > 0

		pop	ds
		retn

render_text_char_alt		endp

			                        ;* No entry point to code
		push	ds
		vga_row_offset
		pop	di
		add	di,di
		add	di,di
		add	di,di
		add	di,ax
		mov	si,di
		add	si,vga_stride
		SET_VGA_ES
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		xor	ch,ch			; Zero register

copy_region_loop:
								push	cx
								push	di
								push	si
								mov	cx,bx
								rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
								pop	si
								pop	di
								add	di,vga_stride
								add	si,vga_stride
								pop	cx
								loop	copy_region_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		add	di,0
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,bh
		push	bx
		mov	bx,vga_stride
		mul	bx			; dx:ax = reg * ax
		pop	si
		add	si,si
		add	si,si
		add	si,si
		add	si,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,0A000h
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh
		add	bx,bx
		add	bx,bx

copy_from_vga_loop:
								push	cx
								push	si
								mov	cx,bx
								rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
								pop	si
								add	si,vga_stride
								pop	cx
								loop	copy_from_vga_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,di
		add	si,0
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,bh
		push	bx
		mov	bx,vga_stride
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,di
		add	di,ax
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		SET_VGA_ES
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh
		add	bx,bx
		add	bx,bx

copy_to_vga_loop:
								push	cx
								push	di
								mov	cx,bx
								rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
								pop	di
								add	di,vga_stride
								pop	cx
								loop	copy_to_vga_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	cs:char_src_ptr,bx
		mov	cs:char_bit_idx,cl
		mov	al,1
		test	byte ptr cs:gvar_cinematic_active,0FFh
		jz	set_char_color			; Jump if zero
		mov	al,7

set_char_color:
		mov	cs:char_color,al

char_cmd_loop:
														lodsb				; String [si] to al
														cmp	al,0FFh
														jne	check_newline_cmd			; Jump if not equal
														retn

check_newline_cmd:
														cmp	al,0Dh
														je	handle_newline			; Jump if equal
														or	al,al			; Zero ?
														js	set_color_cmd			; Jump if sign=1
														push	cx
														push	bx
														push	si
														mov	ah,cs:char_color
														call	render_text_char_alt
														pop	si
														pop	bx
														pop	cx
														add	bx,8
														jmp	short char_cmd_loop

handle_newline:
														add	byte ptr cs:char_bit_idx,8
														mov	cl,cs:char_bit_idx
														mov	bx,cs:char_src_ptr
														jmp	short char_cmd_loop

set_color_cmd:
								and	al,7
								mov	cs:char_color,al
								jmp	short char_cmd_loop
			                        ;* No entry point to code
		push	ds
		push	dx
		vga_row_offset
		pop	si
		add	si,si
		add	si,si
		add	si,si
		add	si,ax
		pop	bx
		vga_row_offset
		pop	di
		add	di,di
		add	di,di
		add	di,di
		add	di,ax
		SET_VGA_ES
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		xor	ch,ch			; Zero register

copy_stride_loop:
								push	cx
								push	di
								push	si
								mov	cx,bx
								rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
								pop	si
								pop	di
								add	di,vga_stride
								add	si,vga_stride
								pop	cx
								loop	copy_stride_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	al,ds:tile_color_tbl[bx]
		mov	ds:tile_color,al
		pop	bx
		vga_row_offset
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		SET_VGA_ES
		call	fill_rectangle
		mov	al,ds:tile_color
		mov	cx,10h

corner_pixel_loop:
								mov	es:[di],al
								mov	es:[di+1],al
								mov	es:[di+12h],al
								mov	es:[di+13h],al
								add	di,vga_stride
								loop	corner_pixel_loop		; Loop if cx > 0

fill_rectangle		proc	near
		mov	cx,2

fill_rect_row_loop:
								push	cx
								push	di
								mov	al,ds:tile_color
								mov	cx,14h
								rep	stosb			; Rep when cx >0 Store al to es:[di]
								pop	di
								add	di,vga_stride
								pop	cx
								loop	fill_rect_row_loop		; Loop if cx > 0

		retn

fill_rectangle		endp

			                        ;* No entry point to code
		push	ds
		push	si
		push	cs
		pop	ds
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	si,ax
		vga_row_offset
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		SET_VGA_ES
		mov	si,ds:tile_offset_tbl[si]
		mov	cx,0Dh

tile_row_loop:
								push	cx
								mov	cx,10h

tile_col_loop:
														lodsb				; String [si] to al
														cmp	al,80h
														je	tile_next_col			; Jump if equal
														stosb				; Store al to es:[di]
														dec	di

tile_next_col:
														inc	di
														loop	tile_col_loop		; Loop if cx > 0

								pop	cx
								add	di,offset font_render_code
								loop	tile_row_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn
; Sprite bitplane animation data: 70 rows x 6 bytes = 420 bytes
; Each row: [bp0_lo, bp0_hi, bp1_lo, bp1_hi, bp2_lo, bp2_hi] ?-- 3 bitplanes x 16 pixels
; 80h = background, 00h = boundary/action, other = colour index
; Process: process_sprite_row reads 8 consecutive rows (48 bytes) per call
; Sprite bitplane animation data: 70 rows x 6 bytes = 420 bytes
; Each row: [bp0_lo, bp0_hi, bp1_lo, bp1_hi, bp2_lo, bp2_hi] -- 3 bitplanes x 16 pixels
; 80h = background, 00h = boundary/action, other = colour index
; process_sprite_row reads 8 consecutive rows (48 bytes) per call

sprite_anim_data:
		db	061h, 02Ah, 031h, 02Bh, 080h, 080h	; [####  ]
		db	080h, 080h, 080h, 080h, 000h, 000h	; [    ..]
		db	000h, 000h, 080h, 000h, 080h, 080h	; [.. .  ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	000h, 000h, 011h, 011h, 011h, 012h	; [..####]
		db	000h, 000h, 080h, 080h, 080h, 080h	; [..    ]
		db	080h, 080h, 080h, 080h, 000h, 011h	; [    .#]
		db	011h, 009h, 009h, 001h, 012h, 000h	; [#####.]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	080h, 080h, 000h, 011h, 009h, 009h	; [  .###]
		db	009h, 028h, 02Ah, 010h, 080h, 080h	; [####  ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	011h, 015h, 001h, 009h, 00Dh, 005h	; [######]
		db	005h, 012h, 000h, 080h, 080h, 080h	; [##.   ]
		db	080h, 080h, 080h, 080h, 011h, 010h	; [    ##]
		db	028h, 028h, 02Dh, 028h, 028h, 012h	; [######]
		db	000h, 080h, 080h, 080h, 080h, 080h	; [.     ]
		db	080h, 080h, 012h, 015h, 005h, 005h	; [  ####]
		db	005h, 005h, 005h, 012h, 000h, 080h	; [####. ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	000h, 012h, 005h, 02Dh, 02Dh, 005h	; [.#####]
		db	015h, 002h, 080h, 080h, 080h, 080h	; [##    ]
		db	080h, 080h, 080h, 080h, 000h, 002h	; [    .#]
		db	002h, 02Dh, 02Dh, 005h, 012h, 000h	; [#####.]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	080h, 080h, 000h, 000h, 002h, 012h	; [  ..##]
		db	012h, 012h, 000h, 000h, 080h, 080h	; [##..  ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	000h, 000h, 080h, 000h, 000h, 000h	; [.. ...]
		db	080h, 000h, 080h, 080h, 080h, 080h	; [ .    ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	000h, 001h, 009h, 009h, 009h, 01Bh	; [.#####]
		db	003h, 000h, 080h, 080h, 080h, 080h	; [#.    ]
		db	080h, 080h, 080h, 000h, 009h, 009h	; [   .##]
		db	000h, 000h, 000h, 000h, 003h, 01Bh	; [....##]
		db	000h, 080h, 080h, 080h, 080h, 080h	; [.     ]
		db	000h, 009h, 001h, 000h, 001h, 009h	; [.##.##]
		db	001h, 000h, 000h, 003h, 003h, 000h	; [#..##.]
		db	080h, 080h, 080h, 080h, 001h, 009h	; [    ##]
		db	000h, 009h, 009h, 001h, 000h, 000h	; [.###..]
		db	001h, 000h, 003h, 003h, 080h, 080h	; [#.##  ]
		db	080h, 000h, 009h, 001h, 001h, 009h	; [ .####]
		db	009h, 000h, 000h, 000h, 000h, 001h	; [#....#]
		db	003h, 003h, 000h, 080h, 080h, 000h	; [##.  .]
		db	009h, 000h, 009h, 001h, 000h, 000h	; [#.##..]
		db	002h, 002h, 000h, 000h, 000h, 00Bh	; [##...#]
		db	000h, 080h, 080h, 000h, 009h, 000h	; [.  .#.]
		db	001h, 000h, 000h, 002h, 002h, 002h	; [#..###]
		db	002h, 002h, 002h, 00Bh, 000h, 080h	; [####. ]
		db	080h, 000h, 009h, 003h, 001h, 002h	; [ .####]
		db	002h, 002h, 012h, 012h, 012h, 002h	; [######]
		db	001h, 00Bh, 000h, 080h, 080h, 080h	; [##.   ]
		db	001h, 01Bh, 002h, 001h, 002h, 012h	; [######]
		db	012h, 012h, 012h, 002h, 009h, 001h	; [######]
		db	080h, 080h, 080h, 080h, 000h, 00Bh	; [    .#]
		db	003h, 002h, 00Ah, 001h, 012h, 012h	; [######]
		db	012h, 001h, 009h, 000h, 080h, 080h	; [###.  ]
		db	080h, 080h, 080h, 000h, 01Bh, 003h	; [   .##]
		db	002h, 000h, 002h, 002h, 001h, 009h	; [#.####]
		db	000h, 080h, 080h, 080h, 080h, 080h	; [.     ]
		db	080h, 080h, 000h, 003h, 001h, 003h	; [  .###]
		db	003h, 001h, 003h, 000h, 080h, 080h	; [###.  ]
		db	080h, 080h, 080h, 080h, 080h, 080h	; [      ]
		db	080h, 000h, 000h, 000h, 000h, 000h	; [ .....]
		db	000h, 080h, 080h, 080h, 080h, 080h	; [.     ]
; VGA init stub: sets ES=A000h, DI=0, CX=8, falls into clear_vram_outer

vga_vram_init:
		SET_VGA_ES
		xor	di,di
		mov	cx,8

clear_vram_outer:
								push	cx
								push	di
								mov	cx,19h

clear_vram_inner:
														push	cx
														push	di
														mov	cx,char_width_half
														xor	ax,ax			; Zero register
														rep	stosw			; Rep when cx >0 Store ax to es:[di]
														pop	di
														add	di,skip_8_rows
														pop	cx
														loop	clear_vram_inner		; Loop if cx > 0

								pop	di
								add	di,vga_stride
								pop	cx
								loop	clear_vram_outer		; Loop if cx > 0

		retn
			                        ;* No entry point to code
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

sprite_batch_loop:
								push	cx
								call	process_sprite_row
								pop	cx
								loop	sprite_batch_loop		; Loop if cx > 0

		retn

process_sprite_row		proc	near
		mov	cx,8

sprite_row_loop:
								push	cx
								lodsw				; String [si] to ax
								xchg	ah,al
								mov	cs:bitplane_0,ax
								lodsw				; String [si] to ax
								xchg	ah,al
								mov	cs:bitplane_1,ax
								lodsw				; String [si] to ax
								xchg	ah,al
								mov	cs:bitplane_2,ax
								call	bitplane_to_pixels
								pop	cx
								loop	sprite_row_loop		; Loop if cx > 0

		retn

process_sprite_row		endp

bitplane_to_pixels		proc	near
		mov	cx,2

bitplane_pixels_loop:
								call	extract_bitplane_bit
								call	extract_bitplane_bit
								call	extract_bitplane_bit
								call	extract_bitplane_bit
								call	extract_bitplane_bit
								rol	word ptr cs:bitplane_2,1	; Rotate
								adc	ax,ax
								stosw				; Store ax to es:[di]
								rol	word ptr cs:bitplane_1,1	; Rotate
								adc	ax,ax
								rol	word ptr cs:bitplane_0,1	; Rotate
								adc	ax,ax
								call	extract_bitplane_bit
								call	extract_bitplane_bit
								stosb				; Store al to es:[di]
								loop	bitplane_pixels_loop		; Loop if cx > 0

		retn

bitplane_to_pixels		endp

extract_bitplane_bit		proc	near
		rol	word ptr cs:bitplane_2,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:bitplane_1,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:bitplane_0,1	; Rotate
		adc	ax,ax
		retn

extract_bitplane_bit		endp

		db	12 dup (0)

seg_a		ends

		end	start
