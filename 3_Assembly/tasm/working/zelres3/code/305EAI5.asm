
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				_305MAPBO                                ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   5-Apr-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    9          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	0A2AEh			;*
data_2e		equ	0B5B4h			;*
data_14e	equ	1312h			;*
data_15e	equ	6008h			;*
data_16e	equ	600Ah			;*
data_17e	equ	600Ch			;*
data_18e	equ	600Eh			;*
data_19e	equ	6010h			;*
data_20e	equ	6014h			;*
data_21e	equ	6028h			;*
data_22e	equ	602Ah			;*
data_23e	equ	602Ch			;*
data_24e	equ	602Eh			;*
data_25e	equ	6034h			;*
data_26e	equ	603Ah			;*
data_27e	equ	603Eh			;*
data_28e	equ	6040h			;*
data_29e	equ	0A1E6h			;*
data_30e	equ	0A268h			;*
data_31e	equ	0A29Ah			;*
data_32e	equ	0A31Ch			;*
data_33e	equ	0A41Bh			;*
data_34e	equ	0A41Ch			;*
data_35e	equ	0A428h			;*
data_36e	equ	0A429h			;*
data_37e	equ	0C002h			;*
data_38e	equ	0ED20h			;*
data_39e	equ	0FF35h			;*
data_40e	equ	0FF4Ah			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_305MAPBO	proc	far

start:
		db	0F7h, 09h, 00h, 00h, 37h,0A3h
		db	 00h, 00h, 00h, 00h, 21h,0A3h
		db	 32h, 32h, 14h, 0Ah, 0Ah, 00h
		db	 00h, 00h, 28h, 28h, 14h, 14h
		db	 0Ah, 00h
		db	26 dup (0)
		db	0B0h,0A0h, 37h,0A1h,0BEh,0A1h
		db	0F5h,0A1h, 40h,0A2h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 28h,0A1h
loc_1:
		scasw				; Scan es:[di] for ax
		mov	ax,ds:data_29e
		xor	ss:data_30e[bp+si],sp
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0EAh,0A2h,0FEh,0A2h, 77h,0A2h

loc_ret_2:
		retn	86A2h
			                        ;* No entry point to code
		mov	ds:data_31e,al
		in	ax,0A2h			; port 0A2h ??I/O Non-standard
		add	[bx+si],al
		pop	ss
		mov	ds:data_32e,ax
		adc	ah,ss:data_1e[bp+di]
		db	8 dup (0)
		db	0ECh,0A0h, 73h,0A1h,0BEh,0A1h
		db	 13h,0A2h, 40h,0A2h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 28h,0A1h
		db	0AFh,0A1h,0E6h,0A1h, 31h,0A2h
		db	 68h,0A2h, 00h, 00h
data_6		db	0
		db	0
data_7		db	0
		db	 00h,0EAh,0A2h,0FEh,0A2h, 77h
		db	0A2h,0C2h,0A2h, 86h,0A2h, 9Ah
		db	0A2h,0E5h,0A2h, 00h, 00h, 17h
		db	0A3h, 1Ch,0A3h, 12h,0A3h,0AEh
		db	0A2h
		db	8 dup (0)
		db	 01h, 8Fh, 90h, 79h, 7Ah, 01h
		db	 7Fh, 80h, 81h, 82h, 01h, 87h
		db	 88h, 89h, 8Ah, 01h, 7Fh, 80h
		db	 99h, 9Ah, 01h, 8Fh, 90h, 91h
		db	 92h, 01h, 7Fh, 80h, 99h, 9Ah
		db	 01h, 87h, 88h, 89h, 8Ah, 01h
		db	 7Fh, 80h, 81h, 82h, 01h,0C7h
		db	 88h,0C9h, 8Ah, 01h,0C7h, 88h
		db	0CBh, 8Ah, 01h,0C7h, 88h,0CDh
		db	 8Ah, 01h,0C7h, 88h,0C9h, 8Ah
		db	 01h,0B7h,0B8h,0A1h,0A2h, 01h
		db	0A7h,0A8h,0A9h,0AAh, 01h,0AFh
		db	0B0h,0B1h,0B2h, 01h,0A7h,0A8h
		db	0C1h,0C2h, 01h,0B7h,0B8h,0B9h
		db	0BAh, 01h,0A7h,0A8h,0C1h,0C2h
		db	 01h,0AFh,0B0h,0B1h,0B2h, 01h
		db	0A7h,0A8h,0A9h,0AAh, 01h,0AFh
