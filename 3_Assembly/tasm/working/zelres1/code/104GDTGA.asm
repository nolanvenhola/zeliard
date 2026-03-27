
PAGE  59,132

;==========================================================================
;
;  PLAYER_STATS - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	240h
data_40e	equ	29DCh			;*
data_41e	equ	2A80h			;*
data_42e	equ	32FCh			;*
data_43e	equ	3304h			;*
data_44e	equ	3640h			;*
data_45e	equ	3642h			;*
data_46e	equ	3B04h			;*
data_47e	equ	3BC8h			;*
data_48e	equ	3BFBh			;*
data_49e	equ	3BFCh			;*
data_50e	equ	4BD4h			;*
data_51e	equ	4BFDh			;*
data_52e	equ	4BFFh			;*
data_53e	equ	4C01h			;*
data_54e	equ	4C03h			;*
data_55e	equ	4C05h			;*
data_56e	equ	4C07h			;*
data_57e	equ	4C09h			;*
data_58e	equ	4C0Ah			;*
data_59e	equ	4C0Bh			;*
data_60e	equ	4C0Ch			;*
data_61e	equ	4C0Fh			;*
data_63e	equ	4C11h			;*
data_64e	equ	4C13h			;*
data_65e	equ	5255h			;*
data_66e	equ	5500h			;*
data_67e	equ	80A0h			;*
data_68e	equ	0A000h			;*
data_69e	equ	0BF07h			;*
data_70e	equ	0F500h			;*
data_71e	equ	0FF1Ah			;*
data_72e	equ	0FF2Ch			;*
data_73e	equ	0			;*
data_74e	equ	1A6Eh			;*
data_75e	equ	1A8Eh			;*
data_76e	equ	8000h			;*
data_77e	equ	80A0h			;*
data_78e	equ	0			;*
data_79e	equ	0
data_80e	equ	80A0h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_04		proc	far

start:
		cwd				; Word to double word
		and	al,[bx+si]
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
		dec	bx
		xor	dh,[bx+si]
		xor	byte ptr [bx+si],0D4h
;*		xor	dh,dl
		db	 30h,0D6h		;  Fixup - byte match
		inc	cx
		mov	cl,[bp+di+0Ch]
		xor	di,[bx+di+33h]
		push	word ptr [bp+di]
;*		jg	loc_1			;*Jump if >
		db	 7Fh, 34h		;  Fixup - byte match
		db	 60h, 36h,0B4h, 36h, 08h, 37h
		db	0ECh, 30h, 47h, 37h,0C9h, 37h
		db	0C3h, 38h, 01h, 3Ch, 4Bh, 3Dh
		db	 06h, 3Eh, 5Ch, 3Eh, 39h, 40h
		db	 19h, 41h,0B2h, 41h,0C4h, 4Bh
		db	 50h, 53h, 51h, 1Eh, 8Ah,0C5h
		db	0F6h,0E1h, 8Bh,0E8h, 06h, 1Fh
		db	 8Bh,0F7h, 8Ch,0C8h, 05h, 00h
		db	 30h, 8Eh,0C0h,0BFh
		db	 00h, 00h, 2Eh,0C7h, 06h, 01h
		db	 4Ch, 00h, 00h, 2Eh,0C7h, 06h
		db	 03h, 4Ch, 00h, 00h, 8Bh,0CDh
		db	0D1h,0E9h

locloop_2:
		mov	ax,ds:[bp+si]
		xchg	ah,al
		mov	cs:data_55e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_2		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		pop	ax
		mov	di,0
		jmp	loc_6
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
		mov	word ptr cs:data_55e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_3:
		add	bp,bp
		mov	ax,ds:[bp+si]
		xchg	al,ah
		mov	cs:data_54e,ax
		shr	bp,1			; Shift w/zeros fill
		mov	ax,ds:[bp+si]
		xchg	al,ah
		mov	cs:data_53e,ax
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_3		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		pop	ax
		mov	di,0
		jmp	loc_6
			                        ;* No entry point to code
		push	ds
		push	ax
		push	es
		push	di
		call	extract_bits_2
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_61e,32CAh
		call	stats_func_1
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
		mov	word ptr cs:data_52e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_4:
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
		mov	cs:data_54e,bx
		mov	cs:data_53e,ax
		mov	cs:data_55e,cx
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		pop	cx
		loop	locloop_4		; Loop if cx > 0

		pop	ds
		pop	cx
		pop	bx
		xor	ax,ax			; Zero register
		mov	di,0
		push	ds
		push	ax
		push	es
		push	di
		call	extract_bits_2
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_61e,3290h
		mov	byte ptr cs:data_60e,0
		or	al,al			; Zero ?
		jnz	loc_5			; Jump if not zero
		call	stats_func_1
loc_5:
		mov	byte ptr cs:data_60e,0FFh
		call	stats_func_1
		pop	ds
		retn
loc_6:
		push	ds
		push	ax
		push	es
		push	di
		call	extract_bits_2
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_61e,3234h
		mov	byte ptr cs:data_60e,0
		or	al,al			; Zero ?
		jnz	loc_7			; Jump if not zero
		call	stats_func_1
loc_7:
		mov	byte ptr cs:data_60e,0FFh
		call	stats_func_1
		pop	ds
		retn

zr1_04		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_func_1		proc	near
		mov	byte ptr cs:data_58e,0
		mov	ax,0B800h
		mov	es,ax
		mov	bp,8
loc_8:
		mov	al,cs:data_58e
		mov	cs:data_57e,al
		mov	byte ptr cs:data_71e,0
		push	cx
		push	si
		push	di
loc_9:
		mov	bl,cs:data_57e
		and	bx,7
		mov	bl,cs:data_42e[bx]
		call	word ptr cs:data_61e
		inc	byte ptr cs:data_57e
		mov	al,ch
		xor	ah,ah			; Zero register
		add	ax,ax
		add	si,ax
		add	di,2000h
		cmp	di,8000h
		jb	loc_10			; Jump if below
		add	di,80A0h
loc_10:
		dec	cl
		jz	loc_12			; Jump if zero
		mov	bl,cs:data_57e
		and	bx,7
		mov	bl,cs:data_43e[bx]
		call	word ptr cs:data_61e
		inc	byte ptr cs:data_57e
		mov	al,ch
		xor	ah,ah			; Zero register
		add	ax,ax
		add	si,ax
		add	di,2000h
		cmp	di,8000h
		jb	loc_11			; Jump if below
		add	di,80A0h
loc_11:
		dec	cl
		jnz	loc_9			; Jump if not zero
loc_12:
		pop	di
		pop	si
		pop	cx
		inc	byte ptr cs:data_58e
loc_13:
		cmp	byte ptr cs:data_71e,14h
		jb	loc_13			; Jump if below
		dec	bp
		jz	loc_ret_14		; Jump if zero
		jmp	loc_8

loc_ret_14:
		retn
stats_func_1		endp

			                        ;* No entry point to code
		test	byte ptr cs:data_60e,0FFh
		jz	loc_18			; Jump if zero
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx

locloop_15:
		lodsb				; String [si] to al
		rol	bl,1			; Rotate
		jnc	loc_16			; Jump if carry=0
		and	byte ptr es:[di],0Fh
		mov	ah,al
		and	ah,0F0h
		or	es:[di],ah
loc_16:
		rol	bl,1			; Rotate
		jnc	loc_17			; Jump if carry=0
		and	byte ptr es:[di],0F0h
		and	al,0Fh
		or	es:[di],al
loc_17:
		inc	di
		loop	locloop_15		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
loc_18:
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx

locloop_19:
		lodsb				; String [si] to al
		rol	bl,1			; Rotate
		jnc	loc_20			; Jump if carry=0
		mov	ah,al
		and	ah,0F0h
		or	es:[di],ah
loc_20:
		rol	bl,1			; Rotate
		jnc	loc_21			; Jump if carry=0
		and	al,0Fh
		or	es:[di],al
loc_21:
		inc	di
		loop	locloop_19		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
			                        ;* No entry point to code
		test	byte ptr cs:data_60e,0FFh
		jz	loc_18			; Jump if zero
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx

locloop_22:
		lodsb				; String [si] to al
		rol	bl,1			; Rotate
		jnc	loc_23			; Jump if carry=0
		mov	ah,al
		and	ah,0F0h
		jz	loc_23			; Jump if zero
		and	byte ptr es:[di],0Fh
		or	es:[di],ah
loc_23:
		rol	bl,1			; Rotate
		jnc	loc_24			; Jump if carry=0
		and	al,0Fh
		jz	loc_24			; Jump if zero
		and	byte ptr es:[di],0F0h
		or	es:[di],al
loc_24:
		inc	di
		loop	locloop_22		; Loop if cx > 0

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

locloop_25:
		rol	bl,1			; Rotate
		sbb	al,al
		and	al,0Fh
		mov	dl,al
		rol	bl,1			; Rotate
		sbb	al,al
		and	al,0F0h
		or	dl,al
		rol	bl,1			; Rotate
		sbb	al,al
		and	al,0Fh
		mov	dh,al
		rol	bl,1			; Rotate
		sbb	al,al
		and	al,0F0h
		or	dh,al
		and	es:[di],dx
		inc	di
		inc	di
		loop	locloop_25		; Loop if cx > 0

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
		or	byte ptr ds:data_69e,15h
		dec	sp
		xor	ax,ax			; Zero register
		mov	cx,320h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	di,4C15h
loc_26:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_27			; Jump if not equal
		retn
loc_27:
		sub	al,20h			; ' '
		jnc	loc_28			; Jump if carry=0
		retn
loc_28:
		jz	loc_30			; Jump if zero
		push	si
		push	di
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:data_70e
		mov	si,ax
		mov	cx,8

locloop_29:
		push	cx
		lodsb				; String [si] to al
		call	stats_func_2
		mov	es:[di],dx
		call	stats_func_2
		mov	es:[di+2],dx
		add	di,0A0h
		pop	cx
		loop	locloop_29		; Loop if cx > 0

		pop	di
		pop	si
loc_30:
		add	di,4
		jmp	short loc_26

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_func_2		proc	near
		add	al,al
		sbb	ah,ah
		and	ah,0F0h
		add	al,al
		sbb	dl,dl
		and	dl,0Fh
		or	dl,ah
		add	al,al
		sbb	ah,ah
		and	ah,0F0h
		add	al,al
		sbb	dh,dh
		and	dh,0Fh
		or	dh,ah
		retn
stats_func_2		endp

			                        ;* No entry point to code
		push	ds
		push	cx
		push	bx
		mov	dl,0A0h
		mul	dl			; ax = reg * al
		add	ax,4C15h
		mov	si,ax
		add	cl,bl
		mov	al,0A0h
		mul	cl			; ax = reg * al
		add	ax,8000h
		push	ax
		push	si
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		push	ds
		pop	es
		mov	di,data_76e
		mov	si,data_77e
		mov	cx,3FB0h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		push	cs
		pop	ds
		mov	cx,50h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	bx
		push	bx
		call	extract_bits_2
		mov	di,ax
		pop	bx
		mov	al,0A0h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	si,ax
		add	si,0
		mov	bp,ax
		add	bp,data_76e
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	ax,0B800h
		mov	es,ax
		pop	cx
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

locloop_31:
		push	cx
		push	di
		mov	cx,bx

locloop_32:
		lodsw				; String [si] to ax
		or	ax,ds:[bp]
		stosw				; Store ax to es:[di]
		inc	bp
		inc	bp
		loop	locloop_32		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_33			; Jump if below
		add	di,80A0h
loc_33:
		pop	cx
		loop	locloop_31		; Loop if cx > 0

		pop	ds
		retn
loc_34:
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
		mov	word ptr cs:data_55e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_35:
		add	bp,bp
		mov	ax,ds:[bp+si]
		xchg	ah,al
		mov	cs:data_54e,ax
		shr	bp,1			; Shift w/zeros fill
		mov	ax,ds:[bp+si]
		xchg	ah,al
		mov	cs:data_53e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_35		; Loop if cx > 0

		pop	cx
		pop	bx
		pop	ax
		pop	ds
loc_36:
		push	ds
		call	extract_bits_2
		mov	di,ax
		mov	si,data_78e
		push	es
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ch
		add	bx,bx
		xor	ch,ch			; Zero register

locloop_37:
		push	cx
		push	di
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	cx
		add	di,2000h
		cmp	di,8000h
		jb	loc_38			; Jump if below
		add	di,80A0h
loc_38:
		loop	locloop_37		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_68e
		xor	dx,dx			; Zero register
		mov	cx,9

locloop_39:
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
		add	dx,180h
		loop	locloop_39		; Loop if cx > 0

		mov	byte ptr ds:data_71e,0
loc_40:
		mov	si,data_68e
		mov	cx,9

locloop_41:
		push	cx
		test	byte ptr [si],0FFh
		jz	loc_43			; Jump if zero
		mov	al,[si+0Dh]
		cmp	al,[si+0Eh]
		je	loc_42			; Jump if equal
		inc	byte ptr [si+0Ch]
		test	byte ptr [si+0Ch],1
		jnz	loc_42			; Jump if not zero
		inc	byte ptr [si+0Dh]
loc_42:
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	cx,ds:data_45e[bx]
		mov	[si+7],cx
		mov	al,[si+4]
		add	al,[si+0Ah]
		mov	[si+4],al
		mov	bh,al
		mov	al,[si+3]
		add	al,[si+9]
		mov	[si+3],al
		mov	bl,al
		call	extract_bits_2
		mov	[si+5],ax
		mov	di,ax
		mov	bp,[si+1]
		push	ds
		push	si
		mov	ax,0B800h
		mov	ds,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	si,di
		mov	di,bp
		call	copy_buffer
		pop	si
		pop	ds
loc_43:
		pop	cx
		add	si,0Fh
		loop	locloop_41		; Loop if cx > 0

		mov	si,data_68e
		mov	cx,9

locloop_44:
		push	cx
		test	byte ptr cs:[si],0FFh
		jz	loc_45			; Jump if zero
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	bp,ds:data_44e[bx]
		mov	cx,[si+7]
		mov	dl,[si]
		mov	byte ptr [si],0
		mov	ax,[si+3]
		cmp	ah,4Bh			; 'K'
		jae	loc_45			; Jump if above or =
		cmp	al,0A0h
		jae	loc_45			; Jump if above or =
		mov	[si],dl
		mov	di,[si+5]
		push	ds
		push	si
		mov	ax,0B800h
		mov	es,ax
		mov	ds,cs:data_72e
		mov	si,bp
		call	stats_multiply
		pop	si
		pop	ds
loc_45:
		pop	cx
		add	si,0Fh
		loop	locloop_44		; Loop if cx > 0

loc_46:
		cmp	byte ptr cs:data_71e,1Eh
		jb	loc_46			; Jump if below
		mov	byte ptr cs:data_71e,0
		mov	si,data_68e
		mov	cx,9

locloop_47:
		push	cx
		mov	bp,[si+1]
		mov	di,[si+5]
		mov	cx,[si+7]
		push	ds
		push	si
		mov	ax,0B800h
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
		loop	locloop_47		; Loop if cx > 0

		mov	si,data_68e
		mov	cx,9

locloop_48:
		test	byte ptr [si],0FFh
		jz	loc_49			; Jump if zero
		jmp	loc_40
loc_49:
		add	si,0Fh
		loop	locloop_48		; Loop if cx > 0

		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

copy_buffer		proc	near
		push	si
		push	cx
loc_50:
		push	si
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	si
		add	si,2000h
		cmp	si,8000h
		jb	loc_51			; Jump if below
		add	si,80A0h
loc_51:
		dec	cl
		jnz	loc_50			; Jump if not zero
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
loc_52:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		add	cx,cx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_53			; Jump if below
		add	di,80A0h
loc_53:
		dec	cl
		jnz	loc_52			; Jump if not zero
		pop	cx
		pop	di
		retn
copy_buffer_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_multiply		proc	near
		push	di
		push	cx
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bx,ax
		mov	word ptr cs:data_55e,0
