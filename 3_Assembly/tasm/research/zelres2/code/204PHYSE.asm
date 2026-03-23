
PAGE  59,132

;==========================================================================
;
;  PHYSICS_ENGINE - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	4000h			;*
data_2e		equ	6000h			;*
data_3e		equ	6333h			;*
data_4e		equ	8640h			;*
data_5e		equ	8690h			;*
data_6e		equ	0B000h			;*
data_7e		equ	0B17Eh			;*
data_8e		equ	0D000h			;*
data_60e	equ	317Eh			;*
data_61e	equ	37A2h			;*
data_62e	equ	3844h			;*
data_63e	equ	45ABh			;*
data_64e	equ	46D0h			;*
data_65e	equ	4982h			;*
data_66e	equ	4C38h			;*
data_67e	equ	4EFFh			;*
data_68e	equ	4F46h			;*
data_69e	equ	4F86h			;*
data_70e	equ	4FE2h			;*
data_72e	equ	4FE4h			;*
data_73e	equ	4FE6h			;*
data_74e	equ	4FE8h			;*
data_75e	equ	4FEAh			;*
data_76e	equ	4FEBh			;*
data_77e	equ	4FECh			;*
data_78e	equ	4FEDh			;*
data_79e	equ	4FEFh			;*
data_80e	equ	4FF1h			;*
data_81e	equ	4FF3h			;*
data_83e	equ	4FF5h			;*
data_84e	equ	4FF7h			;*
data_85e	equ	4FF8h			;*
data_86e	equ	4FF9h			;*
data_87e	equ	5009h			;*
data_88e	equ	500Ah			;*
data_89e	equ	500Dh			;*
data_90e	equ	5016h			;*
data_91e	equ	5116h			;*
data_92e	equ	5216h			;*
data_93e	equ	52A6h			;*
data_94e	equ	6000h			;*
data_95e	equ	625Ch			;*
data_96e	equ	0A030h			;*
data_97e	equ	0A05Ah			;*
data_98e	equ	0B24Fh			;*
data_99e	equ	0C010h			;*
data_100e	equ	0C012h			;*
data_101e	equ	0E000h			;*
data_102e	equ	0E900h			;*
data_103e	equ	0E91Bh			;*
data_104e	equ	0ED20h			;*
data_105e	equ	0EDA0h			;*
data_106e	equ	0FF1Ah			;*
data_107e	equ	0FF2Ch			;*
data_108e	equ	0FF2Fh			;*
data_109e	equ	0FF31h			;*
data_110e	equ	0FF33h			;*
data_111e	equ	0FF34h			;*
data_112e	equ	0FF35h			;*
data_113e	equ	0FF36h			;*
data_114e	equ	0FF37h			;*
data_115e	equ	0FF38h			;*
data_116e	equ	0FF39h			;*
data_117e	equ	0FF3Ah			;*
data_118e	equ	0FF3Dh			;*
data_119e	equ	0FF3Fh			;*
data_120e	equ	0FF40h			;*
data_121e	equ	0FF41h			;*
data_122e	equ	0FF42h			;*
data_123e	equ	0FF43h			;*
data_124e	equ	0FF44h			;*
data_125e	equ	0FF45h			;*
data_126e	equ	0FF46h			;*
data_127e	equ	0			;*
data_128e	equ	4FDh
data_129e	equ	0D85h
data_130e	equ	2000h
data_131e	equ	47CDh
data_132e	equ	6000h
data_133e	equ	0A058h
data_134e	equ	0A05Ah

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_04		proc	far

start:
		mov	dh,22h			; '"'
		add	[bx+si],al
		sub	al,30h			; '0'
		db	 62h, 39h, 15h, 3Fh,0D3h, 3Dh
		db	0ACh, 40h,0E4h, 44h,0D5h, 3Fh
		db	 7Ah, 32h,0A6h, 37h,0FEh, 40h
		db	 64h, 40h, 4Ch, 39h, 5Fh, 42h
		db	0FEh, 44h, 48h, 45h, 37h, 46h
		db	 5Ch, 40h, 0Fh, 49h, 44h, 49h
		db	0AEh, 4Ah, 6Ch, 4Eh, 31h, 4Fh
		db	 0Eh, 07h,0BFh, 16h, 50h, 33h
		db	0C0h,0B9h, 80h, 00h,0F3h,0ABh
data_9		db	0FEh
		db	 06h,0F7h, 4Fh,0C7h, 06h,0E4h
		db	 4Fh,0FDh, 04h, 8Bh, 36h, 31h
		db	0FFh, 83h,0EEh, 21h,0E8h,0F0h
		db	 14h, 33h,0DBh,0F6h, 04h, 80h
		db	 74h, 03h,0E8h,0CDh, 02h
loc_5:
		inc	si
		mov	cx,6

locloop_6:
		push	cx
		test	byte ptr [si],80h
		jz	loc_7			; Jump if zero
		call	physics_func_4
loc_7:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_8			; Jump if zero
		call	physics_func_4
loc_8:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_9			; Jump if zero
		call	physics_func_4
loc_9:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_10			; Jump if zero
		call	physics_func_4
loc_10:
		inc	si
		inc	bx
		pop	cx
		loop	locloop_6		; Loop if cx > 0

		test	byte ptr [si],80h
		jz	loc_11			; Jump if zero
		call	physics_func_4
loc_11:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_12			; Jump if zero
		call	physics_func_4
loc_12:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_13			; Jump if zero
		call	physics_func_4
loc_13:
		inc	si
		test	byte ptr [si],80h
		jz	loc_14			; Jump if zero
		call	physics_func_5
loc_14:
		mov	si,ds:data_109e
		mov	di,data_102e
		mov	byte ptr ds:data_75e,12h
loc_15:
		call	physics_func_23
		xor	bx,bx			; Zero register
		add	si,3
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jns	loc_16			; Jump if not sign
		call	physics_func_6
loc_16:
		mov	cx,6

locloop_17:
		push	cx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_18			; Jump if zero
		call	physics_func_1
loc_18:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_19			; Jump if zero
		call	physics_func_1
loc_19:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_20			; Jump if zero
		call	physics_func_1
loc_20:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_21			; Jump if zero
		call	physics_func_1
loc_21:
		inc	bx
		pop	cx
		loop	locloop_17		; Loop if cx > 0

		cmpsb				; Cmp [si] to es:[di]
		jz	loc_22			; Jump if zero
		call	physics_func_1
loc_22:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_23			; Jump if zero
		call	physics_func_1
loc_23:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_24			; Jump if zero
		call	physics_func_1
loc_24:
		inc	bx
		lodsb				; String [si] to al
		inc	di
		or	al,al			; Zero ?
		jns	loc_25			; Jump if not sign
		jmp	loc_69
loc_25:
		cmp	al,es:[di-1]
		je	loc_26			; Jump if equal
		call	physics_func_1
loc_26:
		add	si,4
		call	physics_func_41
		add	word ptr ds:data_72e,40B4h
		cmp	word ptr ds:data_72e,6000h
		jb	loc_27			; Jump if below
		add	word ptr ds:data_72e,0A05Ah
loc_27:
		dec	byte ptr ds:data_75e
		jnz	loc_15			; Jump if not zero
		retn

zr2_04		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_1		proc	near
		mov	al,[si-1]
		or	al,al			; Zero ?
		jns	loc_28			; Jump if not sign
		jmp	loc_66
loc_28:
		cmp	byte ptr es:[di-1],0FCh
		jne	loc_29			; Jump if not equal
		mov	byte ptr es:[di-1],0FFh
		jmp	short loc_30
loc_29:
		inc	byte ptr es:[di-1]
		mov	byte ptr es:[di-1],0FEh
		jz	loc_30			; Jump if zero
		mov	es:[di-1],al
		mov	dx,bx
		add	dx,dx
		add	dx,ds:data_72e
		call	physics_multiply
loc_30:
		mov	al,ds:data_100e
		sub	al,5
		jnc	loc_31			; Jump if carry=0
		retn
loc_31:
		cmp	al,4
		jb	loc_32			; Jump if below
		retn
loc_32:
		push	bx
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:data_60e[bx]	;*
		pop	bx
		retn
physics_func_1		endp

			                        ;* No entry point to code
		xchg	[bx+di],dh
		cmpsb				; Cmp [si] to es:[di]
;*		xor	sp,bx
		db	 31h,0DCh		;  Fixup - byte match
		xor	[bp+si+32h],bx
		mov	al,[si-1]
		sub	al,1Bh
		cmp	al,2
		jb	loc_33			; Jump if below
		retn
loc_33:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_84e,1
		jnz	loc_34			; Jump if not zero
		retn
loc_34:
		inc	al
		and	al,1
		add	al,1Bh
		mov	[si-1],al
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,1Dh
		cmp	al,6
		jb	loc_35			; Jump if below
		retn
loc_35:
		mov	byte ptr [di-1],0FEh
		cmp	al,4
		jae	loc_37			; Jump if above or =
		or	al,al			; Zero ?
		jnz	loc_36			; Jump if not zero
		push	ax
		call	word ptr cs:[11Ah]
		and	al,3
		pop	ax
		jz	loc_36			; Jump if zero
		retn
loc_36:
		inc	al
		and	al,3
		add	al,1Dh
		mov	[si-1],al
		retn
loc_37:
		inc	al
		and	al,1
		add	al,21h			; '!'
		mov	[si-1],al
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,2Ch			; ','
		cmp	al,2
		jae	loc_39			; Jump if above or =
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_84e,1
		jnz	loc_38			; Jump if not zero
		retn
