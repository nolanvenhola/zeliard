
PAGE  59,132

;==========================================================================
;
;  ENEMY_SKELETON - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_21e	equ	2000h			;*
data_22e	equ	2002h			;*
data_23e	equ	2010h			;*
data_24e	equ	2012h			;*
data_25e	equ	2016h			;*
data_26e	equ	2040h			;*
data_27e	equ	2044h			;*
data_28e	equ	3016h			;*
data_29e	equ	6004h			;*
data_30e	equ	0A078h			;*
data_31e	equ	0A084h			;*
data_32e	equ	0A0F8h			;*
data_33e	equ	0A16Eh			;*
data_34e	equ	0A1CEh			;*
data_35e	equ	0A302h			;*
data_36e	equ	0A360h			;*
data_37e	equ	0A37Ah			;*
data_38e	equ	0A3D4h			;*
data_39e	equ	0A4A3h			;*
data_40e	equ	0A79Dh			;*
data_41e	equ	0A79Eh			;*
data_42e	equ	0A79Fh			;*
data_43e	equ	0A7A0h			;*
data_44e	equ	0A7A1h			;*
data_45e	equ	0FF1Ah			;*
data_46e	equ	0FF2Ch			;*
data_47e	equ	0FF4Ch			;*
data_48e	equ	0FF4Eh			;*
data_49e	equ	0FF4Fh			;*
data_50e	equ	0FF50h			;*
data_51e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_10		proc	far

start:
		mov	byte ptr ds:[7],al
		add	[si],al
		mov	al,ds:data_35e
		mov	es,ds:data_46e
		mov	di,8000h
		mov	si,0A40Fh
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_46e
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:data_27e
		pop	ds
		mov	byte ptr ds:data_48e,0
		mov	byte ptr ds:data_49e,0
		call	word ptr cs:data_22e
		call	word ptr cs:data_24e
		mov	si,0A41Ah
		call	word ptr cs:data_23e
		call	skel_process_loop
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_21e
		call	skel_func_7
		mov	ds:data_47e,si
loc_1:
		call	word ptr cs:data_29e
		cmp	al,0FFh
		je	loc_2			; Jump if equal
		call	skel_func_1
		jmp	short loc_1
loc_2:
		jmp	word ptr cs:data_26e

zr2_10		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

skel_func_1		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:data_30e[bx]	;*
skel_func_1		endp

			                        ;* No entry point to code
		in	al,0A0h			; port 0A0h ??I/O Non-standard
;*		call	far ptr skel_func_8		;*
		db	9Ah
		dw	0D4A0h, 92A0h		;  Fixup - byte match
		mov	al,ds:data_31e
		mov	ah,data_17[bx+si]
		popf				; Pop flags
		cmpsw				; Cmp [si] to es:[di]
;*		inc	bx
		db	0FFh,0C3h		;  Fixup - byte match
		xor	al,al			; Zero register
		mov	ds:data_40e,al
		jmp	loc_21
			                        ;* No entry point to code
		mov	al,0FFh
		mov	ds:data_43e,al
		jmp	loc_21
		db	0B9h, 0Ah, 00h

locloop_3:
		push	cx
		mov	ax,word ptr ds:[86h]
		mov	dl,byte ptr ds:[85h]
		add	ax,64h
		adc	dl,0
		mov	word ptr ds:[86h],ax
		mov	byte ptr ds:[85h],dl
		call	word ptr cs:data_25e
		mov	byte ptr ds:data_51e,13h
		mov	byte ptr ds:data_45e,0
loc_4:
		call	skel_func_5
		cmp	byte ptr ds:data_45e,0Fh
		jb	loc_4			; Jump if below
		pop	cx
		loop	locloop_3		; Loop if cx > 0

		mov	byte ptr ds:[5],0FFh
		retn
		db	0C6h, 06h, 1Ah,0FFh, 00h
loc_5:
		call	skel_func_5
		cmp	byte ptr ds:data_45e,96h
		jb	loc_5			; Jump if below
		retn
			                        ;* No entry point to code
		mov	si,data_32e
		mov	cx,0Ch

