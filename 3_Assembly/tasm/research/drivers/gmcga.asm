
PAGE  59,132

;==========================================================================
;
;  GMCGA.BIN - CGA 4-Color Graphics Driver (Mode 5, 320x200)
;
;  CGA variant of the graphics driver API. Same functions as MCGA
;  but adapted for CGA's 4-color palette and interleaved memory layout.
;  CGA video memory at 0xB800, odd/even scanline interleaving.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	2751h			;*
data_2e		equ	0E200h			;*
data_3e		equ	0E202h			;*
data_4e		equ	0E206h			;*
data_5e		equ	0E20Ah			;*
data_6e		equ	0E20Ch			;*
data_19e	equ	217Fh			;*
data_20e	equ	225Ch			;*
data_21e	equ	24E9h			;*
data_22e	equ	24EAh			;*
data_23e	equ	24ECh			;*
data_24e	equ	259Ah			;*
data_25e	equ	290Bh			;*
data_26e	equ	2C11h			;*
data_27e	equ	2DE1h			;*
data_28e	equ	2DE2h			;*
data_29e	equ	2DE3h			;*
data_30e	equ	2DE4h			;*
data_31e	equ	2DE6h			;*
data_32e	equ	2DE7h			;*
data_33e	equ	2DE9h			;*
data_34e	equ	2DEBh			;*
data_35e	equ	2E22h			;*
data_36e	equ	5D21h			;*
data_37e	equ	6722h			;*
data_38e	equ	0C050h			;*
data_39e	equ	0F500h			;*
data_40e	equ	0F502h			;*
data_41e	equ	0F504h			;*
data_42e	equ	0FF01h			;*
data_43e	equ	0FF2Ch			;*
data_44e	equ	0			;*
data_45e	equ	0C050h			;*
data_46e	equ	23Ch
data_47e	equ	18BCh
data_48e	equ	0C050h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

gmcga		proc	far

start:
		inc	si
;*		and	al,dh
		db	 20h,0F0h		;  Fixup - byte match
		and	ds:data_36e[bx],al
		and	dl,ds:data_37e[bx]
		and	ah,ds:data_35e[bx+di]
		and	di,[si]
		and	di,[bp+si]
		and	al,44h			; 'D'
		and	al,61h			; 'a'
		and	al,81h
		and	al,0AAh
		and	al,2Ch			; ','
		db	 26h,0DBh, 26h,0F5h, 26h, 4Bh
		db	 29h,0F5h, 29h, 56h, 2Ah, 9Ch
		db	 2Ah,0E4h, 2Ah, 2Fh, 2Bh, 97h
		db	 2Bh, 58h, 25h,0EFh, 24h, 0Fh
		db	 27h, 30h, 27h, 4Ah, 23h, 11h
		db	 28h, 29h, 28h, 19h, 2Ch, 24h
		db	 21h, 66h, 2Dh, 99h, 2Dh, 50h
		db	0D0h,0EBh, 1Bh,0FFh, 81h,0E7h
		db	 00h, 20h,0B0h, 50h,0F6h,0E3h
		db	 03h,0F8h, 8Ah,0DFh, 32h,0FFh
		db	 03h,0FBh, 58h, 0Ah,0C0h, 74h
		db	 6Ah, 57h, 80h,0E9h, 04h, 83h
		db	0C7h, 50h,0E8h, 60h, 00h, 5Fh
		db	0B8h, 0Fh,0F0h,0E8h, 33h, 00h
		db	0B8h, 3Fh,0FCh,0E8h, 2Dh, 00h
		db	 51h, 53h, 8Ah,0DDh,0FEh,0CBh
		db	 32h,0FFh, 32h,0EDh

locloop_1:
		mov	byte ptr es:[di],0F0h
		mov	byte ptr es:[bx+di],0Fh
		add	di,2000h
		cmp	di,4000h
		jb	loc_2			; Jump if below
		add	di,data_38e
loc_2:
		loop	locloop_1		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0FC3Fh
		call	fill_horizontal_line
		mov	ax,0F00Fh

