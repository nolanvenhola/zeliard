
PAGE  59,132

;==========================================================================
;
;  IMAGE_CONTROLLER - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	63h
data_12e	equ	2050h			;*
data_13e	equ	2A80h			;*
data_14e	equ	32A7h			;*
data_15e	equ	32AFh			;*
data_16e	equ	35ADh			;*
data_17e	equ	35AFh			;*
data_18e	equ	35CDh			;*
data_19e	equ	3A6Ch			;*
data_20e	equ	3B30h			;*
data_21e	equ	3B63h			;*
data_22e	equ	3B64h			;*
data_23e	equ	416Ah			;*
data_24e	equ	4210h			;*
data_25e	equ	4211h			;*
data_26e	equ	4212h			;*
data_27e	equ	4213h			;*
data_28e	equ	4214h			;*
data_29e	equ	4216h			;*
data_31e	equ	4218h			;*
data_32e	equ	421Ah			;*
data_33e	equ	421Ch			;*
data_34e	equ	453Ch			;*
data_35e	equ	455Eh			;*
data_36e	equ	0A000h			;*
data_37e	equ	0BF07h			;*
data_38e	equ	0F500h			;*
data_39e	equ	0FF1Ah			;*
data_40e	equ	0FF2Ch			;*
data_41e	equ	1A6Eh			;*
data_42e	equ	1A8Fh			;*
data_43e	equ	1A90h			;*
data_44e	equ	13Fh
data_45e	equ	140h
data_46e	equ	141h
data_47e	equ	504h
data_48e	equ	0FEBFh
data_49e	equ	0FEC0h
data_50e	equ	0FEC1h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_01		proc	far

start:
		adc	byte ptr [di],0
		add	[bp+si],dh
		xor	[bp+si+30h],cl
		sahf				; Store ah into flags
;*		xor	dh,bh
		db	 30h,0FEh		;  Fixup - byte match
		xor	[si],dh
		inc	cx
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		inc	dx
		mov	bh,32h			; '2'
		cmc				; Complement carry
		xor	al,[bp+si+33h]
		lodsw				; String [si] to ax
		xor	dx,bp
		xor	ax,3622h
		db	 6Fh, 36h, 26h, 31h, 9Ah, 36h
		db	 1Ch, 37h, 16h, 38h, 69h, 3Bh
		db	 7Fh, 3Ch,0A1h, 3Dh,0F7h, 3Dh
		db	0B1h, 3Fh, 75h, 40h, 0Dh, 41h
		db	 0Ah, 42h,0BAh,0CEh, 03h,0B8h
		db	 05h, 00h,0EFh,0B8h, 03h, 00h
		db	0EFh,0B8h, 08h,0FFh,0EFh,0B8h
		db	 07h, 0Fh,0EFh,0B8h, 02h, 0Fh
		db	0EFh,0C3h, 50h,0BAh,0C4h, 03h
		db	0B8h, 02h, 0Fh,0EFh,0BAh,0CEh
		db	 03h,0B8h, 05h, 02h,0EFh, 2Eh
		db	0C7h, 06h, 16h, 42h, 71h, 30h
		db	 58h,0E8h, 5Dh, 01h,0B8h, 03h
		db	 00h,0EFh,0B8h, 05h, 00h,0EFh
		db	0B8h, 08h,0FFh,0EFh,0C3h, 2Eh
		db	0F6h, 06h, 13h, 42h,0FFh, 74h
		db	 0Bh, 50h,0B8h, 03h, 00h,0EFh
		db	 58h, 32h,0FFh,0E8h,0ECh, 01h
loc_1:
		push	ax
		mov	ax,1003h
		out	dx,ax			; port 1, DMA-1 bas&cnt ch 0
		pop	ax
		push	si
		mov	bh,1
		call	imgctl_process_loop_2
		pop	si
		push	si
		add	si,cs:data_28e
		mov	bh,8
		call	imgctl_process_loop_2
		pop	si
		retn
			                        ;* No entry point to code
		push	ax
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	word ptr cs:data_29e,30C5h
		pop	ax
		call	imgctl_multiply
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn
			                        ;* No entry point to code
		test	byte ptr cs:data_27e,0FFh
		jz	loc_2			; Jump if zero
		push	ax
		mov	ax,3
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		pop	ax
		xor	bh,bh			; Zero register
		call	imgctl_process_loop
