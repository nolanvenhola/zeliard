
PAGE  59,132

;==========================================================================
;
;  OPENING_SCENE - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	660h			;*
data_2e		equ	819h			;*
data_3e		equ	0D20h			;*
data_4e		equ	0EE0h			;*
data_5e		equ	1A40h			;*
data_6e		equ	1D40h			;*
data_7e		equ	3000h			;*
data_8e		equ	3A80h			;*
data_9e		equ	4000h			;*
data_10e	equ	46D3h			;*
data_11e	equ	6000h			;*
data_12e	equ	9C40h			;*
data_13e	equ	0A9C0h			;*
data_14e	equ	0AB40h			;*
data_15e	equ	0D000h			;*
data_137e	equ	4000h			;*
data_138e	equ	64EAh			;*
data_139e	equ	653Dh			;*
data_140e	equ	653Fh			;*
data_141e	equ	6A73h			;*
data_142e	equ	6D56h			;*
data_143e	equ	6D58h			;*
data_144e	equ	6D5Ah			;*
data_145e	equ	6D5Bh			;*
data_146e	equ	6D5Ch			;*
data_147e	equ	6D5Dh			;*
data_148e	equ	75A0h			;*
data_149e	equ	8000h			;*
data_150e	equ	9000h			;*
data_151e	equ	9060h			;*
data_152e	equ	9096h			;*
data_153e	equ	911Eh			;*
data_154e	equ	912Bh			;*
data_155e	equ	947Dh			;*
data_156e	equ	94DDh			;*
data_157e	equ	953Dh			;*
data_158e	equ	9547h			;*
data_159e	equ	9551h			;*
data_160e	equ	955Dh			;*
data_161e	equ	9573h			;*
data_162e	equ	957Eh			;*
data_163e	equ	959Fh			;*
data_164e	equ	95B4h			;*
data_165e	equ	95FEh			;*
data_166e	equ	9609h			;*
data_167e	equ	97C0h			;*
data_168e	equ	0A000h			;*
data_169e	equ	0B000h			;*
data_170e	equ	0B800h			;*
data_171e	equ	0D000h			;*
data_172e	equ	0FF1Ah			;*
data_173e	equ	0FF1Dh			;*
data_174e	equ	0FF24h			;*
data_175e	equ	0FF26h			;*
data_176e	equ	0FF29h			;*
data_177e	equ	0FF2Ch			;*
data_178e	equ	0FF75h			;*
data_179e	equ	0			;*
data_180e	equ	660h			;*
data_181e	equ	0CC0h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_00		proc	far

start:
		sub	word ptr ds:[0],si
		add	ah,[bx+si-6]
		mov	sp,2000h
		sti				; Enable interrupts
		mov	byte ptr cs:data_173e,0
		mov	byte ptr cs:data_176e,0
		push	cs
		pop	ds
		call	word ptr cs:data_51
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	si,data_162e
		mov	di,data_168e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	fill_buffer
		mov	ax,4
		call	word ptr cs:data_92
		xor	bx,bx			; Zero register
		mov	cl,96h
		mov	si,data_138e
		call	word ptr cs:data_49+0Eh	; ('f ')
		mov	bx,70Fh
		mov	cx,4170h
		mov	es,cs:data_177e
		mov	di,data_137e
		call	word ptr cs:data_101
		push	cs
		pop	es
		mov	si,data_157e
		mov	di,data_168e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,data_158e
		mov	di,data_170e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	scene_process_loop
		call	word ptr cs:data_51
		mov	byte ptr cs:data_173e,0
		mov	byte ptr cs:data_176e,0
		mov	ax,1
		call	word ptr cs:data_92
		mov	al,0FFh
		mov	bx,1220h
		mov	cx,2C68h
		mov	es,cs:data_177e
		mov	di,data_137e
		call	word ptr cs:data_89
		call	scene_scan_loop
		mov	ax,2
		call	word ptr cs:data_92
		mov	al,0FFh
		mov	bx,1220h
		mov	cx,2C68h
		mov	es,cs:data_177e
		mov	di,4000h
		call	word ptr cs:data_90
		mov	es,cs:data_177e
		mov	si,data_170e
		mov	di,data_150e
		call	scene_process_loop
		mov	bx,2048h
		mov	cx,1040h
		mov	es,cs:data_177e
		mov	di,data_148e
		call	word ptr cs:data_96
		mov	byte ptr cs:data_178e,4
		mov	si,data_151e
		call	word ptr cs:data_97
		push	cs
		pop	es
		mov	si,data_159e
		mov	di,data_168e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_167e
		call	scene_process_loop
		call	fill_buffer_2
		mov	bx,1220h
		mov	cx,2C68h
		call	word ptr cs:data_91
		mov	ax,3
		call	word ptr cs:data_92
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	al,0FFh
		mov	bx,1720h
		mov	cx,2270h
		mov	di,0
		call	word ptr cs:data_90
		mov	si,data_153e
loc_1:
		mov	byte ptr ds:data_172e,0
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_2			; Jump if zero
		push	si
		dec	al
		mov	bx,1720h
		call	word ptr cs:data_98
		pop	si
		mov	al,14h
		call	scene_func_4
		jmp	short loc_1
loc_2:
		mov	byte ptr ds:data_172e,0
		mov	al,0F0h
		call	scene_func_4
		mov	si,data_152e
		call	scene_func_1
		mov	byte ptr ds:data_172e,0
		mov	al,0F0h
		call	scene_func_4
		mov	al,2
		mov	bx,1720h
		call	word ptr cs:data_98
		mov	byte ptr ds:data_172e,0
		mov	al,0Fh
		call	scene_func_4
		mov	al,3
		mov	bx,1720h
		call	word ptr cs:data_98
		mov	byte ptr ds:data_172e,0
		mov	al,0F0h
		call	scene_func_4
		xor	al,al			; Zero register
		mov	bx,94h
		mov	cx,501Eh
		call	word ptr cs:data_47+80h	; ('es')
		push	cs
		pop	es
		mov	si,9568h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	fill_buffer
		push	cs
		pop	es
		mov	si,data_161e
		mov	di,data_168e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,data_162e
		mov	di,data_169e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,data_160e
		mov	es,cs:data_177e
		mov	di,offset data_87+32h	; (' ')
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	bx,1720h
		mov	cx,2270h
		call	word ptr cs:data_91
		mov	ax,4
		call	word ptr cs:data_92
		mov	byte ptr ds:data_172e,0
		push	ds
		mov	ds,cs:data_177e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		call	word ptr cs:data_100
		mov	al,0F0h
		call	scene_func_4
		xor	al,al			; Zero register
		mov	bx,0B48h
		mov	cx,3180h
		mov	es,cs:data_177e
		mov	di,4000h
		call	word ptr cs:data_90
		mov	byte ptr ds:data_172e,0
		mov	es,cs:data_177e
		mov	si,data_169e
		mov	di,data_137e
		call	fill_buffer
		mov	al,0F0h
		call	scene_func_4
		mov	bx,70Fh
		mov	cx,4170h
		mov	es,cs:data_177e
		mov	di,4000h
		call	word ptr cs:data_101
		mov	byte ptr ds:data_172e,0
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	fill_buffer
		mov	si,data_154e
		call	word ptr cs:data_102
		mov	al,0F0h
		call	scene_func_4
		mov	ax,0C7h
		mov	cx,64h

locloop_3:
		push	cx
		mov	byte ptr ds:data_172e,0
		push	ax
		call	word ptr cs:data_103
		pop	ax
		push	ax
		mov	al,ah
		call	word ptr cs:data_103
		mov	al,50h			; 'P'
		call	scene_func_4
		pop	ax
		add	ah,2
		sub	al,2
		pop	cx
		loop	locloop_3		; Loop if cx > 0

loc_4:
		call	scene_func_5
		test	byte ptr ds:data_175e,0FFh
		jz	loc_4			; Jump if zero
		jmp	loc_17

zr1_00		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_func_1		proc	near
		mov	byte ptr ds:data_140e,8Ah
loc_5:
		mov	byte ptr ds:data_172e,0
loc_6:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_7			; Jump if not zero
		retn
loc_7:
		cmp	al,5
		jae	loc_8			; Jump if above or =
		push	si
		dec	al
		mov	bx,1F70h
		call	word ptr cs:data_99
		pop	si
		jmp	short loc_6
loc_8:
		call	scene_func_2
		mov	al,14h
		call	scene_func_4
		jmp	short loc_5
scene_func_1		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_func_2		proc	near
		cmp	al,0FFh
		jne	loc_11			; Jump if not equal
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_9			; Jump if not zero
		retn
loc_9:
		cmp	al,1
		je	loc_10			; Jump if equal
		retn
loc_10:
		xor	ax,ax			; Zero register
		lodsb				; String [si] to al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	ds:data_139e,ax
		add	byte ptr ds:data_140e,0Ah
		retn
loc_11:
		push	ax
		push	si
		push	ax
		mov	bx,ds:data_139e
		add	bx,2
		mov	cl,ds:data_140e
		add	cl,1
		mov	ah,2
		call	word ptr cs:data_108
		pop	ax
		mov	bx,ds:data_139e
		mov	cl,ds:data_140e
		mov	ah,7
		call	word ptr cs:data_108
		pop	si
		add	word ptr ds:data_139e,8
		pop	ax
		cmp	al,20h			; ' '
		jne	loc_12			; Jump if not equal
		retn
loc_12:
		mov	byte ptr ds:data_178e,3Fh	; '?'
		retn
