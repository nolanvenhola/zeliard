
PAGE  59,132

;==========================================================================
;
;  303EAI3.BIN - Enemy AI Handler: TORI (zelres3 chunk 4)
;
;  Per-enemy AI controller for the TORI (bird) enemy, loaded alongside
;  311TORI.BIN sprites. Manages flight path, swoop attack, and collision
;  for the flying bird enemy. The TORI uses a more elaborate set of
;  animation substates (0..7) than ground enemies because it transitions
;  between hover / dive / retreat behaviours.
;
;  Dispatch model matches the EAI* family (see 301EAI1.asm for full
;  description of the enemy slot record at DS:SI).
;
;  Resource table constants (DS offsets in game_seg):
;    6004h..603Ah = TORI movement/collision/attack dispatch table slots.
;    0A4EAh..0A662h = TORI flight-pattern / attack-decision lookup tables.
;    0FF35h = shared gvar_frame_cnt.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; --- TORI enemy AI dispatch table (game_seg:6004h..603Ah, in DS at runtime) ---
ai_fn_tbl_a	equ	6004h			; AI fn (dive / swoop)
ai_fn_tbl_b	equ	6008h			; AI fn
ai_fn_tbl_c	equ	600Ah			; AI fn
ai_fn_tbl_d	equ	600Ch			; AI fn
ai_fn_tbl_e	equ	600Eh			; AI fn
ai_fn_tbl_f	equ	6010h			; AI fn
ai_fn_tbl_g	equ	6012h			; AI fn
ai_fn_tbl_h	equ	6014h			; AI fn
ai_fn_tbl_i	equ	6016h			; AI fn
ai_fn_tbl_j	equ	601Ch			; AI fn
ai_fn_tbl_k	equ	6028h			; AI fn
ai_fn_tbl_l	equ	602Ah			; AI fn
ai_fn_tbl_m	equ	602Eh			; AI fn
ai_hide_fn	equ	6034h			; AI fn: hide / despawn
ai_attack_fn	equ	603Ah			; AI fn: attack / release projectile

; --- TORI lookup tables (game_seg DS) ---
tori_tbl_a	equ	0A4EAh			; TORI flight-pattern base table
tori_tbl_b	equ	0A519h
tori_tbl_c	equ	0A5A3h
tori_tbl_d	equ	0A654h
tori_tbl_e	equ	0A655h
tori_tbl_f	equ	0A661h
tori_tbl_g	equ	0A662h
gvar_frame_cnt	equ	0FF35h			; frame counter byte

; Backwards-compat aliases
data_7e		equ	ai_fn_tbl_a
data_8e		equ	ai_fn_tbl_b
data_9e		equ	ai_fn_tbl_c
data_10e	equ	ai_fn_tbl_d
data_11e	equ	ai_fn_tbl_e
data_12e	equ	ai_fn_tbl_f
data_13e	equ	ai_fn_tbl_g
data_14e	equ	ai_fn_tbl_h
data_15e	equ	ai_fn_tbl_i
data_16e	equ	ai_fn_tbl_j
data_17e	equ	ai_fn_tbl_k
data_18e	equ	ai_fn_tbl_l
data_19e	equ	ai_fn_tbl_m
data_20e	equ	ai_hide_fn
data_21e	equ	ai_attack_fn
data_22e	equ	tori_tbl_a
data_23e	equ	tori_tbl_b
data_24e	equ	tori_tbl_c
data_25e	equ	tori_tbl_d
data_26e	equ	tori_tbl_e
data_27e	equ	tori_tbl_f
data_28e	equ	tori_tbl_g
data_29e	equ	gvar_frame_cnt

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

tori_ai_main	proc	far

