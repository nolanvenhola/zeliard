
PAGE  59,132

;==========================================================================
;
;  PLAYER_STATS - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr1com.inc

; restored after factoring (consensus value, but not all files agree):
sprite_row_buf_b         equ     5500h
sprite_mask_off          equ     1A8Eh


; The following equates show data references outside the range of the program.

cga_plane2_buf		equ	29DCh			;*
tga_mask_tbl_a		equ	32FCh			;*
tga_mask_tbl_b		equ	3304h			;*
sprite_src_tbl		equ	3640h			;*
sprite_frame_tbl	equ	3642h			;*
move_seq_up		equ	3B04h			;*
move_seq_horiz		equ	3BC8h			;*
color_pair_tbl		equ	3BFBh			;*
color_pair_tbl_b	equ	3BFCh			;*
tga_palette_xlat	equ	4BD4h			;*
tga_color_lut		equ	4BFDh			;*
src_word_a		equ	4BFFh			;*
src_word_b		equ	4C01h			;*
src_word_c		equ	4C03h			;*
src_word_d		equ	4C05h			;*
src_word_e		equ	4C07h			;*
cur_col_ctr		equ	4C09h			;*
cur_row_ctr		equ	4C0Ah			;*
cur_pass_ctr		equ	4C0Bh			;*
render_mode_flag	equ	4C0Ch			;*
render_fn_ptr		equ	4C0Fh			;*
saved_di		equ	4C11h			;*
saved_es		equ	4C13h			;*
sprite_row_buf		equ	5255h			;*
tga_bank_wrap		equ	80A0h			;*  Tandy bank advance after 0x8000 wrap
tga_color_reg		equ	0BF07h			;*
tga_vram_seg		equ	0B800h			;   Tandy framebuffer segment
font_ptr_a		equ	0F500h			;*
gvar_frame_timer	equ	0FF1Ah			;*
gvar_game_seg		equ	0FF2Ch			;*
tga_screen_start	equ	0			;*  Tandy framebuffer copy-back start
tga_work_buf		equ	8000h			;*  Tandy work buffer base
tga_work_buf_p2		equ	80A0h			;*  tga_work_buf second bank
tga_src_start		equ	0			;*
tga_dst_start		equ	0
tga_buf_wrap		equ	80A0h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

zr1_04		proc	far

start:
		cwd				; Word to double word
		and	al,[bx+si]
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
		dec	bx
		xor	dh,[bx+si]
		xor	byte ptr [bx+si],0D4h
;*		xor	dh,dl
		db	 30h,0D6h		;  Fixup - byte match
		inc	cx
		mov	cl,[bp+di+0Ch]
		xor	di,[bx+di+33h]
		push	word ptr [bp+di]
;*		jg	loc_1			;*Jump if >
		jg	init_data_block
; Render function dispatch table: count byte + word offsets
; 12 entries for render sub-functions, indexed by render_fn_ptr

render_fn_disp_tbl:
		db	00Ch			; was: db 07Fh, 034h (count=12)
		db	 60h, 36h,0B4h, 36h, 08h, 37h
		db	0ECh, 30h, 47h, 37h,0C9h, 37h
		db	0C3h, 38h, 01h, 3Ch, 4Bh, 3Dh
		db	 06h, 3Eh, 5Ch, 3Eh, 39h, 40h
		db	 19h, 41h,0B2h, 41h,0C4h, 4Bh
		db	 50h, 53h, 51h, 1Eh, 8Ah,0C5h
		db	0F6h,0E1h, 8Bh,0E8h, 06h, 1Fh
		db	 8Bh,0F7h, 8Ch,0C8h, 05h, 00h
		db	 30h, 8Eh,0C0h,0BFh

; Self-modifying init: clears src_word_a/src_word_b, then sets up CX for render loop

init_data_block:
		db	 00h, 00h, 2Eh,0C7h, 06h, 01h
		db	 4Ch, 00h, 00h, 2Eh,0C7h, 06h
		db	 03h, 4Ch, 00h, 00h, 8Bh,0CDh
		db	0D1h,0E9h

render_2plane_loop:
						mov	ax,ds:[bp+si]
						xchg	ah,al
						mov	cs:src_word_d,ax
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	render_2plane_loop		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		pop	ax
		mov	di,0
		jmp	render_2plane_blit

render_3plane_setup:
		push	ax
		push	bx
		push	cx
		push	ds
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bp,ax
		push	es
		pop	ds
		mov	si,di
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	di,0
		mov	word ptr cs:src_word_d,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

render_3plane_loop:
						add	bp,bp
						mov	ax,ds:[bp+si]
						xchg	al,ah
						mov	cs:src_word_c,ax
						shr	bp,1			; Shift w/zeros fill
						mov	ax,ds:[bp+si]
						xchg	al,ah
						mov	cs:src_word_b,ax
						lodsw				; String [si] to ax
						xchg	al,ah
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	render_3plane_loop		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		pop	ax
		mov	di,0
		jmp	render_2plane_blit

render_1plane_blit:
		push	ds
		push	ax
		push	es
		push	di
		call	extract_bits_2
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,32CAh
		call	stats_func_1
		pop	ds
		retn

render_4plane_alt:
		push	bx
		push	cx
		push	ds
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bp,ax
		push	es
		pop	ds
		mov	si,di
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	di,0
		mov	word ptr cs:src_word_a,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

render_4plane_loop:
						push	cx
						mov	bx,ds:[bp+si]
						xchg	bh,bl
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	dx,bx
						and	dx,ax
						mov	cx,bx
						or	cx,ax
						not	dx
						and	ax,dx
						and	bx,dx
						mov	cs:src_word_c,bx
						mov	cs:src_word_b,ax
						mov	cs:src_word_d,cx
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						pop	cx
						loop	render_4plane_loop		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		xor	ax,ax			; Zero register
		mov	di,0
		push	ds
		push	ax
		push	es
		push	di
		call	extract_bits_2
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,3290h
		mov	byte ptr cs:render_mode_flag,0
		or	al,al			; Zero ?
		jnz	render_opaque_call			; Jump if not zero
		call	stats_func_1

render_opaque_call:
		mov	byte ptr cs:render_mode_flag,0FFh
		call	stats_func_1
		pop	ds
		retn

render_2plane_blit:
		push	ds
		push	ax
		push	es
		push	di
		call	extract_bits_2
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,3234h
		mov	byte ptr cs:render_mode_flag,0
		or	al,al			; Zero ?
		jnz	render_blit_done			; Jump if not zero
		call	stats_func_1

render_blit_done:
		mov	byte ptr cs:render_mode_flag,0FFh
		call	stats_func_1
		pop	ds
		retn

zr1_04		endp

stats_func_1		proc	near
		mov	byte ptr cs:cur_row_ctr,0
		mov	ax,tga_vram_seg
		mov	es,ax
		mov	bp,8

render_pass_loop:
		mov	al,cs:cur_row_ctr
		mov	cs:cur_col_ctr,al
		mov	byte ptr cs:gvar_frame_timer,0
		push	cx
		push	si
		push	di

render_col_loop:
						mov	bl,cs:cur_col_ctr
						and	bx,7
						mov	bl,cs:tga_mask_tbl_a[bx]
						call	word ptr cs:render_fn_ptr
						inc	byte ptr cs:cur_col_ctr
						mov	al,ch
						xor	ah,ah			; Zero register
						add	ax,ax
						add	si,ax
						add	di,2000h
						cmp	di,tga_work_buf
						jb	tga_wrap_a			; Jump if below
						add	di,tga_bank_wrap

tga_wrap_a:
						dec	cl
						jz	render_col_done			; Jump if zero
						mov	bl,cs:cur_col_ctr
						and	bx,7
						mov	bl,cs:tga_mask_tbl_b[bx]
						call	word ptr cs:render_fn_ptr
						inc	byte ptr cs:cur_col_ctr
						mov	al,ch
						xor	ah,ah			; Zero register
						add	ax,ax
						add	si,ax
						add	di,2000h
						cmp	di,tga_work_buf
						jb	tga_wrap_b			; Jump if below
						add	di,tga_bank_wrap

tga_wrap_b:
						dec	cl
						jnz	render_col_loop			; Jump if not zero

render_col_done:
		pop	di
		pop	si
		pop	cx
		inc	byte ptr cs:cur_row_ctr

frame_timer_wait:
						cmp	byte ptr cs:gvar_frame_timer,14h
						jb	frame_timer_wait			; Jump if below
		dec	bp
		jz	render_pass_ret		; Jump if zero
		jmp	render_pass_loop

render_pass_ret:
		retn

stats_func_1		endp

blit_mask_blend:
		test	byte ptr cs:render_mode_flag,0FFh
		jz	mask_or_entry			; Jump if zero
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx

mask_blend_loop:
						lodsb				; String [si] to al
						rol	bl,1			; Rotate
						jnc	blend_hi_nibble			; Jump if carry=0
						and	byte ptr es:[di],0Fh
						mov	ah,al
						and	ah,0F0h
						or	es:[di],ah

blend_hi_nibble:
						rol	bl,1			; Rotate
						jnc	blend_lo_nibble			; Jump if carry=0
						and	byte ptr es:[di],0F0h
						and	al,0Fh
						or	es:[di],al

blend_lo_nibble:
						inc	di
						loop	mask_blend_loop		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn

mask_or_entry:
						push	si
						push	di
						push	cx
						mov	cl,ch
						xor	ch,ch			; Zero register
						add	cx,cx

mask_or_loop:
										lodsb				; String [si] to al
										rol	bl,1			; Rotate
										jnc	or_hi_nibble			; Jump if carry=0
										mov	ah,al
										and	ah,0F0h
										or	es:[di],ah

or_hi_nibble:
										rol	bl,1			; Rotate
										jnc	or_lo_nibble			; Jump if carry=0
										and	al,0Fh
										or	es:[di],al

or_lo_nibble:
										inc	di
										loop	mask_or_loop		; Loop if cx > 0

						pop	cx
						pop	di
						pop	si
						retn

blit_mask_transp:
						test	byte ptr cs:render_mode_flag,0FFh
						jz	mask_or_entry			; Jump if zero
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx

transp_blend_loop:
						lodsb				; String [si] to al
						rol	bl,1			; Rotate
						jnc	transp_hi_nibble			; Jump if carry=0
						mov	ah,al
						and	ah,0F0h
						jz	transp_hi_nibble			; Jump if zero
						and	byte ptr es:[di],0Fh
						or	es:[di],ah

transp_hi_nibble:
						rol	bl,1			; Rotate
						jnc	transp_lo_nibble			; Jump if carry=0
						and	al,0Fh
						jz	transp_lo_nibble			; Jump if zero
						and	byte ptr es:[di],0F0h
						or	es:[di],al

transp_lo_nibble:
						inc	di
						loop	transp_blend_loop		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn

blit_mask_clear:
		push	di
		push	cx
		not	bl
		mov	cl,ch
		xor	ch,ch			; Zero register

mask_clear_loop:
						rol	bl,1			; Rotate
						sbb	al,al
						and	al,0Fh
						mov	dl,al
						rol	bl,1			; Rotate
						sbb	al,al
						and	al,0F0h
						or	dl,al
						rol	bl,1			; Rotate
						sbb	al,al
						and	al,0Fh
						mov	dh,al
						rol	bl,1			; Rotate
						sbb	al,al
						and	al,0F0h
						or	dh,al
						and	es:[di],dx
						inc	di
						inc	di
						loop	mask_clear_loop		; Loop if cx > 0

		pop	cx
		pop	di
		retn

glyph_init_entry:
		and	byte ptr [bx+si],8
		add	al,[bx+si+10h]
		add	al,1
		add	[si],ax
		adc	[bx+si+2],al
		or	[bx+si],ah
		or	byte ptr ds:tga_color_reg,15h
		dec	sp
		xor	ax,ax			; Zero register
		mov	cx,320h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	di,4C15h

glyph_char_loop:
						lodsb				; String [si] to al
						cmp	al,0FFh
						jne	glyph_term_check			; Jump if not equal
						retn

glyph_term_check:
						sub	al,20h			; ' '
						jnc	glyph_space_check			; Jump if carry=0
						retn

glyph_space_check:
						jz	glyph_advance			; Jump if zero
						push	si
						push	di
						xor	ah,ah			; Zero register
						add	ax,ax
						add	ax,ax
						add	ax,ax
						add	ax,ds:font_ptr_a
						mov	si,ax
						mov	cx,8

glyph_row_loop:
										push	cx
										lodsb				; String [si] to al
										call	stats_func_2
										mov	es:[di],dx
										call	stats_func_2
										mov	es:[di+2],dx
										add	di,0A0h
										pop	cx
										loop	glyph_row_loop		; Loop if cx > 0

						pop	di
						pop	si

glyph_advance:
						add	di,4
						jmp	short glyph_char_loop

stats_func_2		proc	near
		add	al,al
		sbb	ah,ah
		and	ah,0F0h
		add	al,al
		sbb	dl,dl
		and	dl,0Fh
		or	dl,ah
		add	al,al
		sbb	ah,ah
		and	ah,0F0h
		add	al,al
		sbb	dh,dh
		and	dh,0Fh
		or	dh,ah
		retn

stats_func_2		endp

sprite_blit_entry:
		push	ds
		push	cx
		push	bx
		mov	dl,0A0h
		mul	dl			; ax = reg * al
		add	ax,4C15h
		mov	si,ax
		add	cl,bl
		mov	al,0A0h
		mul	cl			; ax = reg * al
		add	ax,8000h
		push	ax
		push	si
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		push	ds
		pop	es
		mov	di,tga_work_buf
		mov	si,tga_work_buf_p2
		mov	cx,3FB0h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		push	cs
		pop	ds
		mov	cx,50h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	bx
		push	bx
		call	extract_bits_2
		mov	di,ax
		pop	bx
		mov	al,0A0h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	si,ax
		add	si,0
		mov	bp,ax
		add	bp,tga_work_buf
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	ax,tga_vram_seg
		mov	es,ax
		pop	cx
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

spr_blit_row_loop:
						push	cx
						push	di
						mov	cx,bx

spr_blit_col_loop:
										lodsw				; String [si] to ax
										or	ax,ds:[bp]
										stosw				; Store ax to es:[di]
										inc	bp
										inc	bp
										loop	spr_blit_col_loop		; Loop if cx > 0

						pop	di
						add	di,2000h
						cmp	di,tga_work_buf
						jb	spr_blit_wrap			; Jump if below
						add	di,tga_bank_wrap

spr_blit_wrap:
						pop	cx
						loop	spr_blit_row_loop		; Loop if cx > 0

		pop	ds
		retn

render_xor_entry:
		push	ds
		push	ax
		push	bx
		push	cx
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bp,ax
		push	es
		pop	ds
		mov	si,di
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	di,0
		mov	word ptr cs:src_word_d,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

xor_pixel_loop:
						add	bp,bp
						mov	ax,ds:[bp+si]
						xchg	ah,al
						mov	cs:src_word_c,ax
						shr	bp,1			; Shift w/zeros fill
						mov	ax,ds:[bp+si]
						xchg	ah,al
						mov	cs:src_word_b,ax
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	xor_pixel_loop		; Loop if cx > 0

		pop	cx
		pop	bx
		pop	ax
		pop	ds

blit_to_tga:
		push	ds
		call	extract_bits_2
		mov	di,ax
		mov	si,tga_src_start
		push	es
		pop	ds
		mov	ax,tga_vram_seg
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ch
		add	bx,bx
		xor	ch,ch			; Zero register

tga_blit_row_loop:
						push	cx
						push	di
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	di
						pop	cx
						add	di,2000h
						cmp	di,tga_work_buf
						jb	blit_tga_wrap			; Jump if below
						add	di,tga_bank_wrap

blit_tga_wrap:
						loop	tga_blit_row_loop		; Loop if cx > 0

		pop	ds
		retn

sprite_obj_init:
		push	cs
		pop	es
		mov	di,sprite_obj_tbl
		xor	dx,dx			; Zero register
		mov	cx,9

obj_init_loop:
						mov	al,1
						stosb				; Store al to es:[di]
						mov	ax,dx
						stosw				; Store ax to es:[di]
						movsw				; Mov [si] to es:[di]
						stosw				; Store ax to es:[di]
						mov	ax,101h
						stosw				; Store ax to es:[di]
						movsb				; Mov [si] to es:[di]
						movsb				; Mov [si] to es:[di]
						xor	al,al			; Zero register
						stosb				; Store al to es:[di]
						stosb				; Store al to es:[di]
						movsb				; Mov [si] to es:[di]
						movsb				; Mov [si] to es:[di]
						add	dx,180h
						loop	obj_init_loop		; Loop if cx > 0

		mov	byte ptr ds:gvar_frame_timer,0

obj_anim_loop:
		mov	si,sprite_obj_tbl
		mov	cx,9

obj_anim_entry:
						push	cx
						test	byte ptr [si],0FFh
						jz	obj_update_next			; Jump if zero
						mov	al,[si+0Dh]
						cmp	al,[si+0Eh]
						je	obj_update_frame			; Jump if equal
						inc	byte ptr [si+0Ch]
						test	byte ptr [si+0Ch],1
						jnz	obj_update_frame			; Jump if not zero
						inc	byte ptr [si+0Dh]

obj_update_frame:
						xor	bx,bx			; Zero register
						mov	bl,[si+0Dh]
						add	bx,bx
						add	bx,bx
						mov	cx,ds:sprite_frame_tbl[bx]
						mov	[si+7],cx
						mov	al,[si+4]
						add	al,[si+0Ah]
						mov	[si+4],al
						mov	bh,al
						mov	al,[si+3]
						add	al,[si+9]
						mov	[si+3],al
						mov	bl,al
						call	extract_bits_2
						mov	[si+5],ax
						mov	di,ax
						mov	bp,[si+1]
						push	ds
						push	si
						mov	ax,tga_vram_seg
						mov	ds,ax
						mov	ax,cs
						add	ax,3000h
						mov	es,ax
						mov	si,di
						mov	di,bp
						call	copy_buffer
						pop	si
						pop	ds

obj_update_next:
						pop	cx
						add	si,0Fh
						loop	obj_anim_entry		; Loop if cx > 0

		mov	si,sprite_obj_tbl
		mov	cx,9

obj_draw_entry:
						push	cx
						test	byte ptr cs:[si],0FFh
						jz	obj_draw_skip			; Jump if zero
						xor	bx,bx			; Zero register
						mov	bl,[si+0Dh]
						add	bx,bx
						add	bx,bx
						mov	bp,ds:sprite_src_tbl[bx]
						mov	cx,[si+7]
						mov	dl,[si]
						mov	byte ptr [si],0
						mov	ax,[si+3]
						cmp	ah,4Bh			; 'K'
						jae	obj_draw_skip			; Jump if above or =
						cmp	al,0A0h
						jae	obj_draw_skip			; Jump if above or =
						mov	[si],dl
						mov	di,[si+5]
						push	ds
						push	si
						mov	ax,tga_vram_seg
						mov	es,ax
						mov	ds,cs:gvar_game_seg
						mov	si,bp
						call	stats_multiply
						pop	si
						pop	ds

obj_draw_skip:
						pop	cx
						add	si,0Fh
						loop	obj_draw_entry		; Loop if cx > 0

obj_vblank_wait:
						cmp	byte ptr cs:gvar_frame_timer,1Eh
						jb	obj_vblank_wait			; Jump if below
		mov	byte ptr cs:gvar_frame_timer,0
		mov	si,sprite_obj_tbl
		mov	cx,9

obj_blit_entry:
						push	cx
						mov	bp,[si+1]
						mov	di,[si+5]
						mov	cx,[si+7]
						push	ds
						push	si
						mov	ax,tga_vram_seg
						mov	es,ax
						mov	ax,cs
						add	ax,3000h
						mov	ds,ax
						mov	si,bp
						call	copy_buffer_2
						pop	si
						pop	ds
						pop	cx
						add	si,0Fh
						loop	obj_blit_entry		; Loop if cx > 0

		mov	si,sprite_obj_tbl
		mov	cx,9

