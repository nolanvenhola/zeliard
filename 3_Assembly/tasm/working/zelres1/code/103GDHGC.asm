
PAGE  59,132

;==========================================================================
;
;  IMAGE_DECODE - 103GDHGC Sprite/Image Renderer (zelres1 chunk 4, gdhgc.bin)
;
;  HGC variant of the in-game image / sprite controller. Loaded by
;  game.bin into the game segment (gfx_mode_tbl_all entry, mode 3) when
;  Hercules mode is selected. Provides sprite blit, scroll, palette, and
;  screen primitives used by 100OPDMO opening/title and 106TOWN
;  town/dungeon code.
;
;  Connections:
;    Loads:        none (rendering primitives only)
;    Calls into:   render_fn_ptr (CS dispatch slot, set by caller),
;                  hgc_dispatch_fn (mode-table jmp)
;    Called by:    game.bin LOAD_CHUNK chunk_ref_gdhgc via gfx_mode_tbl_all
;                  (loaded_code_a CS:0x3000 entry for graphics-driver init);
;                  100OPDMO + 106TOWN invoke gfx_init/draw/update/palette
;                  thunks that resolve into this chunk
;    Reads/writes: gvar_frame_timer (FF1A), gvar_game_seg (FF2C)
;                  - zeliad-owned shared globals
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr1com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
gvar_frame_timer	equ	0FF1Ah			;* Global frame timer counter
gvar_game_seg	equ	0FF2Ch			;* Global game data segment

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
; restored after factoring (consensus value, but not all files agree):
sprite_row_buf_b         equ     5500h
sprite_mask_off          equ     1A8Eh
hgc_seg		equ	0B000h                  ; Hercules Graphics Card framebuffer segment
hgc_plane2_off	equ	240h                    ; Offset to second HGC interlace plane
hgc_dispatch_fn	equ	2022h			;* Dispatch function table
hgc_plane2_buf	equ	2050h			;* Second render plane buffer
hgc_plane3_buf	equ	29DCh			;* Third render plane buffer
hgc_plane_stride	equ	2A80h			;* Stride between HGC planes
hgc_mask_tbl_a	equ	32BBh			;* First blit mask table (even passes)
hgc_mask_tbl_b	equ	32CBh			;* Second blit mask table (odd passes)
sprite_src_tbl	equ	3645h			;* Sprite source frame pointer table
sprite_frame_tbl	equ	3647h			;* Sprite animation frame index table
move_seq_horiz	equ	3ACBh			;* Horizontal movement sequence data
move_seq_up	equ	3B8Fh			;* Vertical (up) movement sequence data
color_pair_tbl	equ	3BC2h			;* Color pair lookup table
hgc_palette_xlat	equ	44F5h			;* Palette translation table (HGC)
hgc_color_lut	equ	4C23h			;* Color lookup table (HGC)
render_lut_ptr	equ	4C52h			;* Pointer into color lookup table for current render
cur_col_ctr	equ	4C5Ch			;* Current column counter within blit pass
cur_row_ctr	equ	4C5Dh			;* Current row counter (pass index)
cur_pass_ctr	equ	4C5Eh			;* Current pass counter (outer blit loop)
render_fn_ptr	equ	4C60h			;* Pointer to active render sub-function
saved_di	equ	4C62h			;* Saved destination offset (DI)
saved_es	equ	4C64h			;* Saved destination segment (ES)
sprite_row_buf	equ	4F86h			;* Sprite row render buffer
hgc_bank1_end_m1	equ	5FA6h			;* HGC bank wrap adjust for reverse direction
hgc_bank2_wrap	equ	0A05Ah			;* HGC offset added when DI wraps past bank1_end
font_ptr_a	equ	0F500h			;* Font bitmap data pointer
hgc_work_buf	equ	4000h			;* HGC working render buffer base
hgc_work_buf_p2	equ	4050h			;* HGC working render buffer plane 2
hgc_capture_src	equ	232Fh                   ; HGC capture source offset
hgc_bank1_end	equ	6000h                   ; HGC bank 1 end boundary (4 x 2000h banks)
hgc_bank2_base_m1	equ	0A059h                  ; HGC bank2 base minus 1 (stosb target before wrap)
hgc_bank2_wrap_b	equ	0A05Ah                  ; HGC bank2 wrap offset (byte-path alias)
hgc_bank2_wrap_w	equ	0A058h                  ; HGC bank2 wrap offset after stosw (word-path)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
src_word_a	equ	4C54h			;* Render source word A (plane 0)
src_word_b	equ	4C56h			;* Render source word B (plane 1)
src_word_c	equ	4C58h			;* Render source word C (plane 2)
src_word_d	equ	4C5Ah			;* Render source word D (plane 3)
render_mode_flag	equ	4C5Fh			;* Render mode: 0=overwrite, FF=mask-blend

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
hgc_screen_start	equ	0                       ; HGC framebuffer start offset (DI init)
hgc_buf_start	equ	0			;* HGC render buffer start (DI init, screen)
hgc_buf_reset	equ	0			;* HGC source buffer reset value (SI init)

; Macro: advance DI by 0x2000 (one HGC interlaced bank) and check bank boundary.
; Jumps to no_wrap_label if DI stays within bank 1 (< hgc_bank1_end).
; Falls through when bank wrap needed (caller must handle the wrap case).
hgc_advance_di	macro	no_wrap_label
		add	di,2000h		; next HGC interlaced bank row
		cmp	di,hgc_bank1_end	; past bank 1 boundary?
		jb	no_wrap_label		; no: continue in bank 1
endm
; Macro: advance DI by 0x2000 and check bank boundary (wrap-path variant).
; Jumps to wrap_label when DI >= hgc_bank1_end (bank wrap needed).
; Falls through when no wrap needed.
hgc_advance_di_wrap	macro	wrap_label
		add	di,2000h		; next HGC interlaced bank row
		cmp	di,hgc_bank1_end	; past bank 1 boundary?
		jae	wrap_label		; yes: handle wrap
endm
; Macro: write one masked pixel to HGC with interlaced bank wrapping.
; Loads next byte from SI, masks with cur_row_ctr, OR with [SI+3] pattern,
; stores to ES:DI, advances DI by 0x1FFF. If DI >= hgc_bank1_end writes
; again (bank wrap) and adds hgc_bank2_base_m1 offset.
; next_label: label to jump to when no bank wrap needed (skips wrap path).
hgc_write_pixel	macro	next_label
		lodsb				; pixel byte from pattern table
		and	al,cs:cur_row_ctr	; apply color mask
		or	al,[si+3]		; OR background pattern
		stosb				; write to HGC framebuffer
		add	di,1FFFh		; advance to next interlaced bank row
		cmp	di,hgc_bank1_end	; past bank 1 end?
		jb	next_label		; no: skip wrap
		stosb				; yes: write to bank 2 as well
		add	di,hgc_bank2_base_m1	; advance past bank boundary
endm
; SET_ES_3000
;   Compute ES = CS + 3000h (load ES with the +3000h work-buffer segment).
SET_ES_3000	MACRO
		mov	ax, cs
		add	ax, 3000h
		mov	es, ax
		ENDM
; EXPAND_CH_BYTE
;   Save CX, then CX = CH zero-extended (CH bytes count).
;   Used at the entry of each blit row helper.
EXPAND_CH_BYTE	MACRO
		push	cx
		mov	cl, ch
		xor	ch, ch
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

run_hgc_gfx_driver_main	proc	far

start:
		retf	1Fh			; Return far - dispatch table entry 0 (module init/reset)
		; HGC driver dispatch table (encoded far-call targets; Sourcer cannot decode as x86)
		db	 00h, 2Bh, 4Ch, 32h, 30h, 78h	; dispatch words: 2B00h, 324Ch, 7830h
		db	 30h,0C2h, 30h, 7Ah, 42h,0D8h	; dispatch words: C230h, 7A30h, D842h
		db	 4Bh,0DBh, 32h, 33h, 33h,0CAh	; dispatch words: DB4Bh, 3332h, CA33h
		db	 33h, 4Ah, 34h, 65h, 36h,0B1h	; dispatch words: 4A33h, 6534h, B136h
		db	 36h, 2Bh, 4Ch,0DAh, 30h,0FDh	; dispatch words: 2B36h, DA4Ch, FD30h
		db	 36h, 7Fh, 37h, 7Dh, 38h,0C5h	; dispatch words: 7F36h, 7D37h, C538h
		db	 3Bh, 30h, 3Dh, 49h, 3Eh, 9Fh	; dispatch words: 303Bh, 493Dh, 9F3Eh
		db	 3Eh, 9Ch, 40h,0A6h, 41h, 56h	; dispatch words: 9C3Eh, A640h, 5641h
		db	 42h, 13h, 4Ch, 50h, 53h, 51h	; dispatch words: 1342h, 504Ch + push bx,cx
		db	 1Eh, 8Ah,0C5h,0F6h,0E1h, 8Bh	; push ds; mov al,ch; mul cl; mov bp,...
		db	0E8h, 06h, 1Fh, 8Bh,0F7h, 8Ch	; ...ax; push es; pop ds; mov si,di; mov ax,...
		db	0C8h, 05h, 00h, 30h, 8Eh,0C0h	; ...cs; add ax,3000h; mov es,ax
		db	0BFh, 00h, 00h, 2Eh,0C7h, 06h	; mov di,0; mov word ptr cs:[4C56h],...
		db	 56h, 4Ch, 00h, 00h, 2Eh,0C7h	; ...0; mov word ptr cs:[4C58h],...
		db	 06h, 58h, 4Ch, 00h, 00h, 8Bh	; ...0; mov cx,bp
		db	0CDh,0D1h,0E9h			; mov cx,bp; shr cx,1 -> blit_plane_a_loop

blit_plane_a_loop:
								mov	ax,ds:[bp+si]
								mov	cs:src_word_d,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosw				; Store ax to es:[di]
								loop	blit_plane_a_loop		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		pop	ax
		mov	di,0
		jmp	blit_dispatch_done

render_ab_init_entry:
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

