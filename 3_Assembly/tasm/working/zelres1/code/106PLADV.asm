
PAGE  59,132

;==========================================================================
;
;  PLAYER_ADVANCED - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	4100h			;*
data_2e		equ	8002h			;*
data_3e		equ	0C000h			;*
data_47e	equ	2000h			;*
data_48e	equ	2002h			;*
data_49e	equ	2004h			;*
data_50e	equ	2006h			;*
data_51e	equ	2008h			;*
data_52e	equ	200Eh			;*
data_53e	equ	2010h			;*
data_54e	equ	2012h			;*
data_55e	equ	2014h			;*
data_56e	equ	2016h			;*
data_57e	equ	2018h			;*
data_58e	equ	201Ah			;*
data_59e	equ	2022h			;*
data_60e	equ	2024h			;*
data_61e	equ	2026h			;*
data_62e	equ	2028h			;*
data_63e	equ	202Ah			;*
data_64e	equ	2038h			;*
data_65e	equ	2040h			;*
data_66e	equ	2042h			;*
data_67e	equ	278Bh			;*
data_68e	equ	3002h			;*
data_69e	equ	3004h			;*
data_70e	equ	3006h			;*
data_71e	equ	3008h			;*
data_72e	equ	300Ah			;*
data_73e	equ	300Ch			;*
data_74e	equ	300Eh			;*
data_75e	equ	3010h			;*
data_76e	equ	3012h			;*
data_77e	equ	3014h			;*
data_78e	equ	3018h			;*
data_79e	equ	301Ah			;*
data_80e	equ	301Ch			;*
data_81e	equ	301Eh			;*
data_82e	equ	3020h			;*
data_83e	equ	3024h			;*
data_84e	equ	3026h			;*
data_85e	equ	481Ch			;*
data_86e	equ	4D4Dh			;*
data_87e	equ	534Dh			;*
data_88e	equ	6014h			;*
data_89e	equ	6018h			;*
data_90e	equ	601Ah			;*
data_91e	equ	6A59h			;*
data_92e	equ	6AEBh			;*
data_93e	equ	6C93h			;*
data_94e	equ	6C9Bh			;*
data_95e	equ	6CA4h			;*
data_96e	equ	6CACh			;*
data_97e	equ	6D88h			;*
data_98e	equ	6FEDh			;*
data_99e	equ	77BAh			;*
data_100e	equ	7B82h			;*
data_101e	equ	7BE2h			;*
data_102e	equ	7C42h			;*
data_103e	equ	7C43h			;*
data_104e	equ	7C44h			;*
data_105e	equ	7C45h			;*
data_106e	equ	7C46h			;*
data_107e	equ	7C47h			;*
data_108e	equ	7C49h			;*
data_109e	equ	7C4Bh			;*
data_110e	equ	7C4Ch			;*
data_111e	equ	7C4Eh			;*
data_112e	equ	7C50h			;*
data_113e	equ	7C52h			;*
data_114e	equ	7C53h			;*
data_115e	equ	7C54h			;*
data_116e	equ	7C55h			;*
data_117e	equ	7C56h			;*
data_118e	equ	7C57h			;*
data_119e	equ	7C58h			;*
data_120e	equ	7C5Ah			;*
data_121e	equ	7C5Ch			;*
data_122e	equ	7C5Dh			;*
data_123e	equ	7C5Eh			;*
data_124e	equ	7C5Fh			;*
data_125e	equ	7C60h			;*
data_126e	equ	7C62h			;*
data_127e	equ	7C63h			;*
data_128e	equ	7C64h			;*
data_129e	equ	7C67h			;*
data_130e	equ	7C6Eh			;*
data_131e	equ	7C74h			;*
data_132e	equ	7C7Ah			;*
data_133e	equ	0A000h			;*
data_134e	equ	0A002h			;*
data_135e	equ	0A004h			;*
data_136e	equ	0C000h			;*
data_137e	equ	0C002h			;*
data_138e	equ	0C004h			;*
data_139e	equ	0C007h			;*
data_140e	equ	0C009h			;*
data_141e	equ	0C00Dh			;*
data_142e	equ	0C00Fh			;*
data_143e	equ	0C011h			;*
data_144e	equ	0C015h			;*
data_145e	equ	0C01Ch			;*
data_146e	equ	0E000h			;*
data_147e	equ	0E001h			;*
data_148e	equ	0E1FDh			;*
data_149e	equ	0E1FFh			;*
data_150e	equ	0F605h			;*
data_151e	equ	0FF00h			;*
data_152e	equ	0FF18h			;*
data_153e	equ	0FF1Ah			;*
data_154e	equ	0FF1Dh			;*
data_155e	equ	0FF1Eh			;*
data_156e	equ	0FF24h			;*
data_157e	equ	0FF26h			;*
data_158e	equ	0FF29h			;*
data_159e	equ	0FF2Ah			;*
data_160e	equ	0FF2Ch			;*
data_161e	equ	0FF33h			;*
data_162e	equ	0FF4Ch			;*
data_163e	equ	0FF4Eh			;*
data_164e	equ	0FF4Fh			;*
data_165e	equ	0FF52h			;*
data_166e	equ	0FF53h			;*
data_167e	equ	0FF54h			;*
data_168e	equ	0FF56h			;*
data_169e	equ	0FF57h			;*
data_170e	equ	0FF58h			;*
data_171e	equ	0FF6Ah			;*
data_172e	equ	0FF6Ch			;*
data_173e	equ	0FF74h			;*
data_174e	equ	0FF75h			;*
data_175e	equ	0FF78h			;*
data_176e	equ	49h
data_177e	equ	83h
data_178e	equ	0C2h
data_179e	equ	6AE9h
data_180e	equ	7686h
data_181e	equ	77BAh
data_182e	equ	7B82h
data_183e	equ	7BE2h
data_184e	equ	7C42h
data_185e	equ	7C44h
data_186e	equ	7C47h
data_187e	equ	7C4Bh
data_188e	equ	7C4Ch
data_189e	equ	7C4Eh
data_190e	equ	7C52h
data_191e	equ	7C53h
data_192e	equ	7C54h
data_193e	equ	7C56h
data_194e	equ	7C57h
data_195e	equ	7C58h
data_196e	equ	7C5Ah
data_197e	equ	7C5Ch
data_198e	equ	7C5Dh
data_199e	equ	7C5Eh
data_200e	equ	7C5Fh
data_201e	equ	7C60h
data_202e	equ	7C62h
data_203e	equ	7C63h
data_204e	equ	7C67h
data_205e	equ	7C74h
data_206e	equ	0A000h
data_207e	equ	0C007h
data_208e	equ	0FF14h
data_209e	equ	0FF17h
data_210e	equ	0FF18h
data_211e	equ	0FF1Ah
data_212e	equ	0FF1Dh
data_213e	equ	0FF1Eh
data_214e	equ	0FF29h
data_215e	equ	0FF4Ch
data_216e	equ	0FF52h
data_217e	equ	0FF53h
data_218e	equ	0FF54h
data_219e	equ	0FF56h
data_220e	equ	0FF58h
data_221e	equ	0FF6Ah
data_222e	equ	0FF74h
data_223e	equ	0FF75h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_06		proc	far

start:
		jge	loc_1			; Jump if > or =
		add	[bx+si],al
		db	 26h, 60h
data_5		db	1Eh
		db	 60h, 6Ch, 70h,0C7h, 72h,0D3h
		db	 74h, 70h, 75h, 89h, 75h, 1Ah
		db	'uDs9uitBp{t'
loc_1:
		cmpsw				; Cmp [si] to es:[di]
		jz	$-6Ch			; Jump if zero
		jnz	loc_4			; Jump if not zero
		mov	byte ptr ds:data_103e,0FFh
		jmp	short loc_3
			                        ;* No entry point to code
		mov	byte ptr cs:data_103e,0
loc_3:
		mov	ds,cs:data_160e
		mov	si,4100h
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,7000h
		mov	cx,0A4h
		call	word ptr cs:data_84e
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		push	cs
		pop	ds
loc_4:
		call	player_func_33
		mov	byte ptr ds:[0E7h],0
		test	byte ptr ds:[49h],0FFh
		jz	loc_5			; Jump if zero
		mov	byte ptr ds:[0E8h],0
loc_5:
		call	word ptr cs:data_48e
		mov	si,ds:data_136e
		inc	si
loc_6:
		lodsb				; String [si] to al
		inc	al
		jnz	loc_6			; Jump if not zero
		lodsb				; String [si] to al
		mov	ds:data_105e,al
		lodsb				; String [si] to al
		mov	ds:data_106e,al
		mov	byte ptr ds:data_104e,0
		test	byte ptr ds:[0E8h],0FFh
		jnz	loc_8			; Jump if not zero
		test	byte ptr ds:data_105e,1
		jz	loc_7			; Jump if zero
		test	byte ptr ds:data_103e,0FFh
		jnz	loc_7			; Jump if not zero
		mov	byte ptr ds:data_104e,0FFh
loc_7:
		call	player_load_chunk
		call	player_func_22
		call	word ptr cs:data_68e
		test	byte ptr ds:[49h],0FFh
		jnz	loc_8			; Jump if not zero
		push	ds
		mov	ds,cs:data_160e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
loc_8:
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		push	cs
		pop	ds
		call	player_func_25
		xor	al,al			; Zero register
		mov	ds:data_154e,al
		mov	ds:data_155e,al
		mov	byte ptr ds:[0E4h],al
		mov	byte ptr ds:[9Fh],al
		mov	bx,204h
		xor	al,al			; Zero register
		mov	ch,21h			; '!'
		call	word ptr cs:data_49e
		mov	bx,21Ch
		xor	al,al			; Zero register
		mov	ch,42h			; 'B'
		call	word ptr cs:data_49e
		mov	bx,data_85e
		xor	al,al			; Zero register
		mov	ch,42h			; 'B'
		call	word ptr cs:data_49e
		call	word ptr cs:data_54e
		call	player_func_29
		call	word ptr cs:data_50e
		call	word ptr cs:data_51e
		call	word ptr cs:data_55e
		call	word ptr cs:data_56e
		test	byte ptr ds:[9Dh],0FFh
		jz	loc_9			; Jump if zero
		mov	bx,0AA1Ch
		xor	al,al			; Zero register
		mov	ch,17h
		call	word ptr cs:data_49e
		call	word ptr cs:data_57e
loc_9:
		test	byte ptr ds:[93h],0FFh
		jz	loc_10			; Jump if zero
		mov	bx,0C61Ch
		xor	al,al			; Zero register
		mov	ch,17h
		call	word ptr cs:data_49e
		call	word ptr cs:data_58e
loc_10:
		mov	si,ds:data_136e
		inc	si
