
PAGE  59,132

;==========================================================================
;
;  ANIMATION_SYSTEM - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	4000h			;*
data_2e		equ	6000h			;*
data_3e		equ	80A0h			;*
data_4e		equ	8CF0h			;*
data_5e		equ	0B000h			;*
data_6e		equ	0B17Eh			;*
data_7e		equ	0D000h			;*
data_49e	equ	3172h			;*
data_50e	equ	3915h			;*
data_51e	equ	39E8h			;*
data_52e	equ	4264h			;*
data_53e	equ	4771h			;*
data_54e	equ	489Dh			;*
data_55e	equ	4BFBh			;*
data_56e	equ	51D2h			;*
data_57e	equ	522Fh			;*
data_59e	equ	5231h			;*
data_60e	equ	5233h			;*
data_61e	equ	5235h			;*
data_62e	equ	5237h			;*
data_63e	equ	5238h			;*
data_64e	equ	5239h			;*
data_65e	equ	523Ah			;*
data_66e	equ	523Bh			;*
data_68e	equ	523Dh			;*
data_69e	equ	523Fh			;*
data_70e	equ	5241h			;*
data_72e	equ	5243h			;*
data_73e	equ	5244h			;*
data_74e	equ	5245h			;*
data_75e	equ	5255h			;*
data_76e	equ	5256h			;*
data_77e	equ	5259h			;*
data_78e	equ	5262h			;*
data_79e	equ	5362h			;*
data_80e	equ	5562h			;*
data_81e	equ	5682h			;*
data_82e	equ	625Ch			;*
data_83e	equ	723Bh			;*
data_84e	equ	80A0h			;*
data_85e	equ	0A030h			;*
data_86e	equ	0C010h			;*
data_87e	equ	0C012h			;*
data_88e	equ	0E000h			;*
data_89e	equ	0E900h			;*
data_90e	equ	0E91Bh			;*
data_91e	equ	0ED20h			;*
data_92e	equ	0EDA0h			;*
data_93e	equ	0FF1Ah			;*
data_94e	equ	0FF2Ch			;*
data_95e	equ	0FF2Fh			;*
data_96e	equ	0FF31h			;*
data_97e	equ	0FF33h			;*
data_98e	equ	0FF34h			;*
data_99e	equ	0FF36h			;*
data_100e	equ	0FF37h			;*
data_101e	equ	0FF38h			;*
data_102e	equ	0FF39h			;*
data_103e	equ	0FF3Ah			;*
data_104e	equ	0FF3Dh			;*
data_105e	equ	0FF3Fh			;*
data_106e	equ	0FF40h			;*
data_107e	equ	0FF41h			;*
data_108e	equ	0FF42h			;*
data_109e	equ	0FF43h			;*
data_110e	equ	0FF44h			;*
data_111e	equ	0FF45h			;*
data_112e	equ	0FF46h			;*
data_113e	equ	0A0h
data_114e	equ	41F8h
data_115e	equ	80A0h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_05		proc	far

start:
		mov	byte ptr ds:[26h],al
		add	[si],ch
		xor	ds:data_83e,al
		inc	ax
;*		jg	loc_1			;*Jump if >
		db	 7Fh, 3Fh		;  Fixup - byte match
		mov	cx,9E42h
		inc	si
		sub	[bx+di+6Eh],ax
		xor	bl,[di]
		cmp	[bx+di],cx
		inc	bx
;*		jp	loc_3			;*Jump if parity=1
		db	 7Ah, 42h		;  Fixup - byte match
                           lock	cmp	al,[bx+di+44h]
		mov	bx,546h
		inc	di
		std				; Set direction flag
		inc	di
		jo	loc_6			; Jump if overflow=1
		dec	bp
		dec	bx
		nop
		dec	bx
		daa				; Decimal adjust
		dec	bp
		call	$+2E53h
		push	dx
		push	cs
		pop	es
		mov	di,data_78e
		xor	ax,ax			; Zero register
		mov	cx,80h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		inc	byte ptr ds:data_72e
		mov	word ptr ds:data_59e,41F8h
		mov	si,ds:data_96e
		sub	si,21h
		call	anim_func_42
		xor	bx,bx			; Zero register
		test	byte ptr [si],80h
		jz	loc_2			; Jump if zero
		call	anim_func_3
loc_2:
		inc	si
		mov	cx,6

locloop_4:
		push	cx
		test	byte ptr [si],80h
		jz	loc_5			; Jump if zero
		call	anim_func_4
loc_5:
		inc	si
loc_6:
		inc	bx
		test	byte ptr [si],80h
		jz	loc_7			; Jump if zero
		call	anim_func_4
loc_7:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_8			; Jump if zero
		call	anim_func_4
loc_8:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_9			; Jump if zero
		call	anim_func_4
loc_9:
		inc	si
		inc	bx
		pop	cx
		loop	locloop_4		; Loop if cx > 0

		test	byte ptr [si],80h
		jz	loc_10			; Jump if zero
		call	anim_func_4
loc_10:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_11			; Jump if zero
		call	anim_func_4
loc_11:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_12			; Jump if zero
		call	anim_func_4
loc_12:
		inc	si
		test	byte ptr [si],80h
		jz	loc_13			; Jump if zero
		call	anim_func_5
loc_13:
		mov	si,ds:data_96e
		mov	di,data_89e
		mov	byte ptr ds:data_62e,12h
loc_14:
		call	anim_func_22
		xor	bx,bx			; Zero register
		add	si,3
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jns	loc_15			; Jump if not sign
		call	anim_func_6
loc_15:
		mov	cx,6

locloop_16:
		push	cx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_17			; Jump if zero
		call	anim_func_1
loc_17:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_18			; Jump if zero
		call	anim_func_1
loc_18:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_19			; Jump if zero
		call	anim_func_1
loc_19:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_20			; Jump if zero
		call	anim_func_1
loc_20:
		inc	bx
		pop	cx
		loop	locloop_16		; Loop if cx > 0

		cmpsb				; Cmp [si] to es:[di]
		jz	loc_21			; Jump if zero
		call	anim_func_1
loc_21:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_22			; Jump if zero
		call	anim_func_1
loc_22:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_23			; Jump if zero
		call	anim_func_1
loc_23:
		inc	bx
		lodsb				; String [si] to al
		inc	di
		or	al,al			; Zero ?
		jns	loc_24			; Jump if not sign
		jmp	loc_84
loc_24:
		cmp	al,es:[di-1]
		je	loc_25			; Jump if equal
		call	anim_func_1
loc_25:
		add	si,4
		call	anim_func_41
		add	word ptr ds:data_59e,140h
		dec	byte ptr ds:data_62e
		jnz	loc_14			; Jump if not zero
		retn

zr2_05		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_1		proc	near
		mov	al,[si-1]
		or	al,al			; Zero ?
		jns	loc_26			; Jump if not sign
		jmp	loc_82
loc_26:
		cmp	byte ptr es:[di-1],0FCh
		jne	loc_27			; Jump if not equal
		mov	byte ptr es:[di-1],0FFh
		jmp	short loc_28
loc_27:
		inc	byte ptr es:[di-1]
		mov	byte ptr es:[di-1],0FEh
		jz	loc_28			; Jump if zero
		mov	es:[di-1],al
		mov	dx,bx
		add	dx,dx
		add	dx,dx
		add	dx,ds:data_59e
		call	anim_multiply
loc_28:
		mov	al,ds:data_87e
		sub	al,5
		jnc	loc_29			; Jump if carry=0
		retn
loc_29:
		cmp	al,4
		jb	loc_30			; Jump if below
		retn
loc_30:
		push	bx
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:data_49e[bx]	;*
		pop	bx
		retn
anim_func_1		endp

			                        ;* No entry point to code
;*		jp	loc_34			;*Jump if parity=1
		db	 7Ah, 31h		;  Fixup - byte match
;*		call	far ptr anim_func_50		;*
		db	9Ah
		dw	0D031h, 4E31h		;  Fixup - byte match
		xor	cl,ss:data_110e[bp+si]
		sub	al,1Bh
		cmp	al,2
		jb	loc_31			; Jump if below
		retn
loc_31:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_72e,1
		jnz	loc_32			; Jump if not zero
		retn
loc_32:
		inc	al
		and	al,1
		add	al,1Bh
		mov	[si-1],al
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,1Dh
		cmp	al,6
		jb	loc_33			; Jump if below
		retn
loc_33:
		mov	byte ptr [di-1],0FEh
		cmp	al,4
		jae	loc_36			; Jump if above or =
		or	al,al			; Zero ?
		jnz	loc_35			; Jump if not zero
		push	ax
		call	word ptr cs:[11Ah]
		and	al,3
		pop	ax
		jz	loc_35			; Jump if zero
		retn
loc_35:
		inc	al
		and	al,3
		add	al,1Dh
		mov	[si-1],al
		retn
loc_36:
		inc	al
		and	al,1
		add	al,21h			; '!'
		mov	[si-1],al
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,2Ch			; ','
		cmp	al,2
		jae	loc_38			; Jump if above or =
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_72e,1
		jnz	loc_37			; Jump if not zero
		retn
loc_37:
		inc	al
		and	al,1
		add	al,2Ch			; ','
		mov	[si-1],al
		retn
loc_38:
		mov	al,[si-1]
		cmp	al,3Eh			; '>'
		jb	loc_39			; Jump if below
		retn
loc_39:
		mov	bl,33h			; '3'
		cmp	al,0Eh
		je	loc_41			; Jump if equal
		mov	bl,36h			; '6'
		cmp	al,0Dh
		je	loc_41			; Jump if equal
		mov	bl,39h			; '9'
		cmp	al,0Fh
		je	loc_41			; Jump if equal
		mov	bl,3Ch			; '<'
		cmp	al,0Ch
		je	loc_41			; Jump if equal
		mov	bl,3Dh			; '='
		cmp	al,10h
		je	loc_41			; Jump if equal
		sub	al,33h			; '3'
		jnc	loc_40			; Jump if carry=0
		retn
loc_40:
		mov	bl,0Eh
		cmp	al,2
		je	loc_41			; Jump if equal
		mov	bl,0Dh
		cmp	al,5
		je	loc_41			; Jump if equal
		mov	bl,0Fh
		cmp	al,8
		je	loc_41			; Jump if equal
		mov	bl,0Ch
		cmp	al,9
		je	loc_41			; Jump if equal
		mov	bl,10h
		cmp	al,0Ah
		je	loc_41			; Jump if equal
		inc	al
		add	al,33h			; '3'
		mov	bl,al
loc_41:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_72e,1
		jnz	loc_42			; Jump if not zero
		retn
loc_42:
		mov	[si-1],bl
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,25h			; '%'
		cmp	al,4
		jb	loc_43			; Jump if below
		retn
loc_43:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_72e,1
		jnz	loc_44			; Jump if not zero
		retn
loc_44:
		inc	al
		and	al,3
		add	al,25h			; '%'
		mov	[si-1],al
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_multiply		proc	near
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,dx
		or	al,al			; Zero ?
		jnz	loc_45			; Jump if not zero
		jmp	loc_64
loc_45:
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:data_78e[bx],0FFFFh
		jnz	loc_49			; Jump if not zero
		dec	al
		mov	ds:data_78e[bx],di
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_94e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,4

locloop_46:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_47			; Jump if below
		add	di,data_115e
loc_47:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_48			; Jump if below
		add	di,data_115e
