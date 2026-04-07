
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_353UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_6e		equ	0A00h			;*
data_7e		equ	2000h			;*
data_8e		equ	54A0h			;*
data_9e		equ	6000h			;*
data_10e	equ	6C65h			;*
data_11e	equ	8000h			;*
data_12e	equ	800Ah			;*
data_13e	equ	0D900h			;*
data_14e	equ	0FE0Ah			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_353UNKN	proc	far

start:
		dec	di
		add	ax,0
		add	[bx],al
		db	0FEh,0FEh, 00h, 21h, 30h, 40h
		db	 00h, 00h,0F0h, 00h, 0Fh,0FCh
		db	0D4h, 00h, 03h, 55h, 74h, 44h
		db	 01h, 88h, 1Ch, 44h, 01h, 88h
		db	 00h, 15h, 35h, 6Ah, 00h, 14h
		db	 15h, 68h, 00h, 05h, 00h, 0Ah
		db	 02h, 82h, 01h, 55h, 05h, 40h
		db	 02h, 80h,0FEh, 00h, 02h, 03h
		db	 00h, 03h, 00h, 01h
data_2		db	0			; Data table (indexed access)
		db	 02h, 00h, 0Fh, 00h, 0Fh, 00h
		db	 5Fh, 00h, 0Fh, 30h, 00h, 4Bh
		db	0C0h, 00h, 00h, 75h, 50h, 00h
		db	 00h, 85h, 50h,0C0h, 00h,0D5h
		db	 40h,0D5h, 30h,0D5h, 40h, 05h
		db	 50h,0D5h, 00h,0D0h, 00h,0D5h
		db	 00h,0F4h, 00h,0F4h, 00h, 05h
		db	0D7h, 00h, 07h, 0Dh, 01h, 00h
		db	 01h, 00h, 05h, 3Fh,0F5h, 00h
		db	 05h, 35h, 55h, 00h, 00h, 14h
		db	0FEh, 00h, 00h, 10h,0FEh, 00h
		db	 06h,0FCh, 00h,0FCh, 00h, 7Fh
		db	 00h, 7Fh, 00h, 4Fh,0C0h, 4Fh
		db	0C0h, 03h, 00h, 03h, 70h,0FEh
		db	 00h, 00h
loc_1:
		jl	loc_1			; Jump if <
		add	[bx+si],al
		push	di
		inc	byte ptr [bx+si]
		add	[di],dl
		inc	byte ptr [bx+si]
		add	[di],al
		inc	byte ptr [bx+si]
		pop	ss
loc_2:
		jo	loc_2			; Jump if overflow=1
		add	[bx+si],al
		inc	ax
		inc	byte ptr [bx+si]
		sbb	al,[di]
		or	cl,[bp+si]
		push	bp
;*		xor	[bx+si+0],al
		db	 30h, 40h, 00h		;  Fixup - byte match
		db	 00h,0F0h, 00h, 0Fh,0FCh,0D4h
		db	 00h, 03h, 55h,0F4h, 44h, 01h
		db	 88h, 1Ch, 44h, 01h, 88h, 00h
		db	 15h, 35h, 6Ah, 00h, 14h, 15h
		db	 68h,0B0h, 00h, 4Bh,0C0h, 0Ah
		db	 05h, 04h,0AAh,0FEh, 00h, 06h
		db	 03h, 00h, 03h, 00h, 01h, 00h
		db	 02h, 00h, 0Fh, 00h, 0Fh, 00h
		db	 5Fh, 00h, 0Fh, 05h,0D5h, 00h
		db	 05h, 00h, 00h, 59h, 50h, 00h
		db	 00h, 25h, 50h,0C0h, 00h,0D5h
		db	 40h,0D5h, 30h,0D5h, 40h, 05h
		db	 50h,0D5h
data_3		db	0			; Data table (indexed access)
		db	0F0h, 00h,0F5h
