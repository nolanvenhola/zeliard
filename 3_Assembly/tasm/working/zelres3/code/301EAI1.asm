
PAGE  59,132

;��������������������������������������������������������������������������
;��					                                 ��
;��				_301MAPCA                                ��
;��					                                 ��
;��      Created:   5-Apr-26		                                 ��
;��      Code type: zero start		                                 ��
;��      Passes:    9          Analysis	Options on: none                 ��
;��					                                 ��
;��������������������������������������������������������������������������

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_11e	equ	6004h			;*
data_12e	equ	6006h			;*
data_13e	equ	6008h			;*
data_14e	equ	600Ah			;*
data_15e	equ	600Ch			;*
data_16e	equ	600Eh			;*
data_17e	equ	6010h			;*
data_18e	equ	6012h			;*
data_19e	equ	6014h			;*
data_20e	equ	6016h			;*
data_21e	equ	6018h			;*
data_22e	equ	601Ah			;*
data_23e	equ	6028h			;*
data_24e	equ	602Ah			;*
data_25e	equ	602Eh			;*
data_26e	equ	6030h			;*
data_27e	equ	6032h			;*
data_28e	equ	6034h			;*
data_29e	equ	0A29Dh			;*
data_30e	equ	0A2D0h			;*
data_31e	equ	0A723h			;*
data_32e	equ	0A72Fh			;*
data_33e	equ	0FF2Eh			;*
data_34e	equ	0FF35h			;*
data_35e	equ	0FF36h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_301MAPCA	proc	far

start:
		aaa				; Ascii adjust
		pop	es
		add	[bx+si],al
		push	sp
		mov	byte ptr ds:[0],al
		add	[bx+si],al
		inc	ax
		mov	data_10,al
		add	ax,3
		add	[bx+si],al
		add	[di],al
		add	ax,80Fh
		db	28 dup (0)
		db	0B0h,0A0h,0F6h,0A0h, 1Eh,0A1h
		db	 64h,0A1h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0A0h,0A1h
		db	0AFh,0A1h,0BEh,0A1h,0CDh,0A1h
		db	8 dup (0)
		db	 2Ch,0A2h, 2Ch,0A2h,0DCh,0A1h
		db	 13h,0A2h,0EBh,0A1h,0FFh,0A1h
		db	 1Dh,0A2h, 00h, 00h, 22h,0A2h
		db	 27h,0A2h
		db	12 dup (0)
		db	0D3h,0A0h, 0Ah,0A1h, 41h,0A1h
		db	 82h,0A1h
		db	8 dup (0)
		db	0A0h,0A1h,0AFh,0A1h,0BEh,0A1h
		db	0CDh,0A1h
		db	8 dup (0)
		db	 2Ch,0A2h, 2Ch,0A2h,0DCh,0A1h
		db	 13h,0A2h,0EBh,0A1h,0FFh,0A1h
		db	 1Dh,0A2h, 00h, 00h, 22h,0A2h
		db	 27h,0A2h
		db	13 dup (0)
		db	 19h, 1Ah, 1Bh, 1Ch, 00h, 1Dh
		db	 1Eh, 1Fh, 20h, 00h, 21h, 22h
		db	 23h, 24h, 00h, 25h, 26h, 27h
		db	 28h, 00h, 29h, 2Ah, 2Bh, 2Ch
		db	 00h, 2Dh, 2Eh, 2Fh, 30h, 00h
		db	 31h, 32h, 33h, 34h, 00h, 19h
		db	 1Ah, 1Bh, 1Ch, 00h
		db	'5678', 0
		db	'9:;<', 0
		db	'=>?@', 0
		db	'ABCD', 0
		db	'EFGH', 0
		db	'IJKL', 0
		db	'M', 0
		db	'OP', 0
		db	'Q', 0
		db	'RS', 0
		db	'TUOP', 0
		db	'VWXY'
		db	 00h, 00h, 5Bh, 5Ch, 5Dh, 00h
		db	 00h, 5Eh, 5Fh, 60h, 00h
		db	61h
