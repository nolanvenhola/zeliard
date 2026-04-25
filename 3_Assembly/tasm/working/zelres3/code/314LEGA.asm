
PAGE  59,132

;==========================================================================
;
;  314LEGA - Level / Map Renderer Code Module - Tarso (zelres3 chunk)
;
;  Level renderer and per-frame map update program for the Tarso area
;  (town name 'Tarso' embedded near the module trailer). Sibling of
;  312ZELA (Satono) and 313MEDA (Bosque/Vista); shares the
;  game-segment dispatch ABI and per-map state byte layout.
;
;  Structure:
;    - Header pointer / descriptor area (file 0x00..0x80) mis-decoded by
;      Sourcer as sbb/and x86 instructions; preserved as raw bytes
;    - Large tile/cell layout data block (lega_tile_data_block_*)
;    - Per-frame NPC scan loop (lega_npc_scan_loop..lega_npc_scan_done)
;    - Phase / state machine + scroll helpers
;    - Trailer: 10-word handler jump-table + continuation tile data
;      + 'Tarso' town-name string fragment
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; The following equates show data references outside the range of the program.
; Shared references across 312-319 map-program family:
;   200Ch..6038h  - game-segment dispatch callback fn ptrs
;   0C010h        - sprite attribute record base
;   0ED20h        - char/tile lookup table
;   0FF2Eh..0FF75h - per-map global state flag bytes

; --- Game-segment dispatch callbacks (CS-relative ptrs in game DS) ---
lega_cb_scroll		equ	200Ch		; scroll / dispatch callback
lega_cb_tile_query	equ	6028h		; tile-at-cell callback fn A
lega_cb_npc_step	equ	6036h		; NPC step / cell-iter callback fn B
lega_cb_entity_act	equ	6038h		; entity action callback fn C

; --- Internal tile/render data tables (CS/DS-relative) ---
lega_tbl_a3c7		equ	0A3C7h		; (unresolved data ref)
lega_tbl_a41b		equ	0A41Bh		; xlat table base (mov bx, 0A41Bh + xlat)
lega_npc_state_a	equ	0A41Fh		; cell-state scan table A (5 bytes, scasb)
lega_npc_state_b	equ	0A424h		; cell-state scan table B (5 bytes, scasb)
lega_anim_dx_tbl	equ	0A5D8h		; per-phase delta-X table base
lega_anim_dy_tbl	equ	0A5D9h		; per-phase delta-Y table base
lega_phase_xlat_a	equ	0A69Bh		; phase-A xlat table (xlat-indexed)
lega_phase_xlat_b	equ	0A6BCh		; phase-B xlat table (xlat-indexed)
lega_unk_a6c8		equ	0A6C8h		; (unresolved table ref)
lega_dispatch_tbl	equ	0A744h		; trailer dispatch jump-table base

; --- Scroll / phase state bytes (DS) ---
lega_scroll_x		equ	0A7A0h		; scroll X position (word)
lega_scroll_phase	equ	0A7A2h		; scroll phase counter byte
lega_scroll_x_max	equ	0A7A3h		; scroll X max (word)

; --- NPC scan / cell write state bytes (DS) ---
lega_npc_idx		equ	0A7B6h		; NPC scan index byte
lega_anim_byte		equ	0A7B7h		; current animation/speaker byte
lega_idle_step		equ	0A7B8h		; idle step counter (0..0x28)
lega_phase_step		equ	0A7B9h		; phase step counter (mod 8)
lega_phase_dir_b	equ	0A7BAh		; per-frame xlat output (written after xlat)
lega_phase_substep	equ	0A7BBh		; phase sub-step (mod 4)
lega_attr_tmp		equ	0A7BCh		; tile attribute scratch byte
lega_phase_locked	equ	0A7BDh		; phase-locked flag
lega_phase_subflag	equ	0A7BEh		; phase sub-flag
lega_phase_delay	equ	0A7BFh		; phase delay countdown
lega_phase_active	equ	0A7C0h		; phase-active flag
lega_phase_active_b	equ	0A7C1h		; phase-active sub-flag
lega_anim2_active	equ	0A7C2h		; secondary animation active flag
lega_anim2_x		equ	0A7C3h		; secondary anim X position (word)
lega_anim2_y		equ	0A7C5h		; secondary anim Y position
lega_anim2_frame	equ	0A7C6h		; secondary anim frame index
lega_anim2_phase	equ	0A7C7h		; secondary anim phase counter
lega_anim2_subflag	equ	0A7C8h		; secondary anim sub-flag
lega_render_buf		equ	0A7C9h		; tile render buffer base
lega_render_buf_b	equ	0A7CBh		; tile render buffer +2
lega_extra_attr		equ	0A7F1h		; extra-attr byte at scan tail

