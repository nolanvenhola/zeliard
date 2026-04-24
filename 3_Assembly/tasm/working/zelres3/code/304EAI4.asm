
PAGE  59,132

;==========================================================================
;
;  304EAI4.BIN - Enemy AI Handler: ZELA (zelres3 chunk 5)
;
;  Per-enemy AI controller for the ZELA enemy, loaded alongside
;  312ZELA.BIN sprites. ZELA is a mid-game enemy with segmented body
;  (this file spawns linked body parts in enemy_data_ext[bx] starting
;  at 0ED20h and chains them via the enemy table at 0C010h).
;
;  Dispatch model matches the EAI* family (see 301EAI1.asm).
;
;  Resource table constants (DS offsets in game_seg):
;    6004h..603Eh = ZELA movement/collision/spawn dispatch table slots.
;    0A45Eh / 0A756h = ZELA attack-pattern and movement direction tables.
;    0C002h = shared active projectile count (gvar_proj_cnt).
;    0C010h = enemy slot record base (enemy_attr_base).
;    0ED20h = extended enemy data area (body segment/chain tracking).
;    0FF35h / 0FF4Ah = global frame / sub-frame counters.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; --- ZELA enemy AI dispatch table (game_seg:6004h..603Eh, DS-relative) ---
ai_fn_tbl_a	equ	6004h			; AI fn
ai_fn_tbl_b	equ	6008h			; AI fn
ai_fn_tbl_c	equ	6010h			; AI fn
ai_fn_tbl_d	equ	6012h			; AI fn
ai_fn_tbl_e	equ	6014h			; AI fn
ai_fn_tbl_f	equ	6016h			; AI fn
ai_fn_tbl_g	equ	6028h			; AI fn
ai_fn_tbl_h	equ	602Ah			; AI fn
ai_fn_tbl_i	equ	602Ch			; AI fn
ai_fn_tbl_j	equ	602Eh			; AI fn
ai_fn_tbl_k	equ	6032h			; AI fn
ai_hide_fn	equ	6034h			; AI fn: hide / despawn
ai_spawn_fn	equ	603Eh			; AI fn: spawn body segment

; --- ZELA lookup tables / battle globals ---
zela_tbl_a	equ	0A45Eh			; ZELA pattern/direction lookup A
zela_tbl_b	equ	0A756h			; ZELA pattern/direction lookup B
gvar_proj_cnt	equ	0C002h			; shared projectile count
enemy_attr_base	equ	0C010h			; enemy slot record base (DS:0C010h)
enemy_data_ext	equ	0ED20h			; extended enemy data area (body chain)
gvar_frame_cnt	equ	0FF35h			; frame counter byte
gvar_sub_frame	equ	0FF4Ah			; sub-frame counter byte

; Backwards-compat aliases
data_10e	equ	ai_fn_tbl_a
data_11e	equ	ai_fn_tbl_b
data_12e	equ	ai_fn_tbl_c
data_13e	equ	ai_fn_tbl_d
data_14e	equ	ai_fn_tbl_e
data_15e	equ	ai_fn_tbl_f
data_16e	equ	ai_fn_tbl_g
data_17e	equ	ai_fn_tbl_h
data_18e	equ	ai_fn_tbl_i
data_19e	equ	ai_fn_tbl_j
data_20e	equ	ai_fn_tbl_k
data_21e	equ	ai_hide_fn
data_22e	equ	ai_spawn_fn
data_23e	equ	zela_tbl_a
data_24e	equ	zela_tbl_b
data_25e	equ	gvar_proj_cnt
data_26e	equ	enemy_attr_base
data_27e	equ	enemy_data_ext
data_28e	equ	gvar_frame_cnt
data_29e	equ	gvar_sub_frame

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zela_ai_main	proc	far

