
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_207MOLEB                                €€
;€€					                                 €€
;€€      Created:   29-Mar-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'M4'                      ; Target assembler: MASM-4.0

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	499h			;*
data_82e	equ	2A08h			;*
data_83e	equ	2A41h			;*
data_84e	equ	2E02h			;*
data_85e	equ	36EAh			;*
data_86e	equ	3A41h			;*
data_87e	equ	3AA8h			;*
data_88e	equ	4102h			;*
data_89e	equ	4108h			;*
data_90e	equ	410Ah			;*
data_91e	equ	4111h			;*
data_92e	equ	4113h			;*
data_93e	equ	4120h			;*
data_94e	equ	4128h			;*
data_95e	equ	412Eh			;*
data_96e	equ	4180h			;*
data_97e	equ	4188h			;*
data_98e	equ	41A0h			;*
data_99e	equ	41A2h			;*
data_100e	equ	41A8h			;*
data_101e	equ	41CBh			;*
data_102e	equ	41EBh			;*
data_103e	equ	4202h			;*
data_104e	equ	420Ah			;*
data_105e	equ	4220h			;*
data_106e	equ	423Ah			;*
data_107e	equ	4280h			;*
data_108e	equ	428Ah			;*
data_109e	equ	42A0h			;*
data_110e	equ	42A3h			;*
data_111e	equ	42E2h			;*
data_112e	equ	4308h			;*
data_113e	equ	4320h			;*
data_114e	equ	4380h			;*
data_115e	equ	4382h			;*
data_116e	equ	4688h			;*
data_117e	equ	4880h			;*
data_118e	equ	4B01h			;*
data_119e	equ	6000h			;*
data_120e	equ	8002h			;*
data_121e	equ	800Ah			;*
data_122e	equ	800Bh			;*
data_123e	equ	8022h			;*
data_124e	equ	802Eh			;*
data_125e	equ	803Ah			;*
data_126e	equ	8041h			;*
data_127e	equ	8043h			;*
data_129e	equ	8045h			;*
data_130e	equ	8080h			;*
data_131e	equ	808Ah			;*
data_132e	equ	8228h			;*
data_133e	equ	822Ah			;*
data_134e	equ	8242h			;*
data_135e	equ	8820h			;*
data_136e	equ	8841h			;*
data_137e	equ	8888h			;*
data_138e	equ	88FBh			;*
data_139e	equ	8A02h			;*
data_140e	equ	8A41h			;*
data_141e	equ	8EFAh			;*
data_142e	equ	99A2h			;*
data_143e	equ	0A000h			;*
data_144e	equ	0A02Ah			;*
data_145e	equ	0A041h			;*
data_146e	equ	0A042h			;*
data_147e	equ	0A044h			;*
data_148e	equ	0A0A0h			;*
data_149e	equ	0A202h			;*
data_150e	equ	0A211h			;*
data_151e	equ	0A214h			;*
data_152e	equ	0A241h			;*
data_153e	equ	0A2A0h			;*
data_154e	equ	0A2FAh			;*
data_155e	equ	0A3ABh			;*
data_156e	equ	0A80Ah			;*
data_157e	equ	0A811h			;*
data_158e	equ	0A812h			;*
data_159e	equ	0A82Bh			;*
data_160e	equ	0AB83h			;*
data_161e	equ	0AFBAh			;*
data_162e	equ	0BAA0h			;*
data_163e	equ	0BABBh			;*
data_164e	equ	0C050h			;*
data_165e	equ	0C0ECh			;*
data_166e	equ	0CA22h			;*
data_167e	equ	0CA91h			;*
data_168e	equ	0CB22h			;*
data_169e	equ	0E241h			;*
data_170e	equ	0E2A0h			;*
data_171e	equ	0E808h			;*
data_172e	equ	0E8BAh			;*
data_173e	equ	0E8EBh			;*
data_174e	equ	0EA41h			;*
data_175e	equ	0EA8Eh			;*
data_176e	equ	0FA91h			;*
data_177e	equ	0FBF0h			;*
data_178e	equ	3BF0h
data_179e	equ	6778h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_207MOLEB	proc	far

start:
		sub	es:[bx+si],ax
		add	ds:data_142e,ch
		add	al,8Ch
		db	0C8h, 8Eh,0D8h, 8Eh,0C0h,0FCh
		db	0E8h, 95h, 00h,0BEh,0AEh, 04h
		db	0BFh, 26h, 29h,0E8h, 3Dh, 04h
		db	0BEh, 3Dh, 07h,0BFh, 86h, 32h
		db	0E8h, 34h, 04h,0BEh, 26h, 29h
		db	0BDh, 60h, 09h,0BBh, 00h, 0Ch
		db	0B9h, 0Dh, 38h,0E8h,0A1h, 00h
		db	0C6h, 06h, 97h, 04h, 10h,0BEh
		db	0CDh, 08h,0BFh, 26h, 29h,0E8h
		db	 17h, 04h,0BEh,0DBh, 10h,0BFh
		db	 86h, 32h,0E8h, 0Eh, 04h,0BEh
		db	 26h, 29h,0BDh, 60h, 09h,0BBh
		db	 00h, 00h,0B9h,0C8h, 0Ch,0E8h
		db	 7Bh, 00h,0BEh, 61h, 18h,0BFh
		db	 26h, 29h,0E8h,0F6h, 03h,0BEh
		db	 88h, 20h,0BFh, 86h, 32h,0E8h
		db	0EDh, 03h,0BEh, 26h, 29h,0BDh
		db	 60h, 09h,0BBh, 00h, 44h,0B9h
		db	0C8h, 0Ch,0E8h, 5Ah, 00h,0C6h
		db	 06h, 98h, 04h,0FFh,0C6h, 06h
		db	 97h, 04h, 50h,0BEh, 99h, 27h
		db	0BFh, 26h, 29h,0E8h,0CBh, 03h
		db	0BFh, 86h, 32h,0B9h,0B0h, 04h
		db	 33h,0C0h,0F3h,0ABh,0BDh, 60h
		db	 09h,0BBh, 9Eh, 0Ch,0B9h, 2Ah
		db	 38h,0E8h, 31h, 00h,0E8h,0ACh
		db	 02h,0CBh,0F6h, 06h, 99h, 04h
		db	0FFh, 74h, 01h,0C3h
loc_6:
		mov	dx,3CCh
		xor	al,al			; Zero register
		out	dx,al			; port 3CCh, EGA graphics 1 pos
		inc	dx
		inc	al
		out	dx,al			; port 3CDh ??I/O Non-standard
		mov	dx,3CEh
		mov	ax,0
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 0, set/reset bit
		inc	al
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 1, enable set/reset
		mov	ax,0F02h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 2, color compare bits
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

_207MOLEB	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		xor	ax,ax			; Zero register
		mov	al,ds:data_1e
		add	ax,ax
		add	ax,0DEh
		mov	di,ax
		jmp	word ptr [di]		;*
sub_1		endp

;*		jmp	far ptr loc_61		;*
		db	0EAh
		dw	4000h, 4001h		;  Fixup - byte match
			                        ;* No entry point to code
		add	ss:data_118e[bp+si],di
		add	bh,ss:data_20[bp]
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	bx,cx
loc_7:
		push	di
		push	cx
loc_8:
		mov	ah,ds:[bp+si]
		lodsb				; String [si] to al
		mov	cl,ah
		or	cl,al
		xor	cl,al
		mov	ch,cl
		or	al,ch
		not	ch
		and	ah,ch
		mov	ch,al
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	es:[di],ch
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	es:[di],ah
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	es:[di],cl
		inc	di
		dec	bh
		jnz	loc_8			; Jump if not zero
		pop	cx
		pop	di
		add	di,50h
		mov	bh,ch
		dec	bl
		jnz	loc_7			; Jump if not zero
		pop	es
		retn
			                        ;* No entry point to code
		push	es
		mov	ax,50h
		shr	bl,1			; Shift w/zeros fill
		sbb	dx,dx
		mul	bl			; ax = reg * al
		and	dx,2000h
		add	ax,dx
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bx,cx
loc_9:
		push	di
		push	cx
loc_10:
		push	bx
		mov	ah,ds:[bp+si]
		lodsb				; String [si] to al
		xor	dl,dl			; Zero register
		mov	cx,4

locloop_11:
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
		or	dl,byte ptr ds:[1AAh][bx]
		loop	locloop_11		; Loop if cx > 0

		mov	al,dl
		stosb				; Store al to es:[di]
		pop	bx
		dec	bh
		jnz	loc_10			; Jump if not zero
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_12			; Jump if below
		add	di,data_164e
loc_12:
		mov	bh,ch
		dec	bl
		jnz	loc_9			; Jump if not zero
		pop	es
		retn
		db	 00h, 03h, 02h, 01h, 01h, 03h
		db	 02h, 01h, 00h, 03h, 02h, 01h
		db	 01h, 03h, 02h, 01h, 06h, 33h
		db	0C0h, 8Ah,0C3h, 05h, 1Ch, 00h
		db	0B2h, 03h,0F6h,0F2h, 8Ah,0F4h
		db	0D0h,0CEh,0D0h,0CEh,0D0h,0CEh
		db	0B4h, 5Ah,0F6h,0E4h, 81h,0E2h
		db	 00h, 60h, 03h,0C2h, 80h,0C7h
		db	 05h, 8Ah,0DFh, 32h,0FFh, 03h
		db	0C3h, 8Bh,0F8h,0B8h, 00h,0B0h
		db	 8Eh,0C0h, 8Bh,0D9h
loc_13:
		push	di
		push	cx
loc_14:
		push	bx
		mov	ah,ds:[bp+si]
		lodsb				; String [si] to al
		xor	dl,dl			; Zero register
		mov	cx,4

locloop_15:
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
		or	dl,byte ptr ds:[1AAh][bx]
		loop	locloop_15		; Loop if cx > 0

		mov	al,dl
		stosb				; Store al to es:[di]
		pop	bx
		dec	bh
		jnz	loc_14			; Jump if not zero
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,data_119e
		jb	loc_16			; Jump if below
		push	ds
		push	si
		push	cx
		push	di
		push	es
		pop	ds
		mov	si,di
		sub	si,2000h
		mov	cl,ch
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	cx
		pop	si
		pop	ds
		add	di,0A05Ah
loc_16:
		mov	bh,ch
		dec	bl
		jnz	loc_13			; Jump if not zero
		pop	es
		retn
			                        ;* No entry point to code
		push	es
		xor	dx,dx			; Zero register
		mov	dl,bh
		mov	bh,dh
		push	dx
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	dx
		add	dx,dx
		add	dx,dx
		add	ax,dx
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	bx,cx
loc_17:
		push	di
		push	cx
loc_18:
		push	bx
		mov	dh,ds:[bp+si]
		mov	dl,[si]
		call	sub_2
		stosb				; Store al to es:[di]
		call	sub_2
		stosb				; Store al to es:[di]
		call	sub_2
		stosb				; Store al to es:[di]
		call	sub_2
		stosb				; Store al to es:[di]
		inc	si
		pop	bx
		dec	bh
		jnz	loc_18			; Jump if not zero
		pop	cx
		pop	di
		add	di,140h
		mov	bh,ch
		dec	bl
		jnz	loc_17			; Jump if not zero
		pop	es
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
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
		mov	al,byte ptr ds:[2AEh][bx]
		retn
sub_2		endp

		db	 00h, 01h, 05h, 03h, 08h, 09h
		db	 0Dh, 0Bh, 28h, 29h, 2Dh, 2Bh
		db	 18h, 19h, 1Dh, 1Bh, 06h, 8Ah
		db	0F3h,0D0h,0CEh,0D0h,0CEh,0D0h
		db	0CEh, 81h,0E2h, 00h, 60h,0D0h
		db	0EBh,0D0h,0EBh,0B8h,0A0h, 00h
		db	0F6h,0E3h, 03h,0C2h, 8Ah,0DFh
		db	 32h,0FFh, 03h,0DBh, 03h,0C3h
		db	 8Bh,0F8h,0B8h, 00h,0B8h, 8Eh
		db	0C0h, 8Bh,0D9h
loc_19:
		push	di
		push	cx
loc_20:
		push	bx
		mov	dh,ds:[bp+si]
		mov	dl,[si]
		call	sub_3
		stosb				; Store al to es:[di]
		call	sub_3
		stosb				; Store al to es:[di]
		inc	si
		pop	bx
		dec	bh
		jnz	loc_20			; Jump if not zero
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_21			; Jump if below
		add	di,80A0h
loc_21:
		mov	bh,ch
		dec	bl
		jnz	loc_19			; Jump if not zero
		pop	es
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		xor	al,al			; Zero register
		mov	cx,2

locloop_22:
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
		or	al,byte ptr ds:[33Eh][bx]
		loop	locloop_22		; Loop if cx > 0

		retn
sub_3		endp

		db	 00h, 07h, 01h, 02h, 07h, 0Fh
		db	 03h, 0Ah, 01h, 03h, 09h, 0Bh
		db	 02h, 0Ah, 0Bh, 0Eh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		xor	ax,ax			; Zero register
		mov	al,ds:data_1e
		add	ax,ax
		add	ax,35Ch
		mov	di,ax
		jmp	word ptr [di]		;*
sub_4		endp

		db	 68h, 03h, 8Bh, 03h, 8Bh, 03h
		db	 8Bh, 03h, 8Ch, 03h,0CFh, 03h
		db	0B8h, 00h,0A0h, 8Eh,0C0h,0BAh
		db	0C4h, 03h,0B8h, 02h, 04h,0EFh
		db	0BEh, 9Ah, 04h,0BFh,0B2h, 0Eh
		db	0E8h, 03h
data_15		dw	0BF00h			; Data table (indexed access)
		db	0FCh, 0Eh,0B9h, 05h, 00h

locloop_23:
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,4Eh
		loop	locloop_23		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		retn
			                        ;* No entry point to code
		mov	ax,0A000h
		mov	es,ax
		mov	si,49Ah
		mov	di,3AC8h
		call	sub_5
		mov	di,data_178e

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		mov	cx,5

locloop_24:
		push	cx
		push	di
		lodsb				; String [si] to al
		call	sub_6
		lodsb				; String [si] to al
		call	sub_6
		pop	di
		add	di,140h
		pop	cx
		loop	locloop_24		; Loop if cx > 0

		retn
sub_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		mov	cx,4

locloop_25:
		xor	ah,ah			; Zero register
		add	al,al
		adc	ah,ah
		add	ah,ah
		add	ah,ah
		add	al,al
		adc	ah,ah
		add	ah,ah
		add	ah,ah
		or	es:[di],ah
		inc	di
		loop	locloop_25		; Loop if cx > 0

		retn
sub_6		endp

			                        ;* No entry point to code
		mov	ax,0B800h
		mov	es,ax
		mov	di,66E4h
		mov	dh,0FFh
		call	sub_7
		mov	di,data_179e
		xor	dh,dh			; Zero register

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		mov	cx,5

locloop_26:
		push	cx
		push	di
		xor	dl,dl			; Zero register
		mov	cx,4

locloop_27:
		mov	al,es:[di]
		call	sub_8
		stosb				; Store al to es:[di]
		loop	locloop_27		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_28			; Jump if below
		add	di,80A0h
loc_28:
		pop	cx
		loop	locloop_26		; Loop if cx > 0

		retn
sub_7		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		test	dl,0FFh
		jz	loc_29			; Jump if zero
		retn
loc_29:
		mov	ah,al
		mov	bl,ah
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		mov	si,bx
		mov	al,byte ptr cs:[444h][bx]
		add	al,al
		add	al,al
		add	al,al
		add	al,al
		mov	bl,ah
		and	bl,0Fh
		or	al,byte ptr cs:[444h][bx]
		or	si,si			; Zero ?
		jz	loc_30			; Jump if zero
		retn
loc_30:
		test	dh,0FFh
		jnz	loc_31			; Jump if not zero
		retn
loc_31:
		mov	al,ah
		mov	dl,0FFh
		retn
sub_8		endp

		db	 00h, 04h, 05h, 05h, 04h, 05h
		db	 05h, 07h, 08h, 0Ch, 0Dh, 0Dh
		db	 0Ch, 0Dh, 0Dh, 0Fh
loc_32:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_33			; Jump if not zero
		retn
loc_33:
		mov	ah,al
		and	ah,0F0h
		cmp	ah,byte ptr ds:[497h]
		jne	loc_34			; Jump if not equal
		and	al,0Fh
		mov	ah,al
		mov	al,0AAh
		jmp	short loc_37
loc_34:
		cmp	ah,40h			; '@'
		jne	loc_35			; Jump if not equal
		and	al,0Fh
		mov	ah,al
		xor	al,al			; Zero register
		jmp	short loc_37
