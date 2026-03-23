
PAGE  59,132

;==========================================================================
;
;  PHYSICS_SUBSYSTEMS - Code Module
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
data_51e	equ	3170h			;*
data_52e	equ	38D1h			;*
data_53e	equ	397Dh			;*
data_54e	equ	4643h			;*
data_55e	equ	4777h			;*
data_56e	equ	47BEh			;*
data_57e	equ	4A3Ah			;*
data_58e	equ	4F88h			;*
data_59e	equ	4FCFh			;*
data_60e	equ	500Fh			;*
data_61e	equ	506Bh			;*
data_63e	equ	506Dh			;*
data_64e	equ	506Fh			;*
data_65e	equ	5071h			;*
data_66e	equ	5073h			;*
data_67e	equ	5074h			;*
data_68e	equ	5075h			;*
data_69e	equ	5076h			;*
data_70e	equ	5077h			;*
data_71e	equ	5078h			;*
data_72e	equ	507Ah			;*
data_73e	equ	507Ch			;*
data_75e	equ	507Eh			;*
data_76e	equ	5080h			;*
data_77e	equ	5081h			;*
data_78e	equ	5082h			;*
data_79e	equ	5092h			;*
data_80e	equ	5093h			;*
data_81e	equ	5096h			;*
data_82e	equ	509Fh			;*
data_83e	equ	519Fh			;*
data_84e	equ	529Fh			;*
data_85e	equ	532Fh			;*
data_86e	equ	625Ch			;*
data_87e	equ	0A030h			;*
data_88e	equ	0C010h			;*
data_89e	equ	0C012h			;*
data_90e	equ	0C050h			;*
data_91e	equ	0E000h			;*
data_92e	equ	0E900h			;*
data_93e	equ	0E91Bh			;*
data_94e	equ	0ED20h			;*
data_95e	equ	0EDA0h			;*
data_96e	equ	0FB3Ah			;*
data_97e	equ	0FF1Ah			;*
data_98e	equ	0FF2Ch			;*
data_99e	equ	0FF2Fh			;*
data_100e	equ	0FF31h			;*
data_101e	equ	0FF33h			;*
data_102e	equ	0FF34h			;*
data_103e	equ	0FF36h			;*
data_104e	equ	0FF37h			;*
data_105e	equ	0FF38h			;*
data_106e	equ	0FF39h			;*
data_107e	equ	0FF3Ah			;*
data_108e	equ	0FF3Dh			;*
data_109e	equ	0FF3Fh			;*
data_110e	equ	0FF40h			;*
data_111e	equ	0FF41h			;*
data_112e	equ	0FF42h			;*
data_113e	equ	0FF43h			;*
data_114e	equ	0FF44h			;*
data_115e	equ	0FF45h			;*
data_116e	equ	0FF46h			;*
data_117e	equ	0A0h
data_118e	equ	23Ch
data_119e	equ	0D94h
data_120e	equ	0C050h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_03		proc	far

start:
		aas				; Ascii adjust
		and	ax,[bx+si]
		add	[si],ch
		xor	ss:data_96e[bp+di],bl
		aas				; Ascii adjust
		or	bh,[bx]
		add	word ptr [bx+di+7Eh],0AC45h
		inc	ax
		db	 6Ch, 32h,0D5h, 38h,0CDh, 41h
		db	 43h, 41h, 85h, 3Ah,0FCh, 42h
		db	 99h, 45h,0E3h, 45h,0EDh, 46h
		db	 29h, 41h,0B6h, 49h, 05h, 4Ah
		db	 66h, 4Bh,0F5h, 4Eh,0BAh, 4Fh
		db	 0Eh, 07h,0BFh, 9Fh, 50h, 33h
		db	0C0h,0B9h, 80h
data_9		dw	0F300h			; Data table (indexed access)
		db	0ABh,0FEh, 06h, 80h, 50h,0C7h
		db	 06h, 6Dh, 50h, 3Ch, 02h, 8Bh
		db	 36h, 31h,0FFh, 83h,0EEh, 21h
		db	0E8h, 8Bh, 15h, 33h,0DBh,0F6h
		db	 04h, 80h, 74h, 03h,0E8h,0C8h
		db	 03h, 46h,0B9h, 06h, 00h

locloop_1:
		push	cx
		test	byte ptr [si],80h
		jz	loc_2			; Jump if zero
		call	physsub_func_3
loc_2:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_3			; Jump if zero
		call	physsub_func_3
loc_3:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_4			; Jump if zero
		call	physsub_func_3
loc_4:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_5			; Jump if zero
		call	physsub_func_3
loc_5:
		inc	si
		inc	bx
		pop	cx
		loop	locloop_1		; Loop if cx > 0

		test	byte ptr [si],80h
		jz	loc_6			; Jump if zero
		call	physsub_func_3
loc_6:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_7			; Jump if zero
		call	physsub_func_3
loc_7:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_8			; Jump if zero
		call	physsub_func_3
loc_8:
		inc	si
		test	byte ptr [si],80h
		jz	loc_9			; Jump if zero
		call	physsub_func_4
loc_9:
		mov	si,ds:data_100e
		mov	di,0E900h
		mov	byte ptr ds:data_66e,12h
loc_10:
		call	physsub_func_21
		xor	bx,bx			; Zero register
		add	si,3
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jns	loc_11			; Jump if not sign
		call	physsub_func_5
loc_11:
		mov	cx,6

locloop_12:
		push	cx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_13			; Jump if zero
		call	physsub_func_1
loc_13:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_14			; Jump if zero
		call	physsub_func_1
loc_14:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_15			; Jump if zero
		call	physsub_func_1
loc_15:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_16			; Jump if zero
		call	physsub_func_1
loc_16:
		inc	bx
		pop	cx
		loop	locloop_12		; Loop if cx > 0

		cmpsb				; Cmp [si] to es:[di]
		jz	loc_17			; Jump if zero
		call	physsub_func_1
loc_17:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_18			; Jump if zero
		call	physsub_func_1
loc_18:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_19			; Jump if zero
		call	physsub_func_1
loc_19:
		inc	bx
		lodsb				; String [si] to al
		inc	di
		or	al,al			; Zero ?
		jns	loc_20			; Jump if not sign
		jmp	loc_80
loc_20:
		cmp	al,es:[di-1]
		je	loc_21			; Jump if equal
		call	physsub_func_1
loc_21:
		add	si,4
		call	physsub_func_39
		add	word ptr ds:data_63e,140h
		dec	byte ptr ds:data_66e
		jnz	loc_10			; Jump if not zero
		retn

zr2_03		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_func_1		proc	near
		mov	al,[si-1]
		or	al,al			; Zero ?
		jns	loc_22			; Jump if not sign
		jmp	loc_78
loc_22:
		cmp	byte ptr es:[di-1],0FCh
		jne	loc_23			; Jump if not equal
		mov	byte ptr es:[di-1],0FFh
		jmp	short loc_24
loc_23:
		inc	byte ptr es:[di-1]
		mov	byte ptr es:[di-1],0FEh
		jz	loc_24			; Jump if zero
		mov	es:[di-1],al
		mov	dx,bx
		add	dx,dx
		add	dx,ds:data_63e
		call	physsub_multiply
loc_24:
		mov	al,ds:data_89e
		sub	al,5
		jnc	loc_25			; Jump if carry=0
		retn
loc_25:
		cmp	al,4
		jb	loc_26			; Jump if below
		retn
loc_26:
		push	bx
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:data_51e[bx]	;*
		pop	bx
		retn
physsub_func_1		endp

			                        ;* No entry point to code
;*		js	loc_30			;*Jump if sign=1
		db	 78h, 31h		;  Fixup - byte match
		cbw				; Convrt byte to word
;*		xor	si,cx
		db	 31h,0CEh		;  Fixup - byte match
		xor	[si+32h],cx
		mov	al,[si-1]
		sub	al,1Bh
		cmp	al,2
		jb	loc_27			; Jump if below
		retn
loc_27:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_76e,1
		jnz	loc_28			; Jump if not zero
		retn
loc_28:
		inc	al
		and	al,1
		add	al,1Bh
		mov	[si-1],al
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,1Dh
		cmp	al,6
		jb	loc_29			; Jump if below
		retn
loc_29:
		mov	byte ptr [di-1],0FEh
		cmp	al,4
		jae	loc_32			; Jump if above or =
		or	al,al			; Zero ?
		jnz	loc_31			; Jump if not zero
		push	ax
		call	word ptr cs:[11Ah]
		and	al,3
		pop	ax
		jz	loc_31			; Jump if zero
		retn
loc_31:
		inc	al
		and	al,3
		add	al,1Dh
		mov	[si-1],al
		retn
loc_32:
		inc	al
		and	al,1
		add	al,21h			; '!'
		mov	[si-1],al
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,2Ch			; ','
		cmp	al,2
		jae	loc_34			; Jump if above or =
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_76e,1
		jnz	loc_33			; Jump if not zero
		retn
loc_33:
		inc	al
		and	al,1
		add	al,2Ch			; ','
		mov	[si-1],al
		retn
loc_34:
		mov	al,[si-1]
		cmp	al,3Eh			; '>'
		jb	loc_35			; Jump if below
		retn