loc_11:
		lodsb				; String [si] to al
		inc	al
		jnz	loc_11			; Jump if not zero
		inc	si
		lodsb				; String [si] to al
		mov	ds:data_106e,al
		mov	si,ds:data_138e
		call	word ptr cs:data_53e
		mov	al,byte ptr ds:[80h]
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,0C017h
		mov	ds:data_159e,ax
		call	player_func_27
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_12			; Jump if zero
		mov	byte ptr ds:[0E8h],0
		call	player_load_chunk
		mov	bx,61FCh
		push	bx
		mov	bx,6EAFh
		push	bx
		mov	si,6F23h
		push	cs
		pop	es
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		call	word ptr cs:data_65e
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:data_102e,0FFh
		jmp	word ptr cs:data_135e
loc_12:
		push	cs
		pop	es
		mov	al,0FEh
		mov	di,data_146e
		mov	cx,0E0h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		call	player_multiply_2
		test	byte ptr ds:data_185e,0FFh
		jz	loc_15			; Jump if zero
		mov	word ptr ds:data_186e,6781h
		test	byte ptr ds:data_178e,1
		jnz	loc_13			; Jump if not zero
		mov	word ptr ds:data_186e,67F4h
loc_13:
		mov	cx,4

locloop_14:
		push	cx
		call	word ptr cs:data_107e
		call	player_multiply_2
		pop	cx
		loop	locloop_14		; Loop if cx > 0

		call	word ptr cs:data_107e
loc_15:
		mov	byte ptr ds:data_187e,0
		test	byte ptr ds:data_176e,0FFh
		jz	loc_16			; Jump if zero
		push	ds
		mov	ds,cs:data_160e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
loc_16:
		call	player_multiply_2
		call	fill_buffer
		call	player_func_30
		call	player_func_1
		test	byte ptr ds:data_109e,0FFh
		jnz	loc_17			; Jump if not zero
		call	player_func_2
loc_17:
		mov	byte ptr ds:data_109e,0
		mov	dx,61FCh
		push	dx
		int	61h			; ??INT Non-standard interrupt
		cmp	al,1
		jne	loc_18			; Jump if not equal
		jmp	loc_151
loc_18:
		and	al,0Ch
		cmp	al,4
		jne	loc_19			; Jump if not equal
		jmp	loc_86
loc_19:
		cmp	al,8
		jne	loc_20			; Jump if not equal
		jmp	loc_92
loc_20:
		or	byte ptr ds:[0E7h],1
		mov	byte ptr ds:data_109e,0FFh
		retn

zr1_06		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_1		proc	near
		test	byte ptr ds:data_154e,0FFh
		jnz	loc_21			; Jump if not zero
		retn
loc_21:
		mov	byte ptr ds:data_154e,0
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		xor	bh,bh			; Zero register
		mov	dx,bx
		add	dx,word ptr ds:[80h]
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,5
		add	bx,ds:data_159e
		test	byte ptr ds:[0C2h],1
		jnz	loc_24			; Jump if not zero
		inc	dx
		cmp	byte ptr [bx+8],0FDh
		je	loc_22			; Jump if equal
		inc	dx
		cmp	byte ptr [bx+10h],0FDh
		je	loc_22			; Jump if equal
		inc	dx
		cmp	byte ptr [bx+18h],0FDh
		je	loc_22			; Jump if equal
		retn
loc_22:
		call	player_func_20
		mov	al,[si+6]
		and	al,0C0h
		jz	loc_23			; Jump if zero
		retn
loc_23:
		mov	al,[si+2]
		mov	ah,[si+5]
		push	ax
		mov	byte ptr [si+5],7
		or	byte ptr [si+2],80h
		or	byte ptr [si+4],1
		call	player_func_3
		pop	ax
		mov	[si+5],ah
		mov	[si+2],al
		retn
loc_24:
		dec	dx
		cmp	byte ptr [bx-8],0FDh
		je	loc_25			; Jump if equal
		dec	dx
		cmp	byte ptr [bx-10h],0FDh
		je	loc_25			; Jump if equal
		dec	dx
		cmp	byte ptr [bx-18h],0FDh
		je	loc_25			; Jump if equal
		retn
loc_25:
		call	player_func_20
		mov	al,[si+6]
		and	al,0C0h
		jz	loc_26			; Jump if zero
		retn
loc_26:
		mov	al,[si+2]
		mov	ah,[si+5]
		push	ax
		mov	byte ptr [si+5],7
		and	byte ptr [si+2],7Fh
		or	byte ptr [si+4],1
		call	player_func_3
		pop	ax
		mov	[si+5],ah
		mov	[si+2],al
		retn
player_func_1		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_2		proc	near
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		xor	bh,bh			; Zero register
		mov	dx,bx
		add	dx,word ptr ds:[80h]
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,5
		add	bx,ds:data_159e
		test	byte ptr ds:[0C2h],1
		jnz	loc_30			; Jump if not zero
		inc	dx
		inc	dx
		cmp	byte ptr [bx+10h],0FDh
		je	loc_27			; Jump if equal
		retn
loc_27:
		call	player_func_20
		test	byte ptr [si+2],80h
		jnz	loc_28			; Jump if not zero
		retn
loc_28:
		test	byte ptr [si+6],80h
		jnz	loc_29			; Jump if not zero
		retn
loc_29:
		or	byte ptr [si+4],1
		mov	byte ptr ds:data_121e,0FFh
		jmp	short loc_34
loc_30:
		dec	dx
		dec	dx
		cmp	byte ptr [bx-10h],0FDh
		je	loc_31			; Jump if equal
		retn
loc_31:
		call	player_func_20
		test	byte ptr [si+2],80h
		jz	loc_32			; Jump if zero
		retn
loc_32:
		test	byte ptr [si+6],80h
		jnz	loc_33			; Jump if not zero
		retn
loc_33:
		or	byte ptr [si+4],1
		mov	byte ptr ds:data_121e,0FFh
		jmp	short loc_34

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_3:
loc_34:
		and	byte ptr [si+6],7Fh
		mov	al,[si+7]
		push	si
		push	ax
		mov	byte ptr ds:data_153e,28h	; '('
		call	player_func_14
		mov	byte ptr ds:data_174e,1Eh
		mov	ax,718h
		test	byte ptr ds:[0C2h],1
		jnz	loc_35			; Jump if not zero
		mov	ax,0B18h
loc_35:
		mov	ds:data_110e,ax
		xor	di,di			; Zero register
		mov	cx,1658h
		call	word ptr cs:data_61e
		mov	byte ptr ds:data_154e,0
		pop	bx
		mov	ax,ds:data_110e
		call	player_multiply
		mov	ax,ds:data_188e
		xor	di,di			; Zero register
		mov	cx,1658h
		call	word ptr cs:data_62e
		pop	si
		mov	byte ptr ds:data_212e,0
		push	cs
		pop	es
		mov	al,0FEh
		mov	di,data_146e
		mov	cx,0E0h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	byte ptr ds:data_197e,0
		mov	byte ptr ds:data_212e,0
		mov	byte ptr ds:data_213e,0
		retn
player_func_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_multiply		proc	near
loc_36:
		or	byte ptr ds:[0E7h],1

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_5:
		mov	ds:data_112e,ax
		mov	ds:data_111e,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,ds:data_141e
		mov	si,[bx]
		mov	byte ptr ds:data_114e,0
		mov	byte ptr ds:data_115e,0
		mov	byte ptr ds:data_116e,0
		mov	byte ptr ds:data_118e,0
		mov	ds:data_119e,si
		call	player_func_8
		mov	al,cl
		mov	ds:data_117e,al
		cmp	al,8
		jb	loc_37			; Jump if below
		mov	al,8
loc_37:
		push	ax
		mov	cl,0Ah
		mul	cl			; ax = reg * al
		add	al,6
		mov	cl,al
		mov	ch,2Ch			; ','
		mov	ds:data_120e,cx
		mov	al,56h			; 'V'
		sub	al,cl
		mov	bx,ds:data_111e
		add	bl,al
		pop	ax
		and	al,0FEh
		add	al,al
		add	al,al
		add	al,al
		mov	ah,40h			; '@'
		sub	ah,al
		shr	ah,1			; Shift w/zeros fill
		sub	bl,ah
		mov	ds:data_111e,bx
		add	bh,bh
		mov	al,0FFh
		call	word ptr cs:data_47e
loc_38:
		mov	si,ds:data_195e
		lodsb				; String [si] to al
		mov	ds:data_195e,si
		cmp	al,2Fh			; '/'
		jne	loc_39			; Jump if not equal
		jmp	loc_48
loc_39:
		cmp	al,81h
		jne	loc_40			; Jump if not equal
		jmp	loc_71
loc_40:
		cmp	al,83h
		jne	loc_41			; Jump if not equal
		jmp	loc_73
loc_41:
		cmp	al,85h
		jne	loc_42			; Jump if not equal
		jmp	loc_74
loc_42:
		cmp	al,87h
		jne	loc_43			; Jump if not equal
		jmp	loc_75
loc_43:
		cmp	al,89h
		jne	loc_44			; Jump if not equal
		jmp	loc_76
loc_44:
		cmp	al,8Bh
		jne	loc_45			; Jump if not equal
		jmp	loc_70
loc_45:
		cmp	al,0FFh
		jne	loc_46			; Jump if not equal
		jmp	loc_55
loc_46:
		push	ax
		mov	cx,ds:data_189e
		xor	bh,bh			; Zero register
		mov	bl,ch
		add	bx,bx
		add	bx,bx
		add	bx,bx
		mov	al,ds:data_191e
		xor	ah,ah			; Zero register
		add	bx,ax
		add	bx,4
		mov	al,ds:data_192e
		mov	dl,0Ah
		mul	dl			; ax = reg * al
		add	cl,al
		add	cl,4
		pop	ax
		push	bx
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	dl,ds:data_182e[bx]
		mov	dh,bh
		pop	bx
		push	ax
		sub	bx,dx
		mov	ah,1
		call	word ptr cs:data_59e
		pop	ax
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	cl,ds:data_183e[bx]
		add	ds:data_191e,cl
		cmp	al,20h			; ' '
		je	loc_47			; Jump if equal
		jmp	loc_38
loc_47:
		mov	si,ds:data_195e
		call	player_func_7
		mov	dl,ds:data_191e
		xor	dh,dh			; Zero register
		add	dx,cx
		cmp	dx,0A8h
		jae	loc_48			; Jump if above or =
		jmp	loc_38
loc_48:
		mov	byte ptr ds:data_191e,0
		inc	byte ptr ds:data_192e
		cmp	byte ptr ds:data_192e,8
		jne	loc_50			; Jump if not equal
		dec	byte ptr ds:data_192e
		mov	cx,0Ah

locloop_49:
		push	cx
		mov	bx,ds:data_189e
		add	bl,4
		mov	cx,ds:data_196e
		shr	ch,1			; Shift w/zeros fill
		sub	cl,8
		call	word ptr cs:data_60e
		pop	cx
		loop	locloop_49		; Loop if cx > 0

loc_50:
		inc	byte ptr ds:data_194e
		cmp	byte ptr ds:data_194e,7
		jae	loc_51			; Jump if above or =
		jmp	loc_38
loc_51:
		cmp	byte ptr ds:data_193e,8
		jne	loc_52			; Jump if not equal
		jmp	loc_38
