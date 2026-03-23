
PAGE  59,132

;==========================================================================
;
;  GMHGC.BIN - Hercules Graphics Card Monochrome Driver (720x348)
;
;  HGC variant of the graphics driver API. Uses monochrome framebuffer
;  at 0xB000 with bit-level pixel operations. 4 interleaved banks.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	0E200h			;*
data_2e		equ	0E202h			;*
data_3e		equ	0E206h			;*
data_4e		equ	0E20Ah			;*
data_5e		equ	0E20Ch			;*
data_18e	equ	21D6h			;*
data_19e	equ	22D5h			;*
data_20e	equ	2600h			;*
data_21e	equ	2994h			;*
data_22e	equ	2CA7h			;*
data_23e	equ	2E7Fh			;*
data_24e	equ	2E80h			;*
data_25e	equ	2E81h			;*
data_26e	equ	2E82h			;*
data_27e	equ	2E84h			;*
data_28e	equ	2E85h			;*
data_29e	equ	2E87h			;*
data_30e	equ	2E89h			;*
data_31e	equ	6000h			;*
data_32e	equ	0A05Ah			;*
data_33e	equ	0B324h			;*
data_34e	equ	0BB23h			;*
data_35e	equ	0F500h			;*
data_36e	equ	0F502h			;*
data_37e	equ	0F504h			;*
data_38e	equ	0F92Ah			;*
data_39e	equ	0FF01h			;*
data_40e	equ	0FF2Ch			;*
data_41e	equ	0			;*
data_42e	equ	4FDh
data_43e	equ	6000h
data_44e	equ	0A05Ah

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

gmhgc		proc	far

start:
		inc	si
		and	[bp+di],dl
;*		and	si,bx
		db	 21h,0DEh		;  Fixup - byte match
;*		and	si,dx
		db	 21h,0D6h		;  Fixup - byte match
		and	dl,[bx+si]
		and	sp,ax
		and	bl,[bp+si]
		and	bp,ds:data_34e[di]
		and	bp,ds:data_33e[bx+di]
		and	al,0D0h
		and	al,0F0h
		and	al,19h
		and	ax,2698h
		pop	dx
		daa				; Decimal adjust
		jz	loc_1			; Jump if zero
;*		aam	29h			; ')' undocumented inst
		db	0D4h, 29h		;  Fixup - byte match
		mov	al,ds:data_38e
		sub	dh,[bp+si]
		sub	di,[bp+di+2Bh]
		db	0C6h, 2Bh, 18h, 2Ch,0C7h, 25h
		db	 5Eh, 25h, 8Eh, 27h,0AFh, 27h
		db	0C9h, 23h, 90h, 28h,0A8h, 28h
		db	0AFh, 2Ch, 43h, 21h, 02h, 2Eh
		db	 37h, 2Eh, 50h,0E8h,0C7h
loc_1:
		or	ax,0F88Bh
		pop	ax
		or	al,al			; Zero ?
		jnz	loc_2			; Jump if not zero
		jmp	loc_8
loc_2:
		push	di
		sub	cl,4
		add	di,4000h
		cmp	di,6000h
		jb	loc_3			; Jump if below
		add	di,data_32e
loc_3:
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

locloop_4:
		mov	byte ptr es:[di],0F0h
		mov	byte ptr es:[bx+di],0Fh
		add	di,2000h
		cmp	di,6000h
		jb	loc_5			; Jump if below
		mov	byte ptr es:[di],0F0h
		mov	byte ptr es:[bx+di],0Fh
		add	di,data_44e
loc_5:
		loop	locloop_4		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0FC3Fh
		call	fill_horizontal_line
		mov	ax,0F00Fh

gmhgc		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_horizontal_line		proc	near
		push	di
		or	es:[di],al
		inc	di
		mov	bh,ch
		sub	bh,2
loc_6:
		or	byte ptr es:[di],0FFh
		inc	di
		dec	bh
		jnz	loc_6			; Jump if not zero
		or	es:[di],ah
		pop	di
		add	di,2000h
		cmp	di,data_43e
		jae	loc_7			; Jump if above or =
		retn
loc_7:
		push	di
		push	ds
		push	cx
		push	es
		pop	ds
		mov	si,di
		sub	si,2000h
		mov	cl,ch
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	ds
		pop	di
		add	di,0A05Ah
		retn
fill_horizontal_line		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

clear_screen		proc	near
loc_8:
		mov	ax,0B000h
		mov	es,ax
		mov	ah,cl
loc_9:
		call	clear_screen_row
		add	di,2000h
		cmp	di,data_31e
		jb	loc_10			; Jump if below
		call	clear_screen_row
		add	di,0A05Ah
