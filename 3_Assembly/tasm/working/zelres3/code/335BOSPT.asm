
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR3_35	                                 лл
;лл					                                 лл
;лл      Created:   16-Feb-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	0C4C3h			;*
data_7e		equ	1CD3h			;*
data_8e		equ	43C3h			;*
data_9e		equ	53C3h			;*
data_10e	equ	73C3h			;*
data_11e	equ	84C3h			;*
data_12e	equ	0A1D3h			;*
data_13e	equ	0C4C3h			;*
data_14e	equ	0C5C3h			;*
data_15e	equ	0DDC3h			;*
data_16e	equ	0E004h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_35		proc	far

start:
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		sbb	[bx+si],al
		add	[di],ah
;*		aad	0			; undocumented inst
		db	0D5h, 00h		;  Fixup - byte match
		add	ds:data_12e[bx+di],ax
		shl	word ptr ss:data_7e[bp+di],cl	; Shift w/zeros fill
;*		aam	0D2h			; undocumented inst
		db	0D4h,0D2h		;  Fixup - byte match
;*		aam	12h			; undocumented inst
		db	0D4h, 12h		;  Fixup - byte match
;*		aad	2Ah			; '*' undocumented inst
		db	0D5h, 2Ah		;  Fixup - byte match
;*		aad	6			; undocumented inst
		db	0D5h, 06h		;  Fixup - byte match
		db	0FFh,0FFh,0FFh, 0Ah, 00h, 00h
		db	 81h,0D3h, 63h, 01h, 1Dh, 53h
		db	 48h,0C8h,0C9h, 49h,0CBh, 83h
		db	0C3h, 05h, 04h, 91h,0C3h, 09h
		db	 04h,0E0h, 82h, 06h, 04h, 07h
		db	 04h,0C7h,0C9h,0C8h,0C4h,0C7h
		db	0C9h, 49h,0CBh, 82h,0C3h, 05h
		db	 04h, 91h,0C3h, 0Ah, 04h, 82h
		db	 06h, 04h,0C4h, 01h, 20h, 05h
		db	 04h,0C7h,0C4h,0C7h, 58h,0CAh
		db	0C8h,0E0h, 07h, 04h, 91h,0C3h
		db	 0Ah, 04h,0E0h, 43h,0E0h, 73h
		db	 88h,0C3h, 46h, 68h,0C8h, 09h
		db	 04h, 91h,0C3h,0C4h, 87h,0C3h
		db	 43h, 89h,0C2h, 40h, 41h, 40h
		db	 81h,0C3h,0CDh,0C7h, 48h,0C8h
		db	 0Bh, 04h, 40h, 51h, 50h, 41h
		db	 87h,0C3h,0C4h, 40h, 51h,0C1h
		db	 81h,0C3h, 43h,0C2h,0C1h, 41h
		db	 40h,0C2h, 40h, 88h,0C3h,0D8h
		db	0CDh,0C9h,0C8h, 73h,0DDh, 06h
		db	 04h, 91h,0C3h,0C4h, 87h,0C3h
		db	 43h, 89h, 63h, 86h,0D8h,0CDh
		db	0C8h, 05h, 04h, 85h,0C3h,0C4h
		db	 85h,0C3h, 07h, 04h, 83h,0C3h
		db	0C4h, 8Fh,0C3h, 43h,0E0h, 63h
		db	 87h,0D8h,0CDh, 05h, 04h, 85h
		db	0C3h,0C4h, 85h,0C3h,0C4h,0DDh
		db	 05h, 04h, 83h,0C3h,0C4h, 8Fh
		db	0C3h, 53h, 63h, 88h,0D8h,0C4h

locloop_1:
		add	[di],bx
		push	bx
		test	ax,bx
		les	ax,dword ptr data_5[di]	; Load seg:offset ptr
		add	al,94h
		retn
			                        ;* No entry point to code
		push	bx
		db	 63h, 89h,0D6h,0E1h,0DDh, 53h
		db	 85h,0C3h,0C4h, 85h,0C3h, 07h
		db	 04h, 94h,0C3h, 53h,0DDh, 53h
		db	 89h,0D6h,0E1h,0DDh, 53h, 85h
		db	0C3h,0C4h, 85h,0C3h, 63h,0E0h
		db	 53h, 94h,0C3h, 53h,0DDh, 53h
		db	 89h,0D6h,0E1h,0DDh, 53h, 85h
		db	0C3h,0C4h, 85h,0C3h, 43h, 9Ah
		db	0C3h, 53h, 63h, 89h,0D6h,0E1h
		db	0DDh, 53h, 85h,0C3h,0C4h, 85h
		db	0C3h,0C4h,0DDh, 9Ah,0C3h, 53h
		db	 63h, 85h,0C3h, 83h,0D6h,0E1h
		db	0DDh, 53h, 85h,0C3h,0C4h, 85h
		db	0C3h, 43h, 9Ah,0C3h, 53h, 53h
		db	0DDh, 85h,0C3h, 83h,0C3h, 01h
		db	 1Dh, 53h, 85h,0C3h,0C4h, 85h
		db	0C3h, 43h, 92h,0C3h,0C4h, 86h
		db	0C3h, 53h, 82h,0C3h,0C4h, 89h
		db	0C3h, 73h, 85h,0C3h,0C4h, 85h

locloop_2:
		retn
			                        ;* No entry point to code
		inc	bx
;*		mov	bh,al
		db	 88h,0C7h		;  Fixup - byte match
		int	49h			; ??INT Non-standard interrupt
		retf				; Return far
		db	 91h, 82h,0C3h,0C4h, 8Ch,0C3h
		db	0C4h,0DDh, 85h,0C3h,0C4h, 85h
		db	0C3h, 43h, 88h,0D8h,0CCh,0C9h
		db	0CAh, 81h,0CBh, 90h, 82h,0C3h
		db	0C4h, 8Ch,0C3h, 43h, 85h,0C3h
		db	0C4h, 85h,0C3h, 43h, 89h,0D8h
		db	0CCh,0CDh,0CAh, 91h, 82h,0C3h
		db	0C4h, 8Ch,0C3h, 43h, 85h,0C3h
		db	0C4h, 85h,0C3h, 43h, 8Ah,0D8h
		db	0CCh, 92h, 82h,0C3h,0C4h, 8Ch
		db	0C3h, 43h, 85h,0C3h,0C4h, 85h
		db	0C3h, 43h, 9Eh, 82h,0C3h,0C4h
		db	 8Ch,0C3h, 43h, 85h,0C3h,0C4h
		db	 85h,0C3h,0C4h,0DDh, 9Eh, 82h
		db	0C3h,0C4h, 8Ch,0C3h,0DDh,0C4h
		db	 85h,0C3h, 43h,0E0h, 05h, 04h
		db	 9Eh, 89h,0C3h, 43h, 84h,0C3h
		db	 43h, 85h,0C3h, 08h, 04h, 9Eh
		db	 89h,0C3h, 43h, 84h,0C3h, 43h
		db	 85h,0C3h, 73h, 01h
		db	20h