start:
		inc	si
		or	[bx+si],al
		add	[bx+di-5Eh],ch
		db	 00h, 00h, 00h, 00h, 4Fh,0A2h
		db	 0Ah, 0Ah, 00h, 00h, 14h, 00h
		db	 00h, 00h, 14h, 04h
		db	 50h, 50h, 50h
		db	27 dup (0)
		db	0B0h,0A0h, 5Fh,0A1h, 96h,0A1h
		db	0A0h,0A1h,0B9h,0A1h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 50h,0A1h
		db	 87h,0A1h,0AAh,0A1h,0AAh,0A1h
		db	0CDh,0A1h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 2Ch,0A2h, 2Ch,0A2h
		db	0DCh,0A1h, 13h,0A2h,0EBh,0A1h
		db	0FFh,0A1h, 27h,0A2h, 00h, 00h
		db	 45h,0A2h, 4Ah,0A2h, 40h,0A2h
		db	 00h, 00h
		db	9 dup (0)
		db	0A1h, 5Fh,0A1h, 96h,0A1h,0A0h
		db	0A1h,0B9h,0A1h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 50h,0A1h, 87h
		db	0A1h,0AAh,0A1h,0AAh,0A1h,0CDh
		db	0A1h, 00h, 00h, 00h, 00h
data_3		db	0
		db	 00h, 2Ch,0A2h, 2Ch,0A2h,0DCh
		db	0A1h, 13h,0A2h,0EBh,0A1h,0FFh
		db	0A1h, 27h,0A2h, 00h, 00h, 45h
		db	0A2h, 4Ah,0A2h, 40h,0A2h, 00h
		db	 00h
		db	8 dup (0)
		db	 01h, 00h, 01h, 02h, 03h, 01h
		db	 00h, 01h, 05h, 06h, 01h, 00h
		db	 01h, 08h, 09h, 01h, 00h, 01h
		db	 0Bh, 0Ch, 01h, 00h, 01h, 0Eh
		db	 0Fh, 01h, 00h, 01h, 11h, 12h
		db	 01h, 00h, 01h, 14h, 15h, 01h
		db	 00h, 01h, 17h, 18h, 01h, 00h
		db	 01h, 32h, 33h, 01h, 00h, 00h
		db	 34h, 35h, 01h, 00h, 00h, 36h
		db	 37h, 01h, 00h, 00h, 38h, 39h
		db	 01h, 00h, 00h,0E2h,0A4h, 01h
		db	 3Ah, 3Bh, 3Ch, 3Dh, 01h, 3Eh
		db	 00h, 3Fh, 00h, 01h, 40h, 00h
		db	 41h, 00h, 01h, 19h, 00h, 1Ah
		db	 1Bh, 01h, 19h, 00h, 1Dh, 1Eh
		db	 01h, 19h, 00h, 20h, 21h, 01h
		db	 19h, 00h, 23h, 24h, 01h, 19h
data_5		dw	2600h
		db	 27h, 01h, 19h, 00h, 29h, 2Ah
		db	 01h, 19h, 00h
		db	 2Ch, 2Dh
data_6		db	1
		db	 19h, 00h, 2Fh, 30h, 01h, 19h
		db	 00h, 43h, 44h, 01h, 00h, 00h
		db	 45h, 46h, 01h, 00h, 00h, 47h
		db	 48h, 01h, 00h, 00h, 49h, 4Ah
		db	 01h, 00h, 00h,0A3h,0A2h, 01h
		db	 4Bh, 4Ch, 4Dh, 4Eh, 01h, 00h
		db	 4Fh, 00h, 50h, 01h, 00h, 51h
		db	 00h, 52h, 01h, 53h, 54h, 55h
		db	 56h, 01h, 57h, 58h, 59h, 5Ah
		db	 01h
		db	 5Bh, 5Ch
		db	']^', 0
		db	'_`ab', 0
		db	'c`ef', 0
		db	'ghij', 0
		db	'_lmn', 0
		db	'o`qr', 0
		db	'stuv', 0
		db	'cxyz', 0
		db	'{l}~', 0
		db	 7Fh, 80h, 81h, 82h, 00h, 83h
		db	 84h, 85h, 86h, 00h, 87h, 88h
		db	 89h, 8Ah, 02h, 8Bh, 8Ch, 8Dh
		db	 8Eh, 02h, 8Fh, 90h
