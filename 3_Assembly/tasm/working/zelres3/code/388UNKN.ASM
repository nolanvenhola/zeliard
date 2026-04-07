
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_388UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	1020h			;*
data_2e		equ	7686h			;*
data_3e		equ	0FE06h			;*
data_4e		equ	638h			;*
data_5e		equ	6C8h			;*
data_6e		equ	0CF5h			;*
data_7e		equ	18F6h			;*
data_8e		equ	3010h			;*
data_9e		equ	71F6h			;*
data_10e	equ	0E5D5h			;*
data_17e	equ	17E5h			;*
data_18e	equ	37E5h			;*
data_19e	equ	59E6h			;*
data_20e	equ	78E5h			;*
data_21e	equ	0F501h			;*
data_22e	equ	0FFC8h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_388UNKN	proc	far

start:
		db	0C9h, 0Fh, 00h, 00h,0B9h, 07h
		db	 0Ch, 08h, 29h, 07h, 59h, 07h
		db	 01h, 1Fh, 00h, 02h,0FEh, 00h
		db	 03h,0D7h, 01h, 04h, 50h, 02h
		db	 09h, 65h, 03h, 06h, 15h, 07h
loc_1:
		pop	es
		sbb	al,[bx]
		or	[bx],bl
		pop	es
		or	[si],sp
		pop	es
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
		jnc	loc_1			; Jump if carry=0
;*		add	cl,ch
		db	 00h,0E9h		;  Fixup - byte match
		add	ds:data_20e[si],bl
		out	3,al			; port 3, DMA-1 bas&cnt ch 1
		loop	$+42h			; Loop if cx > 0

		add	[bx+di],al
		add	al,[bp+di]
		add	al,1
		add	[bx+di],al
		add	al,[bp+di]
		add	al,1
		add	[bx+di],al
		add	al,[bp+di]
		add	al,1
		add	[bx+di],al
		add	al,[bp+di]
		add	al,1
		add	[bx+di],al
		add	al,[bp+di]
		add	al,1
		add	[bx+di],al
		add	al,[bp+di]
		add	al,1
		add	[bx+di],al
		add	al,[bp+di]
		add	al,1
		add	[bx+di],al
		add	al,[bp+di]
		add	al,1
		add	[bx+di],al
		add	al,[bp+di]
		add	al,1
		add	[bx+di],al
		add	al,[bp+di]
		add	al,1
		add	[bx+di],al
		add	al,[bp+di]
		mov	al,ds:data_19e
		in	ax,78h			; port 78h ??I/O Non-standard
		adc	[bp+si],ah
		xor	ah,[si]
		inc	sp
		xor	al,13h
		and	[bp+di],sp
		and	al,12h
		add	ax,[bx+di]
		push	bp
		db	 65h, 56h, 10h, 22h, 32h, 24h
		db	 44h, 34h, 13h, 21h, 35h, 77h
		db	 76h,0E6h, 57h,0E5h, 6Eh, 9Eh
		db	0F5h, 01h, 02h,0F0h, 00h,0E9h
		db	 00h, 28h, 29h, 26h, 45h, 55h
		db	0F0h, 01h, 05h, 1Ah, 1Bh, 2Bh
		db	 3Bh, 36h,0F6h, 01h, 98h, 00h
		db	 18h, 19h, 16h, 45h, 55h, 65h
		db	 1Bh, 1Ch, 16h, 43h, 33h, 32h
		db	 30h, 9Ch,0E5h, 78h,0E6h, 03h
		db	0F5h, 01h, 04h,0F0h, 01h,0E9h
		db	 00h
		db	 70h, 71h
		db	'rstqpqrstqpqrstqpqrstqpqrstqpqrs'
		db	'tqpqrstqpqrstq'
		db	0F6h, 01h,0C2h, 00h,0FBh, 25h
		db	 00h,0FFh,0F0h, 01h,0E9h, 00h
		db	0A4h,0E5h, 69h,0E6h, 61h,0F0h
		db	 01h,0E9h, 00h,0F5h, 01h, 04h
		db	0F0h, 01h,0E9h, 00h,0E2h, 40h
		db	 11h, 12h, 74h, 13h, 11h, 10h
		db	 72h, 74h, 13h, 7Ch,0F6h, 01h
		db	 0Eh, 01h,0F5h, 01h, 02h,0F0h
		db	 01h,0E9h, 00h,0F5h, 02h, 02h
		db	0F0h, 01h,0E9h, 00h
		db	'x{qstsq{'
		db	0F6h, 02h, 2Ch, 01h,0F6h, 01h
		db	 25h, 01h,0F5h, 01h, 02h,0F0h
		db	 01h,0E9h, 00h,0F5h, 02h, 02h
		db	0F0h, 01h,0E9h, 00h
		db	'}~uqsqu~'
		db	0F6h, 02h, 4Ah, 01h,0F6h, 01h
		db	 43h, 01h,0F5h, 01h, 02h,0F0h
		db	 01h,0E9h, 00h,0F5h, 02h, 02h
		db	0F0h, 01h,0E9h, 00h
		db	'x{qstsq{'
		db	0F6h, 02h, 68h, 01h,0F6h, 01h
		db	 61h, 01h,0F5h, 01h, 04h,0F0h
loc_2:
;*		add	cx,bp
		db	 01h,0E9h		;  Fixup - byte match
		add	[bx-17h],bh
		add	[bx+si+71h],si
		jc	loc_2			; Jump if carry Set
		add	[bx+1],di
		jnc	loc_18			; Jump if carry=0
		jnz	loc_19			; Jump if not zero
		jnz	loc_20			; Jump if not zero
;*		ja	loc_21			;*Jump if above
		db	 77h, 78h		;  Fixup - byte match
;*		ja	loc_22			;*Jump if above
		db	 77h, 78h		;  Fixup - byte match
		jns	$+7Ch			; Jump if not sign
		jns	$+7Ah			; Jump if not sign
		ja	$+78h			; Jump if above
		cmc				; Complement carry
		add	[bp+di],ax
;*                         lock	add	cx,bp
		db	0F0h, 01h,0E9h		;  Fixup - byte match
		add	[bp+di],bp
		sub	bx,[bx+di]
loc_3:
		push	ss
;*		ja	loc_7			;*Jump if above
		db	 77h, 18h		;  Fixup - byte match
		sbb	[di],dx
		push	ss
		pop	ss
		js	loc_10			; Jump if sign=1
		push	ss
loc_5:
		ja	loc_11			; Jump if above