obj_active_loop:
						test	byte ptr [si],0FFh
						jz	obj_active_next			; Jump if zero
						jmp	obj_anim_loop

obj_active_next:
						add	si,0Fh
						loop	obj_active_loop		; Loop if cx > 0

		retn

copy_buffer		proc	near
		push	si
		push	cx

cpybuf_row_loop:
						push	si
						push	cx
						mov	cl,ch
						xor	ch,ch			; Zero register
						add	cx,cx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	cx
						pop	si
						add	si,2000h
						cmp	si,tga_work_buf
						jb	cpybuf_wrap			; Jump if below
						add	si,tga_bank_wrap

cpybuf_wrap:
						dec	cl
						jnz	cpybuf_row_loop			; Jump if not zero
		pop	cx
		pop	si
		retn

copy_buffer		endp

copy_buffer_2		proc	near
		push	di
		push	cx

cpybuf2_row_loop:
						push	di
						push	cx
						mov	cl,ch
						xor	ch,ch			; Zero register
						add	cx,cx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	cx
						pop	di
						add	di,2000h
						cmp	di,tga_work_buf
						jb	cpybuf2_wrap			; Jump if below
						add	di,tga_bank_wrap

cpybuf2_wrap:
						dec	cl
						jnz	cpybuf2_row_loop			; Jump if not zero
		pop	cx
		pop	di
		retn

copy_buffer_2		endp

stats_multiply		proc	near
		push	di
		push	cx
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bx,ax
		mov	word ptr cs:src_word_d,0

smul_row_loop:
						push	di
						push	cx
						mov	cl,ch
						xor	ch,ch			; Zero register

smul_col_loop:
										xor	al,al			; Zero register
										mov	ah,[bx+si]
										mov	cs:src_word_b,ax
										mov	ah,[si]
										mov	cs:src_word_a,ax
										mov	cs:src_word_c,ax
										inc	si
										push	bx
										call	stats_process_loop_4
										pop	bx
										or	es:[di],ax
										inc	di
										inc	di
										loop	smul_col_loop		; Loop if cx > 0

						pop	cx
						pop	di
						add	di,2000h
						cmp	di,tga_work_buf
						jb	smul_wrap			; Jump if below
						add	di,tga_bank_wrap

smul_wrap:
						dec	cl
						jnz	smul_row_loop			; Jump if not zero
		pop	cx
		pop	di
		retn

stats_multiply		endp

; Self-modifying stub: render_fn_ptr dispatcher init for 3-plane mode
; Patches CS:[4C05h] and CS:[4C01h] then sets cx for render_2plane_loop

render_3plane_stub:
		db	 00h, 90h, 20h, 06h, 80h, 91h
		db	 20h, 06h, 00h, 93h, 20h, 06h
		db	 80h, 94h, 20h, 06h, 00h, 96h
		db	 18h, 04h,0C0h, 96h, 18h, 04h
		db	 80h, 97h, 18h, 04h
xor3_plane2_off	dw	9840h			; Plane B base offset for XOR 3-plane render
		db	 18h, 04h, 1Eh, 53h, 32h,0E4h
		db	0BAh,0C0h, 0Ch,0F7h,0E2h, 05h
		db	 40h,0ABh, 2Eh, 8Eh, 1Eh, 2Ch
		db	0FFh, 8Bh,0F0h, 8Ch,0C8h, 05h
		db	 00h, 30h, 8Eh,0C0h,0BFh, 00h
		db	 00h, 2Eh,0C7h, 06h, 05h, 4Ch
		db	 00h, 00h, 2Eh,0C7h, 06h, 03h
		db	 4Ch, 00h, 00h,0B9h, 30h, 03h

plane_xor_loop:
						mov	ax,xor3_plane2_off[si]
						xchg	ah,al
						mov	cs:src_word_a,ax
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	cs:src_word_b,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	plane_xor_loop		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,0
		mov	cx,2230h
		jmp	blit_to_tga
; Self-modifying stub: render_fn_ptr dispatcher init for 1-plane mode

render_1plane_stub:
		db	 1Eh, 53h, 32h,0E4h
face_panel2_anchor	db	0BAh
		db	 80h, 04h,0F7h,0E2h, 05h,0C0h
		db	 97h, 2Eh, 8Eh, 1Eh, 2Ch,0FFh
		db	 8Bh,0F0h, 8Ch,0C8h, 05h, 00h
		db	 30h, 8Eh,0C0h,0BFh, 00h, 00h
		db	 2Eh,0C7h, 06h, 05h, 4Ch, 00h
		db	 00h, 2Eh,0C7h, 06h, 03h, 4Ch
		db	 00h, 00h,0B9h, 20h, 01h

plane_xor2_loop:
						mov	ax,ds:cga_plane2_off[si]
						xchg	ah,al
						mov	cs:src_word_b,ax
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	plane_xor2_loop		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,tga_dst_start
		mov	cx,1220h
		jmp	blit_to_tga

tga_clear_screen:
		mov	ax,tga_vram_seg
		mov	es,ax
		xor	di,di			; Zero register
		mov	cx,64h

tga_clear_row_loop:
						push	cx
						push	di
						mov	ax,101h
						mov	cx,50h
						rep	stosw			; Rep when cx >0 Store ax to es:[di]
						pop	di
						add	di,2000h
						cmp	di,tga_work_buf
						jb	clr_plane2_wrap			; Jump if below
						add	di,tga_buf_wrap

clr_plane2_wrap:
						push	di
						mov	ax,1010h
						mov	cx,50h
						rep	stosw			; Rep when cx >0 Store ax to es:[di]
						pop	di
						add	di,2000h
						cmp	di,tga_work_buf
						jb	clr_plane2_done			; Jump if below
						add	di,tga_bank_wrap

clr_plane2_done:
						pop	cx
						loop	tga_clear_row_loop		; Loop if cx > 0

		retn
		db	 33h,0DBh,0B9h, 19h, 00h

char_render_row_loop:
						push	cx
						mov	cx,22h

char_render_col_loop:
										push	cx
										lodsb				; String [si] to al
										push	bx
										push	ds
										push	si
										call	stats_multiply_2
										pop	si
										pop	ds
										pop	bx
										inc	bh
										pop	cx
										loop	char_render_col_loop		; Loop if cx > 0

						xor	bh,bh			; Zero register
						inc	bl
						pop	cx
						loop	char_render_row_loop		; Loop if cx > 0

		retn

stats_multiply_2		proc	near
		mov	ds,cs:gvar_game_seg
		mov	dx,cs
		add	dx,2000h
		mov	es,dx
		xor	ah,ah			; Zero register

col_div40_loop:
						sub	al,28h			; '('
						jc	col_div40_done			; Jump if carry Set
						inc	ah
						jmp	short col_div40_loop

col_div40_done:
		add	al,28h			; '('
		mov	cl,al
		mov	al,ah
		xor	ah,ah			; Zero register
		mov	dx,140h
		mul	dx			; dx:ax = reg * ax
		xor	ch,ch			; Zero register
		add	ax,cx
		add	ax,4000h
		push	ax
		mov	dx,bx
		xor	dh,dh			; Zero register
		mov	ax,110h
		mul	dx			; dx:ax = reg * ax
		mov	dl,bh
		xor	dh,dh			; Zero register
		add	ax,dx
		add	ax,0
		mov	di,ax
		pop	si
		mov	cx,3

char_blit_plane_loop:
						push	cx
						push	di
						push	si
						mov	cx,8

char_blit_row_loop:
										movsb				; Mov [si] to es:[di]
										add	di,21h
										add	si,27h
										loop	char_blit_row_loop		; Loop if cx > 0

						pop	si
						pop	di
						add	di,1A90h
						add	si,640h
						pop	cx
						loop	char_blit_plane_loop		; Loop if cx > 0

		retn

stats_multiply_2		endp

char_draw_entry:
		push	ds
		mov	dx,cs
		mov	es,dx
		add	dx,2000h
		mov	ds,dx
		push	ax
		mov	dl,22h			; '"'
		mul	dl			; ax = reg * al
		add	ax,0
		mov	si,ax
		push	si
		mov	di,sprite_row_buf
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,sprite_plane_b_off
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,sprite_row_buf
		mov	cx,44h

bit_reverse_loop:
						mov	al,es:[di]
						mov	dx,8

bitrev_inner:
										ror	al,1			; Rotate
										adc	ah,ah
										dec	dx
										jnz	bitrev_inner			; Jump if not zero
						mov	es:[di],ah
						inc	di
						loop	bit_reverse_loop		; Loop if cx > 0

		pop	si
		pop	ax
		mov	bl,al
		xor	bh,bh			; Zero register
		call	extract_bits_2
		mov	di,ax
		mov	ax,tga_vram_seg
		mov	es,ax
		push	di
		mov	cx,11h

spr_draw_top_loop:
						push	cx
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	bx,ds:sprite_mask_off[si]
						xchg	bh,bl
						mov	dx,ax
						and	dx,bx
						mov	cs:src_word_a,dx
						or	dx,bx
						mov	cs:src_word_b,dx
						mov	cs:src_word_c,dx
						mov	cs:src_word_d,dx
						or	ax,bx
						not	ax
						mov	cs:src_word_e,ax
						call	stats_func_20
						and	es:[di],ax
						call	stats_process_loop_4
						or	es:[di],ax
						call	stats_func_20
						and	es:[di+2],ax
						call	stats_process_loop_4
						or	es:[di+2],ax
						add	di,4
						pop	cx
						loop	spr_draw_top_loop		; Loop if cx > 0

		pop	di
		add	di,9Ch
		push	cs
		pop	ds
		mov	si,sprite_row_buf
		mov	cx,11h

spr_draw_bot_loop:
						push	cx
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	bx,[si+20h]
						xchg	bh,bl
						mov	dx,ax
						and	dx,bx
						mov	cs:src_word_a,dx
						or	dx,bx
						mov	cs:src_word_b,dx
						mov	cs:src_word_c,dx
						mov	cs:src_word_d,dx
						or	ax,bx
						not	ax
						mov	cs:src_word_e,ax
						call	stats_func_20
						and	es:[di+2],ax
						call	stats_process_loop_4
						or	es:[di+2],ax
						call	stats_func_20
						and	es:[di],ax
						call	stats_process_loop_4
						or	es:[di],ax
						sub	di,4
						pop	cx
						loop	spr_draw_bot_loop		; Loop if cx > 0

		pop	ds
		retn