data_9		dw	0B1CFh
		db	0D1h, 01h,0AFh,0CFh,0B1h,0D2h
		db	 01h,0AFh,0CFh,0B1h,0D3h, 01h
		db	0AFh,0CFh,0B1h,0D1h, 01h,0D4h
		db	0D5h,0D6h,0D7h, 01h, 00h, 00h
		db	0DAh,0DBh, 01h, 00h, 00h, 00h
		db	 00h, 01h, 7Bh, 7Ch, 7Dh, 7Eh
		db	 01h, 83h, 84h, 85h, 86h, 01h
		db	 7Bh, 7Ch, 7Dh, 7Eh, 01h, 8Bh
		db	 8Ch, 8Dh, 8Eh, 01h, 93h, 94h
		db	 95h, 96h, 01h, 9Bh, 9Ch, 9Dh
		db	 9Eh, 01h, 93h, 94h, 95h, 96h
		db	 01h, 8Bh, 8Ch, 8Dh, 8Eh, 01h
		db	 8Bh, 8Ch, 8Dh, 8Eh, 01h, 8Bh
		db	 8Ch, 8Dh, 8Eh, 01h, 8Bh, 8Ch
		db	 8Dh, 8Eh, 01h, 8Bh, 8Ch, 8Dh
		db	 8Eh, 01h,0A3h,0A4h,0A5h,0A6h
		db	 01h,0ABh,0A4h,0ADh,0AEh, 01h
data_10		db	0A3h			; Data table (indexed access)
		db	0A4h,0A5h,0A6h, 01h,0B3h,0B4h
		db	0B5h
data_11		db	0B6h			; Data table (indexed access)
		db	 01h,0BBh,0BCh,0BDh,0BEh, 01h
		db	0C3h,0BCh,0C5h,0C6h, 01h,0BBh

locloop_3:
		mov	sp,0BEBDh
		add	ss:data_2e[bp+di],si
		mov	dh,1
		mov	bl,0B4h
		mov	ch,0B6h
		add	ss:data_2e[bp+di],si
		mov	dh,1
		mov	bl,0B4h
		mov	ch,0B6h
		add	ss:data_2e[bp+di],si
		mov	dh,1
		loopnz	locloop_3		; Loop if zf=0, cx>0

;*		loop	locloop_4		;*Loop if cx > 0

		db	0E2h,0E3h		;  Fixup - byte match
