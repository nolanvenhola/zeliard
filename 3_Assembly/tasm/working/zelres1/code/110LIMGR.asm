
PAGE  59,132

;==========================================================================
;
;  LARGE_IMAGE_RENDERER - Code Module
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
data_12e	equ	35BAh			;*
data_13e	equ	3616h			;*
data_14e	equ	386Ch			;*
data_15e	equ	3A20h			;*
data_16e	equ	3C68h			;*
data_17e	equ	3DCBh			;*
data_18e	equ	3E64h			;*
data_19e	equ	3E66h			;*
data_20e	equ	3E67h			;*
data_21e	equ	3E68h			;*
data_22e	equ	3E6Ah			;*
data_23e	equ	3E6Dh			;*
data_24e	equ	3E6Fh			;*
data_25e	equ	3E71h			;*
data_26e	equ	3E73h			;*
data_27e	equ	3E75h			;*
data_28e	equ	3E77h			;*
data_30e	equ	3E7Bh			;*
data_31e	equ	419Bh			;*
data_32e	equ	425Bh			;*
data_33e	equ	42BBh			;*
data_34e	equ	431Bh			;*
data_35e	equ	5238h			;*
data_36e	equ	7F60h			;*
data_37e	equ	80A0h			;*
data_38e	equ	0C00Fh			;*
data_39e	equ	0E005h			;*
data_40e	equ	0F502h			;*
data_41e	equ	0F504h			;*
data_42e	equ	0FF2Ah			;*
data_43e	equ	0FF2Ch			;*
data_44e	equ	0FF57h			;*
data_45e	equ	0FF68h			;*
data_46e	equ	0FF6Ah			;*
data_47e	equ	0			;*
data_48e	equ	41F8h
data_49e	equ	4266h
data_50e	equ	55F8h
data_51e	equ	5666h
data_52e	equ	5738h
data_53e	equ	57A6h
data_54e	equ	7F60h
data_55e	equ	80A0h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_10		proc	far

start:
		sbb	dx,[di]
		add	[bx+si],al
		inc	di
		cmp	bp,[bx+si]
		xor	[bx+di+30h],bl
		in	al,36h			; port 36h ??I/O Non-standard
		inc	dx
		aaa				; Ascii adjust
;*		jz	loc_3			;*Jump if zero
		db	 74h, 37h		;  Fixup - byte match
;*		sal	byte ptr [bx],1		; Shift w/zeros fill
		db	0D0h, 37h		;  Fixup - byte match
		xchg	bx,ax
		xor	cx,[bx+si]
		db	 36h, 77h, 36h,0CEh, 35h, 00h
		db	 38h, 3Fh, 38h,0C2h, 38h, 90h
		db	 38h, 8Fh, 3Ah,0E7h, 3Ah, 83h
		db	 39h, 16h, 3Ch, 81h, 3Bh, 1Eh
		db	0BEh,0F8h, 4Bh,0BFh, 00h,0A0h
		db	 0Eh, 07h,0B8h, 00h,0B8h, 8Eh
		db	0D8h,0B9h, 1Ch, 00h

locloop_1:
		push	cx
		push	si
		mov	cx,18h

locloop_2:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_4			; Jump if below
		add	si,data_37e
loc_4:
		loop	locloop_2		; Loop if cx > 0

		pop	si
		pop	cx
		add	si,4
		loop	locloop_1		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_34e
		xor	ax,ax			; Zero register
		mov	cx,100h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,ds:data_42e
		cmp	byte ptr [si+1Dh],0FDh
		jne	loc_5			; Jump if not equal
		call	limg_multiply_2
loc_5:
		mov	word ptr ds:data_18e,4BF8h
		mov	si,ds:data_42e
		add	si,20h
		push	cs
		pop	es
		mov	di,0E000h
		mov	byte ptr ds:data_19e,0
loc_6:
		call	limg_scan_loop
		xor	bl,bl			; Zero register
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_7			; Jump if zero
		call	limg_func_4
loc_7:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_8			; Jump if zero
		call	limg_func_4
loc_8:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_9			; Jump if zero
		call	limg_func_4
loc_9:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_10			; Jump if zero
		call	limg_func_3
