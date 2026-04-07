
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_385UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_18e	equ	1C03h			;*
data_19e	equ	1FE5h			;*
data_20e	equ	3708h			;*
data_21e	equ	0E93Fh			;*
data_22e	equ	0F002h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_385UNKN	proc	far

start:
		and	cx,word ptr ds:[0]
		loopz	locloop_1		; Loop if zf=1, cx>0

		db	 3Eh, 07h, 41h, 06h,0B1h, 06h

locloop_1:
		add	[bx],bx
		add	[bp+si],al
		inc	dx
		add	[bp+di],ax
		inc	ax
		add	al,[si]
		and	ax,903h
		iret				; Interrupt return
			                        ;* No entry point to code
		add	ax,data_8
		pop	es
		xor	al,ds:data_20e
		push	es
		or	[si],di
		push	es
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
		db	 8Ch,0F0h, 00h,0E9h, 00h,0A0h
		db	0E5h, 69h,0E6h, 5Ch,0E2h, 40h
		db	 00h, 11h, 12h, 23h, 33h, 24h
		db	0E6h, 26h, 45h, 44h,0E6h, 5Ch
		db	 06h, 13h, 17h, 28h, 38h, 24h
		db	0E6h, 26h, 45h, 54h, 64h,0E6h
		db	 5Ch, 16h, 16h, 76h, 79h,0F0h
		db	 01h, 08h, 13h, 07h, 08h, 09h
		db	 2Ah, 29h, 08h, 36h, 06h,0E5h
		db	 6Eh, 9Ah,0E6h, 0Bh, 06h, 02h
		db	 01h, 02h, 01h, 0Bh, 00h, 0Ch
		db	 02h, 01h, 0Bh,0E6h, 5Ch,0E5h
		db	 69h,0A0h, 26h, 29h, 08h, 13h
		db	 07h, 08h, 09h, 2Ah, 29h, 08h
		db	0E5h, 6Eh,0A4h,0E6h, 0Bh, 07h
		db	 09h, 08h, 09h, 07h, 06h, 01h
		db	 0Bh
		db	'LML@KM@KBMKBFB'
		db	0A0h,0E5h, 69h,0E6h
		db	'\NGIDNGYi'
		db	0E6h, 31h, 98h,0E5h, 6Eh, 4Dh
		db	 4Dh, 04h
		db	'MM$'
		db	'MMMMMM'
		db	0B0h,0E6h, 0Bh
		db	'@NFBCNFB'
		db	 98h,0E6h, 31h, 4Dh, 4Dh, 24h
		db	0E5h, 69h,0A0h,0E6h
		db	'\NGIDNGYiOOOOOJIHIHG'
		db	0E9h, 01h, 40h, 41h, 40h, 42h
		db	 43h,0A8h,0E5h, 6Eh,0E6h, 0Bh
		db	'BDDDEDDDFDCDB@'
		db	0E5h, 69h,0A0h,0E6h, 5Ch, 41h
		db	 40h, 01h, 01h, 27h, 01h, 01h
		db	 27h, 01h, 01h, 27h, 01h, 01h
		db	27h, 'GFHC)FHCB B@AJ+@JLK-'
		db	 01h, 01h, 27h, 01h, 01h, 27h
		db	 01h, 01h, 27h, 01h, 01h
		db	27h, 'GFHC)FHCB B@AJ+KNMKNMMM'
		db	0FBh, 25h, 00h,0FFh,0F0h, 01h
		db	0E9h, 01h,0F0h, 01h,0E9h, 01h
		db	0F5h, 01h, 02h,0F0h, 01h,0E9h
		db	 01h,0E1h, 00h, 40h,0A4h,0E5h
		db	 64h,0E6h, 5Ch,0E2h, 40h, 17h
		db	 42h, 4Fh, 39h, 79h,0B0h,0E1h
		db	 50h, 40h,0E5h, 64h,0E6h, 3Bh
		db	0F0h, 02h, 06h,0E9h, 02h, 00h
		db	 01h, 02h, 03h, 04h, 00h, 03h
		db	 04h, 00h, 03h, 04h, 01h, 02h
		db	 00h, 01h, 02h, 00h, 01h, 02h
		db	0F6h, 01h, 4Dh, 01h,0F5h, 01h
		db	 02h,0F0h, 02h,0E9h, 02h, 05h
		db	 03h, 00h, 05h, 03h, 00h, 05h
		db	 03h, 06h, 02h, 00h, 06h, 02h
		db	 00h, 06h, 02h, 03h, 04h, 00h
		db	 03h, 04h, 00h, 03h, 04h, 06h
		db	 02h, 00h, 06h, 02h, 00h, 06h
		db	 02h,0F6h, 01h, 87h, 01h, 07h
		db	 08h, 09h, 0Ah, 05h, 06h, 07h
		db	 08h, 09h, 0Ah, 05h, 06h, 07h
		db	 08h, 09h, 0Ah, 0Bh, 08h, 0Ah
		db	 05h, 03h, 04h, 0Bh, 08h, 0Ah
		db	 05h, 03h, 04h, 0Bh, 08h, 0Ah
		db	 05h, 07h, 08h, 09h, 0Ah, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 08h
		db	 09h, 0Ch, 0Dh, 06h, 05h, 08h
		db	 09h, 0Ch, 0Dh, 06h, 05h, 08h
		db	 09h, 0Ch, 0Dh,0E1h, 00h