scene_func_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_scan_loop		proc	near
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:data_93
		mov	si,6FF0h
loc_13:
		call	word ptr cs:data_94
		push	si
		mov	cx,0Ah

locloop_14:
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,0Ah
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:data_95
		mov	al,1Ch
		call	scene_func_4
		pop	cx
		loop	locloop_14		; Loop if cx > 0

		pop	si
		cmp	byte ptr [si-1],0FFh
		jne	loc_13			; Jump if not equal
		mov	cx,78h

locloop_15:
		push	cx
		xor	ax,ax			; Zero register
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:data_95
		mov	al,1Ch
		call	scene_func_4
		pop	cx
		loop	locloop_15		; Loop if cx > 0

		retn
scene_scan_loop		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_func_4		proc	near
loc_16:
		test	byte ptr cs:data_173e,0FFh
		jnz	loc_17			; Jump if not zero
		cmp	byte ptr cs:data_176e,0Dh
		je	loc_17			; Jump if equal
		call	scene_func_5
		cmp	cs:data_172e,al
		jb	loc_16			; Jump if below
		mov	byte ptr cs:data_172e,0
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

scene_func_5:
		push	si
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		pop	si
		retn
loc_17:
		mov	byte ptr ds:data_174e,8
		mov	al,0FFh
		mov	bx,0
		mov	cx,50C8h
		call	word ptr cs:data_91
loc_18:
		test	byte ptr ds:data_175e,0FFh
		jz	loc_18			; Jump if zero
		mov	byte ptr cs:data_173e,0
		mov	byte ptr cs:data_176e,0
		jmp	short $+2		; delay for I/O
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		push	cs
		pop	ds
		call	word ptr cs:data_51
		mov	si,9589h
		mov	es,cs:data_177e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	byte ptr ds:data_172e,0
		push	ds
		mov	ds,cs:data_177e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	byte ptr cs:data_173e,0
		mov	byte ptr cs:data_176e,0
		mov	ax,1
		call	word ptr cs:data_92
		call	scene_func_7
		jmp	short loc_20

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

scene_func_6:
loc_19:
		test	byte ptr cs:data_173e,0FFh
		jnz	loc_20			; Jump if not zero
		cmp	byte ptr cs:data_176e,0Dh
		je	loc_20			; Jump if equal
		call	scene_func_5
		cmp	cs:data_172e,al
		jb	loc_19			; Jump if below
		mov	byte ptr cs:data_172e,0
		retn
loc_20:
		mov	byte ptr ds:data_174e,8
		call	word ptr cs:data_51
loc_21:
		test	byte ptr ds:data_175e,0FFh
		jz	loc_21			; Jump if zero
		mov	byte ptr cs:data_173e,0
		mov	byte ptr cs:data_176e,0
		jmp	loc_25

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

scene_func_7:
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:data_93
		mov	si,742Fh
loc_22:
		call	word ptr cs:data_94
		push	si
		mov	cx,0Ah

locloop_23:
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,0Ah
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:data_95
		mov	al,1Ch
		call	scene_func_6
		pop	cx
		loop	locloop_23		; Loop if cx > 0

		pop	si
		cmp	byte ptr [si-1],0FFh
		jne	loc_22			; Jump if not equal
		mov	cx,78h

locloop_24:
		push	cx
		xor	ax,ax			; Zero register
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:data_95
		mov	al,1Ch
		call	scene_func_6
		pop	cx
		loop	locloop_24		; Loop if cx > 0

		retn
		db	 87h, 20h
		db	'   Copyright (C)1987,1990 GAME A'
		db	'RTS    ', 0Dh, '    Copyright (C'
		db	')1990 Sierra On-Line    '
		db	0FFh, 00h, 00h, 00h
loc_25:
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		mov	byte ptr cs:data_173e,0
		mov	byte ptr cs:data_176e,0
		mov	word ptr cs:data_142e,79C6h
		mov	ax,5
		call	word ptr cs:data_92
		push	cs
		pop	es
		mov	si,9594h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	si,data_168e
		mov	di,0
		call	scene_process_loop
		push	cs
		pop	es
		mov	si,data_163e
		mov	di,data_168e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	scene_process_loop
		mov	bx,0
		mov	cx,5088h
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		call	word ptr cs:data_96
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:data_177e
		mov	di,data_137e
		call	word ptr cs:data_96
		call	scene_multiply
		mov	ax,9
		call	word ptr cs:data_92
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:data_177e
		mov	di,4000h
		call	word ptr cs:data_96
		push	cs
		pop	es
		mov	si,95A9h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	scene_process_loop
		call	scene_multiply
		xor	ax,ax			; Zero register
		call	word ptr cs:data_104
		mov	ax,6
		call	word ptr cs:data_92
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:data_177e
		mov	di,4000h
		call	word ptr cs:data_96
		push	cs
		pop	es
		mov	si,9551h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_167e
		call	scene_process_loop
		call	scene_multiply
		mov	al,4
		call	scene_multiply_2
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		call	scene_process_loop_3
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:data_177e
		mov	di,4000h
		call	word ptr cs:data_96
		call	scene_multiply
		call	scene_multiply
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		mov	bx,1728h
		mov	cx,2230h
		mov	al,7
		call	word ptr cs:data_105
		call	scene_multiply
		call	scene_multiply
		mov	al,2
		call	scene_multiply_2
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		mov	bx,1728h
		mov	cx,2230h
		call	word ptr cs:data_96
		mov	byte ptr cs:data_172e,0
		mov	al,0Fh
		call	scene_func_8
		mov	al,3
		call	scene_multiply_2
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		mov	bx,1728h
		mov	cx,2230h
		call	word ptr cs:data_96
		push	cs
		pop	es
		mov	si,data_164e
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	scene_process_loop
		mov	bx,410h
		mov	cx,4868h
		call	word ptr cs:data_91
		call	scene_multiply
		mov	ax,7
		call	word ptr cs:data_92
		mov	al,0FFh
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:data_177e
		mov	di,4000h
		call	word ptr cs:data_90
		call	scene_multiply
		push	cs
		pop	es
		mov	si,95BEh
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	scene_process_loop
		xor	al,al			; Zero register
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:data_177e
		mov	di,data_137e
		call	word ptr cs:data_90
		call	scene_multiply
		call	scene_multiply
		push	cs
		pop	es
		mov	si,95C8h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	scene_process_loop
		mov	di,data_137e
		mov	bx,1610h
		mov	cx,2468h
		mov	al,5
		call	word ptr cs:data_105
		call	scene_multiply
		xor	ax,ax			; Zero register
		call	word ptr cs:data_104
		call	scene_multiply
		push	cs
		pop	es
		mov	si,95D2h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	scene_process_loop
		mov	al,0FFh
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:data_177e
		mov	di,data_137e
		call	word ptr cs:data_90
		push	cs
		pop	es
		mov	si,data_165e
		mov	di,data_168e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	scene_process_loop
		push	cs
		pop	es
		mov	si,data_166e
		mov	di,data_168e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_149e
		call	scene_process_loop
		call	scene_multiply
		call	scene_multiply
		xor	ax,ax			; Zero register
		call	word ptr cs:data_104
		mov	ax,6
		call	word ptr cs:data_92
		mov	bx,0A15h
		mov	cx,1A5Dh
		call	word ptr cs:data_106
		mov	es,cs:data_177e
		mov	di,4000h
		mov	bx,0B18h
		mov	cx,1858h
		call	word ptr cs:data_96
		mov	bx,2C15h
		mov	cx,1A5Dh
		call	word ptr cs:data_106
		mov	es,cs:data_177e
		mov	di,8000h
		mov	bx,2D18h
		mov	cx,1858h
		call	word ptr cs:data_96
		call	scene_multiply
		call	scene_multiply
		push	cs
		pop	es
		mov	si,9613h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_149e
		call	scene_process_loop
		xor	ax,ax			; Zero register
		call	word ptr cs:data_104
		mov	ax,8
		call	word ptr cs:data_92
		mov	bx,1515h
		mov	cx,315Dh
		call	word ptr cs:data_106
		mov	es,cs:data_177e
		mov	di,data_149e
		mov	bx,1618h
		call	word ptr cs:data_107
		call	scene_multiply
		call	scene_multiply
		mov	bx,1515h
		mov	dx,315Dh
		mov	cx,18h

locloop_26:
		push	cx
		push	dx
		push	bx
		mov	byte ptr cs:data_172e,0
		mov	cx,dx
		call	word ptr cs:data_106
		mov	al,0Fh
		call	scene_func_8
		pop	bx
		pop	dx
		inc	bh
		dec	dh
		pop	cx
		loop	locloop_26		; Loop if cx > 0

		mov	bx,2C15h
		mov	cx,1A5Dh
		call	word ptr cs:data_106
		mov	bx,0A15h
		mov	cx,1A5Dh
		call	word ptr cs:data_106
		mov	es,cs:data_177e
		mov	di,4000h
		mov	bx,0B18h
		mov	cx,1858h
		call	word ptr cs:data_96
		call	scene_multiply
		call	scene_multiply
		mov	bx,2C15h
		mov	dx,1A5Dh
		mov	cx,18h

