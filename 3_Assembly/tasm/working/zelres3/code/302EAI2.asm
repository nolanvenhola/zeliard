
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_302MAPBC                                €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_10e	equ	6004h			;*
data_11e	equ	6008h			;*
data_12e	equ	600Ah			;*
data_13e	equ	600Ch			;*
data_14e	equ	600Eh			;*
data_15e	equ	6010h			;*
data_16e	equ	6012h			;*
data_17e	equ	6014h			;*
data_18e	equ	6016h			;*
data_19e	equ	6028h			;*
data_20e	equ	602Ah			;*
data_21e	equ	602Ch			;*
data_22e	equ	602Eh			;*
data_23e	equ	6030h			;*
data_24e	equ	6032h			;*
data_25e	equ	6034h			;*
data_26e	equ	603Ah			;*
data_27e	equ	0A4FDh			;*
data_28e	equ	0A4FEh			;*
data_29e	equ	0A50Ah			;*
data_30e	equ	0A50Bh			;*
data_31e	equ	0A517h			;*
data_32e	equ	0A518h			;*
data_33e	equ	0A524h			;*
data_34e	equ	0A525h			;*
data_35e	equ	0A6D6h			;*
data_36e	equ	0A6D7h			;*
data_37e	equ	0A8D2h			;*
data_38e	equ	0A8D3h			;*
data_39e	equ	0A8DFh			;*
data_40e	equ	0A8E0h			;*
data_41e	equ	0A8F0h			;*
data_42e	equ	0A956h			;*
data_43e	equ	0C002h			;*
data_44e	equ	0FF35h			;*
data_45e	equ	0FF36h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_302MAPBC	proc	far

start:
		mov	al,data_1
		add	[bx+di-5Dh],ch
		db	0, 0, 0, 0
data_1		db	49h
		db	0A3h, 0Ah, 0Ah, 04h, 0Ah, 04h
		db	0FFh, 00h, 00h
		db	 0Ah, 0Ah, 08h, 0Ah, 08h, 28h
		db	26 dup (0)
		db	0B0h,0A0h, 0Fh,0A1h, 6Eh,0A1h
		db	0B9h,0A1h, 18h,0A2h, 6Dh,0A2h
		db	 00h, 00h, 00h, 00h, 00h,0A1h
		db	 5Fh,0A1h,0AAh,0A1h, 09h,0A2h
		db	 5Eh,0A2h,0B3h,0A2h, 00h, 00h
		db	 00h, 00h, 26h,0A3h, 26h,0A3h
		db	0C2h,0A2h, 0Dh,0A3h,0D1h,0A2h
		db	0E5h,0A2h, 21h,0A3h, 00h, 00h
		db	 3Fh,0A3h, 44h,0A3h, 00h, 00h
		db	0F9h,0A2h, 3Ah,0A3h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0D8h,0A0h
		db	 37h,0A1h, 6Eh,0A1h,0E1h,0A1h
		db	 3Bh,0A2h, 90h,0A2h, 00h, 00h
		db	 00h, 00h, 00h,0A1h, 5Fh,0A1h
		db	0AAh,0A1h, 09h,0A2h, 5Eh,0A2h
		db	0B3h,0A2h
data_3		db	0
		db	 00h, 00h, 00h, 26h,0A3h, 26h
		db	0A3h,0C2h,0A2h, 0Dh,0A3h,0D1h
		db	0A2h,0E5h,0A2h, 21h,0A3h, 00h
		db	 00h, 3Fh,0A3h, 44h,0A3h, 00h
		db	 00h,0F9h,0A2h, 3Ah,0A3h
		db	7 dup (0)
		db	'!"#$'
		db	0
		db	'%&', 27h, '(', 0
		db	')*+,', 0
		db	'%&', 27h, '(', 0
		db	'%&', 27h, '(', 0
		db	'%&', 27h, '(', 0
		db	'%&', 27h, '(', 0
		db	'%&', 27h, '(', 0
		db	'-./0', 0
		db	'1234', 0
		db	'5678', 0
		db	'1234', 0
		db	'1234', 0
		db	'1234', 0
		db	'1234', 0
		db	'1234', 0
		db	'9:;<', 0
		db	'=', 0
		db	'>?'
		db	0, 0, 0, 0, 0, 0
		db	 40h, 41h