loc_2:
		push	ax
		mov	ax,1003h
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		pop	ax
		push	si
		mov	bh,1
		call	imgctl_process_loop_2
		pop	si
		push	si
		add	si,cs:data_28e
		push	si
		mov	bh,2
		call	imgctl_process_loop_2
		pop	si
		add	si,cs:data_28e
		mov	bh,4
		call	imgctl_process_loop_2
		pop	si
		retn
			                        ;* No entry point to code
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	word ptr cs:data_29e,3121h
		mov	al,0FFh
		call	imgctl_multiply
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn
			                        ;* No entry point to code
		xor	bh,bh			; Zero register
		jmp	loc_10
			                        ;* No entry point to code
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	word ptr cs:data_29e,314Dh
		xor	al,al			; Zero register
		call	imgctl_multiply
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn
			                        ;* No entry point to code
		push	cx
		push	di
		push	bp
		push	si
		push	ax
		mov	ax,1003h
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		pop	ax
		mov	bp,cs:data_28e
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_3:
		push	cx
		push	ax
		lodsb				; String [si] to al
		and	al,ah
		mov	ch,al
		mov	cl,ds:[bp+si-1]
		and	cl,ah
		mov	bh,cl
		and	bh,ch
		mov	bl,cl
		or	bl,ch
		not	bh
		and	ch,bh
		and	cl,bh
		and	bl,ah
		test	byte ptr cs:data_27e,0FFh
		jz	loc_4			; Jump if zero
		mov	ax,3
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		mov	al,8
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		inc	dx
		mov	al,bl
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
		dec	dx
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	ax,1003h
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
loc_4:
		mov	al,8
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		inc	dx
		mov	al,ch
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
		mov	al,2
		xchg	es:[di],al
		mov	al,cl
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
		mov	al,4
		xchg	es:[di],al
		mov	al,bl
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
		mov	al,8
		xchg	es:[di],al
		dec	dx
		inc	di
		pop	ax
		pop	cx
		loop	locloop_3		; Loop if cx > 0

		pop	si
		pop	bp
		pop	di
		pop	cx
		retn

zr1_01		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_multiply		proc	near
		push	ds
		push	ax
		push	es
		push	di
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	cs:data_28e,ax
		pop	si
		pop	ds
		pop	ax
		mov	byte ptr cs:data_27e,0
		or	al,al			; Zero ?
		jnz	loc_5			; Jump if not zero
		call	vga_operation
loc_5:
		mov	byte ptr cs:data_27e,0FFh
		call	vga_operation
		pop	ds
		retn
imgctl_multiply		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation		proc	near
		mov	byte ptr cs:data_25e,0
		mov	ax,0A000h
		mov	es,ax
		mov	bp,8
loc_6:
		mov	al,cs:data_25e
		mov	cs:data_24e,al
		mov	byte ptr cs:data_39e,0
		push	cx
		push	si
		push	di
loc_7:
		mov	bl,cs:data_24e
		and	bx,7
		mov	ah,cs:data_14e[bx]
		call	word ptr cs:data_29e
		inc	byte ptr cs:data_24e
		mov	al,ch
		xor	ah,ah			; Zero register
		add	si,ax
		add	di,50h
		dec	cl
		jz	loc_8			; Jump if zero
		mov	bl,cs:data_24e
		and	bx,7
		mov	ah,cs:data_15e[bx]
		call	word ptr cs:data_29e
		inc	byte ptr cs:data_24e
		mov	al,ch
		xor	ah,ah			; Zero register
		add	si,ax
		add	di,50h
		dec	cl
		jnz	loc_7			; Jump if not zero
loc_8:
		pop	di
		pop	si
		pop	cx
		inc	byte ptr cs:data_25e
loc_9:
		cmp	byte ptr cs:data_39e,14h
		jb	loc_9			; Jump if below
		dec	bp
		jnz	loc_6			; Jump if not zero
		retn
vga_operation		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_process_loop		proc	near
loc_10:
		push	di
		push	cx
		push	ax
		mov	al,8
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		inc	dx
		mov	al,ah
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_11:
		mov	al,bh
		xchg	es:[di],al
		inc	di
		loop	locloop_11		; Loop if cx > 0

		dec	dx
		pop	ax
		pop	cx
		pop	di
		retn
imgctl_process_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_process_loop_2		proc	near
		push	di
		push	cx
		push	ax
		mov	al,8
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
		inc	dx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_12:
		lodsb				; String [si] to al
		and	al,ah
		out	dx,al			; port 2, DMA-1 bas&add ch 1
		mov	al,bh
		xchg	es:[di],al
		inc	di
		loop	locloop_12		; Loop if cx > 0

		dec	dx
		pop	ax
		pop	cx
		pop	di
		retn
imgctl_process_loop_2		endp

			                        ;* No entry point to code
		and	byte ptr [bx+si],8
		add	al,[bx+si+10h]
		add	al,1
		add	[si],ax
		adc	[bx+si+2],al
		or	[bx+si],ah
		or	byte ptr ds:data_37e,1Ch
		inc	dx
		xor	ax,ax			; Zero register
		mov	cx,190h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	di,data_33e
loc_13:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_14			; Jump if not equal
		retn
loc_14:
		sub	al,20h			; ' '
		jnc	loc_15			; Jump if carry=0
		retn
loc_15:
		jz	loc_17			; Jump if zero
		push	si
		push	di
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:data_38e
		mov	si,ax
		mov	cx,8

locloop_16:
		movsw				; Mov [si] to es:[di]
		add	di,4Eh
		loop	locloop_16		; Loop if cx > 0

		pop	di
		pop	si