;*		add	sp,sp
		db	 01h,0E4h		;  Fixup - byte match
		in	ax,0E6h			; port 0E6h ??I/O Non-standard
		out	1,ax			; port 1, DMA-1 bas&cnt ch 0
		call	$-1514h
		jmp	short $+2		; delay for I/O
		or	ax,0F0Eh
		adc	[bx+si],al
		adc	ds:data_14e,cx
		add	[si],dl
		adc	ax,1716h
		add	[di],cl
		sbb	[bx+di],bl
		sbb	al,[bx+si]
		add	[bx+si],al
		add	[bp+si],ax
		add	[bx+si],al
		add	[si],al
		add	ax,0
		add	[bx],al
		or	[bx+si],al
		add	[bx+si],al
		or	cx,[si]
		add	[bp+di],bl
		sbb	al,1Dh
		push	ds
		add	[bx],bl
		and	[bx+di],ah
		and	al,[bx+si]
		and	sp,[si]
		and	ax,0
		db	27h, '()*', 0
		db	'+,-.', 0
		db	'/012', 0
		db	'3456', 0
		db	'789:', 0
		db	';<=>', 0
		db	27h, '()*', 0
		db	'+,-.', 0
		db	'/012', 0
		db	'3456', 0
		db	'789:', 0
		db	'?@AB', 0
		db	'CDEF', 0
		db	'GHIJ', 0
		db	'KLMN', 0
		db	'OPQR', 0
		db	'STUV', 0
		db	'WXQR', 0
		db	'YZQR', 0
		db	'[\]^', 0
		db	'_`ab', 0
		db	'cdef'
		db	 00h, 00h, 00h, 69h, 6Ah, 00h
		db	 6Bh, 6Ch, 6Dh, 6Eh, 00h, 4Bh
		db	 4Ch, 4Dh, 4Eh, 00h, 73h, 74h
		db	 75h, 76h, 01h, 03h, 06h, 0Ah
		db	 26h, 01h, 67h, 68h, 6Fh, 70h
		db	 01h, 71h, 72h,0A0h,0C0h, 00h
		db	 77h, 78h, 97h, 98h, 00h, 9Fh
		db	0ACh,0BFh,0C4h, 00h,0C8h,0CAh
		db	0CCh,0CEh, 00h, 9Fh,0ACh,0BFh
		db	0C4h, 02h, 77h, 78h, 97h, 98h
		db	 02h, 9Fh,0ACh,0BFh,0C4h, 02h
		db	0C8h,0CAh,0CCh,0CEh, 02h, 9Fh
		db	0ACh,0BFh,0C4h, 01h, 77h, 78h
		db	 97h, 98h, 01h, 9Fh,0ACh,0BFh
		db	0C4h, 01h,0C8h,0CAh,0CCh,0CEh
		db	 01h, 9Fh,0ACh,0BFh,0C4h, 00h
		db	0D0h,0D8h,0D9h,0DCh, 00h,0D0h
		db	0D8h,0D9h,0DCh, 00h,0D0h,0D8h
		db	0D9h,0DCh, 00h,0D0h,0D8h,0D9h
		db	0DCh, 00h,0D0h,0D8h,0D9h,0DCh
		db	 00h,0D0h,0D8h,0D9h,0DCh, 00h
		db	0D0h,0D8h,0D9h,0DCh, 01h,0DDh
		db	0DEh,0DFh,0ECh, 00h,0F1h,0F1h
		db	0F1h,0F1h, 00h,0F1h,0F1h,0F3h
		db	0F3h, 00h,0F4h,0F4h,0F6h,0F6h
		db	 00h,0F8h,0F8h,0FAh,0FAh, 00h
		db	0F2h,0F2h,0F1h,0F1h, 00h,0F2h
		db	0F2h,0F3h,0F3h, 00h,0FCh,0FDh
		db	0F6h,0F6h, 00h,0FEh,0FEh,0FAh
		db	0FAh, 02h,0F5h,0F7h,0F9h,0FBh
		db	 00h,0EDh,0EEh,0EFh,0F0h, 02h
		db	0EDh,0EEh,0EFh,0F0h, 2Bh,0A3h
		db	 2Bh,0A3h, 2Fh,0A3h, 33h,0A3h
		db	 33h,0A3h, 0Bh, 05h, 05h, 05h
		db	 05h, 04h, 05h, 04h, 05h, 00h
		db	 05h, 00h, 8Ah, 5Ch, 04h, 80h
		db	0E3h, 0Fh, 32h,0FFh, 03h,0DBh
		db	0FFh,0A7h, 45h,0A3h, 50h,0A3h
		db	 4Fh,0A3h,0F1h,0A5h, 12h,0A8h
		db	 1Ah,0A9h,0C3h,0F6h, 44h, 08h
		db	0FFh, 75h, 04h,0C6h, 44h, 08h
		db	 18h,0F6h, 44h, 05h, 20h, 74h
		db	 03h,0E9h,0D2h, 00h
loc_5:
		and	byte ptr [si+15h],0BFh
		call	sub_5
		jc	loc_6			; Jump if carry Set
		retn
loc_6:
		test	byte ptr [si+9],1
		jnz	loc_13			; Jump if not zero
		call	sub_7
		jc	loc_12			; Jump if carry Set
		add	byte ptr [si+6],80h
		jc	loc_7			; Jump if carry Set
		jmp	loc_17
