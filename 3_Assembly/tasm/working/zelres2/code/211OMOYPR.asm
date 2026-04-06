
PAGE  59,132

;==========================================================================
;
;  OMOYPRO.BIN - Souvenir / Omoya Shop Program (zelres2 chunk_11)
;
;  Loaded at loaded_code_a (0x3000) by town.bin when player enters
;  the omoya / souvenir shop building.
;
;  Created:   28-Mar-26
;  Passes:    5          Analysis Options on: none
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_13e	equ	2002h			;*
data_14e	equ	2010h			;*
data_15e	equ	2012h			;*
data_16e	equ	2040h			;*
data_17e	equ	2044h			;*
data_18e	equ	3016h			;*
data_19e	equ	6016h			;*
data_20e	equ	0A004h			;*
data_21e	equ	0A0BBh			;*
data_22e	equ	0A129h			;*
data_23e	equ	0FF14h			;*
data_24e	equ	0FF1Dh			;*
data_25e	equ	0FF2Ch			;*
data_26e	equ	0FF50h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

omoyp		proc	far

start:
		push	bx
		add	al,[bx+si]
		add	[di],al
		mov	al,ds:data_20e
		retn
			                        ;* No entry point to code
		mov	es,ds:data_25e
		mov	di,8000h
		mov	si,0A239h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_25e
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:data_17e
		pop	ds
		call	word ptr cs:data_13e
		call	word ptr cs:data_15e
		mov	si,0A245h
		call	word ptr cs:data_14e
		call	sub_1
		test	byte ptr ds:[49h],0FFh
		jnz	$+18h			; Jump if not zero
		mov	byte ptr ds:data_24e,0
loc_1:
		call	word ptr cs:data_19e
		test	byte ptr ds:data_24e,0FFh
		jz	loc_1			; Jump if zero
		jmp	word ptr cs:data_16e
			                        ;* No entry point to code
		pop	ax
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	si,0A0ADh
		mov	di,6000h
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	ax,cs
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ds:data_23e
		add	bx,bx
		mov	si,ds:data_21e[bx]
		mov	di,3000h
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	word ptr cs:data_26e,0
		cmp	word ptr cs:data_26e,12Ch
		jb	$-7			; Jump if below
		mov	bx,0
		mov	cx,50C8h
		call	word ptr cs:[3006h]
		mov	byte ptr cs:[0FF77h],0FFh
		jmp	word ptr ds:[6000h]
			                        ;* No entry point to code
		add	[bp+di],si
		db	'enddemo.bin'
		db	 00h,0C7h,0A0h,0D3h,0A0h,0D3h
		db	0A0h,0DFh,0A0h,0EBh,0A0h,0F8h
		db	0A0h, 00h, 02h
		db	'gdega.bin'
		db	0, 0, 3
		db	'gdcga.bin'
		db	0, 0, 4
		db	'gdhgc.bin'
		db	0, 0, 6
		db	'gdmcga.bin'
		db	0, 0, 5
		db	'gdtga.bin'
		db	0

omoyp		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		mov	si,data_22e
		mov	bx,0C1Eh
		mov	cx,10h

locloop_2:
		push	cx
		mov	cx,11h

locloop_3:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_18e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_3		; Loop if cx > 0

		sub	bh,11h
		add	bl,8
		pop	cx
		loop	locloop_2		; Loop if cx > 0

		retn
sub_1		endp

		db	7 dup (0)
		db	1, 2
		db	14 dup (0)
		db	3, 4, 5, 6, 0
		db	12 dup (0)
		db	 07h, 08h, 09h, 0Ah, 00h
		db	12 dup (0)
		db	 0Bh, 0Ch, 0Dh, 0Eh, 00h
		db	12 dup (0)
		db	 0Fh, 10h, 11h, 12h, 00h
		db	12 dup (0)
		db	 13h, 14h, 15h, 16h, 00h
		db	12 dup (0)
		db	 17h, 18h, 19h, 1Ah, 00h
		db	7 dup (0)
		db	 1Bh, 1Ch, 1Dh, 1Eh, 1Fh
		db	 20h, 21h, 22h, 23h
		db	7 dup (0)
		db	'$'
		db	'%&', 27h, '()*+,-'
		db	7 dup (0)
		db	'./012345678'
		db	0, 0, 0, 0, 0, 0
		db	'9:;<=>?@ABC'
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 44h, 45h, 46h, 47h, 00h, 48h
		db	 49h, 4Ah, 4Bh, 4Ch, 4Dh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 4Eh
		db	 4Fh, 50h, 51h, 00h, 52h, 53h
		db	 54h, 55h, 56h, 57h, 58h, 00h
		db	 00h, 00h, 00h, 00h
		db	'YZ[\]^_`abcdef'
		db	0, 0, 0
		db	'ghijklmnopqrstu'
		db	0, 0
		db	'vwxyz{|}~'
		db	 7Fh, 80h, 81h, 82h, 83h, 84h
		db	 85h, 86h, 01h, 14h
		db	'OMOYA.GRP'
		db	 00h, 16h,0AFh, 02h
		db	0Ah, 'In the Hut'

seg_a		ends



		end	start
