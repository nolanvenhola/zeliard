
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_387UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	571h			;*
data_2e		equ	2A80h			;*
data_3e		equ	3937h			;*
data_4e		equ	0F005h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_387UNKN	proc	far

start:
		cmp	al,0Dh
		add	[bx+si],al
		sub	al,6
		or	al,7
		test	ax,[di]
		mov	sp,105h
		pop	ds
		add	[bp+si],al
		sbb	ax,301h
		and	ax,[bp+si]
		add	al,66h			; 'f'
		add	cl,[bx+di]
		push	bp
		add	ax,ds:data_1e
		pop	es
;*		jbe	loc_1			;*Jump if below or =
		db	 76h, 05h		;  Fixup - byte match
		or	[bp+di+5],bh
		or	ds:data_4e[bx+si],ax
;*		add	cl,ch
		db	 00h,0E9h		;  Fixup - byte match
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
		db	 6Eh,0F0h, 00h,0E9h, 00h,0F5h
		db	 01h, 04h,0F0h, 00h,0E9h, 00h
		db	0A0h,0E6h, 48h,0E5h, 7Fh,0E2h
		db	 40h, 00h, 01h, 02h, 11h, 21h
		db	 02h, 03h, 04h, 12h,0E6h, 3Fh
		db	0E5h, 46h,0A0h
		db	'15AQ36CS07@P48Dd'
		db	0F6h, 01h, 2Ch, 00h,0A0h,0E6h
		db	 59h,0E5h, 78h, 12h, 09h, 09h
		db	 5Ah, 50h, 74h,0F0h, 01h, 01h
		db	 11h, 9Ch,0E5h, 69h, 24h, 01h
		db	 11h,0A4h,0E5h, 5Ah, 24h, 01h
		db	 11h,0A0h,0E5h
		db	'x2IIZP$'
		db	'#P'
		db	 14h, 12h
		db	'KLMNMLKO2IIZP$'
		db	 01h, 11h,0A4h,0E5h, 69h, 24h
		db	 01h, 11h, 9Ch,0E5h, 5Ah, 24h
		db	 01h, 11h,0A0h,0E5h
		db	'x2IIZP$'
		db	'#Pd'
		db	0E6h, 03h, 9Ch,0E5h, 6Eh, 4Eh
		db	0E9h, 01h, 40h, 41h, 42h, 43h
		db	 44h,0A0h,0E5h, 78h,0E6h
		db	'YEFWXYvVWXYXw'
		db	 16h, 56h, 57h, 58h,0F0h, 02h
		db	 05h, 15h,0E6h, 03h,0A4h,0E5h
		db	'n*', 27h, ')&', 27h, '56%4#$'
		db	'%&'
		db	0A0h,0E5h, 78h,0E6h
		db	'Y789F67898GVj:)*y'
		db	0F0h, 03h, 09h,0A0h,0E6h, 48h
		db	0E5h, 7Fh, 19h, 1Ah, 17h, 2Bh
		db	 12h, 13h, 1Bh, 33h, 4Bh, 1Ch
		db	 10h, 5Bh, 19h, 1Ah, 17h, 1Bh
		db	 6Bh, 4Bh, 12h, 13h, 1Bh, 33h
		db	 6Bh, 1Dh, 1Eh, 1Ch, 10h,0FBh
		db	 25h, 00h,0FFh,0F0h, 03h,0E9h
		db	 01h,0E5h, 73h,0E6h, 59h,0F0h
		db	 03h,0E9h, 01h,0F5h, 01h, 04h
		db	0F0h, 03h,0E9h, 01h, 0Bh, 0Bh
		db	0F6h, 01h, 2Ch, 01h, 4Bh,0E2h
		db	 40h, 1Ah, 1Ah, 79h, 76h, 34h
		db	0F0h, 04h, 07h, 17h
		db	'+;JJYVdcV'
		db	 14h, 7Bh, 3Bh, 4Ah, 4Ah, 59h
		db	 56h, 64h, 07h, 17h
		db	'+;JJYVdcV'
		db	0F0h, 05h, 04h
		db	1Bh, '"#467C45565DS456c'
		db	3, 2, 1
		db	'467C45565DSw7&', 27h
		db	0F0h, 06h, 06h,0E1h, 00h, 40h
		db	 16h, 1Fh, 00h, 3Fh, 1Fh, 00h
		db	 3Eh, 1Fh, 00h, 3Dh, 1Fh, 00h
		db	 3Ch, 1Fh, 00h, 3Bh, 1Fh, 00h
		db	 3Ah, 1Fh, 00h, 39h, 1Fh, 00h
		db	 38h, 1Fh, 00h, 37h, 1Fh, 00h
		db	 36h, 1Fh, 00h, 35h, 1Fh, 00h
		db	 34h, 1Fh, 00h, 33h, 1Fh, 00h
		db	 32h, 1Fh, 00h, 31h, 1Fh, 00h
		db	 30h, 1Fh, 00h, 2Fh, 1Fh, 00h
		db	 2Eh, 1Fh, 00h, 2Dh, 1Fh, 00h
		db	 2Ch, 1Fh, 00h, 2Bh, 1Fh, 00h
		db	 2Ah, 1Fh, 00h, 29h, 1Fh, 00h
		db	 28h, 1Fh, 00h, 27h, 1Fh, 00h
		db	 26h, 1Fh, 00h, 25h, 1Fh, 00h
		db	 24h, 1Fh, 00h, 23h, 1Fh, 00h
		db	 22h, 1Fh, 00h, 21h, 1Fh, 00h
		db	 20h, 1Fh, 00h, 1Fh, 1Fh, 00h
		db	 1Eh, 1Fh, 00h, 1Dh, 1Fh, 00h
		db	 1Ch, 1Fh, 00h, 1Bh, 1Fh, 00h
		db	 1Ah, 1Fh, 00h, 19h, 1Fh, 00h
		db	 18h, 1Fh, 00h, 17h, 1Fh, 00h
		db	 16h, 1Fh, 00h, 15h, 1Fh, 00h
		db	 14h, 1Fh, 00h, 13h, 1Fh, 00h
		db	 12h, 1Fh, 00h, 11h,0E1h, 00h
		db	 40h, 0Bh, 0Bh, 0Bh,0FBh, 25h
		db	 01h,0FFh,0F0h, 06h,0E9h, 01h
		db	0E5h, 6Eh,0A0h,0E6h, 68h,0F0h
		db	 06h,0E9h, 01h,0F5h, 01h, 18h
		db	0F0h, 06h,0E9h, 01h,0E2h, 40h
		db	0E9h, 02h
		db	' 12#0!20312#'
		db	0F6h, 01h, 33h, 02h,0F5h, 01h
		db	 04h,0F0h, 06h,0E9h, 02h
		db	'$'
		db	'315 1" 4312'
		db	0F6h, 01h, 4Eh, 02h,0FBh, 2Ch
		db	 02h,0FFh,0F0h, 06h,0E9h, 02h
		db	0F0h, 06h,0E9h, 02h,0A0h,0E5h
		db	 7Fh,0E6h, 42h,0F5h, 01h, 08h
		db	0F0h, 06h,0E9h, 02h,0E2h
		db	'@ 214!"1 61%'
		db	0F6h, 01h, 76h, 02h,0F5h, 01h
		db	 03h,0F0h, 06h,0E9h, 02h
		db	' 214!"1 61% 214!"1 6705'
		db	0F6h, 01h, 8Eh, 02h
		db	' 214!"1 61% 214!"1 6128'
		db	0F5h, 01h, 02h,0F0h, 06h,0E9h
		db	 02h
		db	'%214!"521$'
		db	'12'
		db	0F6h, 01h,0C7h, 02h,0F5h, 01h
		db	 02h,0F0h, 06h,0E9h, 02h
		db	')162&!916"61'
		db	0F6h, 01h,0DEh, 02h,0F5h, 01h
		db	 02h,0F0h, 06h,0E9h, 02h
		db	'%214!"521'
