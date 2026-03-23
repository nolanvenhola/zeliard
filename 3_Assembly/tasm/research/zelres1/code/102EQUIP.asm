
PAGE  59,132

;==========================================================================
;
;  EQUIPMENT - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	0
data_2e		equ	240h
data_60e	equ	2022h			;*
data_61e	equ	2050h			;*
data_62e	equ	29DCh			;*
data_63e	equ	2A80h			;*
data_64e	equ	32C4h			;*
data_65e	equ	32D4h			;*
data_66e	equ	3635h			;*
data_67e	equ	3637h			;*
data_68e	equ	3A05h			;*
data_69e	equ	3AC9h			;*
data_70e	equ	3AFCh			;*
data_71e	equ	4A97h			;*
data_72e	equ	4AA0h			;*
data_73e	equ	4AA2h			;*
data_74e	equ	4AA4h			;*
data_75e	equ	4AA6h			;*
data_76e	equ	4AA8h			;*
data_77e	equ	4AAAh			;*
data_78e	equ	4AABh			;*
data_79e	equ	4AACh			;*
data_80e	equ	4AADh			;*
data_81e	equ	4AAEh			;*
data_83e	equ	4AB0h			;*
data_84e	equ	4AB2h			;*
data_85e	equ	4DD4h			;*
data_86e	equ	5500h			;*
data_87e	equ	9F36h			;*
data_88e	equ	0A000h			;*
data_89e	equ	0C050h			;*
data_90e	equ	0F500h			;*
data_91e	equ	0FF1Ah			;*
data_92e	equ	0FF2Ch			;*
data_93e	equ	0FF5Fh			;*
data_94e	equ	0FF60h			;*
data_95e	equ	0FF61h			;*
data_96e	equ	0			;*
data_97e	equ	1A6Eh			;*
data_98e	equ	1A8Eh			;*
data_99e	equ	4000h			;*
data_100e	equ	4050h			;*
data_101e	equ	0			;*
data_102e	equ	0C050h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_02		proc	far

start:
		sbb	byte ptr ds:[0],bl
		lahf				; Load ah from flags
		dec	dx
		xor	dh,[bx+si]
		js	loc_1			; Jump if sign=1
		retn	0EF30h
			                        ;* No entry point to code
		inc	ax
		dec	bp
		dec	dx
		in	al,32h			; port 32h ??I/O Non-standard
		cmp	al,33h			; '3'
;*		sal	word ptr [bp+di],cl	; Shift w/zeros fill
		db	0D3h, 33h		;  Fixup - byte match
		push	si
		xor	al,55h			; 'U'
		mov	ax,ss:data_87e
		dec	dx
		jmp	$-12CDh
			                        ;* No entry point to code
		db	 36h, 6Fh, 37h, 16h, 38h,0FFh
		db	':@<', 0Dh, '=c=??$'
		db	'@'
		db	0BDh, 40h, 87h, 4Ah, 50h, 53h
		db	 51h, 1Eh
loc_1:
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
		mov	word ptr cs:data_74e,0
		mov	word ptr cs:data_75e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_2:
		mov	ax,ds:[bp+si]
		mov	cs:data_76e,ax
		lodsw				; String [si] to ax
		mov	cs:data_73e,ax
		call	equip_process_loop_5
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
		mov	word ptr cs:data_76e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_3:
		add	bp,bp
		mov	ax,ds:[bp+si]
		mov	cs:data_75e,ax
		shr	bp,1			; Shift w/zeros fill
		mov	ax,ds:[bp+si]
		mov	cs:data_74e,ax
		lodsw				; String [si] to ax
		mov	cs:data_73e,ax
		call	equip_process_loop_5
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
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_81e,32AFh
		call	equip_func_1
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
		mov	word ptr cs:data_76e,0
		mov	word ptr cs:data_73e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_4:
		mov	ax,ds:[bp+si]
		mov	cs:data_75e,ax
		lodsw				; String [si] to ax
		mov	cs:data_74e,ax
		call	equip_process_loop_5
		stosw				; Store ax to es:[di]
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
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_81e,3275h
		mov	byte ptr cs:data_80e,0
		or	al,al			; Zero ?
		jnz	loc_5			; Jump if not zero
		call	equip_func_1
loc_5:
		mov	byte ptr cs:data_80e,0FFh
		call	equip_func_1
		pop	ds
		retn
loc_6:
		push	ds
		push	ax
		push	es
		push	di
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		pop	si
		pop	ds
		pop	ax
		mov	word ptr cs:data_81e,3238h
		mov	byte ptr cs:data_80e,0
		or	al,al			; Zero ?
		jnz	loc_7			; Jump if not zero
		call	equip_func_1
loc_7:
		mov	byte ptr cs:data_80e,0FFh
		call	equip_func_1
		pop	ds
		retn

zr1_02		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

equip_func_1		proc	near
		mov	byte ptr cs:data_78e,0
		mov	ax,0B800h
		mov	es,ax
		mov	bp,8
