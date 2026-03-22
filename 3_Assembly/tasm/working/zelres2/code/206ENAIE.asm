
PAGE  59,132

;==========================================================================
;
;  ENEMY_AI - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	4000h			;*
data_2e		equ	6000h			;*
data_3e		equ	6333h			;*
data_4e		equ	9350h			;*
data_5e		equ	0B000h			;*
data_6e		equ	0B17Eh			;*
data_7e		equ	0D000h			;*
data_55e	equ	2939h			;*
data_56e	equ	3176h			;*
data_57e	equ	3893h			;*
data_58e	equ	389Bh			;*
data_59e	equ	3963h			;*
data_60e	equ	3F38h			;*
data_61e	equ	4086h			;*
data_62e	equ	4588h			;*
data_63e	equ	46D4h			;*
data_64e	equ	4A25h			;*
data_65e	equ	4F8Ch			;*
data_66e	equ	4FE9h			;*
data_68e	equ	4FEBh			;*
data_69e	equ	4FEDh			;*
data_70e	equ	4FEFh			;*
data_71e	equ	4FF1h			;*
data_72e	equ	4FF2h			;*
data_73e	equ	4FF3h			;*
data_74e	equ	4FF4h			;*
data_75e	equ	4FF5h			;*
data_77e	equ	4FF7h			;*
data_78e	equ	4FF9h			;*
data_79e	equ	4FFBh			;*
data_81e	equ	4FFDh			;*
data_82e	equ	4FFFh			;*
data_83e	equ	5000h			;*
data_84e	equ	5010h			;*
data_85e	equ	5011h			;*
data_86e	equ	5014h			;*
data_87e	equ	501Dh			;*
data_88e	equ	511Dh			;*
data_89e	equ	625Ch			;*
data_90e	equ	0A030h			;*
data_91e	equ	0C010h			;*
data_92e	equ	0C012h			;*
data_93e	equ	0E000h			;*
data_94e	equ	0E900h			;*
data_95e	equ	0E91Bh			;*
data_96e	equ	0ED20h			;*
data_97e	equ	0EDA0h			;*
data_98e	equ	0FA00h			;*
data_99e	equ	0FF1Ah			;*
data_100e	equ	0FF2Ch			;*
data_101e	equ	0FF2Fh			;*
data_102e	equ	0FF31h			;*
data_103e	equ	0FF33h			;*
data_104e	equ	0FF34h			;*
data_105e	equ	0FF35h			;*
data_106e	equ	0FF36h			;*
data_107e	equ	0FF37h			;*
data_108e	equ	0FF38h			;*
data_109e	equ	0FF39h			;*
data_110e	equ	0FF3Ah			;*
data_111e	equ	0FF3Dh			;*
data_112e	equ	0FF3Fh			;*
data_113e	equ	0FF40h			;*
data_114e	equ	0FF41h			;*
data_115e	equ	0FF42h			;*
data_116e	equ	0FF43h			;*
data_117e	equ	0FF44h			;*
data_118e	equ	0FF45h			;*
data_119e	equ	0FF46h			;*
data_120e	equ	138h
data_121e	equ	500h
data_122e	equ	11B0h
data_123e	equ	0FA00h
data_124e	equ	0FA40h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_06		proc	far

start:
		pop	bp
		and	ax,[bx+si]
		add	[si],ch
		xor	ds:data_55e[bx+di],bh
		aas				; Ascii adjust
		xor	al,3Eh			; '>'
		das				; Decimal adjust
		inc	cx
		lodsw				; String [si] to ax
		inc	sp
		sar	byte ptr [bx],1		; Shift w/sign fill
		jc	loc_1			; Jump if carry Set
		db	 9Bh, 37h, 92h, 41h,0F0h, 40h
		db	0A3h, 39h,0F7h, 42h,0CEh, 44h
		db	 18h, 45h, 14h, 46h,0D7h, 40h
		db	 33h, 49h, 90h, 49h, 51h, 4Bh
		db	0DDh, 4Eh,0E8h, 4Fh, 0Eh, 07h
		db	0BFh, 1Dh, 50h, 33h,0C0h,0B9h
data_8		dw	80h
		db	0F3h,0ABh
data_9		db	0FEh
		db	 06h,0FFh, 4Fh,0C7h, 06h,0EBh
		db	 4Fh,0B0h, 11h
loc_1:
		mov	si,ds:data_102e
		sub	si,21h
		call	ai_func_45
		xor	bx,bx			; Zero register
		test	byte ptr [si],80h
		jz	loc_2			; Jump if zero
		call	ai_func_3
loc_2:
		inc	si
		mov	cx,6

locloop_3:
		push	cx
		test	byte ptr [si],80h
		jz	loc_4			; Jump if zero
		call	ai_func_4
loc_4:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_5			; Jump if zero
		call	ai_func_4
loc_5:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_6			; Jump if zero
		call	ai_func_4
loc_6:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_7			; Jump if zero
		call	ai_func_4
loc_7:
		inc	si
		inc	bx
		pop	cx
		loop	locloop_3		; Loop if cx > 0

		test	byte ptr [si],80h
		jz	loc_8			; Jump if zero
		call	ai_func_4
loc_8:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_9			; Jump if zero
		call	ai_func_4
loc_9:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_10			; Jump if zero
		call	ai_func_4
loc_10:
		inc	si
		test	byte ptr [si],80h
		jz	loc_11			; Jump if zero
		call	ai_func_5
loc_11:
		mov	si,ds:data_102e
		mov	di,0E900h
		mov	byte ptr ds:data_71e,12h
loc_12:
		call	vga_operation5
		xor	bx,bx			; Zero register
		add	si,3
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jns	loc_13			; Jump if not sign
		call	ai_func_6
loc_13:
		mov	cx,6

locloop_14:
		push	cx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_15			; Jump if zero
		call	ai_func_1
loc_15:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_16			; Jump if zero
		call	ai_func_1
loc_16:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_17			; Jump if zero
		call	ai_func_1
loc_17:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_18			; Jump if zero
		call	ai_func_1
loc_18:
		inc	bx
		pop	cx
		loop	locloop_14		; Loop if cx > 0

		cmpsb				; Cmp [si] to es:[di]
		jz	loc_19			; Jump if zero
		call	ai_func_1
loc_19:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_20			; Jump if zero
		call	ai_func_1
loc_20:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_21			; Jump if zero
		call	ai_func_1
loc_21:
		inc	bx
		lodsb				; String [si] to al
		inc	di
		or	al,al			; Zero ?
		jns	loc_22			; Jump if not sign
		jmp	loc_62
loc_22:
		cmp	al,es:[di-1]
		je	loc_23			; Jump if equal
		call	ai_func_1
loc_23:
		add	si,4
		call	ai_func_44
		add	word ptr ds:data_68e,0A00h
		dec	byte ptr ds:data_71e
		jnz	loc_12			; Jump if not zero
		retn

zr2_06		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_func_1		proc	near
		mov	al,[si-1]
		or	al,al			; Zero ?
		jns	loc_24			; Jump if not sign
		jmp	loc_60
loc_24:
		cmp	byte ptr es:[di-1],0FCh
		jne	loc_25			; Jump if not equal
		mov	byte ptr es:[di-1],0FFh
		jmp	short loc_26
loc_25:
		inc	byte ptr es:[di-1]
		mov	byte ptr es:[di-1],0FEh
		jz	loc_26			; Jump if zero
		mov	es:[di-1],al
		mov	dx,bx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		add	dx,ds:data_68e
		shr	dx,1			; Shift w/zeros fill
		call	vga_operation
loc_26:
		mov	al,ds:data_92e
		sub	al,5
		jnc	loc_27			; Jump if carry=0
		retn
loc_27:
		cmp	al,4
		jb	loc_28			; Jump if below
		retn
loc_28:
		push	bx
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:data_56e[bx]	;*
		pop	bx
		retn
ai_func_1		endp

			                        ;* No entry point to code
;*		jle	loc_32			;*Jump if < or =
		db	 7Eh, 31h		;  Fixup - byte match
		sahf				; Store ah into flags
;*		xor	sp,dx
		db	 31h,0D4h		;  Fixup - byte match
		xor	[bp+si+32h],dx
		mov	al,[si-1]
		sub	al,1Bh
		cmp	al,2
		jb	loc_29			; Jump if below
		retn
loc_29:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_82e,1
		jnz	loc_30			; Jump if not zero
		retn
loc_30:
		inc	al
		and	al,1
		add	al,1Bh
		mov	[si-1],al
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,1Dh
		cmp	al,6
		jb	loc_31			; Jump if below
		retn
loc_31:
		mov	byte ptr [di-1],0FEh
		cmp	al,4
		jae	loc_34			; Jump if above or =
		or	al,al			; Zero ?
		jnz	loc_33			; Jump if not zero
		push	ax
		call	word ptr cs:[11Ah]
		and	al,3
		pop	ax
		jz	loc_33			; Jump if zero
		retn
loc_33:
		inc	al
		and	al,3
		add	al,1Dh
		mov	[si-1],al
		retn