loc_10:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_11			; Jump if zero
		call	limg_func_3
loc_11:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_12			; Jump if zero
		call	limg_multiply
loc_12:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_13			; Jump if zero
		call	limg_func_3
loc_13:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_14			; Jump if zero
		call	limg_func_3
loc_14:
		add	word ptr ds:data_18e,4
		inc	byte ptr ds:data_19e
		cmp	byte ptr ds:data_19e,1Ch
		jne	loc_6			; Jump if not equal
		retn

zr1_10		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_scan_loop		proc	near
		cmp	byte ptr ds:data_19e,1Bh
		jne	loc_15			; Jump if not equal
		retn
loc_15:
		mov	al,byte ptr ds:[83h]
		cmp	ds:data_19e,al
		je	loc_16			; Jump if equal
		retn
loc_16:
		push	di
		push	es
		push	si
		xor	ax,ax			; Zero register
		mov	al,byte ptr ds:[83h]
		add	ax,ax
		add	ax,ax
		mov	di,ax
		add	di,data_35e
		mov	ax,0B800h
		mov	es,ax
		mov	si,data_31e
		mov	cx,2

locloop_17:
		push	cx
		push	di
		call	limg_check_state
		pop	di
		add	di,4
		pop	cx
		loop	locloop_17		; Loop if cx > 0

		pop	si
		pop	es
		pop	di
		retn
limg_scan_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_multiply		proc	near
		cmp	byte ptr [si-1],0FDh
		jne	loc_18			; Jump if not equal
		jmp	loc_51

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

limg_func_3:
loc_18:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	loc_19			; Jump if not zero
		retn
loc_19:
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
		mov	ax,0A0h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:data_18e
		mov	di,ax
		pop	dx
		mov	bl,dl
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:data_34e[bx],0FFFFh
		jnz	loc_22			; Jump if not zero
		mov	ds:data_34e[bx],di
		mov	ax,20h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,data_5e
		mov	ds,cs:data_43e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

locloop_20:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_21			; Jump if below
		add	di,data_55e
loc_21:
		loop	locloop_20		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_22:
		mov	si,ds:data_34e[bx]
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_23			; Jump if below
		add	di,data_55e
loc_23:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_24			; Jump if below
		add	si,data_55e
loc_24:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_25			; Jump if below
		add	di,data_55e
loc_25:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_26			; Jump if below
		add	si,data_55e
loc_26:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_27			; Jump if below
		add	di,data_55e
loc_27:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_28			; Jump if below
		add	si,data_55e
loc_28:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_29			; Jump if below
		add	di,data_55e
loc_29:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_30			; Jump if below
		add	si,data_55e
loc_30:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_31			; Jump if below
		add	di,data_55e
loc_31:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_32			; Jump if below
		add	si,data_55e
loc_32:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_33			; Jump if below
		add	di,data_55e
loc_33:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_34			; Jump if below
		add	si,data_55e
loc_34:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_35			; Jump if below
		add	di,data_55e
loc_35:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_36			; Jump if below
		add	si,data_55e
loc_36:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

limg_func_4:
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
		mov	es,cs:data_43e
		add	bx,es:data_3e
		mov	dh,es:[bx]
		pop	es
		pop	bx
		or	dh,dh			; Zero ?
		jnz	loc_38			; Jump if not zero
		jmp	loc_18
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
		mov	ax,0A0h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:data_18e
		mov	di,ax
		pop	dx
		mov	ax,20h
		mul	dl			; ax = reg * al
		mov	si,ax
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bp,ax
		add	si,8100h
		add	bp,data_6e
		mov	ax,60h
		mul	byte ptr ds:data_19e	; ax = data * al
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ax
		add	bx,0A000h
		mov	ds,cs:data_43e
		mov	ax,0B800h
		mov	es,ax
		cmp	dh,4
		je	loc_41			; Jump if equal
		mov	cx,8

locloop_39:
		push	cx
		mov	al,ds:[bp]
		call	limg_process_loop_6
		mov	cl,al
		mov	ax,cs:[bx]
		and	ax,dx
		or	ax,[si]
		stosw				; Store ax to es:[di]
		mov	al,cl
		call	limg_process_loop_6
		mov	ax,cs:[bx+2]
		and	ax,dx
		or	ax,[si+2]
		stosw				; Store ax to es:[di]
		inc	bp
		add	bx,4
		add	si,4
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_40			; Jump if below
		add	di,data_55e