set_color_pair:
		mov	bx,ax
		add	bx,bx
		mov	al,ds:color_pair_tbl[bx]
		mov	ds:cur_row_ctr,al
		mov	al,ds:color_pair_tbl_b[bx]
		mov	ds:cur_col_ctr,al
		mov	ax,tga_vram_seg
		mov	es,ax
		mov	di,288h
		mov	si,move_seq_up

seq_up_loop:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	seq_right_entry			; Jump if zero
						call	stats_func_7
						add	di,0A0h
						jmp	short seq_up_loop

seq_right_entry:
		add	di,0FF62h

seq_right_loop:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	seq_down_entry			; Jump if zero
						call	stats_func_7
						inc	di
						inc	di
						jmp	short seq_right_loop

seq_down_entry:
		add	di,0FF5Eh

seq_down_loop:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	seq_left_entry			; Jump if zero
						call	stats_func_7
						add	di,0FF60h
						jmp	short seq_down_loop

seq_left_entry:
		add	di,9Eh

seq_left_loop:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	seq2_start			; Jump if zero
						call	stats_func_7
						dec	di
						dec	di
						jmp	short seq_left_loop

seq2_start:
		add	di,0A2h
		mov	si,move_seq_horiz

move_seq_step:
						mov	byte ptr cs:gvar_frame_timer,0
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jnz	move_dir_step			; Jump if not zero
						retn

move_dir_step:
						xor	cx,cx			; Zero register
						mov	cl,al

move_up_col_loop:
										push	cx
										mov	al,18h
										call	stats_func_7
										add	di,0A0h
										pop	cx
										loop	move_up_col_loop		; Loop if cx > 0

						add	di,0FF60h
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jnz	move_right_step			; Jump if not zero
						retn

move_right_step:
						xor	cx,cx			; Zero register
						mov	cl,al

move_right_col_loop:
										push	cx
										mov	al,18h
										call	stats_func_7
										inc	di
										inc	di
										pop	cx
										loop	move_right_col_loop		; Loop if cx > 0

						dec	di
						dec	di
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jnz	move_down_step			; Jump if not zero
						retn

move_down_step:
						xor	cx,cx			; Zero register
						mov	cl,al

move_down_col_loop:
										push	cx
										mov	al,18h
										call	stats_func_7
										add	di,0FF60h
										pop	cx
										loop	move_down_col_loop		; Loop if cx > 0

						add	di,0A0h
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jnz	move_left_step			; Jump if not zero
						retn

move_left_step:
						xor	cx,cx			; Zero register
						mov	cl,al

move_left_col_loop:
										push	cx
										mov	al,18h
										call	stats_func_7
										dec	di
										dec	di
										pop	cx
										loop	move_left_col_loop		; Loop if cx > 0

						inc	di
						inc	di

move_seq_wait:
										cmp	byte ptr cs:gvar_frame_timer,0Ch
										jb	move_seq_wait			; Jump if below
						jmp	short move_seq_step

stats_func_7		proc	near
		push	si
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,3A44h
		mov	si,ax
		push	di
		mov	bh,cs:cur_col_ctr
		call	extract_bits
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,tga_work_buf
		jb	tile_col1_wrap			; Jump if below
		add	di,tga_bank_wrap

tile_col1_wrap:
		mov	bh,cs:cur_col_ctr
		ror	bh,1			; Rotate
		call	extract_bits
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,tga_work_buf
		jb	tile_col2_wrap			; Jump if below
		add	di,tga_bank_wrap

tile_col2_wrap:
		mov	bh,cs:cur_col_ctr
		call	extract_bits
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,tga_work_buf
		jb	tile_col3_wrap			; Jump if below
		add	di,tga_bank_wrap

tile_col3_wrap:
		mov	bh,cs:cur_col_ctr
		ror	bh,1			; Rotate
		call	extract_bits
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		pop	di
		pop	si
		retn

stats_func_7		endp

extract_bits		proc	near
		mov	word ptr ds:src_word_a,0
		mov	word ptr ds:src_word_d,0
		mov	ah,[si+4]
		mov	ds:src_word_c,ax
		mov	ds:src_word_b,ax
		lodsb				; String [si] to al
		and	al,bh
		mov	ah,al
		mov	al,ds:cur_row_ctr
		shr	al,1			; Shift w/zeros fill
		jnc	xtb_bit1_skip			; Jump if carry=0
		or	ds:src_word_a,ax

xtb_bit1_skip:
		shr	al,1			; Shift w/zeros fill
		jnc	xtb_bit2_skip			; Jump if carry=0
		or	ds:src_word_b,ax

xtb_bit2_skip:
		shr	al,1			; Shift w/zeros fill
		jc	xtb_bit3_set			; Jump if carry Set
		retn

xtb_bit3_set:
		or	ds:src_word_c,ax
		retn

extract_bits		endp

		db	 00h, 00h, 00h, 03h, 80h, 80h
		db	 85h, 84h, 03h, 03h, 03h, 03h
		db	 84h, 84h, 84h, 84h, 03h, 03h
		db	 03h, 03h, 84h, 84h, 84h,0D4h
		db	 00h, 00h, 00h,0FFh, 00h, 00h
		db	 55h, 00h, 00h, 00h, 01h,0FFh
		db	 02h, 02h, 56h, 00h, 00h, 00h
		db	 00h,0FFh, 40h, 40h, 55h, 00h
		db	 00h, 00h, 00h,0C0h, 01h, 01h
		db	 61h, 21h,0C0h,0C0h,0C0h,0C0h
		db	 21h, 21h, 21h, 21h,0C0h,0C0h
		db	0C0h,0C0h, 21h, 21h, 21h, 21h
		db	0C0h,0E0h,0E0h,0E0h, 2Bh, 01h
		db	 01h, 01h, 03h, 03h, 03h, 03h
		db	0D4h, 84h, 84h, 84h, 03h, 03h
		db	 03h, 03h, 84h, 84h, 84h, 84h
		db	 03h, 02h, 00h, 00h, 84h, 85h
		db	 80h, 80h,0FFh,0AAh, 00h, 00h
		db	 00h, 55h, 00h, 00h,0FFh,0A8h
		db	 00h, 00h, 00h, 56h, 02h, 02h
		db	0FFh,0FFh, 00h, 00h, 00h, 55h
		db	 40h, 40h,0C0h,0C0h,0C0h,0C0h
		db	 2Bh, 21h, 21h, 21h,0C0h,0C0h
		db	0C0h,0C0h, 21h, 21h, 21h, 21h
		db	0C0h, 80h, 00h, 00h, 21h, 61h
		db	 01h, 01h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 07h, 07h, 07h, 07h, 80h, 80h
		db	 80h, 80h,0E0h,0E0h,0E0h,0E0h
		db	 01h, 01h, 01h, 01h,0FFh,0FFh
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	 01h, 02h, 03h
		db	20 dup (16h)
		db	 0Bh, 0Ch, 0Dh, 00h, 0Eh, 0Fh
		db	66 dup (15h)
		db	 10h, 0Eh, 13h, 00h, 12h, 11h
		db	19 dup (17h)
		db	 0Ah, 09h, 08h, 07h, 00h, 04h
		db	 06h
		db	66 dup (14h)
		db	 05h, 04h, 00h, 18h, 46h, 18h
		db	 45h, 17h, 44h, 16h, 43h, 15h
		db	 42h, 14h, 41h, 13h, 40h, 12h
		db	 3Fh, 11h, 3Eh, 10h, 3Dh, 0Fh
		db	 3Ch, 0Eh, 3Bh, 0Dh, 3Ah, 0Ch
		db	 39h, 0Bh, 38h, 0Ah, 37h, 09h
		db	 36h, 08h, 35h, 07h, 34h, 06h
		db	 33h, 05h, 32h, 04h, 31h, 03h
		db	 30h, 02h, 2Fh, 01h, 2Eh, 00h
		db	 02h, 55h, 03h,0FFh, 01h, 55h
		db	 1Eh, 2Eh,0A2h, 0Ch, 4Ch, 53h
		db	 51h, 8Ah,0C5h,0F6h,0E1h, 8Bh
		db	0E8h, 06h, 1Fh, 8Bh,0F7h, 8Ch
		db	0C8h, 05h, 00h, 30h, 8Eh,0C0h
		db	0BFh, 00h, 00h, 2Eh,0C7h, 06h
		db	 05h, 4Ch, 00h, 00h, 2Eh,0C7h
		db	 06h,0FFh, 4Bh, 00h, 00h, 2Eh
		db	0C7h, 06h, 01h, 4Ch, 00h, 00h
		db	 2Eh,0C7h, 06h, 03h, 4Ch, 00h
		db	 00h, 8Bh,0CDh,0D1h,0E9h

spr_multiplane_loop:
						push	si
						test	byte ptr cs:render_mode_flag,1
						jz	spr_plane_b_skip			; Jump if zero
						mov	ax,[si]
						xchg	ah,al
						mov	cs:src_word_a,ax
						add	si,bp

spr_plane_b_skip:
						test	byte ptr cs:render_mode_flag,2
						jz	spr_plane_c_skip			; Jump if zero
						mov	ax,[si]
						xchg	ah,al
						mov	cs:src_word_b,ax
						add	si,bp

spr_plane_c_skip:
						test	byte ptr cs:render_mode_flag,4
						jz	spr_plane_out			; Jump if zero
						mov	ax,[si]
						xchg	ah,al
						mov	cs:src_word_c,ax

spr_plane_out:
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						pop	si
						inc	si
						inc	si
						loop	spr_multiplane_loop		; Loop if cx > 0

		pop	cx
		pop	bx
		sub	bx,410h
		mov	byte ptr cs:cur_row_ctr,0
		mov	byte ptr cs:cur_pass_ctr,0
		mov	cs:render_fn_ptr,cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,0
		mov	ax,tga_vram_seg
		mov	es,ax
		mov	cx,8