data_4		dw	0FD00h			; Data table (indexed access)
		db	 00h,0FDh, 00h,0FFh, 00h,0FFh
		db	 00h, 0Dh,0FEh, 00h, 03h, 35h
		db	0FEh, 00h, 00h, 35h,0FEh, 00h
		db	 00h, 35h,0FEh, 00h, 00h, 30h
		db	0FEh, 00h, 00h, 03h,0FEh, 00h
		db	 00h, 03h,0FEh, 00h, 01h, 5Fh
		db	0C0h, 5Fh,0C0h, 37h,0C0h, 77h
		db	0C0h, 0Fh, 00h, 7Fh,0FEh, 00h
		db	 00h,0FCh,0FEh, 00h, 00h,0FCh
		db	0FEh, 00h, 00h,0F0h,0FEh, 00h
		db	 00h,0FCh,0FEh, 00h, 00h, 3Fh
		db	 00h, 30h, 00h, 4Bh,0C0h, 00h
		db	 00h, 75h, 50h, 00h, 00h, 85h
		db	 50h,0C0h, 00h,0D5h, 40h,0D5h
		db	 30h,0D5h, 40h, 05h, 50h,0D5h
		db	 00h,0F0h, 00h,0F5h, 00h,0FCh
		db	 00h,0FCh, 00h, 05h,0D7h, 00h
		db	 07h, 0Dh, 03h, 00h, 03h, 00h
		db	 0Fh, 3Fh,0FFh, 00h, 0Fh, 3Fh
		db	0FFh, 00h, 00h, 34h,0FEh, 00h
		db	 00h, 10h,0FEh, 00h, 06h,0F5h
		db	 00h,0F5h, 00h,0F5h, 00h,0F5h
		db	 00h,0C5h, 40h,0C5h, 40h, 01h
		db	 00h, 01h, 50h,0FEh, 00h, 00h
		db	 54h,0FEh, 00h, 00h, 55h,0FEh
		db	 00h, 00h, 15h,0FEh, 00h, 00h
		db	 05h,0FEh, 00h, 17h, 50h,0FEh
		db	 00h, 00h, 40h, 00h, 0Dh,0FEh
		db	 00h, 03h, 3Fh,0FEh, 00h, 00h
		db	 3Fh,0FEh, 00h, 00h, 3Fh,0FEh
		db	 00h, 00h, 30h,0FEh, 00h, 00h
		db	 01h,0FEh, 00h, 00h, 01h,0FEh
		db	 00h, 01h, 5Fh, 40h, 5Fh, 40h
		db	 0Dh, 40h,0FDh, 40h, 05h, 00h
		db	0F5h,0FEh, 00h, 00h,0D4h,0FEh
		db	 00h, 00h, 54h,0FEh, 00h, 00h
		db	 50h,0FEh, 00h, 00h, 54h,0FEh
		db	 00h, 00h, 15h, 00h, 30h, 40h
		db	 00h, 00h,0F0h, 00h, 0Fh,0FCh
		db	0D4h, 00h, 03h, 55h, 74h, 44h
		db	 01h, 88h, 1Ch, 44h, 01h, 88h
		db	 00h, 15h, 35h, 6Ah, 00h, 14h
		db	 15h, 68h, 00h, 00h, 0Fh,0D0h
		db	0FEh, 00h, 02h, 02h, 00h, 01h
		db	 00h, 01h, 00h, 0Ah, 00h, 20h
		db	 00h, 14h, 00h, 50h, 00h,0A8h
		db	 00h, 90h, 01h,0FEh, 00h, 00h
		db	 01h,0FEh, 00h, 02h, 60h, 00h
		db	 9Bh,0D4h, 00h, 00h, 33h,0D4h
		db	 00h, 00h, 87h, 54h, 00h, 00h
		db	 15h, 50h, 3Dh, 50h, 3Dh, 50h
		db	 30h, 07h,0FDh, 50h,0FFh, 55h
		db	0FFh
		db	50h
