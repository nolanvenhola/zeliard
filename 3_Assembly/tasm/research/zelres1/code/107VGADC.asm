
PAGE  59,132

;==========================================================================
;
;  VGA_DECOMPRESSOR - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	4Eh
data_2e		equ	8000h			;*
data_3e		equ	8004h			;*
data_4e		equ	8100h			;*
data_10e	equ	32EBh			;*
data_11e	equ	35BEh			;*
data_12e	equ	361Ah			;*
data_13e	equ	3628h			;*
data_14e	equ	38B9h			;*
data_15e	equ	3A32h			;*
data_16e	equ	3BB1h			;*
data_17e	equ	3BB3h			;*
data_18e	equ	3BB4h			;*
data_19e	equ	3BB7h			;*
data_20e	equ	3BBAh			;*
data_21e	equ	3BBCh			;*
data_22e	equ	3BE4h			;*
data_23e	equ	3D4Ch			;*
data_24e	equ	3E80h			;*
data_25e	equ	0C00Fh			;*
data_26e	equ	0C583h			;*
data_27e	equ	0E005h			;*
data_28e	equ	0F502h			;*
data_29e	equ	0F504h			;*
data_30e	equ	0FF2Ah			;*
data_31e	equ	0FF2Ch			;*
data_32e	equ	0FF57h			;*
data_33e	equ	0FF68h			;*
data_34e	equ	0FF6Ah			;*
data_35e	equ	46Ch
data_36e	equ	4A3h
data_37e	equ	0C80h
data_38e	equ	24ECh
data_39e	equ	2C6Ch
data_40e	equ	2CA3h
data_41e	equ	2EECh
data_42e	equ	2F23h
data_43e	equ	3BB5h
data_44e	equ	3E80h
data_45e	equ	3EB0h
data_46e	equ	3EE0h
data_47e	equ	3F10h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_07		proc	far

start:
		dec	sp
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bx+si],al
		db	'f;(0\0&7'
		db	 7Fh, 37h,0B7h, 37h, 0Eh, 38h
		db	0B6h, 33h, 0Ch, 36h, 69h, 36h
		db	0D2h, 35h, 44h, 38h, 8Ch, 38h
		db	0FEh, 38h,0CBh, 38h,0A1h, 3Ah
		db	 09h, 3Bh, 8Eh, 39h,0B0h, 3Bh
		db	0B0h, 3Bh, 1Eh,0BEh, 6Ch, 18h
		db	0BFh, 00h,0A0h, 0Eh, 07h,0B8h
		db	 00h,0A0h, 8Eh,0D8h,0BAh,0CEh
		db	 03h,0B0h, 04h,0EEh, 42h,0B9h
		db	 1Ch, 00h

locloop_1:
		push	cx
		push	si
		mov	cx,18h

locloop_2:
		mov	al,0
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		movsw				; Mov [si] to es:[di]
		dec	si
		dec	si
		mov	al,2
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		movsw				; Mov [si] to es:[di]
		add	si,4Eh
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
		mov	di,data_23e
		xor	ax,ax			; Zero register
		mov	cx,100h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,ds:data_30e
		cmp	byte ptr [si+1Dh],0FDh
		jne	loc_3			; Jump if not equal
		call	vgadec_multiply_2
loc_3:
		mov	word ptr ds:data_16e,186Ch
		mov	si,ds:data_30e
		add	si,20h
		push	cs
		pop	es
		mov	di,0E000h
		mov	byte ptr ds:data_17e,0
loc_4:
		call	vga_operation
		xor	bl,bl			; Zero register
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_5			; Jump if zero
		call	vgadec_func_4
loc_5:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_6			; Jump if zero
		call	vgadec_func_4
loc_6:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_7			; Jump if zero
		call	vgadec_func_4
loc_7:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_8			; Jump if zero
		call	vgadec_func_3
loc_8:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_9			; Jump if zero
		call	vgadec_func_3
loc_9:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_10			; Jump if zero
		call	vgadec_multiply
loc_10:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_11			; Jump if zero
		call	vgadec_func_3
loc_11:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_12			; Jump if zero
		call	vgadec_func_3
loc_12:
		add	word ptr ds:data_16e,2
		inc	byte ptr ds:data_17e
		cmp	byte ptr ds:data_17e,1Ch
		jne	loc_4			; Jump if not equal
		retn