data_6		db	'BC', 0
		db	'DEFG', 0
		db	'HIJK', 0
		db	'DELM', 0
		db	'DEFN', 0
		db	'^EFN', 0
		db	'_EFN', 0
		db	'^EFN', 0
		db	'OPQR', 0
		db	'STUV', 0
		db	'WXYZ', 0
		db	'ST[\', 0
		db	'ST]V', 0
		db	'S`]V', 0
		db	'Sa]V', 0
		db	'S`]V', 0
		db	'bcde', 0
		db	'fghi', 0
		db	'jklm'
		db	 02h, 00h, 00h, 7Dh, 7Eh, 02h
		db	 00h, 00h, 7Fh, 80h, 02h, 00h
		db	 00h, 83h, 84h, 02h, 85h, 86h
		db	 87h, 88h, 02h, 85h, 86h, 87h
		db	 88h, 02h, 00h, 00h, 83h, 84h
		db	 02h, 00h, 00h, 7Fh, 80h, 02h
		db	 00h, 00h, 7Dh, 7Eh, 02h, 00h
		db	 00h, 89h, 8Ah, 02h, 00h, 00h
		db	 8Bh, 8Ch, 02h, 00h, 00h, 89h
		db	 8Ah, 02h, 00h, 00h, 8Dh, 8Eh
		db	 02h, 00h, 00h, 91h, 92h, 02h
		db	 93h, 94h, 95h, 96h, 02h, 97h
		db	 98h, 99h, 9Ah, 00h, 9Bh, 9Ch
		db	 9Dh, 9Eh, 00h, 9Bh, 9Ch, 9Fh
		db	 9Eh, 00h,0A1h,0A2h,0A3h,0A4h
		db	 00h,0A5h,0A2h,0A6h,0A7h, 00h
		db	0A8h,0A9h,0AAh,0ABh, 00h,0ACh
		db	0ADh,0AEh,0AFh, 00h, 9Bh, 9Ch
		db	 9Dh, 9Eh, 00h, 9Bh, 9Ch,0A0h
		db	 9Eh, 00h,0B4h,0B5h,0B6h,0B7h
		db	 00h,0B4h,0B5h,0B6h,0B8h, 00h
		db	0BAh,0BBh,0BCh,0BDh, 00h,0BAh
		db	0BEh,0BFh,0C0h, 00h,0C1h,0C2h
		db	0C3h,0C4h, 00h,0C5h,0C6h,0C7h
		db	0C8h, 00h,0B4h,0B5h,0B6h,0B7h
		db	 00h,0B4h,0B5h,0B6h,0B9h, 00h
		db	0CDh,0CEh,0CFh,0D0h, 00h,0D1h
		db	0D2h,0D3h,0D4h, 00h, 00h, 00h
		db	0D7h,0D8h, 00h,0D9h,0DAh,0DBh
		db	0DCh, 00h,0E1h,0E2h,0E3h,0E4h
		db	 00h,0E1h,0E2h,0E3h,0E4h, 00h
		db	0E5h,0E6h,0E7h,0E8h, 00h,0E9h
		db	0EAh,0EBh,0ECh, 00h,0E5h,0E6h
		db	0E7h,0E8h, 00h,0EDh,0EEh,0EFh
		db	0F0h, 00h,0D9h,0DAh,0DBh,0DCh
		db	 00h,0DDh,0DEh,0DFh,0E0h, 00h
		db	0DDh,0DEh,0DFh,0E0h, 00h, 81h
		db	 82h, 8Fh, 90h, 00h,0B0h,0B1h
		db	0B2h,0B3h, 00h, 81h, 82h, 8Fh
		db	 90h, 00h,0C9h,0CAh,0CBh,0CCh
		db	 00h,0D5h,0D6h,0F1h,0F2h, 00h
		db	0F3h,0F4h,0F5h,0F6h, 00h,0F7h
		db	0F8h,0F9h,0FAh, 01h,0D9h,0DAh
		db	0DBh,0DCh, 01h,0E1h,0E2h,0E3h
		db	0E4h, 01h,0E1h,0E2h,0E3h,0E4h
		db	 01h,0E5h,0E6h,0E7h,0E8h, 01h
		db	0E9h,0EAh,0EBh,0ECh, 01h,0E5h
		db	0E6h,0E7h,0E8h, 01h,0EDh,0EEh
		db	0EFh,0F0h, 01h,0D9h,0DAh,0DBh
		db	0DCh, 01h,0DDh,0DEh,0DFh,0E0h
		db	 01h,0DDh,0DEh,0DFh,0E0h, 01h
		db	 81h, 82h, 8Fh, 90h, 01h,0B0h
		db	0B1h,0B2h,0B3h, 01h, 81h, 82h
		db	 8Fh, 90h, 01h,0C9h,0CAh,0CBh
		db	0CCh, 01h,0D5h,0D6h,0F1h,0F2h
		db	 01h,0F3h,0F4h,0F5h,0F6h, 01h
		db	0F7h,0F8h,0F9h,0FAh, 01h, 01h
		db	 02h, 03h, 04h, 01h, 05h, 06h
		db	 07h, 08h, 01h, 09h, 0Ah, 0Bh
		db	 0Ch, 00h, 0Dh, 0Eh, 0Fh, 10h
		db	 00h, 11h, 12h, 13h, 14h, 00h
		db	 15h, 16h, 17h, 18h, 00h, 11h
		db	 12h, 13h, 14h, 02h, 0Dh, 0Eh
		db	 0Fh, 10h, 02h, 11h, 12h, 13h
		db	 14h, 02h, 15h, 16h, 17h, 18h
		db	 02h, 11h, 12h, 13h, 14h, 01h
		db	 0Dh, 0Eh, 0Fh, 10h, 01h, 11h
		db	 12h, 13h, 14h, 01h, 15h, 16h
		db	 17h, 18h, 01h, 11h, 12h, 13h
		db	 14h, 00h, 19h, 1Ah, 1Bh, 1Ch
		db	 00h, 19h, 1Ah, 1Bh, 1Ch, 00h
		db	 19h, 1Ah, 1Bh, 1Ch, 00h, 19h
		db	 1Ah, 1Bh, 1Ch, 01h, 1Dh, 1Eh
		db	 1Fh, 20h, 01h, 6Eh, 6Eh, 6Eh
		db	 6Eh, 01h, 6Fh, 70h, 71h, 72h
		db	 01h, 73h, 74h, 75h, 76h, 01h
		db	 00h, 00h, 77h, 78h, 02h, 79h
		db	 7Ah, 7Bh, 7Ch, 00h,0FBh,0FCh
		db	0FDh,0FEh, 02h,0FBh,0FCh,0FDh
		db	0FEh, 55h,0A3h, 55h,0A3h, 59h
		db	0A3h, 5Dh,0A3h, 61h,0A3h, 65h
		db	0A3h, 05h, 05h, 05h, 05h, 04h
		db	 00h, 04h, 00h, 05h, 04h, 04h
		db	 00h, 05h, 04h, 05h, 00h, 09h
		db	 09h, 09h, 09h, 8Ah, 5Ch, 04h
		db	 80h,0E3h, 0Fh, 32h,0FFh, 03h
		db	0DBh,0FFh,0A7h, 77h,0A3h, 84h
		db	0A3h, 83h,0A3h,0D8h,0A6h,0A4h
		db	0A7h, 23h,0A9h, 23h,0A9h,0C3h
		db	0F6h, 44h, 08h,0FFh, 75h, 04h
		db	0C6h, 44h, 08h, 08h,0F6h, 44h
		db	 05h, 20h, 74h, 03h,0E9h, 14h
		db	 03h
