
PAGE  59,132

;==========================================================================
;
;  PALETTE_GRAPHICS - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	240h
data_2e		equ	63h
data_18e	equ	29DCh			;*
data_19e	equ	2A80h			;*
data_20e	equ	32B9h			;*
data_21e	equ	32C1h			;*
data_22e	equ	3617h			;*
data_23e	equ	3619h			;*
data_24e	equ	3B1Fh			;*
data_25e	equ	3BE3h			;*
data_26e	equ	3C16h			;*
data_27e	equ	3C17h			;*
data_28e	equ	4289h			;*
data_29e	equ	428Ah			;*
data_30e	equ	428Bh			;*
data_31e	equ	44F8h			;*
data_32e	equ	44FAh			;*
data_33e	equ	44FBh			;*
data_34e	equ	44FDh			;*
data_35e	equ	44FFh			;*
data_36e	equ	4501h			;*
data_37e	equ	4503h			;*
data_38e	equ	4505h			;*
data_39e	equ	4506h			;*
data_40e	equ	4507h			;*
data_41e	equ	4508h			;*
data_42e	equ	450Bh			;*
data_44e	equ	450Dh			;*
data_45e	equ	450Fh			;*
data_46e	equ	5191h			;*
data_47e	equ	5500h			;*
data_48e	equ	6666h			;*
data_49e	equ	0A000h			;*
data_50e	equ	0BF07h			;*
data_51e	equ	0F500h			;*
data_52e	equ	0FF1Ah			;*
data_53e	equ	0FF2Ch			;*
data_54e	equ	0			;*
data_55e	equ	140h			;*
data_56e	equ	1A6Eh			;*
data_57e	equ	1A8Eh			;*
data_58e	equ	0			;*
data_59e	equ	0
data_60e	equ	140h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_05		proc	far

start:
;*		aad	21h			; '!' undocumented inst
		db	0D5h, 21h		;  Fixup - byte match
		add	[bx+si],al
		test	word ptr [si+32h],8830h
;*		xor	ah,ah			; Zero register
		db	 30h,0E4h		;  Fixup - byte match
		xor	[bx+di],ah
		inc	dx
		int	3			; Debug breakpoint
		inc	sp
		db	0C9h, 32h, 2Ch, 33h,0B7h, 33h
		db	 37h, 34h, 4Fh, 36h,0ABh, 36h
		db	 07h, 37h,0FCh, 30h, 32h, 37h
		db	0B4h, 37h,0E6h, 38h, 1Ch, 3Ch
		db	 79h, 3Dh, 35h, 3Eh, 8Bh, 3Eh
		db	 80h, 40h, 62h, 41h, 05h, 42h
		db	0DEh, 44h, 50h, 53h, 51h, 1Eh
		db	 8Ah,0C5h,0F6h,0E1h, 8Bh,0E8h
		db	 06h, 1Fh, 8Bh,0F7h, 8Ch,0C8h
		db	 05h, 00h, 30h, 8Eh,0C0h,0BFh
		db	 00h, 00h, 2Eh,0C7h, 06h,0FDh
		db	 44h, 00h, 00h, 2Eh,0C7h, 06h
		db	0FFh, 44h, 00h, 00h, 8Bh,0CDh
		db	0D1h,0E9h

locloop_1:
		mov	ax,ds:[bp+si]
		xchg	ah,al
		mov	cs:data_36e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_1		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		pop	ax
		mov	di,0
		jmp	loc_5
			                        ;* No entry point to code
		push	ax
		push	bx
		push	cx
		push	ds
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bp,ax
		push	es
		pop	ds
		mov	si,di
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	di,0
		mov	word ptr cs:data_36e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_2:
		add	bp,bp
		mov	ax,ds:[bp+si]
		xchg	al,ah
		mov	cs:data_35e,ax
		shr	bp,1			; Shift w/zeros fill
		mov	ax,ds:[bp+si]
		xchg	al,ah
		mov	cs:data_34e,ax
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_2		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		pop	ax
		mov	di,0
		jmp	loc_5
			                        ;* No entry point to code
		push	ds
		push	ax
		push	es
		push	di
		call	pal_multiply_4
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_42e,329Dh
		call	vga_operation
		pop	ds
		retn
			                        ;* No entry point to code
		push	bx
		push	cx
		push	ds
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bp,ax
		push	es
		pop	ds
		mov	si,di
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	di,0
		mov	word ptr cs:data_33e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_3:
		push	cx
		mov	bx,ds:[bp+si]
		xchg	bh,bl
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	dx,bx
		and	dx,ax
		mov	cx,bx
		or	cx,ax
		not	dx
		and	ax,dx
		and	bx,dx
		mov	cs:data_35e,bx
		mov	cs:data_34e,ax
		mov	cs:data_36e,cx
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		pop	cx
		loop	locloop_3		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		xor	ax,ax			; Zero register
		mov	di,0
		push	ds
		push	ax
		push	es
		push	di
		call	pal_multiply_4
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_42e,3277h
		mov	byte ptr cs:data_41e,0
		or	al,al			; Zero ?
		jnz	loc_4			; Jump if not zero
		call	vga_operation
loc_4:
		mov	byte ptr cs:data_41e,0FFh
		call	vga_operation
		pop	ds
		retn
loc_5:
		push	ds
		push	ax
		push	es
		push	di
		call	pal_multiply_4
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_42e,3239h
		mov	byte ptr cs:data_41e,0
		or	al,al			; Zero ?
		jnz	loc_6			; Jump if not zero
		call	vga_operation
loc_6:
		mov	byte ptr cs:data_41e,0FFh
		call	vga_operation
		pop	ds
		retn

zr1_05		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

vga_operation		proc	near
		mov	byte ptr cs:data_39e,0
		mov	ax,0A000h
		mov	es,ax
		mov	bp,8
loc_7:
		mov	al,cs:data_39e
		mov	cs:data_38e,al
		mov	byte ptr cs:data_52e,0
		push	cx
		push	si
		push	di
loc_8:
		mov	bl,cs:data_38e
		and	bx,7
		mov	bl,cs:data_20e[bx]
		call	word ptr cs:data_42e
		inc	byte ptr cs:data_38e
		mov	al,ch
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	si,ax
		add	di,140h
		dec	cl
		jz	loc_9			; Jump if zero
		mov	bl,cs:data_38e
		and	bx,7
		mov	bl,cs:data_21e[bx]
		call	word ptr cs:data_42e
		inc	byte ptr cs:data_38e
		mov	al,ch
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	si,ax
		add	di,140h
		dec	cl
		jnz	loc_8			; Jump if not zero
