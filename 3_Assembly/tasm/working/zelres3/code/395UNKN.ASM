
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_395UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_11e	equ	2505h			;*
data_12e	equ	8382h			;*
data_13e	equ	8F5h
data_14e	equ	242Ah
data_15e	equ	252Bh
data_16e	equ	2A2Ah
data_17e	equ	2B2Bh
data_18e	equ	3A89h
data_19e	equ	3B3Bh
data_20e	equ	3C3Ah
data_21e	equ	4830h
data_22e	equ	600Ch
data_23e	equ	60C0h
data_24e	equ	8202h
data_25e	equ	8833h
data_26e	equ	8838h
data_27e	equ	883Ah
data_28e	equ	892Ah
data_29e	equ	893Ah
data_30e	equ	0E322h
data_31e	equ	0E43Bh
data_32e	equ	0F633h
data_33e	equ	1FE5h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_395UNKN	proc	far

start:
		mov	cx,0Dh
		add	ds:data_11e[bx+si],dl
;*		or	dl,al
		db	 08h,0C2h		;  Fixup - byte match
		add	al,42h			; 'B'
		add	ax,1F01h
		add	[bp+si],al
		mov	bx,300h
		push	cx
		add	[si],ax
		loop	$+4			; Loop if cx > 0

;*		or	di,cx
		db	 09h,0CFh		;  Fixup - byte match
		add	ax,word ptr ds:[4AEh]
		pop	es
		mov	bl,4
		or	byte ptr ds:[904h][bx+si],bh
		mov	bp,0F004h
;*		add	cl,ch
		db	 00h,0E9h		;  Fixup - byte match
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
		js	$-5Eh			; Jump if sign=1
		in	ax,7Fh			; port 7Fh ??I/O Non-standard
		out	8,al			; port 8, DMA-1 command reg
		cmc				; Complement carry
		add	[bp+si],al
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
;*		add	dl,ah
		db	 00h,0E2h		;  Fixup - byte match
		push	ax
		add	[bx+di],al
		adc	dl,[bp+di]
		adc	[bx+di],dl
		add	al,[bp+di]
		adc	[bx+di],dl
		adc	dl,[bp+di]
		test	byte ptr [bx+si],2Dh	; '-'
;*		add	cl,dh
		db	 00h,0F1h		;  Fixup - byte match
;*		add	al,dh
		db	 00h,0F0h		;  Fixup - byte match
;*		add	cl,ch
		db	 00h,0E9h		;  Fixup - byte match
;*		add	ch,ah
		db	 00h,0E5h		;  Fixup - byte match
		js	$-18h			; Jump if sign=1
		pop	di
		loop	$+42h			; Loop if cx > 0

		and	al,35h			; '5'
		inc	bp
		inc	si
		inc	di
		dec	ax
		dec	cx
		pop	dx
		db	'j+,IDML~n'
		db	0E5h, 78h,0E6h, 58h,0E2h, 60h
		db	 2Fh,0E9h, 01h
		db	' ABCDec&', 27h, 'AHIGzj'
		db	0F5h, 01h, 03h,0F0h, 00h,0E9h
		db	 01h,0E5h, 7Fh,0E2h, 40h,0F0h
		db	 01h, 0Bh, 1Ch, 0Bh, 1Ch, 0Bh
		db	 0Bh, 0Ch, 0Bh, 2Ch, 0Dh, 0Eh
		db	 3Bh, 3Bh, 0Bh, 1Ch, 0Bh, 1Ch
		db	 0Fh, 4Bh, 0Bh, 0Fh, 5Bh, 0Fh
		db	 5Bh, 3Fh, 3Fh,0F6h, 01h, 7Bh
		db	 00h,0E2h, 60h, 59h,0E9h, 02h
		db	 00h, 51h, 02h, 53h, 04h, 55h
		db	 06h
		db	'778899::'
		db	0FBh, 45h, 00h,0FFh,0F0h, 01h
		db	0E9h, 02h,0A0h,0F5h, 00h, 04h
		db	0F0h, 01h,0E9h, 02h, 6Bh, 6Bh
		db	0F6h, 00h,0C3h, 00h,0F0h, 01h
		db	0E9h, 02h,0E5h, 6Eh,0E6h, 5Fh
		db	0E2h, 40h, 7Ch,0F0h, 02h, 0Dh
		db	 1Dh, 1Eh, 1Fh,0E9h, 03h, 10h
		db	 11h, 22h, 32h, 43h, 44h, 15h
		db	 16h, 17h, 14h, 58h, 38h,0E5h
data_1		db	64h			; Data table (indexed access)
		db	0E6h, 59h,0E2h, 60h, 49h, 4Ah
		db	 1Bh, 1Ch, 1Dh, 19h, 3Eh, 3Dh
		db	 4Fh, 4Ah, 1Bh,0E9h, 04h, 10h
		db	 11h, 12h, 53h, 33h,0F5h, 01h
		db	 03h,0F0h, 02h,0E9h, 04h,0E5h
		db	 7Fh,0E2h, 40h, 64h, 15h, 64h
		db	 15h, 64h, 64h, 65h, 64h, 75h
		db	 66h, 67h,0F0h, 03h, 04h, 04h
		db	 14h, 25h, 14h, 25h, 18h, 34h
		db	 34h, 38h, 44h, 18h, 44h, 08h
		db	 08h,0F6h, 01h, 07h, 01h, 19h
		db	 09h, 09h, 09h, 09h, 19h, 09h
		db	 09h, 09h, 09h, 19h, 09h, 09h
		db	 09h, 09h, 19h, 09h, 09h, 09h
		db	 09h, 09h, 0Ah, 0Bh, 0Ch, 0Dh
		db	 0Eh, 0Fh,0E9h, 05h, 00h,0FBh
		db	0CDh, 00h,0FFh,0F0h, 03h,0E9h
		db	 05h,0A0h,0F5h, 00h, 02h,0F0h
		db	 03h,0E9h, 05h,0E6h, 6Bh,0E5h
		db	 50h,0E2h, 78h, 51h, 52h, 53h
		db	 54h,0E2h, 64h, 51h, 52h, 53h
		db	 54h,0E2h, 50h, 51h, 52h, 53h
		db	 54h,0E2h, 41h, 51h, 52h, 53h
		db	 54h, 25h,0E6h, 67h,0E2h, 78h
		db	 52h, 52h,0E2h, 73h, 52h, 52h
		db	0E2h, 6Eh, 52h, 52h,0E2h, 69h
		db	 52h, 52h,0E2h, 64h, 52h, 52h
		db	0E2h, 5Ah, 52h, 52h,0E2h, 50h
		db	 52h, 52h,0E2h, 46h, 52h, 52h
		db	 65h,0E6h, 6Bh,0E2h, 78h, 51h
		db	 52h, 53h, 54h,0E2h, 64h, 51h
		db	 52h, 53h, 54h,0E2h, 50h, 51h
		db	 52h, 53h, 54h,0E2h, 41h, 51h
		db	 52h, 53h, 54h, 25h,0E6h, 67h
		db	0E2h, 78h, 52h, 52h,0E2h, 73h
		db	 52h, 52h,0E2h, 6Eh, 52h, 52h
		db	0E2h, 69h, 52h, 52h,0E2h, 64h
		db	 52h, 52h,0E2h, 5Ah, 52h, 52h
		db	0E2h, 50h, 52h, 52h,0E2h
		db	 46h, 52h, 52h, 65h

