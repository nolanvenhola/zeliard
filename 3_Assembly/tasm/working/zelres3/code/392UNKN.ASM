
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_392UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_18e	equ	1FE5h			;*
data_19e	equ	3002h			;*
data_20e	equ	3104h			;*
data_21e	equ	78E5h			;*
data_22e	equ	0F002h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_392UNKN	proc	far

start:
		db	 36h, 0Eh, 00h, 00h, 14h, 07h
		db	 1Eh, 07h,0E6h, 05h, 74h, 06h
		db	 01h, 1Fh, 00h, 02h,0F8h, 00h
		db	 03h,0ADh, 02h, 09h,0D8h, 03h
		db	 05h,0CDh, 05h, 06h,0D2h, 05h
loc_1:
		pop	es
		xlat				; al=[al+[bx]] table
		add	ax,0DC08h
		add	ax,0E109h
		add	ax,0F0h
		jmp	$-1FFDh
			                        ;* No entry point to code
		jge	loc_1			; Jump if > or =
;*		add	cl,ch
		db	 00h,0E9h		;  Fixup - byte match
		add	ds:data_21e[bx+si],ah
		out	59h,al			; port 59h ??I/O Non-standard
		loop	locloop_2		; Loop if cx > 0

		add	[bx+di],al
		add	dl,[bp+di]
		adc	al,15h
		db	'&&', 27h, 27h, '(())**++,,--..//'
		db	0E9h, 01h
		db	'  !!""##$$'
		db	'%%6'
		db	 07h, 08h, 07h, 09h, 07h, 47h
		db	 57h, 67h, 77h,0F0h, 01h, 07h
		db	0F5h, 01h, 02h,0F0h, 01h,0E9h
		db	 01h, 06h, 16h
		db	 2Ah, 2Bh

locloop_2:
		sub	al,21h			; '!'
		push	es
		db	'6--!.', 27h, 27h, 27h, 'GHMEDC'
		db	0F6h, 01h, 68h, 00h, 2Ah, 2Ah
		db	 5Ah, 6Bh, 7Eh, 7Fh, 0Bh, 06h
		db	 2Ah, 2Ah, 5Ah, 6Ch, 7Eh, 7Fh
		db	 0Ah, 06h, 2Ah, 2Ah, 5Ah, 6Bh
		db	 7Eh, 7Fh, 0Bh, 06h, 2Ah, 2Ah
		db	 5Ah, 6Ch, 7Eh, 7Fh,0E9h, 02h
		db	 70h, 71h, 72h, 73h, 04h
		db	'%&', 27h, '(&', 27h, '(#$$'
		db	'""  !!HIH'
		db	0F0h, 02h, 08h, 18h
		db	'(:3H(TR`PRTStTWH'
		db	0F0h, 03h, 08h, 18h, 19h, 18h
		db	'(8HZShHtr'
		db	0F0h, 04h, 00h, 10h, 12h, 14h
		db	 13h, 24h, 14h, 17h
		db	'830;41LL]m'
		db	0FBh, 25h, 00h,0FFh,0F0h, 04h
		db	0E9h, 02h
data_1		db	0A0h
		db	0F0h, 04h,0E9h, 02h,0E5h, 78h
		db	0E6h, 59h,0E2h, 40h, 7Eh, 7Fh
		db	0E9h, 03h, 70h,0F0h, 05h, 01h
		db	 02h, 03h, 14h, 15h, 14h, 16h
		db	 14h, 14h, 17h, 18h, 19h, 1Ah
		db	 1Bh, 1Ch, 1Dh, 1Eh, 1Fh,0E9h
		db	 04h, 10h, 11h, 11h, 12h, 13h
		db	 14h, 15h, 16h, 17h, 18h, 19h
		db	 18h, 12h, 1Ah, 1Bh, 1Ch, 1Ah
		db	 2Dh, 3Eh, 3Fh, 3Eh,0E9h, 05h
		db	 30h, 31h, 41h, 51h, 61h, 71h
		db	0F0h, 06h, 01h,0F5h, 01h, 02h
		db	0F0h, 06h,0E9h, 05h, 02h, 12h
		db	 23h, 24h, 25h, 26h, 02h
		db	'2', 27h, 27h, '&(!!!AIGJKL'
		db	0F6h, 01h, 45h, 01h, 2Dh, 2Dh
		db	 5Dh, 6Eh, 7Fh,0E9h, 06h, 70h
		db	 01h, 02h, 23h, 23h, 53h, 64h
		db	 75h, 70h, 03h, 02h, 23h, 23h
		db	 53h, 61h, 75h, 70h, 01h, 02h
		db	'##Sdupvtup'
		db	1
		db	27h, '()#()# !!%%&&$$'
		db	0E5h, 3Ch,0E6h, 03h,0E2h, 7Fh
		db	0F0h, 07h, 0Ah,0E2h, 73h, 0Ah
		db	0E2h, 69h, 0Ah,0E2h, 5Fh, 0Ah
		db	0E2h, 55h, 0Ah,0E2h, 4Bh, 0Ah
		db	0E2h, 46h, 0Ah,0E2h, 3Ch, 0Ah
		db	0E2h, 37h, 0Ah,0E2h, 2Dh, 0Ah
		db	0E2h, 23h, 0Ah,0E2h, 19h, 0Ah
		db	0E2h, 7Fh, 0Bh,0E2h, 73h, 0Bh
		db	0E2h, 69h, 0Bh,0E2h, 5Fh, 0Bh
		db	0E2h, 55h, 0Bh,0E2h, 4Bh, 0Bh
		db	0E2h, 46h, 0Bh,0E2h, 3Ch, 0Bh
		db	0E2h, 37h, 0Bh,0E2h, 2Dh, 0Bh
		db	0E2h, 23h, 0Bh,0E2h, 19h, 0Bh
		db	0E2h, 7Fh, 04h,0E2h, 73h, 04h
		db	0E2h, 69h, 04h

