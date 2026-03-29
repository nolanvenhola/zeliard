
PAGE  59,132

;��������������������������������������������������������������������������
;��					                                 ��
;��				_106TOWNB                                ��
;��					                                 ��
;��      Created:   29-Mar-26		                                 ��
;��      Code type: zero start		                                 ��
;��      Passes:    9          Analysis	Options on: none                 ��
;��					                                 ��
;��������������������������������������������������������������������������

target		EQU   'M4'                      ; Target assembler: MASM-4.0

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
data_67e	equ	2600h			;*
data_68e	equ	278Bh			;*
data_69e	equ	3002h			;*
data_70e	equ	3004h			;*
data_71e	equ	3006h			;*
data_72e	equ	3008h			;*
data_73e	equ	300Ah			;*
data_74e	equ	300Ch			;*
data_75e	equ	300Eh			;*
data_76e	equ	3010h			;*
data_77e	equ	3012h			;*
data_78e	equ	3014h			;*
data_79e	equ	3018h			;*
data_80e	equ	301Ah			;*
data_81e	equ	301Ch			;*
data_82e	equ	301Eh			;*
data_83e	equ	3020h			;*
data_84e	equ	3024h			;*
data_85e	equ	3026h			;*
data_86e	equ	481Ch			;*
data_87e	equ	4D4Dh			;*
data_88e	equ	534Dh			;*
data_89e	equ	6014h			;*
data_90e	equ	6018h			;*
data_91e	equ	601Ah			;*
data_92e	equ	6A59h			;*
data_93e	equ	6AE9h			;*
data_95e	equ	6C93h			;*
data_96e	equ	6C9Bh			;*
data_97e	equ	6CA4h			;*
data_98e	equ	6CACh			;*
data_99e	equ	6D88h			;*
data_100e	equ	6FEDh			;*
data_101e	equ	7686h			;*
data_102e	equ	77BAh			;*
data_103e	equ	7B82h			;*
data_104e	equ	7BE2h			;*
data_105e	equ	7C42h			;*
data_106e	equ	7C43h			;*
data_107e	equ	7C44h			;*
data_108e	equ	7C45h			;*
data_109e	equ	7C46h			;*
data_110e	equ	7C47h			;*
data_111e	equ	7C49h			;*
data_112e	equ	7C4Bh			;*
data_113e	equ	7C4Ch			;*
data_114e	equ	7C4Eh			;*
data_115e	equ	7C50h			;*
data_116e	equ	7C52h			;*
data_117e	equ	7C53h			;*
data_118e	equ	7C54h			;*
data_119e	equ	7C55h			;*
data_120e	equ	7C56h			;*
data_121e	equ	7C57h			;*
data_122e	equ	7C58h			;*
data_123e	equ	7C5Ah			;*
data_124e	equ	7C5Ch			;*
data_125e	equ	7C5Dh			;*
data_126e	equ	7C5Eh			;*
data_127e	equ	7C5Fh			;*
data_128e	equ	7C60h			;*
data_129e	equ	7C62h			;*
data_130e	equ	7C63h			;*
data_131e	equ	7C64h			;*
data_132e	equ	7C67h			;*
data_133e	equ	7C6Eh			;*
data_134e	equ	7C74h			;*
data_135e	equ	7C7Ah			;*
data_136e	equ	0A000h			;*
data_137e	equ	0A002h			;*
data_138e	equ	0A004h			;*
data_139e	equ	0C000h			;*
data_140e	equ	0C002h			;*
data_141e	equ	0C004h			;*
data_142e	equ	0C007h			;*
data_143e	equ	0C009h			;*
data_144e	equ	0C00Dh			;*
data_145e	equ	0C00Fh			;*
data_146e	equ	0C011h			;*
data_147e	equ	0C015h			;*
data_148e	equ	0C01Ch			;*
data_149e	equ	0E000h			;*
data_150e	equ	0E001h			;*
data_151e	equ	0E1FDh			;*
data_152e	equ	0E1FFh			;*
data_153e	equ	0F605h			;*
data_154e	equ	0FF00h			;*
data_155e	equ	0FF14h			;*
data_156e	equ	0FF17h			;*
data_157e	equ	0FF18h			;*
data_158e	equ	0FF1Ah			;*
data_159e	equ	0FF1Dh			;*
data_160e	equ	0FF1Eh			;*
data_161e	equ	0FF24h			;*
data_162e	equ	0FF26h			;*
data_163e	equ	0FF29h			;*
data_164e	equ	0FF2Ah			;*
data_165e	equ	0FF2Ch			;*
data_166e	equ	0FF33h			;*
data_167e	equ	0FF4Ch			;*
data_168e	equ	0FF4Eh			;*
data_169e	equ	0FF4Fh			;*
data_170e	equ	0FF52h			;*
data_171e	equ	0FF53h			;*
data_172e	equ	0FF54h			;*
data_173e	equ	0FF56h			;*
data_174e	equ	0FF57h			;*
data_175e	equ	0FF58h			;*
data_176e	equ	0FF6Ah			;*
data_177e	equ	0FF6Ch			;*
data_178e	equ	0FF74h			;*
data_179e	equ	0FF75h			;*
data_180e	equ	0FF78h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_106TOWNB	proc	far

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
		mov	byte ptr ds:data_106e,0FFh
		jmp	short loc_2
			                        ;* No entry point to code
		mov	byte ptr cs:data_106e,0
loc_2:
		mov	ds,cs:data_165e
		mov	si,4100h
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,7000h
		mov	cx,0A4h
		call	word ptr cs:data_85e
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		push	cs
		pop	ds
loc_4:
		call	sub_33
		mov	byte ptr ds:[0E7h],0
		test	byte ptr ds:[49h],0FFh
		jz	loc_5			; Jump if zero
		mov	byte ptr ds:[0E8h],0
loc_5:
		call	word ptr cs:data_48e
		mov	si,ds:data_139e
		inc	si
loc_6:
		lodsb				; String [si] to al
		inc	al
		jnz	loc_6			; Jump if not zero
		lodsb				; String [si] to al
		mov	ds:data_108e,al
		lodsb				; String [si] to al
		mov	ds:data_109e,al
		mov	byte ptr ds:data_107e,0
		test	byte ptr ds:[0E8h],0FFh
		jnz	loc_8			; Jump if not zero
		test	byte ptr ds:data_108e,1
		jz	loc_7			; Jump if zero
		test	byte ptr ds:data_106e,0FFh
		jnz	loc_7			; Jump if not zero
		mov	byte ptr ds:data_107e,0FFh
loc_7:
		call	sub_24
		call	sub_22
		call	word ptr cs:data_69e
		test	byte ptr ds:[49h],0FFh
		jnz	loc_8			; Jump if not zero
		push	ds
		mov	ds,cs:data_165e
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
		call	sub_25
		xor	al,al			; Zero register
		mov	ds:data_159e,al
		mov	ds:data_160e,al
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
		mov	bx,data_86e
		xor	al,al			; Zero register
		mov	ch,42h			; 'B'
		call	word ptr cs:data_49e
		call	word ptr cs:data_54e
		call	sub_29
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
		mov	si,ds:data_139e
		inc	si
loc_11:
		lodsb				; String [si] to al
		inc	al
		jnz	loc_11			; Jump if not zero
		inc	si
		lodsb				; String [si] to al
		mov	ds:data_109e,al
		mov	si,ds:data_141e
		call	word ptr cs:data_53e
		mov	al,byte ptr ds:[80h]
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,0C017h
		mov	ds:data_164e,ax
		call	sub_27
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_12			; Jump if zero
		mov	byte ptr ds:[0E8h],0
		call	sub_24
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
		mov	byte ptr ds:data_105e,0FFh
		jmp	word ptr cs:data_138e
loc_12:
		push	cs
		pop	es
		mov	al,0FEh
		mov	di,data_149e
		mov	cx,0E0h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		call	sub_13
		test	byte ptr ds:data_107e,0FFh
		jz	loc_15			; Jump if zero
		mov	word ptr ds:data_110e,6781h
		test	byte ptr ds:[0C2h],1
		jnz	loc_13			; Jump if not zero
		mov	word ptr ds:data_110e,67F4h
loc_13:
		mov	cx,4

locloop_14:
		push	cx
		call	word ptr cs:data_110e
		call	sub_13
		pop	cx
		loop	locloop_14		; Loop if cx > 0

		call	word ptr cs:data_110e
loc_15:
		mov	byte ptr ds:data_112e,0
		test	byte ptr ds:[49h],0FFh
		jz	loc_16			; Jump if zero
		push	ds
		mov	ds,cs:data_165e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