loc_3:
		inc	bx
		test	ax,bx
		test	al,bl
		inc	bx
		test	ax,bx
		push	bx
		mov	ds:data_15e[bx+di],cl
		les	ax,dword ptr ds:data_8e[si]	; Load seg:offset ptr
		test	ax,bx
		inc	bx
		test	ax,bx
		les	ax,dword ptr ds:data_11e[di]	; Load seg:offset ptr
		retn
		db	 43h, 85h,0C3h, 53h, 88h, 89h
		db	0C3h, 43h, 84h,0C3h, 43h, 85h
		db	0C3h, 43h, 85h,0C3h,0C4h, 85h
		db	0C3h, 84h,0C3h, 43h, 91h, 89h
		db	0C3h, 43h, 84h,0C3h, 43h, 85h
		db	0C3h, 43h, 85h,0C3h,0DDh, 85h
		db	0C3h, 84h,0C3h,0DDh,0C4h, 40h
		db	 61h, 60h,0C2h,0C1h,0C2h,0C1h
		db	 83h, 89h,0C3h, 43h, 84h,0C3h
		db	 43h, 85h,0C3h, 43h, 85h,0C3h
		db	0C4h, 8Ah,0C3h, 43h, 91h,0C8h
		db	0C7h, 43h, 85h,0C3h, 43h, 84h
		db	0C3h, 43h, 85h,0C3h, 43h, 85h
		db	0C3h,0C4h,0C2h, 60h,0C2h, 40h
		db	0C2h, 81h,0C3h, 43h, 85h,0C3h
		db	 43h,0E0h, 84h,0C3h,0C7h, 48h
		db	0C9h,0C8h, 43h, 85h,0C3h,0C4h
		db	0DDh, 84h,0C3h, 87h,0C3h,0DDh
		db	0C4h, 85h,0C3h,0C4h, 8Ah,0C3h
		db	 43h, 85h,0C3h, 53h, 84h,0C3h
		db	0C7h,0CDh,0C9h, 48h, 43h,0DAh
		db	 84h,0C3h, 43h, 84h,0C3h, 87h
		db	0C3h, 43h, 85h,0C3h, 53h,0E0h
		db	 87h,0C3h,0C4h,0DDh, 43h,0E0h
		db	 05h, 04h, 84h,0D8h,0C8h,0C9h
		db	0CDh,0C8h, 53h,0DBh, 84h,0C3h
		db	 43h, 84h,0C3h, 43h, 85h,0C3h
		db	 43h, 85h,0C3h, 63h, 87h,0C3h
		db	 0Ah, 04h, 85h,0D8h,0CDh,0C9h
		db	0C8h, 53h,0DCh, 84h,0C3h, 43h
		db	 84h,0C3h, 43h, 85h,0C3h, 43h
		db	 85h,0C3h, 63h, 87h,0C3h, 07h
		db	 04h,0DDh, 43h, 86h,0D8h,0CDh
		db	0C3h, 53h,0D7h, 84h,0C3h, 43h
		db	 84h,0C3h, 43h, 85h,0C3h, 43h
		db	 85h,0C3h,0C4h,0DDh, 43h, 87h
		db	0C3h, 73h,0E0h, 73h, 87h,0D8h
		db	0C3h, 53h,0C6h, 84h,0C3h, 43h
		db	 84h,0C3h, 43h, 85h,0C3h, 43h
		db	 85h,0C3h, 63h, 87h,0C3h, 43h
		db	 85h,0C3h, 53h, 88h,0C3h, 53h
		db	 85h,0C3h, 43h, 84h,0C3h, 43h
		db	 85h,0C3h, 43h, 85h,0C3h, 63h
		db	 87h,0C3h, 43h, 85h,0C3h, 43h
		db	0DDh, 88h,0C3h, 53h, 85h,0C3h
		db	 43h, 84h,0C3h, 43h, 85h,0C3h
		db	 43h, 85h,0C3h, 63h, 87h,0C3h
		db	 43h, 85h,0C3h, 53h, 88h,0C3h
		db	 53h, 85h,0C3h, 43h, 84h,0C3h
		db	 43h, 85h,0C3h, 43h, 85h,0C3h
		db	 63h, 87h,0C3h, 43h, 85h,0C3h
		db	 53h, 88h,0C3h, 53h, 85h,0C3h
		db	 43h, 84h,0C3h, 43h, 85h,0C3h
		db	 43h, 85h,0C3h, 43h, 89h,0C3h
		db	 43h, 85h,0C3h, 53h, 88h,0C3h
		db	 43h,0E0h, 85h,0C3h,0DDh,0C4h
		db	 84h,0C3h, 43h, 85h,0C3h,0DDh
		db	0C4h, 85h,0C3h, 43h, 89h,0C3h
		db	0C4h,0DDh, 85h,0C3h, 53h, 88h
		db	0C3h,0C4h, 01h, 20h, 85h,0C3h
		db	0DDh,0C4h, 84h,0C3h, 43h, 85h
		db	0C3h, 43h, 85h,0D6h,0E1h, 53h
		db	 87h,0C3h, 43h, 85h,0C3h, 53h
		db	 88h,0C3h, 53h, 85h,0C3h, 43h
		db	 84h,0C3h, 43h, 85h,0C3h, 43h
		db	 85h,0D6h,0E1h, 43h,0DDh, 87h
		db	0C3h, 43h, 85h,0E0h, 53h, 88h
		db	 89h,0C3h, 43h, 84h,0C3h, 43h
		db	 85h,0C3h, 43h, 85h,0D6h,0E1h
		db	 53h, 87h,0C3h, 43h, 91h, 50h
		db	 86h,0C3h, 43h, 84h,0C3h, 43h
		db	 85h,0C3h, 43h, 85h,0D6h,0E1h
		db	 53h, 87h,0C3h, 43h, 41h, 06h
		db	 01h,0C2h, 40h, 41h,0C1h,0C2h
		db	0C1h, 89h,0C3h, 43h, 84h,0C3h
		db	 87h,0C3h,0C4h,0DDh, 85h,0D6h
		db	0E1h, 53h, 87h,0C3h, 43h, 91h
		db	 63h, 85h,0E0h, 43h, 84h,0C3h
		db	 87h,0C3h, 43h, 85h,0D6h,0E1h
		db	 53h, 87h,0C3h, 43h, 85h,0E0h
		db	0C4h,0C7h,0C9h, 49h,0CBh,0C8h
		db	 43h,0E0h,0C4h, 53h,0E0h, 8Ch
		db	0C3h, 43h, 85h,0C3h, 43h, 85h
		db	0D6h,0E1h, 53h, 87h,0C3h,0C4h
		db	0C7h, 87h,0D8h,0CDh, 58h,0C8h
		db	0C7h,0C8h, 43h,0DDh,0C4h, 01h
		db	 20h,0C1h, 51h,0C1h,0C2h, 40h
		db	 51h, 81h,0C3h, 43h, 85h,0C3h
		db	 43h, 85h,0D6h,0E1h, 53h, 87h
		db	0C3h,0C4h,0C9h,0CAh, 87h,0D8h
		db	0CDh, 58h,0C8h, 53h,0C4h, 02h
		db	 20h, 8Ch,0C3h,0DDh,0C4h, 8Dh
		db	0C3h, 63h, 87h,0C3h,0C4h, 48h
		db	0CAh,0CBh, 86h,0D8h,0CDh, 68h
		db	0CAh,0C8h,0C4h, 02h, 20h, 8Ch
		db	0C3h, 43h,0C2h,0C1h, 51h, 50h
		db	0C2h,0C1h,0C2h,0C1h, 81h,0C3h
		db	 43h,0DDh,0C4h, 87h,0C3h,0C4h
		db	0C7h,0C9h,0C8h,0C4h, 87h,0D8h
		db	0CDh, 48h,0CAh,0CBh,0C8h, 90h
		db	0C3h, 43h, 8Dh,0C3h, 63h, 9Bh
		db	 90h,0C3h, 43h, 85h,0C3h, 43h
		db	 85h,0C3h, 53h,0E0h, 41h, 50h
		db	 41h, 40h, 41h, 90h, 90h,0C3h
		db	 43h, 85h,0C3h, 43h, 85h,0C3h
		db	 43h, 01h, 20h, 9Bh,0C9h,0CAh
		db	0CBh, 81h,0C8h, 73h, 01h, 20h
		db	0C4h,0E0h, 73h, 85h,0C3h,0C4h
		db	0DDh, 85h,0C3h,0C4h
loc_4:
		add	[bx+si],sp
loc_5:
		or	[si],ax
		mov	bx,cx
		int	3			; Debug breakpoint
		js	$+6Ah			; Jump if sign=1
		jnc	$+3			; Jump if carry=0
;*		and	ah,al
		db	 20h,0C4h		;  Fixup - byte match
		loopnz	$+7			; Loop if zf=0, cx>0

		add	al,85h
		retn
			                        ;* No entry point to code
		inc	bx
		test	ax,bx
		pop	es
		add	al,0DDh
		db	 63h, 8Ah,0D9h,0CCh, 05h, 09h
		db	0CAh, 48h,0C8h, 73h,0DDh, 73h
		db	0DDh, 53h, 85h,0C3h, 43h, 85h
		db	0C3h, 05h, 04h,0DDh, 53h,0DDh
		db	 43h, 89h,0D9h,0CCh,0C9h,0C8h
		db	0C7h, 48h,0CAh,0C8h,0C9h,0C8h
		db	 63h,0DDh, 07h, 04h,0DDh, 53h
		db	 85h,0C3h, 43h, 85h,0C3h, 0Ch
		db	 04h, 88h,0D9h,0CCh,0C9h,0C8h
		db	0C7h,0C9h,0C8h, 48h,0C4h, 0Fh
		db	 04h, 88h,0C3h, 43h, 8Fh,0C3h
		db	0C4h,0DDh, 73h, 84h,0C3h,0C4h
		db	0C7h, 58h, 63h,0DDh, 0Eh, 04h
		db	 88h,0C3h, 43h, 41h, 40h, 51h
		db	 40h,0C2h,0C1h, 41h,0C1h
		db	 81h,0C3h, 06h, 04h, 84h, 63h
		db	0C9h,0C8h, 63h, 53h,0E0h, 53h
		db	0DDh, 63h,0E0h, 53h, 88h,0C3h
		db	0C4h,0DDh, 8Fh,0C3h, 43h,0DDh
		db	 63h, 84h, 63h,0C8h, 63h,0E0h
		db	 84h,0C3h, 53h, 90h,0C3h, 43h
		db	 8Fh,0C3h, 06h, 04h, 84h, 43h
		db	0DDh, 73h, 82h, 84h,0C3h, 53h
		db	 90h,0C3h, 43h, 85h,0C3h, 43h
		db	 87h,0C3h, 73h,0DDh,0C4h
loc_8:
		test	al,[bx]
		add	al,82h
		test	al,bl
		push	bx
		nop
		retn
			                        ;* No entry point to code
		inc	bx
		test	ax,bx
;*		ffree	st(4)			; Set tag to empty
		db	0DDh,0C4h		;  Fixup - byte match
;*		xchg	ax,bx
		db	 87h,0C3h		;  Fixup - byte match
		push	es
		add	al,84h
		push	es
		add	al,0DDh
;*		add	byte ptr ds:data_13e[si],0DDh
		db	 82h, 84h,0C3h,0C4h,0DDh	;  Fixup - byte match
		les	dx,dword ptr ds:data_8e[bx+si]	; Load seg:offset ptr
		test	ax,bx
		inc	bx
;*		xchg	ax,bx
		db	 87h,0C3h		;  Fixup - byte match
;*		fld	qword ptr ds:data_16e	; Push onto stack
		db	0DDh, 06h, 04h,0E0h	;  Fixup - byte match
		or	[si],ax
;*		add	byte ptr ds:data_9e[si],90h
		db	 82h, 84h,0C3h, 53h, 90h	;  Fixup - byte match
		retn
			                        ;* No entry point to code
		inc	bx
		test	ax,bx
		inc	bx
;*		xchg	ax,bx
		db	 87h,0C3h		;  Fixup - byte match
		adc	al,[si]
;*		add	byte ptr ds:data_9e[si],90h
		db	 82h, 84h,0C3h, 53h, 90h	;  Fixup - byte match
		retn
			                        ;* No entry point to code
		inc	bx
		test	ax,bx
		inc	bx
;*		xchg	ax,bx
		db	 87h,0C3h		;  Fixup - byte match
		inc	bx