loc_52:
		sub	byte ptr ds:data_193e,7
		mov	cx,ds:data_189e
		xor	bh,bh			; Zero register
		mov	bl,ch
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,54h
		add	cl,4Ah			; 'J'
		push	cx
		push	bx
		mov	ax,27Ch
		call	word ptr cs:data_59e
		mov	byte ptr ds:data_212e,0
		mov	byte ptr ds:data_213e,0
		pop	bx
		pop	cx
loc_53:
		push	cx
		push	bx
		call	math_calc
		call	player_multiply_2
		pop	bx
		pop	cx
		test	byte ptr ds:data_197e,0FFh
		jnz	loc_54			; Jump if not zero
		test	byte ptr ds:data_213e,0FFh
		jz	loc_54			; Jump if zero
		retn
loc_54:
		test	byte ptr ds:data_212e,0FFh
		jz	loc_53			; Jump if zero
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	bh,bl
		mov	bl,cl
		xor	al,al			; Zero register
		mov	cx,208h
		call	word ptr cs:data_47e
		mov	byte ptr ds:data_212e,0
		mov	byte ptr ds:data_194e,0
		mov	byte ptr ds:data_223e,1Dh
		jmp	loc_38

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_6:
loc_55:
		mov	byte ptr ds:data_154e,0
		mov	byte ptr ds:data_155e,0
loc_56:
		call	math_calc
		call	player_multiply_2
		test	byte ptr ds:data_212e,0FFh
		jz	loc_57			; Jump if zero
		retn
loc_57:
		test	byte ptr ds:data_213e,0FFh
		jz	loc_58			; Jump if zero
		retn
loc_58:
		test	byte ptr ds:data_209e,0FFh
		jnz	loc_56			; Jump if not zero
loc_59:
		call	math_calc
		call	player_multiply_2
		test	byte ptr ds:data_212e,0FFh
		jz	loc_60			; Jump if zero
		retn
loc_60:
		test	byte ptr ds:data_213e,0FFh
		jz	loc_61			; Jump if zero
		retn
loc_61:
		test	byte ptr ds:data_209e,0FFh
		jz	loc_59			; Jump if zero
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_7:
		xor	cx,cx			; Zero register
loc_62:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jns	loc_63			; Jump if not sign
		retn
loc_63:
		cmp	al,20h			; ' '
		jne	loc_64			; Jump if not equal
		retn
loc_64:
		cmp	al,2Fh			; '/'
		jne	loc_65			; Jump if not equal
		retn
loc_65:
		sub	al,20h			; ' '
		jc	loc_62			; Jump if carry Set
		mov	bl,al
		xor	bh,bh			; Zero register
		add	cl,cs:data_101e[bx]
		adc	ch,bh
		jmp	short loc_62

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_8:
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
loc_66:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		js	loc_68			; Jump if sign=1
		cmp	al,2Fh			; '/'
		jne	loc_67			; Jump if not equal
		inc	cx
		xor	dx,dx			; Zero register
		jmp	short loc_66
loc_67:
		push	cx
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	cl,ds:data_101e[bx]
		mov	ch,bh
		add	dx,cx
		pop	cx
		cmp	al,20h			; ' '
		jne	loc_66			; Jump if not equal
		push	cx
		push	si
		push	dx
		call	player_func_7
		add	dx,cx
		cmp	dx,0A8h
		pop	dx
		pop	si
		pop	cx
		jc	loc_66			; Jump if carry Set
		xor	dx,dx			; Zero register
		inc	cx
		jmp	short loc_66
loc_68:
		or	dx,dx			; Zero ?
		jnz	loc_69			; Jump if not zero
		retn
loc_69:
		inc	cx
		retn
loc_70:
		or	byte ptr ds:[4],80h
		jmp	loc_119
loc_71:
		mov	bx,ds:data_110e
		add	bh,bh
		add	bx,193Fh
		push	bx
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_47e
		pop	bx
		add	bx,103h
		mov	ds:data_167e,bx
		call	player_func_47
		mov	ax,ds:data_188e
		mov	bl,0Dh
		jnc	loc_72			; Jump if carry=0
		jmp	loc_36
loc_72:
		mov	bl,0Ch
		jmp	loc_36
loc_73:
		or	byte ptr ds:[34h],80h
		mov	byte ptr ds:[9Ah],0FFh
		call	player_func_25
		jmp	loc_55
loc_74:
		mov	byte ptr ds:data_197e,0FFh
		mov	bl,4
		mov	ax,word ptr ds:[7C50h]
		jmp	loc_36
loc_75:
		call	player_func_6
		mov	bl,5
		mov	ax,word ptr ds:[7C50h]
		jmp	loc_36
loc_76:
		mov	bx,ds:data_188e
		add	bh,bh
		add	bx,1832h
		push	bx
		mov	cx,1219h
		mov	al,0FFh
		call	word ptr cs:data_47e
		pop	bx
		add	bx,203h
		mov	ds:data_218e,bx
		call	player_func_9
		mov	ax,ds:data_188e
		mov	bl,6
		jnc	loc_77			; Jump if carry=0
		jmp	loc_36
loc_77:
		mov	dx,word ptr ds:[8Bh]
		sub	dx,9C4h
		mov	bl,7
		jnc	loc_78			; Jump if carry=0
		jmp	loc_36
loc_78:
		mov	word ptr ds:[8Bh],dx
		call	word ptr cs:data_55e
		or	byte ptr ds:[34h],40h	; '@'
		mov	si,0A1h
loc_79:
		test	byte ptr [si],0FFh
		jz	loc_80			; Jump if zero
		inc	si
		jmp	short loc_79
loc_80:
		mov	byte ptr [si],5
		call	player_func_25
		mov	ax,ds:data_110e
		mov	bl,8
		jmp	loc_36
player_multiply		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_9		proc	near
		mov	byte ptr ds:data_216e,2
		mov	byte ptr ds:data_217e,2
		mov	cx,2
		mov	si,6736h
		call	player_multiply_6
		mov	byte ptr ds:data_219e,0
		xor	bl,bl			; Zero register
		call	player_func_43
		jnc	loc_81			; Jump if carry=0
		mov	bl,1
loc_81:
		or	bl,bl			; Zero ?
		jnz	loc_82			; Jump if not zero
		retn
loc_82:
		stc				; Set carry flag
		retn
player_func_9		endp

		db	 54h, 61h, 6Bh, 65h, 00h, 4Eh
		db	 6Fh, 20h, 54h, 61h, 6Bh, 65h
		db	 00h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

math_calc		proc	near
		mov	ax,ds:data_189e
		sub	ah,6
		mov	cx,ds:data_196e
		add	al,cl
		cmp	al,56h			; 'V'
		jae	loc_83			; Jump if above or =
		retn
loc_83:
		push	ax
		xor	ah,ah			; Zero register
		sub	al,4Eh			; 'N'
		mov	cx,8
		div	cl			; al, ah rem = ax/reg
		mov	cl,al
		pop	ax
		push	cs
		pop	es
		mov	di,data_146e
		mov	al,ah
		mov	dl,8
		mul	dl			; ax = reg * al
		add	di,ax
		mov	al,0FFh

locloop_84:
		push	cx
		push	di
		mov	cx,16h

locloop_85:
		stosb				; Store al to es:[di]
		add	di,7
		loop	locloop_85		; Loop if cx > 0

		pop	di
		inc	di
		pop	cx
		loop	locloop_84		; Loop if cx > 0

		retn
math_calc		endp

loc_86:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[83h]
		add	bl,3
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ds:data_159e
		mov	al,[bx+7]
		call	player_scan_loop
		jnz	loc_87			; Jump if not zero
		retn
loc_87:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		add	bx,word ptr ds:[80h]
		dec	bx
		call	player_func_12
		jz	loc_88			; Jump if zero
		retn
loc_88:
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],3
		or	byte ptr ds:[0C2h],1
		cmp	byte ptr ds:[83h],0Bh
		jb	loc_89			; Jump if below
		dec	byte ptr ds:[83h]
		retn
loc_89:
		test	word ptr ds:[80h],0FFFFh
		jnz	loc_90			; Jump if not zero
		dec	byte ptr ds:[83h]
		retn
loc_90:
		dec	word ptr ds:[80h]
		sub	word ptr ds:data_159e,8
		call	word ptr cs:data_70e
		cmp	byte ptr ds:data_105e,1
		je	loc_91			; Jump if equal
		retn
loc_91:
		call	word ptr cs:data_71e
		retn
loc_92:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[83h]
		add	bl,6
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ds:data_159e
		mov	al,[bx+7]
		call	player_scan_loop
		jnz	loc_93			; Jump if not zero
		retn
loc_93:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		add	bx,word ptr ds:[80h]
		inc	bx
		call	player_func_12
		jz	loc_94			; Jump if zero
		retn
loc_94:
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],3
		and	byte ptr ds:[0C2h],0FEh
		cmp	byte ptr ds:[83h],10h
		jae	loc_95			; Jump if above or =
		inc	byte ptr ds:[83h]
		retn
loc_95:
		mov	ax,ds:data_137e
		sub	ax,23h
		mov	bx,word ptr ds:[80h]
		inc	bx
		cmp	ax,bx
		jne	loc_96			; Jump if not equal
		inc	byte ptr ds:[83h]
		retn
loc_96:
		inc	word ptr ds:[80h]
		add	word ptr ds:data_159e,8
		call	word ptr cs:data_72e
		cmp	byte ptr ds:data_105e,1
		je	loc_97			; Jump if equal
		retn
loc_97:
		call	word ptr cs:data_73e
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_scan_loop		proc	near
		mov	es,cs:data_160e
		mov	si,es:data_2e
		mov	cl,es:[si]
		or	cl,cl			; Zero ?
		jz	loc_100			; Jump if zero
		xor	ch,ch			; Zero register
		inc	si

locloop_98:
		cmp	al,es:[si]
		jne	loc_99			; Jump if not equal
		retn
loc_99:
		inc	si
		loop	locloop_98		; Loop if cx > 0

loc_100:
		not	cl
		or	cl,cl			; Zero ?
		retn
player_scan_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_12		proc	near
		mov	si,ds:data_142e
loc_101:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	loc_102			; Jump if not equal
		retn
loc_102:
		sub	ax,bx
		jnz	loc_103			; Jump if not zero
		test	byte ptr [si+6],40h	; '@'
		jz	loc_103			; Jump if zero
		retn
loc_103:
		add	si,8
		jmp	short loc_101
player_func_12		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_multiply_2		proc	near
		call	player_func_26

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_14:
		call	player_func_18
		call	player_func_17
		call	word ptr cs:data_69e
		mov	cl,ds:data_161e
		mov	al,4
		mul	cl			; ax = reg * al
loc_104:
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		call	word ptr cs:[11Eh]
		jnc	loc_105			; Jump if carry=0
		call	clear_buffer
loc_105:
		pop	ax
		cmp	ds:data_211e,al
		jb	loc_104			; Jump if below
		mov	byte ptr ds:data_211e,0
		retn