locloop_1:
		out	6Bh,al			; port 6Bh ??I/O Non-standard
		loop	locloop_14		; Loop if cx > 0

		push	cx
		push	dx
		push	bx
		push	sp
;*		loop	locloop_12		;*Loop if cx > 0

		db	0E2h, 64h		;  Fixup - byte match
		push	cx
		push	dx
		push	bx
		push	sp
		loop	locloop_11		; Loop if cx > 0

		push	cx
		push	dx
		push	bx
		push	sp
		loop	locloop_8		; Loop if cx > 0

		push	cx

locloop_2:
		push	dx

locloop_3:
		push	bx
		push	sp
		test	byte ptr [bx+si],59h	; 'Y'
;*		add	ax,si
		db	 01h,0F0h		;  Fixup - byte match
		add	bp,cx
		add	ax,1F5h
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	bp,cx
		add	ax,34E6h
		in	ax,6Eh			; port 6Eh ??I/O Non-standard
		loop	locloop_13		; Loop if cx > 0

		jbe	loc_16			; Jump if below or =
;*		js	loc_17			;*Jump if sign=1
		db	 78h, 79h		;  Fixup - byte match
		db	 7Ah, 7Bh, 76h, 77h, 78h
loc_5:
		jns	$+7Ch			; Jump if not sign
		jnp	$+58h			; Jump if not parity
		push	di
		pop	ax
		pop	cx
		pop	dx
		pop	bx
		push	si
		push	di
		pop	ax
		pop	cx
		pop	dx
		pop	bx
		pop	dx
		pop	bx
		pop	dx
		pop	bx
		test	byte ptr [bx+di],0
		add	ah,ch
		db	 6Eh,0F5h, 01h, 04h,0F0h

locloop_6:
		add	bp,cx

locloop_8:
		add	ax,0D0Ch
		or	[si],cl
		push	cs
		or	ax,0F08h

locloop_11:
		or	al,0Eh
		or	ax,0C08h
		push	cs
		or	ax,0F608h
		add	[bx],bp
		add	dh,ch
		add	[si],ax

locloop_13:
                           lock	add	bp,cx
		add	ax,706h
		jmpn	loc_15
		db	1, 2, 3, 0

locloop_14:
		add	al,[bx+di]
loc_15:
		add	al,[bp+di]
		add	[bx+di],al
		add	al,[bp+di]
;*		add	dh,dh
		db	 00h,0F6h		;  Fixup - byte match
		add	[bp+si+2],cx
		in	ax,78h			; port 78h ??I/O Non-standard
		cmc				; Complement carry
		add	word ptr ds:[3F0h],ax
		jmp	$+1409h
			                        ;* No entry point to code
;*		jno	loc_21			;*Jump if not overflw
		db	 71h, 75h		;  Fixup - byte match
;*		jbe	loc_21			;*Jump if below or =
		db	 76h, 73h		;  Fixup - byte match
		ja	loc_20			; Jump if above
		pop	ax
		push	ax
		pop	ax
		push	ax
		pop	ax
		push	ax
		pop	ax
		push	ax
		adc	al,51h			; 'Q'
		push	bp
		push	si
		push	bx
		push	di
		push	ax
loc_16:
		pop	ax
		push	ax
		adc	[di+76h],si
		jnc	loc_23			; Jump if carry=0
;*		jo	loc_24			;*Jump if overflow=1
		db	 70h, 78h		;  Fixup - byte match
		push	dx
		pop	ax
		push	dx
		pop	ax
		push	dx
		pop	ax
		push	dx
		pop	ax
		adc	[di+56h],dx
		push	bx
		push	di
		push	ax
		pop	ax
		push	dx
		pop	ax
		test	byte ptr [bx+di],69h	; 'i'
		add	ah,ch
		jg	loc_19			; Jump if >
;*		jnz	loc_25			;*Jump if not zero
		db	 75h, 76h		;  Fixup - byte match
		db	'swpxRXRXRXRXRXR'
loc_19:
		db	'XRXRXRXRXRXRXRXRXRXRXRXRXRXRXRXR'
		db	'XRXRXRXRX'
		db	0FBh,0F9h, 01h,0FFh,0F0h, 03h
loc_20:
		jmp	$-5FF7h
			                        ;* No entry point to code
		in	ax,6Eh			; port 6Eh ??I/O Non-standard
		out	70h,al			; port 70h, CMOS addr,bit7=NMI
						;  al = 0, seconds register
		cmc				; Complement carry
		add	[si],al
                           lock	add	bp,cx
		push	es
		loop	locloop_29		; Loop if cx > 0

		sbb	[bp+si],bx
		sbb	[bp+si],bx
		or	[bx+di],cx
		dec	dx
		sbb	bl,[bx+di]
		sbb	cl,[bx+di-1Eh]
		dec	bx
