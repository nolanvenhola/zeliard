
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				_357UNKN                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   5-Apr-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    5          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_10e	equ	3EE8h			;*
data_11e	equ	40E7h			;*
data_12e	equ	8010h			;*
data_13e	equ	80FEh			;*
data_14e	equ	98A8h			;*
data_15e	equ	9E20h			;*
data_16e	equ	0A0A7h			;*
data_17e	equ	0AA80h			;*
data_18e	equ	0AAFEh			;*
data_19e	equ	0ABA8h			;*
data_20e	equ	0BE2Ah			;*
data_21e	equ	0FEA0h			;*
data_22e	equ	0FF03h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_357UNKN	proc	far

start:
		mov	al,data_2
		add	[bx+si],al
		push	es
		db	 66h, 00h, 69h, 80h, 6Eh, 02h
		db	 6Fh,0AAh
data_1		dw	38Dh
		db	 93h, 01h, 99h, 40h, 9Ah,0A0h
		db	 9Bh, 20h, 9Ch,0A8h
data_2		db	0B3h
		db	0C0h,0B9h,0FFh,0CBh,0FEh,0D2h
		db	 0Ah,0D6h, 2Ah,0DBh, 04h,0E6h
		db	 10h,0FFh,0FFh, 66h, 2Fh, 0Ah
		db	 66h, 01h, 2Bh, 66h, 01h,0BFh
		db	 00h, 02h, 2Ah,0FFh, 00h, 2Bh
		db	 66h, 06h, 80h, 66h, 01h, 80h
		db	 66h, 01h,0E8h, 00h, 80h, 00h
		db	0FEh, 00h, 80h, 00h,0FFh, 80h
		db	0E0h, 00h,0FFh,0EAh,0FAh, 66h
		db	 00h,0BFh, 00h, 02h, 00h, 2Fh
		db	 66h, 01h, 0Ah, 66h, 14h,0FFh
		db	 80h,0E0h, 00h,0FEh, 00h, 80h
		db	 00h,0E8h, 00h, 80h, 00h, 80h
		db	 66h, 01h, 80h, 66h, 01h, 80h
		db	 66h, 0Ah, 03h, 00h, 02h
data_3		db	0			; Data table (indexed access)
		db	 0Fh, 00h, 02h, 8Dh, 00h, 02h
		db	 00h, 30h, 3Ch, 20h, 08h, 00h
		db	0CCh, 66h, 00h, 03h, 0Ch, 66h
		db	 01h, 03h, 00h, 02h,0F0h, 3Fh
		db	 80h, 28h, 66h, 02h,0C0h, 00h
		db	 80h, 00h, 0Ch, 00h, 08h, 66h
		db	 03h,0F0h, 30h,0A0h, 20h, 0Ch
		db	 00h, 08h, 66h, 03h,0C0h,0CFh
		db	 80h, 00h, 0Ch,0CFh, 66h, 01h
		db	 03h, 00h, 02h, 0Ch,0C0h, 66h
		db	 01h, 0Fh, 00h, 02h, 33h, 30h
		db	 20h, 66h, 04h,0C3h, 00h, 82h
		db	 00h, 03h, 66h, 00h,0CCh, 00h
		db	 80h, 00h, 03h,0C0h, 00h, 80h
		db	0CCh, 66h, 05h, 30h, 30h, 00h
		db	 20h, 03h, 00h, 02h, 00h,0F0h
		db	 00h, 20h, 66h, 07h, 03h, 00h
		db	 02h, 66h, 03h,0C0h, 00h, 80h
		db	 66h, 00h, 03h, 00h, 02h, 66h
		db	 03h, 3Ch, 00h, 20h, 30h, 30h
		db	 20h, 66h, 03h, 03h, 0Ch, 02h
		db	 08h, 66h, 06h, 30h, 00h, 20h
		db	 00h, 8Dh, 00h
data_4		db	6Eh			; Data table (indexed access)
		db	 00h,0C0h, 00h, 80h, 00h, 03h
		db	 66h, 02h, 0Ch, 00h, 08h, 00h
		db	0C0h, 00h, 80h, 00h, 03h, 00h
		db	 02h, 66h, 0Ah, 03h, 00h, 02h
		db	 00h,0C0h, 00h, 80h, 00h,0F0h
		db	 00h,0A0h, 00h,0F0h, 00h, 80h
		db	 00h, 03h, 00h, 02h, 66h, 08h
		db	 03h, 00h, 02h, 30h, 30h, 9Bh
		db	 00h, 66h, 0Fh, 1Fh, 66h, 01h
		db	0FDh, 66h, 00h, 03h,0FEh, 66h
		db	 00h, 06h,0F8h, 66h, 00h, 0Dh
		db	0E8h, 00h, 05h, 66h, 0Ah,0D0h
		db	 66h, 01h, 52h, 66h, 01h, 8Ah
		db	 40h, 66h, 01h, 20h, 66h, 01h
		db	 10h,0A0h, 00h, 0Dh, 90h, 00h
		db	 03h, 0Dh, 40h, 00h, 05h, 06h
		db	 40h, 66h, 00h, 03h, 66h, 02h
		db	0A0h, 66h, 01h
data_5		dw	6615h			; Data table (indexed access)
		db	 09h, 10h,0C0h, 66h, 00h, 10h
		db	0A0h, 66h, 00h, 20h, 66h, 01h
		db	 40h, 66h, 00h, 02h, 66h, 01h
		db	 50h, 66h, 16h, 1Fh, 66h, 01h
		db	0FDh, 66h, 00h, 03h,0FEh, 66h
		db	 00h, 06h,0F8h, 00h, 05h, 0Dh
		db	0E8h, 00h, 13h, 66h, 0Ah,0D0h
		db	 66h, 01h, 52h, 66h, 01h, 8Ah
		db	 40h, 66h, 01h, 20h, 50h, 66h
		db	 00h, 10h,0A8h, 00h, 0Dh, 90h
		db	 00h, 2Fh, 0Dh, 40h, 00h, 17h
		db	 06h, 40h, 00h, 0Ah, 03h, 66h
		db	 02h,0A0h, 66h, 01h, 15h, 66h
		db	 09h, 10h,0D0h, 66h, 00h, 10h
		db	0A8h, 66h, 00h, 20h, 40h, 66h
		db	 00h, 40h, 66h, 00h, 02h, 66h
		db	 01h, 50h, 66h, 16h, 1Fh, 66h
		db	 01h,0FDh, 66h, 00h, 03h,0FEh
		db	 00h, 01h, 06h,0F8h, 00h, 07h
		db	 0Dh,0E9h, 00h, 16h, 66h, 0Ah
		db	0D0h, 66h, 01h, 52h, 66h, 01h
		db	 8Ah, 40h, 20h, 66h, 00h, 20h
		db	0F5h, 00h, 40h, 10h,0BAh, 00h
		db	 0Dh, 92h, 00h, 2Dh, 0Dh, 45h
		db	 00h, 3Ah, 06h, 40h, 00h, 1Fh
		db	 03h, 66h, 00h, 0Ah, 00h,0A0h
		db	 66h, 01h, 15h, 66h, 08h, 80h
		db	 10h, 7Dh, 00h, 40h, 10h,0BAh
		db	 66h, 00h, 20h,0D4h, 66h, 00h
		db	 40h,0A0h, 00h, 02h, 66h, 01h
		db	 50h, 66h, 09h, 03h,0BFh, 02h
		db	0AAh, 08h, 66h, 01h, 18h, 00h
		db	 02h,0FEh, 30h, 00h, 20h, 00h
		db	 20h, 00h, 0Bh,0FAh, 20h, 00h
		db	 20h, 66h, 01h, 0Bh,0FAh, 20h
		db	 00h, 20h, 00h,0AAh,0F0h,0AAh
		db	 30h, 03h, 08h, 00h, 08h, 02h
		db	 04h,0AAh,0DBh, 00h, 02h, 04h
		db	 22h, 66h, 00h,0A0h, 48h, 04h
		db	 02h, 04h, 92h, 66h, 00h,0A1h
		db	 20h, 04h, 02h, 04h, 02h, 3Fh
		db	0B6h, 23h,0A6h, 20h, 34h, 00h
		db	 24h, 10h, 1Ch, 02h, 3Eh, 10h
		db	 00h, 01h, 55h, 10h, 00h, 10h
		db	 00h, 10h, 00h, 15h,0FDh, 10h
		db	 00h, 12h,0AAh, 1Dh, 50h, 1Dh
		db	 50h,0EAh,0AAh, 8Ah,0AAh, 04h
		db	 02h, 04h, 02h, 04h, 00h, 20h
		db	 80h, 04h, 02h, 44h, 22h, 04h
		db	 02h, 05h, 02h, 04h, 00h, 50h
		db	 20h,0DBh, 00h,0A2h, 44h, 6Dh
		db	 6Ch, 45h, 6Ch, 00h, 02h, 00h
		db	 02h, 00h, 07h, 00h, 06h, 00h
		db	 07h, 00h, 06h, 00h, 1Fh, 00h
		db	 1Fh, 00h, 78h, 00h, 70h, 00h
		db	0E0h, 00h,0C0h, 00h, 78h, 00h
		db	 70h, 00h, 1Fh, 00h, 1Bh, 66h
		db	 0Ah,0C0h, 00h,0C0h, 00h,0F0h
		db	 00h,0E0h, 00h, 38h, 00h, 20h
		db	 00h,0F0h, 00h,0C0h, 00h,0C0h
		db	 66h, 02h, 0Fh, 00h, 0Dh, 00h
		db	 0Bh, 00h, 0Ah, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 0Ah, 00h
		db	 0Bh, 00h, 09h, 00h, 0Bh, 00h
		db	 0Ah, 00h, 0Bh, 00h, 09h, 66h
		db	 0Ah,0E0h, 00h,0A0h, 66h, 03h
		db	 90h, 00h, 90h, 00h,0F0h, 00h
		db	0C0h, 66h, 20h, 0Fh, 00h, 07h
		db	 00h, 3Fh, 00h, 17h, 66h, 06h
		db	 02h, 0Ch, 02h, 04h, 0Ah, 38h
		db	 0Ah, 18h, 2Ah,0F8h, 2Ah, 78h
		db	0FFh,0E8h, 5Dh,0E8h,0FBh,0E0h
		db	0F9h,0E0h,0AFh,0A0h,0A7h,0A0h
		db	 00h,0FEh, 00h, 5Eh, 03h,0FAh
		db	 03h,0FAh, 00h, 80h, 00h, 6Bh
		db	 03h, 02h, 03h,0AEh,0FEh,0AAh
data_6		db	0FEh			; Data table (indexed access)

locloop_2:
		stosb				; Store al to es:[di]
		sti				; Enable interrupts
		mov	si,0BEF8h
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		test	al,2Bh			; '+'
		and	cl,ss:data_7[bp+di]
		mov	si,data_15e
		and	ds:data_14e[bx+si],bh
		test	al,0B8h
		mov	ax,0B8B8h
		mov	dx,0BA28h
		sub	ss:data_19e[bp+di],ch
		test	al,0AAh
		test	al,0AAh
		test	al,0AFh