loc_1:
		test	byte ptr [si+15h],40h	; '@'
		jz	loc_2			; Jump if zero
		jmp	loc_39
loc_2:
		call	sub_5
		jc	loc_3			; Jump if carry Set
		retn
loc_3:
		test	byte ptr [si+9],1
		jz	loc_4			; Jump if zero
		jmp	loc_19
loc_4:
		call	sub_7
		jc	loc_10			; Jump if carry Set
		cmp	al,0FFh
		je	loc_5			; Jump if equal
		xor	byte ptr [si+5],80h
loc_5:
		add	byte ptr [si+6],80h
		jc	loc_6			; Jump if carry Set
		jmp	loc_40
loc_6:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		test	byte ptr [si+5],80h
		jnz	loc_8			; Jump if not zero
		call	sub_3
		jc	loc_7			; Jump if carry Set
		jmp	loc_40
loc_7:
		or	byte ptr [si+5],80h
		jmp	loc_40
loc_8:
		call	sub_1
		jc	loc_9			; Jump if carry Set
		jmp	loc_40
loc_9:
		and	byte ptr [si+5],7Fh
		jmp	loc_40
loc_10:
		and	byte ptr [si+5],7Fh
		mov	al,11h
		cmp	al,[si+3]
		jb	loc_11			; Jump if below
		or	byte ptr [si+5],80h
