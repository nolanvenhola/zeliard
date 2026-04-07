
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_391UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	1311h			;*
data_2e		equ	1414h			;*
data_3e		equ	0C182h			;*
data_4e		equ	0F001h			;*
data_5e		equ	0F506h			;*
data_6e		equ	0F5C2h			;*
data_21e	equ	18C1h			;*
data_22e	equ	1A1Ah			;*
data_23e	equ	0E510h			;*
data_24e	equ	0F001h			;*
data_25e	equ	0F503h			;*
data_26e	equ	0F606h			;*
data_27e	equ	0FC04h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_391UNKN	proc	far

start:
		db	 65h, 10h, 00h, 00h, 49h, 07h
		db	 18h, 09h,0D9h, 05h, 79h, 06h
		db	 01h, 1Fh, 00h, 02h,0E6h, 00h
		db	 03h, 0Eh, 02h, 04h, 68h, 03h
		db	 09h, 33h, 04h, 06h,0C5h, 05h
		db	 07h,0CAh, 05h, 08h,0CFh, 05h
		db	 09h,0D4h, 05h,0F0h, 00h,0E9h
		db	 00h,0E0h, 6Eh,0A0h,0E6h, 59h
		db	0E5h, 78h,0F0h, 00h,0E9h, 00h
		db	0F5h, 01h
data_7		dw	0F002h
		db	 00h,0E9h, 00h,0E2h, 40h, 00h
		db	 01h, 10h, 20h, 30h, 42h, 33h
		db	 54h, 64h,0E2h, 28h, 05h, 06h
		db	 07h, 08h, 09h, 0Ah, 3Bh, 7Ch
		db	 5Dh, 6Dh,0F6h, 01h, 31h, 00h
		db	0E2h, 40h,0F0h, 01h, 0Eh, 1Eh
		db	 2Fh,0E9h, 01h, 20h, 31h, 42h
		db	 52h, 23h, 14h
		db	'`aBb$'
		db	'#DT!u566'
		db	 07h, 17h, 25h, 20h, 31h, 42h
		db	 52h, 23h, 14h
		db	'`aBb$'
		db	'#DT!u56'
		db	0E2h, 19h, 28h, 29h, 2Ah, 2Bh
		db	0E2h
		db	 30h, 25h, 2Ch, 27h, 20h
loc_1:
		loop	$+3Ch			; Loop if cx > 0

		sub	ax,2221h
		and	al,0E2h
		inc	ax
                           lock	add	al,[di]
		add	ax,2515h
		sub	al,37h			; '7'
		inc	ax
		inc	cx
		xor	al,[bx+di+40h]
		push	bp
		db	'&IJN`@g', 27h, 'ENZ'
		db	7Fh
		db	'yzyz~z~u~u|'
		db	 05h, 05h, 15h, 25h, 2Ch, 37h
loc_2:
		inc	ax
		inc	cx
		xor	al,[bx+di+40h]
		push	bp
		db	'&IJN`@g', 27h, 'EN:'
		db	 0Eh, 0Bh, 09h,0E9h, 02h, 00h
		db	 01h,0F0h, 03h, 02h, 12h, 22h
		db	 33h, 34h, 35h, 36h, 37h,0FBh
		db	 2Ah, 00h,0FFh,0F0h, 03h,0E9h
		db	 02h,0E5h, 78h,0A0h,0E6h, 59h
		db	0F0h, 03h,0E9h, 02h,0F5h, 01h
		db	 02h,0F0h, 03h,0E9h, 02h,0E2h
		db	'@HIXhx:r'
		db	0F0h
data_8		db	4
		db	 0Bh, 1Bh, 1Bh, 2Bh,0F6h, 01h
		db	0F6h, 00h,0F5h, 01h, 02h,0F0h
		db	 04h,0E9h, 02h, 31h, 42h, 32h
		db	0E2h, 32h, 3Ch, 3Ch, 32h, 3Dh
		db	 32h,0E2h, 40h, 3Eh, 3Eh, 42h
		db	 32h, 52h,0E2h, 32h, 3Ah, 3Bh
		db	 3Fh,0E9h, 03h, 30h,0E2h
		db	'@1212b3tupvwx2'
		db	0E2h
		db	'-3tupvwx2'
		db	0E2h, 1Eh
		db	'3tupvwx2'
		db	0E2h, 0Fh
		db	'3tupvwx2'
		db	0E2h, 32h,0F0h, 05h, 09h, 19h
		db	 11h, 1Ah, 1Bh, 1Bh, 10h, 27h
		db	 12h, 1Ch, 1Ch, 1Dh, 1Ah, 1Ah
		db	 17h, 15h, 00h, 02h,0E2h, 40h
		db	 1Eh
		db	 3Fh, 33h, 34h, 35h, 30h
loc_3:
		aaa				; Ascii adjust
		adc	ah,dl
		sub	ax,3F1Eh
		xor	si,[si]
		xor	ax,3730h
		adc	ah,dl
		push	ds
		push	ds
		aas				; Ascii adjust
		xor	si,[si]
		xor	ax,3730h
		adc	ah,dl
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		push	ds
		aas				; Ascii adjust
		xor	si,[si]
		xor	ax,3730h
		adc	al,[bp+si+42h]
		loop	$+34h			; Loop if cx > 0

		sbb	ax,1B1Ah
;*		sbb	dl,ah
		db	 18h,0E2h		;  Fixup - byte match
		cmp	[bx+si],dl
		adc	ax,1E13h
		loop	$+42h			; Loop if cx > 0

		jmp	$+1007h
			                        ;* No entry point to code
		adc	[bp+si],dx
		adc	si,si
		add	[bx+si],dx
		add	[si+54h],dx
		db	64h
loc_5:
		and	al,25h			; '%'
;*		jbe	loc_7			;*Jump if below or =
		db	 76h, 07h		;  Fixup - byte match
		add	[bp+si+1],si
		pop	es
                           lock	push	es
		add	al,18h
		sub	[bp+si],bp
