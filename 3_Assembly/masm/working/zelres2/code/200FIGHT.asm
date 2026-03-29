
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				_200FIGHT                                ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   29-Mar-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    8          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'M4'                      ; Target assembler: MASM-4.0

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	8000h			;*
data_2e		equ	8018h			;*
data_3e		equ	801Ch			;*
data_4e		equ	8020h			;*
data_5e		equ	8024h			;*
data_6e		equ	8028h			;*
data_7e		equ	802Ch			;*
data_8e		equ	0B002h			;*
data_9e		equ	0C000h			;*
data_96e	equ	4000h			;*
data_97e	equ	6CFEh			;*
data_98e	equ	6D17h			;*
data_99e	equ	7516h			;*
data_100e	equ	76CEh			;*
data_101e	equ	77C7h			;*
data_102e	equ	77D7h			;*
data_103e	equ	79B4h			;*
data_104e	equ	79B6h			;*
data_105e	equ	79CAh			;*
data_106e	equ	8244h			;*
data_107e	equ	83D7h			;*
data_108e	equ	8581h			;*
data_109e	equ	85C2h			;*
data_110e	equ	85EEh			;*
data_111e	equ	8790h			;*
data_112e	equ	883Fh			;*
data_113e	equ	8C79h			;*
data_114e	equ	8C8Dh			;*
data_115e	equ	8F33h			;*
data_116e	equ	90CAh			;*
data_117e	equ	9185h			;*
data_118e	equ	920Ah			;*
data_119e	equ	9234h			;*
data_120e	equ	972Fh			;*
data_121e	equ	9788h			;*
data_122e	equ	98B8h			;*
data_123e	equ	98BEh			;*
data_124e	equ	9985h			;*
data_125e	equ	9C1Eh			;*
data_126e	equ	9EEDh			;*
data_127e	equ	9EEEh			;*
data_128e	equ	9EEFh			;*
data_129e	equ	9EF0h			;*
data_130e	equ	9EF1h			;*
data_131e	equ	9EF2h			;*
data_132e	equ	9EF4h			;*
data_133e	equ	9EF5h			;*
data_134e	equ	9EF6h			;*
data_135e	equ	9EF7h			;*
data_136e	equ	9EF8h			;*
data_137e	equ	9EF9h			;*
data_138e	equ	9EFAh			;*
data_139e	equ	9EFEh			;*
data_140e	equ	9EFFh			;*
data_141e	equ	9F00h			;*
data_142e	equ	9F01h			;*
data_143e	equ	9F02h			;*
data_144e	equ	9F03h			;*
data_145e	equ	9F05h			;*
data_146e	equ	9F07h			;*
data_147e	equ	9F08h			;*
data_148e	equ	9F09h			;*
data_149e	equ	9F0Ah			;*
data_150e	equ	9F0Bh			;*
data_151e	equ	9F0Ch			;*
data_152e	equ	9F0Dh			;*
data_153e	equ	9F0Eh			;*
data_154e	equ	9F10h			;*
data_155e	equ	9F12h			;*
data_156e	equ	9F14h			;*
data_157e	equ	9F15h			;*
data_158e	equ	9F16h			;*
data_159e	equ	9F17h			;*
data_160e	equ	9F18h			;*
data_161e	equ	9F19h			;*
data_162e	equ	9F1Ah			;*
data_163e	equ	9F1Ch			;*
data_164e	equ	9F1Dh			;*
data_165e	equ	9F1Eh			;*
data_166e	equ	9F1Fh			;*
data_167e	equ	9F20h			;*
data_168e	equ	9F21h			;*
data_169e	equ	9F22h			;*
data_170e	equ	9F23h			;*
data_171e	equ	9F24h			;*
data_172e	equ	9F25h			;*
data_173e	equ	9F26h			;*
data_174e	equ	9F27h			;*
data_175e	equ	9F28h			;*
data_176e	equ	9F29h			;*
data_177e	equ	9F2Ah			;*
data_178e	equ	9F2Bh			;*
data_179e	equ	9F2Ch			;*
data_180e	equ	9F2Dh			;*
data_181e	equ	9F85h			;*
data_182e	equ	0A000h			;*
data_183e	equ	0A002h			;*
data_184e	equ	0A006h			;*
data_185e	equ	0A008h			;*
data_186e	equ	0A010h			;*
data_187e	equ	0C000h			;*
data_188e	equ	0C002h			;*
data_189e	equ	0C004h			;*
data_190e	equ	0C006h			;*
data_191e	equ	0C008h			;*
data_192e	equ	0C00Ah			;*
data_193e	equ	0C00Ch			;*
data_194e	equ	0C00Eh			;*
data_195e	equ	0C010h			;*
data_196e	equ	0C012h			;*
data_197e	equ	0C013h			;*
data_198e	equ	0C015h			;*
data_199e	equ	0C016h			;*
data_200e	equ	0C017h			;*
data_201e	equ	0C019h			;*
data_202e	equ	0C01Bh			;*
data_203e	equ	0E000h			;*
data_204e	equ	0E001h			;*
data_205e	equ	0E8FEh			;*
data_206e	equ	0E8FFh			;*
data_207e	equ	0E900h			;*
data_208e	equ	0E921h			;*
data_209e	equ	0E939h			;*
data_210e	equ	0EB60h			;*
data_211e	equ	0EB80h			;*
data_212e	equ	0ED20h			;*
data_213e	equ	0EDA0h			;*
data_214e	equ	0FF08h			;*
data_215e	equ	0FF18h			;*
data_216e	equ	0FF1Ah			;*
data_217e	equ	0FF1Dh			;*
data_218e	equ	0FF1Eh			;*
data_219e	equ	0FF24h			;*
data_220e	equ	0FF2Ch			;*
data_221e	equ	0FF2Eh			;*
data_222e	equ	0FF2Fh			;*
data_223e	equ	0FF30h			;*
data_224e	equ	0FF31h			;*
data_225e	equ	0FF33h			;*
data_226e	equ	0FF34h			;*
data_227e	equ	0FF35h			;*
data_228e	equ	0FF36h			;*
data_229e	equ	0FF37h			;*
data_230e	equ	0FF38h			;*
data_231e	equ	0FF39h			;*
data_232e	equ	0FF3Ah			;*
data_233e	equ	0FF3Ch			;*
data_234e	equ	0FF3Dh			;*
data_235e	equ	0FF3Eh			;*
data_236e	equ	0FF3Fh			;*
data_237e	equ	0FF40h			;*
data_238e	equ	0FF41h			;*
data_239e	equ	0FF42h			;*
data_240e	equ	0FF43h			;*
data_241e	equ	0FF44h			;*
data_242e	equ	0FF45h			;*
data_243e	equ	0FF46h			;*
data_244e	equ	0FF47h			;*
data_245e	equ	0FF4Ah			;*
data_246e	equ	0FF4Bh			;*
data_247e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_200FIGHT	proc	far

start:
		db	 2Eh, 3Fh, 00h, 00h, 42h, 60h
		db	0DCh, 79h, 23h, 97h, 3Fh, 97h
		db	0E5h, 91h,0F6h, 91h, 0Ah, 92h
		db	 22h, 92h, 34h, 92h, 43h, 92h
		db	 55h, 92h, 6Ch, 92h,0B4h, 92h
		db	 0Ah, 93h, 62h, 93h, 9Ah, 93h
		db	0C5h, 93h, 0Ch, 94h, 52h, 94h
		db	 9Ah, 94h, 6Eh, 6Dh, 82h, 6Dh
		db	 8Eh, 6Dh,0E1h, 94h,0A0h, 97h
		db	0D5h, 96h,0B5h, 97h,0A1h, 96h
		db	 51h, 98h, 11h, 86h,0DBh, 83h
		db	0C5h, 98h, 5Bh, 97h
loc_1:
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		push	cs
		pop	ds
		mov	byte ptr ds:data_167e,0
		mov	byte ptr ds:data_168e,0
		mov	byte ptr ds:data_169e,0
		mov	ax,0FFFFh
		mov	ds:data_211e,al
		mov	ds:data_213e,al
		mov	word ptr ds:[0EB15h],ax
		mov	byte ptr ds:data_221e,0
		mov	byte ptr ds:data_222e,0
		mov	byte ptr ds:data_223e,0
		mov	byte ptr ds:data_142e,0
		test	byte ptr ds:data_226e,0FFh
		jnz	loc_2			; Jump if not zero
		jmp	loc_7
loc_2:
		call	sub_28
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:data_143e,0FFh
		mov	al,byte ptr ds:[0C8h]
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9E53h
		mov	si,ax
		mov	es,cs:data_220e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	si,9BF1h
		mov	es,cs:data_220e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		call	word ptr cs:data_85
		mov	byte ptr ds:data_229e,0
		call	word ptr cs:data_81
		call	word ptr cs:data_80
		call	sub_53
		mov	byte ptr ds:data_143e,0
		push	ds
		mov	ds,cs:data_220e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	cx,6

locloop_3:
		push	cx
		mov	byte ptr ds:data_216e,0
loc_4:
		cmp	byte ptr ds:data_216e,41h	; 'A'
		jb	loc_4			; Jump if below
		mov	bx,0C28h
		mov	cx,3828h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		mov	byte ptr ds:data_216e,0
loc_5:
		cmp	byte ptr ds:data_216e,41h	; 'A'
		jb	loc_5			; Jump if below
		call	word ptr cs:data_85
		pop	cx
		loop	locloop_3		; Loop if cx > 0

		mov	si,ds:data_187e
		add	si,5
		mov	al,[si]
		mov	[si-1],al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9D8Dh
		mov	si,ax

_200FIGHT	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		mov	es,cs:data_220e
		mov	di,data_96e
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_220e
		mov	si,4000h
		mov	bp,0A000h
		mov	cx,100h
		call	word ptr cs:data_89
		pop	ds
loc_6:
		mov	si,ds:data_183e
		add	si,8
		lodsb				; String [si] to al
		mov	ds:data_142e,al
		mov	si,[si]
		call	word ptr cs:[2010h]
		mov	si,ds:data_183e
		add	si,3
		mov	bx,[si]
		push	bx
		call	word ptr cs:[200Ah]
		pop	bx
		call	word ptr cs:[200Ch]
		jmp	short loc_8
loc_7:
		call	word ptr cs:[2012h]
		call	sub_27
		mov	si,ds:data_194e
		call	word ptr cs:[2010h]
		call	word ptr cs:[2016h]
loc_8:
		call	word ptr cs:[2006h]
		call	word ptr cs:[2008h]
		call	word ptr cs:[2014h]
		test	byte ptr ds:[0E6h],0FFh
		jnz	loc_9			; Jump if not zero
		jmp	loc_11
loc_9:
		mov	byte ptr ds:data_173e,0FFh
		mov	word ptr ds:[80h],29h
		mov	byte ptr ds:[83h],5
		call	sub_29
		call	sub_48
loc_10:
		call	sub_44
		test	byte ptr ds:[0E6h],0FFh
		jnz	loc_10			; Jump if not zero
		push	ds
		mov	ds,cs:data_220e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	byte ptr ds:data_143e,0
		mov	ah,1Eh
		mov	al,1
		call	word ptr cs:[10Ch]
		mov	byte ptr ds:data_226e,0FFh
		mov	byte ptr ds:data_174e,0FFh
		mov	si,ds:data_187e
		lodsb				; String [si] to al
		call	sub_74
		call	sub_75
		push	ds
		mov	ds,cs:data_220e
		mov	si,8030h
		mov	cx,66h
		call	word ptr cs:[2044h]
		call	word ptr cs:data_90
		pop	ds
		push	ds
		call	word ptr cs:data_83
		mov	cx,18h
		call	word ptr cs:[2044h]
		pop	ds
		mov	word ptr ds:data_162e,18h
		mov	byte ptr ds:data_163e,0Dh
		mov	byte ptr ds:[83h],0Ch
		mov	byte ptr ds:data_141e,0Ch
		call	sub_70
		call	sub_28
		jmp	loc_6
loc_11:
		call	sub_29
		test	byte ptr ds:data_174e,0FFh
		jz	loc_12			; Jump if zero
		call	sub_48
		call	sub_44
		mov	byte ptr ds:data_173e,0
		jmp	short loc_14
loc_12:
		test	byte ptr ds:data_226e,0FFh
		jz	loc_13			; Jump if zero
		call	word ptr cs:data_79
loc_13:
		call	sub_48
		call	sub_140
loc_14:
		test	byte ptr ds:[49h],0FFh
		jz	loc_15			; Jump if zero
		jmp	loc_703
loc_15:
		test	byte ptr ds:data_143e,0FFh
		jz	loc_16			; Jump if zero
		mov	byte ptr ds:data_143e,0
		push	ds
		mov	ds,cs:data_220e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
loc_16:
		xor	al,al			; Zero register
		mov	ds:data_217e,al
		mov	ds:data_218e,al
		mov	byte ptr ds:data_216e,0
		mov	byte ptr ds:data_174e,0
loc_17:
		test	byte ptr ds:data_231e,0FFh
		jnz	loc_20			; Jump if not zero
		call	sub_42
		call	sub_7
		call	sub_44
		call	sub_107
		or	al,0E8h
		sub	[bx+di],al
		call	sub_6
		inc	byte ptr ds:data_149e
		cmp	byte ptr ds:data_149e,2
		jne	loc_18			; Jump if not equal
		mov	byte ptr ds:data_230e,0
loc_18:
		mov	dx,629Ch
		push	dx
		int	61h			; ??INT Non-standard interrupt
		test	al,2
		jz	loc_19			; Jump if zero
		and	byte ptr ds:[0C2h],0FDh
loc_19:
		call	sub_18
		call	sub_5
		retn
loc_20:
		mov	byte ptr ds:data_230e,0
		mov	byte ptr ds:data_234e,0
		mov	byte ptr ds:data_239e,0
		mov	byte ptr ds:data_233e,0
		call	word ptr cs:data_73
		mov	byte ptr ds:data_240e,0
		call	sub_44
		call	sub_6
		call	sub_5
		cmp	byte ptr ds:data_231e,0FFh
		jne	loc_21			; Jump if not equal
		call	sub_37
		inc	si
		call	sub_23
		jc	loc_20			; Jump if carry Set
		add	si,24h
		call	sub_34
		call	sub_23
		jc	loc_20			; Jump if carry Set
loc_21:
		and	byte ptr ds:[0C2h],0FDh
		mov	byte ptr ds:data_231e,0
		mov	byte ptr ds:data_217e,0
		mov	byte ptr ds:data_218e,0
		mov	byte ptr ds:data_167e,0
		mov	byte ptr ds:data_168e,0
		mov	byte ptr ds:[0E7h],7Fh
		jmp	loc_17
sub_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_5		proc	near
		mov	byte ptr ds:data_169e,0
		int	61h			; ??INT Non-standard interrupt
		cmp	al,5
		jne	loc_22			; Jump if not equal
		jmp	loc_78
loc_22:
		cmp	al,9
		jne	loc_23			; Jump if not equal
		jmp	loc_106
loc_23:
		cmp	al,1
		jne	loc_24			; Jump if not equal
		jmp	loc_63
loc_24:
		mov	ah,al
		test	byte ptr ds:data_231e,0FFh
		jnz	loc_28			; Jump if not zero
		test	byte ptr ds:data_234e,0FFh
		jz	loc_28			; Jump if zero
		test	byte ptr ds:data_150e,0FFh
		jnz	loc_25			; Jump if not zero
		jmp	loc_69
loc_25:
		mov	byte ptr ds:data_150e,0
		test	byte ptr ds:[0C2h],2
		jnz	loc_26			; Jump if not zero
		jmp	loc_69
loc_26:
		mov	dx,65BAh
		push	dx
		test	byte ptr ds:[0C2h],1
		jnz	loc_27			; Jump if not zero
		jmp	loc_107
loc_27:
		jmp	loc_79
loc_28:
		push	ax
		mov	al,byte ptr ds:[0C2h]
		and	al,1
		cmp	al,ds:data_171e
		mov	ds:data_171e,al
		jz	loc_29			; Jump if zero
		call	sub_8
loc_29:
		pop	ax
		mov	al,ah
		push	ax
		cmp	al,2
		jne	loc_30			; Jump if not equal
		call	sub_20
loc_30:
		pop	ax
		and	al,0Ch
		cmp	al,4
		jne	loc_31			; Jump if not equal
		jmp	loc_79
loc_31:
		cmp	al,8
		jne	loc_32			; Jump if not equal
		jmp	loc_107
loc_32:
		call	sub_8
		mov	al,ds:data_231e
		or	al,ds:data_230e
		jz	loc_33			; Jump if zero
		retn
loc_33:
		mov	byte ptr ds:[0E7h],80h
		retn
			                        ;* No entry point to code
		test	byte ptr ds:data_230e,0FFh
		jz	loc_34			; Jump if zero
		retn
loc_34:
		test	byte ptr ds:data_234e,0FFh
		jz	loc_35			; Jump if zero
		retn
loc_35:
		call	sub_37
		mov	al,[si]
		call	sub_39
		jnz	loc_36			; Jump if not zero
		retn
loc_36:
		inc	si
		inc	si
		mov	al,[si]
		call	sub_39
		jnz	loc_37			; Jump if not zero
		retn
loc_37:
		add	si,24h
		call	sub_34
		mov	al,[si]
		call	sub_39
		jz	loc_38			; Jump if zero
		jmp	loc_95
loc_38:
		jmp	loc_124

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_6:
		test	byte ptr ds:data_156e,0FFh
		jnz	loc_39			; Jump if not zero
		retn
loc_39:
		test	byte ptr ds:data_142e,0FFh
		jnz	loc_41			; Jump if not zero
		mov	si,data_153e
		mov	al,[si]
		or	al,[si+1]
		mov	ah,[si+2]
		or	ah,[si+3]
		test	al,ah
		jz	loc_40			; Jump if zero
		test	byte ptr ds:[0C2h],1
		jnz	loc_41			; Jump if not zero
		jmp	short loc_43
loc_40:
		or	al,al			; Zero ?
		jnz	loc_43			; Jump if not zero
loc_41:
		test	byte ptr ds:data_231e,0FFh
		jz	loc_42			; Jump if zero
		and	byte ptr ds:[0C2h],0FCh
		or	byte ptr ds:[0C2h],1
		mov	byte ptr ds:data_234e,7Fh
		mov	byte ptr ds:data_217e,0
loc_42:
		call	sub_13
		call	sub_13
		jmp	short loc_45
loc_43:
		test	byte ptr ds:data_231e,0FFh
		jz	loc_44			; Jump if zero
		and	byte ptr ds:[0C2h],0FCh
		mov	byte ptr ds:data_234e,7Fh
		mov	byte ptr ds:data_217e,0
loc_44:
		call	sub_16
		call	sub_16
		jmp	short loc_45
loc_45:
		test	byte ptr ds:data_231e,0FFh
		jz	loc_46			; Jump if zero
		mov	byte ptr ds:data_231e,80h
		mov	byte ptr ds:data_234e,0
loc_46:
		test	byte ptr ds:data_157e,0FFh
		jz	loc_47			; Jump if zero
		retn
loc_47:
		test	byte ptr ds:data_234e,80h
		jz	loc_48			; Jump if zero
		retn
loc_48:
		call	sub_22
		jnc	loc_49			; Jump if carry=0
		retn
loc_49:
		test	byte ptr ds:data_148e,0FFh
		jnz	loc_50			; Jump if not zero
		jmp	loc_169
loc_50:
		dec	byte ptr ds:data_148e
		inc	byte ptr ds:[84h]
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_7:
		call	sub_36
		jz	loc_51			; Jump if zero
		retn
loc_51:
		test	byte ptr ds:data_234e,0FFh
		jz	loc_52			; Jump if zero
		retn
loc_52:
		test	byte ptr ds:data_167e,0FFh
		jnz	loc_53			; Jump if not zero
		retn
loc_53:
		dec	byte ptr ds:data_167e
		call	sub_37
		add	si,6Dh
		call	sub_34
		mov	al,[si]
		cmp	al,40h			; '@'
		jb	loc_54			; Jump if below
		cmp	al,49h			; 'I'
		jae	loc_54			; Jump if above or =
		mov	byte ptr ds:data_167e,0
		retn
loc_54:
		mov	al,ds:data_169e
		test	byte ptr ds:data_170e,1
		jz	loc_56			; Jump if zero
		cmp	al,1
		jne	loc_55			; Jump if not equal
		retn
loc_55:
		jmp	loc_116
loc_56:
		cmp	al,2
		jne	loc_57			; Jump if not equal
		retn
loc_57:
		jmp	loc_87

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_8:
		call	sub_36
		jz	loc_58			; Jump if zero
		retn
loc_58:
		test	byte ptr ds:data_167e,0FFh
		jz	loc_59			; Jump if zero
		retn
loc_59:
		test	byte ptr ds:data_231e,0FFh
		jz	loc_60			; Jump if zero
		retn
loc_60:
		mov	al,ds:data_168e
		shr	al,1			; Shift w/zeros fill
		or	al,al			; Zero ?
		jnz	loc_61			; Jump if not zero
		retn
loc_61:
		cmp	al,0Ah
		jb	loc_62			; Jump if below
		mov	al,0Ah
loc_62:
		mov	ds:data_167e,al
		mov	byte ptr ds:data_168e,0
		retn
loc_63:
		mov	byte ptr ds:data_160e,0
		call	sub_69
		call	sub_80
		call	sub_10

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_9:
		inc	byte ptr ds:data_167e
		cmp	byte ptr ds:data_167e,0Ah
		jb	loc_64			; Jump if below
		mov	byte ptr ds:data_167e,0Ah
loc_64:
		test	byte ptr ds:data_231e,0FFh
		jz	loc_65			; Jump if zero
		retn
loc_65:
		mov	byte ptr ds:data_230e,0
		mov	al,ds:data_148e
		cmp	al,ds:data_152e
		jae	loc_69			; Jump if above or =
		call	sub_37
		sub	si,23h
		call	sub_35
		mov	al,[si]
		call	sub_39
		jnz	loc_67			; Jump if not zero
		mov	byte ptr ds:[0E7h],0
		and	byte ptr ds:[0C2h],0FDh
		mov	byte ptr ds:data_234e,0FFh
		mov	al,ds:data_152e
		shr	al,1			; Shift w/zeros fill
		mov	ds:data_151e,al
		inc	byte ptr ds:data_148e
		cmp	byte ptr ds:[84h],7
		jae	loc_66			; Jump if above or =
		jmp	loc_77
loc_66:
		dec	byte ptr ds:[84h]
		retn
loc_67:
		test	byte ptr ds:data_148e,0FFh
		jnz	loc_69			; Jump if not zero
		test	byte ptr ds:data_231e,0FFh
		jz	loc_68			; Jump if zero
		retn
loc_68:
		mov	byte ptr ds:[0E7h],80h
		retn
loc_69:
		mov	byte ptr ds:data_239e,0
		mov	byte ptr ds:data_234e,7Fh
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_10:
		call	sub_37
		inc	si
		call	sub_23
		jc	loc_73			; Jump if carry Set
		dec	si
		call	sub_23
		jnc	loc_70			; Jump if carry=0
		test	byte ptr ds:[0C2h],1
		jnz	loc_79			; Jump if not zero
		retn
loc_70:
		inc	si
		inc	si
		call	sub_23
		jc	loc_71			; Jump if carry Set
		retn
loc_71:
		test	byte ptr ds:[0C2h],1
		jnz	loc_ret_72		; Jump if not zero
		jmp	loc_107

loc_ret_72:
		retn
loc_73:
		mov	byte ptr ds:data_231e,0FFh
		mov	byte ptr ds:data_230e,0
