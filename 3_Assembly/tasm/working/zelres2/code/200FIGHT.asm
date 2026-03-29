
PAGE  59,132

;==========================================================================
;
;  MAIN_GAME_LOOP - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; Mapped addresses (auto-fixed from original chunk)
game_func_142		equ	036E8h


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
data_95e	equ	4000h			;*
data_96e	equ	6CFEh			;*
data_97e	equ	6D17h			;*
data_98e	equ	7516h			;*
data_99e	equ	76CEh			;*
data_100e	equ	77C7h			;*
data_101e	equ	77D7h			;*
data_102e	equ	79B4h			;*
data_103e	equ	79B6h			;*
data_104e	equ	79CAh			;*
data_105e	equ	8244h			;*
data_106e	equ	83D7h			;*
data_107e	equ	8581h			;*
data_108e	equ	85C2h			;*
data_109e	equ	85EEh			;*
data_110e	equ	8790h			;*
data_111e	equ	883Fh			;*
data_112e	equ	8C79h			;*
data_113e	equ	8C8Dh			;*
data_114e	equ	8F33h			;*
data_115e	equ	90CAh			;*
data_116e	equ	9185h			;*
data_117e	equ	920Ah			;*
data_118e	equ	9234h			;*
data_119e	equ	972Fh			;*
data_120e	equ	9788h			;*
data_121e	equ	98B8h			;*
data_122e	equ	98BEh			;*
data_123e	equ	9985h			;*
data_124e	equ	9C1Eh			;*
data_125e	equ	9EEDh			;*
data_126e	equ	9EEEh			;*
data_127e	equ	9EEFh			;*
data_128e	equ	9EF0h			;*
data_129e	equ	9EF1h			;*
data_130e	equ	9EF2h			;*
data_131e	equ	9EF4h			;*
data_132e	equ	9EF5h			;*
data_133e	equ	9EF6h			;*
data_134e	equ	9EF7h			;*
data_135e	equ	9EF8h			;*
data_136e	equ	9EF9h			;*
data_137e	equ	9EFAh			;*
data_138e	equ	9EFEh			;*
data_139e	equ	9EFFh			;*
data_140e	equ	9F00h			;*
data_141e	equ	9F01h			;*
data_142e	equ	9F02h			;*
data_143e	equ	9F03h			;*
data_144e	equ	9F05h			;*
data_145e	equ	9F07h			;*
data_146e	equ	9F08h			;*
data_147e	equ	9F09h			;*
data_148e	equ	9F0Ah			;*
data_149e	equ	9F0Bh			;*
data_150e	equ	9F0Ch			;*
data_151e	equ	9F0Dh			;*
data_152e	equ	9F0Eh			;*
data_153e	equ	9F10h			;*
data_154e	equ	9F12h			;*
data_155e	equ	9F14h			;*
data_156e	equ	9F15h			;*
data_157e	equ	9F16h			;*
data_158e	equ	9F17h			;*
data_159e	equ	9F18h			;*
data_160e	equ	9F19h			;*
data_161e	equ	9F1Ah			;*
data_162e	equ	9F1Ch			;*
data_163e	equ	9F1Dh			;*
data_164e	equ	9F1Eh			;*
data_165e	equ	9F1Fh			;*
data_166e	equ	9F20h			;*
data_167e	equ	9F21h			;*
data_168e	equ	9F22h			;*
data_169e	equ	9F23h			;*
data_170e	equ	9F24h			;*
data_171e	equ	9F25h			;*
data_172e	equ	9F26h			;*
data_173e	equ	9F27h			;*
data_174e	equ	9F28h			;*
data_175e	equ	9F29h			;*
data_176e	equ	9F2Ah			;*
data_177e	equ	9F2Bh			;*
data_178e	equ	9F2Ch			;*
data_179e	equ	9F2Dh			;*
data_180e	equ	9F85h			;*
data_181e	equ	0A000h			;*
data_182e	equ	0A002h			;*
data_183e	equ	0A006h			;*
data_184e	equ	0A008h			;*
data_185e	equ	0A010h			;*
data_186e	equ	0C000h			;*
data_187e	equ	0C002h			;*
data_188e	equ	0C004h			;*
data_189e	equ	0C006h			;*
data_190e	equ	0C008h			;*
data_191e	equ	0C00Ah			;*
data_192e	equ	0C00Ch			;*
data_193e	equ	0C00Eh			;*
data_194e	equ	0C010h			;*
data_195e	equ	0C012h			;*
data_196e	equ	0C013h			;*
data_197e	equ	0C015h			;*
data_198e	equ	0C016h			;*
data_199e	equ	0C017h			;*
data_200e	equ	0C019h			;*
data_201e	equ	0C01Bh			;*
data_202e	equ	0E000h			;*
data_203e	equ	0E001h			;*
data_204e	equ	0E8FEh			;*
data_205e	equ	0E8FFh			;*
data_206e	equ	0E900h			;*
data_207e	equ	0E921h			;*
data_208e	equ	0E939h			;*
data_209e	equ	0EB60h			;*
data_210e	equ	0EB80h			;*
data_211e	equ	0ED20h			;*
data_212e	equ	0EDA0h			;*
data_213e	equ	0FF08h			;*
data_214e	equ	0FF18h			;*
data_215e	equ	0FF1Ah			;*
data_216e	equ	0FF1Dh			;*
data_217e	equ	0FF1Eh			;*
data_218e	equ	0FF24h			;*
data_219e	equ	0FF2Ch			;*
data_220e	equ	0FF2Eh			;*
data_221e	equ	0FF2Fh			;*
data_222e	equ	0FF30h			;*
data_223e	equ	0FF31h			;*
data_224e	equ	0FF33h			;*
data_225e	equ	0FF34h			;*
data_226e	equ	0FF35h			;*
data_227e	equ	0FF36h			;*
data_228e	equ	0FF37h			;*
data_229e	equ	0FF38h			;*
data_230e	equ	0FF39h			;*
data_231e	equ	0FF3Ah			;*
data_232e	equ	0FF3Ch			;*
data_233e	equ	0FF3Dh			;*
data_234e	equ	0FF3Eh			;*
data_235e	equ	0FF3Fh			;*
data_236e	equ	0FF40h			;*
data_237e	equ	0FF41h			;*
data_238e	equ	0FF42h			;*
data_239e	equ	0FF43h			;*
data_240e	equ	0FF44h			;*
data_241e	equ	0FF45h			;*
data_242e	equ	0FF46h			;*
data_243e	equ	0FF47h			;*
data_244e	equ	0FF4Ah			;*
data_245e	equ	0FF4Bh			;*
data_246e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_00		proc	far

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
		mov	byte ptr ds:data_166e,0
		mov	byte ptr ds:data_167e,0
		mov	byte ptr ds:data_168e,0
		mov	ax,0FFFFh
		mov	ds:data_210e,al
		mov	ds:data_212e,al
		mov	word ptr ds:[0EB15h],ax
		mov	byte ptr ds:data_220e,0
		mov	byte ptr ds:data_221e,0
		mov	byte ptr ds:data_222e,0
		mov	byte ptr ds:data_141e,0
		test	byte ptr ds:data_225e,0FFh
		jnz	loc_2			; Jump if not zero
		jmp	loc_7
loc_2:
		call	game_func_29
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:data_142e,0FFh
		mov	al,byte ptr ds:[0C8h]
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9E53h
		mov	si,ax
		mov	es,cs:data_219e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	si,9BF1h
		mov	es,cs:data_219e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		call	word ptr cs:data_85
		mov	byte ptr ds:data_228e,0
		call	word ptr cs:data_82
		call	word ptr cs:data_81
		call	game_multiply_2
		mov	byte ptr ds:data_142e,0
		push	ds
		mov	ds,cs:data_219e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	cx,6

locloop_3:
		push	cx
		mov	byte ptr ds:data_215e,0
loc_4:
		cmp	byte ptr ds:data_215e,41h	; 'A'
		jb	loc_4			; Jump if below
		mov	bx,0C28h
		mov	cx,3828h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		mov	byte ptr ds:data_215e,0
loc_5:
		cmp	byte ptr ds:data_215e,41h	; 'A'
		jb	loc_5			; Jump if below
		call	word ptr cs:data_85
		pop	cx
		loop	locloop_3		; Loop if cx > 0

		mov	si,ds:data_186e
		add	si,5
		mov	al,[si]
		mov	[si-1],al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9D8Dh
		mov	si,ax

zr2_00		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation		proc	near
		mov	es,cs:data_219e
		mov	di,data_95e
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_219e
		mov	si,4000h
		mov	bp,0A000h
		mov	cx,100h
		call	word ptr cs:data_88
		pop	ds
loc_6:
		mov	si,ds:data_182e
		add	si,8
		lodsb				; String [si] to al
		mov	ds:data_141e,al
		mov	si,[si]
		call	word ptr cs:[2010h]
		mov	si,ds:data_182e
		add	si,3
		mov	bx,[si]
		push	bx
		call	word ptr cs:[200Ah]
		pop	bx
		call	word ptr cs:[200Ch]
		jmp	short loc_8
loc_7:
		call	word ptr cs:[2012h]
		call	game_get_value_2
		mov	si,ds:data_193e
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
		mov	byte ptr ds:data_172e,0FFh
		mov	word ptr ds:[80h],29h
		mov	byte ptr ds:[83h],5
		call	vga_operation0
		call	fill_buffer
loc_10:
		call	game_check_state_3
		test	byte ptr ds:[0E6h],0FFh
		jnz	loc_10			; Jump if not zero
		push	ds
		mov	ds,cs:data_219e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	byte ptr ds:data_142e,0
		mov	ah,1Eh
		mov	al,1
		call	word ptr cs:[10Ch]
		mov	byte ptr ds:data_225e,0FFh
		mov	byte ptr ds:data_173e,0FFh
		mov	si,ds:data_186e
		lodsb				; String [si] to al
		call	copy_buffer
		call	vga_operation_2
		push	ds
		mov	ds,cs:data_219e
		mov	si,8030h
		mov	cx,66h
		call	word ptr cs:[2044h]
		call	word ptr cs:data_89
		pop	ds
		push	ds
		call	word ptr cs:data_84
		mov	cx,18h
		call	word ptr cs:[2044h]
		pop	ds
		mov	word ptr ds:data_161e,18h
		mov	byte ptr ds:data_162e,0Dh
		mov	byte ptr ds:[83h],0Ch
		mov	byte ptr ds:data_140e,0Ch
		call	game_func_70
		call	game_func_29
		jmp	loc_6
loc_11:
		call	vga_operation0
		test	byte ptr ds:data_173e,0FFh
		jz	loc_12			; Jump if zero
		call	fill_buffer
		call	game_check_state_3
		mov	byte ptr ds:data_172e,0
		jmp	short loc_14
loc_12:
		test	byte ptr ds:data_225e,0FFh
		jz	loc_13			; Jump if zero
		call	word ptr cs:data_80
loc_13:
		call	fill_buffer
		call	clear_buffer
loc_14:
		test	byte ptr ds:[49h],0FFh
		jz	loc_15			; Jump if zero
		jmp	loc_700
loc_15:
		test	byte ptr ds:data_142e,0FFh
		jz	loc_16			; Jump if zero
		mov	byte ptr ds:data_142e,0
		push	ds
		mov	ds,cs:data_219e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
loc_16:
		xor	al,al			; Zero register
		mov	ds:data_216e,al
		mov	ds:data_217e,al
		mov	byte ptr ds:data_215e,0
		mov	byte ptr ds:data_173e,0
loc_17:
		test	byte ptr ds:data_230e,0FFh
		jnz	loc_20			; Jump if not zero
		call	game_func_43
		call	game_func_9
		call	game_check_state_3
;*		call	game_func_107			;*
		call	sub_27B4
		db	00Ch			; was: db 0E8h, 001h, 025h
		call	game_func_7
		call	game_func_8
		inc	byte ptr ds:data_148e
		cmp	byte ptr ds:data_148e,2
		jne	loc_18			; Jump if not equal
		mov	byte ptr ds:data_229e,0
loc_18:
		mov	dx,629Ch
		push	dx
		int	61h			; ??INT Non-standard interrupt
		test	al,2
		jz	loc_19			; Jump if zero
		and	byte ptr ds:[0C2h],0FDh
loc_19:
		call	game_func_20
		call	game_check_state
		retn
loc_20:
		mov	byte ptr ds:data_229e,0
		mov	byte ptr ds:data_233e,0
		mov	byte ptr ds:data_238e,0
		mov	byte ptr ds:data_232e,0
		call	word ptr cs:data_74
		mov	byte ptr ds:data_239e,0
		call	game_check_state_3
		call	game_func_8
		call	game_check_state
		cmp	byte ptr ds:data_230e,0FFh
		jne	loc_21			; Jump if not equal
		call	vga_operation8
		inc	si
		call	game_get_value
		jc	loc_20			; Jump if carry Set
		add	si,24h
		call	vga_operation5
		call	game_get_value
		jc	loc_20			; Jump if carry Set
loc_21:
		and	byte ptr ds:[0C2h],0FDh
		mov	byte ptr ds:data_230e,0
		mov	byte ptr ds:data_216e,0
		mov	byte ptr ds:data_217e,0
		mov	byte ptr ds:data_166e,0
		mov	byte ptr ds:data_167e,0
		mov	byte ptr ds:[0E7h],7Fh
		jmp	loc_17
vga_operation		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_check_state		proc	near
		mov	byte ptr ds:data_168e,0
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
		test	byte ptr ds:data_230e,0FFh
		jnz	loc_28			; Jump if not zero
		test	byte ptr ds:data_233e,0FFh
		jz	loc_28			; Jump if zero
		test	byte ptr ds:data_149e,0FFh
		jnz	loc_25			; Jump if not zero
		jmp	loc_69
loc_25:
		mov	byte ptr ds:data_149e,0
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
		cmp	al,ds:data_170e
		mov	ds:data_170e,al
		jz	loc_29			; Jump if zero
		call	game_func_10
loc_29:
		pop	ax
		mov	al,ah
		push	ax
		cmp	al,2
		jne	loc_30			; Jump if not equal
		call	game_func_22
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
		call	game_func_10
		mov	al,ds:data_230e
		or	al,ds:data_229e
		jz	loc_33			; Jump if zero
		retn
loc_33:
		mov	byte ptr ds:[0E7h],80h
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_7:
		test	byte ptr ds:data_229e,0FFh
		jz	loc_34			; Jump if zero
		retn
loc_34:
		test	byte ptr ds:data_233e,0FFh
		jz	loc_35			; Jump if zero
		retn
loc_35:
		call	vga_operation8
		mov	al,[si]
		call	game_check_state_2
		jnz	loc_36			; Jump if not zero
		retn
loc_36:
		inc	si
		inc	si
		mov	al,[si]
		call	game_check_state_2
		jnz	loc_37			; Jump if not zero
		retn
loc_37:
		add	si,24h
		call	vga_operation5
		mov	al,[si]
		call	game_check_state_2
		jz	loc_38			; Jump if zero
		jmp	loc_95
loc_38:
		jmp	loc_124

;���� External Entry into Subroutine ��������������������������������������

game_func_8:
		test	byte ptr ds:data_155e,0FFh
		jnz	loc_39			; Jump if not zero
		retn
loc_39:
		test	byte ptr ds:data_141e,0FFh
		jnz	loc_41			; Jump if not zero
		mov	si,data_152e
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
		test	byte ptr ds:data_230e,0FFh
		jz	loc_42			; Jump if zero
		and	byte ptr ds:[0C2h],0FCh
		or	byte ptr ds:[0C2h],1
		mov	byte ptr ds:data_233e,7Fh
		mov	byte ptr ds:data_216e,0
loc_42:
		call	game_func_15
		call	game_func_15
		jmp	short loc_45
loc_43:
		test	byte ptr ds:data_230e,0FFh
		jz	loc_44			; Jump if zero
		and	byte ptr ds:[0C2h],0FCh
		mov	byte ptr ds:data_233e,7Fh
		mov	byte ptr ds:data_216e,0
loc_44:
		call	game_process_loop
		call	game_process_loop
		jmp	short loc_45
loc_45:
		test	byte ptr ds:data_230e,0FFh
		jz	loc_46			; Jump if zero
		mov	byte ptr ds:data_230e,80h
		mov	byte ptr ds:data_233e,0
loc_46:
		test	byte ptr ds:data_156e,0FFh
		jz	loc_47			; Jump if zero
		retn
loc_47:
		test	byte ptr ds:data_233e,80h
		jz	loc_48			; Jump if zero
		retn
loc_48:
		call	game_func_24
		jnc	loc_49			; Jump if carry=0
		retn
loc_49:
		test	byte ptr ds:data_147e,0FFh
		jnz	loc_50			; Jump if not zero
		jmp	loc_169
loc_50:
		dec	byte ptr ds:data_147e
		inc	byte ptr ds:[84h]
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_9:
		call	vga_operation7
		jz	loc_51			; Jump if zero
		retn
loc_51:
		test	byte ptr ds:data_233e,0FFh
		jz	loc_52			; Jump if zero
		retn
loc_52:
		test	byte ptr ds:data_166e,0FFh
		jnz	loc_53			; Jump if not zero
		retn
loc_53:
		dec	byte ptr ds:data_166e
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	al,[si]
		cmp	al,40h			; '@'
		jb	loc_54			; Jump if below
		cmp	al,49h			; 'I'
		jae	loc_54			; Jump if above or =
		mov	byte ptr ds:data_166e,0
		retn
loc_54:
		mov	al,ds:data_168e
		test	byte ptr ds:data_169e,1
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

;���� External Entry into Subroutine ��������������������������������������

game_func_10:
		call	vga_operation7
		jz	loc_58			; Jump if zero
		retn
loc_58:
		test	byte ptr ds:data_166e,0FFh
		jz	loc_59			; Jump if zero
		retn
loc_59:
		test	byte ptr ds:data_230e,0FFh
		jz	loc_60			; Jump if zero
		retn
loc_60:
		mov	al,ds:data_167e
		shr	al,1			; Shift w/zeros fill
		or	al,al			; Zero ?
		jnz	loc_61			; Jump if not zero
		retn
loc_61:
		cmp	al,0Ah
		jb	loc_62			; Jump if below
		mov	al,0Ah
loc_62:
		mov	ds:data_166e,al
		mov	byte ptr ds:data_167e,0
		retn
loc_63:
		mov	byte ptr ds:data_159e,0
		call	game_func_69
		call	game_func_80
		call	game_func_12

;���� External Entry into Subroutine ��������������������������������������

game_func_11:
		inc	byte ptr ds:data_166e
		cmp	byte ptr ds:data_166e,0Ah
		jb	loc_64			; Jump if below
		mov	byte ptr ds:data_166e,0Ah
loc_64:
		test	byte ptr ds:data_230e,0FFh
		jz	loc_65			; Jump if zero
		retn
loc_65:
		mov	byte ptr ds:data_229e,0
		mov	al,ds:data_147e
		cmp	al,ds:data_151e
		jae	loc_69			; Jump if above or =
		call	vga_operation8
		sub	si,23h
		call	vga_operation6
		mov	al,[si]
		call	game_check_state_2
		jnz	loc_67			; Jump if not zero
		mov	byte ptr ds:[0E7h],0
		and	byte ptr ds:[0C2h],0FDh
		mov	byte ptr ds:data_233e,0FFh
		mov	al,ds:data_151e
		shr	al,1			; Shift w/zeros fill
		mov	ds:data_150e,al
		inc	byte ptr ds:data_147e
		cmp	byte ptr ds:[84h],7
		jae	loc_66			; Jump if above or =
		jmp	loc_77