loc_34:
		inc	al
		and	al,1
		add	al,21h			; '!'
		mov	[si-1],al
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,2Ch			; ','
		cmp	al,2
		jae	loc_36			; Jump if above or =
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_82e,1
		jnz	loc_35			; Jump if not zero
		retn
loc_35:
		inc	al
		and	al,1
		add	al,2Ch			; ','
		mov	[si-1],al
		retn
loc_36:
		mov	al,[si-1]
		cmp	al,3Eh			; '>'
		jb	loc_37			; Jump if below
		retn
loc_37:
		mov	bl,33h			; '3'
		cmp	al,0Eh
		je	loc_39			; Jump if equal
		mov	bl,36h			; '6'
		cmp	al,0Dh
		je	loc_39			; Jump if equal
		mov	bl,39h			; '9'
		cmp	al,0Fh
		je	loc_39			; Jump if equal
		mov	bl,3Ch			; '<'
		cmp	al,0Ch
		je	loc_39			; Jump if equal
		mov	bl,3Dh			; '='
		cmp	al,10h
		je	loc_39			; Jump if equal
		sub	al,33h			; '3'
		jnc	loc_38			; Jump if carry=0
		retn
loc_38:
		mov	bl,0Eh
		cmp	al,2
		je	loc_39			; Jump if equal
		mov	bl,0Dh
		cmp	al,5
		je	loc_39			; Jump if equal
		mov	bl,0Fh
		cmp	al,8
		je	loc_39			; Jump if equal
		mov	bl,0Ch
		cmp	al,9
		je	loc_39			; Jump if equal
		mov	bl,10h
		cmp	al,0Ah
		je	loc_39			; Jump if equal
		inc	al
		add	al,33h			; '3'
		mov	bl,al
loc_39:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_82e,1
		jnz	loc_40			; Jump if not zero
		retn
loc_40:
		mov	[si-1],bl
		retn
			                        ;* No entry point to code
		mov	al,[si-1]
		sub	al,25h			; '%'
		cmp	al,4
		jb	loc_41			; Jump if below
		retn
loc_41:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:data_82e,1
		jnz	loc_42			; Jump if not zero
		retn
loc_42:
		inc	al
		and	al,3
		add	al,25h			; '%'
		mov	[si-1],al
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation		proc	near
		push	es
		push	ds
		push	di
		push	si
		push	bx
		add	dx,dx
		mov	di,dx
		or	al,al			; Zero ?
		jnz	loc_43			; Jump if not zero
		jmp	loc_48
loc_43:
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:data_87e[bx],0FFFFh
		jnz	loc_46			; Jump if not zero
		dec	al
		mov	ds:data_87e[bx],di
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_100e
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

locloop_44:
		push	cx
		mov	cx,2

locloop_45:
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsb				; String [si] to al
		mov	bl,al
		mov	bh,dl
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		mov	es:[di],dh
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		mov	es:[di+1],dl
		add	bx,bx
		add	bx,bx
		and	bh,3Fh			; '?'
		mov	es:[di+2],bh
		and	al,3Fh			; '?'
		mov	es:[di+3],al
		add	di,4
		loop	locloop_45		; Loop if cx > 0

		add	di,data_120e
		pop	cx
		loop	locloop_44		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_46:
		mov	si,ds:data_87e[bx]
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	cx,8

locloop_47:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,data_120e
		add	si,138h
		loop	locloop_47		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_48:
		mov	ax,0A000h
		mov	es,ax
		xor	ax,ax			; Zero register
		mov	cx,8

locloop_49:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,138h
		loop	locloop_49		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
vga_operation		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_func_3		proc	near
		cmp	byte ptr ds:data_94e,0FFh
		jne	loc_50			; Jump if not equal
		retn
loc_50:
		cmp	byte ptr ds:data_94e,0FCh
		jne	loc_51			; Jump if not equal
		retn
loc_51:
		push	si
		push	bx
		mov	byte ptr ds:data_94e,0FFh
		mov	cl,[si]
		add	si,25h
		call	ai_func_44
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_52			; Jump if not sign
		call	ai_get_value
loc_52:
		push	ax
		mov	al,cl
		call	vga_operation0
		add	si,3
		pop	ax
		mov	ah,[si]
		mov	dx,11B0h
		call	ai_func_9
		pop	bx
		pop	si
		retn
ai_func_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_func_4		proc	near
		push	si
		push	bx
		mov	cx,bx
		mov	di,bx
		add	di,data_94e
		mov	bx,data_84e
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	byte ptr [bx+1],0
		mov	byte ptr [di+1],0FFh
		mov	dx,cx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		add	dx,11B0h
		mov	cl,[si]
		add	si,24h
		call	ai_func_44
		mov	bx,data_86e
		lodsw				; String [si] to ax
		mov	[bx],ax
		mov	al,cl
		call	vga_operation0
		inc	si
		inc	si
		mov	di,data_86e
		mov	bp,data_84e
		call	ai_func_7
		pop	bx
		pop	si
		retn
ai_func_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_func_5		proc	near
		cmp	byte ptr ds:data_95e,0FFh
		jne	loc_53			; Jump if not equal
		retn
loc_53:
		cmp	byte ptr ds:data_95e,0FCh
		jne	loc_54			; Jump if not equal
		retn
loc_54:
		mov	byte ptr ds:data_95e,0FFh
		mov	cl,[si]
		add	si,24h
		call	ai_func_44
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_55			; Jump if not sign
		call	ai_get_value
loc_55:
		push	ax
		mov	al,cl
		call	vga_operation0
		add	si,2
		pop	ax
		mov	ah,[si]
		mov	dx,1288h
		jmp	loc_69

;���� External Entry into Subroutine ��������������������������������������

ai_func_6:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_84e
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	al,0FFh
		xchg	[di+1Ch],al
		mov	[bx+1],al
		mov	cl,[si-1]
		mov	dl,[si]
		add	si,24h
		call	ai_func_44
		mov	dh,[si]
		mov	al,cl
		call	vga_operation0
		inc	si
		mov	bx,dx
		pop	dx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		add	dx,ds:data_68e
		cmp	byte ptr ds:data_84e,0FFh
		je	loc_57			; Jump if equal
		cmp	byte ptr ds:data_84e,0FCh
		je	loc_57			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_56			; Jump if not sign
		call	ai_get_value
loc_56:
		call	ai_func_9
		pop	dx
		pop	si
		pop	bx
loc_57:
		add	dx,0A00h
		cmp	byte ptr ds:data_71e,1
		je	loc_59			; Jump if equal
		cmp	byte ptr ds:data_85e,0FFh
		je	loc_59			; Jump if equal
		cmp	byte ptr ds:data_85e,0FCh
		je	loc_59			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_58			; Jump if not sign
		call	ai_get_value
loc_58:
		call	ai_func_9
loc_59:
		pop	bx
		pop	di
		pop	si
		retn
loc_60:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_84e
		mov	ax,0FFFEh
		xchg	[di-1],ax
		mov	[bx],ax
		mov	ax,0FFFFh
		xchg	[di+1Bh],ax
		mov	[bx+2],ax
		mov	cl,[si-1]
		mov	bx,data_86e
		mov	al,[si]
		mov	[bx+1],al
		add	si,24h
		call	ai_func_44
		mov	ax,[si-1]
		mov	[bx+2],ax
		pop	dx
		mov	ds:data_72e,dl
		mov	al,ds:data_71e
		neg	al
		add	al,12h
		mov	ds:data_73e,al
		add	dx,dx
		add	dx,dx
		add	dx,dx
		add	dx,ds:data_68e
		mov	al,cl
		call	vga_operation0
		mov	di,data_86e
		mov	[di],al
		mov	bp,data_84e
		call	ai_func_7
		cmp	byte ptr ds:data_71e,1
		je	loc_61			; Jump if equal
		add	dx,9F0h
		call	ai_func_7
		test	byte ptr ds:data_104e,0FFh
		jz	loc_61			; Jump if zero
		test	byte ptr ds:data_101e,0FFh
		jz	loc_61			; Jump if zero
		call	vga_operation1
loc_61:
		pop	bx
		pop	di
		pop	si
		retn
loc_62:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,data_84e
		mov	al,0FEh
		xchg	[di-1],al
		mov	[bx],al
		mov	al,0FFh
		xchg	[di+1Bh],al
		mov	[bx+1],al
		mov	cl,[si-1]
		add	si,24h
		call	ai_func_44
		mov	dl,[si-1]
		mov	al,cl
		call	vga_operation0
		mov	bl,al
		mov	bh,dl
		pop	dx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		add	dx,ds:data_68e
		cmp	byte ptr ds:data_84e,0FFh
		je	loc_64			; Jump if equal
		cmp	byte ptr ds:data_84e,0FCh
		je	loc_64			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_63			; Jump if not sign
		call	ai_get_value
loc_63:
		call	ai_func_9
		pop	dx
		pop	si
		pop	bx
loc_64:
		add	dx,0A00h
		cmp	byte ptr ds:data_71e,1
		je	loc_66			; Jump if equal
		cmp	byte ptr ds:data_85e,0FFh
		je	loc_66			; Jump if equal
		cmp	byte ptr ds:data_85e,0FCh
		je	loc_66			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_65			; Jump if not sign
		call	ai_get_value