loc_48:
		loop	locloop_46		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_49:
		mov	si,ds:data_78e[bx]
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_50			; Jump if below
		add	di,data_115e
loc_50:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_51			; Jump if below
		add	si,data_115e
loc_51:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_52			; Jump if below
		add	di,data_115e
loc_52:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_53			; Jump if below
		add	si,data_115e
loc_53:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_54			; Jump if below
		add	di,data_115e
loc_54:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_55			; Jump if below
		add	si,data_115e
loc_55:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_56			; Jump if below
		add	di,data_115e
loc_56:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_57			; Jump if below
		add	si,data_115e
loc_57:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_58			; Jump if below
		add	di,data_115e
loc_58:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_59			; Jump if below
		add	si,data_115e
loc_59:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_60			; Jump if below
		add	di,data_115e
loc_60:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_61			; Jump if below
		add	si,data_115e
loc_61:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_62			; Jump if below
		add	di,data_115e
loc_62:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_63			; Jump if below
		add	si,data_115e
loc_63:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_64:
		mov	ax,0B800h
		mov	es,ax
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_65			; Jump if below
		add	di,data_115e
loc_65:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_66			; Jump if below
		add	di,data_115e
loc_66:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_67			; Jump if below
		add	di,data_115e
loc_67:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_68			; Jump if below
		add	di,data_115e
loc_68:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_69			; Jump if below
		add	di,data_115e
loc_69:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_70			; Jump if below
		add	di,data_115e
loc_70:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_71			; Jump if below
		add	di,data_115e
loc_71:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
anim_multiply		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_3		proc	near
		cmp	byte ptr ds:data_89e,0FFh
		jne	loc_72			; Jump if not equal
		retn
loc_72:
		cmp	byte ptr ds:data_89e,0FCh
		jne	loc_73			; Jump if not equal
		retn
loc_73:
		push	si
		push	bx
		mov	byte ptr ds:data_89e,0FFh
		mov	cl,[si]
		add	si,25h
		call	anim_func_41
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_74			; Jump if not sign
		call	anim_get_value
loc_74:
		push	ax
		mov	al,cl
		call	anim_multiply_3
		add	si,3
		pop	ax
		mov	ah,[si]
		mov	dx,41F8h
		call	anim_func_9
		pop	bx
		pop	si
		retn
anim_func_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_4		proc	near
		push	si
		push	bx
		mov	cx,bx
		mov	di,bx
		add	di,data_89e
		mov	bx,data_75e
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	byte ptr [bx+1],0
		mov	byte ptr [di+1],0FFh
		mov	dx,cx
		add	dx,dx
		add	dx,dx
		add	dx,41F8h
		mov	cl,[si]
		add	si,24h
		call	anim_func_41
		mov	bx,data_77e
		lodsw				; String [si] to ax
		mov	[bx],ax
		mov	al,cl
		call	anim_multiply_3
		inc	si
		inc	si
		mov	di,data_77e
		mov	bp,data_75e
		call	anim_func_7
		pop	bx
		pop	si
		retn
anim_func_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_5		proc	near
		cmp	byte ptr ds:data_90e,0FFh
		jne	loc_75			; Jump if not equal
		retn
loc_75:
		cmp	byte ptr ds:data_90e,0FCh
		jne	loc_76			; Jump if not equal
		retn
loc_76:
		mov	byte ptr ds:data_90e,0FFh
		mov	cl,[si]
		add	si,24h
		call	anim_func_41
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_77			; Jump if not sign
		call	anim_get_value
loc_77:
		push	ax
		mov	al,cl
		call	anim_multiply_3
		add	si,2
		pop	ax
		mov	ah,[si]
		mov	dx,4264h
		jmp	loc_91

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_6:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_75e
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	al,0FFh
		xchg	[di+1Ch],al
		mov	[bx+1],al
		mov	cl,[si-1]
		mov	dl,[si]
		add	si,24h
		call	anim_func_41
		mov	dh,[si]
		mov	al,cl
		call	anim_multiply_3
		inc	si
		mov	bx,dx
		pop	dx
		add	dx,dx
		add	dx,dx
		add	dx,ds:data_59e
		cmp	byte ptr ds:data_75e,0FFh
		je	loc_79			; Jump if equal
		cmp	byte ptr ds:data_75e,0FCh
		je	loc_79			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_78			; Jump if not sign
		call	anim_get_value
loc_78:
		call	anim_func_9
		pop	dx
		pop	si
		pop	bx
loc_79:
		add	dx,140h
		cmp	byte ptr ds:data_62e,1
		je	loc_81			; Jump if equal
		cmp	byte ptr ds:data_76e,0FFh
		je	loc_81			; Jump if equal
		cmp	byte ptr ds:data_76e,0FCh
		je	loc_81			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_80			; Jump if not sign
		call	anim_get_value
loc_80:
		call	anim_func_9
loc_81:
		pop	bx
		pop	di
		pop	si
		retn
loc_82:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_75e
		mov	ax,0FFFEh
		xchg	[di-1],ax
		mov	[bx],ax
		mov	ax,0FFFFh
		xchg	[di+1Bh],ax
		mov	[bx+2],ax
		mov	cl,[si-1]
		mov	bx,data_77e
		mov	al,[si]
		mov	[bx+1],al
		add	si,24h
		call	anim_func_41
		mov	ax,[si-1]
		mov	[bx+2],ax
		pop	dx
		mov	ds:data_63e,dl
		mov	al,ds:data_62e
		neg	al
		add	al,12h
		mov	ds:data_64e,al
		add	dx,dx
		add	dx,dx
		add	dx,ds:data_59e
		mov	al,cl
		call	anim_multiply_3
		mov	di,data_77e
		mov	[di],al
		mov	bp,data_75e
		call	anim_func_7
		cmp	byte ptr ds:data_62e,1
		je	loc_83			; Jump if equal
		add	dx,138h
		call	anim_func_7
		test	byte ptr ds:data_98e,0FFh
		jz	loc_83			; Jump if zero
		test	byte ptr ds:data_95e,0FFh
		jz	loc_83			; Jump if zero
		call	anim_check_state_2
loc_83:
		pop	bx
		pop	di
		pop	si
		retn
loc_84:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_75e
		mov	al,0FEh
		xchg	[di-1],al
		mov	[bx],al
		mov	al,0FFh
		xchg	[di+1Bh],al
		mov	[bx+1],al
		mov	cl,[si-1]
		add	si,24h
		call	anim_func_41
		mov	dl,[si-1]
		mov	al,cl
		call	anim_multiply_3
		mov	bl,al
		mov	bh,dl
		pop	dx
		add	dx,dx
		add	dx,dx
		add	dx,ds:data_59e
		cmp	byte ptr ds:data_75e,0FFh
		je	loc_86			; Jump if equal
		cmp	byte ptr ds:data_75e,0FCh
		je	loc_86			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_85			; Jump if not sign
		call	anim_get_value
loc_85:
		call	anim_func_9
		pop	dx
		pop	si
		pop	bx
loc_86:
		add	dx,140h
		cmp	byte ptr ds:data_62e,1
		je	loc_88			; Jump if equal
		cmp	byte ptr ds:data_76e,0FFh
		je	loc_88			; Jump if equal
		cmp	byte ptr ds:data_76e,0FCh
		je	loc_88			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_87			; Jump if not sign
		call	anim_get_value
loc_87:
		call	anim_func_9
loc_88:
		pop	bx
		pop	di
		pop	si
		jmp	loc_25

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_7:
		call	anim_func_8

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_8:
		cmp	byte ptr ds:[bp],0FFh
		je	loc_90			; Jump if equal
		cmp	byte ptr ds:[bp],0FCh
		je	loc_90			; Jump if equal
		mov	ah,[si]
		mov	al,[di]
		or	al,al			; Zero ?
		jns	loc_89			; Jump if not sign
		call	anim_get_value
loc_89:
		push	bp
		push	si
		push	di
		push	dx
		call	anim_func_9
		pop	dx
		pop	di
		pop	si
		pop	bp
loc_90:
		inc	si
		inc	di
		inc	bp
		add	dx,4
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_9:
loc_91:
		push	es
		push	ds
		mov	bl,ds:data_65e
		or	al,al			; Zero ?
		jz	loc_92			; Jump if zero
		js	loc_92			; Jump if sign=1
		or	bl,80h
loc_92:
		mov	cl,al
		mov	al,ah
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bp,ax
		add	bp,0A000h
		mov	ds,cs:data_94e
		mov	di,dx
		push	cs
		pop	es
		mov	ch,bl
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:data_56e[bx]
		mov	cs:data_57e,ax
		mov	al,cl
		or	ch,ch			; Zero ?
		js	loc_93			; Jump if sign=1
		push	di
		mov	di,5682h
		call	anim_process_loop
		pop	di
		mov	si,data_81e
		push	cs
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		call	anim_check_state
		pop	ds
		pop	es
		retn
loc_93:
		push	di
		mov	di,data_81e
		call	anim_multiply_2
		pop	di
		mov	si,data_81e
		push	cs
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		call	anim_check_state
		pop	ds
		pop	es
		retn
anim_func_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_multiply_2		proc	near
		push	bp
		push	si
		push	di
		dec	cl
		mov	al,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	copy_buffer
		pop	di
		pop	si
		pop	bp
		jmp	short $+2		; delay for I/O

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_11:
		mov	cx,8

locloop_94:
		push	cx
		mov	dl,ds:[bp]
		call	anim_process_loop_5
		and	es:[di],ax
		push	dx
		lodsw				; String [si] to ax
		call	extract_bits
		or	es:[di],ax
		pop	dx
		call	anim_process_loop_5
		and	es:[di+2],ax
		lodsw				; String [si] to ax
		call	extract_bits
		or	es:[di+2],ax
		inc	bp
		add	di,4
		pop	cx
		loop	locloop_94		; Loop if cx > 0

		retn
anim_multiply_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_process_loop		proc	near
		mov	cx,8

locloop_95:
		lodsw				; String [si] to ax
		call	extract_bits
		stosw				; Store ax to es:[di]
		lodsw				; String [si] to ax
		call	extract_bits
		stosw				; Store ax to es:[di]
		loop	locloop_95		; Loop if cx > 0

		retn
anim_process_loop		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

extract_bits		proc	near
		mov	bx,ax
		shr	bh,1			; Shift w/zeros fill
		shr	bh,1			; Shift w/zeros fill
		shr	bh,1			; Shift w/zeros fill
		shr	bh,1			; Shift w/zeros fill
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,cs:data_57e
		mov	dh,cs:[bx]
		add	dh,dh
		add	dh,dh
		add	dh,dh
		add	dh,dh
		mov	bx,ax
		and	bh,0Fh
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,cs:data_57e
		or	dh,cs:[bx]
		mov	bx,ax
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		add	bx,cs:data_57e
		mov	dl,cs:[bx]
		add	dl,dl
		add	dl,dl
		add	dl,dl
		add	dl,dl
		mov	bx,ax
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	bx,cs:data_57e
		or	dl,cs:[bx]
		mov	ax,dx
		retn
extract_bits		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_check_state		proc	near
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_96			; Jump if below
		add	di,data_115e
loc_96:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_97			; Jump if below
		add	di,data_115e
loc_97:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_98			; Jump if below
		add	di,data_115e
loc_98:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_99			; Jump if below
		add	di,data_115e
loc_99:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_100			; Jump if below
		add	di,data_115e
loc_100:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_101			; Jump if below
		add	di,data_115e
loc_101:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_102			; Jump if below
		add	di,data_115e
