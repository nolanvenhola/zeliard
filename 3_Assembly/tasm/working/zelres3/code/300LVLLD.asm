
PAGE  59,132

;==========================================================================
;
;  LEVEL_LOADER - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_6e		equ	2000h			;*
data_7e		equ	2026h			;*
data_8e		equ	2028h			;*
data_9e		equ	203Eh			;*
data_10e	equ	3022h			;*
data_11e	equ	3024h			;*
data_12e	equ	3026h			;*
data_13e	equ	3028h			;*
data_14e	equ	84BEh			;*
data_15e	equ	0A569h			;*
data_16e	equ	0A572h			;*
data_17e	equ	0A59Ah			;*
data_18e	equ	0A59Bh			;*
data_19e	equ	0A59Ch			;*
data_20e	equ	0A59Dh			;*
data_21e	equ	0A59Eh			;*
data_22e	equ	0A59Fh			;*
data_23e	equ	0A5A0h			;*
data_24e	equ	0A5A1h			;*
data_25e	equ	0A5A2h			;*
data_26e	equ	0A5A3h			;*
data_27e	equ	0A5A4h			;*
data_28e	equ	0A5A5h			;*
data_29e	equ	0A5A6h			;*
data_30e	equ	0A5A7h			;*
data_31e	equ	0FF1Ah			;*
data_32e	equ	0FF26h			;*
data_33e	equ	0FF2Ch			;*
data_34e	equ	0FF33h			;*
data_35e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_00		proc	far

start:
		test	al,5
		add	[bx+si],al
		add	ah,ds:data_14e[bx+si]
		movsw				; Mov [si] to es:[di]
		mov	es,cs:data_33e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	es,cs:data_33e
		mov	si,0A58Fh
		mov	di,6000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_33e
		mov	si,6000h
		mov	bp,0D000h
		mov	cx,100h
		call	word ptr cs:data_13e
		pop	ds
		inc	byte ptr ds:[0A0h]
		mov	al,0
		cmp	byte ptr ds:[0A0h],9
		jb	loc_1			; Jump if below
		mov	byte ptr ds:[0A0h],9
		mov	al,1
loc_1:
		mov	ds:data_27e,al
		mov	bx,2552h
		call	word ptr cs:data_9e
		and	byte ptr ds:[0C2h],0FEh
		mov	bx,0C6Eh
		mov	cx,0Dh

locloop_2:
		test	cx,1
		jnz	loc_3			; Jump if not zero
		mov	byte ptr ds:data_35e,1Ah
loc_3:
		push	cx
		push	bx
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],3
		call	lvload_multiply
		call	lvload_multiply_2
		pop	bx
		cmp	bh,24h			; '$'
		je	loc_4			; Jump if equal
		push	bx
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:data_6e
		pop	bx
		add	bh,2
loc_4:
		pop	cx
		loop	locloop_2		; Loop if cx > 0

		mov	byte ptr ds:[0E7h],4
		mov	bx,246Eh
		call	lvload_multiply
		mov	cx,5

locloop_5:
		push	cx
		call	lvload_multiply_2
		pop	cx
		loop	locloop_5		; Loop if cx > 0

		mov	byte ptr ds:[0E7h],5
loc_6:
		mov	bx,246Eh
		call	lvload_multiply
		call	lvload_multiply_2
		call	lvload_multiply_2
		inc	byte ptr ds:[0E7h]
		cmp	byte ptr ds:[0E7h],9
		jb	loc_6			; Jump if below
		mov	bx,246Eh
		call	lvload_multiply
		call	word ptr cs:data_11e
		xor	bh,bh			; Zero register
		mov	bl,byte ptr ds:[0A0h]
		dec	bx
		mov	al,ds:data_15e[bx]
		mov	ds:data_17e,al
		mov	byte ptr ds:data_18e,2
		call	lvload_func_3
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	byte ptr ds:data_28e,0
loc_7:
		mov	al,ds:data_28e
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	lvload_multiply_2
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		inc	byte ptr ds:data_28e
		cmp	byte ptr ds:data_28e,2
		jb	loc_7			; Jump if below
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,6
		mov	al,ds:data_20e
		mov	cx,1110h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	byte ptr ds:data_35e,1Bh
		mov	byte ptr ds:data_28e,0