data_5		db	24h			; Data table (indexed access)
		db	 31h, 32h,0F6h, 01h,0F5h, 02h
		db	')162&!916"61)162&!9161284'
		db	0E5h, 73h,0A0h,0E6h, 78h
		db	'*+*<,<:<*,*<,<:<*+*<L<<:<*+*<,<:'
		db	'<*+*<,<:<Z'
		db	0FBh, 6Ah, 02h,0FFh,0F0h, 06h
		db	0E9h, 02h,0F0h, 06h,0E9h, 02h
		db	0F5h, 01h, 03h,0F0h, 06h,0E9h
		db	 02h,0E5h, 7Fh,0E7h, 0Ah,0E2h
		db	 4Eh, 6Dh, 6Dh,0E2h, 6Ah, 6Eh
		db	 7Fh,0E2h, 4Eh, 7Dh, 7Dh, 7Dh
		db	0E2h, 6Ah,0E9h, 03h, 70h, 31h
		db	0E2h, 4Eh, 62h,0E2h, 6Ah, 73h
		db	0E2h, 4Eh, 62h,0E2h, 6Ah, 73h
		db	0E2h, 4Eh, 72h, 62h,0E2h, 6Ah
		db	 73h, 63h,0E2h, 4Eh, 72h, 72h
		db	0E2h, 6Ah, 60h,0E2h, 5Ch, 74h
		db	 31h,0E2h, 4Eh, 62h,0E2h, 6Ah
		db	 73h,0E2h, 4Eh, 72h,0E5h, 7Fh
		db	0E7h, 0Ah, 62h, 62h,0E2h, 6Ah
		db	 73h,0E2h, 4Eh, 72h, 72h, 72h
		db	0E2h, 6Ah, 70h, 31h,0E2h, 4Eh
		db	 62h,0E2h, 6Ah, 73h,0E2h, 4Eh
		db	 62h,0E2h, 6Ah, 73h,0E2h, 4Eh
		db	 72h, 62h,0E2h, 6Ah, 73h, 63h
		db	0E2h, 4Eh, 72h, 72h,0E2h, 6Ah
		db	 70h, 70h, 65h, 73h, 31h,0F6h
		db	 01h, 60h, 03h,0E5h, 7Fh,0E7h
		db	 0Ah,0E2h, 4Eh, 62h, 62h,0E2h
		db	 6Ah, 63h, 76h,0E2h, 4Eh, 72h
		db	 72h, 72h,0E2h, 6Ah, 70h, 31h
		db	0E2h, 4Eh, 62h,0E2h, 6Ah, 73h
		db	0E2h, 4Eh, 62h,0E2h, 6Ah, 73h
		db	0E2h, 4Eh, 72h, 62h,0E2h, 6Ah
		db	 73h, 63h,0E2h, 4Eh, 72h, 72h
		db	0E2h, 6Ah, 60h,0E2h, 5Ch, 74h
		db	 31h,0E2h, 4Eh, 62h,0E2h, 6Ah
		db	 73h,0E2h, 4Eh, 72h,0E5h, 7Fh
		db	0E7h, 0Ah, 62h, 62h,0E2h, 6Ah
		db	 73h,0E2h, 4Eh, 72h, 72h, 72h
		db	0E2h, 6Ah, 70h, 31h,0E2h, 4Eh
		db	 62h,0E2h, 6Ah, 73h,0E2h, 4Eh
		db	 62h,0E2h, 6Ah, 73h,0E2h, 4Eh
		db	 72h, 62h,0E2h, 6Ah, 73h, 63h
		db	0E2h, 4Eh, 72h, 72h,0E2h, 6Ah
		db	 70h, 70h, 70h, 70h,0F5h, 01h
		db	 08h,0F0h, 06h,0E9h, 03h,0E5h
		db	 7Fh,0E7h, 0Ah,0E2h, 4Eh, 62h
		db	 62h,0E2h, 6Ah, 63h, 76h,0E2h
		db	 4Eh, 72h, 72h, 72h,0E2h, 6Ah
		db	 70h, 31h,0E2h, 4Eh, 62h,0E2h
		db	 6Ah, 73h,0E2h
		db	4Eh