loc_7:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		test	byte ptr [si+6],3
		jz	loc_8			; Jump if zero
		jmp	loc_17
loc_8:
		mov	al,10h
		cmp	al,[si+3]
		jb	loc_10			; Jump if below
		call	sub_1
		jnc	loc_9			; Jump if carry=0
		jmp	loc_17
loc_9:
		or	byte ptr [si+5],80h
		jmp	loc_17
loc_10:
		call	sub_3
		jnc	loc_11			; Jump if carry=0
		jmp	loc_17
loc_11:
		and	byte ptr [si+5],7Fh
		jmp	loc_17
loc_12:
		call	word ptr cs:data_9
		and	al,0C0h
		jnz	loc_7			; Jump if not zero
		mov	al,[si+6]
		not	al
		and	al,3
		jnz	loc_7			; Jump if not zero
		or	byte ptr [si+9],1
		mov	byte ptr [si+6],8
		jmp	short loc_17
loc_13:
		add	byte ptr [si+6],80h
		jnc	loc_17			; Jump if carry=0
		inc	byte ptr [si+6]
		mov	al,[si+6]
		and	al,0Fh
		cmp	al,0Bh
		je	loc_14			; Jump if equal
		cmp	al,0Ch
		jne	loc_17			; Jump if not equal
		and	byte ptr [si+9],0FEh
		mov	byte ptr [si+6],3
		jmp	short loc_17
loc_14:
		mov	al,[si+3]
		mov	ds:data_35e,al
		inc	al
		mov	ds:data_33e,al
		mov	al,[si+2]
		inc	al
		mov	ds:data_36e,al
		mov	ds:data_34e,al
		mov	bx,0A41Bh
		test	byte ptr [si+5],80h
		jnz	loc_15			; Jump if not zero
		mov	bx,0A428h
loc_15:
		call	word ptr cs:data_26e
		jmp	short loc_17
		db	 00h, 00h,0B1h, 00h, 14h, 00h
		db	 28h, 00h
		db	7 dup (0)
		db	0B1h, 00h, 14h, 04h, 28h, 00h
		db	 00h, 00h, 00h, 00h, 00h
loc_16:
		mov	al,[si+5]
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:data_25e
loc_17:
		mov	al,[si+6]
		mov	[si+16h],al
		mov	al,[si+5]
		and	al,80h
		mov	ah,[si+15h]
		and	ah,7Fh
		or	al,ah
		mov	[si+15h],al
		retn

_305MAPBO	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	loc_18			; Jump if carry=0
		retn
loc_18:
		call	sub_2
		jnc	loc_19			; Jump if carry=0
		retn
loc_19:
		mov	bx,[si]
		inc	bx
		mov	ax,ds:data_37e
		sub	ax,bx
		jnz	loc_20			; Jump if not zero
		xchg	bx,ax
loc_20:
		mov	[si],bx
		mov	[si+10h],bx
		inc	byte ptr [si+3]
		inc	byte ptr [si+13h]
		clc				; Clear carry flag
		retn
sub_1		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		mov	ax,[si+2]
		call	word ptr cs:data_21e
		inc	di
		inc	di
		mov	cx,4

locloop_21:
		mov	al,[di]
		call	word ptr cs:data_24e
		stc				; Set carry flag
		jz	loc_22			; Jump if zero
		retn
loc_22:
		xchg	si,di
		add	si,24h
		call	word ptr cs:data_22e
		xchg	si,di
		loop	locloop_21		; Loop if cx > 0

		xchg	si,di
		sub	si,24h
		call	word ptr cs:data_23e
		mov	al,[si]
		sub	si,24h
		call	word ptr cs:data_23e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_23e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_23e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_23e
		or	al,[si]
		xchg	si,di
		add	al,al
		retn
sub_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3		proc	near
		cmp	byte ptr [si+3],2
		jae	loc_23			; Jump if above or =
		retn
loc_23:
		call	sub_4
		jnc	loc_24			; Jump if carry=0
		retn
