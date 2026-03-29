
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				GAME	                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   29-Mar-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    9          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'M4'                      ; Target assembler: MASM-4.0

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_10e	equ	18ABh			;*
data_11e	equ	201Ch			;*
data_12e	equ	201Eh			;*
data_13e	equ	2020h			;*
data_14e	equ	203Eh			;*
data_15e	equ	3000h			;*
data_16e	equ	37A4h			;*
data_17e	equ	3EA4h			;*
data_18e	equ	6000h			;*
data_19e	equ	6002h			;*
data_20e	equ	0A288h			;*
data_21e	equ	0A2D1h			;*
data_22e	equ	0A31Ah			;*
data_23e	equ	0A3D3h			;*
data_24e	equ	0A3F2h			;*
data_25e	equ	0A456h			;*
data_26e	equ	0A470h			;*
data_28e	equ	0A474h			;*
data_29e	equ	0C000h			;*
data_30e	equ	0FF08h			;*
data_31e	equ	0FF14h			;*
data_32e	equ	0FF36h			;*
data_33e	equ	0FF38h			;*
data_34e	equ	0FF39h			;*
data_35e	equ	0FF3Ah			;*
data_36e	equ	0FF3Ch			;*
data_37e	equ	0FF3Dh			;*
data_38e	equ	0FF3Eh			;*
data_39e	equ	0FF40h			;*
data_40e	equ	0FF42h			;*
data_41e	equ	0FF43h			;*
data_42e	equ	0FF44h			;*
data_43e	equ	0FF4Bh			;*
data_44e	equ	0FF74h			;*
data_45e	equ	0FF77h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

game		proc	far

start:
		mov	cs:data_28e,ax
		mov	ax,cs
		mov	ds,ax
		push	cs
		pop	es
		mov	di,0F500h
		mov	si,0A21Dh
		mov	al,2
		call	word ptr cs:[10Ch]
		add	es:[di],di
		add	es:[di+2],di
		add	es:[di+4],di
		call	word ptr cs:[120h]
		xor	al,al			; Zero register
		mov	ds:data_34e,al
		mov	ds:data_35e,al
		mov	ds:data_41e,al
		mov	ds:data_42e,al
		mov	ds:data_36e,al
		mov	ds:data_37e,al
		mov	ds:data_33e,al
		mov	ds:data_32e,al
		mov	ds:data_38e,al
		mov	ds:data_43e,al
		mov	ds:data_30e,al
		mov	byte ptr ds:[0E7h],al
		mov	ds:data_44e,al
		mov	ds:data_45e,al
		mov	ds:data_39e,al
		mov	ds:data_40e,al
		mov	ax,cs
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ds:data_31e
		add	bx,bx
		mov	si,ds:data_22e[bx]
		mov	di,3000h
		mov	al,3
		call	word ptr cs:[10Ch]
		call	word ptr cs:data_15e
		cmp	word ptr cs:data_28e,0FFFFh
		je	loc_1			; Jump if equal
		mov	byte ptr cs:data_45e,0FFh
		mov	si,0A27Bh
		mov	di,6000h
		mov	al,3
		call	word ptr cs:[10Ch]
		jmp	word ptr ds:data_18e
loc_1:
		call	sub_2
		mov	ax,cs
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ds:data_31e
		add	bx,bx
		mov	si,ds:data_21e[bx]
		mov	di,3000h
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	si,0A270h
		mov	di,6000h
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ds:data_31e
		add	bx,bx
		mov	si,ds:data_20e[bx]
		mov	di,9000h
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	si,0A264h
		mov	di,0C000h
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	ax,cs
		add	ax,1000h
		mov	es,ax
		mov	si,0A23Fh
		mov	di,0C000h
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	ax,cs
		add	ax,1000h
		mov	es,ax
		mov	si,0A233h
		mov	di,0E200h
		mov	al,2
		call	word ptr cs:[10Ch]
		add	es:[di],di
		add	es:[di+2],di
		add	es:[di+4],di
		add	es:[di+6],di
		add	es:[di+8],di
		add	es:[di+0Ah],di
		add	es:[di+0Ch],di
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		mov	si,0A24Ch
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	si,0A258h
		mov	di,1800h
		mov	al,2
		call	word ptr cs:[10Ch]
		add	es:[di],di
		add	es:[di+2],di
		add	es:[di+4],di
		mov	ah,byte ptr ds:[92h]
		mov	al,4
		call	word ptr cs:[10Ch]
		mov	ax,cs
		mov	ds,ax
		add	ax,3000h
		mov	word ptr ds:data_26e+2,ax
		mov	es,ax
		mov	di,0
		mov	si,0A228h
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	al,ds:data_31e
		push	ds
		call	dword ptr ds:data_26e
		pop	ds
		call	sub_1
		mov	ax,cs
		mov	ds,ax
		test	byte ptr ds:[92h],0FFh
		jz	loc_2			; Jump if zero
		mov	al,byte ptr ds:[92h]
		mov	bx,data_10e
		call	word ptr cs:data_11e
loc_2:
		test	byte ptr ds:[93h],0FFh
		jz	loc_3			; Jump if zero
		mov	al,byte ptr ds:[93h]
		mov	bx,data_17e
		call	word ptr cs:data_13e
loc_3:
		test	byte ptr ds:[9Dh],0FFh
		jz	loc_4			; Jump if zero
		mov	al,byte ptr ds:[9Dh]
		mov	bx,data_16e
		call	word ptr cs:data_12e