loc_3:
		db	 62h,0E2h, 6Ah, 73h,0E2h

locloop_4:
		dec	si
loc_5:
		jc	$+64h			; Jump if carry Set
		loop	$+6Ch			; Loop if cx > 0

loc_6:
		jnc	$+65h			; Jump if carry=0
;*		loop	locloop_13		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		jc	$+74h			; Jump if carry Set
loc_7:
		loop	$+6Ch			; Loop if cx > 0

		db	 60h,0E2h, 5Ch
loc_8:
		jz	$+33h			; Jump if zero
		loop	$+50h			; Loop if cx > 0

		db	62h
loc_9:
		loop	$+6Ch			; Loop if cx > 0

		jnc	loc_3			; Jump if carry=0
		dec	si
loc_10:
		jc	loc_5			; Jump if carry Set
		jg	loc_6			; Jump if >
		or	ah,[bp+si+62h]
		loop	locloop_15		; Loop if cx > 0

		jnc	$-1Ch			; Jump if carry=0
		dec	si
		jc	$+74h			; Jump if carry Set
		jc	$-1Ch			; Jump if carry Set
		db	 6Ah, 70h, 31h,0E2h, 4Eh, 62h
		db	0E2h, 6Ah, 73h,0E2h, 4Eh, 62h
		db	0E2h, 6Ah, 73h,0E2h, 4Eh, 72h
		db	 62h,0E2h, 6Ah, 73h, 63h,0E2h
		db	 4Eh, 72h, 72h,0E2h, 6Ah, 70h
		db	 31h, 63h, 60h,0E2h, 4Eh, 72h
		db	0E2h, 6Ah, 60h,0E2h, 4Eh, 72h
		db	0F6h
loc_12:
		add	[bx+si+4],cx
		db	 62h,0E2h, 6Ah, 63h, 76h,0E2h
		db	 4Eh, 72h, 72h, 72h,0E2h, 6Ah
		db	 70h, 31h,0E2h, 4Eh, 62h,0E2h
		db	 6Ah, 73h,0E2h, 4Eh, 62h,0E2h
		db	 6Ah, 73h,0E2h, 4Eh, 72h, 62h
		db	0E2h, 6Ah, 73h,0E2h, 4Eh, 62h
		db	0E2h, 6Ah, 73h,0E2h, 4Eh, 72h
		db	0E2h
		db	 6Ah, 70h
loc_14:
;*		xor	dx,sp
		db	 31h,0E2h		;  Fixup - byte match
		dec	si
		db	 62h,0E2h, 6Ah, 73h,0E2h

locloop_15:
		dec	si
		jc	loc_14			; Jump if carry Set
		add	[bp+si],ax
                           lock	push	es
		jmp	$+6206h
			                        ;* No entry point to code
		loop	locloop_19		; Loop if cx > 0

		jnc	$-1Ch			; Jump if carry=0
		dec	si
		jc	$+74h			; Jump if carry Set
		jc	$-1Ch			; Jump if carry Set
		db	 6Ah, 70h, 31h,0E2h, 4Eh, 62h
		db	0E2h, 6Ah, 73h,0E2h, 4Eh, 62h
		db	0E2h, 6Ah, 73h,0E2h, 4Eh, 72h
		db	 62h,0E2h, 6Ah, 73h,0E2h, 4Eh
		db	 62h,0E2h, 6Ah, 73h,0E2h, 4Eh
		db	 72h,0E2h, 6Ah, 70h, 31h,0E2h
		db	 4Eh, 62h,0E2h, 6Ah, 73h,0E2h
		db	 4Eh, 72h,0F6h, 01h, 00h, 05h
		db	 62h,0E2h, 6Ah, 73h,0E2h, 4Eh
		db	 72h, 72h, 72h,0E2h
		db	 6Ah, 70h

locloop_18:
;*		xor	dx,sp
		db	 31h,0E2h		;  Fixup - byte match
		dec	si
		db	 62h,0E2h, 6Ah, 73h,0E2h, 4Eh
		db	 62h,0E2h, 6Ah, 73h,0E2h, 4Eh
		db	 72h, 62h,0E2h, 6Ah, 73h,0E2h
		db	 4Eh, 62h,0E2h, 6Ah, 73h,0E2h
		db	 4Eh, 72h, 70h, 70h,0E2h, 6Ah
		db	 70h, 70h,0FBh, 59h, 03h,0FFh

