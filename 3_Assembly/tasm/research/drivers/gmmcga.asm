
PAGE  59,132

;==========================================================================
;
;  GMMCGA.BIN - MCGA/VGA 256-Color Graphics Driver (Mode 13h, 320x200)
;
;  Graphics primitives for VGA framebuffer at 0xA000:0000:
;  - Screen clear, pixel plot, line fill (horizontal/vertical)
;  - Rectangle fill
;  - Text character rendering (8x8 with color)
;  - Tilemap rendering (large 6x18 and small 8x16 tiles)
;  - 3-bitplane sprite decoding (3 bits per pixel, 8 colors)
;  - Time/BCD formatting utilities
;
;  VGA row stride: 320 bytes (0x140)
;
;  Code type: zero start
;  Created:   16-Feb-26
;  Passes:    9          Analysis Options on: none
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	12Ch
data_2e		equ	2658h			;*
data_3e		equ	0E200h			;*
data_4e		equ	0E202h			;*
data_5e		equ	0E206h			;*
data_6e		equ	0E20Ah			;*
data_7e		equ	0E20Ch			;*
data_32e	equ	2226h			;*
data_33e	equ	2434h			;*
data_34e	equ	2435h			;*
data_35e	equ	2437h			;*
data_36e	equ	24EAh			;*
data_37e	equ	2A5Dh			;*
data_38e	equ	2CBDh			;*
data_39e	equ	2CBEh			;*
data_40e	equ	2CBFh			;*
data_41e	equ	2CC0h			;*
data_42e	equ	2CC2h			;*
data_43e	equ	2CC3h			;*
data_44e	equ	2CC5h			;*
data_45e	equ	2CC7h			;*
data_46e	equ	9521h			;*
data_47e	equ	0F500h			;*
data_48e	equ	0F502h			;*
data_49e	equ	0F504h			;*
data_50e	equ	0FF01h			;*
data_51e	equ	0FF2Ch			;*
data_52e	equ	0FF77h			;*
data_53e	equ	0			;*
data_54e	equ	140h			;*
data_55e	equ	140h
data_56e	equ	11B0h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

gmmcga		proc	far

start:
		inc	si
		and	ds:data_46e,al
		and	[bx],sp
		and	dl,[bp+22h]
		xor	[bp+si],sp
		db	 60h, 22h,0BFh, 22h,0CDh, 22h
		db	 85h, 23h, 8Fh, 23h,0ACh, 23h
		db	0CCh, 23h,0F5h, 23h, 4Ch, 25h
		db	0E2h, 25h,0FCh, 25h,0E9h, 27h
		db	 57h, 28h, 9Ah, 28h,0D9h, 28h
		db	 1Ah, 29h, 6Fh, 29h,0C3h, 29h
		db	0A3h, 24h, 3Ah, 24h, 16h, 26h
		db	 37h, 26h,0DBh, 22h, 18h, 27h
		db	 30h, 27h, 1Ch, 2Ah, 30h, 21h
		db	 01h, 2Ch, 2Ah, 2Ch, 50h, 33h
		db	0C0h, 8Ah,0C7h, 8Ah,0FCh, 50h
		db	0B8h, 40h, 01h,0F7h,0E3h, 5Fh
		db	 03h,0FFh, 03h,0FFh, 03h,0F8h
		db	 58h, 0Ah,0C0h, 75h, 03h,0E9h
		db	 86h, 00h
loc_1:
		mov	dx,909h
		test	byte ptr cs:data_52e,0FFh
		jz	loc_2			; Jump if zero
		mov	dx,0FFFFh
loc_2:
		push	di
		sub	cl,4
		add	di,280h
		call	clear_screen
		pop	di
		xor	ax,ax			; Zero register
		xor	bx,bx			; Zero register
		call	fill_horizontal_line
		mov	ax,0FF00h
		mov	bx,0FFh
		call	fill_horizontal_line
		push	cx
		push	bx
		mov	bl,ch
		dec	bl
		add	bx,bx
		add	bx,bx
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

