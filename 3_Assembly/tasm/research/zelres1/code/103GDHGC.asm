
PAGE  59,132

;==========================================================================
;
;  IMAGE_DECODE - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	0
data_2e		equ	240h
data_54e	equ	2022h			;*
data_55e	equ	2050h			;*
data_56e	equ	29DCh			;*
data_57e	equ	2A80h			;*
data_58e	equ	32BBh			;*
data_59e	equ	32CBh			;*
data_60e	equ	3645h			;*
data_61e	equ	3647h			;*
data_62e	equ	3ACBh			;*
data_63e	equ	3B8Fh			;*
data_64e	equ	3BC2h			;*
data_65e	equ	44F5h			;*
data_66e	equ	4C23h			;*
data_67e	equ	4C52h			;*
data_68e	equ	4C54h			;*
data_69e	equ	4C56h			;*
data_70e	equ	4C58h			;*
data_71e	equ	4C5Ah			;*
data_72e	equ	4C5Ch			;*
data_73e	equ	4C5Dh			;*
data_74e	equ	4C5Eh			;*
data_75e	equ	4C5Fh			;*
data_76e	equ	4C60h			;*
data_78e	equ	4C62h			;*
data_79e	equ	4C64h			;*
data_80e	equ	4F86h			;*
data_81e	equ	5500h			;*
data_82e	equ	5FA6h			;*
data_83e	equ	0A000h			;*
data_84e	equ	0A05Ah			;*
data_85e	equ	0F500h			;*
data_86e	equ	0FF1Ah			;*
data_87e	equ	0FF2Ch			;*
data_88e	equ	0			;*
data_89e	equ	1A6Eh			;*
data_90e	equ	1A8Eh			;*
data_91e	equ	4000h			;*
data_92e	equ	4050h			;*
data_93e	equ	0			;*
data_94e	equ	232Fh
data_95e	equ	6000h
data_96e	equ	0A059h
data_97e	equ	0A05Ah

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_03		proc	far

start:
		retf	1Fh			; Return far
		db	 00h, 2Bh, 4Ch, 32h, 30h, 78h
		db	 30h,0C2h, 30h, 7Ah, 42h,0D8h
		db	 4Bh,0DBh, 32h, 33h, 33h,0CAh
		db	 33h, 4Ah, 34h, 65h, 36h,0B1h
		db	 36h, 2Bh, 4Ch,0DAh, 30h,0FDh
		db	 36h, 7Fh, 37h, 7Dh, 38h,0C5h
		db	 3Bh, 30h, 3Dh, 49h, 3Eh, 9Fh
		db	 3Eh, 9Ch, 40h,0A6h, 41h, 56h
		db	 42h, 13h, 4Ch, 50h, 53h, 51h
		db	 1Eh, 8Ah,0C5h,0F6h,0E1h, 8Bh
		db	0E8h, 06h, 1Fh, 8Bh,0F7h, 8Ch
		db	0C8h, 05h, 00h, 30h, 8Eh,0C0h
		db	0BFh, 00h, 00h, 2Eh,0C7h, 06h
		db	 56h, 4Ch, 00h, 00h, 2Eh,0C7h
		db	 06h, 58h, 4Ch, 00h, 00h, 8Bh
		db	0CDh,0D1h,0E9h

locloop_1:
		mov	ax,ds:[bp+si]
		mov	cs:data_71e,ax
		lodsw				; String [si] to ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
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
		mov	word ptr cs:data_71e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_2:
		add	bp,bp
		mov	ax,ds:[bp+si]
		mov	cs:data_70e,ax
		shr	bp,1			; Shift w/zeros fill
		mov	ax,ds:[bp+si]
		mov	cs:data_69e,ax
		lodsw				; String [si] to ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
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
		call	math_calc
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_76e,32A6h
		call	imgdec_func_1
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
		mov	word ptr cs:data_71e,0
		mov	word ptr cs:data_68e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_3:
		mov	ax,ds:[bp+si]
		mov	cs:data_70e,ax
		lodsw				; String [si] to ax
		mov	cs:data_69e,ax
		call	imgdec_process_loop_5
		stosw				; Store ax to es:[di]
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
		call	math_calc
		mov	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_76e,3256h
		mov	byte ptr cs:data_75e,0
		or	al,al			; Zero ?
		jnz	loc_4			; Jump if not zero
		call	imgdec_func_1
loc_4:
		mov	byte ptr cs:data_75e,0FFh
		call	imgdec_func_1
		pop	ds
		retn
loc_5:
		push	ds
		push	ax
		push	es
		push	di
		call	math_calc
		add	di,ax
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_76e,3219h
		mov	byte ptr cs:data_75e,0
		or	al,al			; Zero ?
		jnz	loc_6			; Jump if not zero
		call	imgdec_func_1
loc_6:
		mov	byte ptr cs:data_75e,0FFh
		call	imgdec_func_1
		pop	ds
		retn

zr1_03		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_func_1		proc	near
		mov	byte ptr cs:data_73e,0
		mov	ax,0B000h
		mov	es,ax
		mov	bp,8
loc_7:
		mov	al,cs:data_73e
		mov	cs:data_72e,al
		mov	byte ptr cs:data_86e,0
		push	cx
		push	si
		push	di
loc_8:
		mov	bl,cs:data_72e
		and	bx,7
		add	bx,bx
		mov	bx,cs:data_58e[bx]
		push	bx
		call	word ptr cs:data_76e
		pop	bx
		inc	byte ptr cs:data_72e
		add	di,2000h
		cmp	di,6000h
		jb	loc_9			; Jump if below
		call	word ptr cs:data_76e
		add	di,0A05Ah
loc_9:
		mov	al,ch
		xor	ah,ah			; Zero register
		add	si,ax
		dec	cl
		jz	loc_11			; Jump if zero
		mov	bl,cs:data_72e
		and	bx,7
		add	bx,bx
		mov	bx,cs:data_59e[bx]
		push	bx
		call	word ptr cs:data_76e
		pop	bx
		inc	byte ptr cs:data_72e
		add	di,2000h
		cmp	di,6000h
		jb	loc_10			; Jump if below
		call	word ptr cs:data_76e
		add	di,0A05Ah
loc_10:
		mov	al,ch
		xor	ah,ah			; Zero register
		add	si,ax
		dec	cl
		jnz	loc_8			; Jump if not zero
loc_11:
		pop	di
		pop	si
		pop	cx
		inc	byte ptr cs:data_73e
loc_12:
		cmp	byte ptr cs:data_86e,14h
		jb	loc_12			; Jump if below
		dec	bp
		jz	loc_ret_13		; Jump if zero
		jmp	loc_7

loc_ret_13:
		retn
imgdec_func_1		endp

			                        ;* No entry point to code
		test	byte ptr cs:data_75e,0FFh
		jz	loc_15			; Jump if zero
		push	si
		push	di
		push	cx
		mov	dx,bx
		not	bx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_14:
		and	es:[di],bl
		lodsb				; String [si] to al
		and	al,dl
		or	es:[di],al
		inc	di
		xchg	dh,dl
		xchg	bh,bl
		loop	locloop_14		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
loc_15:
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_16:
		lodsb				; String [si] to al
		and	al,bl
		or	es:[di],al
		inc	di
		xchg	bh,bl
		loop	locloop_16		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
			                        ;* No entry point to code
		test	byte ptr cs:data_75e,0FFh
		jz	loc_20			; Jump if zero
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_17:
		push	cx
		lodsb				; String [si] to al
		mov	ah,al
		mov	dl,3
		mov	cx,4

locloop_18:
		test	ah,dl
		jz	loc_19			; Jump if zero
		or	ah,dl
loc_19:
		add	dl,dl
		add	dl,dl
		loop	locloop_18		; Loop if cx > 0

		and	ah,bl
		not	ah
		and	es:[di],ah
		and	al,bl
		or	es:[di],al
		inc	di
		xchg	bh,bl
		pop	cx
		loop	locloop_17		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
