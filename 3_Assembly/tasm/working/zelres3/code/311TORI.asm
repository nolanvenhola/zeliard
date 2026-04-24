
PAGE  59,132

;==========================================================================
;
;  311TORI.BIN - Tori / Bird Enemy Code Module (zelres3 chunk 12, 'Pollo')
;
;  Tori (bird) enemy sprite/logic module loaded by 200FIGHT.asm alongside
;  EAI3/EAI4 behavior handlers.  The Japanese name "tori" means bird;
;  the Spanish marker 'Pollo' ('chicken/bird') appears as a text tag
;  in the module's trailing data.
;
;  Primary entry: tori_scan_and_update -- iterates the enemy slot list
;  (SI = fight_slot_list), handles bird-specific flight/glide patterns,
;  composes multi-plane sprite rows via sub_1 (row plotter), and spawns
;  swoop/dive projectiles when in-range.
;
;  Sub-functions: sub_1 (bit-stream sprite row renderer with [bp]+[si]),
;  sub_2..sub_5 (phase counters for glide/turn/swoop states), sub_6
;  (range-gated spawn / initial state reset).  Tail carries 'Pollo'.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; Fight-engine callback vectors / shared globals (DS, game_seg).

fight_cb_prep		equ	200Ch			; prep/init callback
fight_cb_record_ofs	equ	6028h			; compute record addr from tile
fight_cb_anim_step	equ	6036h			; animation advance callback
fight_cb_hit_check	equ	6038h			; per-slot hit/collision query
fight_cb_aim		equ	603Ah			; aim/target callback
fight_cb_shutdown	equ	603Ch			; shutdown callback

; Shared pattern / AI tables (DS).

sprite_pat_tbl		equ	0A64Dh			; sprite pattern table
glide_table_a		equ	0A682h			; glide path A
glide_table_b		equ	0A688h			; glide path B
glide_table_c		equ	0A68Eh			; glide path C
ai_column_tbl		equ	0A6CBh			; AI column-index table (xlat base)

; Tori-specific global state (DS).

tori_spawn_tile		equ	0A766h			; spawn-cell tile
tori_spawn_col		equ	0A767h			; spawn-cell col
tori_hp			equ	0A773h			; Tori HP counter
tori_row_hi		equ	0A775h			; row hi byte
tori_row_lo		equ	0A776h			; row lo byte
tori_slot_idx		equ	0A789h			; current slot index
tori_dir_state		equ	0A78Ah			; direction state byte
tori_phase_a		equ	0A78Bh			; phase byte A
tori_glide_flag		equ	0A78Ch			; gliding-active flag
tori_sub_phase		equ	0A78Dh			; sub-phase counter
tori_attack_flag	equ	0A78Eh			; attack mode flag
tori_swoop_ctr		equ	0A78Fh			; swoop counter
tori_turn_flag		equ	0A790h			; turning flag
tori_cycle_idx		equ	0A791h			; cycle index byte
tori_frame_idx		equ	0A792h			; frame-index byte
tori_anim_state		equ	0A793h			; animation state byte
tori_pattern_idx	equ	0A794h			; pattern index
tori_anim_timer		equ	0A795h			; anim-timer byte
tori_phase_count	equ	0A796h			; phase counter
tori_phase_limit	equ	0A797h			; phase limit
tori_dive_flag		equ	0A798h			; dive-flag byte
tori_turn_cooldown	equ	0A799h			; turn cooldown
tori_altitude		equ	0A79Ah			; altitude (y) position byte
tori_alt_state		equ	0A79Bh			; alternate state byte
tori_tmp_buf		equ	0A79Ch			; temp buffer offset (0x48 bytes)
fight_state_max		equ	0C002h			; max state index (for wrap)
fight_slot_list		equ	0C010h			; base of enemy slot list
sprite_idx_table	equ	0ED20h			; sprite index mapping table
gvar_death_flag		equ	0FF2Eh			; tori death flag global
gvar_dir_toggle		equ	0FF2Fh			; dir-toggle flag global
gvar_completion		equ	0FF30h			; completion/stage flag global
gvar_spawn_fx_flag	equ	0FF75h			; flag byte for spawn VFX

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