locloop_3:
		mov	es:[di],dx
		mov	es:[bx+di+2],dx
		add	di,data_55e
		loop	locloop_3		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0FF00h
		mov	bx,0FFh
		call	fill_horizontal_line
		xor	ax,ax			; Zero register
		xor	bx,bx			; Zero register

gmmcga		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_horizontal_line		proc	near
		push	di
		push	cx
		not	ax
		and	es:[di],ax
		not	ax
		and	ax,dx
		or	es:[di],ax
		inc	di
		inc	di
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		sub	cx,4
		mov	al,dl
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		not	bx
		and	es:[di],bx
		not	bx
		and	bx,dx
		or	es:[di],bx
		pop	cx
		pop	di
		add	di,140h
		retn
fill_horizontal_line		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

clear_screen		proc	near
loc_4:
		mov	ax,0A000h
		mov	es,ax
		push	cx
		xor	ax,ax			; Zero register
loc_5:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	cx
		pop	di
		add	di,140h
		dec	cl
		jnz	loc_5			; Jump if not zero
		pop	cx
		retn
clear_screen		endp

			                        ;* No entry point to code
		mov	ax,0A000h
		mov	es,ax
		mov	di,data_56e
		mov	cx,8

locloop_6:
		push	cx
		push	di
		mov	cx,12h

locloop_7:
		push	cx
		push	di
		mov	cx,0E0h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,0A00h
		pop	cx
		loop	locloop_7		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_6		; Loop if cx > 0

		retn
data_16		db	0B8h
		db	 00h,0A0h, 8Eh,0C0h
		db	0BEh, 8Dh, 21h,0B9h, 08h, 00h

locloop_8:
		push	cx
		mov	di,11B0h
		lodsb				; String [si] to al
		push	di
		mov	cx,48h

locloop_9:
		push	cx
		mov	cx,0E0h

locloop_10:
		rol	al,1			; Rotate
		jnc	loc_11			; Jump if carry=0
		mov	byte ptr es:[di],0
loc_11:
		inc	di
		loop	locloop_10		; Loop if cx > 0

		ror	al,1			; Rotate
		ror	al,1			; Rotate
		ror	al,1			; Rotate
		pop	cx
		add	di,1A0h
		loop	locloop_9		; Loop if cx > 0

		pop	di
		add	di,140h
		mov	cx,48h

locloop_12:
		push	cx
		mov	cx,0E0h

locloop_13:
		ror	al,1			; Rotate
		jnc	loc_14			; Jump if carry=0
		mov	byte ptr es:[di],0
loc_14:
		inc	di
		loop	locloop_13		; Loop if cx > 0

		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		pop	cx
		add	di,1A0h
		loop	locloop_12		; Loop if cx > 0

		mov	cx,1F40h

locloop_15:
		loop	locloop_15		; Loop if cx > 0

		pop	cx
		loop	locloop_8		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		add	[bp+di],ax
		pop	es
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		pop	ds
		aas				; Ascii adjust
		db	 7Fh,0FFh
loc_16:
		mov	cs:data_32e,al
		mov	ax,0A000h
		mov	es,ax
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		add	bx,9Eh
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	bx
		add	ax,bx
		add	ax,30h
		mov	di,ax
		push	cx
		xor	ax,ax			; Zero register
		call	plot_pixel
		pop	cx
		inc	di
		mov	cl,ch
loc_17:
		push	cx
		mov	ax,0FFFFh
		call	plot_pixel
		pop	cx
		inc	di
		dec	cl
		jnz	loc_17			; Jump if not zero
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

plot_pixel		proc	near
		test	byte ptr cs:data_32e,0FFh
		jnz	loc_19			; Jump if not zero
		push	di
		and	ah,5
		and	al,2Dh			; '-'
		mov	byte ptr es:[di],0
		add	di,data_55e
		mov	cx,8

locloop_18:
		mov	es:[di],ah
		add	di,data_55e
		loop	locloop_18		; Loop if cx > 0

		mov	es:[di],al
		pop	di
		retn
loc_19:
		cmp	byte ptr cs:data_32e,80h
		je	loc_21			; Jump if equal
		push	di
		mov	ah,al
		not	ah
		and	al,1
		mov	cx,0Ah