data_5		db	0FFh			; Data table (indexed access)
		db	0A0h,0FFh,0A0h, 00h, 05h,0FEh
		db	 00h, 00h, 5Dh,0FEh, 00h, 00h
		db	0D0h,0FEh, 00h, 06h, 03h,0FEh
		db	 00h, 00h, 0Fh,0FEh, 00h, 00h
		db	 3Fh,0FEh, 00h, 00h, 3Fh,0FFh
		db	0A0h,0FFh,0A0h,0FDh, 68h,0FDh
		db	 68h,0FCh, 6Ah,0FCh, 6Ah, 00h
		db	 18h,0F4h, 1Ah, 00h, 00h,0E4h
		db	 0Ah, 00h, 00h, 90h, 0Ah, 00h
		db	 00h, 80h, 0Ah, 00h, 00h,0E0h
		db	 0Ah,0FEh, 00h, 0Bh, 80h,0FEh
		db	 00h, 00h, 80h,0FEh, 00h, 00h
		db	 80h,0FEh, 00h, 00h, 80h,0FEh
		db	 00h, 00h,0A0h, 00h, 00h, 01h
		db	0FEh, 00h, 00h, 03h,0FEh, 00h
		db	 00h, 03h,0FEh, 00h, 00h, 03h
		db	0FEh, 00h, 00h, 01h,0FEh, 00h
		db	 0Ch, 20h,0FEh, 00h, 01h, 3Fh
		db	0D8h,0C0h, 00h, 1Eh,0AAh,0A1h
		db	 10h, 0Ch, 84h,0C0h, 90h, 0Dh
		db	 04h, 00h, 50h,0FAh,0AAh, 00h
		db	0A8h,0AAh, 52h, 00h,0A0h, 14h
		db	 00h, 60h, 00h, 9Bh,0D4h, 00h
		db	 00h, 33h,0D5h, 40h, 00h,0A7h
		db	 55h,0A0h, 00h, 52h,0AAh, 43h
		db	 54h, 2Bh, 54h, 28h, 03h, 51h
		db	 54h, 17h,0F5h, 17h,0F4h, 3Fh
		db	0EAh, 3Fh,0E8h,0FEh, 00h, 10h
		db	 03h,0FEh, 00h, 00h, 0Fh,0FEh
		db	 00h, 00h, 3Fh,0FEh, 00h, 00h
		db	 3Fh, 3Fh,0A8h, 3Fh,0A8h, 7Eh
		db	 3Ah, 7Eh, 3Ah, 7Ch, 16h, 7Ch
		db	 16h, 00h, 0Ch,0F4h, 0Eh, 00h
		db	 00h,0E4h, 0Ah, 00h, 00h, 90h
		db	 0Ah, 00h, 00h, 80h, 0Ah, 00h
		db	 00h,0E0h, 0Ah,0FEh, 00h, 0Bh
		db	 80h,0FEh, 00h, 00h, 80h,0FEh
		db	 00h, 00h, 80h,0FEh, 00h, 00h
		db	 80h,0FEh, 00h, 00h,0A0h, 00h
		db	 00h, 02h,0FEh, 00h, 00h, 03h
		db	0FEh, 00h, 00h, 03h,0FEh, 00h
		db	 00h, 03h,0FEh, 00h, 10h, 10h
		db	0FEh, 00h, 01h, 3Fh,0D0h,0C0h
		db	 00h, 1Dh, 54h,0A0h, 40h, 0Ah
		db	 24h,0C0h, 20h, 0Ah, 44h, 01h
		db	 50h,0F2h,0A9h, 00h,0A8h,0ABh
		db	 51h, 00h,0A0h, 14h, 00h, 30h
		db	 00h, 4Ch, 7Ah, 01h, 00h, 7Ah
		db	 8Dh, 02h,0A0h, 15h, 51h, 0Ch
		db	0D0h, 0Ch, 2Ch, 0Fh, 40h, 0Fh
		db	 4Bh, 00h, 00h, 3Fh, 54h, 3Fh
		db	0FAh, 3Fh,0FAh, 7Fh, 4Ch, 7Fh
		db	 4Ch, 00h, 00h,0C0h,0FEh, 00h
		db	 0Ah,0A0h, 00h, 40h, 00h,0C0h
		db	0FEh, 00h, 00h, 80h,0FEh, 00h
		db	 0Dh, 01h, 00h, 01h,0FEh, 00h
		db	 00h, 07h,0FEh, 00h, 00h, 0Fh
		db	0FEh, 00h, 00h, 1Fh,0FEh, 00h
		db	 00h, 3Eh,0FEh
		db	0, 0