loc_40:
		pop	cx
		loop	locloop_39		; Loop if cx > 0

		jmp	short loc_44
loc_41:
		mov	cx,8

locloop_42:
		push	cx
		mov	ax,cs:[bx]
		stosw				; Store ax to es:[di]
		mov	ax,cs:[bx+2]
		stosw				; Store ax to es:[di]
		add	bx,4
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_43			; Jump if below
		add	di,data_37e
loc_43:
		pop	cx
		loop	locloop_42		; Loop if cx > 0

loc_44:
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	ah,[di-1]
		or	ah,ah			; Zero ?
		jnz	loc_45			; Jump if not zero
		retn
loc_45:
		cmp	ah,19h
		jb	loc_46			; Jump if below
		retn
loc_46:
		push	di
		push	es
		mov	es,cs:data_43e
		mov	di,es:data_4e
		mov	cl,es:[di]
		or	cl,cl			; Zero ?
		jz	loc_49			; Jump if zero
		inc	di
loc_47:
		mov	al,es:[di]
		cmp	al,0FFh
		je	loc_49			; Jump if equal
		cmp	ah,al
		jne	loc_48			; Jump if not equal
		mov	al,es:[di+1]
		mov	[si-1],al
		jmp	short loc_49
loc_48:
		inc	di
		inc	di
		dec	cl
		jnz	loc_47			; Jump if not zero
loc_49:
		pop	es
		pop	di
		retn
		db	0BFh, 9Bh, 41h

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

limg_func_5:
		mov	cx,6

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

limg_func_6:
		push	cs
		pop	es

locloop_50:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_5e
		mov	ds,cs:data_43e
		mov	cx,10h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	ds
		pop	cx
		loop	locloop_50		; Loop if cx > 0

		retn
loc_51:
		push	ds
		push	si
		push	es
		push	di
		mov	di,data_21e
		movsw				; Mov [si] to es:[di]
		add	si,5
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dl,cs:data_19e
		add	dl,4
		xor	dh,dh			; Zero register
		add	dx,word ptr cs:[80h]
		mov	ds:data_23e,dx
		call	limg_func_8
		mov	es:data_20e,al
		cmp	byte ptr es:data_22e,0FDh
		jne	loc_52			; Jump if not equal
		inc	dx
		call	limg_func_8
		mov	es:data_22e,al
loc_52:
		mov	si,3E67h
		mov	di,425Bh
		call	limg_func_5
		mov	si,cs:data_38e
loc_53:
		call	limg_scan_loop_2
		or	bl,bl			; Zero ?
		jz	loc_54			; Jump if zero
		push	si
		push	bx
		call	limg_multiply_3
		pop	bx
		mov	es,cs:data_43e
		mov	si,data_20e
		call	limg_get_value
		pop	si
loc_54:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_53			; Jump if not zero
		pop	di
		pop	es
		mov	ch,es:[di-1]
		mov	cl,es:[di+7]
		push	es
		push	di
		push	cx
		mov	di,cs:data_18e
		add	di,640h
		push	di
		mov	si,data_32e
		mov	ax,0B800h
		mov	es,ax
		inc	ch
		jz	loc_55			; Jump if zero
		call	limg_check_state
loc_55:
		pop	di
		pop	cx
		cmp	byte ptr cs:data_19e,1Bh
		je	loc_56			; Jump if equal
		mov	si,data_33e
		add	di,4
		inc	cl
		jz	loc_56			; Jump if zero
		call	limg_check_state
loc_56:
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
limg_multiply		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_multiply_2		proc	near
		push	es
		push	ds
		mov	si,ds:data_42e
		add	si,25h
		mov	di,data_20e
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dx,word ptr ds:[80h]
		add	dx,3
		mov	ds:data_23e,dx
		cmp	byte ptr ds:data_20e,0FDh
		jne	loc_57			; Jump if not equal
		inc	dx
		call	limg_func_8
		mov	ds:data_20e,al