; --- Shared game-segment globals (used across map-program family) ---
enemy_attr_base		equ	0C010h		; sprite/entity record base (DS)
sprite_xlat_tbl		equ	0ED20h		; char/tile lookup table (shared)
gvar_death_flag		equ	0FF2Eh		; global death flag
gvar_dir_toggle		equ	0FF2Fh		; global dir-toggle flag
gvar_unk_ff3c		equ	0FF3Ch		; global state byte (used in header decode)
gvar_spawn_fx_flag	equ	0FF75h		; spawn VFX flag

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

lega_main		proc	far

; ------------------------------------------------------------------
; start: header + embedded tile/cell layout data.
; The leading "sbb/add/and" x86 decode is Sourcer mis-parsing the
; module header fields; real code entry is via dispatch from game
; DS. The 12 zero bytes below are the reserved / padding header area.
; ------------------------------------------------------------------

start:
		sbb	[bx+si],cx		; header field bytes
		add	[bx+si],al		; header field bytes
		and	sp,ss:lega_scroll_x[bp+si]	; header field bytes
		db	12 dup (0)		; reserved / padding
		db	0A0h,0A0h,0A0h,0A0h,0A0h,0A0h
		db	 50h
		db	 0Ah, 0Ah
lega_tile_data_block_a		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah	; Data table (indexed access)
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, '>'
		db	0A0h, 8Eh,0A0h,0DEh,0A0h, 2Eh
		db	0A1h, 7Eh,0A1h,0CEh,0A1h, 05h
		db	0A2h, 02h, 00h, 00h, 00h, 03h
		db	 02h, 00h, 00h, 04h, 00h, 02h
		db	 00h, 00h, 00h, 05h, 02h, 00h
		db	 00h, 06h, 00h, 02h, 00h, 00h
		db	 00h, 07h, 02h, 00h, 00h, 08h
		db	 00h, 02h, 00h,0ADh, 00h,0AFh
		db	 02h,0AEh, 00h,0B0h, 00h, 02h
		db	0B1h,0B2h,0B5h,0B6h, 02h,0B3h
		db	0B4h,0B7h,0B8h, 02h,0B9h,0BAh
		db	 39h, 01h, 02h, 75h,0AAh, 02h
		db	 38h, 02h, 00h, 00h, 00h, 01h
		db	 02h, 00h, 00h, 02h, 00h, 02h
		db	 00h, 00h, 00h,0BBh, 02h, 00h
		db	 00h,0BCh, 00h, 00h, 09h, 0Ah
		db	 0Bh, 0Ch, 00h, 0Dh, 0Eh, 10h
		db	 11h, 00h, 0Eh, 0Fh, 11h, 12h
lega_tile_data_block_b		db	0			; Data table (indexed access)
		db	 13h, 14h
