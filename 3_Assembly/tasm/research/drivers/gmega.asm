
PAGE  59,132

;==========================================================================
;
;  GMEGA.BIN - EGA 16-Color Graphics Driver (Mode 0Eh, 640x200)
;
;  EGA variant of the graphics driver API. Uses EGA planar memory
;  at 0xA000 with Map Mask and Bit Mask registers for pixel access.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	27BBh			;*
data_2e		equ	0E200h			;*
data_3e		equ	0E202h			;*
data_4e		equ	0E206h			;*
data_5e		equ	0E20Ah			;*
data_6e		equ	0E20Ch			;*
data_18e	equ	21C0h			;*
data_19e	equ	22DEh			;*
data_20e	equ	256Ah			;*
data_21e	equ	256Bh			;*
data_22e	equ	256Dh			;*
data_23e	equ	2D27h			;*
data_24e	equ	2E93h			;*
data_25e	equ	2E94h			;*
data_26e	equ	2E95h			;*
data_27e	equ	2E97h			;*
data_28e	equ	4526h			;*
data_29e	equ	0A000h			;*
data_30e	equ	0A523h			;*
data_31e	equ	0BB23h			;*
data_32e	equ	0C821h			;*
data_33e	equ	0D92Bh			;*
data_34e	equ	0DEA2h			;*
data_35e	equ	0E52Ah			;*
data_36e	equ	0F500h			;*
data_37e	equ	0F502h			;*
data_38e	equ	0F504h			;*
data_39e	equ	0F828h			;*
data_40e	equ	0FE71h			;*
data_41e	equ	0FF2Ch			;*
data_42e	equ	0FF77h			;*
data_43e	equ	316Ch			;*
data_44e	equ	46Ch

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

gmega		proc	far

start:
		inc	si
		and	ds:data_32e,bl
;*		and	di,bx
		db	 21h,0DFh		;  Fixup - byte match
		and	bl,[si]
		and	bp,cx
		and	ah,ds:data_30e
		and	si,ss:data_31e[bp+di]
		and	al,0C5h
		and	al,0E2h
		and	al,2
		and	ax,252Bh
		mov	si,data_28e
		daa				; Decimal adjust
		pop	di
		daa				; Decimal adjust
		pop	ax
;*		sub	cx,bp
		db	 29h,0E9h		;  Fixup - byte match
		sub	[bp+di],si
		sub	cl,ss:data_35e[bp+di]
		sub	bh,[bp+si]
		sub	cx,ss:data_33e[bp]
		and	ax,2570h
		jns	loc_1			; Jump if not sign
;*		call	far ptr fill_rectangle	;*
		db	9Ah
		dw	0C127h, 7B23h		;  Fixup - byte match
		sub	ss:data_39e[bp+di],dl
		sub	cx,[bp+21h]
		db	 63h, 2Eh, 92h, 2Eh, 50h,0B8h
		db	 50h, 00h,0F6h,0E3h, 8Ah,0DFh
		db	 32h,0FFh, 03h,0C3h, 8Bh,0F8h
		db	 58h, 0Ah,0C0h, 75h, 03h,0E9h
		db	 9Dh, 00h
		db	57h
loc_1:
		sub	cl,4
		add	di,0A0h
		call	clear_screen
		pop	di
		mov	ax,0F00Fh
		call	fill_horizontal_line
		mov	ax,0FC3Fh
		call	fill_horizontal_line
		push	cx
		push	bx
		mov	bl,ch
		dec	bl
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

locloop_2:
		mov	byte ptr es:[di],0F0h
		mov	byte ptr es:[bx+di],0Fh
		add	di,50h
		loop	locloop_2		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0FC3Fh
		call	fill_horizontal_line
		mov	ax,0F00Fh

gmega		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_horizontal_line		proc	near
		push	ax
		mov	dx,3CEh
		mov	ax,803h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		pop	ax
		push	ax
		push	di
		not	ax
		xchg	es:[di],al
		inc	di
		mov	bh,ch
		sub	bh,2
loc_3:
		xor	al,al			; Zero register
		xchg	es:[di],al
		inc	di
		dec	bh
		jnz	loc_3			; Jump if not zero
		xchg	es:[di],ah
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		test	byte ptr cs:data_42e,0FFh
		jz	loc_4			; Jump if zero
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
loc_4:
		mov	dx,3CEh
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		pop	di
		pop	ax
		xchg	es:[di],al
		inc	di
		mov	bh,ch
		sub	bh,2