data_8		db	91h			; Data table (indexed access)
		db	 92h, 02h, 9Dh, 9Dh, 9Eh, 9Eh
		db	 02h,0A1h,0A1h, 9Eh, 9Eh, 02h
		db	 95h, 96h, 98h, 99h, 02h, 99h
		db	 9Ah, 9Bh, 9Ch, 02h, 00h, 00h
		db	 9Fh,0A0h, 00h,0A8h,0A9h,0AAh
		db	0ABh, 00h,0ACh,0ADh,0AEh,0AFh
		db	 00h,0B0h,0B1h,0B2h,0B3h, 00h
		db	0B4h,0B5h,0B6h,0B7h, 00h,0B8h
		db	0B9h,0BAh,0BBh, 00h,0BCh,0BDh
		db	0BEh,0BFh, 00h,0C0h,0C1h,0C2h
		db	0C3h, 01h, 04h, 07h, 0Ah, 0Dh
		db	 01h, 10h, 13h, 16h, 1Ch, 01h
		db	 1Fh, 22h, 25h, 28h, 00h, 2Bh
		db	 2Eh, 31h, 42h, 00h, 64h, 6Bh
		db	 70h, 77h, 00h, 7Ch,0C4h,0C5h
		db	0C6h, 00h, 64h, 6Bh, 70h, 77h
		db	 02h, 2Bh, 2Eh, 31h, 42h, 02h
		db	 64h, 6Bh, 70h, 77h, 02h, 7Ch
		db	0C4h,0C5h,0C6h, 02h, 64h, 6Bh
		db	 70h, 77h, 00h,0C7h,0C8h,0C9h
		db	0CAh, 00h,0C7h,0C8h,0C9h,0CAh
		db	 00h,0C7h,0C8h,0C9h,0CAh, 00h
		db	0C7h,0C8h,0C9h,0CAh, 01h,0CBh
		db	0CCh,0CDh,0CEh, 02h,0D7h,0D7h
		db	0D7h,0D7h, 02h,0D8h,0D9h,0DAh
		db	0DBh, 02h,0DCh,0DDh,0DEh,0DFh
		db	 02h, 00h, 00h,0E0h,0E1h, 00h
		db	0CFh,0D0h,0D1h,0D2h, 00h,0D3h
		db	0D4h,0D5h,0D6h, 02h,0D3h,0D4h
		db	0D5h,0D6h, 59h,0A2h, 5Dh,0A2h
		db	 61h,0A2h, 61h,0A2h, 65h,0A2h
		db	 05h, 04h, 04h, 05h, 04h, 04h
		db	 04h, 04h, 01h, 01h, 01h, 01h
		db	 05h, 05h, 05h, 04h, 8Ah, 5Ch
		db	 04h, 80h,0E3h, 0Fh, 32h,0FFh
		db	 03h,0DBh,0FFh,0A7h, 77h,0A2h
		db	 81h,0A2h, 66h,0A4h,0B1h,0A6h
		db	0B1h,0A6h,0F0h,0A6h,0F6h, 44h
		db	 08h,0FFh, 75h, 04h,0C6h
		db	 44h, 08h, 08h
loc_1:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_2			; Jump if zero
		jmp	word ptr cs:data_21e
loc_2:
		test	byte ptr [si+9],8
		jz	loc_3			; Jump if zero
		jmp	loc_29
loc_3:
		test	byte ptr [si+9],4
		jz	loc_4			; Jump if zero
		jmp	loc_20
loc_4:
		call	word ptr cs:data_14e
		jc	loc_5			; Jump if carry Set
		retn
loc_5:
		test	byte ptr [si+9],1
		jnz	loc_14			; Jump if not zero
		test	byte ptr [si+9],2
		jz	loc_6			; Jump if zero
		jmp	loc_17
loc_6:
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,7
		and	ah,0F0h
		or	al,ah
		add	al,80h
		mov	[si+6],al
		jc	loc_7			; Jump if carry Set
		retn
loc_7:
		mov	al,ds:data_28e
		mov	ah,[si+2]
		cmp	al,ah
		je	loc_8			; Jump if equal
		inc	al
		and	al,3Fh			; '?'
		cmp	al,ah
		je	loc_8			; Jump if equal
		test	byte ptr [si+5],80h
		jnz	loc_12			; Jump if not zero
		jmp	short loc_10
loc_8:
		call	word ptr cs:data_5
		and	al,3
		jnz	loc_9			; Jump if not zero
		mov	byte ptr [si+9],5
loc_9:
		cmp	byte ptr [si+3],11h
		jb	loc_12			; Jump if below
loc_10:
		and	byte ptr [si+5],7Fh
		call	word ptr cs:data_12e
		jc	loc_11			; Jump if carry Set
		retn
loc_11:
		mov	byte ptr [si+9],9
		retn
