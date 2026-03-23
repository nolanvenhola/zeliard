
PAGE  59,132

;==========================================================================
;
;  GMTGA.BIN - Tandy Graphics Adapter 16-Color Driver (Mode 9, 320x200)
;
;  TGA variant of the graphics driver API. Uses Tandy's linear 16-color
;  framebuffer with nibble-packed pixels (2 pixels per byte).
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
data_19e	equ	21A7h			;*
data_20e	equ	22A6h			;*
data_21e	equ	262Eh			;*
data_22e	equ	2999h			;*
data_23e	equ	2CB7h			;*
data_24e	equ	2CB9h			;*
data_25e	equ	2E6Ch			;*
data_26e	equ	2E6Dh			;*
data_27e	equ	2E6Eh			;*
data_28e	equ	2E6Fh			;*
data_29e	equ	2E71h			;*
data_30e	equ	2E72h			;*
data_31e	equ	2E74h			;*
data_32e	equ	2E76h			;*
data_33e	equ	80A0h			;*
data_34e	equ	0A721h			;*
data_35e	equ	0EB22h			;*
data_36e	equ	0F500h			;*
data_37e	equ	0F502h			;*
data_38e	equ	0F504h			;*
data_39e	equ	0FF01h			;*
data_40e	equ	0FF2Ch			;*
data_41e	equ	0			;*
data_42e	equ	80A0h			;*
data_43e	equ	41F8h
data_44e	equ	80A0h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

gmtga		proc	far

start:
		inc	si
;*		and	al,dh
		db	 20h,0F0h		;  Fixup - byte match
		and	ds:data_34e[bx],dh
		and	ah,cl
		and	dh,ds:data_35e[bx+di]
		and	bh,[bx+si+23h]
		xchg	[bp+di],ah
		db	0DCh, 24h,0E6h, 24h, 03h, 25h
		db	 23h, 25h, 4Ch, 25h,0B0h, 26h
		db	 71h, 27h, 8Bh, 27h,0D9h, 29h
		db	 68h, 2Ah,0BBh, 2Ah, 0Fh, 2Bh
		db	 65h, 2Bh,0AEh, 2Bh,0FCh, 2Bh
		db	0FAh, 25h, 91h, 25h,0A5h, 27h
		db	0C6h, 27h, 94h, 23h,0A7h, 28h
		db	0BFh, 28h, 5Bh, 2Ch, 24h, 21h
		db	0C3h, 2Dh,0F6h, 2Dh, 50h, 02h
		db	0FFh,0E8h, 02h, 0Eh, 8Bh,0F8h
		db	 58h, 0Ah,0C0h, 74h, 77h, 57h
		db	 80h,0E9h, 04h, 81h,0C7h, 00h
		db	 40h, 81h,0FFh, 00h, 80h, 72h
		db	 04h, 81h,0C7h,0A0h, 80h
loc_1:
		call	clear_screen
		pop	di
		mov	ax,0
		call	fill_horizontal_line
		mov	ax,0F00Fh
		call	fill_horizontal_line
		push	cx
		push	bx
		mov	bl,ch
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_2:
		mov	byte ptr es:[di],0FFh
		mov	byte ptr es:[bx+di+1],0FFh
		add	di,2000h
		cmp	di,8000h
		jb	loc_3			; Jump if below
		add	di,data_44e
loc_3:
		loop	locloop_2		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0F00Fh
		call	fill_horizontal_line
		mov	ax,0

gmtga		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_horizontal_line		proc	near
		push	di
		or	es:[di],al
		inc	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		dec	cx
		add	cx,cx
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	es:[di],ah
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_ret_4		; Jump if below
		add	di,80A0h

loc_ret_4:
		retn
fill_horizontal_line		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

clear_screen		proc	near
loc_5:
		mov	ax,0B800h
		mov	es,ax
		push	cx
loc_6:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_7			; Jump if below
		add	di,80A0h
loc_7:
		dec	cl
		jnz	loc_6			; Jump if not zero
		pop	cx
		retn
clear_screen		endp

			                        ;* No entry point to code
		mov	ax,0B800h
		mov	es,ax
		mov	di,data_43e
		mov	cx,8