loc_65:
		call	ai_func_9
loc_66:
		pop	bx
		pop	di
		pop	si
		jmp	loc_23

;���� External Entry into Subroutine ��������������������������������������

ai_func_7:
		call	ai_func_8

;���� External Entry into Subroutine ��������������������������������������

ai_func_8:
		cmp	byte ptr ds:[bp],0FFh
		je	loc_68			; Jump if equal
		cmp	byte ptr ds:[bp],0FCh
		je	loc_68			; Jump if equal
		mov	ah,[si]
		mov	al,[di]
		or	al,al			; Zero ?
		jns	loc_67			; Jump if not sign
		call	ai_get_value
loc_67:
		push	bp
		push	si
		push	di
		push	dx
		call	ai_func_9
		pop	dx
		pop	di
		pop	si
		pop	bp
loc_68:
		inc	si
		inc	di
		inc	bp
		add	dx,8
		retn

;���� External Entry into Subroutine ��������������������������������������

ai_func_9:
loc_69:
		push	es
		push	ds
		mov	bl,ds:data_74e
		or	al,al			; Zero ?
		jz	loc_70			; Jump if zero
		js	loc_70			; Jump if sign=1
		or	bl,80h
loc_70:
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
		mov	ds,cs:data_100e
		mov	di,dx
		mov	ax,0A000h
		mov	es,ax
		mov	ch,bl
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:data_65e[bx]
		mov	cs:data_66e,ax
		mov	al,cl
		or	ch,ch			; Zero ?
		js	loc_71			; Jump if sign=1
		push	di
		mov	di,0FA00h
		call	ai_process_loop_2
		pop	di
		mov	si,data_123e
		mov	ax,0A000h
		mov	ds,ax
		call	ai_process_loop_4
		pop	ds
		pop	es
		retn
loc_71:
		push	di
		mov	di,data_98e
		call	ai_multiply
		pop	di
		mov	si,data_123e
		mov	ax,0A000h
		mov	ds,ax
		call	ai_process_loop_4
		pop	ds
		pop	es
		retn
ai_func_5		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_multiply		proc	near
		push	bp
		push	si
		push	di
		dec	cl
		mov	al,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	extract_bits
		pop	di
		pop	si
		pop	bp
		jmp	short $+2		; delay for I/O

;���� External Entry into Subroutine ��������������������������������������

ai_func_11:
		mov	cx,8

locloop_72:
		push	cx
		mov	dl,ds:[bp]
		lodsw				; String [si] to ax
		call	ai_process_loop
		lodsw				; String [si] to ax
		call	ai_process_loop
		inc	bp
		pop	cx
		loop	locloop_72		; Loop if cx > 0

		retn
ai_multiply		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_process_loop		proc	near
		mov	cx,4

locloop_73:
		add	dl,dl
		sbb	dh,dh
		and	dh,es:[di]
		call	ai_func_15
		or	bl,dh
		mov	es:[di],bl
		inc	di
		loop	locloop_73		; Loop if cx > 0

		retn
ai_process_loop		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_process_loop_2		proc	near
		mov	cx,8

locloop_74:
		push	cx
		lodsw				; String [si] to ax
		call	ai_process_loop_3
		lodsw				; String [si] to ax
		call	ai_process_loop_3
		pop	cx
		loop	locloop_74		; Loop if cx > 0

		retn
ai_process_loop_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_process_loop_3		proc	near
		mov	cx,4

locloop_75:
		call	ai_func_15
		mov	es:[di],bl
		inc	di
		loop	locloop_75		; Loop if cx > 0

		retn
ai_process_loop_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_func_15		proc	near
		add	ax,ax
		adc	bx,bx
		add	ax,ax
		adc	bx,bx
		add	ax,ax
		adc	bx,bx
		add	ax,ax
		adc	bx,bx
		and	bx,0Fh
		add	bx,cs:data_66e
		mov	bl,cs:[bx]
		retn
ai_func_15		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_process_loop_4		proc	near
		mov	cx,8

locloop_76:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,138h
		loop	locloop_76		; Loop if cx > 0

		retn
ai_process_loop_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

extract_bits		proc	near
		mov	cx,10h

locloop_77:
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsb				; String [si] to al
		mov	bl,al
		mov	bh,dl
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		mov	es:[di],dh
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		mov	es:[di+1],dl
		add	bx,bx
		add	bx,bx
		and	bh,3Fh			; '?'
		mov	es:[di+2],bh
		and	al,3Fh			; '?'
		mov	es:[di+3],al
		add	di,4
		loop	locloop_77		; Loop if cx > 0

		retn
extract_bits		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

fill_buffer		proc	near
		xor	ax,ax			; Zero register
		mov	cx,20h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
fill_buffer		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_get_value		proc	near
		and	al,7Fh
		mov	bx,data_96e
		xlat				; al=[al+[bx]] table
		retn
ai_get_value		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation0		proc	near
		and	al,7Fh
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	cl,ds:data_96e[bx]
		mov	ch,10h
		mul	ch			; ax = reg * al
		add	ax,ds:data_91e
		mov	bp,ax
		mov	al,ds:[bp+6]
		and	al,0Fh
		mov	ch,5
		mul	ch			; ax = reg * al
		mov	si,0A070h
		test	byte ptr ds:[bp+5],80h
		jnz	loc_78			; Jump if not zero
		mov	si,data_90e
loc_78:
		mov	bl,ds:[bp+4]
		and	bl,1Fh
		add	bl,bl
		xor	bh,bh			; Zero register
		add	ax,[bx+si]
		mov	si,ax
		lodsb				; String [si] to al
		test	byte ptr ds:data_104e,0FFh
		jnz	loc_79			; Jump if not zero
		test	byte ptr ds:[bp+5],20h	; ' '
		jz	loc_79			; Jump if zero
		add	al,3
loc_79:
		mov	ds:data_74e,al
		mov	al,cl
		retn
vga_operation0		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation1		proc	near
		cmp	byte ptr ds:data_73e,10h
		jb	loc_80			; Jump if below
		retn
loc_80:
		push	cs
		pop	es
		call	word ptr cs:[11Ah]
		and	al,0Fh
		cmp	al,0Eh
		jae	loc_81			; Jump if above or =
		retn
loc_81:
		mov	di,data_97e
		xor	cl,cl			; Zero register
loc_82:
		cmp	byte ptr [di],0FFh
		je	loc_83			; Jump if equal
		add	di,4
		inc	cl
		jmp	short loc_82
loc_83:
		cmp	cl,20h			; ' '
		jb	loc_84			; Jump if below
		retn
loc_84:
		call	word ptr cs:[11Ah]
		and	al,3
		cmp	al,3
		je	loc_84			; Jump if equal
		dec	al
		add	al,ds:data_72e
		cmp	al,0FFh
		jne	loc_85			; Jump if not equal
		mov	al,4
loc_85:
		cmp	al,1Bh
		jb	loc_86			; Jump if below
		mov	al,1Ah
loc_86:
		stosb				; Store al to es:[di]
loc_87:
		call	word ptr cs:[11Ah]
		and	al,3
		cmp	al,3
		je	loc_87			; Jump if equal
		dec	al
		add	al,ds:data_73e
		cmp	al,0FFh
		jne	loc_88			; Jump if not equal
		xor	al,al			; Zero register
loc_88:
		stosb				; Store al to es:[di]
		mov	al,3
		stosb				; Store al to es:[di]
		call	word ptr cs:[11Ah]
		and	al,3
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn
vga_operation1		endp

			                        ;* No entry point to code
		push	cs
		pop	es
		mov	di,data_97e
		mov	si,di
loc_89:
		cmp	byte ptr [si],0FFh
		jne	loc_90			; Jump if not equal
		mov	byte ptr [di],0FFh
		retn
loc_90:
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
		mov	al,[si+1]
		xor	ah,ah			; Zero register
		mov	dx,0A00h
		mul	dx			; dx:ax = reg * ax
		mov	cl,[si]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	ax,cx
		add	ax,11B0h
		push	si
		push	di
		push	es
		push	ax
		mov	bl,[si+3]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,ds:data_57e[bx]
		mov	ds:data_75e,ax
		mov	bl,[si+2]
		and	bl,3
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:data_58e[bx]
		pop	di
		mov	ax,0A000h
		mov	es,ax
		mov	cx,10h

locloop_91:
		lodsw				; String [si] to ax
		xchg	ah,al
		call	ai_func_30
		not	bp
		and	es:[di],bp
		or	es:[di],dx
		call	ai_func_30
		not	bp
		and	es:[di+2],bp
		or	es:[di+2],dx
		call	ai_func_30
		not	bp
		and	es:[di+4],bp
		or	es:[di+4],dx
		call	ai_func_30
		not	bp
		and	es:[di+6],bp
		or	es:[di+6],dx
		lodsw				; String [si] to ax
		xchg	ah,al
		call	ai_func_30
		not	bp
		and	es:[di+8],bp
		or	es:[di+8],dx
		call	ai_func_30
		not	bp
		and	es:[di+0Ah],bp
		or	es:[di+0Ah],dx
		call	ai_func_30
		not	bp
		and	es:[di+0Ch],bp
		or	es:[di+0Ch],dx
		call	ai_func_30
		not	bp
		and	es:[di+0Eh],bp
		or	es:[di+0Eh],dx
		add	di,140h
		loop	locloop_91		; Loop if cx > 0

		pop	es
		pop	di
		pop	si
		dec	byte ptr [si+2]
		cmp	byte ptr [si+2],0FFh
		je	loc_92			; Jump if equal
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	si,4
loc_92:
		add	si,4
		jmp	loc_89
			                        ;* No entry point to code
		adc	[bp+si],dl
		xor	ds:data_60e,dh
		xor	ds:data_59e,dh
		and	di,[bx+di]
