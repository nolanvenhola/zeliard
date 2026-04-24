
PAGE  59,132

;==========================================================================
;
;  319MAO2 / _319MAPA6 - Final Boss Arena Map Program (zelres3 chunk)
;
;  Map-program code module for the final boss (Boss 6 / Mao-2) arena.
;  Loaded together with the arena data file map_boss6_arena.bin
;  (319MAPA6.bin). This is the LAST map-program in the game - the
;  climactic demon-lord (Jp. "Mao") encounter.
;
;  Contains the 'ashiin' byte sequence near end (Jashiin speaker-name
;  fragment, shared with 318MAO1). The file has 8+ helper subroutines
;  (sub_2..sub_9) wiring up the final-boss behaviour state machine.
;
;  Structure:
;    - Header / dispatch pointer area (file 0x00..~0x80) mis-decoded by
;      Sourcer - preserved as db bytes
;    - Large embedded tile / cell layout data (~file 0x80..~0x600)
;    - Main per-frame scan loop (loc_2..loc_85)
;    - Many sub_NN helpers for boss behaviour/scripting
;    - 'ashiin' speaker-name trailer + zero padding
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_13e	equ	200Ch			;*
data_14e	equ	2F2Eh			;*
data_15e	equ	302Fh			;*
data_16e	equ	6028h			;*
data_17e	equ	6036h			;*
data_18e	equ	6038h			;*
data_19e	equ	0A46Fh			;*
data_20e	equ	0A666h			;*
data_21e	equ	0A8A9h			;*
data_22e	equ	0A957h			;*
data_23e	equ	0A98Ah			;*
data_24e	equ	0A9DBh			;*
data_25e	equ	0AA71h			;*
data_26e	equ	0ABF9h			;*
data_27e	equ	0AC03h			;*
data_28e	equ	0AC05h			;*
data_29e	equ	0AC06h			;*
data_30e	equ	0AC1Bh			;*
data_31e	equ	0AC1Ch			;*
data_32e	equ	0AC1Dh			;*
data_33e	equ	0AC1Eh			;*
data_34e	equ	0AC1Fh			;*
data_35e	equ	0AC20h			;*
data_36e	equ	0AC21h			;*
data_37e	equ	0AC22h			;*
data_38e	equ	0AC23h			;*
data_39e	equ	0AC24h			;*
data_40e	equ	0AC25h			;*
data_41e	equ	0AC26h			;*
data_42e	equ	0AC28h			;*
data_43e	equ	0AC29h			;*
data_44e	equ	0AC2Ah			;*
data_45e	equ	0AC2Bh			;*
data_46e	equ	0AC2Ch			;*
data_47e	equ	0AC2Dh			;*
data_48e	equ	0AC2Eh			;*
data_49e	equ	0AC2Fh			;*
data_50e	equ	0AC30h			;*
data_51e	equ	0AC31h			;*
data_52e	equ	0AC32h			;*
data_53e	equ	0AC33h			;*
data_54e	equ	0AC34h			;*
data_55e	equ	0AC35h			;*
data_56e	equ	0AC36h			;*
data_57e	equ	0AC37h			;*
data_58e	equ	0AC38h			;*
data_59e	equ	0AC39h			;*
data_60e	equ	0AC41h			;*
data_61e	equ	0AC4Ah			;*
data_62e	equ	0AC65h			;*
data_63e	equ	0AC6Eh			;*
data_64e	equ	0AEADh			;*
data_65e	equ	0C002h			;*
data_66e	equ	0C010h			;*
data_67e	equ	0ED20h			;*
data_68e	equ	0FF21h			;*
data_69e	equ	0FF2Eh			;*
data_70e	equ	0FF2Fh			;*
data_71e	equ	0FF30h			;*
data_72e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_319MAPA6	proc	far

start:
		db	 6Fh, 0Ch, 00h, 00h
data_2		db	0F2h
		db	0A2h, 03h,0ACh
		db	12 dup (0)
		db	'PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP'
		db	'|'
data_5		db	0A0h
		db	0CCh,0A0h, 1Ch,0A1h, 6Ch,0A1h
		db	 8Fh,0A1h,0A8h,0A1h
		db	52 dup (0)
		db	0B7h,0A1h, 07h,0A2h, 57h,0A2h
		db	0A7h,0A2h,0CAh,0A2h,0E3h,0A2h
data_7		db	1
		db	1, 2