locloop_8:
		push	cx
		push	di
		mov	cx,12h

locloop_9:
		push	cx
		push	di
		mov	cx,38h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		add	di,140h
		pop	cx
		loop	locloop_9		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_10			; Jump if below
		add	di,80A0h
loc_10:
		pop	cx
		loop	locloop_8		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	ax,0B800h
		mov	es,ax
		mov	si,data_19e
		mov	cx,8

locloop_11:
		push	cx
		mov	di,data_43e
		lodsw				; String [si] to ax
		push	di
		mov	cx,48h

locloop_12:
		push	cx
		push	di
		mov	cx,38h

locloop_13:
		and	es:[di],ax
		inc	di
		inc	di
		loop	locloop_13		; Loop if cx > 0

		pop	di
		add	di,4000h
		cmp	di,8000h
		jb	loc_14			; Jump if below
		add	di,80A0h
loc_14:
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		pop	cx
		loop	locloop_12		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_15			; Jump if below
		add	di,data_44e
loc_15:
		mov	cx,48h

locloop_16:
		push	cx
		push	di
		mov	cx,38h

locloop_17:
		and	es:[di],ax
		inc	di
		inc	di
		loop	locloop_17		; Loop if cx > 0

		pop	di
		pop	cx
		add	di,4000h
		cmp	di,8000h
		jb	loc_18			; Jump if below
		add	di,data_44e
loc_18:
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		loop	locloop_16		; Loop if cx > 0

		mov	cx,3E80h

locloop_19:
		loop	locloop_19		; Loop if cx > 0

		pop	cx
		loop	locloop_11		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		cld				; Clear direction
		db	0FFh,0FCh,0FCh,0CCh,0FCh,0CCh
		db	0CCh,0C0h,0CCh,0C0h,0C0h, 00h
		db	0C0h, 00h, 00h
loc_20:
		mov	cs:data_20e,al
		mov	ax,0B800h
		mov	es,ax
		add	bl,9Eh
		mov	dh,bl
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		mov	ax,0A0h
		mul	bl			; ax = reg * al
		add	ax,dx
		mov	di,ax
		mov	dl,bh
		and	bh,1
		shr	dl,1			; Shift w/zeros fill
		add	dl,18h
		xor	dh,dh			; Zero register
		add	di,dx
		mov	cl,bh
		add	cl,cl
		add	cl,cl
		mov	ax,0FF0Fh
		shr	ah,cl			; Shift w/zeros fill
		shr	al,cl			; Shift w/zeros fill
		neg	bh
		add	bh,1
		sub	ch,bh
		push	cx
		call	plot_pixel
		pop	cx
		inc	di
		mov	cl,ch
		shr	cl,1			; Shift w/zeros fill
		test	cl,0FFh
		jz	loc_22			; Jump if zero
loc_21:
		push	cx
		mov	ax,0FFFFh
		call	plot_pixel
		pop	cx
		inc	di
		dec	cl
		jnz	loc_21			; Jump if not zero
loc_22:
		and	ch,1
		jnz	loc_23			; Jump if not zero
		retn
loc_23:
		mov	cl,ch
		add	cl,cl
		add	cl,cl
		mov	ah,0FFh
		shr	ah,cl			; Shift w/zeros fill
		not	ah
		mov	al,ah

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

plot_pixel		proc	near
		test	byte ptr cs:data_20e,0FFh
		jnz	loc_26			; Jump if not zero
		push	di
		not	ah
		mov	dl,al
		and	dl,11h
		mov	cx,9

locloop_24:
		and	es:[di],ah
		or	es:[di],dl
		add	di,2000h
		cmp	di,8000h
		jb	loc_25			; Jump if below
		add	di,data_44e
loc_25:
		loop	locloop_24		; Loop if cx > 0

		and	es:[di],ah
		and	al,99h
		or	es:[di],al
		pop	di
		retn
loc_26:
		cmp	byte ptr cs:data_20e,80h
		je	loc_29			; Jump if equal
		push	di
		mov	ah,al
		not	ah
		and	al,77h			; 'w'
		mov	cx,0Ah