;*		jcxz	loc_93			;*Jump if cx=0
		db	0E3h, 38h		;  Fixup - byte match
		mov	data_8,ax
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
loc_94:
		jg	loc_94			; Jump if >
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
;*		loopnz	locloop_96		;*Loop if zf=0, cx>0

		db	0E0h, 01h		;  Fixup - byte match
loc_95:
		jg	loc_95			; Jump if >
		add	byte ptr [bx+si],2Fh	; '/'
		hlt				; Halt processor
		add	ds:data_86e[bx],bh
		push	cs
		pop	es
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosb				; Store al to es:[di]
		mov	di,data_83e
		mov	cx,8
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		jmp	short loc_100
			                        ;* No entry point to code
		call	vga_operation4
		mov	di,data_83e
		mov	dl,ds:data_105e
		dec	dl
		mov	cx,4

locloop_97:
		push	cx
		and	dl,3Fh			; '?'
		mov	al,24h			; '$'
		mul	dl			; ax = reg * al
		mov	bx,ax
		add	bx,data_93e
		mov	al,byte ptr ds:[83h]
		add	al,3
		xor	ah,ah			; Zero register
		add	bx,ax
		mov	cx,4

locloop_98:
		mov	al,[bx]
		or	al,al			; Zero ?
		js	loc_99			; Jump if sign=1
		xor	al,al			; Zero register
loc_99:
		mov	[di],al
		inc	bx
		inc	di
		loop	locloop_98		; Loop if cx > 0

		inc	dl
		pop	cx
		loop	locloop_97		; Loop if cx > 0

loc_100:
		mov	al,byte ptr ds:[84h]
		xor	ah,ah			; Zero register
		mov	cx,0A00h
		mul	cx			; dx:ax = reg * ax
		mov	cl,byte ptr ds:[83h]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	ax,cx
		add	ax,11B0h
		mov	ds:data_69e,ax
		mov	byte ptr ds:data_72e,0
		mov	si,5014h
		mov	di,data_83e
		mov	cx,3

locloop_101:
		push	cx
		mov	cx,3

locloop_102:
		push	cx
		mov	ax,3A88h
		push	ax
		mov	al,[di]
		or	al,[di+1]
		or	al,[di+4]
		or	al,[di+5]
		jnz	loc_103			; Jump if not zero
		jmp	loc_140
loc_103:
		test	byte ptr [di],0FFh
		jz	loc_104			; Jump if zero
		mov	al,[di]
		push	si
		call	vga_operation0
		inc	si
		inc	si
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_142
loc_104:
		test	byte ptr [di+1],0FFh
		jz	loc_105			; Jump if zero
		mov	al,[di+1]
		push	si
		call	vga_operation0
		inc	si
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_142
loc_105:
		test	byte ptr [di+4],0FFh
		jz	loc_106			; Jump if zero
		mov	al,[di+4]
		push	si
		call	vga_operation0
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_142
loc_106:
		mov	al,[di+5]
		push	si
		call	vga_operation0
		mov	cl,[si]
		pop	si
		mov	[si],al
		mov	al,cl
		jmp	loc_142
			                        ;* No entry point to code
		inc	byte ptr ds:data_72e
		inc	di
		inc	si
		pop	cx
		loop	locloop_102		; Loop if cx > 0

		pop	cx
		inc	di
		loop	locloop_101		; Loop if cx > 0

		mov	bl,ds:data_106e
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:data_65e[bx]
		mov	cs:data_66e,ax
		mov	es,cs:data_100e
		mov	al,byte ptr ds:[0E8h]
		or	al,ds:data_109e
		or	al,ds:data_110e
		jz	loc_107			; Jump if zero
		jmp	loc_117
loc_107:
		mov	cl,0FFh
		mov	si,6117h
		test	byte ptr ds:[0C2h],1
		jz	loc_108			; Jump if zero
		xor	cl,cl			; Zero register
		mov	si,61B9h
loc_108:
		test	byte ptr ds:data_113e,0FFh
		jz	loc_112			; Jump if zero
		inc	cl
		jnz	loc_109			; Jump if not zero
		mov	al,ds:data_112e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	vga_operation3
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,62C7h
		jmp	short loc_115
loc_109:
		mov	al,ds:data_112e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:data_114e
		dec	dl
		jnz	loc_110			; Jump if not zero
		add	ax,24h
		jmp	short loc_111
loc_110:
		dec	dl
		jnz	loc_111			; Jump if not zero
		mov	ax,63h
loc_111:
		add	si,ax
		jmp	short loc_115
loc_112:
		call	vga_operation3
		or	al,al			; Zero ?
		jz	loc_114			; Jump if zero
		dec	al
		mov	cl,al
		test	byte ptr ds:[0C2h],1
		jnz	loc_114			; Jump if not zero
		mov	ax,6Ch
		mov	dl,ds:data_108e
		and	dl,9
		xor	dh,dh			; Zero register
		add	ax,dx
		or	cl,cl			; Zero ?
		jz	loc_113			; Jump if zero
		add	ax,1Bh
loc_113:
		add	si,ax
		jmp	short loc_115
loc_114:
		test	byte ptr ds:data_108e,0FFh
		jnz	loc_117			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		cmp	al,80h
		je	loc_117			; Jump if equal
		add	al,2
		and	al,3
		test	al,1
		jnz	loc_117			; Jump if not zero
		mov	cl,9
		mul	cl			; ax = reg * al
		add	si,ax
		jmp	short loc_116
loc_115:
		test	byte ptr ds:data_108e,0FFh
		jz	loc_116			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:data_72e,3
		call	vga_operation2
		jmp	short loc_117
loc_116:
		mov	cx,9
		mov	byte ptr ds:data_72e,0
		call	vga_operation2
loc_117:
		mov	si,610Eh
		test	byte ptr ds:data_110e,0FFh
		jnz	loc_122			; Jump if not zero
		mov	si,60EAh
		test	byte ptr ds:data_109e,0FFh
		jnz	loc_120			; Jump if not zero
		mov	si,6075h
		test	byte ptr ds:[0C2h],1
		jnz	loc_118			; Jump if not zero
		mov	si,data_2e
loc_118:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_119			; Jump if zero
		add	si,5Ah
		jmp	short loc_120
loc_119:
		mov	ax,2Dh
		test	byte ptr ds:data_108e,0FFh
		jnz	loc_121			; Jump if not zero
		mov	ax,3Fh
		test	byte ptr ds:data_111e,80h
		jnz	loc_121			; Jump if not zero
		mov	cl,ds:data_115e
		mov	ax,48h
		dec	cl
		jz	loc_121			; Jump if zero
		mov	ax,51h
		dec	cl
		jz	loc_121			; Jump if zero
		mov	ax,36h
		cmp	byte ptr ds:data_111e,7Fh
		je	loc_121			; Jump if equal
		mov	ax,24h
		cmp	byte ptr ds:[0E7h],80h
		je	loc_121			; Jump if equal
loc_120:
		mov	al,byte ptr ds:[0E7h]
		and	al,3
		mov	cl,9
		mul	cl			; ax = reg * al
loc_121:
		add	si,ax
loc_122:
		mov	cx,9
		mov	byte ptr ds:data_72e,0
		call	vga_operation2
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_123			; Jump if zero
		retn
loc_123:
		mov	cl,0FFh
		mov	si,61B9h
		test	byte ptr ds:[0C2h],1
		jnz	loc_124			; Jump if not zero
		xor	cl,cl			; Zero register
		mov	si,6117h
loc_124:
		mov	al,ds:data_109e
		or	al,ds:data_110e
		jz	loc_126			; Jump if zero
		call	vga_operation3
		or	al,al			; Zero ?
		jnz	loc_125			; Jump if not zero
		retn
loc_125:
		dec	al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,1Bh
		add	al,7Eh			; '~'
		xor	ah,ah			; Zero register
		jmp	loc_133
loc_126:
		test	byte ptr ds:data_113e,0FFh
		jz	loc_130			; Jump if zero
		inc	cl
		jnz	loc_127			; Jump if not zero
		mov	al,ds:data_112e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	vga_operation3
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,625Bh
		jmp	short loc_134
loc_127:
		mov	al,ds:data_112e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:data_114e
		dec	dl
		jnz	loc_128			; Jump if not zero
		add	ax,24h
		jmp	short loc_129
loc_128:
		dec	dl
		jnz	loc_129			; Jump if not zero
		mov	ax,63h
loc_129:
		add	si,ax
		jmp	short loc_134