loc_5:
		mov	al,0FFh
		xchg	es:[di],al
		inc	di
		dec	bh
		jnz	loc_5			; Jump if not zero
		mov	al,ah
		xchg	es:[di],al
		inc	di
		add	di,bx
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		retn
fill_horizontal_line		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

clear_screen		proc	near
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	bl,50h			; 'P'
		sub	bl,ch
		xor	bh,bh			; Zero register
		mov	ah,cl
loc_6:
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	cx
		add	di,bx
		dec	ah
		jnz	loc_6			; Jump if not zero
		retn
clear_screen		endp

			                        ;* No entry point to code
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	di,data_44e
		mov	cx,8

locloop_7:
		push	cx
		push	di
		mov	cx,12h

locloop_8:
		push	cx
		push	di
		mov	cx,38h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,280h
		pop	cx
		loop	locloop_8		; Loop if cx > 0

		pop	di
		add	di,50h
		pop	cx
		loop	locloop_7		; Loop if cx > 0

		retn
			                        ;* No entry point to code
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
		mov	si,data_18e
		mov	cx,8

locloop_9:
		push	cx
		mov	di,data_44e
		lodsb				; String [si] to al
		mov	ah,al
		push	di
		mov	cx,48h

locloop_10:
		push	cx
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		mov	cx,38h

locloop_11:
		xor	al,al			; Zero register
		xchg	es:[di],al
		inc	di
		loop	locloop_11		; Loop if cx > 0

		rol	ah,1			; Rotate
		rol	ah,1			; Rotate
		rol	ah,1			; Rotate
		pop	cx
		add	di,68h
		loop	locloop_10		; Loop if cx > 0

		pop	di
		add	di,50h
		mov	cx,48h

locloop_12:
		push	cx
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		mov	cx,38h

locloop_13:
		xor	al,al			; Zero register
		xchg	es:[di],al
		inc	di
		loop	locloop_13		; Loop if cx > 0

		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		pop	cx
		add	di,68h
		loop	locloop_12		; Loop if cx > 0

		mov	cx,3E80h

locloop_14:
		loop	locloop_14		; Loop if cx > 0

		pop	cx
		loop	locloop_9		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn
			                        ;* No entry point to code
		add	[bx+di],dx
		adc	ax,5755h
		ja	loc_19			; Jump if above
		jmp	dword ptr ds:data_34e
			                        ;* No entry point to code
		and	bh,ds:data_29e[bx+si]
		mov	es,ax
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	di,ax
		mov	dl,bh
		and	bh,3
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		xor	dh,dh			; Zero register
		add	di,dx
		add	di,data_43e
		mov	cl,bh
		add	cl,cl
		mov	ax,0FF3Fh
		shr	ah,cl			; Shift w/zeros fill
		shr	al,cl			; Shift w/zeros fill
		neg	bh
		add	bh,3
		sub	ch,bh
		push	cx
		call	plot_pixel
		pop	cx
		inc	di
		mov	cl,ch
		shr	cl,1			; Shift w/zeros fill
		shr	cl,1			; Shift w/zeros fill
		test	cl,0FFh
		jz	loc_17			; Jump if zero
loc_16:
		push	cx
		mov	ax,0FFFFh
		call	plot_pixel
		pop	cx
		inc	di
		dec	cl
		jnz	loc_16			; Jump if not zero
loc_17:
		and	ch,3
		jnz	loc_18			; Jump if not zero
		retn
loc_18:
		mov	cl,ch
		shl	cl,1			; Shift w/zeros fill
		mov	ah,0FFh
		shr	ah,cl			; Shift w/zeros fill
		not	ah
		mov	al,ah
		call	plot_pixel
		mov	dx,3CEh
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

plot_pixel		proc	near
		mov	cx,ax
		test	byte ptr cs:data_19e,0FFh
		jnz	loc_21			; Jump if not zero
		mov	dx,3CEh
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
loc_19:
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		push	di
		mov	al,7
		out	dx,al			; port 3C5h, EGA sequencr func
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,50h
		mov	ch,8
loc_20:
		mov	al,7
		out	dx,al			; port 3C5h, EGA sequencr func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,5
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	al,cl
		and	al,0AAh
		xchg	es:[di],al
		add	di,50h
		dec	ch
		jnz	loc_20			; Jump if not zero
		mov	al,7
		out	dx,al			; port 3C5h, EGA sequencr func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,5
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	al,cl
		xchg	es:[di],al
		pop	di
		retn