locloop_2:
		inc	ax
		movsb				; Mov [si] to es:[di]
		in	ax,64h			; port 64h, keyboard status
		out	5Ch,al			; port 5Ch ??I/O Non-standard
		adc	al,14h
		and	[si],dl
		adc	al,20h			; ' '
		adc	al,14h
		and	[si],dl
		adc	al,20h			; ' '
		xor	ds:data_21e,bh
		add	si,[bx+si]
		and	[bp+si],si
		xor	si,[bx+si]
		xor	al,25h			; '%'
		xor	al,35h			; '5'
		db	'67(5798*'
		db	 16h, 16h, 2Bh, 16h, 16h, 2Bh
		db	 16h, 16h, 2Bh, 16h, 16h
		db	'+;230!2304%4567(8<:8<:::'
		db	0FBh, 46h, 01h,0FFh,0F0h, 02h
		db	0E9h, 03h,0F0h, 02h,0E9h, 03h
		db	0A0h,0E5h, 6Eh,0E6h, 3Bh,0F5h
		db	 01h, 04h,0F0h, 02h,0E9h, 03h
		db	0E2h, 40h, 09h, 06h, 0Bh, 09h
		db	 06h, 0Bh, 09h, 06h, 0Ch, 07h
		db	 0Bh, 0Ch, 07h, 0Bh, 0Ch, 07h
		db	0F6h, 01h, 50h, 02h,0F5h, 01h
		db	 02h,0F0h, 02h,0E9h, 03h, 0Ah
		db	 09h, 0Bh, 0Ah, 09h, 0Bh, 0Ah
		db	 09h, 08h, 07h, 0Bh, 08h, 07h
		db	 0Bh, 08h, 07h, 09h, 06h, 0Bh
		db	 09h, 06h, 0Bh, 09h, 06h, 08h
		db	 07h, 0Bh, 08h, 07h, 0Bh, 08h
		db	 07h,0F6h, 01h, 6Dh, 02h, 0Dh
		db	 0Eh, 0Fh,0E9h, 04h, 00h, 01h
		db	 02h, 03h, 04h, 05h, 00h, 01h
		db	 02h, 03h, 04h, 05h, 00h, 06h
		db	 04h, 00h, 01h, 07h, 08h, 06h
		db	 04h, 00h, 01h, 07h, 08h, 06h
		db	 04h, 00h, 01h, 03h, 04h, 05h
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 00h, 04h, 05h, 09h, 0Ah, 02h
		db	 01h, 04h, 05h, 09h, 0Ah, 02h
		db	 01h, 04h, 05h, 09h, 0Ah, 9Ch
		db	0E5h, 64h,0E6h, 5Ch, 18h, 18h
		db	 2Bh, 18h, 18h, 2Bh, 18h, 18h
		db	 2Bh, 18h, 18h
		db	'+;<=>/<=>'
		db	0E9h, 05h
		db	'0!0123$'
		db	'1354&'
		db	 12h, 12h, 27h, 12h, 12h, 27h
		db	 12h, 12h, 27h, 12h, 12h
		db	27h, '789:+89:0!0123$'
		db	'4<64<666'
		db	0FBh, 44h, 02h,0FFh,0F0h, 02h
		db	0E9h, 05h,0A0h,0E5h, 78h,0E6h
		db	 6Ah,0F0h, 02h,0E9h, 05h,0F5h
		db	 01h, 10h,0F0h, 02h,0E9h, 05h
		db	0E2h
		db	40h
		db	8 dup (0Dh)
		db	0F6h, 01h, 35h, 03h,0F5h, 01h
		db	 02h,0F0h, 02h,0E9h, 05h, 0Eh
		db	 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh
		db	 0Eh,0F6h, 01h, 4Ah, 03h,0F5h
		db	 01h, 02h,0F0h, 02h,0E9h, 05h
		db	 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 0Fh, 0Fh,0F6h, 01h, 5Dh, 03h
		db	0F5h, 01h, 02h,0F0h, 02h,0E9h
		db	 05h, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh
		db	 0Eh, 0Eh, 0Eh,0F6h, 01h, 70h
		db	 03h,0E9h, 06h
		db	8 dup (0)
		db	8 dup (1)
		db	 02h, 02h, 22h, 10h, 10h, 20h
		db	 13h, 13h, 23h, 14h, 14h, 24h
		db	 12h, 12h, 22h, 10h, 10h, 20h
		db	 15h, 11h, 16h, 14h, 07h, 13h
		db	 18h, 14h, 12h, 12h, 22h, 10h
		db	 10h, 20h, 13h, 13h, 23h, 14h
		db	 14h, 24h, 31h, 31h, 11h
		db	8 dup (11h)
		db	 19h, 19h, 10h, 10h, 33h, 38h
		db	 34h, 30h,0FBh, 2Eh, 03h,0FFh
		db	0F0h, 02h,0E9h, 06h,0F0h, 02h
		db	0E9h, 06h,0F5h, 01h, 02h,0F0h
		db	 02h,0E9h, 06h,0E5h, 7Fh,0E7h
		db	 0Ah,0E2h, 4Eh, 44h,0E2h, 5Ch
		db	 44h,0E2h, 6Ah, 49h,0E2h, 5Ch
		db	 5Ah,0E2h, 4Eh, 54h, 44h,0E2h
		db	 6Ah, 50h,0E2h, 4Eh, 54h, 44h
		db	0E2h, 6Ah, 59h,0E2h, 4Eh, 54h
		db	 44h,0E2h, 6Ah, 50h,0E2h, 4Eh
		db	 44h,0E2h, 6Ah, 59h,0E2h, 4Eh
		db	 54h, 44h,0E2h, 6Ah, 59h,0E2h
		db	 4Eh, 44h,0E2h, 6Ah, 50h,0E2h
		db	 4Eh, 44h,0E2h, 6Ah, 59h,0E2h
		db	 4Eh, 44h,0E2h, 6Ah, 59h,0E2h
		db	 4Eh, 54h, 44h,0E2h, 6Ah, 50h
		db	0E2h, 5Ch, 5Bh,0E5h, 7Fh,0E7h
		db	 0Ah,0E2h, 4Eh, 44h,0E2h, 5Ch
		db	 44h,0E2h, 6Ah, 59h,0E2h, 4Eh
		db	 54h, 44h,0E2h, 6Ah, 50h,0E2h
		db	 4Eh, 54h, 44h,0E2h, 6Ah, 59h
		db	0E2h, 4Eh, 54h, 44h,0E2h, 6Ah
		db	 50h,0E2h, 4Eh, 44h,0E2h, 6Ah
		db	 59h,0E2h, 4Eh, 54h, 44h,0E2h
		db	 6Ah, 59h,0E2h, 4Eh, 44h,0E2h
		db	 6Ah, 50h,0E2h, 4Eh, 44h,0E2h
		db	 6Ah, 59h, 60h, 60h, 50h, 5Ch
		db	 5Dh,0F6h, 01h,0DAh, 03h,0F5h
		db	 01h, 02h,0F0h, 02h,0E9h, 06h
		db	0E2h, 5Ch, 4Ah,0E2h, 4Eh, 44h
		db	0E2h, 6Ah, 59h,0E2h, 4Eh, 54h
		db	 44h,0E2h, 6Ah, 50h,0E2h
		db	4Eh