start:
		aaa				; Ascii adjust
		pop	es
		add	[bx+si],al
		mov	dl,0A2h
		db	 00h, 00h, 00h, 00h, 9Ah,0A2h
		db	 14h, 0Ah, 0Ah, 14h, 00h, 00h
		db	 00h, 00h, 28h, 28h, 10h, 28h
		db	 00h
		db	27 dup (0)
		db	0B0h,0A0h, 55h,0A1h,0A5h,0A1h
		db	0D7h,0A1h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 28h,0A1h
		db	 73h,0A1h,0C8h,0A1h, 13h,0A2h
		db	8 dup (0)
		db	 72h,0A2h, 72h,0A2h, 22h,0A2h
		db	 59h,0A2h, 31h,0A2h, 45h,0A2h
		db	 6Dh,0A2h, 00h, 00h, 8Bh,0A2h
		db	 90h,0A2h, 00h, 00h, 00h, 00h
		db	 86h,0A2h, 95h,0A2h, 00h, 00h
		db	 00h, 00h,0ECh,0A0h, 37h,0A1h
		db	 82h,0A1h,0F5h,0A1h, 00h
		db	7 dup (0)
		db	 28h,0A1h, 73h,0A1h,0C8h,0A1h
		db	 13h,0A2h
		db	8 dup (0)
		db	 72h,0A2h, 72h,0A2h, 22h,0A2h
		db	 59h,0A2h, 31h,0A2h, 45h,0A2h
		db	 6Dh,0A2h, 00h, 00h, 8Bh,0A2h
		db	 90h,0A2h, 00h, 00h, 00h, 00h
		db	 86h,0A2h, 95h,0A2h, 00h, 00h
		db	 00h, 00h, 00h, 01h, 02h, 03h
		db	 04h, 00h, 05h, 06h, 07h, 08h
		db	 00h, 09h, 0Ah, 0Bh, 0Ch, 00h
		db	 0Dh, 0Eh, 0Fh, 10h, 00h, 11h
		db	 12h, 13h, 14h, 00h, 15h, 16h
		db	 17h, 18h, 00h, 19h, 1Ah, 1Bh
		db	 1Ch, 00h, 1Dh, 1Eh, 0Fh, 10h
		db	 00h, 21h, 22h, 00h, 00h, 00h
		db	 00h, 00h, 21h, 22h, 00h, 00h
		db	 00h, 23h, 24h, 00h, 25h, 26h
		db	 27h, 28h, 00h, 1Dh, 1Eh, 0Fh
		db	 10h, 00h,0BFh, 1Ah,0C0h, 1Ch
		db	 00h, 15h, 16h,0C1h,0C2h, 00h
		db	 11h, 12h, 13h, 14h, 00h, 0Dh
		db	 0Eh, 0Fh, 10h, 00h,0C3h, 0Ah
		db	0C4h, 1Ch, 00h, 05h, 06h, 20h
		db	 1Fh, 00h, 01h, 02h, 03h, 04h
		db	 00h, 21h, 22h, 00h, 00h, 00h
		db	 00h, 00h, 21h, 22h, 00h, 00h
		db	 00h, 23h, 24h, 00h, 25h, 26h
		db	 27h, 28h, 00h, 29h, 2Ah, 2Bh
		db	 2Ch, 00h, 2Dh, 2Eh, 2Fh, 30h
		db	 00h, 31h, 32h, 33h, 34h, 00h
		db	 00h, 00h, 35h, 36h, 00h, 37h
		db	 38h, 39h, 3Ah, 00h, 3Bh, 3Ch
		db	 3Dh, 3Eh, 00h, 3Fh, 40h, 41h
		db	 42h, 00h, 43h, 44h, 45h, 46h
		db	 00h, 43h, 44h, 45h, 46h, 00h
		db	 00h, 00h, 47h, 48h, 00h
		db	 49h, 4Ah
		db	'KL', 0
		db	'MNOP', 0
		db	'QRST', 0
		db	'UVWX', 0
		db	'UVWX', 0
		db	'YZ[\', 0
		db	']^_`', 0
		db	'abcd'
		db	 00h, 00h, 00h, 65h, 66h, 00h
		db	 00h, 00h, 67h, 68h, 00h, 00h
		db	 00h, 69h, 6Ah, 00h, 00h, 00h
		db	 6Bh, 6Ch, 00h, 6Dh, 6Eh, 6Fh
		db	 70h, 00h, 76h, 77h, 73h, 74h
		db	 00h, 76h, 78h, 73h, 74h, 00h
		db	 00h, 00h, 65h, 66h, 00h, 00h
		db	 00h, 67h, 68h, 00h, 00h, 00h
		db	 69h, 6Ah, 00h, 00h, 00h, 6Bh
		db	 6Ch, 00h, 6Dh, 6Eh, 6Fh, 70h
		db	 00h, 71h, 72h, 73h, 74h, 00h
		db	 75h, 72h, 73h, 74h, 00h, 7Bh
		db	 7Ch, 7Dh, 7Eh, 00h, 7Fh, 80h
		db	 81h, 82h, 00h, 83h, 84h, 85h
		db	 86h, 01h, 87h, 88h, 89h, 8Ah
		db	 01h, 8Bh, 8Ch, 8Dh, 8Eh, 01h
		db	 8Fh, 90h, 91h, 92h, 01h, 93h
		db	 94h, 95h, 96h, 01h, 97h, 98h
		db	 99h, 9Ah, 01h, 9Bh, 9Ch, 9Dh
		db	 9Eh, 01h, 87h, 88h, 89h, 8Ah
		db	 01h, 9Fh,0A0h,0A1h,0A2h, 01h
		db	0A3h,0A4h,0A5h,0A6h, 01h,0A7h
		db	0A8h,0A9h,0AAh, 01h,0ABh,0ACh
		db	0ADh,0AEh, 01h,0AFh,0B0h,0B1h
		db	0B2h, 01h,0B3h,0B4h,0B5h,0B6h
		db	 01h,0B7h,0B8h,0B9h,0BAh, 01h
		db	0BBh,0BCh,0BDh,0BEh, 01h,0EFh
		db	0F0h,0F1h,0F2h, 01h,0F3h,0C5h
		db	0C6h,0C7h, 01h,0C8h,0C9h,0CAh
		db	0CBh, 00h,0CCh,0CDh,0CEh,0CFh
		db	 00h,0D0h,0D1h,0D2h,0D3h, 00h
		db	0D4h,0D5h,0D6h,0D7h, 00h,0D0h
		db	0D1h,0D2h,0D3h, 02h,0CCh,0CDh
		db	0CEh,0CFh, 02h,0D0h,0D1h,0D2h
		db	0D3h, 02h,0D4h,0D5h,0D6h,0D7h
		db	 02h,0D0h,0D1h,0D2h,0D3h, 00h
		db	0D8h,0D9h,0DAh,0DBh, 00h,0D8h
		db	0D9h,0DAh,0DBh, 00h,0D8h,0D9h
		db	0DAh,0DBh, 00h,0D8h,0D9h,0DAh
		db	0DBh, 01h,0DCh,0DDh,0DEh,0DFh
		db	 01h,0E4h,0ECh,0E4h,0ECh, 01h
		db	0E5h,0ECh,0E6h,0ECh, 01h,0E7h
		db	0E8h,0E9h,0EAh, 01h, 00h, 00h
		db	 00h,0EBh, 02h,0E0h,0E1h,0E2h
		db	0E3h, 00h,0EDh,0EEh, 79h, 7Ah
		db	 02h,0EDh,0EEh, 79h, 7Ah, 01h
		db	0F4h,0F5h,0F6h,0F7h,0A2h,0A2h
		db	0A6h,0A2h,0AAh,0A2h,0AEh,0A2h
		db	 04h, 04h, 00h, 00h, 05h, 05h
		db	 00h, 00h, 04h, 04h, 04h, 04h
		db	 05h, 05h, 05h, 05h, 8Ah, 5Ch
		db	 04h, 80h,0E3h, 0Fh, 32h,0FFh
		db	 03h,0DBh,0FFh,0A7h,0C0h,0A2h
		db	0C8h,0A2h, 4Dh,0A4h,0F0h,0A4h
		db	 6Eh,0A6h,0F6h, 44h, 08h,0FFh
		db	 75h, 04h,0C6h, 44h, 08h, 02h
		db	0F6h, 44h, 05h, 20h, 74h, 05h
		db	 2Eh,0FFh, 26h, 34h, 60h, 8Ah
		db	 5Ch, 09h, 83h,0E3h, 07h, 03h
		db	0DBh,0FFh,0A7h,0E9h,0A2h,0F9h
		db	0A2h, 56h,0A3h, 67h,0A3h, 74h
		db	0A3h,0ACh,0A3h,0E0h,0A3h, 05h
		db	0A4h, 0Eh,0A4h,0FEh, 44h, 06h
		db	 80h, 64h, 06h, 07h, 2Eh,0FFh
		db	 16h, 1Ch, 60h, 73h, 46h,0F6h
		db	 44h, 06h, 01h, 75h, 01h,0C3h
		db	 8Ah, 44h, 03h, 3Ch, 12h, 72h
		db	 04h, 3Ch, 15h
		db	 72h, 34h