loc_21:
		cmp	byte ptr cs:data_19e,80h
		je	loc_23			; Jump if equal
		mov	dx,3CEh
		mov	ah,cl
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		push	di
		mov	ch,0Ah
loc_22:
		mov	al,7
		out	dx,al			; port 3C5h, EGA sequencr func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	al,cl
		and	al,0AAh
		xchg	es:[di],al
		add	di,50h
		dec	ch
		jnz	loc_22			; Jump if not zero
		pop	di
		retn
loc_23:
		mov	dx,3CEh
		mov	ah,cl
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	al,7
		out	dx,al			; port 3C5h, EGA sequencr func
		push	di
		mov	ch,0Ah
loc_24:
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,50h
		dec	ch
		jnz	loc_24			; Jump if not zero
		pop	di
		retn
plot_pixel		endp

		db	 00h,0BFh, 05h, 33h, 2Eh, 8Bh
		db	 1Eh,0B2h, 00h,0EBh, 05h,0BFh
		db	0C5h, 36h,0EBh, 00h,0B8h, 00h
		db	0A0h, 8Eh,0C0h,0BAh,0C4h, 03h
		db	0B8h, 02h, 02h,0EFh,0E8h, 7Ch
		db	 00h
		db	50h
loc_25:
		or	bl,bl			; Zero ?
		jz	loc_26			; Jump if zero
		mov	bh,6
		mov	al,0FFh
		call	fill_vertical_line
		dec	bl
		add	di,0FE21h
		jmp	short loc_25
loc_26:
		pop	ax
		or	al,al			; Zero ?
		jnz	loc_27			; Jump if not zero
		retn
loc_27:
		mov	bh,6
		jmp	loc_35
			                        ;* No entry point to code
		mov	di,3305h
		mov	bx,word ptr cs:[90h]
		jmp	short loc_28
		db	0BFh,0C5h, 36h,0EBh, 00h
loc_28:
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,102h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		call	calc_text_width
		push	ax
		push	bx
loc_29:
		or	bl,bl			; Zero ?
		jz	loc_30			; Jump if zero
		mov	bh,5
		mov	al,0FFh
		call	fill_vertical_line
		dec	bl
		add	di,data_40e
		jmp	short loc_29
loc_30:
		pop	bx
		pop	ax
		or	al,al			; Zero ?
		jz	loc_31			; Jump if zero
		mov	bh,5
		call	fill_vertical_line
		add	di,data_40e
		inc	bl
loc_31:
		mov	bh,19h
		sub	bh,bl
		jnz	loc_32			; Jump if not zero
		retn
loc_32:
		mov	bl,bh
loc_33:
		mov	bh,5
		xor	al,al			; Zero register
		call	fill_vertical_line
		add	di,0FE71h
		dec	bl
		jnz	loc_33			; Jump if not zero
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	loc_34			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	cl,bl
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		and	cl,7
		mov	al,0FFh
		shr	al,cl			; Shift w/zeros fill
		not	al
		retn
loc_34:
		mov	bx,19h
		xor	al,al			; Zero register
		retn
calc_text_width		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_vertical_line		proc	near
loc_35:
		stosb				; Store al to es:[di]
		add	di,4Fh
		dec	bh
		jnz	loc_35			; Jump if not zero
		retn
fill_vertical_line		endp

			                        ;* No entry point to code
		mov	byte ptr cs:data_24e,3
		mov	byte ptr cs:data_25e,2
		jmp	short loc_38
			                        ;* No entry point to code
		mov	byte ptr cs:data_24e,1
		mov	byte ptr cs:data_25e,5
		jmp	short loc_38
			                        ;* No entry point to code
		mov	byte ptr cs:data_24e,1
		mov	byte ptr cs:data_25e,0
		xor	dh,dh			; Zero register
		mov	dl,bh
		mov	di,dx
		mov	al,bl
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	di,ax
		mov	bl,cl
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
loc_36:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_37			; Jump if zero
		push	bx
		push	ds
		push	si
		and	bl,3
		call	render_text_char
		pop	si
		pop	ds
		pop	bx
		inc	bl
		jmp	short loc_36
loc_37:
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn
loc_38:
		lodsb				; String [si] to al
		xor	dh,dh			; Zero register
		mov	dl,al
		mov	di,dx
		lodsb				; String [si] to al
		mov	cl,50h			; 'P'
		mul	cl			; ax = reg * al
		add	di,ax
		lodsb				; String [si] to al
		mov	bl,al
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode

locloop_39:
		push	cx
		lodsb				; String [si] to al
		push	bx
		push	ds
		push	si
		and	bl,3
		call	render_text_char
		pop	si
		pop	ds
		pop	bx
		inc	bl
		pop	cx
		loop	locloop_39		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

render_text_char		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:data_38e
		add	bl,bl
		mov	cl,bl
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		push	di
		mov	bl,8
loc_40:
		push	bx
		lodsb				; String [si] to al
		xor	bl,bl			; Zero register
		mov	bh,al
		shr	bx,cl			; Shift w/zeros fill
		push	bx
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	al,bh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_25e
		xchg	es:[di],al
		mov	al,bl
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_25e
		xchg	es:[di+1],al
		pop	bx
		mov	al,bh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_24e
		xchg	es:[di],al
		mov	al,bl
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_24e
		xchg	es:[di+1],al
		add	di,50h
		pop	bx
		dec	bl
		jnz	loc_40			; Jump if not zero
		dec	dx
		pop	di
		inc	di
		cmp	cl,6
		je	loc_41			; Jump if equal
		retn
loc_41:
		inc	di
		retn
render_text_char		endp

			                        ;* No entry point to code
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,88h
;*		jmp	loc_15			;*
		db	0E9h, 03h,0FDh		;  Fixup - byte match
			                        ;* No entry point to code
		push	ds
		mov	ax,word ptr cs:[8Bh]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,data_21e
		mov	cx,105h
		mov	ax,26BBh
		mov	bx,0FF01h
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ax,word ptr cs:[86h]
		mov	dl,byte ptr cs:[85h]
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,data_20e
		mov	cx,106h
		mov	ax,13BBh
		mov	bx,0FF01h
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		xor	bx,bx			; Zero register
		mov	bl,byte ptr cs:[9Dh]
		dec	bl
		mov	al,byte ptr cs:[0ABh][bx]
		xor	ah,ah			; Zero register
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,data_22e
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,0FF01h
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		test	byte ptr cs:[93h],0FFh
		jnz	loc_42			; Jump if not zero
		retn
loc_42:
		push	ds
		mov	ax,word ptr cs:[94h]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,data_22e
		mov	cx,103h
		mov	ax,3EBBh
		mov	bx,0FF01h
		call	render_tilemap_large
		pop	ds
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

init_timestamp		proc	near
		mov	di,2569h
		call	time_to_bcd
		mov	cx,6

locloop_43:
		test	byte ptr cs:[di],0FFh
		jz	loc_44			; Jump if zero
		retn
loc_44:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	locloop_43		; Loop if cx > 0

		retn
init_timestamp		endp

		db	7 dup (0)

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

time_to_bcd		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	modulo_divide_bcd
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	modulo_divide_bcd
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	modulo_divide_bcd
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	int_divide_bcd
		mov	cs:[di+3],dh
		mov	bx,64h
		call	int_divide_bcd
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	int_divide_bcd
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn
time_to_bcd		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

modulo_divide_bcd		proc	near
		xor	dh,dh			; Zero register
loc_45:
		sub	dl,cl
		jc	loc_48			; Jump if carry Set
		sub	ax,bx
		jnc	loc_46			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_47			; Jump if zero
		dec	dl
loc_46:
		inc	dh
		jmp	short loc_45
loc_47:
		add	ax,bx
loc_48:
		add	dl,cl
		retn
modulo_divide_bcd		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

int_divide_bcd		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn
int_divide_bcd		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

render_tilemap_large		proc	near
		mov	cs:data_24e,bl
		mov	cs:data_25e,bh
		mov	bl,ah
		mov	ah,50h			; 'P'
		mul	ah			; ax = reg * al
		xor	bh,bh			; Zero register
		add	bx,ax
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
loc_49:
		mov	al,[di]
		inc	di
		push	bx
		push	cx
		push	di
		push	ds
		mov	di,bx
		call	decode_bitplane_tile
		pop	ds
		pop	di
		pop	cx
		pop	bx
		mov	al,ch
		and	ax,1
		add	bx,ax
		inc	bx
		inc	ch
		dec	cl
		jnz	loc_49			; Jump if not zero
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn
render_tilemap_large		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decode_bitplane_tile		proc	near
		mov	bx,0FFF0h
		test	ch,1
		jz	loc_50			; Jump if zero
		mov	bx,0FFFh
loc_50:
		test	byte ptr ds:data_25e,0FFh
		jz	loc_52			; Jump if zero
		push	di
		push	cx
		push	ax
		mov	al,8
		mov	cx,7