gmcga		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_horizontal_line		proc	near
		push	di
		or	es:[di],al
		inc	di
		mov	bh,ch
		sub	bh,2
loc_3:
		or	byte ptr es:[di],0FFh
		inc	di
		dec	bh
		jnz	loc_3			; Jump if not zero
		or	es:[di],ah
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_ret_4		; Jump if below
		add	di,0C050h

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
		mov	ah,cl
loc_6:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_7			; Jump if below
		add	di,0C050h
loc_7:
		dec	ah
		jnz	loc_6			; Jump if not zero
		retn
clear_screen		endp

			                        ;* No entry point to code
		mov	ax,0B800h
		mov	es,ax
		mov	di,data_46e
		mov	cx,8

locloop_8:
		push	cx
		push	di
		mov	cx,12h

locloop_9:
		push	cx
		push	di
		mov	cx,38h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,140h
		pop	cx
		loop	locloop_9		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_10			; Jump if below
		add	di,0C050h
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
		mov	di,data_46e
		lodsb				; String [si] to al
		push	di
		mov	cx,48h

locloop_12:
		push	cx
		mov	cx,38h

locloop_13:
		and	es:[di],al
		inc	di
		loop	locloop_13		; Loop if cx > 0

		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		pop	cx
		add	di,18h
		loop	locloop_12		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_14			; Jump if below
		add	di,data_48e
loc_14:
		mov	cx,48h

locloop_15:
		push	cx
		mov	cx,38h

locloop_16:
		and	es:[di],al
		inc	di
		loop	locloop_16		; Loop if cx > 0

		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		pop	cx
		add	di,18h
		loop	locloop_15		; Loop if cx > 0

		mov	cx,3E80h

locloop_17:
		loop	locloop_17		; Loop if cx > 0

		pop	cx
		loop	locloop_11		; Loop if cx > 0

		retn
		db	0FEh,0EEh,0EAh,0AAh,0A8h, 88h
		db	 80h, 00h
loc_18:
		mov	cs:data_20e,al
		mov	ax,0B800h
		mov	es,ax
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		mov	ax,50h
		mul	bl			; ax = reg * al
		add	di,ax
		mov	dl,bh
		and	bh,3
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		xor	dh,dh			; Zero register
		add	di,dx
		add	di,data_47e
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
		jz	loc_20			; Jump if zero
loc_19:
		push	cx
		mov	ax,0FFFFh
		call	plot_pixel
		pop	cx
		inc	di
		dec	cl
		jnz	loc_19			; Jump if not zero
loc_20:
		and	ch,3
		jnz	loc_21			; Jump if not zero
		retn
loc_21:
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
		test	byte ptr cs:data_20e,0FFh
		jnz	loc_24			; Jump if not zero
		push	di
		not	ah
		mov	cx,9

locloop_22:
		and	es:[di],ah
		add	di,2000h
		cmp	di,4000h
		jb	loc_23			; Jump if below
		add	di,data_48e
loc_23:
		loop	locloop_22		; Loop if cx > 0

		and	es:[di],ah
		or	es:[di],al
		pop	di
		retn
loc_24:
		cmp	byte ptr cs:data_20e,80h
		je	loc_27			; Jump if equal
		push	di
		mov	ah,al
		not	ah
		and	al,55h			; 'U'
		mov	cx,0Ah

locloop_25:
		and	es:[di],ah
		or	es:[di],al
		add	di,2000h
		cmp	di,4000h
		jb	loc_26			; Jump if below
		add	di,data_48e
loc_26:
		loop	locloop_25		; Loop if cx > 0

		pop	di
		retn
loc_27:
		push	di
		not	al
		mov	cx,0Ah

locloop_28:
		and	es:[di],al
		add	di,2000h
		cmp	di,4000h
		jb	loc_29			; Jump if below
		add	di,0C050h
loc_29:
		loop	locloop_28		; Loop if cx > 0

		pop	di
		retn
