
PAGE  59,132

;==========================================================================
;
;  GMTGA.BIN - Tandy Graphics Adapter 16-Color Driver (Mode 9, 320x200)
;
;  TGA variant of the graphics driver API. Uses Tandy's linear 16-color
;  framebuffer with nibble-packed pixels (2 pixels per byte).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

anim_ptr_0	equ	0E200h			;*
anim_ptr_1	equ	0E202h			;*
anim_ptr_2	equ	0E206h			;*
anim_ptr_3	equ	0E20Ah			;*
anim_ptr_4	equ	0E20Ch			;*
tile_src_base	equ	21A7h			;*
plot_mode	equ	22A6h			;*
tile_color_tbl	equ	262Eh			;*
pixel_mask_tbl	equ	2999h			;*
tile_offset_tbl	equ	2CB7h			;*
tile_color_tbl_b equ	2CB9h			;*
tile_fg_mask	equ	2E6Ch			;*
tile_bg_mask	equ	2E6Dh			;*
char_color	equ	2E6Eh			;*
char_src_ptr	equ	2E6Fh			;*
char_bit_idx	equ	2E71h			;*
bitplane_0	equ	2E72h			;*
bitplane_1	equ	2E74h			;*
bitplane_2	equ	2E76h			;*
tga_wrap	equ	80A0h			;*
dispatch_tbl	equ	0A721h			;*
tile_col_tbl	equ	0EB22h			;*
font_ptr_a	equ	0F500h			;*
font_ptr_b	equ	0F502h			;*
font_ptr_c	equ	0F504h			;*
palette_state	equ	0FF01h			;*
gvar_game_seg	equ	0FF2Ch			;*
zero_offset	equ	0			;*
tga_hud_ofs	equ	41F8h

driver_base	equ	2000h			; driver loads at game_seg:2000h
tga_seg		equ	80A0h			; Tandy framebuffer segment (0x8000 area)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

gmtga		proc	far

start:
		inc	si
		db	 20h,0F0h		; and al, dh  (alt encoding: 20h r/m,r vs 22h r,r/m)
		and	ds:dispatch_tbl[bx],dh
		and	ah,cl
		and	dh,ds:tile_col_tbl[bx+di]
		and	bh,[bx+si+23h]
		xchg	[bp+di],ah
; Function dispatch table (27 word entries) followed by dispatch mechanism code.
; Entries are CS-relative addresses (driver loads at game_seg:2000h).
		dw	024DCh			; fn  0
		dw	024E6h			; fn  1
		dw	02503h			; fn  2
		dw	02523h			; fn  3
		dw	0254Ch			; fn  4
		dw	026B0h			; fn  5
		dw	02771h			; fn  6
		dw	0278Bh			; fn  7
		dw	029D9h			; fn  8
		dw	02A68h			; fn  9
		dw	02ABBh			; fn 10
		dw	02B0Fh			; fn 11
		dw	02B65h			; fn 12
		dw	02BAEh			; fn 13
		dw	02BFCh			; fn 14
		dw	025FAh			; fn 15
		dw	02591h			; fn 16
		dw	027A5h			; fn 17
		dw	027C6h			; fn 18
		dw	02394h			; fn 19
		dw	028A7h			; fn 20
		dw	028BFh			; fn 21
		dw	02C5Bh			; fn 22
		dw	02124h			; fn 23
		dw	02DC3h			; fn 24
		dw	02DF6h			; fn 25
		dw	00250h			; fn 26
; Dispatch mechanism: lookup BX in table, jump to target, handle DI bank-select wrap.
		db	0FFh,0E8h, 02h, 0Eh, 8Bh,0F8h
		db	 58h, 0Ah,0C0h, 74h, 77h, 57h
		db	 80h,0E9h, 04h, 81h,0C7h, 00h
		db	 40h, 81h,0FFh, 00h, 80h, 72h
		db	 04h, 81h,0C7h,0A0h, 80h
init_draw_border:
		call	clear_screen
		pop	di
		mov	ax,0
		call	fill_horizontal_line
		mov	ax,0F00Fh
		call	fill_horizontal_line
		push	cx
		push	bx
		mov	bl,ch
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

border_row_loop:
		mov	byte ptr es:[di],0FFh
		mov	byte ptr es:[bx+di+1],0FFh
		add	di,2000h
		cmp	di,8000h
		jb	border_row_wrap		; Jump if below
		add	di,tga_wrap
border_row_wrap:
		loop	border_row_loop		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0F00Fh
		call	fill_horizontal_line
		mov	ax,0