loc_8:
		mov	al,cs:data_78e
		mov	cs:data_77e,al
		mov	byte ptr cs:data_91e,0
		push	cx
		push	si
		push	di
loc_9:
		mov	bl,cs:data_77e
		and	bx,7
		add	bx,bx
		mov	bx,cs:data_64e[bx]
		call	word ptr cs:data_81e
		inc	byte ptr cs:data_77e
		mov	al,ch
		xor	ah,ah			; Zero register
		add	si,ax
		add	di,2000h
		cmp	di,4000h
		jb	loc_10			; Jump if below
		add	di,0C050h
loc_10:
		dec	cl
		jz	loc_12			; Jump if zero
		mov	bl,cs:data_77e
		and	bx,7
		add	bx,bx
		mov	bx,cs:data_65e[bx]
		call	word ptr cs:data_81e
		inc	byte ptr cs:data_77e
		mov	al,ch
		xor	ah,ah			; Zero register
		add	si,ax
		add	di,2000h
		cmp	di,4000h
		jb	loc_11			; Jump if below
		add	di,0C050h
loc_11:
		dec	cl
		jnz	loc_9			; Jump if not zero
loc_12:
		pop	di
		pop	si
		pop	cx
		inc	byte ptr cs:data_78e
loc_13:
		cmp	byte ptr cs:data_91e,14h
		jb	loc_13			; Jump if below
		dec	bp
		jz	loc_ret_14		; Jump if zero
		jmp	loc_8

loc_ret_14:
		retn
equip_func_1		endp

			                        ;* No entry point to code
		test	byte ptr cs:data_80e,0FFh
		jz	loc_16			; Jump if zero
		push	si
		push	di
		push	cx
		mov	dx,bx
		not	bx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_15:
		and	es:[di],bl
		lodsb				; String [si] to al
		and	al,dl
		or	es:[di],al
		inc	di
		xchg	dh,dl
		xchg	bh,bl
		loop	locloop_15		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
loc_16:
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_17:
		lodsb				; String [si] to al
		and	al,bl
		or	es:[di],al
		inc	di
		xchg	bh,bl
		loop	locloop_17		; Loop if cx > 0

		pop	cx
		pop	di
		pop	si
		retn
			                        ;* No entry point to code
		test	byte ptr cs:data_80e,0FFh
		jz	loc_16			; Jump if zero
		push	si
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_18:
		push	cx
		lodsb				; String [si] to al
		mov	ah,al
		mov	dl,3
		mov	cx,4

locloop_19:
		test	ah,dl
		jz	loc_20			; Jump if zero
		or	ah,dl
loc_20:
		add	dl,dl
		add	dl,dl
		loop	locloop_19		; Loop if cx > 0

		and	ah,bl
		not	ah
		and	es:[di],ah
		and	al,bl
		or	es:[di],al
		inc	di
		xchg	bh,bl
		pop	cx
		loop	locloop_18		; Loop if cx > 0

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

locloop_21:
		and	es:[di],bl
		inc	di
		xchg	dh,dl
		xchg	bh,bl
		loop	locloop_21		; Loop if cx > 0

		pop	cx
		pop	di
		retn
		db	 00h,0C0h, 00h, 0Ch,0C0h, 00h
		db	 0Ch, 00h, 00h, 30h, 00h, 03h
		db	 30h, 00h, 03h, 00h, 03h, 00h
		db	 30h, 00h, 00h, 03h, 00h, 30h
		db	 0Ch, 00h,0C0h, 00h, 00h, 0Ch
		db	 00h,0C0h, 0Eh, 07h,0BFh,0B4h
		db	 4Ah, 33h,0C0h,0B9h, 90h, 01h
		db	0F3h,0ABh,0BFh,0B4h
		db	4Ah
loc_22:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_23			; Jump if not equal
		retn
loc_23:
		sub	al,20h			; ' '
		jnc	loc_24			; Jump if carry=0
		retn
loc_24:
		jz	loc_26			; Jump if zero
		push	si
		push	di
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:data_90e
		mov	si,ax
		mov	cx,8

locloop_25:
		push	cx
		lodsb				; String [si] to al
		call	equip_process_loop
		mov	es:[di],dx
		add	di,50h
		pop	cx
		loop	locloop_25		; Loop if cx > 0

		pop	di
		pop	si
loc_26:
		add	di,2
		jmp	short loc_22

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

equip_process_loop		proc	near
		mov	cx,8

locloop_27:
		add	al,al
		adc	bx,bx
		add	bx,bx
		loop	locloop_27		; Loop if cx > 0

		mov	dx,bx
		shr	dx,1			; Shift w/zeros fill
		or	dx,bx
		xchg	dh,dl
		retn
equip_process_loop		endp

			                        ;* No entry point to code
		push	ds
		push	cx
		push	bx
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,4AB4h
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
		mov	di,data_99e
		mov	si,data_100e
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
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		pop	bx
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	si,ax
		add	si,0
		mov	bp,ax
		add	bp,data_99e
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	ax,0B800h
		mov	es,ax
		pop	cx
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