loc_12:
		or	byte ptr [si+5],80h
		call	word ptr cs:data_11e
		jc	loc_13			; Jump if carry Set
		retn
loc_13:
		mov	byte ptr [si+9],9
		retn
loc_14:
		mov	al,[si+6]
		and	al,0Fh
		cmp	al,8
		jae	loc_15			; Jump if above or =
		mov	byte ptr [si+6],8
		retn
loc_15:
		inc	al
		mov	[si+6],al
		cmp	al,0Bh
		je	loc_16			; Jump if equal
		retn
loc_16:
		or	al,10h
		mov	[si+6],al
		and	byte ptr [si+9],0FEh
		retn
loc_17:
		mov	al,[si+6]
		and	al,0Fh
		cmp	al,0Ch
		jb	loc_18			; Jump if below
		mov	byte ptr [si+6],0Bh
		retn
loc_18:
		dec	al
		mov	[si+6],al
		cmp	al,8
		je	loc_19			; Jump if equal
		retn
loc_19:
		or	al,10h
		mov	[si+6],al
		and	byte ptr [si+9],0FDh
		retn
loc_20:
		mov	al,[si+6]
		and	al,0Fh
		inc	al
		cmp	al,0Fh
		jae	loc_21			; Jump if above or =
		mov	[si+6],al
		retn
loc_21:
		cmp	al,10h
		jb	loc_22			; Jump if below
		mov	al,0Eh
loc_22:
		mov	[si+6],al
		test	byte ptr [si+5],80h
		jz	loc_25			; Jump if zero
		call	word ptr cs:data_15e
		call	word ptr cs:data_15e
		jc	loc_23			; Jump if carry Set
		retn
loc_23:
		call	word ptr cs:data_11e
		call	word ptr cs:data_11e
		jc	loc_24			; Jump if carry Set
		retn
loc_24:
		and	byte ptr [si+5],7Fh
		jmp	short loc_28
loc_25:
		call	word ptr cs:data_13e
		call	word ptr cs:data_13e
		jc	loc_26			; Jump if carry Set
		retn
loc_26:
		call	word ptr cs:data_12e
		call	word ptr cs:data_12e
		jc	loc_27			; Jump if carry Set
		retn
loc_27:
		or	byte ptr [si+5],80h
loc_28:
		mov	byte ptr [si+6],1Dh
		mov	byte ptr [si+9],2
		retn
loc_29:
		mov	al,[si+6]
		inc	al
		and	al,0Fh
		cmp	al,0Dh
		jb	loc_30			; Jump if below
		mov	al,0Bh
loc_30:
		mov	[si+6],al
		test	byte ptr [si+0Ah],1
		jnz	loc_32			; Jump if not zero
		call	word ptr cs:data_14e
		add	byte ptr [si+9],10h
		test	byte ptr [si+9],0F0h
		jz	loc_31			; Jump if zero
		retn
loc_31:
		or	byte ptr [si+0Ah],1
		retn
loc_32:
		test	byte ptr [si+0Ah],4
		jnz	loc_34			; Jump if not zero
		or	byte ptr [si+0Ah],4
		test	byte ptr [si+0Ah],8
		jnz	loc_33			; Jump if not zero
		jmp	word ptr cs:data_11e
loc_33:
		jmp	word ptr cs:data_12e
loc_34:
		mov	bx,0A456h
		test	byte ptr [si+5],80h
		jnz	loc_35			; Jump if not zero
		mov	bx,data_23e
loc_35:
		mov	al,[si+9]
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		and	al,7
		add	byte ptr [si+9],20h	; ' '
		test	byte ptr [si+9],0E0h
		jnz	loc_36			; Jump if not zero
		mov	byte ptr [si+0Ah],0
		mov	byte ptr [si+9],2
loc_36:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_10e
		jc	loc_37			; Jump if carry Set
		retn
loc_37:
		mov	al,[si+9]
		and	al,0E0h
		jnz	loc_38			; Jump if not zero
		retn
loc_38:
		cmp	al,0C0h
		jb	loc_39			; Jump if below
		retn
loc_39:
		xor	byte ptr [si+5],80h
		retn
			                        ;* No entry point to code
		add	al,[bx+di]
		add	[bx+si],ax
		add	[bx],al
		pop	es
		push	es
		add	al,[bp+di]
		add	ax,[si]
		add	al,5
		add	ax,0F606h
		inc	sp