loc_1:
		test	byte ptr [si+5],80h
		jnz	loc_4			; Jump if not zero
		call	word ptr cs:data_12e
		jc	loc_2			; Jump if carry Set
		retn
loc_2:
		xor	al,al			; Zero register
		xchg	[si+0Ah],al
		xor	byte ptr [si+5],80h
		test	al,1
		jz	loc_3			; Jump if zero
		retn
loc_3:
		jmp	short loc_6
loc_4:
		call	word ptr cs:data_8e
		jc	loc_5			; Jump if carry Set
		retn
loc_5:
		xor	al,al			; Zero register
		xchg	[si+0Ah],al
		xor	byte ptr [si+5],80h
		test	al,1
		jz	loc_6			; Jump if zero
		retn
loc_6:
		mov	byte ptr [si+9],1
		mov	byte ptr [si+6],8
		retn
			                        ;* No entry point to code
		call	word ptr cs:data_14e
		jc	loc_7			; Jump if carry Set
		retn
loc_7:
		mov	byte ptr [si+9],2
		mov	byte ptr [si+6],9
		retn
			                        ;* No entry point to code
		mov	byte ptr [si+9],3
		mov	byte ptr [si+6],0Ah
		mov	byte ptr [si+0Ah],0
		retn
			                        ;* No entry point to code
		cmp	byte ptr [si+0Ah],1
		jne	loc_8			; Jump if not equal
		mov	byte ptr [si+9],4
		mov	byte ptr [si+0Ah],0FFh
