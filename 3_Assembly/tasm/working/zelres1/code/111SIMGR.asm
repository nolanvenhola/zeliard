
PAGE  59,132

;==========================================================================
;
;  SMALL_IMAGE_RENDERER - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	8000h			;*
data_2e		equ	8004h			;*
data_3e		equ	8100h			;*
data_4e		equ	0D000h			;*
data_12e	equ	34D8h			;*
data_13e	equ	3534h			;*
data_14e	equ	37C3h			;*
data_15e	equ	392Ah			;*
data_16e	equ	3B4Bh			;*
data_17e	equ	3C98h			;*
data_18e	equ	3C9Ah			;*
data_19e	equ	3C9Bh			;*
data_20e	equ	3C9Eh			;*
data_21e	equ	3CA1h			;*
data_22e	equ	3CA3h			;*
data_23e	equ	3CA5h			;*
data_24e	equ	3CA7h			;*
data_25e	equ	3CA9h			;*
data_26e	equ	3CABh			;*
data_28e	equ	3CAFh			;*
data_29e	equ	3D4Fh			;*
data_30e	equ	3DEFh			;*
data_31e	equ	4100h			;*
data_32e	equ	42EFh			;*
data_33e	equ	6000h			;*
data_34e	equ	0A000h			;*
data_35e	equ	0C00Fh			;*
data_36e	equ	0E005h			;*
data_37e	equ	0F502h			;*
data_38e	equ	0F504h			;*
data_39e	equ	0FF2Ah			;*
data_40e	equ	0FF2Ch			;*
data_41e	equ	0FF57h			;*
data_42e	equ	0FF68h			;*
data_43e	equ	0FF6Ah			;*
data_44e	equ	0			;*
data_45e	equ	80h
data_46e	equ	138h
data_47e	equ	140h
data_48e	equ	11B0h
data_49e	equ	128Eh
data_50e	equ	3200h
data_51e	equ	3C9Ch
data_52e	equ	93B0h
data_53e	equ	0B1B0h
data_54e	equ	0B28Eh
data_55e	equ	0BBB0h
data_56e	equ	0BC8Eh
data_57e	equ	0FA00h
data_58e	equ	0FAC0h
data_59e	equ	0FB80h
data_60e	equ	0FC40h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_11		proc	far

start:
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		adc	al,0
		add	[bx+di+3Ah],al
		sub	[bx+si],dh
		push	cx
		xor	[bx+si],ch
		db	 36h, 77h, 36h,0A4h, 36h,0F1h
		db	 36h,0FCh, 32h, 26h, 35h, 9Ah
		db	 35h,0ECh, 34h, 1Ch, 37h, 85h
		db	 37h, 05h, 38h,0CCh, 37h, 99h
		db	 39h,0EFh, 39h, 8Eh, 38h,0F9h
		db	 3Ah, 71h, 3Ah, 1Eh,0BEh,0B0h
		db	 61h,0BFh, 00h,0A0h, 0Eh, 07h
		db	0B8h, 00h,0A0h, 8Eh,0D8h,0B9h
		db	 1Ch, 00h

locloop_1:
		push	cx
		push	si
		mov	cx,18h

locloop_2:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	si,138h
		loop	locloop_2		; Loop if cx > 0

		pop	si
		pop	cx
		add	si,8
		loop	locloop_1		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_32e
		xor	ax,ax			; Zero register
		mov	cx,100h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,ds:data_39e
		cmp	byte ptr [si+1Dh],0FDh
		jne	loc_3			; Jump if not equal
		call	simg_multiply_2
loc_3:
		mov	word ptr ds:data_17e,61B0h
		mov	si,ds:data_39e
		add	si,20h
		push	cs
		pop	es
		mov	di,0E000h
		mov	byte ptr ds:data_18e,0
loc_4:
		call	vga_operation
		xor	bl,bl			; Zero register
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_5			; Jump if zero
		call	simg_func_4