loc_16:
		call	sub_13
		call	sub_15
		call	sub_30
		call	sub_1
		test	byte ptr ds:data_112e,0FFh
		jnz	loc_17			; Jump if not zero
		call	sub_2
loc_17:
		mov	byte ptr ds:data_112e,0
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
		mov	byte ptr ds:data_112e,0FFh
		retn

_106TOWNB	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		test	byte ptr ds:data_159e,0FFh
		jnz	loc_21			; Jump if not zero
		retn
loc_21:
		mov	byte ptr ds:data_159e,0
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		xor	bh,bh			; Zero register
		mov	dx,bx
		add	dx,word ptr ds:[80h]
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,5
		add	bx,ds:data_164e
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
		call	sub_20
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
		call	sub_3
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
		call	sub_20
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
		call	sub_3
		pop	ax
		mov	[si+5],ah
		mov	[si+2],al
		retn
sub_1		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_2		proc	near
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		xor	bh,bh			; Zero register
		mov	dx,bx
		add	dx,word ptr ds:[80h]
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,5
		add	bx,ds:data_164e
		test	byte ptr ds:[0C2h],1
		jnz	loc_30			; Jump if not zero
		inc	dx
		inc	dx
		cmp	byte ptr [bx+10h],0FDh
		je	loc_27			; Jump if equal
		retn
loc_27:
		call	sub_20
		test	byte ptr [si+2],80h
		jnz	loc_28			; Jump if not zero
		retn
loc_28:
		test	byte ptr [si+6],80h
		jnz	loc_29			; Jump if not zero
		retn
loc_29:
		or	byte ptr [si+4],1
		mov	byte ptr ds:data_124e,0FFh
		jmp	short loc_34
loc_30:
		dec	dx
		dec	dx
		cmp	byte ptr [bx-10h],0FDh
		je	loc_31			; Jump if equal
		retn
loc_31:
		call	sub_20
		test	byte ptr [si+2],80h
		jz	loc_32			; Jump if zero
		retn
loc_32:
		test	byte ptr [si+6],80h
		jnz	loc_33			; Jump if not zero
		retn
loc_33:
		or	byte ptr [si+4],1
		mov	byte ptr ds:data_124e,0FFh
		jmp	short loc_34

;���� External Entry into Subroutine ��������������������������������������

sub_3:
loc_34:
		and	byte ptr [si+6],7Fh
		mov	al,[si+7]
		push	si
		push	ax
		mov	byte ptr ds:data_158e,28h	; '('
		call	sub_14
		mov	byte ptr ds:data_179e,1Eh
		mov	ax,718h
		test	byte ptr ds:[0C2h],1
		jnz	loc_35			; Jump if not zero
		mov	ax,0B18h
loc_35:
		mov	ds:data_113e,ax
		xor	di,di			; Zero register
		mov	cx,1658h
		call	word ptr cs:data_61e
		mov	byte ptr ds:data_159e,0
		pop	bx
		mov	ax,ds:data_113e
		call	sub_4
		mov	ax,ds:data_113e
		xor	di,di			; Zero register
		mov	cx,1658h
		call	word ptr cs:data_62e
		pop	si
		mov	byte ptr ds:data_159e,0
		push	cs
		pop	es
		mov	al,0FEh
		mov	di,data_149e
		mov	cx,0E0h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	byte ptr ds:data_124e,0
		mov	byte ptr ds:data_159e,0
		mov	byte ptr ds:data_160e,0
		retn
sub_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_4		proc	near
loc_36:
		or	byte ptr ds:[0E7h],1

;���� External Entry into Subroutine ��������������������������������������

sub_5:
		mov	ds:data_115e,ax
		mov	ds:data_114e,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,ds:data_144e
		mov	si,[bx]
		mov	byte ptr ds:data_117e,0
		mov	byte ptr ds:data_118e,0
		mov	byte ptr ds:data_119e,0
		mov	byte ptr ds:data_121e,0
		mov	ds:data_122e,si
		call	sub_8
		mov	al,cl
		mov	ds:data_120e,al
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
		mov	ds:data_123e,cx
		mov	al,56h			; 'V'
		sub	al,cl
		mov	bx,ds:data_114e
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
		mov	ds:data_114e,bx
		add	bh,bh
		mov	al,0FFh
		call	word ptr cs:data_47e
loc_38:
		mov	si,ds:data_122e
		lodsb				; String [si] to al
		mov	ds:data_122e,si
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
		mov	cx,ds:data_114e
		xor	bh,bh			; Zero register
		mov	bl,ch
		add	bx,bx
		add	bx,bx
		add	bx,bx
		mov	al,ds:data_117e
		xor	ah,ah			; Zero register
		add	bx,ax
		add	bx,4
		mov	al,ds:data_118e
		mov	dl,0Ah
		mul	dl			; ax = reg * al
		add	cl,al
		add	cl,4
		pop	ax
		push	bx
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	dl,ds:data_103e[bx]
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
		mov	cl,ds:data_104e[bx]
		add	ds:data_117e,cl
		cmp	al,20h			; ' '
		je	loc_47			; Jump if equal
		jmp	loc_38
loc_47:
		mov	si,ds:data_122e
		call	sub_7
		mov	dl,ds:data_117e
		xor	dh,dh			; Zero register
		add	dx,cx
		cmp	dx,0A8h
		jae	loc_48			; Jump if above or =
		jmp	loc_38
loc_48:
		mov	byte ptr ds:data_117e,0
		inc	byte ptr ds:data_118e
		cmp	byte ptr ds:data_118e,8
		jne	loc_50			; Jump if not equal
		dec	byte ptr ds:data_118e
		mov	cx,0Ah

locloop_49:
		push	cx
		mov	bx,ds:data_114e
		add	bl,4
		mov	cx,ds:data_123e
		shr	ch,1			; Shift w/zeros fill
		sub	cl,8
		call	word ptr cs:data_60e
		pop	cx
		loop	locloop_49		; Loop if cx > 0

loc_50:
		inc	byte ptr ds:data_121e
		cmp	byte ptr ds:data_121e,7
		jae	loc_51			; Jump if above or =
		jmp	loc_38
loc_51:
		cmp	byte ptr ds:data_120e,8
		jne	loc_52			; Jump if not equal
		jmp	loc_38
loc_52:
		sub	byte ptr ds:data_120e,7
		mov	cx,ds:data_114e
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
		mov	byte ptr ds:data_159e,0
		mov	byte ptr ds:data_160e,0
		pop	bx
		pop	cx
loc_53:
		push	cx
		push	bx
		call	sub_10
		call	sub_13
		pop	bx
		pop	cx
		test	byte ptr ds:data_124e,0FFh
		jnz	loc_54			; Jump if not zero
		test	byte ptr ds:data_160e,0FFh
		jz	loc_54			; Jump if zero
		retn
loc_54:
		test	byte ptr ds:data_159e,0FFh
		jz	loc_53			; Jump if zero
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	bh,bl
		mov	bl,cl
		xor	al,al			; Zero register
		mov	cx,208h
		call	word ptr cs:data_47e
		mov	byte ptr ds:data_159e,0
		mov	byte ptr ds:data_121e,0
		mov	byte ptr ds:data_179e,1Dh
		jmp	loc_38

;���� External Entry into Subroutine ��������������������������������������

sub_6:
loc_55:
		mov	byte ptr ds:data_159e,0
		mov	byte ptr ds:data_160e,0
loc_56:
		call	sub_10
		call	sub_13
		test	byte ptr ds:data_159e,0FFh
		jz	loc_57			; Jump if zero
		retn
loc_57:
		test	byte ptr ds:data_160e,0FFh
		jz	loc_58			; Jump if zero
		retn
loc_58:
		test	byte ptr ds:data_156e,0FFh
		jnz	loc_56			; Jump if not zero
loc_59:
		call	sub_10
		call	sub_13
		test	byte ptr ds:data_159e,0FFh
		jz	loc_60			; Jump if zero
		retn
loc_60:
		test	byte ptr ds:data_160e,0FFh
		jz	loc_61			; Jump if zero
		retn
loc_61:
		test	byte ptr ds:data_156e,0FFh
		jz	loc_59			; Jump if zero
		retn

;���� External Entry into Subroutine ��������������������������������������

sub_7:
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
		add	cl,cs:data_104e[bx]
		adc	ch,bh
		jmp	short loc_62

;���� External Entry into Subroutine ��������������������������������������

sub_8:
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
		mov	cl,ds:data_104e[bx]
		mov	ch,bh
		add	dx,cx
		pop	cx
		cmp	al,20h			; ' '
		jne	loc_66			; Jump if not equal
		push	cx
		push	si
		push	dx
		call	sub_7
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
		mov	bx,ds:data_113e
		add	bh,bh
		add	bx,193Fh
		push	bx
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_47e
		pop	bx
		add	bx,103h
		mov	ds:data_172e,bx
		call	sub_47
		mov	ax,ds:data_113e
		mov	bl,0Dh
		jnc	loc_72			; Jump if carry=0
		jmp	loc_36
loc_72:
		mov	bl,0Ch
		jmp	loc_36
loc_73:
		or	byte ptr ds:[34h],80h
		mov	byte ptr ds:[9Ah],0FFh
		call	sub_25
		jmp	loc_55
loc_74:
		mov	byte ptr ds:data_124e,0FFh
		mov	bl,4
		mov	ax,ds:data_115e
		jmp	loc_36
loc_75:
		call	sub_6
		mov	bl,5
		mov	ax,ds:data_115e
		jmp	loc_36
loc_76:
		mov	bx,ds:data_113e
		add	bh,bh
		add	bx,1832h
		push	bx
		mov	cx,1219h
		mov	al,0FFh
		call	word ptr cs:data_47e
		pop	bx
		add	bx,203h
		mov	ds:data_172e,bx
		call	sub_9
		mov	ax,ds:data_113e
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
		call	sub_25
		mov	ax,ds:data_113e
		mov	bl,8
		jmp	loc_36
sub_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_9		proc	near
		mov	byte ptr ds:data_170e,2
		mov	byte ptr ds:data_171e,2
		mov	cx,2
		mov	si,6736h
		call	sub_48
		mov	byte ptr ds:data_173e,0
		xor	bl,bl			; Zero register
		call	sub_43
		jnc	loc_81			; Jump if carry=0
		mov	bl,1
loc_81:
		or	bl,bl			; Zero ?
		jnz	loc_82			; Jump if not zero
		retn
loc_82:
		stc				; Set carry flag
		retn
sub_9		endp

		db	 54h, 61h, 6Bh, 65h, 00h, 4Eh
		db	 6Fh, 20h, 54h, 61h, 6Bh, 65h
		db	 00h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_10		proc	near
		mov	ax,ds:data_114e
		sub	ah,6
		mov	cx,ds:data_123e
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
		mov	di,data_149e
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
sub_10		endp

loc_86:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[83h]
		add	bl,3
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ds:data_164e
		mov	al,[bx+7]
		call	sub_11
		jnz	loc_87			; Jump if not zero
		retn
loc_87:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		add	bx,word ptr ds:[80h]
		dec	bx
		call	sub_12
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
		sub	word ptr ds:data_164e,8
		call	word ptr cs:data_71e
		cmp	byte ptr ds:data_108e,1
		je	loc_91			; Jump if equal
		retn
loc_91:
		call	word ptr cs:data_72e
		retn
loc_92:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[83h]
		add	bl,6
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ds:data_164e
		mov	al,[bx+7]
		call	sub_11
		jnz	loc_93			; Jump if not zero
		retn
loc_93:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		add	bx,word ptr ds:[80h]
		inc	bx
		call	sub_12
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
		mov	ax,ds:data_140e
		sub	ax,23h
		mov	bx,word ptr ds:[80h]
		inc	bx
		cmp	ax,bx
		jne	loc_96			; Jump if not equal
		inc	byte ptr ds:[83h]
		retn
loc_96:
		inc	word ptr ds:[80h]
		add	word ptr ds:data_164e,8
		call	word ptr cs:data_73e
		cmp	byte ptr ds:data_108e,1
		je	loc_97			; Jump if equal
		retn
loc_97:
		call	word ptr cs:data_74e
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_11		proc	near
		mov	es,cs:data_165e
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
sub_11		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_12		proc	near
		mov	si,ds:data_145e
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
sub_12		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_13		proc	near
		call	sub_26

;���� External Entry into Subroutine ��������������������������������������

sub_14:
		call	sub_18
		call	sub_17
		call	word ptr cs:data_70e
		mov	cl,ds:data_166e
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
		call	sub_49
loc_105:
		pop	ax
		cmp	ds:data_158e,al
		jb	loc_104			; Jump if below
		mov	byte ptr ds:data_158e,0
		retn
sub_13		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_15		proc	near
		test	word ptr ds:data_157e,1
		jnz	loc_106			; Jump if not zero
		retn
loc_106:
		mov	byte ptr ds:data_179e,0Bh
		call	word ptr cs:data_48e
		call	sub_16
		call	word ptr cs:data_137e
		call	sub_16
		call	word ptr cs:data_48e
		call	sub_23
		call	word ptr cs:data_69e
		push	cs
		pop	es
		mov	al,0FEh
		mov	di,data_149e
		mov	cx,0E0h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		call	sub_14
		mov	byte ptr ds:data_159e,0
		mov	byte ptr ds:data_160e,0
		retn
sub_15		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_16		proc	near
		mov	es,cs:data_165e
		mov	di,data_3e
		mov	si,data_136e
		mov	cx,800h
		; UI strings: Take/No Take prompt
		db	'Take', 0		; 0x0000
		db	'No Take', 0		; 0x0005
		db	'No Take', 0		; 0x0005
locloop_107:
		mov	ax,es:[di]
		movsw				; Mov [si] to es:[di]
		mov	[si-2],ax
		loop	locloop_107		; Loop if cx > 0
		; UI strings: Take/No Take prompt
		db	'Take', 0		; 0x0000
		db	'No Take', 0		; 0x0005
		db	'Take', 0		; 0x0000
		db	'No Take', 0		; 0x0005
		retn
sub_16		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_17		proc	near
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
sub_17		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_18		proc	near
		push	cs
		pop	es
		xor	ax,ax			; Zero register
		mov	al,byte ptr ds:[83h]
		add	al,4
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,5
		add	ax,ds:data_164e
		push	ax
		mov	si,ax
		mov	di,data_134e
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
		mov	si,data_134e
		mov	cx,2

locloop_109:
		push	si
		mov	al,[si]
		cmp	al,0FDh
		jne	loc_111			; Jump if not equal
		call	sub_20
loc_110:
		mov	al,[si+3]
		cmp	al,0FDh
		jne	loc_111			; Jump if not equal
		add	si,8
		call	sub_21
		jmp	short loc_110
loc_111:
		pop	si
		mov	[si],al
		add	si,3
		inc	dx
		loop	locloop_109		; Loop if cx > 0

		mov	si,data_134e
		call	word ptr cs:data_75e
		pop	dx
		dec	dx
		mov	ds:data_111e,dx
		pop	si
		push	cs
		pop	es
		mov	di,data_135e
		mov	al,[si-8]
		stosb				; Store al to es:[di]
		mov	al,[si]
		stosb				; Store al to es:[di]
		mov	al,[si+8]
		stosb				; Store al to es:[di]
		mov	si,ds:data_145e
loc_112:
		call	sub_19
		or	al,al			; Zero ?
		jz	loc_113			; Jump if zero
		push	ax
		call	word ptr cs:data_78e
		pop	bx
		mov	es,cs:data_165e
		push	si
		mov	si,data_134e
		call	word ptr cs:data_76e
		pop	si
loc_113:
		add	si,8
		cmp	word ptr [si],0FFFFh
		jne	loc_112			; Jump if not equal
		mov	si,6A3Bh
		test	byte ptr ds:[0C2h],1
		jnz	loc_114			; Jump if not zero
		mov	si,data_92e
loc_114:
		xor	ax,ax			; Zero register
		mov	al,byte ptr ds:[0E7h]
		add	ax,ax
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	si,ax
		call	word ptr cs:data_77e
		retn
sub_18		endp

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

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_19		proc	near
		mov	cx,3
		mov	dx,ds:data_111e
		mov	di,data_135e

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
sub_19		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_20		proc	near
		mov	si,ds:data_145e

;���� External Entry into Subroutine ��������������������������������������

sub_21:
loc_117:
		cmp	dx,[si]
		jne	loc_118			; Jump if not equal
		retn
loc_118:
		add	si,8
		jmp	short loc_117
sub_20		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_22		proc	near
		call	sub_32

;���� External Entry into Subroutine ��������������������������������������

sub_23:
		mov	al,ds:data_155e
		push	ds
		call	dword ptr ds:data_93e
		pop	ds
		retn
