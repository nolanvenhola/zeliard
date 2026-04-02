
PAGE  59,132

;==========================================================================
;
;  GMCGA.BIN - CGA 4-Color Graphics Driver (Mode 5, 320x200)
;
;  CGA variant of the graphics driver API. Same functions as MCGA
;  but adapted for CGA's 4-color palette and interleaved memory layout.
;  CGA video memory at 0xB800, odd/even scanline interleaving.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; The following equates show data references outside the range of the program.

tile_src_base_b		equ	2751h			;*
anim_ptr_0		equ	0E200h			;*
anim_ptr_1		equ	0E202h			;*
anim_ptr_2		equ	0E206h			;*
anim_ptr_3		equ	0E20Ah			;*
anim_ptr_4		equ	0E20Ch			;*
tile_src_base	equ	217Fh			;*
plot_mode	equ	225Ch			;*
text_vga_ofs_a	equ	24E9h			;*
tile_color_tbl	equ	24EAh			;*
text_vga_ofs_b	equ	24ECh			;*
tile_color_tbl_b	equ	259Ah			;*
pixel_mask_tbl	equ	290Bh			;*
tile_offset_tbl	equ	2C11h			;*
tile_fg_mask	equ	2DE1h			;*
tile_bg_mask	equ	2DE2h			;*
char_color	equ	2DE3h			;*
char_src_ptr	equ	2DE4h			;*
char_bit_idx	equ	2DE6h			;*
bitplane_0	equ	2DE7h			;*
bitplane_1	equ	2DE9h			;*
bitplane_2	equ	2DEBh			;*
dispatch_mask_tbl	equ	2E22h			;*
dispatch_tbl	equ	5D21h			;*
tile_col_tbl	equ	6722h			;*
cga_wrap	equ	0C050h			;*
font_ptr_a	equ	0F500h			;*
font_ptr_b	equ	0F502h			;*
font_ptr_c	equ	0F504h			;*
palette_state	equ	0FF01h			;*
gvar_game_seg	equ	0FF2Ch			;*
zero_offset	equ	0			;*
cga_hud_ofs	equ	23Ch
cga_tile_stride	equ	18BCh

cga_seg		equ	0B800h			; CGA framebuffer segment

; Set ES to the CGA framebuffer segment (0xB800)
SET_CGA_ES	MACRO
		mov	ax, cga_seg
		mov	es, ax
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

gmcga		proc	far

start:
		inc	si
		db	20h, 0F0h		; and al, dh  (alt encoding: 20h r/m,r vs 22h r,r/m)
		and	ds:dispatch_tbl[bx],al
		and	dl,ds:tile_col_tbl[bx]
		and	ah,ds:dispatch_mask_tbl[bx+di]
		and	di,[si]
		and	di,[bp+si]
		and	al,44h			; 'D'
		and	al,61h			; 'a'
		and	al,81h
		and	al,0AAh
		and	al,2Ch			; ','
; Function dispatch table (21 word entries) followed by dispatch code.
; Entries are CS-relative addresses (driver loads at game_seg:2000h).
; First 42 bytes = 21 dw pointers; remaining = dispatch mechanism code.
		dw	0DB26h			; fn  0
		dw	0F526h			; fn  1
		dw	04B26h			; fn  2
		dw	0F529h			; fn  3
		dw	05629h			; fn  4
		dw	09C2Ah			; fn  5
		dw	0E42Ah			; fn  6
		dw	02F2Ah			; fn  7
		dw	0972Bh			; fn  8
		dw	0582Bh			; fn  9
		dw	0EF25h			; fn 10
		dw	00F24h			; fn 11
		dw	03027h			; fn 12
		dw	04A27h			; fn 13
		dw	01123h			; fn 14
		dw	02928h			; fn 15
		dw	01928h			; fn 16
		dw	0242Ch			; fn 17
		dw	06621h			; fn 18
		dw	0992Dh			; fn 19
		dw	0502Dh			; fn 20
; Coordinate-to-CGA-offset calculation + bordered row draw.
; Input: BL=col BH=row CL/CH=width/height.
; Calculates CGA byte offset: DI = (col/2 & 2000h) + col*80 + row
; then draws top border, middle rows, bottom border via fill_horizontal_line.
; JZ at byte 23 jumps to set_plot_mode (height=0 → init mode only).
		shr	bl,1
		sbb	di,di
		and	di,2000h
		mov	al,50h
		mul	bl
		add	di,ax
		mov	bl,bh
		xor	bh,bh
		add	di,bx
		pop	ax
		or	al,al
		jz	clear_screen_init
		push	di
		sub	cl,4
		add	di,50h
		call	clear_screen_init
		pop	di
		mov	ax,0F00Fh
		call	fill_horizontal_line
		mov	ax,0FC3Fh
		call	fill_horizontal_line
		push	cx
		push	bx
		mov	bl,ch
		dec	bl
		xor	bh,bh
		xor	ch,ch

init_vram_loop:
			mov	byte ptr es:[di],0F0h
			mov	byte ptr es:[bx+di],0Fh
			add	di,2000h
			cmp	di,4000h
			jb	cga_scanline_wrap			; Jump if below
			add	di,cga_wrap

