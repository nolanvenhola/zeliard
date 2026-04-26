
PAGE  59,132

;==========================================================================
;
;  IMAGE_CONTROLLER - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr1com.inc

; restored after factoring (consensus value, but not all files agree):
sprite_img_base          equ     97C0h


; The following equates show data references outside the range of the program.

ega_plane2_buf	equ	2050h			;*
mask_tbl_a	equ	32A7h			;*
mask_tbl_b	equ	32AFh			;*
sprite_src_tbl	equ	35ADh			;*
sprite_frame_tbl	equ	35AFh			;*
palette_xlat_tbl	equ	35CDh			;*
move_seq_up	equ	3A6Ch			;*
move_seq_horiz	equ	3B30h			;*
color_pair_tbl_lo	equ	3B63h			;*
color_pair_tbl_hi	equ	3B64h			;*
ega_palette_buf	equ	416Ah			;*
cur_col_ctr	equ	4210h			;*
cur_color	equ	4211h			;*
cur_row_ctr	equ	4212h			;*
plane_enable_flags	equ	4213h			;*
img_stride	equ	4214h			;*
render_fn_ptr	equ	4216h			;*
saved_di	equ	4218h			;*
saved_es	equ	421Ah			;*
text_dest_off	equ	421Ch			;*
sprite_row_buf	equ	453Ch			;*
sprite_row_buf_b	equ	455Eh			;*
scroll_mask_off	equ	39ACh			;* CS offset of scroll_pixel_masks data
font_ptr_a	equ	0F500h			;*
gvar_frame_timer	equ	0FF1Ah			;*
gvar_game_seg	equ	0FF2Ch			;*
sprite_mask_off	equ	1A8Fh			;*
sprite_or_off	equ	1A90h			;*
ega_row_m1	equ	13Fh
ega_row_p1	equ	141h
screen_start_off	equ	504h
move_up_left	equ	0FEBFh
move_up	equ	0FEC0h
move_up_right	equ	0FEC1h
sprite_backbuf_plane_sz equ	1028h		; bytes per plane in sprite back-buffer (at CS+3000h)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

imgctl_module		proc	far

start:
		adc	byte ptr [di],0
		add	[bp+si],dh
		xor	[bp+si+30h],cl
		sahf				; Store ah into flags
;*		xor	dh,bh
		db	 30h,0FEh		;  Fixup - byte match
		xor	[si],dh
		inc	cx
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		inc	dx
		mov	bh,32h			; '2'
		cmc				; Complement carry
		xor	al,[bp+si+33h]
		lodsw				; String [si] to ax
		xor	dx,bp
		xor	ax,3622h
; Dispatch table: 13 word offsets to public entry points of this EGA module
; [0]=ega_setup_mode1 [1]=ega_render_three_planes [2]=ega_setup_mode2 [3]=ega_fill_plane0
; [4]=ega_setup_mode3 [5]=ega_render_planes_cx [6]=imgctl_render_text [7]=imgctl_copy_vga_src
; [8]=imgctl_init_sprites [9]=imgctl_clear_checkerboard [10]=imgctl_render_sprite_cols
; [11]=imgctl_copy_to_buf [12]=imgctl_scroll_snake

dispatch_tbl:
		db	 6Fh, 36h, 26h, 31h, 9Ah, 36h	; [0]=366Fh [1]=3126h [2]=369Ah
		db	 1Ch, 37h, 16h, 38h, 69h, 3Bh	; [3]=371Ch [4]=3816h [5]=3B69h
		db	 7Fh, 3Ch,0A1h, 3Dh,0F7h, 3Dh	; [6]=3C7Fh [7]=3DA1h [8]=3DF7h
		db	0B1h, 3Fh, 75h, 40h, 0Dh, 41h	; [9]=3FB1h [10]=4075h [11]=410Dh
		db	 0Ah, 42h				; [12]=420Ah
; EGA reset: set mode0+data_rotate+bitmask registers then ret

ega_reset_regs:
		db	0BAh,0CEh, 03h,0B8h		; mov dx,3CEh; mov ax,...
		db	 05h, 00h,0EFh,0B8h, 03h, 00h	; ..0005h; out dx,ax; mov ax,0003h
		db	0EFh,0B8h, 08h,0FFh,0EFh,0B8h	; out dx,ax; mov ax,0FF08h; out dx,ax; mov ax,...
		db	 07h, 0Fh,0EFh,0B8h, 02h, 0Fh	; ..0F07h; out dx,ax; mov ax,0F02h
		db	0EFh,0C3h				; out dx,ax; retn
; EGA mode2 setup: write all-planes, set mode5, set render_fn_ptr=3071h, then fade

ega_setup_mode2_a:
		db	 50h,0BAh,0C4h, 03h		; push ax; mov dx,3C4h
		db	0B8h, 02h, 0Fh,0EFh,0BAh,0CEh	; mov ax,0F02h; out dx,ax; mov dx,3CEh
		db	 03h,0B8h, 05h, 02h,0EFh, 2Eh	; ; mov ax,0205h; out dx,ax; CS:
		db	0C7h, 06h, 16h, 42h, 71h, 30h	; mov word[render_fn_ptr],3071h  CS:3071h = mode2a inner row renderer
		db	 58h,0E8h, 5Dh, 01h,0B8h, 03h	; pop ax; call +0x15D; mov ax,3
		db	 00h,0EFh,0B8h, 05h, 00h,0EFh	; out dx,ax; mov ax,5; out dx,ax
		db	0B8h, 08h,0FFh,0EFh,0C3h		; mov ax,0FF08h; out dx,ax; retn
; EGA conditional plane0: test plane_enable_flags, optional write plane0, then 3-plane

ega_render_cond_plane0:
		db	 2Eh,0F6h, 06h, 13h, 42h,0FFh	; test byte[cs:plane_enable_flags],0FFh
		db	 74h, 0Bh, 50h,0B8h, 03h, 00h	; jz +0Bh; push ax; mov ax,3
		db	0EFh, 58h, 32h,0FFh,0E8h,0ECh, 01h	; out dx,ax; pop ax; xor bh,bh; call +0x1EC

ega_render_two_planes:
		push	ax
		mov	ax,1003h
		out	dx,ax			; port 1, DMA-1 bas&cnt ch 0
		pop	ax
		push	si
		mov	bh,1
		call	imgctl_process_loop_2
		pop	si
		push	si
		add	si,cs:img_stride
		mov	bh,8
		call	imgctl_process_loop_2
		pop	si
		retn

