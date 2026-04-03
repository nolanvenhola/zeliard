
PAGE  59,132

;==========================================================================
;
;  GMHGC.BIN - Hercules Graphics Card Monochrome Driver (720x348)
;
;  HGC variant of the graphics driver API. Uses monochrome framebuffer
;  at 0xB000 with bit-level pixel operations. 4 interleaved banks.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; The following equates show data references outside the range of the program.

anim_ptr_0		equ	0E200h			;*
anim_ptr_1		equ	0E202h			;*
anim_ptr_2		equ	0E206h			;*
anim_ptr_3		equ	0E20Ah			;*
anim_ptr_4		equ	0E20Ch			;*
fade_mask_tbl	equ	21D6h			;*
plot_mode	equ	22D5h			;*
tile_color_tbl	equ	2600h			;*
pixel_lut	equ	2994h			;*
tile_color_tbl_b	equ	2CA7h			;*
tile_fg_mask	equ	2E7Fh			;*
tile_bg_mask	equ	2E80h			;*
char_color	equ	2E81h			;*
char_src_ptr	equ	2E82h			;*
char_bit_idx	equ	2E84h			;*
bitplane_0	equ	2E85h			;*
bitplane_1	equ	2E87h			;*
bitplane_2	equ	2E89h			;*
hgc_bank_size	equ	6000h			;*
hgc_stride	equ	0A05Ah			;*
hgc_reg_b	equ	0B324h			;*
hgc_reg_a	equ	0BB23h			;*
font_ptr_a	equ	0F500h			;*
font_ptr_b	equ	0F502h			;*
font_ptr_c	equ	0F504h			;*
drv_state_byte	equ	0F92Ah			;*
palette_state	equ	0FF01h			;*
gvar_game_seg	equ	0FF2Ch			;*
zero_offset	equ	0			;*
hgc_cursor_ofs	equ	4FDh

driver_base	equ	2000h			; driver loads at game_seg:2000h
hgc_seg		equ	0B000h			; HGC framebuffer segment

; stdply.bin player state field offsets (shared with all gm*.bin drivers)
include  stdply.inc

; Set ES to the HGC framebuffer segment (0xB000)
SET_HGC_ES	MACRO
		mov	ax, hgc_seg
		mov	es, ax
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

gmhgc		proc	far

start:
		inc	si
		and	[bp+di],dl
;*		and	si,bx
		db	 21h,0DEh		;  and si, bx  (alt encoding: 21h r/m,r)
;*		and	si,dx
		db	 21h,0D6h		;  and si, dx  (alt encoding: 21h r/m,r)
		and	dl,[bx+si]
		and	sp,ax
		and	bl,[bp+si]
		and	bp,ds:hgc_reg_a[di]
		and	bp,ds:hgc_reg_b[bx+di]
		and	al,0D0h
		and	al,0F0h
		and	al,19h
		and	ax,2698h
		pop	dx
		daa				; Decimal adjust
		jz	dispatch_entry			; Jump if zero
;*		aam	29h			; ')' undocumented inst
		db	0D4h, 29h		;  aam 29h  (undocumented form, alternate encoding)
		mov	al,ds:drv_state_byte
		sub	dh,[bp+si]
		sub	di,[bp+di+2Bh]
		dw	02BC6h			; fn  0
		dw	02C18h			; fn  1
		dw	025C7h			; fn  2
		dw	0255Eh			; fn  3
		dw	0278Eh			; fn  4
		dw	027AFh			; fn  5
		dw	023C9h			; fn  6
		dw	02890h			; fn  7
		dw	028A8h			; fn  8
		dw	02CAFh			; fn  9
		dw	02143h			; fn 10
		dw	02E02h			; fn 11
		dw	02E37h			; fn 12