loc_24:
		mov	ax,[si]
		dec	ax
		cmp	ax,0FFFFh
		jne	loc_25			; Jump if not equal
		mov	ax,ds:data_37e
		dec	ax
loc_25:
		mov	[si],ax
		mov	[si+10h],ax
		dec	byte ptr [si+3]
		dec	byte ptr [si+13h]
		clc				; Clear carry flag
		retn
sub_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_4		proc	near
		mov	ax,[si+2]
		call	word ptr cs:data_21e
		dec	di
		mov	cx,4

locloop_26:
		mov	al,[di]
		call	word ptr cs:data_24e
		stc				; Set carry flag
		jz	loc_27			; Jump if zero
		retn
loc_27:
		xchg	si,di
		add	si,24h
		call	word ptr cs:data_22e
		xchg	si,di
		loop	locloop_26		; Loop if cx > 0

		dec	di
		xchg	si,di
		sub	si,24h
		call	word ptr cs:data_23e
		mov	al,[si]
		sub	si,24h
		call	word ptr cs:data_23e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_23e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_23e
		or	al,[si]
		sub	si,24h
		call	word ptr cs:data_23e
		or	al,[si]
		xchg	si,di
		add	al,al
		retn
sub_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_5		proc	near
		test	byte ptr [si+3],0FFh
		stc				; Set carry flag
		jnz	loc_28			; Jump if not zero
		retn
loc_28:
		cmp	byte ptr [si+3],23h	; '#'
		stc				; Set carry flag
		jnz	loc_29			; Jump if not zero
		retn
loc_29:
		call	sub_6
		jnc	loc_30			; Jump if carry=0
		retn
loc_30:
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		inc	byte ptr [si+12h]
		and	byte ptr [si+12h],3Fh	; '?'
		clc				; Clear carry flag
		retn
sub_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_6		proc	near
		mov	ax,[si+2]
		call	word ptr cs:data_21e
		xchg	si,di
		add	si,offset data_6
		call	word ptr cs:data_22e
		xchg	si,di
		mov	cx,2

locloop_31:
		mov	al,[di]
		call	word ptr cs:data_24e
		stc				; Set carry flag
		jz	loc_32			; Jump if zero
		retn
loc_32:
		inc	di
		loop	locloop_31		; Loop if cx > 0

		dec	di
		mov	al,[di]
		or	al,[di-1]
		or	al,[di-1]
		add	al,al
		retn
sub_6		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_7		proc	near
		mov	al,ds:data_39e
		sub	al,[si+2]
		jnc	loc_33			; Jump if carry=0
		neg	al
loc_33:
		cmp	al,4
		mov	al,0FFh
		jc	loc_34			; Jump if carry Set
		retn
loc_34:
		cmp	byte ptr [si+3],11h
		jae	loc_36			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	loc_35			; Jump if zero
		retn
loc_35:
		clc				; Clear carry flag
		retn
loc_36:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	loc_37			; Jump if not zero
		retn
loc_37:
		clc				; Clear carry flag
		retn
sub_7		endp

			                        ;* No entry point to code
		test	byte ptr [si+8],0FFh
		jnz	loc_38			; Jump if not zero
		mov	byte ptr [si+8],10h
loc_38:
		test	byte ptr [si+5],20h	; ' '
		jnz	loc_39			; Jump if not zero
		jmp	loc_59
loc_39:
		mov	al,[si+5]
		and	al,1Fh
		cmp	al,4
		jne	loc_40			; Jump if not equal
		jmp	word ptr cs:data_25e
loc_40:
		cmp	al,5
		jne	loc_41			; Jump if not equal
		jmp	word ptr cs:data_25e
loc_41:
		cmp	al,8
		jne	loc_42			; Jump if not equal
		jmp	word ptr cs:data_25e
loc_42:
		cmp	al,1
		jne	loc_43			; Jump if not equal
		cmp	data_7,6
		jne	loc_43			; Jump if not equal
		jmp	word ptr cs:data_25e
loc_43:
		and	byte ptr [si+5],0DFh
		test	byte ptr [si+9],2
		jz	loc_44			; Jump if zero
		jmp	loc_59