ega_setup_mode1:
		push	ax
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	word ptr cs:render_fn_ptr,30C5h	; CS:30C5h = mode1 inner row renderer
		pop	ax
		call	imgctl_multiply
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

ega_render_three_planes:
		test	byte ptr cs:plane_enable_flags,0FFh
		jz	skip_plane0_render			; Jump if zero
		push	ax
		mov	ax,3
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		pop	ax
		xor	bh,bh			; Zero register
		call	imgctl_process_loop

skip_plane0_render:
		push	ax
		mov	ax,1003h
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		pop	ax
		push	si
		mov	bh,1
		call	imgctl_process_loop_2
		pop	si
		push	si
		add	si,cs:img_stride
		push	si
		mov	bh,2
		call	imgctl_process_loop_2
		pop	si
		add	si,cs:img_stride
		mov	bh,4
		call	imgctl_process_loop_2
		pop	si
		retn

ega_setup_mode2:
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	word ptr cs:render_fn_ptr,3121h	; CS:3121h = mode2 inner row renderer
		mov	al,0FFh
		call	imgctl_multiply
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

ega_fill_plane0:
		xor	bh,bh			; Zero register
		jmp	fill_plane_entry

ega_setup_mode3:
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	word ptr cs:render_fn_ptr,314Dh	; CS:314Dh = mode3 inner row renderer
		xor	al,al			; Zero register
		call	imgctl_multiply
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

ega_render_planes_cx:
		push	cx
		push	di
		push	bp
		push	si
		push	ax
		mov	ax,1003h
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		pop	ax
		mov	bp,cs:img_stride
		mov	cl,ch
		xor	ch,ch			; Zero register

pixel_blend_loop:
						push	cx
						push	ax
						lodsb				; String [si] to al
						and	al,ah
						mov	ch,al
						mov	cl,ds:[bp+si-1]
						and	cl,ah
						mov	bh,cl
						and	bh,ch
						mov	bl,cl
						or	bl,ch
						not	bh
						and	ch,bh
						and	cl,bh
						and	bl,ah
						test	byte ptr cs:plane_enable_flags,0FFh
						jz	skip_bg_plane			; Jump if zero
						mov	ax,3
						out	dx,ax			; port 0, DMA-1 bas&add ch 0
						mov	al,8
						out	dx,al			; port 0, DMA-1 bas&add ch 0
						inc	dx
						mov	al,bl
						out	dx,al			; port 1, DMA-1 bas&cnt ch 0
						dec	dx
						xor	al,al			; Zero register
						xchg	es:[di],al
						mov	ax,1003h
						out	dx,ax			; port 0, DMA-1 bas&add ch 0

skip_bg_plane:
						mov	al,8
						out	dx,al			; port 0, DMA-1 bas&add ch 0
						inc	dx
						mov	al,ch
						out	dx,al			; port 1, DMA-1 bas&cnt ch 0
						mov	al,2
						xchg	es:[di],al
						mov	al,cl
						out	dx,al			; port 1, DMA-1 bas&cnt ch 0
						mov	al,4
						xchg	es:[di],al
						mov	al,bl
						out	dx,al			; port 1, DMA-1 bas&cnt ch 0
						mov	al,8
						xchg	es:[di],al
						dec	dx
						inc	di
						pop	ax
						pop	cx
						loop	pixel_blend_loop		; Loop if cx > 0

		pop	si
		pop	bp
		pop	di
		pop	cx
		retn

imgctl_module		endp

imgctl_multiply		proc	near
		push	ds
		push	ax
		push	es
		push	di
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	cs:img_stride,ax
		pop	si
		pop	ds
		pop	ax
		mov	byte ptr cs:plane_enable_flags,0
		or	al,al			; Zero ?
		jnz	do_fg_vga_op			; Jump if not zero
		call	vga_operation

do_fg_vga_op:
		mov	byte ptr cs:plane_enable_flags,0FFh
		call	vga_operation
		pop	ds
		retn

imgctl_multiply		endp

vga_operation		proc	near
		mov	byte ptr cs:cur_color,0
		mov	ax,vga_seg
		mov	es,ax
		mov	bp,8

vga_op_pass_loop:
						mov	al,cs:cur_color
						mov	cs:cur_col_ctr,al
						mov	byte ptr cs:gvar_frame_timer,0
						push	cx
						push	si
						push	di

vga_op_row_loop:
										mov	bl,cs:cur_col_ctr
										and	bx,7
										mov	ah,cs:mask_tbl_a[bx]
										call	word ptr cs:render_fn_ptr
										inc	byte ptr cs:cur_col_ctr
										mov	al,ch
										xor	ah,ah			; Zero register
										add	si,ax
										add	di,50h
										dec	cl
										jz	vga_op_row_done			; Jump if zero
										mov	bl,cs:cur_col_ctr
										and	bx,7
										mov	ah,cs:mask_tbl_b[bx]
										call	word ptr cs:render_fn_ptr
										inc	byte ptr cs:cur_col_ctr
										mov	al,ch
										xor	ah,ah			; Zero register
										add	si,ax
										add	di,50h
										dec	cl
										jnz	vga_op_row_loop			; Jump if not zero

vga_op_row_done:
						pop	di
						pop	si
						pop	cx
						inc	byte ptr cs:cur_color

wait_frame_timer:
										cmp	byte ptr cs:gvar_frame_timer,14h
										jb	wait_frame_timer			; Jump if below
						dec	bp
						jnz	vga_op_pass_loop			; Jump if not zero
		retn

vga_operation		endp

imgctl_process_loop		proc	near

fill_plane_entry:
		push	di
		push	cx
		push	ax
		mov	al,8
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		inc	dx
		mov	al,ah
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
		mov	cl,ch
		xor	ch,ch			; Zero register

fill_plane_loop:
						mov	al,bh
						xchg	es:[di],al
						inc	di
						loop	fill_plane_loop		; Loop if cx > 0

		dec	dx
		pop	ax
		pop	cx
		pop	di
		retn

imgctl_process_loop		endp

imgctl_process_loop_2		proc	near
		push	di
		push	cx
		push	ax
		mov	al,8
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
		inc	dx
		mov	cl,ch
		xor	ch,ch			; Zero register

mask_write_loop:
						lodsb				; String [si] to al
						and	al,ah
						out	dx,al			; port 2, DMA-1 bas&add ch 1
						mov	al,bh
						xchg	es:[di],al
						inc	di
						loop	mask_write_loop		; Loop if cx > 0

		dec	dx
		pop	ax
		pop	cx
		pop	di
		retn