tori_main	proc	far

start:
		in	al,7			; port 7, DMA-1 bas&cnt ch 3
		add	[bx+si],al
;*		aam	0A1h			; undocumented inst
		db	0D4h,0A1h		;  Fixup - byte match
		jnc	$-57h			; Jump if carry=0
		db	12 dup (0)
		db	 38h, 12h
		db	30 dup (12h)
		db	 4Eh,0A0h, 67h,0A0h, 94h,0A0h
		db	0BCh,0A0h,0DAh,0A0h, 02h,0A1h
		db	 16h,0A1h, 2Ah,0A1h, 3Eh,0A1h
		db	 52h,0A1h, 57h,0A1h, 70h,0A1h
		db	 8Eh,0A1h,0ACh,0A1h,0C5h,0A1h
		db	 00h, 01h, 02h, 03h, 04h, 00h
		db	 9Ch, 02h, 9Dh, 04h, 00h, 29h
		db	 2Ah, 2Bh, 2Ch, 00h, 6Ah, 6Bh
		db	 6Ch, 6Dh, 00h, 6Ah, 6Bh, 8Ah
		db	 6Dh, 00h, 0Eh, 0Fh, 12h, 13h
		db	 00h, 2Dh, 32h, 2Eh, 2Fh, 00h
		db	 2Dh, 49h, 2Eh, 50h, 00h, 2Dh
		db	 00h, 2Eh, 58h, 00h
data_3		db	0
		db	 62h, 66h
data_4		db	67h
		db	 00h, 7Dh, 7Eh, 00h, 87h, 00h
		db	 7Dh, 7Eh
data_5		db	0			; Data table (indexed access)
		db	 19h, 00h, 00h, 00h, 8Fh, 90h
		db	 00h, 96h, 97h, 98h, 99h, 00h
		db	 10h, 11h, 14h, 00h, 00h, 00h
		db	 3Bh, 38h, 39h, 00h, 4Dh, 4Eh
		db	 49h, 4Ah, 00h, 00h, 00h, 59h
		db	 5Ah, 00h, 63h, 64h, 68h, 69h
		db	 00h, 00h, 72h, 6Eh, 6Fh, 00h
		db	 91h, 00h, 94h, 95h, 00h, 99h
		db	 9Ah, 28h, 9Bh, 00h, 00h, 05h
		db	 06h, 07h, 00h, 39h, 3Ah, 36h
		db	 37h, 00h, 4Fh, 00h, 4Bh, 4Ch
		db	 00h, 00h, 5Bh, 00h, 5Fh, 00h
		db	 65h, 00h,0A4h,0A5h, 00h, 7Ah
		db	 00h, 76h, 77h, 00h, 15h, 16h
		db	 17h, 18h, 00h, 35h, 36h, 33h
		db	 34h, 00h, 50h, 51h, 3Ch, 3Dh
		db	 00h, 5Ch, 5Dh, 60h, 61h, 00h
		db	 2Eh,0A6h, 00h, 3Ch, 00h, 7Bh
		db	 7Ch, 78h, 79h, 00h, 92h, 93h
		db	0ACh,0ABh, 00h,0AAh, 28h, 27h
		db	 26h, 00h, 08h, 09h, 19h, 1Ah
		db	 00h, 08h, 09h, 1Ch, 1Dh, 00h
		db	 08h, 09h, 19h, 1Fh, 00h
		db	 08h, 09h, 21h, 22h