loc_54:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_55:
		xor	al,al			; Zero register
		mov	ah,[bx+si]
		mov	cs:data_53e,ax
		mov	ah,[si]
		mov	cs:data_52e,ax
		mov	cs:data_54e,ax
		inc	si
		push	bx
		call	stats_process_loop_4
		pop	bx
		or	es:[di],ax
		inc	di
		inc	di
		loop	locloop_55		; Loop if cx > 0

		pop	cx
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_56			; Jump if below
		add	di,80A0h
loc_56:
		dec	cl
		jnz	loc_54			; Jump if not zero
		pop	cx
		pop	di
		retn
stats_multiply		endp

		db	 00h, 90h, 20h, 06h, 80h, 91h
		db	 20h, 06h, 00h, 93h, 20h, 06h
		db	 80h, 94h, 20h, 06h, 00h, 96h
		db	 18h, 04h,0C0h, 96h, 18h, 04h
		db	 80h, 97h, 18h, 04h
data_2		dw	9840h			; Data table (indexed access)
		db	 18h, 04h, 1Eh, 53h, 32h,0E4h
		db	0BAh,0C0h, 0Ch,0F7h,0E2h, 05h
		db	 40h,0ABh, 2Eh, 8Eh, 1Eh, 2Ch
		db	0FFh, 8Bh,0F0h, 8Ch,0C8h, 05h
		db	 00h, 30h, 8Eh,0C0h,0BFh, 00h
		db	 00h, 2Eh,0C7h, 06h, 05h, 4Ch
		db	 00h, 00h, 2Eh,0C7h, 06h, 03h
		db	 4Ch, 00h, 00h,0B9h, 30h, 03h

locloop_57:
		mov	ax,data_2[si]
		xchg	ah,al
		mov	cs:data_52e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_53e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_57		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,0
		mov	cx,2230h
		jmp	loc_36
		db	 1Eh, 53h, 32h,0E4h
data_4		db	0BAh
		db	 80h, 04h,0F7h,0E2h, 05h,0C0h
		db	 97h, 2Eh, 8Eh, 1Eh, 2Ch,0FFh
		db	 8Bh,0F0h, 8Ch,0C8h, 05h, 00h
		db	 30h, 8Eh,0C0h,0BFh, 00h, 00h
		db	 2Eh,0C7h, 06h, 05h, 4Ch, 00h
		db	 00h, 2Eh,0C7h, 06h, 03h, 4Ch
		db	 00h, 00h,0B9h, 20h, 01h

locloop_58:
		mov	ax,ds:data_1e[si]
		xchg	ah,al
		mov	cs:data_53e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_58		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,data_79e
		mov	cx,1220h
		jmp	loc_36
			                        ;* No entry point to code
		mov	ax,0B800h
		mov	es,ax
		xor	di,di			; Zero register
		mov	cx,64h

locloop_59:
		push	cx
		push	di
		mov	ax,101h
		mov	cx,50h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_60			; Jump if below
		add	di,data_80e
loc_60:
		push	di
		mov	ax,1010h
		mov	cx,50h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_61			; Jump if below
		add	di,80A0h
loc_61:
		pop	cx
		loop	locloop_59		; Loop if cx > 0

		retn
		db	 33h,0DBh,0B9h, 19h, 00h

locloop_62:
		push	cx
		mov	cx,22h

locloop_63:
		push	cx
		lodsb				; String [si] to al
		push	bx
		push	ds
		push	si
		call	stats_multiply_2
		pop	si
		pop	ds
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_63		; Loop if cx > 0

		xor	bh,bh			; Zero register
		inc	bl
		pop	cx
		loop	locloop_62		; Loop if cx > 0

		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_multiply_2		proc	near
		mov	ds,cs:data_72e
		mov	dx,cs
		add	dx,2000h
		mov	es,dx
		xor	ah,ah			; Zero register
loc_64:
		sub	al,28h			; '('
		jc	loc_65			; Jump if carry Set
		inc	ah
		jmp	short loc_64
loc_65:
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

locloop_66:
		push	cx
		push	di
		push	si
		mov	cx,8

locloop_67:
		movsb				; Mov [si] to es:[di]
		add	di,21h
		add	si,27h
		loop	locloop_67		; Loop if cx > 0

		pop	si
		pop	di
		add	di,1A90h
		add	si,640h
		pop	cx
		loop	locloop_66		; Loop if cx > 0

		retn
stats_multiply_2		endp

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
		mov	di,data_65e
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,data_74e
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,data_65e
		mov	cx,44h

locloop_68:
		mov	al,es:[di]
		mov	dx,8
loc_69:
		ror	al,1			; Rotate
		adc	ah,ah
		dec	dx
		jnz	loc_69			; Jump if not zero
		mov	es:[di],ah
		inc	di
		loop	locloop_68		; Loop if cx > 0

		pop	si
		pop	ax
		mov	bl,al
		xor	bh,bh			; Zero register
		call	extract_bits_2
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		push	di
		mov	cx,11h

locloop_70:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	bx,ds:data_75e[si]
		xchg	bh,bl
		mov	dx,ax
		and	dx,bx
		mov	cs:data_52e,dx
		or	dx,bx
		mov	cs:data_53e,dx
		mov	cs:data_54e,dx
		mov	cs:data_55e,dx
		or	ax,bx
		not	ax
		mov	cs:data_56e,ax
		call	stats_func_20
		and	es:[di],ax
		call	stats_process_loop_4
		or	es:[di],ax
		call	stats_func_20
		and	es:[di+2],ax
		call	stats_process_loop_4
		or	es:[di+2],ax
		add	di,4
		pop	cx
		loop	locloop_70		; Loop if cx > 0

		pop	di
		add	di,9Ch
		push	cs
		pop	ds
		mov	si,data_65e
		mov	cx,11h

locloop_71:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	bx,[si+20h]
		xchg	bh,bl
		mov	dx,ax
		and	dx,bx
		mov	cs:data_52e,dx
		or	dx,bx
		mov	cs:data_53e,dx
		mov	cs:data_54e,dx
		mov	cs:data_55e,dx
		or	ax,bx
		not	ax
		mov	cs:data_56e,ax
		call	stats_func_20
		and	es:[di+2],ax
		call	stats_process_loop_4
		or	es:[di+2],ax
		call	stats_func_20
		and	es:[di],ax
		call	stats_process_loop_4
		or	es:[di],ax
		sub	di,4
		pop	cx
		loop	locloop_71		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	bx,ax
		add	bx,bx
		mov	al,ds:data_48e[bx]
		mov	ds:data_58e,al
		mov	al,ds:data_49e[bx]
		mov	ds:data_57e,al
		mov	ax,0B800h
		mov	es,ax
		mov	di,288h
		mov	si,data_46e
loc_72:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_73			; Jump if zero
		call	stats_func_7
		add	di,0A0h
		jmp	short loc_72
loc_73:
		add	di,0FF62h
loc_74:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_75			; Jump if zero
		call	stats_func_7
		inc	di
		inc	di
		jmp	short loc_74
loc_75:
		add	di,0FF5Eh
loc_76:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_77			; Jump if zero
		call	stats_func_7
		add	di,0FF60h
		jmp	short loc_76
loc_77:
		add	di,9Eh
loc_78:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_79			; Jump if zero
		call	stats_func_7
		dec	di
		dec	di
		jmp	short loc_78
loc_79:
		add	di,0A2h
		mov	si,data_47e
loc_80:
		mov	byte ptr cs:data_71e,0
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_81			; Jump if not zero
		retn
loc_81:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_82:
		push	cx
		mov	al,18h
		call	stats_func_7
		add	di,0A0h
		pop	cx
		loop	locloop_82		; Loop if cx > 0

		add	di,0FF60h
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_83			; Jump if not zero
		retn
loc_83:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_84:
		push	cx
		mov	al,18h
		call	stats_func_7
		inc	di
		inc	di
		pop	cx
		loop	locloop_84		; Loop if cx > 0

		dec	di
		dec	di
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_85			; Jump if not zero
		retn
loc_85:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_86:
		push	cx
		mov	al,18h
		call	stats_func_7
		add	di,0FF60h
		pop	cx
		loop	locloop_86		; Loop if cx > 0

		add	di,0A0h
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_87			; Jump if not zero
		retn
