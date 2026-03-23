
PAGE  59,132

;==========================================================================
;
;  BOSS_BEHAVIORS - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_18e	equ	68Eh			;*
data_19e	equ	2000h			;*
data_20e	equ	2002h			;*
data_21e	equ	2008h			;*
data_22e	equ	2010h			;*
data_23e	equ	2012h			;*
data_24e	equ	2016h			;*
data_25e	equ	2018h			;*
data_26e	equ	2040h			;*
data_27e	equ	2044h			;*
data_28e	equ	3016h			;*
data_29e	equ	6004h			;*
data_30e	equ	0A080h			;*
data_31e	equ	0A1CFh			;*
data_32e	equ	0A505h			;*
data_33e	equ	0FF1Ah			;*
data_34e	equ	0FF2Ch			;*
data_35e	equ	0FF4Ch			;*
data_36e	equ	0FF4Eh			;*
data_37e	equ	0FF4Fh			;*
data_38e	equ	0FF50h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_16		proc	far

start:
		adc	[di],al
		add	[bx+si],al
		add	al,0A0h
		das				; Decimal adjust
		mov	ds:data_18e,al
		sub	al,0FFh
		mov	di,8000h
		mov	si,0A2E1h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_34e
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:data_27e
		pop	ds
		mov	byte ptr ds:data_36e,0
		mov	byte ptr ds:data_37e,0
		call	word ptr cs:data_20e
		call	word ptr cs:data_23e
		mov	si,0A2EBh
		call	word ptr cs:data_22e
		call	boss_func_1
		mov	word ptr ds:data_35e,0A2F6h
loc_1:
		call	word ptr cs:data_29e
		cmp	al,0FFh
		je	loc_2			; Jump if equal
		call	boss_func_2
		jmp	short loc_1
loc_2:
		jmp	word ptr cs:data_26e

zr2_16		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

boss_func_1		proc	near
loc_3:
		call	boss_process_loop
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_19e
		mov	byte ptr ds:data_32e,0FFh
		retn
boss_func_1		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

boss_func_2		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:data_30e[bx]	;*
boss_func_2		endp

		db	8Ah
data_1		db	0A0h
data_2		dw	0A0BEh
		db	 14h,0A1h, 2Ah,0A1h, 5Fh,0A1h
		db	 8Ah, 1Eh
data_3		dw	0C006h
		db	0FEh,0CBh, 32h,0FFh, 03h,0DBh
		db	 8Bh, 97h,0D1h,0A2h, 89h
data_4		db	16h
		db	 06h,0A5h, 8Bh,0C2h, 32h,0D2h
		db	0BFh, 08h,0A5h, 2Eh,0FFh, 16h
		db	 06h
data_5		db	60h
		db	 8Bh, 36h, 4Ch,0FFh, 56h,0C7h
data_6		dw	4C06h
data_7		db	0FFh
		db	 08h,0A5h, 2Eh,0FFh, 16h, 04h
		db	 60h, 5Eh, 89h, 36h, 4Ch,0FFh
		db	0C3h,0BBh, 2Bh, 2Fh,0B9h, 19h
		db	 0Ch,0B0h,0FFh, 2Eh,0FFh, 16h
		db	 00h, 20h,0C7h, 06h, 54h,0FFh
		db	 2Eh, 30h, 2Eh,0FFh, 16h, 08h
		db	 60h, 9Ch,0BBh, 2Bh, 2Fh,0B9h
		db	 19h, 0Ch, 32h,0C0h, 2Eh,0FFh
		db	 16h, 00h, 20h, 9Dh,0C7h, 06h
		db	 4Ch,0FFh,0BDh,0A3h, 73h, 01h
		db	0C3h,0A1h, 06h,0A5h, 32h,0D2h
		db	 2Eh,0FFh, 16h, 0Ah, 60h,0C7h
		db	 06h, 4Ch,0FFh, 1Ah,0A4h, 73h
		db	 01h,0C3h
loc_4:
		mov	data_1,dl
		mov	data_2,ax
		call	word ptr cs:data_24e
		mov	word ptr ds:data_35e,0A483h
		retn
		db	0C6h, 06h
data_8		dw	0A505h
		db	 00h, 32h,0C0h
loc_5:
		push	ax
		call	boss_multiply
		call	boss_func_4
		pop	ax
		inc	al
		cmp	al,4
		jne	loc_5			; Jump if not equal
		retn
			                        ;* No entry point to code
		call	boss_func_3
		call	word ptr cs:data_26e
		call	boss_func_3
		call	boss_func_3
		mov	ax,data_6
		mov	data_3,ax
		call	word ptr cs:data_21e
		push	cs
		pop	es
		mov	si,offset data_7
		mov	di,offset data_5
		mov	cx,7
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		test	data_4,0FFh
		jz	loc_6			; Jump if zero
		call	word ptr cs:data_25e
loc_6:
		jmp	loc_3

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

boss_func_3		proc	near
		mov	byte ptr ds:data_33e,0
loc_7:
		call	boss_scan_loop
		cmp	byte ptr ds:data_33e,96h
		jb	loc_7			; Jump if below
		retn
boss_func_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

boss_func_4		proc	near
		mov	byte ptr ds:data_33e,0