;*		db	0DDh, 08h, 04h,0E0h, 53h,0E0h
		db	0DDh, 08h, 04h,0E0h, 53h,0E0h	;  Fixup - byte match
		db	 43h, 82h, 98h,0C3h,0C4h,0DDh
		db	 85h,0C3h, 43h, 84h,0C3h, 0Bh
		db	 04h, 8Ch, 98h,0C3h,0C4h,0DDh
		db	 85h,0C3h, 43h, 84h,0C3h,0C4h
		db	0DDh, 09h, 04h, 8Ch, 98h,0C3h
		db	43h
loc_9:
		test	ax,bx
		inc	bx
		test	al,bl
		add	ax,0DD04h
		jnc	loc_8			; Jump if carry=0
		nop
		retn
		db	0C4h,0DDh, 8Dh,0C3h,0DDh,0C4h
		db	 84h,0C3h, 0Ah, 04h,0DDh, 86h
		db	0C3h,0E0h, 43h, 82h, 90h,0C3h
		db	 43h, 8Dh,0C3h, 43h, 84h,0C3h
		db	 43h,0E0h, 53h,0E0h, 43h,0E0h
		db	 43h, 86h,0C3h, 53h, 82h, 90h
		db	0C3h, 63h, 8Bh,0C3h, 43h, 8Fh
		db	0C3h,0C4h, 86h,0C3h, 43h,0DDh
		db	 82h, 90h
data_3		dw	63C3h, 0C38Bh, 0C4DDh	; Data table (indexed access)
		dw	61C1h
		db	0C1h, 41h, 60h, 41h, 81h,0C3h
		db	0C4h, 86h,0C3h, 53h, 82h, 90h
		db	0C3h, 05h, 04h, 89h,0C3h, 43h
		db	 8Fh,0C3h,0DDh, 86h,0C3h, 53h
		db	 82h, 90h,0C3h, 05h, 04h, 89h
		db	0C3h, 0Bh, 04h, 85h,0C3h,0C4h
		db	 86h,0C3h

locloop_10:
		push	bx
;*		or	byte ptr ds:data_14e[bx+si],0C4h
		db	 82h, 88h,0C3h,0C5h,0C4h	;  Fixup - byte match
		test	ax,bx
		jnc	loc_9			; Jump if carry=0
		retn
		db	 73h,0DDh, 05h

locloop_12:
		add	al,8Dh
		retn
			                        ;* No entry point to code
		push	bx
;*		or	byte ptr ds:data_8e[bx+si],85h
		db	 82h, 88h,0C3h, 43h, 85h	;  Fixup - byte match
		retn
		db	0C4h,0C5h, 53h, 8Ah,0C3h, 53h
		db	0DDh, 06h, 04h,0DDh, 8Dh,0C3h
		db	 53h, 82h, 88h,0C3h, 01h, 1Dh
		db	 88h,0C3h, 43h, 8Ah,0C3h, 0Bh
		db	 04h, 8Dh,0C3h, 43h,0DDh, 82h
		db	 88h,0C3h, 43h, 88h,0C3h, 43h
		db	 8Ah,0C3h, 0Bh, 04h, 85h,0C3h
		db	0C4h, 86h,0C3h,0C4h, 84h, 88h
		db	0C3h, 43h, 88h,0C3h, 8Ch,0C3h
		db	 08h, 04h,0DDh, 43h, 85h,0C3h
		db	0C4h, 86h,0C3h,0DDh, 84h, 88h
		db	0C3h, 43h, 88h,0C3h, 8Ch,0C3h
		db	0DDh,0C4h,0E0h, 43h,0E0h, 63h
		db	0E0h,0C4h, 85h,0C3h,0C4h, 86h
		db	0C3h, 53h, 82h, 88h,0C3h,0C4h
		db	0DDh, 88h,0C3h, 84h,0C3h, 87h
		db	0C3h,0DDh,0C4h, 8Fh,0C3h,0C4h
		db	0CBh, 85h,0C3h, 53h, 82h, 88h
		db	0C3h, 43h, 88h,0C3h, 84h,0C3h
		db	 87h,0C3h, 43h, 40h,0C2h, 60h
		db	 41h, 40h,0C2h, 40h, 81h,0C3h
		db	0DDh, 49h,0CBh, 83h,0C3h,0C4h
		db	0C7h,0CBh, 82h,0CBh, 87h,0C3h
		db	0C4h,0DDh, 88h,0C3h,0C4h, 8Bh
		db	0C3h, 43h, 8Fh,0C3h,0C4h,0C9h
		db	 49h,0CBh, 82h,0C3h, 53h,0C9h
		db	0CAh,0CAh,0CBh, 86h,0C3h, 43h
		db	 88h,0C3h,0C4h, 8Bh,0C3h, 43h
		db	 86h,0C3h,0C4h, 01h, 20h, 85h
		db	0C3h, 43h,0C9h,0CAh,0CBh, 82h
		db	0C3h,0C4h,0DDh,0C8h,0C7h,0C9h
data_4		dw	0CAC9h, 85CBh		; Data table (indexed access)
		db	0C5h, 43h, 88h,0C3h, 53h, 89h
		db	0C3h, 43h, 86h,0C3h, 53h, 85h
		db	0C3h,0C4h,0C7h, 58h, 82h,0C3h
		db	0C7h,0C9h, 43h,0C7h,0C7h,0C9h
		db	 91h,0C3h, 53h, 89h,0C3h, 43h
		db	 86h,0C3h, 53h, 85h,0C3h,0C4h
		db	0C7h, 58h,0C8h, 43h, 48h,0C8h
		db	 43h, 40h,0C2h, 50h, 41h, 40h
		db	0C2h,0C1h,0C2h, 86h,0C3h, 43h
		db	 8Ah,0C3h,0C4h,0DDh, 86h,0C3h
		db	 53h, 85h,0C3h,0C7h, 48h,0CAh
		db	0C8h,0C4h,0C5h,0C4h, 68h,0C8h
		db	 93h,0C3h, 43h, 8Ah,0C3h, 43h
		db	 86h,0C3h,0DDh, 43h, 85h, 68h
		db	 47h,0C7h,0CAh, 68h,0CAh,0CBh
		db	 86h,0C3h,0C4h, 8Bh,0C3h, 8Ch
		db	0C3h, 43h, 86h,0C3h, 53h, 85h
		db	0D8h, 09h, 09h,0CAh, 4Ah, 86h
		db	0C3h,0C4h, 8Bh,0C3h, 8Ch,0C3h
		db	 43h, 86h,0C3h, 43h,0DDh, 86h
		db	0D8h, 58h,0C8h,0C7h, 58h,0CAh
		db	0CBh, 82h, 86h,0C3h, 53h, 44h
		db	 53h,0C5h, 88h,0C3h, 87h,0C3h
		db	 43h, 86h,0C3h, 53h, 87h,0D8h
		db	 68h,0C8h,0C4h,0C7h,0C9h,0CAh
		db	0CBh, 81h, 86h,0C3h, 08h, 04h
		db	 88h,0C3h, 87h,0C3h, 43h, 86h
		db	0C3h, 53h, 88h,0D8h, 58h,0C8h
		db	0C7h, 58h,0CAh,0CBh, 86h,0C3h
		db	 43h,0DDh, 05h, 04h, 90h,0C3h
		db	 43h, 86h,0C3h, 53h, 89h,0D8h
		db	 05h, 09h,0CAh, 82h, 86h,0C3h
		db	 63h,0C5h, 43h,0C5h,0C4h, 90h
		db	0C3h, 43h, 86h,0C3h, 53h, 8Ah
		db	0C3h, 68h,0CAh,0CBh, 82h, 86h
		db	0C3h,0C4h, 8Fh,0C3h, 05h, 04h
		db	 82h, 53h, 86h,0C3h, 53h, 8Ah
		db	0C3h,0C7h, 68h,0CAh,0CBh, 81h
		db	 86h,0C5h,0C4h, 8Fh,0C3h, 05h
		db	 04h, 82h, 53h, 86h,0C3h, 53h
		db	 8Ah,0C3h,0C7h, 78h,0CAh,0CBh
		db	 97h,0C3h, 0Ah, 04h, 86h,0C3h
data_5		dw	8A53h, 0C4C3h		; Data table (indexed access)
		db	0C8h,0C7h, 58h,0CAh,0CBh, 8Eh
		db	0C3h,0C5h,0C4h, 86h,0C3h, 06h
		db	 04h,0DDh, 0Bh, 04h,0DDh, 8Ah
		db	0C3h,0DDh, 68h,0CAh,0CBh, 81h
		db	 8Eh,0C3h, 43h, 86h,0C3h, 63h
		db	0DDh, 06h, 04h,0DDh, 53h,0DDh
		db	 63h, 8Ah,0C3h,0C4h, 58h,0CAh
		db	0CBh, 82h, 82h,0C3h, 43h, 89h
		db	0C3h, 43h, 86h,0C3h, 14h, 04h
		db	 8Ah,0C3h,0C4h, 58h,0CAh,0CBh
		db	 82h, 82h,0DDh, 43h, 89h,0DDh
		db	 43h, 86h,0C3h,0C4h,0C5h, 07h
		db	 04h,0E0h, 63h,0E0h, 73h, 8Ah
		db	0C3h,0C4h,0C7h,0C9h,0CAh,0CBh
		db	 83h, 8Eh,0C3h,0C4h,0DDh, 43h
		db	 8Ah,0C3h,0C4h, 98h,0C3h,0C4h
		db	0DDh,0C9h,0CAh,0CBh, 83h, 82h
		db	0C3h, 43h, 89h,0C3h, 63h, 50h
		db	 41h, 60h, 81h,0C3h,0C4h,0C1h
		db	 51h, 50h, 41h
loc_13:
		inc	ax
		jno	$+42h			; Jump if not overflw
		inc	cx
		inc	ax