locloop_27:
		and	es:[di],ah
		or	es:[di],al
		add	di,2000h
		cmp	di,8000h
		jb	loc_28			; Jump if below
		add	di,data_44e
loc_28:
		loop	locloop_27		; Loop if cx > 0

		pop	di
		retn
loc_29:
		push	di
		not	al
		mov	cx,0Ah

locloop_30:
		and	es:[di],al
		add	di,2000h
		cmp	di,8000h
		jb	loc_31			; Jump if below
		add	di,80A0h
loc_31:
		loop	locloop_30		; Loop if cx > 0

		pop	di
		retn
plot_pixel		endp

		db	 00h,0BFh, 2Ah, 79h, 2Eh, 8Bh
		db	 1Eh,0B2h, 00h,0EBh, 05h,0BFh
		db	 0Ah, 7Bh,0EBh, 00h,0B8h, 00h
		db	0B8h, 8Eh,0C0h,0E8h, 7Eh, 00h
		db	50h
loc_32:
		or	bl,bl			; Zero ?
		jz	loc_33			; Jump if zero
		push	di
		mov	bh,6
		mov	al,44h			; 'D'
		mov	ah,33h			; '3'
		call	fill_vertical_line
		dec	bl
		pop	di
		inc	di
		jmp	short loc_32
loc_33:
		pop	ax
		or	al,al			; Zero ?
		jnz	loc_34			; Jump if not zero
		retn
loc_34:
		and	al,44h			; 'D'
		mov	ah,33h			; '3'
		mov	bh,6
		jmp	short loc_42
			                        ;* No entry point to code
		mov	di,792Ah
		mov	bx,word ptr cs:[90h]
		jmp	short loc_35
		db	0BFh, 0Ah, 7Bh,0EBh, 00h
loc_35:
		mov	ax,0B800h
		mov	es,ax
		call	calc_text_width
		push	ax
		push	bx
loc_36:
		or	bl,bl			; Zero ?
		jz	loc_37			; Jump if zero
		push	di
		mov	bh,5
		mov	al,0AAh
		mov	ah,0FFh
		call	fill_vertical_line
		dec	bl
		pop	di
		inc	di
		jmp	short loc_36
loc_37:
		pop	bx
		pop	ax
		or	al,al			; Zero ?
		jz	loc_38			; Jump if zero
		push	di
		mov	bh,5
		and	al,0AAh
		mov	ah,0FFh
		call	fill_vertical_line
		pop	di
		inc	di
		inc	bl
loc_38:
		mov	bh,32h			; '2'
		sub	bh,bl
		jnz	loc_39			; Jump if not zero
		retn
loc_39:
		mov	bl,bh
loc_40:
		push	di
		mov	bh,5
		xor	al,al			; Zero register
		mov	ah,44h			; 'D'
		call	fill_vertical_line
		pop	di
		inc	di
		dec	bl
		jnz	loc_40			; Jump if not zero
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	loc_41			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	cl,bl
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		and	cl,2
		add	cl,cl
		mov	al,0FFh
		shr	al,cl			; Shift w/zeros fill
		not	al
		retn
loc_41:
		mov	bx,32h
		xor	al,al			; Zero register
		retn
calc_text_width		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_vertical_line		proc	near
loc_42:
		and	es:[di],ah
		or	es:[di],al
		add	di,2000h
		cmp	di,8000h
		jb	loc_43			; Jump if below
		add	di,80A0h
loc_43:
		dec	bh
		jnz	loc_42			; Jump if not zero
		retn
fill_vertical_line		endp

			                        ;* No entry point to code
		mov	byte ptr cs:data_25e,0AAh
		mov	byte ptr cs:data_26e,44h	; 'D'
		jmp	short loc_46
			                        ;* No entry point to code
		mov	byte ptr cs:data_25e,0FFh
		mov	byte ptr cs:data_26e,88h
		jmp	short loc_46
			                        ;* No entry point to code
		mov	byte ptr cs:data_25e,0FFh
		mov	byte ptr cs:data_26e,0
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	bl,cl
		shr	bx,1			; Shift w/zeros fill
		and	bx,1
		add	di,bx
		mov	bl,cl
		mov	ax,0B800h
		mov	es,ax