loc_102:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		retn
anim_check_state		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

copy_buffer		proc	near
		mov	cx,10h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		retn
copy_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

fill_buffer		proc	near
		xor	ax,ax			; Zero register
		mov	cx,10h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
fill_buffer		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_get_value		proc	near
		and	al,7Fh
		mov	bx,data_91e
		xlat				; al=[al+[bx]] table
		retn
anim_get_value		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_multiply_3		proc	near
		and	al,7Fh
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	cl,ds:data_91e[bx]
		mov	ch,10h
		mul	ch			; ax = reg * al
		add	ax,ds:data_86e
		mov	bp,ax
		mov	al,ds:[bp+6]
		and	al,0Fh
		mov	ch,5
		mul	ch			; ax = reg * al
		mov	si,0A070h
		test	byte ptr ds:[bp+5],80h
		jnz	loc_103			; Jump if not zero
		mov	si,data_85e
loc_103:
		mov	bl,ds:[bp+4]
		and	bl,1Fh
		add	bl,bl
		xor	bh,bh			; Zero register
		add	ax,[bx+si]
		mov	si,ax
		lodsb				; String [si] to al
		test	byte ptr ds:data_98e,0FFh
		jnz	loc_104			; Jump if not zero
		test	byte ptr ds:[bp+5],20h	; ' '
		jz	loc_104			; Jump if zero
		add	al,3
loc_104:
		mov	ds:data_65e,al
		mov	al,cl
		retn
anim_multiply_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_check_state_2		proc	near
		cmp	byte ptr ds:data_64e,10h
		jb	loc_105			; Jump if below
		retn
loc_105:
		push	cs
		pop	es
		call	word ptr cs:[11Ah]
		and	al,0Fh
		cmp	al,0Eh
		jae	loc_106			; Jump if above or =
		retn
loc_106:
		mov	di,data_92e
		xor	cl,cl			; Zero register
loc_107:
		cmp	byte ptr [di],0FFh
		je	loc_108			; Jump if equal
		add	di,4
		inc	cl
		jmp	short loc_107
loc_108:
		cmp	cl,20h			; ' '
		jb	loc_109			; Jump if below
		retn
loc_109:
		call	word ptr cs:[11Ah]
		and	al,3
		cmp	al,3
		je	loc_109			; Jump if equal
		dec	al
		add	al,ds:data_63e
		cmp	al,0FFh
		jne	loc_110			; Jump if not equal
		mov	al,4
loc_110:
		cmp	al,1Bh
		jb	loc_111			; Jump if below
		mov	al,1Ah
loc_111:
		stosb				; Store al to es:[di]
loc_112:
		call	word ptr cs:[11Ah]
		and	al,3
		cmp	al,3
		je	loc_112			; Jump if equal
		dec	al
		add	al,ds:data_64e
		cmp	al,0FFh
		jne	loc_113			; Jump if not equal
		xor	al,al			; Zero register
loc_113:
		stosb				; Store al to es:[di]
		mov	al,3
		stosb				; Store al to es:[di]
		call	word ptr cs:[11Ah]
		and	al,7
		mov	bx,data_50e
		xlat				; al=[al+[bx]] table
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn
anim_check_state_2		endp

			                        ;* No entry point to code
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		inc	sp
		push	bp
		db	 66h,0CCh,0DDh,0EEh,0CCh, 0Eh
		db	 07h,0BFh,0A0h,0EDh, 8Bh,0F7h
loc_114:
		cmp	byte ptr [si],0FFh
		jne	loc_115			; Jump if not equal
		mov	byte ptr [di],0FFh
		retn
loc_115:
		mov	al,[si+1]
		mov	cl,1Ch
		mul	cl			; ax = reg * al
		mov	cl,[si]
		xor	ch,ch			; Zero register
		add	ax,cx
		push	di
		add	ax,0E900h
		mov	di,ax
		mov	al,0FEh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	di,1Ah
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		pop	di
		mov	ah,[si+1]
		xor	al,al			; Zero register
		mov	bx,ax
		add	ax,ax
		shr	bx,1			; Shift w/zeros fill
		add	ax,bx
		shr	ax,1			; Shift w/zeros fill
		mov	cl,[si]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	ax,cx
		add	ax,41F8h
		push	si
		push	di
		push	es
		push	ax
		mov	al,[si+3]
		mov	ah,al
		mov	ds:data_66e,ax
		mov	bl,[si+2]
		and	bl,3
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:data_51e[bx]
		pop	di
		mov	ax,0B800h
		mov	es,ax
		mov	cx,10h

locloop_116:
		lodsw				; String [si] to ax
		xchg	ah,al
		call	anim_func_27
		not	bp
		and	es:[di],bp
		or	es:[di],dx
		call	anim_func_27
		not	bp
		and	es:[di+2],bp
		or	es:[di+2],dx
		lodsw				; String [si] to ax
		xchg	ah,al
		call	anim_func_27
		not	bp
		and	es:[di+4],bp
		or	es:[di+4],dx
		call	anim_func_27
		not	bp
		and	es:[di+6],bp
		or	es:[di+6],dx
		add	di,2000h
		cmp	di,8000h
		jb	loc_117			; Jump if below
		add	di,data_84e
loc_117:
		loop	locloop_116		; Loop if cx > 0

		pop	es
		pop	di
		pop	si
		dec	byte ptr [si+2]
		cmp	byte ptr [si+2],0FFh
		je	loc_118			; Jump if equal
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	si,4
loc_118:
		add	si,4
		jmp	loc_114
			                        ;* No entry point to code
		mov	al,3Ah			; ':'
;*		jo	loc_119			;*Jump if overflow=1
		db	 70h, 3Ah		;  Fixup - byte match
		xor	[bp+si],bh
                           lock	cmp	[bx+si],ax
		db	16 dup (0)
		db	 0Fh,0F0h, 00h, 00h, 3Fh,0FCh
		db	 00h, 00h,0FCh, 3Fh, 00h, 00h
		db	0F0h, 0Fh, 00h, 00h,0F0h, 0Fh
		db	 00h, 00h,0FCh, 3Fh, 00h, 00h
		db	 3Fh,0FCh, 00h, 00h, 0Fh,0F0h
		db	26 dup (0)
		db	 0Fh,0F0h, 00h, 00h, 3Fh,0FCh
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	0FCh, 3Fh, 00h, 03h,0F0h, 0Fh
		db	0C0h, 03h,0C0h, 03h,0C0h, 03h
		db	0C0h, 03h,0C0h, 03h,0F0h, 0Fh
		db	0C0h, 00h,0FCh, 3Fh, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 3Fh,0FCh
		db	 00h, 00h, 0Fh,0F0h
		db	10 dup (0)
		db	 0Fh,0F0h, 00h, 00h,0FFh,0FFh
		db	 00h, 03h,0FFh,0FFh,0C0h, 0Fh
		db	0FFh,0FFh,0F0h, 3Fh,0F0h, 0Fh
		db	0FCh, 3Fh,0C0h, 03h,0FCh,0FFh
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	0FFh,0FFh, 00h, 00h,0FFh,0FFh
		db	 00h, 00h,0FFh, 3Fh,0C0h, 03h
		db	0FCh, 3Fh,0F0h, 0Fh,0FCh, 0Fh
		db	0FFh,0FFh,0F0h, 03h,0FFh,0FFh
		db	0C0h, 00h,0FFh,0FFh, 00h, 00h
		db	 0Fh,0F0h, 00h, 00h, 3Fh,0FCh
		db	 00h, 03h,0FFh,0FFh,0C0h, 0Fh
		db	0C0h, 03h,0F0h, 3Fh, 00h, 00h
		db	0FCh, 3Ch, 00h, 00h, 3Ch,0FCh
		db	 00h, 00h, 3Fh,0F0h, 00h, 00h
		db	 0Fh,0F0h, 00h, 00h, 0Fh,0F0h
		db	 00h, 00h, 0Fh,0F0h, 00h, 00h
		db	 0Fh,0FCh, 00h, 00h, 3Fh, 3Ch
		db	 00h, 00h, 3Ch, 3Fh, 00h, 00h
		db	0FCh, 0Fh,0C0h, 03h,0F0h, 03h
		db	0FFh,0FFh,0C0h, 00h, 3Fh,0FCh
		db	 00h,0BFh, 59h, 52h, 0Eh, 07h
		db	 33h,0C0h,0ABh,0ABh,0ABh,0ABh
		db	0AAh,0BFh, 45h, 52h,0B9h, 08h
		db	 00h,0F3h,0ABh,0EBh, 3Ch,0E8h
		db	 0Eh, 04h,0BFh, 45h, 52h, 8Ah
		db	 16h, 35h,0FFh,0FEh,0CAh,0B9h
		db	 04h, 00h

locloop_120:
		push	cx
		and	dl,3Fh			; '?'
		mov	al,24h			; '$'
		mul	dl			; ax = reg * al
		mov	bx,ax
		add	bx,data_88e
		mov	al,byte ptr ds:[83h]
		add	al,3
		xor	ah,ah			; Zero register
		add	bx,ax
		mov	cx,4

locloop_121:
		mov	al,[bx]
		or	al,al			; Zero ?
		js	loc_122			; Jump if sign=1
		xor	al,al			; Zero register
loc_122:
		mov	[di],al
		inc	bx
		inc	di
		loop	locloop_121		; Loop if cx > 0

		inc	dl
		pop	cx
		loop	locloop_120		; Loop if cx > 0

		mov	al,byte ptr ds:[84h]
		xor	ah,ah			; Zero register
		mov	cx,140h
		mul	cx			; dx:ax = reg * ax
		mov	cl,byte ptr ds:[83h]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	ax,cx
		add	ax,41F8h
		mov	ds:data_60e,ax
		mov	byte ptr ds:data_63e,0
		mov	si,5259h
		mov	di,data_74e
		mov	cx,3

locloop_123:
		push	cx
		mov	cx,3

locloop_124:
		push	cx
		mov	ax,3BD3h
		push	ax
		mov	al,[di]
		or	al,[di+1]
		or	al,[di+4]
		or	al,[di+5]
		jnz	loc_125			; Jump if not zero
		jmp	loc_162
loc_125:
		test	byte ptr [di],0FFh
		jz	loc_126			; Jump if zero
		mov	al,[di]
		push	si
		call	anim_multiply_3
		inc	si
		inc	si
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_164
loc_126:
		test	byte ptr [di+1],0FFh
		jz	loc_127			; Jump if zero
		mov	al,[di+1]
		push	si
		call	anim_multiply_3
		inc	si
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_164
loc_127:
		test	byte ptr [di+4],0FFh
		jz	loc_128			; Jump if zero
		mov	al,[di+4]
		push	si
		call	anim_multiply_3
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_164
loc_128:
		mov	al,[di+5]
		push	si
		call	anim_multiply_3
		mov	cl,[si]
		pop	si
		mov	[si],al
		mov	al,cl
		jmp	loc_164
			                        ;* No entry point to code
		inc	byte ptr ds:data_63e
		inc	di
		inc	si
		pop	cx
		loop	locloop_124		; Loop if cx > 0

		pop	cx
		inc	di
		loop	locloop_123		; Loop if cx > 0

		mov	bl,ds:data_99e
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:data_56e[bx]
		mov	cs:data_57e,ax
		mov	es,cs:data_94e
		mov	al,byte ptr ds:[0E8h]
		or	al,ds:data_102e
		or	al,ds:data_103e
		jz	loc_129			; Jump if zero
		jmp	loc_139
