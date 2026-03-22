
PAGE  59,132

;==========================================================================
;
;  TILE_COLLISION - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_14e	equ	200Ch			;*
data_15e	equ	6028h			;*
data_16e	equ	6036h			;*
data_17e	equ	6038h			;*
data_18e	equ	8000h			;*
data_19e	equ	0A4BBh			;*
data_20e	equ	0A783h			;*
data_21e	equ	0A810h			;*
data_22e	equ	0A87Ah			;*
data_23e	equ	0A87Dh			;*
data_24e	equ	0A881h			;*
data_25e	equ	0A89Ah			;*
data_26e	equ	0A8B7h			;*
data_27e	equ	0A8D7h			;*
data_28e	equ	0A8DEh			;*
data_29e	equ	0A8FDh			;*
data_30e	equ	0A96Ch			;*
data_31e	equ	0A985h			;*
data_32e	equ	0AA3Ch			;*
data_33e	equ	0AA3Eh			;*
data_34e	equ	0AA3Fh			;*
data_35e	equ	0AA53h			;*
data_36e	equ	0AA54h			;*
data_37e	equ	0AA55h			;*
data_38e	equ	0AA56h			;*
data_39e	equ	0AA57h			;*
data_40e	equ	0AA58h			;*
data_41e	equ	0AA59h			;*
data_42e	equ	0AA5Ah			;*
data_43e	equ	0AA5Bh			;*
data_44e	equ	0AA5Ch			;*
data_45e	equ	0AA5Dh			;*
data_46e	equ	0AA5Eh			;*
data_47e	equ	0AA5Fh			;*
data_48e	equ	0AA60h			;*
data_49e	equ	0AA61h			;*
data_50e	equ	0AA62h			;*
data_51e	equ	0AA63h			;*
data_52e	equ	0AA64h			;*
data_53e	equ	0AA65h			;*
data_54e	equ	0AA66h			;*
data_55e	equ	0AA67h			;*
data_56e	equ	0AA68h			;*
data_57e	equ	0AA69h			;*
data_58e	equ	0C010h			;*
data_59e	equ	0ED20h			;*
data_60e	equ	0FF2Eh			;*
data_61e	equ	0FF2Fh			;*
data_62e	equ	0FF30h			;*
data_63e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_16		proc	far

start:
		test	ax,0Bh
;*		add	ch,bl
		db	 00h,0DDh		;  Fixup - byte match
		mov	ds:data_32e,al
		db	12 dup (0)
		db	 28h, 1Eh, 1Eh, 1Eh, 1Eh, 1Eh
		db	 1Eh, 1Eh
		db	 28h, 28h
		db	22 dup (0)
		db	 44h,0A0h, 6Ch,0A0h,0BCh,0A0h
		db	 07h,0A1h, 52h,0A1h, 8Eh,0A1h
		db	0DEh,0A1h, 1Fh,0A2h, 47h,0A2h
		db	 97h,0A2h, 00h, 66h, 00h, 67h
		db	 6Ch, 00h, 68h, 69h, 6Dh, 6Eh
		db	 00h, 6Ch, 6Dh, 72h, 73h, 00h
		db	 83h, 84h, 00h, 86h, 00h, 95h
		db	0B1h, 98h, 99h, 00h, 9Ah, 9Bh
		db	 9Dh, 9Eh, 00h, 68h, 90h, 6Dh
		db	 91h, 00h, 9Ah, 9Bh, 9Dh,0FEh
		db	 00h, 73h, 74h, 00h, 00h
data_3		db	0			; Data table (indexed access)
		db	 6Ah, 6Bh, 6Fh, 70h, 00h, 70h
		db	 71h, 75h, 76h, 00h
data_4		db	77h
		db	 78h, 7Ah, 7Bh, 00h, 78h, 79h
		db	 7Bh, 7Ch, 00h, 7Dh, 7Eh, 77h
		db	 10h, 00h, 7Fh, 01h, 0Ch, 0Dh
		db	 00h, 77h, 10h, 00h, 0Eh, 00h
		db	 97h, 00h
		db	70h
data_5		db	71h			; Data table (indexed access)
		db	0
loc_1:
		mov	bl,75h			; 'u'
;*		add	[bx+0],dh
		db	 00h, 77h, 00h		;  Fixup - byte match
		db	 76h, 00h, 78h, 79h, 00h,0A6h
		db	 9Fh, 87h,0A1h, 00h, 99h
