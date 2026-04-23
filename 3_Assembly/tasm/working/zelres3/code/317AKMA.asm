
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_317MAPA4                                €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_14e	equ	200Ch			;*
data_15e	equ	6028h			;*
data_16e	equ	6036h			;*
data_17e	equ	6038h			;*
data_18e	equ	0A7EEh			;*
data_19e	equ	0A870h			;*
data_20e	equ	0A918h			;*
data_21e	equ	0A940h			;*
data_22e	equ	0A969h			;*
data_23e	equ	0AA06h			;*
data_24e	equ	0AA08h			;*
data_25e	equ	0AA09h			;*
data_26e	equ	0AA1Eh			;*
data_27e	equ	0AA1Fh			;*
data_28e	equ	0AA20h			;*
data_29e	equ	0AA21h			;*
data_30e	equ	0AA22h			;*
data_31e	equ	0AA23h			;*
data_32e	equ	0AA24h			;*
data_33e	equ	0AA25h			;*
data_34e	equ	0AA26h			;*
data_35e	equ	0AA27h			;*
data_36e	equ	0AA28h			;*
data_37e	equ	0AA29h			;*
data_38e	equ	0AA2Ah			;*
data_39e	equ	0AA33h			;*
data_40e	equ	0AA87h			;*
data_41e	equ	0C002h			;*
data_42e	equ	0C010h			;*
data_43e	equ	0ED20h			;*
data_44e	equ	0FF2Eh			;*
data_45e	equ	0FF2Fh			;*
data_46e	equ	0FF30h			;*
data_47e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_317MAPA4	proc	far

start:
		cli				; Disable interrupts
		or	al,[bx+si]
		add	[bp+di],ch
		mov	ds:data_23e,ax
		db	12 dup (0)
		db	'((((((P((((((((((((((((((((((((('
		db	'~'
		db	0A0h,0E2h,0A0h, 78h,0A1h, 0Eh
		db	0A2h, 54h,0A2h, 9Fh,0A2h,0B3h
		db	0A2h
		db	50 dup (0)
		db	0B0h,0A0h, 2Dh,0A1h,0C3h,0A1h
		db	 31h,0A2h, 77h,0A2h,0A9h,0A2h
data_5		dw	0A2EFh
		db	0
data_6		db	0
		db	 02h, 03h, 04h, 00h, 05h, 06h
		db	 07h, 08h, 00h, 09h, 0Ah, 0Dh
		db	 0Eh, 00h, 0Bh, 0Ch, 0Fh, 10h
		db	 00h, 0Fh, 10h, 11h,0BDh, 00h
		db	0F3h, 00h,0BBh,0F4h, 00h