loc_5:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_6			; Jump if zero
		call	simg_func_4
loc_6:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_7			; Jump if zero
		call	simg_func_4
loc_7:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_8			; Jump if zero
		call	simg_func_3
loc_8:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_9			; Jump if zero
		call	simg_func_3
loc_9:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_10			; Jump if zero
		call	simg_multiply
loc_10:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_11			; Jump if zero
		call	simg_func_3
loc_11:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_12			; Jump if zero
		call	simg_func_3
loc_12:
		add	word ptr ds:data_17e,8
		inc	byte ptr ds:data_18e
		cmp	byte ptr ds:data_18e,1Ch
		jne	loc_4			; Jump if not equal
		retn

zr1_11		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation		proc	near
		cmp	byte ptr ds:data_18e,1Bh
		jne	loc_13			; Jump if not equal
		retn
loc_13:
		mov	al,byte ptr ds:[83h]
		cmp	ds:data_18e,al
		je	loc_14			; Jump if equal
		retn
loc_14:
		push	di
		push	es
		push	si
		push	ds
		mov	al,byte ptr ds:[83h]
		add	al,al
		add	al,al
		add	al,al
		xor	ah,ah			; Zero register
		mov	di,ax
		add	di,data_52e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,data_57e
		mov	cx,2

locloop_15:
		push	cx
		push	di
		call	vga_operation1
		pop	di
		add	di,8
		pop	cx
		loop	locloop_15		; Loop if cx > 0

		pop	ds
		pop	si
		pop	es
		pop	di
		retn
vga_operation		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_multiply		proc	near
		cmp	byte ptr [si-1],0FDh
		jne	loc_16			; Jump if not equal
		jmp	loc_37

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

simg_func_3:
loc_16:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	loc_17			; Jump if not zero
		retn
loc_17:
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
		add	bx,bx
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:data_17e
		mov	di,ax
		pop	dx
		mov	bl,dl
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:data_32e[bx],0FFFFh
		jnz	loc_20			; Jump if not zero
		mov	ds:data_32e[bx],di
		mov	ax,30h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,data_3e
		mov	ds,cs:data_40e
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

locloop_18:
		push	cx
		mov	cx,2

locloop_19:
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsb				; String [si] to al
		mov	bl,al
		mov	bh,dl
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		mov	es:[di],dh
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		mov	es:[di+1],dl
		add	bx,bx
		add	bx,bx
		and	bh,3Fh			; '?'
		mov	es:[di+2],bh
		and	al,3Fh			; '?'
		mov	es:[di+3],al
		add	di,4
		loop	locloop_19		; Loop if cx > 0

		add	di,data_46e
		pop	cx
		loop	locloop_18		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_20:
		mov	si,ds:data_32e[bx]
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	cx,8

locloop_21:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,138h
		add	si,138h
		loop	locloop_21		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

simg_func_4:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	loc_22			; Jump if not zero
		retn
loc_22:
		push	bx
		push	es
		mov	dl,[si-1]
		mov	bl,dl
		xor	bh,bh			; Zero register
		mov	es,cs:data_40e
		add	bx,es:data_1e
		mov	dh,es:[bx]
		pop	es
		pop	bx
		or	dh,dh			; Zero ?
		jnz	loc_23			; Jump if not zero
		jmp	loc_16
loc_23:
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
		add	bx,bx
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:data_17e
		mov	di,ax
		pop	dx
		mov	ax,8
		mul	dl			; ax = reg * al
		mov	bp,ax
		mov	ax,30h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,data_3e
		add	bp,data_4e
		mov	ax,0C0h
		mul	byte ptr ds:data_18e	; ax = data * al
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ax
		add	bx,data_34e
		mov	ds,cs:data_40e
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

locloop_24:
		push	cx
		mov	ah,ds:[bp]
		inc	bp
		mov	cx,2