sub_22		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_24		proc	near
		mov	al,ds:data_108e
		and	al,1
		mov	cl,0Bh
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,6AD3h
		mov	ax,cs
		add	ax,2000h
		mov	word ptr ds:data_93e+2,ax
		mov	es,ax
		mov	di,3300h
		mov	al,3
		call	word ptr cs:[10Ch]
		retn
sub_24		endp

			                        ;* No entry point to code
		add	[bx+di],cx
		; SAR chunk references: YMPD.BIN, CKPD.BIN
		db	'YYMPD.BIN', 0		; 0x0000
		db	001h, 00Ah		; 0x000A
		db	'CKPD.BIN', 0		; 0x000C
		db	'3', 0			; 0x0015

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_25		proc	near
loc_119:
		mov	si,ds:data_147e
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
sub_25		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_26		proc	near
		call	sub_28
		mov	si,ds:data_145e
		mov	dx,[si]
		cmp	dx,0FFFFh
		jne	$+5			; Jump if not equal
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
		mov	bx,ds:data_146e
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

;���� External Entry into Subroutine ��������������������������������������

sub_27:
loc_136:
		mov	si,ds:data_145e
loc_137:
		mov	bx,[si]
		cmp	bx,0FFFFh
		jne	loc_138			; Jump if not equal
		retn
loc_138:
		add	bx,bx
		add	bx,bx
		add	bx,bx
		mov	al,ds:data_148e[bx]
		mov	byte ptr ds:data_148e[bx],0FDh
		mov	[si+3],al
		add	si,8
		jmp	short loc_137
sub_26		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_28		proc	near
		mov	si,ds:data_145e
loc_139:
		mov	bx,[si]
		cmp	bx,0FFFFh
		jne	loc_140			; Jump if not equal
		retn
loc_140:
		mov	al,[si+3]
		cmp	al,0FDh
		je	loc_141			; Jump if equal
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,data_148e
		mov	[bx],al
loc_141:
		add	si,8
		jmp	short loc_139
sub_28		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_29		proc	near
		mov	si,data_95e
		call	word ptr cs:data_52e
		mov	si,data_96e
		call	word ptr cs:data_52e
		mov	si,data_97e
		call	word ptr cs:data_52e
		mov	si,data_98e
		call	word ptr cs:data_52e
		retn
sub_29		endp

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

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_30		proc	near
		mov	al,byte ptr ds:[83h]
		inc	al
		jnz	loc_145			; Jump if not zero
		call	sub_28
		mov	byte ptr ds:data_158e,28h	; '('
		call	sub_14
		mov	si,ds:data_142e
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
				jmp 0FFBh			; was: db 0E9h,017h,003h
loc_144:
		call	sub_31
		mov	byte ptr ds:[83h],1Ah
		mov	ax,ds:data_140e
		sub	ax,24h
		mov	word ptr ds:[80h],ax
		jmp	loc_8
loc_145:
		cmp	al,1Ch
		je	loc_146			; Jump if equal
		retn
loc_146:
		call	sub_28
		mov	byte ptr ds:data_158e,28h	; '('
		call	sub_14
		mov	si,ds:data_142e
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
				jmp 0FFBh			; was: db 0E9h,0D9h,002h
loc_149:
		call	sub_31
		mov	byte ptr ds:[83h],0
		mov	word ptr ds:[80h],0
		jmp	loc_8

;���� External Entry into Subroutine ��������������������������������������

sub_31:
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
		add	si,data_99e
		mov	es,cs:data_165e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_165e
		mov	si,data_1e
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,7000h
		mov	cx,0A0h
		call	word ptr cs:data_85e
		pop	ds
		pop	ax
		cmp	ah,ds:data_109e
		je	loc_ret_150		; Jump if equal
		mov	ds:data_109e,ah
		call	sub_32

loc_ret_150:
		retn
			                        ;* No entry point to code
		add	ds:data_87e,bx
		dec	bp
		dec	bp
		inc	cx
		dec	si
		db	 2Eh, 47h, 52h, 50h, 00h, 01h
		db	 1Fh
		db	'CMAN.GRP'
		db	0

;���� External Entry into Subroutine ��������������������������������������

sub_32:
		mov	al,0Bh
		mul	byte ptr ds:data_109e	; ax = data * al
		add	ax,6DCEh
		mov	si,ax
		mov	es,cs:data_165e
		mov	di,8000h
		mov	al,2
		call	word ptr cs:[10Ch]
		add	word ptr es:[di],8000h
		add	word ptr es:[di+2],8000h
		add	word ptr es:[di+4],8000h
		jmp	word ptr cs:data_84e
			                        ;* No entry point to code
		add	[bp+si],sp
		inc	bx
		push	ax
		sub	byte ptr ds:data_67e,24h	; '$'
		xor	[bx+si],al
		and	al,[bp+di+50h]
		inc	cx
		push	sp
		db	 2Eh, 47h, 52h, 50h, 00h, 01h
		db	'#MPAT.GRP'
		db	0, 1
		db	'$'
		db	'DPAT.GRP'
		db	0

;���� External Entry into Subroutine ��������������������������������������

sub_33:
		mov	es,cs:data_165e
		mov	si,6E1Eh
		mov	di,6000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_165e
		mov	si,6000h
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,8000h
		mov	cx,2Eh
		call	word ptr cs:data_85e
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
		mov	si,ds:data_143e
loc_152:
		cmp	word ptr [si],0FFFFh
		jne	loc_153			; Jump if not equal
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
		call	sub_28
		mov	byte ptr ds:data_158e,28h	; '('
		call	sub_14
		pop	si
		mov	al,[si+2]
		cmp	al,0FFh
		jne	loc_155			; Jump if not equal
		jmp	loc_157
loc_155:
		sub	al,8
		jc	loc_156			; Jump if carry Set
		jmp	loc_161
loc_156:
		mov	byte ptr ds:data_161e,4
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
		mov	byte ptr ds:data_105e,0FFh
		call	word ptr cs:data_136e
		call	word ptr cs:data_48e
		mov	byte ptr ds:data_105e,0
		call	word ptr cs:data_54e
		call	sub_29
		mov	si,ds:data_141e
		call	word ptr cs:data_53e
		call	sub_22
		call	word ptr cs:data_69e
		push	cs
		pop	es
		mov	al,0FEh
		mov	di,data_149e
		mov	cx,0E0h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		call	sub_25
		mov	byte ptr ds:data_158e,28h	; '('
		call	sub_14
		mov	byte ptr ds:data_159e,0
		mov	byte ptr ds:data_160e,0
		mov	byte ptr ds:[0E7h],1
		push	ds
		mov	ds,cs:data_165e
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
		call	sub_14
		test	byte ptr ds:[45h],80h
		jnz	loc_158			; Jump if not zero
		mov	byte ptr ds:data_124e,0FFh
		mov	ax,918h
		xor	bl,bl			; Zero register
		call	sub_5
		mov	byte ptr ds:data_124e,0
		or	byte ptr ds:[45h],80h
loc_158:
		mov	byte ptr ds:data_161e,4
		mov	ah,86h
		mov	byte ptr ds:[0C4h],ah
		mov	al,1
		call	word ptr cs:[10Ch]
		mov	si,data_99e
		mov	es,cs:data_165e
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
loc_159:
		test	byte ptr ds:data_162e,0FFh
		jz	loc_159			; Jump if zero
		mov	si,data_100e
		mov	es,cs:data_165e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	word ptr ds:[80h],84h
		mov	byte ptr ds:[83h],0Dh
		call	word ptr cs:data_65e
;*		jmp	loc_3			;*
				jmp 36h			; was: db 0E9h,031h,0F0h
		db	 01h, 32h
loc_161:
		push	bp
		inc	di
		dec	bp
		xor	ch,ds:data_88e
		inc	sp
		add	ss:data_153e[bp+di],dh
		jcxz	loc_162			; Jump if cx=0
		push	es
		or	ax,ax			; Zero ?
loc_162:
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
		jns	loc_163			; Jump if not sign
		add	ax,ds:data_140e
loc_163:
		mov	word ptr ds:[80h],ax
		mov	data_5,0FFh
		call	word ptr cs:data_65e
		mov	bx,6002h
		xor	al,al			; Zero register
		jmp	word ptr cs:[10Ch]
sub_30		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_34		proc	near
		push	si
		push	di
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[11Eh]
		jnc	loc_164			; Jump if carry=0
		call	sub_49
loc_164:
		pop	di
		pop	si
		test	byte ptr ds:data_105e,0FFh
		jnz	loc_165			; Jump if not zero
		retn
loc_165:
		push	si
		push	di
		call	word ptr cs:data_137e
		pop	di
		pop	si
		retn