loc_66:
		dec	byte ptr ds:[84h]
		retn
loc_67:
		test	byte ptr ds:data_147e,0FFh
		jnz	loc_69			; Jump if not zero
		test	byte ptr ds:data_230e,0FFh
		jz	loc_68			; Jump if zero
		retn
loc_68:
		mov	byte ptr ds:[0E7h],80h
		retn
loc_69:
		mov	byte ptr ds:data_238e,0
		mov	byte ptr ds:data_233e,7Fh
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_12:
		call	vga_operation8
		inc	si
		call	game_get_value
		jc	loc_73			; Jump if carry Set
		dec	si
		call	game_get_value
		jnc	loc_70			; Jump if carry=0
		test	byte ptr ds:[0C2h],1
		jnz	loc_79			; Jump if not zero
		retn
loc_70:
		inc	si
		inc	si
		call	game_get_value
		jc	loc_71			; Jump if carry Set
		retn
loc_71:
		test	byte ptr ds:[0C2h],1
		jnz	loc_ret_72		; Jump if not zero
		jmp	loc_107

loc_ret_72:
		retn
loc_73:
		mov	byte ptr ds:data_230e,0FFh
		mov	byte ptr ds:data_229e,0
loc_74:
		call	vga_operation8
		sub	si,23h
		call	vga_operation6
		dec	byte ptr ds:[0E7h]
		call	game_get_value
		jc	loc_75			; Jump if carry Set
		or	byte ptr ds:[0E7h],1
		retn
loc_75:
		call	game_func_13
		call	game_check_state_3
		test	byte ptr ds:[0E7h],1
		jz	loc_76			; Jump if zero
		retn
loc_76:
		jmp	short loc_74

;���� External Entry into Subroutine ��������������������������������������

game_func_13:
loc_77:
		dec	byte ptr ds:[82h]
		mov	si,ds:data_223e
		sub	si,24h
		call	vga_operation6
		mov	ds:data_223e,si
		retn
loc_78:
		mov	byte ptr ds:data_149e,0FFh
		call	game_func_11
		jmp	short loc_79
loc_79:
		mov	byte ptr ds:data_159e,0
		test	byte ptr ds:[0C2h],1
		jnz	loc_80			; Jump if not zero
		jmp	loc_112
loc_80:
		test	byte ptr ds:data_229e,0FFh
		jz	loc_81			; Jump if zero
		retn
loc_81:
		cmp	byte ptr ds:data_238e,1
		jne	loc_82			; Jump if not equal
		jmp	loc_114
loc_82:
		call	game_func_15
		jnc	loc_83			; Jump if carry=0
		jmp	loc_114
loc_83:
		mov	byte ptr ds:data_168e,2
		test	byte ptr ds:data_230e,0FFh
		jz	loc_84			; Jump if zero
		retn
loc_84:
		call	vga_operation7
		jnz	loc_85			; Jump if not zero
		test	byte ptr ds:data_166e,0FFh
		jnz	loc_85			; Jump if not zero
		mov	byte ptr ds:data_169e,0
		inc	byte ptr ds:data_167e
loc_85:
		or	byte ptr ds:[0C2h],2
		test	byte ptr ds:data_233e,0FFh
		jz	loc_86			; Jump if zero
		retn
loc_86:
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],7Fh
		mov	byte ptr ds:data_160e,0
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_15:
loc_87:
		call	vga_operation8
		mov	di,si
		sub	si,24h
		call	vga_operation6
		dec	si
		mov	cx,4

locloop_88:
		call	vga_operation9
		add	al,al
		jnc	loc_89			; Jump if carry=0
		retn
loc_89:
		add	si,24h
		call	vga_operation5
		loop	locloop_88		; Loop if cx > 0

		xchg	di,si
		test	byte ptr ds:data_229e,0FFh
		jnz	loc_91			; Jump if not zero
		mov	al,[si]
		call	game_check_state_2
		stc				; Set carry flag
		jz	loc_90			; Jump if zero
		retn
loc_90:
		call	game_func_16
		jnc	loc_91			; Jump if carry=0
		retn
loc_91:
		mov	cx,2

locloop_92:
		add	si,24h
		call	vga_operation5
		mov	al,[si]
		call	game_func_42
		stc				; Set carry flag
		jz	loc_93			; Jump if zero
		retn
loc_93:
		push	cx
		call	game_func_16
		pop	cx
		jnc	loc_94			; Jump if carry=0
		retn
loc_94:
		loop	locloop_92		; Loop if cx > 0

loc_95:
		dec	word ptr ds:[80h]
;*		cmp	word ptr ds:[80h],0FFFFh
		db	 83h, 3Eh, 80h, 00h,0FFh	;  Fixup - byte match
		jnz	loc_96			; Jump if not zero
		mov	ax,ds:data_187e
		dec	ax
		mov	word ptr ds:[80h],ax
		mov	si,ds:data_200e
		mov	ds:data_143e,si
loc_96:
		push	cs
		pop	es
		std				; Set direction flag
		mov	si,data_204e
		mov	di,data_205e
		mov	cx,8FFh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		cld				; Clear direction
		mov	si,ds:data_143e
		dec	si
		mov	di,0E8DCh
		xor	dl,dl			; Zero register
loc_97:
		call	vga_operation2
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
		mov	ds:data_143e,si
		mov	si,ds:data_200e
		dec	si
		mov	ax,word ptr ds:[80h]
		add	ax,24h
		cmp	ax,ds:data_187e
		je	loc_100			; Jump if equal
		mov	si,ds:data_144e
		xor	dh,dh			; Zero register
loc_99:
		call	vga_operation2
		dec	si
		add	dh,bh
		cmp	dh,40h			; '@'
		jb	loc_99			; Jump if below
loc_100:
		mov	ds:data_144e,si
		call	game_func_100
		mov	bx,word ptr ds:[80h]
		mov	byte ptr ds:data_244e,0
		mov	si,ds:data_194e
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
		call	vga_operation4
		mov	al,ds:data_244e
		or	al,80h
		mov	[di],al
loc_103:
		inc	byte ptr ds:data_244e
		add	si,10h
		jmp	short loc_101

;���� External Entry into Subroutine ��������������������������������������

game_func_16:
		cmp	byte ptr ds:data_195e,7
		clc				; Clear carry flag
		jnz	loc_104			; Jump if not zero
		retn
loc_104:
		mov	al,[si]
		push	si
		call	game_func_63
		pop	si
		cmp	cl,2
		stc				; Set carry flag
		jnz	loc_105			; Jump if not zero
		retn
loc_105:
		clc				; Clear carry flag
		retn
loc_106:
		mov	byte ptr ds:data_149e,0FFh
		call	game_func_11
		jmp	short loc_107
loc_107:
		mov	byte ptr ds:data_159e,0
		test	byte ptr ds:[0C2h],1
		jnz	loc_112			; Jump if not zero
		test	byte ptr ds:data_229e,0FFh
		jz	loc_108			; Jump if zero
		retn
loc_108:
		cmp	byte ptr ds:data_238e,2
		je	loc_114			; Jump if equal
		call	game_process_loop
		jc	loc_114			; Jump if carry Set
		mov	byte ptr ds:data_168e,1
		test	byte ptr ds:data_230e,0FFh
		jz	loc_109			; Jump if zero
		retn
loc_109:
		call	vga_operation7
		jnz	loc_110			; Jump if not zero
		test	byte ptr ds:data_166e,0FFh
		jnz	loc_110			; Jump if not zero
		mov	byte ptr ds:data_169e,1
		inc	byte ptr ds:data_167e
loc_110:
		or	byte ptr ds:[0C2h],2
		test	byte ptr ds:data_233e,0FFh
		jz	loc_111			; Jump if zero
		retn
loc_111:
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],7Fh
		mov	byte ptr ds:data_160e,0
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_17:
loc_112:
		xor	byte ptr ds:[0C2h],1
		test	byte ptr ds:data_230e,0FFh
		jz	loc_113			; Jump if zero
		retn
loc_113:
		mov	byte ptr ds:[0E7h],80h
		retn
loc_114:
		and	byte ptr ds:[0C2h],0FDh
		mov	al,ds:data_230e
		or	al,ds:data_233e
		jz	loc_115			; Jump if zero
		retn
loc_115:
		mov	byte ptr ds:[0E7h],80h
		retn
game_check_state		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_process_loop		proc	near
loc_116:
		call	vga_operation8
		inc	si
		inc	si
		mov	di,si
		sub	si,24h
		call	vga_operation6
		mov	cx,4

locloop_117:
		call	vga_operation9
		add	al,al
		jnc	loc_118			; Jump if carry=0
		retn
loc_118:
		add	si,24h
		call	vga_operation5
		loop	locloop_117		; Loop if cx > 0

		xchg	di,si
		test	byte ptr ds:data_229e,0FFh
		jnz	loc_120			; Jump if not zero
		mov	al,[si]
		call	game_check_state_2
		stc				; Set carry flag
		jz	loc_119			; Jump if zero
		retn
loc_119:
		call	game_func_19
		jnc	loc_120			; Jump if carry=0
		retn
loc_120:
		mov	cx,2

locloop_121:
		add	si,24h
		call	vga_operation5
		mov	al,[si]
		call	game_func_42
		stc				; Set carry flag
		jz	loc_122			; Jump if zero
		retn
loc_122:
		push	cx
		call	game_func_19
		pop	cx
		jnc	loc_123			; Jump if carry=0
		retn
loc_123:
		loop	locloop_121		; Loop if cx > 0

loc_124:
		inc	word ptr ds:[80h]
		mov	ax,word ptr ds:[80h]
		add	ax,23h
		cmp	ax,ds:data_187e
		jne	loc_125			; Jump if not equal
		mov	word ptr ds:data_144e,0C01Ah
loc_125:
		push	cs
		pop	es
		mov	si,data_203e
		mov	di,data_202e
		mov	cx,8FFh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	si,ds:data_144e
		inc	si
		mov	di,0E023h
		call	vga_operation3
		dec	si
		mov	ds:data_144e,si
		mov	ax,word ptr ds:[80h]
		cmp	ax,ds:data_187e
		jne	loc_126			; Jump if not equal
		mov	word ptr ds:[80h],0
		mov	si,data_201e
		jmp	short loc_128
loc_126:
		mov	si,ds:data_143e
		xor	dh,dh			; Zero register
loc_127:
		call	vga_operation1
		inc	si
		add	dh,bh
		cmp	dh,40h			; '@'
		jb	loc_127			; Jump if below
loc_128:
		mov	ds:data_143e,si
		call	game_func_99
		mov	byte ptr ds:data_244e,0
		mov	bx,word ptr ds:[80h]
		add	bx,23h
		mov	ax,bx
		sub	ax,ds:data_187e
		jc	loc_129			; Jump if carry Set
		mov	bx,ax
loc_129:
		mov	si,ds:data_194e
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
		call	vga_operation4
		mov	al,ds:data_244e
		or	al,80h
		mov	[di],al
loc_132:
		inc	byte ptr ds:data_244e
		add	si,10h
		jmp	short loc_130
game_process_loop		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_19		proc	near
		cmp	byte ptr ds:data_195e,7
		clc				; Clear carry flag
		jnz	loc_133			; Jump if not zero
		retn
loc_133:
		mov	al,[si]
		push	si
		call	game_func_63
		pop	si
		dec	cl
		stc				; Set carry flag
		jnz	loc_134			; Jump if not zero
		retn
loc_134:
		clc				; Clear carry flag
		retn
game_func_19		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_20		proc	near
		test	byte ptr ds:data_156e,0FFh
		jz	loc_135			; Jump if zero
		retn
loc_135:
		test	byte ptr ds:data_233e,80h
		jz	loc_136			; Jump if zero
		retn
loc_136:
		call	game_func_84
		call	game_func_21
		call	game_func_24
		jnc	loc_137			; Jump if carry=0
		jmp	loc_170
loc_137:
		inc	byte ptr ds:data_146e
		test	byte ptr ds:data_147e,0FFh
		jz	loc_138			; Jump if zero
		pushf				; Push flags
		dec	byte ptr ds:data_147e
		inc	byte ptr ds:[84h]
		popf				; Pop flags
loc_138:
		pop	ax
		jnz	loc_139			; Jump if not zero
		call	game_func_23
loc_139:
		test	byte ptr ds:[0C2h],2
		jnz	loc_140			; Jump if not zero
		call	vga_operation8
		add	si,49h
		call	vga_operation5
		call	game_get_value
		jnc	loc_140			; Jump if carry=0
		mov	byte ptr ds:data_230e,0FFh
		retn
loc_140:
		mov	byte ptr ds:[0E7h],80h
		mov	al,ds:data_233e
		mov	byte ptr ds:data_233e,7Fh
		test	byte ptr ds:data_238e,0FFh
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
		call	game_func_17
loc_149:
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	al,[si]
		call	game_check_state_2
		jz	loc_150			; Jump if zero
		retn
loc_150:
		inc	si
		mov	al,[si]
		call	game_check_state_2
		jnz	loc_151			; Jump if not zero
		retn
loc_151:
		jmp	loc_116
loc_152:
		test	byte ptr ds:[0C2h],1
		jz	loc_145			; Jump if zero
		and	byte ptr ds:[0C2h],0FDh
		call	game_func_17
loc_153:
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	al,[si]
		call	game_check_state_2
		jz	loc_154			; Jump if zero
		retn
loc_154:
		dec	si
		mov	al,[si]
		call	game_check_state_2
		jnz	loc_155			; Jump if not zero
		retn
loc_155:
		jmp	loc_87

;���� External Entry into Subroutine ��������������������������������������

game_func_21:
		mov	byte ptr ds:data_238e,0
		call	vga_operation8
		add	si,49h
		call	vga_operation5
		call	game_scan_loop
		jz	loc_156			; Jump if zero
		retn
loc_156:
		and	byte ptr ds:[0C2h],0FDh
		mov	ds:data_238e,dl
		test	byte ptr ds:data_150e,0FFh
		jnz	loc_161			; Jump if not zero
		mov	al,ds:data_157e
		inc	byte ptr ds:data_157e
		and	al,3
		jz	loc_157			; Jump if zero
		retn
loc_157:
		int	61h			; ??INT Non-standard interrupt
		cmp	byte ptr ds:data_238e,1
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
		dec	byte ptr ds:data_150e
		cmp	byte ptr ds:data_238e,1
		jne	loc_163			; Jump if not equal
		jmp	loc_116
loc_163:
		jmp	loc_87

;���� External Entry into Subroutine ��������������������������������������

game_func_22:
		mov	byte ptr ds:data_159e,0
		test	byte ptr ds:data_238e,0FFh
		jz	loc_164			; Jump if zero
		retn
loc_164:
		call	game_func_78
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		call	game_get_value
		jc	loc_166			; Jump if carry Set
		test	byte ptr ds:data_230e,0FFh
		jz	loc_165			; Jump if zero
		mov	byte ptr ds:data_230e,80h
		mov	byte ptr ds:data_233e,80h
		retn
loc_165:
		mov	byte ptr ds:data_148e,0
		mov	byte ptr ds:data_229e,0FFh
		retn
loc_166:
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		inc	byte ptr ds:[0E7h]
		mov	al,[si]
		call	game_check_state_2
		jz	loc_167			; Jump if zero
		or	byte ptr ds:[0E7h],1
		retn
loc_167:
		call	game_func_23
		call	game_check_state_3
		test	byte ptr ds:[0E7h],1
		jz	loc_168			; Jump if zero
		retn
loc_168:
		jmp	short loc_166

;���� External Entry into Subroutine ��������������������������������������

game_func_23:
loc_169:
		inc	byte ptr ds:[82h]
		mov	si,ds:data_223e
		add	si,24h
		call	vga_operation5
		mov	ds:data_223e,si
		retn
loc_170:
		mov	al,ds:data_233e
		xor	al,7Fh
		jz	loc_171			; Jump if zero
		retn
loc_171:
		pop	ax
		mov	dl,ds:data_146e
		mov	byte ptr ds:data_233e,0
		mov	byte ptr ds:data_148e,0
		mov	byte ptr ds:data_146e,0
		mov	byte ptr ds:[0E7h],80h
		test	byte ptr ds:data_238e,0FFh
		jz	loc_172			; Jump if zero
		retn
loc_172:
		cmp	dl,2
		jae	loc_173			; Jump if above or =
		retn
loc_173:
		mov	byte ptr ds:data_229e,0FFh
		retn
game_func_20		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_24		proc	near
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	di,si
		call	vga_operation9
		add	al,al
		jnc	loc_174			; Jump if carry=0
		retn
loc_174:
		dec	si
		call	vga_operation9
		add	al,al
		jnc	loc_175			; Jump if carry=0
		retn
loc_175:
		mov	si,di
		mov	al,[si]
		call	game_func_42
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
		call	game_func_42
		clc				; Clear carry flag
		jnz	loc_178			; Jump if not zero
		retn
loc_178:
		inc	si
		inc	si
		mov	al,[si]
		call	game_func_42
		stc				; Set carry flag
		jz	loc_179			; Jump if zero
		retn
loc_179:
		clc				; Clear carry flag
		retn
game_func_24		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_get_value		proc	near
		mov	al,[si]
		dec	al
		cmp	al,2
		retn
game_get_value		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_scan_loop		proc	near
		mov	es,cs:data_219e
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

loc_185:
		or	dl,dl			; Zero ?
		retn
game_scan_loop		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_27		proc	near
		mov	si,ds:data_192e
loc_186:
		mov	di,[si]
;*		cmp	di,0FFFFh
		db	 83h,0FFh,0FFh		;  Fixup - byte match
		jnz	loc_187			; Jump if not zero
		retn
loc_187:
		add	si,3
		mov	al,[si-1]
		and	al,[di]
		jnz	loc_189			; Jump if not zero
loc_188:
		mov	di,[si]
;*		cmp	di,0FFFFh
		db	 83h,0FFh,0FFh		;  Fixup - byte match
		jz	loc_190			; Jump if zero
		add	si,4
		jmp	short loc_188
loc_189:
		mov	di,[si]
;*		cmp	di,0FFFFh
		db	 83h,0FFh,0FFh		;  Fixup - byte match
		jz	loc_190			; Jump if zero
		mov	ax,[si+2]
		mov	[di],ax
		add	si,4
		jmp	short loc_189
loc_190:
		inc	si
		inc	si
		jmp	short loc_186
game_func_27		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_get_value_2		proc	near
		mov	si,6C44h
		call	word ptr cs:[200Eh]
		mov	si,6C4Ch
		call	word ptr cs:[200Eh]
		retn
game_get_value_2		endp

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

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_29		proc	near
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
game_func_29		endp

			                        ;* No entry point to code
		or	ax,2AFh
		add	ax,4E45h
		inc	bp
		dec	bp
		pop	cx

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation0		proc	near
		mov	si,data_201e
		mov	cx,word ptr ds:[80h]
		or	cx,cx			; Zero ?
		jz	loc_193			; Jump if zero

locloop_191:
		xor	dh,dh			; Zero register
loc_192:
		call	vga_operation1
		inc	si
		add	dh,bh
		cmp	dh,40h			; '@'
		jb	loc_192			; Jump if below
		loop	locloop_191		; Loop if cx > 0

loc_193:
		mov	ds:data_143e,si
		mov	di,0E000h
		mov	ax,word ptr ds:[80h]
		mov	cx,24h

locloop_194:
		push	di
		call	vga_operation3
		pop	di
		inc	di
		inc	ax
		cmp	ax,ds:data_187e
		jne	loc_195			; Jump if not equal
		mov	si,0C01Bh
		xor	ax,ax			; Zero register