data_6		db	87h			; Data table (indexed access)
		db	0B3h, 88h, 00h,0A1h,0A3h, 8Ch
		db	 89h, 00h, 8Ah, 00h,0ADh, 8Dh
		db	 00h,0ADh, 8Dh, 8Bh, 10h, 00h
		db	 8Dh, 8Fh, 10h, 7Eh, 00h,0A6h
		db	 01h, 0Ch, 0Dh, 00h, 8Eh, 10h
		db	 67h, 0Eh, 00h, 6Eh, 6Fh, 73h
		db	0A7h, 00h, 6Ah, 6Bh, 6Fh,0A0h
		db	 00h,0A0h,0A1h,0A8h,0A9h, 00h
		db	 9Fh, 9Fh,0A1h,0A2h, 00h,0A2h
		db	0A3h,0AAh,0ABh, 00h,0A4h,0A5h
		db	0ACh,0ADh, 00h,0ACh,0ADh, 67h
		db	 0Eh, 00h
		db	 6Eh, 6Fh
loc_2:
		test	sp,ds:data_18e[bx]
;*		add	data_6[bx+di],0B4h
		db	 82h, 81h,0AEh, 00h,0B4h	;  Fixup - byte match
		rol	sp,cl			; Rotate
		xchg	sp,ax
;*		add	bl,dl
		db	 00h,0D3h		;  Fixup - byte match
		add	data_5[si],dl
;*		test	si,[si+0]
		db	 85h, 74h, 00h		;  Fixup - byte match
		db	 00h, 00h, 00h,0DFh,0E8h,0E9h
		db	 00h,0E0h,0E1h,0EAh,0EAh, 00h
		db	0E2h,0E2h,0EAh,0EBh
data_7		dw	0E300h
		db	0E4h, 00h, 00h, 00h
