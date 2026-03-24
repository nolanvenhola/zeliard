
PAGE  59,132

;==========================================================================
;
;  ENEMY_GHOST - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	8000h			;*
data_57e	equ	2000h			;*
data_58e	equ	2002h			;*
data_59e	equ	2004h			;*
data_60e	equ	2010h			;*
data_61e	equ	2012h			;*
data_62e	equ	2016h			;*
data_63e	equ	201Ah			;*
data_64e	equ	201Ch			;*
data_65e	equ	2020h			;*
data_66e	equ	2040h			;*
data_67e	equ	2044h			;*
data_68e	equ	291Dh			;*
data_69e	equ	3016h			;*
data_70e	equ	4002h			;*
data_71e	equ	6004h			;*
data_72e	equ	6006h			;*
data_73e	equ	6008h			;*
data_74e	equ	600Ah			;*
data_75e	equ	600Ch			;*
data_76e	equ	600Eh			;*
data_77e	equ	6010h			;*
data_78e	equ	6012h			;*
data_79e	equ	7FE8h			;*
data_80e	equ	9998h			;*
data_81e	equ	0A119h			;*
data_82e	equ	0A176h			;*
data_83e	equ	0A198h			;*
data_84e	equ	0A24Bh			;*
data_85e	equ	0A498h			;*
data_86e	equ	0A6BFh			;*
data_87e	equ	0A8FDh			;*
data_88e	equ	0A90Fh			;*
data_89e	equ	0AAD0h			;*
data_90e	equ	0AB68h			;*
data_91e	equ	0AC9Ch			;*
data_92e	equ	0ACA2h			;*
data_93e	equ	0ACAEh			;*
data_94e	equ	0AD05h			;*
data_95e	equ	0AD11h			;*
data_96e	equ	0B3DEh			;*
data_97e	equ	0BAA7h			;*
data_98e	equ	0BBFDh			;*
data_99e	equ	0BBFEh			;*
data_100e	equ	0BC0Fh			;*
data_101e	equ	0BC10h			;*
data_102e	equ	0BC21h			;*
data_103e	equ	0BC22h			;*
data_104e	equ	0BC23h			;*
data_105e	equ	0BC24h			;*
data_106e	equ	0BC25h			;*
data_107e	equ	0BC26h			;*
data_108e	equ	0BC27h			;*
data_109e	equ	0BC28h			;*
data_110e	equ	0BC29h			;*
data_112e	equ	0BC2Ch			;*
data_113e	equ	0BC2Dh			;*
data_114e	equ	0BC2Fh			;*
data_115e	equ	0BC30h			;*
data_116e	equ	0BC31h			;*
data_117e	equ	0BC32h			;*
data_118e	equ	0BC3Bh			;*
data_119e	equ	0BC41h			;*
data_120e	equ	0C006h			;*
data_121e	equ	0FF1Ah			;*
data_122e	equ	0FF2Ch			;*
data_123e	equ	0FF4Ch			;*
data_124e	equ	0FF4Eh			;*
data_125e	equ	0FF4Fh			;*
data_126e	equ	0FF50h			;*
data_127e	equ	0FF52h			;*
data_128e	equ	0FF53h			;*
data_129e	equ	0FF54h			;*
data_130e	equ	0FF56h			;*
data_131e	equ	0FF57h			;*
data_132e	equ	0FF58h			;*
data_133e	equ	0FF68h			;*
data_134e	equ	0FF6Ah			;*
data_135e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_12		proc	far

start:
		inc	di
		sbb	al,0
		add	[si],al
		mov	al,ds:data_88e
		mov	es,ds:data_122e
		mov	di,8000h
		mov	si,data_92e
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_122e
		mov	si,data_1e
		mov	cx,100h
		call	word ptr cs:data_67e
		pop	ds
		mov	byte ptr ds:data_124e,0
		mov	byte ptr ds:data_125e,0
		mov	byte ptr ds:data_102e,0
		call	word ptr cs:data_58e
		call	word ptr cs:data_61e
		mov	si,data_93e
		call	word ptr cs:data_60e
		call	ghost_process_loop
		call	ghost_process_loop_2
		push	cs
		pop	es
		mov	bl,ds:data_120e
		dec	bl
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:data_97e[bx]
		mov	di,data_98e
		mov	cx,12h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		xor	al,al			; Zero register
		call	ghost_func_10
		mov	byte ptr ds:data_104e,0FFh
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_57e
		mov	word ptr ds:data_123e,0ADD3h
		test	byte ptr ds:[24h],2
		jnz	loc_1			; Jump if not zero
		cmp	byte ptr ds:data_120e,5
		jne	loc_1			; Jump if not equal
		test	byte ptr ds:[9Bh],0FFh
		jz	loc_1			; Jump if zero
		mov	word ptr ds:data_123e,0B2A2h
		mov	byte ptr ds:data_104e,0
loc_1:
		call	word ptr cs:data_71e
		cmp	al,0FFh
		je	loc_2			; Jump if equal
		call	ghost_func_3
		jmp	short loc_1
loc_2:
		jmp	word ptr cs:data_66e

zr2_12		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

ghost_process_loop		proc	near
		mov	si,0D2h
		mov	al,ds:data_120e
		dec	al
		xor	ah,ah			; Zero register
		add	si,ax
		mov	dl,[si]
		push	cs
		pop	es
		mov	di,data_118e
		xor	dh,dh			; Zero register
		mov	cx,6

locloop_3:
		add	dl,dl
		jnc	loc_5			; Jump if carry=0
		mov	al,cl
		neg	al
		add	al,6
		stosb				; Store al to es:[di]
		inc	dh
loc_5:
		loop	locloop_3		; Loop if cx > 0

		mov	ds:data_116e,dh
		retn
ghost_process_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

ghost_process_loop_2		proc	near
		mov	si,0DBh
		mov	al,ds:data_120e
		dec	al
		xor	ah,ah			; Zero register
		add	si,ax
		mov	dl,[si]
		push	cs
		pop	es
		mov	di,data_119e
		xor	dh,dh			; Zero register
		mov	cx,6

locloop_6:
		add	dl,dl
		jnc	loc_7			; Jump if carry=0
		mov	al,cl
		neg	al
		add	al,6
		stosb				; Store al to es:[di]
		inc	dh
loc_7:
		loop	locloop_6		; Loop if cx > 0

		mov	ds:data_117e,dh
		retn