loc_74:
		call	sub_37
		sub	si,23h
		call	sub_35
		dec	byte ptr ds:[0E7h]
		call	sub_23
		jc	loc_75			; Jump if carry Set
		or	byte ptr ds:[0E7h],1
		retn
loc_75:
		call	sub_11
		call	sub_44
		test	byte ptr ds:[0E7h],1
		jz	loc_76			; Jump if zero
		retn
loc_76:
		jmp	short loc_74

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_11:
loc_77:
		dec	byte ptr ds:[82h]
		mov	si,ds:data_224e
		sub	si,24h
		call	sub_35
		mov	ds:data_224e,si
		retn
loc_78:
		mov	byte ptr ds:data_150e,0FFh
		call	sub_9
		jmp	short loc_79
loc_79:
		mov	byte ptr ds:data_160e,0
		test	byte ptr ds:[0C2h],1
		jnz	loc_80			; Jump if not zero
		jmp	loc_112
loc_80:
		test	byte ptr ds:data_230e,0FFh
		jz	loc_81			; Jump if zero
		retn
loc_81:
		cmp	byte ptr ds:data_239e,1
		jne	loc_82			; Jump if not equal
		jmp	loc_114
loc_82:
		call	sub_13
		jnc	loc_83			; Jump if carry=0
		jmp	loc_114
loc_83:
		mov	byte ptr ds:data_169e,2
		test	byte ptr ds:data_231e,0FFh
		jz	loc_84			; Jump if zero
		retn
loc_84:
		call	sub_36
		jnz	loc_85			; Jump if not zero
		test	byte ptr ds:data_167e,0FFh
		jnz	loc_85			; Jump if not zero
		mov	byte ptr ds:data_170e,0
		inc	byte ptr ds:data_168e
loc_85:
		or	byte ptr ds:[0C2h],2
		test	byte ptr ds:data_234e,0FFh
		jz	loc_86			; Jump if zero
		retn
loc_86:
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],7Fh
		mov	byte ptr ds:data_161e,0
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_13:
loc_87:
		call	sub_37
		mov	di,si
		sub	si,24h
		call	sub_35
		dec	si
		mov	cx,4

locloop_88:
		call	sub_38
		add	al,al
		jnc	loc_89			; Jump if carry=0
		retn
loc_89:
		add	si,24h
		call	sub_34
		loop	locloop_88		; Loop if cx > 0

		xchg	di,si
		test	byte ptr ds:data_230e,0FFh
		jnz	loc_91			; Jump if not zero
		mov	al,[si]
		call	sub_39
		stc				; Set carry flag
		jz	loc_90			; Jump if zero
		retn
loc_90:
		call	sub_14
		jnc	loc_91			; Jump if carry=0
		retn
loc_91:
		mov	cx,2

locloop_92:
		add	si,24h
		call	sub_34
		mov	al,[si]
		call	sub_41
		stc				; Set carry flag
		jz	loc_93			; Jump if zero
		retn
loc_93:
		push	cx
		call	sub_14
		pop	cx
		jnc	loc_94			; Jump if carry=0
		retn
loc_94:
		loop	locloop_92		; Loop if cx > 0

loc_95:
		dec	word ptr ds:[80h]
		cmp	word ptr ds:[80h],0FFFFh
		jne	loc_96			; Jump if not equal
		mov	ax,ds:data_188e
		dec	ax
		mov	word ptr ds:[80h],ax
		mov	si,ds:data_201e
		mov	ds:data_144e,si
loc_96:
		push	cs
		pop	es
		std				; Set direction flag
		mov	si,data_205e
		mov	di,data_206e
		mov	cx,8FFh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		cld				; Clear direction
		mov	si,ds:data_144e
		dec	si
		mov	di,0E8DCh
		xor	dl,dl			; Zero register
loc_97:
		call	sub_31
		dec	si
		add	dl,bh
loc_98:
		mov	[di],bl
		sub	di,24h
		dec	bh
		jnz	loc_98			; Jump if not zero
		cmp	dl,40h			; '@'
		jb	loc_97			; Jump if below
		inc	si
		mov	ds:data_144e,si
		mov	si,ds:data_201e
		dec	si
		mov	ax,word ptr ds:[80h]
		add	ax,24h
		cmp	ax,ds:data_188e
		je	loc_100			; Jump if equal
		mov	si,ds:data_145e
		xor	dh,dh			; Zero register
loc_99:
		call	sub_31
		dec	si
		add	dh,bh
		cmp	dh,40h			; '@'
		jb	loc_99			; Jump if below
loc_100:
		mov	ds:data_145e,si
		call	sub_100
		mov	bx,word ptr ds:[80h]
		mov	byte ptr ds:data_245e,0
		mov	si,ds:data_195e
loc_101:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_102			; Jump if not equal
		retn
loc_102:
		cmp	ah,0FFh
		je	loc_103			; Jump if equal
		cmp	ax,bx
		jne	loc_103			; Jump if not equal
		xor	ah,ah			; Zero register
		mov	al,[si+2]
		call	sub_33
		mov	al,ds:data_245e
		or	al,80h
		mov	[di],al
loc_103:
		inc	byte ptr ds:data_245e
		add	si,10h
		jmp	short loc_101

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_14:
		cmp	byte ptr ds:data_196e,7
		clc				; Clear carry flag
		jnz	loc_104			; Jump if not zero
		retn
loc_104:
		mov	al,[si]
		push	si
		call	sub_63
		pop	si
		cmp	cl,2
		stc				; Set carry flag
		jnz	loc_105			; Jump if not zero
		retn
loc_105:
		clc				; Clear carry flag
		retn
loc_106:
		mov	byte ptr ds:data_150e,0FFh
		call	sub_9
		jmp	short loc_107
loc_107:
		mov	byte ptr ds:data_160e,0
		test	byte ptr ds:[0C2h],1
		jnz	loc_112			; Jump if not zero
		test	byte ptr ds:data_230e,0FFh
		jz	loc_108			; Jump if zero
		retn
loc_108:
		cmp	byte ptr ds:data_239e,2
		je	loc_114			; Jump if equal
		call	sub_16
		jc	loc_114			; Jump if carry Set
		mov	byte ptr ds:data_169e,1
		test	byte ptr ds:data_231e,0FFh
		jz	loc_109			; Jump if zero
		retn
loc_109:
		call	sub_36
		jnz	loc_110			; Jump if not zero
		test	byte ptr ds:data_167e,0FFh
		jnz	loc_110			; Jump if not zero
		mov	byte ptr ds:data_170e,1
		inc	byte ptr ds:data_168e
loc_110:
		or	byte ptr ds:[0C2h],2
		test	byte ptr ds:data_234e,0FFh
		jz	loc_111			; Jump if zero
		retn
loc_111:
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],7Fh
		mov	byte ptr ds:data_161e,0
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_15:
loc_112:
		xor	byte ptr ds:[0C2h],1
		test	byte ptr ds:data_231e,0FFh
		jz	loc_113			; Jump if zero
		retn
loc_113:
		mov	byte ptr ds:[0E7h],80h
		retn
loc_114:
		and	byte ptr ds:[0C2h],0FDh
		mov	al,ds:data_231e
		or	al,ds:data_234e
		jz	loc_115			; Jump if zero
		retn
loc_115:
		mov	byte ptr ds:[0E7h],80h
		retn
sub_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_16		proc	near
loc_116:
		call	sub_37
		inc	si
		inc	si
		mov	di,si
		sub	si,24h
		call	sub_35
		mov	cx,4

locloop_117:
		call	sub_38
		add	al,al
		jnc	loc_118			; Jump if carry=0
		retn
loc_118:
		add	si,24h
		call	sub_34
		loop	locloop_117		; Loop if cx > 0

		xchg	di,si
		test	byte ptr ds:data_230e,0FFh
		jnz	loc_120			; Jump if not zero
		mov	al,[si]
		call	sub_39
		stc				; Set carry flag
		jz	loc_119			; Jump if zero
		retn
loc_119:
		call	sub_17
		jnc	loc_120			; Jump if carry=0
		retn
loc_120:
		mov	cx,2

locloop_121:
		add	si,24h
		call	sub_34
		mov	al,[si]
		call	sub_41
		stc				; Set carry flag
		jz	loc_122			; Jump if zero
		retn
loc_122:
		push	cx
		call	sub_17
		pop	cx
		jnc	loc_123			; Jump if carry=0
		retn
loc_123:
		loop	locloop_121		; Loop if cx > 0

loc_124:
		inc	word ptr ds:[80h]
		mov	ax,word ptr ds:[80h]
		add	ax,23h
		cmp	ax,ds:data_188e
		jne	loc_125			; Jump if not equal
		mov	word ptr ds:data_145e,0C01Ah
loc_125:
		push	cs
		pop	es
		mov	si,data_204e
		mov	di,data_203e
		mov	cx,8FFh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	si,ds:data_145e
		inc	si
		mov	di,0E023h
		call	sub_32
		dec	si
		mov	ds:data_145e,si
		mov	ax,word ptr ds:[80h]
		cmp	ax,ds:data_188e
		jne	loc_126			; Jump if not equal
		mov	word ptr ds:[80h],0
		mov	si,data_202e
		jmp	short loc_128
loc_126:
		mov	si,ds:data_144e
		xor	dh,dh			; Zero register
loc_127:
		call	sub_30
		inc	si
		add	dh,bh
		cmp	dh,40h			; '@'
		jb	loc_127			; Jump if below
loc_128:
		mov	ds:data_144e,si
		call	sub_99
		mov	byte ptr ds:data_245e,0
		mov	bx,word ptr ds:[80h]
		add	bx,23h
		mov	ax,bx
		sub	ax,ds:data_188e
		jc	loc_129			; Jump if carry Set
		mov	bx,ax
loc_129:
		mov	si,ds:data_195e
loc_130:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_131			; Jump if not equal
		retn
loc_131:
		cmp	ah,0FFh
		je	loc_132			; Jump if equal
		cmp	ax,bx
		jne	loc_132			; Jump if not equal
		mov	ah,23h			; '#'
		mov	al,[si+2]
		call	sub_33
		mov	al,ds:data_245e
		or	al,80h
		mov	[di],al
loc_132:
		inc	byte ptr ds:data_245e
		add	si,10h
		jmp	short loc_130
sub_16		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_17		proc	near
		cmp	byte ptr ds:data_196e,7
		clc				; Clear carry flag
		jnz	loc_133			; Jump if not zero
		retn
loc_133:
		mov	al,[si]
		push	si
		call	sub_63
		pop	si
		dec	cl
		stc				; Set carry flag
		jnz	loc_134			; Jump if not zero
		retn
loc_134:
		clc				; Clear carry flag
		retn
sub_17		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_18		proc	near
		test	byte ptr ds:data_157e,0FFh
		jz	loc_135			; Jump if zero
		retn
loc_135:
		test	byte ptr ds:data_234e,80h
		jz	loc_136			; Jump if zero
		retn
loc_136:
		call	sub_84
		call	sub_19
		call	sub_22
		jnc	loc_137			; Jump if carry=0
		jmp	loc_170
loc_137:
		inc	byte ptr ds:data_147e
		test	byte ptr ds:data_148e,0FFh
		jz	loc_138			; Jump if zero
		pushf				; Push flags
		dec	byte ptr ds:data_148e
		inc	byte ptr ds:[84h]
		popf				; Pop flags
loc_138:
		pop	ax
		jnz	loc_139			; Jump if not zero
		call	sub_21
loc_139:
		test	byte ptr ds:[0C2h],2
		jnz	loc_140			; Jump if not zero
		call	sub_37
		add	si,49h
		call	sub_34
		call	sub_23
		jnc	loc_140			; Jump if carry=0
		mov	byte ptr ds:data_231e,0FFh
		retn
loc_140:
		mov	byte ptr ds:[0E7h],80h
		mov	al,ds:data_234e
		mov	byte ptr ds:data_234e,7Fh
		test	byte ptr ds:data_239e,0FFh
		jz	loc_141			; Jump if zero
		retn
loc_141:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_142			; Jump if zero
		retn
loc_142:
		test	al,0FFh
		jnz	loc_144			; Jump if not zero
		mov	ax,69E0h
		push	ax
		test	byte ptr ds:[0C2h],1
		jz	loc_143			; Jump if zero
		jmp	loc_79
loc_143:
		jmp	loc_107
			                        ;* No entry point to code
		and	byte ptr ds:[0C2h],0FDh
		retn
loc_144:
		int	61h			; ??INT Non-standard interrupt
		and	al,0Ch
		cmp	al,4
		je	loc_148			; Jump if equal
		cmp	al,8
		je	loc_152			; Jump if equal
loc_145:
		test	byte ptr ds:[0C2h],2
		jnz	loc_146			; Jump if not zero
		cmp	al,4
		je	loc_153			; Jump if equal
		cmp	al,8
		je	loc_149			; Jump if equal
		retn
loc_146:
		test	byte ptr ds:[0C2h],1
		jz	loc_147			; Jump if zero
		jmp	loc_79
loc_147:
		jmp	loc_107
loc_148:
		test	byte ptr ds:[0C2h],1
		jnz	loc_145			; Jump if not zero
		and	byte ptr ds:[0C2h],0FDh
		call	sub_15
loc_149:
		call	sub_37
		add	si,6Dh
		call	sub_34
		mov	al,[si]
		call	sub_39
		jz	loc_150			; Jump if zero
		retn
loc_150:
		inc	si
		mov	al,[si]
		call	sub_39
		jnz	loc_151			; Jump if not zero
		retn
loc_151:
		jmp	loc_116
loc_152:
		test	byte ptr ds:[0C2h],1
		jz	loc_145			; Jump if zero
		and	byte ptr ds:[0C2h],0FDh
		call	sub_15
loc_153:
		call	sub_37
		add	si,6Dh
		call	sub_34
		mov	al,[si]
		call	sub_39
		jz	loc_154			; Jump if zero
		retn
loc_154:
		dec	si
		mov	al,[si]
		call	sub_39
		jnz	loc_155			; Jump if not zero
		retn
loc_155:
		jmp	loc_87

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_19:
		mov	byte ptr ds:data_239e,0
		call	sub_37
		add	si,49h
		call	sub_34
		call	sub_24
		jz	loc_156			; Jump if zero
		retn
loc_156:
		and	byte ptr ds:[0C2h],0FDh
		mov	ds:data_239e,dl
		test	byte ptr ds:data_151e,0FFh
		jnz	loc_161			; Jump if not zero
		mov	al,ds:data_158e
		inc	byte ptr ds:data_158e
		and	al,3
		jz	loc_157			; Jump if zero
		retn
loc_157:
		int	61h			; ??INT Non-standard interrupt
		cmp	byte ptr ds:data_239e,1
		je	loc_159			; Jump if equal
		test	al,8
		jz	loc_158			; Jump if zero
		retn
loc_158:
		jmp	loc_87
loc_159:
		test	al,4
		jz	loc_160			; Jump if zero
		retn
loc_160:
		jmp	loc_116
loc_161:
		mov	al,byte ptr ds:[9Eh]
		cmp	al,3
		jne	loc_162			; Jump if not equal
		retn
loc_162:
		dec	byte ptr ds:data_151e
		cmp	byte ptr ds:data_239e,1
		jne	loc_163			; Jump if not equal
		jmp	loc_116
loc_163:
		jmp	loc_87

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_20:
		mov	byte ptr ds:data_160e,0
		test	byte ptr ds:data_239e,0FFh
		jz	loc_164			; Jump if zero
		retn
loc_164:
		call	sub_78
		call	sub_37
		add	si,6Dh
		call	sub_34
		call	sub_23
		jc	loc_166			; Jump if carry Set
		test	byte ptr ds:data_231e,0FFh
		jz	loc_165			; Jump if zero
		mov	byte ptr ds:data_231e,80h
		mov	byte ptr ds:data_234e,80h
		retn
loc_165:
		mov	byte ptr ds:data_149e,0
		mov	byte ptr ds:data_230e,0FFh
		retn
loc_166:
		call	sub_37
		add	si,6Dh
		call	sub_34
		inc	byte ptr ds:[0E7h]
		mov	al,[si]
		call	sub_39
		jz	loc_167			; Jump if zero
		or	byte ptr ds:[0E7h],1
		retn
loc_167:
		call	sub_21
		call	sub_44
		test	byte ptr ds:[0E7h],1
		jz	loc_168			; Jump if zero
		retn
loc_168:
		jmp	short loc_166

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_21:
loc_169:
		inc	byte ptr ds:[82h]
		mov	si,ds:data_224e
		add	si,24h
		call	sub_34
		mov	ds:data_224e,si
		retn
loc_170:
		mov	al,ds:data_234e
		xor	al,7Fh
		jz	loc_171			; Jump if zero
		retn
loc_171:
		pop	ax
		mov	dl,ds:data_147e
		mov	byte ptr ds:data_234e,0
		mov	byte ptr ds:data_149e,0
		mov	byte ptr ds:data_147e,0
		mov	byte ptr ds:[0E7h],80h
		test	byte ptr ds:data_239e,0FFh
		jz	loc_172			; Jump if zero
		retn
loc_172:
		cmp	dl,2
		jae	loc_173			; Jump if above or =
		retn
loc_173:
		mov	byte ptr ds:data_230e,0FFh
		retn
sub_18		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_22		proc	near
		call	sub_37
		add	si,6Dh
		call	sub_34
		mov	di,si
		call	sub_38
		add	al,al
		jnc	loc_174			; Jump if carry=0
		retn
loc_174:
		dec	si
		call	sub_38
		add	al,al
		jnc	loc_175			; Jump if carry=0
		retn
loc_175:
		mov	si,di
		mov	al,[si]
		call	sub_41
		stc				; Set carry flag
		jz	loc_176			; Jump if zero
		retn
loc_176:
		cmp	byte ptr ds:[0E7h],80h
		clc				; Clear carry flag
		jnz	loc_177			; Jump if not zero
		retn
loc_177:
		dec	si
		mov	al,[si]
		call	sub_41
		clc				; Clear carry flag
		jnz	loc_178			; Jump if not zero
		retn
loc_178:
		inc	si
		inc	si
		mov	al,[si]
		call	sub_41
		stc				; Set carry flag
		jz	loc_179			; Jump if zero
		retn
loc_179:
		clc				; Clear carry flag
		retn
sub_22		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_23		proc	near
		mov	al,[si]
		dec	al
		cmp	al,2
		retn
sub_23		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_24		proc	near
		mov	es,cs:data_220e
		mov	al,[si]
		mov	di,data_2e
		mov	dl,2
		mov	cx,4

locloop_180:
		test	byte ptr es:[di],0FFh
		jz	loc_182			; Jump if zero
		cmp	al,es:[di]
		jne	loc_181			; Jump if not equal
		retn
loc_181:
		inc	di
		loop	locloop_180		; Loop if cx > 0

loc_182:
		mov	di,data_3e
		mov	dl,1
		mov	cx,4

locloop_183:
		test	byte ptr es:[di],0FFh
		jz	loc_185			; Jump if zero
		cmp	al,es:[di]
		jne	loc_184			; Jump if not equal
		retn
loc_184:
		inc	di
		loop	locloop_183		; Loop if cx > 0


;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_25:
loc_185:
		or	dl,dl			; Zero ?
		retn
sub_24		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_26		proc	near
		mov	si,ds:data_193e
loc_186:
		mov	di,[si]
		cmp	di,0FFFFh
		jne	loc_187			; Jump if not equal
		retn
loc_187:
		add	si,3
		mov	al,[si-1]
		and	al,[di]
		jnz	loc_189			; Jump if not zero
loc_188:
		mov	di,[si]
		cmp	di,0FFFFh
		je	loc_190			; Jump if equal
		add	si,4
		jmp	short loc_188
loc_189:
		mov	di,[si]
		cmp	di,0FFFFh
		je	loc_190			; Jump if equal
		mov	ax,[si+2]
		mov	[di],ax
		add	si,4
		jmp	short loc_189
loc_190:
		inc	si
		inc	si
		jmp	short loc_186
sub_26		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_27		proc	near
		mov	si,6C44h
		call	word ptr cs:[200Eh]
		mov	si,6C4Ch
		call	word ptr cs:[200Eh]
		retn
sub_27		endp

			                        ;* No entry point to code
		or	ax,1BBh
		add	al,47h			; 'G'
		dec	di
		dec	sp
		inc	sp
		or	ax,1AFh
		add	ax,4C50h
		inc	cx
		inc	bx
		inc	bp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_28		proc	near
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,21h			; '!'
		call	word ptr cs:[2004h]
		mov	bx,2310h
		mov	al,80h
		mov	ch,67h			; 'g'
		call	word ptr cs:[2004h]
		mov	bx,0AA9h
		mov	dx,0AB5h
		mov	cx,0E03h
		call	word ptr cs:[202Ch]
		mov	bx,21Ch
		xor	al,al			; Zero register
		mov	ch,42h			; 'B'
		call	word ptr cs:[2004h]
		mov	si,6C8Fh
		jmp	word ptr cs:[200Eh]
sub_28		endp

			                        ;* No entry point to code
		or	ax,2AFh
		add	ax,4E45h
		inc	bp
		dec	bp
		pop	cx

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_29		proc	near
		mov	si,data_202e
		mov	cx,word ptr ds:[80h]
		or	cx,cx			; Zero ?
		jz	loc_193			; Jump if zero

locloop_191:
		xor	dh,dh			; Zero register
loc_192:
		call	sub_30
		inc	si
		add	dh,bh
		cmp	dh,40h			; '@'
		jb	loc_192			; Jump if below
		loop	locloop_191		; Loop if cx > 0

loc_193:
		mov	ds:data_144e,si
		mov	di,0E000h
		mov	ax,word ptr ds:[80h]
		mov	cx,24h

locloop_194:
		push	di
		call	sub_32
		pop	di
		inc	di
		inc	ax
		cmp	ax,ds:data_188e
		jne	loc_195			; Jump if not equal
		mov	si,0C01Bh
		xor	ax,ax			; Zero register
loc_195:
		loop	locloop_194		; Loop if cx > 0

		or	ax,ax			; Zero ?
		jnz	loc_196			; Jump if not zero
		mov	si,ds:data_201e
loc_196:
		dec	si
		mov	ds:data_145e,si
		mov	al,byte ptr ds:[82h]
		xor	ah,ah			; Zero register
		call	sub_33
		mov	ds:data_224e,di
		retn
sub_29		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_30		proc	near
		mov	bl,[si]
		and	bl,0C0h
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_97e[bx]	;*
sub_30		endp

			                        ;* No entry point to code
		pop	ds
		db	 6Dh, 2Fh, 6Dh, 47h, 6Dh, 4Fh
		db	 6Dh

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_31		proc	near
		mov	bl,[si]
		and	bl,0C0h
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_98e[bx]	;*
sub_31		endp

			                        ;* No entry point to code
		daa				; Decimal adjust
		db	 6Dh, 2Fh, 6Dh, 47h, 6Dh, 4Fh
		db	 6Dh, 8Ah, 3Ch,0FEh,0C7h, 46h
		db	 8Ah, 1Ch,0C3h, 8Ah, 1Ch, 4Eh
		db	 8Ah, 3Ch,0FEh,0C7h,0C3h, 8Ah
		db	 1Ch, 8Ah,0FBh,0D0h,0EFh,0D0h
		db	0EFh,0D0h,0EFh,0D0h,0EFh, 80h
		db	0E7h, 03h, 80h,0C7h, 02h, 80h
		db	0E3h, 0Fh,0FEh,0C3h,0C3h, 8Ah
		db	 3Ch, 80h,0E7h, 3Fh, 32h,0DBh
		db	0C3h, 8Ah, 1Ch, 80h,0E3h, 3Fh
		db	0B7h, 01h,0C3h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_32		proc	near
		xor	dl,dl			; Zero register