locloop_3:
;*		loop	locloop_11		;*Loop if cx > 0

		db	0E2h, 5Fh		;  Fixup - byte match
		add	al,0E2h
		push	bp
		add	al,0E2h
		dec	bx
		add	al,0E2h
		inc	si
		add	al,0E2h
		cmp	al,4
;*		loop	locloop_8		;*Loop if cx > 0

		db	0E2h, 37h		;  Fixup - byte match
		add	al,0E2h
		sub	ax,0E204h
		and	ax,[si]
		loop	locloop_7		; Loop if cx > 0

		add	al,0E2h
		jge	loc_5			; Jump if > or =
;*		loop	locloop_21		;*Loop if cx > 0

		db	0E2h, 73h		;  Fixup - byte match

locloop_4:
		push	es
		loop	locloop_19		; Loop if cx > 0

		push	es
loc_5:
;*		loop	locloop_18		;*Loop if cx > 0

		db	0E2h, 5Fh		;  Fixup - byte match
		push	es
;*		loop	locloop_17		;*Loop if cx > 0

		db	0E2h, 55h		;  Fixup - byte match
		push	es
		loop	locloop_16		; Loop if cx > 0

		push	es
;*		loop	locloop_15		;*Loop if cx > 0

		db	0E2h, 46h		;  Fixup - byte match
		push	es
		loop	locloop_14		; Loop if cx > 0

		push	es

locloop_7:
		loop	locloop_13		; Loop if cx > 0

		push	es
;*		loop	locloop_12		;*Loop if cx > 0

		db	0E2h, 2Dh		;  Fixup - byte match
		push	es
		loop	$+25h			; Loop if cx > 0

		push	es
		loop	locloop_10		; Loop if cx > 0

		push	es
;*		loop	locloop_27		;*Loop if cx > 0

		db	0E2h, 7Fh		;  Fixup - byte match
		or	ah,dl
		jnc	loc_9			; Jump if carry=0
;*		loop	locloop_25		;*Loop if cx > 0

		db	0E2h, 69h		;  Fixup - byte match
		or	ah,dl
		pop	di
		or	ah,dl
		push	bp
		or	ah,dl
loc_9:
		dec	bx
		or	ah,dl
		inc	si
		or	ah,dl
		cmp	al,0Ah

locloop_10:
		loop	locloop_20		; Loop if cx > 0

		or	ah,dl
		sub	ax,0E20Ah
		and	cx,[bp+si]
		loop	$+1Bh			; Loop if cx > 0

		or	ah,dl
		jg	$+0Dh			; Jump if >
		loop	$+75h			; Loop if cx > 0

		or	sp,dx
		db	 69h, 0Bh

locloop_13:
		loop	$+61h			; Loop if cx > 0


locloop_14:
		or	sp,dx
		push	bp
		or	sp,dx
		dec	bx
		or	sp,dx
		inc	si

locloop_16:
		or	sp,dx
		cmp	al,0Bh
		loop	locloop_26		; Loop if cx > 0

		or	sp,dx
		sub	ax,0E20Bh
		and	cx,[bp+di]
		loop	locloop_23		; Loop if cx > 0

		or	sp,dx
		jg	$+6			; Jump if >
;*		loop	locloop_32		;*Loop if cx > 0

		db	0E2h, 73h		;  Fixup - byte match

locloop_19:
		add	al,0E2h
		db	 69h, 04h

locloop_20:
		loop	locloop_31		; Loop if cx > 0

		add	al,0E2h
loc_22:
		push	bp
		add	al,0E2h
		dec	bx
		add	al,0E2h
		inc	si
		add	al,0E2h
		cmp	al,4

locloop_23:
		loop	locloop_30		; Loop if cx > 0

		add	al,0E2h
		sub	ax,0E204h
		and	ax,[si]
;*		loop	locloop_28		;*Loop if cx > 0

		db	0E2h, 19h		;  Fixup - byte match
		add	al,0E5h
		js	loc_22			; Jump if sign=1
		pop	cx
		loop	locloop_31		; Loop if cx > 0

		adc	dx,[bx+si]
		push	ss

locloop_26:
		sbb	al,11h
		adc	al,2Bh			; '+'
		sub	si,[bp+si]
		inc	dx
		sti				; Enable interrupts
		std				; Set direction flag
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
                           lock	pop	es
		jmp	$-5FF7h
			                        ;* No entry point to code
		in	ax,6Eh			; port 6Eh ??I/O Non-standard
		out	1Ch,al			; port 1Ch ??I/O Non-standard
                           lock	pop	es
		jmp	$-0AF7h
		db	 01h, 03h,0F0h, 07h,0E9h
loc_29:
		push	es
		loop	$+42h			; Loop if cx > 0

		pop	bp
		db	 6Dh, 7Eh

