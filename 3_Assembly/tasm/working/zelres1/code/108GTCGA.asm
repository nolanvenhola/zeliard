
PAGE  59,132

;==========================================================================
;
;  IMAGE_DECODER_A - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	4100h			;*
data_2e		equ	6000h			;*
data_3e		equ	8000h			;*
data_4e		equ	8004h			;*
data_5e		equ	8100h			;*
data_6e		equ	0D000h			;*
data_12e	equ	127Ch			;*
data_13e	equ	2135h			;*
data_14e	equ	3568h			;*
data_15e	equ	35C4h			;*
data_16e	equ	3811h			;*
data_17e	equ	39B4h			;*
data_18e	equ	3C04h			;*
data_19e	equ	3D0Bh			;*
data_20e	equ	3D6Dh			;*
data_21e	equ	3D6Fh			;*
data_22e	equ	3D70h			;*
data_23e	equ	3D71h			;*
data_24e	equ	3D73h			;*
data_25e	equ	3D76h			;*
data_26e	equ	3D78h			;*
data_27e	equ	3D7Ah			;*
data_28e	equ	3D7Ch			;*
data_29e	equ	3D7Eh			;*
data_30e	equ	3D80h			;*
data_32e	equ	3D84h			;*
data_33e	equ	3DACh			;*
data_34e	equ	3F14h			;*
data_35e	equ	3F74h			;*
data_36e	equ	3FA4h			;*
data_37e	equ	3FB0h			;*
data_38e	equ	3FD4h			;*
data_39e	equ	0A000h			;*
data_40e	equ	0C00Fh			;*
data_41e	equ	0C050h			;*
data_42e	equ	0E005h			;*
data_43e	equ	0F502h			;*
data_44e	equ	0F504h			;*
data_45e	equ	0FF2Ah			;*
data_46e	equ	0FF2Ch			;*
data_47e	equ	0FF57h			;*
data_48e	equ	0FF68h			;*
data_49e	equ	0FF6Ah			;*
data_50e	equ	0			;*
data_51e	equ	23Ch
data_52e	equ	273h
data_53e	equ	163Ch
data_54e	equ	1673h
data_55e	equ	177Ch
data_56e	equ	17B3h
data_57e	equ	3FB0h
data_58e	equ	0C050h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_08		proc	far

start:
;*		aam	11h			; undocumented inst
		db	0D4h, 11h		;  Fixup - byte match
		add	[bx+si],al
		cmc				; Complement carry
		cmp	ch,[bx+si]
		xor	[bx+30h],dl
		ja	locloop_2		; Jump if above
;*		aam	36h			; '6' undocumented inst
		db	0D4h, 36h		;  Fixup - byte match
		add	ax,6037h
		aaa				; Ascii adjust
		dec	di
		xor	si,ss:data_13e[bp]
		db	 36h, 7Ch, 35h, 8Fh, 37h,0D8h
		db	 37h, 62h, 38h, 23h, 38h, 23h
		db	 3Ah, 88h, 3Ah, 02h, 39h,0B2h
		db	 3Bh, 2Fh, 3Bh, 1Eh,0BEh, 3Ch
		db	 0Ch,0BFh, 00h,0A0h, 0Eh, 07h
		db	0B8h, 00h,0B8h, 8Eh,0D8h,0B9h
		db	 1Ch, 00h

locloop_1:
		push	cx
		push	si
		mov	cx,18h

locloop_2:
		movsw				; Mov [si] to es:[di]
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_3			; Jump if below
		add	si,data_41e
loc_3:
		loop	locloop_2		; Loop if cx > 0

		pop	si
		pop	cx
		inc	si
		inc	si
		loop	locloop_1		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_38e
		xor	ax,ax			; Zero register
		mov	cx,100h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,ds:data_45e
		cmp	byte ptr [si+1Dh],0FDh
		jne	loc_4			; Jump if not equal
		call	deca_multiply_2
loc_4:
		mov	word ptr ds:data_20e,0C3Ch
		mov	si,ds:data_45e
		add	si,20h
		push	cs
		pop	es
		mov	di,0E000h
		mov	byte ptr ds:data_21e,0