spr_pass_loop:
						push	cx
						mov	al,cs:cur_pass_ctr
						mov	cs:cur_row_ctr,al
						mov	byte ptr cs:gvar_frame_timer,0
						mov	cx,0Dh

spr_col_loop:
										push	cx
										push	bx
										push	si
										call	stats_multiply_3
										pop	si
										pop	bx
										pop	cx
										add	byte ptr cs:cur_row_ctr,8
										loop	spr_col_loop		; Loop if cx > 0

						pop	cx

spr_pass_vbl_wait:
										cmp	byte ptr cs:gvar_frame_timer,14h
										jb	spr_pass_vbl_wait			; Jump if below
						inc	byte ptr cs:cur_pass_ctr
						loop	spr_pass_loop		; Loop if cx > 0

		pop	ds
		retn

stats_multiply_3		proc	near
		push	bx
		mov	bl,cs:cur_row_ctr
		add	bl,10h
		mov	bh,4
		call	extract_bits_2
		mov	di,ax
		pop	bx
		cmp	cs:cur_row_ctr,bl
		jb	smul3_out_range			; Jump if below
		mov	al,bl
		add	al,cs:render_fn_ptr
		cmp	cs:cur_row_ctr,al
		jae	smul3_out_range			; Jump if above or =
		mov	al,cs:cur_row_ctr
		sub	al,bl
		add	al,al
		mul	byte ptr cs:render_fn_ptr+1	; ax = data * al
		add	si,ax
		mov	byte ptr cs:cur_col_ctr,0
		mov	cx,48h

smul3_col_loop:
						push	cx
						mov	word ptr es:[di],0
						cmp	cs:cur_col_ctr,bh
						jb	smul3_col_skip			; Jump if below
						mov	al,bh
						add	al,byte ptr cs:render_fn_ptr+1
						cmp	cs:cur_col_ctr,al
						jae	smul3_col_skip			; Jump if above or =
						movsw				; Mov [si] to es:[di]
						dec	di
						dec	di

smul3_col_skip:
						inc	di
						inc	di
						inc	byte ptr cs:cur_col_ctr
						pop	cx
						loop	smul3_col_loop		; Loop if cx > 0

		retn

smul3_out_range:
		mov	cx,48h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

stats_multiply_3		endp

txt_row_blit_entry:
		mov	cs:cur_row_ctr,bl
		call	extract_bits_2
		mov	di,ax
		mov	ax,tga_vram_seg
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		sub	bx,2
		xor	ch,ch			; Zero register
		sub	cx,5
		push	cx
		push	di
		call	fill_buffer
		pop	di
		inc	byte ptr cs:cur_row_ctr
		add	di,2000h
		cmp	di,tga_work_buf
		jb	txt_row_wrap			; Jump if below
		add	di,tga_bank_wrap

txt_row_wrap:
		mov	cx,2
		call	clear_buffer
		pop	cx

txt_border_loop:
						push	cx
						call	stats_get_value
						or	byte ptr es:[di],0Fh
						mov	byte ptr es:[di+1],0
						or	byte ptr es:[bx+di+1],0F0h
						mov	byte ptr es:[bx+di],0
						inc	byte ptr cs:cur_row_ctr
						add	di,2000h
						cmp	di,tga_work_buf
						jb	txt_border_wrap			; Jump if below
						add	di,tga_bank_wrap

txt_border_wrap:
						pop	cx
						loop	txt_border_loop		; Loop if cx > 0

		mov	cx,1
		call	clear_buffer

fill_buffer		proc	near
		call	stats_get_value
		or	byte ptr es:[di],0Fh
		inc	di
		mov	cx,bx
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0F0h
		retn

fill_buffer		endp

clear_buffer		proc	near

clrbuf_row_loop:
						push	cx
						push	di
						call	stats_get_value
						or	byte ptr es:[di],0Fh
						inc	di
						mov	cx,bx
						xor	al,al			; Zero register
						rep	stosb			; Rep when cx >0 Store al to es:[di]
						or	byte ptr es:[di],0F0h
						pop	di
						inc	byte ptr cs:cur_row_ctr
						add	di,2000h
						cmp	di,tga_work_buf
						jb	clrbuf_wrap			; Jump if below
						add	di,tga_bank_wrap

clrbuf_wrap:
						pop	cx
						loop	clrbuf_row_loop		; Loop if cx > 0

		retn

clear_buffer		endp

stats_get_value		proc	near
		mov	word ptr es:[di-3],4444h
		mov	word ptr es:[di-1],4444h
		retn

stats_get_value		endp

plane_merge_entry:
		push	bx
		push	es
		push	di
		mov	cx,1028h

plane_merge_loop:
						mov	al,es:[di]
						and	al,byte ptr es:[1028h][di]
						mov	ah,es:plane3_merge_buf[di]
						not	ah
						and	al,ah
						not	al
						and	es:[di],al
						and	byte ptr es:[1028h][di],al
						and	es:plane3_merge_buf[di],al
						mov	al,es:plane3_merge_buf[di]
						mov	ah,es:[di]
						not	ah
						and	al,ah
						mov	ah,byte ptr es:[1028h][di]
						not	ah
						and	al,ah
						or	es:[di],al
						or	byte ptr es:[1028h][di],al
						not	al
						and	es:plane3_merge_buf[di],al
						inc	di
						loop	plane_merge_loop		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,2F58h
		jmp	render_xor_entry

face_render_entry:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	di,69Ah
		add	di,ds:saved_di
		call	stats_process_loop_3
		mov	di,offset face_panel2_anchor
		add	di,ds:saved_di
		call	stats_process_loop_3
		mov	ax,tga_vram_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,44h

face_render_loop:
						push	cx
						mov	byte ptr cs:gvar_frame_timer,0
						mov	ax,44h
						sub	ax,cx
						add	ax,ax
						push	ax
						mov	bl,al
						mov	al,50h			; 'P'
						mul	bl			; ax = reg * al
						push	ax
						mov	bh,0
						call	extract_bits_2
						mov	di,ax
						pop	ax
						add	ax,cs:saved_di
						mov	si,ax
						pop	ax
						cmp	ax,16h
						jb	face_row_narrow			; Jump if below
						cmp	ax,71h
						jae	face_row_narrow			; Jump if above or =
						call	stats_process_loop_2
						jmp	short face_row_done

face_row_narrow:
						call	stats_process_loop

face_row_done:
						pop	cx
						push	cx
						mov	ax,cx
						add	ax,ax
						dec	ax
						push	ax
						mov	bl,al
						mov	al,50h			; 'P'
						mul	bl			; ax = reg * al
						push	ax
						mov	bh,0
						call	extract_bits_2
						mov	di,ax
						pop	ax
						add	ax,cs:saved_di
						mov	si,ax
						pop	ax
						cmp	ax,16h
						jb	face_row_narrow2			; Jump if below
						cmp	ax,71h
						jae	face_row_narrow2			; Jump if above or =
						call	stats_process_loop_2
						jmp	short face_row_vbl_wait

face_row_narrow2:
						call	stats_process_loop

face_row_vbl_wait:
										cmp	byte ptr cs:gvar_frame_timer,4
										jb	face_row_vbl_wait			; Jump if below
						pop	cx
						loop	face_render_loop		; Loop if cx > 0

		pop	ds
		retn

stats_process_loop		proc	near
		mov	cx,28h
		mov	word ptr cs:src_word_d,0

proc_loop_wide:
						mov	ax,ds:sprite_row_buf_b[si]
						xchg	ah,al
						mov	cs:src_word_c,ax
						mov	ax,ds:cga_plane_stride[si]
						xchg	ah,al
						mov	cs:src_word_b,ax
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	proc_loop_wide		; Loop if cx > 0

		retn

stats_process_loop		endp

stats_process_loop_2		proc	near
		mov	cx,0Bh
		mov	word ptr cs:src_word_d,0

proc_loop_narrow_top:
						mov	ah,ds:sprite_row_buf_b[si]
						mov	cs:src_word_c,ax
						mov	ah,ds:cga_plane_stride[si]
						mov	cs:src_word_b,ax
						lodsb				; String [si] to al
						xchg	ah,al
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	proc_loop_narrow_top		; Loop if cx > 0

		add	si,18h
		add	di,30h
		mov	cx,5

proc_loop_mid:
						mov	ax,ds:sprite_row_buf_b[si]
						xchg	ah,al
						mov	cs:src_word_c,ax
						mov	ax,ds:cga_plane_stride[si]
						xchg	ah,al
						mov	cs:src_word_b,ax
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	proc_loop_mid		; Loop if cx > 0

		add	si,18h
		add	di,30h
		mov	cx,0Bh

proc_loop_narrow_bot:
						mov	ah,ds:sprite_row_buf_b[si]
						mov	cs:src_word_c,ax
						mov	ah,ds:cga_plane_stride[si]
						mov	cs:src_word_b,ax
						lodsb				; String [si] to al
						xchg	ah,al
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	proc_loop_narrow_bot		; Loop if cx > 0

		retn

stats_process_loop_2		endp

stats_process_loop_3		proc	near
		push	di
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

border_top_loop:
						mov	byte ptr es:[di],30h	; '0'
						mov	byte ptr es:[di+19h],0Ch
						add	di,50h
						loop	border_top_loop		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		pop	di
		add	di,cga_plane_stride
		push	di
		mov	ax,0FD7Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,2Dh

border_mid_loop:
						mov	byte ptr es:[di],0B0h
						mov	byte ptr es:[di+19h],0Eh
						add	di,50h
						mov	byte ptr es:[di],70h	; 'p'
						mov	byte ptr es:[di+19h],0Dh
						add	di,50h
						loop	border_mid_loop		; Loop if cx > 0

		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	ax,0FD7Fh
		call	fill_buffer_2
		pop	di
		add	di,cga_plane_stride
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

border_bot_loop:
						mov	byte ptr es:[di],30h	; '0'
						mov	byte ptr es:[di+19h],0Ch
						add	di,50h
						loop	border_bot_loop		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		retn

stats_process_loop_3		endp

fill_buffer_2		proc	near
		stosb				; Store al to es:[di]
		mov	al,0FFh
		mov	cx,18h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,ah
		stosb				; Store al to es:[di]
		retn