plot_pixel		endp

		db	 00h,0BFh, 65h, 39h, 2Eh, 8Bh
		db	 1Eh,0B2h, 00h,0EBh, 05h,0BFh
		db	 45h, 3Bh,0EBh, 00h,0B8h, 00h
		db	0B8h, 8Eh,0C0h,0E8h, 7Eh, 00h
		db	50h
loc_30:
		or	bl,bl			; Zero ?
		jz	loc_31			; Jump if zero
		push	di
		mov	bh,6
		mov	al,0AAh
		mov	ah,55h			; 'U'
		call	fill_vertical_line
		dec	bl
		pop	di
		inc	di
		jmp	short loc_30
loc_31:
		pop	ax
		or	al,al			; Zero ?
		jnz	loc_32			; Jump if not zero
		retn
loc_32:
		and	al,0AAh
		mov	ah,55h			; 'U'
		mov	bh,6
		jmp	short loc_40
			                        ;* No entry point to code
		mov	di,3965h
		mov	bx,word ptr cs:[90h]
		jmp	short loc_33
		db	0BFh, 45h, 3Bh,0EBh, 00h
loc_33:
		mov	ax,0B800h
		mov	es,ax
		call	calc_text_width
		push	ax
		push	bx
loc_34:
		or	bl,bl			; Zero ?
		jz	loc_35			; Jump if zero
		push	di
		mov	bh,5
		mov	al,55h			; 'U'
		mov	ah,0AAh
		call	fill_vertical_line
		dec	bl
		pop	di
		inc	di
		jmp	short loc_34
loc_35:
		pop	bx
		pop	ax
		or	al,al			; Zero ?
		jz	loc_36			; Jump if zero
		push	di
		mov	bh,5
		and	al,55h			; 'U'
		mov	ah,0AAh
		call	fill_vertical_line
		pop	di
		inc	di
		inc	bl
loc_36:
		mov	bh,19h
		sub	bh,bl
		jnz	loc_37			; Jump if not zero
		retn
loc_37:
		mov	bl,bh
loc_38:
		push	di
		mov	bh,5
		xor	al,al			; Zero register
		mov	ah,0AAh
		call	fill_vertical_line
		pop	di
		inc	di
		dec	bl
		jnz	loc_38			; Jump if not zero
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	loc_39			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	cl,bl
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		and	cl,6
		mov	al,0FFh
		shr	al,cl			; Shift w/zeros fill
		not	al
		retn
loc_39:
		mov	bx,19h
		xor	al,al			; Zero register
		retn
calc_text_width		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_vertical_line		proc	near
loc_40:
		and	es:[di],ah
		or	es:[di],al
		add	di,2000h
		cmp	di,4000h
		jb	loc_41			; Jump if below
		add	di,0C050h
loc_41:
		dec	bh
		jnz	loc_40			; Jump if not zero
		retn
fill_vertical_line		endp

			                        ;* No entry point to code
		mov	byte ptr cs:data_27e,55h	; 'U'
		mov	byte ptr cs:data_28e,0AAh
		jmp	short loc_44
			                        ;* No entry point to code
		mov	byte ptr cs:data_27e,0FFh
		mov	byte ptr cs:data_28e,0
		jmp	short loc_44
			                        ;* No entry point to code
		mov	byte ptr cs:data_27e,0FFh
		mov	byte ptr cs:data_28e,0
		xor	dh,dh			; Zero register
		mov	dl,bh
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		add	di,dx
		mov	al,bl
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	di,ax
		mov	bl,cl
		mov	ax,0B800h
		mov	es,ax
loc_42:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_43			; Jump if not zero
		retn
loc_43:
		push	bx
		push	ds
		push	si
		and	bl,3
		call	render_text_char
		pop	si
		pop	ds
		pop	bx
		inc	bl
		jmp	short loc_42