loc_8:
		mov	al,ds:data_28e
		or	al,80h
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		sub	bx,18h
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	lvload_multiply_2
		call	lvload_multiply_2
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,6
		mov	al,ds:data_20e
		mov	cx,1110h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		inc	byte ptr ds:data_28e
		cmp	byte ptr ds:data_28e,2
		jb	loc_8			; Jump if below
		mov	bx,2552h
		mov	cx,410h
		xor	al,al			; Zero register
		call	word ptr cs:data_6e
		call	word ptr cs:data_11e
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	byte ptr ds:data_28e,0
loc_9:
		mov	al,ds:data_28e
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	lvload_multiply_2
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		inc	byte ptr ds:data_28e
		cmp	byte ptr ds:data_28e,4
		jb	loc_9			; Jump if below
		mov	byte ptr ds:data_30e,0C8h
loc_10:
		inc	byte ptr ds:data_29e
		test	byte ptr ds:data_29e,1
		jnz	loc_11			; Jump if not zero
		inc	byte ptr ds:data_28e
		inc	byte ptr ds:data_30e
		cmp	byte ptr ds:data_30e,3
		jb	loc_11			; Jump if below
		mov	byte ptr ds:data_30e,0
		mov	byte ptr ds:data_35e,1Ch
loc_11:
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		call	lvload_func_4
		pushf				; Push flags
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	al,ds:data_28e
		and	al,1
		add	al,2
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	lvload_multiply_2
		popf				; Pop flags
		jnc	loc_10			; Jump if carry=0
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,6
		mov	al,ds:data_20e
		mov	cx,1110h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	byte ptr ds:data_35e,1Bh
		mov	byte ptr ds:data_28e,0
loc_12:
		mov	al,ds:data_28e
		or	al,80h
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		sub	bx,18h
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	lvload_multiply_2
		call	lvload_multiply_2
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,6
		mov	al,ds:data_20e
		mov	cx,1110h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		inc	byte ptr ds:data_28e
		cmp	byte ptr ds:data_28e,2
		jb	loc_12			; Jump if below
		mov	al,ds:data_27e
		mov	bl,byte ptr ds:[0A0h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	bx,ds:data_16e[bx]
		call	word ptr cs:data_9e
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_7e
		mov	byte ptr ds:data_28e,4
loc_13:
		mov	al,ds:data_28e
		dec	al
		mov	bl,ds:data_19e
		xor	bh,bh			; Zero register
		mov	cl,ds:data_20e
		call	word ptr cs:data_12e
		call	lvload_multiply_2
		mov	ah,ds:data_19e
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		mov	al,ds:data_20e
		mov	cx,310h
		xor	di,di			; Zero register
		call	word ptr cs:data_8e
		dec	byte ptr ds:data_28e
		jnz	loc_13			; Jump if not zero
		push	ds
		mov	ds,cs:data_33e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
loc_14:
		test	byte ptr ds:data_32e,0FFh
		jz	loc_14			; Jump if zero
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	bx,2456h
		mov	cx,618h
		xor	al,al			; Zero register
		call	word ptr cs:data_6e
		mov	byte ptr ds:[0E7h],8
loc_15:
		mov	bx,246Eh
		call	lvload_multiply
		call	lvload_multiply_2
		call	lvload_multiply_2
		dec	byte ptr ds:[0E7h]
		cmp	byte ptr ds:[0E7h],5
		jae	loc_15			; Jump if above or =
		mov	bx,246Eh
		call	lvload_multiply
		mov	cx,5

locloop_16:
		push	cx
		call	lvload_multiply_2
		pop	cx
		loop	locloop_16		; Loop if cx > 0

		mov	bx,246Eh
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:data_6e
		mov	bx,266Eh
		mov	cx,0Dh

locloop_17:
		test	cx,1
		jnz	loc_18			; Jump if not zero
		mov	byte ptr ds:data_35e,1Ah
loc_18:
		push	cx
		push	bx
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],3
		call	lvload_multiply
		call	lvload_multiply_2
		pop	bx
		cmp	bh,3Eh			; '>'
		je	loc_19			; Jump if equal
		push	bx
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:data_6e
		pop	bx
		add	bh,2
loc_19:
		pop	cx
		loop	locloop_17		; Loop if cx > 0

		mov	cx,618h
		xor	al,al			; Zero register
		jmp	word ptr cs:data_6e

zr3_00		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

lvload_multiply		proc	near
		mov	al,byte ptr ds:[0E7h]
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,0A435h
		mov	si,ax
		mov	cx,3

locloop_20:
		push	cx
		mov	cx,3

locloop_21:
		push	cx
		lodsb				; String [si] to al
		push	si
		push	bx
		call	word ptr cs:data_10e
		pop	bx
		pop	si
		add	bl,8
		pop	cx
		loop	locloop_21		; Loop if cx > 0

		sub	bl,18h
		add	bh,2
		pop	cx
		loop	locloop_20		; Loop if cx > 0

		retn