loc_11:
		test	byte ptr [si+5],80h
		jz	loc_13			; Jump if zero
		sub	al,[si+3]
		cmp	al,ds:data_35e
		je	loc_15			; Jump if equal
		jc	loc_12			; Jump if carry Set
		call	sub_1
		jc	loc_15			; Jump if carry Set
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	loc_40
loc_12:
		call	sub_3
		jc	loc_17			; Jump if carry Set
		dec	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	loc_40
loc_13:
		mov	ah,[si+3]
		sub	ah,al
		cmp	ah,ds:data_36e
		je	loc_15			; Jump if equal
		jc	loc_14			; Jump if carry Set
		call	sub_3
		jc	loc_15			; Jump if carry Set
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	loc_40
loc_14:
		call	sub_1
		jc	loc_17			; Jump if carry Set
		dec	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	loc_40
loc_15:
		call	word ptr cs:data_6+4	; ('EF')
		and	al,3
		dec	al
		add	al,8
		mov	ds:data_35e,al
		call	word ptr cs:data_6+4	; ('EF')
		and	al,3
		sub	al,2
		add	al,9
		mov	ds:data_36e,al
		call	sub_7
		jc	loc_16			; Jump if carry Set
		jmp	loc_40
loc_16:
		or	byte ptr [si+9],1
		mov	byte ptr [si+6],4
		jmp	loc_40
loc_17:
		call	word ptr cs:data_6+4	; ('EF')
		and	al,1
		jz	loc_18			; Jump if zero
		retn
loc_18:
		or	byte ptr [si+9],3
		mov	byte ptr [si+6],4
		jmp	loc_40
loc_19:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],6
		je	loc_21			; Jump if equal
		cmp	byte ptr [si+6],8
		je	loc_20			; Jump if equal
		jmp	loc_40
loc_20:
		and	byte ptr [si+9],0FCh
		mov	byte ptr [si+6],0
		jmp	loc_40
loc_21:
		mov	al,[si+3]
		mov	ds:data_29e,al
		mov	ds:data_33e,al
		inc	al
		mov	ds:data_27e,al
		mov	ds:data_31e,al
		mov	al,[si+2]
		add	al,2
		mov	ds:data_30e,al
		mov	ds:data_28e,al
		mov	ds:data_34e,al
		mov	ds:data_32e,al
		mov	bx,0A4FDh
		mov	ax,0A517h
		test	byte ptr [si+5],80h
		jnz	loc_22			; Jump if not zero
		mov	bx,0A50Ah
		mov	ax,0A524h
loc_22:
		test	byte ptr [si+9],2
		jz	loc_23			; Jump if zero
		xchg	bx,ax