locloop_28:
		push	cx
		push	di
		mov	cx,bx
		shr	cx,1			; Shift w/zeros fill

locloop_29:
		lodsw				; String [si] to ax
		or	ax,ds:[bp]
		stosw				; Store ax to es:[di]
		inc	bp
		inc	bp
		loop	locloop_29		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_30			; Jump if below
		add	di,0C050h
loc_30:
		pop	cx
		loop	locloop_28		; Loop if cx > 0

		pop	ds
		retn
loc_31:
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
		mov	word ptr cs:data_76e,0
		mov	cx,bp
		shr	cx,1			; Shift w/zeros fill

locloop_32:
		add	bp,bp
		mov	ax,ds:[bp+si]
		mov	cs:data_75e,ax
		shr	bp,1			; Shift w/zeros fill
		mov	ax,ds:[bp+si]
		mov	cs:data_74e,ax
		lodsw				; String [si] to ax
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		stosw				; Store ax to es:[di]
		loop	locloop_32		; Loop if cx > 0

		pop	cx
		pop	bx
		pop	ax
		pop	ds
loc_33:
		push	ds
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	di,bx
		mov	si,data_101e
		push	es
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		xor	bx,bx			; Zero register
		mov	bl,ch
		xor	ch,ch			; Zero register

locloop_34:
		push	cx
		push	di
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	cx
		add	di,2000h
		cmp	di,4000h
		jb	loc_35			; Jump if below
		add	di,0C050h
loc_35:
		loop	locloop_34		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_88e
		xor	dx,dx			; Zero register
		mov	cx,9

locloop_36:
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
		loop	locloop_36		; Loop if cx > 0

		mov	byte ptr ds:data_91e,0
loc_37:
		mov	si,data_88e
		mov	cx,9
loc_38:
		push	cx
		test	byte ptr [si],0FFh
		jz	loc_40			; Jump if zero
		mov	al,[si+0Dh]
		cmp	al,[si+0Eh]
		je	loc_39			; Jump if equal
		inc	byte ptr [si+0Ch]
		test	byte ptr [si+0Ch],1
		jnz	loc_39			; Jump if not zero
		inc	byte ptr [si+0Dh]
loc_39:
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	cx,ds:data_67e[bx]
		mov	[si+7],cx
		mov	al,[si+4]
		add	al,[si+0Ah]
		mov	[si+4],al
		mov	dh,al
		mov	al,[si+3]
		add	al,[si+9]
		mov	[si+3],al
		mov	dl,al
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
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
loc_40:
		pop	cx
		add	si,0Fh
		loop	locloop_41		; Loop if cx > 0

		jmp	short loc_42

locloop_41:
		jmp	loc_38
loc_42:
		mov	si,data_88e
		mov	cx,9

locloop_43:
		push	cx
		test	byte ptr cs:[si],0FFh
		jz	loc_44			; Jump if zero
		xor	bx,bx			; Zero register
		mov	bl,[si+0Dh]
		add	bx,bx
		add	bx,bx
		mov	bp,ds:data_66e[bx]
		mov	cx,[si+7]
		mov	dl,[si]
		mov	byte ptr [si],0
		mov	ax,[si+3]
		cmp	ah,4Bh			; 'K'
		jae	loc_44			; Jump if above or =
		cmp	al,0A0h
		jae	loc_44			; Jump if above or =
		mov	[si],dl
		mov	di,[si+5]
		push	ds
		push	si
		mov	ax,0B800h
		mov	es,ax
		mov	ds,cs:data_92e
		mov	si,bp
		call	equip_multiply
		pop	si
		pop	ds
loc_44:
		pop	cx
		add	si,0Fh
		loop	locloop_43		; Loop if cx > 0

loc_45:
		cmp	byte ptr cs:data_91e,1Eh
		jb	loc_45			; Jump if below
		mov	byte ptr cs:data_91e,0
		mov	si,data_88e
		mov	cx,9

locloop_46:
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
		loop	locloop_46		; Loop if cx > 0

		mov	si,data_88e
		mov	cx,9

locloop_47:
		test	byte ptr [si],0FFh
		jz	loc_48			; Jump if zero
		jmp	loc_37
loc_48:
		add	si,0Fh
		loop	locloop_47		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_buffer		proc	near
		push	si
		push	cx
loc_49:
		push	si
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	si
		add	si,2000h
		cmp	si,4000h
		jb	loc_50			; Jump if below
		add	si,0C050h
loc_50:
		dec	cl
		jnz	loc_49			; Jump if not zero
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
loc_51:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_52			; Jump if below
		add	di,0C050h
loc_52:
		dec	cl
		jnz	loc_51			; Jump if not zero
		pop	cx
		pop	di
		retn
copy_buffer_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

equip_multiply		proc	near
		push	di
		push	cx
		mov	al,ch
		mul	cl			; ax = reg * al
		mov	bx,ax
		mov	word ptr cs:data_76e,0
		mov	word ptr cs:data_75e,0
loc_53:
		push	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register

