
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_394UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	5FE6h			;*
data_2e		equ	60E6h			;*
data_3e		equ	0FF00h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_394UNKN	proc	far

start:
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	al,[bx+si]
;*		add	dh,bh
		db	 00h,0FEh		;  Fixup - byte match
		add	[di],cl
;*		add	bx,sp
		db	 01h,0E3h		;  Fixup - byte match
;*		add	dh,ch
		db	 00h,0EEh		;  Fixup - byte match
		add	[bx+di],al
		pop	ds
		add	[bp+si],al
		dec	si
		add	[bp+di],al
		jnp	$+2			; delay for I/O
		add	al,0ABh
		add	[di],al
		retf	600h
			                        ;* No entry point to code
		iret				; Interrupt return
		db	 00h, 07h,0D4h, 00h, 08h,0D9h
		db	 00h, 09h,0DEh, 00h,0F0h
loc_1:
;*		add	cl,ch
		db	 00h,0E9h		;  Fixup - byte match
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
;*		and	byte ptr ds:data_1e[bx+si],0E5h
		db	 82h,0A0h,0E6h, 5Fh,0E5h	;  Fixup - byte match
		js	loc_1			; Jump if sign=1
		add	[bp+si],al
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
;*		add	dl,ah
		db	 00h,0E2h		;  Fixup - byte match
		inc	ax
		add	[bx+di],al
		add	[bx+si],al
		adc	[bp+si],ah
		add	[bx+di],al
		add	[bx+si],al
		adc	[bp+si],ah
		add	[bx+di],al
		add	[bx+si],al
		adc	[bp+si],dl
		add	[bx+di],dh
		add	al,[bx+si-0Ah]
		add	[di],ch
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
		add	ds:data_1e[bx+si],ah
		in	ax,78h			; port 78h ??I/O Non-standard
		cmc				; Complement carry
		add	[bp+si],al
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
;*		add	dl,ah
		db	 00h,0E2h		;  Fixup - byte match
		inc	ax
		add	ax,[bx+di]
		add	ax,[bp+di]
		adc	sp,[si]
		add	ax,[bx+di]
		add	ax,[bp+di]
		adc	sp,[si]
		add	ax,[bx+di]
		add	ax,[bp+di]
		adc	dx,[si]
		add	si,[bx+di]
		add	al,43h			; 'C'
		test	byte ptr [bx+si],5Ah	; 'Z'
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
;*		add	cl,ah
		db	 00h,0E1h		;  Fixup - byte match
		push	ds
		inc	ax
		mov	al,ds:data_1e
		in	ax,69h			; port 69h ??I/O Non-standard
		cmc				; Complement carry
		add	[bp+si],al
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
;*		add	dl,ah
		db	 00h,0E2h		;  Fixup - byte match
		inc	ax
		add	[bx+di],al
		add	[bx+si],al
		adc	[bp+si],ah
		add	[bx+di],al
		add	[bx+si],al
		adc	[bp+si],ah
		add	[bx+di],al
		add	[bx+si],al
		adc	[bp+si],dl
		add	[bx+di],dh
		add	al,[bx+si-0Ah]
		add	ss:data_3e[bp+si],cl
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
		add	ds:data_2e[bx+si],ah
		in	ax,7Fh			; port 7Fh ??I/O Non-standard
		loop	$+42h			; Loop if cx > 0

		inc	bp
		inc	bp
		inc	bp
		push	bp
		db	 65h, 06h, 07h, 48h, 55h, 75h
		db	 06h, 07h, 09h, 07h, 06h, 0Ah
		db	 25h, 2Ah, 45h,0FFh,0F0h, 00h
		db	0E9h, 00h,0FFh,0F0h, 00h,0E9h
		db	 00h,0FFh,0F0h, 00h,0E9h, 00h
		db	0FFh,0F0h, 00h,0E9h, 00h,0FFh
		db	0F0h, 00h,0E9h, 00h,0FFh, 4Ch
		db	 80h
		db	'NHJ067<92'
		db	 06h, 06h, 18h, 18h, 30h, 30h
		db	 0Ch,0FFh
		db	'``01$$'
		db	0Ch, 0Ch
		db	 04h, 23h, 00h, 2Eh, 00h, 54h
		db	 00h, 5Dh, 00h, 69h, 00h, 75h
		db	 00h, 81h, 00h,0AAh, 00h,0B7h
		db	 00h,0D3h, 00h,0DCh, 00h,0EBh
		db	 00h,0D4h, 00h, 0Dh, 01h, 0Ch
		db	0B0h, 01h, 05h, 01h, 01h,0F0h
		db	 00h,0E0h, 7Dh, 80h,0E5h, 0Fh
		db	0D5h,0FBh, 8Ah, 00h,0F0h, 00h
		db	 80h,0E5h, 0Fh,0D5h,0F0h, 00h
		db	0F5h, 08h,0F0h, 00h, 01h, 00h
		db	 01h, 01h, 11h, 23h, 01h, 00h
		db	 01h, 01h, 11h, 23h, 01h, 00h
		db	 01h, 01h, 11h, 13h, 01h, 30h
		db	 03h, 41h,0F6h, 38h, 00h,0FFh
		db	0F0h, 00h, 80h,0E5h, 0Fh,0D3h
		db	0FBh,0BDh, 00h,0F0h, 00h, 80h
		db	0E5h, 17h,0D5h, 00h,0E1h, 02h
		db	0FBh, 8Ah, 00h,0F0h, 00h, 80h
		db	0E5h, 17h,0D5h, 00h,0E1h, 02h
		db	0FBh, 34h, 00h,0F0h, 00h, 80h
		db	0E5h, 17h,0D3h, 00h,0E1h, 02h
		db	0FBh,0BDh, 00h,0F0h, 00h,0E0h
		db	 7Dh, 80h,0E5h, 0Fh,0D4h,0DDh
		db	0F0h, 00h,0F5h, 08h,0F0h, 00h
		db	 05h, 00h, 05h, 05h, 15h, 27h
		db	 05h, 00h, 05h, 05h, 15h, 27h
		db	 05h, 00h, 05h, 05h, 15h, 17h
		db	 05h, 30h, 07h, 45h,0F6h, 8Eh
		db	 00h,0FFh,0F0h, 00h, 80h,0E5h
		db	 17h,0D4h,0DDh,0E1h, 20h, 00h
		db	0FBh, 8Ah, 00h,0F0h, 00h, 81h
		db	0E5h, 0Fh,0D2h,0F0h, 00h, 41h
		db	 41h, 41h, 61h, 07h, 08h,0E4h
		db	 41h,0E3h, 71h, 07h, 08h, 0Ah
		db	 08h, 07h, 03h, 21h, 23h, 41h
		db	0FFh,0FFh, 06h, 18h, 30h, 0Ch
		db	 60h, 02h, 54h, 3Ch, 20h, 10h
		db	 10h, 07h, 07h, 01h, 51h, 41h
		db	 1Dh, 00h, 40h, 81h,0F3h,0F5h
		db	 0Eh, 0Eh, 15h, 15h, 05h, 05h
		db	 01h, 00h, 01h, 03h, 17h, 09h
		db	 5Fh, 11h, 0Fh, 38h, 00h, 02h
		db	 00h, 00h, 00h, 02h, 02h, 81h
		db	 01h, 02h,0D0h, 01h, 07h, 99h
		db	 01h,0FFh, 38h, 00h, 05h

_394UNKN	endp

seg_a		ends



		end	start