data_8		db	3
		db	 04h, 01h, 05h, 06h, 08h, 09h
		db	 01h, 00h, 07h, 0Ah, 0Bh, 01h
		db	 0Ch, 0Dh, 0Fh, 10h, 01h, 0Eh
		db	 0Fh, 11h, 12h, 01h, 12h, 13h
		db	 15h, 16h, 01h, 00h, 14h, 18h
		db	 19h, 01h, 16h, 17h, 18h, 1Bh
		db	 01h, 0Ch, 0Dh, 1Ch, 1Dh, 01h
		db	 1Eh, 1Fh, 20h, 21h, 01h, 20h
		db	 21h, 18h, 22h, 01h, 21h, 00h
		db	 22h, 23h, 01h, 05h, 06h,0F3h
		db	0F4h, 01h,0F7h,0F8h, 25h, 26h
		db	 01h, 27h, 28h, 2Ah, 2Bh, 01h
		db	 2Bh, 2Ch, 18h, 2Eh, 01h,0F5h
		db	0F6h, 00h, 24h, 01h, 11h, 27h
		db	 29h, 2Ah, 01h, 00h, 29h, 18h
		db	 2Dh, 01h,0F7h,0F8h, 30h, 31h
		db	 01h, 33h, 34h, 35h, 36h, 01h
		db	 35h, 36h, 37h, 38h, 01h, 00h
		db	 00h,0F5h,0F6h, 01h, 2Fh, 30h
		db	 32h, 33h, 01h, 0Ch, 70h, 72h
		db	 73h, 01h, 75h, 76h, 78h, 79h
		db	 01h, 71h, 72h, 74h, 75h, 01h
		db	 74h, 75h, 18h, 78h, 01h, 76h
		db	 00h, 79h, 7Ah, 01h, 0Ch, 0Dh
		db	 0Fh, 10h, 01h, 12h, 13h
		db	7Ch
data_9		dw	offset sub_1
		db	 7Dh, 00h, 7Eh, 00h, 01h, 13h
		db	 00h, 7Bh, 7Ch, 01h, 00h, 7Dh
		db	 00h, 7Eh, 01h, 0Eh, 0Fh, 11h
		db	 12h, 01h, 7Bh, 7Ch, 00h, 7Dh
		db	 01h, 75h, 1Ah, 7Dh, 7Dh, 01h
		db	 7Dh, 7Dh, 7Eh, 7Eh, 01h, 8Eh
		db	 06h, 08h, 09h, 01h, 00h, 8Dh
		db	 00h, 8Fh, 01h, 00h, 8Fh, 90h
		db	 91h, 01h, 96h, 06h, 08h, 09h
		db	 01h, 00h, 00h, 94h, 95h, 01h
		db	 00h, 00h, 92h, 93h, 01h, 00h
		db	 97h, 99h, 9Ah, 01h, 98h, 99h
		db	 9Bh, 9Ch, 01h, 0Ch, 0Dh,0B1h
		db	0B2h, 01h,0B1h,0B2h,0B4h,0B5h
		db	 01h,0B2h, 00h,0B5h,0B6h, 01h
		db	 00h, 07h,0ADh,0AEh, 01h

_319MAPA6	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		scasw				; Scan es:[di] for ax
		mov	al,18h
		mov	bl,1
		add	ds:data_64e[bx],cl
		add	[bx+si],ax
		add	data_10[di],ch
		cwd				; Word to double word
;*		calls	far ptr sub_10		;*
		db	9Ah
		dw	0AEB7h, 9801h		;  Fixup - byte match
		cwd				; Word to double word
		db	 9Bh,0B7h, 01h,0C3h,0C4h,0C5h
		db	0C6h, 01h,0CBh,0CCh,0CDh,0CEh
		db	 01h,0CFh,0D0h,0D1h,0D2h, 01h
		db	0D3h,0D4h,0D5h,0D6h, 01h,0D7h
		db	0D8h,0D9h,0DAh, 00h,0DBh