locloop_54:
		xor	ah,ah			; Zero register
		mov	al,[bx+si]
		mov	cs:data_74e,ax
		lodsb				; String [si] to al
		mov	cs:data_73e,ax
		push	bx
		call	equip_process_loop_5
		pop	bx
		or	es:[di],al
		inc	di
		loop	locloop_54		; Loop if cx > 0

		pop	cx
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_55			; Jump if below
		add	di,0C050h
loc_55:
		dec	cl
		jnz	loc_53			; Jump if not zero
		pop	cx
		pop	di
		retn
equip_multiply		endp

		db	 00h, 90h, 20h, 06h, 80h, 91h
		db	 20h, 06h, 00h, 93h, 20h, 06h
		db	 80h, 94h, 20h, 06h, 00h, 96h
		db	 18h, 04h,0C0h, 96h, 18h, 04h
		db	 80h, 97h, 18h, 04h, 40h, 98h
		db	 18h, 04h, 1Eh, 53h, 32h,0E4h
		db	0BAh,0C0h
		db	0Ch
data_8		dw	0E2F7h			; Data table (indexed access)
		db	 05h, 40h,0ABh, 2Eh, 8Eh, 1Eh
		db	 2Ch,0FFh, 8Bh,0F0h, 8Ch,0C8h
		db	 05h, 00h, 30h, 8Eh,0C0h,0BFh
		db	 00h, 00h, 2Eh,0C7h, 06h,0A8h
		db	 4Ah, 00h, 00h, 2Eh,0C7h, 06h
		db	0A6h, 4Ah, 00h, 00h,0B9h, 30h
		db	 03h

locloop_56:
		mov	ax,data_8[si]
		mov	cs:data_73e,ax
		lodsw				; String [si] to ax
		mov	cs:data_74e,ax
		call	equip_process_loop_5
		stosw				; Store ax to es:[di]
		loop	locloop_56		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,0
		mov	cx,2230h
		jmp	loc_33
			                        ;* No entry point to code
		push	ds
		push	bx
		xor	ah,ah			; Zero register
		mov	dx,480h
		mul	dx			; dx:ax = reg * ax
		add	ax,97C0h
		mov	ds,cs:data_92e
		mov	si,ax
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	di,0
		mov	word ptr cs:data_76e,0
		mov	word ptr cs:data_75e,0
		mov	cx,120h

locloop_57:
		mov	ax,ds:data_2e[si]
		mov	cs:data_74e,ax
		lodsw				; String [si] to ax
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		stosw				; Store ax to es:[di]
		loop	locloop_57		; Loop if cx > 0

		pop	bx
		pop	ds
		mov	di,data_1e
		mov	cx,1220h
		jmp	loc_33
		db	 33h,0DBh,0B9h, 19h, 00h

locloop_58:
		push	cx
		mov	cx,22h

locloop_59:
		push	cx
		lodsb				; String [si] to al
		push	bx
		push	ds
		push	si
		call	equip_multiply_2
		pop	si
		pop	ds
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_59		; Loop if cx > 0

		xor	bh,bh			; Zero register
		inc	bl
		pop	cx
		loop	locloop_58		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

equip_multiply_2		proc	near
		mov	ds,cs:data_92e
		mov	dx,cs
		add	dx,2000h
		mov	es,dx
		xor	ah,ah			; Zero register
loc_60:
		sub	al,28h			; '('
		jc	loc_61			; Jump if carry Set
		inc	ah
		jmp	short loc_60
loc_61:
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

locloop_62:
		push	cx
		push	di
		push	si
		mov	cx,8

locloop_63:
		movsb				; Mov [si] to es:[di]
		add	di,21h
		add	si,27h
		loop	locloop_63		; Loop if cx > 0

		pop	si
		pop	di
		add	di,1A90h
		add	si,640h
		pop	cx
		loop	locloop_62		; Loop if cx > 0

		retn
equip_multiply_2		endp

			                        ;* No entry point to code
		mov	word ptr cs:data_76e,0
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
		mov	di,data_85e
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,data_97e
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,data_85e
		mov	cx,44h

locloop_64:
		mov	al,es:[di]
		mov	dx,8
loc_65:
		ror	al,1			; Rotate
		adc	ah,ah
		dec	dx
		jnz	loc_65			; Jump if not zero
		mov	es:[di],ah
		inc	di
		loop	locloop_64		; Loop if cx > 0

		pop	si
		pop	ax
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	bl,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		mov	ax,0B800h
		mov	es,ax
		push	di
		mov	cx,11h

locloop_66:
		lodsw				; String [si] to ax
		mov	cs:data_74e,ax
		mov	ax,ds:data_98e[si]
		mov	cs:data_75e,ax
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		or	es:[di],ax
		inc	di
		inc	di
		loop	locloop_66		; Loop if cx > 0

		pop	di
		add	di,4Eh
		push	cs
		pop	ds
		mov	si,data_85e
		mov	cx,11h