loc_35:
		test	byte ptr ds:[498h],0FFh
		jz	loc_36			; Jump if zero
		cmp	ah,0D0h
		jne	loc_36			; Jump if not equal
		and	al,0Fh
		mov	ah,al
		mov	al,0FFh
		jmp	short loc_37
loc_36:
		mov	ah,1
loc_37:
		stosb				; Store al to es:[di]
		dec	ah
		jnz	loc_37			; Jump if not zero
		jmp	short loc_32
			                        ;* No entry point to code
		nop
		add	[bx+si],al
		and	[bx+si],al
		adc	al,[bx+si]
		stosw				; Store ax to es:[di]
		add	ds:data_143e[bx],ch
		add	[bx+si],al
		sub	[bx+si],al
		sub	al,[bp+si]
		stosw				; Store ax to es:[di]
		add	bh,data_41[bx]
		cmp	dl,byte ptr ss:[0FCFFh][bp+di]
		sub	dl,byte ptr ss:[0FCFFh][bp+di]
		sub	dl,byte ptr ss:[0FCFFh][bp+di]
		sub	dl,byte ptr ss:[0FCFFh][bp+di]
		sub	bp,data_15[bx]
		loopnz	$+5			; Loop if zf=0, cx>0

;*		jmp	short loc_38		;*
		db	0EBh,0FAh		;  Fixup - byte match
		db	0FFh,0FCh, 2Ah, 93h,0FFh,0FCh
		db	 2Ah, 93h,0FFh,0FCh, 2Ah, 93h
		db	0FFh,0FCh, 2Ah, 92h,0ACh,0EAh
		db	 43h,0EAh,0A8h, 44h,0EAh,0A8h
		db	 44h,0EAh,0A8h, 44h,0EAh,0A8h
		db	 42h,0B0h, 28h, 0Ch, 0Eh, 42h
		db	0EAh,0A8h
		db	44h

locloop_39:
		jmp	far ptr $+3FB7h
		db	 44h,0EAh,0A8h, 43h,0ABh,0E8h
		db	0AFh,0FAh,0EFh,0E8h, 28h, 2Bh
		db	0AFh,0FAh,0FFh,0E8h, 28h, 3Eh
		db	0FAh,0AEh,0BBh,0E8h, 28h, 2Ah
		db	0AFh,0FAh,0FFh,0E8h, 28h, 3Ah
		db	 91h,0ECh,0C0h, 03h, 3Bh, 91h
		db	0AEh,0E8h, 28h, 2Ah,0AFh,0FAh
		db	 91h,0E8h, 28h, 3Ah, 91h,0FFh
		db	0AFh,0E8h, 28h, 3Fh,0AFh,0FAh
		db	 91h,0E8h, 28h, 7Bh,0AFh,0FAh
		db	 2Bh,0A8h,0BAh,0AFh,0FAh,0E2h
		db	0B8h, 3Ah,0FAh,0AFh, 91h,0E2h
		db	0B8h, 3Bh,0ABh,0BBh,0BAh,0E2h
		db	0B8h, 3Ah,0FAh,0AFh,0EAh,0E2h
		db	0B8h, 2Ah,0EAh,0EBh, 05h, 50h
		db	0EBh,0ABh, 91h,0E2h,0B8h, 3Ah
		db	0FAh,0AFh,0AFh,0E2h,0B8h, 2Fh
		db	0AFh, 91h,0FAh,0E2h,0B8h, 2Ah
		db	0FAh,0AFh,0AFh,0E2h,0B8h, 2Fh
		db	0FAh,0AEh, 2Ah,0F8h,0EAh,0EFh
		db	 91h,0CAh,0ACh, 2Bh,0ABh, 91h
		db	0FAh,0CAh,0ACh, 2Ah,0FEh,0AFh
		db	0ABh,0CAh,0ACh, 2Fh,0ABh, 91h
		db	0EBh,0CAh,0ACh, 2Ah,0BEh,0EAh
		db	 10h, 04h, 6Bh,0BAh,0EAh,0CAh
		db	0ACh, 2Fh, 92h,0FAh,0CAh,0ACh
		db	 2Ah,0FAh,0AFh, 91h,0CAh,0ACh
		db	 2Fh, 92h,0FAh,0CAh,0ACh, 2Ah
		db	0FBh,0ABh, 2Fh,0E8h,0EAh,0FAh
		db	 91h,0C8h, 2Ch, 2Ah, 92h,0AFh
		db	0C8h, 2Ch, 2Ah, 93h,0C8h, 2Ch
		db	 3Ah, 92h,0AEh,0C8h, 2Ch, 0Ah
		db	0ABh,0ECh, 10h, 34h, 3Bh,0EAh
		db	0A0h,0C8h, 2Ch, 3Ah,0BAh, 91h
		db	0AFh,0C8h, 2Ch, 2Ah,0AFh,0FAh
		db	 91h,0C8h, 2Ch, 3Ah,0BAh, 91h
		db	0AFh,0C8h, 2Ch, 2Ah,0AFh,0ABh
		db	 2Bh,0A8h,0EFh,0ABh,0A0h,0C8h
		db	0ECh, 2Bh,0A0h, 0Ah,0EAh,0C8h
		db	0ECh, 0Ah,0EAh,0ABh,0A0h,0C8h
		db	0ECh, 2Bh,0A0h, 0Ah,0AEh,0C8h
		db	0ECh, 02h,0A8h,0ECh, 11h, 74h
		db	 3Bh, 2Ah, 80h,0C8h,0ECh, 2Ah
		db	0E0h, 0Ah, 91h,0C8h,0ECh, 0Ah
		db	 91h,0AEh,0A0h,0C8h
data_20		db	0ECh			; Data table (indexed access)
		db	 2Bh,0A0h, 0Ah,0EAh,0C8h,0ECh
		db	 0Ah,0EAh,0FBh, 2Ah,0A8h, 92h
		db	 0Ah,0CAh,0ACh, 3Ah, 0Ah,0A0h
		db	0ABh,0CAh,0ACh, 20h, 92h, 8Ah
		db	0CAh,0ACh, 2Ah, 0Bh,0A2h, 91h
		db	0CAh,0ACh, 2Ah, 83h,0EAh, 17h
		db	0F4h, 6Bh, 82h,0B8h,0CAh,0ACh
		db	 2Ah, 0Ah,0A0h,0AEh,0CAh,0ACh
		db	 20h, 92h, 0Ah,0CAh,0ACh, 2Ah
		db	 0Ah,0A0h, 91h,0CAh,0ACh, 20h
		db	 92h, 2Ah,0E8h,0CAh,0A0h, 91h
		db	0E2h,0B8h, 28h, 91h, 0Ah, 0Ah
		db	0E2h,0B8h, 0Ah, 0Ah,0A0h, 91h
		db	0E2h,0B8h, 20h,0BAh, 0Ah, 0Ah
		db	0E2h,0B8h, 20h, 2Eh,0EBh, 05h
		db	 50h,0EBh,0A8h, 0Ah,0E2h,0B8h
		db	 20h,0A0h, 91h, 0Ah,0E2h,0B8h
		db	 2Ah, 0Ah,0A0h,0A0h,0E2h,0B8h
		db	 20h,0A0h, 91h, 0Ah,0E2h,0B8h
		db	 2Ah, 0Ah,0A3h, 2Bh,0A8h,0A0h
		db	 0Ah, 41h,0EBh,0E8h, 0Ah, 41h
		db	 91h,0A0h,0EBh,0E8h, 2Eh,0A0h
		db	 0Ah, 41h,0EBh,0E8h, 0Ah, 28h
		db	 91h,0EAh,0EBh,0E8h, 0Ah,0EAh
		db	0E0h, 80h, 03h, 2Bh, 91h,0A0h
		db	0EBh,0E8h, 2Ah, 91h, 41h,0A0h
		db	0EBh,0E8h, 41h,0A0h, 0Ah, 91h
		db	0EBh,0E8h, 0Ah,0EEh, 41h,0A0h
		db	0EBh,0E8h, 41h,0A0h, 0Ah, 2Ah
		db	0EAh,0EEh,0EFh,0ABh,0EAh,0A8h
		db	 3Eh,0FFh,0EEh,0EBh,0EAh,0A8h
		db	 3Fh,0EFh,0FAh,0BBh,0EAh,0A8h
		db	 3Bh,0FFh,0FFh,0FFh,0EAh,0A8h
		db	 3Fh,0FFh, 80h, 28h, 0Ch, 0Ah
		db	0FAh,0BFh,0EAh,0A8h, 3Fh,0EFh
		db	0FFh, 91h,0EAh,0A8h, 3Bh,0EFh
		db	0BBh,0BFh,0EAh,0A8h, 2Eh,0FBh
		db	0FBh,0AFh,0EAh,0A8h, 6Ah,0FBh
		db	0BBh,0ABh, 94h, 42h, 2Ah, 93h
		db	 42h, 2Ah, 93h, 42h, 2Ah, 93h
		db	 42h, 2Ah, 91h, 41h, 02h,0E0h
		db	 02h, 92h, 42h, 2Ah, 93h, 42h
		db	 2Ah, 93h, 42h, 2Ah, 92h,0EAh
		db	 42h, 2Ah, 93h,0EEh,0AEh,0EAh
		db	0AEh,0BEh,0FAh,0FAh,0BEh,0EEh
		db	0AFh,0FAh,0BEh,0EEh,0AFh,0FAh
		db	0BEh,0EEh,0AFh,0FAh,0BEh,0EEh
		db	0AFh,0FAh,0AEh,0EEh,0AFh,0FAh
		db	0BEh,0BEh,0AFh,0FAh,0BBh,0BEh
		db	0ABh,0FAh,0BBh,0BEh,0ABh,0FAh
		db	0BBh,0BEh,0AFh,0FAh,0BBh,0BEh
		db	0AFh,0FAh,0BBh,0BEh,0AFh,0FAh
		db	0BBh, 3Ah,0ABh,0BAh,0BAh, 00h
		db	 80h,0A8h, 02h, 80h, 42h, 20h
		db	 80h, 28h, 02h, 42h, 02h, 08h
		db	 20h, 80h, 43h, 28h, 0Ah, 28h
		db	 43h, 83h, 91h,0A8h, 0Ah,0A8h
		db	 28h, 43h, 02h, 80h, 2Ah, 02h
		db	'B *', 0Ah, 8, 'C', 8, 0Ah
		db	 80h, 42h, 02h, 80h, 2Ah, 02h
		db	 4Fh, 4Bh, 0Ah, 80h, 02h,0A0h
		db	 4Fh, 4Bh, 08h,0A0h, 02h,0E0h
		db	 42h, 03h, 80h, 44h, 0Eh, 0Ah
		db	 2Eh,0B8h, 49h,0A8h, 02h, 42h
		db	 88h,0A0h, 02h, 42h, 2Ah, 46h
		db	0A0h, 45h, 20h, 44h, 0Bh, 80h
		db	 0Ah, 20h, 20h, 80h, 4Ah, 38h
		db	 23h, 8Bh, 80h, 45h,0C0h, 42h
		db	 0Ah, 20h, 20h, 42h, 20h, 83h
		db	0A8h, 42h, 30h, 4Bh, 08h, 47h
		db	 02h, 08h, 30h, 41h,0E0h, 08h
		db	 42h, 08h, 45h, 08h, 0Eh,0A0h
		db	 20h, 44h, 02h, 23h, 48h, 38h
		db	0E2h, 42h, 20h, 41h, 02h, 46h
		db	 02h, 42h, 20h, 45h, 20h, 0Bh
		db	'A', 0Ch, ' ', 0Ah, 'D(E', 8, 0Ah
		db	0A0h, 20h, 44h, 02h, 02h, 42h
		db	 02h, 20h, 45h, 80h, 43h, 3Ah
		db	 44h, 02h, 41h, 02h, 44h, 38h
		db	 20h, 45h,0A0h, 08h, 28h, 41h
		db	 03h, 80h, 42h, 20h, 46h, 08h
		db	 20h, 80h, 45h, 8Ch, 42h, 02h
		db	 80h, 48h, 08h,0E0h, 41h, 22h
		db	 44h, 2Eh, 80h, 42h, 03h, 80h
		db	 41h,0C0h, 42h, 02h,0C0h, 41h
		db	 28h, 08h, 80h, 08h, 43h, 38h
		db	 46h, 02h, 41h, 80h
		db	43h
data_21		db	0Bh			; Data table (indexed access)
		db	 02h, 08h, 42h, 2Ah, 03h, 44h
		db	 80h, 38h, 42h, 20h, 42h, 0Eh
		db	 44h, 02h, 44h, 02h, 41h, 02h
		db	 43h, 20h, 02h
		db	20h
data_22		db	8			; Data table (indexed access)
		db	0C2h, 80h, 28h, 42h, 08h, 46h
		db	 02h, 45h,0B0h, 41h, 0Ah, 43h
		db	 0Eh, 44h,0A0h, 0Ah, 42h, 20h
		db	 41h, 2Ah, 02h
		db	 48h, 20h, 20h
data_23		dw	2844h			; Data table (indexed access)
		db	2
data_25		db	83h			; Data table (indexed access)
		db	 20h, 20h,0A0h, 0Ah, 43h, 08h
		db	 45h, 0Eh, 45h, 0Ah, 28h, 41h
		db	0EAh, 42h, 02h,0EAh, 02h, 42h
		db	 80h,0A8h,0A0h, 42h, 2Ah,0A0h
		db	 4Ah, 02h,0EEh, 45h,0A0h, 0Ah
		db	 08h, 41h, 2Eh, 20h,0A8h, 42h
		db	 02h, 41h, 22h, 28h, 43h, 20h
		db	 0Ah, 88h, 42h, 08h, 41h, 0Ch
		db	 45h, 0Ah, 80h, 02h,0A0h, 0Ah
		db	 80h, 43h, 20h, 41h, 91h
data_26		db	42h			; Data table (indexed access)
		db	 08h, 20h, 8Bh, 80h, 42h, 2Eh
		db	 08h, 0Bh,0A0h, 42h, 2Ah, 08h
		db	0B8h, 41h, 08h, 0Ah, 20h, 20h
		db	 42h, 02h, 41h, 02h, 08h, 43h
		db	 20h, 02h, 43h, 08h, 41h, 08h
		db	 45h, 2Ah,0A8h
		db	0Ah
data_27		db	0A8h			; Data table (indexed access)
		db	2
		db	8, 'C A(C "C', 8, 'A'
		db	 02h,0C0h, 42h, 08h, 08h,0A0h
		db	 20h, 20h, 02h, 20h, 20h, 4Ah
		db	 02h
		db	'C', 8, 'D G', 8, 'A', 8, 'C', 8, 'D'
		db	 02h, 47h, 02h, 41h, 08h, 08h
		db	 80h, 08h, 00h, 4Dh,0A3h,0EEh
		db	 33h,0A8h, 38h,0E2h,0A8h, 38h
		db	0FEh, 8Eh, 0Ah, 03h,0BEh, 13h
		db	0ABh, 11h, 0Ah,0EEh,0E8h,0BBh
		db	 8Ah, 0Eh, 12h,0A2h,0A8h, 11h
		db	0A2h, 11h,0E8h,0E2h,0AEh,0A2h
		db	 0Ah,0A8h, 11h, 23h,0B8h, 11h
		db	 2Eh, 8Ah,0A8h,0A2h, 2Ah,0A2h
		db	 0Eh,0A2h,0A2h,0A3h,0B8h,0AEh
		db	 28h,0ABh, 22h,0E2h, 2Ah, 22h
		db	 0Ah,0A3h,0A2h,0A3h,0ACh,0EAh
		db	0ACh,0CAh, 8Ah, 8Ah, 2Ah,0A2h
		db	 03h,0ABh,0A2h,0A3h, 11h,0B2h
		db	 11h,0CAh,0EAh, 8Ah,0FAh, 8Ah
		db	 03h,0E8h,0A2h,0A3h, 11h,0A2h
		db	 11h,0CBh, 11h,0A8h,0A8h, 8Ah
		db	 02h,0AEh,0EAh,0A8h,0EBh,0A3h
		db	0A8h, 88h, 11h,0A8h,0E8h, 8Ch
		db	 02h,0ABh,0EBh,0A8h,0EEh,0A3h
		db	 11h, 8Bh, 11h,0A8h,0A8h, 8Ch
		db	 41h,0EAh, 2Bh,0A8h,0EAh,0A3h
		db	 11h,0ABh, 11h,0A2h, 11h, 32h
		db	 41h,0EAh, 2Ah,0A8h,0EEh,0A3h
		db	 11h,0A8h,0ABh,0A2h,0A2h, 0Ah
		db	 41h, 11h, 3Ah,0A8h,0EAh,0A0h
		db	0A2h,0A8h, 11h,0A2h,0A2h, 0Bh
		db	 41h, 11h, 3Ah,0E8h,0EAh,0A3h
		db	 11h,0A8h, 11h, 8Bh,0A3h, 33h
		db	 41h, 3Ah, 3Ah,0A8h,0EAh,0A3h
		db	 11h,0A8h, 11h, 8Eh, 88h,0AFh
		db	 41h, 3Ah, 8Eh,0A8h,0EAh, 83h
		db	 11h, 88h, 11h, 8Eh, 8Ch,0ACh
		db	 41h, 2Ah, 8Eh,0ACh,0EAh, 23h
		db	0A8h,0A2h, 11h, 02h, 0Ch,0B3h
		db	 41h, 2Ah, 8Eh, 88h,0EAh, 80h
		db	 11h, 82h,0A8h, 8Fh, 8Ch,0CBh
		db	 41h, 0Eh, 8Eh,0A0h,0EAh, 23h
		db	0ABh, 22h,0A2h, 3Ah, 32h,0CAh
		db	 41h, 0Eh,0A2h, 88h,0E8h, 80h
		db	0A0h, 8Eh,0A8h, 88h, 32h,0B2h
		db	 41h, 0Ah, 2Eh, 20h,0EBh, 23h
		db	0A2h, 02h, 23h, 0Ah, 32h,0ACh
		db	 41h, 08h, 83h, 80h,0E8h, 03h
		db	0A8h, 0Eh, 8Ah, 30h, 32h,0ACh
		db	 41h, 02h,0ACh,0FBh, 3Ah,0A8h
		db	0EBh,0A3h,0EEh,0CFh, 82h,0B2h
		db	 41h, 0Ah, 11h,0AEh, 12h,0BAh
		db	0A2h,0BAh,0ABh,0A0h,0CBh, 41h
		db	 3Ah,0A8h,0BAh, 2Ah, 11h,0A2h
		db	 8Ah,0A8h, 11h, 88h,0CBh, 41h
		db	 2Ah,0A2h,0A8h, 11h, 8Bh, 22h
		db	 8Ah,0A8h, 11h,0A8h, 33h, 41h
		db	0E2h,0A2h