loc_17:
		add	di,2
		jmp	short loc_13
			                        ;* No entry point to code
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,421Ch
		mov	si,ax
		mov	al,bl
		mul	dl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	dx,3C4h
		mov	ax,402h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,204h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		push	si
		push	ds
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		dec	cl
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

locloop_18:
		push	cx
		push	di
		mov	si,di
		add	si,50h
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		add	di,50h
		pop	cx
		loop	locloop_18		; Loop if cx > 0

		pop	ds
		pop	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
loc_19:
		push	ds
		push	es
		push	di
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	cs:data_28e,ax
		pop	si
		pop	ds
		call	copy_vga_buffer
		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_vga_buffer		proc	near
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

locloop_20:
		push	cx
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		push	si
		push	di
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		push	si
		push	di
		add	si,cs:data_28e
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		push	si
		push	di
		add	si,cs:data_28e
		add	si,cs:data_28e
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		pop	cx
		add	di,50h
		add	si,bx
		loop	locloop_20		; Loop if cx > 0

		retn
copy_vga_buffer		endp

			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_36e
		xor	dx,dx			; Zero register
		mov	cx,9

locloop_21:
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
		add	dx,240h
		loop	locloop_21		; Loop if cx > 0

		mov	byte ptr ds:data_24e,0
		mov	byte ptr ds:data_39e,0
loc_22:
		mov	si,data_36e
		mov	cx,9
loc_23:
		push	cx
		test	byte ptr [si],0FFh
		jnz	loc_24			; Jump if not zero
		jmp	loc_26
loc_24:
		mov	al,[si+0Dh]
		cmp	al,[si+0Eh]
		je	loc_25			; Jump if equal
		inc	byte ptr [si+0Ch]
		test	byte ptr [si+0Ch],1
		jnz	loc_25			; Jump if not zero
		inc	byte ptr [si+0Dh]
loc_25:
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	cx,ds:data_17e[bx]
		mov	[si+7],cx
		mov	al,[si+4]
		add	al,[si+0Ah]
		mov	[si+4],al
		mov	dh,al
		mov	al,[si+3]
		add	al,[si+9]
		mov	[si+3],al
		mov	dl,al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	bp,ax
		add	ax,ax
		add	ax,ax
		add	ax,bp
		add	ax,ax
		mov	dl,dh
		xor	dh,dh			; Zero register
		add	ax,dx
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
		mov	dx,3CEh
		mov	al,4
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		inc	dx
		mov	si,di
		mov	di,bp
		mov	al,0
		out	dx,al			; port 3CFh, EGA graphic func
		call	copy_buffer
		mov	al,1
		out	dx,al			; port 3CFh, EGA graphic func
		call	copy_buffer
		mov	al,2
		out	dx,al			; port 3CFh, EGA graphic func
		call	copy_buffer
		pop	si
		pop	ds
loc_26:
		pop	cx
		add	si,0Fh
		loop	locloop_27		; Loop if cx > 0

		jmp	short loc_28

locloop_27:
		jmp	loc_23
loc_28:
		mov	si,data_36e
		mov	cx,9

locloop_29:
		push	cx
		push	si
		mov	al,ds:data_24e
		and	al,7
		mov	bx,data_18e
		xlat				; al=[al+[bx]] table
		mov	ds:data_23e,al
		inc	byte ptr ds:data_24e
		xor	ax,ax			; Zero register
		call	vga_operation4
		pop	si
		test	byte ptr cs:[si],0FFh
		jz	loc_30			; Jump if zero
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	bp,ds:data_16e[bx]
		mov	cx,[si+7]
		mov	dl,[si]
		mov	byte ptr [si],0
		mov	ax,[si+3]
		cmp	ah,4Bh			; 'K'
		jae	loc_30			; Jump if above or =
		cmp	al,0A0h
		jae	loc_30			; Jump if above or =
		mov	[si],dl
		mov	di,[si+5]
		push	ds
		push	si
		mov	ax,0A000h
		mov	es,ax
		mov	ds,cs:data_40e
		mov	si,bp
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,4
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		call	imgctl_process_loop_3
		mov	dx,3C4h
		mov	ax,202h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,104h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		call	imgctl_process_loop_3
		pop	si
		pop	ds
loc_30:
		pop	cx
		add	si,0Fh
		loop	locloop_29		; Loop if cx > 0

loc_31:
		cmp	byte ptr cs:data_39e,1Eh
		jb	loc_31			; Jump if below
		mov	byte ptr cs:data_39e,0
		mov	si,data_36e
		mov	cx,9

locloop_32:
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
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		call	copy_buffer_2
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		call	copy_buffer_2
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		call	copy_buffer_2
		pop	si
		pop	ds
		pop	cx
		add	si,0Fh
		loop	locloop_32		; Loop if cx > 0

		mov	si,data_36e
		mov	cx,9

locloop_33:
		test	byte ptr [si],0FFh
		jz	loc_34			; Jump if zero
		jmp	loc_22