;*		add	bl,0C8h
		db	 82h,0C3h,0C8h		;  Fixup - byte match
		db	0C9h,0CAh,0CBh, 84h, 82h,0DDh
		db	 43h, 89h,0C3h, 63h, 8Ah,0C3h
		db	0C4h
loc_14:
		cbw				; Convrt byte to word
		retn
		db	0C7h,0C9h,0CAh,0CBh, 84h, 8Eh
		db	0C3h, 05h, 04h, 8Eh,0C3h,0C4h
		db	0E0h, 43h, 85h,0C3h, 43h, 86h
		db	0D9h,0CCh, 48h,0CAh, 85h, 82h
		db	0C3h, 43h, 89h,0C3h,0C4h,0DDh
		db	 63h, 8Eh,0C3h, 63h, 85h,0C3h
		db	 43h, 85h,0D9h,0CCh, 58h, 86h
		db	 82h,0DDh, 43h, 89h,0C3h, 43h
		db	0DDh, 53h, 8Eh,0C3h, 63h, 85h
		db	0C3h,0DDh,0C4h, 84h,0D9h,0CCh
		db	0C9h,0C7h,0C8h,0C9h, 86h, 8Eh
		db	0C3h, 43h,0DDh, 53h, 8Eh,0C3h
		db	 43h, 87h,0C3h, 43h, 84h,0C3h
		db	0C4h,0C8h
		db	53h

locloop_15:
		xchg	ss:data_8e[bp+si],al
;*		mov	bx,ax
		db	 89h,0C3h		;  Fixup - byte match
		add	ax,8E04h
		retn
			                        ;* No entry point to code
		inc	bx
;*		xchg	ax,bx
		db	 87h,0C3h		;  Fixup - byte match
		inc	bx
		test	al,bl
		jnc	loc_13			; Jump if carry=0
;*		sbb	ch,43h			; 'C'
		db	 82h,0DDh, 43h		;  Fixup - byte match
;*		mov	bx,ax
		db	 89h,0C3h		;  Fixup - byte match
		push	bx
;*		fld	qword ptr [bp+di-72h]	; Push onto stack
		db	0DDh, 43h, 8Eh		;  Fixup - byte match
		retn
			                        ;* No entry point to code
;*		ffree	st(4)			; Set tag to empty
		db	0DDh,0C4h		;  Fixup - byte match
;*		ffree	st(4)			; Set tag to empty
		db	0DDh,0C4h		;  Fixup - byte match
		test	ax,bx
		inc	bx
		test	al,bl
		jnc	loc_14			; Jump if carry=0
		mov	es,bx
;*		jnc	loc_16			;*Jump if carry=0
		db	 73h,0DDh		;  Fixup - byte match
		mov	es,bx
		db	 63h, 85h,0C3h, 43h, 84h,0C3h
		db	 73h, 86h, 82h,0C3h, 43h, 89h
		db	0C3h, 05h, 04h, 8Eh,0C3h, 63h
		db	 85h,0C3h,0C5h,0C4h, 84h,0C3h
		db	 73h, 86h, 82h,0DDh, 43h, 89h
		db	0C3h, 05h, 04h, 8Eh,0C3h, 63h
		db	 8Dh,0C3h, 43h,0DDh,0C4h, 86h
		db	 8Eh,0C3h, 53h,0DDh, 43h, 8Eh
		db	0C3h, 63h, 8Dh,0C3h, 63h, 86h
		db	 82h,0C3h, 43h,0E0h, 43h, 86h
		db	0C3h,0C4h,0DDh, 63h, 8Ch,0C3h
		db	 43h,0DDh, 53h, 8Dh,0C3h, 53h
		db	0DDh, 86h, 82h,0C3h, 73h, 86h
		db	0C3h, 05h, 04h, 8Ch,0C3h, 05h
		db	 04h, 8Dh,0C3h, 63h, 86h, 84h
		db	0C3h, 53h, 86h,0C3h,0C4h,0DDh
		db	 63h, 8Ah,0C3h, 07h, 04h, 8Dh
		db	0C3h, 63h, 86h, 84h,0C3h, 43h
		db	0DDh, 86h, 02h, 20h, 63h, 8Ah
		db	0C3h, 07h, 04h, 8Dh,0C3h, 63h
		db	 86h, 84h,0C3h, 53h, 95h,0C3h
		db	 09h, 04h, 8Dh,0C3h, 63h, 86h
		db	 84h,0C3h, 53h,0C2h, 40h,0C2h
		db	 40h, 51h, 50h,0C2h, 40h,0C2h
		db	 60h, 81h,0C3h, 09h, 04h, 8Dh
		db	0C3h, 63h, 86h, 84h,0C3h,0DDh
		db	 43h, 95h,0C3h,0C4h, 8Eh,0C3h
		db	 43h, 85h,0C3h, 63h, 86h, 84h
		db	0C3h, 53h, 86h, 05h, 20h, 0Ah
		db	 04h, 8Eh,0C3h,0C4h,0DDh, 85h
		db	0C3h, 63h, 86h, 84h,0C3h,0C4h
		db	0DDh,0C4h, 86h,0C3h, 0Fh, 04h
		db	 8Eh,0C3h, 43h, 85h,0C3h, 63h
		db	 86h, 84h,0C3h,0C4h,0DDh,0C4h
		db	 86h,0C3h, 0Ah, 04h,0DDh, 63h
		db	 85h,0C5h, 53h, 85h,0C3h, 43h
		db	 85h,0C3h, 63h, 86h, 84h,0C3h
		db	 53h, 86h,0C3h, 0Fh, 04h, 85h
		db	0C5h, 53h, 85h,0C3h, 43h, 85h
		db	0C3h, 53h,0DDh, 86h, 84h,0C3h
		db	 53h, 86h,0C3h, 53h,0DDh, 73h
		db	 01h, 20h, 43h,0E0h, 43h, 85h
		db	0C3h, 53h, 85h,0C3h, 43h, 85h
		db	0C3h, 63h, 86h, 84h,0C3h,0C4h
		db	0DDh,0C4h, 86h,0C3h, 63h, 91h
		db	0C3h, 53h, 85h,0C3h,0DDh,0C4h
		db	 85h,0C3h,0DDh, 53h, 86h, 84h
		db	0C3h, 53h, 86h,0C3h, 63h, 40h
		db	 61h, 70h, 71h, 81h,0C3h, 53h
		db	 85h,0C3h,0DDh,0C4h, 85h,0C3h
		db	 63h, 86h, 84h,0C3h, 53h, 86h
		db	0C3h, 63h, 91h,0C3h, 53h, 85h
		db	0C3h, 43h, 85h,0C3h, 53h,0DDh
		db	 86h, 84h,0C3h, 53h, 86h,0C3h
		db	0C4h,0DDh, 43h, 85h,0C3h, 05h
		db	 04h, 85h,0C3h,0C4h, 87h,0C3h
		db	 43h, 85h,0C3h, 63h, 86h, 84h
		db	0C3h, 53h, 86h,0C3h, 63h, 85h
		db	0C3h, 05h, 04h, 85h,0C3h,0DDh
		db	 87h,0C3h, 43h, 85h,0C3h, 63h
		db	 86h, 84h,0C3h, 53h, 86h,0C3h
		db	 43h, 87h,0C3h, 53h,0DDh, 43h
		db	 85h,0C3h, 53h, 85h,0C3h,0C4h
		db	0DDh, 85h,0C3h, 63h, 86h, 84h
		db	0C3h, 53h, 86h,0C3h, 43h, 87h
		db	0C3h, 43h, 01h, 1Dh, 43h, 85h
		db	0C3h, 53h, 85h,0C3h, 43h, 85h
		db	0C3h,0C4h,0DDh, 43h, 86h, 84h
		db	0C3h, 53h, 86h,0C3h, 63h, 85h
		db	0C3h, 05h, 04h, 85h,0C3h, 53h
		db	 85h,0C3h, 43h, 85h,0C3h, 53h
		db	0DDh, 86h, 84h,0C3h, 53h, 86h
		db	0C3h, 63h, 85h,0C3h, 63h,0DDh
		db	0C4h, 85h,0C3h, 53h, 85h,0C3h
		db	 43h, 85h,0C3h, 63h, 86h, 82h
		db	0C3h, 08h, 04h, 82h, 73h, 85h
		db	0C3h, 06h, 04h,0E0h, 53h,0DDh
		db	 16h, 04h, 84h, 82h,0C3h, 07h
		db	 04h,0DDh, 82h, 73h, 85h,0C3h
		db	 22h, 04h, 84h, 82h,0C3h, 0Fh
		db	 04h, 85h,0C3h, 0Eh, 04h,0E0h
		db	 63h,0E0h, 73h,0E0h, 07h, 04h
		db	 84h, 82h,0C3h, 43h,0DDh
		db	43h