loc_5:
		in	al,0E5h			; port 0E5h ??I/O Non-standard
		db	 00h, 00h, 00h, 00h,0E7h,0ECh
		db	0EDh, 00h, 00h,0F5h,0F9h,0FAh
		db	 00h,0EDh,0EEh,0F6h,0F7h, 00h
		db	0EFh,0F0h,0F8h,0EAh, 00h,0F1h
		db	0F2h,0EAh,0EBh, 00h,0F3h,0F4h
		db	 00h, 00h, 00h, 00h, 00h,0F4h
		db	 00h, 00h,0FBh,0FCh,0B2h, 96h
		db	 00h,0FDh,0FDh,0EAh,0EAh, 00h
		db	0FDh,0F3h,0E6h,0A6h, 00h, 00h
		db	 92h,0F9h,0FAh, 00h, 93h,0BBh
		db	0BAh,0BFh, 00h, 00h,0CCh,0C8h
		db	0E9h, 00h,0CFh,0CFh,0EAh,0EBh
		db	 00h,0D0h,0D1h, 00h, 00h, 00h
		db	0AFh, 00h, 00h,0B0h, 00h,0BCh
		db	0C1h,0B2h, 96h, 00h,0CAh,0F1h
		db	0FDh,0FDh, 00h,0F2h,0F3h,0FDh
		db	0F3h, 00h,0F3h,0F4h,0F3h,0F4h
		db	 00h,0FDh,0FDh,0EAh,0EAh, 00h
		db	0FDh,0F3h,0E6h,0A6h, 00h, 00h
		db	 0Eh, 20h, 21h, 00h, 0Fh, 10h
		db	 22h, 23h, 00h, 02h, 03h, 19h
		db	 10h, 00h, 04h, 05h, 1Ah, 1Bh
		db	 00h, 1Ch, 1Dh, 24h, 25h, 00h
		db	 1Eh, 1Fh, 26h, 27h, 00h, 0Eh
		db	 0Fh, 20h, 12h, 00h, 0Fh, 10h
		db	 12h, 3Ch, 00h, 02h, 03h, 19h
		db	 28h, 00h, 04h, 05h, 29h, 2Ah
		db	 00h, 1Ch, 2Bh, 3Dh, 26h, 00h
		db	 2Ch, 11h, 27h, 31h, 00h, 0Fh
		db	 10h, 37h, 38h, 00h, 02h, 03h
		db	 32h, 33h, 00h, 04h, 05h, 34h
		db	 35h, 00h, 36h, 2Ch, 26h, 27h
		db	 00h, 11h, 11h, 31h, 39h, 00h
		db	 06h, 07h, 11h, 5Ch, 00h, 11h
		db	 42h, 3Bh, 48h, 00h, 08h, 09h
		db	 3Eh, 3Fh, 00h, 43h, 44h, 49h
		db	 4Ah, 00h, 45h, 46h, 4Bh, 4Ch
		db	 00h, 47h, 16h, 4Dh, 4Eh, 00h
		db	 11h, 4Fh, 55h, 56h, 00h, 54h
		db	 16h, 5Bh, 4Eh, 00h, 50h, 51h
		db	 57h, 58h, 00h, 52h, 53h, 59h
		db	 5Ah, 00h, 11h, 5Eh, 64h, 65h
		db	 00h, 08h, 09h, 5Dh, 3Fh, 00h
		db	 5Fh, 60h, 2Dh, 2Eh, 00h, 61h
		db	 62h, 2Fh, 30h, 00h, 63h, 16h
		db	 3Ah, 4Eh, 00h, 0Ah, 0Bh, 40h
		db	 41h, 00h, 00h, 00h, 14h, 15h
		db	 00h, 06h, 07h, 11h, 11h, 00h
		db	 13h, 75h, 17h, 77h, 00h, 17h
		db	 77h, 18h, 7Ah, 01h, 00h,0B6h
		db	0B7h, 00h, 01h, 00h,0B5h,0B6h
		db	 00h, 01h, 00h,0B6h,0B7h, 00h
		db	 01h, 00h,0B7h,0B8h, 00h, 01h
		db	 00h,0B6h,0B5h, 00h, 01h,0B9h
		db	0B6h,0B8h, 00h, 01h,0BEh,0B8h
		db	0B8h,0C0h, 01h,0B8h,0C0h,0C5h
		db	0C6h, 01h, 00h, 00h,0C2h,0C7h
		db	 01h,0BDh,0BEh,0C5h,0C3h, 01h
		db	 00h, 00h,0BDh,0C2h, 01h,0C9h
		db	0B7h,0CBh, 00h, 01h,0C9h,0CDh
		db	0CDh,0CEh, 01h, 00h,0C9h,0BEh
		db	0D2h, 01h, 00h,0CDh,0C2h,0D2h
		db	 01h,0CEh, 00h,0C2h,0D4h, 01h
		db	 00h, 00h,0D5h,0D8h, 01h, 00h
		db	 00h,0D8h,0D9h, 01h, 00h, 00h
		db	0DAh,0DCh, 01h, 00h, 00h,0DBh
		db	0DCh, 01h, 00h, 00h,0DBh,0DEh
		db	 01h, 00h, 00h,0D5h,0D6h, 01h
		db	 00h, 00h,0D6h,0D6h, 01h, 00h
		db	 00h,0D7h,0D7h, 01h, 00h, 00h
		db	0D6h,0D7h, 01h, 00h, 00h,0D8h
		db	0D9h, 01h, 00h, 00h,0DAh,0DBh
		db	 01h, 00h, 00h,0DBh,0DCh, 01h
		db	 00h, 00h,0DCh,0DBh, 01h, 00h
		db	 00h,0DDh,0DEh, 8Bh, 36h, 10h
		db	0C0h,0C6h, 06h, 59h,0AAh, 00h
		db	0C6h, 06h, 5Ah,0AAh, 00h