loc_35:
		mov	bl,33h			; '3'
		cmp	al,0Eh
		je	loc_37			; Jump if equal
		mov	bl,36h			; '6'
		cmp	al,0Dh
		je	loc_37			; Jump if equal
		mov	bl,39h			; '9'
		cmp	al,0Fh
		je	loc_37			; Jump if equal
		mov	bl,3Ch			; '<'
		cmp	al,0Ch
		je	loc_37			; Jump if equal
		mov	bl,3Dh			; '='
		cmp	al,10h
		je	loc_37			; Jump if equal
		sub	al,33h			; '3'
		jnc	loc_36			; Jump if carry=0
		retn
loc_36:
		mov	bl,0Eh
		cmp	al,2
		je	loc_37			; Jump if equal
		mov	bl,0Dh
		cmp	al,5
		je	loc_37			; Jump if equal
		mov	bl,0Fh
		cmp	al,8
		je	loc_37			; Jump if equal
		mov	bl,0Ch
		cmp	al,9
		je	loc_37			; Jump if equal
		mov	bl,10h
		cmp	al,0Ah
		je	loc_37			; Jump if equal
		inc	al
		add	al,33h			; '3'
		mov	bl,al
loc_37:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_76e,1
		jnz	loc_38			; Jump if not zero
		retn
loc_38:
		mov	[si-1],bl
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,25h			; '%'
		cmp	al,4
		jb	loc_39			; Jump if below
		retn
loc_39:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_76e,1
		jnz	loc_40			; Jump if not zero
		retn
loc_40:
		inc	al
		and	al,3
		add	al,25h			; '%'
		mov	[si-1],al
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_multiply		proc	near
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,dx
		or	al,al			; Zero ?
		jnz	loc_41			; Jump if not zero
		jmp	loc_60
loc_41:
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:data_82e[bx],0FFFFh
		jnz	loc_45			; Jump if not zero
		dec	al
		mov	ds:data_82e[bx],di
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_98e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,4

locloop_42:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_43			; Jump if below
		add	di,data_120e
loc_43:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_44			; Jump if below
		add	di,data_120e
loc_44:
		loop	locloop_42		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_45:
		mov	si,ds:data_82e[bx]
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_46			; Jump if below
		add	di,data_120e
loc_46:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_47			; Jump if below
		add	si,data_120e
loc_47:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_48			; Jump if below
		add	di,data_120e
loc_48:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_49			; Jump if below
		add	si,data_120e
loc_49:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_50			; Jump if below
		add	di,data_120e
loc_50:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_51			; Jump if below
		add	si,data_120e
loc_51:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_52			; Jump if below
		add	di,data_120e
loc_52:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_53			; Jump if below
		add	si,data_120e
loc_53:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_54			; Jump if below
		add	di,data_120e
loc_54:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_55			; Jump if below
		add	si,data_120e
loc_55:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_56			; Jump if below
		add	di,data_120e
loc_56:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_57			; Jump if below
		add	si,data_120e
loc_57:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_58			; Jump if below
		add	di,data_120e
loc_58:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_59			; Jump if below
		add	si,data_120e
loc_59:
		movsw				; Mov [si] to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_60:
		mov	ax,0B800h
		mov	es,ax
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_61			; Jump if below
		add	di,data_120e
loc_61:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_62			; Jump if below
		add	di,data_120e
loc_62:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_63			; Jump if below
		add	di,data_120e
loc_63:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_64			; Jump if below
		add	di,data_120e
loc_64:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_65			; Jump if below
		add	di,data_120e
loc_65:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_66			; Jump if below
		add	di,data_120e
loc_66:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_67			; Jump if below
		add	di,data_120e
loc_67:
		stosw				; Store ax to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
physsub_multiply		endp

			                        ;* No entry point to code
		cmp	byte ptr ds:data_92e,0FFh
		jne	loc_68			; Jump if not equal
		retn
loc_68:
		cmp	byte ptr ds:data_92e,0FCh
		jne	loc_69			; Jump if not equal
		retn
loc_69:
		push	si
		push	bx
		mov	byte ptr ds:data_92e,0FFh
		mov	cl,[si]
		add	si,25h
		call	physsub_func_39
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_70			; Jump if not sign
		call	physsub_get_value
loc_70:
		push	ax
		mov	al,cl
		call	physsub_multiply_3
		add	si,3
		pop	ax
		mov	ah,[si]
		mov	dx,23Ch
		call	physsub_func_8
		pop	bx
		pop	si
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_func_3		proc	near
		push	si
		push	bx
		mov	cx,bx
		mov	di,bx
		add	di,data_92e
		mov	bx,data_79e
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	byte ptr [bx+1],0
		mov	byte ptr [di+1],0FFh
		mov	dx,cx
		add	dx,dx
		add	dx,23Ch
		mov	cl,[si]
		add	si,24h
		call	physsub_func_39
		mov	bx,data_81e
		lodsw				; String [si] to ax
		mov	[bx],ax
		mov	al,cl
		call	physsub_multiply_3
		inc	si
		inc	si
		mov	di,data_81e
		mov	bp,data_79e
		call	physsub_func_6
		pop	bx
		pop	si
		retn
physsub_func_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_func_4		proc	near
		cmp	byte ptr ds:data_93e,0FFh
		jne	loc_71			; Jump if not equal
		retn
loc_71:
		cmp	byte ptr ds:data_93e,0FCh
		jne	loc_72			; Jump if not equal
		retn
loc_72:
		mov	byte ptr ds:data_93e,0FFh
		mov	cl,[si]
		add	si,24h
		call	physsub_func_39
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_73			; Jump if not sign
		call	physsub_get_value
loc_73:
		push	ax
		mov	al,cl
		call	physsub_multiply_3
		add	si,2
		pop	ax
		mov	ah,[si]
		mov	dx,272h
		jmp	loc_87

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_5:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_79e
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	al,0FFh
		xchg	[di+1Ch],al
		mov	[bx+1],al
		mov	cl,[si-1]
		mov	dl,[si]
		add	si,24h
		call	physsub_func_39
		mov	dh,[si]
		mov	al,cl
		call	physsub_multiply_3
		inc	si
		mov	bx,dx
		pop	dx
		add	dx,dx
		add	dx,ds:data_63e
		cmp	byte ptr ds:data_79e,0FFh
		je	loc_75			; Jump if equal
		cmp	byte ptr ds:data_79e,0FCh
		je	loc_75			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_74			; Jump if not sign
		call	physsub_get_value
loc_74:
		call	physsub_func_8
		pop	dx
		pop	si
		pop	bx
loc_75:
		add	dx,140h
		cmp	byte ptr ds:data_66e,1
		je	loc_77			; Jump if equal
		cmp	byte ptr ds:data_80e,0FFh
		je	loc_77			; Jump if equal
		cmp	byte ptr ds:data_80e,0FCh
		je	loc_77			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_76			; Jump if not sign
		call	physsub_get_value
loc_76:
		call	physsub_func_8
loc_77:
		pop	bx
		pop	di
		pop	si
		retn
loc_78:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_79e
		mov	ax,0FFFEh
		xchg	[di-1],ax
		mov	[bx],ax
		mov	ax,0FFFFh
		xchg	[di+1Bh],ax
		mov	[bx+2],ax
		mov	cl,[si-1]
		mov	bx,data_81e
		mov	al,[si]
		mov	[bx+1],al
		add	si,24h
		call	physsub_func_39
		mov	ax,[si-1]
		mov	[bx+2],ax
		pop	dx
		mov	ds:data_67e,dl
		mov	al,ds:data_66e
		neg	al
		add	al,12h
		mov	ds:data_68e,al
		add	dx,dx
		add	dx,ds:data_63e
		mov	al,cl
		call	physsub_multiply_3
		mov	di,data_81e
		mov	[di],al
		mov	bp,data_79e
		call	physsub_func_6
		cmp	byte ptr ds:data_66e,1
		je	loc_79			; Jump if equal
		add	dx,13Ch
		call	physsub_func_6
		test	byte ptr ds:data_102e,0FFh
		jz	loc_79			; Jump if zero
		test	byte ptr ds:data_99e,0FFh
		jz	loc_79			; Jump if zero
		call	physsub_check_state_2
loc_79:
		pop	bx
		pop	di
		pop	si
		retn
loc_80:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_79e
		mov	al,0FEh
		xchg	[di-1],al
		mov	[bx],al
		mov	al,0FFh
		xchg	[di+1Bh],al
		mov	[bx+1],al
		mov	cl,[si-1]
		add	si,24h
		call	physsub_func_39
		mov	dl,[si-1]
		mov	al,cl
		call	physsub_multiply_3
		mov	bl,al
		mov	bh,dl
		pop	dx
		add	dx,dx
		add	dx,ds:data_63e
		cmp	byte ptr ds:data_79e,0FFh
		je	loc_82			; Jump if equal
		cmp	byte ptr ds:data_79e,0FCh
		je	loc_82			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_81			; Jump if not sign
		call	physsub_get_value
loc_81:
		call	physsub_func_8
		pop	dx
		pop	si
		pop	bx
loc_82:
		add	dx,140h
		cmp	byte ptr ds:data_66e,1
		je	loc_84			; Jump if equal
		cmp	byte ptr ds:data_80e,0FFh
		je	loc_84			; Jump if equal
		cmp	byte ptr ds:data_80e,0FCh
		je	loc_84			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_83			; Jump if not sign
		call	physsub_get_value
loc_83:
		call	physsub_func_8
loc_84:
		pop	bx
		pop	di
		pop	si
		jmp	loc_21

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_6:
		call	physsub_func_7

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_7:
		cmp	byte ptr ds:[bp],0FFh
		je	loc_86			; Jump if equal
		cmp	byte ptr ds:[bp],0FCh
		je	loc_86			; Jump if equal
		mov	ah,[si]
		mov	al,[di]
		or	al,al			; Zero ?
		jns	loc_85			; Jump if not sign
		call	physsub_get_value