loc_129:
		mov	cl,0FFh
		mov	si,6117h
		test	byte ptr ds:[0C2h],1
		jz	loc_130			; Jump if zero
		xor	cl,cl			; Zero register
		mov	si,61B9h
loc_130:
		test	byte ptr ds:data_106e,0FFh
		jz	loc_134			; Jump if zero
		inc	cl
		jnz	loc_131			; Jump if not zero
		mov	al,ds:data_105e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	anim_func_21
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,62C7h
		jmp	short loc_137
loc_131:
		mov	al,ds:data_105e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:data_107e
		dec	dl
		jnz	loc_132			; Jump if not zero
		add	ax,24h
		jmp	short loc_133
loc_132:
		dec	dl
		jnz	loc_133			; Jump if not zero
		mov	ax,63h
loc_133:
		add	si,ax
		jmp	short loc_137
loc_134:
		call	anim_func_21
		or	al,al			; Zero ?
		jz	loc_136			; Jump if zero
		dec	al
		mov	cl,al
		test	byte ptr ds:[0C2h],1
		jnz	loc_136			; Jump if not zero
		mov	ax,6Ch
		mov	dl,ds:data_101e
		and	dl,9
		xor	dh,dh			; Zero register
		add	ax,dx
		or	cl,cl			; Zero ?
		jz	loc_135			; Jump if zero
		add	ax,1Bh
loc_135:
		add	si,ax
		jmp	short loc_137
loc_136:
		test	byte ptr ds:data_101e,0FFh
		jnz	loc_139			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		cmp	al,80h
		je	loc_139			; Jump if equal
		add	al,2
		and	al,3
		test	al,1
		jnz	loc_139			; Jump if not zero
		mov	cl,9
		mul	cl			; ax = reg * al
		add	si,ax
		jmp	short loc_138
loc_137:
		test	byte ptr ds:data_101e,0FFh
		jz	loc_138			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:data_63e,3
		call	anim_multiply_4
		jmp	short loc_139
loc_138:
		mov	cx,9
		mov	byte ptr ds:data_63e,0
		call	anim_multiply_4
loc_139:
		mov	si,610Eh
		test	byte ptr ds:data_103e,0FFh
		jnz	loc_144			; Jump if not zero
		mov	si,60EAh
		test	byte ptr ds:data_102e,0FFh
		jnz	loc_142			; Jump if not zero
		mov	si,6075h
		test	byte ptr ds:[0C2h],1
		jnz	loc_140			; Jump if not zero
		mov	si,data_2e
loc_140:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_141			; Jump if zero
		add	si,5Ah
		jmp	short loc_142
loc_141:
		mov	ax,2Dh
		test	byte ptr ds:data_101e,0FFh
		jnz	loc_143			; Jump if not zero
		mov	ax,3Fh
		test	byte ptr ds:data_104e,80h
		jnz	loc_143			; Jump if not zero
		mov	cl,ds:data_108e
		mov	ax,48h
		dec	cl
		jz	loc_143			; Jump if zero
		mov	ax,51h
		dec	cl
		jz	loc_143			; Jump if zero
		mov	ax,36h
		cmp	byte ptr ds:data_104e,7Fh
		je	loc_143			; Jump if equal
		mov	ax,24h
		cmp	byte ptr ds:[0E7h],80h
		je	loc_143			; Jump if equal
loc_142:
		mov	al,byte ptr ds:[0E7h]
		and	al,3
		mov	cl,9
		mul	cl			; ax = reg * al
loc_143:
		add	si,ax
loc_144:
		mov	cx,9
		mov	byte ptr ds:data_63e,0
		call	anim_multiply_4
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_145			; Jump if zero
		retn
loc_145:
		mov	cl,0FFh
		mov	si,61B9h
		test	byte ptr ds:[0C2h],1
		jnz	loc_146			; Jump if not zero
		xor	cl,cl			; Zero register
		mov	si,6117h
loc_146:
		mov	al,ds:data_102e
		or	al,ds:data_103e
		jz	loc_148			; Jump if zero
		call	anim_func_21
		or	al,al			; Zero ?
		jnz	loc_147			; Jump if not zero
		retn
loc_147:
		dec	al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,1Bh
		add	al,7Eh			; '~'
		xor	ah,ah			; Zero register
		jmp	loc_155
loc_148:
		test	byte ptr ds:data_106e,0FFh
		jz	loc_152			; Jump if zero
		inc	cl
		jnz	loc_149			; Jump if not zero
		mov	al,ds:data_105e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	anim_func_21
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,625Bh
		jmp	short loc_156
loc_149:
		mov	al,ds:data_105e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:data_107e
		dec	dl
		jnz	loc_150			; Jump if not zero
		add	ax,24h
		jmp	short loc_151
loc_150:
		dec	dl
		jnz	loc_151			; Jump if not zero
		mov	ax,63h
loc_151:
		add	si,ax
		jmp	short loc_156
loc_152:
		test	byte ptr ds:[0C2h],1
		jz	loc_154			; Jump if zero
		call	anim_func_21
		or	al,al			; Zero ?
		jz	loc_154			; Jump if zero
		dec	al
		mov	cl,al
		mov	al,ds:data_101e
		and	al,9
		add	al,6Ch			; 'l'
		xor	ah,ah			; Zero register
		or	cl,cl			; Zero ?
		jz	loc_153			; Jump if zero
		add	ax,1Bh
loc_153:
		add	si,ax
		jmp	short loc_156
loc_154:
		mov	ax,1Bh
		test	byte ptr ds:data_101e,0FFh
		jnz	loc_155			; Jump if not zero
		mov	cl,byte ptr ds:[0E7h]
		cmp	cl,80h
		je	loc_155			; Jump if equal
		and	cl,3
		mov	al,9
		mul	cl			; ax = reg * al
loc_155:
		add	si,ax
loc_156:
		test	byte ptr ds:data_101e,0FFh
		jz	loc_157			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:data_63e,3
		jmp	short locloop_158
loc_157:
		mov	cx,9
		mov	byte ptr ds:data_63e,0
		jmp	short locloop_158

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_multiply_4		proc	near

locloop_158:
		push	cx
		mov	al,es:[si]
		or	al,al			; Zero ?
		jz	loc_159			; Jump if zero
		push	es
		push	ds
		push	si
		push	di
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,6333h
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bp,ax
		add	bp,data_7e
		mov	ds,cs:data_94e
		mov	di,dx
		push	cs
		pop	es
		mov	al,cs:data_63e
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,5562h
		mov	di,ax
		call	anim_func_11
		pop	di
		pop	si
		pop	ds
		pop	es
loc_159:
		inc	si
		inc	byte ptr ds:data_63e
		pop	cx
		loop	locloop_158		; Loop if cx > 0

		retn
anim_multiply_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_21		proc	near
		mov	al,byte ptr ds:[93h]
		or	al,al			; Zero ?
		jnz	loc_160			; Jump if not zero
		retn
loc_160:
		cmp	al,4
		mov	al,1
		jnc	loc_161			; Jump if carry=0
		retn
loc_161:
		mov	al,2
		retn
anim_func_21		endp

loc_162:
		mov	al,[si]
		push	ds
		push	si
		push	di
		push	ax
		mov	ds,cs:data_94e
		push	cs
		pop	es
		mov	al,cs:data_63e
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,5562h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_163			; Jump if zero
		dec	al
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	copy_buffer
		pop	di
		pop	si
		pop	ds
		retn
loc_163:
		call	fill_buffer
		pop	di
		pop	si
		pop	ds
		retn
loc_164:
		push	ds
		push	si
		push	di
		mov	cl,al
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_165			; Jump if not sign
		call	anim_get_value
loc_165:
		push	ax
		mov	bl,ds:data_65e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	dx,cs:data_56e[bx]
		mov	cs:data_57e,dx
		mov	al,cl
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bp,ax
		add	bp,0A000h
		mov	ds,cs:data_94e
		push	cs
		pop	es
		mov	al,cs:data_63e
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,5562h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_166			; Jump if zero
		mov	cl,al
		call	anim_multiply_2
		pop	di
		pop	si
		pop	ds
		retn
loc_166:
		call	anim_process_loop
		pop	di
		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		mov	cl,byte ptr ds:[84h]
		mov	al,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		add	ax,ds:data_96e
		mov	si,ax
		call	anim_func_41
		mov	di,data_77e
		push	cs
		pop	es
		mov	cx,3

locloop_167:
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	si,21h
		call	anim_func_41
		loop	locloop_167		; Loop if cx > 0

		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_22		proc	near
		mov	al,ds:data_62e
		neg	al
		add	al,12h
		mov	cl,al
		test	byte ptr ds:data_109e,0FFh
		jnz	loc_169			; Jump if not zero
		mov	al,byte ptr ds:[84h]
		sub	al,2
		cmp	al,cl
		jne	loc_ret_168		; Jump if not equal
		call	anim_process_loop_2

loc_ret_168:
		retn
loc_169:
		mov	al,byte ptr ds:[84h]
		sub	al,5
		cmp	cl,al
		jae	loc_170			; Jump if above or =
		retn
loc_170:
		jnz	loc_171			; Jump if not zero
		call	anim_func_23
		jmp	loc_205
loc_171:
		add	al,0Ah
		cmp	al,cl
		je	loc_172			; Jump if equal
		retn
loc_172:
		jmp	loc_189
			                        ;* No entry point to code
		test	byte ptr ds:data_109e,0FFh
		jnz	loc_173			; Jump if not zero
		retn
loc_173:
		push	es
		push	si
		push	di
		push	bx
		mov	es,cs:data_94e
		inc	byte ptr ds:data_112e
		mov	al,ds:data_111e
		or	al,al			; Zero ?
		jz	loc_177			; Jump if zero
		dec	al
		jz	loc_175			; Jump if zero
		cmp	byte ptr ds:data_112e,5
		jb	loc_174			; Jump if below
		jmp	loc_181
loc_174:
		xor	cl,cl			; Zero register
		mov	si,0B16Eh
		mov	word ptr ds:data_70e,0FF01h
		mov	dx,13Ch
		test	byte ptr ds:[0C2h],1
		jnz	loc_179			; Jump if not zero
		mov	si,0B0BEh
		mov	word ptr ds:data_70e,1
		mov	dx,140h
		jmp	short loc_179
loc_175:
		cmp	byte ptr ds:data_112e,5
		jb	loc_176			; Jump if below
		jmp	loc_181
loc_176:
		mov	bl,ds:data_112e
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B19Eh
		mov	si,0B12Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_178			; Jump if not zero
		mov	di,0B18Ah
		mov	si,0B07Eh
		jmp	short loc_178
loc_177:
		cmp	byte ptr ds:data_112e,7
		jae	loc_181			; Jump if above or =
		mov	bl,ds:data_112e
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B192h
		mov	si,0B0CEh
		test	byte ptr ds:[0C2h],1
		jnz	loc_178			; Jump if not zero
		mov	di,data_6e
		mov	si,0B01Eh
loc_178:
		mov	bx,es:[bx+di]
		mov	ds:data_70e,bx
		mov	al,bl
		cbw				; Convrt byte to word
		mov	dx,140h
		imul	dx			; dx:ax = reg * ax
		mov	dx,ax
		mov	al,bh
		cbw				; Convrt byte to word
		add	ax,ax
		add	ax,ax
		add	dx,ax