loc_23:
;*		jnp	loc_31			;*Jump if not parity
		db	 7Bh, 7Bh		;  Fixup - byte match
;*		loop	locloop_28		;*Loop if cx > 0

		db	0E2h, 5Ah		;  Fixup - byte match
		jnp	loc_32			; Jump if not parity
;*		loop	locloop_30		;*Loop if cx > 0

		db	0E2h, 6Eh		;  Fixup - byte match
;*		jnp	loc_33			;*Jump if not parity
		db	 7Bh, 7Bh		;  Fixup - byte match
;*		jnp	loc_22			;*Jump if not parity
		db	 7Bh,0E2h		;  Fixup - byte match
;*		jg	loc_35			;*Jump if >
		db	 7Fh, 7Bh		;  Fixup - byte match
;*		jnp	loc_36			;*Jump if not parity
		db	 7Bh, 7Bh		;  Fixup - byte match
;*		jnp	loc_37			;*Jump if not parity
		db	 7Bh, 7Bh		;  Fixup - byte match
		test	byte ptr [bx+si],0EEh
		add	dh,al
		add	bp,cx
		push	es
		in	ax,78h			; port 78h ??I/O Non-standard
		out	6Ah,al			; port 6Ah ??I/O Non-standard
loc_26:
		cmc				; Complement carry
		add	[si],ax
loc_27:
                           lock	add	bp,cx
		push	es
		loop	locloop_34		; Loop if cx > 0

                           lock	add	al,9
		or	[bx+di],bx
		sbb	[bx+di],cx
		or	cl,[bx+di]
		sbb	[si],bx
		or	ax,0A09h
		sbb	[bx+di],bx
		or	[bp+si],cx
		or	[bx+di],bx
		sbb	al,0Dh
		test	byte ptr [bx+di],22h	; '"'
		add	si,bp
		add	[bp+si],ax
                           lock	add	al,0E9h
		push	es
		push	cs
		push	cs
		push	ds
		push	ds
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		push	cs
		push	ds
		sbb	ax,7E9h
		add	[bx+di],al
		add	dl,[bx+di]
		adc	[bx+di],ax
		add	al,[bx+di]
		adc	[bp+di],dx
;*		add	dh,dh
		db	 00h,0F6h		;  Fixup - byte match
		add	[di+3],ax
		cmc				; Complement carry
		add	[bp+si],ax
                           lock	add	al,0E9h
		pop	es
		add	al,4
		adc	al,14h
		add	al,5
		add	al,14h
		push	ss

locloop_29:
		add	ax,[si]
		add	ax,1414h
		add	al,7
		add	al,14h
		push	ss
		add	si,si
		add	[bp+3],sp
loc_32:
		cmc				; Complement carry
		add	[bp+di],ax
                           lock	add	al,0E9h

locloop_34:
		pop	es
		or	[bx+si],cl
		sbb	[bp+si],bx
		or	[bx+si],cl
		or	[bx+si],cl
		sbb	[bp+si],bx
		sbb	[bx+si],bl
		or	[bx],al
		or	[bx],al
		sbb	[bx+si],bl
		pop	es
		sbb	[bp+si],bx
		or	[bx],al
		or	[bx+si],cl
		pop	es
		or	[bx+si],cl
		pop	es
		or	[bx+si],cl
		or	[bx],dl
		or	[bx],dl
		or	[bx],dl
		or	[bx],dl
		test	byte ptr [bx+di],85h
		add	dx,[si]
		adc	al,4
		add	al,14h
		adc	al,4
		add	al,14h
		adc	al,4
		add	al,14h
		adc	al,4
		add	al,14h
		adc	al,4
		adc	al,14h
		adc	al,14h
		sti				; Enable interrupts
		pop	ss
		add	di,di
                           lock	add	al,0E9h
		pop	es
		cmc				; Complement carry
		add	[bp+si],al
                           lock	add	al,0E9h
		pop	es
		in	ax,7Fh			; port 7Fh ??I/O Non-standard
		out	0Ah,ax			; port 0Ah, DMA-1 mask reg bit
		sub	bp,[bp+di]
		sub	bp,[bp+di]
		test	byte ptr [bx+si],0D6h
		add	si,ax
		add	al,0E9h
		pop	es
		cmc				; Complement carry
		add	[bp+si],ax
                           lock	add	al,0E9h
		pop	es