data_9		dw	5C62h
		db	 5Dh, 00h, 63h, 64h, 65h, 66h
		db	 00h, 75h, 76h, 77h, 78h, 00h
		db	 75h, 76h, 79h, 78h, 00h, 7Ah
		db	 7Bh, 7Ch, 7Dh, 00h, 7Eh, 7Bh
		db	 7Fh, 80h, 00h, 81h, 82h, 83h
		db	 84h, 00h, 85h, 86h, 87h, 88h
		db	 00h, 89h, 8Ah, 8Bh, 8Ch, 00h
		db	 8Dh, 8Eh, 8Fh, 90h, 00h, 8Dh
		db	 8Eh, 8Fh, 91h, 00h, 92h, 93h
		db	 94h, 95h, 00h, 92h, 96h, 97h
		db	 98h, 00h, 99h, 9Ah, 9Bh, 9Ch
		db	 00h, 9Dh, 9Eh, 9Fh,0A0h, 00h
		db	0A1h,0A2h,0A3h,0A4h, 00h, 67h
		db	 68h, 69h, 6Ah, 00h, 6Bh, 6Ch
		db	 6Dh, 6Eh, 00h, 6Fh, 70h, 71h
		db	 72h, 00h, 73h, 74h,0E0h,0E1h
		db	 00h,0F2h,0F3h,0F4h,0F5h, 00h
		db	0F6h,0F7h,0F4h,0F5h, 00h,0E2h
		db	0E3h,0E4h,0E5h, 00h,0E6h,0E7h
		db	0E8h,0E9h, 00h,0EAh,0EBh,0ECh
		db	0EDh, 00h,0EEh,0EFh,0F0h,0F1h
		db	 00h,0F2h,0F3h,0F4h,0F5h, 00h
		db	0F6h,0F7h,0F4h,0F5h, 00h,0A5h
		db	0A6h,0A7h,0A8h, 00h,0A9h,0AAh
		db	0ABh,0ACh, 00h,0ADh,0AEh,0AFh
		db	0B0h, 00h,0B1h,0B2h,0B3h,0B4h
		db	 00h,0B5h,0B6h,0B7h,0B8h, 00h
		db	0B9h,0BAh,0BBh,0BCh, 00h,0BDh
		db	0BEh,0BFh,0C0h, 00h,0C1h,0C2h
		db	0C3h,0C4h, 00h, 00h, 00h,0C7h
		db	0C8h, 00h,0F8h,0F9h,0FAh,0FBh
		db	 00h,0FCh,0FDh, 5Ah, 4Eh, 00h
		db	 00h, 00h,0C5h,0C6h, 01h, 01h
		db	 02h, 03h, 04h, 01h, 05h, 06h
		db	 07h, 08h, 01h, 09h, 0Ah, 0Bh
		db	 0Ch, 00h, 0Dh, 0Eh, 0Fh, 10h
		db	 00h, 11h, 12h, 13h, 14h, 00h
		db	 15h, 16h, 17h, 18h, 00h, 11h
		db	 12h, 13h, 14h
data_10		db	2
		db	 0Dh, 0Eh, 0Fh, 10h, 02h, 11h
		db	 12h, 13h, 14h, 02h, 15h, 16h
		db	 17h, 18h, 02h, 11h, 12h, 13h
		db	 14h, 00h,0C9h,0CAh,0CBh,0CCh
		db	 00h,0C9h,0CAh,0CBh,0CCh, 01h
		db	0CDh,0CEh,0CFh,0D0h, 00h,0D1h
		db	0D2h,0D3h,0D4h, 02h,0D1h,0D2h
		db	0D3h,0D4h, 01h,0D5h,0D5h,0D5h
		db	0D5h, 01h,0D6h,0D7h,0D8h,0D9h
		db	 01h,0DAh,0DBh,0DCh,0DDh, 01h
		db	 00h, 00h,0DEh,0DFh, 4Ch,0A2h
		db	 50h,0A2h
		db	50h
loc_1:
		mov	byte ptr ds:[0A248h],al
		add	ax,0
		add	[di],al
		add	al,4
		add	[si],al
		add	[si],al
		add	byte ptr ss:[45Ch][bp+si],cl
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:[0A262h][bx]	;*
		db	 6Ah,0A2h,0E7h,0A3h, 3Fh,0A4h
		db	 17h,0A5h, 2Eh,0FFh, 16h, 30h
		db	 60h, 75h, 05h, 2Eh,0FFh, 26h
		db	 32h, 60h,0F6h, 44h, 08h,0FFh
		db	 75h, 04h,0C6h, 44h, 08h, 02h
loc_2:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_3			; Jump if zero
		jmp	word ptr cs:data_28e
loc_3:
		mov	bl,[si+9]
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_29e[bx]	;*
			                        ;* No entry point to code
		movsw				; Mov [si] to es:[di]
		mov	ds:data_30e,al
		jcxz	loc_1			; Jump if cx=0
		and	word ptr ss:data_33e[bp+di],16h
		or	al,60h			; '`'
		test	byte ptr [si+6],0FFh
		jz	loc_4			; Jump if zero
		sub	byte ptr [si+6],10h
		retn