loc_85:
		push	bp
		push	si
		push	di
		push	dx
		call	physsub_func_8
		pop	dx
		pop	di
		pop	si
		pop	bp
loc_86:
		inc	si
		inc	di
		inc	bp
		inc	dx
		inc	dx
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_8:
loc_87:
		push	es
		push	ds
		mov	bl,ds:data_69e
		or	al,al			; Zero ?
		jz	loc_88			; Jump if zero
		js	loc_88			; Jump if sign=1
		or	bl,80h
loc_88:
		mov	cl,al
		mov	al,ah
		mov	ch,10h
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		mov	bp,ax
		add	bp,0A000h
		mov	ds,cs:data_98e
		mov	di,dx
		push	cs
		pop	es
		mov	ch,bl
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:data_60e[bx]
		mov	cs:data_61e,ax
		mov	al,cl
		or	ch,ch			; Zero ?
		js	loc_89			; Jump if sign=1
		push	di
		mov	di,532Fh
		call	physsub_process_loop
		pop	di
		mov	si,data_85e
		push	cs
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		call	physsub_check_state
		pop	ds
		pop	es
		retn
loc_89:
		push	di
		mov	di,data_85e
		call	physsub_multiply_2
		pop	di
		mov	si,data_85e
		push	cs
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		call	physsub_check_state
		pop	ds
		pop	es
		retn
physsub_func_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_multiply_2		proc	near
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

physsub_func_10:
		mov	cx,8

locloop_90:
		mov	ax,ds:[bp]
		and	es:[di],ax
		lodsw				; String [si] to ax
		call	extract_bits
		or	es:[di],ax
		inc	bp
		inc	bp
		inc	di
		inc	di
		loop	locloop_90		; Loop if cx > 0

		retn
physsub_multiply_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_process_loop		proc	near
		mov	cx,8

locloop_91:
		lodsw				; String [si] to ax
		call	extract_bits
		stosw				; Store ax to es:[di]
		loop	locloop_91		; Loop if cx > 0

		retn
physsub_process_loop		endp


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
		add	bx,cs:data_61e
		mov	dh,cs:[bx]
		add	dh,dh
		add	dh,dh
		add	dh,dh
		add	dh,dh
		mov	bx,ax
		and	bh,0Fh
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,cs:data_61e
		or	dh,cs:[bx]
		mov	bx,ax
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		add	bx,cs:data_61e
		mov	dl,cs:[bx]
		add	dl,dl
		add	dl,dl
		add	dl,dl
		add	dl,dl
		mov	bx,ax
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	bx,cs:data_61e
		or	dl,cs:[bx]
		mov	ax,dx
		retn
extract_bits		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_check_state		proc	near
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_92			; Jump if below
		add	di,data_120e
loc_92:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_93			; Jump if below
		add	di,data_120e
loc_93:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_94			; Jump if below
		add	di,data_120e
loc_94:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_95			; Jump if below
		add	di,data_120e
loc_95:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_96			; Jump if below
		add	di,data_120e
loc_96:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_97			; Jump if below
		add	di,data_120e
loc_97:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_98			; Jump if below
		add	di,data_120e
loc_98:
		movsw				; Mov [si] to es:[di]
		retn
physsub_check_state		endp


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

physsub_get_value		proc	near
		and	al,7Fh
		mov	bx,data_94e
		xlat				; al=[al+[bx]] table
		retn
physsub_get_value		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_multiply_3		proc	near
		and	al,7Fh
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	cl,ds:data_94e[bx]
		mov	ch,10h
		mul	ch			; ax = reg * al
		add	ax,ds:data_88e
		mov	bp,ax
		mov	al,ds:[bp+6]
		and	al,0Fh
		mov	ch,5
		mul	ch			; ax = reg * al
		mov	si,0A070h
		test	byte ptr ds:[bp+5],80h
		jnz	loc_99			; Jump if not zero
		mov	si,data_87e
loc_99:
		mov	bl,ds:[bp+4]
		and	bl,1Fh
		add	bl,bl
		xor	bh,bh			; Zero register
		add	ax,[bx+si]
		mov	si,ax
		lodsb				; String [si] to al
		test	byte ptr ds:data_102e,0FFh
		jnz	loc_100			; Jump if not zero
		test	byte ptr ds:[bp+5],20h	; ' '
		jz	loc_100			; Jump if zero
		add	al,3
loc_100:
		mov	ds:data_69e,al
		mov	al,cl
		retn
physsub_multiply_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_check_state_2		proc	near
		cmp	byte ptr ds:data_68e,10h
		jb	loc_101			; Jump if below
		retn
loc_101:
		push	cs
		pop	es
		call	word ptr cs:[11Ah]
		and	al,0Fh
		cmp	al,0Eh
		jae	loc_102			; Jump if above or =
		retn
loc_102:
		mov	di,data_95e
		xor	cl,cl			; Zero register
loc_103:
		cmp	byte ptr [di],0FFh
		je	loc_104			; Jump if equal
		add	di,4
		inc	cl
		jmp	short loc_103
loc_104:
		cmp	cl,20h			; ' '
		jb	loc_105			; Jump if below
		retn
loc_105:
		call	word ptr cs:[11Ah]
		and	al,3
		cmp	al,3
		je	loc_105			; Jump if equal
		dec	al
		add	al,ds:data_67e
		cmp	al,0FFh
		jne	loc_106			; Jump if not equal
		mov	al,4
loc_106:
		cmp	al,1Bh
		jb	loc_107			; Jump if below
		mov	al,1Ah
loc_107:
		stosb				; Store al to es:[di]
loc_108:
		call	word ptr cs:[11Ah]
		and	al,3
		cmp	al,3
		je	loc_108			; Jump if equal
		dec	al
		add	al,ds:data_68e
		cmp	al,0FFh
		jne	loc_109			; Jump if not equal
		xor	al,al			; Zero register
loc_109:
		stosb				; Store al to es:[di]
		mov	al,3
		stosb				; Store al to es:[di]
		call	word ptr cs:[11Ah]
		and	al,3
		mov	bx,data_52e
		xlat				; al=[al+[bx]] table
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn
physsub_check_state_2		endp

			                        ;* No entry point to code
		push	bp
		stosb				; Store al to es:[di]
		jmp	dword ptr ss:[70Eh][bp+si]	;*
		db	0BFh,0A0h,0EDh, 8Bh,0F7h
loc_110:
		cmp	byte ptr [si],0FFh
		jne	loc_111			; Jump if not equal
		mov	byte ptr [di],0FFh
		retn
loc_111:
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
		add	ax,cx
		add	ax,23Ch
		push	si
		push	di
		push	es
		push	ax
		mov	al,[si+3]
		mov	ds:data_70e,al
		mov	bl,[si+2]
		and	bl,3
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:data_53e[bx]
		pop	di
		mov	ax,0B800h
		mov	es,ax
		mov	cx,10h

locloop_112:
		lodsw				; String [si] to ax
		and	al,ds:data_70e
		and	ah,ds:data_70e
		or	es:[di],ax
		lodsw				; String [si] to ax
		and	al,ds:data_70e
		and	ah,ds:data_70e
		or	es:[di+2],ax
		add	di,2000h
		cmp	di,4000h
		jb	loc_113			; Jump if below
		add	di,data_90e
loc_113:
		loop	locloop_112		; Loop if cx > 0

		pop	es
		pop	di
		pop	si
		dec	byte ptr [si+2]
		cmp	byte ptr [si+2],0FFh
		je	loc_114			; Jump if equal
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	si,4
loc_114:
		add	si,4
		jmp	loc_110
			                        ;* No entry point to code
		inc	bp
		cmp	al,[di]
		cmp	al,ch
		cmp	data_9[di],ax
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
		db	 00h,0BFh, 96h, 50h, 0Eh, 07h
		db	 33h,0C0h,0ABh,0ABh,0ABh,0ABh
		db	0AAh,0BFh, 82h, 50h,0B9h, 08h
		db	 00h,0F3h,0ABh,0EBh, 3Ch,0E8h
		db	 04h, 04h,0BFh, 82h, 50h, 8Ah
		db	 16h, 35h,0FFh,0FEh,0CAh,0B9h
		db	 04h, 00h

locloop_115:
		push	cx
		and	dl,3Fh			; '?'
		mov	al,24h			; '$'
		mul	dl			; ax = reg * al
		mov	bx,ax
		add	bx,data_91e
		mov	al,byte ptr ds:[83h]
		add	al,3
		xor	ah,ah			; Zero register
		add	bx,ax
		mov	cx,4

locloop_116:
		mov	al,[bx]
		or	al,al			; Zero ?
		js	loc_117			; Jump if sign=1
		xor	al,al			; Zero register
loc_117:
		mov	[di],al
		inc	bx
		inc	di
		loop	locloop_116		; Loop if cx > 0

		inc	dl
		pop	cx
		loop	locloop_115		; Loop if cx > 0

		mov	al,byte ptr ds:[84h]
		xor	ah,ah			; Zero register
		mov	cx,140h
		mul	cx			; dx:ax = reg * ax
		mov	cl,byte ptr ds:[83h]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	ax,cx
		add	ax,23Ch
		mov	ds:data_64e,ax
		mov	byte ptr ds:data_67e,0
		mov	si,5096h
		mov	di,data_78e
		mov	cx,3