locloop_6:
		push	cx
		lodsb				; String [si] to al
		push	si
		call	skel_process_loop_2
		call	skel_func_2
		pop	si
		pop	cx
		loop	locloop_6		; Loop if cx > 0

		retn
		db	0, 0, 1, 2, 2, 1
		db	0, 3, 4, 4, 5, 6

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

skel_func_2		proc	near
		mov	byte ptr ds:data_45e,0
loc_7:
		call	skel_func_5
		cmp	byte ptr ds:data_45e,19h
		jb	loc_7			; Jump if below
		retn
skel_func_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

skel_process_loop		proc	near
		mov	si,data_33e
		mov	bx,0E17h
		mov	cx,8

locloop_8:
		push	cx
		mov	cx,0Ch

locloop_9:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_28e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_9		; Loop if cx > 0

		sub	bh,0Ch
		add	bl,8
		pop	cx
		loop	locloop_8		; Loop if cx > 0

		test	byte ptr ds:[49h],0FFh
		jnz	loc_10			; Jump if not zero
		retn
loc_10:
		mov	al,6
skel_process_loop		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

skel_process_loop_2		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_34e[bx]
		mov	bx,1117h
		mov	cx,7

locloop_11:
		push	cx
		mov	cx,6

locloop_12:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_28e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_12		; Loop if cx > 0

		sub	bh,6
		add	bl,8
		pop	cx
		loop	locloop_11		; Loop if cx > 0

		retn
skel_process_loop_2		endp

		db	 00h, 01h, 02h, 03h, 3Eh, 3Fh
		db	 40h, 41h, 18h, 19h, 1Ah, 1Bh
		db	 04h, 05h, 06h, 07h, 42h, 43h
		db	 44h, 45h, 1Ch, 1Dh, 1Eh, 1Fh
		db	8, 9, 0Ah, 'FGHIJK !"'
		db	0Bh
		db	0Ch, 0Dh, 'LMNOPQ#$'
		db	'%'
		db	 0Eh, 0Fh, 10h
		db	'RSTUVW&', 27h, '('
		db	 11h, 12h, 13h
		db	'XYZ[\)*+,'
		db	 14h, 15h, 16h, 17h
		db	']^_-./0123456789:;<='
		db	0DCh,0A1h, 06h,0A2h, 30h,0A2h
		db	 5Ah,0A2h, 84h,0A2h,0AEh,0A2h
		db	0D8h,0A2h, 03h, 3Eh, 3Fh, 40h
		db	 41h, 18h, 07h, 42h, 43h, 44h
		db	 45h, 1Ch
		db	'FGHIJKLMNOPQRSTUVWXYZ[\)'
		db	 17h, 5Dh, 5Eh, 5Fh, 2Dh, 2Eh
		db	 03h, 3Eh, 3Fh, 40h, 41h, 18h
		db	 07h, 42h, 43h, 44h, 45h, 1Ch
		db	'FGHIJKLMNOPQR`abVWXYZ[\)'
		db	 17h, 5Dh, 5Eh, 5Fh, 2Dh, 2Eh
		db	 03h, 3Eh, 3Fh, 40h, 41h, 18h
		db	 07h, 42h, 43h, 44h, 45h, 1Ch
		db	'FGHIJKLMNOPQRcdeVWXYZ[\)'
		db	 17h, 5Dh, 5Eh, 5Fh, 2Dh, 2Eh
		db	 03h, 66h, 67h, 68h, 69h, 18h
		db	 07h, 6Ah, 6Bh, 6Ch, 6Dh, 1Ch
		db	'nopqrstuvwxyz{|}~'
		db	 7Fh, 80h, 81h, 82h, 83h, 84h
		db	 29h, 17h, 85h, 86h, 87h, 2Dh
		db	 2Eh, 03h, 88h, 89h, 8Ah, 8Bh
		db	 18h, 07h, 8Ch, 8Dh, 8Eh, 8Fh
		db	 1Ch, 90h, 91h, 92h, 93h, 94h
		db	 95h, 96h,0ADh,0ABh,0AEh, 9Ah
		db	 9Bh, 9Ch, 9Dh, 9Eh, 9Fh,0A0h
		db	0A1h,0A2h,0A3h,0A4h,0A5h,0A6h
		db	 29h, 17h,0A7h,0A8h,0A9h, 2Dh
		db	 2Eh, 03h, 88h, 89h, 8Ah, 8Bh
		db	 18h, 07h, 8Ch, 8Dh, 8Eh, 8Fh
		db	 1Ch, 90h, 91h, 92h, 93h, 94h
		db	 95h, 96h,0AAh,0ABh,0ACh, 9Ah
		db	 9Bh, 9Ch, 9Dh, 9Eh, 9Fh,0A0h
		db	0A1h,0A2h,0A3h,0A4h,0A5h,0A6h
		db	 29h, 17h,0A7h,0A8h,0A9h, 2Dh
		db	 2Eh, 03h, 88h, 89h, 8Ah, 8Bh
		db	 18h, 07h, 8Ch, 8Dh, 8Eh, 8Fh
		db	 1Ch, 90h, 91h, 92h, 93h, 94h
		db	 95h, 96h, 97h, 98h, 99h, 9Ah
		db	 9Bh, 9Ch, 9Dh, 9Eh, 9Fh,0A0h
		db	0A1h,0A2h,0A3h,0A4h,0A5h,0A6h
		db	 29h, 17h,0A7h,0A8h,0A9h
		db	 2Dh, 2Eh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