loc_57:
		mov	si,data_20e
		mov	di,425Bh
		mov	cx,3
		call	limg_func_6
		mov	si,cs:data_38e
loc_58:
		call	limg_scan_loop_2
		or	bl,bl			; Zero ?
		jz	loc_59			; Jump if zero
		push	si
		dec	bl
		mov	al,3
		mul	bl			; ax = reg * al
		push	ax
		call	limg_multiply_3
		pop	ax
		add	di,ax
		mov	bp,di
		mov	es,cs:data_43e
		mov	si,3E67h
		mov	di,425Bh
		call	limg_multiply_4
		pop	si
loc_59:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_58			; Jump if not zero
		mov	di,data_35e
		mov	si,data_32e
		mov	ax,0B800h
		mov	es,ax
		call	limg_check_state
		pop	ds
		pop	es
		mov	di,data_39e
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn
limg_multiply_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_func_8		proc	near
		call	limg_func_9
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_60			; Jump if equal
		retn
loc_60:
		add	si,8
		call	limg_func_10
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_60			; Jump if equal
		retn
limg_func_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_func_9		proc	near
		mov	si,ds:data_38e

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

limg_func_10:
loc_61:
		cmp	dx,[si]
		jne	loc_62			; Jump if not equal
		retn
loc_62:
		add	si,8
		jmp	short loc_61
limg_func_9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_check_state		proc	near
		mov	cx,3
loc_63:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_64			; Jump if below
		add	di,data_55e
loc_64:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_65			; Jump if below
		add	di,data_55e
loc_65:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_66			; Jump if below
		add	di,data_55e
loc_66:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_67			; Jump if below
		add	di,data_55e
loc_67:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_68			; Jump if below
		add	di,data_55e
loc_68:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_69			; Jump if below
		add	di,data_55e
loc_69:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_70			; Jump if below
		add	di,data_55e
loc_70:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_71			; Jump if below
		add	di,80A0h
loc_71:
		loop	locloop_72		; Loop if cx > 0

		jmp	short loc_ret_73

locloop_72:
		jmp	loc_63

loc_ret_73:
		retn
limg_check_state		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_get_value		proc	near
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_12e[bx]	;*
		retn
limg_get_value		endp

		db	0C6h, 35h,0BEh, 35h,0BFh, 5Bh
		db	 42h,0E8h, 70h, 00h,0EBh, 6Eh
		db	 83h,0C6h, 03h,0BFh,0BBh, 42h
		db	0EBh
		db	66h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_multiply_3		proc	near
		mov	al,[si+2]
		mov	ch,al
		and	al,7Fh
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,4000h
		mov	di,ax
		xor	dl,dl			; Zero register
		or	ch,ch			; Zero ?
		js	loc_74			; Jump if sign=1
		mov	dl,4
loc_74:
		mov	al,[si+4]
		and	al,3
		add	al,dl
		mov	cl,6
		mul	cl			; ax = reg * al
		add	di,ax
		retn
limg_multiply_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_scan_loop_2		proc	near
		mov	cx,2
		mov	dx,ds:data_23e

locloop_75:
		mov	bl,cl
		cmp	[si],dx
		jne	loc_76			; Jump if not equal
		retn
loc_76:
		inc	dx
		loop	locloop_75		; Loop if cx > 0

		mov	bl,cl
		retn
limg_scan_loop_2		endp

			                        ;* No entry point to code
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_13e[bx]	;*
		retn
			                        ;* No entry point to code
		sub	al,36h			; '6'
		and	al,36h			; '6'
		sbb	al,36h			; '6'
		add	bp,3
		mov	di,419Bh
		jmp	short loc_77
			                        ;* No entry point to code
		mov	di,419Bh
		call	limg_multiply_4
		jmp	short loc_77
			                        ;* No entry point to code
		mov	di,41FBh
		add	si,3
		jmp	short loc_77

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_multiply_4		proc	near
loc_77:
		mov	cx,3

locloop_78:
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
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		add	ax,7000h
		mov	cs:data_28e,ax
		mov	ax,cs
		add	ax,2000h
		mov	word ptr cs:data_28e+2,ax
		mov	ds,cs:data_43e
		push	cs
		pop	es
		call	limg_process_loop
		pop	bp
		pop	es
		pop	si
		pop	ds
		pop	cx
		loop	locloop_78		; Loop if cx > 0

		retn