ghost_process_loop_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

ghost_func_3		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:data_81e[bx]	;*
ghost_func_3		endp

			                        ;* No entry point to code
		sub	ax,59A1h
		mov	ds:data_85e,al
		retf
			                        ;* No entry point to code
		cmpsb				; Cmp [si] to es:[di]
		push	es
		cmpsw				; Cmp [si] to es:[di]
		push	ss
		cmpsw				; Cmp [si] to es:[di]
		pop	cx
		cmpsw				; Cmp [si] to es:[di]
;*		jo	loc_4			;*Jump if overflow=1
		db	 70h,0A8h		;  Fixup - byte match
		sub	byte ptr ds:data_87e[bx+si],0E8h
		rol	byte ptr [bx],cl	; Rotate
		mov	bx,data_68e
		mov	cx,1837h
		mov	al,0FFh
		call	word ptr cs:data_57e
		mov	word ptr ds:data_129e,2920h
		mov	byte ptr ds:data_127e,5
		mov	byte ptr ds:data_128e,5
		mov	cx,5
		mov	si,0ACC8h
		call	word ptr cs:data_76e
		mov	byte ptr ds:data_130e,0
		mov	bl,ds:data_102e
		call	word ptr cs:data_77e
		jnc	loc_8			; Jump if carry=0
		xor	bl,bl			; Zero register
loc_8:
		mov	ds:data_102e,bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_82e[bx]	;*
			                        ;* No entry point to code
		and	byte ptr ds:data_83e[bx+di],44h	; 'D'
		mov	ds:data_84e,al
		push	dx
		mov	ds:data_79e,al
		pop	es
		mov	si,0B1DEh
		test	byte ptr ds:data_109e,0FFh
		jnz	loc_9			; Jump if not zero
;*		call	ghost_func_5			;*
		db	0E8h, 76h, 05h		;  Fixup - byte match
		mov	si,0B1FFh
loc_9:
		mov	ds:data_123e,si
		retn
			                        ;* No entry point to code
		call	ghost_func_8
		test	byte ptr ds:[93h],0FFh
		jnz	loc_10			; Jump if not zero
		mov	word ptr ds:data_123e,0AE4Ah
		retn
loc_10:
		mov	ax,word ptr ds:[96h]
		sub	ax,word ptr ds:[94h]
		jnz	loc_11			; Jump if not zero
		mov	word ptr ds:data_123e,0AEB1h
		retn
loc_11:
		mov	byte ptr ds:data_109e,0FFh
		shr	ax,1			; Shift w/zeros fill
		adc	ax,0
		mov	ds:data_110e,ax
		mov	word ptr ds:data_123e,0AEF8h
		call	word ptr cs:data_71e
		xor	dl,dl			; Zero register
		mov	ax,ds:data_110e
		mov	di,0BC33h
		call	word ptr cs:data_72e
		mov	si,ds:data_123e
		push	si
		mov	word ptr ds:data_123e,0BC33h
		call	word ptr cs:data_71e
		pop	si
		mov	ds:data_123e,si
		call	word ptr cs:data_71e
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_57e
		mov	word ptr ds:data_129e,302Eh
		call	word ptr cs:data_73e
		pushf				; Push flags
		call	ghost_func_8
		popf				; Pop flags
		mov	word ptr ds:data_123e,0ADEFh
		jnc	loc_12			; Jump if carry=0
		retn
loc_12:
		mov	ax,ds:data_110e
		xor	dl,dl			; Zero register
		call	word ptr cs:data_74e
		mov	word ptr ds:data_123e,0AF53h
		jnc	loc_13			; Jump if carry=0
		retn
loc_13:
		mov	byte ptr ds:[85h],dl
		mov	word ptr ds:[86h],ax
		call	word ptr cs:data_62e
		mov	word ptr ds:data_123e,0AFAFh
		retn
			                        ;* No entry point to code
		mov	word ptr ds:data_123e,0B026h
		retn
			                        ;* No entry point to code
		mov	word ptr ds:data_123e,0B081h
		retn
			                        ;* No entry point to code
		mov	word ptr ds:data_123e,0B11Fh
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_109e,0FFh
		push	cs
		pop	es
		mov	di,data_132e
		mov	si,data_118e
		mov	cx,6
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	al,ds:data_116e
		mov	ds:data_128e,al
		cmp	al,3
		jb	loc_14			; Jump if below
		mov	al,3
loc_14:
		mov	ds:data_127e,al
		mov	byte ptr ds:data_130e,0
		mov	byte ptr ds:data_103e,0
		mov	bx,156Eh
		mov	cx,2524h
		mov	al,0FFh
		call	word ptr cs:data_57e
		mov	byte ptr ds:data_131e,0FFh
		mov	word ptr ds:data_129e,1571h
		mov	word ptr ds:data_134e,21h
		mov	word ptr ds:data_133e,17h
		mov	si,0AD05h
		mov	di,0BBFDh
		mov	cl,ds:data_127e
		xor	ch,ch			; Zero register
		mov	al,ds:data_130e
		call	word ptr cs:data_78e
		mov	bl,ds:data_103e
		call	word ptr cs:data_77e
		jnc	loc_15			; Jump if carry=0
		mov	word ptr ds:data_123e,0ADEFh
		retn
loc_15:
		mov	ds:data_103e,bl
		mov	al,bl
		add	al,ds:data_130e
		mov	bx,data_132e
		xlat				; al=[al+[bx]] table
		call	ghost_func_4
		push	ax
		mov	word ptr ds:data_123e,0B0DCh
		call	word ptr cs:data_71e
		pop	ax
		push	ax
		mov	si,ds:data_123e
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:data_94e[bx]
		mov	ds:data_123e,ax
		call	word ptr cs:data_71e
		pop	si
		mov	ds:data_123e,si
		call	word ptr cs:data_71e
		pop	ax
		push	ax
		xor	ah,ah			; Zero register
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		mov	si,data_98e
		add	si,ax
		mov	dl,[si]
		mov	ax,[si+1]
		mov	ds:data_110e,dl
		mov	word ptr ds:data_110e+1,ax
		call	word ptr cs:data_74e
		pop	bx
		mov	word ptr ds:data_123e,0AF54h
		jnc	loc_16			; Jump if carry=0
		retn