loc_9:
		pop	di
		pop	si
		pop	cx
		inc	byte ptr cs:data_39e
loc_10:
		cmp	byte ptr cs:data_52e,14h
		jb	loc_10			; Jump if below
		dec	bp
		jnz	loc_7			; Jump if not zero
		retn
vga_operation		endp

			                        ;* No entry point to code
		test	byte ptr cs:data_41e,0FFh
		jz	loc_13			; Jump if zero
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx

locloop_11:
		lodsb				; String [si] to al
		rol	bl,1			; Rotate
		jnc	loc_12			; Jump if carry=0
		mov	es:[di],al
loc_12:
		inc	di
		loop	locloop_11		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
loc_13:
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx

locloop_14:
		lodsb				; String [si] to al
		rol	bl,1			; Rotate
		sbb	ah,ah
		and	al,ah
		or	es:[di],al
		inc	di
		loop	locloop_14		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
			                        ;* No entry point to code
		test	byte ptr cs:data_41e,0FFh
		jz	loc_13			; Jump if zero
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx

locloop_15:
		lodsb				; String [si] to al
		rol	bl,1			; Rotate
		jnc	loc_16			; Jump if carry=0
		or	al,al			; Zero ?
		jz	loc_16			; Jump if zero
		mov	es:[di],al
loc_16:
		inc	di
		loop	locloop_15		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
			                        ;* No entry point to code
		push	di
		push	cx
		not	bl
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx

locloop_17:
		rol	bl,1			; Rotate
		sbb	al,al
		rol	bl,1			; Rotate
		sbb	ah,ah
		and	es:[di],ax
		inc	di
		inc	di
		loop	locloop_17		; Loop if cx > 0

		pop	cx
		pop	di
		retn
			                        ;* No entry point to code
		and	byte ptr [bx+si],8
		add	al,[bx+si+10h]
		add	al,1
		add	[si],ax
		adc	[bx+si+2],al
		or	[bx+si],ah
		or	byte ptr ds:data_50e,11h
		inc	bp
		xor	ax,ax			; Zero register
		mov	cx,640h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	di,4511h
loc_18:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_19			; Jump if not equal
		retn
loc_19:
		sub	al,20h			; ' '
		jnc	loc_20			; Jump if carry=0
		retn
loc_20:
		jz	loc_22			; Jump if zero
		push	si
		push	di
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:data_51e
		mov	si,ax
		mov	cx,8

locloop_21:
		push	cx
		lodsb				; String [si] to al
		call	pal_func_2
		mov	es:[di],dx
		call	pal_func_2
		mov	es:[di+2],dx
		call	pal_func_2
		mov	es:[di+4],dx
		call	pal_func_2
		mov	es:[di+6],dx
		add	di,140h
		pop	cx
		loop	locloop_21		; Loop if cx > 0

		pop	di
		pop	si
loc_22:
		add	di,8
		jmp	short loc_18

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

pal_func_2		proc	near
		add	al,al
		sbb	dl,dl
		add	al,al
		sbb	dh,dh
		retn
pal_func_2		endp

			                        ;* No entry point to code
		push	ds
		push	cx
		push	bx
		mov	dl,0A0h
		mul	dl			; ax = reg * al
		add	ax,ax
		add	ax,4511h
		mov	si,ax
		add	cl,bl
		mov	al,0A0h
		mul	cl			; ax = reg * al
		add	ax,ax
		add	ax,0
		push	ax
		push	si
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		push	ds
		pop	es
		mov	di,data_54e
		mov	si,data_55e
		mov	cx,7F60h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		push	cs
		pop	ds
		mov	cx,0A0h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	bx
		push	bx
		call	pal_multiply_4
		mov	di,ax
		pop	bx
		mov	al,0A0h
		mul	bl			; ax = reg * al
		add	ax,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	ax,bx
		mov	si,ax
		add	si,0
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	ax,0A000h
		mov	es,ax
		pop	cx
		mov	dx,9999h
		mov	bp,data_48e
		xor	bx,bx			; Zero register
		mov	bl,ch
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_23:
		push	cx
		push	di
		mov	cx,bx

locloop_24:
		and	es:[di],dx
		lodsw				; String [si] to ax
		and	ax,bp
		or	es:[di],ax
		inc	di
		inc	di
		loop	locloop_24		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_23		; Loop if cx > 0

		pop	ds
		retn
loc_25:
		push	ds
		push	ax
		push	bx
		push	cx
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bp,ax
		push	es
		pop	ds
		mov	si,di
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	di,0
		mov	word ptr cs:data_36e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_26:
		add	bp,bp
		mov	ax,ds:[bp+si]
		xchg	ah,al
		mov	cs:data_35e,ax
		shr	bp,1			; Shift w/zeros fill
		mov	ax,ds:[bp+si]
		xchg	ah,al
		mov	cs:data_34e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_26		; Loop if cx > 0

		pop	cx
		pop	bx
		pop	ax
		pop	ds
loc_27:
		push	ds
		call	pal_multiply_4
		mov	di,ax
		mov	si,data_58e
		push	es
		pop	ds
		mov	ax,0A000h
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ch
		add	bx,bx
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_28:
		push	cx
		push	di
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	cx
		add	di,140h
		loop	locloop_28		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_49e
		xor	dx,dx			; Zero register
		mov	cx,9

locloop_29:
		mov	al,1
		stosb				; Store al to es:[di]
		mov	ax,dx
		stosw				; Store ax to es:[di]
		movsw				; Mov [si] to es:[di]
		stosw				; Store ax to es:[di]
		mov	ax,101h
		stosw				; Store ax to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		xor	al,al			; Zero register
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	dx,300h
		loop	locloop_29		; Loop if cx > 0

		mov	byte ptr ds:data_38e,0
		mov	byte ptr ds:data_52e,0
loc_30:
		mov	si,data_49e
		mov	cx,9