data_6		dw	0C386h, 8C63h		; Data table (indexed access)
		db	0C3h,0DDh, 53h, 94h,0C3h, 53h
		db	 84h, 82h,0C3h, 73h, 86h,0C3h
		db	 63h, 8Ch,0C3h, 53h,0DDh,0C1h
		db	0C2h, 40h, 51h, 60h, 41h,0C1h
		db	 86h,0C3h, 53h, 84h, 82h,0C3h
		db	 73h, 86h,0C3h, 63h, 8Dh,0C3h
		db	 53h, 94h,0C3h, 53h, 84h, 82h
		db	0C3h, 73h, 86h,0C3h, 63h, 8Dh
		db	0C3h, 53h, 85h,0C3h,0C4h,0C1h
		db	0C2h,0C1h,0C2h, 40h, 41h, 40h
		db	 83h,0C3h, 53h, 84h, 82h,0C3h
		db	0DDh, 63h, 86h,0C3h,0C4h,0DDh
		db	 43h, 8Eh,0C3h, 43h, 85h,0C3h
		db	0C4h,0E0h,0C4h, 8Bh,0C3h, 53h
		db	 84h, 82h,0C3h, 73h, 86h,0C3h
		db	 63h, 8Eh,0C3h, 43h, 85h,0C3h
		db	 05h, 04h, 01h, 20h, 43h, 84h
		db	0C3h,0DDh, 86h, 82h,0C3h, 73h
		db	 86h,0C3h, 63h, 8Fh,0C3h,0C4h
		db	 85h,0C3h, 09h, 04h, 84h,0C3h
		db	0C4h, 86h, 82h,0C3h, 73h, 86h
		db	0C3h, 63h, 8Fh,0C3h,0C4h, 85h
		db	0C3h, 09h, 04h, 84h,0C3h, 43h
		db	0DDh, 84h, 82h,0C3h, 53h,0DDh
		db	0C4h, 86h,0C3h, 63h, 8Fh,0C3h
		db	0C4h, 85h,0C3h, 73h,0DDh, 88h
		db	0C3h, 53h, 84h, 82h,0C3h, 73h
		db	 86h,0C3h, 63h, 8Fh,0C3h,0C4h
		db	 85h,0C3h, 43h,0E0h, 53h, 88h
		db	0C3h, 53h, 84h, 82h,0C3h, 73h
		db	 86h,0C3h,0DDh, 53h, 8Fh,0C3h
		db	0C4h, 85h,0C3h, 43h, 8Ch,0C3h
		db	 53h, 84h, 82h,0C3h, 73h, 86h
		db	0C3h, 63h, 8Fh,0C3h,0C4h, 85h
		db	0C3h, 43h, 8Ch,0C3h, 53h, 84h
		db	 43h,0DDh, 73h, 86h,0C3h, 63h
		db	 8Fh,0C3h,0C4h, 85h,0C3h,0C4h
		db	 8Dh,0C3h, 05h, 04h,0E0h, 73h
		db	0DDh, 43h, 86h,0C3h, 63h, 8Fh
		db	0C3h,0C4h, 85h,0C3h,0C4h, 8Dh
		db	0C3h, 06h, 04h, 07h, 04h, 87h
		db	0C3h, 53h, 8Fh,0C3h,0C4h, 85h
		db	0C3h,0C4h, 8Dh,0C3h,0C4h,0DDh
		db	 73h, 07h, 04h, 88h,0C3h, 43h
		db	 85h,0C3h,0DDh, 43h, 86h,0C3h
		db	0C4h, 8Ah,0C4h, 86h,0C3h,0E0h
		db	 08h, 04h, 04h, 20h, 53h, 89h
		db	0C3h,0C4h, 85h,0C3h, 53h, 86h
		db	0C3h,0C4h, 89h, 63h, 84h,0C3h
		db	 09h, 04h, 85h,0C3h, 43h, 89h
		db	0C3h,0C4h, 85h,0C3h, 53h, 86h
		db	0C3h,0C4h, 8Ah,0C4h, 86h,0C3h
		db	0C4h,0E0h, 07h, 04h, 85h,0C3h
		db	0DDh,0C4h, 89h,0C3h,0C4h, 85h
		db	0C3h, 0Ah, 04h, 94h,0C3h, 43h
		db	0DDh, 63h, 85h,0C3h, 43h, 89h
		db	0C3h,0C4h, 85h,0C3h, 0Ah, 04h
		db	 94h,0C3h, 06h, 04h, 85h,0C3h
		db	 43h, 89h,0C3h,0C4h, 85h,0C3h
		db	 63h,0DDh, 05h, 04h, 94h,0C3h
		db	 06h, 04h, 85h,0C3h, 43h, 89h
		db	0C3h,0C4h, 85h,0C3h, 06h, 04h
		db	0DDh, 53h, 94h,0D6h,0E1h, 05h
		db	 04h, 85h,0C3h, 43h, 89h,0C7h
		db	0C9h, 85h,0C3h, 53h, 95h,0C3h
		db	0C5h, 85h,0D6h,0E1h, 05h, 04h
		db	 85h,0C3h, 43h, 88h,0D9h,0CCh
		db	0C9h, 85h,0C3h,0C4h,0DDh,0C4h
		db	 41h, 50h,0C2h, 50h, 41h,0C1h
		db	 89h,0C3h,0C4h, 85h,0D6h,0E1h
		db	 05h, 04h, 85h,0C3h, 43h, 87h
		db	0D9h,0CCh,0C9h,0CAh,0CBh, 84h
		db	0C3h, 53h, 95h,0C3h,0C4h, 85h
		db	0D6h,0E1h, 05h, 04h, 85h,0C3h
		db	 43h, 86h,0D9h,0CCh, 48h,0CAh
		db	0CBh, 84h,0C3h, 53h, 86h,0C3h
		db	0C4h, 8Dh,0C3h, 43h, 84h,0D6h
		db	0E1h, 43h,0DDh, 53h, 85h,0C3h
		db	 43h, 85h,0D9h,0CCh, 48h,0C8h
		db	0CBh, 85h,0C3h, 53h, 86h,0C3h
		db	0C4h, 8Dh,0C3h,0C4h,0DDh, 84h
		db	0D6h,0E1h,0DDh, 73h, 85h,0C3h
		db	 43h, 85h, 48h, 49h,0C7h,0C9h
		db	0CAh, 84h,0C3h, 43h,0DDh, 86h
		db	0C3h,0C4h, 8Dh,0C3h, 43h, 84h
		db	0D6h,0E1h, 05h, 04h, 85h,0C3h
		db	0DDh,0C4h, 85h,0C3h,0C8h,0C7h
		db	0C9h, 49h, 85h,0C3h, 53h, 86h
		db	0C3h,0C4h, 85h,0C3h,0C4h, 86h
		db	0C3h, 43h, 84h,0C3h, 06h, 04h
		db	 8Dh,0C3h,0C8h,0C7h,0C9h, 49h
		db	 85h,0C3h, 53h, 86h,0C3h,0DDh
		db	 85h,0C3h,0DDh, 86h,0C3h, 43h
		db	 84h,0C3h, 06h, 04h,0C1h, 41h
		db	 50h,0C2h,0C1h,0C2h, 40h,0C2h
		db	 81h,0C3h, 43h,0CAh,0CBh, 86h
		db	0C3h, 53h, 86h,0C3h,0C4h, 85h
		db	0C3h,0C4h, 86h,0C5h,0C4h, 85h
		db	0C3h,0C4h,0C5h, 73h, 8Dh,0C3h
		db	 43h,0CBh, 87h,0C3h,0DDh, 43h
		db	 86h,0C3h,0C4h, 85h,0C3h, 43h
		db	 91h,0C3h, 43h, 85h,0C3h, 43h
		db	 85h,0C3h, 43h, 88h,0C3h,0DDh
		db	 43h, 86h,0C3h,0C4h, 85h,0C3h
		db	 43h,0C1h, 41h, 50h,0C2h, 40h
		db	 51h, 40h,0C2h,0C1h, 81h,0C3h
		db	0DDh,0C4h, 85h,0C3h, 43h, 85h
		db	0C3h, 43h, 85h,0C3h,0C4h,0DDh
		db	 63h, 86h,0C3h,0C4h, 85h,0C3h
		db	0DDh,0C4h, 91h,0C3h, 43h, 85h
		db	0C3h, 43h, 85h,0C3h,0C4h,0DDh
		db	 85h,0C3h, 05h, 04h, 86h,0C3h
		db	0C4h, 85h,0C3h, 43h, 87h,0C3h
		db	 89h,0C3h, 43h, 85h,0C3h, 43h
		db	 85h,0C3h, 43h, 85h,0C3h, 05h
		db	 04h, 86h,0C3h,0C4h, 85h,0C3h
		db	 43h, 87h,0C3h,0C5h, 43h, 86h
		db	0C3h, 43h, 85h,0C3h, 43h, 85h
		db	0C3h, 43h, 85h,0C3h, 05h, 04h
		db	 86h,0C3h,0C4h, 85h,0C3h, 43h
		db	 87h,0C3h, 53h, 86h,0C3h, 43h
		db	 85h,0C3h,0DDh,0C4h, 85h,0C3h
		db	 43h, 85h,0C3h, 05h, 04h, 86h
		db	0C3h,0DDh, 85h,0C3h, 43h, 87h
		db	0C3h, 53h, 86h,0C3h, 01h, 1Dh
		db	 85h,0C3h, 87h,0C3h, 43h, 85h
		db	0C3h, 63h,0DDh,0C4h, 86h,0C3h
		db	0C4h, 85h,0C3h,0C4h,0DDh, 87h
		db	0C3h, 53h, 86h,0C3h, 43h, 85h
		db	0C3h, 87h,0C3h, 43h, 85h,0C3h
		db	 06h, 04h,0DDh, 05h, 04h,0DDh
		db	 43h, 82h, 53h, 87h,0C3h, 53h
		db	 86h,0C3h,0DDh,0C4h, 85h,0C3h
		db	 43h, 85h,0C3h, 43h, 85h,0C3h
		db	 0Ah, 04h,0DDh, 73h, 82h
loc_17:
		push	bx
;*		xchg	ax,bx
		db	 87h,0C3h		;  Fixup - byte match
		inc	bx