loc_6:
		sbb	[di],dx
		jbe	loc_25			; Jump if below or =
		jns	loc_25			; Jump if not sign
		jp	loc_5			; Jump if parity=1
		add	ds:data_21e[bx+si],sp
		add	[si],cx
;*                         lock	add	cx,bp
		db	0F0h, 01h,0E9h		;  Fixup - byte match
		add	[bx+di],bx
		push	ss
;*		ja	loc_13			;*Jump if above
		db	 77h, 18h		;  Fixup - byte match
loc_10:
		sbb	[di],dx
loc_11:
		jbe	$+79h			; Jump if below or =
		sbb	[bp+si-0Ah],bh
;*		add	cx,ax
		db	 01h,0C1h		;  Fixup - byte match
;*		add	bx,di
		db	 01h,0FBh		;  Fixup - byte match
loc_12:
		pop	es
;*		add	di,di
		db	 01h,0FFh		;  Fixup - byte match
;*                         lock	add	cx,bp
		db	0F0h, 01h,0E9h		;  Fixup - byte match
;*		add	ax,si
		db	 01h,0F0h		;  Fixup - byte match
;*		add	cx,bp
		db	 01h,0E9h		;  Fixup - byte match
		add	[bp+di],bp
		sub	bp,[bp+di]
		sub	bx,ds:data_19e[si]
		loopz	$+16h			; Loop if zf=1, cx>0

		inc	ax
		in	ax,64h			; port 64h, keyboard status
		loop	locloop_24		; Loop if cx > 0

                           lock	add	al,[di]
		push	ss
		db	 26h, 17h, 37h, 27h, 08h, 19h
		db	 18h, 17h, 06h, 48h, 49h, 5Ch
		db	 6Ch, 5Bh, 05h, 16h, 26h, 17h
loc_18:
		aaa				; Ascii adjust
		daa				; Decimal adjust
		or	[bx+di],bl
loc_19:
		sub	al,7Dh			; '}'
loc_20:
;*		jnp	loc_16			;*Jump if not parity
		db	 7Bh,0E1h		;  Fixup - byte match
		add	[bx+si-0Bh],al
		add	[bp+si],ax
                           lock	add	ch,cl
;*		add	bp,sp
		db	 01h,0E5h		;  Fixup - byte match
		db	 64h,0E6h, 31h
loc_23:
		push	ds
		push	ds
		sbb	di,word ptr ds:[0F05Eh]
		add	cx,word ptr ds:[211Fh]
		xor	[bp+di],di
		test	byte ptr [bx+di],10h
		add	cl,[bp+4Eh]
		dec	bx
		pop	si
		db	6Eh

locloop_24:
		jle	loc_23			; Jump if < or =
		add	dh,[bx+si]
loc_25:
		xor	[bp+si],si
		inc	ax
		inc	cx
		inc	bx
		inc	sp
		and	ax,2525h
		and	ax,78E5h
		push	es
		inc	si
		push	si