locloop_67:
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cs:data_74e,ax
		mov	ax,[si+20h]
		xchg	ah,al
		mov	cs:data_75e,ax
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		or	es:[di],ax
		dec	di
		dec	di
		loop	locloop_67		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		mov	bx,ax
		mov	al,ds:data_70e[bx]
		mov	ds:data_78e,al
		mov	ax,0B800h
		mov	es,ax
		mov	di,284h
		mov	si,data_68e
loc_68:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_69			; Jump if zero
		call	equip_func_7
		add	di,0A0h
		jmp	short loc_68
loc_69:
		add	di,data_95e
loc_70:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_71			; Jump if zero
		call	equip_func_7
		inc	di
		jmp	short loc_70
loc_71:
		add	di,data_93e
loc_72:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_73			; Jump if zero
		call	equip_func_7
		add	di,0FF60h
		jmp	short loc_72
loc_73:
		add	di,9Fh
loc_74:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_75			; Jump if zero
		call	equip_func_7
		dec	di
		jmp	short loc_74
loc_75:
		add	di,0A1h
		mov	si,data_69e
loc_76:
		mov	byte ptr cs:data_91e,0
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_77			; Jump if not zero
		retn
loc_77:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_78:
		push	cx
		mov	al,18h
		call	equip_func_7
		add	di,0A0h
		pop	cx
		loop	locloop_78		; Loop if cx > 0

		add	di,data_94e
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_79			; Jump if not zero
		retn
loc_79:
		xor	cx,cx			; Zero register
		mov	cl,al

locloop_80:
		push	cx
		mov	al,18h
		call	equip_func_7
		inc	di
		pop	cx
		loop	locloop_80		; Loop if cx > 0

		dec	di
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
		call	equip_func_7
		add	di,0FF60h
		pop	cx
		loop	locloop_82		; Loop if cx > 0

		add	di,0A0h
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
		call	equip_func_7
		dec	di
		pop	cx
		loop	locloop_84		; Loop if cx > 0

		inc	di
loc_85:
		cmp	byte ptr cs:data_91e,0Ch
		jb	loc_85			; Jump if below
		jmp	short loc_76

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

equip_func_7		proc	near
		push	si
		push	di
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,3945h
		mov	si,ax
		lodsb				; String [si] to al
		and	al,cs:data_78e
		or	al,[si+3]
		stosb				; Store al to es:[di]
		add	di,1FFFh
		cmp	di,4000h
		jb	loc_86			; Jump if below
		add	di,data_102e
loc_86:
		lodsb				; String [si] to al
		and	al,cs:data_78e
		or	al,[si+3]
		stosb				; Store al to es:[di]
		add	di,1FFFh
		cmp	di,4000h
		jb	loc_87			; Jump if below
		add	di,data_102e
loc_87:
		lodsb				; String [si] to al
		and	al,cs:data_78e
		or	al,[si+3]
		stosb				; Store al to es:[di]
		add	di,1FFFh
		cmp	di,4000h
		jb	loc_88			; Jump if below
		add	di,data_102e
loc_88:
		lodsb				; String [si] to al
		and	al,cs:data_78e
		or	al,[si+3]
		stosb				; Store al to es:[di]
		pop	di
		pop	si
		retn
equip_func_7		endp

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
		db	0ADh, 4Ah, 53h, 51h, 8Ah,0C5h
		db	0F6h,0E1h, 8Bh,0E8h, 06h, 1Fh
		db	 8Bh,0F7h, 8Ch,0C8h, 05h, 00h
		db	 30h, 8Eh,0C0h,0BFh, 00h, 00h
		db	 2Eh,0C7h, 06h,0A8h, 4Ah, 00h
		db	 00h, 2Eh,0C7h, 06h,0A2h, 4Ah
		db	 00h, 00h, 2Eh,0C7h, 06h,0A4h
		db	 4Ah, 00h, 00h, 2Eh,0C7h, 06h
		db	0A6h, 4Ah, 00h, 00h, 8Bh,0CDh
		db	0D1h,0E9h

locloop_89:
		push	si
		test	byte ptr cs:data_80e,1
		jz	loc_90			; Jump if zero
		mov	ax,[si]
		mov	cs:data_73e,ax
		add	si,bp
loc_90:
		test	byte ptr cs:data_80e,2
		jz	loc_91			; Jump if zero
		mov	ax,[si]
		mov	cs:data_74e,ax
		add	si,bp
loc_91:
		test	byte ptr cs:data_80e,4
		jz	loc_92			; Jump if zero
		mov	ax,[si]
		mov	cs:data_75e,ax
loc_92:
		call	equip_process_loop_5
		stosw				; Store ax to es:[di]
		pop	si
		inc	si
		inc	si
		loop	locloop_89		; Loop if cx > 0

		pop	cx
		pop	bx
		sub	bx,410h
		mov	byte ptr cs:data_78e,0
		mov	byte ptr cs:data_79e,0
		mov	cs:data_81e,cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,data_101e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

locloop_93:
		push	cx
		mov	al,cs:data_79e
		mov	cs:data_78e,al
		mov	byte ptr cs:data_91e,0
		mov	cx,0Dh