locloop_51:
		mov	ah,bh
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		xor	ah,ah			; Zero register
		xchg	es:[di],ah
		mov	ah,bl
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		xor	ah,ah			; Zero register
		xchg	es:[di+1],ah
		mov	ah,bh
		and	ah,0AAh
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		mov	ah,5
		xchg	es:[di],ah
		mov	ah,bl
		and	ah,0AAh
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		mov	ah,5
		xchg	es:[di+1],ah
		add	di,50h
		loop	locloop_51		; Loop if cx > 0

		pop	ax
		pop	cx
		pop	di
loc_52:
		inc	al
		jnz	loc_53			; Jump if not zero
		retn
loc_53:
		dec	al
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,cs:data_37e
		mov	si,ax
		push	cs
		pop	ds
		mov	cl,7
loc_54:
		lodsw				; String [si] to ax
		xchg	ah,al
		test	ch,1
		jnz	loc_55			; Jump if not zero
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
loc_55:
		mov	bl,al
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		mov	ah,cs:data_24e
		xchg	es:[di],ah
		mov	ah,bl
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		mov	ah,cs:data_24e
		xchg	es:[di+1],ah
		add	di,50h
		dec	cl
		jnz	loc_54			; Jump if not zero
		retn
decode_bitplane_tile		endp

			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_41e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,10Eh
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_2e
		mov	si,ax
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bp,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bp,bx
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	cx,12h

locloop_56:
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[bp],al
		mov	es:[bp+1],ah
		lodsw				; String [si] to ax
		mov	es:[bp+2],al
		mov	es:[bp+3],ah
		lodsb				; String [si] to al
		mov	es:[bp+4],al
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[bp+4],al
		mov	es:[bp+3],ah
		lodsw				; String [si] to ax
		mov	es:[bp+2],al
		mov	es:[bp+1],ah
		lodsb				; String [si] to al
		mov	es:[bp],al
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[bp],al
		mov	es:[bp+1],ah
		lodsw				; String [si] to ax
		mov	es:[bp+2],al
		mov	es:[bp+3],ah
		lodsb				; String [si] to al
		mov	es:[bp+4],al
		add	bp,50h
		loop	locloop_56		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_41e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_4e
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_41e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_3e
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,data_1e
		or	al,al			; Zero ?
		jz	loc_57			; Jump if zero
		mov	ds,cs:data_41e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_6e
		mov	si,ax
loc_57:
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,data_1e
		or	al,al			; Zero ?
		jz	loc_58			; Jump if zero
		mov	ds,cs:data_41e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_5e
		mov	si,ax
loc_58:
		call	render_tilemap_small
		pop	ds
		retn
		db	0, 0, 0, 0
		db	'TUUUUUUT'
		db	 00h, 00h, 00h, 00h, 02h, 00h
		db	 00h, 80h, 80h, 00h, 00h, 02h
		db	 06h, 30h, 18h, 00h, 02h, 00h
		db	 00h, 80h, 9Eh,0F3h,0F8h, 02h
		db	 03h, 31h, 8Ch, 00h, 02h, 00h
		db	 00h, 80h, 9Fh,0F7h,0BCh, 02h
		db	 05h, 31h, 8Ch, 00h, 02h, 00h
		db	 00h, 80h, 9Fh,0F7h,0BCh, 02h
		db	 06h, 31h, 8Ch, 00h, 02h, 00h
		db	 00h, 80h, 9Fh,0F7h,0BCh, 02h
		db	 06h, 30h, 18h, 00h, 02h, 00h
		db	 00h, 80h, 9Eh,0F3h,0F8h, 02h
		db	 00h, 00h, 00h, 00h, 02h, 00h
		db	 00h, 80h, 80h, 00h, 00h, 02h
		db	 00h, 00h, 00h, 00h, 02h, 00h
		db	 00h, 80h, 80h, 00h, 00h, 02h
		db	 03h, 18h, 0Ch, 0Ch, 02h, 00h
		db	 00h, 80h, 8Fh, 7Bh,0FFh,0FEh
		db	 03h, 19h, 80h,0C0h, 02h, 00h
		db	 00h, 80h, 8Fh, 7Fh, 83h,0C2h
		db	 03h, 18h, 18h, 18h, 02h, 00h
		db	 00h, 80h, 8Fh, 7Bh,0FBh,0FAh
		db	 03h, 18h, 0Ch,0C0h, 02h, 00h
		db	 00h, 80h, 8Fh, 78h, 3Fh,0C2h
		db	 00h, 30h, 18h, 0Ch, 02h, 00h
		db	 00h, 80h, 87h,0F7h,0FBh,0FEh
		db	 00h, 00h, 00h, 00h, 02h, 00h
		db	 00h, 80h, 80h, 00h, 00h, 02h
		db	 00h, 00h, 00h, 00h
		db	'TUUUUUUT'
		db	 1Eh, 2Eh, 8Eh, 1Eh, 2Ch,0FFh
		db	 32h,0E4h,0B9h,0C0h, 00h,0F7h
		db	0E1h, 03h, 06h, 08h,0E2h, 8Bh
		db	0F0h,0E8h, 1Ah, 00h, 1Fh,0C3h
		db	 1Eh, 2Eh, 8Eh, 1Eh, 2Ch,0FFh
		db	 32h,0E4h,0B9h,0C0h, 00h,0F7h
		db	0E1h, 03h, 06h, 04h,0E2h, 8Bh
		db	0F0h,0E8h, 02h, 00h, 1Fh,0C3h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