loc_5:
		call	deca_scan_loop
		xor	bl,bl			; Zero register
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_6			; Jump if zero
		call	deca_func_4
loc_6:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_7			; Jump if zero
		call	deca_func_4
loc_7:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_8			; Jump if zero
		call	deca_func_4
loc_8:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_9			; Jump if zero
		call	deca_func_3
loc_9:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_10			; Jump if zero
		call	deca_func_3
loc_10:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_11			; Jump if zero
		call	deca_multiply
loc_11:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_12			; Jump if zero
		call	deca_func_3
loc_12:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_13			; Jump if zero
		call	deca_func_3
loc_13:
		add	word ptr ds:data_20e,2
		inc	byte ptr ds:data_21e
		cmp	byte ptr ds:data_21e,1Ch
		jne	loc_5			; Jump if not equal
		retn

zr1_08		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_scan_loop		proc	near
		cmp	byte ptr ds:data_21e,1Bh
		jne	loc_14			; Jump if not equal
		retn
loc_14:
		mov	al,byte ptr ds:[83h]
		cmp	ds:data_21e,al
		je	loc_15			; Jump if equal
		retn
loc_15:
		push	di
		push	es
		push	si
		mov	al,byte ptr ds:[83h]
		add	al,al
		xor	ah,ah			; Zero register
		mov	di,ax
		add	di,data_12e
		mov	ax,0B800h
		mov	es,ax
		mov	si,data_34e
		mov	cx,2

locloop_16:
		push	cx
		push	di
		call	deca_check_state
		pop	di
		inc	di
		inc	di
		pop	cx
		loop	locloop_16		; Loop if cx > 0

		pop	si
		pop	es
		pop	di
		retn
deca_scan_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_multiply		proc	near
		cmp	byte ptr [si-1],0FDh
		jne	loc_17			; Jump if not equal
		jmp	loc_47

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

deca_func_3:
loc_17:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	loc_18			; Jump if not zero
		retn
loc_18:
		dec	di
		dec	si
		mov	dl,[si]
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		push	dx
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		mov	ax,50h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:data_20e
		mov	di,ax
		pop	dx
		mov	bl,dl
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:data_38e[bx],0FFFFh
		jnz	loc_22			; Jump if not zero
		mov	ds:data_38e[bx],di
		mov	ax,10h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,data_5e
		mov	ds,cs:data_46e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,4

locloop_19:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_20			; Jump if below
		add	di,data_58e
loc_20:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_21			; Jump if below
		add	di,data_58e
loc_21:
		loop	locloop_19		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_22:
		mov	si,ds:data_38e[bx]
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_23			; Jump if below
		add	di,data_58e
loc_23:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_24			; Jump if below
		add	si,data_58e
loc_24:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_25			; Jump if below
		add	di,data_58e
loc_25:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_26			; Jump if below
		add	si,data_58e
loc_26:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_27			; Jump if below
		add	di,data_58e
loc_27:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_28			; Jump if below
		add	si,data_58e
loc_28:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_29			; Jump if below
		add	di,data_58e
loc_29:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_30			; Jump if below
		add	si,data_58e
loc_30:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_31			; Jump if below
		add	di,data_58e
loc_31:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_32			; Jump if below
		add	si,data_58e
loc_32:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_33			; Jump if below
		add	di,data_58e
loc_33:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_34			; Jump if below
		add	si,data_58e
loc_34:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_35			; Jump if below
		add	di,data_58e
loc_35:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_36			; Jump if below
		add	si,data_58e
loc_36:
		movsw				; Mov [si] to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

deca_func_4:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	loc_37			; Jump if not zero
		retn
loc_37:
		push	bx
		push	es
		mov	dl,[si-1]
		mov	bl,dl
		xor	bh,bh			; Zero register
		mov	es,cs:data_46e
		add	bx,es:data_3e
		mov	dh,es:[bx]
		pop	es
		pop	bx
		or	dh,dh			; Zero ?
		jnz	loc_38			; Jump if not zero
		jmp	loc_17
