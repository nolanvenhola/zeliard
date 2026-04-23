
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_306MAPBK                                €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_9e		equ	6004h			;*
data_10e	equ	6008h			;*
data_11e	equ	600Ch			;*
data_12e	equ	6010h			;*
data_13e	equ	6014h			;*
data_14e	equ	6028h			;*
data_15e	equ	602Ah			;*
data_16e	equ	602Ch			;*
data_17e	equ	602Eh			;*
data_18e	equ	6032h			;*
data_19e	equ	6034h			;*
data_20e	equ	603Ah			;*
data_21e	equ	0A4DDh			;*
data_22e	equ	0A4DEh			;*
data_23e	equ	0A4EAh			;*
data_24e	equ	0A4EBh			;*
data_25e	equ	0A766h			;*
data_26e	equ	0C002h			;*
data_27e	equ	0FF35h			;*
data_28e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_306MAPBK	proc	far

start:
		ror	byte ptr [bx+di],cl	; Rotate
		add	[bx+si],al
		stc				; Set carry flag
		mov	word ptr ds:[0],ax
		add	[bx+si],al
		db	0DFh,0A3h, 64h, 64h, 32h, 32h
		db	 00h, 00h, 00h, 00h
		db	 50h, 50h, 28h, 28h, 50h
		db	27 dup (0)
		db	0B0h,0A0h, 5Fh,0A1h, 0Eh,0A2h
		db	0BDh,0A2h, 1Ch,0A3h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 50h,0A1h
		db	0FFh,0A1h,0AEh,0A2h, 0Dh,0A3h
		db	 30h,0A3h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0C1h,0A3h,0C1h,0A3h
		db	 3Fh,0A3h, 8Ah,0A3h, 4Eh,0A3h
		db	 62h,0A3h,0B2h,0A3h, 00h, 00h
		db	0B7h,0A3h,0BCh,0A3h,0D5h,0A3h
		db	 76h,0A3h, 00h, 00h, 00h, 00h
		db	0DAh,0A3h, 00h, 00h, 00h,0A1h
		db	0AFh,0A1h, 5Eh,0A2h,0E5h,0A2h
		db	 1Ch,0A3h, 00h, 00h, 00h, 00h
data_3		db	0
		db	 00h, 50h,0A1h,0FFh,0A1h,0AEh
		db	0A2h, 0Dh,0A3h, 30h,0A3h, 00h
		db	 00h
data_4		db	0
		db	 00h, 00h, 00h,0C1h,0A3h,0C1h
		db	0A3h, 3Fh,0A3h, 8Ah,0A3h, 4Eh
		db	0A3h, 62h,0A3h,0B2h,0A3h, 00h
		db	 00h,0B7h,0A3h,0BCh,0A3h,0D5h
		db	0A3h, 76h,0A3h, 00h, 00h, 00h
		db	 00h,0DAh,0A3h, 00h, 00h, 00h
		db	 01h, 02h, 03h, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 01h, 02h
		db	 03h, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 01h, 02h, 03h, 04h
		db	 00h, 01h, 02h, 12h, 04h, 00h
		db	 01h, 02h, 13h, 04h, 00h, 01h
		db	 02h, 14h, 04h, 00h, 01h, 02h
		db	 15h, 04h, 00h, 01h, 02h, 14h
		db	 04h, 00h, 01h, 02h, 13h, 04h
		db	 00h, 01h, 02h, 12h, 04h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 01h
		db	 02h, 03h, 04h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 01h, 02h, 03h
		db	 04h, 00h, 09h, 0Ah, 0Bh, 0Ch
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 09h, 0Ah, 0Bh, 0Ch, 00h, 00h
		db	 00h, 00h, 00h, 00h
		db	9