locloop_3:
		test	al,0A0h
		push	si
;*		jmp	far ptr loc_19		;*
		db	0EAh
		dw	15A8h, 6656h		;  Fixup - byte match
		db	 13h, 0Fh, 00h

locloop_4:
		pop	es
		add	[bx],bh
		add	[bx],dl
;*		add	dh,bh
		db	 00h,0FEh		;  Fixup - byte match
		add	[bp+66h],bl
		add	al,[bp+si]
		or	al,2
		add	al,0Ah
		cmp	[bp+si],cl
		sbb	[bp+si],ch
		clc				; Clear carry flag
		sub	bh,[bx+si-1]
		call	$-17A0h
		sti				; Enable interrupts
;*		loopnz	locloop_5		;*Loop if zf=0, cx>0

		db	0E0h,0F9h		;  Fixup - byte match
		loopnz	locloop_2		; Loop if zf=0, cx>0

		mov	al,ds:data_16e
		mov	si,data_15e
		and	[bp+di],al
		cli				; Disable interrupts
		add	di,dx
		add	byte ptr ds:[6B00h][bx+si],al
		add	ax,[bp+si]
		add	bp,ss:data_18e[bp]
		db	0FEh,0AAh,0FBh,0BEh,0F8h,0BEh
		db	0ABh

locloop_6:
		stosw				; Store ax to es:[di]
		test	al,2Bh			; '+'
		and	cl,ss:data_7[bp+di]
		scasw				; Scan es:[di] for ax
		loop	locloop_3		; Loop if cx > 0

		loop	locloop_4		; Loop if cx > 0

		test	al,98h
		test	al,0B8h
		mov	ax,0B8B8h
		mov	dx,0BA28h
		sub	ss:data_19e[bp+di],ch
		test	al,0AAh
		test	al,0AAh
		test	al,0AFh
		test	al,0A0h
		push	si
;*		jmp	far ptr loc_20		;*
		db	0EAh
		dw	15A8h, 0AB52h		;  Fixup - byte match
;*		jmp	far ptr loc_1		;*
		db	0EAh
		dw	0E453h, 0F66h		;  Fixup - byte match
			                        ;* No entry point to code
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bx],al
		add	[bx],bh
		add	[bx],dl
;*		add	dh,bh
		db	 00h,0FEh		;  Fixup - byte match
		add	[bp+3],bl
		cli				; Disable interrupts
		add	di,dx
		add	cl,[si]
		add	al,[si]
		or	bh,[bx+si]
		or	bl,[bx+si]
		sub	bh,al
		sub	bh,[bx+si-1]
		call	$-17A0h
		sti				; Enable interrupts
;*		loopnz	locloop_7		;*Loop if zf=0, cx>0

		db	0E0h,0F9h		;  Fixup - byte match
		loopnz	locloop_6		; Loop if zf=0, cx>0

		mov	al,ds:data_16e
		mov	si,data_15e
		and	ds:data_14e[bx+si],bh
		test	al,0
		add	byte ptr [bx+si],6Bh	; 'k'
		add	ax,[bp+si]
		add	bp,ss:data_18e[bp]
		db	0FEh,0AAh,0FBh,0BEh,0F8h,0BEh
		db	0ABh,0ABh,0A8h, 2Bh, 22h, 8Bh
		db	 20h, 0Bh,0AFh,0E2h,0AFh,0E2h
		db	0FEh,0AAh,0FEh,0A8h,0B8h,0B8h
		db	0B8h,0B8h,0BAh, 28h,0BAh, 28h
		db	0ABh,0A8h,0ABh,0A8h,0AAh,0A8h
		db	0AAh,0A8h,0AFh,0A8h,0A0h, 56h
		db	0EAh,0A8h, 15h, 52h,0ABh,0EAh
		db	 53h,0E4h,0AFh,0AAh, 4Fh,0ACh
		db	 66h, 06h, 30h, 80h, 10h, 80h
		db	 3Ch,0A0h, 14h,0A0h, 3Fh,0A8h
		db	 1Dh,0A8h, 3Bh,0FFh, 3Bh, 75h
		db	 0Fh,0EFh, 07h,0EFh, 0Fh,0BBh
		db	 07h,0BBh, 66h, 16h,0E0h, 00h
		db	0E0h, 00h

locloop_8:
		clc				; Clear carry flag
;*		add	al,bh
		db	 00h,0F8h		;  Fixup - byte match
		add	byte ptr ds:[0E3Eh],cl
		db	 3Eh, 3Ch, 8Eh, 3Ch, 8Eh, 3Ch
		db	 2Eh, 1Ch, 2Eh, 3Eh, 2Eh, 1Eh
		db	 2Eh, 3Bh,0EAh, 3Bh,0EAh, 3Ah
		db	0ABh, 1Ah,0ABh, 3Eh,0AFh,0C1h
		db	 5Fh, 2Ah,0AAh,0D5h, 55h,0EAh
		db	 00h,0EAh, 00h,0AAh, 80h,0AAh
		db	 80h, 02h, 00h,0E9h, 00h, 80h
		db	0C0h

locloop_9:
		mov	dx,0FAC0h
		scasw				; Scan es:[di] for ax
		cli				; Disable interrupts
		scasw				; Scan es:[di] for ax
		db	0FEh,0EBh,0FEh, 2Bh,0EBh,0AEh
		db	0E8h, 2Eh,0E2h, 88h,0E0h, 08h
		db	 66h, 02h, 30h, 80h, 10h, 80h
		db	 3Ch,0A0h, 14h,0A0h, 3Fh,0A8h
		db	 1Dh,0A8h, 3Bh,0FFh, 3Bh, 75h
		db	 0Fh,0EFh, 07h,0EFh, 0Fh,0BBh
		db	 07h,0BBh, 0Eh, 3Eh, 0Eh, 3Eh
		db	 66h, 12h,0E0h, 00h,0E0h, 00h
		db	0F8h, 00h,0F8h, 00h,0EAh, 00h
		db	0EAh, 00h, 3Ch, 8Eh, 3Ch, 8Eh
		db	 3Ch, 2Eh, 1Ch, 2Eh, 3Eh, 2Eh
		db	 1Eh, 2Eh, 3Bh,0EAh, 3Bh,0EAh
		db	 3Ah,0ABh, 1Ah,0ABh, 3Eh,0AFh
		db	0C1h, 5Fh, 2Ah,0AAh,0D5h, 55h
		db	0EFh,0A2h, 0Fh, 89h,0AAh, 80h
		db	0AAh, 80h, 02h, 00h,0E9h, 00h
		db	 80h,0C0h,0BAh,0C0h,0FAh,0AFh
		db	0FAh,0AFh

locloop_10:
		db	0FEh
loc_11:
		jmp	short loc_11
			                        ;* No entry point to code
		sub	bp,bx
		mov	si,data_10e
		loop	locloop_9		; Loop if cx > 0

		loopnz	$+0Ah			; Loop if zf=0, cx>0

		mov	di,dx
		mov	di,dx
		xor	ds:data_12e[bx+si],al
		cmp	al,0A0h
		adc	al,0A0h
		aas				; Ascii adjust
		test	al,1Dh
		test	al,3Bh			; ';'
		db	0FFh, 3Bh, 75h, 0Fh,0EFh, 07h
		db	0EFh, 0Fh,0BBh, 07h,0BBh, 0Eh
		db	 3Eh, 0Eh, 3Eh, 3Ch, 8Eh, 3Ch
		db	 8Eh, 66h, 0Eh,0E0h, 00h,0E0h
		db	 00h

locloop_12:
		clc				; Clear carry flag
;*		add	al,bh
		db	 00h,0F8h		;  Fixup - byte match
;*		add	dl,ch
		db	 00h,0EAh		;  Fixup - byte match
;*		add	dl,ch
		db	 00h,0EAh		;  Fixup - byte match
		add	ss:data_17e[bp+si],ch
		cmp	byte ptr [si],2Eh	; '.'
		sbb	al,2Eh			; '.'
		db	 3Eh, 2Eh, 1Eh, 2Eh, 3Bh,0EAh
		db	 3Bh,0EAh, 3Ah,0ABh, 1Ah,0ABh
		db	 3Eh,0AFh,0C1h, 5Fh, 2Ah,0AAh
		db	0D5h, 55h,0EFh,0AAh, 1Fh, 94h
		db	0BAh,0AAh, 7Ah,0A5h, 02h, 00h
		db	0E9h, 00h, 80h,0C0h,0BAh,0C0h
		db	0FAh,0AFh,0FAh,0AFh,0FEh