loc_10:
		dec	ah
		jnz	loc_9			; Jump if not zero
		retn
clear_screen		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

clear_screen_row		proc	near
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	cx
		pop	di
		retn
clear_screen_row		endp

			                        ;* No entry point to code
		mov	ax,0B000h
		mov	es,ax
		mov	di,data_42e
		mov	cx,90h

locloop_11:
		push	cx
		push	di
		mov	cx,38h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,2000h
		cmp	di,data_43e
		jb	loc_12			; Jump if below
		push	di
		mov	cx,38h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,0A05Ah
loc_12:
		pop	cx
		loop	locloop_11		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	ax,0B000h
		mov	es,ax
		mov	si,data_18e
		mov	cx,8

locloop_13:
		push	cx
		mov	di,4FDh
		lodsb				; String [si] to al
		push	di
		mov	cx,48h

locloop_14:
		push	cx
		call	fade_screen_row
		add	di,2000h
		cmp	di,6000h
		jb	loc_15			; Jump if below
		call	fade_screen_row
		add	di,0A05Ah
loc_15:
		add	di,2000h
		cmp	di,6000h
		jb	loc_16			; Jump if below
		add	di,0A05Ah
loc_16:
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		pop	cx
		loop	locloop_14		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,6000h
		jb	loc_17			; Jump if below
		add	di,0A05Ah
loc_17:
		mov	cx,48h

locloop_18:
		push	cx
		call	fade_screen_row
		add	di,2000h
		cmp	di,6000h
		jb	loc_19			; Jump if below
		call	fade_screen_row
		add	di,0A05Ah
loc_19:
		add	di,2000h
		cmp	di,6000h
		jb	loc_20			; Jump if below
		add	di,data_44e
loc_20:
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		pop	cx
		loop	locloop_18		; Loop if cx > 0

		mov	cx,3E80h

locloop_21:
		loop	locloop_21		; Loop if cx > 0

		pop	cx
		loop	locloop_13		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fade_screen_row		proc	near
		push	di
		mov	cx,38h

locloop_22:
		and	es:[di],al
		inc	di
		loop	locloop_22		; Loop if cx > 0

		pop	di
		retn
fade_screen_row		endp

		db	0FEh,0EEh,0EAh,0AAh,0A8h, 88h
		db	 80h, 00h
loc_23:
		mov	cs:data_19e,al
		mov	ax,0B000h
		mov	es,ax
		xor	ax,ax			; Zero register
		mov	al,bl
		add	ax,0BAh
		mov	dl,3
		div	dl			; al, ah rem = ax/reg
		mov	dh,ah
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		mov	ah,5Ah			; 'Z'
		mul	ah			; ax = reg * al
		add	ax,dx
		add	bh,14h
		mov	dl,bh
		and	bh,3
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		xor	dh,dh			; Zero register
		add	ax,dx
		add	ax,0Ch
		mov	di,ax
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
		jz	loc_25			; Jump if zero
loc_24:
		push	cx
		mov	ax,0FFFFh
		call	plot_pixel
		pop	cx
		inc	di
		dec	cl
		jnz	loc_24			; Jump if not zero
loc_25:
		and	ch,3
		jnz	loc_26			; Jump if not zero
		retn
loc_26:
		mov	cl,ch
		shl	cl,1			; Shift w/zeros fill
		mov	ah,0FFh
		shr	ah,cl			; Shift w/zeros fill
		not	ah
		mov	al,ah

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

plot_pixel		proc	near
		test	byte ptr cs:data_19e,0FFh
		jnz	loc_29			; Jump if not zero
		push	di
		not	ah
		mov	cx,9

locloop_27:
		and	es:[di],ah
		add	di,2000h
		cmp	di,data_43e
		jb	loc_28			; Jump if below
		and	es:[di],ah
		add	di,data_44e
loc_28:
		loop	locloop_27		; Loop if cx > 0

		and	es:[di],ah
		or	es:[di],al
		pop	di
		retn
loc_29:
		cmp	byte ptr cs:data_19e,80h
		je	loc_32			; Jump if equal
		push	di
		mov	ah,al
		not	ah
		and	al,55h			; 'U'
		mov	cx,0Ah

locloop_30:
		and	es:[di],ah
		or	es:[di],al
		add	di,2000h
		cmp	di,data_43e
		jb	loc_31			; Jump if below
		and	es:[di],ah
		or	es:[di],al
		add	di,data_44e
loc_31:
		loop	locloop_30		; Loop if cx > 0

		pop	di
		retn
loc_32:
		push	di
		not	al
		mov	cx,0Ah

