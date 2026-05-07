
PAGE  59,132

;==========================================================================
;
;  PALETTE_GRAPHICS - 105GDMCA Sprite/Image Renderer (zelres1 chunk 6, gdmcga.bin)
;
;  MCGA/VGA variant of the in-game image / sprite controller. Loaded by
;  game.bin into the game segment (gfx_mode_tbl_all entry, mode 4) when
;  MCGA/VGA mode is selected. Provides sprite blit, scroll, full-DAC
;  palette cycling, and screen primitives used by 100OPDMO opening/title
;  and 106TOWN town/dungeon code.
;
;  Connections:
;    Loads:        none (rendering primitives only)
;    Calls into:   render_fn_ptr (CS:0x450B dispatch slot, set by caller);
;                  VGA framebuffer writes to A000:0
;    Called by:    game.bin LOAD_CHUNK chunk_ref_gdmcga via gfx_mode_tbl_all
;                  (loaded_code_a CS:0x3000 entry for graphics-driver init);
;                  100OPDMO + 106TOWN invoke gfx_init/draw/update/palette
;                  thunks that resolve into this chunk
;    Reads/writes: gvar_frame_timer (FF1A), gvar_game_seg (FF2C)
;                  - zeliad-owned shared globals; VGA palette via DAC ports
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr1com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
gvar_frame_timer	equ	0FF1Ah			;*
gvar_game_seg	equ	0FF2Ch			;*

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
; restored after factoring (consensus value, but not all files agree):
sprite_img_base          equ     97C0h
; restored after factoring (consensus value, but not all files agree):
sprite_row_buf_b         equ     5500h
sprite_mask_off          equ     1A8Eh
ega_plane3_buf	equ	29DCh			;*
mask_tbl_a	equ	32B9h			;*
mask_tbl_b	equ	32C1h			;*
sprite_frame_tbl	equ	3617h			;*
sprite_src_tbl	equ	3619h			;*
move_seq_up	equ	3B1Fh			;*
move_seq_horiz	equ	3BE3h			;*
scroll_col_tbl	equ	3C16h			;*
scroll_row_tbl	equ	3C17h			;*
pal_r_reg	equ	4289h			;*
pal_g_reg	equ	428Ah			;*
pal_b_reg	equ	428Bh			;*
cur_pal_ptr	equ	44F8h			;*
cur_col_ctr	equ	4505h			;*
cur_row_ctr	equ	4506h			;*
cur_pass_ctr	equ	4507h			;*
render_fn_ptr	equ	450Bh			;*
saved_di	equ	450Dh			;*
saved_es	equ	450Fh			;*
sprite_row_buf	equ	5191h			;*
sprite_plane_mask	equ	6666h			;*
font_ptr_a	equ	0F500h			;*
vga_row_stride	equ	140h
text_dest_off	equ	4511h				;* Text output destination offset in VGA
pal_cycle_tbl	equ	3637h				;* Palette cycle RGB table
pal_step_tbl	equ	3A5Fh				;* Palette step data table offset

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
cur_pal_idx	equ	44FAh			;*
src_word_a	equ	44FBh			;*
src_word_b	equ	44FDh			;*
src_word_c	equ	44FFh			;*
src_word_d	equ	4501h			;*
mask_word	equ	4503h			;*
render_mode_flag	equ	4508h			;*

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
sprite_buf_start	equ	0			;*
screen_start_off	equ	0

; SET_ES_3000
;   Compute ES = CS + 3000h (load ES with the +3000h work-buffer segment).
SET_ES_3000	MACRO
		mov	ax, cs
		add	ax, 3000h
		mov	es, ax
		ENDM
; EXPAND_CH_4X
;   Save CX, then CX = CH * 4 (zero-extended 8-bit count -> 16-bit, shifted x4).
;   Used at the entry of each blit row helper to compute the byte count.
EXPAND_CH_4X	MACRO
		push	cx
		mov	cl, ch
		xor	ch, ch
		add	cx, cx
		add	cx, cx
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

mcga_imgctl_module		proc	far

start:
;*		aad	21h			; '!' undocumented inst
		db	0D5h, 21h		;  Fixup - byte match
		add	[bx+si],al
		test	word ptr [si+32h],8830h
;*		xor	ah,ah			; Zero register
		db	 30h,0E4h		;  Fixup - byte match
		xor	[bx+di],ah
		inc	dx
		int	3			; Debug breakpoint
		inc	sp
		db	0C9h, 32h, 2Ch, 33h,0B7h, 33h	; dispatch words: 32C9h, 332Ch, 33B7h
		db	 37h, 34h, 4Fh, 36h,0ABh, 36h	; dispatch words: 3437h, 364Fh, 36ABh
		db	 07h, 37h,0FCh, 30h, 32h, 37h	; dispatch words: 3707h, 30FCh, 3732h
		db	0B4h, 37h,0E6h, 38h, 1Ch, 3Ch	; dispatch words: 37B4h, 38E6h, 3C1Ch
		db	 79h, 3Dh, 35h, 3Eh, 8Bh, 3Eh	; dispatch words: 3D79h, 3E35h, 3E8Bh
		db	 80h, 40h, 62h, 41h, 05h, 42h	; dispatch words: 4080h, 4162h, 4205h
		db	0DEh, 44h, 50h, 53h, 51h, 1Eh	; dispatch word: 44DEh + push ax/bx/cx/ds
		db	 8Ah,0C5h,0F6h,0E1h, 8Bh,0E8h	; mov al,ch; mul cl; mov bp,ax
		db	 06h, 1Fh, 8Bh,0F7h, 8Ch,0C8h	; push es/pop ds; mov si,di; mov ax,cs
		db	 05h, 00h, 30h, 8Eh,0C0h,0BFh	; add ax,3000h; mov es,ax; mov di,...
		db	 00h, 00h, 2Eh,0C7h, 06h,0FDh	; ...0; mov word ptr cs:[44FDh],...
		db	 44h, 00h, 00h, 2Eh,0C7h, 06h	; ...0; mov word ptr cs:[44FFh],...
		db	0FFh, 44h, 00h, 00h, 8Bh,0CDh	; ...0; mov cx,bp
		db	0D1h,0E9h			; shr cx,1 -> render_plane_a_loop

render_plane_a_loop:
							mov	ax,ds:[bp+si]
							xchg	ah,al
							mov	cs:src_word_d,ax
							lodsw				; String [si] to ax
							xchg	ah,al
							mov	cs:src_word_a,ax
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
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
		SET_ES_3000
		mov	di,0
		mov	word ptr cs:src_word_d,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

render_plane_ab_loop:
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
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
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
		call	pal_multiply_4
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,329Dh	; CS:329Dh = disp_blit_expand (write nonzero pixels only)
		call	vga_operation
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
		SET_ES_3000
		mov	di,0
		mov	word ptr cs:src_word_a,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

render_plane_abc_loop:
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
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							pop	cx
							loop	render_plane_abc_loop		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		xor	ax,ax			; Zero register
		mov	di,0
		push	ds
		push	ax
		push	es
		push	di
		call	pal_multiply_4
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,3277h	; CS:3277h = blit_or_entry (OR blit)
		mov	byte ptr cs:render_mode_flag,0
		or	al,al			; Zero ?
		jnz	render_blit_skip			; Jump if not zero
		call	vga_operation

render_blit_skip:
		mov	byte ptr cs:render_mode_flag,0FFh
		call	vga_operation
		pop	ds
		retn

render_blit_entry:
		push	ds
		push	ax
		push	es
		push	di
		call	pal_multiply_4
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,3239h	; CS:3239h = disp_blit_masked (masked write blit)
		mov	byte ptr cs:render_mode_flag,0
		or	al,al			; Zero ?
		jnz	render_blit_skip2			; Jump if not zero
		call	vga_operation

render_blit_skip2:
		mov	byte ptr cs:render_mode_flag,0FFh
		call	vga_operation
		pop	ds
		retn