loc_13:
		jmp	short loc_13
			                        ;* No entry point to code
		sub	bp,bx
		mov	si,3EE8h
		loop	locloop_10		; Loop if cx > 0

		loopnz	$+0Ah			; Loop if zf=0, cx>0

		mov	di,dx
		mov	di,dx
		stosb				; Store al to es:[di]
		mov	si,data_20e
		add	ax,[bx+si]
		add	ax,[bx+si]
		pop	es
		add	[bx],al
		add	byte ptr ds:[6C0h],al
		db	0C0h, 06h, 75h, 06h, 75h, 02h
		db	 7Fh, 02h, 7Fh, 01h, 73h, 41h
		db	 4Fh, 00h, 24h, 00h,0DCh, 01h
		db	0ACh, 19h,0FCh, 66h, 03h, 0Ch
		db	 00h, 0Ch, 00h, 0Ch, 00h, 0Ch
		db	0D0h, 3Ch,0D0h, 3Ch,0FFh, 32h
		db	0FFh, 32h,0FFh,0F2h,0FFh,0F2h
		db	0CDh, 34h,0CEh,0F4h,0C5h, 08h
		db	0C5h,0F8h, 00h, 75h, 00h, 75h
		db	 00h, 10h, 06h,0E6h, 00h, 03h
		db	 13h, 80h, 58h, 02h, 59h,0C0h
		db	0CCh, 00h,0CCh,0F1h, 80h, 00h
		db	0FFh,0ECh, 7Bh, 00h, 7Bh, 16h
		db	 74h, 80h, 74h, 8Ah, 55h,0F0h
		db	 55h,0F0h, 03h,0D0h, 03h,0D0h
		db	 30h,0ACh, 00h,0ACh, 30h, 14h
		db	 00h, 14h, 12h, 0Ch, 40h, 0Ch
		db	 03h, 30h,0A0h, 30h, 03h, 70h
		db	 50h, 70h, 02h,0CEh,0AAh,0CEh
		db	 66h, 05h, 04h, 66h, 00h, 80h
		db	 66h, 01h, 40h, 44h, 66h, 01h
		db	 04h, 66h, 00h, 40h, 20h, 66h
		db	 00h,0A8h, 14h, 66h, 00h, 39h
		db	 14h, 66h, 00h, 0Eh, 02h, 00h
		db	 10h, 23h, 16h, 00h, 38h, 0Bh
		db	 79h, 00h, 24h, 0Bh, 7Dh, 00h
		db	 34h, 00h,0FCh, 00h, 0Bh, 13h
		db	0BFh, 00h, 04h, 00h, 2Fh, 66h
		db	 00h, 41h,0EFh, 66h, 01h, 10h
		db	 66h, 01h, 80h, 66h, 03h, 01h
		db	 00h, 81h, 00h, 03h, 86h, 03h
		db	 70h, 0Eh,0FEh, 0Eh,0E1h,0FDh
		db	0FFh,0FDh, 53h,0FAh,0FFh,0FAh
		db	0AFh,0E2h,0AFh,0E2h,0FEh,0AAh
		db	0FEh,0A8h,0AAh,0A8h,0AAh, 97h
		db	 2Ah, 80h, 2Ah,0BFh, 02h, 83h
		db	 02h,0BCh, 00h,0A2h, 00h,0ACh
		db	 00h,0ABh, 00h,0A0h, 00h,0AFh
		db	 00h,0A0h,0ABh,0EAh, 03h,0E0h
		db	0AFh,0AAh, 4Fh,0A8h, 2Bh,0AAh
		db	0C3h,0A8h, 2Fh,0A8h,0C0h, 2Ah
		db	0BFh,0ECh, 00h, 02h,0EAh,0B8h
		db	 00h, 02h,0A0h,0A2h, 0Ah, 00h
		db	 88h, 20h, 26h, 80h, 00h, 2Fh
		db	 00h, 20h, 00h, 0Bh, 66h, 01h
		db	0EEh, 00h, 1Ch, 00h,0ABh, 00h
		db	 54h, 00h, 0Ah, 00h,0F5h, 66h
		db	 00h, 0Bh,0FAh, 66h, 00h, 03h
		db	0AAh, 66h, 01h, 28h, 80h, 20h
		db	 2Bh,0C0h,0A0h,0A2h, 0Bh, 00h
		db	 2Ah, 88h, 66h, 00h, 80h, 2Ch
		db	 66h, 00h, 20h, 80h, 00h, 38h
		db	 02h
		db	0
		db	 01h,0FEh, 66h, 01h,0AEh, 66h
		db	 00h, 03h,0F8h,0FEh,0AAh,0FEh
		db	0A8h,0AAh,0A8h,0AAh, 97h, 2Ah
		db	 80h, 2Ah,0BFh, 02h, 83h, 02h
		db	0BCh, 00h,0A2h, 00h,0ACh, 00h
		db	0ABh, 00h,0A0h, 00h,0AFh, 00h
		db	0A0h, 00h, 2Fh, 00h, 20h,0AFh
		db	0AAh, 4Fh,0A8h, 2Bh,0AAh,0C3h
		db	0A8h, 2Fh,0A8h,0C0h, 2Ah,0BFh
		db	0ECh, 00h, 02h,0EAh,0B8h, 00h
		db	 02h,0A0h,0A2h, 0Ah, 00h, 88h
		db	 20h, 26h, 69h, 00h, 20h, 2Bh
		db	0C0h, 00h, 0Bh, 66h, 01h, 02h
		db	 66h, 01h, 03h, 66h, 01h, 0Ah
		db	 00h, 05h, 00h, 0Ah, 00h, 05h
		db	 66h, 01h, 0Fh, 66h, 01h, 0Fh
		db	 66h, 01h, 3Eh,0A0h,0A2h, 0Bh
		db	 00h, 2Ah, 88h, 66h, 00h, 80h
		db	 2Ch, 66h, 00h, 20h, 69h, 00h
		db	 20h,0A0h, 00h, 5Fh,0A8h, 66h
		db	 00h,0A3h,0A8h, 66h, 00h,0A3h
		db	0A0h, 66h, 00h,0AEh, 80h,0AAh
		db	0A8h,0AAh, 97h, 2Ah, 80h, 2Ah
		db	0BFh, 02h, 83h, 02h,0BCh, 00h
		db	0A2h, 00h,0ACh, 00h,0ABh, 00h
		db	0A0h, 00h,0AFh, 00h,0A0h, 00h
		db	 2Fh, 00h, 20h, 00h, 0Bh, 66h
		db	 00h, 2Bh,0AAh,0C3h,0A8h, 2Fh
		db	0A8h,0C0h, 2Ah,0BFh,0ECh, 00h
		db	 02h,0EAh,0B8h, 00h, 02h,0A0h
		db	0A2h, 0Ah, 00h, 88h, 20h, 26h
		db	 69h, 00h, 20h, 2Bh,0C0h,0A0h
		db	0A2h, 0Bh, 66h, 00h, 02h, 66h
		db	 01h, 0Fh, 00h, 0Ch, 00h, 0Ah
		db	 00h, 0Ah, 00h, 02h, 00h, 02h
		db	 66h, 0Dh, 03h, 2Ah, 88h, 66h
		db	 00h, 80h, 2Ch, 66h, 00h, 20h
		db	 80h, 66h, 00h,0EAh, 00h, 15h
		db	 00h,0AAh, 00h, 55h, 80h, 66h
		db	 00h,0FAh,0A0h, 66h, 00h,0FAh
		db	 80h, 66h, 00h,0EAh, 66h, 00h
		db	 0Bh, 66h, 01h, 02h, 66h, 01h
		db	 03h, 66h, 03h, 02h, 66h, 01h
		db	 03h, 66h, 01h, 03h, 66h, 01h
		db	 3Eh, 66h, 01h, 02h,0A0h,0A2h
		db	 0Bh, 00h, 2Ah, 88h, 66h, 00h
		db	 80h, 2Ch, 66h, 00h, 20h,0A0h
		db	 80h, 10h, 0Ah,0A0h,0A5h, 50h
		db	 66h, 00h,0AFh,0A0h, 66h, 00h
		db	0AFh,0A0h, 66h, 00h,0BEh, 9Ah
		db	 00h,0A2h, 0Bh, 00h, 2Ah, 88h
		db	 66h, 00h, 80h, 2Ch, 66h, 00h
		db	0A0h,0A8h, 40h, 14h,0A3h,0A8h
		db	 50h, 54h, 66h, 00h,0A3h,0E8h
		db	 66h, 00h,0A3h,0E8h, 66h, 00h
		db	0AFh,0A8h,0EFh,0AAh, 0Fh, 80h
		db	0BAh,0AAh, 3Ah,0A1h,0BAh,0A8h
		db	 3Ah, 82h, 3Ah,0F8h,0F8h, 02h
		db	 3Bh,0FEh,0C0h, 00h, 2Eh,0ABh
		db	0C0h, 00h,0BAh, 0Ah, 00h,0A0h
		db	0F8h, 82h, 02h, 68h, 8Bh,0FAh
		db	 8Bh,0FAh,0AAh,0BEh, 2Ah,0BEh
		db	 2Ah,0AAh, 96h,0AAh, 02h,0A8h
		db	0AAh,0A8h,0C2h, 80h, 2Ah, 80h
		db	 8Ah, 00h, 2Ah, 00h, 2Ah, 00h
		db	 0Ah, 00h, 0Ah, 00h, 0Ah, 00h
		db	0F8h, 6Eh, 00h,0BCh,0BAh, 0Ah
		db	 00h,0B0h, 22h,0A8h, 66h, 00h
		db	 38h, 02h, 66h, 00h, 02h, 08h
		db	 3Ch, 66h, 00h, 80h,0FEh, 40h
		db	 66h, 00h,0BAh, 66h, 01h, 2Ah
		db	 80h, 08h, 00h, 08h, 00h, 28h
		db	 00h, 08h, 00h,0AAh, 00h, 25h
		db	 00h,0EAh, 00h, 15h, 00h,0A0h
		db	 00h, 5Bh, 66h, 01h,0FAh,0E0h
		db	 66h, 00h, 3Ah, 80h, 66h, 00h
		db	 28h, 00h,0BAh,0AAh, 3Ah,0A1h
		db	0BAh,0A8h, 3Ah, 82h, 3Ah,0F8h
		db	0F8h, 02h, 3Bh,0FEh,0C0h, 00h
		db	 2Eh,0ABh,0C0h, 00h,0BAh, 0Ah
		db	 00h,0A0h,0F8h, 82h, 02h, 68h
		db	0F8h, 6Eh, 00h,0BCh,0AAh,0BEh
		db	 2Ah,0BEh, 2Ah,0AAh, 96h,0AAh
		db	 02h,0A8h,0AAh,0A8h,0C2h, 80h
		db	 2Ah, 80h, 8Ah, 00h, 2Ah, 00h
		db	 2Ah, 00h, 0Ah, 00h, 0Ah, 00h
		db	 0Ah, 00h, 08h, 00h, 08h, 00h
		db	0BAh, 0Ah, 00h,0B0h, 22h,0A8h
		db	 66h, 00h, 38h, 02h, 66h, 00h
		db	 02h, 08h, 0Ch, 02h, 00h, 0Ah
		db	 3Eh,0A5h, 66h, 00h, 3Eh, 8Fh
		db	 66h, 00h, 0Ah, 8Fh, 66h, 00h
		db	 02h,0AEh, 20h, 66h, 01h, 80h
		db	 66h, 01h,0C0h, 66h, 01h,0A0h
		db	 00h, 50h, 00h,0A0h, 00h, 50h
		db	 66h, 01h,0A0h, 66h, 01h,0A0h
		db	 66h, 01h,0A8h, 00h,0BAh,0A8h
		db	 3Ah, 82h, 3Ah,0F8h,0F8h, 02h
		db	 3Bh,0FEh,0C0h, 00h, 2Eh,0ABh
		db	0C0h, 00h,0BAh, 0Ah, 00h,0A0h
		db	0F8h, 82h, 02h, 68h,0F8h, 6Eh
		db	 00h,0BCh,0BAh, 0Ah, 00h,0B0h
		db	 2Ah,0AAh, 96h,0AAh, 02h,0A8h
		db	0AAh,0A8h,0C2h, 80h, 2Ah, 80h
		db	 8Ah, 00h, 2Ah, 00h, 2Ah, 00h
		db	 0Ah, 00h, 0Ah, 00h, 0Ah, 00h
		db	 08h, 00h, 08h, 00h, 20h, 66h
		db	 01h, 22h,0A8h, 66h, 00h, 38h
		db	 02h, 66h, 00h, 02h, 08h, 66h
		db	 01h,0AAh, 00h, 55h, 00h,0AAh
		db	 03h, 55h, 66h, 00h, 0Eh,0FAh
		db	 66h, 00h, 02h,0FAh, 66h, 01h
		db	0EAh, 80h, 66h, 01h,0E0h, 00h
		db	 20h, 00h,0A0h, 00h,0A0h, 00h
		db	 80h, 00h, 80h, 66h, 0Dh, 80h
		db	 00h,0BAh, 0Ah, 00h,0B0h, 22h
		db	0A8h, 66h, 00h, 38h, 02h, 66h
		db	 00h, 0Ah, 08h, 04h, 02h, 0Ah
		db	0A0h, 05h, 5Ah, 66h, 00h, 0Fh
		db	0AEh, 66h, 00h, 0Fh,0AEh, 66h
		db	 00h, 0Eh,0ABh, 20h, 66h, 01h
		db	 80h, 66h, 01h,0C0h, 66h, 03h
		db	 80h, 66h, 01h, 80h, 66h, 01h
		db	 80h, 66h, 01h,0A8h, 66h, 01h
		db	 80h, 00h,0BAh, 0Ah, 00h,0B0h
		db	 22h,0A8h, 66h, 00h, 38h, 02h
		db	 66h, 00h, 2Ah, 0Ah, 14h, 01h
		db	 2Ah, 8Ah, 15h, 45h, 66h, 00h
		db	 3Eh, 8Eh, 66h, 00h, 3Eh, 8Eh
		db	 66h, 00h, 3Ah,0AEh,0FEh,0AAh
		db	0FEh,0A8h,0AAh,0A8h,0AAh, 97h
		db	 2Ah, 80h, 2Ah,0BFh, 02h, 83h
		db	 02h,0BCh, 38h,0A2h, 38h,0ACh
		db	0EAh,0ABh,0EAh,0A0h,0A2h,0AFh
		db	0A2h,0A0h, 00h, 2Fh, 00h, 20h
		db	0FEh,0AAh,0FEh,0A8h,0AAh,0A8h
		db	0AAh, 97h, 2Ah, 80h, 2Ah,0BFh
		db	 02h, 83h, 02h,0BCh, 00h,0A2h
		db	 00h,0ACh, 00h,0EBh, 00h,0E0h
		db	 03h,0AFh, 03h,0A0h, 03h,0AFh
		db	 03h,0A0h,0AAh,0BEh, 2Ah,0BEh
		db	 2Ah,0AAh, 96h,0AAh, 02h,0A8h
		db	0AAh,0A8h,0C2h, 80h, 2Ah, 80h
		db	 8Ah, 38h, 2Ah, 38h, 2Ah,0AAh
		db	 0Ah,0AAh, 0Ah, 8Ah, 0Ah, 8Ah
		db	 08h, 00h, 08h, 00h,0AAh,0BEh
		db	 2Ah,0BEh, 2Ah,0AAh, 96h,0AAh
		db	 02h,0A8h,0AAh,0A8h,0C2h, 80h
		db	 2Ah, 80h, 8Ah, 00h, 2Ah, 00h
		db	 2Ah, 00h, 0Ah, 00h, 0Bh, 80h
		db	 0Bh, 80h, 0Bh, 80h, 0Bh, 80h
		db	 19h, 00h, 1Ah,0C5h, 01h, 00h
		db	 02h,0E3h, 05h, 00h, 0Ah,0F1h
		db	 00h, 08h, 0Fh,0F9h, 00h, 8Ch
		db	 00h,0EFh, 03h,0E2h, 03h,0FEh
		db	 03h,0F1h, 03h,0FFh, 03h,0B7h
		db	 03h,0FFh, 03h, 5Dh, 6Bh, 9Dh
		db	 01h, 4Eh,0EAh, 8Eh, 00h, 05h
		db	0FEh,0A5h, 66h, 00h, 7Fh, 20h
		db	 66h, 00h,0AFh, 26h, 66h, 00h
		db	 37h, 78h, 80h, 00h, 87h,0E0h
		db	0A0h, 00h,0ADh,0FAh, 02h,0BFh
		db	 02h,0BFh, 03h, 56h, 01h, 56h
		db	 03h,0E8h, 00h, 68h, 0Eh,0A0h
		db	 01h, 40h, 0Eh,0A0h, 01h, 50h
		db	 66h, 00h, 0Fh,0B0h, 66h, 00h
		db	 0Fh,0A0h, 66h, 00h, 3Eh, 00h
		db	 59h, 80h, 58h, 7Ch,0A5h, 20h
		db	0A2h,0DEh, 05h, 70h, 0Ah, 83h
		db	 66h, 00h, 0Dh,0F1h, 66h, 00h
		db	 05h,0F0h, 66h, 01h, 7Ch, 66h
		db	 08h, 09h, 56h, 66h, 00h, 20h
		db	 7Bh, 19h, 00h, 1Ah,0CFh, 01h
		db	 00h, 02h,0F7h, 05h, 00h, 0Ah
		db	0FFh, 66h, 00h, 0Fh,0FDh, 00h
		db	 80h, 00h,0F7h, 03h, 80h, 13h
		db	0FDh, 1Bh,0FDh,0FFh,0FDh, 01h
		db	0B8h,0BFh,0F8h
