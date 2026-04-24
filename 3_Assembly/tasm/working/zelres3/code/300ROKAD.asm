
PAGE  59,132

;==========================================================================
;
;  300ROKAD.BIN - Roka Demo Scene (ROKADEMO.BIN, zelres3 chunk 1)
;
;  Animated demo / cutscene sequence played between gameplay transitions
;  (e.g. entering a new area or on game-over/victory). It loads the
;  "Roka" character sprites and walks them through 9 staged poses on
;  a map background, then plays an end fanfare.
;
;  Load chain (see SAR ref table in 200FIGHT.asm):
;    zelres2 chunk 1  ROKADEMO.BIN    - this module (code)
;    zelres3 chunk 54 '6DMAN.GRP'     - Roka character sprite set (ref at 0A5AAh)
;    zelres3 chunk 95 '_MFAN.MSD'     - Roka fanfare music       (ref at 0A5A1h)
;
;  Structure:
;    roka_demo_main    - main entry:
;        1. load graphics driver chunk (idx 5) into DS:3000h
;        2. load sprite chunk ref 0A58Fh into DS:6000h
;        3. decode sprite palette/tiles via gfx_setup_fn
;        4. increment scene counter gvar_roka_scene (clamped to 9)
;        5. palette wipe + per-frame poses in 9 loops over lvload_render/step
;        6. compute Bresenham-style line interpolation between current pose
;           and target pose via compute_line_delta / step_line
;        7. fire INT 60h to play fanfare music (passing music chunk ref)
;        8. tear-down: reverse palette wipe, int 60h stop, return
;
;    draw_pose_3x3     - render 3x3 sprite tile at [BX] (reads 9 tile indices)
;    wait_frame        - tick frame timer (waits for gvar_timer_lo >= 4*speed)
;    compute_line_delta- compute |dx|, |dy|, signs, major axis (Bresenham setup)
;    step_line         - step one pixel along line (Bresenham error update)
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; --- Graphics driver dispatch table (in this module's CS segment) ---
gfx_fillrect_fn	equ	2000h			; fill rectangle (BX=base, CX=size word, AL=color)
gfx_tile_fn	equ	2026h			; tile / sprite blit fn (AH,AL coords, CX size, DI clip)
gfx_tile_fn_b	equ	2028h			; alt tile / sprite blit fn
gfx_scene_fn	equ	203Eh			; palette/scene setup fn (BX=params)
gfx_sprite_plot	equ	3022h			; plot sprite via AL index, BX coords (called by draw_pose_3x3)
gfx_palette_fn	equ	3024h			; palette switch (AX=palette index)
gfx_tile_draw	equ	3026h			; draw tile (AL=tile, BL=row, CL=col)
gfx_decode_fn	equ	3028h			; decode sprite palette/tile buffer (SI=src, BP=dst, CX=count)

; --- Sprite data base in game_seg (loaded at DS:6000h by chunk loader) ---
sprite_base_a	equ	84BEh			; sprite animation frame data base

; --- Scene state / demo control vars (game_seg, DS-relative) ---
pose_table_base	equ	0A569h			; target-pose-table base (indexed by scene 1..9)
pose_vec_table	equ	0A572h			; pose-vector lookup word table (indexed per scene)
cur_pose_y	equ	0A59Ah			; current pose row (Y) byte
cur_pose_x	equ	0A59Bh			; current pose col (X) byte, init=2
bres_target_y	equ	0A59Ch			; line-interp: target Y byte
bres_target_x	equ	0A59Dh			; line-interp: target X byte
bres_sign_y	equ	0A59Eh			; line-interp: sign of dy (-1/0/+1)
bres_sign_x	equ	0A59Fh			; line-interp: sign of dx (-1/0/+1)
sar_ref_music	equ	0A5A0h			; SAR ref: '_MFAN.MSD' (INT 60h music param)
bres_dy		equ	0A5A1h			; line-interp: |dy|
bres_dx		equ	0A5A2h			; line-interp: |dx|
bres_error	equ	0A5A3h			; line-interp: error accumulator
bres_major_y	equ	0A5A4h			; line-interp: 0=x-major, 0FFh=y-major
blink_byte	equ	0A5A4h			; alias (Sourcer gave two labels to same addr)
roka_pose_idx	equ	0A5A4h			; active pose index (0..8)
blink_timer	equ	0A5A5h			; blink / sub-step counter byte
blink_timer_b	equ	0A5A6h			; secondary blink/cycle byte
blink_state	equ	0A5A7h			; blink/anim state byte

; --- Global variables (game_seg:0xFFxx) ---
gvar_timer_lo	equ	0FF1Ah			; frame timer low byte (zeliard.inc)
gvar_enable_all	equ	0FF26h			; enable-all flag byte (zeliard.inc)
gvar_game_seg	equ	0FF2Ch			; game segment selector word (zeliard.inc)
gvar_anim_speed	equ	0FF33h			; animation speed counter byte
gvar_volume_b	equ	0FF75h			; audio volume/env byte (zeliard.inc)

; Backwards-compat aliases (original Sourcer-generated names kept for now)
data_6e		equ	gfx_fillrect_fn
data_7e		equ	gfx_tile_fn
data_8e		equ	gfx_tile_fn_b
data_9e		equ	gfx_scene_fn
data_10e	equ	gfx_sprite_plot
data_11e	equ	gfx_palette_fn
data_12e	equ	gfx_tile_draw
data_13e	equ	gfx_decode_fn
data_14e	equ	sprite_base_a
data_15e	equ	pose_table_base
data_16e	equ	pose_vec_table
data_17e	equ	cur_pose_y
data_18e	equ	cur_pose_x
data_19e	equ	bres_target_y
data_20e	equ	bres_target_x
data_21e	equ	bres_sign_y
data_22e	equ	bres_sign_x
data_23e	equ	sar_ref_music
data_24e	equ	bres_dy
data_25e	equ	bres_dx
data_26e	equ	bres_error
data_27e	equ	roka_pose_idx
data_28e	equ	blink_timer
data_29e	equ	blink_timer_b
data_30e	equ	blink_state
data_31e	equ	gvar_timer_lo
data_32e	equ	gvar_enable_all
data_33e	equ	gvar_game_seg
data_34e	equ	gvar_anim_speed
data_35e	equ	gvar_volume_b

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

roka_demo_main	proc	far

start:
		test	al,5
		add	[bx+si],al
		add	ah,ds:data_14e[bx+si]
		movsw				; Mov [si] to es:[di]
		mov	es,cs:data_33e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	es,cs:data_33e
		mov	si,0A58Fh
		mov	di,6000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_33e
		mov	si,6000h
		mov	bp,0D000h
		mov	cx,100h
		call	word ptr cs:data_13e
		pop	ds
		inc	byte ptr ds:[0A0h]
		mov	al,0
		cmp	byte ptr ds:[0A0h],9
		jb	loc_1			; Jump if below
		mov	byte ptr ds:[0A0h],9
		mov	al,1
loc_1:
		mov	ds:data_27e,al
		mov	bx,2552h
		call	word ptr cs:data_9e
		and	byte ptr ds:[0C2h],0FEh
		mov	bx,0C6Eh
		mov	cx,0Dh

locloop_2:
		test	cx,1
		jnz	loc_3			; Jump if not zero
		mov	byte ptr ds:data_35e,1Ah
loc_3:
		push	cx
		push	bx
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],3
		call	draw_pose_3x3
		call	wait_frame
		pop	bx
		cmp	bh,24h			; '$'
		je	loc_4			; Jump if equal
		push	bx
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:data_6e
		pop	bx
		add	bh,2