cga_scanline_wrap:
			loop	init_vram_loop		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0FC3Fh
		call	fill_horizontal_line
		mov	ax,0F00Fh

gmcga		endp

;��������������������������������������������������������������������������

fill_horizontal_line		proc	near
		push	di
		or	es:[di],al
		inc	di
		mov	bh,ch
		sub	bh,2

hline_mid_scan:
			or	byte ptr es:[di],0FFh
			inc	di
			dec	bh
			jnz	hline_mid_scan			; Jump if not zero
		or	es:[di],ah
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_ret_4		; Jump if below
		add	di,0C050h

loc_ret_4:
		retn

fill_horizontal_line		endp

;��������������������������������������������������������������������������

clear_screen		proc	near
clear_screen_init:
		SET_CGA_ES
		mov	ah,cl

clear_row_loop:
			push	di
			push	cx
			mov	cl,ch
			xor	ch,ch			; Zero register
			xor	al,al			; Zero register
			rep	stosb			; Rep when cx >0 Store al to es:[di]
			pop	cx
			pop	di
			add	di,2000h
			cmp	di,4000h
			jb	clear_row_wrap			; Jump if below
			add	di,0C050h

clear_row_wrap:
			dec	ah
			jnz	clear_row_loop			; Jump if not zero
		retn

clear_screen		endp

			                        ;* No entry point to code
		SET_CGA_ES
		mov	di,cga_hud_ofs
		mov	cx,8

hud_clear_outer:
			push	cx
			push	di
			mov	cx,12h

hud_clear_inner:
				push	cx
				push	di
				mov	cx,38h
				xor	al,al			; Zero register
				rep	stosb			; Rep when cx >0 Store al to es:[di]
				pop	di
				add	di,140h
				pop	cx
				loop	hud_clear_inner		; Loop if cx > 0

			pop	di
			add	di,2000h
			cmp	di,4000h
			jb	hud_clear_wrap			; Jump if below
			add	di,0C050h

hud_clear_wrap:
			pop	cx
			loop	hud_clear_outer		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		SET_CGA_ES
		mov	si,tile_src_base
		mov	cx,8

hud_mask_outer:
			push	cx
			mov	di,cga_hud_ofs
			lodsb				; String [si] to al
			push	di
			mov	cx,48h

hud_mask_mid:
				push	cx
				mov	cx,38h

hud_mask_inner:
				and	es:[di],al
				inc	di
				loop	hud_mask_inner		; Loop if cx > 0

				rol	al,1			; Rotate
				rol	al,1			; Rotate
				rol	al,1			; Rotate
				pop	cx
				add	di,18h
				loop	hud_mask_mid		; Loop if cx > 0

			pop	di
			add	di,2000h
			cmp	di,4000h
			jb	hud_mask_wrap			; Jump if below
			add	di,cga_wrap

hud_mask_wrap:
			mov	cx,48h

hud_mask_mid2:
				push	cx
				mov	cx,38h

hud_mask_inner2:
				and	es:[di],al
				inc	di
				loop	hud_mask_inner2		; Loop if cx > 0

				rol	al,1			; Rotate
				rol	al,1			; Rotate
				rol	al,1			; Rotate
				pop	cx
				add	di,18h
				loop	hud_mask_mid2		; Loop if cx > 0

			mov	cx,3E80h

delay_loop:
				loop	delay_loop		; Loop if cx > 0

			pop	cx
			loop	hud_mask_outer		; Loop if cx > 0

		retn
; CGA pixel shade/dither table: descending bit-density patterns (7..0 bits set)
		db	0FEh,0EEh,0EAh,0AAh,0A8h, 88h	; 7,6,5,4,3,2 bits set per byte
		db	 80h, 00h			; 1,0 bits set

set_plot_mode:
		mov	cs:plot_mode,al
		SET_CGA_ES
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		mov	ax,50h
		mul	bl			; ax = reg * al
		add	di,ax
		mov	dl,bh
		and	bh,3
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		xor	dh,dh			; Zero register
		add	di,dx
		add	di,cga_tile_stride
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
		jz	plot_remainder_check			; Jump if zero

fill_mid_pixels:
			push	cx
			mov	ax,0FFFFh
			call	plot_pixel
			pop	cx
			inc	di
			dec	cl
			jnz	fill_mid_pixels			; Jump if not zero

plot_remainder_check:
		and	ch,3
		jnz	plot_last_pixels			; Jump if not zero
		retn

plot_last_pixels:
		mov	cl,ch
		shl	cl,1			; Shift w/zeros fill
		mov	ah,0FFh
		shr	ah,cl			; Shift w/zeros fill
		not	ah
		mov	al,ah

;��������������������������������������������������������������������������

plot_pixel		proc	near
		test	byte ptr cs:plot_mode,0FFh
		jnz	check_mode_80h			; Jump if not zero
		push	di
		not	ah
		mov	cx,9

plot_erase_loop:
			and	es:[di],ah
			add	di,2000h
			cmp	di,4000h
			jb	plot_erase_wrap			; Jump if below
			add	di,cga_wrap

