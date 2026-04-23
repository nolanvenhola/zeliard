
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_307MAPIC                                €€
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
data_12e	equ	6010h			;*
data_13e	equ	6014h			;*
data_14e	equ	6028h			;*
data_15e	equ	602Ah			;*
data_16e	equ	602Ch			;*
data_17e	equ	602Eh			;*
data_18e	equ	6030h			;*
data_19e	equ	6032h			;*
data_20e	equ	6034h			;*
data_21e	equ	603Ah			;*
data_22e	equ	8A89h			;*
data_23e	equ	8B8Ah			;*
data_24e	equ	9291h			;*
data_25e	equ	0A1A0h			;*
data_26e	equ	0A460h			;*
data_27e	equ	0A461h			;*
data_28e	equ	0A46Dh			;*
data_29e	equ	0A46Eh			;*
data_30e	equ	0A491h			;*
data_31e	equ	0A492h			;*
data_32e	equ	0A701h			;*
data_33e	equ	0A704h			;*
data_34e	equ	0A705h			;*
data_35e	equ	0A711h			;*
data_36e	equ	0A712h			;*
data_37e	equ	0A8C7h			;*
data_38e	equ	0C002h			;*
data_39e	equ	0FF35h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_307MAPIC	proc	far

start:
		iret				; Interrupt return
		db	 08h, 00h, 00h,0F1h,0A2h, 00h
		db	 00h, 00h, 00h,0DBh,0A2h, 50h
		db	 50h,0C8h,0C8h, 32h, 00h, 00h
		db	 00h, 50h, 50h, 50h, 50h, 28h
		db	 00h
		db	26 dup (0)
		db	0B0h,0A0h, 0Fh,0A1h, 6Eh,0A1h
		db	0CDh,0A1h, 2Ch,0A2h
		db	7 dup (0)
		db	0A1h, 5Fh,0A1h,0BEh,0A1h, 1Dh
		db	0A2h, 54h,0A2h
		db	10 dup (0)
		db	 63h,0A2h,0AEh,0A2h, 72h,0A2h
		db	 86h,0A2h,0CCh,0A2h, 00h, 00h
		db	0D1h,0A2h,0D6h,0A2h, 00h, 00h
		db	 9Ah,0A2h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0D8h,0A0h
		db	 37h,0A1h, 96h,0A1h,0F5h,0A1h
		db	 40h,0A2h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 00h,0A1h, 5Fh,0A1h
		db	0BEh,0A1h, 1Dh,0A2h, 54h,0A2h
		db	0, 0
data_5		db	0
		db	7 dup (0)
		db	 63h,0A2h,0AEh,0A2h, 72h,0A2h
		db	 86h,0A2h,0CCh,0A2h, 00h, 00h
		db	0D1h,0A2h,0D6h,0A2h, 00h, 00h
		db	 9Ah,0A2h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 00h,0B0h
		db	0B1h,0B2h,0B3h, 00h,0B8h,0B9h
		db	0BAh,0BBh, 00h,0B0h,0B1h,0C0h
		db	0B3h, 00h,0B8h,0B9h,0BAh,0BBh
		db	 00h,0B0h,0B1h,0B2h,0B3h, 00h
		db	0B0h,0B1h,0B2h,0B3h, 00h,0D1h
		db	0D2h,0D3h,0D4h, 00h,0D1h,0D2h
		db	0D3h,0D4h, 00h,0D7h,0D8h,0D9h
		db	 11h, 00h, 26h, 27h, 28h, 35h
		db	 00h,0D7h,0D8h,0D9h, 58h, 00h
		db	 26h, 27h, 28h, 35h, 00h,0D7h
		db	0D8h, 81h, 82h, 00h,0D7h,0D8h
		db	 81h, 82h, 00h, 97h, 98h, 99h
		db	 9Ah, 00h, 97h, 98h, 99h, 9Ah
		db	 00h, 7Fh, 80h,0A9h,0CDh, 00h
		db	 00h, 00h,0CBh,0CCh, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B4h,0B5h
		db	0B6h,0B7h, 00h,0BCh