loc_87:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_88:
		push	cx
		mov	al,18h
		call	stats_func_7
		dec	di
		dec	di
		pop	cx
		loop	locloop_88		; Loop if cx > 0

		inc	di
		inc	di
loc_89:
		cmp	byte ptr cs:data_71e,0Ch
		jb	loc_89			; Jump if below
		jmp	short loc_80

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_func_7		proc	near
		push	si
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,3A44h
		mov	si,ax
		push	di
		mov	bh,cs:data_57e
		call	extract_bits
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,8000h
		jb	loc_90			; Jump if below
		add	di,80A0h
loc_90:
		mov	bh,cs:data_57e
		ror	bh,1			; Rotate
		call	extract_bits
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,8000h
		jb	loc_91			; Jump if below
		add	di,80A0h
loc_91:
		mov	bh,cs:data_57e
		call	extract_bits
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,8000h
		jb	loc_92			; Jump if below
		add	di,80A0h
loc_92:
		mov	bh,cs:data_57e
		ror	bh,1			; Rotate
		call	extract_bits
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		pop	di
		pop	si
		retn
stats_func_7		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

extract_bits		proc	near
		mov	word ptr ds:data_52e,0
		mov	word ptr ds:data_55e,0
		mov	ah,[si+4]
		mov	ds:data_54e,ax
		mov	ds:data_53e,ax
		lodsb				; String [si] to al
		and	al,bh
		mov	ah,al
		mov	al,ds:data_58e
		shr	al,1			; Shift w/zeros fill
		jnc	loc_93			; Jump if carry=0
		or	ds:data_52e,ax
loc_93:
		shr	al,1			; Shift w/zeros fill
		jnc	loc_94			; Jump if carry=0
		or	ds:data_53e,ax
loc_94:
		shr	al,1			; Shift w/zeros fill
		jc	loc_95			; Jump if carry Set
		retn
loc_95:
		or	ds:data_54e,ax
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
		db	 1Eh, 2Eh,0A2h, 0Ch, 4Ch, 53h
		db	 51h, 8Ah,0C5h,0F6h,0E1h, 8Bh
		db	0E8h, 06h, 1Fh, 8Bh,0F7h, 8Ch
		db	0C8h, 05h, 00h, 30h, 8Eh,0C0h
		db	0BFh, 00h, 00h, 2Eh,0C7h, 06h
		db	 05h, 4Ch, 00h, 00h, 2Eh,0C7h
		db	 06h,0FFh, 4Bh, 00h, 00h, 2Eh
		db	0C7h, 06h, 01h, 4Ch, 00h, 00h
		db	 2Eh,0C7h, 06h, 03h, 4Ch, 00h
		db	 00h, 8Bh,0CDh,0D1h,0E9h

locloop_96:
		push	si
		test	byte ptr cs:data_60e,1
		jz	loc_97			; Jump if zero
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_52e,ax
		add	si,bp
loc_97:
		test	byte ptr cs:data_60e,2
		jz	loc_98			; Jump if zero
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_53e,ax
		add	si,bp
loc_98:
		test	byte ptr cs:data_60e,4
		jz	loc_99			; Jump if zero
		mov	ax,[si]
		xchg	ah,al
		mov	cs:data_54e,ax
loc_99:
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		pop	si
		inc	si
		inc	si
		loop	locloop_96		; Loop if cx > 0

		pop	cx
		pop	bx
		sub	bx,410h
		mov	byte ptr cs:data_58e,0
		mov	byte ptr cs:data_59e,0
		mov	cs:data_61e,cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,0
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

locloop_100:
		push	cx
		mov	al,cs:data_59e
		mov	cs:data_58e,al
		mov	byte ptr cs:data_71e,0
		mov	cx,0Dh

locloop_101:
		push	cx
		push	bx
		push	si
		call	stats_multiply_3
		pop	si
		pop	bx
		pop	cx
		add	byte ptr cs:data_58e,8
		loop	locloop_101		; Loop if cx > 0

		pop	cx
loc_102:
		cmp	byte ptr cs:data_71e,14h
		jb	loc_102			; Jump if below
		inc	byte ptr cs:data_59e
		loop	locloop_100		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_multiply_3		proc	near
		push	bx
		mov	bl,cs:data_58e
		add	bl,10h
		mov	bh,4
		call	extract_bits_2
		mov	di,ax
		pop	bx
		cmp	cs:data_58e,bl
		jb	loc_105			; Jump if below
		mov	al,bl
		add	al,cs:data_61e
		cmp	cs:data_58e,al
		jae	loc_105			; Jump if above or =
		mov	al,cs:data_58e
		sub	al,bl
		add	al,al
		mul	byte ptr cs:data_61e+1	; ax = data * al
		add	si,ax
		mov	byte ptr cs:data_57e,0
		mov	cx,48h

locloop_103:
		push	cx
		mov	word ptr es:[di],0
		cmp	cs:data_57e,bh
		jb	loc_104			; Jump if below
		mov	al,bh
		add	al,byte ptr cs:data_61e+1
		cmp	cs:data_57e,al
		jae	loc_104			; Jump if above or =
		movsw				; Mov [si] to es:[di]
		dec	di
		dec	di
loc_104:
		inc	di
		inc	di
		inc	byte ptr cs:data_57e
		pop	cx
		loop	locloop_103		; Loop if cx > 0

		retn
loc_105:
		mov	cx,48h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
stats_multiply_3		endp

			                        ;* No entry point to code
		mov	cs:data_58e,bl
		call	extract_bits_2
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		sub	bx,2
		xor	ch,ch			; Zero register
		sub	cx,5
		push	cx
		push	di
		call	fill_buffer
		pop	di
		inc	byte ptr cs:data_58e
		add	di,2000h
		cmp	di,8000h
		jb	loc_106			; Jump if below
		add	di,data_67e
loc_106:
		mov	cx,2
		call	clear_buffer
		pop	cx

locloop_107:
		push	cx
		call	stats_get_value
		or	byte ptr es:[di],0Fh
		mov	byte ptr es:[di+1],0
		or	byte ptr es:[bx+di+1],0F0h
		mov	byte ptr es:[bx+di],0
		inc	byte ptr cs:data_58e
		add	di,2000h
		cmp	di,8000h
		jb	loc_108			; Jump if below
		add	di,data_67e
loc_108:
		pop	cx
		loop	locloop_107		; Loop if cx > 0

		mov	cx,1
		call	clear_buffer

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

fill_buffer		proc	near
		call	stats_get_value
		or	byte ptr es:[di],0Fh
		inc	di
		mov	cx,bx
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0F0h
		retn
fill_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

clear_buffer		proc	near

locloop_109:
		push	cx
		push	di
		call	stats_get_value
		or	byte ptr es:[di],0Fh
		inc	di
		mov	cx,bx
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0F0h
		pop	di
		inc	byte ptr cs:data_58e
		add	di,2000h
		cmp	di,8000h
		jb	loc_110			; Jump if below
		add	di,80A0h
loc_110:
		pop	cx
		loop	locloop_109		; Loop if cx > 0

		retn
clear_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_get_value		proc	near
		mov	word ptr es:[di-3],4444h
		mov	word ptr es:[di-1],4444h
		retn
stats_get_value		endp

			                        ;* No entry point to code
		push	bx
		push	es
		push	di
		mov	cx,1028h

locloop_111:
		mov	al,es:[di]
		and	al,byte ptr es:[1028h][di]
		mov	ah,es:data_39[di]
		not	ah
		and	al,ah
		not	al
		and	es:[di],al
		and	byte ptr es:[1028h][di],al
		and	es:data_39[di],al
		mov	al,es:data_39[di]
		mov	ah,es:[di]
		not	ah
		and	al,ah
		mov	ah,byte ptr es:[1028h][di]
		not	ah
		and	al,ah
		or	es:[di],al
		or	byte ptr es:[1028h][di],al
		not	al
		and	es:data_39[di],al
		inc	di
		loop	locloop_111		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,2F58h
		jmp	loc_34
			                        ;* No entry point to code
		push	ds
		mov	ds:data_63e,di
		mov	ds:data_64e,es
		mov	di,69Ah
		add	di,ds:data_63e
		call	stats_process_loop_3
		mov	di,offset data_4
		add	di,ds:data_63e
		call	stats_process_loop_3
		mov	ax,0B800h
		mov	es,ax
		mov	ds,cs:data_64e
		mov	cx,44h