zr1_07		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation		proc	near
		cmp	byte ptr ds:data_17e,1Bh
		jne	loc_13			; Jump if not equal
		retn
loc_13:
		mov	al,byte ptr ds:[83h]
		cmp	ds:data_17e,al
		je	loc_14			; Jump if equal
		retn
loc_14:
		push	di
		push	es
		push	si
		push	ds
		mov	al,byte ptr ds:[83h]
		add	al,al
		xor	ah,ah			; Zero register
		mov	di,ax
		add	di,data_38e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,data_44e
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,2

locloop_15:
		push	cx
		call	vga_operation1
		add	di,0F882h
		pop	cx
		loop	locloop_15		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		pop	si
		pop	es
		pop	di
		retn
vga_operation		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vgadec_multiply		proc	near
		cmp	byte ptr [si-1],0FDh
		jne	loc_16			; Jump if not equal
		jmp	loc_33

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vgadec_func_3:
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
		mov	ax,50h
		mul	bl			; ax = reg * al
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,ds:data_16e
		mov	di,ax
		mov	bl,dl
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:data_23e[bx],0FFFFh
		jnz	loc_19			; Jump if not zero
		mov	ds:data_23e[bx],di
		mov	ax,30h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,data_4e
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	ds,cs:data_31e
		mov	ax,0A000h
		mov	es,ax
		mov	bx,4Eh
		mov	cx,4

locloop_18:
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		dec	di
		dec	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		add	di,bx
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		dec	di
		dec	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		add	di,bx
		loop	locloop_18		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_19:
		mov	si,ds:data_23e[bx]
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	bx,data_1e
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vgadec_func_4:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	loc_20			; Jump if not zero
		retn
loc_20:
		push	bx
		push	es
		mov	dl,[si-1]
		mov	bl,dl
		xor	bh,bh			; Zero register
		mov	es,cs:data_31e
		add	bx,es:data_2e
		mov	dh,es:[bx]
		pop	es
		pop	bx
		or	dh,dh			; Zero ?
		jnz	loc_21			; Jump if not zero
		jmp	loc_16
loc_21:
		dec	di
		dec	si
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		xor	ah,ah			; Zero register
		mov	al,dh
		dec	al
		and	al,3
		add	al,al
		mov	di,ax
		mov	ax,ds:data_10e[di]
		push	ax
		mov	ax,50h
		mul	bl			; ax = reg * al
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,ds:data_16e
		mov	di,ax
		mov	ax,30h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,8100h
		mov	ax,60h
		mul	byte ptr ds:data_17e	; ax = data * al
		shl	bl,1			; Shift w/zeros fill
		shl	bl,1			; Shift w/zeros fill
		shl	bl,1			; Shift w/zeros fill
		shl	bl,1			; Shift w/zeros fill
		shl	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		add	bx,ax
		add	bx,0A000h
		mov	bp,bx
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	ds,cs:data_31e
;*		mov	ax,offset vgadec_func_25	;*
		db	0B8h, 00h,0A0h		;  Fixup - byte match
		mov	es,ax
		pop	ax
		call	ax			;*
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	ah,[di-1]
		or	ah,ah			; Zero ?
		jnz	loc_22			; Jump if not zero
		retn
loc_22:
		cmp	ah,19h
		jb	loc_23			; Jump if below
		retn
loc_23:
		push	di
		push	es
		mov	es,cs:data_31e
		mov	di,es:data_3e
		mov	cl,es:[di]
		or	cl,cl			; Zero ?
		jz	loc_26			; Jump if zero
		inc	di
loc_24:
		mov	al,es:[di]
		cmp	al,0FFh
		je	loc_26			; Jump if equal
		cmp	ah,al
		jne	loc_25			; Jump if not equal
		mov	al,es:[di+1]
		mov	[si-1],al
		jmp	short loc_26
loc_25:
		inc	di
		inc	di
		dec	cl
		jnz	loc_24			; Jump if not zero
loc_26:
		pop	es
		pop	di
		retn
			                        ;* No entry point to code
		db	0F3h, 32h, 27h, 33h, 62h, 33h
		db	 94h, 33h,0B9h, 08h, 00h