locloop_30:
;*		jge	loc_33			;*Jump if > or =
		db	 7Dh, 7Eh		;  Fixup - byte match
		jg	loc_29			; Jump if >
		add	ds:data_22e[di],di
		or	[di],cl
		or	ax,0E91Dh
		pop	es
		adc	[bx+di],dl
		adc	ah,[bp+di]
		cmc				; Complement carry
		add	[bp+di],cx
;*                         lock	or	cl,ch
		db	0F0h, 08h,0E9h		;  Fixup - byte match
		pop	es

locloop_31:
		add	al,35h			; '5'
		add	dl,[di]
		add	word ptr ds:[237h],si
		add	dl,ss:data_20e
		xor	dh,dh			; Zero register
;*		add	bx,bx
		db	 01h,0DBh		;  Fixup - byte match
		add	al,[bx+di]
		cmp	[bx+di],al
		sbb	[bx+di],al
		xor	ax,231h
		add	dl,ss:data_19e
		xor	al,[si]
		xor	ax,1502h
		add	word ptr ds:[237h],si
		add	dl,ss:data_1
		inc	bx
		add	[bx+di],dx
		adc	[bx+di],ax
		adc	[bx+di],dx
		add	[bx+di],dx
		adc	[bx+di],ax
		adc	[bx+di],dx
		add	[bx+di],dx
		adc	[bx+di],ax
		adc	[bx+di],dx
		add	[bx+di],dx
		adc	[bx+di],ax
		adc	[bx+di],dx
		add	al,14h
		adc	al,4
		adc	al,14h
		add	al,14h
		adc	al,4
		adc	al,14h
		add	al,14h
		adc	al,4
		adc	al,14h
		add	al,14h
		adc	al,4
		adc	al,14h
		or	[bx+di],bx
		sbb	[bx+di],cx
		sbb	[bx+di],bx
		or	[bx+di],bx
		sbb	[bx+di],cx
		sbb	[bx+di],bx
		or	[bx+di],bx
		sbb	[bx+di],cx
		sbb	[bx+di],bx
