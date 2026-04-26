
PAGE  59,132

;==========================================================================
;
;  102GDCGA - CGA Image Controller Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr1com.inc

; restored after factoring (consensus value, but not all files agree):
sprite_row_buf_b         equ     5500h
sprite_mask_off          equ     1A8Eh

; The following equates show data references outside the range of the program.

cga_screen_start		equ	0
cga_dispatch_fn	equ	2022h			;*
cga_plane2_buf	equ	2050h			;*
cga_plane3_buf	equ	29DCh			;*
cga_blit_fn_a	equ	3238h			;* CGA inner blit loop A (mode 0)
cga_blit_fn_b	equ	3275h			;* CGA inner blit loop B (with mode flag)
cga_blit_fn_c	equ	32AFh			;* CGA inner blit loop C (reverse)
cga_mask_tbl_a	equ	32C4h			;*
cga_mask_tbl_b	equ	32D4h			;*
sprite_src_tbl	equ	3635h			;*
sprite_frame_tbl	equ	3637h			;*
cga_scroll_mask_off	equ	3945h			;* CS offset of scroll cell mask data
move_seq_up	equ	3A05h			;*
move_seq_horiz	equ	3AC9h			;*
color_pair_tbl	equ	3AFCh			;*
cga_palette_xlat	equ	4A97h			;*
cga_color_lut	equ	4AA0h			;*
src_word_a	equ	4AA2h			;*
src_word_b	equ	4AA4h			;*
src_word_c	equ	4AA6h			;*
src_word_d	equ	4AA8h			;*
cur_col_ctr	equ	4AAAh			;*
cur_row_ctr	equ	4AABh			;*
cur_pass_ctr	equ	4AACh			;*
render_mode_flag	equ	4AADh			;*
render_fn_ptr	equ	4AAEh			;*
saved_di	equ	4AB0h			;*
saved_es	equ	4AB2h			;*
sprite_row_buf	equ	4DD4h			;*
sprite_img_base	equ	9F36h			;*
cga_bank2_wrap	equ	0C050h			;*
font_ptr_a	equ	0F500h			;*
gvar_frame_timer	equ	0FF1Ah			;*
gvar_game_seg	equ	0FF2Ch			;*
gvar_ff5f	equ	0FF5Fh			;*
gvar_ff60	equ	0FF60h			;*
gvar_ff61	equ	0FF61h			;*
cga_work_buf	equ	4000h			;*
cga_work_buf_p2	equ	4050h			;*
cga_buf_reset	equ	0			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

cga_imgctl_module		proc	far

start:
		sbb	byte ptr ds:[0],bl
		lahf				; Load ah from flags
		dec	dx
		xor	dh,[bx+si]
		js	render_plane_a_entry			; Jump if sign=1
		retn	0EF30h
		inc	ax
		dec	bp
		dec	dx
		in	al,32h			; port 32h ??I/O Non-standard
		cmp	al,33h			; '3'
;*		sal	word ptr [bp+di],cl	; Shift w/zeros fill
		db	0D3h, 33h		;  Fixup - byte match
		push	si
		xor	al,55h			; 'U'
		mov	ax,ss:sprite_img_base
		dec	dx
		jmp	$-12CDh
		db	 36h, 6Fh, 37h, 16h, 38h,0FFh	; dispatch words: 6F36h, 1637h, FF38h
		db	':@<', 0Dh, '=c=??$'		; dispatch words (text-encoded): 403Ah, 0D3Ch, ...
		db	'@'				; dispatch table padding byte
		db	0BDh, 40h, 87h, 4Ah, 50h, 53h	; dispatch word: 40BDh + push ax/bx
		db	 51h, 1Eh			; push cx; push ds (entry preamble)

render_plane_a_entry:
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
		mov	word ptr cs:src_word_b,0
		mov	word ptr cs:src_word_c,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

render_plane_a_loop:
								mov	ax,ds:[bp+si]
								mov	cs:src_word_d,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosw				; Store ax to es:[di]
								loop	render_plane_a_loop		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		pop	ax
		mov	di,0
		jmp	render_blit_entry

disp_render_a_only:
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