locloop_25:
		push	cx
		lodsb				; String [si] to al
		mov	dl,al
		lodsb				; String [si] to al
		mov	dh,al
		lodsb				; String [si] to al
		mov	cl,al
		mov	ch,dl
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		add	ah,ah
		jnc	loc_26			; Jump if carry=0
		mov	dh,cs:[bx]
loc_26:
		inc	bx
		mov	es:[di],dh
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		add	ah,ah
		jnc	loc_27			; Jump if carry=0
		mov	dl,cs:[bx]
loc_27:
		inc	bx
		mov	es:[di+1],dl
		add	cx,cx
		add	cx,cx
		and	ch,3Fh			; '?'
		add	ah,ah
		jnc	loc_28			; Jump if carry=0
		mov	ch,cs:[bx]
loc_28:
		inc	bx
		mov	es:[di+2],ch
		and	al,3Fh			; '?'
		add	ah,ah
		jnc	loc_29			; Jump if carry=0
		mov	al,cs:[bx]
loc_29:
		inc	bx
		mov	es:[di+3],al
		add	di,4
		pop	cx
		loop	locloop_25		; Loop if cx > 0

		pop	cx
		add	di,138h
		loop	locloop_24		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	ah,[di-1]
		or	ah,ah			; Zero ?
		jnz	loc_30			; Jump if not zero
		retn
loc_30:
		cmp	ah,19h
		jb	loc_31			; Jump if below
		retn
loc_31:
		push	di
		push	es
		mov	es,cs:data_40e
		mov	di,es:data_2e
		mov	cl,es:[di]
		or	cl,cl			; Zero ?
		jz	loc_34			; Jump if zero
		inc	di
loc_32:
		mov	al,es:[di]
		cmp	al,0FFh
		je	loc_34			; Jump if equal
		cmp	ah,al
		jne	loc_33			; Jump if not equal
		mov	al,es:[di+1]
		mov	[si-1],al
		jmp	short loc_34
loc_33:
		inc	di
		inc	di
		dec	cl
		jnz	loc_32			; Jump if not zero
loc_34:
		pop	es
		pop	di
		retn
		db	0BFh, 00h,0FAh

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

simg_func_5:
		mov	cx,6

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

simg_func_6:
		mov	ax,0A000h
		mov	es,ax

locloop_35:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_3e
		mov	ds,cs:data_40e
		mov	cx,10h

locloop_36:
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsb				; String [si] to al
		mov	bl,al
		mov	bh,dl
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		mov	es:[di],dh
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		mov	es:[di+1],dl
		add	bx,bx
		add	bx,bx
		and	bh,3Fh			; '?'
		mov	es:[di+2],bh
		and	al,3Fh			; '?'
		mov	es:[di+3],al
		add	di,4
		loop	locloop_36		; Loop if cx > 0

		pop	si
		pop	ds
		pop	cx
		loop	locloop_35		; Loop if cx > 0

		retn
loc_37:
		push	ds
		push	si
		push	es
		push	di
		mov	di,data_51e
		movsw				; Mov [si] to es:[di]
		add	si,5
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dl,cs:data_18e
		add	dl,4
		xor	dh,dh			; Zero register
		add	dx,word ptr cs:[80h]
		mov	ds:data_21e,dx
		call	simg_func_8
		mov	es:data_19e,al
		cmp	byte ptr es:data_20e,0FDh
		jne	loc_38			; Jump if not equal
		inc	dx
		call	simg_func_8
		mov	es:data_20e,al
loc_38:
		mov	si,3C9Bh
		mov	di,0FB80h
		call	simg_func_5
		mov	si,cs:data_35e
loc_39:
		call	vga_operation4
		or	bl,bl			; Zero ?
		jz	loc_40			; Jump if zero
		push	si
		push	bx
		call	vga_operation3
		pop	bx
		mov	es,cs:data_40e
		mov	si,data_19e
		call	vga_operation2
		pop	si