gmtga		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_horizontal_line		proc	near
		push	di
		or	es:[di],al
		inc	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		dec	cx
		add	cx,cx
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	es:[di],ah
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	fhl_wrap_done		; Jump if below
		add	di,80A0h

fhl_wrap_done:
		retn
fill_horizontal_line		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

clear_screen		proc	near
clear_seg_init:
		mov	ax,0B800h
		mov	es,ax
		push	cx
clear_row_loop:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	clear_row_wrap			; Jump if below
		add	di,80A0h
clear_row_wrap:
		dec	cl
		jnz	clear_row_loop			; Jump if not zero
		pop	cx
		retn
clear_screen		endp

			                        ;* No entry point to code
		mov	ax,0B800h
		mov	es,ax
		mov	di,tga_hud_ofs
		mov	cx,8

hud_clear_pass_loop:
		push	cx
		push	di
		mov	cx,12h

hud_clear_row_loop:
		push	cx
		push	di
		mov	cx,38h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		add	di,140h
		pop	cx
		loop	hud_clear_row_loop		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	hud_clear_wrap			; Jump if below
		add	di,80A0h
hud_clear_wrap:
		pop	cx
		loop	hud_clear_pass_loop		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	ax,0B800h
		mov	es,ax
		mov	si,tile_src_base
		mov	cx,8

tile_mask_pass_loop:
		push	cx
		mov	di,tga_hud_ofs
		lodsw				; String [si] to ax
		push	di
		mov	cx,48h

tile_mask_row_loop_a:
		push	cx
		push	di
		mov	cx,38h

tile_mask_inner_a:
		and	es:[di],ax
		inc	di
		inc	di
		loop	tile_mask_inner_a		; Loop if cx > 0

		pop	di
		add	di,4000h
		cmp	di,8000h
		jb	tile_mask_wrap_a			; Jump if below
		add	di,80A0h
tile_mask_wrap_a:
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		pop	cx
		loop	tile_mask_row_loop_a		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	tile_mask_wrap_b			; Jump if below
		add	di,tga_wrap
tile_mask_wrap_b:
		mov	cx,48h

tile_mask_row_loop_b:
		push	cx
		push	di
		mov	cx,38h

tile_mask_inner_b:
		and	es:[di],ax
		inc	di
		inc	di
		loop	tile_mask_inner_b		; Loop if cx > 0

		pop	di
		pop	cx
		add	di,4000h
		cmp	di,8000h
		jb	tile_mask_wrap_c			; Jump if below
		add	di,tga_wrap
tile_mask_wrap_c:
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		loop	tile_mask_row_loop_b		; Loop if cx > 0

		mov	cx,3E80h

delay_loop:
		loop	delay_loop		; Loop if cx > 0

		pop	cx
		loop	tile_mask_pass_loop		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		cld				; Clear direction
		db	0FFh,0FCh,0FCh,0CCh,0FCh,0CCh
		db	0CCh,0C0h,0CCh,0C0h,0C0h, 00h
		db	0C0h, 00h, 00h
draw_sprite_entry:
		mov	cs:plot_mode,al
		mov	ax,0B800h
		mov	es,ax
		add	bl,9Eh
		mov	dh,bl
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		mov	ax,0A0h
		mul	bl			; ax = reg * al
		add	ax,dx
		mov	di,ax
		mov	dl,bh
		and	bh,1
		shr	dl,1			; Shift w/zeros fill
		add	dl,18h
		xor	dh,dh			; Zero register
		add	di,dx
		mov	cl,bh
		add	cl,cl
		add	cl,cl
		mov	ax,0FF0Fh
		shr	ah,cl			; Shift w/zeros fill
		shr	al,cl			; Shift w/zeros fill
		neg	bh
		add	bh,1
		sub	ch,bh
		push	cx
		call	plot_pixel
		pop	cx
		inc	di
		mov	cl,ch
		shr	cl,1			; Shift w/zeros fill
		test	cl,0FFh
		jz	draw_pixel_done			; Jump if zero
draw_pixel_loop:
		push	cx
		mov	ax,0FFFFh
		call	plot_pixel
		pop	cx
		inc	di
		dec	cl
		jnz	draw_pixel_loop			; Jump if not zero
draw_pixel_done:
		and	ch,1
		jnz	draw_pixel_partial			; Jump if not zero
		retn
draw_pixel_partial:
		mov	cl,ch
		add	cl,cl
		add	cl,cl
		mov	ah,0FFh
		shr	ah,cl			; Shift w/zeros fill
		not	ah
		mov	al,ah

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

plot_pixel		proc	near
		test	byte ptr cs:plot_mode,0FFh
		jnz	plot_mode_check			; Jump if not zero
		push	di
		not	ah
		mov	dl,al
		and	dl,11h
		mov	cx,9