imgctl_process_loop_2		endp

imgctl_render_text:
		and	byte ptr [bx+si],8
		add	al,[bx+si+10h]
		add	al,1
		add	[si],ax
		adc	[bx+si+2],al
		or	[bx+si],ah
		or	byte ptr ds:font_ctrl_byte,1Ch
		inc	dx
		xor	ax,ax			; Zero register
		mov	cx,190h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	di,text_dest_off

char_render_loop:
						lodsb				; String [si] to al
						cmp	al,0FFh
						jne	char_not_end			; Jump if not equal
						retn

char_not_end:
						sub	al,20h			; ' '
						jnc	char_printable			; Jump if carry=0
						retn

char_printable:
						jz	char_advance			; Jump if zero
						push	si
						push	di
						xor	ah,ah			; Zero register
						add	ax,ax
						add	ax,ax
						add	ax,ax
						add	ax,ax
						add	ax,ds:font_ptr_a
						mov	si,ax
						mov	cx,8

char_row_copy_loop:
										movsw				; Mov [si] to es:[di]
										add	di,4Eh
										loop	char_row_copy_loop		; Loop if cx > 0

						pop	di
						pop	si

char_advance:
						add	di,2
						jmp	short char_render_loop

imgctl_copy_vga_src:
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,text_dest_off
		mov	si,ax
		mov	al,bl
		mul	dl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	dx,3C4h
		mov	ax,402h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,204h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		push	si
		push	ds
		mov	ax,vga_seg
		mov	es,ax
		mov	ds,ax
		dec	cl
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

ega_row_copy_loop:
						push	cx
						push	di
						mov	si,di
						add	si,50h
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	di
						add	di,50h
						pop	cx
						loop	ega_row_copy_loop		; Loop if cx > 0

		pop	ds
		pop	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn

sprite_copy_entry:
		push	ds
		push	es
		push	di
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	cs:img_stride,ax
		pop	si
		pop	ds
		call	copy_vga_buffer
		pop	ds
		retn

copy_vga_buffer		proc	near
		mov	ax,vga_seg
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

copy_vga_planes_loop:
						push	cx
						mov	al,1
						out	dx,al			; port 3C5h, EGA sequencr func
						push	si
						push	di
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	di
						pop	si
						mov	al,2
						out	dx,al			; port 3C5h, EGA sequencr func
						push	si
						push	di
						add	si,cs:img_stride
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	di
						pop	si
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						push	si
						push	di
						add	si,cs:img_stride
						add	si,cs:img_stride
						mov	cx,bx
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	di
						pop	si
						pop	cx
						add	di,50h
						add	si,bx
						loop	copy_vga_planes_loop		; Loop if cx > 0

		retn

copy_vga_buffer		endp

imgctl_init_sprites:
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
						add	dx,240h
						loop	sprite_obj_init_loop		; Loop if cx > 0

		mov	byte ptr ds:cur_col_ctr,0
		mov	byte ptr ds:gvar_frame_timer,0

sprite_anim_loop:
		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_process_loop:
		push	cx
		test	byte ptr [si],0FFh
		jnz	sprite_active			; Jump if not zero
		jmp	sprite_skip

sprite_active:
		mov	al,[si+0Dh]
		cmp	al,[si+0Eh]
		je	skip_alt_frame			; Jump if equal
		inc	byte ptr [si+0Ch]
		test	byte ptr [si+0Ch],1
		jnz	skip_alt_frame			; Jump if not zero
		inc	byte ptr [si+0Dh]

skip_alt_frame:
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
		mov	ax,vga_seg
		mov	ds,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	dx,3CEh
		mov	al,4
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		inc	dx
		mov	si,di
		mov	di,bp
		mov	al,0
		out	dx,al			; port 3CFh, EGA graphic func
		call	copy_buffer
		mov	al,1
		out	dx,al			; port 3CFh, EGA graphic func
		call	copy_buffer
		mov	al,2
		out	dx,al			; port 3CFh, EGA graphic func
		call	copy_buffer
		pop	si
		pop	ds

sprite_skip:
		pop	cx
		add	si,0Fh
		loop	sprite_loop_next		; Loop if cx > 0

		jmp	short after_sprite_loop

sprite_loop_next:
		jmp	sprite_process_loop

after_sprite_loop:
		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_blit_loop:
						push	cx
						push	si
						mov	al,ds:cur_col_ctr
						and	al,7
						mov	bx,palette_xlat_tbl
						xlat				; al=[al+[bx]] table
						mov	ds:ega_palette_buf,al
						inc	byte ptr ds:cur_col_ctr
						xor	ax,ax			; Zero register
						call	vga_operation4
						pop	si
						test	byte ptr cs:[si],0FFh
						jz	skip_sprite_blit			; Jump if zero
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
						jae	skip_sprite_blit			; Jump if above or =
						cmp	al,0A0h
						jae	skip_sprite_blit			; Jump if above or =
						mov	[si],dl
						mov	di,[si+5]
						push	ds
						push	si
						mov	ax,vga_seg
						mov	es,ax
						mov	ds,cs:gvar_game_seg
						mov	si,bp
						mov	dx,3C4h
						mov	ax,102h
						out	dx,ax			; port 3C4h, EGA sequencr index
										;  al = 2, map mask register
						mov	dx,3CEh
						mov	ax,4
						out	dx,ax			; port 3CEh, EGA graphic index
										;  al = 4, read map select
						call	imgctl_process_loop_3
						mov	dx,3C4h
						mov	ax,202h
						out	dx,ax			; port 3C4h, EGA sequencr index
										;  al = 2, map mask register
						mov	dx,3CEh
						mov	ax,104h
						out	dx,ax			; port 3CEh, EGA graphic index
										;  al = 4, read map select
						call	imgctl_process_loop_3
						pop	si
						pop	ds

skip_sprite_blit:
						pop	cx
						add	si,0Fh
						loop	sprite_blit_loop		; Loop if cx > 0