data_28		db	13h
		db	 8Ah, 11h,0A8h, 11h,0A2h, 2Fh
		db	 41h, 8Ah
data_29		dw	128Ah			; Data table (indexed access)
		db	0A8h
data_31		dw	138Ah			; Data table (indexed access)
		db	0A2h, 2Fh, 41h, 13h,0A2h, 28h
		db	 13h, 20h, 82h
		db	33h
data_32		db	41h			; Data table (indexed access)
		db	 2Ah, 13h,0A8h, 88h, 88h, 88h
		db	 88h, 08h, 0Bh, 41h, 2Ah, 20h
		db	 20h,0A2h,0A2h, 22h, 20h, 02h
		db	 41h, 08h,0CBh, 41h, 0Ah, 80h
		db	 08h, 46h, 32h, 11h, 41h, 02h
		db	 11h,0BBh
data_33		dw	0A8FBh			; Data table (indexed access)
		db	0AEh,0FAh,0ABh,0ABh,0C2h,0CBh
		db	 42h, 2Ah, 11h,0EBh, 11h,0BAh
		db	 13h, 0Bh,0A3h, 41h, 02h,0A8h
		db	 22h,0BAh, 2Ah,0CEh,0A3h, 12h
		db	0A3h,0A3h, 41h, 0Eh,0A2h,0BAh
		db	 11h, 2Ah, 82h,0A2h, 11h,0A8h
		db	 22h,0CBh, 41h, 3Ah, 2Ah,0ABh
		db	 12h, 83h, 8Eh, 8Ah,0A2h,0A2h
		db	0BBh, 41h, 28h,0BAh,0ABh, 2Ah
		db	 88h,0E8h,0EAh, 88h,0A2h, 22h
		db	0CAh, 41h,0E2h
data_34		db	0FAh
		db	0A2h, 2Eh, 80h,0EAh, 0Eh
data_35		db	88h			; Data table (indexed access)
		db	 11h, 83h,0A2h, 41h,0E2h,0A2h
		db	 22h, 11h, 83h
data_36		db	11h			; Data table (indexed access)
		db	0A3h,0A8h, 11h, 23h,0A3h, 41h
		db	0EAh,0B8h,0A2h,0ACh, 83h, 11h
		db	0A3h
data_37		db	0A8h			; Data table (indexed access)
		db	 11h,0A2h,0CBh, 41h, 0Ah, 22h
		db	 11h
data_38		dw	83A8h			; Data table (indexed access)
		db	 11h,0E0h, 3Ah, 11h, 22h,0ABh
		db	 41h, 03h, 12h,0A8h,0A3h, 11h
		db	0A3h, 8Eh,0EAh, 82h,0CBh, 41h
		db	 22h,0C2h, 11h,0ABh, 83h,0ABh
		db	0A3h,0A0h,0A2h, 23h,0A3h, 41h
		db	 08h, 8Bh, 2Ah, 11h,0A3h,0ABh
		db	0A3h, 12h, 83h,0A3h, 42h, 02h
		db	 0Ah, 11h, 83h, 11h,0A2h, 11h
		db	 8Ah, 22h,0CBh, 41h, 02h,0A0h
		db	 8Eh, 11h, 83h, 11h, 8Eh, 12h
		db	 82h,0EBh, 41h, 0Eh,0D2h, 22h
		db	 11h, 83h, 14h,0A2h,0CBh, 41h
		db	 3Ah,0ABh, 8Bh, 11h, 83h, 8Ah
		db	 12h,0A8h,0A3h,0A2h, 41h,0EAh
		db	0AFh, 80h,0EAh, 23h,0BAh, 2Ah
		db	 12h, 03h,0A3h, 03h, 11h,0AFh
data_39		db	0E2h			; Data table (indexed access)
		db	0A8h, 82h, 12h,0A2h,0A8h, 22h
		db	0CBh, 03h,0ABh,0FAh, 8Eh,0A8h
		db	 23h, 8Ah, 11h,0A2h, 8Ah, 22h
		db	0ABh, 0Eh,0ABh,0A0h,0FAh,0A2h
		db	 83h,0BAh,0ABh, 12h, 82h,0C8h
		db	 0Eh, 11h,0CFh, 8Ah,0A2h, 0Bh
		db	 11h, 2Ah, 2Ah, 11h, 23h,0A2h
		db	 0Eh, 11h, 3Ah, 2Ah, 11h, 83h
		db	 8Ah, 11h, 8Ah, 2Ah, 83h,0A3h
data_40		db	0Eh
		db	0A0h,0E8h, 11h,0A8h,0A3h, 12h
		db	0A2h, 11h, 02h,0CAh, 3Ah, 83h
		db	0C8h, 11h,0BAh, 83h, 8Ah,0A8h
		db	0A2h,0A2h,0A2h,0ABh, 3Ah,0A2h
		db	 82h, 2Ah, 88h,0A2h,0BAh,0ABh
		db	 8Ah, 11h, 22h,0CBh, 3Ah, 82h
		db	 2Eh, 3Ah, 2Ah, 02h, 11h, 8Ah
		db	 12h,0A3h,0A3h, 3Ah, 20h, 11h
		db	 2Ah, 11h, 83h, 11h,0BAh, 11h
		db	 22h, 03h,0A2h, 3Ah, 82h,0EEh
		db	0EAh, 8Eh,0A3h, 14h, 82h,0CBh
		db	 3Ah, 20h,0EAh,0BAh, 2Ah, 80h
		db	 13h, 2Ah, 22h,0ABh, 38h, 80h
		db	0BAh, 12h, 20h,0BAh, 12h, 88h
		db	 22h,0CBh, 3Ah,0C0h, 3Bh,0BAh
		db	 11h, 83h, 13h, 88h,0A3h,0A2h
		db	 41h, 08h, 3Eh, 12h, 83h,0BAh
		db	 12h,0A2h, 03h,0A3h, 41h, 22h
		db	 3Bh,0AEh,0EAh, 23h,0BAh,0EAh
		db	0AEh,0A8h, 22h,0CBh, 41h,0C8h
		db	 3Eh, 12h, 80h, 13h, 8Ah, 22h
		db	0ABh, 03h,0A2h, 0Bh,0AEh, 11h
		db	 20h,0BAh, 12h,0A8h, 02h,0C8h
		db	 02h,0A8h, 8Eh, 11h,0AEh, 83h
		db	0BAh, 13h, 23h,0A2h, 0Ah,0BAh
		db	 0Eh,0EAh, 11h, 0Bh,0BAh,0EAh
		db	 11h, 20h, 03h,0A3h, 41h, 11h
		db	 8Ah, 12h, 83h,0BAh, 12h, 8Ah
		db	 02h,0CAh, 41h, 0Ah, 0Eh,0BAh
		db	 11h, 20h, 13h,0A0h, 02h,0ABh
		db	 41h, 02h,0BAh, 11h,0BAh, 83h
		db	0BAh, 12h, 8Ah, 22h,0CBh, 03h
		db	0FAh,0CBh, 12h, 20h,0BAh,0ABh
		db	0ABh,0A8h, 23h,0A3h, 0Eh,0EAh
		db	0CEh, 12h, 41h, 13h, 22h, 03h
		db	0A2h, 0Eh,0BAh,0EEh,0EAh, 11h
		db	 83h,0BEh,0BAh, 11h, 88h, 02h
		db	0CBh, 03h, 11h,0EAh, 11h,0AEh
		db	 03h,0BAh, 11h,0BAh, 22h, 22h
		db	0ABh, 02h,0EBh, 2Eh, 11h,0EAh
		db	 80h,0BAh, 12h, 88h, 22h,0CBh
		db	 41h,0ABh, 2Ah, 12h, 41h,0BAh
		db	 12h, 22h, 22h,0CBh, 41h,0EBh
		db	 3Bh, 11h, 80h, 03h,0BAh, 12h
		db	 88h,0A3h,0A2h, 41h, 11h, 2Eh
		db	0BAh, 20h, 03h,0EAh, 12h,0A2h
		db	 03h,0A3h, 41h,0EBh, 3Bh,0A8h
		db	 41h, 08h, 12h,0A0h,0A8h, 22h
		db	0CBh, 41h,0ABh, 2Eh, 20h, 41h
		db	 23h,0EAh,0A0h,0FFh,0F0h, 11h
		db	0ABh, 41h,0A8h, 88h, 80h, 08h
		db	 88h, 11h, 0Fh,0FEh,0EEh,0F2h
		db	0ABh, 02h,0A0h, 20h, 41h, 22h
		db	 23h,0A8h,0FBh,0FAh,0BBh,0BBh
		db	 2Ah, 0Ah, 02h, 41h, 08h, 88h
		db	 8Bh,0ABh,0EEh,0EEh,0EAh,0AEh
		db	 8Bh, 08h, 41h, 22h, 02h, 22h
		db	 22h,0AFh,0BBh, 11h,0AEh,0ABh
		db	0A2h, 42h, 80h, 88h, 88h, 8Fh
		db	0EFh, 11h,0EAh,0BAh, 11h,0A3h
		db	 41h, 02h, 22h, 22h, 23h,0FAh
		db	 8Fh, 13h,0BAh,0A3h, 42h, 88h
		db	 88h,0FFh, 11h, 8Eh,0EAh, 13h
		db	 83h, 41h, 02h,0A2h, 3Fh,0BAh
		db	 11h, 8Fh, 13h,0BAh,0A3h, 41h
		db	 03h, 8Fh,0EAh,0BEh, 8Eh, 8Eh
		db	 13h,0EAh,0A2h, 41h, 03h, 3Ah
		db	 11h,0AEh,0A3h, 8Fh, 14h, 83h
		db	 41h, 03h,0BAh, 13h, 0Eh, 14h
		db	 82h, 41h, 02h, 3Ah, 12h,0A8h
		db	0CEh, 14h, 23h, 41h, 0Eh,0EAh
		db	 13h, 8Eh, 14h,0A3h, 41h, 3Ah
		db	0E0h, 12h,0A8h, 0Eh, 14h,0A3h
		db	 03h,0FFh,0ABh, 8Eh, 11h, 80h
		db	 2Eh, 14h,0A2h, 0Eh, 12h,0A0h
		db	0E8h, 02h, 2Eh,0A3h, 13h, 83h
		db	 0Eh, 11h,0EAh,0BAh, 80h, 22h
		db	 82h, 8Bh, 13h,0A3h, 0Eh, 13h
		db	 3Bh,0CAh, 2Ah, 8Bh, 13h, 83h
		db	 0Eh, 12h,0A8h,0EAh,0BCh,0AEh
		db	 8Eh, 11h,0AEh, 11h,0A3h, 0Eh
		db	 12h,0A0h, 11h,0ABh,0EEh, 14h
		db	0A3h, 0Eh, 11h,0BAh, 8Eh, 2Ah
		db	 11h, 8Eh, 14h,0B3h, 41h, 11h
		db	0A8h, 3Ah, 8Eh, 11h, 8Eh, 12h
		db	0ABh, 11h,0A2h, 0Ah, 2Ah, 11h
		db	0EEh, 8Eh, 11h, 82h,0BAh, 13h
		db	0A3h, 0Ah, 2Ah, 12h,0BAh, 11h
		db	 0Eh, 14h,0A3h, 02h, 8Ah, 14h
		db	 82h, 14h, 82h, 0Ah, 8Ah, 11h
		db	0EAh, 11h,0A2h, 8Eh, 14h, 82h
		db	 0Ah,0EAh,0BAh,0ABh, 11h, 08h
		db	 0Eh,0ABh, 13h,0A3h, 0Bh, 13h
		db	0A2h, 80h, 2Eh, 14h,0A3h, 0Eh
		db	 13h, 80h, 02h,0AEh, 13h, 2Ah
		db	 83h, 0Eh, 13h, 41h, 2Ah, 2Eh
		db	 14h,0A3h, 0Eh, 12h,0A2h,0ABh
		db	0C8h, 8Eh, 14h,0A2h, 0Eh, 11h
		db	0EAh,0AEh, 11h,0BEh, 2Ah, 14h
		db	 83h, 0Eh, 14h,0ABh,0CEh, 14h
		db	0A3h, 0Eh, 15h, 8Eh, 14h,0A3h
		db	 0Eh, 15h, 8Ah, 12h, 2Ah, 11h
		db	 83h, 0Eh, 11h,0BAh, 13h, 0Ah
		db	 12h,0EAh, 11h, 83h, 0Eh, 14h
		db	0A8h, 8Ah, 14h, 83h, 0Eh, 13h
		db	0A8h, 11h, 8Eh, 14h,0A2h, 41h
		db	0A0h,0A2h, 2Ah, 22h, 08h, 0Ah
		db	 14h, 83h, 46h, 0Eh, 14h, 83h
		db	 41h, 02h, 22h, 22h, 02h, 41h
		db	 0Eh, 13h,0A2h, 02h, 42h, 88h
		db	 88h, 88h, 41h, 0Eh, 12h,0A2h
		db	 88h, 82h, 42h, 11h,0A2h, 22h
		db	 20h, 0Eh, 13h, 22h, 0Fh, 41h
		db	 02h, 2Ah,0A8h, 88h, 88h, 0Ch
		db	 44h, 0Fh, 41h, 02h, 13h, 22h
		db	 03h,0FFh,0FEh,0FBh,0A8h, 0Bh
		db	 41h, 02h, 13h, 88h, 03h, 13h
		db	0A2h, 0Bh, 41h, 3Fh,0FFh,0F3h
		db	0FFh,0FFh,0CEh, 2Ah, 11h,0A8h
		db	 80h, 23h, 41h,0EAh, 11h, 8Eh
		db	 12h, 8Eh, 2Ah, 11h, 82h, 20h
		db	 23h, 03h, 12h, 8Eh,0BAh, 11h
		db	 8Fh, 44h, 83h, 03h, 12h, 8Fh
		db	0EAh, 11h,0BEh, 14h, 02h, 03h
		db	 8Ah, 11h, 8Eh, 12h,0EAh, 12h
		db	0ABh, 11h, 83h, 03h, 12h, 8Eh
		db	 11h,0ABh, 11h, 2Ah, 12h,0BAh
		db	 83h, 03h, 12h, 8Eh, 11h,0ABh
		db	0A8h, 14h,0A3h, 03h, 11h,0A3h
		db	 8Eh, 11h,0AEh,0A2h, 12h,0EAh
		db	 11h,0A3h, 03h, 11h,0AEh, 8Eh
		db	 11h,0AEh,0A3h, 11h, 2Ah, 11h
		db	0A2h,0A3h, 03h, 12h, 8Eh, 11h
		db	0AEh, 83h, 11h,0A8h, 12h,0E3h
		db	 03h, 12h, 8Eh, 11h,0AEh,0A3h
		db	0A8h,0EAh, 3Ah, 0Eh,0A3h, 03h
		db	 12h, 80h, 11h,0AEh, 83h,0A8h
		db	0EAh, 3Ah, 0Eh,0A2h, 03h,0A2h
		db	 11h, 82h,0EAh,0ACh,0A3h, 28h
		db	0EAh, 3Ah, 8Eh,0A2h, 03h, 12h
		db	 82h,0EAh,0AEh, 83h, 88h,0CAh
		db	 3Ah, 8Ch,0A3h, 03h, 12h, 82h
		db	0EAh,0ACh, 03h,0A8h,0E8h, 32h
		db	 8Eh, 83h, 03h, 12h, 8Fh, 11h
		db	 2Ah, 0Bh, 20h,0CAh, 3Ah, 0Ch
		db	0A2h, 03h, 11h,0A3h, 8Fh, 11h
		db	 8Ah,0ABh,0A0h,0E8h, 3Ah, 0Ch
		db	0A3h, 03h, 11h, 8Eh, 8Eh, 11h
		db	 8Eh, 8Fh, 28h,0E8h, 38h, 8Eh
		db	 83h, 03h,0A0h, 3Ah, 8Eh, 11h
		db	 30h, 0Fh,0A0h,0E2h, 3Ah, 0Eh
		db	 23h, 41h, 0Ch,0EAh, 8Eh,0A8h
		db	0A3h, 8Fh,0A0h,0E8h, 32h, 0Eh
		db	 82h, 03h, 11h, 0Eh, 8Eh,0A8h
		db	0CEh, 8Fh, 80h,0E0h, 30h, 8Eh
		db	 03h, 03h, 11h,0A3h, 8Eh,0A3h
		db	 11h, 0Eh,0C2h,0B0h, 8Ch, 2Bh
		db	 0Bh, 03h, 12h, 0Eh, 12h, 8Eh
		db	 12h, 8Eh, 11h,0A2h, 03h, 12h
		db	 8Eh, 12h, 0Eh, 12h