locloop_19:
                           lock	push	es
		jmp	loc_7
			                        ;* No entry point to code
                           lock	push	es
		jmp	loc_8
			                        ;* No entry point to code
                           lock	push	es
		jmp	loc_9
		db	0F0h

locloop_20:
		push	es
		jmp	loc_10
			                        ;* No entry point to code
		dec	di
		push	cx
		or	byte ptr [bp+si+4Ch],52h	; 'R'
		dec	bx
		push	ax
		dec	bp
		push	sp
		push	bx
		cmp	[bp+di],di
		cmp	al,3Eh			; '>'
		aaa				; Ascii adjust
		inc	ax
		inc	cx
		inc	bx
		inc	bp
		inc	di
		dec	ax
		dec	dx
		dec	sp
		dec	bp
		dec	di
		push	cx
		cmp	byte ptr ds:data_3e,0FFh
		sub	ax,3432h
		cmp	[bx],si
		sub	si,[bx+si]
		das				; Decimal adjust
		xor	ax,8029h
		inc	bp
		inc	ax
		sub	ah,[si]
		and	ah,ds:data_2e
		and	al,2Eh			; '.'
		sub	[bp+si],sp
		push	es
		add	ax,0D0Ch
		xor	byte ptr ds:[202h],ch
		add	al,[bp+di]
		or	al,0Bh
		sbb	[bx],dl
		adc	dl,[bx+di]
		push	es
		pop	es
		sbb	[bx],dl
		adc	dl,[bx+di]
		or	al,0FFh
		push	es
		add	ax,0B0Ch
		xor	byte ptr ds:[2224h],ch
		or	al,0Dh
		xor	byte ptr ds:[506h],ch
		or	al,0Bh
		and	al,22h			; '"'
		sbb	[bx],dl
		dec	ax
		dec	cx
		db	 60h, 61h, 60h, 5Fh, 06h, 05h
		db	 12h,0FFh, 12h, 11h, 0Ch,0FFh
		db	 30h,0FFh, 18h,0FFh, 0Ch, 0Bh
		db	 06h, 07h, 18h, 17h, 60h,0FFh
		db	 0Ch,0FFh, 06h, 05h, 0Ch, 0Bh
		db	 12h, 11h, 48h,0FFh, 30h, 2Eh
		db	 24h,0FFh, 06h, 05h, 0Ch, 0Bh
		db	 24h, 22h, 18h, 17h, 0Ch, 0Dh
		db	 48h, 49h, 60h, 61h, 02h, 5Fh
		db	 0Ch, 0Bh, 06h, 05h, 06h, 07h
		db	 18h,0FFh, 00h, 01h, 06h, 01h
		db	 04h, 23h, 00h,0DAh, 00h, 9Dh
		db	 01h,0EDh, 01h,0A5h, 02h,0B1h
		db	 02h, 4Ah, 03h, 1Ah, 04h, 01h
		db	 05h,0BDh, 02h, 0Ah, 06h, 73h
		db	 06h,0E8h, 05h, 0Ch, 07h, 0Ch
		db	0B0h, 01h, 05h, 01h, 01h,0F0h
		db	 00h,0E0h, 91h,0E5h, 17h,0F0h
		db	 00h,0F5h, 10h,0F0h, 00h, 83h
		db	0D5h,0FCh,0FDh, 03h, 00h, 85h
		db	0D5h,0FCh, 09h, 04h,0F6h, 2Dh
		db	 00h, 80h,0FCh, 98h, 00h, 15h
		db	 10h,0E3h,0E3h, 2Ah, 2Ch,0E4h
		db	 21h, 23h, 21h,0E3h, 2Ch, 2Ah
		db	 28h,0FCh, 98h, 00h, 35h, 81h
		db	0CEh,0E3h, 23h, 25h, 26h, 28h
		db	 2Ah, 2Ch,0E4h,0C1h, 80h, 21h
		db	 23h, 05h, 06h, 08h, 43h, 03h
		db	 05h, 06h, 08h, 06h, 45h, 13h
		db	 03h, 05h, 06h, 51h, 81h,0CEh
		db	 2Ah, 25h, 28h, 23h, 25h, 01h
		db	 03h, 21h,0E3h, 0Ch, 2Ah, 2Ch
		db	0E4h, 21h, 23h,0C1h, 80h, 05h
		db	 06h, 08h, 43h, 03h, 05h, 06h
		db	 08h, 06h, 45h, 13h, 6Ah, 28h
		db	 2Ah, 78h,0FCh,0B7h, 00h,0FBh
		db	 29h, 00h,0F0h, 00h,0D6h, 00h
		db	 21h, 21h,0E3h, 0Ch, 08h,0F0h
		db	 01h, 05h, 1Ah,0CDh, 05h, 1Ah
		db	0CDh, 05h, 1Ah, 20h,0C5h,0D6h
		db	31h
data_7		dw	0E331h			; Data table (indexed access)
		db	 2Ch, 28h, 05h, 03h, 28h,0FEh
		db	0F0h, 01h, 83h, 38h, 3Ah, 35h
		db	 00h,0E3h
		db	'8:0', 0Ah, ' 35@'
		db	0E4h, 38h, 3Ah, 35h, 10h,0E3h
		db	 20h, 38h, 3Ah, 30h, 0Ah, 50h
		db	0E3h, 38h, 3Ah,0E4h, 33h, 35h
		db	0FEh,0F0h, 00h, 82h,0E5h, 0Fh
		db	0F5h, 20h,0F0h, 00h,0FCh, 50h
		db	 01h,0F6h,0E1h, 00h,0FCh, 50h
		db	 01h,0FCh, 63h, 01h,0FCh, 50h
		db	 01h,0FCh, 63h, 01h,0FCh, 50h
		db	 01h,0FCh, 63h, 01h,0FCh, 50h
		db	 01h,0D2h, 0Ah,0E4h, 25h, 23h
		db	 28h, 03h, 05h, 23h,0E3h, 0Ah
		db	0E4h, 21h, 23h, 25h, 26h,0FCh
		db	 77h, 01h,0FCh, 77h, 01h,0FCh