wait_sprite_frame:
						cmp	byte ptr cs:gvar_frame_timer,1Eh
						jb	wait_sprite_frame			; Jump if below
		mov	byte ptr cs:gvar_frame_timer,0
		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_backbuf_loop:
						push	cx
						mov	bp,[si+1]
						mov	di,[si+5]
						mov	cx,[si+7]
						push	ds
						push	si
						mov	ax,vga_seg
						mov	es,ax
						mov	ax,cs
						add	ax,3000h
						mov	ds,ax
						mov	si,bp
						mov	dx,3C4h
						mov	al,2
						out	dx,al			; port 3C4h, EGA sequencr index
										;  al = 2, map mask register
						inc	dx
						mov	al,1
						out	dx,al			; port 3C5h, EGA sequencr func
						call	copy_buffer_2
						mov	al,2
						out	dx,al			; port 3C5h, EGA sequencr func
						call	copy_buffer_2
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						call	copy_buffer_2
						pop	si
						pop	ds
						pop	cx
						add	si,0Fh
						loop	sprite_backbuf_loop		; Loop if cx > 0

		mov	si,sprite_obj_tbl
		mov	cx,9

check_all_done_loop:
						test	byte ptr [si],0FFh
						jz	all_sprites_done			; Jump if zero
						jmp	sprite_anim_loop

all_sprites_done:
						add	si,0Fh
						loop	check_all_done_loop		; Loop if cx > 0

		mov	ax,2
		jmp	load_palette_entry

copy_buffer		proc	near
		push	si
		push	cx

copy_buf_row_loop:
						push	si
						push	cx
						mov	cl,ch
						xor	ch,ch			; Zero register
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	cx
						pop	si
						add	si,50h
						dec	cl
						jnz	copy_buf_row_loop			; Jump if not zero
		pop	cx
		pop	si
		retn

copy_buffer		endp

copy_buffer_2		proc	near
		push	di
		push	cx

copy_buf2_row_loop:
						push	di
						push	cx
						mov	cl,ch
						xor	ch,ch			; Zero register
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						pop	cx
						pop	di
						add	di,50h
						dec	cl
						jnz	copy_buf2_row_loop			; Jump if not zero
		pop	cx
		pop	di
		retn

copy_buffer_2		endp

imgctl_process_loop_3		proc	near
		push	di
		push	cx

or_plane_row_loop:
						push	di
						push	cx
						mov	cl,ch
						xor	ch,ch			; Zero register

or_pixels_loop:
										lodsb				; String [si] to al
										or	es:[di],al
										inc	di
										loop	or_pixels_loop		; Loop if cx > 0

						pop	cx
						pop	di
						add	di,50h
						dec	cl
						jnz	or_plane_row_loop			; Jump if not zero
		pop	cx
		pop	di
		retn

imgctl_process_loop_3		endp

; EGA sequencer/CRTC register table: pairs of (count_byte, EGA_reg, row_height)

ega_reg_tbl:
		db	 00h, 90h, 20h, 06h, 80h, 91h
		db	 20h, 06h, 00h, 93h, 20h, 06h
		db	 80h, 94h, 20h, 06h, 00h, 96h
		db	 18h, 04h,0C0h, 96h, 18h, 04h
		db	 80h, 97h, 18h, 04h, 40h, 98h
		db	 18h, 04h, 36h, 06h, 3Fh, 07h
		db	 2Dh, 05h, 24h, 04h, 1Eh, 32h
; EGA plane copy setup: waits retrace, selects game seg, computes src/dst, writes 2 planes

imgctl_copy_game_planes:
		db	0E4h,0BAh,0C0h, 0Ch,0F7h,0E2h	; in al,3BAh (wait retrace); imul dx; loop
		db	 05h, 40h,0ABh, 2Eh, 8Eh, 1Eh	; loop+stosw; mov ds,[cs:gvar_game_seg]
		db	 2Ch,0FFh, 8Bh,0F0h,0B8h, 50h	; mov si,ax; mov ax,50h
		db	 00h,0F6h,0E3h, 8Ah,0DFh, 32h	; mul bl; mov bl,bh; xor bh,bh
		db	0FFh, 03h,0C3h, 8Bh,0F8h,0B8h	; add ax,bx; mov di,ax; mov ax,0A000h
		db	 00h,0A0h, 8Eh,0C0h,0BAh,0C4h	; mov es,ax; mov dx,3C4h
		db	 03h,0B0h, 02h,0EEh, 42h,0B0h	; mov al,2; out dx,al; inc dx; mov al,2
		db	 02h,0EEh,0E8h, 08h, 00h,0B0h	; out dx,al; call copy_17w_row_loop+3; mov al,1
		db	 01h,0EEh,0E8h, 02h, 00h, 1Fh	; out dx,al; call copy_17w_row_loop+3; pop ds
		db	0C3h			; retn
; Entry: push di; mov cx,30h then fall into copy_17w_row_loop
		db	 57h,0B9h, 30h, 00h

copy_17w_row_loop:
						push	di
						push	cx
						mov	cx,11h
						rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
						pop	cx
						pop	di
						add	di,50h
						loop	copy_17w_row_loop		; Loop if cx > 0

		pop	di
		retn

imgctl_clear_checkerboard:
		push	ds
		xor	ah,ah			; Zero register
		mov	dx,480h
		mul	dx			; dx:ax = reg * ax
		add	ax,sprite_img_base
		mov	ds,cs:gvar_game_seg
		mov	si,ax
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	ax,vga_seg
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		call	copy_buffer_3
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		call	copy_buffer_3
		pop	ds
		retn

copy_buffer_3		proc	near
		push	di
		mov	cx,20h

copy_buf3_row_loop:
						push	di
						push	cx
						mov	cx,9
						rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
						pop	cx
						pop	di
						add	di,50h
						loop	copy_buf3_row_loop		; Loop if cx > 0

		pop	di
		retn

copy_buffer_3		endp

imgctl_render_sprite_cols:
		mov	ax,vga_seg
		mov	es,ax
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		xor	di,di			; Zero register
		mov	bx,2288h		; checkerboard pixel pair: bh=22h (b00100010), bl=88h (b10001000)
		mov	cx,64h

checkerboard_loop:
						push	cx
						mov	al,bh
						mov	ah,bh
						mov	cx,28h
						rep	stosw			; Rep when cx >0 Store ax to es:[di]
						mov	al,bl
						mov	ah,bl
						mov	cx,28h
						rep	stosw			; Rep when cx >0 Store ax to es:[di]
						pop	cx
						loop	checkerboard_loop		; Loop if cx > 0

		retn

imgctl_render_sprite_palette_all:
		xor	bx,bx			; Zero register
		mov	cx,19h

sprite_palette_outer:
						push	cx
						mov	cx,22h