locloop_20:
		and	es:[di],ah
		or	es:[di],al
		add	di,data_55e
		loop	locloop_20		; Loop if cx > 0

		pop	di
		retn
loc_21:
		push	di
		not	al
		mov	cx,0Ah

locloop_22:
		and	es:[di],al
		add	di,140h
		loop	locloop_22		; Loop if cx > 0

		pop	di
		retn
plot_pixel		endp

		db	 00h,0BFh, 14h,0CCh, 2Eh, 8Bh
		db	 1Eh,0B2h, 00h,0EBh, 05h,0BFh
		db	 14h,0DBh,0EBh, 00h,0B8h, 00h
		db	0A0h, 8Eh,0C0h,0E8h, 60h, 00h
		db	 8Bh,0CBh, 0Bh,0C9h, 75h, 01h
		db	0C3h

locloop_23:
		push	cx
		push	di
		mov	bh,6
		mov	al,12h
		mov	ah,2Dh			; '-'
		call	fill_vertical_line
		pop	di
		inc	di
		pop	cx
		loop	locloop_23		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	di,0CC14h
		mov	bx,word ptr cs:[90h]
		jmp	short loc_24
		db	0BFh, 14h,0DBh,0EBh, 00h
loc_24:
		mov	ax,0A000h
		mov	es,ax
		call	calc_text_width
		push	bx
		mov	cx,bx
		or	cx,cx			; Zero ?
		jz	loc_26			; Jump if zero

locloop_25:
		push	cx
		push	di
		mov	bh,5
		mov	al,9
		mov	ah,12h
		call	fill_vertical_line
		pop	di
		inc	di
		pop	cx
		loop	locloop_25		; Loop if cx > 0

loc_26:
		pop	bx
		mov	cx,64h
		sub	cx,bx
		jnz	locloop_27		; Jump if not zero
		retn

locloop_27:
		push	cx
		push	di
		mov	bh,5
		xor	al,al			; Zero register
		mov	ah,12h
		call	fill_vertical_line
		pop	di
		inc	di
		pop	cx
		loop	locloop_27		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	loc_28			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		retn
loc_28:
		mov	bx,64h
		retn
calc_text_width		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_vertical_line		proc	near
loc_29:
		and	es:[di],ah
		or	es:[di],al
		add	di,140h
		dec	bh
		jnz	loc_29			; Jump if not zero
		retn
fill_vertical_line		endp

			                        ;* No entry point to code
		mov	byte ptr cs:data_38e,1Bh
		mov	byte ptr cs:data_39e,12h
		jmp	short loc_32
			                        ;* No entry point to code
		mov	byte ptr cs:data_38e,9
		mov	byte ptr cs:data_39e,2Dh	; '-'
		jmp	short loc_32
			                        ;* No entry point to code
		mov	byte ptr cs:data_38e,9
		mov	byte ptr cs:data_39e,0
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
		xor	ch,ch			; Zero register
		add	di,cx
		mov	ax,0A000h
		mov	es,ax
loc_30:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_31			; Jump if not zero
		retn
loc_31:
		push	ds
		push	si
		call	render_text_char
		pop	si
		pop	ds
		jmp	short loc_30
loc_32:
		lodsb				; String [si] to al
		mov	dl,al
		xor	dh,dh			; Zero register
		push	dx
		lodsb				; String [si] to al
		xor	ah,ah			; Zero register
		mov	bx,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		lodsb				; String [si] to al
		xor	ah,ah			; Zero register
		mov	bl,al
		add	di,ax
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		mov	ax,0A000h
		mov	es,ax

locloop_33:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		call	render_text_char
		pop	si
		pop	ds
		pop	cx
		loop	locloop_33		; Loop if cx > 0

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
		add	si,ds:data_49e
		push	di
		mov	bl,8
loc_34:
		push	bx
		lodsb				; String [si] to al
		push	di
		mov	dh,al
		mov	dl,4
loc_35:
		add	dh,dh
		jnc	loc_36			; Jump if carry=0
		mov	al,ds:data_39e
		mov	es:[di+1],al
		mov	ah,ds:data_38e
		mov	es:[di],ah