plot_pixel_loop:
		and	es:[di],ah
		or	es:[di],dl
		add	di,2000h
		cmp	di,8000h
		jb	plot_pixel_wrap			; Jump if below
		add	di,tga_wrap
plot_pixel_wrap:
		loop	plot_pixel_loop		; Loop if cx > 0

		and	es:[di],ah
		and	al,99h
		or	es:[di],al
		pop	di
		retn
plot_mode_check:
		cmp	byte ptr cs:plot_mode,80h
		je	plot_erase_mode			; Jump if equal
		push	di
		mov	ah,al
		not	ah
		and	al,77h			; 'w'
		mov	cx,0Ah

plot_and_loop:
		and	es:[di],ah
		or	es:[di],al
		add	di,2000h
		cmp	di,8000h
		jb	plot_and_wrap			; Jump if below
		add	di,tga_wrap
plot_and_wrap:
		loop	plot_and_loop		; Loop if cx > 0

		pop	di
		retn
plot_erase_mode:
		push	di
		not	al
		mov	cx,0Ah

plot_erase_loop:
		and	es:[di],al
		add	di,2000h
		cmp	di,8000h
		jb	plot_erase_wrap			; Jump if below
		add	di,80A0h
plot_erase_wrap:
		loop	plot_erase_loop		; Loop if cx > 0

		pop	di
		retn
plot_pixel		endp

		db	 00h,0BFh, 2Ah, 79h, 2Eh, 8Bh
		db	 1Eh,0B2h, 00h,0EBh, 05h,0BFh
		db	 0Ah, 7Bh,0EBh, 00h,0B8h, 00h
		db	0B8h, 8Eh,0C0h,0E8h, 7Eh, 00h
		db	50h
draw_cols_loop:
		or	bl,bl			; Zero ?
		jz	draw_cols_done			; Jump if zero
		push	di
		mov	bh,6
		mov	al,44h			; 'D'
		mov	ah,33h			; '3'
		call	fill_vertical_line
		dec	bl
		pop	di
		inc	di
		jmp	short draw_cols_loop
draw_cols_done:
		pop	ax
		or	al,al			; Zero ?
		jnz	draw_partial_col			; Jump if not zero
		retn
draw_partial_col:
		and	al,44h			; 'D'
		mov	ah,33h			; '3'
		mov	bh,6
		jmp	short fvl_loop
			                        ;* No entry point to code
		mov	di,792Ah
		mov	bx,word ptr cs:[90h]
		jmp	short draw_entry_b
		db	0BFh, 0Ah, 7Bh,0EBh, 00h
draw_entry_b:
		mov	ax,0B800h
		mov	es,ax
		call	calc_text_width
		push	ax
		push	bx
draw_cols_loop_b:
		or	bl,bl			; Zero ?
		jz	draw_cols_done_b			; Jump if zero
		push	di
		mov	bh,5
		mov	al,0AAh
		mov	ah,0FFh
		call	fill_vertical_line
		dec	bl
		pop	di
		inc	di
		jmp	short draw_cols_loop_b
draw_cols_done_b:
		pop	bx
		pop	ax
		or	al,al			; Zero ?
		jz	draw_pad_start			; Jump if zero
		push	di
		mov	bh,5
		and	al,0AAh
		mov	ah,0FFh
		call	fill_vertical_line
		pop	di
		inc	di
		inc	bl
draw_pad_start:
		mov	bh,32h			; '2'
		sub	bh,bl
		jnz	draw_pad_loop_start			; Jump if not zero
		retn
draw_pad_loop_start:
		mov	bl,bh
draw_pad_loop:
		push	di
		mov	bh,5
		xor	al,al			; Zero register
		mov	ah,44h			; 'D'
		call	fill_vertical_line
		pop	di
		inc	di
		dec	bl
		jnz	draw_pad_loop			; Jump if not zero
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	text_too_wide			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	cl,bl
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		and	cl,2
		add	cl,cl
		mov	al,0FFh
		shr	al,cl			; Shift w/zeros fill
		not	al
		retn
text_too_wide:
		mov	bx,32h
		xor	al,al			; Zero register
		retn
calc_text_width		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_vertical_line		proc	near
fvl_loop:
		and	es:[di],ah
		or	es:[di],al
		add	di,2000h
		cmp	di,8000h
		jb	fvl_wrap			; Jump if below
		add	di,80A0h
fvl_wrap:
		dec	bh
		jnz	fvl_loop			; Jump if not zero
		retn