loc_4:
		pop	cx
		loop	locloop_2		; Loop if cx > 0

		mov	byte ptr ds:[0E7h],4
		mov	bx,246Eh
		call	draw_pose_3x3
		mov	cx,5

locloop_5:
		push	cx
		call	wait_frame
		pop	cx
		loop	locloop_5		; Loop if cx > 0

		mov	byte ptr ds:[0E7h],5
loc_6:
		mov	bx,246Eh
		call	draw_pose_3x3
		call	wait_frame
		call	wait_frame
		inc	byte ptr ds:[0E7h]
		cmp	byte ptr ds:[0E7h],9
		jb	loc_6			; Jump if below
		mov	bx,246Eh
		call	draw_pose_3x3
		call	word ptr cs:data_11e
		xor	bh,bh			; Zero register
		mov	bl,byte ptr ds:[0A0h]
		dec	bx
		mov	al,ds:data_15e[bx]
		mov	ds:data_17e,al
		mov	byte ptr ds:data_18e,2
		call	bres_setup
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	byte ptr ds:data_28e,0
loc_7:
		mov	al,ds:data_28e
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	wait_frame
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		inc	byte ptr ds:data_28e
		cmp	byte ptr ds:data_28e,2
		jb	loc_7			; Jump if below
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,6
		mov	al,ds:data_20e
		mov	cx,1110h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	byte ptr ds:data_35e,1Bh
		mov	byte ptr ds:data_28e,0