loc_36:
		inc	di
		dec	dl
		jnz	loc_35			; Jump if not zero
		pop	di
		add	di,140h
		pop	bx
		dec	bl
		jnz	loc_34			; Jump if not zero
		pop	di
		add	di,5
		retn
render_text_char		endp

			                        ;* No entry point to code
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,88h
		jmp	loc_16
			                        ;* No entry point to code
		push	ds
		mov	ax,word ptr cs:[8Bh]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,data_34e
		mov	cx,105h
		mov	ax,26BBh
		mov	bx,data_50e
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
		mov	di,data_33e
		mov	cx,106h
		mov	ax,13BBh
		mov	bx,data_50e
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
		mov	di,data_35e
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,data_50e
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		test	byte ptr cs:[93h],0FFh
		jnz	loc_37			; Jump if not zero
		retn
loc_37:
		push	ds
		mov	ax,word ptr cs:[94h]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,data_35e
		mov	cx,103h
		mov	ax,3EBBh
		mov	bx,data_50e
		call	render_tilemap_large
		pop	ds
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

init_timestamp		proc	near
		mov	di,2433h
		call	time_to_bcd
		mov	cx,6

locloop_38:
		test	byte ptr cs:[di],0FFh
		jz	loc_39			; Jump if zero
		retn
loc_39:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	locloop_38		; Loop if cx > 0

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
loc_40:
		sub	dl,cl
		jc	loc_43			; Jump if carry Set
		sub	ax,bx
		jnc	loc_41			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_42			; Jump if zero
		dec	dl
loc_41:
		inc	dh
		jmp	short loc_40
loc_42:
		add	ax,bx
loc_43:
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
		mov	ds:data_39e,bh
		xor	bh,bh			; Zero register
		mov	dl,ds:data_36e[bx]
		mov	ds:data_38e,dl
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,bh
		push	bx
		mov	bx,140h
		mul	bx			; dx:ax = reg * ax
		pop	bx
		add	bx,bx
		add	bx,bx
		add	bx,ax
		shr	ch,1			; Shift w/zeros fill
		sbb	ax,ax
		and	ax,2
		add	bx,ax
		mov	ax,0A000h
		mov	es,ax
loc_44:
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
		add	bx,6
		dec	cl
		jnz	loc_44			; Jump if not zero
		retn
render_tilemap_large		endp

		db	 00h, 09h, 12h
		db	 1Bh, 24h, 2Dh, 36h, 3Fh

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decode_bitplane_tile		proc	near
		test	byte ptr ds:data_39e,0FFh
		jz	loc_46			; Jump if zero
		push	ax
		push	di
		mov	ax,505h
		mov	cx,7

locloop_45:
		push	cx
		push	di
		mov	cx,3
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		add	di,data_55e
		pop	cx
		loop	locloop_45		; Loop if cx > 0

		pop	di
		pop	ax
loc_46:
		inc	al
		jnz	loc_47			; Jump if not zero
		retn
loc_47:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:data_48e
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,7

locloop_48:
		lodsb				; String [si] to al
		add	al,al
		add	al,al
		mov	ah,6
loc_49:
		add	al,al
		jnc	loc_50			; Jump if carry=0
		mov	bl,cs:data_38e
		mov	es:[di],bl
loc_50:
		inc	di
		dec	ah
		jnz	loc_49			; Jump if not zero
		add	di,13Ah
		loop	locloop_48		; Loop if cx > 0

		retn
decode_bitplane_tile		endp

			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_51e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,10Eh
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_3e
		mov	si,ax
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	bp
		add	bp,bp
		add	bp,bp
		add	bp,bp
		add	bp,ax
		mov	ax,0A000h
		mov	es,ax
		mov	cx,12h