loc_16:
		mov	ds:data_112e,dl
		mov	ds:data_113e,ax
		inc	bl
		mov	ds:data_114e,bl
		mov	word ptr ds:data_123e,0B106h
		call	word ptr cs:data_71e
		mov	dl,ds:data_110e
		mov	ax,word ptr ds:data_110e+1
		mov	di,0BC33h
		call	word ptr cs:data_72e
		mov	si,ds:data_123e
		push	si
		mov	word ptr ds:data_123e,0BC33h
		call	word ptr cs:data_71e
		pop	si
		mov	ds:data_123e,si
		call	word ptr cs:data_71e
		mov	byte ptr ds:data_110e,0
		mov	word ptr ds:data_110e+1,0
		test	byte ptr ds:[92h],0FFh
		jz	loc_17			; Jump if zero
		mov	al,byte ptr ds:[92h]
		mov	ds:data_115e,al
		mov	word ptr ds:data_123e,0B046h
		call	word ptr cs:data_71e
		mov	al,ds:data_115e
		dec	al
		xor	ah,ah			; Zero register
		mov	bx,ax
		add	ax,ax
		add	bx,ax
		mov	dl,ds:data_98e[bx]
		mov	ax,ds:data_99e[bx]
		shr	dl,1			; Shift w/zeros fill
		rcr	ax,1			; Rotate thru carry
		mov	ds:data_110e,dl
		mov	word ptr ds:data_110e+1,ax
		mov	di,0BC33h
		call	word ptr cs:data_72e
		mov	si,ds:data_123e
		push	si
		mov	word ptr ds:data_123e,0BC33h
		call	word ptr cs:data_71e
		pop	si
		mov	ds:data_123e,si
		call	word ptr cs:data_71e
loc_17:
		mov	word ptr ds:data_123e,0B0EDh
		call	word ptr cs:data_71e
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_57e
		mov	word ptr ds:data_129e,302Eh
		call	word ptr cs:data_73e
		mov	word ptr ds:data_123e,0ADEFh
		jnc	loc_18			; Jump if carry=0
		retn
loc_18:
		mov	word ptr ds:data_123e,0AE1Ch
		mov	dl,ds:data_112e
		mov	ax,ds:data_113e
		mov	byte ptr ds:[85h],dl
		mov	word ptr ds:[86h],ax
		mov	dl,ds:data_110e
		mov	ax,word ptr ds:data_110e+1
		call	word ptr cs:data_75e
		call	word ptr cs:data_62e
		test	byte ptr ds:data_115e,0FFh
		jz	loc_19			; Jump if zero
		mov	al,ds:data_115e
		dec	al
		mov	bx,data_91e
		xlat				; al=[al+[bx]] table
		mov	bl,ds:data_120e
		dec	bl
		xor	bh,bh			; Zero register
		or	byte ptr ds:[0D2h][bx],al
loc_19:
		mov	al,ds:data_114e
		mov	byte ptr ds:[92h],al
		cmp	al,6
		jne	loc_20			; Jump if not equal
		mov	bl,ds:data_120e
		dec	bl
		xor	bh,bh			; Zero register
		and	byte ptr ds:[0D2h][bx],0FBh
loc_20:
		call	ghost_process_loop
		mov	ah,byte ptr ds:[92h]
		mov	al,4
		call	word ptr cs:[10Ch]
		mov	al,byte ptr ds:[92h]
		mov	bx,18ABh
		jmp	word ptr cs:data_64e

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

ghost_func_4		proc	near
		cmp	al,3
		je	loc_21			; Jump if equal
		retn
loc_21:
		test	byte ptr ds:[24h],2
		jz	loc_22			; Jump if zero
		retn
loc_22:
		cmp	byte ptr ds:data_120e,5
		je	loc_23			; Jump if equal
		retn
loc_23:
		pop	ax
		mov	word ptr ds:data_123e,0B24Ch
		retn
ghost_func_4		endp

			                        ;* No entry point to code
		mov	byte ptr ds:data_109e,0FFh
		push	cs
		pop	es
		mov	di,data_132e
		mov	si,data_119e
		mov	cx,6
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	al,ds:data_117e
		mov	ds:data_128e,al
		cmp	al,3
		jb	loc_24			; Jump if below
		mov	al,3
loc_24:
		mov	ds:data_127e,al
		mov	byte ptr ds:data_130e,0
		mov	byte ptr ds:data_103e,0
		mov	bx,156Eh
		mov	cx,2524h
		mov	al,0FFh
		call	word ptr cs:data_57e
		mov	byte ptr ds:data_131e,0FFh
		mov	word ptr ds:data_129e,1571h
		mov	word ptr ds:data_134e,21h
		mov	word ptr ds:data_133e,17h
		mov	si,0AD11h
		mov	di,0BC0Fh
		mov	cl,ds:data_127e
		xor	ch,ch			; Zero register
		mov	al,ds:data_130e
		call	word ptr cs:data_78e
		mov	bl,ds:data_103e
		call	word ptr cs:data_77e
		jnc	loc_25			; Jump if carry=0
		mov	word ptr ds:data_123e,0ADEFh
		retn
loc_25:
		mov	ds:data_103e,bl
		mov	word ptr ds:data_123e,0B0DCh
		call	word ptr cs:data_71e
		mov	al,ds:data_103e
		add	al,ds:data_130e
		mov	bx,data_132e
		xlat				; al=[al+[bx]] table
		push	ax
		mov	si,ds:data_123e
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:data_95e[bx]
		mov	ds:data_123e,ax
		call	word ptr cs:data_71e
		pop	si
		mov	ds:data_123e,si
		call	word ptr cs:data_71e
		pop	ax
		push	ax
		xor	ah,ah			; Zero register
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		mov	si,data_100e
		add	si,ax
		mov	dl,[si]
		mov	ax,[si+1]
		mov	ds:data_110e,dl
		mov	word ptr ds:data_110e+1,ax
		call	word ptr cs:data_74e
		pop	bx
		mov	word ptr ds:data_123e,0AF54h
		jnc	loc_26			; Jump if carry=0
		retn