loc_179:
		mov	di,ds:data_60e
		add	di,dx
		test	byte ptr ds:data_101e,0FFh
		jz	loc_180			; Jump if zero
		add	di,140h
loc_180:
		mov	ds:data_68e,di
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	si,cx
		mov	ds:data_69e,si
		pop	bx
		pop	di
		pop	si
		pop	es
		jmp	loc_189
loc_181:
		mov	byte ptr ds:data_109e,0
		mov	byte ptr ds:data_112e,0
		pop	bx
		pop	di
		pop	si
		pop	es
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_23:
		test	byte ptr ds:data_110e,0FFh
		jnz	loc_182			; Jump if not zero
		retn
loc_182:
		push	es
		push	di
		push	si
		push	bx
		call	anim_func_25
		pop	bx
		pop	si
		pop	di
		pop	es
		mov	byte ptr ds:data_110e,0
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_24:
		push	ds
		push	cs
		pop	es
		mov	si,cs:data_68e
		mov	ax,0B800h
		mov	ds,ax
		mov	di,data_79e
		mov	cx,20h

locloop_183:
		push	cx
		mov	cx,8
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	si,1FF0h
		cmp	si,8000h
		jb	loc_184			; Jump if below
		add	si,80A0h
loc_184:
		pop	cx
		loop	locloop_183		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_25:
		mov	di,cs:data_68e
		mov	ax,0B800h
		mov	es,ax
		mov	si,data_79e
		mov	cx,20h

locloop_185:
		push	cx
		mov	cx,8
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	di,1FF0h
		cmp	di,8000h
		jb	loc_186			; Jump if below
		add	di,80A0h
loc_186:
		pop	cx
		loop	locloop_185		; Loop if cx > 0

		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_26:
		mov	al,byte ptr ds:[84h]
		add	al,ds:data_70e
		and	al,3Fh			; '?'
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,byte ptr ds:data_70e+1
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		mov	si,ax
		add	si,ds:data_96e
		call	anim_func_41
		mov	cx,4

locloop_187:
		push	cx
		mov	cx,4

locloop_188:
		push	cx
		mov	bl,[si]
		inc	si
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	word ptr ds:data_78e[bx],0
		pop	cx
		loop	locloop_188		; Loop if cx > 0

		add	si,20h
		call	anim_func_41
		pop	cx
		loop	locloop_187		; Loop if cx > 0

		retn
loc_189:
		test	byte ptr ds:data_109e,0FFh
		jnz	loc_190			; Jump if not zero
		retn
loc_190:
		mov	byte ptr ds:data_110e,0FFh
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	anim_func_26
		call	anim_func_24
		xor	bx,bx			; Zero register
		mov	bl,byte ptr cs:[92h]
		dec	bl
		add	bx,bx
		mov	ax,cs:data_52e[bx]
		mov	cs:data_66e,ax
		mov	ds,cs:data_94e
		mov	ax,0B800h
		mov	es,ax
		mov	di,cs:data_68e
		mov	si,cs:data_69e
		mov	cx,4

locloop_191:
		push	cx
		push	di
		mov	cx,4

locloop_192:
		push	cx
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_193			; Jump if not equal
		add	di,140h
		jmp	short loc_196
loc_193:
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,ds:data_5e
		mov	cx,8

locloop_194:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		call	anim_func_27
		not	bp
		and	es:[di],bp
		or	es:[di],dx
		call	anim_func_27
		not	bp
		and	es:[di+2],bp
		or	es:[di+2],dx
		add	di,2000h
		cmp	di,8000h
		jb	loc_195			; Jump if below
		add	di,80A0h
loc_195:
		pop	cx
		loop	locloop_194		; Loop if cx > 0

		pop	si
loc_196:
		pop	cx
		loop	locloop_192		; Loop if cx > 0

		pop	di
		add	di,4
		pop	cx
		loop	locloop_191		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
anim_func_22		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_27		proc	near
		xor	bp,bp			; Zero register
		xor	dx,dx			; Zero register
		xor	bx,bx			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jz	loc_198			; Jump if zero
		or	bp,0F0h
		mov	bh,byte ptr cs:data_66e+1
		cmp	bl,3
		je	loc_197			; Jump if equal
		mov	bh,cs:data_66e
loc_197:
		and	bh,0F0h
		mov	dl,bh
loc_198:
		xor	bx,bx			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jz	loc_200			; Jump if zero
		or	bp,0Fh
		mov	bh,byte ptr cs:data_66e+1
		cmp	bl,3
		je	loc_199			; Jump if equal
		mov	bh,cs:data_66e
loc_199:
		and	bh,0Fh
		or	dl,bh
loc_200:
		xor	bx,bx			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jz	loc_202			; Jump if zero
		or	bp,0F000h
		mov	bh,byte ptr cs:data_66e+1
		cmp	bl,3
		je	loc_201			; Jump if equal
		mov	bh,cs:data_66e
loc_201:
		and	bh,0F0h
		mov	dh,bh
loc_202:
		xor	bx,bx			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jnz	loc_203			; Jump if not zero
		retn
loc_203:
		or	bp,0F00h
		mov	bh,byte ptr cs:data_66e+1
		cmp	bl,3
		je	loc_204			; Jump if equal
		mov	bh,cs:data_66e
loc_204:
		and	bh,0Fh
		or	dh,bh
		retn
anim_func_27		endp

		db	 77h,0FFh, 33h,0BBh, 22h,0AAh
		db	 77h,0FFh, 33h,0BBh, 88h,0EEh
		db	 02h,0FFh,0E8h, 3Fh, 0Fh,0A3h
		db	 33h, 52h,0EBh
		db	0Dh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_process_loop_2		proc	near
loc_205:
		test	byte ptr ds:data_100e,0FFh
		jz	loc_206			; Jump if zero
		retn
loc_206:
		mov	byte ptr ds:data_100e,0FFh
loc_207:
		push	es
		push	ds
		push	si
		push	di
		push	bx
		mov	ax,0B800h
		mov	es,ax
		mov	si,data_80e
		mov	di,cs:data_60e
		mov	cx,3

locloop_208:
		push	cx
		mov	cx,3

locloop_209:
		push	cx
		push	di
		call	anim_check_state
		pop	di
		add	di,4
		pop	cx
		loop	locloop_209		; Loop if cx > 0

		add	di,134h
		pop	cx
		loop	locloop_208		; Loop if cx > 0

		pop	bx
		pop	di
		pop	si
		pop	ds
		pop	es
		retn
anim_process_loop_2		endp

			                        ;* No entry point to code
		push	ds
		push	si
		dec	al
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_94e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

locloop_210:
		push	cx
		lodsw				; String [si] to ax
		or	al,al			; Zero ?
		jz	loc_211			; Jump if zero
		mov	es:[di],al
loc_211:
		or	ah,ah			; Zero ?
		jz	loc_212			; Jump if zero
		mov	es:[di+1],ah
loc_212:
		lodsw				; String [si] to ax
		or	al,al			; Zero ?
		jz	loc_213			; Jump if zero
		mov	es:[di+2],al
loc_213:
		or	ah,ah			; Zero ?
		jz	loc_214			; Jump if zero
		mov	es:[di+3],ah
loc_214:
		add	di,2000h
		cmp	di,8000h
		jb	loc_215			; Jump if below
		add	di,80A0h
loc_215:
		pop	cx
		loop	locloop_210		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_110e,0
		mov	ax,0B800h
		mov	es,ax
		mov	byte ptr ds:data_72e,8
loc_216:
		mov	word ptr ds:data_59e,41F8h
		mov	byte ptr ds:data_93e,0
		mov	si,ds:data_96e
		mov	di,data_89e
		mov	cx,12h

locloop_217:
		push	cx
		add	si,4
		xor	bx,bx			; Zero register
		mov	cx,1Ch

locloop_218:
		push	cx
		lodsb				; String [si] to al
		call	anim_multiply_5
		inc	di
		inc	bl
		pop	cx
		loop	locloop_218		; Loop if cx > 0

		add	si,4
		call	anim_func_41
		add	word ptr ds:data_59e,140h
		pop	cx
		loop	locloop_217		; Loop if cx > 0

loc_219:
		cmp	byte ptr ds:data_93e,10h
		jb	loc_219			; Jump if below
		dec	byte ptr ds:data_72e
		jnz	loc_216			; Jump if not zero
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_multiply_5		proc	near
		cmp	byte ptr [di],0FFh
		jne	loc_220			; Jump if not equal
		retn
loc_220:
		cmp	byte ptr [di],0FCh
		jne	loc_221			; Jump if not equal
		retn
loc_221:
		push	ds
		push	di
		push	si
		push	bx
		push	ax
		mov	ah,ds:data_72e
		dec	ah
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sbb	ax,ax
		xor	ax,0F0F0h
		mov	cs:data_70e,ax
		add	bx,bx
		add	bx,bx
		add	bx,ds:data_59e
		mov	di,bx
		pop	ax
		test	al,0FFh
		jz	loc_223			; Jump if zero
		dec	al
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_94e
		push	si
		push	di
		mov	al,cs:data_72e
		and	al,3
		neg	al
		add	al,3
		call	anim_func_32
		call	anim_func_30
		pop	di
		pop	si
		mov	al,cs:data_72e
		call	anim_func_32
		add	di,2
		add	si,2
		call	anim_func_30
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_30:
		mov	cx,2

locloop_222:
		mov	bx,cs:data_70e
		lodsw				; String [si] to ax
		and	ax,bx
		not	bx
		and	es:[di],bx
		or	es:[di],ax
		add	di,0A0h
		add	si,0Eh
		loop	locloop_222		; Loop if cx > 0

		retn
loc_223:
		push	di
		mov	al,cs:data_72e
		and	al,3
		neg	al
		add	al,3
		call	anim_func_32
		call	anim_get_value_2
		pop	di
		mov	al,cs:data_72e
		call	anim_func_32
		add	di,2
		call	anim_get_value_2
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn
anim_multiply_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_get_value_2		proc	near
		mov	ax,cs:data_70e
		not	ax
		and	es:[di],ax
		add	di,data_113e
		and	es:[di],ax
		retn
anim_get_value_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_32		proc	near
		and	al,3
		xor	ah,ah			; Zero register
		push	ax
		add	ax,ax
		add	ax,ax
		add	si,ax
		pop	ax
		or	ax,ax			; Zero ?
		jnz	loc_224			; Jump if not zero
		retn
loc_224:
		add	di,2000h
		cmp	di,8000h
		jb	loc_225			; Jump if below
		add	di,80A0h
loc_225:
		dec	ax
		jnz	loc_224			; Jump if not zero
		retn
anim_func_32		endp

			                        ;* No entry point to code
		mov	al,byte ptr ds:[83h]
		add	al,al
		add	al,al
		add	al,al
		mov	ah,byte ptr ds:[84h]
		add	ah,ah
		add	ah,ah
		add	ah,ah
		mov	ds:data_57e,al
		mov	byte ptr ds:data_57e+1,ah
		call	anim_scan_loop
		mov	byte ptr ds:data_72e,0EEh
		call	anim_func_33
		mov	byte ptr ds:data_72e,0
		call	anim_func_33
		jmp	loc_252

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_33		proc	near
		mov	al,ds:data_57e
		dec	al
		mov	bl,al
		add	al,19h
		mov	dl,al
		mov	al,byte ptr ds:data_57e+1
		dec	al
		mov	bh,al
		add	al,19h
		mov	dh,al
		call	anim_func_34
		mov	al,ds:data_57e
		sub	al,5
		mov	bl,al
		add	al,21h			; '!'
		mov	dl,al
		mov	al,byte ptr ds:data_57e+1
		sub	al,5
		mov	bh,al
		add	al,21h			; '!'
		mov	dh,al
		call	anim_func_34
		mov	al,ds:data_57e
		sub	al,9
		mov	bl,al
		add	al,29h			; ')'
		mov	dl,al
		mov	al,byte ptr ds:data_57e+1
		sub	al,9
		mov	bh,al
		add	al,29h			; ')'
		mov	dh,al

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_34:
		mov	cx,9