mcga_imgctl_module		endp

vga_operation		proc	near
		mov	byte ptr cs:cur_row_ctr,0
		mov	ax,vga_seg
		mov	es,ax
		mov	bp,8

vga_blit_row_start:
							mov	al,cs:cur_row_ctr
							mov	cs:cur_col_ctr,al
							mov	byte ptr cs:gvar_frame_timer,0
							push	cx
							push	si
							push	di

vga_blit_col_loop:
												mov	bl,cs:cur_col_ctr
												and	bx,7
												mov	bl,cs:mask_tbl_a[bx]
												call	word ptr cs:render_fn_ptr
												inc	byte ptr cs:cur_col_ctr
												mov	al,ch
												xor	ah,ah			; Zero register
												add	ax,ax
												add	ax,ax
												add	si,ax
												add	di,140h
												dec	cl
												jz	vga_blit_col_done			; Jump if zero
												mov	bl,cs:cur_col_ctr
												and	bx,7
												mov	bl,cs:mask_tbl_b[bx]
												call	word ptr cs:render_fn_ptr
												inc	byte ptr cs:cur_col_ctr
												mov	al,ch
												xor	ah,ah			; Zero register
												add	ax,ax
												add	ax,ax
												add	si,ax
												add	di,140h
												dec	cl
												jnz	vga_blit_col_loop			; Jump if not zero

vga_blit_col_done:
							pop	di
							pop	si
							pop	cx
							inc	byte ptr cs:cur_row_ctr

vga_frame_wait:
												cmp	byte ptr cs:gvar_frame_timer,14h
												jb	vga_frame_wait			; Jump if below
							dec	bp
							jnz	vga_blit_row_start			; Jump if not zero
		retn

vga_operation		endp

disp_blit_masked:
		test	byte ptr cs:render_mode_flag,0FFh
		jz	blit_or_entry			; Jump if zero
		push	si
		push	di
		EXPAND_CH_4X

blit_write_loop:
							lodsb				; String [si] to al
							rol	bl,1			; Rotate
							jnc	blit_write_skip			; Jump if carry=0
							mov	es:[di],al

blit_write_skip:
							inc	di
							loop	blit_write_loop		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn

blit_or_entry:
							push	si
							push	di
							EXPAND_CH_4X

blit_or_loop:
												lodsb				; String [si] to al
												rol	bl,1			; Rotate
												sbb	ah,ah
												and	al,ah
												or	es:[di],al
												inc	di
												loop	blit_or_loop		; Loop if cx > 0

							pop	cx
							pop	di
							pop	si
							retn

disp_blit_expand:
							test	byte ptr cs:render_mode_flag,0FFh
							jz	blit_or_entry			; Jump if zero
		push	si
		push	di
		EXPAND_CH_4X

blit_write_nonzero_loop:
							lodsb				; String [si] to al
							rol	bl,1			; Rotate
							jnc	blit_write_nonzero_skip			; Jump if carry=0
							or	al,al			; Zero ?
							jz	blit_write_nonzero_skip			; Jump if zero
							mov	es:[di],al

blit_write_nonzero_skip:
							inc	di
							loop	blit_write_nonzero_loop		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn

disp_blit_clear:
		push	di
		push	cx
		not	bl
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx

blit_and_mask_loop:
							rol	bl,1			; Rotate
							sbb	al,al
							rol	bl,1			; Rotate
							sbb	ah,ah
							and	es:[di],ax
							inc	di
							inc	di
							loop	blit_and_mask_loop		; Loop if cx > 0

		pop	cx
		pop	di
		retn

disp_text_render:
		and	byte ptr [bx+si],8
		add	al,[bx+si+10h]
		add	al,1
		add	[si],ax
		adc	[bx+si+2],al
		or	[bx+si],ah
		or	byte ptr ds:font_ctrl_byte,11h
		inc	bp
		xor	ax,ax			; Zero register
		mov	cx,640h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	di,text_dest_off

font_char_loop:
							lodsb				; String [si] to al
							cmp	al,0FFh
							jne	font_char_notend			; Jump if not equal
							retn

font_char_notend:
							sub	al,20h			; ' '
							jnc	font_char_nonempty			; Jump if carry=0
							retn

font_char_nonempty:
							jz	font_char_space			; Jump if zero
							push	si
							push	di
							xor	ah,ah			; Zero register
							add	ax,ax
							add	ax,ax
							add	ax,ax
							add	ax,ds:font_ptr_a
							mov	si,ax
							mov	cx,8

font_row_loop:
												push	cx
												lodsb				; String [si] to al
												call	pal_func_2
												mov	es:[di],dx
												call	pal_func_2
												mov	es:[di+2],dx
												call	pal_func_2
												mov	es:[di+4],dx
												call	pal_func_2
												mov	es:[di+6],dx
												add	di,140h
												pop	cx
												loop	font_row_loop		; Loop if cx > 0

							pop	di
							pop	si

font_char_space:
							add	di,8
							jmp	short font_char_loop

pal_func_2		proc	near
		add	al,al
		sbb	dl,dl
		add	al,al
		sbb	dh,dh
		retn

pal_func_2		endp

disp_scroll_copy:
		push	ds
		push	cx
		push	bx
		mov	dl,0A0h
		mul	dl			; ax = reg * al
		add	ax,ax
		add	ax,text_dest_off
		mov	si,ax
		add	cl,bl
		mov	al,0A0h
		mul	cl			; ax = reg * al
		add	ax,ax
		add	ax,0
		push	ax
		push	si
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		push	ds
		pop	es
		mov	di,cga_buf_start
		mov	si,ega_row_w
		mov	cx,7F60h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		push	cs
		pop	ds
		mov	cx,0A0h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	bx
		push	bx
		call	pal_multiply_4
		mov	di,ax
		pop	bx
		mov	al,0A0h
		mul	bl			; ax = reg * al
		add	ax,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	ax,bx
		mov	si,ax
		add	si,0
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	ax,vga_seg
		mov	es,ax
		pop	cx
		mov	dx,9999h
		mov	bp,sprite_plane_mask
		xor	bx,bx			; Zero register
		mov	bl,ch
		add	bx,bx
		xor	ch,ch			; Zero register

sprite_blit_row_loop:
							push	cx
							push	di
							mov	cx,bx

sprite_blit_col_loop:
												and	es:[di],dx
												lodsw				; String [si] to ax
												and	ax,bp
												or	es:[di],ax
												inc	di
												inc	di
												loop	sprite_blit_col_loop		; Loop if cx > 0

							pop	di
							add	di,140h
							pop	cx
							loop	sprite_blit_row_loop		; Loop if cx > 0

		pop	ds
		retn

render_plane_ab_2_entry:
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
		SET_ES_3000
		mov	di,0
		mov	word ptr cs:src_word_d,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

render_plane_ab_2_loop:
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
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							loop	render_plane_ab_2_loop		; Loop if cx > 0

		pop	cx
		pop	bx
		pop	ax
		pop	ds

blit_vga_entry:
		push	ds
		call	pal_multiply_4
		mov	di,ax
		mov	si,sprite_buf_start
		push	es
		pop	ds
		mov	ax,vga_seg
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ch
		add	bx,bx
		add	bx,bx
		xor	ch,ch			; Zero register

blit_vga_row_loop:
							push	cx
							push	di
							mov	cx,bx
							rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
							pop	di
							pop	cx
							add	di,140h
							loop	blit_vga_row_loop		; Loop if cx > 0

		pop	ds
		retn

disp_sprite_obj_init:
		push	cs
		pop	es
		mov	di,sprite_obj_tbl
		xor	dx,dx			; Zero register
		mov	cx,9

sprite_init_loop:
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
							add	dx,300h
							loop	sprite_init_loop		; Loop if cx > 0

		mov	byte ptr ds:cur_col_ctr,0
		mov	byte ptr ds:gvar_frame_timer,0