;*		loop	locloop_38		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		cmp	al,4Dh			; 'M'
		dec	si
		aaa				; Ascii adjust
		dec	si
		cmp	al,4Eh			; 'N'
		dec	si
		cmp	al,4Eh			; 'N'
		aaa				; Ascii adjust
		dec	si
		cmp	al,4Eh			; 'N'
		cmc				; Complement carry
		add	al,[bp+si]
                           lock	add	al,0E9h
		pop	es
		cmp	al,4Eh			; 'N'
		dec	si
		aaa				; Ascii adjust
		dec	si
		cmp	al,4Eh			; 'N'
		dec	si
		cmp	al,4Eh			; 'N'
		aaa				; Ascii adjust
		dec	si
		cmp	al,4Eh			; 'N'
		test	byte ptr [bp+si],4
		add	al,3Ch			; '<'
		dec	si
		dec	si
		aaa				; Ascii adjust
		dec	si
		cmp	al,41h			; 'A'
		dec	si
		cmp	al,4Eh			; 'N'
		inc	di
		push	di
		push	di
		cmp	al,4Dh			; 'M'
		dec	si
		aaa				; Ascii adjust
		dec	si
		cmp	al,4Eh			; 'N'
		dec	si
		cmp	al,4Eh			; 'N'
		aaa				; Ascii adjust
		dec	si
		cmp	al,4Eh			; 'N'
		cmc				; Complement carry
		add	al,[bp+si]
                           lock	add	al,0E9h
		pop	es
		cmp	al,4Eh			; 'N'
		dec	si
		aaa				; Ascii adjust
		dec	si
		cmp	al,4Eh			; 'N'
		dec	si
		cmp	al,4Eh			; 'N'
		aaa				; Ascii adjust
		dec	si
		cmp	al,4Eh			; 'N'
		test	byte ptr [bp+si],38h	; '8'
		add	al,3Ch			; '<'
		dec	si
		dec	si
		aaa				; Ascii adjust
		dec	si
		cmp	al,41h			; 'A'
		dec	si
		cmp	al,4Eh			; 'N'
		push	di
		push	di
		push	di
		push	di
		test	byte ptr [bx+di],0EDh
		add	si,bp
		add	[bp+di],ax
                           lock	add	al,0E9h
		pop	es
		db	'<oG<`G<OLMlWWGm\\<`G<oG<MLOL7`L7'
		db	'm\\'
		db	0F6h, 01h, 63h, 04h
		db	'<NN7N<AN<N7N<N<NN7NL'
		db	8 dup (57h)
		db	0FBh,0E6h, 03h,0FFh,0F0h, 04h
		db	0E9h, 07h,0FFh,0F0h, 04h,0E9h
		db	 07h,0FFh,0F0h, 04h,0E9h, 07h
		db	0FFh,0F0h, 04h,0E9h, 07h,0FFh
		db	'-,', 27h, '(>=89@?:BEFK31./53842'
		db	'+-7P'
		db	80h
		db	'WVK,+*)(', 27h, '&%$'
		db	'#"'
		db	80h
		db	'9834;:4<?98@E.+()/3-$'
		db	'&+1J'
		db	80h
		db	'QPE@?>=<;:9DEKJ'
		db	 80h, 51h, 54h, 57h
		db	'Z]\RUYXVQXTPRSUW-', 27h, '3/0.(1'
		db	'.(0-', 27h, '/&,)+'
		db	 80h, 24h, 22h, 2Ah, 21h, 30h
		db	 2Eh, 18h, 17h, 30h, 30h, 30h
		db	 31h, 18h, 18h
		db	'HI```a', 0Ch, 0Ch
		db	 18h,0FFh, 24h,0FFh, 06h, 06h
		db	 0Ch, 0Dh, 18h, 18h, 60h,0FFh
		db	 30h, 30h, 30h, 31h, 18h, 18h
		db	'HI``00`a', 0Ch, 0Ch, '$'
		db	0FFh, 06h, 06h, 0Ch, 0Ch, 18h
		db	0FFh, 0Ch, 0Dh, 18h, 18h, 03h
		db	 03h, 30h,0FFh, 04h, 04h, 0Ch
		db	 0Bh, 06h, 05h, 60h,0FFh, 00h
		db	 01h, 0Ch, 01h, 06h, 01h, 18h
		db	 01h, 04h, 23h, 00h, 98h, 00h
		db	 1Fh, 01h,0AFh, 01h, 89h, 02h
		db	 9Bh, 02h,0BCh, 03h, 6Bh, 04h
		db	0C8h, 05h,0F3h, 02h, 03h, 07h
		db	 7Bh, 07h,0E7h, 06h, 25h, 08h
		db	 0Ch,0B0h, 01h, 05h, 01h, 01h
		db	0F0h, 00h,0E0h, 87h, 81h,0E5h
		db	 17h,0D2h,0FCh, 55h, 04h,0F1h
		db	 00h,0E5h, 0Fh,0F0h, 00h, 87h
		db	0D4h, 03h, 12h,0E3h, 29h, 2Ah
		db	0E4h, 25h, 24h,0E3h, 3Bh,0E4h
		db	 07h, 0Ah, 24h, 23h, 2Bh, 2Ah
		db	0E4h, 44h, 80h,0D3h, 04h, 02h
		db	0E3h, 2Bh, 2Ch,0E4h, 26h, 24h
		db	 59h, 56h, 05h, 03h,0E3h, 2Bh
		db	 28h, 2Ah,0E4h, 23h, 48h,0F5h
		db	 0Ch,0F0h, 00h,0D5h
		db	'i i ii`ip'
		db	0E4h, 64h, 63h,0E3h,0F0h, 01h
		db	 09h, 09h, 19h, 20h, 19h, 20h
		db	 14h, 29h, 14h, 29h, 14h, 29h
		db	 04h, 04h,0F6h, 60h, 00h,0D3h
		db	 2Ah, 19h, 28h, 17h, 26h, 15h
		db	 24h, 13h, 02h, 02h, 01h, 01h
		db	0E3h, 0Ch, 0Ch, 0Bh, 0Bh,0FBh
		db	 32h, 00h,0F0h, 00h, 81h,0E5h
		db	 17h,0E1h, 04h,0D2h,0FCh, 55h
		db	 04h,0F0h, 00h, 87h,0E5h, 17h
		db	0D3h, 0Ah, 19h, 24h, 25h, 2Ch
		db	 2Ah, 35h,0E4h, 01h, 04h,0E3h
		db	 2Ah, 29h,0E4h, 25h, 24h, 4Ah
		db	 80h,0E5h, 2Fh,0D2h, 0Bh, 08h
		db	 25h, 26h, 2Ch, 2Bh,0E4h, 54h
		db	 51h,0E3h, 0Ch, 0Ah, 26h, 23h
		db	 25h, 2Ah,0E4h, 43h,0E5h, 17h
		db	0F5h, 0Ch,0F0h, 00h,0D5h
		db	'c c cc`cpji'
		db	0F0h, 01h, 03h, 03h, 13h, 20h
		db	 13h, 20h,0E3h, 1Ah,0E4h, 23h
		db	0E3h, 1Ah,0E4h, 23h,0E3h, 1Ah
		db	0E4h, 23h,0E3h, 0Ah, 0Ah,0F6h
		db	0D4h, 00h,0D4h,0E5h, 1Fh, 15h
		db	 05h, 05h, 05h, 05h, 15h, 05h
		db	 05h, 05h, 05h, 15h, 05h, 05h
		db	 05h, 05h, 15h, 05h, 05h, 05h
		db	 05h, 05h, 04h, 03h, 02h, 01h
		db	0E3h, 0Ch, 0Bh, 0Ah,0FBh,0A3h
		db	 00h,0F0h, 00h,0F5h, 09h,0F0h
		db	 00h,0F5h, 08h,0F0h, 00h, 82h
		db	0E5h, 0Fh,0F5h, 1Ah,0F0h, 00h
		db	0D3h,0F0h, 01h, 39h, 3Ah,0E4h
		db	 34h, 33h,0CEh,0F6h, 2Eh, 81h
		db	 83h,0D3h,0E5h, 0Fh, 3Ah, 3Ah
		db	0CCh, 3Ah, 3Ah,0CCh, 3Ah, 3Ah
		db	0CCh, 3Ah, 3Ah,0CCh, 3Ah, 3Ah
		db	0CCh, 3Ah, 3Ah,0CCh, 3Ah, 3Ah
		db	0CCh, 3Ah, 3Ah, 40h,0F6h, 27h
		db	 01h, 82h,0E5h, 0Fh,0F5h, 12h
		db	0F0h, 01h,0D3h, 39h, 3Ah,0E4h
		db	 34h, 33h,0CEh,0F6h, 60h, 81h
		db	0F6h, 23h, 41h, 84h,0E5h, 1Fh
		db	0F0h, 01h,0F5h, 20h,0F0h, 01h
		db	0D4h,0FCh,0FDh, 04h,0F6h, 76h
		db	 01h,0F5h, 10h,0F0h, 01h,0D4h
		db	0FCh,0AEh, 05h,0F6h, 81h, 01h
		db	0F5h, 10h,0F0h, 01h,0D4h,0FCh
		db	 23h, 05h,0F6h, 8Ch, 01h,0F5h
		db	 18h,0F0h, 01h,0D4h,0FCh, 3Dh
		db	 05h,0F6h, 97h, 01h,0D4h,0FCh
		db	 77h, 05h
		db	'54545454'
		db	0FBh, 72h, 01h,0F0h, 00h, 86h
		db	0F5h, 10h,0F0h, 00h,0D2h,0E5h
		db	 07h, 6Ah, 64h, 6Ah, 64h,0F0h
		db	 01h, 0Ah, 0Ah, 24h, 14h, 1Ah
		db	 14h, 2Ah,0E4h,0E5h, 2Fh, 53h
		db	 53h,0E5h, 1Fh, 53h, 53h,0E5h
		db	 17h, 53h, 53h, 53h,0E5h, 07h
		db	 53h, 53h, 53h, 53h, 53h,0F6h
		db	0B4h, 01h,0F0h, 01h, 85h,0E5h
		db	 07h,0D2h,0F5h, 10h,0F0h, 01h
		db	 1Ah, 1Ah, 0Ah, 0Ah, 1Ah, 14h
		db	 1Ah, 0Ah, 0Ch,0E4h, 11h,0E3h
		db	 1Ah, 14h
		db	0Ah