locloop_226:
		push	cx
		push	dx
		push	bx
		call	anim_func_35
		pop	bx
		pop	dx
		sub	bl,0Ch
		jnc	loc_227			; Jump if carry=0
		xor	bl,bl			; Zero register
loc_227:
		sub	bh,0Ch
		jnc	loc_228			; Jump if carry=0
		xor	bh,bh			; Zero register
loc_228:
		add	dl,0Ch
		jnc	loc_229			; Jump if carry=0
		mov	dl,0FFh
loc_229:
		add	dh,0Ch
		jnc	loc_230			; Jump if carry=0
		mov	dh,0FFh
loc_230:
		push	dx
		push	bx
		call	anim_multiply_6
		pop	bx
		pop	dx
		pop	cx
		loop	locloop_226		; Loop if cx > 0

		retn
anim_func_33		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_35		proc	near
		mov	ax,0B800h
		mov	es,ax
		push	dx
		push	bx
		mov	dh,bh
		call	anim_extract_bits
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	bh,dh
		call	anim_extract_bits
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	dl,bl
		call	anim_func_36
		pop	bx
		pop	dx
		mov	bl,dl

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

anim_func_36:
		cmp	dh,bh
		jae	loc_231			; Jump if above or =
		xchg	dx,bx
loc_231:
		or	bl,bl			; Zero ?
		jnz	loc_232			; Jump if not zero
		retn
loc_232:
		cmp	bl,0DFh
		jb	loc_233			; Jump if below
		retn
loc_233:
		or	bh,bh			; Zero ?
		jnz	loc_234			; Jump if not zero
		mov	bh,1
loc_234:
		cmp	dh,8Fh
		jb	loc_235			; Jump if below
		mov	dh,8Eh
loc_235:
		mov	al,dh
		sub	al,bh
		inc	al
		push	ax
		mov	al,bh
		call	extract_bits_2
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		pop	cx
		xor	ch,ch			; Zero register
		and	bl,1
		jz	loc_236			; Jump if zero
		mov	ah,0Fh
		jmp	short loc_237
loc_236:
		mov	ah,0F0h
loc_237:
		mov	al,ah
		not	al
		and	ah,ds:data_72e

locloop_238:
		and	es:[di],al
		or	es:[di],ah
		add	di,2000h
		cmp	di,8000h
		jb	loc_239			; Jump if below
		add	di,80A0h
loc_239:
		loop	locloop_238		; Loop if cx > 0

		retn
anim_func_35		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_extract_bits		proc	near
		cmp	dl,bl
		jae	loc_240			; Jump if above or =
		xchg	dx,bx
loc_240:
		or	bh,bh			; Zero ?
		jnz	loc_241			; Jump if not zero
		retn
loc_241:
		cmp	bh,8Fh
		jb	loc_242			; Jump if below
		retn
loc_242:
		or	bl,bl			; Zero ?
		jnz	loc_243			; Jump if not zero
		mov	bl,1
loc_243:
		cmp	dl,0DFh
		jb	loc_244			; Jump if below
		mov	dl,0DEh
loc_244:
		mov	al,bh
		call	extract_bits_2
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		mov	ah,dl
		shr	ah,1			; Shift w/zeros fill
		sub	ah,al
		mov	cl,ah
		xor	ch,ch			; Zero register
		and	bl,1
		jz	loc_245			; Jump if zero
		mov	al,0Fh
		jmp	short loc_246
loc_245:
		mov	al,0FFh
loc_246:
		and	dl,1
		jz	loc_247			; Jump if zero
		mov	ah,0FFh
		jmp	short loc_248
loc_247:
		mov	ah,0F0h
loc_248:
		jcxz	loc_250			; Jump if cx=0
		dec	cx
		jcxz	loc_249			; Jump if cx=0
		mov	dh,al
		not	dh
		and	al,ds:data_72e
		and	es:[di],dh
		or	es:[di],al
		inc	di
		mov	al,0FFh
		and	al,ds:data_72e
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	dh,ah
		not	dh
		and	ah,ds:data_72e
		and	es:[di],dh
		or	es:[di],ah
		retn
loc_249:
		mov	dh,al
		not	dh
		and	al,ds:data_72e
		and	es:[di],dh
		or	es:[di],al
		inc	di
		mov	dh,ah
		not	dh
		and	ah,ds:data_72e
		and	es:[di],dh
		or	es:[di],ah
		retn
loc_250:
		and	al,ah
		mov	dh,al
		not	dh
		and	al,ds:data_72e
		and	es:[di],dh
		or	es:[di],al
		retn
anim_extract_bits		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

extract_bits_2		proc	near
		push	bx
		add	al,0Eh
		mov	bh,al
		ror	bh,1			; Rotate
		ror	bh,1			; Rotate
		ror	bh,1			; Rotate
		and	bx,6000h
		mov	di,bx
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	bl,0A0h
		mul	bl			; ax = reg * al
		add	ax,18h
		add	di,ax
		pop	bx
		retn
extract_bits_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_multiply_6		proc	near
		mov	cl,ds:data_97e
		shr	cl,1			; Shift w/zeros fill
		inc	cl
		mov	al,1
		mul	cl			; ax = reg * al
loc_251:
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		cmp	ds:data_93e,al
		jb	loc_251			; Jump if below
		mov	byte ptr ds:data_93e,0
		retn
anim_multiply_6		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_scan_loop		proc	near
loc_252:
		mov	ax,0B800h
		mov	es,ax
		mov	di,data_114e
		mov	cx,8

locloop_253:
		push	cx
		push	di
		mov	cx,12h

locloop_254:
		push	cx
		push	di
		mov	cx,38h
		mov	ax,4444h

locloop_255:
		xor	es:[di],ax
		inc	di
		inc	di
		loop	locloop_255		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_254		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_256			; Jump if below
		add	di,80A0h
loc_256:
		pop	cx
		loop	locloop_253		; Loop if cx > 0

		retn
anim_scan_loop		endp

			                        ;* No entry point to code
		and	al,3Fh			; '?'
		mov	bx,ax
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,0Eh
		sub	bh,4
		add	bh,bh
		add	bh,bh
		add	bh,18h
		call	extract_bits_4
		mov	di,ax
		retn
			                        ;* No entry point to code
		mov	bl,byte ptr ds:[9Dh]
		or	bl,bl			; Zero ?
		jz	loc_257			; Jump if zero
		cmp	bl,7
		je	loc_257			; Jump if equal
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	es,cs:data_94e
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	si,[bx]
		mov	di,data_4e
		mov	cx,480h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
loc_257:
		mov	ds,cs:data_94e
		mov	si,8CF0h
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_41		proc	near
		cmp	si,0E900h
		jae	loc_258			; Jump if above or =
		retn
loc_258:
		sub	si,900h
		retn
anim_func_41		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_func_42		proc	near
		cmp	si,0E000h
		jb	loc_259			; Jump if below
		retn
loc_259:
		add	si,900h
		retn
anim_func_42		endp

			                        ;* No entry point to code
		push	si
		push	ds
		mov	word ptr cs:data_66e,0CC44h
		mov	si,data_53e
		mov	di,658h
		mov	ax,0B800h
		mov	es,ax
		mov	cx,5

locloop_260:
		push	cx
		mov	cx,1Ch

locloop_261:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	ds,cs:data_94e
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,4000h
		mov	si,ax
		push	di
		mov	cx,8

locloop_262:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		call	anim_func_27
		mov	es:[di],dx
		call	anim_func_27
		mov	es:[di+2],dx
		add	di,2000h
		cmp	di,8000h
		jb	loc_263			; Jump if below
		add	di,80A0h
loc_263:
		pop	cx
		loop	locloop_262		; Loop if cx > 0

		pop	di
		add	di,4
		pop	si
		pop	ds
		pop	cx
		loop	locloop_261		; Loop if cx > 0

		add	di,0D0h
		pop	cx
		loop	locloop_260		; Loop if cx > 0

		pop	ds
		pop	si
		retn
		db	 00h, 01h, 02h, 04h, 07h, 09h
		db	 0Dh, 10h, 04h, 15h, 17h, 1Ch
		db	 1Eh, 04h, 07h, 09h, 22h, 02h
		db	 25h, 08h, 02h, 28h, 02h, 2Dh
		db	 31h, 36h, 3Bh, 40h, 00h, 01h
		db	 03h, 06h, 08h, 0Ah, 0Eh, 11h
		db	 06h, 08h, 18h, 0Eh, 1Eh, 04h
		db	8, 0Ah, '#$'
		db	'&', 8, 27h, ')*'
		db	 04h, 32h, 37h, 3Ch, 06h, 00h
		db	 01h, 02h, 05h, 08h, 02h, 0Eh
		db	 12h, 06h, 08h, 19h, 0Eh, 1Eh
		db	 04h, 08h, 02h, 23h, 24h, 26h
		db	 08h, 25h, 29h, 02h, 2Eh, 33h
		db	 38h, 3Dh, 06h, 00h, 01h, 03h
		db	 06h, 08h, 0Bh, 0Eh, 13h, 06h
		db	 08h, 1Ah, 0Eh, 1Fh, 04h, 08h
		db	 0Bh
		db	'#$'
		db	'&', 8, 27h, ')+/49>'
		db	 06h, 00h, 01h, 02h, 04h, 08h
		db	 0Ch, 0Fh, 14h, 04h, 16h, 1Bh
		db	 1Dh
		db	' !', 8, 0Ch, '#$'
		db	'&', 8
		db	 02h, 28h, 2Ch, 30h, 35h, 3Ah
		db	 3Fh, 06h,0A2h, 43h, 52h,0BEh
		db	 55h, 49h,0C7h, 06h, 31h, 52h
		db	0F8h, 41h,0B9h, 12h, 00h

locloop_264:
		push	cx
		mov	cx,1Ch

locloop_265:
		push	cx
		lodsb				; String [si] to al
		push	si
		call	anim_multiply_7
		pop	si
		add	word ptr ds:data_59e,4
		pop	cx
		loop	locloop_265		; Loop if cx > 0

		add	word ptr ds:data_59e,0D0h
		pop	cx
		loop	locloop_264		; Loop if cx > 0

		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_multiply_7		proc	near
		push	ds
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:data_94e
		mov	ax,0B800h
		mov	es,ax
		mov	di,cs:data_59e
		mov	cx,8

locloop_266:
		push	cx
		lodsw				; String [si] to ax
		call	anim_process_loop_3
		stosw				; Store ax to es:[di]
		lodsw				; String [si] to ax
		call	anim_process_loop_3
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_267			; Jump if below
		add	di,80A0h
loc_267:
		pop	cx
		loop	locloop_266		; Loop if cx > 0

		pop	ds
		retn
anim_multiply_7		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_process_loop_3		proc	near
		or	ax,ax			; Zero ?
		jnz	loc_268			; Jump if not zero
		retn
loc_268:
		mov	cx,4