;*		fld	qword ptr ss:data_8e[bp]	; Push onto stack
		db	0DDh, 86h,0C3h, 43h	;  Fixup - byte match
		test	ax,bx
		inc	bx
		test	ax,bx
		inc	bx
		test	ax,bx
		adc	ax,8704h
		retn
			                        ;* No entry point to code
		push	bx
		xchg	al,bl
		inc	bx
		test	ax,bx
		inc	bx
		test	ax,bx
		inc	bx
		test	ax,bx
		db	0C4h,0DDh, 10h, 04h,0DDh, 43h
		db	 87h,0C3h, 53h, 86h,0C3h, 43h
		db	 85h,0C3h, 43h, 85h,0DDh, 43h
		db	 85h,0C3h, 73h,0DDh, 63h,0DDh
		db	 0Ah, 04h, 87h,0C3h,0DDh, 43h
		db	 86h,0C3h, 43h, 85h,0C3h, 43h
		db	 85h,0C3h, 43h, 85h,0C3h, 53h
		db	 89h,0C3h, 53h,0DDh, 53h, 89h
		db	0C3h, 06h, 04h, 44h, 53h, 85h
		db	0C3h, 43h, 85h,0C3h, 73h,0DDh
		db	 73h, 89h,0C3h, 53h,0DDh, 53h
		db	 89h,0C3h,0DDh, 73h, 44h, 63h
		db	 85h,0C3h, 43h, 85h,0C3h, 53h
		db	0DDh, 06h, 04h, 89h,0DDh, 06h
		db	 04h, 89h,0C3h, 73h, 44h, 73h
		db	 85h,0C3h, 43h, 85h,0C3h, 0Ah
		db	 04h, 89h,0C3h, 06h, 04h, 84h
		db	0C3h, 07h, 04h, 89h,0C2h, 50h
		db	 81h,0C3h,0DDh,0C4h, 8Bh

locloop_18:
		retn
		db	 63h,0DDh, 89h,0C3h, 06h, 04h
		db	 84h,0C3h, 07h, 04h, 40h, 51h
		db	 50h,0C2h, 85h,0C3h, 43h,0C1h
		db	 61h,0C1h,0C2h,0C1h, 41h, 81h
		db	0C3h, 63h,0DDh, 89h,0C3h, 43h
		db	0E0h, 43h,0E0h,0C4h, 84h,0C3h
		db	0C4h,0DDh, 05h, 04h, 89h, 63h
		db	0E0h, 53h, 8Bh,0C3h, 53h, 8Bh
		db	0C3h,0C4h, 8Ah,0C3h, 07h, 04h
		db	 84h,0C3h, 43h,0E0h,0C4h, 0Dh
		db	 04h, 85h,0C3h, 53h, 8Bh,0C3h
		db	0C4h, 8Ah,0C3h

locloop_19:
		pop	es
		add	al,84h
		retn
		db	 63h, 0Dh, 04h, 85h,0C3h, 73h
		db	 89h,0C3h,0C4h, 8Ah,0C3h, 07h
		db	 04h, 84h,0C3h, 63h,0E0h, 63h
		db	0E0h, 53h,0DDh, 63h, 85h,0C3h
		db	 73h, 89h,0C3h,0DDh, 8Ah,0C3h
		db	 53h,0DDh, 43h,0DDh,0C4h, 84h
		db	0C3h, 63h, 89h,0C3h,0C4h,0DDh
		db	 43h, 85h,0C3h,0C4h,0DDh, 53h
		db	 89h,0C3h,0C4h, 8Ah,0C3h, 08h
		db	 04h, 88h,0C1h,0C2h, 50h, 84h
		db	0C3h, 43h,0DDh,0C4h, 85h,0C3h
		db	 53h,0DDh,0C4h, 89h,0C3h,0C4h
		db	 8Ah,0C3h, 08h, 04h,0C2h, 50h
		db	 41h, 40h, 89h,0C3h, 63h, 85h
		db	0C3h, 53h, 8Bh,0C3h,0C4h, 8Ah
		db	0C3h,0E0h, 63h,0DDh, 53h, 88h
		db	 8Bh,0C3h, 43h, 85h,0C3h, 53h
		db	 8Bh,0C3h,0C4h, 8Ch,0C3h, 05h
		db	 04h, 87h,0C3h,0E0h, 8Bh,0C3h
		db	 87h,0C3h, 53h, 8Bh,0C3h, 8Dh
		db	0C3h,0DDh, 73h, 87h,0C3h,0C4h
		db	 8Bh,0C3h, 87h,0C3h, 53h, 8Bh
		db	0C3h, 8Dh,0C3h, 05h, 04h, 87h
		db	 43h, 8Bh,0C3h, 43h, 85h,0C3h
		db	 53h, 99h,0C3h, 05h, 04h, 84h
		db	0C3h,0E0h, 53h, 8Bh,0C3h, 43h
		db	 85h,0C3h, 53h, 99h,0C3h, 05h
		db	 04h, 84h,0C3h, 63h, 8Bh,0C3h
		db	 43h, 85h,0C3h, 53h,0A4h,0C3h
		db	 63h, 8Bh,0C3h, 43h, 85h,0C3h
		db	 53h, 92h,0C3h,0DDh, 61h, 40h
		db	0C2h, 40h, 51h, 40h, 82h,0C3h
		db	 63h, 8Bh,0C3h, 43h, 85h,0C3h
		db	 53h,0C2h, 40h, 51h, 40h, 61h
		db	 40h, 84h,0C3h,0DDh, 90h,0C3h
		db	 63h, 85h,0C3h, 85h,0C3h,0C4h
		db	0DDh, 85h,0C3h, 53h, 92h,0C3h
		db	0C4h, 95h, 85h,0C3h, 85h,0C3h
		db	 43h, 85h,0C3h,0C4h,0DDh,0C4h
		db	 82h,0C4h, 84h,0DDh, 43h, 88h
		db	0C3h,0C4h, 95h, 85h,0C3h, 85h
		db	0C3h, 43h, 85h,0C3h, 53h, 81h
		db	 63h, 82h,0DDh, 43h, 88h,0C3h
		db	0C4h, 95h, 8Bh,0C3h, 43h, 85h
		db	0C3h, 53h, 82h,0C4h, 83h,0C3h
		db	 53h, 88h,0C3h,0C4h,0DDh, 43h
		db	 88h,0C3h, 43h, 85h,0C3h,0C4h
		db	 8Bh,0C3h, 53h, 8Eh,0C3h, 53h
		db	 88h,0C3h,0C4h,0DDh, 43h, 88h
		db	0C3h, 43h, 85h,0C3h,0C4h, 8Bh
		db	0C3h, 53h, 8Eh,0C3h, 53h, 88h
		db	0C3h, 63h, 88h,0C3h, 43h, 85h
		db	0C3h,0C4h, 8Bh,0C3h, 73h, 8Ch
		db	0C3h, 53h, 88h,0C3h, 63h, 88h
		db	0C3h, 43h, 85h,0C3h,0C4h, 8Bh
		db	0C3h,0C4h,0DDh, 53h, 8Ch,0C3h
		db	 43h,0DDh, 86h,0C3h, 05h, 04h
		db	 88h,0C3h,0C4h,0DDh, 85h,0C3h
		db	0DDh, 8Bh,0C3h, 05h, 04h, 8Bh
		db	0C3h, 43h,0DDh, 86h,0C3h, 73h
		db	0DDh, 88h,0C3h, 43h, 85h,0C3h
		db	0DDh, 8Bh,0C3h, 05h, 04h, 8Bh
		db	0C3h, 53h, 86h,0C3h, 43h,0DDh
		db	 43h,0C5h, 88h,0C3h, 43h, 85h
		db	0C3h,0C4h, 85h,0C3h,0C5h, 85h
		db	0C3h, 63h, 8Ch,0C3h, 53h, 86h
		db	0C3h,0DDh, 53h, 44h, 88h,0C3h
		db	0DDh,0C4h, 85h,0C3h,0C4h, 85h
		db	0C3h,0C4h, 85h,0C3h, 63h, 8Ch
		db	0C3h, 53h, 86h,0C3h, 53h, 44h
		db	0C4h, 88h,0C3h, 43h, 85h,0C3h
		db	0C4h, 85h,0C3h,0C4h, 85h,0C3h
		db	 43h, 8Eh,0C3h,0DDh, 43h, 86h
		db	0C3h, 43h, 44h,0C4h,0C5h, 88h
		db	0C3h,0DDh,0C4h, 85h,0C3h,0DDh
		db	 85h,0C3h,0C4h, 85h,0C3h, 43h
		db	 8Eh,0C3h,0C4h,0DDh,0C4h, 86h
		db	0C3h,0C4h,0C5h, 43h,0C5h,0C4h
		db	 88h,0C3h, 43h, 85h,0C3h,0C4h
		db	 85h,0C3h,0C5h, 85h,0C3h, 43h
		db	 84h,0C3h, 89h,0C3h, 53h, 86h

locloop_20:
		retn
			                        ;* No entry point to code
		lds	ax,dword ptr [bp+di-23h]	; Load seg:offset ptr
		inc	bx
;*		mov	bl,al
		db	 88h,0C3h		;  Fixup - byte match
		inc	bx
		test	ax,bx
		les	ax,dword ptr ds:data_1e[di]	; Load seg:offset ptr
		test	ax,bx
		inc	bx
		test	al,bl
;*		mov	bx,ax
		db	 89h,0C3h		;  Fixup - byte match
		push	bx
		xchg	al,bl
		add	ax,8804h
		retn
			                        ;* No entry point to code
		inc	bx
		test	ax,bx
		les	ax,dword ptr ds:data_13e[di]	; Load seg:offset ptr
		test	ax,bx
		inc	bx
		mov	es,bx
		inc	bx
;*		fld	qword ptr ss:data_10e[bp]	; Push onto stack
		db	0DDh, 86h,0C3h, 73h	;  Fixup - byte match