sprite_anim_frame_top:
		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_update_loop:
							push	cx
							test	byte ptr [si],0FFh
							jz	sprite_update_done			; Jump if zero
							mov	al,[si+0Dh]
							cmp	al,[si+0Eh]
							je	sprite_anim_advance			; Jump if equal
							inc	byte ptr [si+0Ch]
							test	byte ptr [si+0Ch],1
							jnz	sprite_anim_advance			; Jump if not zero
							inc	byte ptr [si+0Dh]

sprite_anim_advance:
							xor	bx,bx			; Zero register
							mov	bl,[si+0Dh]
							add	bx,bx
							add	bx,bx
							mov	cx,ds:sprite_src_tbl[bx]
							mov	[si+7],cx
							mov	al,[si+4]
							add	al,[si+0Ah]
							mov	[si+4],al
							mov	bh,al
							mov	al,[si+3]
							add	al,[si+9]
							mov	[si+3],al
							mov	bl,al
							call	pal_multiply_4
							mov	[si+5],ax
							mov	di,ax
							mov	bp,[si+1]
							push	ds
							push	si
							mov	ax,vga_seg
							mov	ds,ax
							SET_ES_3000
							mov	si,di
							mov	di,bp
							call	copy_buffer
							pop	si
							pop	ds

sprite_update_done:
							pop	cx
							add	si,0Fh
							loop	sprite_update_loop		; Loop if cx > 0

		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_pal_update_loop:
							push	cx
							push	si
							mov	al,ds:cur_col_ctr
							and	al,7
							mov	ah,3
							mul	ah			; ax = reg * al
							add	ax,pal_cycle_tbl
							mov	si,ax
							lodsb				; String [si] to al
							mov	ds:pal_r_reg,al
							lodsb				; String [si] to al
							mov	ds:pal_g_reg,al
							lodsb				; String [si] to al
							mov	ds:pal_b_reg,al
							inc	byte ptr ds:cur_col_ctr
							xor	ax,ax			; Zero register
							call	vga_operation9
							pop	si
							test	byte ptr cs:[si],0FFh
							jz	sprite_pal_skip			; Jump if zero
							xor	bx,bx			; Zero register
							mov	bl,[si+0Dh]
							add	bx,bx
							add	bx,bx
							mov	bp,ds:sprite_frame_tbl[bx]
							mov	cx,[si+7]
							mov	dl,[si]
							mov	byte ptr [si],0
							mov	ax,[si+3]
							cmp	ah,4Bh			; 'K'
							jae	sprite_pal_skip			; Jump if above or =
							cmp	al,0A0h
							jae	sprite_pal_skip			; Jump if above or =
							mov	[si],dl
							mov	di,[si+5]
							push	ds
							push	si
							mov	ax,vga_seg
							mov	es,ax
							mov	ds,cs:gvar_game_seg
							mov	si,bp
							call	pal_multiply
							pop	si
							pop	ds

sprite_pal_skip:
							pop	cx
							add	si,0Fh
							loop	sprite_pal_update_loop		; Loop if cx > 0

sprite_frame_wait:
							cmp	byte ptr cs:gvar_frame_timer,1Eh
							jb	sprite_frame_wait			; Jump if below
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
							mov	ax,vga_seg
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

sprite_active_check:
							test	byte ptr [si],0FFh
							jz	sprite_slot_empty			; Jump if zero
							jmp	sprite_anim_frame_top

sprite_slot_empty:
							add	si,0Fh
							loop	sprite_active_check		; Loop if cx > 0

		mov	ax,2
		jmp	palette_write_entry

copy_buffer		proc	near
		push	si
		push	cx

copy_buf_row_loop:
							push	si
							EXPAND_CH_4X
							rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
							pop	cx
							pop	si
							add	si,140h
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
							EXPAND_CH_4X
							rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
							pop	cx
							pop	di
							add	di,140h
							dec	cl
							jnz	copy_buf2_row_loop			; Jump if not zero
		pop	cx
		pop	di
		retn

copy_buffer_2		endp

pal_multiply		proc	near
		push	di
		push	cx
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bx,ax
		mov	word ptr cs:src_word_d,0

pal_mul_row_loop:
							push	di
							push	cx
							mov	cl,ch
							xor	ch,ch			; Zero register

pal_mul_pixel_loop:
												xor	al,al			; Zero register
												mov	ah,[bx+si]
												mov	cs:src_word_b,ax
												mov	ah,[si]
												mov	cs:src_word_a,ax
												mov	cs:src_word_c,ax
												inc	si
												push	bx
												call	pal_process_loop
												pop	bx
												or	es:[di],ax
												push	bx
												call	pal_process_loop
												pop	bx
												or	es:[di+2],ax
												add	di,4
												loop	pal_mul_pixel_loop		; Loop if cx > 0

							pop	cx
							pop	di
							add	di,140h
							dec	cl
							jnz	pal_mul_row_loop			; Jump if not zero
		pop	cx
		pop	di
		retn

pal_multiply		endp

disp_scroll_a:					;* Dispatcher entry: scroll function A
		db	 00h, 90h, 20h, 06h, 80h, 91h	; CRTC seq: (00h,90h),(20h,06h),(80h,91h)
		db	 20h, 06h, 00h, 93h, 20h, 06h	; CRTC seq: (20h,06h),(00h,93h),(20h,06h)
		db	 80h, 94h, 20h, 06h, 00h, 96h	; CRTC seq: (80h,94h),(20h,06h),(00h,96h)
		db	 18h, 04h,0C0h, 96h, 18h, 04h	; CRTC seq: (18h,04h),(C0h,96h),(18h,04h)
		db	 80h, 97h, 18h, 04h, 40h, 98h	; CRTC seq: (80h,97h),(18h,04h),(40h,98h)
		db	 18h, 04h, 1Fh, 1Fh, 00h, 0Fh	; CRTC seq + plane mix tbl: 1F1F 000F
		db	 0Fh, 00h, 1Fh, 1Fh, 1Fh, 0Fh	; plane mix table (4 bytes/entry)
		db	 0Fh, 0Fh, 1Fh, 00h, 1Fh, 0Fh	; plane mix table (cont.)
		db	 00h, 0Fh, 1Fh, 00h, 00h, 0Fh	; plane mix table (cont.)
		db	 00h, 00h, 1Eh, 53h, 32h,0E4h	; plane mix tbl tail + push ds; push bx; xor ah
		db	0BAh,0C0h, 0Ch,0F7h,0E2h, 05h	; mov dx,0CC0h; mul dx; add ax,...
		db	 40h,0ABh			; ...4000h marker; stosw (continued by next inline word)
		db	2Eh					; CS segment override prefix (with next 2 bytes = MOV DS,[BX])
scroll_a_plane_b	dw	1E8Eh		; Bytes 8Eh,1Eh = MOV DS,[BX] in disp_scroll_a code; label offset used as plane B displacement in render_ab_buf_loop
		db	 2Ch,0FFh, 8Bh,0F0h, 8Ch,0C8h	; (cont.) sub al,FFh; mov si,ax; mov ax,cs
		db	 05h, 00h, 30h, 8Eh,0C0h,0BFh	; add ax,3000h; mov es,ax; mov di,...
		db	 00h, 00h, 2Eh,0C7h, 06h, 01h	; ...0; mov word ptr cs:[4501h],...
		db	 45h, 00h, 00h, 2Eh,0C7h, 06h	; ...0; mov word ptr cs:[44FFh],...
		db	0FFh, 44h, 00h, 00h,0B9h, 30h	; ...0; mov cx,330h
		db	 03h				; (cont. mov cx high byte) -> render_ab_buf_loop