locloop_31:
		push	cx
		test	byte ptr [si],0FFh
		jz	loc_33			; Jump if zero
		mov	al,[si+0Dh]
		cmp	al,[si+0Eh]
		je	loc_32			; Jump if equal
		inc	byte ptr [si+0Ch]
		test	byte ptr [si+0Ch],1
		jnz	loc_32			; Jump if not zero
		inc	byte ptr [si+0Dh]
loc_32:
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	cx,ds:data_23e[bx]
		mov	[si+7],cx
		mov	al,[si+4]
		add	al,[si+0Ah]
		mov	[si+4],al
		mov	bh,al
		mov	al,[si+3]
		add	al,[si+9]
		mov	[si+3],al
		mov	bl,al
		call	pal_multiply_4
		mov	[si+5],ax
		mov	di,ax
		mov	bp,[si+1]
		push	ds
		push	si
		mov	ax,0A000h
		mov	ds,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	si,di
		mov	di,bp
		call	copy_buffer
		pop	si
		pop	ds
loc_33:
		pop	cx
		add	si,0Fh
		loop	locloop_31		; Loop if cx > 0

		mov	si,data_49e
		mov	cx,9

locloop_34:
		push	cx
		push	si
		mov	al,ds:data_38e
		and	al,7
		mov	ah,3
		mul	ah			; ax = reg * al
		add	ax,3637h
		mov	si,ax
		lodsb				; String [si] to al
		mov	ds:data_28e,al
		lodsb				; String [si] to al
		mov	ds:data_29e,al
		lodsb				; String [si] to al
		mov	ds:data_30e,al
		inc	byte ptr ds:data_38e
		xor	ax,ax			; Zero register
		call	vga_operation9
		pop	si
		test	byte ptr cs:[si],0FFh
		jz	loc_35			; Jump if zero
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	bp,ds:data_22e[bx]
		mov	cx,[si+7]
		mov	dl,[si]
		mov	byte ptr [si],0
		mov	ax,[si+3]
		cmp	ah,4Bh			; 'K'
		jae	loc_35			; Jump if above or =
		cmp	al,0A0h
		jae	loc_35			; Jump if above or =
		mov	[si],dl
		mov	di,[si+5]
		push	ds
		push	si
		mov	ax,0A000h
		mov	es,ax
		mov	ds,cs:data_53e
		mov	si,bp
		call	pal_multiply
		pop	si
		pop	ds
loc_35:
		pop	cx
		add	si,0Fh
		loop	locloop_34		; Loop if cx > 0

loc_36:
		cmp	byte ptr cs:data_52e,1Eh
		jb	loc_36			; Jump if below
		mov	byte ptr cs:data_52e,0
		mov	si,data_49e
		mov	cx,9

locloop_37:
		push	cx
		mov	bp,[si+1]
		mov	di,[si+5]
		mov	cx,[si+7]
		push	ds
		push	si
		mov	ax,0A000h
		mov	es,ax
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,bp
		call	copy_buffer_2
		pop	si
		pop	ds
		pop	cx
		add	si,0Fh
		loop	locloop_37		; Loop if cx > 0

		mov	si,data_49e
		mov	cx,9

locloop_38:
		test	byte ptr [si],0FFh
		jz	loc_39			; Jump if zero
		jmp	loc_30
loc_39:
		add	si,0Fh
		loop	locloop_38		; Loop if cx > 0

		mov	ax,2
		jmp	loc_115

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

copy_buffer		proc	near
		push	si
		push	cx
loc_40:
		push	si
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	si
		add	si,140h
		dec	cl
		jnz	loc_40			; Jump if not zero
		pop	cx
		pop	si
		retn
copy_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

copy_buffer_2		proc	near
		push	di
		push	cx
loc_41:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	di
		add	di,140h
		dec	cl
		jnz	loc_41			; Jump if not zero
		pop	cx
		pop	di
		retn
copy_buffer_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

pal_multiply		proc	near
		push	di
		push	cx
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bx,ax
		mov	word ptr cs:data_36e,0
loc_42:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_43:
		xor	al,al			; Zero register
		mov	ah,[bx+si]
		mov	cs:data_34e,ax
		mov	ah,[si]
		mov	cs:data_33e,ax
		mov	cs:data_35e,ax
		inc	si
		push	bx
		call	pal_process_loop
		pop	bx
		or	es:[di],ax
		push	bx
		call	pal_process_loop
		pop	bx
		or	es:[di+2],ax
		add	di,4
		loop	locloop_43		; Loop if cx > 0

		pop	cx
		pop	di
		add	di,140h
		dec	cl
		jnz	loc_42			; Jump if not zero
		pop	cx
		pop	di
		retn
pal_multiply		endp

		db	 00h, 90h, 20h, 06h, 80h, 91h
		db	 20h, 06h, 00h, 93h, 20h, 06h
		db	 80h, 94h, 20h, 06h, 00h, 96h
		db	 18h, 04h,0C0h, 96h, 18h, 04h
		db	 80h, 97h, 18h, 04h, 40h, 98h
		db	 18h, 04h, 1Fh, 1Fh, 00h, 0Fh
		db	 0Fh, 00h, 1Fh, 1Fh, 1Fh, 0Fh
		db	 0Fh, 0Fh, 1Fh, 00h, 1Fh, 0Fh
		db	 00h, 0Fh, 1Fh, 00h, 00h, 0Fh
		db	 00h, 00h, 1Eh, 53h, 32h,0E4h
		db	0BAh,0C0h, 0Ch,0F7h,0E2h, 05h
		db	 40h,0ABh
		db	2Eh
data_4		dw	1E8Eh			; Data table (indexed access)
		db	 2Ch,0FFh, 8Bh,0F0h, 8Ch,0C8h
		db	 05h, 00h, 30h, 8Eh,0C0h,0BFh
		db	 00h, 00h, 2Eh,0C7h, 06h, 01h
		db	 45h, 00h, 00h, 2Eh,0C7h, 06h
		db	0FFh, 44h, 00h, 00h,0B9h, 30h
		db	 03h

locloop_44:
		mov	ax,data_4[si]
		xchg	ah,al
		mov	cs:data_33e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_34e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_44		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,0
		mov	cx,2230h
		jmp	loc_27
			                        ;* No entry point to code
		push	ds
		push	bx
		xor	ah,ah			; Zero register
		mov	dx,480h
		mul	dx			; dx:ax = reg * ax
		add	ax,97C0h
		mov	ds,cs:data_53e
		mov	si,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	di,0
		mov	word ptr cs:data_36e,0
		mov	word ptr cs:data_35e,0
		mov	cx,120h