data_5		dw	0B0Ah
		db	 0Ch, 00h, 09h, 0Ah, 0Bh, 17h
		db	 00h, 09h, 0Ah, 0Bh, 18h, 00h
		db	 09h, 0Ah, 0Bh, 19h, 00h, 09h
		db	 0Ah, 0Bh, 1Ah, 00h, 09h, 0Ah
		db	 0Bh, 19h, 00h, 09h, 0Ah, 0Bh
		db	 18h, 00h, 09h, 0Ah, 0Bh, 17h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 09h, 0Ah, 0Bh, 0Ch, 00h, 00h
		db	 00h, 00h, 00h, 00h, 09h, 0Ah
		db	 0Bh, 0Ch, 00h, 1Bh, 1Ch, 1Dh
		db	 1Eh, 00h, 00h, 00h, 1Bh, 1Ch
		db	 00h, 00h, 00h, 26h, 27h, 00h
		db	 11h, 06h, 07h, 08h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 11h, 06h
		db	 07h, 08h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 11h, 06h, 07h, 08h
		db	 00h, 11h, 06h, 07h, 08h, 00h
		db	 11h, 06h, 07h, 08h, 00h, 11h
		db	 06h, 07h, 08h, 00h, 11h, 06h
		db	 07h, 08h, 00h, 11h, 06h, 07h
		db	 08h, 00h, 11h, 06h, 07h, 08h
		db	 00h, 11h, 06h, 07h, 08h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 11h
		db	 06h, 07h, 08h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 11h, 06h, 07h
		db	 08h, 00h, 0Dh, 16h, 0Fh, 10h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 0Dh, 16h, 0Fh, 10h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 0Dh, 16h
		db	 0Fh, 10h, 00h, 0Dh, 16h, 0Fh
		db	 10h, 00h, 0Dh, 16h, 0Fh, 10h
		db	 00h, 0Dh, 16h, 0Fh, 10h, 00h
		db	 0Dh, 16h, 0Fh, 10h, 00h, 0Dh
		db	 16h, 0Fh, 10h, 00h, 0Dh, 16h
		db	 0Fh, 10h, 00h, 0Dh, 16h, 0Fh
		db	 10h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 0Dh, 16h, 0Fh, 10h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 0Dh
		db	 16h, 0Fh, 10h, 00h, 1Fh, 20h
		db	 21h, 22h, 00h, 1Dh
		db	 23h, 24h
		db	'%', 0
		db	'(#)%', 0
		db	'*+,-', 0
		db	'./01', 0
		db	'2345', 0
		db	'6789', 0
		db	'6789', 0
		db	'JKLM', 0
		db	'NOPQ', 0
		db	'c', 0
		db	 65h, 00h, 00h, 5Ah, 00h, 5Ch
		db	 00h, 00h, 5Dh, 00h, 5Fh, 00h
		db	 00h, 60h, 00h, 62h, 00h, 00h
		db	 63h, 00h, 65h, 00h, 00h, 63h
		db	 00h, 65h, 00h, 00h
		db	 4Eh, 4Fh
		db	'PQ', 0
		db	'JKLM', 0
		db	'6789', 0
		db	':;<=', 0
		db	'>?@A', 0
		db	'BCDE', 0
		db	'FGHI', 0
		db	'FGHI', 0
		db	'RSTU', 0
		db	'VWXY', 0
		db	'rstu', 0
		db	'fghi', 0
		db	'jklm', 0
		db	'nopq', 0
		db	'rstu', 0
		db	'rstu', 0
		db	'VWXY', 0
		db	'RSTU', 0
		db	'FGHI', 0
		db	'vwx9', 0
		db	'z{|}'
		db	 00h, 00h, 00h, 80h, 81h, 01h
		db	0C2h,0C3h,0C4h,0C5h, 01h,0C6h
		db	0C7h,0C8h,0C9h, 01h,0C2h,0C3h
		db	0C4h,0CAh, 01h,0C6h,0C7h,0CBh
		db	0CCh, 01h, 9Ch, 9Dh, 9Eh, 9Fh
		db	 01h,0B7h,0B8h,0B9h,0BAh, 01h
		db	 00h,0BBh,0BCh,0BDh, 01h,0BEh
		db	0BFh,0C0h,0C1h, 01h,0CDh,0CEh
		db	0CFh,0D0h, 01h,0D1h,0D2h,0D3h
		db	0D4h, 01h,0CDh,0CEh,0D5h,0D0h
		db	 01h,0D1h,0D2h,0D6h,0D7h, 01h
		db	0A4h,0A5h,0A6h,0A7h, 01h,0ACh
		db	0ADh,0AEh,0AFh, 01h,0B0h, 00h
		db	0B1h,0B2h, 01h,0B3h,0B4h,0B5h
		db	0B6h, 01h,0D8h,0D9h,0DAh,0DBh
		db	 01h,0DCh,0DDh,0DEh,0DFh, 01h
		db	0E0h,0E1h,0E2h,0E3h, 01h, 05h
		db	 05h, 05h, 05h, 01h, 0Eh, 0Eh
		db	 5Bh, 5Eh, 01h, 61h, 64h, 79h
		db	 7Eh, 01h, 7Fh, 82h, 83h, 84h
		db	 01h, 85h, 86h, 87h, 88h, 01h
		db	 89h, 8Ah, 8Bh, 8Bh, 01h, 8Ch
		db	 8Ch, 00h, 00h, 01h, 8Dh, 8Eh
		db	 8Fh, 90h, 01h, 91h, 92h, 93h
		db	 94h, 01h, 95h, 96h, 97h, 98h
		db	 00h, 99h, 9Ah, 9Bh,0A0h, 00h
		db	0A1h,0A2h,0A3h,0A8h, 00h,0A9h
		db	0AAh,0ABh,0E4h, 00h,0A1h,0A2h
		db	0A3h,0A8h, 02h, 99h, 9Ah, 9Bh
		db	0A0h, 02h,0A1h,0A2h,0A3h,0A8h
		db	 02h,0A9h,0AAh,0ABh,0E4h, 02h
		db	0A1h,0A2h,0A3h,0A8h, 01h, 99h
		db	 9Ah, 9Bh,0A0h, 01h,0A1h,0A2h
		db	0A3h,0A8h, 01h,0A9h,0AAh,0ABh
		db	0E4h, 01h,0A1h,0A2h,0A3h,0A8h
		db	 00h,0E5h,0E6h,0E7h,0E8h, 00h
		db	0E5h,0E6h,0E7h,0E8h, 00h,0E5h
		db	0E6h,0E7h,0E8h, 00h,0E5h,0E6h
		db	0E7h,0E8h, 00h,0E5h,0E6h,0E7h
		db	0E8h, 00h,0E5h,0E6h,0E7h,0E8h
		db	 00h,0E5h,0E6h,0E7h,0E8h, 00h
		db	0E5h,0E6h,0E7h,0E8h, 01h,0E9h
		db	0EAh,0EBh,0ECh, 00h,0EDh,0EEh
		db	0EFh,0F0h, 02h,0EDh,0EEh,0EFh
		db	0F0h, 01h,0FEh,0FEh,0FEh,0FEh
		db	 01h,0F1h,0F2h,0F3h,0F4h, 01h
		db	0F5h,0F6h,0F7h,0F7h, 01h, 00h
		db	 00h,0F8h,0F8h, 00h, 00h, 00h
		db	0F9h,0FAh, 01h, 00h,0FBh,0FCh
		db	0FDh,0E9h,0A3h,0E9h,0A3h,0EDh
		db	0A3h,0F1h,0A3h,0F5h,0A3h, 0Bh
		db	 0Bh, 0Bh, 0Bh, 05h, 05h, 05h
		db	 05h, 05h, 05h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 8Ah, 5Ch, 04h
		db	 80h,0E3h, 0Fh, 32h,0FFh, 03h
		db	0DBh,0FFh,0A7h, 07h,0A4h, 12h
		db	0A4h, 11h,0A4h,0B8h,0A6h, 57h
		db	0A8h, 5Fh,0A9h,0C3h,0F6h, 44h
		db	 08h,0FFh, 75h, 04h,0C6h, 44h
		db	 08h, 30h,0F6h, 44h, 05h, 20h
		db	 74h, 10h, 8Ah, 44h, 05h, 24h
		db	 1Fh, 3Ch, 01h, 75h, 03h,0E9h
		db	0C9h, 00h