render_ab_buf_loop:
							mov	ax,scroll_a_plane_b[si]
							xchg	ah,al
							mov	cs:src_word_a,ax
							lodsw				; String [si] to ax
							xchg	ah,al
							mov	cs:src_word_b,ax
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							loop	render_ab_buf_loop		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,0
		mov	cx,2230h
		jmp	blit_vga_entry

disp_render_ab_gseg:
		push	ds
		push	bx
		xor	ah,ah			; Zero register
		mov	dx,480h
		mul	dx			; dx:ax = reg * ax
		add	ax,sprite_img_base
		mov	ds,cs:gvar_game_seg
		mov	si,ax
		SET_ES_3000
		mov	di,0
		mov	word ptr cs:src_word_d,0
		mov	word ptr cs:src_word_c,0
		mov	cx,120h

render_ab_gseg_loop:
							mov	ax,ds:cga_plane2_off[si]
							xchg	ah,al
							mov	cs:src_word_b,ax
							lodsw				; String [si] to ax
							xchg	ah,al
							mov	cs:src_word_a,ax
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							loop	render_ab_gseg_loop		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,screen_start_off
		mov	cx,1220h
		jmp	blit_vga_entry

disp_vga_checker:
		mov	ax,vga_seg
		mov	es,ax
		xor	di,di			; Zero register
		mov	cx,64h

vga_checker_row_loop:
							push	cx
							push	di
							mov	ax,1000h
							mov	cx,0A0h
							rep	stosw			; Rep when cx >0 Store ax to es:[di]
							pop	di
							add	di,vga_row_stride
							push	di
							mov	ax,10h
							mov	cx,0A0h
							rep	stosw			; Rep when cx >0 Store ax to es:[di]
							pop	di
							add	di,140h
							pop	cx
							loop	vga_checker_row_loop		; Loop if cx > 0

		retn

disp_tilemap_render:				;* Dispatcher entry: tilemap render
		db	 33h,0DBh,0B9h, 19h, 00h	; xor bx,bx; mov cx,19h

tilemap_row_loop:
							push	cx
							mov	cx,22h

tilemap_col_loop:
												push	cx
												lodsb				; String [si] to al
												push	bx
												push	ds
												push	si
												call	pal_multiply_2
												pop	si
												pop	ds
												pop	bx
												inc	bh
												pop	cx
												loop	tilemap_col_loop		; Loop if cx > 0

							xor	bh,bh			; Zero register
							inc	bl
							pop	cx
							loop	tilemap_row_loop		; Loop if cx > 0

		retn

pal_multiply_2		proc	near
		mov	ds,cs:gvar_game_seg
		mov	dx,cs
		add	dx,2000h
		mov	es,dx
		xor	ah,ah			; Zero register

div_loop:
							sub	al,28h			; '('
							jc	div_done			; Jump if carry Set
							inc	ah
							jmp	short div_loop

div_done:
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

tile_plane_loop:
							push	cx
							push	di
							push	si
							mov	cx,8

tile_row_loop:
												movsb				; Mov [si] to es:[di]
												add	di,21h
												add	si,27h
												loop	tile_row_loop		; Loop if cx > 0

							pop	si
							pop	di
							add	di,1A90h
							add	si,640h
							pop	cx
							loop	tile_plane_loop		; Loop if cx > 0

		retn

pal_multiply_2		endp

disp_tile_render:
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

bitrev_loop:
							mov	al,es:[di]
							mov	dx,8

bitrev_bit_loop:
												ror	al,1			; Rotate
												adc	ah,ah
												dec	dx
												jnz	bitrev_bit_loop			; Jump if not zero
							mov	es:[di],ah
							inc	di
							loop	bitrev_loop		; Loop if cx > 0

		pop	si
		pop	ax
		mov	bl,al
		xor	bh,bh			; Zero register
		call	pal_multiply_4
		mov	di,ax
		mov	ax,vga_seg
		mov	es,ax
		push	di
		mov	cx,11h

sprite_render_loop_a:
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
							mov	cs:mask_word,ax
							call	pal_func_21
							and	es:[di],ax
							call	pal_process_loop
							or	es:[di],ax
							call	pal_func_21
							and	es:[di+2],ax
							call	pal_process_loop
							or	es:[di+2],ax
							call	pal_func_21
							and	es:[di+4],ax
							call	pal_process_loop
							or	es:[di+4],ax
							call	pal_func_21
							and	es:[di+6],ax
							call	pal_process_loop
							or	es:[di+6],ax
							add	di,8
							pop	cx
							loop	sprite_render_loop_a		; Loop if cx > 0

		pop	di
		add	di,138h
		push	cs
		pop	ds
		mov	si,sprite_row_buf
		mov	cx,11h

sprite_render_loop_b:
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
							mov	cs:mask_word,ax
							call	pal_func_21
							and	es:[di+4],ax
							call	pal_process_loop
							or	es:[di+4],ax
							call	pal_func_21
							and	es:[di+6],ax
							call	pal_process_loop
							or	es:[di+6],ax
							call	pal_func_21
							and	es:[di],ax
							call	pal_process_loop
							or	es:[di],ax
							call	pal_func_21
							and	es:[di+2],ax
							call	pal_process_loop
							or	es:[di+2],ax
							sub	di,8
							pop	cx
							loop	sprite_render_loop_b		; Loop if cx > 0

		pop	ds
		retn

disp_scroll_ring:
		mov	bx,ax
		add	bx,bx
		mov	al,ds:scroll_col_tbl[bx]
		mov	ds:cur_row_ctr,al
		mov	al,ds:scroll_row_tbl[bx]
		mov	ds:cur_col_ctr,al
		mov	ax,vga_seg
		mov	es,ax
		mov	di,1410h
		mov	si,move_seq_up

scroll_up_loop:
							lodsb				; String [si] to al
							or	al,al			; Zero ?
							jz	scroll_up_done			; Jump if zero
							call	pal_func_7
							add	di,500h
							jmp	short scroll_up_loop

scroll_up_done:
		add	di,0FB04h

scroll_right_loop:
							lodsb				; String [si] to al
							or	al,al			; Zero ?
							jz	scroll_right_done			; Jump if zero
							call	pal_func_7
							add	di,4
							jmp	short scroll_right_loop

scroll_right_done:
		add	di,0FAFCh

scroll_down_loop:
							lodsb				; String [si] to al
							or	al,al			; Zero ?
							jz	scroll_down_done			; Jump if zero
							call	pal_func_7
							add	di,0FB00h
							jmp	short scroll_down_loop

scroll_down_done:
		add	di,4FCh

scroll_left_loop:
							lodsb				; String [si] to al
							or	al,al			; Zero ?
							jz	scroll_left_done			; Jump if zero
							call	pal_func_7
							sub	di,4
							jmp	short scroll_left_loop

scroll_left_done:
		add	di,504h
		mov	si,move_seq_horiz

scroll_ring_top:
							mov	byte ptr cs:gvar_frame_timer,0
							lodsb				; String [si] to al
							or	al,al			; Zero ?
							jnz	scroll_ring_run			; Jump if not zero
							retn

scroll_ring_run:
							xor	cx,cx			; Zero register
							mov	cl,al

scroll_up_seg_loop:
												push	cx
												mov	al,18h
												call	pal_func_7
												add	di,500h
												pop	cx
												loop	scroll_up_seg_loop		; Loop if cx > 0

							add	di,0FB00h
							lodsb				; String [si] to al
							or	al,al			; Zero ?
							jnz	scroll_horiz_run			; Jump if not zero
							retn

scroll_horiz_run:
							xor	cx,cx			; Zero register
							mov	cl,al

scroll_right_seg_loop:
												push	cx
												mov	al,18h
												call	pal_func_7
												add	di,4
												pop	cx
												loop	scroll_right_seg_loop		; Loop if cx > 0

							sub	di,4
							lodsb				; String [si] to al
							or	al,al			; Zero ?
							jnz	scroll_down_run			; Jump if not zero
							retn