locloop_45:
		mov	ax,ds:data_1e[si]
		xchg	ah,al
		mov	cs:data_34e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_45		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,data_59e
		mov	cx,1220h
		jmp	loc_27
			                        ;* No entry point to code
		mov	ax,0A000h
		mov	es,ax
		xor	di,di			; Zero register
		mov	cx,64h

locloop_46:
		push	cx
		push	di
		mov	ax,1000h
		mov	cx,0A0h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		add	di,data_60e
		push	di
		mov	ax,10h
		mov	cx,0A0h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		add	di,140h
		pop	cx
		loop	locloop_46		; Loop if cx > 0

		retn
		db	 33h,0DBh,0B9h, 19h, 00h

locloop_47:
		push	cx
		mov	cx,22h

locloop_48:
		push	cx
		lodsb				; String [si] to al
		push	bx
		push	ds
		push	si
		call	pal_multiply_2
		pop	si
		pop	ds
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_48		; Loop if cx > 0

		xor	bh,bh			; Zero register
		inc	bl
		pop	cx
		loop	locloop_47		; Loop if cx > 0

		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

pal_multiply_2		proc	near
		mov	ds,cs:data_53e
		mov	dx,cs
		add	dx,2000h
		mov	es,dx
		xor	ah,ah			; Zero register
loc_49:
		sub	al,28h			; '('
		jc	loc_50			; Jump if carry Set
		inc	ah
		jmp	short loc_49
loc_50:
		add	al,28h			; '('
		mov	cl,al
		mov	al,ah
		xor	ah,ah			; Zero register
		mov	dx,140h
		mul	dx			; dx:ax = reg * ax
		xor	ch,ch			; Zero register
		add	ax,cx
		add	ax,4000h
		push	ax
		mov	dx,bx
		xor	dh,dh			; Zero register
		mov	ax,110h
		mul	dx			; dx:ax = reg * ax
		mov	dl,bh
		xor	dh,dh			; Zero register
		add	ax,dx
		add	ax,0
		mov	di,ax
		pop	si
		mov	cx,3

locloop_51:
		push	cx
		push	di
		push	si
		mov	cx,8

locloop_52:
		movsb				; Mov [si] to es:[di]
		add	di,21h
		add	si,27h
		loop	locloop_52		; Loop if cx > 0

		pop	si
		pop	di
		add	di,1A90h
		add	si,640h
		pop	cx
		loop	locloop_51		; Loop if cx > 0

		retn
pal_multiply_2		endp

			                        ;* No entry point to code
		push	ds
		mov	dx,cs
		mov	es,dx
		add	dx,2000h
		mov	ds,dx
		push	ax
		mov	dl,22h			; '"'
		mul	dl			; ax = reg * al
		add	ax,0
		mov	si,ax
		push	si
		mov	di,data_46e
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,data_56e
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,data_46e
		mov	cx,44h

locloop_53:
		mov	al,es:[di]
		mov	dx,8
loc_54:
		ror	al,1			; Rotate
		adc	ah,ah
		dec	dx
		jnz	loc_54			; Jump if not zero
		mov	es:[di],ah
		inc	di
		loop	locloop_53		; Loop if cx > 0

		pop	si
		pop	ax
		mov	bl,al
		xor	bh,bh			; Zero register
		call	pal_multiply_4
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		push	di
		mov	cx,11h

locloop_55:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	bx,ds:data_57e[si]
		xchg	bh,bl
		mov	dx,ax
		and	dx,bx
		mov	cs:data_33e,dx
		or	dx,bx
		mov	cs:data_34e,dx
		mov	cs:data_35e,dx
		mov	cs:data_36e,dx
		or	ax,bx
		not	ax
		mov	cs:data_37e,ax
		call	pal_func_21
		and	es:[di],ax
		call	pal_process_loop
		or	es:[di],ax
		call	pal_func_21
		and	es:[di+2],ax
		call	pal_process_loop
		or	es:[di+2],ax
		call	pal_func_21
		and	es:[di+4],ax
		call	pal_process_loop
		or	es:[di+4],ax
		call	pal_func_21
		and	es:[di+6],ax
		call	pal_process_loop
		or	es:[di+6],ax
		add	di,8
		pop	cx
		loop	locloop_55		; Loop if cx > 0

		pop	di
		add	di,138h
		push	cs
		pop	ds
		mov	si,data_46e
		mov	cx,11h

locloop_56:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	bx,[si+20h]
		xchg	bh,bl
		mov	dx,ax
		and	dx,bx
		mov	cs:data_33e,dx
		or	dx,bx
		mov	cs:data_34e,dx
		mov	cs:data_35e,dx
		mov	cs:data_36e,dx
		or	ax,bx
		not	ax
		mov	cs:data_37e,ax
		call	pal_func_21
		and	es:[di+4],ax
		call	pal_process_loop
		or	es:[di+4],ax
		call	pal_func_21
		and	es:[di+6],ax
		call	pal_process_loop
		or	es:[di+6],ax
		call	pal_func_21
		and	es:[di],ax
		call	pal_process_loop
		or	es:[di],ax
		call	pal_func_21
		and	es:[di+2],ax
		call	pal_process_loop
		or	es:[di+2],ax
		sub	di,8
		pop	cx
		loop	locloop_56		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	bx,ax
		add	bx,bx
		mov	al,ds:data_26e[bx]
		mov	ds:data_39e,al
		mov	al,ds:data_27e[bx]
		mov	ds:data_38e,al
		mov	ax,0A000h
		mov	es,ax
		mov	di,1410h
		mov	si,data_24e
loc_57:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_58			; Jump if zero
		call	pal_func_7
		add	di,500h
		jmp	short loc_57
loc_58:
		add	di,0FB04h
loc_59:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_60			; Jump if zero
		call	pal_func_7
		add	di,4
		jmp	short loc_59
loc_60:
		add	di,0FAFCh
loc_61:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_62			; Jump if zero
		call	pal_func_7
		add	di,0FB00h
		jmp	short loc_61
loc_62:
		add	di,4FCh
loc_63:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_64			; Jump if zero
		call	pal_func_7
		sub	di,4
		jmp	short loc_63