loc_38:
		dec	di
		dec	si
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		push	dx
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		mov	ax,50h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:data_20e
		mov	di,ax
		pop	dx
		mov	ax,10h
		mul	dl			; ax = reg * al
		mov	si,ax
		mov	bp,ax
		add	si,data_5e
		add	bp,data_6e
		mov	ax,30h
		mul	byte ptr ds:data_21e	; ax = data * al
		add	bx,bx
		add	bx,bx
		add	bx,ax
		add	bx,data_39e
		mov	ds,cs:data_46e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

locloop_39:
		mov	ax,cs:[bx]
		inc	bx
		inc	bx
		and	ax,ds:[bp]
		inc	bp
		inc	bp
		or	ax,[si]
		inc	si
		inc	si
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_40			; Jump if below
		add	di,data_41e
loc_40:
		loop	locloop_39		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	ah,[di-1]
		or	ah,ah			; Zero ?
		jnz	loc_41			; Jump if not zero
		retn
loc_41:
		cmp	ah,19h
		jb	loc_42			; Jump if below
		retn
loc_42:
		push	di
		push	es
		mov	es,cs:data_46e
		mov	di,es:data_4e
		mov	cl,es:[di]
		or	cl,cl			; Zero ?
		jz	loc_45			; Jump if zero
		inc	di
loc_43:
		mov	al,es:[di]
		cmp	al,0FFh
		je	loc_45			; Jump if equal
		cmp	ah,al
		jne	loc_44			; Jump if not equal
		mov	al,es:[di+1]
		mov	[si-1],al
		jmp	short loc_45
loc_44:
		inc	di
		inc	di
		dec	cl
		jnz	loc_43			; Jump if not zero
loc_45:
		pop	es
		pop	di
		retn
		db	0BFh, 14h, 3Fh

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

deca_func_5:
		mov	cx,6

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

deca_func_6:
		push	cs
		pop	es

locloop_46:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	cl,10h
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_5e
		mov	ds,cs:data_46e
		mov	cx,8
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	ds
		pop	cx
		loop	locloop_46		; Loop if cx > 0

		retn
loc_47:
		push	ds
		push	si
		push	es
		push	di
		mov	di,data_23e
		movsw				; Mov [si] to es:[di]
		add	si,5
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dl,cs:data_21e
		add	dl,4
		xor	dh,dh			; Zero register
		add	dx,word ptr cs:[80h]
		mov	ds:data_25e,dx
		call	deca_func_8
		mov	es:data_22e,al
		cmp	byte ptr es:data_24e,0FDh
		jne	loc_48			; Jump if not equal
		inc	dx
		call	deca_func_8
		mov	es:data_24e,al
loc_48:
		mov	si,3D70h
		mov	di,3F74h
		call	deca_func_5
		mov	si,cs:data_40e
loc_49:
		call	deca_scan_loop_2
		or	bl,bl			; Zero ?
		jz	loc_50			; Jump if zero
		push	si
		push	bx
		call	deca_multiply_3
		pop	bx
		mov	es,cs:data_46e
		mov	si,data_22e
		call	deca_get_value
		pop	si
loc_50:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_49			; Jump if not zero
		pop	di
		pop	es
		mov	ch,es:[di-1]
		mov	cl,es:[di+7]
		push	es
		push	di
		push	cx
		mov	di,cs:data_20e
		add	di,640h
		push	di
		mov	si,data_35e
		mov	ax,0B800h
		mov	es,ax
		inc	ch
		jz	loc_51			; Jump if zero
		call	deca_check_state
loc_51:
		pop	di
		pop	cx
		cmp	byte ptr cs:data_21e,1Bh
		je	loc_52			; Jump if equal
		mov	si,data_36e
		inc	di
		inc	di
		inc	cl
		jz	loc_52			; Jump if zero
		call	deca_check_state
loc_52:
		pop	di
		pop	es
		mov	al,0FFh
		mov	byte ptr es:[di-1],0FEh
		mov	es:[di],al
		mov	es:[di+1],al
		mov	es:[di+7],al
		mov	es:[di+8],al
		mov	es:[di+9],al
		pop	si
		pop	ds
		retn