;*		jbe	loc_26			;*Jump if below or =
		db	 76h, 07h		;  Fixup - byte match
		inc	di
		push	di
		ja	$+0Ah			; Jump if above
		dec	ax
		pop	ax
		js	$+7Bh			; Jump if sign=1
		cmp	dh,[si]
		sti				; Enable interrupts
		db	0DBh, 01h,0FFh,0F0h, 03h,0E9h
		db	 02h,0F0h, 03h,0E9h, 02h,0E5h
		db	 78h,0A0h,0E6h, 7Bh,0F5h, 01h
		db	 04h,0F0h, 03h,0E9h, 02h,0E2h
		db	 40h, 46h,0F0h, 04h, 06h, 06h
		db	 16h, 06h, 16h, 06h, 16h, 06h
		db	 03h, 04h, 0Bh,0F6h, 01h, 60h
		db	 02h, 16h, 06h, 06h, 16h, 06h
		db	 16h, 06h, 16h, 16h, 07h, 07h
		db	 16h, 06h, 06h, 16h, 06h, 16h
		db	 06h, 16h, 16h, 06h, 06h, 17h
		db	 07h, 07h, 17h, 07h, 17h, 07h
		db	 17h, 17h, 07h, 07h, 17h, 07h
		db	 07h, 17h, 07h, 17h, 07h, 17h
		db	 17h, 07h, 07h, 16h, 06h, 06h
		db	 16h, 06h, 16h, 06h, 16h, 06h
		db	 03h, 04h, 0Bh, 16h, 06h, 06h
		db	 16h, 06h, 16h, 06h, 16h, 16h
		db	 06h, 06h, 19h, 09h, 09h, 19h
		db	 09h, 19h, 09h, 19h, 19h, 09h
		db	 09h, 1Ah, 0Ah, 0Ah, 1Ah, 0Ah
		db	 14h, 04h, 14h, 14h, 04h, 04h
		db	0F5h, 01h, 02h,0F0h, 04h,0E9h
		db	 02h, 18h, 08h, 08h, 18h, 08h
		db	 18h, 08h, 18h, 18h, 08h, 08h
		db	 18h, 08h, 08h, 18h, 08h, 18h
		db	 08h, 18h, 18h, 07h, 07h, 16h
		db	 06h, 06h, 16h, 06h, 16h, 06h
		db	 16h, 16h, 07h, 07h, 16h, 06h
		db	 06h, 16h, 06h, 16h, 06h, 16h
		db	 16h, 07h, 07h,0F6h, 01h,0D4h
		db	 02h, 18h, 08h, 08h, 18h, 08h
		db	 18h, 08h, 18h, 18h, 08h, 08h
		db	 18h, 08h, 08h, 18h, 08h, 18h
		db	 08h, 18h, 18h, 08h, 08h, 19h
		db	 09h, 09h, 19h, 09h, 1Ah, 0Ah
		db	 1Ah, 1Ah, 0Ah, 0Ah, 14h, 04h
		db	 04h, 14h, 04h, 1Ah, 0Ah, 1Ah
		db	 0Ah, 03h, 04h, 04h,0E5h, 7Fh
		db	 16h, 16h, 25h, 16h, 16h, 35h
		db	 16h, 25h, 16h, 35h, 16h, 16h
		db	 45h, 16h, 55h,0E6h, 31h,0E5h
		db	 64h,0E1h, 14h, 40h, 66h, 16h
		db	 76h,0F0h, 05h, 06h, 17h, 27h
		db	 37h, 07h, 18h, 28h, 38h, 08h
		db	 09h, 4Ah, 44h,0E1h, 00h, 40h
		db	0FBh, 54h, 02h,0FFh,0F0h, 05h
		db	0E9h, 02h,0F0h, 05h,0E9h, 02h
		db	0F5h, 01h, 02h,0F0h, 05h,0E9h
		db	 02h,0E5h, 7Fh,0E7h, 0Ah,0E2h
		db	 6Ah, 5Ch,0E2h, 4Eh, 5Dh,0E2h
		db	 6Ah, 6Eh, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 7Ch, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 7Ch, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 6Fh
		db	 5Ch,0E2h, 4Eh, 6Dh,0E5h, 7Fh
		db	0E7h, 0Ah,0E2h, 6Ah, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 6Fh, 7Ch
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 7Ch, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 6Fh, 5Ch,0E2h, 5Ch, 6Bh
		db	0E5h, 7Fh,0E7h, 0Ah,0E2h, 6Ah
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 6Fh, 7Ch, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 7Ch, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 6Fh, 5Ch,0E2h
		db	 4Eh, 6Dh,0E5h, 7Fh,0E7h, 0Ah
		db	0E2h, 6Ah, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 7Ch, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 7Ch, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 6Fh
		db	 7Fh, 7Fh,0F6h, 01h, 70h, 03h
		db	0E5h, 7Fh,0E7h, 0Ah, 5Ch,0E2h
		db	 4Eh, 5Dh,0E2h, 6Ah, 6Eh, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 6Fh
		db	 7Ch, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 7Ch, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 5Ch,0E2h, 4Eh
		db	 6Dh,0E5h, 7Fh,0E7h, 0Ah,0E2h
		db	 6Ah, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 6Fh, 7Ch, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 7Ch, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 6Fh, 5Ch
		db	0E2h, 5Ch, 6Bh,0E5h, 7Fh,0E7h
		db	 0Ah,0E2h, 6Ah, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 6Fh, 7Ch, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 7Ch
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 6Fh, 5Ch,0E2h, 4Eh, 6Dh,0E5h
		db	 7Fh,0E7h, 0Ah,0E2h, 6Ah, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 6Fh
		db	 7Ch, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 7Ch, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 7Fh, 7Fh, 68h,0F5h
		db	 01h, 02h,0F0h, 05h,0E9h, 02h
		db	0E5h, 7Fh,0E7h, 0Ah, 5Ch,0E2h
		db	 4Eh, 5Dh,0E2h, 6Ah, 6Eh, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 6Fh
		db	 7Ch, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 7Ch, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 5Ch,0E2h, 4Eh
		db	 6Dh,0E5h, 7Fh,0E7h, 0Ah,0E2h
		db	 6Ah, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 6Fh, 7Ch, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 7Ch, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 6Fh, 5Ch
		db	0E2h, 5Ch, 6Bh,0E5h, 7Fh,0E7h
		db	 0Ah,0E2h, 6Ah, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 6Fh, 7Ch, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 7Ch
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 6Fh, 5Ch,0E2h, 4Eh, 6Dh,0E5h
		db	 7Fh,0E7h, 0Ah,0E2h, 6Ah, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 6Fh
		db	 7Ch, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 7Ch, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 7Fh, 7Fh,0F6h
		db	 01h,0A7h, 04h,0E5h, 7Fh,0E7h
		db	 0Ah, 5Ch,0E2h, 4Eh, 5Dh,0E2h
		db	 6Ah, 6Eh, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 7Ch, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 7Ch, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 6Fh
		db	 5Ch,0E2h, 4Eh, 6Dh,0E5h, 7Fh
		db	0E7h, 0Ah,0E2h, 6Ah, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 6Fh, 7Ch
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 7Ch, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 6Fh, 5Ch,0E2h, 5Ch, 6Bh
		db	0E5h, 7Fh,0E7h, 0Ah,0E2h, 6Ah
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 6Fh, 7Ch, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 7Ch, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 6Fh, 5Ch,0E2h
		db	 4Eh, 6Dh,0E5h, 7Fh,0E7h, 0Ah
		db	0E2h, 6Ah, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 7Ch, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 7Ch, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 7Fh
		db	 7Fh, 7Fh, 7Fh,0E5h, 7Fh,0E7h
		db	 0Ah, 5Ch,0E2h, 4Eh, 5Dh,0E2h
		db	 6Ah, 6Eh, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 7Ch, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 7Ch, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 6Fh
		db	 5Ch,0E2h, 4Eh, 6Dh,0E5h, 7Fh
		db	0E7h, 0Ah,0E2h, 6Ah, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 6Fh, 7Ch
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 7Ch, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 6Fh, 5Ch,0E2h, 5Ch, 6Bh
		db	0E5h, 7Fh,0E7h, 0Ah,0E2h, 6Ah
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h
data_12		db	6Ah
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 6Fh, 7Ch, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 7Ch, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 6Fh, 5Ch,0E2h
		db	 4Eh, 6Dh,0E5h, 7Fh,0E7h, 0Ah
		db	0E2h, 6Ah, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 7Ch, 7Ch,0E2h
		db	 40h, 7Fh, 7Fh,0E2h, 4Eh, 7Fh
		db	 7Fh,0E2h, 5Ch, 7Fh, 7Fh,0E2h
		db	 6Ah, 7Fh, 7Fh,0E5h, 7Fh,0E7h
		db	 0Ah, 5Ch,0E2h, 4Eh, 5Dh,0E2h
		db	 6Ah, 6Eh, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 7Ch, 5Ch,0E2h
		db	 4Eh, 6Dh,0E2h, 6Ah, 7Ch, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 6Fh
		db	 5Ch,0E2h, 4Eh, 6Dh,0F5h, 01h
		db	 03h,0F0h, 05h,0E9h, 02h,0E5h
		db	 7Fh,0E7h, 0Ah,0E2h, 6Ah, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 6Fh
		db	 7Ch, 5Ch,0E2h, 4Eh, 6Dh,0E2h
		db	 6Ah, 7Ch, 5Ch,0E2h, 4Eh, 6Dh
		db	0E2h, 6Ah, 6Fh, 5Ch,0E2h
data_13		db	5Ch
		db	 6Bh,0E5h, 7Fh,0E7h, 0Ah