data_41		db	0Eh			; Data table (indexed access)
		db	11h
data_42		db	0A2h
		db	 03h, 12h, 8Eh, 12h, 0Eh, 12h
		db	 8Eh, 11h, 83h, 03h, 12h, 0Eh
		db	 12h, 8Eh, 12h, 0Eh, 11h,0A3h
		db	 03h, 11h,0A2h, 0Eh, 12h, 0Eh
		db	 12h, 0Eh, 11h, 83h, 03h, 12h
		db	 8Eh, 11h,0A8h, 0Eh, 12h, 8Eh
		db	 11h, 23h, 41h, 8Ah,0A2h, 0Eh
		db	 11h, 8Ah, 0Eh, 11h, 88h, 0Eh
		db	0A8h, 03h, 41h, 22h, 08h, 0Ah
		db	 82h, 20h, 0Eh, 88h, 20h, 0Eh
		db	 82h, 02h, 4Bh, 0Ah, 41h, 0Eh
		db	 17h,0A0h, 41h,0A2h, 41h,0FAh
		db	 18h, 20h,0CAh, 03h, 19h, 88h
		db	 3Ah, 0Eh, 15h,0A8h,0A0h,0A2h
		db	 22h, 20h, 0Eh, 0Fh,0FFh,0EAh
		db	0CBh,0EBh,0EEh,0EEh,0BAh,0BAh
		db	0BEh, 11h,0BEh, 0Eh, 12h,0A3h
		db	 11h,0BAh,0B8h,0A8h, 11h,0EAh
		db	 82h,0A2h, 0Eh, 12h,0A3h, 14h
		db	 22h,0AEh, 2Ah, 82h, 0Eh, 12h
		db	0A8h, 12h,0A3h, 88h,0E2h, 11h
		db	 3Ah,0A2h, 0Eh, 11h,0A8h,0A8h
		db	0EAh, 11h, 0Eh,0A8h,0EAh,0A8h
		db	 22h, 82h, 0Eh, 12h,0A8h,0EAh
		db	0A8h,0E3h,0A3h, 11h, 20h, 3Ah
		db	0A2h, 0Eh, 13h, 0Ah,0A8h,0E8h
		db	 8Eh,0A0h, 0Ah, 8Ah,0A2h, 0Eh
		db	 13h,0A0h,0E3h, 11h, 3Ah, 0Eh
		db	0A3h, 11h,0A2h, 0Eh, 12h, 2Ah
		db	 8Eh, 33h, 11h, 28h,0EAh, 83h
		db	0A8h, 02h, 0Eh, 12h, 38h, 2Ah
		db	 22h, 11h, 83h, 11h,0A2h,0A3h
		db	 82h, 02h, 11h,0ABh, 83h, 8Eh
		db	 8Ah, 13h, 8Eh,0A2h, 82h, 41h
		db	 12h, 3Ah,0A2h, 8Ah, 11h, 82h
		db	 11h, 8Eh, 11h, 22h, 03h, 11h
		db	0ABh, 11h,0A3h,0A3h,0A8h, 28h
		db	 11h, 23h, 11h, 82h, 02h, 13h
		db	 8Ch,0A3h, 03h, 8Bh,0A2h,0A8h
		db	0EAh, 22h, 0Eh, 12h, 8Ah, 2Ah
		db	0A8h,0EAh, 8Bh,0AEh, 11h, 3Ah
		db	 82h, 0Eh, 11h, 2Ah, 8Ah, 11h
		db	0A2h, 11h,0AEh, 12h, 3Ah, 02h
		db	 0Eh,0ACh, 28h, 8Ah, 11h,0A3h
		db	 11h,0ABh,0AEh, 2Ah, 2Ah, 82h
		db	 0Eh,0A8h,0A8h, 8Ah, 13h,0ABh
		db	0A2h, 2Ah, 8Eh, 22h, 03h,0A8h
		db	 11h, 2Ah, 13h,0AEh,0A2h, 2Ah
		db	 8Eh, 82h, 0Eh, 12h, 8Ah, 11h
		db	 2Ah, 11h,0BAh, 11h, 2Ah, 3Ah
		db	 02h, 0Eh, 11h,0A2h, 12h, 2Ah
		db	0AFh,0FAh,0AEh, 2Ah,0A8h, 82h
		db	 0Eh, 11h,0AEh, 2Ah, 11h, 2Eh
		db	0BAh, 12h, 8Ah,0A2h, 02h, 03h
		db	 12h, 2Ah,0ABh,0FBh,0EAh, 11h
		db	0AEh, 8Ah,0A8h, 02h, 03h,0A8h
		db	 11h, 8Ah, 13h, 82h, 8Ah, 0Ah
		db	 22h, 02h, 0Eh,0A8h, 2Bh, 8Ah
		db	0ABh, 8Ah, 8Ah, 88h,0BAh, 8Ah
		db	 88h, 02h, 0Eh,0B8h,0ABh, 8Ah
		db	0AEh, 0Ah,0EEh, 2Ah,0E2h, 02h
		db	 22h, 02h, 0Eh,0A8h,0BAh, 82h
		db	0A8h, 8Bh,0A2h,0A8h, 11h, 80h
		db	 08h, 02h, 0Eh,0B8h, 11h,0A2h
		db	 3Ah, 03h, 88h,0BAh,0A2h, 20h
		db	 22h, 02h, 0Eh,0A8h,0BAh, 82h
		db	 3Ah, 88h,0A0h,0CAh, 02h, 88h
		db	 41h, 02h, 0Eh,0ACh,0ABh, 28h
		db	 11h, 0Ah, 28h,0E2h, 02h, 88h
		db	 22h, 02h, 0Eh,0A8h, 2Bh, 88h
		db	0E8h, 82h, 82h,0CAh, 8Ah, 20h
		db	 80h, 02h, 0Eh,0B8h, 0Ah, 08h
		db	0EAh, 08h, 8Ah,0A8h,0A2h, 28h
		db	 02h, 02h, 0Eh,0EAh, 08h, 8Eh
		db	0A8h,0A3h, 08h, 82h, 88h, 08h
		db	 80h, 02h, 0Eh, 11h,0A2h, 22h
		db	 22h, 02h, 02h, 22h, 20h, 22h
		db	 41h, 02h, 0Eh, 08h, 88h, 0Ah
		db	 82h, 20h, 02h, 08h, 08h, 42h
		db	 02h, 00h, 1Dh,0ABh,0E2h,0BBh
		db	 11h,0BAh,0EAh,0A2h,0BAh,0FEh
		db	0AEh,0A0h,0ABh,0BEh, 13h,0ABh
		db	 11h, 08h,0EEh,0E8h,0BBh,0A0h
		db	0ACh, 12h,0A2h,0A8h, 11h,0A2h
		db	0A8h,0E8h,0E0h, 2Eh,0A0h, 11h
		db	0A8h
data_43		db	2Ah			; Data table (indexed access)
data_44		dw	3820h			; Data table (indexed access)
		db	 0Ah, 0Eh, 8Ah,0A8h,0A0h
data_45		db	0Ah
		db	0A0h,0A0h, 20h, 22h, 41h, 38h
		db	 0Eh, 08h, 83h,0A0h,0E2h, 22h
		db	 20h,0A0h, 20h, 22h, 20h, 0Ch
		db	 0Ah, 0Ch,0C2h, 80h, 82h
data_46		db	28h			; Data table (indexed access)
		db	0A0h,0A8h, 80h, 20h,0A0h, 41h
		db	 30h, 08h,0C0h, 41h, 82h, 30h
		db	 80h,0A8h,0E0h, 20h,0A0h, 41h
		db	 20h, 41h,0C0h, 02h, 08h, 20h
		db	 80h,0A8h, 0Ch, 20h, 28h, 03h
data_47		dw	4120h
data_49		db	80h			; Data table (indexed access)
		db	 02h, 08h,0C0h, 80h,0A8h, 28h
		db	 03h, 08h, 0Eh, 80h, 41h, 80h
		db	 20h, 08h, 88h, 80h, 11h, 22h
		db	 23h, 08h, 02h, 41h, 20h, 80h
		db	 22h, 02h, 2Ah, 41h, 11h, 02h
		db	 22h, 42h, 20h, 42h, 03h, 02h
		db	 02h, 41h, 11h, 02h, 02h, 42h
		db	 20h, 42h, 02h, 41h, 22h, 41h
		db	 11h, 41h, 02h, 41h, 20h, 41h
		db	 20h, 20h, 20h, 43h, 11h, 80h
		db	 43h, 80h
		db	41h
data_50		dw	4280h			; Data table (indexed access)
		db	 08h, 41h, 11h, 80h, 44h
data_51		dw	820h			; Data table (indexed access)
		db	 08h, 41h
data_53		dw	4180h			; Data table (indexed access)
		db	 11h, 80h, 42h, 08h, 20h, 41h
		db	 20h, 20h, 02h, 41h, 30h, 11h
		db	 80h
		db	 42h, 08h, 42h
data_55		db	80h
		db	20h
data_56		dw	4103h			; Data table (indexed access)
		db	0C8h, 11h,0A0h, 43h
data_57		db	20h			; Data table (indexed access)
		db	 41h, 20h, 41h, 02h, 41h, 02h
		db	 11h,0A0h, 43h, 80h, 41h, 80h
		db	 08h, 80h, 41h, 30h, 11h
data_58		dw	42A0h			; Data table (indexed access)
		db	 03h, 20h, 02h, 41h, 23h, 0Ah
		db	 41h, 20h, 11h,0A0h, 42h, 08h
		db	 41h, 28h, 41h, 8Ah, 42h,0ACh
		db	 11h,0A8h,0A0h, 38h, 3Ah,0A8h
		db	 2Bh,0A0h, 2Eh, 41h, 82h, 80h
		db	 13h,0AEh, 12h,0BAh,0A2h,0BAh
		db	0A3h,0A0h, 08h, 11h,0BAh,0A8h
		db	0BAh, 2Ah, 11h,0A0h, 80h, 08h
		db	 41h, 88h, 41h, 12h,0A0h, 08h
		db	 02h, 8Bh, 20h, 80h, 08h, 41h
		db	 20h, 41h, 11h,0E2h,0A0h, 42h
		db	 0Ah, 80h, 80h, 08h, 43h, 11h
		db	 80h, 80h, 42h, 08h, 80h, 41h
		db	 08h, 42h, 20h, 11h, 41h, 80h
		db	 42h, 08h, 42h, 08h, 43h, 11h
		db	 80h, 46h, 08h, 43h, 11h, 80h
		db	 4Ah, 11h,0A0h
		db	4Ah
data_59		db	11h
		db	0A8h, 42h, 38h,0A8h,0AEh,0FAh
		db	0ABh,0A3h, 41h, 08h, 13h, 8Ah
		db	0EBh, 11h,0BAh, 13h, 42h, 12h
		db	0A8h, 22h,0B2h, 0Ah,0C2h,0A3h
		db	 11h, 2Ah, 42h, 11h,0AEh,0A0h
		db	 32h,0A2h, 02h, 80h,0A2h, 11h
		db	0A8h, 41h, 08h, 11h,0BAh, 20h
		db	 2Bh,0A0h, 0Ah, 80h, 8Eh, 8Ah
		db	0A0h, 80h,0B8h, 11h,0A8h, 32h
		db	 0Bh, 20h, 88h,0C8h, 0Ah, 88h
		db	 20h, 02h, 08h, 11h, 20h, 3Ah
		db	0A2h, 41h, 80h,0CAh, 41h, 88h
		db	 41h, 80h, 41h, 11h, 20h, 22h
		db	 22h, 02h, 80h, 88h, 41h, 08h
		db	 02h, 42h, 11h, 02h,0B8h, 41h
		db	 0Ch, 80h, 80h, 41h, 08h, 02h
		db	 02h, 41h, 11h, 82h, 22h, 41h
		db	 08h, 80h, 80h,0C0h, 41h, 02h
		db	 02h, 80h, 11h, 83h, 22h, 41h
		db	 08h, 80h, 02h,0A0h, 02h,0E0h
		db	 02h, 08h, 11h, 82h, 42h, 80h
		db	 80h, 03h, 80h, 41h,0A0h, 42h
		db	 11h,0A0h, 88h, 42h, 80h, 03h