loc_4:
		aas				; Ascii adjust
;*		jge	loc_9			;*Jump if > or =
		db	 7Dh, 7Ah		;  Fixup - byte match
;*		jge	loc_10			;*Jump if > or =
		db	 7Dh, 7Ah		;  Fixup - byte match
		cli				; Disable interrupts
;*		jz	loc_5			;*Jump if zero
		db	 74h,0FAh		;  Fixup - byte match
;*		jz	loc_3			;*Jump if zero
		db	 74h,0F4h		;  Fixup - byte match
		cli				; Disable interrupts
		hlt				; Halt processor
;*		jp	loc_6			;*Jump if parity=1
		db	 7Ah, 01h		;  Fixup - byte match
		mov	al,0D0h
		cmp	al,[bp+di]
		add	data_5[bx+si],ah
		add	[bx+si+1Ah],al
		add	[bx+si],al
		sbb	byte ptr [bp+si],0
		add	ds:data_14e[bx+si],al
		add	[bx],dl
		cmp	dh,0
		add	ds:data_9e[bx+si],ah
		add	data_3[bx],al
;*		add	dl,bh
		db	 00h,0FAh		;  Fixup - byte match
		push	bp
		dec	ax
		js	loc_7			; Jump if sign=1
		test	dx,[bx+si]
		aas				; Ascii adjust
		sub	al,[bx+si+0Dh]
		push	bp
		or	ax,54h
		add	[bx],di
		push	sp
		aas				; Ascii adjust
		cli				; Disable interrupts
		aas				; Ascii adjust
		cli				; Disable interrupts
		aas				; Ascii adjust
		int	3			; Debug breakpoint
		aas				; Ascii adjust
		int	3			; Debug breakpoint
		add	[bx+si],al
		db	0C0h,0FEh, 00h, 06h, 80h,0FEh
		db	 00h, 00h,0E0h,0FEh, 00h, 00h
		db	 70h, 00h
loc_7:
		add	byte ptr [bx+si],80h
		inc	byte ptr [bx+si]
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
		inc	byte ptr [bx+si]
		add	[di+7Ah],bh
		jge	loc_11			; Jump if > or =
		cli				; Disable interrupts
;*		jnz	loc_8			;*Jump if not zero
		db	 75h,0FAh		;  Fixup - byte match
		jz	$-0Ah			; Jump if zero
		jnp	$-0Ah			; Jump if not parity
		jp	$+2			; delay for I/O
;*		xor	al,dl
		db	 30h,0D0h		;  Fixup - byte match
		cmp	al,[bx+si]
		add	data_2[bx+si],ah
		add	[bx+si+1Ah],al
		add	[bx+si],al
		sbb	byte ptr [bp+si],0
		add	ds:data_12e[bx+si],al
		inc	byte ptr [bx+si]
		push	ss
		cmp	dh,0
;*		add	byte ptr ds:[0][bx+si],ah
		db	 00h,0A0h, 00h, 00h	;  Fixup - byte match
;*		adc	dh,bh
		db	 10h,0FEh		;  Fixup - byte match
		add	[bx+di],al
		aas				; Ascii adjust
		push	ax
		db	0C0h, 00h, 15h, 54h,0A4h, 40h
		db	 02h, 24h,0C0h, 20h, 16h, 44h
		db	 01h,0D3h, 3Ah, 28h, 00h,0BFh
		db	0FBh, 40h, 00h,0F8h, 14h,0FEh
		db	 00h, 0Ah, 0Bh,0FAh, 00h, 00h
		db	 7Eh, 80h, 00h, 00h,0F4h,0FEh
		db	 00h, 00h, 80h,0FEh, 00h, 04h
		db	 07h,0E0h,0C8h, 0Ah, 6Bh, 80h
		db	 90h, 3Dh, 50h, 00h, 2Dh,0DDh
		db	 0Ah,0EBh, 0Ah,0EBh, 0Dh, 55h
		db	 0Dh, 55h, 00h, 01h, 3Fh, 54h
		db	 3Fh,0FAh, 3Fh,0FAh, 3Fh,0CCh
		db	 3Fh,0CCh, 00h, 00h,0C0h