render_tilemap_small		proc	near
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bp,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bp,bx
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	cx,10h
loc_59:
		push	cx
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	di,ax
		lodsw				; String [si] to ax
		xchg	al,ah
		xor	bl,bl			; Zero register
		mov	cx,4

locloop_60:
		shr	di,1			; Shift w/zeros fill
		rcr	ax,1			; Rotate thru carry
		rcr	bl,1			; Rotate thru carry
		loop	locloop_60		; Loop if cx > 0

		xchg	di,ax
		mov	es:[bp],ah
		mov	es:[bp+1],al
		xchg	di,ax
		mov	es:[bp+2],ah
		mov	es:[bp+3],al
		mov	es:[bp+4],bl
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	di,ax
		lodsw				; String [si] to ax
		xor	bl,bl			; Zero register
		mov	cx,4

locloop_61:
		shr	ax,1			; Shift w/zeros fill
		rcr	di,1			; Rotate thru carry
		rcr	bl,1			; Rotate thru carry
		loop	locloop_61		; Loop if cx > 0

		mov	es:[bp],ah
		mov	es:[bp+1],al
		xchg	di,ax
		mov	es:[bp+2],ah
		mov	es:[bp+3],al
		mov	es:[bp+4],bl
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	di,ax
		lodsw				; String [si] to ax
		xchg	al,ah
		xor	bl,bl			; Zero register
		mov	cx,4

locloop_62:
		shr	di,1			; Shift w/zeros fill
		rcr	ax,1			; Rotate thru carry
		rcr	bl,1			; Rotate thru carry
		loop	locloop_62		; Loop if cx > 0

		xchg	di,ax
		mov	es:[bp],ah
		mov	es:[bp+1],al
		xchg	di,ax
		mov	es:[bp+2],ah
		mov	es:[bp+3],al
		mov	es:[bp+4],bl
		add	bp,50h
		pop	cx
		loop	locloop_63		; Loop if cx > 0

		jmp	short loc_ret_64

locloop_63:
		jmp	loc_59

loc_ret_64:
		retn
render_tilemap_small		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

render_text_char_alt		proc	near
		push	ds
		push	cs
		pop	ds
		mov	ds:data_24e,ah
		xor	ah,ah			; Zero register
		sub	al,20h			; ' '
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:data_36e
		push	ax
		mov	al,bl
		and	al,3
		add	al,al
		mov	ds:data_25e,al
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	al,50h			; 'P'
		mul	cl			; ax = reg * al
		add	ax,bx
		mov	di,ax
		pop	si
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	bp,4Eh
		mov	cx,8

locloop_65:
		push	cx
		lodsw				; String [si] to ax
		mov	bh,al
		xor	bl,bl			; Zero register
		mov	cl,cs:data_25e
		shr	bx,cl			; Shift w/zeros fill
		xor	al,al			; Zero register
		shr	ax,cl			; Shift w/zeros fill
		or	bl,ah
		mov	ah,al
		mov	al,bh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_24e
		xchg	es:[di],al
		inc	di
		mov	al,bl
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_24e
		xchg	es:[di],al
		inc	di
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_24e
		xchg	es:[di],al
		add	di,4Eh
		pop	cx
		loop	locloop_65		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	ds
		retn
render_text_char_alt		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
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
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_66:
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
		loop	locloop_66		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		add	di,0
		mov	bl,ah
		mov	bh,50h			; 'P'
		mul	bh			; ax = reg * al
		mov	si,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	si,bx
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,0A000h
		mov	ds,ax
		mov	dx,3CEh
		mov	al,4
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 4, read map select
		inc	dx
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