loc_197:
		call	sub_30
		inc	si
		add	dl,bh
loc_198:
		mov	[di],bl
		add	di,24h
		dec	bh
		jnz	loc_198			; Jump if not zero
		cmp	dl,40h			; '@'
		jb	loc_197			; Jump if below
		retn
sub_32		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_33		proc	near
		push	bx
		and	al,3Fh			; '?'
		mov	bl,ah
		mov	bh,24h			; '$'
		mul	bh			; ax = reg * al
		xor	bh,bh			; Zero register
		add	ax,bx
		add	ax,0E000h
		mov	di,ax
		pop	bx
		retn
sub_33		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_34		proc	near
loc_199:
		cmp	si,0E900h
		jae	loc_200			; Jump if above or =
		retn
loc_200:
		sub	si,900h
		retn
sub_34		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_35		proc	near
		cmp	si,0E000h
		jb	loc_201			; Jump if below
		retn
loc_201:
		add	si,900h
		retn
sub_35		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_36		proc	near
		cmp	byte ptr ds:data_196e,4
		je	loc_202			; Jump if equal
		retn
loc_202:
		cmp	byte ptr ds:[9Eh],4
		jne	loc_203			; Jump if not equal
		mov	al,0FFh
		or	al,al			; Zero ?
		retn
loc_203:
		xor	al,al			; Zero register
		retn
sub_36		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_37		proc	near
		mov	al,byte ptr ds:[84h]
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		mov	si,ax
		add	si,ds:data_224e
		jmp	short loc_199
sub_37		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_38		proc	near
		mov	al,[si]
		test	al,80h
		stc				; Set carry flag
		jnz	loc_204			; Jump if not zero
		retn
loc_204:
		and	al,7Fh
		mov	cl,10h
		mul	cl			; ax = reg * al
		mov	bx,ax
		add	bx,ds:data_195e
		mov	al,[bx+4]
		or	al,al			; Zero ?
		retn
sub_38		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_39		proc	near
		cmp	al,40h			; '@'
		jb	loc_205			; Jump if below
		cmp	al,al
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_40:
		cmp	al,49h			; 'I'
		jb	loc_205			; Jump if below
		cmp	al,al
		retn
loc_205:
		push	di
		push	cx
		mov	es,cs:data_220e
		mov	di,data_1e
		mov	cx,18h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		pop	cx
		pop	di
		jnz	loc_206			; Jump if not zero
		retn
loc_206:
		and	al,9Fh
		cmp	al,90h
		je	loc_207			; Jump if equal
		cmp	al,91h
		je	loc_207			; Jump if equal
		and	al,80h
		cmp	al,80h
		retn
loc_207:
		mov	al,0FFh
		or	al,al			; Zero ?
		retn
sub_39		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_41		proc	near
		cmp	al,49h			; 'I'
		jb	loc_208			; Jump if below
		cmp	al,al
		retn
loc_208:
		push	di
		push	cx
		mov	es,cs:data_220e
		mov	di,data_1e
		mov	cx,18h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		pop	cx
		pop	di
		jnz	loc_209			; Jump if not zero
		retn
loc_209:
		and	al,80h
		cmp	al,80h
		retn
sub_41		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_42		proc	near
		test	byte ptr ds:[92h],0FFh
		jnz	loc_210			; Jump if not zero
		retn
loc_210:
		int	61h			; ??INT Non-standard interrupt
		test	ah,1
		jz	loc_212			; Jump if zero
		test	byte ptr ds:data_234e,0FFh
		jz	loc_212			; Jump if zero
		test	byte ptr ds:data_239e,0FFh
		jnz	loc_212			; Jump if not zero
		test	al,2
		jz	loc_212			; Jump if zero
		mov	byte ptr ds:data_242e,2
		mov	byte ptr ds:data_243e,2
		test	byte ptr ds:data_244e,0FFh
		jz	loc_211			; Jump if zero
		jmp	loc_223
loc_211:
		mov	byte ptr ds:data_244e,0FFh
		mov	byte ptr ds:data_247e,4
		jmp	short loc_223
loc_212:
		mov	byte ptr ds:data_244e,0
		test	byte ptr ds:data_217e,0FFh
		jnz	loc_213			; Jump if not zero
		retn
loc_213:
		test	byte ptr ds:data_240e,0FFh
		jz	loc_214			; Jump if zero
		retn
loc_214:
		test	byte ptr ds:data_233e,0FFh
		jz	loc_215			; Jump if zero
		retn
loc_215:
		test	byte ptr ds:data_226e,0FFh
		jnz	loc_219			; Jump if not zero
		call	sub_37
		sub	si,93h
		call	sub_35
		xor	dl,dl			; Zero register
		mov	cx,4

locloop_216:
		push	cx
		mov	cx,8

locloop_217:
		push	cx
		call	sub_38
		jc	loc_218			; Jump if carry Set
		test	al,60h			; '`'
		jnz	loc_218			; Jump if not zero
		test	byte ptr [bx+7],10h
		jnz	loc_218			; Jump if not zero
		mov	dl,0FFh
loc_218:
		inc	si
		pop	cx
		loop	locloop_217		; Loop if cx > 0

		add	si,1Ch
		call	sub_34
		pop	cx
		loop	locloop_216		; Loop if cx > 0

		or	dl,dl			; Zero ?
		jnz	loc_220			; Jump if not zero
loc_219:
		int	61h			; ??INT Non-standard interrupt
		test	al,1
		jz	loc_221			; Jump if zero
loc_220:
		mov	byte ptr ds:data_242e,1
		mov	byte ptr ds:data_243e,0
		jmp	short loc_222
loc_221:
		mov	byte ptr ds:data_242e,0
		mov	byte ptr ds:data_243e,0
loc_222:
		mov	byte ptr ds:data_247e,3
loc_223:
		mov	byte ptr ds:data_217e,0
		mov	byte ptr ds:data_218e,0
		mov	byte ptr ds:data_240e,0FFh
		retn
sub_42		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_43		proc	near
		test	byte ptr ds:data_240e,0FFh
		jnz	loc_224			; Jump if not zero
		retn
loc_224:
		test	byte ptr ds:data_226e,0FFh
		jz	loc_225			; Jump if zero
		test	byte ptr ds:data_221e,0FFh
		jz	loc_225			; Jump if zero
		retn
loc_225:
		call	sub_37
		mov	bx,90h
		test	byte ptr ds:data_230e,0FFh
		jz	loc_226			; Jump if zero
		mov	bx,6Ch
loc_226:
		sub	si,bx
		call	sub_35
		mov	bl,byte ptr ds:[0C2h]
		and	bl,1
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,bl
		mov	al,ds:data_242e
		mov	ah,0
		or	al,al			; Zero ?
		jz	loc_227			; Jump if zero
		mov	ah,6
		dec	al
		jz	loc_227			; Jump if zero
		mov	al,bl
		add	al,0Ah
		jmp	short loc_228
loc_227:
		mov	al,ds:data_243e
		or	al,bl
		add	al,ah
loc_228:
		and	al,0FEh
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	es,cs:data_220e
		mov	di,es:data_8e[bx]
loc_229:
		mov	al,es:[di]
		inc	di
		cmp	al,0FFh
		jne	loc_230			; Jump if not equal
		retn
loc_230:
		xor	ah,ah			; Zero register
		add	si,ax
		call	sub_34
		call	sub_38
		jc	loc_229			; Jump if carry Set
		test	al,20h			; ' '
		jnz	loc_229			; Jump if not zero
		test	byte ptr [bx+5],20h	; ' '
		jnz	loc_229			; Jump if not zero
		or	byte ptr [bx+5],40h	; '@'
		and	byte ptr [bx+5],0E0h
		or	byte ptr [bx+5],1
		jmp	short loc_229
sub_43		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_44		proc	near
loc_231:
		mov	al,2
		cmp	byte ptr ds:[9Eh],1
		jne	loc_232			; Jump if not equal
		mov	al,4
loc_232:
		mov	ds:data_152e,al
		call	sub_61
		test	byte ptr ds:data_234e,0FFh
		jnz	loc_234			; Jump if not zero
		mov	byte ptr ds:data_148e,0
		mov	al,ds:data_141e
		cmp	al,byte ptr ds:[84h]
		je	loc_234			; Jump if equal
		jc	loc_233			; Jump if carry Set
		call	sub_11
		inc	byte ptr ds:[84h]
		jmp	short loc_234
loc_233:
		call	sub_21
		dec	byte ptr ds:[84h]
loc_234:
		test	byte ptr ds:[0E6h],0FFh
		jnz	loc_235			; Jump if not zero
		test	byte ptr ds:data_226e,0FFh
		jz	loc_236			; Jump if zero
loc_235:
		mov	si,ds:data_183e
		add	si,7
		mov	al,[si]
		cmp	byte ptr ds:[83h],al
		je	loc_237			; Jump if equal
		call	sub_16
		dec	byte ptr ds:[83h]
		jmp	short loc_237
loc_236:
		mov	al,byte ptr ds:[83h]
		cmp	al,0Ch
		je	loc_237			; Jump if equal
		call	sub_13
		inc	byte ptr ds:[83h]
loc_237:
		mov	al,byte ptr ds:[84h]
		add	al,byte ptr ds:[82h]
		and	al,3Fh			; '?'
		mov	ds:data_227e,al
		call	sub_64
		call	sub_85
		call	sub_77
		call	sub_83
		call	sub_66
		call	sub_111
		test	byte ptr ds:data_223e,0FFh
		jnz	loc_238			; Jump if not zero
		call	sub_116
loc_238:
		mov	byte ptr ds:data_228e,0
		mov	byte ptr ds:data_156e,0
;*		call	sub_55			;*
		db	0E8h,0E3h, 04h		;  Fixup - byte match
		call	word ptr cs:data_73
		call	sub_94
		call	sub_104
		call	word ptr cs:data_74
		call	sub_54
		cmp	byte ptr ds:data_196e,7
		jne	loc_239			; Jump if not equal
		cmp	byte ptr ds:[9Eh],5
		je	loc_239			; Jump if equal
		inc	byte ptr ds:data_172e
		test	byte ptr ds:data_172e,3Fh	; '?'
		jnz	loc_239			; Jump if not zero
		mov	byte ptr ds:data_228e,0FFh
		mov	byte ptr ds:data_247e,9
		mov	ax,0Fh
		call	sub_60
		mov	dx,9BB9h
		call	sub_50
loc_239:
		call	sub_46
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_240			; Jump if zero
		mov	byte ptr ds:data_228e,0
		jmp	short loc_241

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_45:
loc_240:
		mov	byte ptr ds:data_229e,0
loc_241:
		mov	byte ptr ds:data_237e,0
		test	byte ptr ds:data_240e,0FFh
		jz	loc_242			; Jump if zero
		mov	byte ptr ds:data_237e,0FFh
		mov	al,ds:data_242e
		mov	ds:data_238e,al
		mov	al,ds:data_243e
		mov	ds:data_236e,al
		jmp	short loc_243
loc_242:
		test	byte ptr ds:data_233e,0FFh
		jz	loc_243			; Jump if zero
		mov	byte ptr ds:data_237e,0FFh
		mov	al,ds:data_178e
		mov	ds:data_236e,al
		mov	byte ptr ds:data_238e,1
loc_243:
		test	byte ptr ds:data_229e,0FFh
		jnz	loc_244			; Jump if not zero
		call	sub_53
loc_244:
		call	word ptr cs:data_72
		test	byte ptr ds:[0E8h],0FFh
		jnz	loc_246			; Jump if not zero
		mov	ax,word ptr ds:[0C6h]
		or	ax,ax			; Zero ?
		jz	loc_246			; Jump if zero
		dec	ax
		mov	word ptr ds:[0C6h],ax
		add	word ptr ds:[90h],8
		mov	ax,word ptr ds:[0B2h]
		cmp	ax,word ptr ds:[90h]
		jae	loc_245			; Jump if above or =
		mov	ax,word ptr ds:[0B2h]
		mov	word ptr ds:[90h],ax
		mov	word ptr ds:[0C6h],0
loc_245:
		mov	byte ptr ds:data_247e,13h
		call	word ptr cs:[2008h]
loc_246:
		call	word ptr cs:data_71
		test	byte ptr ds:data_222e,0FFh
		jz	loc_247			; Jump if zero
		call	word ptr cs:data_78
		mov	byte ptr ds:data_219e,0Ah
loc_247:
		mov	cl,ds:data_225e
		mov	al,2
		mul	cl			; ax = reg * al
loc_248:
		cmp	ds:data_216e,al
		jb	loc_248			; Jump if below
		call	sub_104
		call	word ptr cs:data_73
		call	sub_90
		call	sub_102
		call	sub_109
		call	sub_43
		call	word ptr cs:data_74
		mov	cl,ds:data_225e
		mov	al,4
		mul	cl			; ax = reg * al
loc_249:
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		call	word ptr cs:[11Eh]
		jnc	loc_250			; Jump if carry=0
		call	sub_65
loc_250:
		pop	ax
		cmp	ds:data_216e,al
		jb	loc_249			; Jump if below
		mov	byte ptr ds:data_216e,0
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_251			; Jump if zero
		retn
loc_251:
		test	byte ptr ds:[7Fh],0FFh
		jnz	loc_252			; Jump if not zero
		test	word ptr ds:[90h],0FFFFh
		jnz	loc_252			; Jump if not zero
		jmp	loc_703
loc_252:
		inc	byte ptr ds:data_160e
		cmp	byte ptr ds:data_160e,10h
		jb	loc_253			; Jump if below
		mov	byte ptr ds:data_160e,0
		mov	ax,word ptr ds:[90h]
		cmp	ax,word ptr ds:[0B2h]
		jae	loc_253			; Jump if above or =
		add	ax,2
		mov	word ptr ds:[90h],ax
		call	word ptr cs:[2008h]
loc_253:
		test	byte ptr ds:data_165e,0FFh
		jz	loc_254			; Jump if zero
		jmp	loc_267
loc_254:
		test	byte ptr ds:data_226e,0FFh
		jz	loc_255			; Jump if zero
		test	byte ptr ds:data_223e,0FFh
		jz	loc_255			; Jump if zero
		cmp	byte ptr ds:data_213e,0FFh
		jne	loc_255			; Jump if not equal
		mov	si,ds:data_183e
		add	si,5
		lodsw				; String [si] to ax
		push	si
		call	sub_143
		pop	si
		add	si,4
		lodsw				; String [si] to ax
		call	sub_120
		mov	byte ptr ds:data_165e,0FFh
loc_255:
		test	byte ptr ds:data_221e,0FFh
		jz	loc_256			; Jump if zero
		retn
loc_256:
		test	word ptr ds:data_215e,1
		jnz	loc_263			; Jump if not zero
		mov	byte ptr ds:data_133e,0
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_46:
		test	byte ptr ds:data_129e,0FFh
		jz	loc_259			; Jump if zero
		mov	al,0FCh
		inc	byte ptr ds:data_127e
		test	byte ptr ds:data_127e,1Fh
		jnz	loc_257			; Jump if not zero
		mov	al,0FEh
		mov	byte ptr ds:data_129e,0
loc_257:
		push	cs
		pop	es
		mov	di,data_208e
		mov	cl,ds:data_130e
		xor	ch,ch			; Zero register

locloop_258:
		push	cx
		mov	cx,12h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		add	di,0Ah
		pop	cx
		loop	locloop_258		; Loop if cx > 0

loc_259:
		test	byte ptr ds:data_128e,0FFh
		jnz	loc_260			; Jump if not zero
		retn
loc_260:
		mov	al,0FCh
		inc	byte ptr ds:data_126e
		and	byte ptr ds:data_126e,1Fh
		jnz	loc_261			; Jump if not zero
		mov	al,0FEh
		mov	byte ptr ds:data_128e,0
loc_261:
		push	ds
		pop	es
		mov	di,data_209e
		mov	cx,2

locloop_262:
		push	cx
		push	di
		mov	cx,1Ah
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,1Ch
		pop	cx
		loop	locloop_262		; Loop if cx > 0

		retn
loc_263:
		mov	al,ds:data_133e
		or	al,ds:data_233e
		or	al,ds:data_235e
		or	al,ds:data_173e
		jz	loc_264			; Jump if zero
		retn
loc_264:
		mov	byte ptr ds:data_247e,0Bh
		call	word ptr cs:[2002h]
		call	sub_47
		call	word ptr cs:data_182e
		call	sub_47
		cmp	byte ptr ds:data_246e,8
		jne	loc_265			; Jump if not equal
		jmp	loc_710
loc_265:
		call	word ptr cs:[2002h]
		push	ds
		call	word ptr cs:data_83
		mov	cx,18h
		call	word ptr cs:[2044h]
		pop	ds
		mov	byte ptr ds:data_133e,0FFh
		call	sub_48
		mov	byte ptr ds:data_217e,0
		mov	byte ptr ds:data_218e,0
		mov	byte ptr ds:data_128e,0
		mov	byte ptr ds:data_129e,0
		jmp	loc_231

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_47:
		mov	es,cs:data_220e
		mov	di,data_9e
		mov	si,data_182e
		mov	cx,800h

locloop_266:
		mov	ax,es:[di]
		movsw				; Mov [si] to es:[di]
		mov	[si-2],ax
		loop	locloop_266		; Loop if cx > 0

		retn
loc_267:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_268			; Jump if zero
		retn
loc_268:
		mov	si,ds:data_187e
		add	si,6
		lodsb				; String [si] to al
		push	si
		mov	ds:data_139e,al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9CBCh
		mov	si,ax
		push	cs
		pop	es
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		pop	si
		lodsb				; String [si] to al
		mov	ds:data_140e,al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9D8Dh
		mov	si,ax
		mov	es,cs:data_220e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_220e
		mov	si,4000h
		mov	bp,0A000h
		mov	cx,100h
		call	word ptr cs:data_89
		pop	ds
		mov	byte ptr ds:data_226e,0
		mov	si,ds:data_187e
		add	si,8
loc_269:
		lodsw				; String [si] to ax
		cmp	ax,0FFFFh
		je	loc_270			; Jump if equal
		mov	bx,ax
		lodsw				; String [si] to ax
		mov	[bx],ax
		jmp	short loc_269
loc_270:
		call	sub_37
		mov	ax,word ptr ds:[80h]
		mov	bl,byte ptr ds:[83h]
		xor	bh,bh			; Zero register
		add	ax,bx
		test	byte ptr [si-5],0FFh
		jz	loc_271			; Jump if zero
		add	ax,9
loc_271:
		mov	bx,ax
		sub	bx,ds:data_188e
		jc	loc_272			; Jump if carry Set
		mov	ax,bx
loc_272:
		mov	si,ds:data_192e
		mov	[si],ax
		call	sub_66
		call	sub_46
		call	sub_53
		call	word ptr cs:data_79
		mov	bx,21Ch
		xor	al,al			; Zero register
		mov	ch,42h			; 'B'
		call	word ptr cs:[2004h]
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:data_165e,0
		jmp	loc_1
sub_44		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_48		proc	near
loc_273:
		push	cs
		pop	es
		mov	di,data_207e
		mov	cx,214h
		mov	al,0FDh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn
sub_48		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_49		proc	near
loc_274:
		push	di
		mov	es,cs:data_220e
		mov	di,data_4e
		mov	cx,4

locloop_275:
		mov	ah,es:[di]
		inc	di
		or	ah,ah			; Zero ?
		jz	loc_276			; Jump if zero
		cmp	ah,al
		je	loc_277			; Jump if equal
		loop	locloop_275		; Loop if cx > 0

loc_276:
		mov	ah,0FFh
		or	ah,ah			; Zero ?
loc_277:
		pop	di
		retn
sub_49		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_50		proc	near
loc_278:
		push	si
		push	dx

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_51:
		mov	bx,0E1Eh
		mov	cx,3410h
		mov	al,0FFh
		call	word ptr cs:[2000h]
		mov	byte ptr ds:data_126e,0
		mov	byte ptr ds:data_128e,0FFh
		mov	byte ptr ds:data_127e,0FFh
		pop	si
		lodsw				; String [si] to ax
		add	ax,3Ah
		mov	bx,ax
		mov	cl,22h			; '"'
		call	word ptr cs:[202Ah]
		pop	si
		retn
sub_50		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_52		proc	near
		lodsb				; String [si] to al
		add	al,19h
		mov	cl,al
		push	cx
		lodsb				; String [si] to al
		push	si
		add	al,2
		mov	ds:data_130e,al
		mov	bl,8
		mul	bl			; ax = reg * al
		mov	bx,1616h
		mov	ch,24h			; '$'
		mov	cl,al
		mov	al,0FFh
		call	word ptr cs:[2000h]
		pop	si
		mov	byte ptr ds:data_126e,0
		mov	byte ptr ds:data_128e,0
		mov	byte ptr ds:data_127e,0
		mov	byte ptr ds:data_129e,0FFh
		mov	bx,58h
		pop	cx
loc_279:
		mov	ds:data_131e,bx
		mov	ds:data_132e,cl
		lodsb				; String [si] to al
		xor	ah,ah			; Zero register
		add	bx,ax
loc_280:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_281			; Jump if not equal
		retn
loc_281:
		cmp	al,2Fh			; '/'
		je	loc_282			; Jump if equal
		mov	ah,1
		push	cx
		push	bx
		push	si
		call	word ptr cs:[2022h]
		pop	si
		pop	bx
		pop	cx
		add	bx,8
		jmp	short loc_280
loc_282:
		mov	bx,ds:data_131e
		mov	cl,ds:data_132e
		add	cl,0Ch
		jmp	short loc_279
sub_52		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_53		proc	near
		mov	al,byte ptr ds:[84h]
		mov	cl,1Ch
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		xor	ch,ch			; Zero register
		add	ax,cx
		add	ax,0E900h
		mov	di,ax
		push	cs
		pop	es
		mov	al,0FFh
		mov	cx,3

locloop_283:
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	di,19h
		loop	locloop_283		; Loop if cx > 0

		retn
sub_53		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_54		proc	near
		cmp	byte ptr ds:[9Eh],2
		jne	loc_284			; Jump if not equal
		retn
loc_284:
		mov	byte ptr ds:data_159e,0
		call	sub_37
		mov	cx,3
		test	byte ptr ds:data_230e,0FFh
		jz	locloop_285		; Jump if zero
		add	si,24h
		call	sub_34
		dec	cx

locloop_285:
		push	cx
		mov	cx,3

locloop_286:
		push	cx
		mov	al,[si]
		inc	si
		call	sub_49
		jnz	loc_287			; Jump if not zero
		mov	byte ptr ds:data_159e,0FFh
loc_287:
		pop	cx
		loop	locloop_286		; Loop if cx > 0

		add	si,21h
		call	sub_34
		pop	cx
		loop	locloop_285		; Loop if cx > 0

		test	byte ptr ds:data_231e,0FFh
		jnz	loc_288			; Jump if not zero
		inc	si
		mov	al,[si]
		call	sub_49
		jnz	loc_288			; Jump if not zero
		mov	byte ptr ds:data_159e,0FFh
loc_288:
		test	byte ptr ds:data_159e,0FFh
		jnz	loc_289			; Jump if not zero
		retn
loc_289:
		mov	byte ptr ds:data_228e,0FFh
		mov	byte ptr ds:data_247e,9
		mov	bl,ds:data_196e
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,ds:data_99e[bx]
		xor	ah,ah			; Zero register
		jmp	loc_310
			                        ;* No entry point to code
		add	[bx+di],ax
		add	al,8
		adc	al,14h
		adc	al,14h
		adc	al,0F6h
		push	es
		xor	al,0FFh
		push	word ptr [si+8]
		test	byte ptr ds:data_221e,0FFh
		jz	loc_290			; Jump if zero
		retn
