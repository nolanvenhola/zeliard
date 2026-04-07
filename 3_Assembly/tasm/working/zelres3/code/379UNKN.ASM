
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_379UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    6          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_4e		equ	0B0Ah			;*
data_5e		equ	8003h			;*
data_6e		equ	800Dh			;*
data_7e		equ	0F603h			;*
data_8e		equ	0FE7Fh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_379UNKN	proc	far

start:
		push	sp
		push	es
		add	[bx+si],al
		add	[bx],al
		test	byte ptr [bx+si],1
		add	al,ds:data_4e
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		adc	[bx+di],dl
		adc	dl,[bp+di]
		adc	al,15h
		push	ss
		pop	ss
		sbb	[bx+di],bl
		sbb	bl,[bp+di]
		sbb	al,21h			; '!'
		and	al,[bx+si]
;*		sbb	si,si
		db	 19h,0F6h		;  Fixup - byte match
		add	[bx+si],al
;*		sbb	dh,dh
		db	 18h,0F6h		;  Fixup - byte match
		add	[bx+si],al
		push	ss
		and	[bp+si],sp
		test	byte ptr [bx+si],0Ah
		add	al,20h			; ' '
;*		add	si,si
		db	 01h,0F6h		;  Fixup - byte match
		add	[bx+si],al
		or	al,20h			; ' '
		test	byte ptr [bx+si],1
		add	al,40h			; '@'
		add	[bx+si],ax
;*		add	si,si
		db	 01h,0F6h		;  Fixup - byte match
		add	[bx+si],al
		add	ax,ds:data_7e[bx+si]
		add	[bx+si],al
		pop	es
		db	0C0h, 06h, 80h, 00h, 00h, 0Fh
loc_1:
		mov	al,ds:data_6e
		add	[bx+si],al
		pop	es
		inc	ax
		add	si,si
		add	[bx+si],al
		add	al,data_3[bx+si]
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
		add	[bx+si],dl
		add	[bx+si],dl
		add	[bx+si],dl
		add	al,40h			; '@'
		test	byte ptr [bx+si],7
		add	[bx+si],ax
;*		add	si,si
		db	 01h,0F6h		;  Fixup - byte match
		add	[bx+si],al
		add	ax,ds:data_5e[bx+si]
		add	[bx+si],al
		add	[bx+si],ax
;*		add	si,si
		db	 01h,0F6h		;  Fixup - byte match
		add	[bx+si],al
		add	[bx+si],ax
;*		add	si,si
		db	 01h,0F6h		;  Fixup - byte match
		add	ds:data_8e,al
		add	[bx+di],al
		add	[bx+si],al
		jg	loc_1			; Jump if >
		add	[bx],bh
		add	byte ptr ds:[60h],bh
		pop	ds
		call	word ptr [di]		;*
		push	sp
		test	byte ptr [bx+si],3
		loopnz	$+2			; Loop if zf=0, cx>0

		pop	ss
		test	word ptr [bx],0E7h
;*		add	bh,dh
		db	 00h,0F7h		;  Fixup - byte match
		mul	di			; dx:ax = reg * ax
		out	0,ax			; port 0, DMA-1 bas&add ch 0
;*		add	bh,dh
		db	 00h,0F7h		;  Fixup - byte match
		test	word ptr [di+45h],0F6h
		add	ax,0FF7Fh
		jg	$-100h			; Jump if >
		add	[bx+si],al
		db	 7Fh,0FFh, 7Fh,0FEh, 00h, 00h
		db	 7Fh,0FFh, 55h, 54h,0F6h, 00h
		db	 05h,0F7h,0F7h,0E7h,0E7h, 00h
		db	 00h,0F7h,0F7h,0E7h,0E7h, 00h
		db	 00h,0F7h,0F7h, 45h, 45h,0F6h
		db	 00h, 04h, 1Ch, 7Fh,0E3h, 7Fh
		db	0E2h, 00h, 70h, 7Fh, 8Fh, 7Fh
		db	 8Eh, 01h,0C0h, 7Eh, 3Fh, 54h
		db	 14h,0F6h, 00h, 03h, 14h, 00h
		db	0E3h,0F7h,0E3h,0E7h, 70h, 00h
		db	 87h,0F7h, 87h,0E7h,0C0h