loc_8:
		mov	al,ds:data_28e
		or	al,80h
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		sub	bx,18h
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	wait_frame
		call	wait_frame
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,6
		mov	al,ds:data_20e
		mov	cx,1110h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		inc	byte ptr ds:data_28e
		cmp	byte ptr ds:data_28e,2
		jb	loc_8			; Jump if below
		mov	bx,2552h
		mov	cx,410h
		xor	al,al			; Zero register
		call	word ptr cs:data_6e
		call	word ptr cs:data_11e
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	byte ptr ds:data_28e,0
loc_9:
		mov	al,ds:data_28e
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	wait_frame
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		inc	byte ptr ds:data_28e
		cmp	byte ptr ds:data_28e,4
		jb	loc_9			; Jump if below
		mov	byte ptr ds:data_30e,0C8h
loc_10:
		inc	byte ptr ds:data_29e
		test	byte ptr ds:data_29e,1
		jnz	loc_11			; Jump if not zero
		inc	byte ptr ds:data_28e
		inc	byte ptr ds:data_30e
		cmp	byte ptr ds:data_30e,3
		jb	loc_11			; Jump if below
		mov	byte ptr ds:data_30e,0
		mov	byte ptr ds:data_35e,1Ch
loc_11:
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		call	bres_step
		pushf				; Push flags
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	al,ds:data_28e
		and	al,1
		add	al,2
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	wait_frame
		popf				; Pop flags
		jnc	loc_10			; Jump if carry=0
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,6
		mov	al,ds:data_20e
		mov	cx,1110h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	byte ptr ds:data_35e,1Bh
		mov	byte ptr ds:data_28e,0