loc_39:
		or	bl,[bp+si]
		adc	al,1Ah
		or	cl,[si]
		in	al,11h			; port 11h ??I/O Non-standard
		jcxz	loc_39			; Jump if cx=0
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		cmc				; Complement carry
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	[bp+di],bx
		sbb	cx,[bp+di]
		or	bx,[bp+di]
		adc	ax,0B1Bh
		in	al,1			; port 1, DMA-1 bas&cnt ch 0
		adc	ah,bl
		sbb	dx,[di]
		or	cx,[bp+di]
		sbb	dx,[di]
		sbb	cx,[bp+di]
		in	al,1			; port 1, DMA-1 bas&cnt ch 0
		adc	ah,bl
		test	byte ptr [di],2
		cmc				; Complement carry
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	[bp+si],bx
		sbb	cl,[bp+si]
		or	bl,[bp+si]
		adc	al,1Ah
		or	cl,[si]
		in	al,11h			; port 11h ??I/O Non-standard
;*		jcxz	loc_40			;*Jump if cx=0
		db	0E3h, 1Ah		;  Fixup - byte match
		adc	al,0Ah
		or	bl,[bp+si]
		adc	al,1Ah
		or	cl,[si]
		in	al,11h			; port 11h ??I/O Non-standard
		jcxz	$-8			; Jump if cx=0
		and	al,2
		cmc				; Complement carry
		or	al,0F0h
		add	[bx+di],bx
		sbb	word ptr ds:[1908h],ax
		sbb	[bx+di],bx
		sbb	word ptr ds:[908h],ax
		or	[bx+di],bx
		adc	bx,[bx+di]
		adc	cx,[bx+di]
		or	[bp+di],dx
		push	es
		or	[bx+di],bl
		adc	bx,[bx+di]
		sbb	[bp+di],dx
		sbb	[bx+di],bx
		adc	bx,[bx+di]
		sbb	[bx+di],bx
		add	bx,[bx+di]
		add	bx,[bx+di]
		add	bx,[bx+di]
		add	si,si
		inc	bx
		add	cl,[bp+si]
		or	bl,[bp+si]
		sbb	cl,[bp+si]
		or	bl,[bp+si]
		sbb	cl,[bp+si]
		or	bl,[bp+si]
		sbb	cl,[bp+si]
		or	bl,[bp+si]
		sbb	cl,[bp+si]
		or	bl,[bp+si]
		or	cl,[bp+si]
		or	cl,[bp+si]
		sti				; Enable interrupts
		db	0DEh, 01h,0F0h, 00h, 81h

locloop_41:
		in	ax,1Fh			; port 1Fh ??I/O Non-standard
		loopz	locloop_41		; Loop if zf=1, cx>0

		sar	ah,cl			; Shift w/sign fill
		push	bp
		add	al,0E5h
		pop	ss
;*		loopz	locloop_42		;*Loop if zf=1, cx>0

		db	0E1h, 04h		;  Fixup - byte match
		sti				; Enable interrupts
		xor	al,[bx+si]
;*                         lock	add	cl,ah
		db	0F0h, 00h,0E1h		;  Fixup - byte match
;*		or	ch,dh
		db	 08h,0F5h		;  Fixup - byte match
;*		or	ax,si
		db	 09h,0F0h		;  Fixup - byte match
;*		add	ch,dh
		db	 00h,0F5h		;  Fixup - byte match
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	ss:data_33e[bp+si],al
		cmc				; Complement carry
		sbb	dh,al