loc_4:
		mov	al,[si+3]
		sub	al,11h
		cmp	al,0Ah
		jb	loc_5			; Jump if below
		mov	al,11h
		sub	al,[si+3]
		cmp	al,7
		jae	loc_6			; Jump if above or =
loc_5:
		mov	byte ptr [si+9],40h	; '@'
loc_6:
		mov	byte ptr [si+6],0
		retn
			                        ;* No entry point to code
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],3
		je	loc_7			; Jump if equal
		retn
loc_7:
		mov	byte ptr [si+9],80h
		retn
			                        ;* No entry point to code
		call	sub_1
		test	byte ptr ds:data_35e,0FFh
		jz	loc_8			; Jump if zero
		mov	byte ptr [si+9],0C0h
		retn
loc_8:
		mov	al,ds:data_34e
		sub	al,[si+2]
		add	al,15h
		and	al,3Fh			; '?'
		cmp	al,12h
		jb	loc_13			; Jump if below
		cmp	al,18h
		jb	loc_10			; Jump if below
		cmp	byte ptr [si+3],11h
		je	loc_15			; Jump if equal
		cmp	byte ptr [si+3],10h
		je	loc_15			; Jump if equal
		jnc	loc_9			; Jump if carry=0
		call	word ptr cs:data_20e
		jc	loc_11			; Jump if carry Set
		or	byte ptr [si+5],80h
		retn
loc_9:
		call	word ptr cs:data_18e
		jc	loc_12			; Jump if carry Set
		and	byte ptr [si+5],7Fh
		retn
loc_10:
		cmp	byte ptr [si+3],11h
		je	loc_15			; Jump if equal
		cmp	byte ptr [si+3],10h
		je	loc_15			; Jump if equal
		jnc	loc_12			; Jump if carry=0
loc_11:
		call	word ptr cs:data_13e
		jc	loc_15			; Jump if carry Set
		or	byte ptr [si+5],80h
		retn
loc_12:
		call	word ptr cs:data_17e
		jc	loc_15			; Jump if carry Set
		and	byte ptr [si+5],7Fh
		retn
loc_13:
		cmp	byte ptr [si+3],11h
		je	loc_15			; Jump if equal
		cmp	byte ptr [si+3],10h
		je	loc_15			; Jump if equal
		jnc	loc_14			; Jump if carry=0
		call	word ptr cs:data_14e
		jc	loc_11			; Jump if carry Set
		or	byte ptr [si+5],80h
		retn
loc_14:
		call	word ptr cs:data_16e
		jc	loc_12			; Jump if carry Set
		and	byte ptr [si+5],7Fh
		retn
loc_15:
		call	word ptr cs:data_19e
		jc	loc_16			; Jump if carry Set
		retn
loc_16:
		mov	byte ptr [si+9],0C0h
		retn
			                        ;* No entry point to code
		test	byte ptr [si+9],20h	; ' '
		jnz	loc_22			; Jump if not zero
		call	sub_1
		test	byte ptr [si+5],80h
		jz	loc_18			; Jump if zero
		call	word ptr cs:data_14e
		jc	loc_17			; Jump if carry Set
		retn
loc_17:
		and	byte ptr [si+5],7Fh
		jmp	short loc_20
loc_18:
		call	word ptr cs:data_16e
		jc	loc_19			; Jump if carry Set
		retn
loc_19:
		or	byte ptr [si+5],80h
loc_20:
		call	word ptr cs:data_15e
		jc	loc_21			; Jump if carry Set
		retn
loc_21:
		or	byte ptr [si+9],20h	; ' '
		mov	byte ptr [si+6],2
		retn
loc_22:
		dec	byte ptr [si+6]
		and	byte ptr [si+6],7
		test	byte ptr [si+6],0FFh
		jz	loc_23			; Jump if zero
		retn
loc_23:
		mov	byte ptr [si+6],70h	; 'p'
		mov	byte ptr [si+9],0
		retn

_301MAPCA	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],7
		jae	loc_24			; Jump if above or =
		retn
loc_24:
		mov	byte ptr [si+6],3
		retn
sub_1		endp

			                        ;* No entry point to code
		call	word ptr cs:data_26e
		jnz	loc_25			; Jump if not zero
		jmp	word ptr cs:data_27e
loc_25:
		test	byte ptr [si+8],0FFh
		jnz	loc_26			; Jump if not zero
		mov	byte ptr [si+8],2
loc_26:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_27			; Jump if zero
		jmp	word ptr cs:data_28e
loc_27:
		call	word ptr cs:data_19e
		jc	loc_28			; Jump if carry Set
		retn