locloop_94:
		push	cx
		push	bx
		push	si
		call	extract_bits
		pop	si
		pop	bx
		pop	cx
		add	byte ptr cs:data_78e,8
		loop	locloop_94		; Loop if cx > 0

		pop	cx
loc_95:
		cmp	byte ptr cs:data_91e,14h
		jb	loc_95			; Jump if below
		inc	byte ptr cs:data_79e
		loop	locloop_93		; Loop if cx > 0

		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

extract_bits		proc	near
		mov	al,cs:data_78e
		add	al,10h
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	dl,50h			; 'P'
		mul	dl			; ax = reg * al
		add	ax,4
		add	di,ax
		cmp	cs:data_78e,bl
		jb	loc_98			; Jump if below
		mov	al,bl
		add	al,cs:data_81e
		cmp	cs:data_78e,al
		jae	loc_98			; Jump if above or =
		mov	al,cs:data_78e
		sub	al,bl
		mul	byte ptr cs:data_81e+1	; ax = data * al
		add	si,ax
		mov	byte ptr cs:data_77e,0
		mov	cx,48h

locloop_96:
		push	cx
		mov	byte ptr es:[di],0
		cmp	cs:data_77e,bh
		jb	loc_97			; Jump if below
		mov	al,bh
		add	al,byte ptr cs:data_81e+1
		cmp	cs:data_77e,al
		jae	loc_97			; Jump if above or =
		movsb				; Mov [si] to es:[di]
		dec	di
loc_97:
		inc	di
		inc	byte ptr cs:data_77e
		pop	cx
		loop	locloop_96		; Loop if cx > 0

		retn
loc_98:
		mov	cx,24h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
extract_bits		endp

			                        ;* No entry point to code
		mov	cs:data_78e,bl
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
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register
		sub	cx,5
		push	cx
		push	di
		call	fill_buffer
		pop	di
		inc	byte ptr cs:data_78e
		add	di,2000h
		cmp	di,4000h
		jb	loc_99			; Jump if below
		add	di,data_89e
loc_99:
		mov	cx,2
		call	clear_buffer
		pop	cx

locloop_100:
		push	cx
		call	equip_get_value
		or	byte ptr es:[di],30h	; '0'
		and	byte ptr es:[di],0F0h
		or	byte ptr es:[bx+di-1],0Ch
		and	byte ptr es:[bx+di-1],0Fh
		inc	byte ptr cs:data_78e
		add	di,2000h
		cmp	di,4000h
		jb	loc_101			; Jump if below
		add	di,data_89e
loc_101:
		pop	cx
		loop	locloop_100		; Loop if cx > 0

		mov	cx,1
		call	clear_buffer

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

fill_buffer		proc	near
		call	equip_get_value
		or	byte ptr es:[di],3Fh	; '?'
		inc	di
		mov	cx,bx
		sub	cx,2
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	byte ptr es:[di],0FCh
		retn
fill_buffer		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

clear_buffer		proc	near

locloop_102:
		push	cx
		push	di
		call	equip_get_value
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
		inc	byte ptr cs:data_78e
		add	di,2000h
		cmp	di,4000h
		jb	loc_103			; Jump if below
		add	di,0C050h
loc_103:
		pop	cx
		loop	locloop_102		; Loop if cx > 0

		retn
clear_buffer		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

equip_get_value		proc	near
		mov	word ptr es:[di-1],0
		retn
equip_get_value		endp

			                        ;* No entry point to code
		push	bx
		push	es
		push	di
		mov	cx,1028h

locloop_104:
		mov	al,es:[di]
		and	al,es:data_15[di]
		mov	ah,es:data_61e[di]
		not	ah
		and	al,ah
		not	al
		and	es:[di],al
		and	es:data_15[di],al
		and	es:data_61e[di],al
		mov	al,es:data_61e[di]
		mov	ah,es:[di]
		not	ah
		and	al,ah
		mov	ah,es:data_15[di]
		not	ah
		and	al,ah
		or	es:[di],al
		or	es:data_15[di],al
		not	al
		and	es:data_61e[di],al
		inc	di
		loop	locloop_104		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,2F58h
		jmp	loc_31
			                        ;* No entry point to code
		push	ds
		mov	ds:data_83e,di
		mov	ds:data_84e,es
		mov	di,69Ah
		add	di,ds:data_83e
		call	equip_process_loop_4
		mov	di,6BCh
		add	di,ds:data_83e
		call	equip_process_loop_4
		mov	ax,0B800h
		mov	es,ax
		mov	ds,cs:data_84e
		mov	cx,44h
loc_105:
		push	cx
		mov	byte ptr cs:data_91e,0
		mov	ax,44h
		sub	ax,cx
		add	ax,ax
		push	ax
		mov	bl,al
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		push	ax
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		pop	ax
		add	ax,cs:data_83e
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	loc_106			; Jump if below
		cmp	ax,71h
		jae	loc_106			; Jump if above or =
		call	equip_process_loop_3
		jmp	short loc_107