plot_erase_wrap:
			loop	plot_erase_loop		; Loop if cx > 0

		and	es:[di],ah
		or	es:[di],al
		pop	di
		retn

check_mode_80h:
		cmp	byte ptr cs:plot_mode,80h
		je	plot_and_entry			; Jump if equal
		push	di
		mov	ah,al
		not	ah
		and	al,55h			; 'U'
		mov	cx,0Ah

plot_xor_loop:
			and	es:[di],ah
			or	es:[di],al
			add	di,2000h
			cmp	di,4000h
			jb	plot_xor_wrap			; Jump if below
			add	di,cga_wrap

plot_xor_wrap:
			loop	plot_xor_loop		; Loop if cx > 0

		pop	di
		retn

plot_and_entry:
		push	di
		not	al
		mov	cx,0Ah

plot_and_loop:
			and	es:[di],al
			add	di,2000h
			cmp	di,4000h
			jb	plot_and_wrap			; Jump if below
			add	di,0C050h

plot_and_wrap:
			loop	plot_and_loop		; Loop if cx > 0

		pop	di
		retn

plot_pixel		endp

		db	 00h,0BFh, 65h, 39h, 2Eh, 8Bh
		db	 1Eh,0B2h, 00h,0EBh, 05h,0BFh
		db	 45h, 3Bh,0EBh, 00h,0B8h, 00h
		db	0B8h, 8Eh,0C0h,0E8h, 7Eh, 00h
		db	50h

draw_vline_loop:
			or	bl,bl			; Zero ?
			jz	draw_vline_check			; Jump if zero
			push	di
			mov	bh,6
			mov	al,0AAh
			mov	ah,55h			; 'U'
			call	fill_vertical_line
			dec	bl
			pop	di
			inc	di
			jmp	short draw_vline_loop

draw_vline_check:
		pop	ax
		or	al,al			; Zero ?
		jnz	draw_hline_text			; Jump if not zero
		retn

draw_hline_text:
		and	al,0AAh
		mov	ah,55h			; 'U'
		mov	bh,6
		jmp	short vline_plot_loop
			                        ;* No entry point to code
		mov	di,3965h
		mov	bx,word ptr cs:[90h]
		jmp	short text_render_init
		db	0BFh, 45h, 3Bh,0EBh, 00h

text_render_init:
		SET_CGA_ES
		call	calc_text_width
		push	ax
		push	bx

text_char_loop:
			or	bl,bl			; Zero ?
			jz	text_remainder			; Jump if zero
			push	di
			mov	bh,5
			mov	al,55h			; 'U'
			mov	ah,0AAh
			call	fill_vertical_line
			dec	bl
			pop	di
			inc	di
			jmp	short text_char_loop

text_remainder:
		pop	bx
		pop	ax
		or	al,al			; Zero ?
		jz	text_height_check			; Jump if zero
		push	di
		mov	bh,5
		and	al,55h			; 'U'
		mov	ah,0AAh
		call	fill_vertical_line
		pop	di
		inc	di
		inc	bl

text_height_check:
		mov	bh,19h
		sub	bh,bl
		jnz	text_fill_loop			; Jump if not zero
		retn

text_fill_loop:
		mov	bl,bh

text_fill_line:
			push	di
			mov	bh,5
			xor	al,al			; Zero register
			mov	ah,0AAh
			call	fill_vertical_line
			pop	di
			inc	di
			dec	bl
			jnz	text_fill_line			; Jump if not zero
		retn

;��������������������������������������������������������������������������

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	text_width_clamped			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	cl,bl
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		and	cl,6
		mov	al,0FFh
		shr	al,cl			; Shift w/zeros fill
		not	al
		retn

text_width_clamped:
		mov	bx,19h
		xor	al,al			; Zero register
		retn

calc_text_width		endp

;��������������������������������������������������������������������������

fill_vertical_line		proc	near
vline_plot_loop:
			and	es:[di],ah
			or	es:[di],al
			add	di,2000h
			cmp	di,4000h
			jb	vline_wrap			; Jump if below
			add	di,0C050h

vline_wrap:
			dec	bh
			jnz	vline_plot_loop			; Jump if not zero
		retn

fill_vertical_line		endp

			                        ;* No entry point to code
		mov	byte ptr cs:tile_fg_mask,55h	; 'U'
		mov	byte ptr cs:tile_bg_mask,0AAh
		jmp	short text_coords_setup
			                        ;* No entry point to code
		mov	byte ptr cs:tile_fg_mask,0FFh
		mov	byte ptr cs:tile_bg_mask,0
		jmp	short text_coords_setup
			                        ;* No entry point to code
		mov	byte ptr cs:tile_fg_mask,0FFh
		mov	byte ptr cs:tile_bg_mask,0
		xor	dh,dh			; Zero register
		mov	dl,bh
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		add	di,dx
		mov	al,bl
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	di,ax
		mov	bl,cl
		SET_CGA_ES

text_string_loop:
			lodsb				; String [si] to al
			or	al,al			; Zero ?
			jnz	text_char_render			; Jump if not zero
			retn