sub_34		endp

			                        ;* No entry point to code
		mov	si,ds:data_167e
		call	sub_39
		mov	dl,ds:data_168e
		xor	dh,dh			; Zero register
		add	dx,cx
		cmp	dx,0D0h
		jb	loc_166			; Jump if below
		call	sub_35
loc_166:
		mov	byte ptr ds:data_158e,0
loc_167:
		call	sub_34
		cmp	byte ptr ds:data_158e,6
		jb	loc_167			; Jump if below
		mov	si,ds:data_167e
		lodsb				; String [si] to al
		mov	ds:data_167e,si
		cmp	al,2Fh			; '/'
		jne	loc_168			; Jump if not equal
		jmp	loc_180
loc_168:
		cmp	al,0Dh
		jne	loc_169			; Jump if not equal
		jmp	loc_180
loc_169:
		cmp	al,0Ch
		jne	loc_170			; Jump if not equal
		jmp	loc_188
loc_170:
		cmp	al,0Fh
		jne	loc_171			; Jump if not equal
		jmp	loc_185
loc_171:
		cmp	al,11h
		jne	loc_172			; Jump if not equal
		jmp	loc_186
loc_172:
		cmp	al,13h
		jne	loc_173			; Jump if not equal
		mov	byte ptr ds:data_125e,0FFh
		jmp	short loc_166
loc_173:
		cmp	al,15h
		jne	loc_174			; Jump if not equal
		mov	byte ptr ds:data_125e,0
		jmp	short loc_166
loc_174:
		cmp	al,0FFh
		jne	loc_175			; Jump if not equal
		lodsb				; String [si] to al
		mov	ds:data_167e,si
		retn
loc_175:
		or	al,al			; Zero ?
		jnz	loc_176			; Jump if not zero
		retn
loc_176:
		push	ax
		cmp	byte ptr ds:data_168e,0D0h
		jb	loc_177			; Jump if below
		call	sub_35
loc_177:
		mov	bl,ds:data_168e
		xor	bh,bh			; Zero register
		mov	cl,ds:data_169e
		mov	al,0Ah
		mul	cl			; ax = reg * al
		mov	cl,al
		pop	ax
		push	bx
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	dl,ds:data_103e[bx]
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
		mov	cl,ds:data_104e[bx]
		mov	ch,bh
		pop	bx
		add	bx,cx
		mov	ds:data_168e,bl
		test	byte ptr ds:data_125e,0FFh
		jnz	loc_178			; Jump if not zero
		cmp	al,20h			; ' '
		je	loc_178			; Jump if equal
		mov	byte ptr ds:data_179e,5
		jmp	loc_166
loc_178:
		mov	si,ds:data_167e
		call	sub_39
		mov	dl,ds:data_168e
		xor	dh,dh			; Zero register
		add	dx,cx
		cmp	dx,0D0h
		jb	loc_179			; Jump if below
		call	sub_35
loc_179:
		jmp	loc_166
loc_180:
		call	sub_35
		jmp	loc_166

;��������������������������������������������������������������������������
		; Sprite file references: MMAN.GRP, CMAN.GRP
		db	'MMMAN.GRP', 0		; 0x0000
		db	001h, 01Fh		; 0x000A
		db	'CMAN.GRP', 0		; 0x000C
		db	'CMAN.GRP', 0		; 0x000C
		call	sub_37

loc_ret_181:
		retn

;���� External Entry into Subroutine ��������������������������������������

sub_36:
loc_182:
		cmp	byte ptr ds:data_169e,5
		jae	loc_183			; Jump if above or =
		retn
loc_183:
		dec	byte ptr ds:data_169e
		mov	cx,0Ah

locloop_184:
		push	cx
		call	sub_34
		mov	bx,762h
		mov	cx,1A32h
		call	word ptr cs:data_60e
		pop	cx
		loop	locloop_184		; Loop if cx > 0
		; Pattern/sprite file references: MPAT.GRP, DPAT.GRP
		db	004h		; 0x0000
		db	080h		; 0x0002
		db	'.', 0		; 0x0003
		db	'&$0', 0		; 0x0005
		; Pattern/sprite file references: MPAT.GRP, DPAT.GRP
		db	004h		; 0x0000
		; Pattern/sprite file references: MPAT.GRP, DPAT.GRP
		db	004h		; 0x0000
		db	080h		; 0x0002
		db	'.', 0		; 0x0003
		db	'&$0', 0		; 0x0005
		db	'"CP', 0		; 0x0009
		db	'.', 0		; 0x000D
		db	'&$0', 0		; 0x000F
		db	'"CPAT.GRP', 0		; 0x0013
		db	001h		; 0x001D
		db	'#MPAT.GRP', 0		; 0x001E
loc_185:
		call	sub_37
		jmp	loc_166
loc_186:
		call	sub_38
		jmp	loc_166

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_37		proc	near
		mov	bx,9Ch
		mov	cl,8Bh
		mov	ax,27Ch
		call	word ptr cs:data_59e
		call	sub_38
		mov	bx,data_68e
		mov	cx,20Ah
		xor	al,al			; Zero register
		call	word ptr cs:data_47e
		mov	byte ptr ds:data_116e,0
		retn
sub_37		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_38		proc	near
		mov	byte ptr ds:data_159e,0
		mov	byte ptr ds:data_160e,0
loc_187:
		call	sub_34
		mov	al,ds:data_159e
		or	al,ds:data_160e
		jz	loc_187			; Jump if zero
		mov	byte ptr ds:data_159e,0
		mov	byte ptr ds:data_160e,0
		mov	byte ptr ds:data_179e,1Dh
		retn
sub_38		endp

loc_188:
		mov	byte ptr ds:data_168e,0
		mov	byte ptr ds:data_169e,0
		mov	byte ptr ds:data_116e,0
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_47e
		jmp	loc_166

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_39		proc	near
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
loc_189:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_190			; Jump if zero
		cmp	al,0FFh
		je	loc_190			; Jump if equal
		cmp	al,20h			; ' '
		je	loc_190			; Jump if equal
		cmp	al,2Fh			; '/'
		je	loc_190			; Jump if equal
		cmp	al,0Dh
		je	loc_190			; Jump if equal
		cmp	al,0Ch
		je	loc_190			; Jump if equal
		mov	ah,al
		sub	al,20h			; ' '
		jc	loc_189			; Jump if carry Set
		inc	dx
		mov	bl,al
		xor	bh,bh			; Zero register
		add	cl,cs:data_104e[bx]
		adc	ch,bh
		jmp	short loc_189
loc_190:
		cmp	dx,1
		je	loc_191			; Jump if equal
		retn
loc_191:
		cmp	ah,2Eh			; '.'
		je	loc_192			; Jump if equal
		cmp	ah,2Ch			; ','
		je	loc_192			; Jump if equal
		retn
loc_192:
		xor	cx,cx			; Zero register
		retn
sub_39		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_40		proc	near
		mov	si,ds:data_167e
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
loc_193:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_197			; Jump if zero
		cmp	al,0FFh
		jne	loc_194			; Jump if not equal
		; Building program file references (OMOYPRO, KENJPRO, ARMRPRO...)
		db	',', 0		; 0x0000
		db	0BEh		; 0x0002
		db	'03', 0		; 0x0004
		db	0CDh		; 0x0007
		db	'`', 0		; 0x0008
		db	0C3h, 001h, 00Bh		; 0x000A
		db	'KINGPRO', 0		; 0x000D
		db	00Bh		; 0x0015
		db	'KINGPRO.BIN', 0		; 0x0016
		; Building program file references (OMOYPRO, KENJPRO, ARMRPRO...)
		db	',', 0		; 0x0000
		db	0BEh		; 0x0002
		db	'03', 0		; 0x0004
		db	0CDh		; 0x0007
		db	'`', 0		; 0x0008
		db	0C3h, 001h, 00Bh		; 0x000A
		db	'KINGPRO', 0		; 0x000D
		db	00Bh		; 0x0015
		db	'KINGPRO.BIN', 0		; 0x0016
		db	001h, 00Ch		; 0x0022
		db	'OMOYPRO.BIN', 0		; 0x0024
		db	001h, 012h		; 0x0030
		db	'KENJPRO.BIN', 0		; 0x0032
		db	001h, 00Dh		; 0x003E
		db	'ARMRPRO.BIN', 0		; 0x0040
		db	001h, 010h		; 0x004C
		db	'DRUGPRO.BIN', 0		; 0x004E
		db	001h, 00Fh		; 0x005A
		db	'CHURPRO.BIN', 0		; 0x005C
		db	001h, 00Eh		; 0x0068
		db	'BANKPR', 0		; 0x006A