skel_func_5		proc	near
		cmp	word ptr ds:data_50e,4
		jae	loc_13			; Jump if above or =
		retn
loc_13:
		mov	word ptr ds:data_50e,0
		call	skel_func_6
		jmp	short loc_18

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

skel_func_6:
		test	byte ptr ds:data_43e,0FFh
		jnz	loc_14			; Jump if not zero
		retn
loc_14:
		inc	byte ptr ds:data_44e
		cmp	byte ptr ds:data_44e,1Ah
		jb	loc_16			; Jump if below
		call	word ptr cs:[11Ah]
		or	al,al			; Zero ?
		jz	loc_15			; Jump if zero
		retn
loc_15:
		mov	byte ptr ds:data_44e,0FFh
		retn
loc_16:
		mov	bx,data_36e
		mov	al,ds:data_44e
		xlat				; al=[al+[bx]] table
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,data_37e
		mov	bx,112Fh
		mov	cx,4

locloop_17:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_28e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_17		; Loop if cx > 0

		retn
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 01h, 01h, 01h, 01h, 01h, 02h
		db	 02h, 02h, 02h, 02h, 01h, 01h
		db	 01h, 01h, 01h, 00h, 00h, 00h
		db	 00h, 00h, 96h, 97h, 98h, 99h
		db	 96h,0AAh,0ABh,0ACh, 96h,0ADh
		db	0ABh,0AEh
loc_18:
		test	byte ptr ds:data_40e,0FFh
		jnz	loc_19			; Jump if not zero
		retn
loc_19:
		inc	byte ptr ds:data_41e
		cmp	byte ptr ds:data_41e,6
		jae	loc_20			; Jump if above or =
		retn
loc_20:
		mov	byte ptr ds:data_41e,0
		inc	byte ptr ds:data_42e
		mov	al,ds:data_42e
loc_21:
		and	al,1
		mov	cl,0Ah
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_38e
		mov	bx,113Fh
		mov	cx,2

locloop_22:
		push	cx
		mov	cx,5

locloop_23:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_28e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_23		; Loop if cx > 0

		sub	bh,5
		add	bl,8
		pop	cx
		loop	locloop_22		; Loop if cx > 0

		retn