text_char_render:
			push	bx
			push	ds
			push	si
			and	bl,3
			call	render_text_char
			pop	si
			pop	ds
			pop	bx
			inc	bl
			jmp	short text_string_loop

text_coords_setup:
		lodsb				; String [si] to al
		xor	dh,dh			; Zero register
		mov	dl,al
		lodsb				; String [si] to al
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		add	di,dx
		mov	cl,50h			; 'P'
		mul	cl			; ax = reg * al
		add	di,ax
		lodsb				; String [si] to al
		mov	bl,al
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		SET_CGA_ES

text_line_loop:
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
			loop	text_line_loop		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������

render_text_char		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		add	si,ds:font_ptr_c
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8

char_scan_loop:
			push	bx
			lodsb				; String [si] to al
			mov	dl,4

char_nibble_shift:
				add	ax,ax
				add	ah,ah
				dec	dl
				jnz	char_nibble_shift			; Jump if not zero
			mov	al,ah
			shr	ah,1			; Shift w/zeros fill
			or	al,ah
			xor	bl,bl			; Zero register
			mov	bh,al
			shr	bx,cl			; Shift w/zeros fill
			push	bx
			shr	bx,1			; Shift w/zeros fill
			shr	bx,1			; Shift w/zeros fill
			xchg	bh,bl
			not	bx
			and	es:[di],bx
			not	bx
			and	bh,ds:tile_bg_mask
			and	bl,ds:tile_bg_mask
			or	es:[di],bx
			pop	bx
			xchg	bh,bl
			not	bx
			and	es:[di],bx
			not	bx
			and	bh,ds:tile_fg_mask
			and	bl,ds:tile_fg_mask
			or	es:[di],bx
			add	di,2000h
			cmp	di,4000h
			jb	char_scan_wrap			; Jump if below
			add	di,0C050h

char_scan_wrap:
			pop	bx
			dec	bl
			jnz	char_scan_loop			; Jump if not zero
		pop	di
		inc	di
		cmp	cl,6
		je	char_skip_space			; Jump if equal
		retn

char_skip_space:
		inc	di
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
		mov	di,tile_color_tbl
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
		mov	di,text_vga_ofs_b
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		test	byte ptr cs:[93h],0FFh
		jnz	sprite_check			; Jump if not zero
		retn

sprite_check:
		push	ds
		mov	ax,word ptr cs:[94h]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,text_vga_ofs_b
		mov	cx,103h
		mov	ax,3EBBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn

;��������������������������������������������������������������������������

init_timestamp		proc	near
		mov	di,24E8h
		call	time_to_bcd
		mov	cx,6

timestamp_check_loop:
			test	byte ptr cs:[di],0FFh
			jz	timestamp_mark			; Jump if zero
			retn

timestamp_mark:
			mov	byte ptr cs:[di],0FFh
			inc	di
			loop	timestamp_check_loop		; Loop if cx > 0

		retn

init_timestamp		endp

		db	7 dup (0)

;��������������������������������������������������������������������������

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

;��������������������������������������������������������������������������

modulo_divide_bcd		proc	near
		xor	dh,dh			; Zero register

bcd_div_loop:
			sub	dl,cl
			jc	bcd_add_back			; Jump if carry Set
			sub	ax,bx
			jnc	bcd_dec_quotient			; Jump if carry=0
			or	dl,dl			; Zero ?
			jz	bcd_restore			; Jump if zero
			dec	dl

bcd_dec_quotient:
			inc	dh
			jmp	short bcd_div_loop

bcd_restore:
		add	ax,bx

bcd_add_back:
		add	dl,cl
		retn

modulo_divide_bcd		endp

;��������������������������������������������������������������������������

int_divide_bcd		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn

int_divide_bcd		endp

;��������������������������������������������������������������������������

render_tilemap_large		proc	near
		mov	ds:tile_bg_mask,bh
		xor	bh,bh			; Zero register
		mov	dl,ds:tile_color_tbl_b[bx]
		mov	ds:tile_fg_mask,dl
		shr	al,1			; Shift w/zeros fill
		sbb	bx,bx
		and	bx,2000h
		add	bl,ah
		mov	ah,50h			; 'P'
		mul	ah			; ax = reg * al
		add	bx,ax
		SET_CGA_ES

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
			mov	al,ch
			and	ax,1
			add	bx,ax
			inc	bx
			inc	ch
			dec	cl
			jnz	tile_render_loop			; Jump if not zero
		retn

render_tilemap_large		endp

		db	 00h,0FFh,0AAh,0FFh, 55h, 00h
		db	0FFh,0AAh

;��������������������������������������������������������������������������

decode_bitplane_tile		proc	near
		mov	bx,0Fh
		test	ch,1
		jz	tile_nibble_check			; Jump if zero
		mov	bx,0F000h

tile_nibble_check:
		test	byte ptr ds:tile_bg_mask,0FFh
		jz	tile_data_check			; Jump if zero
		push	di
		push	cx
		xchg	bh,bl
		mov	cx,7

tile_erase_loop:
			and	es:[di],bx
			add	di,2000h
			cmp	di,4000h
			jb	tile_erase_wrap			; Jump if below
			add	di,cga_wrap