sub_41		proc	near
		xor	dh,dh			; Zero register
loc_203:
		sub	dl,bl
		jc	loc_206			; Jump if carry Set
		sub	ax,cx
		jnc	loc_204			; Jump if carry=0
		or	dl,dl			; Zero ?
		jz	loc_205			; Jump if zero
		dec	dl
loc_204:
		inc	dh
		jmp	short loc_203
loc_205:
		add	ax,cx
loc_206:
		add	dl,bl
		push	ax
		mov	al,dh
		stosb				; Store al to es:[di]
		pop	ax
		retn
sub_41		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_42		proc	near
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
sub_42		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_43		proc	near
		mov	byte ptr ds:data_159e,0
		mov	byte ptr ds:data_160e,0
		push	bx
		call	sub_44
		pop	bx
		push	bx
		call	sub_34
		pop	bx
		mov	byte ptr ds:data_158e,0
		test	byte ptr ds:data_160e,0FFh
		stc				; Set carry flag
		jz	loc_207			; Jump if zero
		retn
loc_207:
		test	byte ptr ds:data_159e,0FFh
		jz	loc_208			; Jump if zero
		clc				; Clear carry flag
		mov	byte ptr ds:data_179e,1Fh
		retn
loc_208:
		mov	ax,7353h
		push	ax
		int	61h			; ??INT Non-standard interrupt
		and	al,3
		cmp	al,1
		jne	loc_213			; Jump if not equal
		or	bl,bl			; Zero ?
		jz	loc_209			; Jump if zero
		push	bx
		call	sub_45
		pop	bx
		dec	bl
		retn
loc_209:
		test	byte ptr ds:data_173e,0FFh
		jnz	loc_210			; Jump if not zero
		retn
loc_210:
		push	di
		push	si
		push	bx
		dec	byte ptr ds:data_173e
		mov	al,ds:data_173e
		add	al,bl
		mov	bx,data_175e
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_80e
		mov	cx,0Ah

locloop_211:
		push	cx
		mov	bx,ds:data_172e
		add	bx,301h
		mov	al,cl
		dec	al
		mov	cl,ds:data_170e
		add	cl,cl
		mov	dl,cl
		add	cl,cl
		add	cl,cl
		add	cl,dl
		sub	cl,2
		mov	ch,ds:data_176e
		call	word ptr cs:data_82e
loc_212:
		call	sub_34
		cmp	byte ptr ds:data_158e,4
		jb	loc_212			; Jump if below
		mov	byte ptr ds:data_158e,0
		pop	cx
		loop	locloop_211		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		retn
loc_213:
		cmp	al,2
		je	loc_214			; Jump if equal
		retn
loc_214:
		mov	al,ds:data_170e
		dec	al
		cmp	bl,al
		jae	loc_215			; Jump if above or =
		push	bx
		call	sub_46
		pop	bx
		inc	bl
		retn
loc_215:
		mov	al,bl
		add	al,ds:data_173e
		inc	al
		mov	ah,ds:data_171e
		dec	ah
		cmp	ah,al
		jae	loc_216			; Jump if above or =
		retn
loc_216:
		push	di
		push	si
		push	bx
		inc	byte ptr ds:data_173e
		mov	al,ds:data_173e
		add	al,bl
		mov	bx,data_175e
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_80e
		mov	cx,0Ah

locloop_217:
		push	cx
		mov	bx,ds:data_172e
		add	bx,301h
		mov	al,cl
		neg	al
		add	al,0Ah
		mov	cl,ds:data_170e
		add	cl,cl
		mov	dl,cl
		add	cl,cl
		add	cl,cl
		add	cl,dl
		sub	cl,2
		mov	ch,ds:data_176e
		call	word ptr cs:data_83e
loc_218:
		call	sub_34
		cmp	byte ptr ds:data_158e,4
		jb	loc_218			; Jump if below
		mov	byte ptr ds:data_158e,0
		pop	cx
		loop	locloop_217		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		retn
sub_43		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_44		proc	near
		mov	al,0Ah
		mul	bl			; ax = reg * al
		add	ax,ds:data_172e
		add	ax,100h
		mov	bx,ax
		jmp	word ptr cs:data_79e
sub_44		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_45		proc	near
		mov	al,0Ah
		mul	bl			; ax = reg * al
		add	ax,ds:data_172e
		add	ax,100h
		mov	bx,ax
		mov	cx,0Ah

locloop_219:
		push	cx
		mov	byte ptr ds:data_158e,0
		dec	bx
		push	bx
		call	word ptr cs:data_79e
loc_220:
		call	sub_34
		cmp	byte ptr ds:data_158e,4
		jb	loc_220			; Jump if below
		pop	bx
		pop	cx
		loop	locloop_219		; Loop if cx > 0

		retn
sub_45		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_46		proc	near
		mov	al,0Ah
		mul	bl			; ax = reg * al
		add	ax,ds:data_172e
		add	ax,100h
		mov	bx,ax
		mov	cx,0Ah

locloop_221:
		push	cx
		mov	byte ptr ds:data_158e,0
		inc	bx
		push	bx
		call	word ptr cs:data_79e
loc_222:
		call	sub_34
		cmp	byte ptr ds:data_158e,4
		jb	loc_222			; Jump if below
		pop	bx
		pop	cx
		loop	locloop_221		; Loop if cx > 0

		retn
sub_46		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_47		proc	near
		mov	al,ds:data_170e
		mov	ah,ds:data_171e
		push	ax
		mov	al,ds:data_173e
		push	ax
		mov	byte ptr ds:data_170e,2
		mov	byte ptr ds:data_171e,2
		mov	cx,2
		mov	si,7513h
		call	sub_48
		mov	byte ptr ds:data_173e,0
		xor	bl,bl			; Zero register
		call	sub_43
		jnc	loc_223			; Jump if carry=0
		mov	bl,1
loc_223:
		pop	ax
		mov	ds:data_173e,al
		pop	ax
		mov	ds:data_170e,al
		mov	ds:data_171e,ah
		or	bl,bl			; Zero ?
		jnz	loc_224			; Jump if not zero
		retn
loc_224:
		stc				; Set carry flag
		retn
sub_47		endp

		db	 59h, 65h, 73h, 00h, 4Eh, 6Fh
		db	 00h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_48		proc	near
		xor	dl,dl			; Zero register

locloop_225:
		push	cx
		push	dx
		mov	al,0Ah
		mul	dl			; ax = reg * al
		add	ax,ds:data_172e
		add	ax,301h
		mov	bx,ax
		xor	cl,cl			; Zero register
		call	word ptr cs:data_64e
		pop	dx
		pop	cx
		inc	dl
		loop	locloop_225		; Loop if cx > 0

		retn
sub_48		endp

		db	 32h,0E4h

locloop_226:
		push	cx
		push	si
		push	di
		push	ax
		mov	bx,data_175e
		xlat				; al=[al+[bx]] table
		call	word ptr cs:data_80e
		pop	ax
		push	ax
		mov	al,ah
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		add	ax,ax
		add	ax,ax
		add	bx,ax
		add	bx,ds:data_172e
		add	bx,300h
		call	word ptr cs:data_81e
		pop	ax
		inc	al
		inc	ah
		pop	di
		pop	si
		pop	cx
		loop	locloop_226		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		mov	bl,byte ptr ds:[85h]
		sub	bl,dl
		jnc	loc_227			; Jump if carry=0
		retn
loc_227:
		mov	dl,bl
		mov	bx,word ptr ds:[86h]
		xchg	bx,ax
		sub	ax,bx
		jc	loc_228			; Jump if carry Set
		retn
loc_228:
		sub	dl,1
		retn
			                        ;* No entry point to code
		add	word ptr ds:[86h],ax
		adc	byte ptr ds:[85h],dl
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_49		proc	near
loc_229:
		mov	cl,0FFh
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		push	cs
		pop	es
		mov	si,7688h
		mov	al,6
		call	word ptr cs:[10Ch]
		mov	byte ptr ds:data_174e,0
		call	sub_50
		push	cs
		pop	es
		test	byte ptr cs:data_131e,0FFh
		jz	loc_230			; Jump if zero
		mov	di,data_177e
		xor	al,al			; Zero register
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	si,7688h
		jmp	short loc_233
loc_230:
		mov	si,data_177e
		mov	di,data_132e
		mov	cx,8

locloop_231:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_232			; Jump if zero
		stosb				; Store al to es:[di]
		loop	locloop_231		; Loop if cx > 0