locloop_112:
		push	cx
		mov	byte ptr cs:data_71e,0
		mov	ax,44h
		sub	ax,cx
		add	ax,ax
		push	ax
		mov	bl,al
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		push	ax
		mov	bh,0
		call	extract_bits_2
		mov	di,ax
		pop	ax
		add	ax,cs:data_63e
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	loc_113			; Jump if below
		cmp	ax,71h
		jae	loc_113			; Jump if above or =
		call	stats_process_loop_2
		jmp	short loc_114
loc_113:
		call	stats_process_loop
loc_114:
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
		call	extract_bits_2
		mov	di,ax
		pop	ax
		add	ax,cs:data_63e
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	loc_115			; Jump if below
		cmp	ax,71h
		jae	loc_115			; Jump if above or =
		call	stats_process_loop_2
		jmp	short loc_116
loc_115:
		call	stats_process_loop
loc_116:
		cmp	byte ptr cs:data_71e,4
		jb	loc_116			; Jump if below
		pop	cx
		loop	locloop_112		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_process_loop		proc	near
		mov	cx,28h
		mov	word ptr cs:data_55e,0

locloop_117:
		mov	ax,ds:data_66e[si]
		xchg	ah,al
		mov	cs:data_54e,ax
		mov	ax,ds:data_41e[si]
		xchg	ah,al
		mov	cs:data_53e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_117		; Loop if cx > 0

		retn
stats_process_loop		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_process_loop_2		proc	near
		mov	cx,0Bh
		mov	word ptr cs:data_55e,0

locloop_118:
		mov	ah,ds:data_66e[si]
		mov	cs:data_54e,ax
		mov	ah,ds:data_41e[si]
		mov	cs:data_53e,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_118		; Loop if cx > 0

		add	si,18h
		add	di,30h
		mov	cx,5

locloop_119:
		mov	ax,ds:data_66e[si]
		xchg	ah,al
		mov	cs:data_54e,ax
		mov	ax,ds:data_41e[si]
		xchg	ah,al
		mov	cs:data_53e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_119		; Loop if cx > 0

		add	si,18h
		add	di,30h
		mov	cx,0Bh

locloop_120:
		mov	ah,ds:data_66e[si]
		mov	cs:data_54e,ax
		mov	ah,ds:data_41e[si]
		mov	cs:data_53e,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_120		; Loop if cx > 0

		retn
stats_process_loop_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_process_loop_3		proc	near
		push	di
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

locloop_121:
		mov	byte ptr es:[di],30h	; '0'
		mov	byte ptr es:[di+19h],0Ch
		add	di,50h
		loop	locloop_121		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		pop	di
		add	di,data_41e
		push	di
		mov	ax,0FD7Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,2Dh

locloop_122:
		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	byte ptr es:[di],70h	; 'p'
		mov	byte ptr es:[di+19h],0Dh
		add	di,50h
		loop	locloop_122		; Loop if cx > 0

		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	ax,0FD7Fh
		call	fill_buffer_2
		pop	di
		add	di,data_41e
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

locloop_123:
		mov	byte ptr es:[di],30h	; '0'
		mov	byte ptr es:[di+19h],0Ch
		add	di,50h
		loop	locloop_123		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		retn
stats_process_loop_3		endp


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
		mov	ds:data_63e,di
		mov	ds:data_64e,es
		mov	ax,0B800h
		mov	es,ax
		mov	ds,cs:data_64e
		mov	cx,39h

locloop_124:
		mov	byte ptr cs:data_71e,0
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,39h
		add	ax,ax
		call	stats_multiply_4
		pop	ax
		push	ax
		add	ax,ax
		dec	ax
		call	stats_multiply_4
loc_125:
		cmp	byte ptr cs:data_71e,4
		jb	loc_125			; Jump if below
		pop	cx
		loop	locloop_124		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_multiply_4		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,cs:data_63e
		mov	si,ax
		xor	bh,bh			; Zero register
		call	extract_bits_2
		mov	di,ax
		pop	ax
		cmp	ax,14h
		jae	loc_126			; Jump if above or =
		mov	cx,2Fh
		jmp	short loc_127
loc_126:
		mov	cx,23h
		cmp	ax,17h
		jb	loc_127			; Jump if below
		cmp	ax,1Ch
		jb	loc_129			; Jump if below
		mov	cx,21h
loc_127:
		mov	word ptr cs:data_55e,0

locloop_128:
		mov	ah,ds:data_40e[si]
		mov	cs:data_54e,ax
		mov	ah,byte ptr data_20[si]
		mov	cs:data_53e,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_128		; Loop if cx > 0

		retn
loc_129:
		mov	cx,21h
		mov	word ptr cs:data_55e,0

locloop_130:
		mov	ah,ds:data_40e[si]
		mov	cs:data_54e,ax
		mov	ah,byte ptr data_20[si]
		mov	cs:data_53e,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_130		; Loop if cx > 0

		mov	ah,ds:data_40e[si]
		mov	cs:data_54e,ax
		mov	ah,byte ptr data_20[si]
		mov	cs:data_53e,ax
		lodsb				; String [si] to al
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		and	ax,0F0FFh
		and	word ptr es:[di],0F00h
		or	es:[di],ax
		retn
stats_multiply_4		endp

			                        ;* No entry point to code
		push	ds
		mov	ds:data_63e,di
		mov	ds:data_64e,es
		mov	ax,0B800h
		mov	es,ax
		mov	ds,cs:data_64e
		mov	cx,39h

locloop_131:
		mov	byte ptr cs:data_71e,0
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,39h
		add	ax,ax
		call	stats_fill_buf
		pop	ax
		push	ax
		add	ax,ax
		dec	ax
		call	stats_fill_buf
loc_132:
		cmp	byte ptr cs:data_71e,4
		jb	loc_132			; Jump if below
		pop	cx
		loop	locloop_131		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_fill_buf		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,3CDh
		add	ax,cs:data_63e
		mov	si,ax
		add	bl,14h
		mov	bh,21h			; '!'
		call	extract_bits_2
		mov	di,ax
		pop	ax
		cmp	ax,5Eh
		mov	cx,2Fh
		jnc	loc_134			; Jump if carry=0
		mov	cx,7
		mov	word ptr cs:data_55e,0

locloop_133:
		mov	ax,ds:data_40e[si]
		xchg	ah,al
		mov	cs:data_54e,ax
		mov	ax,data_20[si]
		xchg	ah,al
		mov	cs:data_53e,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_52e,ax
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		call	stats_process_loop_4
		stosw				; Store ax to es:[di]
		loop	locloop_133		; Loop if cx > 0

		mov	cx,21h
loc_134:
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
stats_fill_buf		endp

			                        ;* No entry point to code
		push	ax
		call	extract_bits_2
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		pop	ax
		mov	ah,al
		mov	cx,8

locloop_135:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_136			; Jump if below
		add	di,80A0h