loc_44:
		call	word ptr cs:data_27e
		jnc	loc_45			; Jump if carry=0
		jmp	loc_59
loc_45:
		push	di
		mov	ax,[si+2]
		call	word ptr cs:data_21e
		mov	bx,di
		pop	di
		test	byte ptr [si+5],80h
		jnz	loc_52			; Jump if not zero
		mov	al,[si+3]
		or	al,al			; Zero ?
		jns	loc_46			; Jump if not sign
		jmp	loc_59
loc_46:
		cmp	al,20h			; ' '
		jb	loc_47			; Jump if below
		jmp	loc_59
loc_47:
		inc	bx
		inc	bx
		xchg	bx,si
		sub	si,24h
		call	word ptr cs:data_23e
		mov	cx,3

locloop_48:
		lodsb				; String [si] to al
		call	word ptr cs:data_24e
		xchg	bx,si
		jz	loc_49			; Jump if zero
		jmp	loc_59
loc_49:
		xchg	bx,si
		lodsb				; String [si] to al
		call	word ptr cs:data_24e
		xchg	bx,si
		jz	loc_50			; Jump if zero
		jmp	loc_59
loc_50:
		xchg	bx,si
		add	si,22h
		call	word ptr cs:data_22e
		loop	locloop_48		; Loop if cx > 0

		sub	si,48h
		call	word ptr cs:data_23e
		xchg	si,bx
		push	dx
		or	dl,80h
		xchg	[bx],dl
		pop	bx
		xor	bh,bh			; Zero register
		mov	ds:data_38e[bx],dl
		mov	dl,bl
		mov	bx,[si]
		inc	bx
		inc	bx
		mov	ax,ds:data_37e
		dec	ax
		sub	ax,bx
		jnc	loc_51			; Jump if carry=0
		not	ax
		xchg	bx,ax
loc_51:
		mov	[di],bx
		mov	al,[si+3]
		add	al,2
		mov	[di+3],al
		jmp	short loc_57
loc_52:
		mov	al,[si+3]
		or	al,al			; Zero ?
		jns	loc_53			; Jump if not sign
		jmp	loc_59
loc_53:
		cmp	al,4
		jae	loc_54			; Jump if above or =
		jmp	loc_59
loc_54:
		dec	bx
		dec	bx
		xchg	bx,si
		sub	si,25h
		call	word ptr cs:data_23e
		mov	cx,3

locloop_55:
		lodsb				; String [si] to al
		call	word ptr cs:data_24e
		xchg	bx,si
		jnz	loc_59			; Jump if not zero
		xchg	bx,si
		lodsb				; String [si] to al
		call	word ptr cs:data_24e
		xchg	bx,si
		jnz	loc_59			; Jump if not zero
		xchg	bx,si
		add	si,22h
		call	word ptr cs:data_22e
		loop	locloop_55		; Loop if cx > 0

		sub	si,47h
		call	word ptr cs:data_23e
		xchg	si,bx
		push	dx
		or	dl,80h
		xchg	[bx],dl
		pop	bx
		xor	bh,bh			; Zero register
		mov	ds:data_38e[bx],dl
		mov	dl,bl
		mov	bx,[si]
		sub	bx,2
		jnc	loc_56			; Jump if carry=0
		add	bx,ds:data_37e
loc_56:
		mov	[di],bx
		mov	al,[si+3]
		sub	al,2
		mov	[di+3],al
loc_57:
		mov	al,[si+2]
		mov	[di+2],al
		mov	al,[si+4]
		or	al,60h			; '`'
		mov	[di+4],al
		mov	al,[si+5]
		and	al,80h
		mov	[di+5],al
		mov	byte ptr [di+6],4
		mov	al,[si+7]
		mov	[di+7],al
		mov	byte ptr [di+8],0
		mov	byte ptr [di+9],2
		mov	byte ptr [di+0Ah],0
		cmp	ds:data_40e,dl
		jb	loc_58			; Jump if below
		retn
loc_58:
		or	byte ptr [si+9],1
