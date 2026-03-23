
PAGE  59,132

;==========================================================================
;
;  IMAGE_DECODER_B - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	4100h			;*
data_2e		equ	6000h			;*
data_3e		equ	8000h			;*
data_4e		equ	8004h			;*
data_5e		equ	8100h			;*
data_6e		equ	0D000h			;*
data_13e	equ	347Ah			;*
data_14e	equ	34D6h			;*
data_15e	equ	3737h			;*
data_16e	equ	38D5h			;*
data_17e	equ	3B1Dh			;*
data_18e	equ	3C24h			;*
data_19e	equ	3CACh			;*
data_20e	equ	3CAEh			;*
data_21e	equ	3CAFh			;*
data_22e	equ	3CB0h			;*
data_23e	equ	3CB2h			;*
data_24e	equ	3CB5h			;*
data_25e	equ	3CB7h			;*
data_26e	equ	3CB9h			;*
data_27e	equ	3CBBh			;*
data_28e	equ	3CBDh			;*
data_29e	equ	3CBFh			;*
data_31e	equ	3CC3h			;*
data_32e	equ	3CEBh			;*
data_33e	equ	3E53h			;*
data_34e	equ	3E83h			;*
data_35e	equ	3EB3h			;*
data_36e	equ	3EE3h			;*
data_37e	equ	3F13h			;*
data_38e	equ	50F1h			;*
data_39e	equ	5FA6h			;*
data_40e	equ	6000h			;*
data_41e	equ	0A000h			;*
data_42e	equ	0A058h			;*
data_43e	equ	0A05Ah			;*
data_44e	equ	0C00Fh			;*
data_45e	equ	0E005h			;*
data_46e	equ	0F435h			;*
data_47e	equ	0F502h			;*
data_48e	equ	0F504h			;*
data_49e	equ	0FF2Ah			;*
data_50e	equ	0FF2Ch			;*
data_51e	equ	0FF57h			;*
data_52e	equ	0FF68h			;*
data_53e	equ	0FF6Ah			;*
data_54e	equ	0			;*
data_55e	equ	4FDh
data_56e	equ	34CFh
data_57e	equ	3506h
data_58e	equ	5FA6h
data_59e	equ	6000h
data_60e	equ	7FA6h
data_61e	equ	0A058h
data_62e	equ	0A05Ah

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_09		proc	far

start:
		adc	dx,[bx+di]
		add	[bx+si],al
		or	al,3Ah			; ':'
		sub	[bx+si],dh
		push	di
		xor	ds:data_46e[bx+di],cl
		xor	ax,362Ch
		xchg	bp,ax
		db	 36h,0B3h, 32h,0C8h, 34h, 33h
		db	 35h, 8Eh, 34h,0CBh, 36h, 09h
		db	 37h, 83h, 37h, 49h, 37h, 44h
		db	 39h,0A6h, 39h, 23h, 38h,0CBh
		db	 3Ah, 48h, 3Ah, 1Eh,0BEh, 5Fh
		db	 2Ch,0BFh, 00h,0A0h, 0Eh, 07h
		db	0B8h, 00h,0B0h, 8Eh,0D8h,0B9h
		db	 1Ch, 00h

locloop_1:
		push	cx
		push	si
		mov	cx,18h

locloop_2:
		movsw				; Mov [si] to es:[di]
		add	si,1FFEh
		cmp	si,6000h
		jb	loc_3			; Jump if below
		add	si,data_43e
loc_3:
		loop	locloop_2		; Loop if cx > 0

		pop	si
		pop	cx
		inc	si
		inc	si
		loop	locloop_1		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_37e
		xor	ax,ax			; Zero register
		mov	cx,100h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,ds:data_49e
		cmp	byte ptr [si+1Dh],0FDh
		jne	loc_4			; Jump if not equal
		call	decb_multiply
loc_4:
		mov	word ptr ds:data_19e,2C5Fh
		mov	si,ds:data_49e
		add	si,20h
		push	cs
		pop	es
		mov	di,0E000h
		mov	byte ptr ds:data_20e,0
loc_5:
		call	decb_scan_loop
		xor	bl,bl			; Zero register
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_6			; Jump if zero
		call	decb_func_4
loc_6:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_7			; Jump if zero
		call	decb_func_4
loc_7:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_8			; Jump if zero
		call	decb_func_4
loc_8:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_9			; Jump if zero
		call	decb_func_3
loc_9:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_10			; Jump if zero
		call	decb_func_3
loc_10:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_11			; Jump if zero
		call	decb_func_2