loc_40:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_39			; Jump if not zero
		pop	di
		pop	es
		mov	ch,es:[di-1]
		mov	cl,es:[di+7]
		push	es
		push	di
		push	cx
		mov	di,cs:data_17e
		add	di,data_50e
		push	di
		mov	si,data_59e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		inc	ch
		jz	loc_41			; Jump if zero
		call	vga_operation1
loc_41:
		pop	di
		pop	cx
		cmp	byte ptr cs:data_18e,1Bh
		je	loc_42			; Jump if equal
		mov	si,data_60e
		add	di,8
		inc	cl
		jz	loc_42			; Jump if zero
		call	vga_operation1
loc_42:
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
simg_multiply		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_multiply_2		proc	near
		push	es
		push	ds
		mov	si,ds:data_39e
		add	si,25h
		mov	di,data_19e
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dx,word ptr ds:[80h]
		add	dx,3
		mov	ds:data_21e,dx
		cmp	byte ptr ds:data_19e,0FDh
		jne	loc_43			; Jump if not equal
		inc	dx
		call	simg_func_8
		mov	ds:data_19e,al
loc_43:
		mov	si,3C9Bh
		mov	di,0FB80h
		mov	cx,3
		call	simg_func_6
		mov	si,cs:data_35e
loc_44:
		call	vga_operation4
		or	bl,bl			; Zero ?
		jz	loc_45			; Jump if zero
		push	si
		dec	bl
		mov	al,3
		mul	bl			; ax = reg * al
		push	ax
		call	vga_operation3
		pop	ax
		add	di,ax
		mov	bp,di
		mov	es,cs:data_40e
		mov	si,3C9Bh
		mov	di,0FB80h
		call	vga_operation_2
		pop	si
loc_45:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_44			; Jump if not zero
		mov	di,data_52e
		mov	si,data_59e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		call	vga_operation1
		pop	ds
		pop	es
		mov	di,data_36e
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn
simg_multiply_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_func_8		proc	near
		call	simg_func_9
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_46			; Jump if equal
		retn
loc_46:
		add	si,8
		call	vga_operation0
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_46			; Jump if equal
		retn
simg_func_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_func_9		proc	near
		mov	si,ds:data_35e

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vga_operation0:
loc_47:
		cmp	dx,[si]
		jne	loc_48			; Jump if not equal
		retn
loc_48:
		add	si,8
		jmp	short loc_47
simg_func_9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation1		proc	near
		mov	cx,18h

locloop_49:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,138h
		loop	locloop_49		; Loop if cx > 0

		retn
vga_operation1		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation2		proc	near
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_12e[bx]	;*
		retn
vga_operation2		endp

			                        ;* No entry point to code
		in	al,34h			; port 34h ??I/O Non-standard
		db	0DCh, 34h,0BFh, 80h,0FBh,0E8h
		db	 70h, 00h,0EBh, 6Eh, 83h,0C6h
		db	 03h,0BFh, 40h,0FCh,0EBh
		db	66h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation3		proc	near
		mov	al,[si+2]
		mov	ch,al
		and	al,7Fh
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,4000h
		mov	di,ax
		xor	dl,dl			; Zero register
		or	ch,ch			; Zero ?
		js	loc_50			; Jump if sign=1
		mov	dl,4
loc_50:
		mov	al,[si+4]
		and	al,3
		add	al,dl
		mov	cl,6
		mul	cl			; ax = reg * al
		add	di,ax
		retn
vga_operation3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation4		proc	near
		mov	cx,2
		mov	dx,ds:data_21e

locloop_51:
		mov	bl,cl
		cmp	[si],dx
		jne	loc_52			; Jump if not equal
		retn
loc_52:
		inc	dx
		loop	locloop_51		; Loop if cx > 0

		mov	bl,cl
		retn