fill_vertical_line		endp

			                        ;* No entry point to code
		mov	byte ptr cs:tile_fg_mask,0AAh
		mov	byte ptr cs:tile_bg_mask,44h	; 'D'
		jmp	short text_entry_xy
			                        ;* No entry point to code
		mov	byte ptr cs:tile_fg_mask,0FFh
		mov	byte ptr cs:tile_bg_mask,88h
		jmp	short text_entry_xy
			                        ;* No entry point to code
		mov	byte ptr cs:tile_fg_mask,0FFh
		mov	byte ptr cs:tile_bg_mask,0
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	bl,cl
		shr	bx,1			; Shift w/zeros fill
		and	bx,1
		add	di,bx
		mov	bl,cl
		mov	ax,0B800h
		mov	es,ax
text_render_loop:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	text_render_char			; Jump if not zero
		retn
text_render_char:
		push	bx
		push	ds
		push	si
		and	bl,1
		call	render_text_char
		pop	si
		pop	ds
		pop	bx
		inc	bl
		jmp	short text_render_loop
text_entry_xy:
		lodsb				; String [si] to al
		mov	bh,al
		add	bh,bh
		lodsb				; String [si] to al
		mov	bl,al
		call	bitplane_to_pixels
		mov	di,ax
		lodsb				; String [si] to al
		mov	bl,al
		shr	ax,1			; Shift w/zeros fill
		and	ax,1
		add	di,ax
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		mov	ax,0B800h
		mov	es,ax

text_char_row_loop:
		push	cx
		lodsb				; String [si] to al
		push	bx
		push	ds
		push	si
		and	bl,1
		call	render_text_char
		pop	si
		pop	ds
		pop	bx
		inc	bl
		pop	cx
		loop	text_char_row_loop		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
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
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8
char_row_loop:
		push	bx
		lodsb				; String [si] to al
		call	extract_bitplane_bit
		push	ax
		call	extract_bitplane_bit
		pop	bx
		mov	bl,ah
		mov	dh,bl
		xor	dl,dl			; Zero register
		shr	bx,cl			; Shift w/zeros fill
		shr	dx,cl			; Shift w/zeros fill
		mov	dh,dl
		xor	dl,dl			; Zero register
		push	bx
		push	dx
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		sbb	al,al
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		and	al,0F0h
		or	dh,al
		xchg	bh,bl
		xchg	dh,dl
		not	bx
		not	dx
		and	es:[di],bx
		and	es:[di+2],dx
		not	bx
		not	dx
		and	bh,ds:tile_bg_mask
		and	bl,ds:tile_bg_mask
		and	dh,ds:tile_bg_mask
		and	dl,ds:tile_bg_mask
		or	es:[di],bx
		or	es:[di+2],dx
		pop	dx
		pop	bx
		xchg	bh,bl
		xchg	dh,dl
		not	bx
		not	dx
		and	es:[di],bx
		and	es:[di+2],dx
		not	bx
		not	dx
		and	bh,ds:tile_fg_mask
		and	bl,ds:tile_fg_mask
		and	dh,ds:tile_fg_mask
		and	dl,ds:tile_fg_mask
		or	es:[di],bx
		or	es:[di+2],dx
		add	di,2000h
		cmp	di,8000h
		jb	char_row_wrap			; Jump if below
		add	di,80A0h
char_row_wrap:
		pop	bx
		dec	bl
		jz	char_row_done			; Jump if zero
		jmp	char_row_loop
char_row_done:
		pop	di
		inc	di
		inc	di
		cmp	cl,4
		je	char_advance_wide			; Jump if equal
		retn
char_advance_wide:
		inc	di
		retn
render_text_char		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

extract_bitplane_bit		proc	near
		xor	ah,ah			; Zero register
		mov	dl,2
extract_bit_loop:
		add	al,al
		sbb	dh,dh
		and	dh,0Fh
		add	ah,ah
		add	ah,ah
		add	ah,ah
		add	ah,ah
		or	ah,dh
		dec	dl
		jnz	extract_bit_loop			; Jump if not zero
		retn
extract_bitplane_bit		endp

			                        ;* No entry point to code
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,88h
		jmp	draw_sprite_entry
			                        ;* No entry point to code
		push	ds
		mov	ax,word ptr cs:[8Bh]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,258Ch
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
		mov	di,258Bh
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
		mov	di,258Eh
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		test	byte ptr cs:[93h],0FFh
		jnz	sprite_vis_check			; Jump if not zero
		retn
sprite_vis_check:
		push	ds
		mov	ax,word ptr cs:[94h]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,258Eh
		mov	cx,103h
		mov	ax,3EBBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

init_timestamp		proc	near
		mov	di,258Ah
		call	time_to_bcd
		mov	cx,6