locloop_269:
		push	cx
		add	ax,ax
		adc	cl,cl
		add	ax,ax
		adc	cl,cl
		add	ax,ax
		adc	cl,cl
		add	ax,ax
		adc	cl,cl
		and	cl,0Fh
		mov	bl,cs:data_72e
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_54e[bx]	;*
		add	dx,dx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		or	dl,cl
		pop	cx
		loop	locloop_269		; Loop if cx > 0

		mov	ax,dx
		retn
anim_process_loop_3		endp

			                        ;* No entry point to code
		cmpsw				; Cmp [si] to es:[di]
		dec	ax
		ror	byte ptr [bx+si-21h],1	; Rotate
		dec	ax
		cld				; Clear direction
		dec	ax
		daa				; Decimal adjust
		dec	cx
		mov	ch,2
		cmp	cl,6
		jne	loc_270			; Jump if not equal
		jmp	loc_274
loc_270:
		mov	ch,0Ah
		cmp	cl,0Eh
		jne	loc_271			; Jump if not equal
		jmp	loc_274
loc_271:
		mov	ch,5
		cmp	cl,1
		jne	loc_272			; Jump if not equal
		jmp	loc_274
loc_272:
		mov	ch,0Dh
		cmp	cl,9
		jne	loc_ret_273		; Jump if not equal
		jmp	loc_274

loc_ret_273:
		retn
			                        ;* No entry point to code
		mov	ch,4
		cmp	cl,3
		je	loc_274			; Jump if equal
		mov	ch,0Ch
		cmp	cl,0Bh
		je	loc_274			; Jump if equal
		retn
			                        ;* No entry point to code
		mov	ch,1
		cmp	cl,3
		je	loc_274			; Jump if equal
		mov	ch,9
		cmp	cl,0Bh
		je	loc_274			; Jump if equal
		mov	ch,3
		cmp	cl,5
		je	loc_274			; Jump if equal
		mov	ch,0Bh
		cmp	cl,0Dh
		je	loc_274			; Jump if equal
		retn
			                        ;* No entry point to code
		mov	ch,2
		cmp	cl,3
		je	loc_274			; Jump if equal
		mov	ch,0Ah
		cmp	cl,0Bh
		je	loc_274			; Jump if equal
		mov	ch,1
		cmp	cl,5
		je	loc_274			; Jump if equal
		mov	ch,9
		cmp	cl,0Dh
		je	loc_274			; Jump if equal
		mov	ch,5
		cmp	cl,6
		je	loc_274			; Jump if equal
		mov	ch,0Dh
		cmp	cl,0Eh
		je	loc_274			; Jump if equal
		retn
			                        ;* No entry point to code
		mov	ch,1
		cmp	cl,5
		je	loc_274			; Jump if equal
		mov	ch,9
		cmp	cl,0Dh
		je	loc_274			; Jump if equal
		mov	ch,5
		cmp	cl,3
		je	loc_274			; Jump if equal
		mov	ch,0Dh
		cmp	cl,0Bh
		je	loc_274			; Jump if equal
		mov	ch,3
		cmp	cl,6
		je	loc_274			; Jump if equal
		mov	ch,0Bh
		cmp	cl,0Eh
		je	loc_274			; Jump if equal
		retn
loc_274:
		mov	cl,ch
		retn
			                        ;* No entry point to code
		pop	es
		or	[bx+di],cl
		or	al,[bx]
		or	[bp+di],cl
		or	al,7
		or	[bx+di],cl
		or	bl,[bx+di]
		cmp	ax,2761h
		sbb	ax,1D1Eh
		push	ds
		pop	ds
		and	[bx],bl
		and	[di],bl
		push	ds
		pop	ds
		and	[di],cl
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		adc	[bx],cl
		adc	[di],cl
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		adc	[bx],dl
		sbb	ds:data_82e,bh
		sub	ah,es:[di]
		and	[bp+si],sp
		and	[bp+si],sp
		and	sp,[si]
		and	[bp+si],sp
		and	[bp+si],sp
		or	[bp+si],cx
		pop	es
		or	[bx],al
		or	[bx+di],cl
		or	al,[bx]
		or	[bx+di],bl
		push	sp
		pop	cx
		pop	bp
		db	 63h, 32h, 2Fh, 2Eh, 1Fh, 20h
		db	 1Fh, 20h, 1Dh, 1Eh, 1Fh, 20h
		db	 1Fh, 20h, 0Fh, 10h, 11h, 12h
		db	 0Fh, 10h, 0Dh, 0Eh, 17h, 18h
		db	'PUZ^df(0#$'
		db	'!"#$'
		db	'!"#$'
		db	 07h, 08h, 0Ah, 0Ch, 07h, 08h
		db	 09h, 0Ah, 1Ah
		db	'4QV[_eg/-'
		db	 1Dh, 1Eh, 1Fh, 20h, 1Dh, 1Eh
		db	 1Fh, 20h, 1Dh, 1Eh, 0Fh, 10h
		db	 0Dh, 0Eh, 0Dh, 0Eh, 17h, 18h
		db	 49h, 4Dh, 52h, 57h, 00h
		db	'`ihjk(&!"+&!"!"'
		db	7
		db	8, 9, 0Ah, 9, 0Ah, 1Bh, 'FJNSX'
		db	 00h, 00h, 00h, 00h, 69h, 6Ch
		db	 31h, 2Dh, 1Fh, 20h, 2Ch, 2Dh
		db	 1Fh, 20h, 1Fh, 20h, 13h, 14h
		db	 13h, 14h, 17h, 18h
		db	 43h, 47h, 4Bh, 4Fh
		db	7 dup (0)
		db	'mno)&!"*%!"'
		db	 15h, 16h, 15h, 16h, 1Ch
		db	 35h, 44h, 48h, 4Ch
		db	9 dup (0)
		db	 69h, 71h, 73h, 74h, 1Fh, 20h
		db	 2Ch, 27h, 1Fh, 20h, 17h, 18h
		db	 38h, 3Ah, 3Fh, 42h, 45h
		db	12 dup (0)
		db	'muwyo+&)&'
		db	 1Ah, 34h, 39h, 3Bh, 40h, 41h
		db	14 dup (0)
		db	'vxz{12/-367<'
		db	0
		db	18 dup (0)
		db	 6Dh, 71h, 70h, 72h, 70h
		db	84 dup (0)
		db	 01h, 02h, 01h, 02h, 01h, 02h
		db	 01h, 02h, 01h, 02h, 01h, 02h
		db	 01h, 02h, 01h, 02h, 01h, 02h
		db	 01h, 02h, 01h, 02h, 01h, 02h
		db	 01h, 02h, 01h, 02h, 03h, 04h
		db	 03h, 04h, 03h, 04h, 03h, 04h
		db	 03h, 04h, 03h, 04h, 03h, 04h
		db	 03h, 04h, 03h, 04h, 03h, 04h
		db	 03h, 04h, 03h, 04h, 03h, 04h
		db	 03h, 04h, 05h, 06h, 05h, 06h
		db	 05h, 06h, 05h, 06h, 05h, 06h
		db	 05h, 06h, 05h, 06h, 05h, 06h
		db	 05h, 06h, 05h, 06h, 05h, 06h
		db	 06h, 05h, 05h, 06h, 05h, 06h
		db	 1Eh, 50h, 02h,0FFh,0E8h, 60h
		db	 06h, 8Bh,0F8h, 2Eh,0C7h, 06h
		db	 2Fh, 52h,0DEh, 51h, 58h,0B1h
		db	 20h,0F6h,0E1h, 05h, 00h, 60h
		db	 8Bh,0F0h, 2Eh, 8Eh, 1Eh, 2Ch
		db	0FFh,0B8h, 00h,0B8h, 8Eh,0C0h
		db	0B9h, 08h, 00h

locloop_275:
		lodsw				; String [si] to ax
		call	extract_bits
		stosw				; Store ax to es:[di]
		lodsw				; String [si] to ax
		call	extract_bits
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_276			; Jump if below
		add	di,80A0h
loc_276:
		loop	locloop_275		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	word ptr cs:data_66e,0FF77h
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_55e[bx]
		mov	di,4D68h
		mov	ax,0B800h
		mov	es,ax
		mov	cx,18h

locloop_277:
		lodsw				; String [si] to ax
		xchg	ah,al
		call	anim_func_27
		not	bp
		and	es:[di],bp
		or	es:[di],dx
		call	anim_func_27
		not	bp
		and	es:[di+2],bp
		or	es:[di+2],dx
		lodsw				; String [si] to ax
		xchg	ah,al
		call	anim_func_27
		not	bp
		and	es:[di+4],bp
		or	es:[di+4],dx
		call	anim_func_27
		not	bp
		and	es:[di+6],bp
		or	es:[di+6],dx
		add	di,2000h
		cmp	di,8000h
		jb	loc_278			; Jump if below
		add	di,80A0h
loc_278:
		loop	locloop_277		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		pop	es
		dec	sp
		pop	es
		dec	sp
		pop	es
		dec	sp
		db	 67h, 4Ch, 67h, 4Ch,0C7h, 4Ch
		db	45 dup (0)
		db	 02h, 00h, 00h, 00h, 06h, 00h
		db	 00h, 00h, 06h, 00h, 00h, 00h
		db	 0Eh, 00h, 00h, 00h, 0Eh, 00h
		db	 00h, 00h, 0Ch, 00h, 00h, 00h
		db	 0Eh, 00h, 00h, 00h, 1Ch, 00h
		db	 00h, 00h, 0Ch, 00h, 00h, 00h
		db	 1Ch, 00h, 00h, 00h, 1Ch, 00h
		db	 00h, 00h, 1Ch, 00h, 00h, 00h
		db	 1Ch
		db	16 dup (0)
		db	 80h, 00h, 00h, 01h, 80h, 00h
		db	 00h, 03h, 80h, 00h, 00h, 03h
		db	 00h, 00h, 00h, 07h, 80h, 00h
		db	 00h, 07h, 00h, 00h, 00h, 07h
		db	 00h, 00h, 00h, 0Fh, 00h, 00h
		db	 00h, 0Eh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 1Eh, 00h, 00h
		db	 00h, 0Eh, 00h, 00h, 00h, 1Fh
		db	 00h, 00h, 00h, 1Eh, 00h, 00h
		db	 00h, 1Fh, 00h, 00h, 00h, 1Eh
		db	 00h, 00h, 00h, 1Eh, 00h, 00h
		db	 00h, 1Eh, 00h, 00h, 00h, 1Eh
		db	 00h, 00h, 00h, 1Ch, 00h, 00h
		db	 00h
		db	3Fh
		db	12 dup (0)
		db	 40h, 00h, 00h, 00h,0C0h, 00h
		db	 00h, 01h,0C0h, 00h, 00h, 03h
		db	 80h, 00h, 00h, 03h, 80h, 00h
		db	 00h, 07h, 80h, 00h, 00h, 07h
		db	 00h, 00h, 00h, 07h, 00h, 00h
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 0Eh, 00h, 00h
		db	 00h, 1Fh, 00h, 00h, 00h, 0Eh
		db	 00h, 00h, 00h, 1Fh, 00h, 00h
		db	 00h, 1Eh, 00h, 00h, 00h, 1Fh
		db	 00h, 00h, 00h, 1Eh, 00h, 00h
		db	 00h, 1Fh, 00h, 00h, 00h, 1Fh
		db	 00h, 00h, 00h, 1Eh, 00h, 00h
		db	 03h, 1Ch,0C0h, 00h, 00h,0FFh
		db	 00h, 00h, 2Eh,0C7h, 06h, 3Bh
		db	 52h, 77h,0FFh, 1Eh, 0Ah,0C0h
		db	 78h, 10h, 24h, 03h,0B2h, 40h
		db	0F6h,0E2h, 05h,0E8h, 4Dh, 8Bh
		db	0F0h,0BDh, 01h, 00h,0EBh, 0Eh
		db	 24h, 01h, 8Ah,0E0h, 32h,0C0h
		db	 05h,0E8h, 4Eh, 8Bh,0F0h,0BDh
		db	 04h, 00h, 8Ah,0C3h, 24h, 01h
		db	 02h,0C0h, 02h,0C0h,0A2h, 44h
		db	 52h,0D1h,0EBh, 8Ah,0FBh, 8Ah
		db	0D9h,0E8h, 4Fh, 04h, 8Bh,0F8h
		db	0B8h, 00h,0B8h, 8Eh,0C0h, 8Bh
		db	0CDh