loc_64:
		add	di,504h
		mov	si,data_25e
loc_65:
		mov	byte ptr cs:data_52e,0
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_66			; Jump if not zero
		retn
loc_66:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_67:
		push	cx
		mov	al,18h
		call	pal_func_7
		add	di,500h
		pop	cx
		loop	locloop_67		; Loop if cx > 0

		add	di,0FB00h
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_68			; Jump if not zero
		retn
loc_68:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_69:
		push	cx
		mov	al,18h
		call	pal_func_7
		add	di,4
		pop	cx
		loop	locloop_69		; Loop if cx > 0

		sub	di,4
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_70			; Jump if not zero
		retn
loc_70:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_71:
		push	cx
		mov	al,18h
		call	pal_func_7
		add	di,0FB00h
		pop	cx
		loop	locloop_71		; Loop if cx > 0

		add	di,500h
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_72			; Jump if not zero
		retn
loc_72:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_73:
		push	cx
		mov	al,18h
		call	pal_func_7
		sub	di,4
		pop	cx
		loop	locloop_73		; Loop if cx > 0

		add	di,4
loc_74:
		cmp	byte ptr cs:data_52e,0Ch
		jb	loc_74			; Jump if below
		jmp	short loc_65

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

pal_func_7		proc	near
		push	si
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,3A5Fh
		mov	si,ax
		push	di
		mov	bh,cs:data_38e
		call	extract_bits
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		add	di,13Ch
		mov	bh,cs:data_38e
		ror	bh,1			; Rotate
		call	extract_bits
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		add	di,13Ch
		mov	bh,cs:data_38e
		call	extract_bits
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		add	di,13Ch
		mov	bh,cs:data_38e
		ror	bh,1			; Rotate
		call	extract_bits
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		pop	di
		pop	si
		retn
pal_func_7		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

extract_bits		proc	near
		mov	word ptr ds:data_33e,0
		mov	word ptr ds:data_36e,0
		mov	ah,[si+4]
		mov	ds:data_35e,ax
		mov	ds:data_34e,ax
		lodsb				; String [si] to al
		and	al,bh
		mov	ah,al
		mov	al,ds:data_39e
		shr	al,1			; Shift w/zeros fill
		jnc	loc_75			; Jump if carry=0
		or	ds:data_33e,ax
loc_75:
		shr	al,1			; Shift w/zeros fill
		jnc	loc_76			; Jump if carry=0
		or	ds:data_34e,ax
loc_76:
		shr	al,1			; Shift w/zeros fill
		jc	loc_77			; Jump if carry Set
		retn
loc_77:
		or	ds:data_35e,ax
		retn
extract_bits		endp

		db	 00h, 00h, 00h, 03h, 80h, 80h
		db	 85h, 84h, 03h, 03h, 03h, 03h
		db	 84h, 84h, 84h, 84h, 03h, 03h
		db	 03h, 03h, 84h, 84h, 84h,0D4h
		db	 00h, 00h, 00h,0FFh, 00h, 00h
		db	 55h, 00h, 00h, 00h, 01h,0FFh
		db	 02h, 02h, 56h, 00h, 00h, 00h
		db	 00h,0FFh, 40h, 40h, 55h, 00h
		db	 00h, 00h, 00h,0C0h, 01h, 01h
		db	 61h, 21h,0C0h,0C0h,0C0h,0C0h
		db	 21h, 21h, 21h, 21h,0C0h,0C0h
		db	0C0h,0C0h, 21h, 21h, 21h, 21h
		db	0C0h,0E0h,0E0h,0E0h, 2Bh, 01h
		db	 01h, 01h, 03h, 03h, 03h, 03h
		db	0D4h, 84h, 84h, 84h, 03h, 03h
		db	 03h, 03h, 84h, 84h, 84h, 84h
		db	 03h, 02h, 00h, 00h, 84h, 85h
		db	 80h, 80h,0FFh,0AAh, 00h, 00h
		db	 00h, 55h, 00h, 00h,0FFh,0A8h
		db	 00h, 00h, 00h, 56h, 02h, 02h
		db	0FFh,0FFh, 00h, 00h, 00h, 55h
		db	 40h, 40h,0C0h,0C0h,0C0h,0C0h
		db	 2Bh, 21h, 21h, 21h,0C0h,0C0h
		db	0C0h,0C0h, 21h, 21h, 21h, 21h
		db	0C0h, 80h, 00h, 00h, 21h, 61h
		db	 01h, 01h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 07h, 07h, 07h, 07h, 80h, 80h
		db	 80h, 80h,0E0h,0E0h,0E0h,0E0h
		db	 01h, 01h, 01h, 01h,0FFh,0FFh
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	 01h, 02h, 03h
		db	20 dup (16h)
		db	 0Bh, 0Ch, 0Dh, 00h, 0Eh, 0Fh
		db	66 dup (15h)
		db	 10h, 0Eh, 13h, 00h, 12h, 11h
		db	19 dup (17h)
		db	 0Ah, 09h, 08h, 07h, 00h, 04h
		db	 06h
		db	66 dup (14h)
		db	 05h, 04h, 00h, 18h, 46h, 18h
		db	 45h, 17h, 44h, 16h, 43h, 15h
		db	 42h, 14h, 41h, 13h, 40h, 12h
		db	 3Fh, 11h, 3Eh, 10h, 3Dh, 0Fh
		db	 3Ch, 0Eh, 3Bh, 0Dh, 3Ah, 0Ch
		db	 39h, 0Bh, 38h, 0Ah, 37h, 09h
		db	 36h, 08h, 35h, 07h, 34h, 06h
		db	 33h, 05h, 32h, 04h, 31h, 03h
		db	 30h, 02h, 2Fh, 01h, 2Eh, 00h
		db	 02h, 55h, 03h,0FFh, 01h, 55h
		db	 1Eh, 2Eh,0A2h, 08h, 45h, 53h
		db	 51h, 8Ah,0C5h,0F6h,0E1h, 8Bh
		db	0E8h, 06h, 1Fh, 8Bh,0F7h, 8Ch
		db	0C8h, 05h, 00h, 30h, 8Eh,0C0h
		db	0BFh, 00h, 00h, 2Eh,0C7h, 06h
		db	 01h, 45h, 00h, 00h, 2Eh,0C7h
		db	 06h,0FBh, 44h, 00h, 00h, 2Eh
		db	0C7h, 06h,0FDh, 44h, 00h, 00h
		db	 2Eh,0C7h, 06h,0FFh, 44h, 00h
		db	 00h, 8Bh,0CDh,0D1h,0E9h