loc_136:
		loop	locloop_135		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		dec	ax
		mov	cx,100h
		mul	cx			; dx:ax = reg * ax
		add	ax,41E4h
		mov	cs:data_51e,ax
		retn
		db	 00h, 01h, 04h, 05h, 07h, 07h
		db	 07h, 07h, 08h, 07h, 04h, 05h
		db	 07h, 07h, 07h, 07h, 01h, 09h
		db	 05h, 05h, 09h, 09h, 09h, 09h
		db	 01h, 09h, 05h, 05h, 09h, 09h
		db	 09h, 09h, 04h, 05h, 0Ch, 0Dh
		db	 0Ch, 0Ch, 0Ch, 0Ch, 04h, 0Ch
		db	 0Ch, 0Dh, 0Ch, 0Ch, 0Ch, 0Ch
		db	 05h, 05h, 0Dh, 0Dh, 0Dh, 0Dh
		db	 0Dh, 0Dh, 05h
		db	7 dup (0Dh)
		db	 07h, 09h, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 0Fh, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 07h, 09h
		db	 0Ch, 0Dh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 07h, 0Fh, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 09h, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 07h, 0Fh
		db	 0Ch, 0Dh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 07h, 09h, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 0Fh, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 00h, 01h
		db	 04h, 05h, 07h, 07h, 07h, 07h
		db	 08h, 07h, 04h, 05h, 07h, 07h
		db	 07h, 07h, 07h, 09h, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 07h, 0Fh
		db	 0Ch, 0Dh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 04h, 05h, 0Ch, 0Dh, 0Ch, 0Ch
		db	 0Ch, 0Ch, 04h, 0Ch, 0Ch, 0Dh
		db	 0Ch, 0Ch, 0Ch, 0Ch, 05h, 05h
		db	 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh
		db	 05h
		db	7 dup (0Dh)
		db	 07h, 09h, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 0Fh, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 07h, 09h
		db	 0Ch, 0Dh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 07h, 0Fh, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 09h, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 07h, 0Fh
		db	 0Ch, 0Dh, 0Fh, 0Fh, 0Fh, 0Fh
		db	 07h, 09h, 0Ch, 0Dh, 0Fh, 0Fh
		db	 0Fh, 0Fh, 07h, 0Fh, 0Ch, 0Dh
		db	 0Fh, 0Fh, 0Fh, 0Fh, 00h, 01h
		db	 04h, 05h, 00h, 03h, 06h, 07h
		db	 08h, 07h, 04h, 05h, 02h, 03h
		db	 06h, 08h, 01h, 09h, 05h, 05h
		db	 01h, 09h, 02h, 09h, 01h, 09h
		db	 05h, 05h, 03h, 0Bh, 05h, 09h
		db	 04h, 05h, 0Ch, 0Dh, 04h, 0Dh
		db	 06h, 0Ch, 04h, 0Ch, 0Ch, 0Dh
		db	 0Dh, 0Dh, 06h, 0Ch, 05h, 05h
		db	 0Dh, 0Dh, 05h, 0Dh, 06h, 0Dh
		db	 05h, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh
		db	 06h, 0Dh, 00h, 01h, 04h, 05h
		db	 00h, 03h, 06h, 07h, 00h, 07h
		db	 04h, 05h, 02h, 03h, 06h, 08h
		db	 03h, 09h, 0Dh, 0Dh, 03h, 0Bh
		db	 0Ah, 0Bh, 03h, 0Ah, 0Dh, 0Dh
		db	 0Ah, 0Bh, 0Ah, 0Bh, 06h, 02h
		db	 06h, 06h, 06h, 0Ah, 0Eh, 0Eh
		db	 06h, 0Eh, 06h, 06h, 0Ah, 0Ah
		db	 0Eh, 0Eh, 07h, 09h, 0Ch, 0Dh
		db	 07h, 0Bh, 0Eh, 0Fh, 07h, 0Fh
		db	 0Ch, 0Dh, 0Ah, 0Bh, 0Eh, 0Fh
		db	 08h, 01h, 04h, 05h, 00h, 03h
		db	 06h, 07h, 07h, 07h, 04h, 05h
		db	 02h, 03h, 06h, 07h, 07h, 09h
		db	 0Ch, 0Dh, 07h, 0Ah, 0Eh, 0Fh
		db	 07h, 0Fh, 0Ch, 0Dh, 0Ah, 0Ah
		db	 0Eh, 0Fh, 04h, 05h, 0Ch, 0Dh
		db	 04h, 0Dh, 06h, 0Ch, 04h, 0Ch
		db	 0Ch, 0Dh, 05h, 0Ch, 06h, 0Ch
		db	 05h, 05h, 0Dh, 0Dh, 05h, 0Dh
		db	 06h, 0Dh, 05h, 0Dh, 0Dh, 0Dh
		db	 0Dh, 0Dh, 06h, 0Dh, 02h, 03h
		db	 0Dh, 0Dh, 02h, 0Ah, 0Ah, 0Ah
		db	 02h, 0Ah, 05h, 0Dh, 0Dh, 0Ah
		db	 0Ah, 0Ah, 03h, 09h, 0Dh, 0Dh
		db	 03h, 0Bh, 0Ah, 0Bh, 03h, 0Ah
		db	 0Dh, 0Dh, 0Ah, 0Bh, 0Ah, 0Bh
		db	 06h, 02h, 06h, 06h, 06h, 0Ah
		db	 0Eh, 0Eh, 06h, 0Eh, 06h, 06h
		db	 0Ah, 0Ah, 0Eh, 0Eh, 07h, 09h
		db	 0Ch, 0Dh, 07h, 0Bh, 0Eh, 0Fh
		db	 07h, 0Fh, 0Ch, 0Dh, 0Ah, 0Bh
		db	 0Eh, 0Fh, 00h, 04h, 01h, 07h
		db	 01h, 07h, 00h, 07h
		db	8 dup (0)
		db	 04h, 0Ch, 05h, 0Ch, 05h, 0Ch
		db	 04h, 0Ch, 00h
		db	7 dup (0)
		db	1, 5, 9, 3, 9, 3
		db	1
		db	9
		db	8 dup (0)
		db	 07h, 0Ch, 03h, 0Fh, 03h, 0Fh
		db	 07h, 0Fh
		db	8 dup (0)
		db	1, 5, 9, 3, 9, 3
		db	1
		db	9
		db	8 dup (0)
		db	 07h, 0Ch, 03h, 0Fh, 03h, 0Fh
		db	 07h, 0Fh
		db	9 dup (0)
		db	4, 1, 7, 1, 7, 0
		db	7
		db	8 dup (0)
		db	 07h, 0Ch, 03h, 0Fh, 03h, 0Fh
		db	 07h, 0Fh
		db	137 dup (0)
		db	1, 4, 5, 3, 3