loc_44:
		lodsb				; String [si] to al
		xor	dh,dh			; Zero register
		mov	dl,al
		lodsb				; String [si] to al
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		add	di,dx
		mov	cl,50h			; 'P'
		mul	cl			; ax = reg * al
		add	di,ax
		lodsb				; String [si] to al
		mov	bl,al
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		mov	ax,0B800h
		mov	es,ax

locloop_45:
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
		loop	locloop_45		; Loop if cx > 0

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
		add	si,ds:data_41e
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8
loc_46:
		push	bx
		lodsb				; String [si] to al
		mov	dl,4
loc_47:
		add	ax,ax
		add	ah,ah
		dec	dl
		jnz	loc_47			; Jump if not zero
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
		and	bh,ds:data_28e
		and	bl,ds:data_28e
		or	es:[di],bx
		pop	bx
		xchg	bh,bl
		not	bx
		and	es:[di],bx
		not	bx
		and	bh,ds:data_27e
		and	bl,ds:data_27e
		or	es:[di],bx
		add	di,2000h
		cmp	di,4000h
		jb	loc_48			; Jump if below
		add	di,0C050h
loc_48:
		pop	bx
		dec	bl
		jnz	loc_46			; Jump if not zero
		pop	di
		inc	di
		cmp	cl,6
		je	loc_49			; Jump if equal
		retn
loc_49:
		inc	di
		retn
render_text_char		endp

			                        ;* No entry point to code
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,88h
		jmp	loc_18
			                        ;* No entry point to code
		push	ds
		mov	ax,word ptr cs:[8Bh]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,data_22e
		mov	cx,105h
		mov	ax,26BBh
		mov	bx,data_42e
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
		mov	di,data_21e
		mov	cx,106h
		mov	ax,13BBh
		mov	bx,data_42e
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
		mov	di,data_23e
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,data_42e
		call	render_tilemap_large
		pop	ds
		retn
			                        ;* No entry point to code
		test	byte ptr cs:[93h],0FFh
		jnz	loc_50			; Jump if not zero
		retn
loc_50:
		push	ds
		mov	ax,word ptr cs:[94h]
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,data_23e
		mov	cx,103h
		mov	ax,3EBBh
		mov	bx,data_42e
		call	render_tilemap_large
		pop	ds
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

init_timestamp		proc	near
		mov	di,24E8h
		call	time_to_bcd
		mov	cx,6

locloop_51:
		test	byte ptr cs:[di],0FFh
		jz	loc_52			; Jump if zero
		retn
loc_52:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	locloop_51		; Loop if cx > 0

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
loc_53:
		sub	dl,cl
		jc	loc_56			; Jump if carry Set
		sub	ax,bx
		jnc	loc_54			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_55			; Jump if zero
		dec	dl
loc_54:
		inc	dh
		jmp	short loc_53
loc_55:
		add	ax,bx
loc_56:
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
		mov	ds:data_28e,bh
		xor	bh,bh			; Zero register
		mov	dl,ds:data_24e[bx]
		mov	ds:data_27e,dl
		shr	al,1			; Shift w/zeros fill
		sbb	bx,bx
		and	bx,2000h
		add	bl,ah
		mov	ah,50h			; 'P'
		mul	ah			; ax = reg * al
		add	bx,ax
		mov	ax,0B800h
		mov	es,ax
loc_57:
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
		jnz	loc_57			; Jump if not zero
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
		jz	loc_58			; Jump if zero
		mov	bx,0F000h
loc_58:
		test	byte ptr ds:data_28e,0FFh
		jz	loc_61			; Jump if zero
		push	di
		push	cx
		xchg	bh,bl
		mov	cx,7

locloop_59:
		and	es:[di],bx
		add	di,2000h
		cmp	di,4000h
		jb	loc_60			; Jump if below
		add	di,data_48e
loc_60:
		loop	locloop_59		; Loop if cx > 0

		pop	cx
		pop	di
loc_61:
		inc	al
		jnz	loc_62			; Jump if not zero
		retn
loc_62:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:data_40e
		mov	si,ax
		push	cs
		pop	ds
		mov	cl,7