data_3		db	0			; Data table (indexed access)
		db	 37h,0F7h, 05h, 45h, 73h,0C8h
		db	 88h, 36h, 88h, 36h, 01h, 10h
		db	 1Ch, 6Dh, 1Ch, 6Ch,0C3h, 20h
		db	 0Ch, 5Ah, 0Ch, 58h,0CFh,0F0h
		db	 00h, 05h,0F6h, 00h, 01h,0CFh
		db	0FAh, 8Ah,0A0h, 00h, 00h,0CFh
		db	 7Dh, 45h, 50h, 00h, 00h, 1Fh
		db	 5Eh, 0Ah, 08h, 00h, 00h,0FEh
		db	0FFh, 54h, 54h,0F6h, 00h, 05h
		db	 7Ch, 7Fh, 7Ch, 7Eh, 00h, 80h
		db	 7Ch,0BFh, 7Ch,0BEh, 00h, 80h
		db	 7Ch,0BFh, 54h, 94h, 01h, 00h
		db	 01h, 00h, 01h, 00h, 00h, 81h
		db	0E0h, 95h,0E0h, 85h, 01h, 41h
		db	 61h, 45h, 61h, 45h, 04h,0A3h
		db	 44h,0A3h, 44h,0A3h, 0Ah, 00h
		db	0Ah
loc_2:
		add	[bp+si],cl