loc_130:
		test	byte ptr ds:[0C2h],1
		jz	loc_132			; Jump if zero
		call	vga_operation3
		or	al,al			; Zero ?
		jz	loc_132			; Jump if zero
		dec	al
		mov	cl,al
		mov	al,ds:data_108e
		and	al,9
		add	al,6Ch			; 'l'
		xor	ah,ah			; Zero register
		or	cl,cl			; Zero ?
		jz	loc_131			; Jump if zero
		add	ax,1Bh
loc_131:
		add	si,ax
		jmp	short loc_134
loc_132:
		mov	ax,1Bh
		test	byte ptr ds:data_108e,0FFh
		jnz	loc_133			; Jump if not zero
		mov	cl,byte ptr ds:[0E7h]
		cmp	cl,80h
		je	loc_133			; Jump if equal
		and	cl,3
		mov	al,9
		mul	cl			; ax = reg * al
loc_133:
		add	si,ax
loc_134:
		test	byte ptr ds:data_108e,0FFh
		jz	loc_135			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:data_72e,3
		jmp	short locloop_136
loc_135:
		mov	cx,9
		mov	byte ptr ds:data_72e,0
		jmp	short locloop_136

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation2		proc	near

locloop_136:
		push	cx
		mov	al,es:[si]
		or	al,al			; Zero ?
		jz	loc_137			; Jump if zero
		push	es
		push	ds
		push	si
		push	di
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,data_3e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bp,ax
		add	bp,data_7e
		mov	ds,cs:data_100e
		mov	di,dx
		push	cs
		pop	es
		mov	al,cs:data_72e
		mov	cl,40h			; '@'
		mul	cl			; ax = reg * al
		add	ax,511Dh
		mov	di,ax
		call	ai_func_11
		pop	di
		pop	si
		pop	ds
		pop	es
loc_137:
		inc	si
		inc	byte ptr ds:data_72e
		pop	cx
		loop	locloop_136		; Loop if cx > 0

		retn
vga_operation2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation3		proc	near
		mov	al,byte ptr ds:[93h]
		or	al,al			; Zero ?
		jnz	loc_138			; Jump if not zero
		retn
loc_138:
		cmp	al,4
		mov	al,1
		jnc	loc_139			; Jump if carry=0
		retn
loc_139:
		mov	al,2
		retn
vga_operation3		endp

loc_140:
		mov	al,[si]
		push	ds
		push	si
		push	di
		push	ax
		mov	ds,cs:data_100e
		push	cs
		pop	es
		mov	al,cs:data_72e
		mov	cl,40h			; '@'
		mul	cl			; ax = reg * al
		add	ax,511Dh
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_141			; Jump if zero
		dec	al
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	extract_bits
		pop	di
		pop	si
		pop	ds
		retn
loc_141:
		call	fill_buffer
		pop	di
		pop	si
		pop	ds
		retn
loc_142:
		push	ds
		push	si
		push	di
		mov	cl,al
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_143			; Jump if not sign
		call	ai_get_value
loc_143:
		push	ax
		mov	bl,ds:data_74e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	dx,cs:data_65e[bx]
		mov	cs:data_66e,dx
		mov	al,cl
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,data_1e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bp,ax
		add	bp,0A000h
		mov	ds,cs:data_100e
		push	cs
		pop	es
		mov	al,cs:data_72e
		mov	cl,40h			; '@'
		mul	cl			; ax = reg * al
		add	ax,511Dh
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_144			; Jump if zero
		mov	cl,al
		call	ai_multiply
		pop	di
		pop	si
		pop	ds
		retn
loc_144:
		call	ai_process_loop_2
		pop	di
		pop	si
		pop	ds
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation4		proc	near
		mov	cl,byte ptr ds:[84h]
		mov	al,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		add	ax,ds:data_102e
		mov	si,ax
		call	ai_func_44
		mov	di,data_86e
		push	cs
		pop	es
		mov	cx,3

locloop_145:
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	si,21h
		call	ai_func_44
		loop	locloop_145		; Loop if cx > 0

		retn
vga_operation4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation5		proc	near
		mov	al,ds:data_71e
		neg	al
		add	al,12h
		mov	cl,al
		test	byte ptr ds:data_116e,0FFh
		jnz	loc_147			; Jump if not zero
		mov	al,byte ptr ds:[84h]
		sub	al,2
		cmp	al,cl
		jne	loc_ret_146		; Jump if not equal
		call	ai_func_31

loc_ret_146:
		retn
loc_147:
		mov	al,byte ptr ds:[84h]
		sub	al,5
		cmp	cl,al
		jae	loc_148			; Jump if above or =
		retn
loc_148:
		jnz	loc_149			; Jump if not zero
		call	vga_operation6
		jmp	loc_175
loc_149:
		add	al,0Ah
		cmp	al,cl
		je	loc_150			; Jump if equal
		retn
loc_150:
		jmp	loc_165
			                        ;* No entry point to code
		test	byte ptr ds:data_116e,0FFh
		jnz	loc_151			; Jump if not zero
		retn
loc_151:
		push	es
		push	si
		push	di
		push	bx
		mov	es,cs:data_100e
		inc	byte ptr ds:data_119e
		mov	al,ds:data_118e
		or	al,al			; Zero ?
		jz	loc_155			; Jump if zero
		dec	al
		jz	loc_153			; Jump if zero
		cmp	byte ptr ds:data_119e,5
		jb	loc_152			; Jump if below
		jmp	loc_159
loc_152:
		xor	cl,cl			; Zero register
		mov	si,0B16Eh
		mov	word ptr ds:data_79e,0FF01h
		mov	dx,9F8h
		test	byte ptr ds:[0C2h],1
		jnz	loc_157			; Jump if not zero
		mov	si,0B0BEh
		mov	word ptr ds:data_79e,1
		mov	dx,0A00h
		jmp	short loc_157
loc_153:
		cmp	byte ptr ds:data_119e,5
		jb	loc_154			; Jump if below
		jmp	loc_159
loc_154:
		mov	bl,ds:data_119e
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B19Eh
		mov	si,0B12Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_156			; Jump if not zero
		mov	di,0B18Ah
		mov	si,0B07Eh
		jmp	short loc_156
loc_155:
		cmp	byte ptr ds:data_119e,7
		jae	loc_159			; Jump if above or =
		mov	bl,ds:data_119e
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B192h
		mov	si,0B0CEh
		test	byte ptr ds:[0C2h],1
		jnz	loc_156			; Jump if not zero
		mov	di,data_6e
		mov	si,0B01Eh
loc_156:
		mov	bx,es:[bx+di]
		mov	ds:data_79e,bx
		mov	al,bl
		cbw				; Convrt byte to word
		mov	dx,0A00h
		imul	dx			; dx:ax = reg * ax
		mov	dx,ax
		mov	al,bh
		cbw				; Convrt byte to word
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	dx,ax
loc_157:
		mov	di,ds:data_69e
		add	di,dx
		test	byte ptr ds:data_108e,0FFh
		jz	loc_158			; Jump if zero
		add	di,0A00h
loc_158:
		mov	ds:data_77e,di
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	si,cx
		mov	ds:data_78e,si
		pop	bx
		pop	di
		pop	si
		pop	es
		jmp	loc_165
loc_159:
		mov	byte ptr ds:data_116e,0
		mov	byte ptr ds:data_119e,0
		pop	bx
		pop	di
		pop	si
		pop	es
		retn

;���� External Entry into Subroutine ��������������������������������������

vga_operation6:
		test	byte ptr ds:data_117e,0FFh
		jnz	loc_160			; Jump if not zero
		retn
loc_160:
		push	es
		push	di
		push	si
		push	bx
		call	vga_operation8
		pop	bx
		pop	si
		pop	di
		pop	es
		mov	byte ptr ds:data_117e,0
		retn

;���� External Entry into Subroutine ��������������������������������������

vga_operation7:
		push	ds
		mov	si,cs:data_77e
		mov	ax,0A000h
		mov	ds,ax
		mov	es,ax
		mov	di,data_124e
		mov	cx,20h

locloop_161:
		push	cx
		mov	cx,10h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	si,120h
		pop	cx
		loop	locloop_161		; Loop if cx > 0

		pop	ds
		retn

;���� External Entry into Subroutine ��������������������������������������

vga_operation8:
		push	ds
		mov	di,cs:data_77e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,data_124e
		mov	cx,20h

locloop_162:
		push	cx
		mov	cx,10h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		add	di,120h
		pop	cx
		loop	locloop_162		; Loop if cx > 0

		pop	ds
		retn

;���� External Entry into Subroutine ��������������������������������������

vga_operation9:
		mov	al,byte ptr ds:[84h]
		add	al,ds:data_79e
		and	al,3Fh			; '?'
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,byte ptr ds:data_79e+1
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		mov	si,ax
		add	si,ds:data_102e
		call	ai_func_44
		mov	cx,4

locloop_163:
		push	cx
		mov	cx,4

locloop_164:
		push	cx
		mov	bl,[si]
		inc	si
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	word ptr ds:data_87e[bx],0
		pop	cx
		loop	locloop_164		; Loop if cx > 0

		add	si,20h
		call	ai_func_44
		pop	cx
		loop	locloop_163		; Loop if cx > 0

		retn