vga_operation4		endp

			                        ;* No entry point to code
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_13e[bx]	;*
		retn
			                        ;* No entry point to code
		dec	dx
		xor	ax,3542h
		cmp	dh,[di]
		add	bp,3
		mov	di,0FA00h
		jmp	short loc_53
			                        ;* No entry point to code
		mov	di,0FA00h
		call	vga_operation_2
		jmp	short loc_53
			                        ;* No entry point to code
		mov	di,data_58e
		add	si,3
		jmp	short loc_53

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation_2		proc	near
loc_53:
		mov	cx,3

locloop_54:
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
		push	ax
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_31e
		pop	ax
		mov	cl,8
		mul	cl			; ax = reg * al
		add	ax,7000h
		mov	cs:data_26e,ax
		mov	ax,cs
		add	ax,2000h
		mov	word ptr cs:data_26e+2,ax
		mov	ds,cs:data_40e
		mov	ax,0A000h
		mov	es,ax
		call	vga_operation6
		pop	bp
		pop	es
		pop	si
		pop	ds
		pop	cx
		loop	locloop_54		; Loop if cx > 0

		retn
vga_operation_2		endp

			                        ;* No entry point to code
		mov	di,data_57e
		mov	cx,6

locloop_55:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		push	ax
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_33e
		pop	ax
		mov	cl,8
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	cs:data_26e,ax
		mov	ax,cs
		add	ax,2000h
		mov	word ptr cs:data_26e+2,ax
		mov	ds,cs:data_40e
		mov	ax,0A000h
		mov	es,ax
		call	vga_operation6
		pop	si
		pop	ds
		pop	cx
		loop	locloop_55		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation6		proc	near
		push	ds
		push	si
		push	di
		lds	si,dword ptr cs:data_26e	; Load seg:offset ptr
		mov	cx,8

locloop_56:
		push	cx
		lodsb				; String [si] to al
		mov	cx,8

locloop_57:
		add	al,al
		sbb	ah,ah
		and	es:[di],ah
		inc	di
		loop	locloop_57		; Loop if cx > 0

		pop	cx
		loop	locloop_56		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		mov	cx,10h

locloop_58:
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsb				; String [si] to al
		mov	bl,al
		mov	bh,dl
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		or	es:[di],dh
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		or	es:[di+1],dl
		add	bx,bx
		add	bx,bx
		and	bh,3Fh			; '?'
		or	es:[di+2],bh
		and	al,3Fh			; '?'
		or	es:[di+3],al
		add	di,4
		loop	locloop_58		; Loop if cx > 0

		retn
vga_operation6		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		std				; Set direction flag
		mov	si,data_54e
		mov	al,8
loc_59:
		push	si
		mov	di,si
		sub	si,8
		mov	cx,6Ch
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	si,78h
		mov	cx,4
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,140h
		dec	al
		jnz	loc_59			; Jump if not zero
		mov	si,data_56e
		mov	al,8
loc_60:
		push	si
		mov	di,si
		sub	si,10h
		mov	cx,68h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	si,data_45e
		mov	cx,8
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,140h
		dec	al
		jnz	loc_60			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		std				; Set direction flag
		mov	si,data_49e
		mov	al,10h
loc_61:
		push	si
		mov	di,si
		sub	si,4
		mov	cx,6Eh
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	si,74h
		mov	cx,2
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,140h
		dec	al
		jnz	loc_61			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,data_53e
		mov	al,8
loc_62:
		push	si
		mov	di,si
		add	si,8
		mov	cx,6Ch
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,78h
		mov	cx,4
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,140h
		dec	al
		jnz	loc_62			; Jump if not zero
		mov	si,data_55e
		mov	al,8
loc_63:
		push	si
		mov	di,si
		add	si,10h
		mov	cx,68h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,80h
		mov	cx,8
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,140h
		dec	al
		jnz	loc_63			; Jump if not zero
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,data_48e
		mov	al,10h