loc_8:
		mov	byte ptr [si+6],0Bh
		test	byte ptr [si+5],80h
		jnz	loc_10			; Jump if not zero
		inc	byte ptr [si+0Ah]
		call	word ptr cs:data_11e
		jc	loc_9			; Jump if carry Set
		retn
loc_9:
		xor	byte ptr [si+5],80h
		retn
loc_10:
		inc	byte ptr [si+0Ah]
		call	word ptr cs:data_9e
		jc	loc_11			; Jump if carry Set
		retn
loc_11:
		xor	byte ptr [si+5],80h
		retn
			                        ;* No entry point to code
		cmp	byte ptr [si+0Ah],1
		jne	loc_12			; Jump if not equal
		mov	byte ptr [si+9],5
loc_12:
		mov	byte ptr [si+6],8
		test	byte ptr [si+5],80h
		jnz	loc_14			; Jump if not zero
		inc	byte ptr [si+0Ah]
		call	word ptr cs:data_12e
		jc	loc_13			; Jump if carry Set
		retn
loc_13:
		xor	byte ptr [si+5],80h
		retn
loc_14:
		inc	byte ptr [si+0Ah]
		call	word ptr cs:data_8e
		jc	loc_15			; Jump if carry Set
		retn
loc_15:
		xor	byte ptr [si+5],80h
		retn
			                        ;* No entry point to code
		mov	byte ptr [si+6],8
		test	byte ptr [si+5],80h
		jnz	loc_17			; Jump if not zero
		call	word ptr cs:data_13e
		jc	loc_16			; Jump if carry Set
		retn
loc_16:
		mov	byte ptr [si+6],9
		mov	byte ptr [si+9],6
		retn
loc_17:
		call	word ptr cs:data_15e
		jc	loc_18			; Jump if carry Set
		retn
loc_18:
		jmp	short loc_16
			                        ;* No entry point to code
		mov	byte ptr [si+6],0Ah
		mov	byte ptr [si+9],7
		retn
			                        ;* No entry point to code
		mov	byte ptr [si+6],8
		test	byte ptr [si+5],80h
		jnz	loc_21			; Jump if not zero
		call	word ptr cs:data_11e
		jc	loc_19			; Jump if carry Set
		retn
loc_19:
		call	word ptr cs:data_16e
		jc	loc_20			; Jump if carry Set
		xor	byte ptr [si+5],80h
		retn
loc_20:
		mov	byte ptr [si+9],0
		mov	byte ptr [si+6],0
		mov	byte ptr [si+0Ah],1
		retn
loc_21:
		call	word ptr cs:data_9e
		jc	loc_22			; Jump if carry Set
		retn
loc_22:
		call	word ptr cs:data_10e
		jc	loc_20			; Jump if carry Set
		xor	byte ptr [si+5],80h
		retn
			                        ;* No entry point to code
		test	byte ptr [si+8],0FFh
		jnz	loc_23			; Jump if not zero
		mov	byte ptr [si+8],2