loc_165:
		test	byte ptr ds:data_116e,0FFh
		jnz	loc_166			; Jump if not zero
		retn
loc_166:
		mov	byte ptr ds:data_117e,0FFh
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	vga_operation9
		call	vga_operation7
		xor	bx,bx			; Zero register
		mov	bl,byte ptr cs:[92h]
		dec	bl
		add	bx,bx
		mov	ax,cs:data_61e[bx]
		mov	cs:data_75e,ax
		mov	ds,cs:data_100e
		mov	ax,0A000h
		mov	es,ax
		mov	di,cs:data_77e
		mov	si,cs:data_78e
		mov	cx,4

locloop_167:
		push	cx
		push	di
		mov	cx,4

locloop_168:
		push	cx
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_169			; Jump if not equal
		add	di,0A00h
		jmp	short loc_171
loc_169:
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,ds:data_5e
		mov	cx,8

locloop_170:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		call	ai_func_30
		not	bp
		and	es:[di],bp
		or	es:[di],dx
		call	ai_func_30
		not	bp
		and	es:[di+2],bp
		or	es:[di+2],dx
		call	ai_func_30
		not	bp
		and	es:[di+4],bp
		or	es:[di+4],dx
		call	ai_func_30
		not	bp
		and	es:[di+6],bp
		or	es:[di+6],dx
		add	di,140h
		pop	cx
		loop	locloop_170		; Loop if cx > 0

		pop	si
loc_171:
		pop	cx
		loop	locloop_168		; Loop if cx > 0

		pop	di
		add	di,8
		pop	cx
		loop	locloop_167		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
			                        ;* No entry point to code
		add	[bx+di],cx
		add	al,24h			; '$'
		add	bx,[bp+di]
		add	[bx+di],cx
		add	al,24h			; '$'
		push	es

;���� External Entry into Subroutine ��������������������������������������

		db	36h			; byte preceding ai_func_30
ai_func_30:
		xor	bp,bp			; Zero register
		xor	dx,dx			; Zero register
		xor	bl,bl			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jz	loc_172			; Jump if zero
		or	bp,0FFh
		mov	dl,byte ptr cs:data_75e+1
		cmp	bl,3
		je	loc_172			; Jump if equal
		mov	dl,cs:data_75e
loc_172:
		xor	bl,bl			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jnz	loc_173			; Jump if not zero
		retn
loc_173:
		or	bp,0FF00h
		mov	dh,byte ptr cs:data_75e+1
		cmp	bl,3
		jne	loc_174			; Jump if not equal
		retn
loc_174:
		mov	dh,cs:data_75e
		retn
			                        ;* No entry point to code
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		mov	ds:data_69e,di
		jmp	short loc_177

;���� External Entry into Subroutine ��������������������������������������

ai_func_31:
loc_175:
		test	byte ptr ds:data_107e,0FFh
		jz	loc_176			; Jump if zero
		retn
loc_176:
		mov	byte ptr ds:data_107e,0FFh
loc_177:
		push	es
		push	ds
		push	si
		push	di
		push	bx
		mov	ax,0A000h
		mov	es,ax
		mov	si,data_88e
		mov	di,cs:data_69e
		mov	cx,3

locloop_178:
		push	cx
		mov	cx,3

locloop_179:
		push	cx
		push	di
		call	ai_process_loop_4
		pop	di
		add	di,8
		pop	cx
		loop	locloop_179		; Loop if cx > 0

		add	di,9E8h
		pop	cx
		loop	locloop_178		; Loop if cx > 0

		pop	bx
		pop	di
		pop	si
		pop	ds
		pop	es
		retn
vga_operation5		endp

			                        ;* No entry point to code
		push	ds
		push	si
		dec	al
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_100e
		mov	ax,0A000h
		mov	es,ax
		add	di,di
		mov	cx,8

locloop_180:
		push	cx
		mov	cx,2

locloop_181:
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsb				; String [si] to al
		mov	bl,al
		mov	bh,dl
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		or	dh,dh			; Zero ?
		jz	loc_182			; Jump if zero
		mov	es:[di],dh
loc_182:
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		or	dl,dl			; Zero ?
		jz	loc_183			; Jump if zero
		mov	es:[di+1],dl
loc_183:
		add	bx,bx
		add	bx,bx
		and	bh,3Fh			; '?'
		jz	loc_184			; Jump if zero
		mov	es:[di+2],bh
loc_184:
		and	al,3Fh			; '?'
		jz	loc_185			; Jump if zero
		mov	es:[di+3],al
loc_185:
		add	di,4
		loop	locloop_181		; Loop if cx > 0

		add	di,138h
		pop	cx
		loop	locloop_180		; Loop if cx > 0

		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_117e,0
		mov	ax,0A000h
		mov	es,ax
		mov	byte ptr ds:data_82e,8
loc_186:
		mov	word ptr ds:data_68e,11B0h
		mov	byte ptr ds:data_99e,0
		mov	si,ds:data_102e
		mov	di,data_94e
		mov	cx,12h

locloop_187:
		push	cx
		add	si,4
		xor	bx,bx			; Zero register
		mov	cx,1Ch

locloop_188:
		push	cx
		lodsb				; String [si] to al
		call	ai_multiply_2
		inc	di
		inc	bl
		pop	cx
		loop	locloop_188		; Loop if cx > 0

		add	si,4
		call	ai_func_44
		add	word ptr ds:data_68e,0A00h
		pop	cx
		loop	locloop_187		; Loop if cx > 0

loc_189:
		cmp	byte ptr ds:data_99e,10h
		jb	loc_189			; Jump if below
		dec	byte ptr ds:data_82e
		jnz	loc_186			; Jump if not zero
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_multiply_2		proc	near
		cmp	byte ptr [di],0FFh
		jne	loc_190			; Jump if not equal
		retn
loc_190:
		cmp	byte ptr [di],0FCh
		jne	loc_191			; Jump if not equal
		retn
loc_191:
		push	ds
		push	di
		push	si
		push	bx
		push	ax
		mov	ah,ds:data_82e
		dec	ah
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sbb	ax,ax
		xor	ax,0FF00h
		mov	ds:data_81e,ax
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ds:data_68e
		mov	di,bx
		pop	ax
		test	al,0FFh
		jnz	loc_192			; Jump if not zero
		jmp	loc_194
loc_192:
		dec	al
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:data_100e
		push	si
		push	di
		mov	al,cs:data_82e
		and	al,3
		neg	al
		add	al,3
		call	ai_multiply_3
		call	ai_func_33
		pop	di
		pop	si
		mov	al,cs:data_82e
		call	ai_multiply_3
		add	di,4
		add	si,3
		call	ai_func_33
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

;���� External Entry into Subroutine ��������������������������������������

ai_func_33:
		mov	cx,2

locloop_193:
		push	cx
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsb				; String [si] to al
		mov	bl,al
		mov	bh,dl
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		add	bx,bx
		add	bx,bx
		and	bh,3Fh			; '?'
		and	al,3Fh			; '?'
		mov	bl,al
		xchg	dh,dl
		xchg	bh,bl
		mov	ax,cs:data_81e
		not	ax
		and	es:[di],ax
		and	es:[di+2],ax
		not	ax
		and	ax,dx
		or	es:[di],ax
		mov	ax,cs:data_81e
		and	ax,bx
		or	es:[di+2],ax
		add	di,500h
		add	si,15h
		pop	cx
		loop	locloop_193		; Loop if cx > 0

		retn
loc_194:
		push	di
		mov	al,cs:data_82e
		and	al,3
		neg	al
		add	al,3
		call	ai_multiply_3
		call	ai_func_34
		pop	di
		mov	al,cs:data_82e
		call	ai_multiply_3
		add	di,4
		call	ai_func_34
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn
ai_multiply_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_func_34		proc	near
		mov	ax,cs:data_81e
		not	ax
		and	es:[di],ax
		and	es:[di+2],ax
		add	di,data_121e
		and	es:[di],ax
		and	es:[di+2],ax
		retn
ai_func_34		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_multiply_3		proc	near
		and	al,3
		xor	ah,ah			; Zero register
		push	ax
		mov	bx,6
		mul	bl			; ax = reg * al
		add	si,ax
		pop	ax
		mov	bx,140h
		mul	bx			; dx:ax = reg * ax
		add	di,ax
		retn
ai_multiply_3		endp

			                        ;* No entry point to code
		mov	al,byte ptr ds:[83h]
		add	al,al
		add	al,al
		add	al,al
		mov	ah,byte ptr ds:[84h]
		add	ah,ah
		add	ah,ah
		add	ah,ah
		mov	ds:data_66e,al
		mov	byte ptr ds:data_66e+1,ah
		call	vga_operation_3
		mov	byte ptr ds:data_82e,36h	; '6'
		call	ai_func_36
		mov	byte ptr ds:data_82e,0
		call	ai_func_36
		jmp	loc_212

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_func_36		proc	near
		mov	al,ds:data_66e
		dec	al
		mov	bl,al
		add	al,19h
		mov	dl,al
		mov	al,byte ptr ds:data_66e+1
		dec	al
		mov	bh,al
		add	al,19h
		mov	dh,al
		call	ai_func_37
		mov	al,ds:data_66e
		sub	al,5
		mov	bl,al
		add	al,21h			; '!'
		mov	dl,al
		mov	al,byte ptr ds:data_66e+1
		sub	al,5
		mov	bh,al
		add	al,21h			; '!'
		mov	dh,al
		call	ai_func_37
		mov	al,ds:data_66e
		sub	al,9
		mov	bl,al
		add	al,29h			; ')'
		mov	dl,al
		mov	al,byte ptr ds:data_66e+1
		sub	al,9
		mov	bh,al
		add	al,29h			; ')'
		mov	dh,al