loc_4:
		mov	ah,byte ptr cs:[0C4h]
		mov	al,1
		call	word ptr cs:[10Ch]
		mov	ax,cs
		mov	ds,ax
		add	ax,1000h
		mov	es,ax
		mov	si,cs:data_29e
		lodsb				; String [si] to al
		push	si
		shr	al,1			; Shift w/zeros fill
		and	al,1Fh
		mov	byte ptr cs:[0C8h],al
		mov	cl,0Bh
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,0A363h
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		pop	si
		lodsb				; String [si] to al
		mov	cl,0Bh
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,0A38Fh
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		jmp	word ptr ds:data_19e
		db	0
		db	0Dh, 'font.grp'
		db	0, 1
		db	8, 'mole.bin'
		db	 00h, 01h, 1Ch
		db	'itemp.grp'
		db	0, 1, 2
		db	'select.bin'
		db	 00h, 01h, 1Dh
		db	'magic.grp'
		db	0, 1
		db	1Bh, 'sword.grp'
		db	0, 1, 1
		db	'fight.bin'
		db	0, 0, 7
		db	'town.bin'
		db	0, 0, 1
		db	'opdemo.bin'
		db	 00h, 94h,0A2h,0A0h,0A2h,0A0h
		db	0A2h,0ACh,0A2h,0B8h,0A2h,0C5h
		db	0A2h, 01h, 03h
		db	'gfega.bin'
		db	0, 1, 4
		db	'gfcga.bin'
		db	0, 1, 5
		db	'gfhgc.bin'
		db	0, 1, 7
		db	'gfmcga.bin'
		db	0, 1, 6
		db	'gftga.bin'
		db	 00h,0DDh,0A2h,0E9h,0A2h,0E9h
		db	0A2h,0F5h,0A2h, 01h,0A3h, 0Eh
		db	0A3h, 00h
		db	8, 'gtega.bin'
		db	0, 0
		db	9, 'gtcga.bin'
		db	0, 0
		db	0Ah, 'gthgc.bin'
		db	0, 0
		db	0Ch, 'gtmcga.bin'
		db	 00h, 00h, 0Bh
		db	'gttga.bin'
		db	 00h, 26h,0A3h, 32h,0A3h, 32h
		db	0A3h, 3Eh,0A3h, 4Ah,0A3h, 57h
		db	0A3h, 00h, 02h
		db	'gdega.bin'
		db	0, 0, 3
		db	'gdcga.bin'
		db	0, 0, 4
		db	'gdhgc.bin'
		db	0, 0, 6
		db	'gdmcga.bin'
		db	0, 0, 5
		db	'gdtga.bin'
		db	0, 1
		db	'/MGT1.MSD'
		db	0, 1
		db	'1UGM1.MSD'
		db	0, 1
		db	'0MGT2.MSD'
		db	0, 1
		db	'2UGM2.MSD'
		db	 00h, 01h, 1Eh
		db	'MMAN.GRP'
		db	 00h, 01h, 1Fh
		db	'CMAN.GRP'
		db	0

game		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		test	byte ptr ds:[0A0h],0FFh
		jnz	loc_5			; Jump if not zero
		retn
loc_5:
		mov	cl,byte ptr ds:[0A0h]
		xor	ch,ch			; Zero register
		xor	bx,bx			; Zero register

locloop_6:
		push	cx
		push	bx
		mov	dx,bx
		add	bx,bx
		mov	bx,ds:data_23e[bx]
		xor	al,al			; Zero register
		cmp	dx,8
		jne	loc_7			; Jump if not equal
		mov	al,1
loc_7:
		call	word ptr cs:data_14e
		pop	bx
		inc	bx
		pop	cx
		loop	locloop_6		; Loop if cx > 0

		retn
sub_1		endp

		db	 00h, 0Fh, 00h, 3Dh, 00h, 15h
		db	 00h, 37h, 00h, 1Bh, 00h, 31h
		db	 00h, 21h, 00h, 2Bh, 00h
		db	26h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		mov	bl,ds:data_31e
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:data_24e[bx]	;*
sub_2		endp

		db	0FEh,0A3h, 1Ah,0A4h, 1Ah,0A4h
		db	 6Fh,0A4h, 1Bh,0A4h, 6Eh,0A4h
		db	 0Eh, 07h,0BAh, 09h,0A4h,0B8h
		db	 02h, 10h,0CDh, 10h,0C3h, 00h
		db	 3Fh, 24h, 12h, 1Bh, 09h, 36h
		db	 2Dh, 38h, 07h, 04h, 02h, 03h
		db	 01h, 06h, 05h, 00h,0C3h, 0Eh
		db	 1Fh,0BEh, 56h,0A4h, 33h,0DBh
		db	0B9h, 08h, 00h

locloop_8:
		push	cx
		lodsb				; String [si] to al
		mov	dh,al
		lodsb				; String [si] to al
		mov	dl,al
		lodsb				; String [si] to al
		mov	ah,al
		push	si
		mov	si,data_25e
		mov	cx,8

locloop_9:
		push	cx
		push	ax
		push	dx
		lodsb				; String [si] to al
		add	dh,al
		lodsb				; String [si] to al
		add	al,dl
		mov	ch,al
		lodsb				; String [si] to al
		add	al,ah
		mov	cl,al
		mov	ax,1010h
		int	10h			; Video display   ah=functn 10h
						;  set color reg bx with colors
						;   dh=red, ch=green, cl=blue
		inc	bx
		pop	dx
		pop	ax
		pop	cx
		loop	locloop_9		; Loop if cx > 0

		pop	si
		pop	cx
		loop	locloop_8		; Loop if cx > 0

		retn
		db	 00h, 00h, 00h, 1Fh, 1Fh, 1Fh
		db	 1Fh, 00h, 00h, 00h, 1Fh, 00h
		db	 00h, 1Fh, 1Fh, 00h, 00h, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 00h, 1Fh
		db	0C3h,0C3h, 00h, 00h, 00h, 30h
		db	 00h, 00h

seg_a		ends



		end	start