loc_34:
		or	[bx+di],bx
		sbb	[bx+di],cx
		sbb	[bx+di],bx
		add	[bx+di],dx
		adc	[bx+di],ax
		adc	[bx+di],dx
		add	[bx+di],dx
		adc	[bx+di],ax
		adc	[bx+di],dx
		add	[bx+di],dx
		adc	[bx+di],ax
		adc	[bx+di],dx
		add	[bx+di],dx
		adc	[bx+di],dx
		sbb	[si],dx
		adc	al,[bx+di]
		adc	[bx+di],dx
		add	[bx+di],dx
		adc	[bx+di],ax
		adc	[bx+di],dx
		add	[bx+di],dx
		adc	[bx+di],ax
		adc	[bx+di],dx
		add	[bx+di],dx
		adc	[bx+di],ax
		adc	[bx+di],dx
		add	[bx+di],dx
		adc	[si],ax
		adc	al,14h
		add	al,14h
		adc	al,4
		adc	al,14h
		add	al,14h
		adc	al,4
		adc	al,14h
		add	al,14h
		adc	al,4
		adc	al,14h
		add	al,14h
		adc	al,9
		sbb	[bx+di],bx
		or	[bx+di],bx
		sbb	[bx+di],cx
		sbb	[bx+di],bx
		or	[bx+di],bx
		sbb	[bx+di],cx
		sbb	[bx+di],bx
		or	[bx+di],bx
		sbb	[bx+di],cx
		sbb	[bx+di],bx
		or	[bx+di],bx
		sbb	[bp+si+5Bh],bx
		pop	sp
		pop	bp
		pop	si
		pop	di
		adc	al,14h
		db	 6Fh,0E9h
		db	8, '`abcbcdefghyY'
		db	0F0h, 09h, 06h, 09h, 06h, 04h
		db	0FBh,0B6h, 02h,0FFh,0F0h, 09h
		db	0E9h, 08h,0F0h, 09h,0E9h, 08h
		db	0E5h, 7Fh,0E7h, 0Ah,0E2h, 6Ah
		db	 1Ah, 0Bh, 1Ah, 0Bh, 1Ah, 0Bh
		db	 2Bh, 3Ch
		db	8 dup (49h)
		db	0F5h, 01h, 07h,0F0h, 09h,0E9h
		db	8, ':EEEE5I:AEE:EE:EE5IE:EE'
		db	0F6h, 01h,0F9h, 03h, 3Ah
		db	'EEEE5I:AEE:EE:'
		db	'EEIIII:LKEE5I:AEE:EE:EE5IE:EE'
		db	0F5h, 01h, 06h,0F0h, 09h,0E9h
		db	8, ':EEEE5I:AEE:EE:EE5IE:EE'
		db	0F6h, 01h, 47h, 04h
		db	':EEEE5I:AEE:EE:EE'
		db	0E2h, 78h, 4Dh, 4Dh, 46h, 46h
		db	0E2h
		db	'j:LKEE5I:AEE:EE:EE5IE:EE'
		db	0F5h, 01h, 08h,0F0h, 09h,0E9h
		db	8, ':EEEE5I:AEE:EE:EE5IE:EE'
		db	0F6h, 01h, 99h, 04h
		db	':EEEE5I:AEE'
		db	0E2h
		db	'xMMBBFFJJ'
		db	0E2h
		db	'j:LKEE9EEEE5JE5JE9EEEE'
		db	0F5h, 01h, 02h,0F0h, 09h,0E9h
		db	8, ':EEEE9EEEE:EE5JE9EEEE'
		db	0F6h, 01h,0E7h, 04h
		db	':EEEE9EEAK:EE5JE9EEEE'
		db	0F5h, 01h, 03h,0F0h, 09h,0E9h
		db	8, ':EEEE9EEEE:EE5JE9EEEE'
		db	0F6h, 01h, 1Ch, 05h, 3Ah, 45h
		db	'EE'
		db	'E9EEAK:EE5JEYII:LKEE9EEEE5JE5JE9'
		db	'EEEE'
		db	0F5h, 01h, 02h,0F0h, 09h,0E9h
		db	8, ':EEEE9EEEE:EE5JE9EEEE'
		db	0F6h, 01h, 64h, 05h, 3Ah, 45h
		db	'EEE9EEAK:EE5JE9EEEE:EEEE9EEEE:EE'
		db	'5JE9EEEE:EEEE9EEAK:EE5JEYIImmmbb'
		db	'bFF:|', 1Bh
		db	0FBh,0DCh, 03h,0FFh,0F0h, 09h
		db	0E9h, 08h,0FFh,0F0h, 09h,0E9h
		db	 08h,0FFh,0F0h, 09h,0E9h, 08h
		db	0FFh,0F0h, 09h,0E9h, 08h,0FFh
		db	0F0h, 09h,0E9h, 08h,0FFh
		db	'@ABCDEFGHIJKLMNOPQRSTU'
		db	80h
		db	'XWYEJOVLHMOLHJ>ACEDFGQ'
		db	80h
		db	'9:;<?@AS0B28C9D7E./GH12I<>LKN0J'
		db	 80h, 5Dh, 5Ch, 5Eh, 5Dh, 80h
		db	'JOTV[Q\ZYX@EGCE'
		db	80h
		db	'@JGH9<>MLB&)+()+'
		db	80h
		db	'-&$'
		db	'!#.975421/.-,+*)(', 27h, '&$'
		db	 80h, 22h, 30h, 01h, 01h, 03h
		db	 03h, 06h, 06h, 0Ch,0FFh, 01h
		db	 02h, 12h, 13h, 18h, 19h, 60h
		db	 61h, 60h, 60h, 48h,0FFh, 06h
		db	 06h, 30h,0FFh, 01h, 01h
		db	'HH', 0Ch, 0Ch, '00', 9, 0Ah, 0Ch
		db	0Dh, 'HH00`a', 0Ch, 0Ch, '01HI``'
		db	1, 1
		db	9, 0Ah, 0Ch, 0Dh, 'HH00`a', 0Ch, 0Ch
		db	'01', 0Ch, 0Ch, 'HI', 8, 8
		db	 06h, 06h, 24h,0FFh, 60h,0FFh
		db	 01h, 01h, 03h, 03h, 06h, 06h
		db	 0Ch,0FFh, 01h, 01h, 01h, 02h
		db	 12h, 13h, 18h, 19h, 60h, 61h
		db	 60h, 60h, 48h,0FFh, 06h, 06h
		db	 30h,0FFh, 01h, 01h, 48h, 48h
		db	 0Ch, 0Ch, 30h, 30h, 10h, 10h
		db	 08h, 08h, 06h, 06h, 24h,0FFh
		db	 60h,0FFh, 10h, 0Fh, 08h, 07h
		db	 18h, 17h, 0Ch, 0Bh, 06h, 05h
		db	 30h,0FFh, 12h, 11h, 18h,0FFh
		db	 08h, 07h, 01h, 01h, 10h, 0Fh
		db	 18h, 17h, 60h, 01h, 30h,0FFh
		db	 00h, 01h, 06h, 01h, 0Ch, 01h
		db	 08h, 01h, 24h, 01h, 04h, 23h
		db	 00h, 2Eh, 00h,0BCh, 00h, 9Eh
		db	 01h,0A9h, 01h, 3Ch, 02h,0E1h
		db	 02h,0B0h, 03h,0EDh, 04h, 77h
		db	 02h, 8Dh, 06h,0C9h, 06h, 55h
		db	 06h, 1Eh, 07h, 0Ch,0B0h, 01h
		db	 05h, 01h, 01h,0F0h, 00h,0E0h
		db	 82h, 80h,0E5h, 17h,0D4h,0FBh
		db	0E9h, 02h,0F0h, 00h, 80h,0E5h
		db	 17h,0D3h,0FCh, 42h, 04h, 82h
		db	0D5h,0F5h, 08h,0F0h, 00h,0E5h
		db	 0Fh, 06h,0CFh, 06h,0CFh, 06h
		db	0CFh, 06h,0CFh, 06h,0CFh, 06h
		db	0CFh, 06h,0CFh, 06h,0CFh, 06h
		db	0CFh, 06h,0CFh, 06h,0CFh, 06h
		db	0E5h, 0Fh, 05h,0CFh, 05h,0CFh
		db	 05h,0CFh, 05h,0CFh, 05h,0CFh
		db	 05h,0CFh, 05h,0CFh, 05h,0CFh
		db	 05h,0CFh, 05h,0CFh, 05h,0CFh
		db	 05h,0E5h, 0Fh, 03h,0CFh, 03h
		db	0CFh, 03h,0CFh, 03h,0CFh, 03h
		db	0CFh, 03h,0CFh, 03h,0CFh, 03h
		db	0CFh, 03h,0CFh, 03h,0CFh, 03h
		db	0CFh, 03h,0F7h,0A7h, 00h,0E5h
		db	 0Fh, 01h,0CFh, 01h,0CFh, 01h
		db	0CFh, 01h,0CFh, 01h,0CFh, 01h
		db	0CFh, 01h,0CFh, 01h,0CFh, 01h
		db	0CFh, 01h,0CFh, 01h,0CFh, 01h
		db	0FBh, 3Bh, 00h,0F0h, 00h, 80h
		db	0E5h, 17h,0D4h, 15h, 18h,0E4h
		db	 11h,0E3h, 17h, 1Ah,0E4h, 13h
		db	 25h, 25h, 30h,0FBh, 2Eh, 00h
		db	0F0h, 00h, 81h,0E5h, 07h,0F0h
		db	 00h,0D2h,0F5h, 0Ch,0F0h, 00h
		db	 03h