locloop_3:
		push	sp
		inc	sp
;*		loop	locloop_27		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		pop	cx
;*		loop	locloop_21		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match

locloop_4:
		push	sp

locloop_5:
		inc	sp
;*		loop	locloop_29		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		push	ax
;*		loop	locloop_22		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match

locloop_6:
		inc	sp
;*		loop	locloop_30		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		pop	cx
;*		loop	locloop_24		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	sp

locloop_7:
		inc	sp
;*		loop	locloop_31		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		pop	cx

locloop_8:
		loop	locloop_26		; Loop if cx > 0


locloop_9:
		inc	sp
		loop	locloop_32		; Loop if cx > 0

		push	ax
		loop	locloop_28		; Loop if cx > 0

		inc	sp

locloop_11:
		loop	locloop_34		; Loop if cx > 0

		pop	cx
;*		loop	locloop_29		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match

locloop_12:
		inc	sp

locloop_13:
		loop	locloop_36		; Loop if cx > 0

		pop	cx
;*		loop	locloop_30		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	sp

locloop_14:
		inc	sp
		loop	locloop_38		; Loop if cx > 0

		push	ax
;*		loop	locloop_31		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match

locloop_15:
		push	sp
		inc	sp
		loop	locloop_40		; Loop if cx > 0

		pop	cx
;*		loop	locloop_33		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match

locloop_16:
		push	sp
		inc	sp
;*		loop	locloop_42		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		push	ax
;*		loop	locloop_35		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	sp
		inc	sp
		loop	locloop_44		; Loop if cx > 0

		pop	cx

locloop_18:
		loop	locloop_37		; Loop if cx > 0

		push	sp
		inc	sp
		loop	locloop_46		; Loop if cx > 0

		push	ax

locloop_20:
		loop	locloop_39		; Loop if cx > 0

		inc	sp
;*		loop	locloop_47		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		pop	cx
		loop	locloop_41		; Loop if cx > 0

		push	sp
		inc	sp
;*		loop	locloop_48		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		pop	cx
		loop	locloop_43		; Loop if cx > 0

		inc	sp
		loop	locloop_50		; Loop if cx > 0


locloop_23:
		push	ax
		loop	locloop_45		; Loop if cx > 0

		inc	sp
		loop	locloop_52		; Loop if cx > 0

		pop	cx

locloop_25:
		loop	locloop_46		; Loop if cx > 0


locloop_26:
		inc	sp
		loop	locloop_55		; Loop if cx > 0

		pop	cx
;*		loop	locloop_47		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match

locloop_28:
		push	sp
		inc	sp
		loop	locloop_57		; Loop if cx > 0

		push	ax
;*		loop	locloop_53		;*Loop if cx > 0

		db	0E2h, 5Ch		;  Fixup - byte match
		pop	bx
;*		loop	locloop_49		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		inc	sp
		loop	locloop_59		; Loop if cx > 0

		pop	cx
		loop	locloop_51		; Loop if cx > 0

		push	sp
		inc	sp
		loop	locloop_61		; Loop if cx > 0

		push	ax
		loop	locloop_54		; Loop if cx > 0

		push	sp
		inc	sp

locloop_32:
;*		loop	locloop_63		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		pop	cx
;*		loop	locloop_56		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	sp

locloop_34:
		inc	sp
		loop	$+6Ch			; Loop if cx > 0

		push	ax
;*		loop	locloop_58		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match

locloop_36:
		inc	sp
;*		loop	locloop_64		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match

locloop_37:
		pop	cx
;*		loop	locloop_60		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	sp

locloop_38:
		inc	sp
		loop	$+6Ch			; Loop if cx > 0


locloop_39:
		pop	cx
		loop	locloop_62		; Loop if cx > 0

		inc	sp

locloop_40:
		loop	$+6Ch			; Loop if cx > 0


locloop_41:
		push	ax
		loop	$+50h			; Loop if cx > 0

		inc	sp
		loop	locloop_66		; Loop if cx > 0

		pop	cx

locloop_43:
		loop	$+50h			; Loop if cx > 0

		inc	sp
;*		loop	locloop_68		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match

locloop_44:
		pop	cx

locloop_45:
;*		loop	locloop_64		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	sp
		inc	sp
		loop	$+6Ch			; Loop if cx > 0


locloop_46:
		push	ax
		loop	$+50h			; Loop if cx > 0

		push	sp
		inc	sp
;*		loop	locloop_70		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		pop	cx
;*		loop	locloop_65		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	sp
		inc	sp
		loop	locloop_73		; Loop if cx > 0

		push	ax
;*		loop	locloop_67		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	sp
		inc	sp

locloop_50:
		loop	$+6Ch			; Loop if cx > 0

		pop	cx

locloop_51:
		loop	$+50h			; Loop if cx > 0

		push	sp

locloop_52:
		inc	sp
		loop	$+6Ch			; Loop if cx > 0

		push	ax