loc_44:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_45			; Jump if not zero
		retn
loc_45:
		push	bx
		push	ds
		push	si
		and	bl,1
		call	render_text_char
		pop	si
		pop	ds
		pop	bx
		inc	bl
		jmp	short loc_44
loc_46:
		lodsb				; String [si] to al
		mov	bh,al
		add	bh,bh
		lodsb				; String [si] to al
		mov	bl,al
		call	bitplane_to_pixels
		mov	di,ax
		lodsb				; String [si] to al
		mov	bl,al
		shr	ax,1			; Shift w/zeros fill
		and	ax,1
		add	di,ax
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		mov	ax,0B800h
		mov	es,ax

locloop_47:
		push	cx
		lodsb				; String [si] to al
		push	bx
		push	ds
		push	si
		and	bl,1
		call	render_text_char
		pop	si
		pop	ds
		pop	bx
		inc	bl
		pop	cx
		loop	locloop_47		; Loop if cx > 0

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
		add	si,ds:data_38e
		add	bl,bl
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8
loc_48:
		push	bx
		lodsb				; String [si] to al
		call	extract_bitplane_bit
		push	ax
		call	extract_bitplane_bit
		pop	bx
		mov	bl,ah
		mov	dh,bl
		xor	dl,dl			; Zero register
		shr	bx,cl			; Shift w/zeros fill
		shr	dx,cl			; Shift w/zeros fill
		mov	dh,dl
		xor	dl,dl			; Zero register
		push	bx
		push	dx
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		sbb	al,al
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		and	al,0F0h
		or	dh,al
		xchg	bh,bl
		xchg	dh,dl
		not	bx
		not	dx
		and	es:[di],bx
		and	es:[di+2],dx
		not	bx
		not	dx
		and	bh,ds:data_26e
		and	bl,ds:data_26e
		and	dh,ds:data_26e
		and	dl,ds:data_26e
		or	es:[di],bx
		or	es:[di+2],dx
		pop	dx
		pop	bx
		xchg	bh,bl
		xchg	dh,dl
		not	bx
		not	dx
		and	es:[di],bx
		and	es:[di+2],dx
		not	bx
		not	dx
		and	bh,ds:data_25e
		and	bl,ds:data_25e
		and	dh,ds:data_25e
		and	dl,ds:data_25e
		or	es:[di],bx
		or	es:[di+2],dx
		add	di,2000h
		cmp	di,8000h
		jb	loc_49			; Jump if below
		add	di,80A0h
loc_49:
		pop	bx
		dec	bl
		jz	loc_50			; Jump if zero
		jmp	loc_48
loc_50:
		pop	di
		inc	di
		inc	di
		cmp	cl,4
		je	loc_51			; Jump if equal
		retn
loc_51:
		inc	di
		retn
render_text_char		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

extract_bitplane_bit		proc	near
		xor	ah,ah			; Zero register
		mov	dl,2
loc_52:
		add	al,al
		sbb	dh,dh
		and	dh,0Fh
		add	ah,ah
		add	ah,ah
		add	ah,ah
		add	ah,ah
		or	ah,dh
		dec	dl
		jnz	loc_52			; Jump if not zero
		retn
extract_bitplane_bit		endp

			                        ;* No entry point to code
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,88h
		jmp	loc_20
			                        ;* No entry point to code
		push	ds
		mov	ax,word ptr cs:[8Bh]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,258Ch
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
		mov	di,258Bh
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
		mov	di,258Eh
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,data_39e
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		test	byte ptr cs:[93h],0FFh
		jnz	loc_53			; Jump if not zero
		retn
loc_53:
		push	ds
		mov	ax,word ptr cs:[94h]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,258Eh
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
		mov	di,258Ah
		call	time_to_bcd
		mov	cx,6

locloop_54:
		test	byte ptr cs:[di],0FFh
		jz	loc_55			; Jump if zero
		retn