loc_12:
		mov	al,ds:data_28e
		or	al,80h
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		sub	bx,18h
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	wait_frame
		call	wait_frame
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,6
		mov	al,ds:data_20e
		mov	cx,1110h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		inc	byte ptr ds:data_28e
		cmp	byte ptr ds:data_28e,2
		jb	loc_12			; Jump if below
		mov	al,ds:data_27e
		mov	bl,byte ptr ds:[0A0h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	bx,ds:data_16e[bx]
		call	word ptr cs:data_9e
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	byte ptr ds:data_28e,4
loc_13:
		mov	al,ds:data_28e
		dec	al
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	wait_frame
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		dec	byte ptr ds:data_28e
		jnz	loc_13			; Jump if not zero
		push	ds
		mov	ds,cs:data_33e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
loc_14:
		test	byte ptr ds:data_32e,0FFh
		jz	loc_14			; Jump if zero
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	bx,2456h
		mov	cx,618h
		xor	al,al			; Zero register
		call	word ptr cs:data_6e
		mov	byte ptr ds:[0E7h],8
loc_15:
		mov	bx,246Eh
		call	draw_pose_3x3
		call	wait_frame
		call	wait_frame
		dec	byte ptr ds:[0E7h]
		cmp	byte ptr ds:[0E7h],5
		jae	loc_15			; Jump if above or =
		mov	bx,246Eh
		call	draw_pose_3x3
		mov	cx,5

locloop_16:
		push	cx
		call	wait_frame
		pop	cx
		loop	locloop_16		; Loop if cx > 0

		mov	bx,246Eh
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:data_6e
		mov	bx,266Eh
		mov	cx,0Dh

locloop_17:
		test	cx,1
		jnz	loc_18			; Jump if not zero
		mov	byte ptr ds:data_35e,1Ah
loc_18:
		push	cx
		push	bx
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],3
		call	draw_pose_3x3
		call	wait_frame
		pop	bx
		cmp	bh,3Eh			; '>'
		je	loc_19			; Jump if equal
		push	bx
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:data_6e
		pop	bx
		add	bh,2
loc_19:
		pop	cx
		loop	locloop_17		; Loop if cx > 0

		mov	cx,618h
		xor	al,al			; Zero register
		jmp	word ptr cs:data_6e

roka_demo_main	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

draw_pose_3x3		proc	near
		mov	al,byte ptr ds:[0E7h]
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,0A435h
		mov	si,ax
		mov	cx,3

locloop_20:
		push	cx
		mov	cx,3

locloop_21:
		push	cx
		lodsb				; String [si] to al
		push	si
		push	bx
		call	word ptr cs:data_10e
		pop	bx
		pop	si
		add	bl,8
		pop	cx
		loop	locloop_21		; Loop if cx > 0

		sub	bl,18h
		add	bh,2
		pop	cx
		loop	locloop_20		; Loop if cx > 0

		retn
draw_pose_3x3		endp

		db	 00h, 02h, 04h, 01h, 03h, 05h
		db	 00h, 00h, 06h, 07h, 09h, 0Bh
		db	 08h, 0Ah, 0Ch, 00h, 00h, 00h
		db	 00h, 02h, 0Eh, 01h, 0Dh, 0Fh
		db	 00h, 00h, 10h, 07h, 09h, 11h
		db	 08h, 0Ah, 12h, 00h, 00h, 00h
		db	 00h, 14h, 16h, 13h, 15h, 17h
		db	 00h, 00h, 18h, 19h, 00h, 1Ch
		db	 1Ah, 1Bh, 1Dh, 00h, 00h, 1Eh
		db	 1Fh, 00h, 23h, 20h, 21h, 24h
		db	 00h, 22h, 25h, 1Fh, 00h, 23h
		db	 20h, 26h, 28h, 00h, 27h, 29h
		db	 1Fh, 00h
		db	'#*,(+-).1#/24035'

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

wait_frame		proc	near
		mov	cl,ds:data_34e
		mov	al,4
		mul	cl			; ax = reg * al
loc_22:
		cmp	ds:data_31e,al
		jb	loc_22			; Jump if below
		mov	byte ptr ds:data_31e,0
		retn
wait_frame		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

bres_setup		proc	near
		mov	byte ptr ds:data_19e,94h
		mov	byte ptr ds:data_20e,50h	; 'P'
		xor	cl,cl			; Zero register
		mov	al,ds:data_17e
		sub	al,ds:data_19e
		jz	loc_24			; Jump if zero
		jnc	loc_23			; Jump if carry=0
		neg	al
		dec	cl
		jmp	short loc_24
loc_23:
		inc	cl
loc_24:
		mov	ds:data_23e,al
		mov	ds:data_21e,cl
		xor	cl,cl			; Zero register
		mov	al,ds:data_18e
		sub	al,ds:data_20e
		jz	loc_26			; Jump if zero
		jnc	loc_25			; Jump if carry=0
		neg	al
		dec	cl
		jmp	short loc_26