loc_38:
		inc	al
		and	al,1
		add	al,2Ch			; ','
		mov	[si-1],al
		retn
loc_39:
		mov	al,[si-1]
		cmp	al,3Eh			; '>'
		jb	loc_40			; Jump if below
		retn
loc_40:
		mov	bl,33h			; '3'
		cmp	al,0Eh
		je	loc_42			; Jump if equal
		mov	bl,36h			; '6'
		cmp	al,0Dh
		je	loc_42			; Jump if equal
		mov	bl,39h			; '9'
		cmp	al,0Fh
		je	loc_42			; Jump if equal
		mov	bl,3Ch			; '<'
		cmp	al,0Ch
		je	loc_42			; Jump if equal
		mov	bl,3Dh			; '='
		cmp	al,10h
		je	loc_42			; Jump if equal
		sub	al,33h			; '3'
		jnc	loc_41			; Jump if carry=0
		retn
loc_41:
		mov	bl,0Eh
		cmp	al,2
		je	loc_42			; Jump if equal
		mov	bl,0Dh
		cmp	al,5
		je	loc_42			; Jump if equal
		mov	bl,0Fh
		cmp	al,8
		je	loc_42			; Jump if equal
		mov	bl,0Ch
		cmp	al,9
		je	loc_42			; Jump if equal
		mov	bl,10h
		cmp	al,0Ah
		je	loc_42			; Jump if equal
		inc	al
		add	al,33h			; '3'
		mov	bl,al
loc_42:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_84e,1
		jnz	loc_43			; Jump if not zero
		retn
loc_43:
		mov	[si-1],bl
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,25h			; '%'
		cmp	al,4
		jb	loc_44			; Jump if below
		retn
loc_44:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_84e,1
		jnz	loc_45			; Jump if not zero
		retn
loc_45:
		inc	al
		and	al,3
		add	al,25h			; '%'
		mov	[si-1],al
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_multiply		proc	near
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,dx
		or	al,al			; Zero ?
		jz	loc_52			; Jump if zero
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:data_90e[bx],0FFFFh
		jnz	loc_48			; Jump if not zero
		dec	al
		mov	ds:data_90e[bx],di
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_107e
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

locloop_46:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,data_132e
		jb	loc_47			; Jump if below
		mov	ax,[si-2]
		stosw				; Store ax to es:[di]
		add	di,data_133e
loc_47:
		loop	locloop_46		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_48:
		mov	si,ds:data_90e[bx]
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	cx,8

locloop_49:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,data_132e
		jb	loc_50			; Jump if below
		mov	ax,[si-2]
		stosw				; Store ax to es:[di]
		add	di,data_133e
loc_50:
		add	si,1FFEh
		cmp	si,6000h
		jb	loc_51			; Jump if below
		add	si,0A05Ah
loc_51:
		loop	locloop_49		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_52:
		mov	ax,0B000h
		mov	es,ax
		xor	ax,ax			; Zero register
		mov	cx,8

locloop_53:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,data_132e
		jb	loc_54			; Jump if below
		stosw				; Store ax to es:[di]
		add	di,0A058h
loc_54:
		loop	locloop_53		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
physics_multiply		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_3		proc	near
		cmp	byte ptr ds:data_102e,0FFh
		jne	loc_55			; Jump if not equal
		retn
loc_55:
		cmp	byte ptr ds:data_102e,0FCh
		jne	loc_56			; Jump if not equal
		retn
loc_56:
		push	si
		push	bx
		mov	byte ptr ds:data_102e,0FFh
		mov	cl,[si]
		add	si,25h
		call	physics_func_41
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_57			; Jump if not sign
		call	physics_get_value
loc_57:
		push	ax
		mov	al,cl
		call	physics_multiply_3
		add	si,3
		pop	ax
		mov	ah,[si]
		mov	dx,4FDh
		call	physics_func_9
		pop	bx
		pop	si
		retn
physics_func_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_4		proc	near
		push	si
		push	bx
		mov	cx,bx
		mov	di,bx
		add	di,data_102e
		mov	bx,data_87e
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	byte ptr [bx+1],0
		mov	byte ptr [di+1],0FFh
		mov	dx,cx
		add	dx,dx
		add	dx,4FDh
		mov	cl,[si]
		add	si,24h
		call	physics_func_41
		mov	bx,data_89e
		lodsw				; String [si] to ax
		mov	[bx],ax
		mov	al,cl
		call	physics_multiply_3
		inc	si
		inc	si
		mov	di,data_89e
		mov	bp,data_87e
		call	physics_func_7
		pop	bx
		pop	si
		retn
physics_func_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_5		proc	near
		cmp	byte ptr ds:data_103e,0FFh
		jne	loc_58			; Jump if not equal
		retn
loc_58:
		cmp	byte ptr ds:data_103e,0FCh
		jne	loc_59			; Jump if not equal
		retn
loc_59:
		mov	byte ptr ds:data_103e,0FFh
		mov	cl,[si]
		add	si,24h
		call	physics_func_41
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_60			; Jump if not sign
		call	physics_get_value
loc_60:
		push	ax
		mov	al,cl
		call	physics_multiply_3
		add	si,2
		pop	ax
		mov	ah,[si]
		mov	dx,533h
		jmp	loc_77

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_6:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_87e
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	al,0FFh
		xchg	[di+1Ch],al
		mov	[bx+1],al
		mov	cl,[si-1]
		mov	dl,[si]
		add	si,24h
		call	physics_func_41
		mov	dh,[si]
		mov	al,cl
		call	physics_multiply_3
		inc	si
		mov	bx,dx
		pop	dx
		add	dx,dx
		add	dx,ds:data_72e
		cmp	byte ptr ds:data_87e,0FFh
		je	loc_62			; Jump if equal
		cmp	byte ptr ds:data_87e,0FCh
		je	loc_62			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_61			; Jump if not sign
		call	physics_get_value
loc_61:
		call	physics_func_9
		pop	dx
		pop	si
		pop	bx
loc_62:
		add	dx,40B4h
		cmp	dx,6000h
		jb	loc_63			; Jump if below
		add	dx,0A05Ah
loc_63:
		cmp	byte ptr ds:data_75e,1
		je	loc_65			; Jump if equal
		cmp	byte ptr ds:data_88e,0FFh
		je	loc_65			; Jump if equal
		cmp	byte ptr ds:data_88e,0FCh
		je	loc_65			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_64			; Jump if not sign
		call	physics_get_value
loc_64:
		call	physics_func_9
loc_65:
		pop	bx
		pop	di
		pop	si
		retn
loc_66:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_87e
		mov	ax,0FFFEh
		xchg	[di-1],ax
		mov	[bx],ax
		mov	ax,0FFFFh
		xchg	[di+1Bh],ax
		mov	[bx+2],ax
		mov	cl,[si-1]
		mov	bx,data_89e
		mov	al,[si]
		mov	[bx+1],al
		add	si,24h
		call	physics_func_41
		mov	ax,[si-1]
		mov	[bx+2],ax
		pop	dx
		mov	ds:data_76e,dl
		mov	al,ds:data_75e
		neg	al
		add	al,12h
		mov	ds:data_77e,al
		add	dx,dx
		add	dx,ds:data_72e
		mov	al,cl
		call	physics_multiply_3
		mov	di,data_89e
		mov	[di],al
		mov	bp,data_87e
		call	physics_func_7
		cmp	byte ptr ds:data_75e,1
		je	loc_68			; Jump if equal
		add	dx,40B0h
		cmp	dx,6000h
		jb	loc_67			; Jump if below
		add	dx,0A05Ah
loc_67:
		call	physics_func_7
		test	byte ptr ds:data_111e,0FFh
		jz	loc_68			; Jump if zero
		test	byte ptr ds:data_108e,0FFh
		jz	loc_68			; Jump if zero
		call	physics_check_state
loc_68:
		pop	bx
		pop	di
		pop	si
		retn
loc_69:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_87e
		mov	al,0FEh
		xchg	[di-1],al
		mov	[bx],al
		mov	al,0FFh
		xchg	[di+1Bh],al
		mov	[bx+1],al
		mov	cl,[si-1]
		add	si,24h
		call	physics_func_41
		mov	dl,[si-1]
		mov	al,cl
		call	physics_multiply_3
		mov	bl,al
		mov	bh,dl
		pop	dx
		add	dx,dx
		add	dx,ds:data_72e
		cmp	byte ptr ds:data_87e,0FFh
		je	loc_71			; Jump if equal
		cmp	byte ptr ds:data_87e,0FCh
		je	loc_71			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_70			; Jump if not sign
		call	physics_get_value
loc_70:
		call	physics_func_9
		pop	dx
		pop	si
		pop	bx
loc_71:
		add	dx,40B4h
		cmp	dx,6000h
		jb	loc_72			; Jump if below
		add	dx,0A05Ah
loc_72:
		cmp	byte ptr ds:data_75e,1
		je	loc_74			; Jump if equal
		cmp	byte ptr ds:data_88e,0FFh
		je	loc_74			; Jump if equal
		cmp	byte ptr ds:data_88e,0FCh
		je	loc_74			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_73			; Jump if not sign
		call	physics_get_value
loc_73:
		call	physics_func_9
loc_74:
		pop	bx
		pop	di
		pop	si
		jmp	loc_26

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_7:
		call	physics_func_8

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_8:
		cmp	byte ptr ds:[bp],0FFh
		je	loc_76			; Jump if equal
		cmp	byte ptr ds:[bp],0FCh
		je	loc_76			; Jump if equal
		mov	ah,[si]
		mov	al,[di]
		or	al,al			; Zero ?
		jns	loc_75			; Jump if not sign
		call	physics_get_value
