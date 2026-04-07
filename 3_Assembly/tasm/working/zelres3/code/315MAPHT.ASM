
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_315MAPHT                                €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_14e	equ	0C0Bh			;*
data_15e	equ	200Ch			;*
data_16e	equ	6028h			;*
data_17e	equ	6036h			;*
data_18e	equ	6038h			;*
data_19e	equ	603Ah			;*
data_20e	equ	603Ch			;*
data_21e	equ	0A2F8h			;*
data_22e	equ	0A32Fh			;*
data_23e	equ	0A334h			;*
data_24e	equ	0A339h			;*
data_25e	equ	0A4DBh			;*
data_26e	equ	0A543h			;*
data_27e	equ	0A544h			;*
data_28e	equ	0A550h			;*
data_29e	equ	0A551h			;*
data_30e	equ	0A5DFh			;*
data_31e	equ	0A5E1h			;*
data_32e	equ	0A5E2h			;*
data_33e	equ	0A5F6h			;*
data_34e	equ	0A5F7h			;*
data_35e	equ	0A5F8h			;*
data_36e	equ	0A5F9h			;*
data_37e	equ	0A5FAh			;*
data_38e	equ	0A5FBh			;*
data_39e	equ	0A5FCh			;*
data_40e	equ	0A5FDh			;*
data_41e	equ	0A5FEh			;*
data_42e	equ	0A5FFh			;*
data_43e	equ	0A600h			;*
data_44e	equ	0A601h			;*
data_45e	equ	0A602h			;*
data_46e	equ	0A603h			;*
data_47e	equ	0A606h			;*
data_48e	equ	0A60Ch			;*
data_49e	equ	0A612h			;*
data_50e	equ	0A618h			;*
data_51e	equ	0C002h			;*
data_52e	equ	0C010h			;*
data_53e	equ	0ED20h			;*
data_54e	equ	0FF2Eh			;*
data_55e	equ	0FF2Fh			;*
data_56e	equ	0FF30h			;*
data_57e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_315MAPHT	proc	far

start:
		sbb	ax,word ptr ds:[0]
		mov	dh,0A1h
		db	0DFh,0A5h
		db	12 dup (0)
		db	32 dup (1Eh)
		db	 3Ah,0A0h, 8Ah,0A0h,0D0h,0A0h
		db	 16h,0A1h, 66h,0A1h, 00h, 01h
		db	 02h, 03h, 04h, 00h, 11h, 07h
		db	 12h, 13h, 00h, 1Eh, 16h, 1Fh
		db	 20h, 00h, 05h, 06h, 07h, 08h
		db	 00h, 14h, 15h, 16h, 17h, 00h
		db	 21h, 22h, 23h, 24h, 00h, 09h
		db	 0Ah, 0Bh, 0Ch, 00h, 18h, 19h
		db	 1Ah, 1Bh, 00h, 25h, 26h, 27h
		db	 1Dh, 00h, 0Dh, 0Eh, 0Fh, 10h
		db	 00h, 1Ch, 10h, 1Dh, 10h, 00h
		db	 28h, 10h, 29h, 2Ah, 00h, 18h
		db	 2Bh, 1Ah, 2Ch, 00h
data_4		dw	102Dh
		db	 2Eh, 10h, 00h, 11h, 07h, 12h
		db	 2Fh, 00h
		db	30h