skel_func_5		endp

			                        ;* No entry point to code
		mov	ds:data_39e,al
		movsw				; Mov [si] to es:[di]
		cmpsb				; Cmp [si] to es:[di]
		pop	ss
		cmpsw				; Cmp [si] to es:[di]
		test	al,0A9h
		sub	ax,0B0AFh
		mov	cl,0B2h
		mov	bl,17h
		mov	ah,0B5h
		mov	dh,2Dh			; '-'

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

skel_func_7		proc	near
		mov	si,0A42Fh
		mov	al,byte ptr ds:[5]
		or	al,byte ptr ds:[6]
		jnz	loc_24			; Jump if not zero
		retn
loc_24:
		mov	si,0A53Ch
		test	byte ptr ds:[6],0FFh
		jnz	loc_25			; Jump if not zero
		retn
loc_25:
		mov	si,0A5D2h
		test	byte ptr ds:[49h],0FFh
		jnz	loc_26			; Jump if not zero
		retn
loc_26:
		mov	si,0A6C1h
		retn
skel_func_7		endp

			                        ;* No entry point to code
		add	[bp+di],dx
		dec	bx
		dec	cx
		dec	si
		inc	di
		db	 2Eh, 47h, 52h, 50h, 00h, 13h
		db	0AFh, 00h, 11h
		db	'King of Felishika', 0Ch
		db	0FFh, 00h,0FFh, 03h,0FFh, 04h
		db	'Brave Duke Garland, '
		db	0FFh, 05h,0FFh, 02h,0FFh, 04h
		db	'you\ll need money for your journ'
		db	'ey./I&hereby bestow upon you 100'
		db	'0&Go'
		db	 6Ch, 64h, 73h, 2Eh,0FFh, 05h
		db	0FFh, 02h,0FFh, 01h, 0Dh,0FFh
		db	 04h
		db	'Go to town and outfit yourself, '
		db	'then make haste to the labyrinth'
		db	' to defeat the forces of Jashiin'
		db	'. My kingdom and the life of my '
		db	'daughter are at stake.'
		db	0FFh, 05h, 11h,0FFh,0FFh, 0Ch
		db	0FFh, 00h,0FFh, 03h,0FFh, 04h
		db	'Brave Duke, did you forget somet'
		db	'hing?'
		db	0FFh, 05h,0FFh, 02h, 0Dh,0FFh
		db	 04h
		db	'The entrance to the labyrinth is'
		db	' at the edge of town.'
		db	0FFh, 05h, 0Dh,0FFh, 04h
		db	'Please hurry, before it\s too la'
		db	'te! '
		db	0FFh, 05h, 11h,0FFh,0FFh, 0Ch
		db	0FFh, 00h,0FFh, 03h,0FFh, 04h
		db	'Duke Garland, '
		db	0FFh, 05h,0FFh, 02h,0FFh, 04h
		db	'I am in debt to you for your eff'
		db	'orts. '
		db	0FFh, 05h,0FFh, 02h,0FFh, 04h
		db	'Have you not yet succeeded in va'
		db	'nquishing Jash'
		db	 69h, 69h, 6Eh, 3Fh, 20h,0FFh
		db	 05h,0FFh, 02h, 0Dh,0FFh, 04h
		db	'I pray that the spirits will gui'
		db	'de you. Please don\t give up, th'
		db	'e people of Zeliard are dependin'
		db	'g on you!'
		db	0FFh, 05h, 11h,0FFh,0FFh, 0Ch
data_17		db	0FFh			; Data table (indexed access)
		db	 03h,0FFh, 04h
		db	'Duke Garland, '
		db	0FFh, 05h,0FFh, 02h,0FFh, 04h
data_18		db	'you are a brave man. You have co'
		db	'nquered Jashiin and returned the'
		db	' nine Tears of Esmesanti. '
		db	0FFh, 05h,0FFh, 02h, 0Dh,0FFh
		db	 04h
		db	'Now go quickly to the chamber of'
		db	' Princess Felicia. The&crystals '
		db	'will bring her back to life. '
		db	0FFh, 05h, 11h,0FFh,0FFh, 00h
		db	 00h, 00h, 00h, 00h

seg_a		ends



		end	start