;*		or	bh,bh			; Zero ?
		db	 08h,0FFh		;  Fixup - byte match
		jnz	loc_40			; Jump if not zero
		mov	byte ptr [si+8],10h
loc_40:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_47			; Jump if zero
		mov	al,[si+5]
		and	al,1Fh
		cmp	al,4
		jne	loc_41			; Jump if not equal
		jmp	word ptr cs:data_21e
loc_41:
		cmp	al,5
		jne	loc_42			; Jump if not equal
		jmp	word ptr cs:data_21e
loc_42:
		cmp	al,8
		jne	loc_43			; Jump if not equal
		jmp	word ptr cs:data_21e
loc_43:
		cmp	al,1
		jne	loc_44			; Jump if not equal
		cmp	data_3,6
		jne	loc_44			; Jump if not equal
		jmp	word ptr cs:data_21e
loc_44:
		test	byte ptr [si+6],1
		jz	loc_45			; Jump if zero
		jmp	word ptr cs:data_21e
loc_45:
		and	byte ptr [si+5],0DFh
		test	byte ptr [si+7],40h	; '@'
		jnz	loc_47			; Jump if not zero
		call	word ptr cs:data_22e
		jc	loc_47			; Jump if carry Set
		mov	word ptr [di],0FF00h
		test	byte ptr [di+7],40h	; '@'
		jz	loc_46			; Jump if zero
		and	byte ptr [di+7],0BFh
		mov	al,[di+0Ah]
		mov	cl,10h
		mul	cl			; ax = reg * al
		mov	bx,ax
		add	bx,ds:data_26e
		mov	byte ptr [bx+2],0
loc_46:
		mov	byte ptr [di+2],7Fh
		mov	[si+0Ah],dl
		or	byte ptr [si+7],40h	; '@'
loc_47:
		test	byte ptr [si+9],1
		pushf				; Push flags
		and	byte ptr [si+9],0FEh
		popf				; Pop flags
		jz	loc_48			; Jump if zero
		retn
loc_48:
		test	byte ptr [si+7],40h	; '@'
		jnz	loc_57			; Jump if not zero
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,3
		and	ah,0F0h
		or	al,ah
		mov	[si+6],al
		mov	bx,si
loc_49:
		mov	si,bx
loc_50:
		call	word ptr cs:data_14e
		jc	loc_51			; Jump if carry Set
		retn
loc_51:
		sub	byte ptr [si+6],10h
		test	byte ptr [si+6],0F0h
		jz	loc_52			; Jump if zero
		retn
loc_52:
		or	byte ptr [si+6],40h	; '@'
		mov	al,ds:data_28e
		cmp	al,[si+2]
		je	loc_53			; Jump if equal
		inc	al
		and	al,3Fh			; '?'
		cmp	al,[si+2]
		je	loc_53			; Jump if equal
		test	byte ptr [si+5],80h
		jnz	loc_55			; Jump if not zero
		jmp	short loc_54
loc_53:
		mov	al,10h
		cmp	al,[si+3]
		jae	loc_55			; Jump if above or =
loc_54:
		and	byte ptr [si+5],7Fh
		call	word ptr cs:data_12e
		jc	loc_55			; Jump if carry Set
		retn
loc_55:
		or	byte ptr [si+5],80h
		call	word ptr cs:data_11e
		jc	loc_56			; Jump if carry Set
		retn
loc_56:
		and	byte ptr [si+5],7Fh
		jmp	word ptr cs:data_12e
loc_57:
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,7
		and	ah,0F0h
		or	ah,al
		mov	[si+6],ah
		cmp	al,6
		jne	loc_50			; Jump if not equal
		and	[si+6],ah
		mov	al,[si+0Ah]
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,ds:data_26e
		mov	di,ax
		push	di
		mov	ax,[si+2]
		call	word ptr cs:data_16e
		mov	bx,si
		mov	si,di
		pop	di
		test	byte ptr [bx+5],80h
		jnz	loc_62			; Jump if not zero
		mov	al,[bx+3]
		or	al,al			; Zero ?
		jns	loc_58			; Jump if not sign
		jmp	loc_49
loc_58:
		cmp	al,21h			; '!'
		jb	loc_59			; Jump if below
		jmp	loc_49