loc_25:
		inc	cl
loc_26:
		mov	ds:data_24e,al
		mov	ds:data_22e,cl
		mov	al,ds:data_23e
		shr	al,1			; Shift w/zeros fill
		mov	ds:data_26e,al
		mov	byte ptr ds:data_25e,0
		mov	al,ds:data_23e
		cmp	al,ds:data_24e
		jb	loc_27			; Jump if below
		retn
loc_27:
		mov	al,ds:data_24e
		shr	al,1			; Shift w/zeros fill
		mov	ds:data_26e,al
		mov	byte ptr ds:data_25e,0FFh
		retn
bres_setup		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

bres_step		proc	near
		test	byte ptr ds:data_25e,0FFh
		jnz	loc_30			; Jump if not zero
		mov	al,ds:data_26e
		sub	al,ds:data_24e
		jnc	loc_28			; Jump if carry=0
		add	al,ds:data_23e
		mov	ah,ds:data_22e
		add	ds:data_20e,ah
loc_28:
		mov	ds:data_26e,al
		mov	al,ds:data_21e
		add	ds:data_19e,al
		mov	al,ds:data_17e
		cmp	al,ds:data_19e
		stc				; Set carry flag
		jnz	loc_29			; Jump if not zero
		retn
loc_29:
		clc				; Clear carry flag
		retn
loc_30:
		mov	al,ds:data_26e
		sub	al,ds:data_23e
		jnc	loc_31			; Jump if carry=0
		add	al,ds:data_24e
		mov	ah,ds:data_21e
		add	ds:data_19e,ah
loc_31:
		mov	ds:data_26e,al
		mov	al,ds:data_22e
		add	ds:data_20e,al
		mov	al,ds:data_18e
		cmp	al,ds:data_20e
		stc				; Set carry flag
		jnz	loc_32			; Jump if not zero
		retn
loc_32:
		clc				; Clear carry flag
		retn
bres_step		endp

; --- Demo data tables (referenced via pose_table_base / pose_vec_table) ---
; 9-entry palette/color lookup table (indexed 1..9 by roka_pose_idx):
pose_palette_tbl:
		db	 3Ch,0F4h, 54h,0DCh, 6Ch,0C4h, 84h,0ACh, 98h
; 9-entry (Y,X) target-position table, one word per pose:
pose_target_tbl:
		db	 00h, 0Fh			; pose 1: (Y=0x00, X=0x0F)
		db	 00h, 3Dh			; pose 2: (Y=0x00, X=0x3D)
		db	 00h, 15h			; pose 3: (Y=0x00, X=0x15)
		db	 00h, 37h			; pose 4: (Y=0x00, X=0x37)
		db	 00h, 1Bh			; pose 5: (Y=0x00, X=0x1B)
		db	 00h, 31h			; pose 6: (Y=0x00, X=0x31)
		db	 00h, 21h			; pose 7: (Y=0x00, X=0x21)
		db	 00h, 2Bh			; pose 8: (Y=0x00, X=0x2B)
		db	 00h, 26h			; pose 9: (Y=0x00, X=0x26)
; SAR chunk reference records consumed via INT 60h / chunk loader.
; Format (from 200FIGHT resource_name_table): shared null serves both
; as previous record terminator and next record's chunk id.
; Referenced via sar_ref_music (pointer starts at 0A5A0h = byte before '_').
ref_mfan_msd:
		db	02h				; chunk id = 2
		db	'_MFAN.MSD'			; zelres3 chunk 95: Roka fanfare music
		db	0, 2				; NUL + archive = 2 (zelres3) for next rec
ref_6dman_grp:
		db	'6DMAN.GRP'			; zelres3 chunk 54: Roka/6DMAN character sprites
		db	15 dup (0)

seg_a		ends



		end	start