limg_multiply_4		endp

			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,419Bh
		mov	cx,6

locloop_79:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_2e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		add	ax,8000h
		mov	cs:data_28e,ax
		mov	ax,cs
		add	ax,2000h
		mov	word ptr cs:data_28e+2,ax
		mov	ds,cs:data_43e
		call	limg_process_loop
		pop	si
		pop	ds
		pop	cx
		loop	locloop_79		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_process_loop		proc	near
		push	ds
		push	si
		push	di
		lds	si,dword ptr cs:data_28e	; Load seg:offset ptr
		mov	cx,8

locloop_80:
		push	cx
		lodsb				; String [si] to al
		call	limg_process_loop_6
		and	es:[di],dx
		call	limg_process_loop_6
		and	es:[di+2],dx
		add	di,4
		pop	cx
		loop	locloop_80		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		mov	cx,8

locloop_81:
		lodsw				; String [si] to ax
		or	es:[di],ax
		lodsw				; String [si] to ax
		or	es:[di+2],ax
		add	di,4
		loop	locloop_81		; Loop if cx > 0

		retn
limg_process_loop		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		std				; Set direction flag
		mov	si,data_51e
		mov	al,8
loc_82:
		push	si
		mov	di,si
		sub	si,4
		mov	cx,36h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	si,3Ch
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,8000h
		jb	loc_83			; Jump if below
		add	si,80A0h
loc_83:
		dec	al
		jnz	loc_82			; Jump if not zero
		mov	si,data_53e
		mov	al,8
loc_84:
		push	si
		mov	di,si
		sub	si,8
		mov	cx,34h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	si,40h
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,8000h
		jb	loc_85			; Jump if below
		add	si,80A0h
loc_85:
		dec	al
		jnz	loc_84			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		std				; Set direction flag
		mov	si,data_49e
		mov	al,10h
loc_86:
		push	si
		mov	di,si
		dec	si
		dec	si
		mov	cx,37h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	si,3Ah
		movsw				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,8000h
		jb	loc_87			; Jump if below
		add	si,80A0h
loc_87:
		dec	al
		jnz	loc_86			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	si,data_50e
		mov	al,8
loc_88:
		push	si
		mov	di,si
		add	si,4
		mov	cx,36h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,3Ch
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,8000h
		jb	loc_89			; Jump if below
		add	si,80A0h
loc_89:
		dec	al
		jnz	loc_88			; Jump if not zero
		mov	si,data_52e
		mov	al,8
loc_90:
		push	si
		mov	di,si
		add	si,8
		mov	cx,34h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,40h
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,8000h
		jb	loc_91			; Jump if below
		add	si,80A0h
loc_91:
		dec	al
		jnz	loc_90			; Jump if not zero
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	si,data_48e
		mov	al,10h
loc_92:
		push	si
		mov	di,si
		inc	si
		inc	si
		mov	cx,37h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,3Ah
		movsw				; Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,8000h
		jb	loc_93			; Jump if below
		add	si,80A0h
loc_93:
		dec	al
		jnz	loc_92			; Jump if not zero
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
		add	ax,ax
		mov	si,ax
		add	si,8000h
		add	bh,bh
		add	bh,bh
		call	extract_bits
		mov	di,ax
		mov	ds,cs:data_43e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

locloop_94:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_95			; Jump if below
		add	di,80A0h
loc_95:
		loop	locloop_94		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	si
		push	di
		push	cs
		pop	ds
		add	bh,bh
		call	extract_bits
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	si,data_14e
		mov	cx,9

locloop_96:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_97			; Jump if below
		add	di,data_37e
loc_97:
		loop	locloop_96		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		retn
		db	 00h, 00h, 00h, 00h, 0Ch,0C0h
		db	 00h, 00h, 0Ch,0CCh, 00h, 00h
		db	 0Ch,0CCh,0C0h, 00h, 0Ch,0CCh
		db	0CCh, 00h, 0Ch,0CCh,0C0h, 00h
		db	 0Ch,0CCh, 00h, 00h, 0Ch,0C0h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 02h,0FFh,0E8h, 98h, 05h, 8Bh
		db	0F8h,0BEh, 7Bh, 3Eh,0B8h, 00h
		db	0B8h, 8Eh,0C0h,0B9h, 09h, 00h