player_multiply_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

fill_buffer		proc	near
		test	word ptr ds:data_210e,1
		jnz	loc_106			; Jump if not zero
		retn
loc_106:
		mov	byte ptr ds:data_223e,0Bh
		call	word ptr cs:data_48e
		call	player_process_loop
		call	word ptr cs:data_134e
		call	player_process_loop
		call	word ptr cs:data_48e
		call	player_func_23
		call	word ptr cs:data_68e
		push	cs
		pop	es
		mov	al,0FEh
		mov	di,data_146e
		mov	cx,0E0h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		call	player_func_14
		mov	byte ptr ds:data_212e,0
		mov	byte ptr ds:data_213e,0
		retn
fill_buffer		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_process_loop		proc	near
		mov	es,cs:data_160e
		mov	di,data_3e
		mov	si,data_206e
		mov	cx,800h

locloop_107:
		mov	ax,es:[di]
		movsw				; Mov [si] to es:[di]
		mov	[si-2],ax
		loop	locloop_107		; Loop if cx > 0

		retn
player_process_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_17		proc	near
		mov	al,byte ptr ds:[83h]
		cmp	al,1Bh
		jb	loc_108			; Jump if below
		retn
loc_108:
		add	al,al
		add	al,al
		add	al,al
		add	al,5
		xor	ah,ah			; Zero register
		add	ax,0E000h
		mov	di,ax
		push	cs
		pop	es
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	di,5
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn
player_func_17		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_18		proc	near
		push	cs
		pop	es
		xor	ax,ax			; Zero register
		mov	al,byte ptr ds:[83h]
		add	al,4
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,5
		add	ax,ds:data_159e
		push	ax
		mov	si,ax
		mov	di,data_131e
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	si,5
		mov	cx,3
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		xor	dx,dx			; Zero register
		mov	dl,byte ptr ds:[83h]
		add	dl,4
		add	dx,word ptr ds:[80h]
		push	dx
		mov	si,data_205e
		mov	cx,2

locloop_109:
		push	si
		mov	al,[si]
		cmp	al,0FDh
		jne	loc_111			; Jump if not equal
		call	player_func_20
loc_110:
		mov	al,[si+3]
		cmp	al,0FDh
		jne	loc_111			; Jump if not equal
		add	si,8
		call	player_func_21
		jmp	short loc_110
loc_111:
		pop	si
		mov	[si],al
		add	si,3
		inc	dx
		loop	locloop_109		; Loop if cx > 0

		mov	si,data_131e
		call	word ptr cs:data_74e
		pop	dx
		dec	dx
		mov	ds:data_108e,dx
		pop	si
		push	cs
		pop	es
		mov	di,data_132e
		mov	al,[si-8]
		stosb				; Store al to es:[di]
		mov	al,[si]
		stosb				; Store al to es:[di]
		mov	al,[si+8]
		stosb				; Store al to es:[di]
		mov	si,ds:data_142e
loc_112:
		call	player_scan_loop_2
		or	al,al			; Zero ?
		jz	loc_113			; Jump if zero
		push	ax
		call	word ptr cs:data_77e
		pop	bx
		mov	es,cs:data_160e
		push	si
		mov	si,data_131e
		call	word ptr cs:data_75e
		pop	si
loc_113:
		add	si,8
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_112			; Jump if not zero
		mov	si,6A3Bh
		test	byte ptr ds:[0C2h],1
		jnz	loc_114			; Jump if not zero
		mov	si,data_91e
loc_114:
		xor	ax,ax			; Zero register
		mov	al,byte ptr ds:[0E7h]
		add	ax,ax
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	si,ax
		call	word ptr cs:data_76e
		retn
player_func_18		endp

		db	 00h, 02h, 04h, 01h, 03h, 05h
		db	 06h, 08h, 0Ah, 07h, 09h, 0Bh
		db	 00h, 0Ch, 0Eh, 01h, 0Dh, 0Fh
		db	 06h, 10h, 12h, 07h, 11h, 13h
		db	 14h, 16h, 18h, 15h, 17h, 19h
		db	 1Ah, 1Ch, 1Eh, 1Bh, 1Dh, 1Fh
		db	 20h, 22h, 24h, 21h, 23h, 25h
		db	 1Ah
		db	'&(', 1Bh, 27h, ') *,!+-'
		db	 14h, 16h, 18h, 15h, 17h, 19h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_scan_loop_2		proc	near
		mov	cx,3
		mov	dx,ds:data_108e
		mov	di,data_132e

locloop_115:
		cmp	byte ptr [di],0FDh
		jne	loc_116			; Jump if not equal
		mov	al,cl
		cmp	dx,[si]
		jne	loc_116			; Jump if not equal
		retn
loc_116:
		inc	di
		inc	dx
		loop	locloop_115		; Loop if cx > 0

		xor	al,al			; Zero register
		retn
player_scan_loop_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_20		proc	near
		mov	si,ds:data_142e

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_21:
loc_117:
		cmp	dx,[si]
		jne	loc_118			; Jump if not equal
		retn
loc_118:
		add	si,8
		jmp	short loc_117
player_func_20		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_22		proc	near
		call	player_func_32

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_23:
		mov	al,ds:data_208e
		push	ds
		call	dword ptr ds:data_179e
		pop	ds
		retn
player_func_22		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_load_chunk		proc	near
		mov	al,ds:data_105e
		and	al,1
		mov	cl,0Bh
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,6AD3h
		mov	ax,cs
		add	ax,2000h
		mov	ds:data_92e,ax
		mov	es,ax
		mov	di,3300h
		mov	al,3
		call	word ptr cs:[10Ch]
		retn
player_load_chunk		endp

			                        ;* No entry point to code
		add	[bx+di],cx
		pop	cx
		dec	bp
		push	ax
		inc	sp
		db	 2Eh, 42h, 49h, 4Eh, 00h, 01h
		db	0Ah, 'CKPD.BIN'
		db	 00h, 00h, 33h, 00h, 30h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_25		proc	near
loc_119:
		mov	si,ds:data_144e
loc_120:
		lodsw				; String [si] to ax
		mov	bx,ax
		and	al,ah
		inc	al
		jnz	loc_121			; Jump if not zero
		retn
loc_121:
		lodsb				; String [si] to al
		and	al,[bx]
		jnz	loc_123			; Jump if not zero
loc_122:
		lodsw				; String [si] to ax
		and	al,ah
		inc	al
		jz	loc_124			; Jump if zero
		inc	si
		jmp	short loc_122
loc_123:
		lodsw				; String [si] to ax
		mov	bx,ax
		and	al,ah
		inc	al
		jz	loc_124			; Jump if zero
		mov	al,[si]
		mov	[bx],al
		inc	si
		jmp	short loc_123
loc_124:
		jmp	short loc_120
player_func_25		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_26		proc	near
		call	player_func_28
		mov	si,ds:data_142e
		mov	dx,[si]
;*		cmp	dx,0FFFFh
		db	 83h,0FAh,0FFh		;  Fixup - byte match
		jnz	$+5			; Jump if not zero
		jmp	loc_136
			                        ;* No entry point to code
		mov	bl,[si+5]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,word ptr ds:[6B41h][bx]
		call	ax			;*
		mov	[si],dx
		add	si,8
		jmp	short $-1Ch
			                        ;* No entry point to code
		push	cx
		db	 6Bh, 6Ch, 6Bh,0A6h, 6Bh,0B7h
		db	 6Bh,0D2h, 6Bh,0ECh, 6Bh, 19h
		db	 6Ch, 2Ah, 6Ch, 80h, 4Ch, 02h
		db	 80h, 8Ah, 1Eh, 83h, 00h, 80h
		db	0C3h, 04h, 32h,0FFh, 03h, 1Eh
		db	 80h, 00h, 3Bh,0DAh, 72h, 6Ch
		db	 80h, 64h, 02h, 7Fh,0EBh, 66h
		db	 8Ah, 44h, 04h, 04h, 10h, 88h
		db	 44h, 04h, 8Ah,0E8h, 24h, 10h
		db	 74h, 01h,0C3h
loc_125:
		inc	ch
		and	ch,0Fh
		or	ch,al
		mov	[si+4],ch
		mov	bx,ds:data_143e
		test	byte ptr [si+2],80h
		jz	loc_127			; Jump if zero
		dec	dx
		cmp	[bx],dx
		jae	loc_126			; Jump if above or =
		retn
loc_126:
		and	byte ptr [si+2],7Fh
		retn
loc_127:
		inc	dx
		cmp	[bx+2],dx
		jb	loc_128			; Jump if below
		retn
loc_128:
		or	byte ptr [si+2],80h
		retn
			                        ;* No entry point to code
		mov	al,[si+4]
		add	al,10h
		mov	[si+4],al
		mov	ch,al
		and	al,30h			; '0'
		jz	loc_129			; Jump if zero
		retn
loc_129:
		jmp	short loc_125
			                        ;* No entry point to code
		or	byte ptr [si+2],80h
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		xor	bh,bh			; Zero register
		add	bx,word ptr ds:[80h]
		cmp	bx,dx
		jae	loc_130			; Jump if above or =
		retn
loc_130:
		and	byte ptr [si+2],7Fh
		retn
			                        ;* No entry point to code
		mov	al,[si+4]
		add	al,10h
		mov	[si+4],al
		mov	ch,al
		and	al,30h			; '0'
		jz	loc_131			; Jump if zero
		retn
loc_131:
		inc	ch
		and	ch,1
		or	al,ch
		mov	[si+4],al
		retn
			                        ;* No entry point to code
		mov	al,[si+4]
		add	al,10h
		mov	[si+4],al
		mov	ch,al
		and	al,10h
		jz	loc_132			; Jump if zero
		retn
loc_132:
		inc	ch
		and	ch,0Fh
		or	ch,al
		mov	[si+4],ch
		and	ch,7
		jnz	loc_133			; Jump if not zero
		xor	byte ptr [si+2],80h
		retn
loc_133:
		test	byte ptr [si+2],80h
		jz	loc_134			; Jump if zero
		dec	dx
		retn
loc_134:
		inc	dx
		retn
			                        ;* No entry point to code
		mov	al,[si+4]
		add	al,10h
		mov	[si+4],al
		mov	ch,al
		and	al,30h			; '0'
		jz	loc_135			; Jump if zero
		retn
loc_135:
		jmp	short loc_132
		db	0C3h

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_27:
loc_136:
		mov	si,ds:data_142e
loc_137:
		mov	bx,[si]
;*		cmp	bx,0FFFFh
		db	 83h,0FBh,0FFh		;  Fixup - byte match
		jnz	loc_138			; Jump if not zero
		retn
loc_138:
		add	bx,bx
		add	bx,bx
		add	bx,bx
		mov	al,ds:data_145e[bx]
		mov	byte ptr ds:data_145e[bx],0FDh
		mov	[si+3],al
		add	si,8
		jmp	short loc_137
player_func_26		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_28		proc	near
		mov	si,ds:data_142e
loc_139:
		mov	bx,[si]