locloop_27:
		push	cx
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	bx,ax
		movsw				; Mov [si] to es:[di]
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	cx,ax
		mov	ax,cs:[bp+2]
		and	ax,cx
		mov	es:[di-2],ax
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	ax,cs:[bp]
		and	ax,cx
		or	ax,bx
		mov	es:[di-2],ax
		add	di,4Eh
		add	bp,4
		pop	cx
		loop	locloop_27		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_28:
		push	cx
		lodsw				; String [si] to ax
		mov	bx,ax
		lodsw				; String [si] to ax
		mov	cx,ax
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	ax,cs:[bp]
		and	ax,cx
		or	ax,bx
		stosw				; Store ax to es:[di]
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	bx,ax
		mov	ax,cs:[bp+2]
		and	ax,cx
		or	ax,bx
		mov	es:[di-2],ax
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	word ptr es:[di-2],0
		add	di,4Eh
		add	bp,4
		pop	cx
		loop	locloop_28		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_29:
		push	cx
		lodsw				; String [si] to ax
		mov	bx,ax
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	ax,cs:[bp]
		and	ax,bx
		mov	es:[di-2],ax
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	cx,cs:[bp+2]
		and	cx,bx
		or	cx,ax
		mov	es:[di-2],cx
		add	di,4Eh
		add	bp,4
		pop	cx
		loop	locloop_29		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	ds
		push	cs
		pop	ds
		mov	si,bp
		mov	cx,8

locloop_30:
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	word ptr es:[di-2],0
		dec	di
		dec	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		add	di,4Eh
		loop	locloop_30		; Loop if cx > 0

		pop	ds
		retn
		db	0BFh, 80h, 3Eh

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vgadec_func_5:
		mov	cx,6

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vgadec_func_6:
		mov	ax,0A000h
		mov	es,ax

locloop_31:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_4e
		mov	ds,cs:data_31e
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	cx,8

locloop_32:
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		dec	di
		dec	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		loop	locloop_32		; Loop if cx > 0

		pop	si
		pop	ds
		pop	cx
		loop	locloop_31		; Loop if cx > 0

		retn
loc_33:
		push	ds
		push	si
		push	es
		push	di
		mov	di,data_43e
		movsw				; Mov [si] to es:[di]
		add	si,5
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dl,cs:data_17e
		add	dl,4
		xor	dh,dh			; Zero register
		add	dx,word ptr cs:[80h]
		mov	ds:data_20e,dx
		call	vgadec_func_8
		mov	es:data_18e,al
		cmp	byte ptr es:data_19e,0FDh
		jne	loc_34			; Jump if not equal
		inc	dx
		call	vgadec_func_8
		mov	es:data_19e,al
loc_34:
		mov	si,3BB4h
		mov	di,3EE0h
		call	vgadec_func_5
		mov	si,cs:data_25e
loc_35:
		call	vga_operation4
		or	bl,bl			; Zero ?
		jz	loc_36			; Jump if zero
		push	si
		push	bx
		call	vga_operation3
		pop	bx
		mov	es,cs:data_31e
		mov	si,data_18e
		call	vga_operation2
		pop	si
loc_36:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_35			; Jump if not zero
		pop	di
		pop	es
		mov	ch,es:[di-1]
		mov	cl,es:[di+7]
		push	es
		push	di
		push	cx
		mov	di,cs:data_16e
		add	di,data_37e
		push	di
		mov	si,data_46e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		inc	ch
		jz	loc_37			; Jump if zero
		call	vga_operation1
loc_37:
		pop	di
		pop	cx
		cmp	byte ptr cs:data_17e,1Bh
		je	loc_38			; Jump if equal
		mov	si,data_47e
		inc	di
		inc	di
		inc	cl
		jz	loc_38			; Jump if zero
		call	vga_operation1
loc_38:
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
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
vgadec_multiply		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vgadec_multiply_2		proc	near
		push	es
		push	ds
		mov	si,ds:data_30e
		add	si,25h
		mov	di,data_18e
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dx,word ptr ds:[80h]
		add	dx,3
		mov	ds:data_20e,dx
		cmp	byte ptr ds:data_18e,0FDh
		jne	loc_39			; Jump if not equal
		inc	dx
		call	vgadec_func_8
		mov	ds:data_18e,al