tile_erase_wrap:
			loop	tile_erase_loop		; Loop if cx > 0

		pop	cx
		pop	di

tile_data_check:
		inc	al
		jnz	tile_decode_start			; Jump if not zero
		retn

tile_decode_start:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:font_ptr_b
		mov	si,ax
		push	cs
		pop	ds
		mov	cl,7

tile_font_loop:
			lodsb				; String [si] to al
			mov	ah,8

tile_bit_expand:
				add	al,al
				adc	dx,dx
				add	dx,dx
				dec	ah
				jnz	tile_bit_expand			; Jump if not zero
			mov	ax,dx
			shr	dx,1			; Shift w/zeros fill
			or	ax,dx
			test	ch,1
			jnz	tile_pos_adjust			; Jump if not zero
			add	ax,ax
			add	ax,ax
			add	ax,ax
			add	ax,ax

tile_pos_adjust:
			xchg	ah,al
			and	ah,cs:tile_fg_mask
			and	al,cs:tile_fg_mask
			or	es:[di],ax
			add	di,2000h
			cmp	di,4000h
			jb	tile_font_wrap			; Jump if below
			add	di,0C050h

tile_font_wrap:
			dec	cl
			jnz	tile_font_loop			; Jump if not zero
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
		shr	bl,1			; Shift w/zeros fill
		sbb	bp,bp
		and	bp,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	bp,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bp,bx
		SET_CGA_ES
		mov	cx,12h

large_tile_loop:
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
			mov	es:[bp],dh
			mov	es:[bp+1],dl
			mov	ax,[si+2]
			xchg	ah,al
			mov	cs:bitplane_0,ax
			mov	ax,[si+6]
			mov	cs:bitplane_1,ax
			mov	ax,[si+0Ch]
			xchg	ah,al
			mov	cs:bitplane_2,ax
			call	extract_bitplane_pixels
			mov	es:[bp+2],dh
			mov	es:[bp+3],dl
			xor	al,al			; Zero register
			mov	ah,[si+4]
			mov	cs:bitplane_0,ax
			mov	ah,[si+5]
			mov	cs:bitplane_1,ax
			mov	ah,[si+0Eh]
			mov	cs:bitplane_2,ax
			call	extract_bitplane_pixels
			mov	es:[bp+4],dh
			add	si,0Fh
			add	bp,2000h
			cmp	bp,4000h
			jb	large_tile_wrap			; Jump if below
			add	bp,0C050h

large_tile_wrap:
			pop	cx
			loop	large_tile_loop		; Loop if cx > 0

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
		mov	si,tile_src_base_b
		or	al,al			; Zero ?
		jz	anim_ptr4_check			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_4
		mov	si,ax

anim_ptr4_check:
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,tile_src_base_b
		or	al,al			; Zero ?
		jz	anim_ptr3_check			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_3
		mov	si,ax

anim_ptr3_check:
		call	render_tilemap_small
		pop	ds
		retn
; CGA 2-bitplane tile bitmap data (patterns for render_tilemap_large):
; Each pair of rows (6 bytes each) encodes one tile line in 2 CGA planes.
		db	 00h, 00h, 00h, 00h,0FCh,0FFh
		db	0FFh, 3Fh, 2Ah,0AAh,0AAh,0A8h
		db	 00h, 00h, 00h, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 00h, 00h, 02h
		db	 0Eh, 38h,0F8h, 00h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 08h, 02h
		db	 0Fh,0BBh, 8Eh, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 88h, 82h, 02h
		db	 0Fh,0FBh, 8Eh, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 08h, 82h, 02h
		db	 0Eh,0FBh, 8Eh, 00h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 82h, 02h
		db	 0Eh, 38h,0F8h, 00h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 08h, 02h
		db	 00h, 00h, 00h, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 00h, 00h, 02h
		db	 00h, 00h, 00h, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 00h, 00h, 02h
		db	 0Eh, 38h,0FBh,0F8h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 08h, 0Ah
		db	 0Eh, 3Bh, 83h, 80h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 80h, 82h
		db	 0Eh, 38h,0E3h,0C0h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 20h, 02h
		db	 0Eh, 38h, 3Bh, 80h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 08h, 82h
		db	 03h,0E3h,0E3h,0F8h, 03h, 00h
		db	 00h,0C0h, 80h, 20h, 20h, 0Ah
		db	 00h, 00h, 00h, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 00h, 00h, 02h
		db	 00h, 00h, 00h, 00h,0FCh,0FFh
		db	0FFh, 3Fh, 2Ah,0AAh,0AAh,0A8h
; Sprite source selector A: computes SI from row*192 + game_seg:[E208h], calls render_tilemap_small+2
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
; Sprite source selector B: same but uses base [E204h] and calls render_tilemap_small  (+2)
		push	ds
		mov	ds,cs:[gvar_game_seg]	; switch to game data segment
		xor	ah,ah
		mov	cx,0C0h
		mul	cx
		add	ax,ds:[0E204h]		; + sprite base B in game segment
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn

;��������������������������������������������������������������������������

