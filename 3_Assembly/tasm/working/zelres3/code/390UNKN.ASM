
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_390UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	17E5h			;*
data_2e		equ	3304h			;*
data_27e	equ	211Dh			;*
data_28e	equ	0F504h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_390UNKN	proc	far

start:
		mov	ch,15h
		add	[bx+si],al
		db	0C6h, 0Ah,0EBh, 0Ah,0EDh, 08h
		db	 4Ch, 09h, 01h, 1Fh, 00h, 02h
		db	0F6h, 00h, 03h, 4Bh, 03h, 04h
		db	 77h, 04h, 09h, 7Ch, 05h, 06h
		db	0D9h, 08h, 07h,0DEh, 08h, 08h
		db	0E3h, 08h, 09h,0E8h, 08h,0F0h
		db	 00h,0E9h, 00h,0E0h, 82h,0E6h
		db	 58h,0E5h, 78h, 00h, 10h, 20h
		db	0E2h, 40h, 31h, 32h, 33h, 34h
		db	 33h, 32h,0F0h, 00h,0E9h, 00h
		db	 41h, 53h, 54h, 65h, 76h, 77h
		db	0F0h, 01h, 07h, 17h
		db	'&%4CDU5`ABCDCAq'
		db	0F0h, 02h, 03h, 04h, 15h
		db	'&', 27h, '7GVUfW(', 27h, '()xx'
		db	0F0h, 03h, 08h, 18h, 28h, 20h
		db	 20h, 10h
		db	'0ABCDCBQcd%vw'
		db	0F0h, 04h, 07h, 17h
		db	'&%4CDU5`ABCDCAq'
		db	0F0h, 05h, 03h, 04h, 15h
		db	'&', 27h, '7GVUfW(', 27h, '()xx'
		db	0F0h, 06h, 08h, 18h
		db	'(8HJGKFELD'
		db	0E6h, 17h,0E5h, 78h, 14h, 54h
		db	 65h, 56h, 75h, 76h,0F0h, 07h
		db	 05h, 1Dh, 16h, 15h, 26h, 16h
		db	 37h, 18h, 47h, 48h, 57h, 17h
		db	 16h, 15h, 14h, 6Dh, 0Eh, 04h
		db	 6Dh, 63h, 24h, 14h, 35h, 16h
		db	 45h, 46h, 05h, 1Dh, 16h, 15h
		db	 26h, 16h, 37h, 18h, 47h, 48h
		db	 57h, 17h, 16h, 15h, 14h, 6Dh
		db	 0Eh, 04h, 71h, 21h, 11h,0E6h
		db	58h
		db	0E5h, 78h, 41h, 42h, 43h, 44h
		db	 43h, 42h,0FBh, 34h, 00h,0FFh
		db	0F0h, 07h,0E9h, 00h,0F0h, 07h
		db	0E9h, 00h,0E6h, 72h,0E5h, 78h
		db	0E2h, 64h,0F0h, 08h, 0Fh, 0Fh
		db	 1Fh, 1Fh, 1Fh, 27h, 10h, 14h
		db	 2Dh, 10h,0E9h, 01h, 10h, 11h
		db	 11h, 11h, 11h, 32h, 41h, 41h
		db	 32h, 41h, 51h, 51h, 13h, 12h
		db	 14h, 14h, 12h, 15h, 15h, 15h
		db	0E6h, 58h,0E5h, 6Eh, 22h,0E2h
		db	 40h, 13h, 16h, 17h, 18h, 17h
		db	 16h, 23h,0E5h, 64h, 13h, 16h
		db	 17h, 18h, 17h, 16h, 23h,0E5h
		db	 6Eh, 27h, 28h, 29h, 22h,0E5h
		db	 64h, 27h, 28h, 29h,0E5h, 73h
		db	 6Ah, 78h,0F0h, 09h, 08h, 18h
		db	'*+3LM^>b'
		db	0E5h, 6Eh, 72h,0F0h, 0Ah, 03h
		db	 06h, 07h, 08h, 07h, 06h, 13h
		db	0E5h, 64h, 03h, 06h, 07h, 08h
		db	 07h, 06h, 13h,0E5h, 6Eh, 17h
		db	 18h, 19h, 12h,0E5h, 64h, 17h
		db	 18h, 19h,0E5h
		db	's*8HXjkzo#/#&33'
		db	0F0h, 0Bh, 03h, 13h, 23h,0E6h
		db	 72h,0E5h, 78h,0E2h
		db	'd<<LAB<<LABLBJEBJJBRkjRk'
		db	0E9h, 02h
		db	'ppqqrrssttppUA'
		db	0F0h, 0Ch, 05h, 11h, 11h, 05h
		db	 11h, 11h, 05h, 21h, 26h, 26h
		db	 27h, 27h, 24h, 24h,0E6h, 58h
		db	0E5h, 6Eh, 05h,0E2h
		db	'@$'
		db	'()#)(4'
		db	0E5h
		db	'd$'
		db	'()#)(4'
		db	0E5h, 6Eh, 39h, 33h, 3Ah, 05h
		db	0E5h, 64h, 39h, 33h, 3Ah,0E5h
		db	 73h, 47h, 53h, 63h, 73h,0F0h
		db	 0Dh, 07h, 0Bh, 14h, 22h, 2Ch
		db	 3Dh, 1Dh, 45h,0E5h
		db	'nUdhiciht'
		db	0E5h
		db	'ddhiciht'
		db	0E5h, 6Eh, 79h, 73h, 7Ah, 55h
		db	0E5h, 64h, 79h, 73h, 7Ah,0E5h
		db	 73h,0F0h, 0Eh, 07h, 13h, 23h
		db	 33h, 47h, 4Bh, 57h, 4Eh, 04h
		db	 0Eh, 04h, 08h, 14h, 14h, 64h
		db	 74h,0F0h, 0Fh, 04h, 1Eh, 1Eh
		db	 14h, 14h, 19h, 19h, 13h, 13h
		db	 16h, 16h, 12h, 12h, 1Dh, 1Dh
		db	 1Fh, 1Fh,0E5h, 50h,0E6h, 03h
		db	0E2h, 41h,0E9h, 03h, 10h, 11h
		db	 12h,0E2h, 50h, 10h, 11h, 12h
		db	0E2h, 5Fh, 10h, 11h, 12h,0E2h
		db	 6Eh, 10h, 11h, 12h,0E2h, 78h
		db	 10h, 11h, 12h,0E2h, 41h, 10h
		db	 11h, 12h, 13h, 14h,0E2h, 50h
		db	 11h, 12h, 13h, 14h,0E2h, 5Fh
		db	 11h, 12h, 13h, 14h,0E2h, 73h
		db	 11h, 12h, 13h, 14h,0E2h, 41h
		db	 15h, 16h, 17h,0E2h, 50h, 15h
		db	 16h, 17h,0E2h, 5Fh, 15h, 16h
		db	 17h,0E2h, 6Eh, 15h, 16h, 17h
		db	0E2h, 78h, 15h, 16h, 17h,0E2h
		db	 41h, 15h, 16h, 17h, 18h, 14h
		db	0E2h, 50h, 16h, 17h, 18h, 14h
		db	0E2h, 5Fh, 16h, 17h, 18h, 14h
		db	0E2h, 73h, 16h, 17h, 18h, 14h
		db	8 dup (29h)
		db	8 dup (2Ah)
		db	8 dup (29h)
		db	 11h, 19h, 1Bh, 19h, 16h, 19h
		db	 1Bh, 19h, 1Ch, 19h, 1Bh, 11h
		db	 1Ch, 12h, 17h, 18h,0E2h, 41h
		db	 10h, 11h, 12h,0E2h, 50h, 10h
		db	 11h, 12h,0E2h, 5Fh, 10h, 11h
		db	 12h,0E2h
		db	6Eh

locloop_2:
		adc	[bx+di],dl
		adc	ah,dl

locloop_3:
;*		js	loc_6			;*Jump if sign=1
		db	 78h, 10h		;  Fixup - byte match
		adc	[bp+si],dx
		loop	locloop_10		; Loop if cx > 0

		adc	[bx+di],dl
		adc	dl,[bp+di]
		adc	al,0E2h
		push	ax
		adc	[bp+si],dx
		adc	dx,[si]
		loop	locloop_12		; Loop if cx > 0

		adc	[bp+si],dx
		adc	dx,[si]
		loop	locloop_17		; Loop if cx > 0

		adc	[bp+si],dx
		adc	dx,[si]
		loop	locloop_11		; Loop if cx > 0