loc_39:
		mov	si,data_18e
		mov	di,3EE0h
		mov	cx,3
		call	vgadec_func_6
		mov	si,cs:data_25e
loc_40:
		call	vga_operation4
		or	bl,bl			; Zero ?
		jz	loc_41			; Jump if zero
		push	si
		dec	bl
		mov	al,3
		mul	bl			; ax = reg * al
		push	ax
		call	vga_operation3
		pop	ax
		add	di,ax
		mov	bp,di
		mov	es,cs:data_31e
		mov	si,data_18e
		mov	di,3EE0h
		call	vga_operation_2
		pop	si
loc_41:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_40			; Jump if not zero
		mov	di,data_38e
		mov	si,data_46e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		call	vga_operation1
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		pop	es
		mov	di,data_27e
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn
vgadec_multiply_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vgadec_func_8		proc	near
		call	vgadec_func_9
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_42			; Jump if equal
		retn
loc_42:
		add	si,8
		call	vga_operation0
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_42			; Jump if equal
		retn
vgadec_func_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vgadec_func_9		proc	near
		mov	si,ds:data_25e

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vga_operation0:
loc_43:
		cmp	dx,[si]
		jne	loc_44			; Jump if not equal
		retn
loc_44:
		add	si,8
		jmp	short loc_43
vgadec_func_9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation1		proc	near
		mov	bx,4Eh
		mov	cx,3

locloop_45:
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		loop	locloop_45		; Loop if cx > 0

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
		call	word ptr cs:data_11e[bx]	;*
		retn
vga_operation2		endp

			                        ;* No entry point to code
		retf	0C235h
			                        ;* No entry point to code
		xor	ax,0E0BFh
		db	 3Eh,0E8h, 70h, 00h,0EBh, 6Eh
		db	 83h,0C6h, 03h,0BFh, 10h, 3Fh
		db	0EBh
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
		js	loc_46			; Jump if sign=1
		mov	dl,4
loc_46:
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
		mov	dx,ds:data_20e

locloop_47:
		mov	bl,cl
		cmp	[si],dx
		jne	loc_48			; Jump if not equal
		retn
loc_48:
		inc	dx
		loop	locloop_47		; Loop if cx > 0

		mov	bl,cl
		retn
vga_operation4		endp

			                        ;* No entry point to code
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_12e[bx]	;*
		retn
			                        ;* No entry point to code
		xor	ds:data_13e,dh
		and	ds:data_26e,dh
		add	di,ds:data_24e[bx]
		jmp	short loc_49
			                        ;* No entry point to code
		mov	di,3E80h
		call	vga_operation_2
		jmp	short loc_49
			                        ;* No entry point to code
		mov	di,data_45e
		add	si,3
		jmp	short loc_49

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation_2		proc	near
loc_49:
		mov	cx,3

locloop_50:
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
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,4100h
		mov	si,ax
		mov	ds,cs:data_31e
		mov	ax,0A000h
		mov	es,ax
		call	vga_operation6
		pop	bp
		pop	es
		pop	si
		pop	ds
		pop	cx
		loop	locloop_50		; Loop if cx > 0

		retn
vga_operation_2		endp

			                        ;* No entry point to code
		mov	di,data_44e
		mov	cx,6

locloop_51:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,6000h
		mov	si,ax
		mov	ds,cs:data_31e
		mov	ax,0A000h
		mov	es,ax
		call	vga_operation6
		pop	si
		pop	ds
		pop	cx
		loop	locloop_51		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation6		proc	near
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,8

locloop_52:
		push	cx
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		lodsw				; String [si] to ax
		mov	cx,ax
		lodsw				; String [si] to ax
		mov	bx,ax
		lodsw				; String [si] to ax
		mov	bp,ax
		or	ax,bx
		or	ax,cx
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di+1],al
		mov	ax,bp
		and	ax,bx
		and	ax,cx
		xchg	cx,ax
		push	ax
		dec	dx
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		pop	ax
		xor	al,cl
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di],al
		xor	ah,ch
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di+1],al
		mov	ax,bx
		xor	al,cl
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di],al
		xor	ah,ch
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di+1],al
		mov	ax,bp
		xor	al,cl
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di],al
		xor	ah,ch
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di+1],al
		dec	dx
		inc	di
		inc	di
		pop	cx
		loop	locloop_52		; Loop if cx > 0

		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn
vga_operation6		endp

			                        ;* No entry point to code
		push	ds
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		std				; Set direction flag
		mov	si,data_40e
		mov	al,8
loc_53:
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
		add	si,50h
		dec	al
		jnz	loc_53			; Jump if not zero
		mov	si,data_42e
		mov	al,8
loc_54:
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
		add	si,50h
		dec	al
		jnz	loc_54			; Jump if not zero
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		cld				; Clear direction
		retn
			                        ;* No entry point to code
		push	ds
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		std				; Set direction flag
		mov	si,data_36e
		mov	al,10h
loc_55:
		push	si
		mov	di,si
		dec	si
		mov	cx,37h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,1Dh
		movsb				; Mov [si] to es:[di]
		pop	si
		add	si,50h
		dec	al
		jnz	loc_55			; Jump if not zero
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		cld				; Clear direction
		retn
			                        ;* No entry point to code
		push	ds
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,data_39e
		mov	al,8
loc_56:
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
		add	si,50h
		dec	al
		jnz	loc_56			; Jump if not zero
		mov	si,data_41e
		mov	al,8
loc_57:
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
		add	si,50h
		dec	al
		jnz	loc_57			; Jump if not zero
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,data_35e
		mov	al,10h
loc_58:
		push	si
		mov	di,si
		inc	si
		mov	cx,37h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,1Dh
		movsb				; Mov [si] to es:[di]
		pop	si
		add	si,50h
		dec	al
		jnz	loc_58			; Jump if not zero
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	si
		mov	dl,30h			; '0'
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,data_2e
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		mov	di,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	ds,cs:data_31e
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

locloop_59:
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		dec	di
		dec	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		add	di,4Eh
		loop	locloop_59		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	si
		push	di
		push	cs
		pop	ds
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	dx,3C4h
		mov	ax,202h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	ax,0A000h
		mov	es,ax
		mov	si,data_14e
		mov	cx,9

locloop_62:
		movsw				; Mov [si] to es:[di]
		add	di,4Eh
		loop	locloop_62		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		retn
		db	0, 0
loc_63:
		jo	$+2			; delay for I/O
		jle	$+2			; delay for I/O
;*		jg	loc_60			;*Jump if >
		db	 7Fh,0C0h		;  Fixup - byte match
		jg	loc_63			; Jump if >
;*		jg	loc_61			;*Jump if >
		db	 7Fh,0C0h		;  Fixup - byte match
		jle	$+2			; delay for I/O
		jo	$+2			; delay for I/O
		add	[bx+si],al
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	si,data_21e
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	cx,9

locloop_64:
		push	cx
		push	di
		push	si
		mov	cx,ds:data_34e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,28h
		pop	di
		add	di,50h
		pop	cx
		loop	locloop_64		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	si
		push	di
		push	di
		xor	ah,ah			; Zero register
		push	ax
		push	cs
		pop	es
		mov	di,data_21e
		xor	ax,ax			; Zero register
		mov	cx,0C8h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		push	ax
		add	ax,ax
		add	si,ax
		mov	si,[si]
		call	vga_operation7
		pop	ax
		pop	di
		test	byte ptr ds:data_32e,0FFh
		jz	loc_65			; Jump if zero
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	di,ax
		mov	dl,[di]
		mov	ax,[di+1]
		call	vga_operation9
loc_65:
		pop	di
		pop	si
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation7		proc	near
		push	cs
		pop	es
		mov	di,data_22e
		xor	bl,bl			; Zero register
loc_66:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_67			; Jump if not zero
		retn
loc_67:
		push	bx
		push	ds
		push	si
		and	bl,3
		call	vga_operation8
		pop	si
		pop	ds
		pop	bx
		inc	bl
		jmp	short loc_66
vga_operation7		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation8		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:data_29e
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8
loc_68:
		push	bx
		lodsb				; String [si] to al
		xor	bl,bl			; Zero register
		mov	bh,al
		shr	bx,cl			; Shift w/zeros fill
		or	es:[di],bh
		or	es:[di+1],bl
		add	di,28h
		pop	bx
		dec	bl
		jnz	loc_68			; Jump if not zero
		pop	di
		inc	di
		cmp	cl,6
		je	loc_69			; Jump if equal
		retn