render_tilemap_small		proc	near
		shr	bl,1			; Shift w/zeros fill
		sbb	bp,bp
		and	bp,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	bp,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bp,bx
		SET_CGA_ES
		mov	cx,10h

small_tile_loop:
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
			mov	ax,dx
			mov	dx,[si+2]
			xchg	dh,dl
			mov	cs:bitplane_0,dx
			mov	dx,[si+4]
			mov	cs:bitplane_1,dx
			mov	dx,[si+0Ah]
			xchg	dh,dl
			mov	cs:bitplane_2,dx
			call	extract_bitplane_pixels
			xor	bl,bl			; Zero register
			mov	cx,4

small_tile_shift:
				shr	ax,1			; Shift w/zeros fill
				rcr	dx,1			; Rotate thru carry
				rcr	bl,1			; Rotate thru carry
				loop	small_tile_shift		; Loop if cx > 0

			mov	es:[bp],ah
			mov	es:[bp+1],al
			mov	es:[bp+2],dh
			mov	es:[bp+3],dl
			mov	es:[bp+4],bl
			add	si,0Ch
			add	bp,2000h
			cmp	bp,4000h
			jb	small_tile_wrap			; Jump if below
			add	bp,0C050h

small_tile_wrap:
			pop	cx
			loop	small_tile_loop		; Loop if cx > 0

		retn

render_tilemap_small		endp

;��������������������������������������������������������������������������

extract_bitplane_pixels		proc	near
		mov	cx,8

bitplane_extract_loop:
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
			or	dl,cs:pixel_mask_tbl[bx]
			loop	bitplane_extract_loop		; Loop if cx > 0

		retn

extract_bitplane_pixels		endp

; pixel_mask_tbl: 3-bit bitplane index (0-7) → CGA 2-bit color (0=black,1=cyan,2=magenta,3=white)
; Indexed by bx (accumulated from bitplane_2 msb, bitplane_1 msb, bitplane_0 msb × 2)
		db	0, 1, 2, 1, 1, 0	; indices 0x00-0x05
		db	3, 2, 1, 3, 3, 3	; indices 0x06-0x0B
		db	1, 3, 3, 2, 2, 3	; indices 0x0C-0x11
		db	2, 1, 1, 2, 2, 2	; indices 0x12-0x17
		db	1, 3, 1, 3, 1, 1	; indices 0x18-0x1D
		db	2, 2, 1, 1, 1, 1	; indices 0x1E-0x23
		db	1, 1, 3, 2, 0, 3	; indices 0x24-0x29
		db	2, 1, 1, 1, 3, 2	; indices 0x2A-0x2F
		db	3, 3, 2, 2, 3, 3	; indices 0x30-0x35
		db	3, 2, 1, 2, 2, 2	; indices 0x36-0x3B
		db	2, 2, 2, 2		; indices 0x3C-0x3F

;��������������������������������������������������������������������������

render_text_char_alt		proc	near
		push	ds
		push	cs
		pop	ds
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,ds:tile_color_tbl_b[bx]
		mov	ds:tile_fg_mask,ah
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
		mov	ds:tile_bg_mask,al
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	cl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	cl			; ax = reg * al
		add	ax,bx
		add	di,ax
		pop	si
		SET_CGA_ES
		mov	cx,8

alt_char_scan_loop:
			push	cx
			lodsb				; String [si] to al
			call	expand_font_bits
			mov	cl,cs:tile_bg_mask
			mov	ah,dl
			xor	dl,dl			; Zero register
			mov	al,dl
			shr	dx,cl			; Shift w/zeros fill
			shr	ax,cl			; Shift w/zeros fill
			or	dl,ah
			mov	ch,al
			xchg	dh,dl
			mov	bx,dx
			mov	cl,ch
			not	bx
			not	cl
			and	es:[di],bx
			and	es:[di+2],cl
			and	dl,cs:tile_fg_mask
			and	dh,cs:tile_fg_mask
			and	ch,cs:tile_fg_mask
			or	es:[di],dx
			or	es:[di+2],ch
			pop	cx
			add	di,2000h
			cmp	di,4000h
			jb	alt_char_wrap			; Jump if below
			add	di,0C050h

alt_char_wrap:
			loop	alt_char_scan_loop		; Loop if cx > 0

		pop	ds
		retn

render_text_char_alt		endp

;��������������������������������������������������������������������������

expand_font_bits		proc	near
		mov	cx,8

font_bit_expand_loop:
			add	al,al
			adc	bx,bx
			add	bx,bx
			loop	font_bit_expand_loop		; Loop if cx > 0

		mov	dx,bx
		shr	dx,1			; Shift w/zeros fill
		or	dx,bx
		retn

expand_font_bits		endp

			                        ;* No entry point to code
		push	ds
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		add	di,ax
		mov	si,di
		add	si,2000h
		cmp	si,4000h
		jb	copy_scan_wrap			; Jump if below
		add	si,cga_wrap

copy_scan_wrap:
		SET_CGA_ES
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

copy_scan_loop:
			push	cx
			push	di
			push	si
			mov	cx,bx
			rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
			pop	si
			pop	di
			add	di,2000h
			cmp	di,4000h
			jb	copy_di_wrap			; Jump if below
			add	di,cga_wrap