locloop_33:
		and	es:[di],al
		add	di,2000h
		cmp	di,data_43e
		jb	loc_34			; Jump if below
		and	es:[di],al
		add	di,0A05Ah
loc_34:
		loop	locloop_33		; Loop if cx > 0

		pop	di
		retn
plot_pixel		endp

		db	 00h,0BFh, 40h, 56h, 2Eh, 8Bh
		db	 1Eh,0B2h, 00h,0EBh, 05h,0BFh
		db	0A8h, 57h,0EBh, 00h,0B8h, 00h
		db	0B0h, 8Eh,0C0h,0E8h, 7Eh, 00h
		db	50h
loc_35:
		or	bl,bl			; Zero ?
		jz	loc_36			; Jump if zero
		push	di
		mov	bh,6
		mov	al,0AAh
		mov	ah,55h			; 'U'
		call	fill_vertical_line
		dec	bl
		pop	di
		inc	di
		jmp	short loc_35
loc_36:
		pop	ax
		or	al,al			; Zero ?
		jnz	loc_37			; Jump if not zero
		retn
loc_37:
		and	al,0AAh
		mov	ah,55h			; 'U'
		mov	bh,6
		jmp	short loc_45
			                        ;* No entry point to code
		mov	di,5640h
		mov	bx,word ptr cs:[90h]
		jmp	short loc_38
		db	0BFh,0A8h, 57h,0EBh, 00h
loc_38:
		mov	ax,0B000h
		mov	es,ax
		call	calc_text_width
		push	ax
		push	bx
loc_39:
		or	bl,bl			; Zero ?
		jz	loc_40			; Jump if zero
		push	di
		mov	bh,5
		mov	al,55h			; 'U'
		mov	ah,0AAh
		call	fill_vertical_line
		dec	bl
		pop	di
		inc	di
		jmp	short loc_39
loc_40:
		pop	bx
		pop	ax
		or	al,al			; Zero ?
		jz	loc_41			; Jump if zero
		push	di
		mov	bh,5
		and	al,55h			; 'U'
		mov	ah,0AAh
		call	fill_vertical_line
		pop	di
		inc	di
		inc	bl
loc_41:
		mov	bh,19h
		sub	bh,bl
		jnz	loc_42			; Jump if not zero
		retn
loc_42:
		mov	bl,bh
loc_43:
		push	di
		mov	bh,5
		xor	al,al			; Zero register
		mov	ah,0AAh
		call	fill_vertical_line
		pop	di
		inc	di
		dec	bl
		jnz	loc_43			; Jump if not zero
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	loc_44			; Jump if carry Set
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
loc_44:
		mov	bx,19h
		xor	al,al			; Zero register
		retn
calc_text_width		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_vertical_line		proc	near
loc_45:
		and	es:[di],ah
		or	es:[di],al
		add	di,2000h
		cmp	di,data_43e
		jb	loc_46			; Jump if below
		and	es:[di],ah
		or	es:[di],al
		add	di,0A05Ah
loc_46:
		dec	bh
		jnz	loc_45			; Jump if not zero
		retn
fill_vertical_line		endp

		db	 2Eh,0C6h, 06h, 7Fh, 2Eh, 55h
		db	 2Eh,0C6h, 06h, 80h, 2Eh,0AAh
		db	0EBh, 3Ch, 2Eh,0C6h, 06h, 7Fh
		db	 2Eh,0FFh, 2Eh,0C6h, 06h, 80h
		db	 2Eh, 00h,0EBh, 2Eh, 2Eh,0C6h
		db	 06h, 7Fh, 2Eh,0FFh, 2Eh,0C6h
		db	 06h, 80h, 2Eh, 00h,0E8h, 39h
		db	 0Ah, 8Bh,0F8h, 8Ah,0D9h,0B8h
		db	 00h,0B0h, 8Eh,0C0h
loc_47:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_48			; Jump if not zero
		retn
loc_48:
		push	bx
		push	ds
		push	si
		and	bl,3
		call	render_text_char
		pop	si
		pop	ds
		pop	bx
		inc	bl
		jmp	short loc_47
			                        ;* No entry point to code
		lodsb				; String [si] to al
		mov	bh,al
		lodsb				; String [si] to al
		mov	bl,al
		call	calc_hgc_address
		mov	di,ax
		lodsb				; String [si] to al
		mov	bl,al
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		mov	ax,0B000h
		mov	es,ax

locloop_49:
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
		loop	locloop_49		; Loop if cx > 0

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
		add	si,ds:data_37e
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8
loc_50:
		push	bx
		lodsb				; String [si] to al
		mov	dl,4