;*		add	[bx+si+0],dl
		db	 00h, 50h, 00h		;  Fixup - byte match
		db	 50h,0FFh, 50h,0FEh, 28h, 00h
		db	 29h,0FFh, 29h,0FEh, 18h, 00h
		db	 1Bh,0FFh, 19h, 54h, 20h, 00h
		db	 20h, 00h, 20h, 00h,0C0h, 00h
		db	0D7h,0F7h,0C7h,0E7h, 80h, 00h
		db	 97h,0F7h, 87h,0E7h, 00h, 00h
		db	 37h,0F7h, 05h, 45h,0A8h, 32h
		db	0A8h, 32h,0A8h
		db	'2TKtKtKx1'
		db	0F8h, 31h,0F8h, 31h, 29h, 50h
		db	0A9h, 53h,0A9h, 53h,0D4h,0A5h
		db	0D4h,0A7h,0D4h,0A7h, 03h, 2Ah
		db	 03h, 2Eh, 03h, 2Eh, 00h,0D8h
		db	 00h,0D8h, 00h,0D8h, 00h, 30h
		db	 00h, 30h, 00h, 30h,0F6h, 00h
		db	 0Ah, 01h, 00h, 01h, 00h, 01h
		db	 28h, 00h, 28h, 00h, 28h, 00h
		db	0D4h, 05h,0D4h, 05h,0D4h, 05h
		db	 03h, 0Ah, 03h, 0Ah, 03h, 0Ah
		db	 00h,0D8h, 00h,0D8h, 00h,0D8h
		db	 00h, 30h, 00h, 30h, 00h, 30h
		db	0F6h, 00h, 16h, 01h, 00h, 01h
		db	 00h, 01h,0F6h, 02h, 03h, 00h
		db	0C0h, 00h,0C0h, 00h,0C0h, 00h
		db	 10h, 00h, 10h, 00h, 10h, 01h
		db	0B2h, 01h,0B2h, 01h,0B2h, 04h
		db	 4Bh, 06h, 4Bh, 06h, 4Bh, 15h
		db	 31h, 1Dh, 31h, 1Dh
		db	'1', 9, 'P9S9ST'
		db	0A5h, 74h,0A7h, 74h,0A7h, 23h
		db	 2Ah, 63h, 2Eh, 63h, 2Eh, 50h
		db	0D8h, 50h,0D8h, 50h,0D8h,0C0h
		db	 30h,0C0h, 30h,0C0h, 30h,0A0h
		db	 00h,0A0h, 00h,0A0h, 00h, 52h
		db	 00h, 72h, 00h, 72h, 00h, 7Ah
		db	 00h,0FAh, 00h,0FAh, 00h, 29h
		db	 40h,0A9h, 40h,0A9h, 40h,0D4h
		db	0A8h,0D4h,0A8h,0D4h,0A8h, 03h
		db	 2Ah, 03h, 2Eh, 03h, 2Eh, 00h
		db	0D8h, 00h,0D8h, 00h,0D8h, 00h
		db	 30h, 00h, 30h, 00h, 30h, 80h
		db	0F6h, 00h, 00h, 80h, 00h, 11h
		db	 04h, 00h, 00h, 11h, 04h, 02h
		db	 82h, 00h, 00h, 02h, 82h, 01h
		db	0C8h, 00h, 00h, 01h, 48h, 00h
		db	0D0h,0F6h, 00h, 00h,0D0h, 00h
		db	0D2h,0F6h, 00h, 00h, 92h, 00h
		db	 72h,0F6h, 00h, 00h, 32h, 00h
		db	 78h,0F6h, 00h, 00h, 68h, 00h
		db	 72h,0F6h, 00h, 00h, 52h, 00h
		db	 70h,0F6h, 00h, 00h, 50h, 00h
		db	 58h,0F6h, 00h, 00h, 58h, 00h
		db	 5Ch,0F6h, 00h, 00h, 5Ch, 00h
		db	 74h,0F6h, 00h, 00h, 54h, 00h
		db	 5Ch,0F6h, 00h, 00h, 5Ch, 00h
		db	 54h,0F6h, 00h, 00h, 44h, 00h
		db	 74h,0F6h, 00h, 00h, 74h, 00h
		db	 68h,0F6h, 00h, 00h, 48h, 00h
		db	 72h,0F6h, 00h, 00h, 72h, 00h
		db	 72h,0F6h, 00h, 00h, 52h, 00h
		db	0F0h,0F6h, 00h, 00h,0D0h, 00h
		db	0C8h,0F6h, 00h, 00h, 48h, 02h
		db	 82h, 00h, 00h, 02h, 82h, 11h
		db	 04h, 00h, 00h, 11h, 04h, 80h
		db	0F6h, 00h, 00h, 80h, 00h, 48h
		db	0F6h, 00h, 00h, 48h, 00h, 40h
		db	0F6h, 00h, 00h, 40h, 00h, 08h
		db	0F6h, 00h, 00h, 08h, 00h, 48h
		db	0F6h, 00h, 00h, 48h, 00h, 48h
		db	0F6h, 00h, 00h, 48h,0F6h, 00h
		db	 04h, 48h,0F6h, 00h, 00h, 48h
		db	 00h, 40h,0F6h, 00h, 00h, 40h
		db	 00h, 00h, 01h,0F6h, 00h, 00h
		db	 01h, 20h, 88h, 00h, 00h, 20h
		db	 88h, 41h, 40h, 00h, 00h, 41h
		db	 40h, 13h, 80h, 00h, 00h, 12h
		db	 80h, 0Bh,0F6h, 00h, 00h, 0Bh
		db	 00h, 4Bh,0F6h, 00h, 00h, 49h
		db	 00h, 4Eh,0F6h, 00h, 00h, 4Ch
		db	 00h, 1Eh,0F6h, 00h, 00h, 16h
		db	 00h, 4Eh,0F6h, 00h, 00h, 4Ah
		db	 00h, 0Eh,0F6h, 00h, 00h, 0Ah
		db	 00h, 1Ah,0F6h, 00h, 00h, 1Ah
		db	 00h, 3Ah,0F6h, 00h, 00h, 3Ah
		db	 00h, 2Eh,0F6h, 00h, 00h, 2Ah
		db	 00h, 3Ah,0F6h, 00h, 00h, 3Ah
		db	 00h, 2Ah,0F6h, 00h, 00h, 22h
		db	 00h, 2Eh,0F6h, 00h, 00h, 2Eh
		db	 00h, 16h,0F6h, 00h, 00h, 12h
		db	 00h, 4Eh,0F6h, 00h, 00h, 4Eh
		db	 00h, 4Eh,0F6h, 00h, 00h, 4Ah
		db	 00h, 0Fh,0F6h, 00h, 00h, 0Bh
		db	 00h, 13h,0F6h, 00h, 00h, 12h
		db	 00h, 41h, 40h, 00h, 00h, 41h
		db	 40h, 20h, 88h, 00h, 00h, 20h
		db	 88h, 00h, 01h,0F6h, 00h, 00h
		db	 01h, 00h, 12h,0F6h, 00h, 00h
		db	 12h, 00h, 02h,0F6h, 00h, 00h
		db	 02h, 00h, 10h,0F6h, 00h, 00h
		db	 10h, 00h, 12h,0F6h, 00h, 00h
		db	 12h, 00h, 12h,0F6h, 00h, 00h
		db	 12h,0F6h, 00h, 04h, 12h,0F6h
		db	 00h, 00h, 12h, 00h, 02h,0F6h
		db	 00h, 00h, 02h,0F6h, 00h, 09h
		db	0ABh,0FAh, 00h, 00h,0ABh,0FAh
		db	0F6h, 00h, 05h,0AAh,0AAh,0F6h
		db	 00h, 07h, 55h, 55h,0F6h, 00h
		db	 01h,0AAh,0AAh, 00h, 00h,0F9h
		db	0C4h, 06h, 3Bh, 06h, 3Bh, 00h
		db	 00h,0E0h, 38h,0E0h, 38h, 00h
		db	 01h,0F3h, 92h,0F3h, 92h,0F3h
		db	 93h,0F6h, 00h, 03h,0F3h, 93h
		db	0A2h, 82h, 00h, 00h, 73h, 93h
		db	 51h, 11h, 00h, 00h, 20h, 38h
		db	 20h, 28h, 00h, 00h,0FFh,0FFh
		db	 55h, 55h, 00h, 00h,0C0h, 00h
		db	0C0h,0F6h, 00h, 00h, 30h, 00h
		db	 30h, 00h, 0Ch,0F6h, 00h, 02h
		db	 03h, 00h, 88h, 00h, 88h, 00h
		db	0C0h,0C0h,0C2h, 00h,0C2h, 00h
		db	 00h, 30h, 00h, 80h, 00h, 80h
		db	0F6h, 00h, 00h, 2Ch, 00h, 2Ch
		db	0F6h, 00h, 00h, 03h, 00h, 03h
		db	0F6h, 00h, 00h, 03h, 00h, 03h
		db	0F6h, 00h, 00h, 0Ch, 00h, 0Ch
		db	 00h, 30h, 00h, 08h, 00h, 08h
		db	 00h,0C0h, 00h, 28h, 00h, 28h
		db	 03h, 01h, 00h,0A3h, 00h,0A3h
		db	 0Ch, 02h, 02h, 86h, 02h, 86h
		db	 30h, 18h, 0Ah, 18h, 0Ah, 18h
		db	 00h, 30h,0C0h, 30h,0C0h, 30h
		db	0EDh,0FFh,0F6h, 00h, 01h,0C0h
		db	0E0h, 3Eh, 00h, 3Eh, 00h,0E1h
		db	0E0h, 1Ch, 13h, 1Ch, 13h,0FEh
		db	0F3h,0F6h, 00h, 01h,0B0h, 00h
		db	 0Fh,0F3h, 0Ah,0A2h,0E0h, 00h
		db	 1Fh,0F3h, 15h, 51h,0C0h, 00h
		db	 3Fh, 60h, 2Ah, 20h, 80h, 00h
		db	 7Dh,0FFh, 55h, 55h,0FFh,0FFh
		db	0F6h, 00h, 03h, 38h, 18h, 38h
		db	 18h, 00h, 88h, 93h, 44h, 93h
		db	 44h, 93h,0CCh,0F6h, 00h, 03h
		db	 93h,0CCh, 82h, 88h, 00h, 00h
		db	 93h,0CCh, 11h, 44h, 00h, 00h
		db	 38h, 18h, 28h, 08h, 00h, 00h
		db	0FFh,0FFh, 55h, 55h, 8Fh,0FCh
		db	 70h, 03h, 70h, 03h, 07h, 80h
		db	 00h, 63h, 00h, 63h, 13h, 00h
		db	0E0h,0C9h,0E0h,0C9h,0F3h, 9Ch
		db	0F6h, 00h, 03h, 07h, 80h, 02h
		db	 80h, 00h, 00h,0CFh, 2Eh, 45h
		db	 04h, 00h, 00h, 62h, 2Eh, 22h
		db	 2Ah, 00h, 00h,0FFh,0F7h, 55h
		db	 55h,0F6h, 00h, 05h