lega_tile_data_block_c		dw	1615h			; Data table (indexed access)
		db	 00h, 17h, 18h, 19h, 1Ah, 00h
		db	 19h, 1Ah, 1Ch, 1Dh, 00h, 1Ah
		db	 1Bh, 1Dh, 1Eh, 00h, 1Fh, 13h
		db	 20h, 21h, 00h, 13h, 14h, 21h
		db	 16h, 00h, 20h, 21h, 22h, 23h
		db	 00h, 21h, 16h, 23h, 18h, 00h
		db	 24h, 1Ah, 25h, 1Dh, 00h, 1Ah
		db	 1Bh, 1Dh, 1Eh, 00h, 0Dh, 0Eh
		db	 26h, 27h, 00h, 0Fh, 00h, 28h
		; Tile index tables (Sourcer emitted mis-split strings; raw bytes from reference)
		db	29h, 00h, 2Ah, 2Bh, 2Eh, 2Fh, 00h, 2Ch, 2Dh, 30h, 31h, 00h
		db	32h, 33h, 36h, 37h, 00h, 34h, 35h, 19h, 1Ah, 00h, 36h, 37h
		db	3Ah, 3Bh, 00h, 19h, 1Ah, 1Ch, 1Dh, 00h, 1Ah, 00h, 1Dh, 1Eh
		db	00h, 0Dh, 0Eh, 3Dh, 27h, 00h, 3Ch, 3Dh, 3Eh, 3Fh, 00h, 3Fh
		db	40h, 43h, 44h, 00h, 41h, 42h, 45h, 46h, 00h, 47h, 48h, 49h
		db	00h, 00h, 4Ah, 0Eh, 4Dh, 27h, 00h, 34h, 35h, 58h, 59h, 00h
		db	4Bh, 4Ch, 4Eh, 4Fh, 00h, 50h, 51h, 00h, 44h, 00h, 58h, 59h
		db	5Ah, 5Bh, 00h, 53h, 54h, 56h, 57h, 00h, 4Eh, 4Fh, 54h, 55h
		db	00h, 00h, 00h, 52h, 53h, 00h, 0Dh, 0Eh, 5Dh, 27h, 00h, 0Eh
		db	0Fh, 27h, 28h, 00h, 61h, 2Ch, 6Ah, 6Bh, 00h, 2Ch, 69h, 6Bh
		db	6Ch, 00h, 6Bh, 6Ch
		db	 6Dh, 6Eh, 00h, 6Eh, 6Fh, 70h
		db	 71h, 00h, 70h, 71h, 5Ah, 72h
		db	 00h, 00h, 5Ch, 5Eh, 5Fh, 00h
		db	 5Ch, 5Dh, 5Fh, 60h, 00h, 62h
		db	 63h, 65h, 66h, 00h, 64h, 65h
		db	 67h, 68h, 00h, 0Dh, 0Eh, 73h
		db	 74h, 00h, 0Eh, 0Fh, 74h, 12h
		db	 00h, 76h, 77h, 7Ah, 7Bh, 00h
		db	 78h, 79h, 7Ch, 7Dh, 00h, 17h
		db	 7Ah, 19h, 1Ah, 00h, 19h, 1Ah
		db	 1Ch, 1Dh, 00h, 1Ah, 1Bh, 1Dh
		db	 1Eh, 00h, 7Eh, 7Fh, 82h, 83h
		db	 00h, 80h, 81h, 84h, 85h, 00h
		db	 19h, 1Ah,0A2h,0A3h, 00h, 1Ah
		db	 1Bh,0A3h,0A4h, 00h, 7Eh, 7Fh
		db	0A5h, 83h, 00h, 00h, 00h,0A0h
		db	0A1h, 00h, 7Eh, 7Fh,0ACh, 83h
		db	 00h, 1Ah, 1Bh, 1Dh,0ABh, 00h
		db	 19h, 1Ah,0A9h, 1Dh, 00h, 00h
		db	0A6h,0A7h,0A8h, 00h, 86h, 87h
		db	 88h, 89h, 00h, 8Bh, 8Ch, 8Eh
		db	 8Fh, 00h, 89h, 8Ah, 8Ch, 8Dh
		db	 00h, 92h, 93h, 96h, 97h, 00h
		db	 8Fh, 90h, 93h, 94h, 00h, 98h
		db	 99h, 1Ah, 9Bh, 00h, 99h, 9Ah
		db	 9Bh, 9Ch, 00h, 1Ah, 9Bh, 9Dh
		db	 9Eh, 00h, 9Bh, 9Ch, 9Eh, 9Fh
		db	 00h, 91h, 92h, 95h, 96h, 00h
		db	 17h, 98h, 19h, 1Ah, 00h, 19h
		db	 1Ah, 1Ch, 9Dh, 02h,0BDh,0BEh
		db	0BFh,0C0h, 02h,0C1h,0C2h,0C3h
		db	0C4h, 02h,0C5h,0C6h,0C7h,0C8h
		db	 02h,0C9h,0CAh,0CBh,0CCh, 02h
		db	0CDh,0CEh,0CFh,0D0h, 02h, 00h
		db	 00h,0D1h,0D2h, 8Bh, 36h, 10h
		db	0C0h,0C6h, 06h,0B6h,0A7h, 00h
		db	0C6h

