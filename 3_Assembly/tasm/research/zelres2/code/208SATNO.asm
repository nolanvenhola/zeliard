
PAGE  59,132

;==========================================================================
;
;  ENEMY_BAT - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_7e		equ	2C6Ch			;*
data_8e		equ	2C88h			;*
data_9e		equ	335Bh			;*
data_10e	equ	338Ah			;*
data_11e	equ	3432h			;*
data_12e	equ	357Dh			;*
data_13e	equ	35BBh			;*
data_14e	equ	36B6h			;*
data_15e	equ	3C30h			;*
data_16e	equ	56F1h			;*
data_17e	equ	6000h			;*
data_18e	equ	0C050h			;*
data_19e	equ	0FD57h			;*
data_20e	equ	0			;*
data_21e	equ	1340h			;*
data_22e	equ	0B1B0h
data_23e	equ	0B220h
data_24e	equ	0BBB0h
data_25e	equ	23Ch
data_26e	equ	163Ch

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_08		proc	far

start:
		db	 65h, 25h, 00h, 00h, 2Eh,0A2h
		db	 5Bh, 33h, 8Ch,0CAh, 8Eh,0DAh
		db	 81h,0C2h, 00h, 10h, 8Eh,0C2h
		db	0FCh,0BFh, 00h, 00h,0B9h, 80h
		db	 26h, 33h,0C0h,0F3h,0ABh, 8Ch
		db	0CAh, 81h,0C2h, 00h, 10h, 8Eh
		db	0C2h,0BEh,0E7h, 38h,0BFh, 00h
		db	 00h,0E8h, 32h, 00h,0BEh, 59h
		db	 47h,0BFh, 40h, 13h,0E8h, 29h
		db	 00h,0E8h, 48h, 00h, 8Ch,0CAh
		db	 81h,0C2h, 00h, 10h, 8Eh,0C2h
		db	0BFh, 00h, 00h,0BEh, 9Eh, 55h
		db	0B9h, 10h, 00h

locloop_6:
		call	bat_func_3
		loop	locloop_6		; Loop if cx > 0

		mov	si,data_16e
		mov	cx,10h

locloop_7:
		call	bat_func_3
		loop	locloop_7		; Loop if cx > 0

		call	bat_func_4
		retf				; Return far
		db	 00h, 33h,0C9h
loc_8:
		lodsb				; String [si] to al
		cmp	al,6
		mov	ah,1
		jnz	loc_9			; Jump if not zero
		lodsw				; String [si] to ax
loc_9:
		stosb				; Store al to es:[di]
		inc	ch
		cmp	ch,38h			; '8'
		jne	loc_10			; Jump if not equal
		xor	ch,ch			; Zero register
		inc	cl
		cmp	cl,58h			; 'X'
		jne	loc_10			; Jump if not equal
		retn
loc_10:
		dec	ah
		jnz	loc_9			; Jump if not zero
		jmp	short loc_8
			                        ;* No entry point to code
		xor	bx,bx			; Zero register
		mov	bl,ds:data_9e
		add	bx,bx
		jmp	word ptr ds:data_10e[bx]	;*
			                        ;* No entry point to code
		xchg	si,ax
		xor	dx,cx
		xor	dx,cx
		xor	ax,[bp+si+34h]
		mov	ax,1034h
		xor	ax,8C1Eh
		retf	0C281h			; Return far
		db	 00h, 10h, 8Eh,0DAh,0BEh, 00h
		db	 00h,0B8h, 00h,0A0h, 8Eh,0C0h
		db	0BAh,0C4h, 03h,0B0h, 02h,0EEh
		db	 42h,0B0h, 01h,0EEh,0E8h, 08h
		db	 00h,0B0h, 04h,0EEh,0E8h, 02h
		db	 00h, 1Fh,0C3h,0BFh, 6Ch, 04h
		db	0B9h, 58h, 00h

locloop_11:
		push	cx
		push	di
		mov	cx,38h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		add	di,50h
		pop	cx
		loop	locloop_11		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,data_20e
		mov	ax,0B800h
		mov	es,ax
		mov	di,data_25e
		mov	cx,58h

locloop_12:
		push	cx
		push	di
		mov	cx,38h

locloop_13:
		push	cx
		mov	ah,ds:data_21e[si]
		lodsb				; String [si] to al
		xor	dl,dl			; Zero register
		mov	cx,4

locloop_14:
		add	ah,ah
		adc	bl,bl
		add	al,al
		adc	bl,bl
		add	ah,ah
		adc	bl,bl
		add	al,al
		adc	bl,bl
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	dl,dl
		add	dl,dl
		or	dl,cs:data_11e[bx]
		loop	locloop_14		; Loop if cx > 0

		mov	al,dl
		stosb				; Store al to es:[di]
		pop	cx
		loop	locloop_13		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_15			; Jump if below
		add	di,data_18e
loc_15:
		pop	cx
		loop	locloop_12		; Loop if cx > 0

		pop	ds
		retn
		db	 00h, 03h, 01h, 02h, 00h, 03h
		db	 01h, 02h, 00h, 03h, 01h, 02h
		db	 00h, 03h, 01h, 02h, 1Eh, 8Ch
		db	0CAh, 81h,0C2h, 00h, 10h, 8Eh
		db	0DAh,0BEh, 00h, 00h,0B8h, 00h
		db	0B0h, 8Eh,0C0h,0BFh,0FDh, 04h
		db	0B9h, 58h, 00h

locloop_16:
		push	cx
		push	di
		mov	cx,38h

locloop_17:
		push	cx
		mov	ah,data_3[si]
		lodsb				; String [si] to al
		xor	dl,dl			; Zero register
		mov	cx,4

locloop_18:
		add	ah,ah
		adc	bl,bl
		add	al,al
		adc	bl,bl
		add	ah,ah
		adc	bl,bl
		add	al,al
		adc	bl,bl
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	dl,dl
		add	dl,dl
		or	dl,cs:data_11e[bx]
		loop	locloop_18		; Loop if cx > 0

		mov	al,dl
		stosb				; Store al to es:[di]
		pop	cx
		loop	locloop_17		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,data_17e
		jb	loc_19			; Jump if below
		push	ds
		push	si
		push	cx
		push	di
		push	es
		pop	ds
		mov	si,di
		sub	si,2000h
		mov	cx,38h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	cx
		pop	si
		pop	ds
		add	di,0A05Ah
loc_19:
		pop	cx
		loop	locloop_16		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,data_20e
		mov	ax,0A000h
		mov	es,ax
		mov	di,11B0h
		mov	cx,58h

locloop_20:
		push	cx
		push	di
		mov	cx,38h

locloop_21:
		push	cx
		mov	dh,ds:data_21e[si]
		mov	dl,[si]
		inc	si
		call	bat_func_1
		stosb				; Store al to es:[di]
		call	bat_func_1
		stosb				; Store al to es:[di]
		call	bat_func_1
		stosb				; Store al to es:[di]
		call	bat_func_1
		stosb				; Store al to es:[di]
		pop	cx
		loop	locloop_21		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_20		; Loop if cx > 0

		pop	ds
		retn

zr2_08		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

bat_func_1		proc	near
		xor	al,al			; Zero register
		add	dh,dh
		adc	al,al
		add	al,al
		add	dl,dl
		adc	al,al
		add	dh,dh
		adc	al,al
		add	al,al
		add	dl,dl
		adc	al,al
		retn
bat_func_1		endp

			                        ;* No entry point to code
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,data_20e
		mov	ax,0B800h
		mov	es,ax
		mov	di,41F8h
		mov	cx,58h

locloop_22:
		push	cx
		push	di
		mov	cx,38h

locloop_23:
		push	cx
		mov	dh,ds:data_21e[si]
		mov	dl,[si]
		inc	si
		call	bat_process_loop
		stosb				; Store al to es:[di]
		call	bat_process_loop
		stosb				; Store al to es:[di]
		pop	cx
		loop	locloop_23		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_24			; Jump if below
		add	di,80A0h
loc_24:
		pop	cx
		loop	locloop_22		; Loop if cx > 0

		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

bat_process_loop		proc	near
		xor	al,al			; Zero register
		mov	cx,2

locloop_25:
		add	dh,dh
		adc	bl,bl
		add	dl,dl
		adc	bl,bl
		add	dh,dh
		adc	bl,bl
		add	dl,dl
		adc	bl,bl
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	al,al
		add	al,al
		add	al,al
		add	al,al
		or	al,cs:data_12e[bx]
		loop	locloop_25		; Loop if cx > 0

		retn
bat_process_loop		endp

		db	 00h, 07h, 09h, 01h, 07h, 0Fh
		db	 0Bh, 07h, 09h, 0Bh, 0Bh, 03h
		db	 01h, 07h, 03h
		db	9

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

bat_func_3		proc	near
		xor	bl,bl			; Zero register
loc_26:
		lodsb				; String [si] to al
		mov	ah,al
		and	ah,0F0h
		cmp	ah,60h			; '`'
		mov	ah,1
		jnz	loc_27			; Jump if not zero
		and	al,0Fh
		mov	ah,al
		xor	al,al			; Zero register
loc_27:
		stosb				; Store al to es:[di]
		inc	bl
		dec	ah
		jnz	loc_27			; Jump if not zero
		cmp	bl,1Ch
		jne	loc_26			; Jump if not equal
		retn
bat_func_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

bat_func_4		proc	near
		xor	bx,bx			; Zero register
		mov	bl,ds:data_9e
		add	bx,bx
		jmp	word ptr ds:data_13e[bx]	;*
bat_func_4		endp

		db	0C7h, 35h, 43h, 36h, 43h, 36h
		db	0C6h, 36h, 4Eh, 37h, 00h, 38h
		db	 1Eh, 8Ch,0CAh, 81h,0C2h, 00h
		db	 10h, 8Eh,0DAh,0BEh, 00h, 00h
		db	0B8h, 00h,0A0h, 8Eh,0C0h,0BFh
		db	 6Ch, 2Ch,0BAh,0C4h, 03h,0B0h
		db	 02h,0EEh, 42h,0B9h, 08h, 00h

locloop_28:
		mov	al,4
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		call	copy_buffer
		mov	al,2
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		call	copy_buffer
		add	di,50h
		loop	locloop_28		; Loop if cx > 0

		mov	di,2EECh
		mov	cx,8

locloop_29:
		mov	al,1
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		call	copy_buffer
		mov	al,2
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		call	copy_buffer
		add	di,50h
		loop	locloop_29		; Loop if cx > 0

		mov	al,7
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		push	es
		pop	ds
		mov	si,data_7e
		mov	di,data_8e
		mov	ah,10h
loc_30:
		mov	cx,1Ch
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		add	di,34h
		add	si,34h
		dec	ah
		jnz	loc_30			; Jump if not zero
		mov	dx,3CEh
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_buffer		proc	near
		push	di
		push	cx
		mov	cx,1Ch
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	di
		retn
copy_buffer		endp

			                        ;* No entry point to code
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,data_20e
		mov	ax,0B800h
		mov	es,ax
		mov	di,data_26e
		mov	cx,10h

locloop_31:
		push	cx
		push	di
		mov	cx,1Ch

locloop_32:
		push	cx
		mov	ah,[si+1Ch]
		lodsb				; String [si] to al
		xor	dl,dl			; Zero register
		mov	cx,4

locloop_33:
		add	ah,ah
		adc	bl,bl
		add	al,al
		adc	bl,bl
		add	ah,ah
		adc	bl,bl
		add	al,al
		adc	bl,bl
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	dl,dl
		add	dl,dl
		or	dl,cs:data_14e[bx]
		loop	locloop_33		; Loop if cx > 0

		mov	al,dl
		stosb				; Store al to es:[di]
		pop	cx
		loop	locloop_32		; Loop if cx > 0

		push	ds
		push	si
		push	es
		pop	ds
		mov	si,di
		sub	si,1Ch
		mov	cx,0Eh
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	ds
		add	si,1Ch
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_34			; Jump if below
		add	di,data_18e
loc_34:
		pop	cx
		loop	locloop_31		; Loop if cx > 0

		pop	ds
		retn
		db	 00h, 03h, 02h, 01h, 01h, 03h
		db	 03h, 03h, 02h, 03h, 01h, 02h
		db	 02h, 03h, 03h, 03h, 1Eh, 8Ch
		db	0CAh, 81h,0C2h, 00h, 10h, 8Eh
		db	0DAh,0BEh, 00h, 00h,0B8h, 00h
		db	0B0h, 8Eh,0C0h,0BFh,0C1h, 53h
		db	0B9h, 10h, 00h

locloop_35:
		push	cx
		push	di
		mov	cx,1Ch

locloop_36:
		push	cx
		mov	ah,[si+1Ch]
		lodsb				; String [si] to al
		xor	dl,dl			; Zero register
		mov	cx,4

locloop_37:
		add	ah,ah
		adc	bl,bl
		add	al,al
		adc	bl,bl
		add	ah,ah
		adc	bl,bl
		add	al,al
		adc	bl,bl
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	dl,dl
		add	dl,dl
		or	dl,cs:data_14e[bx]
		loop	locloop_37		; Loop if cx > 0

		mov	al,dl
		stosb				; Store al to es:[di]
		pop	cx
		loop	locloop_36		; Loop if cx > 0

		push	ds
		push	si
		push	es
		pop	ds
		mov	si,di
		sub	si,1Ch
		mov	cx,0Eh
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	ds
		add	si,1Ch
		pop	di
		add	di,2000h
		cmp	di,data_17e
		jb	loc_38			; Jump if below
		push	ds
		push	si
		push	cx
		push	di
		push	es
		pop	ds
		mov	si,di
		sub	si,2000h
		mov	cx,38h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	cx
		pop	si
		pop	ds
		add	di,0A05Ah
loc_38:
		pop	cx
		loop	locloop_35		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,data_20e
		mov	ax,0A000h
		mov	es,ax
		mov	di,data_22e
		mov	cx,8

locloop_39:
		push	cx
		push	si
		push	di
		mov	cx,0Eh

locloop_40:
		push	cx
		mov	dx,[si]
		mov	bx,[si+1Ch]
		xchg	dl,dh
		xchg	bl,bh
		mov	cx,8

locloop_41:
		xor	al,al			; Zero register
		add	dx,dx
		adc	al,al
		add	bx,bx
		adc	al,al
		add	al,al
		add	dx,dx
		adc	al,al
		add	bx,bx
		adc	al,al
		add	al,al
		stosb				; Store al to es:[di]
		loop	locloop_41		; Loop if cx > 0

		inc	si
		inc	si
		pop	cx
		loop	locloop_40		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	si
		add	si,38h
		pop	cx
		loop	locloop_39		; Loop if cx > 0

		mov	di,data_24e
		mov	cx,8

locloop_42:
		push	cx
		push	si
		push	di
		mov	cx,0Eh

locloop_43:
		push	cx
		mov	bx,[si]
		mov	dx,[si+1Ch]
		xchg	dl,dh
		xchg	bl,bh
		mov	cx,8

locloop_44:
		xor	al,al			; Zero register
		add	dx,dx
		adc	al,al
		add	bx,bx
		adc	al,al
		add	al,al
		add	dx,dx
		adc	al,al
		add	bx,bx
		adc	al,al
		stosb				; Store al to es:[di]
		loop	locloop_44		; Loop if cx > 0

		inc	si
		inc	si
		pop	cx
		loop	locloop_43		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	si
		add	si,38h
		pop	cx
		loop	locloop_42		; Loop if cx > 0

		push	es
		pop	ds
		mov	si,data_22e
		mov	di,data_23e
		mov	ah,10h