loc_75:
		push	bp
		push	si
		push	di
		push	dx
		call	physics_func_9
		pop	dx
		pop	di
		pop	si
		pop	bp
loc_76:
		inc	si
		inc	di
		inc	bp
		inc	dx
		inc	dx
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_9:
loc_77:
		push	es
		push	ds
		mov	bl,ds:data_78e
		or	al,al			; Zero ?
		jz	loc_78			; Jump if zero
		js	loc_78			; Jump if sign=1
		or	bl,80h
loc_78:
		mov	cl,al
		mov	al,ah
		mov	ch,10h
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		mov	bp,ax
		add	bp,0A000h
		mov	ds,cs:data_107e
		mov	di,dx
		push	cs
		pop	es
		mov	ch,bl
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:data_69e[bx]
		mov	cs:data_70e,ax
		mov	al,cl
		or	ch,ch			; Zero ?
		js	loc_79			; Jump if sign=1
		push	di
		mov	di,52A6h
		call	physics_process_loop
		pop	di
		mov	si,data_93e
		push	cs
		pop	ds
		mov	ax,0B000h
		mov	es,ax
		call	physics_scan_loop
		pop	ds
		pop	es
		retn
loc_79:
		push	di
		mov	di,data_93e
		call	physics_multiply_2
		pop	di
		mov	si,data_93e
		push	cs
		pop	ds
		mov	ax,0B000h
		mov	es,ax
		call	physics_scan_loop
		pop	ds
		pop	es
		retn
physics_func_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_multiply_2		proc	near
		push	bp
		push	si
		push	di
		dec	cl
		mov	al,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	copy_buffer
		pop	di
		pop	si
		pop	bp
		jmp	short $+2		; delay for I/O

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_11:
		mov	cx,8

locloop_80:
		mov	ax,ds:[bp]
		and	es:[di],ax
		lodsw				; String [si] to ax
		call	extract_bits
		or	es:[di],ax
		inc	bp
		inc	bp
		inc	di
		inc	di
		loop	locloop_80		; Loop if cx > 0

		retn
physics_multiply_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_process_loop		proc	near
		mov	cx,8

locloop_81:
		lodsw				; String [si] to ax
		call	extract_bits
		stosw				; Store ax to es:[di]
		loop	locloop_81		; Loop if cx > 0

		retn
physics_process_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

extract_bits		proc	near
		mov	bx,ax
		shr	bh,1			; Shift w/zeros fill
		shr	bh,1			; Shift w/zeros fill
		shr	bh,1			; Shift w/zeros fill
		shr	bh,1			; Shift w/zeros fill
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,cs:data_70e
		mov	dh,cs:[bx]
		add	dh,dh
		add	dh,dh
		add	dh,dh
		add	dh,dh
		mov	bx,ax
		and	bh,0Fh
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,cs:data_70e
		or	dh,cs:[bx]
		mov	bx,ax
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		add	bx,cs:data_70e
		mov	dl,cs:[bx]
		add	dl,dl
		add	dl,dl
		add	dl,dl
		add	dl,dl
		mov	bx,ax
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	bx,cs:data_70e
		or	dl,cs:[bx]
		mov	ax,dx
		retn
extract_bits		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_scan_loop		proc	near
		mov	cx,8

locloop_82:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,data_132e
		jb	loc_83			; Jump if below
		mov	ax,[si-2]
		stosw				; Store ax to es:[di]
		add	di,0A058h
loc_83:
		loop	locloop_82		; Loop if cx > 0

		retn
physics_scan_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_buffer		proc	near
		mov	cx,8
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		retn
copy_buffer		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

fill_buffer		proc	near
		xor	ax,ax			; Zero register
		mov	cx,8
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
fill_buffer		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_get_value		proc	near
		and	al,7Fh
		mov	bx,data_104e
		xlat				; al=[al+[bx]] table
		retn
physics_get_value		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_multiply_3		proc	near
		and	al,7Fh
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	cl,ds:data_104e[bx]
		mov	ch,10h
		mul	ch			; ax = reg * al
		add	ax,ds:data_99e
		mov	bp,ax
		mov	al,ds:[bp+6]
		and	al,0Fh
		mov	ch,5
		mul	ch			; ax = reg * al
		mov	si,0A070h
		test	byte ptr ds:[bp+5],80h
		jnz	loc_84			; Jump if not zero
		mov	si,data_96e
loc_84:
		mov	bl,ds:[bp+4]
		and	bl,1Fh
		add	bl,bl
		xor	bh,bh			; Zero register
		add	ax,[bx+si]
		mov	si,ax
		lodsb				; String [si] to al
		test	byte ptr ds:data_111e,0FFh
		jnz	loc_85			; Jump if not zero
		test	byte ptr ds:[bp+5],20h	; ' '
		jz	loc_85			; Jump if zero
		add	al,3
loc_85:
		mov	ds:data_78e,al
		mov	al,cl
		retn
physics_multiply_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_check_state		proc	near
		cmp	byte ptr ds:data_77e,10h
		jb	loc_86			; Jump if below
		retn
loc_86:
		push	cs
		pop	es
		call	word ptr cs:[11Ah]
		and	al,0Fh
		cmp	al,0Eh
		jae	loc_87			; Jump if above or =
		retn
loc_87:
		mov	di,data_105e
		xor	cl,cl			; Zero register
loc_88:
		cmp	byte ptr [di],0FFh
		je	loc_89			; Jump if equal
		add	di,4
		inc	cl
		jmp	short loc_88
loc_89:
		cmp	cl,20h			; ' '
		jb	loc_90			; Jump if below
		retn
loc_90:
		call	word ptr cs:[11Ah]
		and	al,3
		cmp	al,3
		je	loc_90			; Jump if equal
		dec	al
		add	al,ds:data_76e
		cmp	al,0FFh
		jne	loc_91			; Jump if not equal
		mov	al,4
loc_91:
		cmp	al,1Bh
		jb	loc_92			; Jump if below
		mov	al,1Ah
loc_92:
		stosb				; Store al to es:[di]
loc_93:
		call	word ptr cs:[11Ah]
		and	al,3
		cmp	al,3
		je	loc_93			; Jump if equal
		dec	al
		add	al,ds:data_77e
		cmp	al,0FFh
		jne	loc_94			; Jump if not equal
		xor	al,al			; Zero register
loc_94:
		stosb				; Store al to es:[di]
		mov	al,3
		stosb				; Store al to es:[di]
		call	word ptr cs:[11Ah]
		and	al,3
		mov	bx,data_61e
		xlat				; al=[al+[bx]] table
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn
physics_check_state		endp

			                        ;* No entry point to code
		push	bp
		stosb				; Store al to es:[di]
		jmp	dword ptr ss:[70Eh][bp+si]	;*
		db	0BFh,0A0h,0EDh, 8Bh,0F7h
loc_95:
		cmp	byte ptr [si],0FFh
		jne	loc_96			; Jump if not equal
		mov	byte ptr [di],0FFh
		retn
loc_96:
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
		mov	al,[si]
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,4FDh
		xor	cx,cx			; Zero register
		mov	cl,[si+1]
		jcxz	loc_99			; Jump if cx=0

locloop_97:
		add	ax,40B4h
		cmp	ax,6000h
		jb	loc_98			; Jump if below
		add	ax,0A05Ah
loc_98:
		loop	locloop_97		; Loop if cx > 0

loc_99:
		push	si
		push	di
		push	es
		push	ax
		mov	bl,[si+2]
		and	bl,3
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:data_62e[bx]
		pop	di
		mov	ax,0B000h
		mov	es,ax
		mov	cx,10h

locloop_100:
		lodsw				; String [si] to ax
		mov	bx,ax
		lodsw				; String [si] to ax
		or	es:[di],bx
		or	es:[di+2],ax
		add	di,2000h
		cmp	di,data_132e
		jb	loc_101			; Jump if below
		or	es:[di],bx
		or	es:[di+2],ax
		add	di,data_97e
loc_101:
		loop	locloop_100		; Loop if cx > 0

		pop	es
		pop	di
		pop	si
		dec	byte ptr [si+2]
		cmp	byte ptr [si+2],0FFh
		je	loc_102			; Jump if equal
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	si,4
loc_102:
		add	si,4
		jmp	loc_95
			                        ;* No entry point to code
		or	al,39h			; '9'
		int	3			; Debug breakpoint
		cmp	ds:data_66e[si],cl
		cmp	[bx+si],al
		db	16 dup (0)
		db	 0Bh,0D0h, 00h, 00h, 5Fh,0FAh
		db	 00h, 00h, 7Fh,0FEh, 00h, 00h
		db	0FFh,0FFh, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 7Fh,0FEh, 00h, 00h
		db	 5Fh,0FAh, 00h, 00h, 0Bh,0D0h
		db	26 dup (0)
		db	 2Fh,0F4h, 00h, 00h,0FFh,0FFh
		db	 00h, 03h,0FFh,0FFh,0C0h, 07h
		db	0FFh,0FFh,0E0h, 0Fh,0FAh, 5Fh
		db	0F0h, 0Fh,0F0h, 0Fh,0F0h, 0Fh
		db	0F0h, 0Fh,0F0h, 0Fh,0FAh, 5Fh
		db	0F0h, 07h,0FFh,0FFh,0E0h, 03h
		db	0FFh,0FFh,0C0h, 00h,0FFh,0FFh
		db	 00h, 00h, 2Fh,0F4h
		db	10 dup (0)
		db	 2Fh,0F4h, 00h, 01h, 7Fh,0FEh
		db	 80h, 07h,0FFh,0FFh,0E0h, 0Fh
		db	0FFh,0FFh,0F0h, 3Fh,0F4h, 2Fh
		db	0FCh, 7Fh,0A0h, 05h,0FEh, 7Fh
		db	 80h, 01h,0FEh,0FFh, 00h, 00h
		db	0FFh,0FFh, 00h, 00h,0FFh, 7Fh
		db	 80h, 01h,0FEh, 7Fh,0A0h, 05h
		db	0FEh, 3Fh,0F4h, 2Fh,0FCh, 0Fh
		db	0FFh,0FFh,0F0h, 07h,0FFh,0FFh
		db	0E0h, 01h, 7Fh,0FEh, 80h, 00h
		db	 2Fh,0F4h, 00h, 00h, 2Fh,0F4h
		db	 00h, 01h