loc_55:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	locloop_54		; Loop if cx > 0

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
loc_56:
		sub	dl,cl
		jc	loc_59			; Jump if carry Set
		sub	ax,bx
		jnc	loc_57			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_58			; Jump if zero
		dec	dl
loc_57:
		inc	dh
		jmp	short loc_56
loc_58:
		add	ax,bx
loc_59:
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
		mov	si,di
		mov	ds:data_26e,bh
		xor	bh,bh			; Zero register
		mov	dl,ds:data_21e[bx]
		mov	ds:data_25e,dl
		mov	bx,ax
		shr	ch,1			; Shift w/zeros fill
		adc	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		xor	ch,ch			; Zero register
		mov	ax,0B800h
		mov	es,ax

locloop_60:
		push	cx
		lodsb				; String [si] to al
		push	di
		push	si
		push	ds
		call	decode_bitplane_tile
		pop	ds
		pop	si
		pop	di
		add	di,3
		pop	cx
		loop	locloop_60		; Loop if cx > 0

		retn
render_tilemap_large		endp

			                        ;* No entry point to code
;*		mov	bh,bh
		db	 88h,0FFh		;  Fixup - byte match
		int	3			; Debug breakpoint
		stosb				; Store al to es:[di]
		mov	bx,0EE99h
		db	0DDh

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decode_bitplane_tile		proc	near
		test	byte ptr ds:data_26e,0FFh
		jz	loc_63			; Jump if zero
		push	di
		push	cx
		mov	cx,7

locloop_61:
		mov	word ptr es:[di],1111h
		mov	byte ptr es:[di+2],11h
		add	di,2000h
		cmp	di,8000h
		jb	loc_62			; Jump if below
		add	di,80A0h
loc_62:
		loop	locloop_61		; Loop if cx > 0

		pop	cx
		pop	di
loc_63:
		cmp	al,0FFh
		jne	loc_64			; Jump if not equal
		retn
loc_64:
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:data_37e
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,7

locloop_65:
		lodsb				; String [si] to al
		add	al,al
		add	al,al
		call	extract_bitplane_bit
		and	ah,cs:data_25e
		or	es:[di],ah
		call	extract_bitplane_bit
		and	ah,cs:data_25e
		or	es:[di+1],ah
		call	extract_bitplane_bit
		and	ah,cs:data_25e
		or	es:[di+2],ah
		add	di,2000h
		cmp	di,8000h
		jb	loc_66			; Jump if below
		add	di,80A0h
loc_66:
		loop	locloop_65		; Loop if cx > 0

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
		add	bh,bh
		call	bitplane_to_pixels
		mov	bp,ax
		mov	ax,0B800h
		mov	es,ax
		mov	cx,12h
loc_67:
		push	cx
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_30e,ax
		mov	ax,[si+8]
		mov	cs:data_31e,ax
		mov	ax,[si+0Ah]
		xchg	ah,al
		mov	cs:data_32e,ax
		call	extract_bitplane_pixels
		mov	es:[bp],dh
		mov	es:[bp+1],dl
		call	extract_bitplane_pixels
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		mov	ax,[si+2]
		xchg	ah,al
		mov	cs:data_30e,ax
		mov	ax,[si+6]
		mov	cs:data_31e,ax
		mov	ax,[si+0Ch]
		xchg	ah,al
		mov	cs:data_32e,ax
		call	extract_bitplane_pixels
		mov	es:[bp+4],dh
		mov	es:[bp+5],dl
		call	extract_bitplane_pixels
		mov	es:[bp+6],dh
		mov	es:[bp+7],dl
		xor	al,al			; Zero register
		mov	ah,[si+4]
		mov	cs:data_30e,ax
		mov	ah,[si+5]
		mov	cs:data_31e,ax
		mov	ah,[si+0Eh]
		mov	cs:data_32e,ax
		call	extract_bitplane_pixels
		mov	es:[bp+8],dh
		mov	es:[bp+9],dl
		add	si,0Fh
		add	bp,2000h
		cmp	bp,8000h
		jb	loc_68			; Jump if below
		add	bp,80A0h