loc_290:
		mov	word ptr ds:data_155e,0
		call	sub_37
		dec	si
		mov	di,9F0Eh
		mov	bx,7651h
		test	byte ptr ds:data_230e,0FFh
		jnz	loc_291			; Jump if not zero
		mov	bx,763Eh
		sub	si,24h
		call	sub_35
loc_291:
		push	bx
		push	di
		push	si
		call	bx			;*
		sbb	al,al
		mov	[di],al
		jz	loc_292			; Jump if zero
		call	sub_56
loc_292:
		pop	si
		pop	di
		pop	bx
		inc	si
		inc	di
		push	bx
		push	di
		push	si
		call	bx			;*
		jc	loc_293			; Jump if carry Set
		call	sub_59
loc_293:
		sbb	al,al
		mov	[di],al
		jz	loc_294			; Jump if zero
		call	sub_56
loc_294:
		pop	si
		pop	di
		pop	bx
		inc	si
		inc	di
		push	bx
		push	di
		push	si
		call	bx			;*
		jc	loc_295			; Jump if carry Set
		call	sub_59
loc_295:
		sbb	al,al
		mov	[di],al
		jz	loc_296			; Jump if zero
		call	sub_57
loc_296:
		pop	si
		pop	di
		pop	bx
		inc	si
		inc	di
		call	bx			;*
		sbb	al,al
		mov	[di],al
		jz	loc_297			; Jump if zero
		call	sub_57
loc_297:
		mov	di,data_153e
		mov	al,[di]
		or	al,[di+1]
		or	al,[di+2]
		or	al,[di+3]
		mov	ds:data_156e,al
		mov	ds:data_228e,al
		or	al,al			; Zero ?
		jz	loc_ret_298		; Jump if zero
		call	word ptr cs:[201Ah]

loc_ret_298:
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_56:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_299			; Jump if zero
		retn
loc_299:
		mov	ax,ds:data_155e
		test	byte ptr ds:[0C2h],1
		jz	loc_304			; Jump if zero
		jmp	short loc_301

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_57:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_300			; Jump if zero
		retn
loc_300:
		mov	ax,ds:data_155e
		test	byte ptr ds:[0C2h],1
		jnz	loc_304			; Jump if not zero
		jmp	short loc_301
loc_301:
		test	byte ptr ds:[93h],0FFh
		jz	loc_304			; Jump if zero
		shr	ax,1			; Shift w/zeros fill
		mov	cl,byte ptr ds:[93h]
		inc	cl
		shr	cl,1			; Shift w/zeros fill
		shr	ax,cl			; Shift w/zeros fill
		sub	word ptr ds:[94h],ax
		jc	loc_302			; Jump if carry Set
		jnz	loc_303			; Jump if not zero
loc_302:
		push	ax
		call	sub_58
		mov	word ptr ds:[94h],0
		pop	ax
loc_303:
		call	sub_60
		mov	byte ptr ds:data_247e,8
		retn
loc_304:
		call	sub_60
		mov	byte ptr ds:data_247e,9
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_58:
		mov	byte ptr ds:[93h],0
		mov	bx,0C51Ch
		mov	al,0FFh
		mov	ch,18h
		call	word ptr cs:[2004h]
		mov	bx,3EA3h
		mov	cx,511h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		mov	dx,9AB4h
		jmp	loc_278
			                        ;* No entry point to code
		call	sub_38
		jc	loc_305			; Jump if carry Set
		test	al,40h			; '@'
		jnz	loc_305			; Jump if not zero
		and	al,0Fh
		jmp	short loc_309
loc_305:
		add	si,24h
		call	sub_34
		call	sub_38
		jc	loc_306			; Jump if carry Set
		test	al,40h			; '@'
		jnz	loc_306			; Jump if not zero
		and	al,0Fh
		jmp	short loc_309

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_59:
loc_306:
		add	si,24h
		call	sub_34
		call	sub_38
		cmc				; Complement carry
		jc	loc_307			; Jump if carry Set
		retn
loc_307:
		clc				; Clear carry flag
		test	al,40h			; '@'
		jz	loc_308			; Jump if zero
		retn
loc_308:
		and	al,0Fh
		jmp	short loc_309
loc_309:
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	al,ds:data_186e[bx]
		xor	ah,ah			; Zero register
		add	ds:data_155e,ax
		stc				; Set carry flag
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_60:
loc_310:
		sub	word ptr ds:[90h],ax
		jnc	loc_311			; Jump if carry=0
		mov	word ptr ds:[90h],0
loc_311:
		push	si
		call	word ptr cs:[2008h]
		pop	si
		retn
sub_54		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_61		proc	near
		mov	byte ptr ds:data_157e,0
		call	sub_37
		add	si,49h
		call	sub_34
		mov	cx,3

locloop_312:
		push	cx
		call	sub_62
		sub	si,24h
		call	sub_35
		pop	cx
		loop	locloop_312		; Loop if cx > 0

		retn
sub_61		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_62		proc	near
		mov	al,[si]
		push	si
		call	sub_63
		pop	si
		jz	loc_314			; Jump if zero
		retn
loc_314:
		pop	ax
		pop	ax
		mov	bl,cl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_100e[bx]	;*
sub_62		endp

			                        ;* No entry point to code
;*		aam	76h			; 'v' undocumented inst
		db	0D4h, 76h		;  Fixup - byte match
;*                         lock	jbe	loc_313			;*Jump if below or =
		db	0F0h, 76h,0EAh		;  Fixup - byte match
;*		jbe	loc_313			;*Jump if below or =
		db	 76h,0E8h		;  Fixup - byte match
		dec	dx
		out	dx,ax			; port 0FFFFh ??I/O Non-standard
		call	sub_11
		mov	byte ptr ds:data_157e,0FFh
		mov	byte ptr ds:data_234e,0
		mov	byte ptr ds:[0E7h],80h
		retn
			                        ;* No entry point to code
		call	sub_16
		jmp	loc_116
			                        ;* No entry point to code
		call	sub_13
		jmp	loc_87

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_63		proc	near
		or	al,al			; Zero ?
		jz	loc_323			; Jump if zero
		mov	es,cs:data_220e
		mov	bh,al
		xor	cl,cl			; Zero register
		mov	si,data_5e
		mov	bl,4
loc_315:
		mov	al,es:[si]
		inc	si
		or	al,al			; Zero ?
		jz	loc_317			; Jump if zero
		cmp	al,bh
		jne	loc_316			; Jump if not equal
		retn
loc_316:
		dec	bl
		jnz	loc_315			; Jump if not zero
loc_317:
		inc	cl
		mov	si,data_6e
		mov	bl,4
loc_318:
		mov	al,es:[si]
		inc	si
		or	al,al			; Zero ?
		jz	loc_320			; Jump if zero
		cmp	al,bh
		jne	loc_319			; Jump if not equal
		retn
loc_319:
		dec	bl
		jnz	loc_318			; Jump if not zero
loc_320:
		inc	cl
		mov	si,data_7e
		mov	bl,4
loc_321:
		mov	al,es:[si]
		inc	si
		or	al,al			; Zero ?
		jz	loc_323			; Jump if zero
		cmp	al,bh
		jne	loc_322			; Jump if not equal
		retn
loc_322:
		dec	bl
		jnz	loc_321			; Jump if not zero
loc_323:
		mov	cl,0FFh
		or	cl,cl			; Zero ?
		retn
sub_63		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_64		proc	near
		mov	ax,ds:data_197e
		cmp	ax,0FFFFh
		je	loc_328			; Jump if equal
		call	sub_141
		jc	loc_328			; Jump if carry Set
		mov	al,byte ptr ds:[83h]
		add	al,4
		mov	ah,al
		sub	al,bl
		jnc	loc_324			; Jump if carry=0
		neg	al
loc_324:
		mov	bh,al
		sub	bl,ah
		jnc	loc_325			; Jump if carry=0
		neg	bl
loc_325:
		cmp	bl,bh
		jb	loc_326			; Jump if below
		mov	bl,bh
loc_326:
		mov	ds:data_179e,bl
		mov	bl,ds:data_198e
		mov	bh,ds:data_227e
		mov	al,bh
		sub	al,bl
		and	al,3Fh			; '?'
		sub	bl,bh
		and	bl,3Fh			; '?'
		cmp	bl,al
		jb	loc_327			; Jump if below
		mov	bl,al
loc_327:
		mov	ds:data_180e,bl
		cmp	byte ptr ds:data_179e,10h
		jae	loc_328			; Jump if above or =
		mov	al,ds:data_179e
		mov	bx,data_101e
		xlat				; al=[al+[bx]] table
		mov	dl,al
		cmp	byte ptr ds:data_180e,10h
		jae	loc_328			; Jump if above or =
		mov	al,ds:data_180e
		mov	bx,data_101e
		xlat				; al=[al+[bx]] table
		add	al,dl
		jc	loc_328			; Jump if carry Set
		mov	bx,data_102e
		xlat				; al=[al+[bx]] table
		mov	ds:data_214e,al
		retn
loc_328:
		mov	byte ptr ds:data_214e,0
		retn
sub_64		endp

		db	 00h, 01h, 04h, 09h, 10h, 19h
		db	 24h, 31h, 40h, 51h, 64h, 79h
		db	 90h,0A9h,0C4h,0E1h
		db	17 dup (0Fh)
		db	20 dup (0Eh)
		db	0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh
		db	0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh
		db	0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh
		db	0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh
		db	0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch
		db	0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch
		db	0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch
		db	0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch
		db	0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch
		db	0Ch, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 8, 8, 8, 8, 8, 8, 8
		db	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
		db	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
		db	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
		db	8, 8, 8, 8, 8, 8, 8, 8, 8
		db	59 dup (6)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_65		proc	near
		mov	bx,601Ch
		jmp	loc_367
sub_65		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_66		proc	near
		mov	bp,ds:data_192e
loc_329:
		mov	ax,ds:[bp]
		cmp	ax,0FFFFh
		jne	loc_330			; Jump if not equal
		retn