loc_64:
		push	si
		mov	di,si
		add	si,4
		mov	cx,6Eh
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,74h
		mov	cx,2
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,140h
		dec	al
		jnz	loc_64			; Jump if not zero
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	si
		mov	dl,30h			; '0'
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,di
		add	di,ax
		mov	ds,cs:data_40e
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

locloop_65:
		push	cx
		mov	cx,2

locloop_66:
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsb				; String [si] to al
		mov	bl,al
		mov	bh,dl
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		mov	es:[di],dh
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		mov	es:[di+1],dl
		add	bx,bx
		add	bx,bx
		and	bh,3Fh			; '?'
		mov	es:[di+2],bh
		and	al,3Fh			; '?'
		mov	es:[di+3],al
		add	di,4
		loop	locloop_66		; Loop if cx > 0

		add	di,data_46e
		pop	cx
		loop	locloop_65		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	si
		push	di
		push	cs
		pop	ds
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	si,data_14e
		mov	cx,9

locloop_67:
		push	cx
		lodsb				; String [si] to al
		mov	ah,al
		mov	cx,8

locloop_68:
		add	ah,ah
		sbb	al,al
		and	al,12h
		stosb				; Store al to es:[di]
		loop	locloop_68		; Loop if cx > 0

		add	di,138h
		pop	cx
		loop	locloop_67		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		retn
		db	 00h, 60h, 70h, 78h, 7Ch, 78h
		db	 70h, 60h, 00h, 33h,0C0h, 8Ah
		db	0C7h, 8Ah,0FCh, 50h,0B8h, 40h
		db	 01h,0F7h,0E3h, 5Fh, 03h,0FFh
		db	 03h,0FFh, 03h,0F8h,0BEh,0AFh
		db	 3Ch,0B8h, 00h,0A0h, 8Eh,0C0h
		db	0B9h, 09h, 00h

locloop_69:
		push	cx
		push	di
		push	si
		mov	cx,ds:data_43e
		add	cx,cx
		add	cx,cx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,0A0h
		pop	di
		add	di,140h
		pop	cx
		loop	locloop_69		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	si
		push	di
		push	di
		xor	ah,ah			; Zero register
		push	ax
		push	cs
		pop	es
		mov	di,data_28e
		xor	ax,ax			; Zero register
		mov	cx,320h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		push	ax
		add	ax,ax
		add	si,ax
		mov	si,[si]
		call	vga_operation7
		pop	ax
		pop	di
		test	byte ptr ds:data_41e,0FFh
		jz	loc_70			; Jump if zero
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	di,ax
		mov	dl,[di]
		mov	ax,[di+1]
		call	vga_operation9
loc_70:
		pop	di
		pop	si
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation7		proc	near
		push	cs
		pop	es
		mov	di,data_29e
		xor	bl,bl			; Zero register
loc_71:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_72			; Jump if not zero
		retn
loc_72:
		push	ds
		push	si
		call	extract_bits
		pop	si
		pop	ds
		jmp	short loc_71
vga_operation7		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

extract_bits		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:data_38e
		push	di
		mov	bl,8
loc_73:
		push	bx
		lodsb				; String [si] to al
		push	di
		mov	dh,al
		mov	dl,4
loc_74:
		add	dh,dh
		sbb	bl,bl
		and	bl,9
		mov	es:[di],bl
		inc	di
		dec	dl
		jnz	loc_74			; Jump if not zero
		pop	di
		add	di,0A0h
		pop	bx
		dec	bl
		jnz	loc_73			; Jump if not zero
		pop	di
		add	di,5
		retn
extract_bits		endp

			                        ;* No entry point to code
		push	dx
		push	ax
		push	cs
		pop	es
		mov	di,data_28e
		xor	ax,ax			; Zero register
		mov	cx,320h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		pop	dx
		call	simg_process_loop_2
		mov	di,3DEFh
		mov	si,3929h
		mov	cx,7
		mov	bl,1
		mov	word ptr ds:data_43e,0Bh
		jmp	short locloop_75

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation9		proc	near
		call	simg_process_loop_2
		push	cs
		pop	es
		mov	di,data_30e
		mov	ax,ds:data_42e
		add	ax,ax
		add	ax,ax
		add	di,ax
		mov	si,data_15e
		mov	cx,6