data_10		db	0DCh			; Data table (indexed access)
		db	0DDh,0DEh, 00h,0DFh,0E0h,0E1h
		db	0E2h, 00h,0E3h,0E4h,0E5h,0E6h
		db	 01h, 39h, 3Ah, 3Bh, 3Ch, 01h
		db	 3Dh, 3Eh, 3Fh, 40h, 01h, 41h
		db	 00h, 44h, 45h, 01h, 42h, 43h
		db	 46h, 47h, 01h, 49h, 4Ah, 4Dh
		db	 4Eh, 01h, 4Ch, 4Dh, 50h, 51h
		db	 01h, 47h, 48h, 4Ah, 4Bh, 01h
		db	 4Fh, 00h, 52h, 51h, 01h, 42h
		db	 43h, 53h, 54h, 01h, 55h, 56h
		db	 57h, 58h, 01h, 57h, 58h, 5Ah
		db	 51h, 01h, 00h, 57h, 59h, 5Ah
		db	 01h, 3Dh, 3Eh,0F9h,0FAh, 01h
		db	0FBh,0FCh, 5Bh, 5Ch, 01h, 5Eh
		db	 5Fh, 61h, 62h, 01h, 60h, 61h
		db	 64h, 51h, 01h,0FDh,0FEh, 5Dh
		db	 00h, 01h, 5Fh, 4Bh, 62h, 63h
		db	 01h, 63h, 00h, 65h, 51h, 01h
		db	0FBh,0FCh, 66h, 67h, 01h, 69h
		db	 6Ah, 6Ch, 6Dh, 01h, 6Ch, 6Dh
		db	 6Eh, 6Fh, 01h, 00h, 00h,0FDh
		db	0FEh, 01h, 67h, 68h, 6Ah, 6Bh
		db	 01h, 7Fh, 43h, 80h, 81h, 01h
		db	 83h, 84h, 87h, 88h, 01h, 81h
		db	 82h, 84h, 85h, 01h, 84h, 85h
		db	 88h, 51h, 01h, 00h, 83h, 86h
		db	 87h, 01h, 42h, 43h, 46h, 47h
		db	 01h, 49h, 4Ah, 8Ah, 89h, 01h
		db	 00h, 8Bh, 00h, 8Ch, 01h, 47h
		db	 48h, 4Ah, 4Bh, 01h, 89h, 8Ah
		db	 8Bh, 00h, 01h, 00h, 49h, 89h
		db	 8Ah, 01h, 8Bh, 00h, 8Ch, 00h
		db	 01h, 77h, 84h, 8Bh, 8Bh, 01h
		db	 8Bh, 8Bh, 8Ch, 8Ch, 01h, 3Dh
		db	 9Dh, 3Fh, 40h, 01h, 9Eh, 00h
		db	 9Fh, 00h, 01h, 9Fh, 00h,0A0h
		db	0A1h, 01h, 3Dh,0A2h, 3Fh, 40h
		db	 01h, 00h, 00h,0A3h,0A4h, 01h
		db	 00h, 00h,0A5h,0A6h, 01h,0A7h
		db	 00h,0A8h,0A9h, 01h,0A9h,0AAh
		db	0ABh,0ACh, 01h, 42h, 43h,0BAh
		db	0BBh, 01h,0BAh,0BBh,0BFh,0C0h
		db	 01h, 00h,0BAh,0BEh,0BFh, 01h
		db	 41h, 00h,0B8h,0B9h, 01h,0BCh
		db	0BDh,0C1h, 51h, 01h, 9Fh, 00h
		db	0B8h,0B9h, 01h, 00h, 00h,0B8h
		db	0B9h, 01h,0A8h,0A9h,0B8h,0C2h
		db	 01h,0A9h,0AAh,0C2h,0ACh, 01h
		db	0C7h,0C8h,0C9h,0CAh, 01h,0CBh
		db	0CCh,0CDh,0CEh, 01h,0CFh,0D0h
		db	0D1h,0D2h, 01h,0D3h,0D4h,0D5h
		db	0D6h, 01h,0D7h,0D8h,0D9h,0DAh
		db	 00h,0E7h,0E8h,0E9h,0EAh, 00h
		db	0EBh,0ECh,0EDh,0EEh, 00h,0EFh
		db	0F0h,0F1h,0F2h, 8Bh, 36h, 10h
		db	0C0h,0C6h, 06h, 1Dh,0ACh, 00h
		db	0C6h, 06h, 1Ch,0ACh, 00h
loc_1:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jz	loc_4			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:data_17e
		jc	loc_3			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:data_16e
		mov	bl,ds:data_31e
		xor	bh,bh			; Zero register
		mov	al,ds:data_67e[bx]
		mov	[di],al
		test	byte ptr ds:data_32e,80h
		jnz	loc_3			; Jump if not zero
		test	byte ptr [si+5],40h	; '@'
		jz	loc_3			; Jump if zero
		mov	al,[si+5]
		and	al,1Fh
		test	byte ptr [si+4],1Fh
		jnz	loc_2			; Jump if not zero
		test	byte ptr [si+6],0Fh
		jnz	loc_2			; Jump if not zero
		or	al,80h
loc_2:
		mov	ds:data_32e,al
loc_3:
		inc	byte ptr ds:data_31e
		add	si,10h
		jmp	short loc_1
loc_4:
		mov	si,ds:data_66e
		mov	word ptr [si],0FFFFh
		mov	ds:data_41e,si
		mov	byte ptr ds:data_31e,0
		test	byte ptr ds:data_32e,0FFh
		jz	loc_6			; Jump if zero
		mov	al,ds:data_32e
		and	al,1Fh
		push	ax
		call	word ptr cs:data_18e
		mov	bl,ah
		pop	ax
		xor	bh,bh			; Zero register
		shr	bx,1			; Shift w/zeros fill
		cmp	al,1
		je	loc_5			; Jump if equal
		shr	bx,1			; Shift w/zeros fill
loc_5:
		call	sub_8
		mov	byte ptr ds:data_72e,39h	; '9'
		cmp	word ptr ds:data_29e,0C8h
		jae	loc_6			; Jump if above or =
		mov	byte ptr ds:data_52e,0FFh
loc_6:
		test	byte ptr ds:data_69e,0FFh
		jz	loc_7			; Jump if zero
		jmp	loc_85
loc_7:
		test	byte ptr ds:data_36e,0FFh
		jnz	loc_9			; Jump if not zero
		test	byte ptr ds:data_68e,0FFh
		jnz	loc_8			; Jump if not zero
		retn
loc_8:
		mov	byte ptr ds:data_36e,0FFh
		retn
loc_9:
		test	byte ptr ds:data_52e,0FFh
		jz	loc_10			; Jump if zero
		jmp	loc_24
loc_10:
		test	byte ptr ds:data_38e,0FFh
		jnz	loc_13			; Jump if not zero
		test	byte ptr ds:data_42e,0FFh
		jz	loc_11			; Jump if zero
		jmp	loc_62
loc_11:
		test	byte ptr ds:data_47e,0FFh
		jz	loc_12			; Jump if zero
		jmp	loc_62
loc_12:
		call	sub_2
		mov	byte ptr ds:data_40e,0
		mov	byte ptr ds:data_38e,0FFh
		call	word ptr cs:data_9
		rol	al,1			; Rotate
		and	al,1
		mov	ds:data_39e,al