sprite_palette_inner:
										push	cx
										lodsb				; String [si] to al
										push	bx
										push	ds
										push	si
										call	imgctl_multiply_2
										pop	si
										pop	ds
										pop	bx
										inc	bh
										pop	cx
										loop	sprite_palette_inner		; Loop if cx > 0

						xor	bh,bh			; Zero register
						inc	bl
						pop	cx
						loop	sprite_palette_outer		; Loop if cx > 0

		retn

imgctl_multiply_2		proc	near
		mov	ds,cs:gvar_game_seg
		mov	dx,cs
		add	dx,2000h
		mov	es,dx
		xor	ah,ah			; Zero register

div28_loop:
						sub	al,28h			; '('
						jc	div28_done			; Jump if carry Set
						inc	ah
						jmp	short div28_loop

div28_done:
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

three_pass_copy_loop:
						push	cx
						push	di
						push	si
						mov	cx,8

eight_row_copy_loop:
										movsb				; Mov [si] to es:[di]
										add	di,21h
										add	si,27h
										loop	eight_row_copy_loop		; Loop if cx > 0

						pop	si
						pop	di
						add	di,sprite_or_off
						add	si,640h
						pop	cx
						loop	three_pass_copy_loop		; Loop if cx > 0

		retn

imgctl_multiply_2		endp

imgctl_copy_to_buf:
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
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		mov	di,ax
		mov	ax,vga_seg
		mov	es,ax
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		push	si
		push	di
		mov	cx,22h

fwd_blit_loop:
						lodsb				; String [si] to al
						mov	bl,al
						or	al,ds:sprite_mask_off[si]
						out	dx,al			; port 3CFh, EGA graphic func
						xor	al,al			; Zero register
						xchg	es:[di],al
						mov	al,bl
						and	al,ds:sprite_mask_off[si]
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,0Fh
						xchg	es:[di],al
						inc	di
						loop	fwd_blit_loop		; Loop if cx > 0

		pop	di
		pop	si
		dec	dx
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		add	si,sprite_or_off
		push	di
		mov	cx,22h

fwd_blit2_loop:
						lodsb				; String [si] to al
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,0Eh
						xchg	es:[di],al
						inc	di
						loop	fwd_blit2_loop		; Loop if cx > 0

		pop	di
		push	cs
		pop	ds
		add	di,4Fh
		dec	dx
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	si,sprite_row_buf
		push	di
		mov	cx,22h

rev_blit_loop:
						lodsb				; String [si] to al
						mov	bl,al
						or	al,[si+21h]
						out	dx,al			; port 3CFh, EGA graphic func
						xor	al,al			; Zero register
						xchg	es:[di],al
						mov	al,bl
						and	al,[si+21h]
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,0Fh
						xchg	es:[di],al
						dec	di
						loop	rev_blit_loop		; Loop if cx > 0

		pop	di
		dec	dx
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	si,sprite_row_buf_b
		mov	cx,22h

rev_blit2_loop:
						lodsb				; String [si] to al
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,0Eh
						xchg	es:[di],al
						dec	di
						loop	rev_blit2_loop		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	ds
		retn

imgctl_scroll_snake:
		mov	bx,ax
		add	bx,bx
		mov	al,ds:color_pair_tbl_lo[bx]
		mov	ds:cur_color,al
		mov	al,ds:color_pair_tbl_hi[bx]
		mov	ds:cur_col_ctr,al
		mov	ax,vga_seg
		mov	es,ax
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	di,screen_start_off
		mov	si,move_seq_up

move_up_loop:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	move_horiz_start			; Jump if zero
						call	imgctl_func_11
						add	di,140h
						jmp	short move_up_loop

move_horiz_start:
		add	di,move_up_right

move_horiz_loop:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	move_down_start			; Jump if zero
						call	imgctl_func_11
						inc	di
						jmp	short move_horiz_loop

move_down_start:
		add	di,move_up_left

move_down_loop:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	move_left_start			; Jump if zero
						call	imgctl_func_11
						add	di,0FEC0h
						jmp	short move_down_loop

move_left_start:
		add	di,ega_row_m1

move_left_loop:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	move_seq_done			; Jump if zero
						call	imgctl_func_11
						dec	di
						jmp	short move_left_loop

move_seq_done:
		add	di,ega_row_p1
		mov	si,move_seq_horiz

scroll_step_loop:
						mov	byte ptr cs:gvar_frame_timer,0
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	scroll_cleanup_ega			; Jump if zero
						xor	cx,cx			; Zero register
						mov	cl,al

scroll_up_inner:
										push	cx
										mov	al,18h
										call	imgctl_func_11
										add	di,140h
										pop	cx
										loop	scroll_up_inner		; Loop if cx > 0

						add	di,move_up
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	scroll_cleanup_ega			; Jump if zero
						xor	cx,cx			; Zero register
						mov	cl,al

scroll_right_inner:
										push	cx
										mov	al,18h
										call	imgctl_func_11
										inc	di
										pop	cx
										loop	scroll_right_inner		; Loop if cx > 0

						dec	di
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	scroll_cleanup_ega			; Jump if zero
						xor	cx,cx			; Zero register
						mov	cl,al

scroll_down_inner:
										push	cx
										mov	al,18h
										call	imgctl_func_11
										add	di,0FEC0h
										pop	cx
										loop	scroll_down_inner		; Loop if cx > 0

						add	di,ega_row_w
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	scroll_cleanup_ega			; Jump if zero
						xor	cx,cx			; Zero register
						mov	cl,al

scroll_left_inner:
										push	cx
										mov	al,18h
										call	imgctl_func_11
										dec	di
										pop	cx
										loop	scroll_left_inner		; Loop if cx > 0

						inc	di

wait_scroll_timer:
										cmp	byte ptr cs:gvar_frame_timer,0Ch
										jb	wait_scroll_timer			; Jump if below
						jmp	short scroll_step_loop

scroll_cleanup_ega:
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

imgctl_func_11		proc	near
		push	si
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,scroll_mask_off
		mov	si,ax
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		push	di
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,50h
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,50h
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,50h
		xor	al,al			; Zero register
		xchg	es:[di],al
		pop	di
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		push	di
		mov	ah,cs:cur_col_ctr
		ror	ah,1			; Rotate
		lodsb				; String [si] to al
		and	al,cs:cur_col_ctr
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:cur_color
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		and	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:cur_color
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		and	al,cs:cur_col_ctr
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:cur_color
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		and	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:cur_color
		xchg	es:[di],al
		pop	di
		push	di
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,6
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,6
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,6
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,6
		xchg	es:[di],al
		pop	di
		dec	dx
		pop	si
		retn