data_6		dw	0BEBDh
		db	0BFh, 00h,0C1h,0C2h,0C3h,0C4h
		db	 00h,0BCh,0BDh,0BEh,0BFh, 00h
		db	0C7h,0C8h,0C9h,0CAh, 00h,0C7h
		db	0C8h,0C9h,0CAh, 00h,0D5h,0D6h
		db	0C9h,0CAh, 00h,0D5h,0D6h,0C9h
		db	0CAh, 00h, 12h, 13h, 14h, 25h
		db	 00h, 3Ch, 43h, 4Ah, 51h, 00h
		db	 5Fh, 66h, 7Dh, 7Eh, 00h, 3Ch
		db	 43h, 4Ah, 51h, 00h, 83h, 94h
		db	 95h, 96h, 00h, 83h, 94h, 95h
		db	 96h, 00h, 9Bh,0AFh, 95h, 96h
		db	 00h, 9Bh,0AFh, 95h, 96h, 00h
		db	0CEh,0C5h,0C6h, 00h, 00h,0CDh
		db	0C5h,0CEh, 00h, 00h,0CFh,0D0h
		db	0DAh,0DBh, 01h, 00h, 00h, 36h
		db	 37h, 01h, 00h, 00h, 3Dh, 3Eh
		db	 01h, 00h, 00h, 44h, 45h, 01h
		db	 00h, 00h, 4Bh, 4Ch, 01h
data_7		dw	6Dh			; Data table (indexed access)
		db	 6Fh, 70h, 01h, 6Dh, 00h, 6Fh
		db	 70h, 01h, 75h, 76h, 77h, 78h
		db	 01h, 75h, 76h, 77h, 78h, 01h
		db	 00h, 00h, 52h, 53h, 01h, 00h
		db	 00h, 59h, 5Ah, 01h, 00h, 00h
		db	 60h, 61h, 01h, 00h, 00h, 67h
		db	 68h, 01h, 00h, 85h, 86h, 87h
		db	 01h, 00h, 85h, 86h, 87h, 01h
		db	 8Ch, 8Dh, 8Eh, 8Fh, 01h, 8Ch
		db	 8Dh, 8Eh, 8Fh, 01h, 00h, 9Ch
		db	 9Dh, 9Eh, 01h,0A3h,0A4h,0A5h
		db	0A6h, 01h,0AAh,0ABh,0ACh, 00h
		db	 01h, 38h, 39h, 3Ah, 3Bh, 01h
		db	 3Fh, 40h, 41h, 42h, 01h, 46h
		db	 47h, 48h, 49h, 01h, 4Dh, 4Eh
		db	 4Fh, 50h, 01h, 71h, 72h, 73h
		db	 74h, 01h, 71h, 72h, 73h, 74h
		db	 01h, 79h, 7Ah, 7Bh, 7Ch, 01h
		db	 79h, 7Ah, 7Bh, 7Ch, 01h, 54h
		db	 55h, 56h, 57h, 01h, 5Bh, 5Ch
		db	 5Dh, 5Eh, 01h, 62h, 63h, 64h
		db	 65h, 01h
		db	 69h, 6Ah, 6Bh, 6Ch
loc_1:
		add	ds:data_22e[bx+si],cx
		mov	ax,[bx+di]
		mov	ds:data_23e[bx+di],cl
		add	ds:data_24e[bx+si],dx
		xchg	bx,ax
		add	ds:data_24e[bx+si],dx
		xchg	bx,ax
		add	ds:data_25e[bx],bx
		mov	ds:data_32e,al
		test	al,0
		add	[bx+di],al
		db	 00h, 00h, 00h, 00h, 02h, 01h
		db	 02h, 03h, 04h, 02h, 05h, 06h
		db	 07h, 08h, 02h, 09h, 0Ah, 0Bh
		db	 0Ch, 02h, 0Dh, 0Eh, 0Fh, 10h
		db	 02h, 15h, 16h, 17h, 18h, 02h
		db	 19h, 1Ah, 1Bh, 1Ch, 02h, 1Dh
		db	 1Eh, 1Fh, 20h, 02h, 21h, 22h
		db	 23h, 24h, 02h, 29h, 2Ah, 2Bh
		db	 2Ch, 02h, 2Dh, 2Eh, 2Fh, 30h
		db	 02h, 31h, 32h, 33h, 34h, 01h
		db	0DCh,0DDh,0DEh,0DFh, 01h,0E0h
		db	0E1h,0E2h