loc_34:
		add	si,0Fh
		loop	locloop_33		; Loop if cx > 0

		mov	ax,2
		jmp	loc_101

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_buffer		proc	near
		push	si
		push	cx
loc_35:
		push	si
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	si
		add	si,50h
		dec	cl
		jnz	loc_35			; Jump if not zero
		pop	cx
		pop	si
		retn
copy_buffer		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_buffer_2		proc	near
		push	di
		push	cx
loc_36:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	di
		add	di,50h
		dec	cl
		jnz	loc_36			; Jump if not zero
		pop	cx
		pop	di
		retn
copy_buffer_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_process_loop_3		proc	near
		push	di
		push	cx
loc_37:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_38:
		lodsb				; String [si] to al
		or	es:[di],al
		inc	di
		loop	locloop_38		; Loop if cx > 0

		pop	cx
		pop	di
		add	di,50h
		dec	cl
		jnz	loc_37			; Jump if not zero
		pop	cx
		pop	di
		retn
imgctl_process_loop_3		endp

		db	 00h, 90h, 20h, 06h, 80h, 91h
		db	 20h, 06h, 00h, 93h, 20h, 06h
		db	 80h, 94h, 20h, 06h, 00h, 96h
		db	 18h, 04h,0C0h, 96h, 18h, 04h
		db	 80h, 97h, 18h, 04h, 40h, 98h
		db	 18h, 04h, 36h, 06h, 3Fh, 07h
		db	 2Dh, 05h, 24h, 04h, 1Eh, 32h
		db	0E4h,0BAh,0C0h, 0Ch,0F7h,0E2h
		db	 05h, 40h,0ABh, 2Eh, 8Eh, 1Eh
		db	 2Ch,0FFh, 8Bh,0F0h,0B8h, 50h
		db	 00h,0F6h,0E3h, 8Ah,0DFh, 32h
		db	0FFh, 03h,0C3h, 8Bh,0F8h,0B8h
		db	 00h,0A0h, 8Eh,0C0h,0BAh,0C4h
		db	 03h,0B0h, 02h,0EEh, 42h,0B0h
		db	 02h,0EEh,0E8h, 08h, 00h,0B0h
		db	 01h,0EEh,0E8h, 02h, 00h, 1Fh
		db	0C3h, 57h,0B9h, 30h, 00h

locloop_39:
		push	di
		push	cx
		mov	cx,11h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	di
		add	di,50h
		loop	locloop_39		; Loop if cx > 0

		pop	di
		retn
			                        ;* No entry point to code
		push	ds
		xor	ah,ah			; Zero register
		mov	dx,480h
		mul	dx			; dx:ax = reg * ax
		add	ax,97C0h
		mov	ds,cs:data_40e
		mov	si,ax
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		call	copy_buffer_3
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		call	copy_buffer_3
		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_buffer_3		proc	near
		push	di
		mov	cx,20h

locloop_40:
		push	di
		push	cx
		mov	cx,9
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	di
		add	di,50h
		loop	locloop_40		; Loop if cx > 0

		pop	di
		retn
copy_buffer_3		endp

			                        ;* No entry point to code
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		xor	di,di			; Zero register
		mov	bx,2288h
		mov	cx,64h

locloop_41:
		push	cx
		mov	al,bh
		mov	ah,bh
		mov	cx,28h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	al,bl
		mov	ah,bl
		mov	cx,28h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	cx
		loop	locloop_41		; Loop if cx > 0

		retn
		db	 33h,0DBh,0B9h, 19h, 00h

locloop_42:
		push	cx
		mov	cx,22h

locloop_43:
		push	cx
		lodsb				; String [si] to al
		push	bx
		push	ds
		push	si
		call	imgctl_multiply_2
		pop	si
		pop	ds
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_43		; Loop if cx > 0

		xor	bh,bh			; Zero register
		inc	bl
		pop	cx
		loop	locloop_42		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_multiply_2		proc	near
		mov	ds,cs:data_40e
		mov	dx,cs
		add	dx,2000h
		mov	es,dx
		xor	ah,ah			; Zero register
loc_44:
		sub	al,28h			; '('
		jc	loc_45			; Jump if carry Set
		inc	ah
		jmp	short loc_44
loc_45:
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

locloop_46:
		push	cx
		push	di
		push	si
		mov	cx,8

locloop_47:
		movsb				; Mov [si] to es:[di]
		add	di,21h
		add	si,27h
		loop	locloop_47		; Loop if cx > 0

		pop	si
		pop	di
		add	di,1A90h
		add	si,640h
		pop	cx
		loop	locloop_46		; Loop if cx > 0

		retn
imgctl_multiply_2		endp

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
		mov	di,data_34e
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,data_41e
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,data_34e
		mov	cx,44h

locloop_48:
		mov	al,es:[di]
		mov	dx,8