loc_195:
		loop	locloop_194		; Loop if cx > 0

		or	ax,ax			; Zero ?
		jnz	loc_196			; Jump if not zero
		mov	si,ds:data_200e
loc_196:
		dec	si
		mov	ds:data_144e,si
		mov	al,byte ptr ds:[82h]
		xor	ah,ah			; Zero register
		call	vga_operation4
		mov	ds:data_223e,di
		retn
vga_operation0		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation1		proc	near
		mov	bl,[si]
		and	bl,0C0h
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_96e[bx]	;*
vga_operation1		endp

			                        ;* No entry point to code
		pop	ds
		db	 6Dh, 2Fh, 6Dh, 47h, 6Dh, 4Fh
		db	 6Dh

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation2		proc	near
		mov	bl,[si]
		and	bl,0C0h
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_97e[bx]	;*
vga_operation2		endp

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

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation3		proc	near
		xor	dl,dl			; Zero register
loc_197:
		call	vga_operation1
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
vga_operation3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation4		proc	near
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
vga_operation4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation5		proc	near
loc_199:
		cmp	si,0E900h
		jae	loc_200			; Jump if above or =
		retn
loc_200:
		sub	si,900h
		retn
vga_operation5		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation6		proc	near
		cmp	si,0E000h
		jb	loc_201			; Jump if below
		retn
loc_201:
		add	si,900h
		retn
vga_operation6		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation7		proc	near
		cmp	byte ptr ds:data_195e,4
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
vga_operation7		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation8		proc	near
		mov	al,byte ptr ds:[84h]
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		mov	si,ax
		add	si,ds:data_223e
		jmp	short loc_199
vga_operation8		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation9		proc	near
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
		add	bx,ds:data_194e
		mov	al,[bx+4]
		or	al,al			; Zero ?
		retn
vga_operation9		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_check_state_2		proc	near
		cmp	al,40h			; '@'
		jb	loc_205			; Jump if below
		cmp	al,al
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_41:
		cmp	al,49h			; 'I'
		jb	loc_205			; Jump if below
		cmp	al,al
		retn
loc_205:
		push	di
		push	cx
		mov	es,cs:data_219e
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
game_check_state_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_42		proc	near
		cmp	al,49h			; 'I'
		jb	loc_208			; Jump if below
		cmp	al,al
		retn
loc_208:
		push	di
		push	cx
		mov	es,cs:data_219e
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
game_func_42		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_43		proc	near
		test	byte ptr ds:[92h],0FFh
		jnz	loc_210			; Jump if not zero
		retn
loc_210:
		int	61h			; ??INT Non-standard interrupt
		test	ah,1
		jz	loc_212			; Jump if zero
		test	byte ptr ds:data_233e,0FFh
		jz	loc_212			; Jump if zero
		test	byte ptr ds:data_238e,0FFh
		jnz	loc_212			; Jump if not zero
		test	al,2
		jz	loc_212			; Jump if zero
		mov	byte ptr ds:data_241e,2
		mov	byte ptr ds:data_242e,2
		test	byte ptr ds:data_243e,0FFh
		jz	loc_211			; Jump if zero
		jmp	loc_223
loc_211:
		mov	byte ptr ds:data_243e,0FFh
		mov	byte ptr ds:data_246e,4
		jmp	short loc_223
loc_212:
		mov	byte ptr ds:data_243e,0
		test	byte ptr ds:data_216e,0FFh
		jnz	loc_213			; Jump if not zero
		retn
loc_213:
		test	byte ptr ds:data_239e,0FFh
		jz	loc_214			; Jump if zero
		retn
loc_214:
		test	byte ptr ds:data_232e,0FFh
		jz	loc_215			; Jump if zero
		retn
loc_215:
		test	byte ptr ds:data_225e,0FFh
		jnz	loc_219			; Jump if not zero
		call	vga_operation8
		sub	si,93h
		call	vga_operation6
		xor	dl,dl			; Zero register
		mov	cx,4

locloop_216:
		push	cx
		mov	cx,8

locloop_217:
		push	cx
		call	vga_operation9
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
		call	vga_operation5
		pop	cx
		loop	locloop_216		; Loop if cx > 0

		or	dl,dl			; Zero ?
		jnz	loc_220			; Jump if not zero
loc_219:
		int	61h			; ??INT Non-standard interrupt
		test	al,1
		jz	loc_221			; Jump if zero
loc_220:
		mov	byte ptr ds:data_241e,1
		mov	byte ptr ds:data_242e,0
		jmp	short loc_222
loc_221:
		mov	byte ptr ds:data_241e,0
		mov	byte ptr ds:data_242e,0
loc_222:
		mov	byte ptr ds:data_246e,3
loc_223:
		mov	byte ptr ds:data_216e,0
		mov	byte ptr ds:data_217e,0
		mov	byte ptr ds:data_239e,0FFh
		retn
game_func_43		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_44		proc	near
		test	byte ptr ds:data_239e,0FFh
		jnz	loc_224			; Jump if not zero
		retn
loc_224:
		test	byte ptr ds:data_225e,0FFh
		jz	loc_225			; Jump if zero
		test	byte ptr ds:data_220e,0FFh
		jz	loc_225			; Jump if zero
		retn
loc_225:
		call	vga_operation8
		mov	bx,90h
		test	byte ptr ds:data_229e,0FFh
		jz	loc_226			; Jump if zero
		mov	bx,6Ch
loc_226:
		sub	si,bx
		call	vga_operation6
		mov	bl,byte ptr ds:[0C2h]
		and	bl,1
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,bl
		mov	al,ds:data_241e
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
		mov	al,ds:data_242e
		or	al,bl
		add	al,ah
loc_228:
		and	al,0FEh
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	es,cs:data_219e
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
		call	vga_operation5
		call	vga_operation9
		jc	loc_229			; Jump if carry Set
		test	al,20h			; ' '
		jnz	loc_229			; Jump if not zero
		test	byte ptr [bx+5],20h	; ' '
		jnz	loc_229			; Jump if not zero
		or	byte ptr [bx+5],40h	; '@'
		and	byte ptr [bx+5],0E0h
		or	byte ptr [bx+5],1
		jmp	short loc_229
game_func_44		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_check_state_3		proc	near
loc_231:
		mov	al,2
		cmp	byte ptr ds:[9Eh],1
		jne	loc_232			; Jump if not equal
		mov	al,4
loc_232:
		mov	ds:data_151e,al
		call	game_process_loop_2
		test	byte ptr ds:data_233e,0FFh
		jnz	loc_234			; Jump if not zero
		mov	byte ptr ds:data_147e,0
		mov	al,ds:data_140e
		cmp	al,byte ptr ds:[84h]
		je	loc_234			; Jump if equal
		jc	loc_233			; Jump if carry Set
		call	game_func_13
		inc	byte ptr ds:[84h]
		jmp	short loc_234
loc_233:
		call	game_func_23
		dec	byte ptr ds:[84h]
loc_234:
		test	byte ptr ds:[0E6h],0FFh
		jnz	loc_235			; Jump if not zero
		test	byte ptr ds:data_225e,0FFh
		jz	loc_236			; Jump if zero
loc_235:
		mov	si,ds:data_182e
		add	si,7
		mov	al,[si]
		cmp	byte ptr ds:[83h],al
		je	loc_237			; Jump if equal
		call	game_process_loop
		dec	byte ptr ds:[83h]
		jmp	short loc_237
loc_236:
		mov	al,byte ptr ds:[83h]
		cmp	al,0Ch
		je	loc_237			; Jump if equal
		call	game_func_15
		inc	byte ptr ds:[83h]
loc_237:
		mov	al,byte ptr ds:[84h]
		add	al,byte ptr ds:[82h]
		and	al,3Fh			; '?'
		mov	ds:data_226e,al
		call	game_check_state_4
		call	game_func_85
		call	game_scan_loop_4
		call	game_scan_loop_5
		call	game_func_66
		call	game_func_111
		test	byte ptr ds:data_222e,0FFh
		jnz	loc_238			; Jump if not zero
		call	game_func_116
loc_238:
		mov	byte ptr ds:data_227e,0
		mov	byte ptr ds:data_155e,0
;*		call	game_func_55			;*
		db	0E8h,0E3h, 04h		;  Fixup - byte match
		call	word ptr cs:data_74
		call	copy_buffer_2
		call	game_scan_loop_8
		call	word ptr cs:data_75
		call	game_scan_loop_3
		cmp	byte ptr ds:data_195e,7
		jne	loc_239			; Jump if not equal
		cmp	byte ptr ds:[9Eh],5
		je	loc_239			; Jump if equal
		inc	byte ptr ds:data_171e
		test	byte ptr ds:data_171e,3Fh	; '?'
		jnz	loc_239			; Jump if not zero
		mov	byte ptr ds:data_227e,0FFh
		mov	byte ptr ds:data_246e,9
		mov	ax,0Fh
		call	game_func_60
		mov	dx,9BB9h
		call	game_func_51
loc_239:
		call	game_func_47
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_240			; Jump if zero
		mov	byte ptr ds:data_227e,0
		jmp	short loc_241

;���� External Entry into Subroutine ��������������������������������������

game_func_46:
loc_240:
		mov	byte ptr ds:data_228e,0
loc_241:
		mov	byte ptr ds:data_236e,0
		test	byte ptr ds:data_239e,0FFh
		jz	loc_242			; Jump if zero
		mov	byte ptr ds:data_236e,0FFh
		mov	al,ds:data_241e
		mov	ds:data_237e,al
		mov	al,ds:data_242e
		mov	ds:data_235e,al
		jmp	short loc_243
loc_242:
		test	byte ptr ds:data_232e,0FFh
		jz	loc_243			; Jump if zero
		mov	byte ptr ds:data_236e,0FFh
		mov	al,ds:data_177e
		mov	ds:data_235e,al
		mov	byte ptr ds:data_237e,1
loc_243:
		test	byte ptr ds:data_228e,0FFh
		jnz	loc_244			; Jump if not zero
		call	game_multiply_2
loc_244:
		call	word ptr cs:data_73
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
		mov	byte ptr ds:data_246e,13h
		call	word ptr cs:[2008h]
loc_246:
		call	word ptr cs:data_72
		test	byte ptr ds:data_221e,0FFh
		jz	loc_247			; Jump if zero
		call	word ptr cs:data_79
		mov	byte ptr ds:data_218e,0Ah
loc_247:
		mov	cl,ds:data_224e
		mov	al,2
		mul	cl			; ax = reg * al
loc_248:
		cmp	ds:data_215e,al
		jb	loc_248			; Jump if below
		call	game_scan_loop_8
		call	word ptr cs:data_74
		call	game_check_state_5
		call	game_func_102
		call	game_func_109
		call	game_func_44
		call	word ptr cs:data_75
		mov	cl,ds:data_224e
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
		call	game_func_65
loc_250:
		pop	ax
		cmp	ds:data_215e,al
		jb	loc_249			; Jump if below
		mov	byte ptr ds:data_215e,0
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_251			; Jump if zero
		retn
loc_251:
		test	byte ptr ds:[7Fh],0FFh
		jnz	loc_252			; Jump if not zero
		test	word ptr ds:[90h],0FFFFh
		jnz	loc_252			; Jump if not zero
		jmp	loc_700
loc_252:
		inc	byte ptr ds:data_159e
		cmp	byte ptr ds:data_159e,10h
		jb	loc_253			; Jump if below
		mov	byte ptr ds:data_159e,0
		mov	ax,word ptr ds:[90h]
		cmp	ax,word ptr ds:[0B2h]
		jae	loc_253			; Jump if above or =
		add	ax,2
		mov	word ptr ds:[90h],ax
		call	word ptr cs:[2008h]
loc_253:
		test	byte ptr ds:data_164e,0FFh
		jz	loc_254			; Jump if zero
		jmp	loc_267
loc_254:
		test	byte ptr ds:data_225e,0FFh
		jz	loc_255			; Jump if zero
		test	byte ptr ds:data_222e,0FFh
		jz	loc_255			; Jump if zero
		cmp	byte ptr ds:data_212e,0FFh
		jne	loc_255			; Jump if not equal
		mov	si,ds:data_182e
		add	si,5
		lodsw				; String [si] to ax
		push	si
		call	game_func_143
		pop	si
		add	si,4
		lodsw				; String [si] to ax
		call	game_func_120
		mov	byte ptr ds:data_164e,0FFh
loc_255:
		test	byte ptr ds:data_220e,0FFh
		jz	loc_256			; Jump if zero
		retn
loc_256:
		test	word ptr ds:data_214e,1
		jnz	loc_263			; Jump if not zero
		mov	byte ptr ds:data_132e,0
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_47:
		test	byte ptr ds:data_128e,0FFh
		jz	loc_259			; Jump if zero
		mov	al,0FCh
		inc	byte ptr ds:data_126e
		test	byte ptr ds:data_126e,1Fh
		jnz	loc_257			; Jump if not zero
		mov	al,0FEh
		mov	byte ptr ds:data_128e,0
loc_257:
		push	cs
		pop	es
		mov	di,data_207e
		mov	cl,ds:data_129e
		xor	ch,ch			; Zero register

locloop_258:
		push	cx
		mov	cx,12h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		add	di,0Ah
		pop	cx
		loop	locloop_258		; Loop if cx > 0

loc_259:
		test	byte ptr ds:data_127e,0FFh
		jnz	loc_260			; Jump if not zero
		retn
loc_260:
		mov	al,0FCh
		inc	byte ptr ds:data_125e
		and	byte ptr ds:data_125e,1Fh
		jnz	loc_261			; Jump if not zero
		mov	al,0FEh
		mov	byte ptr ds:data_127e,0
loc_261:
		push	ds
		pop	es
		mov	di,data_208e
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
		mov	al,ds:data_132e
		or	al,ds:data_232e
		or	al,ds:data_234e
		or	al,ds:data_172e
		jz	loc_264			; Jump if zero
		retn
loc_264:
		mov	byte ptr ds:data_246e,0Bh
		call	word ptr cs:[2002h]
		call	game_func_48
		call	word ptr cs:data_181e
		call	game_func_48
		cmp	byte ptr ds:data_245e,8
		jne	loc_265			; Jump if not equal
		jmp	loc_707
loc_265:
		call	word ptr cs:[2002h]
		push	ds
		call	word ptr cs:data_84
		mov	cx,18h
		call	word ptr cs:[2044h]
		pop	ds
		mov	byte ptr ds:data_132e,0FFh
		call	fill_buffer
		mov	byte ptr ds:data_216e,0
		mov	byte ptr ds:data_217e,0
		mov	byte ptr ds:data_127e,0
		mov	byte ptr ds:data_128e,0
		jmp	loc_231

;���� External Entry into Subroutine ��������������������������������������

game_func_48:
		mov	es,cs:data_219e
		mov	di,data_9e
		mov	si,data_181e
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
		mov	si,ds:data_186e
		add	si,6
		lodsb				; String [si] to al
		push	si
		mov	ds:data_138e,al
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
		mov	ds:data_139e,al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9D8Dh
		mov	si,ax
		mov	es,cs:data_219e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_219e
		mov	si,4000h
		mov	bp,0A000h
		mov	cx,100h
		call	word ptr cs:data_88
		pop	ds
		mov	byte ptr ds:data_225e,0
		mov	si,ds:data_186e
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
		call	vga_operation8
		mov	ax,word ptr ds:[80h]
		mov	bl,byte ptr ds:[83h]
		xor	bh,bh			; Zero register
		add	ax,bx
		test	byte ptr [si-5],0FFh
		jz	loc_271			; Jump if zero
		add	ax,9
loc_271:
		mov	bx,ax
		sub	bx,ds:data_187e
		jc	loc_272			; Jump if carry Set
		mov	ax,bx
loc_272:
		mov	si,ds:data_191e
		mov	[si],ax
		call	game_func_66
		call	game_func_47
		call	game_multiply_2
		call	word ptr cs:data_80
		mov	bx,21Ch
		xor	al,al			; Zero register
		mov	ch,42h			; 'B'
		call	word ptr cs:[2004h]
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:data_164e,0
		jmp	loc_1
game_check_state_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_buffer		proc	near
loc_273:
		push	cs
		pop	es
		mov	di,data_206e
		mov	cx,214h
		mov	al,0FDh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn
fill_buffer		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_scan_loop_2		proc	near
loc_274:
		push	di
		mov	es,cs:data_219e
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
game_scan_loop_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_51		proc	near
loc_278:
		push	si
		push	dx
		mov	bx,0E1Eh
		mov	cx,3410h
		mov	al,0FFh
		call	word ptr cs:[2000h]
		mov	byte ptr ds:data_125e,0
		mov	byte ptr ds:data_127e,0FFh
		mov	byte ptr ds:data_126e,0FFh
		pop	si
		lodsw				; String [si] to ax
		add	ax,3Ah
		mov	bx,ax
		mov	cl,22h			; '"'
		call	word ptr cs:[202Ah]
		pop	si
		retn
game_func_51		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_multiply		proc	near
		lodsb				; String [si] to al
		add	al,19h
		mov	cl,al
		push	cx
		lodsb				; String [si] to al
		push	si
		add	al,2
		mov	ds:data_129e,al
		mov	bl,8
		mul	bl			; ax = reg * al
		mov	bx,1616h
		mov	ch,24h			; '$'
		mov	cl,al
		mov	al,0FFh
		call	word ptr cs:[2000h]
		pop	si
		mov	byte ptr ds:data_125e,0
		mov	byte ptr ds:data_127e,0
		mov	byte ptr ds:data_126e,0
		mov	byte ptr ds:data_128e,0FFh
		mov	bx,58h
		pop	cx
loc_279:
		mov	ds:data_130e,bx
		mov	ds:data_131e,cl
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
		mov	bx,ds:data_130e
		mov	cl,ds:data_131e
		add	cl,0Ch
		jmp	short loc_279
game_multiply		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_multiply_2		proc	near
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
game_multiply_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_scan_loop_3		proc	near
		cmp	byte ptr ds:[9Eh],2
		jne	loc_284			; Jump if not equal
		retn
loc_284:
		mov	byte ptr ds:data_158e,0
		call	vga_operation8
		mov	cx,3
		test	byte ptr ds:data_229e,0FFh
		jz	locloop_285		; Jump if zero
		add	si,24h
		call	vga_operation5
		dec	cx

locloop_285:
		push	cx
		mov	cx,3

locloop_286:
		push	cx
		mov	al,[si]
		inc	si
		call	game_scan_loop_2
		jnz	loc_287			; Jump if not zero
		mov	byte ptr ds:data_158e,0FFh
loc_287:
		pop	cx
		loop	locloop_286		; Loop if cx > 0

		add	si,21h
		call	vga_operation5
		pop	cx
		loop	locloop_285		; Loop if cx > 0

		test	byte ptr ds:data_230e,0FFh
		jnz	loc_288			; Jump if not zero
		inc	si
		mov	al,[si]
		call	game_scan_loop_2
		jnz	loc_288			; Jump if not zero
		mov	byte ptr ds:data_158e,0FFh
loc_288:
		test	byte ptr ds:data_158e,0FFh
		jnz	loc_289			; Jump if not zero
		retn
loc_289:
		mov	byte ptr ds:data_227e,0FFh
		mov	byte ptr ds:data_246e,9
		mov	bl,ds:data_195e
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,ds:data_98e[bx]
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
		test	byte ptr ds:data_220e,0FFh
		jz	loc_290			; Jump if zero
		retn