loc_13:
		inc	byte ptr ds:data_40e
		mov	al,ds:data_40e
		cmp	al,6
		jae	loc_15			; Jump if above or =
		shr	al,1			; Shift w/zeros fill
		jnc	loc_14			; Jump if carry=0
		jmp	loc_62
loc_14:
		mov	byte ptr ds:data_72e,3Bh	; ';'
		mov	byte ptr ds:data_37e,60h	; '`'
		mov	al,ds:data_39e
		mov	cl,0Ah
		mul	cl			; ax = reg * al
		mov	ds:data_30e,al
		jmp	loc_51
loc_15:
		cmp	al,0Bh
		jae	loc_18			; Jump if above or =
		sub	al,6
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	al,ds:data_39e
		mov	ah,al
		add	al,al
		add	al,al
		add	al,ah
		add	bx,data_19e
		xlat				; al=[al+[bx]] table
		mov	ds:data_30e,al
		mov	byte ptr ds:data_37e,0
		cmp	al,9
		jne	loc_16			; Jump if not equal
		call	sub_5
loc_16:
		cmp	al,0Ch
		jne	loc_17			; Jump if not equal
		call	sub_6
loc_17:
		jmp	loc_51
loc_18:
		cmp	al,11h
		jae	loc_20			; Jump if above or =
		shr	al,1			; Shift w/zeros fill
		jnc	loc_19			; Jump if carry=0
		jmp	loc_62
loc_19:
		mov	byte ptr ds:data_72e,3Bh	; ';'
		mov	byte ptr ds:data_37e,60h	; '`'
		jmp	loc_51
loc_20:
		mov	byte ptr ds:data_38e,0
		jmp	loc_62
		db	 00h, 00h, 07h, 07h, 09h, 0Ah
		db	 0Ah, 0Bh, 0Bh
		db	0Ch

;���� External Entry into Subroutine ��������������������������������������

sub_2:
		mov	byte ptr ds:data_28e,9
		call	word ptr cs:data_9
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		mov	ds:data_33e,al
		not	al
		and	al,14h
		add	al,data_7
		add	al,4
		cmp	al,ds:data_65e
		jb	loc_21			; Jump if below
		sub	al,ds:data_65e
loc_21:
		mov	ds:data_27e,al
		cmp	al,10h
		jb	loc_22			; Jump if below
		cmp	al,35h			; '5'
		jae	loc_22			; Jump if above or =
		retn
loc_22:
		not	byte ptr ds:data_33e
		mov	al,ds:data_33e
		not	al
		and	al,14h
		add	al,data_7
		add	al,4
		cmp	al,ds:data_65e
		jb	loc_23			; Jump if below
		sub	al,ds:data_65e
loc_23:
		mov	ds:data_27e,al
		retn
loc_24:
		inc	byte ptr ds:data_58e
		test	byte ptr ds:data_58e,1Fh
		jnz	loc_25			; Jump if not zero
		call	sub_9
loc_25:
		test	byte ptr ds:data_53e,0FFh
		jz	loc_26			; Jump if zero
		jmp	loc_46
loc_26:
		test	byte ptr ds:data_56e,0FFh
		jz	loc_27			; Jump if zero
		jmp	loc_44
loc_27:
		test	byte ptr ds:data_42e,0FFh
		jz	loc_28			; Jump if zero
		jmp	loc_51
loc_28:
		mov	al,data_7
		add	al,data_8
		add	al,3
		cmp	al,ds:data_65e
		jb	loc_29			; Jump if below
		sub	al,ds:data_65e
loc_29:
		xor	cl,cl			; Zero register
		cmp	ds:data_27e,al
		jae	loc_30			; Jump if above or =
		mov	cl,0FFh
loc_30:
		mov	ds:data_33e,cl
		or	cl,cl			; Zero ?
		jnz	loc_37			; Jump if not zero
		mov	ah,ds:data_27e
		sub	ah,al
		and	ah,0FEh
		cmp	ah,8
		jne	loc_31			; Jump if not equal
		jmp	loc_41
loc_31:
		jnc	loc_34			; Jump if carry=0
		dec	byte ptr ds:data_30e
		and	byte ptr ds:data_30e,3
		test	byte ptr ds:data_30e,1
		jnz	loc_32			; Jump if not zero
		call	sub_4
loc_32:
		call	sub_4
		jc	loc_33			; Jump if carry Set
		jmp	loc_43
loc_33:
		mov	byte ptr ds:data_54e,0
		mov	byte ptr ds:data_53e,0FFh
		jmp	short loc_41
loc_34:
		inc	byte ptr ds:data_30e
		and	byte ptr ds:data_30e,3
		test	byte ptr ds:data_30e,1
		jz	loc_35			; Jump if zero
		call	sub_3
loc_35:
		call	sub_3
		jc	loc_36			; Jump if carry Set
		jmp	loc_43
loc_36:
		mov	byte ptr ds:data_54e,0
		mov	byte ptr ds:data_53e,0FFh
		jmp	short loc_41
loc_37:
		sub	al,ds:data_27e
		and	al,0FEh
		cmp	al,8
		je	loc_41			; Jump if equal
		jnc	loc_39			; Jump if carry=0
		dec	byte ptr ds:data_30e
		and	byte ptr ds:data_30e,3
		test	byte ptr ds:data_30e,1
		jnz	loc_38			; Jump if not zero
		call	sub_3