locloop_67:
		push	cx
		push	si
		mov	al,0
		out	dx,al			; port 3CFh, EGA graphic func
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		push	si
		mov	al,1
		out	dx,al			; port 3CFh, EGA graphic func
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		push	si
		mov	al,2
		out	dx,al			; port 3CFh, EGA graphic func
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		push	si
		mov	al,3
		out	dx,al			; port 3CFh, EGA graphic func
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,50h
		pop	cx
		loop	locloop_67		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,di
		add	si,0
		mov	bl,ah
		mov	bh,50h			; 'P'
		mul	bh			; ax = reg * al
		mov	di,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	di,bx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

locloop_68:
		push	cx
		push	di
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		push	di
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		push	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		push	di
		mov	al,8
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		add	di,50h
		pop	cx
		loop	locloop_68		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	cs:data_26e,bx
		mov	cs:data_27e,cl
		mov	al,1
		test	byte ptr cs:data_42e,0FFh
		jz	loc_69			; Jump if zero
		mov	al,7
loc_69:
		mov	cs:data_24e,al
loc_70:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_71			; Jump if not equal
		retn
loc_71:
		cmp	al,0Dh
		je	loc_72			; Jump if equal
		or	al,al			; Zero ?
		js	loc_73			; Jump if sign=1
		push	cx
		push	bx
		push	si
		mov	ah,cs:data_24e
		call	render_text_char_alt
		pop	si
		pop	bx
		pop	cx
		add	bx,8
		jmp	short loc_70
loc_72:
		add	byte ptr cs:data_27e,8
		mov	cl,cs:data_27e
		mov	bx,cs:data_26e
		jmp	short loc_70
loc_73:
		and	al,7
		mov	cs:data_24e,al
		jmp	short loc_70
			                        ;* No entry point to code
		push	ds
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		mov	si,ax
		mov	ax,50h
		mul	dl			; ax = reg * al
		mov	dl,dh
		xor	dh,dh			; Zero register
		add	dx,dx
		add	ax,dx
		mov	di,ax
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
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_74:
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
		loop	locloop_74		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	cs
		pop	ds
		mov	ds:data_24e,al
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		call	fill_rectangle
		mov	cx,10h

locloop_75:
		mov	al,0F0h
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_24e
		xchg	es:[di],al
		mov	al,0Fh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_24e
		xchg	es:[di+4],al
		add	di,50h
		loop	locloop_75		; Loop if cx > 0

		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func
		call	fill_rectangle
		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_rectangle		proc	near
		mov	cx,2

locloop_76:
		push	cx
		mov	al,ds:data_24e
		mov	cx,5
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		add	di,4Bh
		pop	cx
		loop	locloop_76		; Loop if cx > 0

		retn
fill_rectangle		endp

			                        ;* No entry point to code
		push	ds
		push	si
		push	cs
		pop	ds
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	si,ax
		mov	si,ds:data_23e[si]
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,0Dh
loc_77:
		push	cx
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	bx,[si]
		mov	bp,bx
		mov	ax,[si+6]
		xchg	al,ah
		or	bx,ax
		and	bp,ax
		or	bx,[si+8]
		and	bp,[si+8]
		not	bp
		push	bp
		mov	cx,[si+2]
		mov	bp,cx
		mov	ax,[si+4]
		xchg	al,ah
		or	cx,ax
		and	bp,ax
		or	cx,[si+0Ah]
		and	bp,[si+0Ah]
		not	bp
		mov	al,bl
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,bh
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di+1],al
		mov	al,cl
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di+2],al
		mov	al,ch
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di+3],al
		mov	cx,bp
		pop	bx
		dec	dx
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	ax,bx
		and	ax,[si]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di+1],al
		mov	ax,cx
		and	ax,[si+2]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di+2],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di+3],al
		mov	ax,[si+6]
		xchg	al,ah
		and	ax,bx
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di+1],al
		mov	ax,[si+4]
		xchg	al,ah
		and	ax,cx
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di+2],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di+3],al
		mov	ax,bx
		and	ax,[si+8]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di+1],al
		mov	ax,cx
		and	ax,[si+0Ah]
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di+2],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di+3],al
		dec	dx
		add	si,0Ch
		add	di,50h
		pop	cx
		loop	locloop_78		; Loop if cx > 0

		jmp	short loc_79

locloop_78:
		jmp	loc_77