data_8		db	13h			; Data table (indexed access)
		db	 46h, 43h, 46h, 48h,0F6h,0C6h
		db	 00h, 53h, 53h, 23h, 25h, 26h
		db	 2Ah, 60h,0F5h, 2Ch,0F0h, 00h
		db	 5Ah, 73h, 58h, 23h, 56h, 71h
		db	0E3h, 7Ah,0E4h, 58h, 71h, 58h
		db	 21h, 5Ah, 76h, 78h,0F6h,0DAh
		db	 00h, 56h,0E3h, 7Ch,0E4h, 56h
		db	0E3h, 2Ch,0E4h
		db	'VsvXqX!XuxZsX#Vq'
		db	0E3h, 7Ah,0E4h, 58h, 71h, 58h
		db	 21h, 5Ah, 56h, 40h,0FCh, 53h
		db	 01h
		db	'V&&V&&V&&V&&V&&V&&V&&&+*('
		db	0FCh, 53h, 01h,0E4h, 1Ah, 18h
		db	 16h, 15h, 13h, 12h,0E3h, 2Ah
		db	 2Ah,0E4h,0F0h, 01h, 02h,0E3h
		db	 0Ch, 0Bh, 0Ah, 09h, 0Ah, 09h
		db	 08h, 07h, 06h, 05h, 04h, 13h
		db	 23h, 36h, 33h, 36h, 38h,0FBh
		db	0C1h, 00h,0F0h, 01h
		db	 46h, 56h
		db	'VFVVF'
		db	'VV'
		db	'FVVFV'
		db	'VF'
		db	'VVFVVFVVJZZ'
		db	'JZZJZZJZZJZZJZZJZZJ'
		db	'ZZK[[K[[K[[K[[K[[K[[K[[K[['
		db	0FEh,0F0h, 00h, 80h,0E5h, 1Fh
		db	0D4h,0E1h, 04h,0FBh,0E9h, 02h
		db	0F0h, 00h, 80h,0E5h, 1Fh,0D3h
		db	0E1h, 04h,0FCh, 42h, 04h, 82h
		db	0D5h,0F0h, 01h, 60h,0F5h, 08h
		db	0F0h, 01h,0E5h, 1Fh, 16h,0CFh
		db	 16h,0CFh, 16h,0CFh, 16h,0CFh
		db	 16h,0CFh, 16h,0CFh, 16h,0CFh
		db	 16h,0CFh, 16h,0CFh, 16h,0CFh
		db	 16h,0CFh, 16h,0E5h, 1Fh, 15h
		db	0CFh, 15h,0CFh, 15h,0CFh, 15h
		db	0CFh, 15h,0CFh, 15h,0CFh, 15h
		db	0CFh, 15h,0CFh, 15h,0CFh, 15h
		db	0CFh, 15h,0CFh, 15h,0E5h, 1Fh
		db	 13h,0CFh, 13h,0CFh, 13h,0CFh
		db	 13h,0CFh, 13h,0CFh, 13h,0CFh
		db	 13h,0CFh, 13h,0CFh, 13h,0CFh
		db	 13h,0CFh, 13h,0CFh, 13h,0F7h
		db	 27h, 02h,0E5h, 1Fh, 11h,0CFh
		db	 11h,0CFh, 11h,0CFh, 11h,0CFh
		db	 11h,0CFh, 11h,0CFh, 11h,0CFh
		db	 11h,0CFh, 11h,0CFh, 11h,0CFh
		db	 11h,0CFh, 11h,0FBh,0BBh, 01h
		db	0F0h, 01h, 80h,0E5h, 1Fh,0D4h
		db	 65h, 28h,0E4h, 21h,0E3h, 27h
		db	 2Ah,0E4h
loc_35:
		and	dx,[di+55h]
		jo	loc_35			; Jump if overflow=1
		test	ax,0F001h
		add	ss:data_8[bp+di],al
;*		aam	0F0h			; undocumented inst
		db	0D4h,0F0h		;  Fixup - byte match
		add	al,[bx+si]
		adc	[di],ah
		and	ax,2525h
		and	ax,2525h
		and	ax,64F5h
                           lock	add	dh,[bx+si]
		xor	ax,3530h
		not	byte ptr [bx+si+2]
		xor	[di],dh
		xor	[di],ah
		and	ax,2525h
		cmc				; Complement carry