loc_20:
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_21:
		lodsb				; String [si] to al
		and	al,bl
		or	es:[di],al
		inc	di
		xchg	bh,bl
		loop	locloop_21		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
			                        ;* No entry point to code
		push	di
		push	cx
		not	bx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_22:
		and	es:[di],bl
		inc	di
		xchg	dh,dl
		xchg	bh,bl
		loop	locloop_22		; Loop if cx > 0

		pop	cx
		pop	di
		retn
		db	 00h,0C0h, 00h, 0Ch,0C0h, 00h
		db	 0Ch, 00h, 00h, 30h, 00h, 03h
		db	 30h, 00h, 03h, 00h, 03h, 00h
		db	 30h, 00h, 00h, 03h, 00h, 30h
		db	 0Ch, 00h,0C0h, 00h, 00h, 0Ch
		db	 00h,0C0h, 0Eh, 07h,0BFh, 66h
		db	 4Ch, 33h,0C0h,0B9h, 90h, 01h
		db	0F3h,0ABh,0BFh
		db	 66h, 4Ch
loc_23:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_24			; Jump if not equal
		retn
loc_24:
		sub	al,20h			; ' '
		jnc	loc_25			; Jump if carry=0
		retn
loc_25:
		jz	loc_27			; Jump if zero
		push	si
		push	di
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:data_85e
		mov	si,ax
		mov	cx,8

locloop_26:
		push	cx
		lodsb				; String [si] to al
		call	imgdec_process_loop
		mov	es:[di],dx
		add	di,50h
		pop	cx
		loop	locloop_26		; Loop if cx > 0

		pop	di
		pop	si
loc_27:
		add	di,2
		jmp	short loc_23

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_process_loop		proc	near
		mov	cx,8

locloop_28:
		add	al,al
		adc	bx,bx
		add	bx,bx
		loop	locloop_28		; Loop if cx > 0

		mov	dx,bx
		shr	dx,1			; Shift w/zeros fill
		or	dx,bx
		xchg	dh,dl
		retn
imgdec_process_loop		endp

			                        ;* No entry point to code
		push	ds
		push	cx
		push	bx
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,4C66h
		mov	si,ax
		add	cl,bl
		mov	al,50h			; 'P'
		mul	cl			; ax = reg * al
		add	ax,4000h
		push	ax
		push	si
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		push	ds
		pop	es
		mov	di,data_91e
		mov	si,data_92e
		mov	cx,1FD8h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		push	cs
		pop	ds
		mov	cx,28h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	bx
		push	bx
		call	math_calc
		mov	di,ax
		pop	bx
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	si,ax
		add	si,0
		mov	bp,ax
		add	bp,data_91e
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	ax,0B000h
		mov	es,ax
		pop	cx
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

locloop_29:
		push	cx
		call	imgdec_process_loop_2
		add	di,2000h
		cmp	di,6000h
		jb	loc_30			; Jump if below
		call	imgdec_process_loop_2
		add	di,data_97e
loc_30:
		add	bp,bx
		add	si,bx
		pop	cx
		loop	locloop_29		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_process_loop_2		proc	near
		push	di
		push	si
		push	bp
		mov	cx,bx
		shr	cx,1			; Shift w/zeros fill

locloop_31:
		lodsw				; String [si] to ax
		or	ax,ds:[bp]
		stosw				; Store ax to es:[di]
		inc	bp
		inc	bp
		loop	locloop_31		; Loop if cx > 0

		pop	bp
		pop	si
		pop	di
		retn
imgdec_process_loop_2		endp

loc_32:
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
		mov	word ptr cs:data_71e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_33:
		add	bp,bp
		mov	ax,ds:[bp+si]
		mov	cs:data_70e,ax
		shr	bp,1			; Shift w/zeros fill
		mov	ax,ds:[bp+si]
		mov	cs:data_69e,ax
		lodsw				; String [si] to ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		stosw				; Store ax to es:[di]
		loop	locloop_33		; Loop if cx > 0

		pop	cx
		pop	bx
		pop	ax
		pop	ds
loc_34:
		push	ds
		call	math_calc
		mov	di,ax
		mov	si,data_93e
		push	es
		pop	ds
		mov	ax,0B000h
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

locloop_35:
		push	cx
		push	si
		push	di
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	di,2000h
		cmp	di,data_95e
		jb	loc_36			; Jump if below
		push	si
		push	di
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	di,0A05Ah
loc_36:
		add	si,bx
		pop	cx
		loop	locloop_35		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_83e
		xor	dx,dx			; Zero register
		mov	cx,9

locloop_37:
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
		add	dx,0C0h
		loop	locloop_37		; Loop if cx > 0

		mov	byte ptr ds:data_86e,0
loc_38:
		mov	si,data_83e
		mov	cx,9
loc_39:
		push	cx
		test	byte ptr [si],0FFh
		jz	loc_41			; Jump if zero
		mov	al,[si+0Dh]
		cmp	al,[si+0Eh]
		je	loc_40			; Jump if equal
		inc	byte ptr [si+0Ch]
		test	byte ptr [si+0Ch],1
		jnz	loc_40			; Jump if not zero
		inc	byte ptr [si+0Dh]
loc_40:
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	cx,ds:data_61e[bx]
		mov	[si+7],cx
		mov	al,[si+4]
		add	al,[si+0Ah]
		mov	[si+4],al
		mov	dl,al
		mov	al,[si+3]
		add	al,[si+9]
		mov	[si+3],al
		xor	dh,dh			; Zero register
		add	dx,5
		push	dx
		xor	ah,ah			; Zero register
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
		pop	dx
		add	ax,dx
		mov	[si+5],ax
		mov	di,ax
		mov	bp,[si+1]
		push	ds
		push	si
		mov	ax,0B000h
		mov	ds,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	si,di
		mov	di,bp
		call	copy_buffer
		pop	si
		pop	ds
loc_41:
		pop	cx
		add	si,0Fh
		loop	locloop_42		; Loop if cx > 0

		jmp	short loc_43

locloop_42:
		jmp	loc_39
loc_43:
		mov	si,data_83e
		mov	cx,9

locloop_44:
		push	cx
		test	byte ptr cs:[si],0FFh
		jz	loc_45			; Jump if zero
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	bp,ds:data_60e[bx]
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
		mov	ax,0B000h
		mov	es,ax
		mov	ds,cs:data_87e
		mov	si,bp
		call	imgdec_multiply
		pop	si
		pop	ds
loc_45:
		pop	cx
		add	si,0Fh
		loop	locloop_44		; Loop if cx > 0

loc_46:
		cmp	byte ptr cs:data_86e,1Eh
		jb	loc_46			; Jump if below
		mov	byte ptr cs:data_86e,0
		mov	si,data_83e
		mov	cx,9

locloop_47:
		push	cx
		mov	bp,[si+1]
		mov	di,[si+5]
		mov	cx,[si+7]
		push	ds
		push	si
		mov	ax,0B000h
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

		mov	si,data_83e
		mov	cx,9

locloop_48:
		test	byte ptr [si],0FFh
		jz	loc_49			; Jump if zero
		jmp	loc_38
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
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	si
		add	si,2000h
		cmp	si,6000h
		jb	loc_51			; Jump if below
		add	si,0A05Ah
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
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		push	si
		push	di
		push	cx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	di
		pop	si
		add	di,2000h
		cmp	di,data_95e
		jb	loc_53			; Jump if below
		push	si
		push	di
		push	cx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	di
		pop	si
		add	di,0A05Ah
loc_53:
		add	si,cx
		pop	cx
		dec	cl
		jnz	loc_52			; Jump if not zero
		pop	cx
		pop	di
		retn
copy_buffer_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_multiply		proc	near
		push	di
		push	cx
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bx,ax
		mov	word ptr cs:data_71e,0
		mov	word ptr cs:data_70e,0
loc_54:
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		call	imgdec_process_loop_3
		add	di,2000h
		cmp	di,6000h
		jb	loc_55			; Jump if below
		call	imgdec_process_loop_3
		add	di,0A05Ah