loc_290:
		mov	word ptr ds:data_154e,0
		call	vga_operation8
		dec	si
		mov	di,9F0Eh
		mov	bx,7651h
		test	byte ptr ds:data_229e,0FFh
		jnz	loc_291			; Jump if not zero
		mov	bx,763Eh
		sub	si,24h
		call	vga_operation6
loc_291:
		push	bx
		push	di
		push	si
		call	bx			;*
		sbb	al,al
		mov	[di],al
		jz	loc_292			; Jump if zero
		call	game_func_56
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
		call	game_func_59
loc_293:
		sbb	al,al
		mov	[di],al
		jz	loc_294			; Jump if zero
		call	game_func_56
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
		call	game_func_59
loc_295:
		sbb	al,al
		mov	[di],al
		jz	loc_296			; Jump if zero
		call	game_func_57
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
		call	game_func_57
loc_297:
		mov	di,data_152e
		mov	al,[di]
		or	al,[di+1]
		or	al,[di+2]
		or	al,[di+3]
		mov	ds:data_155e,al
		mov	ds:data_227e,al
		or	al,al			; Zero ?
		jz	loc_ret_298		; Jump if zero
		call	word ptr cs:[201Ah]

loc_ret_298:
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_56:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_299			; Jump if zero
		retn
loc_299:
		mov	ax,ds:data_154e
		test	byte ptr ds:[0C2h],1
		jz	loc_304			; Jump if zero
		jmp	short loc_301

;���� External Entry into Subroutine ��������������������������������������

game_func_57:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_300			; Jump if zero
		retn
loc_300:
		mov	ax,ds:data_154e
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
		call	game_func_58
		mov	word ptr ds:[94h],0
		pop	ax
loc_303:
		call	game_func_60
		mov	byte ptr ds:data_246e,8
		retn
loc_304:
		call	game_func_60
		mov	byte ptr ds:data_246e,9
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_58:
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
		call	vga_operation9
		jc	loc_305			; Jump if carry Set
		test	al,40h			; '@'
		jnz	loc_305			; Jump if not zero
		and	al,0Fh
		jmp	short loc_309
loc_305:
		add	si,24h
		call	vga_operation5
		call	vga_operation9
		jc	loc_306			; Jump if carry Set
		test	al,40h			; '@'
		jnz	loc_306			; Jump if not zero
		and	al,0Fh
		jmp	short loc_309

;���� External Entry into Subroutine ��������������������������������������

game_func_59:
loc_306:
		add	si,24h
		call	vga_operation5
		call	vga_operation9
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
		mov	al,ds:data_185e[bx]
		xor	ah,ah			; Zero register
		add	ds:data_154e,ax
		stc				; Set carry flag
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_60:
loc_310:
		sub	word ptr ds:[90h],ax
		jnc	loc_311			; Jump if carry=0
		mov	word ptr ds:[90h],0
loc_311:
		push	si
		call	word ptr cs:[2008h]
		pop	si
		retn
game_scan_loop_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_process_loop_2		proc	near
		mov	byte ptr ds:data_156e,0
		call	vga_operation8
		add	si,49h
		call	vga_operation5
		mov	cx,3

locloop_312:
		push	cx
		call	game_func_62
		sub	si,24h
		call	vga_operation6
		pop	cx
		loop	locloop_312		; Loop if cx > 0

		retn
game_process_loop_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_62		proc	near
		mov	al,[si]
		push	si
		call	game_func_63
		pop	si
		jz	loc_314			; Jump if zero
		retn
loc_314:
		pop	ax
		pop	ax
		mov	bl,cl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_99e[bx]	;*
game_func_62		endp

			                        ;* No entry point to code
;*		aam	76h			; 'v' undocumented inst
		db	0D4h, 76h		;  Fixup - byte match
;*                         lock	jbe	loc_313			;*Jump if below or =
		db	0F0h, 76h,0EAh		;  Fixup - byte match
;*		jbe	loc_313			;*Jump if below or =
		db	 76h,0E8h		;  Fixup - byte match
		dec	dx
		out	dx,ax			; port 0FFFFh ??I/O Non-standard
		call	game_func_13
		mov	byte ptr ds:data_156e,0FFh
		mov	byte ptr ds:data_233e,0
		mov	byte ptr ds:[0E7h],80h
		retn
			                        ;* No entry point to code
		call	game_process_loop
		jmp	loc_116
			                        ;* No entry point to code
		call	game_func_15
		jmp	loc_87

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_63		proc	near
		or	al,al			; Zero ?
		jz	loc_323			; Jump if zero
		mov	es,cs:data_219e
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
game_func_63		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_check_state_4		proc	near
		mov	ax,ds:data_196e
		cmp	ax,0FFFFh
		je	loc_328			; Jump if equal
		call	game_func_141
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
		mov	ds:data_178e,bl
		mov	bl,ds:data_197e
		mov	bh,ds:data_226e
		mov	al,bh
		sub	al,bl
		and	al,3Fh			; '?'
		sub	bl,bh
		and	bl,3Fh			; '?'
		cmp	bl,al
		jb	loc_327			; Jump if below
		mov	bl,al
loc_327:
		mov	ds:data_179e,bl
		cmp	byte ptr ds:data_178e,10h
		jae	loc_328			; Jump if above or =
		mov	al,ds:data_178e
		mov	bx,data_100e
		xlat				; al=[al+[bx]] table
		mov	dl,al
		cmp	byte ptr ds:data_179e,10h
		jae	loc_328			; Jump if above or =
		mov	al,ds:data_179e
		mov	bx,data_100e
		xlat				; al=[al+[bx]] table
		add	al,dl
		jc	loc_328			; Jump if carry Set
		mov	bx,data_101e
		xlat				; al=[al+[bx]] table
		mov	ds:data_213e,al
		retn
loc_328:
		mov	byte ptr ds:data_213e,0
		retn
game_check_state_4		endp

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

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_65		proc	near
		mov	bx,601Ch
		jmp	loc_366
game_func_65		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_66		proc	near
		mov	bp,ds:data_191e
loc_329:
		mov	ax,ds:[bp]
		cmp	ax,0FFFFh
		jne	loc_330			; Jump if not equal
		retn
loc_330:
		call	game_func_68
		jc	loc_332			; Jump if carry Set
		mov	al,ds:[bp+3]
		and	al,7
		add	al,61h			; 'a'
		mov	ds:data_103e,al
		mov	ds:data_104e,al
		mov	al,ds:[bp+2]
		xor	ah,ah			; Zero register
		call	vga_operation4
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
		mov	si,data_102e
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
		call	game_get_value_3
		inc	di
		inc	si
		dec	al
		jnz	loc_337			; Jump if not zero
		pop	si
		add	si,5
		xchg	si,di
		pop	si
		add	si,24h
		call	vga_operation5
		xchg	di,si
		pop	ax
		pop	cx
		loop	locloop_336		; Loop if cx > 0

		jmp	short loc_332
game_func_66		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_get_value_3		proc	near
		test	byte ptr [di],80h
		jz	loc_338			; Jump if zero
		retn
loc_338:
		mov	dl,[si]
		mov	[di],dl
		retn
game_get_value_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_68		proc	near
		add	ax,3
		push	ax
		sub	ax,ds:data_187e
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
		mov	ax,ds:data_187e
		sub	ax,word ptr ds:[80h]
		add	ax,bx
		xchg	bx,ax
		mov	ax,27h
		sub	ax,bx
		retn
game_func_68		endp
		; ASCII sequence / lookup table
		db	'\'', 0		; 0x0000
		db	'+', 0		; 0x0002
		db	0C3h		; 0x0004
		db	'IJaKLMOPQN_RST`_UVW`IJaKLMX', 0		; 0x0005
		db	'YN_Z', 0		; 0x0021
		db	'[`_\\]^`', 0		; 0x0026
		db	0BCh		; 0x002E
		db	0F3h,0AAh,0F6h,0D0h,0A2h,0F5h
		db	 9Eh,0A2h,0FEh, 9Eh,0A2h,0FFh
		db	 9Eh,0E8h, 57h, 04h,0B0h,0FFh
		db	0A2h, 60h,0EBh,0A2h, 67h,0EBh
		db	0A2h, 6Eh,0EBh,0A2h, 75h,0EBh
		db	0C6h, 06h, 3Ah,0FFh, 00h, 2Eh
		db	 8Eh, 06h, 2Ch,0FFh,0BEh,0E6h
		db	 9Bh,0BFh, 00h, 60h,0B0h, 02h
		db	 2Eh,0FFh, 16h, 0Ch, 01h, 1Eh
		db	 2Eh, 8Eh, 1Eh, 2Ch,0FFh,0BEh
		db	 33h, 63h,0BDh, 00h,0D0h,0B9h
		db	0E6h, 00h, 2Eh,0FFh, 16h, 28h
		db	 30h, 1Fh, 8Bh, 36h, 00h,0C0h
		db	0ACh,0E8h, 4Dh, 04h, 2Eh,0FFh
		db	 16h, 02h, 20h,0BEh,0FDh, 9Bh
		db	 2Eh, 8Eh, 06h, 2Ch,0FFh,0BFh
		db	 00h, 80h,0B0h, 02h, 2Eh,0FFh
		db	 16h, 0Ch, 01h, 1Eh, 2Eh, 8Eh
		db	 1Eh, 2Ch,0FFh,0BEh, 00h, 80h
		db	0B9h, 80h, 00h, 2Eh,0FFh, 16h
		db	 44h, 20h, 1Fh, 32h,0C0h, 2Eh
		db	0FFh, 16h, 1Eh, 30h,0A0h,0C4h
		db	 00h, 0Ah,0C0h, 78h, 03h,0E8h
		db	 7Ch,0F1h,0E9h,0EBh, 01h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_69		proc	near
		call	vga_operation8
		sub	si,25h
		call	vga_operation6
		cmp	byte ptr [si],4Ah	; 'J'
		je	loc_344			; Jump if equal
		inc	si
		cmp	byte ptr [si],4Ah	; 'J'
		je	loc_346			; Jump if equal
		inc	si
		cmp	byte ptr [si],4Ah	; 'J'
		je	loc_342			; Jump if equal
		retn
loc_342:
		test	byte ptr ds:[0C2h],1
		jz	loc_343			; Jump if zero
		retn
loc_343:
		pop	ax
		jmp	loc_116
loc_344:
		test	byte ptr ds:[0C2h],1
		jnz	loc_345			; Jump if not zero
		retn
loc_345:
		pop	ax
		jmp	loc_87
loc_346:
		mov	ax,word ptr ds:[80h]
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	bx,ds:data_187e
		dec	bx
		sub	bx,ax
		jnc	loc_347			; Jump if carry=0
		not	bx
		mov	ax,bx
loc_347:
		mov	bl,byte ptr ds:[84h]
		dec	bl
		add	bl,byte ptr ds:[82h]
		and	bl,3Fh			; '?'
		mov	si,ds:data_191e
loc_348:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_349			; Jump if not zero
		retn
loc_349:
		cmp	ax,[si]
		jne	loc_350			; Jump if not equal
		cmp	bl,[si+2]
		je	loc_351			; Jump if equal
loc_350:
		add	si,0Ch
		jmp	short loc_348
loc_351:
		pop	ax
		test	byte ptr [si+3],80h
		jnz	loc_354			; Jump if not zero
		call	game_func_72
		jc	loc_352			; Jump if carry Set
		retn
loc_352:
		mov	byte ptr ds:[0E7h],80h
		mov	byte ptr ds:data_167e,0
		test	byte ptr ds:data_160e,0FFh
		jz	loc_353			; Jump if zero
		retn
loc_353:
		mov	byte ptr ds:data_160e,0FFh
		mov	byte ptr ds:data_246e,16h
		mov	dx,9AC5h
		jmp	loc_278
loc_354:
		mov	bx,[si+9]
;*		cmp	bx,0FFFFh
		db	 83h,0FBh,0FFh		;  Fixup - byte match
		jz	loc_355			; Jump if zero
		mov	al,[si+0Bh]
		or	[bx],al
loc_355:
		push	si
		call	game_func_91
		call	fill_buffer
		call	word ptr cs:data_74
		call	game_func_73
		call	game_func_46
		mov	si,ds:data_194e
		mov	word ptr [si],0FFFFh
		pop	si
		mov	al,[si+3]
		and	al,7
		push	ax
		mov	ax,[si+5]
		mov	ds:data_161e,ax
		mov	al,[si+7]
		mov	ds:data_162e,al
		mov	al,[si+3]
		and	al,40h			; '@'
		mov	byte ptr ds:[0C3h],al
		mov	al,[si+8]
		mov	ds:data_163e,al
		mov	ah,[si+4]
		cmp	byte ptr [si+7],0FFh
		jne	loc_356			; Jump if not equal
		or	ah,80h
loc_356:
		mov	byte ptr ds:[0C4h],ah
		mov	al,1
		call	word ptr cs:[10Ch]
		test	byte ptr ds:[0C4h],80h
		jnz	loc_357			; Jump if not zero
		call	game_func_27
loc_357:
		call	game_func_70
		mov	si,ds:data_186e
		lodsb				; String [si] to al
		test	al,1
		jnz	loc_358			; Jump if not zero
		mov	si,9C08h
		mov	es,cs:data_219e
		mov	di,8000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_219e
		mov	si,8000h
		mov	cx,80h
		call	word ptr cs:[2044h]
		pop	ds
		pop	ax
		call	word ptr cs:data_86
		mov	byte ptr ds:data_133e,0FFh
		mov	byte ptr ds:data_218e,0Ah
		jmp	short loc_359
loc_358:
		mov	si,9BFDh
		mov	es,cs:data_219e
		mov	di,8000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_219e
		mov	si,8000h
		mov	cx,80h
		call	word ptr cs:[2044h]
		pop	ds
		pop	ax
		call	word ptr cs:data_86
		mov	si,ds:data_186e
		lodsb				; String [si] to al
		call	copy_buffer
loc_359:
		mov	byte ptr ds:data_231e,0
		mov	byte ptr ds:data_132e,0FFh
		mov	byte ptr ds:data_210e,0FFh
		test	byte ptr ds:data_163e,80h
		jz	loc_360			; Jump if zero
		mov	si,data_124e
		push	cs
		pop	es
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		call	word ptr cs:data_181e
		mov	byte ptr ds:data_139e,0FFh
		mov	byte ptr ds:data_138e,0FFh
		mov	al,byte ptr ds:[0C8h]
		mov	ds:data_137e,al
		mov	byte ptr ds:data_142e,0FFh
		call	vga_operation_2
		mov	es,cs:data_219e
		mov	si,9BE6h
		mov	di,6000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_219e
		mov	si,6333h
		mov	bp,0D000h
		mov	cx,0E6h
		call	word ptr cs:data_88
		pop	ds
		jmp	loc_364
loc_360:
		test	byte ptr ds:[0C3h],0FFh
		jnz	loc_362			; Jump if not zero
		and	byte ptr ds:[0C2h],0FEh
		mov	bx,0A6Eh
		mov	cx,1Ah

locloop_361:
		push	cx
		push	bx
		inc	byte ptr ds:[0E7h]
		call	word ptr cs:data_82
		pop	bx
		add	bh,2
		push	bx
		call	word ptr cs:data_87
		call	game_multiply_3
		pop	bx
		push	bx
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		pop	bx
		pop	cx
		loop	locloop_361		; Loop if cx > 0

		mov	cx,618h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		jmp	short loc_364
loc_362:
		or	byte ptr ds:[0C2h],1
		mov	bx,406Eh
		mov	cx,1Ah

locloop_363:
		push	cx
		push	bx
		inc	byte ptr ds:[0E7h]
		call	word ptr cs:data_82
		pop	bx
		sub	bh,2
		push	bx
		call	word ptr cs:data_87
		call	game_multiply_3
		pop	bx
		push	bx
		add	bh,4
		mov	cx,218h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		pop	bx
		pop	cx
		loop	locloop_363		; Loop if cx > 0

		mov	cx,618h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
loc_364:
		mov	si,ds:data_186e
		lodsb				; String [si] to al
		mov	ah,al
		and	al,1
		jz	loc_365			; Jump if zero
		call	vga_operation_2
		mov	si,ds:data_186e
		lodsb				; String [si] to al
		mov	ah,al
		add	ah,ah
		sbb	bl,bl
		mov	ds:data_225e,bl
		add	ah,ah
		sbb	bl,bl
		mov	byte ptr ds:[0E6h],bl
		mov	byte ptr ds:data_220e,0
		mov	byte ptr ds:data_221e,0
		call	word ptr cs:[2002h]
		mov	byte ptr ds:[83h],0Ch
		mov	al,ds:data_198e
		mov	byte ptr ds:[84h],al
		mov	ds:data_140e,al
		mov	byte ptr ds:[0E7h],80h
		push	ds
		mov	ds,cs:data_219e
		mov	si,8030h
		mov	cx,66h
		call	word ptr cs:[2044h]
		call	word ptr cs:data_89
		pop	ds
		push	ds
		call	word ptr cs:data_84
		mov	cx,18h
		call	word ptr cs:[2044h]
		pop	ds
		jmp	loc_1
loc_365:
		mov	si,ds:data_186e
		inc	si
		lodsb				; String [si] to al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9C2Dh
		mov	si,ax
		mov	es,cs:data_219e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	bx,6000h
loc_366:
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		push	bx
		call	game_func_71
		mov	word ptr ds:[80h],ax
		mov	byte ptr ds:[83h],bl
		mov	si,ds:data_186e
		lodsb				; String [si] to al
		shr	al,1			; Shift w/zeros fill
		and	al,1Fh
		mov	byte ptr ds:[0C8h],al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9E53h
		mov	si,ax
		mov	es,cs:data_219e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		pop	bx
		xor	al,al			; Zero register
		jmp	word ptr cs:[10Ch]
game_func_69		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_70		proc	near
		mov	ax,ds:data_161e
		add	ax,0FFF0h
		or	ah,ah			; Zero ?
		jns	loc_367			; Jump if not sign
		add	ax,ds:data_187e
loc_367:
		mov	word ptr ds:[80h],ax
		mov	al,ds:data_162e
		inc	al
		sub	al,ds:data_198e
		and	al,3Fh			; '?'
		mov	byte ptr ds:[82h],al
		retn
game_func_70		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_71		proc	near
		mov	bx,0Dh
		mov	ax,ds:data_161e
		mov	cx,ds:data_187e
		sub	cx,bx
		sub	cx,ax
		jnc	loc_368			; Jump if carry=0
		mov	ax,ds:data_187e
		add	ax,0FFDCh
		mov	cx,ds:data_161e
		sbb	cx,ax
		mov	bl,cl
		sub	bl,3
		retn
loc_368:
		add	ax,0FFEFh
		or	ah,ah			; Zero ?
		jnz	loc_369			; Jump if not zero
		retn
loc_369:
		xor	ax,ax			; Zero register
		mov	bl,ds:data_161e
		sub	bl,4
		retn
game_func_71		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_72		proc	near
		mov	bl,[si+8]
		and	bl,1
		jnz	loc_371			; Jump if not zero
		test	byte ptr ds:[98h],0FFh
		stc				; Set carry flag
		jnz	loc_370			; Jump if not zero
		retn
loc_370:
		dec	byte ptr ds:[98h]
		mov	byte ptr ds:data_246e,15h
		or	byte ptr [si+3],80h
		mov	bx,[si+9]
		mov	al,[si+0Bh]
		or	[bx],al
		retn
loc_371:
		test	byte ptr ds:[99h],0FFh
		stc				; Set carry flag
		jnz	loc_372			; Jump if not zero
		retn