loc_23:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_24			; Jump if zero
		jmp	word ptr cs:data_20e
loc_24:
		test	byte ptr [si+9],8
		jnz	loc_28			; Jump if not zero
		test	byte ptr [si+9],4
		jnz	loc_25			; Jump if not zero
		or	byte ptr [si+5],80h
		cmp	byte ptr [si+3],11h
		jb	loc_25			; Jump if below
		xor	byte ptr [si+5],80h
loc_25:
		call	word ptr cs:data_14e
		jc	loc_26			; Jump if carry Set
		retn
loc_26:
		and	byte ptr [si+6],0F0h
		add	byte ptr [si+6],80h
		jc	loc_27			; Jump if carry Set
		retn
loc_27:
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],8
		retn
loc_28:
		and	byte ptr [si+9],0FBh
		mov	al,[si+6]
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],6
		jb	loc_29			; Jump if below
		mov	byte ptr [si+6],0
		and	byte ptr [si+9],0F7h
loc_29:
		mov	bx,0A4E4h
		test	byte ptr [si+5],80h
		jnz	loc_30			; Jump if not zero
		mov	bx,data_22e
loc_30:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_7e
		jc	loc_31			; Jump if carry Set
		retn
loc_31:
		and	byte ptr [si+9],0F7h
		cmp	byte ptr [si+6],1
		jne	loc_32			; Jump if not equal
		or	byte ptr [si+9],4
		xor	byte ptr [si+5],80h
loc_32:
		mov	byte ptr [si+6],0
		jmp	word ptr cs:data_14e
			                        ;* No entry point to code
		add	[bx+di],ax
		add	[bx+si],al
		pop	es
		pop	es
		add	ax,[bp+di]
		add	al,4
		add	ax,0F605h
		inc	sp
;*		or	bh,bh			; Zero ?
		db	 08h,0FFh		;  Fixup - byte match
		jnz	loc_33			; Jump if not zero
		mov	byte ptr [si+8],4
loc_33:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_34			; Jump if zero
		jmp	word ptr cs:data_20e
loc_34:
		call	word ptr cs:data_14e
		jc	loc_35			; Jump if carry Set
		retn
loc_35:
		mov	bl,[si+9]
		and	bx,3
		add	bx,bx
		jmp	word ptr ds:data_23e[bx]	;*
			                        ;* No entry point to code
		and	ds:data_24e[di],sp
		mov	dx,12A5h
		cmpsb				; Cmp [si] to es:[di]
		or	byte ptr [si+4],60h	; '`'
		add	byte ptr [si+6],80h
		jc	loc_36			; Jump if carry Set
		retn
loc_36:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],1
		jz	loc_37			; Jump if zero
		retn
loc_37:
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],7
		jb	loc_38			; Jump if below
		mov	byte ptr [si+9],1
		mov	byte ptr [si+6],2
loc_38:
		test	byte ptr [si+5],80h
		jz	loc_40			; Jump if zero
		mov	ax,[si+2]
		call	word ptr cs:data_17e
		xchg	si,di
		add	si,4Ah
		call	word ptr cs:data_18e
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:data_19e
		jz	loc_39			; Jump if zero
		jmp	word ptr cs:data_8e
loc_39:
		and	byte ptr [si+5],7Fh
		jmp	word ptr cs:data_12e
loc_40:
		mov	ax,[si+2]
		call	word ptr cs:data_17e
		xchg	si,di
		add	si,47h
		call	word ptr cs:data_18e
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:data_19e
		jz	loc_41			; Jump if zero
		jmp	word ptr cs:data_12e
loc_41:
		or	byte ptr [si+5],80h
		jmp	word ptr cs:data_8e
			                        ;* No entry point to code
		and	byte ptr [si+4],1Fh
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],5
		je	loc_42			; Jump if equal
		retn
loc_42:
		mov	byte ptr [si+9],2
		mov	byte ptr [si+0Ah],0
		retn
			                        ;* No entry point to code
		test	byte ptr [si+9],80h
		jnz	loc_44			; Jump if not zero
		add	byte ptr [si+6],40h	; '@'
		jc	loc_43			; Jump if carry Set
		retn
loc_43:
		xor	byte ptr [si+5],80h
		call	sub_1
		jc	loc_45			; Jump if carry Set
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],3
		je	loc_44			; Jump if equal
		retn