loc_11:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_12			; Jump if zero
		call	decb_func_3
loc_12:
		inc	bl
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_13			; Jump if zero
		call	decb_func_3
loc_13:
		add	word ptr ds:data_19e,2
		inc	byte ptr ds:data_20e
		cmp	byte ptr ds:data_20e,1Ch
		jne	loc_5			; Jump if not equal
		retn

zr1_09		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_scan_loop		proc	near
		cmp	byte ptr ds:data_20e,1Bh
		jne	loc_14			; Jump if not equal
		retn
loc_14:
		mov	al,byte ptr ds:[83h]
		cmp	ds:data_20e,al
		je	loc_15			; Jump if equal
		retn
loc_15:
		push	di
		push	es
		push	si
		mov	al,byte ptr ds:[83h]
		add	al,al
		xor	ah,ah			; Zero register
		mov	di,ax
		add	di,data_38e
		mov	ax,0B000h
		mov	es,ax
		mov	si,data_33e
		mov	cx,2

locloop_16:
		push	cx
		push	di
		call	decb_scan_loop_2
		pop	di
		inc	di
		inc	di
		pop	cx
		loop	locloop_16		; Loop if cx > 0

		pop	si
		pop	es
		pop	di
		retn
decb_scan_loop		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_func_2		proc	near
		cmp	byte ptr [si-1],0FDh
		jne	loc_17			; Jump if not equal
		jmp	loc_41

;���� External Entry into Subroutine ��������������������������������������

decb_func_3:
loc_17:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	loc_18			; Jump if not zero
		retn
loc_18:
		dec	di
		dec	si
		mov	dl,[si]
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,ds:data_19e
		or	bl,bl			; Zero ?
		jz	loc_21			; Jump if zero
loc_19:
		add	di,40B4h
		cmp	di,6000h
		jb	loc_20			; Jump if below
		add	di,data_62e
loc_20:
		dec	bl
		jnz	loc_19			; Jump if not zero
loc_21:
		mov	bl,dl
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:data_37e[bx],0FFFFh
		jnz	loc_24			; Jump if not zero
		mov	ds:data_37e[bx],di
		mov	ax,10h
		mul	dl			; ax = reg * al
		mov	si,ax
		add	si,data_5e
		mov	ds,cs:data_50e
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

locloop_22:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,data_59e
		jb	loc_23			; Jump if below
		mov	ax,[si-2]
		stosw				; Store ax to es:[di]
		add	di,data_61e
loc_23:
		loop	locloop_22		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_24:
		mov	si,ds:data_37e[bx]
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	cx,8

locloop_25:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,data_59e
		jb	loc_26			; Jump if below
		mov	ax,[si-2]
		stosw				; Store ax to es:[di]
		add	di,data_42e
loc_26:
		add	si,1FFEh
		cmp	si,6000h
		jb	loc_27			; Jump if below
		add	si,data_43e
loc_27:
		loop	locloop_25		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

;���� External Entry into Subroutine ��������������������������������������

decb_func_4:
		mov	al,[di-1]
		mov	byte ptr [di-1],0FEh
		inc	al
		jnz	loc_28			; Jump if not zero
		retn
loc_28:
		push	bx
		push	es
		mov	dl,[si-1]
		mov	bl,dl
		xor	bh,bh			; Zero register
		mov	es,cs:data_50e
		add	bx,es:data_3e
		mov	dh,es:[bx]
		pop	es
		pop	bx
		or	dh,dh			; Zero ?
		jnz	loc_29			; Jump if not zero
		jmp	loc_17
loc_29:
		dec	di
		dec	si
		movsb				; Mov [si] to es:[di]
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,ds:data_19e
		or	bl,bl			; Zero ?
		jz	loc_32			; Jump if zero
		push	bx
loc_30:
		add	di,40B4h
		cmp	di,6000h
		jb	loc_31			; Jump if below
		add	di,data_62e
loc_31:
		dec	bl
		jnz	loc_30			; Jump if not zero
		pop	bx
loc_32:
		mov	ax,10h
		mul	dl			; ax = reg * al
		mov	si,ax
		mov	bp,ax
		add	si,data_5e
		add	bp,data_6e
		mov	ax,30h
		mul	byte ptr ds:data_20e	; ax = data * al
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ax
		add	bx,data_41e
		mov	ds,cs:data_50e
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