lega_npc_scan_loop:
		push	es
		mov	bh,0A7h
		add	ss:gvar_unk_ff3c[bp+di],al
		jz	lega_npc_scan_done			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:lega_cb_npc_step
		jc	lega_npc_scan_next			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:lega_cb_tile_query
		mov	bl,ds:lega_npc_idx
		xor	bh,bh			; Zero register
		mov	al,ds:sprite_xlat_tbl[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	lega_npc_scan_next			; Jump if zero
		mov	al,[si+5]
		and	al,1Fh
		mov	ds:lega_anim_byte,al

lega_npc_scan_next:
		inc	byte ptr ds:lega_npc_idx
		add	si,10h
;*		jmp	short loc_2		;*
		db	0EBh, 0C4h		; jmp short 235h (absolute)

lega_npc_scan_done:
		mov	si,ds:enemy_attr_base
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:lega_anim_byte,0FFh
		jz	lega_post_scan_check_death			; Jump if zero
		mov	al,ds:lega_anim_byte
		push	ax
		call	word ptr cs:lega_cb_entity_act
		mov	bl,ah
		xor	bh,bh			; Zero register
		pop	ax
		cmp	al,9
		je	lega_anim_apply_scroll			; Jump if equal
		cmp	al,1
		jne	lega_anim_dispatch_other			; Jump if not equal
		add	bx,bx
		jmp	short lega_anim_apply_scroll

lega_anim_dispatch_other:
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill

lega_anim_apply_scroll:
		call	lega_scroll_finalize
		mov	byte ptr ds:gvar_spawn_fx_flag,2Fh	; '/'
		cmp	byte ptr ds:lega_scroll_x,2Fh	; '/'
		jae	lega_post_scan_check_death			; Jump if above or =
		mov	byte ptr ds:lega_phase_delay,14h
		mov	byte ptr ds:lega_phase_locked,0FFh

lega_post_scan_check_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	lega_phase_check_active			; Jump if zero
		jmp	lega_idle_or_spawn

lega_phase_check_active:
		test	byte ptr ds:lega_phase_active,0FFh
		jz	lega_phase_check_anim2			; Jump if zero
		jmp	lega_phase_active_handler

lega_phase_check_anim2:
		test	byte ptr ds:lega_anim2_active,0FFh
		jz	lega_phase_check_locked			; Jump if zero
		cmp	byte ptr ds:lega_anim2_phase,0Dh
		jae	lega_phase_check_locked			; Jump if above or =
		jmp	lega_phase_check_step6

lega_phase_check_locked:
		test	byte ptr ds:lega_phase_locked,0FFh
		jnz	lega_phase_locked_branch			; Jump if not zero
		mov	byte ptr ds:lega_phase_delay,3Ch	; '<'
		inc	byte ptr ds:lega_phase_step
		and	byte ptr ds:lega_phase_step,7
		mov	al,ds:lega_phase_step
		push	cs
		pop	es
		mov	di,lega_npc_state_a
		mov	cx,5
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jnz	lega_phase_a_done			; Jump if not zero
		push	ax
		call	lega_scroll_dec_step
		sbb	al,al
		mov	ds:lega_phase_locked,al
		pop	ax
		cmp	al,7
		jne	lega_phase_a_done			; Jump if not equal
		call	lega_scroll_dec_step
		sbb	al,al
		mov	ds:lega_phase_locked,al

lega_phase_a_done:
		jmp	short lega_phase_check_step6

lega_phase_locked_branch:
		dec	byte ptr ds:lega_phase_delay
		jnz	lega_phase_b_step			; Jump if not zero
		mov	byte ptr ds:lega_phase_locked,0
		jmp	short lega_phase_check_step6

lega_phase_b_step:
			mov	al,ds:lega_phase_step
			or	al,al			; Zero ?
			jnz	lega_phase_b_skip0			; Jump if not zero
			mov	al,8

lega_phase_b_skip0:
			cmp	al,6
			jne	lega_phase_b_skip6			; Jump if not equal
			sub	al,2

lega_phase_b_skip6:
			dec	al
			mov	ds:lega_phase_step,al
			push	cs
			pop	es
			mov	di,lega_npc_state_b
			mov	cx,5
			repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
			jnz	lega_phase_check_step6			; Jump if not zero
			push	ax
			call	lega_scroll_inc_step
			cmc				; Complement carry
			sbb	al,al
			mov	ds:lega_phase_locked,al
			pop	ax
			cmp	al,6
			je	lega_phase_b_apply			; Jump if equal
			cmp	al,3
			jne	lega_phase_b_step			; Jump if not equal

lega_phase_b_apply:
		call	lega_scroll_inc_step
		cmc				; Complement carry
		sbb	al,al
		mov	ds:lega_phase_locked,al

lega_phase_check_step6:
		test	byte ptr ds:lega_phase_locked,0FFh
		jnz	lega_phase_dir_apply			; Jump if not zero
		cmp	byte ptr ds:lega_phase_step,6
		jne	lega_phase_dir_apply			; Jump if not equal
		call	word ptr cs:[11Ah]	; was: call word ptr cs:data_6 (fn ptr at offset 11Ah)
		and	al,1
		jnz	lega_phase_dir_apply			; Jump if not zero
		test	byte ptr ds:lega_anim2_active,0FFh
		jnz	lega_phase_dir_apply			; Jump if not zero
		mov	ax,cs:lega_scroll_x
		sub	ax,14h
		jc	lega_phase_dir_apply			; Jump if carry Set
		mov	byte ptr ds:lega_phase_active,0FFh
		mov	byte ptr ds:lega_phase_active_b,0
		mov	byte ptr ds:lega_phase_subflag,0
		mov	byte ptr ds:lega_phase_step,8
		mov	byte ptr ds:gvar_spawn_fx_flag,30h	; '0'

lega_phase_dir_apply:
		inc	byte ptr ds:lega_phase_substep
		and	byte ptr ds:lega_phase_substep,3
		mov	al,ds:lega_phase_substep
		mov	bx,lega_tbl_a41b
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[0A7BAh],al
		jmp	$+9Ah

lega_phase_active_handler:
		db	0FEh, 06h,0C1h,0A7h, 8Ah, 1Eh
		db	0C1h,0A7h,0FEh,0CBh, 32h,0FFh
		db	 03h,0DBh,0FFh,0A7h,0C7h,0A3h
		db	0CDh,0A3h,0FEh,0A3h, 0Ah,0A4h
		db	0C6h, 06h,0BAh,0A7h, 06h,0C6h
		db	 06h,0B9h,0A7h, 08h,0C6h, 06h
		db	0C2h,0A7h,0FFh,0A1h,0A0h,0A7h
		db	 05h, 04h, 00h,0A3h,0C3h,0A7h
		db	0A0h,0A2h,0A7h, 24h, 3Fh,0A2h
		db	0C5h,0A7h,0C6h, 06h,0C6h,0A7h
		db	 00h,0C6h, 06h,0C7h,0A7h, 00h
		db	0C6h, 06h,0C8h,0A7h, 00h,0EBh
		db	 4Eh,0C6h, 06h,0BAh,0A7h, 07h
		db	0C6h, 06h,0B9h,0A7h, 06h,0EBh
		db	 42h,0C6h, 06h,0BAh,0A7h, 00h
		db	0C6h, 06h,0C0h,0A7h, 00h,0C6h
		db	 06h,0B9h,0A7h, 06h,0EBh, 31h
		db	 00h, 01h, 02h, 01h, 02h, 05h
		db	 06h, 07h, 00h, 01h, 03h, 06h
		db	 07h, 07h

lega_main		endp

lega_scroll_dec_step		proc	near
		mov	ax,ds:lega_scroll_x
		dec	ax
		mov	bx,0Eh
		sub	bx,ax
		mov	ds:lega_scroll_x,ax
		cmc				; Complement carry
		jnc	$+3			; Jump if carry=0
		retn

lega_scroll_dec_step		endp

		db	0F8h,0C3h

lega_scroll_inc_step		proc	near
		mov	ax,ds:lega_scroll_x
		inc	ax
		mov	bx,32h
		sub	bx,ax
		jnc	$+3			; Jump if carry=0
		retn

lega_scroll_inc_step		endp

		db	0A3h,0A0h,0A7h,0F8h,0C3h
		db	 0Eh, 07h
		db	0BFh,0C9h,0A7h,0B9h, 28h, 00h
		db	0B8h,0FFh,0FFh,0F3h,0ABh, 8Ah
		db	 1Eh,0B9h,0A7h, 32h,0FFh, 03h
		db	0DBh, 8Bh,0B7h,0C8h,0A6h, 8Bh
		db	0AFh, 44h,0A7h
		db	0BFh,0CBh,0A7h,0B9h, 08h, 00h

lega_render_outer_loop:
			push	cx
			mov	cx,8

lega_render_inner_loop:
				rol	byte ptr ds:[bp],1	; Rotate
				jnc	lega_render_inner_advance			; Jump if carry=0
				movsb				; Mov [si] to es:[di]
				dec	di

lega_render_inner_advance:
				inc	di
				loop	lega_render_inner_loop		; Loop if cx > 0

			inc	di
			inc	di
			inc	bp
			pop	cx
			loop	lega_render_outer_loop		; Loop if cx > 0

		mov	al,byte ptr ds:[0A7BAh]
		add	al,al
		mov	di,lega_extra_attr
		cmp	byte ptr ds:lega_phase_step,6
		je	lega_extra_attr_step			; Jump if equal
		cmp	byte ptr ds:lega_phase_step,8
		jb	lega_extra_attr_done			; Jump if below

lega_extra_attr_step:
		inc	di

lega_extra_attr_done:
		stosb				; Store al to es:[di]
		add	di,13h
		inc	al
		stosb				; Store al to es:[di]
		mov	byte ptr ds:lega_npc_idx,0
		mov	ax,ds:lega_scroll_x
		mov	si,ds:enemy_attr_base
		mov	di,0A7C9h
		mov	cx,8

lega_render_scan_loop:
		push	cx
		push	di
		push	ax
		call	word ptr cs:lega_cb_npc_step
		pop	ax
		mov	ds:lega_attr_tmp,bl
		jc	lega_render_scan_outer_advance			; Jump if carry Set
		xor	cl,cl			; Zero register

lega_render_scan_inner:
			push	cx
			push	ax
			cmp	byte ptr [di],0FFh
			je	lega_render_scan_advance			; Jump if equal
			mov	[si],ax
			mov	al,ds:lega_scroll_phase
			add	al,cl
			and	al,3Fh			; '?'
			mov	[si+2],al
			mov	al,ds:lega_attr_tmp
			mov	[si+3],al
			mov	al,[di]
			mov	[si+6],al
			mov	ah,al
			add	al,al
			sbb	al,al
			and	al,60h			; '`'
			mov	bl,ah
			shr	bl,1			; Shift w/zeros fill
			shr	bl,1			; Shift w/zeros fill
			shr	bl,1			; Shift w/zeros fill
			shr	bl,1			; Shift w/zeros fill
			and	bl,7
			or	al,bl
			mov	[si+4],al
			mov	byte ptr [si+5],0
			test	byte ptr ds:lega_anim_byte,0FFh
			jz	lega_render_scan_xlat			; Jump if zero
			or	byte ptr [si+5],20h	; ' '

lega_render_scan_xlat:
			push	di
			mov	ax,[si+2]
			call	word ptr cs:lega_cb_tile_query
			mov	bl,ds:lega_npc_idx
			xor	bh,bh			; Zero register
			mov	al,bl
			or	al,80h
			xchg	[di],al
			mov	ds:sprite_xlat_tbl[bx],al
			pop	di
			add	si,10h
			inc	byte ptr ds:lega_npc_idx

lega_render_scan_advance:
			inc	di
			pop	ax
			pop	cx
			inc	cl
			cmp	cl,0Ah
			jne	lega_render_scan_inner			; Jump if not equal

lega_render_scan_outer_advance:
		inc	ax
		pop	di
		add	di,0Ah
		pop	cx
		loop	lega_render_scan_loop_target		; Loop if cx > 0

		jmp	short lega_render_scan_done

lega_render_scan_loop_target:
		jmp	lega_render_scan_loop

lega_render_scan_done:
		call	lega_render_anim2_cell
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:lega_anim2_active,0FFh
		jnz	lega_anim2_check_subflag			; Jump if not zero
		retn

lega_anim2_check_subflag:
		test	byte ptr ds:lega_anim2_subflag,0FFh
		jnz	lega_anim2_subflag_branch			; Jump if not zero
		cmp	byte ptr ds:lega_anim2_x,12h
		jae	lega_anim2_step			; Jump if above or =
		mov	byte ptr ds:lega_anim2_subflag,0FFh
		mov	byte ptr ds:lega_anim2_frame,3
		mov	byte ptr ds:gvar_spawn_fx_flag,32h	; '2'
		retn

lega_anim2_step:
		mov	bl,ds:lega_anim2_phase
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	al,ds:lega_anim_dx_tbl[bx]
		add	ds:lega_anim2_x,al
		mov	al,ds:lega_anim_dy_tbl[bx]
		add	ds:lega_anim2_y,al
		cmp	byte ptr ds:lega_anim2_phase,10h
		adc	byte ptr ds:lega_anim2_phase,0
		mov	al,ds:lega_anim2_frame
		inc	al
		cmp	al,3
		jb	lega_anim2_frame_clamp			; Jump if below
		xor	al,al			; Zero register

lega_anim2_frame_clamp:
		mov	ds:lega_anim2_frame,al
		cmp	byte ptr ds:lega_anim2_phase,9
		jne	lega_anim2_check_phase_c			; Jump if not equal
		mov	byte ptr ds:gvar_spawn_fx_flag,31h	; '1'

lega_anim2_check_phase_c:
		cmp	byte ptr ds:lega_anim2_phase,0Ch
		jne	lega_anim2_check_phase_f			; Jump if not equal
		mov	byte ptr ds:gvar_spawn_fx_flag,31h	; '1'

lega_anim2_check_phase_f:
		cmp	byte ptr ds:lega_anim2_phase,0Fh
		jne	lega_anim2_finalize_ret		; Jump if not equal
		mov	byte ptr ds:gvar_spawn_fx_flag,31h	; '1'

lega_anim2_finalize_ret:
		retn

lega_anim2_subflag_branch:
		inc	byte ptr ds:lega_anim2_frame
		cmp	byte ptr ds:lega_anim2_frame,6
		jae	lega_anim2_clear_active			; Jump if above or =
		retn

lega_anim2_clear_active:
		mov	byte ptr ds:lega_anim2_active,0
		retn
		db	0FFh, 00h,0FFh, 00h,0FFh, 01h
		db	 00h, 02h,0FFh, 02h, 00h, 02h
		db	0FFh, 02h,0FFh,0FEh,0FFh, 00h
		db	0FFh, 02h,0FFh,0FFh,0FFh, 00h
		db	0FFh, 01h,0FFh, 00h,0FFh, 00h
		db	0FFh, 00h,0FFh, 00h

lega_render_anim2_cell		proc	near
		test	byte ptr ds:lega_anim2_active,0FFh
		jnz	lega_anim2_cell_query			; Jump if not zero
		retn

lega_anim2_cell_query:
		mov	ax,ds:lega_anim2_x
		push	ax
		call	word ptr cs:lega_cb_npc_step
		pop	ax
		jnc	lega_anim2_cell_write			; Jump if carry=0
		retn

lega_anim2_cell_write:
		mov	[si],ax
		mov	al,ds:lega_anim2_y
		mov	[si+2],al
		mov	[si+3],bl
		mov	byte ptr [si+4],26h	; '&'
		mov	byte ptr [si+5],0
		mov	al,ds:lega_anim2_frame
		mov	[si+6],al
		mov	ax,[si+2]
		call	word ptr cs:lega_cb_tile_query
		mov	bl,ds:lega_npc_idx
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:sprite_xlat_tbl[bx],al
		add	si,10h
		retn

lega_render_anim2_cell		endp

lega_scroll_finalize		proc	near
		mov	ax,ds:lega_scroll_x_max
		sub	ax,bx
		jnc	lega_scroll_clamp_zero			; Jump if carry=0
		xor	ax,ax			; Zero register

lega_scroll_clamp_zero:
		mov	ds:lega_scroll_x_max,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:lega_cb_scroll
		pop	ax
		or	ax,ax			; Zero ?
		jz	lega_scroll_set_death			; Jump if zero
		retn

lega_scroll_set_death:
		mov	byte ptr ds:lega_idle_step,0
		mov	byte ptr ds:lega_anim2_active,0
		mov	byte ptr ds:gvar_death_flag,0FFh
		retn

lega_scroll_finalize		endp

lega_idle_or_spawn:
		cmp	byte ptr ds:lega_idle_step,28h	; '('
;*		jae	loc_50			;*Jump if above or =
		db	073h, 04Dh		; jnc 6C6h (absolute)
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		inc	byte ptr ds:lega_idle_step
		cmp	byte ptr ds:lega_idle_step,0Ah
		jae	lega_idle_late_phase			; Jump if above or =
		mov	al,ds:lega_idle_step
		mov	bx,lega_phase_xlat_a
		xlat				; al=[al+[bx]] table
		mov	ds:lega_phase_step,al
		cmp	al,3
		jb	lega_idle_apply			; Jump if below
		mov	byte ptr ds:gvar_spawn_fx_flag,33h	; '3'

lega_idle_apply:
		jmp	lega_phase_dir_apply
		db	0, 1, 2, 3, 6, 7
		db	6, 3, 2, 1

lega_idle_late_phase:
		mov	ah,ds:lega_idle_step
		mov	al,6
		cmp	ah,6
		jae	$+8			; Jump if above or =
		mov	al,ah
		mov	bx,lega_phase_xlat_b
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[0A7BAh],al
		jmp	$-26Dh

; ------------------------------------------------------------------
; Module trailer: dispatch-table handler body + jump-table words
; + tile/cell continuation data + 'Tarso' town-name fragment.
; Entered via dispatch call [lega_dispatch_tbl+bx] from main loop.
; ------------------------------------------------------------------
			                        ;* No entry point to code
		add	ax,[bp+di]		; data bytes
		add	al,4			; data bytes
		add	ax,0C605h		; data bytes
		push	es			; data byte
;*		xor	bh,bh			; Zero register
		db	030h, 0FFh		; xor bh,bh (alt encoding) -- data bytes
;*		inc	bx
		db	0FFh, 0C3h		; inc bx (alt encoding) -- data bytes
; jump-table: 10 word entries pointing into cs:A6DC..A798 handlers
		db	0DCh,0A6h,0E3h,0A6h,0ECh,0A6h
		db	0F6h,0A6h, 01h,0A7h, 0Ch,0A7h
		db	 18h,0A7h, 22h,0A7h, 2Eh,0A7h
		db	 39h,0A7h, 11h, 10h, 12h, 13h
		db	 14h, 15h, 16h, 11h, 17h, 19h
		db	 10h, 12h, 18h, 1Ah, 1Bh, 1Ch
		db	 1Dh, 1Fh, 21h, 23h, 10h, 1Eh
		db	' "$'
		db	'%)*', 27h, '&('
		db	 10h, 1Eh
		db	' "$'
		db	'%20-1+.'
		db	 10h, 1Eh
		db	' ,/=:<;3'
		db	10h
		db	'456789BC@D>'
		db	10h
		db	'?AEFXYZOPRTVQSUW'
		db	0CAh, 42h, 47h, 40h, 48h, 3Eh
		db	 10h, 3Fh, 41h, 45h, 46h,0CEh
		db	 42h, 4Dh, 40h, 4Ch, 3Eh, 10h
		db	 3Fh, 41h, 45h, 46h, 58h,0A7h
		db	 60h,0A7h, 68h,0A7h, 70h,0A7h
		db	 78h,0A7h, 80h,0A7h, 88h,0A7h
		db	 90h,0A7h, 98h,0A7h, 98h,0A7h
		db	 00h, 00h, 00h, 00h, 20h,0ABh
		db	 01h, 00h, 00h, 00h, 00h, 00h
		db	 2Ch,0ADh, 01h, 00h, 00h, 00h
		db	 00h, 00h, 2Bh, 80h, 2Bh, 01h
		db	 00h, 00h, 05h, 10h, 28h, 80h
		db	 2Bh, 01h, 08h, 04h, 18h, 00h
		db	 28h, 80h, 2Bh, 00h, 00h, 02h
		db	 14h, 10h, 20h,0A8h, 0Ch, 03h
		db	 00h, 00h, 03h, 05h, 10h, 55h
		db	 00h, 01h, 00h, 00h, 00h, 00h
		db	 0Bh,0ABh, 53h, 00h, 01h, 00h
		db	 03h, 05h, 10h, 55h, 00h, 01h
		db	 26h, 00h, 07h, 80h, 02h, 70h
		db	 17h, 08h,0FFh,0ADh,0A7h,0DCh
		db	 05h, 11h,0BBh, 02h, 05h
; 'Tarso' - town-name / label string fragment
		db	'Tarso'
; trailing zero padding to round module size up
		db	99 dup (0)

seg_a		ends

		end	start