data_20		dw	706h			; Data table (indexed access)
		db	 08h, 01h, 04h, 05h, 03h, 03h
		db	 06h, 07h, 01h, 09h, 05h, 05h
		db	 09h, 09h, 02h, 03h, 01h, 09h
		db	 05h, 05h, 09h, 09h, 02h, 03h
		db	 04h, 05h, 0Ch, 0Dh, 0Dh, 0Dh
		db	 06h, 0Ch, 04h, 05h, 0Ch, 0Dh
		db	 0Dh, 0Dh, 06h, 0Ch, 05h, 05h
		db	 0Dh, 0Dh, 0Dh, 0Dh, 0Ch, 0Dh
		db	 05h, 05h, 0Dh, 0Dh, 0Dh, 0Dh
		db	 0Ch, 0Dh, 03h, 09h, 0Dh, 0Dh
		db	 0Bh, 0Bh, 0Ah, 0Bh, 03h, 09h
		db	 0Dh, 0Dh, 0Bh, 0Bh, 0Ah, 0Bh
		db	 03h, 09h, 0Dh, 0Dh, 0Bh, 0Bh
		db	 0Ah, 0Bh, 03h, 09h, 0Dh, 0Dh
		db	 0Bh, 0Bh, 0Ah, 0Bh, 06h, 02h
		db	 06h, 0Ch, 0Ah, 0Ah, 0Eh, 0Eh
		db	 06h, 02h, 06h, 0Ch, 0Ah, 0Ah
		db	 0Eh, 0Eh, 07h, 03h, 0Ch, 0Dh
		db	 0Bh, 0Bh, 0Eh, 0Fh, 07h, 03h
		db	 0Ch, 0Dh, 0Bh, 0Bh, 0Eh, 0Fh
		db	 08h, 01h, 04h, 05h, 03h, 03h
		db	 06h, 07h, 08h, 01h, 04h, 05h
		db	 03h, 03h, 07h, 07h, 01h, 09h
		db	 05h, 05h, 09h, 09h, 02h, 03h
		db	 01h, 09h, 05h, 05h, 09h, 09h
		db	 02h, 03h, 04h, 05h, 0Ch, 0Dh
		db	 0Dh, 0Dh, 06h, 0Ch, 04h, 05h
		db	 0Ch, 0Dh, 0Dh, 0Dh, 06h, 0Ch
		db	 05h, 05h, 0Dh, 0Dh, 0Dh, 0Dh
		db	 0Ch, 0Dh, 05h, 05h, 0Dh, 0Dh
		db	 0Dh, 0Dh, 0Ch, 0Dh, 03h, 09h
		db	 0Dh, 0Dh, 0Bh, 0Bh, 0Ah, 0Bh
		db	 03h, 09h, 0Dh, 0Dh, 0Bh, 0Bh
		db	 0Ah, 0Bh, 03h, 09h, 0Dh, 0Dh
		db	 0Bh, 0Bh, 0Ah, 0Bh, 03h, 09h
		db	 0Dh, 0Dh, 0Bh, 0Bh, 0Ah, 0Bh
		db	 06h, 02h, 06h, 0Ch, 0Ah, 0Ah
		db	 0Eh, 0Eh, 06h, 02h, 06h, 0Ch
		db	 0Ah, 0Ah, 0Eh, 0Eh, 07h, 03h
		db	 0Ch, 0Dh, 0Bh, 0Bh, 0Eh, 0Fh
		db	 07h, 03h, 0Ch, 0Dh, 0Bh, 0Bh
		db	 0Eh, 0Fh, 00h, 01h, 04h, 03h
		db	 02h, 03h, 06h, 07h
		db	8 dup (0)
		db	1, 9, 5, 9, 2, 9
		db	2, 3, 0
		db	7 dup (0)
		db	 04h, 05h, 0Ch, 05h, 08h, 05h
		db	 06h, 0Ch, 00h
		db	7 dup (0)
		db	 03h, 09h, 05h, 0Bh, 0Ah, 0Bh
		db	 07h, 0Bh, 00h
		db	7 dup (0)
		db	 02h, 02h, 08h, 0Ah, 0Ah, 0Ah
		db	 0Eh, 07h
		db	8 dup (0)
		db	 03h, 09h, 05h, 0Bh, 0Ah, 0Bh
		db	 07h, 0Bh, 00h
		db	7 dup (0)
		db	 06h, 02h, 06h, 07h, 0Eh, 07h
		db	 0Eh, 0Eh
		db	8 dup (0)
		db	 07h, 03h, 0Ch, 0Bh, 07h, 0Bh
		db	 0Eh, 0Fh, 00h
		db	136 dup (0)
		db	 01h, 04h, 05h, 00h, 03h, 06h
		db	 07h, 08h, 07h, 04h, 05h, 02h
		db	 03h, 06h, 08h, 01h, 09h, 05h
		db	 05h, 01h, 09h, 02h, 09h, 01h
		db	 09h, 05h, 05h, 03h, 0Bh, 05h
		db	 09h, 04h, 05h, 0Ch, 0Dh, 04h
		db	 08h, 06h, 0Ch, 04h, 0Ch, 0Ch
		db	 0Dh, 0Dh, 0Dh, 06h, 0Ch, 05h
		db	 05h, 0Dh, 0Dh, 05h, 08h, 06h
		db	 0Dh, 05h, 0Dh, 0Dh, 0Dh, 0Dh
		db	 0Dh, 06h, 0Dh, 00h, 01h, 04h
		db	 05h, 00h, 03h, 06h, 07h, 00h
		db	 07h, 04h, 05h, 02h, 03h, 06h
		db	 08h, 03h, 09h, 08h, 08h, 03h
		db	 0Bh, 0Ah, 0Bh, 03h, 0Ah, 0Dh
		db	 0Dh, 0Ah, 0Bh, 0Ah, 0Bh, 06h
		db	 02h, 06h, 06h, 06h, 0Ah, 0Eh
		db	 0Eh, 06h, 0Eh, 06h, 06h, 0Ah
		db	 0Ah, 0Eh, 0Eh, 07h, 09h, 0Ch
		db	 0Dh, 07h, 0Bh, 0Eh, 0Fh, 07h
		db	 0Fh, 0Ch, 0Dh, 0Ah, 0Bh, 0Eh
		db	 0Fh, 08h, 01h, 04h, 05h, 00h
		db	 03h, 06h, 07h, 07h, 07h, 04h
		db	 05h, 02h, 03h, 06h, 07h, 07h
		db	 09h, 0Ch, 0Dh, 07h, 0Ah, 0Eh
		db	 0Fh, 07h, 0Fh, 0Ch, 0Dh, 0Ah
		db	 0Ah, 0Eh, 0Fh, 04h, 05h, 0Ch
		db	 0Dh, 04h, 0Dh, 06h, 0Ch, 04h
		db	 0Ch, 0Ch, 0Dh, 05h, 0Ch, 06h
		db	 0Ch, 05h, 05h, 0Dh, 0Dh, 05h
		db	 0Dh, 06h, 0Dh, 05h, 0Dh, 0Dh
		db	 0Dh, 0Dh, 0Dh, 06h, 0Dh, 02h
		db	 03h, 0Dh, 0Dh, 02h, 0Ah, 0Ah
		db	 0Ah, 02h, 0Ah, 05h, 0Dh, 0Dh
		db	 0Ah, 0Ah, 0Ah, 03h, 09h, 0Dh
		db	 0Dh, 03h, 0Bh, 0Ah, 0Bh, 03h
		db	 0Ah, 0Dh, 0Dh, 0Ah, 0Bh, 0Ah
		db	 0Bh, 06h, 02h, 06h, 06h, 06h
		db	 0Ah, 0Eh, 0Eh, 06h, 0Eh, 06h
		db	 06h, 0Ah, 0Ah, 0Eh, 0Eh, 07h
		db	 09h, 0Ch, 0Dh, 07h, 0Bh, 0Eh
		db	 0Fh, 07h, 0Fh, 0Ch, 0Dh, 0Ah
		db	 0Bh, 0Eh, 0Fh, 00h, 01h, 04h
		db	 05h, 02h, 03h, 06h, 07h, 08h
		db	 01h, 04h, 05h, 03h, 03h, 06h
		db	 07h, 01h, 09h, 05h, 05h, 03h
		db	 09h, 02h, 03h, 01h, 09h, 05h
		db	 05h, 09h, 09h, 02h, 03h, 04h
		db	 05h, 0Ch, 0Dh, 06h, 08h, 06h
		db	 0Ch, 04h, 05h, 0Ch, 0Dh, 08h
		db	 08h, 06h, 0Ch, 05h, 05h, 0Dh
		db	 0Dh, 08h, 08h, 0Ch, 0Dh, 05h
		db	 05h, 0Dh, 0Dh, 08h, 08h, 0Ch
		db	 0Dh, 02h, 03h, 06h, 08h, 0Ah
		db	 0Bh, 0Eh, 0Ah, 02h, 03h, 06h
		db	 08h, 0Ah, 0Bh, 0Eh, 0Ah, 03h
		db	 09h, 08h, 08h, 0Bh, 0Bh, 0Ah
		db	 0Bh, 03h, 09h, 08h, 08h, 0Bh
		db	 0Bh, 0Ah, 0Bh, 06h, 02h, 06h
		db	 0Ch, 0Eh, 0Ah, 0Eh, 0Eh, 06h
		db	 02h, 06h, 0Ch, 0Ah, 0Ah, 0Eh
		db	 0Eh, 07h, 03h, 0Ch, 0Dh, 0Ah
		db	 0Bh, 0Eh, 0Fh, 07h, 03h, 0Ch
		db	 0Dh, 0Bh, 0Bh, 0Eh, 0Fh, 08h
		db	 01h, 04h, 05h, 02h, 03h, 06h
		db	 07h, 08h, 01h, 04h, 05h, 03h
		db	 03h, 07h, 07h, 01h, 09h, 05h
		db	 05h, 03h, 09h, 02h, 03h, 01h
		db	 09h, 05h, 05h, 09h, 09h, 02h
		db	 03h, 04h, 05h, 0Ch, 0Dh, 06h
		db	 08h, 06h, 0Ch, 04h, 05h, 0Ch
		db	 0Dh, 08h, 08h, 06h, 0Ch, 05h
		db	 05h, 0Dh, 0Dh, 08h, 08h, 0Ch
		db	 0Dh, 05h, 05h, 0Dh, 0Dh, 08h
		db	 08h, 0Ch, 0Dh, 03h, 09h, 08h
		db	 08h, 0Ah, 0Bh, 0Ah, 0Bh, 03h
		db	 09h, 08h, 08h, 0Bh, 0Bh, 0Ah
		db	 0Bh, 03h, 09h, 08h, 08h, 0Bh
		db	 0Bh, 0Ah, 0Bh, 03h, 09h, 08h
		db	 08h, 0Bh, 0Bh, 0Ah, 0Bh, 06h
		db	 02h, 06h, 0Ch, 0Eh, 0Ah, 0Eh
		db	 0Eh, 06h, 02h, 06h, 0Ch, 0Ah
		db	 0Ah, 0Eh, 0Eh, 07h, 03h, 0Ch
		db	 0Dh, 0Ah, 0Bh, 0Eh, 0Fh, 07h
		db	 03h, 0Ch, 0Dh, 0Bh, 0Bh, 0Eh
		db	 0Fh, 00h, 01h, 04h, 02h, 00h
		db	 03h, 06h, 07h, 08h, 07h, 04h
		db	 05h, 02h, 03h, 06h, 08h, 01h
		db	 09h, 05h, 03h, 01h, 09h, 02h
		db	 09h, 01h, 09h, 05h, 05h, 03h
		db	 0Bh, 05h, 09h, 04h, 05h, 0Ch
		db	 06h, 04h, 08h, 06h, 0Ch, 04h
		db	 0Ch, 0Ch, 08h, 0Dh, 0Dh, 06h
		db	 0Ch, 02h, 03h, 06h, 0Ah, 02h
		db	 0Bh, 0Eh, 0Ah, 02h, 03h, 06h
		db	 08h, 0Ah, 0Bh, 0Eh, 0Ah, 00h
		db	 01h, 04h, 02h, 00h, 03h, 06h
		db	 07h, 00h, 07h, 04h, 05h, 02h
		db	 03h, 06h, 08h, 03h, 09h, 08h
		db	 0Bh, 03h, 0Bh, 0Ah, 0Bh, 03h
		db	 0Ah, 08h, 08h, 0Ah, 0Bh, 0Ah
		db	 0Bh, 06h, 02h, 06h, 0Eh, 06h
		db	 0Ah, 0Eh, 0Eh, 06h, 0Eh, 06h
		db	 06h, 0Ah, 0Ah, 0Eh, 0Eh, 07h
		db	 09h, 0Ch, 0Ah, 07h, 0Bh, 0Eh
		db	 0Fh, 07h, 0Fh, 0Ch, 0Dh, 0Ah
		db	 0Bh, 0Eh, 0Fh, 08h, 01h, 04h
		db	 02h, 00h, 03h, 06h, 07h, 07h
		db	 07h, 04h, 05h, 02h, 03h, 06h
		db	 07h, 07h, 09h, 0Ch, 03h, 07h
		db	 0Ah, 0Eh, 0Fh, 07h, 0Fh, 0Ch
		db	 0Dh, 0Ah, 0Ah, 0Eh, 0Fh, 04h
		db	 05h, 0Ch, 06h, 04h, 08h, 06h
		db	 0Ch, 04h, 0Ch, 0Ch, 08h, 05h
		db	 0Ch, 06h, 0Ch, 05h, 05h, 0Dh
		db	 08h, 05h, 08h, 06h, 0Dh, 05h
		db	 0Dh, 0Dh, 08h, 0Dh, 0Dh, 06h
		db	 0Dh, 02h, 03h, 0Dh, 0Ah, 02h
		db	 0Ah, 0Ah, 0Ah, 02h, 0Ah, 05h
		db	 0Dh, 0Dh, 0Ah, 0Ah, 0Ah, 03h
		db	 09h, 08h, 0Bh, 03h, 0Bh, 0Ah
		db	 0Bh, 03h, 0Ah, 08h, 08h, 0Ah
		db	 0Bh, 0Ah, 0Bh, 06h, 02h, 06h
		db	 0Eh, 06h, 0Ah, 0Eh, 0Eh, 06h
		db	 0Eh, 06h, 06h, 0Ah, 0Ah, 0Eh
		db	 0Eh, 07h, 09h, 0Ch, 0Ah, 07h
		db	 0Bh, 0Eh, 0Fh, 07h, 0Fh, 0Ch
		db	 0Dh, 0Ah, 0Bh, 0Eh, 0Fh, 00h
		db	 01h, 04h, 04h, 02h, 04h, 06h
		db	 07h
		db	8 dup (0)
		db	 01h, 09h, 05h, 0Ch, 02h, 0Ch
		db	 02h, 03h, 00h
		db	7 dup (0)
		db	 04h, 05h, 0Ch, 05h, 08h, 05h
		db	 06h, 0Ch, 00h
		db	7 dup (0)
		db	 04h, 0Ch, 05h, 0Ch, 0Dh, 0Ch
		db	 07h, 0Ch, 00h
		db	7 dup (0)
		db	 02h, 02h, 08h, 0Dh, 0Ah, 0Dh
		db	 0Eh, 07h
		db	8 dup (0)
		db	 04h, 0Ch, 05h, 0Ch, 0Dh, 0Ch
		db	 07h, 0Ch, 00h
		db	7 dup (0)
		db	 06h, 02h, 06h, 07h, 0Eh, 07h
		db	 0Eh, 0Eh
		db	8 dup (0)
		db	 07h, 03h, 0Ch, 0Ch, 07h, 0Ch
		db	 0Eh, 0Fh
		db	136 dup (0)

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_process_loop_4		proc	near
		push	cx
		push	si
		mov	si,cs:data_51e
		mov	cx,4