locloop_118:
		push	cx
		mov	cx,3

locloop_119:
		push	cx
		mov	ax,3B66h
		push	ax
		mov	al,[di]
		or	al,[di+1]
		or	al,[di+4]
		or	al,[di+5]
		jnz	loc_120			; Jump if not zero
		jmp	loc_157
loc_120:
		test	byte ptr [di],0FFh
		jz	loc_121			; Jump if zero
		mov	al,[di]
		push	si
		call	physsub_multiply_3
		inc	si
		inc	si
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_159
loc_121:
		test	byte ptr [di+1],0FFh
		jz	loc_122			; Jump if zero
		mov	al,[di+1]
		push	si
		call	physsub_multiply_3
		inc	si
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_159
loc_122:
		test	byte ptr [di+4],0FFh
		jz	loc_123			; Jump if zero
		mov	al,[di+4]
		push	si
		call	physsub_multiply_3
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_159
loc_123:
		mov	al,[di+5]
		push	si
		call	physsub_multiply_3
		mov	cl,[si]
		pop	si
		mov	[si],al
		mov	al,cl
		jmp	loc_159
			                        ;* No entry point to code
		inc	byte ptr ds:data_67e
		inc	di
		inc	si
		pop	cx
		loop	locloop_119		; Loop if cx > 0

		pop	cx
		inc	di
		loop	locloop_118		; Loop if cx > 0

		mov	bl,ds:data_103e
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:data_60e[bx]
		mov	cs:data_61e,ax
		mov	es,cs:data_98e
		mov	al,byte ptr ds:[0E8h]
		or	al,ds:data_106e
		or	al,ds:data_107e
		jz	loc_124			; Jump if zero
		jmp	loc_134
loc_124:
		mov	cl,0FFh
		mov	si,6117h
		test	byte ptr ds:[0C2h],1
		jz	loc_125			; Jump if zero
		xor	cl,cl			; Zero register
		mov	si,61B9h
loc_125:
		test	byte ptr ds:data_110e,0FFh
		jz	loc_129			; Jump if zero
		inc	cl
		jnz	loc_126			; Jump if not zero
		mov	al,ds:data_109e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	physsub_func_20
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,62C7h
		jmp	short loc_132
loc_126:
		mov	al,ds:data_109e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:data_111e
		dec	dl
		jnz	loc_127			; Jump if not zero
		add	ax,24h
		jmp	short loc_128
loc_127:
		dec	dl
		jnz	loc_128			; Jump if not zero
		mov	ax,63h
loc_128:
		add	si,ax
		jmp	short loc_132
loc_129:
		call	physsub_func_20
		or	al,al			; Zero ?
		jz	loc_131			; Jump if zero
		dec	al
		mov	cl,al
		test	byte ptr ds:[0C2h],1
		jnz	loc_131			; Jump if not zero
		mov	ax,6Ch
		mov	dl,ds:data_105e
		and	dl,9
		xor	dh,dh			; Zero register
		add	ax,dx
		or	cl,cl			; Zero ?
		jz	loc_130			; Jump if zero
		add	ax,1Bh
loc_130:
		add	si,ax
		jmp	short loc_132
loc_131:
		test	byte ptr ds:data_105e,0FFh
		jnz	loc_134			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		cmp	al,80h
		je	loc_134			; Jump if equal
		add	al,2
		and	al,3
		test	al,1
		jnz	loc_134			; Jump if not zero
		mov	cl,9
		mul	cl			; ax = reg * al
		add	si,ax
		jmp	short loc_133
loc_132:
		test	byte ptr ds:data_105e,0FFh
		jz	loc_133			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:data_67e,3
		call	physsub_multiply_4
		jmp	short loc_134
loc_133:
		mov	cx,9
		mov	byte ptr ds:data_67e,0
		call	physsub_multiply_4
loc_134:
		mov	si,610Eh
		test	byte ptr ds:data_107e,0FFh
		jnz	loc_139			; Jump if not zero
		mov	si,60EAh
		test	byte ptr ds:data_106e,0FFh
		jnz	loc_137			; Jump if not zero
		mov	si,6075h
		test	byte ptr ds:[0C2h],1
		jnz	loc_135			; Jump if not zero
		mov	si,data_2e
loc_135:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_136			; Jump if zero
		add	si,5Ah
		jmp	short loc_137
loc_136:
		mov	ax,2Dh
		test	byte ptr ds:data_105e,0FFh
		jnz	loc_138			; Jump if not zero
		mov	ax,3Fh
		test	byte ptr ds:data_108e,80h
		jnz	loc_138			; Jump if not zero
		mov	cl,ds:data_112e
		mov	ax,48h
		dec	cl
		jz	loc_138			; Jump if zero
		mov	ax,51h
		dec	cl
		jz	loc_138			; Jump if zero
		mov	ax,36h
		cmp	byte ptr ds:data_108e,7Fh
		je	loc_138			; Jump if equal
		mov	ax,24h
		cmp	byte ptr ds:[0E7h],80h
		je	loc_138			; Jump if equal
loc_137:
		mov	al,byte ptr ds:[0E7h]
		and	al,3
		mov	cl,9
		mul	cl			; ax = reg * al
loc_138:
		add	si,ax
loc_139:
		mov	cx,9
		mov	byte ptr ds:data_67e,0
		call	physsub_multiply_4
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_140			; Jump if zero
		retn
loc_140:
		mov	cl,0FFh
		mov	si,61B9h
		test	byte ptr ds:[0C2h],1
		jnz	loc_141			; Jump if not zero
		xor	cl,cl			; Zero register
		mov	si,6117h
loc_141:
		mov	al,ds:data_106e
		or	al,ds:data_107e
		jz	loc_143			; Jump if zero
		call	physsub_func_20
		or	al,al			; Zero ?
		jnz	loc_142			; Jump if not zero
		retn
loc_142:
		dec	al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,1Bh
		add	al,7Eh			; '~'
		xor	ah,ah			; Zero register
		jmp	loc_150
loc_143:
		test	byte ptr ds:data_110e,0FFh
		jz	loc_147			; Jump if zero
		inc	cl
		jnz	loc_144			; Jump if not zero
		mov	al,ds:data_109e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	physsub_func_20
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,625Bh
		jmp	short loc_151
loc_144:
		mov	al,ds:data_109e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:data_111e
		dec	dl
		jnz	loc_145			; Jump if not zero
		add	ax,24h
		jmp	short loc_146
loc_145:
		dec	dl
		jnz	loc_146			; Jump if not zero
		mov	ax,63h
loc_146:
		add	si,ax
		jmp	short loc_151
loc_147:
		test	byte ptr ds:[0C2h],1
		jz	loc_149			; Jump if zero
		call	physsub_func_20
		or	al,al			; Zero ?
		jz	loc_149			; Jump if zero
		dec	al
		mov	cl,al
		mov	al,ds:data_105e
		and	al,9
		add	al,6Ch			; 'l'
		xor	ah,ah			; Zero register
		or	cl,cl			; Zero ?
		jz	loc_148			; Jump if zero
		add	ax,1Bh
loc_148:
		add	si,ax
		jmp	short loc_151
loc_149:
		mov	ax,1Bh
		test	byte ptr ds:data_105e,0FFh
		jnz	loc_150			; Jump if not zero
		mov	cl,byte ptr ds:[0E7h]
		cmp	cl,80h
		je	loc_150			; Jump if equal
		and	cl,3
		mov	al,9
		mul	cl			; ax = reg * al
loc_150:
		add	si,ax
loc_151:
		test	byte ptr ds:data_105e,0FFh
		jz	loc_152			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:data_67e,3
		jmp	short locloop_153
loc_152:
		mov	cx,9
		mov	byte ptr ds:data_67e,0
		jmp	short locloop_153

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_multiply_4		proc	near

locloop_153:
		push	cx
		mov	al,es:[si]
		or	al,al			; Zero ?
		jz	loc_154			; Jump if zero
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
		mov	ds,cs:data_98e
		mov	di,dx
		push	cs
		pop	es
		mov	al,cs:data_67e
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,529Fh
		mov	di,ax
		call	physsub_func_10
		pop	di
		pop	si
		pop	ds
		pop	es
loc_154:
		inc	si
		inc	byte ptr ds:data_67e
		pop	cx
		loop	locloop_153		; Loop if cx > 0

		retn
physsub_multiply_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_func_20		proc	near
		mov	al,byte ptr ds:[93h]
		or	al,al			; Zero ?
		jnz	loc_155			; Jump if not zero
		retn
loc_155:
		cmp	al,4
		mov	al,1
		jnc	loc_156			; Jump if carry=0
		retn
loc_156:
		mov	al,2
		retn
physsub_func_20		endp

loc_157:
		mov	al,[si]
		push	ds
		push	si
		push	di
		push	ax
		mov	ds,cs:data_98e
		push	cs
		pop	es
		mov	al,cs:data_67e
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,529Fh
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_158			; Jump if zero
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
loc_158:
		call	fill_buffer
		pop	di
		pop	si
		pop	ds
		retn
loc_159:
		push	ds
		push	si
		push	di
		mov	cl,al
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_160			; Jump if not sign
		call	physsub_get_value