loc_45:
		mov	cx,38h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	di,0D0h
		add	si,0D0h
		dec	ah
		jnz	loc_45			; Jump if not zero
		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,data_20e
		mov	ax,0B800h
		mov	es,ax
		mov	di,55F8h
		mov	cx,8

locloop_46:
		push	cx
		push	di
		mov	cx,1Ch

locloop_47:
		push	cx
		mov	dh,[si+1Ch]
		mov	dl,[si]
		inc	si
		mov	bp,38C7h
		call	bat_process_loop_2
		stosb				; Store al to es:[di]
		call	bat_process_loop_2
		stosb				; Store al to es:[di]
		pop	cx
		loop	locloop_47		; Loop if cx > 0

		push	ds
		push	si
		push	es
		pop	ds
		mov	si,di
		sub	si,38h
		mov	cx,1Ch
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	ds
		add	si,1Ch
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_48			; Jump if below
		add	di,80A0h
loc_48:
		pop	cx
		loop	locloop_46		; Loop if cx > 0

		mov	di,5738h
		mov	cx,8

locloop_49:
		push	cx
		push	di
		mov	cx,1Ch

locloop_50:
		push	cx
		mov	dh,[si+1Ch]
		mov	dl,[si]
		inc	si
		mov	bp,38D7h
		call	bat_process_loop_2
		stosb				; Store al to es:[di]
		call	bat_process_loop_2
		stosb				; Store al to es:[di]
		pop	cx
		loop	locloop_50		; Loop if cx > 0

		push	ds
		push	si
		push	es
		pop	ds
		mov	si,di
		sub	si,38h
		mov	cx,1Ch
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	ds
		add	si,1Ch
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_51			; Jump if below
		add	di,80A0h
loc_51:
		pop	cx
		loop	locloop_49		; Loop if cx > 0

		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

bat_process_loop_2		proc	near
		xor	al,al			; Zero register
		mov	cx,2

locloop_52:
		add	dh,dh
		adc	bl,bl
		add	dl,dl
		adc	bl,bl
		add	dh,dh
		adc	bl,bl
		add	dl,dl
		adc	bl,bl
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	al,al
		add	al,al
		add	al,al
		add	al,al
		add	bx,bp
		or	al,cs:[bx]
		loop	locloop_52		; Loop if cx > 0

		retn
bat_process_loop_2		endp

		db	 00h, 03h, 04h, 07h, 03h, 0Bh
		db	 05h, 0Ah, 04h, 05h, 0Ch, 06h
		db	 07h, 0Ah, 06h, 0Eh, 00h, 07h
		db	 04h, 02h, 07h, 0Fh, 0Ch, 0Eh
		db	 04h, 0Ch, 0Ch, 02h, 02h, 0Eh
		db	 02h, 0Ah, 06h,0AAh, 70h,0BBh
		db	0FBh,0BFh,0BBh,0BFh,0BBh,0BBh
		db	0FFh,0BBh,0BBh,0BFh, 06h,0BBh
		db	 08h,0FBh,0FFh,0FFh,0BBh,0BFh
		db	0FBh, 06h,0BBh, 10h,0FFh,0FFh
		db	0FBh, 06h,0BBh, 0Ch,0FEh,0FEh
		db	0FEh,0FFh,0FEh,0EFh,0FFh,0FFh
		db	0FFh,0EFh,0FFh,0FFh,0EEh,0EEh
		db	0EFh,0FEh,0EFh,0FFh,0FFh,0FEh
		db	0FFh,0EEh,0EFh,0FFh,0FFh,0FFh
		db	0EEh,0EFh,0EEh,0EFh,0FEh,0FFh
		db	0EFh,0FEh,0EFh,0EFh,0FFh,0FEh
		db	0FFh,0EFh,0FFh,0FFh,0FEh,0FFh
		db	0EEh, 06h,0EFh, 04h,0FEh,0FFh
		db	0FFh,0FEh,0EEh,0EEh,0EEh, 06h
		db	0FFh, 32h,0EFh,0FBh, 06h,0FFh
		db	 77h,0BBh,0BBh,0BBh, 06h,0FFh
		db	 0Dh,0FEh,0EAh,0BBh,0FFh,0FFh
		db	0FEh,0EAh,0EFh,0FFh,0FFh,0EEh
		db	0EEh,0EEh, 06h,0FFh, 10h,0FEh
		db	0EEh,0EEh, 06h,0FFh, 05h,0BBh
		db	0FBh,0AEh, 06h,0EEh, 04h,0EFh
		db	0FFh,0FFh,0FBh,0BAh,0BEh,0BEh
		db	0EFh,0FBh,0FBh,0BBh, 06h,0FFh
		db	 0Eh, 06h,0BBh, 0Bh,0BFh,0FFh
		db	0FFh,0BBh,0BBh,0BBh,0FBh,0BBh
		db	0BBh,0BFh,0BFh,0FFh,0BBh,0EEh
		db	0EEh,0EAh,0AAh,0AAh,0AAh,0EEh
		db	0FEh,0EEh,0EEh,0EFh,0FFh,0EAh
		db	0EAh,0ABh,0AAh,0BFh,0EEh,0EEh
		db	0AAh, 06h,0BBh, 04h,0BFh,0FFh
		db	0FEh, 06h,0EEh, 07h,0FEh,0AAh
		db	0AEh,0EEh,0AAh,0AAh,0AEh,0EEh
		db	0FFh,0FFh,0FFh, 06h,0EEh, 04h
		db	0EFh,0EEh,0FFh,0FFh,0FFh,0EEh
		db	0FFh,0BBh,0BBh,0BBh,0BAh,0ABh
		db	0ABh, 06h,0BBh, 05h,0BAh,0ABh
		db	0AAh,0AAh,0ABh,0ABh,0BBh, 06h
		db	0AAh, 06h,0ABh, 06h,0BBh, 07h
		db	0AAh,0ABh, 06h,0BBh, 13h,0BFh
		db	0FFh,0BFh, 06h,0EEh, 08h, 06h
		db	0AAh, 0Dh,0EEh,0AEh,0AAh,0EEh
		db	0EEh,0EAh,0AAh,0EEh,0AAh