locloop_78:
		push	si
		test	byte ptr cs:data_41e,1
		jz	loc_79			; Jump if zero
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_33e,ax
		add	si,bp
loc_79:
		test	byte ptr cs:data_41e,2
		jz	loc_80			; Jump if zero
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_34e,ax
		add	si,bp
loc_80:
		test	byte ptr cs:data_41e,4
		jz	loc_81			; Jump if zero
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_35e,ax
loc_81:
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		pop	si
		inc	si
		inc	si
		loop	locloop_78		; Loop if cx > 0

		pop	cx
		pop	bx
		sub	bx,410h
		mov	byte ptr cs:data_39e,0
		mov	byte ptr cs:data_40e,0
		mov	cs:data_42e,cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,0
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

locloop_82:
		push	cx
		mov	al,cs:data_40e
		mov	cs:data_39e,al
		mov	byte ptr cs:data_52e,0
		mov	cx,0Dh

locloop_83:
		push	cx
		push	bx
		push	si
		call	pal_multiply_3
		pop	si
		pop	bx
		pop	cx
		add	byte ptr cs:data_39e,8
		loop	locloop_83		; Loop if cx > 0

		pop	cx
loc_84:
		cmp	byte ptr cs:data_52e,14h
		jb	loc_84			; Jump if below
		inc	byte ptr cs:data_40e
		loop	locloop_82		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

pal_multiply_3		proc	near
		push	bx
		mov	bl,cs:data_39e
		add	bl,10h
		mov	bh,4
		call	pal_multiply_4
		mov	di,ax
		pop	bx
		cmp	cs:data_39e,bl
		jb	loc_87			; Jump if below
		mov	al,bl
		add	al,cs:data_42e
		cmp	cs:data_39e,al
		jae	loc_87			; Jump if above or =
		mov	al,cs:data_39e
		sub	al,bl
		mul	byte ptr cs:data_42e+1	; ax = data * al
		add	ax,ax
		add	ax,ax
		add	si,ax
		mov	byte ptr cs:data_38e,0
		mov	cx,48h

locloop_85:
		push	cx
		mov	word ptr es:[di],0
		mov	word ptr es:[di+2],0
		cmp	cs:data_38e,bh
		jb	loc_86			; Jump if below
		mov	al,bh
		add	al,byte ptr cs:data_42e+1
		cmp	cs:data_38e,al
		jae	loc_86			; Jump if above or =
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	di,4
loc_86:
		add	di,4
		inc	byte ptr cs:data_38e
		pop	cx
		loop	locloop_85		; Loop if cx > 0

		retn
loc_87:
		mov	cx,90h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
pal_multiply_3		endp

			                        ;* No entry point to code
		mov	cs:data_39e,bl
		call	pal_multiply_4
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		sub	bx,4
		xor	ch,ch			; Zero register
		sub	cx,5
		push	cx
		push	di
		call	fill_buffer
		pop	di
		inc	byte ptr cs:data_39e
		add	di,140h
		mov	cx,2
		call	clear_buffer
		pop	cx

locloop_88:
		push	cx
		call	vga_operation2
		mov	byte ptr es:[di],0FFh
		mov	byte ptr es:[di+1],0
		mov	byte ptr es:[di+2],0
		mov	byte ptr es:[di+3],0
		or	byte ptr es:[bx+di+3],0FFh
		mov	byte ptr es:[bx+di+2],0
		mov	byte ptr es:[bx+di+1],0
		mov	byte ptr es:[bx+di],0
		inc	byte ptr cs:data_39e
		add	di,140h
		pop	cx
		loop	locloop_88		; Loop if cx > 0

		mov	cx,1
		call	clear_buffer

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

fill_buffer		proc	near
		call	vga_operation2
		mov	cx,bx
		add	cx,4
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn
fill_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

clear_buffer		proc	near

locloop_89:
		push	cx
		push	di
		call	vga_operation2
		mov	byte ptr es:[di],0FFh
		inc	di
		mov	cx,bx
		add	cx,2
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	byte ptr es:[di],0FFh
		pop	di
		inc	byte ptr cs:data_39e
		add	di,140h
		pop	cx
		loop	locloop_89		; Loop if cx > 0

		retn
clear_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

vga_operation2		proc	near
		mov	word ptr es:[di-7],202h
		mov	word ptr es:[di-5],202h
		mov	word ptr es:[di-3],202h
		mov	word ptr es:[di-1],202h
		retn
vga_operation2		endp

			                        ;* No entry point to code
		push	bx
		push	es
		push	di
		mov	cx,1028h

locloop_90:
		mov	al,es:[di]
		and	al,byte ptr es:[1028h][di]
		mov	ah,es:data_17[di]
		not	ah
		and	al,ah
		not	al
		and	es:[di],al
		and	byte ptr es:[1028h][di],al
		and	es:data_17[di],al
		mov	al,es:data_17[di]
		mov	ah,es:[di]
		not	ah
		and	al,ah
		mov	ah,byte ptr es:[1028h][di]
		not	ah
		and	al,ah
		or	es:[di],al
		or	byte ptr es:[1028h][di],al
		not	al
		and	es:data_17[di],al
		inc	di
		loop	locloop_90		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,2F58h
		jmp	loc_25
			                        ;* No entry point to code
		push	ds
		mov	ds:data_44e,di
		mov	ds:data_45e,es
		mov	di,69Ah
		add	di,ds:data_44e
		call	vga_operation5
		mov	di,6BCh
		add	di,ds:data_44e
		call	vga_operation5
		mov	ax,0A000h
		mov	es,ax
		mov	ds,cs:data_45e
		mov	cx,44h

locloop_91:
		push	cx
		mov	byte ptr cs:data_52e,0
		mov	ax,44h
		sub	ax,cx
		add	ax,ax
		push	ax
		mov	bl,al
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		push	ax
		mov	bh,0
		call	pal_multiply_4
		mov	di,ax
		pop	ax
		add	ax,cs:data_44e
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	loc_92			; Jump if below
		cmp	ax,71h
		jae	loc_92			; Jump if above or =
		call	vga_operation4
		jmp	short loc_93