data_5		dw	3115h			; Data table (indexed access)
		db	 17h, 00h, 32h, 33h, 34h, 35h
		db	 00h, 41h, 42h, 43h, 44h, 00h
		db	 1Eh, 50h, 1Fh
		db	'Q', 0
		db	'6789', 0
		db	'EFGH', 0
		db	'RST$'
		db	0
		db	':;<=', 0
		db	'IJKL', 0
		db	'UOVW', 0
		db	'>', 0
		db	'?@', 0
		db	'MNO'
		db	 10h, 00h, 58h, 10h, 59h, 2Ah
		db	 00h, 49h, 5Ah, 4Bh, 5Bh, 00h
		db	 5Ch, 4Eh, 5Dh, 5Eh, 00h, 00h
		db	 32h, 5Fh, 60h, 00h, 6Bh, 6Ch
		db	 6Dh, 6Eh, 00h, 79h, 7Ah, 7Bh
		db	 7Ch, 00h, 61h, 62h, 63h, 64h
		db	 00h, 6Fh, 70h, 71h, 72h, 00h
		db	 7Dh, 7Eh, 7Fh, 24h, 00h, 65h
		db	 66h, 67h, 68h, 00h, 73h, 1Dh
		db	 74h, 75h, 00h, 80h, 4Fh, 81h
		db	 59h, 00h, 69h, 00h, 6Ah, 00h
		db	 00h, 76h, 77h, 4Fh, 78h, 00h
		db	 82h, 10h, 59h, 2Ah, 00h, 73h
		db	 83h, 74h, 84h, 00h
		db	 76h, 77h, 4Fh, 78h
data_7		dw	0
		db	 85h, 86h, 87h, 00h, 93h, 94h
		db	 95h, 96h, 00h, 1Eh,0A1h,0A2h
		db	0A3h, 00h, 88h, 89h, 8Ah, 8Bh
		db	 00h, 97h, 98h, 99h, 9Ah, 00h
		db	0A4h,0A5h,0A6h,0A7h, 00h, 8Ch
		db	 8Dh, 8Eh, 67h, 00h, 9Bh, 9Ch
		db	 9Dh, 9Eh, 00h, 25h, 26h, 27h
		db	 1Dh, 00h, 8Fh, 90h, 91h, 92h
		db	 00h, 1Dh, 9Fh,0A0h, 10h, 00h
		db	 28h, 10h
		db	 29h, 2Ah
		db	11 dup (0)
		db	 93h,0A8h, 95h,0A9h, 00h,0AAh
		db	0ABh,0ACh,0ADh, 00h, 00h,0AEh
		db	 00h,0AFh, 00h,0BBh,0BCh,0BDh
		db	0BEh, 00h, 1Eh,0CAh,0A2h,0CBh
		db	 00h,0B0h,0B1h,0B2h,0B3h, 00h
		db	0BFh,0C0h,0C1h,0C2h, 00h,0CCh
		db	0CDh,0CEh,0CFh, 00h,0B4h,0B5h
		db	0B6h,0B7h, 00h,0C3h,0C4h,0C5h
		db	0C6h, 00h,0D0h,0D1h,0D2h,0D3h
		db	 00h,0B8h, 00h,0B9h,0BAh, 00h
		db	0C7h,0C8h, 4Fh,0C9h, 00h,0D4h
		db	 10h, 1Dh, 2Ah, 00h
		db	10 dup (0)
		db	0BBh,0BCh,0BDh,0BEh, 00h,0BFh
		db	0D5h,0C1h,0D6h, 8Bh, 36h, 10h
		db	0C0h,0C6h, 06h,0FDh,0A5h, 00h
		db	0C6h, 06h,0FFh,0A5h, 00h