timestamp_init_loop:
		test	byte ptr cs:[di],0FFh
		jz	timestamp_init_next			; Jump if zero
		retn
timestamp_init_next:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	timestamp_init_loop		; Loop if cx > 0

		retn
init_timestamp		endp

		db	7 dup (0)

;��������������������������������������������������������������������������
;                              SUBROUTINE
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
;                              SUBROUTINE
;��������������������������������������������������������������������������

modulo_divide_bcd		proc	near
		xor	dh,dh			; Zero register
div_loop:
		sub	dl,cl
		jc	div_done			; Jump if carry Set
		sub	ax,bx
		jnc	div_inc			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	div_adjust			; Jump if zero
		dec	dl
div_inc:
		inc	dh
		jmp	short div_loop
div_adjust:
		add	ax,bx
div_done:
		add	dl,cl
		retn
modulo_divide_bcd		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
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
;                              SUBROUTINE
;��������������������������������������������������������������������������

render_tilemap_large		proc	near
		mov	si,di
		mov	ds:tile_bg_mask,bh
		xor	bh,bh			; Zero register
		mov	dl,ds:tile_color_tbl[bx]
		mov	ds:tile_fg_mask,dl
		mov	bx,ax
		shr	ch,1			; Shift w/zeros fill
		adc	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		xor	ch,ch			; Zero register
		mov	ax,0B800h
		mov	es,ax

tilemap_large_loop:
		push	cx
		lodsb				; String [si] to al
		push	di
		push	si
		push	ds
		call	decode_bitplane_tile
		pop	ds
		pop	si
		pop	di
		add	di,3
		pop	cx
		loop	tilemap_large_loop		; Loop if cx > 0

		retn
render_tilemap_large		endp

			                        ;* No entry point to code
		db	 88h,0FFh		; mov bh, bh  (alt encoding: no-op)
		int	3			; Debug breakpoint
		stosb				; Store al to es:[di]
		mov	bx,0EE99h
		db	0DDh

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decode_bitplane_tile		proc	near
		test	byte ptr ds:tile_bg_mask,0FFh
		jz	tile_skip_clear			; Jump if zero
		push	di
		push	cx
		mov	cx,7

tile_clear_loop:
		mov	word ptr es:[di],1111h
		mov	byte ptr es:[di+2],11h
		add	di,2000h
		cmp	di,8000h
		jb	tile_clear_wrap			; Jump if below
		add	di,80A0h
tile_clear_wrap:
		loop	tile_clear_loop		; Loop if cx > 0

		pop	cx
		pop	di
tile_skip_clear:
		cmp	al,0FFh
		jne	tile_draw_start			; Jump if not equal
		retn
tile_draw_start:
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:font_ptr_b
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,7

tile_draw_loop:
		lodsb				; String [si] to al
		add	al,al
		add	al,al
		call	extract_bitplane_bit
		and	ah,cs:tile_fg_mask
		or	es:[di],ah
		call	extract_bitplane_bit
		and	ah,cs:tile_fg_mask
		or	es:[di+1],ah
		call	extract_bitplane_bit
		and	ah,cs:tile_fg_mask
		or	es:[di+2],ah
		add	di,2000h
		cmp	di,8000h
		jb	tile_draw_wrap			; Jump if below
		add	di,80A0h
tile_draw_wrap:
		loop	tile_draw_loop		; Loop if cx > 0

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
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	bp,ax
		mov	ax,0B800h
		mov	es,ax
		mov	cx,12h
sprite_large_row:
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
		call	extract_bitplane_pixels
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		mov	ax,[si+2]
		xchg	ah,al
		mov	cs:bitplane_0,ax
		mov	ax,[si+6]
		mov	cs:bitplane_1,ax
		mov	ax,[si+0Ch]
		xchg	ah,al
		mov	cs:bitplane_2,ax
		call	extract_bitplane_pixels
		mov	es:[bp+4],dh
		mov	es:[bp+5],dl
		call	extract_bitplane_pixels
		mov	es:[bp+6],dh
		mov	es:[bp+7],dl
		xor	al,al			; Zero register
		mov	ah,[si+4]
		mov	cs:bitplane_0,ax
		mov	ah,[si+5]
		mov	cs:bitplane_1,ax
		mov	ah,[si+0Eh]
		mov	cs:bitplane_2,ax
		call	extract_bitplane_pixels
		mov	es:[bp+8],dh
		mov	es:[bp+9],dl
		add	si,0Fh
		add	bp,2000h
		cmp	bp,8000h
		jb	sprite_large_wrap			; Jump if below
		add	bp,80A0h
