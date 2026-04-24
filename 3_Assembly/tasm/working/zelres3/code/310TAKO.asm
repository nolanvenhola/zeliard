
PAGE  59,132

;==========================================================================
;
;  310TAKO.BIN - Tako / Octopus Enemy Code Module (zelres3 chunk 11, 'Pulpo')
;
;  Tako (octopus) enemy sprite/logic module loaded by 200FIGHT.asm
;  alongside EAI2/EAI3 behavior handlers.  The Japanese name "tako" means
;  octopus; the Spanish marker 'Pulpo' ('octopus') appears as a text tag
;  in the module's trailing data.
;
;  Primary entry: tako_scan_and_update -- iterates the enemy slot list
;  (SI = fight_slot_list), drives octopus-specific frame/tentacle
;  animations via the fight callbacks, handles multi-arm sprite columns,
;  and respawns tentacle projectiles on timed phases.
;
;  Large data blocks near the top are tentacle animation frame tables
;  (cycle indices and 5-byte per-row entries).  Footer carries 'Pulpo'.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; Fight-engine callback vectors / shared globals (DS, game_seg).

fight_cb_prep		equ	200Ch			; prep/init callback
fight_cb_record_ofs	equ	6028h			; compute record addr from tile
fight_cb_anim_step	equ	6036h			; animation advance callback
fight_cb_hit_check	equ	6038h			; per-slot hit/collision query

; Shared sprite pattern tables used by Tako.

sprite_pat_tbl_a	equ	0A57Dh			; sprite pattern table A
sprite_pat_tbl_b	equ	0A64Dh			; sprite pattern table B
dir_xlat_table		equ	0A725h			; direction lookup table (xlat base)
tako_vector_tbl		equ	0A9AFh			; tako render-vector table

; Tako-specific global state (DS).
; NOTE: Sourcer emitted duplicate EQUs for the same address (e.g. AA80h
; appears twice); both point to the same byte so they are aliases.

tako_row_pos_base	equ	0AA80h			; current row position (word base)
tako_row_delta		equ	0AA82h			; row delta byte
tako_hp			equ	0AA83h			; Tako HP counter
tako_phase_a		equ	0AA96h			; phase counter A
tako_flag_a		equ	0AA97h			; flag byte A (direction)
tako_flag_b		equ	0AA98h			; flag byte B (state)
tako_flag_c		equ	0AA99h			; flag byte C (animation)
tako_frame_idx		equ	0AA9Ah			; frame index
tako_state		equ	0AA9Bh			; state byte
tako_alt_state		equ	0AA9Ch			; alternate state byte
tako_timer_a		equ	0AA9Eh			; timer A (word)
tako_timer_a_byte	equ	0AA9Fh			; timer A byte
tako_col_pos		equ	0AAA1h			; col position byte
fight_slot_list		equ	0C010h			; base of enemy slot list
sprite_idx_table	equ	0ED20h			; sprite index mapping table
gvar_death_flag		equ	0FF2Eh			; tako death flag global
gvar_dir_toggle		equ	0FF2Fh			; dir-toggle flag global
gvar_completion		equ	0FF30h			; completion/stage flag global
gvar_spawn_fx_flag	equ	0FF75h			; flag byte for spawn VFX
sprite_src_base		equ	0E3A5h			; tako sprite-source base

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

tako_main	proc	far

start:
		mov	byte ptr ds:[0Ah],al
		add	[di-5Eh],bh