loc_160:
		push	ax
		mov	bl,ds:data_69e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	dx,cs:data_60e[bx]
		mov	cs:data_61e,dx
		mov	al,cl
		mov	ch,10h
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		mov	bp,ax
		add	bp,0A000h
		mov	ds,cs:data_98e
		push	cs
		pop	es
		mov	al,cs:data_67e
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,529Fh
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_161			; Jump if zero
		mov	cl,al
		call	physsub_multiply_2
		pop	di
		pop	si
		pop	ds
		retn
loc_161:
		call	physsub_process_loop
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
		add	ax,ds:data_100e
		mov	si,ax
		call	physsub_func_39
		mov	di,data_81e
		push	cs
		pop	es
		mov	cx,3

locloop_162:
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	si,21h
		call	physsub_func_39
		loop	locloop_162		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_func_21		proc	near
		mov	al,ds:data_66e
		neg	al
		add	al,12h
		mov	cl,al
		test	byte ptr ds:data_113e,0FFh
		jnz	loc_164			; Jump if not zero
		mov	al,byte ptr ds:[84h]
		sub	al,2
		cmp	al,cl
		jne	loc_ret_163		; Jump if not equal
		call	physsub_func_26

loc_ret_163:
		retn
loc_164:
		mov	al,byte ptr ds:[84h]
		sub	al,5
		cmp	cl,al
		jae	loc_165			; Jump if above or =
		retn
loc_165:
		jnz	loc_166			; Jump if not zero
		call	physsub_func_22
		jmp	loc_192
loc_166:
		add	al,0Ah
		cmp	al,cl
		je	loc_167			; Jump if equal
		retn
loc_167:
		jmp	loc_184
			                        ;* No entry point to code
		test	byte ptr ds:data_113e,0FFh
		jnz	loc_168			; Jump if not zero
		retn
loc_168:
		push	es
		push	si
		push	di
		push	bx
		mov	es,cs:data_98e
		inc	byte ptr ds:data_116e
		mov	al,ds:data_115e
		or	al,al			; Zero ?
		jz	loc_172			; Jump if zero
		dec	al
		jz	loc_170			; Jump if zero
		cmp	byte ptr ds:data_116e,5
		jb	loc_169			; Jump if below
		jmp	loc_176
loc_169:
		xor	cl,cl			; Zero register
		mov	si,0B16Eh
		mov	word ptr ds:data_73e,0FF01h
		mov	dx,13Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_174			; Jump if not zero
		mov	si,0B0BEh
		mov	word ptr ds:data_73e,1
		mov	dx,140h
		jmp	short loc_174
loc_170:
		cmp	byte ptr ds:data_116e,5
		jb	loc_171			; Jump if below
		jmp	loc_176
loc_171:
		mov	bl,ds:data_116e
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B19Eh
		mov	si,0B12Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_173			; Jump if not zero
		mov	di,0B18Ah
		mov	si,0B07Eh
		jmp	short loc_173
loc_172:
		cmp	byte ptr ds:data_116e,7
		jae	loc_176			; Jump if above or =
		mov	bl,ds:data_116e
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B192h
		mov	si,0B0CEh
		test	byte ptr ds:[0C2h],1
		jnz	loc_173			; Jump if not zero
		mov	di,data_7e
		mov	si,0B01Eh
loc_173:
		mov	bx,es:[bx+di]
		mov	ds:data_73e,bx
		mov	al,bl
		cbw				; Convrt byte to word
		mov	dx,140h
		imul	dx			; dx:ax = reg * ax
		mov	dx,ax
		mov	al,bh
		cbw				; Convrt byte to word
		add	ax,ax
		add	dx,ax
loc_174:
		mov	di,ds:data_64e
		add	di,dx
		test	byte ptr ds:data_105e,0FFh
		jz	loc_175			; Jump if zero
		add	di,140h
loc_175:
		mov	ds:data_71e,di
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	si,cx
		mov	ds:data_72e,si
		pop	bx
		pop	di
		pop	si
		pop	es
		jmp	loc_184
loc_176:
		mov	byte ptr ds:data_113e,0
		mov	byte ptr ds:data_116e,0
		pop	bx
		pop	di
		pop	si
		pop	es
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_22:
		test	byte ptr ds:data_114e,0FFh
		jnz	loc_177			; Jump if not zero
		retn
loc_177:
		push	es
		push	di
		push	si
		push	bx
		call	physsub_func_24
		pop	bx
		pop	si
		pop	di
		pop	es
		mov	byte ptr ds:data_114e,0
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_23:
		push	ds
		push	cs
		pop	es
		mov	si,cs:data_71e
		mov	ax,0B800h
		mov	ds,ax
		mov	di,data_83e
		mov	cx,20h

locloop_178:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	si,1FF8h
		cmp	si,4000h
		jb	loc_179			; Jump if below
		add	si,0C050h
loc_179:
		loop	locloop_178		; Loop if cx > 0

		pop	ds
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_24:
		mov	di,cs:data_71e
		mov	ax,0B800h
		mov	es,ax
		mov	si,data_83e
		mov	cx,20h

locloop_180:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FF8h
		cmp	di,4000h
		jb	loc_181			; Jump if below
		add	di,0C050h
loc_181:
		loop	locloop_180		; Loop if cx > 0

		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_25:
		mov	al,byte ptr ds:[84h]
		add	al,ds:data_73e
		and	al,3Fh			; '?'
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,byte ptr ds:data_73e+1
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		mov	si,ax
		add	si,ds:data_100e
		call	physsub_func_39
		mov	cx,4

locloop_182:
		push	cx
		mov	cx,4

locloop_183:
		push	cx
		mov	bl,[si]
		inc	si
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	word ptr ds:data_82e[bx],0
		pop	cx
		loop	locloop_183		; Loop if cx > 0

		add	si,20h
		call	physsub_func_39
		pop	cx
		loop	locloop_182		; Loop if cx > 0

		retn
loc_184:
		test	byte ptr ds:data_113e,0FFh
		jnz	loc_185			; Jump if not zero
		retn
loc_185:
		mov	byte ptr ds:data_114e,0FFh
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	physsub_func_25
		call	physsub_func_23
		mov	ds,cs:data_98e
		mov	ax,0B800h
		mov	es,ax
		mov	di,cs:data_71e
		mov	si,cs:data_72e
		mov	cx,4

locloop_186:
		push	cx
		push	di
		mov	cx,4

locloop_187:
		push	cx
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_188			; Jump if not equal
		add	di,140h
		jmp	short loc_191
loc_188:
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,ds:data_6e
		mov	cx,8

locloop_189:
		push	cx
		lodsw				; String [si] to ax
		call	physsub_process_loop_2
		or	es:[di],ax
		add	di,2000h
		cmp	di,4000h
		jb	loc_190			; Jump if below
		add	di,data_90e
loc_190:
		pop	cx
		loop	locloop_189		; Loop if cx > 0

		pop	si
loc_191:
		pop	cx
		loop	locloop_187		; Loop if cx > 0

		pop	di
		inc	di
		inc	di
		pop	cx
		loop	locloop_186		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
			                        ;* No entry point to code
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		add	di,ax
		mov	ds:data_64e,di
		jmp	short loc_194

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_26:
loc_192:
		test	byte ptr ds:data_104e,0FFh
		jz	loc_193			; Jump if zero
		retn
loc_193:
		mov	byte ptr ds:data_104e,0FFh
loc_194:
		push	es
		push	ds
		push	si
		push	di
		push	bx
		mov	ax,0B800h
		mov	es,ax
		mov	si,data_84e
		mov	di,cs:data_64e
		mov	cx,3

locloop_195:
		push	cx
		mov	cx,3

locloop_196:
		push	cx
		push	di
		call	physsub_check_state
		pop	di
		inc	di
		inc	di
		pop	cx
		loop	locloop_196		; Loop if cx > 0

		add	di,13Ah
		pop	cx
		loop	locloop_195		; Loop if cx > 0

		pop	bx
		pop	di
		pop	si
		pop	ds
		pop	es
		retn
physsub_func_21		endp

			                        ;* No entry point to code
		push	ds
		push	si
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_98e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

locloop_197:
		push	cx
		lodsw				; String [si] to ax
		mov	bx,ax
		mov	dx,3
		mov	cx,8

locloop_198:
		test	bx,dx
		jz	loc_199			; Jump if zero
		or	bx,dx
loc_199:
		add	dx,dx
		add	dx,dx
		loop	locloop_198		; Loop if cx > 0

		not	bx
		and	es:[di],bx
		or	es:[di],ax
		add	di,2000h
		cmp	di,4000h
		jb	loc_200			; Jump if below
		add	di,0C050h
loc_200:
		pop	cx
		loop	locloop_197		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_114e,0
		mov	ax,0B800h
		mov	es,ax
		mov	byte ptr ds:data_76e,8
loc_201:
		mov	word ptr ds:data_63e,23Ch
		mov	byte ptr ds:data_97e,0
		mov	si,ds:data_100e
		mov	di,data_92e
		mov	cx,12h

locloop_202:
		push	cx
		add	si,4
		xor	bx,bx			; Zero register
		mov	cx,1Ch

locloop_203:
		push	cx
		lodsb				; String [si] to al
		call	physsub_multiply_5
		inc	di
		inc	bl
		pop	cx
		loop	locloop_203		; Loop if cx > 0

		add	si,4
		call	physsub_func_39
		add	word ptr ds:data_63e,140h
		pop	cx
		loop	locloop_202		; Loop if cx > 0

loc_204:
		cmp	byte ptr ds:data_97e,10h
		jb	loc_204			; Jump if below
		dec	byte ptr ds:data_76e
		jnz	loc_201			; Jump if not zero
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_multiply_5		proc	near
		cmp	byte ptr [di],0FFh
		jne	loc_205			; Jump if not equal
		retn