loc_11:
		inc	byte ptr [bx+si]
		or	byte ptr data_4[bx+si],al
		add	byte ptr data_4[bx+si],al
		add	ds:data_11e[bx+si],al
		inc	byte ptr [bx+si]
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
		inc	byte ptr [bx+si]
		add	[di],dx
		add	[bx+si],cl
		add	[bx+di],cl
		add	[si],dl
		inc	byte ptr [bx+si]
		add	[si],dl
		add	[bx+si],dl
		add	[bp+si],cl
		inc	byte ptr [bx+si]
		add	ds:data_6e,al
		add	[si],al
		add	[di],al
		add	[bp+si],al
		add	[bp+si],al
		add	[bx+di],al
		add	[bx+di],al
		add	[bx+si],al
		add	byte ptr [bp+di],1Fh
                           lock	add	byte ptr [bp+di],75h	; 'u'
		pop	ax
		adc	[bx+di],dl
		inc	bx
		sub	al,91h
		adc	[bp+si+2Ch],ax
		add	ax,0EA40h
		lodsb				; String [si] to al
		or	al,ds:data_10e[bx+si]
		mov	al,ds:data_8e
		inc	byte ptr [bx+si]
		push	es
		cmp	dh,0
		add	byte ptr data_4[bx+si],al
		adc	[bx+di],ax
		inc	byte ptr [bx+si]
		sbb	ax,ds:data_13e
		cmc				; Complement carry
		add	[bx+si],al
		mov	di,0FCh
		add	[di+54h],bh
		aas				; Ascii adjust
		call	$-15BEh
		aas				; Ascii adjust
		push	ax
		aas				; Ascii adjust
		push	cx
		add	[bx+si],al
		aas				; Ascii adjust
		push	sp
		aas				; Ascii adjust
		cli				; Disable interrupts
		aas				; Ascii adjust
		cli				; Disable interrupts
;*		jg	loc_15			;*Jump if >
		db	 7Fh, 4Ch		;  Fixup - byte match
		jg	loc_16			; Jump if >
		inc	byte ptr [bx+si]
		or	ax,ds:data_7e[bx+si]
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		;  Fixup - byte match
		db	0C0h,0FEh, 00h, 00h, 40h,0FEh
		db	 00h, 00h,0C0h
loc_12:
		inc	byte ptr [bx+si]
loc_13:
		add	[di+7Ah],bh
		jge	$+7Ch			; Jump if > or =
		cli				; Disable interrupts
;*		jz	loc_14			;*Jump if zero
		db	 74h,0FAh		;  Fixup - byte match
		jz	loc_12			; Jump if zero
		jp	loc_13			; Jump if parity=1
		jp	$+2			; delay for I/O
;*		xor	al,dl
		db	 30h,0D0h		;  Fixup - byte match
		cmp	al,[bx+si]
		add	data_2[bx+si],ah
		add	[bx+si+1Ah],al
		add	[bx+si],al
		sbb	byte ptr [bp+si],0
		add	ds:data_12e[bx+si],al
		inc	byte ptr [bx+si]
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
		inc	byte ptr [bx+si]
		add	byte ptr data_4[bx+si],al
		add	byte ptr data_4[bx+si],al
		add	byte ptr data_4[bx+si],al
		add	byte ptr data_4[bx+si],al
loc_16:
		add	al,byte ptr data_4[bx+si]
;*		add	byte ptr ds:[0][bx+si],ah
		db	 00h,0A0h, 00h, 00h	;  Fixup - byte match

_353UNKN	endp

seg_a		ends



		end	start