loc_372:
		dec	byte ptr ds:[99h]
		mov	byte ptr ds:data_246e,15h
		or	byte ptr [si+3],80h
		mov	bx,[si+9]
		mov	al,[si+0Bh]
		or	[bx],al
		retn
game_func_72		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_73		proc	near
		xor	al,al			; Zero register
		mov	ds:data_239e,al
		mov	ds:data_240e,al
		mov	ds:data_232e,al
		mov	ds:data_233e,al
		mov	ds:data_229e,al
		mov	ds:data_227e,al
		mov	ds:data_127e,al
		mov	ds:data_234e,al
		mov	ds:data_245e,al
		mov	ds:data_213e,al
		mov	byte ptr ds:[0E7h],al
		mov	ax,0FFFFh
		mov	ds:data_210e,al
		mov	ds:data_212e,al
		mov	word ptr ds:[0EB15h],ax
		mov	ds:data_231e,al
		mov	ds:data_132e,al
		jmp	loc_273
game_func_73		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

copy_buffer		proc	near
		push	cs
		pop	es
		mov	di,data_133e
		mov	cx,4
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		shr	al,1			; Shift w/zeros fill
		and	al,0Fh
		mov	ah,al
		mov	al,0FFh
		cmp	ah,byte ptr ds:[0C8h]
		je	loc_373			; Jump if equal
		mov	byte ptr ds:data_218e,0Ah
		mov	byte ptr ds:[0C8h],ah
		mov	al,ah
loc_373:
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn
copy_buffer		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation_2		proc	near
		mov	es,cs:data_219e
		mov	si,9C13h
		mov	di,8C00h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	bl,ds:data_134e
		mov	al,0Bh
		mul	bl			; ax = reg * al
		add	ax,9C43h
		mov	si,ax
		mov	es,cs:data_219e
		mov	di,8000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	bl,ds:data_135e
		cmp	bl,0FFh
		jne	loc_374			; Jump if not equal
		retn
loc_374:
		cmp	bl,ds:data_138e
		je	loc_375			; Jump if equal
		mov	ds:data_138e,bl
		mov	al,0Bh
		mul	bl			; ax = reg * al
		add	ax,9CBCh
		mov	si,ax
		push	cs
		pop	es
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
loc_375:
		mov	bl,ds:data_136e
		cmp	bl,0FFh
		jne	loc_376			; Jump if not equal
		retn
loc_376:
		cmp	bl,ds:data_139e
		je	loc_377			; Jump if equal
		mov	ds:data_139e,bl
		mov	al,0Bh
		mul	bl			; ax = reg * al
		add	ax,9D8Dh
		mov	si,ax
		mov	es,cs:data_219e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_219e
		mov	si,4000h
		mov	bp,0A000h
		mov	cx,100h
		call	word ptr cs:data_88
		pop	ds
loc_377:
		mov	bl,ds:data_137e
		cmp	bl,0FFh
		jne	loc_378			; Jump if not equal
		retn
loc_378:
		push	bx
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:data_142e,0FFh
		pop	bx
		mov	al,0Bh
		mul	bl			; ax = reg * al
		add	ax,9E53h
		mov	si,ax
		mov	es,cs:data_219e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		retn
vga_operation_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_multiply_3		proc	near
		mov	cl,ds:data_224e
		mov	al,4
		mul	cl			; ax = reg * al
loc_379:
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		cmp	ds:data_215e,al
		jb	loc_379			; Jump if below
		mov	byte ptr ds:data_215e,0
		retn
game_multiply_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_scan_loop_4		proc	near
		mov	si,ds:data_188e
loc_380:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_381			; Jump if not equal
		retn
loc_381:
		call	game_func_87
		jc	loc_383			; Jump if carry Set
		mov	ah,bl
		mov	al,[si+2]
		call	vga_operation4
		mov	cx,3
		mov	dl,40h			; '@'

locloop_382:
		call	game_func_89
		inc	di
		inc	dl
		loop	locloop_382		; Loop if cx > 0

loc_383:
		add	si,3
		jmp	short loc_380
game_scan_loop_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_78		proc	near
		test	byte ptr ds:data_230e,0FFh
		jz	loc_384			; Jump if zero
		retn
loc_384:
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	dl,40h			; '@'
		call	game_func_82
		jz	loc_385			; Jump if zero
		retn
loc_385:
		mov	di,ds:data_188e
		mov	dl,40h			; '@'
		call	game_process_loop_3
		jnc	loc_386			; Jump if carry=0
		pop	ax
		mov	byte ptr ds:[0E7h],80h
		jmp	loc_169
loc_386:
		call	vga_operation9
		jnc	loc_387			; Jump if carry=0
		retn
loc_387:
		and	al,60h			; '`'
		jz	loc_388			; Jump if zero
		retn
loc_388:
		test	byte ptr [bx+5],20h	; ' '
		jz	loc_389			; Jump if zero
		retn
loc_389:
		or	byte ptr [bx+5],40h	; '@'
		and	byte ptr [bx+5],0E0h
		retn
game_func_78		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_process_loop_3		proc	near
		push	dx
		call	game_func_81
		pop	dx
		mov	bx,si
		add	si,23h
		call	vga_operation5
		test	byte ptr [si],80h
		clc				; Clear carry flag
		jz	loc_390			; Jump if zero
		retn
loc_390:
		mov	cx,3

locloop_391:
		inc	si
		test	byte ptr [si],0FFh
		jz	loc_392			; Jump if zero
		retn
loc_392:
		loop	locloop_391		; Loop if cx > 0

		mov	si,bx
		add	si,24h
		call	vga_operation5
		push	di
		mov	di,si
		mov	cx,3

locloop_393:
		push	dx
		push	bx
		call	game_func_89
		pop	bx
		xchg	di,bx
		push	bx
		xor	dl,dl			; Zero register
		call	game_func_89
		pop	bx
		xchg	di,bx
		inc	di
		inc	bx
		pop	dx
		inc	dl
		loop	locloop_393		; Loop if cx > 0

		pop	di
		inc	byte ptr [di+2]
		and	byte ptr [di+2],3Fh	; '?'
		stc				; Set carry flag
		retn
game_process_loop_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_80		proc	near
		test	byte ptr ds:data_230e,0FFh
		jz	loc_394			; Jump if zero
		retn
loc_394:
		call	vga_operation8
		sub	si,23h
		call	vga_operation6
		mov	al,[si]
		call	game_check_state_2
		jz	loc_395			; Jump if zero
		retn
loc_395:
		add	si,90h
		call	vga_operation5
		mov	dl,40h			; '@'
		call	game_func_82
		jz	loc_396			; Jump if zero
		retn
loc_396:
		mov	di,ds:data_188e
		mov	dl,40h			; '@'
		push	dx
		call	game_func_81
		pop	dx
		mov	ax,si
		sub	si,24h
		call	vga_operation6
		mov	bx,si
		sub	si,24h
		call	vga_operation6
		mov	cx,3

locloop_397:
		test	byte ptr [si],80h
		jz	loc_398			; Jump if zero
		retn
loc_398:
		test	byte ptr [bx],0FFh
		jz	loc_399			; Jump if zero
		retn
loc_399:
		inc	si
		inc	bx
		loop	locloop_397		; Loop if cx > 0

		mov	bx,ax
		mov	si,bx
		sub	si,24h
		call	vga_operation6
		push	di
		mov	di,si
		mov	cx,3

locloop_400:
		push	dx
		push	bx
		call	game_func_89
		pop	bx
		xchg	di,bx
		push	bx
		xor	dl,dl			; Zero register
		call	game_func_89
		pop	bx
		xchg	di,bx
		inc	di
		inc	bx
		pop	dx
		inc	dl
		loop	locloop_400		; Loop if cx > 0

		pop	di
		dec	byte ptr [di+2]
		and	byte ptr [di+2],3Fh	; '?'
		pop	ax
		pop	ax
		mov	byte ptr ds:[0E7h],80h
		mov	byte ptr ds:data_233e,0
		jmp	loc_77
game_func_80		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_81		proc	near
		mov	al,byte ptr ds:[83h]
		add	al,4
		add	al,dh
		xor	ah,ah			; Zero register
		add	ax,word ptr ds:[80h]
		cmp	ax,ds:data_187e
		jb	loc_401			; Jump if below
		sub	ax,ds:data_187e
loc_401:
		mov	cl,byte ptr ds:[82h]
		add	cl,byte ptr ds:[84h]
		add	cl,3
		and	cl,3Fh			; '?'
loc_402:
		cmp	ax,[di]
		jne	loc_403			; Jump if not equal
		cmp	cl,[di+2]
		je	loc_404			; Jump if equal
loc_403:
		add	di,3
		jmp	short loc_402
loc_404:
		call	game_func_87
		mov	al,[di+2]
		mov	ah,bl
		push	di
		call	vga_operation4
		mov	si,di
		pop	di
		retn
game_func_81		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_82		proc	near
		mov	dh,1
		cmp	dl,[si]
		jne	loc_405			; Jump if not equal
		retn
loc_405:
		dec	dh
		inc	dl
		cmp	dl,[si]
		jne	loc_406			; Jump if not equal
		retn
loc_406:
		dec	dh
		inc	dl
		cmp	dl,[si]
		retn
game_func_82		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_scan_loop_5		proc	near
		mov	si,ds:data_189e
loc_407:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_408			; Jump if not equal
		retn
loc_408:
		call	game_func_87
		jc	loc_410			; Jump if carry Set
		mov	ah,bl
		mov	al,[si+2]
		call	vga_operation4
		mov	cx,3
		mov	dl,43h			; 'C'

locloop_409:
		call	game_func_89
		inc	di
		inc	dl
		loop	locloop_409		; Loop if cx > 0

loc_410:
		add	si,3
		jmp	short loc_407
game_scan_loop_5		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_84		proc	near
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	dl,43h			; 'C'
		call	game_func_82
		jz	loc_411			; Jump if zero
		retn
loc_411:
		mov	di,ds:data_189e
		mov	dl,43h			; 'C'
		call	game_process_loop_3
		jc	loc_412			; Jump if carry Set
		retn
loc_412:
		jmp	loc_169
game_func_84		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_85		proc	near
		inc	byte ptr ds:data_145e
		mov	si,ds:data_190e
loc_413:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_414			; Jump if not equal
		retn
loc_414:
		and	ax,3FFFh
		call	game_func_88
		jc	loc_419			; Jump if carry Set
		mov	cl,bl
		dec	bx
		dec	bx
		or	bh,bh			; Zero ?
		jns	loc_415			; Jump if not sign
		inc	cl
		mov	al,[si+2]
		xor	ah,ah			; Zero register
		call	vga_operation4
		jmp	short loc_417
loc_415:
		mov	ax,bx
		sub	ax,22h
		jc	loc_416			; Jump if carry Set
		push	ax
		mov	al,[si+2]
		mov	ah,22h			; '"'
		call	vga_operation4
		pop	ax
		add	di,ax
		mov	cl,al
		neg	cl
		add	cl,2
		jmp	short loc_417
loc_416:
		mov	ah,bl
		mov	al,[si+2]
		call	vga_operation4
		mov	cl,3
loc_417:
		xor	ch,ch			; Zero register
		xor	dl,dl			; Zero register

locloop_418:
		call	game_func_89
		inc	di
		loop	locloop_418		; Loop if cx > 0

loc_419:
		mov	ax,[si]
		mov	bl,ah
		and	ax,3FFFh
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		and	bl,3
		jz	loc_420			; Jump if zero
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:data_105e[bx]	;*
loc_420:
		call	game_func_87
		jc	loc_422			; Jump if carry Set
		mov	ah,bl
		mov	al,[si+2]
		call	vga_operation4
		mov	cx,3
		mov	dl,46h			; 'F'

locloop_421:
		call	game_func_89
		inc	di
		inc	dl
		loop	locloop_421		; Loop if cx > 0

loc_422:
		add	si,7
		jmp	loc_413
game_func_85		endp

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
		jz	loc_423			; Jump if zero
		retn
loc_423:
		test	byte ptr [si+2],80h
		jnz	loc_426			; Jump if not zero
		inc	ax
		mov	bx,ax
		sub	ax,ds:data_187e
		jz	loc_424			; Jump if zero
		xchg	bx,ax
loc_424:
		push	si
		push	ax
		call	game_scan_loop_6
		jc	loc_425			; Jump if carry Set
		call	game_process_loop
loc_425:
		pop	ax
		pop	si
		mov	bx,[si+5]
		jmp	short loc_429
loc_426:
		dec	ax
		cmp	ax,0FFFFh
		jne	loc_427			; Jump if not equal
		mov	ax,ds:data_187e
		dec	ax
loc_427:
		push	si
		push	ax
		call	game_scan_loop_6
		jc	loc_428			; Jump if carry Set
		call	game_func_15
loc_428:
		pop	ax
		pop	si
		mov	bx,[si+3]
loc_429:
		mov	dl,[si+1]
		and	dl,0C0h
		or	dl,ah
		mov	[si],al
		mov	[si+1],dl
		sub	bx,ax
		jz	loc_430			; Jump if zero
		retn
loc_430:
		xor	byte ptr [si+2],80h
		or	byte ptr [si+2],40h	; '@'
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_scan_loop_6		proc	near
		mov	dl,ds:data_233e
		or	dl,ds:data_230e
		stc				; Set carry flag
		jz	loc_431			; Jump if zero
		retn
loc_431:
		mov	al,byte ptr ds:[84h]
		add	al,byte ptr ds:[82h]
		add	al,3
		and	al,3Fh			; '?'
		mov	ah,[si+2]
		and	ah,3Fh			; '?'
		cmp	al,ah
		stc				; Set carry flag
		jz	loc_432			; Jump if zero
		retn
loc_432:
		mov	ax,[si]
		and	ax,3FFFh
		call	game_func_87
		jnc	loc_433			; Jump if carry=0
		retn
loc_433:
		mov	dl,byte ptr ds:[83h]
		add	dl,4
		mov	cx,3

locloop_434:
		cmp	dl,al
		clc				; Clear carry flag
		jnz	loc_435			; Jump if not zero
		retn
loc_435:
		inc	dl
		loop	locloop_434		; Loop if cx > 0

		stc				; Set carry flag
		retn
game_scan_loop_6		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_87		proc	near
		mov	bx,ax
		sub	ax,word ptr ds:[80h]
		jc	loc_436			; Jump if carry Set
		xchg	bx,ax
		mov	ax,21h
		sub	ax,bx
		retn
loc_436:
		mov	ax,21h
		sub	ax,bx
		jnc	loc_437			; Jump if carry=0
		retn
loc_437:
		mov	ax,ds:data_187e
		sub	ax,word ptr ds:[80h]
		add	ax,bx
		xchg	bx,ax
		mov	ax,21h
		sub	ax,bx
		retn
game_func_87		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_88		proc	near
		add	ax,2
		mov	bx,ax
		sub	ax,ds:data_187e
		jnc	loc_438			; Jump if carry=0
		xchg	bx,ax
loc_438:
		mov	bx,ax
		sub	ax,word ptr ds:[80h]
		jc	loc_439			; Jump if carry Set
		xchg	bx,ax
		mov	ax,25h
		sub	ax,bx
		retn
loc_439:
		mov	ax,25h
		sub	ax,bx
		jnc	loc_440			; Jump if carry=0
		retn
loc_440:
		mov	ax,ds:data_187e
		sub	ax,word ptr ds:[80h]
		add	ax,bx
		xchg	bx,ax
		mov	ax,25h
		sub	ax,bx
		retn
game_func_88		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_89		proc	near
		test	byte ptr [di],80h
		jnz	loc_441			; Jump if not zero
		mov	[di],dl
		retn
loc_441:
		mov	bl,[di]
		and	bl,7Fh
		xor	bh,bh			; Zero register
		mov	ds:data_211e[bx],dl
		retn
game_func_89		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_check_state_5		proc	near
		mov	si,data_210e
loc_442:
		cmp	byte ptr [si],0FFh
		jne	loc_443			; Jump if not equal
		retn
loc_443:
		push	si
		call	game_func_92
		pop	si
		mov	al,[si]
		mov	[si+0Bh],al
		sub	al,4
		cmp	al,1Ch
		jae	loc_445			; Jump if above or =
		mov	al,[si+1]
		sub	al,byte ptr ds:[82h]
		and	al,3Fh			; '?'
		cmp	al,12h
		jae	loc_445			; Jump if above or =
		mov	[si+0Ch],al
		mov	ah,[si+0Bh]
		push	ax
		call	game_multiply_4
		pop	ax
		cmp	byte ptr [di],0FFh
		je	loc_444			; Jump if equal
		cmp	byte ptr [di],0FCh
		je	loc_444			; Jump if equal
		call	word ptr cs:data_77
		or	di,8000h
		mov	[si+7],di
		mov	al,[si+2]
		mov	bl,al
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		and	bx,3
		mov	bl,ds:data_106e[bx]
		and	bl,[si+3]
		add	al,bl
		and	al,3Fh			; '?'
		and	di,7FFFh
		call	word ptr cs:data_76
loc_444:
		add	si,0Dh
		jmp	short loc_442
loc_445:
		mov	byte ptr [si],0
		jmp	short loc_444
game_check_state_5		endp

			                        ;* No entry point to code
		add	[bx+di],al
		add	ax,[bx]

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_91		proc	near
		mov	si,data_210e
loc_446:
		cmp	byte ptr [si],0FFh
		je	loc_447			; Jump if equal
		push	si
		call	game_func_92
		pop	si
		add	si,0Dh
		jmp	short loc_446
loc_447:
		mov	byte ptr ds:data_210e,0FFh
		retn
game_func_91		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_92		proc	near
		test	word ptr [si+7],8000h
		jnz	loc_448			; Jump if not zero
		retn
loc_448:
		and	word ptr [si+7],7FFFh
		mov	dx,[si+7]
		mov	al,[si+0Ch]
		mov	ah,[si+0Bh]
game_func_92		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_93		proc	near
loc_449:
		push	ax
		call	game_multiply_4
		pop	ax
		cmp	byte ptr [di],0FCh
		jb	loc_450			; Jump if below
		retn
loc_450:
		add	al,byte ptr ds:[82h]
		call	vga_operation4
		mov	al,[di]
		jmp	word ptr cs:data_78
game_func_93		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

copy_buffer_2		proc	near
		mov	si,data_210e
		mov	di,data_210e
		push	cs
		pop	es
		mov	byte ptr ds:data_165e,0
loc_451:
		mov	al,[si]
		or	al,al			; Zero ?
		jnz	loc_452			; Jump if not zero
		test	word ptr [si+7],8000h
		jz	loc_455			; Jump if zero
loc_452:
		inc	al
		jnz	loc_453			; Jump if not zero
		mov	byte ptr [di],0FFh
		retn
loc_453:
		inc	byte ptr [si+3]
		push	es
		push	di
		call	game_scan_loop_7
		pop	di
		pop	es
		push	si
		mov	cx,0Dh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		test	byte ptr [si+5],40h	; '@'
		jnz	loc_454			; Jump if not zero
		mov	al,[si+3]
		cmp	al,[si+4]
		jb	loc_454			; Jump if below
		mov	byte ptr [si],0
loc_454:
		inc	byte ptr ds:data_165e
loc_455:
		add	si,0Dh
		jmp	short loc_451
copy_buffer_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_scan_loop_7		proc	near
		call	game_func_97
		test	byte ptr [si+5],8
		jnz	loc_457			; Jump if not zero
		mov	ah,[si]
		or	ah,ah			; Zero ?
		jnz	loc_456			; Jump if not zero
		retn