data_7		db	0BBh
		db	0F4h,0BEh,0BFh, 00h,0F4h,0BCh
		db	0BFh,0C0h, 00h,0BBh, 5Ah,0BEh
		db	0BFh, 00h, 5Ah, 5Bh,0BFh,0C0h
		db	 00h, 12h, 00h, 15h, 16h, 00h
		db	 13h, 14h, 17h, 18h, 00h, 1Ch
		db	 1Dh, 20h, 21h, 00h, 1Ah, 1Bh
		db	 1Eh, 1Fh, 00h, 1Eh, 1Fh,0C6h
		db	 22h, 00h, 00h,0F5h,0F6h,0C2h
		db	 00h,0F6h,0C2h,0C4h,0C5h, 00h
		db	0C1h,0F6h,0C3h,0C4h, 00h,0A6h
		db	0A7h,0C3h,0C4h, 00h,0A7h,0C2h
		db	0C4h,0C5h, 00h, 00h, 35h, 3Ch
		db	 3Dh, 00h, 3Dh, 3Eh, 41h, 42h
		db	 00h, 31h, 32h, 35h, 36h, 00h
		db	 00h, 2Ah, 2Eh, 23h, 00h, 24h
		db	 25h, 2Ah, 00h, 00h, 00h
		db	',/-', 0
		db	'3#78', 0
		db	'##C#', 0
		db	'DEFG', 0
		db	'&', 27h, '-#', 0
		db	'####', 0
		db	'9:#@', 0
		db	'#@@'
		db	 00h, 00h, 00h, 29h, 27h, 28h
		db	 00h, 23h, 00h, 3Ah, 3Bh, 00h
		db	 71h, 00h, 00h, 73h, 00h, 73h
		db	 74h, 77h, 78h, 00h, 77h, 70h
		db	 77h, 70h, 00h, 82h, 83h, 88h
		db	 70h, 00h, 88h, 70h, 00h, 88h
		db	 00h, 00h, 77h, 81h, 82h, 00h
		db	 79h, 7Ah, 78h, 79h, 00h, 70h
		db	 78h, 84h, 85h, 00h, 70h, 70h
		db	 70h, 8Ch, 00h, 8Fh, 90h, 91h
		db	 92h, 00h, 75h, 76h, 7Ah, 7Bh
		db	 00h, 7Bh, 00h, 7Ch, 7Dh, 00h
		db	 7Fh, 80h, 86h, 87h, 00h, 89h
		db	 8Ah, 8Dh, 8Eh, 00h, 87h, 00h
		db	 8Ah, 8Bh, 00h, 00h, 00h, 48h
		db	 49h, 00h, 00h, 00h, 00h, 4Bh
		db	 00h
		db	'NOST', 0
		db	'LMPQ', 0
		db	'U#WX', 0
		db	'R', 0
		db	'#V', 0
		db	'#Y[Y', 0
		db	'K^gh', 0
		db	'_`i#', 0
		db	'DnF'
		db	 47h, 00h, 00h, 00h, 4Bh, 4Ch
		db	 00h, 61h, 62h, 23h, 6Bh, 00h
		db	 00h, 00h, 4Ch, 4Dh, 00h, 63h
		db	 64h, 6Ch, 6Dh, 00h, 00h, 00h
		db	 65h, 66h, 00h, 00h, 98h, 00h
		db	 9Dh, 00h,0A2h, 70h,0A2h,0A6h
		db	 00h, 4Bh, 4Ch, 99h, 9Ah, 00h
		db	 9Eh, 9Fh,0A3h,0A4h, 00h, 00h
		db	 00h, 4Dh, 00h, 00h, 9Bh, 9Ch
		db	0A0h,0A1h, 00h, 00h, 00h, 4Bh
		db	 97h, 00h,0B1h,0B2h,0B8h,0B9h
		db	 00h,0AFh,0B0h, 70h,0B7h, 00h
		db	 8Fh, 90h, 91h, 92h, 00h, 00h
		db	 00h, 4Ch, 4Dh, 00h,0ADh,0AEh
		db	0B5h, 70h, 00h, 00h, 00h, 4Bh
		db	 4Ch, 00h,0ABh,0ACh,0B3h,0B4h
		db	 00h, 00h, 00h,0A9h,0AAh, 00h
		db	0CBh,0CCh,0CDh,0CEh, 00h, 00h
		db	0C9h,0CFh,0D0h, 00h,0C7h,0C8h
		db	0C9h,0CAh, 00h,0D2h, 00h,0D4h
		db	0D5h, 00h,0D4h,0D5h,0D6h,0D7h
		db	 00h,0D5h,0C9h,0D7h,0D0h, 00h
		db	0C7h,0C8h,0C9h,0CAh, 00h,0D8h
		db	0D9h,0DAh,0DBh, 00h,0DBh, 00h
		db	0DDh,0DEh, 00h,0E1h,0E2h,0DFh
		db	0E0h, 00h,0D8h,0D9h,0DAh,0DBh
		db	 00h,0E3h,0E4h,0E5h,0E6h, 00h
		db	0DBh,0E5h,0DDh,0E7h, 00h,0E5h
		db	0E6h