locloop_8:
		adc	ax,1716h
		loop	locloop_13		; Loop if cx > 0

		adc	ax,1716h
;*		loop	locloop_15		;*Loop if cx > 0

		db	0E2h, 5Fh		;  Fixup - byte match
		adc	ax,1716h
		loop	locloop_18		; Loop if cx > 0

		adc	ax,1716h
		loop	$+7Ah			; Loop if cx > 0

		adc	ax,1716h
		loop	locloop_14		; Loop if cx > 0

		adc	ax,1716h
		sbb	[si],dl
		loop	$+52h			; Loop if cx > 0

		push	ss
		pop	ss
		sbb	[si],dl
		loop	locloop_19		; Loop if cx > 0

		push	ss
		pop	ss

locloop_10:
		sbb	[si],dl
		loop	$+75h			; Loop if cx > 0

		push	ss
		pop	ss
		sbb	[si],dl
		sub	[bx+di],bp
		sub	[bx+di],bp
		sub	[bx+di],bp
		sub	[bx+di],bp
		sub	ch,[bp+si]
		sub	ch,[bp+si]
		sub	ch,[bp+si]
		sub	ch,[bp+si]
		sti				; Enable interrupts

locloop_11:
		cli				; Disable interrupts
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
;*                         lock	pop	cs			; Dangerous-8088 only
		db	0F0h, 0Fh		;  Fixup - byte match
;*		jmp	loc_24			;*
		db	0E9h, 03h, 04h		;  Fixup - byte match
			                        ;* No entry point to code
		add	al,0F0h
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		jmp	$-19FAh
		db	 58h,0E1h, 28h, 40h

locloop_12:
		in	ax,5Ah			; port 5Ah ??I/O Non-standard

locloop_13:
		and	al,0E2h
		inc	ax
		adc	[di],bx

locloop_14:
		push	ds
		adc	bl,ds:data_27e
		in	ax,50h			; port 50h ??I/O Non-standard
		adc	[di],bx
		push	ds
		adc	bl,ds:data_27e
		in	ax,5Ah			; port 5Ah ??I/O Non-standard
		and	ah,cs:[bx]

locloop_17:
		and	al,0E5h
		push	ax
		and	ah,cs:[bx]
		in	ax,5Fh			; port 5Fh ??I/O Non-standard
		cmp	al,42h			; 'B'
		push	dx
		db	 62h, 7Ch, 76h,0F0h, 10h

locloop_18:
		add	[bx+si],bx
		pop	ds
		jmp	$+2007h
		db	 00h, 31h

locloop_19:
		in	ax,5Ah			; port 5Ah ??I/O Non-standard
		inc	cx
		push	dx
		push	bx
		push	sp
		push	bp
		push	sp
		push	bx
		db	 62h,0E5h
		db	'PRSTUTSb'
		db	0E5h, 5Ah, 64h, 65h, 66h, 41h
		db	0E5h, 50h, 64h, 65h, 66h,0E5h
		db	 5Fh, 77h,0F0h, 11h, 05h, 15h
		db	'%78G9RYRS'
		db	 02h, 02h, 62h, 72h,0F0h, 12h
		db	 02h, 01h, 01h, 01h,0E6h, 58h
		db	0E5h, 5Ah, 11h, 22h, 23h, 24h
		db	 25h, 24h, 23h, 32h,0E5h
		db	'P"#$'
		db	'%$'
		db	'#2'
		db	0E5h, 5Ah, 34h, 35h, 36h, 11h
		db	0E5h, 50h, 34h, 35h, 36h,0E5h
		db	 5Fh, 47h, 55h, 65h, 75h,0F0h
		db	 13h, 07h, 08h, 12h, 2Ah, 2Bh
		db	 30h, 10h, 41h,0E5h
		db	'ZQbcdedcr'
		db	0E5h
		db	'Pbcdedcr'
		db	0E5h, 5Ah, 74h, 75h, 76h, 51h
		db	0E5h, 50h, 74h, 75h, 76h,0E5h
		db	 5Fh,0F0h, 14h, 07h, 15h, 25h
		db	 35h, 47h, 48h, 57h, 49h, 02h
		db	 09h, 02h, 03h, 12h, 12h, 62h
		db	 72h,0F0h, 15h, 02h, 19h, 19h
		db	 12h, 12h, 14h, 14h, 15h, 15h
		db	 1Ch, 1Ch, 1Ah, 1Ah, 10h, 10h
		db	 1Dh, 1Dh,0E6h, 17h,0E5h, 78h
		db	 25h, 35h, 46h, 3Ch, 16h, 1Ch
		db	'V7<6,<J0'
		db	 1Ah, 10h, 6Ah, 3Ah, 3Ch, 36h
		db	 35h, 07h, 58h, 55h, 07h, 04h
		db	 25h, 35h, 46h, 3Ch, 16h, 1Ch
		db	'V7<6,<J0'
		db	 1Ah, 10h, 6Ah, 3Ah, 3Ch, 36h
		db	 35h, 07h, 58h, 55h, 72h, 22h
		db	 32h, 61h,0FBh, 51h, 03h,0FFh
		db	0F0h, 15h,0E9h, 04h,0E6h, 1Fh
		db	0E5h, 78h,0F0h, 15h,0E9h, 04h
		db	0F5h, 01h, 02h,0F0h, 15h,0E9h
		db	 04h,0E2h, 40h, 3Eh, 3Fh,0E9h
		db	 05h, 30h, 11h
		db	32h
loc_20:
		xor	[bx+di],dx
		xor	[bx+di],dh
		test	byte ptr [bx+di],86h
		add	al,0F5h
		add	[bp+si],ax
                           lock	adc	ax,5E9h
		cmc				; Complement carry
		add	al,[bp+si]
                           lock	adc	ax,5E9h
		xor	dh,[bx+di]
		xor	[bx+di],dl
		xor	dh,[bx+di]
		adc	[bx+si],si
;*		xor	si,si			; Zero register
		db	 31h,0F6h		;  Fixup - byte match
		add	ah,ds:data_2e[di]
                           lock	push	ss
		add	al,3
		adc	ax,506h
		adc	dl,[bx+di]
		adc	[bx+di],ah
		adc	dl,[bx+di]
		and	[bx+si],dx
;*		adc	si,si
		db	 11h,0F6h		;  Fixup - byte match
		add	ss:data_28e[bp],bx

locloop_21:
		add	[si],ax
                           lock	push	ss
		jmp	$+1208h
			                        ;* No entry point to code
		adc	[bx+si],dx
		and	[bp+si],dx
		adc	[bx+di],sp
		adc	[bx+di],dl
		test	byte ptr [bx+di],0CEh
		add	al,0F5h
		add	[bp+si],ax
                           lock	push	ss
		jmp	$-0AF8h
			                        ;* No entry point to code
		add	al,[bp+si]
                           lock	push	ss
		jmp	$+1208h
			                        ;* No entry point to code
		adc	[bx+si],dx
		and	[bp+si],dx
		adc	[bx+di],sp
		adc	[bx+di],dl
		test	byte ptr [bp+si],0E9h
		add	al,13h
		add	al,3
		adc	ax,506h
		adc	dl,[bx+di]
		adc	[bx+di],ah
		adc	dl,[bx+di]
		and	[bx+si],dx
;*		adc	si,si
		db	 11h,0F6h		;  Fixup - byte match