loc_68:
		pop	cx
		loop	locloop_69		; Loop if cx > 0

		jmp	short loc_70

locloop_69:
		jmp	loc_67
loc_70:
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
		mov	si,27E7h
		or	al,al			; Zero ?
		jz	loc_71			; Jump if zero
		mov	ds,cs:data_40e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_5e
		mov	si,ax
loc_71:
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,27E7h
		or	al,al			; Zero ?
		jz	loc_72			; Jump if zero
		mov	ds,cs:data_40e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_4e
		mov	si,ax
loc_72:
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
		add	bh,bh
		call	bitplane_to_pixels
		inc	ax
		mov	bp,ax
		mov	ax,0B800h
		mov	es,ax
		mov	cx,10h

locloop_73:
		push	cx
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_30e,ax
		mov	ax,[si+6]
		mov	cs:data_31e,ax
		mov	ax,[si+8]
		xchg	ah,al
		mov	cs:data_32e,ax
		call	extract_bitplane_pixels
		mov	es:[bp],dh
		mov	es:[bp+1],dl
		call	extract_bitplane_pixels
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		mov	ax,[si+2]
		xchg	ah,al
		mov	cs:data_30e,ax
		mov	ax,[si+4]
		mov	cs:data_31e,ax
		mov	ax,[si+0Ah]
		xchg	ah,al
		mov	cs:data_32e,ax
		call	extract_bitplane_pixels
		mov	es:[bp+4],dh
		mov	es:[bp+5],dl
		call	extract_bitplane_pixels
		mov	es:[bp+6],dh
		mov	es:[bp+7],dl
		add	si,0Ch
		add	bp,2000h
		cmp	bp,8000h
		jb	loc_74			; Jump if below
		add	bp,80A0h
loc_74:
		pop	cx
		loop	locloop_73		; Loop if cx > 0

		retn
render_tilemap_small		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

extract_bitplane_pixels		proc	near
		mov	cx,4

locloop_75:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_32e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_31e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_30e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_32e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_31e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_30e,1	; Rotate
		adc	bx,bx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		or	dl,cs:data_22e[bx]
		loop	locloop_75		; Loop if cx > 0

		retn
extract_bitplane_pixels		endp

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
		mov	ah,ds:data_21e[bx]
		mov	ds:data_25e,ah
		pop	bx
		xor	ah,ah			; Zero register
		sub	al,20h			; ' '
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:data_36e
		push	ax
		mov	al,bl
		and	al,1
		mov	ds:data_26e,al
		shr	bx,1			; Shift w/zeros fill
		mov	bh,bl
		mov	bl,cl
		call	bitplane_to_pixels
		mov	di,ax
		pop	si
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

locloop_76:
		push	cx
		push	di
		lodsb				; String [si] to al
		push	ax
		mov	cl,cs:data_26e
		shr	al,cl			; Shift w/zeros fill
		call	extract_bitplane_bit
		not	ah
		and	es:[di],ah
		not	ah
		and	ah,cs:data_25e
		or	es:[di],ah
		pop	ax
		mov	cl,2
		sub	cl,cs:data_26e
		shl	al,cl			; Shift w/zeros fill
		inc	di
		mov	cx,3

locloop_77:
		call	extract_bitplane_bit
		not	ah
		and	es:[di],ah
		not	ah
		and	ah,cs:data_25e
		or	es:[di],ah
		inc	di
		loop	locloop_77		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_78			; Jump if below
		add	di,80A0h
loc_78:
		pop	cx
		loop	locloop_76		; Loop if cx > 0

		pop	ds
		retn
render_text_char_alt		endp

			                        ;* No entry point to code
		push	ds
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	si,di
		add	si,2000h
		cmp	si,8000h
		jb	loc_79			; Jump if below
		add	si,data_44e
loc_79:
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_80:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_81			; Jump if below
		add	di,data_42e
loc_81:
		add	si,2000h
		cmp	si,8000h
		jb	loc_82			; Jump if below
		add	si,data_44e
loc_82:
		pop	cx
		loop	locloop_80		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		add	di,0
		mov	dh,al
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	bl,ah
		mov	bh,0A0h
		mul	bh			; ax = reg * al
		add	dx,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	dx,bx
		mov	si,dx
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,0B800h
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ch,bh