deca_multiply		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_multiply_2		proc	near
		push	es
		push	ds
		mov	si,ds:data_45e
		add	si,25h
		mov	di,data_22e
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dx,word ptr ds:[80h]
		add	dx,3
		mov	ds:data_25e,dx
		cmp	byte ptr ds:data_22e,0FDh
		jne	loc_53			; Jump if not equal
		inc	dx
		call	deca_func_8
		mov	ds:data_22e,al
loc_53:
		mov	si,3D70h
		mov	di,3F74h
		mov	cx,3
		call	deca_func_6
		mov	si,cs:data_40e
loc_54:
		call	deca_scan_loop_2
		or	bl,bl			; Zero ?
		jz	loc_55			; Jump if zero
		push	si
		dec	bl
		mov	al,3
		mul	bl			; ax = reg * al
		push	ax
		call	deca_multiply_3
		pop	ax
		add	di,ax
		mov	bp,di
		mov	es,cs:data_46e
		mov	si,3D70h
		mov	di,data_35e
		call	deca_multiply_4
		pop	si
loc_55:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_54			; Jump if not zero
		mov	di,data_12e
		mov	si,data_35e
		mov	ax,0B800h
		mov	es,ax
		call	deca_check_state
		pop	ds
		pop	es
		mov	di,data_42e
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn
deca_multiply_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_func_8		proc	near
		call	deca_func_9
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_56			; Jump if equal
		retn
loc_56:
		add	si,8
		call	deca_func_10
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_56			; Jump if equal
		retn
deca_func_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_func_9		proc	near
		mov	si,ds:data_40e

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

deca_func_10:
loc_57:
		cmp	dx,[si]
		jne	loc_58			; Jump if not equal
		retn
loc_58:
		add	si,8
		jmp	short loc_57
deca_func_9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_check_state		proc	near
		mov	cx,3

locloop_59:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_60			; Jump if below
		add	di,data_58e
loc_60:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_61			; Jump if below
		add	di,data_58e
loc_61:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_62			; Jump if below
		add	di,data_58e
loc_62:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_63			; Jump if below
		add	di,data_58e
loc_63:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_64			; Jump if below
		add	di,data_58e
loc_64:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_65			; Jump if below
		add	di,data_58e
loc_65:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_66			; Jump if below
		add	di,data_58e
loc_66:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_67			; Jump if below
		add	di,0C050h
loc_67:
		loop	locloop_59		; Loop if cx > 0

		retn
deca_check_state		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_get_value		proc	near
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_14e[bx]	;*
		retn
deca_get_value		endp

			                        ;* No entry point to code
		jz	loc_69			; Jump if zero
		db	 6Ch, 35h,0BFh, 74h, 3Fh,0E8h
		db	 70h, 00h,0EBh, 6Eh, 83h,0C6h
		db	 03h,0BFh,0A4h, 3Fh,0EBh
		db	66h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_multiply_3		proc	near
		mov	al,[si+2]
		mov	ch,al
		and	al,7Fh
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,4000h
		mov	di,ax
		xor	dl,dl			; Zero register
		or	ch,ch			; Zero ?
		js	loc_68			; Jump if sign=1
		mov	dl,4
loc_68:
		mov	al,[si+4]
		and	al,3
		add	al,dl
		mov	cl,6
		mul	cl			; ax = reg * al
loc_69:
		add	di,ax
		retn
deca_multiply_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_scan_loop_2		proc	near
		mov	cx,2
		mov	dx,ds:data_25e

locloop_70:
		mov	bl,cl
		cmp	[si],dx
		jne	loc_71			; Jump if not equal
		retn
loc_71:
		inc	dx
		loop	locloop_70		; Loop if cx > 0

		mov	bl,cl
		retn
deca_scan_loop_2		endp

			                        ;* No entry point to code
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_15e[bx]	;*
		retn
		db	0DAh, 35h,0D2h, 35h,0CAh, 35h
		db	 83h,0C5h, 03h,0BFh, 14h, 3Fh
		db	0EBh, 10h,0BFh, 14h, 3Fh,0E8h
		db	 0Ah, 00h,0EBh, 08h,0BFh, 44h
		db	 3Fh, 83h,0C6h, 03h,0EBh, 00h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_multiply_4		proc	near
		mov	cx,3