fill_buffer_2		endp

face2_render_entry:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	ax,tga_vram_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,39h

face2_render_loop:
						mov	byte ptr cs:gvar_frame_timer,0
						push	cx
						mov	ax,cx
						neg	ax
						add	ax,39h
						add	ax,ax
						call	stats_multiply_4
						pop	ax
						push	ax
						add	ax,ax
						dec	ax
						call	stats_multiply_4

face2_vbl_wait:
										cmp	byte ptr cs:gvar_frame_timer,4
										jb	face2_vbl_wait			; Jump if below
						pop	cx
						loop	face2_render_loop		; Loop if cx > 0

		pop	ds
		retn

stats_multiply_4		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,cs:saved_di
		mov	si,ax
		xor	bh,bh			; Zero register
		call	extract_bits_2
		mov	di,ax
		pop	ax
		cmp	ax,14h
		jae	smul4_wide_entry			; Jump if above or =
		mov	cx,2Fh
		jmp	short smul4_fill

smul4_wide_entry:
		mov	cx,23h
		cmp	ax,17h
		jb	smul4_fill			; Jump if below
		cmp	ax,1Ch
		jb	smul4_partial_entry			; Jump if below
		mov	cx,21h

smul4_fill:
		mov	word ptr cs:src_word_d,0

sfill_col_loop:
						mov	ah,ds:cga_plane2_buf[si]
						mov	cs:src_word_c,ax
						mov	ah,byte ptr face_color_lut[si]
						mov	cs:src_word_b,ax
						lodsb				; String [si] to al
						xchg	ah,al
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	sfill_col_loop		; Loop if cx > 0

		retn

smul4_partial_entry:
		mov	cx,21h
		mov	word ptr cs:src_word_d,0

sfill_partial_loop:
						mov	ah,ds:cga_plane2_buf[si]
						mov	cs:src_word_c,ax
						mov	ah,byte ptr face_color_lut[si]
						mov	cs:src_word_b,ax
						lodsb				; String [si] to al
						xchg	ah,al
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	sfill_partial_loop		; Loop if cx > 0

		mov	ah,ds:cga_plane2_buf[si]
		mov	cs:src_word_c,ax
		mov	ah,byte ptr face_color_lut[si]
		mov	cs:src_word_b,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:src_word_a,ax
		call	stats_process_loop_4
		and	ax,0F0FFh
		and	word ptr es:[di],0F00h
		or	es:[di],ax
		retn

stats_multiply_4		endp

face3_render_entry:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	ax,tga_vram_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,39h

face3_render_loop:
						mov	byte ptr cs:gvar_frame_timer,0
						push	cx
						mov	ax,cx
						neg	ax
						add	ax,39h
						add	ax,ax
						call	stats_fill_buf
						pop	ax
						push	ax
						add	ax,ax
						dec	ax
						call	stats_fill_buf

face3_vbl_wait:
										cmp	byte ptr cs:gvar_frame_timer,4
										jb	face3_vbl_wait			; Jump if below
						pop	cx
						loop	face3_render_loop		; Loop if cx > 0

		pop	ds
		retn

stats_fill_buf		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,3CDh
		add	ax,cs:saved_di
		mov	si,ax
		add	bl,14h
		mov	bh,21h			; '!'
		call	extract_bits_2
		mov	di,ax
		pop	ax
		cmp	ax,5Eh
		mov	cx,2Fh
		jnc	sfill_zero_pad			; Jump if carry=0
		mov	cx,7
		mov	word ptr cs:src_word_d,0

sfill2_col_loop:
						mov	ax,ds:cga_plane2_buf[si]
						xchg	ah,al
						mov	cs:src_word_c,ax
						mov	ax,face_color_lut[si]
						xchg	ah,al
						mov	cs:src_word_b,ax
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	cs:src_word_a,ax
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						call	stats_process_loop_4
						stosw				; Store ax to es:[di]
						loop	sfill2_col_loop		; Loop if cx > 0

		mov	cx,21h

sfill_zero_pad:
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

stats_fill_buf		endp

solid_fill_entry:
		push	ax
		call	extract_bits_2
		mov	di,ax
		mov	ax,tga_vram_seg
		mov	es,ax
		pop	ax
		mov	ah,al
		mov	cx,8

solid_fill_loop:
						stosw				; Store ax to es:[di]
						stosw				; Store ax to es:[di]
						add	di,1FFCh
						cmp	di,tga_work_buf
						jb	solid_fill_wrap			; Jump if below
						add	di,tga_bank_wrap

solid_fill_wrap:
						loop	solid_fill_loop		; Loop if cx > 0

		retn

set_lut_ptr:
		dec	ax
		mov	cx,100h
		mul	cx			; dx:ax = reg * ax
		add	ax,41E4h
		mov	cs:tga_color_lut,ax
		retn
		db	 00h, 01h, 04h, 05h, 07h, 07h
		db	 07h, 07h, 08h, 07h, 04h, 05h
		db	 07h, 07h, 07h, 07h, 01h, 09h
		db	 05h, 05h, 09h, 09h, 09h, 09h
		db	 01h, 09h, 05h, 05h, 09h, 09h
		db	 09h, 09h, 04h, 05h, 0Ch, 0Dh
		db	 0Ch, 0Ch, 0Ch, 0Ch, 04h, 0Ch
		db	 0Ch, 0Dh, 0Ch, 0Ch, 0Ch, 0Ch
		db	 05h, 05h, 0Dh, 0Dh, 0Dh, 0Dh
		db	 0Dh, 0Dh, 05h
		db	7 dup (0Dh)
		db	 07h, 09h, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 0Fh, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 07h, 09h
		db	 0Ch, 0Dh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 07h, 0Fh, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 09h, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 07h, 0Fh
		db	 0Ch, 0Dh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 07h, 09h, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 0Fh, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 00h, 01h
		db	 04h, 05h, 07h, 07h, 07h, 07h
		db	 08h, 07h, 04h, 05h, 07h, 07h
		db	 07h, 07h, 07h, 09h, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 07h, 0Fh
		db	 0Ch, 0Dh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 04h, 05h, 0Ch, 0Dh, 0Ch, 0Ch
		db	 0Ch, 0Ch, 04h, 0Ch, 0Ch, 0Dh
		db	 0Ch, 0Ch, 0Ch, 0Ch, 05h, 05h
		db	 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh
		db	 05h
		db	7 dup (0Dh)
		db	 07h, 09h, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 0Fh, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 07h, 09h
		db	 0Ch, 0Dh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 07h, 0Fh, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 09h, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 07h, 0Fh
		db	 0Ch, 0Dh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 07h, 09h, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 0Fh, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 00h, 01h
		db	 04h, 05h, 00h, 03h, 06h, 07h
		db	 08h, 07h, 04h, 05h, 02h, 03h
		db	 06h, 08h, 01h, 09h, 05h, 05h
		db	 01h, 09h, 02h, 09h, 01h, 09h
		db	 05h, 05h, 03h, 0Bh, 05h, 09h
		db	 04h, 05h, 0Ch, 0Dh, 04h, 0Dh
		db	 06h, 0Ch, 04h, 0Ch, 0Ch, 0Dh
		db	 0Dh, 0Dh, 06h, 0Ch, 05h, 05h
		db	 0Dh, 0Dh, 05h, 0Dh, 06h, 0Dh
		db	 05h, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh
		db	 06h, 0Dh, 00h, 01h, 04h, 05h
		db	 00h, 03h, 06h, 07h, 00h, 07h
		db	 04h, 05h, 02h, 03h, 06h, 08h
		db	 03h, 09h, 0Dh, 0Dh, 03h, 0Bh
		db	 0Ah, 0Bh, 03h, 0Ah, 0Dh, 0Dh
		db	 0Ah, 0Bh, 0Ah, 0Bh, 06h, 02h
		db	 06h, 06h, 06h, 0Ah, 0Eh, 0Eh
		db	 06h, 0Eh, 06h, 06h, 0Ah, 0Ah
		db	 0Eh, 0Eh, 07h, 09h, 0Ch, 0Dh
		db	 07h, 0Bh, 0Eh, 0Fh, 07h, 0Fh
		db	 0Ch, 0Dh, 0Ah, 0Bh, 0Eh, 0Fh
		db	 08h, 01h, 04h, 05h, 00h, 03h
		db	 06h, 07h, 07h, 07h, 04h, 05h
		db	 02h, 03h, 06h, 07h, 07h, 09h
		db	 0Ch, 0Dh, 07h, 0Ah, 0Eh, 0Fh
		db	 07h, 0Fh, 0Ch, 0Dh, 0Ah, 0Ah
		db	 0Eh, 0Fh, 04h, 05h, 0Ch, 0Dh
		db	 04h, 0Dh, 06h, 0Ch, 04h, 0Ch
		db	 0Ch, 0Dh, 05h, 0Ch, 06h, 0Ch
		db	 05h, 05h, 0Dh, 0Dh, 05h, 0Dh
		db	 06h, 0Dh, 05h, 0Dh, 0Dh, 0Dh
		db	 0Dh, 0Dh, 06h, 0Dh, 02h, 03h
		db	 0Dh, 0Dh, 02h, 0Ah, 0Ah, 0Ah
		db	 02h, 0Ah, 05h, 0Dh, 0Dh, 0Ah
		db	 0Ah, 0Ah, 03h, 09h, 0Dh, 0Dh
		db	 03h, 0Bh, 0Ah, 0Bh, 03h, 0Ah
		db	 0Dh, 0Dh, 0Ah, 0Bh, 0Ah, 0Bh
		db	 06h, 02h, 06h, 06h, 06h, 0Ah
		db	 0Eh, 0Eh, 06h, 0Eh, 06h, 06h
		db	 0Ah, 0Ah, 0Eh, 0Eh, 07h, 09h
		db	 0Ch, 0Dh, 07h, 0Bh, 0Eh, 0Fh
		db	 07h, 0Fh, 0Ch, 0Dh, 0Ah, 0Bh
		db	 0Eh, 0Fh, 00h, 04h, 01h, 07h
		db	 01h, 07h, 00h, 07h
		db	8 dup (0)
		db	 04h, 0Ch, 05h, 0Ch, 05h, 0Ch
		db	 04h, 0Ch, 00h
		db	7 dup (0)
		db	1, 5, 9, 3, 9, 3
		db	1
		db	9
		db	8 dup (0)
		db	 07h, 0Ch, 03h, 0Fh, 03h, 0Fh
		db	 07h, 0Fh
		db	8 dup (0)
		db	1, 5, 9, 3, 9, 3
		db	1
		db	9
		db	8 dup (0)
		db	 07h, 0Ch, 03h, 0Fh, 03h, 0Fh
		db	 07h, 0Fh
		db	9 dup (0)
		db	4, 1, 7, 1, 7, 0
		db	7
		db	8 dup (0)
		db	 07h, 0Ch, 03h, 0Fh, 03h, 0Fh
		db	 07h, 0Fh
		db	137 dup (0)
		db	1, 4, 5, 3, 3