loc_22:
		mov	al,[bx+di]
		cld				; Clear direction
		mov	al,[bx+di]
		cld				; Clear direction
		ja	loc_23			; Jump if above
		cld				; Clear direction
loc_23:
		ja	$+3			; Jump if above
		cld				; Clear direction
		mov	al,[bx+di]
		rol	byte ptr ds:[23E4h],cl	; Rotate
		and	[di],sp
		add	[bp+di],ax
		jcxz	$+28h			; Jump if cx=0
		in	al,23h			; port 23h ??I/O Non-standard
		and	[bp+di],sp
		and	ax,2826h
		test	dl,dl
		cmc				; Complement carry
;*		adc	al,dh
		db	 10h,0F0h		;  Fixup - byte match
		add	[bx+si],cl
		sub	ah,[bp+di]
		jcxz	$+2Ah			; Jump if cx=0
		or	ah,ah			; Zero ?
		and	ax,[di]
		jcxz	$+0Ch			; Jump if cx=0
		in	al,28h			; port 28h ??I/O Non-standard
		sub	ah,[bp+di]
		and	ax,38F6h
;*		add	bx,di
		db	 01h,0FBh		;  Fixup - byte match
		db	0DAh, 00h,0F0h, 00h,0D2h, 0Ah
		db	0E4h, 25h, 23h, 28h, 03h, 05h
		db	 23h,0E3h, 0Ah,0E4h, 21h, 23h
		db	0E3h, 08h,0FEh,0F0h, 00h,0D2h
		db	 0Ah,0E4h, 25h, 23h, 28h, 03h
		db	 05h, 23h,0E3h, 0Ah,0E4h, 21h
		db	0E3h, 2Ch, 2Ah, 28h,0FEh,0F0h
		db	 00h,0D2h, 08h,0E4h, 25h, 23h
		db	 28h, 03h, 05h,0E3h, 28h,0E4h
		db	 25h, 23h, 08h, 23h, 25h,0FEh
		db	0F0h, 00h,0D2h, 06h,0E4h, 23h
		db	 21h, 25h, 01h, 03h,0E3h, 26h
		db	0E4h, 23h, 21h, 05h, 21h, 23h
		db	0FEh,0F0h, 00h,0E5h, 17h,0F0h
		db	 00h, 84h,0F5h, 60h,0F0h, 00h
		db	0D2h, 0Ah,0E4h, 23h, 25h, 0Ah
		db	0E3h, 2Ah,0E4h, 03h, 25h,0E3h
		db	 2Ah,0E4h, 2Ah, 23h, 25h, 0Ah
		db	0F6h,0A6h, 01h, 86h,0CEh,0D3h
		db	 00h, 0Ah, 00h, 25h, 05h, 25h
		db	 20h, 25h, 00h, 0Ah, 00h, 25h
		db	 05h, 25h, 20h, 25h, 00h, 0Ah
		db	 00h, 25h, 05h, 25h, 20h, 25h
		db	 00h, 0Ah, 00h, 25h, 05h, 25h
		db	 20h, 25h, 00h, 0Ah, 00h, 25h
		db	 05h, 25h, 20h, 25h, 10h,0C1h
		db	0FBh, 9Dh, 01h,0F0h, 00h,0E5h
		db	 17h,0E1h, 02h,0F0h, 00h, 70h
		db	 70h, 70h, 70h, 80h,0D5h, 00h
		db	 2Ah, 2Ah, 08h, 03h,0E3h,0F0h
		db	 01h, 0Ch,0E4h, 15h, 60h, 20h
		db	 3Ah, 3Ah, 28h, 23h,0E3h, 0Ch
		db	 0Ah,0E4h, 23h,0E3h, 5Ch, 70h
		db	0E4h, 20h, 3Ah, 3Ah, 28h, 23h
		db	0E3h, 0Ch,0E4h, 15h, 60h, 20h
		db	 3Ah, 3Ah, 28h, 23h,0E3h, 0Ch
		db	 0Ah,0E4h, 23h,0E3h, 4Ch,0F0h
		db	 02h, 00h, 18h, 1Ah, 2Ch,0E4h
		db	 23h, 25h,0E3h, 0Ah, 2Ch,0E4h
		db	 21h, 21h, 23h, 21h,0E3h
		db	 0Ch, 3Ah, 2Ch
loc_24:
		in	al,21h			; port 21h, 8259-1 int IMR
		and	sp,bx
		dec	dx
		pop	ax
		push	si
		sub	al,0E4h
		and	sp,[di]
		jcxz	$+0Ch			; Jump if cx=0
		sub	al,0E4h
		and	[bx+di],sp
		and	sp,[bx+di]
;*		jcxz	loc_26			;*Jump if cx=0
		db	0E3h, 0Ch		;  Fixup - byte match
		cmp	ah,ah
		db	 65h, 13h, 15h, 73h,0E7h,0F0h
		db	 03h, 03h,0E7h, 02h
loc_26:
		out	1,ax			; port 1, DMA-1 bas&cnt ch 0
		out	0E3h,ax			; port 0E3h ??I/O Non-standard
		or	al,0E7h
		or	sp,di