loc_232:
		mov	byte ptr es:[di],2Eh	; '.'
		mov	byte ptr es:[di+1],55h	; 'U'
		mov	byte ptr es:[di+2],53h	; 'S'
		mov	byte ptr es:[di+3],52h	; 'R'
		mov	byte ptr es:[di+4],0
		mov	si,7C65h
		mov	byte ptr cs:data_180e,0FFh
loc_233:
		mov	di,0
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	byte ptr cs:data_180e,0
		jc	loc_234			; Jump if carry Set
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
		jmp	word ptr ds:data_101e
loc_234:
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
		mov	byte ptr cs:data_159e,0
loc_235:
		call	word ptr cs:[110h]
		test	byte ptr cs:data_159e,0FFh
		jz	loc_235			; Jump if zero
		mov	byte ptr cs:data_159e,0
		jmp	loc_229
sub_49		endp

		db	0FFh
		db	'User File'
		db	0
		db	'Not Found'
		db	 00h, 47h, 41h, 4Dh, 45h, 2Eh
		db	 42h, 49h, 00h, 00h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_50		proc	near
		mov	ax,cs
		mov	es,ax
		mov	ds,ax
		mov	di,0E000h
		mov	dx,77A8h
		call	word ptr cs:[11Ch]
		mov	di,data_149e
		inc	byte ptr [di]
		jnz	loc_236			; Jump if not zero
		dec	byte ptr [di]
loc_236:
		std				; Set direction flag
		mov	si,data_151e
		mov	di,data_152e
		mov	cx,0FFh
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		cld				; Clear direction
		mov	word ptr ds:data_150e,77BAh
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
		mov	di,data_132e
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		mov	byte ptr ds:data_126e,0
		mov	si,data_177e
		mov	di,data_132e
		mov	cx,8

locloop_237:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_238			; Jump if zero
		inc	byte ptr ds:data_126e
		stosb				; Store al to es:[di]
		loop	locloop_237		; Loop if cx > 0

loc_238:
		mov	al,ds:data_126e
		mov	ds:data_127e,al
		push	cs
		pop	es
		mov	di,data_132e
		mov	al,60h			; '`'
		mov	cx,8

locloop_239:
		scasb				; Scan es:[di] for al
		jnz	loc_240			; Jump if not zero
		loop	locloop_239		; Loop if cx > 0

		mov	si,data_102e
		mov	di,data_132e
		mov	cx,8
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
loc_240:
		mov	bx,3Ch
		mov	cl,44h			; 'D'
		mov	si,77AEh
		call	word ptr cs:data_63e
		mov	word ptr ds:data_128e,60h
		mov	byte ptr ds:data_129e,56h	; 'V'
		mov	word ptr ds:data_172e,343Bh
		mov	word ptr ds:data_176e,0Ah
		mov	al,ds:data_149e
		or	al,al			; Zero ?
		jz	loc_247			; Jump if zero
		cmp	al,5
		jb	loc_241			; Jump if below
		mov	al,5
loc_241:
		xor	ah,ah			; Zero register
		mov	cx,ax
		xor	al,al			; Zero register
		mov	si,0E001h
		jcxz	loc_242			; Jump if cx=0
		call	sub_53
loc_242:
		mov	si,0E001h
		mov	al,ds:data_149e
		mov	ds:data_171e,al
		mov	byte ptr ds:data_170e,5
		call	sub_54
		push	cs
		pop	es
		mov	di,data_177e
		mov	cx,8
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		cmp	byte ptr ds:data_127e,0
		stc				; Set carry flag
		jnz	loc_243			; Jump if not zero
		retn
loc_243:
		mov	si,data_132e
		mov	di,data_177e
loc_244:
		lodsb				; String [si] to al
		cmp	al,0FFh
		clc				; Clear carry flag
		jnz	loc_245			; Jump if not zero
		retn
loc_245:
		cmp	al,60h			; '`'
		clc				; Clear carry flag
		jnz	loc_246			; Jump if not zero
		retn
loc_246:
		stosb				; Store al to es:[di]
		jmp	short loc_244
loc_247:
		mov	ax,0FFFFh
		jmp	dword ptr cs:data_154e
sub_50		endp

			                        ;* No entry point to code
		db	 2Eh, 00h,0FFh, 2Ah, 2Eh, 75h
		db	 73h, 72h, 00h
		db	'Input name:'
		db	0
		db	'Re-Start'
		db	0

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_51		proc	near
		mov	byte ptr cs:data_131e,0
		push	cs
		pop	es
		mov	di,data_132e
		mov	al,2Dh			; '-'
		mov	cx,8
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jz	loc_248			; Jump if zero
		retn
loc_248:
		mov	byte ptr cs:data_131e,0FFh
		mov	byte ptr cs:data_126e,0
		retn
sub_51		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_52		proc	near
		test	byte ptr cs:data_131e,0FFh
		jnz	loc_249			; Jump if not zero
		retn
loc_249:
		mov	byte ptr cs:data_131e,0
		push	cs
		pop	es
		mov	di,data_132e
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	byte ptr cs:data_127e,0
		retn
sub_52		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_53		proc	near
		xor	ah,ah			; Zero register

locloop_250:
		push	cx
		push	si
		push	ax
		call	word ptr cs:data_80e
		pop	ax
		push	ax
		mov	al,ah
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		add	ax,ax
		add	ax,ax
		add	bx,ax
		add	bx,ds:data_172e
		add	bx,300h
		call	word ptr cs:data_81e
		pop	ax
		inc	al
		inc	ah
		pop	si
		pop	cx
		loop	locloop_250		; Loop if cx > 0

		retn
sub_53		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_54		proc	near
		call	sub_51
		mov	byte ptr ds:data_178e,0FFh
		mov	byte ptr ds:data_163e,0
		mov	byte ptr ds:data_159e,0
		mov	byte ptr ds:data_160e,0
		mov	byte ptr ds:data_173e,0
		mov	byte ptr ds:data_130e,0
		xor	bl,bl			; Zero register
		test	byte ptr ds:data_171e,0FFh
		jz	loc_251			; Jump if zero
		call	word ptr cs:data_89e
loc_251:
		call	sub_56
		xor	al,al			; Zero register
		call	sub_55
loc_252:
		mov	byte ptr ds:data_158e,0
		test	word ptr cs:data_157e,1
		jz	loc_256			; Jump if zero
		push	cs
		pop	es
		mov	di,data_132e
		mov	al,60h			; '`'
		mov	cx,8

locloop_253:
		scasb				; Scan es:[di] for al
		jnz	loc_255			; Jump if not zero
		loop	locloop_253		; Loop if cx > 0

		push	si
		mov	si,data_102e
		mov	di,data_132e
		mov	cx,8
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		call	sub_51
		call	sub_56
		mov	byte ptr ds:data_179e,1
loc_254:
		test	word ptr cs:data_157e,1
		jnz	loc_254			; Jump if not zero
		jmp	short loc_252
loc_255:
		mov	byte ptr ds:data_179e,1Fh
		mov	byte ptr ds:data_178e,0
		mov	byte ptr ds:data_160e,0
		retn
loc_256:
		test	byte ptr ds:data_159e,0FFh
		jz	loc_259			; Jump if zero
		mov	byte ptr ds:data_179e,1
		push	si
		xor	bh,bh			; Zero register
		mov	bl,ds:data_173e
		add	bl,ds:data_130e
		add	bx,bx
		mov	si,[bx+si]
		push	cs
		pop	es
		mov	di,data_132e
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		mov	byte ptr ds:data_126e,0
		mov	di,data_132e
		mov	cx,8

locloop_257:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_258			; Jump if zero
		inc	byte ptr ds:data_126e
		stosb				; Store al to es:[di]
		loop	locloop_257		; Loop if cx > 0

loc_258:
		mov	al,ds:data_126e
		mov	ds:data_127e,al
		pop	si
		call	sub_51
		mov	byte ptr ds:data_159e,0
		mov	ax,ds:data_128e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	bl,ds:data_129e
		mov	cx,1010h
		xor	al,al			; Zero register
		call	word ptr cs:data_47e
		call	sub_56
		xor	al,al			; Zero register
		call	sub_55
		jmp	loc_252
loc_259:
		mov	cx,786Fh
		push	cx
		test	byte ptr ds:data_163e,0FFh
		jz	loc_263			; Jump if zero
		mov	byte ptr ds:data_179e,1
		mov	al,ds:data_163e
		mov	byte ptr ds:data_163e,0
		cmp	al,0Dh
		jne	loc_260			; Jump if not equal
		retn