locloop_279:
		push	cx
		push	di
		mov	cx,10h

locloop_280:
		push	cx
		push	di
		mov	cx,2

locloop_281:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		call	anim_func_27
		push	ax
		call	extract_bits_3
		pop	ax
		call	anim_func_27
		call	extract_bits_3
		pop	cx
		loop	locloop_281		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	loc_282			; Jump if below
		add	di,data_3e
loc_282:
		pop	cx
		loop	locloop_280		; Loop if cx > 0

		pop	di
		add	di,8
		pop	cx
		loop	locloop_279		; Loop if cx > 0

		pop	ds
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

extract_bits_3		proc	near
		push	dx
		mov	cl,cs:data_73e
		mov	ax,bp
		mov	bh,al
		xor	bl,bl			; Zero register
		xor	al,al			; Zero register
		shr	bx,cl			; Shift w/zeros fill
		shr	ax,cl			; Shift w/zeros fill
		or	bl,ah
		mov	ah,al
		not	bx
		not	ah
		and	es:[di],bh
		and	es:[di+1],bl
		and	es:[di+2],ah
		pop	ax
		mov	bh,al
		xor	bl,bl			; Zero register
		xor	al,al			; Zero register
		shr	bx,cl			; Shift w/zeros fill
		shr	ax,cl			; Shift w/zeros fill
		or	bl,ah
		mov	ah,al
		or	es:[di],bh
		inc	di
		or	es:[di],bl
		inc	di
		or	es:[di],ah
		retn
extract_bits_3		endp

		db	22 dup (0)
		db	 10h, 00h, 00h, 10h, 60h, 00h
		db	 00h, 07h,0C0h, 00h, 00h, 07h
		db	0C0h, 00h, 00h, 07h,0C0h, 00h
		db	 00h, 0Ch, 10h, 00h, 00h, 10h
		db	 00h
		db	26 dup (0)
		db	 01h, 00h, 00h, 00h, 01h, 00h
		db	 00h, 00h, 40h, 04h, 00h, 00h
		db	 01h, 00h, 00h, 00h, 09h, 20h
		db	 00h, 00h, 03h, 80h, 00h, 04h
		db	 57h,0D4h, 80h, 00h, 03h, 80h
		db	 00h, 00h, 09h, 20h, 00h, 00h
		db	 01h, 00h, 00h, 00h, 40h, 04h
		db	 00h, 00h, 01h, 00h, 00h, 00h
		db	 01h
		db	7 dup (0)
		db	 01h, 00h, 00h, 00h, 01h, 00h
		db	 00h, 00h, 01h, 00h, 00h, 00h
		db	 02h, 80h, 00h, 00h, 83h, 80h
		db	 00h, 00h, 23h, 88h, 00h, 00h
		db	 0Dh,0B0h, 00h, 00h, 0Bh,0E8h
		db	 00h, 96h,0FFh,0FFh,0B9h, 00h
		db	 17h,0E8h, 00h, 00h, 0Bh, 58h
		db	 00h, 00h, 23h, 82h, 00h, 00h
		db	 02h, 80h, 80h, 02h, 01h, 00h
		db	 00h, 00h, 01h, 00h, 00h, 00h
		db	 01h, 00h
		db	8 dup (0)
		db	 10h, 10h, 00h, 00h, 00h, 04h
		db	 00h, 00h, 80h, 00h, 80h, 03h
		db	 00h, 00h, 71h, 0Ch, 00h, 00h
		db	 3Dh, 38h, 00h, 00h, 07h,0F0h
		db	 00h, 00h, 97h,0E5h, 00h, 00h
		db	 0Fh,0F0h, 00h, 00h, 1Fh, 38h
		db	 00h, 00h, 39h, 0Eh, 00h, 00h
		db	0E1h, 01h, 80h, 01h, 00h, 00h
		db	 40h, 04h, 00h, 00h, 08h, 10h
		db	35 dup (0)
		db	 92h, 4Ah,0AAh,0EBh, 00h
		db	34 dup (0)
		db	 01h, 00h, 00h, 00h, 01h, 00h
		db	 00h, 01h, 01h, 00h, 00h, 00h
		db	 82h, 00h, 00h, 00h,0ABh, 00h
		db	 00h, 01h, 5Dh, 04h, 24h,0AEh
		db	0EFh,0FFh,0FFh,0FFh,0FFh, 04h
		db	 24h,0ABh,0EFh, 00h, 00h, 01h
		db	 5Dh, 00h, 00h, 00h, 22h, 00h
		db	 00h, 00h, 81h, 00h, 00h, 00h
		db	 01h, 00h, 00h, 00h, 01h, 00h
		db	19 dup (0)
		db	 81h, 00h, 00h, 00h,0C4h, 00h
		db	 00h, 00h,0BCh, 00h, 00h, 00h
		db	0EEh,0EAh, 24h, 20h,0FFh,0FFh
		db	0FFh,0FFh,0FBh,0AAh, 24h, 20h
		db	0FDh, 40h, 00h, 00h,0E6h, 00h
		db	 00h, 00h, 40h, 80h, 00h, 00h
		db	 00h
		db	20h
		db	42 dup (0)
		db	0D7h, 55h, 52h, 49h
		db	60 dup (0)
		db	0A7h, 54h, 90h, 04h, 00h
		db	37 dup (0)
		db	 10h, 00h, 00h, 00h, 04h, 00h
		db	 00h, 00h, 00h, 80h, 00h, 00h
		db	 00h, 71h, 00h, 00h, 00h, 3Dh
		db	 00h, 00h, 00h, 07h, 10h, 04h
		db	 00h, 97h, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 1Fh, 00h, 00h
		db	 00h, 39h, 00h, 00h, 00h,0E1h
		db	 00h, 00h, 01h, 00h, 00h, 00h
		db	 04h, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 10h
		db	7 dup (0)
		db	 80h, 00h, 00h, 03h, 00h, 00h
		db	 00h, 0Ch, 00h, 00h, 00h, 38h
		db	 00h, 00h, 00h,0F0h, 00h, 00h
		db	 00h,0E5h, 02h, 00h, 10h,0F0h
		db	 00h, 00h, 00h, 3Ch, 00h, 00h
		db	 00h, 07h, 00h, 00h, 00h, 00h
		db	0C0h, 00h, 00h, 00h, 20h, 00h
		db	 00h, 00h, 04h
		db	38 dup (0)
		db	 20h, 09h, 2Ah,0E5h
		db	28 dup (0)
		db	 51h, 1Eh, 56h, 8Ch,0C8h, 05h
		db	 00h, 30h, 8Eh,0C0h,0B8h, 20h
		db	 00h,0F7h,0E1h, 8Bh,0C8h,0BFh
		db	 00h, 00h,0F3h,0A4h, 5Fh, 07h
		db	 59h, 8Ch,0C8h, 05h, 00h, 30h
		db	 8Eh,0D8h,0BEh, 00h, 00h

locloop_283:
		push	cx
		mov	cx,8

locloop_284:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	dx,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cx,ax
		mov	cs:data_59e,dx
		mov	cs:data_61e,cx
		or	ax,dx
		mov	bx,ax
		shr	bx,1			; Shift w/zeros fill
		or	ax,bx
		add	bx,bx
		add	bx,bx
		or	ax,bx
		not	ax
		mov	cs:data_66e,ax
		call	anim_process_loop_4
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	anim_process_loop_4
		mov	ax,dx
		xchg	ah,al
		stosw				; Store ax to es:[di]
		call	anim_scan_loop_2
		mov	es:[bp],dl
		inc	bp
		pop	cx
		loop	locloop_284		; Loop if cx > 0

		pop	cx
		loop	locloop_283		; Loop if cx > 0

		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_process_loop_4		proc	near
		mov	cx,4

locloop_285:
		rol	word ptr cs:data_61e,1	; Rotate
		adc	dx,dx
		rol	word ptr cs:data_59e,1	; Rotate
		adc	dx,dx
		rol	word ptr cs:data_61e,1	; Rotate
		adc	dx,dx
		rol	word ptr cs:data_59e,1	; Rotate
		adc	dx,dx
		loop	locloop_285		; Loop if cx > 0

		retn
anim_process_loop_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_scan_loop_2		proc	near
		mov	cx,8

locloop_286:
		xor	al,al			; Zero register
		rol	word ptr cs:data_66e,1	; Rotate
		adc	al,al
		rol	word ptr cs:data_66e,1	; Rotate
		adc	al,al
		cmp	al,3
		je	loc_287			; Jump if equal
		xor	al,al			; Zero register
loc_287:
		and	al,1
		add	dl,dl
		or	dl,al
		loop	locloop_286		; Loop if cx > 0

		retn
anim_scan_loop_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

anim_process_loop_5		proc	near
		mov	cx,4

locloop_288:
		add	dl,dl
		sbb	dh,dh
		and	dh,0Fh
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		or	al,dh
		loop	locloop_288		; Loop if cx > 0

		xchg	ah,al
		retn
anim_process_loop_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

extract_bits_4		proc	near
		mov	dh,bl
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		mov	ax,0A0h
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		mul	bl			; ax = reg * al
		add	ax,dx
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		retn
extract_bits_4		endp

		db	0DEh, 51h,0EEh, 51h,0FEh, 51h
		db	 0Eh, 52h, 1Eh, 52h, 0Eh, 52h
		db	 00h, 07h, 04h, 02h, 07h, 0Fh
		db	 0Ch, 0Eh, 04h, 0Ch, 0Ch, 0Eh
		db	 02h, 0Eh, 0Eh, 0Ah, 00h, 04h
		db	 03h, 08h, 04h, 0Ch, 07h, 06h
		db	 03h, 07h, 0Bh, 0Ah, 08h, 06h
		db	 0Ah, 0Eh, 00h, 07h, 03h, 01h
		db	 07h, 0Fh, 0Bh, 09h, 03h, 0Bh
		db	 0Bh, 09h, 01h, 09h, 09h, 09h
		db	 00h, 01h, 08h, 05h, 01h, 09h
		db	 07h, 05h, 08h, 07h, 0Eh, 0Ch
		db	 05h, 05h, 0Ch, 0Dh, 00h, 08h
		db	 01h, 05h, 08h, 0Eh, 07h, 0Ch
		db	 01h, 07h, 09h, 05h, 05h, 0Ch
		db	 05h, 0Dh,0C3h, 00h
		db	1138 dup (0)

seg_a		ends



		end	start