locloop_54:
		loop	locloop_69		; Loop if cx > 0


locloop_55:
		inc	sp
		loop	$+6Ch			; Loop if cx > 0

		pop	cx
		loop	locloop_71		; Loop if cx > 0

		push	sp

locloop_57:
		inc	sp
		loop	$+6Ch			; Loop if cx > 0

		pop	cx
		loop	$+50h			; Loop if cx > 0

		inc	sp
		loop	$+6Ch			; Loop if cx > 0

		push	ax
		loop	$+50h			; Loop if cx > 0

		inc	sp
		loop	locloop_75		; Loop if cx > 0

		pop	cx

locloop_61:
		loop	$+50h			; Loop if cx > 0


locloop_62:
		inc	sp
		loop	locloop_76		; Loop if cx > 0

		pop	cx
		loop	$+50h			; Loop if cx > 0

		push	sp
		loop	$+6Ch			; Loop if cx > 0

		db	 60h, 60h, 5Dh,0F6h, 01h, 73h
		db	 04h,0F5h, 01h

locloop_64:
		add	si,ax
		add	ch,cl
		push	es
		db	 60h, 60h, 60h, 60h, 49h,0E2h
		db	 4Eh, 7Ah,0E2h

locloop_65:
		db	 6Ah, 60h, 60h, 60h, 60h

locloop_66:
		dec	cx
		loop	$+50h			; Loop if cx > 0

		jp	locloop_65		; Jump if parity=1
		add	word ptr ss:[0E205h][bp+di],cx
		db	 6Ah, 60h, 60h, 60h, 60h, 49h
		db	0E2h

locloop_69:
		dec	si
		jp	loc_72			; Jump if parity=1
		loop	$+6Ch			; Loop if cx > 0

		dec	cx

locloop_71:
		push	ax
		dec	cx
		push	ax
		dec	cx
loc_72:
		pop	bp

locloop_73:
		cmc				; Complement carry
		add	[bp+si],ax
                           lock	add	ch,cl
		push	es
		db	 60h, 60h, 60h, 60h, 49h,0E2h
		db	 4Eh, 7Ah,0E2h, 6Ah, 60h, 60h
		db	 60h, 60h, 49h,0E2h, 4Eh, 7Ah
		db	0F6h, 01h
		db	0BBh, 05h,0E2h, 6Ah, 49h,0E2h
		db	 4Eh, 6Eh,0E2h
		db	 6Ah, 69h, 59h

locloop_75:
		inc	ax
		loop	locloop_77		; Loop if cx > 0

		pop	di
;*		loop	locloop_79		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match

locloop_76:
		pop	cx
		dec	cx
;*		loop	locloop_78		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		pop	si
;*		loop	locloop_80		;*Loop if cx > 0

		db	0E2h, 6Ah		;  Fixup - byte match
		pop	cx
		inc	ax
		loop	$+50h			; Loop if cx > 0

		pop	di
		loop	$+6Ch			; Loop if cx > 0

		pop	cx
		inc	ax
		loop	$+50h			; Loop if cx > 0

		db	 64h,0E2h, 6Ah, 40h,0E2h, 4Eh
		db	 64h,0E2h, 6Ah, 49h,0E2h, 5Ch
		db	 5Bh,0E2h, 6Ah, 40h,0E2h, 4Eh
		db	 64h,0E2h, 6Ah, 40h,0E2h, 4Eh
		db	 64h,0E2h, 6Ah, 49h,0E2h, 5Ch
		db	 5Bh,0E2h, 6Ah, 40h,0E2h, 4Eh
		db	 64h,0E2h, 6Ah, 40h,0E2h
data_7		db	4Eh
		db	 64h,0E2h, 6Ah, 59h
data_8		dw	636Ch
		db	 6Dh, 69h,0FBh,0D3h, 03h,0FFh
		db	0F0h, 02h,0E9h

locloop_77:
		push	es
;*		push	ax
		db	0FFh,0F0h		;  Fixup - byte match
		add	ch,cl
		push	es
;*		push	ax
		db	0FFh,0F0h		;  Fixup - byte match
		add	ch,cl
		push	es
;*		push	ax
		db	0FFh,0F0h		;  Fixup - byte match
		add	ch,cl
		push	es
		inc	word ptr [bx+si+43h]
		inc	bp
		dec	dx
		adc	byte ptr [bp+47h],4Ch	; 'L'
		db	'NOQB?;HSKLGE;?B@CJNQOSRH4FBC@GEQ'
		db	'ONJSLK679>67;?@BECG4FQONJ'
		db	'GEQONS'
		db	'C@LK4679>;?@BECG4679>F($'
		db	'#&#(-*'
		db	 1Ch, 27h, 80h
		db	'+$'
		db	'".0)!1$'
		db	'"'
		db	 06h, 05h, 30h, 31h, 30h, 2Eh
		db	 60h, 5Fh, 48h,0FFh, 0Ch,0FFh
		db	 18h, 17h, 0Ch, 0Bh, 24h, 22h
		db	 18h, 17h, 30h, 31h, 06h, 05h
		db	'HI`_0.', 0Ch, 0Ah, 0Ch
		db	 0Bh, 18h, 17h, 06h, 05h, 00h
		db	 01h, 0Ch, 01h, 06h, 01h, 18h
		db	 01h, 04h, 23h, 00h,0FFh, 00h
		db	 2Fh, 01h,0CAh, 01h, 11h, 02h
		db	 1Ah, 02h,0BBh, 02h,0F8h, 03h
		db	0D0h, 04h, 25h, 02h, 4Bh, 06h
		db	0A5h