loc_456:
		mov	al,[si+1]
		call	vga_operation4
		mov	al,[di]
		call	game_func_41
		jz	loc_457			; Jump if zero
		mov	byte ptr [si],0
		retn
loc_457:
		mov	al,byte ptr ds:[82h]
		add	al,byte ptr ds:[84h]
		test	byte ptr ds:data_229e,0FFh
		jnz	loc_458			; Jump if not zero
		and	al,3Fh			; '?'
		cmp	al,[si+1]
		je	loc_460			; Jump if equal
loc_458:
		mov	cx,2

locloop_459:
		inc	al
		and	al,3Fh			; '?'
		cmp	al,[si+1]
		je	loc_460			; Jump if equal
		loop	locloop_459		; Loop if cx > 0

		retn
loc_460:
		mov	al,byte ptr ds:[83h]
		add	al,4
		test	byte ptr ds:[0C2h],1
		jz	loc_461			; Jump if zero
		inc	al
loc_461:
		cmp	al,[si]
		je	loc_462			; Jump if equal
		inc	al
		cmp	al,[si]
		je	loc_462			; Jump if equal
		retn
loc_462:
		mov	byte ptr [si],0
		test	byte ptr ds:[93h],0FFh
		jz	loc_464			; Jump if zero
		test	byte ptr ds:data_239e,0FFh
		jnz	loc_464			; Jump if not zero
		test	byte ptr ds:data_230e,0FFh
		jnz	loc_464			; Jump if not zero
		mov	al,[si+5]
		and	al,7
		cmp	al,2
		je	loc_464			; Jump if equal
		cmp	al,6
		je	loc_464			; Jump if equal
		or	al,al			; Zero ?
		jz	loc_463			; Jump if zero
		cmp	al,1
		je	loc_463			; Jump if equal
		cmp	al,7
		je	loc_463			; Jump if equal
		test	byte ptr ds:[0C2h],1
		jnz	loc_464			; Jump if not zero
		jmp	short loc_466
loc_463:
		test	byte ptr ds:[0C2h],1
		jnz	loc_466			; Jump if not zero
loc_464:
		mov	al,[si+6]
		xor	ah,ah			; Zero register
		call	game_func_60
		mov	byte ptr ds:data_246e,9
		mov	al,0FFh
		mov	ds:data_155e,al
		mov	ds:data_227e,al
		mov	bx,0FFFFh
		mov	cx,0FFFFh
		mov	al,[si+5]
		and	al,7
		cmp	al,2
		je	loc_465			; Jump if equal
		cmp	al,6
		je	loc_465			; Jump if equal
		xor	bx,bx			; Zero register
		or	al,al			; Zero ?
		jz	loc_465			; Jump if zero
		cmp	al,1
		je	loc_465			; Jump if equal
		cmp	al,7
		je	loc_465			; Jump if equal
		xchg	cx,bx
loc_465:
		mov	ds:data_152e,cx
		mov	ds:data_153e,bx
		retn
loc_466:
		cmp	byte ptr ds:[93h],4
		jae	loc_468			; Jump if above or =
		mov	al,byte ptr ds:[84h]
		add	al,byte ptr ds:[82h]
		inc	al
		test	byte ptr ds:data_229e,0FFh
		jz	loc_467			; Jump if zero
		inc	al
loc_467:
		call	game_func_96
		jc	loc_464			; Jump if carry Set
loc_468:
		mov	byte ptr ds:data_246e,0Ah
		retn
game_scan_loop_7		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_96		proc	near
		mov	bl,[si+5]
		and	bx,7
		add	bx,bx
		and	al,3Fh			; '?'
		jmp	word ptr ds:data_107e[bx]	;*
game_func_96		endp

			                        ;* No entry point to code
		xchg	cx,ax
		test	bx,ds:data_123e[bx+di]
		test	bx,ds:data_116e[bx+di]
		test	bx,ds:data_180e[bx]
		test	bx,data_90[bx]
loc_2598:
		inc	sp
		add	[di+1],si
		retn
			                        ;* No entry point to code
		stc				; Set carry flag
		retn
			                        ;* No entry point to code
		dec	al
		and	al,3Fh			; '?'
;*		jmp	short loc_469		;*
		db	0EBh,0F2h		;  Fixup - byte match
			                        ;* No entry point to code
		inc	al
		and	al,3Fh			; '?'
;*		jmp	short loc_469		;*
		jmp	short loc_2598
		jmp	short loc_2598
		jmp	short loc_2598
		db	0EBh			; was: db 0ECh, 00Ch

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_97		proc	near
		test	byte ptr [si+5],40h	; '@'
		jz	loc_470			; Jump if zero
		call	game_func_98
		jnc	loc_470			; Jump if carry=0
		retn
loc_470:
		mov	bl,[si+5]
		and	bx,7
		add	bx,bx
		call	word ptr ds:data_108e[bx]	;*
		and	byte ptr [si+1],3Fh	; '?'
		retn
game_func_97		endp

			                        ;* No entry point to code
;*		aad	85h			; undocumented inst
		db	0D5h, 85h		;  Fixup - byte match
		rol	byte ptr ds:data_109e[di],cl	; Rotate
		db	0DEh, 85h,0E1h, 85h,0E4h, 85h
		db	0EAh, 85h,0D8h, 85h,0FEh, 4Ch
		db	 01h,0FEh, 04h,0C3h,0FEh, 44h
		db	 01h,0FEh, 04h,0C3h,0FEh, 4Ch
		db	 01h,0FEh, 0Ch,0C3h,0FEh, 44h
		db	 01h,0FEh, 0Ch,0C3h,0FEh, 44h
		db	 01h,0C3h,0FEh, 4Ch, 01h,0C3h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_98		proc	near
		mov	bl,[si+3]
		xor	bh,bh			; Zero register
		mov	di,[si+9]
		mov	al,[bx+di]
		cmp	al,0FFh
		jne	loc_471			; Jump if not equal
		mov	byte ptr ds:[80h][si],0
		stc				; Set carry flag
		retn
loc_471:
		and	al,7
		and	byte ptr [si+5],0F8h
		or	[si+5],al
		retn
game_func_98		endp

			                        ;* No entry point to code
		cmp	byte ptr ds:data_165e,1Fh
		jb	loc_472			; Jump if below
		retn
loc_472:
		push	si
		push	cs
		pop	es
		mov	si,bx
		mov	di,data_210e
loc_473:
		cmp	byte ptr [di],0FFh
		je	loc_474			; Jump if equal
		add	di,0Dh
		jmp	short loc_473
loc_474:
		mov	cx,0Dh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		inc	byte ptr ds:data_165e
		pop	si
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_99		proc	near
		mov	si,data_210e
loc_475:
		mov	al,[si]
		cmp	al,0FFh
		jne	loc_476			; Jump if not equal
		retn
loc_476:
		or	al,al			; Zero ?
		jz	loc_477			; Jump if zero
		dec	byte ptr [si]
loc_477:
		add	si,0Dh
		jmp	short loc_475
game_func_99		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_100		proc	near
		mov	si,data_210e
loc_478:
		mov	al,[si]
		cmp	al,0FFh
		jne	loc_479			; Jump if not equal
		retn
loc_479:
		or	al,al			; Zero ?
		jz	loc_480			; Jump if zero
		inc	byte ptr [si]
loc_480:
		add	si,0Dh
		jmp	short loc_478
game_func_100		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_multiply_4		proc	near
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
game_multiply_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_102		proc	near
		mov	si,data_209e
		mov	cx,4

locloop_481:
		push	cx
		cmp	byte ptr [si],0FFh
		je	loc_483			; Jump if equal
		call	game_func_103
		test	byte ptr [si+2],0FFh
		jnz	loc_482			; Jump if not zero
		mov	byte ptr [si],0FFh
		jmp	short loc_483
loc_482:
		mov	bl,[si]
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,data_110e
		mov	ah,byte ptr ds:[83h]
		add	ah,[bx]
		mov	[si+5],ah
		mov	al,byte ptr ds:[84h]
		add	al,[bx+1]
		and	al,3Fh			; '?'
		mov	[si+6],al
		push	ax
		call	game_multiply_4
		pop	ax
		cmp	byte ptr [di],0FFh
		je	loc_483			; Jump if equal
		cmp	byte ptr [di],0FCh
		je	loc_483			; Jump if equal
		call	word ptr cs:data_77
		or	di,8000h
		mov	[si+3],di
		mov	al,66h			; 'f'
		and	di,7FFFh
		push	si
		call	word ptr cs:data_76
		pop	si
loc_483:
		add	si,7
		pop	cx
		loop	locloop_481		; Loop if cx > 0

		retn
game_func_102		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_103		proc	near
		test	word ptr [si+3],8000h
		jnz	loc_484			; Jump if not zero
		retn
loc_484:
		and	word ptr [si+3],7FFFh
		mov	dx,[si+3]
		mov	ah,[si+5]
		mov	al,[si+6]
		jmp	loc_449
game_func_103		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_scan_loop_8		proc	near
		mov	si,data_209e
		mov	cx,4

locloop_485:
		push	cx
		cmp	byte ptr [si],0FFh
		je	loc_486			; Jump if equal
		mov	bl,[si]
		add	bl,[si+1]
		and	bl,0Fh
		mov	[si],bl
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,data_110e
		mov	ah,byte ptr ds:[83h]
		add	ah,[bx]
		mov	al,byte ptr ds:[84h]
		add	al,[bx+1]
		add	al,byte ptr ds:[82h]
		call	vga_operation4
		xchg	si,di
		sub	si,25h
		call	vga_operation6
		xchg	si,di
		call	game_func_105
loc_486:
		add	si,7
		pop	cx
		loop	locloop_485		; Loop if cx > 0

		retn
game_scan_loop_8		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_105		proc	near
		test	byte ptr ds:data_225e,0FFh
		jz	loc_487			; Jump if zero
		test	byte ptr ds:data_222e,0FFh
		jz	loc_487			; Jump if zero
		retn
loc_487:
		call	game_func_106
		inc	di
		call	game_func_106
		xchg	si,di
		add	si,23h
		call	vga_operation5
		xchg	si,di
		call	game_func_106
		inc	di
game_func_105		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_106		proc	near
		test	byte ptr [si+2],0FFh
		jnz	loc_488			; Jump if not zero
		retn
loc_488:
		xchg	si,di
		call	vga_operation9
		xchg	si,di
		jnc	loc_489			; Jump if carry=0
		retn
loc_489:
		test	byte ptr [bx+4],20h	; ' '
		jz	loc_490			; Jump if zero
		retn
loc_490:
		test	byte ptr [bx+5],20h	; ' '
		jz	loc_491			; Jump if zero
		retn
loc_491:
		and	byte ptr [bx+5],0E0h
		or	byte ptr [bx+5],49h	; 'I'
		dec	byte ptr [si+2]
		retn
game_func_106		endp

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
sub_27B4:
		add	al,3
		add	ax,[bp+si]
		add	dh,dh
		push	es
		popf				; Pop flags
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		jnz	loc_492			; Jump if not zero
		retn
loc_492:
		test	byte ptr ds:data_232e,0FFh
		jnz	loc_496			; Jump if not zero
		test	byte ptr ds:data_217e,0FFh
		jnz	loc_493			; Jump if not zero
		retn
loc_493:
		mov	byte ptr ds:data_216e,0
		mov	byte ptr ds:data_217e,0
		test	byte ptr ds:data_239e,0FFh
		jz	loc_494			; Jump if zero
		retn
loc_494:
		test	byte ptr ds:data_234e,0FFh
		jz	loc_495			; Jump if zero
		retn
loc_495:
		mov	byte ptr ds:data_177e,0
		mov	byte ptr ds:data_232e,0FFh
		mov	byte ptr ds:data_246e,17h
		retn
loc_496:
		add	byte ptr ds:data_177e,2
		cmp	byte ptr ds:data_177e,4
		je	loc_498			; Jump if equal
		cmp	byte ptr ds:data_177e,6
		jae	loc_497			; Jump if above or =
		retn
loc_497:
		mov	byte ptr ds:data_232e,0
		retn
loc_498:
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		test	byte ptr ds:[0ABh][bx],0FFh
		jnz	loc_499			; Jump if not zero
		retn
loc_499:
		dec	byte ptr ds:[0ABh][bx]
		call	word ptr cs:[2018h]
		mov	byte ptr ds:data_246e,18h
		mov	si,0EB15h
		mov	byte ptr ds:data_234e,0FFh
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_111e[bx]	;*
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
		mov	al,ds:data_229e
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
		cmp	ax,ds:data_187e
		jb	loc_500			; Jump if below
		sub	ax,ds:data_187e
loc_500:
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

locloop_501:
		push	cx
		mov	al,6
		mul	cl			; ax = reg * al
		add	ax,2
		add	ax,word ptr ds:[80h]
		cmp	ax,ds:data_187e
		jb	loc_502			; Jump if below
		sub	ax,ds:data_187e
loc_502:
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
		loop	locloop_501		; Loop if cx > 0

		retn
		db	 56h,0B9h, 03h, 00h

locloop_503:
		push	cx
;*		call	game_func_108			;*
		db	0E8h, 4Dh,0FFh		;  Fixup - byte match
		add	si,10h
		pop	cx
		loop	locloop_503		; Loop if cx > 0

		pop	si
		sub	byte ptr [si+2],2
		and	byte ptr [si+2],3Fh	; '?'
		add	byte ptr [si+12h],2
		and	byte ptr [si+12h],3Fh	; '?'
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_125e,0FFh
		mov	byte ptr ds:data_126e,0FFh
		test	byte ptr ds:data_225e,0FFh
		jz	loc_504			; Jump if zero
		test	byte ptr ds:data_220e,0FFh
		jnz	loc_508			; Jump if not zero
loc_504:
		mov	si,ds:data_223e
		sub	si,24h
		call	vga_operation6
		mov	cx,13h

locloop_505:
		push	cx
		mov	cx,24h

locloop_506:
		push	cx
		test	byte ptr [si],80h
		jz	loc_507			; Jump if zero
		call	game_func_115
loc_507:
		inc	si
		pop	cx
		loop	locloop_506		; Loop if cx > 0

		call	vga_operation5
		pop	cx
		loop	locloop_505		; Loop if cx > 0

loc_508:
		mov	byte ptr ds:data_234e,0
		mov	byte ptr ds:data_246e,19h
		call	word ptr cs:data_83
		mov	byte ptr ds:data_217e,0
		call	fill_buffer
		jmp	loc_231

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_109		proc	near
		mov	si,0EB15h
		mov	cx,4
loc_509:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_510			; Jump if not zero
		retn
loc_510:
		push	cx
		call	game_func_110
		cmp	byte ptr [si+1],0FFh
		jne	loc_511			; Jump if not equal
		mov	word ptr [si],0FFFFh
		jmp	loc_516
loc_511:
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
		jnz	loc_512			; Jump if not zero
		mov	di,data_113e
loc_512:
		add	di,ax
		mov	di,[di]
		add	di,bx
		mov	ax,[si]
		call	game_func_141
		jc	loc_516			; Jump if carry Set
		mov	[si+6],bl
		mov	al,[si+2]
		sub	al,byte ptr ds:[82h]
		and	al,3Fh			; '?'
		mov	[si+7],al
		mov	bh,al
		xchg	bh,bl
		push	si
		add	si,8
		mov	bp,data_112e
		mov	cx,4

locloop_513:
		push	cx
		push	bx
		push	bp
		add	bh,ds:[bp]
		mov	al,bh
		sub	al,4
		cmp	al,1Ch
		jae	loc_515			; Jump if above or =
		inc	bp
		add	bl,ds:[bp]
		and	bl,3Fh			; '?'
		cmp	bl,12h
		jae	loc_515			; Jump if above or =
		mov	al,[di]
		push	di
		push	ax
		mov	ax,bx
		push	ax
		call	game_multiply_4
		pop	ax
		cmp	byte ptr [di],0FFh
		je	loc_514			; Jump if equal
		cmp	byte ptr [di],0FCh
		je	loc_514			; Jump if equal
		call	word ptr cs:data_77
		or	di,8000h
		mov	[si],di
		and	di,7FFFh
		pop	ax
		push	si
		call	word ptr cs:data_76
		pop	si
		pop	di
		jmp	short loc_515
loc_514:
		pop	ax
		pop	di
loc_515:
		pop	bp
		inc	si
		inc	si
		inc	di
		inc	bp
		inc	bp
		pop	bx
		pop	cx
		loop	locloop_513		; Loop if cx > 0

		pop	si
loc_516:
		add	si,10h
		pop	cx
		loop	locloop_517		; Loop if cx > 0

		jmp	short loc_ret_518

locloop_517:
		jmp	loc_509

loc_ret_518:
		retn
game_func_109		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_110		proc	near
		test	word ptr [si+8],8000h
		jz	loc_519			; Jump if zero
		and	word ptr [si+8],7FFFh
		mov	dx,[si+8]
		mov	ah,[si+6]
		mov	al,[si+7]
		push	si
		call	game_func_93
		pop	si
loc_519:
		test	word ptr [si+0Ah],8000h
		jz	loc_520			; Jump if zero
		and	word ptr [si+0Ah],7FFFh
		mov	dx,[si+0Ah]
		mov	ah,[si+6]
		inc	ah
		mov	al,[si+7]
		push	si
		call	game_func_93
		pop	si
loc_520:
		test	word ptr [si+0Ch],8000h
		jz	loc_521			; Jump if zero
		and	word ptr [si+0Ch],7FFFh
		mov	dx,[si+0Ch]
		mov	ah,[si+6]
		mov	al,[si+7]
		inc	al
		and	al,3Fh			; '?'
		push	si
		call	game_func_93
		pop	si
loc_521:
		test	word ptr [si+0Eh],8000h
		jnz	loc_522			; Jump if not zero
		retn
loc_522:
		and	word ptr [si+0Eh],7FFFh
		mov	dx,[si+0Eh]
		mov	ah,[si+6]
		inc	ah
		mov	al,[si+7]
		inc	al
		and	al,3Fh			; '?'
		push	si
		call	game_func_93
		pop	si
		retn
game_func_110		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_111		proc	near
		test	byte ptr ds:data_234e,0FFh
		jnz	$+3			; Jump if not zero
		retn
game_func_111		endp

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
loc_523:
		or	byte ptr [si+3],80h
		retn
			                        ;* No entry point to code
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ah
		jb	loc_524			; Jump if below
		jmp	loc_532
loc_524:
		call	game_func_112
		jmp	loc_536
			                        ;* No entry point to code
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ch
		jb	loc_525			; Jump if below
		jmp	loc_532
loc_525:
		cmp	byte ptr [si+4],4
		jae	loc_526			; Jump if above or =
		call	game_func_113
		jmp	short loc_527
loc_526:
		and	byte ptr [si+5],3
		inc	byte ptr [si+5]
		cmp	byte ptr [si+4],3
		je	loc_527			; Jump if equal
		mov	ax,[si]
		call	game_func_141
		jc	loc_527			; Jump if carry Set
		cmp	bl,21h			; '!'
		jae	loc_527			; Jump if above or =
		mov	ah,bl
		mov	al,[si+2]
		call	vga_operation4
		xchg	si,di
		add	si,48h
		call	vga_operation5
		xchg	si,di
		mov	al,[di]
		call	game_check_state_2
		jnz	loc_527			; Jump if not zero
		mov	al,[di+1]
		call	game_check_state_2
		jnz	loc_527			; Jump if not zero
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
loc_527:
		jmp	loc_536
			                        ;* No entry point to code
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ch
		jae	loc_530			; Jump if above or =
		mov	cx,4