loc_1:
		and	byte ptr [si+5],9Fh
loc_2:
		and	byte ptr [si+15h],0BFh
		call	sub_6
		jc	loc_3			; Jump if carry Set
		retn
loc_3:
		test	byte ptr [si+9],1
		jnz	loc_9			; Jump if not zero
		call	sub_1
		jc	loc_8			; Jump if carry Set
loc_4:
		inc	byte ptr [si+0Ah]
		mov	byte ptr [si+6],1
		or	byte ptr [si+4],60h	; '`'
		call	word ptr cs:data_5
		and	al,1
		jnz	loc_6			; Jump if not zero
		call	sub_2
		jnc	loc_5			; Jump if carry=0
		jmp	loc_13
loc_5:
		or	byte ptr [si+5],80h
		jmp	loc_13
loc_6:
		call	sub_4
		jnc	loc_7			; Jump if carry=0
		jmp	loc_13
loc_7:
		and	byte ptr [si+5],7Fh
		jmp	loc_13
loc_8:
		test	byte ptr [si+0Ah],0F0h
		jz	loc_4			; Jump if zero
		mov	byte ptr [si+0Ah],0
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],1
		jmp	short loc_13
loc_9:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],0Fh
		jnz	loc_10			; Jump if not zero
		and	byte ptr [si+9],0FEh
		mov	byte ptr [si+6],1
		or	byte ptr [si+4],60h	; '`'
		jmp	short loc_13