loc_3:
		jg	loc_3			; Jump if >
		jg	loc_3			; Jump if >
		add	[bx+si],al
loc_4:
		jg	loc_4			; Jump if >
		jg	loc_4			; Jump if >
		add	[bx+si],al
loc_5:
		jg	loc_5			; Jump if >
		jg	loc_5			; Jump if >
		add	[bx+si],al
loc_6:
		jg	loc_6			; Jump if >
		jg	loc_6			; Jump if >
		add	[bx+si],al
		jg	$-100h			; Jump if >
		jg	$-2			; Jump if >
		add	[bx+si],al
loc_7:
		jg	loc_7			; Jump if >
		jg	loc_7			; Jump if >
		add	[bx+si],al
		jg	$-100h			; Jump if >
		push	bp
		push	ax
		test	byte ptr [bx+si],3
		jg	$-7Eh			; Jump if >
		add	[bp],bh
		jl	$+80h			; Jump if <
		add	[bx+di],al
		inc	byte ptr [bx+di]
		cld				; Clear direction
		js	$+2			; delay for I/O
		pop	es
		inc	byte ptr [bx]
		cld				; Clear direction
		db	 60h, 00h, 1Fh,0FEh, 1Fh,0FCh
		db	 00h, 00h
loc_8:
		jg	loc_8			; Jump if >
		jg	loc_8			; Jump if >
		add	[bx+si],al
