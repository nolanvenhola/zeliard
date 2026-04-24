
PAGE  59,132

;==========================================================================
;
;  309CRAB.BIN - Crab Enemy Code Module (zelres3 chunk 10, 'Cangrejo')
;
;  Crab-type enemy sprite/logic module loaded by 200FIGHT.asm alongside
;  EAI1/EAI2 behavior handlers.  The Spanish name 'Cangrejo' ('crab')
;  appears as a text marker in the module's trailing data.
;
;  Primary entry: eai_scan_and_update -- iterates the enemy slot list
;  (SI = fight_slot_list), updates each live slot via the EAI behavior
;  callbacks, then re-spawns crabs when range/slot-count conditions
;  permit (`sub_1`/`sub_2` adjust fight_hp; `sub_3` emits crab sprite
;  rows into the slot buffer).
;
;  The tail of the file carries 'Cangrejo' as an 8-char name tag used
;  by the game data loader / debug display.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; Fight-engine callback vectors / shared globals (DS at game_seg).

fight_cb_prep		equ	200Ch			; prep/init callback
fight_cb_record_ofs	equ	6028h			; compute record addr from tile
fight_cb_anim_step	equ	6036h			; animation advance callback
fight_cb_hit_check	equ	6038h			; per-slot hit/collision query
sprite_src_alt		equ	8080h			; alternate sprite-source base
sprite_src_aux		equ	80A1h			; auxiliary sprite-source base

; Crab-specific global state (DS, game_seg).

crab_spawn_limit	equ	0A481h			; max simultaneous crab spawns
crab_anim_tbl_a		equ	0A5B6h			; crab animation sequence A
crab_anim_tbl_b		equ	0A5F5h			; crab animation sequence B (misc)
crab_anim_tbl_c		equ	0A5F9h			; crab animation sequence C
crab_pos_tbl		equ	0A70Ah			; crab spawn position/grid table
fight_hp		equ	0A7C3h			; current fight HP (crab counter)
crab_phase_base		equ	0A7C5h			; phase-base byte
crab_phase_limit	equ	0A7C6h			; phase-limit byte
crab_slot_idx		equ	0A7DCh			; current slot index
crab_state_bits		equ	0A7DDh			; packed state bits
crab_frame_idx		equ	0A7DEh			; frame index (0..5)
crab_flag_d		equ	0A7DFh			; flag byte (phase selector)
crab_dir_flag		equ	0A7E0h			; direction flag
crab_sub_phase		equ	0A7E1h			; sub-phase counter
crab_flag_g		equ	0A7E2h			; crab activity flag
crab_flag_h		equ	0A7E3h			; crab persistent flag
crab_idx_e		equ	0A7E5h			; crab helper index E
crab_anim_idx		equ	0A7E6h			; animation step index
crab_anim_frame		equ	0A7E7h			; current animation frame
crab_row_pos		equ	0A7E8h			; current row position
crab_col_pos		equ	0A7E9h			; current col position
crab_anim_base		equ	0A7EAh			; animation base (word)
crab_timer_a		equ	0A7ECh			; phase timer A
crab_timer_b		equ	0A7EDh			; phase timer B
fight_state_max		equ	0C002h			; max state index (for wrap)
fight_slot_list		equ	0C010h			; base of enemy/crab slot list
sprite_idx_table	equ	0ED20h			; sprite index mapping table
gvar_death_flag		equ	0FF2Eh			; crab death flag global
gvar_dir_toggle		equ	0FF2Fh			; dir-toggle flag global
gvar_completion		equ	0FF30h			; completion/stage flag global
gvar_spawn_fx_flag	equ	0FF75h			; flag byte for spawn VFX

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

crab_main	proc	far