;*		add	bl,dl
		db	 00h,0D3h		;  Fixup - byte match
                           lock	add	[bx+di],di
		cmp	ah,ah
		xor	al,33h			; '3'
		into				; Int 4 on overflow
		imul	byte ptr ds:data_12e[si]	; ax = data * al
;*		aad	0E5h			; undocumented inst
		db	0D5h,0E5h		;  Fixup - byte match
		pop	ds
		cmp	bh,[bp+si]
		into				; Int 4 on overflow
		cmp	bh,[bp+si]
		into				; Int 4 on overflow
		cmp	bh,[bp+si]
		into				; Int 4 on overflow
		cmp	bh,[bp+si]
		into				; Int 4 on overflow
		cmp	bh,[bp+si]
		into				; Int 4 on overflow
		cmp	bh,[bp+si]
		into				; Int 4 on overflow
		cmp	bh,[bp+si]
		into				; Int 4 on overflow
		cmp	bh,[bp+si]
		inc	ax
		mul	byte ptr ds:data_24e[di]	; ax = data * al
		in	ax,1Fh			; port 1Fh ??I/O Non-standard
		cmc				; Complement carry
		adc	dh,al
;*		add	bx,dx
		db	 01h,0D3h		;  Fixup - byte match
		cmp	[bp+si],di
		in	al,34h			; port 34h ??I/O Non-standard
		xor	cx,si
		neg	dh
;*		xor	dh,0A1h
		db	 82h,0F6h,0A1h		;  Fixup - byte match
		inc	dx
		test	ah,ch
		daa				; Decimal adjust
		sti				; Enable interrupts
;*		jc	loc_43			;*Jump if carry Set
		db	 72h, 01h		;  Fixup - byte match
;*                         lock	add	ch,cl
		db	0F0h, 00h,0CDh		;  Fixup - byte match
;*		add	bh,cl
		db	 00h,0CFh		;  Fixup - byte match
		add	dl,al
		add	cl,dh
;*		or	cx,dx
		db	 09h,0D1h		;  Fixup - byte match
		or	ah,[bx+si]
		db	0C0h, 20h,0C0h, 20h,0C0h, 20h
		db	0C0h,0C6h,0F0h, 00h,0F5h, 1Ch
		db	0F0h, 00h, 10h, 00h, 18h, 10h
		db	 00h, 10h, 18h, 10h,0F6h, 0Ch
		db	 03h, 10h, 00h, 18h, 10h, 00h
		db	 10h, 38h, 06h, 38h, 06h, 18h
		db	 10h, 00h, 18h, 10h, 00h, 10h
		db	 18h, 10h, 10h, 00h, 18h, 10h
		db	 00h, 10h, 18h, 10h, 10h, 00h
		db	 18h, 10h, 00h, 10h, 18h, 10h
		db	 10h, 00h, 18h, 10h, 00h, 10h
		db	 18h, 38h, 06h, 38h, 06h, 10h
		db	 00h, 18h, 10h, 00h, 10h, 18h
		db	 10h, 10h, 00h, 18h, 10h, 00h
		db	 10h, 18h, 10h, 10h, 00h, 18h
		db	 10h, 00h, 10h, 18h, 10h, 10h
		db	 00h, 18h, 10h, 00h, 10h, 38h
		db	 06h, 38h, 06h, 38h, 06h
		db	38h
		db	6			; Data table (indexed access)
		db	0F5h, 0Ch,0F0h
		dw	3000h
		db	 18h, 18h, 30h, 18h, 18h, 10h
		db	 10h, 00h, 30h, 18h, 38h, 06h
		db	 38h, 06h, 18h, 20h, 18h, 30h
		db	 06h, 30h, 06h, 30h, 18h, 18h
		db	 30h, 18h, 18h, 10h, 10h, 00h
		db	 10h, 38h, 18h, 10h, 38h, 18h
		db	 30h, 06h, 30h, 06h,0F6h, 6Fh
		db	 03h, 10h, 00h, 18h, 10h, 00h
		db	 10h, 18h, 10h, 10h, 00h, 18h
		db	 10h, 38h, 06h, 38h, 06h, 38h
		db	 06h, 38h, 06h, 38h, 06h, 38h
		db	 06h, 38h, 06h, 38h, 06h,0FBh
		db	 08h, 03h,0F0h, 00h,0E0h, 87h
		db	 80h,0E5h, 17h,0F0h, 01h,0DEh
		db	0D3h,0FCh, 55h, 04h,0F1h, 00h
		db	0F0h, 01h, 81h,0E5h, 0Fh,0D4h
		db	 43h, 72h,0E3h, 29h, 2Ah,0E4h
		db	 25h, 24h,0E3h,0F0h, 02h, 0Bh
		db	0E4h, 17h, 1Ah, 24h, 23h, 2Bh
		db	 2Ah,0E4h, 04h, 82h,0E5h, 0Fh
		db	 38h, 38h, 48h, 83h,0D3h, 14h
		db	 12h,0E3h, 2Bh, 2Ch,0E4h, 26h
		db	 24h, 59h, 66h, 82h, 38h, 38h
		db	 83h, 15h, 13h,0E3h, 2Bh, 28h
		db	 2Ah,0E4h, 23h, 08h, 82h, 38h
		db	 38h, 38h, 38h,0F5h, 0Ch,0F0h
		db	 02h, 83h,0D4h, 49h, 40h, 82h
		db	 48h, 83h, 49h, 40h, 82h, 48h
		db	 83h, 49h, 49h, 40h, 49h, 40h
		db	 82h, 38h, 38h, 48h, 83h,0E4h
		db	 44h, 43h,0E3h, 39h, 39h, 49h
		db	 40h, 82h, 48h, 83h, 49h, 40h
		db	 82h, 48h, 83h
		db	'D)D)D)44'
		db	0F6h, 0Dh, 04h,0D2h
		db	'*I(G&E$'
		db	'C2211'
		db	0E3h, 3Ch, 3Ch, 3Bh, 3Bh,0FBh
		db	0CCh, 03h,0F0h, 02h,0F5h, 08h
		db	0F0h, 02h, 1Ah, 19h, 24h, 25h
		db	 2Ah, 29h, 14h, 15h, 2Ah, 29h
		db	 24h, 25h,0F6h, 59h, 04h,0FEh
		db	0F0h, 00h,0F5h, 09h,0F0h, 00h
		db	0F5h, 08h,0F0h, 00h, 84h,0E5h
		db	 0Fh,0F5h, 1Ah,0F0h, 00h,0D3h
		db	0F0h, 01h, 39h, 3Ah,0E4h, 34h
		db	 33h,0CEh,0F6h, 7Ah, 84h, 85h
		db	0D6h,0E5h, 0Fh, 3Ah, 3Ah,0CEh
		db	 3Ah, 3Ah,0CEh, 3Ah, 3Ah,0CEh
		db	 3Ah, 3Ah,0CEh, 3Ah, 3Ah,0CEh
		db	 3Ah, 3Ah,0CEh, 3Ah, 3Ah,0CEh
		db	 3Ah, 3Ah, 40h,0F6h, 73h, 04h
		db	 84h,0E5h, 0Fh,0F5h, 12h,0F0h
		db	 01h,0D3h, 39h, 3Ah,0E4h, 34h
		db	 33h,0CEh,0F6h,0ACh, 84h,0F6h
		db	 6Fh, 44h,0F0h, 01h, 86h,0E5h
		db	 27h,0E1h, 10h,0F5h, 20h,0F0h
		db	 01h,0D3h,0FCh,0FDh, 04h,0F6h
		db	0C4h, 04h,0E5h, 1Fh,0F5h, 10h
		db	0F0h, 01h,0D3h,0FCh,0AEh, 05h
		db	0F6h,0D1h, 04h,0F5h, 10h,0F0h
		db	 01h,0D3h,0FCh, 23h, 05h,0F6h
		db	0DCh, 04h,0F5h, 18h,0F0h, 01h
		db	0D3h,0FCh, 3Dh, 05h,0F6h,0E7h
		db	 04h,0D3h,0FCh, 77h, 05h, 82h
		db	0E5h, 0Fh, 08h, 08h, 18h,0FBh
		db	0BBh, 04h,0F0h, 01h, 5Ah,0E4h
		db	 51h, 54h, 59h, 5Ah, 59h,0E3h
		db	 5Ah,0E4h, 51h, 54h, 59h, 5Ah
		db	 59h,0E3h, 3Ah,0E4h, 31h, 33h
		db	 36h, 3Ah, 38h,0E3h, 3Ah,0E4h
		db	'136:8:8:8'
		db	0FEh,0F0h, 01h, 0Ah,0E4h, 01h
		db	 03h,0E3h, 0Ah,0E4h, 05h, 01h
		db	 03h, 05h,0E3h, 0Ah,0E4h, 05h
		db	 01h, 03h,0E3h, 0Ah,0E4h, 05h
		db	 01h, 03h,0FEh,0F0h, 01h, 19h
		db	 5Ah, 5Bh, 5Ch,0E4h
		db	'QRS43434343'
		db	0E3h, 18h, 3Ah, 3Bh, 3Ch,0E4h
		db	 31h, 32h, 33h, 34h, 33h,0E3h
		db	 1Ah, 5Bh, 5Ch,0E4h
		db	'QRST545454'