loc_2:
		out	0E8h,ax			; port 0E8h ??I/O Non-standard
		add	[bx+di],al
		jmpn	loc_3
loc_3:
;*		add	cl,ch
		db	 00h,0E9h		;  Fixup - byte match
;*		jmp	far ptr loc_1		;*
		db	0EAh
		dw	0, 100h			;  Fixup - byte match
		jmp	short $+2		; delay for I/O
		add	[bx+si],al
		jmp	short loc_2
		db	 00h,0EDh, 00h, 01h,0EBh,0F8h
		db	0F7h, 00h, 01h,0EBh, 00h,0FAh
		db	 00h, 01h,0EBh, 00h,0FCh, 00h
		db	0EEh,0EFh, 00h, 00h, 00h,0EFh
		db	 19h, 00h, 00h, 00h,0F0h,0F1h
		db	0F2h, 00h, 00h,0F1h, 19h, 00h
		db	 00h, 00h,0F0h,0F1h,0F2h, 4Ah
		db	 00h,0F0h,0F1h,0F2h, 34h, 00h
		db	0F0h,0F1h,0F2h,0FFh, 00h,0F1h
		db	 19h, 4Ah, 5Ch, 00h, 00h, 6Fh
		db	 6Ah, 93h, 00h, 72h, 7Eh, 94h
		db	 95h, 00h, 96h,0A5h,0B6h,0BAh
		db	 00h,0A8h, 00h,0D1h,0D3h, 00h
		db	 01h,0EBh,0F9h,0F7h, 00h, 01h
		db	0EBh,0F8h,0F7h, 00h, 00h, 00h
		db	0F9h,0F7h, 00h, 00h, 00h,0F8h
		db	0F7h, 00h, 01h,0EBh, 00h,0FBh
		db	 00h, 01h,0EBh, 00h,0FAh, 00h
		db	 00h,0FAh,0FBh, 00h, 00h, 00h
		db	0FAh,0FAh, 00h, 00h, 01h,0EBh
		db	 00h,0FEh, 00h, 01h,0EBh, 00h
		db	0FCh, 00h, 00h,0FDh,0FEh, 00h
		db	 00h, 00h,0FDh,0FCh, 00h, 00h
		db	0F1h, 19h, 4Ah, 5Dh, 00h,0F1h
		db	 19h, 4Ah, 5Ch, 00h, 00h, 00h
		db	 4Ah, 5Dh, 00h, 00h, 00h, 4Ah
		db	 5Ch, 00h,0F1h, 19h, 3Fh, 00h
		db	 00h,0F1h, 19h, 34h, 00h, 00h
		db	 34h, 00h, 00h, 3Fh, 00h, 34h
		db	 00h, 00h, 34h, 00h,0F1h, 19h
		db	 30h, 00h, 00h,0F1h, 19h,0FFh
		db	 00h, 00h, 2Bh, 00h, 00h, 30h
		db	 00h, 2Bh, 00h, 00h,0FFh, 8Bh
		db	 36h, 10h,0C0h,0C6h, 06h, 1Eh
		db	0AAh, 00h,0C6h, 06h, 1Fh,0AAh
		db	 00h