data_60		dw	0A41h			; Data table (indexed access)
		db	0A8h, 41h, 20h, 11h,0A8h, 02h
		db	 41h, 80h, 41h, 02h, 41h, 0Ah
		db	 88h, 41h, 08h, 11h,0A8h,0A0h
		db	 80h, 80h, 42h, 80h, 02h, 20h
		db	 41h,0E0h, 11h,0A2h, 3Ah, 20h
		db	0A2h, 80h, 08h, 45h, 11h,0B8h
		db	0FBh, 88h, 02h, 80h, 0Ah, 80h
		db	 42h, 20h, 41h, 11h,0E0h,0EFh
		db	 80h, 08h, 41h, 3Ah, 45h,0A8h
		db	0A0h,0A0h, 02h, 28h, 41h, 2Ah
		db	 88h, 20h, 41h, 20h, 41h,0A8h
		db	 41h, 02h, 82h, 28h, 41h, 0Ah
		db	 80h, 20h, 41h, 20h, 41h,0A0h
		db	 41h, 20h,0FAh,0A0h, 41h, 3Ah
		db	 03h, 41h,0A0h, 42h,0A2h, 02h
		db	 0Fh, 80h,0A0h, 41h, 28h, 02h
		db	 41h,0A0h, 20h, 41h,0AEh, 0Ah
		db	 3Ah, 20h, 28h, 41h, 08h, 41h
		db	 80h, 43h,0ACh, 41h,0E8h, 20h
		db	 08h, 41h, 08h, 80h,0A0h, 0Ah
		db	 42h, 88h, 41h,0C8h, 20h, 08h
		db	 41h, 0Ah, 41h,0A0h, 43h, 88h
		db	 22h, 82h, 22h, 88h, 41h, 32h
		db	 41h, 80h, 02h, 20h, 41h, 80h
		db	 02h, 02h
		db	'A', 8, 'A"B  A'
		db	0B8h, 20h, 02h, 43h, 02h, 41h
		db	 0Ah, 02h, 42h,0B8h, 42h, 02h
		db	 80h, 41h, 08h, 41h, 0Ah, 43h
		db	 88h, 20h, 41h, 02h, 42h, 08h
		db	 0Ah, 02h, 41h, 20h, 41h, 80h
		db	 41h, 02h, 44h, 0Ah, 20h, 43h
		db	 82h, 42h, 0Ah, 28h, 42h, 20h
		db	 44h, 80h, 42h, 02h, 28h, 80h
		db	 41h, 20h, 44h, 11h, 02h, 43h
		db	 20h, 42h, 0Ch, 41h, 20h, 41h
		db	 11h, 42h, 20h, 42h, 02h, 20h
		db	 0Ah, 02h, 42h,0A8h, 02h, 41h
		db	 20h, 41h, 20h, 02h, 0Ah, 08h
		db	 28h, 42h, 11h, 43h, 02h, 42h
		db	 08h, 41h, 02h, 20h, 41h,0A8h
		db	 30h, 42h, 02h, 08h, 02h, 45h
		db	0A0h,0A0h, 41h, 0Ah, 08h, 41h
		db	 02h, 42h, 08h, 42h, 11h, 08h
		db	 41h, 0Ah, 0Ah, 20h, 02h, 08h
		db	0A0h, 43h, 11h,0A0h, 42h, 08h
		db	 80h, 42h,0A0h, 02h, 20h, 41h
		db	0A8h, 42h, 20h, 02h, 20h, 42h
		db	 03h, 08h, 20h, 41h,0A0h,0E2h
		db	 42h, 20h, 44h, 02h, 42h,0A0h
		db	 8Ah, 42h, 20h, 80h, 41h, 02h
		db	 41h, 08h, 42h,0A8h, 08h, 41h
		db	 08h, 44h, 30h, 02h, 20h, 41h
		db	0A8h, 43h, 02h, 42h, 20h, 41h
		db	 88h, 20h, 41h, 11h, 42h, 82h
		db	 02h, 41h, 02h, 42h, 02h, 20h
		db	 41h, 11h, 08h, 41h, 20h, 43h
		db	 22h, 44h, 11h, 02h, 02h, 02h
		db	 43h, 02h, 44h, 11h, 42h, 28h
		db	 41h, 08h, 0Ah, 08h, 44h, 11h
		db	 08h, 41h, 20h, 41h, 20h, 0Ah
		db	 45h, 11h, 28h, 80h, 80h, 41h
		db	 08h, 43h, 02h, 42h,0A8h,0A0h
		db	 20h, 41h, 20h, 20h, 41h,0F0h
		db	 41h, 08h, 88h, 41h,0A2h, 42h
		db	 08h, 08h, 88h, 23h, 42h, 02h
		db	 02h, 80h,0A0h, 41h, 22h, 41h
		db	 20h, 41h,0AFh, 42h, 0Eh, 41h
		db	 20h, 11h,0A8h, 80h, 41h, 80h
		db	 41h, 0Ch, 41h, 08h, 38h, 20h
		db	 20h, 11h,0A8h, 20h, 22h, 03h
		db	0C2h, 80h, 42h, 08h, 30h, 20h
		db	 11h,0A8h, 41h, 08h,0F3h, 80h
		db	 80h, 02h, 41h, 20h, 08h, 80h
		db	 11h,0A8h, 80h, 41h, 30h, 80h
		db	 41h, 08h, 20h, 20h, 38h, 20h
		db	 11h,0A8h, 42h, 3Ch, 42h, 28h
		db	 42h,0E0h, 41h, 11h,0A8h, 41h
		db	 20h, 0Ch, 42h, 20h, 41h, 80h
		db	0A0h, 41h, 11h,0A8h, 08h, 28h
		db	 0Ah, 42h, 20h, 41h, 80h, 20h
		db	 41h, 11h,0A8h, 41h, 20h, 02h
		db	 42h, 08h, 08h, 08h, 08h, 41h
		db	 11h,0A0h, 42h,0A0h, 22h, 80h
		db	 42h, 08h, 42h, 11h, 82h, 43h
		db	 28h, 46h,0A8h, 43h, 0Ah, 80h
		db	 02h, 80h, 41h, 82h, 02h, 41h
		db	0A0h, 43h, 28h, 41h, 22h, 80h
		db	 44h,0A0h, 44h, 02h, 80h, 43h
		db	 20h, 41h,0A0h, 20h, 02h, 42h
		db	 08h, 20h, 42h, 20h, 80h, 41h
		db	0A0h, 41h, 20h, 42h, 80h,0A2h
		db	 41h, 20h, 0Eh, 80h, 41h,0A0h
		db	 80h, 42h, 08h,0A8h, 20h, 42h
		db	 0Ah, 42h,0A0h, 80h, 43h, 2Ah
		db	 41h, 02h, 41h, 22h, 41h, 30h
		db	0A0h, 02h, 80h, 42h, 28h, 43h
		db	 03h, 80h, 20h,0A0h, 41h, 80h
		db	 42h, 02h, 41h, 02h, 42h, 80h
		db	 20h,0A0h, 44h, 08h, 42h, 20h
		db	 08h, 02h, 41h,0A0h, 42h, 20h
		db	 80h, 28h, 82h, 41h, 20h, 08h
		db	 42h,0A0h, 02h, 42h, 08h, 02h
		db	 82h, 80h, 44h,0A0h, 41h, 08h
		db	 80h, 41h, 08h, 02h, 42h, 02h
		db	 41h, 20h,0A0h, 41h, 08h, 20h
		db	 02h, 80h, 45h, 20h,0A0h, 08h
		db	 41h, 08h, 80h, 02h, 20h, 41h
		db	 80h, 42h, 80h,0A0h, 44h, 08h
		db	 20h, 41h, 20h, 42h,0A0h,0ACh
		db	 41h, 80h, 41h, 28h, 08h, 80h
		db	 42h, 80h, 02h, 80h,0ACh, 41h
		db	 20h, 41h, 02h, 82h, 20h, 43h
		db	 02h, 80h,0A0h, 41h, 02h, 42h
		db	0A8h, 42h, 08h, 42h,0A0h,0ACh
		db	 80h, 42h, 20h, 0Ah, 80h, 43h
		db	 22h, 20h,0A0h, 43h, 02h, 08h
		db	 80h, 44h, 80h,0A0h, 82h, 43h
		db	 02h, 43h, 02h, 41h, 80h,0A0h
		db	 08h, 41h, 08h, 20h, 88h, 80h
		db	 43h, 02h, 80h,0A0h, 41h, 0Ah
		db	 02h, 88h, 22h, 80h, 41h, 80h
		db	 08h, 41h, 20h,0A8h
		db	'A *"', 8, 'B ', 0Ah, 'A'
		db	 80h, 11h, 47h, 20h, 41h, 02h
		db	 80h, 11h,0A8h, 02h, 22h, 02h
		db	 47h, 11h,0A8h, 42h, 08h, 46h
		db	 80h, 12h, 08h, 41h, 20h, 20h
		db	 44h, 02h, 41h, 11h,0A8h, 41h
		db	 80h, 80h, 88h, 46h, 12h, 43h
		db	 02h, 46h, 11h,0A8h,0A8h, 8Ah
		db	 11h, 88h, 45h, 08h, 11h, 80h
		db	 49h, 20h, 11h, 2Ah, 02h, 80h
		db	 0Ah,0A8h, 45h, 20h,0A8h,0A8h
		db	 41h, 80h, 41h,0A0h, 80h, 44h
		db	 80h,0A8h, 80h, 08h, 80h, 20h
		db	 02h, 80h, 41h, 2Ah, 28h, 2Ah
		db	 41h,0A8h, 42h, 02h, 88h, 0Ah
		db	 42h, 08h, 41h, 0Ah, 80h,0A8h
		db	 41h, 80h, 02h, 41h, 08h, 44h
		db	 02h, 80h,0A8h, 41h, 80h, 42h
		db	 08h, 45h,0A0h,0A8h, 80h, 42h
		db	 02h, 42h, 20h, 43h, 80h,0A8h
		db	0A0h, 42h, 02h, 44h, 22h, 41h
		db	 80h,0A8h, 80h, 42h, 20h, 20h
		db	 43h,0A0h, 41h, 20h,0A8h, 43h
		db	 20h, 20h, 20h, 44h, 20h,0A8h
		db	 43h, 02h, 42h, 20h, 02h, 42h
		db	 20h,0A8h
		db	'A', 0Ah, 'C A', 0Ah, 8, 'A '
		db	0A8h, 41h, 0Ah, 43h, 80h, 08h
		db	 0Ah, 0Ah, 41h, 20h,0A8h, 80h
		db	 41h, 02h, 08h, 42h, 08h, 43h
		db	 80h,0A8h, 80h, 42h, 08h, 46h
		db	0A0h,0A8h, 08h, 44h, 28h, 44h
		db	 20h,0A8h, 45h, 80h, 08h, 42h
		db	 80h, 41h,0A8h, 42h, 80h, 20h
		db	 42h, 20h, 22h, 42h, 20h, 11h
		db	 42h, 80h, 43h, 20h, 28h, 02h
		db	 41h, 80h,0A8h, 43h, 80h, 45h
		db	 82h, 41h,0A8h, 46h, 02h, 80h
		db	 80h, 20h, 41h,0A8h, 0Ah, 42h
		db	 08h, 80h, 80h, 80h, 8Ah, 82h
		db	 80h, 41h,0A8h, 0Ah, 41h, 02h
		db	 20h, 80h, 41h, 80h, 02h, 02h
		db	 02h, 20h,0A8h, 41h, 08h, 41h
		db	0A0h, 28h, 41h, 02h, 41h, 82h
		db	 20h, 41h,0A8h, 08h, 42h, 20h
		db	0A0h, 80h, 42h, 02h, 08h, 20h
		db	0A8h, 08h, 43h, 88h, 41h, 08h
		db	 02h, 41h, 08h, 80h,0A8h, 44h
		db	 08h, 42h, 8Ah, 80h, 22h, 20h
		db	 11h, 43h,0A0h, 0Ah, 41h, 0Ah
		db	 88h, 41h, 28h, 41h, 11h, 80h
		db	 41h, 0Ah, 82h, 20h, 41h, 88h
		db	 20h, 41h, 82h, 41h, 11h,0A8h
		db	 49h, 08h, 11h,0A2h,0A8h, 28h
		db	 28h, 2Ah, 82h, 12h,0A0h, 41h
		db	0A0h, 11h, 0Ah, 80h, 42h, 0Ah
		db	 41h, 0Ah, 20h,0A8h, 41h, 08h
		db	0A8h,0A8h, 02h, 02h, 80h, 43h
		db	 80h, 42h, 08h,0A0h, 8Ah, 80h
		db	 2Ah, 02h,0A2h, 82h, 0Ah, 44h
		db	0A0h, 41h, 2Ah,0C8h, 2Bh,0E2h
		db	0EEh,0BAh,0BAh,0BEh, 11h, 80h
		db	0A0h,0A8h, 43h, 3Ah, 3Ah, 12h
		db	0EAh, 80h, 41h,0A2h, 80h, 42h
		db	 08h, 08h, 42h, 20h,0AEh, 82h
		db	 41h,0A0h, 02h, 80h, 41h,0A0h
		db	 43h, 20h, 0Ah, 02h, 20h,0A2h
		db	 02h, 80h, 41h, 20h, 44h, 0Ah
		db	 42h,0A2h, 41h, 02h, 42h, 20h
		db	 42h, 20h, 42h, 20h,0A2h, 45h
		db	 20h, 41h, 20h, 08h, 08h, 20h
		db	0A2h, 45h, 20h, 43h, 28h, 41h
		db	0A0h, 41h, 82h, 43h, 80h, 08h
		db	 20h, 43h,0A0h, 41h, 82h, 41h
		db	 08h, 41h, 80h, 41h, 82h, 02h
		db	 42h,0A8h, 41h, 03h, 80h, 42h
		db	0A0h, 08h, 80h, 43h, 11h, 41h
		db	 02h, 42h, 82h,0A8h, 43h, 80h
		db	 41h,0A8h, 41h, 23h, 42h, 80h
		db	0A0h, 20h, 80h, 43h,0A8h, 41h
		db	 02h, 45h, 8Eh, 08h, 41h, 20h
		db	0A0h, 02h, 02h, 80h, 41h, 20h
		db	 42h, 0Eh, 80h, 08h, 80h,0A0h
		db	 02h, 02h, 80h, 42h, 80h, 80h
		db	 02h, 80h, 08h, 41h,0A0h, 0Eh
		db	 02h, 80h, 80h, 41h, 80h, 41h
		db	 8Eh, 42h, 80h,0A0h, 08h, 02h
		db	 80h, 41h, 20h, 20h, 41h, 8Eh
		db	 41h, 82h, 20h,0A8h, 08h, 02h
		db	 41h, 22h, 20h, 42h, 0Eh, 41h
		db	 02h, 80h,0A0h, 08h, 02h, 80h
		db	 02h, 41h, 80h, 08h, 0Ah, 41h
		db	 02h, 41h,0A0h, 41h, 0Ah, 80h
		db	 02h, 42h, 08h, 0Eh,0C0h, 08h
		db	 80h,0A0h, 41h, 0Eh, 41h, 82h
		db	 42h, 28h, 0Ah, 80h, 02h, 41h
		db	0A8h, 08h, 0Ah, 41h, 0Bh, 43h
		db	 0Eh, 80h, 28h, 41h,0A8h, 0Ah
		db	 02h, 80h, 0Ah, 80h, 41h, 80h
		db	 3Ah, 41h, 22h, 41h,0A0h, 08h
		db	 8Bh, 80h, 0Bh, 82h, 80h