locloop_528:
		push	cx
		add	byte ptr [si+2],2
		and	byte ptr [si+2],3Fh	; '?'
		call	game_scan_loop_9
		add	si,10h
		pop	cx
		loop	locloop_528		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ah
		jae	loc_531			; Jump if above or =
		mov	cx,3

locloop_529:
		push	cx
		call	game_func_112
		call	game_scan_loop_9
		add	si,10h
		pop	cx
		loop	locloop_529		; Loop if cx > 0

		retn
loc_530:
		mov	byte ptr [si+30h],0
		mov	byte ptr [si+31h],0FFh
loc_531:
		mov	byte ptr [si+20h],0
		mov	byte ptr [si+21h],0FFh
		mov	byte ptr [si+10h],0
		mov	byte ptr [si+11h],0FFh
loc_532:
		mov	byte ptr [si],0
		mov	byte ptr [si+1],0FFh
		mov	byte ptr ds:data_234e,0
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_112		proc	near
		mov	al,[si+5]
		inc	al
		cmp	al,3
		jb	loc_533			; Jump if below
		xor	al,al			; Zero register
loc_533:
		mov	[si+5],al

;���� External Entry into Subroutine ��������������������������������������

game_func_113:
		mov	ax,[si]
		mov	bl,[si+3]
		and	bx,1
		add	bx,bx
		add	bx,bx
		dec	bx
		dec	bx
		add	ax,bx
		or	ax,ax			; Zero ?
		jns	loc_534			; Jump if not sign
		add	ax,ds:data_187e
		jmp	short loc_535
loc_534:
		cmp	ax,ds:data_187e
		jb	loc_535			; Jump if below
		sub	ax,ds:data_187e
loc_535:
		mov	[si],ax
		retn
game_func_112		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_scan_loop_9		proc	near
loc_536:
		test	byte ptr ds:data_225e,0FFh
		jz	loc_537			; Jump if zero
		test	byte ptr ds:data_220e,0FFh
		stc				; Set carry flag
		jz	loc_537			; Jump if zero
		retn
loc_537:
		mov	ax,[si]
		call	game_func_141
		jnc	loc_538			; Jump if carry=0
		retn
loc_538:
		mov	ah,bl
		sub	bl,2
		cmp	bl,20h			; ' '
		cmc				; Complement carry
		jnc	loc_539			; Jump if carry=0
		retn
loc_539:
		mov	al,[si+2]
		call	vga_operation4
		push	si
		xchg	di,si
		sub	si,25h
		call	vga_operation6
		mov	byte ptr ds:data_176e,0
		mov	cx,3

locloop_540:
		push	cx
		mov	cx,3

locloop_541:
		push	cx
		call	game_func_115
		pop	cx
		inc	si
		loop	locloop_541		; Loop if cx > 0

		add	si,21h
		call	vga_operation5
		pop	cx
		loop	locloop_540		; Loop if cx > 0

		pop	si
		mov	al,ds:data_176e
		add	al,al
		cmc				; Complement carry
		retn
game_scan_loop_9		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_115		proc	near
		call	vga_operation9
		jnc	loc_542			; Jump if carry=0
		retn
loc_542:
		test	al,20h			; ' '
		jz	loc_543			; Jump if zero
		retn
loc_543:
		test	byte ptr [bx+5],20h	; ' '
		jz	loc_544			; Jump if zero
		retn
loc_544:
		mov	al,[bx+5]
		or	al,40h			; '@'
		and	al,0E0h
		mov	ah,byte ptr ds:[9Dh]
		inc	ah
		or	al,ah
		mov	[bx+5],al
		mov	byte ptr ds:data_176e,0FFh
		retn
game_func_115		endp

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

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_116		proc	near
		mov	si,ds:data_194e
		mov	al,ds:data_225e
		or	al,byte ptr ds:[0E6h]
		jz	loc_545			; Jump if zero
		jmp	word ptr cs:data_181e
loc_545:
		mov	byte ptr ds:data_244e,0
loc_546:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_547			; Jump if not equal
		retn
loc_547:
		mov	byte ptr [si+3],0FFh
		cmp	ah,0FFh
		je	loc_548			; Jump if equal
		call	game_func_141
		jc	loc_548			; Jump if carry Set
		mov	[si+3],bl
		call	game_func_117
		cmp	byte ptr [si+1],0FFh
		je	loc_548			; Jump if equal
		mov	ax,[si+2]
		call	vga_operation4
		mov	bl,ds:data_244e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_211e[bx],al
		test	byte ptr [si+4],11h
		jnz	loc_548			; Jump if not zero
		test	byte ptr [si+7],10h
		jz	loc_548			; Jump if zero
		xchg	si,di
		add	si,48h
		call	vga_operation5
		xchg	si,di
		mov	bl,ds:data_244e
		inc	bl
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_211e[bx],al
loc_548:
		test	byte ptr [si+7],20h	; ' '
		jnz	loc_550			; Jump if not zero
		mov	al,[si+0Fh]
		inc	al
		jz	loc_549			; Jump if zero
		mov	[si+0Fh],al
loc_549:
		jnz	loc_550			; Jump if not zero
		call	game_check_state_6
loc_550:
		inc	byte ptr ds:data_244e
		add	si,10h
		jmp	short loc_546
game_func_116		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_117		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		mov	al,[si+5]
		and	al,0DFh
		test	al,40h			; '@'
		jz	loc_552			; Jump if zero
		test	byte ptr [si+4],20h	; ' '
		jnz	loc_551			; Jump if not zero
		or	al,20h			; ' '
loc_551:
		and	al,0BFh
loc_552:
		mov	[si+5],al
		mov	al,ds:data_244e
		mov	bx,data_211e
		xlat				; al=[al+[bx]] table
		mov	[di],al
		test	byte ptr [si+4],11h
		jnz	loc_553			; Jump if not zero
		test	byte ptr [si+7],10h
		jz	loc_553			; Jump if zero
		xchg	si,di
		add	si,48h
		call	vga_operation5
		xchg	si,di
		mov	al,ds:data_244e
		inc	al
		xlat				; al=[al+[bx]] table
		mov	[di],al
loc_553:
		test	byte ptr [si+4],18h
		jnz	loc_554			; Jump if not zero
		jmp	word ptr cs:data_181e
loc_554:
		jmp	short $+2		; delay for I/O
		xor	bh,bh			; Zero register
		mov	bl,[si+4]
		and	bl,1Fh
		sub	bl,10h
		jnc	$+5			; Jump if carry=0
		jmp	loc_582
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
loc_555:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],4
		jae	loc_556			; Jump if above or =
		retn
loc_556:
		mov	byte ptr [si+6],0
		mov	al,[si+9]
		or	al,al			; Zero ?
		jnz	loc_557			; Jump if not zero
		jmp	loc_588
loc_557:
		test	al,10h
		jz	loc_558			; Jump if zero
		or	al,60h			; '`'
		or	byte ptr [si+7],80h
		mov	byte ptr [si+0Fh],0
loc_558:
		mov	[si+4],al
		and	byte ptr [si+5],80h
		mov	byte ptr [si+9],0
		retn
			                        ;* No entry point to code
		test	byte ptr [si+0Ah],1
		jnz	loc_562			; Jump if not zero
		mov	ah,[si+2]
		sub	ah,3
		and	ah,3Fh			; '?'
		cmp	ah,ds:data_226e
		je	loc_559			; Jump if equal
		retn
loc_559:
		mov	al,byte ptr ds:[83h]
		add	al,3
		mov	ah,byte ptr ds:[0C2h]
		and	ah,1
		add	ah,ah
		add	al,ah
		mov	cx,2

locloop_560:
		cmp	al,[si+3]
		je	loc_561			; Jump if equal
		inc	al
		loop	locloop_560		; Loop if cx > 0

		retn
loc_561:
		mov	byte ptr ds:data_246e,12h
		or	byte ptr [si+0Ah],1
		retn
loc_562:
		and	byte ptr [si+4],7Fh
		call	game_func_125
		add	byte ptr [si+6],80h
		jc	loc_563			; Jump if carry Set
		retn
loc_563:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],4
		jae	loc_564			; Jump if above or =
		retn
loc_564:
		mov	byte ptr [si+6],0
		jmp	loc_588
			                        ;* No entry point to code
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],3
		je	loc_565			; Jump if equal
		retn
loc_565:
		jmp	loc_588
			                        ;* No entry point to code
		call	game_scan_loop_10
		jnc	loc_566			; Jump if carry=0
		retn
loc_566:
		mov	byte ptr ds:data_246e,14h
		test	byte ptr [si+6],0Fh
		jnz	loc_568			; Jump if not zero
		mov	al,[si+9]
		test	al,10h
		jz	loc_567			; Jump if zero
		or	al,60h			; '`'
		or	byte ptr [si+7],80h
		mov	byte ptr [si+0Fh],0
loc_567:
		mov	[si+4],al
		mov	byte ptr [si+9],0
		retn
loc_568:
		call	game_func_119
		mov	bl,[si+6]
		and	bl,0Fh
		dec	bl
		add	bl,bl
		xor	bh,bh			; Zero register
		jmp	word ptr ds:data_114e[bx]	;*
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
loc_569:
		cmp	al,5
		jne	loc_570			; Jump if not equal
		mov	ax,0Ah
		call	game_func_120
		jmp	loc_588
loc_570:
		mov	ax,64h
		call	game_func_120
		jmp	loc_588
			                        ;* No entry point to code
		mov	dx,9A72h
		call	game_func_118
		jnc	loc_571			; Jump if carry=0
		retn
loc_571:
		inc	byte ptr ds:[98h]
		jmp	loc_588
		db	0BAh,0CBh, 9Bh,0E8h
data_72		dw	0D5h
data_73		dw	173h
data_74		dw	0FEC3h
data_75		dw	9906h
data_76		dw	0E900h
data_77		dw	144h
		db	0E8h, 85h
data_78		dw	7301h
data_79		dw	0C301h
data_80		dw	83BAh
data_81		dw	0E89Ah
data_82		dw	0E3CCh
data_83		dw	680h
data_84		dw	0C6h
data_85		dw	0E90Ah
data_86		dw	offset vga_operation
data_87		dw	offset game_func_142
		db	 02h,0E8h, 6Eh, 01h, 73h, 01h
data_88		dw	0BAC3h
data_89		dw	9A99h
		db	0E8h,0B5h,0E3h,0A1h,0B2h, 00h
		db	0D1h,0E8h,0D1h,0E8h,0D1h,0E8h
		db	 40h, 01h, 06h,0C6h, 00h,0E9h
		db	 10h, 01h,0C6h, 44h, 0Fh, 00h
		db	0F6h, 44h, 09h, 01h, 75h, 2Ah
		db	0E8h, 47h, 01h, 73h, 01h,0C3h
loc_573:
		mov	byte ptr ds:data_246e,11h
		or	byte ptr [si+7],80h
		or	byte ptr [si+9],1
		mov	byte ptr [si+0Ah],0EBh
		mov	bl,[si+6]
		add	bl,bl
		xor	bh,bh			; Zero register
		add	bx,ds:data_199e
		push	si
		mov	si,[bx]
		call	game_multiply
		pop	si
		retn
loc_574:
		test	byte ptr [si+0Ah],0FFh
		jz	loc_575			; Jump if zero
		inc	byte ptr [si+0Ah]
		retn
loc_575:
		and	byte ptr [si+9],0FEh
		retn
			                        ;* No entry point to code
		mov	dx,9AF3h
		call	game_func_118
		jnc	loc_576			; Jump if carry=0
		retn
loc_576:
		mov	byte ptr ds:[9Ch],0FFh
		jmp	loc_588
			                        ;* No entry point to code
		mov	dx,9B63h
		call	game_func_118
		jnc	loc_577			; Jump if carry=0
		retn
loc_577:
		mov	al,1
		jmp	short loc_578
			                        ;* No entry point to code
		mov	al,ds:data_195e
		sub	al,4
		mov	cl,3
		mul	cl			; ax = reg * al
		mov	di,data_115e
		add	di,ax
		mov	al,[di]
		mov	dx,[di+1]
		push	ax
		call	game_func_118
		pop	ax
		jnc	loc_578			; Jump if carry=0
		retn
loc_578:
		push	ax
		mov	di,0A1h
loc_579:
		test	byte ptr [di],0FFh
		jz	loc_580			; Jump if zero
		inc	di
		jmp	short loc_579
loc_580:
		pop	ax
		mov	[di],al
		jmp	loc_588
			                        ;* No entry point to code
		add	al,0Fh
		db	 9Bh, 02h, 47h, 9Bh, 03h, 7Fh
		db	 9Bh

;���� External Entry into Subroutine ��������������������������������������

game_func_118:
		push	dx
		call	game_func_125
		call	game_scan_loop_10
		pop	dx
		jnc	loc_581			; Jump if carry=0
		retn
loc_581:
		mov	byte ptr ds:data_246e,11h
		jmp	loc_278
loc_582:
		add	byte ptr [si+6],80h
		jc	loc_583			; Jump if carry Set
		retn
loc_583:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],3
		je	loc_584			; Jump if equal
		retn
loc_584:
		mov	byte ptr [si+0Fh],0
		test	byte ptr [si+7],40h	; '@'
		jz	loc_585			; Jump if zero
		and	byte ptr [si+7],0BFh
		mov	al,[si+0Ah]
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,ds:data_194e
		mov	di,ax
		mov	byte ptr [di+2],0
loc_585:
		test	byte ptr [si+7],10h
		jz	loc_586			; Jump if zero
		test	byte ptr [si+4],1
		jz	loc_588			; Jump if zero
loc_586:
		mov	byte ptr [si+6],0
		mov	byte ptr [si+4],72h	; 'r'
		mov	al,[si+7]
		and	al,0Fh
		jnz	loc_587			; Jump if not zero
		retn
loc_587:
		cmp	al,1
		je	loc_588			; Jump if equal
		or	al,70h			; 'p'
		or	byte ptr [si+7],80h
		mov	byte ptr [si+0Fh],4
		mov	[si+4],al
		and	byte ptr [si+5],80h
		and	byte ptr [si+7],0F0h
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_119:
loc_588:
		mov	word ptr [si],0FF00h
		test	byte ptr [si+7],20h	; ' '
		jnz	loc_589			; Jump if not zero
		retn
loc_589:
		mov	di,[si+0Bh]
;*		cmp	di,0FFFFh
		db	 83h,0FFh,0FFh		;  Fixup - byte match
		jnz	loc_590			; Jump if not zero
		retn
loc_590:
		mov	al,[si+0Dh]
		or	[di],al
		mov	word ptr [si+0Bh],0FFFFh
		retn
game_func_117		endp

			                        ;* No entry point to code
		add	word ptr ds:[86h],ax
		adc	byte ptr ds:[85h],0
		push	si
		call	word ptr cs:[2016h]
		pop	si
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_120		proc	near
		add	word ptr ds:[8Bh],ax
		jnc	loc_591			; Jump if carry=0
		mov	word ptr ds:[8Bh],0FFFFh
loc_591:
		push	si
		call	word ptr cs:[2014h]
		pop	si
		retn
game_func_120		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_scan_loop_10		proc	near
		test	byte ptr ds:[0E8h],0FFh
		stc				; Set carry flag
		jz	loc_592			; Jump if zero
		retn
loc_592:
		mov	ah,[si+2]
		add	ah,2
		mov	cx,4

locloop_593:
		dec	ah
		and	ah,3Fh			; '?'
		cmp	ah,ds:data_226e
		je	loc_594			; Jump if equal
		loop	locloop_593		; Loop if cx > 0

		and	byte ptr [si+7],7Fh
		stc				; Set carry flag
		retn
loc_594:
		mov	al,byte ptr ds:[83h]
		add	al,4
		mov	ah,[si+3]
		sub	ah,3
		mov	cx,4

locloop_595:
		inc	ah
		cmp	ah,al
		je	loc_596			; Jump if equal
		loop	locloop_595		; Loop if cx > 0

		and	byte ptr [si+7],7Fh
		stc				; Set carry flag
		retn
loc_596:
		test	byte ptr [si+7],80h
		clc				; Clear carry flag
		jnz	loc_597			; Jump if not zero
		retn
loc_597:
		inc	byte ptr [si+0Fh]
		test	byte ptr [si+0Fh],7
		jnz	loc_598			; Jump if not zero
		retn
loc_598:
		stc				; Set carry flag
		retn
game_scan_loop_10		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_122		proc	near
loc_599:
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	loc_600			; Jump if carry=0
		retn
loc_600:
		call	game_func_128
		jnc	loc_601			; Jump if carry=0
		retn
loc_601:
		jmp	loc_620
			                        ;* No entry point to code
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	loc_602			; Jump if carry=0
		retn
loc_602:
		call	game_func_134
		jnc	loc_603			; Jump if carry=0
		retn
loc_603:
		call	game_func_126
		jmp	loc_625

;���� External Entry into Subroutine ��������������������������������������

game_func_123:
loc_604:
		mov	al,[si+3]
		or	al,al			; Zero ?
		stc				; Set carry flag
		jnz	loc_605			; Jump if not zero
		retn
loc_605:
		cmp	al,23h			; '#'
		stc				; Set carry flag
		jnz	loc_606			; Jump if not zero
		retn
loc_606:
		call	game_func_132
		jnc	loc_607			; Jump if carry=0
		retn
loc_607:
		jmp	loc_625
			                        ;* No entry point to code
		cmp	byte ptr [si+3],2
		jae	loc_608			; Jump if above or =
		retn
loc_608:
		call	game_func_136
		jnc	loc_609			; Jump if carry=0
		retn
loc_609:
		call	game_func_127
		jmp	short loc_625

;���� External Entry into Subroutine ��������������������������������������

game_func_124:
loc_610:
		cmp	byte ptr [si+3],2
		jae	loc_611			; Jump if above or =
		retn
loc_611:
		call	game_func_130
		jnc	loc_612			; Jump if carry=0
		retn
loc_612:
		jmp	short loc_622
			                        ;* No entry point to code
		cmp	byte ptr [si+3],2
		jae	loc_613			; Jump if above or =
		retn
loc_613:
		call	game_func_137
		jnc	loc_614			; Jump if carry=0
		retn
loc_614:
		call	game_func_127
		jmp	short loc_624

;���� External Entry into Subroutine ��������������������������������������

game_func_125:
		mov	al,[si+3]
		or	al,al			; Zero ?
		stc				; Set carry flag
		jnz	loc_615			; Jump if not zero
		retn
loc_615:
		cmp	al,23h			; '#'
		stc				; Set carry flag
		jnz	loc_616			; Jump if not zero
		retn
loc_616:
		call	game_func_133
		jnc	loc_617			; Jump if carry=0
		retn
loc_617:
		jmp	short loc_624
			                        ;* No entry point to code
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	loc_618			; Jump if carry=0
		retn
loc_618:
		call	game_func_135
		jnc	loc_619			; Jump if carry=0
		retn
loc_619:
		call	game_func_126
		jmp	short loc_624

;���� External Entry into Subroutine ��������������������������������������

game_func_126:
loc_620:
		mov	ax,[si]
		inc	ax
		mov	bx,ax
		sub	bx,ds:data_187e
		jc	loc_621			; Jump if carry Set
		mov	ax,bx
loc_621:
		mov	[si],ax
		inc	byte ptr [si+3]
		clc				; Clear carry flag
		retn

;���� External Entry into Subroutine ��������������������������������������

game_func_127:
loc_622:
		mov	ax,[si]
		or	ax,ax			; Zero ?
		jnz	loc_623			; Jump if not zero
		mov	ax,ds:data_187e