loc_23:
		call	word ptr cs:data_26e
		jmp	loc_40
		db	 00h, 00h, 9Ah, 00h,0FFh, 40h
		db	 08h, 00h, 00h, 31h,0A5h, 00h
		db	 00h, 00h, 00h, 9Ah, 00h,0FFh
		db	 40h, 08h, 00h, 00h, 3Dh,0A5h
		db	 00h, 00h, 00h, 00h, 9Ah, 00h
		db	 07h, 00h, 14h
		db	8 dup (0)
		db	 9Ah, 00h, 07h, 04h, 14h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 01h
		db	 01h, 01h, 00h, 00h, 07h, 07h
		db	 07h, 07h, 07h, 07h,0FFh, 03h
		db	 03h, 03h, 04h, 04h, 05h, 05h
		db	 05h, 05h, 05h, 05h,0FFh

_302MAPBC	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	loc_24			; Jump if carry=0
		retn
loc_24:
		call	sub_2
		jnc	loc_25			; Jump if carry=0
		retn
loc_25:
		mov	bx,[si]
		inc	bx
		mov	ax,ds:data_43e
		sub	ax,bx
		jnz	loc_26			; Jump if not zero
		xchg	bx,ax
loc_26:
		mov	[si],bx
		mov	[si+10h],bx
		inc	byte ptr [si+3]
		inc	byte ptr [si+13h]
		clc				; Clear carry flag
		retn
sub_1		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		mov	ax,[si+2]
		call	word ptr cs:data_19e
		inc	di
		inc	di
		mov	cx,4

locloop_27:
		mov	al,[di]
		call	word ptr cs:data_22e
		stc				; Set carry flag
		jz	loc_28			; Jump if zero
		retn
loc_28:
		xchg	si,di
		add	si,24h
		call	word ptr cs:data_20e
		xchg	si,di
		loop	locloop_27		; Loop if cx > 0

		xchg	si,di
		sub	si,24h
		call	word ptr cs:data_21e
		mov	al,[si]
		sub	si,24h
		call	word ptr cs:data_21e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_21e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_21e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_21e
		or	al,[si]
		xchg	si,di
		add	al,al
		retn
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		cmp	byte ptr [si+3],2
		jae	loc_29			; Jump if above or =
		retn
loc_29:
		call	sub_4
		jnc	loc_30			; Jump if carry=0
		retn
loc_30:
		mov	ax,[si]
		dec	ax
		cmp	ax,0FFFFh
		jne	loc_31			; Jump if not equal
		mov	ax,ds:data_43e
		dec	ax
loc_31:
		mov	[si],ax
		mov	[si+10h],ax
		dec	byte ptr [si+3]
		dec	byte ptr [si+13h]
		clc				; Clear carry flag
		retn
sub_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		mov	ax,[si+2]
		call	word ptr cs:data_19e
		dec	di
		mov	cx,4

locloop_32:
		mov	al,[di]
		call	word ptr cs:data_22e
		stc				; Set carry flag
		jz	loc_33			; Jump if zero
		retn
loc_33:
		xchg	si,di
		add	si,24h
		call	word ptr cs:data_20e
		xchg	si,di
		loop	locloop_32		; Loop if cx > 0

		dec	di
		xchg	si,di
		sub	si,24h
		call	word ptr cs:data_21e
		mov	al,[si]
		sub	si,24h
		call	word ptr cs:data_21e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_21e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_21e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_21e
		or	al,[si]
		xchg	si,di
		add	al,al
		retn
sub_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		test	byte ptr [si+3],0FFh
		stc				; Set carry flag
		jnz	loc_34			; Jump if not zero
		retn
loc_34:
		cmp	byte ptr [si+3],23h	; '#'
		stc				; Set carry flag
		jnz	loc_35			; Jump if not zero
		retn
loc_35:
		call	sub_6
		jnc	loc_36			; Jump if carry=0
		retn
loc_36:
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		inc	byte ptr [si+12h]
		and	byte ptr [si+12h],3Fh	; '?'
		clc				; Clear carry flag
		retn
sub_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		mov	ax,[si+2]
		call	word ptr cs:data_19e
		xchg	si,di
		add	si,offset data_3
		call	word ptr cs:data_20e
		xchg	si,di
		mov	cx,2