loc_26:
		mov	ds:data_112e,dl
		mov	ds:data_113e,ax
		inc	bl
		mov	ds:data_114e,bl
		mov	word ptr ds:data_123e,0B106h
		call	word ptr cs:data_71e
		mov	dl,ds:data_110e
		mov	ax,word ptr ds:data_110e+1
		mov	di,0BC33h
		call	word ptr cs:data_72e
		mov	si,ds:data_123e
		push	si
		mov	word ptr ds:data_123e,0BC33h
		call	word ptr cs:data_71e
		pop	si
		mov	ds:data_123e,si
		call	word ptr cs:data_71e
		mov	byte ptr ds:data_110e,0
		mov	word ptr ds:data_110e+1,0
		test	byte ptr ds:[93h],0FFh
		jz	loc_27			; Jump if zero
		mov	al,byte ptr ds:[93h]
		mov	ds:data_115e,al
		mov	word ptr ds:data_123e,0B0A1h
		call	word ptr cs:data_71e
		mov	al,ds:data_115e
		dec	al
		xor	ah,ah			; Zero register
		mov	bx,ax
		add	ax,ax
		add	bx,ax
		mov	dl,ds:data_100e[bx]
		mov	ax,ds:data_101e[bx]
		shr	dl,1			; Shift w/zeros fill
		rcr	ax,1			; Rotate thru carry
		mov	ds:data_110e,dl
		mov	word ptr ds:data_110e+1,ax
		mov	di,0BC33h
		call	word ptr cs:data_72e
		mov	si,ds:data_123e
		push	si
		mov	word ptr ds:data_123e,0BC33h
		call	word ptr cs:data_71e
		pop	si
		mov	ds:data_123e,si
		call	word ptr cs:data_71e
loc_27:
		mov	word ptr ds:data_123e,0B0EDh
		call	word ptr cs:data_71e
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_57e
		mov	word ptr ds:data_129e,302Eh
		call	word ptr cs:data_73e
		mov	word ptr ds:data_123e,0ADEFh
		jnc	loc_28			; Jump if carry=0
		retn
loc_28:
		mov	word ptr ds:data_123e,0AE1Ch
		mov	dl,ds:data_112e
		mov	ax,ds:data_113e
		mov	byte ptr ds:[85h],dl
		mov	word ptr ds:[86h],ax
		mov	dl,ds:data_110e
		mov	ax,word ptr ds:data_110e+1
		call	word ptr cs:data_75e
		call	word ptr cs:data_62e
		test	byte ptr ds:data_115e,0FFh
		jz	loc_29			; Jump if zero
		mov	al,ds:data_115e
		dec	al
		mov	bx,data_91e
		xlat				; al=[al+[bx]] table
		mov	bl,ds:data_120e
		dec	bl
		xor	bh,bh			; Zero register
		or	byte ptr ds:[0DBh][bx],al