loc_27:
		or	ah,bh
;*		or	di,sp
		db	 09h,0E7h		;  Fixup - byte match
;*		or	bh,ah
		db	 08h,0E7h		;  Fixup - byte match
		pop	es
		out	6,ax			; port 6, DMA-1 bas&add ch 3
		out	5,ax			; port 5, DMA-1 bas&cnt ch 2
		out	4,ax			; port 4, DMA-1 bas&add ch 2
		out	3,ax			; port 3, DMA-1 bas&cnt ch 1
		out	2,ax			; port 2, DMA-1 bas&add ch 1
		out	1,ax			; port 1, DMA-1 bas&cnt ch 0
		out	0E3h,ax			; port 0E3h ??I/O Non-standard
		or	al,0E7h
		or	sp,di
		or	ah,bh
;*		or	di,sp
		db	 09h,0E7h		;  Fixup - byte match
;*		or	bh,ah
		db	 08h,0E7h		;  Fixup - byte match
		pop	es
		out	6,ax			; port 6, DMA-1 bas&add ch 3
		out	5,ax			; port 5, DMA-1 bas&cnt ch 2
		out	4,ax			; port 4, DMA-1 bas&add ch 2
		out	3,ax			; port 3, DMA-1 bas&cnt ch 1
		out	2,ax			; port 2, DMA-1 bas&add ch 1
		out	1,ax			; port 1, DMA-1 bas&cnt ch 0
		out	0E3h,ax			; port 0E3h ??I/O Non-standard
		or	al,0E7h
		or	sp,di
		or	ah,bh
;*		or	di,sp
		db	 09h,0E7h		;  Fixup - byte match
		or	[bx+si],dl
;*		and	bl,bh
		db	 20h,0FBh		;  Fixup - byte match
		db	0F3h, 01h,0F0h, 00h

locloop_28:
		in	ax,27h			; port 27h ??I/O Non-standard
		loopz	locloop_28		; Loop if zf=1, cx>0

                           lock	add	ax,[bx+si]
		sti				; Enable interrupts
		db	0F3h, 01h,0F0h, 00h,0E5h, 27h
		db	0E1h, 04h,0F0h, 03h, 00h,0FBh
		db	 29h, 00h,0F0h, 00h,0CDh, 00h
		db	0CFh, 02h,0D0h, 02h,0CEh, 09h
		db	0D1h, 0Ah,0C2h,0F5h, 1Ch,0F0h
		db	 00h, 11h, 01h, 01h, 01h, 19h
		db	 01h, 11h, 11h, 01h, 11h, 11h
		db	 01h, 19h, 01h, 11h, 01h,0F6h
		db	0CCh, 02h, 11h, 01h, 01h, 01h
		db	 19h, 01h, 11h, 11h, 01h, 11h
		db	 11h, 01h, 18h, 18h, 18h, 18h
		db	0F5h, 20h,0F0h, 00h, 11h, 01h
		db	 01h, 01h, 19h, 01h, 11h, 11h
		db	 01h, 11h, 11h, 01h, 19h, 01h
		db	 11h, 01h, 11h, 01h, 01h, 01h
		db	 19h, 01h, 11h, 11h, 01h, 11h
		db	 11h, 01h, 19h, 01h, 19h, 19h
		db	0F6h,0F3h, 02h,0F5h, 0Ch,0F0h
		db	 00h, 11h, 01h, 01h, 01h, 19h
		db	 01h, 11h, 11h, 01h, 11h, 11h
		db	 01h, 19h, 01h, 11h, 01h,0F6h
		db	 1Ah, 03h, 11h, 01h, 01h, 01h
		db	 19h, 01h, 11h, 11h, 01h, 11h
		db	 11h, 01h,0C8h, 08h,0CAh, 08h
		db	 18h, 18h,0C8h,0F8h,0CAh,0F8h
		db	 18h, 18h,0FBh,0BDh, 02h,0F0h
		db	 00h,0E0h, 91h,0F5h, 10h,0F0h
		db	 00h, 80h,0E5h, 17h,0D4h,0FCh
		db	0FDh, 03h, 00h, 81h,0D5h,0FCh
		db	 09h, 04h,0F6h, 50h, 03h, 82h
		db	0FCh,0DBh, 03h, 15h, 10h,0E3h
		db	0E3h, 2Ah, 2Ch,0E4h, 21h, 23h
		db	 21h,0E3h, 2Ch, 2Ah, 28h,0FCh
		db	0DBh, 03h, 35h, 83h,0E4h, 23h
		db	 25h, 26h, 28h, 2Ah, 2Ch,0E3h
		db	 82h, 21h, 23h, 05h, 06h, 08h
		db	 43h, 03h, 05h, 06h, 08h, 06h
		db	 45h, 13h, 03h, 05h, 06h, 51h
		db	 83h,0E4h, 2Ah, 25h, 28h, 23h
		db	 25h, 01h, 03h, 21h,0E3h, 0Ch
		db	 2Ah, 2Ch,0E4h, 21h, 23h,0E3h
		db	 82h, 05h, 06h, 08h, 43h, 03h
		db	 05h, 06h, 08h, 06h, 45h, 13h
		db	 6Ah, 28h, 2Ah, 78h, 80h,0E4h
		db	 28h, 2Ah, 25h,0F0h, 01h, 00h
		db	0E3h
		db	'8:0', 0Ah, ' 35@'
		db	0E4h, 38h, 3Ah, 35h, 10h,0E3h
		db	 20h, 38h, 3Ah, 30h, 0Ah, 50h
		db	0E3h, 38h, 3Ah,0E4h, 33h, 35h
		db	0FBh, 4Ah, 03h,0F0h, 01h,0E5h
		db	 17h,0D5h, 20h, 31h, 31h,0E3h
		db	 2Ch, 28h, 05h, 1Ah,0E5h, 27h
		db	 05h, 1Ah,0E5h, 37h, 05h, 1Ah
		db	 20h,0E5h, 17h,0D5h, 31h, 31h
		db	0E3h, 2Ch, 28h, 05h, 03h, 28h
		db	0FEh,0F0h, 01h, 38h, 3Ah, 30h
		db	0F0h, 02h, 4Ah, 10h, 13h, 15h
		db	0FEh,0F0h, 02h,0F0h, 03h
		db	':;J34C89H56U'
		db	0FEh,0F0h, 00h,0F5h, 10h,0F0h
		db	 00h, 84h,0E5h, 1Fh,0D2h, 0Ah
		db	0E4h, 23h, 25h, 85h,0E5h, 0Fh
		db	 0Ch, 84h,0E5h, 1Fh,0D2h, 2Ah
		db	0E4h, 03h, 25h,0E3h, 2Ah,0E4h
		db	 2Ah, 85h,0E5h, 0Fh, 0Ch, 84h
		db	0E5h, 1Fh,0D3h, 23h, 25h, 84h
		db	0E5h, 1Fh,0D2h, 0Ah,0E4h, 23h
		db	 25h, 85h,0E5h, 0Fh, 0Ch, 84h
		db	0E5h, 1Fh,0D2h, 2Ah,0E4h, 03h
		db	 25h,0E3h, 2Ah,0E4h, 2Ah, 23h
		db	 25h, 85h,0E5h, 0Fh, 0Ch,0F6h
		db	 1Eh, 04h,0F5h, 20h,0F0h, 00h
		db	 84h,0E5h, 1Fh,0D2h, 0Ah,0E4h
		db	 23h, 25h, 85h,0E5h, 0Fh, 0Ch
		db	 84h,0E5h, 1Fh,0D2h, 2Ah,0E4h
		db	 03h, 25h,0E3h, 2Ah,0E4h, 2Ah
		db	 85h,0E5h, 0Fh, 0Ch, 84h,0E5h
		db	 1Fh,0D3h, 23h, 25h, 84h,0E5h
		db	 1Fh,0D2h, 0Ah,0E4h, 23h, 25h
		db	 85h,0E5h, 0Fh, 0Ch, 84h,0E5h
		db	 1Fh,0D2h, 2Ah,0E4h, 03h, 25h
		db	0E3h, 2Ah,0E4h, 2Ah, 85h,0E5h
		db	 0Fh, 2Ch, 20h, 28h, 28h,0F6h
		db	 65h, 04h,0D5h, 00h, 86h,0E5h
		db	 17h