loc_49:
		ror	al,1			; Rotate
		adc	ah,ah
		dec	dx
		jnz	loc_49			; Jump if not zero
		mov	es:[di],ah
		inc	di
		loop	locloop_48		; Loop if cx > 0

		pop	si
		pop	ax
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		push	si
		push	di
		mov	cx,22h

locloop_50:
		lodsb				; String [si] to al
		mov	bl,al
		or	al,ds:data_42e[si]
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,bl
		and	al,ds:data_42e[si]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,0Fh
		xchg	es:[di],al
		inc	di
		loop	locloop_50		; Loop if cx > 0

		pop	di
		pop	si
		dec	dx
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		add	si,data_43e
		push	di
		mov	cx,22h

locloop_51:
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,0Eh
		xchg	es:[di],al
		inc	di
		loop	locloop_51		; Loop if cx > 0

		pop	di
		push	cs
		pop	ds
		add	di,4Fh
		dec	dx
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	si,data_34e
		push	di
		mov	cx,22h

locloop_52:
		lodsb				; String [si] to al
		mov	bl,al
		or	al,[si+21h]
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,bl
		and	al,[si+21h]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,0Fh
		xchg	es:[di],al
		dec	di
		loop	locloop_52		; Loop if cx > 0

		pop	di
		dec	dx
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	si,data_35e
		mov	cx,22h

locloop_53:
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,0Eh
		xchg	es:[di],al
		dec	di
		loop	locloop_53		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	ds
		retn
			                        ;* No entry point to code
		mov	bx,ax
		add	bx,bx
		mov	al,ds:data_21e[bx]
		mov	ds:data_25e,al
		mov	al,ds:data_22e[bx]
		mov	ds:data_24e,al
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	di,data_47e
		mov	si,data_19e
loc_54:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_55			; Jump if zero
		call	imgctl_func_11
		add	di,140h
		jmp	short loc_54
loc_55:
		add	di,data_50e
loc_56:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_57			; Jump if zero
		call	imgctl_func_11
		inc	di
		jmp	short loc_56
loc_57:
		add	di,data_48e
loc_58:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_59			; Jump if zero
		call	imgctl_func_11
		add	di,0FEC0h
		jmp	short loc_58
loc_59:
		add	di,data_44e
loc_60:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_61			; Jump if zero
		call	imgctl_func_11
		dec	di
		jmp	short loc_60
loc_61:
		add	di,data_46e
		mov	si,data_20e
loc_62:
		mov	byte ptr cs:data_39e,0
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_68			; Jump if zero
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_63:
		push	cx
		mov	al,18h
		call	imgctl_func_11
		add	di,140h
		pop	cx
		loop	locloop_63		; Loop if cx > 0

		add	di,data_49e
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_68			; Jump if zero
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_64:
		push	cx
		mov	al,18h
		call	imgctl_func_11
		inc	di
		pop	cx
		loop	locloop_64		; Loop if cx > 0

		dec	di
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_68			; Jump if zero
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_65:
		push	cx
		mov	al,18h
		call	imgctl_func_11
		add	di,0FEC0h
		pop	cx
		loop	locloop_65		; Loop if cx > 0

		add	di,data_45e
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_68			; Jump if zero
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_66:
		push	cx
		mov	al,18h
		call	imgctl_func_11
		dec	di
		pop	cx
		loop	locloop_66		; Loop if cx > 0

		inc	di
loc_67:
		cmp	byte ptr cs:data_39e,0Ch
		jb	loc_67			; Jump if below
		jmp	short loc_62
loc_68:
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_func_11		proc	near
		push	si
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,39ACh
		mov	si,ax
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		push	di
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,50h
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,50h
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,50h
		xor	al,al			; Zero register
		xchg	es:[di],al
		pop	di
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		push	di
		mov	ah,cs:data_24e
		ror	ah,1			; Rotate
		lodsb				; String [si] to al
		and	al,cs:data_24e
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_25e
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		and	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_25e
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		and	al,cs:data_24e
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_25e
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		and	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_25e
		xchg	es:[di],al
		pop	di
		push	di
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,6
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,6
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,6
		xchg	es:[di],al
		add	di,50h
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,6
		xchg	es:[di],al
		pop	di
		dec	dx
		pop	si
		retn
imgctl_func_11		endp

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
		db	 1Eh, 2Eh,0A2h, 13h, 42h, 81h
		db	0EBh, 10h, 04h, 2Eh,0C6h, 06h
		db	 11h, 42h, 00h, 2Eh,0C6h, 06h
		db	 12h, 42h, 00h, 2Eh, 89h, 0Eh
		db	 16h, 42h, 8Ah,0C5h,0F6h,0E1h
		db	 2Eh,0A3h, 14h, 42h, 06h, 1Fh
		db	 57h, 5Eh,0B8h, 00h,0A0h, 8Eh
		db	0C0h,0B9h, 08h, 00h

locloop_69:
		push	cx
		mov	al,cs:data_26e
		mov	cs:data_25e,al
		mov	byte ptr cs:data_39e,0
		mov	cx,0Dh