;���� External Entry into Subroutine ��������������������������������������

ai_func_37:
		mov	cx,9

locloop_195:
		push	cx
		push	dx
		push	bx
		call	vga_operation_2
		pop	bx
		pop	dx
		sub	bl,0Ch
		jnc	loc_196			; Jump if carry=0
		xor	bl,bl			; Zero register
loc_196:
		sub	bh,0Ch
		jnc	loc_197			; Jump if carry=0
		xor	bh,bh			; Zero register
loc_197:
		add	dl,0Ch
		jnc	loc_198			; Jump if carry=0
		mov	dl,0FFh
loc_198:
		add	dh,0Ch
		jnc	loc_199			; Jump if carry=0
		mov	dh,0FFh
loc_199:
		push	dx
		push	bx
		call	ai_multiply_5
		pop	bx
		pop	dx
		pop	cx
		loop	locloop_195		; Loop if cx > 0

		retn
ai_func_36		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation_2		proc	near
		mov	ax,0A000h
		mov	es,ax
		push	dx
		push	bx
		mov	dh,bh
		call	ai_fill_buf
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	bh,dh
		call	ai_fill_buf
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	dl,bl
		call	ai_func_39
		pop	bx
		pop	dx
		mov	bl,dl

;���� External Entry into Subroutine ��������������������������������������

ai_func_39:
		cmp	dh,bh
		jae	loc_200			; Jump if above or =
		xchg	dx,bx
loc_200:
		or	bl,bl			; Zero ?
		jnz	loc_201			; Jump if not zero
		retn
loc_201:
		cmp	bl,0DFh
		jb	loc_202			; Jump if below
		retn
loc_202:
		or	bh,bh			; Zero ?
		jnz	loc_203			; Jump if not zero
		mov	bh,1
loc_203:
		cmp	dh,8Fh
		jb	loc_204			; Jump if below
		mov	dh,8Eh
loc_204:
		mov	al,dh
		sub	al,bh
		inc	al
		push	ax
		mov	al,bh
		call	ai_multiply_4
		mov	al,bl
		xor	ah,ah			; Zero register
		add	di,ax
		pop	cx
		xor	ch,ch			; Zero register
		mov	ah,ds:data_82e

locloop_205:
		mov	es:[di],ah
		add	di,140h
		loop	locloop_205		; Loop if cx > 0

		retn
vga_operation_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_fill_buf		proc	near
		cmp	dl,bl
		jae	loc_206			; Jump if above or =
		xchg	dx,bx
loc_206:
		or	bh,bh			; Zero ?
		jnz	loc_207			; Jump if not zero
		retn
loc_207:
		cmp	bh,8Fh
		jb	loc_208			; Jump if below
		retn
loc_208:
		or	bl,bl			; Zero ?
		jnz	loc_209			; Jump if not zero
		mov	bl,1
loc_209:
		cmp	dl,0DFh
		jb	loc_210			; Jump if below
		mov	dl,0DEh
loc_210:
		mov	al,bh
		call	ai_multiply_4
		mov	al,bl
		xor	ah,ah			; Zero register
		add	di,ax
		mov	ah,dl
		sub	ah,al
		mov	cl,ah
		xor	ch,ch			; Zero register
		mov	al,ds:data_82e
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn
ai_fill_buf		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_multiply_4		proc	near
		push	dx
		xor	ah,ah			; Zero register
		mov	di,140h
		mul	di			; dx:ax = reg * ax
		add	ax,11B0h
		mov	di,ax
		pop	dx
		retn
ai_multiply_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_multiply_5		proc	near
		mov	cl,ds:data_103e
		shr	cl,1			; Shift w/zeros fill
		inc	cl
		mov	al,1
		mul	cl			; ax = reg * al
loc_211:
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		cmp	ds:data_99e,al
		jb	loc_211			; Jump if below
		mov	byte ptr ds:data_99e,0
		retn
ai_multiply_5		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation_3		proc	near
loc_212:
		mov	ax,0A000h
		mov	es,ax
		mov	di,data_122e
		mov	cx,8

locloop_213:
		push	cx
		push	di
		mov	cx,12h

locloop_214:
		push	cx
		push	di
		mov	ax,1212h
		mov	cx,70h

locloop_215:
		xor	es:[di],ax
		inc	di
		inc	di
		loop	locloop_215		; Loop if cx > 0

		pop	di
		add	di,0A00h
		pop	cx
		loop	locloop_214		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_213		; Loop if cx > 0

		retn
vga_operation_3		endp

			                        ;* No entry point to code
		and	al,3Fh			; '?'
		mov	bl,ah
		xor	ah,ah			; Zero register
		mov	dx,0A00h
		mul	dx			; dx:ax = reg * ax
		sub	bl,4
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	ax,bx
		mov	di,ax
		add	di,11B0h
		shr	di,1			; Shift w/zeros fill
		retn
			                        ;* No entry point to code
		mov	bl,byte ptr ds:[9Dh]
		or	bl,bl			; Zero ?
		jz	loc_216			; Jump if zero
		cmp	bl,7
		je	loc_216			; Jump if equal
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	es,cs:data_100e
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	si,[bx]
		mov	di,data_4e
		mov	cx,480h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
loc_216:
		mov	ds,cs:data_100e
		mov	si,9350h
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_func_44		proc	near
		cmp	si,0E900h
		jae	loc_217			; Jump if above or =
		retn
loc_217:
		sub	si,900h
		retn
ai_func_44		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_func_45		proc	near
		cmp	si,0E000h
		jb	loc_218			; Jump if below
		retn
loc_218:
		add	si,900h
		retn
ai_func_45		endp

			                        ;* No entry point to code
		push	si
		push	ds
		mov	word ptr cs:data_75e,1210h
		mov	si,data_62e
		mov	di,3230h
		mov	ax,0A000h
		mov	es,ax
		mov	cx,5

locloop_219:
		push	cx
		mov	cx,1Ch

locloop_220:
		push	cx
		lodsb				; String [si] to al
		push	ds
		push	si
		mov	ds,cs:data_100e
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,4000h
		mov	si,ax
		push	di
		mov	cx,8

locloop_221:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		call	ai_func_30
		mov	es:[di],dx
		call	ai_func_30
		mov	es:[di+2],dx
		call	ai_func_30
		mov	es:[di+4],dx
		call	ai_func_30
		mov	es:[di+6],dx
		add	di,140h
		pop	cx
		loop	locloop_221		; Loop if cx > 0

		pop	di
		add	di,8
		pop	si
		pop	ds
		pop	cx
		loop	locloop_220		; Loop if cx > 0

		add	di,920h
		pop	cx
		loop	locloop_219		; Loop if cx > 0

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
		db	 3Fh, 06h,0A2h,0FFh, 4Fh,0BEh
		db	 3Bh, 47h,0C7h, 06h,0EBh, 4Fh
		db	0B0h, 11h,0B9h, 12h, 00h

locloop_222:
		push	cx
		mov	cx,1Ch

locloop_223:
		push	cx
		lodsb				; String [si] to al
		push	si
		call	vga_operation_4
		pop	si
		add	word ptr ds:data_68e,8
		pop	cx
		loop	locloop_223		; Loop if cx > 0

		add	word ptr ds:data_68e,920h
		pop	cx
		loop	locloop_222		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

vga_operation_4		proc	near
		push	ds
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:data_100e
		mov	ax,0A000h
		mov	es,ax
		mov	di,cs:data_68e
		mov	cx,8

locloop_224:
		push	cx
		call	extract_bits_2
		add	di,138h
		pop	cx
		loop	locloop_224		; Loop if cx > 0

		pop	ds
		retn
vga_operation_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

extract_bits_2		proc	near
		mov	cx,2

locloop_225:
		push	cx
		lodsw				; String [si] to ax
		mov	dx,ax
		lodsb				; String [si] to al
		mov	bl,al
		mov	bh,dl
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		mov	es:[di],dh
		shr	dl,1			; Shift w/zeros fill
		shr	dl,1			; Shift w/zeros fill
		mov	es:[di+1],dl
		add	bx,bx
		add	bx,bx
		and	bh,3Fh			; '?'
		mov	es:[di+2],bh
		and	al,3Fh			; '?'
		mov	es:[di+3],al
		mov	bl,cs:data_82e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	cx,4