loc_63:
		lodsb				; String [si] to al
		mov	ah,8
loc_64:
		add	al,al
		adc	dx,dx
		add	dx,dx
		dec	ah
		jnz	loc_64			; Jump if not zero
		mov	ax,dx
		shr	dx,1			; Shift w/zeros fill
		or	ax,dx
		test	ch,1
		jnz	loc_65			; Jump if not zero
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
loc_65:
		xchg	ah,al
		and	ah,cs:data_27e
		and	al,cs:data_27e
		or	es:[di],ax
		add	di,2000h
		cmp	di,4000h
		jb	loc_66			; Jump if below
		add	di,0C050h
loc_66:
		dec	cl
		jnz	loc_63			; Jump if not zero
		retn
decode_bitplane_tile		endp

			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_43e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,10Eh
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_2e
		mov	si,ax
		shr	bl,1			; Shift w/zeros fill
		sbb	bp,bp
		and	bp,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	bp,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bp,bx
		mov	ax,0B800h
		mov	es,ax
		mov	cx,12h

locloop_67:
		push	cx
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_32e,ax
		mov	ax,[si+8]
		mov	cs:data_33e,ax
		mov	ax,[si+0Ah]
		xchg	ah,al
		mov	cs:data_34e,ax
		call	extract_bitplane_pixels
		mov	es:[bp],dh
		mov	es:[bp+1],dl
		mov	ax,[si+2]
		xchg	ah,al
		mov	cs:data_32e,ax
		mov	ax,[si+6]
		mov	cs:data_33e,ax
		mov	ax,[si+0Ch]
		xchg	ah,al
		mov	cs:data_34e,ax
		call	extract_bitplane_pixels
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		xor	al,al			; Zero register
		mov	ah,[si+4]
		mov	cs:data_32e,ax
		mov	ah,[si+5]
		mov	cs:data_33e,ax
		mov	ah,[si+0Eh]
		mov	cs:data_34e,ax
		call	extract_bitplane_pixels
		mov	es:[bp+4],dh
		add	si,0Fh
		add	bp,2000h
		cmp	bp,4000h
		jb	loc_68			; Jump if below
		add	bp,0C050h
loc_68:
		pop	cx
		loop	locloop_67		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_43e
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
		mov	ds,cs:data_43e
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
		jz	loc_69			; Jump if zero
		mov	ds,cs:data_43e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_6e
		mov	si,ax
loc_69:
		call	render_tilemap_small
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,data_1e
		or	al,al			; Zero ?
		jz	loc_70			; Jump if zero
		mov	ds,cs:data_43e
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:data_5e
		mov	si,ax
loc_70:
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
		shr	bl,1			; Shift w/zeros fill
		sbb	bp,bp
		and	bp,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	bp,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bp,bx
		mov	ax,0B800h
		mov	es,ax
		mov	cx,10h

locloop_71:
		push	cx
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_32e,ax
		mov	ax,[si+6]
		mov	cs:data_33e,ax
		mov	ax,[si+8]
		xchg	ah,al
		mov	cs:data_34e,ax
		call	extract_bitplane_pixels
		mov	ax,dx
		mov	dx,[si+2]
		xchg	dh,dl
		mov	cs:data_32e,dx
		mov	dx,[si+4]
		mov	cs:data_33e,dx
		mov	dx,[si+0Ah]
		xchg	dh,dl
		mov	cs:data_34e,dx
		call	extract_bitplane_pixels
		xor	bl,bl			; Zero register
		mov	cx,4

locloop_72:
		shr	ax,1			; Shift w/zeros fill
		rcr	dx,1			; Rotate thru carry
		rcr	bl,1			; Rotate thru carry
		loop	locloop_72		; Loop if cx > 0

		mov	es:[bp],ah
		mov	es:[bp+1],al
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		mov	es:[bp+4],bl
		add	si,0Ch
		add	bp,2000h
		cmp	bp,4000h
		jb	loc_73			; Jump if below
		add	bp,0C050h