render_plane_ab_loop:
								add	bp,bp
								mov	ax,ds:[bp+si]
								mov	cs:src_word_c,ax
								shr	bp,1			; Shift w/zeros fill
								mov	ax,ds:[bp+si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosw				; Store ax to es:[di]
								loop	render_plane_ab_loop		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		pop	ax
		mov	di,0
		jmp	render_blit_entry

disp_render_a_rev:
		push	ds
		push	ax
		push	es
		push	di
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,cga_blit_fn_c
		call	equip_func_1
		pop	ds
		retn

disp_render_a_full:
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
		mov	word ptr cs:src_word_a,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

render_plane_ba_loop:
								mov	ax,ds:[bp+si]
								mov	cs:src_word_c,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_b,ax
								call	equip_process_loop_5
								stosw				; Store ax to es:[di]
								loop	render_plane_ba_loop		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		xor	ax,ax			; Zero register
		mov	di,0
		push	ds
		push	ax
		push	es
		push	di
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,cga_blit_fn_b
		mov	byte ptr cs:render_mode_flag,0
		or	al,al			; Zero ?
		jnz	render_blit_skip			; Jump if not zero
		call	equip_func_1

render_blit_skip:
		mov	byte ptr cs:render_mode_flag,0FFh
		call	equip_func_1
		pop	ds
		retn

render_blit_entry:
		push	ds
		push	ax
		push	es
		push	di
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,cga_blit_fn_a
		mov	byte ptr cs:render_mode_flag,0
		or	al,al			; Zero ?
		jnz	render_blit_skip2			; Jump if not zero
		call	equip_func_1

render_blit_skip2:
		mov	byte ptr cs:render_mode_flag,0FFh
		call	equip_func_1
		pop	ds
		retn

cga_imgctl_module		endp

equip_func_1		proc	near
		mov	byte ptr cs:cur_row_ctr,0
		mov	ax,0B800h
		mov	es,ax
		mov	bp,8

col_render_pass_top:
		mov	al,cs:cur_row_ctr
		mov	cs:cur_col_ctr,al
		mov	byte ptr cs:gvar_frame_timer,0
		push	cx
		push	si
		push	di

col_render_even:
								mov	bl,cs:cur_col_ctr
								and	bx,7
								add	bx,bx
								mov	bx,cs:cga_mask_tbl_a[bx]
								call	word ptr cs:render_fn_ptr
								inc	byte ptr cs:cur_col_ctr
								mov	al,ch
								xor	ah,ah			; Zero register
								add	si,ax
								add	di,2000h
								cmp	di,4000h
								jb	col_render_odd			; Jump if below
								add	di,0C050h

col_render_odd:
								dec	cl
								jz	col_render_done			; Jump if zero
								mov	bl,cs:cur_col_ctr
								and	bx,7
								add	bx,bx
								mov	bx,cs:cga_mask_tbl_b[bx]
								call	word ptr cs:render_fn_ptr
								inc	byte ptr cs:cur_col_ctr
								mov	al,ch
								xor	ah,ah			; Zero register
								add	si,ax
								add	di,2000h
								cmp	di,4000h
								jb	col_render_odd_wrap			; Jump if below
								add	di,0C050h

col_render_odd_wrap:
								dec	cl
								jnz	col_render_even			; Jump if not zero

col_render_done:
		pop	di
		pop	si
		pop	cx
		inc	byte ptr cs:cur_row_ctr

col_render_timer_wait:
								cmp	byte ptr cs:gvar_frame_timer,14h
								jb	col_render_timer_wait			; Jump if below
		dec	bp
		jz	col_render_ret		; Jump if zero
		jmp	col_render_pass_top

col_render_ret:
		retn

equip_func_1		endp

disp_blit_masked:
		test	byte ptr cs:render_mode_flag,0FFh
		jz	blit_or_only			; Jump if zero
		push	si
		push	di
		push	cx
		mov	dx,bx
		not	bx
		mov	cl,ch
		xor	ch,ch			; Zero register

blit_masked_loop:
								and	es:[di],bl
								lodsb				; String [si] to al
								and	al,dl
								or	es:[di],al
								inc	di
								xchg	dh,dl
								xchg	bh,bl
								loop	blit_masked_loop		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn

blit_or_only:
								push	si
								push	di
								push	cx
								mov	cl,ch
								xor	ch,ch			; Zero register

blit_or_loop:
														lodsb				; String [si] to al
														and	al,bl
														or	es:[di],al
														inc	di
														xchg	bh,bl
														loop	blit_or_loop		; Loop if cx > 0

								pop	cx
								pop	di
								pop	si
								retn

disp_blit_expand:
								test	byte ptr cs:render_mode_flag,0FFh
								jz	blit_or_only			; Jump if zero
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register

blit_expand_loop:
								push	cx
								lodsb				; String [si] to al
								mov	ah,al
								mov	dl,3
								mov	cx,4

expand_bits_loop:
														test	ah,dl
														jz	expand_no_fill			; Jump if zero
														or	ah,dl

expand_no_fill:
														add	dl,dl
														add	dl,dl
														loop	expand_bits_loop		; Loop if cx > 0

								and	ah,bl
								not	ah
								and	es:[di],ah
								and	al,bl
								or	es:[di],al
								inc	di
								xchg	bh,bl
								pop	cx
								loop	blit_expand_loop		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn

disp_blit_clear:
		push	di
		push	cx
		not	bx
		mov	cl,ch
		xor	ch,ch			; Zero register

blit_clear_loop:
								and	es:[di],bl
								inc	di
								xchg	dh,dl
								xchg	bh,bl
								loop	blit_clear_loop		; Loop if cx > 0

		pop	cx
		pop	di
		retn
		; inline data / dead-zone bytes between blit_clear and text_char_loop
		db	 00h,0C0h, 00h, 0Ch,0C0h, 00h	; pixel-clear pattern row 0
		db	 0Ch, 00h, 00h, 30h, 00h, 03h	; pixel-clear pattern row 1
		db	 30h, 00h, 03h, 00h, 03h, 00h	; pixel-clear pattern row 2
		db	 30h, 00h, 00h, 03h, 00h, 30h	; pixel-clear pattern row 3
		db	 0Ch, 00h,0C0h, 00h, 00h, 0Ch	; pixel-clear pattern row 4
		db	 00h,0C0h, 0Eh, 07h,0BFh,0B4h	; pixel-clear tail + push cs; pop es; mov di,...
		db	 4Ah, 33h,0C0h,0B9h, 90h, 01h	; mov di,4AB4h; xor ax,ax; mov cx,190h
		db	0F3h,0ABh,0BFh,0B4h		; rep stosw; mov di,...
		db	4Ah				; ...4AB4h (operand high byte) -> text_char_loop

text_char_loop:
								lodsb				; String [si] to al
								cmp	al,0FFh
								jne	text_char_skip			; Jump if not equal
								retn

text_char_skip:
								sub	al,20h			; ' '
								jnc	text_char_render			; Jump if carry=0
								retn

text_char_render:
								jz	text_advance			; Jump if zero
								push	si
								push	di
								xor	ah,ah			; Zero register
								add	ax,ax
								add	ax,ax
								add	ax,ax
								add	ax,ds:font_ptr_a
								mov	si,ax
								mov	cx,8

text_glyph_row_loop:
														push	cx
														lodsb				; String [si] to al
														call	equip_process_loop
														mov	es:[di],dx
														add	di,50h
														pop	cx
														loop	text_glyph_row_loop		; Loop if cx > 0

								pop	di
								pop	si

text_advance:
								add	di,2
								jmp	short text_char_loop

equip_process_loop		proc	near
		mov	cx,8

build_pixel_pair_loop:
								add	al,al
								adc	bx,bx
								add	bx,bx
								loop	build_pixel_pair_loop		; Loop if cx > 0

		mov	dx,bx
		shr	dx,1			; Shift w/zeros fill
		or	dx,bx
		xchg	dh,dl
		retn

equip_process_loop		endp

disp_scroll_copy:
		push	ds
		push	cx
		push	bx
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,4AB4h
		mov	si,ax
		add	cl,bl
		mov	al,50h			; 'P'
		mul	cl			; ax = reg * al
		add	ax,4000h
		push	ax
		push	si
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		push	ds
		pop	es
		mov	di,cga_work_buf
		mov	si,cga_work_buf_p2
		mov	cx,1FD8h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		push	cs
		pop	ds
		mov	cx,28h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	bx
		push	bx
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		pop	bx
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	si,ax
		add	si,0
		mov	bp,ax
		add	bp,cga_work_buf
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	ax,0B800h
		mov	es,ax
		pop	cx
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

scroll_copy_row_loop:
								push	cx
								push	di
								mov	cx,bx
								shr	cx,1			; Shift w/zeros fill

scroll_or_word_loop:
														lodsw				; String [si] to ax
														or	ax,ds:[bp]
														stosw				; Store ax to es:[di]
														inc	bp
														inc	bp
														loop	scroll_or_word_loop		; Loop if cx > 0

								pop	di
								add	di,2000h
								cmp	di,4000h
								jb	scroll_wrap			; Jump if below
								add	di,0C050h

scroll_wrap:
								pop	cx
								loop	scroll_copy_row_loop		; Loop if cx > 0

		pop	ds
		retn

sprite_render_entry:
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

sprite_render_loop:
								add	bp,bp
								mov	ax,ds:[bp+si]
								mov	cs:src_word_c,ax
								shr	bp,1			; Shift w/zeros fill
								mov	ax,ds:[bp+si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosw				; Store ax to es:[di]
								loop	sprite_render_loop		; Loop if cx > 0

		pop	cx
		pop	bx
		pop	ax
		pop	ds

sprite_blit_entry:
		push	ds
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	si,cga_buf_reset
		push	es
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

sprite_blit_row_loop:
								push	cx
								push	di
								mov	cx,bx
								rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
								pop	di
								pop	cx
								add	di,2000h
								cmp	di,4000h
								jb	sprite_blit_wrap			; Jump if below
								add	di,0C050h

sprite_blit_wrap:
								loop	sprite_blit_row_loop		; Loop if cx > 0

		pop	ds
		retn

disp_sprite_obj_init:
		push	cs
		pop	es
		mov	di,sprite_obj_tbl
		xor	dx,dx			; Zero register
		mov	cx,9

sprite_obj_init_loop:
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
								add	dx,0C0h
								loop	sprite_obj_init_loop		; Loop if cx > 0

		mov	byte ptr ds:gvar_frame_timer,0

sprite_animate_top:
		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_check_active:
		push	cx
		test	byte ptr [si],0FFh
		jz	sprite_skip_inactive			; Jump if zero
		mov	al,[si+0Dh]
		cmp	al,[si+0Eh]
		je	sprite_update_frame			; Jump if equal
		inc	byte ptr [si+0Ch]
		test	byte ptr [si+0Ch],1
		jnz	sprite_update_frame			; Jump if not zero
		inc	byte ptr [si+0Dh]

sprite_update_frame:
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	cx,ds:sprite_frame_tbl[bx]
		mov	[si+7],cx
		mov	al,[si+4]
		add	al,[si+0Ah]
		mov	[si+4],al
		mov	dh,al
		mov	al,[si+3]
		add	al,[si+9]
		mov	[si+3],al
		mov	dl,al
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	bp,ax
		add	ax,ax
		add	ax,ax
		add	ax,bp
		add	ax,ax
		mov	dl,dh
		xor	dh,dh			; Zero register
		add	ax,dx
		mov	[si+5],ax
		mov	di,ax
		mov	bp,[si+1]
		push	ds
		push	si
		mov	ax,0B800h
		mov	ds,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	si,di
		mov	di,bp
		call	copy_buffer
		pop	si
		pop	ds

sprite_skip_inactive:
		pop	cx
		add	si,0Fh
		loop	sprite_animate_next		; Loop if cx > 0

		jmp	short sprite_blit_all_top

sprite_animate_next:
		jmp	sprite_check_active

sprite_blit_all_top:
		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_blit_all_loop:
								push	cx
								test	byte ptr cs:[si],0FFh
								jz	sprite_skip_oob			; Jump if zero
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
								jae	sprite_skip_oob			; Jump if above or =
								cmp	al,0A0h
								jae	sprite_skip_oob			; Jump if above or =
								mov	[si],dl
								mov	di,[si+5]
								push	ds
								push	si
								mov	ax,0B800h
								mov	es,ax
								mov	ds,cs:gvar_game_seg
								mov	si,bp
								call	equip_multiply
								pop	si
								pop	ds

sprite_skip_oob:
								pop	cx
								add	si,0Fh
								loop	sprite_blit_all_loop		; Loop if cx > 0

sprite_frame_timer_wait:
								cmp	byte ptr cs:gvar_frame_timer,1Eh
								jb	sprite_frame_timer_wait			; Jump if below
		mov	byte ptr cs:gvar_frame_timer,0
		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_restore_loop:
								push	cx
								mov	bp,[si+1]
								mov	di,[si+5]
								mov	cx,[si+7]
								push	ds
								push	si
								mov	ax,0B800h
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
								loop	sprite_restore_loop		; Loop if cx > 0

		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_active_check_loop:
								test	byte ptr [si],0FFh
								jz	sprite_active_check_next			; Jump if zero
								jmp	sprite_animate_top

sprite_active_check_next:
								add	si,0Fh
								loop	sprite_active_check_loop		; Loop if cx > 0

		retn

copy_buffer		proc	near
		push	si
		push	cx

copy_buf_row_top:
								push	si
								push	cx
								mov	cl,ch
								xor	ch,ch			; Zero register
								rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
								pop	cx
								pop	si
								add	si,2000h
								cmp	si,4000h
								jb	copy_buf_row_wrap			; Jump if below
								add	si,0C050h

copy_buf_row_wrap:
								dec	cl
								jnz	copy_buf_row_top			; Jump if not zero
		pop	cx
		pop	si
		retn

copy_buffer		endp

copy_buffer_2		proc	near
		push	di
		push	cx

copy_buf2_row_top:
								push	di
								push	cx
								mov	cl,ch
								xor	ch,ch			; Zero register
								rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
								pop	cx
								pop	di
								add	di,2000h
								cmp	di,4000h
								jb	copy_buf2_row_wrap			; Jump if below
								add	di,0C050h

copy_buf2_row_wrap:
								dec	cl
								jnz	copy_buf2_row_top			; Jump if not zero
		pop	cx
		pop	di
		retn

copy_buffer_2		endp

equip_multiply		proc	near
		push	di
		push	cx
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bx,ax
		mov	word ptr cs:src_word_d,0
		mov	word ptr cs:src_word_c,0

multiply_row_top:
								push	di
								push	cx
								mov	cl,ch
								xor	ch,ch			; Zero register

multiply_pixel_loop:
														xor	ah,ah			; Zero register
														mov	al,[bx+si]
														mov	cs:src_word_b,ax
														lodsb				; String [si] to al
														mov	cs:src_word_a,ax
														push	bx
														call	equip_process_loop_5
														pop	bx
														or	es:[di],al
														inc	di
														loop	multiply_pixel_loop		; Loop if cx > 0

								pop	cx
								pop	di
								add	di,2000h
								cmp	di,4000h
								jb	multiply_row_wrap			; Jump if below
								add	di,0C050h

multiply_row_wrap:
								dec	cl
								jnz	multiply_row_top			; Jump if not zero
		pop	cx
		pop	di
		retn

equip_multiply		endp

		; inline data / dead-zone bytes before plane_mix_loop entry
		db	 00h, 90h, 20h, 06h, 80h, 91h	; CRTC seq: (00h,90h),(20h,06h),(80h,91h)
		db	 20h, 06h, 00h, 93h, 20h, 06h	; CRTC seq: (20h,06h),(00h,93h),(20h,06h)
		db	 80h, 94h, 20h, 06h, 00h, 96h	; CRTC seq: (80h,94h),(20h,06h),(00h,96h)
		db	 18h, 04h,0C0h, 96h, 18h, 04h	; CRTC seq: (18h,04h),(C0h,96h),(18h,04h)
		db	 80h, 97h, 18h, 04h, 40h, 98h	; CRTC seq: (80h,97h),(18h,04h),(40h,98h)
		db	 18h, 04h, 1Eh, 53h, 32h,0E4h	; CRTC seq tail + push ds; push bx; xor ah
		db	0BAh,0C0h			; mov dx,0C0h (low byte/operand)
		db	0Ch				; (cont. mov dx high byte = 0Ch -> dx=0CC0h)
plane_mix_word		dw	0E2F7h			; word read by plane_mix_loop via [plane_mix_word+si]
		db	 05h, 40h,0ABh, 2Eh, 8Eh, 1Eh	; add ax,4000h; stosw; mov ds,[cs:gvar]
		db	 2Ch,0FFh, 8Bh,0F0h, 8Ch,0C8h	; sub al,FFh; mov si,ax; mov ax,cs
		db	 05h, 00h, 30h, 8Eh,0C0h,0BFh	; add ax,3000h; mov es,ax; mov di,...
		db	 00h, 00h, 2Eh,0C7h, 06h,0A8h	; ...0; mov word ptr cs:[4AA8h],...
		db	 4Ah, 00h, 00h, 2Eh,0C7h, 06h	; ...0; mov word ptr cs:[4AA6h],...
		db	0A6h, 4Ah, 00h, 00h,0B9h, 30h	; ...0; mov cx,330h
		db	 03h				; (cont. mov cx high byte) -> plane_mix_loop

plane_mix_loop:
								mov	ax,plane_mix_word[si]
								mov	cs:src_word_a,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_b,ax
								call	equip_process_loop_5
								stosw				; Store ax to es:[di]
								loop	plane_mix_loop		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,0
		mov	cx,2230h
		jmp	sprite_blit_entry

disp_sprite_plane_mix:
		push	ds
		push	bx
		xor	ah,ah			; Zero register
		mov	dx,480h
		mul	dx			; dx:ax = reg * ax
		add	ax,97C0h
		mov	ds,cs:gvar_game_seg
		mov	si,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	di,0
		mov	word ptr cs:src_word_d,0
		mov	word ptr cs:src_word_c,0
		mov	cx,120h

sprite_plane_mix_loop:
								mov	ax,ds:cga_plane2_off[si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosw				; Store ax to es:[di]
								loop	sprite_plane_mix_loop		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,cga_screen_start
		mov	cx,1220h
		jmp	sprite_blit_entry
		db	 33h,0DBh,0B9h, 19h, 00h	; dead-zone bytes before char_expand_row_loop

char_expand_row_loop:
								push	cx
								mov	cx,22h

char_expand_col_loop:
														push	cx
														lodsb				; String [si] to al
														push	bx
														push	ds
														push	si
														call	equip_multiply_2
														pop	si
														pop	ds
														pop	bx
														inc	bh
														pop	cx
														loop	char_expand_col_loop		; Loop if cx > 0

								xor	bh,bh			; Zero register
								inc	bl
								pop	cx
								loop	char_expand_row_loop		; Loop if cx > 0

		retn

equip_multiply_2		proc	near
		mov	ds,cs:gvar_game_seg
		mov	dx,cs
		add	dx,2000h
		mov	es,dx
		xor	ah,ah			; Zero register

char_div_28_loop:
								sub	al,28h			; '('
								jc	char_div_28_done			; Jump if carry Set
								inc	ah
								jmp	short char_div_28_loop

char_div_28_done:
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

char_copy_band_loop:
								push	cx
								push	di
								push	si
								mov	cx,8

char_copy_pixel_loop:
														movsb				; Mov [si] to es:[di]
														add	di,21h
														add	si,27h
														loop	char_copy_pixel_loop		; Loop if cx > 0

								pop	si
								pop	di
								add	di,1A90h
								add	si,640h
								pop	cx
								loop	char_copy_band_loop		; Loop if cx > 0

		retn

equip_multiply_2		endp

disp_char_expand:
		mov	word ptr cs:src_word_d,0
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

bit_rotate_loop:
														ror	al,1			; Rotate
														adc	ah,ah
														dec	dx
														jnz	bit_rotate_loop			; Jump if not zero
								mov	es:[di],ah
								inc	di
								loop	bit_reverse_loop		; Loop if cx > 0

		pop	si
		pop	ax
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	bl,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	ax,0B800h
		mov	es,ax
		push	di
		mov	cx,11h

hud_blend_row_loop:
								lodsw				; String [si] to ax
								mov	cs:src_word_b,ax
								mov	ax,ds:sprite_mask_off[si]
								mov	cs:src_word_c,ax
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								or	es:[di],ax
								inc	di
								inc	di
								loop	hud_blend_row_loop		; Loop if cx > 0

		pop	di
		add	di,4Eh
		push	cs
		pop	ds
		mov	si,sprite_row_buf
		mov	cx,11h

hud_blend_row2_loop:
								lodsw				; String [si] to ax
								xchg	ah,al
								mov	cs:src_word_b,ax
								mov	ax,[si+20h]
								xchg	ah,al
								mov	cs:src_word_c,ax
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								or	es:[di],ax
								dec	di
								dec	di
								loop	hud_blend_row2_loop		; Loop if cx > 0

		pop	ds
		retn

disp_pixel_reorder:
		mov	bx,ax
		mov	al,ds:color_pair_tbl[bx]
		mov	ds:cur_row_ctr,al
		mov	ax,0B800h
		mov	es,ax
		mov	di,284h
		mov	si,move_seq_up

draw_top_seg_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	draw_right_seg_start			; Jump if zero
								call	equip_func_7
								add	di,0A0h
								jmp	short draw_top_seg_loop

draw_right_seg_start:
		add	di,gvar_ff61

draw_right_seg_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	draw_left_seg_start			; Jump if zero
								call	equip_func_7
								inc	di
								jmp	short draw_right_seg_loop

draw_left_seg_start:
		add	di,gvar_ff5f

draw_left_seg_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	draw_bot_right_start			; Jump if zero
								call	equip_func_7
								add	di,0FF60h
								jmp	short draw_left_seg_loop

draw_bot_right_start:
		add	di,9Fh

draw_bot_right_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	draw_bot_left_start			; Jump if zero
								call	equip_func_7
								dec	di
								jmp	short draw_bot_right_loop

draw_bot_left_start:
		add	di,0A1h
		mov	si,move_seq_horiz

draw_segment_top:
								mov	byte ptr cs:gvar_frame_timer,0
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jnz	draw_segment_count_a			; Jump if not zero
								retn

draw_segment_count_a:
								xor	cx,cx			; Zero register
								mov	cl,al

draw_vert_loop_a:
														push	cx
														mov	al,18h
														call	equip_func_7
														add	di,0A0h
														pop	cx
														loop	draw_vert_loop_a		; Loop if cx > 0

								add	di,gvar_ff60
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jnz	draw_segment_count_b			; Jump if not zero
								retn

draw_segment_count_b:
								xor	cx,cx			; Zero register
								mov	cl,al

draw_horiz_loop_a:
														push	cx
														mov	al,18h
														call	equip_func_7
														inc	di
														pop	cx
														loop	draw_horiz_loop_a		; Loop if cx > 0

								dec	di
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jnz	draw_segment_count_c			; Jump if not zero
								retn

draw_segment_count_c:
								xor	cx,cx			; Zero register
								mov	cl,al

draw_vert_loop_b:
														push	cx
														mov	al,18h
														call	equip_func_7
														add	di,0FF60h
														pop	cx
														loop	draw_vert_loop_b		; Loop if cx > 0

								add	di,0A0h
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jnz	draw_segment_count_d			; Jump if not zero
								retn

draw_segment_count_d:
								xor	cx,cx			; Zero register
								mov	cl,al

draw_vert_loop_c:
														push	cx
														mov	al,18h
														call	equip_func_7
														dec	di
														pop	cx
														loop	draw_vert_loop_c		; Loop if cx > 0

								inc	di

draw_segment_timer_wait:
														cmp	byte ptr cs:gvar_frame_timer,0Ch
														jb	draw_segment_timer_wait			; Jump if below
								jmp	short draw_segment_top

equip_func_7		proc	near
		push	si
		push	di
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cga_scroll_mask_off
		mov	si,ax
		lodsb				; String [si] to al
		and	al,cs:cur_row_ctr
		or	al,[si+3]
		stosb				; Store al to es:[di]
		add	di,1FFFh
		cmp	di,4000h
		jb	cell_write_row1_wrap			; Jump if below
		add	di,cga_bank2_wrap

cell_write_row1_wrap:
		lodsb				; String [si] to al
		and	al,cs:cur_row_ctr
		or	al,[si+3]
		stosb				; Store al to es:[di]
		add	di,1FFFh
		cmp	di,4000h
		jb	cell_write_row2_wrap			; Jump if below
		add	di,cga_bank2_wrap

cell_write_row2_wrap:
		lodsb				; String [si] to al
		and	al,cs:cur_row_ctr
		or	al,[si+3]
		stosb				; Store al to es:[di]
		add	di,1FFFh
		cmp	di,4000h
		jb	cell_write_row3_wrap			; Jump if below
		add	di,cga_bank2_wrap

cell_write_row3_wrap:
		lodsb				; String [si] to al
		and	al,cs:cur_row_ctr
		or	al,[si+3]
		stosb				; Store al to es:[di]
		pop	di
		pop	si
		retn

equip_func_7		endp

		; CGA cell color pattern table (8 bytes per cell, used by equip_func_7 / cga_scroll_mask_off)
		; followed by color index map and entry code bytes for extract_src_planes_loop
		db	 00h, 00h, 00h, 03h, 80h, 80h	; cell row  0
		db	 8Ah, 88h, 03h, 03h, 03h, 03h	; cell row  1
		db	 88h, 88h, 88h, 88h, 03h, 03h	; cell row  2
		db	 03h, 03h, 88h, 88h, 88h,0A8h	; cell row  3
		db	 00h, 00h, 00h,0FFh, 00h, 00h	; cell row  4
		db	0AAh, 00h, 00h, 00h, 00h,0FFh	; cell row  5
		db	 02h, 02h,0AAh, 00h, 00h, 00h	; cell row  6
		db	 00h,0FFh, 80h, 80h,0AAh, 00h	; cell row  7
		db	 00h, 00h, 00h,0C0h, 02h, 02h	; cell row  8
		db	0A2h, 22h,0C0h,0C0h,0C0h,0C0h	; cell row  9
		db	 22h, 22h, 22h, 22h,0C0h,0C0h	; cell row 10
		db	0C0h,0C0h, 22h, 22h, 22h, 22h	; cell row 11
		db	0C0h,0C0h,0C0h,0C0h, 2Ah, 02h	; cell row 12
		db	 02h, 02h, 03h, 03h, 03h, 03h	; cell row 13
		db	0A8h, 88h, 88h, 88h, 03h, 03h	; cell row 14
		db	 03h, 03h, 88h, 88h, 88h, 88h	; cell row 15
		db	 03h, 00h, 00h, 00h, 88h, 8Ah	; cell row 16
		db	 80h, 80h,0FFh, 00h, 00h, 00h	; cell row 17
		db	 00h,0AAh, 00h, 00h,0FFh, 00h	; cell row 18
		db	 00h, 00h, 00h,0AAh, 02h, 02h	; cell row 19
		db	0FFh, 00h, 00h, 00h, 00h,0AAh	; cell row 20
		db	 80h, 80h,0C0h,0C0h,0C0h,0C0h	; cell row 21
		db	 2Ah, 22h, 22h, 22h,0C0h,0C0h	; cell row 22
		db	0C0h,0C0h, 22h, 22h, 22h, 22h	; cell row 23
		db	0C0h, 00h, 00h, 00h, 22h,0A2h	; cell row 24
		db	 02h, 02h, 00h, 00h,0FFh,0FFh	; cell row 25
		db	 00h, 00h, 00h, 00h,0FFh,0FFh	; cell row 26
		db	 00h, 00h, 00h, 00h, 00h, 00h	; cell row 27
		db	 03h, 03h, 03h, 03h, 80h, 80h	; cell row 28
		db	 80h, 80h,0C0h,0C0h,0C0h,0C0h	; cell row 29
		db	 02h, 02h, 02h, 02h,0FFh,0FFh	; cell row 30
		db	0FFh,0FFh, 00h, 00h, 00h, 00h	; cell row 31
		db	 01h, 02h, 03h			; pal_seq A: indices 1,2,3
		db	20 dup (16h)			; pal_seq A: 20 entries of value 16h
		db	 0Bh, 0Ch, 0Dh, 00h, 0Eh, 0Fh	; pal_seq B: indices 0Bh-0Fh
		db	66 dup (15h)			; pal_seq B: 66 entries of value 15h
		db	 10h, 0Eh, 13h, 00h, 12h, 11h	; pal_seq C: indices 10h-13h
		db	19 dup (17h)			; pal_seq C: 19 entries of value 17h
		db	 0Ah, 09h, 08h, 07h, 00h, 04h	; pal_seq D: indices 04h-0Ah
		db	 06h				; pal_seq D: index 06h
		db	66 dup (14h)			; pal_seq D: 66 entries of value 14h
		db	 05h, 04h, 00h, 18h, 46h, 18h	; final fade-out pair table (reg, val pairs):
		db	 45h, 17h, 44h, 16h, 43h, 15h	;
		db	 42h, 14h, 41h, 13h, 40h, 12h	;
		db	 3Fh, 11h, 3Eh, 10h, 3Dh, 0Fh	;
		db	 3Ch, 0Eh, 3Bh, 0Dh, 3Ah, 0Ch	;
		db	 39h, 0Bh, 38h, 0Ah, 37h, 09h	;
		db	 36h, 08h, 35h, 07h, 34h, 06h	;
		db	 33h, 05h, 32h, 04h, 31h, 03h	;
		db	 30h, 02h, 2Fh, 01h, 2Eh, 00h	;
		db	 00h,0AAh, 55h, 1Eh, 2Eh,0A2h	; param tag bytes (caller signature) + push ds; mov [cs:..],al
		db	0ADh, 4Ah, 53h, 51h, 8Ah,0C5h	; ...4AADh,al; push bx; push cx; mov al,ch
		db	0F6h,0E1h, 8Bh,0E8h, 06h, 1Fh	; mul cl; mov bp,ax; push es; pop ds
		db	 8Bh,0F7h, 8Ch,0C8h, 05h, 00h	; mov si,di; mov ax,cs; add ax,...
		db	 30h, 8Eh,0C0h,0BFh, 00h, 00h	; ...3000h; mov es,ax; mov di,0
		db	 2Eh,0C7h, 06h,0A8h, 4Ah, 00h	; mov word ptr cs:[4AA8h],...
		db	 00h, 2Eh,0C7h, 06h,0A2h, 4Ah	; ...0; mov word ptr cs:[4AA2h],...
		db	 00h, 00h, 2Eh,0C7h, 06h,0A4h	; ...0; mov word ptr cs:[4AA4h],...
		db	 4Ah, 00h, 00h, 2Eh,0C7h, 06h	; ...0; mov word ptr cs:[4AA6h],...
		db	0A6h, 4Ah, 00h, 00h, 8Bh,0CDh	; ...0; mov cx,bp
		db	0D1h,0E9h			; shr cx,1 -> extract_src_planes_loop

extract_src_planes_loop:
								push	si
								test	byte ptr cs:render_mode_flag,1
								jz	extract_plane_a_skip			; Jump if zero
								mov	ax,[si]
								mov	cs:src_word_a,ax
								add	si,bp

extract_plane_a_skip:
								test	byte ptr cs:render_mode_flag,2
								jz	extract_plane_b_skip			; Jump if zero
								mov	ax,[si]
								mov	cs:src_word_b,ax
								add	si,bp

extract_plane_b_skip:
								test	byte ptr cs:render_mode_flag,4
								jz	extract_plane_c_skip			; Jump if zero
								mov	ax,[si]
								mov	cs:src_word_c,ax

extract_plane_c_skip:
								call	equip_process_loop_5
								stosw				; Store ax to es:[di]
								pop	si
								inc	si
								inc	si
								loop	extract_src_planes_loop		; Loop if cx > 0

		pop	cx
		pop	bx
		sub	bx,410h
		mov	byte ptr cs:cur_row_ctr,0
		mov	byte ptr cs:cur_pass_ctr,0
		mov	cs:render_fn_ptr,cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,cga_buf_reset
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

extract_pass_loop:
								push	cx
								mov	al,cs:cur_pass_ctr
								mov	cs:cur_row_ctr,al
								mov	byte ptr cs:gvar_frame_timer,0
								mov	cx,0Dh

extract_col_loop:
														push	cx
														push	bx
														push	si
														call	extract_bits
														pop	si
														pop	bx
														pop	cx
														add	byte ptr cs:cur_row_ctr,8
														loop	extract_col_loop		; Loop if cx > 0

								pop	cx

extract_timer_wait:
														cmp	byte ptr cs:gvar_frame_timer,14h
														jb	extract_timer_wait			; Jump if below
								inc	byte ptr cs:cur_pass_ctr
								loop	extract_pass_loop		; Loop if cx > 0

		pop	ds
		retn

extract_bits		proc	near
		mov	al,cs:cur_row_ctr
		add	al,10h
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,4
		add	di,ax
		cmp	cs:cur_row_ctr,bl
		jb	extract_clear_block			; Jump if below
		mov	al,bl
		add	al,cs:render_fn_ptr
		cmp	cs:cur_row_ctr,al
		jae	extract_clear_block			; Jump if above or =
		mov	al,cs:cur_row_ctr
		sub	al,bl
		mul	byte ptr cs:render_fn_ptr+1	; ax = data * al
		add	si,ax
		mov	byte ptr cs:cur_col_ctr,0
		mov	cx,48h

extract_pixel_loop:
								push	cx
								mov	byte ptr es:[di],0
								cmp	cs:cur_col_ctr,bh
								jb	extract_pixel_write			; Jump if below
								mov	al,bh
								add	al,byte ptr cs:render_fn_ptr+1
								cmp	cs:cur_col_ctr,al
								jae	extract_pixel_write			; Jump if above or =
								movsb				; Mov [si] to es:[di]
								dec	di

extract_pixel_write:
								inc	di
								inc	byte ptr cs:cur_col_ctr
								pop	cx
								loop	extract_pixel_loop		; Loop if cx > 0

		retn

extract_clear_block:
		mov	cx,24h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

extract_bits		endp

disp_draw_status:
		mov	cs:cur_row_ctr,bl
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	ax,0B800h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register
		sub	cx,5
		push	cx
		push	di
		call	fill_buffer
		pop	di
		inc	byte ptr cs:cur_row_ctr
		add	di,2000h
		cmp	di,4000h
		jb	fill_bank_wrap			; Jump if below
		add	di,cga_bank2_wrap

fill_bank_wrap:
		mov	cx,2
		call	clear_buffer
		pop	cx

fill_pixel_loop:
								push	cx
								call	equip_get_value
								or	byte ptr es:[di],30h	; '0'
								and	byte ptr es:[di],0F0h
								or	byte ptr es:[bx+di-1],0Ch
								and	byte ptr es:[bx+di-1],0Fh
								inc	byte ptr cs:cur_row_ctr
								add	di,2000h
								cmp	di,4000h
								jb	fill_pixel_wrap			; Jump if below
								add	di,cga_bank2_wrap

fill_pixel_wrap:
								pop	cx
								loop	fill_pixel_loop		; Loop if cx > 0

		mov	cx,1
		call	clear_buffer

fill_buffer		proc	near
		call	equip_get_value
		or	byte ptr es:[di],3Fh	; '?'
		inc	di
		mov	cx,bx
		sub	cx,2
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0FCh
		retn

fill_buffer		endp

clear_buffer		proc	near

clear_row_loop:
								push	cx
								push	di
								call	equip_get_value
								or	byte ptr es:[di],30h	; '0'
								and	byte ptr es:[di],0F0h
								inc	di
								mov	cx,bx
								sub	cx,2
								xor	al,al			; Zero register
								rep	stosb			; Rep when cx >0 Store al to es:[di]
								or	byte ptr es:[di],0Ch
								and	byte ptr es:[di],0Fh
								pop	di
								inc	byte ptr cs:cur_row_ctr
								add	di,2000h
								cmp	di,4000h
								jb	clear_row_wrap			; Jump if below
								add	di,0C050h

clear_row_wrap:
								pop	cx
								loop	clear_row_loop		; Loop if cx > 0

		retn

clear_buffer		endp

equip_get_value		proc	near
		mov	word ptr es:[di-1],0
		retn

equip_get_value		endp

disp_fill_col:
		push	bx
		push	es
		push	di
		mov	cx,1028h

		; Note: disp_frame_render3 is used as plane C buffer offset in ES (CGA seg)
		;       because the entry code for that function happens to be at the plane C offset

plane3_merge_loop:
								mov	al,es:[di]
								and	al,es:disp_frame_render3[di]
								mov	ah,es:cga_plane2_buf[di]
								not	ah
								and	al,ah
								not	al
								and	es:[di],al
								and	es:disp_frame_render3[di],al
								and	es:cga_plane2_buf[di],al
								mov	al,es:cga_plane2_buf[di]
								mov	ah,es:[di]
								not	ah
								and	al,ah
								mov	ah,es:disp_frame_render3[di]
								not	ah
								and	al,ah
								or	es:[di],al
								or	es:disp_frame_render3[di],al
								not	al
								and	es:cga_plane2_buf[di],al
								inc	di
								loop	plane3_merge_loop		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,2F58h
		jmp	sprite_render_entry

disp_3plane_merge:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	di,69Ah
		add	di,ds:saved_di
		call	equip_process_loop_4
		mov	di,6BCh
		add	di,ds:saved_di
		call	equip_process_loop_4
		mov	ax,0B800h
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,44h

frame_render_row_top:
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
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		pop	ax
		add	ax,cs:saved_di
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	frame_render_use_bg			; Jump if below
		cmp	ax,71h
		jae	frame_render_use_bg			; Jump if above or =
		call	equip_process_loop_3
		jmp	short frame_render_row_bot

frame_render_use_bg:
		call	equip_process_loop_2

frame_render_row_bot:
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
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		pop	ax
		add	ax,cs:saved_di
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	frame_render_use_bg_b			; Jump if below
		cmp	ax,71h
		jae	frame_render_use_bg_b			; Jump if above or =
		call	equip_process_loop_3
		jmp	short frame_render_timer_wait

frame_render_use_bg_b:
		call	equip_process_loop_2

frame_render_timer_wait:
								cmp	byte ptr cs:gvar_frame_timer,4
								jb	frame_render_timer_wait			; Jump if below
		pop	cx
		loop	frame_render_row_loop		; Loop if cx > 0

		jmp	short frame_render_done

frame_render_row_loop:
		jmp	frame_render_row_top

frame_render_done:
		pop	ds
		retn

equip_process_loop_2		proc	near
		mov	cx,28h
		mov	word ptr cs:src_word_d,0

process2_word_loop:
								mov	ax,ds:sprite_row_buf_b[si]
								mov	cs:src_word_c,ax
								mov	ax,ds:cga_plane_stride[si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosw				; Store ax to es:[di]
								loop	process2_word_loop		; Loop if cx > 0

		retn

equip_process_loop_2		endp

equip_process_loop_3		proc	near
		mov	cx,0Bh
		mov	word ptr cs:src_word_d,0

process3_byte_top_loop:
								xor	ah,ah			; Zero register
								mov	al,ds:sprite_row_buf_b[si]
								mov	cs:src_word_c,ax
								mov	al,ds:cga_plane_stride[si]
								mov	cs:src_word_b,ax
								lodsb				; String [si] to al
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosb				; Store al to es:[di]
								loop	process3_byte_top_loop		; Loop if cx > 0

		add	si,18h
		add	di,18h
		mov	cx,5

process3_word_mid_loop:
								mov	ax,ds:sprite_row_buf_b[si]
								mov	cs:src_word_c,ax
								mov	ax,ds:cga_plane_stride[si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosw				; Store ax to es:[di]
								loop	process3_word_mid_loop		; Loop if cx > 0

		add	si,18h
		add	di,18h
		mov	cx,0Bh

process3_byte_bot_loop:
								xor	ah,ah			; Zero register
								mov	al,ds:sprite_row_buf_b[si]
								mov	cs:src_word_c,ax
								mov	al,ds:cga_plane_stride[si]
								mov	cs:src_word_b,ax
								lodsb				; String [si] to al
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosb				; Store al to es:[di]
								loop	process3_byte_bot_loop		; Loop if cx > 0

		retn

equip_process_loop_3		endp

equip_process_loop_4		proc	near
		push	di
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

draw_left_border_loop:
								mov	byte ptr es:[di],30h	; '0'
								mov	byte ptr es:[di+19h],0Ch
								add	di,50h
								loop	draw_left_border_loop		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		pop	di
		add	di,cga_plane_stride
		push	di
		mov	ax,0FD7Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,2Dh

draw_mid_border_loop:
								mov	byte ptr es:[di],0B0h
								mov	byte ptr es:[di+19h],0Eh
								add	di,50h
								mov	byte ptr es:[di],70h	; 'p'
								mov	byte ptr es:[di+19h],0Dh
								add	di,50h
								loop	draw_mid_border_loop		; Loop if cx > 0

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

draw_right_border_loop:
								mov	byte ptr es:[di],30h	; '0'
								mov	byte ptr es:[di+19h],0Ch
								add	di,50h
								loop	draw_right_border_loop		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		retn

equip_process_loop_4		endp

fill_buffer_2		proc	near
		stosb				; Store al to es:[di]
		mov	al,0FFh
		mov	cx,18h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,ah
		stosb				; Store al to es:[di]
		retn

fill_buffer_2		endp

disp_frame_render:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	ax,0B800h
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,39h

extract2_row_loop:
								mov	byte ptr cs:gvar_frame_timer,0
								push	cx
								mov	ax,cx
								neg	ax
								add	ax,39h
								add	ax,ax
								call	extract_bits_2
								pop	ax
								push	ax
								add	ax,ax
								dec	ax
								call	extract_bits_2

extract2_timer_wait:
														cmp	byte ptr cs:gvar_frame_timer,4
														jb	extract2_timer_wait			; Jump if below
								pop	cx
								loop	extract2_row_loop		; Loop if cx > 0

		pop	ds
		retn

extract_bits_2		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,cs:saved_di
		mov	si,ax
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		pop	ax
		cmp	ax,14h
		jae	extract2_short_row			; Jump if above or =
		mov	cx,2Fh
		jmp	short extract2_blend_entry

extract2_short_row:
		mov	cx,23h
		cmp	ax,17h
		jb	extract2_blend_entry			; Jump if below
		cmp	ax,1Ch
		jb	extract2_partial_row			; Jump if below
		mov	cx,21h

extract2_blend_entry:
		mov	word ptr cs:src_word_d,0

extract2_byte_loop:
								xor	ah,ah			; Zero register
								mov	al,ds:cga_plane3_buf[si]
								mov	cs:src_word_c,ax
								mov	al,byte ptr frame_plane_b_tbl[si]
								mov	cs:src_word_b,ax
								lodsb				; String [si] to al
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosb				; Store al to es:[di]
								loop	extract2_byte_loop		; Loop if cx > 0

		retn

extract2_partial_row:
		mov	cx,21h
		mov	word ptr cs:src_word_d,0

extract2_partial_loop:
								xor	ah,ah			; Zero register
								mov	al,ds:cga_plane3_buf[si]
								mov	cs:src_word_c,ax
								mov	al,byte ptr frame_plane_b_tbl[si]
								mov	cs:src_word_b,ax
								lodsb				; String [si] to al
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosb				; Store al to es:[di]
								loop	extract2_partial_loop		; Loop if cx > 0

		xor	ah,ah			; Zero register
		mov	al,ds:cga_plane3_buf[si]
		mov	cs:src_word_c,ax
		mov	al,byte ptr frame_plane_b_tbl[si]
		mov	cs:src_word_b,ax
		lodsb				; String [si] to al
		mov	cs:src_word_a,ax
		call	equip_process_loop_5
		and	al,0FCh
		and	byte ptr es:[di],3
		or	es:[di],al
		retn

extract_bits_2		endp

		; entry code for disp_frame_render3 (push ds; mov saved_di,di; mov saved_es,es;
		;   mov es,0B800h; mov ds,[saved_es]; mov cx,39h) -- jumps into extract3_row_loop
disp_frame_render3		db	1Eh			; push ds
		db	 89h, 3Eh,0B0h, 4Ah, 8Ch, 06h	; mov [4AB0h],di; mov [...],es
		db	0B2h, 4Ah,0B8h, 00h,0B8h, 8Eh	; ...4AB2h; mov ax,0B800h; mov es,...
		db	0C0h, 2Eh, 8Eh, 1Eh,0B2h, 4Ah	; ...ax; mov ds,[cs:saved_es]
		db	0B9h, 39h, 00h			; mov cx,39h -> extract3_row_loop

extract3_row_loop:
								mov	byte ptr cs:gvar_frame_timer,0
								push	cx
								mov	ax,cx
								neg	ax
								add	ax,39h
								add	ax,ax
								call	extract_bits_3
								pop	ax
								push	ax
								add	ax,ax
								dec	ax
								call	extract_bits_3

extract3_timer_wait:
														cmp	byte ptr cs:gvar_frame_timer,4
														jb	extract3_timer_wait			; Jump if below
								pop	cx
								loop	extract3_row_loop		; Loop if cx > 0

		pop	ds
		retn

extract_bits_3		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,3CDh
		add	ax,cs:saved_di
		mov	si,ax
		add	bl,14h
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		add	di,21h
		pop	ax
		cmp	ax,5Eh
		mov	cx,2Fh
		jnc	extract3_clear_tail			; Jump if carry=0
		mov	cx,7
		mov	word ptr cs:src_word_d,0

extract3_word_loop:
								mov	ax,ds:cga_plane3_buf[si]
								mov	cs:src_word_c,ax
								mov	ax,frame_plane_b_tbl[si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	equip_process_loop_5
								stosw				; Store ax to es:[di]
								loop	extract3_word_loop		; Loop if cx > 0

		mov	cx,21h

extract3_clear_tail:
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn

extract_bits_3		endp

disp_frame_render2:
		push	ax
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	ax,0B800h
		mov	es,ax
		pop	ax
		mov	ah,al
		mov	cx,8

hfill_row_loop:
								stosw				; Store ax to es:[di]
								add	di,1FFEh
								cmp	di,4000h
								jb	hfill_row_wrap			; Jump if below
								add	di,0C050h

hfill_row_wrap:
								loop	hfill_row_loop		; Loop if cx > 0

		retn

disp_hfill_row:
		dec	ax
		mov	cx,100h
		mul	cx			; dx:ax = reg * ax
		add	ax,40FDh
		mov	cs:cga_color_lut,ax
		retn
		; 2-bit color data for frame plane A (used by extract_bits_2/3 alongside frame_plane_b_tbl)

frame_plane_a_tbl:
		db	17 dup (0)
		db	2, 0                                               ; plane_a offset 0x011 (2 bytes)
		db	15 dup (0)
		db	1, 0, 0, 0, 0, 0                                   ; plane_a offset 0x022 (6 bytes)
		db	0, 0, 1                                            ; plane_a offset 0x028 (3 bytes)
		db	8 dup (0)
		db	1, 0, 0, 0, 0, 0                                   ; plane_a offset 0x033 (6 bytes)
		db	0, 0, 1                                            ; plane_a offset 0x039 (3 bytes)
		db	8 dup (0)
		db	3, 3, 3, 3, 0, 3                                   ; plane_a offset 0x044 (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; plane_a offset 0x04A (6 bytes)
		db	0, 0, 0, 0, 3, 3                                   ; plane_a offset 0x050 (6 bytes)
		db	3, 3, 0, 3, 0, 0                                   ; plane_a offset 0x056 (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; plane_a offset 0x05C (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; plane_a offset 0x062 (6 bytes)
		db	0, 3, 0, 0, 3, 3                                   ; plane_a offset 0x068 (6 bytes)
		db	3, 3, 0, 0, 0, 0                                   ; plane_a offset 0x06E (6 bytes)
		db	3, 3, 3, 3, 0, 3                                   ; plane_a offset 0x074 (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; plane_a offset 0x07A (6 bytes)
		db	0                                                  ; plane_a offset 0x080 (1 bytes)
		db	7 dup (0)
		db	1, 0                                               ; plane_a offset 0x088 (2 bytes)
		db	10 dup (0)
		db	3, 3, 3, 3, 0, 1                                   ; plane_a offset 0x094 (6 bytes)
		db	8 dup (0)
		db	1, 0, 0, 0, 0, 0                                   ; plane_a offset 0x0A2 (6 bytes)
		db	0, 0, 1                                            ; plane_a offset 0x0A8 (3 bytes)
		db	8 dup (0)
		db	1, 0, 0, 0, 0, 0                                   ; plane_a offset 0x0B3 (6 bytes)
		db	0, 0, 1                                            ; plane_a offset 0x0B9 (3 bytes)
		db	8 dup (0)
		db	3, 3, 3, 3, 0, 0                                   ; plane_a offset 0x0C4 (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; plane_a offset 0x0CA (6 bytes)
		db	0, 0, 0, 0, 3, 3                                   ; plane_a offset 0x0D0 (6 bytes)
		db	3, 3, 0, 0, 0, 0                                   ; plane_a offset 0x0D6 (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; plane_a offset 0x0DC (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; plane_a offset 0x0E2 (6 bytes)
		db	0, 0, 0, 0, 3, 3                                   ; plane_a offset 0x0E8 (6 bytes)
		db	3, 3, 0, 0, 0, 0                                   ; plane_a offset 0x0EE (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; plane_a offset 0x0F4 (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; plane_a offset 0x0FA (6 bytes)
		db	0, 0, 0, 0, 0, 1                                   ; plane_a offset 0x100 (6 bytes)
		db	2, 0                                               ; plane_a offset 0x106 (2 bytes)
		db	9 dup (0)
		db	1, 1, 2, 0, 1, 2                                   ; plane_a offset 0x111 (6 bytes)
		db	1, 0                                               ; plane_a offset 0x117 (2 bytes)
		db	8 dup (0)
		db	1, 2, 0, 0, 2, 2                                   ; plane_a offset 0x121 (6 bytes)
		db	2, 0                                               ; plane_a offset 0x127 (2 bytes)
		db	8 dup (0)
		db	2, 0, 2, 0, 1, 2                                   ; plane_a offset 0x131 (6 bytes)
		db	2, 0                                               ; plane_a offset 0x137 (2 bytes)
		db	12 dup (0)
		db	1, 2                                               ; plane_a offset 0x145 (2 bytes)
		db	9 dup (0)
		db	1, 1, 2, 1, 1, 1                                   ; plane_a offset 0x150 (6 bytes)
		db	1, 3                                               ; plane_a offset 0x156 (2 bytes)
		db	8 dup (0)
		db	2, 1, 2, 2, 2, 1                                   ; plane_a offset 0x160 (6 bytes)
		db	3, 3                                               ; plane_a offset 0x166 (2 bytes)
		db	9 dup (0)
		db	1, 2, 2, 0, 3, 3                                   ; plane_a offset 0x171 (6 bytes)
		db	3, 0                                               ; plane_a offset 0x177 (2 bytes)
		db	32 dup (0)
		db	3, 0                                               ; plane_a offset 0x199 (2 bytes)
		db	15 dup (0)
		db	2, 0                                               ; plane_a offset 0x1AA (2 bytes)
		db	15 dup (0)
		db	2, 0                                               ; plane_a offset 0x1BB (2 bytes)
		db	15 dup (0)
		db	1, 0                                               ; plane_a offset 0x1CC (2 bytes)
		db	15 dup (0)
		db	1, 0                                               ; plane_a offset 0x1DD (2 bytes)
		db	15 dup (0)
		db	3, 0                                               ; plane_a offset 0x1EE (2 bytes)
		db	15 dup (0)
		db	3, 0, 0, 0, 1, 0                                   ; plane_a offset 0x1FF (6 bytes)
		db	1, 0, 1, 0                                         ; plane_a offset 0x205 (4 bytes)
		db	8 dup (0)
		db	2, 1, 2, 1, 2, 0                                   ; plane_a offset 0x211 (6 bytes)
		db	2, 0                                               ; plane_a offset 0x217 (2 bytes)
		db	8 dup (0)
		db	1, 1, 3, 1, 3, 0                                   ; plane_a offset 0x221 (6 bytes)
		db	3, 0                                               ; plane_a offset 0x227 (2 bytes)
		db	7 dup (0)
		db	1, 2, 3, 3, 3, 3                                   ; plane_a offset 0x230 (6 bytes)
		db	0, 3                                               ; plane_a offset 0x236 (2 bytes)
		db	9 dup (0)
		db	1, 1, 3, 1, 3, 0                                   ; plane_a offset 0x241 (6 bytes)
		db	3, 0                                               ; plane_a offset 0x247 (2 bytes)
		db	7 dup (0)
		db	1, 2, 3, 3, 3, 3                                   ; plane_a offset 0x250 (6 bytes)
		db	0, 3                                               ; plane_a offset 0x256 (2 bytes)
		db	15 dup (0)
		db	1, 0                                               ; plane_a offset 0x267 (2 bytes)
		db	7 dup (0)
		db	1, 2, 3, 3, 3, 3                                   ; plane_a offset 0x270 (6 bytes)
		db	1, 3                                               ; plane_a offset 0x276 (2 bytes)
		db	33 dup (0)
		db	3, 0                                               ; plane_a offset 0x299 (2 bytes)
		db	15 dup (0)
		db	2, 0                                               ; plane_a offset 0x2AA (2 bytes)
		db	15 dup (0)
		db	2, 0                                               ; plane_a offset 0x2BB (2 bytes)
		db	15 dup (0)
		db	1, 0                                               ; plane_a offset 0x2CC (2 bytes)
		db	15 dup (0)
		db	1, 0                                               ; plane_a offset 0x2DD (2 bytes)
		db	15 dup (0)
		db	2, 0                                               ; plane_a offset 0x2EE (2 bytes)
		db	15 dup (0)
		db	3, 0, 0, 0, 2, 1                                   ; plane_a offset 0x2FF (6 bytes)
		db	1, 2, 3, 0, 1, 2                                   ; plane_a offset 0x305 (6 bytes)
		db	2, 1, 1, 2, 3, 0                                   ; plane_a offset 0x30B (6 bytes)
		db	1, 2, 2, 1, 1, 1                                   ; plane_a offset 0x311 (6 bytes)
		db	1, 0, 1, 2, 2, 1                                   ; plane_a offset 0x317 (6 bytes)
		db	1, 1, 1, 0, 2, 2                                   ; plane_a offset 0x31D (6 bytes)
		db	2, 1, 1, 2, 3, 0                                   ; plane_a offset 0x323 (6 bytes)
		db	2, 2, 2, 1, 1, 2                                   ; plane_a offset 0x329 (6 bytes)
		db	3, 2, 2, 2, 2, 1                                   ; plane_a offset 0x32F (6 bytes)
		db	1, 2, 2, 0, 2, 2                                   ; plane_a offset 0x335 (6 bytes)
		db	1, 1, 2, 2, 3, 1                                   ; plane_a offset 0x33B (6 bytes)
		db	1, 1, 1, 1, 1, 3                                   ; plane_a offset 0x341 (6 bytes)
		db	3, 1, 1, 1, 1, 1                                   ; plane_a offset 0x347 (6 bytes)
		db	1, 3, 3, 1, 1, 1                                   ; plane_a offset 0x34D (6 bytes)
		db	1, 1, 1, 3, 3, 1                                   ; plane_a offset 0x353 (6 bytes)
		db	1, 1, 1, 1, 1, 3                                   ; plane_a offset 0x359 (6 bytes)
		db	3, 2, 1, 2, 2, 3                                   ; plane_a offset 0x35F (6 bytes)
		db	3, 3, 3, 2, 2, 2                                   ; plane_a offset 0x365 (6 bytes)
		db	2, 3, 3, 3, 3, 3                                   ; plane_a offset 0x36B (6 bytes)
		db	1, 3, 2, 3, 3, 3                                   ; plane_a offset 0x371 (6 bytes)
		db	3, 3, 1, 2, 2, 3                                   ; plane_a offset 0x377 (6 bytes)
		db	3, 3, 3, 0, 0, 0                                   ; plane_a offset 0x37D (6 bytes)
		db	0, 1, 1, 2, 3, 0                                   ; plane_a offset 0x383 (6 bytes)
		db	0, 0, 2, 1, 1, 2                                   ; plane_a offset 0x389 (6 bytes)
		db	3, 1, 1, 2, 2, 1                                   ; plane_a offset 0x38F (6 bytes)
		db	1, 2, 1, 0, 1, 2                                   ; plane_a offset 0x395 (6 bytes)
		db	2, 1, 1, 1, 1, 2                                   ; plane_a offset 0x39B (6 bytes)
		db	2, 2, 2, 1, 1, 2                                   ; plane_a offset 0x3A1 (6 bytes)
		db	2, 0, 2, 2, 2, 1                                   ; plane_a offset 0x3A7 (6 bytes)
		db	1, 2, 3, 2, 2, 2                                   ; plane_a offset 0x3AD (6 bytes)
		db	1, 1, 1, 2, 2, 2                                   ; plane_a offset 0x3B3 (6 bytes)
		db	2, 2, 2, 1, 1, 2                                   ; plane_a offset 0x3B9 (6 bytes)
		db	2, 1, 1, 1, 1, 1                                   ; plane_a offset 0x3BF (6 bytes)
		db	1, 3, 3, 1, 1, 1                                   ; plane_a offset 0x3C5 (6 bytes)
		db	1, 1, 1, 3, 3, 1                                   ; plane_a offset 0x3CB (6 bytes)
		db	1, 1, 2, 1, 1, 3                                   ; plane_a offset 0x3D1 (6 bytes)
		db	3, 1, 1, 1, 1, 1                                   ; plane_a offset 0x3D7 (6 bytes)
		db	1, 3, 3, 2, 1, 2                                   ; plane_a offset 0x3DD (6 bytes)
		db	2, 3, 3, 3, 3, 2                                   ; plane_a offset 0x3E3 (6 bytes)
		db	1, 2, 2, 3                                         ; plane_a offset 0x3E9 (4 bytes)
frame_plane_b_tbl		dw	303h			; 2-bit color data for frame plane B (used by extract_bits_2/3)
		db	3, 3, 1                                            ; plane_b offset 0x000 (3 bytes)
		db	7 dup (3)
		db	1, 3, 2, 3, 3, 3                                   ; plane_b offset 0x00A (6 bytes)
		db	3, 0, 0, 0, 1, 1                                   ; plane_b offset 0x010 (6 bytes)
		db	1, 2, 3, 0, 1, 2                                   ; plane_b offset 0x016 (6 bytes)
		db	2, 1, 1, 2, 3, 0                                   ; plane_b offset 0x01C (6 bytes)
		db	1, 2, 3, 1, 1, 1                                   ; plane_b offset 0x022 (6 bytes)
		db	1, 0, 1, 2, 2, 1                                   ; plane_b offset 0x028 (6 bytes)
		db	1, 1, 1, 0, 2, 2                                   ; plane_b offset 0x02E (6 bytes)
		db	3, 1, 1, 2, 3, 0                                   ; plane_b offset 0x034 (6 bytes)
		db	2, 2, 2, 1, 1, 2                                   ; plane_b offset 0x03A (6 bytes)
		db	3, 1                                               ; plane_b offset 0x040 (2 bytes)
		db	7 dup (3)
		db	0, 3, 3, 3, 3, 3                                   ; plane_b offset 0x049 (6 bytes)
		db	3, 3, 1, 1, 1, 3                                   ; plane_b offset 0x04F (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; plane_b offset 0x055 (6 bytes)
		db	1, 1, 1, 1, 3, 3                                   ; plane_b offset 0x05B (6 bytes)
		db	1, 1, 1, 3, 1, 1                                   ; plane_b offset 0x061 (6 bytes)
		db	3, 3, 1, 1, 1, 1                                   ; plane_b offset 0x067 (6 bytes)
		db	1, 1, 3, 3, 2, 1                                   ; plane_b offset 0x06D (6 bytes)
		db	2, 3, 3, 3, 3, 3                                   ; plane_b offset 0x073 (6 bytes)
		db	2, 2, 2, 2, 3, 3                                   ; plane_b offset 0x079 (6 bytes)
		db	3, 3, 3, 1                                         ; plane_b offset 0x07F (4 bytes)
		db	7 dup (3)
		db	1, 2, 2, 3, 3, 3                                   ; plane_b offset 0x08A (6 bytes)
		db	3, 0, 0, 0, 0, 1                                   ; plane_b offset 0x090 (6 bytes)
		db	1, 2, 3, 0, 0, 0                                   ; plane_b offset 0x096 (6 bytes)
		db	2, 1, 1, 2, 3, 1                                   ; plane_b offset 0x09C (6 bytes)
		db	1, 2, 3, 1, 1, 2                                   ; plane_b offset 0x0A2 (6 bytes)
		db	1, 0, 1, 2, 2, 1                                   ; plane_b offset 0x0A8 (6 bytes)
		db	1, 1, 1, 2, 2, 2                                   ; plane_b offset 0x0AE (6 bytes)
		db	3, 1, 1, 2, 2, 0                                   ; plane_b offset 0x0B4 (6 bytes)
		db	2, 2, 2, 1, 1, 2                                   ; plane_b offset 0x0BA (6 bytes)
		db	3, 2, 2, 2, 3, 1                                   ; plane_b offset 0x0C0 (6 bytes)
		db	1, 2, 2, 2, 2, 2                                   ; plane_b offset 0x0C6 (6 bytes)
		db	2, 1, 1, 2, 2, 1                                   ; plane_b offset 0x0CC (6 bytes)
		db	1, 1, 3, 1, 1, 3                                   ; plane_b offset 0x0D2 (6 bytes)
		db	3, 1, 1, 1, 1, 1                                   ; plane_b offset 0x0D8 (6 bytes)
		db	1, 3, 3, 1, 1, 1                                   ; plane_b offset 0x0DE (6 bytes)
		db	3, 1, 1, 3, 3, 1                                   ; plane_b offset 0x0E4 (6 bytes)
		db	1, 1, 1, 1, 1, 3                                   ; plane_b offset 0x0EA (6 bytes)
		db	3, 2, 1, 2, 3, 3                                   ; plane_b offset 0x0F0 (6 bytes)
		db	3, 3, 3, 2, 1, 2                                   ; plane_b offset 0x0F6 (6 bytes)
		db	2, 3, 3, 3, 3, 3                                   ; plane_b offset 0x0FC (6 bytes)
		db	1, 3, 3, 3, 3, 3                                   ; plane_b offset 0x102 (6 bytes)
		db	3, 3, 1, 3, 2, 3                                   ; plane_b offset 0x108 (6 bytes)
		db	3, 3, 3, 0, 0, 0                                   ; plane_b offset 0x10E (6 bytes)
		db	0, 0, 1, 2, 3, 0                                   ; plane_b offset 0x114 (6 bytes)
		db	1, 2, 2, 1, 1, 2                                   ; plane_b offset 0x11A (6 bytes)
		db	3, 0, 1, 2, 2, 0                                   ; plane_b offset 0x120 (6 bytes)
		db	1, 1, 1, 0, 1, 2                                   ; plane_b offset 0x126 (6 bytes)
		db	2, 1, 1, 1, 1, 0                                   ; plane_b offset 0x12C (6 bytes)
		db	2, 2, 2, 0, 2, 2                                   ; plane_b offset 0x132 (6 bytes)
		db	3, 0, 2, 2, 2, 1                                   ; plane_b offset 0x138 (6 bytes)
		db	1, 2, 3, 0, 2, 2                                   ; plane_b offset 0x13E (6 bytes)
		db	2, 0, 2, 3, 3, 0                                   ; plane_b offset 0x144 (6 bytes)
		db	3, 3, 3, 3, 3, 3                                   ; plane_b offset 0x14A (6 bytes)
		db	3, 0, 0, 0, 0, 0                                   ; plane_b offset 0x150 (6 bytes)
		db	0, 2, 0, 1, 1, 1                                   ; plane_b offset 0x156 (6 bytes)
		db	1, 1, 1, 3, 3, 1                                   ; plane_b offset 0x15C (6 bytes)
		db	1, 2, 2, 0, 3, 3                                   ; plane_b offset 0x162 (6 bytes)
		db	3, 1, 1, 1, 1, 1                                   ; plane_b offset 0x168 (6 bytes)
		db	1, 3, 3, 2, 1, 2                                   ; plane_b offset 0x16E (6 bytes)
		db	3, 2, 3, 3, 3, 2                                   ; plane_b offset 0x174 (6 bytes)
		db	2, 2, 2, 3, 3, 3                                   ; plane_b offset 0x17A (6 bytes)
		db	3, 3, 1, 3, 3, 0                                   ; plane_b offset 0x180 (6 bytes)
		db	3, 3, 3, 3, 1, 2                                   ; plane_b offset 0x186 (6 bytes)
		db	2, 3, 3, 3, 3, 0                                   ; plane_b offset 0x18C (6 bytes)
		db	0, 0, 0, 1, 1, 2                                   ; plane_b offset 0x192 (6 bytes)
		db	3, 0, 0, 0, 2, 1                                   ; plane_b offset 0x198 (6 bytes)
		db	1, 2, 3, 1, 1, 2                                   ; plane_b offset 0x19E (6 bytes)
		db	3, 1, 1, 2, 1, 0                                   ; plane_b offset 0x1A4 (6 bytes)
		db	1, 2, 2, 1, 1, 1                                   ; plane_b offset 0x1AA (6 bytes)
		db	1, 2, 2, 2, 3, 1                                   ; plane_b offset 0x1B0 (6 bytes)
		db	1, 2, 2, 0, 2, 2                                   ; plane_b offset 0x1B6 (6 bytes)
		db	2, 1, 1, 2, 3, 2                                   ; plane_b offset 0x1BC (6 bytes)
		db	2, 2, 3, 1, 1, 2                                   ; plane_b offset 0x1C2 (6 bytes)
		db	2, 2, 2, 2, 2, 1                                   ; plane_b offset 0x1C8 (6 bytes)
		db	1, 2, 2, 1, 1, 1                                   ; plane_b offset 0x1CE (6 bytes)
		db	3, 1, 1, 3, 3, 1                                   ; plane_b offset 0x1D4 (6 bytes)
		db	1, 1, 1, 1, 1, 3                                   ; plane_b offset 0x1DA (6 bytes)
		db	3, 1, 1, 1, 3, 1                                   ; plane_b offset 0x1E0 (6 bytes)
		db	1, 3, 3, 1, 1, 1                                   ; plane_b offset 0x1E6 (6 bytes)
		db	1, 1, 1, 3, 3, 2                                   ; plane_b offset 0x1EC (6 bytes)
		db	1, 2, 3, 3, 3, 3                                   ; plane_b offset 0x1F2 (6 bytes)
		db	3, 2, 1, 2, 2, 3                                   ; plane_b offset 0x1F8 (6 bytes)
		db	3, 3, 3, 3, 1, 3                                   ; plane_b offset 0x1FE (6 bytes)
		db	3, 3, 3, 3, 3, 3                                   ; plane_b offset 0x204 (6 bytes)
		db	1, 3, 2, 3, 3, 3                                   ; plane_b offset 0x20A (6 bytes)
		db	3, 0, 1, 0, 0, 1                                   ; plane_b offset 0x210 (6 bytes)
		db	1, 2, 1, 0, 1, 2                                   ; plane_b offset 0x216 (6 bytes)
		db	2, 1, 1, 2, 3, 1                                   ; plane_b offset 0x21C (6 bytes)
		db	1, 2, 2, 1, 1, 1                                   ; plane_b offset 0x222 (6 bytes)
		db	1, 0, 1, 2, 2, 1                                   ; plane_b offset 0x228 (6 bytes)
		db	1, 1, 1, 0                                         ; plane_b offset 0x22E (4 bytes)
		db	7 dup (2)
		db	0, 2, 2, 2, 1, 1                                   ; plane_b offset 0x239 (6 bytes)
		db	2, 3, 0, 2, 2, 2                                   ; plane_b offset 0x23F (6 bytes)
		db	2, 2, 3, 2, 0, 3                                   ; plane_b offset 0x245 (6 bytes)
		db	3, 3, 3, 3, 3, 3                                   ; plane_b offset 0x24B (6 bytes)
		db	1, 1, 2, 2, 1, 1                                   ; plane_b offset 0x251 (6 bytes)
		db	2, 3, 1, 1, 1, 1                                   ; plane_b offset 0x257 (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; plane_b offset 0x25D (6 bytes)
		db	2, 2, 1, 3, 3, 1                                   ; plane_b offset 0x263 (6 bytes)
		db	1, 1, 1, 1, 1, 1                                   ; plane_b offset 0x269 (6 bytes)
		db	3, 3, 2, 1, 2, 3                                   ; plane_b offset 0x26F (6 bytes)
		db	2, 3, 3, 3, 2, 2                                   ; plane_b offset 0x275 (6 bytes)
		db	2, 2, 3, 3, 3, 3                                   ; plane_b offset 0x27B (6 bytes)
		db	1, 1, 2, 2, 3, 1                                   ; plane_b offset 0x281 (6 bytes)
		db	3, 3, 3, 1, 2, 2                                   ; plane_b offset 0x287 (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; plane_b offset 0x28D (6 bytes)
		db	0, 0, 1, 1, 2, 3                                   ; plane_b offset 0x293 (6 bytes)
		db	0, 0, 0, 2, 1, 1                                   ; plane_b offset 0x299 (6 bytes)
		db	2, 3, 1, 1, 2, 3                                   ; plane_b offset 0x29F (6 bytes)
		db	1, 1, 2, 1, 0, 1                                   ; plane_b offset 0x2A5 (6 bytes)
		db	2, 2, 1, 1, 1, 1                                   ; plane_b offset 0x2AB (6 bytes)
		db	2, 2, 2, 3, 1, 1                                   ; plane_b offset 0x2B1 (6 bytes)
		db	2, 2, 0, 2, 2, 2                                   ; plane_b offset 0x2B7 (6 bytes)
		db	1, 1, 2, 3, 2, 2                                   ; plane_b offset 0x2BD (6 bytes)
		db	2, 3, 1, 1, 2, 2                                   ; plane_b offset 0x2C3 (6 bytes)
		db	2, 2, 2, 2, 1, 1                                   ; plane_b offset 0x2C9 (6 bytes)
		db	2, 2, 1, 1, 1, 3                                   ; plane_b offset 0x2CF (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; plane_b offset 0x2D5 (6 bytes)
		db	1, 1, 1, 1, 3, 3                                   ; plane_b offset 0x2DB (6 bytes)
		db	1, 1, 1, 3, 1, 1                                   ; plane_b offset 0x2E1 (6 bytes)
		db	3, 3, 1, 1, 1, 1                                   ; plane_b offset 0x2E7 (6 bytes)
		db	1, 1, 3, 3, 2, 1                                   ; plane_b offset 0x2ED (6 bytes)
		db	2, 3, 3, 3, 3, 3                                   ; plane_b offset 0x2F3 (6 bytes)
		db	2, 1, 2, 2, 3, 3                                   ; plane_b offset 0x2F9 (6 bytes)
		db	3, 3, 3, 1, 3, 3                                   ; plane_b offset 0x2FF (6 bytes)
		db	3, 3, 3, 3, 3, 1                                   ; plane_b offset 0x305 (6 bytes)
		db	3, 2, 3, 3, 3, 3                                   ; plane_b offset 0x30B (6 bytes)
		db	0, 0, 0, 0, 0, 1                                   ; plane_b offset 0x311 (6 bytes)
		db	2, 3, 0, 1, 2, 2                                   ; plane_b offset 0x317 (6 bytes)
		db	1, 1, 2, 3, 0, 1                                   ; plane_b offset 0x31D (6 bytes)
		db	2, 1, 0, 1, 1, 1                                   ; plane_b offset 0x323 (6 bytes)
		db	0, 1, 2, 2, 1, 1                                   ; plane_b offset 0x329 (6 bytes)
		db	1, 1, 0, 2, 2, 1                                   ; plane_b offset 0x32F (6 bytes)
		db	0, 2, 2, 3, 0, 2                                   ; plane_b offset 0x335 (6 bytes)
		db	2, 2, 1, 1, 2, 3                                   ; plane_b offset 0x33B (6 bytes)
		db	0, 1, 1, 1, 0, 1                                   ; plane_b offset 0x341 (6 bytes)
		db	2, 3, 0, 3, 3, 3                                   ; plane_b offset 0x347 (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; plane_b offset 0x34D (6 bytes)
		db	0, 0, 0, 0, 2, 0                                   ; plane_b offset 0x353 (6 bytes)
		db	1, 1, 1, 1, 1, 1                                   ; plane_b offset 0x359 (6 bytes)
		db	3, 3, 1, 1, 2, 1                                   ; plane_b offset 0x35F (6 bytes)
		db	0, 3, 3, 3, 1, 1                                   ; plane_b offset 0x365 (6 bytes)
		db	1, 1, 1, 1, 3, 3                                   ; plane_b offset 0x36B (6 bytes)
		db	2, 1, 2, 2, 2, 3                                   ; plane_b offset 0x371 (6 bytes)
		db	3, 3, 2, 2, 2, 2                                   ; plane_b offset 0x377 (6 bytes)
		db	3, 3, 3, 3, 3, 1                                   ; plane_b offset 0x37D (6 bytes)
		db	3, 3, 0, 3, 3, 3                                   ; plane_b offset 0x383 (6 bytes)
		db	3, 1, 2, 2, 3, 3                                   ; plane_b offset 0x389 (6 bytes)
		db	3, 3, 0, 0, 0, 0                                   ; plane_b offset 0x38F (6 bytes)
		db	1, 1, 2, 3, 0, 0                                   ; plane_b offset 0x395 (6 bytes)
		db	0, 2, 1, 1, 2, 3                                   ; plane_b offset 0x39B (6 bytes)
		db	1, 1, 2, 3, 1, 1                                   ; plane_b offset 0x3A1 (6 bytes)
		db	2, 1, 0, 1, 2, 2                                   ; plane_b offset 0x3A7 (6 bytes)
		db	1, 1, 1, 1, 2, 2                                   ; plane_b offset 0x3AD (6 bytes)
		db	2, 3, 1, 1, 2, 2                                   ; plane_b offset 0x3B3 (6 bytes)
		db	0, 2, 2, 2, 1, 1                                   ; plane_b offset 0x3B9 (6 bytes)
		db	2, 3, 2, 2, 2, 3                                   ; plane_b offset 0x3BF (6 bytes)
		db	1, 1, 2, 2, 2, 2                                   ; plane_b offset 0x3C5 (6 bytes)
		db	2, 2, 1, 1, 2, 2                                   ; plane_b offset 0x3CB (6 bytes)
		db	1, 1, 1, 3, 1, 1                                   ; plane_b offset 0x3D1 (6 bytes)
		db	3, 3, 1, 1, 1, 1                                   ; plane_b offset 0x3D7 (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; plane_b offset 0x3DD (6 bytes)
		db	1, 3, 1, 1, 3, 3                                   ; plane_b offset 0x3E3 (6 bytes)
		db	1, 1, 1, 1, 1, 1                                   ; plane_b offset 0x3E9 (6 bytes)
		db	3, 3, 2, 1, 2, 3                                   ; plane_b offset 0x3EF (6 bytes)
		db	3, 3, 3, 3, 2, 1                                   ; plane_b offset 0x3F5 (6 bytes)
		db	2, 2, 3, 3, 3, 3                                   ; plane_b offset 0x3FB (6 bytes)
		db	3, 1, 3, 3, 3, 3                                   ; plane_b offset 0x401 (6 bytes)
		db	3, 3, 3, 1, 3, 2                                   ; plane_b offset 0x407 (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; plane_b offset 0x40D (6 bytes)
		db	0, 1, 1, 1, 2, 3                                   ; plane_b offset 0x413 (6 bytes)
		db	0, 1, 2, 2, 1, 1                                   ; plane_b offset 0x419 (6 bytes)
		db	2, 3, 0, 1, 2, 2                                   ; plane_b offset 0x41F (6 bytes)
		db	1, 1, 1, 1, 0, 1                                   ; plane_b offset 0x425 (6 bytes)
		db	2, 2, 1, 1, 1, 1                                   ; plane_b offset 0x42B (6 bytes)
		db	0, 2, 2, 2, 1, 1                                   ; plane_b offset 0x431 (6 bytes)
		db	2, 3, 0, 2, 2, 2                                   ; plane_b offset 0x437 (6 bytes)
		db	1, 1, 2, 3, 1                                      ; plane_b offset 0x43D (5 bytes)
		db	7 dup (2)
		db	0, 2, 2, 2, 2, 2                                   ; plane_b offset 0x449 (6 bytes)
		db	2, 2, 1, 1, 1, 2                                   ; plane_b offset 0x44F (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; plane_b offset 0x455 (6 bytes)
		db	1, 1, 1, 1, 3, 3                                   ; plane_b offset 0x45B (6 bytes)
		db	1, 1, 1, 2, 1, 1                                   ; plane_b offset 0x461 (6 bytes)
		db	2, 2, 1, 1, 1, 1                                   ; plane_b offset 0x467 (6 bytes)
		db	1, 1, 2, 2, 2, 1                                   ; plane_b offset 0x46D (6 bytes)
		db	2, 2, 3, 2, 3, 3                                   ; plane_b offset 0x473 (6 bytes)
		db	2, 2, 2, 2, 3, 3                                   ; plane_b offset 0x479 (6 bytes)
		db	3, 3, 3, 1, 3, 2                                   ; plane_b offset 0x47F (6 bytes)
		db	3, 2, 3, 3, 3, 1                                   ; plane_b offset 0x485 (6 bytes)
		db	2, 2, 3, 3, 3, 3                                   ; plane_b offset 0x48B (6 bytes)
		db	0, 0, 0, 0, 1, 1                                   ; plane_b offset 0x491 (6 bytes)
		db	2, 3, 0, 0, 0, 2                                   ; plane_b offset 0x497 (6 bytes)
		db	1, 1, 2, 3, 1, 1                                   ; plane_b offset 0x49D (6 bytes)
		db	2, 3, 1, 1, 2, 1                                   ; plane_b offset 0x4A3 (6 bytes)
		db	0, 1, 2, 2, 1, 1                                   ; plane_b offset 0x4A9 (6 bytes)
		db	1, 1, 2, 2, 2, 3                                   ; plane_b offset 0x4AF (6 bytes)
		db	1, 1, 2, 2, 0, 2                                   ; plane_b offset 0x4B5 (6 bytes)
		db	2, 2, 1, 1, 2, 3                                   ; plane_b offset 0x4BB (6 bytes)
		db	2, 2, 2, 3, 1, 1                                   ; plane_b offset 0x4C1 (6 bytes)
		db	2, 2, 2, 2, 2, 2                                   ; plane_b offset 0x4C7 (6 bytes)
		db	1, 1, 2, 2, 1, 1                                   ; plane_b offset 0x4CD (6 bytes)
		db	1, 3, 1, 1, 3, 3                                   ; plane_b offset 0x4D3 (6 bytes)
		db	1, 1, 1, 1, 1, 1                                   ; plane_b offset 0x4D9 (6 bytes)
		db	3, 3, 1, 1, 1, 3                                   ; plane_b offset 0x4DF (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; plane_b offset 0x4E5 (6 bytes)
		db	1, 1, 1, 1, 3, 3                                   ; plane_b offset 0x4EB (6 bytes)
		db	2, 1, 2, 3, 3, 2                                   ; plane_b offset 0x4F1 (6 bytes)
		db	3, 3, 2, 1, 2, 2                                   ; plane_b offset 0x4F7 (6 bytes)
		db	3, 3, 3, 3, 3, 1                                   ; plane_b offset 0x4FD (6 bytes)
		db	3, 3, 3, 2, 3, 3                                   ; plane_b offset 0x503 (6 bytes)
		db	3, 1, 3, 2, 3, 3                                   ; plane_b offset 0x509 (6 bytes)
		db	3, 3                                               ; plane_b offset 0x50F (2 bytes)

equip_process_loop_5		proc	near
		push	cx
		push	si
		mov	si,cs:cga_color_lut
		mov	cx,8

color_mix_bit_loop:
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
								or	al,cs:[bx+si]
								loop	color_mix_bit_loop		; Loop if cx > 0

		pop	si
		pop	cx
		retn

equip_process_loop_5		endp

disp_screen_capture:
		push	ds
		mov	ax,0B800h
		mov	ds,ax
		xor	si,si			; Zero register
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,cga_buf_start
		mov	cx,0C8h

vga_cap_row_loop:
								push	cx
								push	si
								mov	cx,28h
								rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
								pop	si
								add	si,2000h
								cmp	si,4000h
								jb	vga_cap_row_wrap			; Jump if below
								add	si,0C050h

vga_cap_row_wrap:
								pop	cx
								loop	vga_cap_row_loop		; Loop if cx > 0

		pop	ds
		xor	ax,ax			; Zero register
		mov	di,cga_work_buf
		mov	cx,2000h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

disp_palette_xlat:
		push	bx
		mov	bl,ah
		xor	bh,bh			; Zero register
		mov	ah,cs:cga_palette_xlat[bx]
		pop	bx
		jmp	word ptr cs:cga_dispatch_fn
		db	 00h, 05h, 02h, 07h, 03h, 04h	; cga_palette_xlat[0..5]: 0,5,2,7,3,4
		db	 06h, 01h,0C3h			; cga_palette_xlat[6..7]=6,1; retn (C3h)
		db	888 dup (0)			; trailing zero pad

seg_a		ends

		end	start