scroll_down_run:
							xor	cx,cx			; Zero register
							mov	cl,al

scroll_down_seg_loop:
												push	cx
												mov	al,18h
												call	pal_func_7
												add	di,0FB00h
												pop	cx
												loop	scroll_down_seg_loop		; Loop if cx > 0

							add	di,500h
							lodsb				; String [si] to al
							or	al,al			; Zero ?
							jnz	scroll_left_run			; Jump if not zero
							retn

scroll_left_run:
							xor	cx,cx			; Zero register
							mov	cl,al

scroll_left_seg_loop:
												push	cx
												mov	al,18h
												call	pal_func_7
												sub	di,4
												pop	cx
												loop	scroll_left_seg_loop		; Loop if cx > 0

							add	di,4

scroll_frame_wait:
												cmp	byte ptr cs:gvar_frame_timer,0Ch
												jb	scroll_frame_wait			; Jump if below
							jmp	short scroll_ring_top

pal_func_7		proc	near
		push	si
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,pal_step_tbl
		mov	si,ax
		push	di
		mov	bh,cs:cur_col_ctr
		call	extract_bits
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		add	di,13Ch
		mov	bh,cs:cur_col_ctr
		ror	bh,1			; Rotate
		call	extract_bits
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		add	di,13Ch
		mov	bh,cs:cur_col_ctr
		call	extract_bits
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		add	di,13Ch
		mov	bh,cs:cur_col_ctr
		ror	bh,1			; Rotate
		call	extract_bits
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		pop	di
		pop	si
		retn

pal_func_7		endp

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
		jnc	extract_bit0			; Jump if carry=0
		or	ds:src_word_a,ax

extract_bit0:
		shr	al,1			; Shift w/zeros fill
		jnc	extract_bit1			; Jump if carry=0
		or	ds:src_word_b,ax

extract_bit1:
		shr	al,1			; Shift w/zeros fill
		jc	extract_bit2			; Jump if carry Set
		retn

extract_bit2:
		or	ds:src_word_c,ax
		retn

extract_bits		endp

pal_plane_sel_tbl:
		db	 00h, 00h, 00h, 03h, 80h, 80h	; sel row  0
		db	 85h, 84h, 03h, 03h, 03h, 03h	; sel row  1
		db	 84h, 84h, 84h, 84h, 03h, 03h	; sel row  2
		db	 03h, 03h, 84h, 84h, 84h,0D4h	; sel row  3
		db	 00h, 00h, 00h,0FFh, 00h, 00h	; sel row  4
		db	 55h, 00h, 00h, 00h, 01h,0FFh	; sel row  5
		db	 02h, 02h, 56h, 00h, 00h, 00h	; sel row  6
		db	 00h,0FFh, 40h, 40h, 55h, 00h	; sel row  7
		db	 00h, 00h, 00h,0C0h, 01h, 01h	; sel row  8
		db	 61h, 21h,0C0h,0C0h,0C0h,0C0h	; sel row  9
		db	 21h, 21h, 21h, 21h,0C0h,0C0h	; sel row 10
		db	0C0h,0C0h, 21h, 21h, 21h, 21h	; sel row 11
		db	0C0h,0E0h,0E0h,0E0h, 2Bh, 01h	; sel row 12
		db	 01h, 01h, 03h, 03h, 03h, 03h	; sel row 13
		db	0D4h, 84h, 84h, 84h, 03h, 03h	; sel row 14
		db	 03h, 03h, 84h, 84h, 84h, 84h	; sel row 15
		db	 03h, 02h, 00h, 00h, 84h, 85h	; sel row 16
		db	 80h, 80h,0FFh,0AAh, 00h, 00h	; sel row 17
		db	 00h, 55h, 00h, 00h,0FFh,0A8h	; sel row 18
		db	 00h, 00h, 00h, 56h, 02h, 02h	; sel row 19
		db	0FFh,0FFh, 00h, 00h, 00h, 55h	; sel row 20
		db	 40h, 40h,0C0h,0C0h,0C0h,0C0h	; sel row 21
		db	 2Bh, 21h, 21h, 21h,0C0h,0C0h	; sel row 22
		db	0C0h,0C0h, 21h, 21h, 21h, 21h	; sel row 23
		db	0C0h, 80h, 00h, 00h, 21h, 61h	; sel row 24
		db	 01h, 01h, 00h, 00h,0FFh,0FFh	; sel row 25
		db	 00h, 00h, 00h, 00h,0FFh,0FFh	; sel row 26
		db	 00h, 00h, 00h, 00h, 00h, 00h	; sel row 27
		db	 07h, 07h, 07h, 07h, 80h, 80h	; sel row 28
		db	 80h, 80h,0E0h,0E0h,0E0h,0E0h	; sel row 29
		db	 01h, 01h, 01h, 01h,0FFh,0FFh	; sel row 30
		db	0FFh,0FFh, 00h, 00h, 00h, 00h	; sel row 31
		db	 01h, 02h, 03h			; pal_seq A: indices 1,2,3
		db	20 dup (16h)			; pal_seq A: 20 entries of value 16h
		db	 0Bh, 0Ch, 0Dh, 00h, 0Eh, 0Fh	; pal_seq B: indices 0Bh-0Fh
		db	66 dup (15h)			; pal_seq B: 66 entries of value 15h
		db	 10h, 0Eh, 13h, 00h, 12h, 11h	; pal_seq C: indices 10h-13h
		db	19 dup (17h)			; pal_seq C: 19 entries of value 17h
		db	 0Ah, 09h, 08h, 07h, 00h, 04h	; pal_seq D: indices 04h-0Ah
		db	 06h				; pal_seq D: index 06h
		db	66 dup (14h)			; pal_seq D: 66 entries of value 14h
		db	 05h, 04h, 00h, 18h, 46h, 18h	; final fade-out pair table:
		db	 45h, 17h, 44h, 16h, 43h, 15h	;   pairs (reg, val)
		db	 42h, 14h, 41h, 13h, 40h, 12h	;
		db	 3Fh, 11h, 3Eh, 10h, 3Dh, 0Fh	;
		db	 3Ch, 0Eh, 3Bh, 0Dh, 3Ah, 0Ch	;
		db	 39h, 0Bh, 38h, 0Ah, 37h, 09h	;
		db	 36h, 08h, 35h, 07h, 34h, 06h	;
		db	 33h, 05h, 32h, 04h, 31h, 03h	;
		db	 30h, 02h, 2Fh, 01h, 2Eh, 00h	;
		db	 02h, 55h, 03h,0FFh, 01h, 55h	; param tag bytes (caller signature)
		db	 1Eh, 2Eh,0A2h, 08h, 45h, 53h	; push ds; mov [cs:4508h],al; push bx
		db	 51h, 8Ah,0C5h,0F6h,0E1h, 8Bh	; push cx; mov al,ch; mul cl; mov bp,...
		db	0E8h, 06h, 1Fh, 8Bh,0F7h, 8Ch	; ...ax; push es; pop ds; mov si,di; mov ax,cs
		db	0C8h, 05h, 00h, 30h, 8Eh,0C0h	; (cont) add ax,3000h; mov es,ax
		db	0BFh, 00h, 00h, 2Eh,0C7h, 06h	; mov di,0; mov word ptr cs:[4501h],...
		db	 01h, 45h, 00h, 00h, 2Eh,0C7h	; ...0; mov word ptr cs:[44FBh],...
		db	 06h,0FBh, 44h, 00h, 00h, 2Eh	; ...0; cs override
		db	0C7h, 06h,0FDh, 44h, 00h, 00h	; mov word ptr cs:[44FDh],0
		db	 2Eh,0C7h, 06h,0FFh, 44h, 00h	; mov word ptr cs:[44FFh],...
		db	 00h, 8Bh,0CDh,0D1h,0E9h	; ...0; mov cx,bp; shr cx,1 -> render_plane_sel_loop