loc_73:
		pop	cx
		loop	locloop_71		; Loop if cx > 0

		retn
render_tilemap_small		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

extract_bitplane_pixels		proc	near
		mov	cx,8

locloop_74:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_34e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_33e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_32e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_34e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_33e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_32e,1	; Rotate
		adc	bx,bx
		add	dx,dx
		add	dx,dx
		or	dl,cs:data_25e[bx]
		loop	locloop_74		; Loop if cx > 0

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
		mov	ah,ds:data_24e[bx]
		mov	ds:data_27e,ah
		pop	bx
		xor	ah,ah			; Zero register
		sub	al,20h			; ' '
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:data_39e
		push	ax
		mov	al,bl
		and	al,3
		add	al,al
		mov	ds:data_28e,al
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	cl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	cl			; ax = reg * al
		add	ax,bx
		add	di,ax
		pop	si
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

locloop_75:
		push	cx
		lodsb				; String [si] to al
		call	expand_font_bits
		mov	cl,cs:data_28e
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
		and	es:[di],bx
		and	es:[di+2],cl
		and	dl,cs:data_27e
		and	dh,cs:data_27e
		and	ch,cs:data_27e
		or	es:[di],dx
		or	es:[di+2],ch
		pop	cx
		add	di,2000h
		cmp	di,4000h
		jb	loc_76			; Jump if below
		add	di,0C050h
loc_76:
		loop	locloop_75		; Loop if cx > 0

		pop	ds
		retn
render_text_char_alt		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

expand_font_bits		proc	near
		mov	cx,8

locloop_77:
		add	al,al
		adc	bx,bx
		add	bx,bx
		loop	locloop_77		; Loop if cx > 0

		mov	dx,bx
		shr	dx,1			; Shift w/zeros fill
		or	dx,bx
		retn
expand_font_bits		endp

			                        ;* No entry point to code
		push	ds
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		add	di,ax
		mov	si,di
		add	si,2000h
		cmp	si,4000h
		jb	loc_78			; Jump if below
		add	si,data_48e
loc_78:
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_79:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_80			; Jump if below
		add	di,data_45e
loc_80:
		add	si,2000h
		cmp	si,4000h
		jb	loc_81			; Jump if below
		add	si,data_48e
loc_81:
		pop	cx
		loop	locloop_79		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		add	di,0
		shr	al,1			; Shift w/zeros fill
		sbb	si,si
		and	si,2000h
		mov	bl,ah
		mov	bh,50h			; 'P'
		mul	bh			; ax = reg * al
		add	si,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	si,bx
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,0B800h
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

locloop_82:
		push	cx
		push	si
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,4000h
		jb	loc_83			; Jump if below
		add	si,data_45e
loc_83:
		pop	cx
		loop	locloop_82		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	si,di
		add	si,0
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	bl,ah
		mov	bh,50h			; 'P'
		mul	bh			; ax = reg * al
		add	di,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	di,bx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		mov	ch,bh

locloop_84:
		push	cx
		push	di
		mov	cx,bx
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_85			; Jump if below
		add	di,0C050h
loc_85:
		pop	cx
		loop	locloop_84		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	cs:data_30e,bx
		mov	cs:data_31e,cl
		mov	byte ptr cs:data_29e,1
loc_86:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_87			; Jump if not equal
		retn
loc_87:
		cmp	al,0Dh
		je	loc_88			; Jump if equal
		or	al,al			; Zero ?
		js	loc_89			; Jump if sign=1
		push	cx
		push	bx
		push	si
		mov	ah,cs:data_29e
		call	render_text_char_alt
		pop	si
		pop	bx
		pop	cx
		add	bx,8
		jmp	short loc_86
loc_88:
		add	byte ptr cs:data_31e,8
		mov	cl,cs:data_31e
		mov	bx,cs:data_30e
		jmp	short loc_86