loc_44:
		xor	ax,0E334h
		sbb	bh,[bp+di]
		cmp	al,0E4h
		xor	[bp+si],si
		xor	si,[si]
		xor	ax,0FE34h
                           lock	add	[bp+si],bx
		pop	bx
		pop	sp
		in	al,51h			; port 51h ??I/O Non-standard
		db	'RST54545454545454545454545454545'
		db	'454545454545454'
		db	0FEh,0F0h, 01h, 0Bh,0E4h, 02h
		db	 04h,0E3h, 0Bh,0E4h, 06h, 02h
		db	 04h, 05h,0E3h, 0Bh,0E4h, 06h
		db	 02h, 04h,0E3h, 0Bh,0E4h, 06h
		db	 02h, 04h,0FEh,0F0h, 00h, 87h
		db	0D1h,0F5h, 10h,0F0h, 00h,0E5h
		db	 0Fh,0F0h, 01h,0D8h, 1Ah, 14h
		db	 1Ah, 14h,0DBh, 0Ah, 0Ah,0D9h
		db	 24h,0D8h, 14h, 1Ah, 14h,0D9h
		db	 2Ah,0E4h,0F0h, 02h,0DFh,0E5h
		db	 17h,0F0h, 03h, 03h, 03h,0E5h
		db	 0Fh, 03h, 03h,0E5h, 0Fh, 03h
		db	 03h, 03h,0E5h, 07h, 03h, 03h
		db	 03h, 03h, 03h,0E3h,0F6h,0CEh
		db	 05h,0F0h, 03h,0D9h,0D1h,0E5h
		db	 0Fh,0F5h, 10h,0F0h, 03h, 88h
		db	 2Ah, 2Ah, 89h, 3Ah, 3Ah, 88h
		db	 2Ah, 24h, 2Ah, 89h, 3Ah, 3Ch
		db	 88h,0E4h, 21h,0E3h, 88h, 2Ah
		db	 24h, 89h, 3Ah, 3Ah, 88h
		db	2Ah
loc_45:
		and	al,2Ah			; '*'
		mov	[bp+si],di
		cmp	al,88h
		in	al,21h			; port 21h, 8259-1 int IMR
		jcxz	loc_45			; Jump if cx=0
		or	al,ds:data_13e
                           lock	add	cx,ds:data_17e[bx+si]
		mov	[bp+di],di
		cmp	cx,ds:data_15e[bx+si]
		sub	cx,ds:data_31e[bx+di]
		xor	ds:data_30e[bx+si],cx
		mov	[bp+di],ch
		and	ax,3B89h
		cmp	cx,ds:data_15e[bx+si]
		sub	cx,ds:data_31e[bx+di]
		xor	ds:data_30e[bx+si],cx
		div	byte ptr [bp+di]	; al,ah rem = ax/data
		push	es
		cmc				; Complement carry
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	cx,ds:data_16e[bx+si]
		mov	[bp+si],di
		cmp	cl,ds:data_14e[bx+si]
		sub	cl,ds:data_20e[bx+di]