locloop_72:
		push	cx
		mov	byte ptr [si],0FFh
		inc	si
		push	ds
		push	si
		mov	al,es:[bp]
		inc	bp
		push	es
		push	bp
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		add	ax,7000h
		mov	cs:data_30e,ax
		mov	ax,cs
		add	ax,2000h
		mov	word ptr cs:data_30e+2,ax
		mov	ds,cs:data_46e
		push	cs
		pop	es
		call	deca_process_loop
		pop	bp
		pop	es
		pop	si
		pop	ds
		pop	cx
		loop	locloop_72		; Loop if cx > 0

		retn
deca_multiply_4		endp

			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_34e
		mov	cx,6

locloop_73:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	cl,10h
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_2e
		add	ax,8000h
		mov	cs:data_30e,ax
		mov	ax,cs
		add	ax,2000h
		mov	word ptr cs:data_30e+2,ax
		mov	ds,cs:data_46e
		call	deca_process_loop
		pop	si
		pop	ds
		pop	cx
		loop	locloop_73		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_process_loop		proc	near
		push	ds
		push	si
		push	di
		lds	si,dword ptr cs:data_30e	; Load seg:offset ptr
		mov	cx,8

locloop_74:
		lodsw				; String [si] to ax
		and	es:[di],ax
		inc	di
		inc	di
		loop	locloop_74		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		mov	cx,8

locloop_75:
		lodsw				; String [si] to ax
		or	es:[di],ax
		inc	di
		inc	di
		loop	locloop_75		; Loop if cx > 0

		retn
deca_process_loop		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		std				; Set direction flag
		mov	si,data_54e
		mov	al,8
loc_76:
		push	si
		mov	di,si
		dec	si
		dec	si
		mov	cx,36h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,1Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,4000h
		jb	loc_77			; Jump if below
		add	si,0C050h
loc_77:
		dec	al
		jnz	loc_76			; Jump if not zero
		mov	si,data_56e
		mov	al,8
loc_78:
		push	si
		mov	di,si
		sub	si,4
		mov	cx,34h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,20h
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,4000h
		jb	loc_79			; Jump if below
		add	si,0C050h
loc_79:
		dec	al
		jnz	loc_78			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		std				; Set direction flag
		mov	si,data_52e
		mov	al,10h
loc_80:
		push	si
		mov	di,si
		dec	si
		mov	cx,37h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,1Dh
		movsb				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,4000h
		jb	loc_81			; Jump if below
		add	si,0C050h
loc_81:
		dec	al
		jnz	loc_80			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	si,data_53e
		mov	al,8
loc_82:
		push	si
		mov	di,si
		inc	si
		inc	si
		mov	cx,36h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,1Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,4000h
		jb	loc_83			; Jump if below
		add	si,0C050h
loc_83:
		dec	al
		jnz	loc_82			; Jump if not zero
		mov	si,data_55e
		mov	al,8
loc_84:
		push	si
		mov	di,si
		add	si,4
		mov	cx,34h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,20h
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,4000h
		jb	loc_85			; Jump if below
		add	si,0C050h
loc_85:
		dec	al
		jnz	loc_84			; Jump if not zero
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	si,data_51e
		mov	al,10h
loc_86:
		push	si
		mov	di,si
		inc	si
		mov	cx,37h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,1Dh
		movsb				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,4000h
		jb	loc_87			; Jump if below
		add	si,0C050h
loc_87:
		dec	al
		jnz	loc_86			; Jump if not zero
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,data_3e
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	di,bx
		mov	ds,cs:data_46e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

locloop_88:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_89			; Jump if below
		add	di,data_58e
loc_89:
		loop	locloop_88		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	si
		push	di
		push	cs
		pop	ds
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	ax,0B800h
		mov	es,ax
		mov	si,data_16e
		mov	cx,9

locloop_90:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_91			; Jump if below
		add	di,data_41e
loc_91:
		loop	locloop_90		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		retn
		db	 00h, 00h, 28h, 00h, 2Ah, 00h
		db	 2Ah, 80h, 2Ah,0A0h, 2Ah, 80h
		db	 2Ah, 00h, 28h, 00h, 00h, 00h
		db	0D0h,0EBh, 1Bh,0FFh, 81h,0E7h
		db	 00h, 20h,0B0h, 50h,0F6h,0E3h
		db	 03h,0F8h, 8Ah,0DFh, 32h,0FFh
		db	 03h,0FBh,0BEh, 84h, 3Dh,0B8h
		db	 00h,0B8h, 8Eh,0C0h,0B9h, 09h
		db	 00h