locloop_37:
		mov	al,[di]
		call	word ptr cs:data_22e
		stc				; Set carry flag
		jz	loc_38			; Jump if zero
		retn
loc_38:
		inc	di
		loop	locloop_37		; Loop if cx > 0

		dec	di
		mov	al,[di]
		or	al,[di-1]
		or	al,[di-1]
		add	al,al
		retn
sub_6		endp

loc_39:
		mov	al,[si+15h]
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:data_25e
loc_40:
		mov	al,[si+6]
		mov	[si+16h],al
		mov	al,[si+5]
		and	al,80h
		mov	ah,[si+15h]
		and	ah,7Fh
		or	al,ah
		mov	[si+15h],al
		retn
			                        ;* No entry point to code
		or	[bx+si],cl
		test	byte ptr [si+8],0FFh
		jnz	loc_41			; Jump if not zero
		mov	byte ptr [si+8],4
loc_41:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_42			; Jump if zero
		jmp	word ptr cs:data_25e
loc_42:
		call	word ptr cs:data_17e
		jc	loc_43			; Jump if carry Set
		retn
loc_43:
		test	byte ptr [si+9],1
		jnz	loc_45			; Jump if not zero
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		jz	loc_44			; Jump if zero
		retn
loc_44:
		or	byte ptr [si+9],1
		and	byte ptr [si+9],0FDh
		mov	byte ptr [si+0Ah],0
		retn
loc_45:
		test	byte ptr [si+9],2
		jnz	loc_50			; Jump if not zero
		mov	al,[si+0Ah]
		and	al,3
		add	al,8
		mov	[si+6],al
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],8
		je	loc_46			; Jump if equal
		retn
loc_46:
		or	byte ptr [si+9],2
		call	word ptr cs:data_6+4	; ('EF')
		or	al,al			; Zero ?
		js	loc_48			; Jump if sign=1
		mov	ax,[si+2]
		call	word ptr cs:data_19e
		xchg	si,di
		add	si,4Ah
		call	word ptr cs:data_20e
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:data_22e
		jz	loc_47			; Jump if zero
		jmp	word ptr cs:data_11e
loc_47:
		jmp	word ptr cs:data_15e
loc_48:
		mov	ax,[si+2]
		call	word ptr cs:data_19e
		xchg	si,di
		add	si,47h
		call	word ptr cs:data_20e
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:data_22e
		jz	loc_49			; Jump if zero
		jmp	word ptr cs:data_15e
loc_49:
		jmp	word ptr cs:data_11e
loc_50:
		mov	al,[si+0Ah]
		and	al,3
		add	al,8
		mov	[si+6],al
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],0Ch
		je	loc_51			; Jump if equal
		retn
loc_51:
		and	byte ptr [si+9],0FEh
		mov	byte ptr [si+6],0
		retn
			                        ;* No entry point to code
		call	word ptr cs:data_23e
		jnz	loc_52			; Jump if not zero
		jmp	word ptr cs:data_24e
loc_52:
		test	byte ptr [si+8],0FFh
		jnz	loc_53			; Jump if not zero
		mov	byte ptr [si+8],2
loc_53:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_54			; Jump if zero
		jmp	word ptr cs:data_25e
loc_54:
		test	byte ptr [si+9],2
		jz	loc_55			; Jump if zero
		jmp	loc_68
loc_55:
		test	byte ptr [si+9],4
		jz	loc_56			; Jump if zero
		jmp	loc_65
loc_56:
		test	byte ptr [si+9],8
		jnz	loc_61			; Jump if not zero
		add	byte ptr [si+6],21h	; '!'
		and	byte ptr [si+6],0E1h
		call	word ptr cs:data_17e
		jc	loc_57			; Jump if carry Set
		retn
loc_57:
		call	sub_7
		jc	loc_59			; Jump if carry Set
		mov	al,[si+6]
		and	al,0E0h
		jz	loc_58			; Jump if zero
		retn
loc_58:
		call	sub_7
		cmp	al,0FFh
		je	loc_59			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		mov	byte ptr [si+6],2
		or	byte ptr [si+9],8
		retn