;*		cmp	bx,0FFFFh
		db	 83h,0FBh,0FFh		;  Fixup - byte match
		jnz	loc_140			; Jump if not zero
		retn
loc_140:
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_141			; Jump if equal
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,data_145e
		mov	[bx],al
loc_141:
		add	si,8
		jmp	short loc_139
player_func_28		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_29		proc	near
		mov	si,data_93e
		call	word ptr cs:data_52e
		mov	si,data_94e
		call	word ptr cs:data_52e
		mov	si,data_95e
		call	word ptr cs:data_52e
		mov	si,data_96e
		call	word ptr cs:data_52e
		retn
player_func_29		endp

			                        ;* No entry point to code
		push	cs
		mov	word ptr ds:[400h],ax
		dec	sp
		dec	cx
		inc	si
		inc	bp
		push	ds
		mov	bx,503h
		inc	cx
		dec	sp
		dec	bp
		inc	cx
		push	bx
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

player_func_30		proc	near
		mov	al,ds:data_177e
		inc	al
		jnz	loc_145			; Jump if not zero
		call	player_func_28
		mov	byte ptr ds:data_211e,28h	; '('
		call	player_func_14
		mov	si,ds:data_207e
loc_142:
		test	byte ptr [si],1
		jnz	loc_143			; Jump if not zero
		add	si,4
		jmp	short loc_142
loc_143:
		lodsb				; String [si] to al
		mov	ah,al
		lodsb				; String [si] to al
		and	ah,0FEh
		jz	loc_144			; Jump if zero
;*		jmp	loc_160			;*
		db	0E9h, 17h, 03h		;  Fixup - byte match
loc_144:
		call	player_func_31
		mov	byte ptr ds:[83h],1Ah
		mov	ax,ds:data_137e
		sub	ax,24h
		mov	word ptr ds:[80h],ax
		jmp	loc_8
loc_145:
		cmp	al,1Ch
		je	loc_146			; Jump if equal
		retn
loc_146:
		call	player_func_28
		mov	byte ptr ds:data_153e,28h	; '('
		call	player_func_14
		mov	si,ds:data_139e
loc_147:
		test	byte ptr [si],1
		jz	loc_148			; Jump if zero
		add	si,4
		jmp	short loc_147
loc_148:
		lodsb				; String [si] to al
		mov	ah,al
		lodsb				; String [si] to al
		and	ah,0FEh
		jz	loc_149			; Jump if zero
;*		jmp	loc_160			;*
		db	0E9h,0D9h, 02h		;  Fixup - byte match
loc_149:
		call	player_func_31
		mov	byte ptr ds:[83h],0
		mov	word ptr ds:[80h],0
		jmp	loc_8

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_31:
		or	al,80h
		mov	byte ptr ds:[0C4h],al
		lodsw				; String [si] to ax
		push	ax
		mov	ah,byte ptr ds:[0C4h]
		mov	al,1
		call	word ptr cs:[10Ch]
		pop	ax
		push	ax
		mov	cl,0Bh
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,data_97e
		mov	es,cs:data_160e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_160e
		mov	si,data_1e
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,7000h
		mov	cx,0A0h
		call	word ptr cs:data_84e
		pop	ds
		pop	ax
		cmp	ah,ds:data_106e
		je	loc_ret_150		; Jump if equal
		mov	ds:data_106e,ah
		call	player_func_32

loc_ret_150:
		retn
			                        ;* No entry point to code
		add	ds:data_86e,bx
		inc	cx
		dec	si
		db	 2Eh, 47h, 52h, 50h, 00h, 01h
		db	 1Fh
		db	'CMAN.GRP'
		db	0

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_32:
		mov	al,0Bh
		mul	byte ptr ds:data_106e	; ax = data * al
		add	ax,6DCEh
		mov	si,ax
		mov	es,cs:data_160e
		mov	di,8000h
		mov	al,2
		call	word ptr cs:[10Ch]
		add	word ptr es:[di],8000h
		add	word ptr es:[di+2],8000h
		add	word ptr es:[di+4],8000h
		jmp	word ptr cs:data_83e
			                        ;* No entry point to code
		add	[bp+si],sp
		inc	bx
		push	ax
		inc	cx
		push	sp
		db	 2Eh, 47h, 52h, 50h, 00h, 01h
		db	'#MPAT.GRP'
		db	0, 1
		db	'$'
		db	'DPAT.GRP'
		db	0

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_33:
		mov	es,cs:data_160e
		mov	si,6E1Eh
		mov	di,6000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_160e
		mov	si,6000h
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,8000h
		mov	cx,2Eh
		call	word ptr cs:data_84e
		pop	ds
		retn
			                        ;* No entry point to code
		add	[bx+si],sp
		push	sp
		dec	bp
		inc	cx
		dec	si
		db	 2Eh, 47h, 52h, 50h, 00h
loc_151:
		or	byte ptr ds:[0E7h],1
		mov	ax,word ptr ds:[80h]
		mov	bl,byte ptr ds:[83h]
		xor	bh,bh			; Zero register
		add	ax,bx
		add	ax,4
		mov	si,ds:data_140e
loc_152:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jnz	loc_153			; Jump if not zero
		retn
loc_153:
		cmp	[si],ax
		je	loc_154			; Jump if equal
		inc	ax
		cmp	[si],ax
		je	loc_154			; Jump if equal
		dec	ax
		dec	ax
		cmp	[si],ax
		je	loc_154			; Jump if equal
		inc	ax
		add	si,3
		jmp	short loc_152
loc_154:
		mov	byte ptr ds:[0E7h],4
		push	si
		call	player_func_28
		mov	byte ptr ds:data_153e,28h	; '('
		call	player_func_14
		pop	si
		mov	al,[si+2]
		cmp	al,0FFh
		jne	loc_155			; Jump if not equal
		jmp	loc_157
loc_155:
		sub	al,8
		jc	loc_156			; Jump if carry Set
;*		jmp	loc_160			;*
		db	0E9h, 7Ah, 01h		;  Fixup - byte match
loc_156:
		mov	byte ptr ds:data_156e,4
		mov	bl,[si+2]
		mov	al,0Eh
		mul	bl			; ax = reg * al
		add	ax,6F07h
		mov	si,ax
		push	cs
		pop	es
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		call	word ptr cs:data_65e
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:data_102e,0FFh
		call	word ptr cs:data_133e
		call	word ptr cs:data_48e
		mov	byte ptr ds:data_102e,0
		call	word ptr cs:data_54e
		call	player_func_29
		mov	si,ds:data_138e
		call	word ptr cs:data_53e
		call	player_func_22
		call	word ptr cs:data_68e
		push	cs
		pop	es
		mov	al,0FEh
		mov	di,data_146e
		mov	cx,0E0h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		call	player_func_25
		mov	byte ptr ds:data_153e,28h	; '('
		call	player_func_14
		mov	byte ptr ds:data_154e,0
		mov	byte ptr ds:data_155e,0
		mov	byte ptr ds:[0E7h],1
		push	ds
		mov	ds,cs:data_160e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		retn
			                        ;* No entry point to code
		add	[bp+di],cx
		dec	bx
		dec	cx
		dec	si
		inc	di
		push	ax
		push	dx
		dec	di
		db	 2Eh, 42h, 49h, 4Eh, 00h, 01h
		db	0Ch, 'OMOYPRO.BIN'
		db	 00h, 01h, 12h
		db	'KENJPRO.BIN'
		db	0, 1
		db	0Dh, 'ARMRPRO.BIN'
		db	 00h, 01h, 10h
		db	'DRUGPRO.BIN'
		db	 00h, 01h, 0Fh
		db	'CHURPRO.BIN'
		db	 00h, 01h, 0Eh
		db	'BANKPRO.BIN'
		db	 00h, 01h, 11h
		db	'INNAPRO.BIN'
		db	0
loc_157:
		mov	byte ptr ds:[0E7h],4
		call	player_func_14
		test	byte ptr ds:[45h],80h
		jnz	loc_158			; Jump if not zero
		mov	byte ptr ds:data_121e,0FFh
		mov	ax,918h
		xor	bl,bl			; Zero register
		call	player_func_5
		mov	byte ptr ds:data_121e,0
		or	byte ptr ds:[45h],80h
loc_158:
		mov	byte ptr ds:data_156e,4
		mov	ah,86h
		mov	byte ptr ds:[0C4h],ah
		mov	al,1
		call	word ptr cs:[10Ch]
		mov	si,data_97e
		mov	es,cs:data_160e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
loc_159:
		test	byte ptr ds:data_157e,0FFh
		jz	loc_159			; Jump if zero
		mov	si,data_98e
		mov	es,cs:data_160e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	word ptr ds:[80h],84h
		mov	byte ptr ds:[83h],0Dh
		call	word ptr cs:data_65e
;*		jmp	loc_2			;*
		db	0E9h, 31h,0F0h		;  Fixup - byte match
			                        ;* No entry point to code
		add	[bp+si],si
		push	bp
		inc	di
		dec	bp
		xor	ch,ds:data_87e
		inc	sp
		add	ss:data_150e[bp+di],dh
		jcxz	loc_161			; Jump if cx=0
		push	es
		or	ax,ax			; Zero ?
loc_161:
		mov	si,ax
		lodsw				; String [si] to ax
		push	ax
		lodsb				; String [si] to al
		sub	al,0Ah
		and	al,3Fh			; '?'
		mov	byte ptr ds:[82h],al
		lodsb				; String [si] to al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		mov	byte ptr ds:[0C3h],al
		lodsb				; String [si] to al
		mov	byte ptr ds:[0C4h],al
		mov	ah,al
		mov	al,1
		call	word ptr cs:[10Ch]
		pop	ax
		add	ax,0FFF0h
		jns	loc_162			; Jump if not sign
		add	ax,ds:data_137e
loc_162:
		mov	word ptr ds:[80h],ax
		mov	data_5,0FFh
		call	word ptr cs:data_65e
		mov	bx,6002h
		xor	al,al			; Zero register
		jmp	word ptr cs:[10Ch]
player_func_30		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_34		proc	near
		push	si
		push	di
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[11Eh]
		jnc	loc_163			; Jump if carry=0
		call	clear_buffer
loc_163:
		pop	di
		pop	si
		test	byte ptr ds:data_184e,0FFh
		jnz	loc_164			; Jump if not zero
		retn
loc_164:
		push	si
		push	di
		call	word ptr cs:data_134e
		pop	di
		pop	si
		retn
player_func_34		endp

			                        ;* No entry point to code
		mov	si,ds:data_162e
		call	player_check_state
		mov	dl,ds:data_163e
		xor	dh,dh			; Zero register
		add	dx,cx
		cmp	dx,0D0h
		jb	loc_165			; Jump if below
		call	player_scan_loop_3
loc_165:
		mov	byte ptr ds:data_153e,0
loc_166:
		call	player_func_34
		cmp	byte ptr ds:data_211e,6
		jb	loc_166			; Jump if below
		mov	si,ds:data_215e
		lodsb				; String [si] to al
		mov	ds:data_215e,si
		cmp	al,2Fh			; '/'
		jne	loc_167			; Jump if not equal
		jmp	loc_179