data_6		dw	900h
		db	 0Ah, 1Ah, 1Bh, 00h, 09h, 0Ah
		db	 1Dh, 1Eh, 00h, 09h, 0Ah, 1Fh
		db	 20h, 00h, 09h, 0Ah, 22h, 23h
		db	 00h,0AFh,0B0h,0B1h,0B2h, 00h
		db	 0Bh, 00h, 8Bh,0BAh, 00h, 0Bh
		db	 00h, 8Bh, 8Ch, 00h, 0Bh,0B5h
		db	0B3h,0B4h, 00h, 0Bh,0B1h, 0Ch
		db	 0Dh, 00h, 00h,0ADh,0BBh,0AEh
		db	 00h, 00h, 00h, 8Dh, 8Eh, 00h
		db	0B6h,0B7h, 00h,0B8h, 00h,0B1h
		db	0B2h, 0Dh,0B9h, 00h, 2Fh, 30h
		db	 3Ch, 3Dh, 00h, 52h, 53h, 3Eh
		db	 3Fh, 00h, 5Eh, 3Fh, 42h, 43h
		db	 00h,0A7h,0A8h, 3Dh, 3Eh, 00h
		db	 73h, 74h, 70h, 71h, 00h, 31h
		db	 00h, 3Eh, 3Fh, 00h, 40h, 41h
		db	 00h, 00h, 00h, 9Eh, 9Fh,0A1h
		db	0A2h, 00h,0A9h, 00h, 3Fh, 00h
		db	 00h, 75h, 00h, 00h, 82h, 00h
		db	 75h, 00h, 00h, 00h, 00h, 40h
		db	 41h, 00h, 44h, 00h, 42h, 43h
		db	 54h, 46h, 00h,0A0h, 44h,0A3h
		db	 47h, 00h, 40h, 41h, 00h, 00h
		db	 00h, 85h, 86h, 83h, 84h, 00h
		db	 3Dh, 7Fh, 1Ah, 1Bh, 00h, 42h
		db	 43h, 45h, 46h, 00h, 55h, 00h
		db	 56h, 57h, 00h, 45h, 46h, 48h
		db	 00h, 00h, 3Dh, 7Fh, 88h, 89h
		db	 00h, 3Fh, 00h, 8Bh, 8Ch, 00h
		db	 44h, 45h, 47h, 48h, 00h, 80h
		db	 81h, 00h, 00h, 00h, 00h, 00h
		db	 8Dh, 8Eh, 8Bh, 36h, 10h,0C0h
		db	0C6h, 06h, 89h,0A7h, 00h,0C6h
		db	 06h, 91h,0A7h, 00h