loc_103:
		jg	loc_103			; Jump if >
		add	byte ptr [bx],0D0h
		or	sp,ax
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bx+si],al
                           lock	cmp	al,0
		add	[si],bh
		js	$+2			; delay for I/O
		add	byte ptr ds:[70h],bl
		add	byte ptr ds:[0F0h],cl
		add	[bx],cl
                           lock	add	[bx+si],al
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		jo	$+2			; delay for I/O
		add	byte ptr ds:[78h],cl
		add	data_9,bl
		add	[si],bh
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bx+si],al
                           lock	pop	es
		ror	byte ptr [bp+di],1	; Rotate
;*		loopnz	locloop_105		;*Loop if zf=0, cx>0

		db	0E0h, 01h		;  Fixup - byte match
loc_104:
		jg	loc_104			; Jump if >
		add	byte ptr [bx+si],2Fh	; '/'
		hlt				; Halt processor
		add	ds:data_89e[bx],bh
		push	cs
		pop	es
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosb				; Store al to es:[di]
		mov	di,data_86e
		mov	cx,8
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		jmp	short loc_109
			                        ;* No entry point to code
		call	physics_multiply_5
		mov	di,data_86e
		mov	dl,ds:data_112e
		dec	dl
		mov	cx,4

locloop_106:
		push	cx
		and	dl,3Fh			; '?'
		mov	al,24h			; '$'
		mul	dl			; ax = reg * al
		mov	bx,ax
		add	bx,data_101e
		mov	al,byte ptr ds:[83h]
		add	al,3
		xor	ah,ah			; Zero register
		add	bx,ax
		mov	cx,4

locloop_107:
		mov	al,[bx]
		or	al,al			; Zero ?
		js	loc_108			; Jump if sign=1
		xor	al,al			; Zero register
loc_108:
		mov	[di],al
		inc	bx
		inc	di
		loop	locloop_107		; Loop if cx > 0

		inc	dl
		pop	cx
		loop	locloop_106		; Loop if cx > 0

loc_109:
		mov	bl,byte ptr ds:[84h]
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,0Eh
		mov	bh,byte ptr ds:[83h]
		add	bh,6
		add	bh,bh
		call	math_calc
		mov	ds:data_73e,ax
		mov	byte ptr ds:data_76e,0
		mov	si,500Dh
		mov	di,data_86e
		mov	cx,3

locloop_110:
		push	cx
		mov	cx,3

locloop_111:
		push	cx
		mov	ax,3A2Fh
		push	ax
		mov	al,[di]
		or	al,[di+1]
		or	al,[di+4]
		or	al,[di+5]
		jnz	loc_112			; Jump if not zero
		jmp	loc_149
loc_112:
		test	byte ptr [di],0FFh
		jz	loc_113			; Jump if zero
		mov	al,[di]
		push	si
		call	physics_multiply_3
		inc	si
		inc	si
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_151
loc_113:
		test	byte ptr [di+1],0FFh
		jz	loc_114			; Jump if zero
		mov	al,[di+1]
		push	si
		call	physics_multiply_3
		inc	si
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_151
loc_114:
		test	byte ptr [di+4],0FFh
		jz	loc_115			; Jump if zero
		mov	al,[di+4]
		push	si
		call	physics_multiply_3
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_151
loc_115:
		mov	al,[di+5]
		push	si
		call	physics_multiply_3
		mov	cl,[si]
		pop	si
		mov	[si],al
		mov	al,cl
		jmp	loc_151
			                        ;* No entry point to code
		inc	byte ptr ds:data_76e
		inc	di
		inc	si
		pop	cx
		loop	locloop_111		; Loop if cx > 0

		pop	cx
		inc	di
		loop	locloop_110		; Loop if cx > 0

		mov	bl,ds:data_113e
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:data_69e[bx]
		mov	cs:data_70e,ax
		mov	es,cs:data_107e
		mov	al,byte ptr ds:[0E8h]
		or	al,ds:data_116e
		or	al,ds:data_117e
		jz	loc_116			; Jump if zero
		jmp	loc_126
loc_116:
		mov	cl,0FFh
		mov	si,6117h
		test	byte ptr ds:[0C2h],1
		jz	loc_117			; Jump if zero
		xor	cl,cl			; Zero register
		mov	si,61B9h
loc_117:
		test	byte ptr ds:data_120e,0FFh
		jz	loc_121			; Jump if zero
		inc	cl
		jnz	loc_118			; Jump if not zero
		mov	al,ds:data_119e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	physics_func_21
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,62C7h
		jmp	short loc_124
loc_118:
		mov	al,ds:data_119e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:data_121e
		dec	dl
		jnz	loc_119			; Jump if not zero
		add	ax,24h
		jmp	short loc_120
loc_119:
		dec	dl
		jnz	loc_120			; Jump if not zero
		mov	ax,63h
loc_120:
		add	si,ax
		jmp	short loc_124
loc_121:
		call	physics_func_21
		or	al,al			; Zero ?
		jz	loc_123			; Jump if zero
		dec	al
		mov	cl,al
		test	byte ptr ds:[0C2h],1
		jnz	loc_123			; Jump if not zero
		mov	ax,6Ch
		mov	dl,ds:data_115e
		and	dl,9
		xor	dh,dh			; Zero register
		add	ax,dx
		or	cl,cl			; Zero ?
		jz	loc_122			; Jump if zero
		add	ax,1Bh
loc_122:
		add	si,ax
		jmp	short loc_124
loc_123:
		test	byte ptr ds:data_115e,0FFh
		jnz	loc_126			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		cmp	al,80h
		je	loc_126			; Jump if equal
		add	al,2
		and	al,3
		test	al,1
		jnz	loc_126			; Jump if not zero
		mov	cl,9
		mul	cl			; ax = reg * al
		add	si,ax
		jmp	short loc_125
loc_124:
		test	byte ptr ds:data_115e,0FFh
		jz	loc_125			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:data_76e,3
		call	physics_multiply_4
		jmp	short loc_126
loc_125:
		mov	cx,9
		mov	byte ptr ds:data_76e,0
		call	physics_multiply_4
loc_126:
		mov	si,610Eh
		test	byte ptr ds:data_117e,0FFh
		jnz	loc_131			; Jump if not zero
		mov	si,60EAh
		test	byte ptr ds:data_116e,0FFh
		jnz	loc_129			; Jump if not zero
		mov	si,6075h
		test	byte ptr ds:[0C2h],1
		jnz	loc_127			; Jump if not zero
		mov	si,data_2e
loc_127:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_128			; Jump if zero
		add	si,5Ah
		jmp	short loc_129
loc_128:
		mov	ax,2Dh
		test	byte ptr ds:data_115e,0FFh
		jnz	loc_130			; Jump if not zero
		mov	ax,3Fh
		test	byte ptr ds:data_118e,80h
		jnz	loc_130			; Jump if not zero
		mov	cl,ds:data_122e
		mov	ax,48h
		dec	cl
		jz	loc_130			; Jump if zero
		mov	ax,51h
		dec	cl
		jz	loc_130			; Jump if zero
		mov	ax,36h
		cmp	byte ptr ds:data_118e,7Fh
		je	loc_130			; Jump if equal
		mov	ax,24h
		cmp	byte ptr ds:[0E7h],80h
		je	loc_130			; Jump if equal
loc_129:
		mov	al,byte ptr ds:[0E7h]
		and	al,3
		mov	cl,9
		mul	cl			; ax = reg * al
loc_130:
		add	si,ax
loc_131:
		mov	cx,9
		mov	byte ptr ds:data_76e,0
		call	physics_multiply_4
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_132			; Jump if zero
		retn
loc_132:
		mov	cl,0FFh
		mov	si,61B9h
		test	byte ptr ds:[0C2h],1
		jnz	loc_133			; Jump if not zero
		xor	cl,cl			; Zero register
		mov	si,6117h
loc_133:
		mov	al,ds:data_116e
		or	al,ds:data_117e
		jz	loc_135			; Jump if zero
		call	physics_func_21
		or	al,al			; Zero ?
		jnz	loc_134			; Jump if not zero
		retn
loc_134:
		dec	al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,1Bh
		add	al,7Eh			; '~'
		xor	ah,ah			; Zero register
		jmp	loc_142
loc_135:
		test	byte ptr ds:data_120e,0FFh
		jz	loc_139			; Jump if zero
		inc	cl
		jnz	loc_136			; Jump if not zero
		mov	al,ds:data_119e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	physics_func_21
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,625Bh
		jmp	short loc_143