loc_59:
		call	word ptr cs:data_6+4	; ('EF')
		and	al,1
		jnz	loc_60			; Jump if not zero
		or	byte ptr [si+9],4
		mov	byte ptr [si+0Ah],0
		retn
loc_60:
		mov	byte ptr [si+6],2
		or	byte ptr [si+9],8
loc_61:
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,7
		cmp	al,7
		jae	loc_64			; Jump if above or =
		mov	ch,ah
		and	ch,0F0h
		or	al,ch
		mov	[si+6],al
		mov	bx,0A8ECh
		test	byte ptr [si+5],80h
		jnz	loc_62			; Jump if not zero
		mov	bx,data_41e
loc_62:
		mov	al,ah
		sub	al,2
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_10e
		jc	loc_63			; Jump if carry Set
		retn
loc_63:
		call	sub_7
		jc	loc_64			; Jump if carry Set
		xor	byte ptr [si+5],80h
loc_64:
		and	byte ptr [si+9],0F7h
		mov	byte ptr [si+6],0
		jmp	word ptr cs:data_17e
loc_65:
		inc	byte ptr [si+0Ah]
		inc	byte ptr [si+6]
		and	byte ptr [si+6],1
		cmp	byte ptr [si+0Ah],4
		je	loc_66			; Jump if equal
		retn
loc_66:
		mov	byte ptr [si+6],7
		mov	al,[si+3]
		mov	ds:data_39e,al
		inc	al
		mov	ds:data_37e,al
		mov	al,[si+2]
		inc	al
		and	al,3Fh			; '?'
		mov	ds:data_40e,al
		mov	ds:data_38e,al
		mov	bx,0A8D2h
		test	byte ptr [si+5],80h
		jnz	loc_67			; Jump if not zero
		mov	bx,0A8DFh
loc_67:
		call	word ptr cs:data_26e
		and	byte ptr [si+9],0FBh
		or	byte ptr [si+9],2
		mov	byte ptr [si+0Ah],0
		retn
loc_68:
		inc	byte ptr [si+0Ah]
		inc	byte ptr [si+6]
		and	byte ptr [si+6],1
		cmp	byte ptr [si+0Ah],6
		je	loc_69			; Jump if equal
		retn
loc_69:
		and	byte ptr [si+9],0FDh
		retn
		db	 00h, 00h, 9Eh, 00h, 06h, 00h
		db	 14h
		db	8 dup (0)
		db	 9Eh, 00h, 06h, 04h, 14h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 01h
		db	 00h, 00h, 07h, 03h, 04h, 04h
		db	 05h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		mov	al,ds:data_44e
		sub	al,[si+2]
		jns	loc_70			; Jump if not sign
		neg	al
loc_70:
		cmp	al,5
		mov	al,0FFh
		jc	loc_71			; Jump if carry Set
		retn
loc_71:
		cmp	byte ptr [si+3],11h
		jae	loc_73			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	loc_72			; Jump if zero
		retn
loc_72:
		clc				; Clear carry flag
		retn
loc_73:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	loc_74			; Jump if not zero
		retn
loc_74:
		clc				; Clear carry flag
		retn
sub_7		endp

			                        ;* No entry point to code
		call	word ptr cs:data_23e
		jnz	loc_75			; Jump if not zero
		jmp	word ptr cs:data_24e
loc_75:
		test	byte ptr [si+8],0FFh
		jnz	loc_76			; Jump if not zero
		mov	byte ptr [si+8],3
loc_76:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_77			; Jump if zero
		jmp	word ptr cs:data_25e
loc_77:
		mov	bl,[si+9]
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_42e[bx]	;*
			                        ;* No entry point to code
		pop	si
		test	ax,0A989h
		pushf				; Push flags
		test	ax,0AA3Ch
		call	word ptr cs:data_13e
		test	byte ptr [si+6],0FFh
		jz	loc_78			; Jump if zero
		sub	byte ptr [si+6],10h
		retn