render_plane_sel_loop:
							push	si
							test	byte ptr cs:render_mode_flag,1
							jz	plane1_skip			; Jump if zero
							mov	ax,[si]
							xchg	ah,al
							mov	cs:src_word_a,ax
							add	si,bp

plane1_skip:
							test	byte ptr cs:render_mode_flag,2
							jz	plane2_skip			; Jump if zero
							mov	ax,[si]
							xchg	ah,al
							mov	cs:src_word_b,ax
							add	si,bp

plane2_skip:
							test	byte ptr cs:render_mode_flag,4
							jz	plane3_skip			; Jump if zero
							mov	ax,[si]
							xchg	ah,al
							mov	cs:src_word_c,ax

plane3_skip:
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							pop	si
							inc	si
							inc	si
							loop	render_plane_sel_loop		; Loop if cx > 0

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
		mov	ax,vga_seg
		mov	es,ax
		mov	cx,8

render_pass_loop:
							push	cx
							mov	al,cs:cur_pass_ctr
							mov	cs:cur_row_ctr,al
							mov	byte ptr cs:gvar_frame_timer,0
							mov	cx,0Dh

render_col_loop:
												push	cx
												push	bx
												push	si
												call	pal_multiply_3
												pop	si
												pop	bx
												pop	cx
												add	byte ptr cs:cur_row_ctr,8
												loop	render_col_loop		; Loop if cx > 0

							pop	cx

render_frame_wait:
												cmp	byte ptr cs:gvar_frame_timer,14h
												jb	render_frame_wait			; Jump if below
							inc	byte ptr cs:cur_pass_ctr
							loop	render_pass_loop		; Loop if cx > 0

		pop	ds
		retn

pal_multiply_3		proc	near
		push	bx
		mov	bl,cs:cur_row_ctr
		add	bl,10h
		mov	bh,4
		call	pal_multiply_4
		mov	di,ax
		pop	bx
		cmp	cs:cur_row_ctr,bl
		jb	sprite_clip_clear			; Jump if below
		mov	al,bl
		add	al,cs:render_fn_ptr
		cmp	cs:cur_row_ctr,al
		jae	sprite_clip_clear			; Jump if above or =
		mov	al,cs:cur_row_ctr
		sub	al,bl
		mul	byte ptr cs:render_fn_ptr+1	; ax = data * al
		add	ax,ax
		add	ax,ax
		add	si,ax
		mov	byte ptr cs:cur_col_ctr,0
		mov	cx,48h

sprite_clip_row_loop:
							push	cx
							mov	word ptr es:[di],0
							mov	word ptr es:[di+2],0
							cmp	cs:cur_col_ctr,bh
							jb	sprite_clip_skip			; Jump if below
							mov	al,bh
							add	al,byte ptr cs:render_fn_ptr+1
							cmp	cs:cur_col_ctr,al
							jae	sprite_clip_skip			; Jump if above or =
							movsw				; Mov [si] to es:[di]
							movsw				; Mov [si] to es:[di]
							sub	di,4

sprite_clip_skip:
							add	di,4
							inc	byte ptr cs:cur_col_ctr
							pop	cx
							loop	sprite_clip_row_loop		; Loop if cx > 0

		retn

sprite_clip_clear:
		mov	cx,90h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

pal_multiply_3		endp

disp_scroll_bar:
		mov	cs:cur_row_ctr,bl
		call	pal_multiply_4
		mov	di,ax
		mov	ax,vga_seg
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		sub	bx,4
		xor	ch,ch			; Zero register
		sub	cx,5
		push	cx
		push	di
		call	fill_buffer
		pop	di
		inc	byte ptr cs:cur_row_ctr
		add	di,140h
		mov	cx,2
		call	clear_buffer
		pop	cx

scroll_bar_loop:
							push	cx
							call	vga_operation2
							mov	byte ptr es:[di],0FFh
							mov	byte ptr es:[di+1],0
							mov	byte ptr es:[di+2],0
							mov	byte ptr es:[di+3],0
							or	byte ptr es:[bx+di+3],0FFh
							mov	byte ptr es:[bx+di+2],0
							mov	byte ptr es:[bx+di+1],0
							mov	byte ptr es:[bx+di],0
							inc	byte ptr cs:cur_row_ctr
							add	di,140h
							pop	cx
							loop	scroll_bar_loop		; Loop if cx > 0

		mov	cx,1
		call	clear_buffer

fill_buffer		proc	near
		call	vga_operation2
		mov	cx,bx
		add	cx,4
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn

fill_buffer		endp

clear_buffer		proc	near

clear_buf_row_loop:
							push	cx
							push	di
							call	vga_operation2
							mov	byte ptr es:[di],0FFh
							inc	di
							mov	cx,bx
							add	cx,2
							xor	al,al			; Zero register
							rep	stosb			; Rep when cx >0 Store al to es:[di]
							mov	byte ptr es:[di],0FFh
							pop	di
							inc	byte ptr cs:cur_row_ctr
							add	di,140h
							pop	cx
							loop	clear_buf_row_loop		; Loop if cx > 0

		retn

clear_buffer		endp

vga_operation2		proc	near
		mov	word ptr es:[di-7],202h
		mov	word ptr es:[di-5],202h
		mov	word ptr es:[di-3],202h
		mov	word ptr es:[di-1],202h
		retn

vga_operation2		endp

disp_pixel_sort:
		push	bx
		push	es
		push	di
		mov	cx,1028h

pixel_sort_loop:
							mov	al,es:[di]
							and	al,byte ptr es:[sprite_backbuf_plane_sz][di]
							mov	ah,es:pixel_plane_c_buf[di]
							not	ah
							and	al,ah
							not	al
							and	es:[di],al
							and	byte ptr es:[sprite_backbuf_plane_sz][di],al
							and	es:pixel_plane_c_buf[di],al
							mov	al,es:pixel_plane_c_buf[di]
							mov	ah,es:[di]
							not	ah
							and	al,ah
							mov	ah,byte ptr es:[sprite_backbuf_plane_sz][di]
							not	ah
							and	al,ah
							or	es:[di],al
							or	byte ptr es:[sprite_backbuf_plane_sz][di],al
							not	al
							and	es:pixel_plane_c_buf[di],al
							inc	di
							loop	pixel_sort_loop		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,2F58h
		jmp	render_plane_ab_2_entry

disp_wipe_a:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	di,69Ah
		add	di,ds:saved_di
		call	vga_operation5
		mov	di,6BCh
		add	di,ds:saved_di
		call	vga_operation5
		mov	ax,vga_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,44h

wipe_row_loop:
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
							call	pal_multiply_4
							mov	di,ax
							pop	ax
							add	ax,cs:saved_di
							mov	si,ax
							pop	ax
							cmp	ax,16h
							jb	wipe_edge_call			; Jump if below
							cmp	ax,71h
							jae	wipe_edge_call			; Jump if above or =
							call	vga_operation4
							jmp	short wipe_row_frame_wait

wipe_edge_call:
							call	vga_operation3

wipe_row_frame_wait:
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
							call	pal_multiply_4
							mov	di,ax
							pop	ax
							add	ax,cs:saved_di
							mov	si,ax
							pop	ax
							cmp	ax,16h
							jb	wipe_edge2_call			; Jump if below
							cmp	ax,71h
							jae	wipe_edge2_call			; Jump if above or =
							call	vga_operation4
							jmp	short wipe_frame_wait

wipe_edge2_call:
							call	vga_operation3

wipe_frame_wait:
												cmp	byte ptr cs:gvar_frame_timer,4
												jb	wipe_frame_wait			; Jump if below
							pop	cx
							loop	wipe_row_loop		; Loop if cx > 0

		pop	ds
		retn

vga_operation3		proc	near
		mov	cx,28h
		mov	word ptr cs:src_word_d,0