loc_55:
		add	si,cx
		pop	cx
		dec	cl
		jnz	loc_54			; Jump if not zero
		pop	cx
		pop	di
		retn
imgdec_multiply		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_process_loop_3		proc	near
		push	di
		push	si
		push	cx

locloop_56:
		xor	ah,ah			; Zero register
		mov	al,[bx+si]
		mov	cs:data_69e,ax
		lodsb				; String [si] to al
		mov	cs:data_68e,ax
		push	bx
		call	imgdec_process_loop_5
		pop	bx
		or	es:[di],al
		inc	di
		loop	locloop_56		; Loop if cx > 0

		pop	cx
		pop	si
		pop	di
		retn
imgdec_process_loop_3		endp

		db	 00h, 90h, 20h, 06h, 80h, 91h
		db	 20h, 06h, 00h, 93h, 20h, 06h
		db	 80h, 94h, 20h, 06h, 00h, 96h
		db	 18h, 04h,0C0h, 96h, 18h
data_3		dw	8004h			; Data table (indexed access)
		db	 97h, 18h, 04h, 40h, 98h, 18h
		db	 04h, 1Eh, 53h, 32h,0E4h,0BAh
		db	0C0h, 0Ch,0F7h,0E2h, 05h, 40h
		db	0ABh, 2Eh, 8Eh, 1Eh, 2Ch,0FFh
		db	 8Bh,0F0h, 8Ch,0C8h, 05h, 00h
		db	 30h, 8Eh,0C0h,0BFh, 00h, 00h
		db	 2Eh,0C7h, 06h, 5Ah, 4Ch, 00h
		db	 00h, 2Eh,0C7h, 06h, 58h, 4Ch
		db	 00h, 00h,0B9h, 30h, 03h

locloop_57:
		mov	ax,data_3[si]
		mov	cs:data_68e,ax
		lodsw				; String [si] to ax
		mov	cs:data_69e,ax
		call	imgdec_process_loop_5
		stosw				; Store ax to es:[di]
		loop	locloop_57		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,0
		mov	cx,2230h
		jmp	loc_34
			                        ;* No entry point to code
		push	ds
		push	bx
		xor	ah,ah			; Zero register
		mov	dx,480h
		mul	dx			; dx:ax = reg * ax
		add	ax,97C0h
		mov	ds,cs:data_87e
		mov	si,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	di,0
		mov	word ptr cs:data_71e,0
		mov	word ptr cs:data_70e,0
		mov	cx,120h

locloop_58:
		mov	ax,ds:data_2e[si]
		mov	cs:data_69e,ax
		lodsw				; String [si] to ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		stosw				; Store ax to es:[di]
		loop	locloop_58		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,data_1e
		mov	cx,1220h
		jmp	loc_34
		db	 33h,0DBh,0B9h, 19h, 00h

locloop_59:
		push	cx
		mov	cx,22h

locloop_60:
		push	cx
		lodsb				; String [si] to al
		push	bx
		push	ds
		push	si
		call	imgdec_multiply_2
		pop	si
		pop	ds
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_60		; Loop if cx > 0

		xor	bh,bh			; Zero register
		inc	bl
		pop	cx
		loop	locloop_59		; Loop if cx > 0

		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_multiply_2		proc	near
		mov	ds,cs:data_87e
		mov	dx,cs
		add	dx,2000h
		mov	es,dx
		xor	ah,ah			; Zero register
loc_61:
		sub	al,28h			; '('
		jc	loc_62			; Jump if carry Set
		inc	ah
		jmp	short loc_61
loc_62:
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

locloop_63:
		push	cx
		push	di
		push	si
		mov	cx,8

locloop_64:
		movsb				; Mov [si] to es:[di]
		add	di,21h
		add	si,27h
		loop	locloop_64		; Loop if cx > 0

		pop	si
		pop	di
		add	di,1A90h
		add	si,640h
		pop	cx
		loop	locloop_63		; Loop if cx > 0

		retn
imgdec_multiply_2		endp

			                        ;* No entry point to code
		mov	word ptr cs:data_71e,0
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
		mov	di,data_80e
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,data_89e
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,data_80e
		mov	cx,44h

locloop_65:
		mov	al,es:[di]
		mov	dx,8
loc_66:
		ror	al,1			; Rotate
		adc	ah,ah
		dec	dx
		jnz	loc_66			; Jump if not zero
		mov	es:[di],ah
		inc	di
		loop	locloop_65		; Loop if cx > 0

		pop	si
		pop	ax
		mov	bl,al
		xor	bh,bh			; Zero register
		call	math_calc
		mov	di,ax
		mov	ax,0B000h
		mov	es,ax
		push	di
		push	di
		push	si
		mov	cx,11h

locloop_67:
		lodsw				; String [si] to ax
		mov	cs:data_69e,ax
		mov	ax,ds:data_90e[si]
		mov	cs:data_70e,ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		or	es:[di],ax
		inc	di
		inc	di
		loop	locloop_67		; Loop if cx > 0

		pop	si
		pop	di
		add	di,2000h
		cmp	di,6000h
		jb	loc_69			; Jump if below
		mov	cx,11h

locloop_68:
		lodsw				; String [si] to ax
		mov	cs:data_69e,ax
		mov	ax,ds:data_90e[si]
		mov	cs:data_70e,ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		or	es:[di],ax
		inc	di
		inc	di
		loop	locloop_68		; Loop if cx > 0

loc_69:
		pop	di
		add	di,4Eh
		push	cs
		pop	ds
		push	di
		mov	si,data_80e
		mov	cx,11h

locloop_70:
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_69e,ax
		mov	ax,[si+20h]
		xchg	ah,al
		mov	cs:data_70e,ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		or	es:[di],ax
		dec	di
		dec	di
		loop	locloop_70		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,6000h
		jb	loc_72			; Jump if below
		mov	si,data_80e
		mov	cx,11h

locloop_71:
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_69e,ax
		mov	ax,[si+20h]
		xchg	ah,al
		mov	cs:data_70e,ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		or	es:[di],ax
		dec	di
		dec	di
		loop	locloop_71		; Loop if cx > 0

loc_72:
		pop	ds
		retn
			                        ;* No entry point to code
		mov	bx,ax
		mov	al,ds:data_64e[bx]
		mov	ds:data_73e,al
		mov	ax,0B000h
		mov	es,ax
		mov	di,data_65e
		mov	si,data_62e
loc_73:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_75			; Jump if zero
		call	imgdec_func_9
		add	di,205Ah
		cmp	di,6000h
		jb	loc_74			; Jump if below
		add	di,0A05Ah
loc_74:
		jmp	short loc_73
loc_75:
		sub	di,2059h
		jnc	loc_76			; Jump if carry=0
		add	di,data_82e
loc_76:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_77			; Jump if zero
		call	imgdec_func_9
		inc	di
		jmp	short loc_76
loc_77:
		sub	di,205Bh
		jnc	loc_78			; Jump if carry=0
		add	di,data_82e
loc_78:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_80			; Jump if zero
		call	imgdec_func_9
		sub	di,205Ah
		jnc	loc_79			; Jump if carry=0
		add	di,5FA6h
loc_79:
		jmp	short loc_78
loc_80:
		add	di,2059h
		cmp	di,6000h
		jb	loc_81			; Jump if below
		add	di,data_84e
loc_81:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_82			; Jump if zero
		call	imgdec_func_9
		dec	di
		jmp	short loc_81
loc_82:
		add	di,205Bh
		cmp	di,6000h
		jb	loc_83			; Jump if below
		add	di,data_84e
loc_83:
		mov	si,data_63e
loc_84:
		mov	byte ptr cs:data_86e,0
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
		call	imgdec_func_9
		add	di,205Ah
		cmp	di,6000h
		jb	loc_87			; Jump if below
		add	di,0A05Ah
loc_87:
		pop	cx
		loop	locloop_86		; Loop if cx > 0

		sub	di,205Ah
		jnc	loc_88			; Jump if carry=0
		add	di,data_82e