loc_38:
		call	sub_3
		jnc	loc_43			; Jump if carry=0
		mov	byte ptr ds:data_54e,0
		mov	byte ptr ds:data_53e,0FFh
		jmp	short loc_41
loc_39:
		inc	byte ptr ds:data_30e
		and	byte ptr ds:data_30e,3
		test	byte ptr ds:data_30e,1
		jz	loc_40			; Jump if zero
		call	sub_4
loc_40:
		call	sub_4
		jnc	loc_43			; Jump if carry=0
		mov	byte ptr ds:data_54e,0
		mov	byte ptr ds:data_53e,0FFh
loc_41:
		mov	al,ds:data_55e
		mov	byte ptr ds:data_55e,0FFh
		or	al,al			; Zero ?
		jnz	loc_42			; Jump if not zero
		jmp	loc_51
loc_42:
		and	byte ptr ds:data_30e,0FEh
		call	word ptr cs:data_9
		and	al,0Fh
		jnz	loc_43			; Jump if not zero
		mov	byte ptr ds:data_57e,0
		mov	byte ptr ds:data_56e,0FFh
loc_43:
		jmp	loc_51
loc_44:
		mov	al,ds:data_57e
		inc	byte ptr ds:data_57e
		mov	bx,data_19e
		xlat				; al=[al+[bx]] table
		mov	ds:data_30e,al
		cmp	al,9
		je	loc_45			; Jump if equal
		jmp	loc_51
loc_45:
		mov	byte ptr ds:data_56e,0
		call	sub_5
		jmp	loc_51
loc_46:
		mov	bl,ds:data_54e
		add	bl,bl
		add	bl,ds:data_54e
		xor	bh,bh			; Zero register
		add	bx,data_20e
		mov	al,[bx]
		push	bx
		or	al,al			; Zero ?
		jz	loc_48			; Jump if zero
		test	byte ptr ds:data_33e,0FFh
		jnz	loc_47			; Jump if not zero
		call	sub_3
		call	sub_3
		jmp	short loc_48
loc_47:
		call	sub_4
		call	sub_4
loc_48:
		pop	bx
		mov	al,ds:data_28e
		add	al,[bx+1]
		and	al,3Fh			; '?'
		mov	ds:data_28e,al
		mov	al,[bx+2]
		mov	ds:data_30e,al
		inc	byte ptr ds:data_54e
		cmp	byte ptr [bx+3],80h
		jne	loc_51			; Jump if not equal
		mov	byte ptr ds:data_53e,0
		jmp	short loc_51
		db	 00h, 00h, 04h, 00h, 00h, 04h
		db	 00h,0FEh, 05h, 01h,0FEh, 05h
		db	 01h,0FEh, 05h, 01h, 00h, 06h
		db	 01h, 00h, 06h, 01h, 00h, 06h
		db	 01h, 02h, 06h, 01h, 02h, 06h
		db	 01h, 02h, 06h, 00h, 00h, 04h
		db	 00h, 00h, 04h, 00h, 00h, 00h
		db	 80h

;���� External Entry into Subroutine ��������������������������������������

sub_3:
		mov	ax,ds:data_27e
		dec	ax
		mov	bx,0Eh
		sub	bx,ax
		cmc				; Complement carry
		jnc	loc_49			; Jump if carry=0
		retn
loc_49:
		mov	ds:data_27e,ax
		mov	byte ptr ds:data_55e,0
		retn

;���� External Entry into Subroutine ��������������������������������������

sub_4:
		mov	ax,ds:data_27e
		inc	ax
		mov	bx,offset data_5
		sub	bx,ax
		jnc	loc_50			; Jump if carry=0
		retn
loc_50:
		mov	ds:data_27e,ax
		mov	byte ptr ds:data_55e,0
		retn
loc_51:
		push	cs
		pop	es
		mov	di,data_59e
		mov	al,0FFh
		mov	cx,36h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	di,0A9E4h
		mov	si,0AAE1h
		test	byte ptr ds:data_33e,0FFh
		jnz	loc_52			; Jump if not zero
		mov	di,data_22e
		mov	si,data_25e
loc_52:
		mov	bl,ds:data_30e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	di,[bx+di]
		mov	bp,[bx+si]
		call	sub_7
		cmp	byte ptr ds:data_30e,5
		jne	loc_54			; Jump if not equal
		test	byte ptr ds:data_33e,0FFh
		jz	loc_53			; Jump if zero
		mov	byte ptr ds:data_60e,23h	; '#'
		mov	byte ptr ds:data_61e,1Fh
		jmp	short loc_54
loc_53:
		mov	byte ptr ds:data_62e,1Fh
		mov	byte ptr ds:data_63e,21h	; '!'
loc_54:
		mov	ax,ds:data_27e
		mov	si,ds:data_41e
		mov	di,data_59e
		mov	cx,6
loc_55:
		push	cx
		push	di
		push	ax
		call	word ptr cs:data_17e
		pop	ax
		mov	ds:data_34e,bl
		jc	loc_59			; Jump if carry Set
		xor	cl,cl			; Zero register