dispatch_call:
		db	 50h			; push ax      (save fn#)
		db	0E8h, 0C7h		; call calc_hgc_address  (E8 C7 0D: 0Dh = first byte of next 'or ax' = CALL high displacement; dual-use byte trick; target 0E11h)

dispatch_entry:
		or	ax,0F88Bh
		pop	ax
		or	al,al			; Zero ?
		jnz	draw_border_entry			; Jump if not zero
		jmp	clear_screen_start

draw_border_entry:
		push	di
		sub	cl,4
		add	di,4000h
		cmp	di,6000h
		jb	border_bank_ok			; Jump if below
		add	di,hgc_stride

border_bank_ok:
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

border_row_loop:
						mov	byte ptr es:[di],0F0h
						mov	byte ptr es:[bx+di],0Fh
						add	di,2000h
						cmp	di,6000h
						jb	border_loop_bank_ok			; Jump if below
						mov	byte ptr es:[di],0F0h
						mov	byte ptr es:[bx+di],0Fh
						add	di,hgc_stride

border_loop_bank_ok:
						loop	border_row_loop		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0FC3Fh
		call	fill_horizontal_line
		mov	ax,0F00Fh

gmhgc		endp

fill_horizontal_line		proc	near
		push	di
		or	es:[di],al
		inc	di
		mov	bh,ch
		sub	bh,2

fill_hline_inner:
						or	byte ptr es:[di],0FFh
						inc	di
						dec	bh
						jnz	fill_hline_inner			; Jump if not zero
		or	es:[di],ah
		pop	di
		add	di,2000h
		cmp	di,hgc_bank_size
		jae	fill_hline_bank_wrap			; Jump if above or =
		retn

fill_hline_bank_wrap:
		push	di
		push	ds
		push	cx
		push	es
		pop	ds
		mov	si,di
		sub	si,2000h
		mov	cl,ch
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	ds
		pop	di
		add	di,0A05Ah
		retn

fill_horizontal_line		endp

clear_screen		proc	near

clear_screen_start:
		mov	ax,0B000h
		mov	es,ax
		mov	ah,cl

clear_screen_row_loop:
						call	clear_screen_row
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	clear_row_bank_ok			; Jump if below
						call	clear_screen_row
						add	di,0A05Ah

clear_row_bank_ok:
						dec	ah
						jnz	clear_screen_row_loop			; Jump if not zero
		retn

clear_screen		endp

clear_screen_row		proc	near
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	cx
		pop	di
		retn

clear_screen_row		endp

clear_cursor_area:				; called externally: clear HGC framebuffer cursor region (0x90 rows at hgc_cursor_ofs)
		mov	ax,0B000h
		mov	es,ax
		mov	di,hgc_cursor_ofs
		mov	cx,90h

clear_cursor_row_loop:
						push	cx
						push	di
						mov	cx,38h
						xor	al,al			; Zero register
						rep	stosb			; Rep when cx >0 Store al to es:[di]
						pop	di
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	clear_cursor_bank_ok			; Jump if below
						push	di
						mov	cx,38h
						xor	al,al			; Zero register
						rep	stosb			; Rep when cx >0 Store al to es:[di]
						pop	di
						add	di,0A05Ah

clear_cursor_bank_ok:
						pop	cx
						loop	clear_cursor_row_loop		; Loop if cx > 0

		retn

fn_10_fade_screen:				; dispatch fn 10: fade screen using bit-mask table (8 steps)
		mov	ax,0B000h
		mov	es,ax
		mov	si,fade_mask_tbl
		mov	cx,8

fade_outer_loop:
						push	cx
						mov	di,4FDh
						lodsb				; String [si] to al
						push	di
						mov	cx,48h

fade_row_loop_a:
										push	cx
										call	fade_screen_row
										add	di,2000h
										cmp	di,6000h
										jb	fade_row_a_bank_ok			; Jump if below
										call	fade_screen_row
										add	di,0A05Ah

fade_row_a_bank_ok:
										add	di,2000h
										cmp	di,6000h
										jb	fade_row_a_bank_ok2			; Jump if below
										add	di,0A05Ah

fade_row_a_bank_ok2:
										rol	al,1			; Rotate
										rol	al,1			; Rotate
										rol	al,1			; Rotate
										pop	cx
										loop	fade_row_loop_a		; Loop if cx > 0

						pop	di
						add	di,2000h
						cmp	di,6000h
						jb	fade_iter_bank_ok			; Jump if below
						add	di,0A05Ah

fade_iter_bank_ok:
						mov	cx,48h

fade_row_loop_b:
										push	cx
										call	fade_screen_row
										add	di,2000h
										cmp	di,6000h
										jb	fade_row_b_bank_ok			; Jump if below
										call	fade_screen_row
										add	di,0A05Ah

fade_row_b_bank_ok:
										add	di,2000h
										cmp	di,6000h
										jb	fade_row_b_bank_ok2			; Jump if below
										add	di,hgc_stride

fade_row_b_bank_ok2:
										rol	al,1			; Rotate
										rol	al,1			; Rotate
										rol	al,1			; Rotate
										pop	cx
										loop	fade_row_loop_b		; Loop if cx > 0

						mov	cx,3E80h

fade_delay_loop:
										loop	fade_delay_loop		; Loop if cx > 0

						pop	cx
						loop	fade_outer_loop		; Loop if cx > 0

		retn

fade_screen_row		proc	near
		push	di
		mov	cx,38h

fade_row_inner:
						and	es:[di],al
						inc	di
						loop	fade_row_inner		; Loop if cx > 0

		pop	di
		retn

fade_screen_row		endp

fade_step_tbl:					; 8-entry fade step table: bit-mask values decreasing FEh→00h (fade-out steps)
		db	0FEh,0EEh,0EAh,0AAh,0A8h, 88h
		db	 80h, 00h

set_plot_pos:
		mov	cs:plot_mode,al
		mov	ax,0B000h
		mov	es,ax
		xor	ax,ax			; Zero register
		mov	al,bl
		add	ax,0BAh
		mov	dl,3
		div	dl			; al, ah rem = ax/reg
		mov	dh,ah
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		mov	ah,5Ah			; 'Z'
		mul	ah			; ax = reg * al
		add	ax,dx
		add	bh,14h
		mov	dl,bh
		and	bh,3
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		xor	dh,dh			; Zero register
		add	ax,dx
		add	ax,0Ch
		mov	di,ax
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
		jz	plot_partial_check			; Jump if zero

plot_full_bytes_loop:
						push	cx
						mov	ax,0FFFFh
						call	plot_pixel
						pop	cx
						inc	di
						dec	cl
						jnz	plot_full_bytes_loop			; Jump if not zero

plot_partial_check:
		and	ch,3
		jnz	plot_right_partial			; Jump if not zero
		retn

plot_right_partial:
		mov	cl,ch
		shl	cl,1			; Shift w/zeros fill
		mov	ah,0FFh
		shr	ah,cl			; Shift w/zeros fill
		not	ah
		mov	al,ah

plot_pixel		proc	near
		test	byte ptr cs:plot_mode,0FFh
		jnz	plot_patterned			; Jump if not zero
		push	di
		not	ah
		mov	cx,9

plot_clear_col_loop:
						and	es:[di],ah
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	plot_clear_bank_ok			; Jump if below
						and	es:[di],ah
						add	di,hgc_stride

plot_clear_bank_ok:
						loop	plot_clear_col_loop		; Loop if cx > 0

		and	es:[di],ah
		or	es:[di],al
		pop	di
		retn

plot_patterned:
		cmp	byte ptr cs:plot_mode,80h
		je	plot_xor_mode			; Jump if equal
		push	di
		mov	ah,al
		not	ah
		and	al,55h			; 'U'
		mov	cx,0Ah

plot_pattern_col_loop:
						and	es:[di],ah
						or	es:[di],al
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	plot_pattern_bank_ok			; Jump if below
						and	es:[di],ah
						or	es:[di],al
						add	di,hgc_stride

plot_pattern_bank_ok:
						loop	plot_pattern_col_loop		; Loop if cx > 0

		pop	di
		retn

plot_xor_mode:
		push	di
		not	al
		mov	cx,0Ah

plot_xor_col_loop:
						and	es:[di],al
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	plot_xor_bank_ok			; Jump if below
						and	es:[di],al
						add	di,0A05Ah

plot_xor_bank_ok:
						loop	plot_xor_col_loop		; Loop if cx > 0

		pop	di
		retn

plot_pixel		endp

plot_mode_fn:					; self-modifying entry: opcode byte patched by set_plot_mode
		db	 00h			; opcode 00h = add byte ptr [r/m],reg (patched at runtime)
		db	0BFh, 40h, 56h		; ModRM+disp16: byte ptr [bx+5640h], bh (operand constant)
		mov	bx, word ptr cs:[0B2h]
		jmp	short draw_text_field_common

draw_text_field_alt:				; alternate entry: use row-B DI offset
		mov	di, 57A8h
		jmp	short draw_text_field_common

draw_text_field_common:
		SET_HGC_ES			; mov ax,0B000h / mov es,ax
		call	calc_text_width
		push	ax

draw_full_bytes_loop:
						or	bl,bl			; Zero ?
						jz	draw_partial_check			; Jump if zero
						push	di
						mov	bh,6
						mov	al,0AAh
						mov	ah,55h			; 'U'
						call	fill_vertical_line
						dec	bl
						pop	di
						inc	di
						jmp	short draw_full_bytes_loop

draw_partial_check:
		pop	ax
		or	al,al			; Zero ?
		jnz	draw_partial_entry			; Jump if not zero
		retn

draw_partial_entry:
		and	al,0AAh
		mov	ah,55h			; 'U'
		mov	bh,6
		jmp	short fill_vline_inner

draw_text_line_main:				; alternate text-line entry (row A, di=5640h): called externally — parallel to plot_mode_fn
		mov	di,5640h
		mov	bx,word ptr cs:[90h]
		jmp	short draw_text_line

draw_text_field_alt2:				; alternate entry B: use row-B DI offset
		mov	di, 57A8h
		jmp	short draw_text_line

draw_text_line:
		mov	ax,0B000h
		mov	es,ax
		call	calc_text_width
		push	ax
		push	bx

draw_text_left_loop:
						or	bl,bl			; Zero ?
						jz	draw_left_done			; Jump if zero
						push	di
						mov	bh,5
						mov	al,55h			; 'U'
						mov	ah,0AAh
						call	fill_vertical_line
						dec	bl
						pop	di
						inc	di
						jmp	short draw_text_left_loop

draw_left_done:
		pop	bx
		pop	ax
		or	al,al			; Zero ?
		jz	draw_fill_start			; Jump if zero
		push	di
		mov	bh,5
		and	al,55h			; 'U'
		mov	ah,0AAh
		call	fill_vertical_line
		pop	di
		inc	di
		inc	bl

draw_fill_start:
		mov	bh,19h
		sub	bh,bl
		jnz	draw_fill_nonzero			; Jump if not zero
		retn

draw_fill_nonzero:
		mov	bl,bh

draw_fill_loop:
						push	di
						mov	bh,5
						xor	al,al			; Zero register
						mov	ah,0AAh
						call	fill_vertical_line
						pop	di
						inc	di
						dec	bl
						jnz	draw_fill_loop			; Jump if not zero
		retn

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	text_width_overflow			; Jump if carry Set
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

text_width_overflow:
		mov	bx,19h
		xor	al,al			; Zero register
		retn

calc_text_width		endp

fill_vertical_line		proc	near

fill_vline_inner:
						and	es:[di],ah
						or	es:[di],al
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	fill_vline_bank_ok			; Jump if below
						and	es:[di],ah
						or	es:[di],al
						add	di,0A05Ah

fill_vline_bank_ok:
						dec	bh
						jnz	fill_vline_inner			; Jump if not zero
		retn

fill_vertical_line		endp

set_tile_mode_a:				; fg=55h bg=AAh (interleaved), then draw chars
		mov	byte ptr cs:[tile_fg_mask], 55h
		mov	byte ptr cs:[tile_bg_mask], 0AAh
		jmp	short render_chars_data

set_tile_mode_b:				; fg=FFh bg=00h (solid), then draw chars
		mov	byte ptr cs:[tile_fg_mask], 0FFh
		mov	byte ptr cs:[tile_bg_mask], 00h
		jmp	short render_chars_data

set_tile_mode_c:				; fg=FFh bg=00h + compute HGC address then draw chars
		mov	byte ptr cs:[tile_fg_mask], 0FFh
		mov	byte ptr cs:[tile_bg_mask], 00h
		call	calc_hgc_address
		mov	di, ax
		mov	bl, cl
		SET_HGC_ES			; mov ax,0B000h / mov es,ax

render_char_loop:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jnz	render_char_nonzero			; Jump if not zero
						retn

render_char_nonzero:
						push	bx
						push	ds
						push	si
						and	bl,3
						call	render_text_char
						pop	si
						pop	ds
						pop	bx
						inc	bl
						jmp	short render_char_loop

render_chars_data:				; jumped to from set_tile_mode_a/b: read char coord + draw
		lodsb				; String [si] to al
		mov	bh,al
		lodsb				; String [si] to al
		mov	bl,al
		call	calc_hgc_address
		mov	di,ax
		lodsb				; String [si] to al
		mov	bl,al
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		mov	ax,0B000h
		mov	es,ax

render_chars_loop:
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
						loop	render_chars_loop		; Loop if cx > 0

		retn

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

render_char_rows:
						push	bx
						lodsb				; String [si] to al
						mov	dl,4

render_char_bit_loop:
										add	ax,ax
										add	ah,ah
										dec	dl
										jnz	render_char_bit_loop			; Jump if not zero
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
						cmp	di,hgc_bank_size
						jb	render_char_row_bank_ok			; Jump if below
						mov	bx,di
						sub	bx,2000h
						mov	ax,es:[bx]
						mov	es:[di],ax
						add	di,0A05Ah

render_char_row_bank_ok:
						pop	bx
						dec	bl
						jnz	render_char_rows			; Jump if not zero
		pop	di
		inc	di
		cmp	cl,6
		je	render_wide_char			; Jump if equal
		retn

render_wide_char:
		inc	di
		retn

render_text_char		endp

set_plot_fixed:					; called externally: set plot position (bx=210h, al=0, ch=88h) → set_plot_pos
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,88h
		jmp	set_plot_pos

render_large_tilemap_a:				; called externally: render large tilemap A (cs:[8Bh] anim, di=2559h, cx=105h)
		push	ds
		mov	ax,word ptr cs:[8Bh]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,2559h
		mov	cx,105h
		mov	ax,26BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn

render_large_tilemap_b:				; called externally: render large tilemap B (cs:[86h]/cs:[85h] anim, di=2558h, cx=106h)
		push	ds
		mov	ax,word ptr cs:[86h]
		mov	dl,byte ptr cs:[85h]
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,2558h
		mov	cx,106h
		mov	ax,13BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn

render_large_tilemap_c:				; called externally: render large tilemap C (cs:[9Dh] frame select via anim_lut, di=255Bh, cx=103h)
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
		mov	di,255Bh
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn

render_sprite_if_active:			; called externally: render sprite at di=255Bh if cs:[93h] != 0
		test	byte ptr cs:[93h],0FFh
		jnz	render_sprite_active			; Jump if not zero
		retn

render_sprite_active:
		push	ds
		mov	ax,word ptr cs:[94h]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,255Bh
		mov	cx,103h
		mov	ax,3EBBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn

init_timestamp		proc	near
		mov	di,2557h
		call	time_to_bcd
		mov	cx,6

timestamp_fill_loop:
						test	byte ptr cs:[di],0FFh
						jz	timestamp_slot_empty			; Jump if zero
						retn

timestamp_slot_empty:
						mov	byte ptr cs:[di],0FFh
						inc	di
						loop	timestamp_fill_loop		; Loop if cx > 0

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

moddiv_loop:
						sub	dl,cl
						jc	moddiv_exit			; Jump if carry Set
						sub	ax,bx
						jnc	moddiv_inc			; Jump if carry=0
						or	dl,dl			; Zero ?
						jz	moddiv_no_inc			; Jump if zero
						dec	dl

moddiv_inc:
						inc	dh
						jmp	short moddiv_loop

moddiv_no_inc:
		add	ax,bx

moddiv_exit:
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
		mov	ds:tile_bg_mask,bh
		xor	bh,bh			; Zero register
		mov	dl,ds:tile_color_tbl[bx]
		mov	ds:tile_fg_mask,dl
		mov	bx,ax
		call	calc_hgc_address
		mov	bx,ax
		mov	ax,0B000h
		mov	es,ax

render_tilemap_tile_loop:
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
						jnz	render_tilemap_tile_loop			; Jump if not zero
		retn

render_tilemap_large		endp

pixel_pattern_tbl:				; 8-entry pixel mask table: alternating HGC fill values (00,FF,AA,FF,55,00,FF,AA)
		db	 00h,0FFh,0AAh,0FFh, 55h, 00h
		db	0FFh,0AAh

decode_bitplane_tile		proc	near
		mov	bx,0Fh
		test	ch,1
		jz	tile_even_col			; Jump if zero
		mov	bx,0F000h

tile_even_col:
		test	byte ptr ds:tile_bg_mask,0FFh
		jz	tile_draw_check			; Jump if zero
		push	di
		push	cx
		xchg	bh,bl
		mov	cx,7

tile_clear_col_loop:
						and	es:[di],bx
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	tile_clear_bank_ok			; Jump if below
						and	es:[di],bx
						add	di,hgc_stride

tile_clear_bank_ok:
						loop	tile_clear_col_loop		; Loop if cx > 0

		pop	cx
		pop	di

tile_draw_check:
		inc	al
		jnz	tile_nonblank			; Jump if not zero
		retn

tile_nonblank:
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

tile_row_loop:
						lodsb				; String [si] to al
						mov	ah,8

tile_bit_loop:
										add	al,al
										adc	dx,dx
										add	dx,dx
										dec	ah
										jnz	tile_bit_loop			; Jump if not zero
						mov	ax,dx
						shr	dx,1			; Shift w/zeros fill
						or	ax,dx
						test	ch,1
						jnz	tile_odd_col			; Jump if not zero
						add	ax,ax
						add	ax,ax
						add	ax,ax
						add	ax,ax

tile_odd_col:
						xchg	ah,al
						and	ah,cs:tile_fg_mask
						and	al,cs:tile_fg_mask
						or	es:[di],ax
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	tile_row_bank_ok			; Jump if below
						or	es:[di],ax
						add	di,0A05Ah

tile_row_bank_ok:
						dec	cl
						jnz	tile_row_loop			; Jump if not zero
		retn

decode_bitplane_tile		endp

render_sprite_frame:				; called externally: render sprite frame al (via anim_ptr_0) to HGC at (bh,ch)
		push	ds
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,10Eh
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_0
		mov	si,ax
		add	bh,bh
		call	calc_hgc_address
		mov	bp,ax
		mov	ax,0B000h
		mov	es,ax
		mov	cx,12h

sprite_row_loop:
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
		cmp	bp,hgc_bank_size
		jb	sprite_bank_ok			; Jump if below
		mov	di,bp
		sub	di,2000h
		mov	ax,es:[di]
		mov	es:[bp],ax
		mov	ax,es:[di+2]
		mov	es:[bp+2],ax
		mov	al,es:[di+4]
		mov	es:[bp+4],al
		add	bp,0A05Ah

sprite_bank_ok:
		pop	cx
		loop	sprite_row_loop_jmp		; Loop if cx > 0

		jmp	short sprite_done

sprite_row_loop_jmp:
		jmp	sprite_row_loop

sprite_done:
		pop	ds
		retn

render_small_tiles_ptr2:			; called externally: render small tile frame al (via anim_ptr_2) at current position
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

render_small_tiles_ptr1:			; called externally: render small tile frame al (via anim_ptr_1) at current position
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

fn_4_render_anim_tiles_a:			; dispatch fn 4: render small animated tiles (anim_ptr_4 or default si=27D0h)
		push	ds
		mov	si,27D0h
		or	al,al			; Zero ?
		jz	render_small_tiles_entry			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_4
		mov	si,ax

render_small_tiles_entry:
		call	render_tilemap_small
		pop	ds
		retn

fn_5_render_anim_tiles_b:			; dispatch fn 5: render small animated tiles (anim_ptr_3 or default si=27D0h)
		push	ds
		mov	si,27D0h
		or	al,al			; Zero ?
		jz	render_small_tiles_b_entry			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_3
		mov	si,ax

render_small_tiles_b_entry:
		call	render_tilemap_small
		pop	ds
		retn

sprite_anim_data:				; 16 rows x 12 bytes: HGC sprite animation bitplane data (3 planes x 2 bytes/row)
		db	 00h, 00h, 00h, 00h,0FCh,0FFh	; row  0: sentinel/blank
		db	0FFh, 3Fh, 2Ah,0AAh,0AAh,0A8h	; row  0 hi
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row  1
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row  1 hi
		db	 0Eh, 38h,0F8h, 00h, 03h, 00h	; row  2
		db	 00h,0C0h, 82h, 08h, 08h, 02h	; row  2 hi
		db	 0Fh,0BBh, 8Eh, 00h, 03h, 00h	; row  3
		db	 00h,0C0h, 80h, 88h, 82h, 02h	; row  3 hi
		db	 0Fh,0FBh, 8Eh, 00h, 03h, 00h	; row  4
		db	 00h,0C0h, 80h, 08h, 82h, 02h	; row  4 hi
		db	 0Eh,0FBh, 8Eh, 00h, 03h, 00h	; row  5
		db	 00h,0C0h, 82h, 08h, 82h, 02h	; row  5 hi
		db	 0Eh, 38h,0F8h, 00h, 03h, 00h	; row  6
		db	 00h,0C0h, 82h, 08h, 08h, 02h	; row  6 hi
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row  7
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row  7 hi
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row  8
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row  8 hi
		db	 0Eh, 38h,0FBh,0F8h, 03h, 00h	; row  9
		db	 00h,0C0h, 82h, 08h, 08h, 0Ah	; row  9 hi
		db	 0Eh, 3Bh, 83h, 80h, 03h, 00h	; row 10
		db	 00h,0C0h, 82h, 08h, 80h, 82h	; row 10 hi
		db	 0Eh, 38h,0E3h,0C0h, 03h, 00h	; row 11
		db	 00h,0C0h, 82h, 08h, 20h, 02h	; row 11 hi
		db	 0Eh, 38h, 3Bh, 80h, 03h, 00h	; row 12
		db	 00h,0C0h, 82h, 08h, 08h, 82h	; row 12 hi
		db	 03h,0E3h,0E3h,0F8h, 03h, 00h	; row 13
		db	 00h,0C0h, 80h, 20h, 20h, 0Ah	; row 13 hi
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row 14
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row 14 hi
		db	 00h, 00h, 00h, 00h,0FCh,0FFh	; row 15: sentinel/blank
		db	0FFh, 3Fh, 2Ah,0AAh,0AAh,0A8h	; row 15 hi

render_small_tiles_a:				; load si=game_seg:anim_ptr[E208h], call render_tilemap_small
		push	ds
		mov	ds, cs:gvar_game_seg
		xor	ah, ah			; Zero register
		mov	cx, 0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax, ds:[0E208h]		; anim_ptr (not in equate list)
		mov	si, ax
		call	render_tilemap_small
		pop	ds
		retn

render_small_tiles_b:				; load si=game_seg:anim_ptr[E204h], call render_tilemap_small
		push	ds
		mov	ds, cs:gvar_game_seg
		xor	ah, ah			; Zero register
		mov	cx, 0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax, ds:[0E204h]		; anim_ptr (not in equate list)
		mov	si, ax
		call	render_tilemap_small
		pop	ds
		retn

render_tilemap_small		proc	near
		call	calc_hgc_address
		mov	bp,ax
		mov	ax,0B000h
		mov	es,ax
		mov	cx,10h

small_tile_row_loop:
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

small_tile_shift_loop:
						shr	ax,1			; Shift w/zeros fill
						rcr	dx,1			; Rotate thru carry
						rcr	bl,1			; Rotate thru carry
						loop	small_tile_shift_loop		; Loop if cx > 0

		mov	es:[bp],ah
		mov	es:[bp+1],al
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		mov	es:[bp+4],bl
		add	si,0Ch
		add	bp,2000h
		cmp	bp,hgc_bank_size
		jb	small_tile_bank_ok			; Jump if below
		mov	es:[bp],ah
		mov	es:[bp+1],al
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		mov	es:[bp+4],bl
		add	bp,0A05Ah

small_tile_bank_ok:
		pop	cx
		loop	small_tile_loop_jmp		; Loop if cx > 0

		jmp	short small_tile_done

small_tile_loop_jmp:
		jmp	small_tile_row_loop

small_tile_done:
		retn

render_tilemap_small		endp

extract_bitplane_pixels		proc	near
		mov	cx,8

extract_pixel_loop:
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
						or	dl,cs:pixel_lut[bx]
						loop	extract_pixel_loop		; Loop if cx > 0

		retn

extract_bitplane_pixels		endp

		db	0, 1, 2, 1, 1, 0
		db	3, 2, 1, 3, 3, 3
		db	1, 3, 3, 2, 2, 3
		db	2, 1, 1, 2, 2, 2
		db	1, 3, 1, 3, 1, 1
		db	2, 2, 1, 1, 1, 1
		db	1, 1, 3, 2, 0, 3
		db	2, 1, 1, 1, 3, 2
		db	3, 3, 2, 2, 3, 3
		db	3, 2, 1, 2, 2, 2
		db	2, 2, 2, 2

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
		add	bx,14h
		mov	al,bl
		and	al,3
		add	al,al
		mov	ds:tile_bg_mask,al
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		xor	ch,ch			; Zero register
		add	cx,1Ch
		mov	ax,cx
		mov	dl,3
		div	dl			; al, ah rem = ax/reg
		mov	dh,ah
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		mov	ah,5Ah			; 'Z'
		mul	ah			; ax = reg * al
		and	dx,6000h
		add	ax,dx
		add	ax,bx
		mov	di,ax
		pop	si
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

dbl_char_render_loop:
						push	cx
						lodsb				; String [si] to al
						call	double_char_bits
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
						and	dl,cs:tile_fg_mask
						and	dh,cs:tile_fg_mask
						and	ch,cs:tile_fg_mask
						and	es:[di],bx
						and	es:[di+2],cl
						or	es:[di],dx
						or	es:[di+2],ch
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	dbl_char_bank_ok			; Jump if below
						and	es:[di],bx
						and	es:[di+2],cl
						or	es:[di],dx
						or	es:[di+2],ch
						add	di,0A05Ah

dbl_char_bank_ok:
						pop	cx
						loop	dbl_char_render_loop		; Loop if cx > 0

		pop	ds
		retn

render_text_char_alt		endp

double_char_bits		proc	near
		mov	cx,8

double_bits_loop:
						add	al,al
						adc	bx,bx
						add	bx,bx
						loop	double_bits_loop		; Loop if cx > 0

		mov	dx,bx
		shr	dx,1			; Shift w/zeros fill
		or	dx,bx
		retn

double_char_bits		endp

hgc_copy_region:
		push	ds
		add	bh,bh
		call	calc_hgc_address
		mov	di,ax
		mov	si,di
		add	si,2000h
		cmp	si,6000h
		jb	copy_sprite_bank_ok			; Jump if below
		add	si,hgc_stride

copy_sprite_bank_ok:
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

copy_sprite_row_loop:
						push	cx
						push	di
						push	si
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	si
						pop	di
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	copy_sprite_bank_wrap			; Jump if below
						push	di
						push	si
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	si
						pop	di
						add	di,0A05Ah

copy_sprite_bank_wrap:
						add	si,2000h
						cmp	si,6000h
						jb	copy_sprite_src_bank_ok			; Jump if below
						add	si,0A05Ah

copy_sprite_src_bank_ok:
						pop	cx
						loop	copy_sprite_row_loop		; Loop if cx > 0

		pop	ds
		retn

hgc_read_region:
		push	ds
		add	di,0
		mov	bx,ax
		add	bh,bh
		call	calc_hgc_address
		mov	si,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,0B000h
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

save_sprite_row_loop:
						push	cx
						push	si
						mov	cx,bx
						rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
						pop	si
						add	si,2000h
						cmp	si,6000h
						jb	save_sprite_bank_ok			; Jump if below
						add	si,0A05Ah

save_sprite_bank_ok:
						pop	cx
						loop	save_sprite_row_loop		; Loop if cx > 0

		pop	ds
		retn

hgc_copy_to_level:
		push	ds
		mov	si,di
		add	si,0
		mov	bx,ax
		add	bh,bh
		call	calc_hgc_address
		mov	di,ax
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	ax,0B000h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

restore_sprite_row_loop:
						push	cx
						push	si
						push	di
						mov	cx,bx
						rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
						pop	di
						pop	si
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	restore_sprite_bank_ok			; Jump if below
						push	si
						push	di
						mov	cx,bx
						rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
						pop	di
						pop	si
						add	di,0A05Ah

restore_sprite_bank_ok:
						add	si,bx
						add	si,bx
						pop	cx
						loop	restore_sprite_row_loop		; Loop if cx > 0

		pop	ds
		retn

render_string:					; called externally: init char_src_ptr=bx, char_bit_idx=cl, color=1, then render string at si
		mov	cs:char_src_ptr,bx
		mov	cs:char_bit_idx,cl
		mov	byte ptr cs:char_color,1

render_string_next_char:
										lodsb				; String [si] to al
										cmp	al,0FFh
										jne	render_string_not_end			; Jump if not equal
										retn

render_string_not_end:
										cmp	al,0Dh
										je	render_string_newline			; Jump if equal
										or	al,al			; Zero ?
										js	render_string_color			; Jump if sign=1
										push	cx
										push	bx
										push	si
										mov	ah,cs:char_color
										call	render_text_char_alt
										pop	si
										pop	bx
										pop	cx
										add	bx,8
										jmp	short render_string_next_char

render_string_newline:
										add	byte ptr cs:char_bit_idx,8
										mov	cl,cs:char_bit_idx
										mov	bx,cs:char_src_ptr
										jmp	short render_string_next_char

render_string_color:
						and	al,7
						mov	cs:char_color,al
						jmp	short render_string_next_char

fn_0_blit_region:				; dispatch fn 0: blit rectangular region from (bh/ch) to (dx) in HGC framebuffer
		push	ds
		add	bh,bh
		call	calc_hgc_address
		mov	si,ax
		mov	bx,dx
		add	bh,bh
		call	calc_hgc_address
		mov	di,ax
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

blit_region_row_loop:
						push	cx
						push	di
						push	si
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	si
						pop	di
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	blit_region_bank_ok			; Jump if below
						push	di
						push	si
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	si
						pop	di
						add	di,0A05Ah

blit_region_bank_ok:
						add	si,2000h
						cmp	si,6000h
						jb	blit_region_src_bank_ok			; Jump if below
						add	si,0A05Ah

blit_region_src_bank_ok:
						pop	cx
						loop	blit_region_row_loop		; Loop if cx > 0

		pop	ds
		retn

fn_1_draw_digit:				; dispatch fn 1: draw score digit at (bh,al) using tile_color_tbl_b pattern
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	al,ds:tile_color_tbl_b[bx]
		mov	ds:tile_fg_mask,al
		pop	bx
		call	calc_hgc_address
		mov	di,ax
		mov	ax,0B000h
		mov	es,ax
		call	fill_rectangle
		mov	cx,10h

draw_digit_row_loop:
						mov	al,ds:tile_fg_mask
						and	al,0F0h
						and	byte ptr es:[di],0Fh
						or	es:[di],al
						mov	al,ds:tile_fg_mask
						and	al,0Fh
						and	byte ptr es:[di+4],0F0h
						or	es:[di+4],al
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	draw_digit_bank_ok			; Jump if below
						mov	al,ds:tile_fg_mask
						and	al,0F0h
						and	byte ptr es:[di],0Fh
						or	es:[di],al
						mov	al,ds:tile_fg_mask
						and	al,0Fh
						and	byte ptr es:[di+4],0F0h
						or	es:[di+4],al
						add	di,hgc_stride

draw_digit_bank_ok:
						loop	draw_digit_row_loop		; Loop if cx > 0

		call	fill_rectangle
		retn

fill_rectangle		proc	near
		mov	cx,2

fill_rect_row_loop:
						push	cx
						push	di
						mov	al,ds:tile_fg_mask
						mov	cx,5
						rep	stosb			; Rep when cx >0 Store al to es:[di]
						pop	di
						add	di,2000h
						cmp	di,hgc_bank_size
						jb	fill_rect_bank_ok			; Jump if below
						push	di
						mov	al,ds:tile_fg_mask
						mov	cx,5
						rep	stosb			; Rep when cx >0 Store al to es:[di]
						pop	di
						add	di,0A05Ah

fill_rect_bank_ok:
						pop	cx
						loop	fill_rect_row_loop		; Loop if cx > 0

		retn

fill_rectangle		endp

; tile_color_tbl_b (equ 2CA7h): 8-entry tile color table B: HGC pixel pattern values
		db	 00h,0FFh,0AAh,0FFh, 55h,0FFh
		db	0FFh,0AAh

draw_sprite_entry:				; set DS=CS, compute sprite ptr+screen addr, fall into draw_sprite_row_loop
		push	ds
		push	si
		push	cs
		pop	ds
		xor	ah, ah			; Zero register
		add	ax, ax			; ax *= 2
		add	ax, ax			; ax *= 4 (sprite index * 4)
		mov	si, ax
		call	calc_hgc_address
		mov	di, ax
		SET_HGC_ES			; mov ax,0B000h / mov es,ax
		mov	bx, [si+2D2Ah]		; sprite mask ptr (game segment sprite pointer table)
		mov	si, [si+2D2Ch]		; sprite data ptr
		mov	cx, 0Dh

draw_sprite_row_loop:
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
						cmp	di,hgc_bank_size
						jb	draw_sprite_bank_ok			; Jump if below
						mov	bp,di
						sub	bp,2000h
						mov	ax,es:[bp]
						mov	es:[di],ax
						mov	ax,es:[bp+2]
						mov	es:[di+2],ax
						add	di,0A05Ah

draw_sprite_bank_ok:
						pop	cx
						loop	draw_sprite_row_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn

sprite_bitmap_b:				; sprite_data_b: 4-word frame addr table + 4 frames x 13 rows x 4 bytes HGC bitmap
		dw	02D32h			; frame 0 ptr (row  0, offset +8)
		dw	02D9Ah			; frame 1 ptr (row 26, offset +112)
		dw	02D66h			; frame 2 ptr (row 13, offset +60)
		dw	02DCEh			; frame 3 ptr (row 39, offset +164)
		; frame 0: rows 0..12 (mask=FF and blanking border rows)
		db	0FFh,0F0h, 0Ch,0FFh	; row  0
		db	0FFh,0C0h, 00h,0FFh	; row  1
		db	0FFh, 00h, 00h,0FFh	; row  2
		db	0FFh, 00h, 00h,0FFh	; row  3
		db	0FFh, 00h, 00h,0FFh	; row  4
		db	0FFh, 00h, 00h,0FFh	; row  5
		db	0FFh, 00h, 00h,0FFh	; row  6
		db	0FFh,0C0h, 00h,0FFh	; row  7
		db	0FFh,0C0h, 00h,0FFh	; row  8
		db	0FFh,0C0h, 00h,0FFh	; row  9
		db	0FFh,0CCh, 0Ch,0FFh	; row 10
		db	9 dup (0FFh)		; rows 11-12: all-FF + 1 byte
		; frame 2: rows 13..25 (larger character sprite)
		db	 00h, 00h,0FFh,0FCh, 00h, 00h	; row 13-14
		db	 3Fh,0F0h, 00h, 00h, 0Fh,0F0h	; row 15-16
		db	 00h, 00h, 0Fh,0C0h, 00h, 00h	; row 17-18
		db	 03h,0C0h, 00h, 00h, 03h,0C0h	; row 19-20
		db	 00h, 00h, 03h,0C0h, 00h, 00h	; row 21-22
		db	 03h,0F0h, 00h, 00h, 0Fh,0F0h	; row 23-24
		db	 00h, 00h, 0Fh,0FCh, 00h, 00h	; row 25
		; frame 1: rows 26..38 (small figure sprite)
		db	 3Fh,0FFh, 00h, 00h,0FFh,0FFh	; row 26-27
		db	0C0h, 03h,0FFh, 00h, 00h, 00h	; row 28
		db	 00h, 00h, 0Ah,0A0h, 00h, 00h	; row 29
		db	 3Bh,0F8h, 00h, 00h, 2Fh,0D6h	; row 30-31
		db	 00h, 00h,0E7h,0D6h, 00h, 00h	; row 32
		db	0E5h, 56h, 00h, 00h,0A5h, 56h	; row 33-34
		db	 00h, 00h, 25h, 56h, 00h, 00h	; row 35
		db	 29h, 58h, 00h, 00h, 0Ah,0A0h	; row 36-37
		db	 00h, 00h			; row 38
		db	12 dup (0)			; row 39 pad (blank rows)
		; frame 3: rows 39..51 (running figure sprite)
		db	 3Fh,0D4h, 00h, 00h,0F0h, 05h	; row 39-40
		db	 00h, 03h,0CFh,0C1h, 40h, 0Fh	; row 41-42
		db	 3Fh, 0Ch, 50h, 0Fh,0FCh, 03h	; row 43-44
		db	 50h, 0Ch,0F0h,0A0h, 10h, 0Ch	; row 45-46
		db	0C2h,0AAh, 90h, 0Dh,0EAh,0AAh	; row 47-48
		db	0D0h, 0Dh,0BAh,0AAh,0F0h, 01h	; row 49-50
		db	 6Bh,0ABh,0C0h, 00h, 58h,0AFh	; row 51
		db	 00h, 00h, 1Dh, 54h, 00h, 00h	; row 52
		db	 00h, 00h, 00h		; row 53 tail + pad

hgc_vram_init:					; fn 11: clear HGC VRAM (rep stosw 0 to B000:0 x 4000h words)
		SET_HGC_ES			; mov ax,0B000h / mov es,ax
		xor	di, di			; Zero register
		xor	ax, ax			; Zero register
		mov	cx, 4000h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

calc_hgc_address		proc	near
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

calc_hgc_address		endp

fn_12_decode_sprites:				; dispatch fn 12: decode sprite bitplanes from CS+3000h temp buffer → CS+3000h packed pixels
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

sprite_decode_row_loop:
						push	cx
						call	process_sprite_row
						pop	cx
						loop	sprite_decode_row_loop		; Loop if cx > 0

		retn

process_sprite_row		proc	near
		mov	cx,8

sprite_decode_inner_loop:
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
						loop	sprite_decode_inner_loop		; Loop if cx > 0

		retn

process_sprite_row		endp

		db	12 dup (0)

seg_a		ends

		end	start