loc_106:
		call	equip_process_loop_2
loc_107:
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
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		pop	ax
		add	ax,cs:data_83e
		mov	si,ax
		pop	ax
		cmp	ax,16h
		jb	loc_108			; Jump if below
		cmp	ax,71h
		jae	loc_108			; Jump if above or =
		call	equip_process_loop_3
		jmp	short loc_109
loc_108:
		call	equip_process_loop_2
loc_109:
		cmp	byte ptr cs:data_91e,4
		jb	loc_109			; Jump if below
		pop	cx
		loop	locloop_110		; Loop if cx > 0

		jmp	short loc_111

locloop_110:
		jmp	loc_105
loc_111:
		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

equip_process_loop_2		proc	near
		mov	cx,28h
		mov	word ptr cs:data_76e,0

locloop_112:
		mov	ax,ds:data_86e[si]
		mov	cs:data_75e,ax
		mov	ax,ds:data_63e[si]
		mov	cs:data_74e,ax
		lodsw				; String [si] to ax
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		stosw				; Store ax to es:[di]
		loop	locloop_112		; Loop if cx > 0

		retn
equip_process_loop_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

equip_process_loop_3		proc	near
		mov	cx,0Bh
		mov	word ptr cs:data_76e,0

locloop_113:
		xor	ah,ah			; Zero register
		mov	al,ds:data_86e[si]
		mov	cs:data_75e,ax
		mov	al,ds:data_63e[si]
		mov	cs:data_74e,ax
		lodsb				; String [si] to al
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		stosb				; Store al to es:[di]
		loop	locloop_113		; Loop if cx > 0

		add	si,18h
		add	di,18h
		mov	cx,5

locloop_114:
		mov	ax,ds:data_86e[si]
		mov	cs:data_75e,ax
		mov	ax,ds:data_63e[si]
		mov	cs:data_74e,ax
		lodsw				; String [si] to ax
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		stosw				; Store ax to es:[di]
		loop	locloop_114		; Loop if cx > 0

		add	si,18h
		add	di,18h
		mov	cx,0Bh

locloop_115:
		xor	ah,ah			; Zero register
		mov	al,ds:data_86e[si]
		mov	cs:data_75e,ax
		mov	al,ds:data_63e[si]
		mov	cs:data_74e,ax
		lodsb				; String [si] to al
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		stosb				; Store al to es:[di]
		loop	locloop_115		; Loop if cx > 0

		retn
equip_process_loop_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

equip_process_loop_4		proc	near
		push	di
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

locloop_116:
		mov	byte ptr es:[di],30h	; '0'
		mov	byte ptr es:[di+19h],0Ch
		add	di,50h
		loop	locloop_116		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		pop	di
		add	di,data_63e
		push	di
		mov	ax,0FD7Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,2Dh

locloop_117:
		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	byte ptr es:[di],70h	; 'p'
		mov	byte ptr es:[di+19h],0Dh
		add	di,50h
		loop	locloop_117		; Loop if cx > 0

		mov	byte ptr es:[di],0B0h
		mov	byte ptr es:[di+19h],0Eh
		add	di,50h
		mov	ax,0FD7Fh
		call	fill_buffer_2
		pop	di
		add	di,data_63e
		mov	ax,0FC3Fh
		call	fill_buffer_2
		add	di,36h
		mov	cx,5Bh

locloop_118:
		mov	byte ptr es:[di],30h	; '0'
		mov	byte ptr es:[di+19h],0Ch
		add	di,50h
		loop	locloop_118		; Loop if cx > 0

		mov	ax,0FC3Fh
		call	fill_buffer_2
		retn
equip_process_loop_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

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
		mov	ds:data_83e,di
		mov	ds:data_84e,es
		mov	ax,0B800h
		mov	es,ax
		mov	ds,cs:data_84e
		mov	cx,39h

locloop_119:
		mov	byte ptr cs:data_91e,0
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,39h
		add	ax,ax
		call	extract_bits_2
		pop	ax
		push	ax
		add	ax,ax
		dec	ax
		call	extract_bits_2
loc_120:
		cmp	byte ptr cs:data_91e,4
		jb	loc_120			; Jump if below
		pop	cx
		loop	locloop_119		; Loop if cx > 0

		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

extract_bits_2		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,cs:data_83e
		mov	si,ax
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		pop	ax
		cmp	ax,14h
		jae	loc_121			; Jump if above or =
		mov	cx,2Fh
		jmp	short loc_122
loc_121:
		mov	cx,23h
		cmp	ax,17h
		jb	loc_122			; Jump if below
		cmp	ax,1Ch
		jb	loc_124			; Jump if below
		mov	cx,21h
loc_122:
		mov	word ptr cs:data_76e,0

locloop_123:
		xor	ah,ah			; Zero register
		mov	al,ds:data_62e[si]
		mov	cs:data_75e,ax
		mov	al,byte ptr data_53[si]
		mov	cs:data_74e,ax
		lodsb				; String [si] to al
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		stosb				; Store al to es:[di]
		loop	locloop_123		; Loop if cx > 0

		retn