;*		add	dx,sp
		db	 01h,0E2h		;  Fixup - byte match
		add	al,12h
		adc	[bx+si],dx
		and	[bp+si],dx
		adc	[bx+di],sp
		adc	[bx+di],dl
		adc	dl,[bx+di]
		adc	[bx+di],ah
		adc	dl,[bx+di]
		and	[bx+si],dx
		and	[bx+di],sp
		db	 36h, 16h, 47h, 14h, 14h, 14h
		db	 54h, 54h, 62h, 22h, 22h, 36h
		db	 16h, 43h, 14h, 14h, 14h
		db	 54h, 54h, 48h
		db	8 dup (12h)
		db	8 dup (19h)
		db	16 dup (12h)
		db	 36h, 16h, 47h, 14h, 14h, 14h
		db	 54h, 54h, 62h, 22h, 22h, 36h
		db	 16h, 43h, 14h, 14h, 14h
		db	 54h, 54h, 48h
		db	8 dup (12h)
		db	8 dup (19h)
		db	0FBh, 7Fh, 04h,0FFh,0F0h, 16h
		db	0E9h, 05h,0E5h, 7Fh,0E7h, 0Ah
		db	0E2h, 6Ah, 7Ah,0E2h, 5Ch,0F0h
		db	 17h, 0Bh,0E2h, 6Ah, 0Bh, 1Ch
		db	0E2h, 5Ch, 1Bh,0E2h, 4Eh, 07h
		db	 0Bh,0E2h, 6Ah, 1Ah,0E2h, 5Ch
		db	 0Bh,0E2h, 4Eh, 0Bh,0E2h, 6Ah
		db	 1Ch,0E2h, 5Ch, 1Bh,0E2h, 4Eh
		db	 07h,0E2h, 5Ch, 0Bh,0E2h, 6Ah
		db	 1Ah,0E2h, 5Ch, 0Bh,0E2h, 6Ah
		db	 0Bh, 1Ch,0E2h, 5Ch, 1Bh,0E2h
		db	 4Eh, 07h,0E2h, 6Ah, 05h, 1Ah
		db	0E2h, 4Eh, 0Bh, 0Bh,0E2h, 6Ah
		db	 1Ch,0E2h, 4Eh, 27h, 17h,0E2h
		db	 6Ah, 2Ch, 1Ch,0E2h, 4Eh, 27h
		db	0E2h, 6Ah, 1Ch,0E2h, 4Eh, 27h
		db	0F0h, 17h,0E9h, 05h,0E2h, 6Ah
		db	 1Ah,0E2h, 5Ch, 0Dh, 0Eh,0E2h
		db	 6Ah, 1Ch,0E2h, 5Ch, 1Bh,0E2h
		db	 4Eh, 07h, 0Bh,0E2h, 6Ah, 1Ah
		db	0E2h, 5Ch, 0Bh,0E2h, 4Eh, 0Bh
		db	0E2h, 6Ah, 1Ch,0E2h, 5Ch, 1Bh
		db	0E2h, 4Eh, 07h,0E2h, 5Ch, 0Bh
		db	0F5h, 01h, 02h,0F0h, 17h,0E9h
		db	 05h,0E2h, 6Ah, 1Ah,0E2h, 5Ch
		db	 0Bh,0E2h, 6Ah, 0Bh, 1Ch,0E2h
		db	 5Ch, 1Bh,0E2h, 4Eh, 07h, 0Bh
		db	0E2h, 6Ah, 1Ah,0E2h, 5Ch, 0Bh
		db	0E2h, 4Eh, 0Bh,0E2h, 6Ah, 1Ch
		db	0E2h, 5Ch, 1Bh,0E2h, 4Eh, 07h
		db	0E2h, 5Ch, 0Bh,0F6h, 01h, 05h
		db	 06h,0E2h, 6Ah, 1Ah,0E2h, 5Ch
		db	 0Bh,0E2h, 6Ah, 0Bh, 1Ch,0E2h
		db	 5Ch, 1Bh,0E2h, 4Eh, 07h,0E2h
		db	 6Ah, 05h, 1Ah,0E2h, 4Eh, 0Bh
		db	 0Bh,0E2h, 6Ah, 1Ch,0E2h, 4Eh
		db	 07h,0E2h, 6Ah, 1Ch,0E2h, 4Eh
		db	 27h,0E2h, 6Ah, 1Ch,0E2h, 4Eh
		db	 27h,0E2h, 6Ah, 1Ah,0E2h, 5Ch
		db	 0Dh, 0Eh,0E2h, 6Ah, 1Ch,0E2h
		db	 5Ch, 1Bh,0E2h, 4Eh, 07h, 0Bh
		db	0E2h, 6Ah, 1Ah,0E2h, 5Ch, 0Bh
		db	0E2h, 4Eh, 0Bh,0E2h, 6Ah, 1Ch
		db	0E2h, 5Ch, 1Bh,0E2h, 4Eh, 07h
		db	0E2h, 5Ch, 0Bh,0F5h, 01h, 03h
		db	0F0h, 17h,0E9h, 05h,0E2h, 6Ah
		db	 1Ah,0E2h, 5Ch, 0Bh,0E2h, 6Ah
		db	 0Bh, 1Ch,0E2h, 5Ch, 1Bh,0E2h
		db	 4Eh, 07h, 0Bh,0E2h, 6Ah, 1Ah
		db	0E2h, 5Ch, 0Bh,0E2h, 4Eh, 0Bh
		db	0E2h, 6Ah, 1Ch,0E2h, 5Ch, 1Bh
		db	0E2h, 4Eh, 07h,0E2h, 5Ch, 0Bh
		db	0F6h, 01h, 86h, 06h,0E2h, 6Ah
		db	 1Ah,0E2h, 5Ch, 0Bh,0E2h, 6Ah
		db	 0Bh, 1Ch,0E2h, 5Ch, 1Bh,0E2h
		db	 4Eh, 07h,0E2h, 6Ah, 05h, 1Ah
		db	0E2h, 4Eh, 0Bh, 0Bh,0E2h, 6Ah
		db	 1Ch,0E2h, 4Eh, 07h,0E2h, 6Ah
		db	 23h, 16h, 2Ah,0E5h, 7Fh,0E7h
		db	 0Ah, 1Ah, 0Dh, 0Eh, 1Ch,0E2h
		db	 4Eh, 07h, 0Bh,0E2h, 6Ah, 1Ah
		db	0E2h, 5Ch, 0Bh,0E2h, 4Eh, 0Bh
		db	0E2h, 6Ah, 1Ch,0E2h, 5Ch, 1Bh
		db	0E2h, 4Eh, 07h,0E2h, 5Ch, 0Bh
		db	0E5h, 7Fh,0E7h, 0Ah,0E2h, 6Ah
		db	 1Ah,0E2h, 5Ch, 0Bh,0E2h, 6Ah
		db	 0Bh, 1Ch,0E2h, 5Ch, 1Bh,0E2h
		db	 4Eh, 07h, 0Bh,0E2h, 6Ah, 1Ah
		db	0E2h, 5Ch, 0Bh,0E2h, 4Eh, 0Bh
		db	0E2h, 6Ah, 1Ch,0E2h, 5Ch, 1Bh
		db	0E2h, 4Eh, 07h,0E2h, 5Ch, 0Bh
		db	0E2h, 6Ah, 1Ah,0E2h, 5Ch, 0Bh
		db	0E2h, 6Ah, 0Bh, 1Ch,0E2h, 5Ch
		db	 1Bh,0E2h

locloop_22:
		dec	si
		pop	es
		loop	$+6Ch			; Loop if cx > 0

		add	ax,0E21Ah
		dec	si

locloop_23:
		or	cx,[bp+di]
;*		loop	locloop_25		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		sbb	al,0E2h
		dec	si
		pop	es
		loop	$+6Ch			; Loop if cx > 0

		sbb	al,0E2h
		dec	si
		daa				; Decimal adjust
		loop	$+6Ch			; Loop if cx > 0

		sbb	al,0E2h
		dec	si
		daa				; Decimal adjust
		loop	$+6Ch			; Loop if cx > 0

		sbb	ah,dl
		pop	sp
		or	ax,0E20Eh
		db	 6Ah, 1Ch,0E2h, 5Ch, 1Bh,0E2h
		db	 4Eh, 07h, 0Bh,0E2h, 6Ah, 1Ah
		db	0E2h, 5Ch, 0Bh,0E2h, 4Eh, 0Bh
		db	0E2h, 6Ah, 1Ch,0E2h, 5Ch, 1Bh
		db	0E2h, 4Eh, 07h,0E2h, 5Ch, 0Bh
		db	0F5h, 01h, 02h,0F0h, 17h,0E9h
		db	 05h,0E2h, 6Ah, 1Ah,0E2h, 5Ch
		db	 0Bh,0E2h, 6Ah, 0Bh, 1Ch,0E2h
		db	 5Ch, 1Bh,0E2h, 4Eh, 07h, 0Bh
		db	0E2h, 6Ah, 1Ah,0E2h, 5Ch, 0Bh
		db	0E2h, 4Eh, 0Bh,0E2h, 6Ah, 1Ch
		db	0E2h, 5Ch, 1Bh,0E2h, 4Eh, 07h
		db	0E2h, 5Ch, 0Bh,0F6h, 01h, 75h
		db	 07h,0E2h, 6Ah, 1Ah