locloop_226:
		mov	al,es:[di]
		or	al,al			; Zero ?
		jz	loc_227			; Jump if zero
		mov	ah,al
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		call	word ptr cs:data_63e[bx]	;*
		add	ah,ah
		add	ah,ah
		add	ah,ah
		and	al,7
		or	al,ah
		mov	ah,al
		and	ah,7
		call	word ptr cs:data_63e[bx]	;*
		and	al,38h			; '8'
		or	al,ah
loc_227:
		stosb				; Store al to es:[di]
		loop	locloop_226		; Loop if cx > 0

		pop	cx
		loop	locloop_225		; Loop if cx > 0

		retn
extract_bits_2		endp

		db	0DEh, 46h,0EFh, 46h,0F8h, 46h
		db	 09h, 47h, 22h, 47h, 80h,0FCh
		db	 06h, 75h, 03h,0B4h, 03h,0C3h
		db	 80h,0FCh, 07h, 74h, 01h,0C3h
loc_228:
		mov	ah,5
		retn
			                        ;* No entry point to code
		cmp	ah,4
		je	loc_229			; Jump if equal
		retn
loc_229:
		mov	ah,2
		retn
			                        ;* No entry point to code
		cmp	ah,4
		jne	loc_230			; Jump if not equal
		mov	ah,5
		retn
loc_230:
		cmp	ah,7
		je	loc_231			; Jump if equal
		retn
loc_231:
		mov	ah,4
		retn
			                        ;* No entry point to code
		cmp	ah,4
		jne	loc_232			; Jump if not equal
		mov	ah,3
		retn
loc_232:
		cmp	ah,7
		jne	loc_233			; Jump if not equal
		mov	ah,5
		retn
loc_233:
		cmp	ah,6
		je	loc_234			; Jump if equal
		retn
loc_234:
		mov	ah,7
		retn
			                        ;* No entry point to code
		cmp	ah,7
		jne	loc_235			; Jump if not equal
		mov	ah,5
		retn
loc_235:
		cmp	ah,4
		jne	loc_236			; Jump if not equal
		mov	ah,7
		retn
loc_236:
		cmp	ah,6
		je	loc_237			; Jump if equal
		retn
loc_237:
		mov	ah,4
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
		sbb	ds:data_89e,bh
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
		db	 1Eh, 50h, 33h,0C0h, 8Ah,0C7h
		db	 8Ah,0FCh, 50h,0B8h, 40h, 01h
		db	0F7h,0E3h, 5Fh, 03h,0FFh, 03h
		db	0FFh, 03h,0F8h, 58h,0B1h, 20h
		db	0F6h,0E1h, 05h, 00h, 60h, 8Bh
		db	0F0h, 2Eh, 8Eh, 1Eh, 2Ch,0FFh
		db	0B8h, 00h,0A0h, 8Eh,0C0h,0B9h
		db	 08h, 00h

locloop_238:
		push	cx
		lodsw				; String [si] to ax
		mov	dx,ax
		call	ai_process_loop_5
		lodsw				; String [si] to ax
		mov	dx,ax
		call	ai_process_loop_5
		add	di,138h
		pop	cx
		loop	locloop_238		; Loop if cx > 0

		pop	ds
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_process_loop_5		proc	near
		mov	cx,4

locloop_239:
		xor	ax,ax			; Zero register
		add	dx,dx
		adc	ax,ax
		add	dx,dx
		adc	ax,ax
		add	ax,ax
		add	dx,dx
		adc	ax,ax
		add	dx,dx
		adc	ax,ax
		stosb				; Store al to es:[di]
		loop	locloop_239		; Loop if cx > 0

		retn
ai_process_loop_5		endp

			                        ;* No entry point to code
		push	ds
		mov	word ptr cs:data_75e,908h
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_64e[bx]
		mov	di,6C10h
		mov	ax,0A000h
		mov	es,ax
		mov	cx,18h

locloop_240:
		lodsw				; String [si] to ax
		xchg	ah,al
		call	ai_func_30
		not	bp
		and	es:[di],bp
		or	es:[di],dx
		call	ai_func_30
		not	bp
		and	es:[di+2],bp
		or	es:[di+2],dx
		call	ai_func_30
		not	bp
		and	es:[di+4],bp
		or	es:[di+4],dx
		call	ai_func_30
		not	bp
		and	es:[di+6],bp
		or	es:[di+6],dx
		lodsw				; String [si] to ax
		xchg	ah,al
		call	ai_func_30
		not	bp
		and	es:[di+8],bp
		or	es:[di+8],dx
		call	ai_func_30
		not	bp
		and	es:[di+0Ah],bp
		or	es:[di+0Ah],dx
		call	ai_func_30
		not	bp
		and	es:[di+0Ch],bp
		or	es:[di+0Ch],dx
		call	ai_func_30
		not	bp
		and	es:[di+0Eh],bp
		or	es:[di+0Eh],dx
		add	di,140h
		loop	locloop_240		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		xor	[bp+si+31h],cx
		dec	dx
		xor	[bp+si-6Fh],cx
		dec	dx
		xchg	cx,ax
		dec	dx
		db	0F1h, 4Ah
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
		db	0E2h, 05h,0DDh, 4Bh, 8Bh,0F0h
		db	0BDh, 01h, 00h,0EBh, 0Eh, 24h
		db	 01h, 8Ah,0E0h, 32h,0C0h, 05h
		db	0DDh, 4Ch, 8Bh,0F0h,0BDh, 04h
		db	 00h,0B8h, 40h, 01h, 32h,0EDh
		db	0F7h,0E1h, 03h,0C3h, 8Bh,0F8h
		db	0B8h, 00h,0A0h, 8Eh,0C0h, 8Bh
		db	0CDh

locloop_241:
		push	cx
		push	di
		mov	cx,10h

locloop_242:
		push	cx
		push	di
		mov	cx,2

locloop_243:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		call	ai_func_30
		not	bp
		and	es:[di],bp
		or	es:[di],dx
		call	ai_func_30
		not	bp
		and	es:[di+2],bp
		or	es:[di+2],dx
		call	ai_func_30
		not	bp
		and	es:[di+4],bp
		or	es:[di+4],dx
		call	ai_func_30
		not	bp
		and	es:[di+6],bp
		or	es:[di+6],dx
		add	di,8
		pop	cx
		loop	locloop_243		; Loop if cx > 0

		pop	di
		add	di,140h
		pop	cx
		loop	locloop_242		; Loop if cx > 0

		pop	di
		add	di,10h
		pop	cx
		loop	locloop_241		; Loop if cx > 0

		pop	ds
		retn
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

locloop_244:
		push	cx
		mov	cx,8

locloop_245:
		push	cx
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	dx,ax
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cx,ax
		mov	cs:data_68e,dx
		mov	cs:data_70e,cx
		or	ax,dx
		mov	bx,ax
		shr	bx,1			; Shift w/zeros fill
		or	ax,bx
		add	bx,bx
		add	bx,bx
		or	ax,bx
		not	ax
		mov	cs:data_75e,ax
		call	ai_process_loop_6
		mov	ax,dx
		stosw				; Store ax to es:[di]
		call	ai_process_loop_6
		mov	ax,dx
		stosw				; Store ax to es:[di]
		call	ai_scan_loop
		mov	es:[bp],dl
		inc	bp
		pop	cx
		loop	locloop_245		; Loop if cx > 0

		pop	cx
		loop	locloop_244		; Loop if cx > 0

		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_process_loop_6		proc	near
		mov	cx,4

locloop_246:
		rol	word ptr cs:data_70e,1	; Rotate
		adc	dx,dx
		rol	word ptr cs:data_68e,1	; Rotate
		adc	dx,dx
		rol	word ptr cs:data_70e,1	; Rotate
		adc	dx,dx
		rol	word ptr cs:data_68e,1	; Rotate
		adc	dx,dx
		loop	locloop_246		; Loop if cx > 0

		retn
ai_process_loop_6		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

ai_scan_loop		proc	near
		mov	cx,8

locloop_247:
		xor	al,al			; Zero register
		rol	word ptr cs:data_75e,1	; Rotate
		adc	al,al
		rol	word ptr cs:data_75e,1	; Rotate
		adc	al,al
		cmp	al,3
		je	loc_248			; Jump if equal
		xor	al,al			; Zero register
loc_248:
		and	al,1
		add	dl,dl
		or	dl,al
		loop	locloop_247		; Loop if cx > 0

		retn
ai_scan_loop		endp

			                        ;* No entry point to code
		cbw				; Convrt byte to word
		dec	di
		test	al,4Fh			; 'O'
		mov	ax,0C84Fh
		dec	di
		db	0D8h, 4Fh,0C8h, 4Fh, 00h, 01h
		db	 02h, 03h, 08h, 09h, 0Ah, 0Bh
		db	 10h, 11h, 12h, 13h, 18h, 19h
		db	 1Ah, 1Bh, 00h, 02h, 04h, 06h
		db	 10h, 12h, 14h, 16h
		db	' "$'
		db	'&0246'
		db	0, 1, 4, 5
		db	8, 9, 0Ch, 0Dh, ' !$'
		db	'%(),-'
		db	0, 5, 6, 7
		db	'(-./05678=>?'
		db	0, 6, 5, 7
		db	'0657(.-/8>=?'
		db	0C3h
		db	884 dup (0)

seg_a		ends



		end	start