locloop_75:
		push	cx
		push	di
		lodsb				; String [si] to al
		push	si
		call	simg_process_loop
		pop	si
		pop	di
		add	di,6
		pop	cx
		loop	locloop_75		; Loop if cx > 0

		retn
vga_operation9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_process_loop		proc	near
		inc	al
		jnz	loc_76			; Jump if not zero
		retn
loc_76:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:data_37e
		mov	si,ax
		mov	cx,7

locloop_77:
		lodsb				; String [si] to al
		add	al,al
		add	al,al
		mov	ah,6
loc_78:
		add	al,al
		sbb	bl,bl
		and	bl,9
		mov	es:[di],bl
		inc	di
		dec	ah
		jnz	loc_78			; Jump if not zero
		add	di,9Ah
		loop	locloop_77		; Loop if cx > 0

		retn
simg_process_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_process_loop_2		proc	near
		mov	di,3929h
		call	simg_func_22
		mov	cx,6

locloop_79:
		test	byte ptr cs:[di],0FFh
		jz	loc_80			; Jump if zero
		retn
loc_80:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	locloop_79		; Loop if cx > 0

		retn
simg_process_loop_2		endp

		db	7 dup (0)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_func_22		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	simg_func_23
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	simg_func_23
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	simg_func_23
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	simg_func_24
		mov	cs:[di+3],dh
		mov	bx,64h
		call	simg_func_24
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	simg_func_24
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn
simg_func_22		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_func_23		proc	near
		xor	dh,dh			; Zero register
loc_81:
		sub	dl,cl
		jc	loc_84			; Jump if carry Set
		sub	ax,bx
		jnc	loc_82			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_83			; Jump if zero
		dec	dl
loc_82:
		inc	dh
		jmp	short loc_81
loc_83:
		add	ax,bx
loc_84:
		add	dl,cl
		retn
simg_func_23		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_func_24		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn
simg_func_24		endp

			                        ;* No entry point to code
		push	ds
		push	ax
		add	bl,cl
		dec	bl
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		mov	si,di
		sub	si,140h
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_85:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		sub	si,140h
		sub	di,140h
		pop	cx
		loop	locloop_85		; Loop if cx > 0

		pop	ax
		mov	dl,0A0h
		mul	dl			; ax = reg * al
		add	ax,3CAFh
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
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		mov	si,di
		add	si,data_47e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_86:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	si,140h
		add	di,data_47e
		pop	cx
		loop	locloop_86		; Loop if cx > 0

		pop	ax
		mov	dl,0A0h
		mul	dl			; ax = reg * al
		add	ax,3CAFh
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
			                        ;* No entry point to code
		mov	ax,0A000h
		mov	es,ax
		mov	di,data_48e
		mov	cx,8

locloop_87:
		push	cx
		push	di
		mov	cx,12h

locloop_88:
		push	cx
		push	di
		mov	ax,3636h
		mov	cx,70h

locloop_89:
		xor	es:[di],ax
		inc	di
		inc	di
		loop	locloop_89		; Loop if cx > 0

		pop	di
		add	di,0A00h
		pop	cx
		loop	locloop_88		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_87		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	cs:data_26e,di
		mov	word ptr cs:data_26e+2,es
		push	cx
		push	ds
		push	si
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,30h
		mul	cx			; dx:ax = reg * ax
		mov	cx,ax
		mov	di,data_44e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,data_44e

locloop_90:
		push	cx
		mov	cx,8