locloop_83:
		push	cx
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,8000h
		jb	loc_84			; Jump if below
		add	si,data_42e
loc_84:
		pop	cx
		loop	locloop_83		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,di
		add	si,0
		mov	dh,al
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	bl,ah
		mov	bh,0A0h
		mul	bh			; ax = reg * al
		add	dx,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	dx,bx
		mov	di,dx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ch,bh

locloop_85:
		push	cx
		push	di
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_86			; Jump if below
		add	di,80A0h
loc_86:
		pop	cx
		loop	locloop_85		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	cs:data_28e,bx
		mov	cs:data_29e,cl
		mov	byte ptr cs:data_27e,1
loc_87:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_88			; Jump if not equal
		retn
loc_88:
		cmp	al,0Dh
		je	loc_89			; Jump if equal
		or	al,al			; Zero ?
		js	loc_90			; Jump if sign=1
		push	cx
		push	bx
		push	si
		mov	ah,cs:data_27e
		call	render_text_char_alt
		pop	si
		pop	bx
		pop	cx
		add	bx,8
		jmp	short loc_87
loc_89:
		add	byte ptr cs:data_29e,8
		mov	cl,cs:data_29e
		mov	bx,cs:data_28e
		jmp	short loc_87
loc_90:
		mov	cs:data_27e,al
		jmp	short loc_87
			                        ;* No entry point to code
		push	ds
		push	dx
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	si,ax
		pop	bx
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_91:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_92			; Jump if below
		add	di,80A0h
loc_92:
		add	si,2000h
		cmp	si,8000h
		jb	loc_93			; Jump if below
		add	si,80A0h
loc_93:
		pop	cx
		loop	locloop_91		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	al,ds:data_21e[bx]
		sub	al,88h
		mov	ds:data_25e,al
		pop	bx
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		call	fill_rectangle
		mov	cx,10h

locloop_94:
		mov	al,ds:data_25e
		mov	es:[di],al
		mov	es:[di+9],al
		add	di,2000h
		cmp	di,8000h
		jb	loc_95			; Jump if below
		add	di,data_33e
loc_95:
		loop	locloop_94		; Loop if cx > 0

		call	fill_rectangle
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_rectangle		proc	near
		mov	cx,2

locloop_96:
		push	cx
		push	di
		mov	al,ds:data_25e
		mov	cx,0Ah
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_97			; Jump if below
		add	di,80A0h
loc_97:
		pop	cx
		loop	locloop_96		; Loop if cx > 0

		retn
fill_rectangle		endp

			                        ;* No entry point to code
		push	ds
		push	si
		push	cs
		pop	ds
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bx,ds:data_23e[si]
		mov	si,ds:data_24e[si]
		mov	cx,0Dh

locloop_98:
		push	cx
		push	di
		mov	dx,[bx]
		inc	bx
		inc	bx
		xchg	dh,dl
		mov	cx,8

locloop_99:
		add	dx,dx
		sbb	al,al
		and	al,0F0h
		add	dx,dx
		sbb	ah,ah
		and	ah,0Fh
		or	al,ah
		and	es:[di],al
		lodsb				; String [si] to al
		or	es:[di],al
		inc	di
		loop	locloop_99		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_100			; Jump if below
		add	di,80A0h
loc_100:
		pop	cx
		loop	locloop_98		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		mov	di,0F32Ch
		sub	al,0D9h
		sub	al,5Bh			; '['
		sub	ax,2FFCh
;*                         lock	pop	cs			; Dangerous-8088 only
		db	0F0h, 0Fh		;  Fixup - byte match
;*                         lock	pop	cs			; Dangerous-8088 only
		db	0F0h, 0Fh		;  Fixup - byte match
;*                         lock	pop	cs			; Dangerous-8088 only
		db	0F0h, 0Fh		;  Fixup - byte match
                           lock	pop	es
                           lock	pop	es
                           lock	pop	es
;*                         lock	pop	cs			; Dangerous-8088 only
		db	0F0h, 0Fh		;  Fixup - byte match