locloop_25:
		loop	$+5Eh			; Loop if cx > 0

		or	sp,dx
		db	 6Ah, 0Bh, 1Ch,0E2h, 5Ch, 1Bh
		db	0E2h, 4Eh, 07h,0E2h, 6Ah, 05h
		db	 1Ah,0E2h, 4Eh, 0Bh, 0Bh,0E2h
		db	 6Ah, 1Ch,0E2h, 4Eh, 07h,0E2h
		db	 6Ah, 1Ch,0E2h, 4Eh, 27h,0E2h
		db	 6Ah, 1Ch,0E2h, 4Eh, 27h,0E2h
		db	 6Ah, 1Ah,0E2h, 5Ch, 0Dh, 0Eh
		db	0E2h, 6Ah, 1Ch,0E2h, 5Ch, 1Bh
		db	0E2h, 4Eh, 07h, 0Bh,0E2h, 6Ah
		db	 1Ah,0E2h
		db	5Ch
loc_26:
		or	sp,dx
		dec	si
		or	sp,dx
		db	 6Ah, 1Ch,0E2h, 5Ch, 1Bh
loc_27:
;*		loop	locloop_29		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		pop	es
		loop	$+5Eh			; Loop if cx > 0

loc_28:
		or	si,bp
		add	[si],ax
                           lock	pop	ss
		jmp	$-1DF8h
		db	 6Ah, 1Ah,0E2h, 5Ch, 0Bh,0E2h
		db	 6Ah, 0Bh, 1Ch,0E2h, 5Ch, 1Bh
		db	0E2h, 4Eh, 07h, 0Bh,0E2h, 6Ah
		db	 1Ah,0E2h, 5Ch, 0Bh,0E2h, 4Eh
		db	 0Bh,0E2h, 6Ah, 1Ch,0E2h, 5Ch
		db	 1Bh,0E2h, 4Eh, 07h,0E2h, 5Ch
		db	 0Bh,0F6h, 01h,0F6h, 07h,0E2h
		db	 6Ah, 1Ah,0E2h, 5Ch, 0Bh,0E2h
		db	 6Ah, 0Bh, 1Ch,0E2h, 5Ch, 1Bh
		db	0E2h, 4Eh, 07h,0E2h, 6Ah, 05h
		db	 1Ah,0E2h, 4Eh, 0Bh, 0Bh,0E2h