loc_28:
		add	byte ptr [si+6],41h	; 'A'
		and	byte ptr [si+6],0C3h
		test	byte ptr [si+6],0F0h
		jz	loc_29			; Jump if zero
		retn
loc_29:
		cmp	byte ptr [si+3],11h
		jae	loc_31			; Jump if above or =
		call	word ptr cs:data_13e
		jnc	loc_30			; Jump if carry=0
		retn
loc_30:
		or	byte ptr [si+5],80h
		retn
loc_31:
		call	word ptr cs:data_17e
		jnc	loc_32			; Jump if carry=0
		retn
loc_32:
		and	byte ptr [si+5],7Fh
		retn
			                        ;* No entry point to code
		call	word ptr cs:data_26e
		jnz	loc_33			; Jump if not zero
		jmp	word ptr cs:data_27e
loc_33:
		test	byte ptr [si+8],0FFh
		jnz	loc_34			; Jump if not zero
		mov	byte ptr [si+8],1
loc_34:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_35			; Jump if zero
		jmp	word ptr cs:data_28e
loc_35:
		test	byte ptr [si+9],8
		jnz	loc_39			; Jump if not zero
		add	byte ptr [si+6],21h	; '!'
		and	byte ptr [si+6],0E1h
		call	word ptr cs:data_19e
		jc	loc_36			; Jump if carry Set
		retn
loc_36:
		call	sub_2
		jc	loc_38			; Jump if carry Set
		mov	al,[si+6]
		and	al,0E0h
		jz	loc_37			; Jump if zero
		retn
loc_37:
		call	sub_2
		cmp	al,0FFh
		je	loc_38			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		mov	byte ptr [si+6],2
		or	byte ptr [si+9],8
		retn
loc_38:
		mov	byte ptr [si+6],2
		or	byte ptr [si+9],8
loc_39:
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,7
		cmp	al,7
		jae	loc_42			; Jump if above or =
		mov	ch,ah
		and	ch,0F0h
		or	al,ch
		mov	[si+6],al
		mov	bx,0A71Fh
		test	byte ptr [si+5],80h
		jnz	loc_40			; Jump if not zero
		mov	bx,data_31e
loc_40:
		mov	al,ah
		sub	al,2
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_11e
		jc	loc_41			; Jump if carry Set
		retn
loc_41:
		call	sub_2
		jc	loc_42			; Jump if carry Set
		xor	byte ptr [si+5],80h
loc_42:
		and	byte ptr [si+9],0F7h
		mov	byte ptr [si+6],0
		jmp	word ptr cs:data_19e

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_2		proc	near
		mov	al,ds:data_34e
		sub	al,[si+2]
		jns	loc_43			; Jump if not sign
		neg	al
loc_43:
		cmp	al,8
		mov	al,0FFh
		jc	loc_44			; Jump if carry Set
		retn
loc_44:
		cmp	byte ptr [si+3],11h
		jae	loc_46			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	loc_45			; Jump if zero
		retn
loc_45:
		clc				; Clear carry flag
		retn
loc_46:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	loc_47			; Jump if not zero
		retn
loc_47:
		clc				; Clear carry flag
		retn
sub_2		endp

			                        ;* No entry point to code
		call	word ptr cs:data_26e
		jnz	loc_48			; Jump if not zero
		jmp	word ptr cs:data_27e
loc_48:
		test	byte ptr [si+8],0FFh
		jnz	loc_49			; Jump if not zero
		mov	byte ptr [si+8],1
loc_49:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_50			; Jump if zero
		jmp	word ptr cs:data_28e
loc_50:
		test	byte ptr [si+9],8
		jz	loc_51			; Jump if zero
		jmp	loc_68
loc_51:
		test	byte ptr [si+9],10h
		jz	loc_52			; Jump if zero
		jmp	loc_72
loc_52:
		call	word ptr cs:data_19e
		jc	loc_53			; Jump if carry Set
		retn
loc_53:
		test	byte ptr [si+9],4
		jz	loc_60			; Jump if zero
		and	byte ptr [si+6],0F1h
		or	byte ptr [si+6],4
		call	sub_3
		cmp	al,0FFh
		je	loc_54			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],2
		and	byte ptr [si+9],0FBh
		retn
loc_54:
		add	byte ptr [si+6],40h	; '@'
		jc	loc_55			; Jump if carry Set
		retn
loc_55:
		mov	al,[si+6]
		inc	al
		and	al,1
		add	al,4
		mov	[si+6],al
		add	byte ptr [si+9],40h	; '@'
		jc	loc_56			; Jump if carry Set
		retn