locloop_92:
		push	cx
		push	di
		push	si
		mov	cx,ds:data_49e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,28h
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_93			; Jump if below
		add	di,0C050h
loc_93:
		pop	cx
		loop	locloop_92		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	si
		push	di
		push	di
		xor	ah,ah			; Zero register
		push	ax
		push	cs
		pop	es
		mov	di,data_32e
		xor	ax,ax			; Zero register
		mov	cx,0C8h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		push	ax
		add	ax,ax
		add	si,ax
		mov	si,[si]
		call	deca_func_17
		pop	ax
		pop	di
		test	byte ptr ds:data_47e,0FFh
		jz	loc_94			; Jump if zero
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	di,ax
		mov	dl,[di]
		mov	ax,[di+1]
		call	deca_process_loop_2
loc_94:
		pop	di
		pop	si
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_func_17		proc	near
		push	cs
		pop	es
		mov	di,data_33e
		xor	bl,bl			; Zero register
loc_95:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_96			; Jump if not zero
		retn
loc_96:
		push	bx
		push	ds
		push	si
		and	bl,3
		call	deca_func_18
		pop	si
		pop	ds
		pop	bx
		inc	bl
		jmp	short loc_95
deca_func_17		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_func_18		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:data_44e
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8
loc_97:
		push	bx
		lodsb				; String [si] to al
		mov	dl,4
loc_98:
		add	ax,ax
		add	ah,ah
		dec	dl
		jnz	loc_98			; Jump if not zero
		mov	al,ah
		shr	ah,1			; Shift w/zeros fill
		or	al,ah
		xor	bl,bl			; Zero register
		mov	bh,al
		shr	bx,cl			; Shift w/zeros fill
		or	es:[di],bh
		or	es:[di+1],bl
		add	di,28h
		pop	bx
		dec	bl
		jnz	loc_97			; Jump if not zero
		pop	di
		inc	di
		cmp	cl,6
		je	loc_99			; Jump if equal
		retn
loc_99:
		inc	di
		retn
deca_func_18		endp

			                        ;* No entry point to code
		push	dx
		push	ax
		push	cs
		pop	es
		mov	di,data_32e
		xor	ax,ax			; Zero register
		mov	cx,0C8h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		pop	dx
		call	deca_process_loop_4
		mov	di,3DACh
		mov	si,39B3h
		mov	cx,7
		mov	bl,1
		mov	word ptr ds:data_49e,0Bh
		jmp	short locloop_100

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_process_loop_2		proc	near
		call	deca_process_loop_4
		push	cs
		pop	es
		mov	di,data_33e
		add	di,ds:data_48e
		mov	si,data_17e
		mov	cx,6
		mov	bl,1

locloop_100:
		push	cx
		push	bx
		push	di
		lodsb				; String [si] to al
		push	si
		call	deca_process_loop_3
		pop	si
		pop	di
		pop	bx
		mov	al,bl
		inc	di
		and	ax,1
		add	di,ax
		inc	bl
		pop	cx
		loop	locloop_100		; Loop if cx > 0

		retn
deca_process_loop_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_process_loop_3		proc	near
		inc	al
		jnz	loc_101			; Jump if not zero
		retn
loc_101:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:data_43e
		mov	si,ax
		mov	cx,7

locloop_102:
		lodsb				; String [si] to al
		mov	ah,8
loc_103:
		add	al,al
		adc	dx,dx
		add	dx,dx
		dec	ah
		jnz	loc_103			; Jump if not zero
		mov	ax,dx
		shr	dx,1			; Shift w/zeros fill
		or	ax,dx
		test	bl,1
		jnz	loc_104			; Jump if not zero
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
loc_104:
		or	es:[di],ah
		or	es:[di+1],al
		add	di,28h
		loop	locloop_102		; Loop if cx > 0

		retn