locloop_70:
		push	cx
		push	bx
		push	si
		call	imgctl_multiply_3
		pop	si
		pop	bx
		pop	cx
		add	byte ptr cs:data_25e,8
		loop	locloop_70		; Loop if cx > 0

		pop	cx
loc_71:
		cmp	byte ptr cs:data_39e,14h
		jb	loc_71			; Jump if below
		inc	byte ptr cs:data_26e
		loop	locloop_69		; Loop if cx > 0

		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_multiply_3		proc	near
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	al,cs:data_25e
		add	al,10h
		mov	cl,50h			; 'P'
		mul	cl			; ax = reg * al
		add	ax,4
		mov	di,ax
		cmp	cs:data_25e,bl
		jae	loc_72			; Jump if above or =
		jmp	loc_78
loc_72:
		mov	al,bl
		add	al,cs:data_29e
		cmp	cs:data_25e,al
		jae	loc_78			; Jump if above or =
		mov	al,cs:data_25e
		sub	al,bl
		mul	byte ptr cs:data_29e+1	; ax = data * al
		add	si,ax
		mov	byte ptr cs:data_24e,0
		mov	cx,48h

locloop_73:
		push	cx
		mov	al,0Fh
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	byte ptr es:[di],0
		cmp	cs:data_24e,bh
		jb	loc_77			; Jump if below
		mov	al,bh
		add	al,byte ptr cs:data_29e+1
		cmp	cs:data_24e,al
		jae	loc_77			; Jump if above or =
		push	si
		test	byte ptr cs:data_27e,1
		jz	loc_74			; Jump if zero
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	al,[si]
		mov	es:[di],al
		add	si,cs:data_28e
loc_74:
		test	byte ptr cs:data_27e,2
		jz	loc_75			; Jump if zero
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	al,[si]
		mov	es:[di],al
		add	si,cs:data_28e
loc_75:
		test	byte ptr cs:data_27e,4
		jz	loc_76			; Jump if zero
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	al,[si]
		mov	es:[di],al
loc_76:
		pop	si
		inc	si
loc_77:
		inc	di
		inc	byte ptr cs:data_24e
		pop	cx
		loop	locloop_73		; Loop if cx > 0

		retn
loc_78:
		mov	al,0Fh
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,24h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
imgctl_multiply_3		endp

			                        ;* No entry point to code
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	cs:data_25e,bl
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0A000h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register
		sub	cx,5
		push	cx
		push	di
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		call	imgctl_process_loop_4
		pop	di
		inc	byte ptr cs:data_25e
		add	di,50h
		mov	cx,2
		call	imgctl_process_loop_5
		pop	cx

locloop_79:
		push	cx
		call	imgctl_func_15
		mov	al,30h			; '0'
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,7
		xchg	es:[di],al
		mov	al,0Fh
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,0Ch
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,7
		xchg	es:[bx+di-1],al
		mov	al,0F0h
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[bx+di-1],al
		inc	byte ptr cs:data_25e
		add	di,50h
		pop	cx
		loop	locloop_79		; Loop if cx > 0

		mov	cx,1
		call	imgctl_process_loop_5
		call	imgctl_process_loop_4
		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_process_loop_4		proc	near
		call	imgctl_func_15
		mov	al,3Fh			; '?'
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,7
		xchg	es:[di],al
		inc	di
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	cx,bx
		sub	cx,2

locloop_80:
		mov	al,7
		xchg	es:[di],al
		inc	di
		loop	locloop_80		; Loop if cx > 0

		mov	al,0FCh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,7
		xchg	es:[di],al
		retn
imgctl_process_loop_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_process_loop_5		proc	near

locloop_81:
		push	cx
		push	di
		call	imgctl_func_15
		mov	al,30h			; '0'
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,7
		xchg	es:[di],al
		mov	al,0Fh
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di],al
		inc	di
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	cx,bx
		sub	cx,2

locloop_82:
		xor	al,al			; Zero register
		xchg	es:[di],al
		inc	di
		loop	locloop_82		; Loop if cx > 0

		mov	al,0Ch
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,7
		xchg	es:[di],al
		mov	al,0F0h
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di],al
		pop	di
		inc	byte ptr cs:data_25e
		add	di,50h
		pop	cx
		loop	locloop_81		; Loop if cx > 0

		retn
imgctl_process_loop_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_func_15		proc	near
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di-1],al
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,55h			; 'U'
		mov	cl,cs:data_25e
		and	cl,1
		ror	al,cl			; Rotate
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di-1],al
		mov	al,2
		xchg	es:[di],al
		retn
imgctl_func_15		endp

			                        ;* No entry point to code
		push	bx
		push	es
		push	di
		mov	cx,1028h