locloop_33:
		mov	ax,cs:[bx]
		inc	bx
		inc	bx
		and	ax,ds:[bp]
		inc	bp
		inc	bp
		or	ax,[si]
		inc	si
		inc	si
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,data_59e
		jb	loc_34			; Jump if below
		stosw				; Store ax to es:[di]
		add	di,data_42e
loc_34:
		loop	locloop_33		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	ah,[di-1]
		or	ah,ah			; Zero ?
		jnz	loc_35			; Jump if not zero
		retn
loc_35:
		cmp	ah,19h
		jb	loc_36			; Jump if below
		retn
loc_36:
		push	di
		push	es
		mov	es,cs:data_50e
		mov	di,es:data_4e
		mov	cl,es:[di]
		or	cl,cl			; Zero ?
		jz	loc_39			; Jump if zero
		inc	di
loc_37:
		mov	al,es:[di]
		cmp	al,0FFh
		je	loc_39			; Jump if equal
		cmp	ah,al
		jne	loc_38			; Jump if not equal
		mov	al,es:[di+1]
		mov	[si-1],al
		jmp	short loc_39
loc_38:
		inc	di
		inc	di
		dec	cl
		jnz	loc_37			; Jump if not zero
loc_39:
		pop	es
		pop	di
		retn
		db	0BFh, 53h, 3Eh

;���� External Entry into Subroutine ��������������������������������������

decb_func_5:
		mov	cx,6

;���� External Entry into Subroutine ��������������������������������������

decb_func_6:
		push	cs
		pop	es

locloop_40:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	cl,10h
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_5e
		mov	ds,cs:data_50e
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	si
		pop	ds
		pop	cx
		loop	locloop_40		; Loop if cx > 0

		retn
loc_41:
		push	ds
		push	si
		push	es
		push	di
		mov	di,data_22e
		movsw				; Mov [si] to es:[di]
		add	si,5
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dl,cs:data_20e
		add	dl,4
		xor	dh,dh			; Zero register
		add	dx,word ptr cs:[80h]
		mov	ds:data_24e,dx
		call	decb_func_8
		mov	es:data_21e,al
		cmp	byte ptr es:data_23e,0FDh
		jne	loc_42			; Jump if not equal
		inc	dx
		call	decb_func_8
		mov	es:data_23e,al
loc_42:
		mov	si,3CAFh
		mov	di,3EB3h
		call	decb_func_5
		mov	si,cs:data_44e
loc_43:
		call	decb_scan_loop_3
		or	bl,bl			; Zero ?
		jz	loc_44			; Jump if zero
		push	si
		push	bx
		call	decb_multiply_2
		pop	bx
		mov	es,cs:data_50e
		mov	si,data_21e
		call	decb_get_value
		pop	si
loc_44:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_43			; Jump if not zero
		pop	di
		pop	es
		mov	ch,es:[di-1]
		mov	cl,es:[di+7]
		push	es
		push	di
		push	cx
		mov	di,cs:data_19e
		mov	bl,5
loc_45:
		add	di,40B4h
		cmp	di,6000h
		jb	loc_46			; Jump if below
		add	di,data_43e
loc_46:
		dec	bl
		jnz	loc_45			; Jump if not zero
		push	di
		mov	si,data_35e
		mov	ax,0B000h
		mov	es,ax
		inc	ch
		jz	loc_47			; Jump if zero
		call	decb_scan_loop_2
loc_47:
		pop	di
		pop	cx
		cmp	byte ptr cs:data_20e,1Bh
		je	loc_48			; Jump if equal
		mov	si,data_36e
		inc	di
		inc	di
		inc	cl
		jz	loc_48			; Jump if zero
		call	decb_scan_loop_2
loc_48:
		pop	di
		pop	es
		mov	al,0FFh
		mov	byte ptr es:[di-1],0FEh
		mov	es:[di],al
		mov	es:[di+1],al
		mov	es:[di+7],al
		mov	es:[di+8],al
		mov	es:[di+9],al
		pop	si
		pop	ds
		retn
decb_func_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_multiply		proc	near
		push	es
		push	ds
		mov	si,ds:data_49e
		add	si,25h
		mov	di,data_21e
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	dx,word ptr ds:[80h]
		add	dx,3
		mov	ds:data_24e,dx
		cmp	byte ptr ds:data_21e,0FDh
		jne	loc_49			; Jump if not equal
		inc	dx
		call	decb_func_8
		mov	ds:data_21e,al
loc_49:
		mov	si,3CAFh
		mov	di,3EB3h
		mov	cx,3
		call	decb_func_6
		mov	si,cs:data_44e