loc_44:
		mov	byte ptr [si+9],3
		mov	byte ptr [si+6],5
		retn
loc_45:
		mov	byte ptr [si+6],6
		or	byte ptr [si+9],80h
		mov	al,[si+3]
		mov	ds:data_27e,al
		inc	al
		mov	ds:data_25e,al
		mov	al,[si+2]
		and	al,3Fh			; '?'
		mov	ds:data_28e,al
		mov	ds:data_26e,al
		mov	bx,0A654h
		test	byte ptr [si+5],80h
		jnz	loc_46			; Jump if not zero
		mov	bx,0A661h
loc_46:
		jmp	word ptr cs:data_21e
			                        ;* No entry point to code
		dec	byte ptr [si+6]
		cmp	byte ptr [si+6],1
		je	loc_47			; Jump if equal
		retn
loc_47:
		mov	byte ptr [si+9],0
		mov	byte ptr [si+0Ah],0
		retn

tori_ai_main	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		mov	al,ds:data_29e
		sub	al,[si+2]
		jns	loc_48			; Jump if not sign
		neg	al
loc_48:
		cmp	al,5
		mov	al,0FFh
		jc	loc_49			; Jump if carry Set
		retn
loc_49:
		cmp	byte ptr [si+3],11h
		jae	loc_51			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	loc_50			; Jump if zero
		retn
loc_50:
		clc				; Clear carry flag
		retn
loc_51:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	loc_52			; Jump if not zero
		retn
loc_52:
		clc				; Clear carry flag
		retn
sub_1		endp

		db	 00h, 00h, 2Bh, 00h, 0Fh, 00h
		db	 28h
		db	8 dup (0)
		db	 2Bh, 00h, 0Fh, 04h, 28h, 00h
		db	 00h, 00h, 00h, 00h, 00h,0F6h
		db	 44h, 08h,0FFh, 75h, 04h,0C6h
		db	 44h, 08h, 04h,0F6h, 44h, 05h
		db	 20h, 74h, 05h, 2Eh,0FFh
		db	 26h, 34h, 60h
loc_53:
		mov	al,[si+6]
		push	ax
		mov	byte ptr [si+6],0
		call	word ptr cs:data_14e
		pop	ax
		jc	loc_54			; Jump if carry Set
		retn
loc_54:
		mov	[si+6],al
		test	byte ptr [si+9],1
		jnz	loc_58			; Jump if not zero
		mov	byte ptr [si+6],1
		mov	byte ptr [si+0Ah],0
		call	sub_2
		jc	loc_56			; Jump if carry Set
		cmp	al,0FFh
		jne	loc_55			; Jump if not equal
		retn
loc_55:
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		retn
loc_56:
		cmp	ah,0Ah
		jb	loc_57			; Jump if below
		retn
loc_57:
		or	byte ptr [si+9],1
		retn
loc_58:
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],14h
		je	loc_59			; Jump if equal
		test	byte ptr [si+5],80h
		jnz	loc_60			; Jump if not zero
		call	word ptr cs:data_12e
		jnc	loc_61			; Jump if carry=0
		call	word ptr cs:data_11e
		jnc	loc_61			; Jump if carry=0
loc_59:
		and	byte ptr [si+9],0FEh
		retn
loc_60:
		call	word ptr cs:data_8e
		jnc	loc_61			; Jump if carry=0
		call	word ptr cs:data_9e
		jc	loc_59			; Jump if carry Set
loc_61:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],6
		jae	loc_62			; Jump if above or =
		retn
loc_62:
		mov	byte ptr [si+6],1
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_2		proc	near
		mov	al,ds:data_29e
		sub	al,[si+2]
		jns	loc_63			; Jump if not sign
		neg	al
loc_63:
		cmp	al,6
		mov	al,0FFh
		jc	loc_64			; Jump if carry Set
		retn
loc_64:
		mov	al,11h
		sub	al,[si+3]
		jc	loc_66			; Jump if carry Set
		mov	ah,al
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	loc_65			; Jump if zero
		retn
loc_65:
		clc				; Clear carry flag
		retn
loc_66:
		neg	al
		mov	ah,al
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	loc_67			; Jump if not zero
		retn
loc_67:
		clc				; Clear carry flag
		retn
sub_2		endp


seg_a		ends



		end	start