wipe3_col_loop:
							mov	ax,ds:sprite_row_buf_b[si]
							xchg	ah,al
							mov	cs:src_word_c,ax
							mov	ax,ds:ega_plane_stride[si]
							xchg	ah,al
							mov	cs:src_word_b,ax
							lodsw				; String [si] to ax
							xchg	ah,al
							mov	cs:src_word_a,ax
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							loop	wipe3_col_loop		; Loop if cx > 0

		retn

vga_operation3		endp

vga_operation4		proc	near
		mov	cx,0Bh
		mov	word ptr cs:src_word_d,0

wipe4_top_loop:
							mov	ah,ds:sprite_row_buf_b[si]
							mov	cs:src_word_c,ax
							mov	ah,ds:ega_plane_stride[si]
							mov	cs:src_word_b,ax
							lodsb				; String [si] to al
							xchg	ah,al
							mov	cs:src_word_a,ax
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							loop	wipe4_top_loop		; Loop if cx > 0

		add	si,18h
		add	di,60h
		mov	cx,5

wipe4_mid_loop:
							mov	ax,ds:sprite_row_buf_b[si]
							xchg	ah,al
							mov	cs:src_word_c,ax
							mov	ax,ds:ega_plane_stride[si]
							xchg	ah,al
							mov	cs:src_word_b,ax
							lodsw				; String [si] to ax
							xchg	ah,al
							mov	cs:src_word_a,ax
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							loop	wipe4_mid_loop		; Loop if cx > 0

		add	si,18h
		add	di,60h
		mov	cx,0Bh

wipe4_bot_loop:
							mov	ah,ds:sprite_row_buf_b[si]
							mov	cs:src_word_c,ax
							mov	ah,ds:ega_plane_stride[si]
							mov	cs:src_word_b,ax
							lodsb				; String [si] to al
							xchg	ah,al
							mov	cs:src_word_a,ax
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							loop	wipe4_bot_loop		; Loop if cx > 0

		retn

vga_operation4		endp

vga_operation5		proc	near
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
		add	di,ega_plane_stride
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
		add	di,ega_plane_stride
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

vga_operation5		endp

fill_buffer_2		proc	near
		stosb				; Store al to es:[di]
		mov	al,0FFh
		mov	cx,18h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,ah
		stosb				; Store al to es:[di]
		retn

fill_buffer_2		endp

disp_wipe_b:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	ax,vga_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,39h

wipe5_row_loop:
							mov	byte ptr cs:gvar_frame_timer,0
							push	cx
							mov	ax,cx
							neg	ax
							add	ax,39h
							add	ax,ax
							call	vga_operation7
							pop	ax
							push	ax
							add	ax,ax
							dec	ax
							call	vga_operation7

wipe5_frame_wait:
												cmp	byte ptr cs:gvar_frame_timer,4
												jb	wipe5_frame_wait			; Jump if below
							pop	cx
							loop	wipe5_row_loop		; Loop if cx > 0

		pop	ds
		retn

vga_operation7		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,cs:saved_di
		mov	si,ax
		xor	bh,bh			; Zero register
		call	pal_multiply_4
		mov	di,ax
		pop	ax
		cmp	ax,14h
		jae	wipe8_wide_path			; Jump if above or =
		mov	cx,2Fh
		jmp	short wipe8_col_loop_entry

wipe8_wide_path:
		mov	cx,23h
		cmp	ax,17h
		jb	wipe8_col_loop_entry			; Jump if below
		cmp	ax,1Ch
		jb	wipe8_extra_row			; Jump if below
		mov	cx,21h

wipe8_col_loop_entry:
		mov	word ptr cs:src_word_d,0

wipe8_narrow_loop:
							mov	ah,ds:ega_plane3_buf[si]
							mov	cs:src_word_c,ax
							mov	ah,byte ptr ds:scroll_plane2_off[si]
							mov	cs:src_word_b,ax
							lodsb				; String [si] to al
							xchg	ah,al
							mov	cs:src_word_a,ax
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							loop	wipe8_narrow_loop		; Loop if cx > 0

		retn

wipe8_extra_row:
		mov	cx,21h
		mov	word ptr cs:src_word_d,0

wipe8_extra_loop:
							mov	ah,ds:ega_plane3_buf[si]
							mov	cs:src_word_c,ax
							mov	ah,byte ptr ds:scroll_plane2_off[si]
							mov	cs:src_word_b,ax
							lodsb				; String [si] to al
							xchg	ah,al
							mov	cs:src_word_a,ax
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							loop	wipe8_extra_loop		; Loop if cx > 0

		mov	ah,ds:ega_plane3_buf[si]
		mov	cs:src_word_c,ax
		mov	ah,byte ptr ds:scroll_plane2_off[si]
		mov	cs:src_word_b,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:src_word_a,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosb				; Store al to es:[di]
		retn

vga_operation7		endp

disp_wipe_c:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	ax,vga_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,39h

wipe9_row_loop:
							mov	byte ptr cs:gvar_frame_timer,0
							push	cx
							mov	ax,cx
							neg	ax
							add	ax,39h
							add	ax,ax
							call	vga_operation8
							pop	ax
							push	ax
							add	ax,ax
							dec	ax
							call	vga_operation8

wipe9_frame_wait:
												cmp	byte ptr cs:gvar_frame_timer,4
												jb	wipe9_frame_wait			; Jump if below
							pop	cx
							loop	wipe9_row_loop		; Loop if cx > 0

		pop	ds
		retn

vga_operation8		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,hscroll_plane_off
		add	ax,cs:saved_di
		mov	si,ax
		add	bl,14h
		mov	bh,21h			; '!'
		call	pal_multiply_4
		mov	di,ax
		pop	ax
		cmp	ax,5Eh
		mov	cx,2Fh
		jnc	wipe9_clear_row			; Jump if carry=0
		mov	cx,7
		mov	word ptr cs:src_word_d,0

wipe9_wide_loop:
							mov	ax,ds:ega_plane3_buf[si]
							xchg	ah,al
							mov	cs:src_word_c,ax
							mov	ax,word ptr ds:scroll_plane2_off[si]
							xchg	ah,al
							mov	cs:src_word_b,ax
							lodsw				; String [si] to ax
							xchg	ah,al
							mov	cs:src_word_a,ax
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							call	pal_process_loop
							stosw				; Store ax to es:[di]
							loop	wipe9_wide_loop		; Loop if cx > 0

		mov	cx,21h

wipe9_clear_row:
		add	cx,cx
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

vga_operation8		endp

disp_fill_row:
		push	ax
		call	pal_multiply_4
		mov	di,ax
		mov	ax,vga_seg
		mov	es,ax
		pop	ax
		mov	ah,al
		mov	cx,8

fill_row_loop:
							stosw				; Store ax to es:[di]
							stosw				; Store ax to es:[di]
							stosw				; Store ax to es:[di]
							stosw				; Store ax to es:[di]
							add	di,138h
							loop	fill_row_loop		; Loop if cx > 0

		retn

vga_operation9		proc	near

palette_write_entry:
		mov	dx,30h
		mul	dx			; dx:ax = reg * ax
		add	ax,pal_r_reg		; offset to palette R register array base
		mov	si,ax
		mov	ds:cur_pal_ptr,si
		pushf				; Push flags
		cli				; Disable interrupts
		mov	si,ds:cur_pal_ptr
		mov	ax,40h
		mov	es,ax
		mov	dx,es:bios_crt_port_off
		add	dx,6
		push	dx
		in	al,dx			; port 3DAh, CGA/EGA vid status
		mov	byte ptr ds:cur_pal_idx,0
		mov	cx,10h

pal_step_loop:
							push	cx
							lodsb				; String [si] to al
							mov	bh,al
							lodsb				; String [si] to al
							mov	bl,al
							lodsb				; String [si] to al
							mov	ah,al
							push	si
							mov	si,ds:cur_pal_ptr
							mov	cx,10h