start:
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		pop	es
		add	[bx+si],al
                           lock	mov	ds:fight_hp,al
		db	12 dup (0)
		db	21 dup (6)
		db	0Fh
		db	10 dup (6)
		db	 5Ch,0A0h, 8Eh,0A0h,0BBh,0A0h
		db	0EDh,0A0h, 1Fh,0A1h, 4Ch,0A1h
		db	 7Eh,0A1h,0B0h,0A1h,0E2h,0A1h
		db	14 dup (0)
		db	 14h,0A2h, 46h,0A2h, 73h,0A2h
		db	 00h, 00h,0A5h,0A2h,0D7h,0A2h
		db	 00h, 00h, 00h, 00h, 01h, 00h
		db	 00h, 00h, 26h, 27h, 00h, 00h
		db	 00h, 00h, 01h, 00h, 00h, 00h
		db	 26h, 27h, 00h, 00h, 00h, 00h
		db	 01h, 00h, 00h, 00h, 26h, 27h
		db	 00h, 00h
data_5		dw	2600h
		db	 27h, 00h, 00h, 00h, 26h, 27h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 01h, 02h, 0Ah, 0Bh, 00h, 00h
		db	 00h, 02h, 00h, 00h, 00h, 00h
		db	 28h, 29h, 00h, 00h, 00h, 02h
		db	 00h, 00h, 00h, 00h, 28h, 29h
		db	 00h, 00h, 00h, 02h, 00h, 00h
		db	 00h, 00h, 28h, 29h, 00h, 00h
		db	 00h, 28h, 29h, 00h, 00h, 00h
		db	 28h, 29h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 03h, 04h, 00h, 05h
		db	 00h, 2Ah, 2Bh, 2Ch, 2Dh, 00h
		db	 03h, 04h, 00h, 47h, 00h, 2Ah
		db	 2Bh, 2Ch, 58h, 00h, 03h, 04h
		db	 00h, 69h, 00h, 2Ah, 2Bh, 2Ch
		db	 72h, 00h, 03h, 04h, 00h, 05h
		db	 00h, 03h, 04h, 00h, 05h, 00h
		db	 8Fh, 90h, 00h, 91h, 00h,0ADh
		db	0AEh,0AFh,0B0h, 00h, 06h, 07h
		db	 08h, 09h, 00h, 06h, 2Fh, 30h
		db	 31h, 00h, 06h, 07h, 48h, 49h
		db	 00h, 06h, 2Fh, 59h, 5Ah, 00h
		db	 06h, 07h, 59h, 5Ah, 00h, 06h
		db	 2Fh, 73h, 74h, 00h, 06h, 2Fh
		db	 08h, 09h, 00h, 06h, 2Fh, 08h
		db	 09h, 00h