locloop_91:
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
		mov	cs:data_22e,dx
		xchg	ch,cl
		mov	cs:data_23e,cx
		xchg	bh,bl
		mov	cs:data_24e,bx
		xchg	ah,al
		not	ax
		mov	cs:data_25e,ax
		call	simg_process_loop_3
		push	es
		push	di
		les	di,dword ptr cs:data_26e	; Load seg:offset ptr
		call	simg_scan_loop
		mov	al,dl
		stosb				; Store al to es:[di]
		mov	cs:data_26e,di
		pop	di
		pop	es
		pop	cx
		loop	locloop_91		; Loop if cx > 0

		pop	cx
		loop	locloop_90		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_40e
		mov	si,data_3e
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	cx,2EE0h
		mov	di,data_44e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	es,cs:data_40e
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,0
		mov	di,8100h
		mov	bx,es:data_1e
		mov	bp,0D000h
		mov	cx,0FAh

locloop_92:
		push	cx
		mov	al,es:[bx]
		cmp	al,5
		jb	loc_93			; Jump if below
		xor	al,al			; Zero register
loc_93:
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		add	bx,bx
		call	word ptr cs:data_16e[bx]	;*
		pop	bx
		inc	bx
		pop	cx
		loop	locloop_92		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	bp
		cmp	di,[bp+di+3Bh]
		stosb				; Store al to es:[di]
		cmp	bx,cx
		cmp	cx,[bx+si]
		cmp	al,0B9h
		or	[bx+si],al

locloop_94:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_22e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_23e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_24e,ax
		call	simg_process_loop_3
		mov	byte ptr es:[bp],0
		inc	bp
		pop	cx
		loop	locloop_94		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_95:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_22e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_23e,ax
		mov	word ptr cs:data_24e,0
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_25e,ax
		call	simg_process_loop_3
		call	simg_scan_loop
		mov	es:[bp],dl
		inc	bp
		pop	cx
		loop	locloop_95		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_96:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_22e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_25e,ax
		mov	word ptr cs:data_23e,0
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_24e,ax
		call	simg_process_loop_3
		call	simg_scan_loop
		mov	es:[bp],dl
		inc	bp
		pop	cx
		loop	locloop_96		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_97:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_25e,ax
		mov	word ptr cs:data_22e,0
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	cs:data_23e,ax
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	cs:data_24e,ax
		call	simg_process_loop_3
		call	simg_scan_loop
		mov	es:[bp],dl
		inc	bp
		pop	cx
		loop	locloop_97		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_98:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_22e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_23e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_24e,ax
		call	simg_process_loop_3
		mov	byte ptr es:[bp],0FFh
		inc	bp
		pop	cx
		loop	locloop_98		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_process_loop_3		proc	near
		mov	cx,2

locloop_99:
		call	simg_func_26
		call	simg_func_26
		call	simg_func_26
		call	simg_func_26
		call	simg_func_26
		rol	word ptr cs:data_24e,1	; Rotate
		adc	ax,ax
		stosw				; Store ax to es:[di]
		rol	word ptr cs:data_23e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_22e,1	; Rotate
		adc	ax,ax
		call	simg_func_26
		call	simg_func_26
		stosb				; Store al to es:[di]
		loop	locloop_99		; Loop if cx > 0

		retn
simg_process_loop_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_func_26		proc	near
		rol	word ptr cs:data_24e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_23e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_22e,1	; Rotate
		adc	ax,ax
		retn
simg_func_26		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

simg_scan_loop		proc	near
		mov	cx,8

locloop_100:
		xor	al,al			; Zero register
		rol	word ptr cs:data_25e,1	; Rotate
		adc	al,al
		rol	word ptr cs:data_25e,1	; Rotate
		adc	al,al
		cmp	al,3
		je	loc_101			; Jump if equal
		xor	al,al			; Zero register
loc_101:
		and	al,1
		add	dl,dl
		or	dl,al
		loop	locloop_100		; Loop if cx > 0

		retn
simg_scan_loop		endp

		db	2135 dup (0)

seg_a		ends



		end	start