loc_14:
		add	[si-1],dh
		hlt				; Halt processor
		push	es
		pop	ax
		jg	loc_14			; Jump if >
		add	[si-1],dx
;*		aam	1			; undocumented inst
		db	0D4h, 01h		;  Fixup - byte match
;*		and	bh,dl
		db	 20h,0D7h		;  Fixup - byte match
                           lock	add	[bx+si-51h],ax
		db	0C0h, 66h, 00h, 7Eh,0A0h, 00h
		db	 20h, 01h,0FFh, 00h, 62h, 46h
		db	 7Fh, 03h, 84h, 18h, 1Fh, 0Eh
		db	0A8h, 21h, 5Bh, 0Eh,0A0h, 01h
		db	 5Bh, 66h, 00h, 2Fh,0BAh, 66h
		db	 00h, 8Fh,0B0h, 66h, 00h
data_7		db	3Eh			; Data table (indexed access)
		db	 10h, 66h, 00h,0DFh, 88h, 20h
		db	 00h,0AFh,0D0h, 59h, 80h,0D8h
		db	 70h,0A5h, 20h,0A2h,0D4h, 05h
		db	 70h, 0Ah, 81h, 66h, 00h, 0Dh
		db	0F0h, 66h, 00h, 05h,0F2h, 66h
		db	 01h, 7Ch, 66h, 00h, 04h, 40h
		db	 66h, 04h, 12h, 40h, 66h, 00h
		db	 01h, 84h, 66h, 01h, 61h, 66h
		db	 00h, 21h, 50h, 66h, 01h, 72h
		db	 66h, 00h, 02h, 4Ah, 66h, 00h
		db	 80h, 66h, 02h, 0Ah, 66h, 01h
		db	 06h, 66h, 00h, 9Bh, 00h, 66h
		db	 04h, 08h, 08h, 66h, 01h, 80h
		db	 66h, 00h, 90h, 20h, 66h, 00h
		db	 91h, 7Fh, 00h,0C0h, 03h,0FFh
		db	 07h, 21h, 47h, 3Fh, 01h,0D9h
		db	 3Dh,0DFh, 00h,0DFh, 7Eh,0DFh
		db	 00h, 7Eh, 7Ah, 7Eh, 00h, 75h
		db	 3Dh, 75h, 00h, 20h, 1Ah, 20h
		db	 66h, 00h, 48h, 04h, 02h, 00h
		db	0F2h, 10h, 0Ch,0C0h,0DCh,0C2h
		db	0BAh,0A0h,0FAh,0A0h,0F4h, 00h
		db	0F4h, 7Ch,0A8h, 00h,0A9h,0FAh
		db	 50h, 00h, 57h,0D4h, 08h, 00h
		db	 0Ah,0A0h, 15h,0FFh, 00h, 57h
		db	 37h,0FEh, 0Bh,0AEh, 5Fh,0FEh
		db	 2Ah, 76h,0FFh,0FCh, 59h,0ECh
		db	0FFh,0F9h,0DFh,0F8h,0FFh,0C1h
		db	0FBh,0C2h,0FEh, 1Fh, 7Eh, 05h
		db	0C1h,0FFh,0C0h, 2Bh, 31h, 10h
		db	 31h, 10h, 50h, 40h, 50h, 40h
		db	 00h, 30h, 00h, 10h,0F0h, 00h
		db	0D0h, 00h,0DCh, 30h, 54h, 30h
		db	0D0h, 00h, 90h, 00h, 44h, 00h
		db	 44h, 00h, 70h,0C0h, 50h,0C0h
		db	 3Dh, 10h, 2Dh, 10h, 5Ch, 40h
		db	 54h, 40h, 0Dh, 00h, 0Dh, 00h
		db	0F1h, 00h,0B1h, 00h, 50h, 3Dh
		db	 50h, 35h, 40h,0F4h, 40h,0C4h
		db	 00h,0F4h, 00h, 74h, 00h,0D1h
		db	 00h,0C1h, 3Dh, 00h, 31h, 00h
		db	 5Ch, 40h, 54h, 40h, 0Ch, 00h
		db	 0Ch, 00h,0F0h, 00h,0B0h, 00h
		db	0C0h, 3Ch,0C0h, 2Ch,0C0h,0F4h
		db	0C0h,0D4h, 00h,0F4h, 00h,0B4h
		db	 10h,0D1h, 10h,0D1h, 7Dh, 10h
		db	 35h, 10h, 0Ch, 44h, 0Ch, 44h
		db	 66h, 02h, 30h, 00h, 20h, 00h
		db	 1Fh, 00h, 1Bh, 66h, 00h,0F4h
		db	 00h,0A4h, 04h,0F4h, 04h,0F4h
		db	 00h,0D1h, 00h,0D1h, 66h, 06h
		db	 0Ch, 00h, 0Ch, 66h, 04h,0C3h
		db	 00h,0C0h, 00h, 01h, 00h, 01h
		db	 66h, 02h, 03h, 00h, 02h, 00h
		db	 0Ch, 00h, 04h, 66h, 04h, 0Ch
		db	 00h, 0Ch, 66h, 02h, 43h, 00h
		db	 41h, 00h, 40h, 00h, 40h, 66h
		db	 03h, 10h, 40h, 10h, 40h, 01h
		db	 00h, 01h, 66h, 00h, 10h, 00h
		db	 10h, 66h, 02h, 30h,0C3h, 30h
		db	 43h, 00h, 04h, 00h, 04h, 31h
		db	 00h, 31h, 00h, 0Dh, 3Ch, 05h
		db	 04h, 3Ch,0F4h, 2Ch, 54h, 03h
		db	 53h, 01h, 51h, 3Dh, 40h, 29h
		db	 40h, 35h, 00h, 35h, 00h, 04h
		db	 34h, 04h, 24h, 00h, 75h, 00h
		db	 55h,0F0h, 14h, 90h, 14h, 1Dh
		db	 01h, 15h, 01h, 40h,0C4h, 40h
		db	0C4h, 66h, 03h, 03h, 00h, 02h
		db	 00h, 01h, 00h, 01h, 00h,0C0h
		db	 00h,0C0h, 66h, 02h, 31h, 00h
		db	 31h, 00h, 0Dh, 3Ch, 09h, 14h
		db	 3Ch,0D5h, 24h, 54h, 03h, 00h
		db	 03h, 00h, 40h, 0Ch, 40h, 04h
		db	 4Ch, 00h, 4Ch, 66h, 00h, 03h
		db	 00h, 01h, 0Dh, 04h, 01h, 04h
		db	0F4h, 74h,0A4h, 54h, 1Dh, 31h
		db	 15h, 31h, 4Ah,0E4h, 48h, 84h
		db	 00h, 02h, 00h, 03h, 00h, 1Ah
		db	 00h, 56h, 00h,0B6h, 00h,0B5h
		db	 00h,0FAh, 01h, 87h, 01h,0DFh
		db	 01h,0BFh, 01h,0D0h, 01h,0B2h
		db	 02h,0BFh, 02h,0FFh, 0Dh,0A0h
		db	 0Dh, 64h,0D4h, 00h,0BCh, 00h
		db	 7Bh, 00h,0FBh, 00h,0FEh, 80h
		db	0FEh, 80h, 2Ah, 80h,0FEh, 80h
		db	0FCh,0C0h,0FCh,0C0h, 24h,0E0h
		db	 6Ch,0E0h,0FEh,0D8h,0FEh,0D8h
		db	 00h, 74h,0AAh, 74h, 11h,0BFh
		db	 11h, 7Fh, 23h,0A0h, 2Fh, 6Ah
		db	 51h, 7Fh, 50h,0FFh, 51h, 61h
		db	 50h,0EBh, 43h, 7Fh, 46h,0FFh
		db	 45h, 00h, 4Dh, 00h, 5Ch, 00h
		db	 5Ch, 00h, 9Eh, 6Dh, 9Eh, 6Dh
		db	0FEh, 34h,0FEh, 34h, 0Eh, 54h
		db	 1Eh, 54h,0F3h, 1Ah,0F7h, 1Ah
		db	0C8h, 0Ah,0D9h, 0Ah,0FFh, 0Ah
		db	0FFh, 0Ah, 00h, 0Ah, 00h, 0Ah
		db	 00h, 65h, 00h, 65h, 52h,0F5h
		db	 52h,0F5h, 66h, 0Bh, 32h, 03h
		db	0FFh, 05h, 7Fh, 1Fh,0FFh, 2Fh
		db	0D5h, 7Fh,0D5h,0FAh,0AAh,0FAh
		db	0AAh,0F5h, 55h,0F5h, 55h, 66h
		db	 0Ah,0FDh, 00h,0FDh, 00h,0CAh
		db	0A0h,0EAh,0A0h, 55h, 54h, 55h
		db	 54h, 6Fh, 02h, 55h, 55h, 55h
		db	 55h, 66h, 07h, 25h, 00h, 3Fh
		db	 02h, 37h, 03h,0FFh, 16h,0FDh
		db	 1Fh,0FFh, 3Eh,0AAh, 3Eh,0AAh
		db	 75h, 55h, 75h, 55h,0EAh,0AAh
		db	0EAh,0AAh, 66h, 06h,0F0h, 00h
		db	0F0h, 00h, 2Ah, 00h,0EAh, 00h
		db	 55h, 50h, 55h, 50h,0AAh,0A8h
		db	0AAh,0A8h, 55h, 54h, 55h, 54h
		db	 6Fh, 02h, 66h, 0Bh, 07h, 00h
		db	 07h, 00h, 7Dh, 00h, 7Dh, 01h
		db	0F5h, 01h,0F5h, 07h, 55h, 07h
		db	 55h, 0Ch, 05h, 0Ch, 05h, 66h
		db	 08h, 0Ch, 30h,0C0h, 00h,0C3h
		db	 30h, 00h,0C4h, 00h
		db	'4@', 0Ch, 'D<@', 0Ch, 'W|'
		db	 00h, 14h, 75h, 14h, 00h, 25h
		db	 00h, 3Fh, 00h, 91h, 00h,0FFh
		db	 02h, 3Eh, 03h,0FFh, 02h,0DFh
		db	 03h,0FFh, 03h,0F7h, 07h,0FFh
		db	 02h,0FFh, 03h,0FFh, 05h, 7Fh
		db	 07h,0FFh, 1Ah,0AAh, 1Ah,0AAh
		db	 74h, 00h