data_11		dw	3606h			; Data table (indexed access)
		db	 06h, 3Eh, 07h, 0Ch,0B0h, 01h
		db	 05h, 01h, 01h,0F0h, 00h,0E0h
		db	 73h,0E5h, 17h,0F0h, 00h, 80h
		db	0D4h, 05h, 1Ch,0E4h, 11h, 23h
		db	 30h, 81h, 23h, 20h, 80h,0D4h
		db	 05h, 1Ch,0E4h, 11h, 23h, 30h
		db	 81h, 23h, 40h, 80h,0D4h, 1Ch
		db	 1Ch,0F5h, 08h,0F0h, 00h, 80h
		db	0D4h, 5Ch,0E4h, 58h, 67h, 03h
		db	 65h, 67h, 68h, 5Ah, 58h, 67h
		db	0F7h, 6Ch, 00h,0E3h, 7Ch, 82h
		db	0C3h
		db	'ljhjhgedjhg'
		db	0CCh,0FBh, 47h, 00h,0F0h, 00h
		db	 82h,0C3h, 65h, 68h, 67h, 68h
		db	 65h,0E3h, 6Ch, 68h, 67h, 14h
		db	0E3h, 1Ch,0E4h, 14h, 15h, 17h
		db	0E3h, 1Ch,0E4h, 15h, 17h, 1Ah
		db	0E3h, 1Ch,0E4h, 17h, 1Ah, 1Ch
		db	 1Ah,0CCh, 80h,0E4h, 11h, 15h
		db	 18h, 10h, 11h, 15h,0F0h, 01h
		db	 08h,0CFh, 83h,0D3h, 1Ch, 1Ch
		db	 20h, 1Ch, 1Ch, 30h, 1Ch, 1Ch
		db	 1Ch, 1Ch, 1Ch, 1Ch,0C0h,0C3h
		db	 82h,0D4h, 15h,0E4h, 11h,0E3h
		db	 1Ch, 1Ah,0E4h, 13h, 11h,0E3h
		db	 1Ch, 1Ah,0CCh,0CFh, 83h,0E3h
		db	 1Ch, 1Ch, 30h,0E4h,0C0h, 80h
		db	0E4h, 11h, 15h, 18h, 10h, 11h
		db	 15h, 08h, 1Ch, 1Ch, 1Ch, 1Ch
		db	 1Ch, 1Ah, 18h, 17h, 18h, 17h
		db	 15h, 14h, 15h, 14h,0E3h, 1Ch
		db	 1Ah,0C3h, 82h, 1Ch,0E3h, 1Ch
		db	 1Ch, 1Ch,0E4h, 14h,0E3h, 1Ch
		db	 1Ch, 1Ch,0E4h, 17h,0E3h, 1Ch
		db	0E4h, 1Ah,0E3h, 1Ch,0E4h, 1Ch
		db	0E4h, 14h,0CCh, 80h, 15h, 14h
		db	0FCh,0A2h, 03h, 1Ch,0FBh, 29h
		db	 00h,0F0h, 00h, 84h,0E5h, 27h
		db	0D4h,0F5h, 10h,0F0h, 00h, 68h
		db	 65h,0E3h, 65h,0E4h, 68h, 65h
		db	0E3h, 65h,0E4h, 68h, 65h, 6Bh
		db	 67h,0E3h, 65h,0E4h, 6Bh, 67h
		db	0E3h, 65h,0E4h, 6Bh, 67h,0F6h
		db	 07h, 01h,0FCh, 4Dh, 04h, 64h
		db	0FCh,0A2h, 03h, 1Ch,0FBh,0FFh
		db	 00h,0F0h, 00h, 85h,0E5h, 0Fh
		db	0F0h, 00h,0D3h,0F5h, 40h,0F0h
		db	 00h
		db	'eeeeeeee'
		db	0F6h, 39h, 01h, 61h, 61h
		db	14 dup (61h)
		db	0E3h, 6Ch
		db	15 dup (6Ch)
		db	0E4h, 61h
		db	15 dup (61h)
		db	8 dup (63h)
		db	0E3h, 6Ch
		db	7 dup (6Ch)
		db	0E4h
		db	'eeUccSjjZggWeeUccS'
		db	0E3h, 65h, 6Ch,0E4h
		db	'dg`jhgeeUccSjjZggW'
		db	0E3h, 1Ch, 1Ch, 6Ch
		db	8 dup (6Ch)
		db	0E4h, 61h, 61h, 63h, 63h, 1Ah
		db	 18h, 17h, 13h,0FBh, 34h, 01h
		db	0F0h, 00h,0F5h, 08h,0F0h, 00h
		db	 80h,0E5h, 1Fh,0D5h,0E1h, 00h
		db	 05h, 1Ch,0E4h, 11h, 23h, 84h
		db	0E5h, 2Fh,0D4h,0E1h, 02h, 60h
		db	 67h,0E3h, 65h,0E4h, 6Bh, 67h
		db	 68h, 65h,0E3h, 65h,0E4h, 68h
		db	 65h,0E3h, 65h,0E4h, 68h, 65h
		db	 6Bh, 67h,0E3h, 65h,0E4h, 6Bh
		db	 67h,0E3h, 65h,0E4h, 6Bh,0F6h
		db	0CEh, 01h, 60h,0FCh, 4Dh, 04h
		db	 80h,0D4h,0E5h, 1Fh,0FCh,0A2h
		db	 03h, 1Ch,0FBh,0CAh, 01h,0F0h
		db	 00h,0E5h, 1Fh,0E1h, 02h,0FBh
		db	 29h, 00h,0F0h

locloop_81:
		add	ds:data_19e[di],al
		loopz	locloop_81		; Loop if zf=1, cx>0

;*		adc	bl,bh
		db	 10h,0FBh		;  Fixup - byte match
		xor	al,1
;*                         lock	add	al,dl
		db	0F0h, 00h,0D0h		;  Fixup - byte match
;*		add	ch,cl
		db	 00h,0CDh		;  Fixup - byte match
;*		add	bh,cl
		db	 00h,0CFh		;  Fixup - byte match
		add	cl,dh