lvload_multiply		endp

		db	 00h, 02h, 04h, 01h, 03h, 05h
		db	 00h, 00h, 06h, 07h, 09h, 0Bh
		db	 08h, 0Ah, 0Ch, 00h, 00h, 00h
		db	 00h, 02h, 0Eh, 01h, 0Dh, 0Fh
		db	 00h, 00h, 10h, 07h, 09h, 11h
		db	 08h, 0Ah, 12h, 00h, 00h, 00h
		db	 00h, 14h, 16h, 13h, 15h, 17h
		db	 00h, 00h, 18h, 19h, 00h, 1Ch
		db	 1Ah, 1Bh, 1Dh, 00h, 00h, 1Eh
		db	 1Fh, 00h, 23h, 20h, 21h, 24h
		db	 00h, 22h, 25h, 1Fh, 00h, 23h
		db	 20h, 26h, 28h, 00h, 27h, 29h
		db	 1Fh, 00h
		db	'#*,(+-).1#/24035'

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

lvload_multiply_2		proc	near
		mov	cl,ds:data_34e
		mov	al,4
		mul	cl			; ax = reg * al
loc_22:
		cmp	ds:data_31e,al
		jb	loc_22			; Jump if below
		mov	byte ptr ds:data_31e,0
		retn
lvload_multiply_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

lvload_func_3		proc	near
		mov	byte ptr ds:data_19e,94h
		mov	byte ptr ds:data_20e,50h	; 'P'
		xor	cl,cl			; Zero register
		mov	al,ds:data_17e
		sub	al,ds:data_19e
		jz	loc_24			; Jump if zero
		jnc	loc_23			; Jump if carry=0
		neg	al
		dec	cl
		jmp	short loc_24
loc_23:
		inc	cl
loc_24:
		mov	ds:data_23e,al
		mov	ds:data_21e,cl
		xor	cl,cl			; Zero register
		mov	al,ds:data_18e
		sub	al,ds:data_20e
		jz	loc_26			; Jump if zero
		jnc	loc_25			; Jump if carry=0
		neg	al
		dec	cl
		jmp	short loc_26
loc_25:
		inc	cl
loc_26:
		mov	ds:data_24e,al
		mov	ds:data_22e,cl
		mov	al,ds:data_23e
		shr	al,1			; Shift w/zeros fill
		mov	ds:data_26e,al
		mov	byte ptr ds:data_25e,0
		mov	al,ds:data_23e
		cmp	al,ds:data_24e
		jb	loc_27			; Jump if below
		retn
loc_27:
		mov	al,ds:data_24e
		shr	al,1			; Shift w/zeros fill
		mov	ds:data_26e,al
		mov	byte ptr ds:data_25e,0FFh
		retn
lvload_func_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

lvload_func_4		proc	near
		test	byte ptr ds:data_25e,0FFh
		jnz	loc_30			; Jump if not zero
		mov	al,ds:data_26e
		sub	al,ds:data_24e
		jnc	loc_28			; Jump if carry=0
		add	al,ds:data_23e
		mov	ah,ds:data_22e
		add	ds:data_20e,ah
loc_28:
		mov	ds:data_26e,al
		mov	al,ds:data_21e
		add	ds:data_19e,al
		mov	al,ds:data_17e
		cmp	al,ds:data_19e
		stc				; Set carry flag
		jnz	loc_29			; Jump if not zero
		retn
loc_29:
		clc				; Clear carry flag
		retn
loc_30:
		mov	al,ds:data_26e
		sub	al,ds:data_23e
		jnc	loc_31			; Jump if carry=0
		add	al,ds:data_24e
		mov	ah,ds:data_21e
		add	ds:data_19e,ah
loc_31:
		mov	ds:data_26e,al
		mov	al,ds:data_22e
		add	ds:data_20e,al
		mov	al,ds:data_18e
		cmp	al,ds:data_20e
		stc				; Set carry flag
		jnz	loc_32			; Jump if not zero
		retn
loc_32:
		clc				; Clear carry flag
		retn
lvload_func_4		endp

			                        ;* No entry point to code
		cmp	al,0F4h
		push	sp
		db	0DCh, 6Ch,0C4h, 84h,0ACh, 98h
		db	 00h, 0Fh, 00h, 3Dh, 00h, 15h
		db	 00h, 37h, 00h, 1Bh, 00h, 31h
		db	 00h, 21h, 00h, 2Bh, 00h, 26h
		db	 02h
		db	'_MFAN.MSD'
		db	0, 2
		db	'6DMAN.GRP'
		db	15 dup (0)

seg_a		ends



		end	start