loc_79:
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	si
		pop	ds
		retn
		db	 2Bh, 2Dh,0C7h, 2Dh, 00h, 0Fh
		db	0F3h, 00h, 00h,0F3h, 0Fh, 00h
		db	 00h, 0Fh,0F3h, 00h, 00h, 7Ah
		db	 8Fh, 00h, 00h, 7Fh, 75h, 00h
		db	 00h, 70h, 0Fh, 00h, 00h, 77h
		db	0F3h, 00h, 00h, 2Fh, 68h, 00h
		db	 00h, 60h, 23h, 00h, 00h,0EFh
		db	0F9h, 00h, 00h, 17h,0D0h, 00h
		db	 00h,0C0h, 39h, 00h, 00h,0DFh
		db	0FCh, 80h, 80h, 2Bh,0A8h, 00h
		db	 00h, 98h, 7Ch, 80h, 00h,0DFh
		db	0FCh, 80h, 80h, 17h,0B5h, 00h
		db	 00h, 9Fh,0FCh, 80h, 00h, 9Fh
		db	0FCh, 80h, 80h,0ABh,0EAh, 00h
		db	 00h, 9Fh,0FCh, 80h, 00h, 4Fh
		db	0F9h, 00h, 00h, 17h, 74h, 00h
		db	 00h, 4Fh,0F9h, 00h, 00h, 67h
		db	0F3h, 00h, 00h, 1Fh, 7Ch, 00h
		db	 00h, 67h,0F3h, 00h, 00h, 78h
		db	 0Fh, 00h, 00h,0FFh
loc_80:
		jg	$+2			; delay for I/O
		add	[bx+si+0Fh],bh
		add	[bx+si],al
		ja	loc_80			; Jump if above
		add	[bx+si],al
;*		div	word ptr [bx+0]		; ax,dxrem=dx:ax/data
		db	0F7h, 77h, 00h		;  Fixup - byte match
		db	 00h, 77h,0F7h
		db	26 dup (0)
		db	0FFh,0FFh, 00h, 00h, 3Fh,0E0h
		db	 00h, 00h,0E0h, 07h, 00h, 03h
		db	0FFh,0FFh,0C0h,0C0h,0FFh, 0Fh
		db	 03h, 03h, 0Fh,0F4h,0C0h, 07h
		db	0FFh,0FFh,0E0h,0E0h,0BFh, 74h
		db	 04h, 04h, 74h,0BEh,0A0h, 0Fh
		db	0FFh,0FFh,0F0h,0F0h,0F7h,0C2h
		db	 08h, 08h,0C2h,0F7h, 50h, 1Fh
		db	0FFh,0FFh,0F8h,0F8h,0FDh, 83h
		db	 11h, 11h, 83h,0FDh,0A8h, 1Fh
		db	0FFh,0AFh,0F8h,0D8h,0FFh, 1Fh
		db	 13h, 13h, 1Fh,0AFh,0C8h, 1Fh
		db	0FDh, 55h, 78h,0D8h,0FFh,0BFh
		db	 13h, 13h,0BDh, 55h, 48h, 1Fh
		db	0EAh, 02h,0F8h, 98h,0FFh,0BFh
		db	 13h, 11h,0AAh, 02h, 88h, 0Fh
		db	0B4h, 01h,0F0h, 10h,0FFh,0DFh
		db	 0Bh, 08h, 94h, 01h, 10h, 07h
		db	0EBh, 03h,0E0h, 20h,0FEh,0F6h
		db	 05h, 04h, 62h, 02h, 20h, 03h
		db	0FBh, 5Fh,0C0h,0C0h,0F8h,0FFh
		db	 03h, 03h, 2Bh, 58h,0C0h, 00h
		db	0FFh,0FFh, 00h, 00h,0DFh,0F7h
		db	 00h, 00h,0E5h, 57h, 00h, 00h
		db	 1Fh,0F8h, 00h, 00h,0F8h, 1Fh
		db	 00h, 00h, 1Fh,0F8h, 00h,0B8h
		db	 00h,0A0h, 8Eh,0C0h,0BAh,0C4h
		db	 03h,0B8h, 02h, 0Fh,0EFh, 33h
		db	0FFh,0B9h, 08h, 00h

locloop_81:
		push	cx
		push	di
		mov	cx,19h

locloop_82:
		push	cx
		push	di
		mov	cx,50h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,280h
		pop	cx
		loop	locloop_82		; Loop if cx > 0

		pop	di
		add	di,50h
		pop	cx
		loop	locloop_81		; Loop if cx > 0

		retn
		db	0C3h, 00h, 00h, 00h, 00h, 00h

seg_a		ends



		end	start
