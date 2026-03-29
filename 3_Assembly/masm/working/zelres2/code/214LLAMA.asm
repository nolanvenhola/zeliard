
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_214LLAMA                                €€
;€€					                                 €€
;€€      Created:   29-Mar-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'M4'                      ; Target assembler: MASM-4.0

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_13e	equ	68Eh			;*
data_14e	equ	2000h			;*
data_15e	equ	2002h			;*
data_16e	equ	2008h			;*
data_17e	equ	2010h			;*
data_18e	equ	2012h			;*
data_19e	equ	2018h			;*
data_20e	equ	2040h			;*
data_21e	equ	2044h			;*
data_22e	equ	3016h			;*
data_23e	equ	6004h			;*
data_24e	equ	0A078h			;*
data_25e	equ	0A089h			;*
data_26e	equ	0A0CBh			;*
data_27e	equ	0A177h			;*
data_28e	equ	0A234h			;*
data_29e	equ	0A27Ch			;*
data_30e	equ	0A3E4h			;*
data_31e	equ	0A3E5h			;*
data_32e	equ	0FF1Ah			;*
data_33e	equ	0FF2Ch			;*
data_34e	equ	0FF4Ch			;*
data_35e	equ	0FF4Eh			;*
data_36e	equ	0FF4Fh			;*
data_37e	equ	0FF50h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_214LLAMA	proc	far

start:
		out	3,al			; port 3, DMA-1 bas&cnt ch 1
		add	[bx+si],al
		add	al,0A0h
		xlat				; al=[al+[bx]] table
		mov	ax,ds:data_13e
		sub	al,0FFh
		mov	di,8000h
		mov	si,0A299h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_33e
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:data_21e
		pop	ds
		mov	byte ptr ds:data_35e,0
		mov	byte ptr ds:data_36e,0
		call	word ptr cs:data_15e
		call	word ptr cs:data_18e
		mov	si,0A2A6h
		call	word ptr cs:data_17e
		call	sub_2
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_14e
		call	sub_5
		mov	ds:data_34e,si
loc_1:
		call	word ptr cs:data_23e
		cmp	al,0FFh
		je	loc_2			; Jump if equal
		call	sub_1
		jmp	short loc_1
loc_2:
		jmp	word ptr cs:data_20e

_214LLAMA	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:data_24e[bx]	;*
sub_1		endp

			                        ;* No entry point to code
		in	ax,0A0h			; port 0A0h ??I/O Non-standard
;*		and	byte ptr ds:data_25e[bx+si],99h
		db	 82h,0A0h, 89h,0A0h, 99h	;  Fixup - byte match
		mov	al,ds:data_26e
		mov	word ptr ds:data_34e,0A36Ah
		retn
		db	0C6h, 06h, 1Ah
data_1		dw	offset loc_10		; Data table (indexed access)
loc_3:
		call	sub_3
		cmp	byte ptr ds:data_32e,0FAh
		jb	loc_3			; Jump if below
		retn
loc_4:
		mov	ax,word ptr data_1
		add	ax,8
		cmp	ax,word ptr ds:[0B2h]
		jae	loc_6			; Jump if above or =
		mov	word ptr data_1,ax
		call	word ptr cs:data_16e
		mov	byte ptr ds:data_32e,0
loc_5:
		call	sub_3
		cmp	byte ptr ds:data_32e,14h
		jb	loc_5			; Jump if below
		jmp	short loc_4
loc_6:
		mov	ax,word ptr ds:[0B2h]
		mov	word ptr data_1,ax
		call	word ptr cs:data_16e
		jmp	short $+2		; delay for I/O
		push	cs
		pop	es
		mov	si,0B4h
		mov	di,0ABh
		mov	cx,7
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		test	byte ptr ds:[9Dh],0FFh
		jz	loc_ret_7		; Jump if zero
		call	word ptr cs:data_19e

loc_ret_7:
		retn
		db	0C6h, 06h,0E4h,0A3h, 00h
loc_8:
		mov	byte ptr ds:data_32e,0
		cmp	byte ptr ds:data_30e,5
		jb	loc_9			; Jump if below
		retn
loc_9:
		mov	al,ds:data_30e
		mov	cl,6
		mul	cl			; ax = reg * al
		add	ax,0A134h
		mov	si,ax
		mov	bx,163Fh
		mov	cx,3

locloop_11:
		push	cx
		mov	cx,2

locloop_12:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_22e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_12		; Loop if cx > 0

		sub	bh,2
		add	bl,8
		pop	cx
		loop	locloop_11		; Loop if cx > 0