loc_15:
		hlt				; Halt processor
;*		add	bh,bl
		db	 00h,0DFh		;  Fixup - byte match
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
;*		add	ch,bh
		db	 00h,0FDh		;  Fixup - byte match
		inc	ax
		std				; Set direction flag
		inc	ax
		test	byte ptr ds:data_13e[bx+si],0FDh
		inc	ax
		std				; Set direction flag
		inc	ax
;*		jmp	far ptr loc_18		;*
		db	0EAh
		dw	0EA80h, 5580h		;  Fixup - byte match
			                        ;* No entry point to code
		inc	ax
		push	bp
		inc	ax
		stosb				; Store al to es:[di]
		test	al,0AAh
		test	al,66h			; 'f'
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		cmp	[bx+si],ax
		aas				; Ascii adjust
;*		add	bl,dl
		db	 00h,0D3h		;  Fixup - byte match
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		add	bx,ds:data_22e
		push	es
		das				; Decimal adjust
		pop	es
		jmp	word ptr [bp+0Eh]	;*
			                        ;* No entry point to code
		out	dx,al			; port 0FAC0h ??I/O Non-standard
;*		add	dh,bh
		db	 00h,0FEh		;  Fixup - byte match
;*		add	ch,bh
		db	 00h,0FDh		;  Fixup - byte match
		inc	ax
		std				; Set direction flag
		inc	ax
		mov	si,data_21e
		mov	al,ds:data_11e
		inc	word ptr [bx+si+4]
		db	 6Dh, 07h,0FFh, 05h, 9Fh, 07h
		db	0FFh, 06h,0FFh, 07h,0FFh, 03h
		db	0FFh, 03h,0FFh, 01h,0BFh, 01h
		db	0FFh, 01h, 3Eh, 01h,0FEh, 02h
		db	0E5h, 03h,0E5h, 0Eh,0AAh, 0Eh
		db	0AAh,0FEh,0A0h,0FEh,0A0h,0FFh
		db	 40h,0FFh, 40h,0FEh,0A0h,0FEh
		db	0A0h,0FAh, 80h,0FAh, 80h,0EAh
		db	 80h,0EAh, 80h,0AAh, 80h,0AAh
		db	 80h, 55h, 40h, 55h, 40h,0AAh
		db	0B0h,0AAh,0B0h, 00h, 14h, 00h
		db	 1Fh, 00h, 05h, 00h, 3Fh, 00h
		db	 8Bh, 00h,0FFh, 01h, 2Fh, 01h
		db	0FFh, 01h, 5Fh, 01h,0FFh, 06h
		db	0F7h, 07h,0FFh, 1Bh,0BFh, 1Fh
		db	0FFh,0FDh, 55h,0FDh, 55h,0B8h
		db	 00h,0F8h, 00h, 76h, 00h,0FEh
		db	 00h,0FFh, 00h,0FFh, 00h, 7Eh
		db	 80h,0FEh, 80h,0FEh, 80h,0FEh
		db	 80h,0FDh, 20h,0FDh, 20h,0AAh
		db	0A8h,0AAh,0A8h, 55h, 55h, 55h
		db	 55h, 02h, 28h, 03h,0F8h, 01h
		db	 3Ah, 07h,0FEh, 12h, 5Fh, 1Fh
		db	0FFh, 23h,0EFh, 3Fh,0FFh, 2Fh
		db	0BFh, 3Fh,0FFh, 57h,0FFh, 7Fh
		db	0FFh, 5Bh,0FEh, 7Fh,0FEh,0FDh
		db	 55h,0FDh, 55h, 66h, 0Ah,0C0h
		db	 00h,0C0h, 00h,0D0h, 00h,0D0h
		db	 00h,0D4h, 00h,0D4h, 00h,0AAh
		db	0A0h,0AAh,0A0h, 55h, 55h, 55h
		db	 55h, 66h, 0Bh, 02h, 00h, 03h
		db	 00h, 0Fh, 00h, 0Fh, 00h, 2Bh
		db	 00h, 3Fh, 06h,0BFh, 07h,0FFh