loc_136:
		mov	al,ds:data_119e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:data_121e
		dec	dl
		jnz	loc_137			; Jump if not zero
		add	ax,24h
		jmp	short loc_138
loc_137:
		dec	dl
		jnz	loc_138			; Jump if not zero
		mov	ax,63h
loc_138:
		add	si,ax
		jmp	short loc_143
loc_139:
		test	byte ptr ds:[0C2h],1
		jz	loc_141			; Jump if zero
		call	physics_func_21
		or	al,al			; Zero ?
		jz	loc_141			; Jump if zero
		dec	al
		mov	cl,al
		mov	al,ds:data_115e
		and	al,9
		add	al,6Ch			; 'l'
		xor	ah,ah			; Zero register
		or	cl,cl			; Zero ?
		jz	loc_140			; Jump if zero
		add	ax,1Bh
loc_140:
		add	si,ax
		jmp	short loc_143
loc_141:
		mov	ax,1Bh
		test	byte ptr ds:data_115e,0FFh
		jnz	loc_142			; Jump if not zero
		mov	cl,byte ptr ds:[0E7h]
		cmp	cl,80h
		je	loc_142			; Jump if equal
		and	cl,3
		mov	al,9
		mul	cl			; ax = reg * al
loc_142:
		add	si,ax
loc_143:
		test	byte ptr ds:data_115e,0FFh
		jz	loc_144			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:data_76e,3
		jmp	short locloop_145
loc_144:
		mov	cx,9
		mov	byte ptr ds:data_76e,0
		jmp	short locloop_145

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_multiply_4		proc	near

locloop_145:
		push	cx
		mov	al,es:[si]
		or	al,al			; Zero ?
		jz	loc_146			; Jump if zero
		push	es
		push	ds
		push	si
		push	di
		mov	ch,10h
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,data_3e
		mov	bp,ax
		add	bp,data_8e
		mov	ds,cs:data_107e
		mov	di,dx
		push	cs
		pop	es
		mov	al,cs:data_76e
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,5216h
		mov	di,ax
		call	physics_func_11
		pop	di
		pop	si
		pop	ds
		pop	es
loc_146:
		inc	si
		inc	byte ptr ds:data_76e
		pop	cx
		loop	locloop_145		; Loop if cx > 0

		retn
physics_multiply_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_21		proc	near
		mov	al,byte ptr ds:[93h]
		or	al,al			; Zero ?
		jnz	loc_147			; Jump if not zero
		retn
loc_147:
		cmp	al,4
		mov	al,1
		jnc	loc_148			; Jump if carry=0
		retn
loc_148:
		mov	al,2
		retn
physics_func_21		endp

loc_149:
		mov	al,[si]
		push	ds
		push	si
		push	di
		push	ax
		mov	ds,cs:data_107e
		push	cs
		pop	es
		mov	al,cs:data_76e
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,5216h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_150			; Jump if zero
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	copy_buffer
		pop	di
		pop	si
		pop	ds
		retn
loc_150:
		call	fill_buffer
		pop	di
		pop	si
		pop	ds
		retn
loc_151:
		push	ds
		push	si
		push	di
		mov	cl,al
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_152			; Jump if not sign
		call	physics_get_value
loc_152:
		push	ax
		mov	bl,ds:data_78e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	dx,cs:data_69e[bx]
		mov	cs:data_70e,dx
		mov	al,cl
		mov	ch,10h
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		mov	bp,ax
		add	bp,0A000h
		mov	ds,cs:data_107e
		push	cs
		pop	es
		mov	al,cs:data_76e
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,5216h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_153			; Jump if zero
		mov	cl,al
		call	physics_multiply_2
		pop	di
		pop	si
		pop	ds
		retn
loc_153:
		call	physics_process_loop
		pop	di
		pop	si
		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_multiply_5		proc	near
		mov	cl,byte ptr ds:[84h]
		mov	al,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		add	ax,ds:data_109e
		mov	si,ax
		call	physics_func_41
		mov	di,data_89e
		push	cs
		pop	es
		mov	cx,3

locloop_154:
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	si,21h
		call	physics_func_41
		loop	locloop_154		; Loop if cx > 0

		retn
physics_multiply_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_23		proc	near
		mov	al,ds:data_75e
		neg	al
		add	al,12h
		mov	cl,al
		test	byte ptr ds:data_123e,0FFh
		jnz	loc_156			; Jump if not zero
		mov	al,byte ptr ds:[84h]
		sub	al,2
		cmp	al,cl
		jne	loc_ret_155		; Jump if not equal
		call	physics_func_28

loc_ret_155:
		retn
loc_156:
		mov	al,byte ptr ds:[84h]
		sub	al,5
		cmp	cl,al
		jae	loc_157			; Jump if above or =
		retn
loc_157:
		jnz	loc_158			; Jump if not zero
		call	physics_func_24
		jmp	loc_194
loc_158:
		add	al,0Ah
		cmp	al,cl
		je	loc_159			; Jump if equal
		retn
loc_159:
		jmp	loc_185
			                        ;* No entry point to code
		test	byte ptr ds:data_123e,0FFh
		jnz	loc_160			; Jump if not zero
		retn
loc_160:
		push	es
		push	si
		push	di
		push	bx
		mov	es,cs:data_107e
		inc	byte ptr ds:data_126e
		mov	al,ds:data_125e
		or	al,al			; Zero ?
		jz	loc_167			; Jump if zero
		dec	al
		jz	loc_165			; Jump if zero
		cmp	byte ptr ds:data_126e,5
		jb	loc_161			; Jump if below
		jmp	loc_177
loc_161:
		xor	cl,cl			; Zero register
		mov	si,0B16Eh
		mov	word ptr ds:data_81e,0FF01h
		mov	di,ds:data_73e
		add	di,40B2h
		cmp	di,6000h
		jb	loc_162			; Jump if below
		add	di,0A05Ah
loc_162:
		test	byte ptr ds:[0C2h],1
		jz	loc_163			; Jump if zero
		jmp	loc_175
loc_163:
		mov	si,0B0BEh
		mov	word ptr ds:data_81e,1
		mov	di,ds:data_73e
		add	di,40B4h
		cmp	di,6000h
		jb	loc_164			; Jump if below
		add	di,0A05Ah
loc_164:
		jmp	loc_175
loc_165:
		cmp	byte ptr ds:data_126e,5
		jb	loc_166			; Jump if below
		jmp	loc_177
loc_166:
		mov	bl,ds:data_126e
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B19Eh
		mov	si,0B12Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_169			; Jump if not zero
		mov	di,0B18Ah
		mov	si,0B07Eh
		jmp	short loc_169
loc_167:
		cmp	byte ptr ds:data_126e,7
		jb	loc_168			; Jump if below
		jmp	loc_177
loc_168:
		mov	bl,ds:data_126e
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B192h
		mov	si,0B0CEh
		test	byte ptr ds:[0C2h],1
		jnz	loc_169			; Jump if not zero
		mov	di,data_7e
		mov	si,0B01Eh
loc_169:
		mov	bx,es:[bx+di]
		mov	di,ds:data_73e
		mov	ds:data_81e,bx
		mov	al,bh
		cbw				; Convrt byte to word
		add	ax,ax
		add	di,ax
		or	bl,bl			; Zero ?
		js	loc_172			; Jump if sign=1
		or	bl,bl			; Zero ?
		jz	loc_175			; Jump if zero
loc_170:
		add	di,40B4h
		cmp	di,6000h
		jb	loc_171			; Jump if below
		add	di,0A05Ah
loc_171:
		dec	bl
		jnz	loc_170			; Jump if not zero
		jmp	short loc_175
loc_172:
		neg	bl
		jz	loc_175			; Jump if zero
loc_173:
		sub	di,40B4h
		jnc	loc_174			; Jump if carry=0
		add	di,5FA6h
loc_174:
		dec	bl
		jnz	loc_173			; Jump if not zero
loc_175:
		test	byte ptr ds:data_115e,0FFh
		jz	loc_176			; Jump if zero
		add	di,40B4h
		cmp	di,6000h
		jb	loc_176			; Jump if below
		add	di,0A05Ah
loc_176:
		mov	ds:data_79e,di
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	si,cx
		mov	ds:data_80e,si
		pop	bx
		pop	di
		pop	si
		pop	es
		jmp	loc_185
loc_177:
		mov	byte ptr ds:data_123e,0
		mov	byte ptr ds:data_126e,0
		pop	bx
		pop	di
		pop	si
		pop	es
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_24:
		test	byte ptr ds:data_124e,0FFh
		jnz	loc_178			; Jump if not zero
		retn
loc_178:
		push	es
		push	di
		push	si
		push	bx
		call	physics_func_26
		pop	bx
		pop	si
		pop	di
		pop	es
		mov	byte ptr ds:data_124e,0
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_25:
		push	ds
		push	cs
		pop	es
		mov	si,cs:data_79e
		mov	ax,0B000h
		mov	ds,ax
		mov	di,data_91e
		mov	cx,20h

locloop_179:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	si,1FF8h
		cmp	si,6000h
		jb	loc_180			; Jump if below
		add	si,0A05Ah
loc_180:
		loop	locloop_179		; Loop if cx > 0

		pop	ds
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_26:
		push	ds
		push	cs
		pop	ds
		mov	di,cs:data_79e
		mov	ax,0B000h
		mov	es,ax
		mov	si,data_91e
		mov	cx,20h