loc_56:
		and	byte ptr [si+9],0FBh
		and	byte ptr [si+5],7Fh
		call	word ptr cs:data_9
		and	al,80h
		or	[si+5],al
		or	al,al			; Zero ?
		jns	loc_58			; Jump if not sign
		call	word ptr cs:data_21e
		jc	loc_57			; Jump if carry Set
		retn
loc_57:
		and	byte ptr [si+5],7Fh
		retn
loc_58:
		call	word ptr cs:data_22e
		jc	loc_59			; Jump if carry Set
		retn
loc_59:
		or	byte ptr [si+5],80h
		retn
loc_60:
		mov	ax,[si+2]
		call	word ptr cs:data_23e
		mov	ax,48h
		test	byte ptr [si+5],80h
		jz	loc_61			; Jump if zero
		inc	ax
loc_61:
		xchg	si,di
		add	si,ax
		call	word ptr cs:data_24e
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:data_25e
		jnz	loc_62			; Jump if not zero
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],8
		retn
loc_62:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		test	byte ptr [si+9],2
		jnz	loc_63			; Jump if not zero
		add	byte ptr [si+0Ah],10h
		jnc	loc_63			; Jump if carry=0
		or	byte ptr [si+9],4
		retn
loc_63:
		call	sub_3
		jnc	loc_64			; Jump if carry=0
		and	byte ptr [si+5],0FDh
		mov	byte ptr [si+0Ah],0
loc_64:
		test	byte ptr [si+5],80h
		jz	loc_66			; Jump if zero
		call	word ptr cs:data_13e
		jc	loc_65			; Jump if carry Set
		retn
loc_65:
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],10h
		and	byte ptr [si+9],1Fh
		retn
loc_66:
		call	word ptr cs:data_17e
		jc	loc_67			; Jump if carry Set
		retn
loc_67:
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],10h
		and	byte ptr [si+9],1Fh
		retn
loc_68:
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,3
		jz	loc_71			; Jump if zero
		and	ah,0F0h
		or	ah,al
		mov	[si+6],ah
		mov	bx,0A71Fh
		test	byte ptr [si+5],80h
		jnz	loc_69			; Jump if not zero
		mov	bx,data_31e
loc_69:
		mov	al,[si+6]
		xlat				; al=[al+[bx]] table
		push	ax
		call	word ptr cs:data_12e
		pop	ax
		jc	loc_70			; Jump if carry Set
		jmp	word ptr cs:data_11e
loc_70:
		and	byte ptr [si+9],0F7h
		or	byte ptr [si+9],4
		retn
loc_71:
		and	byte ptr [si+9],0F7h
		mov	byte ptr [si+6],3
		jmp	word ptr cs:data_19e
loc_72:
		add	byte ptr [si+9],20h	; ' '
		test	byte ptr [si+9],20h	; ' '
		jnz	loc_73			; Jump if not zero
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,3
		jz	loc_77			; Jump if zero
		and	ah,0F0h
		or	ah,al
		mov	[si+6],ah
loc_73:
		mov	al,[si+9]
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		dec	al
		and	al,7
		mov	bx,0A727h
		test	byte ptr [si+5],80h
		jnz	loc_74			; Jump if not zero
		mov	bx,data_32e
loc_74:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_11e
		jc	loc_75			; Jump if carry Set
		retn
loc_75:
		and	byte ptr [si+9],0EFh
		or	byte ptr [si+9],4
		test	byte ptr [si+6],0FFh
		jnz	loc_76			; Jump if not zero
		retn
loc_76:
		mov	byte ptr [si+6],3
		retn
loc_77:
		and	byte ptr [si+9],0EFh
		mov	byte ptr [si+6],3
		jmp	word ptr cs:data_19e

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_3		proc	near
		mov	al,ds:data_34e
		sub	al,[si+2]
		jns	loc_78			; Jump if not sign
		neg	al
loc_78:
		cmp	al,6
		mov	al,0FFh
		jc	loc_79			; Jump if carry Set
		retn
loc_79:
		cmp	byte ptr [si+3],11h
		jae	loc_81			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	loc_80			; Jump if zero
		retn
loc_80:
		clc				; Clear carry flag
		retn
loc_81:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	loc_82			; Jump if not zero
		retn
loc_82:
		clc				; Clear carry flag
		retn
sub_3		endp

			                        ;* No entry point to code
		add	[bx+si],ax
		add	[bx],al
		add	ax,[si]
		add	al,5
		add	al,[bx+di]
		add	[bx+si],ax
		add	[bx],al
		pop	es
		push	es
		add	al,[bp+di]
		add	ax,[si]
		add	al,5
		db	05h, 06h		; truncated 'add ax,6' — file ends mid-instruction

seg_a		ends



		end	start