locloop_51:
		push	cx
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_43e,ax
		mov	ax,[si+8]
		mov	cs:data_44e,ax
		mov	ax,[si+0Ah]
		xchg	ah,al
		mov	cs:data_45e,ax
		call	extract_bitplane_pixels
		call	extract_bitplane_pixels
		mov	ax,[si+2]
		xchg	ah,al
		mov	cs:data_43e,ax
		mov	ax,[si+6]
		mov	cs:data_44e,ax
		mov	ax,[si+0Ch]
		xchg	ah,al
		mov	cs:data_45e,ax
		call	extract_bitplane_pixels
		call	extract_bitplane_pixels
		xor	al,al			; Zero register
		mov	ah,[si+4]
		mov	cs:data_43e,ax
		mov	ah,[si+5]
		mov	cs:data_44e,ax
		mov	ah,[si+0Eh]
		mov	cs:data_45e,ax
		call	extract_bitplane_pixels
		add	si,0Fh
		add	bp,data_1e
		pop	cx
		loop	locloop_51		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_51e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_5e
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_51e
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
		mov	si,data_2e
		or	al,al			; Zero ?
		jz	loc_52			; Jump if zero
		mov	ds,cs:data_51e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_7e
		mov	si,ax
loc_52:
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,data_2e
		or	al,al			; Zero ?
		jz	loc_53			; Jump if zero
		mov	ds,cs:data_51e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_6e
		mov	si,ax
loc_53:
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
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	bp
		add	bp,bp
		add	bp,bp
		add	bp,2
		add	bp,ax
		mov	ax,0A000h
		mov	es,ax
		mov	cx,10h

locloop_54:
		push	cx
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_43e,ax
		mov	ax,[si+6]
		mov	cs:data_44e,ax
		mov	ax,[si+8]
		xchg	ah,al
		mov	cs:data_45e,ax
		call	extract_bitplane_pixels
		call	extract_bitplane_pixels
		mov	dx,[si+2]
		xchg	dh,dl
		mov	cs:data_43e,dx
		mov	dx,[si+4]
		mov	cs:data_44e,dx
		mov	dx,[si+0Ah]
		xchg	dh,dl
		mov	cs:data_45e,dx
		call	extract_bitplane_pixels
		call	extract_bitplane_pixels
		add	si,0Ch
		add	bp,130h
		pop	cx
		loop	locloop_54		; Loop if cx > 0

		retn
render_tilemap_small		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

extract_bitplane_pixels		proc	near
		mov	cx,4

locloop_55:
		xor	ax,ax			; Zero register
		rol	word ptr cs:data_45e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_44e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_43e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_45e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_44e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_43e,1	; Rotate
		adc	ax,ax
		mov	es:[bp],al
		inc	bp
		loop	locloop_55		; Loop if cx > 0

		retn
extract_bitplane_pixels		endp


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
		mov	ah,ds:data_36e[bx]
		test	byte ptr cs:data_52e,0FFh
		jz	loc_56			; Jump if zero
		mov	ah,bl
		add	ah,ah
		add	ah,ah
		add	ah,ah
		add	ah,ah
		or	ah,bl
loc_56:
		mov	ds:data_38e,ah
		pop	bx
		xor	ah,ah			; Zero register
		sub	al,20h			; ' '
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:data_47e
		push	ax
		mov	al,bl
		and	al,3
		add	al,al
		mov	ds:data_39e,al
		mov	ax,140h
		xor	ch,ch			; Zero register
		mul	cx			; dx:ax = reg * ax
		add	ax,bx
		mov	di,ax
		pop	si
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

locloop_57:
		push	cx
		lodsb				; String [si] to al
		mov	cx,8

locloop_58:
		add	al,al
		jnc	loc_59			; Jump if carry=0
		mov	dl,cs:data_38e
		mov	es:[di],dl
loc_59:
		inc	di
		loop	locloop_58		; Loop if cx > 0

		pop	cx
		add	di,138h
		loop	locloop_57		; Loop if cx > 0

		pop	ds
		retn
render_text_char_alt		endp

			                        ;* No entry point to code
		push	ds
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
		mov	si,di
		add	si,data_55e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_60:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,data_54e
		add	si,data_55e
		pop	cx
		loop	locloop_60		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		add	di,0
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,bh
		push	bx
		mov	bx,140h
		mul	bx			; dx:ax = reg * ax
		pop	si
		add	si,si
		add	si,si
		add	si,si
		add	si,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,0A000h
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh
		add	bx,bx
		add	bx,bx

locloop_61:
		push	cx
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,data_54e
		pop	cx
		loop	locloop_61		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,di
		add	si,0
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,bh
		push	bx
		mov	bx,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,di
		add	di,ax
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	ax,0A000h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh
		add	bx,bx
		add	bx,bx