loc_59:
		mov	ax,23h
		call	sub_1
		jnc	loc_60			; Jump if carry=0
		jmp	loc_49
loc_60:
		inc	si
		inc	si
		mov	cl,[si]
		mov	al,[bx+0Ah]
		or	al,80h
		mov	[si],al
		xchg	si,bx
		mov	al,[si+4]
		and	al,1Fh
		mov	[di+4],al
		mov	ax,[si]
		add	ax,2
		mov	dx,ds:data_25e
		dec	dx
		sub	dx,ax
		jnc	loc_61			; Jump if carry=0
		not	dx
		mov	ax,dx
loc_61:
		mov	[di],ax
		mov	al,[si+3]
		add	al,2
		mov	[di+3],al
		mov	byte ptr [si+6],16h
		mov	byte ptr [di+6],17h
		jmp	short loc_67
loc_62:
		mov	al,[bx+3]
		or	al,al			; Zero ?
		jns	loc_63			; Jump if not sign
		jmp	loc_49
loc_63:
		cmp	al,3
		jae	loc_64			; Jump if above or =
		jmp	loc_49
loc_64:
		mov	ax,27h
		call	sub_1
		jnc	loc_65			; Jump if carry=0
		jmp	loc_49
loc_65:
		dec	si
		dec	si
		mov	cl,[si]
		mov	al,[bx+0Ah]
		or	al,80h
		mov	[si],al
		xchg	si,bx
		mov	al,[si+4]
		and	al,1Fh
		mov	[di+4],al
		mov	ax,[si]
		sub	ax,2
		or	ax,ax			; Zero ?
		jns	loc_66			; Jump if not sign
		add	ax,ds:data_25e
loc_66:
		mov	[di],ax
		mov	al,[si+3]
		sub	al,2
		mov	[di+3],al
		mov	byte ptr [si+6],17h
		mov	byte ptr [di+6],16h
loc_67:
		mov	al,[si+2]
		mov	[di+2],al
		mov	bl,[si+0Ah]
		xor	bh,bh			; Zero register
		mov	ds:data_27e[bx],cl
		mov	byte ptr [di+7],0
		mov	byte ptr [di+8],0
		mov	byte ptr [di+9],0
		and	byte ptr [si+7],0BFh
		mov	al,ds:data_29e
		cmp	al,[si+0Ah]
		jb	loc_68			; Jump if below
		retn
loc_68:
		or	byte ptr [di+9],1
		retn

zela_ai_main	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		push	si
		sub	si,ax
		call	word ptr cs:data_18e
		mov	cx,3

locloop_69:
		mov	al,[si]
		call	word ptr cs:data_19e
		stc				; Set carry flag
		jnz	loc_70			; Jump if not zero
		mov	al,[si+1]
		call	word ptr cs:data_19e
		stc				; Set carry flag
		jnz	loc_70			; Jump if not zero
		mov	al,[si+2]
		call	word ptr cs:data_19e
		stc				; Set carry flag
		jnz	loc_70			; Jump if not zero
		add	si,24h
		call	word ptr cs:data_17e
		loop	locloop_69		; Loop if cx > 0

		clc				; Clear carry flag
loc_70:
		pop	si
		retn
sub_1		endp

			                        ;* No entry point to code
		or	byte ptr [si+4],20h	; ' '
		test	byte ptr [si+9],1
		jnz	loc_74			; Jump if not zero
		mov	al,[si+3]
		cmp	al,8
		jae	loc_71			; Jump if above or =
		retn
loc_71:
		cmp	al,13h
		jb	loc_72			; Jump if below
		retn
loc_72:
		call	word ptr cs:data_5
		and	al,3
		jz	loc_73			; Jump if zero
		retn
loc_73:
		mov	byte ptr [si+6],1
		or	byte ptr [si+9],1
		retn
loc_74:
		call	word ptr cs:data_14e
		jc	loc_75			; Jump if carry Set
		retn
loc_75:
		and	byte ptr [si+7],0F0h
		or	byte ptr [si+7],1
		jmp	word ptr cs:data_20e
			                        ;* No entry point to code
		test	byte ptr [si+8],0FFh
		jnz	loc_76			; Jump if not zero
		mov	byte ptr [si+8],2
loc_76:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_77			; Jump if zero
		jmp	word ptr cs:data_21e