loc_51:
		add	ax,ax
		add	ah,ah
		dec	dl
		jnz	loc_51			; Jump if not zero
		mov	al,ah
		shr	ah,1			; Shift w/zeros fill
		or	al,ah
		xor	bl,bl			; Zero register
		mov	bh,al
		shr	bx,cl			; Shift w/zeros fill
		push	bx
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		xchg	bh,bl
		not	bx
		and	es:[di],bx
		not	bx
		and	bh,ds:data_24e
		and	bl,ds:data_24e
		or	es:[di],bx
		pop	bx
		xchg	bh,bl
		not	bx
		and	es:[di],bx
		not	bx
		and	bh,ds:data_23e
		and	bl,ds:data_23e
		or	es:[di],bx
		add	di,2000h
		cmp	di,data_31e
		jb	loc_52			; Jump if below
		mov	bx,di
		sub	bx,2000h
		mov	ax,es:[bx]
		mov	es:[di],ax
		add	di,0A05Ah
loc_52:
		pop	bx
		dec	bl
		jnz	loc_50			; Jump if not zero
		pop	di
		inc	di
		cmp	cl,6
		je	loc_53			; Jump if equal
		retn
loc_53:
		inc	di
		retn
render_text_char		endp

			                        ;* No entry point to code
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,88h
		jmp	loc_23
			                        ;* No entry point to code
		push	ds
		mov	ax,word ptr cs:[8Bh]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,2559h
		mov	cx,105h
		mov	ax,26BBh
		mov	bx,data_39e
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
		mov	di,2558h
		mov	cx,106h
		mov	ax,13BBh
		mov	bx,data_39e
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
		mov	di,255Bh
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,data_39e
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		test	byte ptr cs:[93h],0FFh
		jnz	loc_54			; Jump if not zero
		retn
loc_54:
		push	ds
		mov	ax,word ptr cs:[94h]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,255Bh
		mov	cx,103h
		mov	ax,3EBBh
		mov	bx,data_39e
		call	render_tilemap_large
		pop	ds
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

init_timestamp		proc	near
		mov	di,2557h
		call	time_to_bcd
		mov	cx,6

locloop_55:
		test	byte ptr cs:[di],0FFh
		jz	loc_56			; Jump if zero
		retn
loc_56:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	locloop_55		; Loop if cx > 0

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
loc_57:
		sub	dl,cl
		jc	loc_60			; Jump if carry Set
		sub	ax,bx
		jnc	loc_58			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_59			; Jump if zero
		dec	dl
loc_58:
		inc	dh
		jmp	short loc_57
loc_59:
		add	ax,bx
loc_60:
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
		mov	ds:data_24e,bh
		xor	bh,bh			; Zero register
		mov	dl,ds:data_20e[bx]
		mov	ds:data_23e,dl
		mov	bx,ax
		call	calc_hgc_address
		mov	bx,ax
		mov	ax,0B000h
		mov	es,ax
loc_61:
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
		jnz	loc_61			; Jump if not zero
		retn
render_tilemap_large		endp

		db	 00h,0FFh,0AAh,0FFh, 55h, 00h
		db	0FFh,0AAh

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decode_bitplane_tile		proc	near
		mov	bx,0Fh
		test	ch,1
		jz	loc_62			; Jump if zero
		mov	bx,0F000h
loc_62:
		test	byte ptr ds:data_24e,0FFh
		jz	loc_65			; Jump if zero
		push	di
		push	cx
		xchg	bh,bl
		mov	cx,7

locloop_63:
		and	es:[di],bx
		add	di,2000h
		cmp	di,data_43e
		jb	loc_64			; Jump if below
		and	es:[di],bx
		add	di,data_44e
loc_64:
		loop	locloop_63		; Loop if cx > 0

		pop	cx
		pop	di
loc_65:
		inc	al
		jnz	loc_66			; Jump if not zero
		retn
loc_66:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:data_36e
		mov	si,ax
		push	cs
		pop	ds
		mov	cl,7
loc_67:
		lodsb				; String [si] to al
		mov	ah,8
loc_68:
		add	al,al
		adc	dx,dx
		add	dx,dx
		dec	ah
		jnz	loc_68			; Jump if not zero
		mov	ax,dx
		shr	dx,1			; Shift w/zeros fill
		or	ax,dx
		test	ch,1
		jnz	loc_69			; Jump if not zero
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
loc_69:
		xchg	ah,al
		and	ah,cs:data_23e
		and	al,cs:data_23e
		or	es:[di],ax
		add	di,2000h
		cmp	di,data_43e
		jb	loc_70			; Jump if below
		or	es:[di],ax
		add	di,0A05Ah
loc_70:
		dec	cl
		jnz	loc_67			; Jump if not zero
		retn