loc_88:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_89			; Jump if not zero
		retn
loc_89:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_90:
		push	cx
		mov	al,18h
		call	imgdec_func_9
		inc	di
		pop	cx
		loop	locloop_90		; Loop if cx > 0

		dec	di
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_91			; Jump if not zero
		retn
loc_91:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_92:
		push	cx
		mov	al,18h
		call	imgdec_func_9
		sub	di,205Ah
		jnc	loc_93			; Jump if carry=0
		add	di,5FA6h
loc_93:
		pop	cx
		loop	locloop_92		; Loop if cx > 0

		add	di,205Ah
		cmp	di,6000h
		jb	loc_94			; Jump if below
		add	di,data_84e
loc_94:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_95			; Jump if not zero
		retn
loc_95:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_96:
		push	cx
		mov	al,18h
		call	imgdec_func_9
		dec	di
		pop	cx
		loop	locloop_96		; Loop if cx > 0

		inc	di
loc_97:
		cmp	byte ptr cs:data_86e,0Ch
		jb	loc_97			; Jump if below
		jmp	loc_84

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_func_9		proc	near
		push	si
		push	di
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,3A0Bh
		mov	si,ax
		lodsb				; String [si] to al
		and	al,cs:data_73e
		or	al,[si+3]
		stosb				; Store al to es:[di]
		add	di,1FFFh
		cmp	di,data_95e
		jb	loc_98			; Jump if below
		stosb				; Store al to es:[di]
		add	di,data_96e
loc_98:
		lodsb				; String [si] to al
		and	al,cs:data_73e
		or	al,[si+3]
		stosb				; Store al to es:[di]
		add	di,1FFFh
		cmp	di,data_95e
		jb	loc_99			; Jump if below
		stosb				; Store al to es:[di]
		add	di,data_96e
loc_99:
		lodsb				; String [si] to al
		and	al,cs:data_73e
		or	al,[si+3]
		stosb				; Store al to es:[di]
		add	di,1FFFh
		cmp	di,data_95e
		jb	loc_100			; Jump if below
		stosb				; Store al to es:[di]
		add	di,data_96e
loc_100:
		lodsb				; String [si] to al
		and	al,cs:data_73e
		or	al,[si+3]
		stosb				; Store al to es:[di]
		add	di,1FFFh
		cmp	di,data_95e
		jb	loc_101			; Jump if below
		stosb				; Store al to es:[di]
loc_101:
		pop	di
		pop	si
		retn
imgdec_func_9		endp

		db	 00h, 00h, 00h, 03h, 80h, 80h
		db	 8Ah, 88h, 03h, 03h, 03h, 03h
		db	 88h, 88h, 88h, 88h, 03h, 03h
		db	 03h, 03h, 88h, 88h, 88h,0A8h
		db	 00h, 00h, 00h,0FFh, 00h, 00h
		db	0AAh, 00h, 00h, 00h, 00h,0FFh
		db	 02h, 02h,0AAh, 00h, 00h, 00h
		db	 00h,0FFh, 80h, 80h,0AAh, 00h
		db	 00h, 00h, 00h,0C0h, 02h, 02h
		db	0A2h, 22h,0C0h,0C0h,0C0h,0C0h
		db	 22h, 22h, 22h, 22h,0C0h,0C0h
		db	0C0h,0C0h, 22h, 22h, 22h, 22h
		db	0C0h,0C0h,0C0h,0C0h, 2Ah, 02h
		db	 02h, 02h, 03h, 03h, 03h, 03h
		db	0A8h, 88h, 88h, 88h, 03h, 03h
		db	 03h, 03h, 88h, 88h, 88h, 88h
		db	 03h, 00h, 00h, 00h, 88h, 8Ah
		db	 80h, 80h,0FFh, 00h, 00h, 00h
		db	 00h,0AAh, 00h, 00h,0FFh, 00h
		db	 00h, 00h, 00h,0AAh, 02h, 02h
		db	0FFh, 00h, 00h, 00h, 00h,0AAh
		db	 80h, 80h,0C0h,0C0h,0C0h,0C0h
		db	 2Ah, 22h, 22h, 22h,0C0h,0C0h
		db	0C0h,0C0h, 22h, 22h, 22h, 22h
		db	0C0h, 00h, 00h, 00h, 22h,0A2h
		db	 02h, 02h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 03h, 03h, 03h, 03h, 80h, 80h
		db	 80h, 80h,0C0h,0C0h,0C0h,0C0h
		db	 02h, 02h, 02h, 02h,0FFh,0FFh
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
		db	 00h,0AAh, 55h, 1Eh, 2Eh,0A2h
		db	 5Fh, 4Ch, 53h, 51h, 8Ah,0C5h
		db	0F6h,0E1h, 8Bh,0E8h, 06h, 1Fh
		db	 8Bh,0F7h, 8Ch,0C8h, 05h, 00h
		db	 30h, 8Eh,0C0h,0BFh, 00h, 00h
		db	 2Eh,0C7h, 06h, 5Ah, 4Ch, 00h
		db	 00h, 2Eh,0C7h, 06h, 54h, 4Ch
		db	 00h, 00h, 2Eh,0C7h, 06h, 56h
		db	 4Ch, 00h, 00h, 2Eh,0C7h, 06h
		db	 58h, 4Ch, 00h, 00h, 8Bh,0CDh
		db	0D1h,0E9h

locloop_102:
		push	si
		test	byte ptr cs:data_75e,1
		jz	loc_103			; Jump if zero
		mov	ax,[si]
		mov	cs:data_68e,ax
		add	si,bp
loc_103:
		test	byte ptr cs:data_75e,2
		jz	loc_104			; Jump if zero
		mov	ax,[si]
		mov	cs:data_69e,ax
		add	si,bp
loc_104:
		test	byte ptr cs:data_75e,4
		jz	loc_105			; Jump if zero
		mov	ax,[si]
		mov	cs:data_70e,ax
loc_105:
		call	imgdec_process_loop_5
		stosw				; Store ax to es:[di]
		pop	si
		inc	si
		inc	si
		loop	locloop_102		; Loop if cx > 0

		pop	cx
		pop	bx
		sub	bx,410h
		mov	byte ptr cs:data_73e,0
		mov	byte ptr cs:data_74e,0
		mov	cs:data_76e,cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,0
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

locloop_106:
		push	cx
		mov	al,cs:data_74e
		mov	cs:data_73e,al
		mov	byte ptr cs:data_86e,0
		mov	cx,0Dh

locloop_107:
		push	cx
		push	bx
		push	si
		call	imgdec_multiply_3
		pop	si
		pop	bx
		pop	cx
		add	byte ptr cs:data_73e,8
		loop	locloop_107		; Loop if cx > 0

		pop	cx
loc_108:
		cmp	byte ptr cs:data_86e,14h
		jb	loc_108			; Jump if below
		inc	byte ptr cs:data_74e
		loop	locloop_106		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_multiply_3		proc	near
		push	bx
		mov	bl,cs:data_73e
		add	bl,10h
		mov	bh,4
		call	math_calc
		mov	di,ax
		pop	bx
		cmp	cs:data_73e,bl
		jb	loc_112			; Jump if below
		mov	al,bl
		add	al,cs:data_76e
		cmp	cs:data_73e,al
		jae	loc_112			; Jump if above or =
		mov	al,cs:data_73e
		sub	al,bl
		mul	byte ptr cs:data_76e+1	; ax = data * al
		add	si,ax
		push	di
		mov	byte ptr cs:data_72e,0
		mov	cx,48h

locloop_109:
		push	cx
		mov	byte ptr es:[di],0
		cmp	cs:data_72e,bh
		jb	loc_110			; Jump if below
		mov	al,bh
		add	al,byte ptr cs:data_76e+1
		cmp	cs:data_72e,al
		jae	loc_110			; Jump if above or =
		movsb				; Mov [si] to es:[di]
		dec	di