loc_78:
		mov	al,[si+3]
		sub	al,11h
		cmp	al,0Ah
		jb	loc_79			; Jump if below
		mov	al,11h
		sub	al,[si+3]
		cmp	al,7
		jae	loc_80			; Jump if above or =
loc_79:
		mov	byte ptr [si+9],40h	; '@'
loc_80:
		mov	byte ptr [si+6],0
		retn
			                        ;* No entry point to code
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],3
		je	loc_81			; Jump if equal
		retn
loc_81:
		mov	byte ptr [si+9],80h
		retn
			                        ;* No entry point to code
		call	sub_8
		test	byte ptr ds:data_45e,0FFh
		jz	loc_82			; Jump if zero
		mov	byte ptr [si+9],0C0h
		retn
loc_82:
		mov	al,ds:data_44e
		sub	al,[si+2]
		add	al,15h
		and	al,3Fh			; '?'
		cmp	al,12h
		jb	loc_87			; Jump if below
		cmp	al,18h
		jb	loc_84			; Jump if below
		cmp	byte ptr [si+3],11h
		je	loc_89			; Jump if equal
		cmp	byte ptr [si+3],10h
		je	loc_89			; Jump if equal
		jnc	loc_83			; Jump if carry=0
		call	word ptr cs:data_18e
		jc	loc_85			; Jump if carry Set
		or	byte ptr [si+5],80h
		retn
loc_83:
		call	word ptr cs:data_16e
		jc	loc_86			; Jump if carry Set
		and	byte ptr [si+5],7Fh
		retn
loc_84:
		cmp	byte ptr [si+3],11h
		je	loc_89			; Jump if equal
		cmp	byte ptr [si+3],10h
		je	loc_89			; Jump if equal
		jnc	loc_86			; Jump if carry=0
loc_85:
		call	word ptr cs:data_11e
		jc	loc_89			; Jump if carry Set
		or	byte ptr [si+5],80h
		retn
loc_86:
		call	word ptr cs:data_15e
		jc	loc_89			; Jump if carry Set
		and	byte ptr [si+5],7Fh
		retn
loc_87:
		cmp	byte ptr [si+3],11h
		je	loc_89			; Jump if equal
		cmp	byte ptr [si+3],10h
		je	loc_89			; Jump if equal
		jnc	loc_88			; Jump if carry=0
		call	word ptr cs:data_12e
		jc	loc_85			; Jump if carry Set
		or	byte ptr [si+5],80h
		retn
loc_88:
		call	word ptr cs:data_14e
		jc	loc_86			; Jump if carry Set
		and	byte ptr [si+5],7Fh
		retn
loc_89:
		call	word ptr cs:data_17e
		jc	loc_90			; Jump if carry Set
		retn
loc_90:
		mov	byte ptr [si+9],0C0h
		retn
			                        ;* No entry point to code
		test	byte ptr [si+9],20h	; ' '
		jnz	loc_96			; Jump if not zero
		call	sub_8
		test	byte ptr [si+5],80h
		jz	loc_92			; Jump if zero
		call	word ptr cs:data_12e
		jc	loc_91			; Jump if carry Set
		retn
loc_91:
		and	byte ptr [si+5],7Fh
		jmp	short loc_94
loc_92:
		call	word ptr cs:data_14e
		jc	loc_93			; Jump if carry Set
		retn
loc_93:
		or	byte ptr [si+5],80h
loc_94:
		call	word ptr cs:data_13e
		jc	loc_95			; Jump if carry Set
		retn
loc_95:
		or	byte ptr [si+9],20h	; ' '
		mov	byte ptr [si+6],2
		retn
loc_96:
		dec	byte ptr [si+6]
		and	byte ptr [si+6],7
		test	byte ptr [si+6],0FFh
		jz	loc_97			; Jump if zero
		retn
loc_97:
		mov	byte ptr [si+6],70h	; 'p'
		mov	byte ptr [si+9],0
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],7
		jae	loc_98			; Jump if above or =
		retn
loc_98:
		mov	byte ptr [si+6],3
		retn
sub_8		endp


seg_a		ends



		end	start