data_2		db	0AAh			; Data table (indexed access)
		db	0EAh,0EEh,0EAh,0AAh,0EEh,0EEh
		db	0FEh,0AAh,0EAh,0AAh,0AEh,0EEh
		db	0EAh,0AAh,0EEh,0AAh,0EAh,0AEh
		db	 06h,0EEh, 06h,0EFh,0FBh, 06h
		db	0AAh, 2Dh,0BBh,0AAh,0BAh,0AAh
		db	0ABh, 06h,0BBh, 05h,0EAh,0EEh
		db	 06h,0AAh, 35h,0EEh,0ABh,0AAh
		db	0AAh,0AAh,0EAh,0EEh,0EAh,0AEh
		db	0ABh, 06h,0AAh, 2Fh,0EAh, 06h
		db	0AAh, 08h,0ABh,0AAh,0BAh,0EAh
		db	 06h,0AAh,0B6h,0AFh,0FEh,0EFh
		db	 06h,0AAh, 04h,0BFh,0EEh,0EFh
		db	0FAh, 06h,0AAh, 2Dh,0BEh,0AFh
		db	0FEh,0EEh,0BBh,0FAh,0AAh,0BAh
		db	0FBh,0BAh, 06h,0AAh, 1Fh, 3Fh
		db	0FEh,0EEh,0EAh,0BBh, 06h,0AAh
		db	 09h,0ABh,0FEh,0AEh,0EAh, 06h
		db	0AAh, 04h,0FAh,0BEh, 06h,0AAh
		db	 20h, 3Eh,0EAh, 06h,0AAh, 0Ch
		db	0AFh,0FEh,0ABh,0BBh,0BAh,0AAh
		db	0AAh,0AAh,0FAh,0BAh, 06h,0AAh
		db	 1Fh,0ABh,0BAh, 06h,0AAh, 0Dh
		db	0AFh,0FAh,0AAh,0EAh,0AAh,0AAh
		db	0AAh,0ABh,0FBh,0EEh, 06h,0AAh
		db	 10h,0BFh,0FFh,0FFh,0EFh, 06h
		db	0AAh, 0Bh,0AFh,0AEh,0EEh,0EFh
		db	0FEh,0BAh,0AAh,0EEh,0EEh,0FFh
		db	0FBh,0BBh,0AAh,0AAh,0AAh,0FFh
		db	0EAh,0AAh,0EAh,0AAh,0AAh,0AAh
		db	0ABh,0EEh,0BAh,0AAh,0AAh,0ABh
		db	0FFh,0FBh,0FFh,0BBh,0BBh,0AAh
		db	0EEh, 06h,0AAh, 05h,0BFh,0EEh
		db	0ABh,0FFh,0BAh, 06h,0AAh, 07h
		db	0FFh,0FEh,0EEh,0AAh,0AFh,0AFh
		db	0BBh,0BBh,0AAh,0AAh,0AEh,0EEh
		db	 06h,0AAh, 04h,0AEh,0EEh,0EFh
		db	0BFh,0EAh, 06h,0AAh, 05h,0AFh
		db	0ECh,0BAh,0AAh,0AAh,0AFh,0FFh
		db	0FFh,0BBh,0FFh,0EAh, 06h,0AAh
		db	 06h,0BFh,0FFh,0EEh,0AAh,0ABh
		db	0AAh,0BFh,0BFh,0EBh,0FBh,0BBh
		db	0BBh,0BBh, 06h,0AAh, 04h,0AFh
		db	 2Bh,0FAh,0AAh,0AAh,0AAh, 06h
		db	0BBh, 04h,0AAh,0AEh,0EAh,0AAh
		db	0FAh,0BFh,0EAh,0AAh,0BBh,0BFh
		db	0FBh,0BBh,0BFh,0E8h,0BAh,0AAh
		db	0AAh,0AFh,0FEh,0ABh,0EFh,0FEh
		db	0FFh,0FEh,0EAh,0AAh,0AFh, 06h
		db	0FFh, 04h,0EEh,0AAh,0AAh,0AAh
		db	0FFh,0AEh,0EEh,0FFh,0EAh,0AEh
		db	0EEh,0FBh,0BAh,0FFh,0FFh,0EEh
		db	0EAh,0BEh,0EEh,0EEh,0EEh,0BFh
		db	0FFh,0EBh,0FFh,0FEh,0BAh,0EAh
		db	0ABh,0EBh,0FFh, 06h,0AAh, 06h
		db	0FEh,0ECh, 8Eh,0AAh,0AAh,0BFh
		db	0FEh,0AFh,0BAh, 06h,0FFh, 05h
		db	0FAh,0BFh,0BEh,0FFh,0FFh,0EEh
		db	0AAh,0AAh,0AAh, 06h,0FFh, 05h
		db	0ABh, 06h,0FFh, 04h,0FEh,0BFh
		db	0AAh,0AFh, 06h,0FFh, 08h,0FBh
		db	0FFh,0EFh,0AFh,0FFh,0AAh,0A8h
		db	0BFh,0FFh,0FBh,0FFh,0BEh,0EEh
		db	 2Eh,0FFh,0FFh,0BFh,0FEh,0AFh
		db	0BBh,0FEh,0AAh,0EEh,0BEh,0FBh
		db	0AAh,0BFh,0EBh,0BFh,0FFh,0EEh
		db	 06h,0AAh, 07h,0AFh,0ABh,0EAh
		db	0AAh,0AAh,0AAh,0A8h,0BFh,0AAh
		db	0AEh,0EEh,0EBh,0AAh,0AEh,0EEh
		db	0ABh,0BBh,0AFh,0AFh,0EAh,0BFh
		db	0AFh,0FEh,0AAh,0A8h,0AAh,0AAh
		db	0AFh,0EEh,0EAh,0EEh, 22h,0AAh
		db	0AAh,0FFh,0FEh,0EBh,0BAh,0BEh
		db	0AAh,0EEh,0FEh,0FBh,0BAh,0AFh
		db	0AAh,0BFh,0FFh,0EEh,0AAh,0AAh
		db	0AAh,0FFh,0FFh,0FFh,0EBh,0FAh
		db	0AAh,0FFh,0FFh,0FFh,0FEh,0A2h
		db	0FDh,0E8h,0AFh,0FEh,0ABh, 06h
		db	0FFh, 06h,0EFh,0BFh,0BEh,0EFh
		db	0FAh,0AAh,0A8h, 2Bh,0FFh,0EFh
		db	0FFh,0EBh,0BEh, 8Ah,0BFh,0FEh
		db	0FFh,0FEh,0EBh,0BEh,0BAh,0AAh
		db	0FAh,0BEh,0FBh,0BAh,0BEh,0EAh
		db	0BFh,0FFh,0AEh,0AAh,0AAh,0AAh
		db	0AEh,0BAh,0AAh,0FAh,0AAh,0BBh
		db	0FEh,0AAh,0BFh,0FAh, 82h,0FBh
		db	0E8h,0ABh,0FEh,0ABh,0FFh,0EBh
		db	 06h,0FFh, 04h,0EFh,0BFh,0BFh
		db	0AFh,0FAh,0AAh,0AAh, 0Bh,0FFh
		db	0EEh,0FFh,0ABh,0BAh,0A8h,0BFh
		db	0FBh,0FFh,0FBh,0ABh,0FEh,0BAh
		db	0AAh,0FAh,0FEh,0FBh,0BAh,0BBh
		db	0AAh,0BFh,0FFh,0BAh,0AAh,0AAh
		db	0AAh,0BEh,0BFh,0EFh,0AAh,0AAh
		db	0AFh,0FFh,0AAh,0FFh,0FAh, 22h
		db	0FFh,0E8h,0AAh,0FAh,0ABh,0FFh
		db	0ABh, 06h,0FFh, 04h,0BEh,0FFh
		db	0BEh,0AFh,0EAh,0AAh,0AAh, 8Ah
		db	0FFh,0BFh,0FAh,0AEh,0AEh, 88h
		db	0ABh,0FBh,0FFh,0EBh,0AAh,0FAh
		db	0BAh,0AAh,0FAh,0EEh,0FBh,0AAh
		db	0BEh,0AAh,0BFh,0FFh,0BAh, 06h
		db	0AAh, 04h,0BEh,0AAh,0AAh,0AAh
		db	0AEh,0FFh,0EAh,0FEh,0FAh,0CBh
		db	0FFh,0A8h, 8Ah,0AAh,0AEh,0EEh
		db	0ABh,0FFh,0FFh,0FFh,0FEh,0FFh
		db	0AEh,0FFh,0BFh,0EAh,0AAh,0AAh
		db	 0Ah,0FEh,0FBh,0BAh,0EEh,0FEh
		db	 80h,0AAh,0FFh,0FFh,0EBh,0AAh
		db	0EAh,0AEh,0AAh,0EBh,0BEh,0EEh
		db	0BAh,0BEh,0AAh,0BFh,0FFh,0FAh
		db	 06h,0AAh, 04h,0FEh,0AAh,0AEh
		db	0AAh,0AFh,0BFh,0ABh,0FFh,0E8h
		db	0C3h,0FFh, 98h, 0Ah,0AAh,0ABh
		db	0FAh,0BBh,0FFh,0FFh,0FFh,0FEh
		db	0FFh,0ABh,0FAh,0BEh,0EAh,0AAh
		db	0AAh, 82h,0BEh,0EFh,0EBh,0BBh
		db	0EEh, 82h, 2Ah,0FFh,0FFh,0AFh
		db	0AAh,0EAh,0AAh,0ABh,0BBh,0FEh
		db	0EEh,0BAh,0BAh,0AAh,0BFh,0FFh
		db	0AEh, 06h,0AAh, 04h,0BEh,0AAh
		db	0BAh,0AAh,0ABh,0FEh,0BBh,0AFh
		db	0FBh,0CFh,0FEh, 98h, 08h, 88h
		db	0AAh,0FAh,0AFh,0FEh,0FFh,0FFh
		db	0FEh,0FEh,0ABh,0EEh,0FEh,0EAh
		db	0AAh,0AAh, 88h,0ABh,0FFh,0EAh
		db	0AFh,0BAh, 82h, 23h,0FFh,0FFh
		db	0AEh,0AAh,0BBh,0AEh,0ABh,0EBh
		db	0FFh,0AEh,0BAh,0AEh,0AAh,0BFh
		db	0FFh,0EEh,0AAh,0AAh,0AAh, 2Ah
		db	0FAh,0AAh,0EAh,0AAh,0ABh,0FAh
		db	0FBh,0FFh,0EFh,0CFh,0F9h,0A8h
		db	 20h,0A2h, 2Ah,0EAh,0BFh,0FFh
		db	0FFh,0FFh,0EBh,0FFh,0AFh,0BAh
		db	0FBh,0AAh,0AAh,0AAh,0A2h,0ABh
		db	0BEh,0EFh,0BFh,0BEh, 88h, 83h
		db	0FFh,0FFh,0BAh,0AAh,0FBh,0BAh
		db	0AEh,0EEh,0FFh,0AEh,0EAh,0BAh
		db	0AAh,0BFh,0FFh
		db	0EEh,0AAh,0AAh,0AAh, 2Bh,0FAh
		db	0ABh,0AAh,0AAh,0BBh,0FEh,0EFh
		db	0BBh,0EFh,0BFh,0F9h,0AAh, 08h
		db	 28h,0AAh,0ABh,0BFh,0FFh,0FFh
		db	0FFh,0FEh,0FAh,0EFh,0EBh,0FBh
		db	0AAh,0AAh,0AAh, 82h,0AAh,0FFh
		db	0AEh,0BEh,0BAh, 80h, 8Fh,0FFh
		db	0FFh,0BAh,0AAh,0EBh,0AAh,0FBh
		db	0ABh,0BFh,0AEh,0EAh,0BAh,0AAh
		db	0BFh,0FFh
		db	0AEh,0AAh,0AAh,0AAh,0EBh,0FAh
		db	0AFh,0AAh,0AAh
		db	0BEh,0EAh,0FBh,0BAh,0FFh, 3Fh
		db	0FAh,0AAh, 0Ah, 88h, 00h,0BFh
		db	 06h,0FFh, 04h,0FBh,0EFh,0ABh
		db	0ABh,0EBh,0AAh,0AAh,0AAh,0A0h
		db	0AAh,0FBh,0BEh,0EAh,0FAh,0A0h
		db	 0Fh,0FFh,0FEh,0BAh,0AAh,0EFh
		db	0BBh,0AEh,0AEh,0EEh,0EEh,0EAh
		db	0AEh,0AAh,0EFh,0FFh,0AEh,0AAh
		db	0AAh,0AAh, 0Bh,0EAh,0BBh,0AAh
		db	0AAh,0BFh,0FBh,0AEh,0FFh,0BCh
		db	0FFh,0FAh,0AAh, 82h,0A0h, 0Fh
		db	 06h,0FFh, 05h,0EFh,0ABh,0AEh
		db	0AFh,0EBh,0AAh,0AAh,0AAh,0A8h
		db	 2Ah,0BEh,0BBh,0BAh,0FAh,0A2h
		db	 3Fh,0FFh,0EFh,0BAh,0AAh,0EFh
		db	0AEh,0BAh,0ABh,0EFh,0AEh,0EAh
		db	0AEh,0AAh,0BFh,0FFh, 06h,0AAh
		db	 04h,0CFh,0BAh,0AEh,0AAh,0AAh
		db	0EFh,0ABh,0BAh,0BEh,0BFh,0FFh
		db	0FAh, 6Ah, 82h, 80h
		db	 06h,0FFh, 06h,0AFh,0BAh
		db	0BEh,0BFh,0AEh,0AAh,0AAh,0AAh
		db	0A2h, 0Ah,0AEh,0AFh,0AAh,0EEh
		db	0A0h, 3Fh,0FBh,0EBh,0EAh,0AAh
		db	0BBh,0AEh,0BAh,0AFh,0EFh,0EEh
		db	0EAh,0AEh,0AAh,0AFh,0FFh,0AEh
		db	0AAh,0AAh,0AAh, 8Fh,0EAh,0BAh
		db	0AAh,0ABh,0BFh,0AAh,0BAh,0FEh
		db	0BFh,0FFh,0EAh,0AAh,0A8h, 83h
		db	 06h,0FFh, 05h,0FEh,0AFh,0BAh
		db	0FAh,0FEh,0AEh,0AAh,0AAh,0AAh
		db	0A8h, 0Ah,0AAh,0BFh,0ABh,0EEh
		db	0A2h, 3Fh,0EFh,0AFh,0EAh,0AAh
		db	0AFh,0FAh,0EAh,0BFh,0FFh,0EEh
		db	0EAh,0AEh,0AAh,0AFh,0FEh,0AEh
		db	0AAh,0AAh,0AAh,0CEh,0EBh,0EAh
		db	0AAh,0ABh,0FAh,0AAh,0EAh,0EEh
		db	0B3h,0FFh,0A9h,0AAh, 22h, 87h
		db	 06h,0FFh, 05h,0FEh,0FFh,0BAh
		db	0BBh,0FEh,0AEh,0AAh,0AAh,0AAh
		db	0A8h, 82h,0AAh,0FFh,0AFh,0EEh
		db	 88h, 3Fh,0EEh,0BEh,0FAh,0AAh
		db	0BFh,0AFh,0AAh,0BFh,0BFh,0AAh
		db	0EAh,0AAh,0AAh,0AFh,0FEh,0AEh
		db	0AAh,0AAh,0AAh, 83h,0AEh,0EAh
		db	0AAh,0AFh,0AAh,0EFh,0AAh,0AEh
		db	0F3h,0FFh,0A9h,0AAh, 0Ah, 05h
		db	 7Fh,0FFh, 5Fh,0FFh,0FFh,0FBh
		db	0EEh,0FAh,0EBh,0FEh,0BAh, 06h
		db	0AAh, 04h, 00h,0AAh,0FEh,0BFh
		db	0BEh,0A0h,0FFh,0AEh,0EFh,0BAh
		db	0AAh,0FFh,0BAh,0AAh,0BFh,0BEh
		db	0BAh,0BAh,0AEh,0AAh,0AFh,0FEh
		db	0BAh,0AAh,0AAh,0AAh, 82h,0AFh
		db	0AAh,0AAh,0BEh,0AAh,0EFh,0AAh
		db	0AAh,0FFh,0FFh,0A6h,0AAh, 0Ah
		db	 07h,0D5h, 7Dh,0FFh,0FFh,0FFh
		db	0FEh,0FBh,0EBh,0AFh,0FEh,0BAh
		db	 06h,0AAh, 04h, 00h,0AAh,0FAh
		db	0EFh,0EEh, 88h,0FFh,0AAh,0BEh
		db	0BAh,0AAh,0FEh,0EAh,0AAh,0FEh
		db	0BEh,0BAh,0BAh,0ABh,0AAh,0ABh
		db	0FEh,0BAh,0AAh,0AAh,0AAh,0C3h
		db	0BAh,0EAh,0AAh,0FEh,0AAh,0BFh
		db	0AAh,0ABh,0FFh,0FEh,0A6h, 8Ah
		db	 0Ah, 87h, 75h,0D7h, 5Fh,0FFh
		db	0FFh,0EBh,0EFh,0AAh,0AFh,0FAh
		db	0BAh, 06h,0AAh, 04h, 08h, 2Bh
		db	0BEh,0EFh,0BFh,0A8h,0FFh,0BAh
		db	0EFh,0FAh,0AAh,0FBh,0AAh,0AEh
		db	0FEh,0BEh,0BAh,0BAh,0ABh,0EAh
		db	0ABh,0FEh,0BAh,0AAh,0AAh,0AAh
		db	0CEh,0AFh,0AAh,0AEh,0FAh,0AAh
		db	0BBh,0EBh,0ABh,0FFh,0FAh,0AAh
		db	 8Ah, 0Ah, 07h, 7Fh,0FDh,0FFh
		db	0FFh,0FEh,0AEh,0FBh,0ABh,0BFh
		db	0FAh,0EAh, 06h,0AAh, 04h, 0Ah
		db	0AFh,0EFh,0ABh,0FFh,0A8h,0FEh
		db	0AEh,0EEh,0FAh,0AAh,0FBh,0AAh
		db	0AEh,0FEh,0BAh,0BAh,0BAh,0ABh
		db	0EAh,0ABh,0FEh,0BAh,0AAh,0AAh
		db	0AAh, 20h,0BEh,0AAh,0BBh,0FAh
		db	0AAh,0BFh,0EBh,0BBh,0FEh,0AAh
		db	0AAh, 8Ah, 20h, 0Fh, 7Fh,0FFh
		db	0FFh,0FFh,0FEh,0BBh,0AFh,0AEh
		db	0FFh,0EAh, 06h,0AAh, 05h, 8Bh
		db	0AFh,0EAh,0EFh,0EFh,0A0h,0FEh
		db	0EAh,0FBh,0EAh,0ABh,0EEh,0AAh
		db	0BAh,0EEh,0BEh,0BAh,0BAh,0ABh
		db	0EAh,0ABh,0FEh,0FAh,0AAh,0AAh
		db	0AAh, 00h,0FAh,0AAh,0EFh,0FAh
		db	0ABh,0EEh,0EFh, 2Fh,0FEh,0A6h
		db	 9Ah, 2Ah, 0Ah, 3Dh,0FFh,0DDh
		db	0FFh,0FFh,0FEh,0AFh,0AEh,0AAh
		db	0FFh,0EAh, 06h,0AAh, 05h, 2Bh
		db	0FFh,0EAh,0BBh,0EFh,0A2h,0FEh
		db	0FBh,0FBh,0AAh,0ABh,0FBh,0AAh
		db	0BAh,0FEh,0EEh,0BAh,0BAh,0ABh
		db	0BAh,0ABh,0FEh,0EEh,0AAh,0AAh
		db	0AAh, 02h,0BAh,0AFh,0BFh,0EAh
		db	0ABh,0FEh,0ECh, 3Fh,0FEh, 6Ah
		db	0AAh, 2Ah, 20h, 1Dh,0FFh,0F7h
		db	0DFh,0F7h,0FAh,0EFh,0BAh,0AFh
		db	0FFh, 06h,0AAh, 06h, 2Ah,0BFh
		db	0AAh,0AFh,0BAh,0A2h,0FBh,0EFh
		db	0AFh,0EAh,0ABh,0FBh,0AEh,0EEh
		db	0FAh,0FAh,0AEh,0AEh,0BBh,0EAh
		db	0ABh,0FEh,0EEh,0AAh,0AAh,0AAh
		db	 08h,0AAh,0FAh,0FBh,0BAh,0AFh
		db	0EFh,0BCh,0FFh,0FAh, 69h,0AAh
		db	 28h,0A0h,0F5h,0F7h,0DFh,0DFh
		db	 5Fh,0EBh,0BEh,0FEh,0AEh,0FEh
		db	 06h,0AAh, 06h, 0Fh,0FFh,0AAh
		db	0ABh,0EEh,0BBh,0FBh,0AFh,0EFh
		db	0BAh,0AFh,0EBh,0AAh,0BBh,0BEh
		db	0EEh,0AEh,0AEh,0BBh,0AAh,0ABh
		db	0FEh,0EEh,0AAh,0AAh,0AAh,0C0h
		db	0AFh,0EBh,0FEh,0EAh,0AFh,0FFh
		db	0BCh,0FFh,0EAh,0A9h, 6Ah, 28h
		db	 88h,0D5h, 77h, 5Fh,0DDh, 5Fh
		db	0EBh,0FBh,0FAh,0EFh,0FEh, 06h
		db	0AAh, 06h, 3Fh,0FEh,0BAh,0ABh
		db	0EBh,0ABh,0EFh,0ABh,0FFh,0BAh
		db	0BFh,0EEh,0AEh,0BEh,0BEh,0EEh
		db	0AEh,0AEh,0AEh,0FEh,0AAh,0FBh
		db	 06h,0AAh, 04h, 08h, 3Bh,0BFh
		db	0EBh,0EAh,0AFh,0EEh,0F3h,0FFh
		db	0E9h,0A5h,0AAh,0A8h,0A1h,0F7h
		db	0F7h,0DFh, 55h, 7Fh,0AEh,0BEh
		db	0EAh,0BFh,0FEh, 06h,0AAh, 06h
		db	 3Fh,0EAh,0EAh,0AAh,0BBh,0EBh
		db	0BAh,0AEh,0FFh,0EAh,0AFh,0EEh
		db	0AEh,0BAh,0EEh,0FAh,0AEh,0AEh
		db	0ABh,0EBh,0AAh,0FBh,0AEh,0AAh
		db	0AAh,0AAh, 30h, 0Fh,0FFh,0AEh
		db	0AAh,0BFh,0FEh,0FFh,0FFh,0F9h
		db	0A5h,0A8h,0A0h, 89h, 77h,0DFh
		db	0DDh, 55h,0FAh,0BFh,0BAh,0EAh
		db	0FFh,0FAh, 06h,0AAh, 05h,0A8h
		db	0FFh,0AEh,0EAh,0AAh,0AAh,0BFh
		db	0FEh,0AAh,0FEh,0EAh,0BEh,0EEh
		db	0AEh,0AEh,0FAh,0EEh,0AAh,0ABh
		db	0AAh,0EFh,0AEh,0FBh,0AEh,0AAh
		db	0AAh,0AAh, 30h, 0Bh,0FEh,0FAh
		db	0AAh,0FFh,0FBh,0FCh,0FFh,0F9h
		db	0A6h,0A8h, 88h, 81h, 7Dh, 5Fh
		db	0FDh, 5Fh,0FAh,0FEh,0ABh,0EBh
		db	0BFh, 06h,0AAh, 07h,0FFh,0ABh
		db	0AAh,0AAh,0AAh,0ABh,0FFh,0EAh
		db	0FBh,0AAh,0BEh,0EBh,0ABh,0BBh
		db	0BAh,0FAh,0ABh,0ABh,0AAh,0EFh
		db	0ABh,0FBh,0AEh,0AAh,0AAh,0AAh
		db	 33h, 83h,0FFh,0EEh,0EFh,0FFh
		db	0FBh,0FFh,0FFh,0FAh,0AAh,0A2h
		db	 8Ah, 8Dh, 5Fh, 5Fh,0F5h, 5Fh
		db	0FAh,0EEh,0EBh,0AAh,0FAh, 06h
		db	0AAh, 04h,0AEh,0AAh,0BFh,0FFh
		db	0BAh,0AAh,0AAh,0A8h,0AAh,0AFh
		db	0FAh,0EEh,0FAh,0AEh,0FBh,0AAh
		db	0FEh,0FEh,0EAh,0AFh,0ABh,0AAh
		db	0EAh,0AEh,0FBh,0AEh,0AAh,0AAh
		db	0AAh, 30h, 23h,0FFh,0FBh,0FFh
		db	0FFh,0EFh,0FFh,0FFh,0FAh,0AAh
		db	0A2h, 88h, 8Fh, 75h,0FFh,0D5h
		db	 7Fh,0BBh,0ABh,0AFh,0ABh,0EAh
		db	 06h,0AAh, 04h,0BFh,0FFh,0EFh
		db	0FEh,0FAh,0AAh,0AAh,0A8h, 8Ah
		db	0ABh,0FEh,0BFh,0FEh,0AEh,0FBh
		db	0ABh,0EFh,0EEh,0FAh,0AFh,0ABh
		db	0AAh,0EBh,0AFh,0FEh,0AEh,0EAh
		db	0AAh,0AAh, 88h,0C0h, 06h,0FFh
		db	 04h,0E3h,0FFh,0FFh,0E6h,0AAh
		db	0AAh, 2Ah, 0Fh,0FFh,0FFh,0D5h
		db	0FFh,0EFh,0AAh,0BEh,0AFh,0EAh
		db	0AAh,0AAh,0AAh,0ABh,0BFh,0FFh
		db	0AFh,0FAh,0EAh,0AAh,0AAh,0AAh
		db	 22h,0AAh,0BFh,0EFh,0BAh,0ABh
		db	0EEh,0AFh,0BBh,0EEh,0FAh, 9Fh
		db	0ABh,0AAh,0EBh,0BBh,0FEh,0BAh
		db	0AAh,0AAh,0AAh, 8Ah, 38h, 3Fh
		db	0FFh,0FFh,0FFh,0ECh,0FFh,0FFh
		db	0E6h,0AAh,0AAh,0A8h, 0Fh,0FFh
		db	0FFh, 57h,0FFh,0BBh,0AAh,0EAh
		db	0AFh,0BAh,0AAh,0AAh,0AAh,0ABh
		db	0FFh,0FAh,0BFh,0ABh,0EAh,0AAh
		db	0AAh,0AAh, 22h,0AAh,0ABh,0FBh
		db	0EEh,0FBh,0AAh,0FBh,0FEh,0FAh
		db	0FAh,0ABh,0EBh,0AAh,0BBh,0BFh
		db	0FEh,0BBh,0AAh,0AAh,0AAh,0B3h
		db	 38h, 2Fh,0FEh,0FFh,0FBh,0E3h
		db	0FFh,0FFh,0AAh,0AAh,0A8h,0A0h
		db	 2Fh,0FFh,0FDh, 5Fh,0FAh,0AEh
		db	0AAh,0FAh,0AFh,0EAh,0AAh,0AAh
		db	0AAh,0AFh,0FEh,0ABh,0FFh,0ABh
		db	 06h,0AAh, 04h, 28h, 2Ah,0AAh
		db	0BBh,0FBh,0BEh,0FFh,0BEh,0FBh
		db	0BAh,0EAh, 7Bh,0EAh,0EAh,0BBh
		db	0BFh,0BAh,0BEh,0AAh,0AAh,0AAh
		db	0FCh, 8Eh, 0Ah,0FBh,0FFh,0FEh
		db	0ECh,0FFh,0FFh,0AAh,0AAh, 88h
		db	 89h, 7Fh,0FFh,0F5h, 5Fh,0EBh
		db	0BAh,0ABh,0EAh,0BEh,0FAh,0AAh
		db	0AAh,0AAh,0ABh,0FAh,0EEh,0FEh
		db	0AFh, 06h,0AAh, 04h, 0Ah, 00h
		db	0AAh,0AEh,0FFh,0EBh,0AFh,0FAh
		db	0FFh,0BBh,0BAh, 7Bh,0EAh,0EAh
		db	0BAh,0AFh,0FAh,0BEh,0AAh,0AAh
		db	0AAh,0BCh,0A2h, 03h,0FFh,0FFh
		db	0FAh,0F3h,0FFh,0FEh, 9Ah, 6Ah
		db	 82h, 17h,0FFh,0FFh,0F5h, 7Fh
		db	0AFh,0EEh,0ABh,0EAh,0FBh,0EAh
		db	 06h,0AAh, 04h,0FBh,0BBh,0FEh
		db	0AEh,0AAh,0EAh,0AAh,0AAh, 0Ah
		db	 80h, 00h,0ABh,0BEh,0BFh,0AFh
		db	0EBh,0BBh,0BBh,0EAh,0AFh,0EAh
		db	0EAh,0BBh,0AFh,0EEh,0BAh,0AAh
		db	0AAh,0AAh,0FAh, 2Ch, 83h,0FFh
		db	0FFh,0AEh,0F3h,0FFh,0FEh, 6Ah
		db	 6Ah, 28h, 5Fh,0FFh,0FFh,0D5h
		db	0FBh,0BEh,0EEh,0ABh,0ABh,0BFh
		db	0BAh, 06h,0AAh, 04h,0EAh,0EFh
		db	0FEh,0BEh,0ABh,0FAh,0AAh,0A8h
		db	 80h,0AAh, 80h, 2Ah,0ABh,0FAh
		db	0FEh,0BBh,0FEh,0EBh,0EAh, 6Fh
		db	0EAh,0EAh,0BBh,0ABh,0EEh,0BEh
		db	0AAh,0AAh,0AAh,0FEh, 8Ah,0E0h
		db	0EAh,0EAh,0EBh, 8Fh,0FFh,0FEh
		db	 6Ah,0AAh, 28h, 57h,0FFh,0FFh
		db	0D5h,0EEh,0BAh,0BAh,0AFh,0AAh
		db	0FBh,0EAh, 06h,0AAh, 04h,0ABh
		db	0AFh,0FAh,0BAh,0AFh,0FAh,0AAh
		db	0AAh, 22h, 02h,0AAh, 8Ah,0AFh
		db	0FEh,0EBh,0EBh,0BAh,0EBh,0A9h
		db	0AFh,0EAh,0EAh,0AFh,0AEh,0EEh
		db	0EEh,0AAh,0AAh,0AAh,0AFh,0F0h
		db	0B8h, 02h,0AAh,0EAh, 8Fh,0FFh
		db	0FEh,0AAh,0A8h,0A0h, 57h,0FFh
		db	0FFh, 57h,0EFh,0ABh,0EAh,0EFh
		db	0ABh,0FFh,0BAh,0AAh,0AAh,0AAh
		db	0FAh,0ABh,0BFh,0FAh,0BAh,0AFh
		db	0AEh,0AAh,0AAh,0A8h, 20h, 0Ah
		db	 2Ah, 8Fh,0FAh,0AFh,0AEh,0FEh
		db	0AEh,0AAh,0BBh,0EAh,0EAh,0AFh
		db	0ABh,0FAh,0FAh, 06h,0AAh, 04h
		db	0BFh, 0Ah, 20h, 3Bh,0ABh,0CFh
		db	0FBh,0FEh,0AAh, 68h,0A1h, 75h
		db	0FFh,0FDh, 76h,0BFh,0AFh,0ABh
		db	0FFh,0AFh,0FFh,0EAh,0AAh,0AAh
		db	0AAh,0EFh,0AEh,0FEh,0EAh,0BEh
		db	0BFh,0ABh,0AAh,0AAh, 0Ah, 00h
		db	 20h, 2Ah, 8Fh,0EEh,0AEh,0AFh
		db	0BAh,0AEh,0A9h,0BBh,0EAh,0EAh
		db	0AFh,0ABh,0FAh,0EEh,0AAh,0AAh
		db	0AAh, 2Ah,0AAh,0E0h, 2Ch, 0Ah
		db	0AFh, 3Fh,0FBh,0FEh,0AAh, 98h
		db	 01h,0F7h,0FFh,0FDh,0DAh,0EEh
		db	0BAh,0AEh,0FEh,0AFh,0FFh,0EAh
		db	0AAh,0AAh,0ABh,0FFh,0AFh,0FFh
		db	0ABh,0FAh,0FEh,0EBh,0AAh,0AAh
		db	0A2h, 80h, 80h,0AEh, 3Fh,0FAh
		db	0AEh,0AEh,0EAh,0EEh,0AAh,0BBh
		db	0EAh,0EAh,0AEh,0AAh,0FAh,0AEh
		db	0AAh,0AAh,0AAh, 8Ah,0AAh,0BAh
		db	 80h,0A8h, 0Bh, 3Fh,0FFh,0FEh
		db	0A9h,0A0h, 15h,0FFh,0FFh, 55h
		db	0DBh,0AEh,0BAh,0BBh,0FEh,0BFh
		db	0FFh,0EAh,0AAh,0AAh,0ABh,0EFh
		db	0AFh,0EEh,0FEh,0EFh,0FAh,0EAh
		db	0EBh,0EAh,0A8h, 2Ah, 8Ah,0FBh
		db	 3Fh,0AAh,0BEh,0ABh,0EAh,0AEh
		db	0A6h,0BBh,0EAh,0EAh,0ABh,0AEh
		db	0EAh,0FAh,0AAh,0AAh,0AAh, 80h
		db	0AAh,0ABh,0FBh, 0Ah,0ACh,0FFh
		db	0EFh,0FFh,0AAh, 81h, 7Fh,0FFh
		db	0F5h,0FDh, 5Bh,0EAh,0EAh,0BBh
		db	0EAh,0FBh,0FFh,0AAh,0AAh,0AAh
		db	0ABh,0BEh,0BFh,0FFh,0AFh,0BFh
		db	0EBh,0AAh,0EEh,0FFh,0AAh, 80h
		db	 0Ah,0BEh, 8Fh,0EAh,0BAh,0AEh
		db	0EAh,0BAh,0A6h,0BFh,0EAh,0EAh
		db	0AEh,0AFh,0BAh,0FAh,0AAh,0AAh
		db	0AAh,0A0h, 2Ah,0AAh,0AEh,0FAh
		db	0F0h,0FFh,0AFh,0FFh,0BFh, 95h
		db	 7Fh,0FFh,0F7h,0D6h,0EFh,0AAh
		db	0AAh,0EFh,0EBh,0FFh,0FBh,0EAh
		db	0AAh,0AAh,0AFh,0BEh,0BFh,0FAh
		db	0EEh,0EEh,0BEh,0A2h,0BAh,0BFh
		db	0FEh,0AAh, 0Bh,0FEh, 3Fh,0B6h
		db	0EEh,0AFh,0AAh,0BAh, 99h,0BFh
		db	0EAh,0EAh,0AEh,0AFh,0EAh,0FAh
		db	 06h,0AAh, 04h, 02h,0AAh,0AAh
		db	0ABh,0EFh,0FAh,0BFh,0FEh,0BAh
		db	0FFh,0FFh,0EEh,0FEh,0AFh,0EFh
		db	0AEh,0AAh,0AEh,0AAh,0EFh,0FAh
		db	0AAh,0AAh,0AAh,0BBh,0EEh,0ABh
		db	0EEh,0FBh,0BAh,0FAh,0A2h,0BBh
		db	0EEh,0FEh,0EAh, 8Ah,0FAh, 3Bh
		db	 5Ah,0EAh,0BBh,0AAh,0AAh,0AAh
		db	0AFh,0EAh,0BAh,0AAh,0AAh,0EAh
		db	0FAh,0AAh,0AAh,0AAh,0A8h,0A0h
		db	 02h,0AAh,0AEh,0FBh,0EEh,0BBh
		db	0FAh,0AEh,0FFh,0BFh,0EBh,0BEh
		db	0AFh,0FBh,0BBh,0AAh,0BEh,0AAh
		db	0BFh,0EBh,0AAh,0AAh,0AAh,0BFh
		db	0EAh,0AEh,0BFh,0AEh,0FAh,0EEh
		db	0A8h,0AFh,0BBh,0FBh,0AAh,0AAh
		db	0F8h, 3Eh,0B6h,0AAh,0BEh,0AAh
		db	0AAh,0AAh,0EFh,0EAh,0BAh,0AAh
		db	0AEh,0EAh,0EAh, 06h,0AAh, 04h
		db	 08h, 00h, 02h,0AFh,0AFh,0AEh
		db	0FEh,0FEh,0BAh,0FFh,0EEh,0AFh
		db	0FAh,0BBh,0FFh,0EBh,0AAh,0BAh
		db	0AAh,0BFh,0ABh,0AAh,0AAh,0AAh
		db	0BEh,0EAh,0AEh,0BEh, 3Fh,0E8h
		db	0FAh,0A8h,0BAh,0BEh,0BEh,0FFh
		db	0AAh,0A8h,0FFh, 5Ah,0EAh, 06h
		db	0AAh, 04h,0BFh,0EAh,0BAh,0AAh
		db	0BBh,0AAh,0BAh, 06h,0AAh, 04h
		db	0A0h, 0Ah,0AAh,0FEh,0FBh,0ABh
		db	0EAh,0BAh,0BBh,0FFh,0FAh,0AFh
		db	0EAh,0BFh,0BBh,0AAh,0AAh,0FEh
		db	0AAh,0BEh,0AEh,0AAh,0AAh,0AAh
		db	0FBh,0AAh,0AEh,0BAh, 3Fh,0F8h
		db	0FEh,0A2h, 2Fh,0BBh,0FAh,0BFh
		db	0FBh,0A8h,0EEh, 6Ah,0AAh,0BAh
		db	0AAh,0AAh,0AAh,0FFh,0EAh,0BAh
		db	0AAh,0BEh,0AAh,0FAh, 06h,0AAh
		db	 05h,0A0h, 2Fh,0EFh,0EAh,0AFh
		db	0ABh,0EAh,0ABh,0FBh,0AAh,0BFh
		db	0EAh,0BFh,0BEh,0AAh,0AAh,0BAh
		db	0AAh,0BEh,0AEh,0AAh,0AAh,0AAh
		db	0EEh,0EAh,0BAh,0B8h, 3Fh,0B8h
		db	0BFh,0A8h, 8Bh,0AAh,0ABh,0EEh
		db	0BEh, 83h,0BFh, 06h,0AAh, 06h
		db	0EFh,0EAh,0BAh,0AAh,0BEh,0AAh
		db	0FAh, 06h,0AAh, 06h,0BEh,0EFh
		db	0AAh,0BAh,0AAh,0EAh,0ABh,0FEh
		db	0AAh,0BFh,0EAh,0EEh,0BFh,0AEh
		db	0AAh,0EAh,0AAh,0FAh,0BAh,0AAh
		db	0AAh,0AAh,0FBh,0AAh,0EAh,0A8h
		db	 2Ah,0E8h,0FAh,0A8h,0A0h,0BEh
		db	0AAh,0AAh,0A2h, 23h,0EFh,0AAh
		db	0EAh,0BAh,0AAh,0AAh,0AAh,0FAh
		db	0EAh,0BAh,0AAh,0BAh,0AAh,0EAh
		db	 06h,0AAh, 06h,0EFh,0BAh,0AAh
		db	0AAh,0ABh,0AAh,0ABh,0BBh,0AAh
		db	0FFh,0BAh,0BEh,0EEh,0AAh,0AAh
		db	0EAh,0AAh,0EAh, 06h,0AAh, 04h
		db	0FBh,0AAh,0BAh,0BAh, 3Ah,0E8h
		db	 3Eh,0A8h, 2Ah, 20h, 0Fh,0BAh
		db	 00h,0FFh,0BAh,0ABh, 06h,0AAh
		db	 05h,0EBh,0AAh,0BAh,0AAh,0EEh
		db	0AAh,0EAh, 06h,0AAh, 06h,0BFh
		db	0EAh, 06h,0AAh, 04h,0AFh,0FEh
		db	0ABh,0FFh,0EAh,0FEh,0FEh,0AAh
		db	0ABh,0AAh,0ABh,0EAh,0AAh,0AAh
		db	0AAh,0ABh,0BEh,0AAh,0EAh,0A8h
		db	 3Ah,0A0h,0FAh,0AAh, 0Ah,0AAh
		db	 2Ah,0A0h, 3Fh,0AFh,0EAh,0AEh
		db	 06h,0AAh, 04h,0ABh,0BBh,0AAh
		db	0BAh,0AAh,0FAh, 06h,0AAh, 07h
		db	0BAh,0FBh,0AAh,0EAh,0AAh,0BAh
		db	0AAh,0FFh,0EAh,0ABh,0FEh,0AAh
		db	0FAh,0FBh,0AAh,0AFh, 06h,0AAh
		db	 06h,0ABh,0EEh,0AAh,0EAh,0A2h
		db	 3Eh,0A8h,0FEh,0AAh,0A2h,0A0h
		db	 80h, 3Fh,0EFh,0AAh,0AAh,0AEh
		db	 06h,0AAh, 07h,0BAh,0AAh,0FAh
		db	 06h,0AAh, 07h,0BEh,0FEh,0AFh
		db	0AAh,0AAh,0BAh,0ABh,0FEh,0AEh
		db	0AFh,0FEh,0AAh,0EAh,0EBh,0AAh
		db	0AFh,0AAh,0ABh, 06h,0AAh, 04h
		db	0AEh,0EAh,0ABh,0AAh,0A8h,0AEh
		db	0A2h,0FAh,0AAh,0AAh, 08h, 0Ch
		db	0EFh,0BAh,0AAh,0AAh,0BAh, 06h
		db	0AAh, 05h,0AEh,0AAh,0EAh,0AAh
		db	0FAh, 06h,0AAh, 06h,0ABh,0EBh
		db	0AAh,0BAh,0AAh,0AAh,0BAh,0ABh
		db	0FAh,0BAh