face_color_lut	dw	706h			; Face render 3-plane color lookup table
		db	 08h, 01h, 04h, 05h, 03h, 03h
		db	 06h, 07h, 01h, 09h, 05h, 05h
		db	 09h, 09h, 02h, 03h, 01h, 09h
		db	 05h, 05h, 09h, 09h, 02h, 03h
		db	 04h, 05h, 0Ch, 0Dh, 0Dh, 0Dh
		db	 06h, 0Ch, 04h, 05h, 0Ch, 0Dh
		db	 0Dh, 0Dh, 06h, 0Ch, 05h, 05h
		db	 0Dh, 0Dh, 0Dh, 0Dh, 0Ch, 0Dh
		db	 05h, 05h, 0Dh, 0Dh, 0Dh, 0Dh
		db	 0Ch, 0Dh, 03h, 09h, 0Dh, 0Dh
		db	 0Bh, 0Bh, 0Ah, 0Bh, 03h, 09h
		db	 0Dh, 0Dh, 0Bh, 0Bh, 0Ah, 0Bh
		db	 03h, 09h, 0Dh, 0Dh, 0Bh, 0Bh
		db	 0Ah, 0Bh, 03h, 09h, 0Dh, 0Dh
		db	 0Bh, 0Bh, 0Ah, 0Bh, 06h, 02h
		db	 06h, 0Ch, 0Ah, 0Ah, 0Eh, 0Eh
		db	 06h, 02h, 06h, 0Ch, 0Ah, 0Ah
		db	 0Eh, 0Eh, 07h, 03h, 0Ch, 0Dh
		db	 0Bh, 0Bh, 0Eh, 0Fh, 07h, 03h
		db	 0Ch, 0Dh, 0Bh, 0Bh, 0Eh, 0Fh
		db	 08h, 01h, 04h, 05h, 03h, 03h
		db	 06h, 07h, 08h, 01h, 04h, 05h
		db	 03h, 03h, 07h, 07h, 01h, 09h
		db	 05h, 05h, 09h, 09h, 02h, 03h
		db	 01h, 09h, 05h, 05h, 09h, 09h
		db	 02h, 03h, 04h, 05h, 0Ch, 0Dh
		db	 0Dh, 0Dh, 06h, 0Ch, 04h, 05h
		db	 0Ch, 0Dh, 0Dh, 0Dh, 06h, 0Ch
		db	 05h, 05h, 0Dh, 0Dh, 0Dh, 0Dh
		db	 0Ch, 0Dh, 05h, 05h, 0Dh, 0Dh
		db	 0Dh, 0Dh, 0Ch, 0Dh, 03h, 09h
		db	 0Dh, 0Dh, 0Bh, 0Bh, 0Ah, 0Bh
		db	 03h, 09h, 0Dh, 0Dh, 0Bh, 0Bh
		db	 0Ah, 0Bh, 03h, 09h, 0Dh, 0Dh
		db	 0Bh, 0Bh, 0Ah, 0Bh, 03h, 09h
		db	 0Dh, 0Dh, 0Bh, 0Bh, 0Ah, 0Bh
		db	 06h, 02h, 06h, 0Ch, 0Ah, 0Ah
		db	 0Eh, 0Eh, 06h, 02h, 06h, 0Ch
		db	 0Ah, 0Ah, 0Eh, 0Eh, 07h, 03h
		db	 0Ch, 0Dh, 0Bh, 0Bh, 0Eh, 0Fh
		db	 07h, 03h, 0Ch, 0Dh, 0Bh, 0Bh
		db	 0Eh, 0Fh, 00h, 01h, 04h, 03h
		db	 02h, 03h, 06h, 07h
		db	8 dup (0)
		db	1, 9, 5, 9, 2, 9
		db	2, 3, 0
		db	7 dup (0)
		db	 04h, 05h, 0Ch, 05h, 08h, 05h
		db	 06h, 0Ch, 00h
		db	7 dup (0)
		db	 03h, 09h, 05h, 0Bh, 0Ah, 0Bh
		db	 07h, 0Bh, 00h
		db	7 dup (0)
		db	 02h, 02h, 08h, 0Ah, 0Ah, 0Ah
		db	 0Eh, 07h
		db	8 dup (0)
		db	 03h, 09h, 05h, 0Bh, 0Ah, 0Bh
		db	 07h, 0Bh, 00h
		db	7 dup (0)
		db	 06h, 02h, 06h, 07h, 0Eh, 07h
		db	 0Eh, 0Eh
		db	8 dup (0)
		db	 07h, 03h, 0Ch, 0Bh, 07h, 0Bh
		db	 0Eh, 0Fh, 00h
		db	136 dup (0)
		db	 01h, 04h, 05h, 00h, 03h, 06h
		db	 07h, 08h, 07h, 04h, 05h, 02h
		db	 03h, 06h, 08h, 01h, 09h, 05h
		db	 05h, 01h, 09h, 02h, 09h, 01h
		db	 09h, 05h, 05h, 03h, 0Bh, 05h
		db	 09h, 04h, 05h, 0Ch, 0Dh, 04h
		db	 08h, 06h, 0Ch, 04h, 0Ch, 0Ch
		db	 0Dh, 0Dh, 0Dh, 06h, 0Ch, 05h
		db	 05h, 0Dh, 0Dh, 05h, 08h, 06h
		db	 0Dh, 05h, 0Dh, 0Dh, 0Dh, 0Dh
		db	 0Dh, 06h, 0Dh, 00h, 01h, 04h
		db	 05h, 00h, 03h, 06h, 07h, 00h
		db	 07h, 04h, 05h, 02h, 03h, 06h
		db	 08h, 03h, 09h, 08h, 08h, 03h
		db	 0Bh, 0Ah, 0Bh, 03h, 0Ah, 0Dh
		db	 0Dh, 0Ah, 0Bh, 0Ah, 0Bh, 06h
		db	 02h, 06h, 06h, 06h, 0Ah, 0Eh
		db	 0Eh, 06h, 0Eh, 06h, 06h, 0Ah
		db	 0Ah, 0Eh, 0Eh, 07h, 09h, 0Ch
		db	 0Dh, 07h, 0Bh, 0Eh, 0Fh, 07h
		db	 0Fh, 0Ch, 0Dh, 0Ah, 0Bh, 0Eh
		db	 0Fh, 08h, 01h, 04h, 05h, 00h
		db	 03h, 06h, 07h, 07h, 07h, 04h
		db	 05h, 02h, 03h, 06h, 07h, 07h
		db	 09h, 0Ch, 0Dh, 07h, 0Ah, 0Eh
		db	 0Fh, 07h, 0Fh, 0Ch, 0Dh, 0Ah
		db	 0Ah, 0Eh, 0Fh, 04h, 05h, 0Ch
		db	 0Dh, 04h, 0Dh, 06h, 0Ch, 04h
		db	 0Ch, 0Ch, 0Dh, 05h, 0Ch, 06h
		db	 0Ch, 05h, 05h, 0Dh, 0Dh, 05h
		db	 0Dh, 06h, 0Dh, 05h, 0Dh, 0Dh
		db	 0Dh, 0Dh, 0Dh, 06h, 0Dh, 02h
		db	 03h, 0Dh, 0Dh, 02h, 0Ah, 0Ah
		db	 0Ah, 02h, 0Ah, 05h, 0Dh, 0Dh
		db	 0Ah, 0Ah, 0Ah, 03h, 09h, 0Dh
		db	 0Dh, 03h, 0Bh, 0Ah, 0Bh, 03h
		db	 0Ah, 0Dh, 0Dh, 0Ah, 0Bh, 0Ah
		db	 0Bh, 06h, 02h, 06h, 06h, 06h
		db	 0Ah, 0Eh, 0Eh, 06h, 0Eh, 06h
		db	 06h, 0Ah, 0Ah, 0Eh, 0Eh, 07h
		db	 09h, 0Ch, 0Dh, 07h, 0Bh, 0Eh
		db	 0Fh, 07h, 0Fh, 0Ch, 0Dh, 0Ah
		db	 0Bh, 0Eh, 0Fh, 00h, 01h, 04h
		db	 05h, 02h, 03h, 06h, 07h, 08h
		db	 01h, 04h, 05h, 03h, 03h, 06h
		db	 07h, 01h, 09h, 05h, 05h, 03h
		db	 09h, 02h, 03h, 01h, 09h, 05h
		db	 05h, 09h, 09h, 02h, 03h, 04h
		db	 05h, 0Ch, 0Dh, 06h, 08h, 06h
		db	 0Ch, 04h, 05h, 0Ch, 0Dh, 08h
		db	 08h, 06h, 0Ch, 05h, 05h, 0Dh
		db	 0Dh, 08h, 08h, 0Ch, 0Dh, 05h
		db	 05h, 0Dh, 0Dh, 08h, 08h, 0Ch
		db	 0Dh, 02h, 03h, 06h, 08h, 0Ah
		db	 0Bh, 0Eh, 0Ah, 02h, 03h, 06h
		db	 08h, 0Ah, 0Bh, 0Eh, 0Ah, 03h
		db	 09h, 08h, 08h, 0Bh, 0Bh, 0Ah
		db	 0Bh, 03h, 09h, 08h, 08h, 0Bh
		db	 0Bh, 0Ah, 0Bh, 06h, 02h, 06h
		db	 0Ch, 0Eh, 0Ah, 0Eh, 0Eh, 06h
		db	 02h, 06h, 0Ch, 0Ah, 0Ah, 0Eh
		db	 0Eh, 07h, 03h, 0Ch, 0Dh, 0Ah
		db	 0Bh, 0Eh, 0Fh, 07h, 03h, 0Ch
		db	 0Dh, 0Bh, 0Bh, 0Eh, 0Fh, 08h
		db	 01h, 04h, 05h, 02h, 03h, 06h
		db	 07h, 08h, 01h, 04h, 05h, 03h
		db	 03h, 07h, 07h, 01h, 09h, 05h
		db	 05h, 03h, 09h, 02h, 03h, 01h
		db	 09h, 05h, 05h, 09h, 09h, 02h
		db	 03h, 04h, 05h, 0Ch, 0Dh, 06h
		db	 08h, 06h, 0Ch, 04h, 05h, 0Ch
		db	 0Dh, 08h, 08h, 06h, 0Ch, 05h
		db	 05h, 0Dh, 0Dh, 08h, 08h, 0Ch
		db	 0Dh, 05h, 05h, 0Dh, 0Dh, 08h
		db	 08h, 0Ch, 0Dh, 03h, 09h, 08h
		db	 08h, 0Ah, 0Bh, 0Ah, 0Bh, 03h
		db	 09h, 08h, 08h, 0Bh, 0Bh, 0Ah
		db	 0Bh, 03h, 09h, 08h, 08h, 0Bh
		db	 0Bh, 0Ah, 0Bh, 03h, 09h, 08h
		db	 08h, 0Bh, 0Bh, 0Ah, 0Bh, 06h
		db	 02h, 06h, 0Ch, 0Eh, 0Ah, 0Eh
		db	 0Eh, 06h, 02h, 06h, 0Ch, 0Ah
		db	 0Ah, 0Eh, 0Eh, 07h, 03h, 0Ch
		db	 0Dh, 0Ah, 0Bh, 0Eh, 0Fh, 07h
		db	 03h, 0Ch, 0Dh, 0Bh, 0Bh, 0Eh
		db	 0Fh, 00h, 01h, 04h, 02h, 00h
		db	 03h, 06h, 07h, 08h, 07h, 04h
		db	 05h, 02h, 03h, 06h, 08h, 01h
		db	 09h, 05h, 03h, 01h, 09h, 02h
		db	 09h, 01h, 09h, 05h, 05h, 03h
		db	 0Bh, 05h, 09h, 04h, 05h, 0Ch
		db	 06h, 04h, 08h, 06h, 0Ch, 04h
		db	 0Ch, 0Ch, 08h, 0Dh, 0Dh, 06h
		db	 0Ch, 02h, 03h, 06h, 0Ah, 02h
		db	 0Bh, 0Eh, 0Ah, 02h, 03h, 06h
		db	 08h, 0Ah, 0Bh, 0Eh, 0Ah, 00h
		db	 01h, 04h, 02h, 00h, 03h, 06h
		db	 07h, 00h, 07h, 04h, 05h, 02h
		db	 03h, 06h, 08h, 03h, 09h, 08h
		db	 0Bh, 03h, 0Bh, 0Ah, 0Bh, 03h
		db	 0Ah, 08h, 08h, 0Ah, 0Bh, 0Ah
		db	 0Bh, 06h, 02h, 06h, 0Eh, 06h
		db	 0Ah, 0Eh, 0Eh, 06h, 0Eh, 06h
		db	 06h, 0Ah, 0Ah, 0Eh, 0Eh, 07h
		db	 09h, 0Ch, 0Ah, 07h, 0Bh, 0Eh
		db	 0Fh, 07h, 0Fh, 0Ch, 0Dh, 0Ah
		db	 0Bh, 0Eh, 0Fh, 08h, 01h, 04h
		db	 02h, 00h, 03h, 06h, 07h, 07h
		db	 07h, 04h, 05h, 02h, 03h, 06h
		db	 07h, 07h, 09h, 0Ch, 03h, 07h
		db	 0Ah, 0Eh, 0Fh, 07h, 0Fh, 0Ch
		db	 0Dh, 0Ah, 0Ah, 0Eh, 0Fh, 04h
		db	 05h, 0Ch, 06h, 04h, 08h, 06h
		db	 0Ch, 04h, 0Ch, 0Ch, 08h, 05h
		db	 0Ch, 06h, 0Ch, 05h, 05h, 0Dh
		db	 08h, 05h, 08h, 06h, 0Dh, 05h
		db	 0Dh, 0Dh, 08h, 0Dh, 0Dh, 06h
		db	 0Dh, 02h, 03h, 0Dh, 0Ah, 02h
		db	 0Ah, 0Ah, 0Ah, 02h, 0Ah, 05h
		db	 0Dh, 0Dh, 0Ah, 0Ah, 0Ah, 03h
		db	 09h, 08h, 0Bh, 03h, 0Bh, 0Ah
		db	 0Bh, 03h, 0Ah, 08h, 08h, 0Ah
		db	 0Bh, 0Ah, 0Bh, 06h, 02h, 06h
		db	 0Eh, 06h, 0Ah, 0Eh, 0Eh, 06h
		db	 0Eh, 06h, 06h, 0Ah, 0Ah, 0Eh
		db	 0Eh, 07h, 09h, 0Ch, 0Ah, 07h
		db	 0Bh, 0Eh, 0Fh, 07h, 0Fh, 0Ch
		db	 0Dh, 0Ah, 0Bh, 0Eh, 0Fh, 00h
		db	 01h, 04h, 04h, 02h, 04h, 06h
		db	 07h
		db	8 dup (0)
		db	 01h, 09h, 05h, 0Ch, 02h, 0Ch
		db	 02h, 03h, 00h
		db	7 dup (0)
		db	 04h, 05h, 0Ch, 05h, 08h, 05h
		db	 06h, 0Ch, 00h
		db	7 dup (0)
		db	 04h, 0Ch, 05h, 0Ch, 0Dh, 0Ch
		db	 07h, 0Ch, 00h
		db	7 dup (0)
		db	 02h, 02h, 08h, 0Dh, 0Ah, 0Dh
		db	 0Eh, 07h
		db	8 dup (0)
		db	 04h, 0Ch, 05h, 0Ch, 0Dh, 0Ch
		db	 07h, 0Ch, 00h
		db	7 dup (0)
		db	 06h, 02h, 06h, 07h, 0Eh, 07h
		db	 0Eh, 0Eh
		db	8 dup (0)
		db	 07h, 03h, 0Ch, 0Ch, 07h, 0Ch
		db	 0Eh, 0Fh
		db	136 dup (0)