loc_56:
		push	cx
		push	ax
		cmp	byte ptr [di],0FFh
		je	loc_58			; Jump if equal
		mov	[si],ax
		add	cl,ds:data_28e
		and	cl,3Fh			; '?'
		mov	[si+2],cl
		mov	al,ds:data_34e
		mov	[si+3],al
		mov	al,[di]
		mov	ah,al
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		or	al,ds:data_37e
		mov	[si+4],al
		mov	[si+6],ah
		mov	al,ds:data_33e
		and	al,80h
		mov	[si+5],al
		test	byte ptr ds:data_32e,0FFh
		jz	loc_57			; Jump if zero
		or	byte ptr [si+5],20h	; ' '
loc_57:
		push	di
		mov	ax,[si+2]
		call	word ptr cs:data_16e
		mov	bl,ds:data_31e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_67e[bx],al
		pop	di
		add	si,10h
		inc	byte ptr ds:data_31e
loc_58:
		inc	di
		pop	ax
		pop	cx
		inc	cl
		cmp	cl,9
		jne	loc_56			; Jump if not equal
loc_59:
		inc	ax
		pop	di
		add	di,9
		pop	cx
		loop	locloop_60		; Loop if cx > 0

		jmp	short loc_61

locloop_60:
		jmp	loc_55
loc_61:
		mov	ds:data_41e,si
		mov	word ptr [si],0FFFFh
loc_62:
		test	byte ptr ds:data_42e,0FFh
		jnz	loc_63			; Jump if not zero
		jmp	loc_69
loc_63:
		mov	si,ds:data_41e
		cmp	byte ptr ds:data_46e,9
		jae	loc_66			; Jump if above or =
		cmp	byte ptr ds:data_46e,3
		jae	loc_64			; Jump if above or =
		inc	byte ptr ds:data_44e
		and	byte ptr ds:data_44e,3Fh	; '?'
loc_64:
		mov	al,ds:data_43e
		inc	al
		test	byte ptr ds:data_45e,0FFh
		jnz	loc_65			; Jump if not zero
		dec	al
		dec	al
loc_65:
		mov	ds:data_43e,al
loc_66:
		mov	al,ds:data_43e
		xor	ah,ah			; Zero register
		push	ax
		call	word ptr cs:data_17e
		pop	ax
		jc	loc_68			; Jump if carry Set
		mov	[si],ax
		mov	al,ds:data_44e
		mov	[si+2],al
		mov	[si+3],bl
		mov	byte ptr [si+4],24h	; '$'
		xor	al,al			; Zero register
		mov	ah,ds:data_46e
		cmp	ah,3
		jb	loc_67			; Jump if below
		and	ah,3
		inc	ah
		mov	al,ah
loc_67:
		mov	[si+6],al
		mov	al,ds:data_45e
		and	al,80h
		mov	[si+5],al
		mov	ax,[si+2]
		call	word ptr cs:data_16e
		mov	bl,ds:data_31e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_67e[bx],al
		add	si,10h
		inc	byte ptr ds:data_31e
loc_68:
		mov	word ptr [si],0FFFFh
		inc	byte ptr ds:data_46e
		cmp	byte ptr ds:data_46e,0Bh
		jb	loc_69			; Jump if below
		mov	byte ptr ds:data_42e,0
loc_69:
		test	byte ptr ds:data_47e,0FFh
		jnz	loc_70			; Jump if not zero
		retn
loc_70:
		xor	dl,dl			; Zero register
		cmp	byte ptr ds:data_51e,3
		jae	loc_71			; Jump if above or =
		inc	byte ptr ds:data_49e
		and	byte ptr ds:data_49e,3Fh	; '?'
		mov	dl,2
loc_71:
		mov	al,ds:data_48e
		inc	al
		test	byte ptr ds:data_50e,0FFh
		jnz	loc_72			; Jump if not zero
		dec	al
		dec	al
loc_72:
		mov	ds:data_48e,al
		xor	ah,ah			; Zero register
		push	dx
		push	ax
		call	word ptr cs:data_17e
		pop	ax
		pop	dx
		jc	loc_73			; Jump if carry Set
		mov	[si],ax
		mov	al,ds:data_49e
		mov	[si+2],al
		mov	[si+3],bl
		mov	byte ptr [si+4],25h	; '%'
		mov	[si+6],dl
		mov	al,ds:data_50e
		and	al,80h
		mov	[si+5],al
		mov	ax,[si+2]
		call	word ptr cs:data_16e
		mov	bl,ds:data_31e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_67e[bx],al
		add	si,10h
		inc	byte ptr ds:data_31e
loc_73:
		mov	word ptr [si],0FFFFh
		inc	byte ptr ds:data_51e
		cmp	byte ptr ds:data_48e,10h
		jb	loc_74			; Jump if below
		cmp	byte ptr ds:data_48e,39h	; '9'
		jae	loc_74			; Jump if above or =
		retn
loc_74:
		mov	byte ptr ds:data_47e,0
		retn
sub_1		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_5		proc	near
		mov	byte ptr ds:data_46e,0
		mov	byte ptr ds:data_42e,0FFh
		mov	al,ds:data_33e
		mov	ds:data_45e,al
		and	al,5
		add	al,ds:data_27e
		mov	ds:data_43e,al
		mov	al,ds:data_28e
		add	al,4
		and	al,3Fh			; '?'
		mov	ds:data_44e,al
		mov	byte ptr ds:data_72e,3Ah	; ':'
		retn