data_3		db	0BFh			; Data table (indexed access)
		db	0FAh,0ABh,0AAh,0EAh,0AAh,0BEh
		db	 06h,0AAh, 06h,0AFh,0AAh,0ABh
		db	0AAh,0A2h,0EAh,0A0h,0FAh,0AAh
		db	0A0h, 20h,0FFh,0BAh, 06h,0AAh
		db	 0Bh,0EAh,0AAh,0EAh, 06h,0AAh
		db	 06h,0BEh,0AAh,0AAh,0BAh,0AAh
		db	0EAh,0EAh,0AAh,0EBh,0EAh,0BFh
		db	0BAh,0AAh,0AAh,0ABh,0AAh,0BBh
		db	0AAh,0AEh, 06h,0AAh, 04h,0AFh
		db	0AAh,0AAh,0AAh,0A8h,0EAh,0A2h
		db	0AAh,0AAh, 22h,0AEh,0EEh,0AAh
		db	0AAh,0AAh,0ABh, 06h,0AAh, 06h
		db	0AEh,0AAh,0AAh,0AAh,0FAh, 06h
		db	0AAh, 06h,0EEh,0AAh,0AAh,0EAh
		db	0ABh,0AAh,0EAh,0ABh,0BEh,0AAh
		db	0FEh,0EAh,0AAh,0AAh,0EBh,0AAh
		db	0AEh, 06h,0AAh, 06h,0BEh, 06h
		db	0AAh, 05h, 8Bh,0AAh,0AAh,0AAh
		db	0AFh,0BAh, 06h,0AAh, 0Bh,0ABh
		db	0AAh,0ABh,0BAh, 06h,0AAh, 05h
		db	0ABh, 06h,0AAh, 04h,0ABh,0ABh
		db	0AAh,0ABh,0EEh,0AAh,0FAh,0AAh
		db	0AAh,0ABh,0ABh,0AAh,0BAh,0AAh
		db	0BAh, 06h,0AAh, 04h,0BFh, 06h
		db	0AAh, 05h,0A3h,0AAh,0AAh,0AAh
		db	0BAh, 06h,0AAh, 0Bh,0AEh,0ABh
		db	0AAh,0ABh,0EAh, 06h,0AAh, 05h
		db	0BAh, 06h,0AAh, 04h,0AFh,0AAh
		db	0AAh,0ABh,0BAh,0ABh,0EEh,0AAh
		db	0AAh,0AAh,0AEh,0AAh,0BAh,0AAh
		db	0BAh, 06h,0AAh, 04h,0BBh,0AAh
		db	0AAh,0AAh,0AEh,0AAh,0ABh, 06h
		db	0AAh, 0Fh,0BAh,0AEh,0AAh,0ABh
		db	0EAh, 06h,0AAh, 05h,0EAh, 06h
		db	0AAh, 04h,0BEh,0AAh,0AAh,0ABh
		db	0BAh,0ABh,0EAh, 06h,0AAh, 07h
		db	0EAh, 06h,0AAh, 04h,0EEh, 06h
		db	0AAh, 09h,0BAh, 06h,0AAh, 0Eh
		db	0ABh,0EAh, 06h,0AAh, 09h,0AFh
		db	0EAh,0AAh,0AAh,0ABh,0AAh,0ABh
		db	 06h,0AAh, 0Dh,0FAh, 06h,0AAh
		db	 08h,0ABh,0EAh, 06h,0AAh, 0Ch
		db	0FAh, 06h,0AAh, 0Ch,0BAh,0AAh
		db	0AAh,0AAh,0AEh, 06h,0AAh, 0Fh
		db	0BAh, 06h,0AAh, 08h,0BEh, 06h
		db	0AAh, 0Fh,0ABh, 06h,0AAh, 1Eh
		db	0EAh, 06h,0AAh, 07h,0ABh, 06h
		db	0AAh, 17h, 06h,0AAh, 70h,0BBh
		db	0FBh,0BFh,0BBh,0BFh,0BBh,0BBh
		db	0FFh,0BBh,0BBh,0BFh, 06h,0BBh
		db	 08h,0FBh,0FFh,0FFh,0BBh,0BFh
		db	0FBh, 06h,0BBh, 10h,0FFh,0FFh
		db	0FBh, 06h,0BBh, 0Ch,0FEh,0FEh
		db	0FEh,0FFh,0FEh,0EFh,0FFh,0FFh
		db	0FFh,0EFh,0FFh,0FFh,0EEh,0EEh
		db	0EFh,0FEh,0EFh,0FFh,0FFh,0FEh
		db	0FFh,0EEh,0EFh,0FFh,0FFh,0FFh
		db	0EEh,0EFh,0EEh,0EFh,0FEh,0FFh
		db	0EFh,0FEh,0EFh,0EFh,0FFh,0FEh
		db	0FFh,0EFh,0FFh,0FFh,0FEh,0FFh
		db	0EEh, 06h,0EFh, 04h,0FEh,0FFh
		db	0FFh,0FEh,0EEh,0EEh,0EEh, 06h
		db	0FFh, 32h,0EFh,0FBh, 06h,0FFh
		db	0FFh, 06h,0FFh,0FFh, 06h,0FFh
		db	0F9h,0F0h, 2Bh,0BAh, 06h,0FFh
		db	 04h,0C2h,0BBh,0BAh,0AFh, 06h
		db	0FFh, 2Dh,0C3h,0EAh,0ABh,0BBh
		db	0EEh,0AFh,0FFh,0CEh,0AEh,0EFh
		db	 06h,0FFh, 1Eh,0FDh, 6Ah,0ABh
		db	0BBh,0BFh,0EEh, 06h,0FFh, 09h
		db	0FCh, 03h,0EBh,0BFh, 06h,0FFh
		db	 04h, 0Bh,0ABh, 06h,0FFh, 1Fh
		db	0FDh, 2Bh,0BFh, 06h,0FFh, 0Ch
		db	0F0h, 03h,0EAh,0EEh,0EFh,0FFh
		db	0FFh,0FFh, 0Eh,0AFh, 06h,0FFh
		db	 1Fh,0F4h,0AFh, 06h,0FFh, 0Dh
		db	0F0h, 0Fh,0EAh,0BFh,0FFh,0FFh
		db	0FFh,0FCh, 0Fh,0FBh, 06h,0FFh
		db	 10h,0C0h, 02h,0AAh,0BAh, 06h
		db	0FFh, 0Bh,0F4h, 2Bh,0BBh,0BAh
		db	0ABh,0EFh,0FFh,0BBh,0BBh,0AAh
		db	0AEh,0EEh,0FFh,0FFh,0FFh, 00h
		db	 3Fh,0EAh,0BFh,0FFh,0FFh,0FFh
		db	0FCh, 3Eh,0BFh,0FFh,0FFh,0FCh
		db	 02h,0AEh,0AAh,0EEh,0EEh,0FFh
		db	0BBh, 06h,0FFh, 05h,0C0h, 33h
		db	0FCh, 02h,0EFh, 06h,0FFh, 07h
		db	0AAh,0ABh,0BBh,0FFh,0F4h,0AAh
		db	0EEh,0EEh,0FFh,0FFh,0FBh,0BBh
		db	 06h,0FFh, 04h,0FBh,0BBh,0B0h
		db	0C0h, 3Eh,0EAh, 06h,0FFh, 04h
		db	0F0h, 3Ch,0BFh,0FFh,0FFh,0F0h
		db	 00h, 02h,0EEh,0AAh,0BFh, 06h
		db	0FFh, 06h,0C0h, 00h, 33h,0FBh
		db	0A8h,0AFh,0EAh,0EAh,0BEh,0AEh
		db	0EEh,0EEh,0EEh, 06h,0FFh, 04h
		db	0D8h, 2Ah,0AFh,0FFh,0FFh,0FFh
		db	 06h,0EEh, 04h,0FFh,0FBh,0BFh
		db	0FFh, 0Fh,0C0h, 3Fh,0EAh,0AEh
		db	0EAh,0AEh,0EEh,0C0h, 3Ch,0BFh
		db	0FFh,0FFh,0F0h, 03h,0FFh,0F0h
		db	0CFh,0AAh,0ABh,0BFh,0FFh,0F0h
		db	 06h, 00h, 04h, 33h,0FBh,0AAh
		db	0ABh,0AAh,0FBh,0BBh,0AAh,0BFh
		db	0FBh,0BBh,0AEh,0EFh,0AAh,0AAh
		db	 90h, 2Ah,0ABh,0BBh,0BBh,0BBh
		db	0EAh,0AAh,0BEh,0AAh,0ABh,0EFh
		db	0BFh,0FCh, 3Ch, 00h,0FEh,0FAh
		db	0BFh,0FFh,0FFh,0FFh, 03h, 3Ch
		db	 8Fh,0FFh,0FFh,0C0h, 03h,0FFh
		db	0CBh,0FFh, 00h, 00h,0F0h, 00h
		db	 0Fh,0C0h,0C3h, 00h, 00h, 33h
		db	0FFh,0AAh,0ABh, 06h,0AAh, 05h
		db	0D7h, 06h,0AAh, 04h,0ABh, 42h
		db	 06h,0AAh, 0Ah,0ACh,0AAh,0B0h
		db	0F0h, 00h,0FFh,0B8h,0AAh,0AAh
		db	0ACh, 00h,0C3h, 3Eh, 2Eh,0AAh
		db	0AAh,0C0h, 03h, 06h,0FFh, 04h
		db	 33h,0F3h, 0Ch,0FFh,0C0h, 3Ch
		db	0C0h, 00h, 33h,0FBh,0AAh,0ABh
		db	 06h,0FFh, 04h,0D0h, 57h, 06h
		db	0FFh, 05h, 42h,0AAh,0ABh,0BBh
		db	0B6h,0FFh,0FBh,0BBh,0FEh,0EEh
		db	0FAh,0F0h, 3Fh,0C0h,0F0h, 03h
		db	0FEh,0E8h,0AFh,0FFh,0F0h, 33h
		db	 3Fh, 3Eh, 22h,0FFh,0FFh, 00h
		db	 03h, 3Fh,0FFh,0FFh,0FFh, 33h
		db	0F3h, 0Ch,0CFh,0F0h,0FFh,0C0h
		db	 00h, 33h,0FBh,0BAh,0ABh,0AAh
		db	0AAh,0AAh,0B4h, 05h, 55h,0FAh
		db	0AAh,0AAh,0ABh, 7Dh, 04h, 28h
		db	0AAh,0ABh, 56h, 06h,0AAh, 06h
		db	0B0h,0CAh,0C3h, 30h, 0Fh,0FEh
		db	0E8h, 2Ah,0AAh,0B0h, 00h, 3Ch
		db	0FEh, 8Ah,0AAh,0ABh, 00h, 03h
		db	 3Fh,0FFh,0FFh,0FFh, 0Fh,0F3h
		db	 0Ch,0CFh,0C3h, 3Fh,0C0h, 00h
		db	0F3h,0FBh,0AAh,0ABh,0D1h, 7Fh
		db	0FDh, 05h, 5Dh, 77h,0FFh,0F5h
		db	0EAh,0ADh, 7Dh, 88h,0E8h,0AAh
		db	0ABh, 57h,0AAh,0B6h, 06h,0AAh
		db	 04h,0B0h,0CAh,0C0h,0F0h, 0Fh
		db	0FEh,0EAh, 0Ah,0AAh,0B3h, 00h
		db	0FCh,0FAh,0A8h,0AAh,0ACh, 00h
		db	 0Ch, 06h,0FFh, 04h, 0Fh,0F3h
		db	 0Ch,0CFh,0CCh,0FFh,0C0h, 00h
		db	0CFh,0FFh,0AAh,0EAh, 41h,0FFh
		db	0D0h, 5Fh, 75h, 5Fh,0FFh,0D7h
		db	0FAh,0ADh,0DDh, 8Bh, 28h,0AAh
		db	0ADh, 57h,0EAh,0D7h, 06h,0AAh
		db	 04h,0C3h, 0Ah,0C3h,0F0h, 3Fh
		db	0FFh,0AEh, 8Ah,0AAh,0C0h, 0Fh
		db	0F3h,0EEh, 88h,0AAh,0ACh, 00h
		db	 3Ch, 06h,0FFh, 04h, 0Fh,0F3h
		db	 0Ch,0FFh,0C3h,0FFh,0C0h, 00h
		db	0CFh,0FEh,0AAh,0AAh, 57h,0FFh
		db	 55h, 7Dh,0F7h, 7Fh,0FFh,0DFh
		db	0FFh,0ADh, 35h, 30h,0A8h, 8Ah
		db	0A9h, 5Dh,0FBh, 57h,0EAh,0AAh
		db	0AAh,0ABh, 00h,0F3h, 00h,0C0h
		db	 3Fh,0FBh,0AEh, 0Ah,0ABh, 0Ch
		db	0CFh, 33h,0FEh, 80h,0AAh,0A0h
		db	 00h, 3Ch, 06h,0FFh, 04h, 3Fh
		db	0C3h, 33h,0CFh,0C3h,0FFh,0C0h
		db	 00h, 0Fh,0FEh,0AAh,0AAh, 75h
		db	0FFh, 55h,0FDh,0D7h, 7Fh,0FFh
		db	0DFh,0FFh,0F7h, 7Dh, 00h,0B8h