loc_89:
		and	al,7
		mov	cs:data_29e,al
		jmp	short loc_86
			                        ;* No entry point to code
		push	ds
		shr	bl,1			; Shift w/zeros fill
		sbb	si,si
		and	si,2000h
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		add	si,ax
		shr	dl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	ax,50h
		mul	dl			; ax = reg * al
		mov	dl,dh
		xor	dh,dh			; Zero register
		add	dx,dx
		add	ax,dx
		add	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_90:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_91			; Jump if below
		add	di,data_38e
loc_91:
		add	si,2000h
		cmp	si,4000h
		jb	loc_92			; Jump if below
		add	si,0C050h
loc_92:
		pop	cx
		loop	locloop_90		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	al,ds:data_26e[bx]
		mov	ds:data_27e,al
		pop	bx
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
		call	fill_rectangle
		mov	cx,10h

locloop_93:
		mov	al,ds:data_27e
		and	al,0F0h
		and	byte ptr es:[di],0Fh
		or	es:[di],al
		mov	al,ds:data_27e
		and	al,0Fh
		and	byte ptr es:[di+4],0F0h
		or	es:[di+4],al
		add	di,2000h
		cmp	di,4000h
		jb	loc_94			; Jump if below
		add	di,data_38e
loc_94:
		loop	locloop_93		; Loop if cx > 0

		call	fill_rectangle
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_rectangle		proc	near
		mov	cx,2

locloop_95:
		push	cx
		push	di
		mov	al,ds:data_27e
		mov	cx,5
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_96			; Jump if below
		add	di,0C050h
loc_96:
		pop	cx
		loop	locloop_95		; Loop if cx > 0

		retn
fill_rectangle		endp

		db	 00h,0FFh,0AAh,0FFh, 55h,0FFh
		db	0FFh,0AAh, 1Eh, 56h, 0Eh, 1Fh
		db	 32h,0E4h, 03h,0C0h, 03h,0C0h
		db	 8Bh,0F0h,0D0h,0EBh, 1Bh,0FFh
		db	 81h,0E7h, 00h, 20h,0B0h, 50h
		db	0F6h,0E3h, 03h,0F8h, 8Ah,0DFh
		db	 32h,0FFh, 03h,0FBh,0B8h, 00h
		db	0B8h, 8Eh,0C0h, 8Bh, 9Ch, 8Eh
		db	 2Ch, 8Bh,0B4h, 90h, 2Ch,0B9h
		db	 0Dh, 00h

locloop_97:
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
		cmp	di,4000h
		jb	loc_98			; Jump if below
		add	di,data_38e
loc_98:
		pop	cx
		loop	locloop_97		; Loop if cx > 0

		pop	si
		pop	ds
		retn
		db	 96h, 2Ch,0FEh, 2Ch,0CAh, 2Ch
		db	 32h, 2Dh,0FFh,0F0h, 0Ch,0FFh
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
		db	 00h, 00h, 00h,0B8h, 00h,0B8h
		db	 8Eh,0C0h, 33h,0FFh,0B9h, 08h
		db	 00h

locloop_99:
		push	cx
		push	di
		mov	cx,19h

locloop_100:
		push	cx
		push	di
		mov	cx,28h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		add	di,140h
		pop	cx
		loop	locloop_100		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_101			; Jump if below
		add	di,0C050h
loc_101:
		pop	cx
		loop	locloop_99		; Loop if cx > 0

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
		mov	di,data_44e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,data_44e

locloop_102:
		push	cx
		call	process_sprite_row
		pop	cx
		loop	locloop_102		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

process_sprite_row		proc	near
		mov	cx,8

locloop_103:
		push	cx
		lodsw				; String [si] to ax
		mov	cs:data_32e,ax
		lodsw				; String [si] to ax
		mov	cs:data_33e,ax
		lodsw				; String [si] to ax
		mov	cs:data_34e,ax
		call	extract_bitplane_pixels
		mov	ax,dx
		stosw				; Store ax to es:[di]
		pop	cx
		loop	locloop_103		; Loop if cx > 0

		retn
process_sprite_row		endp

		db	12 dup (0)

seg_a		ends



		end	start