data_61		db	88h			; Data table (indexed access)
		db	 3Ah, 82h, 88h, 41h,0A0h, 38h
		db	 0Bh, 80h, 0Eh, 0Ah,0EEh, 0Ah
		db	0E2h, 02h, 22h, 41h,0A0h, 28h
		db	 3Ah, 80h,0A8h, 8Bh,0A2h,0A8h
		db	 11h, 80h, 08h, 41h,0A0h, 38h
		db	 22h,0A0h, 3Ah, 03h, 88h,0BAh
		db	0A2h, 20h, 22h, 41h,0A2h, 08h
		db	 3Ah, 80h,0BAh, 88h,0A0h,0CAh
		db	 82h, 88h, 08h, 41h,0A2h, 0Ch
		db	 2Bh, 2Ah, 11h, 0Ah, 2Ah,0E2h
		db	 22h, 88h, 22h, 41h,0A2h, 08h
		db	0ABh, 88h,0E8h, 82h,0A2h,0CAh
		db	 8Ah, 20h, 88h, 41h,0A2h, 38h
		db	 11h, 08h,0EAh, 08h, 11h,0A8h
		db	0A2h, 28h, 02h, 41h,0A0h,0EAh
		db	 28h, 8Eh,0A8h,0A3h,0A8h, 82h
		db	 88h, 88h, 80h, 41h,0A2h, 11h
		db	0A2h, 22h, 22h, 02h,0A2h, 22h
		db	 22h, 22h, 42h,0A2h, 08h, 88h
		db	 0Ah, 82h, 20h, 02h, 08h, 08h
		db	 43h, 00h, 4Ch,0A0h, 43h, 3Ah
		db	0EBh,0EEh,0A0h, 44h,0A0h, 42h
		db	 03h, 13h,0AEh, 44h,0A0h, 41h
		db	0EAh, 8Eh,0A8h, 8Ah,0EAh,0A8h
		db	 8Fh,0A8h, 42h,0A0h, 0Eh, 11h
		db	 3Eh, 22h, 88h,0A8h,0A8h, 3Ah
		db	0A2h, 80h, 41h,0A0h, 3Ah, 28h
		db	 3Ah, 8Eh, 8Ah,0A2h, 11h, 3Ah
		db	0BAh, 20h, 41h,0A0h,0EAh,0A2h
		db	 3Ah, 22h, 11h,0A2h,0A8h, 28h
		db	0ABh, 88h, 41h,0A3h,0A2h, 28h
		db	0E8h,0A3h, 11h,0A8h,0EAh, 08h
		db	 8Ah,0B2h, 41h,0A3h, 11h, 20h
		db	0EAh,0A8h,0EAh,0A3h,0A8h, 8Ah
		db	0ABh,0A2h, 41h,0AEh, 8Ah, 28h
		db	0EAh, 28h,0E8h, 0Eh, 11h, 0Eh
		db	 11h, 08h, 80h,0AEh, 2Eh,0A0h
		db	0EAh,0EAh, 03h,0A3h,0A8h, 8Eh
		db	 11h,0A0h, 80h,0ACh,0AEh,0A8h
		db	0EAh, 11h,0A8h,0EAh, 11h, 0Eh
		db	 8Ah, 88h, 80h,0ACh,0AEh,0A0h
		db	 3Ah, 11h,0A8h,0EAh,0A8h, 3Ah
		db	0BAh,0A8h, 80h,0A0h,0BAh,0A8h
		db	 3Ah, 11h, 23h, 11h,0A2h, 3Ah
		db	 11h, 82h, 41h,0A3h,0EAh, 11h
		db	 3Ah,0AEh, 83h,0A8h,0A8h, 3Ah
		db	 11h, 22h, 41h,0A3h, 11h,0A8h
		db	 8Eh,0BAh, 8Eh,0ABh,0A0h,0EAh
		db	 11h, 82h, 41h,0E2h,0EAh, 11h
		db	 0Eh, 11h, 2Ah, 11h,0A8h,0E8h
		db	 11h, 08h, 41h,0A0h,0EAh, 11h
		db	 8Eh,0A8h,0ABh, 11h, 20h,0EBh
		db	0A8h, 88h, 41h,0E2h, 3Ah, 11h
		db	 23h, 13h, 83h, 11h,0A2h, 20h
		db	 41h,0E0h,0BAh, 11h, 83h, 13h
		db	 23h, 11h,0A8h, 20h, 41h,0E2h
		db	 2Eh,0A2h, 23h, 12h, 88h, 83h
		db	0A8h, 80h, 80h, 41h,0E0h, 8Eh
		db	 88h, 80h,0EAh,0A2h, 22h, 0Eh
		db	0A2h, 20h, 80h, 41h,0A2h, 23h
		db	 42h,0C8h, 80h, 41h, 0Ch, 20h
		db	 02h, 42h,0E0h,0FEh,0BEh,0F3h
		db	0FBh,0EAh,0EEh,0EAh,0EBh,0FAh
		db	0E8h, 41h,0E2h,0FAh, 11h,0A3h
		db	 13h,0AEh, 12h, 88h, 41h,0A0h
		db	0EAh, 11h, 8Eh, 11h,0ABh, 14h
		db	 88h, 41h,0A2h,0EAh, 11h, 8Eh
		db	0A8h, 14h,0EAh,0A8h, 41h,0A0h
		db	0EAh, 11h, 3Ah,0ABh, 12h, 8Ah
		db	 12h, 88h, 41h,0E2h, 11h,0A8h
		db	0EAh, 13h,0BAh, 12h, 08h, 41h
		db	0E0h,0EAh,0A3h, 16h, 88h, 88h
		db	 41h,0E2h, 11h,0A3h, 11h,0A2h
		db	 8Ah, 28h, 22h, 22h, 22h, 08h
		db	 41h,0E2h, 11h, 03h, 80h, 08h
		db	 45h, 08h, 41h,0E2h, 49h, 20h
		db	 41h,0E0h, 88h,0FAh,0EAh,0AEh
		db	0BAh,0AEh,0AFh, 12h, 80h, 41h
		db	0E2h, 23h, 11h,0A8h,0BAh,0BAh
		db	 22h, 41h, 11h,0A8h, 42h,0E0h
		db	 8Eh,0AEh, 8Ah, 11h, 28h, 80h
		db	 2Ah,0A8h, 11h, 80h, 41h,0E2h
		db	 3Ah,0A8h, 82h, 11h,0A2h, 02h
		db	0A8h,0A8h, 11h, 30h, 41h,0A0h
		db	 11h,0A2h, 0Eh, 11h, 88h, 0Ah
		db	 12h,0EAh, 8Ch, 41h,0E2h,0E8h
		db	0A8h, 3Ah, 11h, 20h, 2Ah, 13h
		db	 08h, 41h,0E0h,0EEh, 80h,0EAh
		db	 11h, 80h, 12h,0BAh, 11h, 82h
		db	 41h,0E2h,0EAh, 88h,0EAh,0A8h
		db	 80h, 11h, 0Ah, 11h, 8Ah, 22h
		db	 41h,0A3h,0A2h, 83h, 11h,0A2h
		db	 02h,0A8h,0BAh, 11h,0A8h, 82h
		db	 41h,0E3h, 8Ah, 83h, 11h,0A8h
		db	 02h, 11h,0EAh, 11h, 22h, 02h
		db	 41h,0E3h, 8Bh, 23h, 11h,0A0h
		db	 0Ah, 12h,0A8h, 88h, 02h, 41h
		db	0E3h, 8Ah, 83h, 11h, 88h, 0Ah
		db	 12h,0A2h, 41h, 28h, 41h,0A3h
		db	0EAh,0A3h, 11h,0A0h, 0Ah, 12h
		db	0A8h, 3Eh, 88h, 41h,0A3h, 8Ah
		db	 83h, 11h, 88h, 2Ah,0ABh, 11h
		db	 83h, 80h, 08h, 41h,0E2h, 8Ah
		db	0A0h,0EAh,0A0h, 2Ah, 11h, 2Ah
		db	 0Ch, 28h, 20h, 41h,0E2h, 8Eh
		db	 88h,0EAh, 88h, 8Ah,0BAh, 2Ah
		db	 30h,0EAh, 20h, 41h,0E8h,0CAh
		db	0A0h,0EAh,0A0h, 2Ch,0EAh, 08h
		db	0C2h,0ABh, 20h, 41h,0E0h,0E2h
		db	0A8h, 3Ah,0A8h, 8Ah, 11h, 08h
		db	 82h,0BFh, 20h, 41h,0E8h,0A2h
		db	0A8h, 3Eh, 11h, 22h,0A0h, 0Ah
		db	 33h,0EFh, 08h, 41h,0A0h, 83h
		db	0A8h, 0Eh, 12h, 88h, 2Ah, 2Ah
		db	0AEh, 88h, 41h,0E8h, 3Eh,0EAh
		db	 0Bh, 2Ah, 22h, 20h, 2Ah, 8Eh
		db	0A2h, 82h, 41h,0E2h, 38h,0A8h
		db	 0Ah,0C8h, 88h, 80h, 11h,0A2h
		db	0A8h, 82h, 41h,0E0h,0E2h,0BAh
		db	 0Ah,0B0h, 20h, 02h, 11h,0A8h
		db	0F2h, 20h, 80h,0A3h, 8Ah, 2Ah
		db	 0Ah,0AFh, 41h, 0Ah, 11h,0BAh
		db	 08h, 88h, 80h,0E3h, 8Ch, 38h
		db	 8Ah, 83h,0FAh, 12h, 8Ah,0A2h
		db	 22h, 20h,0E2h,0A3h, 11h, 0Ah
		db	 0Eh, 08h, 13h, 88h,0C8h, 20h
		db	0E2h, 11h, 88h, 23h, 38h,0FAh
		db	 2Ah,0EAh, 11h,0A0h,0E2h, 08h
		db	0E0h,0A2h, 20h, 33h, 33h, 08h
		db	 2Ah, 12h, 88h,0A8h, 80h,0E2h
		db	 20h, 03h, 83h, 3Bh, 08h, 2Ah
		db	0EAh, 11h, 20h, 11h, 41h,0E8h
		db	 8Eh,0CAh, 80h,0F2h,0A0h, 2Ah
		db	 2Ah, 11h, 80h,0E8h, 80h,0E2h
		db	 2Ah,0A2h, 23h,0ECh, 41h, 13h
		db	 41h, 88h, 41h,0EAh,0EBh,0A3h
		db	0A3h, 2Eh,0A8h, 13h, 80h, 80h
		db	 41h,0EBh, 80h,0A0h,0E0h,0A8h
		db	 02h, 13h, 82h, 42h,0EEh, 82h
		db	0A0h,0A8h, 2Eh,0A8h, 13h,0A2h
		db	 88h, 41h,0EEh, 0Ah,0A8h,0A8h
		db	0BAh, 11h, 2Ah, 12h, 82h,0A0h
		db	41h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_9		proc	near
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
;*		and	byte ptr ds:data_87e[bx+si],0A8h
		db	 82h,0A0h,0A8h, 3Ah,0A8h	;  Fixup - byte match
		sub	ch,byte ptr data_29
		test	al,41h			; 'A'
		lodsb				; String [si] to al
		adc	ds:data_162e[bx+si],cx
		mov	al,ds:data_133e
		adc	ss:data_99e[bp+si],cx
		jmp	short $+0Ch
sub_9		endp

			                        ;* No entry point to code
		inc	cx
		test	al,3Ah			; ':'
		test	al,11h
		mov	dl,[bx+di]
		or	ch,ds:data_174e[bx+si]
		db	0C0h, 03h,0A0h,0BAh,0A0h, 2Ah
		db	 8Ah,0AEh, 8Ah,0A0h, 41h,0EAh
		db	0BEh,0BAh,0A8h, 3Ah,0A8h, 11h
		db	 2Ah,0A2h, 0Ah, 80h, 41h,0ABh
		db	0EAh, 11h,0A0h,0BAh,0A0h,0EEh
		db	 12h, 82h, 8Ah, 80h,0EEh,0A0h
		db	 2Ah, 88h, 3Ah, 88h,0A2h, 11h
		db	 2Ah,0A2h,0A8h, 20h,0FAh, 8Ah
		db	0CAh,0A0h,0BAh,0A0h,0EAh, 12h
		db	 82h,0A2h, 20h,0BAh, 2Ah,0BAh
		db	 80h, 3Ah, 88h, 13h,0A0h,0A8h
		db	 20h,0EAh, 3Ah,0EAh, 22h,0BAh
		db	 20h, 11h,0A2h, 11h,0A8h,0A0h
		db	 80h,0EAh, 8Fh,0A8h, 82h, 3Ah
		db	 80h, 8Ah, 13h, 28h, 80h,0EAh
		db	 11h,0A2h, 08h,0B2h, 20h, 88h
		db	 12h,0A2h, 20h, 80h,0B2h,0A8h
		db	 88h, 02h, 28h, 0Ah, 30h, 08h
		db	 11h, 8Ah, 82h, 41h,0FCh, 02h
		db	 41h, 08h, 12h, 8Eh, 80h, 22h
		db	0A2h, 02h, 41h,0E3h,0C0h, 03h
		db	 22h,0A2h, 11h,0A0h, 3Bh, 41h
		db	 88h, 82h, 41h, 88h, 88h, 88h
		db	 8Ah, 11h, 8Ah, 88h, 80h,0E8h
		db	 41h, 08h, 41h,0E2h, 2Fh,0FFh
		db	0FFh, 0Ah, 11h,0A2h, 22h, 03h
		db	0A0h, 08h, 41h,0C8h,0FAh, 12h
		db	0A0h,0A2h, 2Ah, 88h, 80h, 0Ah
		db	0A0h, 41h,0E3h,0AEh, 2Eh,0BAh
		db	 2Ah, 2Ah, 11h,0A2h, 20h, 43h
		db	0CEh,0EAh, 28h,0A8h,0A8h, 8Ah
		db	0BFh,0E8h, 88h, 43h, 2Ah,0A8h
		db	0A8h,0A8h, 11h, 0Ah,0EAh,0BAh
		db	 22h, 43h,0BAh, 8Ah,0A8h,0A8h
		db	 11h,0A3h, 11h, 20h, 88h, 43h
		db	0FAh, 2Ah,0A8h, 12h, 83h, 11h
		db	 82h, 2Fh, 03h,0F0h, 41h,0FAh
		db	 2Ah,0A8h, 12h,0A3h, 11h, 23h
		db	0BAh,0A2h,0A8h, 41h,0FAh, 2Ah
		db	 11h,0AEh, 11h, 03h,0A2h, 02h
		db	0EAh, 88h,0EAh, 41h,0FAh, 2Ch
		db	 11h,0A2h,0AEh, 22h, 28h, 0Ah
		db	 2Ah,0A0h, 88h, 41h,0FAh, 14h
		db	 03h, 80h, 28h, 2Ah, 80h, 8Ah
		db	 41h,0FAh, 11h,0A8h, 11h,0A8h
		db	0A2h,0C0h, 80h, 22h, 20h, 20h
		db	 41h,0BAh,0ABh, 11h,0A2h, 11h
		db	 82h,0B0h, 20h,0B8h, 02h, 42h
		db	0BAh,0A8h, 11h,0E2h, 11h, 82h
		db	0ACh, 08h,0A0h, 08h, 42h,0BAh
		db	 11h,0ABh, 11h,0A8h, 82h,0ABh
		db	0C0h, 22h, 22h, 42h,0BAh, 12h
		db	 8Ah,0A2h, 20h, 11h,0BFh, 44h
		db	0BAh, 13h,0A8h, 02h, 12h,0FFh
		db	0FFh,0FFh,0C0h,0BAh, 11h, 82h
		db	 20h, 22h, 41h, 11h,0A2h, 13h
		db	 20h,0BAh, 20h, 43h, 02h, 2Ah
		db	 8Ah, 2Ah, 12h, 20h,0BFh,0FFh
		db	0BFh,0EBh,0EEh,0B8h, 8Ah, 8Ah
		db	 11h,0A2h, 11h, 20h,0EAh,0BAh
		db	0BAh, 11h,0A8h,0E8h, 2Ah,0BAh
		db	 11h,0A2h, 11h, 20h,0EAh,0AFh
		db	0EAh, 8Ah,0A8h,0E0h, 8Ah, 12h
		db	 8Ah, 28h, 20h,0EAh, 11h, 2Ah
		db	 11h, 83h, 88h, 2Ah, 12h, 8Ah
		db	0EAh, 20h,0E2h, 8Ah, 2Bh, 11h
		db	 3Ah,0A0h, 8Ah, 13h,0A8h, 20h
		db	0E0h, 2Ah, 28h,0A8h,0EAh, 88h
		db	 2Ah, 8Ah,0A2h, 11h,0A2h, 20h
		db	0E3h, 11h, 2Ah, 80h,0EAh,0A0h
		db	 8Ah, 8Ah,0AEh, 11h,0A8h, 20h
		db	0EAh, 11h, 28h, 38h,0EAh, 88h
		db	 2Ah, 2Ah, 12h,0A2h, 20h,0EAh
		db	0A8h,0A3h, 12h,0A0h, 8Ah, 13h
		db	0A8h, 20h,0EAh, 14h,0A8h, 14h
		db	0A2h, 20h,0EAh, 14h,0A8h, 14h
		db	0A8h, 20h,0C0h, 44h, 02h, 14h
		db	0A2h, 20h,0EAh, 11h,0AEh, 12h
		db	0A2h, 12h, 2Ah, 11h,0A8h, 20h
		db	0B2h,0BAh, 2Ah, 2Bh, 8Ah,0A2h
		db	 12h, 2Ah, 8Ah,0A2h, 20h,0B8h
		db	 11h, 2Ah, 11h, 2Ah,0A2h, 14h
		db	 28h, 20h,0BCh,0AEh, 2Ah, 2Ah
		db	 11h,0A2h, 14h,0A2h, 20h,0B8h
		db	 11h, 2Ah,0EAh, 11h,0A2h,0A8h
		db	 11h,0A8h,0A2h,0A8h, 20h,0FAh
		db	0A8h, 13h,0A2h,0A2h, 11h,0A8h
		db	 11h,0A2h, 20h,0BAh,0A8h, 12h
		db	 8Ah,0A2h, 13h, 2Ah,0A8h, 20h
		db	0BAh,0ABh, 12h,0BAh,0A2h, 11h
		db	0A2h,0AEh, 2Ah, 22h, 20h,0EAh
		db	 14h, 02h, 11h,0A2h,0AEh, 2Ah
		db	 88h, 20h,0EAh, 13h,0A8h,0A2h
		db	 11h,0E2h, 11h, 2Ah, 20h, 20h
		db	 14h,0A8h,0B2h, 2Ah, 11h, 88h
		db	 88h, 88h, 20h,0EAh, 13h, 82h
		db	0B2h, 8Ah,0A8h, 43h, 20h,0EAh
		db	 13h, 2Bh,0C3h, 11h, 45h,0FEh
		db	0FBh,0AFh,0A8h, 41h, 02h,0A0h
		db	 02h, 02h, 43h,0EAh, 8Ah, 12h
		db	0A2h, 42h, 11h,0A8h, 88h, 42h
		db	 8Ah, 11h, 2Ah, 11h, 88h, 0Bh
		db	0FFh,0FFh, 0Fh,0FFh,0C0h, 41h
		db	0CAh,0A8h, 82h, 22h, 20h, 13h
		db	 8Eh, 11h,0A8h, 41h,0C2h, 80h
		db	 43h, 2Ah, 11h,0A2h, 8Eh, 12h
		db	 41h, 80h,0EAh, 13h, 82h, 11h
		db	0A8h, 0Eh, 12h, 41h,0C3h, 11h
		db	0EAh, 12h,0A8h, 12h, 8Eh, 11h
		db	0A2h, 41h,0C3h,0AEh, 12h,0ABh
		db	 11h, 2Ah, 11h, 8Eh, 12h, 41h
		db	0CEh, 13h,0A8h,0EAh, 2Ah, 11h
		db	 8Eh, 12h, 41h,0CAh, 11h,0ABh
		db	 12h, 3Ah, 8Ah, 11h, 8Eh,0CAh
		db	 11h, 41h,0FAh, 8Ah, 11h,0A8h
		db	 11h, 3Ah, 8Ah, 11h, 8Eh,0BAh
		db	 11h, 41h,0FBh,0A2h, 11h, 2Ah
		db	 11h, 32h, 8Ah, 11h, 8Eh, 12h
		db	 41h,0FAh, 8Ch,0A3h,0A8h,0EAh
		db	 3Ah, 8Ah, 11h, 8Eh, 12h, 41h
		db	0BAh, 8Ch,0A3h,0A8h,0EAh, 32h
		db	 8Ah, 11h, 0Eh, 12h, 41h,0BAh
		db	 8Eh,0A3h,0A8h,0E8h, 3Ah, 0Ah
		db	0ABh, 8Eh, 11h, 8Ah, 41h,0FAh
		db	 0Eh,0A3h,0A0h,0E2h, 0Eh, 8Ah
		db	0ABh, 8Eh, 12h, 41h,0F2h, 8Eh
		db	 83h, 28h,0EAh, 41h, 3Ah,0ABh
		db	 8Fh, 12h, 41h,0BAh, 0Ch,0A3h
		db	0A0h,0C8h, 20h,0A8h, 11h,0CEh
		db	0EAh, 11h, 41h,0FAh, 0Ch,0A3h
		db	 28h,0CAh, 2Ah,0A2h, 11h,0CEh
		db	0EAh, 11h, 41h,0F2h, 8Eh, 23h
		db	 28h,0E8h, 0Eh,0B2h, 11h, 8Eh
		db	0BAh, 11h, 41h,0F8h, 8Ch,0A3h
		db	 88h,0CAh, 0Ch, 0Ch, 11h, 8Eh
		db	0BAh, 11h, 41h,0B2h, 8Ch, 83h
		db	 28h,0CAh, 0Eh,0CAh, 2Ah, 8Eh
		db	0BAh, 11h, 41h,0F0h, 0Eh, 03h
		db	 08h,0C2h, 0Eh,0B3h, 2Ah, 8Eh
		db	0EAh, 11h, 41h,0FCh, 2Bh, 0Eh
		db	0C2h,0B0h, 8Ch, 11h,0CAh, 8Fh
		db	 12h, 41h,0BAh, 11h, 8Eh, 12h
		db	 8Eh, 12h, 8Ch, 12h, 41h,0BAh
		db	 11h, 8Ch, 12h, 8Ch, 12h, 8Eh
		db	 12h, 41h,0F2h, 11h, 8Eh, 12h
		db	 8Ch, 12h, 8Eh, 11h,0A8h, 41h
		db	0FAh, 11h, 8Ch, 12h, 8Eh, 12h
		db	 8Ch, 11h,0A8h, 41h,0F2h, 11h
		db	 8Ch, 12h, 8Ch, 12h, 8Ch, 8Ah
		db	0A8h, 41h,0F8h, 11h, 8Eh, 12h
		db	 8Ch, 2Ah, 11h, 8Eh, 11h,0A2h
		db	 41h,0F0h, 2Ah, 8Ch, 22h, 11h
		db	 8Ch,0A2h, 11h, 8Ch, 82h, 20h
		db	 41h,0F0h, 82h, 8Ch, 08h, 22h
		db	 8Ch, 08h, 82h,0BCh, 20h, 42h
		db	0C8h, 80h, 4Ah,0E2h, 3Ah, 17h
		db	 80h, 42h,0CBh,0EAh, 17h,0A8h
		db	 82h, 41h,0EEh, 19h, 20h, 80h
		db	0BAh, 15h,0A2h, 82h, 88h, 88h
		db	 80h, 41h,0FFh,0FFh,0EBh, 3Fh
		db	0FFh,0BBh,0BAh,0EBh,0EAh,0FAh
		db	 11h, 80h,0FAh, 11h,0BAh, 8Fh
		db	 11h,0E8h,0E2h,0A2h,0ABh, 12h
		db	 80h,0BAh,0BAh,0A8h, 8Ah, 11h
		db	0A2h, 12h, 8Ah,0B8h, 11h, 41h
		db	0BAh, 11h, 2Ah,0A2h,0E8h, 13h
		db	 8Ah, 11h,0EAh, 80h,0FBh, 8Ah
		db	 12h,0E2h, 14h,0A2h, 8Ah, 41h
		db	0FBh, 8Ah, 11h,0A6h,0A2h, 15h
		db	0EAh, 80h,0FEh, 8Ah, 11h,0AFh
		db	0A2h, 15h, 2Ah, 80h,0FAh, 8Ah
		db	 11h,0AEh,0E2h, 14h,0AEh, 11h
		db	 80h,0BEh, 11h,0A8h,0AEh,0A2h
		db	 14h,0AEh,0A0h, 41h,0FAh, 11h
		db	0A8h,0E6h, 16h, 8Eh, 41h,0EAh
		db	 11h,0AEh, 0Eh, 15h,0BAh, 8Ah
		db	 41h,0C2h, 11h,0A8h,0EAh, 15h
		db	 3Ah,0A8h, 80h,0CEh, 11h,0AEh
		db	 11h, 0Ah, 13h,0A8h, 8Eh, 11h
		db	 41h,0CAh, 12h,0A8h,0A2h, 11h
		db	0A0h,0ABh, 8Ah,0A3h,0A8h, 80h
		db	0BAh, 12h, 28h,0AEh, 11h, 0Bh
		db	 11h,0BAh,0A8h,0EAh, 41h,0BAh
		db	0A8h, 11h, 2Ah, 3Ah,0A8h,0ABh
		db	 12h,0A8h,0E8h, 41h,0BAh,0B0h
		db	0A2h, 2Ah, 11h,0A0h,0AEh, 11h
		db	0B8h,0A8h, 11h, 41h,0FAh,0A2h
		db	0A2h, 2Ah, 11h,0A2h,0AEh, 11h
		db	 88h, 11h, 38h, 80h,0CEh,0A2h
		db	0A8h, 12h,0A8h,0FAh, 11h, 88h
		db	 11h, 3Ah, 41h,0FAh, 12h, 2Ah
		db	 11h, 2Ah, 12h,0A8h,0A8h,0E8h
		db	 41h,0BAh, 11h, 8Ah, 12h, 2Ah
		db	 12h,0B8h, 11h,0A2h, 41h,0BAh
		db	 2Ah,0B8h, 12h, 2Ah, 13h, 2Ah
		db	 88h, 41h,0CAh, 2Ah,0A8h, 11h
		db	0ABh, 13h,0BAh, 2Ah,0A0h, 41h
		db	0CAh, 22h, 11h, 2Ah, 13h, 82h
		db	 28h, 28h, 88h, 41h,0BAh, 20h
		db	0AEh, 2Ah,0ABh, 8Ah, 8Ah, 88h
		db	0EAh, 2Ah, 20h, 41h,0FAh,0E2h
		db	0AEh, 2Ah,0AEh, 0Ah,0EEh