loc_53:
		or	ch,ss:data_19e[bp+si]
		ja	loc_53			; Jump if above
		test	al,0AAh
		stosw				; Store ax to es:[di]
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		retn
			                        ;* No entry point to code
		aas				; Ascii adjust
		sti				; Enable interrupts
		scasb				; Scan es:[di] for al
;*		sub	byte ptr ss:data_15e[bp+di],0CFh
		db	 82h,0ABh, 30h, 3Ch,0CFh	;  Fixup - byte match
		out	dx,al			; port 0, DMA-1 bas&add ch 0
;*		sub	byte ptr [bp+si],0
		db	 82h, 2Ah, 00h		;  Fixup - byte match
;*		add	al,dh
		db	 00h,0F0h		;  Fixup - byte match
		db	0FFh,0FFh,0FFh,0FCh,0CFh,0C3h
		db	 33h,0CFh,0CFh,0FFh,0C0h, 00h
		db	0F3h,0FFh,0AAh,0BAh,0D7h,0FFh
		db	 77h,0F5h, 5Dh, 06h,0FFh, 04h
		db	0C4h, 30h,0C2h,0B8h, 08h, 88h
		db	0A9h,0F5h, 5Fh,0FFh,0C0h, 0Ah
		db	0ABh, 03h,0FCh, 33h, 03h, 3Fh
		db	0FBh,0BEh, 88h,0ACh, 00h, 3Fh
		db	0FFh,0BAh, 82h, 20h, 00h, 00h
		db	0F3h,0FFh,0FFh,0FFh,0FCh, 3Fh
		db	0C0h,0F3h,0CFh,0F3h,0FFh,0C0h
		db	 00h, 33h,0FFh,0EAh,0EAh, 1Fh
		db	0FFh,0DFh,0D7h, 75h, 06h,0FFh
		db	 04h,0D0h, 30h, 4Bh,0A8h, 20h
		db	0A2h, 2Ah,0D5h, 7Fh,0F0h, 00h
		db	 00h, 3Ch, 00h,0F0h,0CFh, 0Ch
		db	0FFh,0FFh,0AEh,0A2h,0ACh,0C3h
		db	 30h,0FFh,0BEh, 88h, 80h, 00h
		db	 00h,0CFh,0FFh,0FFh,0FFh,0F3h
		db	 3Fh,0C0h,0F3h, 3Fh,0CFh,0FFh
		db	0C0h, 00h, 33h,0FEh,0EBh,0AEh
		db	 3Fh,0FFh,0DFh, 55h, 57h, 06h
		db	0FFh, 04h,0D0h,0C1h,0EBh,0AAh
		db	 08h, 28h,0AAh,0A8h,0B0h, 00h
		db	 00h, 00h, 03h, 0Fh, 30h, 3Ch
		db	 0Ch,0FFh,0EFh,0BBh, 82h,0AAh
		db	 00h,0F3h,0FEh,0BAh, 80h, 80h
		db	 00h, 00h,0CFh,0FFh,0FFh,0FFh
		db	 0Ch,0FFh,0C0h,0F3h, 3Fh,0CFh
		db	0FFh,0C0h, 00h,0F3h,0FEh,0EAh
		db	0AEh,0FFh,0FFh, 7Fh, 5Dh, 57h
		db	 06h,0FFh, 04h,0C1h,0C9h, 4Ah
		db	0AAh, 0Ah, 88h, 00h, 80h, 06h
		db	 00h, 04h, 0Ch, 30h,0FCh,0FCh
		db	 3Ch,0FFh,0FFh,0BBh,0A0h,0AAh
		db	 0Ch,0C3h,0EAh,0FAh,0A0h, 00h
		db	 00h, 03h,0CFh,0FFh,0FFh,0FCh
		db	0F3h,0FFh, 33h, 33h, 3Fh,0F3h
		db	0FFh, 30h, 00h,0F3h,0FEh,0EAh
		db	0AFh, 0Fh,0FDh,0FFh, 75h, 77h
		db	 06h,0FFh, 04h, 43h, 13h, 0Ah
		db	0AAh, 82h,0A0h, 06h, 00h, 06h
		db	 30h,0FCh,0F3h,0F0h, 3Ch,0FFh
		db	0EEh,0FAh,0A8h, 2Ah, 83h,0CFh
		db	0BAh,0FAh,0A2h, 00h, 00h, 30h
		db	0CFh,0FFh,0FFh,0F3h,0CFh,0FFh
		db	 30h,0F3h, 3Fh,0F3h,0FFh,0C0h
		db	 00h,0FFh,0FEh,0EBh,0AEh,0CFh
		db	0FFh,0FDh, 77h, 5Fh, 06h,0FFh
		db	 04h, 40h, 16h,0CAh,0EAh, 82h
		db	 80h, 06h, 00h, 04h, 0Ch, 00h
		db	0F0h,0CFh,0C3h,0C0h,0F3h,0FFh
		db	0BEh,0BBh,0E2h, 0Ah,0B3h,0FFh
		db	0AAh,0EEh,0A0h, 00h, 0Ch, 3Ch
		db	 3Fh,0FFh,0FFh,0F3h,0CFh,0FFh
		db	 30h, 33h, 3Fh,0F3h,0FFh,0F0h
		db	 00h,0F3h,0FEh,0EBh,0AEh, 8Fh
		db	0FFh,0F5h,0DDh,0DFh, 06h,0FFh
		db	 04h, 40h, 24h, 2Ah,0AAh,0A8h
		db	 80h, 00h, 00h, 00h,0C0h,0C0h
		db	 03h,0F0h,0CFh, 0Fh,0C3h,0F3h
		db	0FFh,0BEh,0BFh,0E8h, 0Ah,0AFh
		db	0FFh,0ABh,0EEh,0A2h, 00h, 30h
		db	0F0h, 3Fh,0FFh,0FFh, 0Fh, 3Fh
		db	0FFh, 00h, 33h, 3Fh,0F3h,0FFh
		db	0F0h, 03h,0F3h,0FEh,0EBh,0AAh
		db	0CFh,0FFh,0F5h, 7Fh,0FFh,0F5h
		db	 77h,0FFh,0FDh, 4Fh, 08h,0ABh
		db	0AAh, 22h, 88h, 00h, 00h, 0Fh
		db	 00h, 30h, 03h, 00h,0CFh,0CFh
		db	0C3h,0F3h,0FFh,0BAh,0FBh,0E8h
		db	 82h,0AFh,0FFh,0AFh,0EEh, 88h
		db	 00h, 33h,0C3h, 0Fh,0FFh,0FCh
		db	0F0h,0FFh,0FCh,0C0h,0FFh, 3Fh
		db	0FFh,0FFh,0F0h, 03h,0F3h,0FEh
		db	0EAh,0ABh, 83h,0FFh,0D7h,0DFh
		db	 7Fh, 57h,0FFh,0FFh,0FDh, 0Fh
		db	 33h,0ABh,0AAh, 0Ah, 0Ah, 80h
		db	 00h,0ACh, 33h, 30h, 0Ch, 33h
		db	 0Fh, 3Fh,0C3h,0CFh,0FFh,0FEh
		db	0BBh,0FAh, 00h,0AAh,0FEh,0BFh
		db	0BEh,0A0h, 00h,0F3h, 30h,0CFh
		db	0FFh,0C0h,0CFh,0FFh,0FCh,0C3h
		db	0CFh,0CFh,0F3h,0FFh,0F0h, 03h
		db	0CFh,0FEh,0EAh,0BAh, 83h,0FFh
		db	0D7h,0DFh,0FDh,0DDh,0FFh,0FFh
		db	0F5h, 0Ch, 3Ch,0AEh,0AAh, 0Ah
		db	 0Bh,0EAh, 82h,0F0h, 30h,0F0h
		db	 03h, 0Ch, 3Ch,0FFh, 03h,0CFh
		db	0FEh,0FAh,0BFh,0BAh, 00h,0AAh
		db	0FAh,0EFh,0EEh, 88h, 00h,0FFh
		db	0C3h,0CFh,0FFh,0C3h, 3Fh,0FFh
		db	0F3h,0C3h,0CFh,0CFh,0FCh,0FFh
		db	0FCh, 03h,0CFh,0FFh,0EBh,0EBh
		db	0C3h,0FFh,0DFh, 7Dh,0FDh, 77h
		db	0FFh,0FDh, 54h, 00h, 32h,0AEh
		db	 8Ah, 0Ah, 8Bh,0BAh,0EBh,0A3h
		db	 00h,0C0h, 3Ch, 30h,0FFh,0FFh
		db	 0Fh,0CFh,0FEh,0FAh,0EEh,0AEh
		db	 08h, 28h,0BEh,0EFh,0BFh,0A8h
		db	 00h,0FFh, 30h, 0Fh,0FFh, 0Ch
		db	0FFh,0FFh,0F3h,0C3h,0CFh,0CFh
		db	0FCh, 3Fh,0FCh, 03h,0CFh,0FFh
		db	0EEh,0ABh,0CFh,0FFh, 7Dh,0FFh
		db	0F5h,0FFh,0FFh,0F4h, 54h, 30h
		db	0CAh,0AAh, 8Ah, 0Ah, 0Bh,0BCh
		db	0CEh, 00h,0C3h,0CFh,0F3h, 0Ch
		db	0FCh,0FCh, 0Fh, 3Fh,0FEh,0EAh
		db	0EEh,0EEh, 0Ah,0ACh, 2Fh,0ABh
		db	0FFh,0A8h, 03h,0FFh, 33h, 0Fh
		db	0FFh, 0Ch,0FFh,0FFh,0F3h,0CFh
		db	0CFh,0CFh,0FCh, 3Fh,0FCh, 03h
		db	0CFh,0FFh,0BAh,0EBh, 20h,0FFh
		db	0FFh,0FFh,0F5h,0FFh,0FFh,0F4h
		db	 44h,0C2h,0AAh,0AAh, 8Ah, 20h
		db	 03h,0B0h,0F0h,0CCh,0C0h,0C3h
		db	0CCh,0F0h,0F3h,0FCh, 3Fh,0FFh
		db	0FEh,0FAh,0BEh,0EEh, 88h,0A0h
		db	 2Ah,0EFh,0EFh,0A0h, 03h, 3Fh
		db	 0Ch, 3Fh,0FCh, 33h,0FFh,0FFh
		db	0F3h,0C3h,0CFh,0CFh,0FCh, 3Fh
		db	0FCh, 03h, 0Fh,0FFh,0BAh,0EBh
		db	 00h,0FFh,0FDh,0FFh,0F7h,0FFh
		db	0FFh,0D0h,0D0h,0C2h,0AEh,0BAh
		db	 2Ah, 0Ah, 02h, 30h,0E2h, 00h
		db	 33h, 33h,0F0h,0F3h,0FFh,0F0h
		db	 3Fh,0FFh,0FEh,0EAh,0AFh,0EEh
		db	 28h, 30h, 2Ah,0BBh,0EFh,0A2h
		db	 03h, 3Ch, 0Ch,0FFh,0FCh, 0Ch
		db	0FFh,0FFh,0F3h, 33h,0CFh,0CFh
		db	0FCh,0CFh,0FCh, 03h, 33h,0FFh
		db	0BAh,0ABh, 02h,0FFh,0FFh,0FFh
		db	0D7h,0FFh,0FFh,0D3h,0C3h,0CEh
		db	0EAh,0AAh, 2Ah, 20h, 22h, 03h
		db	 38h,0E0h, 08h,0CFh, 30h,0CFh
		db	0F3h,0C0h,0FFh,0FFh,0FBh,0AAh
		db	0BBh,0EAh, 2Bh,0C0h,0AAh,0AFh
		db	0BAh,0A2h, 0Ch,0F0h,0F0h, 3Fh
		db	0FFh, 0Ch,0FFh,0FFh,0CFh, 0Fh
		db	0F3h,0F3h,0FCh, 3Fh,0FCh, 03h
		db	 33h,0FFh,0FBh,0AEh, 08h,0BFh
		db	0FFh,0FFh, 7Fh,0FFh,0FFh, 43h
		db	 0Fh, 3Ah,0EBh,0AAh, 28h,0A0h
		db	 0Ah,0CBh,0E0h,0E0h,0A3h, 3Ch
		db	0C3h, 03h,0FFh,0C3h,0EFh,0FFh
		db	0FBh,0AAh,0AFh,0BAh, 00h, 00h
		db	0BAh,0ABh,0EEh,0BBh, 0Ch,0F0h
		db	 30h,0CFh,0FFh, 3Ch,0FFh,0FFh
		db	 83h, 33h,0F3h,0F3h,0FCh,0FFh
		db	0FCh, 03h, 33h,0FFh,0FAh,0EEh
		db	0C0h,0BFh, 06h,0FFh, 05h, 43h
		db	 30h,0EAh,0ABh,0EAh, 28h, 88h
		db	 2Ah, 8Bh,0A3h,0E2h,0AFh, 3Ch
		db	 0Ch, 0Fh,0FFh,0C3h,0EFh,0FFh
		db	0FBh,0AEh,0AFh,0BAh, 00h, 02h
		db	0BAh,0ABh,0EBh,0A8h, 33h,0FCh
		db	 00h,0CFh,0F0h, 33h,0FFh,0FFh
		db	 83h, 33h,0F3h,0F3h,0FFh, 03h
		db	0FFh, 0Ch,0FFh,0FFh,0BAh,0EEh
		db	 08h, 3Fh, 06h,0FFh, 04h,0FDh
		db	 0Ch, 00h, 2Bh,0AFh,0AAh,0A8h
		db	0A2h, 0Bh, 0Bh,0EFh,0AAh, 83h
		db	0F3h,0C3h, 3Fh,0FFh, 03h,0BEh
		db	0FFh,0AEh,0AEh,0EFh,0BAh, 00h
		db	 3Eh,0EAh,0AAh,0BBh,0E8h, 8Fh
		db	0F3h, 00h, 3Fh,0FCh,0F3h,0FFh
		db	0FAh, 33h, 0Fh,0F3h,0F3h,0FFh
		db	0FCh,0FFh, 0Ch,0F3h,0FFh,0BAh
		db	0AEh, 30h, 0Fh, 06h,0FFh, 04h
		db	0FDh, 00h, 00h,0CBh,0AFh,0A8h
		db	0A0h, 8Ah, 88h, 2Ch,0EEh,0AAh
		db	 0Fh,0C0h,0CFh, 3Fh,0FFh, 0Fh
		db	0ABh,0FFh,0AAh,0AAh,0BFh,0ECh
		db	 00h,0FEh,0EAh,0AAh,0AAh,0B0h
		db	0CFh,0FFh, 03h, 3Fh,0F3h,0F3h
		db	0FFh,0EEh, 0Fh, 33h,0FFh,0FCh
		db	0FFh,0F0h,0FFh, 0Ch,0F3h,0FFh
		db	0FBh,0AFh, 30h, 0Bh, 06h,0FFh
		db	 04h,0F4h, 03h, 00h, 3Bh,0AEh
		db	0A8h, 88h, 82h, 82h,0AFh, 3Eh
		db	0A0h, 0Fh, 03h,0FCh, 3Fh,0FCh
		db	0FFh,0BAh,0FEh,0AAh,0AEh,0BEh
		db	0AAh, 00h,0FBh,0AAh,0ABh,0AAh
		db	0ABh,0FFh,0FFh, 0Ch,0FFh,0F3h
		db	0FCh,0FBh,0B8h,0CFh, 0Fh,0FCh
		db	0FCh,0FFh,0F0h,0FFh, 0Ch,0F3h
		db	0FFh,0BAh,0EBh, 33h, 83h, 06h
		db	0FFh, 04h,0F4h, 00h,0C0h,0CAh
		db	0AAh,0A2h, 8Ah, 82h,0A0h,0AFh
		db	0FAh,0A0h, 0Fh, 33h, 3Ch,0FFh
		db	0FFh,0FEh,0EFh,0FEh,0E9h, 52h
		db	0AAh, 80h, 00h,0FAh,0AAh,0AFh
		db	0E8h,0AAh,0AFh,0FFh, 33h, 0Fh
		db	0FFh,0FCh,0EEh, 03h, 03h, 3Fh
		db	0FCh,0FCh,0FFh,0FFh,0FFh, 0Ch
		db	0F3h,0FFh,0BAh,0AFh, 30h, 23h
		db	 06h,0FFh, 04h,0D0h, 00h, 03h
		db	 3Ah,0AAh,0A2h, 88h, 80h, 8Ah
		db	 3Fh, 2Ah, 80h,0CCh,0FCh,0F0h
		db	0FFh,0FFh,0FEh,0EBh,0FEh,0E5h
		db	 40h, 00h, 3Ch, 03h,0FAh,0EAh
		db	0AFh,0A8h, 8Ah,0ABh,0FFh,0C0h
		db	 03h,0FFh,0FBh,0A8h, 30h, 33h
		db	 0Fh,0FCh,0F8h,0FFh,0FCh,0FFh
		db	 03h,0F3h, 3Fh,0BAh,0BBh,0C8h
		db	0C0h, 06h,0FFh, 04h,0DCh, 03h
		db	 03h, 2Eh,0AAh,0AAh, 2Ah, 00h
		db	 03h, 3Ch,0EAh, 00h, 30h,0FFh
		db	0C3h,0FFh,0FFh,0EAh,0BFh,0FEh
		db	0A4h, 40h, 00h,0FFh, 0Fh,0EAh
		db	0AAh,0AEh,0BAh, 22h,0AAh,0BFh
		db	0FCh,0CFh,0FFh,0EEh,0A0h,0CCh
		db	 33h, 0Fh,0FCh,0F8h,0FFh,0FFh
		db	0FFh, 03h,0CFh,0FFh,0BAh,0BBh
		db	0CAh, 38h, 3Fh,0FFh,0FFh,0FFh
		db	0D3h, 0Ch, 0Ch,0EEh,0AAh,0AAh
		db	0A8h, 03h, 0Fh, 0Ch,0A8h, 00h
		db	0CCh,0FFh, 3Fh,0FFh,0FFh,0EBh
		db	0BFh,0BEh, 94h, 00h, 0Fh,0FCh
		db	0FFh,0EBh,0AAh,0BEh,0EAh, 22h
		db	0AAh,0ABh,0FCh, 33h, 0Fh,0AAh
		db	 0Ch, 03h, 0Fh, 0Fh,0FFh, 38h
		db	0FFh,0FFh,0FFh, 03h,0CCh,0FFh
		db	0BAh,0FBh,0F3h, 38h, 2Fh,0FDh
		db	0FFh,0F7h,0DCh, 0Ch, 03h,0AAh
		db	0AAh,0A8h,0A0h, 30h, 03h, 32h
		db	0A0h, 0Fh,0F3h,0FFh, 0Fh,0FFh
		db	0FFh,0EEh,0BFh,0BAh, 90h, 03h
		db	0FFh,0F0h,0FFh,0ABh,0AAh,0AAh
		db	0AAh, 28h, 2Ah,0AAh,0BBh, 0Ch
		db	0FEh, 0Ch,0C3h, 0Ch,0CFh, 3Fh
		db	0FFh, 3Ah, 3Fh,0FFh,0FCh,0CFh
		db	0C3h,0FFh,0BBh,0BBh,0FCh, 8Eh
		db	 0Ah, 86h, 83h, 01h,0D3h, 33h
		db	 0Fh,0AAh,0AAh, 88h, 8Ah, 80h
		db	 0Ch, 0Ah,0A0h, 3Ch,0CFh,0FCh
		db	 3Fh,0FFh,0FEh,0BEh,0BEh,0BAh
		db	 94h, 0Fh,0FFh,0C3h,0FFh,0AAh
		db	0AAh,0BAh,0EAh, 0Ah, 00h,0AAh
		db	0AEh,0FFh,0E8h,0F0h, 0Fh, 00h
		db	0CCh,0CFh,0FFh, 3Bh, 3Fh,0FFh
		db	0BCh, 0Fh,0C3h,0FFh,0FEh,0FBh
		db	0FCh,0A2h, 03h,0EBh,0A2h, 85h
		db	 8Ch,0F0h,0C2h,0BAh,0EAh, 82h
		db	 28h, 0Ch, 3Ch, 0Ah, 80h,0F0h
		db	 33h,0FCh, 3Fh,0FFh,0FEh,0EAh
		db	0FEh,0EAh, 55h, 0Fh,0FFh, 33h
		db	0FEh,0ABh, 2Ah,0AEh,0AAh, 0Ah
		db	 80h, 00h,0ABh,0BEh, 80h,0F0h
		db	 2Ch,0CCh,0CCh, 3Fh,0FFh, 3Eh
		db	 3Fh,0FFh,0B0h, 33h,0CFh,0FFh
		db	0EEh,0ABh,0FFh, 2Ch, 83h, 00h
		db	 00h, 53h,0CCh,0F0h,0CEh,0EAh
		db	0EAh, 28h,0A0h, 00h
		db	 3Fh, 2Ah, 0Ch