loc_50:
		call	decb_scan_loop_3
		or	bl,bl			; Zero ?
		jz	loc_51			; Jump if zero
		push	si
		dec	bl
		mov	al,3
		mul	bl			; ax = reg * al
		push	ax
		call	decb_multiply_2
		pop	ax
		add	di,ax
		mov	bp,di
		mov	es,cs:data_50e
		mov	si,3CAFh
		mov	di,3EB3h
		call	decb_multiply_3
		pop	si
loc_51:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_50			; Jump if not zero
		mov	di,data_38e
		mov	si,data_35e
		mov	ax,0B000h
		mov	es,ax
		call	decb_scan_loop_2
		pop	ds
		pop	es
		mov	di,data_45e
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn
decb_multiply		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_func_8		proc	near
		call	decb_func_9
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_52			; Jump if equal
		retn
loc_52:
		add	si,8
		call	decb_func_10
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_52			; Jump if equal
		retn
decb_func_8		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_func_9		proc	near
		mov	si,ds:data_44e

;���� External Entry into Subroutine ��������������������������������������

decb_func_10:
loc_53:
		cmp	dx,[si]
		jne	loc_54			; Jump if not equal
		retn
loc_54:
		add	si,8
		jmp	short loc_53
decb_func_9		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_scan_loop_2		proc	near
		mov	cx,18h

locloop_55:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,data_59e
		jb	loc_56			; Jump if below
		mov	ax,[si-2]
		stosw				; Store ax to es:[di]
		add	di,0A058h
loc_56:
		loop	locloop_55		; Loop if cx > 0

		retn
decb_scan_loop_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_get_value		proc	near
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_13e[bx]	;*
		retn
decb_get_value		endp

			                        ;* No entry point to code
		xchg	[si],dh
;*		jle	loc_58			;*Jump if < or =
		db	 7Eh, 34h		;  Fixup - byte match
		mov	di,3EB3h
		call	decb_multiply_3
		jmp	short loc_61
			                        ;* No entry point to code
		add	si,3
		mov	di,3EE3h
		jmp	short loc_61

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_multiply_2		proc	near
		mov	al,[si+2]
		mov	ch,al
		and	al,7Fh
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,4000h
		mov	di,ax
		xor	dl,dl			; Zero register
		or	ch,ch			; Zero ?
		js	loc_57			; Jump if sign=1
		mov	dl,4
loc_57:
		mov	al,[si+4]
		and	al,3
		add	al,dl
		mov	cl,6
		mul	cl			; ax = reg * al
		add	di,ax
		retn
decb_multiply_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_scan_loop_3		proc	near
		mov	cx,2
		mov	dx,ds:data_24e

locloop_59:
		mov	bl,cl
		cmp	[si],dx
		jne	loc_60			; Jump if not equal
		retn
loc_60:
		inc	dx
		loop	locloop_59		; Loop if cx > 0

		mov	bl,cl
		retn
decb_scan_loop_3		endp

			                        ;* No entry point to code
		mov	bp,di
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_14e[bx]	;*
		retn
			                        ;* No entry point to code
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		xor	al,0E4h
		xor	al,0DCh
		xor	al,83h
		lds	ax,dword ptr [bp+di]	; Load seg:offset ptr
		mov	di,3E53h
		jmp	short loc_61
			                        ;* No entry point to code
		mov	di,3E53h
		call	decb_multiply_3
		jmp	short loc_61
			                        ;* No entry point to code
		mov	di,data_34e
		add	si,3
		jmp	short loc_61

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_multiply_3		proc	near
loc_61:
		mov	cx,3

locloop_62:
		push	cx
		mov	byte ptr [si],0FFh
		inc	si
		push	ds
		push	si
		mov	al,es:[bp]
		inc	bp
		push	es
		push	bp
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		add	ax,7000h
		mov	cs:data_29e,ax
		mov	ax,cs
		add	ax,2000h
		mov	word ptr cs:data_29e+2,ax
		mov	ds,cs:data_50e
		push	cs
		pop	es
		call	decb_process_loop
		pop	bp
		pop	es
		pop	si
		pop	ds
		pop	cx
		loop	locloop_62		; Loop if cx > 0

		retn
decb_multiply_3		endp

			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_33e
		mov	cx,6

locloop_63:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	cl,10h
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_2e
		add	ax,8000h
		mov	cs:data_29e,ax
		mov	ax,cs
		add	ax,2000h
		mov	word ptr cs:data_29e+2,ax
		mov	ds,cs:data_50e
		call	decb_process_loop
		pop	si
		pop	ds
		pop	cx
		loop	locloop_63		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_process_loop		proc	near
		push	ds
		push	si
		push	di
		lds	si,dword ptr cs:data_29e	; Load seg:offset ptr
		mov	cx,8