loc_92:
		call	vga_operation3
loc_93:
		pop	cx
		push	cx
		mov	ax,cx
		add	ax,ax
		dec	ax
		push	ax
		mov	bl,al
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		push	ax
		mov	bh,0
		call	pal_multiply_4
		mov	di,ax
		pop	ax
		add	ax,cs:data_44e
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	loc_94			; Jump if below
		cmp	ax,71h
		jae	loc_94			; Jump if above or =
		call	vga_operation4
		jmp	short loc_95
loc_94:
		call	vga_operation3
loc_95:
		cmp	byte ptr cs:data_52e,4
		jb	loc_95			; Jump if below
		pop	cx
		loop	locloop_91		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

vga_operation3		proc	near
		mov	cx,28h
		mov	word ptr cs:data_36e,0

locloop_96:
		mov	ax,ds:data_47e[si]
		xchg	ah,al
		mov	cs:data_35e,ax
		mov	ax,ds:data_19e[si]
		xchg	ah,al
		mov	cs:data_34e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_96		; Loop if cx > 0

		retn
vga_operation3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

vga_operation4		proc	near
		mov	cx,0Bh
		mov	word ptr cs:data_36e,0

locloop_97:
		mov	ah,ds:data_47e[si]
		mov	cs:data_35e,ax
		mov	ah,ds:data_19e[si]
		mov	cs:data_34e,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_97		; Loop if cx > 0

		add	si,18h
		add	di,60h
		mov	cx,5

locloop_98:
		mov	ax,ds:data_47e[si]
		xchg	ah,al
		mov	cs:data_35e,ax
		mov	ax,ds:data_19e[si]
		xchg	ah,al
		mov	cs:data_34e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_98		; Loop if cx > 0

		add	si,18h
		add	di,60h
		mov	cx,0Bh

locloop_99:
		mov	ah,ds:data_47e[si]
		mov	cs:data_35e,ax
		mov	ah,ds:data_19e[si]
		mov	cs:data_34e,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_99		; Loop if cx > 0

		retn
vga_operation4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

vga_operation5		proc	near
		push	di
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

locloop_100:
		mov	byte ptr es:[di],30h	; '0'
		mov	byte ptr es:[di+19h],0Ch
		add	di,50h
		loop	locloop_100		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		pop	di
		add	di,data_19e
		push	di
		mov	ax,0FD7Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,2Dh

locloop_101:
		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	byte ptr es:[di],70h	; 'p'
		mov	byte ptr es:[di+19h],0Dh
		add	di,50h
		loop	locloop_101		; Loop if cx > 0

		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	ax,0FD7Fh
		call	fill_buffer_2
		pop	di
		add	di,data_19e
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

locloop_102:
		mov	byte ptr es:[di],30h	; '0'
		mov	byte ptr es:[di+19h],0Ch
		add	di,50h
		loop	locloop_102		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		retn
vga_operation5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

fill_buffer_2		proc	near
		stosb				; Store al to es:[di]
		mov	al,0FFh
		mov	cx,18h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,ah
		stosb				; Store al to es:[di]
		retn
fill_buffer_2		endp

			                        ;* No entry point to code
		push	ds
		mov	ds:data_44e,di
		mov	ds:data_45e,es
		mov	ax,0A000h
		mov	es,ax
		mov	ds,cs:data_45e
		mov	cx,39h

locloop_103:
		mov	byte ptr cs:data_52e,0
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,39h
		add	ax,ax
		call	vga_operation7
		pop	ax
		push	ax
		add	ax,ax
		dec	ax
		call	vga_operation7
loc_104:
		cmp	byte ptr cs:data_52e,4
		jb	loc_104			; Jump if below
		pop	cx
		loop	locloop_103		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

vga_operation7		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,cs:data_44e
		mov	si,ax
		xor	bh,bh			; Zero register
		call	pal_multiply_4
		mov	di,ax
		pop	ax
		cmp	ax,14h
		jae	loc_105			; Jump if above or =
		mov	cx,2Fh
		jmp	short loc_106
loc_105:
		mov	cx,23h
		cmp	ax,17h
		jb	loc_106			; Jump if below
		cmp	ax,1Ch
		jb	loc_108			; Jump if below
		mov	cx,21h
loc_106:
		mov	word ptr cs:data_36e,0

locloop_107:
		mov	ah,ds:data_18e[si]
		mov	cs:data_35e,ax
		mov	ah,byte ptr ds:[14EEh][si]
		mov	cs:data_34e,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_107		; Loop if cx > 0

		retn
loc_108:
		mov	cx,21h
		mov	word ptr cs:data_36e,0

locloop_109:
		mov	ah,ds:data_18e[si]
		mov	cs:data_35e,ax
		mov	ah,byte ptr ds:[14EEh][si]
		mov	cs:data_34e,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_109		; Loop if cx > 0

		mov	ah,ds:data_18e[si]
		mov	cs:data_35e,ax
		mov	ah,byte ptr ds:[14EEh][si]
		mov	cs:data_34e,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosb				; Store al to es:[di]
		retn
vga_operation7		endp

			                        ;* No entry point to code
		push	ds
		mov	ds:data_44e,di
		mov	ds:data_45e,es
		mov	ax,0A000h
		mov	es,ax
		mov	ds,cs:data_45e
		mov	cx,39h

locloop_110:
		mov	byte ptr cs:data_52e,0
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,39h
		add	ax,ax
		call	vga_operation8
		pop	ax
		push	ax
		add	ax,ax
		dec	ax
		call	vga_operation8
loc_111:
		cmp	byte ptr cs:data_52e,4
		jb	loc_111			; Jump if below
		pop	cx
		loop	locloop_110		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

vga_operation8		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,3CDh
		add	ax,cs:data_44e
		mov	si,ax
		add	bl,14h
		mov	bh,21h			; '!'
		call	pal_multiply_4
		mov	di,ax
		pop	ax
		cmp	ax,5Eh
		mov	cx,2Fh
		jnc	loc_113			; Jump if carry=0
		mov	cx,7
		mov	word ptr cs:data_36e,0