decode_bitplane_tile		endp

			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_40e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,10Eh
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_1e
		mov	si,ax
		add	bh,bh
		call	calc_hgc_address
		mov	bp,ax
		mov	ax,0B000h
		mov	es,ax
		mov	cx,12h
loc_71:
		push	cx
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_28e,ax
		mov	ax,[si+8]
		mov	cs:data_29e,ax
		mov	ax,[si+0Ah]
		xchg	ah,al
		mov	cs:data_30e,ax
		call	extract_bitplane_pixels
		mov	es:[bp],dh
		mov	es:[bp+1],dl
		mov	ax,[si+2]
		xchg	ah,al
		mov	cs:data_28e,ax
		mov	ax,[si+6]
		mov	cs:data_29e,ax
		mov	ax,[si+0Ch]
		xchg	ah,al
		mov	cs:data_30e,ax
		call	extract_bitplane_pixels
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		xor	al,al			; Zero register
		mov	ah,[si+4]
		mov	cs:data_28e,ax
		mov	ah,[si+5]
		mov	cs:data_29e,ax
		mov	ah,[si+0Eh]
		mov	cs:data_30e,ax
		call	extract_bitplane_pixels
		mov	es:[bp+4],dh
		add	si,0Fh
		add	bp,2000h
		cmp	bp,data_43e
		jb	loc_72			; Jump if below
		mov	di,bp
		sub	di,2000h
		mov	ax,es:[di]
		mov	es:[bp],ax
		mov	ax,es:[di+2]
		mov	es:[bp+2],ax
		mov	al,es:[di+4]
		mov	es:[bp+4],al
		add	bp,0A05Ah
loc_72:
		pop	cx
		loop	locloop_73		; Loop if cx > 0

		jmp	short loc_74

locloop_73:
		jmp	loc_71
loc_74:
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_40e
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
		mov	ds,cs:data_40e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_2e
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,27D0h
		or	al,al			; Zero ?
		jz	loc_75			; Jump if zero
		mov	ds,cs:data_40e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_5e
		mov	si,ax
loc_75:
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,27D0h
		or	al,al			; Zero ?
		jz	loc_76			; Jump if zero
		mov	ds,cs:data_40e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_4e
		mov	si,ax
loc_76:
		call	render_tilemap_small
		pop	ds
		retn
		db	 00h, 00h, 00h, 00h,0FCh,0FFh
		db	0FFh, 3Fh, 2Ah,0AAh,0AAh,0A8h
		db	 00h, 00h, 00h, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 00h, 00h, 02h
		db	 0Eh, 38h,0F8h, 00h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 08h, 02h
		db	 0Fh,0BBh, 8Eh, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 88h, 82h, 02h
		db	 0Fh,0FBh, 8Eh, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 08h, 82h, 02h
		db	 0Eh,0FBh, 8Eh, 00h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 82h, 02h
		db	 0Eh, 38h,0F8h, 00h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 08h, 02h
		db	 00h, 00h, 00h, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 00h, 00h, 02h
		db	 00h, 00h, 00h, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 00h, 00h, 02h
		db	 0Eh, 38h,0FBh,0F8h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 08h, 0Ah
		db	 0Eh, 3Bh, 83h, 80h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 80h, 82h
		db	 0Eh, 38h,0E3h,0C0h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 20h, 02h
		db	 0Eh, 38h, 3Bh, 80h, 03h, 00h
		db	 00h,0C0h, 82h, 08h, 08h, 82h
		db	 03h,0E3h,0E3h,0F8h, 03h, 00h
		db	 00h,0C0h, 80h, 20h, 20h, 0Ah
		db	 00h, 00h, 00h, 00h, 03h, 00h
		db	 00h,0C0h, 80h, 00h, 00h, 02h
		db	 00h, 00h, 00h, 00h,0FCh,0FFh
		db	0FFh, 3Fh, 2Ah,0AAh,0AAh,0A8h
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
		call	calc_hgc_address
		mov	bp,ax
		mov	ax,0B000h
		mov	es,ax
		mov	cx,10h
loc_77:
		push	cx
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_28e,ax
		mov	ax,[si+6]
		mov	cs:data_29e,ax
		mov	ax,[si+8]
		xchg	ah,al
		mov	cs:data_30e,ax
		call	extract_bitplane_pixels
		mov	ax,dx
		mov	dx,[si+2]
		xchg	dh,dl
		mov	cs:data_28e,dx
		mov	dx,[si+4]
		mov	cs:data_29e,dx
		mov	dx,[si+0Ah]
		xchg	dh,dl
		mov	cs:data_30e,dx
		call	extract_bitplane_pixels
		xor	bl,bl			; Zero register
		mov	cx,4