loc_59:
		call	word ptr cs:data_28e
		mov	al,[si+9]
		and	byte ptr [si+9],0FEh
		test	al,1
		jz	loc_60			; Jump if zero
		retn
loc_60:
		test	byte ptr [si+9],2
		jnz	loc_67			; Jump if not zero
		mov	al,[si+6]
		inc	al
		and	al,0F3h
		mov	[si+6],al
		call	word ptr cs:data_20e
		jc	loc_61			; Jump if carry Set
		retn
loc_61:
		mov	al,[si+6]
		sub	al,10h
		mov	ah,al
		mov	[si+6],al
		and	al,0F0h
		jz	loc_62			; Jump if zero
		retn
loc_62:
		or	ah,40h			; '@'
		mov	[si+6],ah
		mov	al,ds:data_39e
		cmp	al,[si+2]
		je	loc_63			; Jump if equal
		inc	al
		and	al,3Fh			; '?'
		cmp	al,[si+2]
		je	loc_63			; Jump if equal
		test	byte ptr [si+5],80h
		jnz	loc_65			; Jump if not zero
		jmp	short loc_64
loc_63:
		mov	al,11h
		cmp	al,[si+3]
		jae	loc_65			; Jump if above or =
loc_64:
		and	byte ptr [si+5],7Fh
		call	word ptr cs:data_19e
		jc	loc_65			; Jump if carry Set
		retn
loc_65:
		or	byte ptr [si+5],80h
		call	word ptr cs:data_15e
		jc	loc_66			; Jump if carry Set
		retn
loc_66:
		and	byte ptr [si+5],7Fh
		jmp	word ptr cs:data_19e
loc_67:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		jz	loc_68			; Jump if zero
		retn
loc_68:
		and	byte ptr [si+9],0FDh
		and	byte ptr [si+4],9Fh
		retn
			                        ;* No entry point to code
		test	byte ptr [si+8],0FFh
		jnz	loc_69			; Jump if not zero
		mov	byte ptr [si+8],8
loc_69:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_70			; Jump if zero
		jmp	word ptr cs:data_25e
loc_70:
		call	word ptr cs:data_28e
		test	byte ptr [si+9],4
		jz	loc_71			; Jump if zero
		jmp	loc_89
loc_71:
		call	word ptr cs:data_20e
		jc	loc_72			; Jump if carry Set
		retn
loc_72:
		test	byte ptr [si+9],2
		jz	loc_82			; Jump if zero
		mov	al,[si+6]
		and	al,7
		jnz	loc_73			; Jump if not zero
		and	byte ptr [si+9],0FEh
loc_73:
		cmp	al,4
		jne	loc_74			; Jump if not equal
		or	byte ptr [si+9],1
loc_74:
		test	byte ptr [si+9],1
		jnz	loc_75			; Jump if not zero
		inc	byte ptr [si+6]
		jmp	short loc_76
loc_75:
		dec	byte ptr [si+6]
loc_76:
		mov	al,[si+6]
		and	al,7
		jnz	loc_77			; Jump if not zero
		and	byte ptr [si+5],7Fh
		jmp	short loc_79
loc_77:
		cmp	al,4
		je	loc_78			; Jump if equal
		retn
loc_78:
		or	byte ptr [si+5],80h
loc_79:
		call	sub_7
		jnc	loc_80			; Jump if carry=0
		mov	byte ptr [si+9],4
		mov	byte ptr [si+0Ah],0
		retn
loc_80:
		call	word ptr cs:data_9
		and	al,80h
		jnz	loc_81			; Jump if not zero
		retn
loc_81:
		mov	byte ptr [si+9],0
		mov	byte ptr [si+0Ah],0
		retn
loc_82:
		call	sub_7
		jnc	loc_83			; Jump if carry=0
		mov	byte ptr [si+9],4
		mov	byte ptr [si+0Ah],0
		retn
loc_83:
		inc	byte ptr [si+0Ah]
		and	al,7
		jnz	loc_84			; Jump if not zero
		mov	byte ptr [si+9],2