loc_77:
		cmp	byte ptr [si+3],3
		jae	loc_78			; Jump if above or =
		retn
loc_78:
		cmp	byte ptr [si+3],21h	; '!'
		jb	loc_79			; Jump if below
		retn
loc_79:
		call	sub_2
		cmp	cl,3
		je	loc_80			; Jump if equal
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_2		proc	near
loc_80:
		mov	bx,0A7CEh
		test	byte ptr [si+5],80h
		jnz	loc_81			; Jump if not zero
		mov	bx,data_24e
loc_81:
		mov	al,0Fh
		mul	byte ptr [si+9]		; ax = data * al
		add	bx,ax
		mov	cx,5

locloop_82:
		push	cx
		push	bx
		mov	al,[bx]
		call	word ptr cs:data_10e
		pop	bx
		pop	cx
		jnc	loc_83			; Jump if carry=0
		inc	bx
		inc	bx
		inc	bx
		loop	locloop_82		; Loop if cx > 0

		xor	byte ptr [si+5],80h
		retn
loc_83:
		mov	al,[bx+1]
		mov	[si+9],al
		mov	al,[bx+2]
		mov	[si+6],al
		retn
sub_2		endp

			                        ;* No entry point to code
		push	es
		add	al,[bx+di]
		pop	es
		add	[bp+si],ax
		add	[bx+si],al
		add	[bx+di],al
		pop	es
		add	ax,[bp+si]
		push	es
		add	[di],ax
		add	ax,[bp+di]
		push	es
		add	al,[bx+di]
		pop	es
		add	[bp+si],ax
		add	[bx+si],al
		add	[bx+di],al
		pop	es
		add	ax,[si]
		add	al,0
		add	ax,303h
		push	es
		add	al,[bx+di]
		pop	es
		add	[bp+si],ax
		add	[bx+si],al
		add	[bp+di],al
		add	ax,402h
		add	al,0
		add	ax,303h
		push	es
		add	al,[bx+di]
		pop	es
		add	[bp+si],ax
		add	al,byte ptr ds:[301h]
		add	ax,402h
		add	al,0
		add	ax,303h
		push	es
		add	al,[bx+di]
		add	[bx],ax
		add	ax,[bp+si]
		push	es
		add	[bp+di],ax
		add	ax,402h
		add	al,0
		add	ax,303h
		add	[bx+si],al
		add	[bx+di],al
		pop	es
		add	ax,[bp+si]
		push	es
		add	[bp+di],ax
		add	ax,402h
		add	al,0
		pop	es
		add	[bp+si],ax
		add	[bx+si],al
		add	[bx+di],al
		pop	es
		add	ax,[bp+si]
		push	es
		add	[bp+di],ax
		add	ax,602h
		push	es
		add	[di],al
		pop	es
		add	ax,[si]
		add	[bx+si],al
		add	ax,[bx+di]
		add	al,[bp+si]
		add	al,[bx+si]
		add	ax,207h
		add	al,0
		add	[bp+di],al
		add	[bp+si],ax
		add	al,[bp+si]
		add	[bx+di],ax
		add	ax,[bp+si]
		add	al,0
		add	[bp+di],ax
		add	[bp+si],ax
		add	al,[bp+si]
		add	[bx+di],ax
		add	ax,[bp+di]
		add	[si],al
		add	[bp+di],ax
		add	[bp+di],ax
		add	al,[bp+si]
		add	[bx+di],ax
		add	ax,[bp+di]
		add	[si],al
		add	[bx],al
		add	ax,203h
		add	al,[bx+si]
		add	[bp+di],ax
		add	ax,[bx+si]
		add	al,0
		pop	es
		add	ax,602h
		push	es
		add	[bx+di],al
		add	ax,[bp+si]
		add	[si],al
		add	[bx],al
		add	ax,602h
		push	es
		add	[di],ax
		pop	es
		add	al,[bx+si]
		add	al,1
		pop	es
		add	ax,602h
		push	es
		add	[di],ax
		pop	es
		add	ax,[si]
		add	[bx+di],al
		pop	es
		add	ax,603h
		push	es
		add	[di],ax
		pop	es
		add	ax,[si]
		add	[bx+si],al
		add	ax,[bx+di]
		db	03h			; truncated 'add ax,[bx+si]' — file ends mid-instruction (missing ModRM)

seg_a		ends



		end	start