data_62		dw	882Ah			; Data table (indexed access)
data_63		dw	8808h			; Data table (indexed access)
		db	 41h,0FAh, 22h,0EAh, 0Ah,0A8h
		db	 8Bh,0A2h,0A8h, 11h, 41h, 20h
		db	 41h,0FAh,0E2h, 11h, 88h, 3Ah
		db	 03h, 88h,0BAh, 88h, 80h, 88h
		db	 41h,0FAh, 22h,0EAh
		db	8
data_64		dw	883Ah			; Data table (indexed access)
data_65		dw	0CAA0h			; Data table (indexed access)
data_66		db	0Ah			; Data table (indexed access)
		db	 20h, 42h,0BAh
data_67		dw	0ACB2h			; Data table (indexed access)
		db	0A0h, 11h, 0Ah, 28h,0E2h, 0Ah
		db	 20h, 88h, 41h,0BAh,0A0h,0AEh
		db	 20h,0E8h, 82h, 82h,0CAh, 28h
		db	 82h, 42h,0FAh,0E0h, 28h, 20h
		db	0EAh, 08h, 8Ah,0A8h, 88h,0A0h
		db	 08h, 41h,0BBh,0A8h, 22h, 38h
		db	0A8h,0A3h, 08h, 82h, 20h, 22h
		db	 42h,0BAh, 11h, 88h, 88h, 22h
		db	 02h, 02h, 22h, 80h, 88h
data_68		db	42h			; Data table (indexed access)
		db	0F8h, 22h, 20h, 28h, 82h, 20h
		db	 02h, 08h, 20h, 43h, 00h, 1Ch
		db	 0Ah, 13h,0BAh,0EBh,0EEh, 15h
		db	 0Ah, 12h,0ABh, 13h,0AEh, 14h
		db	 0Ah, 11h,0EAh,0AEh,0A8h, 8Ah
		db	0EAh,0A8h,0AFh
data_69		db	13h			; Data table (indexed access)
		db	 0Ah,0AEh, 11h, 3Eh, 20h, 88h
		db	0A8h, 41h, 3Ah,0A2h, 12h
data_70		db	0Ah
		db	0BAh, 28h, 3Ah, 80h, 80h, 20h
		db	 20h, 3Ah,0BAh, 2Ah, 11h, 0Ah
		db	0EAh,0A2h, 3Ah, 42h, 20h, 20h
		db	 28h,0ABh, 8Ah, 11h, 08h,0A2h
		db	 08h,0E8h, 42h, 20h, 41h, 08h
		db	 82h,0B2h, 11h, 08h,0A2h, 41h
		db	0E0h, 44h, 88h, 83h,0A2h, 11h
		db	 41h, 82h, 28h, 46h, 02h, 08h
		db	 11h, 42h, 20h, 45h, 80h, 02h
		db	 41h, 11h, 41h, 20h, 88h, 41h
		db	 20h, 42h, 82h, 42h, 08h, 11h
		db	 41h, 20h, 41h, 02h, 02h, 42h
		db	 88h, 08h, 02h, 08h, 11h, 08h
		db	 80h, 88h, 41h, 0Ah, 42h, 02h
		db	 08h, 41h, 02h, 11h, 08h, 02h
		db	 82h, 02h, 2Eh, 80h, 20h, 08h
		db	 08h,0A0h, 22h, 11h, 08h, 42h
		db	 80h, 3Ah, 80h, 41h, 20h, 20h
		db	0A0h, 02h, 11h, 41h, 02h, 88h
		db	 41h, 2Ah, 42h, 28h, 20h, 41h
		db	 0Ah, 11h, 41h, 20h, 80h, 41h
		db	 88h, 03h, 80h, 20h, 20h, 41h
		db	 8Ah, 11h, 41h, 08h, 20h, 20h
		db	 08h, 02h, 80h, 80h, 80h, 02h
		db	 2Ah, 11h, 41h, 88h, 41h, 80h
		db	 41h, 80h, 02h, 20h, 88h, 08h
		db	 2Ah, 11h, 02h, 22h, 80h, 20h
		db	 0Ah, 41h, 08h, 80h, 41h, 80h
		db	 12h, 41h, 82h, 88h, 80h, 41h
		db	 22h, 22h, 02h,0A2h, 20h, 12h
		db	 02h, 20h, 43h, 80h, 42h, 20h
		db	 02h, 12h, 41h,0FEh,0BEh,0F0h
		db	0FBh,0EAh,0EEh,0EAh,0EBh,0FAh
		db	0EAh, 11h, 02h, 0Ah, 11h,0A0h
		db	0A0h, 11h,0A0h, 2Eh, 41h, 2Ah
		db	 8Ah, 11h, 41h, 2Ah, 20h, 80h
		db	 80h, 0Bh, 80h, 28h, 41h, 0Ah
		db	 0Ah, 11h, 41h, 20h, 82h, 80h
		db	 80h, 02h, 41h, 08h, 41h, 08h
		db	 0Ah, 11h, 42h, 82h, 42h, 02h
		db	 44h, 0Ah, 11h, 45h, 02h, 44h
		db	 0Ah, 11h, 4Ah, 0Ah, 11h, 4Ah
		db	 0Ah, 11h, 02h, 49h, 0Ah, 11h
		db	 02h, 49h, 2Ah, 11h, 41h, 88h
		db	0FAh,0EAh,0AEh,0BAh,0AEh,0AFh
		db	 14h, 02h, 03h, 11h,0A8h, 3Ah
		db	0BAh, 22h, 41h,0A2h, 13h, 41h
		db	 0Eh,0AEh, 80h, 0Ah, 28h, 80h
		db	 41h, 08h, 02h, 12h, 02h, 3Ah
		db	0A8h, 41h, 0Ah, 43h, 08h, 41h
		db	 3Ah, 11h, 41h, 2Ah,0A0h, 41h
		db	 02h, 44h,0E0h, 0Eh, 11h, 41h
		db	0E8h,0A8h, 43h, 02h, 41h, 08h
		db	0A0h, 0Ah, 11h, 41h,0ECh, 80h
		db	 41h, 80h, 43h, 38h, 42h, 11h
		db	 41h,0EAh, 80h, 02h, 47h, 11h
		db	 03h,0A0h, 80h, 48h, 11h, 03h
		db	 80h, 80h, 45h, 80h, 42h, 11h
		db	 03h, 83h, 41h, 0Ah, 42h, 20h
		db	 44h, 11h, 03h, 82h, 41h, 8Ah
		db	 43h, 08h, 42h, 02h, 11h, 03h
		db	0C2h, 41h, 80h
data_71		dw	241h			; Data table (indexed access)
		db	 44h, 02h, 11h, 03h, 44h, 0Ah
		db	 80h, 43h, 02h, 11h, 43h, 0Ah
		db	 41h, 02h, 02h, 42h, 38h, 0Ah
		db	 11h, 45h, 80h
		db	3Ah
data_72		db	42h
		db	 3Ah, 0Ah, 11h, 45h, 2Ch,0E8h
		db	 41h, 03h
data_73		dw	0AEFh			; Data table (indexed access)
		db	 11h, 45h, 0Ah,0A0h, 41h, 02h
		db	0BFh, 0Ah, 11h, 08h, 41h, 08h
		db	 41h,0A0h, 44h, 0Fh, 02h, 11h
		db	 41h, 80h,0A8h, 41h, 20h, 45h
		db	 02h, 11h, 08h, 41h, 2Ah, 48h
		db	 11h, 02h, 41h, 88h, 44h, 0Ah
		db	 43h, 11h, 41h, 02h, 8Ah, 48h
		db	 2Ah, 41h, 0Ah, 02h, 02h, 47h
		db	 2Ah, 43h, 8Ah, 47h, 0Ah, 42h
		db	 0Ah, 08h, 42h, 08h, 02h
		db	 43h, 0Ah
data_74		db	42h			; Data table (indexed access)
		db	 08h, 20h, 43h,0E0h, 08h, 42h
		db	 02h, 47h,0A0h