imgctl_func_11		endp

; EGA bit-mask data for scroll animation (8 entries ?? 8 bytes = pixel-column masks, 2 planes)

scroll_pixel_masks:
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
; EGA palette sequence index tables: pairs (EGA_reg_index, palette_value) for fade

ega_palette_seq_tbl:
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
; Color fade setup: al=plane_flags, cx=render_fn, ch=rows, cl=cols

imgctl_color_fade_setup:
		db	 02h, 55h, 03h,0FFh, 01h, 55h	; header bytes (param tag)
		db	 1Eh, 2Eh,0A2h, 13h, 42h, 81h	; push ds; mov[cs:plane_enable_flags],al; sub bx
		db	0EBh, 10h, 04h, 2Eh,0C6h, 06h	; sub bx,0410h; mov byte[cs:cur_color],0
		db	 11h, 42h, 00h, 2Eh,0C6h, 06h	; (cont); mov byte[cs:cur_row_ctr],0
		db	 12h, 42h, 00h, 2Eh, 89h, 0Eh	; (cont); mov [cs:render_fn_ptr],cx
		db	 16h, 42h, 8Ah,0C5h,0F6h,0E1h	; (cont); mov al,ch; mul cl
		db	 2Eh,0A3h, 14h, 42h, 06h, 1Fh	; mov [cs:img_stride],ax; push es; pop ds
		db	 57h, 5Eh,0B8h, 00h,0A0h, 8Eh	; push di; pop si; mov ax,0A000h; mov es,ax
		db	0C0h,0B9h, 08h, 00h		; (cont); mov cx,8

color_fade_outer:
						push	cx
						mov	al,cs:cur_row_ctr
						mov	cs:cur_color,al
						mov	byte ptr cs:gvar_frame_timer,0
						mov	cx,0Dh

color_fade_col_loop:
										push	cx
										push	bx
										push	si
										call	imgctl_multiply_3
										pop	si
										pop	bx
										pop	cx
										add	byte ptr cs:cur_color,8
										loop	color_fade_col_loop		; Loop if cx > 0

						pop	cx

wait_fade_timer:
										cmp	byte ptr cs:gvar_frame_timer,14h
										jb	wait_fade_timer			; Jump if below
						inc	byte ptr cs:cur_row_ctr
						loop	color_fade_outer		; Loop if cx > 0

		pop	ds
		retn

imgctl_multiply_3		proc	near
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	al,cs:cur_color
		add	al,10h
		mov	cl,50h			; 'P'
		mul	cl			; ax = reg * al
		add	ax,4
		mov	di,ax
		cmp	cs:cur_color,bl
		jae	sprite_in_range			; Jump if above or =
		jmp	sprite_clear_row

sprite_in_range:
		mov	al,bl
		add	al,cs:render_fn_ptr
		cmp	cs:cur_color,al
		jae	sprite_clear_row			; Jump if above or =
		mov	al,cs:cur_color
		sub	al,bl
		mul	byte ptr cs:render_fn_ptr+1	; ax = data * al
		add	si,ax
		mov	byte ptr cs:cur_col_ctr,0
		mov	cx,48h

sprite_col_render_loop:
						push	cx
						mov	al,0Fh
						out	dx,al			; port 3C5h, EGA sequencr func
						mov	byte ptr es:[di],0
						cmp	cs:cur_col_ctr,bh
						jb	sprite_col_end			; Jump if below
						mov	al,bh
						add	al,byte ptr cs:render_fn_ptr+1
						cmp	cs:cur_col_ctr,al
						jae	sprite_col_end			; Jump if above or =
						push	si
						test	byte ptr cs:plane_enable_flags,1
						jz	render_plane1			; Jump if zero
						mov	al,1
						out	dx,al			; port 3C5h, EGA sequencr func
						mov	al,[si]
						mov	es:[di],al
						add	si,cs:img_stride

render_plane1:
						test	byte ptr cs:plane_enable_flags,2
						jz	render_plane2			; Jump if zero
						mov	al,2
						out	dx,al			; port 3C5h, EGA sequencr func
						mov	al,[si]
						mov	es:[di],al
						add	si,cs:img_stride

render_plane2:
						test	byte ptr cs:plane_enable_flags,4
						jz	render_plane4			; Jump if zero
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						mov	al,[si]
						mov	es:[di],al

render_plane4:
						pop	si
						inc	si

sprite_col_end:
						inc	di
						inc	byte ptr cs:cur_col_ctr
						pop	cx
						loop	sprite_col_render_loop		; Loop if cx > 0

		retn

sprite_clear_row:
		mov	al,0Fh
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,24h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

imgctl_multiply_3		endp

imgctl_draw_border_box:
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	cs:cur_color,bl
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,vga_seg
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register
		sub	cx,5
		push	cx
		push	di
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		call	imgctl_process_loop_4
		pop	di
		inc	byte ptr cs:cur_color
		add	di,50h
		mov	cx,2
		call	imgctl_process_loop_5
		pop	cx

draw_border_mid_loop:
						push	cx
						call	imgctl_func_15
						mov	al,30h			; '0'
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,7
						xchg	es:[di],al
						mov	al,0Fh
						out	dx,al			; port 3CFh, EGA graphic func
						xor	al,al			; Zero register
						xchg	es:[di],al
						mov	al,0Ch
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,7
						xchg	es:[bx+di-1],al
						mov	al,0F0h
						out	dx,al			; port 3CFh, EGA graphic func
						xor	al,al			; Zero register
						xchg	es:[bx+di-1],al
						inc	byte ptr cs:cur_color
						add	di,50h
						pop	cx
						loop	draw_border_mid_loop		; Loop if cx > 0

		mov	cx,1
		call	imgctl_process_loop_5
		call	imgctl_process_loop_4
		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

imgctl_process_loop_4		proc	near
		call	imgctl_func_15
		mov	al,3Fh			; '?'
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,7
		xchg	es:[di],al
		inc	di
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	cx,bx
		sub	cx,2

draw_border_fill_loop:
						mov	al,7
						xchg	es:[di],al
						inc	di
						loop	draw_border_fill_loop		; Loop if cx > 0

		mov	al,0FCh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,7
		xchg	es:[di],al
		retn

imgctl_process_loop_4		endp

imgctl_process_loop_5		proc	near