deca_process_loop_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_process_loop_4		proc	near
		mov	di,39B3h
		call	deca_func_22
		mov	cx,6

locloop_105:
		test	byte ptr cs:[di],0FFh
		jz	loc_106			; Jump if zero
		retn
loc_106:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	locloop_105		; Loop if cx > 0

		retn
deca_process_loop_4		endp

		db	7 dup (0)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_func_22		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	deca_func_23
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	deca_func_23
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	deca_func_23
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	deca_func_24
		mov	cs:[di+3],dh
		mov	bx,64h
		call	deca_func_24
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	deca_func_24
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn
deca_func_22		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_func_23		proc	near
		xor	dh,dh			; Zero register
loc_107:
		sub	dl,cl
		jc	loc_110			; Jump if carry Set
		sub	ax,bx
		jnc	loc_108			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_109			; Jump if zero
		dec	dl
loc_108:
		inc	dh
		jmp	short loc_107
loc_109:
		add	ax,bx
loc_110:
		add	dl,cl
		retn
deca_func_23		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_func_24		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn
deca_func_24		endp

			                        ;* No entry point to code
		push	ds
		push	ax
		add	bl,cl
		dec	bl
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	si,di
		sub	si,2000h
		jnc	loc_111			; Jump if carry=0
		add	si,data_57e
loc_111:
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

locloop_112:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		sub	si,2000h
		jnc	loc_113			; Jump if carry=0
		add	si,data_37e
loc_113:
		sub	di,2000h
		jnc	loc_114			; Jump if carry=0
		add	di,data_57e
loc_114:
		pop	cx
		loop	locloop_112		; Loop if cx > 0

		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,3D84h
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	ax
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	si,di
		add	si,2000h
		cmp	si,4000h
		jb	loc_115			; Jump if below
		add	si,data_58e
loc_115:
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

locloop_116:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	si,2000h
		cmp	si,4000h
		jb	loc_117			; Jump if below
		add	si,data_41e
loc_117:
		add	di,2000h
		cmp	di,4000h
		jb	loc_118			; Jump if below
		add	di,data_58e
loc_118:
		pop	cx
		loop	locloop_116		; Loop if cx > 0

		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,3D84h
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
			                        ;* No entry point to code
		mov	ax,0B800h
		mov	es,ax
		mov	di,data_51e
		mov	cx,8

locloop_119:
		push	cx
		push	di
		mov	cx,12h

locloop_120:
		push	cx
		push	di
		mov	ax,0FFFFh
		mov	cx,1Ch

locloop_121:
		xor	es:[di],ax
		inc	di
		inc	di
		loop	locloop_121		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_120		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_122			; Jump if below
		add	di,0C050h
loc_122:
		pop	cx
		loop	locloop_119		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	cs:data_30e,di
		mov	word ptr cs:data_30e+2,es
		push	cx
		push	ds
		push	si
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,30h
		mul	cx			; dx:ax = reg * ax
		mov	cx,ax
		mov	di,data_50e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,data_50e

locloop_123:
		push	cx
		mov	cx,8

locloop_124:
		push	cx
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsw				; String [si] to ax
		mov	cx,ax
		lodsw				; String [si] to ax
		mov	bx,ax
		mov	bp,ax
		or	ax,cx
		or	ax,dx
		and	bp,cx
		and	bp,dx
		not	bp
		and	dx,bp
		and	cx,bp
		and	bx,bp
		mov	cs:data_26e,dx
		mov	cs:data_27e,cx
		mov	cs:data_28e,bx
		not	ax
		mov	cs:data_29e,ax
		call	deca_process_loop_5
		mov	ax,dx
		stosw				; Store ax to es:[di]
		push	es
		push	di
		les	di,dword ptr cs:data_30e	; Load seg:offset ptr
		call	deca_scan_loop_3
		mov	ax,dx
		stosw				; Store ax to es:[di]
		mov	cs:data_30e,di
		pop	di
		pop	es
		pop	cx
		loop	locloop_124		; Loop if cx > 0

		pop	cx
		loop	locloop_123		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_46e
		mov	si,data_5e
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	cx,2EE0h
		mov	di,data_50e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	es,cs:data_46e
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,0
		mov	di,8100h
		mov	bx,es:data_3e
		mov	bp,0D000h
		mov	cx,0FAh