stats_process_loop_4		proc	near
		push	cx
		push	si
		mov	si,cs:tga_color_lut
		mov	cx,4

lut_lookup_loop:
						xor	bx,bx			; Zero register
						rol	word ptr cs:src_word_d,1	; Rotate
						adc	bx,bx
						rol	word ptr cs:src_word_c,1	; Rotate
						adc	bx,bx
						rol	word ptr cs:src_word_b,1	; Rotate
						adc	bx,bx
						rol	word ptr cs:src_word_a,1	; Rotate
						adc	bx,bx
						rol	word ptr cs:src_word_d,1	; Rotate
						adc	bx,bx
						rol	word ptr cs:src_word_c,1	; Rotate
						adc	bx,bx
						rol	word ptr cs:src_word_b,1	; Rotate
						adc	bx,bx
						rol	word ptr cs:src_word_a,1	; Rotate
						adc	bx,bx
						add	ax,ax
						add	ax,ax
						add	ax,ax
						add	ax,ax
						or	al,cs:[bx+si]
						loop	lut_lookup_loop		; Loop if cx > 0

		xchg	ah,al
		pop	si
		pop	cx
		retn

stats_process_loop_4		endp

stats_func_20		proc	near
		rol	word ptr cs:src_word_e,1	; Rotate
		sbb	dl,dl
		rol	word ptr cs:src_word_e,1	; Rotate
		sbb	dh,dh
		or	dl,dh
		and	dl,0F0h
		rol	word ptr cs:src_word_e,1	; Rotate
		sbb	al,al
		rol	word ptr cs:src_word_e,1	; Rotate
		sbb	dh,dh
		or	al,dh
		and	al,0Fh
		or	al,dl
		rol	word ptr cs:src_word_e,1	; Rotate
		sbb	dl,dl
		rol	word ptr cs:src_word_e,1	; Rotate
		sbb	dh,dh
		or	dl,dh
		and	dl,0F0h
		rol	word ptr cs:src_word_e,1	; Rotate
		sbb	ah,ah
		rol	word ptr cs:src_word_e,1	; Rotate
		sbb	dh,dh
		or	ah,dh
		and	ah,0Fh
		or	ah,dl
		retn

stats_func_20		endp

tga_copyback_entry:
		push	ds
		mov	ax,tga_vram_seg
		mov	ds,ax
		xor	si,si			; Zero register
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,tga_screen_start
		mov	cx,0C8h

tga_copyback_loop:
						push	cx
						push	si
						mov	cx,50h
						rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
						pop	si
						add	si,2000h
						cmp	si,tga_work_buf
						jb	cpyback_wrap			; Jump if below
						add	si,tga_bank_wrap

cpyback_wrap:
						pop	cx
						loop	tga_copyback_loop		; Loop if cx > 0

		pop	ds
		xor	ax,ax			; Zero register
		mov	di,tga_work_buf
		mov	cx,4000h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

palette_xlat_entry:
		push	bx
		mov	bl,ah
		xor	bh,bh			; Zero register
		mov	ah,cs:tga_palette_xlat[bx]
		pop	bx
		jmp	word ptr cs:palette_xlat_jmp
		db	0, 5, 2, 7, 3, 4
		db	6, 1

extract_bits_2		proc	near
		add	bh,bh
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

extract_bits_2		endp

		db	0C3h
		db	1057 dup (0)
palette_xlat_jmp		dw	0
		db	44 dup (0)
plane3_merge_buf		db	0			; Data table (indexed access)
		db	588 dup (0)

seg_a		ends

		end	start