locloop_27:
		loop	$+6Ch			; Loop if cx > 0

		pop	sp
		loop	$+50h			; Loop if cx > 0

		db	 6Dh,0E2h, 6Ah, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 6Fh, 7Ch, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 7Ch
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 6Fh, 5Ch,0E2h, 4Eh, 6Dh,0F6h
		db	 01h, 98h, 06h,0E5h, 7Fh,0E7h
		db	 0Ah,0E2h, 6Ah, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 5Ch,0E2h, 4Eh
		db	 6Dh,0E2h, 6Ah, 6Fh, 7Ch, 5Ch
		db	0E2h, 4Eh, 6Dh,0E2h, 6Ah, 7Ch
		db	 5Ch,0E2h, 4Eh, 6Dh,0E2h, 6Ah
		db	 7Fh, 7Fh, 7Fh, 7Fh,0FBh, 69h
		db	 03h,0FFh,0F0h, 05h,0E9h, 02h
		db	0FFh,0F0h, 05h,0E9h, 02h,0FFh
		db	0F0h, 05h,0E9h, 02h,0FFh,0F0h
		db	 05h,0E9h, 02h,0FFh
		db	 4Ch, 45h, 4Ah, 47h, 48h

locloop_28:
		inc	bx
		or	byte ptr [bx+39h],3Ch	; '<'
		inc	cx
		inc	ax
		inc	sp
		aaa				; Ascii adjust
		db	'>489;PMLJHGED'
		db	80h
		db	'CO574250/'
		db	80h
		db	'-+)(,.$'
		db	'*"&'
		db	 06h, 05h, 24h, 22h, 0Ch, 0Bh
		db	 18h, 17h
		db	0Ch, 0Dh, '010.`_HG', 0Ch
		db	0Bh
		db	'`a0.', 0Ch, 0Dh, '01`_'
		db	 06h, 05h, 24h, 22h, 0Ch, 0Bh
		db	 18h, 17h, 0Ch, 0Dh, 06h, 05h
		db	'010.`_HG'
		db	 18h, 17h, 60h, 61h, 30h
loc_29:
		db	 2Eh, 0Ch, 0Bh, 0Ch, 0Dh, 30h
		db	 31h, 60h, 5Fh, 06h, 05h, 0Ch
		db	 0Bh, 30h,0FFh, 18h,0FFh, 24h
		db	0FFh, 60h,0FFh
		db	'HG', 0Ch, 0Dh, '`_HG', 0Ch
		db	 0Bh, 0Ch, 0Dh, 30h, 2Eh, 00h
		db	 01h, 0Ch, 01h, 06h, 01h, 04h
		db	 23h, 00h, 92h, 00h, 10h, 01h
		db	 0Eh, 02h, 7Ch, 02h,0E3h, 02h
		db	0FDh, 03h, 83h, 04h, 25h, 05h
		db	 49h, 03h, 19h, 07h, 73h, 07h
		db	0E9h, 06h, 0Ch, 08h, 0Ch,0B0h
		db	 01h, 05h, 01h, 01h,0F0h, 00h
		db	0E0h, 8Ch, 81h,0D5h,0E5h, 1Fh
		db	0F5h, 28h,0F0h, 00h,0FCh, 88h
		db	 06h,0F6h, 2Dh, 00h, 05h,0E3h
		db	 0Ah,0E4h, 03h,0E3h, 0Ch, 80h
		db	0D5h,0E5h, 1Fh, 15h, 23h, 33h
		db	 21h, 11h,0E3h, 1Ch, 2Ah, 2Ch
		db	0E4h, 21h, 13h,0E3h, 0Ch, 0Ah
		db	 48h, 50h,0E4h, 15h, 23h, 33h
		db	 21h, 11h,0E3h, 1Ch, 2Ah, 38h
		db	0E4h, 48h, 40h, 85h,0E5h, 1Fh
		db	0F5h, 08h,0F0h, 00h,0D3h, 2Ah
		db	0E4h, 21h, 20h, 68h, 26h, 25h
		db	 75h, 50h,0F6h, 63h, 00h,0D3h
		db	 2Ah,0E4h, 21h, 20h,0F0h, 01h
		db	 08h, 15h, 19h, 10h, 2Ch,0E4h
		db	 33h, 35h, 81h,0D5h,0E5h, 1Fh
		db	0F5h, 80h,0F0h, 01h,0FCh, 88h
		db	 06h,0F6h, 87h, 00h,0FBh, 23h
		db	 00h,0F0h, 00h, 84h,0E5h, 27h
		db	0D5h,0F5h, 10h,0F0h, 00h,0FCh
		db	 97h, 06h,0F6h, 9Ah, 00h,0D3h
		db	0FCh,0A8h, 06h,0F5h, 10h,0F0h
		db	 00h, 08h,0E4h, 03h, 08h, 0Ah
		db	 0Ch, 0Ah, 08h, 03h,0E3h,0F6h
		db	0A8h, 00h,0FCh,0A8h, 06h,0D3h
		db	0F5h, 10h,0F0h, 00h, 05h, 09h
		db	 0Ah, 0Ch,0F6h,0BDh, 00h,0D5h
		db	 09h, 06h, 05h, 03h, 05h, 03h
		db	 01h,0E3h, 0Ch,0E4h, 01h,0E3h
		db	 0Ch, 0Ah, 09h, 0Ah, 0Ch,0E4h
		db	 01h, 03h,0D4h,0F5h, 0Ch,0F0h
		db	 00h,0F0h, 01h, 40h, 1Ah,0E4h
		db	 13h, 51h,0E3h, 1Ch, 1Ah,0E4h
		db	 15h, 13h, 11h,0E3h, 5Ch, 1Ah
		db	0E4h, 13h, 51h,0E3h, 1Ch, 1Ah
		db	0E4h, 15h, 53h,0E3h, 59h, 5Ah
		db	 5Ch, 59h,0F6h,0DEh, 00h,0D5h
		db	0F5h, 30h,0F0h, 01h,0FCh, 97h
		db	 06h,0F6h, 05h, 01h,0FBh, 92h
		db	 00h,0F0h, 00h, 83h,0E5h, 0Fh
		db	0D2h,0F5h, 10h,0F0h, 00h
		db	'*', 0Ah, 0Ah, '*', 0Ah, '*', 0Ah
		db	'*', 0Ah
		db	0E4h, 01h,0E3h, 0Ch, 0Bh,0F6h
		db	 18h, 01h
		db	'*', 0Ah, 0Ah, '*', 0Ah, '*', 0Ah
		db	'*'
		db	'*', 8, 8, '*', 0Ah, 0Ah, '*', 0Ah
		db	'*', 0Ah, '**', 0Ah, 0Ah, '(', 8, 8
		db	'(', 8, '(', 8, '((', 8, 8
		db	'(', 8, 8, '(', 8, '(', 8, '((', 8
		db	8, '*', 0Ah, 0Ah, '*', 0Ah, '*', 0Ah
		db	'*', 0Ah
		db	0E4h, 01h,0E3h, 0Ch, 0Bh
		db	'*', 0Ah, 0Ah, '*', 0Ah, '*', 0Ah
		db	'**', 0Ah, 0Ah, '%'
		db	 05h, 05h, 25h, 05h, 25h, 05h
		db	 25h, 25h, 05h, 05h
		db	')', 9, 9, ')', 9, ',', 0Ch, ',,', 0Ch
		db	0Ch
		db	0F5h, 08h,0F0h, 00h, 26h, 06h
		db	 06h, 26h, 06h, 26h, 06h, 26h
		db	 26h, 06h, 06h, 26h, 06h, 06h
		db	 26h, 06h, 26h, 06h
		db	'&&', 8, 8, '*', 0Ah, 0Ah, '*', 0Ah
		db	'*', 0Ah, '**', 8, 8, '*', 0Ah, 0Ah
		db	'*', 0Ah, '*', 0Ah, '**', 8, 8
		db	0F6h, 88h, 01h, 26h, 06h, 06h
		db	 26h, 06h, 26h, 06h, 26h, 26h
		db	 06h, 06h, 26h, 06h, 06h, 26h
		db	 06h, 26h, 06h, 26h, 26h, 06h
		db	 06h, 25h, 05h, 05h, 25h, 05h
		db	')', 9, '))', 9, 9, ',', 0Ch, 0Ch
		db	',', 0Ch, ')', 9, ')', 9
		db	0E4h, 01h,0E3h, 0Ch, 0Bh
		db	'**P**0*P*0**'
		db	 10h, 2Ah, 40h