loc_6:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jz	loc_9			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:data_16e
		jc	loc_8			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:data_15e
		mov	bl,ds:data_41e
		xor	bh,bh			; Zero register
		mov	al,ds:data_59e[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	loc_8			; Jump if zero
		test	byte ptr ds:data_42e,80h
		jnz	loc_8			; Jump if not zero
		mov	al,[si+5]
		and	al,1Fh
		test	byte ptr [si+4],1Fh
		jnz	loc_7			; Jump if not zero
		or	al,80h
loc_7:
		mov	ds:data_42e,al
loc_8:
		inc	byte ptr ds:data_41e
		add	si,10h
		jmp	short loc_6
loc_9:
		mov	si,ds:data_58e
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:data_42e,0FFh
		jz	loc_14			; Jump if zero
		mov	al,ds:data_42e
		push	ax
		and	al,1Fh
		call	word ptr cs:data_17e
		mov	bl,ah
		xor	bh,bh			; Zero register
		pop	ax
		mov	ah,al
		and	ah,7Fh
		shr	bx,1			; Shift w/zeros fill
		sub	ah,2
		jc	loc_10			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
loc_10:
		test	al,80h
		jz	loc_11			; Jump if zero
		mov	byte ptr ds:data_53e,0FFh
		mov	byte ptr ds:data_63e,34h	; '4'
		add	bx,bx
		jmp	short loc_12
loc_11:
		mov	byte ptr ds:data_47e,0FFh
		mov	byte ptr ds:data_63e,35h	; '5'
loc_12:
		call	tilecol_func_4
		test	byte ptr ds:data_53e,0FFh
		jz	loc_13			; Jump if zero
		mov	al,ds:data_43e
		cmp	al,6
		sbb	al,al
		neg	al
		mov	ds:data_54e,al
		mov	byte ptr ds:data_55e,0
		mov	byte ptr ds:data_38e,0
		mov	byte ptr ds:data_49e,0
		mov	byte ptr ds:data_47e,0FFh
		mov	byte ptr ds:data_56e,0FFh
		mov	byte ptr ds:data_48e,8
loc_13:
		mov	byte ptr ds:data_53e,0
loc_14:
		test	byte ptr ds:data_60e,0FFh
		jz	loc_15			; Jump if zero
		jmp	loc_60
loc_15:
		inc	byte ptr ds:data_44e
		test	byte ptr ds:data_38e,0FFh
		jz	loc_16			; Jump if zero
		jmp	loc_31
loc_16:
		test	byte ptr ds:data_49e,0FFh
		jz	loc_17			; Jump if zero
;*		jmp	loc_30			;*
		db	0E9h,0E6h, 00h		;  Fixup - byte match
loc_17:
		add	byte ptr ds:data_46e,80h
		jnc	loc_20			; Jump if carry=0
		test	byte ptr ds:data_47e,0FFh
		jnz	loc_18			; Jump if not zero
		call	tilecol_func_1
		jc	loc_20			; Jump if carry Set
		inc	byte ptr ds:data_45e
		jmp	short loc_20
loc_18:
		dec	byte ptr ds:data_48e
		jnz	loc_19			; Jump if not zero
		mov	byte ptr ds:data_47e,0
		jmp	short loc_20
loc_19:
		call	tilecol_func_2
		sbb	al,al
		not	al
		mov	ds:data_47e,al
		dec	byte ptr ds:data_45e
loc_20:
		test	byte ptr ds:data_56e,0FFh
		jnz	loc_28			; Jump if not zero
		call	word ptr cs:data_7
		and	al,0C0h
		jnz	loc_22			; Jump if not zero
		test	byte ptr ds:data_43e,0FFh
		jz	loc_21			; Jump if zero
		cmp	byte ptr ds:data_43e,4
		je	loc_21			; Jump if equal
		cmp	byte ptr ds:data_43e,7
		jne	loc_22			; Jump if not equal
loc_21:
		mov	al,ds:data_43e
		mov	ds:data_50e,al
		mov	byte ptr ds:data_51e,0
		mov	byte ptr ds:data_49e,0FFh
		jmp	loc_35
loc_22:
		mov	al,data_4
		add	al,10h
		cmp	al,ds:data_32e
		jae	loc_24			; Jump if above or =
		mov	al,6
		cmp	byte ptr ds:data_43e,6
		jb	loc_23			; Jump if below
		mov	al,7
loc_23:
		mov	ds:data_43e,al
		jmp	loc_35
loc_24:
		sub	al,5
		cmp	al,ds:data_32e
		jae	loc_26			; Jump if above or =
		mov	al,0
		cmp	byte ptr ds:data_43e,7
		jb	loc_25			; Jump if below
		mov	al,6
loc_25:
		mov	ds:data_43e,al
		jmp	loc_35
loc_26:
		mov	al,4
		cmp	byte ptr ds:data_43e,7
		jb	loc_27			; Jump if below
		mov	al,6
loc_27:
		mov	ds:data_43e,al
		jmp	loc_35
loc_28:
		mov	bx,0A4B4h
		test	byte ptr ds:data_54e,0FFh
		jnz	loc_29			; Jump if not zero
		mov	bx,data_19e
loc_29:
		mov	al,ds:data_55e
		xlat				; al=[al+[bx]] table
		or	al,al			; Zero ?
		jns	$+9			; Jump if not sign
		and	al,7Fh
		mov	byte ptr ds:data_56e,0
		mov	ds:data_43e,al
		inc	byte ptr ds:data_55e
		jmp	loc_35
			                        ;* No entry point to code
		or	cl,[bx+di]
		push	es
		add	ax,[bp+si]
		add	ax,word ptr ss:[203h][bp+si]
		add	ax,[bp+si]
		add	[bp+di],ax
;*		cmp	dh,6
		db	 82h,0FEh, 06h		;  Fixup - byte match
		db	 63h,0AAh,0A0h, 63h,0AAh, 24h
		db	 01h, 02h, 06h, 62h,0AAh,0A2h
		db	 5Bh,0AAh,0A0h, 63h,0AAh, 3Ch
		db	 06h, 72h, 69h,0A0h, 62h,0AAh
		db	0FEh,0C0h,0A2h, 5Bh,0AAh,0C6h
		db	 06h, 57h,0AAh, 00h,0C6h, 06h
		db	 64h,0AAh, 00h,0C6h, 06h, 61h
		db	0AAh, 00h,0C6h, 06h, 56h,0AAh
		db	0FFh,0C6h, 06h, 75h,0FFh, 36h
		db	0EBh
		db	46h
loc_31:
		mov	byte ptr ds:data_63e,36h	; '6'
		mov	al,ds:data_39e
		inc	al
		cmp	al,4
		jb	loc_32			; Jump if below
		mov	al,2
loc_32:
		mov	ds:data_39e,al
		inc	byte ptr ds:data_52e
		mov	al,ds:data_52e
		cmp	al,0Ah
		jb	loc_35			; Jump if below
		mov	byte ptr ds:data_38e,0
		jmp	short loc_35

zr3_16		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

tilecol_func_1		proc	near
		mov	ax,ds:data_32e
		dec	ax
		mov	bx,0Eh
		sub	bx,ax
		cmc				; Complement carry
		jnc	loc_33			; Jump if carry=0
		retn
loc_33:
		mov	ds:data_32e,ax
		retn
tilecol_func_1		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

tilecol_func_2		proc	near
		mov	ax,ds:data_32e
		inc	ax
		mov	bx,1Eh
		sub	bx,ax
		jnc	loc_34			; Jump if carry=0
		retn
loc_34:
		mov	ds:data_32e,ax
		retn
tilecol_func_2		endp

loc_35:
		push	cs
		pop	es
		mov	di,data_57e
		mov	ax,0FFFFh
		mov	cx,0A0h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	byte ptr ds:data_35e,0
		mov	byte ptr ds:data_36e,1
		mov	bl,ds:data_43e
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:data_20e[bx]
		mov	bp,ds:data_21e[bx]
		mov	cx,0Ch
		call	tilecol_multiply
		mov	byte ptr ds:data_35e,0Ch
		mov	byte ptr ds:data_36e,0
		mov	bl,ds:data_44e
		and	bl,1
		add	bl,bl
		mov	si,ds:data_28e[bx]
		mov	bp,ds:data_29e[bx]
		mov	cx,0Bh
		call	tilecol_multiply
		mov	byte ptr ds:data_35e,9
		mov	byte ptr ds:data_36e,6
		mov	bl,ds:data_45e
		and	bl,3
		add	bl,bl
		mov	si,ds:data_24e[bx]
		mov	bp,ds:data_25e[bx]
		mov	cx,7
		call	tilecol_multiply
		mov	byte ptr ds:data_35e,11h
		mov	byte ptr ds:data_36e,6
		mov	bl,ds:data_45e
		and	bl,3
		add	bl,bl
		mov	si,ds:data_26e[bx]
		mov	bp,data_27e
		mov	cx,7
		call	tilecol_multiply
		mov	byte ptr ds:data_35e,19h
		mov	byte ptr ds:data_36e,8
		mov	si,data_22e
		mov	bp,data_23e
		mov	cx,4
		call	tilecol_multiply
		mov	byte ptr ds:data_41e,0
		mov	ax,ds:data_32e
		mov	si,ds:data_58e
		mov	di,data_57e
		mov	cx,1Dh
loc_36:
		push	cx
		push	di
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		mov	ds:data_37e,bl
		jc	loc_40			; Jump if carry Set
		xor	cl,cl			; Zero register
loc_37:
		push	cx
		push	ax
		cmp	byte ptr [di],0FFh
		je	loc_39			; Jump if equal
		mov	[si],ax
		mov	al,ds:data_33e
		add	al,cl
		and	al,3Fh			; '?'
		mov	[si+2],al
		mov	al,ds:data_37e
		mov	[si+3],al
		mov	al,[di]
		mov	ah,al
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	bl,ds:data_60e
		not	bl
		and	bl,80h
		or	al,bl
		mov	[si+4],al
		mov	[si+6],ah
		mov	byte ptr [si+5],0
		test	byte ptr ds:data_42e,0FFh
		jz	loc_38			; Jump if zero
		or	byte ptr [si+5],20h	; ' '
loc_38:
		push	di
		mov	ax,[si+2]
		call	word ptr cs:data_15e
		mov	bl,ds:data_41e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_59e[bx],al
		add	si,10h
		inc	byte ptr ds:data_41e
		pop	di
loc_39:
		inc	di
		pop	ax
		pop	cx
		inc	cl
		cmp	cl,0Ah
		jne	loc_37			; Jump if not equal
loc_40:
		inc	ax
		pop	di
		add	di,0Ah
		pop	cx
		loop	locloop_41		; Loop if cx > 0

		jmp	short loc_42

locloop_41:
		jmp	loc_36
loc_42:
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:data_38e,0FFh
		jnz	loc_43			; Jump if not zero
		retn
loc_43:
		mov	di,0A917h
		mov	bp,0A930h
		cmp	byte ptr ds:data_43e,6
		jb	loc_44			; Jump if below
		mov	di,data_30e
		mov	bp,data_31e
loc_44:
		mov	bl,ds:data_39e
		and	bl,3
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	di,[bx+di]
		push	di
		mov	di,bp
		mov	bp,[bx+di]
		pop	di
		mov	ax,ds:data_32e
		sub	ax,0Ah
		cmp	byte ptr ds:data_43e,5
		jne	loc_45			; Jump if not equal
		add	ax,4
loc_45:
		mov	cx,0Dh
loc_46:
		push	cx
		push	ax
		call	word ptr cs:data_16e
		pop	ax
		mov	ds:data_37e,bl
		jnc	loc_49			; Jump if carry=0
		mov	cx,8

locloop_47:
		rol	byte ptr ds:[bp],1	; Rotate
		jnc	loc_48			; Jump if carry=0
		inc	di
loc_48:
		loop	locloop_47		; Loop if cx > 0

		jmp	short loc_52
loc_49:
		xor	cl,cl			; Zero register
loc_50:
		push	cx
		push	ax
		rol	byte ptr ds:[bp],1	; Rotate
		jnc	loc_51			; Jump if carry=0
		mov	[si],ax
		mov	al,ds:data_33e
		add	al,cl
		add	al,4
		and	al,3Fh			; '?'
		mov	[si+2],al
		mov	al,ds:data_37e
		mov	[si+3],al
		mov	al,[di]
		mov	ah,al
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		or	al,20h			; ' '
		mov	[si+4],al
		mov	[si+6],ah
		mov	byte ptr [si+5],0
		push	di
		mov	ax,[si+2]
		call	word ptr cs:data_15e
		mov	bl,ds:data_41e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_59e[bx],al
		add	si,10h
		inc	byte ptr ds:data_41e
		pop	di
		inc	di
loc_51:
		pop	ax
		pop	cx
		inc	cl
		cmp	cl,8
		jne	loc_50			; Jump if not equal
loc_52:
		inc	ax
		inc	bp
		pop	cx
		loop	locloop_53		; Loop if cx > 0

		jmp	short loc_54

locloop_53:
		jmp	loc_46
loc_54:
		mov	word ptr [si],0FFFFh
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

tilecol_multiply		proc	near
		mov	al,ds:data_35e
		mov	bl,0Ah
		mul	bl			; ax = reg * al
		mov	bl,ds:data_36e
		xor	bh,bh			; Zero register
		add	ax,bx
		add	ax,0AA69h
		mov	di,ax

locloop_55:
		push	cx
		mov	cx,8

locloop_56:
		rol	byte ptr ds:[bp],1	; Rotate
		jnc	loc_57			; Jump if carry=0
		lodsb				; String [si] to al
		mov	[di],al
loc_57:
		inc	di
		loop	locloop_56		; Loop if cx > 0

		inc	di
		inc	di
		inc	bp
		pop	cx
		loop	locloop_55		; Loop if cx > 0

		retn
tilecol_multiply		endp

			                        ;* No entry point to code
		cwd				; Word to double word
		cmpsw				; Cmp [si] to es:[di]
		scasw				; Scan es:[di] for ax
		cmpsw				; Cmp [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		cmpsw				; Cmp [si] to es:[di]
		mov	dx,0C5A7h
		cmpsw				; Cmp [si] to es:[di]
		iret				; Interrupt return
			                        ;* No entry point to code
		cmpsw				; Cmp [si] to es:[di]
		db	0DAh,0A7h,0E4h,0A7h,0FAh,0A7h
		db	0EFh,0A7h, 05h,0A8h, 00h, 02h
		db	 01h, 10h, 11h, 12h, 13h, 14h
		db	 15h, 17h, 16h, 00h, 02h, 06h
		db	 10h, 11h, 12h, 13h, 14h, 15h
		db	 17h, 16h, 00h, 03h, 01h, 2Eh
		db	 11h, 12h, 13h, 14h, 15h, 17h
		db	 16h, 00h, 03h, 06h, 2Eh, 11h
		db	 12h, 13h, 14h, 15h, 17h, 16h
		db	 05h, 04h, 19h, 18h, 13h, 1Ah
		db	 14h, 15h, 17h, 16h, 07h, 04h
		db	 76h, 77h, 18h, 13h, 1Ah, 14h
		db	 15h, 17h, 16h, 05h, 04h, 1Ch
		db	 1Bh, 1Dh, 1Eh, 1Fh, 20h, 22h
		db	 16h, 00h, 02h, 01h
		db	'#$'
		db	'%&', 27h, '()!'
		db	0, 2, 6
		db	'#$'
		db	'%&', 27h, '()!'
		db	0, 3, 1
		db	'*$'
		db	'%&', 27h, '()!'
		db	0, 3, 6
		db	'*$'
		db	'%&', 27h, '()!&'
		db	0A8h, 32h,0A8h, 26h,0A8h, 32h
		db	0A8h, 3Eh,0A8h, 4Ah,0A8h, 56h
		db	0A8h, 62h,0A8h, 6Eh,0A8h, 62h
		db	0A8h, 6Eh,0A8h, 00h, 00h, 00h
		db	 80h, 40h, 80h, 20h, 80h, 50h
		db	 16h, 00h, 04h, 00h, 00h, 00h
		db	 80h, 20h, 80h, 20h, 80h, 50h
		db	 16h, 00h, 04h, 00h, 00h, 00h
		db	 00h, 00h, 20h, 80h, 20h, 90h
		db	 36h, 00h, 04h, 00h, 00h, 00h
		db	 00h, 00h, 20h, 80h, 30h, 90h
		db	 36h, 00h, 04h, 00h, 00h, 08h
		db	 20h, 10h, 20h, 10h, 00h, 18h
		db	 0Ah, 00h, 04h, 08h, 04h, 08h
		db	 04h, 08h, 04h, 08h, 04h, 00h
		db	 06h, 00h, 04h, 08h, 02h, 08h
		db	 04h, 08h, 04h, 08h, 04h, 00h
		db	 06h, 00h, 04h, 2Bh, 2Ch, 2Dh
		db	 80h, 00h, 80h, 80h, 89h,0A8h
		db	 8Fh,0A8h, 95h,0A8h, 8Fh,0A8h
		db	'PQRTSUVWXZY[\]_^`'
		db	0A2h,0A8h,0A9h,0A8h,0B0h,0A8h
		db	0A9h,0A8h, 20h, 00h, 20h, 00h
		db	0A0h, 00h,0A0h, 00h, 20h, 20h
		db	 00h,0A0h, 00h,0A0h, 00h, 00h
		db	 20h, 00h,0A0h, 00h,0A0h,0BFh
		db	0A8h,0C7h,0A8h,0CFh,0A8h,0C7h
		db	0A8h
		db	'ubcdsetfugcisjthaklpsqtr'
		db	0A0h, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h,0E2h,0A8h,0F1h,0A8h
		db	'657<08=19>2:;34@AFBGJCHKIDE'
		db	 01h,0A9h, 0Ch,0A9h, 10h, 40h
		db	 28h, 80h, 28h, 80h, 28h, 80h
		db	 30h, 80h, 80h, 10h, 00h, 28h
		db	 00h, 58h, 00h, 58h, 10h, 40h
		db	 00h, 40h, 1Fh,0A9h, 20h,0A9h
		db	 23h,0A9h, 2Ah,0A9h, 80h, 83h
		db	 82h, 81h, 8Ah, 89h, 86h, 87h
		db	 85h, 88h, 84h, 8Dh, 8Eh, 8Ch
		db	 8Fh, 8Bh, 81h, 38h,0A9h, 45h
		db	0A9h, 52h,0A9h, 5Fh,0A9h
		db	12 dup (0)
		db	 80h, 00h, 00h
		db	7 dup (0)
		db	 10h, 00h, 40h, 80h, 00h, 00h
		db	 00h, 00h, 00h, 08h, 00h, 08h
		db	 00h, 18h, 20h, 08h, 80h, 00h
		db	 00h, 00h, 00h, 00h, 08h, 00h
		db	 08h, 10h, 08h, 20h, 00h, 80h
		db	 74h,0A9h, 76h,0A9h, 79h,0A9h
		db	 7Fh,0A9h, 90h, 91h, 92h, 93h
		db	 94h, 95h, 96h, 97h, 98h, 96h
		db	 99h, 9Ah, 9Bh, 9Bh, 9Ch, 9Bh
		db	 9Dh, 8Dh,0A9h, 9Ah,0A9h,0A7h
		db	0A9h,0A7h,0A9h
		db	8 dup (0)
		db	 20h, 20h
		db	8 dup (0)
		db	 20h, 00h, 20h, 00h, 20h, 00h
		db	 00h, 00h, 20h, 20h, 00h, 20h
		db	 00h, 20h, 00h, 20h, 00h, 20h
		db	 00h, 00h, 00h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

tilecol_func_4		proc	near
		mov	ax,ds:data_34e
		sub	ax,bx
		jnc	loc_58			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_58:
		mov	ds:data_34e,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:data_14e
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_59			; Jump if zero
		retn
loc_59:
		mov	byte ptr ds:data_40e,0
		mov	byte ptr ds:data_60e,0FFh
		mov	byte ptr ds:data_40e,0
		mov	byte ptr ds:data_53e,0
		mov	byte ptr ds:data_55e,0
		mov	byte ptr ds:data_38e,0
		mov	byte ptr ds:data_49e,0
		retn
tilecol_func_4		endp

loc_60:
		cmp	byte ptr ds:data_40e,28h	; '('
		jae	loc_63			; Jump if above or =
		mov	byte ptr ds:data_61e,0FFh
		inc	byte ptr ds:data_40e
		cmp	byte ptr ds:data_40e,1Eh
		jae	loc_62			; Jump if above or =
		inc	byte ptr ds:data_44e
		mov	al,ds:data_44e
		and	al,1
		add	al,2
		mov	ds:data_43e,al
		mov	al,ds:data_44e
		and	al,3
		jz	loc_61			; Jump if zero
		jmp	loc_35
loc_61:
		mov	byte ptr ds:data_63e,37h	; '7'
		jmp	loc_35
loc_62:
		mov	byte ptr ds:data_44e,1
		mov	byte ptr ds:data_43e,0Ah
		jmp	loc_35
loc_63:
		mov	byte ptr ds:data_62e,0FFh
		retn
			                        ;* No entry point to code
		push	ds
		add	[bx+si],cl
		and	[bp+di],al
;*		loopnz	locloop_64		;*Loop if zf=0, cx>0

		db	0E0h, 2Eh		;  Fixup - byte match
		add	ax,4900h
		stosb				; Store al to es:[di]
		les	cx,dword ptr [bx+di]	; Load seg:offset ptr
		adc	word ptr ss:[600h][bp+di],di
		inc	sp
;*		jc	loc_65			;*Jump if carry Set
		db	 72h, 61h		;  Fixup - byte match
		db	 67h, 6Fh, 6Eh
		db	342 dup (0)

seg_a		ends



		end	start