loc_167:
		cmp	al,0Dh
		jne	loc_168			; Jump if not equal
		jmp	loc_179
loc_168:
		cmp	al,0Ch
		jne	loc_169			; Jump if not equal
		jmp	loc_187
loc_169:
		cmp	al,0Fh
		jne	loc_170			; Jump if not equal
		jmp	loc_184
loc_170:
		cmp	al,11h
		jne	loc_171			; Jump if not equal
		jmp	loc_185
loc_171:
		cmp	al,13h
		jne	loc_172			; Jump if not equal
		mov	byte ptr ds:data_198e,0FFh
		jmp	short loc_165
loc_172:
		cmp	al,15h
		jne	loc_173			; Jump if not equal
		mov	byte ptr ds:data_198e,0
		jmp	short loc_165
loc_173:
		cmp	al,0FFh
		jne	loc_174			; Jump if not equal
		lodsb				; String [si] to al
		mov	ds:data_215e,si
		retn
loc_174:
		or	al,al			; Zero ?
		jnz	loc_175			; Jump if not zero
		retn
loc_175:
		push	ax
		cmp	byte ptr ds:data_163e,0D0h
		jb	loc_176			; Jump if below
		call	player_scan_loop_3
loc_176:
		mov	bl,byte ptr ds:[0FF4Eh]
		xor	bh,bh			; Zero register
		mov	cl,byte ptr ds:[0FF4Fh]
		mov	al,0Ah
		mul	cl			; ax = reg * al
		mov	cl,al
		pop	ax
		push	bx
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	dl,ds:data_182e[bx]
		mov	dh,bh
		pop	bx
		push	bx
		push	ax
		sub	bx,dx
		mov	ah,1
		add	bx,38h
		add	cl,63h			; 'c'
		call	word ptr cs:data_59e
		pop	ax
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	cl,ds:data_183e[bx]
		mov	ch,bh
		pop	bx
		add	bx,cx
		mov	byte ptr ds:[0FF4Eh],bl
		test	byte ptr ds:data_198e,0FFh
		jnz	loc_177			; Jump if not zero
		cmp	al,20h			; ' '
		je	loc_177			; Jump if equal
		mov	byte ptr ds:data_223e,5
		jmp	loc_165
loc_177:
		mov	si,ds:data_215e
		call	player_check_state
		mov	dl,byte ptr ds:[0FF4Eh]
		xor	dh,dh			; Zero register
		add	dx,cx
		cmp	dx,0D0h
		jb	loc_178			; Jump if below
		call	player_scan_loop_3
loc_178:
		jmp	loc_165
loc_179:
		call	player_scan_loop_3
		jmp	loc_165

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_scan_loop_3		proc	near
		mov	byte ptr ds:data_163e,0
		inc	byte ptr ds:data_113e
		inc	byte ptr ds:data_164e
		cmp	byte ptr ds:data_113e,4
		jb	loc_181			; Jump if below
		call	player_check_state_2
		push	cx
		call	player_func_36
		pop	cx
		cmp	cx,2
		jb	loc_ret_180		; Jump if below
		call	player_func_37

loc_ret_180:
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_36:
loc_181:
		cmp	byte ptr ds:data_164e,5
		jae	loc_182			; Jump if above or =
		retn
loc_182:
		dec	byte ptr ds:data_164e
		mov	cx,0Ah

locloop_183:
		push	cx
		call	player_func_34
		mov	bx,762h
		mov	cx,1A32h
		call	word ptr cs:data_60e
		pop	cx
		loop	locloop_183		; Loop if cx > 0

		retn
player_scan_loop_3		endp

loc_184:
		call	player_func_37
		jmp	loc_165
loc_185:
		call	player_func_38
		jmp	loc_165

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_37		proc	near
		mov	bx,9Ch
		mov	cl,8Bh
		mov	ax,27Ch
		call	word ptr cs:data_59e
		call	player_func_38
		mov	bx,data_67e
		mov	cx,20Ah
		xor	al,al			; Zero register
		call	word ptr cs:data_47e
		mov	byte ptr ds:data_113e,0
		retn
player_func_37		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_38		proc	near
		mov	byte ptr ds:data_212e,0
		mov	byte ptr ds:data_213e,0
loc_186:
		call	player_func_34
		mov	al,ds:data_212e
		or	al,ds:data_213e
		jz	loc_186			; Jump if zero
		mov	byte ptr ds:data_212e,0
		mov	byte ptr ds:data_213e,0
		mov	byte ptr ds:data_223e,1Dh
		retn
player_func_38		endp

loc_187:
		mov	byte ptr ds:data_163e,0
		mov	byte ptr ds:data_164e,0
		mov	byte ptr ds:data_113e,0
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_47e
		jmp	loc_165

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_check_state		proc	near
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
loc_188:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_189			; Jump if zero
		cmp	al,0FFh
		je	loc_189			; Jump if equal
		cmp	al,20h			; ' '
		je	loc_189			; Jump if equal
		cmp	al,2Fh			; '/'
		je	loc_189			; Jump if equal
		cmp	al,0Dh
		je	loc_189			; Jump if equal
		cmp	al,0Ch
		je	loc_189			; Jump if equal
		mov	ah,al
		sub	al,20h			; ' '
		jc	loc_188			; Jump if carry Set
		inc	dx
		mov	bl,al
		xor	bh,bh			; Zero register
		add	cl,cs:data_101e[bx]
		adc	ch,bh
		jmp	short loc_188
loc_189:
		cmp	dx,1
		je	loc_190			; Jump if equal
		retn
loc_190:
		cmp	ah,2Eh			; '.'
		je	loc_191			; Jump if equal
		cmp	ah,2Ch			; ','
		je	loc_191			; Jump if equal
		retn
loc_191:
		xor	cx,cx			; Zero register
		retn
player_check_state		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_check_state_2		proc	near
		mov	si,ds:data_162e
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
loc_192:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_196			; Jump if zero
		cmp	al,0FFh
		jne	loc_193			; Jump if not equal
		lodsb				; String [si] to al
		cmp	al,0FFh
		je	loc_196			; Jump if equal
		jmp	short loc_192
loc_193:
		cmp	al,0Ch
		je	loc_196			; Jump if equal
		cmp	al,2Fh			; '/'
		jne	loc_194			; Jump if not equal
		xor	dx,dx			; Zero register
		inc	cx
		jmp	short loc_192
loc_194:
		cmp	al,0Dh
		jne	loc_195			; Jump if not equal
		xor	dx,dx			; Zero register
		inc	cx
		jmp	short loc_192
loc_195:
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	bl,ds:data_101e[bx]
		add	dx,bx
		cmp	al,20h			; ' '
		jne	loc_192			; Jump if not equal
		push	cx
		push	si
		push	dx
		push	dx
		call	player_check_state
		pop	dx
		add	dx,cx
		cmp	dx,0D0h
		pop	dx
		pop	si
		pop	cx
		jc	loc_192			; Jump if carry Set
		xor	dx,dx			; Zero register
		inc	cx
		jmp	short loc_192
loc_196:
		or	dx,dx			; Zero ?
		jnz	loc_197			; Jump if not zero
		retn
loc_197:
		inc	cx
		retn
player_check_state_2		endp

			                        ;* No entry point to code
		push	ds
		pop	es
		push	di
		mov	bl,0Fh
		mov	cx,4240h
		call	player_func_41
		mov	bl,1
		mov	cx,86A0h
		call	player_func_41
		xor	bl,bl			; Zero register
		mov	cx,2710h
		call	player_func_41
		mov	cx,3E8h
		call	player_func_42
		mov	cx,64h
		call	player_func_42
		mov	cx,0Ah
		call	player_func_42
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		pop	di
		mov	si,di
		mov	cx,7

locloop_198:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_199			; Jump if not zero
		loop	locloop_198		; Loop if cx > 0

loc_199:
		add	al,30h			; '0'
		stosb				; Store al to es:[di]
		jcxz	loc_201			; Jump if cx=0
		dec	cx
		jz	loc_201			; Jump if zero

locloop_200:
		lodsb				; String [si] to al
		add	al,30h			; '0'
		stosb				; Store al to es:[di]
		loop	locloop_200		; Loop if cx > 0

loc_201:
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_41		proc	near
		xor	dh,dh			; Zero register
loc_202:
		sub	dl,bl
		jc	loc_205			; Jump if carry Set
		sub	ax,cx
		jnc	loc_203			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_204			; Jump if zero
		dec	dl
loc_203:
		inc	dh
		jmp	short loc_202
loc_204:
		add	ax,cx
loc_205:
		add	dl,bl
		push	ax
		mov	al,dh
		stosb				; Store al to es:[di]
		pop	ax
		retn
player_func_41		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_42		proc	near
		xor	dh,dh			; Zero register
		div	cx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		push	ax
		mov	al,dh
		stosb				; Store al to es:[di]
		pop	ax
		retn
player_func_42		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_43		proc	near
		mov	byte ptr ds:data_212e,0
		mov	byte ptr ds:data_213e,0
		push	bx
		call	player_multiply_3
		pop	bx
		push	bx
		call	player_func_34
		pop	bx
		mov	byte ptr ds:data_211e,0
		test	byte ptr ds:data_213e,0FFh
		stc				; Set carry flag
		jz	loc_206			; Jump if zero
		retn
loc_206:
		test	byte ptr ds:data_212e,0FFh
		jz	loc_207			; Jump if zero
		clc				; Clear carry flag
		mov	byte ptr ds:data_223e,1Fh
		retn
loc_207:
		mov	ax,7353h
		push	ax
		int	61h			; ??INT Non-standard interrupt
		and	al,3
		cmp	al,1
		jne	loc_212			; Jump if not equal
		or	bl,bl			; Zero ?
		jz	loc_208			; Jump if zero
		push	bx
		call	player_multiply_4
		pop	bx
		dec	bl
		retn
loc_208:
		test	byte ptr ds:data_219e,0FFh
		jnz	loc_209			; Jump if not zero
		retn
loc_209:
		push	di
		push	si
		push	bx
		dec	byte ptr ds:data_219e
		mov	al,ds:data_219e
		add	al,bl
		mov	bx,data_220e
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_79e
		mov	cx,0Ah

locloop_210:
		push	cx
		mov	bx,ds:data_218e
		add	bx,301h
		mov	al,cl
		dec	al
		mov	cl,ds:data_216e
		add	cl,cl
		mov	dl,cl
		add	cl,cl
		add	cl,cl
		add	cl,dl
		sub	cl,2
		mov	ch,ds:data_221e
		call	word ptr cs:data_81e
loc_211:
		call	player_func_34
		cmp	byte ptr ds:data_211e,4
		jb	loc_211			; Jump if below
		mov	byte ptr ds:data_211e,0
		pop	cx
		loop	locloop_210		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		retn
loc_212:
		cmp	al,2
		je	loc_213			; Jump if equal
		retn