;*		sub	byte ptr ss:[0][bp+si],0
		db	 80h,0AAh, 00h, 00h, 00h	;  Fixup - byte match
		db	9 dup (0)
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, '(', 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 0Ah, 'R'
		db	0A0h,0A2h,0A0h,0F2h,0A0h, 42h
		db	0A1h, 92h,0A1h,0E2h,0A1h
		db	16 dup (0)
		db	 55h,0A2h, 05h,0A2h, 5Fh,0A2h
		db	 00h, 00h, 00h, 01h, 00h, 00h
		db	 02h, 03h, 04h, 05h, 00h, 00h
		db	 00h, 06h, 07h, 00h, 00h, 00h
		db	 08h, 09h, 00h, 0Ah, 0Bh, 0Ch
		db	 0Dh, 00h, 0Eh, 0Fh, 10h, 11h
		db	 00h, 00h, 00h, 00h, 16h, 00h
		db	 17h, 18h, 19h, 1Ah, 00h, 1Bh
		db	 1Ch, 1Dh, 1Eh, 00h, 00h, 00h
		db	 1Fh, 20h, 00h, 00h, 00h, 21h
		db	 22h, 00h, 23h, 24h, 25h, 26h
		db	 00h, 27h, 28h, 29h, 2Ah, 00h
		db	 00h, 00h, 2Bh, 2Ch, 00h, 2Dh
		db	 2Eh, 2Fh, 30h, 00h, 31h, 32h
		db	 33h, 34h, 00h, 00h, 00h, 00h
		db	 35h, 00h, 36h, 37h, 38h, 39h
		db	 00h, 3Ah, 3Bh, 3Ch, 3Dh, 00h
		db	 00h, 00h, 00h, 3Eh, 00h, 3Fh
		db	 40h, 41h, 42h, 00h, 43h, 44h
		db	 45h, 1Ah, 00h, 00h, 00h, 46h
		db	 47h, 00h, 48h, 24h, 25h, 26h
		db	 00h, 00h, 00h, 49h, 4Ah, 00h
		db	 4Bh, 4Ch, 4Dh, 4Eh, 00h, 00h
		db	 00h, 4Fh, 4Ah, 00h, 50h, 4Ch
		db	 4Dh, 4Eh, 00h, 00h, 00h, 21h
		db	 51h, 00h, 23h, 52h, 25h, 26h
		db	 00h, 53h, 00h, 54h, 55h, 00h
		db	 00h, 56h, 57h, 58h, 00h, 00h
		db	 00h, 03h, 00h, 00h, 59h, 5Ah
		db	 5Bh, 5Ch, 00h, 0Eh, 5Dh, 5Eh
		db	 5Fh, 00h, 00h, 00h, 63h, 00h
		db	 00h, 64h, 65h, 66h, 67h, 00h
		db	 68h, 69h, 6Ah, 6Bh, 00h, 0Eh
		db	 6Ch, 6Dh, 5Fh, 00h, 71h, 44h
		db	 45h, 1Ah, 00h, 00h, 00h, 72h
		db	 73h, 00h, 74h, 00h, 75h, 76h
		db	 00h, 00h, 00h, 77h, 78h, 00h
		db	 79h, 7Ah, 7Bh, 7Ch, 00h, 7Fh
		db	 18h, 19h, 1Ah, 00h, 80h, 00h
		db	 81h, 82h, 00h, 00h, 00h, 00h
		db	 83h, 00h, 00h, 00h, 77h, 78h
		db	 00h, 84h, 85h, 86h, 87h, 00h
		db	 00h, 00h, 00h, 17h, 00h, 8Ah
		db	 8Bh, 8Ch, 8Dh, 00h, 00h, 00h
		db	 8Eh, 8Fh, 00h, 90h, 91h, 92h
		db	 93h, 00h, 00h, 95h, 96h, 97h
		db	 00h, 66h, 00h, 98h, 99h, 00h
		db	 9Ah, 00h, 9Bh, 9Ch, 00h, 00h
		db	 9Dh, 9Eh, 9Fh, 00h,0A2h,0A3h
		db	 00h,0A4h, 00h, 00h, 00h,0A5h
		db	0A6h, 00h,0C5h,0CCh,0C6h, 15h
		db	 00h, 0Ah,0A9h,0AAh, 0Dh, 00h
		db	 0Ah,0ACh,0ADh,0AEh, 00h, 0Eh
		db	 0Fh,0AFh, 11h, 00h, 00h, 56h
		db	 00h, 00h, 00h, 59h,0B1h, 00h
		db	0B2h, 00h, 0Eh, 5Dh,0B3h, 5Fh
		db	 00h,0B5h,0B6h, 00h, 67h, 00h
		db	0B7h,0B8h, 6Ah, 6Bh, 00h, 00h
		db	 00h, 75h, 76h, 00h, 00h,0BAh
		db	 7Bh, 7Ch, 00h,0BCh,0BDh, 86h
		db	 87h, 00h,0CEh,0CFh, 8Ch, 00h
		db	 00h, 90h,0BFh, 00h,0C0h, 00h
		db	 00h, 9Dh, 00h,0C2h, 00h, 0Ah
		db	0ACh,0ADh,0AEh, 00h, 0Eh, 5Dh
		db	0C4h, 5Fh, 00h, 0Eh, 0Fh,0C4h
		db	 11h, 00h, 0Eh, 6Ch,0C4h, 5Fh
		db	 00h, 0Eh, 0Fh,0C4h,0C7h, 00h
		db	 17h, 18h,0C8h,0C9h, 00h,0CAh
		db	0CBh, 1Dh, 1Eh, 00h, 0Eh, 5Dh
		db	0C4h,0CDh, 00h, 43h, 44h,0C8h
		db	0C9h, 00h, 0Eh, 6Ch,0C4h,0CDh
		db	 00h, 71h, 44h,0C8h,0C9h, 00h
		db	 7Fh, 18h,0C8h,0C9h, 00h, 00h
		db	 00h, 08h,0A8h, 00h, 12h, 13h
		db	 14h, 15h, 00h, 60h, 61h, 62h
		db	 15h, 00h, 6Eh, 6Fh, 70h, 15h
		db	 00h, 7Dh, 6Fh, 7Eh, 15h, 00h
		db	 88h, 6Fh, 89h, 15h, 00h, 94h
		db	 6Fh, 89h, 15h, 00h,0A0h, 6Fh
		db	0A1h, 15h, 00h,0ABh, 6Fh, 14h
		db	 15h, 00h,0B0h, 13h, 14h, 15h
		db	 00h,0B4h, 61h, 62h, 15h, 00h
		db	0B9h, 6Fh, 70h, 15h, 00h,0BBh
		db	 6Fh, 7Eh, 15h, 00h,0BEh, 6Fh
		db	 89h, 15h, 00h,0C1h, 6Fh, 89h
		db	 15h, 00h,0C3h, 6Fh, 89h, 15h
		db	 00h,0C5h, 6Fh, 14h, 15h, 00h
		db	0C5h, 13h,0C6h, 15h, 00h, 00h
		db	 00h,0A7h,0A8h, 02h, 00h,0D0h
		db	 00h,0D1h, 02h,0D2h,0D3h,0D4h
		db	0D5h, 02h, 00h, 00h,0D6h,0D7h
		db	 02h,0D8h,0D9h,0DAh,0DBh, 02h
		db	0DCh,0DDh,0DEh,0DFh, 02h,0E0h
		db	0E1h,0E2h,0E3h, 8Bh, 36h, 10h
		db	0C0h,0C6h, 06h, 9Ah,0AAh, 00h
		db	0C6h, 06h, 9Bh,0AAh, 00h
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
		mov	bl,ds:tako_frame_idx
		xor	bh,bh			; Zero register
		mov	al,ds:sprite_idx_table[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	loc_3			; Jump if zero
		test	byte ptr ds:tako_state,80h
		jnz	loc_3			; Jump if not zero
		mov	al,[si+5]
		and	al,1Fh
		cmp	byte ptr [si+4],0Eh
		jb	loc_2			; Jump if below
		or	al,80h
loc_2:
		mov	ds:tako_state,al
loc_3:
		inc	byte ptr ds:tako_frame_idx
		add	si,10h
		jmp	short loc_1
loc_4:
		mov	si,ds:fight_slot_list
		mov	word ptr [si],0FFFFh
		mov	al,ds:tako_state
		or	al,al			; Zero ?
		jz	loc_7			; Jump if zero
		push	ax
		and	al,1Fh
		call	word ptr cs:fight_cb_hit_check
		mov	bl,ah
		xor	bh,bh			; Zero register
		add	bx,bx
		pop	ax
		or	al,al			; Zero ?
		jns	loc_5			; Jump if not sign
		mov	byte ptr ds:gvar_spawn_fx_flag,24h	; '$'
		add	bx,bx
		jmp	short loc_6
loc_5:
		mov	byte ptr ds:gvar_spawn_fx_flag,25h	; '%'
loc_6:
		call	sub_1
		test	byte ptr ds:tako_flag_b,10h
		jnz	loc_7			; Jump if not zero
		mov	bx,tako_flag_a
		cmp	byte ptr [bx],10h
		je	loc_7			; Jump if equal
		add	byte ptr [bx],8
		mov	byte ptr ds:tako_flag_b,10h
		or	byte ptr ds:tako_flag_c,20h	; ' '
		mov	byte ptr ds:gvar_spawn_fx_flag,26h	; '&'
loc_7:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	loc_8			; Jump if zero
		jmp	loc_32
loc_8:
		inc	byte ptr ds:tako_phase_a
		and	byte ptr ds:tako_phase_a,7
		mov	dl,ds:tako_flag_a
		mov	bx,tako_flag_b
		test	byte ptr [bx],10h
		jz	loc_10			; Jump if zero
		xor	byte ptr [bx],20h	; ' '
		test	byte ptr [bx],20h	; ' '
		jnz	loc_9			; Jump if not zero
		sub	dl,8
loc_9:
		mov	al,[bx]
		mov	ah,al
		and	al,0F0h
		inc	ah
		and	ah,0Fh
		or	al,ah
		mov	[bx],al
		or	ah,ah			; Zero ?
		jnz	loc_10			; Jump if not zero
		and	byte ptr [bx],0EFh
		and	byte ptr ds:tako_flag_c,0DFh
loc_10:
		cmp	dl,10h
		jne	loc_14			; Jump if not equal
		mov	bx,tako_flag_c
		test	byte ptr [bx],40h	; '@'
		jz	loc_11			; Jump if zero
		mov	al,20h			; ' '
		xor	al,[bx]
		mov	ah,al
		inc	al
		and	al,3
		and	ah,0E0h
		or	ah,al
		mov	[bx],ah
		or	al,al			; Zero ?
		jnz	loc_12			; Jump if not zero
		mov	byte ptr [bx],0A0h
		mov	ax,ds:tako_row_pos_base
		add	ax,4
		mov	ds:tako_timer_a_byte,ax
		mov	al,ds:tako_row_delta
		add	al,4
		and	al,3Fh			; '?'
		mov	ds:tako_col_pos,al
		mov	byte ptr ds:gvar_spawn_fx_flag,27h	; '''
loc_11:
		test	byte ptr [bx],0A0h
		jnz	loc_12			; Jump if not zero
		test	byte ptr ds:tako_flag_b,10h
		jnz	loc_12			; Jump if not zero
		or	byte ptr [bx],40h	; '@'
loc_12:
		test	byte ptr [bx],20h	; ' '
		jnz	loc_13			; Jump if not zero
		add	dl,8
loc_13:
		test	byte ptr [bx],80h
		jz	loc_14			; Jump if zero
		mov	al,[bx]
		mov	ah,al
		inc	ah
		and	ah,1Fh
		and	al,0E0h
		or	al,ah
		mov	[bx],al
		dec	word ptr ds:tako_timer_a_byte
		cmp	ah,19h
		jne	loc_14			; Jump if not equal
		mov	byte ptr [bx],0
loc_14:
		mov	byte ptr ds:tako_frame_idx,0
		mov	bl,ds:tako_phase_a
		xor	bh,bh			; Zero register
		add	bl,dl
		add	bl,bl
		mov	di,ds:sprite_pat_tbl_a[bx]
		mov	bx,ds:tako_vector_tbl[bx]
		mov	ax,ds:tako_row_pos_base
		mov	si,ds:fight_slot_list
		mov	cx,7
loc_15:
		push	cx
		push	bx
		push	ax
		call	word ptr cs:fight_cb_anim_step
		mov	ds:tako_alt_state,bl
		pop	ax
		pop	bx
		jnc	loc_18			; Jump if carry=0
		mov	cx,8

locloop_16:
		rol	byte ptr [bx],1		; Rotate
		jnc	loc_17			; Jump if carry=0
		inc	di
		inc	di
loc_17:
		loop	locloop_16		; Loop if cx > 0

		jmp	short loc_22
loc_18:
		xor	cx,cx			; Zero register
loc_19:
		push	cx
		push	bx
		rol	byte ptr [bx],1		; Rotate
		jnc	loc_21			; Jump if carry=0
		mov	[si],ax
		add	cl,cl
		add	cl,ds:tako_row_delta
		and	cl,3Fh			; '?'
		mov	[si+2],cl
		mov	cl,ds:tako_alt_state
		mov	[si+3],cl
		mov	cl,[di]
		mov	[si+4],cl
		mov	cl,[di+1]
		mov	[si+6],cl
		mov	byte ptr [si+5],0
		test	byte ptr ds:tako_state,0FFh
		jz	loc_20			; Jump if zero
		or	byte ptr [si+5],20h	; ' '
loc_20:
		push	di
		push	ax
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	bl,ds:tako_frame_idx
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:sprite_idx_table[bx],al
		pop	ax
		pop	di
		add	si,10h
		add	di,2
		inc	byte ptr ds:tako_frame_idx
loc_21:
		pop	bx
		pop	cx
		inc	cx
		cmp	cx,8
		jne	loc_19			; Jump if not equal
loc_22:
		inc	bx
		add	ax,2
		pop	cx
		loop	locloop_23		; Loop if cx > 0

		jmp	short loc_24

locloop_23:
		jmp	loc_15
loc_24:
		mov	al,ds:tako_flag_c
		test	al,80h
		jz	loc_27			; Jump if zero
		and	al,1Fh
		dec	al
		add	al,al
		add	al,al
		xor	ah,ah			; Zero register
		add	ax,0AA20h
		mov	di,ax
		mov	ax,ds:tako_timer_a_byte
		mov	cx,4

locloop_25:
		push	cx
		push	ax
		call	word ptr cs:fight_cb_anim_step
		pop	ax
		jc	loc_26			; Jump if carry Set
		mov	dl,[di]
		or	dl,dl			; Zero ?
		jz	loc_26			; Jump if zero
		push	di
		push	ax
		mov	[si],ax
		mov	al,ds:tako_col_pos
		mov	[si+2],al
		mov	[si+3],bl
		mov	byte ptr [si+4],30h	; '0'
		dec	dl
		mov	[si+6],dl
		mov	byte ptr [si+5],0
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	bl,ds:tako_frame_idx
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:sprite_idx_table[bx],al
		add	si,10h
		inc	byte ptr ds:tako_frame_idx
		pop	ax
		pop	di
loc_26:
		inc	di
		inc	ax
		pop	cx
		loop	locloop_25		; Loop if cx > 0

loc_27:
		mov	word ptr [si],0FFFFh
		retn

tako_main	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		mov	ax,ds:tako_hp
		sub	ax,bx
		jnc	loc_28			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_28:
		mov	ds:tako_hp,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:fight_cb_prep
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_29			; Jump if zero
		retn
loc_29:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	loc_30			; Jump if zero
		retn
loc_30:
		mov	byte ptr ds:tako_timer_a,0
		mov	byte ptr ds:gvar_death_flag,0FFh

loc_ret_31:
		retn
sub_1		endp

loc_32:
		mov	byte ptr ds:tako_flag_c,0
		cmp	byte ptr ds:tako_timer_a,28h	; '('
		jae	loc_34			; Jump if above or =
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		mov	bx,tako_timer_a
		cmp	byte ptr [bx],14h
		jae	loc_33			; Jump if above or =
		inc	byte ptr [bx]
		mov	al,[bx]
		mov	bx,tako_phase_a
		inc	byte ptr [bx]
		and	byte ptr [bx],7
		and	al,1
		add	al,al
		add	al,al
		add	al,al
		add	al,ds:tako_flag_a
		mov	dl,al
		mov	byte ptr ds:gvar_spawn_fx_flag,28h	; '('
		jmp	loc_14
loc_33:
		inc	byte ptr [bx]
		mov	dl,ds:tako_flag_a
		add	dl,8
		jmp	loc_14
loc_34:
		mov	byte ptr ds:gvar_completion,0FFh
		retn
			                        ;* No entry point to code
		mov	bp,sprite_src_base
		movsw				; Mov [si] to es:[di]
		pop	es
		cmpsb				; Cmp [si] to es:[di]
		sub	ss:sprite_pat_tbl_b[bp],sp
		jno	loc_ret_31		; Jump if not overflw
		xchg	bp,ax
		cmpsb				; Cmp [si] to es:[di]
		mov	cx,0DDA6h
		cmpsb				; Cmp [si] to es:[di]
		add	ds:dir_xlat_table[bx],sp
		inc	di
		cmpsw				; Cmp [si] to es:[di]
		db	 67h,0A7h, 87h,0A7h,0ABh,0A7h
		db	0CDh,0A7h,0EFh,0A7h, 0Bh,0A8h
		db	 27h,0A8h, 43h,0A8h, 5Fh,0A8h
		db	 7Bh,0A8h, 97h,0A8h,0B3h,0A8h
		db	0CFh,0A8h,0EBh,0A8h, 07h,0A9h
		db	 23h,0A9h, 3Fh,0A9h, 5Bh,0A9h
		db	 77h,0A9h, 93h,0A9h, 00h, 00h
		db	 00h, 01h, 00h, 02h, 00h, 03h
		db	 00h, 04h, 00h, 05h, 0Fh, 00h
		db	 00h, 06h, 00h, 07h, 00h, 08h
		db	 00h, 0Ah, 00h, 0Bh, 00h, 0Ch
		db	 00h, 0Dh, 00h, 0Eh, 00h, 0Fh
		db	 01h, 00h, 01h, 01h, 01h, 02h
		db	 01h, 0Eh, 01h, 0Fh, 02h, 00h
		db	 02h, 01h, 02h, 02h, 0Fh, 01h
		db	 00h, 06h, 01h, 05h, 00h, 08h
		db	 01h, 06h, 01h, 07h, 00h, 0Ch
		db	 01h, 08h, 01h, 09h, 00h, 0Fh
		db	 01h, 03h, 01h, 01h, 01h, 02h
		db	 02h, 03h, 02h, 04h, 02h, 05h
		db	 02h, 06h, 0Fh, 02h, 00h, 09h
		db	 02h, 07h, 00h, 08h, 01h, 06h
		db	 01h, 07h, 00h, 0Ch, 00h, 0Dh
		db	 00h, 0Eh, 00h, 0Fh, 01h, 03h
		db	 01h, 04h, 01h, 02h, 02h, 08h
		db	 02h, 09h, 02h, 0Ah, 02h, 0Bh
		db	 02h, 06h, 0Fh, 03h, 00h, 09h
		db	 02h, 0Ch, 00h, 08h, 00h, 0Ah
		db	 00h, 0Bh, 00h, 0Ch, 01h, 08h
		db	 01h, 09h, 00h, 0Fh, 01h, 00h
		db	 01h, 04h, 01h, 02h, 02h, 0Dh
		db	 02h, 0Eh, 02h, 0Fh, 03h, 00h
		db	 02h, 06h, 0Fh, 04h, 00h, 06h
		db	 02h, 0Ch, 00h, 08h, 01h, 0Ch
		db	 01h, 0Dh, 00h, 0Ch, 01h, 0Ah
		db	 01h, 0Bh, 00h, 0Fh, 01h, 00h
		db	 01h, 01h, 01h, 02h, 03h, 01h
		db	 03h, 02h, 03h, 03h, 03h, 04h
		db	 02h, 06h, 0Fh, 05h, 00h, 06h
		db	 02h, 07h, 00h, 08h, 01h, 06h
		db	 01h, 07h, 00h, 0Ch, 01h, 08h
		db	 01h, 09h, 00h, 0Fh, 01h, 03h
		db	 01h, 01h, 01h, 02h, 03h, 05h
		db	 03h, 06h, 03h, 07h, 03h, 08h
		db	 02h, 06h, 0Fh, 06h, 00h, 09h
		db	 02h, 07h, 00h, 08h, 01h, 06h
		db	 01h, 07h, 00h, 0Ch, 00h, 0Dh
		db	 00h, 0Eh, 00h, 0Fh, 01h, 03h
		db	 01h, 04h, 01h, 02h, 03h, 09h
		db	 03h, 0Ah, 0Eh, 01h, 03h, 0Ch
		db	 02h, 02h, 0Fh, 07h, 00h, 09h
		db	 00h, 07h, 00h, 08h, 00h, 0Ah
		db	 00h, 0Bh, 00h, 0Ch, 01h, 08h
		db	 01h, 09h, 00h, 0Fh, 01h, 00h
		db	 01h, 04h, 01h, 02h, 00h, 00h
		db	 00h, 01h, 05h, 06h, 03h, 0Dh
		db	 03h, 0Eh, 0Fh, 08h, 00h, 06h
		db	 00h, 07h, 00h, 08h, 00h, 0Ah
		db	 00h, 0Bh, 00h, 0Ch, 00h, 0Dh
		db	 00h, 0Eh, 00h, 0Fh, 01h, 00h
		db	 01h, 01h, 01h, 02h, 01h, 0Eh
		db	 03h, 0Fh, 02h, 00h, 04h, 00h
		db	 04h, 01h, 0Fh, 09h, 00h, 06h
		db	 01h, 05h, 00h, 08h, 01h, 06h
		db	 01h, 07h, 00h, 0Ch, 01h, 08h
		db	 01h, 09h, 00h, 0Fh, 01h, 03h
		db	 01h, 01h, 01h, 02h, 02h, 03h
		db	 04h, 02h, 04h, 03h, 02h, 06h
		db	 0Fh, 0Ah, 00h, 09h, 02h, 07h
		db	 00h, 08h, 01h, 06h, 01h, 07h
		db	 00h, 0Ch, 00h, 0Dh, 00h, 0Eh
		db	 00h, 0Fh, 01h, 03h, 01h, 04h
		db	 01h, 02h, 04h, 04h, 04h, 05h
		db	 02h, 06h, 0Fh, 0Bh, 00h, 09h
		db	 02h, 0Ch, 00h, 08h, 00h, 0Ah
		db	 00h, 0Bh, 00h, 0Ch, 01h, 08h
		db	 01h, 09h, 00h, 0Fh, 01h, 00h
		db	 01h, 04h, 01h, 02h, 02h, 0Eh
		db	 04h, 06h, 02h, 06h, 0Fh, 0Ch
		db	 00h, 06h, 02h, 0Ch, 00h, 08h
		db	 01h, 0Ch, 01h, 0Dh, 00h, 0Ch
		db	 01h, 0Ah, 01h, 0Bh, 00h, 0Fh
		db	 01h, 00h, 01h, 01h, 01h, 02h
		db	 03h, 01h, 04h, 07h, 03h, 03h
		db	 04h, 08h, 02h, 06h, 0Fh, 0Dh
		db	 00h, 06h, 02h, 07h, 00h, 08h
		db	 01h, 06h, 01h, 07h, 00h, 0Ch
		db	 01h, 08h, 01h, 09h, 00h, 0Fh
		db	 01h, 03h, 01h, 01h, 01h, 02h
		db	 03h, 05h, 03h, 07h, 04h, 09h
		db	 02h, 06h, 0Fh, 0Eh, 00h, 09h
		db	 02h, 07h, 00h, 08h, 01h, 06h
		db	 01h, 07h, 00h, 0Ch, 00h, 0Dh
		db	 00h, 0Eh, 00h, 0Fh, 01h, 03h
		db	 01h, 04h, 01h, 02h, 03h, 09h
		db	 0Eh, 01h, 04h, 0Ah, 04h, 0Bh
		db	 0Fh, 0Fh, 00h, 09h, 00h, 07h
		db	 00h, 08h, 00h, 0Ah, 00h, 0Bh
		db	 00h, 0Ch, 01h, 08h, 01h, 09h
		db	 00h, 0Fh, 01h, 00h, 01h, 04h
		db	 01h, 02h, 04h, 0Ch, 0Eh, 00h
		db	 00h, 06h, 00h, 07h, 00h, 08h
		db	 00h, 0Ah, 00h, 0Bh, 00h, 0Ch
		db	 00h, 0Dh, 00h, 0Eh, 00h, 0Fh
		db	 01h, 00h, 01h, 01h, 01h, 02h
		db	 04h, 0Bh, 0Eh, 00h, 00h, 06h
		db	 01h, 05h, 00h, 08h, 01h, 06h
		db	 01h, 07h, 00h, 0Ch, 01h, 08h
		db	 01h, 09h, 00h, 0Fh, 01h, 03h
		db	 01h, 01h, 01h, 02h, 04h, 0Dh
		db	 0Eh, 00h, 00h, 09h, 02h, 07h
		db	 00h, 08h, 01h, 06h, 01h, 07h
		db	 00h, 0Ch, 00h, 0Dh, 00h, 0Eh
		db	 00h, 0Fh, 01h, 03h, 01h, 04h
		db	 01h, 02h, 04h, 0Dh, 0Eh, 00h
		db	 00h, 09h, 02h, 0Ch, 00h, 08h
		db	 00h, 0Ah, 00h, 0Bh, 00h, 0Ch
		db	 01h, 08h, 01h, 09h, 00h, 0Fh
		db	 01h, 00h, 01h, 04h, 01h, 02h
		db	 04h, 0Dh, 0Eh, 00h, 00h, 06h
		db	 02h, 0Ch, 00h, 08h, 01h, 0Ch
		db	 01h, 0Dh, 00h, 0Ch, 01h, 0Ah
		db	 01h, 0Bh, 00h, 0Fh, 01h, 00h
		db	 01h, 01h, 01h, 02h, 04h, 0Dh
		db	 0Eh, 00h, 00h, 06h, 02h, 07h
		db	 00h, 08h, 01h, 06h, 01h, 07h
		db	 00h, 0Ch, 01h, 08h, 01h, 09h
		db	 00h, 0Fh, 01h, 03h, 01h, 01h
		db	 01h, 02h, 04h, 0Dh, 0Eh, 00h
		db	 00h, 09h, 02h, 07h, 00h, 08h
		db	 01h, 06h, 01h, 07h, 00h, 0Ch
		db	 00h, 0Dh, 00h, 0Eh, 00h, 0Fh
		db	 01h, 03h, 01h, 04h, 01h, 02h
		db	 04h, 0Bh, 0Eh, 00h, 00h, 09h
		db	 00h, 07h, 00h, 08h, 00h, 0Ah
		db	 00h, 0Bh, 00h, 0Ch, 01h, 08h
		db	 01h, 09h, 00h, 0Fh, 01h, 00h
		db	 01h, 04h, 01h, 02h, 04h, 0Eh
		db	 03h, 0Bh, 00h, 06h, 04h, 0Fh
		db	 05h, 00h, 00h, 0Ah, 00h, 0Bh
		db	 00h, 0Ch, 00h, 0Dh, 00h, 0Eh
		db	 00h, 0Fh, 01h, 00h, 01h, 01h
		db	 01h, 02h, 05h, 01h, 03h, 0Bh
		db	 00h, 06h, 05h, 02h, 05h, 00h
		db	 01h, 06h, 01h, 07h, 00h, 0Ch
		db	 01h, 08h, 01h, 09h, 00h, 0Fh
		db	 01h, 03h, 01h, 01h, 01h, 02h
		db	 05h, 03h, 03h, 0Bh, 00h, 09h
		db	 05h, 04h, 05h, 00h, 01h, 06h
		db	 01h, 07h, 00h, 0Ch, 00h, 0Dh
		db	 00h, 0Eh, 00h, 0Fh, 01h, 03h
		db	 01h, 04h, 01h, 02h, 05h, 03h
		db	 03h, 0Bh, 00h, 09h, 05h, 05h
		db	 05h, 00h, 00h, 0Ah, 00h, 0Bh
		db	 00h, 0Ch, 01h, 08h, 01h, 09h
		db	 00h, 0Fh, 01h, 00h, 01h, 04h
		db	 01h, 02h, 05h, 03h, 03h, 0Bh
		db	 00h, 06h, 05h, 05h, 05h, 00h
		db	 01h, 0Ch, 01h, 0Dh, 00h, 0Ch
		db	 01h, 0Ah, 01h, 0Bh, 00h, 0Fh
		db	 01h, 00h, 01h, 01h, 01h, 02h
		db	 05h, 03h, 03h, 0Bh, 00h, 06h
		db	 05h, 04h, 05h, 00h, 01h, 06h
		db	 01h, 07h, 00h, 0Ch, 01h, 08h
		db	 01h, 09h, 00h, 0Fh, 01h, 03h
		db	 01h, 01h, 01h, 02h, 05h, 03h
		db	 03h, 0Bh, 00h, 09h, 05h, 04h
		db	 05h, 00h, 01h, 06h, 01h, 07h
		db	 00h, 0Ch, 00h, 0Dh, 00h, 0Eh
		db	 00h, 0Fh, 01h, 03h, 01h, 04h
		db	 01h, 02h, 05h, 01h, 03h, 0Bh
		db	 00h, 09h, 04h, 0Fh, 05h, 00h
		db	 00h, 0Ah, 00h, 0Bh, 00h, 0Ch
		db	 01h, 08h, 01h, 09h, 00h, 0Fh
		db	 01h, 00h, 01h, 04h, 01h, 02h
		db	0EFh,0A9h,0F6h,0A9h,0FDh,0A9h
		db	0F6h,0A9h,0F6h,0A9h,0F6h,0A9h
		db	0F6h,0A9h,0F6h,0A9h, 04h,0AAh
		db	0F6h,0A9h,0FDh,0A9h, 0Bh,0AAh
		db	 0Bh,0AAh,0F6h,0A9h, 12h,0AAh
		db	 12h,0AAh, 19h,0AAh, 19h,0AAh
		db	 19h,0AAh, 19h,0AAh, 19h,0AAh
		db	 19h,0AAh, 19h,0AAh, 19h,0AAh
		db	 19h,0AAh, 19h,0AAh, 19h,0AAh
		db	 19h,0AAh, 19h,0AAh, 19h,0AAh
		db	 19h,0AAh, 19h,0AAh,0E0h, 60h
		db	 60h,0E0h,0E0h,0E0h,0E0h, 60h
		db	 60h, 60h,0E0h,0E0h,0E0h,0E0h
		db	 60h, 20h, 60h,0E0h,0E0h,0E0h
		db	0E0h,0C0h, 60h, 60h,0E0h,0E0h
		db	0E0h,0E0h, 20h, 20h, 60h,0E0h
		db	0E0h,0E0h,0E0h, 40h, 60h, 60h
		db	0E0h,0E0h,0E0h,0E0h, 00h, 00h
		db	 60h,0E0h,0E0h,0E0h,0E0h, 00h
		db	 00h, 00h, 00h, 01h, 00h, 00h
		db	 00h, 02h, 00h, 00h, 00h, 02h
		db	 00h, 03h, 00h, 02h, 00h, 03h
		db	 00h, 02h, 00h, 03h, 00h, 02h
		db	 00h, 03h, 00h, 02h, 00h, 03h
		db	 00h, 02h, 00h, 03h, 00h, 02h
		db	 00h, 03h, 00h, 02h, 00h, 03h
		db	 00h, 02h, 00h, 03h, 00h, 02h
		db	 00h, 03h, 00h, 02h, 00h, 03h
		db	 00h, 02h, 00h, 03h, 00h, 02h
		db	 00h, 03h, 00h, 02h, 00h, 03h
		db	 00h, 02h, 00h, 03h, 00h, 02h
		db	 00h, 03h, 00h, 02h, 00h, 03h
		db	 00h, 04h, 00h, 03h, 00h, 00h
		db	 04h, 03h, 00h, 00h, 00h, 05h
		db	 00h, 00h, 00h, 00h, 06h, 24h
		db	 00h, 10h,0FAh, 00h,0C8h, 00h
		db	 07h,0FFh, 8Dh,0AAh,0C8h, 00h
		db	 12h,0BBh, 00h, 05h
		db	 50h, 75h, 6Ch, 70h, 6Fh
		db	12 dup (0)

seg_a		ends



		end	start