locloop_137:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_55e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_54e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_53e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_52e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_55e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_54e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_53e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_52e,1	; Rotate
		adc	bx,bx
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		or	al,cs:[bx+si]
		loop	locloop_137		; Loop if cx > 0

		xchg	ah,al
		pop	si
		pop	cx
		retn
stats_process_loop_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

stats_func_20		proc	near
		rol	word ptr cs:data_56e,1	; Rotate
		sbb	dl,dl
		rol	word ptr cs:data_56e,1	; Rotate
		sbb	dh,dh
		or	dl,dh
		and	dl,0F0h
		rol	word ptr cs:data_56e,1	; Rotate
		sbb	al,al
		rol	word ptr cs:data_56e,1	; Rotate
		sbb	dh,dh
		or	al,dh
		and	al,0Fh
		or	al,dl
		rol	word ptr cs:data_56e,1	; Rotate
		sbb	dl,dl
		rol	word ptr cs:data_56e,1	; Rotate
		sbb	dh,dh
		or	dl,dh
		and	dl,0F0h
		rol	word ptr cs:data_56e,1	; Rotate
		sbb	ah,ah
		rol	word ptr cs:data_56e,1	; Rotate
		sbb	dh,dh
		or	ah,dh
		and	ah,0Fh
		or	ah,dl
		retn
stats_func_20		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,0B800h
		mov	ds,ax
		xor	si,si			; Zero register
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,data_73e
		mov	cx,0C8h

locloop_138:
		push	cx
		push	si
		mov	cx,50h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,8000h
		jb	loc_139			; Jump if below
		add	si,80A0h
loc_139:
		pop	cx
		loop	locloop_138		; Loop if cx > 0

		pop	ds
		xor	ax,ax			; Zero register
		mov	di,data_76e
		mov	cx,4000h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
			                        ;* No entry point to code
		push	bx
		mov	bl,ah
		xor	bh,bh			; Zero register
		mov	ah,cs:data_50e[bx]
		pop	bx
		jmp	word ptr cs:data_38
		db	0, 5, 2, 7, 3, 4
		db	6, 1

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

extract_bits_2		proc	near
		add	bh,bh
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
extract_bits_2		endp

		db	0C3h
		db	1057 dup (0)
data_38		dw	0
		db	44 dup (0)
data_39		db	0			; Data table (indexed access)
		db	588 dup (0)

seg_a		ends



		end	start