loc_29:
		or	al,byte ptr ds:[0FE5h][di]
		or	al,86h
		in	ax,17h			; port 17h ??I/O Non-standard
		and	ax,2505h
		and	[di],ah
		add	[bp+si],cl
		test	sp,bp
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		or	al,86h
		in	ax,17h			; port 17h ??I/O Non-standard
		and	ax,2505h
		and	[di],ah
		add	[bp+si],cl
		test	sp,bp
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		or	al,86h
		in	ax,17h			; port 17h ??I/O Non-standard
		and	ax,2505h
		and	[di],ah
		add	[bp+si],cl
		test	sp,bp
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		or	al,86h
		in	ax,17h			; port 17h ??I/O Non-standard
		and	ax,2505h
		and	[di],ah
		add	[bp+si],cl
		test	sp,bp
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		or	al,86h
		in	ax,17h			; port 17h ??I/O Non-standard
		and	ax,2505h
		and	[di],ah
		test	sp,bp
		das				; Decimal adjust
		sub	al,2Ch			; ','
		in	ax,0Fh			; port 0Fh, DMA-1 all mask bit
		sub	al,2Ch			; ','
		sti				; Enable interrupts
		sbb	al,[si]
;*                         lock	add	ch,ah
		db	0F0h, 00h,0E5h		;  Fixup - byte match
		pop	es
                           lock	add	bx,si
		cmc				; Complement carry
;*		and	al,dh
		db	 20h,0F0h		;  Fixup - byte match
		add	di,sp
		xchg	bp,ax
		add	ax,0AF6h
		add	ax,0CF5h
                           lock	add	di,sp
		xchg	bp,ax
		add	ax,7A87h
;*		mov	ah,ah
		db	 88h,0E4h		;  Fixup - byte match
                           lock	add	al,5
		add	cx,[bx+si]
		xchg	[bp+di],dx
		adc	ax,388h
		jcxz	loc_29			; Jump if cx=0
		sbb	ah,ah
		mov	[bx+di],al
;*		jcxz	loc_31			;*Jump if cx=0
		db	0E3h, 0Ch		;  Fixup - byte match
		or	cl,[bx+si]
		not	byte ptr [si]
		add	ax,95FCh
		add	ax,1A87h
;*		mov	ah,ah
		db	 88h,0E4h		;  Fixup - byte match
loc_31:
		add	ax,803h
		xchg	[bp+di],dx
		adc	ax,388h