locloop_98:
		push	cx
		push	di
		push	si
		mov	cx,ds:data_46e
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,50h
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_99			; Jump if below
		add	di,80A0h
loc_99:
		pop	cx
		loop	locloop_98		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	si
		push	di
		push	di
		xor	ah,ah			; Zero register
		push	ax
		push	cs
		pop	es
		mov	di,data_30e
		xor	ax,ax			; Zero register
		mov	cx,190h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		push	ax
		add	ax,ax
		add	si,ax
		mov	si,[si]
		call	limg_func_17
		pop	ax
		pop	di
		test	byte ptr ds:data_44e,0FFh
		jz	loc_100			; Jump if zero
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	di,ax
		mov	dl,[di]
		mov	ax,[di+1]
		call	limg_process_loop_2
loc_100:
		pop	di
		pop	si
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_func_17		proc	near
		push	cs
		pop	es
		mov	di,3ECBh
		xor	bl,bl			; Zero register
loc_101:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_102			; Jump if not zero
		retn
loc_102:
		push	bx
		push	ds
		push	si
		and	bl,1
		call	limg_func_18
		pop	si
		pop	ds
		pop	bx
		inc	bl
		jmp	short loc_101
limg_func_17		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_func_18		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:data_41e
		add	bl,bl
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8
loc_103:
		push	bx
		lodsb				; String [si] to al
		call	limg_func_19
		push	ax
		call	limg_func_19
		pop	bx
		mov	bl,ah
		mov	dh,bl
		xor	dl,dl			; Zero register
		shr	bx,cl			; Shift w/zeros fill
		shr	dx,cl			; Shift w/zeros fill
		mov	dh,dl
		xor	dl,dl			; Zero register
		xchg	bh,bl
		xchg	dh,dl
		or	es:[di],bx
		or	es:[di+2],dx
		add	di,50h
		pop	bx
		dec	bl
		jnz	loc_103			; Jump if not zero
		pop	di
		inc	di
		inc	di
		cmp	cl,4
		je	loc_104			; Jump if equal
		retn
loc_104:
		inc	di
		retn
limg_func_18		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_func_19		proc	near
		xor	ah,ah			; Zero register
		mov	dl,2
loc_105:
		add	al,al
		sbb	dh,dh
		and	dh,0Fh
		add	ah,ah
		add	ah,ah
		add	ah,ah
		add	ah,ah
		or	ah,dh
		dec	dl
		jnz	loc_105			; Jump if not zero
		retn
limg_func_19		endp

			                        ;* No entry point to code
		push	dx
		push	ax
		push	cs
		pop	es
		mov	di,data_30e
		xor	ax,ax			; Zero register
		mov	cx,190h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		pop	dx
		call	limg_process_loop_4
		mov	di,3ECBh
		mov	si,3A1Fh
		mov	cx,7
		mov	bl,1
		mov	word ptr ds:data_46e,0Bh
		jmp	short locloop_106

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_process_loop_2		proc	near
		call	limg_process_loop_4
		push	cs
		pop	es
		mov	di,3ECBh
		mov	ax,ds:data_45e
		add	ax,ax
		add	di,ax
		inc	di
		mov	si,data_15e
		mov	cx,6

locloop_106:
		push	cx
		push	di
		lodsb				; String [si] to al
		push	si
		call	limg_process_loop_3
		pop	si
		pop	di
		add	di,3
		pop	cx
		loop	locloop_106		; Loop if cx > 0

		retn
limg_process_loop_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_process_loop_3		proc	near
		inc	al
		jnz	loc_107			; Jump if not zero
		retn
loc_107:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:data_40e
		mov	si,ax
		mov	cx,7

locloop_108:
		lodsb				; String [si] to al
		add	al,al
		add	al,al
		call	limg_func_19
		or	es:[di],ah
		call	limg_func_19
		or	es:[di+1],ah
		call	limg_func_19
		or	es:[di+2],ah
		add	di,50h
		loop	locloop_108		; Loop if cx > 0

		retn