sub_5		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_6		proc	near
		mov	byte ptr ds:data_51e,0
		mov	byte ptr ds:data_47e,0FFh
		mov	al,ds:data_33e
		mov	ds:data_50e,al
		and	al,8
		add	al,ds:data_27e
		dec	al
		mov	ds:data_48e,al
		mov	al,ds:data_28e
		add	al,4
		and	al,3Fh			; '?'
		mov	ds:data_49e,al
		mov	byte ptr ds:data_72e,3Ah	; ':'
		retn
sub_6		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_7		proc	near
		mov	si,data_59e
		mov	cx,6

locloop_77:
		push	cx
		mov	cx,8

locloop_78:
		rol	byte ptr ds:[bp],1	; Rotate
		jnc	loc_79			; Jump if carry=0
		mov	al,[di]
		mov	[si],al
		inc	di
loc_79:
		inc	si
		loop	locloop_78		; Loop if cx > 0

		inc	bp
		inc	si
		pop	cx
		loop	locloop_77		; Loop if cx > 0

		retn
sub_7		endp

			                        ;* No entry point to code
;*		jnc	loc_75			;*Jump if carry=0
		db	 73h,0A9h		;  Fixup - byte match
;*		jnp	loc_76			;*Jump if not parity
		db	 7Bh,0A9h		;  Fixup - byte match
;*		sub	byte ptr ds:data_23e[bx+di],91h
		db	 82h,0A9h, 8Ah,0A9h, 91h	;  Fixup - byte match
		test	ax,0A999h
		mov	ax,ds:data_21e
		test	ax,0A9B1h
		mov	dx,0C3A9h
		test	ax,0A9CAh
		shr	byte ptr ds:data_24e[bx+di],cl	; Shift w/zeros fill
		add	al,data_2
		add	[bp+di],ax
		add	ax,207h
		add	[bx+di],al
		or	[bx+di],cl
		or	cl,[bp+di]
		adc	[bp+si],dl
		adc	[bx+si],ax
		or	al,0Dh
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		push	ss
		pop	ss
		add	[si],cl
		adc	dx,[si]
		adc	ax,1A02h
		sbb	ax,[bx+si]
		add	[bx+si],bx
		sbb	[si],bx
		add	ah,[bp+si]
		and	ax,[bx+si]
		add	[di],bx
		push	ds
		and	[bp+si],al
		sbb	al,[bx+si]
		add	[bx+si],bx
		and	al,25h			; '%'
		daa				; Decimal adjust
		sub	data_2,al
		add	ax,es:[di]
		pop	es
		sub	bp,[bp+si]
		push	es
		add	al,0
		sub	[bp+di],ax
		add	ax,2D07h
		sub	al,6
		add	al,0
		sub	[bp+di],ax
		add	ax,3107h
		xor	al,[bx+si]
		add	ds:data_15e,bp
		daa				; Decimal adjust
		xor	si,[bp+si]
		add	ds:data_14e,ah
		xor	[bp+di],ch
		sub	dh,[si]
		xor	al,[bx+si]
		sub	ds:data_15e,bp
		db	 36h, 2Ch, 35h, 32h, 00h, 29h
		db	 2Eh, 2Fh, 30h, 00h,0AAh, 08h
		db	0AAh, 0Fh,0AAh, 17h,0AAh, 1Eh
		db	0AAh, 26h,0AAh, 2Eh,0AAh, 35h
		db	0AAh, 3Eh,0AAh, 47h,0AAh, 50h
		db	0AAh, 57h,0AAh, 5Fh,0AAh, 68h
		db	0AAh, 05h, 00h, 01h, 03h, 04h
		db	 06h, 02h, 07h, 0Bh, 00h, 01h
		db	 08h, 09h, 0Ah, 02h, 0Fh, 00h
		db	 0Ch, 0Dh, 0Eh, 11h, 10h, 12h
		db	 00h, 0Ch, 13h, 14h, 15h, 17h
		db	 16h, 1Ch, 00h, 01h, 18h, 19h
		db	 1Ah, 1Bh, 02h, 22h, 00h, 01h
		db	 1Dh, 1Eh, 20h, 21h, 02h, 00h
		db	 01h, 18h, 24h, 25h, 1Ah, 02h
		db	 05h, 00h, 26h, 03h, 04h, 06h
		db	 27h, 28h, 07h, 05h, 00h, 29h
		db	 03h, 04h, 06h, 2Ah, 07h, 2Bh
		db	 05h, 00h, 29h, 03h, 04h, 06h
		db	 2Ch, 07h, 2Dh, 30h, 00h, 01h
		db	 2Eh, 2Fh, 31h, 32h, 30h, 00h
		db	 26h, 2Eh, 2Fh, 27h, 33h, 32h
		db	 30h, 00h
		db	')./*42+0'
		db	 00h, 29h, 2Eh, 2Fh, 2Ch, 35h
		db	 32h, 36h, 8Dh,0AAh, 93h,0AAh
		db	 99h,0AAh, 9Fh,0AAh,0A5h,0AAh
		db	0ABh,0AAh,0B1h,0AAh,0B7h,0AAh
		db	0BDh,0AAh,0C3h,0AAh,0C9h,0AAh
		db	0CFh,0AAh,0D5h,0AAh,0DBh,0AAh
		db	 00h, 00h, 11h, 04h,0AAh, 01h
		db	 00h, 00h, 10h, 00h,0ABh, 01h
		db	 00h, 00h, 09h, 02h,0AAh, 01h
		db	 00h, 00h, 10h, 04h,0ABh, 00h
		db	 00h, 00h, 08h, 03h, 55h, 01h
		db	 00h, 00h, 10h, 05h,0AAh, 02h
		db	 00h, 00h, 10h, 04h,0ABh, 00h
		db	 00h, 00h, 31h, 04h,0AAh, 01h
		db	 40h, 00h, 41h, 04h,0AAh, 01h
		db	 00h, 10h, 21h, 04h,0AAh, 01h
		db	 00h, 00h, 05h, 00h, 2Bh, 01h
		db	 00h, 00h, 0Dh, 00h, 2Bh, 01h
		db	 10h, 00h, 15h, 00h, 2Bh, 01h
		db	 00h, 04h, 0Dh, 00h, 2Bh, 01h
		db	0FDh,0AAh, 03h,0ABh, 09h,0ABh
		db	 0Fh,0ABh, 15h,0ABh, 1Bh,0ABh
		db	 21h,0ABh, 27h,0ABh, 2Dh,0ABh
		db	 33h,0ABh, 39h,0ABh, 3Fh,0ABh
		db	 45h,0ABh, 4Bh,0ABh, 01h,0AAh
		db	 04h, 11h, 00h, 00h, 01h,0ABh
		db	 00h, 10h, 00h, 00h, 01h,0AAh
		db	 02h, 09h, 00h, 00h, 00h,0ABh
		db	 04h, 10h, 00h, 00h, 01h, 55h
		db	 03h, 08h, 00h, 00h, 02h,0AAh
		db	 05h, 10h, 00h, 00h, 00h,0ABh
		db	 04h, 10h, 00h, 00h, 01h,0AAh
		db	 04h, 31h, 00h, 00h, 01h,0AAh
		db	 04h, 41h, 00h, 40h, 01h,0AAh
		db	 04h, 21h, 10h, 00h, 01h, 2Bh
		db	 00h, 05h, 00h, 00h, 01h, 2Bh
		db	 00h, 0Dh, 00h, 00h, 01h, 2Bh
		db	 00h, 15h, 00h, 10h, 01h, 2Bh
		db	 00h, 0Dh, 04h, 00h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_8		proc	near
		mov	ax,ds:data_29e
		sub	ax,bx
		jnc	loc_80			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_80:
		mov	ds:data_29e,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:data_13e
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_81			; Jump if zero
		retn