loc_260:
		cmp	al,8
		jne	loc_261			; Jump if not equal
		jmp	loc_283
loc_261:
		push	ax
		call	sub_52
		pop	ax
		xor	bx,bx			; Zero register
		mov	bl,ds:data_126e
		cmp	byte ptr ds:data_132e[bx],60h	; '`'
		jne	loc_262			; Jump if not equal
		inc	byte ptr ds:data_127e
loc_262:
		mov	ds:data_132e[bx],al
		call	sub_56
		mov	byte ptr ds:data_179e,1
		mov	al,1
		jmp	loc_279
loc_263:
		int	61h			; ??INT Non-standard interrupt
		test	al,8
		jz	loc_265			; Jump if zero
		mov	byte ptr ds:data_179e,1
		mov	al,1
		call	sub_55
loc_264:
		int	61h			; ??INT Non-standard interrupt
		test	al,8
		jnz	loc_264			; Jump if not zero
		mov	byte ptr ds:data_163e,0
		retn
loc_265:
		test	al,4
		jz	loc_267			; Jump if zero
		mov	byte ptr ds:data_179e,1
		mov	al,0FFh
		call	sub_55
loc_266:
		int	61h			; ??INT Non-standard interrupt
		test	al,4
		jnz	loc_266			; Jump if not zero
		mov	byte ptr ds:data_163e,0
		retn
loc_267:
		test	byte ptr ds:data_171e,0FFh
		jnz	loc_268			; Jump if not zero
		retn
loc_268:
		and	al,3
		cmp	al,1
		jne	loc_273			; Jump if not equal
		test	byte ptr ds:data_130e,0FFh
		jz	loc_269			; Jump if zero
		mov	bl,ds:data_130e
		call	word ptr cs:data_90e
		dec	byte ptr ds:data_130e
		retn
loc_269:
		test	byte ptr ds:data_173e,0FFh
		jnz	loc_270			; Jump if not zero
		retn
loc_270:
		push	di
		push	si
		dec	byte ptr ds:data_173e
		mov	al,ds:data_173e
		add	al,ds:data_130e
		call	word ptr cs:data_80e
		mov	cx,0Ah

locloop_271:
		push	cx
		mov	bx,ds:data_172e
		add	bx,301h
		mov	al,cl
		dec	al
		mov	cl,ds:data_170e
		add	cl,cl
		mov	dl,cl
		add	cl,cl
		add	cl,cl
		add	cl,dl
		sub	cl,2
		mov	ch,ds:data_176e
		call	word ptr cs:data_82e
loc_272:
		cmp	byte ptr ds:data_158e,4
		jb	loc_272			; Jump if below
		mov	byte ptr ds:data_158e,0
		pop	cx
		loop	locloop_271		; Loop if cx > 0

		pop	si
		pop	di
		retn
loc_273:
		cmp	al,2
		je	loc_274			; Jump if equal
		retn
loc_274:
		mov	al,ds:data_130e
		add	al,ds:data_173e
		inc	al
		mov	ah,ds:data_171e
		dec	ah
		cmp	ah,al
		jae	loc_275			; Jump if above or =
		retn
loc_275:
		mov	al,ds:data_170e
		dec	al
		cmp	ds:data_130e,al
		jae	loc_276			; Jump if above or =
		mov	bl,ds:data_130e
		call	word ptr cs:data_91e
		inc	byte ptr ds:data_130e
		retn
loc_276:
		push	di
		push	si
		inc	byte ptr ds:data_173e
		mov	al,ds:data_173e
		add	al,ds:data_130e
		call	word ptr cs:data_80e
		mov	cx,0Ah

locloop_277:
		push	cx
		mov	bx,ds:data_172e
		add	bx,301h
		mov	al,cl
		neg	al
		add	al,0Ah
		mov	cl,ds:data_170e
		add	cl,cl
		mov	dl,cl
		add	cl,cl
		add	cl,cl
		add	cl,dl
		sub	cl,2
		mov	ch,ds:data_176e
		call	word ptr cs:data_83e
loc_278:
		cmp	byte ptr ds:data_158e,4
		jb	loc_278			; Jump if below
		mov	byte ptr ds:data_158e,0
		pop	cx
		loop	locloop_277		; Loop if cx > 0

		pop	si
		pop	di
		retn

;���� External Entry into Subroutine ��������������������������������������

sub_55:
loc_279:
		push	si
		push	ax
		mov	ax,ds:data_128e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	al,ds:data_126e
		add	al,al
		add	bh,al
		mov	bl,ds:data_129e
		add	bl,8
		mov	cx,208h
		xor	al,al			; Zero register
		call	word ptr cs:data_47e
		pop	ax
		add	ds:data_126e,al
		test	byte ptr ds:data_126e,80h
		jz	loc_280			; Jump if zero
		mov	byte ptr ds:data_126e,0
loc_280:
		cmp	byte ptr ds:data_126e,8
		jb	loc_281			; Jump if below
		dec	byte ptr ds:data_126e
loc_281:
		mov	al,ds:data_127e
		cmp	ds:data_126e,al
		jb	loc_282			; Jump if below
		mov	ds:data_126e,al
loc_282:
		mov	bx,ds:data_128e
		mov	cl,ds:data_129e
		xor	ax,ax			; Zero register
		mov	al,ds:data_126e
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	bx,ax
		add	cl,8
		mov	ax,67Fh
		call	word ptr cs:data_59e
		pop	si
		retn

;���� External Entry into Subroutine ��������������������������������������

sub_56:
		push	si
		mov	ax,ds:data_128e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	bl,ds:data_129e
		mov	cx,1008h
		xor	al,al			; Zero register
		call	word ptr cs:data_47e
		mov	bx,ds:data_128e
		mov	cl,ds:data_129e
		mov	si,7C67h
		call	word ptr cs:data_63e
		pop	si
		retn
loc_283:
		call	sub_52
		push	si
		mov	bl,ds:data_126e
		or	bl,bl			; Zero ?
		jnz	loc_284			; Jump if not zero
		inc	bl
loc_284:
		xor	bh,bh			; Zero register
		push	cs
		pop	es
		mov	si,data_132e
		add	si,bx
		mov	di,si
		; Game loader reference: GAME.BIN
		db	0FFh, 016h, 010h, 001h		; 0x0000
		db	'.', 0		; 0x0004
		db	006h, 01Dh, 0FFh, 0FFh		; 0x0006
		db	't', 0		; 0x000A
		; Game loader reference: GAME.BIN
		db	0FFh, 016h, 010h, 001h		; 0x0000
		db	'.', 0		; 0x0004
		db	006h, 01Dh, 0FFh, 0FFh		; 0x0006
		db	't', 0		; 0x000A
		db	'.', 0		; 0x000C
		db	006h, 01Dh, 0FFh		; 0x000E
		db	0E9h		; 0x0012
		db	'+', 0		; 0x0013
		db	0FFh		; 0x0015
		db	'User Fil', 0		; 0x0016
loc_285:
		mov	byte ptr ds:data_133e,60h	; '`'
		mov	al,0FFh
		call	sub_55
		call	sub_56
		pop	si
		retn
sub_54		endp

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
		; Input/user string data
		db	0FFh, 0FFh		; 0x0000
		db	'.', 0		; 0x0002
		db	'.', 0		; 0x0004
		db	0FFh		; 0x0006
		db	'.', 0		; 0x0007
		db	0FFh		; 0x0009
		db	'*.usr', 0		; 0x000A
		db	'Input name:', 0		; 0x0010
		; Input/user string data
		db	0FFh, 0FFh		; 0x0000
		db	'.', 0		; 0x0002
		db	'.', 0		; 0x0004
		db	0FFh		; 0x0006
		db	'.', 0		; 0x0007
		db	0FFh		; 0x0009
		db	'*.usr', 0		; 0x000A
		db	'Input name:', 0		; 0x0010
		; Input/user string data
		db	0FFh, 0FFh		; 0x0000
		db	'.', 0		; 0x0002
		db	'.', 0		; 0x0004
		db	0FFh		; 0x0006
		db	'.', 0		; 0x0007
		db	0FFh		; 0x0009
		db	'*.usr', 0		; 0x000A
		db	'Input name:', 0		; 0x0010
		; Input/user string data
		db	0FFh, 0FFh		; 0x0000
		db	'.', 0		; 0x0002
		db	'.', 0		; 0x0004
		db	0FFh		; 0x0006
		db	'.', 0		; 0x0007
		db	0FFh		; 0x0009
		db	'*.usr', 0		; 0x000A
		db	'Input name:', 0		; 0x0010
		db	'Re', 0		; 0x001C