loc_13:
		call	sub_3
		cmp	byte ptr ds:data_32e,20h	; ' '
		jb	loc_13			; Jump if below
		inc	byte ptr ds:data_30e
		jmp	short loc_8
		db	'ABMNWXABklmnABopqrsBtuvwxyz{|w'

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		mov	si,data_27e
		mov	bx,0E17h
		mov	cx,8

locloop_14:
		push	cx
		mov	cx,0Ch

locloop_15:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_22e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_15		; Loop if cx > 0

		sub	bh,0Ch
		add	bl,8
		pop	cx
		loop	locloop_14		; Loop if cx > 0

		retn
sub_2		endp

		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h
		db	 12h, 10h, 13h, 14h, 15h, 16h
		db	 17h, 18h, 19h, 1Ah, 1Bh, 1Ch
		db	 1Dh, 1Eh, 1Fh
		db	' !"#$'
		db	'%&&', 27h, '(&)*+,-./0123456789:'
		db	';'
		db	'<=>?'
		db	'@ABCDEFGHIJKLMNOPQRSTSUVSWXYZ'

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		cmp	word ptr ds:data_37e,20h
		jae	loc_16			; Jump if above or =
		retn
loc_16:
		mov	word ptr ds:data_37e,0
		inc	byte ptr ds:data_31e
		cmp	byte ptr ds:data_31e,3
		jne	loc_17			; Jump if not equal
		mov	byte ptr ds:data_31e,0
loc_17:
		call	sub_4
		jmp	short loc_21

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_4:
		mov	bl,ds:data_31e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,bx
		add	bx,bx
		add	bx,ax
		mov	si,bx
		add	si,data_28e
		mov	bx,1037h
		mov	cx,2

locloop_18:
		push	cx
		mov	cx,3

locloop_19:
		push	cx
		push	bx
		lodsb				; String [si] to al
		cmp	al,0FFh
		je	loc_20			; Jump if equal
		call	word ptr cs:data_22e
loc_20:
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_19		; Loop if cx > 0

		sub	bh,3
		add	bl,8
		pop	cx
		loop	locloop_18		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	word ptr [bx+si]
		xor	[bp+di],di
		cmp	al,3Dh			; '='
		call	dword ptr [bp+di+5Ch]	;*
		pop	bp
		pop	si
		pop	di
		jmp	word ptr [bx+si+61h]	;*
		db	 62h, 63h, 64h
loc_21:
		mov	bl,ds:data_31e
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		mov	si,bx
		add	si,data_29e
		mov	bx,1537h
		mov	cx,2

locloop_22:
		push	cx
		mov	cx,2

locloop_23:
		push	cx
		push	bx
		lodsb				; String [si] to al
		cmp	al,0FFh
		je	loc_24			; Jump if equal
		call	word ptr cs:data_22e
loc_24:
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_23		; Loop if cx > 0

		sub	bh,2
		add	bl,8
		pop	cx
		loop	locloop_22		; Loop if cx > 0

		retn
sub_3		endp

			                        ;* No entry point to code
		xor	al,35h			; '5'
		inc	ax
		jmp	word ptr [di+66h]	;*
		db	 67h,0FFh, 68h, 69h, 6Ah,0FFh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		mov	ax,word ptr data_1
		cmp	ax,word ptr ds:[0B2h]
		mov	si,0A2B4h
		jnz	loc_25			; Jump if not zero
		retn
loc_25:
		mov	si,0A2F2h
		retn
sub_5		endp

			                        ;* No entry point to code
		add	[bx],dx
		inc	bx
		dec	ax
		push	bp
		push	dx
		inc	bx
		dec	ax
		db	 2Eh, 47h, 52h, 50h, 00h, 17h
		db	0AFh, 02h
		db	0Ah
		db	'The Church', 0Ch, 'Brave Knight,'
		db	' whenever you\re tired come to t'
		db	'his church./'
		db	0FFh, 04h,0FFh, 01h
		db	0Ch, 'Brave Knight, whenever you\'
		db	're weary, come here to rest. '
		db	0FFh, 02h,0FFh, 02h
		db	'The Holy Spirit will help you to'
		db	' regain your strength.'
		db	0FFh, 03h, 0Dh,0FFh, 01h
		db	'Brave Knight, you look fatigued '
		db	'from battle. Why not rest awhile'
		db	' and let the Spirit heal you. '
		db	0FFh, 02h
		db	'/May God go with you.'
		db	0FFh, 00h, 11h,0FFh,0FFh, 00h
		db	 00h

seg_a		ends



		end	start