locloop_29:
		db	 6Ah, 1Ch,0E2h, 4Eh, 07h,0E2h
		db	 6Ah, 1Ch,0E2h, 4Eh, 27h,0E2h
		db	 6Ah, 1Ch,0E2h, 4Eh, 27h,0F5h
		db	 01h, 02h,0F0h, 17h,0E9h, 05h
		db	0E2h, 6Ah, 1Ah,0E2h, 5Ch, 3Dh
		db	0E2h, 6Ah, 09h, 1Ch, 47h, 0Ah
		db	 0Ah, 0Ah, 0Ah, 09h, 1Ch, 47h
		db	 3Ah, 09h, 1Ch, 47h, 0Ah, 0Ah
		db	 0Ah, 0Ah, 09h, 1Ch, 47h,0F5h
		db	 02h, 03h,0F0h, 17h,0E9h, 05h
		db	 1Ah,0E2h, 5Ch, 0Bh,0E2h, 6Ah
		db	 0Bh, 1Ch,0E2h, 5Ch, 1Bh,0E2h
		db	 4Eh, 07h, 0Bh,0E2h, 6Ah, 1Ah
		db	0E2h, 5Ch, 0Bh,0E2h, 4Eh, 0Bh
		db	0E2h, 6Ah, 1Ch,0E2h, 5Ch, 1Bh
		db	0E2h, 4Eh, 07h,0E2h, 5Ch, 0Bh
		db	0F6h, 02h, 75h, 08h,0E2h, 6Ah
		db	 1Ah,0E2h, 5Ch, 0Bh,0E2h, 6Ah
		db	 0Bh, 1Ch,0E2h, 5Ch, 1Bh,0E2h
		db	 4Eh, 07h, 0Bh,0E2h, 6Ah, 1Ah
		db	0E2h, 5Ch, 0Bh,0E2h, 6Ah, 0Bh
		db	 1Ch,0E2h, 4Eh, 27h,0E2h, 6Ah
		db	 1Ch,0E2h, 4Eh, 27h,0E2h, 6Ah
		db	 1Ch,0E2h, 4Eh, 27h,0E2h, 6Ah
		db	 1Ch,0E2h, 4Eh, 27h,0F6h, 01h
		db	 51h, 08h,0FBh,0D8h, 05h,0FFh
		db	0F0h, 17h,0E9h, 05h,0FFh,0F0h
		db	 17h,0E9h, 05h,0FFh,0F0h, 17h
		db	0E9h, 05h,0FFh,0F0h, 17h,0E9h
		db	 05h,0FFh, 80h
		db	'EFIJLMOQRPNKHGT@<'
		db	80h
		db	'EATFIJLHGOPQC>TOJE'
		db	80h
		db	'MHFILGPQCUAEJM'
		db	80h
		db	'CGLO@>?HFIPQ'
		db	80h
		db	'EFIJLHGCOPMU-454-0+.)&/,$'
		db	'*("'
		db	 80h, 60h,0FFh, 30h,0FFh, 0Ch
		db	0FFh, 06h, 06h, 48h, 48h, 0Ch
		db	 0Ch, 60h, 60h, 02h, 02h, 08h
		db	 09h, 04h, 04h, 10h, 10h, 30h
		db	 30h, 03h, 03h, 12h, 13h, 06h
		db	0FFh, 48h, 48h, 0Ch, 0Ch, 60h
		db	 60h, 02h, 02h, 08h, 09h, 04h
		db	 04h, 10h, 10h, 20h, 20h, 02h
		db	 03h, 24h, 25h, 30h, 31h, 60h
		db	 60h, 0Ch,0FFh, 06h, 06h, 48h
		db	 48h, 0Ch, 0Ch, 02h, 02h, 08h
		db	 09h, 04h, 04h, 10h, 10h, 30h
		db	 30h, 03h, 03h, 12h, 13h, 06h
		db	0FFh, 48h, 48h, 0Ch, 0Ch, 60h
		db	 60h, 02h, 02h, 08h, 09h, 04h
		db	 04h, 10h, 10h, 20h, 20h, 02h
		db	 03h
		db	'$'
		db	'%01`aHH'
		db	 03h, 03h, 0Ch, 0Ch, 18h, 18h
		db	 06h, 06h, 30h, 30h, 0Ch, 0Ch
		db	 30h, 31h, 18h, 18h, 06h, 06h
		db	 24h, 24h, 60h, 60h, 60h, 61h
		db	 03h, 03h, 06h, 06h, 0Ch, 0Ch
		db	 08h,0FFh, 08h, 08h, 04h, 04h
		db	 02h, 02h, 02h, 03h, 08h, 09h
		db	 04h, 04h, 10h, 10h, 30h, 30h
		db	 03h, 03h, 12h, 13h, 18h,0FFh
		db	 0Ch,0FFh, 06h, 06h, 0Ch, 0Ch
		db	 02h, 02h, 02h, 03h, 08h, 09h
		db	 04h, 04h, 10h, 10h
		db	'  $'
		db	'%01``'
		db	 03h, 03h, 06h, 06h, 08h,0FFh
		db	 08h, 08h, 04h, 04h, 0Ch,0FFh
		db	 03h, 03h, 06h, 06h, 0Ch, 0Ch
		db	 02h, 02h, 02h, 03h, 08h, 09h
		db	 04h, 04h, 10h, 10h, 30h, 30h
		db	 03h, 03h, 12h, 13h, 18h,0FFh
		db	 0Ch,0FFh, 06h, 06h, 0Ch, 0Ch
		db	 02h, 02h, 02h, 03h, 08h, 09h
		db	 04h, 04h, 10h, 10h
		db	'  $'
		db	'%01``'
		db	 06h, 06h, 0Ch, 0Ch, 02h, 02h
		db	 02h, 03h, 08h, 09h, 04h, 04h
		db	 10h, 10h, 30h, 30h, 03h, 03h
		db	 12h, 13h, 18h,0FFh, 0Ch,0FFh
		db	 06h, 06h, 0Ch, 0Ch, 02h, 02h
		db	 02h, 03h, 08h, 09h, 04h, 04h
		db	 10h, 10h, 20h, 20h, 02h, 02h
		db	 24h, 25h, 30h, 31h, 60h, 60h
		db	 0Ch,0FFh, 06h, 06h, 0Ch, 0Ch
		db	 02h, 02h, 02h, 03h, 08h, 09h
		db	 04h, 04h, 10h, 10h, 30h, 30h
		db	 03h, 03h, 12h, 13h, 18h,0FFh
		db	 0Ch,0FFh, 06h, 06h, 0Ch, 0Ch
		db	 02h, 02h, 02h, 03h, 08h, 09h
		db	 04h, 04h, 10h, 10h
		db	'  $'
		db	'%01``'
		db	 06h, 06h, 30h, 31h, 0Ch, 0Ch
		db	 18h, 18h, 30h, 30h, 24h, 24h
		db	 60h, 61h, 12h, 12h, 0Ch, 0Ch
		db	 06h, 06h, 30h, 31h, 24h, 24h
		db	 0Ch, 0Dh, 18h, 18h, 00h, 01h
		db	 0Ch, 01h, 00h, 01h, 06h, 01h
		db	 30h, 01h, 24h, 01h, 04h, 23h
		db	 00h,0C8h, 00h, 30h, 02h, 01h
		db	 03h,0A6h, 03h,0AEh, 04h, 1Eh
		db	 06h,0F9h, 06h, 0Ah, 08h, 39h
		db	 05h, 29h, 0Ah, 74h, 0Ah,0A9h
		db	 09h,0EBh, 0Ah, 0Ch,0B0h, 01h
		db	 05h, 01h, 01h,0F0h, 00h,0E0h
		db	 7Dh, 00h,0F0h, 00h, 80h,0E5h
		db	 0Fh,0D4h, 1Ah, 1Bh,0E4h, 12h
		db	 13h, 12h,0E3h, 1Bh,0F5h, 10h
		db	0F0h, 00h,0E5h, 0Fh, 2Ah,0E4h
		db	 32h, 33h, 45h, 56h, 68h, 76h
		db	 75h,0F8h, 03h, 62h, 00h,0F8h
		db	 01h, 82h, 00h,0F0h, 01h, 03h
		db	 12h, 13h, 25h, 30h,0E3h, 1Ah
		db	 1Bh,0E4h, 11h, 13h, 11h,0E3h
		db	 1Ah,0FAh, 00h,0FBh, 38h, 00h
		db	0F0h, 01h, 46h, 58h, 6Ah, 68h
		db	 6Ah, 6Bh, 7Ah,0E7h,0F0h, 02h
		db	 0Ah, 10h, 20h, 80h,0D4h,0E5h
		db	 07h, 3Ah, 3Bh,0E4h, 32h, 33h
		db	 32h,0E3h, 3Bh,0FAh, 00h,0FBh
		db	 38h, 00h,0F0h, 02h, 46h, 58h
		db	 6Ah, 68h, 6Ah, 6Bh, 7Ah,0E7h
		db	0F0h, 03h, 0Ah, 1Ah, 19h, 18h
		db	 17h, 16h, 15h, 14h, 13h, 81h
		db	0E5h, 17h,0F5h, 08h,0F0h, 03h
		db	0D5h
		db	'#5FUVeAFE&8JXZxHFEC'
		db	0F0h, 04h, 01h,0E3h, 1Ch,0E4h
		db	 13h,0F7h,0C1h, 00h, 01h, 02h
		db	0FBh, 9Ch, 00h,0F0h, 04h,0E3h
		db	 2Ah,0FBh, 28h, 00h,0F0h, 00h
		db	 84h,0E5h, 07h,0D5h,0F0h, 01h
		db	 11h, 11h, 31h, 31h, 31h,0E3h
		db	0F0h, 03h, 48h, 50h, 53h, 41h
		db	 50h,0E3h, 55h, 51h, 51h, 51h
		db	 51h,0F0h, 04h
		db	'01101AAZPVVP'
		db	0E4h,0E4h, 51h, 51h, 51h, 80h
		db	0F5h, 10h,0F0h, 04h, 60h,0E5h
		db	 0Fh,0D4h, 5Ah, 5Bh,0E4h, 52h
		db	 53h, 52h,0E3h, 5Bh, 6Ah,0E5h
		db	 17h, 5Ah, 5Bh,0E4h, 52h, 53h
		db	 52h,0E3h, 5Bh, 6Ah,0E5h, 1Fh
		db	0E4h, 62h, 63h, 65h, 60h,0E5h
		db	 1Fh, 62h, 63h, 65h,0E5h, 0Fh
		db	 71h,0F0h, 05h, 03h, 11h,0E3h
		db	 1Ch,0F8h, 03h, 3Bh, 01h,0F8h
		db	 01h, 98h, 01h, 2Ah,0E4h, 38h
		db	 39h, 4Ah, 50h,0FAh, 00h,0FBh
		db	0F9h, 00h,0F0h, 05h,0E4h, 61h
		db	0E3h, 18h, 7Ah, 78h, 7Ah, 7Bh
		db	0F0h, 06h, 0Ah,0E7h, 1Ah, 84h
		db	0E5h, 07h,0D4h, 28h, 28h, 38h
		db	0E3h, 31h, 30h,0E4h, 28h, 28h
		db	 38h,0E3h, 31h, 30h,0E4h, 38h
		db	 30h, 31h,0E4h, 31h,0E3h, 30h
		db	 31h, 31h, 30h, 40h,0E3h, 4Ch
		db	0E4h, 41h, 40h,0E3h, 4Ch, 53h
		db	 53h,0E4h,0E4h, 51h, 51h,0E3h
		db	 58h, 58h, 53h, 53h,0E3h, 5Ah
		db	 5Ah, 53h, 53h, 40h,0E4h,0E4h
		db	'1`!!`!!`1'
		db	0E3h, 36h, 36h, 31h, 31h,0E3h
		db	 3Ah, 3Ah, 80h,0FAh, 00h,0FBh
		db	0F9h, 00h,0F0h, 06h,0E4h, 71h
		db	0E3h,0F0h, 07h, 08h, 1Ah, 18h
		db	 1Ah, 1Bh, 2Ah,0E7h, 3Ah, 48h
		db	 48h, 4Ah, 4Ah,0E4h
		db	'BBCCFFHHJJ'
		db	0E4h, 42h, 42h,0F5h, 08h,0F0h
		db	 07h, 82h,0D4h,0E5h, 2Fh,0F5h
		db	 15h,0F0h, 07h, 46h, 4Ah,0E4h
		db	 43h,0E3h,0C0h,0F6h,0C3h, 41h
		db	0E5h, 2Fh, 46h,0F5h, 11h,0F0h
		db	 07h, 4Ah,0E4h, 43h, 46h, 40h
		db	0E3h,0C0h,0F6h,0D3h, 41h,0E5h
		db	 2Fh,0F5h, 15h,0F0h, 07h, 48h
		db	 4Ch,0E4h, 45h,0E3h,0C0h,0F6h
		db	0E3h, 41h,0E5h, 2Fh, 48h,0F5h
		db	 11h,0F0h, 07h, 4Ch,0E4h, 45h
		db	 48h, 40h,0E3h,0C0h,0F6h,0F3h
		db	41h
		db	8 dup (55h)
		db	8 dup (53h)
		db	0F7h,0C8h, 00h
		db	'UUUUUUUUJEDELEDE'
		db	0E4h, 41h,0E3h, 45h, 43h, 4Ah
		db	0E4h, 41h, 43h, 45h, 46h,0FBh
		db	0BBh, 01h,0F0h, 00h, 83h,0E5h
		db	 07h,0D2h, 3Ah,0E4h, 35h, 36h
		db	 15h,0E3h, 3Ah,0E4h, 35h, 15h
		db	 36h, 35h,0E3h, 3Ah,0E4h, 35h
		db	 36h, 15h,0E3h, 3Ah,0E4h, 35h
		db	 15h, 36h, 35h,0F5h, 09h,0F0h
		db	 00h,0F5h, 08h,0F0h, 00h,0D2h
		db	 3Ah,0E4h, 35h, 36h, 15h,0E3h
		db	 3Ah,0E4h, 35h, 15h, 36h, 35h
		db	0E3h, 3Ah,0E4h, 35h, 36h, 15h
		db	0E3h, 3Ah,0E4h, 35h, 15h, 36h
		db	 35h,0D3h, 31h,0E3h,0F0h, 07h
		db	 68h,0E4h, 61h,0E3h, 5Bh, 66h
		db	 6Bh, 5Ah,0E4h, 55h, 56h, 45h
		db	0E3h, 5Ah,0E4h, 55h, 45h, 56h
		db	 55h,0F6h, 55h, 02h,0F7h,0A6h
		db	 42h,0F5h, 10h,0F0h, 07h,0D2h
		db	 5Ah,0E4h, 55h, 56h, 45h,0E3h
		db	 5Ah,0E4h, 55h, 45h, 56h, 55h
		db	0F6h, 91h, 02h,0FBh, 51h, 02h