locloop_125:
		push	cx
		mov	al,es:[bx]
		cmp	al,5
		jb	loc_126			; Jump if below
		xor	al,al			; Zero register
loc_126:
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		add	bx,bx
		call	word ptr cs:data_18e[bx]	;*
		pop	bx
		inc	bx
		pop	cx
		loop	locloop_125		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	cs
		cmp	al,33h			; '3'
		cmp	al,60h			; '`'
		cmp	al,8Dh
		cmp	al,0BAh
		cmp	al,0B9h
		or	[bx+si],al

locloop_127:
		push	cx
		lodsw				; String [si] to ax
		mov	cs:data_26e,ax
		lodsw				; String [si] to ax
		mov	cs:data_27e,ax
		lodsw				; String [si] to ax
		mov	cs:data_28e,ax
		call	deca_process_loop_5
		mov	ax,dx
		stosw				; Store ax to es:[di]
		mov	word ptr es:[bp],0
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_127		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_128:
		push	cx
		lodsw				; String [si] to ax
		mov	cs:data_26e,ax
		lodsw				; String [si] to ax
		mov	cs:data_27e,ax
		mov	word ptr cs:data_28e,0
		lodsw				; String [si] to ax
		mov	cs:data_29e,ax
		call	deca_process_loop_5
		mov	ax,dx
		stosw				; Store ax to es:[di]
		call	deca_scan_loop_3
		mov	es:[bp],dx
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_128		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_129:
		push	cx
		lodsw				; String [si] to ax
		mov	cs:data_26e,ax
		lodsw				; String [si] to ax
		mov	cs:data_29e,ax
		mov	word ptr cs:data_27e,0
		lodsw				; String [si] to ax
		mov	cs:data_28e,ax
		call	deca_process_loop_5
		mov	ax,dx
		stosw				; Store ax to es:[di]
		call	deca_scan_loop_3
		mov	es:[bp],dx
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_129		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_130:
		push	cx
		lodsw				; String [si] to ax
		mov	cs:data_29e,ax
		mov	word ptr cs:data_26e,0
		lodsw				; String [si] to ax
		mov	cs:data_27e,ax
		lodsw				; String [si] to ax
		mov	cs:data_28e,ax
		call	deca_process_loop_5
		mov	ax,dx
		stosw				; Store ax to es:[di]
		call	deca_scan_loop_3
		mov	es:[bp],dx
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_130		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_131:
		push	cx
		add	si,6
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		mov	word ptr es:[bp],0FFFFh
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_131		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_process_loop_5		proc	near
		mov	cx,8

locloop_132:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_28e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_27e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_26e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_28e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_27e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_26e,1	; Rotate
		adc	bx,bx
		add	dx,dx
		add	dx,dx
		or	dl,cs:data_19e[bx]
		loop	locloop_132		; Loop if cx > 0

		retn
deca_process_loop_5		endp

		db	0, 1, 0, 1, 1, 0
		db	3, 2, 1, 3, 2, 3
		db	1, 3, 3, 2, 2, 2
		db	2, 1, 1, 2, 2, 2
		db	1, 3, 1, 3, 1, 1
		db	2, 2, 1, 1, 1, 1
		db	1, 1, 3, 2, 0, 3
		db	2, 1, 1, 1, 3, 2
		db	3, 3, 2, 2, 3, 3
		db	3, 2, 1, 2, 2, 2
		db	2, 2, 2, 2

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

deca_scan_loop_3		proc	near
		mov	cx,8

locloop_133:
		xor	al,al			; Zero register
		rol	word ptr cs:data_29e,1	; Rotate
		adc	al,al
		rol	word ptr cs:data_29e,1	; Rotate
		adc	al,al
		cmp	al,3
		je	loc_134			; Jump if equal
		xor	al,al			; Zero register
loc_134:
		add	dx,dx
		add	dx,dx
		or	dl,al
		loop	locloop_133		; Loop if cx > 0

		retn
deca_scan_loop_3		endp

		db	1127 dup (0)

seg_a		ends



		end	start