loc_205:
		cmp	byte ptr [di],0FCh
		jne	loc_206			; Jump if not equal
		retn
loc_206:
		push	ds
		push	di
		push	si
		push	bx
		push	ax
		mov	ah,ds:data_76e
		dec	ah
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sbb	ah,ah
		xor	ah,0CCh
		mov	cs:data_77e,ah
		add	bx,bx
		add	bx,ds:data_63e
		mov	di,bx
		pop	ax
		test	al,0FFh
		jz	loc_208			; Jump if zero
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_98e
		push	si
		push	di
		mov	al,cs:data_76e
		and	al,3
		neg	al
		add	al,3
		call	physsub_func_30
		call	physsub_func_28
		pop	di
		pop	si
		mov	al,cs:data_76e
		call	physsub_func_30
		inc	di
		inc	si
		call	physsub_func_28
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_28:
		mov	cx,2

locloop_207:
		mov	bl,cs:data_77e
		lodsb				; String [si] to al
		and	al,bl
		not	bl
		and	es:[di],bl
		or	es:[di],al
		add	di,0A0h
		add	si,7
		loop	locloop_207		; Loop if cx > 0

		retn
loc_208:
		push	di
		mov	al,cs:data_76e
		and	al,3
		neg	al
		add	al,3
		call	physsub_func_30
		call	physsub_get_value_2
		pop	di
		mov	al,cs:data_76e
		call	physsub_func_30
		inc	di
		call	physsub_get_value_2
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn
physsub_multiply_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_get_value_2		proc	near
		mov	al,cs:data_77e
		not	al
		and	es:[di],al
		add	di,data_117e
		and	es:[di],al
		retn
physsub_get_value_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_func_30		proc	near
		and	al,3
		xor	ah,ah			; Zero register
		push	ax
		add	ax,ax
		add	si,ax
		pop	ax
		or	ax,ax			; Zero ?
		jnz	loc_209			; Jump if not zero
		retn
loc_209:
		add	di,2000h
		cmp	di,4000h
		jb	loc_210			; Jump if below
		add	di,0C050h
loc_210:
		dec	ax
		jnz	loc_209			; Jump if not zero
		retn
physsub_func_30		endp

			                        ;* No entry point to code
		mov	al,byte ptr ds:[83h]
		add	al,al
		add	al,al
		add	al,al
		mov	ah,byte ptr ds:[84h]
		add	ah,ah
		add	ah,ah
		add	ah,ah
		mov	ds:data_61e,al
		mov	byte ptr ds:data_61e+1,ah
		call	physsub_scan_loop
		mov	byte ptr ds:data_76e,0AAh
		call	physsub_func_31
		mov	byte ptr ds:data_76e,0
		call	physsub_func_31
		jmp	loc_243

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_func_31		proc	near
		mov	al,ds:data_61e
		dec	al
		mov	bl,al
		add	al,19h
		mov	dl,al
		mov	al,byte ptr ds:data_61e+1
		dec	al
		mov	bh,al
		add	al,19h
		mov	dh,al
		call	physsub_func_32
		mov	al,ds:data_61e
		sub	al,5
		mov	bl,al
		add	al,21h			; '!'
		mov	dl,al
		mov	al,byte ptr ds:data_61e+1
		sub	al,5
		mov	bh,al
		add	al,21h			; '!'
		mov	dh,al
		call	physsub_func_32
		mov	al,ds:data_61e
		sub	al,9
		mov	bl,al
		add	al,29h			; ')'
		mov	dl,al
		mov	al,byte ptr ds:data_61e+1
		sub	al,9
		mov	bh,al
		add	al,29h			; ')'
		mov	dh,al

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_32:
		mov	cx,9

locloop_211:
		push	cx
		push	dx
		push	bx
		call	physsub_func_33
		pop	bx
		pop	dx
		sub	bl,0Ch
		jnc	loc_212			; Jump if carry=0
		xor	bl,bl			; Zero register
loc_212:
		sub	bh,0Ch
		jnc	loc_213			; Jump if carry=0
		xor	bh,bh			; Zero register
loc_213:
		add	dl,0Ch
		jnc	loc_214			; Jump if carry=0
		mov	dl,0FFh
loc_214:
		add	dh,0Ch
		jnc	loc_215			; Jump if carry=0
		mov	dh,0FFh
loc_215:
		push	dx
		push	bx
		call	physsub_multiply_6
		pop	bx
		pop	dx
		pop	cx
		loop	locloop_211		; Loop if cx > 0

		retn
physsub_func_31		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_func_33		proc	near
		mov	ax,0B800h
		mov	es,ax
		push	dx
		push	bx
		mov	dh,bh
		call	physsub_extract_bits
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	bh,dh
		call	physsub_extract_bits
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	dl,bl
		call	physsub_func_34
		pop	bx
		pop	dx
		mov	bl,dl

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

physsub_func_34:
		cmp	dh,bh
		jae	loc_216			; Jump if above or =
		xchg	dx,bx
loc_216:
		or	bl,bl			; Zero ?
		jnz	loc_217			; Jump if not zero
		retn
loc_217:
		cmp	bl,0DFh
		jb	loc_218			; Jump if below
		retn
loc_218:
		or	bh,bh			; Zero ?
		jnz	loc_219			; Jump if not zero
		mov	bh,1
loc_219:
		cmp	dh,8Fh
		jb	loc_220			; Jump if below
		mov	dh,8Eh
loc_220:
		mov	al,dh
		sub	al,bh
		inc	al
		push	ax
		mov	al,bh
		call	extract_bits_2
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		pop	cx
		xor	ch,ch			; Zero register
		and	bl,3
		jz	loc_223			; Jump if zero
		cmp	bl,2
		jb	loc_222			; Jump if below
		jz	loc_221			; Jump if zero
		mov	ah,3
		jmp	short loc_224
loc_221:
		mov	ah,0Ch
		jmp	short loc_224
loc_222:
		mov	ah,30h			; '0'
		jmp	short loc_224
loc_223:
		mov	ah,0C0h
loc_224:
		mov	al,ah
		not	al
		and	ah,ds:data_76e

locloop_225:
		and	es:[di],al
		or	es:[di],ah
		add	di,2000h
		cmp	di,4000h
		jb	loc_226			; Jump if below
		add	di,0C050h
loc_226:
		loop	locloop_225		; Loop if cx > 0

		retn
physsub_func_33		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_extract_bits		proc	near
		cmp	dl,bl
		jae	loc_227			; Jump if above or =
		xchg	dx,bx
loc_227:
		or	bh,bh			; Zero ?
		jnz	loc_228			; Jump if not zero
		retn
loc_228:
		cmp	bh,8Fh
		jb	loc_229			; Jump if below
		retn
loc_229:
		or	bl,bl			; Zero ?
		jnz	loc_230			; Jump if not zero
		mov	bl,1
loc_230:
		cmp	dl,0DFh
		jb	loc_231			; Jump if below
		mov	dl,0DEh
loc_231:
		mov	al,bh
		call	extract_bits_2
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
		jz	loc_234			; Jump if zero
		cmp	bl,2
		jb	loc_233			; Jump if below
		jz	loc_232			; Jump if zero
		mov	al,3
		jmp	short loc_235
loc_232:
		mov	al,0Fh
		jmp	short loc_235
loc_233:
		mov	al,3Fh			; '?'
		jmp	short loc_235
loc_234:
		mov	al,0FFh
loc_235:
		and	dl,3
		jz	loc_238			; Jump if zero
		cmp	dl,2
		jb	loc_237			; Jump if below
		jz	loc_236			; Jump if zero
		mov	ah,0FFh
		jmp	short loc_239
loc_236:
		mov	ah,0FCh
		jmp	short loc_239
loc_237:
		mov	ah,0F0h
		jmp	short loc_239
loc_238:
		mov	ah,0C0h
loc_239:
		jcxz	loc_241			; Jump if cx=0
		dec	cx
		jcxz	loc_240			; Jump if cx=0
		mov	dh,al
		not	dh
		and	al,ds:data_76e
		and	es:[di],dh
		or	es:[di],al
		inc	di
		mov	al,0FFh
		and	al,ds:data_76e
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	dh,ah
		not	dh
		and	ah,ds:data_76e
		and	es:[di],dh
		or	es:[di],ah
		retn
loc_240:
		mov	dh,al
		not	dh
		and	al,ds:data_76e
		and	es:[di],dh
		or	es:[di],al
		inc	di
		mov	dh,ah
		not	dh
		and	ah,ds:data_76e
		and	es:[di],dh
		or	es:[di],ah
		retn
loc_241:
		and	al,ah
		mov	dh,al
		not	dh
		and	al,ds:data_76e
		and	es:[di],dh
		or	es:[di],al
		retn
physsub_extract_bits		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

extract_bits_2		proc	near
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	ah,50h			; 'P'
		mul	ah			; ax = reg * al
		add	ax,23Ch
		add	di,ax
		retn
extract_bits_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_multiply_6		proc	near
		mov	cl,ds:data_101e
		shr	cl,1			; Shift w/zeros fill
		inc	cl
		mov	al,1
		mul	cl			; ax = reg * al
loc_242:
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		cmp	ds:data_97e,al
		jb	loc_242			; Jump if below
		mov	byte ptr ds:data_97e,0
		retn