locloop_64:
		lodsw				; String [si] to ax
		and	es:[di],ax
		inc	di
		inc	di
		loop	locloop_64		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		mov	cx,8

locloop_65:
		lodsw				; String [si] to ax
		or	es:[di],ax
		inc	di
		inc	di
		loop	locloop_65		; Loop if cx > 0

		retn
decb_process_loop		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		std				; Set direction flag
		mov	si,53F8h
		mov	al,8
loc_66:
		call	copy_buffer
		add	si,2000h
		cmp	si,6000h
		jb	loc_67			; Jump if below
		call	copy_buffer
		add	si,0A05Ah
loc_67:
		dec	al
		jnz	loc_66			; Jump if not zero
		mov	si,data_57e
		mov	al,8
loc_68:
		call	copy_buffer_2
		add	si,2000h
		cmp	si,data_59e
		jb	loc_69			; Jump if below
		call	copy_buffer_2
		add	si,data_62e
loc_69:
		dec	al
		jnz	loc_68			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

copy_buffer		proc	near
		push	si
		mov	di,si
		dec	si
		dec	si
		mov	cx,36h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,1Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		pop	si
		retn
copy_buffer		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

copy_buffer_2		proc	near
		push	si
		mov	di,si
		sub	si,4
		mov	cx,34h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,20h
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		pop	si
		retn
copy_buffer_2		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		std				; Set direction flag
		mov	si,534h
		mov	al,10h
loc_70:
		call	copy_buffer_3
		add	si,2000h
		cmp	si,6000h
		jb	loc_71			; Jump if below
		call	copy_buffer_3
		add	si,data_62e
loc_71:
		dec	al
		jnz	loc_70			; Jump if not zero
		pop	ds
		cld				; Clear direction
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

copy_buffer_3		proc	near
		push	si
		mov	di,si
		dec	si
		mov	cx,37h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	si,1Dh
		movsb				; Mov [si] to es:[di]
		pop	si
		retn
copy_buffer_3		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	si,53C1h
		mov	al,8
loc_72:
		call	copy_buffer_4
		add	si,2000h
		cmp	si,6000h
		jb	loc_73			; Jump if below
		call	copy_buffer_4
		add	si,0A05Ah
loc_73:
		dec	al
		jnz	loc_72			; Jump if not zero
		mov	si,data_56e
		mov	al,8
loc_74:
		call	copy_buffer_5
		add	si,2000h
		cmp	si,data_59e
		jb	loc_75			; Jump if below
		call	copy_buffer_5
		add	si,data_62e
loc_75:
		dec	al
		jnz	loc_74			; Jump if not zero
		pop	ds
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

copy_buffer_4		proc	near
		push	si
		mov	di,si
		inc	si
		inc	si
		mov	cx,36h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,1Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		pop	si
		retn
copy_buffer_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

copy_buffer_5		proc	near
		push	si
		mov	di,si
		add	si,4
		mov	cx,34h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,20h
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		pop	si
		retn
copy_buffer_5		endp

			                        ;* No entry point to code
		push	ds
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	si,4FDh
		mov	al,10h
loc_76:
		call	copy_buffer_6
		add	si,2000h
		cmp	si,6000h
		jb	loc_77			; Jump if below
		call	copy_buffer_6
		add	si,data_62e
loc_77:
		dec	al
		jnz	loc_76			; Jump if not zero
		pop	ds
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

copy_buffer_6		proc	near
		push	si
		mov	di,si
		inc	si
		mov	cx,37h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		sub	si,1Dh
		movsb				; Mov [si] to es:[di]
		pop	si
		retn
copy_buffer_6		endp

			                        ;* No entry point to code
		push	ds
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,8000h
		add	bh,bh
		call	math_calc
		mov	di,ax
		mov	ds,cs:data_50e
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

locloop_78:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,data_59e
		jb	loc_79			; Jump if below
		mov	ax,[si-2]
		stosw				; Store ax to es:[di]
		add	di,0A058h
loc_79:
		loop	locloop_78		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	si
		push	di
		push	cs
		pop	ds
		call	math_calc
		mov	di,ax
		mov	ax,0B000h
		mov	es,ax
		mov	si,data_15e
		mov	cx,9

locloop_80:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,data_59e
		jb	loc_81			; Jump if below
		mov	ax,[si-2]
		stosw				; Store ax to es:[di]
		add	di,data_42e