blit_plane_ab_loop:
								add	bp,bp
								mov	ax,ds:[bp+si]
								mov	cs:src_word_c,ax
								shr	bp,1			; Shift w/zeros fill
								mov	ax,ds:[bp+si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosw				; Store ax to es:[di]
								loop	blit_plane_ab_loop		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		pop	ax
		mov	di,0
		jmp	blit_dispatch_done

render_plane_a_blit_entry:
		push	ds
		push	ax
		push	es
		push	di
		call	math_calc
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,32A6h
		call	run_render_passes_hgc
		pop	ds
		retn

render_plane_c_entry:
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
		mov	word ptr cs:src_word_a,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

blit_plane_c_loop:
								mov	ax,ds:[bp+si]
								mov	cs:src_word_c,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_b,ax
								call	copy_status_loop_hgc
								stosw				; Store ax to es:[di]
								loop	blit_plane_c_loop		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		xor	ax,ax			; Zero register
		mov	di,0
		push	ds
		push	ax
		push	es
		push	di
		call	math_calc
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,3256h
		mov	byte ptr cs:render_mode_flag,0
		or	al,al			; Zero ?
		jnz	blit_c_second_pass			; Jump if not zero
		call	run_render_passes_hgc

blit_c_second_pass:
		mov	byte ptr cs:render_mode_flag,0FFh
		call	run_render_passes_hgc
		pop	ds
		retn

blit_dispatch_done:
		push	ds
		push	ax
		push	es
		push	di
		call	math_calc
		add	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:render_fn_ptr,3219h
		mov	byte ptr cs:render_mode_flag,0
		or	al,al			; Zero ?
		jnz	blit_dispatch_second			; Jump if not zero
		call	run_render_passes_hgc

blit_dispatch_second:
		mov	byte ptr cs:render_mode_flag,0FFh
		call	run_render_passes_hgc
		pop	ds
		retn

run_hgc_gfx_driver_main	endp

run_render_passes_hgc		proc	near
		mov	byte ptr cs:cur_row_ctr,0
		mov	ax,hgc_seg
		mov	es,ax
		mov	bp,8

render_pass_top:
		mov	al,cs:cur_row_ctr
		mov	cs:cur_col_ctr,al
		mov	byte ptr cs:gvar_frame_timer,0
		push	cx
		push	si
		push	di

render_col_loop:
								mov	bl,cs:cur_col_ctr
								and	bx,7
								add	bx,bx
								mov	bx,cs:hgc_mask_tbl_a[bx]
								push	bx
								call	word ptr cs:render_fn_ptr
								pop	bx
								inc	byte ptr cs:cur_col_ctr
								hgc_advance_di	render_col_next_row			; Jump if below
								call	word ptr cs:render_fn_ptr
								add	di,hgc_bank2_wrap

render_col_next_row:
								mov	al,ch
								xor	ah,ah			; Zero register
								add	si,ax
								dec	cl
								jz	render_col_done			; Jump if zero
								mov	bl,cs:cur_col_ctr
								and	bx,7
								add	bx,bx
								mov	bx,cs:hgc_mask_tbl_b[bx]
								push	bx
								call	word ptr cs:render_fn_ptr
								pop	bx
								inc	byte ptr cs:cur_col_ctr
								hgc_advance_di	render_col_odd_next			; Jump if below
								call	word ptr cs:render_fn_ptr
								add	di,hgc_bank2_wrap

render_col_odd_next:
								mov	al,ch
								xor	ah,ah			; Zero register
								add	si,ax
								dec	cl
								jnz	render_col_loop			; Jump if not zero

render_col_done:
		pop	di
		pop	si
		pop	cx
		inc	byte ptr cs:cur_row_ctr

render_wait_timer:
								cmp	byte ptr cs:gvar_frame_timer,14h
								jb	render_wait_timer			; Jump if below
		dec	bp
		jz	render_func_done		; Jump if zero
		jmp	render_pass_top

render_func_done:
		retn

run_render_passes_hgc		endp

render_mask_blend_entry:
		test	byte ptr cs:render_mode_flag,0FFh
		jz	render_overwrite_entry			; Jump if zero
		push	si
		push	di
		push	cx
		mov	dx,bx
		not	bx
		mov	cl,ch
		xor	ch,ch			; Zero register

render_mask_blend_loop:
								and	es:[di],bl
								lodsb				; String [si] to al
								and	al,dl
								or	es:[di],al
								inc	di
								xchg	dh,dl
								xchg	bh,bl
								loop	render_mask_blend_loop		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn

render_overwrite_entry:
		push	si
		push	di
		EXPAND_CH_BYTE

render_overwrite_loop:
								lodsb				; String [si] to al
								and	al,bl
								or	es:[di],al
								inc	di
								xchg	bh,bl
								loop	render_overwrite_loop		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn

render_expand_entry:
		test	byte ptr cs:render_mode_flag,0FFh
		jz	render_overwrite2_entry			; Jump if zero
		push	si
		push	di
		EXPAND_CH_BYTE

render_expand_loop:
								push	cx
								lodsb				; String [si] to al
								mov	ah,al
								mov	dl,3
								mov	cx,4

render_expand_bits:
														test	ah,dl
														jz	render_expand_bit_set			; Jump if zero
														or	ah,dl

render_expand_bit_set:
														add	dl,dl
														add	dl,dl
														loop	render_expand_bits		; Loop if cx > 0

								and	ah,bl
								not	ah
								and	es:[di],ah
								and	al,bl
								or	es:[di],al
								inc	di
								xchg	bh,bl
								pop	cx
								loop	render_expand_loop		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn

render_overwrite2_entry:
		push	si
		push	di
		EXPAND_CH_BYTE

render_overwrite2_loop:
								lodsb				; String [si] to al
								and	al,bl
								or	es:[di],al
								inc	di
								xchg	bh,bl
								loop	render_overwrite2_loop		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn

render_clear_entry:
		push	di
		push	cx
		not	bx
		mov	cl,ch
		xor	ch,ch			; Zero register

render_clear_loop:
								and	es:[di],bl
								inc	di
								xchg	dh,dl
								xchg	bh,bl
								loop	render_clear_loop		; Loop if cx > 0

		pop	cx
		pop	di
		retn
		; HGC 2bpp bitmask pattern table (00h/03h/0Ch/30h/0C0h = black..white columns)
		db	 00h,0C0h, 00h, 0Ch,0C0h, 00h	; bitmask row 0
		db	 0Ch, 00h, 00h, 30h, 00h, 03h	; bitmask row 1
		db	 30h, 00h, 03h, 00h, 03h, 00h	; bitmask row 2
		db	 30h, 00h, 00h, 03h, 00h, 30h	; bitmask row 3
		db	 0Ch, 00h,0C0h, 00h, 00h, 0Ch	; bitmask row 4
		; Inline dispatch entry (machine code not decoded by Sourcer)
		db	 00h,0C0h, 0Eh, 07h,0BFh, 66h	; bitmask row 5 tail + push cs;pop es; mov di,...
		db	 4Ch, 33h,0C0h,0B9h, 90h, 01h	; mov di,4C66h; xor ax,ax; mov cx,190h
		db	0F3h,0ABh,0BFh			; rep stosw; mov di,...
		db	 66h, 4Ch			; ...4C66h (operand) -> text_char_loop

text_char_loop:
								lodsb				; String [si] to al
								cmp	al,0FFh
								jne	text_char_check_printable			; Jump if not equal
								retn

text_char_check_printable:
								sub	al,20h			; ' '
								jnc	text_char_render			; Jump if carry=0
								retn

text_char_render:
								jz	text_char_advance			; Jump if zero
								push	si
								push	di
								xor	ah,ah			; Zero register
								add	ax,ax
								add	ax,ax
								add	ax,ax
								add	ax,ds:font_ptr_a
								mov	si,ax
								mov	cx,8

text_char_row_loop:
														push	cx
														lodsb				; String [si] to al
														call	build_pixel_pair_hgc
														mov	es:[di],dx
														add	di,50h
														pop	cx
														loop	text_char_row_loop		; Loop if cx > 0

								pop	di
								pop	si

text_char_advance:
								add	di,2
								jmp	short text_char_loop

build_pixel_pair_hgc		proc	near
		mov	cx,8

pixel_expand_bits:
								add	al,al
								adc	bx,bx
								add	bx,bx
								loop	pixel_expand_bits		; Loop if cx > 0

		mov	dx,bx
		shr	dx,1			; Shift w/zeros fill
		or	dx,bx
		xchg	dh,dl
		retn

build_pixel_pair_hgc		endp

scroll_row_entry:
		push	ds
		push	cx
		push	bx
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,4C66h
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
		mov	di,hgc_work_buf
		mov	si,hgc_work_buf_p2
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
		call	math_calc
		mov	di,ax
		pop	bx
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	si,ax
		add	si,0
		mov	bp,ax
		add	bp,hgc_work_buf
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	ax,hgc_seg
		mov	es,ax
		pop	cx
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

scroll_row_loop:
								push	cx
								call	mask_write_loop_hgc
								hgc_advance_di	scroll_row_wrap			; Jump if below
								call	mask_write_loop_hgc
								add	di,hgc_bank2_wrap_b

scroll_row_wrap:
								add	bp,bx
								add	si,bx
								pop	cx
								loop	scroll_row_loop		; Loop if cx > 0

		pop	ds
		retn

mask_write_loop_hgc		proc	near
		push	di
		push	si
		push	bp
		mov	cx,bx
		shr	cx,1			; Shift w/zeros fill

copy_or_words_loop:
								lodsw				; String [si] to ax
								or	ax,ds:[bp]
								stosw				; Store ax to es:[di]
								inc	bp
								inc	bp
								loop	copy_or_words_loop		; Loop if cx > 0

		pop	bp
		pop	si
		pop	di
		retn

mask_write_loop_hgc		endp

render_plane_ab_entry:
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

render_ab_inner_loop:
								add	bp,bp
								mov	ax,ds:[bp+si]
								mov	cs:src_word_c,ax
								shr	bp,1			; Shift w/zeros fill
								mov	ax,ds:[bp+si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosw				; Store ax to es:[di]
								loop	render_ab_inner_loop		; Loop if cx > 0

		pop	cx
		pop	bx
		pop	ax
		pop	ds

blit_to_hgc_entry:
		push	ds
		call	math_calc
		mov	di,ax
		mov	si,hgc_buf_reset
		push	es
		pop	ds
		mov	ax,hgc_seg
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

blit_hgc_row_loop:
								push	cx
								push	si
								push	di
								mov	cx,bx
								rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
								pop	di
								pop	si
								hgc_advance_di	blit_hgc_row_next			; Jump if below
								push	si
								push	di
								mov	cx,bx
								rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
								pop	di
								pop	si
								add	di,hgc_bank2_wrap

blit_hgc_row_next:
								add	si,bx
								pop	cx
								loop	blit_hgc_row_loop		; Loop if cx > 0

		pop	ds
		retn

sprite_init_entry:
		push	cs
		pop	es
		mov	di,sprite_obj_tbl
		xor	dx,dx			; Zero register
		mov	cx,9

sprite_tbl_init_loop:
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
								loop	sprite_tbl_init_loop		; Loop if cx > 0

		mov	byte ptr ds:gvar_frame_timer,0

sprite_update_top:
		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_update_entry:
		push	cx
		test	byte ptr [si],0FFh
		jz	sprite_update_next			; Jump if zero
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
		mov	dl,al
		mov	al,[si+3]
		add	al,[si+9]
		mov	[si+3],al
		xor	dh,dh			; Zero register
		add	dx,5
		push	dx
		xor	ah,ah			; Zero register
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
		pop	dx
		add	ax,dx
		mov	[si+5],ax
		mov	di,ax
		mov	bp,[si+1]
		push	ds
		push	si
		mov	ax,hgc_seg
		mov	ds,ax
		SET_ES_3000
		mov	si,di
		mov	di,bp
		call	copy_pixel_row_hgc
		pop	si
		pop	ds

sprite_update_next:
		pop	cx
		add	si,0Fh
		loop	sprite_update_continue		; Loop if cx > 0

		jmp	short sprite_draw_start

sprite_update_continue:
		jmp	sprite_update_entry

sprite_draw_start:
		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_draw_loop:
								push	cx
								test	byte ptr cs:[si],0FFh
								jz	sprite_draw_next			; Jump if zero
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
								jae	sprite_draw_next			; Jump if above or =
								cmp	al,0A0h
								jae	sprite_draw_next			; Jump if above or =
								mov	[si],dl
								mov	di,[si+5]
								push	ds
								push	si
								mov	ax,hgc_seg
								mov	es,ax
								mov	ds,cs:gvar_game_seg
								mov	si,bp
								call	blit_sprite_hgc
								pop	si
								pop	ds

sprite_draw_next:
								pop	cx
								add	si,0Fh
								loop	sprite_draw_loop		; Loop if cx > 0

sprite_wait_timer:
								cmp	byte ptr cs:gvar_frame_timer,1Eh
								jb	sprite_wait_timer			; Jump if below
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
								mov	ax,hgc_seg
								mov	es,ax
								mov	ax,cs
								add	ax,3000h
								mov	ds,ax
								mov	si,bp
								call	copy_to_di_hgc
								pop	si
								pop	ds
								pop	cx
								add	si,0Fh
								loop	sprite_restore_loop		; Loop if cx > 0

		mov	si,sprite_obj_tbl
		mov	cx,9

sprite_active_check:
								test	byte ptr [si],0FFh
								jz	sprite_all_done			; Jump if zero
								jmp	sprite_update_top

sprite_all_done:
								add	si,0Fh
								loop	sprite_active_check		; Loop if cx > 0

		retn

copy_pixel_row_hgc		proc	near
		push	si
		push	cx

copy_buf_row:
								push	si
								EXPAND_CH_BYTE
								rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
								pop	cx
								pop	si
								add	si,2000h
								cmp	si,hgc_bank1_end
								jb	copy_buf_row_next			; Jump if below
								add	si,hgc_bank2_wrap

copy_buf_row_next:
								dec	cl
								jnz	copy_buf_row			; Jump if not zero
		pop	cx
		pop	si
		retn

copy_pixel_row_hgc		endp

copy_to_di_hgc		proc	near
		push	di
		push	cx

copy_buf2_row:
								EXPAND_CH_BYTE
								push	si
								push	di
								push	cx
								rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
								pop	cx
								pop	di
								pop	si
								hgc_advance_di	copy_buf2_row_next			; Jump if below
								push	si
								push	di
								push	cx
								rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
								pop	cx
								pop	di
								pop	si
								add	di,hgc_bank2_wrap

copy_buf2_row_next:
								add	si,cx
								pop	cx
								dec	cl
								jnz	copy_buf2_row			; Jump if not zero
		pop	cx
		pop	di
		retn

copy_to_di_hgc		endp

blit_sprite_hgc		proc	near
		push	di
		push	cx
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bx,ax
		mov	word ptr cs:src_word_d,0
		mov	word ptr cs:src_word_c,0

multiply_row_loop:
								EXPAND_CH_BYTE
								call	blit_via_di_hgc
								hgc_advance_di	multiply_row_wrap			; Jump if below
								call	blit_via_di_hgc
								add	di,hgc_bank2_wrap

multiply_row_wrap:
								add	si,cx
								pop	cx
								dec	cl
								jnz	multiply_row_loop			; Jump if not zero
		pop	cx
		pop	di
		retn

blit_sprite_hgc		endp

blit_via_di_hgc		proc	near
		push	di
		push	si
		push	cx

process3_pixel_loop:
								xor	ah,ah			; Zero register
								mov	al,[bx+si]
								mov	cs:src_word_b,ax
								lodsb				; String [si] to al
								mov	cs:src_word_a,ax
								push	bx
								call	copy_status_loop_hgc
								pop	bx
								or	es:[di],al
								inc	di
								loop	process3_pixel_loop		; Loop if cx > 0

		pop	cx
		pop	si
		pop	di
		retn

blit_via_di_hgc		endp

		; Inline dispatch entry + hgc_lookup_data_3 block (machine code + render plane source table)
		db	 00h, 90h, 20h, 06h, 80h, 91h	; CRTC pairs: (00,90) (20,06) (80,91)
		db	 20h, 06h, 00h, 93h, 20h, 06h	; CRTC pairs: (20,06) (00,93) (20,06)
		db	 80h, 94h, 20h, 06h, 00h, 96h	; CRTC pairs: (80,94) (20,06) (00,96)
		db	 18h, 04h,0C0h, 96h, 18h	; CRTC pairs: (18,04) (C0,96) + half (18..)
hgc_lookup_data_3		dw	8004h			; Data table (indexed access)
		db	 97h, 18h, 04h, 40h, 98h, 18h	; CRTC pairs: (..97) (18,04) (40,98) (18..)
		db	 04h, 1Eh, 53h, 32h,0E4h,0BAh	; CRTC tail + push ds; push bx; xor ah; mov dx
		db	0C0h, 0Ch,0F7h,0E2h, 05h, 40h	; ...,0CC0h; mul dx; add ax,4000h
		db	0ABh, 2Eh, 8Eh, 1Eh, 2Ch,0FFh	; stosw; mov ds,[cs:gvar]; sub al,FFh
		db	 8Bh,0F0h, 8Ch,0C8h, 05h, 00h	; mov si,ax; mov ax,cs; add ax,...
		db	 30h, 8Eh,0C0h,0BFh, 00h, 00h	; ...3000h; mov es,ax; mov di,0
		db	 2Eh,0C7h, 06h, 5Ah, 4Ch, 00h	; mov word ptr cs:[4C5Ah],...
		db	 00h, 2Eh,0C7h, 06h, 58h, 4Ch	; ...0; mov word ptr cs:[4C58h],...
		db	 00h, 00h,0B9h, 30h, 03h	; ...0; mov cx,330h -> render_words_loop

render_words_loop:
								mov	ax,hgc_lookup_data_3[si]
								mov	cs:src_word_a,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_b,ax
								call	copy_status_loop_hgc
								stosw				; Store ax to es:[di]
								loop	render_words_loop		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,0
		mov	cx,2230h
		jmp	blit_to_hgc_entry

sprite_img_blit_entry:
		push	ds
		push	bx
		xor	ah,ah			; Zero register
		mov	dx,480h
		mul	dx			; dx:ax = reg * ax
		add	ax,97C0h
		mov	ds,cs:gvar_game_seg
		mov	si,ax
		SET_ES_3000
		mov	di,0
		mov	word ptr cs:src_word_d,0
		mov	word ptr cs:src_word_c,0
		mov	cx,120h

sprite_img_decode_loop:
								mov	ax,ds:hgc_plane2_off[si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosw				; Store ax to es:[di]
								loop	sprite_img_decode_loop		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,hgc_screen_start
		mov	cx,1220h
		jmp	blit_to_hgc_entry
		db	 33h,0DBh,0B9h, 19h, 00h	; Inline dispatch stub (5 bytes)

map_tile_row_loop:
								push	cx
								mov	cx,22h

map_tile_col_loop:
														push	cx
														lodsb				; String [si] to al
														push	bx
														push	ds
														push	si
														call	compute_tile_vram_offset_hgc
														pop	si
														pop	ds
														pop	bx
														inc	bh
														pop	cx
														loop	map_tile_col_loop		; Loop if cx > 0

								xor	bh,bh			; Zero register
								inc	bl
								pop	cx
								loop	map_tile_row_loop		; Loop if cx > 0

		retn

compute_tile_vram_offset_hgc		proc	near
		mov	ds,cs:gvar_game_seg
		mov	dx,cs
		add	dx,2000h
		mov	es,dx
		xor	ah,ah			; Zero register

div_row_compute:
								sub	al,28h			; '('
								jc	div_row_done			; Jump if carry Set
								inc	ah
								jmp	short div_row_compute

div_row_done:
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

tile_row_copy_loop:
														movsb				; Mov [si] to es:[di]
														add	di,21h
														add	si,27h
														loop	tile_row_copy_loop		; Loop if cx > 0

								pop	si
								pop	di
								add	di,1A90h
								add	si,640h
								pop	cx
								loop	tile_plane_loop		; Loop if cx > 0

		retn

compute_tile_vram_offset_hgc		endp

char_row_render_entry:
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

bit_reverse_inner:
														ror	al,1			; Rotate
														adc	ah,ah
														dec	dx
														jnz	bit_reverse_inner			; Jump if not zero
								mov	es:[di],ah
								inc	di
								loop	bit_reverse_loop		; Loop if cx > 0

		pop	si
		pop	ax
		mov	bl,al
		xor	bh,bh			; Zero register
		call	math_calc
		mov	di,ax
		mov	ax,hgc_seg
		mov	es,ax
		push	di
		push	di
		push	si
		mov	cx,11h

sprite_row_fwd_loop:
								lodsw				; String [si] to ax
								mov	cs:src_word_b,ax
								mov	ax,ds:sprite_mask_off[si]
								mov	cs:src_word_c,ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								or	es:[di],ax
								inc	di
								inc	di
								loop	sprite_row_fwd_loop		; Loop if cx > 0

		pop	si
		pop	di
		hgc_advance_di	sprite_row_fwd_done			; Jump if below
		mov	cx,11h

sprite_row_fwd_wrap:
								lodsw				; String [si] to ax
								mov	cs:src_word_b,ax
								mov	ax,ds:sprite_mask_off[si]
								mov	cs:src_word_c,ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								or	es:[di],ax
								inc	di
								inc	di
								loop	sprite_row_fwd_wrap		; Loop if cx > 0

sprite_row_fwd_done:
		pop	di
		add	di,4Eh
		push	cs
		pop	ds
		push	di
		mov	si,sprite_row_buf
		mov	cx,11h

sprite_row_rev_loop:
								lodsw				; String [si] to ax
								xchg	ah,al
								mov	cs:src_word_b,ax
								mov	ax,[si+20h]
								xchg	ah,al
								mov	cs:src_word_c,ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								or	es:[di],ax
								dec	di
								dec	di
								loop	sprite_row_rev_loop		; Loop if cx > 0

		pop	di
		hgc_advance_di	sprite_row_rev_done			; Jump if below
		mov	si,sprite_row_buf
		mov	cx,11h

sprite_row_rev_wrap:
								lodsw				; String [si] to ax
								xchg	ah,al
								mov	cs:src_word_b,ax
								mov	ax,[si+20h]
								xchg	ah,al
								mov	cs:src_word_c,ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								or	es:[di],ax
								dec	di
								dec	di
								loop	sprite_row_rev_wrap		; Loop if cx > 0

sprite_row_rev_done:
		pop	ds
		retn

trail_render_entry:
		mov	bx,ax
		mov	al,ds:color_pair_tbl[bx]
		mov	ds:cur_row_ctr,al
		mov	ax,hgc_seg
		mov	es,ax
		mov	di,hgc_palette_xlat
		mov	si,move_seq_horiz

trail_horiz_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	trail_vert_start			; Jump if zero
								call	blit_clipped_alt_hgc
								add	di,205Ah
								cmp	di,hgc_bank1_end
								jb	trail_horiz_next			; Jump if below
								add	di,hgc_bank2_wrap

trail_horiz_next:
								jmp	short trail_horiz_loop

trail_vert_start:
		sub	di,2059h
		jnc	trail_vert_loop			; Jump if carry=0
		add	di,hgc_bank1_end_m1

trail_vert_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	trail_horiz_back_start			; Jump if zero
								call	blit_clipped_alt_hgc
								inc	di
								jmp	short trail_vert_loop

trail_horiz_back_start:
		sub	di,205Bh
		jnc	trail_horiz_back_loop			; Jump if carry=0
		add	di,hgc_bank1_end_m1

trail_horiz_back_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	trail_vert_back_start			; Jump if zero
								call	blit_clipped_alt_hgc
								sub	di,205Ah
								jnc	trail_horiz_back_next			; Jump if carry=0
								add	di,hgc_bank1_end_m1

trail_horiz_back_next:
								jmp	short trail_horiz_back_loop

trail_vert_back_start:
		add	di,2059h
		cmp	di,hgc_bank1_end
		jb	trail_vert_back_loop			; Jump if below
		add	di,hgc_bank2_wrap

trail_vert_back_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	trail_vert_back_next			; Jump if zero
								call	blit_clipped_alt_hgc
								dec	di
								jmp	short trail_vert_back_loop

trail_vert_back_next:
		add	di,205Bh
		cmp	di,hgc_bank1_end
		jb	trail_draw_start			; Jump if below
		add	di,hgc_bank2_wrap

trail_draw_start:
		mov	si,move_seq_up

trail_draw_top:
		mov	byte ptr cs:gvar_frame_timer,0
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	trail_down_start			; Jump if not zero
		retn

trail_down_start:
		xor	cx,cx			; Zero register
		mov	cl,al

trail_down_loop:
								push	cx
								mov	al,18h
								call	blit_clipped_alt_hgc
								add	di,205Ah
								cmp	di,hgc_bank1_end
								jb	trail_down_next			; Jump if below
								add	di,hgc_bank2_wrap

trail_down_next:
								pop	cx
								loop	trail_down_loop		; Loop if cx > 0

		sub	di,205Ah
		jnc	trail_right_start			; Jump if carry=0
		add	di,hgc_bank1_end_m1

trail_right_start:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	trail_right_top			; Jump if not zero
		retn

trail_right_top:
		xor	cx,cx			; Zero register
		mov	cl,al

trail_right_loop:
								push	cx
								mov	al,18h
								call	blit_clipped_alt_hgc
								inc	di
								pop	cx
								loop	trail_right_loop		; Loop if cx > 0

		dec	di
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	trail_up_top			; Jump if not zero
		retn

trail_up_top:
		xor	cx,cx			; Zero register
		mov	cl,al

trail_up_loop:
								push	cx
								mov	al,18h
								call	blit_clipped_alt_hgc
								sub	di,205Ah
								jnc	trail_up_next			; Jump if carry=0
								add	di,hgc_bank1_end_m1

trail_up_next:
								pop	cx
								loop	trail_up_loop		; Loop if cx > 0

		add	di,205Ah
		cmp	di,hgc_bank1_end
		jb	trail_left_top			; Jump if below
		add	di,hgc_bank2_wrap

trail_left_top:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	trail_left_top2			; Jump if not zero
		retn

trail_left_top2:
		xor	cx,cx			; Zero register
		mov	cl,al

trail_left_loop:
								push	cx
								mov	al,18h
								call	blit_clipped_alt_hgc
								dec	di
								pop	cx
								loop	trail_left_loop		; Loop if cx > 0

		inc	di

trail_wait_timer:
								cmp	byte ptr cs:gvar_frame_timer,0Ch
								jb	trail_wait_timer			; Jump if below
		jmp	trail_draw_top

blit_clipped_alt_hgc		proc	near
		push	si
		push	di
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,3A0Bh
		mov	si,ax
		hgc_write_pixel	func9_pixel2_wrap	; pixel 1

func9_pixel2_wrap:
		hgc_write_pixel	func9_pixel3_wrap	; pixel 2

func9_pixel3_wrap:
		hgc_write_pixel	func9_pixel4_wrap	; pixel 3

func9_pixel4_wrap:
		lodsb				; pixel byte from pattern table
		and	al,cs:cur_row_ctr	; apply color mask
		or	al,[si+3]		; OR background pattern
		stosb				; write to HGC framebuffer
		add	di,1FFFh		; advance to next interlaced bank row
		cmp	di,hgc_bank1_end	; past bank 1 end?
		jb	func9_done		; no: done
		stosb				; yes: write to bank 2 (no base advance - last pixel)

func9_done:
		pop	di
		pop	si
		retn

blit_clipped_alt_hgc		endp

		; HGC 2bpp grayscale pattern table for sprite rendering (4-shade: 00h/03h/AAh/C0h/FFh columns)
		db	 00h, 00h, 00h, 03h, 80h, 80h	; pattern row  0
		db	 8Ah, 88h, 03h, 03h, 03h, 03h	; pattern row  1
		db	 88h, 88h, 88h, 88h, 03h, 03h	; pattern row  2
		db	 03h, 03h, 88h, 88h, 88h,0A8h	; pattern row  3
		db	 00h, 00h, 00h,0FFh, 00h, 00h	; pattern row  4
		db	0AAh, 00h, 00h, 00h, 00h,0FFh	; pattern row  5
		db	 02h, 02h,0AAh, 00h, 00h, 00h	; pattern row  6
		db	 00h,0FFh, 80h, 80h,0AAh, 00h	; pattern row  7
		db	 00h, 00h, 00h,0C0h, 02h, 02h	; pattern row  8
		db	0A2h, 22h,0C0h,0C0h,0C0h,0C0h	; pattern row  9
		db	 22h, 22h, 22h, 22h,0C0h,0C0h	; pattern row 10
		db	0C0h,0C0h, 22h, 22h, 22h, 22h	; pattern row 11
		db	0C0h,0C0h,0C0h,0C0h, 2Ah, 02h	; pattern row 12
		db	 02h, 02h, 03h, 03h, 03h, 03h	; pattern row 13
		db	0A8h, 88h, 88h, 88h, 03h, 03h	; pattern row 14
		db	 03h, 03h, 88h, 88h, 88h, 88h	; pattern row 15
		db	 03h, 00h, 00h, 00h, 88h, 8Ah	; pattern row 16
		db	 80h, 80h,0FFh, 00h, 00h, 00h	; pattern row 17
		db	 00h,0AAh, 00h, 00h,0FFh, 00h	; pattern row 18
		db	 00h, 00h, 00h,0AAh, 02h, 02h	; pattern row 19
		db	0FFh, 00h, 00h, 00h, 00h,0AAh	; pattern row 20
		db	 80h, 80h,0C0h,0C0h,0C0h,0C0h	; pattern row 21
		db	 2Ah, 22h, 22h, 22h,0C0h,0C0h	; pattern row 22
		db	0C0h,0C0h, 22h, 22h, 22h, 22h	; pattern row 23
		db	0C0h, 00h, 00h, 00h, 22h,0A2h	; pattern row 24
		db	 02h, 02h, 00h, 00h,0FFh,0FFh	; pattern row 25
		db	 00h, 00h, 00h, 00h,0FFh,0FFh	; pattern row 26
		db	 00h, 00h, 00h, 00h, 00h, 00h	; pattern row 27
		db	 03h, 03h, 03h, 03h, 80h, 80h	; pattern row 28
		db	 80h, 80h,0C0h,0C0h,0C0h,0C0h	; pattern row 29
		db	 02h, 02h, 02h, 02h,0FFh,0FFh	; pattern row 30
		db	0FFh,0FFh, 00h, 00h, 00h, 00h	; pattern row 31
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
		db	 00h,0AAh, 55h, 1Eh, 2Eh,0A2h	; param tag bytes + push ds; mov [cs:..],al
		db	 5Fh, 4Ch, 53h, 51h, 8Ah,0C5h	; ...4C5Fh,al; push bx; push cx; mov al,ch
		db	0F6h,0E1h, 8Bh,0E8h, 06h, 1Fh	; mul cl; mov bp,ax; push es; pop ds
		db	 8Bh,0F7h, 8Ch,0C8h, 05h, 00h	; mov si,di; mov ax,cs; add ax,...
		db	 30h, 8Eh,0C0h,0BFh, 00h, 00h	; ...3000h; mov es,ax; mov di,0
		db	 2Eh,0C7h, 06h, 5Ah, 4Ch, 00h	; mov word ptr cs:[4C5Ah],...
		db	 00h, 2Eh,0C7h, 06h, 54h, 4Ch	; ...0; mov word ptr cs:[4C54h],...
		db	 00h, 00h, 2Eh,0C7h, 06h, 56h	; ...0; mov word ptr cs:[4C56h],...
		db	 4Ch, 00h, 00h, 2Eh,0C7h, 06h	; ...0; mov word ptr cs:[4C58h],...
		db	 58h, 4Ch, 00h, 00h, 8Bh,0CDh	; ...0; mov cx,bp
		db	0D1h,0E9h			; shr cx,1 -> render_src_sel_loop

render_src_sel_loop:
								push	si
								test	byte ptr cs:render_mode_flag,1
								jz	render_src_b_check			; Jump if zero
								mov	ax,[si]
								mov	cs:src_word_a,ax
								add	si,bp

render_src_b_check:
								test	byte ptr cs:render_mode_flag,2
								jz	render_src_c_check			; Jump if zero
								mov	ax,[si]
								mov	cs:src_word_b,ax
								add	si,bp

render_src_c_check:
								test	byte ptr cs:render_mode_flag,4
								jz	render_src_call			; Jump if zero
								mov	ax,[si]
								mov	cs:src_word_c,ax

render_src_call:
								call	copy_status_loop_hgc
								stosw				; Store ax to es:[di]
								pop	si
								inc	si
								inc	si
								loop	render_src_sel_loop		; Loop if cx > 0

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
		mov	ax,hgc_seg
		mov	es,ax
		mov	cx,8

render_pass_loop:
								push	cx
								mov	al,cs:cur_pass_ctr
								mov	cs:cur_row_ctr,al
								mov	byte ptr cs:gvar_frame_timer,0
								mov	cx,0Dh

render_col_inner_loop:
														push	cx
														push	bx
														push	si
														call	blit_sprite_clipped_hgc
														pop	si
														pop	bx
														pop	cx
														add	byte ptr cs:cur_row_ctr,8
														loop	render_col_inner_loop		; Loop if cx > 0

								pop	cx

render_pass_wait_timer:
														cmp	byte ptr cs:gvar_frame_timer,14h
														jb	render_pass_wait_timer			; Jump if below
								inc	byte ptr cs:cur_pass_ctr
								loop	render_pass_loop		; Loop if cx > 0

		pop	ds
		retn

blit_sprite_clipped_hgc		proc	near
		push	bx
		mov	bl,cs:cur_row_ctr
		add	bl,10h
		mov	bh,4
		call	math_calc
		mov	di,ax
		pop	bx
		cmp	cs:cur_row_ctr,bl
		jb	multiply3_clear			; Jump if below
		mov	al,bl
		add	al,cs:render_fn_ptr
		cmp	cs:cur_row_ctr,al
		jae	multiply3_clear			; Jump if above or =
		mov	al,cs:cur_row_ctr
		sub	al,bl
		mul	byte ptr cs:render_fn_ptr+1	; ax = data * al
		add	si,ax
		push	di
		mov	byte ptr cs:cur_col_ctr,0
		mov	cx,48h

multiply3_col_loop:
								push	cx
								mov	byte ptr es:[di],0
								cmp	cs:cur_col_ctr,bh
								jb	multiply3_col_skip			; Jump if below
								mov	al,bh
								add	al,byte ptr cs:render_fn_ptr+1
								cmp	cs:cur_col_ctr,al
								jae	multiply3_col_skip			; Jump if above or =
								movsb				; Mov [si] to es:[di]
								dec	di

multiply3_col_skip:
								inc	di
								inc	byte ptr cs:cur_col_ctr
								pop	cx
								loop	multiply3_col_loop		; Loop if cx > 0

		pop	di
		hgc_advance_di_wrap	multiply3_wrap_copy		; Jump if above or =
		retn

multiply3_wrap_copy:
		push	ds
		push	es
		pop	ds
		mov	si,di
		sub	si,2000h
		mov	cx,48h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn

multiply3_clear:
		push	di
		mov	cx,24h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		hgc_advance_di_wrap	multiply3_clear_wrap		; Jump if above or =
		retn

multiply3_clear_wrap:
		mov	cx,24h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

blit_sprite_clipped_hgc		endp

line_fill_entry:
		mov	cs:cur_row_ctr,bl
		call	math_calc
		mov	di,ax
		mov	ax,hgc_seg
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register
		sub	cx,5
		push	cx
		push	di
		call	init_status_buf_hgc
		pop	di
		inc	byte ptr cs:cur_row_ctr
		hgc_advance_di	fill_buf_second_pass			; Jump if below
		add	di,hgc_bank2_wrap

fill_buf_second_pass:
		mov	cx,2
		call	clear_status_buf_rows_hgc
		pop	cx

fill_rows_loop:
								push	cx
								call	write_status_pattern_0_hgc
								or	byte ptr es:[di],30h	; '0'
								and	byte ptr es:[di],0F0h
								or	byte ptr es:[bx+di-1],0Ch
								and	byte ptr es:[bx+di-1],0Fh
								inc	byte ptr cs:cur_row_ctr
								hgc_advance_di	fill_rows_next			; Jump if below
								call	write_status_pattern_0_hgc
								or	byte ptr es:[di],30h	; '0'
								and	byte ptr es:[di],0F0h
								or	byte ptr es:[bx+di-1],0Ch
								and	byte ptr es:[bx+di-1],0Fh
								inc	byte ptr cs:cur_row_ctr
								add	di,hgc_bank2_wrap

fill_rows_next:
								pop	cx
								loop	fill_rows_loop		; Loop if cx > 0

		mov	cx,1
		call	clear_status_buf_rows_hgc

init_status_buf_hgc		proc	near
		push	di
		call	write_status_pattern_0_hgc
		or	byte ptr es:[di],3Fh	; '?'
		inc	di
		mov	cx,bx
		sub	cx,2
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0FCh
		pop	di
		hgc_advance_di_wrap	fill_buf_wrap		; Jump if above or =
		retn

fill_buf_wrap:
		call	write_status_pattern_0_hgc
		or	byte ptr es:[di],3Fh	; '?'
		inc	di
		mov	cx,bx
		sub	cx,2
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0FCh
		retn

init_status_buf_hgc		endp

clear_status_buf_rows_hgc		proc	near

clear_buf_row_loop:
								push	cx
								push	di
								call	write_status_pattern_0_hgc
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
								hgc_advance_di	clear_buf_row_wrap			; Jump if below
								push	di
								call	write_status_pattern_0_hgc
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
								add	di,hgc_bank2_wrap

clear_buf_row_wrap:
								pop	cx
								loop	clear_buf_row_loop		; Loop if cx > 0

		retn

clear_status_buf_rows_hgc		endp

write_status_pattern_0_hgc		proc	near
		mov	word ptr es:[di-1],0
		retn

write_status_pattern_0_hgc		endp

plane_merge_entry:
		push	bx
		push	es
		push	di
		mov	cx,1028h

plane_merge_loop:
								mov	al,es:[di]
								and	al,byte ptr es:[sprite_backbuf_plane_sz][di]
								mov	ah,es:hgc_plane2_buf[di]
								not	ah
								and	al,ah
								not	al
								and	es:[di],al
								and	byte ptr es:[sprite_backbuf_plane_sz][di],al
								and	es:hgc_plane2_buf[di],al
								mov	al,es:hgc_plane2_buf[di]
								mov	ah,es:[di]
								not	ah
								and	al,ah
								mov	ah,byte ptr es:[sprite_backbuf_plane_sz][di]
								not	ah
								and	al,ah
								or	es:[di],al
								or	byte ptr es:[sprite_backbuf_plane_sz][di],al
								not	al
								and	es:hgc_plane2_buf[di],al
								inc	di
								loop	plane_merge_loop		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,2F58h
		jmp	render_plane_ab_entry

border_draw_entry:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	di,69Ah
		add	di,ds:saved_di
		call	seed_status_pattern_hgc
		mov	di,6BCh
		add	di,ds:saved_di
		call	seed_status_pattern_hgc
		mov	ax,hgc_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,44h

scan_outer_loop:
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
								xor	bh,bh			; Zero register
								call	math_calc
								mov	di,ax
								pop	ax
								add	ax,cs:saved_di
								mov	si,ax
								pop	ax
								cmp	ax,16h
								jb	scan_row_even_else			; Jump if below
								cmp	ax,71h
								jae	scan_row_even_else			; Jump if above or =
								call	init_status_row_11_hgc
								jmp	short scan_row_even_done

scan_row_even_else:
								call	init_status_row_28_hgc

scan_row_even_done:
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
								xor	bh,bh			; Zero register
								call	math_calc
								mov	di,ax
								pop	ax
								add	ax,cs:saved_di
								mov	si,ax
								pop	ax
								cmp	ax,16h
								jb	scan_row_odd_else			; Jump if below
								cmp	ax,71h
								jae	scan_row_odd_else			; Jump if above or =
								call	init_status_row_11_hgc
								jmp	short scan_row_wait_timer

scan_row_odd_else:
								call	init_status_row_28_hgc

scan_row_wait_timer:
														cmp	byte ptr cs:gvar_frame_timer,4
														jb	scan_row_wait_timer			; Jump if below
								pop	cx
								loop	scan_outer_loop		; Loop if cx > 0

		pop	ds
		retn

init_status_row_28_hgc		proc	near
		mov	cx,28h
		mov	word ptr cs:src_word_d,0

scan_words_loop:
								mov	ax,ds:sprite_row_buf_b[si]
								mov	cs:src_word_c,ax
								mov	ax,ds:hgc_plane_stride[si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosw				; Store ax to es:[di]
								push	di
								add	di,1FFEh
								cmp	di,hgc_bank1_end
								jb	scan_words_wrap			; Jump if below
								stosw				; Store ax to es:[di]

scan_words_wrap:
								pop	di
								loop	scan_words_loop		; Loop if cx > 0

		retn

init_status_row_28_hgc		endp

init_status_row_11_hgc		proc	near
		mov	cx,0Bh
		mov	word ptr cs:src_word_d,0

scan2_top_loop:
								xor	ah,ah			; Zero register
								mov	al,ds:sprite_row_buf_b[si]
								mov	cs:src_word_c,ax
								mov	al,ds:hgc_plane_stride[si]
								mov	cs:src_word_b,ax
								lodsb				; String [si] to al
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosb				; Store al to es:[di]
								push	di
								add	di,1FFFh
								cmp	di,hgc_bank1_end
								jb	scan2_top_wrap			; Jump if below
								stosb				; Store al to es:[di]

scan2_top_wrap:
								pop	di
								loop	scan2_top_loop		; Loop if cx > 0

		add	si,18h
		add	di,18h
		mov	cx,5

scan2_mid_loop:
								mov	ax,ds:sprite_row_buf_b[si]
								mov	cs:src_word_c,ax
								mov	ax,ds:hgc_plane_stride[si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosw				; Store ax to es:[di]
								push	di
								add	di,1FFEh
								cmp	di,hgc_bank1_end
								jb	scan2_mid_wrap			; Jump if below
								stosw				; Store ax to es:[di]

scan2_mid_wrap:
								pop	di
								loop	scan2_mid_loop		; Loop if cx > 0

		add	si,18h
		add	di,18h
		mov	cx,0Bh

scan2_bot_loop:
								xor	ah,ah			; Zero register
								mov	al,ds:sprite_row_buf_b[si]
								mov	cs:src_word_c,ax
								mov	al,ds:hgc_plane_stride[si]
								mov	cs:src_word_b,ax
								lodsb				; String [si] to al
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosb				; Store al to es:[di]
								push	di
								add	di,1FFFh
								cmp	di,hgc_bank1_end
								jb	scan2_bot_wrap			; Jump if below
								stosb				; Store al to es:[di]

scan2_bot_wrap:
								pop	di
								loop	scan2_bot_loop		; Loop if cx > 0

		retn

init_status_row_11_hgc		endp

seed_status_pattern_hgc		proc	near
		push	di
		mov	ax,0FC3Fh
		call	fill_status_byte_24x_hgc
		add	di,36h
		mov	cx,5Bh

border_top_loop:
								mov	byte ptr es:[di],30h	; '0'
								mov	byte ptr es:[di+19h],0Ch
								add	di,50h
								loop	border_top_loop		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_status_byte_24x_hgc
		pop	di
		add	di,hgc_plane_stride
		push	di
		mov	ax,0FD7Fh
		call	fill_status_byte_24x_hgc
		add	di,36h
		mov	cx,2Dh

border_sides_loop:
								mov	byte ptr es:[di],0B0h
								mov	byte ptr es:[di+19h],0Eh
								add	di,50h
								mov	byte ptr es:[di],70h	; 'p'
								mov	byte ptr es:[di+19h],0Dh
								add	di,50h
								loop	border_sides_loop		; Loop if cx > 0

		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	ax,0FD7Fh
		call	fill_status_byte_24x_hgc
		pop	di
		add	di,hgc_plane_stride
		mov	ax,0FC3Fh
		call	fill_status_byte_24x_hgc
		add	di,36h
		mov	cx,5Bh

border_bot_loop:
								mov	byte ptr es:[di],30h	; '0'
								mov	byte ptr es:[di+19h],0Ch
								add	di,50h
								loop	border_bot_loop		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_status_byte_24x_hgc
		retn

seed_status_pattern_hgc		endp

fill_status_byte_24x_hgc		proc	near
		stosb				; Store al to es:[di]
		mov	al,0FFh
		mov	cx,18h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,ah
		stosb				; Store al to es:[di]
		retn

fill_status_byte_24x_hgc		endp

extract_pixel_pair_hgc_entry:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	ax,hgc_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,39h

multiply4_outer_loop:
								mov	byte ptr cs:gvar_frame_timer,0
								push	cx
								mov	ax,cx
								neg	ax
								add	ax,39h
								add	ax,ax
								call	extract_pixel_pair_hgc
								pop	ax
								push	ax
								add	ax,ax
								dec	ax
								call	extract_pixel_pair_hgc

multiply4_wait_timer:
														cmp	byte ptr cs:gvar_frame_timer,4
														jb	multiply4_wait_timer			; Jump if below
								pop	cx
								loop	multiply4_outer_loop		; Loop if cx > 0

		pop	ds
		retn

extract_pixel_pair_hgc		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,cs:saved_di
		mov	si,ax
		xor	bh,bh			; Zero register
		call	math_calc
		mov	di,ax
		pop	ax
		cmp	ax,14h
		jae	multiply4_col_wide			; Jump if above or =
		mov	cx,2Fh
		jmp	short multiply4_col_draw

multiply4_col_wide:
		mov	cx,23h
		cmp	ax,17h
		jb	multiply4_col_draw			; Jump if below
		cmp	ax,1Ch
		jb	multiply4_partial			; Jump if below
		mov	cx,21h

multiply4_col_draw:
		mov	word ptr cs:src_word_d,0

multiply4_draw_loop:
								xor	ah,ah			; Zero register
								mov	al,ds:hgc_plane3_buf[si]
								mov	cs:src_word_c,ax
								mov	al,byte ptr hgc_lookup_data_40[si]
								mov	cs:src_word_b,ax
								lodsb				; String [si] to al
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosb				; Store al to es:[di]
								push	di
								add	di,1FFFh
								cmp	di,hgc_bank1_end
								jb	multiply4_draw_wrap			; Jump if below
								stosb				; Store al to es:[di]

multiply4_draw_wrap:
								pop	di
								loop	multiply4_draw_loop		; Loop if cx > 0

		retn

multiply4_partial:
		mov	cx,21h
		mov	word ptr cs:src_word_d,0

multiply4_partial_loop:
								xor	ah,ah			; Zero register
								mov	al,ds:hgc_plane3_buf[si]
								mov	cs:src_word_c,ax
								mov	al,byte ptr hgc_lookup_data_40[si]
								mov	cs:src_word_b,ax
								lodsb				; String [si] to al
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosb				; Store al to es:[di]
								push	di
								add	di,1FFFh
								cmp	di,hgc_bank1_end
								jb	multiply4_partial_wrap			; Jump if below
								stosb				; Store al to es:[di]

multiply4_partial_wrap:
								pop	di
								loop	multiply4_partial_loop		; Loop if cx > 0

		xor	ah,ah			; Zero register
		mov	al,ds:hgc_plane3_buf[si]
		mov	cs:src_word_c,ax
		mov	al,byte ptr hgc_lookup_data_40[si]
		mov	cs:src_word_b,ax
		lodsb				; String [si] to al
		mov	cs:src_word_a,ax
		call	copy_status_loop_hgc
		and	al,0FCh
		and	byte ptr es:[di],3
		or	es:[di],al
		add	di,1FFFh
		cmp	di,hgc_bank1_end
		jae	multiply4_edge_wrap			; Jump if above or =
		retn

multiply4_edge_wrap:
		and	byte ptr es:[di],3
		or	es:[di],al
		retn

extract_pixel_pair_hgc		endp

extract_pixel_pair_alt_hgc_entry:
		push	ds
		mov	ds:saved_di,di
		mov	ds:saved_es,es
		mov	ax,hgc_seg
		mov	es,ax
		mov	ds,cs:saved_es
		mov	cx,39h

multiply5_outer_loop:
								mov	byte ptr cs:gvar_frame_timer,0
								push	cx
								mov	ax,cx
								neg	ax
								add	ax,39h
								add	ax,ax
								call	extract_pixel_pair_alt_hgc
								pop	ax
								push	ax
								add	ax,ax
								dec	ax
								call	extract_pixel_pair_alt_hgc

multiply5_wait_timer:
														cmp	byte ptr cs:gvar_frame_timer,4
														jb	multiply5_wait_timer			; Jump if below
								pop	cx
								loop	multiply5_outer_loop		; Loop if cx > 0

		pop	ds
		retn

extract_pixel_pair_alt_hgc		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,3CDh
		add	ax,cs:saved_di
		mov	si,ax
		add	bl,14h
		xor	bh,bh			; Zero register
		call	math_calc
		mov	di,ax
		add	di,21h
		pop	ax
		cmp	ax,5Eh
		mov	cx,2Fh
		jnc	multiply5_clear			; Jump if carry=0
		mov	cx,7
		mov	word ptr cs:src_word_d,0

multiply5_words_loop:
								mov	ax,ds:hgc_plane3_buf[si]
								mov	cs:src_word_c,ax
								mov	ax,hgc_lookup_data_40[si]
								mov	cs:src_word_b,ax
								lodsw				; String [si] to ax
								mov	cs:src_word_a,ax
								call	copy_status_loop_hgc
								stosw				; Store ax to es:[di]
								push	di
								add	di,1FFEh
								cmp	di,hgc_bank1_end
								jb	multiply5_words_wrap			; Jump if below
								stosw				; Store ax to es:[di]

multiply5_words_wrap:
								pop	di
								loop	multiply5_words_loop		; Loop if cx > 0

		mov	cx,21h

multiply5_clear:
		xor	al,al			; Zero register
		push	cx
		push	di
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		pop	cx
		hgc_advance_di_wrap	multiply5_clear_wrap		; Jump if above or =
		retn

multiply5_clear_wrap:
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn

extract_pixel_pair_alt_hgc		endp

write_pixel_entry:
		push	ax
		call	math_calc
		mov	di,ax
		mov	ax,hgc_seg
		mov	es,ax
		pop	ax
		mov	ah,al
		mov	cx,8

write_pixel_loop:
								stosw				; Store ax to es:[di]
								add	di,1FFEh
								cmp	di,hgc_bank1_end
								jb	write_pixel_wrap			; Jump if below
								stosw				; Store ax to es:[di]
								add	di,hgc_bank2_wrap_w

write_pixel_wrap:
								loop	write_pixel_loop		; Loop if cx > 0

		retn

set_render_lut_entry:
		dec	ax
		mov	cx,100h
		mul	cx			; dx:ax = reg * ax
		add	ax,4288h
		mov	cs:render_lut_ptr,ax
		retn
		; Sprite movement/animation pattern data (sprite_obj_tbl area)
		db	17 dup (0)
		db	2, 0                                               ; sprite_data offset 0x011 (2 bytes)
		db	15 dup (0)
		db	1, 0, 0, 0, 0, 0                                   ; sprite_data offset 0x022 (6 bytes)
		db	0, 0, 1                                            ; sprite_data offset 0x028 (3 bytes)
		db	8 dup (0)
		db	1, 0, 0, 0, 0, 0                                   ; sprite_data offset 0x033 (6 bytes)
		db	0, 0, 1                                            ; sprite_data offset 0x039 (3 bytes)
		db	8 dup (0)
		db	3, 3, 3, 3, 0, 3                                   ; sprite_data offset 0x044 (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; sprite_data offset 0x04A (6 bytes)
		db	0, 0, 0, 0, 3, 3                                   ; sprite_data offset 0x050 (6 bytes)
		db	3, 3, 0, 3, 0, 0                                   ; sprite_data offset 0x056 (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; sprite_data offset 0x05C (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; sprite_data offset 0x062 (6 bytes)
		db	0, 3, 0, 0, 3, 3                                   ; sprite_data offset 0x068 (6 bytes)
		db	3, 3, 0, 0, 0, 0                                   ; sprite_data offset 0x06E (6 bytes)
		db	3, 3, 3, 3, 0, 3                                   ; sprite_data offset 0x074 (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; sprite_data offset 0x07A (6 bytes)
		db	0                                                  ; sprite_data offset 0x080 (1 bytes)
		db	7 dup (0)
		db	1, 0                                               ; sprite_data offset 0x088 (2 bytes)
		db	10 dup (0)
		db	3, 3, 3, 3, 0, 1                                   ; sprite_data offset 0x094 (6 bytes)
		db	8 dup (0)
		db	1, 0, 0, 0, 0, 0                                   ; sprite_data offset 0x0A2 (6 bytes)
		db	0, 0, 1                                            ; sprite_data offset 0x0A8 (3 bytes)
		db	8 dup (0)
		db	1, 0, 0, 0, 0, 0                                   ; sprite_data offset 0x0B3 (6 bytes)
		db	0, 0, 1                                            ; sprite_data offset 0x0B9 (3 bytes)
		db	8 dup (0)
		db	3, 3, 3, 3, 0, 0                                   ; sprite_data offset 0x0C4 (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; sprite_data offset 0x0CA (6 bytes)
		db	0, 0, 0, 0, 3, 3                                   ; sprite_data offset 0x0D0 (6 bytes)
		db	3, 3, 0, 0, 0, 0                                   ; sprite_data offset 0x0D6 (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; sprite_data offset 0x0DC (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; sprite_data offset 0x0E2 (6 bytes)
		db	0, 0, 0, 0, 3, 3                                   ; sprite_data offset 0x0E8 (6 bytes)
		db	3, 3, 0, 0, 0, 0                                   ; sprite_data offset 0x0EE (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; sprite_data offset 0x0F4 (6 bytes)
		db	0, 0, 3, 3, 3, 3                                   ; sprite_data offset 0x0FA (6 bytes)
		db	0, 0, 0, 0, 0, 1                                   ; sprite_data offset 0x100 (6 bytes)
		db	2, 0                                               ; sprite_data offset 0x106 (2 bytes)
		db	9 dup (0)
		db	1, 1, 2, 0, 1, 2                                   ; sprite_data offset 0x111 (6 bytes)
		db	1, 0                                               ; sprite_data offset 0x117 (2 bytes)
		db	8 dup (0)
		db	1, 2, 0, 0, 2, 2                                   ; sprite_data offset 0x121 (6 bytes)
		db	2, 0                                               ; sprite_data offset 0x127 (2 bytes)
		db	8 dup (0)
		db	2, 0, 2, 0, 1, 2                                   ; sprite_data offset 0x131 (6 bytes)
		db	2, 0                                               ; sprite_data offset 0x137 (2 bytes)
		db	12 dup (0)
		db	1, 2                                               ; sprite_data offset 0x145 (2 bytes)
		db	9 dup (0)
		db	1, 1, 2, 1, 1, 1                                   ; sprite_data offset 0x150 (6 bytes)
		db	1, 3                                               ; sprite_data offset 0x156 (2 bytes)
		db	8 dup (0)
		db	2, 1, 2, 2, 2, 1                                   ; sprite_data offset 0x160 (6 bytes)
		db	3, 3                                               ; sprite_data offset 0x166 (2 bytes)
		db	9 dup (0)
		db	1, 2, 2, 0, 3, 3                                   ; sprite_data offset 0x171 (6 bytes)
		db	3, 0                                               ; sprite_data offset 0x177 (2 bytes)
		db	32 dup (0)
		db	3, 0                                               ; sprite_data offset 0x199 (2 bytes)
		db	15 dup (0)
		db	2, 0                                               ; sprite_data offset 0x1AA (2 bytes)
		db	15 dup (0)
		db	2, 0                                               ; sprite_data offset 0x1BB (2 bytes)
		db	15 dup (0)
		db	1, 0                                               ; sprite_data offset 0x1CC (2 bytes)
		db	15 dup (0)
		db	1, 0                                               ; sprite_data offset 0x1DD (2 bytes)
		db	15 dup (0)
		db	3, 0                                               ; sprite_data offset 0x1EE (2 bytes)
		db	15 dup (0)
		db	3, 0, 0, 0, 1, 0                                   ; sprite_data offset 0x1FF (6 bytes)
		db	1, 0, 1, 0                                         ; sprite_data offset 0x205 (4 bytes)
		db	8 dup (0)
		db	2, 1, 2, 1, 2, 0                                   ; sprite_data offset 0x211 (6 bytes)
		db	2, 0                                               ; sprite_data offset 0x217 (2 bytes)
		db	8 dup (0)
		db	1, 1, 3, 1, 3, 0                                   ; sprite_data offset 0x221 (6 bytes)
		db	3, 0                                               ; sprite_data offset 0x227 (2 bytes)
		db	7 dup (0)
		db	1, 2, 3, 3, 3, 3                                   ; sprite_data offset 0x230 (6 bytes)
		db	0, 3                                               ; sprite_data offset 0x236 (2 bytes)
		db	9 dup (0)
		db	1, 1, 3, 1, 3, 0                                   ; sprite_data offset 0x241 (6 bytes)
		db	3, 0                                               ; sprite_data offset 0x247 (2 bytes)
		db	7 dup (0)
		db	1, 2, 3, 3, 3, 3                                   ; sprite_data offset 0x250 (6 bytes)
		db	0, 3                                               ; sprite_data offset 0x256 (2 bytes)
		db	10 dup (0)
hgc_lookup_data_40		dw	0			; Data table (indexed access)
		db	0, 0, 0, 1, 0                                      ; sprite_data offset 0x262 (5 bytes)
		db	7 dup (0)
		db	1, 2, 3, 3, 3, 3                                   ; sprite_data offset 0x26E (6 bytes)
		db	1, 3                                               ; sprite_data offset 0x274 (2 bytes)
		db	33 dup (0)
		db	3, 0                                               ; sprite_data offset 0x297 (2 bytes)
		db	15 dup (0)
		db	2, 0                                               ; sprite_data offset 0x2A8 (2 bytes)
		db	15 dup (0)
		db	2, 0                                               ; sprite_data offset 0x2B9 (2 bytes)
		db	15 dup (0)
		db	1, 0                                               ; sprite_data offset 0x2CA (2 bytes)
		db	15 dup (0)
		db	1, 0                                               ; sprite_data offset 0x2DB (2 bytes)
		db	15 dup (0)
		db	2, 0                                               ; sprite_data offset 0x2EC (2 bytes)
		db	15 dup (0)
		db	3, 0, 0, 0, 2, 1                                   ; sprite_data offset 0x2FD (6 bytes)
		db	1, 2, 3, 0, 1, 2                                   ; sprite_data offset 0x303 (6 bytes)
		db	2, 1, 1, 2, 3, 0                                   ; sprite_data offset 0x309 (6 bytes)
		db	1, 2, 2, 1, 1, 1                                   ; sprite_data offset 0x30F (6 bytes)
		db	1, 0, 1, 2, 2, 1                                   ; sprite_data offset 0x315 (6 bytes)
		db	1, 1, 1, 0, 2, 2                                   ; sprite_data offset 0x31B (6 bytes)
		db	2, 1, 1, 2, 3, 0                                   ; sprite_data offset 0x321 (6 bytes)
		db	2, 2, 2, 1, 1, 2                                   ; sprite_data offset 0x327 (6 bytes)
		db	3, 2, 2, 2, 2, 1                                   ; sprite_data offset 0x32D (6 bytes)
		db	1, 2, 2, 0, 2, 2                                   ; sprite_data offset 0x333 (6 bytes)
		db	1, 1, 2, 2, 3, 1                                   ; sprite_data offset 0x339 (6 bytes)
		db	1, 1, 1, 1, 1, 3                                   ; sprite_data offset 0x33F (6 bytes)
		db	3, 1, 1, 1, 1, 1                                   ; sprite_data offset 0x345 (6 bytes)
		db	1, 3, 3, 1, 1, 1                                   ; sprite_data offset 0x34B (6 bytes)
		db	1, 1, 1, 3, 3, 1                                   ; sprite_data offset 0x351 (6 bytes)
		db	1, 1, 1, 1, 1, 3                                   ; sprite_data offset 0x357 (6 bytes)
		db	3, 2, 1, 2, 2, 3                                   ; sprite_data offset 0x35D (6 bytes)
		db	3, 3, 3, 2, 2, 2                                   ; sprite_data offset 0x363 (6 bytes)
		db	2, 3, 3, 3, 3, 3                                   ; sprite_data offset 0x369 (6 bytes)
		db	1, 3, 2, 3, 3, 3                                   ; sprite_data offset 0x36F (6 bytes)
		db	3, 3, 1, 2, 2, 3                                   ; sprite_data offset 0x375 (6 bytes)
		db	3, 3, 3, 0, 0, 0                                   ; sprite_data offset 0x37B (6 bytes)
		db	0, 1, 1, 2, 3, 0                                   ; sprite_data offset 0x381 (6 bytes)
		db	0, 0, 2, 1, 1, 2                                   ; sprite_data offset 0x387 (6 bytes)
		db	3, 1, 1, 2, 2, 1                                   ; sprite_data offset 0x38D (6 bytes)
		db	1, 2, 1, 0, 1, 2                                   ; sprite_data offset 0x393 (6 bytes)
		db	2, 1, 1, 1, 1, 2                                   ; sprite_data offset 0x399 (6 bytes)
		db	2, 2, 2, 1, 1, 2                                   ; sprite_data offset 0x39F (6 bytes)
		db	2, 0, 2, 2, 2, 1                                   ; sprite_data offset 0x3A5 (6 bytes)
		db	1, 2, 3, 2, 2, 2                                   ; sprite_data offset 0x3AB (6 bytes)
		db	1, 1, 1, 2, 2, 2                                   ; sprite_data offset 0x3B1 (6 bytes)
		db	2, 2, 2, 1, 1, 2                                   ; sprite_data offset 0x3B7 (6 bytes)
		db	2, 1, 1, 1, 1, 1                                   ; sprite_data offset 0x3BD (6 bytes)
		db	1, 3, 3, 1, 1, 1                                   ; sprite_data offset 0x3C3 (6 bytes)
		db	1, 1, 1, 3, 3, 1                                   ; sprite_data offset 0x3C9 (6 bytes)
		db	1, 1, 2, 1, 1, 3                                   ; sprite_data offset 0x3CF (6 bytes)
		db	3, 1, 1, 1, 1, 1                                   ; sprite_data offset 0x3D5 (6 bytes)
		db	1, 3, 3, 2, 1, 2                                   ; sprite_data offset 0x3DB (6 bytes)
		db	2, 3, 3, 3, 3, 2                                   ; sprite_data offset 0x3E1 (6 bytes)
		db	1, 2, 2, 3, 3, 3                                   ; sprite_data offset 0x3E7 (6 bytes)
		db	3, 3, 1, 3, 3, 3                                   ; sprite_data offset 0x3ED (6 bytes)
		db	3, 3, 3, 3, 1, 3                                   ; sprite_data offset 0x3F3 (6 bytes)
		db	2, 3, 3, 3, 3, 0                                   ; sprite_data offset 0x3F9 (6 bytes)
		db	0, 0, 1, 1, 1, 2                                   ; sprite_data offset 0x3FF (6 bytes)
		db	3, 0, 1, 2, 2, 1                                   ; sprite_data offset 0x405 (6 bytes)
		db	1, 2, 3, 0, 1, 2                                   ; sprite_data offset 0x40B (6 bytes)
		db	3, 1, 1, 1, 1, 0                                   ; sprite_data offset 0x411 (6 bytes)
		db	1, 2, 2, 1, 1, 1                                   ; sprite_data offset 0x417 (6 bytes)
		db	1, 0, 2, 2, 3, 1                                   ; sprite_data offset 0x41D (6 bytes)
		db	1, 2, 3, 0, 2, 2                                   ; sprite_data offset 0x423 (6 bytes)
		db	2, 1, 1, 2, 3, 1                                   ; sprite_data offset 0x429 (6 bytes)
		db	7 dup (3)
		db	0, 3, 3, 3, 3, 3                                   ; sprite_data offset 0x436 (6 bytes)
		db	3, 3, 1, 1, 1, 3                                   ; sprite_data offset 0x43C (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; sprite_data offset 0x442 (6 bytes)
		db	1, 1, 1, 1, 3, 3                                   ; sprite_data offset 0x448 (6 bytes)
		db	1, 1, 1, 3, 1, 1                                   ; sprite_data offset 0x44E (6 bytes)
		db	3, 3, 1, 1, 1, 1                                   ; sprite_data offset 0x454 (6 bytes)
		db	1, 1, 3, 3, 2, 1                                   ; sprite_data offset 0x45A (6 bytes)
		db	2, 3, 3, 3, 3, 3                                   ; sprite_data offset 0x460 (6 bytes)
		db	2, 2, 2, 2, 3, 3                                   ; sprite_data offset 0x466 (6 bytes)
		db	3, 3, 3, 1                                         ; sprite_data offset 0x46C (4 bytes)
		db	7 dup (3)
		db	1, 2, 2, 3, 3, 3                                   ; sprite_data offset 0x477 (6 bytes)
		db	3, 0, 0, 0, 0, 1                                   ; sprite_data offset 0x47D (6 bytes)
		db	1, 2, 3, 0, 0, 0                                   ; sprite_data offset 0x483 (6 bytes)
		db	2, 1, 1, 2, 3, 1                                   ; sprite_data offset 0x489 (6 bytes)
		db	1, 2, 3, 1, 1, 2                                   ; sprite_data offset 0x48F (6 bytes)
		db	1, 0, 1, 2, 2, 1                                   ; sprite_data offset 0x495 (6 bytes)
		db	1, 1, 1, 2, 2, 2                                   ; sprite_data offset 0x49B (6 bytes)
		db	3, 1, 1, 2, 2, 0                                   ; sprite_data offset 0x4A1 (6 bytes)
		db	2, 2, 2, 1, 1, 2                                   ; sprite_data offset 0x4A7 (6 bytes)
		db	3, 2, 2, 2, 3, 1                                   ; sprite_data offset 0x4AD (6 bytes)
		db	1, 2, 2, 2, 2, 2                                   ; sprite_data offset 0x4B3 (6 bytes)
		db	2, 1, 1, 2, 2, 1                                   ; sprite_data offset 0x4B9 (6 bytes)
		db	1, 1, 3, 1, 1, 3                                   ; sprite_data offset 0x4BF (6 bytes)
		db	3, 1, 1, 1, 1, 1                                   ; sprite_data offset 0x4C5 (6 bytes)
		db	1, 3, 3, 1, 1, 1                                   ; sprite_data offset 0x4CB (6 bytes)
		db	3, 1, 1, 3, 3, 1                                   ; sprite_data offset 0x4D1 (6 bytes)
		db	1, 1, 1, 1, 1, 3                                   ; sprite_data offset 0x4D7 (6 bytes)
		db	3, 2, 1, 2, 3, 3                                   ; sprite_data offset 0x4DD (6 bytes)
		db	3, 3, 3, 2, 1, 2                                   ; sprite_data offset 0x4E3 (6 bytes)
		db	2, 3, 3, 3, 3, 3                                   ; sprite_data offset 0x4E9 (6 bytes)
		db	1, 3, 3, 3, 3, 3                                   ; sprite_data offset 0x4EF (6 bytes)
		db	3, 3, 1, 3, 2, 3                                   ; sprite_data offset 0x4F5 (6 bytes)
		db	3, 3, 3, 0, 0, 0                                   ; sprite_data offset 0x4FB (6 bytes)
		db	0, 0, 1, 2, 3, 0                                   ; sprite_data offset 0x501 (6 bytes)
		db	1, 2, 2, 1, 1, 2                                   ; sprite_data offset 0x507 (6 bytes)
		db	3, 0, 1, 2, 2, 0                                   ; sprite_data offset 0x50D (6 bytes)
		db	1, 1, 1, 0, 1, 2                                   ; sprite_data offset 0x513 (6 bytes)
		db	2, 1, 1, 1, 1, 0                                   ; sprite_data offset 0x519 (6 bytes)
		db	2, 2, 2, 0, 2, 2                                   ; sprite_data offset 0x51F (6 bytes)
		db	3, 0, 2, 2, 2, 1                                   ; sprite_data offset 0x525 (6 bytes)
		db	1, 2, 3, 0, 2, 2                                   ; sprite_data offset 0x52B (6 bytes)
		db	2, 0, 2, 3, 3, 0                                   ; sprite_data offset 0x531 (6 bytes)
		db	3, 3, 3, 3, 3, 3                                   ; sprite_data offset 0x537 (6 bytes)
		db	3, 0, 0, 0, 0, 0                                   ; sprite_data offset 0x53D (6 bytes)
		db	0, 2, 0, 1, 1, 1                                   ; sprite_data offset 0x543 (6 bytes)
		db	1, 1, 1, 3, 3, 1                                   ; sprite_data offset 0x549 (6 bytes)
		db	1, 2, 2, 0, 3, 3                                   ; sprite_data offset 0x54F (6 bytes)
		db	3, 1, 1, 1, 1, 1                                   ; sprite_data offset 0x555 (6 bytes)
		db	1, 3, 3, 2, 1, 2                                   ; sprite_data offset 0x55B (6 bytes)
		db	3, 2, 3, 3, 3, 2                                   ; sprite_data offset 0x561 (6 bytes)
		db	2, 2, 2, 3, 3, 3                                   ; sprite_data offset 0x567 (6 bytes)
		db	3, 3, 1, 3, 3, 0                                   ; sprite_data offset 0x56D (6 bytes)
		db	3, 3, 3, 3, 1, 2                                   ; sprite_data offset 0x573 (6 bytes)
		db	2, 3, 3, 3, 3, 0                                   ; sprite_data offset 0x579 (6 bytes)
		db	0, 0, 0, 1, 1, 2                                   ; sprite_data offset 0x57F (6 bytes)
		db	3, 0, 0, 0, 2, 1                                   ; sprite_data offset 0x585 (6 bytes)
		db	1, 2, 3, 1, 1, 2                                   ; sprite_data offset 0x58B (6 bytes)
		db	3, 1, 1, 2, 1, 0                                   ; sprite_data offset 0x591 (6 bytes)
		db	1, 2, 2, 1, 1, 1                                   ; sprite_data offset 0x597 (6 bytes)
		db	1, 2, 2, 2, 3, 1                                   ; sprite_data offset 0x59D (6 bytes)
		db	1, 2, 2, 0, 2, 2                                   ; sprite_data offset 0x5A3 (6 bytes)
		db	2, 1, 1, 2, 3, 2                                   ; sprite_data offset 0x5A9 (6 bytes)
		db	2, 2, 3, 1, 1, 2                                   ; sprite_data offset 0x5AF (6 bytes)
		db	2, 2, 2, 2, 2, 1                                   ; sprite_data offset 0x5B5 (6 bytes)
		db	1, 2, 2, 1, 1, 1                                   ; sprite_data offset 0x5BB (6 bytes)
		db	3, 1, 1, 3, 3, 1                                   ; sprite_data offset 0x5C1 (6 bytes)
		db	1, 1, 1, 1, 1, 3                                   ; sprite_data offset 0x5C7 (6 bytes)
		db	3, 1, 1, 1, 3, 1                                   ; sprite_data offset 0x5CD (6 bytes)
		db	1, 3, 3, 1, 1, 1                                   ; sprite_data offset 0x5D3 (6 bytes)
		db	1, 1, 1, 3, 3, 2                                   ; sprite_data offset 0x5D9 (6 bytes)
		db	1, 2, 3, 3, 3, 3                                   ; sprite_data offset 0x5DF (6 bytes)
		db	3, 2, 1, 2, 2, 3                                   ; sprite_data offset 0x5E5 (6 bytes)
		db	3, 3, 3, 3, 1, 3                                   ; sprite_data offset 0x5EB (6 bytes)
		db	3, 3, 3, 3, 3, 3                                   ; sprite_data offset 0x5F1 (6 bytes)
		db	1, 3, 2, 3, 3, 3                                   ; sprite_data offset 0x5F7 (6 bytes)
		db	3, 0, 1, 0, 0, 1                                   ; sprite_data offset 0x5FD (6 bytes)
		db	1, 2, 1, 0, 1, 2                                   ; sprite_data offset 0x603 (6 bytes)
		db	2, 1, 1, 2, 3, 1                                   ; sprite_data offset 0x609 (6 bytes)
		db	1, 2, 2, 1, 1, 1                                   ; sprite_data offset 0x60F (6 bytes)
		db	1, 0, 1, 2, 2, 1                                   ; sprite_data offset 0x615 (6 bytes)
		db	1, 1, 1, 0                                         ; sprite_data offset 0x61B (4 bytes)
		db	7 dup (2)
		db	0, 2, 2, 2, 1, 1                                   ; sprite_data offset 0x626 (6 bytes)
		db	2, 3, 0, 2, 2, 2                                   ; sprite_data offset 0x62C (6 bytes)
		db	2, 2, 3, 2, 0, 3                                   ; sprite_data offset 0x632 (6 bytes)
		db	3, 3, 3, 3, 3, 3                                   ; sprite_data offset 0x638 (6 bytes)
		db	1, 1, 2, 2, 1, 1                                   ; sprite_data offset 0x63E (6 bytes)
		db	2, 3, 1, 1, 1, 1                                   ; sprite_data offset 0x644 (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; sprite_data offset 0x64A (6 bytes)
		db	2, 2, 1, 3, 3, 1                                   ; sprite_data offset 0x650 (6 bytes)
		db	1, 1, 1, 1, 1, 1                                   ; sprite_data offset 0x656 (6 bytes)
		db	3, 3, 2, 1, 2, 3                                   ; sprite_data offset 0x65C (6 bytes)
		db	2, 3, 3, 3, 2, 2                                   ; sprite_data offset 0x662 (6 bytes)
		db	2, 2, 3, 3, 3, 3                                   ; sprite_data offset 0x668 (6 bytes)
		db	1, 1, 2, 2, 3, 1                                   ; sprite_data offset 0x66E (6 bytes)
		db	3, 3, 3, 1, 2, 2                                   ; sprite_data offset 0x674 (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; sprite_data offset 0x67A (6 bytes)
		db	0, 0, 1, 1, 2, 3                                   ; sprite_data offset 0x680 (6 bytes)
		db	0, 0, 0, 2, 1, 1                                   ; sprite_data offset 0x686 (6 bytes)
		db	2, 3, 1, 1, 2, 3                                   ; sprite_data offset 0x68C (6 bytes)
		db	1, 1, 2, 1, 0, 1                                   ; sprite_data offset 0x692 (6 bytes)
		db	2, 2, 1, 1, 1, 1                                   ; sprite_data offset 0x698 (6 bytes)
		db	2, 2, 2, 3, 1, 1                                   ; sprite_data offset 0x69E (6 bytes)
		db	2, 2, 0, 2, 2, 2                                   ; sprite_data offset 0x6A4 (6 bytes)
		db	1, 1, 2, 3, 2, 2                                   ; sprite_data offset 0x6AA (6 bytes)
		db	2, 3, 1, 1, 2, 2                                   ; sprite_data offset 0x6B0 (6 bytes)
		db	2, 2, 2, 2, 1, 1                                   ; sprite_data offset 0x6B6 (6 bytes)
		db	2, 2, 1, 1, 1, 3                                   ; sprite_data offset 0x6BC (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; sprite_data offset 0x6C2 (6 bytes)
		db	1, 1, 1, 1, 3, 3                                   ; sprite_data offset 0x6C8 (6 bytes)
		db	1, 1, 1, 3, 1, 1                                   ; sprite_data offset 0x6CE (6 bytes)
		db	3, 3, 1, 1, 1, 1                                   ; sprite_data offset 0x6D4 (6 bytes)
		db	1, 1, 3, 3, 2, 1                                   ; sprite_data offset 0x6DA (6 bytes)
		db	2, 3, 3, 3, 3, 3                                   ; sprite_data offset 0x6E0 (6 bytes)
		db	2, 1, 2, 2, 3, 3                                   ; sprite_data offset 0x6E6 (6 bytes)
		db	3, 3, 3, 1, 3, 3                                   ; sprite_data offset 0x6EC (6 bytes)
		db	3, 3, 3, 3, 3, 1                                   ; sprite_data offset 0x6F2 (6 bytes)
		db	3, 2, 3, 3, 3, 3                                   ; sprite_data offset 0x6F8 (6 bytes)
		db	0, 0, 0, 0, 0, 1                                   ; sprite_data offset 0x6FE (6 bytes)
		db	2, 3, 0, 1, 2, 2                                   ; sprite_data offset 0x704 (6 bytes)
		db	1, 1, 2, 3, 0, 1                                   ; sprite_data offset 0x70A (6 bytes)
		db	2, 1, 0, 1, 1, 1                                   ; sprite_data offset 0x710 (6 bytes)
		db	0, 1, 2, 2, 1, 1                                   ; sprite_data offset 0x716 (6 bytes)
		db	1, 1, 0, 2, 2, 1                                   ; sprite_data offset 0x71C (6 bytes)
		db	0, 2, 2, 3, 0, 2                                   ; sprite_data offset 0x722 (6 bytes)
		db	2, 2, 1, 1, 2, 3                                   ; sprite_data offset 0x728 (6 bytes)
		db	0, 1, 1, 1, 0, 1                                   ; sprite_data offset 0x72E (6 bytes)
		db	2, 3, 0, 3, 3, 3                                   ; sprite_data offset 0x734 (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; sprite_data offset 0x73A (6 bytes)
		db	0, 0, 0, 0, 2, 0                                   ; sprite_data offset 0x740 (6 bytes)
		db	1, 1, 1, 1, 1, 1                                   ; sprite_data offset 0x746 (6 bytes)
		db	3, 3, 1, 1, 2, 1                                   ; sprite_data offset 0x74C (6 bytes)
		db	0, 3, 3, 3, 1, 1                                   ; sprite_data offset 0x752 (6 bytes)
		db	1, 1, 1, 1, 3, 3                                   ; sprite_data offset 0x758 (6 bytes)
		db	2, 1, 2, 2, 2, 3                                   ; sprite_data offset 0x75E (6 bytes)
		db	3, 3, 2, 2, 2, 2                                   ; sprite_data offset 0x764 (6 bytes)
		db	3, 3, 3, 3, 3, 1                                   ; sprite_data offset 0x76A (6 bytes)
		db	3, 3, 0, 3, 3, 3                                   ; sprite_data offset 0x770 (6 bytes)
		db	3, 1, 2, 2, 3, 3                                   ; sprite_data offset 0x776 (6 bytes)
		db	3, 3, 0, 0, 0, 0                                   ; sprite_data offset 0x77C (6 bytes)
		db	1, 1, 2, 3, 0, 0                                   ; sprite_data offset 0x782 (6 bytes)
		db	0, 2, 1, 1, 2, 3                                   ; sprite_data offset 0x788 (6 bytes)
		db	1, 1, 2, 3, 1, 1                                   ; sprite_data offset 0x78E (6 bytes)
		db	2, 1, 0, 1, 2, 2                                   ; sprite_data offset 0x794 (6 bytes)
		db	1, 1, 1, 1, 2, 2                                   ; sprite_data offset 0x79A (6 bytes)
		db	2, 3, 1, 1, 2, 2                                   ; sprite_data offset 0x7A0 (6 bytes)
		db	0, 2, 2, 2, 1, 1                                   ; sprite_data offset 0x7A6 (6 bytes)
		db	2, 3, 2, 2, 2, 3                                   ; sprite_data offset 0x7AC (6 bytes)
		db	1, 1, 2, 2, 2, 2                                   ; sprite_data offset 0x7B2 (6 bytes)
		db	2, 2, 1, 1, 2, 2                                   ; sprite_data offset 0x7B8 (6 bytes)
		db	1, 1, 1, 3, 1, 1                                   ; sprite_data offset 0x7BE (6 bytes)
		db	3, 3, 1, 1, 1, 1                                   ; sprite_data offset 0x7C4 (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; sprite_data offset 0x7CA (6 bytes)
		db	1, 3, 1, 1, 3, 3                                   ; sprite_data offset 0x7D0 (6 bytes)
		db	1, 1, 1, 1, 1, 1                                   ; sprite_data offset 0x7D6 (6 bytes)
		db	3, 3, 2, 1, 2, 3                                   ; sprite_data offset 0x7DC (6 bytes)
		db	3, 3, 3, 3, 2, 1                                   ; sprite_data offset 0x7E2 (6 bytes)
		db	2, 2, 3, 3, 3, 3                                   ; sprite_data offset 0x7E8 (6 bytes)
		db	3, 1, 3, 3, 3, 3                                   ; sprite_data offset 0x7EE (6 bytes)
		db	3, 3, 3, 1, 3, 2                                   ; sprite_data offset 0x7F4 (6 bytes)
		db	3, 3, 3, 3, 0, 0                                   ; sprite_data offset 0x7FA (6 bytes)
		db	0, 1, 1, 1, 2, 3                                   ; sprite_data offset 0x800 (6 bytes)
		db	0, 1, 2, 2, 1, 1                                   ; sprite_data offset 0x806 (6 bytes)
		db	2, 3, 0, 1, 2, 2                                   ; sprite_data offset 0x80C (6 bytes)
		db	1, 1, 1, 1, 0, 1                                   ; sprite_data offset 0x812 (6 bytes)
		db	2, 2, 1, 1, 1, 1                                   ; sprite_data offset 0x818 (6 bytes)
		db	0, 2, 2, 2, 1, 1                                   ; sprite_data offset 0x81E (6 bytes)
		db	2, 3, 0, 2, 2, 2                                   ; sprite_data offset 0x824 (6 bytes)
		db	1, 1, 2, 3, 1                                      ; sprite_data offset 0x82A (5 bytes)
		db	7 dup (2)
		db	0, 2, 2, 2, 2, 2                                   ; sprite_data offset 0x836 (6 bytes)
		db	2, 2, 1, 1, 1, 2                                   ; sprite_data offset 0x83C (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; sprite_data offset 0x842 (6 bytes)
		db	1, 1, 1, 1, 3, 3                                   ; sprite_data offset 0x848 (6 bytes)
		db	1, 1, 1, 2, 1, 1                                   ; sprite_data offset 0x84E (6 bytes)
		db	2, 2, 1, 1, 1, 1                                   ; sprite_data offset 0x854 (6 bytes)
		db	1, 1, 2, 2, 2, 1                                   ; sprite_data offset 0x85A (6 bytes)
		db	2, 2, 3, 2, 3, 3                                   ; sprite_data offset 0x860 (6 bytes)
		db	2, 2, 2, 2, 3, 3                                   ; sprite_data offset 0x866 (6 bytes)
		db	3, 3, 3, 1, 3, 2                                   ; sprite_data offset 0x86C (6 bytes)
		db	3, 2, 3, 3, 3, 1                                   ; sprite_data offset 0x872 (6 bytes)
		db	2, 2, 3, 3, 3, 3                                   ; sprite_data offset 0x878 (6 bytes)
		db	0, 0, 0, 0, 1, 1                                   ; sprite_data offset 0x87E (6 bytes)
		db	2, 3, 0, 0, 0, 2                                   ; sprite_data offset 0x884 (6 bytes)
		db	1, 1, 2, 3, 1, 1                                   ; sprite_data offset 0x88A (6 bytes)
		db	2, 3, 1, 1, 2, 1                                   ; sprite_data offset 0x890 (6 bytes)
		db	0, 1, 2, 2, 1, 1                                   ; sprite_data offset 0x896 (6 bytes)
		db	1, 1, 2, 2, 2, 3                                   ; sprite_data offset 0x89C (6 bytes)
		db	1, 1, 2, 2, 0, 2                                   ; sprite_data offset 0x8A2 (6 bytes)
		db	2, 2, 1, 1, 2, 3                                   ; sprite_data offset 0x8A8 (6 bytes)
		db	2, 2, 2, 3, 1, 1                                   ; sprite_data offset 0x8AE (6 bytes)
		db	2, 2, 2, 2, 2, 2                                   ; sprite_data offset 0x8B4 (6 bytes)
		db	1, 1, 2, 2, 1, 1                                   ; sprite_data offset 0x8BA (6 bytes)
		db	1, 3, 1, 1, 3, 3                                   ; sprite_data offset 0x8C0 (6 bytes)
		db	1, 1, 1, 1, 1, 1                                   ; sprite_data offset 0x8C6 (6 bytes)
		db	3, 3, 1, 1, 1, 3                                   ; sprite_data offset 0x8CC (6 bytes)
		db	1, 1, 3, 3, 1, 1                                   ; sprite_data offset 0x8D2 (6 bytes)
		db	1, 1, 1, 1, 3, 3                                   ; sprite_data offset 0x8D8 (6 bytes)
		db	2, 1, 2, 3, 3, 2                                   ; sprite_data offset 0x8DE (6 bytes)
		db	3, 3, 2, 1, 2, 2                                   ; sprite_data offset 0x8E4 (6 bytes)
		db	3, 3, 3, 3, 3, 1                                   ; sprite_data offset 0x8EA (6 bytes)
		db	3, 3, 3, 2, 3, 3                                   ; sprite_data offset 0x8F0 (6 bytes)
		db	3, 1, 3, 2, 3, 3                                   ; sprite_data offset 0x8F6 (6 bytes)
		db	3, 3                                               ; sprite_data offset 0x8FC (2 bytes)

copy_status_loop_hgc		proc	near
		push	cx
		push	si
		mov	si,cs:render_lut_ptr
		mov	cx,8

process5_bit_loop:
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
								loop	process5_bit_loop		; Loop if cx > 0

		pop	si
		pop	cx
		retn

copy_status_loop_hgc		endp

hgc_capture_entry:
		push	ds
		mov	ax,hgc_seg
		mov	ds,ax
		mov	si,hgc_capture_src
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,hgc_buf_start
		mov	cx,0C8h

hgc_capture_loop:
								push	cx
								push	si
								mov	cx,28h
								rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
								pop	si
								add	si,2000h
								cmp	si,hgc_bank1_end
								jb	hgc_capture_wrap			; Jump if below
								add	si,hgc_bank2_wrap

hgc_capture_wrap:
								pop	cx
								loop	hgc_capture_loop		; Loop if cx > 0

		pop	ds
		xor	ax,ax			; Zero register
		mov	di,hgc_work_buf
		mov	cx,2000h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

color_xlat_dispatch_entry:
		push	bx
		mov	bl,ah
		xor	bh,bh			; Zero register
		mov	ah,cs:hgc_color_lut[bx]
		pop	bx
		jmp	word ptr cs:hgc_dispatch_fn
		db	 00h, 05h, 02h, 07h, 03h, 04h	; hgc_color_lut[0..5]: 0,5,2,7,3,4
		db	 06h, 01h,0C3h			; hgc_color_lut[6..7]=6,1; retn (C3h)

math_calc		proc	near
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

math_calc		endp

		db	888 dup (0)

seg_a		ends

		end	start