physsub_multiply_6		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_scan_loop		proc	near
loc_243:
		mov	ax,0B800h
		mov	es,ax
		mov	di,data_118e
		mov	cx,8

locloop_244:
		push	cx
		push	di
		mov	cx,12h

locloop_245:
		push	cx
		push	di
		mov	ax,0FFFFh
		mov	cx,1Ch

locloop_246:
		xor	es:[di],ax
		inc	di
		inc	di
		loop	locloop_246		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_245		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_247			; Jump if below
		add	di,0C050h
loc_247:
		pop	cx
		loop	locloop_244		; Loop if cx > 0

		retn
physsub_scan_loop		endp

			                        ;* No entry point to code
		and	al,3Fh			; '?'
		mov	bl,ah
		xor	ah,ah			; Zero register
		mov	dx,140h
		mul	dx			; dx:ax = reg * ax
		sub	bl,4
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		mov	di,ax
		add	di,23Ch
		retn
			                        ;* No entry point to code
		mov	bl,byte ptr ds:[9Dh]
		or	bl,bl			; Zero ?
		jz	loc_248			; Jump if zero
		cmp	bl,7
		je	loc_248			; Jump if equal
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	es,cs:data_98e
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	si,[bx]
		mov	di,data_5e
		mov	cx,480h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
loc_248:
		mov	ds,cs:data_98e
		mov	si,8690h
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_func_39		proc	near
		cmp	si,0E900h
		jae	loc_249			; Jump if above or =
		retn
loc_249:
		sub	si,900h
		retn
physsub_func_39		endp

			                        ;* No entry point to code
		cmp	si,0E000h
		jb	loc_250			; Jump if below
		retn
loc_250:
		add	si,900h
		retn
			                        ;* No entry point to code
		push	si
		push	ds
		mov	si,data_54e
		mov	di,64Ch
		mov	ax,0B800h
		mov	es,ax
		mov	cx,5

locloop_251:
		push	cx
		mov	cx,1Ch

locloop_252:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	ds,cs:data_98e
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,4000h
		mov	si,ax
		push	di
		mov	cx,8

locloop_253:
		push	cx
		lodsw				; String [si] to ax
		not	ax
		call	physsub_process_loop_2
		not	ax
		and	ax,0AAAAh
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_254			; Jump if below
		add	di,0C050h
loc_254:
		pop	cx
		loop	locloop_253		; Loop if cx > 0

		pop	di
		inc	di
		inc	di
		pop	si
		pop	ds
		pop	cx
		loop	locloop_252		; Loop if cx > 0

		add	di,108h
		pop	cx
		loop	locloop_251		; Loop if cx > 0

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
		db	 3Fh, 06h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_process_loop_2		proc	near
		mov	dx,ax
		xor	ax,ax			; Zero register
		mov	cx,8

locloop_255:
		xor	bl,bl			; Zero register
		add	dx,dx
		adc	bl,bl
		add	dx,dx
		adc	bl,bl
		jz	loc_256			; Jump if zero
		mov	bl,3
loc_256:
		add	ax,ax
		add	ax,ax
		or	al,bl
		loop	locloop_255		; Loop if cx > 0

		retn
physsub_process_loop_2		endp

			                        ;* No entry point to code
		mov	ds:data_76e,al
		mov	si,data_56e
		mov	word ptr ds:data_63e,23Ch
		mov	cx,12h

locloop_257:
		push	cx
		mov	cx,1Ch

locloop_258:
		push	cx
		lodsb				; String [si] to al
		push	si
		call	physsub_multiply_7
		pop	si
		add	word ptr ds:data_63e,2
		pop	cx
		loop	locloop_258		; Loop if cx > 0

		add	word ptr ds:data_63e,108h
		pop	cx
		loop	locloop_257		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_multiply_7		proc	near
		push	ds
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:data_98e
		mov	ax,0B800h
		mov	es,ax
		mov	di,cs:data_63e
		mov	cx,8

locloop_259:
		push	cx
		lodsw				; String [si] to ax
		call	physsub_process_loop_3
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_260			; Jump if below
		add	di,0C050h
loc_260:
		pop	cx
		loop	locloop_259		; Loop if cx > 0

		pop	ds
		retn
physsub_multiply_7		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_process_loop_3		proc	near
		mov	cx,8

locloop_261:
		push	cx
		add	ax,ax
		adc	cl,cl
		add	ax,ax
		adc	cl,cl
		and	cl,3
		mov	bl,cs:data_76e
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_55e[bx]	;*
		add	dx,dx
		add	dx,dx
		or	dl,cl
		pop	cx
		loop	locloop_261		; Loop if cx > 0

		mov	ax,dx
		retn
physsub_process_loop_3		endp

			                        ;* No entry point to code
		add	word ptr [bx-7Eh],9347h
		inc	di
		movsb				; Mov [si] to es:[di]
		inc	di
		mov	ch,47h			; 'G'
		retn
			                        ;* No entry point to code
		cmp	cl,1
		jne	loc_262			; Jump if not equal
		mov	cl,2
		retn
loc_262:
		cmp	cl,2
		je	loc_263			; Jump if equal
		retn
loc_263:
		mov	cl,1
		retn
			                        ;* No entry point to code
		cmp	cl,1
		jne	loc_264			; Jump if not equal
		mov	cl,0
		retn
loc_264:
		cmp	cl,2
		je	loc_265			; Jump if equal
		retn
loc_265:
		mov	cl,1
		retn
			                        ;* No entry point to code
		cmp	cl,2
		jne	loc_266			; Jump if not equal
		mov	cl,3
		retn
loc_266:
		cmp	cl,3
		je	loc_267			; Jump if equal
		retn
loc_267:
		mov	cl,2
		retn
			                        ;* No entry point to code
		cmp	cl,1
		je	loc_268			; Jump if equal
		retn
loc_268:
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
		sbb	ds:data_86e,bh
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
		db	 1Eh, 50h,0D0h,0EBh, 1Bh,0FFh
		db	 81h,0E7h, 00h, 20h,0B0h, 50h
		db	0F6h,0E3h, 8Ah,0DFh, 32h,0FFh
		db	 03h,0C3h, 03h,0F8h, 58h,0B1h
		db	 10h,0F6h,0E1h, 05h, 00h, 60h
		db	 8Bh,0F0h, 2Eh, 8Eh, 1Eh, 2Ch
		db	0FFh,0B8h, 00h,0B8h, 8Eh,0C0h
		db	0B9h, 04h, 00h

locloop_269:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_270			; Jump if below
		add	di,data_90e
loc_270:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_271			; Jump if below
		add	di,0C050h
loc_271:
		loop	locloop_269		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_57e[bx]
		mov	di,data_119e
		mov	ax,0B800h
		mov	es,ax
		mov	cx,18h

locloop_272:
		lodsw				; String [si] to ax
		or	es:[di],ax
		lodsw				; String [si] to ax
		or	es:[di+2],ax
		add	di,2000h
		cmp	di,4000h
		jb	loc_273			; Jump if below
		add	di,data_90e
loc_273:
		loop	locloop_272		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		inc	si
		dec	dx
		inc	si
		dec	dx
		inc	si
		dec	dx
		cmpsb				; Cmp [si] to es:[di]
		dec	dx
		cmpsb				; Cmp [si] to es:[di]
		dec	dx
		push	es
		dec	bx
		db	45 dup (0)
		db	 03h, 00h, 00h, 00h, 0Ch, 00h
		db	 00h, 00h, 0Ch, 00h, 00h, 00h
		db	 3Ch, 00h, 00h, 00h, 3Ch, 00h
		db	 00h, 00h, 3Ch, 00h, 00h, 00h
		db	 3Ch, 00h, 00h, 00h, 3Ch, 00h
		db	 00h, 00h, 0Ch, 00h, 00h, 00h
		db	 3Ch, 00h, 00h, 00h, 3Ch, 00h
		db	 00h, 00h, 3Ch, 00h, 00h, 00h
		db	 3Ch, 00h
		db	7 dup (0)
		db	 0Ch, 00h, 00h, 00h, 3Ch, 00h
		db	 00h, 00h,0F0h, 00h, 00h, 00h
		db	0F0h, 00h, 00h, 00h,0F0h, 00h
		db	 00h, 03h,0F0h, 00h, 00h, 03h
		db	0C0h, 00h, 00h, 03h,0C0h, 00h
		db	 00h, 03h,0C0h, 00h, 00h, 0Fh
		db	0C0h, 00h, 00h, 0Fh, 00h, 00h
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 0Fh, 00h, 00h
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 0Fh, 00h, 00h
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 0Fh, 00h, 00h
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h
		db	3Fh
		db	12 dup (0)
		db	0C0h, 00h, 00h, 00h,0C0h, 00h
		db	 00h, 00h,0C0h, 00h, 00h, 03h
		db	0C0h, 00h, 00h, 03h,0C0h, 00h
		db	 00h, 0Fh,0C0h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 0Fh, 00h, 00h
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 0Fh, 00h, 00h
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 3Fh, 00h, 00h
		db	 00h, 3Fh, 00h, 00h, 00h, 3Fh
		db	 00h, 00h, 00h, 3Fh, 00h, 00h
		db	 00h, 3Fh, 00h, 00h, 00h, 3Fh
		db	 00h, 00h, 00h, 3Ch, 00h, 00h
		db	 03h, 3Ch,0C0h, 00h, 00h,0FFh
		db	 00h, 00h, 1Eh, 0Ah,0C0h, 78h
		db	 10h, 24h, 03h,0B2h, 40h,0F6h
		db	0E2h, 05h,0F5h, 4Bh, 8Bh,0F0h
		db	0BDh, 01h, 00h,0EBh, 0Eh, 24h
		db	 01h, 8Ah,0E0h, 32h,0C0h, 05h
		db	0F5h, 4Ch, 8Bh,0F0h,0BDh, 04h
		db	 00h, 8Ah,0C3h, 24h, 03h, 02h
		db	0C0h,0A2h, 81h, 50h,0D1h,0EBh
		db	0D1h,0EBh,0D0h,0E9h, 1Bh,0FFh
		db	 81h,0E7h, 00h, 20h,0B0h, 50h
		db	0F6h,0E1h, 03h,0C3h, 03h,0F8h
		db	0B8h, 00h,0B8h, 8Eh,0C0h, 8Bh
		db	0CDh