locloop_181:
		push	si
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	si
		add	di,1FF8h
		cmp	di,data_132e
		jb	loc_182			; Jump if below
		push	si
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	si
		add	di,0A052h
loc_182:
		add	si,8
		loop	locloop_181		; Loop if cx > 0

		pop	ds
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_27:
		mov	al,byte ptr ds:[84h]
		add	al,ds:data_81e
		and	al,3Fh			; '?'
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,byte ptr ds:data_81e+1
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		mov	si,ax
		add	si,ds:data_109e
		call	physics_func_41
		mov	cx,4

locloop_183:
		push	cx
		mov	cx,4

locloop_184:
		push	cx
		mov	bl,[si]
		inc	si
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	word ptr ds:data_90e[bx],0
		pop	cx
		loop	locloop_184		; Loop if cx > 0

		add	si,20h
		call	physics_func_41
		pop	cx
		loop	locloop_183		; Loop if cx > 0

		retn
loc_185:
		test	byte ptr ds:data_123e,0FFh
		jnz	loc_186			; Jump if not zero
		retn
loc_186:
		mov	byte ptr ds:data_124e,0FFh
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	physics_func_27
		call	physics_func_25
		mov	ds,cs:data_107e
		mov	ax,0B000h
		mov	es,ax
		mov	di,cs:data_79e
		mov	si,cs:data_80e
		mov	cx,4

locloop_187:
		push	cx
		push	di
		mov	cx,4

locloop_188:
		push	cx
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_190			; Jump if not equal
		add	di,40B4h
		cmp	di,6000h
		jb	loc_189			; Jump if below
		add	di,data_134e
loc_189:
		jmp	short loc_193
loc_190:
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,ds:data_6e
		mov	cx,8

locloop_191:
		push	cx
		lodsw				; String [si] to ax
		or	es:[di],ax
		add	di,2000h
		cmp	di,data_132e
		jb	loc_192			; Jump if below
		or	es:[di],ax
		add	di,0A05Ah
loc_192:
		pop	cx
		loop	locloop_191		; Loop if cx > 0

		pop	si
loc_193:
		pop	cx
		loop	locloop_188		; Loop if cx > 0

		pop	di
		inc	di
		inc	di
		pop	cx
		loop	locloop_187		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
			                        ;* No entry point to code
		call	math_calc
		mov	ds:data_73e,ax
		jmp	short loc_196

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_28:
loc_194:
		test	byte ptr ds:data_114e,0FFh
		jz	loc_195			; Jump if zero
		retn
loc_195:
		mov	byte ptr ds:data_114e,0FFh
loc_196:
		push	es
		push	ds
		push	si
		push	di
		push	bx
		mov	ax,0B000h
		mov	es,ax
		mov	si,data_92e
		mov	di,cs:data_73e
		mov	cx,3

locloop_197:
		push	cx
		mov	cx,3

locloop_198:
		push	cx
		push	di
		call	physics_scan_loop
		pop	di
		inc	di
		inc	di
		pop	cx
		loop	locloop_198		; Loop if cx > 0

		add	di,40AEh
		cmp	di,6000h
		jb	loc_199			; Jump if below
		add	di,0A05Ah
loc_199:
		pop	cx
		loop	locloop_197		; Loop if cx > 0

		pop	bx
		pop	di
		pop	si
		pop	ds
		pop	es
		retn
physics_func_23		endp

			                        ;* No entry point to code
		push	ds
		push	si
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_107e
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

locloop_200:
		push	cx
		lodsw				; String [si] to ax
		mov	bx,ax
		mov	dx,3
		mov	cx,8

locloop_201:
		test	bx,dx
		jz	loc_202			; Jump if zero
		or	bx,dx
loc_202:
		add	dx,dx
		add	dx,dx
		loop	locloop_201		; Loop if cx > 0

		not	bx
		and	es:[di],bx
		or	es:[di],ax
		add	di,2000h
		cmp	di,data_132e
		jb	loc_203			; Jump if below
		and	es:[di],bx
		or	es:[di],ax
		add	di,0A05Ah
loc_203:
		pop	cx
		loop	locloop_200		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_124e,0
		mov	ax,0B000h
		mov	es,ax
		mov	byte ptr ds:data_84e,8
loc_204:
		mov	word ptr ds:data_72e,0C0Eh
		mov	byte ptr ds:data_106e,0
		mov	si,ds:data_109e
		mov	di,data_102e
		mov	cx,12h

locloop_205:
		push	cx
		add	si,4
		xor	bx,bx			; Zero register
		mov	cx,1Ch

locloop_206:
		push	cx
		lodsb				; String [si] to al
		call	physics_multiply_6
		inc	di
		inc	bl
		pop	cx
		loop	locloop_206		; Loop if cx > 0

		add	si,4
		call	physics_func_41
		add	word ptr ds:data_72e,8
		pop	cx
		loop	locloop_205		; Loop if cx > 0

loc_207:
		cmp	byte ptr ds:data_106e,10h
		jb	loc_207			; Jump if below
		dec	byte ptr ds:data_84e
		jnz	loc_204			; Jump if not zero
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_multiply_6		proc	near
		cmp	byte ptr [di],0FFh
		jne	loc_208			; Jump if not equal
		retn
loc_208:
		cmp	byte ptr [di],0FCh
		jne	loc_209			; Jump if not equal
		retn
loc_209:
		push	ds
		push	di
		push	si
		push	bx
		push	ax
		mov	ah,ds:data_84e
		dec	ah
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sbb	ah,ah
		xor	ah,0CCh
		mov	cs:data_85e,ah
		add	bx,bx
		xchg	bh,bl
		add	bx,ds:data_72e
		mov	di,bx
		pop	ax
		test	al,0FFh
		jz	loc_212			; Jump if zero
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_107e
		push	si
		push	di
		mov	al,cs:data_84e
		and	al,3
		neg	al
		add	al,3
		call	physics_func_32
		call	physics_func_30
		pop	di
		pop	si
		mov	al,cs:data_84e
		call	physics_func_32
		add	di,100h
		inc	si
		call	physics_func_30
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_30:
		mov	cx,2

locloop_210:
		push	di
		mov	bx,di
		call	math_calc
		mov	di,ax
		mov	bl,cs:data_85e
		lodsb				; String [si] to al
		and	al,bl
		not	bl
		and	es:[di],bl
		or	es:[di],al
		cmp	di,4000h
		jb	loc_211			; Jump if below
		add	di,data_130e
		and	es:[di],bl
		or	es:[di],al
loc_211:
		pop	di
		add	di,4
		add	si,7
		loop	locloop_210		; Loop if cx > 0

		retn
loc_212:
		push	di
		mov	al,cs:data_84e
		and	al,3
		neg	al
		add	al,3
		call	physics_func_32
		call	physics_func_31
		pop	di
		mov	al,cs:data_84e
		call	physics_func_32
		add	di,100h
		call	physics_func_31
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn
physics_multiply_6		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_31		proc	near
		push	di
		mov	bx,di
		call	math_calc
		mov	di,ax
		mov	al,cs:data_85e
		not	al
		and	es:[di],al
		cmp	di,4000h
		jb	loc_213			; Jump if below
		add	di,data_130e
		and	es:[di],al
loc_213:
		pop	bx
		push	ax
		add	bx,4
		call	math_calc
		mov	di,ax
		pop	ax
		and	es:[di],al
		cmp	di,4000h
		jb	loc_ret_214		; Jump if below
		add	di,data_130e
		and	es:[di],al

loc_ret_214:
		retn
physics_func_31		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_32		proc	near
		and	al,3
		xor	ah,ah			; Zero register
		add	di,ax
		add	ax,ax
		add	si,ax
		retn
physics_func_32		endp

			                        ;* No entry point to code
		mov	al,byte ptr ds:[83h]
		add	al,al
		add	al,al
		add	al,al
		mov	ah,byte ptr ds:[84h]
		add	ah,ah
		add	ah,ah
		add	ah,ah
		mov	ds:data_70e,al
		mov	byte ptr ds:data_70e+1,ah
		call	physics_scan_loop_2
		mov	byte ptr ds:data_84e,0AAh
		call	physics_func_33
		mov	byte ptr ds:data_84e,0
		call	physics_func_33
		jmp	loc_247

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_33		proc	near
		mov	al,ds:data_70e
		dec	al
		mov	bl,al
		add	al,19h
		mov	dl,al
		mov	al,byte ptr ds:data_70e+1
		dec	al
		mov	bh,al
		add	al,19h
		mov	dh,al
		call	physics_func_34
		mov	al,ds:data_70e
		sub	al,5
		mov	bl,al
		add	al,21h			; '!'
		mov	dl,al
		mov	al,byte ptr ds:data_70e+1
		sub	al,5
		mov	bh,al
		add	al,21h			; '!'
		mov	dh,al
		call	physics_func_34
		mov	al,ds:data_70e
		sub	al,9
		mov	bl,al
		add	al,29h			; ')'
		mov	dl,al
		mov	al,byte ptr ds:data_70e+1
		sub	al,9
		mov	bh,al
		add	al,29h			; ')'
		mov	dh,al

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_34:
		mov	cx,9

locloop_215:
		push	cx
		push	dx
		push	bx
		call	physics_func_35
		pop	bx
		pop	dx
		sub	bl,0Ch
		jnc	loc_216			; Jump if carry=0
		xor	bl,bl			; Zero register
loc_216:
		sub	bh,0Ch
		jnc	loc_217			; Jump if carry=0
		xor	bh,bh			; Zero register