loc_110:
		inc	di
		inc	byte ptr cs:data_72e
		pop	cx
		loop	locloop_109		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,data_95e
		jae	loc_111			; Jump if above or =
		retn
loc_111:
		push	ds
		push	es
		pop	ds
		mov	si,di
		sub	si,2000h
		mov	cx,48h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
loc_112:
		push	di
		mov	cx,24h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	di
		add	di,2000h
		cmp	di,data_95e
		jae	loc_113			; Jump if above or =
		retn
loc_113:
		mov	cx,24h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
imgdec_multiply_3		endp

			                        ;* No entry point to code
		mov	cs:data_73e,bl
		call	math_calc
		mov	di,ax
		mov	ax,0B000h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register
		sub	cx,5
		push	cx
		push	di
		call	fill_buffer
		pop	di
		inc	byte ptr cs:data_73e
		add	di,2000h
		cmp	di,6000h
		jb	loc_114			; Jump if below
		add	di,data_84e
loc_114:
		mov	cx,2
		call	clear_buffer
		pop	cx

locloop_115:
		push	cx
		call	imgdec_get_value
		or	byte ptr es:[di],30h	; '0'
		and	byte ptr es:[di],0F0h
		or	byte ptr es:[bx+di-1],0Ch
		and	byte ptr es:[bx+di-1],0Fh
		inc	byte ptr cs:data_73e
		add	di,2000h
		cmp	di,data_95e
		jb	loc_116			; Jump if below
		call	imgdec_get_value
		or	byte ptr es:[di],30h	; '0'
		and	byte ptr es:[di],0F0h
		or	byte ptr es:[bx+di-1],0Ch
		and	byte ptr es:[bx+di-1],0Fh
		inc	byte ptr cs:data_73e
		add	di,data_84e
loc_116:
		pop	cx
		loop	locloop_115		; Loop if cx > 0

		mov	cx,1
		call	clear_buffer

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

fill_buffer		proc	near
		push	di
		call	imgdec_get_value
		or	byte ptr es:[di],3Fh	; '?'
		inc	di
		mov	cx,bx
		sub	cx,2
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0FCh
		pop	di
		add	di,2000h
		cmp	di,data_95e
		jae	loc_117			; Jump if above or =
		retn
loc_117:
		call	imgdec_get_value
		or	byte ptr es:[di],3Fh	; '?'
		inc	di
		mov	cx,bx
		sub	cx,2
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0FCh
		retn
fill_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

clear_buffer		proc	near

locloop_118:
		push	cx
		push	di
		call	imgdec_get_value
		or	byte ptr es:[di],30h	; '0'
		and	byte ptr es:[di],0F0h
		inc	di
		mov	cx,bx
		sub	cx,2
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0Ch
		and	byte ptr es:[di],0Fh
		pop	di
		inc	byte ptr cs:data_73e
		add	di,2000h
		cmp	di,data_95e
		jb	loc_119			; Jump if below
		push	di
		call	imgdec_get_value
		or	byte ptr es:[di],30h	; '0'
		and	byte ptr es:[di],0F0h
		inc	di
		mov	cx,bx
		sub	cx,2
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0Ch
		and	byte ptr es:[di],0Fh
		pop	di
		add	di,0A05Ah
loc_119:
		pop	cx
		loop	locloop_118		; Loop if cx > 0

		retn
clear_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_get_value		proc	near
		mov	word ptr es:[di-1],0
		retn
imgdec_get_value		endp

			                        ;* No entry point to code
		push	bx
		push	es
		push	di
		mov	cx,1028h

locloop_120:
		mov	al,es:[di]
		and	al,byte ptr es:[1028h][di]
		mov	ah,es:data_55e[di]
		not	ah
		and	al,ah
		not	al
		and	es:[di],al
		and	byte ptr es:[1028h][di],al
		and	es:data_55e[di],al
		mov	al,es:data_55e[di]
		mov	ah,es:[di]
		not	ah
		and	al,ah
		mov	ah,byte ptr es:[1028h][di]
		not	ah
		and	al,ah
		or	es:[di],al
		or	byte ptr es:[1028h][di],al
		not	al
		and	es:data_55e[di],al
		inc	di
		loop	locloop_120		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,2F58h
		jmp	loc_32
			                        ;* No entry point to code
		push	ds
		mov	ds:data_78e,di
		mov	ds:data_79e,es
		mov	di,69Ah
		add	di,ds:data_78e
		call	imgdec_process_loop_4
		mov	di,6BCh
		add	di,ds:data_78e
		call	imgdec_process_loop_4
		mov	ax,0B000h
		mov	es,ax
		mov	ds,cs:data_79e
		mov	cx,44h

locloop_121:
		push	cx
		mov	byte ptr cs:data_86e,0
		mov	ax,44h
		sub	ax,cx
		add	ax,ax
		push	ax
		mov	bl,al
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		push	ax
		xor	bh,bh			; Zero register
		call	math_calc
		mov	di,ax
		pop	ax
		add	ax,cs:data_78e
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	loc_122			; Jump if below
		cmp	ax,71h
		jae	loc_122			; Jump if above or =
		call	imgdec_scan_loop_2
		jmp	short loc_123
loc_122:
		call	imgdec_scan_loop
loc_123:
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
		xor	bh,bh			; Zero register
		call	math_calc
		mov	di,ax
		pop	ax
		add	ax,cs:data_78e
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	loc_124			; Jump if below
		cmp	ax,71h
		jae	loc_124			; Jump if above or =
		call	imgdec_scan_loop_2
		jmp	short loc_125
loc_124:
		call	imgdec_scan_loop
loc_125:
		cmp	byte ptr cs:data_86e,4
		jb	loc_125			; Jump if below
		pop	cx
		loop	locloop_121		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_scan_loop		proc	near
		mov	cx,28h
		mov	word ptr cs:data_71e,0

locloop_126:
		mov	ax,ds:data_81e[si]
		mov	cs:data_70e,ax
		mov	ax,ds:data_57e[si]
		mov	cs:data_69e,ax
		lodsw				; String [si] to ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		stosw				; Store ax to es:[di]
		push	di
		add	di,1FFEh
		cmp	di,data_95e
		jb	loc_127			; Jump if below
		stosw				; Store ax to es:[di]
loc_127:
		pop	di
		loop	locloop_126		; Loop if cx > 0

		retn
imgdec_scan_loop		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_scan_loop_2		proc	near
		mov	cx,0Bh
		mov	word ptr cs:data_71e,0

locloop_128:
		xor	ah,ah			; Zero register
		mov	al,ds:data_81e[si]
		mov	cs:data_70e,ax
		mov	al,ds:data_57e[si]
		mov	cs:data_69e,ax
		lodsb				; String [si] to al
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		stosb				; Store al to es:[di]
		push	di
		add	di,1FFFh
		cmp	di,data_95e
		jb	loc_129			; Jump if below
		stosb				; Store al to es:[di]
loc_129:
		pop	di
		loop	locloop_128		; Loop if cx > 0

		add	si,18h
		add	di,18h
		mov	cx,5

locloop_130:
		mov	ax,ds:data_81e[si]
		mov	cs:data_70e,ax
		mov	ax,ds:data_57e[si]
		mov	cs:data_69e,ax
		lodsw				; String [si] to ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		stosw				; Store ax to es:[di]
		push	di
		add	di,1FFEh
		cmp	di,data_95e
		jb	loc_131			; Jump if below
		stosw				; Store ax to es:[di]
loc_131:
		pop	di
		loop	locloop_130		; Loop if cx > 0

		add	si,18h
		add	di,18h
		mov	cx,0Bh

locloop_132:
		xor	ah,ah			; Zero register
		mov	al,ds:data_81e[si]
		mov	cs:data_70e,ax
		mov	al,ds:data_57e[si]
		mov	cs:data_69e,ax
		lodsb				; String [si] to al
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		stosb				; Store al to es:[di]
		push	di
		add	di,1FFFh
		cmp	di,data_95e
		jb	loc_133			; Jump if below
		stosb				; Store al to es:[di]