data_9		db	0FEh
		db	0AAh,0FEh,0AAh, 12h,0C0h, 1Fh
		db	0C0h, 49h,0A0h, 7Fh,0E0h, 97h
		db	0D8h,0FFh,0D8h,0DFh, 68h,0FFh
		db	0E8h, 6Bh,0D4h,0FFh,0D4h,0DEh
		db	0AAh,0FEh,0AAh,0D5h, 54h,0D5h
		db	 54h, 6Fh, 02h, 0Ch, 00h, 0Ch
		db	 01h, 66h, 01h, 07h, 66h, 01h
		db	 55h, 00h, 01h, 00h, 01h, 66h
		db	 0Fh, 10h,0DDh, 10h, 66h, 00h
		db	 54h, 00h, 5Ch, 00h, 5Ch, 00h
		db	0C7h, 30h,0C7h, 30h, 30h,0C0h
		db	 30h,0C0h, 41h, 00h, 41h, 66h
		db	 07h, 01h, 1Fh, 00h, 1Eh, 88h
		db	0DFh, 00h,0F8h, 03h,0F7h, 07h
		db	 4Ch, 2Fh,0FEh, 0Dh,0E1h, 07h
		db	0FFh, 06h,0F3h, 16h,0FFh, 07h
		db	0C8h, 05h, 7Fh, 07h,0BDh, 1Ah
		db	0AAh, 1Ah,0AAh,0F6h, 10h, 76h
		db	 00h,0F7h,0A0h,0EEh, 80h, 3Dh
		db	0D4h,0ECh, 50h,0FEh,0ECh,0ACh
		db	0A8h,0FDh, 7Ch, 55h, 54h,0FEh
		db	0F8h,0EAh,0A8h, 55h, 48h, 55h
		db	 40h,0AAh,0ACh,0AAh,0A8h, 00h
		db	 13h, 00h, 1Fh, 00h, 20h, 00h
		db	 60h, 00h, 0Ah, 00h, 3Eh, 02h
		db	 37h, 03h,0FFh, 08h, 7Dh, 18h
		db	 7Dh, 00h, 1Eh, 00h, 1Eh, 2Bh
		db	0CEh, 2Fh, 0Eh, 59h, 17h, 78h
		db	 04h, 80h, 00h, 80h, 00h, 17h
		db	 80h, 1Fh, 80h, 04h,0F8h, 07h
		db	0F8h, 00h,0B8h, 00h,0F8h, 5Ch
		db	 2Dh, 1Ch, 2Dh, 81h, 2Fh, 01h
		db	 3Fh,0D4h, 5Ah, 00h, 5Ah,0E8h
		db	0FAh, 00h,0FAh,0B1h, 2Fh,0F1h
		db	 00h,0E1h, 57h,0E1h,0C0h,0A0h
		db	 2Bh,0E0h, 00h, 70h, 56h, 70h
		db	 00h, 0Bh, 09h, 0Bh, 00h, 05h
		db	0C1h, 07h,0C1h, 21h,0E0h, 21h
		db	0E0h, 1Ah,0BCh, 1Ah,0BCh,0F4h
		db	0B8h, 00h,0F8h,0FAh, 10h, 00h
		db	 10h,0EAh, 35h, 62h, 35h, 52h
		db	 2Bh, 02h, 2Fh, 04h, 16h, 0Ch
		db	 1Eh, 59h, 64h,0F9h, 64h, 01h
		db	 60h, 01h, 60h, 02h,0A4h, 02h
		db	0A4h, 84h, 66h, 01h, 19h, 4Ch
		db	 18h, 00h, 62h, 02h, 20h, 00h
		db	 49h, 68h, 48h, 00h, 20h, 83h
		db	 20h, 00h, 4Ah, 20h, 66h, 04h
		db	0CFh, 20h, 66h, 00h, 25h, 00h
		db	 01h, 66h, 00h, 8Ch, 66h, 00h
		db	0D4h, 34h, 66h, 00h, 2Ah, 94h
		db	 00h, 04h, 31h, 40h, 66h, 00h
		db	 0Dh,0B1h, 00h, 01h, 02h, 86h
		db	 00h, 02h, 00h,0CCh, 66h, 00h
		db	 14h, 00h, 10h, 00h, 4Bh, 00h
		db	 08h, 00h, 15h, 66h, 01h, 04h
		db	0C2h, 66h, 00h, 01h, 21h, 66h
		db	 00h, 08h, 4Ch, 00h, 04h, 40h
		db	 04h, 40h, 00h, 28h, 00h, 28h
		db	 00h, 02h,0E0h, 66h, 00h, 01h
		db	 02h, 66h, 00h, 04h,0D0h, 00h
		db	 10h, 01h, 28h, 66h, 00h, 4Ch
		db	 80h, 66h, 00h, 45h, 14h, 01h
		db	 04h, 88h, 0Ch, 08h, 00h, 08h
		db	 80h, 66h, 11h, 20h, 00h, 10h
		db	 03h, 88h, 00h,0B4h, 02h, 80h
		db	 02h,0AEh, 20h, 00h, 1Ch, 2Ah
		db	 66h, 1Ah, 20h, 00h,0D0h, 00h
		db	 80h, 00h, 7Fh,0EFh,0FBh, 00h
		db	 04h, 3Ah, 1Eh,0C0h, 01h, 2Ah
		db	 03h, 63h, 00h, 98h, 00h,0E3h
		db	 00h, 18h, 00h, 01h, 00h, 2Ah
		db	 66h, 01h,0EAh, 66h, 00h, 03h
		db	0ABh, 02h, 00h,0ADh, 66h, 01h
		db	0FAh,0C0h,0E8h, 20h, 17h, 90h
		db	 80h, 00h, 7Fh,0F8h, 66h, 00h
		db	0EEh,0D8h, 66h, 00h,0F3h,0AAh
		db	 80h, 00h, 7Ah,0A8h, 66h, 00h
		db	0EAh, 69h, 00h, 00h, 7Fh,0EFh
		db	0FBh, 00h, 04h, 3Ah, 7Eh,0C0h
		db	 01h, 2Ah, 3Fh, 63h, 00h, 98h
		db	 07h,0E3h, 00h, 18h, 00h, 01h
		db	 00h, 2Ah, 66h, 01h,0EAh, 66h
		db	 00h, 03h,0ABh, 80h, 00h, 7Fh
		db	0EFh, 04h, 66h, 00h, 3Ah, 04h
		db	 66h, 00h, 2Ah, 04h, 23h, 00h
		db	 58h, 08h, 83h, 00h, 58h, 3Dh
		db	 01h, 02h, 2Ah, 66h, 01h,0EAh
		db	 66h, 00h, 03h,0ABh, 00h, 20h
		db	 00h, 10h, 03h, 88h, 00h,0B4h
		db	 02h, 80h, 02h,0AEh, 20h, 00h
		db	 1Ch, 2Ah, 80h, 02h, 7Fh,0EDh
		db	 7Eh,0D0h, 01h, 27h, 0Fh,0A0h
		db	 00h, 4Fh, 02h, 80h,0C1h, 3Eh
		db	 66h, 08h,0C0h, 00h, 20h, 00h
		db	0DFh, 00h, 02h, 00h,0A9h,0C0h
		db	 66h, 00h,0FAh,0B0h, 66h, 00h
		db	0AFh,0A8h, 66h, 00h,0FAh,0EAh
		db	 66h, 00h, 3Fh,0FBh, 66h, 00h
		db	0CFh,0A0h, 66h, 16h,0A3h, 40h
		db	 5Ch,0BAh,0AEh, 00h
		db	51h
loc_16:
		cli				; Disable interrupts
		or	al,0
		add	bx,ax
		push	es
		add	[bx+di],al
		call	sub_1
		add	sp,[bx+si+66h]
		add	data_5[bx+si],sp
		sub	ah,[bp+1]
		or	[bx+si],al
		and	[bx+si],al
		adc	[bp+di],al
		mov	[bx+si],al
		mov	ah,2
		add	byte ptr [bp+si],0AEh
		and	[bx+si],al
		sbb	al,2Ah			; '*'
		add	byte ptr [bp+si],7Fh
		in	ax,dx			; port 0FAC0h ??I/O Non-standard
		jle	loc_16			; Jump if < or =
		add	[bx+di],bp
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		call	$+1303h
;*		add	ax,dx
		db	 01h,0D0h		;  Fixup - byte match
		add	[bp+di],ch
;*		add	[bx+si+0],dl
		db	 00h, 50h, 00h		;  Fixup - byte match
		db	 26h, 00h, 40h, 00h, 1Eh, 66h
		db	 00h, 03h,0F4h, 66h, 00h, 35h
		db	0A0h, 66h, 00h, 0Ch, 66h, 0Bh
		db	 8Bh, 00h
		db	74h
loc_17:
		cli				; Disable interrupts
		mov	sp,4300h
		stosb				; Store al to es:[di]
		jo	$+2			; delay for I/O
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		db	 68h, 60h, 00h, 1Eh,0A0h, 40h
		db	 00h, 3Ah, 66h, 01h, 3Ch, 66h
		db	 01h, 0Eh, 66h, 01h, 08h, 66h
		db	 04h, 20h, 00h, 10h, 03h, 88h
		db	 00h,0B4h, 02h