loc_29:
		mov	al,ds:data_114e
		mov	byte ptr ds:[93h],al
		call	ghost_process_loop_2
		mov	al,byte ptr ds:[93h]
		mov	bx,3EA4h
		call	word ptr cs:data_65e
		mov	bx,0C61Ch
		xor	al,al			; Zero register
		mov	ch,17h
		call	word ptr cs:data_59e
		mov	bl,byte ptr ds:[93h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,ds:data_86e[bx]
		mov	word ptr ds:[96h],ax
		mov	word ptr ds:[94h],ax
		jmp	word ptr cs:data_63e
			                        ;* No entry point to code
		push	ds
;*		add	[bx+si+0],dl
		db	 00h, 50h, 00h		;  Fixup - byte match
		db	0B4h, 00h, 2Ch, 01h, 2Ch, 01h
		db	 58h, 02h,0C6h, 06h, 23h,0BCh
		db	 00h,0F6h, 06h, 26h,0BCh,0FFh
		db	 74h, 08h,0B0h, 01h,0E8h,0F3h
		db	 02h,0E8h, 91h, 01h,0BEh,0FDh
		db	0A6h
loc_30:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_31			; Jump if not equal
		retn
loc_31:
		push	si
		or	al,al			; Zero ?
		jns	loc_32			; Jump if not sign
		mov	byte ptr ds:data_135e,20h	; ' '
loc_32:
		and	al,7
		call	ghost_func_10
		call	ghost_func_6
		pop	si
		jmp	short loc_30
			                        ;* No entry point to code
		add	ax,[si]
		add	ax,8605h
		push	es
		pop	es
		pop	es
;*		inc	si
		db	0FFh,0C6h		;  Fixup - byte match
		push	es
		sbb	bh,bh
;*		add	al,ch
		db	 00h,0E8h		;  Fixup - byte match
		add	[bp+si],ax
		cmp	byte ptr ds:data_121e,96h
;*		jb	loc_33			;*Jump if below
		db	 72h,0F6h		;  Fixup - byte match
		retn
			                        ;* No entry point to code
		call	word ptr cs:data_66e
		mov	word ptr ds:data_126e,0
loc_34:
		cmp	word ptr ds:data_126e,190h
		jb	loc_34			; Jump if below
		mov	ax,word ptr ds:[96h]
		mov	word ptr ds:[94h],ax
		call	word ptr cs:data_63e
		mov	byte ptr ds:data_105e,0
		mov	byte ptr ds:data_106e,0
		mov	byte ptr ds:data_107e,0
		mov	byte ptr ds:data_108e,0
		xor	al,al			; Zero register
		call	ghost_func_10
		mov	byte ptr ds:data_104e,0FFh
		mov	word ptr ds:data_123e,0AFE0h
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_103e,0
		mov	byte ptr ds:data_130e,0
loc_35:
		push	cs
		pop	es
		mov	cl,ds:data_116e
		xor	ch,ch			; Zero register
		mov	si,data_118e
		mov	di,data_132e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	cl,ds:data_117e
		mov	si,data_119e

locloop_36:
		lodsb				; String [si] to al
		add	al,6
		stosb				; Store al to es:[di]
		loop	locloop_36		; Loop if cx > 0

		mov	al,ds:data_116e
		add	al,ds:data_117e
		mov	ds:data_128e,al
		mov	al,ds:data_128e
		cmp	al,6
		jb	loc_37			; Jump if below
		mov	al,6
loc_37:
		mov	ds:data_127e,al
		mov	bx,2717h
		mov	cx,1B41h
		mov	al,0FFh
		call	word ptr cs:data_57e
		mov	byte ptr ds:data_131e,0
		mov	word ptr ds:data_129e,271Ah
		mov	word ptr ds:data_134e,17h
		mov	si,data_94e
		mov	cl,ds:data_127e
		xor	ch,ch			; Zero register
		mov	al,ds:data_130e
		call	word ptr cs:data_78e
		mov	bl,ds:data_103e
		call	word ptr cs:data_77e
		jnc	loc_38			; Jump if carry=0
		mov	word ptr ds:data_123e,0ADEFh
		retn
loc_38:
		mov	ds:data_103e,bl
		mov	word ptr ds:data_123e,0B0EAh
		call	word ptr cs:data_71e
		mov	al,ds:data_103e
		add	al,ds:data_130e
		mov	bx,data_132e
		xlat				; al=[al+[bx]] table
		call	ghost_func_7
		push	ax
		push	ax
		mov	word ptr ds:data_123e,0B0DDh
		call	word ptr cs:data_71e
		pop	ax
		mov	si,ds:data_123e
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:data_94e[bx]
		mov	ds:data_123e,ax
		call	word ptr cs:data_71e
		pop	si
		mov	ds:data_123e,si
		call	word ptr cs:data_71e
		pop	ax
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:data_96e[bx]
		mov	ds:data_123e,ax
		call	word ptr cs:data_71e
		mov	word ptr ds:data_123e,0B1A9h
		call	word ptr cs:data_71e
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_57e
		mov	word ptr ds:data_129e,302Eh
		call	word ptr cs:data_73e
		mov	word ptr ds:data_123e,0ADEFh
		jnc	loc_39			; Jump if carry=0
		retn
loc_39:
		mov	word ptr ds:data_123e,0B17Eh
		call	word ptr cs:data_71e
		jmp	loc_35

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

ghost_func_6		proc	near
		mov	byte ptr ds:data_121e,0
loc_40:
		call	ghost_check_state
		cmp	byte ptr ds:data_121e,32h	; '2'
		jb	loc_40			; Jump if below
		retn
ghost_func_6		endp

			                        ;* No entry point to code
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_57e
		mov	word ptr ds:data_129e,302Eh
		call	word ptr cs:data_73e
		pushf				; Push flags
		call	ghost_func_8
		popf				; Pop flags
		mov	word ptr ds:data_123e,0B336h
		jnc	loc_41			; Jump if carry=0
		retn
loc_41:
		xor	al,al			; Zero register
		call	ghost_func_10
		mov	word ptr ds:data_123e,0B375h
		call	word ptr cs:data_71e
		mov	byte ptr ds:[92h],4
		mov	byte ptr ds:[9Bh],0
		mov	al,4
		mov	bx,18ABh
		call	word ptr cs:data_64e
		and	byte ptr ds:[0D6h],0EFh
		or	byte ptr ds:[24h],2
		mov	ah,byte ptr ds:[92h]
		mov	al,4
		call	word ptr cs:[10Ch]
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

ghost_func_7		proc	near
		cmp	al,3
		je	loc_42			; Jump if equal
		retn
loc_42:
		test	byte ptr ds:[24h],2
		jz	loc_43			; Jump if zero
		retn
loc_43:
		cmp	byte ptr ds:data_120e,5
		je	loc_44			; Jump if equal
		retn
loc_44:
		pop	ax
		mov	word ptr ds:data_123e,0B240h
		retn
ghost_func_7		endp

		db	0B0h, 03h,0E9h,0CDh, 00h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

ghost_func_8		proc	near
		mov	bx,2717h
		mov	cx,1C41h
		xor	al,al			; Zero register
		jmp	word ptr cs:data_57e
ghost_func_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

ghost_check_state		proc	near
		test	byte ptr ds:data_104e,0FFh
		jnz	loc_45			; Jump if not zero
		retn
loc_45:
		cmp	word ptr ds:data_126e,2
		jae	loc_46			; Jump if above or =
		retn
loc_46:
		mov	word ptr ds:data_126e,0
		inc	byte ptr ds:data_105e
		cmp	byte ptr ds:data_105e,1Eh
		jae	loc_47			; Jump if above or =
		retn
loc_47:
		mov	byte ptr ds:data_105e,0
		inc	byte ptr ds:data_106e
		test	byte ptr ds:data_107e,0FFh
		jz	loc_51			; Jump if zero
		cmp	byte ptr ds:data_107e,7Fh
		jne	loc_48			; Jump if not equal
		mov	byte ptr ds:data_107e,0FFh
		mov	al,2
		jmp	short loc_56
loc_48:
		cmp	byte ptr ds:data_107e,80h
		jne	loc_49			; Jump if not equal
		mov	byte ptr ds:data_107e,0
		xor	al,al			; Zero register
		jmp	short loc_56
loc_49:
		mov	si,data_90e
		mov	al,ds:data_106e
		and	ax,3
		add	ax,ax
		add	si,ax
		mov	bx,0B37h
		mov	cx,2

locloop_50:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_69e
		pop	bx
		add	bl,8
		pop	cx
		loop	locloop_50		; Loop if cx > 0

		jmp	short loc_53
loc_51:
		mov	si,data_89e
		mov	al,ds:data_106e
		and	ax,3
		add	ax,ax
		add	si,ax
		mov	bx,104Fh
		mov	cx,2

locloop_52:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_69e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_52		; Loop if cx > 0

loc_53:
		call	word ptr cs:[11Ah]
		and	al,1
		jz	loc_54			; Jump if zero
		retn
loc_54:
		inc	byte ptr ds:data_108e
		cmp	byte ptr ds:data_108e,1Eh
		jae	loc_55			; Jump if above or =
		retn
loc_55:
		mov	byte ptr ds:data_108e,0
		mov	al,ds:data_107e
		not	al
		xor	al,80h
		mov	ds:data_107e,al
		mov	al,1
		jmp	short loc_56

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

ghost_func_10:
loc_56:
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	cx,ax
		add	ax,ax
		add	ax,cx
		add	ax,0AA10h
		mov	si,ax
		mov	bx,717h
		mov	cx,2

locloop_57:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_58			; Jump if not zero
		retn
loc_58:
		push	cx
		mov	cl,al
		lodsw				; String [si] to ax
		xchg	si,ax
		push	ax

locloop_59:
		push	cx
		mov	cx,0Ch

locloop_60:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_69e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_60		; Loop if cx > 0

		sub	bh,0Ch
		add	bl,8
		pop	cx
		loop	locloop_59		; Loop if cx > 0

		pop	si
		pop	cx
		loop	locloop_57		; Loop if cx > 0

		retn
ghost_check_state		endp

			                        ;* No entry point to code
		add	al,[bx+si-56h]
		push	es
		mov	ss:data_70e[bp+si],ch
		stosb				; Store al to es:[di]
		push	es
		db	0D8h,0AAh, 02h, 40h,0AAh, 06h
		db	 20h,0ABh, 04h, 58h,0AAh, 04h
		db	 70h,0ABh, 03h, 58h,0AAh, 05h
		db	0A0h,0ABh, 08h,0DCh,0ABh, 00h
		db	 00h, 00h, 04h, 58h,0AAh, 04h
		db	 3Ch,0ACh, 04h, 58h,0AAh, 04h
		db	 6Ch,0ACh, 00h, 01h, 02h, 03h
		db	 01h, 01h, 01h, 01h, 01h, 04h
		db	 05h, 06h, 07h, 08h, 09h, 0Ah
		db	 0Bh, 0Ch, 0Ch, 0Ch, 0Ch, 0Dh
		db	 0Eh, 0Fh, 00h, 01h, 02h, 03h
		db	 01h, 01h, 01h, 01h, 01h, 04h
		db	 05h, 06h, 07h, 08h, 09h, 0Ah
		db	 0Bh, 0Ch, 0Ch, 0Ch, 0Ch, 0Dh
		db	 0Eh, 0Fh, 10h, 11h, 12h, 13h
		db	 14h, 15h, 16h, 0Ch, 0Ch, 17h
		db	 18h, 19h, 1Ah, 1Bh, 0Ch, 8Fh
		db	 90h, 1Eh, 91h, 92h, 93h, 21h
		db	 22h, 23h, 10h, 11h, 12h, 13h
		db	 14h, 15h, 16h, 0Ch, 0Ch, 17h
		db	 18h, 19h, 1Ah, 1Bh, 0Ch, 1Ch
		db	 1Dh, 1Eh, 1Fh
		db	' ', 0Ch, '!"#$'
		db	'%', 0Ch, '&', 27h, '()*+,-./0123'
		db	'456789:;<=>?@ABCDEFGHIJKLMNOPQRP'
		db	'QPQPQST'
		db	 10h, 11h, 12h, 13h, 55h, 56h
		db	 57h, 0Ch, 0Ch, 17h, 18h, 19h
		db	 1Ah, 1Bh, 0Ch, 1Ch
		db	'XYZ[', 0Ch, '!"#$'
		db	'%', 0Ch, '\]^_`a,-./0bcdefghi9:;'
		db	'<jklmnopqEFGrstuvwxyz{R'
		db	 10h, 11h, 12h, 13h, 55h, 56h
		db	 57h, 0Ch, 0Ch, 17h, 18h, 19h
		db	 1Ah, 1Bh, 0Ch, 1Ch
		db	'XYZ[', 0Ch, '!"#$'
		db	'%', 0Ch, '|]^_}~,-./0j'
		db	 80h, 81h, 82h, 83h, 84h, 85h
		db	 69h, 39h, 3Ah, 3Bh, 3Ch, 0Ch
		db	 7Fh, 86h, 87h, 88h, 89h, 8Ah
		db	'qEFGrsJKLMNyz{R]'
		db	 81h, 5Dh, 81h, 5Dh, 81h, 8Dh
		db	 8Eh, 24h, 25h, 94h, 95h, 96h
		db	 28h, 97h, 98h, 99h, 2Ch, 2Dh
		db	 2Eh, 2Fh, 30h, 9Ah, 9Bh, 9Ch
		db	 9Dh, 9Eh, 9Fh,0A0h,0A1h, 39h
		db	 3Ah, 3Bh, 3Ch,0A2h,0A3h,0A4h
		db	0A5h,0A6h,0A7h,0A8h,0A9h, 45h
		db	 46h, 47h, 72h,0AAh,0ABh, 4Bh
		db	 4Ch, 4Dh, 4Eh,0ACh,0ADh, 7Bh
		db	 52h, 1Ah, 1Bh, 0Ch,0AEh,0AFh
		db	 1Eh, 91h,0B0h,0B1h, 21h, 22h
		db	 23h, 24h,0B2h,0B3h,0B4h,0B5h
		db	0B6h, 97h,0B7h,0B8h,0B9h, 2Dh
		db	 2Eh, 2Fh,0BAh,0BBh,0BCh, 9Ch
		db	 9Dh, 9Eh,0BDh,0BEh,0BFh, 39h
		db	 3Ah, 3Bh, 3Ch, 0Ch, 0Ch,0C0h
		db	0A5h,0A6h,0C1h, 8Ah
		db	'qEFGrsJKLMNyz{R'
		db	 00h, 01h, 02h,0C2h,0C3h,0C4h
		db	0C5h,0C6h, 01h, 04h, 05h, 06h
		db	 07h, 08h,0C7h,0C8h,0C9h,0CAh
		db	0CBh,0CCh,0CDh, 0Dh, 0Eh, 0Fh
		db	 10h, 11h,0CEh,0CFh,0D0h,0D1h
		db	0D2h,0D3h,0D4h
		db	 17h, 18h, 19h, 1Ah, 1Bh, 0Ch
		db	0D5h,0D6h,0D7h,0D8h,0D9h,0DAh
		db	 21h, 22h, 23h, 24h, 25h, 0Ch
		db	0DBh,0B5h,0DCh,0DDh,0DEh
		db	0Ch, ',-./0', 0Ch, 'j'
		db	 9Ch, 9Dh,0DFh,0E0h, 0Ch, 69h
loc_61:
		cmp	[bp+si],di
		cmp	di,[si]
		or	al,0Ch
		db	0C0h,0E1h,0E2h,0C1h, 8Ah, 71h
loc_62:
		inc	bp
		inc	si
		inc	di
		jc	loc_65			; Jump if carry Set
		dec	dx
		dec	bx
		dec	sp
		dec	bp
		dec	si
		jns	loc_66			; Jump if not sign
		jnp	loc_64			; Jump if not parity
		jcxz	loc_61			; Jump if cx=0
		xchg	sp,ax
		xchg	bp,ax
		xchg	si,ax
		sub	ds:data_80e[bx],dl
		sub	al,2Dh			; '-'
		db	 2Eh,0E5h,0E6h,0E7h, 9Bh, 9Ch
		db	 9Dh, 9Eh, 9Fh,0A0h,0A1h, 39h
		db	 3Ah,0E8h,0E9h,0EAh,0EBh,0A4h
		db	0A5h,0A6h,0A7h,0ECh,0EDh, 45h
		db	 46h,0EEh,0EFh,0F0h,0F1h,0F2h
		db	0F3h,0F4h,0F5h,0F6h,0F7h,0F8h
		db	0F9h, 24h, 25h, 94h, 95h, 96h
		db	 28h, 97h, 98h
loc_63:
		cwd				; Word to double word
		sub	al,2Dh			; '-'
		db	 2Eh, 2Fh, 30h,0E7h, 9Bh, 9Ch
		db	 9Dh, 9Eh, 9Fh,0A0h,0A1h, 39h
		db	 3Ah,0FAh,0FBh,0EAh,0EBh,0A4h
		db	0A5h,0A6h,0A7h,0ECh,0EDh
loc_64:
		inc	bp
		inc	si
		cld				; Clear direction
		std				; Set direction flag
                           lock	dec	byte ptr [bp+di+4Ch]
		dec	bp
		dec	si
		idiv	bh			; al, ah rem = ax/reg
		jnp	$+54h			; Jump if not parity
		add	byte ptr [bx+si+20h],10h
		or	[si],al
		add	[di],dx
		inc	cx
		push	dx
loc_65:
		dec	bp
		dec	di
		push	dx
		db	 2Eh, 47h, 52h, 50h, 00h, 10h
		db	0AFh, 00h, 16h
		db	 57h, 65h
loc_66:
		db	'apon and Armour ShopGo outside', 0
		db	'Repair shield', 0
		db	'Buy weapon', 0
		db	'Bu'
		db	'y shield'
		db	0
		db	'Explain goods'
		db	 00h, 1Dh,0ADh, 2Ch,0ADh, 3Dh
		db	0ADh, 4Ah,0ADh, 59h,0ADh, 6Ch
		db	0ADh, 7Eh,0ADh, 8Ah,0ADh, 9Ch
		db	0ADh,0A9h,0ADh,0B6h,0ADh,0C3h
		db	0ADh
		db	'Training sword', 0
		db	'Wise man\s sword', 0
		db	'Spirit sword', 0
		db	'Knight\s sword', 0
		db	'Illumination sword', 0
		db	'Enchantment sword', 0
		db	'Clay shield', 0
		db	'Wise man\s shield', 0
		db	'Stone shield', 0
		db	'Honor shield', 0
		db	'Light shield', 0
		db	'Titanium Shield', 0
		db	'May I&be of service, sir?/'
		db	0FFh, 00h
		db	0Ch, 'Is there something I&can do'
		db	' for you, sir?/'
		db	0FFh, 00h
		db	0Ch, 'Will there be something els'
		db	'e for you, sir?/'
		db	0FFh, 00h
		db	0Ch, 'Sir, you aren\t carrying a '
		db	'shield -- however, I do have a f'
		db	'ine selection, if you\d like to '
		db	'buy one./'
		db	0FFh, 00h
		db	0Ch, 'Sir, your shield is not in '
		db	'need of repair. How else can I h'
		db	'elp you?/'
		db	0FFh, 00h
		db	0Ch, 'I\ll be glad to repair your'
		db	' shield, sir, for the low price '
		db	'of '
		db	0FFh, 00h
		db	'&golds. Shall I&proceed?'
		db	0FFh, 00h
		db	0Dh, 'I\m sorry sir, you aren\t c'
		db	'arrying enough gold. Perhaps aft'
		db	'er you\ve visited the bank.../'
		db	0FFh, 00h
		db	0Dh, 'Please wait h'
		db	'ere, I\ll only be a moment.'
		db	0FFh, 04h,0FFh, 04h,0FFh, 05h
		db	0FFh, 00h
		db	0Ch, 'The repairs'
		db	' to your armour are comple'
		db	'te. It is now as good as new./'
		db	0FFh, 00h
		db	0Ch, 'Something else for you, sir'
		db	'?/'
		db	0FFh, 01h
		db	'I\ll give you '
		db	0FFh, 00h
		db	'&gol'
		db	'ds on your old w'
		db	'eapon as a trade-in.', 0Dh
		db	0FFh, 00h
		db	0Ch, 'Something else for you, sir'
		db	'?/'
		db	0FFh, 02h
		db	'I\ll give you '
		db	0FFh, 00h
		db	'&go'
		db	'l'
		db	'ds on your old s'
		db	'hield as a trade-in.', 0Dh
		db	0FFh, 00h
		db	0Ch, 'Oh, the '
		db	0FFh, 00h, 3Fh, 2Fh,0FFh, 0Ch
		db	0FFh, 00h
		db	'Will that be all right?'
		db	0FFh, 00h
		db	'That will be '
		db	0FFh, 00h
		db	'&golds./'
		db	0FFh, 00h
		db	0Ch, 'All of my goods are of the '
		db	'highest quality. Which item woul'
		db	'd you like me to tell you a'
		db	 62h, 6Fh, 75h, 74h, 3Fh, 2Fh
		db	0FFh, 06h
		db	 0Ch, 57h
		db	'hich item would you like to know'
		db	' about?/'
		db	0FFh, 49h, 73h
		db	' there another item you would li'
		db	'ke to know about?/'
		db	0FFh
		db	0Ch, 'Thank you, please come agai'
		db	'n.'
		db	 11h,0FFh,0FFh, 0Ch
		db	'If you\re going to wa'
		db	'ste my time, please be on your w'
		db	'ay./'
		db	0FFh, 07h,0FFh, 03h, 11h,0FFh
		db	0FFh
		db	0Ch, 'Uh....../'
		db	0FFh, 00h
		db	0Ch, 'I do not sell that weapon. '
		db	'I haven\t a single one in stock.'
		db	' Please choose another./'
		db	0FFh, 00h
		db	0Ch, 'Well I\ll be... '
		db	0FFh, 04h,0FFh, 04h, 53h, 69h
		db	 72h, 21h, 20h,0FFh, 09h,0FFh
		db	 04h
		db	49h
		db	'sn\t that the crest of honor you'
		db	' bear? Please come in... I mean.'
		db	'..uh... /Might I trade you a kni'
		db	'ght\s sword for it?'
		db	0FFh, 08h
		db	0Ch, 'Oh, I&see. Well, if you cha'
		db	'nge your mind, please come back.'
		db	 11h,0FFh,0FFh, 0Ch
		db	'Oh, thank you, sir! As promised,'
		db	' here is your knight\s sword./'
		db	0FFh, 00h
		db	'Thank you, and please come back '
		db	'soon.'
		db	 11h,0FFh,0FFh,0F6h,0B3h, 9Fh
		db	0B4h, 66h,0B5h,0C9h,0B5h, 4Ch
		db	0B6h,0DBh,0B6h, 0Ch,0B7h,0BBh
		db	0B7h, 3Fh,0B8h,0CAh,0B8h, 58h
		db	0B9h, 0Fh,0BAh
		db	'Well, I\d say this sword is all '
		db	'right for a beginner./You get wh'
		db	'at you pay for./It\s your standa'
		db	'rd, maintenance-free sword. If m'
		db	'oney\s a problem, this one\s for'
		db	' you.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is one is just a bit better than'
		db	' the Training Sword. Once you ge'
		db	't the hang of it, it\s an easy o'
		db	'ne to wield. The price is a bit '
		db	'higher, but you can\t lose on th'
		db	'is one./Why not take it with you'
		db	'?'
		db	 11h, 0Ch,0FFh,0FFh, 59h, 6Fh
		db	'u like this one?/A wise choice./'
		db	'This is a high grade product. It'
		db	'\s one of my biggest sellers.'
		db	 11h, 0Ch,0FFh,0FFh, 4Fh, 68h
		db	', I\d be more than happy to tell'
		db	' you about this one./This is a r'
		db	'eal man\s sword. It\ll topple mo'
		db	'nsters in the wink of an eye.'
		db	 11h, 0Ch,0FFh,0FFh, 59h, 6Fh
		db	'u\ve got a lot of grit I\d say. '
		db	'This one really packs a punch. A'
		db	' top-of-the-line sword for a top'
		db	'-of-the-line-swordsman. Will you'
		db	' take it?'
		db	 11h, 0Ch,0FFh,0FFh, 49h, 73h
		db	'n\t that the sword you brought i'
		db	'n with you?'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is shield is small and has limit'
		db	'ed defense capability. It\s not '
		db	'very durable -- unless it\s used'
		db	' with great skill, it won\t last'
		db	' long. It\s better than nothing,'
		db	' I guess.'
		db	 11h, 0Ch,0FFh,0FFh, 57h, 65h
		db	'll, it\s slightly better than th'
		db	'e Clay Shield. Long ago, a well-'
		db	'known hero used it for a short t'
		db	'ime. You could do a lot worse.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is one is more of a general-use '
		db	'shield. It\s not the best one I '
		db	'carry. I can\t really recommend '
		db	'it, I think it will soon be obso'
		db	'lete.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is shield is in a class by itsel'
		db	'f. It is strong and light and ea'
		db	'sy to use. This is a superior sh'
		db	'ield, the least a brave man shou'
		db	'ld have.'
		db	 11h, 0Ch,0FFh,0FFh, 48h, 6Fh
		db	'! You\ve got quite an eye for th'
		db	'ese things, I see. This shield i'
		db	's not made of common iron. It is'
		db	' made of a magic metal called Ma'
		db	'gane. Against ordinary weapons, '
		db	'it\s unbreakable.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is shield makes the mightiest sw'
		db	'ords seem like paper. It\s light'
		db	' as a feather and hard as a diam'
		db	'ond. Used well, this one will la'
		db	'st you a lifetime.'
		db	 11h, 0Ch,0FFh,0FFh,0B9h,0BAh
		db	0DDh,0BAh, 01h,0BBh, 25h,0BBh
		db	 49h,0BBh, 6Dh,0BBh, 91h,0BBh
		db	0B5h,0BBh,0D9h,0BBh, 00h, 90h
		db	 01h, 00h,0DCh, 05h, 00h, 90h
		db	 1Ah, 00h, 48h, 26h, 01h, 90h
		db	 5Fh, 00h, 04h, 00h, 00h, 32h
		db	 00h, 00h, 96h, 00h, 00h,0A4h
		db	 0Bh, 00h, 48h, 26h, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h, 20h
		db	 03h, 00h,0DCh, 05h, 00h, 90h
		db	 1Ah, 00h, 48h, 26h, 01h,0A8h
		db	 10h, 00h, 04h, 00h, 00h, 32h
		db	 00h, 00h, 96h, 00h, 00h,0A4h
		db	 0Bh, 00h, 48h, 26h, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h, 20h
		db	 03h, 00h,0DCh, 05h, 00h, 90h
		db	 1Ah, 00h, 48h, 26h, 01h,0A8h
		db	 10h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 96h, 00h, 00h, 4Ch
		db	 09h, 00h, 48h, 26h, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h, 90h
		db	 01h, 00h,0B8h, 0Bh, 00h, 40h
		db	 15h, 00h, 48h, 26h, 01h,0A8h
		db	 10h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 32h, 00h, 00h,0F4h
		db	 06h, 00h, 48h, 26h, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h, 90h
		db	 01h, 00h,0B8h, 0Bh, 00h, 98h
		db	 12h, 00h, 24h, 13h, 01h,0A8h
		db	 10h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 32h, 00h, 00h,0F4h
		db	 06h, 00h,0A0h, 1Eh, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h,0C8h
		db	 00h, 00h,0DCh, 05h, 00h, 48h
		db	 0Dh, 00h,0A0h, 1Eh, 01h,0A8h
		db	 10h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 14h, 00h, 00h, 7Ah
		db	 03h, 00h,0F8h, 16h, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h,0C8h
		db	 00h, 00h,0DCh, 05h, 00h, 50h
		db	 05h, 00h,0F8h, 16h, 00h,0F0h
		db	 87h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 14h, 00h, 00h, 7Ah
		db	 03h, 00h,0F8h, 16h, 00h, 78h
		db	 28h, 00h, 78h, 9Bh, 00h, 64h
		db	 00h, 00h,0E8h, 03h, 00h, 50h
		db	 05h, 00h, 50h, 0Fh, 00h, 20h
		db	 80h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 14h, 00h, 00h, 7Ah
		db	 03h, 00h, 50h, 0Fh, 00h,0E8h
		db	 1Ch, 00h, 38h, 7Ch, 00h, 0Ah
		db	 00h, 00h, 64h, 00h, 00h,0A8h
		db	 02h, 00h,0A8h, 07h, 00h, 68h
		db	 74h, 00h, 04h, 00h, 00h, 02h
		db	 00h, 00h, 0Ah, 00h, 00h, 2Ah
		db	 01h, 00h,0A8h, 07h, 00h, 20h
		db	 17h, 00h,0F8h
		db	5Ch
		db	74 dup (0)

seg_a		ends



		end	start