;*                         lock	pop	cs			; Dangerous-8088 only
		db	0F0h, 0Fh		;  Fixup - byte match
;*                         lock	pop	cs			; Dangerous-8088 only
		db	0F0h, 0Fh		;  Fixup - byte match
		db	0F2h, 2Fh,0FFh,0FFh,0FFh,0FFh
		db	0F0h, 0Fh,0E0h, 07h,0C0h, 03h
		db	0C0h, 03h, 80h, 01h, 80h, 01h
		db	 80h, 01h, 80h, 01h,0C0h, 03h
		db	0C0h, 03h,0E0h, 07h,0F0h, 0Fh
		db	0F8h, 1Fh
		db	11 dup (0)
		db	0DDh,0DCh, 00h, 00h, 00h, 00h
		db	 00h, 07h,0DFh,0F7h,0C0h, 00h
		db	 00h, 00h, 00h, 0Dh,0FFh,0F1h
		db	 54h, 00h, 00h, 00h, 00h, 75h
		db	 7Fh, 31h, 14h, 00h, 00h, 00h
		db	 00h, 74h, 11h, 91h, 1Ch, 00h
		db	 00h, 00h, 00h, 45h, 11h, 11h
		db	 1Ch, 00h, 00h, 00h, 00h, 0Ch
		db	 19h, 91h, 54h, 00h, 00h, 00h
		db	 00h, 04h, 49h, 91h,0C0h, 00h
		db	 00h, 00h, 00h, 00h, 4Ch,0CCh
		db	29 dup (0)
		db	 07h,0FFh,0FAh, 20h, 00h, 00h
		db	 00h, 00h,0FFh, 00h, 00h, 2Ah
		db	 00h, 00h, 00h, 0Fh, 70h, 7Fh
		db	 70h, 02h, 20h, 00h, 00h, 7Fh
		db	 0Fh,0F7h, 00h, 70h, 22h, 00h
		db	 00h,0F7h, 7Fh,0F0h, 00h, 07h
		db	 22h, 00h, 00h,0F0h,0F7h, 00h
		db	 44h, 00h, 0Ah, 00h, 00h,0F0h
		db	 70h, 04h, 44h, 44h, 4Ah, 00h
loc_101:
;*		add	dl,dh
		db	 00h,0F2h		;  Fixup - byte match
		jz	loc_104			; Jump if zero
		int	3			; Debug breakpoint
;*		les	di,dword ptr [bp+si+0]	; Load seg:offset ptr
		db	0C4h, 7Ah, 00h		;  Fixup - byte match
		db	 00h, 7Ah, 47h, 4Ch,0CCh,0C4h
		db	0F7h, 00h, 00h, 0Ah, 24h,0D7h
		db	0CCh,0C7h,0F0h, 00h, 00h, 00h
		db	0A2h, 40h, 44h, 7Fh, 00h, 00h
		db	 00h, 00h, 02h, 72h, 27h, 20h
		db	 00h
		db	9 dup (0)
		db	0B8h, 00h,0B8h, 8Eh,0C0h, 33h
		db	0FFh,0B9h, 08h, 00h

locloop_102:
		push	cx
		push	di
		mov	cx,19h

locloop_103:
		push	cx
		push	di
		mov	cx,50h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
loc_104:
		pop	di
		add	di,140h
		pop	cx
		loop	locloop_103		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_105			; Jump if below
		add	di,80A0h
loc_105:
		pop	cx
		loop	locloop_102		; Loop if cx > 0

		retn
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

locloop_106:
		push	cx
		call	process_sprite_row
		pop	cx
		loop	locloop_106		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

process_sprite_row		proc	near
		mov	cx,8

locloop_107:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_30e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_31e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_32e,ax
		call	extract_bitplane_pixels
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	extract_bitplane_pixels
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		pop	cx
		loop	locloop_107		; Loop if cx > 0

		retn
process_sprite_row		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

bitplane_to_pixels		proc	near
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
bitplane_to_pixels		endp

		db	12 dup (0)

seg_a		ends



		end	start