locloop_78:
		shr	ax,1			; Shift w/zeros fill
		rcr	dx,1			; Rotate thru carry
		rcr	bl,1			; Rotate thru carry
		loop	locloop_78		; Loop if cx > 0

		mov	es:[bp],ah
		mov	es:[bp+1],al
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		mov	es:[bp+4],bl
		add	si,0Ch
		add	bp,2000h
		cmp	bp,data_43e
		jb	loc_79			; Jump if below
		mov	es:[bp],ah
		mov	es:[bp+1],al
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		mov	es:[bp+4],bl
		add	bp,0A05Ah
loc_79:
		pop	cx
		loop	locloop_80		; Loop if cx > 0

		jmp	short loc_ret_81

locloop_80:
		jmp	loc_77

loc_ret_81:
		retn
render_tilemap_small		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

extract_bitplane_pixels		proc	near
		mov	cx,8

locloop_82:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_30e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_29e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_28e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_30e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_29e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_28e,1	; Rotate
		adc	bx,bx
		add	dx,dx
		add	dx,dx
		or	dl,cs:data_21e[bx]
		loop	locloop_82		; Loop if cx > 0

		retn
extract_bitplane_pixels		endp

		db	0, 1, 2, 1, 1, 0
		db	3, 2, 1, 3, 3, 3
		db	1, 3, 3, 2, 2, 3
		db	2, 1, 1, 2, 2, 2
		db	1, 3, 1, 3, 1, 1
		db	2, 2, 1, 1, 1, 1
		db	1, 1, 3, 2, 0, 3
		db	2, 1, 1, 1, 3, 2
		db	3, 3, 2, 2, 3, 3
		db	3, 2, 1, 2, 2, 2
		db	2, 2, 2, 2

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

render_text_char_alt		proc	near
		push	ds
		push	cs
		pop	ds
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,ds:data_20e[bx]
		mov	ds:data_23e,ah
		pop	bx
		xor	ah,ah			; Zero register
		sub	al,20h			; ' '
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:data_35e
		push	ax
		add	bx,14h
		mov	al,bl
		and	al,3
		add	al,al
		mov	ds:data_24e,al
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		xor	ch,ch			; Zero register
		add	cx,1Ch
		mov	ax,cx
		mov	dl,3
		div	dl			; al, ah rem = ax/reg
		mov	dh,ah
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		mov	ah,5Ah			; 'Z'
		mul	ah			; ax = reg * al
		and	dx,6000h
		add	ax,dx
		add	ax,bx
		mov	di,ax
		pop	si
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

locloop_83:
		push	cx
		lodsb				; String [si] to al
		call	double_char_bits
		mov	cl,cs:data_24e
		mov	ah,dl
		xor	dl,dl			; Zero register
		mov	al,dl
		shr	dx,cl			; Shift w/zeros fill
		shr	ax,cl			; Shift w/zeros fill
		or	dl,ah
		mov	ch,al
		xchg	dh,dl
		mov	bx,dx
		mov	cl,ch
		not	bx
		not	cl
		and	dl,cs:data_23e
		and	dh,cs:data_23e
		and	ch,cs:data_23e
		and	es:[di],bx
		and	es:[di+2],cl
		or	es:[di],dx
		or	es:[di+2],ch
		add	di,2000h
		cmp	di,data_43e
		jb	loc_84			; Jump if below
		and	es:[di],bx
		and	es:[di+2],cl
		or	es:[di],dx
		or	es:[di+2],ch
		add	di,0A05Ah
loc_84:
		pop	cx
		loop	locloop_83		; Loop if cx > 0

		pop	ds
		retn
render_text_char_alt		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

double_char_bits		proc	near
		mov	cx,8

locloop_85:
		add	al,al
		adc	bx,bx
		add	bx,bx
		loop	locloop_85		; Loop if cx > 0

		mov	dx,bx
		shr	dx,1			; Shift w/zeros fill
		or	dx,bx
		retn
double_char_bits		endp

			                        ;* No entry point to code
		push	ds
		add	bh,bh
		call	calc_hgc_address
		mov	di,ax
		mov	si,di
		add	si,2000h
		cmp	si,6000h
		jb	loc_86			; Jump if below
		add	si,data_44e
loc_86:
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_87:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,2000h
		cmp	di,data_43e
		jb	loc_88			; Jump if below
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,0A05Ah
loc_88:
		add	si,2000h
		cmp	si,6000h
		jb	loc_89			; Jump if below
		add	si,0A05Ah
loc_89:
		pop	cx
		loop	locloop_87		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		add	di,0
		mov	bx,ax
		add	bh,bh
		call	calc_hgc_address
		mov	si,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,0B000h
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