loc_30:
                           lock	pop	es
		rcr	byte ptr [bp+si-1Ch],cl	; Rotate thru carry
		push	bp
		push	si
		inc	bp
;*		jcxz	loc_33			;*Jump if cx=0
		db	0E3h, 5Ah		;  Fixup - byte match
		in	al,55h			; port 55h ??I/O Non-standard
		inc	bp
		push	si
		push	bp
		rcr	byte ptr [bp+si-1Ch],cl	; Rotate thru carry
		push	bp
		push	si
		inc	bp
		jcxz	$+5Ch			; Jump if cx=0
		in	al,55h			; port 55h ??I/O Non-standard
		inc	bp
		push	si
		push	bp
		cmc				; Complement carry
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		pop	es
;*		sal	byte ptr [bp-10h],cl	; Shift w/zeros fill
		db	0D2h, 76h,0F0h		;  Fixup - byte match
		or	[bp+di],al
		sbb	[bx+si],bl
		sbb	[bx+si],ch
		sub	bh,[bp+si]
		cmp	al,[bp-1Ch]
;*		add	bx,sp
		db	 01h,0E3h		;  Fixup - byte match
		sbb	[bx+si],bl
		sbb	[bx+si],ch
		or	al,1Ah
		sbb	bl,[bp+si]
loc_31:
		sbb	bl,[bp+si]
		sbb	bl,[bp+si]
		sbb	bl,[bx+di]
		sbb	[bx+di],bx
		sbb	[bx+di],bx
		sbb	[bx+di],bx
;*		sbb	di,si
		db	 19h,0F7h		;  Fixup - byte match
		xor	[bp+si],al
		sbb	bl,[bp+si]
		sbb	bl,[bp+si]
		sbb	bl,[bp+si]
		sbb	bl,[bp+si]
		sbb	bl,[bp+si]
		sbb	bl,[bp+si]
		sbb	bl,[bp+si]
		sbb	bl,[bp+si]
		sti				; Enable interrupts
		les	ax,dword ptr [bp+si]	; Load seg:offset ptr
;*                         lock	add	cl,ah
		db	0F0h, 00h,0E1h		;  Fixup - byte match
		add	al,0
                           lock	add	byte ptr ds:[17E5h][bx+si],al
;*		aam	1Ah			; undocumented inst
		db	0D4h, 1Ah		;  Fixup - byte match
		sbb	sp,sp
		adc	dl,[bp+di]
		adc	ah,bl
		sbb	si,bp
;*		adc	al,dh
		db	 10h,0F0h		;  Fixup - byte match