locloop_27:
		push	cx
		push	dx
		push	bx
		mov	byte ptr cs:data_172e,0
		mov	cx,dx
		call	word ptr cs:data_106
		mov	al,0Fh
		call	scene_func_8
		pop	bx
		pop	dx
		inc	bh
		dec	dh
		pop	cx
		loop	locloop_27		; Loop if cx > 0

		xor	ax,ax			; Zero register
		call	word ptr cs:data_104
		mov	ax,7
		call	word ptr cs:data_92
		push	cs
		pop	es
		mov	si,95DDh
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	scene_process_loop
		mov	es,cs:data_177e
		mov	di,data_137e
		mov	bx,1010h
		mov	cx,3160h
		call	word ptr cs:data_96
		call	scene_multiply
		push	cs
		pop	es
		mov	si,95E8h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,95F3h
		mov	di,0D000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_177e
		mov	si,data_168e
		mov	di,data_137e
		call	scene_process_loop
		mov	bx,0
		mov	cx,50C8h
		call	word ptr cs:data_91
		mov	bx,808h
		mov	es,cs:data_177e
		mov	di,data_9e
		call	scene_process_loop_5
		mov	es,cs:data_177e
		mov	si,data_171e
		mov	di,data_171e
		call	scene_process_loop
		mov	es,cs:data_177e
		mov	di,4000h
		mov	si,data_15e
		call	scene_process_loop_4
		mov	al,0FFh
		mov	bx,808h
		mov	cx,40C0h
		mov	es,cs:data_177e
		mov	di,4000h
		call	word ptr cs:data_90
		mov	byte ptr cs:data_172e,0
		mov	al,0F0h
		call	scene_func_8
		mov	al,0FFh
		mov	bx,808h
		mov	cx,40C0h
		mov	es,cs:data_177e
		mov	di,4000h
		call	word ptr cs:data_89
		mov	ax,1
		call	word ptr cs:data_92
		mov	si,7338h
		call	scene_scan_loop_2
		mov	cx,0Ah

locloop_28:
		push	cx
		mov	al,0C8h
		call	scene_func_8
		pop	cx
		loop	locloop_28		; Loop if cx > 0

		jmp	short loc_30

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

scene_func_8:
loc_29:
		call	scene_func_9
		cmp	cs:data_172e,al
		jb	loc_29			; Jump if below
		mov	byte ptr cs:data_172e,0
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

scene_func_9:
		test	byte ptr cs:data_173e,0FFh
		jnz	loc_30			; Jump if not zero
		cmp	byte ptr cs:data_176e,0Dh
		je	loc_30			; Jump if equal
		push	si
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		pop	si
		retn
loc_30:
		mov	bx,0
		mov	cx,50C8h
		call	word ptr cs:data_91
		mov	byte ptr cs:data_173e,0
		mov	byte ptr cs:data_176e,0
		mov	ax,cs
		mov	es,ax
		mov	ds,ax
		mov	si,961Eh
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	ax,0FFFFh
		jmp	word ptr cs:data_141e
scene_func_4		endp

		db	 00h,0A0h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_multiply		proc	near
		mov	byte ptr cs:data_172e,0
loc_31:
		mov	al,10h
		call	scene_func_8
loc_32:
		push	cs
		pop	ds
		mov	si,ds:data_142e
		lodsb				; String [si] to al
		mov	ds:data_142e,si
		test	al,80h
		jz	loc_33			; Jump if zero
		jmp	loc_37
