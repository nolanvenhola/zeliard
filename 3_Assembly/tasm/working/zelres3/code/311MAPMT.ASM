
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_311MAPMT                                €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_11e	equ	200Ch			;*
data_12e	equ	6028h			;*
data_13e	equ	6036h			;*
data_14e	equ	6038h			;*
data_15e	equ	603Ah			;*
data_16e	equ	603Ch			;*
data_17e	equ	0A64Dh			;*
data_18e	equ	0A682h			;*
data_19e	equ	0A688h			;*
data_20e	equ	0A68Eh			;*
data_21e	equ	0A6CBh			;*
data_22e	equ	0A766h			;*
data_23e	equ	0A767h			;*
data_24e	equ	0A773h			;*
data_25e	equ	0A775h			;*
data_26e	equ	0A776h			;*
data_27e	equ	0A789h			;*
data_28e	equ	0A78Ah			;*
data_29e	equ	0A78Bh			;*
data_30e	equ	0A78Ch			;*
data_31e	equ	0A78Dh			;*
data_32e	equ	0A78Eh			;*
data_33e	equ	0A78Fh			;*
data_34e	equ	0A790h			;*
data_35e	equ	0A791h			;*
data_36e	equ	0A792h			;*
data_37e	equ	0A793h			;*
data_38e	equ	0A794h			;*
data_39e	equ	0A795h			;*
data_40e	equ	0A796h			;*
data_41e	equ	0A797h			;*
data_42e	equ	0A798h			;*
data_43e	equ	0A799h			;*
data_44e	equ	0A79Ah			;*
data_45e	equ	0A79Bh			;*
data_46e	equ	0A79Ch			;*
data_47e	equ	0C002h			;*
data_48e	equ	0C010h			;*
data_49e	equ	0ED20h			;*
data_50e	equ	0FF2Eh			;*
data_51e	equ	0FF2Fh			;*
data_52e	equ	0FF30h			;*
data_53e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_311MAPMT	proc	far

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
		call	word ptr cs:data_13e
		jc	loc_3			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:data_12e
		mov	bl,ds:data_27e
		xor	bh,bh			; Zero register
		mov	al,ds:data_49e[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	loc_3			; Jump if zero
		test	byte ptr ds:data_35e,80h
		jnz	loc_3			; Jump if not zero
		mov	al,[si+5]
		and	al,1Fh
		test	byte ptr [si+4],0FFh
		jnz	loc_2			; Jump if not zero
		or	al,80h
loc_2:
		mov	ds:data_35e,al
loc_3:
		inc	byte ptr ds:data_27e
		add	si,10h
		jmp	short loc_1
loc_4:
		mov	si,ds:data_48e
		mov	word ptr [si],0FFFh
		mov	al,ds:data_35e
		or	al,al			; Zero ?
		jz	loc_8			; Jump if zero
		push	ax
		and	al,1Fh
		call	word ptr cs:data_14e
		mov	bl,ah
		xor	bh,bh			; Zero register
		pop	ax
		add	bx,bx
		or	al,al			; Zero ?
		jns	loc_5			; Jump if not sign
		add	bx,bx
		add	bx,bx
loc_5:
		mov	byte ptr ds:data_53e,29h	; ')'
		call	sub_6
		test	byte ptr ds:data_30e,0FFh
		jz	loc_6			; Jump if zero
		mov	byte ptr ds:data_30e,0
		mov	byte ptr ds:data_31e,0
		mov	byte ptr ds:data_32e,0FFh
loc_6:
		jnz	loc_7			; Jump if not zero
		call	sub_5
loc_7:
		mov	byte ptr ds:data_39e,4
loc_8:
		mov	byte ptr ds:data_29e,0
		test	byte ptr ds:data_39e,0FFh
		jz	loc_9			; Jump if zero
		dec	byte ptr ds:data_39e
		mov	byte ptr ds:data_29e,1
loc_9:
		test	byte ptr ds:data_30e,0FFh
		jz	loc_14			; Jump if zero
		cmp	byte ptr ds:data_25e,0Eh
		je	loc_10			; Jump if equal
		dec	byte ptr ds:data_25e
loc_10:
		inc	byte ptr ds:data_31e
		and	byte ptr ds:data_31e,3
		cmp	byte ptr ds:data_31e,2
		jne	loc_11			; Jump if not equal
		mov	byte ptr ds:data_53e,2Bh	; '+'
loc_11:
		call	sub_4
		jc	loc_12			; Jump if carry Set
		test	byte ptr ds:data_45e,0FFh
		jz	loc_12			; Jump if zero
		dec	byte ptr ds:data_45e
		test	byte ptr ds:data_35e,0FFh
		jz	loc_13			; Jump if zero
loc_12:
		mov	byte ptr ds:data_30e,0
		mov	byte ptr ds:data_31e,0
		mov	byte ptr ds:data_32e,0FFh
		mov	byte ptr ds:data_53e,2Ah	; '*'
loc_13:
		jmp	loc_30
loc_14:
		test	byte ptr ds:data_32e,0FFh
		jz	loc_17			; Jump if zero
		cmp	byte ptr ds:data_31e,1
		jne	loc_15			; Jump if not equal
		mov	byte ptr ds:data_32e,0
		jmp	loc_30
loc_15:
		mov	byte ptr ds:data_31e,1
		cmp	byte ptr ds:data_25e,12h
		je	loc_16			; Jump if equal
		inc	byte ptr ds:data_25e
		mov	byte ptr ds:data_31e,0
		call	sub_3
loc_16:
		jmp	loc_30
loc_17:
		test	byte ptr ds:data_41e,0FFh
		jz	loc_20			; Jump if zero
		inc	byte ptr ds:data_34e
		and	byte ptr ds:data_34e,3
		call	sub_2
		jnc	loc_18			; Jump if carry=0
		jmp	loc_30
loc_18:
		cmp	byte ptr ds:data_42e,4
		jae	loc_19			; Jump if above or =
		inc	byte ptr ds:data_42e
		mov	byte ptr ds:data_53e,2Ah	; '*'
		mov	byte ptr ds:data_39e,4
		jmp	loc_30
loc_19:
		mov	byte ptr ds:data_41e,0
		mov	byte ptr ds:data_31e,0
		mov	byte ptr ds:data_30e,0FFh
		mov	byte ptr ds:data_45e,0Fh
		jmp	loc_30
loc_20:
		test	byte ptr ds:data_44e,0FFh
		jz	loc_23			; Jump if zero
		call	sub_2
		jnc	loc_21			; Jump if carry=0
		jmp	loc_30
loc_21:
		cmp	byte ptr ds:data_42e,2
		jae	loc_22			; Jump if above or =
		inc	byte ptr ds:data_42e
		mov	byte ptr ds:data_53e,2Ah	; '*'
		mov	byte ptr ds:data_39e,2
		jmp	loc_30
loc_22:
		mov	ax,ds:data_24e
		add	ax,4
		call	word ptr cs:data_13e
		mov	ds:data_22e,bl
		mov	al,ds:data_25e
		add	al,4
		and	al,3Fh			; '?'
		mov	ds:data_23e,al
		mov	bx,0A766h
		call	word ptr cs:data_15e
		mov	byte ptr ds:data_44e,0
		jmp	loc_30
loc_23:
		test	byte ptr ds:data_50e,0FFh
		jz	loc_24			; Jump if zero
		jmp	loc_55
loc_24:
		inc	byte ptr ds:data_34e
		and	byte ptr ds:data_34e,3
		test	byte ptr ds:data_35e,0FFh
		jz	loc_25			; Jump if zero
		cmp	byte ptr ds:data_24e,14h
		jb	loc_25			; Jump if below
		mov	byte ptr ds:data_41e,0FFh
		mov	byte ptr ds:data_42e,0
loc_25:
		test	byte ptr ds:data_41e,0FFh
		jnz	loc_26			; Jump if not zero
		call	word ptr cs:data_6
		and	al,0Fh
		jnz	loc_26			; Jump if not zero
		mov	byte ptr ds:data_44e,0FFh
		mov	byte ptr ds:data_42e,0
loc_26:
		inc	byte ptr ds:data_40e
		test	byte ptr ds:data_40e,1
		jnz	loc_30			; Jump if not zero
		mov	al,data_3
		add	al,data_4
		xor	ah,ah			; Zero register
		mov	cx,ax
		sub	cx,ds:data_47e
		jc	loc_27			; Jump if carry Set
		xchg	cx,ax
loc_27:
		mov	bl,ds:data_24e
		sub	bl,al
		cmp	bl,0Ch
		je	loc_29			; Jump if equal
		jnc	loc_28			; Jump if carry=0
		dec	byte ptr ds:data_28e
		and	byte ptr ds:data_28e,3
		call	sub_5
		jnc	loc_30			; Jump if carry=0
		mov	byte ptr ds:data_41e,0FFh
		mov	byte ptr ds:data_42e,0
		jmp	short loc_30
loc_28:
		inc	byte ptr ds:data_28e
		and	byte ptr ds:data_28e,3
		call	sub_3
loc_29:
		call	word ptr cs:data_6
		and	al,1Fh
		jnz	loc_30			; Jump if not zero
		mov	byte ptr ds:data_41e,0FFh
		mov	byte ptr ds:data_42e,0
loc_30:
		mov	al,ds:data_25e
		mov	ds:data_37e,al
		push	cs
		pop	es
		mov	di,data_46e
		mov	al,0FFh
		mov	cx,48h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		test	byte ptr ds:data_43e,0FFh
		jnz	loc_31			; Jump if not zero
		test	byte ptr ds:data_32e,0FFh
		jz	loc_32			; Jump if zero
loc_31:
		mov	al,ds:data_31e
		and	al,1
		add	al,11h
		call	sub_1
		jmp	short loc_34
loc_32:
		test	byte ptr ds:data_30e,0FFh
		jz	loc_33			; Jump if zero
		mov	al,ds:data_31e
		and	al,3
		add	al,0Dh
		call	sub_1
		mov	al,ds:data_31e
		shr	al,1			; Shift w/zeros fill
		adc	byte ptr ds:data_37e,0
		jmp	short loc_34
loc_33:
		mov	al,ds:data_29e
		call	sub_1
		mov	al,ds:data_28e
		add	al,6
		call	sub_1
		mov	al,ds:data_33e
		add	al,0Ah
		call	sub_1
		mov	al,ds:data_34e
		add	al,2
		call	sub_1
loc_34:
		mov	byte ptr ds:data_27e,0
		mov	ax,ds:data_24e
		mov	di,ds:data_48e
		mov	si,data_46e
		mov	cx,9

locloop_35:
		push	cx
		push	si
		push	ax
		call	word ptr cs:data_13e
		pop	ax
		jc	loc_39			; Jump if carry Set
		mov	ds:data_36e,bl
		xor	cx,cx			; Zero register
loc_36:
		push	cx
		push	ax
		cmp	byte ptr [si],0FFh
		je	loc_38			; Jump if equal
		mov	[di],ax
		mov	al,ds:data_37e
		add	al,cl
		and	al,3Fh			; '?'
		mov	[di+2],al
		mov	al,ds:data_36e
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
		test	byte ptr ds:data_35e,0FFh
		jz	loc_37			; Jump if zero
		or	byte ptr [di+5],20h	; ' '
loc_37:
		mov	ax,[di+2]
		push	di
		call	word ptr cs:data_12e
		mov	bl,ds:data_27e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_49e[bx],al
		pop	di
		add	di,10h
		inc	byte ptr ds:data_27e
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

_311MAPMT	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		add	al,al
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	si,ds:data_17e[bx]
		mov	bp,ds:data_21e[bx]
		mov	di,data_46e
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


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		inc	byte ptr ds:data_33e
		cmp	byte ptr ds:data_33e,3
		stc				; Set carry flag
		jz	loc_43			; Jump if zero
		retn
loc_43:
		mov	byte ptr ds:data_33e,0
		clc				; Clear carry flag
		retn
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		cmp	byte ptr ds:data_24e,0Dh
		jae	loc_44			; Jump if above or =
		retn
loc_44:
		dec	byte ptr ds:data_24e
		clc				; Clear carry flag
		retn
sub_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		cmp	byte ptr ds:data_24e,11h
		jae	loc_45			; Jump if above or =
		retn
loc_45:
		dec	byte ptr ds:data_24e
		clc				; Clear carry flag
		retn
sub_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		cmp	byte ptr ds:data_24e,30h	; '0'
		cmc				; Complement carry
		jnc	loc_46			; Jump if carry=0
		retn
loc_46:
		inc	byte ptr ds:data_24e
		clc				; Clear carry flag
		retn
sub_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		mov	ax,ds:data_26e
		sub	ax,bx
		jnc	loc_47			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_47:
		mov	ds:data_26e,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:data_11e
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_48			; Jump if zero
		retn
loc_48:
		mov	byte ptr ds:data_50e,0FFh
		call	word ptr cs:data_16e
		mov	byte ptr ds:data_41e,0
		mov	byte ptr ds:data_44e,0
		mov	byte ptr ds:data_42e,0
		test	byte ptr ds:data_30e,0FFh
		jnz	loc_49			; Jump if not zero
		retn
loc_49:
		mov	byte ptr ds:data_38e,0
		mov	byte ptr ds:data_30e,0
loc_54:
		mov	byte ptr ds:data_31e,0
		mov	byte ptr ds:data_32e,0FFh
		retn
sub_6		endp

loc_55:
		mov	al,ds:data_38e
		cmp	al,28h			; '('
		jae	loc_57			; Jump if above or =
		mov	byte ptr ds:data_51e,0FFh
		mov	byte ptr ds:data_29e,1
		mov	al,ds:data_38e
		inc	byte ptr ds:data_38e
		cmp	al,14h
		jae	loc_56			; Jump if above or =
		call	sub_2
		inc	byte ptr ds:data_34e
		and	byte ptr ds:data_34e,3
		mov	byte ptr ds:data_53e,2Ch	; ','
		jmp	loc_30
loc_56:
		mov	byte ptr ds:data_43e,0FFh
		mov	byte ptr ds:data_31e,1
		jmp	loc_30
loc_57:
		mov	byte ptr ds:data_52e,0FFh
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
		and	byte ptr ss:data_18e[bp],84h
		cmpsb				; Cmp [si] to es:[di]
		xchg	ss:data_19e[bp],ah
		mov	sp,ss:data_20e[bp]
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