;*		cmp	al,dh
		db	 38h,0F0h		;  Fixup - byte match
		add	dh,[bx+si]
		xor	ax,3530h
		mul	byte ptr [bp+si+2]	; ax = data * al
		inc	bp
		inc	bp
		inc	bp
		inc	bp
		inc	bp
		inc	bp
		and	ax,5025h
		sti				; Enable interrupts
		cmp	al,2
;*                         lock	add	al,dl
		db	0F0h, 00h,0D0h		;  Fixup - byte match
;*		add	ch,cl
		db	 00h,0CDh		;  Fixup - byte match
;*		add	bh,cl
		db	 00h,0CFh		;  Fixup - byte match
		add	cl,dh
;*		or	cx,dx
		db	 09h,0D1h		;  Fixup - byte match
		pop	es
		retn	0F020h
		db	 20h,0A8h
		db	0Ah, 8, 8, 8, 8, 8, 8, 8
		db	0F5h, 64h,0F0h, 00h, 11h, 01h
		db	 01h, 01h, 09h, 11h, 01h, 01h
		db	 11h, 01h, 11h, 01h, 09h, 01h
		db	 11h, 01h,0F6h, 92h, 02h, 11h
		db	 01h, 01h, 01h, 09h, 11h, 01h
		db	 01h, 11h, 01h, 11h, 01h, 08h
		db	 08h, 08h, 08h,0F5h, 38h,0F0h
		db	 00h, 11h, 01h, 01h, 01h, 09h
		db	 01h, 01h, 01h, 11h, 01h, 01h
		db	 01h, 09h, 01h, 01h, 01h,0F6h
		db	0B9h, 02h
		db	 28h, 08h, 28h, 08h, 28h, 08h
data_16		dw	828h
		db	 28h, 08h, 28h, 08h, 08h, 08h
		db	 20h, 84h,0FBh, 77h, 02h,0F0h
		db	 00h,0E0h, 82h, 80h,0E5h, 17h
		db	0D3h,0F0h, 00h,0F0h, 01h, 05h
		db	 06h, 07h,0F0h, 02h, 68h, 69h
		db	 6Ah, 2Bh, 2Bh, 2Ch, 2Ch,0E4h
		db	'!!""##$$'
		db	'%%&&', 27h, 27h, '(())**++,,'
		db	0E4h, 21h, 21h, 22h, 22h, 70h
		db	0F0h, 03h, 05h, 04h, 05h, 06h
		db	 05h, 15h,0E7h, 25h,0E3h,0E3h
		db	0F5h, 08h,0F0h, 03h, 30h, 4Ah
		db	0E4h, 43h, 48h, 4Ah, 50h,0E4h
		db	 43h, 43h,0E3h, 4Ah, 45h,0E4h
		db	 45h, 45h, 45h, 05h, 04h, 03h
		db	 02h, 01h,0E3h, 0Ch,0E3h,0F6h
		db	 26h, 03h,0F5h, 08h,0F0h, 03h
		db	 4Ah, 4Ah, 6Ah,0E4h, 73h,0F0h
		db	 04h, 05h, 01h, 13h, 10h,0E3h
		db	 2Ah, 2Ah, 3Ah,0E4h, 48h, 05h
		db	 01h,0F7h, 64h, 03h,0E3h, 1Ah
		db	 10h,0FBh, 46h, 03h,0F0h, 04h
		db	 06h, 08h, 05h, 01h, 13h,0E3h
		db	 23h, 26h, 28h, 2Ah, 26h, 28h
		db	 2Ah,0E4h
		db	'!##%%&&(('
		db	0E3h,0F5h, 08h,0F0h, 04h, 5Ah
		db	 59h, 5Ah, 6Ah, 0Bh,0E4h, 01h
		db	0E3h, 7Ah,0E4h, 43h, 45h,0F0h
		db	 05h, 06h, 15h, 13h, 11h, 23h
		db	0E3h, 18h,0F7h, 9Eh, 03h, 3Ah
		db	0FBh, 80h, 03h,0F0h, 05h, 4Ah
		db	0E4h, 41h, 46h,0E3h, 4Ch,0E4h
		db	 43h, 48h, 5Ah, 5Ah, 60h,0E3h
		db	0FBh,0E9h, 02h,0F0h, 00h, 80h
		db	0E5h, 1Fh,0D2h,0FCh, 42h, 04h
		db	 81h,0D4h,0E1h, 20h,0F5h, 08h
		db	0F0h, 00h,0E5h, 17h, 06h,0CFh
		db	 06h,0CFh, 06h,0CFh, 06h,0CFh
		db	 06h,0CFh, 06h,0CFh, 06h,0CFh
		db	 06h,0CFh, 06h,0CFh, 06h,0CFh
		db	 06h,0CFh, 06h,0E5h, 17h, 05h
		db	0CFh, 05h,0CFh, 05h,0CFh, 05h
		db	0CFh, 05h,0CFh, 05h,0CFh, 05h
		db	0CFh, 05h,0CFh, 05h,0CFh, 05h
		db	0CFh, 05h,0CFh