loc_1:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jz	loc_3			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:data_17e
		jc	loc_2			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:data_16e
		mov	bl,ds:data_40e
		xor	bh,bh			; Zero register
		mov	al,ds:data_53e[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	loc_2			; Jump if zero
		test	byte ptr ds:data_42e,80h
		jnz	loc_2			; Jump if not zero
		mov	al,[si+5]
		and	al,1Fh
		mov	ds:data_42e,al
loc_2:
		inc	byte ptr ds:data_40e
		add	si,10h
		jmp	short loc_1
loc_3:
		mov	si,ds:data_52e
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:data_42e,0FFh
		jz	loc_6			; Jump if zero
		mov	al,ds:data_42e
		push	ax
		and	al,1Fh
		call	word ptr cs:data_18e
		mov	bl,ah
		pop	ax
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		mov	byte ptr ds:data_57e,24h	; '$'
		call	sub_5
		mov	ax,data_4
		add	ax,0Fh
		mov	bx,ax
		sub	ax,ds:data_51e
		jc	loc_4			; Jump if carry Set
		xchg	bx,ax
loc_4:
		mov	ax,ds:data_30e
		sub	ax,bx
		jnc	loc_5			; Jump if carry=0
		call	sub_4
		call	sub_4
		jmp	short loc_6
loc_5:
		call	sub_3
		call	sub_3
loc_6:
		test	byte ptr ds:data_34e,0FFh
		jz	loc_7			; Jump if zero
		jmp	loc_19
loc_7:
		test	byte ptr ds:data_35e,0FFh
		jnz	loc_11			; Jump if not zero
		call	word ptr cs:data_7
		and	al,0Fh
		jz	loc_8			; Jump if zero
		jmp	loc_19
loc_8:
		test	byte ptr ds:data_54e,0FFh
		jz	loc_9			; Jump if zero
		jmp	loc_19
loc_9:
		mov	byte ptr ds:data_35e,0FFh
		mov	byte ptr ds:data_37e,0FFh
		mov	byte ptr ds:data_36e,0FFh
		mov	byte ptr ds:data_38e,0
		mov	byte ptr ds:data_39e,0
		mov	ax,data_4
		add	ax,0Eh
		mov	bx,ax
		sub	ax,ds:data_51e
		jc	loc_10			; Jump if carry Set
		xchg	bx,ax
loc_10:
		mov	ax,ds:data_30e
		sub	ax,bx
		jnc	loc_11			; Jump if carry=0
		mov	byte ptr ds:data_36e,0
loc_11:
		add	byte ptr ds:data_33e,2
		and	byte ptr ds:data_33e,6
		test	byte ptr ds:data_37e,0FFh
		jz	loc_14			; Jump if zero
		inc	byte ptr ds:data_39e
		and	byte ptr ds:data_39e,3
		jz	loc_12			; Jump if zero
		jmp	loc_26
loc_12:
		mov	byte ptr ds:data_37e,0
		test	byte ptr ds:data_35e,80h
		jz	loc_13			; Jump if zero
		jmp	loc_26
loc_13:
		mov	byte ptr ds:data_35e,0
		jmp	loc_26
loc_14:
		mov	bl,ds:data_38e
		inc	byte ptr ds:data_38e
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:data_21e[bx]	;*
		jmp	loc_26
			                        ;* No entry point to code
		and	ax,2FA3h
		mov	ds:data_22e,ax
		das				; Decimal adjust
		mov	ds:data_24e,ax
		cmp	ss:data_23e[bp+di],sp
		xor	al,0A3h
		xor	al,0A3h
		or	al,0A3h
		mov	byte ptr ds:data_35e,7Fh
		mov	byte ptr ds:data_37e,7Fh
		mov	byte ptr ds:data_45e,0
		inc	byte ptr ds:data_31e
		and	byte ptr ds:data_31e,3Fh	; '?'
		retn

_315MAPHT	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		dec	byte ptr ds:data_31e
		and	byte ptr ds:data_31e,3Fh	; '?'
		retn
sub_1		endp

			                        ;* No entry point to code
		call	sub_1
		jmp	short loc_15
		db	0E8h,0E4h,0FFh,0EBh, 00h
loc_15:
		test	byte ptr ds:data_45e,0FFh
		jz	loc_16			; Jump if zero
		retn
loc_16:
		mov	ax,data_4
		add	ax,0Ch
		mov	bx,ax
		sub	ax,ds:data_51e
		jc	loc_17			; Jump if carry Set
		xchg	bx,ax
loc_17:
		mov	ax,ds:data_30e
		sub	ax,bx
		jnz	loc_18			; Jump if not zero
		retn
loc_18:
		pop	ax
		test	byte ptr ds:data_36e,0FFh
		jnz	loc_23			; Jump if not zero
		jmp	short loc_25
loc_19:
		test	byte ptr ds:data_54e,0FFh
		jz	loc_20			; Jump if zero
		jmp	loc_43
loc_20:
		dec	byte ptr ds:data_41e
		jnz	loc_21			; Jump if not zero
		mov	byte ptr ds:data_41e,2
		inc	byte ptr ds:data_33e
		and	byte ptr ds:data_33e,7
loc_21:
		mov	ax,data_4
		add	ax,12h
		mov	bx,ax
		sub	ax,ds:data_51e
		jnc	loc_22			; Jump if carry=0
		xchg	bx,ax
loc_22:
		sub	ax,ds:data_30e
		jnc	loc_24			; Jump if carry=0
		test	byte ptr ds:data_33e,0FFh
		jnz	loc_26			; Jump if not zero
loc_23:
		call	sub_4
		jnc	loc_26			; Jump if carry=0
		mov	byte ptr ds:data_45e,0FFh
		jmp	short loc_26
loc_24:
		cmp	byte ptr ds:data_33e,4
		jne	loc_26			; Jump if not equal
loc_25:
		call	sub_3
		jnc	loc_26			; Jump if carry=0
		mov	byte ptr ds:data_45e,0FFh
loc_26:
		mov	bl,ds:data_33e
		xor	bh,bh			; Zero register
		mov	dl,ds:data_25e[bx]
		xor	dh,dh			; Zero register
		mov	di,data_46e
		mov	cx,0Ch

locloop_27:
		mov	[di],dx
		add	di,2
		inc	dh
		loop	locloop_27		; Loop if cx > 0

		test	byte ptr ds:data_35e,0FFh
		jnz	loc_34			; Jump if not zero
		test	byte ptr ds:data_34e,0FFh
		jz	loc_28			; Jump if zero
		cmp	byte ptr ds:data_34e,1
		je	loc_33			; Jump if equal
		jmp	short loc_30
loc_28:
		call	word ptr cs:data_7
		and	al,1
		jnz	loc_34			; Jump if not zero
		mov	ax,data_4
		add	ax,12h
		mov	bx,ax
		sub	ax,ds:data_51e
		jc	loc_29			; Jump if carry Set
		xchg	bx,ax
loc_29:
		mov	ax,ds:data_30e
		sub	ax,bx
		jnc	loc_32			; Jump if carry=0
		dec	bx
		dec	bx
		mov	ax,ds:data_30e
		add	ax,7
		sub	ax,bx
		jnc	loc_34			; Jump if carry=0
		cmp	byte ptr ds:data_33e,6
		jne	loc_34			; Jump if not equal
		mov	byte ptr ds:data_34e,2
loc_30:
		mov	byte ptr ds:data_49e,0Ch
		mov	byte ptr ds:data_50e,0Dh
		test	byte ptr ds:data_33e,0FFh
		jnz	loc_31			; Jump if not zero
		call	sub_2
loc_31:
		jmp	short loc_34
loc_32:
		cmp	byte ptr ds:data_33e,2
		jne	loc_34			; Jump if not equal
		mov	byte ptr ds:data_34e,1
loc_33:
		mov	byte ptr ds:data_47e,0Eh
		mov	byte ptr ds:data_48e,0Fh
		cmp	byte ptr ds:data_33e,4
		jne	loc_34			; Jump if not equal
		call	sub_2
loc_34:
		mov	byte ptr ds:data_40e,0
		mov	di,0A603h
		mov	si,ds:data_52e
		mov	ax,ds:data_30e
		mov	cx,4

locloop_35:
		push	cx
		push	ax
		call	word ptr cs:data_17e
		pop	ax
		mov	ds:data_43e,bl
		jnc	loc_36			; Jump if carry=0
		add	di,6
		jmp	short loc_38
loc_36:
		mov	bl,ds:data_31e
		mov	cx,3

locloop_37:
		push	cx
		mov	[si],ax
		mov	[si+2],bl
		mov	dl,ds:data_43e
		mov	[si+3],dl
		mov	dl,[di]
		mov	[si+4],dl
		mov	byte ptr [si+5],0
		mov	dl,[di+1]
		mov	[si+6],dl
		add	di,2
		push	ax
		push	bx
		push	di
		mov	ax,[si+2]
		call	word ptr cs:data_16e
		mov	bl,ds:data_40e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_53e[bx],al
		add	si,10h
		inc	byte ptr ds:data_40e
		pop	di
		pop	bx
		pop	ax
		add	bl,2
		and	bl,3Fh			; '?'
		pop	cx
		loop	locloop_37		; Loop if cx > 0

loc_38:
		inc	ax
		inc	ax
		pop	cx
		loop	locloop_35		; Loop if cx > 0

		mov	word ptr [si],0FFFFh
		retn
			                        ;* No entry point to code
		add	al,[bx+di]
		add	[bp+di],al
		add	al,3
		add	[bx+di],al

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		mov	al,ds:data_31e
		add	al,3
		and	al,3Fh			; '?'
		mov	ds:data_29e,al
		mov	ds:data_27e,al
		mov	ax,ds:data_30e
		inc	ax
		call	word ptr cs:data_17e
		mov	ds:data_26e,bl
		mov	ax,ds:data_30e
		add	ax,7
		call	word ptr cs:data_17e
		mov	ds:data_28e,bl
		mov	al,ds:data_34e
		dec	al
		mov	cl,0Dh
		mul	cl			; ax = reg * al
		add	ax,0A543h
		mov	bx,ax
		call	word ptr cs:data_19e
		mov	byte ptr ds:data_34e,0
		retn
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		cmp	byte ptr ds:data_30e,32h	; '2'
		stc				; Set carry flag
		jnz	loc_39			; Jump if not zero
		retn
loc_39:
		inc	byte ptr ds:data_30e
		clc				; Clear carry flag
		retn
sub_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		cmp	byte ptr ds:data_30e,11h
		stc				; Set carry flag
		jnz	loc_40			; Jump if not zero
		retn
loc_40:
		dec	byte ptr ds:data_30e
		clc				; Clear carry flag
		retn
sub_4		endp

		db	 00h, 00h, 05h, 00h, 32h, 04h
		db	 78h
		db	8 dup (0)
		db	 04h, 00h, 32h, 00h, 78h, 00h
		db	 00h, 00h, 00h, 00h, 00h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		mov	ax,ds:data_32e
		sub	ax,bx
		jnc	loc_41			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_41:
		mov	ds:data_32e,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:data_15e
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_42			; Jump if zero
		retn
loc_42:
		mov	byte ptr ds:data_54e,0FFh
		mov	byte ptr ds:data_44e,0
		mov	byte ptr ds:data_34e,0
		jmp	word ptr cs:data_20e
sub_5		endp

loc_43:
		cmp	byte ptr ds:data_44e,28h	; '('
		jae	loc_48			; Jump if above or =
		mov	byte ptr ds:data_55e,0FFh
		inc	byte ptr ds:data_44e
		cmp	byte ptr ds:data_44e,15h
		jae	loc_47			; Jump if above or =
		test	byte ptr ds:data_44e,3
		jnz	loc_44			; Jump if not zero
		mov	byte ptr ds:data_57e,28h	; '('
loc_44:
		inc	byte ptr ds:data_33e
		and	byte ptr ds:data_33e,7
loc_45:
		mov	bx,data_25e
		mov	al,ds:data_33e
		xlat				; al=[al+[bx]] table
		xor	ah,ah			; Zero register
		mov	di,data_46e
		mov	cx,0Ch

locloop_46:
		mov	[di],ax
		add	di,2
		inc	ah
		loop	locloop_46		; Loop if cx > 0

		jmp	loc_34
loc_47:
		mov	byte ptr ds:data_33e,2
		jmp	short loc_45
loc_48:
		mov	byte ptr ds:data_56e,0FFh
		retn
			                        ;* No entry point to code
		xor	[bx+si],al
		or	al,58h			; 'X'
		add	bh,ds:data_14e[bx+si]
;*		add	ah,ch
		db	 00h,0ECh		;  Fixup - byte match
		movsw				; Mov [si] to es:[di]
		inc	ax
		push	es
		adc	ss:data_12[bp+di],di
		push	ax
		db	 61h, 67h, 75h, 72h, 6Fh
		db	0, 0, 0, 0, 0, 0
data_12		dw	0			; Data table (indexed access)
		db	2, 0
		db	27 dup (0)

seg_a		ends



		end	start