loc_81:
		test	byte ptr ds:data_69e,0FFh
		jz	loc_82			; Jump if zero
		retn
loc_82:
		mov	byte ptr ds:data_35e,0
		mov	byte ptr ds:data_42e,0
		mov	byte ptr ds:data_47e,0
		mov	byte ptr ds:data_69e,0FFh
		retn
sub_8		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_9		proc	near
		cmp	word ptr ds:data_29e,320h
		jne	loc_83			; Jump if not equal
		retn
loc_83:
		mov	bx,ds:data_29e
		add	bx,50h
		mov	ax,320h
		cmp	ax,bx
		jae	loc_84			; Jump if above or =
		mov	bx,320h
		mov	byte ptr ds:data_52e,0
		mov	byte ptr ds:data_40e,0Ah
		mov	byte ptr ds:data_38e,0FFh
		mov	byte ptr ds:data_37e,60h	; '`'
loc_84:
		mov	ds:data_29e,bx
		mov	byte ptr ds:data_72e,3Ch	; '<'
		jmp	word ptr cs:data_13e
sub_9		endp

loc_85:
		mov	al,ds:data_35e
		cmp	al,28h			; '('
		jae	loc_88			; Jump if above or =
		test	byte ptr ds:data_35e,7
		jnz	loc_86			; Jump if not zero
		mov	byte ptr ds:data_72e,23h	; '#'
loc_86:
		mov	byte ptr ds:data_70e,0FFh
		inc	byte ptr ds:data_35e
		cmp	al,14h
		jb	loc_87			; Jump if below
		jmp	loc_51
loc_87:
		shr	al,1			; Shift w/zeros fill
		mov	bx,data_26e
		xlat				; al=[al+[bx]] table
		mov	ds:data_30e,al
		jmp	loc_51
loc_88:
		mov	byte ptr ds:data_71e,0FFh
		retn
			                        ;* No entry point to code
		or	[bx+si],cl
		or	[si],cl
		or	al,0Ch
		or	ax,0B0Dh
		or	si,[bx+si]
		add	[bx+di],cl
		and	[bp+di],al
		adc	[bx],ah
		or	al,0
;*		adc	byte ptr ds:[0][si],ch
		db	 10h,0ACh, 00h, 00h	;  Fixup - byte match
		adc	word ptr ss:[702h][bp+di],di
		dec	dx
		db	 61h, 73h, 68h, 69h, 69h, 6Eh
		db	84 dup (0)

seg_a		ends



		end	start