;*		or	cx,dx
		db	 09h,0D1h		;  Fixup - byte match
		or	dh,ch
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
;*		add	dh,al
		db	 00h,0C6h		;  Fixup - byte match
		adc	[bx+di],ax
		or	[bx+di],ax
		adc	[bx+di],ax
		or	[bx+di],dx
		add	[bx+di],dx
		or	[bx+di],dx
		adc	[bx+di],ax
		or	[bx+di],ax
		adc	[bx+di],ax
		or	[bx+di],ax
		adc	[bx+di],ax
		or	[bx+di],dx
		add	[bx+di],dx
		or	[bx+di],dx
		sub	data_7,al
		or	[si],cl
		or	al,0F6h
		xor	ax,[bp+si]
		cmc				; Complement carry
;*		and	al,dh
		db	 20h,0F0h		;  Fixup - byte match
		add	[bx+di],dl
		add	[bx+di],cx
		add	[bx+di],dx
		add	[bx+di],cx
		adc	[bx+di],ax
		adc	[bx+di],cx
		adc	[bx+di],dx
		add	[bx+di],cx
;*		add	si,si
		db	 01h,0F6h		;  Fixup - byte match
		pop	si
		add	dh,ch
;*		sbb	al,dh
		db	 18h,0F0h		;  Fixup - byte match
;*		add	cl,al
		db	 00h,0C1h		;  Fixup - byte match
		or	[bx+si],cl
		or	[bx+si],cl
		xor	bl,[bx+si]
		div	byte ptr [di+2]		; al,ah rem = ax/data
		db	0C1h, 08h, 08h, 08h, 08h, 32h
		db	 18h,0C6h, 00h, 18h, 18h, 18h
		db	0F5h, 10h,0F0h, 00h,0C1h, 08h
		db	 08h, 08h, 08h, 32h, 18h,0F6h
		db	 8Fh, 02h,0C6h, 32h, 06h, 30h
		db	 06h, 10h, 0Ah, 10h, 12h, 10h
		db	 0Ah, 10h,0C1h
		db	0Ah, 8, '0', 0Ch, 0Ah, 8, '0', 0Ch
		db	0Ah, 8, '0', 0Ch
		db	 0Eh, 0Ch, 0Ch, 0Ch,0FBh, 25h
		db	 02h,0F0h, 00h,0E0h, 73h,0F0h
		db	 00h, 80h,0E5h, 17h,0D3h, 05h
		db	 1Ch,0E4h, 11h, 23h, 30h, 81h
		db	0D7h,0E5h, 0Fh, 23h, 20h, 80h
		db	0E5h, 17h,0D3h, 05h, 1Ch,0E4h
		db	 11h, 23h, 30h, 81h,0D7h,0E5h
		db	 0Fh
		db	23h
loc_82:
		inc	ax
		and	ch,17h
		rcr	word ptr [si],cl	; Rotate thru carry
		sbb	al,0F5h
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	byte ptr ds:[5CD3h][bx+si],al
		in	al,58h			; port 58h ??I/O Non-standard
		db	 67h, 03h, 65h, 67h, 68h, 5Ah
		db	 58h, 67h,0F7h, 10h, 03h,0E3h
		db	 7Ch,0CEh,0E4h, 82h
		db	'ljhjhgedjhg'
		db	0C1h,0E3h,0FBh,0E9h, 02h,0F0h
		db	 00h,0CEh, 82h, 65h, 68h, 67h
		db	 68h, 65h,0E3h, 6Ch, 68h, 67h
		db	 14h,0E3h, 1Ch,0E4h, 14h, 15h
		db	 17h,0E3h, 1Ch,0E4h, 15h, 17h
		db	 1Ah,0E3h, 1Ch,0E4h, 17h, 1Ah
		db	 1Ch, 1Ah,0C1h, 80h,0E4h, 11h
		db	 15h, 18h, 10h, 11h, 15h,0F0h
		db	 01h, 08h, 83h,0D2h, 1Ch, 1Ch
		db	 20h, 1Ch, 1Ch, 30h, 1Ch, 1Ch
		db	 1Ch, 1Ch, 1Ch, 1Ch,0CEh, 82h
		db	0D4h, 15h,0E4h, 11h,0E3h, 1Ch
		db	 1Ah,0E4h, 13h, 11h,0E3h, 1Ch
loc_83:
		sbb	al,cl
		jcxz	loc_82			; Jump if cx=0
;*		jcxz	loc_86			;*Jump if cx=0
		db	0E3h, 1Ch		;  Fixup - byte match
		sbb	al,30h			; '0'
		and	ah,0E4h
		adc	[di],dx
		sbb	[bx+si],dl
		adc	[di],dx
		or	[si],bl
		sbb	al,1Ch
		sbb	al,1Ch
		sbb	bl,[bx+si]
		pop	ss
		sbb	[bx],dl
loc_85:
		adc	ax,1514h
		adc	al,0E3h
		sbb	al,1Ah
		into				; Int 4 on overflow
		in	al,82h			; port 82h, DMA page reg ch 3
		sbb	al,0E3h
		sbb	al,1Ch
		sbb	al,0E4h
		adc	al,0E3h
		sbb	al,1Ch
		sbb	al,0E4h
		pop	ss
;*		jcxz	loc_87			;*Jump if cx=0
		db	0E3h, 1Ch		;  Fixup - byte match
		in	al,1Ah			; port 1Ah ??I/O Non-standard
		jcxz	loc_88			; Jump if cx=0
		in	al,1Ch			; port 1Ch ??I/O Non-standard
		in	al,14h			; port 14h ??I/O Non-standard
		jcxz	loc_83			; Jump if cx=0
		adc	byte ptr [di],14h
		cld				; Clear direction
		mov	ds:data_18e,al
		sti				; Enable interrupts
		mov	di,data_22e
;*		add	bp,si
		db	 01h,0F5h		;  Fixup - byte match
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	[di],sp
		and	ax,35E3h
		in	al,25h			; port 25h ??I/O Non-standard