locloop_274:
		push	cx
		push	di
		mov	cx,10h

locloop_275:
		push	cx
		push	di
		mov	cx,2

locloop_276:
		push	cx
		lodsw				; String [si] to ax
		mov	bh,al
		xor	bl,bl			; Zero register
		mov	cl,cs:data_77e
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
		loop	locloop_276		; Loop if cx > 0

		pop	di
		add	di,2000h
		cmp	di,4000h
		jb	loc_277			; Jump if below
		add	di,0C050h
loc_277:
		pop	cx
		loop	locloop_275		; Loop if cx > 0

		pop	di
		add	di,4
		pop	cx
		loop	locloop_274		; Loop if cx > 0

		pop	ds
		retn
		db	22 dup (0)
		db	 30h, 00h, 00h, 30h,0F0h, 00h
		db	 00h, 0Fh,0C0h, 00h, 00h, 0Fh
		db	0C0h, 00h, 00h, 0Fh,0C0h, 00h
		db	 00h, 0Ch, 30h, 00h, 00h, 30h
		db	 00h
		db	26 dup (0)
		db	 03h, 00h, 00h, 00h, 03h, 00h
		db	 00h, 00h,0C0h, 0Ch, 00h, 00h
		db	 03h, 00h, 00h, 00h, 1Bh, 30h
		db	 00h, 00h, 03h,0C0h, 00h, 0Ch
		db	0FFh,0FCh,0C0h, 00h, 03h,0C0h
		db	 00h, 00h, 33h, 30h, 00h, 00h
		db	 03h, 00h, 00h, 00h,0C0h, 0Ch
		db	 00h, 00h, 03h, 00h, 00h, 00h
		db	 03h
		db	7 dup (0)
		db	 03h, 00h, 00h, 00h, 03h, 00h
		db	 00h, 00h, 03h, 00h, 00h, 00h
		db	 0Ch,0C0h, 00h, 00h, 03h,0C0h
		db	 00h, 00h, 33h,0CCh, 00h, 00h
		db	 0Ch,0C0h, 00h, 00h, 33h,0CCh
		db	 00h,0CFh,0FFh,0FFh,0F3h, 00h
		db	 33h,0CCh, 00h, 00h, 0Fh, 30h
		db	 00h, 00h, 33h, 0Ch, 00h, 00h
		db	 0Ch,0C0h, 00h, 00h, 03h, 00h
		db	 00h, 00h, 03h, 00h, 00h, 00h
		db	 03h, 00h
		db	8 dup (0)
		db	 30h, 30h, 00h, 00h, 00h, 0Ch
		db	 00h, 00h,0C0h, 00h,0C0h, 03h
		db	 00h, 00h,0F3h, 0Ch, 00h, 00h
		db	 3Fh, 3Ch, 00h, 00h, 0Fh,0F0h
		db	 00h, 00h, 3Fh,0F3h, 00h, 00h
		db	 0Fh,0F0h, 00h, 00h, 0Fh, 3Ch
		db	 00h, 00h, 33h, 0Ch, 00h, 00h
		db	0C3h, 03h,0C0h, 03h, 00h, 00h
		db	 30h, 0Ch, 00h, 00h, 0Ch, 30h
		db	 00h
		db	34 dup (0)
		db	0CFh,0FFh,0FFh,0FFh, 00h
		db	34 dup (0)
		db	 03h, 00h, 00h, 00h, 03h, 00h
		db	 00h, 03h, 03h, 00h, 00h, 00h
		db	0C3h, 00h, 00h, 00h,0FFh, 00h
		db	 00h, 03h,0FFh, 0Ch,0CCh,0FFh
		db	0FFh,0FFh,0FFh,0FFh,0FFh, 0Ch
		db	0CCh,0FFh,0FFh, 00h, 00h, 03h
		db	0FFh, 00h, 00h, 00h,0C3h, 00h
		db	 00h, 00h,0C3h, 00h, 00h, 00h
		db	 03h, 00h, 00h, 00h, 03h
		db	20 dup (0)
		db	0C3h, 00h, 00h, 00h,0CCh, 00h
		db	 00h, 00h,0FCh, 00h, 00h, 00h
		db	0FFh,0FFh,0FCh, 30h,0FFh,0FFh
		db	0FFh,0FFh,0FFh,0FFh, 3Ch, 30h
		db	0FFh,0C0h, 00h, 00h,0FFh, 00h
		db	 00h, 00h,0C0h,0C0h, 00h, 00h
		db	 00h
		db	30h
		db	42 dup (0)
		db	0FFh,0FFh,0FFh,0CFh
		db	60 dup (0)
		db	0CFh,0CCh,0CCh, 0Ch, 00h
		db	37 dup (0)
		db	 30h, 00h, 00h, 00h, 0Ch, 00h
		db	 00h, 00h, 00h, 80h, 00h, 00h
		db	 00h,0F3h, 00h, 00h, 00h, 3Fh
		db	 00h, 00h, 00h, 0Fh, 30h, 0Ch
		db	 00h,0FFh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 3Fh, 00h, 00h
		db	 00h, 33h, 00h, 00h, 00h,0C3h
		db	 00h, 00h, 03h, 00h, 00h, 00h
		db	 0Ch, 00h, 00h, 00h, 30h, 00h
		db	 00h, 00h, 00h, 00h, 00h
		db	30h
		db	7 dup (0)
		db	0C0h, 00h, 00h, 03h, 00h, 00h
		db	 00h, 0Ch, 00h, 00h, 00h, 30h
		db	 00h, 00h, 00h,0F0h, 00h, 00h
		db	 00h,0F3h, 03h, 00h, 30h,0F0h
		db	 00h, 00h, 00h, 3Ch, 00h, 00h
		db	 00h, 0Fh, 00h, 00h, 00h, 00h
		db	0C0h, 00h, 00h, 00h, 30h, 00h
		db	 00h, 00h
		db	0Ch
		db	38 dup (0)
		db	 60h, 0Fh, 3Fh,0F3h
		db	28 dup (0)
		db	 51h, 1Eh, 56h, 8Ch,0C8h, 05h
		db	 00h, 30h, 8Eh,0C0h,0B8h, 20h
		db	 00h,0F7h,0E1h, 8Bh,0C8h,0BFh
		db	 00h, 00h,0F3h,0A4h, 5Fh, 07h
		db	 59h, 8Ch,0C8h, 05h, 00h, 30h
		db	 8Eh,0D8h,0BEh, 00h, 00h

locloop_278:
		push	cx
		mov	cx,8

locloop_279:
		push	cx
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsw				; String [si] to ax
		mov	cx,ax
		mov	cs:data_63e,dx
		mov	cs:data_65e,cx
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
		mov	cs:data_75e,ax
		call	physsub_process_loop_4
		mov	ax,dx
		stosw				; Store ax to es:[di]
		call	physsub_scan_loop_2
		mov	es:[bp],dx
		inc	bp
		inc	bp
		pop	cx
		loop	locloop_279		; Loop if cx > 0

		pop	cx
		loop	locloop_278		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_process_loop_4		proc	near
		mov	cx,8

locloop_280:
		xor	bx,bx			; Zero register
		rol	word ptr cs:data_65e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_63e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_65e,1	; Rotate
		adc	bx,bx
		rol	word ptr cs:data_63e,1	; Rotate
		adc	bx,bx
		add	dx,dx
		add	dx,dx
		or	dl,cs:data_58e[bx]
		loop	locloop_280		; Loop if cx > 0

		retn
physsub_process_loop_4		endp

		db	0, 1, 2, 1, 1, 3
		db	3, 1, 2, 3, 2, 2
		db	1, 1, 2, 3

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

physsub_scan_loop_2		proc	near
		mov	cx,8

locloop_281:
		xor	al,al			; Zero register
		rol	word ptr cs:data_75e,1	; Rotate
		adc	al,al
		rol	word ptr cs:data_75e,1	; Rotate
		adc	al,al
		cmp	al,3
		je	loc_282			; Jump if equal
		xor	al,al			; Zero register
loc_282:
		add	dx,dx
		add	dx,dx
		or	dl,al
		loop	locloop_281		; Loop if cx > 0

		retn
physsub_scan_loop_2		endp

			                        ;* No entry point to code
		push	ds
		push	cs
		pop	ds
		mov	si,data_59e
		mov	es,cs:data_98e
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
		sbb	dx,[bx+si+2Bh]
		push	ax
		cmp	dx,[bx+si+4Bh]
		push	ax
		pop	bx
		push	ax
		dec	bx
		push	ax
		add	[bx+di],al
		add	al,[bp+di]
		add	al,5
		push	es
		pop	es
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