loc_10:
		cmp	byte ptr [si+6],4
		jb	loc_13			; Jump if below
		and	byte ptr [si+4],1Fh
		cmp	byte ptr [si+6],8
		jne	loc_13			; Jump if not equal
		mov	al,[si+3]
		mov	ds:data_23e,al
		inc	al
		mov	ds:data_21e,al
		mov	al,[si+2]
		inc	al
		mov	ds:data_24e,al
		mov	ds:data_22e,al
		mov	bx,0A4DDh
		test	byte ptr [si+5],80h
		jnz	loc_11			; Jump if not zero
		mov	bx,0A4EAh
loc_11:
		call	word ptr cs:data_20e
		jmp	short loc_13
		db	 00h, 00h, 63h, 00h, 14h, 00h
		db	 14h
		db	8 dup (0)
		db	 63h, 00h, 14h, 04h, 14h, 00h
		db	 00h, 00h, 00h, 00h, 00h
loc_12:
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:data_19e
loc_13:
		mov	al,[si+6]
		mov	[si+16h],al
		mov	al,[si+4]
		and	al,60h			; '`'
		and	byte ptr [si+14h],9Fh
		or	[si+14h],al
		mov	al,[si+5]
		and	al,80h
		and	byte ptr [si+15h],7Fh
		or	[si+15h],al
		retn

_306MAPBK	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		mov	al,ds:data_27e
		sub	al,[si+2]
		jnc	loc_14			; Jump if carry=0
		neg	al
loc_14:
		cmp	al,4
		mov	al,0FFh
		jc	loc_15			; Jump if carry Set
		retn
loc_15:
		cmp	byte ptr [si+3],11h
		jae	loc_17			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	loc_16			; Jump if zero
		retn
loc_16:
		clc				; Clear carry flag
		retn
loc_17:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	loc_18			; Jump if not zero
		retn
loc_18:
		clc				; Clear carry flag
		retn
sub_1		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	loc_19			; Jump if carry=0
		retn
loc_19:
		call	sub_3
		jnc	loc_20			; Jump if carry=0
		retn
loc_20:
		mov	bx,[si]
		inc	bx
		mov	ax,ds:data_26e
		sub	ax,bx
		jnz	loc_21			; Jump if not zero
		xchg	bx,ax
loc_21:
		mov	[si],bx
		mov	[si+10h],bx
		inc	byte ptr [si+3]
		inc	byte ptr [si+13h]
		clc				; Clear carry flag
		retn
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		mov	ax,[si+2]
		call	word ptr cs:data_14e
		inc	di
		inc	di
		mov	cx,4

locloop_22:
		mov	al,[di]
		call	word ptr cs:data_17e
		stc				; Set carry flag
		jz	loc_23			; Jump if zero
		retn