sprite_large_wrap:
		pop	cx
		loop	sprite_large_next		; Loop if cx > 0

		jmp	short sprite_large_done

sprite_large_next:
		jmp	sprite_large_row
sprite_large_done:
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
		mov	si,27E7h
		or	al,al			; Zero ?
		jz	render_small_default_a			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_4
		mov	si,ax
render_small_default_a:
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,27E7h
		or	al,al			; Zero ?
		jz	render_small_default_b			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_3
		mov	si,ax
render_small_default_b:
		call	render_tilemap_small
		pop	ds
		retn
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
		db	 1Eh, 2Eh, 8Eh, 1Eh, 2Ch,0FFh
		db	 32h,0E4h,0B9h,0C0h, 00h,0F7h
		db	0E1h, 03h, 06h, 08h,0E2h, 8Bh
		db	0F0h,0E8h, 1Ah, 00h, 1Fh,0C3h
		db	 1Eh, 2Eh, 8Eh, 1Eh, 2Ch,0FFh
		db	 32h,0E4h,0B9h,0C0h, 00h,0F7h
		db	0E1h, 03h, 06h, 04h,0E2h, 8Bh
		db	0F0h,0E8h, 02h, 00h, 1Fh,0C3h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

render_tilemap_small		proc	near
		add	bh,bh
		call	bitplane_to_pixels
		inc	ax
		mov	bp,ax
		mov	ax,0B800h
		mov	es,ax
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
		mov	es:[bp],dh
		mov	es:[bp+1],dl
		call	extract_bitplane_pixels
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		mov	ax,[si+2]
		xchg	ah,al
		mov	cs:bitplane_0,ax
		mov	ax,[si+4]
		mov	cs:bitplane_1,ax
		mov	ax,[si+0Ah]
		xchg	ah,al
		mov	cs:bitplane_2,ax
		call	extract_bitplane_pixels
		mov	es:[bp+4],dh
		mov	es:[bp+5],dl
		call	extract_bitplane_pixels
		mov	es:[bp+6],dh
		mov	es:[bp+7],dl
		add	si,0Ch
		add	bp,2000h
		cmp	bp,8000h
		jb	tilemap_small_wrap			; Jump if below
		add	bp,80A0h
tilemap_small_wrap:
		pop	cx
		loop	tilemap_small_loop		; Loop if cx > 0

		retn
render_tilemap_small		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

extract_bitplane_pixels		proc	near
		mov	cx,4

extract_pixels_loop:
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
		add	dx,dx
		add	dx,dx
		or	dl,cs:pixel_mask_tbl[bx]
		loop	extract_pixels_loop		; Loop if cx > 0

		retn
extract_bitplane_pixels		endp

		db	 00h, 07h, 04h, 02h, 03h, 01h
		db	 08h, 05h, 07h, 0Fh, 0Ch, 0Eh
		db	 0Bh, 09h, 0Eh, 0Dh, 04h, 0Ch
		db	 0Ch, 0Eh, 07h, 05h, 06h, 0Ch
		db	 02h, 0Eh, 0Eh, 0Ah, 0Ah, 03h
		db	 0Ah, 07h, 03h, 0Bh, 07h, 0Ah
		db	 0Bh, 09h, 0Ah, 09h, 01h, 09h
		db	 05h, 03h, 09h, 09h, 07h, 05h
		db	 08h, 0Eh, 06h, 0Ah, 0Ah, 07h
		db	 0Eh, 0Ch, 05h, 0Dh, 0Ch, 07h
		db	 09h, 05h
		db	 0Ch, 0Dh

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

render_text_char_alt		proc	near
		push	ds
		push	cs
		pop	ds
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,ds:tile_color_tbl[bx]
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
		and	al,1
		mov	ds:tile_bg_mask,al
		shr	bx,1			; Shift w/zeros fill
		mov	bh,bl
		mov	bl,cl
		call	bitplane_to_pixels
		mov	di,ax
		pop	si
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

text_alt_row_loop:
		push	cx
		push	di
		lodsb				; String [si] to al
		push	ax
		mov	cl,cs:tile_bg_mask
		shr	al,cl			; Shift w/zeros fill
		call	extract_bitplane_bit
		not	ah
		and	es:[di],ah
		not	ah
		and	ah,cs:tile_fg_mask
		or	es:[di],ah
		pop	ax
		mov	cl,2
		sub	cl,cs:tile_bg_mask
		shl	al,cl			; Shift w/zeros fill
		inc	di
		mov	cx,3