loc_3:
;*		jcxz	loc_4			;*Jump if cx=0
		db	0E3h, 01h		;  Fixup - byte match
		in	al,0E5h			; port 0E5h ??I/O Non-standard
		out	0E7h,al			; port 0E7h ??I/O Non-standard
;*		add	al,ch
		db	 00h,0E8h		;  Fixup - byte match
		jmp	$-1413h
		db	 00h,0ECh,0EDh,0EEh,0EFh, 00h
		db	0F0h,0F1h,0F2h,0F3h, 00h,0ECh
		db	0EDh,0EEh,0EFh, 02h,0E8h,0E9h
		db	0EAh,0EBh, 02h,0ECh,0EDh,0EEh
		db	0EFh, 02h,0F0h,0F1h,0F2h,0F3h
		db	 02h,0ECh,0EDh,0EEh,0EFh, 01h
		db	0E8h,0E9h,0EAh,0EBh, 01h,0ECh
		db	0EDh,0EEh,0EFh, 01h,0F0h,0F1h
		db	0F2h,0F3h, 01h,0ECh,0EDh,0EEh
		db	0EFh, 00h,0F4h,0F5h,0F6h,0F7h
		db	 00h,0F4h,0F5h,0F6h,0F7h, 00h
		db	0F4h,0F5h,0F6h,0F7h, 00h,0F4h
		db	0F5h,0F6h,0F7h, 00h,0F4h,0F5h
		db	0F6h,0F7h, 00h,0F4h,0F5h,0F6h
		db	0F7h, 01h,0F8h,0F9h,0FAh,0FBh
		db	 00h,0FCh,0FDh, 6Eh, 84h, 02h
		db	0FCh,0FDh, 6Eh, 84h,0E5h,0A2h
		db	0E5h,0A2h,0E9h,0A2h,0E9h,0A2h
		db	0EDh,0A2h, 0Bh, 0Bh, 0Bh, 05h
		db	 0Bh, 0Bh, 0Bh, 05h, 0Bh, 05h
		db	 05h, 00h, 8Ah, 5Ch, 04h, 80h
		db	0E3h, 0Fh, 32h,0FFh, 03h,0DBh
		db	0FFh,0A7h,0FFh,0A2h, 0Ah,0A3h
		db	 09h,0A3h, 39h,0A6h, 38h,0A6h
		db	 49h,0A7h,0C3h,0F6h, 44h, 08h
		db	0FFh, 75h, 04h,0C6h, 44h, 08h
		db	 10h
loc_5:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_6			; Jump if zero
		jmp	loc_42
loc_6:
		test	byte ptr [si+15h],40h	; '@'
		jz	loc_7			; Jump if zero
		jmp	loc_42
loc_7:
		call	sub_5
		jc	loc_8			; Jump if carry Set
		retn
loc_8:
		test	byte ptr [si+9],1
		jz	loc_9			; Jump if zero
		jmp	loc_23
loc_9:
		call	sub_7
		jc	loc_15			; Jump if carry Set
		cmp	al,0FFh
		je	loc_10			; Jump if equal
		xor	byte ptr [si+5],80h
loc_10:
		add	byte ptr [si+6],80h
		jc	loc_11			; Jump if carry Set
		jmp	loc_26
loc_11:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		test	byte ptr [si+5],80h
		jnz	loc_13			; Jump if not zero
		call	sub_3
		jc	loc_12			; Jump if carry Set
		jmp	loc_26
loc_12:
		or	byte ptr [si+5],80h
		jmp	loc_26
loc_13:
		call	sub_1
		jc	loc_14			; Jump if carry Set
		jmp	loc_26
loc_14:
		and	byte ptr [si+5],7Fh
		jmp	loc_26
loc_15:
		and	byte ptr [si+5],7Fh
		mov	al,11h
		cmp	al,[si+3]
		jb	loc_16			; Jump if below
		or	byte ptr [si+5],80h
loc_16:
		test	byte ptr [si+5],80h
		jz	loc_18			; Jump if zero
		sub	al,[si+3]
		cmp	al,ds:data_30e
		je	loc_20			; Jump if equal
		jc	loc_17			; Jump if carry Set
		call	sub_1
		jc	loc_20			; Jump if carry Set
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	loc_26
loc_17:
		call	sub_3
		jc	loc_21			; Jump if carry Set
		dec	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	loc_26