;*		add	ch,ah
		db	 00h,0E5h		;  Fixup - byte match
		pop	ss
		sub	ah,ah
		xor	dh,[bp+di]
		inc	bp
		push	si
		db	 68h, 76h, 75h,0F8h, 03h, 40h
		db	 03h,0F8h, 01h, 60h, 03h,0F0h
		db	 01h, 03h, 12h, 13h, 25h, 30h
		db	0E3h, 1Ah, 1Bh,0E4h, 11h, 13h
		db	 11h,0E3h, 1Ah,0FAh, 00h,0FBh
		db	 16h, 03h,0F0h, 01h, 46h, 58h
		db	 6Ah, 68h, 6Ah, 6Bh, 7Ah,0E7h
		db	0F0h, 02h, 0Ah, 10h, 20h, 80h
		db	0D4h,0E5h, 0Fh, 3Ah, 3Bh,0E4h
		db	 32h, 33h, 32h,0E3h, 3Bh,0FAh
		db	 00h,0FBh, 16h, 03h,0F0h, 02h
		db	 46h, 58h, 6Ah, 68h, 6Ah, 6Bh
		db	 7Ah,0E7h,0F0h, 03h, 0Ah, 1Ah
		db	 19h, 18h, 17h, 16h, 15h, 14h
		db	 13h, 81h,0E5h, 1Fh,0F5h, 08h
		db	0F0h, 03h,0D5h
		db	'#5FUVeAFE&8JXZxHFEC'
		db	0F0h, 04h, 01h,0E3h, 1Ch,0E4h
		db	 13h,0F7h, 9Fh, 03h, 01h, 02h
		db	0FBh, 7Ah, 03h,0F0h, 04h,0E3h
		db	 2Ah,0FBh, 06h, 03h,0F0h, 00h
		db	0E1h,0FCh, 40h,0F0h, 00h, 40h
		db	 80h,0F5h, 10h,0F0h, 00h, 30h
		db	0E5h, 17h,0D4h, 1Ah, 1Bh,0E4h
		db	 12h, 13h, 12h,0E3h, 1Bh, 3Ah
		db	0E5h, 1Fh, 1Ah, 1Bh,0E4h, 12h
		db	 13h, 12h,0E3h, 1Bh, 3Ah,0E5h
		db	 27h,0E4h, 32h, 33h, 35h, 30h
		db	0E5h, 27h, 32h, 33h, 35h,0E5h
		db	 17h, 51h, 63h, 71h,0E3h, 7Ch
		db	0F8h, 03h,0F5h, 03h,0F8h, 01h
		db	 0Fh, 04h,0F0h, 01h, 0Ah,0E4h
		db	 18h, 19h, 2Ah,0F0h, 03h, 30h
		db	0FAh, 00h,0FBh,0B1h, 03h,0F0h
		db	 03h,0E4h,0F0h, 05h, 61h,0E3h
		db	 18h, 7Ah, 78h, 7Ah, 7Bh,0F0h
		db	 06h, 0Ah,0E7h, 1Ah,0F0h, 08h
		db	 50h, 60h,0FAh, 00h,0FBh,0B1h
		db	 03h,0F0h, 08h,0E4h, 71h,0E3h
		db	0F0h, 09h, 08h, 1Ah, 18h, 1Ah
		db	 1Bh, 2Ah,0E7h, 3Ah, 48h, 48h
		db	 4Ah, 4Ah,0E4h
		db	'BBCCFFHHJJ'
		db	0E4h, 42h, 42h, 50h,0F5h, 08h
		db	0F0h, 09h, 82h,0D4h,0E5h, 37h
		db	0F5h, 15h,0F0h, 09h, 46h, 4Ah
		db	0E4h, 43h,0E3h,0C0h,0F6h, 3Bh
		db	 44h,0E5h, 37h, 46h,0F5h, 11h
		db	0F0h, 09h, 4Ah,0E4h, 43h, 46h
		db	 40h,0E3h,0C0h,0F6h, 4Bh, 44h
		db	0E5h, 37h,0F5h, 15h,0F0h, 09h
		db	 48h, 4Ch,0E4h, 45h,0E3h,0C0h
		db	0F6h, 5Bh, 44h,0E5h, 37h, 48h
		db	0F5h, 11h,0F0h, 09h, 4Ch,0E4h
		db	 45h, 48h, 40h,0E3h,0C0h,0F6h
		db	 6Bh, 44h
		db	8 dup (65h)
		db	8 dup (63h)
		db	0F7h,0A8h, 04h, 65h
		db	7 dup (65h)
		db	'JEDELEDE'
		db	0E4h, 41h,0E3h, 45h, 43h, 4Ah
		db	0E4h, 41h, 43h, 45h, 46h,0FBh
		db	 33h, 04h,0F0h, 09h, 70h,0FBh
		db	0ABh, 03h,0F0h, 00h, 84h,0E5h
		db	 17h,0D5h,0F0h, 02h, 10h,0F0h
		db	 03h
		db	30h
		db	'10101010101010101010101010101010'
		db	'101'
		db	0F0h
		db	8, 'P` !'
		db	' ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !'
		db	' ! ! 1111'
		db	0F0h, 0Ah, 00h, 01h, 00h, 01h
		db	 00h, 01h, 00h, 01h, 10h, 11h
		db	 10h, 11h, 10h, 11h, 10h, 11h
		db	 10h, 11h, 10h, 11h, 10h, 11h
		db	 10h, 11h, 00h, 01h, 00h, 01h
		db	 00h, 01h, 00h, 01h, 10h, 11h
		db	 10h, 11h, 10h, 11h, 10h, 11h
		db	0FBh,0AEh, 04h,0F0h, 00h,0D0h
		db	 00h,0CDh, 00h,0CFh, 02h,0CEh
		db	 07h,0D1h, 0Ah,0C1h, 28h, 03h
		db	 28h, 03h, 08h, 08h, 08h, 28h
		db	 12h, 08h, 28h, 12h
		db	8, 8, 8, 8, 8, ' ', 8, '(', 8, '('
		db	 10h, 28h, 08h, 28h, 04h, 28h
		db	 04h
		db	'(', 0Ch, 8, '(', 0Ch, 8, 8, 8
		db	0C3h,0F5h, 24h,0F0h, 00h, 11h
		db	 01h, 09h, 01h, 11h, 01h, 09h
		db	 01h,0F6h, 6Eh, 05h,0C1h, 28h
		db	 03h, 28h, 03h, 08h, 28h, 0Ch
		db	 28h, 03h, 28h, 03h
		db	8, '(', 0Ch, '(', 0Ch, 8, '(', 0Ch
		db	8, '(', 0Ch, ' ', 8, '(', 8, '('
		db	 10h, 28h, 08h, 28h, 04h, 28h
		db	 04h, 28h, 04h, 28h, 04h, 28h
		db	 04h, 28h, 04h, 28h, 04h, 28h
		db	 04h, 28h, 04h, 28h, 04h, 28h
		db	 04h, 28h, 04h, 20h, 08h, 28h
		db	 12h, 28h, 03h, 28h, 03h, 20h
		db	 0Ch, 28h, 03h, 28h, 03h
		db	' ', 0Ch, 8, 8, 8, 8, 8, 8, 8
		db	0C3h,0F5h, 24h,0F0h, 00h, 11h
		db	 01h, 09h, 01h, 11h, 01h, 09h
		db	 01h,0F6h,0CCh, 05h, 11h, 01h
		db	 09h, 01h, 11h, 01h, 28h, 06h
		db	 28h, 06h, 28h, 06h, 28h, 06h
		db	0F5h, 08h,0F0h, 00h,0F5h, 11h
		db	0F0h, 00h, 31h, 18h, 21h, 18h
		db	 29h, 18h, 21h, 18h,0F6h,0EDh
		db	 45h,0F5h, 09h,0F0h, 00h, 11h
		db	 01h, 09h, 01h, 11h, 01h, 09h
		db	 01h,0F6h,0FCh, 45h,0F7h, 39h
		db	 05h,0F5h, 09h,0F0h, 00h, 11h
		db	 01h, 09h, 01h, 11h, 01h, 09h
		db	 01h,0F6h, 0Eh, 46h,0FBh,0E9h
		db	 05h,0F0h, 00h,0E0h, 7Dh,0E5h
		db	 2Fh,0E1h, 20h,0F0h, 04h,0DBh
		db	0FCh, 4Dh, 09h,0D1h, 80h, 6Ah
		db	0E4h, 65h, 66h, 81h, 55h,0E3h
		db	 80h, 6Ah, 50h,0E1h, 00h,0F0h
		db	 04h,0F0h, 05h,0DFh, 82h,0D3h
		db	0E5h, 17h,0F0h, 06h, 3Ah, 3Bh
		db	0E4h, 32h, 33h, 32h,0E3h, 3Bh
		db	0F5h, 10h,0F0h, 06h,0E5h, 17h
		db	0F0h, 0Ah, 2Ah,0E4h, 32h, 33h
		db	 45h, 56h, 68h, 76h, 75h,0F8h
		db	 03h, 7Bh, 06h,0F8h, 01h,0B3h
		db	 06h, 03h,0F0h, 0Bh, 02h, 03h
		db	 15h, 20h,0E3h, 0Ah, 0Bh,0E4h
		db	 01h, 03h, 01h,0E3h, 0Ah,0FAh
		db	 00h,0FBh, 4Fh, 06h,0F0h, 0Bh
		db	 36h, 48h, 5Ah, 58h, 5Ah, 5Bh
		db	 6Ah,0E7h, 7Ah,0E5h, 2Fh,0E1h
		db	 20h,0F0h, 0Ch,0D8h,0FCh, 4Dh
		db	 09h,0FCh, 4Dh, 09h,0D1h, 80h
		db	 1Ah,0E4h, 15h, 16h, 81h, 25h
		db	0E3h, 80h, 1Ah, 20h,0E1h, 00h
		db	0DBh, 82h,0D3h,0E5h, 0Fh, 2Ah
		db	 2Bh,0E4h, 22h, 23h, 22h,0E3h
		db	 2Bh,0FAh, 00h,0FBh, 4Fh, 06h
		db	0F0h
		db	0Ch, 'FX:8:;j'
		db	0E7h, 7Ah,0F0h, 0Dh, 0Ah, 09h
		db	 08h, 07h, 06h, 05h, 04h, 03h
		db	 83h,0E5h, 07h,0F5h, 08h,0F0h
		db	 0Dh,0D5h, 13h
		db	'%6EFU165'
		db	16h
		db	'(:HJh8653q'
		db	0E3h, 5Ch,0E4h, 53h,0F7h,0F0h
		db	 06h, 71h, 72h,0FBh,0CDh, 06h
		db	0F0h, 0Dh,0E3h,0F0h, 0Eh, 0Ah
		db	0FBh, 3Ah, 06h,0F0h, 00h,0E5h
		db	 1Fh,0F0h, 04h,0DBh,0FCh, 4Dh
		db	 09h,0FCh, 4Dh, 09h, 82h,0F5h
		db	 10h,0F0h, 04h, 60h,0E5h, 1Fh
		db	0D3h, 5Ah, 5Bh,0E4h, 52h, 53h
		db	 52h,0E3h, 5Bh, 6Ah,0E5h, 27h
		db	 5Ah, 5Bh,0E4h, 52h, 53h, 52h
		db	0E3h, 5Bh, 6Ah,0E5h, 2Fh,0E4h
		db	 62h, 63h, 65h, 60h,0E5h, 2Fh
		db	 62h, 63h, 65h,0E5h, 17h, 71h
		db	0F0h, 05h, 03h, 11h,0E3h, 1Ch
		db	0F8h, 03h, 4Bh, 07h,0F8h, 01h
		db	 70h, 07h, 2Ah,0E4h, 38h, 39h
		db	 4Ah, 50h,0FAh, 00h,0FBh, 09h
		db	 07h,0F0h, 05h,0E4h, 61h,0E3h
		db	 18h, 7Ah, 78h, 7Ah, 7Bh,0F0h
		db	 06h, 0Ah,0E7h, 1Ah,0E5h, 1Fh
		db	0DCh,0F5h, 0Dh,0F0h, 06h,0FCh
		db	 4Dh, 09h,0F6h, 5Fh, 47h,0F0h
		db	 07h,0D9h, 82h,0FAh, 00h,0FBh
		db	 09h, 07h,0F0h, 07h,0E4h,0F0h
		db	 08h, 71h,0E3h,0F0h, 09h, 08h
		db	 1Ah, 18h, 1Ah, 1Bh, 2Ah,0E7h
		db	 3Ah, 48h, 48h, 4Ah, 4Ah,0E4h
		db	'BBCCFFHHJJ'
		db	0E4h, 42h, 42h,0F5h, 08h,0F0h
		db	 09h, 84h,0D4h,0E5h, 3Fh,0F5h
		db	 15h,0F0h, 09h, 46h, 4Ah,0E4h
		db	 43h,0E3h,0C1h,0F6h, 9Dh, 47h
		db	0E5h, 3Fh, 46h,0F5h, 11h,0F0h
		db	 09h, 4Ah,0E4h, 43h, 46h, 40h
		db	0E3h,0C1h,0F6h,0ADh, 47h,0E5h
		db	 3Fh,0F5h, 15h,0F0h, 09h, 48h
		db	 4Ch,0E4h, 45h,0E3h,0C1h,0F6h
		db	0BDh, 47h,0E5h, 3Fh, 48h,0F5h
		db	 11h,0F0h, 09h, 4Ch,0E4h, 45h
		db	 48h, 40h,0E3h,0C1h,0F6h,0CDh
		db	47h
		db	8 dup (65h)
		db	8 dup (63h)
		db	0F7h,0F9h, 06h
		db	8 dup (65h)
		db	'JEDELEDE'
		db	0E4h, 41h,0E3h, 45h, 43h, 4Ah
		db	0E4h, 41h, 43h, 45h, 46h,0FBh
		db	 95h, 07h,0F0h, 00h, 85h,0E5h
		db	 07h,0D5h,0F0h, 01h,0DEh, 11h
		db	 11h,0F0h, 04h,0DFh, 51h, 51h
		db	 51h,0E3h,0DCh, 68h, 50h,0DFh
		db	 53h,0DCh, 61h, 50h,0DFh,0E3h
		db	'UQQQQ01101'
		db	0F0h, 05h,0DFh,0F0h, 06h, 51h
		db	 51h,0F0h, 0Ah,0DDh,0F0h, 0Bh
		db	 2Ah, 20h, 26h, 26h, 20h,0E4h
		db	0E4h, 21h, 21h, 21h,0F5h, 08h
		db	0F0h, 0Bh,0FCh, 63h, 09h,0FCh
		db	 63h, 09h,0FCh, 7Ch, 09h,0F6h
		db	 48h, 08h,0FCh, 4Dh, 09h, 85h
		db	0D4h,0E5h, 07h,0DDh, 08h, 08h
		db	0F0h, 0Eh,0D9h, 28h,0E3h, 21h
		db	 20h,0E4h,0DBh, 48h, 48h,0D9h
		db	 28h,0E3h, 21h, 20h,0E4h, 28h
		db	 20h, 21h,0E4h, 21h, 20h,0E3h
		db	 21h, 21h, 20h,0D9h, 50h,0E3h
		db	 5Ch,0E4h, 51h, 50h,0E3h, 5Ch
		db	0DBh, 63h, 63h,0E4h,0E4h, 61h
		db	 61h,0E3h, 68h, 68h, 63h, 63h
		db	0E3h, 6Ah, 6Ah, 63h, 63h, 50h
		db	0DEh,0E4h,0E4h, 21h, 70h,0DBh
		db	 41h, 41h, 70h, 41h, 41h, 70h
		db	0D9h, 21h,0E3h, 26h, 26h, 21h
		db	 21h,0E3h, 2Ah, 2Ah,0F5h, 08h
		db	0F0h, 0Eh,0FCh, 63h, 09h,0FCh
		db	 63h, 09h,0FCh, 7Ch, 09h,0F6h
		db	0AEh, 08h,0FCh, 4Dh, 09h,0D1h
		db	 80h, 7Ah,0E4h, 75h, 76h, 81h
		db	 25h,0E3h, 80h, 7Ah,0E4h, 75h
		db	 81h, 25h, 80h, 76h, 81h, 25h
		db	 25h,0DDh,0E5h, 0Fh,0F5h, 08h
		db	0F0h, 0Eh,0D1h, 80h,0F0h, 0Fh
		db	 06h,0C1h, 86h, 18h,0CEh, 80h
		db	 23h, 18h, 18h, 18h, 18h,0C1h
		db	 86h, 18h,0CEh, 80h, 3Ah, 81h
		db	 4Ah, 4Ah, 80h,0D1h, 06h,0C1h
		db	 86h, 18h,0CEh, 80h,0E4h, 21h
		db	0E3h, 18h, 18h, 18h, 18h,0C1h
		db	 86h, 18h,0CEh, 80h, 2Ch, 1Ah
		db	 1Ah,0C1h, 86h, 18h,0CEh, 80h
		db	 1Ah, 1Ah, 1Ah,0C1h, 86h, 18h
		db	0CEh, 80h, 1Ah, 19h, 19h,0C1h
		db	 86h, 18h,0CEh, 80h, 19h, 19h
		db	 19h,0C1h, 86h, 18h,0CEh, 80h
		db	 19h,0F7h, 0Ah, 08h, 1Ah, 1Ah
		db	0C1h, 86h, 18h,0CEh, 80h, 1Ah
		db	 1Ah, 1Ah,0C1h, 86h, 18h,0CEh
		db	 80h, 1Ah, 1Ah, 1Ah,0C1h, 86h
		db	 18h,0CEh, 80h, 1Ah, 1Ah, 1Ah
		db	0C1h, 86h, 18h,0CEh, 80h, 1Ah
		db	0FBh,0D8h, 08h,0F0h, 0Fh,0DDh
		db	0D1h, 80h, 1Ah,0E4h, 15h, 16h
		db	 81h, 45h,0E3h, 80h, 1Ah,0E4h
		db	 15h, 81h, 45h, 80h, 16h, 15h
		db	0FEh,0F0h, 0Fh,0DDh,0D1h, 80h
		db	 1Ah, 86h, 18h,0E4h, 80h, 16h
		db	 81h, 45h,0E3h, 80h, 1Ah,0E4h
		db	 15h, 81h, 45h, 86h, 18h, 80h
		db	 15h,0FEh,0F0h, 0Fh,0DDh,0D2h
		db	 80h, 11h,0E3h, 18h,0E4h,0DEh
		db	 86h, 48h,0DCh, 80h, 71h,0DDh
		db	0E3h, 1Bh, 16h,0DEh, 86h, 48h
		db	0DCh, 80h, 7Bh,0DDh, 1Ah,0E4h
		db	 15h, 86h, 18h, 81h, 45h, 80h
		db	0E3h, 1Ah,0E4h, 15h, 81h, 45h
		db	 86h, 18h, 80h, 15h,0FEh, 9Ch
		db	 06h, 48h, 0Ch, 60h, 02h, 0Eh
		db	 10h, 30h, 03h, 42h, 06h, 20h
		db	 10h, 01h, 5Ch, 60h,0C0h, 3Ch
		db	 06h, 20h, 10h, 01h, 5Ch,0A8h
		db	 03h, 3Ch, 18h, 0Ch, 06h, 30h
		db	 24h, 60h, 30h, 9Ch, 08h, 04h
		db	 06h, 0Ch, 02h, 0Eh, 10h, 30h
		db	 03h, 42h, 18h, 20h, 01h, 5Ch
		db	 60h, 03h, 06h, 08h, 04h, 0Ch
		db	 20h, 10h, 01h, 5Ch, 60h, 06h
		db	 0Ch, 12h, 3Ch, 24h, 0Ch, 18h
		db	 06h, 3Ch,0C0h, 60h, 20h, 10h
		db	 01h, 5Ch, 60h, 06h, 03h, 0Ch
		db	 5Dh, 30h, 18h, 48h, 0Ch, 60h
		db	 02h, 0Eh, 10h, 03h, 42h, 06h
		db	 20h, 10h, 01h, 5Ch, 60h, 08h
		db	 0Ch, 06h, 01h, 20h, 10h, 5Ch
		db	0A8h, 03h, 3Ch, 18h, 0Ch, 06h
		db	 30h, 24h, 60h, 9Ch, 02h, 06h
		db	 01h, 03h, 08h, 04h, 0Ch, 30h
		db	 0Ch, 24h, 18h, 06h, 08h, 02h
		db	 12h, 20h, 18h, 18h, 06h, 06h
		db	 01h, 71h, 61h, 1Dh, 00h, 80h
		db	 81h, 84h, 07h, 0Eh, 08h, 0Fh
		db	 0Fh, 05h, 05h, 01h,0E4h, 21h
		db	 52h, 00h,0F3h,0C3h, 54h, 54h
		db	 08h, 00h, 00h, 00h, 02h, 02h
		db	 01h, 23h, 21h, 1Ch, 00h,0F3h
		db	0F3h, 38h, 38h, 08h, 00h, 00h
		db	 00h, 02h, 02h, 01h,0E0h, 21h
		db	 8Eh, 00h,0F4h,0F5h, 32h, 36h
		db	 08h, 01h,0FFh,0FFh, 02h,0FFh
		db	 81h, 14h, 00h, 00h, 00h,0F0h
		db	0F4h, 06h, 2Ah, 0Fh, 00h, 00h
		db	 00h, 02h, 02h, 81h, 01h, 02h
		db	0D0h, 01h, 07h, 99h, 01h,0FFh
		db	 38h, 00h, 05h, 00h, 00h, 00h
		db	 02h, 02h, 81h, 00h, 01h, 07h
		db	 7Ch, 07h, 99h, 01h, 0Dh, 38h
		db	 00h, 05h, 0Eh, 15h, 15h, 05h
		db	 05h, 01h, 00h, 01h, 03h, 17h
		db	 09h, 5Fh, 11h, 0Fh, 38h, 00h
		db	 05h, 0Eh, 43h, 43h, 04h, 04h
		db	 81h, 00h, 01h, 1Fh, 02h, 09h
		db	 6Eh, 31h, 1Fh, 38h, 00h, 04h
		db	 00h, 00h, 00h, 02h, 02h, 81h
		db	 00h, 01h, 17h, 03h, 05h, 6Eh
		db	 32h, 1Fh, 38h, 00h, 04h, 01h
		db	0FFh, 00h, 71h, 70h, 01h, 01h
		db	 02h,0AAh, 01h, 03h, 5Fh, 11h
		db	0FDh, 00h, 0Ah, 05h, 00h,0FFh
		db	 00h, 71h, 70h, 01h, 01h, 02h
		db	0B4h, 01h, 07h, 5Fh, 01h,0FEh
		db	 87h, 00h, 04h

_390UNKN	endp

seg_a		ends



		end	start