text_alt_inner_loop:
		call	extract_bitplane_bit
		not	ah
		and	es:[di],ah
		not	ah
		and	ah,cs:tile_fg_mask
		or	es:[di],ah
		inc	di
		loop	text_alt_inner_loop		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	text_alt_wrap			; Jump if below
		add	di,80A0h
text_alt_wrap:
		pop	cx
		loop	text_alt_row_loop		; Loop if cx > 0

		pop	ds
		retn
render_text_char_alt		endp

			                        ;* No entry point to code
		push	ds
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	si,di
		add	si,2000h
		cmp	si,8000h
		jb	sprite_copy_wrap			; Jump if below
		add	si,tga_wrap
sprite_copy_wrap:
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

sprite_copy_loop:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	sprite_copy_wrap_di			; Jump if below
		add	di,tga_wrap
sprite_copy_wrap_di:
		add	si,2000h
		cmp	si,8000h
		jb	sprite_copy_wrap_si			; Jump if below
		add	si,tga_wrap
sprite_copy_wrap_si:
		pop	cx
		loop	sprite_copy_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		add	di,0
		mov	dh,al
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	bl,ah
		mov	bh,0A0h
		mul	bh			; ax = reg * al
		add	dx,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	dx,bx
		mov	si,dx
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,0B800h
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ch,bh

sprite_save_loop:
		push	cx
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,8000h
		jb	sprite_save_wrap			; Jump if below
		add	si,tga_wrap
sprite_save_wrap:
		pop	cx
		loop	sprite_save_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,di
		add	si,0
		mov	dh,al
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	bl,ah
		mov	bh,0A0h
		mul	bh			; ax = reg * al
		add	dx,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	dx,bx
		mov	di,dx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ch,bh

sprite_restore_loop:
		push	cx
		push	di
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	sprite_restore_wrap			; Jump if below
		add	di,80A0h
sprite_restore_wrap:
		pop	cx
		loop	sprite_restore_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	cs:char_src_ptr,bx
		mov	cs:char_bit_idx,cl
		mov	byte ptr cs:char_color,1
string_char_loop:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	string_not_eol			; Jump if not equal
		retn
string_not_eol:
		cmp	al,0Dh
		je	string_newline			; Jump if equal
		or	al,al			; Zero ?
		js	string_color_code			; Jump if sign=1
		push	cx
		push	bx
		push	si
		mov	ah,cs:char_color
		call	render_text_char_alt
		pop	si
		pop	bx
		pop	cx
		add	bx,8
		jmp	short string_char_loop
string_newline:
		add	byte ptr cs:char_bit_idx,8
		mov	cl,cs:char_bit_idx
		mov	bx,cs:char_src_ptr
		jmp	short string_char_loop
string_color_code:
		mov	cs:char_color,al
		jmp	short string_char_loop
			                        ;* No entry point to code
		push	ds
		push	dx
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	si,ax
		pop	bx
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

blit_copy_loop:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	blit_wrap_di			; Jump if below
		add	di,80A0h
blit_wrap_di:
		add	si,2000h
		cmp	si,8000h
		jb	blit_wrap_si			; Jump if below
		add	si,80A0h
blit_wrap_si:
		pop	cx
		loop	blit_copy_loop		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	al,ds:tile_color_tbl[bx]
		sub	al,88h
		mov	ds:tile_fg_mask,al
		pop	bx
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		call	fill_rectangle
		mov	cx,10h

panel_side_loop:
		mov	al,ds:tile_fg_mask
		mov	es:[di],al
		mov	es:[di+9],al
		add	di,2000h
		cmp	di,8000h
		jb	panel_side_wrap			; Jump if below
		add	di,tga_wrap
panel_side_wrap:
		loop	panel_side_loop		; Loop if cx > 0

		call	fill_rectangle
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_rectangle		proc	near
		mov	cx,2

fill_rect_loop:
		push	cx
		push	di
		mov	al,ds:tile_fg_mask
		mov	cx,0Ah
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	fill_rect_wrap			; Jump if below
		add	di,80A0h
fill_rect_wrap:
		pop	cx
		loop	fill_rect_loop		; Loop if cx > 0

		retn
fill_rectangle		endp

			                        ;* No entry point to code
		push	ds
		push	si
		push	cs
		pop	ds
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bx,ds:tile_offset_tbl[si]
		mov	si,ds:tile_color_tbl_b[si]
		mov	cx,0Dh

sprite_px_row_loop:
		push	cx
		push	di
		mov	dx,[bx]
		inc	bx
		inc	bx
		xchg	dh,dl
		mov	cx,8