loc_30:
;*		and	ch,7
		db	 82h,0E5h, 07h		;  Fixup - byte match
;*		sal	al,cl			; Shift w/zeros fill
		db	0D2h,0F0h		;  Fixup - byte match
		add	[bp+si+1Ah],bp
		jp	loc_36			; Jump if parity=1
		sbb	[bx+si+66h],bh
		push	ss
		jbe	loc_30			; Jump if below or =
		add	al,[di]
		sbb	[si],bx
		sti				; Enable interrupts
		adc	[bx+di],al
                           lock	add	byte ptr ds:[0E5D5h][bx+di],al
		das				; Decimal adjust
;*		loopz	locloop_31		;*Loop if zf=1, cx>0

		db	0E1h, 02h		;  Fixup - byte match
		cmc				; Complement carry
;*		sub	al,dh
		db	 28h,0F0h		;  Fixup - byte match
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
;*		mov	byte ptr ds:[18F6h],al
		db	 88h, 06h,0F6h, 18h	;  Fixup - byte match
		add	al,[di]
;*		jcxz	loc_32			;*Jump if cx=0
		db	0E3h, 0Ah		;  Fixup - byte match
		in	al,3			; port 3, DMA-1 bas&cnt ch 1
;*		jcxz	loc_33			;*Jump if cx=0
		db	0E3h, 0Ch		;  Fixup - byte match
		and	ch,17h
;*		aad	15h			; undocumented inst
		db	0D5h, 15h		;  Fixup - byte match
		and	si,[bp+di]
		and	[bx+di],dx
;*		jcxz	loc_34			;*Jump if cx=0
		db	0E3h, 1Ch		;  Fixup - byte match
		sub	ch,[si]
		in	al,21h			; port 21h, 8259-1 int IMR
		adc	sp,bx
		or	al,0Ah
		dec	ax
		push	ax
		in	al,15h			; port 15h ??I/O Non-standard
		and	si,[bp+di]
		and	[bx+di],dx
		jcxz	loc_35			; Jump if cx=0
		sub	bh,[bx+si]
		in	al,48h			; port 48h ??I/O Non-standard
		inc	ax
;*		and	ch,0Fh
		db	 82h,0E5h, 0Fh		;  Fixup - byte match
		cmc				; Complement carry
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
;*		add	bl,dl
		db	 00h,0D3h		;  Fixup - byte match
		db	 26h, 26h, 20h, 66h, 38h, 7Ah
		db	 50h,0F6h, 4Eh, 02h, 26h, 26h
		db	 20h,0F0h, 01h
loc_35:
		push	es
		xor	ax,3633h
		adc	ax,1113h
		jcxz	$+1Eh			; Jump if cx=0
loc_36:
		adc	bp,2FE5h
;*		loopz	locloop_37		;*Loop if zf=1, cx>0

		db	0E1h, 02h		;  Fixup - byte match
		cmc				; Complement carry
;*		xor	al,1
		db	 80h,0F0h, 01h		;  Fixup - byte match
		cld				; Clear direction
;*		mov	byte ptr ds:[71F6h],al
		db	 88h, 06h,0F6h, 71h	;  Fixup - byte match
		add	bh,bl
		push	cs
		add	dh,al
;*		add	al,dh
		db	 00h,0F0h		;  Fixup - byte match
		add	[bx+si+40h],ax
		adc	ch,0E5h
		aas				; Ascii adjust
		loopz	$-100h			; Loop if zf=1, cx>0

		push	ax
                           lock	add	ah,[di]
		xor	ax,[bp+di+31h]
;*		and	bx,sp
		db	 21h,0E3h		;  Fixup - byte match
		sub	al,3Ah			; ':'
		cmp	al,0E4h
		xor	[bp+di],sp
		jcxz	$+5Eh			; Jump if cx=0
		pop	dx
		or	[bx+si],dl
		in	al,25h			; port 25h ??I/O Non-standard
		xor	ax,[bp+di+31h]
;*		and	bx,sp
		db	 21h,0E3h		;  Fixup - byte match
		sub	al,3Ah			; ':'
		dec	ax
		in	al,8			; port 8, DMA-1 status reg
		add	byte ptr ds:[1FE5h][di],al
		cmc				; Complement carry
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	dl,bl
		cmp	ah,ah
		xor	[bx+si],si
		db	 68h, 36h, 35h, 75h, 10h,0F6h
		db	0AEh, 02h,0D3h, 3Ah,0E4h, 31h
		db	 30h,0F0h, 03h, 08h, 15h, 19h
		db	 10h, 2Ch,0E4h
		db	 33h, 35h
loc_38:
		inc	ax
		push	ax
;*		and	ch,17h
		db	 82h,0E5h, 17h		;  Fixup - byte match
		shr	byte ptr [bp+si+1Ah],cl	; Shift w/zeros fill
;*		jp	loc_42			;*Jump if parity=1
		db	 7Ah, 68h		;  Fixup - byte match
		sbb	[bx+si+66h],bh
		push	ss
		jbe	loc_38			; Jump if below or =
		add	al,5
		sbb	[si],bx
		sti				; Enable interrupts