loc_623:
		dec	ax
		mov	[si],ax
		dec	byte ptr [si+3]
		clc				; Clear carry flag
		retn
loc_624:
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		retn
loc_625:
		dec	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		retn
game_func_122		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_128		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		inc	di
		inc	di
		call	game_func_129
		jnc	loc_626			; Jump if carry=0
		retn
loc_626:
		xchg	si,di
		add	si,24h
		call	vga_operation5
		xchg	si,di
		call	game_func_129
		jnc	loc_627			; Jump if carry=0
		retn
loc_627:
		xchg	si,di
		mov	al,[si]
		sub	si,24h
		call	vga_operation6
		or	al,[si]
		sub	si,24h
		call	vga_operation6
		or	al,[si]
		xchg	si,di
		add	al,al
		retn
game_func_128		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_129		proc	near
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_628			; Jump if zero
		retn
loc_628:
		cmp	byte ptr ds:data_195e,5
		clc				; Clear carry flag
		jz	loc_629			; Jump if zero
		retn
loc_629:
		push	si
		call	game_func_63
		pop	si
		dec	cl
		clc				; Clear carry flag
		jz	loc_630			; Jump if zero
		retn
loc_630:
		stc				; Set carry flag
		retn
game_func_129		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_130		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		dec	di
		call	game_func_131
		jnc	loc_631			; Jump if carry=0
		retn
loc_631:
		xchg	si,di
		add	si,24h
		call	vga_operation5
		xchg	si,di
		call	game_func_131
		jnc	loc_632			; Jump if carry=0
		retn
loc_632:
		dec	di
		xchg	si,di
		mov	al,[si]
		sub	si,24h
		call	vga_operation6
		or	al,[si]
		sub	si,24h
		call	vga_operation6
		or	al,[si]
		xchg	si,di
		add	al,al
		retn
game_func_130		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_131		proc	near
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_633			; Jump if zero
		retn
loc_633:
		cmp	byte ptr ds:data_195e,5
		clc				; Clear carry flag
		jz	loc_634			; Jump if zero
		retn
loc_634:
		push	si
		call	game_func_63
		pop	si
		dec	cl
		dec	cl
		clc				; Clear carry flag
		jz	loc_635			; Jump if zero
		retn
loc_635:
		stc				; Set carry flag
		retn
game_func_131		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_132		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_636			; Jump if zero
		retn
loc_636:
		mov	al,[di+1]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_637			; Jump if zero
		retn
loc_637:
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		mov	al,[di+1]
		or	al,[di]
		or	al,[di-1]
		add	al,al
		retn
game_func_132		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_133		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		xchg	si,di
		add	si,48h
		call	vga_operation5
		xchg	si,di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_638			; Jump if zero
		retn
loc_638:
		mov	al,[di+1]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_639			; Jump if zero
		retn
loc_639:
		or	al,[di]
		or	al,[di-1]
		add	al,al
		retn
game_func_133		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_134		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		inc	di
		inc	di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_640			; Jump if zero
		retn
loc_640:
		mov	cl,al
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_641			; Jump if zero
		retn
loc_641:
		or	cl,al
		mov	al,[di-1]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_642			; Jump if zero
		retn
loc_642:
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		or	cl,[di]
		or	cl,[di-1]
		or	cl,[di-2]
		add	cl,cl
		retn
game_func_134		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_135		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		inc	di
		inc	di
		mov	cl,[di]
		xchg	si,di
		add	si,24h
		call	vga_operation5
		xchg	si,di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_643			; Jump if zero
		retn
loc_643:
		or	cl,al
		xchg	si,di
		add	si,24h
		call	vga_operation5
		xchg	si,di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_644			; Jump if zero
		retn
loc_644:
		or	cl,al
		mov	al,[di-1]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_645			; Jump if zero
		retn
loc_645:
		or	cl,al
		or	cl,[di-2]
		add	cl,cl
		retn
game_func_135		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_136		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		dec	di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_646			; Jump if zero
		retn
loc_646:
		dec	di
		mov	cl,[di]
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		or	cl,[di]
		mov	al,[di+1]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_647			; Jump if zero
		retn
loc_647:
		mov	al,[di+2]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_648			; Jump if zero
		retn
loc_648:
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		or	cl,[di+2]
		or	cl,[di+1]
		or	cl,[di]
		add	cl,cl
		retn
game_func_136		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_137		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		dec	di
		dec	di
		mov	cl,[di]
		xchg	si,di
		add	si,24h
		call	vga_operation5
		xchg	si,di
		or	cl,[di]
		inc	di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_649			; Jump if zero
		retn
loc_649:
		xchg	si,di
		add	si,24h
		call	vga_operation5
		xchg	si,di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_650			; Jump if zero
		retn
loc_650:
		or	cl,al
		mov	al,[di+1]
		call	game_func_138
		stc				; Set carry flag
		jz	loc_651			; Jump if zero
		retn
loc_651:
		or	cl,al
		or	cl,[di-1]
		add	cl,cl
		retn
game_func_137		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_138		proc	near
		cmp	al,49h			; 'I'
		jb	loc_653			; Jump if below
		or	al,al			; Zero ?
		jns	loc_652			; Jump if not sign
		retn
loc_652:
		cmp	al,al
		retn
loc_653:
		push	di
		push	cx
		mov	es,cs:data_219e
		mov	di,data_1e
		mov	cx,18h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		pop	cx
		pop	di
		retn
game_func_138		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_check_state_6		proc	near
		cmp	byte ptr [si+1],0FFh
		je	loc_654			; Jump if equal
		retn
loc_654:
		test	byte ptr [si+7],10h
		jz	loc_655			; Jump if zero
		cmp	byte ptr [si+11h],0FFh
		je	loc_655			; Jump if equal
		retn
loc_655:
		mov	ax,[si+0Bh]
		cmp	ax,0FFFFh
		jne	loc_656			; Jump if not equal
		retn
loc_656:
		call	game_func_141
		jnc	loc_657			; Jump if carry=0
		retn
loc_657:
		or	bl,bl			; Zero ?
		jnz	loc_658			; Jump if not zero
		retn
loc_658:
		cmp	bl,23h			; '#'
		jne	loc_659			; Jump if not equal
		retn
loc_659:
		mov	al,byte ptr ds:[82h]
		sub	al,2
		and	al,3Fh			; '?'
		sub	al,[si+0Dh]
		neg	al
		and	al,3Fh			; '?'
		cmp	al,18h
		jae	loc_660			; Jump if above or =
		cmp	bl,3
		jb	loc_660			; Jump if below
		cmp	bl,20h			; ' '
		jae	loc_660			; Jump if above or =
		retn
loc_660:
		test	byte ptr [si+7],10h
		jnz	loc_663			; Jump if not zero
		mov	[si+3],bl
		mov	al,[si+0Dh]
		mov	ah,bl
		call	vga_operation4
		push	di
		xchg	si,di
		sub	si,25h
		call	vga_operation6
		xor	al,al			; Zero register
		mov	cx,3

locloop_661:
		or	al,[si]
		or	al,[si+1]
		or	al,[si+2]
		add	si,24h
		call	vga_operation5
		loop	locloop_661		; Loop if cx > 0

		xchg	si,di
		pop	di
		or	al,al			; Zero ?
		jns	loc_662			; Jump if not sign
		retn
loc_662:
		mov	al,ds:data_244e
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
		mov	bl,ds:data_244e
		xor	bh,bh			; Zero register
		mov	byte ptr ds:data_211e[bx],0
		retn
loc_663:
		test	byte ptr [si+0Eh],1
		jz	loc_664			; Jump if zero
		retn
loc_664:
		mov	[si+3],bl
		mov	[si+13h],bl
		mov	al,[si+0Dh]
		mov	ah,bl
		call	vga_operation4
		push	di
		xchg	si,di
		sub	si,25h
		call	vga_operation6
		xor	al,al			; Zero register
		mov	cx,5

locloop_665:
		or	al,[si]
		or	al,[si+1]
		or	al,[si+2]
		add	si,24h
		call	vga_operation5
		loop	locloop_665		; Loop if cx > 0

		xchg	si,di
		pop	di
		or	al,al			; Zero ?
		jns	loc_666			; Jump if not sign
		retn
loc_666:
		mov	al,ds:data_244e
		or	al,80h
		mov	[di],al
		xchg	si,di
		add	si,48h
		call	vga_operation5
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
		mov	bl,ds:data_244e
		xor	bh,bh			; Zero register
		mov	word ptr ds:data_211e[bx],0
		retn
game_check_state_6		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

clear_buffer		proc	near
		push	cs
		pop	es
		mov	di,data_211e
		mov	cx,80h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		jmp	short $+2		; delay for I/O
		mov	byte ptr ds:data_244e,0
		mov	si,ds:data_194e
loc_667:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_668			; Jump if not equal
		retn
loc_668:
		cmp	ah,0FFh
		je	loc_669			; Jump if equal
		mov	byte ptr [si+3],0FFh
		call	game_func_141
		jc	loc_669			; Jump if carry Set
		mov	[si+3],bl
		mov	al,[si+2]
		mov	ah,bl
		call	vga_operation4
		mov	al,ds:data_244e
		or	al,80h
		mov	[di],al
loc_669:
		inc	byte ptr ds:data_244e
		add	si,10h
		jmp	short loc_667
clear_buffer		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_141		proc	near
		mov	bx,ax
		sub	ax,word ptr ds:[80h]
		jnc	loc_671			; Jump if carry=0
		mov	ax,23h
		sub	ax,bx
		jnc	loc_670			; Jump if carry=0
		retn
loc_670:
		mov	ax,ds:data_187e
		sub	ax,word ptr ds:[80h]
		add	ax,bx
loc_671:
		xchg	bx,ax
		mov	ax,23h
		sub	ax,bx
		retn
game_func_141		endp

loc_672:
		mov	al,[si+4]
		test	al,10h
		jnz	loc_673			; Jump if not zero
		and	al,0Fh
		mov	bx,data_184e
		xlat				; al=[al+[bx]] table
		xor	ah,ah			; Zero register
		call	game_func_143
		jmp	short loc_673
loc_673:
		mov	byte ptr [si+6],0
		or	byte ptr [si+4],68h	; 'h'
		and	byte ptr [si+5],80h
		test	byte ptr [si+7],10h
		jz	loc_674			; Jump if zero
		test	byte ptr [si+4],1
		jnz	loc_674			; Jump if not zero
		mov	byte ptr [si+6],80h
		mov	byte ptr [si+16h],0
		or	byte ptr [si+14h],68h	; 'h'
		and	byte ptr [si+15h],80h
loc_674:
		mov	al,[si+2]
		mov	ah,byte ptr ds:[82h]
		dec	ah
		sub	al,ah
		and	al,3Fh			; '?'
		cmp	al,13h
		jb	loc_675			; Jump if below
		retn
loc_675:
		mov	byte ptr ds:data_246e,7
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_func_143		proc	near
		add	word ptr ds:[8Eh],ax
		jc	loc_676			; Jump if carry Set
		retn
loc_676:
		mov	word ptr ds:[8Eh],0FFFFh
		retn
game_func_143		endp

			                        ;* No entry point to code
		and	al,7
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_119e[bx]	;*
			                        ;* No entry point to code
		in	ax,91h			; port 91h ??I/O Non-standard
		not	byte ptr ds:data_117e[bx+di]
		and	dl,ss:data_118e[bp+si]
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

locloop_677:
		push	cx
		push	si
		mov	al,[di]
		call	game_func_63
		mov	bl,cl
		pop	si
		pop	cx
		jz	loc_678			; Jump if zero
		inc	di
		loop	locloop_677		; Loop if cx > 0

		retn
loc_678:
		pop	ax
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_120e[bx]	;*
			                        ;* No entry point to code
;*		call	far ptr game_func_155		;*
		db	9Ah
		dw	9497h, 8E97h		;  Fixup - byte match
		xchg	di,ax
		call	game_func_122
		jmp	loc_599
			                        ;* No entry point to code
		call	game_func_124
		jmp	loc_610
			                        ;* No entry point to code
		call	game_func_123
		jmp	loc_604
			                        ;* No entry point to code
		mov	ax,[si+2]
		call	vga_operation4
		xchg	si,di
		add	si,48h
		call	vga_operation5
		xchg	si,di
		mov	al,[di]
		jmp	loc_274
			                        ;* No entry point to code
		mov	al,[si+5]
		and	al,1Fh
		call	game_multiply_5
		mov	al,[si+8]
		sub	al,ah
		jbe	loc_679			; Jump if below or =
		mov	[si+8],al
		mov	byte ptr ds:data_246e,6
		retn
loc_679:
		test	byte ptr [si+4],1
		jnz	loc_680			; Jump if not zero
		test	byte ptr [si+7],10h
		jnz	loc_683			; Jump if not zero
loc_680:
		test	byte ptr [si+7],0Fh
		jz	loc_681			; Jump if zero
		jmp	loc_672
loc_681:
		mov	di,ds:data_183e
		mov	bl,[si+4]
		and	bl,7
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	di,[bx+di]
		call	word ptr cs:[11Ah]
		mov	bl,al
		and	bx,3
		cmp	byte ptr ds:data_241e,2
		jne	loc_682			; Jump if not equal
		xor	bx,bx			; Zero register
loc_682:
		mov	al,[bx+di]
		mov	ah,[si+7]
		and	ah,0F0h
		or	al,ah
		mov	[si+7],al
		jmp	loc_672
loc_683:
		test	byte ptr [si+17h],0Fh
		jz	loc_684			; Jump if zero
		jmp	loc_672
loc_684:
		mov	di,ds:data_183e
		mov	bl,[si+4]
		and	bl,7
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	di,[bx+di]
		call	word ptr cs:[11Ah]
		mov	bl,al
		and	bx,3
		cmp	byte ptr ds:data_241e,2
		jne	loc_685			; Jump if not equal
		xor	bx,bx			; Zero register
loc_685:
		mov	al,[bx+di]
		mov	ah,[si+17h]
		and	ah,0F0h
		or	al,ah
		mov	[si+17h],al
		jmp	loc_672

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

game_multiply_5		proc	near
		mov	ah,byte ptr ds:[8Dh]
		shr	ah,1			; Shift w/zeros fill
		inc	ah
		or	al,al			; Zero ?
		jnz	loc_686			; Jump if not zero
		retn
loc_686:
		cmp	al,1
		je	loc_690			; Jump if equal
		mov	ah,byte ptr ds:[8Dh]
		inc	ah
		add	ah,ah
		jc	loc_687			; Jump if carry Set
		add	ah,ah
		jnc	loc_688			; Jump if carry=0
loc_687:
		mov	ah,0FFh
loc_688:
		cmp	al,9
		jne	loc_689			; Jump if not equal
		retn
loc_689:
		sub	al,2
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	ah,ds:data_122e[bx]
		retn
loc_690:
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,ds:data_121e[bx]
		mov	bl,byte ptr ds:[8Dh]
		shr	bl,1			; Shift w/zeros fill
		add	al,bl
		jc	loc_691			; Jump if carry Set
		mov	cl,byte ptr ds:[0E4h]
		inc	cl
		mul	cl			; ax = reg * al
		or	ah,ah			; Zero ?
		jz	loc_692			; Jump if zero
loc_691:
		mov	al,0FFh
loc_692:
		mov	ah,al
		cmp	byte ptr ds:data_241e,2
		je	loc_693			; Jump if equal
		retn
loc_693:
		add	ah,ah
		jc	loc_694			; Jump if carry Set
		retn
loc_694:
		mov	ah,0FFh
		retn
game_multiply_5		endp

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
loc_695:
;*		cmp	word ptr [di],0FFFFh
		db	 83h, 3Dh,0FFh		;  Fixup - byte match
		stc				; Set carry flag
		jnz	loc_696			; Jump if not zero
		retn
loc_696:
;*		cmp	word ptr [di+0Bh],0FFFFh
		db	 83h, 7Dh, 0Bh,0FFh	;  Fixup - byte match
		jnz	loc_697			; Jump if not zero
		cmp	byte ptr [di+1],0FFh
		je	loc_698			; Jump if equal
		mov	ax,[di]
		push	dx
		call	game_func_141
		pop	dx
		jnc	loc_697			; Jump if carry=0
		test	byte ptr [di+4],10h
		jz	loc_699			; Jump if zero
loc_697:
		inc	dl
		add	di,10h
		jmp	short loc_695
loc_698:
		cmp	byte ptr [di+2],7Fh
		je	loc_697			; Jump if equal
loc_699:
		clc				; Clear carry flag
		retn
loc_700:
		call	word ptr cs:data_74
		mov	byte ptr ds:data_239e,0
		mov	byte ptr ds:data_233e,0
		mov	byte ptr ds:data_229e,0
		mov	byte ptr ds:data_227e,0
		mov	byte ptr ds:[0E8h],0FFh
		mov	byte ptr ds:data_174e,0
		mov	byte ptr ds:data_175e,0
		call	word ptr cs:[2008h]
		mov	byte ptr ds:[0E7h],0
		mov	byte ptr ds:data_230e,0
		mov	byte ptr ds:data_228e,0
		call	game_check_state_3
		mov	ax,9929h
		push	ax
		call	game_func_20
		pop	ax
		mov	byte ptr ds:data_228e,0
loc_701:
		call	game_check_state_3
		mov	byte ptr ds:data_228e,0
		cmp	byte ptr ds:[0E7h],2
		je	loc_702			; Jump if equal
		inc	byte ptr ds:data_174e
		test	byte ptr ds:data_174e,7
		jnz	loc_701			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		inc	al
		and	al,3
		cmp	al,3
		je	loc_701			; Jump if equal
		mov	byte ptr ds:[0E7h],al
		jmp	short loc_701
loc_702:
		inc	byte ptr ds:data_175e
		test	byte ptr ds:data_175e,0Fh
		jz	loc_703			; Jump if zero
		test	byte ptr ds:data_175e,1
		jz	loc_701			; Jump if zero
		mov	byte ptr ds:data_228e,0FFh
		jmp	short loc_701
loc_703:
		mov	byte ptr ds:data_218e,8
		mov	cx,1Eh

locloop_704:
		push	cx
		call	game_check_state_3
		pop	cx
		mov	al,cl
		and	al,1
		dec	al
		mov	ds:data_228e,al
		loop	locloop_704		; Loop if cx > 0

		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		call	word ptr cs:[2040h]
		test	byte ptr ds:[49h],0FFh
		jz	loc_705			; Jump if zero
		mov	byte ptr ds:[0C5h],80h
		jmp	short loc_706
loc_705:
		mov	al,byte ptr ds:[8Dh]
		add	al,al
		neg	al
		add	al,7Fh
		xor	ah,ah			; Zero register
		call	game_func_143
		mov	byte ptr ds:[85h],0
		mov	word ptr ds:[86h],0
		shr	word ptr ds:[8Bh],1	; Shift w/zeros fill
loc_706:
		mov	ax,word ptr ds:[0B2h]
		mov	word ptr ds:[90h],ax
		jmp	short loc_707
loc_707:
		mov	byte ptr ds:data_213e,0
		mov	ah,byte ptr ds:[0C5h]
		mov	byte ptr ds:[0C4h],ah
		mov	al,1
		call	word ptr cs:[10Ch]
		mov	ax,ds:data_196e
		mov	ds:data_161e,ax
		mov	si,ds:data_186e
		inc	si
		lodsb				; String [si] to al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,9C2Dh
		mov	si,ax
		mov	es,cs:data_219e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	bx,6002h
		jmp	loc_366
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
data_90		dw	0FF2Eh			; Data table (indexed access)
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