draw_border_tb_loop:
						push	cx
						push	di
						call	imgctl_func_15
						mov	al,30h			; '0'
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,7
						xchg	es:[di],al
						mov	al,0Fh
						out	dx,al			; port 3CFh, EGA graphic func
						xor	al,al			; Zero register
						xchg	es:[di],al
						inc	di
						mov	al,0FFh
						out	dx,al			; port 3CFh, EGA graphic func
						mov	cx,bx
						sub	cx,2

clear_interior_loop:
										xor	al,al			; Zero register
										xchg	es:[di],al
										inc	di
										loop	clear_interior_loop		; Loop if cx > 0

						mov	al,0Ch
						out	dx,al			; port 3CFh, EGA graphic func
						mov	al,7
						xchg	es:[di],al
						mov	al,0F0h
						out	dx,al			; port 3CFh, EGA graphic func
						xor	al,al			; Zero register
						xchg	es:[di],al
						pop	di
						inc	byte ptr cs:cur_color
						add	di,50h
						pop	cx
						loop	draw_border_tb_loop		; Loop if cx > 0

		retn

imgctl_process_loop_5		endp

imgctl_func_15		proc	near
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di-1],al
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,55h			; 'U'
		mov	cl,cs:cur_color
		and	cl,1
		ror	al,cl			; Rotate
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di-1],al
		mov	al,2
		xchg	es:[di],al
		retn

imgctl_func_15		endp

imgctl_rotate_planes:
		push	bx
		push	es
		push	di
		mov	cx,sprite_backbuf_plane_sz

rotate_planes_loop:
						mov	al,es:[di]
						and	al,byte ptr es:[sprite_backbuf_plane_sz][di]
						mov	ah,es:ega_plane2_buf[di]
						not	ah
						and	al,ah
						not	al
						and	es:[di],al
						and	byte ptr es:[sprite_backbuf_plane_sz][di],al
						and	es:ega_plane2_buf[di],al
						mov	al,es:ega_plane2_buf[di]
						mov	ah,es:[di]
						not	ah
						and	al,ah
						mov	ah,byte ptr es:[sprite_backbuf_plane_sz][di]
						not	ah
						and	al,ah
						or	es:[di],al
						or	byte ptr es:[sprite_backbuf_plane_sz][di],al
						not	al
						and	es:ega_plane2_buf[di],al
						inc	di
						loop	rotate_planes_loop		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,2F58h		; ch=2Fh rows, cl=58h bytes/row: full backbuf copy extents
		jmp	sprite_copy_entry

imgctl_vscroll_interleave:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	di,69Ah
		add	di,ds:saved_di
		call	imgctl_process_loop_6
		mov	di,6BCh
		add	di,ds:saved_di
		call	imgctl_process_loop_6
		mov	ax,vga_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	cx,44h

scroll_rows_loop:
						push	cx
						mov	byte ptr cs:gvar_frame_timer,0
						mov	ax,44h
						sub	ax,cx
						add	ax,ax
						push	ax
						mov	bl,50h			; 'P'
						mul	bl			; ax = reg * al
						mov	di,ax
						add	ax,cs:saved_di
						mov	si,ax
						pop	ax
						cmp	ax,16h
						jb	skip_partial_row			; Jump if below
						cmp	ax,71h
						jae	skip_partial_row			; Jump if above or =
						call	copy_buffer_5
						jmp	short after_row_copy

skip_partial_row:
						call	copy_buffer_4

after_row_copy:
						pop	cx
						push	cx
						mov	ax,cx
						add	ax,ax
						dec	ax
						push	ax
						mov	bl,50h			; 'P'
						mul	bl			; ax = reg * al
						mov	di,ax
						add	ax,cs:saved_di
						mov	si,ax
						pop	ax
						cmp	ax,16h
						jb	skip_partial_row_b			; Jump if below
						cmp	ax,71h
						jae	skip_partial_row_b			; Jump if above or =
						call	copy_buffer_5
						jmp	short wait_scroll_delay

skip_partial_row_b:
						call	copy_buffer_4

wait_scroll_delay:
										cmp	byte ptr cs:gvar_frame_timer,4
										jb	wait_scroll_delay			; Jump if below
						pop	cx
						loop	scroll_rows_loop		; Loop if cx > 0

		pop	ds
		retn

copy_buffer_4		proc	near
		push	si
		push	di
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,50h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	si,ega_plane_stride
		push	si
		push	di
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,50h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	si,ega_plane_stride
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,50h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn

copy_buffer_4		endp

copy_buffer_5		proc	near
		push	si
		push	di
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Ah
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	si,ega_plane_stride
		push	si
		push	di
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Ah
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	si,ega_plane_stride
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Ah
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn

copy_buffer_5		endp

imgctl_process_loop_6		proc	near
		push	di
		mov	ax,0FC3Fh
		call	fill_buffer
		add	di,36h
		mov	cx,5Bh

draw_border_top_loop:
						mov	byte ptr es:[di],30h	; '0'
						mov	byte ptr es:[di+19h],0Ch
						add	di,50h
						loop	draw_border_top_loop		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer
		pop	di
		add	di,ega_plane_stride
		push	di
		mov	ax,0FD7Fh
		call	fill_buffer
		add	di,36h
		mov	cx,2Dh

draw_border_mid_rows_loop:
						mov	byte ptr es:[di],0B0h
						mov	byte ptr es:[di+19h],0Eh
						add	di,50h
						mov	byte ptr es:[di],70h	; 'p'
						mov	byte ptr es:[di+19h],0Dh
						add	di,50h
						loop	draw_border_mid_rows_loop		; Loop if cx > 0

		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	ax,0FD7Fh
		call	fill_buffer
		pop	di
		add	di,ega_plane_stride
		mov	ax,0FC3Fh
		call	fill_buffer
		add	di,36h
		mov	cx,5Bh

draw_border_bot_loop:
						mov	byte ptr es:[di],30h	; '0'
						mov	byte ptr es:[di+19h],0Ch
						add	di,50h
						loop	draw_border_bot_loop		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer
		retn

imgctl_process_loop_6		endp

fill_buffer		proc	near
		stosb				; Store al to es:[di]
		mov	al,0FFh
		mov	cx,18h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,ah
		stosb				; Store al to es:[di]
		retn

fill_buffer		endp

imgctl_hscroll_interleave:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	ax,vga_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,39h

scroll_interleave_loop:
						mov	byte ptr cs:gvar_frame_timer,0
						push	cx
						mov	ax,cx
						neg	ax
						add	ax,39h
						add	ax,ax
						call	vga_operation0
						pop	ax
						push	ax
						add	ax,ax
						dec	ax
						call	vga_operation0