copy_di_wrap:
			add	si,2000h
			cmp	si,4000h
			jb	copy_si_wrap			; Jump if below
			add	si,cga_wrap

copy_si_wrap:
			pop	cx
			loop	copy_scan_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		add	di,0
		shr	al,1			; Shift w/zeros fill
		sbb	si,si
		and	si,2000h
		mov	bl,ah
		mov	bh,50h			; 'P'
		mul	bh			; ax = reg * al
		add	si,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	si,bx
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,0B800h
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

copy_words_loop:
			push	cx
			push	si
			mov	cx,bx
			rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
			pop	si
			add	si,2000h
			cmp	si,4000h
			jb	copy_words_wrap			; Jump if below
			add	si,cga_wrap

copy_words_wrap:
			pop	cx
			loop	copy_words_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,di
		add	si,0
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	bl,ah
		mov	bh,50h			; 'P'
		mul	bh			; ax = reg * al
		add	di,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	di,bx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		SET_CGA_ES
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

vram_copy_loop:
			push	cx
			push	di
			mov	cx,bx
			rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
			pop	di
			add	di,2000h
			cmp	di,4000h
			jb	vram_copy_wrap			; Jump if below
			add	di,0C050h

vram_copy_wrap:
			pop	cx
			loop	vram_copy_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	cs:char_src_ptr,bx
		mov	cs:char_bit_idx,cl
		mov	byte ptr cs:char_color,1

char_cmd_loop:
				lodsb				; String [si] to al
				cmp	al,0FFh
				jne	char_terminator_check			; Jump if not equal
				retn

char_terminator_check:
				cmp	al,0Dh
				je	handle_newline			; Jump if equal
				or	al,al			; Zero ?
				js	handle_color_code			; Jump if sign=1
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

handle_color_code:
			and	al,7
			mov	cs:char_color,al
			jmp	short char_cmd_loop
			                        ;* No entry point to code
		push	ds
		shr	bl,1			; Shift w/zeros fill
		sbb	si,si
		and	si,2000h
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		add	si,ax
		shr	dl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	ax,50h
		mul	dl			; ax = reg * al
		mov	dl,dh
		xor	dh,dh			; Zero register
		add	dx,dx
		add	ax,dx
		add	di,ax
		SET_CGA_ES
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

buf_copy_loop:
			push	cx
			push	di
			push	si
			mov	cx,bx
			rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
			pop	si
			pop	di
			add	di,2000h
			cmp	di,4000h
			jb	buf_copy_di_wrap			; Jump if below
			add	di,cga_wrap

buf_copy_di_wrap:
			add	si,2000h
			cmp	si,4000h
			jb	buf_copy_si_wrap			; Jump if below
			add	si,0C050h

buf_copy_si_wrap:
			pop	cx
			loop	buf_copy_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	al,ds:tile_offset_tbl[bx]
		mov	ds:tile_fg_mask,al
		pop	bx
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		SET_CGA_ES
		call	fill_rectangle
		mov	cx,10h

tile_remap_loop:
			mov	al,ds:tile_fg_mask
			and	al,0F0h
			and	byte ptr es:[di],0Fh
			or	es:[di],al
			mov	al,ds:tile_fg_mask
			and	al,0Fh
			and	byte ptr es:[di+4],0F0h
			or	es:[di+4],al
			add	di,2000h
			cmp	di,4000h
			jb	tile_remap_wrap			; Jump if below
			add	di,cga_wrap

tile_remap_wrap:
			loop	tile_remap_loop		; Loop if cx > 0

		call	fill_rectangle
		retn

;��������������������������������������������������������������������������

fill_rectangle		proc	near
		mov	cx,2

rect_fill_loop:
			push	cx
			push	di
			mov	al,ds:tile_fg_mask
			mov	cx,5
			rep	stosb			; Rep when cx >0 Store al to es:[di]
			pop	di
			add	di,2000h
			cmp	di,4000h
			jb	rect_fill_wrap			; Jump if below
			add	di,0C050h

rect_fill_wrap:
			pop	cx
			loop	rect_fill_loop		; Loop if cx > 0

		retn

fill_rectangle		endp

		db	 00h,0FFh,0AAh,0FFh, 55h,0FFh
		db	0FFh,0AAh, 1Eh, 56h, 0Eh, 1Fh
		db	 32h,0E4h, 03h,0C0h, 03h,0C0h
		db	 8Bh,0F0h,0D0h,0EBh, 1Bh,0FFh
		db	 81h,0E7h, 00h, 20h,0B0h, 50h
		db	0F6h,0E3h, 03h,0F8h, 8Ah,0DFh
		db	 32h,0FFh, 03h,0FBh,0B8h, 00h
		db	0B8h, 8Eh,0C0h, 8Bh, 9Ch, 8Eh
		db	 2Ch, 8Bh,0B4h, 90h, 2Ch,0B9h
		db	 0Dh, 00h