loc_217:
		add	dl,0Ch
		jnc	loc_218			; Jump if carry=0
		mov	dl,0FFh
loc_218:
		add	dh,0Ch
		jnc	loc_219			; Jump if carry=0
		mov	dh,0FFh
loc_219:
		push	dx
		push	bx
		call	physics_multiply_7
		pop	bx
		pop	dx
		pop	cx
		loop	locloop_215		; Loop if cx > 0

		retn
physics_func_33		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_35		proc	near
		mov	ax,0B000h
		mov	es,ax
		push	dx
		push	bx
		mov	dh,bh
		call	physics_extract_bits
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	bh,dh
		call	physics_extract_bits
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	dl,bl
		call	physics_func_36
		pop	bx
		pop	dx
		mov	bl,dl

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physics_func_36:
		cmp	dh,bh
		jae	loc_220			; Jump if above or =
		xchg	dx,bx
loc_220:
		or	bl,bl			; Zero ?
		jnz	loc_221			; Jump if not zero
		retn
loc_221:
		cmp	bl,0DFh
		jb	loc_222			; Jump if below
		retn
loc_222:
		or	bh,bh			; Zero ?
		jnz	loc_223			; Jump if not zero
		mov	bh,1
loc_223:
		cmp	dh,8Fh
		jb	loc_224			; Jump if below
		mov	dh,8Eh
loc_224:
		mov	al,dh
		sub	al,bh
		inc	al
		push	ax
		mov	al,bh
		call	physics_get_value_2
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		pop	cx
		xor	ch,ch			; Zero register
		and	bl,3
		jz	loc_227			; Jump if zero
		cmp	bl,2
		jb	loc_226			; Jump if below
		jz	loc_225			; Jump if zero
		mov	ah,3
		jmp	short loc_228
loc_225:
		mov	ah,0Ch
		jmp	short loc_228
loc_226:
		mov	ah,30h			; '0'
		jmp	short loc_228
loc_227:
		mov	ah,0C0h
loc_228:
		mov	al,ah
		not	al
		and	ah,ds:data_84e

locloop_229:
		and	es:[di],al
		or	es:[di],ah
		add	di,2000h
		cmp	di,data_132e
		jb	loc_230			; Jump if below
		and	es:[di],al
		or	es:[di],ah
		add	di,0A05Ah
loc_230:
		loop	locloop_229		; Loop if cx > 0

		retn
physics_func_35		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_extract_bits		proc	near
		cmp	dl,bl
		jae	loc_231			; Jump if above or =
		xchg	dx,bx
loc_231:
		or	bh,bh			; Zero ?
		jnz	loc_232			; Jump if not zero
		retn
loc_232:
		cmp	bh,8Fh
		jb	loc_233			; Jump if below
		retn
loc_233:
		or	bl,bl			; Zero ?
		jnz	loc_234			; Jump if not zero
		mov	bl,1
loc_234:
		cmp	dl,0DFh
		jb	loc_235			; Jump if below
		mov	dl,0DEh
loc_235:
		mov	al,bh
		call	physics_get_value_2
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		mov	ah,dl
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,al
		mov	cl,ah
		xor	ch,ch			; Zero register
		and	bl,3
		jz	loc_238			; Jump if zero
		cmp	bl,2
		jb	loc_237			; Jump if below
		jz	loc_236			; Jump if zero
		mov	al,3
		jmp	short loc_239
loc_236:
		mov	al,0Fh
		jmp	short loc_239
loc_237:
		mov	al,3Fh			; '?'
		jmp	short loc_239
loc_238:
		mov	al,0FFh
loc_239:
		and	dl,3
		jz	loc_242			; Jump if zero
		cmp	dl,2
		jb	loc_241			; Jump if below
		jz	loc_240			; Jump if zero
		mov	ah,0FFh
		jmp	short loc_243
loc_240:
		mov	ah,0FCh
		jmp	short loc_243
loc_241:
		mov	ah,0F0h
		jmp	short loc_243
loc_242:
		mov	ah,0C0h
loc_243:
		jcxz	loc_245			; Jump if cx=0
		dec	cx
		jcxz	loc_244			; Jump if cx=0
		mov	dh,al
		not	dh
		and	al,ds:data_84e
		and	es:[di],dh
		or	es:[di],al
		inc	di
		mov	al,0FFh
		and	al,ds:data_84e
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	dh,ah
		not	dh
		and	ah,ds:data_84e
		and	es:[di],dh
		or	es:[di],ah
		retn
loc_244:
		mov	dh,al
		not	dh
		and	al,ds:data_84e
		and	es:[di],dh
		or	es:[di],al
		inc	di
		mov	dh,ah
		not	dh
		and	ah,ds:data_84e
		and	es:[di],dh
		or	es:[di],ah
		retn
loc_245:
		and	al,ah
		mov	dh,al
		not	dh
		and	al,ds:data_84e
		and	es:[di],dh
		or	es:[di],al
		retn
physics_extract_bits		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_get_value_2		proc	near
		push	bx
		mov	bx,0C0Eh
		add	bl,al
		call	math_calc
		mov	di,ax
		pop	bx
		retn
physics_get_value_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_multiply_7		proc	near
		mov	cl,ds:data_110e
		shr	cl,1			; Shift w/zeros fill
		inc	cl
		mov	al,1
		mul	cl			; ax = reg * al
loc_246:
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		cmp	ds:data_106e,al
		jb	loc_246			; Jump if below
		mov	byte ptr ds:data_106e,0
		retn
physics_multiply_7		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_scan_loop_2		proc	near
loc_247:
		mov	ax,0B000h
		mov	es,ax
		mov	di,data_128e
		mov	cx,90h

locloop_248:
		push	cx
		push	di
		mov	ax,0FFFFh
		mov	cx,1Ch

locloop_249:
		xor	es:[di],ax
		inc	di
		inc	di
		loop	locloop_249		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,data_132e
		jb	loc_251			; Jump if below
		push	di
		mov	ax,0FFFFh
		mov	cx,1Ch

locloop_250:
		xor	es:[di],ax
		inc	di
		inc	di
		loop	locloop_250		; Loop if cx > 0

		pop	di
		add	di,0A05Ah
loc_251:
		pop	cx
		loop	locloop_248		; Loop if cx > 0

		retn
physics_scan_loop_2		endp

			                        ;* No entry point to code
		and	al,3Fh			; '?'
		add	al,al
		add	al,al
		add	al,al
		add	al,0Eh
		sub	ah,4
		add	ah,ah
		add	ah,0Ch
		mov	bx,ax
		call	math_calc
		mov	di,ax
		retn
			                        ;* No entry point to code
		mov	bl,byte ptr ds:[9Dh]
		or	bl,bl			; Zero ?
		jz	loc_252			; Jump if zero
		cmp	bl,7
		je	loc_252			; Jump if equal
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	es,cs:data_107e
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	si,[bx]
		mov	di,data_5e
		mov	cx,480h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
loc_252:
		mov	ds,cs:data_107e
		mov	si,8690h
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_41		proc	near
		cmp	si,0E900h
		jae	loc_253			; Jump if above or =
		retn
loc_253:
		sub	si,900h
		retn
physics_func_41		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_func_42		proc	near
		cmp	si,0E000h
		jb	loc_254			; Jump if below
		retn
loc_254:
		add	si,900h
		retn
physics_func_42		endp

			                        ;* No entry point to code
		push	si
		push	ds
		mov	si,data_63e
		mov	di,data_131e
		mov	ax,0B000h
		mov	es,ax
		mov	cx,5

locloop_255:
		push	cx
		mov	cx,1Ch

locloop_256:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	ds,cs:data_107e
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,4000h
		mov	si,ax
		push	di
		mov	cx,8

locloop_257:
		push	cx
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,data_132e
		jb	loc_258			; Jump if below
		mov	ax,[si-2]
		stosw				; Store ax to es:[di]
		add	di,0A058h
loc_258:
		pop	cx
		loop	locloop_257		; Loop if cx > 0

		pop	di
		inc	di
		inc	di
		pop	si
		pop	ds
		pop	cx
		loop	locloop_256		; Loop if cx > 0

		add	di,407Ch
		cmp	di,6000h
		jb	loc_259			; Jump if below
		add	di,0A05Ah
loc_259:
		pop	cx
		loop	locloop_255		; Loop if cx > 0

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
		db	 3Fh, 06h,0A2h,0F7h, 4Fh,0BEh
		db	 17h, 47h,0C7h, 06h,0E4h, 4Fh
		db	0FDh, 04h,0B9h, 12h, 00h

locloop_260:
		push	cx
		mov	cx,1Ch

locloop_261:
		push	cx
		lodsb				; String [si] to al
		push	si
		call	physics_multiply_8
		pop	si
		add	word ptr ds:data_72e,2
		pop	cx
		loop	locloop_261		; Loop if cx > 0

		add	word ptr ds:data_72e,407Ch
		cmp	word ptr ds:data_72e,6000h
		jb	loc_262			; Jump if below
		add	word ptr ds:data_72e,0A05Ah
loc_262:
		pop	cx
		loop	locloop_260		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_multiply_8		proc	near
		push	ds
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:data_107e
		mov	ax,0B000h
		mov	es,ax
		mov	di,cs:data_72e
		mov	cx,8

locloop_263:
		push	cx
		lodsw				; String [si] to ax
		call	physics_process_loop_2
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,data_132e
		jb	loc_264			; Jump if below
		stosw				; Store ax to es:[di]
		add	di,0A058h