loc_18:
		mov	ah,[si+3]
		sub	ah,al
		cmp	ah,ds:data_31e
		je	loc_20			; Jump if equal
		jc	loc_19			; Jump if carry Set
		call	sub_3
		jc	loc_20			; Jump if carry Set
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	loc_26
loc_19:
		call	sub_1
		jc	loc_21			; Jump if carry Set
		dec	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	loc_26
loc_20:
		call	word ptr cs:data_6
		and	al,3
		dec	al
		add	al,8
		mov	ds:data_30e,al
		call	word ptr cs:data_6
		and	al,3
		sub	al,2
		add	al,9
		mov	ds:data_31e,al
		call	sub_7
		jnc	loc_26			; Jump if carry=0
		or	byte ptr [si+9],1
		mov	byte ptr [si+6],4
		jmp	short loc_26
loc_21:
		call	word ptr cs:data_6
		and	al,1
		jz	loc_22			; Jump if zero
		retn
loc_22:
		or	byte ptr [si+9],3
		mov	byte ptr [si+6],4
		jmp	short loc_26
loc_23:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],6
		je	loc_24			; Jump if equal
		cmp	byte ptr [si+6],8
		jne	loc_26			; Jump if not equal
		and	byte ptr [si+9],0FCh
		mov	byte ptr [si+6],0
		jmp	short loc_26
loc_24:
		mov	al,[si+3]
		mov	ds:data_28e,al
		inc	al
		mov	ds:data_26e,al
		mov	al,[si+2]
		inc	al
		mov	ds:data_29e,al
		mov	ds:data_27e,al
		mov	bx,0A460h
		test	byte ptr [si+5],80h
		jnz	loc_25			; Jump if not zero
		mov	bx,0A46Dh
loc_25:
		call	word ptr cs:data_21e
		jmp	short loc_26
		db	 00h, 00h, 30h, 00h, 14h, 00h
		db	 28h, 00h
		db	7 dup (0)
		db	 2Fh, 00h, 14h, 04h, 28h, 00h
		db	 00h, 00h, 00h, 00h, 00h
loc_26:
		mov	al,[si+6]
		mov	[si+16h],al
		mov	al,[si+5]
		and	al,80h
		mov	ah,[si+15h]
		and	ah,7Fh
		or	al,ah
		mov	[si+15h],al
		retn
		db	8, 8

_307MAPIC	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	loc_27			; Jump if carry=0
		retn
loc_27:
		call	sub_2
		jnc	loc_28			; Jump if carry=0
		retn
loc_28:
		mov	bx,[si]
		inc	bx
		mov	ax,ds:data_38e
		sub	ax,bx
		jnz	loc_29			; Jump if not zero
		xchg	bx,ax
loc_29:
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
		call	word ptr cs:data_14e
		inc	di
		inc	di
		mov	cx,4

locloop_30:
		mov	al,[di]
		call	word ptr cs:data_17e
		stc				; Set carry flag
		jz	loc_31			; Jump if zero
		retn
loc_31:
		xchg	si,di
		add	si,24h
		call	word ptr cs:data_15e
		xchg	si,di
		loop	locloop_30		; Loop if cx > 0

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
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		cmp	byte ptr [si+3],2
		jae	loc_32			; Jump if above or =
		retn
loc_32:
		call	sub_4
		jnc	loc_33			; Jump if carry=0
		retn
loc_33:
		mov	ax,[si]
		dec	ax
		cmp	ax,0FFFFh
		jne	loc_34			; Jump if not equal
		mov	ax,ds:data_38e
		dec	ax
loc_34:
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
		call	word ptr cs:data_14e
		dec	di
		mov	cx,4

locloop_35:
		mov	al,[di]
		call	word ptr cs:data_17e
		stc				; Set carry flag
		jz	loc_36			; Jump if zero
		retn
loc_36:
		xchg	si,di
		add	si,24h
		call	word ptr cs:data_15e
		xchg	si,di
		loop	locloop_35		; Loop if cx > 0

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
sub_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		test	byte ptr [si+3],0FFh
		stc				; Set carry flag
		jnz	loc_37			; Jump if not zero
		retn