deco_draw_loop:
			push	cx
			mov	al,[bx]
			and	es:[di],al
			mov	al,[bx+1]
			and	es:[di+1],al
			mov	al,[bx+2]
			and	es:[di+2],al
			mov	al,[bx+3]
			and	es:[di+3],al
			lodsb				; String [si] to al
			or	es:[di],al
			lodsb				; String [si] to al
			or	es:[di+1],al
			lodsb				; String [si] to al
			or	es:[di+2],al
			lodsb				; String [si] to al
			or	es:[di+3],al
			add	bx,4
			add	di,2000h
			cmp	di,4000h
			jb	deco_draw_wrap			; Jump if below
			add	di,cga_wrap

deco_draw_wrap:
			pop	cx
			loop	deco_draw_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn
; Sprite animation frame pointer table (4 CS-relative word offsets into sprite data):
		dw	2C96h			; frame 0: CS:2C96h (driver offset 0C96h)
		dw	2CFEh			; frame 1: CS:2CFEh (driver offset 0CFEh)
		dw	2CCAh			; frame 2: CS:2CCAh (driver offset 0CCAh)
		dw	2D32h			; frame 3: CS:2D32h (driver offset 0D32h)
; Sprite bitplane bitmap data for all 4 animation frames:
		db	0FFh,0F0h, 0Ch,0FFh
		db	0FFh,0C0h, 00h,0FFh,0FFh, 00h
		db	 00h,0FFh,0FFh, 00h, 00h,0FFh
		db	0FFh, 00h, 00h,0FFh,0FFh, 00h
		db	 00h,0FFh,0FFh, 00h, 00h,0FFh
		db	0FFh,0C0h, 00h,0FFh,0FFh,0C0h
		db	 00h,0FFh,0FFh,0C0h, 00h,0FFh
		db	0FFh,0CCh, 0Ch,0FFh
		db	9 dup (0FFh)
		db	 00h, 00h,0FFh,0FCh, 00h, 00h
		db	 3Fh,0F0h, 00h, 00h, 0Fh,0F0h
		db	 00h, 00h, 0Fh,0C0h, 00h, 00h
		db	 03h,0C0h, 00h, 00h, 03h,0C0h
		db	 00h, 00h, 03h,0C0h, 00h, 00h
		db	 03h,0F0h, 00h, 00h, 0Fh,0F0h
		db	 00h, 00h, 0Fh,0FCh, 00h, 00h
		db	 3Fh,0FFh, 00h, 00h,0FFh,0FFh
		db	0C0h, 03h,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 0Ah,0A0h, 00h, 00h
		db	 3Bh,0F8h, 00h, 00h, 2Fh,0D6h
		db	 00h, 00h,0E7h,0D6h, 00h, 00h
		db	0E5h, 56h, 00h, 00h,0A5h, 56h
		db	 00h, 00h, 25h, 56h, 00h, 00h
		db	 29h, 58h, 00h, 00h, 0Ah,0A0h
		db	 00h, 00h
		db	12 dup (0)
		db	 3Fh,0D4h, 00h, 00h,0F0h, 05h
		db	 00h, 03h,0CFh,0C1h, 40h, 0Fh
		db	 3Fh, 0Ch, 50h, 0Fh,0FCh, 03h
		db	 50h, 0Ch,0F0h,0A0h, 10h, 0Ch
		db	0C2h,0AAh, 90h, 0Dh,0EAh,0AAh
		db	0D0h, 0Dh,0BAh,0AAh,0F0h, 01h
		db	 6Bh,0ABh,0C0h, 00h, 58h,0AFh
		db	 00h, 00h, 1Dh, 54h, 00h, 00h
; CGA init stub: initializes ES=0B800h, DI=0, CX=8, then falls into vram_init_outer
		db	00h, 00h, 00h	; sprite data tail padding
		SET_CGA_ES		; mov ax, 0B800h / mov es, ax
		xor	di,di
		mov	cx,8

vram_init_outer:
			push	cx
			push	di
			mov	cx,19h

vram_init_inner:
				push	cx
				push	di
				mov	cx,28h
				xor	ax,ax			; Zero register
				rep	stosw			; Rep when cx >0 Store ax to es:[di]
				pop	di
				add	di,140h
				pop	cx
				loop	vram_init_inner		; Loop if cx > 0

			pop	di
			add	di,2000h
			cmp	di,4000h
			jb	vram_init_wrap			; Jump if below
			add	di,0C050h

vram_init_wrap:
			pop	cx
			loop	vram_init_outer		; Loop if cx > 0

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

sprite_row_loop:
			push	cx
			call	process_sprite_row
			pop	cx
			loop	sprite_row_loop		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������

process_sprite_row		proc	near
		mov	cx,8

sprite_bitplane_loop:
			push	cx
			lodsw				; String [si] to ax
			mov	cs:bitplane_0,ax
			lodsw				; String [si] to ax
			mov	cs:bitplane_1,ax
			lodsw				; String [si] to ax
			mov	cs:bitplane_2,ax
			call	extract_bitplane_pixels
			mov	ax,dx
			stosw				; Store ax to es:[di]
			pop	cx
			loop	sprite_bitplane_loop		; Loop if cx > 0

		retn

process_sprite_row		endp

		db	12 dup (0)

seg_a		ends

		end	start