loc_133:
		pop	di
		loop	locloop_132		; Loop if cx > 0

		retn
imgdec_scan_loop_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_process_loop_4		proc	near
		push	di
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

locloop_134:
		mov	byte ptr es:[di],30h	; '0'
		mov	byte ptr es:[di+19h],0Ch
		add	di,50h
		loop	locloop_134		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		pop	di
		add	di,data_57e
		push	di
		mov	ax,0FD7Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,2Dh

locloop_135:
		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	byte ptr es:[di],70h	; 'p'
		mov	byte ptr es:[di+19h],0Dh
		add	di,50h
		loop	locloop_135		; Loop if cx > 0

		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	ax,0FD7Fh
		call	fill_buffer_2
		pop	di
		add	di,data_57e
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

locloop_136:
		mov	byte ptr es:[di],30h	; '0'
		mov	byte ptr es:[di+19h],0Ch
		add	di,50h
		loop	locloop_136		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		retn
imgdec_process_loop_4		endp


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
		mov	ds:data_78e,di
		mov	ds:data_79e,es
		mov	ax,0B000h
		mov	es,ax
		mov	ds,cs:data_79e
		mov	cx,39h

locloop_137:
		mov	byte ptr cs:data_86e,0
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,39h
		add	ax,ax
		call	imgdec_multiply_4
		pop	ax
		push	ax
		add	ax,ax
		dec	ax
		call	imgdec_multiply_4
loc_138:
		cmp	byte ptr cs:data_86e,4
		jb	loc_138			; Jump if below
		pop	cx
		loop	locloop_137		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_multiply_4		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,cs:data_78e
		mov	si,ax
		xor	bh,bh			; Zero register
		call	math_calc
		mov	di,ax
		pop	ax
		cmp	ax,14h
		jae	loc_139			; Jump if above or =
		mov	cx,2Fh
		jmp	short loc_140
loc_139:
		mov	cx,23h
		cmp	ax,17h
		jb	loc_140			; Jump if below
		cmp	ax,1Ch
		jb	loc_143			; Jump if below
		mov	cx,21h
loc_140:
		mov	word ptr cs:data_71e,0

locloop_141:
		xor	ah,ah			; Zero register
		mov	al,ds:data_56e[si]
		mov	cs:data_70e,ax
		mov	al,byte ptr data_40[si]
		mov	cs:data_69e,ax
		lodsb				; String [si] to al
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		stosb				; Store al to es:[di]
		push	di
		add	di,1FFFh
		cmp	di,data_95e
		jb	loc_142			; Jump if below
		stosb				; Store al to es:[di]
loc_142:
		pop	di
		loop	locloop_141		; Loop if cx > 0

		retn
loc_143:
		mov	cx,21h
		mov	word ptr cs:data_71e,0

locloop_144:
		xor	ah,ah			; Zero register
		mov	al,ds:data_56e[si]
		mov	cs:data_70e,ax
		mov	al,byte ptr data_40[si]
		mov	cs:data_69e,ax
		lodsb				; String [si] to al
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		stosb				; Store al to es:[di]
		push	di
		add	di,1FFFh
		cmp	di,data_95e
		jb	loc_145			; Jump if below
		stosb				; Store al to es:[di]
loc_145:
		pop	di
		loop	locloop_144		; Loop if cx > 0

		xor	ah,ah			; Zero register
		mov	al,ds:data_56e[si]
		mov	cs:data_70e,ax
		mov	al,byte ptr data_40[si]
		mov	cs:data_69e,ax
		lodsb				; String [si] to al
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		and	al,0FCh
		and	byte ptr es:[di],3
		or	es:[di],al
		add	di,1FFFh
		cmp	di,data_95e
		jae	loc_146			; Jump if above or =
		retn
loc_146:
		and	byte ptr es:[di],3
		or	es:[di],al
		retn
imgdec_multiply_4		endp

			                        ;* No entry point to code
		push	ds
		mov	ds:data_78e,di
		mov	ds:data_79e,es
		mov	ax,0B000h
		mov	es,ax
		mov	ds,cs:data_79e
		mov	cx,39h

locloop_147:
		mov	byte ptr cs:data_86e,0
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,39h
		add	ax,ax
		call	imgdec_multiply_5
		pop	ax
		push	ax
		add	ax,ax
		dec	ax
		call	imgdec_multiply_5
loc_148:
		cmp	byte ptr cs:data_86e,4
		jb	loc_148			; Jump if below
		pop	cx
		loop	locloop_147		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_multiply_5		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,3CDh
		add	ax,cs:data_78e
		mov	si,ax
		add	bl,14h
		xor	bh,bh			; Zero register
		call	math_calc
		mov	di,ax
		add	di,21h
		pop	ax
		cmp	ax,5Eh
		mov	cx,2Fh
		jnc	loc_151			; Jump if carry=0
		mov	cx,7
		mov	word ptr cs:data_71e,0

locloop_149:
		mov	ax,ds:data_56e[si]
		mov	cs:data_70e,ax
		mov	ax,data_40[si]
		mov	cs:data_69e,ax
		lodsw				; String [si] to ax
		mov	cs:data_68e,ax
		call	imgdec_process_loop_5
		stosw				; Store ax to es:[di]
		push	di
		add	di,1FFEh
		cmp	di,data_95e
		jb	loc_150			; Jump if below
		stosw				; Store ax to es:[di]
loc_150:
		pop	di
		loop	locloop_149		; Loop if cx > 0

		mov	cx,21h
loc_151:
		xor	al,al			; Zero register
		push	cx
		push	di
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		pop	cx
		add	di,2000h
		cmp	di,data_95e
		jae	loc_152			; Jump if above or =
		retn
loc_152:
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn
imgdec_multiply_5		endp

			                        ;* No entry point to code
		push	ax
		call	math_calc
		mov	di,ax
		mov	ax,0B000h
		mov	es,ax
		pop	ax
		mov	ah,al
		mov	cx,8

locloop_153:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,data_95e
		jb	loc_154			; Jump if below
		stosw				; Store ax to es:[di]
		add	di,0A058h
loc_154:
		loop	locloop_153		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		dec	ax
		mov	cx,100h
		mul	cx			; dx:ax = reg * ax
		add	ax,4288h
		mov	cs:data_67e,ax
		retn
		db	17 dup (0)
		db	2, 0
		db	15 dup (0)
		db	1, 0, 0, 0, 0, 0
		db	0, 0, 1
		db	8 dup (0)
		db	1, 0, 0, 0, 0, 0
		db	0, 0, 1
		db	8 dup (0)
		db	3, 3, 3, 3, 0, 3
		db	0, 0, 3, 3, 3, 3
		db	0, 0, 0, 0, 3, 3
		db	3, 3, 0, 3, 0, 0
		db	3, 3, 3, 3, 0, 0
		db	0, 0, 3, 3, 3, 3
		db	0, 3, 0, 0, 3, 3
		db	3, 3, 0, 0, 0, 0
		db	3, 3, 3, 3, 0, 3
		db	0, 0, 3, 3, 3, 3
		db	0
		db	7 dup (0)
		db	1, 0
		db	10 dup (0)
		db	3, 3, 3, 3, 0, 1
		db	8 dup (0)
		db	1, 0, 0, 0, 0, 0
		db	0, 0, 1
		db	8 dup (0)
		db	1, 0, 0, 0, 0, 0
		db	0, 0, 1
		db	8 dup (0)
		db	3, 3, 3, 3, 0, 0
		db	0, 0, 3, 3, 3, 3
		db	0, 0, 0, 0, 3, 3
		db	3, 3, 0, 0, 0, 0
		db	3, 3, 3, 3, 0, 0
		db	0, 0, 3, 3, 3, 3
		db	0, 0, 0, 0, 3, 3
		db	3, 3, 0, 0, 0, 0
		db	3, 3, 3, 3, 0, 0
		db	0, 0, 3, 3, 3, 3
		db	0, 0, 0, 0, 0, 1
		db	2, 0
		db	9 dup (0)
		db	1, 1, 2, 0, 1, 2
		db	1, 0
		db	8 dup (0)
		db	1, 2, 0, 0, 2, 2
		db	2, 0
		db	8 dup (0)
		db	2, 0, 2, 0, 1, 2
		db	2, 0
		db	12 dup (0)
		db	1, 2
		db	9 dup (0)
		db	1, 1, 2, 1, 1, 1
		db	1, 3
		db	8 dup (0)
		db	2, 1, 2, 2, 2, 1
		db	3, 3
		db	9 dup (0)
		db	1, 2, 2, 0, 3, 3
		db	3, 0
		db	32 dup (0)
		db	3, 0
		db	15 dup (0)
		db	2, 0
		db	15 dup (0)
		db	2, 0
		db	15 dup (0)
		db	1, 0
		db	15 dup (0)
		db	1, 0
		db	15 dup (0)
		db	3, 0
		db	15 dup (0)
		db	3, 0, 0, 0, 1, 0
		db	1, 0, 1, 0
		db	8 dup (0)
		db	2, 1, 2, 1, 2, 0
		db	2, 0
		db	8 dup (0)
		db	1, 1, 3, 1, 3, 0
		db	3, 0
		db	7 dup (0)
		db	1, 2, 3, 3, 3, 3
		db	0, 3
		db	9 dup (0)
		db	1, 1, 3, 1, 3, 0
		db	3, 0
		db	7 dup (0)
		db	1, 2, 3, 3, 3, 3
		db	0, 3
		db	10 dup (0)