locloop_112:
		mov	ax,ds:data_18e[si]
		xchg	ah,al
		mov	cs:data_35e,ax
		mov	ax,word ptr ds:[14EEh][si]
		xchg	ah,al
		mov	cs:data_34e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_33e,ax
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		call	pal_process_loop
		stosw				; Store ax to es:[di]
		loop	locloop_112		; Loop if cx > 0

		mov	cx,21h
loc_113:
		add	cx,cx
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
vga_operation8		endp

			                        ;* No entry point to code
		push	ax
		call	pal_multiply_4
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		pop	ax
		mov	ah,al
		mov	cx,8

locloop_114:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,138h
		loop	locloop_114		; Loop if cx > 0

		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

vga_operation9		proc	near
loc_115:
		mov	dx,30h
		mul	dx			; dx:ax = reg * ax
		add	ax,4289h
		mov	si,ax
		mov	ds:data_31e,si
		pushf				; Push flags
		cli				; Disable interrupts
		mov	si,ds:data_31e
		mov	ax,40h
		mov	es,ax
		mov	dx,es:data_2e
		add	dx,6
		push	dx
		in	al,dx			; port 3DAh, CGA/EGA vid status
		mov	byte ptr ds:data_32e,0
		mov	cx,10h

locloop_116:
		push	cx
		lodsb				; String [si] to al
		mov	bh,al
		lodsb				; String [si] to al
		mov	bl,al
		lodsb				; String [si] to al
		mov	ah,al
		push	si
		mov	si,ds:data_31e
		mov	cx,10h

locloop_117:
		mov	dx,3C8h
		mov	al,ds:data_32e
		out	dx,al			; port 3C8h, VGA pel address
		jmp	short $+2		; delay for I/O
		mov	dl,0C9h
		lodsb				; String [si] to al
		add	al,bh
		out	dx,al			; port 3C9h, VGA pel data reg
		jmp	short $+2		; delay for I/O
		lodsb				; String [si] to al
		add	al,bl
		out	dx,al			; port 3C9h, VGA pel data reg
		jmp	short $+2		; delay for I/O
		lodsb				; String [si] to al
		add	al,ah
		out	dx,al			; port 3C9h, VGA pel data reg
		jmp	short $+2		; delay for I/O
		inc	byte ptr ds:data_32e
		loop	locloop_117		; Loop if cx > 0

		pop	si
		pop	cx
		loop	locloop_116		; Loop if cx > 0

		pop	dx
		in	al,dx			; port 3DAh, CGA/EGA vid status
		popf				; Pop flags
		retn
vga_operation9		endp

		db	 00h, 00h, 00h, 00h, 0Fh, 0Fh
		db	 00h, 00h, 1Fh, 1Fh, 1Fh, 1Fh
		db	 00h, 00h, 00h, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 07h, 07h, 07h, 0Fh, 0Fh, 0Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 1Fh, 00h, 00h, 1Fh, 1Fh
		db	 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh
		db	 00h, 00h, 00h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	12 dup (1Fh)
		db	 07h, 07h, 07h, 0Fh, 0Fh, 0Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	12 dup (1Fh)
		db	 00h, 00h, 00h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 00h, 00h, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 07h, 07h, 07h, 0Fh, 0Fh, 0Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 1Fh, 00h, 00h, 1Fh, 1Fh
		db	 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh
		db	 00h, 00h, 00h, 1Fh, 00h, 00h
		db	 00h, 00h, 1Fh, 1Fh, 1Fh, 1Fh
		db	 00h, 00h, 1Fh, 1Fh, 1Fh, 1Fh
		db	 00h, 00h, 00h, 1Fh, 1Fh, 1Fh
		db	 07h, 07h, 07h, 1Fh, 1Fh, 1Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 1Fh, 00h, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 0Fh, 0Fh, 0Fh
		db	 00h, 00h, 00h, 00h, 00h, 0Fh
		db	 0Fh, 00h, 00h, 0Fh, 00h, 0Fh
		db	 00h, 0Fh, 0Fh, 00h, 0Fh, 0Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 07h, 07h, 07h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh
		db	 0Fh, 0Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 00h, 00h, 00h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 00h, 0Fh, 0Fh
		db	 00h, 1Fh, 00h, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 07h, 07h, 07h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 00h, 00h, 00h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 00h, 00h, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 07h, 07h, 07h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 00h, 00h, 00h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 1Fh, 00h, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 07h, 07h, 07h, 0Fh, 0Fh, 0Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	12 dup (1Fh)
		db	 00h, 00h, 00h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 00h, 1Fh, 00h
		db	 00h, 00h, 00h, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 07h, 07h, 07h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 00h, 00h, 00h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 0Fh, 00h, 00h
		db	 00h, 1Fh, 00h, 1Fh, 00h, 00h
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh
		db	 07h, 07h, 07h, 00h, 00h, 1Fh
		db	 1Fh, 00h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

pal_process_loop		proc	near
		push	cx
		mov	cx,2

locloop_118:
		rol	word ptr cs:data_36e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_35e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_34e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_33e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_36e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_35e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_34e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_33e,1	; Rotate
		adc	ax,ax
		loop	locloop_118		; Loop if cx > 0

		xchg	ah,al
		pop	cx
		retn
pal_process_loop		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

pal_func_21		proc	near
		rol	word ptr cs:data_37e,1	; Rotate
		sbb	al,al
		rol	word ptr cs:data_37e,1	; Rotate
		sbb	ah,ah
		or	al,ah
		rol	word ptr cs:data_37e,1	; Rotate
		sbb	dl,dl
		rol	word ptr cs:data_37e,1	; Rotate
		sbb	ah,ah
		or	ah,dl
		retn
pal_func_21		endp

			                        ;* No entry point to code
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		xor	ax,ax			; Zero register
		mov	di,data_54e
		mov	cx,8000h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
		db	 2Eh,0FFh, 26h, 22h, 20h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

pal_multiply_4		proc	near
		mov	dl,bl
		mov	bl,bh
		xor	bh,bh			; Zero register
		mov	dh,bh
		add	bx,bx
		add	bx,bx
		mov	ax,140h
		mul	dx			; dx:ax = reg * ax
		add	ax,bx
		retn
pal_multiply_4		endp

		db	0C3h
		db	2900 dup (0)
data_17		db	0			; Data table (indexed access)
		db	392 dup (0)

seg_a		ends



		end	start