sprite_px_inner_loop:
		add	dx,dx
		sbb	al,al
		and	al,0F0h
		add	dx,dx
		sbb	ah,ah
		and	ah,0Fh
		or	al,ah
		and	es:[di],al
		lodsb				; String [si] to al
		or	es:[di],al
		inc	di
		loop	sprite_px_inner_loop		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	sprite_px_wrap			; Jump if below
		add	di,80A0h
sprite_px_wrap:
		pop	cx
		loop	sprite_px_row_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		mov	di,0F32Ch
		sub	al,0D9h
		sub	al,5Bh			; '['
		sub	ax,2FFCh
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F0h, 07h		; nibble pixel-mask pair (hi=0xF0, lo=0x07)
		db	0F0h, 07h		; nibble pixel-mask pair (hi=0xF0, lo=0x07)
		db	0F0h, 07h		; nibble pixel-mask pair (hi=0xF0, lo=0x07)
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F2h, 2Fh,0FFh,0FFh,0FFh,0FFh
		db	0F0h, 0Fh,0E0h, 07h,0C0h, 03h
		db	0C0h, 03h, 80h, 01h, 80h, 01h
		db	 80h, 01h, 80h, 01h,0C0h, 03h
		db	0C0h, 03h,0E0h, 07h,0F0h, 0Fh
		db	0F8h, 1Fh
		db	11 dup (0)
		db	0DDh,0DCh, 00h, 00h, 00h, 00h
		db	 00h, 07h,0DFh,0F7h,0C0h, 00h
		db	 00h, 00h, 00h, 0Dh,0FFh,0F1h
		db	 54h, 00h, 00h, 00h, 00h, 75h
		db	 7Fh, 31h, 14h, 00h, 00h, 00h
		db	 00h, 74h, 11h, 91h, 1Ch, 00h
		db	 00h, 00h, 00h, 45h, 11h, 11h
		db	 1Ch, 00h, 00h, 00h, 00h, 0Ch
		db	 19h, 91h, 54h, 00h, 00h, 00h
		db	 00h, 04h, 49h, 91h,0C0h, 00h
		db	 00h, 00h, 00h, 00h, 4Ch,0CCh
		db	29 dup (0)
		db	 07h,0FFh,0FAh, 20h, 00h, 00h
		db	 00h, 00h,0FFh, 00h, 00h, 2Ah
		db	 00h, 00h, 00h, 0Fh, 70h, 7Fh
		db	 70h, 02h, 20h, 00h, 00h, 7Fh
		db	 0Fh,0F7h, 00h, 70h, 22h, 00h
		db	 00h,0F7h, 7Fh,0F0h, 00h, 07h
		db	 22h, 00h, 00h,0F0h,0F7h, 00h
		db	 44h, 00h, 0Ah, 00h, 00h,0F0h
		db	 70h, 04h, 44h, 44h, 4Ah, 00h
clear_area_entry:
		db	 00h,0F2h		; add dl, dh  (alt encoding: ADD r/m8,r8)
		jz	clear_area_row_done			; Jump if zero
		int	3			; Debug breakpoint
		db	0C4h, 7Ah, 00h		; les di, [bp+si+0]  (LES with disp8=0, alt encoding)
		db	 00h, 7Ah, 47h, 4Ch,0CCh,0C4h
		db	0F7h, 00h, 00h, 0Ah, 24h,0D7h
		db	0CCh,0C7h,0F0h, 00h, 00h, 00h
		db	0A2h, 40h, 44h, 7Fh, 00h, 00h
		db	 00h, 00h, 02h, 72h, 27h, 20h
		db	 00h
		db	9 dup (0)
		db	0B8h, 00h,0B8h, 8Eh,0C0h, 33h
		db	0FFh,0B9h, 08h, 00h

clear_area_pass_loop:
		push	cx
		push	di
		mov	cx,19h

clear_area_row_loop:
		push	cx
		push	di
		mov	cx,50h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
clear_area_row_done:
		pop	di
		add	di,140h
		pop	cx
		loop	clear_area_row_loop		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	clear_area_wrap			; Jump if below
		add	di,80A0h
clear_area_wrap:
		pop	cx
		loop	clear_area_pass_loop		; Loop if cx > 0

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

sprite_decode_pass_loop:
		push	cx
		call	process_sprite_row
		pop	cx
		loop	sprite_decode_pass_loop		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

process_sprite_row		proc	near
		mov	cx,8

sprite_decode_row_loop:
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
		call	extract_bitplane_pixels
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	extract_bitplane_pixels
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		pop	cx
		loop	sprite_decode_row_loop		; Loop if cx > 0

		retn
process_sprite_row		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

bitplane_to_pixels		proc	near
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
bitplane_to_pixels		endp

		db	12 dup (0)

seg_a		ends



		end	start