loc_213:
		mov	al,ds:data_216e
		dec	al
		cmp	bl,al
		jae	loc_214			; Jump if above or =
		push	bx
		call	player_multiply_5
		pop	bx
		inc	bl
		retn
loc_214:
		mov	al,bl
		add	al,ds:data_219e
		inc	al
		mov	ah,ds:data_217e
		dec	ah
		cmp	ah,al
		jae	loc_215			; Jump if above or =
		retn
loc_215:
		push	di
		push	si
		push	bx
		inc	byte ptr ds:data_219e
		mov	al,ds:data_219e
		add	al,bl
		mov	bx,data_220e
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_79e
		mov	cx,0Ah

locloop_216:
		push	cx
		mov	bx,ds:data_218e
		add	bx,301h
		mov	al,cl
		neg	al
		add	al,0Ah
		mov	cl,ds:data_216e
		add	cl,cl
		mov	dl,cl
		add	cl,cl
		add	cl,cl
		add	cl,dl
		sub	cl,2
		mov	ch,ds:data_221e
		call	word ptr cs:data_82e
loc_217:
		call	player_func_34
		cmp	byte ptr ds:data_211e,4
		jb	loc_217			; Jump if below
		mov	byte ptr ds:data_211e,0
		pop	cx
		loop	locloop_216		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		retn
player_func_43		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_multiply_3		proc	near
		mov	al,0Ah
		mul	bl			; ax = reg * al
		add	ax,ds:data_218e
		add	ax,100h
		mov	bx,ax
		jmp	word ptr cs:data_78e
player_multiply_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_multiply_4		proc	near
		mov	al,0Ah
		mul	bl			; ax = reg * al
		add	ax,ds:data_218e
		add	ax,100h
		mov	bx,ax
		mov	cx,0Ah

locloop_218:
		push	cx
		mov	byte ptr ds:data_211e,0
		dec	bx
		push	bx
		call	word ptr cs:data_78e
loc_219:
		call	player_func_34
		cmp	byte ptr ds:data_211e,4
		jb	loc_219			; Jump if below
		pop	bx
		pop	cx
		loop	locloop_218		; Loop if cx > 0

		retn
player_multiply_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_multiply_5		proc	near
		mov	al,0Ah
		mul	bl			; ax = reg * al
		add	ax,ds:data_218e
		add	ax,100h
		mov	bx,ax
		mov	cx,0Ah

locloop_220:
		push	cx
		mov	byte ptr ds:data_211e,0
		inc	bx
		push	bx
		call	word ptr cs:data_78e
loc_221:
		call	player_func_34
		cmp	byte ptr ds:data_211e,4
		jb	loc_221			; Jump if below
		pop	bx
		pop	cx
		loop	locloop_220		; Loop if cx > 0

		retn
player_multiply_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_47		proc	near
		mov	al,ds:data_165e
		mov	ah,ds:data_166e
		push	ax
		mov	al,ds:data_168e
		push	ax
		mov	byte ptr ds:data_165e,2
		mov	byte ptr ds:data_166e,2
		mov	cx,2
		mov	si,7513h
		call	player_multiply_6
		mov	byte ptr ds:data_168e,0
		xor	bl,bl			; Zero register
		call	player_func_43
		jnc	loc_222			; Jump if carry=0
		mov	bl,1
loc_222:
		pop	ax
		mov	ds:data_219e,al
		pop	ax
		mov	ds:data_216e,al
		mov	ds:data_217e,ah
		or	bl,bl			; Zero ?
		jnz	loc_223			; Jump if not zero
		retn
loc_223:
		stc				; Set carry flag
		retn
player_func_47		endp

		db	 59h, 65h, 73h, 00h, 4Eh, 6Fh
		db	 00h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_multiply_6		proc	near
		xor	dl,dl			; Zero register

locloop_224:
		push	cx
		push	dx
		mov	al,0Ah
		mul	dl			; ax = reg * al
		add	ax,ds:data_218e
		add	ax,301h
		mov	bx,ax
		xor	cl,cl			; Zero register
		call	word ptr cs:data_64e
		pop	dx
		pop	cx
		inc	dl
		loop	locloop_224		; Loop if cx > 0

		retn
player_multiply_6		endp

		db	 32h,0E4h

locloop_225:
		push	cx
		push	si
		push	di
		push	ax
		mov	bx,data_170e
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_79e
		pop	ax
		push	ax
		mov	al,ah
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		add	ax,ax
		add	ax,ax
		add	bx,ax
		add	bx,ds:data_167e
		add	bx,300h
		call	word ptr cs:data_80e
		pop	ax
		inc	al
		inc	ah
		pop	di
		pop	si
		pop	cx
		loop	locloop_225		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	bl,byte ptr ds:[85h]
		sub	bl,dl
		jnc	loc_226			; Jump if carry=0
		retn
loc_226:
		mov	dl,bl
		mov	bx,word ptr ds:[86h]
		xchg	bx,ax
		sub	ax,bx
		jc	loc_227			; Jump if carry Set
		retn
loc_227:
		sub	dl,1
		retn
			                        ;* No entry point to code
		add	word ptr ds:[86h],ax
		adc	byte ptr ds:[85h],dl
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

clear_buffer		proc	near
loc_228:
		mov	cl,0FFh
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		push	cs
		pop	es
		mov	si,7688h
		mov	al,6
		call	word ptr cs:[10Ch]
		mov	byte ptr ds:data_169e,0
		call	copy_buffer
		push	cs
		pop	es
		test	byte ptr cs:data_128e,0FFh
		jz	loc_229			; Jump if zero
		mov	di,data_172e
		xor	al,al			; Zero register
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	si,7688h
		jmp	short loc_232
loc_229:
		mov	si,data_172e
		mov	di,data_129e
		mov	cx,8

locloop_230:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_231			; Jump if zero
		stosb				; Store al to es:[di]
		loop	locloop_230		; Loop if cx > 0

loc_231:
		mov	byte ptr es:[di],2Eh	; '.'
		mov	byte ptr es:[di+1],55h	; 'U'
		mov	byte ptr es:[di+2],53h	; 'S'
		mov	byte ptr es:[di+3],52h	; 'R'
		mov	byte ptr es:[di+4],0
		mov	si,7C65h
		mov	byte ptr cs:data_175e,0FFh
loc_232:
		mov	di,0
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	byte ptr cs:data_175e,0
		jc	loc_233			; Jump if carry Set
		mov	si,767Bh
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		call	word ptr cs:data_66e
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		xor	cl,cl			; Zero register
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		mov	ax,0FFFFh
		jmp	word ptr ds:data_180e
loc_233:
		mov	bx,1A46h
		mov	cx,1E1Ah
		mov	al,0FFh
		call	word ptr cs:data_47e
		push	cs
		pop	ds
		mov	si,7667h
		mov	bx,80h
		mov	cl,4Ch			; 'L'
		call	word ptr cs:data_63e
		mov	byte ptr cs:data_154e,0
loc_234:
		call	word ptr cs:[110h]
		test	byte ptr cs:data_154e,0FFh
		jz	loc_234			; Jump if zero
		mov	byte ptr cs:data_154e,0
		jmp	loc_228
clear_buffer		endp

		db	'User File', 0Dh, 'Not Found'
		db	0FFh, 00h, 00h
		db	'GAME.BIN'
		db	 00h, 00h,0A0h, 00h, 00h
		db	'STDPLY.BIN'
		db	0

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_buffer		proc	near
		mov	ax,cs
		mov	es,ax
		mov	ds,ax
		mov	di,0E000h
		mov	dx,77A8h
		call	word ptr cs:[11Ch]
		mov	di,data_146e
		inc	byte ptr [di]
		jnz	loc_235			; Jump if not zero
		dec	byte ptr [di]
loc_235:
		std				; Set direction flag
		mov	si,data_148e
		mov	di,data_149e
		mov	cx,0FFh
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		cld				; Clear direction
		mov	word ptr ds:data_147e,77BAh
		mov	bx,0D38h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_47e
		mov	bx,0D38h
		mov	cx,2637h
		mov	al,0FFh
		call	word ptr cs:data_47e
		push	cs
		pop	es
		mov	di,data_129e
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		mov	byte ptr ds:data_123e,0
		mov	si,data_172e
		mov	di,data_129e
		mov	cx,8

locloop_236:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_237			; Jump if zero
		inc	byte ptr ds:data_123e
		stosb				; Store al to es:[di]
		loop	locloop_236		; Loop if cx > 0

loc_237:
		mov	al,ds:data_123e
		mov	ds:data_124e,al
		push	cs
		pop	es
		mov	di,data_129e
		mov	al,60h			; '`'
		mov	cx,8

locloop_238:
		scasb				; Scan es:[di] for al
		jnz	loc_239			; Jump if not zero
		loop	locloop_238		; Loop if cx > 0

		mov	si,data_99e
		mov	di,data_129e
		mov	cx,8
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
loc_239:
		mov	bx,3Ch
		mov	cl,44h			; 'D'
		mov	si,77AEh
		call	word ptr cs:data_63e
		mov	word ptr ds:data_125e,60h
		mov	byte ptr ds:data_126e,56h	; 'V'
		mov	word ptr ds:data_167e,343Bh
		mov	word ptr ds:data_171e,0Ah
		mov	al,ds:data_146e
		or	al,al			; Zero ?
		jz	loc_246			; Jump if zero
		cmp	al,5
		jb	loc_240			; Jump if below
		mov	al,5
loc_240:
		xor	ah,ah			; Zero register
		mov	cx,ax
		xor	al,al			; Zero register
		mov	si,0E001h
		jcxz	loc_241			; Jump if cx=0
		call	player_process_loop_2
loc_241:
		mov	si,0E001h
		mov	al,ds:data_146e
		mov	ds:data_166e,al
		mov	byte ptr ds:data_165e,5
		call	player_copy_buf
		push	cs
		pop	es
		mov	di,data_172e
		mov	cx,8
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		cmp	byte ptr ds:data_200e,0
		stc				; Set carry flag
		jnz	loc_242			; Jump if not zero
		retn
loc_242:
		mov	si,data_129e
		mov	di,data_172e
loc_243:
		lodsb				; String [si] to al
		cmp	al,0FFh
		clc				; Clear carry flag
		jnz	loc_244			; Jump if not zero
		retn
loc_244:
		cmp	al,60h			; '`'
		clc				; Clear carry flag
		jnz	loc_245			; Jump if not zero
		retn
loc_245:
		stosb				; Store al to es:[di]
		jmp	short loc_243
loc_246:
		mov	ax,0FFFFh
		jmp	dword ptr cs:data_151e
copy_buffer		endp

		db	 2Ah, 2Eh, 75h, 73h, 72h, 00h
		db	'Input name:'
		db	0FFh
		db	'Re-Start'
		db	0

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_func_51		proc	near
		mov	byte ptr cs:data_128e,0
		push	cs
		pop	es
		mov	di,data_129e
		mov	al,2Dh			; '-'
		mov	cx,8
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jz	loc_247			; Jump if zero
		retn