locloop_54:
		retn
			                        ;* No entry point to code
		xor	di,sp
		db	0FFh,0FFh,0FAh,0BBh,0FAh,0EAh
		db	 55h, 3Fh,0FFh, 03h,0FEh,0A8h
		db	 0Ah,0BAh,0A8h, 80h,0AAh, 80h
		db	 2Ah,0A8h, 0Fh, 02h, 8Ch, 03h
		db	 3Ch, 3Fh,0FFh, 3Ah, 3Fh,0FFh
		db	0BCh, 33h,0C3h,0FFh,0EEh,0EBh
		db	0FFh,0CAh,0E0h,0D5h, 95h, 17h
		db	 70h,0F3h,0CEh,0EAh,0AAh, 28h
		db	0A8h, 0Ch,0CFh,0EAh, 33h,0CFh
		db	0CFh,0F0h,0FFh,0FFh,0FAh,0FBh
		db	0FBh,0A9h, 55h, 7Fh,0FCh, 0Fh
		db	0FAh,0A0h, 0Ah,0AAh,0EAh, 22h
		db	 02h,0AAh, 8Ah,0A0h, 03h, 28h
		db	 3Ch,0CFh, 3Ch,0FFh,0FFh, 3Ah
		db	 3Fh,0FFh,0B3h, 33h, 33h,0FFh
		db	0EEh,0EBh,0AFh,0F0h,0B8h, 03h
		db	 5Fh, 17h, 73h,0C3h,0FEh,0AAh
		db	0A8h,0A0h,0A8h,0C0h,0FFh,0A8h
		db	 30h,0FCh, 3Fh, 30h,0FFh,0FFh
		db	0FBh,0FAh,0FBh,0A9h, 05h, 7Fh
		db	0FCh, 0Fh,0FAh,0A0h,0F2h,0ABh
		db	0EAh,0A8h, 20h, 0Ah, 2Ah, 80h
		db	 0Fh,0A0h,0F3h, 03h,0F3h,0FFh
		db	0FFh, 3Eh, 3Fh,0FFh,0ECh, 0Fh
		db	 0Fh,0FFh,0EEh,0EBh,0AAh,0BFh
		db	 0Ah, 20h, 04h,0DFh, 33h,0C7h
		db	0CEh,0AAh,0E8h