;*		mov	ah,ah
		db	 88h,0E4h		;  Fixup - byte match
;*		and	bx,sp
		db	 21h,0E3h		;  Fixup - byte match
		mov	[bp+si],ch
		and	al,89h
		cmp	bh,[bp+si]
		mov	[bp+si],ch
loc_46:
		and	al,2Ah			; '*'
		mov	[bp+si],di
		cmp	al,88h
		in	al,21h			; port 21h, 8259-1 int IMR
		jcxz	loc_46			; Jump if cx=0
		pop	sp
		push	es
		cmc				; Complement carry
		or	al,0F0h
		add	cx,ds:data_17e[bx+si]
		mov	ds:data_27e,si
		sub	bp,[bp+di]
		sub	bp,[bp+di]
		mov	ds:data_29e,si
		cmp	di,[bp+di]
		mov	[bp+di],ch
		and	bp,[bp+di]
		and	cx,ds:data_19e[bx+di]
		mov	[bp+di],ah
		mov	ds:data_26e,si
		sub	sp,[bp+di]
		sub	bp,[bp+di]
		and	bp,[bp+di]
		sub	sp,[bp+di]
		sub	bp,[bp+di]
		sub	cx,ds:data_25e[bx+di]
		sub	cx,ds:data_25e[bx+di]
		sub	cx,ds:data_25e[bx+di]
		sub	cx,ds:data_32e[bx+di]
		test	ax,ds:data_18e
		cmp	cl,ds:data_16e[bx+si]
		mov	[bp+si],di
		cmp	cl,ds:data_16e[bx+si]
		mov	[bp+si],di
		cmp	cl,ds:data_16e[bx+si]
		mov	[bp+si],di
		cmp	cl,ds:data_16e[bx+si]
		mov	[bp+si],di
		cmp	cl,ds:data_28e[bx+si]
		cmp	bh,[bp+si]
		cmp	bh,[bp+si]
		sti				; Enable interrupts
		add	al,ds:data_21e
		sbb	ds:data_23e[bx+si],ch
		or	al,24h			; '$'
		push	es
		or	al,18h
		add	si,[bx+si]
		add	al,2
		dec	ax
		test	al,30h			; '0'
		sbb	ds:data_22e,al
		push	sp
		add	[si],ax
		or	[si],cl
		push	es
		and	[bx+si],dl
		adc	[bx],al
		pop	es
		add	[bx+di+41h],dx
		sbb	ax,4000h
		xor	bx,0EF5h
		add	[bx+si],al
		add	[bp+si],al
		add	al,[bx+di]
		xor	al,31h			; '1'
		inc	ax
		inc	ax
		db	0F1h,0F1h, 15h, 15h, 05h, 0Eh
		db	 08h, 08h, 05h, 05h, 01h,0B8h
		db	0A2h, 61h, 00h, 47h,0F0h, 25h
		db	 04h, 04h, 06h, 23h, 23h, 05h
		db	 05h, 01h, 45h, 02h, 1Bh, 00h
		db	0F7h,0F6h, 6Bh, 6Fh, 0Eh, 00h
		db	 00h, 00h, 02h, 02h, 01h, 41h
		db	0A1h, 1Eh, 00h, 50h, 43h,0F3h
		db	 35h, 0Eh, 00h, 00h, 00h, 02h
		db	 02h, 01h,0E0h, 31h, 11h, 00h
		db	0F4h,0F3h,0F8h, 88h, 88h, 00h
		db	0C0h,0C0h, 02h, 02h, 81h, 20h
		db	 01h, 10h, 00h,0F9h,0F6h, 13h
		db	 34h, 00h, 20h, 0Ch, 0Ch, 07h
		db	 07h, 01h, 61h, 72h, 16h, 00h
		db	0D4h, 8Bh, 24h, 18h, 0Eh, 01h
		db	 06h, 06h, 07h, 07h, 01h, 00h
		db	 01h, 03h, 0Eh, 05h, 5Fh, 31h
		db	 1Fh, 38h, 00h, 04h, 0Eh, 32h
		db	 32h, 02h, 02h, 01h, 00h, 01h
		db	 03h, 1Ch, 05h, 5Fh, 11h, 1Fh
		db	 38h, 00h, 05h, 01h,0E5h, 47h
		db	 06h, 02h, 01h, 00h, 02h, 09h
		db	 38h, 09h, 5Fh, 01h, 2Fh, 87h
		db	 00h, 04h, 0Eh, 15h, 15h, 05h
		db	 05h, 01h, 00h, 01h, 03h, 17h
		db	 09h, 5Fh, 11h, 0Fh, 38h, 00h
		db	 03h, 10h, 17h, 17h, 03h, 03h
		db	 01h, 00h, 01h, 03h, 06h, 07h
		db	 5Fh, 24h, 1Fh, 38h, 00h, 04h
		db	 00h, 33h, 33h, 02h, 02h, 01h
		db	 00h, 01h, 19h, 29h, 07h, 1Dh
		db	 81h, 0Fh, 38h, 1Fh, 03h, 00h
		db	 11h, 11h, 04h, 04h, 01h, 00h
		db	 02h, 03h, 10h, 0Bh,0DAh, 01h
		db	 1Fh, 38h, 00h, 05h, 01h,0E6h
		db	0BBh, 02h, 02h, 01h, 00h, 02h
		db	0D2h, 01h, 09h, 5Fh, 01h,0FFh
		db	 38h, 1Fh, 04h, 00h, 00h, 00h
		db	 02h, 02h, 81h, 01h, 02h,0D0h
		db	 01h, 07h, 99h, 01h,0FFh, 38h
		db	 00h, 05h, 00h, 00h, 00h, 02h
		db	 02h, 81h, 00h, 01h, 01h, 01h
		db	 07h, 99h, 01h, 1Eh, 38h, 00h
		db	 05h

_395UNKN	endp

seg_a		ends



		end	start