data_40		dw	0			; Data table (indexed access)
		db	0, 0, 0, 1, 0
		db	7 dup (0)
		db	1, 2, 3, 3, 3, 3
		db	1, 3
		db	33 dup (0)
		db	3, 0
		db	15 dup (0)
		db	2, 0
		db	15 dup (0)
		db	2, 0
		db	15 dup (0)
		db	1, 0
		db	15 dup (0)
		db	1, 0
		db	15 dup (0)
		db	2, 0
		db	15 dup (0)
		db	3, 0, 0, 0, 2, 1
		db	1, 2, 3, 0, 1, 2
		db	2, 1, 1, 2, 3, 0
		db	1, 2, 2, 1, 1, 1
		db	1, 0, 1, 2, 2, 1
		db	1, 1, 1, 0, 2, 2
		db	2, 1, 1, 2, 3, 0
		db	2, 2, 2, 1, 1, 2
		db	3, 2, 2, 2, 2, 1
		db	1, 2, 2, 0, 2, 2
		db	1, 1, 2, 2, 3, 1
		db	1, 1, 1, 1, 1, 3
		db	3, 1, 1, 1, 1, 1
		db	1, 3, 3, 1, 1, 1
		db	1, 1, 1, 3, 3, 1
		db	1, 1, 1, 1, 1, 3
		db	3, 2, 1, 2, 2, 3
		db	3, 3, 3, 2, 2, 2
		db	2, 3, 3, 3, 3, 3
		db	1, 3, 2, 3, 3, 3
		db	3, 3, 1, 2, 2, 3
		db	3, 3, 3, 0, 0, 0
		db	0, 1, 1, 2, 3, 0
		db	0, 0, 2, 1, 1, 2
		db	3, 1, 1, 2, 2, 1
		db	1, 2, 1, 0, 1, 2
		db	2, 1, 1, 1, 1, 2
		db	2, 2, 2, 1, 1, 2
		db	2, 0, 2, 2, 2, 1
		db	1, 2, 3, 2, 2, 2
		db	1, 1, 1, 2, 2, 2
		db	2, 2, 2, 1, 1, 2
		db	2, 1, 1, 1, 1, 1
		db	1, 3, 3, 1, 1, 1
		db	1, 1, 1, 3, 3, 1
		db	1, 1, 2, 1, 1, 3
		db	3, 1, 1, 1, 1, 1
		db	1, 3, 3, 2, 1, 2
		db	2, 3, 3, 3, 3, 2
		db	1, 2, 2, 3, 3, 3
		db	3, 3, 1, 3, 3, 3
		db	3, 3, 3, 3, 1, 3
		db	2, 3, 3, 3, 3, 0
		db	0, 0, 1, 1, 1, 2
		db	3, 0, 1, 2, 2, 1
		db	1, 2, 3, 0, 1, 2
		db	3, 1, 1, 1, 1, 0
		db	1, 2, 2, 1, 1, 1
		db	1, 0, 2, 2, 3, 1
		db	1, 2, 3, 0, 2, 2
		db	2, 1, 1, 2, 3, 1
		db	7 dup (3)
		db	0, 3, 3, 3, 3, 3
		db	3, 3, 1, 1, 1, 3
		db	1, 1, 3, 3, 1, 1
		db	1, 1, 1, 1, 3, 3
		db	1, 1, 1, 3, 1, 1
		db	3, 3, 1, 1, 1, 1
		db	1, 1, 3, 3, 2, 1
		db	2, 3, 3, 3, 3, 3
		db	2, 2, 2, 2, 3, 3
		db	3, 3, 3, 1
		db	7 dup (3)
		db	1, 2, 2, 3, 3, 3
		db	3, 0, 0, 0, 0, 1
		db	1, 2, 3, 0, 0, 0
		db	2, 1, 1, 2, 3, 1
		db	1, 2, 3, 1, 1, 2
		db	1, 0, 1, 2, 2, 1
		db	1, 1, 1, 2, 2, 2
		db	3, 1, 1, 2, 2, 0
		db	2, 2, 2, 1, 1, 2
		db	3, 2, 2, 2, 3, 1
		db	1, 2, 2, 2, 2, 2
		db	2, 1, 1, 2, 2, 1
		db	1, 1, 3, 1, 1, 3
		db	3, 1, 1, 1, 1, 1
		db	1, 3, 3, 1, 1, 1
		db	3, 1, 1, 3, 3, 1
		db	1, 1, 1, 1, 1, 3
		db	3, 2, 1, 2, 3, 3
		db	3, 3, 3, 2, 1, 2
		db	2, 3, 3, 3, 3, 3
		db	1, 3, 3, 3, 3, 3
		db	3, 3, 1, 3, 2, 3
		db	3, 3, 3, 0, 0, 0
		db	0, 0, 1, 2, 3, 0
		db	1, 2, 2, 1, 1, 2
		db	3, 0, 1, 2, 2, 0
		db	1, 1, 1, 0, 1, 2
		db	2, 1, 1, 1, 1, 0
		db	2, 2, 2, 0, 2, 2
		db	3, 0, 2, 2, 2, 1
		db	1, 2, 3, 0, 2, 2
		db	2, 0, 2, 3, 3, 0
		db	3, 3, 3, 3, 3, 3
		db	3, 0, 0, 0, 0, 0
		db	0, 2, 0, 1, 1, 1
		db	1, 1, 1, 3, 3, 1
		db	1, 2, 2, 0, 3, 3
		db	3, 1, 1, 1, 1, 1
		db	1, 3, 3, 2, 1, 2
		db	3, 2, 3, 3, 3, 2
		db	2, 2, 2, 3, 3, 3
		db	3, 3, 1, 3, 3, 0
		db	3, 3, 3, 3, 1, 2
		db	2, 3, 3, 3, 3, 0
		db	0, 0, 0, 1, 1, 2
		db	3, 0, 0, 0, 2, 1
		db	1, 2, 3, 1, 1, 2
		db	3, 1, 1, 2, 1, 0
		db	1, 2, 2, 1, 1, 1
		db	1, 2, 2, 2, 3, 1
		db	1, 2, 2, 0, 2, 2
		db	2, 1, 1, 2, 3, 2
		db	2, 2, 3, 1, 1, 2
		db	2, 2, 2, 2, 2, 1
		db	1, 2, 2, 1, 1, 1
		db	3, 1, 1, 3, 3, 1
		db	1, 1, 1, 1, 1, 3
		db	3, 1, 1, 1, 3, 1
		db	1, 3, 3, 1, 1, 1
		db	1, 1, 1, 3, 3, 2
		db	1, 2, 3, 3, 3, 3
		db	3, 2, 1, 2, 2, 3
		db	3, 3, 3, 3, 1, 3
		db	3, 3, 3, 3, 3, 3
		db	1, 3, 2, 3, 3, 3
		db	3, 0, 1, 0, 0, 1
		db	1, 2, 1, 0, 1, 2
		db	2, 1, 1, 2, 3, 1
		db	1, 2, 2, 1, 1, 1
		db	1, 0, 1, 2, 2, 1
		db	1, 1, 1, 0
		db	7 dup (2)
		db	0, 2, 2, 2, 1, 1
		db	2, 3, 0, 2, 2, 2
		db	2, 2, 3, 2, 0, 3
		db	3, 3, 3, 3, 3, 3
		db	1, 1, 2, 2, 1, 1
		db	2, 3, 1, 1, 1, 1
		db	1, 1, 3, 3, 1, 1
		db	2, 2, 1, 3, 3, 1
		db	1, 1, 1, 1, 1, 1
		db	3, 3, 2, 1, 2, 3
		db	2, 3, 3, 3, 2, 2
		db	2, 2, 3, 3, 3, 3
		db	1, 1, 2, 2, 3, 1
		db	3, 3, 3, 1, 2, 2
		db	3, 3, 3, 3, 0, 0
		db	0, 0, 1, 1, 2, 3
		db	0, 0, 0, 2, 1, 1
		db	2, 3, 1, 1, 2, 3
		db	1, 1, 2, 1, 0, 1
		db	2, 2, 1, 1, 1, 1
		db	2, 2, 2, 3, 1, 1
		db	2, 2, 0, 2, 2, 2
		db	1, 1, 2, 3, 2, 2
		db	2, 3, 1, 1, 2, 2
		db	2, 2, 2, 2, 1, 1
		db	2, 2, 1, 1, 1, 3
		db	1, 1, 3, 3, 1, 1
		db	1, 1, 1, 1, 3, 3
		db	1, 1, 1, 3, 1, 1
		db	3, 3, 1, 1, 1, 1
		db	1, 1, 3, 3, 2, 1
		db	2, 3, 3, 3, 3, 3
		db	2, 1, 2, 2, 3, 3
		db	3, 3, 3, 1, 3, 3
		db	3, 3, 3, 3, 3, 1
		db	3, 2, 3, 3, 3, 3
		db	0, 0, 0, 0, 0, 1
		db	2, 3, 0, 1, 2, 2
		db	1, 1, 2, 3, 0, 1
		db	2, 1, 0, 1, 1, 1
		db	0, 1, 2, 2, 1, 1
		db	1, 1, 0, 2, 2, 1
		db	0, 2, 2, 3, 0, 2
		db	2, 2, 1, 1, 2, 3
		db	0, 1, 1, 1, 0, 1
		db	2, 3, 0, 3, 3, 3
		db	3, 3, 3, 3, 0, 0
		db	0, 0, 0, 0, 2, 0
		db	1, 1, 1, 1, 1, 1
		db	3, 3, 1, 1, 2, 1
		db	0, 3, 3, 3, 1, 1
		db	1, 1, 1, 1, 3, 3
		db	2, 1, 2, 2, 2, 3
		db	3, 3, 2, 2, 2, 2
		db	3, 3, 3, 3, 3, 1
		db	3, 3, 0, 3, 3, 3
		db	3, 1, 2, 2, 3, 3
		db	3, 3, 0, 0, 0, 0
		db	1, 1, 2, 3, 0, 0
		db	0, 2, 1, 1, 2, 3
		db	1, 1, 2, 3, 1, 1
		db	2, 1, 0, 1, 2, 2
		db	1, 1, 1, 1, 2, 2
		db	2, 3, 1, 1, 2, 2
		db	0, 2, 2, 2, 1, 1
		db	2, 3, 2, 2, 2, 3
		db	1, 1, 2, 2, 2, 2
		db	2, 2, 1, 1, 2, 2
		db	1, 1, 1, 3, 1, 1
		db	3, 3, 1, 1, 1, 1
		db	1, 1, 3, 3, 1, 1
		db	1, 3, 1, 1, 3, 3
		db	1, 1, 1, 1, 1, 1
		db	3, 3, 2, 1, 2, 3
		db	3, 3, 3, 3, 2, 1
		db	2, 2, 3, 3, 3, 3
		db	3, 1, 3, 3, 3, 3
		db	3, 3, 3, 1, 3, 2
		db	3, 3, 3, 3, 0, 0
		db	0, 1, 1, 1, 2, 3
		db	0, 1, 2, 2, 1, 1
		db	2, 3, 0, 1, 2, 2
		db	1, 1, 1, 1, 0, 1
		db	2, 2, 1, 1, 1, 1
		db	0, 2, 2, 2, 1, 1
		db	2, 3, 0, 2, 2, 2
		db	1, 1, 2, 3, 1
		db	7 dup (2)
		db	0, 2, 2, 2, 2, 2
		db	2, 2, 1, 1, 1, 2
		db	1, 1, 3, 3, 1, 1
		db	1, 1, 1, 1, 3, 3
		db	1, 1, 1, 2, 1, 1
		db	2, 2, 1, 1, 1, 1
		db	1, 1, 2, 2, 2, 1
		db	2, 2, 3, 2, 3, 3
		db	2, 2, 2, 2, 3, 3
		db	3, 3, 3, 1, 3, 2
		db	3, 2, 3, 3, 3, 1
		db	2, 2, 3, 3, 3, 3
		db	0, 0, 0, 0, 1, 1
		db	2, 3, 0, 0, 0, 2
		db	1, 1, 2, 3, 1, 1
		db	2, 3, 1, 1, 2, 1
		db	0, 1, 2, 2, 1, 1
		db	1, 1, 2, 2, 2, 3
		db	1, 1, 2, 2, 0, 2
		db	2, 2, 1, 1, 2, 3
		db	2, 2, 2, 3, 1, 1
		db	2, 2, 2, 2, 2, 2
		db	1, 1, 2, 2, 1, 1
		db	1, 3, 1, 1, 3, 3
		db	1, 1, 1, 1, 1, 1
		db	3, 3, 1, 1, 1, 3
		db	1, 1, 3, 3, 1, 1
		db	1, 1, 1, 1, 3, 3
		db	2, 1, 2, 3, 3, 2
		db	3, 3, 2, 1, 2, 2
		db	3, 3, 3, 3, 3, 1
		db	3, 3, 3, 2, 3, 3
		db	3, 1, 3, 2, 3, 3
		db	3, 3

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