loc_81:
		loop	locloop_80		; Loop if cx > 0

		pop	di
		pop	si
		pop	ds
		retn
		db	 00h, 00h, 28h, 00h, 2Ah, 00h
		db	 2Ah, 80h, 2Ah,0A0h, 2Ah, 80h
		db	 2Ah, 00h, 28h, 00h, 00h, 00h
		db	0E8h, 3Ah, 05h, 8Bh,0F8h,0BEh
		db	0C3h, 3Ch,0B8h, 00h,0B0h, 8Eh
		db	0C0h,0B9h, 09h, 00h

locloop_82:
		push	cx
		push	di
		push	si
		mov	cx,ds:data_53e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,2000h
		cmp	di,data_40e
		jb	loc_83			; Jump if below
		push	si
		push	di
		mov	cx,ds:data_53e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		add	di,0A05Ah
loc_83:
		add	si,28h
		pop	cx
		loop	locloop_82		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	si
		push	di
		push	di
		xor	ah,ah			; Zero register
		push	ax
		push	cs
		pop	es
		mov	di,data_31e
		xor	ax,ax			; Zero register
		mov	cx,0C8h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		push	ax
		add	ax,ax
		add	si,ax
		mov	si,[si]
		call	decb_func_23
		pop	ax
		pop	di
		test	byte ptr ds:data_51e,0FFh
		jz	loc_84			; Jump if zero
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	di,ax
		mov	dl,[di]
		mov	ax,[di+1]
		call	decb_process_loop_2
loc_84:
		pop	di
		pop	si
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_func_23		proc	near
		push	cs
		pop	es
		mov	di,data_32e
		xor	bl,bl			; Zero register
loc_85:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_86			; Jump if not zero
		retn
loc_86:
		push	bx
		push	ds
		push	si
		and	bl,3
		call	decb_func_24
		pop	si
		pop	ds
		pop	bx
		inc	bl
		jmp	short loc_85
decb_func_23		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_func_24		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		push	cs
		pop	ds
		add	si,ds:data_48e
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8
loc_87:
		push	bx
		lodsb				; String [si] to al
		mov	dl,4
loc_88:
		add	ax,ax
		add	ah,ah
		dec	dl
		jnz	loc_88			; Jump if not zero
		mov	al,ah
		shr	ah,1			; Shift w/zeros fill
		or	al,ah
		xor	bl,bl			; Zero register
		mov	bh,al
		shr	bx,cl			; Shift w/zeros fill
		or	es:[di],bh
		or	es:[di+1],bl
		add	di,28h
		pop	bx
		dec	bl
		jnz	loc_87			; Jump if not zero
		pop	di
		inc	di
		cmp	cl,6
		je	loc_89			; Jump if equal
		retn
loc_89:
		inc	di
		retn
decb_func_24		endp

			                        ;* No entry point to code
		push	dx
		push	ax
		push	cs
		pop	es
		mov	di,data_31e
		xor	ax,ax			; Zero register
		mov	cx,0C8h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	ax
		pop	dx
		call	decb_process_loop_4
		mov	di,3CEBh
		mov	si,38D4h
		mov	cx,7
		mov	bl,1
		mov	word ptr ds:data_53e,0Bh
		jmp	short locloop_90

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_process_loop_2		proc	near
		call	decb_process_loop_4
		push	cs
		pop	es
		mov	di,data_32e
		add	di,ds:data_52e
		mov	si,data_16e
		mov	cx,6
		mov	bl,1

locloop_90:
		push	cx
		push	bx
		push	di
		lodsb				; String [si] to al
		push	si
		call	decb_process_loop_3
		pop	si
		pop	di
		pop	bx
		mov	al,bl
		inc	di
		and	ax,1
		add	di,ax
		inc	bl
		pop	cx
		loop	locloop_90		; Loop if cx > 0

		retn
decb_process_loop_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_process_loop_3		proc	near
		inc	al
		jnz	loc_91			; Jump if not zero
		retn
loc_91:
		dec	al
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:data_47e
		mov	si,ax
		mov	cx,7

locloop_92:
		lodsb				; String [si] to al
		mov	ah,8
loc_93:
		add	al,al
		adc	dx,dx
		add	dx,dx
		dec	ah
		jnz	loc_93			; Jump if not zero
		mov	ax,dx
		shr	dx,1			; Shift w/zeros fill
		or	ax,dx
		test	bl,1
		jnz	loc_94			; Jump if not zero
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
loc_94:
		or	es:[di],ah
		or	es:[di+1],al
		add	di,28h
		loop	locloop_92		; Loop if cx > 0

		retn