loc_23:
		xchg	si,di
		add	si,24h
		call	word ptr cs:data_15e
		xchg	si,di
		loop	locloop_22		; Loop if cx > 0

		xchg	si,di
		sub	si,24h
		call	word ptr cs:data_16e
		mov	al,[si]
		sub	si,24h
		call	word ptr cs:data_16e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_16e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_16e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_16e
		or	al,[si]
		xchg	si,di
		add	al,al
		retn
sub_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		cmp	byte ptr [si+3],2
		jae	loc_24			; Jump if above or =
		retn
loc_24:
		call	sub_5
		jnc	loc_25			; Jump if carry=0
		retn
loc_25:
		mov	ax,[si]
		dec	ax
		cmp	ax,0FFFFh
		jne	loc_26			; Jump if not equal
		mov	ax,ds:data_26e
		dec	ax
loc_26:
		mov	[si],ax
		mov	[si+10h],ax
		dec	byte ptr [si+3]
		dec	byte ptr [si+13h]
		clc				; Clear carry flag
		retn
sub_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		mov	ax,[si+2]
		call	word ptr cs:data_14e
		dec	di
		mov	cx,4

locloop_27:
		mov	al,[di]
		call	word ptr cs:data_17e
		stc				; Set carry flag
		jz	loc_28			; Jump if zero
		retn
loc_28:
		xchg	si,di
		add	si,24h
		call	word ptr cs:data_15e
		xchg	si,di
		loop	locloop_27		; Loop if cx > 0

		dec	di
		xchg	si,di
		sub	si,24h
		call	word ptr cs:data_16e
		mov	al,[si]
		sub	si,24h
		call	word ptr cs:data_16e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_16e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_16e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_16e
		or	al,[si]
		xchg	si,di
		add	al,al
		retn
sub_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		test	byte ptr [si+3],0FFh
		stc				; Set carry flag
		jnz	loc_29			; Jump if not zero
		retn
loc_29:
		cmp	byte ptr [si+3],23h	; '#'
		stc				; Set carry flag
		jnz	loc_30			; Jump if not zero
		retn
loc_30:
		call	sub_7
		jnc	loc_31			; Jump if carry=0
		retn
loc_31:
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		inc	byte ptr [si+12h]
		and	byte ptr [si+12h],3Fh	; '?'
		clc				; Clear carry flag
		retn
sub_6		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		mov	ax,[si+2]
		call	word ptr cs:data_14e
		xchg	si,di
		add	si,offset data_4
		call	word ptr cs:data_15e
		xchg	si,di
		mov	cx,2

locloop_32:
		mov	al,[di]
		call	word ptr cs:data_17e
		stc				; Set carry flag
		jz	loc_33			; Jump if zero
		retn
loc_33:
		inc	di
		loop	locloop_32		; Loop if cx > 0

		dec	di
		mov	al,[di]
		or	al,[di-1]
		or	al,[di-1]
		add	al,al
		retn
sub_7		endp

			                        ;* No entry point to code
		test	byte ptr [si+8],0FFh
		jnz	loc_34			; Jump if not zero
		mov	byte ptr [si+8],10h
loc_34:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_35			; Jump if zero
		mov	byte ptr [si+6],3
		mov	byte ptr [si+9],1
		jmp	word ptr cs:data_19e
loc_35:
		test	byte ptr [si+9],2
		jz	loc_36			; Jump if zero
		jmp	loc_47
loc_36:
		test	byte ptr [si+9],1
		jz	loc_37			; Jump if zero
		jmp	loc_45
loc_37:
		test	byte ptr [si+9],4
		jz	loc_38			; Jump if zero
		jmp	loc_55
loc_38:
		call	sub_8
		jc	loc_40			; Jump if carry Set
		test	byte ptr [si+9],70h	; 'p'
		jnz	loc_42			; Jump if not zero
		cmp	al,0FFh
		je	loc_39			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		jmp	short loc_40
loc_39:
		call	word ptr cs:data_5
		add	al,al
		and	al,80h
		and	byte ptr [si+5],7Fh
		or	[si+5],al