;*		jcxz	loc_30			;*Jump if cx=0
		db	0E3h, 87h		;  Fixup - byte match
		sbb	ah,ah
		mov	[bx+di],al
		add	ax,[di]
		push	es
		cld				; Clear direction
		scasw				; Scan es:[di] for ax
		add	ax,8F5h
                           lock	add	al,0FCh
		iret				; Interrupt return
		db	 05h,0F6h, 51h, 05h,0FCh,0AFh
		db	 05h,0FCh,0CFh, 05h,0D1h, 87h
		db	 16h, 88h,0E4h, 03h, 01h, 05h
		db	 87h, 11h, 13h, 88h,0E3h, 06h
		db	0E4h, 03h, 01h, 03h, 05h, 06h
		db	 08h,0D2h,0F5h, 10h,0F0h, 04h
		db	 87h, 18h, 88h, 0Ah, 03h,0E3h
		db	 08h, 87h, 1Ah,0E4h, 88h, 03h
		db	 87h, 15h,0E3h, 1Ah,0E4h, 88h
		db	 08h, 0Ah, 03h, 05h,0F6h, 77h
		db	 05h,0FBh, 01h, 05h,0F0h, 04h
		db	0D1h, 87h, 1Ah, 88h,0E4h, 05h
		db	 03h, 08h, 87h, 13h, 15h, 88h
		db	 03h,0E3h, 87h, 1Ah,0E4h, 88h
		db	 01h, 03h, 87h,0E3h, 18h,0FEh
		db	0F0h, 04h,0F5h, 08h,0F0h, 04h
		db	0D1h, 87h, 18h, 88h,0E4h, 05h
		db	 03h, 08h, 87h, 13h, 15h, 88h
		db	0E3h, 08h,0E4h, 05h, 03h, 87h
		db	 18h, 88h, 03h, 05h,0F6h,0B3h
		db	 05h,0FEh,0F0h, 04h,0D1h, 87h
		db	 16h, 88h,0E4h, 03h, 01h, 05h
		db	 87h, 11h, 13h, 88h,0E3h, 06h
		db	0E4h, 03h, 01h, 87h, 15h, 88h
		db	 01h, 03h,0FEh, 0Ch, 18h, 06h
		db	 30h, 24h, 3Ch, 54h,0C0h, 12h
		db	 1Eh, 0Ch, 06h, 30h, 18h, 60h
		db	 48h, 24h, 06h, 0Ch, 18h, 3Ch
		db	 30h, 54h, 60h, 03h,0C0h, 60h
		db	 02h, 0Eh, 1Ah, 08h, 0Ch, 06h
		db	 0Ch, 20h, 10h, 10h, 07h, 07h
		db	 01h, 51h, 41h, 1Dh, 00h, 40h
		db	 81h,0F3h,0F5h, 0Eh, 00h, 00h
		db	 00h, 02h, 02h, 01h, 24h, 21h
		db	 9Ch, 00h,0F3h,0F3h, 38h, 88h
		db	 00h, 00h, 00h, 00h, 02h, 02h
		db	 01h,0E0h, 21h, 8Eh, 00h,0F4h
		db	0F5h, 32h, 36h, 08h, 0Eh, 08h
		db	 08h, 05h, 05h, 01h,0B4h,0A1h
		db	 61h, 00h, 47h,0F0h, 25h, 04h
		db	 04h, 00h, 00h, 00h, 02h, 02h
		db	 01h, 0Ah, 01h,0CFh, 00h,0F3h
		db	0F4h, 09h, 07h, 08h, 01h, 08h
		db	 08h, 07h, 07h, 01h, 12h, 01h
		db	 88h, 00h,0F6h,0F6h, 12h, 12h
		db	 08h, 00h, 00h, 00h, 02h, 02h
		db	 01h, 04h, 16h, 4Ch, 00h,0F7h
		db	0F3h, 56h, 06h, 0Eh, 10h, 17h
		db	 17h, 03h, 03h, 01h, 00h, 01h
		db	 03h, 06h, 07h, 5Fh, 24h, 1Fh
		db	 38h, 00h, 04h, 01h, 0Eh, 0Eh
		db	 03h, 03h, 81h, 00h, 01h, 1Bh
		db	 03h, 05h, 6Eh, 14h, 1Fh, 38h
		db	 00h, 03h, 0Eh, 15h, 15h, 05h
		db	 05h, 01h, 00h, 01h, 03h, 17h
		db	 09h, 5Fh, 11h, 0Fh, 38h, 00h
		db	 05h, 00h, 00h, 00h, 02h, 02h
		db	 81h, 00h, 01h, 17h, 03h, 05h
		db	 6Eh, 32h, 1Fh, 38h, 00h, 03h
		db	 01h, 33h, 33h, 02h, 02h, 01h
		db	 00h, 01h, 0Dh, 29h, 07h, 1Dh
		db	 81h, 0Fh, 38h, 00h, 04h, 01h
		db	0E5h, 47h, 06h, 02h, 01h, 00h
		db	 02h, 09h, 38h, 09h, 5Fh, 01h
		db	 2Fh, 87h, 00h, 04h, 00h, 33h
		db	 33h, 02h, 02h, 01h, 00h, 01h
		db	 19h, 29h, 07h, 1Dh, 81h, 0Fh
		db	 00h, 00h, 05h, 00h, 00h, 00h
		db	 02h, 02h, 81h, 01h, 02h,0D0h
		db	 01h, 07h, 99h, 01h,0FFh, 38h
		db	 00h, 05h, 00h, 00h, 00h, 02h
		db	 02h, 81h, 00h, 01h, 07h, 7Ch
		db	 07h, 99h, 01h, 0Dh, 38h, 00h
		db	 05h

_387UNKN	endp

seg_a		ends



		end	start