limg_process_loop_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_process_loop_4		proc	near
		mov	di,3A1Fh
		call	limg_func_23
		mov	cx,6

locloop_109:
		test	byte ptr cs:[di],0FFh
		jz	loc_110			; Jump if zero
		retn
loc_110:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	locloop_109		; Loop if cx > 0

		retn
limg_process_loop_4		endp

		db	7 dup (0)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_func_23		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	limg_func_24
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	limg_func_24
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	limg_func_24
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	limg_func_25
		mov	cs:[di+3],dh
		mov	bx,64h
		call	limg_func_25
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	limg_func_25
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn
limg_func_23		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_func_24		proc	near
		xor	dh,dh			; Zero register
loc_111:
		sub	dl,cl
		jc	loc_114			; Jump if carry Set
		sub	ax,bx
		jnc	loc_112			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_113			; Jump if zero
		dec	dl
loc_112:
		inc	dh
		jmp	short loc_111
loc_113:
		add	ax,bx
loc_114:
		add	dl,cl
		retn
limg_func_24		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_func_25		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn
limg_func_25		endp

			                        ;* No entry point to code
		push	ds
		push	ax
		add	bh,bh
		add	bl,cl
		dec	bl
		call	extract_bits
		mov	di,ax
		mov	si,ax
		sub	si,2000h
		jnc	loc_115			; Jump if carry=0
		add	si,data_54e
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
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		sub	si,2000h
		jnc	loc_117			; Jump if carry=0
		add	si,data_36e
loc_117:
		sub	di,2000h
		jnc	loc_118			; Jump if carry=0
		add	di,data_54e
loc_118:
		pop	cx
		loop	locloop_116		; Loop if cx > 0

		pop	ax
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,3E7Bh
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	ax
		add	bh,bh
		call	extract_bits
		mov	di,ax
		mov	si,ax
		add	si,2000h
		cmp	si,8000h
		jb	loc_119			; Jump if below
		add	si,data_55e
loc_119:
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

locloop_120:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	si,2000h
		cmp	si,8000h
		jb	loc_121			; Jump if below
		add	si,data_37e
loc_121:
		add	di,2000h
		cmp	di,8000h
		jb	loc_122			; Jump if below
		add	di,data_55e
loc_122:
		pop	cx
		loop	locloop_120		; Loop if cx > 0

		pop	ax
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,3E7Bh
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
			                        ;* No entry point to code
		mov	ax,0B800h
		mov	es,ax
		mov	di,data_48e
		mov	cx,8

locloop_123:
		push	cx
		push	di
		mov	cx,12h

locloop_124:
		push	cx
		push	di
		mov	cx,38h
		mov	ax,0EEEEh

locloop_125:
		xor	es:[di],ax
		inc	di
		inc	di
		loop	locloop_125		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_124		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_126			; Jump if below
		add	di,80A0h
loc_126:
		pop	cx
		loop	locloop_123		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	cs:data_28e,di
		mov	word ptr cs:data_28e+2,es
		push	cx
		push	ds
		push	si
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,30h
		mul	cx			; dx:ax = reg * ax
		mov	cx,ax
		mov	di,data_47e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,data_47e

locloop_127:
		push	cx
		mov	cx,8

locloop_128:
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
		xchg	dh,dl
		mov	cs:data_24e,dx
		xchg	ch,cl
		mov	cs:data_25e,cx
		xchg	bh,bl
		mov	cs:data_26e,bx
		xchg	ah,al
		not	ax
		mov	cs:data_27e,ax
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		push	es
		push	di
		les	di,dword ptr cs:data_28e	; Load seg:offset ptr
		call	limg_scan_loop_3
		mov	al,dl
		stosb				; Store al to es:[di]
		mov	cs:data_28e,di
		pop	di
		pop	es
		pop	cx
		loop	locloop_128		; Loop if cx > 0

		pop	cx
		loop	locloop_127		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_43e
		mov	si,data_5e
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	cx,2EE0h
		mov	di,data_47e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	es,cs:data_43e
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,0
		mov	di,8100h
		mov	bx,es:data_3e
		mov	bp,0D000h
		mov	cx,0FAh