;*		jl	loc_39			;*Jump if <
		db	 7Ch, 02h		;  Fixup - byte match
                           lock	add	[bx+si],al
;*                         lock	add	al,dh
		db	0F0h, 00h,0F0h		;  Fixup - byte match
		add	[bx+si+40h],ax
		adc	ch,0E5h
		aas				; Ascii adjust
;*		loopz	locloop_40		;*Loop if zf=1, cx>0

		db	0E1h, 04h		;  Fixup - byte match
                           lock	add	ah,[di]
		xor	ax,[bp+di+31h]
;*		and	bx,sp
		db	 21h,0E3h		;  Fixup - byte match
		sub	al,3Ah			; ':'
		cmp	al,0E4h
		xor	[bp+di],sp
		jcxz	loc_43			; Jump if cx=0
		pop	dx
		or	[bx+si],dl
		in	al,25h			; port 25h ??I/O Non-standard
		xor	ax,[bp+di+31h]
;*		and	bx,sp
		db	 21h,0E3h		;  Fixup - byte match
		sub	al,3Ah			; ':'
		dec	ax
		in	al,8			; port 8, DMA-1 status reg
		add	ss:data_18e[bp+si],al
		cmc				; Complement carry
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	dl,bl
		db	 36h, 36h, 30h, 66h, 48h, 7Ah
		db	 10h,0F6h, 17h, 03h, 36h, 36h
		db	 30h,0F0h, 03h, 06h, 35h, 33h
		db	 36h, 15h, 13h, 11h,0E3h, 1Ch
loc_41:
		inc	ax
		inc	ax