pal_dac_write_loop:
												mov	dx,3C8h
												mov	al,ds:cur_pal_idx
												out	dx,al			; port 3C8h, VGA pel address
												jmp	short $+2		; delay for I/O
												mov	dl,0C9h
												lodsb				; String [si] to al
												add	al,bh
												out	dx,al			; port 3C9h, VGA pel data reg
												jmp	short $+2		; delay for I/O
												lodsb				; String [si] to al
												add	al,bl
												out	dx,al			; port 3C9h, VGA pel data reg
												jmp	short $+2		; delay for I/O
												lodsb				; String [si] to al
												add	al,ah
												out	dx,al			; port 3C9h, VGA pel data reg
												jmp	short $+2		; delay for I/O
												inc	byte ptr ds:cur_pal_idx
												loop	pal_dac_write_loop		; Loop if cx > 0

							pop	si
							pop	cx
							loop	pal_step_loop		; Loop if cx > 0

		pop	dx
		in	al,dx			; port 3DAh, CGA/EGA vid status
		popf				; Pop flags
		retn

vga_operation9		endp

pal_step_data:					; Palette step data table (addr 3A5Fh, ref by pal_func_7)
		db	 00h, 00h, 00h, 00h, 0Fh, 0Fh	; step  0  (6B/row, RGB tris)
		db	 00h, 00h, 1Fh, 1Fh, 1Fh, 1Fh	; step  1
		db	 00h, 00h, 00h, 00h, 1Fh, 1Fh	; step  2
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step  3
		db	 07h, 07h, 07h, 0Fh, 0Fh, 0Fh	; step  4
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step  5
		db	 00h, 1Fh, 00h, 00h, 1Fh, 1Fh	; step  6
		db	 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh	; step  7
		db	 00h, 00h, 00h, 00h, 00h, 1Fh	; step  8
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step  9
		db	12 dup (1Fh)			; step 10 (white pad)
		db	 07h, 07h, 07h, 0Fh, 0Fh, 0Fh	; step 11
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 12
		db	12 dup (1Fh)			; step 13 (white pad)
		db	 00h, 00h, 00h, 00h, 00h, 1Fh	; step 14
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 15
		db	 00h, 00h, 00h, 00h, 1Fh, 1Fh	; step 16
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 17
		db	 07h, 07h, 07h, 0Fh, 0Fh, 0Fh	; step 18
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 19
		db	 00h, 1Fh, 00h, 00h, 1Fh, 1Fh	; step 20
		db	 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh	; step 21
		db	 00h, 00h, 00h, 1Fh, 00h, 00h	; step 22
		db	 00h, 00h, 1Fh, 1Fh, 1Fh, 1Fh	; step 23
		db	 00h, 00h, 1Fh, 1Fh, 1Fh, 1Fh	; step 24
		db	 00h, 00h, 00h, 1Fh, 1Fh, 1Fh	; step 25
		db	 07h, 07h, 07h, 1Fh, 1Fh, 1Fh	; step 26
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 27
		db	 00h, 1Fh, 00h, 00h, 1Fh, 1Fh	; step 28
		db	 1Fh, 1Fh, 00h, 0Fh, 0Fh, 0Fh	; step 29
		db	 00h, 00h, 00h, 00h, 00h, 0Fh	; step 30
		db	 0Fh, 00h, 00h, 0Fh, 00h, 0Fh	; step 31
		db	 00h, 0Fh, 0Fh, 00h, 0Fh, 0Fh	; step 32
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 33
		db	 07h, 07h, 07h, 00h, 00h, 1Fh	; step 34
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 35
		db	 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh	; step 36
		db	 0Fh, 0Fh, 00h, 1Fh, 1Fh, 1Fh	; step 37
		db	 00h, 00h, 00h, 00h, 00h, 1Fh	; step 38
		db	 1Fh, 00h, 00h, 00h, 0Fh, 0Fh	; step 39
		db	 00h, 1Fh, 00h, 00h, 1Fh, 1Fh	; step 40
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 41
		db	 07h, 07h, 07h, 00h, 00h, 1Fh	; step 42
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 43
		db	 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh	; step 44
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 45
		db	 00h, 00h, 00h, 00h, 00h, 1Fh	; step 46
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 47
		db	 00h, 00h, 00h, 00h, 1Fh, 1Fh	; step 48
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 49
		db	 07h, 07h, 07h, 00h, 00h, 1Fh	; step 50
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 51
		db	 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh	; step 52
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 53
		db	 00h, 00h, 00h, 00h, 00h, 1Fh	; step 54
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 55
		db	 00h, 1Fh, 00h, 00h, 1Fh, 1Fh	; step 56
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 57
		db	 07h, 07h, 07h, 0Fh, 0Fh, 0Fh	; step 58
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 59
		db	12 dup (1Fh)			; step 60 (white pad)
		db	 00h, 00h, 00h, 00h, 00h, 1Fh	; step 61
		db	 1Fh, 00h, 00h, 00h, 1Fh, 00h	; step 62
		db	 00h, 00h, 00h, 00h, 1Fh, 1Fh	; step 63
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 64
		db	 07h, 07h, 07h, 00h, 00h, 1Fh	; step 65
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 66
		db	 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh	; step 67
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 68
		db	 00h, 00h, 00h, 00h, 00h, 1Fh	; step 69
		db	 1Fh, 00h, 00h, 0Fh, 00h, 00h	; step 70
		db	 00h, 1Fh, 00h, 1Fh, 00h, 00h	; step 71
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 72
		db	 07h, 07h, 07h, 00h, 00h, 1Fh	; step 73
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh	; step 74
		db	 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh	; step 75
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh	; step 76

pal_process_loop		proc	near
		push	cx
		mov	cx,2

pal_process_inner:
							rol	word ptr cs:src_word_d,1	; Rotate
							adc	ax,ax
							rol	word ptr cs:src_word_c,1	; Rotate
							adc	ax,ax
							rol	word ptr cs:src_word_b,1	; Rotate
							adc	ax,ax
							rol	word ptr cs:src_word_a,1	; Rotate
							adc	ax,ax
							rol	word ptr cs:src_word_d,1	; Rotate
							adc	ax,ax
							rol	word ptr cs:src_word_c,1	; Rotate
							adc	ax,ax
							rol	word ptr cs:src_word_b,1	; Rotate
							adc	ax,ax
							rol	word ptr cs:src_word_a,1	; Rotate
							adc	ax,ax
							loop	pal_process_inner		; Loop if cx > 0

		xchg	ah,al
		pop	cx
		retn

pal_process_loop		endp

pal_func_21		proc	near
		rol	word ptr cs:mask_word,1	; Rotate
		sbb	al,al
		rol	word ptr cs:mask_word,1	; Rotate
		sbb	ah,ah
		or	al,ah
		rol	word ptr cs:mask_word,1	; Rotate
		sbb	dl,dl
		rol	word ptr cs:mask_word,1	; Rotate
		sbb	ah,ah
		or	ah,dl
		retn

pal_func_21		endp

disp_clear_render_buf:
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		xor	ax,ax			; Zero register
		mov	di,cga_buf_start
		mov	cx,8000h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
		db	 2Eh,0FFh, 26h, 22h, 20h	; jmp word ptr cs:[2022h] (dispatch)

pal_multiply_4		proc	near
		mov	dl,bl
		mov	bl,bh
		xor	bh,bh			; Zero register
		mov	dh,bh
		add	bx,bx
		add	bx,bx
		mov	ax,140h
		mul	dx			; dx:ax = reg * ax
		add	ax,bx
		retn

pal_multiply_4		endp

		db	0C3h					; retn (end of dispatch stub)
		db	2900 dup (0)
pixel_plane_c_buf	db	0			; Third pixel plane buffer (used in disp_pixel_sort as ES:pixel_plane_c_buf[di])
		db	392 dup (0)

seg_a		ends

		end	start