loc_69:
		inc	di
		retn
vga_operation8		endp

			                        ;* No entry point to code
		push	dx
		push	ax
		push	cs
		pop	es
		mov	di,data_21e
		xor	ax,ax			; Zero register
		mov	cx,0C8h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		pop	dx
		call	vgadec_process_loop_2
		mov	di,3BE4h
		mov	si,3A31h
		mov	cx,7
		mov	bl,1
		mov	word ptr ds:data_34e,0Bh
		jmp	short locloop_70

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation9		proc	near
		call	vgadec_process_loop_2
		push	cs
		pop	es
		mov	di,data_22e
		add	di,ds:data_33e
		mov	si,data_15e
		mov	cx,6
		mov	bl,1

locloop_70:
		push	cx
		push	bx
		push	di
		lodsb				; String [si] to al
		push	si
		call	vgadec_process_loop
		pop	si
		pop	di
		pop	bx
		mov	al,bl
		inc	di
		and	ax,1
		add	di,ax
		inc	bl
		pop	cx
		loop	locloop_70		; Loop if cx > 0

		retn
vga_operation9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vgadec_process_loop		proc	near
		inc	al
		jnz	loc_71			; Jump if not zero
		retn
loc_71:
		dec	al
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,cs:data_28e
		mov	si,ax
		mov	cx,7

locloop_72:
		lodsw				; String [si] to ax
		xchg	ah,al
		test	bl,1
		jnz	loc_73			; Jump if not zero
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
loc_73:
		or	es:[di],ah
		or	es:[di+1],al
		add	di,28h
		loop	locloop_72		; Loop if cx > 0

		retn
vgadec_process_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vgadec_process_loop_2		proc	near
		mov	di,3A31h
		call	vgadec_func_22
		mov	cx,6

locloop_74:
		test	byte ptr cs:[di],0FFh
		jz	loc_75			; Jump if zero
		retn
loc_75:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	locloop_74		; Loop if cx > 0

		retn
vgadec_process_loop_2		endp

		db	7 dup (0)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vgadec_func_22		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	vgadec_func_23
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	vgadec_func_23
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	vgadec_func_23
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	vgadec_func_24
		mov	cs:[di+3],dh
		mov	bx,64h
		call	vgadec_func_24
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	vgadec_func_24
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn
vgadec_func_22		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vgadec_func_23		proc	near
		xor	dh,dh			; Zero register
loc_76:
		sub	dl,cl
		jc	loc_79			; Jump if carry Set
		sub	ax,bx
		jnc	loc_77			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_78			; Jump if zero
		dec	dl
loc_77:
		inc	dh
		jmp	short loc_76
loc_78:
		add	ax,bx
loc_79:
		add	dl,cl
		retn
vgadec_func_23		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vgadec_func_24		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn
vgadec_func_24		endp

			                        ;* No entry point to code
		push	ds
		push	ax
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	si,di
		sub	si,50h
		mov	al,50h			; 'P'
		mul	cl			; ax = reg * al
		sub	ax,50h
		add	si,ax
		add	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

locloop_80:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		sub	si,50h
		sub	di,50h
		pop	cx
		loop	locloop_80		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,3BBCh
		mov	si,ax
		push	cs
		pop	ds
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	ax
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	si,di
		add	si,50h
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

locloop_81:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	si,50h
		add	di,50h
		pop	cx
		loop	locloop_81		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,3BBCh
		mov	si,ax
		push	cs
		pop	ds
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
			                        ;* No entry point to code
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,1803h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	di,data_35e
		mov	cx,8

locloop_82:
		push	cx
		push	di
		mov	cx,12h

locloop_83:
		push	cx
		push	di
		mov	cx,38h

locloop_84:
		mov	al,6
		xchg	es:[di],al
		inc	di
		loop	locloop_84		; Loop if cx > 0

		pop	di
		add	di,280h
		pop	cx
		loop	locloop_83		; Loop if cx > 0

		pop	di
		add	di,50h
		pop	cx
		loop	locloop_82		; Loop if cx > 0

		mov	dx,3CEh
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		retn
		db	0C3h
		db	923 dup (0)

seg_a		ends



		end	start