loc_36:
		add	ax,17E5h
		add	cx,di
		add	cx,di
		add	cx,di
		add	cx,di
		add	cx,di
		add	cx,di
		add	cx,di
		add	cx,di
		add	cx,di
		add	cx,di
		add	cx,di
		add	si,di
		sub	ax,[si]
		in	ax,17h			; port 17h ??I/O Non-standard
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	di,cx
		db	 01h,0CFh		;  Fixup - byte match
;*		add	bx,di
		db	 01h,0FBh		;  Fixup - byte match
		mov	di,data_22e+1
		add	ds:data_18e[bx+si],al
		loopz	$+2			; Loop if zf=1, cx>0

		rcl	word ptr [di],cl	; Rotate thru carry
;*		sbb	ah,ah
		db	 18h,0E4h		;  Fixup - byte match
;*		adc	bx,sp
		db	 11h,0E3h		;  Fixup - byte match
		pop	ss
		sbb	ah,ah
		adc	sp,[di]
		and	ax,0FB30h
		mov	al,3
;*                         lock	add	al,dh
		db	0F0h, 00h,0F0h		;  Fixup - byte match
		add	[bp+si],cx
		or	cx,[si]
		in	al,0F0h			; port 0F0h ??I/O Non-standard
		add	ah,[bx+di+64h]
		db	 65h, 26h,0E4h, 2Ch,0E3h, 28h
		db	0E3h, 21h,0E4h, 26h, 26h, 27h
		db	0E3h, 23h, 29h,0E4h, 25h,0E3h
		db	 2Ah,0E4h, 29h,0E3h, 28h,0E4h
loc_37:
		sub	ah,bl
		jcxz	loc_39			; Jump if cx=0
		sub	al,0E4h
		in	al,2Ch			; port 2Ch ??I/O Non-standard
		sub	al,0E4h
;*		and	bx,sp
		db	 21h,0E3h		;  Fixup - byte match
;*		jcxz	loc_40			;*Jump if cx=0
		db	0E3h, 22h		;  Fixup - byte match
		and	sp,sp
		in	al,22h			; port 22h ??I/O Non-standard
		jcxz	$+23h			; Jump if cx=0
loc_38:
		and	sp,sp
		and	ax,2524h
		and	ah,[bx]
		jcxz	loc_37			; Jump if cx=0
;*		and	sp,sp
		db	 21h,0E4h		;  Fixup - byte match
		in	al,24h			; port 24h ??I/O Non-standard
		daa				; Decimal adjust
		jo	loc_38			; Jump if overflow=1
		add	cx,[bp+si]
		or	[bp+si],cx
		or	cx,[bp+si]
		sbb	ah,bh
		sub	ah,bl
		cmc				; Complement carry