decb_process_loop_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_process_loop_4		proc	near
		mov	di,38D4h
		call	decb_func_28
		mov	cx,6

locloop_95:
		test	byte ptr cs:[di],0FFh
		jz	loc_96			; Jump if zero
		retn
loc_96:
		mov	byte ptr cs:[di],0FFh
		inc	di
		loop	locloop_95		; Loop if cx > 0

		retn
decb_process_loop_4		endp

		db	7 dup (0)

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_func_28		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	decb_func_29
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	decb_func_29
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	decb_func_29
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	decb_func_30
		mov	cs:[di+3],dh
		mov	bx,64h
		call	decb_func_30
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	decb_func_30
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn
decb_func_28		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_func_29		proc	near
		xor	dh,dh			; Zero register
loc_97:
		sub	dl,cl
		jc	loc_100			; Jump if carry Set
		sub	ax,bx
		jnc	loc_98			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_99			; Jump if zero
		dec	dl
loc_98:
		inc	dh
		jmp	short loc_97
loc_99:
		add	ax,bx
loc_100:
		add	dl,cl
		retn
decb_func_29		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_func_30		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn
decb_func_30		endp

			                        ;* No entry point to code
		push	ds
		push	ax
		add	bl,cl
		dec	bl
		call	math_calc
		mov	di,ax
		mov	si,di
		sub	si,2000h
		jnc	loc_101			; Jump if carry=0
		add	si,data_58e
loc_101:
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

locloop_102:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		sub	di,2000h
		jnc	loc_103			; Jump if carry=0
		push	di
		push	si
		add	di,data_60e
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,data_58e
loc_103:
		sub	si,2000h
		jnc	loc_104			; Jump if carry=0
		add	si,data_39e
loc_104:
		pop	cx
		loop	locloop_102		; Loop if cx > 0

		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,3CC3h
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		push	ax
		call	math_calc
		mov	di,ax
		mov	si,di
		add	si,2000h
		cmp	si,6000h
		jb	loc_105			; Jump if below
		add	si,data_62e
loc_105:
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		xor	ch,ch			; Zero register

locloop_106:
		push	cx
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,2000h
		cmp	di,data_59e
		jb	loc_107			; Jump if below
		push	di
		push	si
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	di
		add	di,data_62e
loc_107:
		add	si,2000h
		cmp	si,6000h
		jb	loc_108			; Jump if below
		add	si,data_43e
loc_108:
		pop	cx
		loop	locloop_106		; Loop if cx > 0

		pop	ax
		mov	dl,28h			; '('
		mul	dl			; ax = reg * al
		add	ax,3CC3h
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
			                        ;* No entry point to code
		mov	ax,0B000h
		mov	es,ax
		mov	di,data_55e
		mov	cx,90h

locloop_109:
		push	cx
		push	di
		mov	ax,0FFFFh
		mov	cx,1Ch

locloop_110:
		xor	es:[di],ax
		inc	di
		inc	di
		loop	locloop_110		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,data_59e
		jb	loc_112			; Jump if below
		push	di
		mov	ax,0FFFFh
		mov	cx,1Ch

locloop_111:
		xor	es:[di],ax
		inc	di
		inc	di
		loop	locloop_111		; Loop if cx > 0

		pop	di
		add	di,0A05Ah
loc_112:
		pop	cx
		loop	locloop_109		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	cs:data_29e,di
		mov	word ptr cs:data_29e+2,es
		push	cx
		push	ds
		push	si
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,30h
		mul	cx			; dx:ax = reg * ax
		mov	cx,ax
		mov	di,data_54e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,data_54e

locloop_113:
		push	cx
		mov	cx,8

locloop_114:
		push	cx
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsw				; String [si] to ax
		mov	cx,ax
		lodsw				; String [si] to ax
		mov	bx,ax
		mov	bp,ax
		or	ax,cx
		or	ax,dx
		and	bp,cx
		and	bp,dx
		not	bp
		and	dx,bp
		and	cx,bp
		and	bx,bp
		mov	cs:data_25e,dx
		mov	cs:data_26e,cx
		mov	cs:data_27e,bx
		not	ax
		mov	cs:data_28e,ax
		call	decb_process_loop_5
		mov	ax,dx
		stosw				; Store ax to es:[di]
		push	es
		push	di
		les	di,dword ptr cs:data_29e	; Load seg:offset ptr
		call	decb_scan_loop_4
		mov	ax,dx
		stosw				; Store ax to es:[di]
		mov	cs:data_29e,di
		pop	di
		pop	es
		pop	cx
		loop	locloop_114		; Loop if cx > 0

		pop	cx
		loop	locloop_113		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	ds
		mov	ds,cs:data_50e
		mov	si,data_5e
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	cx,2EE0h
		mov	di,data_54e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	es,cs:data_50e
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,0
		mov	di,8100h
		mov	bx,es:data_3e
		mov	bp,0D000h
		mov	cx,0FAh