locloop_90:
		push	cx
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,6000h
		jb	loc_91			; Jump if below
		add	si,0A05Ah
loc_91:
		pop	cx
		loop	locloop_90		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,di
		add	si,0
		mov	bx,ax
		add	bh,bh
		call	calc_hgc_address
		mov	di,ax
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	ax,0B000h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

locloop_92:
		push	cx
		push	si
		push	di
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	di,2000h
		cmp	di,data_43e
		jb	loc_93			; Jump if below
		push	si
		push	di
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	di,0A05Ah
loc_93:
		add	si,bx
		add	si,bx
		pop	cx
		loop	locloop_92		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	cs:data_26e,bx
		mov	cs:data_27e,cl
		mov	byte ptr cs:data_25e,1
loc_94:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_95			; Jump if not equal
		retn
loc_95:
		cmp	al,0Dh
		je	loc_96			; Jump if equal
		or	al,al			; Zero ?
		js	loc_97			; Jump if sign=1
		push	cx
		push	bx
		push	si
		mov	ah,cs:data_25e
		call	render_text_char_alt
		pop	si
		pop	bx
		pop	cx
		add	bx,8
		jmp	short loc_94
loc_96:
		add	byte ptr cs:data_27e,8
		mov	cl,cs:data_27e
		mov	bx,cs:data_26e
		jmp	short loc_94
loc_97:
		and	al,7
		mov	cs:data_25e,al
		jmp	short loc_94
			                        ;* No entry point to code
		push	ds
		add	bh,bh
		call	calc_hgc_address
		mov	si,ax
		mov	bx,dx
		add	bh,bh
		call	calc_hgc_address
		mov	di,ax
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_98:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,2000h
		cmp	di,data_43e
		jb	loc_99			; Jump if below
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,0A05Ah
loc_99:
		add	si,2000h
		cmp	si,6000h
		jb	loc_100			; Jump if below
		add	si,0A05Ah
loc_100:
		pop	cx
		loop	locloop_98		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	al,ds:data_22e[bx]
		mov	ds:data_23e,al
		pop	bx
		call	calc_hgc_address
		mov	di,ax
		mov	ax,0B000h
		mov	es,ax
		call	fill_rectangle
		mov	cx,10h

locloop_101:
		mov	al,ds:data_23e
		and	al,0F0h
		and	byte ptr es:[di],0Fh
		or	es:[di],al
		mov	al,ds:data_23e
		and	al,0Fh
		and	byte ptr es:[di+4],0F0h
		or	es:[di+4],al
		add	di,2000h
		cmp	di,data_43e
		jb	loc_102			; Jump if below
		mov	al,ds:data_23e
		and	al,0F0h
		and	byte ptr es:[di],0Fh
		or	es:[di],al
		mov	al,ds:data_23e
		and	al,0Fh
		and	byte ptr es:[di+4],0F0h
		or	es:[di+4],al
		add	di,data_32e
loc_102:
		loop	locloop_101		; Loop if cx > 0

		call	fill_rectangle
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_rectangle		proc	near
		mov	cx,2

locloop_103:
		push	cx
		push	di
		mov	al,ds:data_23e
		mov	cx,5
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,2000h
		cmp	di,data_43e
		jb	loc_104			; Jump if below
		push	di
		mov	al,ds:data_23e
		mov	cx,5
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,0A05Ah
loc_104:
		pop	cx
		loop	locloop_103		; Loop if cx > 0

		retn
fill_rectangle		endp

		db	 00h,0FFh,0AAh,0FFh, 55h,0FFh
		db	0FFh,0AAh, 1Eh, 56h, 0Eh, 1Fh
		db	 32h,0E4h, 03h,0C0h, 03h,0C0h
		db	 8Bh,0F0h,0E8h, 53h, 01h, 8Bh
		db	0F8h,0B8h, 00h,0B0h, 8Eh,0C0h
		db	 8Bh, 9Ch, 2Ah, 2Dh, 8Bh,0B4h
		db	 2Ch, 2Dh,0B9h, 0Dh, 00h

locloop_105:
		push	cx
		mov	al,[bx]
		and	es:[di],al
		mov	al,[bx+1]
		and	es:[di+1],al
		mov	al,[bx+2]
		and	es:[di+2],al
		mov	al,[bx+3]
		and	es:[di+3],al
		lodsb				; String [si] to al
		or	es:[di],al
		lodsb				; String [si] to al
		or	es:[di+1],al
		lodsb				; String [si] to al
		or	es:[di+2],al
		lodsb				; String [si] to al
		or	es:[di+3],al
		add	bx,4
		add	di,2000h
		cmp	di,data_31e
		jb	loc_106			; Jump if below
		mov	bp,di
		sub	bp,2000h
		mov	ax,es:[bp]
		mov	es:[di],ax
		mov	ax,es:[bp+2]
		mov	es:[di+2],ax
		add	di,0A05Ah