loc_9:
		jg	loc_9			; Jump if >
		jg	loc_9			; Jump if >
		add	[bx+si],al
loc_10:
		jg	loc_10			; Jump if >
		push	bp
		push	ax
		test	byte ptr [bx+si],3
;*		add	sp,di
		db	 01h,0FCh		;  Fixup - byte match
		jle	loc_12			; Jump if < or =
		jle	loc_12			; Jump if < or =
loc_12:
		pop	es
		cld				; Clear direction
		js	$+4			; Jump if sign=1
		js	$+2			; delay for I/O
		pop	ds
		cld				; Clear direction
		db	 60h, 02h, 60h, 00h, 7Fh,0F0h
		db	 00h, 0Eh, 00h, 0Ch, 7Fh,0C0h
		db	 00h, 3Eh, 00h, 3Ch, 7Fh, 00h
		db	 00h,0FEh, 00h,0FCh, 00h, 00h
loc_13:
		jg	loc_13			; Jump if >
		push	bp
		push	ax
		test	byte ptr [bx+si],5
loc_14:
		jg	loc_14			; Jump if >
		jg	loc_14			; Jump if >
		add	[bx+si],al
loc_15:
		jg	loc_15			; Jump if >
		jg	loc_15			; Jump if >
		add	[si],cl
		jg	loc_14			; Jump if >
		jg	loc_14			; Jump if >
		add	[si],bh
;*		jg	loc_11			;*Jump if >
		db	 7Fh,0C2h		;  Fixup - byte match
;*		jg	loc_11			;*Jump if >
		db	 7Fh,0C0h		;  Fixup - byte match
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
loc_16:
		jg	loc_17			; Jump if >
		jg	loc_17			; Jump if >
loc_17:
		add	di,sp
		jl	$+4			; Jump if <
		jl	loc_16			; Jump if <
		add	[bx+si],al
		jg	$-100h			; Jump if >
		push	bp
		push	ax
		add	[bx+si],al
		db	0FFh,0FFh,0F6h, 00h, 01h,0FFh
		db	0FFh,0F6h, 00h, 01h,0FFh,0FFh
		db	0F6h, 00h, 01h,0FFh,0FFh, 08h
		db	 02h, 00h, 00h,0FFh,0FFh, 00h
		db	 88h, 00h, 00h,0FFh,0FFh, 20h
		db	0F6h, 00h, 00h,0FFh,0FFh, 5Dh
		db	 55h, 00h, 00h,0FFh,0FFh,0ABh
		db	0BAh, 00h, 00h,0FFh,0FFh,0F6h
		db	 00h, 01h,0FFh,0FFh,0F6h, 00h
		db	 01h,0FFh,0FFh, 40h, 10h, 00h
		db	 00h,0FFh,0FFh, 02h,0F6h, 00h
		db	 00h,0FFh,0FFh,0F6h, 00h, 01h
		db	0FFh,0FFh, 01h, 04h, 00h, 00h
		db	0FFh,0FFh, 75h, 76h, 00h, 00h
		db	0FFh,0FFh,0FEh,0AFh, 32h, 74h
		db	 00h, 00h, 0Eh, 0Ch, 6Fh,0DCh
		db	 00h, 00h, 1Fh, 3Eh,0DFh, 7Ah
		db	 00h, 00h,0BFh,0FBh,0DFh,0FDh
		db	 00h, 00h,0FFh,0FDh, 6Fh,0FAh
		db	 00h, 00h, 7Fh,0FAh, 1Fh,0E8h
		db	 00h, 00h, 1Fh,0E8h, 0Bh, 50h
		db	 00h, 00h, 0Bh, 50h, 01h, 80h
		db	 00h, 00h, 01h, 80h,0F6h, 00h
		db	 03h, 1Ah, 68h, 00h, 00h, 06h
		db	 18h, 37h,0B8h, 00h, 00h, 0Fh
		db	 7Ch, 2Fh, 7Ch, 00h, 00h, 1Fh
		db	0FCh, 07h,0F8h, 00h, 00h, 1Fh
		db	0F8h, 0Fh,0F0h, 00h, 00h, 0Fh
		db	0F0h, 01h, 80h, 00h, 00h, 01h
		db	 80h,0F6h, 00h, 03h

_379UNKN	endp

seg_a		ends



		end	start