data_75		dw	4208h			; Data table (indexed access)
		db	 82h, 02h, 49h, 02h, 41h, 08h
		db	 80h, 44h, 08h, 02h, 42h, 28h
		db	 80h, 02h, 49h, 88h, 02h, 41h
		db	 08h, 43h,0A8h, 41h, 80h, 20h
		db	 42h, 0Ah, 47h, 80h, 20h, 42h
		db	 11h, 41h, 82h, 20h, 42h,0A8h
		db	 45h, 11h, 41h, 0Ah, 28h, 42h
		db	 2Ah, 43h, 02h, 41h, 11h, 42h
		db	 20h, 41h, 02h, 08h, 02h, 42h
		db	 08h, 41h, 2Ah, 41h,0A0h, 88h
		db	 41h, 02h, 41h, 02h, 80h, 41h
		db	 08h, 41h, 2Ah, 41h, 0Ah, 43h
		db	 88h, 82h, 80h, 41h, 08h, 41h
		db	 2Ah, 08h, 44h, 80h, 41h, 80h
		db	 41h, 08h, 41h, 11h, 2Ah, 80h
		db	 44h, 80h, 42h, 08h, 02h, 11h
		db	 28h, 02h, 80h, 41h, 02h, 42h
		db	 02h, 80h, 02h, 02h, 11h, 20h
		db	 20h, 22h, 80h, 02h, 41h, 80h
		db	 02h, 41h, 02h, 41h, 0Ah, 41h
		db	 80h, 02h, 80h, 02h, 41h,0C0h
		db	 42h, 02h, 41h, 2Ah, 02h, 0Ah
		db	 80h, 41h, 02h, 41h, 80h, 44h
		db	 2Ah, 41h, 0Ah, 02h, 20h, 08h
		db	 20h, 80h, 44h, 11h, 42h, 08h
		db	 80h, 0Ah, 80h, 80h, 41h, 02h
		db	 41h, 20h, 11h, 02h, 41h, 02h
		db	 41h, 02h, 20h, 80h, 41h, 02h
		db	 41h, 20h, 11h, 41h,0A8h, 88h
		db	 41h, 08h, 0Ah, 42h, 8Ah, 02h
		db	 82h, 11h, 41h, 02h, 42h, 02h
		db	 11h, 80h, 41h, 22h,0A2h, 02h
		db	 11h, 46h,0A0h, 42h, 88h, 82h
		db	 11h, 08h, 88h, 88h, 8Ah,0A0h
		db	 41h, 08h, 80h, 42h, 0Ah, 11h
		db	 22h, 2Ch,0F0h,0FCh, 43h, 22h
		db	 41h,0A0h, 0Ah, 11h, 08h, 0Ah
		db	 12h,0A0h, 41h, 02h, 41h, 80h
		db	 2Ah, 12h, 23h,0AEh, 0Eh,0BAh
		db	 42h, 02h, 41h, 20h, 2Ah, 12h
		db	 0Eh,0EAh, 08h, 28h, 44h, 08h
		db	 2Ah, 12h, 2Ah,0A8h, 08h, 28h
		db	 44h, 22h, 2Ah, 12h, 8Ah, 80h
		db	 08h, 28h, 43h, 20h, 08h, 2Ah
		db	 12h, 0Ah, 41h, 08h, 44h, 80h
		db	 41h, 08h, 02h, 11h, 0Ah, 41h
		db	 08h, 43h, 02h, 20h, 43h, 11h
		db	 0Ah, 41h, 08h, 41h, 02h, 41h
		db	 22h, 43h, 02h, 2Ah, 0Ah, 0Ch
		db	 42h, 0Eh, 41h, 28h, 02h, 20h
		db	0A0h
		db	8, '*', 0Ah, 'C', 0Ah, 'B(', 0Ah
		db	 80h, 8Ah, 2Ah, 42h, 08h, 41h
		db	 08h, 02h
		db	'B"  *C A'
		db	 02h, 80h, 20h, 08h, 42h, 11h
		db	 41h, 20h, 41h,0E0h, 41h, 02h
		db	0A0h, 43h, 02h, 11h, 41h, 20h
		db	 03h,0A0h, 80h, 02h,0A8h, 43h
		db	 02h, 11h, 41h, 20h, 02h, 80h
		db	 42h, 11h, 80h, 43h, 11h, 45h
		db	 02h, 8Ah, 11h, 43h, 2Ah, 46h
		db	 80h,0A2h, 13h, 0Ah, 45h, 02h
		db	 20h, 82h, 2Ah, 8Ah, 11h, 0Ah
		db	 03h,0FFh,0BFh,0EBh,0EEh,0B8h
		db	 80h, 80h, 02h,0A2h, 8Ah, 0Ah
		db	 2Ah,0B2h,0B2h, 11h,0A8h, 28h
		db	 20h, 41h, 02h,0A0h, 82h, 0Ah
		db	 2Ah,0AFh,0EAh, 8Ah,0A8h, 41h
		db	 80h, 41h, 02h, 80h, 41h, 0Ah
		db	 2Ah, 11h, 41h, 02h, 80h, 43h
		db	 82h, 80h, 41h, 0Ah, 22h, 8Ah
		db	 41h, 02h, 42h, 80h, 41h, 80h
		db	 42h, 0Ah, 20h, 0Ah, 44h, 02h
		db	 80h, 43h, 0Ah, 20h, 0Ah, 44h
		db	 02h, 80h, 41h, 02h, 41h, 0Ah
		db	 20h, 0Ah, 47h, 80h, 41h, 0Ah
		db	 41h, 08h, 47h, 80h
		db	'A', 0Ah, 'K', 0Ah, 'K', 0Ah, 'K', 0Ah
		db	'*'
		db	 11h,0AEh, 12h,0A0h, 41h, 0Ah
		db	 43h, 0Ah, 02h,0BAh, 0Ah, 0Bh
		db	 82h,0A0h, 41h, 0Ah, 41h, 80h
		db	 02h, 0Ah, 08h, 2Ah, 41h, 02h
		db	 41h, 20h, 45h, 0Ah, 0Ch, 0Eh
		db	 43h, 20h, 08h, 43h, 02h
		db	0Ah, 8, 0Ah, 'C (A', 8, 'A(', 0Ah
		db	8, 8, 'D A', 8, 'A"', 0Ah, 8, 'G', 0Ah
		db	'A', 8, 0Ah, 8, 'F'
		db	0A0h, 0Eh, 41h, 02h, 0Ah, 20h
		db	 46h,0A0h, 0Eh, 41h, 88h, 0Ah
		db	 28h, 41h, 02h, 80h, 41h, 02h
		db	 41h,0E0h, 0Ah, 0Ah, 20h, 0Ah
		db	 28h, 08h, 02h, 80h, 28h, 02h
		db	 02h, 11h, 88h, 88h, 88h, 0Ah
		db	 28h, 42h, 0Ah, 80h, 02h, 8Ah
		db	0A8h, 43h, 0Ah, 2Ah, 80h, 12h
		db	 28h, 03h, 11h, 44h, 2Ah, 45h
		db	 02h,0A0h, 02h, 02h, 41h, 2Ah
		db	 11h, 20h, 41h, 0Ah, 11h,0A2h
		db	 42h, 11h,0A8h, 88h, 2Ah, 11h
		db	 08h, 43h, 88h, 45h, 02h, 11h
		db	 08h, 42h, 02h, 20h,0A0h, 2Ah
		db	0A0h, 02h, 80h,0A8h, 11h, 02h
		db	 44h, 02h, 0Ah, 41h, 02h, 41h
		db	 2Ah, 2Ah, 41h,0E8h, 28h,0A8h
		db	 41h, 02h, 80h, 08h, 02h, 20h
		db	 02h, 2Ah, 03h,0A0h, 41h, 20h
		db	 42h,0A0h, 22h, 80h, 42h, 2Ah
		db	 03h, 80h, 44h, 20h, 41h, 80h
		db	 02h, 41h, 2Ah, 0Eh, 45h, 20h
		db	 42h, 02h, 41h, 2Ah, 02h, 43h
		db	 08h, 42h, 80h, 42h, 02h, 2Ah
		db	 02h, 41h, 88h, 44h, 80h
		db	'B', 0Ah, '*', 8, 'A', 0Ah, 'C', 8
		db	8, 'B'
		db	2
		db	'*', 8, 'D', 8, 8, 8, 'C*', 8, 'B'
		db	 80h, 08h, 42h, 80h, 43h, 2Ah
		db	 08h, 41h, 20h,0A0h, 41h, 08h
		db	 43h,0A0h, 41h, 2Ah, 08h, 41h
		db	0A0h,0A0h, 20h, 02h, 43h,0A0h
		db	 41h, 2Ah, 02h, 43h, 20h, 42h
		db	 20h, 80h, 41h, 02h, 2Ah, 0Ah
		db	 46h, 20h, 42h, 02h
		db	'*', 8, 'D(D *A'
		db	 02h, 42h, 20h, 02h, 45h, 2Ah
		db	 08h, 42h, 88h, 08h, 42h, 08h
		db	 02h, 42h, 2Ah, 02h, 41h, 80h
		db	 28h, 08h, 43h, 02h, 42h, 11h
		db	 41h, 02h, 45h, 02h, 43h, 2Ah
		db	 41h, 08h, 02h, 02h, 80h, 46h
		db	 2Ah, 41h, 02h, 82h,0A2h, 02h
		db	 02h, 02h, 20h, 42h,0A0h, 2Ah
		db	 08h, 80h, 80h, 80h, 02h, 41h
		db	 02h, 08h, 80h, 41h,0A0h, 2Ah
		db	 41h, 08h, 82h, 41h, 80h
		db	'A(', 0Ah, 'A A*', 8, ' '
		db	 80h, 42h, 02h, 0Ah, 08h, 42h
		db	 20h, 2Ah, 02h, 20h, 41h, 80h
		db	 20h, 41h, 22h, 43h, 20h, 2Ah
		db	 08h, 88h, 02h,0A2h
		db	'B D*A(A"'
		db	0A0h, 41h,0A0h, 0Ah, 43h, 2Ah
		db	 41h, 82h, 41h, 08h, 22h, 41h
		db	 08h, 82h, 80h, 42h, 11h, 4Bh
		db	 11h, 41h, 0Ah,0A0h,0A0h,0A0h
		db	 11h, 0Ah,0A8h, 11h, 80h, 02h
		db	 11h, 41h, 2Ah, 43h, 28h, 41h
		db	 28h, 82h,0A0h, 41h, 11h, 02h
		db	0A0h, 08h, 0Ah, 43h, 02h, 43h
		db	 2Ah, 02h, 2Ah, 41h, 11h, 0Ah
		db	 8Ah, 08h, 28h, 43h, 0Ah, 03h
		db	 3Fh,0EBh, 3Fh,0FFh, 8Bh,0BAh
		db	0E8h,0EAh,0FAh, 11h, 0Ah, 0Ah
		db	 11h,0BAh, 8Fh, 11h,0E8h,0EAh
		db	0A8h,0ABh, 11h, 41h, 0Ah, 3Ah
		db	0BAh,0A8h, 0Ah, 11h,0A0h, 42h
		db	 82h,0BAh, 08h, 0Ah, 0Ah, 11h
		db	 41h, 02h,0E8h, 42h, 02h, 80h
		db	 28h, 08h, 8Ah, 3Bh, 80h, 41h
		db	 02h,0E0h, 44h, 28h, 41h, 0Ah
		db	 3Bh, 80h, 08h, 02h,0A0h, 80h
		db	 42h, 80h, 42h, 8Ah, 0Eh, 80h
		db	 41h, 03h,0A0h, 41h, 80h, 41h
		db	 80h, 20h, 20h, 8Ah, 3Ah, 80h
		db	 41h, 02h,0E0h, 41h, 80h, 43h
		db	0A0h, 0Ah, 3Eh, 82h, 08h, 02h
		db	0A0h, 02h, 41h, 20h, 80h, 42h
		db	 0Ah, 0Ah, 02h, 08h, 41h,0A0h
		db	 02h, 42h, 08h, 08h, 41h, 0Ah
		db	 28h, 41h, 0Eh, 42h, 02h, 80h
		db	 20h, 43h, 0Ah, 42h, 08h, 42h
		db	 82h,0A8h, 42h, 02h, 41h, 0Ah
		db	 42h, 8Ch, 42h, 80h,0A0h
		db	' C', 0Ah, 'B', 8, 'E8 A'
		db	8Ah
		db	'A', 8, 0Ah, 'B B:A"', 0Ah, 'A', 8
		db	0Ah, 'C'
		db	 80h, 80h
		db	0Ah, 'A ', 0Ah, 'A8', 0Ah, 'A'
		db	 80h, 41h, 80h, 41h, 38h, 41h
		db	 02h
		db	0Ah, 'A ', 0Ah, 'B  A8'
		db	 02h, 08h, 8Ah
		db	'A ', 8, 'A" B8A', 0Ah, 0Ah, 'A ', 0Ah
		db	'A'
		db	 02h, 41h, 80h, 08h, 28h, 41h
		db	 08h, 0Ah, 02h, 41h, 2Ah, 41h
		db	 02h, 42h, 08h, 3Bh, 41h, 22h
		db	 0Ah, 02h, 41h, 38h, 41h, 82h
		db	'B(*A', 8, 0Ah, 0Ah, ' (A'
		db	 0Bh, 43h, 3Ah, 41h,0A0h, 0Ah
		db	 0Ah, 28h, 0Ah, 41h, 0Ah, 80h
		db	 41h, 80h,0E8h, 41h, 88h, 0Ah
		db	 0Ah, 22h, 2Eh, 41h, 0Bh, 82h
		db	 80h, 88h,0EAh, 0Ah, 20h, 0Ah
		db	 0Ah,0E0h, 2Eh, 41h, 0Eh, 0Ah
		db	0EEh, 0Ah, 88h, 08h, 88h, 0Ah
		db	 0Ah, 20h,0EAh, 41h,0A8h, 8Bh
		db	0A2h,0A8h, 11h, 41h, 20h, 0Ah
		db	 0Ah,0E0h, 8Ah, 82h, 3Ah, 03h
		db	 88h,0BAh, 88h, 80h, 88h, 0Ah
		db	 0Ah, 20h,0EAh, 02h,0BAh, 88h
		db	0A0h,0CAh, 0Ah, 20h, 20h, 0Ah
		db	 0Ah,0B0h,0ACh, 12h, 0Ah, 2Ah
		db	0E2h, 8Ah, 20h, 88h, 0Ah, 0Ah
		db	0A2h,0AEh, 22h,0E8h, 82h,0A2h
		db	0CAh, 28h, 82h, 20h, 0Ah, 0Ah
		db	0E2h,0A8h, 22h,0EAh, 08h, 11h
		db	0A8h, 88h,0A0h, 08h, 0Ah, 0Bh
		db	0A8h,0A2h, 3Ah,0A8h,0A3h,0A8h
		db	 82h, 22h, 22h, 41h, 0Ah, 0Ah
		db	 11h, 88h, 8Ah, 22h, 02h,0A2h
		db	 22h, 88h, 88h, 41h, 0Ah, 08h
		db	 22h, 20h, 2Ah, 82h, 20h, 02h
		db	 08h, 20h, 42h, 0Ah, 00h,0DFh
		db	0DFh,0DFh,0DBh
		db	10 dup (5Fh)
		db	 54h,0AFh,0D5h,0F2h,0AFh,0D5h
		db	0F2h, 59h, 4Fh, 4Ah, 02h, 57h
		db	0AFh,0D5h,0F2h,0AFh,0D5h,0F2h
		db	 59h, 4Fh, 4Ah, 02h, 57h,0AFh
		db	 45h,0F2h,0AFh, 45h,0F2h, 59h
		db	 4Fh, 4Ah, 02h, 57h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 59h, 4Fh
		db	 4Ah, 02h, 57h,0AFh, 45h,0F2h
		db	0AFh, 45h,0F2h, 59h, 4Fh, 4Ah
		db	 02h, 57h,0AFh, 45h,0F2h,0AFh
		db	 45h,0F2h, 59h, 4Fh, 4Ah, 02h
		db	 57h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h, 59h, 4Fh, 4Ah, 02h, 57h
		db	0AFh, 45h,0F2h,0AFh, 45h,0F2h
		db	 59h,0C0h, 45h, 30h, 45h, 0Ch
		db	 45h, 03h, 46h,0C2h,0AFh,0D5h
		db	0F2h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h, 59h,0C0h, 30h, 0Ch, 03h
		db	 41h,0C0h, 30h, 0Ch, 03h, 41h
		db	0C0h, 30h, 0Ch, 03h, 41h,0C0h
		db	 30h, 0Ch, 03h, 41h,0C0h, 30h
		db	 0Ch, 03h, 41h,0C2h,0AFh,0D5h
		db	0F2h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h, 59h,0DFh,0DAh,0C2h,0AFh
		db	 45h,0F2h,0AFh, 45h,0F2h,0AFh
data_77		db	45h			; Data table (indexed access)
		db	0F2h
data_78		dw	5F5Fh			; Data table (indexed access)
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh
		db	45h
data_79		dw	0AFF2h			; Data table (indexed access)
		db	 45h,0F2h,0AFh, 45h,0F2h, 5Fh
		db	 5Fh, 55h,0AFh, 45h,0F2h,0AFh
		db	0D5h,0F2h,0AFh,0D5h,0F2h, 5Fh
		db	 5Fh, 55h,0AFh, 45h,0F2h,0AFh
		db	0D5h,0F2h,0AFh,0D5h,0F2h, 5Fh
		db	 5Fh, 55h,0AFh, 45h,0F2h,0A0h
		db	 45h, 02h,0A0h, 45h, 02h, 5Fh
		db	 5Fh, 55h,0AFh, 45h,0F2h, 5Fh
		db	 5Fh, 5Fh, 54h,0AFh, 45h,0F2h
		db	 5Fh, 5Fh, 5Fh, 54h,0AFh, 45h
		db	0F2h
		db	5Fh
data_80		dw	5F5Fh, 0AF54h		; Data table (indexed access)
		db	 45h,0F2h, 5Fh, 5Fh, 5Fh, 54h
		db	0AFh, 45h,0F2h, 5Fh, 5Fh, 5Fh
		db	 54h,0AFh,0D5h,0F2h, 5Fh, 5Fh
		db	 5Fh, 54h,0AFh,0D5h,0F2h, 5Fh
		db	 5Fh, 5Fh, 54h,0A0h, 45h, 02h
		db	30 dup (5Fh)
		db	 5Ch, 00h

seg_a		ends



		end	start