loc_8:
		call	boss_scan_loop
		cmp	byte ptr ds:data_33e,32h	; '2'
		jb	loc_8			; Jump if below
		retn
boss_func_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

boss_multiply		proc	near
		mov	cl,14h
		mul	cl			; ax = reg * al
		add	ax,0A281h
		mov	si,ax
		mov	bx,827h
		mov	cx,4

locloop_9:
		push	cx
		mov	cx,5

locloop_10:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_28e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_10		; Loop if cx > 0

		sub	bh,5
		add	bl,8
		pop	cx
		loop	locloop_9		; Loop if cx > 0

		retn
boss_multiply		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

boss_process_loop		proc	near
		mov	si,data_31e
		mov	bx,717h
		mov	cx,8

locloop_11:
		push	cx
		mov	cx,0Ch

locloop_12:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_28e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_12		; Loop if cx > 0

		sub	bh,0Ch
		add	bl,8
		pop	cx
		loop	locloop_11		; Loop if cx > 0

		retn
boss_process_loop		endp

		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h
		db	 12h, 13h, 14h, 15h, 16h, 17h
		db	 18h, 19h, 1Ah, 1Bh, 10h, 1Ch
		db	 1Dh, 1Eh, 1Fh, 20h, 21h, 22h
		db	 23h, 24h, 25h, 26h, 10h
		db	27h
		db	'()*+,-./0123456789:;<=>?@ABCDEFG'
		db	'HIJKLMNOPQRSTUVWXYZ[\]'

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

boss_scan_loop		proc	near
		test	byte ptr ds:data_32e,0FFh
		jnz	loc_13			; Jump if not zero
		retn
loc_13:
		cmp	word ptr ds:data_38e,28h
		jae	loc_14			; Jump if above or =
		retn
loc_14:
		mov	word ptr ds:data_38e,0
		call	word ptr cs:data_8
		and	al,1
		add	al,al
		add	al,al
		xor	ah,ah			; Zero register
		add	ax,0A279h
		mov	si,ax
		mov	bx,827h
		mov	cx,2

locloop_15:
		push	cx
		mov	cx,2

locloop_16:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_28e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_16		; Loop if cx > 0

		sub	bh,2
		add	bl,8
		pop	cx
		loop	locloop_15		; Loop if cx > 0

		retn
boss_scan_loop		endp

			                        ;* No entry point to code
		sbb	[bp+si],bx
		and	al,25h			; '%'
		pop	si
		pop	di
		and	al,60h			; '`'
		sbb	[bp+si],bx
		sbb	dx,[bx+si]
		sbb	al,24h			; '$'
		and	ax,1026h
		daa				; Decimal adjust
		das				; Decimal adjust
		xor	[bx+di],dh
		xor	dh,[bp+di]
		cmp	di,[si]
		cmp	ax,3F3Eh
		sbb	[bp+si],bx
		sbb	dx,[bx+si]
		sbb	al,24h			; '$'
		and	ax,1026h
		daa				; Decimal adjust
		das				; Decimal adjust
		xor	[bx+di],dh
		xor	dh,[bp+di]
		cmp	di,[si]
		cmp	ax,3F3Eh
		sbb	[bp+si],bx
		sbb	dx,[bx+si]
		sbb	al,24h			; '$'
		db	 61h, 62h, 10h
		db	27h, '/cd23;ef>?'
		db	 19h, 1Ah, 1Bh, 10h, 1Ch
		db	'$'
		db	'%&gh/ijkl;mno?'
		db	 00h, 00h, 1Eh, 00h, 32h, 00h
		db	 46h, 00h, 64h, 00h, 96h, 00h
		db	0C8h, 00h, 90h, 01h, 01h, 19h
		db	 49h, 4Eh, 4Eh, 2Eh, 47h, 52h
		db	 50h, 00h, 19h,0AFh, 00h, 07h
		db	'The Inn', 0Ch, 'Welcome, sir!/Yo'
		db	'u look like you\ve come a long w'
		db	'ay./One night of rest in my inn '
		db	'is all you need to recover your '
		db	'strength. You can have the best '
		db	'room in the house for only '
		db	0FFh, 00h
		db	'&golds. Will you stay? '
		db	0FFh, 01h, 0Ch
		db	'Oh, I\m sorry to hear that./Well'
		db	', if you should ever need a'
		db	' place to rest, do come back. '
		db	 11h,0FFh,0FFh, 0Ch
		db	'I\m sorry sir, b'
		db	'ut I can\t accommodate you witho'
		db	'ut funds./'
		db	0FFh, 04h
		db	'Please come back when you can af'
		db	'ford'
		db	 20h, 69h, 74h, 2Eh, 20h, 11h
		db	0FFh,0FFh
		db	0Ch
		db	'Thank you, sir. Enjoy your stay.'
		db	' '
		db	0FFh, 02h,0FFh, 04h,0FFh, 03h
		db	 0Ch,0FFh, 04h
		db	49h
		db	' trust you had a good night\s sl'
		db	'eep. We\ll be looking forward to'
		db	' seeing you again./'
		db	 11h,0FFh,0FFh, 00h
		db	10 dup (0)

seg_a		ends



		end	start