imgdec_process_loop_5		proc	near
		push	cx
		push	si
		mov	si,cs:data_67e
		mov	cx,8

locloop_155:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_71e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_70e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_69e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_68e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_71e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_70e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_69e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_68e,1	; Rotate
		adc	bx,bx
		add	ax,ax
		add	ax,ax
		or	al,cs:[bx+si]
		loop	locloop_155		; Loop if cx > 0

		pop	si
		pop	cx
		retn
imgdec_process_loop_5		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,0B000h
		mov	ds,ax
		mov	si,data_94e
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,data_88e
		mov	cx,0C8h

locloop_156:
		push	cx
		push	si
		mov	cx,28h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,6000h
		jb	loc_157			; Jump if below
		add	si,0A05Ah
loc_157:
		pop	cx
		loop	locloop_156		; Loop if cx > 0

		pop	ds
		xor	ax,ax			; Zero register
		mov	di,data_91e
		mov	cx,2000h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
			                        ;* No entry point to code
		push	bx
		mov	bl,ah
		xor	bh,bh			; Zero register
		mov	ah,cs:data_66e[bx]
		pop	bx
		jmp	word ptr cs:data_54e
		db	 00h, 05h, 02h, 07h, 03h, 04h
		db	 06h, 01h,0C3h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

math_calc		proc	near
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
math_calc		endp

		db	888 dup (0)

seg_a		ends



		end	start