loc_8:
		sub	si,[bx]
		daa				; Decimal adjust
		db	'6F$'
		db	'+', 0Ah, '\YZYZ[Z[T[TUddtDE'
		db	0F0h, 07h, 06h, 17h, 11h, 02h
		db	 11h, 17h, 24h, 38h, 19h, 1Ah
		db	 1Bh, 47h, 17h, 46h, 56h, 14h
		db	 1Bh, 0Ah, 4Bh,0E2h, 37h, 6Bh
		db	 66h, 61h, 63h,0E2h, 28h, 13h
		db	0E2h, 1Eh, 13h,0E2h, 14h, 13h
		db	0E2h, 0Ch, 73h,0E2h, 40h, 79h
		db	 7Ah, 7Dh, 7Bh, 7Eh,0FBh,0EFh
		db	 00h,0FFh,0F0h, 07h,0E9h, 04h
		db	0E5h, 78h,0A0h,0E6h, 6Ah,0F0h
		db	 07h,0E9h, 04h,0F5h, 01h, 04h
		db	0F0h, 07h,0E9h, 04h,0E2h, 40h
		db	0F0h, 08h, 0Fh, 0Fh, 0Fh, 0Fh
		db	0E9h, 05h, 00h, 01h, 02h, 03h
		db	 14h, 05h, 02h, 06h, 27h, 08h
		db	 12h, 29h, 00h, 0Ah,0F6h, 01h
		db	 1Eh, 02h,0F5h, 01h, 02h,0F0h
		db	 08h,0E9h, 05h,0F5h, 02h, 02h
		db	0F0h, 08h,0E9h, 05h, 0Bh, 0Bh
		db	 1Ch, 09h, 0Bh, 02h, 09h, 1Ch
		db	 0Bh, 0Bh, 06h, 06h, 10h, 0Ch
		db	 06h, 09h, 0Ch, 10h, 06h, 06h
		db	0F6h, 02h, 48h, 02h, 0Dh, 0Dh
		db	 1Bh, 0Ch, 0Dh, 0Ch, 00h, 1Bh
		db	 0Dh, 0Dh, 06h, 06h, 10h, 0Ch
		db	 06h, 09h, 0Ch, 10h, 06h, 06h
		db	 0Bh, 0Bh, 1Ch, 09h, 0Bh, 02h
		db	 09h, 1Ch, 0Bh, 0Bh, 06h, 06h
		db	 10h
loc_10:
		or	al,6
		or	[si],cx
		adc	data_19,al
		or	ax,0C1Bh
		or	ax,0Ch
		sbb	ax,word ptr ds:[606h]
		push	es
		adc	[si],cl
		push	es
		or	[si],cx
		adc	ds:data_26e,al
		add	[bx+di+2],ax
		or	al,0Ch
		or	al,0Ch
		pop	es
		add	[si],cl
		or	al,16h
		or	al,0Ch
		add	al,[bp+si]
		add	al,[bp+si]
		pop	es
		or	[bp+si],ax
		add	dl,[bx+si]
		add	al,[bp+si]
		or	[bx+si],cl
		or	[bx+si],cl
		or	al,2
		or	[bx+si],cl
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		or	[bx+si],cl
		add	al,[bp+si]
		add	al,[bp+si]
		pop	es
		or	[bp+si],ax
		add	dl,[bx+si]
		add	al,[bp+si]
		or	cx,[bp+di]
		or	cx,[bp+di]
		add	al,[bx]
		add	cl,[bp+di]
		sbb	cx,[bp+di]
		or	ax,word ptr ds:[606h]
		push	es