loc_55:
		mov	ds:data_10e,al
		db	 3Eh, 8Bh,0C0h,0F0h,0FCh, 00h
		db	0FFh,0FFh,0FBh,0EAh,0FBh,0A5h
		db	 10h,0FFh,0FFh, 3Fh,0FEh, 80h
		db	0F8h,0AAh,0FAh, 0Ah, 00h, 20h
		db	 2Ah, 80h, 32h,0E3h,0E0h,0CFh
		db	0F3h,0FFh,0FFh, 3Bh, 3Fh,0FFh
		db	0BCh, 0Fh, 33h,0FFh,0EEh,0EBh
		db	 2Eh,0AAh,0E0h, 2Ch, 0Bh, 7Ch
		db	0C3h,0C7h,0C2h,0AAh,0B8h, 02h
		db	 0Bh,0CFh,0C2h, 2Fh, 33h,0CFh
		db	0F3h, 03h,0FFh,0FFh,0EFh,0AFh
		db	0FAh,0A4h, 00h,0FFh,0C0h,0FCh
		db	 0Ah, 03h, 38h,0AAh,0AAh,0A2h
		db	 80h, 80h,0AAh, 00h, 0Fh,0A3h
		db	0F3h, 3Fh, 33h,0FFh,0FFh, 3Ah
		db	 3Fh,0FEh,0EFh, 0Fh,0F3h,0FFh
		db	0FAh,0AAh, 8Ah,0AAh,0BAh, 80h
		db	0A8h, 04h,0CFh,0CFh,0C2h,0ABh
		db	0A0h, 2Ah, 0Fh,0FCh,0AAh, 2Ch
		db	0F3h,0CFh,0CCh, 03h,0FFh,0FFh
		db	0EEh,0EBh,0EAh,0A4h, 10h,0FFh
		db	 33h, 03h, 30h, 0Fh, 2Ah, 28h
		db	0FAh,0A8h, 2Ah, 8Ah,0AAh, 00h
		db	0FEh, 83h,0E8h, 3Fh,0F3h,0FFh
		db	0FFh, 3Ah, 3Fh,0FFh,0A3h, 3Fh
		db	 0Fh,0FFh,0FAh,0EBh, 80h,0AAh
		db	0ABh,0FBh, 0Ah, 53h, 3Fh, 1Fh
		db	0C0h,0AAh, 82h, 80h, 3Fh, 3Ah
		db	 02h,0ACh, 3Fh, 3Fh,0CCh, 3Fh
		db	0FFh,0FFh,0AFh,0AAh,0EAh, 94h
		db	 43h,0FFh,0C0h,0F0h,0C0h, 3Ch
		db	0FAh, 23h,0FFh,0AAh, 80h, 0Ah
		db	 82h, 80h, 3Bh, 8Fh,0A3h, 3Fh
		db	0CFh,0FFh,0FFh, 3Ah, 3Fh,0FEh
		db	0E0h,0CFh, 0Fh,0FFh,0EEh,0EAh
		db	0A0h, 2Ah,0AAh,0AEh,0F5h, 0Fh
		db	0FCh, 5Fh,0CCh,0BFh,0AAh, 80h
		db	0FCh,0F8h, 2Bh, 30h,0FFh,0FFh
		db	 30h, 3Fh,0FFh,0FFh,0EEh,0AEh
		db	0EEh, 90h, 43h,0FCh, 0Fh, 33h
		db	 3Fh,0C3h,0A2h,0CFh,0FFh,0FEh
		db	0AAh, 0Ah, 2Ah, 00h,0CEh, 32h
		db	0E0h,0FFh,0CFh,0FFh,0FFh, 2Eh
		db	 3Fh,0FEh,0A0h, 3Fh, 0Fh,0FFh
		db	0EEh,0ABh,0AAh, 02h,0AAh,0AAh
		db	0A4h, 10h,0F9h,0BFh, 3Eh,0BAh
		db	 00h, 3Fh,0EEh, 01h, 60h, 23h
		db	0FFh,0FFh,0F2h,0FEh,0EFh,0FEh
		db	0AEh,0BBh,0EEh, 88h, 33h,0B8h
		db	 22h, 08h, 8Ah, 0Bh,0A2h, 8Bh
		db	0EEh,0FEh,0EAh, 8Ah, 2Ah, 08h
		db	0FEh, 3Fh, 88h,0EEh,0BFh,0FFh
		db	0FFh, 2Ah, 8Fh,0FEh,0EBh, 3Bh
		db	 0Fh,0EEh,0FAh,0EBh,0A8h,0A0h
		db	 02h,0AAh, 91h, 07h,0E2h, 7Bh
		db	 3Ah,0AEh, 00h,0BFh,0E8h, 81h
		db	 63h,0CBh,0FCh,0FFh,0C3h,0BAh
		db	0BFh,0FBh,0AAh,0ABh,0BAh, 80h
		db	 3Eh,0E2h, 80h,0A2h, 3Ah, 23h
		db	0A8h,0A3h,0BBh,0FBh,0AAh,0AAh
		db	0A8h, 02h,0CFh,0BEh, 83h,0FBh
		db	0BEh,0FBh,0FFh, 3Bh, 8Fh,0FAh
		db	0E3h, 3Ah, 2Fh,0BAh,0FEh,0AAh
		db	0AAh, 08h, 00h, 02h, 50h, 5Fh
		db	0A1h,0FEh, 3Eh,0BAh, 33h,0EEh
		db	0A0h, 09h, 88h,0CCh,0E8h,0FFh
		db	 8Eh,0FAh,0BFh,0FBh,0AEh,0BBh
		db	0EEh, 83h, 3Bh,0A2h, 82h, 00h
		db	0E8h, 0Eh,0A8h,0BAh,0BEh,0BEh
		db	0FFh,0AAh,0A8h, 00h,0FBh, 3Bh
		db	0AEh,0EEh,0BBh,0BFh,0FFh, 2Eh
		db	 8Fh,0BBh, 8Ch,0EEh, 8Fh,0BAh
		db	0FAh,0EAh,0AAh,0A0h, 0Ah,0A5h
		db	 01h,0FBh, 97h,0EAh,0BAh,0B8h
		db	 0Ch,0FAh,0A0h, 26h, 83h, 88h
		db	0EAh,0FEh, 03h,0AAh,0BFh,0AEh
		db	0BAh,0ABh,0EEh, 08h,0EBh,0A2h
		db	 8Ah, 03h,0F8h, 02h,0A2h, 2Fh
		db	0BBh,0FAh,0BFh,0FBh,0A8h, 22h
		db	0FAh,0FEh, 8Fh,0FAh,0BFh,0BEh
		db	0FFh, 3Fh, 8Fh,0BBh, 83h,0FEh
		db	 0Bh,0BAh,0EAh,0BEh,0AAh,0AAh
		db	0A0h, 10h, 1Fh,0EAh, 5Fh,0A8h
		db	0EAh,0A8h, 3Bh,0AAh, 83h, 26h
		db	 83h, 82h,0EAh,0FEh, 8Eh,0AEh
		db	0BFh,0AEh,0AAh,0AEh,0FAh, 23h
		db	 3Eh, 8Ah, 88h, 0Fh,0B8h, 8Ch
		db	0A8h, 8Bh,0AAh,0ABh,0EEh,0BEh
		db	 80h, 80h,0BBh,0EEh,0AEh,0EAh
		db	0EBh,0AEh,0EFh, 2Eh,0CEh,0EAh
		db	 83h,0FEh, 0Eh,0BAh,0ABh,0EEh
		db	0AAh,0AAh,0AAh, 41h,0EFh,0A9h
		db	0BAh,0AAh,0EAh,0A8h, 0Eh,0AAh
		db	 80h,0E6h, 2Eh, 83h,0E2h,0EEh
		db	 2Eh,0AAh,0FBh,0BAh,0BAh,0AFh
		db	0BAh, 08h,0FAh, 2Ah,0A8h, 2Ah
		db	0E8h, 0Ah,0A8h,0A0h,0BEh,0AAh
		db	0AAh,0A2h, 20h, 20h,0EEh, 3Eh
		db	 8Fh,0AFh,0ABh,0BAh,0FAh, 2Bh
		db	0CEh,0EAh, 8Eh,0EEh, 3Eh,0AAh
		db	0EAh,0EFh,0AAh,0AAh,0AAh, 1Fh
		db	0BAh,0A6h,0AAh,0A7h,0AAh,0A8h
		db	 8Bh,0AAh, 03h,0BAh, 8Eh, 23h
		db	0AAh,0BAh, 3Ah,0BAh,0EEh,0AAh
		db	0EEh,0AAh,0BAh, 08h,0EAh, 8Ah
		db	 8Ah, 0Ah,0E8h, 0Eh,0A8h, 2Ah
		db	 20h, 0Fh,0BAh, 00h, 00h, 8Bh
		db	0A8h,0FAh,0BBh,0BAh,0AEh,0AAh
		db	0E8h,0ABh, 8Fh,0EAh, 32h,0FAh
		db	 3Bh,0BAh,0AFh,0BAh,0AAh,0AAh
		db	0A9h, 7Fh,0EAh, 06h,0AAh, 04h
		db	0A3h, 3Eh,0A8h, 33h,0EAh, 3Eh
		db	 0Fh,0ABh,0E8h,0EAh,0EBh,0EEh
		db	0ABh,0FAh,0AEh,0E8h, 82h,0BAh
		db	 2Ah,0A8h, 0Ah,0A0h, 0Ah,0AAh
		db	 0Ah,0AAh, 2Ah,0A0h, 00h,0A0h
		db	 3Eh,0A3h,0EAh,0AEh,0EAh,0AAh
		db	0ABh,0B8h,0AEh,0CFh,0EAh, 0Eh
		db	0EEh,0BEh,0BAh,0ABh,0BAh,0AAh
		db	0AAh, 85h,0FBh,0AAh,0EAh,0AAh
		db	0BAh,0AAh, 03h,0EAh,0A8h, 0Eh
		db	0AAh, 3Ah, 3Bh,0AEh,0A0h,0FAh
		db	0EAh,0AAh,0ABh,0EAh,0BAh,0A8h
		db	 23h,0EAh, 2Ah,0A2h, 0Eh,0A8h
		db	 0Eh,0AAh,0A2h,0A0h, 80h, 00h
		db	 20h,0AFh,0EAh,0A3h,0AAh,0BAh
		db	0EAh,0AAh,0AAh,0AAh,0ABh, 8Eh
		db	0AEh, 0Eh,0FAh,0FAh,0AAh,0AEh
		db	0EAh,0AAh,0A9h, 7Eh,0FEh,0AFh
		db	0AAh,0AAh,0BAh,0A8h, 3Eh,0AEh
		db	0A0h, 3Eh,0AAh,0EAh,0EBh,0AEh
		db	0A0h,0EAh,0ABh,0AAh,0ABh,0AAh
		db	0BAh,0E2h, 2Eh,0B8h,0AAh,0A8h
		db	0AEh,0A2h, 3Ah,0AAh,0AAh, 08h
		db	 00h, 20h, 8Fh,0BAh,0AAh, 8Ah
		db	0AAh,0BBh,0AAh,0AAh,0AAh,0A2h
		db	0ABh, 2Fh,0AEh, 0Bh,0AAh,0EAh
		db	0EAh,0AEh,0EAh,0AAh,0A7h,0EBh
		db	0AAh,0BAh,0AAh,0AAh,0BAh,0A8h
		db	 3Ah,0BAh, 80h,0FAh,0A8h,0AAh
		db	0EAh,0AEh, 83h,0FAh,0AAh,0AAh
		db	0AEh,0AAh,0EBh,0A0h,0AEh,0E8h
		db	0AAh,0A2h, 2Ah,0A0h, 3Ah,0AAh
		db	0A0h, 20h, 00h, 8Fh,0AAh,0AAh
		db	0AAh,0AFh,0AAh,0BBh,0AAh,0AAh
		db	0BAh,0AAh,0ABh, 3Bh,0AEh, 3Fh
		db	0BAh,0BAh,0EAh,0BAh,0EAh,0AAh
		db	 7Eh,0AAh,0AAh,0BAh,0AAh,0EAh
		db	0EAh,0AAh,0EBh,0EAh, 8Fh,0BAh
		db	0AAh,0AAh,0ABh,0EEh, 8Ch,0EAh
		db	0AEh, 06h,0AAh, 04h,0A0h,0AFh
		db	0AAh,0AAh,0A8h, 2Ah,0A2h,0AAh
		db	0AAh, 22h,0A3h, 33h,0EAh,0AAh
		db	0AAh,0A8h,0BAh,0AAh,0BBh,0AAh
		db	0AAh,0FAh,0A2h,0AEh,0FBh,0AAh
		db	 0Fh,0EAh,0EAh,0EFh,0EAh,0EAh
		db	0AAh,0EEh,0AAh,0AAh,0EAh,0ABh
		db	0AAh,0EAh,0A8h,0BEh,0AAh, 3Eh
		db	0EAh,0AAh,0AAh,0EBh,0EAh,0A3h
		db	 06h,0AAh, 05h,0EBh, 82h,0BBh
		db	 06h,0AAh, 04h, 8Bh,0AAh,0AAh
		db	0AAh,0A0h,0CAh, 06h,0AAh, 04h
		db	0EAh,0AAh,0AEh,0AAh,0ABh,0BAh
		db	0AAh,0A8h,0FAh,0A8h, 8Bh,0AAh
		db	0EAh,0BAh,0ABh,0BAh,0A7h, 06h
		db	0AAh, 04h,0A7h,0ABh,0AAh,0ABh
		db	0EEh,0AAh, 3Ah,0AAh,0AAh,0ABh
		db	0ABh,0AEh, 8Eh,0EAh,0BAh,0AAh
		db	0AAh,0ABh,0AAh, 80h,0BEh, 06h
		db	0AAh, 04h,0A3h,0AAh,0AAh,0AAh
		db	 8Fh, 06h,0AAh, 04h,0BAh,0AAh
		db	0AAh,0AEh,0AAh,0AEh,0EAh,0A2h
		db	0A8h,0EAh,0E8h, 2Bh,0EAh,0EBh
		db	0AAh,0ABh,0AAh,0BAh, 06h,0AAh
		db	 04h, 9Fh,0AAh,0AAh,0ABh,0BAh
		db	0A8h,0EEh,0AAh,0AAh,0AAh,0AFh
		db	0AAh, 8Fh,0AAh,0BAh,0AAh,0AAh
		db	0ABh,0AEh, 88h,0BAh,0AAh,0AAh
		db	0A2h,0AAh,0ABh,0AAh,0AAh,0AAh
		db	0AEh,0EAh, 06h,0AAh, 08h,0FFh
		db	0AAh, 8Ah,0A2h,0EBh,0A8h, 2Bh
		db	0AAh,0EAh,0AAh,0AEh,0EAh,0EAh
		db	0AAh,0AAh,0AAh,0A5h, 7Eh,0AAh
		db	0AAh,0ABh,0BAh,0A8h,0EAh,0AAh
		db	0AAh,0AAh,0BEh,0AAh,0AFh,0AAh
		db	0EAh,0AAh,0AAh,0AAh,0AEh, 22h
		db	0BAh, 06h,0AAh, 08h, 8Fh, 06h
		db	0AAh, 08h,0ABh,0FAh,0AAh,0AAh
		db	0ABh,0ABh,0A8h, 2Bh,0AAh,0AAh
		db	0AAh,0FFh, 06h,0AAh, 05h, 9Fh
		db	0EAh,0AAh,0AAh,0ABh,0AAh,0A8h
		db	0AAh,0AAh,0AAh,0ABh,0EAh, 06h
		db	0AAh, 07h,0BAh, 0Ah,0EAh, 06h
		db	0AAh, 07h,0A8h, 3Ah, 06h,0AAh
		db	 0Ch, 0Ah,0AEh,0AAh,0AEh,0AAh
		db	0EAh,0ABh,0BAh, 06h,0AAh, 05h
		db	 7Ah,0AAh,0AAh,0AAh,0AEh, 06h
		db	0AAh, 08h,0AEh, 06h,0AAh, 05h
		db	0BAh, 8Ah, 06h,0AAh, 08h, 82h
		db	0EEh, 06h,0AAh, 0Dh,0AEh,0A8h
		db	0AAh,0AAh,0AAh,0AEh, 06h,0AAh
		db	 1Ah, 2Ah, 06h,0AAh, 07h,0A8h
		db	 06h,0AAh, 14h,0AEh,0AAh,0AAh
		db	 7Dh, 17h,0DDh, 47h, 55h, 35h
		db	 54h, 7Dh, 1Fh, 45h,0F5h,0F4h
		db	 7Dh, 51h,0DFh,0D5h, 54h, 1Dh
		db	 54h, 53h,0CFh, 4Fh, 74h,0F7h
		db	 37h,0DFh, 4Fh, 4Fh, 7Dh, 17h
		db	0DDh, 47h, 55h, 35h, 54h, 7Dh
		db	 1Fh, 45h,0F5h,0F4h, 7Dh, 51h
		db	0DFh,0D5h, 54h, 1Dh, 54h, 53h
		db	0CFh, 4Fh, 74h,0F7h, 37h,0DFh
		db	 4Fh, 4Fh, 15h, 4Dh, 55h, 1Dh
		db	 55h, 43h, 41h,0D5h, 45h, 44h
		db	 01h, 51h,0D5h,0D1h,0D5h, 40h
		db	 01h,0F5h
		db	'U', 0Dh, 'EMSU5U54'
		db	 15h, 4Dh, 55h, 1Dh, 55h, 43h
		db	 41h,0D5h, 45h, 44h, 01h, 51h
		db	0D5h,0D1h,0D5h, 40h, 01h,0F5h
		db	'U', 0Dh, 'EMSU5U54'
		db	 05h, 4Dh, 54h, 00h, 05h, 54h
		db	 1Ch, 55h, 45h, 63h, 01h, 54h
		db	 55h, 3Dh,0F4h, 55h, 55h, 35h
		db	 01h, 4Dh, 51h, 55h, 4Dh, 40h
		db	 05h, 10h, 85h, 4Dh, 54h, 00h
		db	 05h, 54h, 1Ch, 55h, 45h, 01h
		db	0F4h, 00h, 01h, 54h, 55h, 3Dh
		db	0F4h, 55h, 55h, 35h, 11h, 4Dh
		db	 51h, 55h, 4Dh, 40h, 05h, 11h
		db	 65h, 05h, 35h, 15h, 67h, 01h
		db	 54h, 55h, 40h, 50h, 00h, 35h
		db	 54h,0D5h, 50h, 63h,0E0h, 62h
		db	0FFh,0A0h, 05h, 35h, 15h, 00h
		db	0BEh,0EBh,0EFh,0B8h, 62h, 01h
		db	 54h, 55h, 40h, 50h,0E8h, 35h
		db	 54h,0D5h, 50h, 3Fh,0A0h, 03h
		db	 66h, 75h, 14h, 69h, 05h, 3Dh
		db	 63h, 54h, 50h, 64h, 57h, 7Dh
		db	 7Fh,0D5h, 5Dh,0F0h, 75h, 14h
		db	 1Fh, 55h,0D5h,0D5h, 55h,0F5h
		db	0FDh,0FCh, 00h, 05h, 3Dh, 07h
		db	 5Dh, 40h, 54h, 50h, 07h,0F5h
		db	0D5h,0FDh, 66h, 15h, 40h, 68h
		db	 6Ch,0AEh,0AAh,0ABh,0AAh,0AAh
		db	0AEh, 15h, 43h,0BAh,0BAh,0ABh
		db	0AAh,0EAh,0BAh,0AAh,0ABh,0FEh
		db	0E0h, 00h,0FAh,0EEh,0AAh, 00h
		db	 0Fh,0BAh,0EAh,0EBh,0AAh
		db	'nnUUWUUU@'
		db	 1Dh, 75h, 55h, 55h, 55h, 55h
		db	 75h, 55h,0D5h,0DDh, 5Dh,0FDh
		db	 55h,0DDh, 55h, 75h, 5Dh, 75h
		db	0D5h, 57h, 55h, 6Eh, 6Eh,0AEh
		db	14 dup (0AAh)
		db	0ABh,0AAh,0AAh,0EAh,0ABh,0AAh
		db	0AAh,0AAh,0AAh,0AAh,0AAh,0AAh
		db	0AAh
		db	'i', 0Ch, 'ocUUUUU'
		db	'UUUU]EUU]uU'
		db	12 dup (55h)
		db	 69h, 30h, 64h, 0Fh, 00h, 0Ch
		db	 65h,0C0h, 65h,0AEh,0AAh,0BAh
		db	0BAh,0AAh,0AAh,0AAh,0BAh,0BAh
		db	 80h, 2Bh,0AAh,0AEh,0AAh,0AFh
		db	0AAh,0AEh,0AAh,0AAh,0ABh,0AAh
		db	0AAh,0EBh,0AAh,0EAh,0EAh,0AAh
		db	0AAh, 69h,0C0h, 62h, 0Ch,0C0h
		db	0F0h, 00h,0FCh, 30h, 63h, 0Fh
		db	 66h, 55h, 55h,0D5h, 55h, 57h
		db	 55h,0D5h, 75h, 55h, 05h, 57h
		db	 55h, 5Dh,0D5h,0F0h, 75h,0CDh
		db	 75h, 75h, 57h, 55h, 5Fh, 1Dh
		db	 55h, 55h, 55h, 75h, 5Dh, 63h
		db	 10h, 64h, 03h, 30h,0F0h, 03h
		db	0CFh, 03h,0CCh, 0Fh,0F3h, 63h
		db	 0Fh, 50h, 00h, 30h, 62h, 03h
		db	 00h,0AAh,0AEh,0AAh, 9Ah,0EAh
		db	0ABh,0AAh,0EAh,0ABh, 3Ah,0F2h
		db	0A8h,0E3h, 2Bh, 0Eh,0ACh,0F3h
		db	0AAh,0AAh,0AAh,0A3h, 58h, 82h
		db	0BAh,0ABh,0AAh,0ABh, 2Ah, 63h
		db	0C0h, 64h, 3Fh, 0Fh, 00h,0FCh
		db	 30h,0CFh, 30h,0FDh,0C1h,0CCh
		db	 00h, 3Dh, 70h, 0Fh, 03h,0C0h
		db	 62h,0F0h, 3Ch, 55h, 55h,0D5h
		db	 55h,0D5h, 55h, 55h, 55h, 73h
		db	 13h, 05h,0CCh, 70h,0D3h, 31h
		db	0C1h,0C5h,0DDh, 5Dh, 4Dh, 70h
		db	 13h, 54h,0C5h, 55h, 55h,0F1h
		db	 7Dh, 33h, 00h, 03h, 40h, 63h
		db	 03h,0F5h,0F7h,0C0h, 03h,0D3h
		db	 3Dh, 3Fh,0FFh,0C4h, 0Fh, 01h
		db	0C0h, 0Fh,0FFh,0CCh, 03h, 30h
		db	 0Ch, 03h,0C0h,0A0h, 2Eh,0A9h
		db	 4Ah,0ABh,0AAh,0AAh,0EBh, 35h
		db	0F7h,0EAh, 0Bh,0D3h,0BDh, 0Fh
		db	0FFh,0C4h, 2Fh, 29h,0C0h, 8Fh
		db	 0Fh,0ECh, 28h, 32h,0ACh,0ABh
		db	0C2h,0FCh, 00h, 03h, 10h, 62h
		db	 0Ch, 3Bh, 5Fh, 5Fh,0FDh,0B0h
		db	0CCh,0DFh, 77h, 5Fh, 7Fh, 31h
		db	 34h, 3Fh,0FDh,0F5h, 30h, 3Dh
		db	 03h,0C0h,0FCh, 3Fh, 9Ch, 55h
		db	 57h, 15h,0D5h, 55h, 5Dh, 7Bh
		db	 5Ch, 5Fh,0F1h,0B1h,0CCh, 1Ch
		db	 77h, 5Fh, 70h, 31h, 75h, 70h
		db	0FDh,0F5h, 31h, 71h, 14h,0C1h
		db	 3Ch, 43h,0FFh,0A4h, 0Dh, 22h
		db	 00h, 45h,0BFh,0D5h, 7Dh,0FDh
		db	 5Fh, 5Fh, 5Fh, 55h,0DDh, 7Dh
		db	 7Fh,0FFh,0D7h,0FFh, 5Fh, 57h
		db	0FDh, 77h, 7Ch, 3Dh, 5Fh, 75h
		db	0FFh,0A4h,0ADh, 2Ah,0AAh,0EFh
		db	0BFh,0D5h, 71h,0FDh, 5Fh, 5Fh
		db	 5Fh, 55h,0DDh, 7Dh, 7Fh,0FFh
		db	0D7h,0FFh, 5Fh, 57h,0CDh, 77h
		db	 7Eh,0B1h
		db	 5Fh, 75h

seg_a		ends



		end	start