loc_124:
		mov	cx,21h
		mov	word ptr cs:data_76e,0

locloop_125:
		xor	ah,ah			; Zero register
		mov	al,ds:data_62e[si]
		mov	cs:data_75e,ax
		mov	al,byte ptr data_53[si]
		mov	cs:data_74e,ax
		lodsb				; String [si] to al
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		stosb				; Store al to es:[di]
		loop	locloop_125		; Loop if cx > 0

		xor	ah,ah			; Zero register
		mov	al,ds:data_62e[si]
		mov	cs:data_75e,ax
		mov	al,byte ptr data_53[si]
		mov	cs:data_74e,ax
		lodsb				; String [si] to al
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		and	al,0FCh
		and	byte ptr es:[di],3
		or	es:[di],al
		retn
extract_bits_2		endp

data_15		db	1Eh			; Data table (indexed access)
		db	 89h, 3Eh,0B0h, 4Ah, 8Ch, 06h
		db	0B2h, 4Ah,0B8h, 00h,0B8h, 8Eh
		db	0C0h, 2Eh, 8Eh, 1Eh,0B2h, 4Ah
		db	0B9h, 39h, 00h

locloop_126:
		mov	byte ptr cs:data_91e,0
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,39h
		add	ax,ax
		call	extract_bits_3
		pop	ax
		push	ax
		add	ax,ax
		dec	ax
		call	extract_bits_3
loc_127:
		cmp	byte ptr cs:data_91e,4
		jb	loc_127			; Jump if below
		pop	cx
		loop	locloop_126		; Loop if cx > 0

		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

extract_bits_3		proc	near
		push	ax
		mov	bl,al
		mov	al,2Fh			; '/'
		mul	bl			; ax = reg * al
		add	ax,3CDh
		add	ax,cs:data_83e
		mov	si,ax
		add	bl,14h
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		add	di,ax
		add	di,21h
		pop	ax
		cmp	ax,5Eh
		mov	cx,2Fh
		jnc	loc_129			; Jump if carry=0
		mov	cx,7
		mov	word ptr cs:data_76e,0

locloop_128:
		mov	ax,ds:data_62e[si]
		mov	cs:data_75e,ax
		mov	ax,data_53[si]
		mov	cs:data_74e,ax
		lodsw				; String [si] to ax
		mov	cs:data_73e,ax
		call	equip_process_loop_5
		stosw				; Store ax to es:[di]
		loop	locloop_128		; Loop if cx > 0

		mov	cx,21h
loc_129:
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn
extract_bits_3		endp

			                        ;* No entry point to code
		push	ax
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
		pop	ax
		mov	ah,al
		mov	cx,8

locloop_130:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_131			; Jump if below
		add	di,0C050h
loc_131:
		loop	locloop_130		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		dec	ax
		mov	cx,100h
		mul	cx			; dx:ax = reg * ax
		add	ax,40FDh
		mov	cs:data_72e,ax
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
		db	15 dup (0)
		db	1, 0
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
		db	1, 2, 2, 3
data_53		dw	303h			; Data table (indexed access)
		db	3, 3, 1
		db	7 dup (3)
		db	1, 3, 2, 3, 3, 3
		db	3, 0, 0, 0, 1, 1
		db	1, 2, 3, 0, 1, 2
		db	2, 1, 1, 2, 3, 0
		db	1, 2, 3, 1, 1, 1
		db	1, 0, 1, 2, 2, 1
		db	1, 1, 1, 0, 2, 2
		db	3, 1, 1, 2, 3, 0
		db	2, 2, 2, 1, 1, 2
		db	3, 1
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

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

equip_process_loop_5		proc	near
		push	cx
		push	si
		mov	si,cs:data_72e
		mov	cx,8

locloop_132:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_76e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_75e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_74e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_73e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_76e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_75e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_74e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_73e,1	; Rotate
		adc	bx,bx
		add	ax,ax
		add	ax,ax
		or	al,cs:[bx+si]
		loop	locloop_132		; Loop if cx > 0

		pop	si
		pop	cx
		retn
equip_process_loop_5		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,0B800h
		mov	ds,ax
		xor	si,si			; Zero register
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,data_96e
		mov	cx,0C8h

locloop_133:
		push	cx
		push	si
		mov	cx,28h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		add	si,2000h
		cmp	si,4000h
		jb	loc_134			; Jump if below
		add	si,0C050h
loc_134:
		pop	cx
		loop	locloop_133		; Loop if cx > 0

		pop	ds
		xor	ax,ax			; Zero register
		mov	di,data_99e
		mov	cx,2000h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
			                        ;* No entry point to code
		push	bx
		mov	bl,ah
		xor	bh,bh			; Zero register
		mov	ah,cs:data_71e[bx]
		pop	bx
		jmp	word ptr cs:data_60e
		db	 00h, 05h, 02h, 07h, 03h, 04h
		db	 06h, 01h,0C3h
		db	888 dup (0)

seg_a		ends



		end	start