loc_1:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jz	loc_4			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:fight_cb_anim_step
		jc	loc_3			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	bl,ds:tori_slot_idx
		xor	bh,bh			; Zero register
		mov	al,ds:sprite_idx_table[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	loc_3			; Jump if zero
		test	byte ptr ds:tori_cycle_idx,80h
		jnz	loc_3			; Jump if not zero
		mov	al,[si+5]
		and	al,1Fh
		test	byte ptr [si+4],0FFh
		jnz	loc_2			; Jump if not zero
		or	al,80h
loc_2:
		mov	ds:tori_cycle_idx,al
loc_3:
		inc	byte ptr ds:tori_slot_idx
		add	si,10h
		jmp	short loc_1
loc_4:
		mov	si,ds:fight_slot_list
		mov	word ptr [si],0FFFh
		mov	al,ds:tori_cycle_idx
		or	al,al			; Zero ?
		jz	loc_8			; Jump if zero
		push	ax
		and	al,1Fh
		call	word ptr cs:fight_cb_hit_check
		mov	bl,ah
		xor	bh,bh			; Zero register
		pop	ax
		add	bx,bx
		or	al,al			; Zero ?
		jns	loc_5			; Jump if not sign
		add	bx,bx
		add	bx,bx
loc_5:
		mov	byte ptr ds:gvar_spawn_fx_flag,29h	; ')'
		call	sub_6
		test	byte ptr ds:tori_glide_flag,0FFh
		jz	loc_6			; Jump if zero
		mov	byte ptr ds:tori_glide_flag,0
		mov	byte ptr ds:tori_sub_phase,0
		mov	byte ptr ds:tori_attack_flag,0FFh
loc_6:
		jnz	loc_7			; Jump if not zero
		call	sub_5
loc_7:
		mov	byte ptr ds:tori_anim_timer,4
loc_8:
		mov	byte ptr ds:tori_phase_a,0
		test	byte ptr ds:tori_anim_timer,0FFh
		jz	loc_9			; Jump if zero
		dec	byte ptr ds:tori_anim_timer
		mov	byte ptr ds:tori_phase_a,1
loc_9:
		test	byte ptr ds:tori_glide_flag,0FFh
		jz	loc_14			; Jump if zero
		cmp	byte ptr ds:tori_row_hi,0Eh
		je	loc_10			; Jump if equal
		dec	byte ptr ds:tori_row_hi
loc_10:
		inc	byte ptr ds:tori_sub_phase
		and	byte ptr ds:tori_sub_phase,3
		cmp	byte ptr ds:tori_sub_phase,2
		jne	loc_11			; Jump if not equal
		mov	byte ptr ds:gvar_spawn_fx_flag,2Bh	; '+'
loc_11:
		call	sub_4
		jc	loc_12			; Jump if carry Set
		test	byte ptr ds:tori_alt_state,0FFh
		jz	loc_12			; Jump if zero
		dec	byte ptr ds:tori_alt_state
		test	byte ptr ds:tori_cycle_idx,0FFh
		jz	loc_13			; Jump if zero
loc_12:
		mov	byte ptr ds:tori_glide_flag,0
		mov	byte ptr ds:tori_sub_phase,0
		mov	byte ptr ds:tori_attack_flag,0FFh
		mov	byte ptr ds:gvar_spawn_fx_flag,2Ah	; '*'
loc_13:
		jmp	loc_30
loc_14:
		test	byte ptr ds:tori_attack_flag,0FFh
		jz	loc_17			; Jump if zero
		cmp	byte ptr ds:tori_sub_phase,1
		jne	loc_15			; Jump if not equal
		mov	byte ptr ds:tori_attack_flag,0
		jmp	loc_30
loc_15:
		mov	byte ptr ds:tori_sub_phase,1
		cmp	byte ptr ds:tori_row_hi,12h
		je	loc_16			; Jump if equal
		inc	byte ptr ds:tori_row_hi
		mov	byte ptr ds:tori_sub_phase,0
		call	sub_3
loc_16:
		jmp	loc_30
loc_17:
		test	byte ptr ds:tori_phase_limit,0FFh
		jz	loc_20			; Jump if zero
		inc	byte ptr ds:tori_turn_flag
		and	byte ptr ds:tori_turn_flag,3
		call	sub_2
		jnc	loc_18			; Jump if carry=0
		jmp	loc_30
loc_18:
		cmp	byte ptr ds:tori_dive_flag,4
		jae	loc_19			; Jump if above or =
		inc	byte ptr ds:tori_dive_flag
		mov	byte ptr ds:gvar_spawn_fx_flag,2Ah	; '*'
		mov	byte ptr ds:tori_anim_timer,4
		jmp	loc_30
loc_19:
		mov	byte ptr ds:tori_phase_limit,0
		mov	byte ptr ds:tori_sub_phase,0
		mov	byte ptr ds:tori_glide_flag,0FFh
		mov	byte ptr ds:tori_alt_state,0Fh
		jmp	loc_30
loc_20:
		test	byte ptr ds:tori_altitude,0FFh
		jz	loc_23			; Jump if zero
		call	sub_2
		jnc	loc_21			; Jump if carry=0
		jmp	loc_30
loc_21:
		cmp	byte ptr ds:tori_dive_flag,2
		jae	loc_22			; Jump if above or =
		inc	byte ptr ds:tori_dive_flag
		mov	byte ptr ds:gvar_spawn_fx_flag,2Ah	; '*'
		mov	byte ptr ds:tori_anim_timer,2
		jmp	loc_30
loc_22:
		mov	ax,ds:tori_hp
		add	ax,4
		call	word ptr cs:fight_cb_anim_step
		mov	ds:tori_spawn_tile,bl
		mov	al,ds:tori_row_hi
		add	al,4
		and	al,3Fh			; '?'
		mov	ds:tori_spawn_col,al
		mov	bx,0A766h
		call	word ptr cs:fight_cb_aim
		mov	byte ptr ds:tori_altitude,0
		jmp	loc_30
loc_23:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	loc_24			; Jump if zero
		jmp	loc_55
loc_24:
		inc	byte ptr ds:tori_turn_flag
		and	byte ptr ds:tori_turn_flag,3
		test	byte ptr ds:tori_cycle_idx,0FFh
		jz	loc_25			; Jump if zero
		cmp	byte ptr ds:tori_hp,14h
		jb	loc_25			; Jump if below
		mov	byte ptr ds:tori_phase_limit,0FFh
		mov	byte ptr ds:tori_dive_flag,0
loc_25:
		test	byte ptr ds:tori_phase_limit,0FFh
		jnz	loc_26			; Jump if not zero
		call	word ptr cs:data_6
		and	al,0Fh
		jnz	loc_26			; Jump if not zero
		mov	byte ptr ds:tori_altitude,0FFh
		mov	byte ptr ds:tori_dive_flag,0
loc_26:
		inc	byte ptr ds:tori_phase_count
		test	byte ptr ds:tori_phase_count,1
		jnz	loc_30			; Jump if not zero
		mov	al,data_3
		add	al,data_4
		xor	ah,ah			; Zero register
		mov	cx,ax
		sub	cx,ds:fight_state_max
		jc	loc_27			; Jump if carry Set
		xchg	cx,ax
loc_27:
		mov	bl,ds:tori_hp
		sub	bl,al
		cmp	bl,0Ch
		je	loc_29			; Jump if equal
		jnc	loc_28			; Jump if carry=0
		dec	byte ptr ds:tori_dir_state
		and	byte ptr ds:tori_dir_state,3
		call	sub_5
		jnc	loc_30			; Jump if carry=0
		mov	byte ptr ds:tori_phase_limit,0FFh
		mov	byte ptr ds:tori_dive_flag,0
		jmp	short loc_30
loc_28:
		inc	byte ptr ds:tori_dir_state
		and	byte ptr ds:tori_dir_state,3
		call	sub_3
loc_29:
		call	word ptr cs:data_6
		and	al,1Fh
		jnz	loc_30			; Jump if not zero
		mov	byte ptr ds:tori_phase_limit,0FFh
		mov	byte ptr ds:tori_dive_flag,0
loc_30:
		mov	al,ds:tori_row_hi
		mov	ds:tori_anim_state,al
		push	cs
		pop	es
		mov	di,tori_tmp_buf
		mov	al,0FFh
		mov	cx,48h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		test	byte ptr ds:tori_turn_cooldown,0FFh
		jnz	loc_31			; Jump if not zero
		test	byte ptr ds:tori_attack_flag,0FFh
		jz	loc_32			; Jump if zero
loc_31:
		mov	al,ds:tori_sub_phase
		and	al,1
		add	al,11h
		call	sub_1
		jmp	short loc_34
loc_32:
		test	byte ptr ds:tori_glide_flag,0FFh
		jz	loc_33			; Jump if zero
		mov	al,ds:tori_sub_phase
		and	al,3
		add	al,0Dh
		call	sub_1
		mov	al,ds:tori_sub_phase
		shr	al,1			; Shift w/zeros fill
		adc	byte ptr ds:tori_anim_state,0
		jmp	short loc_34
loc_33:
		mov	al,ds:tori_phase_a
		call	sub_1
		mov	al,ds:tori_dir_state
		add	al,6
		call	sub_1
		mov	al,ds:tori_swoop_ctr
		add	al,0Ah
		call	sub_1
		mov	al,ds:tori_turn_flag
		add	al,2
		call	sub_1
loc_34:
		mov	byte ptr ds:tori_slot_idx,0
		mov	ax,ds:tori_hp
		mov	di,ds:fight_slot_list
		mov	si,tori_tmp_buf
		mov	cx,9

locloop_35:
		push	cx
		push	si
		push	ax
		call	word ptr cs:fight_cb_anim_step
		pop	ax
		jc	loc_39			; Jump if carry Set
		mov	ds:tori_frame_idx,bl
		xor	cx,cx			; Zero register
loc_36:
		push	cx
		push	ax
		cmp	byte ptr [si],0FFh
		je	loc_38			; Jump if equal
		mov	[di],ax
		mov	al,ds:tori_anim_state
		add	al,cl
		and	al,3Fh			; '?'
		mov	[di+2],al
		mov	al,ds:tori_frame_idx
		mov	[di+3],al
		mov	al,[si]
		mov	ah,al
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		and	al,0Fh
		mov	[di+4],al
		mov	[di+6],ah
		mov	byte ptr [di+5],0
		test	byte ptr ds:tori_cycle_idx,0FFh
		jz	loc_37			; Jump if zero
		or	byte ptr [di+5],20h	; ' '
loc_37:
		mov	ax,[di+2]
		push	di
		call	word ptr cs:fight_cb_record_ofs
		mov	bl,ds:tori_slot_idx
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:sprite_idx_table[bx],al
		pop	di
		add	di,10h
		inc	byte ptr ds:tori_slot_idx
loc_38:
		inc	si
		pop	ax
		pop	cx
		inc	cx
		cmp	cx,8
		jne	loc_36			; Jump if not equal
loc_39:
		inc	ax
		pop	si
		add	si,8
		pop	cx
		loop	locloop_35		; Loop if cx > 0

		mov	word ptr [di],0FFFFh
		retn

tori_main	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		add	al,al
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	si,ds:sprite_pat_tbl[bx]
		mov	bp,ds:ai_column_tbl[bx]
		mov	di,tori_tmp_buf
		mov	cx,9

locloop_40:
		push	cx
		mov	cx,8

locloop_41:
		rol	byte ptr ds:[bp],1	; Rotate
		jnc	loc_42			; Jump if carry=0
		lodsb				; String [si] to al
		mov	[di],al
loc_42:
		inc	di
		loop	locloop_41		; Loop if cx > 0

		inc	bp
		pop	cx
		loop	locloop_40		; Loop if cx > 0

		retn
sub_1		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_2		proc	near
		inc	byte ptr ds:tori_swoop_ctr
		cmp	byte ptr ds:tori_swoop_ctr,3
		stc				; Set carry flag
		jz	loc_43			; Jump if zero
		retn
loc_43:
		mov	byte ptr ds:tori_swoop_ctr,0
		clc				; Clear carry flag
		retn
sub_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_3		proc	near
		cmp	byte ptr ds:tori_hp,0Dh
		jae	loc_44			; Jump if above or =
		retn
loc_44:
		dec	byte ptr ds:tori_hp
		clc				; Clear carry flag
		retn
sub_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_4		proc	near
		cmp	byte ptr ds:tori_hp,11h
		jae	loc_45			; Jump if above or =
		retn
loc_45:
		dec	byte ptr ds:tori_hp
		clc				; Clear carry flag
		retn
sub_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_5		proc	near
		cmp	byte ptr ds:tori_hp,30h	; '0'
		cmc				; Complement carry
		jnc	loc_46			; Jump if carry=0
		retn
loc_46:
		inc	byte ptr ds:tori_hp
		clc				; Clear carry flag
		retn
sub_5		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_6		proc	near
		mov	ax,ds:tori_row_lo
		sub	ax,bx
		jnc	loc_47			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_47:
		mov	ds:tori_row_lo,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:fight_cb_prep
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_48			; Jump if zero
		retn
loc_48:
		mov	byte ptr ds:gvar_death_flag,0FFh
		call	word ptr cs:fight_cb_shutdown
		mov	byte ptr ds:tori_phase_limit,0
		mov	byte ptr ds:tori_altitude,0
		mov	byte ptr ds:tori_dive_flag,0
		test	byte ptr ds:tori_glide_flag,0FFh
		jnz	loc_49			; Jump if not zero
		retn
loc_49:
		mov	byte ptr ds:tori_pattern_idx,0
		mov	byte ptr ds:tori_glide_flag,0
loc_54:
		mov	byte ptr ds:tori_sub_phase,0
		mov	byte ptr ds:tori_attack_flag,0FFh
		retn
sub_6		endp

loc_55:
		mov	al,ds:tori_pattern_idx
		cmp	al,28h			; '('
		jae	loc_57			; Jump if above or =
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		mov	byte ptr ds:tori_phase_a,1
		mov	al,ds:tori_pattern_idx
		inc	byte ptr ds:tori_pattern_idx
		cmp	al,14h
		jae	loc_56			; Jump if above or =
		call	sub_2
		inc	byte ptr ds:tori_turn_flag
		and	byte ptr ds:tori_turn_flag,3
		mov	byte ptr ds:gvar_spawn_fx_flag,2Ch	; ','
		jmp	loc_30
loc_56:
		mov	byte ptr ds:tori_turn_cooldown,0FFh
		mov	byte ptr ds:tori_sub_phase,1
		jmp	loc_30
loc_57:
		mov	byte ptr ds:gvar_completion,0FFh
		retn
			                        ;* No entry point to code
		jnc	loc_49			; Jump if carry=0
;*		jnz	loc_50			;*Jump if not zero
		db	 75h,0A6h		;  Fixup - byte match
;*		ja	loc_51			;*Jump if above
		db	 77h,0A6h		;  Fixup - byte match
;*		jp	loc_52			;*Jump if parity=1
		db	 7Ah,0A6h		;  Fixup - byte match
;*		jl	loc_53			;*Jump if <
		db	 7Ch,0A6h		;  Fixup - byte match
		jle	loc_54			; Jump if < or =
		and	byte ptr ss:glide_table_a[bp],84h
		cmpsb				; Cmp [si] to es:[di]
		xchg	ss:glide_table_b[bp],ah
		mov	sp,ss:glide_table_c[bp]
		xchg	cx,ax
		cmpsb				; Cmp [si] to es:[di]
		db	 9Bh,0A6h,0A4h,0A6h,0ADh,0A6h
		db	0B7h,0A6h,0C1h,0A6h, 00h, 30h
		db	 01h, 30h, 80h, 70h, 90h, 71h
		db	 81h, 72h, 82h, 73h, 83h
		db	'P`QaRbSc'
		db	 10h, 40h, 20h, 17h, 46h, 26h
		db	 18h, 47h, 27h, 02h, 11h,0A0h
		db	0C0h, 21h, 41h,0E0h, 31h,0B0h
		db	0D0h, 02h, 12h, 22h, 42h,0B1h
		db	 32h,0A1h,0C1h,0D1h, 02h, 33h
		db	0B2h, 13h, 43h,0C2h, 23h,0A2h
		db	0D2h, 02h, 14h, 44h,0C3h, 24h
		db	0A3h,0C1h,0D1h, 34h,0B3h, 03h
		db	 25h, 15h, 35h,0A4h,0D3h, 45h
		db	0B4h,0E1h,0C4h, 04h, 25h, 16h
		db	 35h,0A4h,0C5h, 45h,0B5h,0D4h
		db	0E2h,0F1h,0A6h,0F1h,0A6h,0FAh
		db	0A6h, 03h,0A7h, 03h,0A7h, 03h
		db	0A7h, 0Ch,0A7h, 0Ch,0A7h, 0Ch
		db	0A7h, 0Ch,0A7h, 15h,0A7h, 1Eh
		db	0A7h, 27h,0A7h, 30h,0A7h, 39h
		db	0A7h, 42h,0A7h, 4Bh,0A7h, 54h
		db	0A7h, 5Dh,0A7h, 00h, 00h
		db	50h
		db	12 dup (0)
		db	 04h, 0Ch
		db	7 dup (0)
		db	4, 0, 4, 0, 0, 0
		db	4, 4
		db	8 dup (0)
		db	 50h, 00h, 40h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 50h, 00h, 20h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 50h, 20h, 00h, 00h, 00h, 10h
		db	 00h, 10h, 0Ah,0A1h, 4Ah, 00h
		db	 00h, 00h, 20h, 00h, 20h, 54h
		db	 00h, 55h, 00h, 00h, 00h, 10h
		db	 05h, 10h, 05h, 10h, 05h, 00h
		db	 00h, 00h, 20h, 00h, 50h, 04h
		db	 50h, 05h, 50h, 00h, 00h, 04h
		db	 00h, 14h, 00h, 54h, 00h, 54h
		db	 00h, 10h, 04h, 00h, 14h, 00h
		db	 54h, 00h, 54h, 00h, 04h, 00h
		db	 00h,0A7h, 00h, 32h, 04h, 28h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 2Eh, 00h, 12h,0F4h, 01h,0F4h
		db	 01h, 08h,0FFh, 80h,0A7h,0F4h
		db	 01h, 12h,0BBh, 00h, 05h
		db	 50h, 6Fh, 6Ch, 6Ch, 6Fh
		db	91 dup (0)

seg_a		ends



		end	start