loc_330:
		call	sub_68
		jc	loc_332			; Jump if carry Set
		mov	al,ds:[bp+3]
		and	al,7
		add	al,61h			; 'a'
		mov	ds:data_104e,al
		mov	ds:data_105e,al
		mov	al,ds:[bp+2]
		xor	ah,ah			; Zero register
		call	sub_33
		cmp	bl,4
		jb	loc_333			; Jump if below
		mov	cx,bx
		sub	bl,27h			; '''
		neg	bl
		inc	bl
		mov	al,bl
		cmp	al,6
		jb	loc_331			; Jump if below
		mov	al,5
loc_331:
		sub	cl,4
		xor	ch,ch			; Zero register
		add	di,cx
		mov	si,79C8h
		test	byte ptr ds:[bp+3],80h
		jnz	loc_335			; Jump if not zero
		mov	si,79B4h
		jmp	short loc_335
loc_332:
		add	bp,0Ch
		jmp	short loc_329
loc_333:
		mov	si,79C8h
		test	byte ptr ds:[bp+3],80h
		jnz	loc_334			; Jump if not zero
		mov	si,data_103e
loc_334:
		mov	al,bl
		inc	al
		mov	cl,5
		sub	cl,al
		xor	ch,ch			; Zero register
		add	si,cx
loc_335:
		mov	cx,4

locloop_336:
		push	cx
		push	ax
		push	di
		push	si
loc_337:
		call	sub_67
		inc	di
		inc	si
		dec	al
		jnz	loc_337			; Jump if not zero
		pop	si
		add	si,5
		xchg	si,di
		pop	si
		add	si,24h
		call	sub_34
		xchg	di,si
		pop	ax
		pop	cx
		loop	locloop_336		; Loop if cx > 0

		jmp	short loc_332
sub_66		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_67		proc	near
		test	byte ptr [di],80h
		jz	loc_338			; Jump if zero
		retn
loc_338:
		mov	dl,[si]
		mov	[di],dl
		retn
sub_67		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_68		proc	near
		add	ax,3
		push	ax
		sub	ax,ds:data_188e
		pop	bx
		jnc	loc_339			; Jump if carry=0
		xchg	bx,ax
loc_339:
		push	ax
		sub	ax,word ptr ds:[80h]
		pop	bx
		jc	loc_340			; Jump if carry Set
		xchg	bx,ax
		mov	ax,27h
		sub	ax,bx
		retn
loc_340:
		mov	ax,27h
		sub	ax,bx
		jnc	loc_341			; Jump if carry=0
		retn
loc_341:
		mov	ax,ds:data_188e
		sub	ax,word ptr ds:[80h]
		add	ax,bx
		xchg	bx,ax
		mov	ax,27h
		sub	ax,bx
		retn
sub_68		endp

		db	'\', 27h, ', 0', 9, 9, '; 0x0000+'
		db	 00h,0C3h
		db	'IJaKLMOPQN_RST`_UVW`IJaKLMX', 0
		db	'YN_Z', 0
		db	'[`_\\]^`', 0
		db	0BCh,0F3h,0AAh,0F6h,0D0h,0A2h
		db	0F5h, 9Eh,0A2h,0FEh, 9Eh,0A2h
		db	0FFh, 9Eh,0E8h, 57h, 04h,0B0h
		db	0FFh,0A2h, 60h,0EBh,0A2h, 67h
		db	0EBh,0A2h, 6Eh,0EBh,0A2h, 75h
		db	0EBh,0C6h, 06h, 3Ah,0FFh, 00h
		db	 2Eh, 8Eh, 06h, 2Ch,0FFh,0BEh
		db	0E6h, 9Bh,0BFh, 00h, 60h,0B0h
		db	 02h, 2Eh,0FFh, 16h, 0Ch, 01h
		db	 1Eh, 2Eh, 8Eh, 1Eh, 2Ch,0FFh
		db	0BEh, 33h, 63h,0BDh, 00h,0D0h
		db	0B9h,0E6h, 00h, 2Eh,0FFh, 16h
		db	 28h, 30h, 1Fh, 8Bh, 36h, 00h
		db	0C0h,0ACh,0E8h, 4Dh, 04h, 2Eh
		db	0FFh, 16h, 02h, 20h,0BEh,0FDh
		db	 9Bh, 2Eh, 8Eh, 06h, 2Ch,0FFh
		db	0BFh, 00h, 80h,0B0h, 02h, 2Eh
		db	0FFh, 16h, 0Ch, 01h, 1Eh, 2Eh
		db	 8Eh, 1Eh, 2Ch,0FFh,0BEh, 00h
		db	 80h,0B9h, 80h, 00h, 2Eh,0FFh
		db	 16h, 44h, 20h, 1Fh, 32h,0C0h
		db	 2Eh,0FFh, 16h, 1Eh, 30h,0A0h
		db	0C4h, 00h, 0Ah,0C0h, 78h, 03h
		db	0E8h, 7Ch,0F1h
loc_342:
		jmp	loc_361

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_69		proc	near
		call	sub_37
		sub	si,25h
		call	sub_35
		cmp	byte ptr [si],4Ah	; 'J'
		je	loc_345			; Jump if equal
		inc	si
		cmp	byte ptr [si],4Ah	; 'J'
		je	loc_347			; Jump if equal
		inc	si
		cmp	byte ptr [si],4Ah	; 'J'
		je	loc_343			; Jump if equal
		retn
loc_343:
		test	byte ptr ds:[0C2h],1
		jz	loc_344			; Jump if zero
		retn
loc_344:
		pop	ax
		jmp	loc_116
loc_345:
		test	byte ptr ds:[0C2h],1
		jnz	loc_346			; Jump if not zero
		retn
loc_346:
		pop	ax
		jmp	loc_87
loc_347:
		mov	ax,word ptr ds:[80h]
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	bx,ds:data_188e
		dec	bx
		sub	bx,ax
		jnc	loc_348			; Jump if carry=0
		not	bx
		mov	ax,bx
loc_348:
		mov	bl,byte ptr ds:[84h]
		dec	bl
		add	bl,byte ptr ds:[82h]
		and	bl,3Fh			; '?'
		mov	si,ds:data_192e
loc_349:
		cmp	word ptr [si],0FFFFh
		jne	loc_350			; Jump if not equal
		retn
loc_350:
		cmp	ax,[si]
		jne	loc_351			; Jump if not equal
		cmp	bl,[si+2]
		je	loc_352			; Jump if equal
loc_351:
		add	si,0Ch
		jmp	short loc_349
loc_352:
		pop	ax
		test	byte ptr [si+3],80h
		jnz	loc_355			; Jump if not zero
		call	sub_72
		jc	loc_353			; Jump if carry Set
		retn
loc_353:
		mov	byte ptr ds:[0E7h],80h
		mov	byte ptr ds:data_168e,0
		test	byte ptr ds:data_161e,0FFh
		jz	loc_354			; Jump if zero
		retn
loc_354:
		mov	byte ptr ds:data_161e,0FFh
		mov	byte ptr ds:data_247e,16h
		mov	dx,9AC5h
		jmp	loc_278
loc_355:
		mov	bx,[si+9]
		cmp	bx,0FFFFh
		je	loc_356			; Jump if equal
		mov	al,[si+0Bh]
		or	[bx],al
loc_356:
		push	si
		call	sub_91
		call	sub_48
		call	word ptr cs:data_73
		call	sub_73
		call	sub_45
		mov	si,ds:data_195e
		mov	word ptr [si],0FFFFh
		pop	si
		mov	al,[si+3]
		and	al,7
		push	ax
		mov	ax,[si+5]
		mov	ds:data_162e,ax
		mov	al,[si+7]
		mov	ds:data_163e,al
		mov	al,[si+3]
		and	al,40h			; '@'
		mov	byte ptr ds:[0C3h],al
		mov	al,[si+8]
		mov	ds:data_164e,al
		mov	ah,[si+4]
		cmp	byte ptr [si+7],0FFh
		jne	loc_357			; Jump if not equal
		or	ah,80h
loc_357:
		mov	byte ptr ds:[0C4h],ah
		mov	al,1
		call	word ptr cs:[10Ch]
		test	byte ptr ds:[0C4h],80h
		jnz	loc_358			; Jump if not zero
		call	sub_26
loc_358:
		call	sub_70
		mov	si,ds:data_187e
		lodsb				; String [si] to al
		test	al,1
		jnz	loc_359			; Jump if not zero
		mov	si,9C08h
		mov	es,cs:data_220e
		mov	di,8000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_220e
		mov	si,8000h
		mov	cx,80h
		call	word ptr cs:[2044h]
		pop	ds
		pop	ax
		call	word ptr cs:data_86
		mov	byte ptr ds:data_134e,0FFh
		mov	byte ptr ds:data_219e,0Ah
		jmp	short loc_360
loc_359:
		mov	si,9BFDh
		mov	es,cs:data_220e
		mov	di,8000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_220e
		mov	si,8000h
		mov	cx,80h
		call	word ptr cs:[2044h]
		pop	ds
		pop	ax
		call	word ptr cs:data_86
		mov	si,ds:data_187e
		lodsb				; String [si] to al
		call	sub_74
loc_360:
		mov	byte ptr ds:data_232e,0
		mov	byte ptr ds:data_133e,0FFh
		mov	byte ptr ds:data_211e,0FFh
		test	byte ptr ds:data_164e,80h
		jz	loc_361			; Jump if zero
		mov	si,data_125e
		push	cs
		pop	es
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		call	word ptr cs:data_182e
		mov	byte ptr ds:data_140e,0FFh
		mov	byte ptr ds:data_139e,0FFh
		mov	al,byte ptr ds:[0C8h]
		mov	ds:data_138e,al
		mov	byte ptr ds:data_143e,0FFh
		call	sub_75
		mov	es,cs:data_220e
		mov	si,9BE6h
		mov	di,6000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_220e
		mov	si,6333h
		mov	bp,0D000h
		mov	cx,0E6h
		call	word ptr cs:data_89
		pop	ds
		jmp	loc_365
loc_361:
		test	byte ptr ds:[0C3h],0FFh
		jnz	loc_363			; Jump if not zero
		and	byte ptr ds:[0C2h],0FEh
		mov	bx,0A6Eh
		mov	cx,1Ah

locloop_362:
		push	cx
		push	bx
		inc	byte ptr ds:[0E7h]
		call	word ptr cs:data_81
		pop	bx
		add	bh,2
		push	bx
		call	word ptr cs:data_87
		call	sub_76
		pop	bx
		push	bx
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		pop	bx
		pop	cx
		loop	locloop_362		; Loop if cx > 0

		mov	cx,618h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		jmp	short loc_365
loc_363:
		or	byte ptr ds:[0C2h],1
		mov	bx,406Eh
		mov	cx,1Ah

locloop_364:
		push	cx
		push	bx
		inc	byte ptr ds:[0E7h]
		call	word ptr cs:data_81
		pop	bx
		sub	bh,2
		push	bx
		call	word ptr cs:data_87
		call	sub_76
		pop	bx
		push	bx
		add	bh,4
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		pop	bx
		pop	cx
		loop	locloop_364		; Loop if cx > 0

		mov	cx,618h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
loc_365:
		mov	si,ds:data_187e
		lodsb				; String [si] to al
		mov	ah,al
		and	al,1
		jz	loc_366			; Jump if zero
		call	sub_75
		mov	si,ds:data_187e
		lodsb				; String [si] to al
		mov	ah,al
		add	ah,ah
		sbb	bl,bl
		mov	ds:data_226e,bl
		add	ah,ah
		sbb	bl,bl
		mov	byte ptr ds:[0E6h],bl
		mov	byte ptr ds:data_221e,0
		mov	byte ptr ds:data_222e,0
		call	word ptr cs:[2002h]
		mov	byte ptr ds:[83h],0Ch
		mov	al,ds:data_199e
		mov	byte ptr ds:[84h],al
		mov	ds:data_141e,al
		mov	byte ptr ds:[0E7h],80h
		push	ds
		mov	ds,cs:data_220e
		mov	si,8030h
		mov	cx,66h
		call	word ptr cs:[2044h]
		call	word ptr cs:data_90
		pop	ds
		push	ds
		call	word ptr cs:data_83
		mov	cx,18h
		call	word ptr cs:[2044h]
		pop	ds
		jmp	loc_1
loc_366:
		mov	si,ds:data_187e
		inc	si
		lodsb				; String [si] to al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9C2Dh
		mov	si,ax
		mov	es,cs:data_220e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	bx,6000h
loc_367:
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		push	bx
		call	sub_71
		mov	word ptr ds:[80h],ax
		mov	byte ptr ds:[83h],bl
		mov	si,ds:data_187e
		lodsb				; String [si] to al
		shr	al,1			; Shift w/zeros fill
		and	al,1Fh
		mov	byte ptr ds:[0C8h],al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9E53h
		mov	si,ax
		mov	es,cs:data_220e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		pop	bx
		xor	al,al			; Zero register
		jmp	word ptr cs:[10Ch]
sub_69		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_70		proc	near
		mov	ax,ds:data_162e
		add	ax,0FFF0h
		or	ah,ah			; Zero ?
		jns	loc_368			; Jump if not sign
		add	ax,ds:data_188e
loc_368:
		mov	word ptr ds:[80h],ax
		mov	al,ds:data_163e
		inc	al
		sub	al,ds:data_199e
		and	al,3Fh			; '?'
		mov	byte ptr ds:[82h],al
		retn
sub_70		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_71		proc	near
		mov	bx,0Dh
		mov	ax,ds:data_162e
		mov	cx,ds:data_188e
		sub	cx,bx
		sub	cx,ax
		jnc	loc_369			; Jump if carry=0
		mov	ax,ds:data_188e
		add	ax,0FFDCh
		mov	cx,ds:data_162e
		sbb	cx,ax
		mov	bl,cl
		sub	bl,3
		retn
loc_369:
		add	ax,0FFEFh
		or	ah,ah			; Zero ?
		jnz	loc_370			; Jump if not zero
		retn
loc_370:
		xor	ax,ax			; Zero register
		mov	bl,ds:data_162e
		sub	bl,4
		retn
sub_71		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_72		proc	near
		mov	bl,[si+8]
		and	bl,1
		jnz	loc_372			; Jump if not zero
		test	byte ptr ds:[98h],0FFh
		stc				; Set carry flag
		jnz	loc_371			; Jump if not zero
		retn
loc_371:
		dec	byte ptr ds:[98h]
		mov	byte ptr ds:data_247e,15h
		or	byte ptr [si+3],80h
		mov	bx,[si+9]
		mov	al,[si+0Bh]
		or	[bx],al
		retn
loc_372:
		test	byte ptr ds:[99h],0FFh
		stc				; Set carry flag
		jnz	loc_373			; Jump if not zero
		retn
loc_373:
		dec	byte ptr ds:[99h]
		mov	byte ptr ds:data_247e,15h
		or	byte ptr [si+3],80h
		mov	bx,[si+9]
		mov	al,[si+0Bh]
		or	[bx],al
		retn
sub_72		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_73		proc	near
		xor	al,al			; Zero register
		mov	ds:data_240e,al
		mov	ds:data_241e,al
		mov	ds:data_233e,al
		mov	ds:data_234e,al
		mov	ds:data_230e,al
		mov	ds:data_228e,al
		mov	ds:data_128e,al
		mov	ds:data_235e,al
		mov	ds:data_246e,al
		mov	ds:data_214e,al
		mov	byte ptr ds:[0E7h],al
		mov	ax,0FFFFh
		mov	ds:data_211e,al
		mov	ds:data_213e,al
		mov	word ptr ds:[0EB15h],ax
		mov	ds:data_232e,al
		mov	ds:data_133e,al
		jmp	loc_273
sub_73		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_74		proc	near
		push	cs
		pop	es
		mov	di,data_134e
		mov	cx,4
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		shr	al,1			; Shift w/zeros fill
		and	al,0Fh
		mov	ah,al
		mov	al,0FFh
		cmp	ah,byte ptr ds:[0C8h]
		je	loc_374			; Jump if equal
		mov	byte ptr ds:data_219e,0Ah
		mov	byte ptr ds:[0C8h],ah
		mov	al,ah
loc_374:
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn
sub_74		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_75		proc	near
		mov	es,cs:data_220e
		mov	si,9C13h
		mov	di,8C00h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	bl,ds:data_135e
		mov	al,0Bh
		mul	bl			; ax = reg * al
		add	ax,9C43h
		mov	si,ax
		mov	es,cs:data_220e
		mov	di,8000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	bl,ds:data_136e
		cmp	bl,0FFh
		jne	loc_375			; Jump if not equal
		retn
loc_375:
		cmp	bl,ds:data_139e
		je	loc_376			; Jump if equal
		mov	ds:data_139e,bl
		mov	al,0Bh
		mul	bl			; ax = reg * al
		add	ax,9CBCh
		mov	si,ax
		push	cs
		pop	es
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
loc_376:
		mov	bl,ds:data_137e
		cmp	bl,0FFh
		jne	loc_377			; Jump if not equal
		retn
loc_377:
		cmp	bl,ds:data_140e
		je	loc_378			; Jump if equal
		mov	ds:data_140e,bl
		mov	al,0Bh
		mul	bl			; ax = reg * al
		add	ax,9D8Dh
		mov	si,ax
		mov	es,cs:data_220e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_220e
		mov	si,4000h
		mov	bp,0A000h
		mov	cx,100h
		call	word ptr cs:data_89
		pop	ds
loc_378:
		mov	bl,ds:data_138e
		cmp	bl,0FFh
		jne	loc_379			; Jump if not equal
		retn
loc_379:
		push	bx
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:data_143e,0FFh
		pop	bx
		mov	al,0Bh
		mul	bl			; ax = reg * al
		add	ax,9E53h
		mov	si,ax
		mov	es,cs:data_220e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		retn
sub_75		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_76		proc	near
		mov	cl,ds:data_225e
		mov	al,4
		mul	cl			; ax = reg * al
loc_380:
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		cmp	ds:data_216e,al
		jb	loc_380			; Jump if below
		mov	byte ptr ds:data_216e,0
		retn
sub_76		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_77		proc	near
		mov	si,ds:data_189e
loc_381:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_382			; Jump if not equal
		retn
loc_382:
		call	sub_87
		jc	loc_384			; Jump if carry Set
		mov	ah,bl
		mov	al,[si+2]
		call	sub_33
		mov	cx,3
		mov	dl,40h			; '@'

locloop_383:
		call	sub_89
		inc	di
		inc	dl
		loop	locloop_383		; Loop if cx > 0

loc_384:
		add	si,3
		jmp	short loc_381
sub_77		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_78		proc	near
		test	byte ptr ds:data_231e,0FFh
		jz	loc_385			; Jump if zero
		retn
loc_385:
		call	sub_37
		add	si,6Dh
		call	sub_34
		mov	dl,40h			; '@'
		call	sub_82
		jz	loc_386			; Jump if zero
		retn
loc_386:
		mov	di,ds:data_189e
		mov	dl,40h			; '@'
		call	sub_79
		jnc	loc_387			; Jump if carry=0
		pop	ax
		mov	byte ptr ds:[0E7h],80h
		jmp	loc_169
loc_387:
		call	sub_38
		jnc	loc_388			; Jump if carry=0
		retn
loc_388:
		and	al,60h			; '`'
		jz	loc_389			; Jump if zero
		retn
loc_389:
		test	byte ptr [bx+5],20h	; ' '
		jz	loc_390			; Jump if zero
		retn
loc_390:
		or	byte ptr [bx+5],40h	; '@'
		and	byte ptr [bx+5],0E0h
		retn
sub_78		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_79		proc	near
		push	dx
		call	sub_81
		pop	dx
		mov	bx,si
		add	si,23h
		call	sub_34
		test	byte ptr [si],80h
		clc				; Clear carry flag
		jz	loc_391			; Jump if zero
		retn
loc_391:
		mov	cx,3

locloop_392:
		inc	si
		test	byte ptr [si],0FFh
		jz	loc_393			; Jump if zero
		retn
loc_393:
		loop	locloop_392		; Loop if cx > 0

		mov	si,bx
		add	si,24h
		call	sub_34
		push	di
		mov	di,si
		mov	cx,3

locloop_394:
		push	dx
		push	bx
		call	sub_89
		pop	bx
		xchg	di,bx
		push	bx
		xor	dl,dl			; Zero register
		call	sub_89
		pop	bx
		xchg	di,bx
		inc	di
		inc	bx
		pop	dx
		inc	dl
		loop	locloop_394		; Loop if cx > 0

		pop	di
		inc	byte ptr [di+2]
		and	byte ptr [di+2],3Fh	; '?'
		stc				; Set carry flag
		retn
sub_79		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_80		proc	near
		test	byte ptr ds:data_231e,0FFh
		jz	loc_395			; Jump if zero
		retn
loc_395:
		call	sub_37
		sub	si,23h
		call	sub_35
		mov	al,[si]
		call	sub_39
		jz	loc_396			; Jump if zero
		retn
loc_396:
		add	si,90h
		call	sub_34
		mov	dl,40h			; '@'
		call	sub_82
		jz	loc_397			; Jump if zero
		retn
loc_397:
		mov	di,ds:data_189e
		mov	dl,40h			; '@'
		push	dx
		call	sub_81
		pop	dx
		mov	ax,si
		sub	si,24h
		call	sub_35
		mov	bx,si
		sub	si,24h
		call	sub_35
		mov	cx,3

locloop_398:
		test	byte ptr [si],80h
		jz	loc_399			; Jump if zero
		retn
loc_399:
		test	byte ptr [bx],0FFh
		jz	loc_400			; Jump if zero
		retn
loc_400:
		inc	si
		inc	bx
		loop	locloop_398		; Loop if cx > 0

		mov	bx,ax
		mov	si,bx
		sub	si,24h
		call	sub_35
		push	di
		mov	di,si
		mov	cx,3

locloop_401:
		push	dx
		push	bx
		call	sub_89
		pop	bx
		xchg	di,bx
		push	bx
		xor	dl,dl			; Zero register
		call	sub_89
		pop	bx
		xchg	di,bx
		inc	di
		inc	bx
		pop	dx
		inc	dl
		loop	locloop_401		; Loop if cx > 0

		pop	di
		dec	byte ptr [di+2]
		and	byte ptr [di+2],3Fh	; '?'
		pop	ax
		pop	ax
		mov	byte ptr ds:[0E7h],80h
		mov	byte ptr ds:data_234e,0
		jmp	loc_77
sub_80		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_81		proc	near
		mov	al,byte ptr ds:[83h]
		add	al,4
		add	al,dh
		xor	ah,ah			; Zero register
		add	ax,word ptr ds:[80h]
		cmp	ax,ds:data_188e
		jb	loc_402			; Jump if below
		sub	ax,ds:data_188e
loc_402:
		mov	cl,byte ptr ds:[82h]
		add	cl,byte ptr ds:[84h]
		add	cl,3
		and	cl,3Fh			; '?'
loc_403:
		cmp	ax,[di]
		jne	loc_404			; Jump if not equal
		cmp	cl,[di+2]
		je	loc_405			; Jump if equal
loc_404:
		add	di,3
		jmp	short loc_403
loc_405:
		call	sub_87
		mov	al,[di+2]
		mov	ah,bl
		push	di
		call	sub_33
		mov	si,di
		pop	di
		retn
sub_81		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_82		proc	near
		mov	dh,1
		cmp	dl,[si]
		jne	loc_406			; Jump if not equal
		retn
loc_406:
		dec	dh
		inc	dl
		cmp	dl,[si]
		jne	loc_407			; Jump if not equal
		retn
loc_407:
		dec	dh
		inc	dl
		cmp	dl,[si]
		retn
sub_82		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_83		proc	near
		mov	si,ds:data_190e
loc_408:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_409			; Jump if not equal
		retn
loc_409:
		call	sub_87
		jc	loc_411			; Jump if carry Set
		mov	ah,bl
		mov	al,[si+2]
		call	sub_33
		mov	cx,3
		mov	dl,43h			; 'C'

locloop_410:
		call	sub_89
		inc	di
		inc	dl
		loop	locloop_410		; Loop if cx > 0

loc_411:
		add	si,3
		jmp	short loc_408
sub_83		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_84		proc	near
		call	sub_37
		add	si,6Dh
		call	sub_34
		mov	dl,43h			; 'C'
		call	sub_82
		jz	loc_412			; Jump if zero
		retn
loc_412:
		mov	di,ds:data_190e
		mov	dl,43h			; 'C'
		call	sub_79
		jc	loc_413			; Jump if carry Set
		retn
loc_413:
		jmp	loc_169
sub_84		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_85		proc	near
		inc	byte ptr ds:data_146e
		mov	si,ds:data_191e
loc_414:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_415			; Jump if not equal
		retn
loc_415:
		and	ax,3FFFh
		call	sub_88
		jc	loc_420			; Jump if carry Set
		mov	cl,bl
		dec	bx
		dec	bx
		or	bh,bh			; Zero ?
		jns	loc_416			; Jump if not sign
		inc	cl
		mov	al,[si+2]
		xor	ah,ah			; Zero register
		call	sub_33
		jmp	short loc_418
loc_416:
		mov	ax,bx
		sub	ax,22h
		jc	loc_417			; Jump if carry Set
		push	ax
		mov	al,[si+2]
		mov	ah,22h			; '"'
		call	sub_33
		pop	ax
		add	di,ax
		mov	cl,al
		neg	cl
		add	cl,2
		jmp	short loc_418
loc_417:
		mov	ah,bl
		mov	al,[si+2]
		call	sub_33
		mov	cl,3
loc_418:
		xor	ch,ch			; Zero register
		xor	dl,dl			; Zero register

locloop_419:
		call	sub_89
		inc	di
		loop	locloop_419		; Loop if cx > 0

loc_420:
		mov	ax,[si]
		mov	bl,ah
		and	ax,3FFFh
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		and	bl,3
		jz	loc_421			; Jump if zero
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:data_106e[bx]	;*
loc_421:
		call	sub_87
		jc	loc_423			; Jump if carry Set
		mov	ah,bl
		mov	al,[si+2]
		call	sub_33
		mov	cx,3
		mov	dl,46h			; 'F'

locloop_422:
		call	sub_89
		inc	di
		inc	dl
		loop	locloop_422		; Loop if cx > 0

loc_423:
		add	si,7
		jmp	loc_414
sub_85		endp

			                        ;* No entry point to code
		dec	dx
;*		adc	byte ptr [bp+si-7Eh],52h	; 'R'
		db	 82h, 52h, 82h, 52h	;  Fixup - byte match
;*		xor	dh,6
		db	 82h,0F6h, 06h		;  Fixup - byte match
		pop	es
		lahf				; Load ah from flags
		add	[di+1],si
		retn
			                        ;* No entry point to code
		mov	cl,[si+2]
		and	byte ptr [si+2],0BFh
		test	cl,40h			; '@'
		jz	loc_424			; Jump if zero
		retn
loc_424:
		test	byte ptr [si+2],80h
		jnz	loc_427			; Jump if not zero
		inc	ax
		mov	bx,ax
		sub	ax,ds:data_188e
		jz	loc_425			; Jump if zero
		xchg	bx,ax
loc_425:
		push	si
		push	ax
		call	sub_86
		jc	loc_426			; Jump if carry Set
		call	sub_16
loc_426:
		pop	ax
		pop	si
		mov	bx,[si+5]
		jmp	short loc_430
loc_427:
		dec	ax
		cmp	ax,0FFFFh
		jne	loc_428			; Jump if not equal
		mov	ax,ds:data_188e
		dec	ax
loc_428:
		push	si
		push	ax
		call	sub_86
		jc	loc_429			; Jump if carry Set
		call	sub_13
loc_429:
		pop	ax
		pop	si
		mov	bx,[si+3]
loc_430:
		mov	dl,[si+1]
		and	dl,0C0h
		or	dl,ah
		mov	[si],al
		mov	[si+1],dl
		sub	bx,ax
		jz	loc_431			; Jump if zero
		retn
loc_431:
		xor	byte ptr [si+2],80h
		or	byte ptr [si+2],40h	; '@'
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_86		proc	near
		mov	dl,ds:data_234e
		or	dl,ds:data_231e
		stc				; Set carry flag
		jz	loc_432			; Jump if zero
		retn
loc_432:
		mov	al,byte ptr ds:[84h]
		add	al,byte ptr ds:[82h]
		add	al,3
		and	al,3Fh			; '?'
		mov	ah,[si+2]
		and	ah,3Fh			; '?'
		cmp	al,ah
		stc				; Set carry flag
		jz	loc_433			; Jump if zero
		retn
loc_433:
		mov	ax,[si]
		and	ax,3FFFh
		call	sub_87
		jnc	loc_434			; Jump if carry=0
		retn
loc_434:
		mov	dl,byte ptr ds:[83h]
		add	dl,4
		mov	cx,3

locloop_435:
		cmp	dl,al
		clc				; Clear carry flag
		jnz	loc_436			; Jump if not zero
		retn
loc_436:
		inc	dl
		loop	locloop_435		; Loop if cx > 0

		stc				; Set carry flag
		retn
sub_86		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_87		proc	near
		mov	bx,ax
		sub	ax,word ptr ds:[80h]
		jc	loc_437			; Jump if carry Set
		xchg	bx,ax
		mov	ax,21h
		sub	ax,bx
		retn
loc_437:
		mov	ax,21h
		sub	ax,bx
		jnc	loc_438			; Jump if carry=0
		retn
loc_438:
		mov	ax,ds:data_188e
		sub	ax,word ptr ds:[80h]
		add	ax,bx
		xchg	bx,ax
		mov	ax,21h
		sub	ax,bx
		retn
sub_87		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_88		proc	near
		add	ax,2
		mov	bx,ax
		sub	ax,ds:data_188e
		jnc	loc_439			; Jump if carry=0
		xchg	bx,ax
loc_439:
		mov	bx,ax
		sub	ax,word ptr ds:[80h]
		jc	loc_440			; Jump if carry Set
		xchg	bx,ax
		mov	ax,25h
		sub	ax,bx
		retn
loc_440:
		mov	ax,25h
		sub	ax,bx
		jnc	loc_441			; Jump if carry=0
		retn
loc_441:
		mov	ax,ds:data_188e
		sub	ax,word ptr ds:[80h]
		add	ax,bx
		xchg	bx,ax
		mov	ax,25h
		sub	ax,bx
		retn
sub_88		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_89		proc	near
		test	byte ptr [di],80h
		jnz	loc_442			; Jump if not zero
		mov	[di],dl
		retn
loc_442:
		mov	bl,[di]
		and	bl,7Fh
		xor	bh,bh			; Zero register
		mov	ds:data_212e[bx],dl
		retn
sub_89		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_90		proc	near
		mov	si,data_211e
loc_443:
		cmp	byte ptr [si],0FFh
		jne	loc_444			; Jump if not equal
		retn
loc_444:
		push	si
		call	sub_92
		pop	si
		mov	al,[si]
		mov	[si+0Bh],al
		sub	al,4
		cmp	al,1Ch
		jae	loc_446			; Jump if above or =
		mov	al,[si+1]
		sub	al,byte ptr ds:[82h]
		and	al,3Fh			; '?'
		cmp	al,12h
		jae	loc_446			; Jump if above or =
		mov	[si+0Ch],al
		mov	ah,[si+0Bh]
		push	ax
		call	sub_101
		pop	ax
		cmp	byte ptr [di],0FFh
		je	loc_445			; Jump if equal
		cmp	byte ptr [di],0FCh
		je	loc_445			; Jump if equal
		call	word ptr cs:data_76
		or	di,8000h
		mov	[si+7],di
		mov	al,[si+2]
		mov	bl,al
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		and	bx,3
		mov	bl,ds:data_107e[bx]
		and	bl,[si+3]
		add	al,bl
		and	al,3Fh			; '?'
		and	di,7FFFh
		call	word ptr cs:data_75
loc_445:
		add	si,0Dh
		jmp	short loc_443
loc_446:
		mov	byte ptr [si],0
		jmp	short loc_445
sub_90		endp

			                        ;* No entry point to code
		add	[bx+di],al
		add	ax,[bx]

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_91		proc	near
		mov	si,data_211e
loc_447:
		cmp	byte ptr [si],0FFh
		je	loc_448			; Jump if equal
		push	si
		call	sub_92
		pop	si
		add	si,0Dh
		jmp	short loc_447
loc_448:
		mov	byte ptr ds:data_211e,0FFh
		retn
sub_91		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_92		proc	near
		test	word ptr [si+7],8000h
		jnz	loc_449			; Jump if not zero
		retn
loc_449:
		and	word ptr [si+7],7FFFh
		mov	dx,[si+7]
		mov	al,[si+0Ch]
		mov	ah,[si+0Bh]
sub_92		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_93		proc	near
loc_450:
		push	ax
		call	sub_101
		pop	ax
		cmp	byte ptr [di],0FCh
		jb	loc_451			; Jump if below
		retn
loc_451:
		add	al,byte ptr ds:[82h]
		call	sub_33
		mov	al,[di]
		jmp	word ptr cs:data_77
sub_93		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_94		proc	near
		mov	si,data_211e
		mov	di,0EB80h
		push	cs
		pop	es
		mov	byte ptr ds:data_166e,0
loc_452:
		mov	al,[si]
		or	al,al			; Zero ?
		jnz	loc_453			; Jump if not zero
		test	word ptr [si+7],8000h
		jz	loc_456			; Jump if zero
loc_453:
		inc	al
		jnz	loc_454			; Jump if not zero
		mov	byte ptr [di],0FFh
		retn
loc_454:
		inc	byte ptr [si+3]
		push	es
		push	di
		call	sub_95
		pop	di
		pop	es
		push	si
		mov	cx,0Dh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		test	byte ptr [si+5],40h	; '@'
		jnz	loc_455			; Jump if not zero
		mov	al,[si+3]
		cmp	al,[si+4]
		jb	loc_455			; Jump if below
		mov	byte ptr [si],0
loc_455:
		inc	byte ptr ds:data_166e
loc_456:
		add	si,0Dh
		jmp	short loc_452
sub_94		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_95		proc	near
;*		call	sub_97			;*
		db	0E8h, 38h, 01h		;  Fixup - byte match
		test	byte ptr [si+5],8
		jnz	loc_458			; Jump if not zero
		mov	ah,[si]
		or	ah,ah			; Zero ?
		jnz	loc_457			; Jump if not zero
		retn
loc_457:
		mov	al,[si+1]
		call	sub_33
		mov	al,[di]
		call	sub_40
		jz	loc_458			; Jump if zero
		mov	byte ptr [si],0
		retn
loc_458:
		mov	al,byte ptr ds:[82h]
		add	al,byte ptr ds:[84h]
		test	byte ptr ds:data_230e,0FFh
		jnz	loc_459			; Jump if not zero
		and	al,3Fh			; '?'
		cmp	al,[si+1]
		je	loc_461			; Jump if equal
loc_459:
		mov	cx,2

locloop_460:
		inc	al
		and	al,3Fh			; '?'
		cmp	al,[si+1]
		je	loc_461			; Jump if equal
		loop	locloop_460		; Loop if cx > 0

		retn
loc_461:
		mov	al,byte ptr ds:[83h]
		add	al,4
		test	byte ptr ds:[0C2h],1
		jz	loc_462			; Jump if zero
		inc	al
loc_462:
		cmp	al,[si]
		je	loc_463			; Jump if equal
		inc	al
		cmp	al,[si]
		je	loc_463			; Jump if equal
		retn
loc_463:
		mov	byte ptr [si],0
		test	byte ptr ds:[93h],0FFh
		jz	loc_465			; Jump if zero
		test	byte ptr ds:data_240e,0FFh
		jnz	loc_465			; Jump if not zero
		test	byte ptr ds:data_231e,0FFh
		jnz	loc_465			; Jump if not zero
		mov	al,[si+5]
		and	al,7
		cmp	al,2
		je	loc_465			; Jump if equal
		cmp	al,6
		je	loc_465			; Jump if equal
		or	al,al			; Zero ?
		jz	loc_464			; Jump if zero
		cmp	al,1
		je	loc_464			; Jump if equal
		cmp	al,7
		je	loc_464			; Jump if equal
		test	byte ptr ds:[0C2h],1
		jnz	loc_465			; Jump if not zero
		jmp	short loc_467
loc_464:
		test	byte ptr ds:[0C2h],1
		jnz	loc_467			; Jump if not zero
loc_465:
		mov	al,[si+6]
		xor	ah,ah			; Zero register
		call	sub_60
		mov	byte ptr ds:data_247e,9
		mov	al,0FFh
		mov	ds:data_156e,al
		mov	ds:data_228e,al
		mov	bx,0FFFFh
		mov	cx,0FFFFh
		mov	al,[si+5]
		and	al,7
		cmp	al,2
		je	loc_466			; Jump if equal
		cmp	al,6
		je	loc_466			; Jump if equal
		xor	bx,bx			; Zero register
		or	al,al			; Zero ?
		jz	loc_466			; Jump if zero
		cmp	al,1
		je	loc_466			; Jump if equal
		cmp	al,7
		je	loc_466			; Jump if equal
		xchg	cx,bx
loc_466:
		mov	ds:data_153e,cx
		mov	ds:data_154e,bx
		retn
loc_467:
		cmp	byte ptr ds:[93h],4
		jae	loc_469			; Jump if above or =
		mov	al,byte ptr ds:[84h]
		add	al,byte ptr ds:[82h]
		inc	al
		test	byte ptr ds:data_230e,0FFh
		jz	loc_468			; Jump if zero
		inc	al
loc_468:
		call	sub_96
		jc	loc_465			; Jump if carry Set
loc_469:
		mov	byte ptr ds:data_247e,0Ah
		retn
sub_95		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_96		proc	near
		mov	bl,[si+5]
		and	bx,7
		add	bx,bx
		and	al,3Fh			; '?'
		jmp	word ptr ds:data_108e[bx]	;*
sub_96		endp

			                        ;* No entry point to code
		xchg	cx,ax
		test	bx,ds:data_124e[bx+di]
		test	bx,ds:data_117e[bx+di]
		test	bx,ds:data_181e[bx]
		test	bx,data_91[bx]
loc_471:
		inc	sp
		add	[di+1],si
		retn
			                        ;* No entry point to code
		stc				; Set carry flag
		retn
			                        ;* No entry point to code
		dec	al
		and	al,3Fh			; '?'
;*		jmp	short loc_470		;*
		db	0EBh,0F2h		;  Fixup - byte match
		db	0FEh,0C0h
loc_472:
		and	al,3Fh			; '?'
		jmp	short loc_471
		jmp	short loc_471
		jmp	short loc_471
		jmp	short loc_472
			                        ;* No entry point to code
		inc	sp
		add	ax,7440h
		push	es
		call	sub_98
		jnc	loc_473			; Jump if carry=0
		retn
loc_473:
		mov	bl,[si+5]
		and	bx,7
		add	bx,bx
		call	word ptr ds:data_109e[bx]	;*
		and	byte ptr [si+1],3Fh	; '?'
		retn
			                        ;* No entry point to code
;*		aad	85h			; undocumented inst
		db	0D5h, 85h		;  Fixup - byte match
		rol	byte ptr ds:data_110e[di],cl	; Rotate
		db	0DEh, 85h,0E1h, 85h,0E4h, 85h
		db	0EAh, 85h,0D8h, 85h,0FEh, 4Ch
		db	 01h,0FEh, 04h,0C3h,0FEh, 44h
		db	 01h,0FEh, 04h,0C3h,0FEh, 4Ch
		db	 01h,0FEh, 0Ch,0C3h,0FEh, 44h
		db	 01h,0FEh, 0Ch,0C3h,0FEh, 44h
		db	 01h,0C3h,0FEh, 4Ch, 01h,0C3h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_98		proc	near
		mov	bl,[si+3]
		xor	bh,bh			; Zero register
		mov	di,[si+9]
		mov	al,[bx+di]
		cmp	al,0FFh
		jne	loc_474			; Jump if not equal
		mov	byte ptr ds:[80h][si],0
		stc				; Set carry flag
		retn
loc_474:
		and	al,7
		and	byte ptr [si+5],0F8h
		or	[si+5],al
		retn
sub_98		endp

			                        ;* No entry point to code
		cmp	byte ptr ds:data_166e,1Fh
		jb	loc_475			; Jump if below
		retn
loc_475:
		push	si
		push	cs
		pop	es
		mov	si,bx
		mov	di,data_211e
loc_476:
		cmp	byte ptr [di],0FFh
		je	loc_477			; Jump if equal
		add	di,0Dh
		jmp	short loc_476
loc_477:
		mov	cx,0Dh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		inc	byte ptr ds:data_166e
		pop	si
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_99		proc	near
		mov	si,data_211e
loc_478:
		mov	al,[si]
		cmp	al,0FFh
		jne	loc_479			; Jump if not equal
		retn
loc_479:
		or	al,al			; Zero ?
		jz	loc_480			; Jump if zero
		dec	byte ptr [si]
loc_480:
		add	si,0Dh
		jmp	short loc_478
sub_99		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_100		proc	near
		mov	si,data_211e
loc_481:
		mov	al,[si]
		cmp	al,0FFh
		jne	loc_482			; Jump if not equal
		retn
loc_482:
		or	al,al			; Zero ?
		jz	loc_483			; Jump if zero
		inc	byte ptr [si]
loc_483:
		add	si,0Dh
		jmp	short loc_481
sub_100		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_101		proc	near
		and	al,3Fh			; '?'
		mov	bl,ah
		mov	bh,1Ch
		mul	bh			; ax = reg * al
		sub	bl,4
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		add	di,0E900h
		retn
sub_101		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_102		proc	near
		mov	si,data_210e
		mov	cx,4

locloop_484:
		push	cx
		cmp	byte ptr [si],0FFh
		je	loc_486			; Jump if equal
		call	sub_103
		test	byte ptr [si+2],0FFh
		jnz	loc_485			; Jump if not zero
		mov	byte ptr [si],0FFh
		jmp	short loc_486
loc_485:
		mov	bl,[si]
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,data_111e
		mov	ah,byte ptr ds:[83h]
		add	ah,[bx]
		mov	[si+5],ah
		mov	al,byte ptr ds:[84h]
		add	al,[bx+1]
		and	al,3Fh			; '?'
		mov	[si+6],al
		push	ax
		call	sub_101
		pop	ax
		cmp	byte ptr [di],0FFh
		je	loc_486			; Jump if equal
		cmp	byte ptr [di],0FCh
		je	loc_486			; Jump if equal
		call	word ptr cs:data_76
		or	di,8000h
		mov	[si+3],di
		mov	al,66h			; 'f'
		and	di,7FFFh
		push	si
		call	word ptr cs:data_75
		pop	si
loc_486:
		add	si,7
		pop	cx
		loop	locloop_484		; Loop if cx > 0

		retn
sub_102		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_103		proc	near
		test	word ptr [si+3],8000h
		jnz	loc_487			; Jump if not zero
		retn
loc_487:
		and	word ptr [si+3],7FFFh
		mov	dx,[si+3]
		mov	ah,[si+5]
		mov	al,[si+6]
		jmp	loc_450
sub_103		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_104		proc	near
		mov	si,data_210e
		mov	cx,4

locloop_488:
		push	cx
		cmp	byte ptr [si],0FFh
		je	loc_489			; Jump if equal
		mov	bl,[si]
		add	bl,[si+1]
		and	bl,0Fh
		mov	[si],bl
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,data_111e
		mov	ah,byte ptr ds:[83h]
		add	ah,[bx]
		mov	al,byte ptr ds:[84h]
		add	al,[bx+1]
		add	al,byte ptr ds:[82h]
		call	sub_33
		xchg	si,di
		sub	si,25h
		call	sub_35
		xchg	si,di
		call	sub_105
loc_489:
		add	si,7
		pop	cx
		loop	locloop_488		; Loop if cx > 0

		retn
sub_104		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_105		proc	near
		test	byte ptr ds:data_226e,0FFh
		jz	loc_490			; Jump if zero
		test	byte ptr ds:data_223e,0FFh
		jz	loc_490			; Jump if zero
		retn
loc_490:
		call	sub_106
		inc	di
		call	sub_106
		xchg	si,di
		add	si,23h
		call	sub_34
		xchg	si,di
		call	sub_106
		inc	di
sub_105		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_106		proc	near
		test	byte ptr [si+2],0FFh
		jnz	loc_491			; Jump if not zero
		retn
loc_491:
		xchg	si,di
		call	sub_38
		xchg	si,di
		jnc	loc_492			; Jump if carry=0
		retn
loc_492:
		test	byte ptr [bx+4],20h	; ' '
		jz	loc_493			; Jump if zero
		retn
loc_493:
		test	byte ptr [bx+5],20h	; ' '
		jz	loc_494			; Jump if zero
		retn
loc_494:
		and	byte ptr [bx+5],0E0h
		or	byte ptr [bx+5],49h	; 'I'
		dec	byte ptr [si+2]
		retn
sub_106		endp

			                        ;* No entry point to code
		add	al,[bx+di]
		add	al,[bx+si]
		add	di,di
		add	al,0FEh
		add	ax,6FEh
		inc	byte ptr [bx]
		dec	word ptr [bx+si]
		add	[bx+si],cl
		add	[bx+si],cx
		add	al,[bx]
		add	ax,word ptr ds:[504h]
		add	al,4

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_107		proc	near
		add	al,3
		add	ax,[bp+si]
		add	dh,dh
		push	es
		popf				; Pop flags
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		jnz	loc_495			; Jump if not zero
		retn
loc_495:
		test	byte ptr ds:data_233e,0FFh
		jnz	loc_499			; Jump if not zero
		test	byte ptr ds:data_218e,0FFh
		jnz	loc_496			; Jump if not zero
		retn
loc_496:
		mov	byte ptr ds:data_217e,0
		mov	byte ptr ds:data_218e,0
		test	byte ptr ds:data_240e,0FFh
		jz	loc_497			; Jump if zero
		retn
loc_497:
		test	byte ptr ds:data_235e,0FFh
		jz	loc_498			; Jump if zero
		retn
loc_498:
		mov	byte ptr ds:data_178e,0
		mov	byte ptr ds:data_233e,0FFh
		mov	byte ptr ds:data_247e,17h
		retn
loc_499:
		add	byte ptr ds:data_178e,2
		cmp	byte ptr ds:data_178e,4
		je	loc_501			; Jump if equal
		cmp	byte ptr ds:data_178e,6
		jae	loc_500			; Jump if above or =
		retn
loc_500:
		mov	byte ptr ds:data_233e,0
		retn
loc_501:
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		test	byte ptr ds:[0ABh][bx],0FFh
		jnz	loc_502			; Jump if not zero
		retn
loc_502:
		dec	byte ptr ds:[0ABh][bx]
		call	word ptr cs:[2018h]
		mov	byte ptr ds:data_247e,18h
		mov	si,0EB15h
		mov	byte ptr ds:data_235e,0FFh
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_112e[bx]	;*
sub_107		endp

			                        ;* No entry point to code
		dec	bp
		mov	[di-78h],cl
		dec	bp
		mov	[di-78h],cl
		test	al,88h
		clc				; Clear carry flag
		mov	[bx+si],bl
		mov	word ptr ds:[0C2h][bx+si],sp
		not	al
		and	al,1
		mov	[si+3],al
		mov	al,ds:data_230e
		and	al,1
		add	al,byte ptr ds:[84h]
		add	al,byte ptr ds:[82h]
		and	al,3Fh			; '?'
		mov	[si+2],al
		mov	al,byte ptr ds:[83h]
		add	al,4
		mov	ah,[si+3]
		not	ah
		and	ah,1
		add	al,ah
		xor	ah,ah			; Zero register
		add	ax,word ptr ds:[80h]
		cmp	ax,ds:data_188e
		jb	loc_503			; Jump if below
		sub	ax,ds:data_188e
loc_503:
		mov	[si],ax
		mov	byte ptr [si+9],0
		mov	byte ptr [si+0Bh],0
		mov	byte ptr [si+0Dh],0
		mov	byte ptr [si+0Fh],0
		mov	byte ptr [si+4],0
		mov	byte ptr [si+5],0
		mov	word ptr [si+10h],0FFFFh
		retn
		db	0B9h, 04h, 00h

locloop_504:
		push	cx
		mov	al,6
		mul	cl			; ax = reg * al
		add	ax,2
		add	ax,word ptr ds:[80h]
		cmp	ax,ds:data_188e
		jb	loc_505			; Jump if below
		sub	ax,ds:data_188e
loc_505:
		mov	[si],ax
		call	word ptr cs:[11Ah]
		and	al,3
		mov	ah,byte ptr ds:[82h]
		sub	ah,3
		sub	ah,al
		and	ah,3Fh			; '?'
		mov	[si+2],ah
		mov	byte ptr [si+9],0
		mov	byte ptr [si+0Bh],0
		mov	byte ptr [si+0Dh],0
		mov	byte ptr [si+0Fh],0
		mov	byte ptr [si+4],0
		mov	byte ptr [si+5],0
		add	si,10h
		pop	cx
		loop	locloop_504		; Loop if cx > 0

		retn
		db	 56h,0B9h, 03h, 00h

locloop_506:
		push	cx
;*		call	sub_108			;*
		db	0E8h, 4Dh,0FFh		;  Fixup - byte match
		add	si,10h
		pop	cx
		loop	locloop_506		; Loop if cx > 0

		pop	si
		sub	byte ptr [si+2],2
		and	byte ptr [si+2],3Fh	; '?'
		add	byte ptr [si+12h],2
		and	byte ptr [si+12h],3Fh	; '?'
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_126e,0FFh
		mov	byte ptr ds:data_127e,0FFh
		test	byte ptr ds:data_226e,0FFh
		jz	loc_507			; Jump if zero
		test	byte ptr ds:data_221e,0FFh
		jnz	loc_511			; Jump if not zero
loc_507:
		mov	si,ds:data_224e
		sub	si,24h
		call	sub_35
		mov	cx,13h

locloop_508:
		push	cx
		mov	cx,24h

locloop_509:
		push	cx
		test	byte ptr [si],80h
		jz	loc_510			; Jump if zero
		call	sub_115
loc_510:
		inc	si
		pop	cx
		loop	locloop_509		; Loop if cx > 0

		call	sub_34
		pop	cx
		loop	locloop_508		; Loop if cx > 0

loc_511:
		mov	byte ptr ds:data_235e,0
		mov	byte ptr ds:data_247e,19h
		call	word ptr cs:data_82
		mov	byte ptr ds:data_218e,0
		call	sub_48
		jmp	loc_231

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_109		proc	near
		mov	si,0EB15h
		mov	cx,4
loc_512:
		cmp	word ptr [si],0FFFFh
		jne	loc_513			; Jump if not equal
		retn
loc_513:
		push	cx
		call	sub_110
		cmp	byte ptr [si+1],0FFh
		jne	loc_514			; Jump if not equal
		mov	word ptr [si],0FFFFh
		jmp	loc_519
loc_514:
		mov	bl,[si+5]
		add	bl,bl
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	al,byte ptr ds:[9Dh]
		dec	al
		add	al,al
		xor	ah,ah			; Zero register
		mov	di,8C81h
		test	byte ptr [si+3],0FFh
		jnz	loc_515			; Jump if not zero
		mov	di,data_114e
loc_515:
		add	di,ax
		mov	di,[di]
		add	di,bx
		mov	ax,[si]
		call	sub_141
		jc	loc_519			; Jump if carry Set
		mov	[si+6],bl
		mov	al,[si+2]
		sub	al,byte ptr ds:[82h]
		and	al,3Fh			; '?'
		mov	[si+7],al
		mov	bh,al
		xchg	bh,bl
		push	si
		add	si,8
		mov	bp,data_113e
		mov	cx,4

locloop_516:
		push	cx
		push	bx
		push	bp
		add	bh,ds:[bp]
		mov	al,bh
		sub	al,4
		cmp	al,1Ch
		jae	loc_518			; Jump if above or =
		inc	bp
		add	bl,ds:[bp]
		and	bl,3Fh			; '?'
		cmp	bl,12h
		jae	loc_518			; Jump if above or =
		mov	al,[di]
		push	di
		push	ax
		mov	ax,bx
		push	ax
		call	sub_101
		pop	ax
		cmp	byte ptr [di],0FFh
		je	loc_517			; Jump if equal
		cmp	byte ptr [di],0FCh
		je	loc_517			; Jump if equal
		call	word ptr cs:data_76
		or	di,8000h
		mov	[si],di
		and	di,7FFFh
		pop	ax
		push	si
		call	word ptr cs:data_75
		pop	si
		pop	di
		jmp	short loc_518
loc_517:
		pop	ax
		pop	di
loc_518:
		pop	bp
		inc	si
		inc	si
		inc	di
		inc	bp
		inc	bp
		pop	bx
		pop	cx
		loop	locloop_516		; Loop if cx > 0

		pop	si
loc_519:
		add	si,10h
		pop	cx
		loop	locloop_520		; Loop if cx > 0

		jmp	short loc_ret_521

locloop_520:
		jmp	loc_512

loc_ret_521:
		retn
sub_109		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_110		proc	near
		test	word ptr [si+8],8000h
		jz	loc_522			; Jump if zero
		and	word ptr [si+8],7FFFh
		mov	dx,[si+8]
		mov	ah,[si+6]
		mov	al,[si+7]
		push	si
		call	sub_93
		pop	si
loc_522:
		test	word ptr [si+0Ah],8000h
		jz	loc_523			; Jump if zero
		and	word ptr [si+0Ah],7FFFh
		mov	dx,[si+0Ah]
		mov	ah,[si+6]
		inc	ah
		mov	al,[si+7]
		push	si
		call	sub_93
		pop	si
loc_523:
		test	word ptr [si+0Ch],8000h
		jz	loc_524			; Jump if zero
		and	word ptr [si+0Ch],7FFFh
		mov	dx,[si+0Ch]
		mov	ah,[si+6]
		mov	al,[si+7]
		inc	al
		and	al,3Fh			; '?'
		push	si
		call	sub_93
		pop	si
loc_524:
		test	word ptr [si+0Eh],8000h
		jnz	loc_525			; Jump if not zero
		retn
loc_525:
		and	word ptr [si+0Eh],7FFFh
		mov	dx,[si+0Eh]
		mov	ah,[si+6]
		inc	ah
		mov	al,[si+7]
		inc	al
		and	al,3Fh			; '?'
		push	si
		call	sub_93
		pop	si
		retn
sub_110		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_111		proc	near
		test	byte ptr ds:data_235e,0FFh
		jnz	$+3			; Jump if not zero
		retn
sub_111		endp

			                        ;* No entry point to code
		mov	si,0EB15h
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:[8AC6h][bx]	;*
			                        ;* No entry point to code
;*		aam	8Ah			; undocumented inst
		db	0D4h, 8Ah		;  Fixup - byte match
		db	0F7h, 8Ah, 09h, 8Bh,0F7h, 8Ah
		db	 64h, 8Bh, 83h, 8Bh, 9Ch, 8Bh
		db	0F6h, 44h, 03h, 80h, 74h, 03h
		db	0E9h,0D8h, 00h,0FEh, 44h, 04h
		db	 80h, 7Ch, 04h, 05h, 72h, 03h
		db	0E9h,0CCh, 00h,0E8h,0D6h, 00h
		db	0E8h, 08h, 01h, 73h, 01h,0C3h
loc_526:
		or	byte ptr [si+3],80h
		retn
			                        ;* No entry point to code
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ah
		jb	loc_527			; Jump if below
		jmp	loc_535
loc_527:
		call	sub_112
		jmp	loc_539
			                        ;* No entry point to code
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ch
		jb	loc_528			; Jump if below
		jmp	loc_535
loc_528:
		cmp	byte ptr [si+4],4
		jae	loc_529			; Jump if above or =
		call	sub_113
		jmp	short loc_530
loc_529:
		and	byte ptr [si+5],3
		inc	byte ptr [si+5]
		cmp	byte ptr [si+4],3
		je	loc_530			; Jump if equal
		mov	ax,[si]
		call	sub_141
		jc	loc_530			; Jump if carry Set
		cmp	bl,21h			; '!'
		jae	loc_530			; Jump if above or =
		mov	ah,bl
		mov	al,[si+2]
		call	sub_33
		xchg	si,di
		add	si,48h
		call	sub_34
		xchg	si,di
		mov	al,[di]
		call	sub_39
		jnz	loc_530			; Jump if not zero
		mov	al,[di+1]
		call	sub_39
		jnz	loc_530			; Jump if not zero
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
loc_530:
		jmp	loc_539
			                        ;* No entry point to code
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ch
		jae	loc_533			; Jump if above or =
		mov	cx,4

locloop_531:
		push	cx
		add	byte ptr [si+2],2
		and	byte ptr [si+2],3Fh	; '?'
		call	sub_114
		add	si,10h
		pop	cx
		loop	locloop_531		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ah
		jae	loc_534			; Jump if above or =
		mov	cx,3

locloop_532:
		push	cx
		call	sub_112
		call	sub_114
		add	si,10h
		pop	cx
		loop	locloop_532		; Loop if cx > 0

		retn
loc_533:
		mov	byte ptr [si+30h],0
		mov	byte ptr [si+31h],0FFh
loc_534:
		mov	byte ptr [si+20h],0
		mov	byte ptr [si+21h],0FFh
		mov	byte ptr [si+10h],0
		mov	byte ptr [si+11h],0FFh
loc_535:
		mov	byte ptr [si],0
		mov	byte ptr [si+1],0FFh
		mov	byte ptr ds:data_235e,0
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_112		proc	near
		mov	al,[si+5]
		inc	al
		cmp	al,3
		jb	loc_536			; Jump if below
		xor	al,al			; Zero register
loc_536:
		mov	[si+5],al

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_113:
		mov	ax,[si]
		mov	bl,[si+3]
		and	bx,1
		add	bx,bx
		add	bx,bx
		dec	bx
		dec	bx
		add	ax,bx
		or	ax,ax			; Zero ?
		jns	loc_537			; Jump if not sign
		add	ax,ds:data_188e
		jmp	short loc_538
loc_537:
		cmp	ax,ds:data_188e
		jb	loc_538			; Jump if below
		sub	ax,ds:data_188e
loc_538:
		mov	[si],ax
		retn
sub_112		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_114		proc	near
loc_539:
		test	byte ptr ds:data_226e,0FFh
		jz	loc_540			; Jump if zero
		test	byte ptr ds:data_221e,0FFh
		stc				; Set carry flag
		jz	loc_540			; Jump if zero
		retn
loc_540:
		mov	ax,[si]
		call	sub_141
		jnc	loc_541			; Jump if carry=0
		retn
loc_541:
		mov	ah,bl
		sub	bl,2
		cmp	bl,20h			; ' '
		cmc				; Complement carry
		jnc	loc_542			; Jump if carry=0
		retn
loc_542:
		mov	al,[si+2]
		call	sub_33
		push	si
		xchg	di,si
		sub	si,25h
		call	sub_35
		mov	byte ptr ds:data_177e,0
		mov	cx,3

locloop_543:
		push	cx
		mov	cx,3

locloop_544:
		push	cx
		call	sub_115
		pop	cx
		inc	si
		loop	locloop_544		; Loop if cx > 0

		add	si,21h
		call	sub_34
		pop	cx
		loop	locloop_543		; Loop if cx > 0

		pop	si
		mov	al,ds:data_177e
		add	al,al
		cmc				; Complement carry
		retn
sub_114		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_115		proc	near
		call	sub_38
		jnc	loc_545			; Jump if carry=0
		retn
loc_545:
		test	al,20h			; ' '
		jz	loc_546			; Jump if zero
		retn
loc_546:
		test	byte ptr [bx+5],20h	; ' '
		jz	loc_547			; Jump if zero
		retn
loc_547:
		mov	al,[bx+5]
		or	al,40h			; '@'
		and	al,0E0h
		mov	ah,byte ptr ds:[9Dh]
		inc	ah
		or	al,ah
		mov	[bx+5],al
		mov	byte ptr ds:data_177e,0FFh
		retn
sub_115		endp

		db	 00h, 00h, 01h, 00h, 00h, 01h
		db	 01h, 01h, 99h, 8Ch,0A5h, 8Ch
		db	0BDh, 8Ch,0E5h, 8Ch,0FDh, 8Ch
		db	 01h, 8Dh, 99h, 8Ch,0B1h, 8Ch
		db	0D1h, 8Ch,0F1h, 8Ch,0FDh, 8Ch
		db	 0Dh, 8Dh
		db	 67h, 68h
		db	'ijklmnopqrghijklmnopqrstuvwxyz{|'
		db	'}~ghijopqrstuvwxyz{|}~klmnopqrst'
		db	'uvwxyz{|}~ghijklmnopqrstuvwxyz{|'
		db	'}~stuvghijklmnopqrstuvwxyz{|}~'

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_116		proc	near
		mov	si,ds:data_195e
		mov	al,ds:data_226e
		or	al,byte ptr ds:[0E6h]
		jz	loc_548			; Jump if zero
		jmp	word ptr cs:data_182e
loc_548:
		mov	byte ptr ds:data_245e,0
loc_549:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_550			; Jump if not equal
		retn
loc_550:
		mov	byte ptr [si+3],0FFh
		cmp	ah,0FFh
		je	loc_551			; Jump if equal
		call	sub_141
		jc	loc_551			; Jump if carry Set
		mov	[si+3],bl
		call	sub_117
		cmp	byte ptr [si+1],0FFh
		je	loc_551			; Jump if equal
		mov	ax,[si+2]
		call	sub_33
		mov	bl,ds:data_245e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_212e[bx],al
		test	byte ptr [si+4],11h
		jnz	loc_551			; Jump if not zero
		test	byte ptr [si+7],10h
		jz	loc_551			; Jump if zero
		xchg	si,di
		add	si,48h
		call	sub_34
		xchg	si,di
		mov	bl,ds:data_245e
		inc	bl
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_212e[bx],al
loc_551:
		test	byte ptr [si+7],20h	; ' '
		jnz	loc_553			; Jump if not zero
		mov	al,[si+0Fh]
		inc	al
		jz	loc_552			; Jump if zero
		mov	[si+0Fh],al
loc_552:
		jnz	loc_553			; Jump if not zero
		call	sub_139
loc_553:
		inc	byte ptr ds:data_245e
		add	si,10h
		jmp	short loc_549
sub_116		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_117		proc	near
		mov	ax,[si+2]
		call	sub_33
		mov	al,[si+5]
		and	al,0DFh
		test	al,40h			; '@'
		jz	loc_555			; Jump if zero
		test	byte ptr [si+4],20h	; ' '
		jnz	loc_554			; Jump if not zero
		or	al,20h			; ' '
loc_554:
		and	al,0BFh
loc_555:
		mov	[si+5],al
		mov	al,ds:data_245e
		mov	bx,data_212e
		xlat				; al=[al+[bx]] table
		mov	[di],al
		test	byte ptr [si+4],11h
		jnz	loc_556			; Jump if not zero
		test	byte ptr [si+7],10h
		jz	loc_556			; Jump if zero
		xchg	si,di
		add	si,48h
		call	sub_34
		xchg	si,di
		mov	al,ds:data_245e
		inc	al
		xlat				; al=[al+[bx]] table
		mov	[di],al
loc_556:
		test	byte ptr [si+4],18h
		jnz	loc_557			; Jump if not zero
		jmp	word ptr cs:data_182e
loc_557:
		jmp	short $+2		; delay for I/O
		xor	bh,bh			; Zero register
		mov	bl,[si+4]
		and	bl,1Fh
		sub	bl,10h
		jnc	$+5			; Jump if carry=0
		jmp	loc_585
			                        ;* No entry point to code
		add	bx,bx
		jmp	word ptr ds:[8E14h][bx]	;*
			                        ;* No entry point to code
		xor	cl,byte ptr ss:[8E8Dh][bp]
		jmp	$-96Fh
		db	 8Eh,0ABh, 8Fh,0ABh, 8Fh,0E8h
		db	 8Fh,0F8h, 8Fh, 08h, 90h, 1Ch
		db	 90h, 9Dh, 90h,0ABh, 8Fh, 3Ch
		db	 90h, 7Fh, 90h, 90h, 90h,0F6h
		db	 44h, 0Ah, 01h, 75h, 1Ch,0F6h
		db	 44h, 05h, 20h, 75h, 01h,0C3h
		db	0C6h, 06h, 75h,0FFh, 12h, 80h
		db	 64h, 05h, 90h, 80h, 64h, 04h
		db	 7Fh, 80h, 4Ch, 04h, 60h, 80h
		db	 4Ch, 0Ah, 01h, 80h, 44h, 06h
		db	 80h, 72h, 01h,0C3h
loc_558:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],4
		jae	loc_559			; Jump if above or =
		retn
loc_559:
		mov	byte ptr [si+6],0
		mov	al,[si+9]
		or	al,al			; Zero ?
		jnz	loc_560			; Jump if not zero
		jmp	loc_591
loc_560:
		test	al,10h
		jz	loc_561			; Jump if zero
		or	al,60h			; '`'
		or	byte ptr [si+7],80h
		mov	byte ptr [si+0Fh],0
loc_561:
		mov	[si+4],al
		and	byte ptr [si+5],80h
		mov	byte ptr [si+9],0
		retn
			                        ;* No entry point to code
		test	byte ptr [si+0Ah],1
		jnz	loc_565			; Jump if not zero
		mov	ah,[si+2]
		sub	ah,3
		and	ah,3Fh			; '?'
		cmp	ah,ds:data_227e
		je	loc_562			; Jump if equal
		retn
loc_562:
		mov	al,byte ptr ds:[83h]
		add	al,3
		mov	ah,byte ptr ds:[0C2h]
		and	ah,1
		add	ah,ah
		add	al,ah
		mov	cx,2

locloop_563:
		cmp	al,[si+3]
		je	loc_564			; Jump if equal
		inc	al
		loop	locloop_563		; Loop if cx > 0

		retn
loc_564:
		mov	byte ptr ds:data_247e,12h
		or	byte ptr [si+0Ah],1
		retn
loc_565:
		and	byte ptr [si+4],7Fh
		call	sub_125
		add	byte ptr [si+6],80h
		jc	loc_566			; Jump if carry Set
		retn
loc_566:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],4
		jae	loc_567			; Jump if above or =
		retn
loc_567:
		mov	byte ptr [si+6],0
		jmp	loc_591
			                        ;* No entry point to code
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],3
		je	loc_568			; Jump if equal
		retn
loc_568:
		jmp	loc_591
			                        ;* No entry point to code
		call	sub_121
		jnc	loc_569			; Jump if carry=0
		retn
loc_569:
		mov	byte ptr ds:data_247e,14h
		test	byte ptr [si+6],0Fh
		jnz	loc_571			; Jump if not zero
		mov	al,[si+9]
		test	al,10h
		jz	loc_570			; Jump if zero
		or	al,60h			; '`'
		or	byte ptr [si+7],80h
		mov	byte ptr [si+0Fh],0
loc_570:
		mov	[si+4],al
		mov	byte ptr [si+9],0
		retn
loc_571:
		call	sub_119
		mov	bl,[si+6]
		and	bl,0Fh
		dec	bl
		add	bl,bl
		xor	bh,bh			; Zero register
		jmp	word ptr ds:data_115e[bx]	;*
			                        ;* No entry point to code
		inc	cx
		db	 8Fh, 4Dh, 8Fh, 59h, 8Fh, 5Fh
		db	 8Fh, 6Bh, 8Fh, 77h, 8Fh, 83h
		db	 8Fh,0BAh, 1Eh, 9Ah,0E8h, 99h
		db	0E4h,0B8h, 32h, 00h,0E9h, 1Eh
		db	 02h,0BAh, 32h, 9Ah,0E8h, 8Dh
		db	0E4h,0B8h, 64h, 00h,0E9h, 12h
		db	 02h,0BAh,0DDh, 9Ah,0E9h, 81h
		db	0E4h,0BAh, 47h, 9Ah,0E8h, 7Bh
		db	0E4h,0B8h,0F4h, 01h,0E9h, 00h
		db	 02h,0BAh, 5Ch, 9Ah,0E8h, 6Fh
		db	0E4h,0B8h,0E8h, 03h,0E9h,0F4h
		db	 01h,0BAh, 2Ch, 9Bh,0E8h, 63h
		db	0E4h,0C6h, 06h, 9Bh, 00h,0FFh
		db	0C3h,0BAh, 9Ch, 9Bh,0E8h, 57h
		db	0E4h, 56h, 2Eh,0FFh, 16h, 04h
		db	 30h,0C6h, 06h, 92h, 00h, 06h
		db	0B0h, 06h,0BBh,0ABh, 18h, 2Eh
		db	0FFh, 16h, 1Ch, 20h, 8Ah, 26h
		db	 92h, 00h,0B0h, 04h, 2Eh,0FFh
		db	 16h, 0Ch, 01h, 5Eh,0C3h,0E8h
		db	0A7h, 02h,0FEh, 44h, 06h, 80h
		db	 64h, 06h, 03h,0E8h,0D8h, 01h
		db	 73h, 01h,0C3h,0C6h, 06h, 75h
		db	0FFh, 10h, 8Ah, 44h, 04h, 24h
		db	 0Fh, 3Ch, 04h, 75h, 09h,0B8h
		db	 01h, 00h,0E8h,0ADh, 01h,0E9h
		db	 7Ah, 01h
loc_572:
		cmp	al,5
		jne	loc_573			; Jump if not equal
		mov	ax,0Ah
		call	sub_120
		jmp	loc_591
loc_573:
		mov	ax,64h
		call	sub_120
		jmp	loc_591
			                        ;* No entry point to code
		mov	dx,9A72h
		call	sub_118
		jnc	loc_574			; Jump if carry=0
		retn
loc_574:
		inc	byte ptr ds:[98h]
		jmp	loc_591
		db	0BAh,0CBh, 9Bh,0E8h
data_71		dw	0D5h
data_72		dw	173h
data_73		dw	0FEC3h
data_74		dw	9906h
data_75		dw	0E900h
data_76		dw	144h
		db	0E8h, 85h
data_77		dw	7301h
data_78		dw	0C301h
data_79		dw	83BAh
data_80		dw	0E89Ah
data_81		dw	0E3CCh
data_82		dw	680h
data_83		dw	0C6h
data_85		dw	0E90Ah
data_86		dw	offset sub_2
data_87		dw	offset sub_142
		db	 02h,0E8h, 6Eh
data_88		dw	7301h
		db	1
data_89		dw	0BAC3h
data_90		dw	9A99h
		db	0E8h,0B5h,0E3h,0A1h,0B2h, 00h
		db	0D1h,0E8h,0D1h,0E8h,0D1h,0E8h
		db	 40h, 01h, 06h,0C6h, 00h,0E9h
		db	 10h, 01h,0C6h, 44h, 0Fh, 00h
		db	0F6h, 44h, 09h, 01h, 75h, 2Ah
		db	0E8h, 47h, 01h, 73h, 01h,0C3h
loc_576:
		mov	byte ptr ds:data_247e,11h
		or	byte ptr [si+7],80h
		or	byte ptr [si+9],1
		mov	byte ptr [si+0Ah],0EBh
		mov	bl,[si+6]
		add	bl,bl
		xor	bh,bh			; Zero register
		add	bx,ds:data_200e
		push	si
		mov	si,[bx]
		call	sub_52
		pop	si
		retn
loc_577:
		test	byte ptr [si+0Ah],0FFh
		jz	loc_578			; Jump if zero
		inc	byte ptr [si+0Ah]
		retn
loc_578:
		and	byte ptr [si+9],0FEh
		retn
			                        ;* No entry point to code
		mov	dx,9AF3h
		call	sub_118
		jnc	loc_579			; Jump if carry=0
		retn
loc_579:
		mov	byte ptr ds:[9Ch],0FFh
		jmp	loc_591
			                        ;* No entry point to code
		mov	dx,9B63h
		call	sub_118
		jnc	loc_580			; Jump if carry=0
		retn
loc_580:
		mov	al,1
		jmp	short loc_581
			                        ;* No entry point to code
		mov	al,ds:data_196e
		sub	al,4
		mov	cl,3
		mul	cl			; ax = reg * al
		mov	di,data_116e
		add	di,ax
		mov	al,[di]
		mov	dx,[di+1]
		push	ax
		call	sub_118
		pop	ax
		jnc	loc_581			; Jump if carry=0
		retn
loc_581:
		push	ax
		mov	di,0A1h
loc_582:
		test	byte ptr [di],0FFh
		jz	loc_583			; Jump if zero
		inc	di
		jmp	short loc_582
loc_583:
		pop	ax
		mov	[di],al
		jmp	loc_591
			                        ;* No entry point to code
		add	al,0Fh
		db	9Bh			;  Fixup - byte match
		add	al,[bx-65h]
		add	di,[bx-65h]

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_118:
		push	dx
		call	sub_125
		call	sub_121
		pop	dx
		jnc	loc_584			; Jump if carry=0
		retn
loc_584:
		mov	byte ptr ds:data_247e,11h
		jmp	loc_278
loc_585:
		add	byte ptr [si+6],80h
		jc	loc_586			; Jump if carry Set
		retn
loc_586:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],3
		je	loc_587			; Jump if equal
		retn
loc_587:
		mov	byte ptr [si+0Fh],0
		test	byte ptr [si+7],40h	; '@'
		jz	loc_588			; Jump if zero
		and	byte ptr [si+7],0BFh
		mov	al,[si+0Ah]
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,ds:data_195e
		mov	di,ax
		mov	byte ptr [di+2],0
loc_588:
		test	byte ptr [si+7],10h
		jz	loc_589			; Jump if zero
		test	byte ptr [si+4],1
		jz	loc_591			; Jump if zero
loc_589:
		mov	byte ptr [si+6],0
		mov	byte ptr [si+4],72h	; 'r'
		mov	al,[si+7]
		and	al,0Fh
		jnz	loc_590			; Jump if not zero
		retn
loc_590:
		cmp	al,1
		je	loc_591			; Jump if equal
		or	al,70h			; 'p'
		or	byte ptr [si+7],80h
		mov	byte ptr [si+0Fh],4
		mov	[si+4],al
		and	byte ptr [si+5],80h
		and	byte ptr [si+7],0F0h
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_119:
loc_591:
		mov	word ptr [si],0FF00h
		test	byte ptr [si+7],20h	; ' '
		jnz	loc_592			; Jump if not zero
		retn
loc_592:
		mov	di,[si+0Bh]
		cmp	di,0FFFFh
		jne	loc_593			; Jump if not equal
		retn
loc_593:
		mov	al,[si+0Dh]
		or	[di],al
		mov	word ptr [si+0Bh],0FFFFh
		retn
sub_117		endp

			                        ;* No entry point to code
		add	word ptr ds:[86h],ax
		adc	byte ptr ds:[85h],0
		push	si
		call	word ptr cs:[2016h]
		pop	si
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_120		proc	near
		add	word ptr ds:[8Bh],ax
		jnc	loc_594			; Jump if carry=0
		mov	word ptr ds:[8Bh],0FFFFh
loc_594:
		push	si
		call	word ptr cs:[2014h]
		pop	si
		retn
sub_120		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_121		proc	near
		test	byte ptr ds:[0E8h],0FFh
		stc				; Set carry flag
		jz	loc_595			; Jump if zero
		retn
loc_595:
		mov	ah,[si+2]
		add	ah,2
		mov	cx,4

locloop_596:
		dec	ah
		and	ah,3Fh			; '?'
		cmp	ah,ds:data_227e
		je	loc_597			; Jump if equal
		loop	locloop_596		; Loop if cx > 0

		and	byte ptr [si+7],7Fh
		stc				; Set carry flag
		retn
loc_597:
		mov	al,byte ptr ds:[83h]
		add	al,4
		mov	ah,[si+3]
		sub	ah,3
		mov	cx,4

locloop_598:
		inc	ah
		cmp	ah,al
		je	loc_599			; Jump if equal
		loop	locloop_598		; Loop if cx > 0

		and	byte ptr [si+7],7Fh
		stc				; Set carry flag
		retn
loc_599:
		test	byte ptr [si+7],80h
		clc				; Clear carry flag
		jnz	loc_600			; Jump if not zero
		retn
loc_600:
		inc	byte ptr [si+0Fh]
		test	byte ptr [si+0Fh],7
		jnz	loc_601			; Jump if not zero
		retn
loc_601:
		stc				; Set carry flag
		retn
sub_121		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_122		proc	near
loc_602:
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	loc_603			; Jump if carry=0
		retn
loc_603:
		call	sub_128
		jnc	loc_604			; Jump if carry=0
		retn
loc_604:
		jmp	loc_623
			                        ;* No entry point to code
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	loc_605			; Jump if carry=0
		retn
loc_605:
		call	sub_134
		jnc	loc_606			; Jump if carry=0
		retn
loc_606:
		call	sub_126
		jmp	loc_628

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_123:
loc_607:
		mov	al,[si+3]
		or	al,al			; Zero ?
		stc				; Set carry flag
		jnz	loc_608			; Jump if not zero
		retn
loc_608:
		cmp	al,23h			; '#'
		stc				; Set carry flag
		jnz	loc_609			; Jump if not zero
		retn
loc_609:
		call	sub_132
		jnc	loc_610			; Jump if carry=0
		retn
loc_610:
		jmp	loc_628
			                        ;* No entry point to code
		cmp	byte ptr [si+3],2
		jae	loc_611			; Jump if above or =
		retn
loc_611:
		call	sub_136
		jnc	loc_612			; Jump if carry=0
		retn
loc_612:
		call	sub_127
		jmp	short loc_628

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_124:
loc_613:
		cmp	byte ptr [si+3],2
		jae	loc_614			; Jump if above or =
		retn
loc_614:
		call	sub_130
		jnc	loc_615			; Jump if carry=0
		retn
loc_615:
		jmp	short loc_625
			                        ;* No entry point to code
		cmp	byte ptr [si+3],2
		jae	loc_616			; Jump if above or =
		retn
loc_616:
		call	sub_137
		jnc	loc_617			; Jump if carry=0
		retn
loc_617:
		call	sub_127
		jmp	short loc_627

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_125:
		mov	al,[si+3]
		or	al,al			; Zero ?
		stc				; Set carry flag
		jnz	loc_618			; Jump if not zero
		retn
loc_618:
		cmp	al,23h			; '#'
		stc				; Set carry flag
		jnz	loc_619			; Jump if not zero
		retn
loc_619:
		call	sub_133
		jnc	loc_620			; Jump if carry=0
		retn
loc_620:
		jmp	short loc_627
			                        ;* No entry point to code
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	loc_621			; Jump if carry=0
		retn
loc_621:
		call	sub_135
		jnc	loc_622			; Jump if carry=0
		retn
loc_622:
		call	sub_126
		jmp	short loc_627

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_126:
loc_623:
		mov	ax,[si]
		inc	ax
		mov	bx,ax
		sub	bx,ds:data_188e
		jc	loc_624			; Jump if carry Set
		mov	ax,bx
loc_624:
		mov	[si],ax
		inc	byte ptr [si+3]
		clc				; Clear carry flag
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_127:
loc_625:
		mov	ax,[si]
		or	ax,ax			; Zero ?
		jnz	loc_626			; Jump if not zero
		mov	ax,ds:data_188e
loc_626:
		dec	ax
		mov	[si],ax
		dec	byte ptr [si+3]
		clc				; Clear carry flag
		retn
loc_627:
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		retn
loc_628:
		dec	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		retn
sub_122		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_128		proc	near
		mov	ax,[si+2]
		call	sub_33
		inc	di
		inc	di
		call	sub_129
		jnc	loc_629			; Jump if carry=0
		retn
loc_629:
		xchg	si,di
		add	si,24h
		call	sub_34
		xchg	si,di
		call	sub_129
		jnc	loc_630			; Jump if carry=0
		retn
loc_630:
		xchg	si,di
		mov	al,[si]
		sub	si,24h
		call	sub_35
		or	al,[si]
		sub	si,24h
		call	sub_35
		or	al,[si]
		xchg	si,di
		add	al,al
		retn
sub_128		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_129		proc	near
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_631			; Jump if zero
		retn
loc_631:
		cmp	byte ptr ds:data_196e,5
		clc				; Clear carry flag
		jz	loc_632			; Jump if zero
		retn
loc_632:
		push	si
		call	sub_63
		pop	si
		dec	cl
		clc				; Clear carry flag
		jz	loc_633			; Jump if zero
		retn
loc_633:
		stc				; Set carry flag
		retn
sub_129		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_130		proc	near
		mov	ax,[si+2]
		call	sub_33
		dec	di
		call	sub_131
		jnc	loc_634			; Jump if carry=0
		retn
loc_634:
		xchg	si,di
		add	si,24h
		call	sub_34
		xchg	si,di
		call	sub_131
		jnc	loc_635			; Jump if carry=0
		retn
loc_635:
		dec	di
		xchg	si,di
		mov	al,[si]
		sub	si,24h
		call	sub_35
		or	al,[si]
		sub	si,24h
		call	sub_35
		or	al,[si]
		xchg	si,di
		add	al,al
		retn
sub_130		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_131		proc	near
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_636			; Jump if zero
		retn
loc_636:
		cmp	byte ptr ds:data_196e,5
		clc				; Clear carry flag
		jz	loc_637			; Jump if zero
		retn
loc_637:
		push	si
		call	sub_63
		pop	si
		dec	cl
		dec	cl
		clc				; Clear carry flag
		jz	loc_638			; Jump if zero
		retn
loc_638:
		stc				; Set carry flag
		retn
sub_131		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_132		proc	near
		mov	ax,[si+2]
		call	sub_33
		xchg	si,di
		sub	si,24h
		call	sub_35
		xchg	si,di
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_639			; Jump if zero
		retn
loc_639:
		mov	al,[di+1]
		call	sub_138
		stc				; Set carry flag
		jz	loc_640			; Jump if zero
		retn
loc_640:
		xchg	si,di
		sub	si,24h
		call	sub_35
		xchg	si,di
		mov	al,[di+1]
		or	al,[di]
		or	al,[di-1]
		add	al,al
		retn
sub_132		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_133		proc	near
		mov	ax,[si+2]
		call	sub_33
		xchg	si,di
		add	si,48h
		call	sub_34
		xchg	si,di
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_641			; Jump if zero
		retn
loc_641:
		mov	al,[di+1]
		call	sub_138
		stc				; Set carry flag
		jz	loc_642			; Jump if zero
		retn
loc_642:
		or	al,[di]
		or	al,[di-1]
		add	al,al
		retn
sub_133		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_134		proc	near
		mov	ax,[si+2]
		call	sub_33
		inc	di
		inc	di
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_643			; Jump if zero
		retn
loc_643:
		mov	cl,al
		xchg	si,di
		sub	si,24h
		call	sub_35
		xchg	si,di
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_644			; Jump if zero
		retn
loc_644:
		or	cl,al
		mov	al,[di-1]
		call	sub_138
		stc				; Set carry flag
		jz	loc_645			; Jump if zero
		retn
loc_645:
		xchg	si,di
		sub	si,24h
		call	sub_35
		xchg	si,di
		or	cl,[di]
		or	cl,[di-1]
		or	cl,[di-2]
		add	cl,cl
		retn
sub_134		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_135		proc	near
		mov	ax,[si+2]
		call	sub_33
		inc	di
		inc	di
		mov	cl,[di]
		xchg	si,di
		add	si,24h
		call	sub_34
		xchg	si,di
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_646			; Jump if zero
		retn
loc_646:
		or	cl,al
		xchg	si,di
		add	si,24h
		call	sub_34
		xchg	si,di
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_647			; Jump if zero
		retn
loc_647:
		or	cl,al
		mov	al,[di-1]
		call	sub_138
		stc				; Set carry flag
		jz	loc_648			; Jump if zero
		retn
loc_648:
		or	cl,al
		or	cl,[di-2]
		add	cl,cl
		retn
sub_135		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_136		proc	near
		mov	ax,[si+2]
		call	sub_33
		dec	di
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_649			; Jump if zero
		retn
loc_649:
		dec	di
		mov	cl,[di]
		xchg	si,di
		sub	si,24h
		call	sub_35
		xchg	si,di
		or	cl,[di]
		mov	al,[di+1]
		call	sub_138
		stc				; Set carry flag
		jz	loc_650			; Jump if zero
		retn
loc_650:
		mov	al,[di+2]
		call	sub_138
		stc				; Set carry flag
		jz	loc_651			; Jump if zero
		retn
loc_651:
		xchg	si,di
		sub	si,24h
		call	sub_35
		xchg	si,di
		or	cl,[di+2]
		or	cl,[di+1]
		or	cl,[di]
		add	cl,cl
		retn
sub_136		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_137		proc	near
		mov	ax,[si+2]
		call	sub_33
		dec	di
		dec	di
		mov	cl,[di]
		xchg	si,di
		add	si,24h
		call	sub_34
		xchg	si,di
		or	cl,[di]
		inc	di
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_652			; Jump if zero
		retn
loc_652:
		xchg	si,di
		add	si,24h
		call	sub_34
		xchg	si,di
		mov	al,[di]
		call	sub_138
		stc				; Set carry flag
		jz	loc_653			; Jump if zero
		retn
loc_653:
		or	cl,al
		mov	al,[di+1]
		call	sub_138
		stc				; Set carry flag
		jz	loc_654			; Jump if zero
		retn
loc_654:
		or	cl,al
		or	cl,[di-1]
		add	cl,cl
		retn
sub_137		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_138		proc	near
		cmp	al,49h			; 'I'
		jb	loc_656			; Jump if below
		or	al,al			; Zero ?
		jns	loc_655			; Jump if not sign
		retn
loc_655:
		cmp	al,al
		retn
loc_656:
		push	di
		push	cx
		mov	es,cs:data_220e
		mov	di,data_1e
		mov	cx,18h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		pop	cx
		pop	di
		retn
sub_138		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_139		proc	near
		cmp	byte ptr [si+1],0FFh
		je	loc_657			; Jump if equal
		retn
loc_657:
		test	byte ptr [si+7],10h
		jz	loc_658			; Jump if zero
		cmp	byte ptr [si+11h],0FFh
		je	loc_658			; Jump if equal
		retn
loc_658:
		mov	ax,[si+0Bh]
		cmp	ax,0FFFFh
		jne	loc_659			; Jump if not equal
		retn
loc_659:
		call	sub_141
		jnc	loc_660			; Jump if carry=0
		retn
loc_660:
		or	bl,bl			; Zero ?
		jnz	loc_661			; Jump if not zero
		retn
loc_661:
		cmp	bl,23h			; '#'
		jne	loc_662			; Jump if not equal
		retn
loc_662:
		mov	al,byte ptr ds:[82h]
		sub	al,2
		and	al,3Fh			; '?'
		sub	al,[si+0Dh]
		neg	al
		and	al,3Fh			; '?'
		cmp	al,18h
		jae	loc_663			; Jump if above or =
		cmp	bl,3
		jb	loc_663			; Jump if below
		cmp	bl,20h			; ' '
		jae	loc_663			; Jump if above or =
		retn
loc_663:
		test	byte ptr [si+7],10h
		jnz	loc_666			; Jump if not zero
		mov	[si+3],bl
		mov	al,[si+0Dh]
		mov	ah,bl
		call	sub_33
		push	di
		xchg	si,di
		sub	si,25h
		call	sub_35
		xor	al,al			; Zero register
		mov	cx,3

locloop_664:
		or	al,[si]
		or	al,[si+1]
		or	al,[si+2]
		add	si,24h
		call	sub_34
		loop	locloop_664		; Loop if cx > 0

		xchg	si,di
		pop	di
		or	al,al			; Zero ?
		jns	loc_665			; Jump if not sign
		retn
loc_665:
		mov	al,ds:data_245e
		or	al,80h
		mov	[di],al
		mov	ax,[si+0Bh]
		mov	[si],ax
		mov	al,[si+0Dh]
		mov	[si+2],al
		mov	al,[si+0Eh]
		mov	[si+4],al
		mov	byte ptr [si+6],10h
		mov	byte ptr [si+5],0
		mov	word ptr [si+9],0
		mov	byte ptr [si+8],0
		mov	bl,ds:data_245e
		xor	bh,bh			; Zero register
		mov	byte ptr ds:data_212e[bx],0
		retn
loc_666:
		test	byte ptr [si+0Eh],1
		jz	loc_667			; Jump if zero
		retn
loc_667:
		mov	[si+3],bl
		mov	[si+13h],bl
		mov	al,[si+0Dh]
		mov	ah,bl
		call	sub_33
		push	di
		xchg	si,di
		sub	si,25h
		call	sub_35
		xor	al,al			; Zero register
		mov	cx,5

locloop_668:
		or	al,[si]
		or	al,[si+1]
		or	al,[si+2]
		add	si,24h
		call	sub_34
		loop	locloop_668		; Loop if cx > 0

		xchg	si,di
		pop	di
		or	al,al			; Zero ?
		jns	loc_669			; Jump if not sign
		retn
loc_669:
		mov	al,ds:data_245e
		or	al,80h
		mov	[di],al
		xchg	si,di
		add	si,48h
		call	sub_34
		xchg	si,di
		inc	al
		mov	[di],al
		mov	ax,[si+0Bh]
		mov	[si],ax
		mov	[si+10h],ax
		mov	al,[si+0Dh]
		mov	[si+2],al
		add	al,2
		and	al,3Fh			; '?'
		mov	[si+12h],al
		mov	al,[si+0Eh]
		mov	[si+4],al
		inc	al
		mov	[si+14h],al
		mov	byte ptr [si+6],10h
		mov	byte ptr [si+16h],10h
		mov	byte ptr [si+5],0
		mov	byte ptr [si+15h],0
		mov	word ptr [si+9],0
		mov	word ptr [si+19h],0
		mov	byte ptr [si+8],0
		mov	byte ptr [si+18h],0
		and	byte ptr [si+17h],0F0h
		mov	bl,ds:data_245e
		xor	bh,bh			; Zero register
		mov	word ptr ds:data_212e[bx],0
		retn
sub_139		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_140		proc	near
		push	cs
		pop	es
		mov	di,data_212e
		mov	cx,80h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		jmp	short $+2		; delay for I/O
		mov	byte ptr ds:data_245e,0
		mov	si,ds:data_195e
loc_670:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_671			; Jump if not equal
		retn
loc_671:
		cmp	ah,0FFh
		je	loc_672			; Jump if equal
		mov	byte ptr [si+3],0FFh
		call	sub_141
		jc	loc_672			; Jump if carry Set
		mov	[si+3],bl
		mov	al,[si+2]
		mov	ah,bl
		call	sub_33
		mov	al,ds:data_245e
		or	al,80h
		mov	[di],al
loc_672:
		inc	byte ptr ds:data_245e
		add	si,10h
		jmp	short loc_670
sub_140		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_141		proc	near
		mov	bx,ax
		sub	ax,word ptr ds:[80h]
		jnc	loc_674			; Jump if carry=0
		mov	ax,23h
		sub	ax,bx
		jnc	loc_673			; Jump if carry=0
		retn
loc_673:
		mov	ax,ds:data_188e
		sub	ax,word ptr ds:[80h]
		add	ax,bx
loc_674:
		xchg	bx,ax
		mov	ax,23h
		sub	ax,bx
		retn
sub_141		endp

loc_675:
		mov	al,[si+4]
		test	al,10h
		jnz	loc_676			; Jump if not zero
		and	al,0Fh
		mov	bx,data_185e
		xlat				; al=[al+[bx]] table
		xor	ah,ah			; Zero register
		call	sub_143
		jmp	short loc_676
loc_676:
		mov	byte ptr [si+6],0
		or	byte ptr [si+4],68h	; 'h'
		and	byte ptr [si+5],80h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_142		proc	near
		test	byte ptr [si+7],10h
		jz	loc_677			; Jump if zero
		test	byte ptr [si+4],1
		jnz	loc_677			; Jump if not zero
		mov	byte ptr [si+6],80h
		mov	byte ptr [si+16h],0
		or	byte ptr [si+14h],68h	; 'h'
		and	byte ptr [si+15h],80h
loc_677:
		mov	al,[si+2]
		mov	ah,byte ptr ds:[82h]
		dec	ah
		sub	al,ah
		and	al,3Fh			; '?'
		cmp	al,13h
		jb	loc_678			; Jump if below
		retn
loc_678:
		mov	byte ptr ds:data_247e,7
		retn
sub_142		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_143		proc	near
		add	word ptr ds:[8Eh],ax
		jc	loc_679			; Jump if carry Set
		retn
loc_679:
		mov	word ptr ds:[8Eh],0FFFFh
		retn
sub_143		endp

			                        ;* No entry point to code
		and	al,7
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_120e[bx]	;*
			                        ;* No entry point to code
		in	ax,91h			; port 91h ??I/O Non-standard
		not	byte ptr ds:data_118e[bx+di]
		and	dl,ss:data_119e[bp+si]
		inc	bx
		xchg	dx,ax
		push	bp
		xchg	dx,ax
		db	 6Ch, 92h, 24h, 07h, 8Ah,0D8h
		db	 32h,0FFh, 03h,0DBh,0FFh,0A7h
		db	 4Bh, 97h,0B4h, 92h,0C5h, 93h
		db	 62h, 93h, 52h, 94h, 0Ah, 93h
		db	 9Ah, 94h, 9Ah, 93h, 0Ch, 94h
		db	 8Bh, 44h, 02h,0E8h, 0Dh,0D6h
		db	 87h,0FEh, 83h,0C6h, 24h,0E8h
		db	 19h,0D6h, 87h,0FEh,0B9h, 02h
		db	 00h

locloop_680:
		push	cx
		push	si
		mov	al,[di]
		call	sub_63
		mov	bl,cl
		pop	si
		pop	cx
		jz	loc_681			; Jump if zero
		inc	di
		loop	locloop_680		; Loop if cx > 0

		retn
loc_681:
		pop	ax
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_121e[bx]	;*
			                        ;* No entry point to code
;*		call	far ptr sub_156		;*
		db	9Ah
		dw	9497h, 8E97h		;  Fixup - byte match
		xchg	di,ax
		call	sub_122
		jmp	loc_602
			                        ;* No entry point to code
		call	sub_124
		jmp	loc_613
			                        ;* No entry point to code
		call	sub_123
		jmp	loc_607
			                        ;* No entry point to code
		mov	ax,[si+2]
		call	sub_33
		xchg	si,di
		add	si,48h
		call	sub_34
		xchg	si,di
		mov	al,[di]
		jmp	loc_274
			                        ;* No entry point to code
		mov	al,[si+5]
		and	al,1Fh
		call	sub_144
		mov	al,[si+8]
		sub	al,ah
		jbe	loc_682			; Jump if below or =
		mov	[si+8],al
		mov	byte ptr ds:data_247e,6
		retn
loc_682:
		test	byte ptr [si+4],1
		jnz	loc_683			; Jump if not zero
		test	byte ptr [si+7],10h
		jnz	loc_686			; Jump if not zero
loc_683:
		test	byte ptr [si+7],0Fh
		jz	loc_684			; Jump if zero
		jmp	loc_675
loc_684:
		mov	di,ds:data_184e
		mov	bl,[si+4]
		and	bl,7
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	di,[bx+di]
		call	word ptr cs:[11Ah]
		mov	bl,al
		and	bx,3
		cmp	byte ptr ds:data_242e,2
		jne	loc_685			; Jump if not equal
		xor	bx,bx			; Zero register
loc_685:
		mov	al,[bx+di]
		mov	ah,[si+7]
		and	ah,0F0h
		or	al,ah
		mov	[si+7],al
		jmp	loc_675
loc_686:
		test	byte ptr [si+17h],0Fh
		jz	loc_687			; Jump if zero
		jmp	loc_675
loc_687:
		mov	di,ds:data_184e
		mov	bl,[si+4]
		and	bl,7
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	di,[bx+di]
		call	word ptr cs:[11Ah]
		mov	bl,al
		and	bx,3
		cmp	byte ptr ds:data_242e,2
		jne	loc_688			; Jump if not equal
		xor	bx,bx			; Zero register
loc_688:
		mov	al,[bx+di]
		mov	ah,[si+17h]
		and	ah,0F0h
		or	al,ah
		mov	[si+17h],al
		jmp	loc_675

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_144		proc	near
		mov	ah,byte ptr ds:[8Dh]
		shr	ah,1			; Shift w/zeros fill
		inc	ah
		or	al,al			; Zero ?
		jnz	loc_689			; Jump if not zero
		retn
loc_689:
		cmp	al,1
		je	loc_693			; Jump if equal
		mov	ah,byte ptr ds:[8Dh]
		inc	ah
		add	ah,ah
		jc	loc_690			; Jump if carry Set
		add	ah,ah
		jnc	loc_691			; Jump if carry=0
loc_690:
		mov	ah,0FFh
loc_691:
		cmp	al,9
		jne	loc_692			; Jump if not equal
		retn
loc_692:
		sub	al,2
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	ah,ds:data_123e[bx]
		retn
loc_693:
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,ds:data_122e[bx]
		mov	bl,byte ptr ds:[8Dh]
		shr	bl,1			; Shift w/zeros fill
		add	al,bl
		jc	loc_694			; Jump if carry Set
		mov	cl,byte ptr ds:[0E4h]
		inc	cl
		mul	cl			; ax = reg * al
		or	ah,ah			; Zero ?
		jz	loc_695			; Jump if zero
loc_694:
		mov	al,0FFh
loc_695:
		mov	ah,al
		cmp	byte ptr ds:data_242e,2
		je	loc_696			; Jump if equal
		retn
loc_696:
		add	ah,ah
		jc	loc_697			; Jump if carry Set
		retn
loc_697:
		mov	ah,0FFh
		retn
sub_144		endp

			                        ;* No entry point to code
		add	[bp+si],ax
		add	al,8
		and	[bx+2],bh
		add	al,8
		adc	[bx+si],ah
		inc	ax
		push	word ptr [bp+si]
		ror	byte ptr ss:[103Eh][bp+di],cl	; Rotate
		db	0C0h
loc_698:
		cmp	word ptr [di],0FFFFh
		stc				; Set carry flag
		jnz	loc_699			; Jump if not zero
		retn
loc_699:
		cmp	word ptr [di+0Bh],0FFFFh
		jne	loc_700			; Jump if not equal
		cmp	byte ptr [di+1],0FFh
		je	loc_701			; Jump if equal
		mov	ax,[di]
		push	dx
		call	sub_141
		pop	dx
		jnc	loc_700			; Jump if carry=0
		test	byte ptr [di+4],10h
		jz	loc_702			; Jump if zero
loc_700:
		inc	dl
		add	di,10h
		jmp	short loc_698
loc_701:
		cmp	byte ptr [di+2],7Fh
		je	loc_700			; Jump if equal
loc_702:
		clc				; Clear carry flag
		retn
loc_703:
		call	word ptr cs:data_73
		mov	byte ptr ds:data_240e,0
		mov	byte ptr ds:data_234e,0
		mov	byte ptr ds:data_230e,0
		mov	byte ptr ds:data_228e,0
		mov	byte ptr ds:[0E8h],0FFh
		mov	byte ptr ds:data_175e,0
		mov	byte ptr ds:data_176e,0
		call	word ptr cs:[2008h]
		mov	byte ptr ds:[0E7h],0
		mov	byte ptr ds:data_231e,0
		mov	byte ptr ds:data_229e,0
		call	sub_44
		mov	ax,9929h
		push	ax
		call	sub_18
		pop	ax
		mov	byte ptr ds:data_229e,0
loc_704:
		call	sub_44
		mov	byte ptr ds:data_229e,0
		cmp	byte ptr ds:[0E7h],2
		je	loc_705			; Jump if equal
		inc	byte ptr ds:data_175e
		test	byte ptr ds:data_175e,7
		jnz	loc_704			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		inc	al
		and	al,3
		cmp	al,3
		je	loc_704			; Jump if equal
		mov	byte ptr ds:[0E7h],al
		jmp	short loc_704
loc_705:
		inc	byte ptr ds:data_176e
		test	byte ptr ds:data_176e,0Fh
		jz	loc_706			; Jump if zero
		test	byte ptr ds:data_176e,1
		jz	loc_704			; Jump if zero
		mov	byte ptr ds:data_229e,0FFh
		jmp	short loc_704
loc_706:
		mov	byte ptr ds:data_219e,8
		mov	cx,1Eh

locloop_707:
		push	cx
		call	sub_44
		pop	cx
		mov	al,cl
		and	al,1
		dec	al
		mov	ds:data_229e,al
		loop	locloop_707		; Loop if cx > 0

		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		call	word ptr cs:[2040h]
		test	byte ptr ds:[49h],0FFh
		jz	loc_708			; Jump if zero
		mov	byte ptr ds:[0C5h],80h
		jmp	short loc_709
loc_708:
		mov	al,byte ptr ds:[8Dh]
		add	al,al
		neg	al
		add	al,7Fh
		xor	ah,ah			; Zero register
		call	sub_143
		mov	byte ptr ds:[85h],0
		mov	word ptr ds:[86h],0
		shr	word ptr ds:[8Bh],1	; Shift w/zeros fill
loc_709:
		mov	ax,word ptr ds:[0B2h]
		mov	word ptr ds:[90h],ax
		jmp	short loc_710
loc_710:
		mov	byte ptr ds:data_214e,0
		mov	ah,byte ptr ds:[0C5h]
		mov	byte ptr ds:[0C4h],ah
		mov	al,1
		call	word ptr cs:[10Ch]
		mov	ax,ds:data_197e
		mov	ds:data_162e,ax
		mov	si,ds:data_187e
		inc	si
		lodsb				; String [si] to al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9C2Dh
		mov	si,ax
		mov	es,cs:data_220e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	bx,6002h
		jmp	loc_367
		db	 26h, 00h
		db	'You get 50 golds.'
		db	0FFh, 22h, 00h
		db	'You get 100 golds.'
		db	0FFh, 22h, 00h
		db	'You get 500 golds.'
		db	0FFh, 1Eh, 00h
		db	'You get 1000 golds.'
		db	0FFh, 32h, 00h
		db	'You get a Key'
data_91		dw	0FF2Eh			; Data table (indexed access)
		db	 1Ch, 00h
		db	'You have recovered.'
		db	0FFh, 08h, 00h
		db	'You have recovered full.'
		db	0FFh, 3Ch, 00h
		db	'Shield broken.'
		db	0FFh, 14h, 00h
		db	'Can\t open this door.'
		db	0FFh, 1Ch, 00h
		db	'Nothing in the box.'
		db	0FFh, 06h, 00h
		db	'You get the Hero\s Crest.'
		db	0FFh, 00h, 00h
		db	'You get the Ruzeria shoes.'
		db	0FFh, 08h, 00h
		db	'You get the Glory Crest.'
		db	0FFh, 06h, 00h
		db	'You get the Pirika shoes.'
		db	0FFh, 06h, 00h
		db	'You get the Feruza shoes.'
		db	0FFh, 00h, 00h
		db	'You get the Silkarn shoes.'
		db	0FFh, 00h, 00h
		db	'Get the Enchantment sword.'
		db	0FFh, 30h, 00h
		db	'It\s too hot !!'
		db	0FFh, 08h, 00h
		db	'Get the lion\s head Key.'
		db	0FFh, 02h
		db	'4FMAN.GRP'
		db	0, 2
		db	'8ENCNT.GRP'
		db	0, 2
		db	'5ROKA.GRP'
		db	0, 1
		db	':ROKA.GRP'
		db	0, 2
		db	'7DCHR.GRP'
		db	0, 2, 1
		db	'ROKADEMO.BIN'
		db	 00h, 01h, 1Eh
		db	'MMAN.GRP'
		db	 00h, 01h, 1Fh
		db	'CMAN.GRP'
		db	0, 2
		db	'KMPP1.GRP'
		db	0, 2
		db	'LMPP2.GRP'
		db	0, 2
		db	'MMPP3.GRP'
		db	0, 2
		db	'NMPP4.GRP'
		db	0, 2
		db	'OMPP5.GRP'
		db	0, 2
		db	'PMPP6.GRP'
		db	0, 2
		db	'QMPP7.GRP'
		db	0, 2
		db	'RMPP8.GRP'
		db	0, 2
		db	'SMPP9.GRP'
		db	0, 2
		db	'TMPPA.GRP'
		db	0, 2
		db	'UMPPB.GRP'
		db	0, 2, 2
		db	'EAI1.BIN'
		db	0, 2
		db	0Ah, 'CRAB.BIN'
		db	0, 2, 3
		db	'EAI2.BIN'
		db	 00h, 02h, 0Bh
		db	'TAKO.BIN'
		db	0, 2, 4
		db	'EAI3.BIN'
		db	0, 2
		db	0Ch, 'TORI.BIN'
		db	0, 2, 5
		db	'EAI4.BIN'
		db	0, 2
		db	0Dh, 'ZELA.BIN'
		db	0, 2, 6
		db	'EAI5.BIN'
		db	 00h, 02h, 0Eh
		db	'MEDA.BIN'
		db	0, 2, 7
		db	'EAI6.BIN'
		db	 00h, 02h, 0Fh
		db	'LEGA.BIN'
		db	0, 2
		db	8, 'EAI7.BIN'
		db	 00h, 02h, 11h
		db	'DRGN.BIN'
		db	0, 2
		db	9, 'EAI8.BIN'
		db	 00h, 02h, 12h
		db	'AKMA.BIN'
		db	 00h, 02h, 13h
		db	'MAO1.BIN'
		db	 00h, 02h, 14h
		db	'MAO2.BIN'
		db	 00h, 02h, 10h
		db	'ZEL2.BIN'
		db	0, 2
		db	'9ENP1.GRP'
		db	0, 2
		db	'ACRAB.GRP'
		db	0, 2
		db	':ENP2.GRP'
		db	0, 2
		db	'BTAKO.GRP'
		db	0, 2
		db	';ENP3.GRP'
		db	0, 2
		db	'CTORI.GRP'
		db	0, 2
		db	'<ENP4.GRP'
		db	0, 2
		db	'DZELA.GRP'
		db	0, 2
		db	'=ENP5.GRP'
		db	0, 2
		db	'EMEDA.GRP'
		db	0, 2
		db	'>ENP6.GRP'
		db	0, 2
		db	'FLEGA.GRP'
		db	0, 2
		db	'?ENP7.GRP'
		db	0, 2
		db	'GDRGN.GRP'
		db	0, 2
		db	'@ENP8.GRP'
		db	0, 2
		db	'HAKMA.GRP'
		db	0, 2
		db	'IMAO1.GRP'
		db	0, 2
		db	'JMAO2.GRP'
		db	0, 1
		db	'/MGT1.MSD'
		db	0, 1
		db	'1UGM1.MSD'
		db	0, 1
		db	'0MGT2.MSD'
		db	0, 1
		db	'2UGM2.MSD'
		db	0, 2
		db	'VMUS1.MSD'
		db	0, 2
		db	'WMUS2.MSD'
		db	0, 2
		db	'XMUS3.MSD'
		db	0, 2
		db	'YMUS4.MSD'
		db	0, 2
		db	'ZMUS5.MSD'
		db	0, 2
		db	'[MUS6.MSD'
		db	0, 2
		db	'\MUS7.MSD'
		db	0, 2
		db	']MUS8.MSD'
		db	0, 2
		db	'^MBOS.MSD'
		db	0, 2
		db	'`MMAO.MSD'
		db	9 dup (0)
		db	0FFh, 00h
		db	7 dup (0)
		db	0FFh,0FFh, 00h
		db	12 dup (0)
		db	2, 0
		db	31 dup (0)

seg_a		ends



		end	start