loc_40:
		mov	al,ds:data_27e
		sub	al,[si+2]
		jns	loc_41			; Jump if not sign
		call	word ptr cs:data_11e
		jmp	short loc_42
loc_41:
		call	word ptr cs:data_13e
loc_42:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		add	byte ptr [si+9],10h
		mov	al,[si+9]
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		and	al,7
		mov	bx,0A75Eh
		test	byte ptr [si+5],80h
		jnz	loc_43			; Jump if not zero
		mov	bx,data_25e
loc_43:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_9e
		jc	loc_44			; Jump if carry Set
		retn
loc_44:
		xor	byte ptr [si+5],80h
		retn
		db	0, 0, 1, 0, 0, 0
		db	7, 0, 4, 4, 3, 4
		db	4, 4, 5, 4
loc_45:
		or	byte ptr [si+4],60h	; '`'
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],7
		jae	loc_46			; Jump if above or =
		retn
loc_46:
		mov	byte ptr [si+6],8
		mov	byte ptr [si+0Ah],0
		mov	byte ptr [si+9],2
		retn
loc_47:
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],0Fh
		jae	loc_54			; Jump if above or =
		call	sub_8
		jnc	loc_49			; Jump if carry=0
		test	byte ptr [si+9],70h	; 'p'
		jnz	loc_51			; Jump if not zero
		cmp	al,0FFh
		je	loc_48			; Jump if equal
		xor	al,80h
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		jmp	short loc_49
loc_48:
		call	word ptr cs:data_5
		add	al,al
		and	al,80h
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		jmp	short loc_49
loc_49:
		mov	al,ds:data_27e
		sub	al,[si+2]
		js	loc_50			; Jump if sign=1
		call	word ptr cs:data_11e
		jmp	short loc_51
loc_50:
		call	word ptr cs:data_13e
loc_51:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		or	byte ptr [si+6],8
		add	byte ptr [si+9],10h
		mov	al,[si+9]
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		and	al,7
		mov	bx,0A75Eh
		test	byte ptr [si+5],80h
		jnz	loc_52			; Jump if not zero
		mov	bx,data_25e
loc_52:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_9e
		jc	loc_53			; Jump if carry Set
		retn
loc_53:
		xor	byte ptr [si+5],80h
		retn
loc_54:
		mov	byte ptr [si+6],0Ch
		mov	byte ptr [si+9],4
		retn
loc_55:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],0Fh
		jz	loc_56			; Jump if zero
		retn
loc_56:
		mov	byte ptr [si+9],0
		and	byte ptr [si+4],1Fh
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		mov	al,ds:data_27e
		sub	al,[si+2]
		jnc	loc_57			; Jump if carry=0
		neg	al
loc_57:
		cmp	al,8
		mov	al,0FFh
		jc	loc_58			; Jump if carry Set
		retn
loc_58:
		cmp	byte ptr [si+3],11h
		jae	loc_60			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	loc_59			; Jump if zero
		retn
loc_59:
		clc				; Clear carry flag
		retn
loc_60:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	loc_61			; Jump if not zero
		retn
loc_61:
		clc				; Clear carry flag
		retn
sub_8		endp

			                        ;* No entry point to code
		test	byte ptr [si+8],0FFh
		jnz	loc_62			; Jump if not zero
		mov	byte ptr [si+8],8
loc_62:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_63			; Jump if zero
		jmp	word ptr cs:data_19e
loc_63:
		test	byte ptr [si+9],1
		jnz	loc_70			; Jump if not zero
		call	word ptr cs:data_13e
		jc	loc_64			; Jump if carry Set
		retn
loc_64:
		call	sub_8
		jc	loc_69			; Jump if carry Set
		add	byte ptr [si+6],80h
		jc	loc_65			; Jump if carry Set
		retn
loc_65:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],0F3h
		test	byte ptr [si+5],80h
		jnz	loc_66			; Jump if not zero
		call	word ptr cs:data_12e
		jnc	loc_67			; Jump if carry=0
		xor	byte ptr [si+5],80h
		jmp	short loc_67