loc_37:
		cmp	byte ptr [si+3],23h	; '#'
		stc				; Set carry flag
		jnz	loc_38			; Jump if not zero
		retn
loc_38:
		call	sub_6
		jnc	loc_39			; Jump if carry=0
		retn
loc_39:
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
		call	word ptr cs:data_14e
		xchg	si,di
		add	si,offset data_5
		call	word ptr cs:data_15e
		xchg	si,di
		mov	cx,2

locloop_40:
		mov	al,[di]
		call	word ptr cs:data_17e
		stc				; Set carry flag
		jz	loc_41			; Jump if zero
		retn
loc_41:
		inc	di
		loop	locloop_40		; Loop if cx > 0

		dec	di
		mov	al,[di]
		or	al,[di-1]
		or	al,[di-1]
		add	al,al
		retn
sub_6		endp

loc_42:
		mov	al,[si+15h]
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:data_20e

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		mov	al,ds:data_39e
		sub	al,[si+2]
		jns	loc_43			; Jump if not sign
		neg	al
loc_43:
		cmp	al,5
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
sub_7		endp

			                        ;* No entry point to code
		retn
			                        ;* No entry point to code
		test	byte ptr [si+8],0FFh
		jnz	loc_48			; Jump if not zero
		mov	byte ptr [si+8],40h	; '@'
loc_48:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_49			; Jump if zero
		jmp	loc_61
loc_49:
		and	byte ptr [si+15h],0BFh
		call	sub_5
		jc	loc_50			; Jump if carry Set
		retn
loc_50:
		test	byte ptr [si+9],1
		jnz	loc_58			; Jump if not zero
		call	sub_7
		jc	loc_57			; Jump if carry Set
loc_51:
		add	byte ptr [si+6],80h
		jc	loc_52			; Jump if carry Set
		jmp	loc_62
loc_52:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		test	byte ptr [si+6],1
		jz	loc_53			; Jump if zero
		jmp	loc_62
loc_53:
		mov	al,10h
		cmp	al,[si+3]
		jb	loc_55			; Jump if below
		call	sub_1
		jnc	loc_54			; Jump if carry=0
		jmp	loc_62
loc_54:
		or	byte ptr [si+5],80h
		jmp	loc_62
loc_55:
		call	sub_3
		jnc	loc_56			; Jump if carry=0
		jmp	loc_62
loc_56:
		and	byte ptr [si+5],7Fh
		jmp	loc_62
loc_57:
		call	word ptr cs:data_6
		and	al,0C0h
		jnz	loc_51			; Jump if not zero
		mov	al,[si+6]
		not	al
		and	al,1
		jnz	loc_51			; Jump if not zero
		or	byte ptr [si+9],1
		mov	byte ptr [si+6],4
		jmp	short loc_62
loc_58:
		add	byte ptr [si+6],80h
		jnc	loc_62			; Jump if carry=0
		inc	byte ptr [si+6]
		mov	al,[si+6]
		and	al,7
		cmp	al,6
		je	loc_59			; Jump if equal
		or	al,al			; Zero ?
		jnz	loc_62			; Jump if not zero
		and	byte ptr [si+9],0FEh
		mov	byte ptr [si+6],3
		jmp	short loc_62
loc_59:
		mov	al,[si+3]
		mov	ds:data_35e,al
		inc	al
		mov	ds:data_33e,al
		mov	al,[si+2]
		inc	al
		mov	ds:data_36e,al
		mov	ds:data_34e,al
		mov	bx,0A704h
		test	byte ptr [si+5],80h
		jnz	loc_60			; Jump if not zero
		mov	bx,0A711h
loc_60:
		call	word ptr cs:data_21e
		jmp	short loc_62
		db	 00h, 00h, 32h, 00h, 14h, 00h
		db	 28h, 00h
		db	7 dup (0)
		db	 31h, 00h, 14h, 04h, 28h, 00h
		db	 00h, 00h, 00h, 00h, 00h
loc_61:
		mov	al,[si+5]
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:data_20e
loc_62:
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
		call	word ptr cs:data_18e
		jnz	loc_63			; Jump if not zero
		jmp	word ptr cs:data_19e