locloop_83:
		mov	al,es:[di]
		and	al,byte ptr es:[1028h][di]
		mov	ah,es:data_12e[di]
		not	ah
		and	al,ah
		not	al
		and	es:[di],al
		and	byte ptr es:[1028h][di],al
		and	es:data_12e[di],al
		mov	al,es:data_12e[di]
		mov	ah,es:[di]
		not	ah
		and	al,ah
		mov	ah,byte ptr es:[1028h][di]
		not	ah
		and	al,ah
		or	es:[di],al
		or	byte ptr es:[1028h][di],al
		not	al
		and	es:data_12e[di],al
		inc	di
		loop	locloop_83		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,2F58h
		jmp	loc_19
			                        ;* No entry point to code
		push	ds
		mov	ds:data_31e,di
		mov	ds:data_32e,es
		mov	di,69Ah
		add	di,ds:data_31e
		call	imgctl_process_loop_6
		mov	di,6BCh
		add	di,ds:data_31e
		call	imgctl_process_loop_6
		mov	ax,0A000h
		mov	es,ax
		mov	ds,cs:data_32e
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	cx,44h

locloop_84:
		push	cx
		mov	byte ptr cs:data_39e,0
		mov	ax,44h
		sub	ax,cx
		add	ax,ax
		push	ax
		mov	bl,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	di,ax
		add	ax,cs:data_31e
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	loc_85			; Jump if below
		cmp	ax,71h
		jae	loc_85			; Jump if above or =
		call	copy_buffer_5
		jmp	short loc_86
loc_85:
		call	copy_buffer_4
loc_86:
		pop	cx
		push	cx
		mov	ax,cx
		add	ax,ax
		dec	ax
		push	ax
		mov	bl,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	di,ax
		add	ax,cs:data_31e
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	loc_87			; Jump if below
		cmp	ax,71h
		jae	loc_87			; Jump if above or =
		call	copy_buffer_5
		jmp	short loc_88
loc_87:
		call	copy_buffer_4
loc_88:
		cmp	byte ptr cs:data_39e,4
		jb	loc_88			; Jump if below
		pop	cx
		loop	locloop_84		; Loop if cx > 0

		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_buffer_4		proc	near
		push	si
		push	di
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,50h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	si,data_13e
		push	si
		push	di
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,50h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	si,data_13e
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,50h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
copy_buffer_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_buffer_5		proc	near
		push	si
		push	di
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Ah
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	si,data_13e
		push	si
		push	di
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Ah
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	si,data_13e
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Ah
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,18h
		add	di,18h
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
copy_buffer_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

imgctl_process_loop_6		proc	near
		push	di
		mov	ax,0FC3Fh
		call	fill_buffer
		add	di,36h
		mov	cx,5Bh

locloop_89:
		mov	byte ptr es:[di],30h	; '0'
		mov	byte ptr es:[di+19h],0Ch
		add	di,50h
		loop	locloop_89		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer
		pop	di
		add	di,data_13e
		push	di
		mov	ax,0FD7Fh
		call	fill_buffer
		add	di,36h
		mov	cx,2Dh

locloop_90:
		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	byte ptr es:[di],70h	; 'p'
		mov	byte ptr es:[di+19h],0Dh
		add	di,50h
		loop	locloop_90		; Loop if cx > 0

		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	ax,0FD7Fh
		call	fill_buffer
		pop	di
		add	di,data_13e
		mov	ax,0FC3Fh
		call	fill_buffer
		add	di,36h
		mov	cx,5Bh

locloop_91:
		mov	byte ptr es:[di],30h	; '0'
		mov	byte ptr es:[di+19h],0Ch
		add	di,50h
		loop	locloop_91		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer
		retn
imgctl_process_loop_6		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

fill_buffer		proc	near
		stosb				; Store al to es:[di]
		mov	al,0FFh
		mov	cx,18h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,ah
		stosb				; Store al to es:[di]
		retn
fill_buffer		endp

			                        ;* No entry point to code
		push	ds
		mov	ds:data_31e,di
		mov	ds:data_32e,es
		mov	ax,0A000h
		mov	es,ax
		mov	ds,cs:data_32e
		mov	cx,39h

locloop_92:
		mov	byte ptr cs:data_39e,0
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,39h
		add	ax,ax
		call	vga_operation0
		pop	ax
		push	ax
		add	ax,ax
		dec	ax
		call	vga_operation0
loc_93:
		cmp	byte ptr cs:data_39e,4
		jb	loc_93			; Jump if below
		pop	cx
		loop	locloop_92		; Loop if cx > 0

		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation0		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,cs:data_31e
		mov	si,ax
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	di,ax
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,4
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		pop	ax
		push	ax
		push	di
		push	si
		call	vga_operation1
		pop	si
		pop	di
		add	si,14EEh
		mov	dx,3C4h
		mov	ax,202h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,104h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		pop	ax
		push	ax
		push	di
		push	si
		call	vga_operation1
		pop	si
		pop	di
		add	si,offset data_11
		mov	dx,3C4h
		mov	ax,402h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,204h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		pop	ax

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vga_operation1:
		cmp	ax,14h
		jae	loc_94			; Jump if above or =
		mov	cx,2Fh
		jmp	short loc_95