locloop_62:
		push	cx
		push	di
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		add	di,140h
		pop	cx
		loop	locloop_62		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	cs:data_41e,bx
		mov	cs:data_42e,cl
		mov	al,1
		test	byte ptr cs:data_52e,0FFh
		jz	loc_63			; Jump if zero
		mov	al,7
loc_63:
		mov	cs:data_40e,al
loc_64:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_65			; Jump if not equal
		retn
loc_65:
		cmp	al,0Dh
		je	loc_66			; Jump if equal
		or	al,al			; Zero ?
		js	loc_67			; Jump if sign=1
		push	cx
		push	bx
		push	si
		mov	ah,cs:data_40e
		call	render_text_char_alt
		pop	si
		pop	bx
		pop	cx
		add	bx,8
		jmp	short loc_64
loc_66:
		add	byte ptr cs:data_42e,8
		mov	cl,cs:data_42e
		mov	bx,cs:data_41e
		jmp	short loc_64
loc_67:
		and	al,7
		mov	cs:data_40e,al
		jmp	short loc_64
			                        ;* No entry point to code
		push	ds
		push	dx
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	si
		add	si,si
		add	si,si
		add	si,si
		add	si,ax
		pop	bx
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
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_68:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,140h
		add	si,140h
		pop	cx
		loop	locloop_68		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	al,ds:data_36e[bx]
		mov	ds:data_38e,al
		pop	bx
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
		call	fill_rectangle
		mov	al,ds:data_38e
		mov	cx,10h

locloop_69:
		mov	es:[di],al
		mov	es:[di+1],al
		mov	es:[di+12h],al
		mov	es:[di+13h],al
		add	di,data_55e
		loop	locloop_69		; Loop if cx > 0


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_rectangle		proc	near
		mov	cx,2

locloop_70:
		push	cx
		push	di
		mov	al,ds:data_38e
		mov	cx,14h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,140h
		pop	cx
		loop	locloop_70		; Loop if cx > 0

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
		mov	si,ds:data_37e[si]
		mov	cx,0Dh

locloop_71:
		push	cx
		mov	cx,10h

locloop_72:
		lodsb				; String [si] to al
		cmp	al,80h
		je	loc_73			; Jump if equal
		stosb				; Store al to es:[di]
		dec	di