loc_63:
		test	byte ptr [si+8],0FFh
		jnz	loc_64			; Jump if not zero
		mov	byte ptr [si+8],8
loc_64:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_65			; Jump if zero
		jmp	word ptr cs:data_20e
loc_65:
		test	byte ptr [si+9],18h
		jz	loc_66			; Jump if zero
		jmp	loc_76
loc_66:
		call	word ptr cs:data_13e
		jc	loc_67			; Jump if carry Set
		retn
loc_67:
		test	byte ptr [si+9],2
		jnz	loc_68			; Jump if not zero
		call	sub_8
		jc	loc_68			; Jump if carry Set
		cmp	al,0FFh
		je	loc_68			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		or	byte ptr [si+9],2
		retn
loc_68:
		mov	ax,[si+2]
		call	word ptr cs:data_14e
		mov	ax,48h
		test	byte ptr [si+5],80h
		jz	loc_69			; Jump if zero
		inc	ax
loc_69:
		xchg	si,di
		add	si,ax
		call	word ptr cs:data_15e
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:data_17e
		jnz	loc_70			; Jump if not zero
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],8
		retn
loc_70:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		test	byte ptr [si+9],2
		jnz	loc_71			; Jump if not zero
		add	byte ptr [si+0Ah],10h
		jnc	loc_71			; Jump if carry=0
		xor	byte ptr [si+9],80h
		retn
loc_71:
		call	sub_8
		jnc	loc_72			; Jump if carry=0
		and	byte ptr [si+9],0FDh
loc_72:
		test	byte ptr [si+5],80h
		jz	loc_74			; Jump if zero
		call	word ptr cs:data_11e
		call	word ptr cs:data_11e
		jc	loc_73			; Jump if carry Set
		retn
loc_73:
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],10h
		retn
loc_74:
		call	word ptr cs:data_12e
		call	word ptr cs:data_12e
		jc	loc_75			; Jump if carry Set
		retn
loc_75:
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],10h
		retn
loc_76:
		add	byte ptr [si+9],20h	; ' '
		test	byte ptr [si+9],20h	; ' '
		jnz	loc_77			; Jump if not zero
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,3
		jz	loc_82			; Jump if zero
		and	ah,0F0h
		or	ah,al
		mov	[si+6],ah
loc_77:
		mov	al,[si+9]
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		dec	al
		and	al,7
		mov	bx,0A8BFh
		mov	cx,0A8B1h
		test	byte ptr [si+5],80h
		jnz	loc_78			; Jump if not zero
		mov	bx,data_37e
		mov	cx,0A8B8h
loc_78:
		test	byte ptr [si+9],10h
		jnz	loc_79			; Jump if not zero
		xchg	cx,bx
loc_79:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_10e
		jc	loc_80			; Jump if carry Set
		retn
loc_80:
		mov	byte ptr [si+9],0
		test	byte ptr [si+6],0FFh
		jnz	loc_81			; Jump if not zero
		retn
loc_81:
		mov	byte ptr [si+6],3
		retn
loc_82:
		and	byte ptr [si+9],0
		mov	byte ptr [si+6],3
		jmp	word ptr cs:data_13e

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		mov	al,ds:data_39e
		sub	al,[si+2]
		jns	loc_83			; Jump if not sign
		neg	al
loc_83:
		cmp	al,6
		mov	al,0FFh
		jc	loc_84			; Jump if carry Set
		retn
loc_84:
		cmp	byte ptr [si+3],11h
		jae	loc_86			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	loc_85			; Jump if zero
		retn
loc_85:
		clc				; Clear carry flag
		retn
loc_86:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	loc_87			; Jump if not zero
		retn
loc_87:
		clc				; Clear carry flag
		retn
sub_8		endp

			                        ;* No entry point to code
		add	[bx+di],ax
		add	[bx+si],al
		add	[bx],al
		pop	es
		add	ax,[bp+di]
		add	al,4
		add	al,5
		add	ax,102h
		add	[bx+si],ax
		add	[bx],al
		pop	es
		push	es
		add	al,[bp+di]
		add	ax,[si]
		add	al,5
		add	ax,6

seg_a		ends



		end	start