loc_39:
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	si,[bx+si]
		inc	bx
		dec	ax
		in	al,41h			; port 41h, 8253 timer 1 refsh
		inc	bx
		push	ax
		dec	ax
		dec	ax
		inc	bx
		jcxz	$+4Ch			; Jump if cx=0
		in	al,4Ah			; port 4Ah ??I/O Non-standard
		dec	dx
		dec	dx
		or	cl,[bx+di]
		or	[bx],al
		push	es
		add	ax,0F6E3h
		xchg	si,ax
		add	al,0F5h
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	ax,[di+45h]
		db	 65h, 7Ah,0F0h, 04h, 0Ch, 08h
		db	 1Ah, 10h, 25h, 25h, 35h,0E4h
		db	 43h,0E3h, 0Ch, 08h,0F7h,0D0h
		db	 04h, 15h, 10h,0FBh,0B4h, 04h
		db	0F0h, 04h,0E4h, 01h, 03h,0E3h
		db	 0Ch, 08h, 1Ah,0E3h, 2Ah,0E4h
		db	'!#%!#%(**,,'
		db	0E4h, 21h, 21h, 23h, 23h,0FEh
		db	0F0h, 00h, 82h,0E5h, 07h,0D1h
		db	0F5h, 0Ch,0F0h, 00h,0D9h, 03h
		db	0F0h, 05h,0DFh, 43h,0D9h,0F0h
		db	 06h, 06h, 03h, 06h, 08h,0F6h
		db	0F5h, 04h,0D9h, 23h, 23h, 83h
		db	 33h, 35h, 36h, 38h,0DCh, 84h
		db	38h
		db	7 dup (38h)
		db	0D9h,0F5h, 2Ch,0F0h, 06h,0D1h
		db	 82h, 2Ah, 23h, 84h,0DCh, 38h
		db	0D9h, 82h, 28h, 83h, 33h, 82h
		db	 26h, 21h, 84h,0DCh, 38h,0D9h
		db	 82h,0E3h, 5Ah,0E4h, 28h, 21h
		db	 84h,0DCh, 38h,0D9h, 82h, 28h
		db	 83h, 31h, 82h, 2Ah, 26h, 84h
		db	0DCh, 38h,0D9h, 82h, 58h,0F6h
		db	 1Ch, 05h,0D1h, 82h, 26h,0E3h
		db	 2Ch, 84h,0DCh, 38h,0D9h, 82h
		db	0E4h, 26h, 83h,0E3h, 3Ch, 82h
		db	0E4h, 26h, 23h, 84h,0DCh, 38h
		db	0D9h, 82h, 56h, 28h, 21h, 84h
		db	0DCh, 38h,0D9h, 82h, 28h, 83h
		db	 31h, 82h, 28h, 25h, 84h,0DCh
		db	 38h,0D9h, 82h, 58h,0D1h, 82h
		db	 2Ah, 23h, 84h,0DCh, 38h,0D9h
		db	 82h, 28h, 83h, 33h, 82h, 26h
		db	 21h, 84h,0DCh, 38h,0D9h, 82h
		db	0E3h, 5Ah,0E4h, 28h, 21h, 84h
		db	0DCh, 38h,0D9h, 82h, 28h, 83h
		db	 31h, 82h, 2Ah, 26h,0DCh, 84h
		db	 38h, 38h, 38h, 38h,0D9h,0F5h
		db	 08h,0F0h, 06h,0F5h, 09h,0F0h
		db	 06h,0D1h, 82h, 26h, 83h, 36h
		db	 36h, 84h, 28h, 83h, 36h, 36h
		db	 82h, 26h, 83h, 36h, 36h, 84h
		db	 28h, 83h, 36h, 36h,0F6h,0A8h
		db	 45h,0F5h, 09h,0F0h, 06h,0D1h
		db	 82h, 2Ah, 83h, 3Ah, 3Ah, 84h
		db	 28h, 83h, 3Ah, 3Ah, 82h, 2Ah
		db	 83h, 3Ah, 3Ah, 84h, 28h, 83h
		db	 3Ah, 3Ah,0F6h,0C4h, 45h,0F5h
		db	 09h,0F0h, 06h,0D1h, 82h, 2Bh
		db	 83h, 3Bh, 3Bh, 84h, 28h, 83h
		db	 3Bh, 3Bh, 82h, 2Bh, 83h, 3Bh
		db	 3Bh, 84h, 28h, 83h, 3Bh, 3Bh
		db	0F6h,0E0h, 45h,0F7h, 2Dh, 06h
		db	0D1h, 82h, 26h, 83h, 36h, 36h
		db	 84h, 28h, 83h, 36h, 36h, 82h
		db	 26h, 83h, 36h, 36h, 84h, 28h
		db	 83h, 36h, 36h,0D1h, 82h, 26h
		db	 83h, 36h, 36h, 84h, 28h, 83h
		db	 36h, 36h, 82h, 26h, 83h, 36h
		db	 36h, 84h,0DCh, 38h,0D9h, 83h
		db	 3Bh, 3Ah, 36h,0FBh,0A4h, 05h
		db	0F0h, 06h,0DCh,0D2h, 82h, 1Ah
		db	 18h, 16h, 15h, 13h, 12h,0E3h
		db	 83h, 3Ah, 3Ah,0E4h, 61h,0E3h
		db	'lkjijihgfeds'
		db	 13h,0DAh, 82h, 06h, 03h, 06h
		db	 08h,0FBh,0EDh, 04h, 10h, 08h
		db	 06h, 84h, 18h, 0Ch, 30h, 12h
		db	 01h, 10h, 08h, 18h, 0Ch, 06h
		db	 04h, 84h,0F0h,0A8h, 06h, 18h
		db	 08h, 84h, 03h, 0Ch, 01h, 13h
		db	0D8h,0A8h, 06h, 90h, 48h, 0Ch
		db	 30h, 60h, 06h, 48h, 0Ch, 01h
		db	 5Dh,0A8h, 3Ch, 0Ch, 54h,0C0h
		db	 08h, 06h, 84h, 02h, 18h, 08h
		db	 0Ch, 06h, 02h, 12h, 01h, 10h
		db	 20h, 10h, 10h, 07h, 07h, 01h
		db	 51h, 41h, 1Dh, 00h, 40h, 81h
		db	0F3h,0F5h, 0Eh, 00h, 00h, 00h
		db	 02h, 02h, 01h,0E0h, 31h, 11h
		db	 00h,0F4h,0F3h,0F8h, 88h, 88h
		db	 00h,0C0h,0C0h, 02h, 02h, 81h
		db	 02h, 01h, 0Eh, 00h,0F6h,0F6h
		db	 44h, 44h, 0Bh, 01h, 00h,0FFh
		db	0FFh, 20h, 81h, 10h, 00h, 06h
		db	 00h,0F6h,0F8h,0FFh, 05h, 0Fh
		db	 0Eh, 15h, 15h, 05h, 05h, 01h
		db	 00h, 01h, 03h, 17h, 09h, 5Fh
		db	 11h, 0Fh, 38h, 00h, 03h, 0Eh
		db	 43h, 43h, 04h, 04h, 81h, 00h
		db	 01h, 1Fh, 02h, 09h, 6Eh, 31h
		db	 1Fh, 38h, 00h, 04h, 00h, 00h
		db	 00h, 02h, 02h, 81h, 01h, 02h
		db	0D0h, 01h, 07h, 99h, 01h,0FFh
		db	 38h, 00h, 05h, 00h, 00h, 00h
		db	 02h, 02h, 81h, 00h, 01h, 01h
		db	 01h, 07h, 99h, 01h, 1Eh, 38h
		db	 00h, 05h, 00h,0FFh, 00h, 71h
		db	 70h, 01h, 01h, 02h,0B4h, 01h
		db	 07h, 5Fh, 01h,0FEh, 87h, 00h
		db	 04h

_392UNKN	endp

seg_a		ends



		end	start