loc_73:
		inc	di
		loop	locloop_72		; Loop if cx > 0

		pop	cx
		add	di,offset data_16
		loop	locloop_71		; Loop if cx > 0

		pop	si
		pop	ds
		retn
		db	 61h, 2Ah, 31h, 2Bh, 80h, 80h
		db	 80h, 80h, 80h, 80h, 00h, 00h
		db	 00h, 00h, 80h, 00h, 80h
		db	7 dup (80h)
		db	 00h, 00h, 11h, 11h, 11h, 12h
		db	 00h, 00h
		db	8 dup (80h)
		db	 00h, 11h, 11h, 09h, 09h, 01h
		db	 12h, 00h
		db	8 dup (80h)
		db	 00h, 11h, 09h, 09h, 09h, 28h
		db	 2Ah, 10h
		db	8 dup (80h)
		db	 11h, 15h, 01h, 09h, 0Dh, 05h
		db	 05h, 12h, 00h
		db	7 dup (80h)
		db	 11h, 10h, 28h, 28h, 2Dh, 28h
		db	 28h, 12h, 00h
		db	7 dup (80h)
		db	 12h, 15h, 05h, 05h, 05h, 05h
		db	 05h, 12h, 00h, 80h, 80h, 80h
		db	 80h, 80h, 80h, 80h, 00h, 12h
		db	 05h, 2Dh, 2Dh, 05h, 15h, 02h
		db	 80h
		db	7 dup (80h)
		db	 00h, 02h, 02h, 2Dh, 2Dh, 05h
		db	 12h, 00h, 80h, 80h, 80h, 80h
		db	 80h, 80h, 80h, 80h, 00h, 00h
		db	 02h, 12h, 12h, 12h, 00h, 00h
		db	8 dup (80h)
		db	 00h, 00h, 80h, 00h, 00h, 00h
		db	 80h, 00h, 80h
		db	39 dup (80h)
		db	 00h, 01h, 09h, 09h, 09h, 1Bh
		db	 03h, 00h
		db	7 dup (80h)
		db	 00h, 09h, 09h, 00h, 00h, 00h
		db	 00h, 03h, 1Bh, 00h, 80h, 80h
		db	 80h, 80h, 80h, 00h, 09h, 01h
		db	 00h, 01h, 09h, 01h, 00h, 00h
		db	 03h, 03h, 00h, 80h, 80h, 80h
		db	 80h, 01h, 09h, 00h, 09h, 09h
		db	 01h, 00h, 00h, 01h, 00h, 03h
		db	 03h, 80h, 80h, 80h, 00h, 09h
		db	 01h, 01h, 09h, 09h, 00h, 00h
		db	 00h, 00h, 01h, 03h, 03h, 00h
		db	 80h, 80h, 00h, 09h, 00h, 09h
		db	 01h, 00h, 00h, 02h, 02h, 00h
		db	 00h, 00h, 0Bh, 00h, 80h, 80h
		db	 00h, 09h, 00h, 01h, 00h, 00h
		db	 02h, 02h, 02h, 02h, 02h, 02h
		db	 0Bh, 00h, 80h, 80h, 00h, 09h
		db	 03h, 01h, 02h, 02h, 02h, 12h
		db	 12h, 12h, 02h, 01h, 0Bh, 00h
		db	 80h, 80h, 80h, 01h, 1Bh, 02h
		db	 01h, 02h, 12h, 12h, 12h, 12h
		db	 02h, 09h, 01h, 80h, 80h, 80h
		db	 80h, 00h, 0Bh, 03h, 02h, 0Ah
		db	 01h, 12h, 12h, 12h, 01h, 09h
		db	 00h, 80h, 80h, 80h, 80h, 80h
		db	 00h, 1Bh, 03h, 02h, 00h, 02h
		db	 02h, 01h, 09h, 00h, 80h, 80h
		db	 80h, 80h, 80h, 80h, 80h, 00h
		db	 03h, 01h, 03h, 03h, 01h, 03h
		db	 00h, 80h, 80h, 80h, 80h, 80h
		db	 80h, 80h, 80h, 80h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 80h, 80h
		db	 80h, 80h, 80h,0B8h, 00h,0A0h
		db	 8Eh,0C0h, 33h,0FFh,0B9h, 08h
		db	 00h

locloop_74:
		push	cx
		push	di
		mov	cx,19h

locloop_75:
		push	cx
		push	di
		mov	cx,0A0h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		add	di,0A00h
		pop	cx
		loop	locloop_75		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_74		; Loop if cx > 0

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
		mov	di,data_53e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,data_53e

locloop_76:
		push	cx
		call	process_sprite_row
		pop	cx
		loop	locloop_76		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

process_sprite_row		proc	near
		mov	cx,8

locloop_77:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_43e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_44e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_45e,ax
		call	bitplane_to_pixels
		pop	cx
		loop	locloop_77		; Loop if cx > 0

		retn
process_sprite_row		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

bitplane_to_pixels		proc	near
		mov	cx,2

locloop_78:
		call	extract_bitplane_bit
		call	extract_bitplane_bit
		call	extract_bitplane_bit
		call	extract_bitplane_bit
		call	extract_bitplane_bit
		rol	word ptr cs:data_45e,1	; Rotate
		adc	ax,ax
		stosw				; Store ax to es:[di]
		rol	word ptr cs:data_44e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_43e,1	; Rotate
		adc	ax,ax
		call	extract_bitplane_bit
		call	extract_bitplane_bit
		stosb				; Store al to es:[di]
		loop	locloop_78		; Loop if cx > 0

		retn
bitplane_to_pixels		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

extract_bitplane_bit		proc	near
		rol	word ptr cs:data_45e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_44e,1	; Rotate
		adc	ax,ax
		rol	word ptr cs:data_43e,1	; Rotate
		adc	ax,ax
		retn
extract_bitplane_bit		endp

		db	12 dup (0)

seg_a		ends



		end	start
