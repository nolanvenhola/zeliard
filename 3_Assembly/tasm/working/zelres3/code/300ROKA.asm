
PAGE  59,132

;==========================================================================
;
;  300ROKA.BIN - Roka Demo Scene (ROKADEMO.BIN, zelres3 chunk 1)
;
;  Animated demo / cutscene played at game start (and between certain
;  gameplay transitions).  Loads the "Roka" character sprites and walks
;  them through 9 staged poses on a map background, then fires an end
;  fanfare.  Loaded by 200FIGHT (resource_name_table @ ~7941) into
;  game_seg:0xA000 and entered far at offset +9 (the first 9 bytes are a
;  file-length header + caller-pre-init bytes; Sourcer mis-decoded them
;  as instructions starting at start: -- they are not executed).
;
;  Resource records (in this module's tail data, reached via DS:SI):
;    [0xA588] ref_mfan_msd   = 02h '_MFAN.MSD' 00 (zelres3, chunk 95)
;    [0xA593] ref_6dman_grp  = 02h '6DMAN.GRP' 00 (zelres3, chunk 54)
;
;  Public structure:
;    roka_demo_main    - far entry @ +9; loads driver+sprite chunks,
;                        runs intro-wipe, 9-pose pose loop, line-interp
;                        movement to target pose, fanfare INT 60h, then
;                        out-wipe and return to caller.
;    draw_pose_3x3     - render 3x3 sprite-tile grid for current pose
;                        ([0xE7]); reads 9 tile indices from pose_tile_data.
;    wait_frame        - tick frame timer (waits for gvar_timer_lo >=
;                        4*gvar_anim_speed).
;    bres_setup        - compute |dx|, |dy|, signs, major axis for line
;                        interpolation between current and (94h,50h).
;    bres_step         - step one pixel along the interpolated line;
;                        sets CF=1 when target reached.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; --- Graphics driver dispatch table (CS-relative function pointers in
; this module's segment, populated by the loaded driver chunk at +3000h).
;
gfx_fillrect_fn	equ	2000h			; fill rectangle (BX=base, CX=size word, AL=color)
gfx_blit_fn	equ	2026h			; tile/sprite blit  (AH,AL coords, CX size, DI clip)
gfx_blit_fn_b	equ	2028h			; alt tile/sprite blit (used in 'erase' phase)
gfx_scene_fn	equ	203Eh			; palette / scene setup fn (BX = pose-vec table entry)
gfx_sprite_plot	equ	3022h			; plot tile by AL=index, BX=row/col packed
gfx_palette_fn	equ	3024h			; palette wipe / switch (no params)
gfx_tile_draw	equ	3026h			; draw tile (AL=tile, BL=row, CL=col)
gfx_decode_fn	equ	3028h			; decode sprite palette/tile buffer (SI=src,BP=dst,CX=count)

; --- Scene-tile pose table base used by draw_pose_3x3 ---
;     Code computes SI = tile_pose_tbl_base + (scene_idx * 9) and reads 9
;     tile indices for a 3x3 grid.  The actual table data starts at
;     pose_tile_data (= tile_pose_tbl_base + 4); the first 4 bytes 0A435h
;     fall inside draw_pose_3x3's epilogue and are never read because
;     scene_idx 0 is unused.
tile_pose_tbl_base equ	0A435h

; --- Demo data table bases (ds, in this module's tail data) ---
pose_y_tbl_base	equ	0A569h			; per-scene Y-target byte; read as [base+bx], bx=scene-1
pose_vec_tbl_base equ	0A572h			; per-scene pose-vector word; read as [base+2*bx]

; --- Scene state / demo control vars (DS = game_seg) ---
gvar_roka_scene	equ	000A0h			; demo scene counter (1..9), bumped per call
gvar_pose_idx	equ	000E7h			; live pose index used by draw_pose_3x3
cur_pose_y	equ	0A59Ah			; current pose row (Y) byte
cur_pose_x	equ	0A59Bh			; current pose col (X) byte, init = 2
bres_pos_y	equ	0A59Ch			; line-interp: current Y (target = 94h, see bres_setup)
bres_pos_x	equ	0A59Dh			; line-interp: current X (target = 50h)
bres_sign_y	equ	0A59Eh			; line-interp: sign of dy (-1 / 0 / +1)
bres_sign_x	equ	0A59Fh			; line-interp: sign of dx (-1 / 0 / +1)
bres_pos_x_2	equ	0A5A0h			; alt copy of bres x (set by bres_setup)
bres_dy		equ	0A5A1h			; line-interp: |dy|
bres_dx		equ	0A5A2h			; line-interp: |dx|
bres_error	equ	0A5A3h			; line-interp: error accumulator
roka_pose_idx	equ	0A5A4h			; active pose index byte (0..8)
draw_phase_aux	equ	0A5A5h			; secondary phase / sub-step byte
draw_phase_state equ	0A5A6h			; phase state low byte
draw_phase_pal	equ	0A5A7h			; palette-cycle phase byte (cycles 0C8h..0C8h+2)

; --- Global variables (game_seg, DS-relative; mirrors zeliard.inc) ---
gvar_timer_lo	equ	0FF1Ah			; frame timer low byte
gvar_enable_all	equ	0FF26h			; enable-all flag byte
gvar_game_seg	equ	0FF2Ch			; game segment selector word
gvar_anim_speed	equ	0FF33h			; animation speed counter byte
gvar_volume_b	equ	0FF75h			; audio volume / env byte

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

roka_demo_main	proc	far

; ----------------------------------------------------------------------
; File header (bytes 0x000..0x008 of the loaded image; never executed).
;   Sourcer disassembled these bytes as instructions starting at start:
;   (test al,5 / add [bx+si],al / add ah,ds:84BEh[bx+si] / movsw) but
;   they are not actually instructions - the entry vector for the far
;   call lands at +9 (the mov es,cs:gvar_game_seg below).
;
;   0x00..0x03 : file length word + pad   = 0x05A8, 0x0000
;   0x04..0x05 : caller ABI dst-base init = 02 A0  (= chunk-loader DI = 0xA002)
;   0x06..0x08 : caller ABI src-base init = BE 84 A5 (= "mov si,0A584h"
;                                                       + a movsw)
; ----------------------------------------------------------------------

start:
		db	0A8h, 05h, 00h, 00h	; file size word (0x05A8) + pad
		db	02h, 0A0h		; caller ABI: chunk-loader dst high
		db	0BEh, 84h, 0A5h		; caller ABI: chunk-loader src-base bytes
		mov	es,cs:gvar_game_seg
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,0A58Fh
		mov	di,6000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,6000h
		mov	bp,0D000h
		mov	cx,100h
		call	word ptr cs:gfx_decode_fn
		pop	ds
		inc	byte ptr ds:gvar_roka_scene
		mov	al,0
		cmp	byte ptr ds:gvar_roka_scene,9
		jb	scene_clamp_done			; Jump if below
		mov	byte ptr ds:gvar_roka_scene,9
		mov	al,1

scene_clamp_done:
		mov	ds:roka_pose_idx,al
		mov	bx,2552h
		call	word ptr cs:gfx_scene_fn
		and	byte ptr ds:[0C2h],0FEh
		mov	bx,0C6Eh
		mov	cx,0Dh

intro_wipe_loop:
			test	cx,1
			jnz	intro_wipe_step			; Jump if not zero
			mov	byte ptr ds:gvar_volume_b,1Ah

intro_wipe_step:
			push	cx
			push	bx
			inc	byte ptr ds:gvar_pose_idx
			and	byte ptr ds:gvar_pose_idx,3
			call	draw_pose_3x3
			call	wait_frame
			pop	bx
			cmp	bh,24h			; '$'
			je	intro_wipe_skip_erase			; Jump if equal
			push	bx
			mov	cx,218h
			xor	al,al			; Zero register
			call	word ptr cs:gfx_fillrect_fn
			pop	bx
			add	bh,2

intro_wipe_skip_erase:
			pop	cx
			loop	intro_wipe_loop		; Loop if cx > 0

		mov	byte ptr ds:gvar_pose_idx,4
		mov	bx,246Eh
		call	draw_pose_3x3
		mov	cx,5

pose4_hold_loop:
			push	cx
			call	wait_frame
			pop	cx
			loop	pose4_hold_loop		; Loop if cx > 0

		mov	byte ptr ds:gvar_pose_idx,5

pose_cycle_loop:
			mov	bx,246Eh
			call	draw_pose_3x3
			call	wait_frame
			call	wait_frame
			inc	byte ptr ds:gvar_pose_idx
			cmp	byte ptr ds:gvar_pose_idx,9
			jb	pose_cycle_loop			; Jump if below
		mov	bx,246Eh
		call	draw_pose_3x3
		call	word ptr cs:gfx_palette_fn
		xor	bh,bh			; Zero register
		mov	bl,byte ptr ds:gvar_roka_scene
		dec	bx
		mov	al,ds:pose_y_tbl_base[bx]
		mov	ds:cur_pose_y,al
		mov	byte ptr ds:cur_pose_x,2
		call	bres_setup
		mov	ah,ds:bres_pos_y
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:bres_pos_x
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:gfx_blit_fn
		mov	byte ptr ds:draw_phase_aux,0

tile_draw_loop_a:
			mov	al,ds:draw_phase_aux
			mov	bl,ds:bres_pos_y
			xor	bh,bh			; Zero register
			mov	cl,ds:bres_pos_x
			call	word ptr cs:gfx_tile_draw
			call	wait_frame
			mov	ah,ds:bres_pos_y
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			mov	al,ds:bres_pos_x
			mov	cx,310h
			xor	di,di			; Zero register
			call	word ptr cs:gfx_blit_fn_b
			inc	byte ptr ds:draw_phase_aux
			cmp	byte ptr ds:draw_phase_aux,2
			jb	tile_draw_loop_a			; Jump if below
		mov	ah,ds:bres_pos_y
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,6
		mov	al,ds:bres_pos_x
		mov	cx,1110h
		xor	di,di			; Zero register
		call	word ptr cs:gfx_blit_fn
		mov	byte ptr ds:gvar_volume_b,1Bh
		mov	byte ptr ds:draw_phase_aux,0

tile_draw_loop_b:
			mov	al,ds:draw_phase_aux
			or	al,80h
			mov	bl,ds:bres_pos_y
			xor	bh,bh			; Zero register
			sub	bx,18h
			mov	cl,ds:bres_pos_x
			call	word ptr cs:gfx_tile_draw
			call	wait_frame
			call	wait_frame
			mov	ah,ds:bres_pos_y
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			sub	ah,6
			mov	al,ds:bres_pos_x
			mov	cx,1110h
			xor	di,di			; Zero register
			call	word ptr cs:gfx_blit_fn_b
			inc	byte ptr ds:draw_phase_aux
			cmp	byte ptr ds:draw_phase_aux,2
			jb	tile_draw_loop_b			; Jump if below
		mov	bx,2552h
		mov	cx,410h
		xor	al,al			; Zero register
		call	word ptr cs:gfx_fillrect_fn
		call	word ptr cs:gfx_palette_fn
		mov	ah,ds:bres_pos_y
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:bres_pos_x
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:gfx_blit_fn
		mov	byte ptr ds:draw_phase_aux,0

tile_draw_loop_c:
			mov	al,ds:draw_phase_aux
			mov	bl,ds:bres_pos_y
			xor	bh,bh			; Zero register
			mov	cl,ds:bres_pos_x
			call	word ptr cs:gfx_tile_draw
			call	wait_frame
			mov	ah,ds:bres_pos_y
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			mov	al,ds:bres_pos_x
			mov	cx,310h
			xor	di,di			; Zero register
			call	word ptr cs:gfx_blit_fn_b
			inc	byte ptr ds:draw_phase_aux
			cmp	byte ptr ds:draw_phase_aux,4
			jb	tile_draw_loop_c			; Jump if below
		mov	byte ptr ds:draw_phase_pal,0C8h

bres_walk_loop:
			inc	byte ptr ds:draw_phase_state
			test	byte ptr ds:draw_phase_state,1
			jnz	bres_walk_step			; Jump if not zero
			inc	byte ptr ds:draw_phase_aux
			inc	byte ptr ds:draw_phase_pal
			cmp	byte ptr ds:draw_phase_pal,3
			jb	bres_walk_step			; Jump if below
			mov	byte ptr ds:draw_phase_pal,0
			mov	byte ptr ds:gvar_volume_b,1Ch

bres_walk_step:
			mov	ah,ds:bres_pos_y
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			mov	al,ds:bres_pos_x
			mov	cx,310h
			xor	di,di			; Zero register
			call	word ptr cs:gfx_blit_fn_b
			call	bres_step
			pushf				; Push flags
			mov	ah,ds:bres_pos_y
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			mov	al,ds:bres_pos_x
			mov	cx,310h
			xor	di,di			; Zero register
			call	word ptr cs:gfx_blit_fn
			mov	al,ds:draw_phase_aux
			and	al,1
			add	al,2
			mov	bl,ds:bres_pos_y
			xor	bh,bh			; Zero register
			mov	cl,ds:bres_pos_x
			call	word ptr cs:gfx_tile_draw
			call	wait_frame
			popf				; Pop flags
			jnc	bres_walk_loop			; Jump if carry=0
		mov	ah,ds:bres_pos_y
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:bres_pos_x
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:gfx_blit_fn_b
		mov	ah,ds:bres_pos_y
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,6
		mov	al,ds:bres_pos_x
		mov	cx,1110h
		xor	di,di			; Zero register
		call	word ptr cs:gfx_blit_fn
		mov	byte ptr ds:gvar_volume_b,1Bh
		mov	byte ptr ds:draw_phase_aux,0

tile_draw_loop_d:
			mov	al,ds:draw_phase_aux
			or	al,80h
			mov	bl,ds:bres_pos_y
			xor	bh,bh			; Zero register
			sub	bx,18h
			mov	cl,ds:bres_pos_x
			call	word ptr cs:gfx_tile_draw
			call	wait_frame
			call	wait_frame
			mov	ah,ds:bres_pos_y
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			sub	ah,6
			mov	al,ds:bres_pos_x
			mov	cx,1110h
			xor	di,di			; Zero register
			call	word ptr cs:gfx_blit_fn_b
			inc	byte ptr ds:draw_phase_aux
			cmp	byte ptr ds:draw_phase_aux,2
			jb	tile_draw_loop_d			; Jump if below
		mov	al,ds:roka_pose_idx
		mov	bl,byte ptr ds:gvar_roka_scene
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	bx,ds:pose_vec_tbl_base[bx]
		call	word ptr cs:gfx_scene_fn
		mov	ah,ds:bres_pos_y
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:bres_pos_x
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:gfx_blit_fn
		mov	byte ptr ds:draw_phase_aux,4

tile_draw_loop_e:
			mov	al,ds:draw_phase_aux
			dec	al
			mov	bl,ds:bres_pos_y
			xor	bh,bh			; Zero register
			mov	cl,ds:bres_pos_x
			call	word ptr cs:gfx_tile_draw
			call	wait_frame
			mov	ah,ds:bres_pos_y
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			shr	ah,1			; Shift w/zeros fill
			mov	al,ds:bres_pos_x
			mov	cx,310h
			xor	di,di			; Zero register
			call	word ptr cs:gfx_blit_fn_b
			dec	byte ptr ds:draw_phase_aux
			jnz	tile_draw_loop_e			; Jump if not zero
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds

wait_enable_all:
			test	byte ptr ds:gvar_enable_all,0FFh
			jz	wait_enable_all			; Jump if zero
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	bx,2456h
		mov	cx,618h
		xor	al,al			; Zero register
		call	word ptr cs:gfx_fillrect_fn
		mov	byte ptr ds:gvar_pose_idx,8

outro_pose_loop:
			mov	bx,246Eh
			call	draw_pose_3x3
			call	wait_frame
			call	wait_frame
			dec	byte ptr ds:gvar_pose_idx
			cmp	byte ptr ds:gvar_pose_idx,5
			jae	outro_pose_loop			; Jump if above or =
		mov	bx,246Eh
		call	draw_pose_3x3
		mov	cx,5

outro_hold_loop:
			push	cx
			call	wait_frame
			pop	cx
			loop	outro_hold_loop		; Loop if cx > 0

		mov	bx,246Eh
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:gfx_fillrect_fn
		mov	bx,266Eh
		mov	cx,0Dh

outro_wipe_loop:
			test	cx,1
			jnz	outro_wipe_step			; Jump if not zero
			mov	byte ptr ds:gvar_volume_b,1Ah

outro_wipe_step:
			push	cx
			push	bx
			inc	byte ptr ds:gvar_pose_idx
			and	byte ptr ds:gvar_pose_idx,3
			call	draw_pose_3x3
			call	wait_frame
			pop	bx
			cmp	bh,3Eh			; '>'
			je	outro_wipe_skip_erase			; Jump if equal
			push	bx
			mov	cx,218h
			xor	al,al			; Zero register
			call	word ptr cs:gfx_fillrect_fn
			pop	bx
			add	bh,2

outro_wipe_skip_erase:
			pop	cx
			loop	outro_wipe_loop		; Loop if cx > 0

		mov	cx,618h
		xor	al,al			; Zero register
		jmp	word ptr cs:gfx_fillrect_fn

roka_demo_main	endp

draw_pose_3x3		proc	near
		mov	al,byte ptr ds:gvar_pose_idx
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,0A435h
		mov	si,ax
		mov	cx,3

pose_row_loop:
			push	cx
			mov	cx,3

pose_col_loop:
				push	cx
				lodsb				; String [si] to al
				push	si
				push	bx
				call	word ptr cs:gfx_sprite_plot
				pop	bx
				pop	si
				add	bl,8
				pop	cx
				loop	pose_col_loop		; Loop if cx > 0

			sub	bl,18h
			add	bh,2
			pop	cx
			loop	pose_row_loop		; Loop if cx > 0

		retn

draw_pose_3x3		endp

; 3x3 tile-index grid table for the 9 demo poses indexed by gvar_pose_idx
; (read as `tile_pose_tbl_base + idx*9`).  pose_tile_data is anchored 4
; bytes after tile_pose_tbl_base; the first 4 entries of pose 0 fall on
; draw_pose_3x3's epilogue bytes (59h E2h E2h C3h above) and are never
; read because the smallest pose index used at runtime is 1.

pose_tile_data	label	byte
		db	 00h, 02h, 04h			; pose 0 row 0  (4 bytes still in code)
		db	 01h, 03h, 05h			; pose 0 row 1
		db	 00h, 00h, 06h			; pose 1 row 0
		db	 07h, 09h, 0Bh			; pose 1 row 1
		db	 08h, 0Ah, 0Ch			; pose 1 row 2
		db	 00h, 00h, 00h			; pose 2 row 0  (blank head row)
		db	 00h, 02h, 0Eh			; pose 2 row 1
		db	 01h, 0Dh, 0Fh			; pose 2 row 2
		db	 00h, 00h, 10h			; pose 3 row 0
		db	 07h, 09h, 11h			; pose 3 row 1
		db	 08h, 0Ah, 12h			; pose 3 row 2
		db	 00h, 00h, 00h			; pose 4 row 0  (blank head row)
		db	 00h, 14h, 16h			; pose 4 row 1
		db	 13h, 15h, 17h			; pose 4 row 2
		db	 00h, 00h, 18h			; pose 5 row 0
		db	 19h, 00h, 1Ch			; pose 5 row 1
		db	 1Ah, 1Bh, 1Dh			; pose 5 row 2
		db	 00h, 00h, 1Eh			; pose 6 row 0
		db	 1Fh, 00h, 23h			; pose 6 row 1
		db	 20h, 21h, 24h			; pose 6 row 2
		db	 00h, 22h, 25h			; pose 7 row 0
		db	 1Fh, 00h, 23h			; pose 7 row 1
		db	 20h, 26h, 28h			; pose 7 row 2
		db	 00h, 27h, 29h			; pose 8 row 0
		db	 1Fh, 00h, 23h			; pose 8 row 1
		db	 2Ah, 2Ch, 28h			; pose 8 row 2  (last 3 bytes also start unused tail)
		db	 2Bh, 2Dh, 29h, 2Eh		; -+
		db	 31h, 23h, 2Fh, 32h		;  | unused tail bytes (10 total).  Spell out as
		db	 34h, 30h			;  | ASCII '+-).1#/24035' if read as text.  Not
		db	 33h, 35h			; -+ accessed by any code path in this module.

wait_frame		proc	near
		mov	cl,ds:gvar_anim_speed
		mov	al,4
		mul	cl			; ax = reg * al

frame_wait:
			cmp	ds:gvar_timer_lo,al
			jb	frame_wait			; Jump if below
		mov	byte ptr ds:gvar_timer_lo,0
		retn

wait_frame		endp

bres_setup		proc	near
		mov	byte ptr ds:bres_pos_y,94h
		mov	byte ptr ds:bres_pos_x,50h	; 'P'
		xor	cl,cl			; Zero register
		mov	al,ds:cur_pose_y
		sub	al,ds:bres_pos_y
		jz	bres_setup_dy_done			; Jump if zero
		jnc	bres_setup_dy_pos			; Jump if carry=0
		neg	al
		dec	cl
		jmp	short bres_setup_dy_done

bres_setup_dy_pos:
		inc	cl

bres_setup_dy_done:
		mov	ds:bres_pos_x_2,al
		mov	ds:bres_sign_y,cl
		xor	cl,cl			; Zero register
		mov	al,ds:cur_pose_x
		sub	al,ds:bres_pos_x
		jz	bres_setup_dx_done			; Jump if zero
		jnc	bres_setup_dx_pos			; Jump if carry=0
		neg	al
		dec	cl
		jmp	short bres_setup_dx_done

bres_setup_dx_pos:
		inc	cl

bres_setup_dx_done:
		mov	ds:bres_dy,al
		mov	ds:bres_sign_x,cl
		mov	al,ds:bres_pos_x_2
		shr	al,1			; Shift w/zeros fill
		mov	ds:bres_error,al
		mov	byte ptr ds:bres_dx,0
		mov	al,ds:bres_pos_x_2
		cmp	al,ds:bres_dy
		jb	bres_setup_y_major			; Jump if below
		retn

bres_setup_y_major:
		mov	al,ds:bres_dy
		shr	al,1			; Shift w/zeros fill
		mov	ds:bres_error,al
		mov	byte ptr ds:bres_dx,0FFh
		retn

bres_setup		endp

bres_step		proc	near
		test	byte ptr ds:bres_dx,0FFh
		jnz	bres_step_y_axis			; Jump if not zero
		mov	al,ds:bres_error
		sub	al,ds:bres_dy
		jnc	bres_step_x_no_carry			; Jump if carry=0
		add	al,ds:bres_pos_x_2
		mov	ah,ds:bres_sign_x
		add	ds:bres_pos_x,ah

bres_step_x_no_carry:
		mov	ds:bres_error,al
		mov	al,ds:bres_sign_y
		add	ds:bres_pos_y,al
		mov	al,ds:cur_pose_y
		cmp	al,ds:bres_pos_y
		stc				; Set carry flag
		jnz	bres_step_x_done			; Jump if not zero
		retn

bres_step_x_done:
		clc				; Clear carry flag
		retn

bres_step_y_axis:
		mov	al,ds:bres_error
		sub	al,ds:bres_pos_x_2
		jnc	bres_step_y_no_carry			; Jump if carry=0
		add	al,ds:bres_dy
		mov	ah,ds:bres_sign_y
		add	ds:bres_pos_y,ah

bres_step_y_no_carry:
		mov	ds:bres_error,al
		mov	al,ds:bres_sign_x
		add	ds:bres_pos_x,al
		mov	al,ds:cur_pose_x
		cmp	al,ds:bres_pos_x
		stc				; Set carry flag
		jnz	bres_step_y_done			; Jump if not zero
		retn

bres_step_y_done:
		clc				; Clear carry flag
		retn

bres_step		endp

; ----------------------------------------------------------------------
; Demo data tables (file offsets 0x56D..0x587 in DS, after bres_step).
;
; Two overlapping lookup tables sit here.  Both are read via the EQU
; bases at the top of this file:
;
;   pose_y_tbl_base   equ 0A569h  ; reads 9 bytes  [base + bx]    (bx=0..8)
;   pose_vec_tbl_base equ 0A572h  ; reads 9 words  [base + bx*2]  (bx=0..8)
;
; Because pose_y_tbl_base is set 4 bytes earlier than the actual data
; below, the FIRST four Y entries (poses 1-4) deliberately overlap the
; bytes of bres_step's tail (`75 01 C3 F8 C3`).  The data block proper
; starts at file offset 0x56D below.  The two tables abut at 0xA572 -
; the high byte of the pose-1 vec word is the same byte as the pose-5 Y
; value, by design.
;
; Pose-Y table seen by the code (poses 1..9):
;   pose 1..4: Y = 01h, C3h, F8h, C3h  (= last 4 bytes of bres_step code)
;   pose 5: Y=3Ch    pose 6: Y=F4h    pose 7: Y=54h
;   pose 8: Y=DCh    pose 9: Y=6Ch    (bytes 0..4 of pose_palette_dat)
; Only poses 5..9 get past the conditional gate before bres_setup, so
; the four overlapping Y values for poses 1..4 are never consumed.
;
; Pose-vec word table (LE, what gfx_scene_fn receives in BX):
;   pose 1: 0x84C4   pose 2: 0x98AC   pose 3: 0x0F00
;   pose 4: 0x3D00   pose 5: 0x1500   pose 6: 0x3700
;   pose 7: 0x1B00   pose 8: 0x3100   pose 9: 0x2100
; ----------------------------------------------------------------------

pose_palette_dat label	byte		; alias for pose_y_tbl_base + 4 (= 0A56Dh)
		db	 3Ch, 0F4h, 54h, 0DCh, 6Ch	; pose-Y for scenes 5..9
		db	 0C4h, 84h, 0ACh, 98h		; bytes 0..3 of pose_vec word table (poses 1-2 hi/lo)

pose_target_tbl label	word		; = pose_vec_tbl_base + 4 (DS = 0xA576)
		dw	0F00h				; pose 3 vec
		dw	3D00h				; pose 4 vec
		dw	1500h				; pose 5 vec
		dw	3700h				; pose 6 vec
		dw	1B00h				; pose 7 vec
		dw	3100h				; pose 8 vec
		dw	2100h				; pose 9 vec
		dw	2B00h				; padding word (pose 10, never read)
		dw	2600h				; padding word (pose 11, never read)

; ----------------------------------------------------------------------
; SAR chunk reference records used by the chunk loader at cs:[10Ch] and
; by INT 60h music dispatch.  Format (also seen in 200FIGHT's
; resource_name_table): [archive_byte][chunk_id_byte][name][NUL] where
; chunk_id_byte equals the first character of the filename (so the byte
; doubles as both the loader chunk index and the leading text byte).
; ----------------------------------------------------------------------

ref_mfan_msd	label	byte			; DS = 0xA588
		db	02h				; archive = 2 (zelres3)
		db	'_MFAN.MSD'			; chunk_id 5Fh = chunk 95, fanfare music
		db	00h				; NUL terminator

ref_6dman_grp	label	byte			; DS = 0xA593
		db	02h				; archive = 2 (zelres3)
		db	'6DMAN.GRP'			; chunk_id 36h = chunk 54, Roka sprites
		db	00h				; NUL terminator
		; tail padding (used as zero-init "BSS" for runtime state vars
		; bres_dx, bres_dy, bres_error, roka_pose_idx, draw_phase_*).
		db	14 dup (00h)

seg_a		ends

		end	start