loc_88:
		and	ax,35E3h
		in	al,25h			; port 25h ??I/O Non-standard
		and	ax,35E3h
		in	al,25h			; port 25h ??I/O Non-standard
		and	ax,35E3h
		neg	dx
		add	dx,[di]
		pop	ss
		sbb	[bp+si],bl
		in	al,33h			; port 33h ??I/O Non-standard
		jcxz	$+19h			; Jump if cx=0
		sbb	[bp+si],bl
		sbb	al,0E4h
		xor	al,0E3h
		sbb	al,0E4h
		adc	al,15h
		pop	ss
		cmp	dl,[si]
		pop	ss
		sbb	[bp+si],bl
		cmp	al,0FBh
		cmpsb				; Cmp [si] to es:[di]
		add	si,ax
		add	[di],dx
		pop	ss
		sbb	[bp+si],bl
		in	al,33h			; port 33h ??I/O Non-standard
		jcxz	$+19h			; Jump if cx=0
		sbb	[bp+si],bl
		sbb	al,0E4h
		xor	al,0E3h
		sbb	al,0E4h
		adc	al,15h
		pop	ss
		cmp	bl,[bp+si]
		sbb	bx,[si]
		sbb	bl,[bp+di]
		sbb	al,1Ch
		db	0FEh,0F0h, 00h,0F0h, 00h,0F5h
		db	 08h,0F0h, 00h,0F0h, 01h,0DCh
		db	 80h,0E5h, 1Fh,0D3h,0E1h, 1Fh
		db	 55h, 1Ch,0E4h, 11h, 63h,0DFh
		db	 84h,0E5h, 1Fh,0E4h, 27h,0E3h
		db	 25h,0E4h, 2Ah, 27h,0E3h, 25h
		db	0E4h, 2Ah, 27h, 28h, 25h,0E3h
		db	 25h,0E4h, 28h, 25h,0E3h, 25h
		db	0E4h, 28h, 25h, 2Bh, 27h,0E3h
		db	 25h,0E4h, 2Bh, 27h,0E3h, 25h
		db	0E4h, 2Bh, 27h,0F6h,0FEh, 03h
		db	0E1h, 1Fh,0FCh, 4Dh, 04h, 24h
		db	0DCh, 80h, 10h,0D4h,0E5h, 1Fh
		db	0E1h, 1Fh,0FCh,0A2h, 03h,0FBh
		db	0FAh, 03h,0F0h, 01h,0F5h, 08h
		db	0F0h, 01h, 2Ch, 28h,0E3h, 25h
		db	0E4h, 2Ch, 28h,0E3h, 25h,0E4h
		db	 2Ch, 28h, 2Ah, 27h,0E3h, 25h
		db	0E4h, 2Ah, 27h,0E3h, 25h,0E4h
		db	 2Ah, 27h, 28h, 25h,0E3h, 25h
		db	0E4h, 28h, 25h,0E3h, 25h,0E4h
		db	 28h, 25h, 2Ah, 27h,0E3h, 25h
		db	0E4h, 2Ah, 27h,0E3h, 25h,0E4h
		db	 2Ah, 27h,0F6h, 51h, 04h,0F5h
		db	 08h,0F0h, 01h,0D5h, 2Ah, 28h
		db	 27h, 23h,0E3h, 2Ch, 2Ah,0E4h
		db	 2Ah, 28h, 27h, 23h,0E3h, 2Ch
		db	 2Ah,0E4h, 2Ah, 28h, 27h, 23h
		db	0F7h,0BAh, 04h, 2Ch, 28h, 23h
		db	0E3h, 2Ch, 28h, 25h,0E4h, 2Ch
		db	 28h, 23h,0E3h, 2Ch, 28h, 25h
		db	0E4h, 2Ch, 28h, 23h,0E3h, 2Ch
		db	0FBh, 88h, 04h,0F0h, 01h, 28h
		db	 27h, 25h, 24h,0E3h, 2Ah, 2Ch
		db	0E4h, 28h, 27h, 25h, 24h,0E3h
		db	 2Ah, 2Ch,0E4h, 28h, 27h, 25h
		db	0FEh,0F0h, 00h,0D1h,0E5h, 07h
		db	0F0h, 02h,0D8h,0F0h, 02h,0F5h
		db	 08h,0F0h, 02h, 85h, 15h, 86h
		db	 15h, 87h, 18h, 86h, 15h, 85h
		db	 15h, 15h, 87h, 18h, 85h, 15h
		db	 86h, 15h, 85h, 15h, 87h, 18h
		db	 85h, 15h, 15h, 86h, 15h, 87h
		db	 18h, 86h, 15h, 85h, 15h, 86h
		db	 15h, 87h, 18h, 86h, 15h, 85h
		db	 15h, 15h, 87h, 18h, 85h, 15h
		db	 86h, 15h, 85h, 15h, 87h, 18h
		db	 85h, 15h,0DAh, 87h, 38h, 38h
		db	0D8h, 18h, 88h,0E4h, 18h, 11h
		db	0E3h,0F6h,0DCh, 04h,0F5h, 10h
		db	0F0h, 02h, 85h, 15h, 86h, 15h
		db	 87h, 18h, 86h, 15h, 85h, 15h
		db	 15h, 87h, 18h, 85h, 15h, 86h
		db	 15h, 85h, 15h, 87h, 18h, 85h
		db	 15h, 15h, 86h, 15h, 87h, 18h
		db	 86h, 15h,0F6h, 23h, 05h,0F5h
		db	 09h,0F0h, 02h, 85h, 11h, 86h
		db	 11h, 87h, 18h, 86h, 11h, 85h
		db	 11h, 11h, 87h, 18h, 85h, 11h
		db	 86h, 11h, 85h, 11h, 87h, 18h
		db	 85h, 11h, 11h, 86h, 11h, 87h
		db	 18h, 86h, 11h,0F7h, 8Eh, 45h
		db	0E3h, 85h, 1Ch, 86h, 1Ch, 87h
		db	 18h, 86h, 1Ch, 85h, 1Ch, 1Ch
		db	 87h, 18h, 85h, 1Ch, 86h, 1Ch
		db	 85h, 1Ch, 87h, 18h, 85h, 1Ch
		db	 1Ch, 86h, 1Ch, 87h, 18h, 86h
		db	 1Ch,0E4h,0FBh, 48h, 05h,0F0h
		db	 02h, 85h, 13h, 86h, 13h, 87h
		db	 18h, 86h, 13h, 85h, 13h, 13h
		db	 87h, 18h, 85h, 13h,0E3h, 86h
		db	 1Ch, 85h, 1Ch, 87h, 18h, 85h
		db	 1Ch, 1Ch, 86h, 1Ch, 87h, 18h
		db	 86h, 1Ch,0E4h,0F5h, 08h,0F0h
		db	 02h,0DAh, 87h, 38h, 38h, 38h
		db	 38h,0D8h, 85h, 45h,0DAh, 87h
		db	 38h, 38h, 38h, 38h,0D8h, 85h
		db	 43h,0DAh, 87h, 38h, 38h, 38h
		db	 38h,0D8h, 85h, 4Ah,0DAh, 87h
		db	 38h, 38h, 38h, 38h,0D8h, 85h
		db	 47h,0F7h, 01h, 06h,0DAh, 87h
		db	 38h, 38h, 38h, 38h,0D8h, 85h
		db	 45h,0DAh, 87h, 38h, 38h, 38h
		db	 38h,0D8h, 85h, 43h,0DAh, 87h
		db	 38h, 38h,0D8h, 85h,0E3h, 1Ch
		db	0E4h, 86h, 14h, 17h, 10h, 85h
		db	 1Ah, 18h, 17h,0FBh,0B2h, 05h
		db	0F0h, 02h,0DAh, 85h,0E3h, 3Ch
		db	 3Ch, 86h, 3Ch, 30h,0D8h, 87h
		db	 18h, 86h, 1Ch, 85h, 1Ch, 1Ch
		db	 87h, 18h, 85h, 1Ch,0DAh, 87h
		db	 38h, 38h,0D8h, 85h, 1Ch,0DAh
		db	 87h, 38h, 38h,0D8h, 85h,0E4h
		db	 11h,0DAh, 87h, 38h, 38h,0D8h
		db	 85h, 13h,0DAh, 3Ah, 38h, 37h
		db	 33h,0D8h,0FBh,0D8h, 04h, 24h
		db	 06h, 60h, 30h, 54h, 18h, 0Ch
		db	 3Ch,0A8h, 06h, 0Ch, 18h, 02h
		db	 24h, 3Ch, 03h, 08h, 0Ch, 02h
		db	 06h, 18h, 20h, 0Ch, 0Ch, 07h
		db	 07h, 01h, 61h, 72h, 1Dh, 00h
		db	 64h,0FBh, 23h, 13h, 0Eh, 06h
		db	 23h, 23h, 05h, 05h, 01h, 45h
		db	 02h, 1Bh, 00h,0F4h,0F2h, 61h
		db	 62h, 0Eh, 00h, 00h, 00h, 02h
		db	 02h, 01h, 34h, 31h, 40h, 40h
		db	0F1h,0F1h, 15h, 15h, 05h, 12h
		db	 08h, 08h, 05h, 05h, 01h, 21h
		db	 22h, 12h, 00h,0F8h, 55h, 35h
		db	 36h, 0Eh, 00h, 00h, 00h, 02h
		db	 02h, 01h, 33h, 01h, 1Eh, 00h
		db	0F2h,0F3h, 23h,0F4h, 0Eh, 00h
		db	 00h, 00h, 02h, 02h, 01h,0E0h
		db	 21h, 8Eh, 00h,0F4h,0F5h, 32h
		db	 36h, 08h, 10h, 0Eh, 0Eh, 05h
		db	 05h, 01h, 00h, 01h, 09h, 06h
		db	 0Dh, 5Fh, 14h, 1Fh, 38h, 00h
		db	 03h, 01h, 54h, 54h, 05h, 05h
		db	 01h, 00h, 01h, 09h, 96h, 01h
		db	 01h,0F4h, 0Fh, 38h, 00h, 04h
		db	 00h, 0Eh, 0Eh, 07h, 07h, 01h
		db	 00h, 01h, 01h, 01h, 05h, 5Fh
		db	 61h, 0Fh, 38h, 00h, 04h, 00h
		db	 2Bh, 2Bh, 02h, 02h, 01h, 00h
		db	 01h, 05h, 17h, 03h, 5Fh, 11h
		db	 0Fh, 38h, 00h, 03h, 00h, 00h
		db	 00h, 02h, 02h, 81h, 00h, 01h
		db	 05h, 91h, 03h, 56h, 61h, 0Fh
		db	 38h, 00h, 03h, 00h, 00h, 00h
		db	 02h, 02h, 81h, 01h, 02h,0D0h
		db	 01h, 07h, 99h, 01h,0FFh, 38h
		db	 00h, 05h, 00h, 00h, 00h, 02h
		db	 02h, 81h, 00h, 01h, 01h, 01h
		db	 07h, 99h, 01h, 1Eh, 38h, 00h
		db	 05h, 00h,0FFh, 00h, 71h, 70h
		db	 01h, 01h, 02h,0B4h, 01h, 07h
		db	 5Fh, 01h,0FEh, 87h, 00h, 04h
		db	 01h,0FFh, 00h, 5Dh, 70h, 01h
		db	 01h, 02h,0B8h, 01h, 07h, 5Fh
		db	 01h,0FFh, 00h, 04h, 04h

_385UNKN	endp

seg_a		ends



		end	start