loc_4:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jz	loc_7			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:data_16e
		jc	loc_6			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:data_15e
		mov	bl,ds:data_26e
		xor	bh,bh			; Zero register
		mov	al,ds:data_43e[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	loc_6			; Jump if zero
		test	byte ptr ds:data_27e,80h
		jnz	loc_6			; Jump if not zero
		mov	al,[si+5]
		and	al,1Fh
		cmp	byte ptr [si+4],5
		jne	loc_5			; Jump if not equal
		or	al,80h
loc_5:
		mov	ds:data_27e,al
loc_6:
		inc	byte ptr ds:data_26e
		add	si,10h
		jmp	short loc_4
loc_7:
		mov	si,ds:data_42e
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:data_27e,0FFh
		jz	loc_8			; Jump if zero
		mov	al,ds:data_27e
		push	ax
		and	al,1Fh
		call	word ptr cs:data_17e
		mov	bl,ah
		pop	ax
		xor	bh,bh			; Zero register
		mov	byte ptr ds:data_47e,22h	; '"'
		call	sub_5
loc_8:
		test	byte ptr ds:data_44e,0FFh
		jz	loc_9			; Jump if zero
		jmp	loc_64
loc_9:
		mov	byte ptr ds:data_32e,0
		mov	al,ds:data_28e
		inc	al
		cmp	al,3
		jb	loc_10			; Jump if below
		xor	al,al			; Zero register
loc_10:
		mov	ds:data_28e,al
		cmp	al,1
		jne	loc_11			; Jump if not equal
		mov	byte ptr ds:data_47e,2Bh	; '+'
loc_11:
		inc	byte ptr ds:data_31e
		test	byte ptr ds:data_29e,0FFh
		jnz	loc_15			; Jump if not zero
		call	sub_1
		jc	loc_12			; Jump if carry Set
		jmp	loc_17
loc_12:
		mov	al,ds:data_24e
		sub	al,2
		and	al,3Fh			; '?'
		mov	ds:data_24e,al
		cmp	al,3Dh			; '='
		je	loc_13			; Jump if equal
		jmp	loc_19
loc_13:
		mov	byte ptr ds:data_29e,0FFh
		mov	byte ptr ds:data_35e,0
		mov	byte ptr ds:data_34e,0
		mov	byte ptr ds:data_33e,0FFh
		mov	byte ptr ds:data_47e,34h	; '4'
		mov	ax,data_5
		mov	bl,data_6
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	bx,ax
		sub	bx,ds:data_41e
		jnc	loc_14			; Jump if carry=0
		xchg	bx,ax
loc_14:
		sub	bx,28h
		sbb	al,al
		and	al,1
		mov	ds:data_36e,al
		jmp	short loc_17
loc_15:
		call	sub_2
		jnc	loc_17			; Jump if carry=0
		mov	al,ds:data_24e
		sub	al,2
		and	al,3Fh			; '?'
		mov	ds:data_24e,al
		cmp	al,3Dh			; '='
		jne	loc_19			; Jump if not equal
		mov	byte ptr ds:data_29e,0
		mov	byte ptr ds:data_35e,0
		mov	byte ptr ds:data_34e,0
		mov	byte ptr ds:data_33e,0FFh
		mov	byte ptr ds:data_47e,34h	; '4'
		mov	ax,data_5
		mov	bl,data_6
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	bx,ax
		sub	bx,ds:data_41e
		jnc	loc_16			; Jump if carry=0
		xchg	bx,ax
loc_16:
		sub	bx,14h
		sbb	al,al
		not	al
		and	al,1
		mov	ds:data_36e,al
loc_17:
		mov	bx,0A954h
		test	byte ptr ds:data_29e,0FFh
		jnz	loc_18			; Jump if not zero
		mov	bx,data_22e
loc_18:
		mov	al,ds:data_23e
		sub	al,0Ah
		shr	al,1			; Shift w/zeros fill
		xlat				; al=[al+[bx]] table
		mov	ds:data_24e,al
loc_19:
		test	byte ptr ds:data_33e,0FFh
		jz	loc_23			; Jump if zero
		mov	al,ds:data_36e
		add	al,2
		mov	ds:data_32e,al
		test	byte ptr ds:data_35e,0FFh
		jnz	loc_20			; Jump if not zero
		inc	byte ptr ds:data_34e
		mov	al,ds:data_36e
		not	al
		and	al,1
		add	al,7
		cmp	ds:data_34e,al
		jb	loc_23			; Jump if below
		mov	byte ptr ds:data_35e,0FFh
		jmp	short loc_23
loc_20:
		dec	byte ptr ds:data_34e
		test	byte ptr ds:data_34e,0FFh
		jnz	loc_23			; Jump if not zero
		mov	byte ptr ds:data_33e,0
		jmp	short loc_23

_317MAPA4	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		mov	ax,ds:data_23e
		dec	ax
		dec	ax
		mov	bx,9
		sub	bx,ax
		cmc				; Complement carry
		jnc	loc_21			; Jump if carry=0
		retn
loc_21:
		mov	ds:data_23e,ax
		retn
sub_1		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		mov	ax,ds:data_23e
		inc	ax
		inc	ax
		mov	bx,33h
		sub	bx,ax
		jnc	loc_22			; Jump if carry=0
		retn
loc_22:
		mov	ds:data_23e,ax
		retn
sub_2		endp

loc_23:
		push	cs
		pop	es
		mov	di,data_38e
		mov	ax,0FFFFh
		mov	cx,120h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,0A7F4h
		mov	di,0A876h
		test	byte ptr ds:data_29e,0FFh
		jnz	loc_24			; Jump if not zero
		mov	si,data_18e
		mov	di,data_19e
loc_24:
		mov	bl,ds:data_28e
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,[bx+si]
		mov	bp,[bx+di]
		call	sub_4
		mov	di,0AA67h
		mov	si,0A92Ch
		test	byte ptr ds:data_29e,0FFh
		jnz	loc_25			; Jump if not zero
		mov	di,data_40e
		mov	si,data_20e
loc_25:
		mov	al,ds:data_31e
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,0Ah
		xor	ah,ah			; Zero register
		add	si,ax
		mov	cx,5

locloop_26:
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,0Eh
		loop	locloop_26		; Loop if cx > 0

		mov	di,0AAD3h
		mov	si,0A94Ah
		test	byte ptr ds:data_29e,0FFh
		jnz	loc_27			; Jump if not zero
		mov	di,data_39e
		mov	si,data_21e
loc_27:
		mov	bl,ds:data_32e
		add	bl,bl
		xor	bh,bh			; Zero register
		add	si,bx
		lodsb				; String [si] to al
		mov	[di],al
		add	di,10h
		lodsb				; String [si] to al
		mov	[di],al
		mov	byte ptr ds:data_26e,0
		mov	ax,ds:data_23e
		mov	si,ds:data_42e
		mov	di,0AA2Ah
		mov	cx,0Dh
loc_28:
		push	cx
		push	di
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		mov	ds:data_30e,bl
		jc	loc_32			; Jump if carry Set
		xor	cl,cl			; Zero register
loc_29:
		push	cx
		push	ax
		cmp	byte ptr [di],0FFh
		je	loc_31			; Jump if equal
		mov	[si],ax
		mov	al,ds:data_24e
		add	al,cl
		and	al,3Fh			; '?'
		mov	[si+2],al
		mov	al,ds:data_30e
		mov	[si+3],al
		mov	al,[di]
		mov	ah,al
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		and	al,0Fh
		mov	[si+4],al
		mov	[si+6],ah
		mov	al,ds:data_29e
		and	al,80h
		mov	[si+5],al
		test	byte ptr ds:data_27e,0FFh
		jz	loc_30			; Jump if zero
		or	byte ptr [si+5],20h	; ' '
loc_30:
		push	di
		mov	ax,[si+2]
		call	word ptr cs:data_15e
		mov	al,ds:data_26e
		mov	bl,al
		or	al,80h
		xchg	[di],al
		xor	bh,bh			; Zero register
		mov	ds:data_43e[bx],al
		inc	byte ptr ds:data_26e
		add	si,10h
		pop	di
loc_31:
		inc	di
		pop	ax
		pop	cx
		inc	cl
		cmp	cl,10h
		jne	loc_29			; Jump if not equal
loc_32:
		inc	ax
		pop	di
		add	di,10h
		pop	cx
		loop	locloop_33		; Loop if cx > 0

		jmp	short loc_34

locloop_33:
		jmp	loc_28
loc_34:
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:data_33e,0FFh
		jnz	loc_35			; Jump if not zero
		retn
loc_35:
		test	byte ptr ds:data_34e,0FFh
		jnz	loc_36			; Jump if not zero
		retn
loc_36:
		test	byte ptr ds:data_36e,0FFh
		jz	loc_37			; Jump if zero
		jmp	loc_47
loc_37:
		test	byte ptr ds:data_29e,0FFh
		jnz	loc_42			; Jump if not zero
		mov	ax,ds:data_23e
		mov	dl,ds:data_24e
		add	dl,9
		mov	cl,ds:data_34e
		dec	cl
		jz	loc_40			; Jump if zero
		xor	ch,ch			; Zero register

locloop_38:
		push	cx
		dec	ax
		dec	ax
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		pop	dx
		mov	ds:data_30e,bl
		jc	loc_39			; Jump if carry Set
		mov	bx,2603h
		call	sub_3
loc_39:
		pop	cx
		loop	locloop_38		; Loop if cx > 0

loc_40:
		dec	ax
		dec	ax
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		pop	dx
		mov	ds:data_30e,bl
		jc	loc_41			; Jump if carry Set
		mov	bx,2602h
		call	sub_3
loc_41:
		mov	word ptr [si],0FFFFh
		retn
loc_42:
		mov	ax,ds:data_23e
		add	ax,0Bh
		mov	dl,ds:data_24e
		add	dl,9
		mov	cl,ds:data_34e
		dec	cl
		jz	loc_45			; Jump if zero
		xor	ch,ch			; Zero register

locloop_43:
		push	cx
		inc	ax
		inc	ax
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		pop	dx
		mov	ds:data_30e,bl
		jc	loc_44			; Jump if carry Set
		mov	bx,2603h
		call	sub_3
loc_44:
		pop	cx
		loop	locloop_43		; Loop if cx > 0

loc_45:
		inc	ax
		inc	ax
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		pop	dx
		mov	ds:data_30e,bl
		jc	loc_46			; Jump if carry Set
		mov	bx,2602h
		call	sub_3
loc_46:
		mov	word ptr [si],0FFFFh
		retn
loc_47:
		test	byte ptr ds:data_29e,0FFh
		jnz	loc_52			; Jump if not zero
		mov	ax,ds:data_23e
		inc	ax
		mov	dl,ds:data_24e
		add	dl,9
		mov	cl,ds:data_34e
		dec	cl
		jz	loc_50			; Jump if zero
		xor	ch,ch			; Zero register

locloop_48:
		push	cx
		dec	ax
		dec	ax
		inc	dl
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		pop	dx
		mov	ds:data_30e,bl
		jc	loc_49			; Jump if carry Set
		mov	bx,2607h
		call	sub_3
loc_49:
		pop	cx
		loop	locloop_48		; Loop if cx > 0

loc_50:
		dec	ax
		dec	ax
		inc	dl
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		pop	dx
		mov	ds:data_30e,bl
		jc	loc_51			; Jump if carry Set
		mov	bx,2606h
		call	sub_3
loc_51:
		mov	word ptr [si],0FFFFh
		retn
loc_52:
		mov	ax,ds:data_23e
		add	ax,0Ah
		mov	dl,ds:data_24e
		add	dl,9
		mov	cl,ds:data_34e
		dec	cl
		jz	loc_55			; Jump if zero
		xor	ch,ch			; Zero register

locloop_53:
		push	cx
		inc	ax
		inc	ax
		inc	dl
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		pop	dx
		mov	ds:data_30e,bl
		jc	loc_54			; Jump if carry Set
		mov	bx,2607h
		call	sub_3
loc_54:
		pop	cx
		loop	locloop_53		; Loop if cx > 0

loc_55:
		inc	ax
		inc	ax
		inc	dl
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		pop	dx
		mov	ds:data_30e,bl
		jc	loc_56			; Jump if carry Set
		mov	bx,2606h
		call	sub_3
loc_56:
		mov	word ptr [si],0FFFFh
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		push	ax
		push	dx
		mov	[si],ax
		and	dl,3Fh			; '?'
		mov	[si+2],dl
		mov	dh,ds:data_30e
		mov	[si+3],dh
		mov	[si+4],bh
		mov	[si+6],bl
		mov	dh,ds:data_29e
		and	dh,80h
		mov	[si+5],dh
		mov	ax,[si+2]
		call	word ptr cs:data_15e
		mov	al,ds:data_26e
		mov	bl,al
		or	al,80h
		xchg	[di],al
		xor	bh,bh			; Zero register
		mov	ds:data_43e[bx],al
		inc	byte ptr ds:data_26e
		add	si,10h
		pop	dx
		pop	ax
		retn
sub_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		mov	di,data_38e
		mov	cx,0Dh

locloop_57:
		push	cx
		mov	cx,2

locloop_58:
		push	cx
		mov	cx,8

locloop_59:
		rol	byte ptr ds:[bp],1	; Rotate
		jnc	loc_60			; Jump if carry=0
		lodsb				; String [si] to al
		mov	[di],al
loc_60:
		inc	di
		loop	locloop_59		; Loop if cx > 0

		inc	bp
		pop	cx
		loop	locloop_58		; Loop if cx > 0

		pop	cx
		loop	locloop_57		; Loop if cx > 0

		retn
sub_4		endp

			                        ;* No entry point to code
		cli				; Disable interrupts
		cmpsw				; Cmp [si] to es:[di]
		sub	al,0A8h
		dec	sp
		test	al,13h
		test	al,3Ch			; '<'
		test	al,5Eh			; '^'
		test	al,0
		push	ax
		adc	[bp+di],dl
		adc	dl,[bx+di]
		add	[bp+si],ax
		push	cx
		adc	al,15h
		push	ss
		pop	ss
		sbb	[bp+di],al
		add	al,19h
		sbb	bl,[bp+di]
		sbb	al,5
		push	es
		sbb	ax,71Eh
		adc	[di],dl
		pop	es
		adc	[bp+si],dx
		adc	dx,[si]
		add	ax,1606h
		pop	ss
		sbb	[bx+di],bl
		add	ax,[si]
		sbb	bl,[bp+di]
		sbb	al,1Dh
		add	[bp+si],ax
		push	ax
		push	ds
;*		add	[bx+di+0],dl
		db	 00h, 51h, 00h		;  Fixup - byte match
		db	 50h, 20h, 01h, 02h, 51h, 21h
		db	 22h, 03h, 04h
		db	'#$'
		db	8, 9, '%& !', 8, '"#', 9, '$'
		db	'%'
		db	 03h, 04h, 26h, 01h, 02h, 50h
		db	 00h, 51h, 00h, 50h, 27h, 01h
		db	 02h, 51h, 28h, 29h, 03h, 04h
		db	 2Ah, 2Bh, 05h, 06h, 07h, 2Ch
		db	 2Dh, 2Eh, 2Eh, 2Ch, 2Dh, 07h
		db	 2Ah, 2Bh, 05h, 06h, 28h, 29h
		db	 03h, 04h, 27h, 01h, 02h, 50h
		db	 00h, 51h, 7Ch,0A8h,0B0h,0A8h
		db	0E4h,0A8h, 96h,0A8h,0CAh,0A8h
		db	0FEh,0A8h, 00h, 00h, 01h, 08h
		db	 04h, 00h, 2Ah,0A8h, 40h, 00h
		db	 2Ah,0B0h, 00h, 00h, 56h, 30h
		db	 88h, 10h
		db	14 dup (0)
		db	 88h, 10h, 56h, 30h, 00h, 00h
		db	 2Ah,0B0h, 40h, 00h, 2Ah,0A8h
		db	 04h, 00h, 01h, 08h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 01h, 08h
		db	 00h, 00h, 02h,0A8h, 00h, 00h
		db	 02h,0B0h, 00h, 00h, 01h, 50h
		db	 00h, 10h, 00h,0A0h, 00h, 00h
		db	9 dup (0)
		db	0A0h, 00h, 10h, 01h, 50h, 00h
		db	 00h, 02h,0B0h, 00h, 00h, 02h
		db	0A8h, 00h, 00h, 01h, 08h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 01h
		db	 08h, 00h, 00h, 02h,0A8h, 00h
		db	 00h, 02h,0B0h, 00h, 00h, 0Ah
		db	 30h, 00h, 10h, 0Ah, 00h, 00h
		db	 00h, 04h, 00h, 00h, 00h, 04h
		db	 00h, 00h, 00h, 0Ah, 00h, 00h
		db	 10h, 0Ah, 30h, 00h, 00h, 02h
		db	0B0h, 00h, 00h, 02h,0A8h, 00h
		db	 00h, 01h, 08h, 00h, 00h, 00h
		db	 00h,0FFh, 30h,0FFh,0FFh,0FFh
		db	 31h, 32h,0FFh,0FFh,0FFh,0FFh
		db	0FFh, 33h, 34h,0FFh, 35h, 36h
		db	0FFh,0FFh,0FFh, 30h,0FFh,0FFh
		db	 31h,0FFh,0FFh,0FFh, 32h,0FFh
		db	0FFh, 33h,0FFh,0FFh, 35h, 34h
		db	 36h,0FFh,0FFh,0FFh,0FFh
		db	'@ABCDCECFC@ABCDGECFC<<=>??'
		db	0, 0, 0, 1
		db	23 dup (1)
		db	0, 0, 0
		db	 3Fh, 3Fh, 3Eh, 3Dh, 3Ch, 3Ch

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		mov	ax,ds:data_25e
		sub	ax,bx
		jnc	loc_61			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_61:
		mov	ds:data_25e,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:data_14e
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_62			; Jump if zero
		retn
loc_62:
		test	byte ptr ds:data_44e,0FFh
		jz	loc_63			; Jump if zero
		retn
loc_63:
		mov	byte ptr ds:data_37e,0
		mov	byte ptr ds:data_33e,0
		mov	byte ptr ds:data_44e,0FFh
		retn
sub_5		endp

loc_64:
		mov	al,ds:data_37e
		cmp	al,28h			; '('
		jae	loc_68			; Jump if above or =
		mov	byte ptr ds:data_45e,0FFh
		inc	byte ptr ds:data_37e
		cmp	al,1Eh
		jae	loc_67			; Jump if above or =
		inc	byte ptr ds:data_28e
		cmp	byte ptr ds:data_28e,3
		jb	loc_65			; Jump if below
		mov	byte ptr ds:data_28e,0
loc_65:
		inc	byte ptr ds:data_31e
		inc	byte ptr ds:data_32e
		and	byte ptr ds:data_32e,1
		test	byte ptr ds:data_31e,3
		jz	loc_66			; Jump if zero
		jmp	loc_23
loc_66:
		mov	byte ptr ds:data_47e,37h	; '7'
		jmp	loc_23
loc_67:
		mov	byte ptr ds:data_28e,1
		mov	byte ptr ds:data_32e,1
		jmp	loc_23
loc_68:
		mov	byte ptr ds:data_46e,0FFh
		retn
			                        ;* No entry point to code
		sub	al,[bx+si]
		add	[bx+si],ah
		add	si,[bx+si]
		jnz	$+0Eh			; Jump if not zero
		add	[bp+di],dl
		stosb				; Store al to es:[di]
		db	0D8h, 0Eh, 10h,0BBh, 02h, 07h
		db	 41h, 6Ch, 67h, 75h, 69h, 65h
		db	 6Eh, 00h, 00h, 00h,0FFh
		db	216 dup (0)

seg_a		ends



		end	start