locloop_129:
		push	cx
		mov	al,es:[bx]
		cmp	al,5
		jb	loc_130			; Jump if below
		xor	al,al			; Zero register
loc_130:
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		add	bx,bx
		call	word ptr cs:data_16e[bx]	;*
		pop	bx
		inc	bx
		pop	cx
		loop	locloop_129		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		jc	loc_132			; Jump if carry Set
		movsw				; Mov [si] to es:[di]
		cmp	al,0E1h
		cmp	al,1Dh
		cmp	ax,3D59h
		mov	cx,8

locloop_131:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_24e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_25e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_26e,ax
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		mov	byte ptr es:[bp],0
		inc	bp
		pop	cx
		loop	locloop_131		; Loop if cx > 0

		retn
		db	0B9h
loc_132:
		or	[bx+si],al

locloop_133:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_24e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_25e,ax
		mov	word ptr cs:data_26e,0
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	cs:data_27e,ax
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	limg_scan_loop_3
		mov	es:[bp],dl
		inc	bp
		pop	cx
		loop	locloop_133		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_134:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_24e,ax
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	cs:data_27e,ax
		mov	word ptr cs:data_25e,0
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	cs:data_26e,ax
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	limg_scan_loop_3
		mov	es:[bp],dl
		inc	bp
		pop	cx
		loop	locloop_134		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_135:
		push	cx
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	cs:data_27e,ax
		mov	word ptr cs:data_24e,0
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_25e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_26e,ax
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	limg_scan_loop_3
		mov	es:[bp],dl
		inc	bp
		pop	cx
		loop	locloop_135		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_136:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_24e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_25e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_26e,ax
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	limg_process_loop_5
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		mov	byte ptr es:[bp],0FFh
		inc	bp
		pop	cx
		loop	locloop_136		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_process_loop_5		proc	near
		mov	cx,4

locloop_137:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_26e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_25e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_24e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_26e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_25e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_24e,1	; Rotate
		adc	bx,bx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		or	dl,cs:data_17e[bx]
		loop	locloop_137		; Loop if cx > 0

		retn
limg_process_loop_5		endp

		db	 00h, 07h, 04h, 02h, 03h, 01h
		db	 08h, 05h, 07h, 0Fh, 0Ch, 0Eh
		db	 0Bh, 09h, 0Eh, 0Dh, 04h, 0Ch
		db	 0Ch, 0Eh, 07h, 05h, 06h, 0Ch
		db	 02h, 0Eh, 0Eh, 0Ah, 0Ah, 03h
		db	 0Ah, 07h, 03h, 0Bh, 07h, 0Ah
		db	 0Bh, 09h, 0Ah, 09h, 01h, 09h
		db	 05h, 03h, 09h, 09h, 07h, 05h
		db	 08h, 0Eh, 06h, 0Ah, 0Ah, 07h
		db	 0Eh, 0Ch, 05h, 0Dh, 0Ch, 07h
		db	 09h, 05h
		db	 0Ch, 0Dh

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_scan_loop_3		proc	near
		mov	cx,8

locloop_138:
		xor	al,al			; Zero register
		rol	word ptr cs:data_27e,1	; Rotate
		adc	al,al
		rol	word ptr cs:data_27e,1	; Rotate
		adc	al,al
		cmp	al,3
		je	loc_139			; Jump if equal
		xor	al,al			; Zero register
loc_139:
		and	al,1
		add	dl,dl
		or	dl,al
		loop	locloop_138		; Loop if cx > 0

		retn
limg_scan_loop_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

extract_bits		proc	near
		mov	dh,bl
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		mov	ax,0A0h
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		mul	bl			; ax = reg * al
		add	ax,dx
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		retn
extract_bits		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

limg_process_loop_6		proc	near
		mov	cx,4

locloop_140:
		add	al,al
		sbb	ah,ah
		and	ah,0Fh
		add	dx,dx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		or	dl,ah
		loop	locloop_140		; Loop if cx > 0

		xchg	dh,dl
		retn
limg_process_loop_6		endp

		db	1719 dup (0)

seg_a		ends



		end	start