loc_66:
		call	word ptr cs:data_10e
		jnc	loc_67			; Jump if carry=0
		xor	byte ptr [si+5],80h
loc_67:
		dec	byte ptr [si+0Ah]
		test	byte ptr [si+0Ah],0Fh
		jz	loc_68			; Jump if zero
		retn
loc_68:
		xor	byte ptr [si+5],80h
		retn
loc_69:
		mov	byte ptr [si+9],1
		mov	byte ptr [si+0Ah],0
		retn
loc_70:
		test	byte ptr [si+9],2
		jnz	loc_77			; Jump if not zero
		call	sub_8
		cmp	al,0FFh
		je	loc_74			; Jump if equal
		mov	byte ptr [si+6],4
		test	byte ptr [si+5],80h
		jnz	loc_71			; Jump if not zero
		call	word ptr cs:data_12e
		call	word ptr cs:data_12e
		jnc	loc_72			; Jump if carry=0
		call	sub_10
		jc	loc_76			; Jump if carry Set
		jmp	short loc_72
loc_71:
		call	word ptr cs:data_10e
		call	word ptr cs:data_10e
		jnc	loc_72			; Jump if carry=0
		call	sub_10
		jc	loc_76			; Jump if carry Set
loc_72:
		inc	byte ptr [si+0Ah]
		mov	al,[si+0Ah]
		and	al,0Fh
		inc	al
		jnz	loc_73			; Jump if not zero
		call	sub_9
loc_73:
		test	byte ptr [si+0Ah],1Fh
		jz	loc_74			; Jump if zero
		retn
loc_74:
		call	sub_8
		jnc	loc_75			; Jump if carry=0
		retn
loc_75:
		mov	byte ptr [si+6],0
		mov	byte ptr [si+9],0
		mov	byte ptr [si+0Ah],0
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_9		proc	near
loc_76:
		or	byte ptr [si+9],2
		xor	byte ptr [si+5],80h
		mov	byte ptr [si+6],5
		retn
sub_9		endp

loc_77:
		inc	byte ptr [si+6]
		test	byte ptr [si+6],7
		jz	loc_78			; Jump if zero
		retn
loc_78:
		and	byte ptr [si+9],0FDh
		mov	byte ptr [si+6],4
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_10		proc	near
		test	byte ptr [si+9],4
		jnz	loc_79			; Jump if not zero
		jmp	word ptr cs:data_13e
loc_79:
		call	word ptr cs:data_11e
		jc	loc_80			; Jump if carry Set
		retn
loc_80:
		or	byte ptr [si+9],4
		retn
sub_10		endp

			                        ;* No entry point to code
		or	byte ptr [si+4],20h	; ' '
		test	byte ptr [si+9],2
		jnz	loc_87			; Jump if not zero
		test	byte ptr [si+9],1
		jnz	loc_84			; Jump if not zero
		cmp	byte ptr [si+3],8
		jae	loc_81			; Jump if above or =
		retn
loc_81:
		cmp	byte ptr [si+3],13h
		jb	loc_82			; Jump if below
		retn
loc_82:
		call	word ptr cs:data_5
		and	al,3
		jz	loc_83			; Jump if zero
		retn
loc_83:
		or	byte ptr [si+9],1
		retn
loc_84:
		call	word ptr cs:data_13e
		jc	loc_85			; Jump if carry Set
		retn
loc_85:
		or	byte ptr [si+9],2
		mov	byte ptr [si+6],1
		mov	ah,data_3
		dec	ah
		mov	al,[si+2]
		sub	al,ah
		and	al,3Fh			; '?'
		cmp	al,13h
		jb	loc_86			; Jump if below
		retn
loc_86:
		mov	byte ptr ds:data_28e,21h	; '!'
		retn
loc_87:
		add	byte ptr [si+6],80h
		jc	loc_88			; Jump if carry Set
		retn
loc_88:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		jz	loc_89			; Jump if zero
		retn
loc_89:
		and	byte ptr [si+7],0F0h
		or	byte ptr [si+7],1
		jmp	word ptr cs:data_18e

seg_a		ends



		end	start