data_6		dw	2692h
		db	 93h, 94h, 00h,0B1h, 07h,0B2h
		db	0B3h, 00h, 0Ah, 0Bh, 0Ch, 0Dh
		db	 00h, 32h, 33h, 0Ch, 0Dh, 00h
		db	 0Ah, 0Bh, 0Ch, 0Dh, 00h, 32h
		db	 33h, 0Ch, 0Dh, 00h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 00h, 32h, 33h, 0Ch
		db	 0Dh, 00h, 32h, 33h,0C5h,0C6h
		db	 00h, 32h, 33h, 0Ch, 0Dh, 00h
		db	 27h, 28h, 32h, 33h, 00h, 0Eh
		db	 35h, 10h, 11h, 00h, 34h, 35h
		db	 36h, 37h, 00h, 0Eh, 35h, 4Ah
		db	 4Bh, 00h, 34h, 35h, 5Bh, 5Ch
		db	 00h, 0Eh, 35h, 5Bh, 5Ch, 00h
		db	 34h, 35h, 75h, 76h, 00h, 34h
		db	 35h, 84h, 85h, 00h, 34h, 35h
		db	 84h, 85h, 00h, 29h, 95h, 96h
		db	 97h, 00h, 0Eh,0B4h,0B5h,0B6h
		db	 00h, 12h, 13h, 14h, 15h, 00h
		db	 38h, 39h, 3Ah, 00h, 00h, 12h
		db	 13h, 4Ch, 15h, 00h, 38h, 39h
		db	 5Dh, 00h, 00h, 12h, 13h, 5Dh
		db	 15h, 00h, 38h, 39h, 77h, 00h
		db	 00h, 12h, 13h, 14h, 15h, 00h
		db	 12h, 13h, 14h, 15h, 00h, 98h
		db	 99h, 9Ah, 00h, 00h,0B7h,0B8h
		db	0B9h,0BAh, 00h, 00h, 16h, 00h
		db	 17h, 00h, 00h, 3Bh, 3Ch, 3Dh
		db	 00h, 00h, 4Dh, 00h, 4Eh, 00h
		db	 5Eh, 5Fh, 00h, 60h, 00h, 0Fh
		db	 2Eh, 6Ah, 6Bh, 00h, 78h, 79h
		db	 7Ah, 7Bh, 00h, 86h, 87h, 00h
		db	 88h, 00h, 86h, 87h, 00h, 88h
		db	 00h, 9Bh, 9Ch, 9Dh, 9Eh, 00h
		db	0BBh,0BFh,0BCh, 00h, 00h, 23h
		db	 24h, 25h, 00h, 00h, 3Eh, 00h
		db	 3Fh, 00h, 00h, 55h, 00h, 56h
		db	 57h, 00h, 65h, 66h, 67h, 68h
		db	 00h, 6Fh, 70h, 71h, 00h, 00h
		db	 80h, 81h, 82h, 83h, 00h, 8Bh
		db	 8Ch, 8Dh, 8Eh, 00h, 8Bh, 8Ch
		db	 8Dh, 8Eh, 00h,0A9h,0AAh,0ABh
		db	0ACh, 00h, 00h,0C1h, 00h,0C2h
		db	 00h, 18h, 19h, 1Ah, 1Bh, 00h
		db	 40h, 19h, 42h, 43h, 00h, 4Fh
		db	 19h, 50h, 51h, 00h, 61h, 19h
		db	 62h, 1Bh, 00h, 6Ch, 19h, 6Dh
		db	 43h, 00h, 7Ch, 19h, 7Dh, 43h
		db	 00h, 18h, 19h, 00h, 1Bh, 00h
		db	 18h, 19h, 00h, 1Bh, 00h, 9Fh
		db	0A0h,0A1h,0A2h, 00h,0BDh, 19h
		db	0BFh, 43h, 00h, 1Ch, 1Dh, 1Eh
		db	 00h, 00h, 1Ch, 1Dh, 00h, 44h
		db	 00h, 1Ch, 1Dh, 1Eh, 44h, 00h
		db	 1Ch, 1Dh, 1Eh, 00h, 00h, 1Ch
		db	 1Dh, 00h, 00h, 00h, 1Ch, 1Dh
		db	 00h, 44h, 00h, 1Ch, 1Dh, 1Eh
		db	 00h, 00h, 1Ch, 1Dh, 1Eh, 00h
		db	 00h, 0Ch, 0Dh,0A3h,0A4h, 00h
		db	 1Fh, 20h, 21h, 22h, 00h, 1Fh
		db	 41h, 45h, 46h, 00h, 1Fh, 52h
		db	 53h, 54h, 00h, 1Fh, 63h, 21h
		db	 64h, 00h, 1Fh, 63h, 21h, 6Eh
		db	 00h, 1Fh, 7Eh, 53h, 7Fh, 00h
		db	 1Fh, 89h, 21h, 8Ah, 00h, 1Fh
		db	 89h, 21h, 8Ah, 00h,0A5h,0A6h
		db	0A7h,0A8h, 00h, 1Fh,0BEh, 21h
		db	0C0h, 00h,0C7h,0C8h, 1Ch, 1Dh
		db	 00h,0C9h,0CAh, 1Ch, 1Dh, 00h
		db	0CBh,0CCh,0CDh,0CEh, 00h,0CFh
		db	0D0h,0D1h,0D2h, 00h,0D3h,0D4h
		db	0D5h,0D6h, 00h,0C3h,0C4h, 1Ch
		db	 1Dh, 00h,0C5h,0C6h, 1Ch, 1Dh
		db	 00h, 0Ch, 0Dh, 1Ch, 1Dh, 00h
		db	 0Ch, 0Dh, 1Ch, 1Dh, 00h, 0Ch
		db	 0Dh, 1Ch, 1Dh, 00h,0D7h,0D8h
		db	0D9h, 00h, 00h,0DAh,0DBh,0DCh
		db	0DDh, 00h,0DEh,0DFh, 00h, 00h
		db	 00h,0E0h,0E1h, 00h, 00h, 00h
		db	0E2h,0E3h, 00h, 00h, 8Bh, 36h
		db	 10h,0C0h,0C6h, 06h,0DCh,0A7h
		db	 00h,0C6h, 06h,0DDh,0A7h, 00h
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
		mov	bl,ds:crab_slot_idx
		xor	bh,bh			; Zero register
		mov	al,ds:sprite_idx_table[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	loc_3			; Jump if zero
		test	byte ptr ds:crab_state_bits,80h
		jnz	loc_3			; Jump if not zero
		mov	al,[si+5]
		and	al,1Fh
		test	byte ptr [si+4],10h
		jz	loc_2			; Jump if zero
		or	al,80h
loc_2:
		mov	ds:crab_state_bits,al
loc_3:
		inc	byte ptr ds:crab_slot_idx
		add	si,10h
		jmp	short loc_1
loc_4:
		mov	si,ds:fight_slot_list
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:gvar_death_flag,0FFh
		jnz	loc_8			; Jump if not zero
		mov	al,ds:crab_state_bits
		or	al,al			; Zero ?
		jz	loc_8			; Jump if zero
		push	ax
		and	al,1Fh
		call	word ptr cs:fight_cb_hit_check
		mov	bl,ah
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		pop	ax
		or	al,al			; Zero ?
		jns	loc_5			; Jump if not sign
		add	bx,bx
loc_5:
		call	sub_4
		mov	byte ptr ds:gvar_spawn_fx_flag,22h	; '"'
		mov	ax,data_5
		add	ax,0Ch
		mov	bx,ds:fight_state_max
		cmp	ax,bx
		jb	loc_6			; Jump if below
		mov	ax,bx
loc_6:
		xchg	bx,ax
		mov	ax,ds:fight_hp
		add	ax,5
		cmp	ax,bx
		jae	loc_7			; Jump if above or =
		call	sub_1
		call	sub_1
		jmp	short loc_8
loc_7:
		call	sub_2
		call	sub_2
loc_8:
		test	byte ptr ds:crab_anim_idx,0FFh
		jz	loc_9			; Jump if zero
		jmp	loc_27
loc_9:
		test	byte ptr ds:[0A7E4h],0FFh
		jz	loc_10			; Jump if zero
		jmp	loc_43
loc_10:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	loc_11			; Jump if zero
		jmp	loc_44
loc_11:
		test	byte ptr ds:crab_flag_g,0FFh
		jz	loc_12			; Jump if zero
		jmp	loc_24
loc_12:
		call	word ptr cs:data_6
		and	al,7
		jnz	loc_13			; Jump if not zero
		jmp	loc_23
loc_13:
		test	byte ptr ds:crab_dir_flag,0FFh
		jnz	loc_17			; Jump if not zero
		inc	byte ptr ds:crab_sub_phase
		test	byte ptr ds:crab_sub_phase,1
		jz	loc_14			; Jump if zero
		jmp	loc_49
loc_14:
		call	sub_1
		jnc	loc_15			; Jump if carry=0
		mov	byte ptr ds:crab_dir_flag,0FFh
loc_15:
		inc	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,6
		jae	loc_16			; Jump if above or =
		jmp	loc_49
loc_16:
		mov	byte ptr ds:crab_frame_idx,0
		jmp	loc_49
loc_17:
		inc	byte ptr ds:crab_sub_phase
		test	byte ptr ds:crab_sub_phase,1
		jz	loc_18			; Jump if zero
		jmp	loc_49
loc_18:
		call	sub_2
		jnc	loc_19			; Jump if carry=0
		mov	byte ptr ds:crab_dir_flag,0
loc_19:
		dec	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,0FFh
		je	loc_20			; Jump if equal
		jmp	loc_49
loc_20:
		mov	byte ptr ds:crab_frame_idx,5
		jmp	loc_49

crab_main	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		cmp	byte ptr ds:fight_hp,10h
		stc				; Set carry flag
		jnz	loc_21			; Jump if not zero
		retn
loc_21:
		dec	byte ptr ds:fight_hp
		clc				; Clear carry flag
		retn
sub_1		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_2		proc	near
		cmp	byte ptr ds:fight_hp,31h	; '1'
		stc				; Set carry flag
		jnz	loc_22			; Jump if not zero
		retn
loc_22:
		inc	byte ptr ds:fight_hp
		clc				; Clear carry flag
		retn
sub_2		endp

loc_23:
		mov	byte ptr ds:crab_flag_h,0
		mov	byte ptr ds:crab_flag_g,0FFh
loc_24:
		inc	byte ptr ds:crab_flag_h
		cmp	byte ptr ds:crab_flag_h,8
;*		je	loc_25			;*Jump if equal
		db	 74h, 18h		;  Fixup - byte match
		mov	bl,ds:crab_flag_h
		xor	bh,bh			; Zero register
		mov	al,ds:crab_spawn_limit[bx]
		mov	ds:crab_frame_idx,al
		jmp	loc_49
			                        ;* No entry point to code
		pop	es
		pop	es
		or	[bx+si],cl
		or	[bx+si],cl
		or	ds:sprite_src_aux,al
		add	[di],al
		or	al,0
		mov	bx,ds:fight_state_max
		mov	cx,ax
		sub	cx,bx
		xchg	bx,ax
		jc	loc_26			; Jump if carry Set
		xchg	bx,cx
loc_26:
		mov	ax,ds:fight_hp
		add	ax,5
		sub	ax,bx
		sbb	dl,dl
		mov	ds:crab_dir_flag,dl
		mov	byte ptr ds:crab_flag_g,0
		mov	byte ptr ds:crab_anim_frame,0
		mov	byte ptr ds:crab_anim_idx,0FFh
loc_27:
		mov	byte ptr ds:crab_frame_idx,9
		mov	bl,ds:crab_anim_frame
		xor	bh,bh			; Zero register
		mov	al,ds:crab_anim_tbl_c[bx]
		cmp	al,0FFh
		jne	loc_28			; Jump if not equal
;*		jmp	loc_42			;*
		db	0E9h,0F1h, 00h		;  Fixup - byte match
loc_28:
		mov	ah,al
		and	al,0Fh
		cmp	al,8
		je	loc_29			; Jump if equal
		shr	al,1			; Shift w/zeros fill
		sbb	al,0
		add	al,ds:crab_phase_base
		and	al,3Fh			; '?'
		mov	ds:crab_phase_base,al
loc_29:
		mov	al,ah
		and	al,0F0h
		jz	loc_31			; Jump if zero
		test	byte ptr ds:crab_dir_flag,0FFh
		jnz	loc_30			; Jump if not zero
		call	sub_1
		jmp	short loc_31
loc_30:
		call	sub_2
loc_31:
		call	sub_3
		inc	byte ptr ds:crab_anim_frame
		retn
loc_32:
		test	byte ptr ds:crab_row_pos,0FFh
		jnz	loc_37			; Jump if not zero
		test	byte ptr ds:crab_anim_idx,0FFh
		jnz	loc_33			; Jump if not zero
		retn
loc_33:
		mov	di,ds:fight_slot_list
loc_34:
		cmp	byte ptr [di+4],14h
		je	loc_35			; Jump if equal
		add	di,10h
		jmp	short loc_34
loc_35:
		mov	al,ds:crab_anim_frame
		mov	[di+6],al
		cmp	byte ptr ds:crab_anim_frame,4
		je	loc_36			; Jump if equal
		retn
loc_36:
		mov	byte ptr ds:crab_col_pos,0
		mov	byte ptr ds:crab_row_pos,0FFh
		mov	ax,ds:fight_hp
		add	ax,4
		mov	ds:crab_anim_base,ax
		mov	al,ds:crab_phase_base
		add	al,3
		and	al,3Fh			; '?'
		mov	ds:crab_timer_a,al
loc_37:
		mov	bl,ds:crab_col_pos
		xor	bh,bh			; Zero register
		inc	byte ptr ds:crab_col_pos
		mov	al,ds:crab_anim_tbl_a[bx]
		cmp	al,0FFh
		jne	loc_38			; Jump if not equal
		mov	byte ptr ds:crab_row_pos,0
		retn
loc_38:
		or	al,al			; Zero ?
		jns	loc_40			; Jump if not sign
		inc	byte ptr ds:crab_timer_a
		and	byte ptr ds:crab_timer_a,3Fh	; '?'
loc_40:
		push	ax
		mov	ax,ds:crab_anim_base
		push	ax
		call	word ptr cs:fight_cb_anim_step
		pop	ax
		pop	cx
		jnc	loc_41			; Jump if carry=0
		retn
loc_41:
		mov	[si],ax
		mov	dl,ds:crab_timer_a
		mov	[si+2],dl
		mov	[si+3],bl
		mov	byte ptr [si+4],35h	; '5'
		and	cl,7Fh
		mov	[si+6],cl
		mov	byte ptr [si+5],0
		mov	word ptr [si+10h],0FFFFh
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	bl,ds:crab_slot_idx
		mov	al,bl
		or	al,80h
		xchg	[di],al
		xor	bh,bh			; Zero register
		mov	ds:sprite_idx_table[bx],al
		retn
			                        ;* No entry point to code
		add	byte ptr ds:sprite_src_alt[bx+si],80h
		add	word ptr ss:[403h][bp+si],0F6FFh
		push	ss
;*		loopnz	locloop_39		;*Loop if zf=0, cx>0

		db	0E0h,0A7h		;  Fixup - byte match
		mov	byte ptr ds:crab_anim_idx,0
		mov	byte ptr ds:crab_idx_e,0
		mov	byte ptr ds:[0A7E4h],0FFh
loc_43:
		mov	bl,ds:crab_idx_e
		xor	bh,bh			; Zero register
		mov	al,ds:crab_anim_tbl_b[bx]
		mov	ds:crab_frame_idx,al
		inc	byte ptr ds:crab_idx_e
		cmp	byte ptr ds:crab_idx_e,4
		je	$+5			; Jump if equal
		jmp	loc_49
			                        ;* No entry point to code
		mov	byte ptr ds:[0A7E4h],0
		jmp	short loc_49
			                        ;* No entry point to code
		pop	es
		or	[bx+si],cl
;*		add	cl,dh
		db	 00h,0F1h		;  Fixup - byte match
		db	0F1h,0F1h,0F1h,0F1h,0F8h,0F8h
		db	0F8h,0F2h,0F2h,0F2h,0F2h,0F2h
		db	0FFh
loc_44:
		mov	al,ds:crab_timer_b
		cmp	al,28h			; '('
		jae	loc_48			; Jump if above or =
		cmp	al,1Eh
		jae	loc_45			; Jump if above or =
		and	al,1
		jnz	loc_45			; Jump if not zero
		mov	byte ptr ds:gvar_spawn_fx_flag,23h	; '#'
loc_45:
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		cmp	byte ptr ds:crab_timer_b,14h
		jae	loc_47			; Jump if above or =
		inc	byte ptr ds:crab_timer_b
		test	byte ptr ds:crab_dir_flag,0FFh
		jnz	loc_46			; Jump if not zero
		inc	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,6
		jb	loc_49			; Jump if below
		mov	byte ptr ds:crab_frame_idx,5
		mov	byte ptr ds:crab_dir_flag,0FFh
		jmp	short loc_49
loc_46:
		dec	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,0FFh
		jb	loc_49			; Jump if below
		mov	byte ptr ds:crab_frame_idx,0
		mov	byte ptr ds:crab_dir_flag,0
		jmp	short loc_49
loc_47:
		inc	byte ptr ds:crab_timer_b
		mov	byte ptr ds:crab_frame_idx,8
		jmp	short loc_49
loc_48:
		mov	byte ptr ds:gvar_completion,0FFh
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_3		proc	near
loc_49:
		mov	bl,ds:crab_frame_idx
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	di,ds:crab_pos_tbl[bx]
		mov	al,ds:crab_phase_base
		mov	ds:crab_flag_d,al
		mov	si,ds:fight_slot_list
		xor	al,al			; Zero register
		mov	ds:crab_slot_idx,al
loc_50:
		push	di
		push	ax
		mov	bl,0Ah
		mul	bl			; ax = reg * al
		add	di,ax
		mov	ax,ds:fight_hp
		mov	cx,0Ah

locloop_51:
		push	cx
		mov	[si],ax
		push	di
		push	ax
		call	word ptr cs:fight_cb_anim_step
		jc	loc_53			; Jump if carry Set
		mov	al,[di]
		cmp	al,0FFh
		je	loc_53			; Jump if equal
		mov	[si+4],al
		mov	al,ds:crab_flag_d
		mov	[si+2],al
		mov	[si+3],bl
		mov	byte ptr [si+5],0
		test	byte ptr ds:crab_state_bits,0FFh
		jz	loc_52			; Jump if zero
		or	byte ptr [si+5],20h	; ' '
loc_52:
		mov	al,ds:crab_frame_idx
		mov	[si+6],al
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	al,ds:crab_slot_idx
		mov	bl,al
		or	al,80h
		xchg	[di],al
		xor	bh,bh			; Zero register
		mov	ds:sprite_idx_table[bx],al
		inc	byte ptr ds:crab_slot_idx
		add	si,10h
loc_53:
		pop	ax
		inc	ax
		pop	di
		inc	di
		pop	cx
		loop	locloop_51		; Loop if cx > 0

		inc	byte ptr ds:crab_flag_d
		and	byte ptr ds:crab_flag_d,3Fh	; '?'
		pop	ax
		pop	di
		inc	al
		cmp	al,6
		jne	loc_50			; Jump if not equal
		mov	word ptr [si],0FFFFh
		jmp	loc_32
sub_3		endp

		db	 1Eh,0A7h, 1Eh,0A7h, 1Eh,0A7h
		db	 1Eh,0A7h, 1Eh,0A7h, 1Eh,0A7h
		db	 1Eh,0A7h, 1Eh,0A7h, 1Eh,0A7h
		db	 5Ah,0A7h,0FFh,0FFh,0FFh, 00h
		db	0FFh, 01h
		db	14 dup (0FFh)
		db	 02h,0FFh, 03h,0FFh, 04h,0FFh
		db	 05h,0FFh, 06h
		db	11 dup (0FFh)
		db	 07h,0FFh, 10h,0FFh, 11h,0FFh
		db	 12h,0FFh
		db	8
		db	15 dup (0FFh)
		db	 00h,0FFh,0FFh,0FFh,0FFh,0FFh
		db	0FFh,0FFh, 03h,0FFh,0FFh,0FFh
		db	 05h,0FFh,0FFh,0FFh, 02h,0FFh
		db	0FFh,0FFh, 14h,0FFh,0FFh,0FFh
		db	 06h,0FFh,0FFh,0FFh, 90h,0FFh
		db	0FFh,0FFh, 12h,0FFh,0FFh,0FFh
		db	0FFh, 07h,0FFh,0FFh,0FFh,0FFh
		db	0FFh
		db	8
		db	12 dup (0FFh)

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_4		proc	near
		mov	ax,ds:crab_phase_limit
		sub	ax,bx
		jnc	loc_54			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_54:
		mov	ds:crab_phase_limit,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:fight_cb_prep
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_55			; Jump if zero
		retn
loc_55:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	loc_56			; Jump if zero
		retn
loc_56:
		mov	byte ptr ds:crab_timer_b,0
		mov	byte ptr ds:gvar_death_flag,0FFh
		retn
sub_4		endp

		db	 2Bh, 00h, 0Ch, 96h, 00h, 78h
		db	 00h, 0Ch, 00h,0D0h,0A7h, 96h
		db	 00h, 10h,0BBh, 00h
		db	8, 'Cangrejo'
		db	18 dup (0)

seg_a		ends



		end	start