loc_264:
		pop	cx
		loop	locloop_263		; Loop if cx > 0

		pop	ds
		retn
physics_multiply_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_process_loop_2		proc	near
		mov	cx,8

locloop_265:
		push	cx
		add	ax,ax
		adc	cl,cl
		add	ax,ax
		adc	cl,cl
		and	cl,3
		mov	bl,cs:data_84e
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_64e[bx]	;*
		add	dx,dx
		add	dx,dx
		or	dl,cl
		pop	cx
		loop	locloop_265		; Loop if cx > 0

		mov	ax,dx
		retn
physics_process_loop_2		endp

		db	0DAh, 46h,0DBh, 46h,0ECh, 46h
		db	0FDh, 46h, 0Eh, 47h,0C3h, 80h
		db	0F9h, 01h, 75h, 03h,0B1h, 02h
		db	0C3h, 80h,0F9h, 02h, 74h, 01h
		db	0C3h
loc_266:
		mov	cl,1
		retn
			                        ;* No entry point to code
		cmp	cl,1
		jne	loc_267			; Jump if not equal
		mov	cl,0
		retn
loc_267:
		cmp	cl,2
		je	loc_268			; Jump if equal
		retn
loc_268:
		mov	cl,1
		retn
			                        ;* No entry point to code
		cmp	cl,2
		jne	loc_269			; Jump if not equal
		mov	cl,3
		retn
loc_269:
		cmp	cl,3
		je	loc_270			; Jump if equal
		retn
loc_270:
		mov	cl,2
		retn
			                        ;* No entry point to code
		cmp	cl,1
		je	loc_271			; Jump if equal
		retn
loc_271:
		mov	cl,3
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
		sbb	ds:data_95e,bh
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
		db	 1Eh, 50h,0E8h, 32h, 05h, 8Bh
		db	0F8h, 58h,0B1h, 10h,0F6h,0E1h
		db	 05h, 00h, 60h, 8Bh,0F0h, 2Eh
		db	 8Eh, 1Eh, 2Ch,0FFh,0B8h, 00h
		db	0B0h, 8Eh,0C0h,0B9h, 08h, 00h

locloop_272:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,data_94e
		jb	loc_273			; Jump if below
		mov	ax,[si-2]
		stosw				; Store ax to es:[di]
		add	di,0A058h
loc_273:
		loop	locloop_272		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_65e[bx]
		mov	di,data_129e
		mov	ax,0B000h
		mov	es,ax
		mov	cx,18h

locloop_274:
		lodsw				; String [si] to ax
		mov	bx,ax
		lodsw				; String [si] to ax
		or	es:[di],bx
		or	es:[di+2],ax
		add	di,2000h
		cmp	di,data_132e
		jb	loc_275			; Jump if below
		or	es:[di],bx
		or	es:[di+2],ax
		add	di,0A05Ah
loc_275:
		loop	locloop_274		; Loop if cx > 0

		pop	ds
		retn
		db	 8Eh, 49h, 8Eh, 49h, 8Eh, 49h
		db	0EEh, 49h,0EEh
		db	 49h, 4Eh, 4Ah
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
		db	 00h, 00h, 1Eh, 0Ah,0C0h, 78h
		db	 10h, 24h, 03h,0B2h, 40h,0F6h
		db	0E2h, 05h, 46h, 4Bh, 8Bh,0F0h
		db	0BDh, 01h, 00h,0EBh, 0Eh, 24h
		db	 01h, 8Ah,0E0h, 32h,0C0h, 05h
		db	 46h, 4Ch, 8Bh,0F0h,0BDh, 04h
		db	 00h, 8Ah,0C3h, 24h, 03h, 02h
		db	0C0h,0A2h,0F8h, 4Fh,0D1h,0EBh
		db	0D1h,0EBh, 8Ah,0FBh, 8Ah,0D9h
		db	0E8h, 61h, 03h, 8Bh,0F8h,0B8h
		db	 00h,0B0h, 8Eh,0C0h, 8Bh,0CDh

locloop_276:
		push	cx
		push	di
		mov	cx,10h

locloop_277:
		push	cx
		push	si
		push	di
		call	physics_process_loop_3
		pop	di
		pop	si
		add	di,2000h
		cmp	di,6000h
		jb	loc_278			; Jump if below
		push	si
		push	di
		call	physics_process_loop_3
		pop	di
		pop	si
		add	di,data_97e
loc_278:
		add	si,4
		pop	cx
		loop	locloop_277		; Loop if cx > 0

		pop	di
		add	di,4
		pop	cx
		loop	locloop_276		; Loop if cx > 0

		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_process_loop_3		proc	near
		mov	cx,2

locloop_279:
		push	cx
		lodsw				; String [si] to ax
		mov	bh,al
		xor	bl,bl			; Zero register
		mov	cl,cs:data_85e
		shr	bx,cl			; Shift w/zeros fill
		xor	al,al			; Zero register
		shr	ax,cl			; Shift w/zeros fill
		or	bl,ah
		mov	ah,al
		or	es:[di],bh
		inc	di
		or	es:[di],bl
		inc	di
		or	es:[di],ah
		pop	cx
		loop	locloop_279		; Loop if cx > 0

		retn
physics_process_loop_3		endp

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

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

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

			                        ;* No entry point to code
		push	cx
		push	ds
		push	si
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,20h
		mul	cx			; dx:ax = reg * ax
		mov	cx,ax
		mov	di,data_127e
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,data_127e

locloop_280:
		push	cx
		mov	cx,8

locloop_281:
		push	cx
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsw				; String [si] to ax
		mov	cx,ax
		mov	cs:data_72e,dx
		mov	cs:data_74e,cx
		or	ax,dx
		xchg	al,ah
		mov	bx,ax
		shr	bx,1			; Shift w/zeros fill
		or	ax,bx
		add	bx,bx
		add	bx,bx
		or	ax,bx
		xchg	al,ah
		not	ax
		mov	cs:data_83e,ax
		call	physics_process_loop_4
		mov	ax,dx
		stosw				; Store ax to es:[di]
		call	physics_scan_loop_3
		mov	es:[bp],dx
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_281		; Loop if cx > 0

		pop	cx
		loop	locloop_280		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_process_loop_4		proc	near
		mov	cx,8

locloop_282:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_74e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_72e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_74e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_72e,1	; Rotate
		adc	bx,bx
		add	dx,dx
		add	dx,dx
		or	dl,cs:data_67e[bx]
		loop	locloop_282		; Loop if cx > 0

		retn
physics_process_loop_4		endp

		db	0, 1, 2, 1, 1, 3
		db	3, 1, 2, 3, 2, 2
		db	1, 1, 2, 3

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physics_scan_loop_3		proc	near
		mov	cx,8

locloop_283:
		xor	al,al			; Zero register
		rol	word ptr cs:data_83e,1	; Rotate
		adc	al,al
		rol	word ptr cs:data_83e,1	; Rotate
		adc	al,al
		cmp	al,3
		je	loc_284			; Jump if equal
		xor	al,al			; Zero register
loc_284:
		add	dx,dx
		add	dx,dx
		or	dl,al
		loop	locloop_283		; Loop if cx > 0

		retn
physics_scan_loop_3		endp

			                        ;* No entry point to code
		push	ds
		push	cs
		pop	ds
		mov	si,data_68e
		mov	es,cs:data_107e
		mov	di,data_4e
		mov	cx,20h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
			                        ;* No entry point to code
		aas				; Ascii adjust
                           lock	or	al,0Ch
		or	al,0Ch
		or	al,0Ch
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
                           lock	or	al,0C0h
		or	al,30h			; '0'
		or	al,0Ch
		aas				; Ascii adjust
                           lock	or	al,0Ch
		or	al,0Ch
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
                           lock	or	al,0Ch
		or	al,0Ch
		or	al,0Ch
		aas				; Ascii adjust
;*                         lock	pop	cs			; Dangerous-8088 only
		db	0F0h, 0Fh		;  Fixup - byte match
                           lock	xor	[si],cl
		xor	[si],cl
		xor	[bx+si],al
		xor	di,sp
		xor	[si],cl
		xor	[si],cl
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
                           lock	xor	[si],cl
		xor	[si],cl
		cmp	al,3Ch			; '<'
		cmp	al,3Ch			; '<'
		xor	cx,sp
		xor	cx,sp
		xor	[si],cl
		xor	[si],cl
		xchg	dx,ax
		dec	di
		mov	ds:data_98e,al
		dec	di
		retn	0D24Fh
			                        ;* No entry point to code
		dec	di
		retn	4Fh
			                        ;* No entry point to code
		add	[bp+si],ax
		add	ax,[si]
		add	ax,706h
		or	[bx+di],cl
		or	cl,[bp+di]
		or	al,0Dh
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bp+si],al
		add	[bp+di],ax
		or	[bp+si],cl
		or	[bp+di],cx
		add	al,6
		add	ax,0C07h
		push	cs
		or	ax,0Fh
		add	[bx+di],al
		add	ax,[bx+si]
		add	[bx+di],al
		add	ax,[si]
		add	al,5
		pop	es
		or	al,0Ch
		or	ax,0Fh
		add	al,[bp+di]
		add	[bx+si],cx
		or	cl,[bp+di]
		or	[si],cx
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		or	ax,604h
		pop	es
		add	ax,300h
		add	[bp+si],al
		or	al,0Fh
		or	al,0Eh
		add	[bp+di],al
		add	[bp+si],al
		or	[bp+di],cl
		or	[bp+si],cl
		db	724 dup (0)

seg_a		ends



		end	start