locloop_115:
		push	cx
		mov	al,es:[bx]
		cmp	al,5
		jb	loc_116			; Jump if below
		xor	al,al			; Zero register
loc_116:
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		add	bx,bx
		call	word ptr cs:data_17e[bx]	;*
		pop	bx
		inc	bx
		pop	cx
		loop	locloop_115		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		daa				; Decimal adjust
		cmp	cx,[si+3Bh]
;*		jns	loc_119			;*Jump if not sign
		db	 79h, 3Bh		;  Fixup - byte match
		cmpsb				; Cmp [si] to es:[di]
		cmp	dx,bx
		db	3Bh, 0B9h, 08h, 00h		; cmp di, word ptr [bx+di+8] (16-bit disp)

locloop_117:
		push	cx
		lodsw				; String [si] to ax
		mov	cs:data_25e,ax
		lodsw				; String [si] to ax
		mov	cs:data_26e,ax
		lodsw				; String [si] to ax
		mov	cs:data_27e,ax
		call	decb_process_loop_5
		mov	ax,dx
		stosw				; Store ax to es:[di]
		mov	word ptr es:[bp],0
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_117		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_118:
		push	cx
		lodsw				; String [si] to ax
		mov	cs:data_25e,ax
		lodsw				; String [si] to ax
		mov	cs:data_26e,ax
		mov	word ptr cs:data_27e,0
		lodsw				; String [si] to ax
		mov	cs:data_28e,ax
		call	decb_process_loop_5
		mov	ax,dx
		stosw				; Store ax to es:[di]
		call	decb_scan_loop_4
		mov	es:[bp],dx
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_118		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_120:
		push	cx
		lodsw				; String [si] to ax
		mov	cs:data_25e,ax
		lodsw				; String [si] to ax
		mov	cs:data_28e,ax
		mov	word ptr cs:data_26e,0
		lodsw				; String [si] to ax
		mov	cs:data_27e,ax
		call	decb_process_loop_5
		mov	ax,dx
		stosw				; Store ax to es:[di]
		call	decb_scan_loop_4
		mov	es:[bp],dx
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_120		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_121:
		push	cx
		lodsw				; String [si] to ax
		mov	cs:data_28e,ax
		mov	word ptr cs:data_25e,0
		lodsw				; String [si] to ax
		mov	cs:data_26e,ax
		lodsw				; String [si] to ax
		mov	cs:data_27e,ax
		call	decb_process_loop_5
		mov	ax,dx
		stosw				; Store ax to es:[di]
		call	decb_scan_loop_4
		mov	es:[bp],dx
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_121		; Loop if cx > 0

		retn
		db	0B9h, 08h, 00h

locloop_122:
		push	cx
		add	si,6
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		mov	word ptr es:[bp],0FFFFh
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_122		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

decb_process_loop_5		proc	near
		mov	cx,8

locloop_123:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_27e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_26e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_25e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_27e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_26e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_25e,1	; Rotate
		adc	bx,bx
		add	dx,dx
		add	dx,dx
		or	dl,cs:data_18e[bx]
		loop	locloop_123		; Loop if cx > 0

		retn
decb_process_loop_5		endp

		db	0, 1, 0, 1, 1, 0
		db	3, 2, 1, 3, 2, 3
		db	1, 3, 3, 2, 2, 2
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

decb_scan_loop_4		proc	near
		mov	cx,8

locloop_124:
		xor	al,al			; Zero register
		rol	word ptr cs:data_28e,1	; Rotate
		adc	al,al
		rol	word ptr cs:data_28e,1	; Rotate
		adc	al,al
		cmp	al,3
		je	loc_125			; Jump if equal
		xor	al,al			; Zero register
loc_125:
		add	dx,dx
		add	dx,dx
		or	dl,al
		loop	locloop_124		; Loop if cx > 0

		retn
decb_scan_loop_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

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

		db	1127 dup (0)

seg_a		ends



		end	start