_357UNKN	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		add	byte ptr [bp+si],0AEh
		and	[bx+si],al
		sbb	al,2Ah			; '*'
		add	byte ptr [bp+si],7Fh
		in	ax,dx			; port 0FAC0h ??I/O Non-standard
		jle	loc_17			; Jump if < or =
		add	[bp+di],bp
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		call	$+1303h
		db	 66h, 0Ch,0C0h, 00h, 20h, 00h
		db	0DFh, 00h, 02h, 00h,0A9h,0C0h
		db	 66h, 00h,0FAh,0B0h, 66h, 00h
		db	0AFh,0A8h, 00h,0B4h, 00h, 43h
		db	 00h, 08h, 00h, 06h, 00h, 10h
		db	 00h, 4Eh, 66h, 01h, 7Ah, 66h
		db	 00h, 01h,0E8h, 66h, 00h, 16h
		db	 80h, 66h, 00h, 02h, 80h, 66h
		db	 02h, 0Eh, 20h,0B1h,0DAh, 38h
		db	 00h,0C6h,0DAh, 30h, 00h,0CDh
		db	 6Ah, 10h, 00h, 2Eh,0A8h, 66h
		db	 00h, 3Ah, 80h, 66h, 00h, 68h
		db	 66h, 01h,0C0h, 66h, 0Ch, 20h
		db	 00h, 10h, 03h, 88h, 00h,0B4h
		db	 02h, 80h, 02h,0AEh, 20h, 00h
		db	 1Ch, 2Ah, 80h, 02h, 7Fh,0EDh
		db	 7Eh,0D0h, 01h, 23h, 66h, 10h
		db	0C0h, 00h, 20h, 00h,0DFh, 00h
		db	 02h, 00h,0A9h,0C0h, 66h, 00h
		db	0FAh,0B0h, 0Fh,0A4h, 00h, 53h
		db	 00h,0D4h, 00h, 23h, 00h, 28h
		db	 00h, 06h, 00h, 10h, 00h, 2Eh
		db	 00h, 20h, 00h, 1Ah, 66h, 01h
		db	0E8h, 66h, 00h, 02h,0A0h, 66h
		db	 00h, 08h, 80h, 66h, 00h,0AFh
		db	0A8h, 0Eh,0A0h,0B1h, 5Ah, 38h
		db	 00h,0C7h,0DAh, 30h, 00h, 8Eh
		db	0EAh, 08h, 00h, 16h, 68h, 66h
		db	 00h, 0Eh, 80h, 66h, 00h, 3Ah
		db	 66h, 01h,0A0h, 00h, 57h,0F8h
		db	 57h,0A8h, 0Ah,0AFh, 0Ah,0AEh
		db	 01h, 55h, 01h, 55h, 00h, 2Ah
		db	 00h, 2Ah, 00h, 10h, 00h, 10h
		db	 66h, 03h, 02h, 00h, 02h, 66h
		db	 06h, 80h, 02h, 80h, 00h, 40h
		db	 0Bh, 40h, 0Ah,0A0h, 15h, 80h
		db	 14h, 70h, 14h, 70h,0D7h,0A0h
		db	 44h,0A0h, 77h,0ACh,0CCh,0ACh
		db	0C3h, 53h, 00h, 53h, 43h, 66h
		db	 0Dh, 30h, 66h, 01h, 05h, 66h
		db	 0Ah,0D4h, 00h,0D5h, 77h, 66h
		db	 00h, 07h, 50h, 66h, 00h, 1Dh
		db	0D0h, 66h, 00h, 75h, 40h, 05h
		db	0C0h, 55h,0C0h, 1Ch, 73h, 1Ch
		db	 73h, 03h, 0Ch, 03h, 0Ch, 04h
		db	 10h, 04h, 10h, 66h, 1Bh, 06h
		db	 00h, 09h, 66h, 0Eh, 04h, 00h
		db	 08h, 00h, 31h,0C0h, 0Dh, 80h
		db	 41h, 40h, 35h, 40h, 00h, 04h
		db	 54h, 38h, 00h, 60h, 00h, 97h
		db	 02h, 00h, 01h, 5Fh, 08h, 7Ah
		db	 05h, 85h, 21h, 80h, 1Eh, 7Fh
		db	 66h, 00h, 5Bh, 67h, 66h, 00h
		db	 55h, 9Fh, 66h, 00h, 15h, 75h
		db	 66h, 01h, 57h, 00h, 01h,0F7h
		db	0FEh, 00h,0DFh, 5Dh, 20h, 05h
		db	0F8h, 52h, 00h, 0Ah,0E0h,0D5h
		db	 00h, 05h, 00h, 92h, 66h, 01h
		db	 34h, 66h, 01h, 57h, 66h, 01h
		db	0D5h,0C0h, 00h, 01h,0F7h,0FEh
		db	 00h,0DFh, 5Dh, 20h, 05h,0FEh
		db	 52h, 00h, 0Ah,0FCh,0D5h, 00h
		db	 05h, 40h, 92h,0A0h, 66h, 00h
		db	 34h, 66h, 01h, 57h, 66h, 01h
		db	0D5h,0C0h, 00h, 01h,0F7h,0FEh
		db	 00h, 20h, 5Ch, 66h, 00h, 20h
		db	 54h, 00h, 06h, 00h,0D8h, 20h
		db	 03h, 00h, 98h, 10h, 00h,0B0h
		db	 34h, 4Ch, 66h, 00h, 57h, 66h
		db	 01h,0D5h,0C0h, 66h, 07h, 02h
		db	 00h, 01h, 00h, 74h, 00h, 8Bh
		db	 03h, 40h, 00h, 95h, 08h, 00h
		db	 05h, 5Fh, 20h, 00h, 15h,0F5h
		db	 80h, 00h, 57h, 5Fh, 08h, 00h
		db	 04h, 00h, 31h,0C0h, 0Dh, 80h
		db	 01h, 40h, 75h, 40h, 00h, 04h
		db	 54h, 38h, 40h, 01h,0B7h,0FEh
		db	 05h, 7Fh,0CAh, 80h, 05h,0F8h
		db	0EAh, 00h, 01h, 40h, 78h, 83h
		db	 03h, 40h, 5Ch,0BAh, 0Ch, 00h
		db	 53h,0FBh, 08h, 00h, 17h,0D0h
		db	 66h, 00h, 17h,0A0h, 08h, 00h
		db	 06h,0C0h, 66h, 00h, 0Dh, 00h
		db	 80h, 00h, 74h, 66h, 01h, 10h
		db	 66h, 01h,0DFh,0FCh, 66h, 00h
		db	 05h,0F3h, 66h, 16h, 08h, 00h
		db	 04h, 00h, 31h,0C0h, 0Dh, 80h
		db	 01h, 40h, 75h, 40h, 00h, 04h
		db	 54h, 38h, 40h, 01h,0B7h,0FEh
		db	 15h,0FFh,0CAh, 00h, 15h,0F8h
		db	0CAh, 00h, 25h, 40h,0CAh, 80h
		db	 01h,0D1h, 5Eh, 2Eh, 0Ch, 01h
		db	 51h,0FEh, 04h, 00h, 1Bh,0FAh
		db	 66h, 00h, 05h, 7Ch, 66h, 01h
		db	 5Ah, 66h, 01h, 34h, 00h, 80h
		db	 00h, 70h, 66h, 01h, 10h, 0Ah
		db	 00h, 70h, 00h, 02h, 00h, 7Ch
		db	 66h, 01h, 2Fh,0C0h, 66h, 00h
		db	 05h,0ACh, 66h, 01h, 30h, 66h
		db	 17h, 02h, 00h, 01h, 00h, 74h
		db	 00h, 8Bh, 03h, 40h, 00h, 95h
		db	 08h, 00h, 05h, 5Fh, 20h, 00h
		db	 15h,0F5h, 66h, 02h, 08h, 00h
		db	 04h, 00h, 31h,0C0h, 0Dh, 80h
		db	 01h, 40h, 75h, 40h, 00h, 04h
		db	 54h, 38h, 40h, 01h,0B7h,0FEh
		db	 15h, 7Fh,0CAh, 80h, 15h,0F8h
		db	0CAh, 00h, 84h, 68h, 5Bh, 95h
		db	 06h, 00h, 59h,0FFh, 66h, 00h
		db	 57h, 7Fh, 66h, 00h, 15h, 7Ch
		db	 66h, 00h, 01h, 5Ch, 66h, 01h
		db	 16h, 66h, 01h, 03h, 66h, 02h
		db	 25h, 40h, 4Ah, 80h, 15h, 00h
		db	 42h, 00h, 08h, 00h, 72h, 66h
		db	 01h, 5Eh, 66h, 01h, 17h, 80h
		db	 66h, 00h, 01h, 68h, 66h, 00h
		db	 01h, 40h, 66h, 13h, 02h, 00h
		db	 01h, 00h, 68h, 00h, 97h, 03h
		db	 40h, 00h, 95h, 08h, 00h, 05h
		db	 5Fh, 66h, 06h, 08h, 00h, 04h
		db	 00h, 31h,0C0h, 0Dh, 80h, 01h
		db	 40h, 75h, 40h, 00h, 04h, 54h
		db	 38h, 40h, 01h,0B7h,0FEh, 15h
		db	 7Fh,0CAh, 80h, 20h, 00h, 15h
		db	0F5h, 85h, 80h, 5Ah, 71h, 0Ch
		db	 00h, 53h,0FDh, 08h, 00h, 57h
		db	 7Dh, 66h, 00h, 14h,0F8h, 66h
		db	 00h, 05h, 70h, 66h, 00h, 01h
		db	 5Ch, 66h, 01h, 15h, 25h,0F8h
		db	0CAh, 00h, 2Bh, 00h, 44h, 80h
		db	 04h, 00h, 6Ah, 66h, 01h, 74h
		db	 00h, 04h, 00h, 58h, 66h, 01h
		db	 17h, 66h, 01h, 05h, 40h, 66h
		db	 00h, 01h, 10h, 66h, 0Bh, 03h
		db	 00h, 03h, 00h, 07h, 00h, 07h
		db	 00h, 0Fh, 00h, 0Fh, 00h, 0Dh
		db	 00h, 1Dh, 00h, 0Ah, 00h, 7Ah
		db	 66h, 00h,0C3h, 66h, 01h, 33h
		db	 00h, 0Ch, 00h, 03h, 66h, 01h
		db	 43h, 66h, 01h, 77h, 00h,0C1h
		db	 40h,0D1h, 40h,0F1h, 60h,0F1h
		db	 60h,0FCh, 50h,0F4h, 40h, 00h
		db	 05h, 01h, 55h, 00h, 1Ch, 04h
		db	 1Ch, 00h, 03h, 06h, 03h, 00h
		db	 04h, 00h, 04h, 66h, 0Eh, 5Fh
		db	 58h, 5Dh, 58h,0AFh, 58h,0AFh
		db	 58h, 17h, 14h, 17h, 14h, 0Bh
		db	0D4h, 0Bh,0D4h, 03h,0D4h, 03h
		db	0D4h, 00h,0C4h, 00h,0C4h, 00h
		db	 30h, 00h, 30h, 66h, 0Bh, 41h
		db	 00h, 40h, 0Ah, 12h, 0Ah, 10h
		db	 02h, 25h, 01h,0A5h, 18h, 85h
		db	 04h,0E1h, 47h,0F4h,0A7h,0F6h
		db	 0Ch, 71h, 72h, 79h, 66h, 02h
		db	 69h, 00h, 01h, 40h, 2Bh, 00h
		db	0A9h, 80h,0C5h, 20h,0C9h,0A0h
		db	 62h, 52h,0D3h, 51h, 8Eh,0ACh
		db	0CFh,0A3h,0FEh,0E0h,0FFh, 1Ah
		db	0F6h, 00h,0FDh,0D0h, 00h, 47h
		db	 0Fh,0A7h, 00h, 13h, 00h, 2Bh
		db	 06h, 01h, 09h, 4Dh, 0Ch, 00h
		db	 33h,0A3h, 66h, 00h, 1Fh,0D4h
		db	 66h, 00h, 0Ah,0FAh, 66h, 01h
		db	 5Fh, 18h, 00h, 26h,0A0h,0C0h
		db	 00h,0FCh, 30h, 66h, 00h,0CAh
		db	0A0h, 08h, 01h, 3Dh, 40h,0C7h
		db	 42h, 38h,0B1h, 18h, 00h, 37h
		db	 5Ah, 66h, 00h,0FAh,0BCh, 40h
		db	 00h,0F5h, 18h, 66h, 00h,0A8h
		db	 08h, 40h, 90h, 40h, 90h, 08h
		db	 00h, 08h, 66h, 00h, 40h, 00h
		db	 40h, 00h, 09h, 00h, 09h, 04h
		db	 56h, 04h, 56h, 01h, 2Fh, 01h
		db	 2Fh, 40h, 7Fh, 40h, 7Fh, 05h
		db	 7Fh, 05h, 7Fh, 44h, 00h, 44h
		db	 00h, 20h, 12h, 20h, 12h, 30h
		db	 80h, 30h, 80h, 45h, 12h, 45h
		db	 12h,0ABh, 40h,0ABh, 40h,0D3h
		db	0CAh,0D3h,0CAh,0EFh, 94h,0EFh
		db	0BFh,0A9h,0A8h,0EBh,0EEh, 12h
		db	0EEh, 12h,0EFh, 0Ah, 6Bh, 0Ah
		db	 7Fh, 11h, 8Fh, 17h,0CFh, 07h
		db	0FFh,0D7h,0FFh, 01h,0E3h, 31h
		db	0F7h, 00h, 03h, 0Ah,0FBh, 00h
		db	 01h, 00h, 5Fh, 18h, 00h, 26h
		db	0A0h, 74h, 58h, 7Ch, 5Ch, 79h
		db	0F0h, 7Dh,0FEh, 7Eh, 70h, 7Eh
		db	 7Fh,0F9h, 30h,0FBh,0FFh,0D8h
		db	 10h,0F7h, 5Ah, 68h, 00h,0FAh
		db	0BCh, 70h, 00h,0F5h, 18h, 30h
		db	 00h,0B8h, 08h, 66h, 05h, 28h
		db	 66h, 05h, 1Bh, 00h, 04h, 08h
		db	 37h, 66h, 01h,0CEh, 00h, 05h
		db	 00h,0F7h, 3Fh, 02h, 25h,0D7h
		db	 66h, 03h,0C0h, 00h, 40h, 03h
		db	 70h,0C2h, 70h, 0Ah,0B8h, 0Ah
		db	0B8h, 35h, 54h,0B5h, 54h, 0Ah
		db	0AAh,0DAh,0AAh, 45h, 56h, 65h
		db	 56h, 80h, 2Ah,0B0h, 2Ah, 00h
		db	 80h, 00h, 80h, 00h, 44h, 00h
		db	 44h, 10h, 02h, 10h, 02h, 66h
		db	 01h, 3Ch, 00h,0FCh, 33h,0FFh
		db	 00h, 0Fh, 0Fh,0FFh, 0Fh,0F0h
		db	0FFh,0FEh, 66h, 00h, 0Eh,0A4h
		db	 66h, 02h, 05h, 10h, 05h, 10h
		db	 00h, 48h, 00h, 48h, 66h, 00h
		db	0C0h, 00h,0C0h, 00h,0E8h,0D8h
		db	0FCh, 00h,0FEh,0B4h, 0Fh,0F0h
		db	0AFh,0FCh, 66h, 00h, 0Dh, 52h
		db	 00h, 32h, 00h, 32h, 00h, 08h
		db	 00h, 08h, 66h, 01h, 03h, 00h
		db	 0Eh, 00h, 06h, 00h, 0Fh, 00h
		db	 0Fh, 00h, 3Fh, 00h, 1Fh, 00h
		db	 3Fh, 00h, 1Fh, 00h, 3Fh, 00h
		db	 3Fh, 32h, 00h, 32h, 00h, 08h
		db	 00h,0C8h, 66h, 01h,0A0h, 00h
		db	 2Ch, 00h,0ACh, 00h,0B8h, 00h
		db	0B8h, 00h,0BAh, 00h,0BAh, 00h
		db	0AAh, 00h,0AAh, 00h,0EAh, 00h
		db	0EAh, 66h, 00h, 3Fh, 00h, 3Fh
		db	 00h, 0Ah, 00h, 0Ah, 66h, 01h
		db	 03h, 66h, 01h, 02h, 66h, 01h
		db	 0Fh, 66h, 01h, 0Ch, 66h, 06h
		db	0AAh, 00h,0AAh, 00h, 28h, 00h
		db	0E8h, 66h, 01h,0B0h, 66h, 01h
		db	0D0h, 66h, 01h,0BCh, 66h, 01h
		db	 0Ch, 66h, 1Bh, 0Ch, 0Fh, 0Ch
		db	 07h, 03h, 3Eh, 03h, 1Eh, 0Ch
		db	0FAh, 0Ch,0FAh, 66h, 12h,0F0h
		db	 00h,0F0h, 00h,0AAh, 00h,0AAh
		db	 00h,0AAh, 80h,0AAh, 80h, 00h
		db	0C0h, 00h,0CAh, 0Fh, 00h, 0Fh
		db	 2Ah, 00h,0F0h, 00h,0FAh, 00h
		db	0AFh, 00h,0AFh, 00h, 2Ah, 00h
		db	 2Ah, 00h, 02h, 00h, 02h, 66h
		db	 06h, 2Ah, 80h,0AAh, 80h, 02h
		db	 00h,0AAh, 66h, 01h,0EAh, 08h
		db	0C3h, 00h,0E0h,0A0h, 80h, 00h
		db	0A0h, 80h,0A0h, 00h,0AAh,0A8h
		db	 66h, 1Bh, 0Fh, 00h, 07h, 00h
		db	0FFh, 00h, 7Fh, 03h,0EAh, 03h
		db	0EAh, 66h, 12h,0F0h, 30h,0F0h
		db	 30h,0A8h,0C0h,0A8h,0C0h,0AAh
		db	 30h,0AAh, 30h, 03h,0A0h, 03h
		db	0AAh, 00h, 80h, 00h,0AAh, 66h
		db	 00h, 30h,0ABh, 8Dh, 00h, 0Ch
		db	 3Bh, 00h, 0Eh, 02h, 2Eh, 00h
		db	 0Ah, 3Ah,0AAh, 66h, 06h, 02h
		db	 00h,0A2h, 66h, 00h,0F0h,0A8h
		db	0F0h, 03h, 00h,0ABh, 00h,0FAh
		db	 00h,0FAh, 00h,0A8h, 00h,0A8h
		db	 00h, 80h, 00h, 80h, 66h, 11h
		db	 0Ch, 30h, 00h, 03h, 0Ch,0C3h
		db	 23h, 00h, 2Ch, 00h, 30h, 02h
		db	 3Ch, 22h, 30h, 02h, 3Eh,0EAh
		db	 28h, 00h, 28h,0AEh, 66h, 0Ah
		db	0E0h, 00h,0E0h, 00h,0BEh, 00h
		db	0BEh, 00h,0AFh, 80h,0AFh, 80h
		db	0AAh,0E0h,0AAh,0E0h,0A0h, 30h
		db	0A0h, 30h, 08h, 00h, 08h,0BBh
		db	 66h, 01h, 2Ah, 00h, 3Ah, 00h
		db	 3Ah, 0Ch,0E3h, 0Ch,0E3h, 03h
		db	 0Ch, 03h, 0Ch, 00h, 82h, 00h
		db	 82h, 66h, 07h, 30h, 80h, 30h
		db	 66h, 00h,0E0h, 66h, 01h,0AAh
		db	 00h, 80h, 00h, 80h, 66h, 13h
		db	 40h, 01h, 00h, 01h,0D0h, 02h
		db	 50h, 02h,0A8h, 05h, 28h, 01h
		db	 28h, 0Eh,0EBh, 0Eh, 22h, 05h
		db	0EEh, 05h, 33h, 35h,0C3h, 35h
		db	 00h,0CAh,0C2h,0CAh, 1Fh,0EAh
		db	 15h,0EAh,0F5h, 50h, 75h, 50h
		db	0AAh, 80h,0AAh, 80h, 54h, 00h
		db	 54h, 00h,0A8h, 00h,0A8h, 00h
		db	0A0h, 00h,0A0h, 00h, 40h, 00h
		db	 40h, 00h, 80h, 00h, 80h, 66h
		db	 00h, 2Bh,0EEh,0ABh, 66h, 00h
		db	 0Ah,0E0h, 66h, 00h, 0Bh,0B8h
		db	 66h, 00h, 02h,0AEh, 03h,0A0h
		db	 03h,0AAh,0CEh, 38h,0CEh, 38h
		db	 30h,0C0h, 30h,0C0h
		db	8, ' ', 8, ' f', 0Ch, 0Ch, 'f'
		db	 01h,0A0h, 66h, 0Eh,0C3h, 66h
		db	 01h,0CCh, 00h, 30h, 00h,0C0h
		db	 66h, 01h,0C2h, 66h, 01h,0EEh
		db	 02h, 83h, 02h, 8Bh, 06h, 8Fh
		db	 06h, 8Fh, 0Ah, 3Fh, 02h, 2Fh
		db	 66h, 0Ah,0C0h, 00h,0C0h, 00h
		db	0E0h, 00h,0E0h, 00h,0F0h, 00h
		db	0F0h, 00h,0B0h, 00h,0B8h, 00h
		db	 50h, 00h, 5Eh, 00h, 1Ah,0FAh
		db	 1Ah,0BAh, 1Ah,0F5h, 1Ah,0F5h
		db	 28h,0E8h, 28h,0E8h, 2Bh,0D0h
		db	 2Bh,0D0h, 2Bh,0C0h, 2Bh,0C0h
		db	 23h, 00h, 23h, 00h, 0Ch, 00h
		db	 0Ch, 66h, 03h,0A0h, 00h,0AAh
		db	 80h, 38h, 00h, 38h, 20h,0C0h
		db	 00h,0C0h, 60h, 20h, 00h, 20h
		db	 66h, 0Fh, 75h, 51h, 75h, 59h
		db	 6Ah, 80h, 4Ah, 85h,0D5h, 00h
		db	0D5h, 00h,0E8h, 44h, 68h, 44h
		db	0D4h, 30h,0D4h, 30h,0E0h,0A0h
		db	 60h,0A0h,0C0h, 00h,0C0h, 00h
		db	0C0h, 00h,0C0h, 00h, 40h, 15h
		db	0C8h, 15h, 00h, 0Bh, 00h, 0Bh
		db	 02h, 03h,0C2h, 03h, 01h, 81h
		db	 01h, 81h, 00h,0B1h, 00h,0B1h
		db	 00h, 40h, 00h, 40h, 66h, 08h
		db	 01h, 66h, 00h, 03h, 08h, 22h
		db	 00h, 07h, 00h, 05h, 00h, 0Fh
		db	 08h, 87h, 00h, 1Eh, 01h, 1Eh
		db	0C0h, 3Dh,0C0h
		db	'-x:x:<4<5'
		db	 7Fh,0C0h, 6Bh,0C4h,0D7h,0F8h
		db	 57h,0F8h,0BAh,0AAh,0BAh,0AAh
		db	0D5h, 56h,0D5h, 56h,0A8h, 43h
		db	0A8h, 43h, 40h, 21h, 5Dh, 21h
		db	 80h, 11h,0EAh, 11h, 03h, 30h
		db	0ABh, 20h, 1Eh, 20h, 16h, 26h
		db	 0Fh, 1Ch, 0Bh, 15h, 0Fh, 48h
		db	 0Bh, 49h, 07h,0B2h, 27h,0B2h
		db	 03h,0D4h, 02h,0D4h, 01h,0AAh
		db	 09h,0AAh, 00h, 55h, 20h, 55h
		db	 00h, 06h, 04h, 06h, 00h, 08h
		db	 5Eh, 88h, 10h, 08h, 4Dh, 68h
		db	 01h, 06h,0DAh, 82h, 00h, 10h
		db	 5Bh, 80h, 38h, 00h, 3Ah,0A8h
		db	 95h, 40h, 95h, 50h, 54h, 00h
		db	 54h, 00h,0AAh, 00h,0AAh, 66h
		db	 00h, 3Fh, 00h, 3Fh, 03h,0D4h
		db	 02h,0D4h, 0Fh, 83h, 0Bh, 82h
		db	 1Eh, 05h, 1Eh, 05h, 38h, 18h
		db	 38h, 50h, 32h, 10h, 32h,0D0h
		db	 26h, 08h, 24h, 49h, 2Eh, 00h
		db	 2Ah, 10h, 68h, 00h, 68h, 66h
		db	 03h,0F1h, 80h,0B1h, 80h, 04h
		db	 60h, 04h, 60h, 03h, 10h, 03h
		db	 10h, 30h, 80h, 20h, 80h, 08h
		db	 08h, 08h, 28h, 01h, 0Ch, 41h
		db	 0Ch, 0Eh, 40h, 0Bh, 44h, 0Eh
		db	 60h, 0Eh, 41h, 03h, 3Eh, 03h
		db	 36h, 40h, 8Fh, 40h, 8Eh, 60h
		db	 00h, 40h, 00h, 3Fh, 07h, 35h
		db	 05h, 0Fh,0F0h, 0Fh, 50h, 01h
		db	0FFh, 01h,0FFh, 07h, 0Ch, 05h
		db	 04h, 7Ch, 08h, 6Ch, 40h, 00h
		db	 38h, 00h, 28h,0F0h,0E0h, 72h
		db	0A0h, 00h, 18h, 00h, 18h,0D5h
		db	0E0h, 55h, 60h, 7Fh, 00h, 7Fh
		db	 66h, 04h, 07h, 66h, 01h, 0Fh
		db	 66h, 01h, 05h, 66h, 01h, 04h
		db	 66h, 01h, 3Fh, 66h, 01h, 0Fh
		db	 66h, 01h, 0Ah, 66h, 01h, 62h
		db	 66h, 00h,0E0h, 66h, 01h, 90h
		db	 66h, 01h, 20h, 66h, 01h, 20h
		db	 66h, 01h, 4Ch, 66h, 01h, 10h
		db	 66h, 05h, 02h, 66h, 01h, 01h
		db	 95h, 66h, 00h, 07h,0B8h, 00h
		db	 47h, 0Fh, 30h, 00h, 8Ah, 0Fh
		db	0B0h, 00h, 45h, 0Dh, 30h, 02h
		db	 8Bh, 06h,0D0h, 00h, 25h, 01h
		db	0A8h, 00h, 13h, 00h, 54h, 00h
		db	 2Ah, 50h, 80h, 66h, 01h, 20h
		db	0FCh, 66h, 00h, 10h,0AAh, 80h
		db	 66h, 00h, 55h, 66h, 00h, 10h
		db	0FEh, 80h, 00h, 20h,0FFh, 66h
		db	 00h, 80h,0FCh, 00h, 02h, 00h
		db	0A8h, 00h
sub_1		endp


seg_a		ends



		end	start