loc_94:
		mov	cx,23h
		cmp	ax,17h
		jb	loc_95			; Jump if below
		cmp	ax,1Ch
		jb	loc_96			; Jump if below
		mov	cx,21h
loc_95:
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
loc_96:
		mov	cx,21h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		lodsb				; String [si] to al
		and	al,0FCh
		and	byte ptr es:[di],3
		or	es:[di],al
		retn
vga_operation0		endp

			                        ;* No entry point to code
		push	ds
		mov	ds:data_31e,di
		mov	ds:data_32e,es
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	ds,cs:data_32e
		mov	cx,39h

locloop_97:
		mov	byte ptr cs:data_39e,0
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,39h
		add	ax,ax
		call	vga_operation2
		pop	ax
		push	ax
		add	ax,ax
		dec	ax
		call	vga_operation2
loc_98:
		cmp	byte ptr cs:data_39e,4
		jb	loc_98			; Jump if below
		pop	cx
		loop	locloop_97		; Loop if cx > 0

		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation2		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,3CDh
		add	ax,cs:data_31e
		mov	si,ax
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	ax,661h
		mov	di,ax
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	ax
		push	ax
		push	di
		push	si
		call	vga_operation3
		pop	si
		pop	di
		add	si,14EEh
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	ax
		push	ax
		push	di
		push	si
		call	vga_operation3
		pop	si
		pop	di
		add	si,offset data_11
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		pop	ax

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vga_operation3:
		cmp	ax,5Eh
		mov	cx,2Fh
		jnc	loc_99			; Jump if carry=0
		mov	cx,0Eh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	cx,21h
loc_99:
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn
vga_operation2		endp

			                        ;* No entry point to code
		push	ax
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		pop	ax
		mov	ah,al
		mov	cx,8

locloop_100:
		stosw				; Store ax to es:[di]
		add	di,4Eh
		loop	locloop_100		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation4		proc	near
loc_101:
		pushf				; Push flags
		cli				; Disable interrupts
		mov	dx,10h
		mul	dx			; dx:ax = reg * ax
		add	ax,416Ah
		mov	si,ax
		mov	ax,40h
		mov	es,ax
		mov	dx,es:data_1e
		add	dx,6
		push	dx
		in	al,dx			; port 3DAh, CGA/EGA vid status
		mov	dx,3C0h
		xor	ah,ah			; Zero register
		mov	cx,10h

locloop_102:
		mov	al,ah
		out	dx,al			; port 3C0h, EGA attributes
		lodsb				; String [si] to al
		out	dx,al			; port 3C0h, EGA attributes
		inc	ah
		loop	locloop_102		; Loop if cx > 0

		pop	dx
		in	al,dx			; port 3DAh, CGA/EGA vid status
		mov	al,20h			; ' '
		mov	dx,3C0h
		out	dx,al			; port 3C0h, EGA attributes
		popf				; Pop flags
		retn
vga_operation4		endp

		db	 00h, 03h, 09h, 3Fh, 00h, 1Bh
		db	 36h, 3Fh, 38h, 07h, 24h, 2Dh
		db	 12h, 1Bh, 06h, 07h, 00h
		db	9, '$'
		db	'-????8'
		db	 07h, 24h, 2Dh, 3Fh, 3Fh, 3Fh
		db	 3Fh, 00h, 09h, 24h, 2Dh, 00h
		db	 1Bh, 36h, 3Fh, 38h, 07h, 24h
		db	 2Dh, 12h, 1Bh, 06h, 07h, 00h
		db	 24h, 09h, 3Fh, 09h, 3Fh, 00h
		db	 3Fh, 38h, 3Fh, 24h, 2Dh, 12h
		db	 1Bh, 36h, 07h, 00h, 01h, 04h
		db	 05h, 03h, 03h
		db	'6?8', 9, '$'
		db	'-', 1Bh, 1Bh
		db	 06h, 3Fh, 00h, 09h, 24h, 03h
		db	 12h
		db	1Bh, '6?8', 9, '$'
		db	'-', 1Bh, 1Bh, '6?'
		db	 00h, 09h, 24h, 2Dh, 00h
		db	1Bh, '6?8', 9, '$'
		db	'-', 1Bh, 1Bh, '6?'
		db	 00h, 09h, 24h, 2Dh, 12h, 1Bh
		db	 36h, 3Fh, 38h, 07h, 24h, 2Dh
		db	 3Fh, 3Fh, 3Fh, 3Fh, 00h, 09h
		db	 24h, 12h, 00h
		db	1Bh, '6?8', 9, '$'
		db	'-', 1Bh, 1Bh, '6?'
		db	 00h, 09h, 24h, 04h, 12h
		db	'$'
		db	'6?8', 9, '$'
		db	'-', 1Bh, 1Bh, '6?.'
		db	0FFh, 26h, 22h, 20h,0C3h
		db	730 dup (0)
data_11		db	0
		db	149 dup (0)

seg_a		ends



		end	start