loc_106:
		pop	cx
		loop	locloop_105		; Loop if cx > 0

		pop	si
		pop	ds
		retn
		db	 32h, 2Dh, 9Ah, 2Dh, 66h, 2Dh
		db	0CEh, 2Dh,0FFh,0F0h, 0Ch,0FFh
		db	0FFh,0C0h, 00h,0FFh,0FFh, 00h
		db	 00h,0FFh,0FFh, 00h, 00h,0FFh
		db	0FFh, 00h, 00h,0FFh,0FFh, 00h
		db	 00h,0FFh,0FFh, 00h, 00h,0FFh
		db	0FFh,0C0h, 00h,0FFh,0FFh,0C0h
		db	 00h,0FFh,0FFh,0C0h, 00h,0FFh
		db	0FFh,0CCh, 0Ch,0FFh
		db	9 dup (0FFh)
		db	 00h, 00h,0FFh,0FCh, 00h, 00h
		db	 3Fh,0F0h, 00h, 00h, 0Fh,0F0h
		db	 00h, 00h, 0Fh,0C0h, 00h, 00h
		db	 03h,0C0h, 00h, 00h, 03h,0C0h
		db	 00h, 00h, 03h,0C0h, 00h, 00h
		db	 03h,0F0h, 00h, 00h, 0Fh,0F0h
		db	 00h, 00h, 0Fh,0FCh, 00h, 00h
		db	 3Fh,0FFh, 00h, 00h,0FFh,0FFh
		db	0C0h, 03h,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 0Ah,0A0h, 00h, 00h
		db	 3Bh,0F8h, 00h, 00h, 2Fh,0D6h
		db	 00h, 00h,0E7h,0D6h, 00h, 00h
		db	0E5h, 56h, 00h, 00h,0A5h, 56h
		db	 00h, 00h, 25h, 56h, 00h, 00h
		db	 29h, 58h, 00h, 00h, 0Ah,0A0h
		db	 00h, 00h
		db	12 dup (0)
		db	 3Fh,0D4h, 00h, 00h,0F0h, 05h
		db	 00h, 03h,0CFh,0C1h, 40h, 0Fh
		db	 3Fh, 0Ch, 50h, 0Fh,0FCh, 03h
		db	 50h, 0Ch,0F0h,0A0h, 10h, 0Ch
		db	0C2h,0AAh, 90h, 0Dh,0EAh,0AAh
		db	0D0h, 0Dh,0BAh,0AAh,0F0h, 01h
		db	 6Bh,0ABh,0C0h, 00h, 58h,0AFh
		db	 00h, 00h, 1Dh, 54h, 00h, 00h
		db	 00h, 00h, 00h,0B8h, 00h,0B0h
		db	 8Eh,0C0h, 33h,0FFh, 33h,0C0h
		db	0B9h, 00h, 40h,0F3h,0ABh,0C3h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

calc_hgc_address		proc	near
		xor	ax,ax			; Zero register
		mov	al,bl
		add	ax,1Ch
		mov	bl,3
		div	bl			; al, ah rem = ax/reg
		mov	bl,ah
		ror	bl,1			; Rotate
		ror	bl,1			; Rotate
		ror	bl,1			; Rotate
		and	bl,60h			; '`'
		mov	ah,5Ah			; 'Z'
		mul	ah			; ax = reg * al
		add	ah,bl
		add	bh,5
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		retn
calc_hgc_address		endp

			                        ;* No entry point to code
		push	cx
		push	ds
		push	si
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,30h
		mul	cx			; dx:ax = reg * ax
		mov	cx,ax
		mov	di,data_41e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,data_41e

locloop_107:
		push	cx
		call	process_sprite_row
		pop	cx
		loop	locloop_107		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

process_sprite_row		proc	near
		mov	cx,8

locloop_108:
		push	cx
		lodsw				; String [si] to ax
		mov	cs:data_28e,ax
		lodsw				; String [si] to ax
		mov	cs:data_29e,ax
		lodsw				; String [si] to ax
		mov	cs:data_30e,ax
		call	extract_bitplane_pixels
		mov	ax,dx
		stosw				; Store ax to es:[di]
		pop	cx
		loop	locloop_108		; Loop if cx > 0

		retn
process_sprite_row		endp

		db	12 dup (0)

seg_a		ends



		end	start