loc_33:
		cmp	al,20h			; ' '
		je	loc_34			; Jump if equal
		cmp	al,2Eh			; '.'
		je	loc_34			; Jump if equal
		cmp	al,2Ch			; ','
		je	loc_34			; Jump if equal
		cmp	al,22h			; '"'
		je	loc_34			; Jump if equal
		cmp	al,27h			; '''
		je	loc_34			; Jump if equal
		mov	ah,ds:data_147e
		mov	ds:data_178e,ah
loc_34:
		push	ax
		mov	bx,ds:data_143e
		add	bx,4
		mov	al,ds:data_144e
		mov	dl,0Ah
		mul	dl			; ax = reg * al
		add	ax,8Fh
		mov	cx,ax
		pop	ax
		push	bx
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	dl,ds:data_155e[bx]
		mov	dh,bh
		pop	bx
		push	ax
		sub	bx,dx
		push	ax
		push	bx
		push	cx
		inc	bx
		inc	cx
		mov	ah,ds:data_145e
		call	word ptr cs:data_108
		pop	cx
		pop	bx
		pop	ax
		mov	ah,ds:data_146e
		call	word ptr cs:data_108
		pop	ax
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	cl,ds:data_156e[bx]
		mov	ch,bh
		add	ds:data_143e,cx
		cmp	al,20h			; ' '
		je	loc_35			; Jump if equal
		jmp	loc_31
loc_35:
		mov	si,ds:data_142e
		call	scene_check_state
		mov	dx,ds:data_143e
		add	dx,cx
		cmp	dx,138h
		jb	loc_36			; Jump if below
		jmp	loc_54
loc_36:
		jmp	loc_31
loc_37:
		cmp	al,0FFh
		jne	loc_38			; Jump if not equal
		retn
loc_38:
		cmp	al,0FDh
		jne	loc_39			; Jump if not equal
		retn
loc_39:
		mov	ah,al
		and	ah,0F0h
		cmp	ah,80h
		jne	loc_40			; Jump if not equal
		jmp	loc_58
loc_40:
		cmp	ah,90h
		jne	loc_41			; Jump if not equal
		jmp	loc_60
loc_41:
		mov	bx,701h
		cmp	al,0FBh
		jne	loc_42			; Jump if not equal
		jmp	loc_52
loc_42:
		mov	bx,700h
		cmp	al,0FAh
		jne	loc_43			; Jump if not equal
		jmp	loc_52
loc_43:
		mov	bx,602h
		cmp	al,0F9h
		je	loc_52			; Jump if equal
		cmp	al,0F5h
		jne	loc_44			; Jump if not equal
		jmp	loc_56
loc_44:
		cmp	al,0F6h
		jne	loc_45			; Jump if not equal
		jmp	loc_57
loc_45:
		xor	ah,ah			; Zero register
		cmp	al,0F7h
		je	loc_53			; Jump if equal
		inc	ah
		cmp	al,0F3h
		je	loc_53			; Jump if equal
		inc	ah
		cmp	al,0F2h
		je	loc_53			; Jump if equal
		inc	ah
		cmp	al,0F1h
		je	loc_53			; Jump if equal
		cmp	al,0FEh
		je	loc_55			; Jump if equal
		mov	ah,ds:data_147e
		mov	byte ptr ds:data_147e,0
		cmp	al,0F0h
		jne	loc_46			; Jump if not equal
		jmp	loc_31
loc_46:
		mov	byte ptr ds:data_147e,3Dh	; '='
		cmp	al,0EFh
		jne	loc_47			; Jump if not equal
		jmp	loc_31
loc_47:
		mov	byte ptr ds:data_147e,3Eh	; '>'
		cmp	al,0EEh
		jne	loc_48			; Jump if not equal
		jmp	loc_31
loc_48:
		mov	byte ptr ds:data_147e,3Fh	; '?'
		cmp	al,0EDh
		jne	loc_49			; Jump if not equal
		jmp	loc_31
loc_49:
		mov	byte ptr ds:data_147e,40h	; '@'
		cmp	al,0ECh
		jne	loc_50			; Jump if not equal
		jmp	loc_31
loc_50:
		mov	byte ptr ds:data_147e,41h	; 'A'
		cmp	al,0EBh
		jne	loc_51			; Jump if not equal
		jmp	loc_31
loc_51:
		mov	ds:data_147e,ah
		jmp	loc_31
loc_52:
		mov	ds:data_145e,bl
		mov	ds:data_146e,bh
		jmp	loc_31
loc_53:
		mov	word ptr ds:data_143e,0
		mov	ds:data_144e,ah
		jmp	loc_31
loc_54:
		mov	word ptr ds:data_143e,0
		inc	byte ptr ds:data_144e
		jmp	loc_31
loc_55:
		mov	bx,8Fh
		mov	cx,5039h
		xor	al,al			; Zero register
		call	word ptr cs:data_47+80h	; ('es')
		xor	ah,ah			; Zero register
		jmp	short loc_53
loc_56:
		mov	al,0F0h
		call	scene_func_8
		jmp	loc_31
loc_57:
		mov	al,0F0h
		call	scene_func_8
		mov	al,0F0h
		call	scene_func_8
		mov	al,0F0h
		call	scene_func_8
		jmp	loc_31
loc_58:
		mov	es,cs:data_177e
		and	al,0Fh
		cmp	al,6
		jae	loc_59			; Jump if above or =
		mov	ah,15h
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,98C0h
		mov	di,ax
		mov	bx,3350h
		mov	cx,0E20h
		call	word ptr cs:data_96
		jmp	loc_32
loc_59:
		sub	al,6
		mov	ah,21h			; '!'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,0B840h
		mov	di,ax
		mov	bx,3338h
		mov	cx,0B10h
		call	word ptr cs:data_96
		jmp	loc_32
loc_60:
		mov	es,cs:data_177e
		and	al,0Fh
		cmp	al,6
		jae	loc_61			; Jump if above or =
		mov	ah,1Bh
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,58C0h
		mov	di,ax
		mov	bx,1350h
		mov	cx,920h
		call	word ptr cs:data_96
		jmp	loc_32
loc_61:
		sub	al,6
		mov	ah,21h			; '!'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,6D00h
		mov	di,ax
		mov	bx,1238h
		mov	cx,0B10h
		call	word ptr cs:data_96
		jmp	loc_32
scene_multiply		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_check_state		proc	near
		xor	cx,cx			; Zero register
loc_62:
		lodsb				; String [si] to al
		cmp	al,20h			; ' '
		jne	loc_63			; Jump if not equal
		retn
loc_63:
		cmp	al,0FFh
		jne	loc_64			; Jump if not equal
		retn
loc_64:
		cmp	al,0FEh
		jne	loc_65			; Jump if not equal
		retn
loc_65:
		cmp	al,0FDh
		jne	loc_66			; Jump if not equal
		retn
loc_66:
		cmp	al,0F7h
		jne	loc_67			; Jump if not equal
		retn
loc_67:
		cmp	al,0F3h
		jne	loc_68			; Jump if not equal
		retn
loc_68:
		cmp	al,0F2h
		jne	loc_69			; Jump if not equal
		retn
loc_69:
		cmp	al,0F1h
		jne	loc_70			; Jump if not equal
		retn
loc_70:
		or	al,al			; Zero ?
		js	loc_62			; Jump if sign=1
		sub	al,20h			; ' '
		jc	loc_62			; Jump if carry Set
		mov	bl,al
		xor	bh,bh			; Zero register
		add	cl,cs:data_156e[bx]
		adc	ch,bh
		jmp	short loc_62
scene_check_state		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_scan_loop_2		proc	near
		push	si
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:data_93
		pop	si
loc_71:
		call	word ptr cs:data_94
		push	si
		mov	cx,0Ah

locloop_72:
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,0Ah
		mov	bx,14h
		mov	cx,50A0h
		call	word ptr cs:data_95
		mov	al,1Ch
		call	scene_func_8
		pop	cx
		loop	locloop_72		; Loop if cx > 0

		pop	si
		cmp	byte ptr [si-1],0FFh
		jne	loc_71			; Jump if not equal
		mov	cx,0A0h

locloop_73:
		push	cx
		xor	ax,ax			; Zero register
		mov	bx,14h
		mov	cx,50A0h
		call	word ptr cs:data_95
		mov	al,1Ch
		call	scene_func_8
		pop	cx
		loop	locloop_73		; Loop if cx > 0

		retn
scene_scan_loop_2		endp

		db	0C6h, 79h, 00h, 00h, 00h, 00h
		db	 00h, 00h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_process_loop		proc	near
		call	scene_func_14
		jmp	short loc_78

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

scene_func_14:
		push	di
		lodsw				; String [si] to ax
		mov	cx,ax
		push	cx
		mov	bp,si
		add	si,cx

locloop_74:
		push	cx
		xor	al,al			; Zero register
		mov	cx,8

locloop_75:
		rol	byte ptr ds:[bp],1	; Rotate
		jc	loc_76			; Jump if carry Set
		stosb				; Store al to es:[di]
		loop	locloop_75		; Loop if cx > 0

		jmp	short loc_77
loc_76:
		movsb				; Mov [si] to es:[di]
		loop	locloop_75		; Loop if cx > 0

loc_77:
		inc	bp
		pop	cx
		loop	locloop_74		; Loop if cx > 0

		pop	cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		pop	di
		retn
loc_78:
		xor	dh,dh			; Zero register

locloop_79:
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		mov	ah,dh
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		add	ah,ah
		add	ah,ah
		or	ah,dh
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		add	ah,ah
		add	ah,ah
		or	ah,dh
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		add	ah,ah
		add	ah,ah
		or	ah,dh
		mov	al,ah
		stosb				; Store al to es:[di]
		loop	locloop_79		; Loop if cx > 0

		retn
scene_process_loop		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

fill_buffer		proc	near
loc_80:
		test	byte ptr [si],40h	; '@'
		jz	loc_84			; Jump if zero
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cx,ax
		cmp	ax,0FFFFh
		jne	loc_81			; Jump if not equal
		retn
loc_81:
		and	cx,3FFFh
		test	ax,8000h
		jz	loc_83			; Jump if zero
loc_82:
		lodsb				; String [si] to al
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		jmp	short loc_80
loc_83:
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		jmp	short loc_80
loc_84:
		lodsb				; String [si] to al
		mov	cl,al
		and	cx,3Fh
		test	al,80h
		jz	loc_83			; Jump if zero
		jmp	short loc_82
fill_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

fill_buffer_2		proc	near
		push	ds
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,data_179e
		mov	cx,1650h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	ds,cs:data_177e
		mov	di,0
		mov	bx,0
		mov	cx,2230h
		mov	si,data_14e
		call	scene_func_17
		mov	bx,0F30h
		mov	cx,620h
		mov	si,data_13e
		call	scene_func_17
		mov	bx,850h
		mov	cx,1220h
		mov	si,data_12e
		call	scene_func_18
		pop	ds
		retn
fill_buffer_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_func_17		proc	near
		push	di
		add	di,data_4e
		call	copy_buffer
		pop	di
		push	di
		call	copy_buffer
		pop	di
		retn
scene_func_17		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_func_18		proc	near
		push	di
		call	copy_buffer
		pop	di
		push	di
		add	di,data_4e
		call	copy_buffer
		pop	di
		retn
scene_func_18		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

copy_buffer		proc	near
		push	bx
		push	cx
		mov	al,22h			; '"'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		add	di,ax
loc_85:
		push	cx
		push	di
		mov	cl,ch
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		add	di,22h
		pop	cx
		dec	cl
		jnz	loc_85			; Jump if not zero
		pop	cx
		pop	bx
		retn
copy_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_multiply_2		proc	near
		push	ds
		xor	ah,ah			; Zero register
		mov	dx,0CC0h
		mul	dx			; dx:ax = reg * ax
		add	ax,0AB40h
		mov	ds,cs:data_177e
		mov	si,ax
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,data_179e
		call	scene_process_loop_2
		pop	ds
		retn
scene_multiply_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_process_loop_2		proc	near
		mov	cx,30h

locloop_86:
		push	cx
		mov	cx,22h

locloop_87:
		mov	ah,ds:data_1e[si]
		lodsb				; String [si] to al
		mov	bh,al
		not	bh
		and	bh,ah
		xor	ah,bh
		mov	es:[di],al
		mov	es:data_180e[di],bh
		mov	es:data_181e[di],ah
		inc	di
		loop	locloop_87		; Loop if cx > 0

		pop	cx
		loop	locloop_86		; Loop if cx > 0

		retn
scene_process_loop_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_process_loop_3		proc	near
		push	ds
		push	es
		pop	ds
		mov	si,di
		mov	es,cs:data_177e
		mov	di,data_10e
		mov	cx,30h

locloop_88:
		push	cx
		push	di
		mov	cx,11h

locloop_89:
		push	cx
		mov	ax,es:[di]
		mov	bx,es:data_6e[di]
		not	ax
		not	bx
		and	ax,bx
		and	ax,es:data_8e[di]
		mov	dx,ax
		not	dx
		mov	bx,ax
		and	ax,[si]
		and	es:[di],dx
		or	es:[di],ax
		mov	ax,bx
		and	ax,ds:data_180e[si]
		and	es:data_6e[di],dx
		or	es:data_6e[di],ax
		mov	ax,bx
		and	ax,ds:data_181e[si]
		and	es:data_8e[di],dx
		or	es:data_8e[di],ax
		add	di,2
		add	si,2
		pop	cx
		loop	locloop_89		; Loop if cx > 0

		pop	di
		add	di,48h
		pop	cx
		loop	locloop_88		; Loop if cx > 0

		pop	ds
		retn
scene_process_loop_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_process_loop_4		proc	near
		add	di,data_2e
		mov	cx,0A0h

locloop_90:
		push	cx
		push	di
		mov	cx,15h

locloop_91:
		push	cx
		mov	al,es:[si]
		and	al,es:data_3e[si]
		mov	ah,es:data_5e[si]
		not	ah
		and	al,ah
		not	al
		mov	ah,es:[si]
		or	ah,es:data_3e[si]
		or	ah,es:data_5e[si]
		and	es:[si],al
		and	es:data_3e[si],al
		not	ah
		and	es:[di],ah
		and	es:data_7e[di],ah
		and	es:data_11e[di],ah
		mov	al,es:[si]
		or	es:[di],al
		mov	al,es:data_3e[si]
		or	es:data_7e[di],al
		mov	al,es:data_5e[si]
		or	es:data_11e[di],al
		inc	di
		inc	si
		pop	cx
		loop	locloop_91		; Loop if cx > 0

		pop	di
		add	di,40h
		pop	cx
		loop	locloop_90		; Loop if cx > 0

		retn
scene_process_loop_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_process_loop_5		proc	near
		push	bx
		push	es
		push	di
		mov	cx,3000h

locloop_92:
		mov	byte ptr es:data_11e[di],0
		mov	al,es:data_7e[di]
		mov	ah,es:[di]
		not	ah
		and	al,ah
		or	es:[di],al
		or	es:data_11e[di],al
		not	al
		and	es:data_7e[di],al
		mov	al,es:data_7e[di]
		and	al,es:[di]
		or	es:data_11e[di],al
		inc	di
		loop	locloop_92		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,40C0h
		mov	al,0FFh
		jmp	word ptr cs:data_90
scene_process_loop_5		endp

		db	'           Two thousand years, ', 0Dh
		db	'from the dark reaches of another'
		db	' galaxy,', 0Dh, '        a demon'
		db	' with not a shred', 0Dh, '      '
		db	'of compassion for humankind,', 0Dh
		db	'         descended upon earth.', 0Dh
		db	0Dh, '          He defiled the la'
		db	'nd,', 0Dh, '  sending vile creat'
		db	'ures to live in it,', 0Dh, '   a'
		db	'nd thus became ruler of the worl'
		db	'd.', 0Dh, 0Dh, '         The Kin'
		db	'g of Felishika,', 0Dh, '     app'
		db	'alled by what had happened,', 0Dh
		db	'          prayed to the Spirit', 0Dh
		db	'      of the Holy Land of Zeliar'
		db	'd', 0Dh, '    for help in defeat'
		db	'ing this monster.', 0Dh, 0Dh, ' '
		db	'   With the help of the holy cry'
		db	'stals', 0Dh, '       called Tear'
		db	's of Esmesanti,', 0Dh, '    the '
		db	'King managed to wrest power', 0Dh
		db	'    from the fiend and seal him '
		db	'deep', 0Dh, '     within the bow'
		db	'els of the earth.', 0Dh, 0Dh, ' '
		db	'           And once again,', 0Dh
		db	' the light of peace came to shin'
		db	'e upon', 0Dh, '              the'
		db	' earth.', 0Dh, 0Dh, 0Dh, 'Howeve'
		db	'r, it is written in', 0Dh, '    '
		db	'   the Sixth Book of Esmesanti:', 0Dh
		db	'                    The Age of D'
		db	'arkness.', 0Dh
		db	0FFh, 20h
		db	'               At last,         '
		db	'       ', 0Dh, '     the door of'
		db	' destiny was opened.    ', 0Dh, ' '
		db	'       The labyrinths are deep, '
		db	'       ', 0Dh, '          and th'
		db	'e way is long.          ', 0Dh, ' '
		db	'    Will Duke Garland be success'
		db	'ful    ', 0Dh, '   in dethroning'
		db	' the Emperor of Chaos?  ', 0Dh
		db	0FFh, 20h
		db	'         Fantasy Action Game    '
		db	'       ', 0Dh, '               Z'
		db	'ELIARD                  ', 0Dh, 0Dh
		db	'             -- STAFF --        '
		db	'        ', 0Dh, 0Dh, 'Producer -'
		db	'- Japanese Version', 0Dh, '     '
		db	'                 Mitsuhiro Mazda'
		db	'   ', 0Dh, 0Dh, 'Producer -- Eng'
		db	'lish Version', 0Dh, '           '
		db	'             Josh Mandel     ', 0Dh
		db	0Dh, 'Lead Programmer      Tomoyu'
		db	'ki Shimada   ', 0Dh, 0Dh, 'Graph'
		db	'ic Designers     Akihiko Yoshida'
		db	'   ', 0Dh, '                    '
		db	'  Masatoshi Azumi   ', 0Dh, 0Dh, 'E'
		db	'nglish Text Translation by', 0Dh
		db	'                       Marti McK'
		db	'enna    ', 0Dh, 0Dh, 'Music Comp'
		db	'osers  -- MECANO ASSOCIATES --', 0Dh
		db	'                    Fumihito Kas'
		db	'atani   ', 0Dh, '               '
		db	'     Nobuyuki Aoshima    ', 0Dh, 0Dh
		db	'Story Maker           Masaru Tak'
		db	'euchi   ', 0Dh, 0Dh, 'Sound Effe'
		db	'cts by     Tomoyuki Shimada   ', 0Dh
		db	0Dh, 'Advisers               Osam'
		db	'u Harada     ', 0Dh, '          '
		db	'             Hiromi Ohba      ', 0Dh
		db	'                       Greg Miya'
		db	'ji      ', 0Dh, 0Dh, 'System Des'
		db	'igner      Rocky Cave Maker   ', 0Dh
		db	0Dh, 'Special Thanks to', 0Dh, ' '
		db	'                   Toshiyuki Uch'
		db	'ida    ', 0Dh, '                '
		db	'       Yuzo Sunaga      ', 0Dh, ' '
		db	'                    Takeshi Miya'
		db	'ji     ', 0Dh, '                '
		db	'     Naozumi Honma      ', 0Dh, ' '
		db	'                    Toshi Masubu'
		db	'chi    ', 0Dh, '                '
		db	'     Ray E. Nakazato    ', 0Dh, ' '
		db	'                    Hiroyuki Koy'
		db	'ama    ', 0Dh, '                '
		db	'     Satoshi Uesaka     ', 0Dh, ' '
		db	'             Sierra On-Line Japa'
		db	'n, Inc.', 0Dh, '                '
		db	'    Eiji (Ed) Nagano    ', 0Dh, 0Dh
		db	0Dh, 0Dh, '    Copyright (C)1987,'
		db	'1990 GAME ARTS    ', 0Dh, '    C'
		db	'opyright (C)1990 Sierra On-Line '
		db	'   ', 0Dh, '  This edition first'
		db	' published 1987 by  ', 0Dh, '  G'
		db	'AME ARTS Co.,Ltd./ Tomoyuki Shim'
		db	'ada  ', 0Dh
		db	0FFh, 50h,0F0h,0FEh,0F3h,0FAh
		db	'Once, long ago, a terrible storm'
		db	' came to the land of Zeliard. '
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F7h
		db	 44h, 61h, 72h, 6Bh
		db	' clouds filled the sky; lightnin'
		db	'g flashed and thunder crashed. '
		db	0F2h
		db	'Day after day, rain poured from '
		db	'the heavens as if in lament.'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F5h
		db	0F5h,0FEh,0F3h,0F5h
		db	'On the seventh day of rain, a be'
		db	'autiful young girl stood on her '
		db	'balcony watching this dark, sad '
		db	'rain.'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F3h
		db	'The girl was Princess Felicia la'
		db	' Felishika.  She was the only da'
		db	'ughter of King Felishika, and th'
		db	'e light of his life.'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F3h
		db	0F5h
		db	'Her smiles were like sunshine, h'
		db	'er voice as beautiful as that of'
		db	' an angel.  She was adored by th'
		db	'e people of the kingdom.'
		db	0F5h,0F5h,0F5h,0F5h
loc_93:
		jmp	short loc_93
			                        ;* No entry point to code
		cmc				; Complement carry
		db	0F3h,0FBh,0A0h, 22h, 57h
		db	'hat a dreadful storm!  Will it n'
		db	'ever end?"'
		db	0F0h,0F6h,0FEh,0F5h,0F3h,0FAh
		db	'Just as the princess spoke these'
		db	' words, the raindrops turned to '
		db	'grains of sand which covered the'
		db	' ground below her. '
		db	0F5h,0F5h,0F5h,0F5h,0F5h,0FEh
		db	0FDh,0FEh,0F5h,0F3h
		db	'As she watched, a startling tran'
		db	'sformation began to take place.'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F3h
		db	'In an instant, the green hills a'
		db	'nd plains turned a dusty brown. '
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F7h
		db	 54h, 72h
		db	'ees and flowers crumpled and wer'
		db	'e buried. '
		db	0F3h
		db	'Rivers and lakes disappeared ben'
		db	'eath the sand.'
		db	0F1h
		db	'This ever-green land was turning'
		db	' to desert before her very eyes.'
		db	0F5h,0F5h,0F5h,0F5h,0F5h,0F5h
		db	0FEh,0FDh,0F5h,0F3h,0FBh,0EBh
		db	0A2h
		db	'"How can this be?" '
		db	0F0h,0FAh
		db	'she cried, '
		db	0EBh,0FBh
		db	'"Wh'
		db	'at evil p'
		db	'ower could cause such a terrible'
		db	' thing to happen?"'
		db	0F0h,0F6h,0F5h,0F5h,0F5h,0FEh
		db	0F3h,0FAh
		db	'Princess Felicia shiver'
		db	'ed as she felt a dark presence n'
		db	'ear her, '
		db	0FDh
		db	'and suddenly, a terrifying voice'
		db	' bellowed as loud as thunder...'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F7h
		db	0F9h,0EDh
		db	'"I am Jashiin, the Emperor of Ch'
		db	'aos.  The descendants of those w'
		db	'ho imprisoned me under the earth'
		db	' shall know that my wrath has sm'
		db	'oldered for two thousand years!"'
		db	0F0h,0F5h,0F5h,0FDh,0FDh,0FEh
		db	0F7h,0EDh
data_47		db	'"Beautiful Princess Felicia, you'
		db	' will make a lovely and terrifyi'
		db	'ng symbol of my awakening.  Your'
		db	' father will not make the mistak'
		db	'es of his ancestors!"'
		db	0F0h,0F5h,0F5h,0FEh,0FDh,0F3h
		db	0FAh
data_49		db	'As the words of the demon resoun'
		db	'ded over the land, Princess Feli'
		db	'cia was turned to stone.'

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

scene_func_26		proc	near
		std				; Set direction flag

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

scene_func_27:
		cmc				; Complement carry
		cmc				; Complement carry
		db	0FEh,0FDh,0F3h
		db	'The rain of sand continued for 1'
		db	'08 days and transformed the once'
		db	'-fertile land into desert.'
		db	0F5h,0F5h,0FEh,0F3h
		db	'The people of the kingdom wept a'
		db	't the terrible fate of their cou'
		db	'ntry, and of their princess.'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0FDh
		db	0FEh,0F7h,0FAh
		db	'The King wept most of all. '
		db	0F3h,0EEh,0FBh
		db	'"Oh, my beloved Felicia!  I fear'
		db	' the Age of Darkness is upon us.'
		db	'  I am powerless to stop it ... '
		db	'and'
		db	' powerless to help you."'
		db	0F0h,0F5h,0F5h,0F5h,0FEh,0FDh
		db	0F3h,0FAh
		db	'But the tears of th'
		db	'e King and his peo'
		db	'ple soon awakened another power.'
		db	0F5h,0F5h,0FEh,0FDh,0F3h
		db	'As the Ki'
		db	'ng grieved'
		db	', '
		db	'an ap'
		db	'parition appeared before him.'
		db	0F5h,0F5h,0FEh,0ECh,0F7h,0FBh
		db	'"I am the Guardian Spirit of the'
		db	' Holy Land of Zeliard.  The demo'
		db	'n Jashiin has been resurrected, '
		db	'and indeed his evil magic will p'
		db	'lunge this world into the Age of'
		db	' Darkness once again."'
		db	0F5h,0F5h,0F5h,0FEh,0F7h, 22h
		db	'Heed my words, King Felishika: T'
		db	'here is but one way to stop this'
		db	' demon.  A brave warrior must ve'
		db	'nture into the labyrinths and re'
		db	'cover the nine Holy Crystals, th'
		db	'e Tears of Esmesanti."'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F7h
		db	 22h
		db	'Many terrible creatures dwell wi'
		db	'thin the labyrinths, all of them'
		db	' Jashiin', 27h, 's minions.  No '
		db	'mortal man could defeat these de'
		db	'adly beasts and wrest the crysta'
		db	'ls from them."'
		db	0F5h,0F5h,0FEh,0F7h, 22h
		db	'However, there is one with the p'
		db	'ower to oppose Jashiin.'
		db	0F2h
		db	'The man who is destined to fight'
		db	' him will soon arrive in your ki'
		db	'ngdom."'
		db	0F5h,0F5h,0F5h,0FEh,0F3h
		db	'"This man is the only being stro'
		db	'ng enough to banish Jashiin fore'
		db	'ver."'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F7h
		db	 22h
		db	'You must await the arrival of th'
		db	'is brave and noble knight, and t'
		db	'ell him everything.  Only with h'
		db	'is help can you hope to restore '
		db	'this land to its former beauty, '
		db	'and free your daughter from her '
		db	'terrible curse."'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F0h
		db	0FDh,0F3h,0FAh
		db	'Having spoken these words, the S'
		db	'pirit disappeared.'
		db	0F5h,0F5h,0F5h,0FEh,0F7h
		db	'King Felishika could not believe'
		db	' what he had seen.'
		db	0F2h,0FBh
		db	'"Surely my mind is playing trick'
		db	's on me!  I', 27h, 'm afraid I h'
		db	'ave gone mad with grief."'
		db	0FAh,0F5h,0F5h,0F5h,0F5h,0FEh
		db	0F3h
		db	'But the next day, a stranger app'
		db	'eared in the kingdom...'
		db	0F5h,0F5h,0F5h,0FEh,0EFh,0FDh
		db	0F3h,0FBh
		db	'"What a desolate place!  Why has'
		db	' the Spirit led me here?"'
		db	0F5h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

scene_func_29:
		cmc				; Complement carry
		cmc				; Complement carry
		cmc				; Complement carry
		db	0FEh,0F0h,0F3h,0FAh
		db	'Guided by the light of the Spiri'
		db	't, brave Duke Garland had journe'
		db	'yed many days to the land of Zel'
		db	'iard.'
		db	0F5h,0F5h,0F5h,0FEh,0FDh,0F3h
		db	'Entering the castle, he was quic'
		db	'kly escorted to the throne of th'
		db	'e grieving King Felishika.'
		db	0F5h,0F5h,0F5h,0FEh,0EEh,0FDh
		db	0F5h,0FEh,0FBh,0F7h, 22h, 81h
		db	 44h, 75h, 6Bh, 65h, 20h, 80h
		db	 47h, 61h, 72h, 6Ch, 61h, 84h
		db	 6Eh, 83h, 64h, 21h, 20h, 20h
		db	 84h, 85h, 59h, 87h, 6Fh, 88h
		db	 75h, 87h, 20h, 86h, 80h, 6Dh
		db	 75h, 81h, 73h, 83h, 74h, 20h
		db	 82h, 62h, 65h, 20h, 81h, 74h
		db	 68h, 65h, 20h, 80h, 6Dh, 61h
		db	 84h, 6Eh, 20h, 83h, 6Fh, 84h
		db	 66h, 20h, 81h, 64h, 65h, 73h
		db	 82h, 74h, 69h, 6Eh, 79h, 20h
		db	 83h, 6Fh, 84h, 66h, 20h, 83h
		db	 77h, 68h, 6Fh, 84h, 6Dh, 20h
		db	 81h, 74h, 68h, 65h, 20h, 83h
		db	 53h, 82h, 70h, 69h, 72h, 69h
		db	 74h, 20h, 83h, 73h, 70h, 6Fh
		db	 81h, 6Bh, 65h, 2Eh, 20h, 20h
		db	 84h, 97h, 80h, 49h, 98h, 87h
		db	 20h, 81h, 88h, 62h, 87h, 65h
		db	 85h, 86h, 67h, 20h, 83h, 6Fh
		db	 84h, 66h, 20h, 85h, 79h, 6Fh
		db	 75h, 20h, 83h, 74h, 6Fh, 20h
		db	 82h, 64h, 65h, 85h, 73h, 74h
		db	 72h, 6Fh, 79h, 20h, 81h, 74h
		db	 68h, 65h, 20h, 83h, 64h, 65h
		db	 80h, 6Dh, 6Fh, 6Eh, 20h, 84h
		db	 4Ah, 80h, 61h, 73h, 82h, 68h
		db	 69h, 69h, 84h, 6Eh, 20h, 80h
		db	 87h, 77h, 88h, 68h, 87h, 6Fh
		db	 86h, 20h, 85h, 68h, 61h, 73h
		db	 20h, 83h, 63h, 75h, 81h, 72h
		db	 83h, 73h, 65h, 64h, 20h, 80h
		db	 6Dh, 79h, 20h, 85h, 6Bh, 69h
		db	 81h, 6Eh, 67h, 64h, 6Fh, 6Dh
		db	 20h, 85h, 61h, 82h, 6Eh, 64h
		db	 20h, 84h, 74h, 75h, 72h, 81h
		db	 6Eh, 65h, 64h, 20h, 80h, 87h
		db	 6Dh, 82h, 88h, 79h, 87h, 20h
		db	 81h, 86h, 62h, 65h, 83h, 6Ch
		db	 6Fh, 81h, 76h, 65h, 83h, 64h
		db	 20h, 85h, 64h, 61h, 75h, 67h
		db	 68h, 80h, 74h, 65h, 72h, 20h
		db	 85h, 74h, 6Fh, 20h, 83h, 87h
		db	 73h, 88h, 74h, 87h, 6Fh, 84h
		db	 86h, 6Eh, 65h, 2Eh, 22h,0F5h
		db	0F5h,0F5h,0F0h,0FEh,0F7h,0FAh
		db	'Duke Garland k'
		db	'nelt before the King. '
		db	0FBh,0F5h,0F5h,0F5h,0F3h,0EFh
		db	 97h, 22h, 93h, 96h, 59h, 6Fh
		db	 90h, 75h, 72h, 20h, 4Dh, 61h
		db	 91h, 6Ah, 65h, 95h, 73h, 74h
		db	 79h, 2Ch, 20h, 90h, 49h, 20h
		db	 91h, 68h, 61h, 93h, 76h, 65h
		db	 20h, 93h, 66h, 6Fh, 6Ch, 6Ch
		db	 6Fh, 77h, 95h, 65h, 64h, 20h
		db	 91h, 74h, 68h, 65h, 20h, 90h
		db	 6Ch, 69h, 92h, 67h, 68h, 93h
		db	 74h, 20h, 94h, 93h, 6Fh, 66h
		db	 20h, 91h, 74h, 68h, 65h, 20h
		db	 93h, 53h, 92h, 70h, 69h, 91h
		db	 72h, 92h, 69h, 74h, 20h, 95h
		db	 74h, 6Fh, 20h, 92h, 74h, 68h
		db	 92h, 69h, 97h, 73h, 98h, 20h
		db	 97h, 95h, 70h, 96h, 90h, 6Ch
		db	 61h, 93h, 63h, 65h, 2Eh, 22h
		db	 94h,0F5h,0F5h,0F5h,0FEh,0F7h
		db	 22h, 90h, 49h, 20h, 93h, 6Bh
		db	 95h, 6Eh, 6Fh, 77h, 94h, 20h
		db	 93h, 6Eh, 6Fh, 74h, 94h, 20h
		db	 93h, 6Fh, 95h, 66h, 20h, 92h
		db	 74h, 68h, 69h, 95h, 73h, 20h
		db	 91h, 64h, 65h, 93h, 6Dh, 6Fh
		db	 94h, 6Eh, 2Ch, 20h, 93h, 6Eh
		db	 6Fh, 90h, 72h, 20h, 93h, 77h
		db	 68h, 90h, 61h, 93h, 74h, 20h
		db	 90h, 70h, 6Fh, 95h, 77h, 65h
		db	 72h, 93h, 73h, 20h, 92h, 68h
		db	 65h, 20h, 91h, 97h, 6Dh, 98h
		db	 61h, 97h, 92h, 79h, 96h, 20h
		db	 93h, 70h, 6Fh, 91h, 73h, 73h
		db	 65h, 93h, 73h, 73h, 2Ch, 20h
		db	 90h, 62h, 75h, 93h, 74h, 20h
		db	 92h, 69h, 95h, 66h, 20h, 91h
		db	 74h, 68h, 90h, 65h, 72h, 65h
		db	 20h, 92h, 69h, 93h, 73h, 20h
		db	 93h, 6Eh, 6Fh, 94h, 6Eh, 65h
		db	 20h, 91h, 65h, 6Ch, 93h, 73h
		db	 65h, 20h, 93h, 77h, 68h, 6Fh
		db	 20h, 90h, 63h, 61h, 94h, 6Eh
		db	 20h, 91h, 64h, 65h, 92h, 66h
		db	 65h, 93h, 61h, 74h, 20h, 92h
		db	 68h, 69h, 93h, 6Dh, 2Ch, 20h
		db	 99h, 91h, 74h, 68h, 65h, 94h
		db	 6Eh, 20h, 90h, 49h, 20h, 93h
		db	 77h, 92h, 69h, 93h, 6Ch, 6Ch
		db	 20h, 91h, 64h, 65h, 92h, 64h
		db	 69h, 90h, 63h, 61h, 92h, 74h
		db	 65h, 20h, 90h, 6Dh, 92h, 79h
		db	 20h, 90h, 6Ch, 95h, 69h, 94h
		db	 66h, 65h, 20h, 93h, 74h, 6Fh
		db	 20h, 92h, 74h, 68h, 93h, 69h
		db	 73h, 20h, 90h, 74h, 61h, 97h
		db	 93h, 73h, 98h, 6Bh, 97h, 2Eh
		db	 96h, 22h, 94h,0F5h,0F5h,0F5h
		db	0F5h,0EEh,0FEh,0F3h, 22h, 83h
		db	 46h, 6Fh, 80h, 72h, 20h, 81h
		db	 74h, 68h, 65h, 20h, 80h, 66h
		db	 69h, 83h, 72h, 73h, 74h, 20h
		db	 80h, 74h, 82h, 69h, 83h, 6Dh
		db	 65h, 20h, 82h, 73h, 69h, 84h
		db	 6Eh, 83h, 63h, 65h, 20h, 81h
		db	 74h, 68h, 65h, 20h, 80h, 73h
		db	 61h, 84h, 6Eh, 83h, 64h, 85h
		db	 73h, 83h, 74h, 6Fh, 80h, 72h
		db	 84h, 6Dh, 20h, 82h, 62h, 87h
		db	 65h, 88h, 81h, 67h, 87h, 61h
		db	 84h, 86h, 6Eh, 2Ch, 20h, 83h
		db	 79h, 6Fh, 75h, 20h, 81h, 68h
		db	 61h, 83h, 76h, 65h, 20h, 80h
		db	 62h, 83h, 72h, 6Fh, 75h, 84h
		db	 67h, 68h, 83h, 74h, 20h, 68h
		db	 6Fh, 85h, 70h, 65h, 20h, 82h
		db	 69h, 84h, 6Eh, 83h, 74h, 6Fh
		db	 20h, 80h, 6Dh, 82h, 79h, 20h
		db	 80h, 68h, 65h, 61h, 72h, 83h
		db	 74h, 2Ch, 20h, 80h, 44h, 75h
		db	 83h, 6Bh, 65h, 20h, 87h, 80h
		db	 47h, 88h, 61h, 87h, 72h, 86h
		db	 84h, 80h, 6Ch, 61h, 84h, 6Eh
		db	 64h, 2Eh, 20h, 20h, 80h, 4Dh
		db	 61h, 82h, 79h, 20h, 83h, 47h
		db	 6Fh, 64h, 84h, 20h, 83h, 67h
		db	 6Fh, 20h, 82h, 77h, 69h, 83h
		db	 74h, 68h, 20h, 83h, 79h, 85h
		db	 6Fh, 75h, 20h, 83h, 6Fh, 84h
		db	 6Eh, 20h, 83h, 79h, 6Fh, 80h
		db	 75h, 72h, 20h, 83h, 71h, 75h
		db	 81h, 65h, 73h, 83h, 74h, 2Eh
		db	 84h, 22h, 84h,0F5h,0F5h,0FEh
		db	0F0h,0FDh,0FDh,0FAh,0F3h
		db	'Suddenly, the room grew cold.  A'
		db	' black mist swirled around them,'
		db	' '
		db	'then took on a hideous shape.'
		db	0F5h,0F5h,0F5h,0FEh,0EDh,0FDh
		db	0F3h,0F9h
		db	'"Are you the fool who dares to c'
		db	'hallenge me?  Don', 27h, 't be a'
		db	'bsurd!"'
		db	0F5h,0F5h,0FEh,0FDh, 99h,0F5h
		db	0FEh,0F3h,0FBh,0EFh, 9Ah, 22h
		db	 90h, 41h, 94h, 6Eh, 93h, 64h
		db	 20h, 93h
		db	79h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

scene_func_30:
		db	 6Fh, 75h, 20h, 90h, 6Dh, 75h
		db	 93h, 73h, 74h, 20h, 92h, 62h
		db	 65h, 20h, 90h, 74h, 68h, 65h
		db	 20h, 91h, 65h, 92h, 76h, 69h
		db	 93h, 6Ch, 20h, 90h, 4Ah, 61h
		db	 92h, 73h, 68h, 69h, 94h, 69h
		db	 6Eh, 21h, 22h,0F5h,0F5h,0EDh
		db	0FEh,0F3h,0F9h
		db	'"You shall address me as the Emp'
		db	'eror of Chaos... '
		db	9Bh
		db	'THE EMPEROR OF CHAOS!"'
		db	0F5h,0F5h,0F5h,0FEh,0F7h, 22h
		db	'Young fool, I could destroy you '
		db	'now, but I need a little amuseme'
		db	'nt.  I will give you some time t'
		db	'o perform your little quest, but'
		db	' you must promise not to bore me'
		db	'."'
		db	0F5h,0F5h,0F5h,0FEh,0F3h
		db	'"Of course, you have no hope of '
		db	'defeating me."'
		db	0F5h,0F5h,0F5h,0EFh,0FEh,0F3h
		db	0FBh, 22h, 9Ah, 90h, 4Dh, 61h
		db	 72h, 95h, 6Bh, 20h, 90h, 6Dh
		db	 92h, 79h, 20h, 90h, 77h, 6Fh
		db	 72h, 93h, 64h, 73h, 2Ch, 20h
		db	 91h, 65h, 92h, 76h, 69h, 93h
		db	 6Ch, 20h, 90h, 6Fh, 94h, 6Eh
		db	 65h, 3Ah, 20h, 90h, 49h, 20h
		db	 95h, 77h, 92h, 69h, 93h, 6Ch
		db	 6Ch, 20h, 93h, 6Eh, 6Fh, 74h
		db	 94h, 20h, 93h, 73h, 74h, 6Fh
		db	 94h, 70h, 20h, 90h, 75h, 94h
		db	 6Eh, 92h, 74h, 69h, 93h, 6Ch
		db	 20h, 90h, 49h, 20h, 91h, 68h
		db	 61h, 93h, 76h, 65h, 20h, 91h
		db	 72h, 65h, 93h, 63h, 6Ch, 90h
		db	 61h, 69h, 93h, 6Dh, 65h, 64h
		db	 20h, 91h, 74h, 68h, 65h, 20h
		db	 90h, 6Eh, 69h, 94h, 6Eh, 65h
		db	 20h, 93h, 68h, 6Fh, 92h, 6Ch
		db	 79h, 20h, 93h, 63h, 72h, 92h
		db	 79h, 73h, 90h, 74h, 61h, 6Ch
		db	 93h, 73h, 2Ch, 20h, 90h, 61h
		db	 94h, 6Eh, 93h, 64h, 20h, 92h
		db	 73h, 65h, 61h, 93h, 6Ch, 65h
		db	 64h, 20h, 95h, 79h, 6Fh, 75h
		db	 20h, 90h, 75h, 94h, 6Eh, 90h
		db	 64h, 65h, 72h, 20h, 91h, 74h
		db	 68h, 65h, 20h, 90h, 65h, 61h
		db	 72h, 93h, 74h, 68h, 20h, 90h
		db	 6Fh, 94h, 6Eh, 93h, 63h, 65h
		db	 20h, 90h
		db	61h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

scene_func_31:
		xchg	sp,ax
		db	 6Eh, 93h, 64h, 20h, 93h, 66h
		db	 6Fh, 90h, 72h, 20h, 95h, 61h
		db	 93h, 6Ch, 6Ch, 21h, 99h, 94h
		db	 22h,0F5h,0F5h,0F5h,0F5h,0FEh
		db	0F0h,0F5h,0F7h,0FAh
		db	'The demon '
		db	'laug'
		db	'hed, and th'
		db	'e sound was like breaking glass.'
		db	0F2h,0F9h,0EDh
		db	'"My labyrinths are immense, and '
		db	'run deep into the earth.  You', 27h
		db	'll soon lose your way, and then '
		db	'my underlings wil'
		db	'l finish you off."'
		db	0F5h,0F5h,0FEh,0F3h
		db	'"It', 27h, 's been many years si'
		db	'nce a stray mortal has wandered '
		db	'into their realm. They are hungr'
		db	'y '
		db	'for human flesh."'
		db	0F5h,0F5h,0F5h,0F0h,0FDh,0FEh
		db	0F3h,0FAh
		db	'With that, '
data_87		db	'Jashiin disappeared leaving echo'
		db	'es of earsplitting laughter.'
data_93		dw	0F5F5h
data_94		dw	0FEFDh
data_95		dw	0F3EFh
data_96		dw	22FBh
data_97		dw	6F59h
data_98		dw	offset scene_func_27
data_99		dw	6168h
data_100	dw	6576h
data_101	dw	offset scene_func_29
data_102	dw	offset scene_func_26
data_103	dw	6573h
data_104	dw	6E65h
data_105	dw	7420h
data_106	dw	6568h
data_107	dw	6C20h
		db	'ast of m'
data_108	dw	offset scene_func_30
		db	' Jashiin!'
		db	0F2h
		db	'Your reign of evil is near its e'
		db	'nd!"'
		db	0F5h,0F5h,0F5h,0FFh, 58h, 25h
		db	0F0h, 00h, 00h, 03h, 68h, 21h
		db	0FCh,0FCh, 04h, 07h, 70h, 23h
		db	 01h,0FDh, 04h, 07h, 70h, 24h
		db	 04h,0FDh, 04h, 07h, 78h, 25h
		db	 06h,0FEh, 04h, 07h, 78h, 28h
		db	 06h, 02h, 04h, 07h, 70h, 29h
		db	 04h, 03h, 04h, 07h, 70h, 2Ah
		db	 01h, 03h, 04h, 07h, 68h, 2Ch
		db	0FCh, 04h, 04h, 07h,0FFh, 01h
		db	 08h, 01h, 42h, 65h, 03h, 77h
		db	 61h, 04h, 72h, 65h, 2Ch, 20h
		db	 03h, 66h, 6Fh, 04h, 72h, 20h
		db	 04h, 49h, 20h, 01h, 73h, 68h
		db	 61h, 03h, 6Ch, 6Ch, 20h, 77h
		db	 04h, 61h, 6Bh, 03h, 65h,0FFh
		db	 01h, 06h, 03h, 66h, 72h, 6Fh
		db	 03h, 6Dh, 20h, 02h, 6Dh, 01h
		db	 79h, 20h, 03h, 73h, 01h, 6Ch
		db	 65h, 65h, 01h, 70h, 20h, 6Fh
		db	 66h, 20h, 03h, 32h, 2Ch, 04h
		db	 30h, 30h, 30h, 20h, 01h, 79h
		db	 65h, 04h, 61h, 72h, 03h, 73h
		db	0FFh, 01h, 02h, 04h, 61h, 02h
		db	 6Eh, 03h, 64h, 20h, 03h, 6Fh
		db	 02h, 6Eh, 63h, 65h, 20h, 04h
		db	 61h, 67h, 61h, 01h, 69h, 6Eh
		db	 20h, 02h, 72h, 65h, 04h, 69h
		db	 01h, 67h, 6Eh, 20h, 03h, 6Fh
		db	 76h, 04h, 65h, 72h, 20h, 01h
		db	 74h, 68h, 65h, 20h, 04h, 77h
		db	 6Fh, 72h, 03h, 6Ch, 64h, 2Eh
		db	 02h, 00h, 01h, 01h, 01h, 02h
		db	 02h, 01h, 01h, 02h, 02h, 03h
		db	 03h, 05h
		db	7 dup (0)
		db	 01h, 02h, 03h, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 05h, 06h
		db	 07h, 08h, 09h, 0Ah, 0Bh, 0Ch
		db	 0Dh, 0Eh, 0Fh, 10h, 11h, 12h
		db	 13h, 14h, 15h, 16h, 00h, 00h
		db	 00h, 17h, 18h, 19h, 1Ah, 1Bh
		db	 1Ch, 1Dh, 1Eh, 1Fh
		db	' !"#$'
		db	'%&', 27h, '()*+,-.'
		db	 00h, 00h, 2Fh, 30h, 31h, 32h
		db	 33h, 00h, 00h, 34h, 35h, 36h
		db	 37h, 38h, 00h, 39h, 26h, 3Ah
		db	 00h
		db	18 dup (0)
		db	 3Bh, 3Ch, 3Dh, 00h, 00h, 00h
		db	 3Eh, 3Fh, 40h, 41h
		db	30 dup (0)
		db	 42h, 43h, 44h, 45h
		db	30 dup (0)
		db	 46h, 47h, 16h
		db	31 dup (0)
		db	 48h, 49h, 4Ah
		db	97 dup (0)
		db	 4Bh, 4Ch, 4Dh
		db	31 dup (0)
		db	 4Eh, 4Fh, 50h
		db	32 dup (0)
		db	51h
		db	33 dup (0)
		db	 52h, 53h
		db	32 dup (0)
		db	 54h, 55h, 56h
		db	31 dup (0)
		db	 57h, 58h, 59h, 5Ah
		db	30 dup (0)
		db	 5Bh, 5Ch, 5Dh, 5Eh
		db	30 dup (0)
		db	 5Fh, 60h, 61h, 62h
		db	30 dup (0)
		db	 63h, 64h
		db	32 dup (0)
		db	 65h, 66h, 67h, 68h, 69h
		db	29 dup (0)
		db	'jklmnopqrs'
		db	24 dup (0)
		db	'tuvwxyz{|}'
		db	24 dup (0)
		db	 7Eh, 7Fh, 80h, 81h, 82h, 83h
		db	 84h, 85h, 86h, 87h, 88h, 89h
		db	 00h, 00h, 00h, 00h, 0Fh, 8Ah
		db	 8Bh, 8Ch, 00h
		db	13 dup (0)
		db	 2Fh, 8Dh, 8Eh, 8Fh, 90h, 91h
		db	 92h, 93h, 94h, 95h, 96h, 97h
		db	 00h, 00h, 00h, 98h, 99h, 9Ah
		db	 9Bh, 9Ch, 9Dh
		db	14 dup (0)
		db	 9Eh, 9Fh,0A0h,0A1h,0A2h,0A3h
		db	0A4h,0A5h,0A6h,0A7h,0A8h,0A9h
		db	 16h, 00h,0AAh,0ABh,0ACh,0ADh
		db	0AEh,0AFh
		db	14 dup (0)
		db	0B0h,0B1h,0B2h,0B3h,0B4h,0B5h
		db	0B6h,0B7h,0B8h, 26h, 26h,0B9h
		db	0BAh,0BBh,0BCh,0BDh,0BEh,0BFh
		db	0C0h,0C1h
		db	13 dup (0)
		db	2, 2, 3, 1, 0, 0
		db	2, 2, 3, 1, 1, 1
		db	2, 2, 0, 1, 2, 1
		db	7 dup (1)
		db	3, 2, 1, 1, 2, 1
		db	9 dup (0)
		db	2, 0
		db	9 dup (0)
		db	1, 0, 0, 0, 0, 0
		db	1, 2, 2, 2, 1, 1
		db	1, 0, 0, 1, 0, 1
		db	1, 0, 0, 2, 1, 0
		db	2, 0, 1, 1, 0, 0
		db	0, 1, 1, 0, 0, 0
		db	1, 1, 1, 2, 0, 3
		db	1, 0, 5, 4, 4, 4
		db	6, 8, 5, 3, 4, 4
		db	6, 6, 6, 5, 6, 8
		db	7, 5, 7, 7, 7, 7
		db	7, 7, 7, 7, 3, 4
		db	6, 6, 6, 7
		db	9 dup (8)
		db	5, 8, 8
		db	8 dup (8)
		db	 07h, 08h, 08h, 08h, 08h, 08h
		db	 07h, 05h, 03h, 05h, 06h, 07h
		db	 07h, 08h, 08h, 07h, 08h, 07h
		db	 07h, 08h, 08h, 05h, 06h, 08h
		db	 05h, 08h, 07h, 07h, 08h, 08h
		db	 08h, 07h, 06h, 08h, 08h, 08h
		db	 07h, 07h, 07h, 04h, 08h, 04h
		db	 07h, 08h, 00h, 17h, 6Eh, 65h
		db	 63h, 2Eh, 67h, 72h, 70h, 00h
		db	 00h, 12h, 68h, 6Fh, 75h, 2Eh
		db	 67h, 72h, 70h, 00h, 00h, 0Fh
		db	'dmaou.grp'
		db	0, 0
		db	'(zopn.msd'
		db	 00h, 00h, 1Eh
		db	'ttl1.grp'
		db	 00h, 00h, 1Fh
		db	'ttl2.grp'
		db	0, 0
		db	' ttl3.grp'
		db	0, 0
		db	27h, 'zend.msd'
		db	0, 0
		db	'!waku.grp'
		db	 00h, 00h, 0Eh, 61h, 6Dh, 65h
		db	 2Eh, 67h, 72h, 70h, 00h, 00h
		db	 10h
		db	'hime.grp'
		db	 00h, 00h, 13h, 69h, 73h, 69h
		db	 2Eh, 67h, 72h, 70h, 00h, 00h
		db	 1Ah, 6Fh, 75h, 69h, 2Eh, 67h
		db	 72h, 70h, 00h, 00h, 1Ch, 73h
		db	 65h, 69h, 2Eh, 67h, 72h, 70h
		db	 00h, 00h
		db	'"yuu1.grp'
		db	0, 0
		db	'#yuu2.grp'
		db	0, 0
		db	'$'
		db	'yuu3.grp'
		db	0, 0
		db	'%yuu4.grp'
		db	0, 0
		db	'&yuup.grp'
		db	0, 0
		db	1Bh, 'oup.grp'
		db	 00h, 00h, 14h
		db	'maop.grp'
		db	0, 0, 0
		db	'game.bin'
		db	0
scene_func_26		endp


seg_a		ends



		end	start