loc_84:
		add	byte ptr [si+6],80h
		jc	loc_85			; Jump if carry Set
		retn
loc_85:
		test	byte ptr [si+5],80h
		jnz	loc_87			; Jump if not zero
		call	word ptr cs:data_19e
		jc	loc_86			; Jump if carry Set
		retn
loc_86:
		mov	byte ptr [si+9],2
		retn
loc_87:
		call	word ptr cs:data_15e
		jc	loc_88			; Jump if carry Set
		retn
loc_88:
		mov	byte ptr [si+9],2
		retn
loc_89:
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],5
		jb	loc_85			; Jump if below
		mov	byte ptr [si+6],5
		test	byte ptr [si+5],80h
		jnz	loc_91			; Jump if not zero
		call	word ptr cs:data_19e
		call	word ptr cs:data_19e
		jc	loc_90			; Jump if carry Set
		retn
loc_90:
		mov	byte ptr [si+9],2
		mov	byte ptr [si+6],0
		retn
loc_91:
		call	word ptr cs:data_15e
		call	word ptr cs:data_15e
		jc	loc_92			; Jump if carry Set
		retn
loc_92:
		mov	byte ptr [si+9],2
		mov	byte ptr [si+6],4
		retn
			                        ;* No entry point to code
		test	byte ptr [si+8],0FFh
		jnz	loc_93			; Jump if not zero
		mov	byte ptr [si+8],8
loc_93:
		test	byte ptr [si+5],20h	; ' '
		jz	loc_94			; Jump if zero
		jmp	word ptr cs:data_25e
loc_94:
		call	word ptr cs:data_28e
		test	byte ptr [si+9],1
		jnz	loc_101			; Jump if not zero
		test	byte ptr [si+9],2
		jnz	loc_105			; Jump if not zero
		mov	al,0Fh
		cmp	al,[si+3]
		jae	loc_95			; Jump if above or =
		mov	al,12h
		cmp	al,[si+3]
		jb	loc_95			; Jump if below
		or	byte ptr [si+9],1
		mov	byte ptr [si+6],4
		jmp	short loc_96
loc_95:
		mov	al,[si+6]
		inc	al
		and	al,3
		and	byte ptr [si+6],0F0h
		or	[si+6],al
loc_96:
		call	word ptr cs:data_17e
		add	byte ptr [si+6],80h
		jc	loc_97			; Jump if carry Set
		retn
loc_97:
		mov	al,10h
		cmp	al,[si+3]
		jb	loc_99			; Jump if below
		call	word ptr cs:data_15e
		jc	loc_98			; Jump if carry Set
		retn
loc_98:
		jmp	word ptr cs:data_19e
loc_99:
		call	word ptr cs:data_19e
		jc	loc_100			; Jump if carry Set
		retn
loc_100:
		jmp	word ptr cs:data_15e
loc_101:
		mov	al,[si+6]
		and	al,7
		cmp	al,5
		jae	loc_102			; Jump if above or =
		inc	byte ptr [si+6]
		retn
loc_102:
		call	word ptr cs:data_20e
		call	word ptr cs:data_20e
		jc	loc_103			; Jump if carry Set
		retn
loc_103:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		jz	loc_104			; Jump if zero
		retn
loc_104:
		mov	byte ptr [si+9],2
		retn
loc_105:
		mov	al,10h
		cmp	al,[si+3]
		jb	loc_108			; Jump if below
		call	word ptr cs:data_17e
		call	word ptr cs:data_16e
		jc	loc_106			; Jump if carry Set
		retn
loc_106:
		call	word ptr cs:data_17e
		jc	loc_107			; Jump if carry Set
		retn
loc_107:
		and	byte ptr [si+9],0FDh
		retn
loc_108:
		call	word ptr cs:data_17e
		call	word ptr cs:data_18e
		jc	loc_109			; Jump if carry Set
		retn
loc_109:
		call	word ptr cs:data_17e
		jc	loc_110			; Jump if carry Set
		retn
loc_110:
		and	byte ptr [si+9],0FDh
		retn

seg_a		ends



		end	start