wait_interleave_timer:
										cmp	byte ptr cs:gvar_frame_timer,4
										jb	wait_interleave_timer			; Jump if below
						pop	cx
						loop	scroll_interleave_loop		; Loop if cx > 0

		pop	ds
		retn

vga_operation0		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,cs:saved_di
		mov	si,ax
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	di,ax
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,4
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		pop	ax
		push	ax
		push	di
		push	si
		call	vga_operation1
		pop	si
		pop	di
		add	si,scroll_plane2_off
		mov	dx,3C4h
		mov	ax,202h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,104h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		pop	ax
		push	ax
		push	di
		push	si
		call	vga_operation1
		pop	si
		pop	di
		add	si,offset hscroll_plane4_buf
		mov	dx,3C4h
		mov	ax,402h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,204h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		pop	ax

vga_operation1:
		cmp	ax,14h
		jae	row_ge_14			; Jump if above or =
		mov	cx,2Fh
		jmp	short full_row_copy

row_ge_14:
		mov	cx,23h
		cmp	ax,17h
		jb	full_row_copy			; Jump if below
		cmp	ax,1Ch
		jb	partial_row_merge			; Jump if below
		mov	cx,21h

full_row_copy:
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn

partial_row_merge:
		mov	cx,21h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		lodsb				; String [si] to al
		and	al,0FCh
		and	byte ptr es:[di],3
		or	es:[di],al
		retn

vga_operation0		endp

imgctl_hscroll_interleave2:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	ax,vga_seg
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	ds,cs:saved_es
		mov	cx,39h

scroll_interleave2_loop:
						mov	byte ptr cs:gvar_frame_timer,0
						push	cx
						mov	ax,cx
						neg	ax
						add	ax,39h
						add	ax,ax
						call	vga_operation2
						pop	ax
						push	ax
						add	ax,ax
						dec	ax
						call	vga_operation2

wait_interleave2_timer:
										cmp	byte ptr cs:gvar_frame_timer,4
										jb	wait_interleave2_timer			; Jump if below
						pop	cx
						loop	scroll_interleave2_loop		; Loop if cx > 0

		pop	ds
		retn

vga_operation2		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,hscroll_plane_off
		add	ax,cs:saved_di
		mov	si,ax
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	ax,661h
		mov	di,ax
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	ax
		push	ax
		push	di
		push	si
		call	vga_operation3
		pop	si
		pop	di
		add	si,scroll_plane2_off
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	ax
		push	ax
		push	di
		push	si
		call	vga_operation3
		pop	si
		pop	di
		add	si,offset hscroll_plane4_buf
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	ax

vga_operation3:
		cmp	ax,5Eh
		mov	cx,2Fh
		jnc	skip_partial_row_c			; Jump if carry=0
		mov	cx,0Eh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	cx,21h

skip_partial_row_c:
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn

vga_operation2		endp

imgctl_fill_2px_color:
		push	ax
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	ax,vga_seg
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		pop	ax
		mov	ah,al
		mov	cx,8

color_write_loop:
						stosw				; Store ax to es:[di]
						add	di,4Eh
						loop	color_write_loop		; Loop if cx > 0

		retn

vga_operation4		proc	near

load_palette_entry:
		pushf				; Push flags
		cli				; Disable interrupts
		mov	dx,10h
		mul	dx			; dx:ax = reg * ax
		add	ax,ega_palette_buf
		mov	si,ax
		mov	ax,40h
		mov	es,ax
		mov	dx,es:bios_crt_port_off
		add	dx,6
		push	dx
		in	al,dx			; port 3DAh, CGA/EGA vid status
		mov	dx,3C0h
		xor	ah,ah			; Zero register
		mov	cx,10h

palette_reg_write_loop:
						mov	al,ah
						out	dx,al			; port 3C0h, EGA attributes
						lodsb				; String [si] to al
						out	dx,al			; port 3C0h, EGA attributes
						inc	ah
						loop	palette_reg_write_loop		; Loop if cx > 0

		pop	dx
		in	al,dx			; port 3DAh, CGA/EGA vid status
		mov	al,20h			; ' '
		mov	dx,3C0h
		out	dx,al			; port 3C0h, EGA attributes
		popf				; Pop flags
		retn

vga_operation4		endp

; EGA palette table: 9 sets ?? 16 attribute register values (6-bit VGA DAC values)
; Used by vga_operation4 via ega_palette_buf index ?? 0x10

ega_palette_data:
		db	 00h, 03h, 09h, 3Fh, 00h, 1Bh
		db	 36h, 3Fh, 38h, 07h, 24h, 2Dh
		db	 12h, 1Bh, 06h, 07h, 00h
		db	9, '$'
		db	'-????8'
		db	 07h, 24h, 2Dh, 3Fh, 3Fh, 3Fh
		db	 3Fh, 00h, 09h, 24h, 2Dh, 00h
		db	 1Bh, 36h, 3Fh, 38h, 07h, 24h
		db	 2Dh, 12h, 1Bh, 06h, 07h, 00h
		db	 24h, 09h, 3Fh, 09h, 3Fh, 00h
		db	 3Fh, 38h, 3Fh, 24h, 2Dh, 12h
		db	 1Bh, 36h, 07h, 00h, 01h, 04h
		db	 05h, 03h, 03h
		db	'6?8', 9, '$'
		db	'-', 1Bh, 1Bh
		db	 06h, 3Fh, 00h, 09h, 24h, 03h
		db	 12h
		db	1Bh, '6?8', 9, '$'
		db	'-', 1Bh, 1Bh, '6?'
		db	 00h, 09h, 24h, 2Dh, 00h
		db	1Bh, '6?8', 9, '$'
		db	'-', 1Bh, 1Bh, '6?'
		db	 00h, 09h, 24h, 2Dh, 12h, 1Bh
		db	 36h, 3Fh, 38h, 07h, 24h, 2Dh
		db	 3Fh, 3Fh, 3Fh, 3Fh, 00h, 09h
		db	 24h, 12h, 00h
		db	1Bh, '6?8', 9, '$'
		db	'-', 1Bh, 1Bh, '6?'
		db	 00h, 09h, 24h, 04h, 12h
		db	'$'
		db	'6?8', 9, '$'
		db	'-', 1Bh, 1Bh, '6?.'
		db	0FFh, 26h, 22h, 20h,0C3h
		db	730 dup (0)
hscroll_plane4_buf		db	0
		db	149 dup (0)

seg_a		ends

		end	start