loc_247:
		mov	byte ptr cs:data_128e,0FFh
		mov	byte ptr cs:data_123e,0
		retn
player_func_51		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

fill_buffer_2		proc	near
		test	byte ptr cs:data_128e,0FFh
		jnz	loc_248			; Jump if not zero
		retn
loc_248:
		mov	byte ptr cs:data_128e,0
		push	cs
		pop	es
		mov	di,data_129e
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	byte ptr cs:data_124e,0
		retn
fill_buffer_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_process_loop_2		proc	near
		xor	ah,ah			; Zero register

locloop_249:
		push	cx
		push	si
		push	ax
		call	word ptr cs:data_79e
		pop	ax
		push	ax
		mov	al,ah
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		add	ax,ax
		add	ax,ax
		add	bx,ax
		add	bx,ds:data_167e
		add	bx,300h
		call	word ptr cs:data_80e
		pop	ax
		inc	al
		inc	ah
		pop	si
		pop	cx
		loop	locloop_249		; Loop if cx > 0

		retn
player_process_loop_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

player_copy_buf		proc	near
		call	player_func_51
		mov	byte ptr ds:data_173e,0FFh
		mov	byte ptr ds:data_158e,0
		mov	byte ptr ds:data_154e,0
		mov	byte ptr ds:data_155e,0
		mov	byte ptr ds:data_168e,0
		mov	byte ptr ds:data_127e,0
		xor	bl,bl			; Zero register
		test	byte ptr ds:data_166e,0FFh
		jz	loc_250			; Jump if zero
		call	word ptr cs:data_88e
loc_250:
		call	player_func_56
		xor	al,al			; Zero register
		call	player_func_55
loc_251:
		mov	byte ptr ds:data_211e,0
		test	word ptr cs:data_152e,1
		jz	loc_255			; Jump if zero
		push	cs
		pop	es
		mov	di,data_129e
		mov	al,60h			; '`'
		mov	cx,8

locloop_252:
		scasb				; Scan es:[di] for al
		jnz	loc_254			; Jump if not zero
		loop	locloop_252		; Loop if cx > 0

		push	si
		mov	si,data_181e
		mov	di,data_129e
		mov	cx,8
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		call	player_func_51
		call	player_func_56
		mov	byte ptr ds:data_223e,1
loc_253:
		test	word ptr cs:data_152e,1
		jnz	loc_253			; Jump if not zero
		jmp	short loc_251
loc_254:
		mov	byte ptr ds:data_223e,1Fh
		mov	byte ptr ds:data_222e,0
		mov	byte ptr ds:data_213e,0
		retn
loc_255:
		test	byte ptr ds:data_212e,0FFh
		jz	loc_258			; Jump if zero
		mov	byte ptr ds:data_223e,1
		push	si
		xor	bh,bh			; Zero register
		mov	bl,ds:data_219e
		add	bl,ds:data_203e
		add	bx,bx
		mov	si,[bx+si]
		push	cs
		pop	es
		mov	di,data_129e
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		mov	byte ptr ds:data_199e,0
		mov	di,data_129e
		mov	cx,8

locloop_256:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_257			; Jump if zero
		inc	byte ptr ds:data_199e
		stosb				; Store al to es:[di]
		loop	locloop_256		; Loop if cx > 0

loc_257:
		mov	al,ds:data_199e
		mov	ds:data_200e,al
		pop	si
		call	player_func_51
		mov	byte ptr ds:data_212e,0
		mov	ax,ds:data_201e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	bl,ds:data_202e
		mov	cx,1010h
		xor	al,al			; Zero register
		call	word ptr cs:data_47e
		call	player_func_56
		xor	al,al			; Zero register
		call	player_func_55
		jmp	loc_251
loc_258:
		mov	cx,786Fh
		push	cx
		test	byte ptr ds:data_214e,0FFh
		jz	loc_262			; Jump if zero
		mov	byte ptr ds:data_223e,1
		mov	al,ds:data_214e
		mov	byte ptr ds:data_214e,0
		cmp	al,0Dh
		jne	loc_259			; Jump if not equal
		retn
loc_259:
		cmp	al,8
		jne	loc_260			; Jump if not equal
		jmp	loc_282
loc_260:
		push	ax
		call	fill_buffer_2
		pop	ax
		xor	bx,bx			; Zero register
		mov	bl,ds:data_199e
		cmp	byte ptr ds:data_204e[bx],60h	; '`'
		jne	loc_261			; Jump if not equal
		inc	byte ptr ds:data_200e
loc_261:
		mov	ds:data_204e[bx],al
		call	player_func_56
		mov	byte ptr ds:data_223e,1
		mov	al,1
		jmp	loc_278
loc_262:
		int	61h			; ??INT Non-standard interrupt
		test	al,8
		jz	loc_264			; Jump if zero
		mov	byte ptr ds:data_223e,1
		mov	al,1
		call	player_func_55
loc_263:
		int	61h			; ??INT Non-standard interrupt
		test	al,8
		jnz	loc_263			; Jump if not zero
		mov	byte ptr ds:data_214e,0
		retn
loc_264:
		test	al,4
		jz	loc_266			; Jump if zero
		mov	byte ptr ds:data_223e,1
		mov	al,0FFh
		call	player_func_55
loc_265:
		int	61h			; ??INT Non-standard interrupt
		test	al,4
		jnz	loc_265			; Jump if not zero
		mov	byte ptr ds:data_214e,0
		retn
loc_266:
		test	byte ptr ds:data_217e,0FFh
		jnz	loc_267			; Jump if not zero
		retn
loc_267:
		and	al,3
		cmp	al,1
		jne	loc_272			; Jump if not equal
		test	byte ptr ds:data_203e,0FFh
		jz	loc_268			; Jump if zero
		mov	bl,ds:data_203e
		call	word ptr cs:data_89e
		dec	byte ptr ds:data_203e
		retn
loc_268:
		test	byte ptr ds:data_219e,0FFh
		jnz	loc_269			; Jump if not zero
		retn
loc_269:
		push	di
		push	si
		dec	byte ptr ds:data_219e
		mov	al,ds:data_219e
		add	al,ds:data_203e
		call	word ptr cs:data_79e
		mov	cx,0Ah

locloop_270:
		push	cx
		mov	bx,ds:data_218e
		add	bx,301h
		mov	al,cl
		dec	al
		mov	cl,ds:data_216e
		add	cl,cl
		mov	dl,cl
		add	cl,cl
		add	cl,cl
		add	cl,dl
		sub	cl,2
		mov	ch,ds:data_221e
		call	word ptr cs:data_81e
loc_271:
		cmp	byte ptr ds:data_211e,4
		jb	loc_271			; Jump if below
		mov	byte ptr ds:data_211e,0
		pop	cx
		loop	locloop_270		; Loop if cx > 0

		pop	si
		pop	di
		retn
loc_272:
		cmp	al,2
		je	loc_273			; Jump if equal
		retn
loc_273:
		mov	al,ds:data_203e
		add	al,ds:data_219e
		inc	al
		mov	ah,ds:data_217e
		dec	ah
		cmp	ah,al
		jae	loc_274			; Jump if above or =
		retn
loc_274:
		mov	al,ds:data_216e
		dec	al
		cmp	ds:data_203e,al
		jae	loc_275			; Jump if above or =
		mov	bl,ds:data_203e
		call	word ptr cs:data_90e
		inc	byte ptr ds:data_203e
		retn
loc_275:
		push	di
		push	si
		inc	byte ptr ds:data_219e
		mov	al,ds:data_219e
		add	al,ds:data_203e
		call	word ptr cs:data_79e
		mov	cx,0Ah

locloop_276:
		push	cx
		mov	bx,ds:data_218e
		add	bx,301h
		mov	al,cl
		neg	al
		add	al,0Ah
		mov	cl,ds:data_216e
		add	cl,cl
		mov	dl,cl
		add	cl,cl
		add	cl,cl
		add	cl,dl
		sub	cl,2
		mov	ch,ds:data_221e
		call	word ptr cs:data_82e
loc_277:
		cmp	byte ptr ds:data_211e,4
		jb	loc_277			; Jump if below
		mov	byte ptr ds:data_211e,0
		pop	cx
		loop	locloop_276		; Loop if cx > 0

		pop	si
		pop	di
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_55:
loc_278:
		push	si
		push	ax
		mov	ax,ds:data_125e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	al,ds:data_123e
		add	al,al
		add	bh,al
		mov	bl,ds:data_126e
		add	bl,8
		mov	cx,208h
		xor	al,al			; Zero register
		call	word ptr cs:data_47e
		pop	ax
		add	ds:data_123e,al
		test	byte ptr ds:data_123e,80h
		jz	loc_279			; Jump if zero
		mov	byte ptr ds:data_123e,0
loc_279:
		cmp	byte ptr ds:data_123e,8
		jb	loc_280			; Jump if below
		dec	byte ptr ds:data_123e
loc_280:
		mov	al,ds:data_124e
		cmp	ds:data_123e,al
		jb	loc_281			; Jump if below
		mov	ds:data_123e,al
loc_281:
		mov	bx,ds:data_125e
		mov	cl,ds:data_126e
		xor	ax,ax			; Zero register
		mov	al,ds:data_123e
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	bx,ax
		add	cl,8
		mov	ax,67Fh
		call	word ptr cs:data_59e
		pop	si
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

player_func_56:
		push	si
		mov	ax,ds:data_125e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	bl,ds:data_126e
		mov	cx,1008h
		xor	al,al			; Zero register
		call	word ptr cs:data_47e
		mov	bx,ds:data_125e
		mov	cl,ds:data_126e
		mov	si,7C67h
		call	word ptr cs:data_63e
		pop	si
		retn
loc_282:
		call	fill_buffer_2
		push	si
		mov	bl,ds:data_123e
		or	bl,bl			; Zero ?
		jnz	loc_283			; Jump if not zero
		inc	bl
loc_283:
		xor	bh,bh			; Zero register
		push	cs
		pop	es
		mov	si,data_129e
		add	si,bx
		mov	di,si
		dec	di
		mov	al,8
		sub	al,bl
		mov	cl,al
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		test	byte ptr ds:data_124e,0FFh
		jz	loc_284			; Jump if zero
		dec	byte ptr ds:data_124e
loc_284:
		mov	byte ptr ds:data_130e,60h	; '`'
		mov	al,0FFh
		call	player_func_55
		call	player_func_56
		pop	si
		retn
player_copy_buf		endp

		db	0, 2, 2, 3, 1, 0
		db	0, 2, 2, 3, 1, 1
		db	1, 2, 2, 0, 1, 2
		db	8 dup (1)
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
		db	7, 8, 8, 8, 8, 8
		db	7, 5, 3, 5, 6, 7
		db	7, 8, 8, 7, 8, 7
		db	7, 8, 8, 5, 6, 8
		db	5, 8, 7, 7, 8, 8
		db	8, 7, 6, 8, 8, 8
		db	7, 7, 7, 4, 8, 4
		db	7, 8, 0
		db	58 dup (0)

seg_a		ends



		end	start