;*		and	ch,27h			; '''
		db	 82h,0E5h, 27h		;  Fixup - byte match
		shr	byte ptr [bp+si+1Ah],cl	; Shift w/zeros fill
		jp	loc_45			; Jump if parity=1
		sbb	[bx+si+66h],bh
		push	ss
		jbe	loc_41			; Jump if below or =
		add	al,5
		sbb	[si],bx
		sti				; Enable interrupts
		out	2,al			; port 2, DMA-1 bas&add ch 1
;*                         lock	add	ch,cl
		db	0F0h, 00h,0CDh		;  Fixup - byte match
;*		add	bh,cl
		db	 00h,0CFh		;  Fixup - byte match
		add	dl,al
		add	cl,dh
		or	dl,cl
		or	al,dl
		cmc				; Complement carry
		sub	al,0F0h
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
		out	dx,ax			; port 29FBh ??I/O Non-standard
		add	si,si
loc_43:
		pop	ax
		add	dx,[bx+si]
		adc	[bx+si],bl
		xor	byte ptr ds:[3010h],al
		push	es
		adc	[bx+si],bl
		cmp	data_12,al
		cmc				; Complement carry
		sub	al,0F0h
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
		out	dx,ax			; port 7A43h ??I/O Non-standard
		add	si,si
;*		jo	loc_44			;*Jump if overflow=1
		db	 70h, 03h		;  Fixup - byte match
		adc	[bx+si],dl
		sbb	[bx+si],dh
		push	es
		adc	[bx+si],dh
		push	es
		adc	[bx+si],bh
		push	es
		cmp	data_12,al
		cmp	data_16,al
;*                         lock	add	ah,bh
		db	0F0h, 00h,0FCh		;  Fixup - byte match
		out	dx,ax			; port 7A43h ??I/O Non-standard
		add	si,si
		mov	ax,[bp+di]
		adc	[bx+si],dl
		sbb	[bx+si],dh
		push	es
		xor	data_13,al
		retf	3806h			; Return far
		db	 06h,0C8h,0FFh,0CAh,0FFh
loc_45:
		cmp	ds:data_22e,al
		retf	38FFh
			                        ;* No entry point to code
		push	es
		db	0C8h,0FFh,0CAh,0FFh, 38h, 06h
		db	0C8h,0FFh,0CAh,0FFh, 38h, 06h
		db	0C8h,0FFh,0CAh,0FFh, 38h, 06h
		db	0C8h,0FFh,0CAh,0FFh, 38h, 06h
		db	0C8h,0FFh,0CAh,0FFh, 38h, 06h
		db	0C8h, 02h,0CAh, 02h,0F5h, 1Ch
		db	0F0h, 00h,0FCh,0EFh, 03h,0F6h
		db	0D0h, 03h, 10h, 10h, 18h, 10h
		db	 38h, 06h, 38h, 06h, 38h, 06h
		db	 38h, 06h, 38h, 06h, 38h, 06h
		db	 38h, 06h, 38h, 06h,0FBh, 49h
		db	 03h,0F0h, 00h, 10h, 10h, 18h
		db	 30h, 06h, 10h, 30h, 06h, 10h
		db	 18h, 10h,0FEh,0F0h, 00h,0E0h
		db	 8Ch, 80h,0E5h, 17h,0D4h,0F5h
		db	 28h,0F0h, 00h,0FCh, 88h, 06h
		db	0F6h, 07h, 04h, 05h,0E3h, 0Ah
		db	0E4h, 03h,0E3h, 0Ch, 81h,0E5h
		db	 17h,0D5h, 15h, 23h, 33h, 21h
		db	 11h,0E3h, 1Ch, 2Ah, 2Ch,0E4h
		db	 21h, 13h,0E3h, 0Ch, 0Ah, 48h
		db	 50h,0E4h, 15h, 23h, 33h, 21h
		db	 11h,0E3h, 1Ch
		db	2Ah
loc_46:
;*		cmp	ah,ah
		db	 38h,0E4h		;  Fixup - byte match
		dec	ax
;*		and	ch,2Fh			; '/'
		db	 82h,0E5h, 2Fh		;  Fixup - byte match
;*		aad	9			; undocumented inst
		db	0D5h, 09h		;  Fixup - byte match
		push	es
		add	ax,503h
		add	ax,[bx+di]
;*		jcxz	loc_48			;*Jump if cx=0
		db	0E3h, 0Ch		;  Fixup - byte match
		in	al,1			; port 1, DMA-1 bas&cnt ch 0
		jcxz	$+0Eh			; Jump if cx=0
		or	cl,[bx+di]
		or	cl,[si]
		in	al,1			; port 1, DMA-1 bas&cnt ch 0
		add	ax,ss:data_17e[bp+di]
;*		sal	bp,cl			; Shift w/zeros fill
		db	0D3h,0F5h		;  Fixup - byte match
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	[bp+si],ch
		in	al,21h			; port 21h, 8259-1 int IMR
		and	[bx+si+26h],ch
		and	ax,5075h
		jcxz	$-8			; Jump if cx=0
		push	bp
		add	al,2Ah			; '*'
		in	al,21h			; port 21h, 8259-1 int IMR
;*		and	al,dh
		db	 20h,0F0h		;  Fixup - byte match
		add	[bx+si],cx
		adc	ax,1019h
		sub	al,0E4h
		xor	si,[di]
		and	ch,17h
;*		aam	0F5h			; undocumented inst
		db	0D4h,0F5h		;  Fixup - byte match
;*		xor	al,1
		db	 80h,0F0h, 01h		;  Fixup - byte match
		cld				; Clear direction
;*		mov	byte ptr ds:[78F6h],al
		db	 88h, 06h,0F6h, 78h	;  Fixup - byte match
		add	al,0FBh
		std				; Set direction flag
		add	si,ax
		add	byte ptr ss:[0E5D4h][bp+si],al
		pop	ds
		loopz	$+22h			; Loop if zf=1, cx>0

		cmc				; Complement carry
;*		adc	al,dh
		db	 10h,0F0h		;  Fixup - byte match
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
		xchg	di,ax
		push	es
		db	0F6h, 8Dh, 04h,0D3h,0FCh,0A8h
		db	 06h,0F5h, 10h,0F0h, 00h
		db	8
loc_49:
		in	al,3			; port 3, DMA-1 bas&cnt ch 1
		or	[bp+si],cl
		or	al,0Ah
		or	[bp+di],al
		jcxz	loc_49			; Jump if cx=0
		db	 9Bh, 04h,0FCh,0A8h, 06h,0D3h
		db	0F5h, 10h,0F0h, 00h, 05h, 09h
		db	 0Ah, 0Ch,0F6h,0B0h, 04h,0D5h
		db	0E1h, 40h, 09h, 06h, 05h, 03h
		db	 05h, 03h, 01h,0E3h, 0Ch,0E4h
		db	 01h,0E3h, 0Ch, 0Ah, 09h, 0Ah
		db	 0Ch,0E4h, 01h, 03h,0E1h, 20h
		db	0F5h, 08h,0F0h, 00h, 84h,0E5h
		db	 17h,0D3h, 26h, 26h, 20h, 66h
		db	 38h, 82h,0E5h, 17h,0D4h, 2Ah
		db	0E4h, 23h, 01h,0E3h, 2Ch, 2Ah
		db	0E4h, 25h, 23h, 21h,0E3h, 0Ch
		db	 2Ah,0E4h, 23h, 01h,0E3h, 2Ch
		db	 2Ah,0E4h, 25h, 03h,0E3h, 09h
		db	 0Ah, 0Ch, 09h,0F6h,0D4h, 04h
		db	 84h,0E5h, 17h,0D3h, 26h, 26h
		db	 20h,0F0h, 01h, 06h, 35h, 33h
		db	 36h, 15h, 13h, 11h,0E3h, 1Ch
		db	 82h,0D4h,0E5h, 1Fh,0F5h, 30h
		db	0F0h, 01h,0FCh, 97h, 06h,0F6h
		db	 1Ah, 05h,0FBh, 83h, 04h,0F0h
		db	 00h,0D1h,0E5h, 07h,0F0h, 04h
		db	0DAh,0F5h, 10h,0F0h, 04h, 85h
		db	 3Ah, 86h
data_16		db	4Ah
		db	 4Ah, 87h, 38h, 86h, 4Ah, 85h
		db	 3Ah, 86h, 4Ah, 85h, 3Ah,0DDh
		db	 87h, 48h, 85h,0E4h, 41h,0E3h
		db	 4Ch, 4Bh,0DAh,0F6h, 2Fh, 05h
		db	 85h, 3Ah, 86h, 4Ah, 4Ah, 87h
		db	 38h, 86h, 4Ah, 85h, 3Ah, 86h
		db	 4Ah, 85h, 3Ah, 87h, 38h, 40h
		db	 86h, 48h, 85h, 3Ah, 86h, 4Ah
		db	 4Ah, 87h, 38h, 86h, 4Ah, 85h
		db	 3Ah, 86h, 4Ah, 85h, 3Ah, 87h
		db	 38h, 86h, 4Ah, 4Ah, 85h, 38h
		db	 86h, 48h, 48h, 87h, 38h, 86h
		db	 48h, 85h, 38h, 86h, 48h, 85h
		db	 38h, 87h, 38h, 86h, 48h, 48h
		db	 85h, 38h, 86h, 48h, 48h, 87h
		db	 38h, 86h, 48h, 85h, 38h, 86h
		db	 48h, 85h, 38h, 87h, 38h, 40h
		db	 86h, 48h, 85h, 3Ah, 86h, 4Ah
		db	 4Ah, 87h, 38h, 86h, 4Ah, 85h
		db	 3Ah, 86h, 4Ah, 85h, 3Ah,0DDh
		db	 87h, 48h, 85h,0E4h, 41h,0E3h
		db	 4Ch, 4Bh,0DAh, 85h, 3Ah, 86h
		db	 4Ah, 4Ah, 87h, 38h, 86h, 4Ah
		db	 85h, 3Ah, 86h, 4Ah, 85h, 3Ah
		db	 87h, 38h, 86h, 4Ah, 4Ah, 85h
		db	 35h, 86h, 45h, 45h, 87h, 38h
		db	 86h, 45h, 85h, 35h, 86h, 45h
		db	 85h, 35h, 87h, 38h, 86h, 45h
		db	 45h, 85h, 39h, 86h, 49h, 49h
		db	 87h, 38h, 86h, 49h, 85h, 3Ch
		db	 86h, 4Ch, 85h, 3Ch, 87h, 38h
		db	0DDh, 48h, 48h,0DAh,0F5h, 09h
		db	0F0h, 04h,0FCh,0BEh, 06h,0F5h
		db	 08h,0F0h, 04h, 85h, 3Ah, 86h
		db	 4Ah, 4Ah, 87h, 38h, 86h, 4Ah
		db	 85h, 3Ah, 86h, 4Ah, 85h, 3Ah
		db	 87h, 38h, 86h, 48h, 48h,0F6h
		db	0FCh, 05h,0F6h,0F5h, 45h,0FCh
		db	0BEh, 06h, 85h, 35h, 86h, 45h
		db	 45h, 87h, 38h, 86h, 45h, 85h
		db	 39h, 86h, 49h, 85h, 39h, 87h
		db	 38h, 86h, 49h, 49h, 85h, 3Ch
		db	 86h, 4Ch, 4Ch, 87h, 38h, 86h
		db	 4Ch, 85h, 39h, 86h, 49h, 85h
		db	 39h,0DDh, 87h, 48h, 85h,0E4h
		db	 41h,0E3h, 4Ch, 4Bh,0DAh, 85h
		db	 3Ah, 3Ah, 10h, 3Ah, 3Ah, 60h
		db	 3Ah, 10h, 3Ah, 60h, 3Ah, 3Ah
		db	 70h, 3Ah, 10h, 88h,0DDh,0C9h
		db	 45h,0C0h, 46h,0C0h, 47h,0C0h
		db	 48h,0C0h, 49h,0C0h, 4Ah,0C0h
		db	 4Bh,0C0h, 4Ch,0DDh, 84h,0E5h
		db	 07h,0D1h,0F0h, 05h, 0Ah, 1Ah
		db	 2Ah, 08h, 18h, 28h, 06h, 16h
		db	 26h, 35h, 49h, 5Ch,0DEh, 87h
		db	0E5h, 07h, 78h, 78h, 78h, 78h
		db	0FBh, 25h, 05h,0F0h, 05h, 75h
		db	0E3h, 7Ah,0E4h, 73h,0E3h, 7Ch
		db	0E4h, 71h,0E3h, 7Ah,0E4h,0FEh
		db	0F0h
loc_50:
		add	ax,0E41Ah
		adc	si,[bx+di-1Dh]
		sbb	al,1Ah
		in	al,15h			; port 15h ??I/O Non-standard
		jnc	loc_54			; Jump if carry=0
		jcxz	$+1Eh			; Jump if cx=0
loc_53:
		jns	loc_53			; Jump if not sign
                           lock	add	ax,10F5h
                           lock	add	ax,0E47Ah
		jnz	loc_55			; Jump if not zero
		jl	loc_50			; Jump if <
;*		jno	loc_51			;*Jump if not overflw
		db	 71h,0E3h		;  Fixup - byte match
;*		jl	loc_56			;*Jump if <
		db	 7Ch, 7Ah		;  Fixup - byte match
;*		jnz	loc_52			;*Jump if not zero
		db	 75h,0E3h		;  Fixup - byte match
		imul	byte ptr ds:data_3e[si]	; ax = data * al
                           lock	add	ax,1685h
		xchg	[bp+76h],dh
		xchg	[bx+si],bx
		xchg	[bp-7Bh],dh
		push	ss
		xchg	[bp-7Bh],dh
		push	ss
		xchg	[bx+si],bx
		xchg	[bp+76h],dh
		test	dx,ds:data_2e
		jbe	$-77h			; Jump if below or =
		sbb	byte ptr ss:[8576h][bp],al
		push	ss
		xchg	[bp-7Bh],dh
		push	ss
		xchg	[bx+si],bx
		xchg	[bx+si+78h],bh
		inc	byte ptr ds:[0C24h]
		sbb	[bx+si+30h],ah
		test	dl,byte ptr ds:[0C9Ch][bx+si]
		cmp	al,30h			; '0'
		db	0C0h, 06h, 48h, 6Ch, 60h, 30h
		db	 24h, 0Ch, 18h, 06h, 84h, 90h
		db	 9Ch, 0Ch, 3Ch, 30h,0C0h,0BAh
		db	 48h, 6Ch, 60h, 30h, 08h, 0Ch
		db	 06h, 02h, 18h
		db	 24h, 48h, 0Ch, 6Ch, 60h
loc_54:
		xor	[bx+si],bl
		add	al,ds:data_1e
		adc	[bx],al
		pop	es
		add	[bx+di+41h],dx
		sbb	ax,4000h
		xor	bx,0EF5h
		add	[bx+si],al
		add	[bp+si],al
loc_55:
		add	al,[bx+di]
		and	al,21h			; '!'
		pushf				; Push flags
;*		add	bl,dh
		db	 00h,0F3h		;  Fixup - byte match
		db	0F3h, 38h, 88h, 00h, 00h, 00h
		db	 00h, 02h, 02h, 01h, 41h,0A1h
		db	 1Eh, 00h, 80h, 63h,0F3h, 35h
		db	 0Eh, 00h, 00h, 00h, 02h, 02h
		db	 01h, 20h, 21h, 10h, 00h,0F5h
		db	0F4h, 54h, 37h, 02h, 00h, 0Ah
		db	 0Ah, 05h, 05h, 01h,0E4h, 01h
		db	 52h, 00h,0F5h,0F4h,0D3h,0F6h
		db	 08h, 00h, 00h, 00h, 02h, 02h
		db	 01h, 61h,0B2h, 0Fh, 00h,0F1h
		db	0C5h, 23h, 07h, 48h, 00h, 00h
		db	 00h, 02h, 02h, 81h, 00h, 01h
		db	 17h, 03h, 05h, 6Eh, 32h, 1Fh
		db	 38h, 00h, 04h, 0Eh, 15h, 15h
		db	 05h, 05h, 01h, 00h, 01h, 03h
		db	 17h, 09h, 5Fh, 11h, 0Fh, 38h
		db	 00h, 05h, 0Eh, 43h, 43h, 04h
		db	 04h, 81h, 00h, 01h, 1Fh, 02h
		db	 09h, 6Eh, 31h, 1Fh, 38h, 00h
		db	 03h, 01h, 1Fh, 1Fh, 02h, 02h
		db	 01h, 00h, 01h, 03h, 17h, 09h
		db	 5Fh, 11h, 0Fh, 38h, 00h, 03h
		db	 00h, 11h, 11h, 04h, 04h, 01h
		db	 00h, 02h, 03h, 10h, 0Bh,0DAh
		db	 01h, 1Fh, 38h, 00h, 03h, 00h
		db	 00h, 00h, 02h, 02h, 81h, 01h
		db	 02h,0D0h, 01h, 07h, 99h, 01h
		db	0FFh, 38h, 00h, 05h, 00h, 00h
		db	 00h, 02h, 02h, 81h, 00h, 01h
		db	 01h, 01h, 07h, 99h, 01h, 1Eh
		db	 38h, 00h, 05h, 00h,0FFh, 00h
		db	 71h, 70h, 01h, 01h, 02h,0B4h
		db	 01h, 07h, 5Fh, 01h,0FEh, 87h
		db	 00h, 04h, 01h,0E5h, 47h, 06h
		db	 02h, 01h, 00h, 02h, 09h, 38h
		db	 09h, 5Fh, 01h, 2Fh, 87h, 00h
		db	 04h

_388UNKN	endp

seg_a		ends



		end	start