;*		db	0DDh, 88h,0C3h,0C4h,0DDh, 85h
		db	0DDh, 88h,0C3h,0C4h,0DDh, 85h	;  Fixup - byte match
		db	0C3h,0C4h, 85h,0C3h,0C4h, 85h
		db	0C3h, 43h, 8Eh,0C3h, 53h, 86h
		db	0C3h, 73h,0DDh, 88h,0C3h, 43h
		db	 87h, 85h,0C3h,0C4h, 85h,0C3h
		db	 63h, 8Ch,0C3h, 53h, 86h,0C3h
		db	 05h, 04h, 88h,0C3h, 43h, 87h
		db	 85h,0C3h,0C4h, 85h,0C3h, 63h
		db	 8Ch,0C3h, 53h, 86h,0C3h,0E0h
		db	 43h,0E0h, 43h, 88h,0C3h, 43h
		db	 87h, 85h,0C3h,0C4h, 85h,0C3h
		db	 63h, 8Ch,0C3h, 43h,0DDh, 95h
		db	0C3h, 43h, 85h,0C3h,0E0h, 85h
		db	0C3h,0C4h, 85h,0C3h, 63h, 8Ch
		db	0C3h, 53h, 50h, 41h, 50h, 61h
		db	 60h, 61h, 81h,0C3h, 43h, 85h
		db	0C3h,0C4h, 85h,0C3h,0C4h, 85h
		db	0C3h,0DDh, 63h, 8Bh,0C3h,0DDh
		db	 43h, 95h,0C3h, 43h, 85h,0C3h
		db	0C4h, 85h,0C3h,0C4h, 85h,0C3h
		db	 73h, 8Bh,0C3h, 53h, 95h,0C3h
		db	 43h, 85h,0C3h,0C4h,0E0h, 53h
		db	0E0h,0C4h,0DDh, 85h,0C3h, 63h
		db	 8Ch,0C3h, 53h, 86h,0C3h, 43h
		db	0C5h, 01h, 20h, 73h,0E0h, 53h
		db	0DDh, 53h,0E0h, 73h, 06h, 04h
		db	 85h,0C3h, 63h, 8Ch,0C3h, 53h
		db	 86h,0C3h,0C4h,0C5h,0C4h, 44h
		db	 73h,0DDh, 0Ch, 04h,0C4h, 01h
		db	 1Dh, 53h,0DDh, 85h,0C3h,0C4h
		db	 8Fh,0C3h,0DDh, 53h,0E0h, 43h
		db	0E0h, 43h,0C5h,0C4h, 44h, 13h
		db	 04h, 53h,0E0h, 53h, 85h,0C3h
		db	0C4h, 8Fh,0C3h, 08h, 04h,0C5h
		db	 05h, 04h,0E0h,0C4h,0E0h, 0Ch
		db	 04h,0E0h,0C4h, 85h,0C3h,0C4h
		db	 85h,0C3h,0C4h, 85h,0C3h, 53h
		db	 86h,0C3h, 0Bh, 04h, 8Fh,0C3h
		db	 53h, 83h, 85h,0C3h,0C4h, 85h
		db	0C3h,0C4h, 85h,0C3h, 53h, 86h
		db	0C3h, 0Bh, 04h, 8Fh,0C3h,0C4h
		db	 01h, 1Dh, 83h, 85h,0C3h,0DDh
		db	 85h,0C3h,0C4h, 85h,0C3h,0C4h
		db	0E0h,0C4h, 86h,0C3h, 0Bh, 04h
		db	 8Fh,0C3h, 53h, 83h, 85h,0C3h
		db	0C4h, 85h,0C3h,0C4h, 8Fh,0C3h
		db	 53h,0E0h,0C4h,0E0h, 63h,0E0h
		db	0C4h,0C1h,0C2h, 40h, 41h, 40h
		db	 87h,0C3h, 53h, 83h, 85h,0C3h
		db	0C4h, 85h,0C3h,0C4h, 40h, 51h
		db	0C1h, 51h, 40h, 41h,0C1h, 81h
		db	0C3h, 43h, 99h,0C3h, 53h, 83h
		db	 85h,0C3h,0C4h, 85h,0C3h,0DDh
		db	 8Fh,0C3h, 43h, 8Fh,0C3h,0C4h
		db	 88h,0C3h, 53h, 83h, 85h,0C3h
		db	0DDh, 85h,0C3h,0C4h, 85h,0C3h
		db	0E0h, 73h,0E0h, 73h,0C2h, 40h
		db	 41h, 40h, 41h, 40h,0C2h, 40h
		db	 81h,0C3h,0C4h, 88h,0C3h, 43h
		db	0DDh, 83h, 85h,0C3h,0C4h, 85h
		db	0C3h,0C4h, 85h,0C3h, 0Bh, 04h
		db	 99h,0C3h, 53h, 83h, 85h,0C3h
		db	0C4h, 85h,0C3h,0C4h, 85h,0C3h
		db	 09h, 04h,0DDh,0C4h, 85h,0C3h
		db	 43h, 54h, 8Eh,0C3h, 53h, 83h
		db	 93h,0C3h, 43h,0DDh, 08h, 04h
		db	 85h,0C3h,0C4h,0C5h,0C4h,0C5h
		db	0C4h, 8Eh,0C3h, 53h, 83h,0C1h
		db	 05h, 02h, 40h, 41h,0C1h, 41h
		db	 60h, 81h,0C3h, 05h, 04h, 8Bh
		db	0C3h,0C5h,0C4h,0C5h, 43h, 8Eh
		db	0C3h, 53h,0C7h, 40h, 93h,0C3h
		db	 05h, 04h, 70h, 41h, 50h, 81h
		db	0C3h, 73h,0C1h,0C2h,0C1h, 41h
		db	 40h, 87h,0C3h, 43h,0DDh, 83h
		db	 84h,0CBh, 81h,0CBh, 8Ch,0C3h
		db	 05h, 04h, 8Bh,0C3h, 63h,0DDh
		db	 8Eh,0C3h, 53h, 83h, 83h,0C3h
		db	0CAh,0CBh,0CAh,0CBh, 8Bh,0C3h
		db	 43h,0DDh, 53h, 85h,0C3h, 0Ah
		db	 04h, 84h,0C3h,0C4h, 88h,0C3h
		db	 53h, 83h, 83h,0C4h,0C9h,0C8h
		db	 49h, 4Ah, 89h,0C3h, 05h, 04h
		db	 85h,0C3h, 0Ah, 04h, 84h,0C3h
		db	0C4h, 88h,0C3h, 53h, 83h, 83h
		db	0C4h,0C8h, 58h,0CAh, 4Ah, 88h
		db	0C3h, 05h, 04h, 85h,0C3h, 0Ah
		db	 04h, 84h,0C3h,0C4h, 88h,0C3h
		db	 73h, 81h, 01h, 20h,0C4h, 46h
		db	 68h,0CAh,0CBh, 88h,0C3h, 05h
		db	 04h, 95h,0C3h,0C4h, 88h,0C3h
		db	 05h, 04h, 53h, 46h, 78h,0CAh
		db	0CBh, 87h,0C3h,0DDh, 73h, 95h
		db	0C3h, 73h, 84h,0C3h, 73h,0DDh
		db	0C4h,0C7h,0C8h,0C7h, 78h, 49h
		db	0CBh, 87h,0C3h, 05h, 04h, 97h
		db	0C3h, 53h, 84h,0C3h, 05h, 04h
		db	0C4h,0C7h, 06h, 09h,0CAh,0CBh
		db	 88h,0C3h, 05h, 04h, 97h,0C3h
		db	 53h, 84h,0C3h,0C4h,0DDh, 63h
		db	0C4h,0C7h,0C9h,0C7h, 48h,0C7h
		db	 48h,0CAh,0CBh, 88h,0C3h, 05h
		db	 04h, 97h,0C3h,0E0h, 43h, 84h
		db	0C3h,0C4h,0DDh, 63h, 63h, 48h
		db	0C7h, 68h,0CBh, 87h,0C3h, 05h
		db	 04h, 91h,0C3h,0C4h, 8Ch,0C3h
		db	 05h, 04h, 73h,0DDh, 43h, 68h
		db	0CAh,0CBh, 85h,0C3h, 05h, 04h
		db	 91h,0C3h,0C4h,0C1h, 41h, 40h
		db	 61h, 40h, 81h,0C3h, 05h, 04h
		db	 07h, 04h,0C7h, 58h, 49h,0CBh
		db	 84h,0C3h, 05h, 04h, 91h,0C3h
		db	0DDh, 8Ch,0C3h, 53h, 01h, 1Dh
		db	0C4h, 3Ch, 00h, 10h, 3Fh, 00h
		db	 10h, 3Fh, 00h, 27h, 42h, 00h
		db	 3Ah, 61h, 00h, 06h, 76h, 00h
		db	 34h, 79h, 00h, 24h,0A9h, 00h
		db	 17h,0B7h, 00h, 2Eh,0CCh, 00h
		db	 36h,0FFh,0FFh,0FFh,0FFh, 03h
		db	 80h,0AAh,0F8h, 00h, 0Ch, 00h
		db	 0Ch, 40h, 8Ah, 07h, 00h, 13h
		db	 00h, 0Dh, 40h,0B6h, 06h, 00h
		db	 14h, 00h, 11h, 40h,0A7h, 0Bh
		db	 00h, 14h, 00h, 15h, 80h,0BEh
		db	 0Fh, 00h, 19h, 00h, 32h, 40h
		db	0B4h, 2Eh, 00h, 3Ch, 00h, 4Fh
		db	 40h, 99h, 45h, 00h, 5Ch, 00h
		db	 57h, 40h, 91h, 4Dh, 00h, 63h
		db	 00h, 6Dh, 40h, 9Dh, 69h, 00h
		db	 74h, 00h, 90h, 40h, 18h, 8Bh
		db	 00h, 97h, 00h, 9Ah, 40h,0B3h
		db	 93h, 00h,0A1h, 00h, 9Fh, 80h
		db	 2Bh, 97h, 00h,0A7h, 00h,0C7h
		db	 40h, 27h,0BDh, 00h,0D0h, 00h
		db	0C8h, 80h, 06h,0C1h, 00h,0D3h
		db	 00h,0DEh, 40h, 94h,0D0h, 00h
		db	0E5h, 00h,0F2h, 80h,0B4h,0E8h
		db	 00h,0F6h, 00h,0FDh, 80h,0A5h
		db	0F8h, 00h, 03h, 00h,0FFh,0FFh
		db	 0Ch, 00h, 1Bh, 81h, 0Eh, 0Ch
		db	 00h, 1Bh, 00h,0FFh,0FFh,0FFh
		db	 1Eh, 00h, 1Ch, 84h, 0Eh, 1Eh
		db	 00h, 1Ch, 00h,0FFh,0FFh,0FFh
		db	 1Fh, 00h, 05h, 80h, 06h, 04h
		db	 00h,0FFh, 00h,0FFh,0FFh,0FFh
		db	 5Ah, 00h, 25h, 84h, 0Eh, 5Ah
		db	 00h, 25h, 00h,0FFh,0FFh,0FFh
		db	 80h, 00h, 29h, 81h, 0Fh,0B0h
		db	 00h, 39h, 00h,0FFh,0FFh,0FFh
		db	 8Fh, 00h, 3Eh,0C4h, 0Fh,0B1h
		db	 00h, 11h, 00h,0FFh,0FFh,0FFh
		db	 92h, 00h, 0Ah,0C2h, 0Fh,0D5h
		db	 00h, 32h, 00h,0FFh,0FFh,0FFh
		db	 96h, 00h, 1Eh, 82h, 0Eh, 96h
		db	 00h, 1Eh, 00h,0FFh,0FFh,0FFh
		db	0A9h, 00h, 1Eh, 82h, 0Eh,0A9h
		db	 00h, 1Eh, 00h,0FFh,0FFh,0FFh
		db	0B0h, 00h, 39h,0C1h, 0Fh, 80h
		db	 00h, 29h, 00h,0FFh,0FFh,0FFh
		db	0B1h, 00h, 11h, 84h, 0Fh, 8Fh
		db	 00h, 3Eh, 00h,0FFh,0FFh,0FFh
		db	0BCh, 00h, 1Eh, 81h, 0Eh,0BCh
		db	 00h, 1Eh, 00h,0FFh,0FFh,0FFh
		db	0D5h, 00h, 32h, 82h, 0Fh, 92h
		db	 00h, 0Ah, 00h,0FFh,0FFh,0FFh
		db	0DDh, 00h, 01h, 82h, 0Eh, 83h
		db	 00h, 1Eh, 00h,0FFh,0FFh,0FFh
		db	0F9h, 00h, 0Fh, 84h, 0Eh,0F9h
		db	 00h, 0Fh, 00h,0FFh,0FFh,0FFh
		db	0FFh,0FFh, 2Bh, 00h, 02h, 33h
		db	0D5h, 00h, 00h,0FFh,0FFh, 2Bh
		db	 00h, 01h, 3Ah,0D5h, 00h,0FFh
		db	 45h,0D5h,0FFh,0FFh,0FFh,0FFh
		db	 2Ch, 00h, 80h,0BAh,0D5h, 00h
		db	0FFh,0C5h,0D5h,0FFh,0FFh,0FFh
		db	0FFh, 2Ch, 00h, 40h, 33h,0D6h
		db	 00h, 00h,0FFh,0FFh, 2Ch, 00h
		db	 20h, 03h,0D7h, 00h, 00h,0FFh
		db	0FFh, 2Ch, 00h, 10h,0C3h,0D7h
		db	 00h, 00h,0FFh,0FFh,0FFh,0FFh
		db	 18h,0AFh, 00h, 0Fh
		db	'Cavern of Plata'
		db	 13h, 00h, 05h, 0Ah, 0Ah, 00h
		db	 00h, 37h,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 19h, 00h, 2Bh, 00h
		db	 02h, 00h, 00h, 06h, 00h, 16h
		db	0FFh, 73h, 00h, 04h, 20h, 00h
		db	 00h, 00h, 2Bh, 00h, 01h, 00h
		db	 00h, 0Bh, 00h, 14h,0FFh, 00h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 0Bh, 00h, 14h, 00h, 00h, 0Bh
		db	 00h, 16h,0FFh, 01h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 0Bh, 00h
		db	 16h, 01h, 00h, 1Dh, 00h, 11h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 1Dh, 00h, 11h, 04h
		db	 00h, 23h, 00h, 0Eh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 23h, 00h, 0Eh, 03h, 00h, 24h
		db	 00h, 16h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 24h, 00h
		db	 16h, 03h, 00h, 26h, 00h, 23h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 26h, 00h, 23h, 04h
		db	 00h, 2Ch, 00h, 11h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 2Ch, 00h, 11h, 04h, 00h, 3Ch
		db	 00h, 02h,0FFh, 73h, 00h, 00h
		db	 20h, 00h, 18h, 00h, 2Ch, 00h
		db	 80h, 00h, 00h, 44h, 00h, 1Eh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 44h, 00h, 1Eh, 02h
		db	 00h, 4Ch, 00h, 38h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 4Ch, 00h, 38h, 02h, 00h, 4Dh
		db	 00h, 16h,0FFh,0D0h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 4Eh, 00h, 3Ch
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 4Eh, 00h, 3Ch, 04h
		db	 00h, 59h, 00h, 16h,0FFh,0D0h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 00h, 58h
		db	 00h, 1Eh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 58h, 00h
		db	 1Eh, 03h, 00h, 5Fh, 00h, 1Eh
		db	0FFh,0D0h, 00h, 00h, 20h, 00h
		db	 19h, 00h, 2Ch, 00h, 40h, 00h
		db	 00h, 5Fh, 00h, 35h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 5Fh, 00h, 35h, 03h, 00h, 6Ch
		db	 00h, 26h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 6Ch, 00h
		db	 26h, 04h, 00h, 6Eh, 00h, 0Ch
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 6Eh, 00h, 0Ch, 02h
		db	 00h, 71h, 00h, 21h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 71h, 00h, 21h, 03h, 00h, 76h
		db	 00h, 02h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 76h, 00h
		db	 02h, 03h, 00h, 82h, 00h, 26h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 82h, 00h, 26h, 04h
		db	 00h, 84h, 00h, 11h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 84h, 00h, 11h, 04h, 00h, 84h
		db	 00h, 22h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 84h, 00h
		db	 22h, 02h, 00h, 86h, 00h, 00h
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 86h, 00h, 00h, 00h
		db	 00h, 86h, 00h, 02h,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 86h, 00h, 02h, 01h, 00h, 86h
		db	 00h, 0Ch,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 86h, 00h
		db	 0Ch, 03h, 00h, 86h, 00h, 33h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 86h, 00h, 33h, 02h
		db	 00h, 88h, 00h, 0Ch,0FFh,0D0h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 2Ch, 00h, 20h, 00h, 00h, 8Bh
		db	 00h, 0Ch,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 8Bh, 00h
		db	 0Ch, 03h, 00h, 8Dh, 00h, 1Eh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 8Dh, 00h, 1Eh, 02h
		db	 00h, 90h, 00h, 3Ah,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 90h, 00h, 3Ah, 04h, 00h, 9Ah
		db	 00h, 31h,0FFh,0D0h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 9Bh, 00h, 0Fh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 9Bh, 00h, 0Fh, 02h
		db	 00h, 9Ch, 00h, 01h,0FFh, 00h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 9Ch, 00h, 01h, 00h, 00h, 9Ch
		db	 00h, 03h,0FFh, 01h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 9Ch, 00h
		db	 03h, 01h, 00h,0B0h, 00h, 1Eh
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0B0h, 00h, 1Eh, 00h
		db	 00h,0B0h, 00h, 20h,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	0B0h, 00h, 20h, 01h, 00h,0B0h
		db	 00h, 31h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B0h, 00h
		db	 31h, 03h, 00h,0B1h, 00h, 06h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0B1h, 00h, 06h, 04h
		db	 00h,0B2h, 00h, 27h,0FFh,0D0h
		db	 00h, 00h, 20h, 00h, 18h, 00h
		db	 2Ch, 00h, 10h, 00h, 00h,0BDh
		db	 00h, 17h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0BDh, 00h
		db	 17h, 04h, 00h,0C0h, 00h, 2Ch
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0C0h, 00h, 2Ch, 02h
		db	 00h,0C4h, 00h, 09h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0C4h, 00h, 09h, 03h, 00h,0C5h
		db	 00h, 0Ch,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C5h, 00h
		db	 0Ch, 04h, 00h,0CDh, 00h, 1Ch
		db	0FFh,0D0h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	 00h,0D0h, 00h, 0Fh,0FFh,0D0h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 00h,0D0h
		db	 00h, 11h,0FFh,0D0h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h,0D4h, 00h, 3Ch
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0D4h, 00h, 3Ch, 03h
		db	 00h,0D6h, 00h, 25h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0D6h, 00h, 25h, 02h, 00h,0D8h
		db	 00h, 0Fh,0FFh,0D0h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h,0D8h, 00h, 11h
		db	0FFh,0D0h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	 00h,0DEh, 00h, 0Ah,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0DEh, 00h, 0Ah, 02h, 00h,0DEh
		db	 00h, 11h,0FFh,0D0h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h,0DEh, 00h, 1Bh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0DEh, 00h, 1Bh, 03h
		db	 00h,0E6h, 00h, 1Bh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0E6h, 00h, 1Bh, 02h, 00h,0E8h
		db	 00h, 35h,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h,0E8h, 00h
		db	 35h, 00h, 00h,0E8h, 00h, 37h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0E8h, 00h, 37h, 01h
		db	 00h,0F4h, 00h, 37h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0F4h, 00h, 37h, 02h, 00h,0FFh
		db	0FFh

zr3_35		endp

seg_a		ends



		end	start