;*		or	cx,bp
		db	 09h,0E9h		;  Fixup - byte match
		push	es
		add	[bx+di],al
		add	[bx+di],dx
		add	[bx+di],ax
		add	al,[bp+si]
		add	al,[bp+si]
		add	ax,[bx+si]
		add	al,[bp+si]
		adc	ax,[bp+si]
		add	al,[bp+si]
		add	al,[bp+si]
		add	al,[bp+si]
		add	al,[bp+si]
		add	al,[bp+si]
		add	dh,[si]
		xor	si,[di]
		db	 36h, 37h, 38h, 39h, 3Ah, 3Bh
		db	 4Ch, 03h, 03h, 03h, 03h, 0Bh
		db	 04h, 03h, 03h, 11h, 03h, 03h
		db	 08h, 08h, 08h, 08h, 0Bh, 06h
		db	 08h, 08h, 14h, 08h, 08h, 09h
		db	 09h, 09h, 09h, 03h
		db	8, 9, 9, 0Dh, 0Ch, 9, 9, 8, 8, 8, 8
		db	 0Bh, 06h, 08h, 08h, 14h, 08h
		db	 08h, 0Eh, 0Eh, 0Eh, 0Eh, 08h
		db	 0Bh, 08h, 0Eh, 1Eh, 0Eh, 0Eh
		db	 01h, 01h, 01h, 01h, 06h, 00h
		db	 01h, 01h, 11h, 01h, 01h, 02h
		db	 02h, 02h, 02h, 03h, 00h, 02h
		db	 02h, 13h, 02h, 02h, 00h, 00h
		db	 02h, 02h, 0Eh, 02h, 04h, 02h
		db	 0Fh,0E9h, 07h, 00h, 01h, 01h
		db	0FBh, 17h, 02h,0FFh,0F0h, 08h
		db	0E9h, 07h,0A0h,0E6h, 59h,0E5h
		db	 64h,0E1h, 14h, 40h, 42h,0F0h
		db	 08h,0E9h, 07h,0F5h, 01h, 02h
		db	0F0h, 08h,0E9h, 07h,0E2h, 40h
		db	 33h, 34h, 53h, 63h, 73h,0F0h
		db	 09h, 05h, 12h, 26h, 36h,0E2h
		db	'(GHIJKL]n/?'
		db	0F6h, 01h, 7Ch, 03h,0E2h, 40h
		db	0E9h, 08h, 70h,0F0h, 0Ah, 00h
		db	 11h, 12h, 23h, 34h, 44h, 15h
		db	 06h, 52h, 53h, 34h, 54h, 16h
		db	 15h, 36h, 46h, 13h, 61h, 21h
		db	 27h, 27h, 70h, 00h, 11h, 12h
		db	 23h, 34h, 44h, 15h, 06h, 52h
		db	 53h, 34h, 54h, 16h, 15h, 36h
		db	 46h, 13h, 61h, 21h, 27h,0E2h
		db	 19h, 18h, 19h, 1Ah, 1Bh,0E2h
		db	 30h, 11h, 1Ch, 10h, 12h,0E2h
		db	 3Ah, 1Dh, 13h, 14h, 16h,0E2h
		db	 40h,0F0h, 0Bh, 01h, 01h, 11h
		db	'!,0BC4CBQ', 27h, 'IJNbB` ANZ'
		db	7Fh
		db	'yzyz~z~q~q|'
		db	 01h, 01h, 11h
		db	'!,0BC4CBQ', 27h, 'IJNbB` AN:'
		db	 0Eh, 0Bh, 09h,0E9h, 09h, 00h
		db	 01h,0F0h, 0Ch, 02h, 12h, 22h
		db	 33h, 34h, 35h, 36h, 37h,0FBh
		db	 75h, 03h,0FFh,0F0h, 0Ch,0E9h
		db	 09h,0F0h, 0Ch,0E9h, 09h,0F5h
		db	 01h, 02h,0F0h, 0Ch,0E9h, 09h
		db	0E5h, 7Fh,0E7h, 0Ah,0E2h
		db	'jHIZKiHyyHyyIkIx'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HYKiHy|HyyIkIx'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HYKiHyyHyyIkIx'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HYKiHyyHy{{{{'
		db	0F6h, 01h, 3Eh, 04h,0F5h, 01h
		db	 02h,0F0h, 0Ch,0E9h, 09h,0E5h
		db	 7Fh,0E7h
		db	0Ah, 'HIZKiHyyHyyIkIx'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HYKiHyyHyyIkIx'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HYKiHy|HyyIkIx'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HYKiHyyHyk}}'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HIZKiHyyHyyIkIx'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HYKiHyyHyyIkIx'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HYKiHy|HyyIkIx'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HYKiHyyHyyIk{'
		db	0E5h, 7Fh,0E7h
		db	0Ah, 'HYKiHyy'
loc_12:
		dec	ax
		jns	$+6Dh			; Jump if not sign
		jnp	loc_20			; Jump if not parity
		dec	dx
		jge	loc_22			; Jump if > or =
		jge	loc_23			; Jump if > or =
;*		jle	loc_24			;*Jump if < or =
		db	 7Eh, 7Eh		;  Fixup - byte match
;*		jle	loc_25			;*Jump if < or =
		db	 7Eh, 7Eh		;  Fixup - byte match
;*		jg	loc_26			;*Jump if >
		db	 7Fh, 7Fh		;  Fixup - byte match
		jg	loc_27			; Jump if >
		test	byte ptr [bx+di],93h
		add	al,0F5h
		add	[bp+si],ax
                           lock	or	al,0E9h
		db	9, 'HIZKiHyyHyyKiHyHYKiHyyHyyKiHy'
		db	'HYKiHy|HyyI{{IxHYKiHyyHyyKiHyHYK'
		db	'iHyyHyyKiI{HYK'
		db	'iHy'
		db	'|Hy'
		db	'yKiHyHYKiHyyHyyKiI'
loc_20:
		jnp	loc_28			; Jump if not parity
		pop	cx
loc_21:
		dec	bx
		db	69h
loc_22:
		js	loc_29			; Jump if sign=1
loc_23:
		jnp	loc_30			; Jump if not parity
		jle	loc_31			; Jump if < or =
		jle	loc_21			; Jump if < or =
		add	[bp+si+5],cx
		sti				; Enable interrupts
loc_27:
		aaa				; Ascii adjust
		add	al,0FFh
                           lock	or	al,0E9h
;*		or	di,di			; Zero ?
		db	 09h,0FFh		;  Fixup - byte match
                           lock	or	al,0E9h
;*		or	di,di			; Zero ?
		db	 09h,0FFh		;  Fixup - byte match
                           lock	or	al,0E9h
;*		or	di,di			; Zero ?
		db	 09h,0FFh		;  Fixup - byte match
                           lock	or	al,0E9h
;*		or	di,di			; Zero ?
		db	 09h,0FFh		;  Fixup - byte match
		dec	dx
		dec	cx
		dec	sp
		or	byte ptr [di+4Eh],4Fh	; 'O'
		push	ax
		push	cx
		push	dx
		push	sp
		push	bp
		push	si
		push	di
		inc	cx
		db	 3Eh, 43h, 45h, 46h, 4Ah, 48h
		db	 3Eh, 80h
		db	'A59:;?D<787'
loc_28:
		cmp	byte ptr [bx+di],3Ah	; ':'
		cmp	di,[si]
		cmp	ax,4443h
		inc	bp
		inc	si
		dec	di
		dec	bp
		xor	ax,4A48h
		inc	bx
		or	byte ptr [di+4Ch],4Bh	; 'K'
		dec	cx
		dec	ax
		inc	di
		aas				; Ascii adjust
		inc	bp
		inc	si
		db	'>AONPQRTJKMO'
		db	80h
		db	'EFHCGI+-,2764)530'
loc_29:
		sub	ch,[bp+di]
loc_30:
		db	 2Eh, 27h, 3Ah, 80h, 26h
loc_31:
		sub	[bx],sp
		db	'.-/012345'
		db	 80h, 3Ah, 2Bh, 3Ch, 3Eh, 27h
		db	 80h
		db	'JILMNOPQRTUVWA>CEFJH'
		db	80h
		db	'59:;?D<787'
		db	80h
		db	'9:;<=$'
		db	'*"&.0-)'
		db	 01h, 01h, 01h, 02h, 03h, 04h
		db	 0Ch, 0Ch, 06h, 06h, 24h, 25h
		db	 48h, 48h, 12h, 12h, 0Ch, 0Dh
		db	 30h, 30h, 06h, 06h, 48h, 48h
		db	 30h, 31h, 12h, 12h, 0Ch, 0Ch
		db	 48h, 49h, 03h, 03h, 12h, 13h
		db	 18h, 18h
		db	'00', 0Ch, 0Ch, 'HH', 0Ch, 0Dh
		db	 06h, 06h, 09h,0FFh, 18h,0FFh
		db	 12h,0FFh, 06h, 06h, 01h, 01h
		db	 01h, 02h, 03h, 04h
		db	0Ch, 0Ch, '$'
		db	'%HIHH'
		db	 06h, 06h, 18h,0FFh, 0Ch,0FFh
		db	 30h,0FFh, 01h, 01h, 0Ch, 0Ch
		db	 06h, 06h, 18h, 18h, 01h, 01h
		db	 48h,0FFh, 03h, 03h, 12h, 13h
		db	 30h, 30h, 48h, 48h, 18h,0FFh
		db	 0Ch, 0Ch, 0Ch, 0Dh, 18h, 18h
		db	 06h, 06h, 03h, 03h, 12h, 13h
		db	 30h, 30h, 0Ch, 0Ch, 48h, 48h
		db	 18h,0FFh, 0Ch, 0Dh, 18h, 18h
		db	 03h, 03h, 06h, 06h
data_14		db	6			; Data table (indexed access)
		db	 05h, 0Ch, 0Bh, 12h, 11h, 01h
		db	 01h, 03h,0FFh, 01h, 02h, 03h
		db	 04h, 0Ch, 0Ch, 06h, 06h, 0Ch
		db	0FFh, 24h, 25h, 48h, 48h, 01h
		db	 01h, 0Ch, 0Ch, 12h, 12h, 0Ch
		db	 0Dh, 30h, 30h, 06h, 06h, 48h
		db	 48h, 30h, 31h, 12h, 12h, 0Ch
		db	 0Ch, 48h, 49h, 0Ch, 0Dh, 03h
		db	 03h, 12h, 13h, 18h, 18h
		db	'00', 0Ch, 0Ch, 'HH', 0Ch, 0Dh
		db	 06h, 06h, 09h,0FFh, 18h,0FFh
		db	 12h,0FFh, 06h, 06h, 00h, 01h
		db	 12h, 01h, 0Ch, 01h, 06h, 01h
		db	 04h, 23h, 00h,0C9h, 00h,0B8h
		db	 01h,0E9h, 02h, 91h, 03h, 89h
		db	 04h, 21h, 05h,0C7h, 05h,0B6h
		db	 06h, 93h, 04h,0B6h, 08h,0D4h
		db	 08h, 6Fh, 08h, 18h, 09h, 0Ch
		db	0B0h, 01h, 05h, 01h, 01h,0F0h
		db	 00h,0E0h, 91h, 80h,0F5h, 08h
		db	0F0h, 00h,0E5h, 17h,0D5h, 03h
		db	 02h, 13h, 25h, 30h, 46h,0E5h
		db	 1Fh, 07h, 08h, 09h, 0Ah, 0Bh
		db	0E4h, 01h, 32h, 53h, 44h,0F6h
		db	 2Ah, 00h,0F5h, 08h,0F0h, 00h
		db	0E5h, 0Fh,0D4h, 66h, 23h, 28h
		db	 7Ah,0F0h, 01h, 0Bh,0E4h, 13h
		db	 21h,0E3h, 38h, 3Ah, 4Bh,0E4h
		db	 11h, 13h, 01h,0E3h, 1Ah, 53h
		db	 60h,0F7h, 68h, 00h, 60h,0FBh
		db	 46h, 00h,0F0h, 01h,0E5h, 1Fh
		db	0E3h, 16h, 1Ah, 1Bh, 1Ch,0E5h
		db	 17h,0E4h, 13h, 14h, 16h, 18h
		db	0E5h, 0Fh, 19h, 1Ah, 1Bh,0E4h
		db	 11h,0F5h, 08h,0F0h, 01h,0D4h
		db	 73h, 73h,0F0h, 02h, 03h, 14h
		db	 26h, 38h, 3Ah, 2Bh, 3Ah, 38h
		db	 43h, 10h,0E3h, 3Ah, 3Bh,0E4h
		db	 31h, 18h, 56h, 33h, 31h,0F7h
		db	0B2h, 00h,0E3h, 4Bh, 68h, 6Ah
		db	 6Bh, 6Ah, 6Bh,0E4h, 61h,0E3h
		db	 6Bh,0E4h, 61h, 63h, 61h, 63h
		db	 64h,0FBh, 81h, 00h,0F0h, 02h
		db	0E3h, 2Bh,0E4h, 71h,0E3h, 7Ch
		db	 7Ah, 79h, 78h,0F0h, 03h, 00h
		db	 1Ah, 1Bh, 1Ch,0E4h, 11h, 12h
		db	0FBh, 23h, 00h,0F0h, 00h, 80h
		db	0E5h, 17h,0F5h, 08h,0F0h, 00h
		db	0D5h, 08h, 09h, 18h
data_15		db	2Ah
		db	 30h,0F0h, 03h, 2Bh,0F6h,0D0h
		db	 00h,0F5h, 08h,0F0h, 03h,0D3h
		db	 18h, 30h,0E4h,0E4h,0E5h, 1Fh
		db	 18h, 18h, 10h, 16h, 10h,0E5h
		db	 17h,0E3h,0E3h, 16h, 16h, 40h
		db	0E5h, 1Fh,0E4h, 1Ah, 1Bh,0E4h
		db	 11h, 13h,0E3h,0E5h, 17h, 18h
		db	 10h, 18h, 50h,0F5h, 11h,0F0h
		db	 03h,0CFh,0D5h, 16h, 65h, 64h
		db	 63h, 62h, 61h,0E3h, 6Ch, 10h
		db	0F6h, 06h, 41h,0E5h, 1Fh,0D4h
		db	 74h, 14h, 18h, 1Ah, 1Bh, 1Bh
		db	0E4h, 13h,0F0h, 04h, 01h, 10h
		db	0E3h, 13h, 13h, 16h, 1Ah, 1Ah
		db	0E4h, 11h, 14h, 23h, 20h,0E5h
		db	 17h,0F5h, 21h,0F0h, 04h,0CFh
		db	0D5h, 18h, 37h, 36h, 35h, 34h
		db	 33h, 31h, 10h,0F6h, 34h, 41h
		db	 40h,0D4h,0E5h, 27h, 16h, 1Ah
		db	 1Bh, 1Ch,0E5h, 1Fh,0E4h, 13h
		db	 14h, 16h, 18h,0E5h, 17h, 19h
		db	 1Ah, 1Bh,0E4h, 11h,0F6h,0E0h
		db	 00h,0F5h, 08h,0F0h, 04h,0D5h
		db	 53h, 53h, 63h, 04h, 76h, 28h
		db	 2Ah, 7Bh, 2Ah, 28h, 43h, 00h
		db	0E3h, 2Ah, 2Bh,0E4h, 21h, 08h
		db	0F0h, 05h, 06h, 13h, 11h,0F7h
		db	 8Fh, 01h,0E3h, 2Bh, 38h, 3Ah
		db	 3Bh, 3Ah, 3Bh,0E4h, 31h,0E3h
		db	 3Bh,0E4h, 31h, 33h, 31h, 33h
		db	 34h,0FBh, 5Eh, 01h,0F0h, 05h
		db	0E3h, 4Bh,0E4h, 11h,0E7h,0E5h
		db	 1Fh, 51h, 56h, 5Ah,0E4h, 51h
		db	0E5h, 27h,0DBh, 11h,0E5h, 2Fh
		db	 11h,0E5h, 37h, 11h,0E5h, 3Fh
		db	0DEh, 31h,0E5h, 17h,0E3h,0E3h
		db	 3Ah, 3Bh, 3Ch,0E4h, 31h, 32h
		db	0FBh,0C9h, 00h,0F0h, 00h, 81h
		db	0E5h, 0Fh,0F0h, 00h,0D2h,0F5h
loc_32:
;*		adc	al,dh
		db	 10h,0F0h		;  Fixup - byte match
		add	[bx+si],ch
		sub	[bx+si],ch
		sub	[bp+si],ch
;*		sub	sp,sp
		db	 29h,0E4h		;  Fixup - byte match
		and	bp,[bx+si]
		aaa				; Ascii adjust
		and	ax,0E323h
		db	 26h,0E4h, 56h, 24h, 33h, 51h
		db	0E3h, 2Ah, 27h,0F6h,0C2h, 01h
		db	0FCh, 2Bh, 02h,0FCh, 2Bh, 02h
		db	0FCh, 95h, 02h
		db	'$$$$'
		db	'+#$$'
		db	';'
		db	12 dup (24h)
		db	 0Ah, 0Bh, 0Ch,0E4h, 01h, 02h
		db	 03h, 04h, 05h, 06h, 07h,0F0h
loc_33:
		add	ax,0E378h
		cld				; Clear direction
		xchg	bp,ax
		add	dh,[si]
		xor	al,34h			; '4'
		xor	al,3Bh			; ';'
		xor	si,[si]
		xor	al,1Bh
		xor	al,34h			; '4'
		xor	si,[bp+di]
		xor	al,34h			; '4'
		cmp	[si],dh
		cmp	dh,[si]
		in	al,0E4h			; port 0E4h ??I/O Non-standard
		xor	[bp+di],si
;*		jcxz	loc_34			;*Jump if cx=0
		db	0E3h,0E3h		;  Fixup - byte match
		xor	al,34h			; '4'
		sti				; Enable interrupts
		mov	bp,data_24e
		add	ax,8F5h
                           lock	add	ax,3838h
		sbb	sp,sp
;*		xor	bx,sp
		db	 31h,0E3h		;  Fixup - byte match
;*		cmp	ah,ah
		db	 38h,0E4h		;  Fixup - byte match
		xor	si,[bx+di]
		jcxz	loc_35			; Jump if cx=0
		cmp	[bx+si],bh
		db	 36h, 36h, 1Ah, 3Bh, 36h,0E4h
		db	 31h,0E3h, 3Bh, 1Ah, 36h, 36h
		db	0F6h, 2Fh, 02h, 34h, 34h, 18h
		db	 3Bh, 34h, 3Bh, 3Ah, 18h
		db	 34h, 34h
loc_35:
		db	 36h, 36h, 1Ah, 3Bh, 36h,0E4h
		db	 31h,0E3h, 3Bh, 1Ah, 36h, 36h
		db	 38h, 38h, 1Bh,0E4h, 31h,0E3h
		db	 38h,0E4h, 33h, 31h,0E3h, 1Bh
		db	 38h, 38h, 36h, 36h, 1Ah, 3Bh
		db	 36h,0E4h, 31h,0E3h, 3Bh, 1Ah
		db	 36h, 36h, 34h, 34h, 18h, 3Bh
		db	 34h, 3Bh, 3Ah, 18h, 36h, 36h
		db	 36h, 36h, 1Ah, 3Bh, 36h,0E4h
		db	 31h,0E3h, 3Bh, 1Ah, 36h, 36h
		db	0FEh,0F0h, 05h, 3Bh, 3Bh, 3Bh
		db	 3Bh,0E4h, 36h,0E3h, 3Ah, 3Bh
		db	 3Bh, 16h, 3Bh, 3Bh,0E4h
		db	'33336133'
		db	0E3h, 1Ah,0E4h, 33h, 33h, 34h
		db	 34h, 34h, 34h,0E3h, 3Bh,0E4h
		db	'344;04433336133'
		db	0E3h, 1Ah,0E4h, 33h, 33h,0E3h
		db	 38h, 38h, 38h, 38h,0E4h, 33h
		db	 36h, 33h,0E3h, 38h, 18h, 38h
		db	 38h, 36h, 36h, 36h, 36h,0E4h
		db	 31h,0E3h, 33h, 36h, 36h, 16h
		db	 36h, 36h,0FEh,0F0h, 00h, 80h
		db	0E1h, 02h,0F0h, 00h,0F5h, 08h
		db	0F0h, 00h,0E5h, 1Fh,0D5h, 03h
		db	 02h, 13h, 25h, 30h, 46h,0E5h
		db	 27h, 07h, 08h, 09h, 0Ah, 0Bh
		db	0E4h, 01h, 32h, 53h, 44h,0F6h
		db	0F2h, 02h,0F5h, 08h,0F0h, 00h
		db	0E5h, 17h,0D4h, 66h, 23h, 28h
		db	 7Ah,0F0h, 01h, 0Bh,0E4h, 13h
		db	 21h,0E3h, 38h, 3Ah, 4Bh,0E4h
		db	 11h, 13h, 01h,0E3h, 1Ah, 53h
		db	 60h,0F7h, 30h, 03h, 60h,0FBh
		db	 0Eh, 03h,0F0h, 01h,0E5h, 27h
		db	0E3h, 16h, 1Ah, 1Bh, 1Ch,0E5h
		db	 1Fh,0E4h, 13h, 14h, 16h, 18h
		db	0E5h, 17h, 19h, 1Ah, 1Bh,0E4h
		db	 11h,0F5h, 08h,0F0h, 01h,0D4h
		db	 73h, 73h,0F0h, 02h, 03h, 14h
		db	 26h, 38h, 3Ah, 2Bh, 3Ah, 38h
		db	 43h, 10h,0E3h, 3Ah, 3Bh,0E4h
		db	 31h, 18h, 56h, 33h, 31h,0F7h
		db	 7Ah, 03h,0E3h, 4Bh, 68h, 6Ah
		db	 6Bh, 6Ah, 6Bh,0E4h, 61h,0E3h
		db	 6Bh,0E4h, 61h, 63h, 61h, 63h
		db	 64h,0FBh, 49h, 03h,0F0h, 02h
		db	0E3h, 2Bh,0E4h, 71h,0E3h, 7Ch
		db	 7Ah, 79h, 78h,0F0h, 03h, 00h
		db	 1Ah, 1Bh, 1Ch,0E4h, 11h, 12h
		db	0FBh,0EEh, 02h,0F0h, 00h, 80h
		db	0F0h, 01h, 70h,0E1h, 02h,0F0h
		db	 01h,0E5h, 1Fh,0F5h, 08h,0F0h
		db	 01h,0D5h,0F0h, 03h
		db	 68h, 69h
loc_36:
                           lock	push	es
		or	[bp+si],bl
		and	[bp+di],bh
		neg	byte ptr ds:data_25e[bx]
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		push	es
		rcr	word ptr [bx+si],cl	; Rotate thru carry
loc_37:
		inc	ax
		in	al,0E4h			; port 0E4h ??I/O Non-standard
		in	ax,27h			; port 27h ??I/O Non-standard
		sbb	[bx+si],bl
		adc	ds:data_23e,dl
		pop	ds
		jcxz	loc_36			; Jump if cx=0
		push	ss
		push	ss
loc_38:
		push	ax
		in	ax,27h			; port 27h ??I/O Non-standard
		in	al,1Ah			; port 1Ah ??I/O Non-standard
		sbb	sp,sp
		adc	[bp+di],dx
		jcxz	loc_37			; Jump if cx=0
		pop	ds
		sbb	[bx+si],dl
		sbb	[bx+si-0Bh],ah
;*		adc	ax,si
		db	 11h,0F0h		;  Fixup - byte match
		push	es
		iret				; Interrupt return
			                        ;* No entry point to code
;*		aad	16h			; undocumented inst
		db	0D5h, 16h		;  Fixup - byte match
		jnz	$+76h			; Jump if not zero
		jnc	$+74h			; Jump if carry=0
		jno	loc_38			; Jump if not overflw
		jl	loc_39			; Jump if <
		not	bh
		inc	bx
		in	ax,27h			; port 27h ??I/O Non-standard
;*		aam	24h			; '$' undocumented inst
		db	0D4h, 24h		;  Fixup - byte match
		adc	al,18h
		sbb	bl,[bp+di]
		sbb	sp,sp
		adc	si,ax
		pop	es
loc_39:
		add	[bx+si],dx
		jcxz	loc_40			; Jump if cx=0
		adc	dx,ds:data_22e
		in	al,11h			; port 11h ??I/O Non-standard
		adc	al,23h			; '#'
;*		and	ch,ah
		db	 20h,0E5h		;  Fixup - byte match
		pop	ds
		cmc				; Complement carry
;*		and	ax,si
		db	 21h,0F0h		;  Fixup - byte match
		pop	es
		iret				; Interrupt return
		db	0D5h, 18h, 37h
loc_40:
		db	 36h, 35h, 34h, 33h, 31h, 10h
		db	0F6h, 05h, 44h, 40h,0D4h,0E5h
		db	 2Fh, 16h, 1Ah, 1Bh, 1Ch,0E5h
		db	 27h,0E4h, 13h, 14h, 16h, 18h
		db	0E5h, 1Fh, 19h, 1Ah, 1Bh,0E4h
		db	 11h,0F6h,0B1h, 03h,0F5h, 08h
		db	0F0h, 07h,0D5h, 53h, 53h, 63h
		db	 04h, 76h, 28h, 2Ah, 7Bh, 2Ah
		db	 28h, 43h, 00h,0E3h, 2Ah, 2Bh
		db	0E4h, 21h, 08h,0F0h, 08h, 06h
		db	 13h, 11h,0F7h, 60h, 04h,0E3h
		db	 2Bh, 38h, 3Ah, 3Bh, 3Ah, 3Bh
		db	0E4h, 31h,0E3h, 3Bh,0E4h, 31h
		db	 33h, 31h, 33h, 34h,0FBh, 2Fh
		db	 04h,0F0h, 08h,0E3h, 4Bh,0E4h
		db	 11h,0E7h,0E5h, 1Fh, 51h, 56h
		db	 5Ah,0E4h, 51h,0E5h, 2Fh,0DBh
		db	 11h,0E5h, 37h, 11h,0E5h, 3Fh
		db	 11h,0E5h, 47h,0DEh, 31h,0E5h
		db	 1Fh,0E3h,0E3h, 3Ah, 3Bh, 3Ch
		db	0E4h, 31h, 32h,0FBh, 99h, 03h
		db	0F0h, 00h, 81h

locloop_41:
		in	ax,1Fh			; port 1Fh ??I/O Non-standard
		loopz	locloop_41		; Loop if zf=1, cx>0

		sti				; Enable interrupts
		mov	bp,data_4e
;*		add	ch,cl
		db	 00h,0CDh		;  Fixup - byte match
;*		add	bh,cl
		db	 00h,0CFh		;  Fixup - byte match
		add	dl,al
		add	cl,dh
		push	es
		rol	word ptr ds:[0F5C2h],1	; Rotate
;*		jo	loc_42			;*Jump if overflow=1
		db	 70h,0F0h		;  Fixup - byte match
		add	[bx+di],dh
		adc	bh,[bx+di]
		or	al,10h
		adc	[bx+si],dx
		adc	[bx+di],bh
		or	al,10h
		mul	byte ptr ss:data_27e[bp+si]	; ax = data * al
		rol	word ptr [si],1		; Rotate
		xor	[bp+si],dx
		cmp	[si],cx
		adc	[bx+di],cl
		sbb	[bx+si],bl
		cmp	cl,[si]
;*		adc	ah,bh
		db	 10h,0FCh		;  Fixup - byte match
		rol	word ptr [si],1		; Rotate
		xor	[bp+si],dx
		cmp	[si],cx
		adc	[bx+di],dl
		adc	[bx+si],bl
		sbb	bl,[bx+si]
;*		sbb	bl,bh
		db	 18h,0FBh		;  Fixup - byte match
		xchg	bx,ax
		add	al,0F0h
		add	[bx+di],dh
		adc	bh,[bx+di]
		or	al,10h
		adc	[bx+si],dx
		adc	[bx+di],bh
		or	al,10h
		xor	[bp+si],dx
		cmp	[si],cx
		adc	[bx+di],dl
		adc	[bx+si],dl
		cmp	[si],cx
		adc	[bx+di],dh
		adc	bh,[bx+di]
		or	al,10h
		adc	[bx+si],dx
		adc	[bx+di],bl
		sbb	[bx+si],dl
		xor	[bp+si],dx
		cmp	[si],cx
		adc	[bx+di],dl
		adc	[bx+si],dl
		cmp	[si],cx
		adc	[bx+di],dh
		adc	bh,[bx+di]
		or	al,10h
		adc	[bx+si],dx
		adc	[bx+di],bh
		or	al,10h
		xor	[bp+si],dx
		cmp	[si],cx
		adc	[bx+di],dl
		adc	[bx+si],dl
		cmp	[si],cx
		adc	[bx+di],dh
		adc	bh,[bx+di]
		or	al,10h
		adc	[bx+si],dx
		adc	[bx+di],bh
		or	al,10h
		db	0FEh,0F0h, 00h,0E0h, 91h, 80h
		db	0F5h, 08h,0F0h, 00h,0E5h, 17h
		db	0D4h, 03h, 02h, 13h, 25h, 30h
		db	 46h,0E5h, 27h, 07h, 08h, 09h
		db	 0Ah, 0Bh,0E4h, 01h, 32h, 53h
		db	 44h,0F6h, 28h, 05h,0F5h, 08h
		db	0F0h, 00h,0E5h, 17h,0D3h, 66h
		db	 23h, 28h, 7Ah,0F0h, 01h, 0Bh
		db	0E4h, 13h, 21h,0E3h, 38h, 3Ah
		db	 4Bh,0E4h, 11h, 13h, 01h,0E3h
		db	 1Ah, 53h, 60h,0F7h, 66h, 05h
		db	 60h,0FBh, 44h, 05h,0F0h, 01h
		db	0E5h, 27h,0E3h, 16h, 1Ah, 1Bh
		db	 1Ch,0E5h, 1Fh,0E4h, 13h, 14h
		db	 16h, 18h,0E5h, 17h, 19h, 1Ah
		db	 1Bh,0E4h, 11h,0F5h, 08h,0F0h
		db	 01h,0D3h, 73h, 73h,0F0h, 02h
		db	 03h, 14h, 26h, 38h, 3Ah, 2Bh
		db	 3Ah, 38h, 43h, 10h,0E3h, 3Ah
		db	 3Bh,0E4h, 31h, 18h, 56h, 33h
		db	 31h,0F7h,0B0h, 05h,0E3h, 4Bh
		db	 68h, 6Ah, 6Bh, 6Ah, 6Bh,0E4h
		db	 61h,0E3h, 6Bh,0E4h, 61h, 63h
		db	 61h, 63h, 64h,0FBh, 7Fh, 05h
		db	0F0h, 02h,0E3h, 2Bh,0E4h
data_19		db	71h
		db	0E3h, 7Ch, 7Ah, 79h, 78h,0F0h
		db	 03h, 00h, 1Ah, 1Bh, 1Ch,0E4h
		db	 11h, 12h,0FBh, 21h, 05h,0F0h
		db	 00h, 80h,0E5h, 17h,0F5h, 08h
		db	0F0h, 00h,0D4h, 08h, 09h, 18h
		db	 2Ah, 30h,0F0h, 03h, 2Bh,0F6h
		db	0CEh, 05h,0F5h, 08h,0F0h, 03h
		db	0D2h, 18h, 30h,0E4h,0E4h,0E5h
		db	 1Fh, 18h, 18h, 10h, 16h, 10h
		db	0E5h, 17h,0E3h,0E3h, 16h, 16h
		db	 40h,0E5h, 1Fh,0E4h, 1Ah, 1Bh
		db	0E4h, 11h, 13h,0E3h,0E5h, 17h
		db	 18h, 10h, 18h, 50h,0F5h, 11h
		db	0F0h, 03h,0CEh,0D4h, 16h, 65h
		db	 64h, 63h, 62h, 61h,0E3h, 6Ch
		db	 10h,0F6h, 04h, 46h,0E5h, 1Fh
		db	0D3h, 74h, 14h, 18h, 1Ah, 1Bh
		db	 1Bh,0E4h, 13h,0F0h, 04h, 01h
		db	 10h,0E3h, 13h, 13h, 16h, 1Ah
		db	 1Ah,0E4h, 11h, 14h, 23h, 20h
		db	0E5h, 17h,0F5h, 21h,0F0h
loc_43:
		add	al,0CEh
;*		aam	18h			; undocumented inst
		db	0D4h, 18h		;  Fixup - byte match
		aaa				; Ascii adjust
		db	 36h, 35h, 34h, 33h, 31h, 10h
		db	0F6h, 32h, 46h, 40h,0D3h,0E5h
		db	 27h, 16h, 1Ah, 1Bh, 1Ch,0E5h
		db	 1Fh,0E4h, 13h, 14h, 16h, 18h
		db	0E5h, 17h, 19h, 1Ah, 1Bh,0E4h
		db	 11h,0F6h,0DEh, 05h,0F5h, 08h
		db	0F0h, 04h,0D4h, 53h, 53h, 63h
		db	 04h, 76h, 28h, 2Ah, 7Bh, 2Ah
		db	 28h, 43h, 00h,0E3h, 2Ah, 2Bh
		db	0E4h, 21h, 08h,0F0h, 05h, 06h
		db	 13h, 11h,0F7h, 8Dh, 06h,0E3h
		db	 2Bh, 38h, 3Ah, 3Bh, 3Ah, 3Bh
		db	0E4h, 31h,0E3h, 3Bh,0E4h, 31h
		db	 33h, 31h, 33h, 34h,0FBh, 5Ch
		db	 06h,0F0h, 05h,0E3h, 4Bh,0E4h
		db	 11h,0E7h,0E5h, 1Fh, 51h, 56h
		db	 5Ah,0E4h, 51h,0E5h, 27h,0DBh
		db	 11h,0E5h, 2Fh, 11h,0E5h, 37h
		db	 11h,0E5h, 3Fh,0DEh, 31h,0E5h
		db	 17h,0E3h,0E3h, 3Ah, 3Bh, 3Ch
		db	0E4h, 31h, 32h,0FBh,0C7h, 05h
		db	0F0h, 00h,0E5h, 0Fh,0F0h, 01h
		db	0DFh,0F5h, 10h
loc_44:
;*                         lock	add	cx,dx
		db	0F0h, 01h,0D1h		;  Fixup - byte match
		sbb	word ptr [bx+si],1818h
;*		add	cl,18h
		db	 82h,0C1h, 18h		;  Fixup - byte match
		into				; Int 4 on overflow
		sbb	word ptr [bp+si],0E419h
		adc	bx,[bx+si]
		pop	ss
;*		add	cl,18h
		db	 82h,0C1h, 18h		;  Fixup - byte match
		into				; Int 4 on overflow
		adc	word ptr [di],0E313h
		push	ss
		in	al,36h			; port 36h ??I/O Non-standard
;*		add	cl,18h
		db	 82h,0C1h, 18h		;  Fixup - byte match
		into				; Int 4 on overflow
		adc	word ptr [si],3133h
;*		add	cl,18h
		db	 82h,0C1h, 18h		;  Fixup - byte match
		into				; Int 4 on overflow
		and	bx,171Ah
		idiv	byte ptr ds:[0F506h][bx]	; al,ah rem = ax/data
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
;*		add	sp,di
		db	 01h,0FCh		;  Fixup - byte match
		push	ds
;*		or	ah,bh
		db	 08h,0FCh		;  Fixup - byte match
		cmp	cx,[bx+si]
		cld				; Clear direction
		push	ds
;*		or	ah,bh
		db	 08h,0FCh		;  Fixup - byte match
		cmp	cx,[bx+si]
		cld				; Clear direction
		push	si
;*		or	ah,bh
		db	 08h,0FCh		;  Fixup - byte match
		cmp	cx,[bx+si]
		cld				; Clear direction
		push	ds
;*		or	ah,bh
		db	 08h,0FCh		;  Fixup - byte match
		cmp	cx,[bx+si]
		cld				; Clear direction
		push	si
;*		or	ah,bh
		db	 08h,0FCh		;  Fixup - byte match
		cmp	cx,[bx+si]
		div	cl			; al, ah rem = ax/reg
		push	es
		cmc				; Complement carry
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
;*		add	cx,dx
		db	 01h,0D1h		;  Fixup - byte match
		sbb	word ptr [bp+di],1B1Bh
;*		add	cl,18h
		db	 82h,0C1h, 18h		;  Fixup - byte match
		into				; Int 4 on overflow
		and	sp,0E316h
		sbb	bl,[bp+di]
		sbb	dl,byte ptr ds:[0C182h]
;*		sbb	dh,cl
		db	 18h,0CEh		;  Fixup - byte match
		sbb	word ptr [bp+di],0D21Bh
		adc	word ptr [bp+di],1313h
;*		add	cl,18h
		db	 82h,0C1h, 18h		;  Fixup - byte match
		into				; Int 4 on overflow
		adc	word ptr ds:[1311h],0E313h
		sbb	al,ss:data_21e[bp+si]
		into				; Int 4 on overflow
		in	al,81h			; port 81h, DMA page reg ch 2
		adc	dx,[bp+di]
		rol	byte ptr ds:[1414h][bx+di],cl	; Rotate
		adc	al,82h
		db	0C1h, 18h,0CEh, 81h,0E3h, 1Bh
		db	0E4h, 13h, 14h, 14h, 1Bh, 82h
		db	0C1h, 18h, 18h,0CEh, 81h, 14h
		db	0D2h, 81h, 13h, 13h, 13h, 82h
		db	0C1h, 18h,0CEh, 81h, 16h, 11h
		db	 13h, 13h,0E3h, 1Ah, 82h,0C1h
		db	 18h,0CEh,0E4h, 81h, 13h, 13h
		db	0D1h, 81h, 18h, 18h, 18h, 82h
		db	0C1h, 18h,0CEh, 81h,0E4h, 13h
		db	 16h, 13h,0E3h, 18h, 18h, 82h
		db	0C1h, 18h,0CEh, 81h, 18h, 18h
		db	0D1h, 81h, 16h, 16h, 16h, 82h
		db	0C1h, 18h,0CEh, 81h,0E4h, 11h
		db	0E3h, 13h, 16h, 16h, 16h, 82h
		db	0C1h, 18h,0CEh, 81h, 16h, 16h
		db	0F7h,0ECh, 07h,0D1h, 81h, 14h
		db	 14h, 14h, 82h,0C1h, 18h,0CEh
		db	 81h, 1Bh, 13h, 14h, 14h, 1Bh
		db	 82h,0C1h, 18h,0CEh, 81h, 13h
		db	 13h,0D1h, 81h, 14h, 14h, 14h
		db	 82h,0C1h, 18h,0CEh, 81h, 14h
		db	 14h, 82h,0C1h, 18h, 18h, 18h
		db	 18h,0CEh,0F0h, 03h,0DEh, 83h
		db	0E3h, 6Ah, 6Bh, 6Ch,0E4h
		db	'abcdefghi'
		db	0F0h, 04h,0DDh,0FBh, 16h, 07h
		db	0F0h, 04h,0D1h, 81h, 14h, 14h
		db	 14h, 82h,0C1h, 18h,0CEh, 81h
		db	 1Bh, 13h, 14h, 14h, 1Bh, 82h
		db	0C1h, 18h,0CEh, 81h, 13h, 13h
		db	0D1h, 81h, 13h, 13h, 14h, 82h
		db	0C1h, 18h,0CEh, 81h, 18h, 14h
		db	 1Ah, 14h,0E4h,0E4h, 11h, 13h
		db	 82h,0C1h, 18h, 18h,0CEh,0FBh
		db	0B6h, 06h,0F0h, 04h,0D1h, 81h
		db	 18h, 18h, 1Bh, 82h,0C1h, 18h
		db	0CEh, 81h,0E4h, 11h,0E3h, 18h
		db	0E4h, 13h, 11h,0E3h, 1Bh, 82h
		db	0C1h, 18h,0CEh, 81h, 18h, 18h
		db	0FEh,0F0h, 04h,0D1h, 81h, 16h
		db	 16h, 1Ah, 82h,0C1h, 18h,0CEh
		db	 81h, 1Bh, 16h,0E4h, 11h,0E3h
		db	 1Bh, 1Ah, 82h,0C1h, 18h,0CEh
		db	 81h, 16h, 16h,0FEh,0F0h, 04h
		db	0D1h, 81h, 14h, 14h, 18h, 82h
		db	0C1h, 18h,0CEh, 81h, 1Bh, 14h
		db	 1Bh, 1Ah, 18h, 82h,0C1h, 18h
		db	0CEh, 81h, 13h, 13h,0FEh, 01h
		db	 10h, 06h, 0Ch, 6Ch, 12h, 3Ch
		db	 48h, 42h, 06h, 30h, 0Ch, 3Ch
		db	 90h, 48h, 03h, 2Ah, 18h, 30h
		db	 0Ch, 48h, 24h, 06h, 03h, 33h
		db	 06h,0FCh, 1Eh, 2Ah, 36h, 01h
		db	 0Ch, 18h, 06h, 0Ch, 01h, 48h
		db	 03h, 2Ah, 30h, 24h, 0Ch, 48h
		db	 06h, 30h, 03h, 01h, 02h, 10h
		db	 06h, 0Ch,0FCh, 1Eh, 2Ah, 36h
		db	 01h, 18h, 06h, 0Ch, 01h, 48h
		db	 03h, 2Ah, 30h, 24h, 0Ch, 48h
		db	 06h, 30h, 03h
data_20		dw	2001h
		db	 10h, 10h, 07h, 07h, 01h, 51h
		db	 41h, 1Dh, 00h, 40h, 81h,0F3h
		db	0F5h, 0Eh, 00h, 00h, 00h, 02h
		db	 02h, 01h, 00h, 22h, 0Ah, 00h
		db	0F4h,0F5h, 44h, 47h, 06h, 0Eh
		db	 15h, 15h, 05h, 05h, 01h, 00h
		db	 01h, 03h, 17h, 09h, 5Fh, 11h
		db	 0Fh, 38h, 00h, 03h, 00h, 00h
		db	 00h, 02h, 02h, 81h, 01h, 02h
		db	0D0h, 01h, 07h, 99h, 01h,0FFh
		db	 38h, 00h, 05h, 00h,0FFh, 00h
		db	 71h, 70h, 01h, 01h, 02h,0B4h
		db	 01h, 07h, 5Fh, 01h,0FEh, 87h
		db	 00h, 04h, 00h, 00h, 00h, 02h
		db	 02h, 81h, 00h, 01h, 01h, 01h
		db	 07h, 99h, 01h, 1Eh, 38h, 00h
		db	 05h

_391UNKN	endp

seg_a		ends



		end	start
