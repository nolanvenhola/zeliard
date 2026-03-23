
PAGE  59,132

;==========================================================================
;
;  SPRITE_RENDERER - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	6000h			;*
data_2e		equ	0B000h			;*
data_3e		equ	0B17Eh			;*
data_53e	equ	3170h			;*
data_54e	equ	3863h			;*
data_55e	equ	3929h			;*
data_56e	equ	3E80h			;*
data_57e	equ	4199h			;*
data_58e	equ	43C8h			;*
data_59e	equ	472Eh			;*
data_60e	equ	485Ch			;*
data_61e	equ	4B88h			;*
data_62e	equ	505Ah			;*
data_63e	equ	5067h			;*
data_65e	equ	5069h			;*
data_66e	equ	506Bh			;*
data_67e	equ	506Dh			;*
data_68e	equ	506Eh			;*
data_69e	equ	506Fh			;*
data_70e	equ	5070h			;*
data_71e	equ	5071h			;*
data_72e	equ	5072h			;*
data_73e	equ	5074h			;*
data_74e	equ	5076h			;*
data_76e	equ	5078h			;*
data_77e	equ	5079h			;*
data_78e	equ	507Ah			;*
data_79e	equ	508Ah			;*
data_80e	equ	508Bh			;*
data_81e	equ	508Eh			;*
data_82e	equ	5097h			;*
data_83e	equ	625Ch			;*
data_84e	equ	0A030h			;*
data_85e	equ	0AF3Fh			;*
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
data_99e	equ	0FF35h			;*
data_100e	equ	0FF36h			;*
data_101e	equ	0FF37h			;*
data_102e	equ	0FF38h			;*
data_103e	equ	0FF39h			;*
data_104e	equ	0FF3Ah			;*
data_105e	equ	0FF3Dh			;*
data_106e	equ	0FF3Fh			;*
data_107e	equ	0FF40h			;*
data_108e	equ	0FF41h			;*
data_109e	equ	0FF42h			;*
data_110e	equ	0FF43h			;*
data_111e	equ	0FF44h			;*
data_112e	equ	0FF45h			;*
data_113e	equ	0FF46h			;*
data_114e	equ	9350h			;*
data_115e	equ	140h
data_116e	equ	46Ch
data_117e	equ	0C8Ch
data_118e	equ	1B04h
data_119e	equ	3E80h
data_120e	equ	3E90h
data_121e	equ	3F20h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_02		proc	far

start:
		xchg	di,ax
		and	[bx+si],ax
		add	[si],ch
		xor	[bx+3Ah],al
		mov	al,ds:data_85e
		db	 3Eh,0EEh
		db	'AZFi@l2g8'
		db	 8Ah, 42h,0AEh, 41h, 31h, 3Ah
		db	0D0h, 43h, 75h, 46h,0BDh, 46h
		db	0BAh, 47h, 9Fh, 41h,0DDh, 4Ah
		db	 2Dh, 4Bh,0B4h, 4Ch, 66h, 50h
		db	 66h, 50h, 0Eh, 07h,0BFh, 97h
		db	 50h, 33h,0C0h,0B9h, 80h, 00h
		db	0F3h,0ABh
data_4		db	0FEh
		db	 06h, 78h, 50h,0C7h, 06h, 69h
		db	 50h, 6Ch, 04h, 8Bh, 36h, 31h
		db	0FFh, 83h,0EEh, 21h,0E8h
data_5		db	65h
		db	 16h, 33h,0DBh,0F6h, 04h, 80h
		db	 74h, 03h,0E8h, 07h, 03h, 46h
		db	0B9h, 06h, 00h

locloop_1:
		push	cx
		test	byte ptr [si],80h
		jz	loc_2			; Jump if zero
		call	sprite_func_3
loc_2:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_3			; Jump if zero
		call	sprite_func_3
loc_3:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_4			; Jump if zero
		call	sprite_func_3
loc_4:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_5			; Jump if zero
		call	sprite_func_3
loc_5:
		inc	si
		inc	bx
		pop	cx
		loop	locloop_1		; Loop if cx > 0

		test	byte ptr [si],80h
		jz	loc_6			; Jump if zero
		call	sprite_func_3
loc_6:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_7			; Jump if zero
		call	sprite_func_3
loc_7:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_8			; Jump if zero
		call	sprite_func_3
loc_8:
		inc	si
		test	byte ptr [si],80h
		jz	loc_9			; Jump if zero
		call	sprite_func_4
loc_9:
		mov	si,ds:data_96e
		mov	di,0E900h
		mov	byte ptr ds:data_67e,12h
loc_10:
		call	vga_operation1
		xor	bx,bx			; Zero register
		add	si,3
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jns	loc_11			; Jump if not sign
		call	sprite_func_5
loc_11:
		mov	cx,6

locloop_12:
		push	cx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_13			; Jump if zero
		call	sprite_func_1
loc_13:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_14			; Jump if zero
		call	sprite_func_1
loc_14:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_15			; Jump if zero
		call	sprite_func_1
loc_15:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_16			; Jump if zero
		call	sprite_func_1
loc_16:
		inc	bx
		pop	cx
		loop	locloop_12		; Loop if cx > 0

		cmpsb				; Cmp [si] to es:[di]
		jz	loc_17			; Jump if zero
		call	sprite_func_1
loc_17:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_18			; Jump if zero
		call	sprite_func_1
loc_18:
		inc	bx
		cmpsb				; Cmp [si] to es:[di]
		jz	loc_19			; Jump if zero
		call	sprite_func_1
loc_19:
		inc	bx
		lodsb				; String [si] to al
		inc	di
		or	al,al			; Zero ?
		jns	loc_20			; Jump if not sign
		jmp	loc_57
loc_20:
		cmp	al,es:[di-1]
		je	loc_21			; Jump if equal
		call	sprite_func_1
loc_21:
		add	si,4
		call	sprite_func_37
		add	word ptr ds:data_65e,280h
		dec	byte ptr ds:data_67e
		jnz	loc_10			; Jump if not zero
		retn

zr2_02		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_func_1		proc	near
		mov	al,[si-1]
		or	al,al			; Zero ?
		jns	loc_22			; Jump if not sign
		jmp	loc_55
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
		add	dx,ds:data_65e
		call	vga_operation
loc_24:
		mov	al,ds:data_87e
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
		call	word ptr ds:data_53e[bx]	;*
		pop	bx
		retn
sprite_func_1		endp

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

vga_operation		proc	near
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,dx
		or	al,al			; Zero ?
		jnz	loc_41			; Jump if not zero
		jmp	loc_44
loc_41:
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:data_82e[bx],0FFFFh
		jnz	loc_43			; Jump if not zero
		mov	ds:data_82e[bx],di
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:data_94e
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	bx,offset data_5
		mov	cx,4

locloop_42:
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		dec	di
		dec	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		add	di,bx
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		dec	di
		dec	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		add	di,bx
		loop	locloop_42		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_43:
		mov	si,ds:data_82e[bx]
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	bx,4Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
loc_44:
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		xor	ax,ax			; Zero register
		mov	bx,4Eh
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
vga_operation		endp

			                        ;* No entry point to code
		cmp	byte ptr ds:data_89e,0FFh
		jne	loc_45			; Jump if not equal
		retn
loc_45:
		cmp	byte ptr ds:data_89e,0FCh
		jne	loc_46			; Jump if not equal
		retn
loc_46:
		push	si
		push	bx
		mov	byte ptr ds:data_89e,0FFh
		mov	cl,[si]
		add	si,25h
		call	sprite_func_37
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_47			; Jump if not sign
		call	sprite_get_value
loc_47:
		push	ax
		mov	al,cl
		call	sprite_multiply_2
		add	si,3
		pop	ax
		mov	ah,[si]
		mov	dx,46Ch
		call	sprite_func_8
		pop	bx
		pop	si
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_func_3		proc	near
		push	si
		push	bx
		mov	cx,bx
		mov	di,bx
		add	di,data_89e
		mov	bx,data_79e
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	byte ptr [bx+1],0
		mov	byte ptr [di+1],0FFh
		mov	dx,cx
		add	dx,dx
		add	dx,46Ch
		mov	cl,[si]
		add	si,24h
		call	sprite_func_37
		mov	bx,data_81e
		lodsw				; String [si] to ax
		mov	[bx],ax
		mov	al,cl
		call	sprite_multiply_2
		inc	si
		inc	si
		mov	di,data_81e
		mov	bp,data_79e
		call	sprite_func_6
		pop	bx
		pop	si
		retn
sprite_func_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_func_4		proc	near
		cmp	byte ptr ds:data_90e,0FFh
		jne	loc_48			; Jump if not equal
		retn
loc_48:
		cmp	byte ptr ds:data_90e,0FCh
		jne	loc_49			; Jump if not equal
		retn
loc_49:
		mov	byte ptr ds:data_90e,0FFh
		mov	cl,[si]
		add	si,24h
		call	sprite_func_37
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_50			; Jump if not sign
		call	sprite_get_value
loc_50:
		push	ax
		mov	al,cl
		call	sprite_multiply_2
		add	si,2
		pop	ax
		mov	ah,[si]
		mov	dx,4A2h
		jmp	loc_64

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sprite_func_5:
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
		call	sprite_func_37
		mov	dh,[si]
		mov	al,cl
		call	sprite_multiply_2
		inc	si
		mov	bx,dx
		pop	dx
		add	dx,dx
		add	dx,ds:data_65e
		cmp	byte ptr ds:data_79e,0FFh
		je	loc_52			; Jump if equal
		cmp	byte ptr ds:data_79e,0FCh
		je	loc_52			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_51			; Jump if not sign
		call	sprite_get_value
loc_51:
		call	sprite_func_8
		pop	dx
		pop	si
		pop	bx
loc_52:
		add	dx,280h
		cmp	byte ptr ds:data_67e,1
		je	loc_54			; Jump if equal
		cmp	byte ptr ds:data_80e,0FFh
		je	loc_54			; Jump if equal
		cmp	byte ptr ds:data_80e,0FCh
		je	loc_54			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_53			; Jump if not sign
		call	sprite_get_value
loc_53:
		call	sprite_func_8
loc_54:
		pop	bx
		pop	di
		pop	si
		retn
loc_55:
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
		call	sprite_func_37
		mov	ax,[si-1]
		mov	[bx+2],ax
		pop	dx
		mov	ds:data_68e,dl
		mov	al,ds:data_67e
		neg	al
		add	al,12h
		mov	ds:data_69e,al
		add	dx,dx
		add	dx,ds:data_65e
		mov	al,cl
		call	sprite_multiply_2
		mov	di,data_81e
		mov	[di],al
		mov	bp,data_79e
		call	sprite_func_6
		cmp	byte ptr ds:data_67e,1
		je	loc_56			; Jump if equal
		add	dx,27Ch
		call	sprite_func_6
		test	byte ptr ds:data_98e,0FFh
		jz	loc_56			; Jump if zero
		test	byte ptr ds:data_95e,0FFh
		jz	loc_56			; Jump if zero
		call	sprite_check_state
loc_56:
		pop	bx
		pop	di
		pop	si
		retn
loc_57:
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
		call	sprite_func_37
		mov	dl,[si-1]
		mov	al,cl
		call	sprite_multiply_2
		mov	bl,al
		mov	bh,dl
		pop	dx
		add	dx,dx
		add	dx,ds:data_65e
		cmp	byte ptr ds:data_79e,0FFh
		je	loc_59			; Jump if equal
		cmp	byte ptr ds:data_79e,0FCh
		je	loc_59			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_58			; Jump if not sign
		call	sprite_get_value
loc_58:
		call	sprite_func_8
		pop	dx
		pop	si
		pop	bx
loc_59:
		add	dx,280h
		cmp	byte ptr ds:data_67e,1
		je	loc_61			; Jump if equal
		cmp	byte ptr ds:data_80e,0FFh
		je	loc_61			; Jump if equal
		cmp	byte ptr ds:data_80e,0FCh
		je	loc_61			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_60			; Jump if not sign
		call	sprite_get_value
loc_60:
		call	sprite_func_8
loc_61:
		pop	bx
		pop	di
		pop	si
		jmp	loc_21

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sprite_func_6:
		call	sprite_func_7

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sprite_func_7:
		cmp	byte ptr ds:[bp],0FFh
		je	loc_63			; Jump if equal
		cmp	byte ptr ds:[bp],0FCh
		je	loc_63			; Jump if equal
		mov	ah,[si]
		mov	al,[di]
		or	al,al			; Zero ?
		jns	loc_62			; Jump if not sign
		call	sprite_get_value
loc_62:
		push	bp
		push	si
		push	di
		push	dx
		call	sprite_func_8
		pop	dx
		pop	di
		pop	si
		pop	bp
loc_63:
		inc	si
		inc	di
		inc	bp
		inc	dx
		inc	dx
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sprite_func_8:
loc_64:
		push	es
		push	ds
		mov	bl,ds:data_70e
		or	al,al			; Zero ?
		jz	loc_65			; Jump if zero
		js	loc_65			; Jump if sign=1
		or	bl,80h
loc_65:
		mov	cl,al
		mov	al,ah
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		add	ax,4000h
		mov	si,ax
		mov	ds,cs:data_94e
		mov	di,dx
		mov	ax,0A000h
		mov	es,ax
		mov	ch,bl
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:data_62e[bx]
		mov	cs:data_63e,ax
		mov	al,cl
		or	ch,ch			; Zero ?
		js	loc_66			; Jump if sign=1
		push	di
		mov	di,data_119e
		call	sprite_func_11
		pop	di
		mov	si,data_119e
		mov	ax,0A000h
		mov	ds,ax
		call	sprite_func_12
		pop	ds
		pop	es
		retn
loc_66:
		push	di
		mov	di,data_56e
		call	sprite_multiply
		pop	di
		mov	si,data_119e
		mov	ax,0A000h
		mov	ds,ax
		call	sprite_func_12
		pop	ds
		pop	es
		retn
sprite_func_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_multiply		proc	near
		push	si
		push	di
		mov	al,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		call	sprite_process_loop
		pop	di
		pop	si
		jmp	short $+2		; delay for I/O

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sprite_func_10:
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,8

locloop_67:
		push	cx
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	bx,ax
		lodsw				; String [si] to ax
		xchg	al,ah
		mov	cx,ax
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	ax,bx
		or	ax,cx
		mov	bp,ax
		shl	bp,1			; Shift w/zeros fill
		or	ax,bp
		shr	bp,1			; Shift w/zeros fill
		shr	bp,1			; Shift w/zeros fill
		or	ax,bp
		xchg	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di+1],al
		dec	dx
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	al,bh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_63e
		xchg	es:[di],al
		mov	al,bl
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_63e
		xchg	es:[di+1],al
		mov	al,ch
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,byte ptr cs:data_63e+1
		xchg	es:[di],al
		mov	al,cl
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,byte ptr cs:data_63e+1
		xchg	es:[di+1],al
		dec	dx
		inc	di
		inc	di
		pop	cx
		loop	locloop_67		; Loop if cx > 0

		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn
sprite_multiply		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_func_11		proc	near
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,8

locloop_68:
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		xor	al,al			; Zero register
		xchg	es:[di],al
		xor	al,al			; Zero register
		xchg	es:[di+1],al
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_63e
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cs:data_63e
		xchg	es:[di+1],al
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,byte ptr cs:data_63e+1
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,byte ptr cs:data_63e+1
		xchg	es:[di+1],al
		dec	dx
		inc	di
		inc	di
		loop	locloop_68		; Loop if cx > 0

		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn
sprite_func_11		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_func_12		proc	near
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,4Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,4Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,4Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,4Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,4Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,4Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,4Eh
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		retn
sprite_func_12		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_process_loop		proc	near
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	cx,8

locloop_69:
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		dec	di
		dec	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		loop	locloop_69		; Loop if cx > 0

		retn
sprite_process_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_func_14		proc	near
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		retn
sprite_func_14		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_get_value		proc	near
		and	al,7Fh
		mov	bx,data_91e
		xlat				; al=[al+[bx]] table
		retn
sprite_get_value		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_multiply_2		proc	near
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
		jnz	loc_70			; Jump if not zero
		mov	si,data_84e
loc_70:
		mov	bl,ds:[bp+4]
		and	bl,1Fh
		add	bl,bl
		xor	bh,bh			; Zero register
		add	ax,[bx+si]
		mov	si,ax
		lodsb				; String [si] to al
		test	byte ptr ds:data_98e,0FFh
		jnz	loc_71			; Jump if not zero
		test	byte ptr ds:[bp+5],20h	; ' '
		jz	loc_71			; Jump if zero
		add	al,3
loc_71:
		mov	ds:data_70e,al
		mov	al,cl
		retn
sprite_multiply_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_check_state		proc	near
		cmp	byte ptr ds:data_69e,10h
		jb	loc_72			; Jump if below
		retn
loc_72:
		push	cs
		pop	es
		call	word ptr cs:[11Ah]
		and	al,0Fh
		cmp	al,0Eh
		jae	loc_73			; Jump if above or =
		retn
loc_73:
		mov	di,data_92e
		xor	cl,cl			; Zero register
loc_74:
		cmp	byte ptr [di],0FFh
		je	loc_75			; Jump if equal
		add	di,4
		inc	cl
		jmp	short loc_74
loc_75:
		cmp	cl,20h			; ' '
		jb	loc_76			; Jump if below
		retn
loc_76:
		call	word ptr cs:[11Ah]
		and	al,3
		cmp	al,3
		je	loc_76			; Jump if equal
		dec	al
		add	al,ds:data_68e
		cmp	al,0FFh
		jne	loc_77			; Jump if not equal
		mov	al,4
loc_77:
		cmp	al,1Bh
		jb	loc_78			; Jump if below
		mov	al,1Ah
loc_78:
		stosb				; Store al to es:[di]
loc_79:
		call	word ptr cs:[11Ah]
		and	al,3
		cmp	al,3
		je	loc_79			; Jump if equal
		dec	al
		add	al,ds:data_69e
		cmp	al,0FFh
		jne	loc_80			; Jump if not equal
		xor	al,al			; Zero register
loc_80:
		stosb				; Store al to es:[di]
		mov	al,3
		stosb				; Store al to es:[di]
		call	word ptr cs:[11Ah]
		and	al,3
		mov	bx,data_54e
		xlat				; al=[al+[bx]] table
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn
sprite_check_state		endp

			                        ;* No entry point to code
		add	al,byte ptr ds:[607h]
		push	cs
		pop	es
		mov	di,data_92e
		mov	si,di
		cmp	byte ptr [si],0FFh
		jne	loc_81			; Jump if not equal
		mov	byte ptr [di],0FFh
		retn
loc_81:
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
		mov	cl,[si]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	ax,cx
		add	ax,46Ch
		push	si
		push	di
		push	es
		push	ax
		mov	al,[si+3]
		mov	ds:data_71e,al
		mov	bl,[si+2]
		and	bl,3
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:data_55e[bx]
		pop	di
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	cx,10h

locloop_82:
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_71e
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_71e
		xchg	es:[di+1],al
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_71e
		xchg	es:[di+2],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_71e
		xchg	es:[di+3],al
		add	di,50h
		loop	locloop_82		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	es
		pop	di
		pop	si
		dec	byte ptr [si+2]
		cmp	byte ptr [si+2],0FFh
		je	$+7			; Jump if equal
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	si,4
		add	si,4
		jmp	$-0B8h
		db	0F1h, 39h,0B1h, 39h, 71h, 39h
		db	 31h, 39h, 00h
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
loc_83:
		jg	loc_83			; Jump if >
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
		add	data_4,bl
		add	[si],bh
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bx+si],al
                           lock	pop	es
		ror	byte ptr [bp+di],1	; Rotate
;*		loopnz	locloop_85		;*Loop if zf=0, cx>0

		db	0E0h, 01h		;  Fixup - byte match
loc_84:
		jg	loc_84			; Jump if >
		add	byte ptr [bx+si],2Fh	; '/'
		hlt				; Halt processor
		add	ds:data_81e[bx],bh
		push	cs
		pop	es
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosb				; Store al to es:[di]
		mov	di,data_78e
		mov	cx,8
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		jmp	short loc_89
			                        ;* No entry point to code
		call	vga_operation0
		mov	di,data_78e
		mov	dl,ds:data_99e
		dec	dl
		mov	cx,4

locloop_86:
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

locloop_87:
		mov	al,[bx]
		or	al,al			; Zero ?
		js	loc_88			; Jump if sign=1
		xor	al,al			; Zero register
loc_88:
		mov	[di],al
		inc	bx
		inc	di
		loop	locloop_87		; Loop if cx > 0

		inc	dl
		pop	cx
		loop	locloop_86		; Loop if cx > 0

loc_89:
		mov	al,byte ptr ds:[84h]
		xor	ah,ah			; Zero register
		mov	cx,280h
		mul	cx			; dx:ax = reg * ax
		mov	cl,byte ptr ds:[83h]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	ax,cx
		add	ax,46Ch
		mov	ds:data_66e,ax
		mov	byte ptr ds:data_68e,0
		mov	si,508Eh
		mov	di,data_78e
		mov	cx,3

locloop_90:
		push	cx
		mov	cx,3

locloop_91:
		push	cx
		mov	ax,3B12h
		push	ax
		mov	al,[di]
		or	al,[di+1]
		or	al,[di+4]
		or	al,[di+5]
		jnz	loc_92			; Jump if not zero
		jmp	loc_129
loc_92:
		test	byte ptr [di],0FFh
		jz	loc_93			; Jump if zero
		mov	al,[di]
		push	si
		call	sprite_multiply_2
		inc	si
		inc	si
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_131
loc_93:
		test	byte ptr [di+1],0FFh
		jz	loc_94			; Jump if zero
		mov	al,[di+1]
		push	si
		call	sprite_multiply_2
		inc	si
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_131
loc_94:
		test	byte ptr [di+4],0FFh
		jz	loc_95			; Jump if zero
		mov	al,[di+4]
		push	si
		call	sprite_multiply_2
		inc	si
		mov	al,[si]
		pop	si
		jmp	loc_131
loc_95:
		mov	al,[di+5]
		push	si
		call	sprite_multiply_2
		mov	cl,[si]
		pop	si
		mov	[si],al
		mov	al,cl
		jmp	loc_131
			                        ;* No entry point to code
		inc	byte ptr ds:data_68e
		inc	di
		inc	si
		pop	cx
		loop	locloop_91		; Loop if cx > 0

		pop	cx
		inc	di
		loop	locloop_90		; Loop if cx > 0

		mov	bl,ds:data_100e
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:data_62e[bx]
		mov	cs:data_63e,ax
		mov	es,cs:data_94e
		mov	al,byte ptr ds:[0E8h]
		or	al,ds:data_103e
		or	al,ds:data_104e
		jz	loc_96			; Jump if zero
		jmp	loc_106
loc_96:
		mov	cl,0FFh
		mov	si,6117h
		test	byte ptr ds:[0C2h],1
		jz	loc_97			; Jump if zero
		xor	cl,cl			; Zero register
		mov	si,61B9h
loc_97:
		test	byte ptr ds:data_107e,0FFh
		jz	loc_101			; Jump if zero
		inc	cl
		jnz	loc_98			; Jump if not zero
		mov	al,ds:data_106e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	sprite_func_19
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,62C7h
		jmp	short loc_104
loc_98:
		mov	al,ds:data_106e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:data_108e
		dec	dl
		jnz	loc_99			; Jump if not zero
		add	ax,24h
		jmp	short loc_100
loc_99:
		dec	dl
		jnz	loc_100			; Jump if not zero
		mov	ax,63h
loc_100:
		add	si,ax
		jmp	short loc_104
loc_101:
		call	sprite_func_19
		or	al,al			; Zero ?
		jz	loc_103			; Jump if zero
		dec	al
		mov	cl,al
		test	byte ptr ds:[0C2h],1
		jnz	loc_103			; Jump if not zero
		mov	ax,6Ch
		mov	dl,ds:data_102e
		and	dl,9
		xor	dh,dh			; Zero register
		add	ax,dx
		or	cl,cl			; Zero ?
		jz	loc_102			; Jump if zero
		add	ax,1Bh
loc_102:
		add	si,ax
		jmp	short loc_104
loc_103:
		test	byte ptr ds:data_102e,0FFh
		jnz	loc_106			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		cmp	al,80h
		je	loc_106			; Jump if equal
		add	al,2
		and	al,3
		test	al,1
		jnz	loc_106			; Jump if not zero
		mov	cl,9
		mul	cl			; ax = reg * al
		add	si,ax
		jmp	short loc_105
loc_104:
		test	byte ptr ds:data_102e,0FFh
		jz	loc_105			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:data_68e,3
		call	vga_operation_2
		jmp	short loc_106
loc_105:
		mov	cx,9
		mov	byte ptr ds:data_68e,0
		call	vga_operation_2
loc_106:
		mov	si,610Eh
		test	byte ptr ds:data_104e,0FFh
		jnz	loc_111			; Jump if not zero
		mov	si,60EAh
		test	byte ptr ds:data_103e,0FFh
		jnz	loc_109			; Jump if not zero
		mov	si,6075h
		test	byte ptr ds:[0C2h],1
		jnz	loc_107			; Jump if not zero
		mov	si,data_1e
loc_107:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_108			; Jump if zero
		add	si,5Ah
		jmp	short loc_109
loc_108:
		mov	ax,2Dh
		test	byte ptr ds:data_102e,0FFh
		jnz	loc_110			; Jump if not zero
		mov	ax,3Fh
		test	byte ptr ds:data_105e,80h
		jnz	loc_110			; Jump if not zero
		mov	cl,ds:data_109e
		mov	ax,48h
		dec	cl
		jz	loc_110			; Jump if zero
		mov	ax,51h
		dec	cl
		jz	loc_110			; Jump if zero
		mov	ax,36h
		cmp	byte ptr ds:data_105e,7Fh
		je	loc_110			; Jump if equal
		mov	ax,24h
		cmp	byte ptr ds:[0E7h],80h
		je	loc_110			; Jump if equal
loc_109:
		mov	al,byte ptr ds:[0E7h]
		and	al,3
		mov	cl,9
		mul	cl			; ax = reg * al
loc_110:
		add	si,ax
loc_111:
		mov	cx,9
		mov	byte ptr ds:data_68e,0
		call	vga_operation_2
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_112			; Jump if zero
		retn
loc_112:
		mov	cl,0FFh
		mov	si,61B9h
		test	byte ptr ds:[0C2h],1
		jnz	loc_113			; Jump if not zero
		xor	cl,cl			; Zero register
		mov	si,6117h
loc_113:
		mov	al,ds:data_103e
		or	al,ds:data_104e
		jz	loc_115			; Jump if zero
		call	sprite_func_19
		or	al,al			; Zero ?
		jnz	loc_114			; Jump if not zero
		retn
loc_114:
		dec	al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,1Bh
		add	al,7Eh			; '~'
		xor	ah,ah			; Zero register
		jmp	loc_122
loc_115:
		test	byte ptr ds:data_107e,0FFh
		jz	loc_119			; Jump if zero
		inc	cl
		jnz	loc_116			; Jump if not zero
		mov	al,ds:data_106e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	sprite_func_19
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,625Bh
		jmp	short loc_123
loc_116:
		mov	al,ds:data_106e
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:data_108e
		dec	dl
		jnz	loc_117			; Jump if not zero
		add	ax,24h
		jmp	short loc_118
loc_117:
		dec	dl
		jnz	loc_118			; Jump if not zero
		mov	ax,63h
loc_118:
		add	si,ax
		jmp	short loc_123
loc_119:
		test	byte ptr ds:[0C2h],1
		jz	loc_121			; Jump if zero
		call	sprite_func_19
		or	al,al			; Zero ?
		jz	loc_121			; Jump if zero
		dec	al
		mov	cl,al
		mov	al,ds:data_102e
		and	al,9
		add	al,6Ch			; 'l'
		xor	ah,ah			; Zero register
		or	cl,cl			; Zero ?
		jz	loc_120			; Jump if zero
		add	ax,1Bh
loc_120:
		add	si,ax
		jmp	short loc_123
loc_121:
		mov	ax,1Bh
		test	byte ptr ds:data_102e,0FFh
		jnz	loc_122			; Jump if not zero
		mov	cl,byte ptr ds:[0E7h]
		cmp	cl,80h
		je	loc_122			; Jump if equal
		and	cl,3
		mov	al,9
		mul	cl			; ax = reg * al
loc_122:
		add	si,ax
loc_123:
		test	byte ptr ds:data_102e,0FFh
		jz	loc_124			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:data_68e,3
		jmp	short locloop_125
loc_124:
		mov	cx,9
		mov	byte ptr ds:data_68e,0
		jmp	short locloop_125

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation_2		proc	near

locloop_125:
		push	cx
		mov	al,es:[si]
		or	al,al			; Zero ?
		jz	loc_126			; Jump if zero
		push	es
		push	ds
		push	si
		push	di
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		add	ax,6333h
		mov	si,ax
		mov	ds,cs:data_94e
		mov	di,dx
		mov	ax,0A000h
		mov	es,ax
		mov	al,cs:data_68e
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,3E90h
		mov	di,ax
		call	sprite_func_10
		pop	di
		pop	si
		pop	ds
		pop	es
loc_126:
		inc	si
		inc	byte ptr ds:data_68e
		pop	cx
		loop	locloop_125		; Loop if cx > 0

		retn
vga_operation_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_func_19		proc	near
		mov	al,byte ptr ds:[93h]
		or	al,al			; Zero ?
		jnz	loc_127			; Jump if not zero
		retn
loc_127:
		cmp	al,4
		mov	al,1
		jnc	loc_128			; Jump if carry=0
		retn
loc_128:
		mov	al,2
		retn
sprite_func_19		endp

loc_129:
		mov	al,[si]
		push	ds
		push	si
		push	di
		push	ax
		mov	ds,cs:data_94e
		mov	ax,0A000h
		mov	es,ax
		mov	al,cs:data_68e
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,3E90h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_130			; Jump if zero
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		call	sprite_process_loop
		pop	di
		pop	si
		pop	ds
		retn
loc_130:
		call	sprite_func_14
		pop	di
		pop	si
		pop	ds
		retn
loc_131:
		push	ds
		push	si
		push	di
		mov	cl,al
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_132			; Jump if not sign
		call	sprite_get_value
loc_132:
		push	ax
		mov	bl,ds:data_70e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	dx,cs:data_62e[bx]
		mov	cs:data_63e,dx
		mov	al,cl
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		add	ax,4000h
		mov	si,ax
		mov	ds,cs:data_94e
		mov	ax,0A000h
		mov	es,ax
		mov	al,cs:data_68e
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,3E90h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_133			; Jump if zero
		mov	cl,al
		call	sprite_multiply
		pop	di
		pop	si
		pop	ds
		retn
loc_133:
		call	sprite_func_11
		pop	di
		pop	si
		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation0		proc	near
		mov	cl,byte ptr ds:[84h]
		mov	al,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		add	ax,ds:data_96e
		mov	si,ax
		call	sprite_func_37
		mov	di,data_81e
		push	cs
		pop	es
		mov	cx,3

locloop_134:
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	si,21h
		call	sprite_func_37
		loop	locloop_134		; Loop if cx > 0

		retn
vga_operation0		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation1		proc	near
		mov	al,ds:data_67e
		neg	al
		add	al,12h
		mov	cl,al
		test	byte ptr ds:data_110e,0FFh
		jnz	loc_136			; Jump if not zero
		mov	al,byte ptr ds:[84h]
		sub	al,2
		cmp	al,cl
		jne	loc_ret_135		; Jump if not equal
		call	vga_operation_3

loc_ret_135:
		retn
loc_136:
		mov	al,byte ptr ds:[84h]
		sub	al,5
		cmp	cl,al
		jae	loc_137			; Jump if above or =
		retn
loc_137:
		jnz	loc_138			; Jump if not zero
		call	vga_operation2
		jmp	loc_164
loc_138:
		add	al,0Ah
		cmp	al,cl
		je	loc_139			; Jump if equal
		retn
loc_139:
		jmp	loc_154
			                        ;* No entry point to code
		test	byte ptr ds:data_110e,0FFh
		jnz	loc_140			; Jump if not zero
		retn
loc_140:
		push	es
		push	si
		push	di
		push	bx
		mov	es,cs:data_94e
		inc	byte ptr ds:data_113e
		mov	al,ds:data_112e
		or	al,al			; Zero ?
		jz	loc_144			; Jump if zero
		dec	al
		jz	loc_142			; Jump if zero
		cmp	byte ptr ds:data_113e,5
		jb	loc_141			; Jump if below
		jmp	loc_148
loc_141:
		xor	cl,cl			; Zero register
		mov	si,0B16Eh
		mov	word ptr ds:data_74e,0FF01h
		mov	dx,27Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_146			; Jump if not zero
		mov	si,0B0BEh
		mov	word ptr ds:data_74e,1
		mov	dx,280h
		jmp	short loc_146
loc_142:
		cmp	byte ptr ds:data_113e,5
		jb	loc_143			; Jump if below
		jmp	loc_148
loc_143:
		mov	bl,ds:data_113e
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B19Eh
		mov	si,0B12Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_145			; Jump if not zero
		mov	di,0B18Ah
		mov	si,0B07Eh
		jmp	short loc_145
loc_144:
		cmp	byte ptr ds:data_113e,7
		jae	loc_148			; Jump if above or =
		mov	bl,ds:data_113e
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B192h
		mov	si,0B0CEh
		test	byte ptr ds:[0C2h],1
		jnz	loc_145			; Jump if not zero
		mov	di,data_3e
		mov	si,0B01Eh
loc_145:
		mov	bx,es:[bx+di]
		mov	ds:data_74e,bx
		mov	al,bl
		cbw				; Convrt byte to word
		mov	dx,280h
		imul	dx			; dx:ax = reg * ax
		mov	dx,ax
		mov	al,bh
		cbw				; Convrt byte to word
		add	ax,ax
		add	dx,ax
loc_146:
		mov	di,ds:data_66e
		add	di,dx
		test	byte ptr ds:data_102e,0FFh
		jz	loc_147			; Jump if zero
		add	di,280h
loc_147:
		mov	ds:data_72e,di
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	si,cx
		mov	ds:data_73e,si
		pop	bx
		pop	di
		pop	si
		pop	es
		jmp	loc_154
loc_148:
		mov	byte ptr ds:data_110e,0
		mov	byte ptr ds:data_113e,0
		pop	bx
		pop	di
		pop	si
		pop	es
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vga_operation2:
		test	byte ptr ds:data_111e,0FFh
		jnz	loc_149			; Jump if not zero
		retn
loc_149:
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	vga_operation4
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	byte ptr ds:data_111e,0
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vga_operation3:
		mov	si,cs:data_72e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	di,data_121e
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,20h

locloop_150:
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	si,48h
		loop	locloop_150		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vga_operation4:
		mov	di,cs:data_72e
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,data_121e
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,20h

locloop_151:
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,48h
		loop	locloop_151		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vga_operation5:
		mov	al,byte ptr ds:[84h]
		add	al,ds:data_74e
		and	al,3Fh			; '?'
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,byte ptr ds:data_74e+1
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		mov	si,ax
		add	si,ds:data_96e
		call	sprite_func_37
		mov	cx,4

locloop_152:
		push	cx
		mov	cx,4

locloop_153:
		push	cx
		mov	bl,[si]
		inc	si
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	word ptr ds:data_82e[bx],0
		pop	cx
		loop	locloop_153		; Loop if cx > 0

		add	si,20h
		call	sprite_func_37
		pop	cx
		loop	locloop_152		; Loop if cx > 0

		retn
loc_154:
		test	byte ptr ds:data_110e,0FFh
		jnz	loc_155			; Jump if not zero
		retn
loc_155:
		mov	byte ptr ds:data_111e,0FFh
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	vga_operation5
		call	vga_operation3
		mov	bl,byte ptr cs:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,cs:data_57e[bx]
		mov	cs:data_71e,al
		mov	ds,cs:data_94e
		mov	ax,0A000h
		mov	es,ax
		mov	di,cs:data_72e
		mov	si,cs:data_73e
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	cx,4
loc_156:
		push	cx
		mov	cx,4
loc_157:
		push	cx
		lodsb				; String [si] to al
		push	si
		mov	bx,280h
		cmp	al,0FFh
		jne	loc_158			; Jump if not equal
		jmp	loc_159
loc_158:
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,ds:data_2e
		mov	cl,cs:data_71e
		mov	bx,50h
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
loc_159:
		add	di,bx
		pop	si
		pop	cx
		loop	locloop_160		; Loop if cx > 0

		jmp	short loc_161

locloop_160:
		jmp	loc_157
loc_161:
		add	di,0F602h
		pop	cx
		loop	locloop_162		; Loop if cx > 0

		jmp	short loc_163

locloop_162:
		jmp	loc_156
loc_163:
		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
vga_operation1		endp

			                        ;* No entry point to code
		add	[si],ax
		add	ax,[bx+di]
		add	al,6
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	ds:data_66e,ax
		jmp	short loc_166

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation_3		proc	near
loc_164:
		test	byte ptr ds:data_101e,0FFh
		jz	loc_165			; Jump if zero
		retn
loc_165:
		mov	byte ptr ds:data_101e,0FFh
loc_166:
		push	es
		push	ds
		push	si
		push	di
		push	bx
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,data_120e
		mov	di,cs:data_66e
		mov	cx,3

locloop_167:
		push	cx
		mov	cx,3

locloop_168:
		push	cx
		push	di
		call	sprite_func_12
		pop	di
		inc	di
		inc	di
		pop	cx
		loop	locloop_168		; Loop if cx > 0

		add	di,27Ah
		pop	cx
		loop	locloop_167		; Loop if cx > 0

		pop	bx
		pop	di
		pop	si
		pop	ds
		pop	es
		retn
vga_operation_3		endp

			                        ;* No entry point to code
		push	ds
		push	si
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:data_94e
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

locloop_169:
		push	cx
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		lodsw				; String [si] to ax
		mov	cx,ax
		lodsw				; String [si] to ax
		mov	bx,ax
		lodsw				; String [si] to ax
		mov	bp,ax
		or	ax,cx
		or	ax,bx
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		xor	al,al			; Zero register
		xchg	es:[di+1],al
		dec	dx
		mov	ax,1003h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	al,cl
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di],al
		mov	al,ch
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di+1],al
		mov	al,bl
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di],al
		mov	al,bh
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di+1],al
		mov	ax,bp
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,4
		xchg	es:[di+1],al
		dec	dx
		add	di,50h
		pop	cx
		loop	locloop_169		; Loop if cx > 0

		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	si
		pop	ds
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_111e,0
		mov	ax,0A000h
		mov	es,ax
		mov	byte ptr ds:data_76e,8
loc_170:
		mov	word ptr ds:data_65e,46Ch
		mov	byte ptr ds:data_93e,0
		mov	si,ds:data_96e
		mov	di,data_89e
		mov	cx,12h

locloop_171:
		push	cx
		add	si,4
		xor	bx,bx			; Zero register
		mov	cx,1Ch

locloop_172:
		push	cx
		lodsb				; String [si] to al
		call	vga_operation7
		inc	di
		inc	bl
		pop	cx
		loop	locloop_172		; Loop if cx > 0

		add	si,4
		call	sprite_func_37
		add	word ptr ds:data_65e,280h
		pop	cx
		loop	locloop_171		; Loop if cx > 0

loc_173:
		cmp	byte ptr ds:data_93e,10h
		jb	loc_173			; Jump if below
		dec	byte ptr ds:data_76e
		jnz	loc_170			; Jump if not zero
		mov	dx,3CEh
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation7		proc	near
		cmp	byte ptr [di],0FFh
		jne	loc_174			; Jump if not equal
		retn
loc_174:
		cmp	byte ptr [di],0FCh
		jne	loc_175			; Jump if not equal
		retn
loc_175:
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
		mov	dx,3CEh
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		add	bx,bx
		add	bx,ds:data_65e
		mov	di,bx
		pop	ax
		test	al,0FFh
		jz	loc_177			; Jump if zero
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:data_94e
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		push	si
		push	di
		mov	al,cs:data_76e
		and	al,3
		neg	al
		add	al,3
		call	sprite_func_30
		call	vga_operation8
		pop	di
		pop	si
		mov	al,cs:data_76e
		call	sprite_func_30
		inc	di
		inc	si
		call	vga_operation8
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

vga_operation8:
		mov	cx,2

locloop_176:
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsb				; String [si] to al
		xchg	es:[di],al
		inc	si
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsb				; String [si] to al
		xchg	es:[di],al
		inc	si
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsb				; String [si] to al
		xchg	es:[di],al
		add	di,140h
		add	si,13h
		loop	locloop_176		; Loop if cx > 0

		retn
loc_177:
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		push	di
		mov	al,cs:data_76e
		and	al,3
		neg	al
		add	al,3
		call	sprite_func_30
		call	vga_operation9
		pop	di
		mov	al,cs:data_76e
		call	sprite_func_30
		inc	di
		call	vga_operation9
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn
vga_operation7		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation9		proc	near
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,data_115e
		xor	al,al			; Zero register
		xchg	es:[di],al
		retn
vga_operation9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_func_30		proc	near
		and	al,3
		add	al,al
		xor	ah,ah			; Zero register
		mov	bx,data_58e
		add	bx,ax
		mov	al,cs:[bx]
		add	si,ax
		mov	al,cs:[bx+1]
		add	di,ax
		retn
sprite_func_30		endp

		db	 00h, 00h, 06h, 50h, 0Ch,0A0h
		db	 12h,0F0h,0A0h, 83h, 00h, 02h
		db	0C0h, 02h,0C0h, 02h,0C0h, 8Ah
		db	 26h, 84h, 00h, 02h,0E4h, 02h
		db	0E4h, 02h,0E4h,0A2h, 67h, 50h
		db	 88h, 26h, 68h, 50h,0E8h, 23h
		db	 02h,0C6h, 06h, 78h, 50h, 06h
		db	0E8h, 0Bh, 00h,0C6h, 06h, 78h
		db	 50h, 00h,0E8h, 03h, 00h,0E9h
		db	 10h, 02h,0A0h, 67h, 50h,0FEh
		db	0C8h, 8Ah,0D8h, 04h, 19h, 8Ah
		db	0D0h,0A0h, 68h, 50h,0FEh,0C8h
		db	 8Ah,0F8h, 04h, 19h, 8Ah,0F0h
		db	0E8h, 2Fh, 00h,0A0h, 67h, 50h
		db	 2Ch, 05h, 8Ah,0D8h, 04h, 21h
		db	 8Ah,0D0h,0A0h, 68h, 50h, 2Ch
		db	 05h, 8Ah,0F8h, 04h, 21h, 8Ah
		db	0F0h,0E8h, 16h, 00h,0A0h, 67h
		db	 50h, 2Ch, 09h, 8Ah,0D8h, 04h
		db	 29h, 8Ah,0D0h,0A0h, 68h, 50h
		db	 2Ch, 09h, 8Ah,0F8h, 04h, 29h
		db	 8Ah,0F0h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_process_loop_2		proc	near
		mov	cx,9

locloop_178:
		push	cx
		push	dx
		push	bx
		call	vga_operation_4
		pop	bx
		pop	dx
		sub	bl,0Ch
		jnc	loc_179			; Jump if carry=0
		xor	bl,bl			; Zero register
loc_179:
		sub	bh,0Ch
		jnc	loc_180			; Jump if carry=0
		xor	bh,bh			; Zero register
loc_180:
		add	dl,0Ch
		jnc	loc_181			; Jump if carry=0
		mov	dl,0FFh
loc_181:
		add	dh,0Ch
		jnc	loc_182			; Jump if carry=0
		mov	dh,0FFh
loc_182:
		push	dx
		push	bx
		call	sprite_multiply_4
		pop	bx
		pop	dx
		pop	cx
		loop	locloop_178		; Loop if cx > 0

		retn
sprite_process_loop_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

vga_operation_4		proc	near
		push	dx
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	dx
		push	dx
		push	bx
		mov	dh,bh
		call	sprite_extract_bits_2
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	bh,dh
		call	sprite_extract_bits_2
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	dl,bl
		call	sprite_extract_bits
		pop	bx
		pop	dx
		mov	bl,dl
		call	sprite_extract_bits
		mov	dx,3CEh
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn
vga_operation_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_extract_bits		proc	near
		cmp	dh,bh
		jae	loc_183			; Jump if above or =
		xchg	dx,bx
loc_183:
		or	bl,bl			; Zero ?
		jnz	loc_184			; Jump if not zero
		retn
loc_184:
		cmp	bl,0DFh
		jb	loc_185			; Jump if below
		retn
loc_185:
		or	bh,bh			; Zero ?
		jnz	loc_186			; Jump if not zero
		mov	bh,1
loc_186:
		cmp	dh,8Fh
		jb	loc_187			; Jump if below
		mov	dh,8Eh
loc_187:
		mov	al,dh
		sub	al,bh
		inc	al
		push	ax
		mov	al,bh
		call	sprite_multiply_3
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		pop	cx
		xor	ch,ch			; Zero register
		and	bl,3
		jz	loc_190			; Jump if zero
		cmp	bl,2
		jb	loc_189			; Jump if below
		jz	loc_188			; Jump if zero
		mov	ah,3
		jmp	short loc_191
loc_188:
		mov	ah,0Ch
		jmp	short loc_191
loc_189:
		mov	ah,30h			; '0'
		jmp	short loc_191
loc_190:
		mov	ah,0C0h
loc_191:
		mov	dx,3CEh
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask

locloop_192:
		mov	al,ds:data_76e
		xchg	es:[di],al
		add	di,50h
		loop	locloop_192		; Loop if cx > 0

		retn
sprite_extract_bits		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_extract_bits_2		proc	near
		cmp	dl,bl
		jae	loc_193			; Jump if above or =
		xchg	dx,bx
loc_193:
		or	bh,bh			; Zero ?
		jnz	loc_194			; Jump if not zero
		retn
loc_194:
		cmp	bh,8Fh
		jb	loc_195			; Jump if below
		retn
loc_195:
		or	bl,bl			; Zero ?
		jnz	loc_196			; Jump if not zero
		mov	bl,1
loc_196:
		cmp	dl,0DFh
		jb	loc_197			; Jump if below
		mov	dl,0DEh
loc_197:
		mov	al,bh
		call	sprite_multiply_3
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
		jz	loc_200			; Jump if zero
		cmp	bl,2
		jb	loc_199			; Jump if below
		jz	loc_198			; Jump if zero
		mov	al,3
		jmp	short loc_201
loc_198:
		mov	al,0Fh
		jmp	short loc_201
loc_199:
		mov	al,3Fh			; '?'
		jmp	short loc_201
loc_200:
		mov	al,0FFh
loc_201:
		and	dl,3
		jz	loc_204			; Jump if zero
		cmp	dl,2
		jb	loc_203			; Jump if below
		jz	loc_202			; Jump if zero
		mov	ah,0FFh
		jmp	short loc_205
loc_202:
		mov	ah,0FCh
		jmp	short loc_205
loc_203:
		mov	ah,0F0h
		jmp	short loc_205
loc_204:
		mov	ah,0C0h
loc_205:
		push	ax
		mov	dx,3CEh
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		pop	ax
		jcxz	loc_208			; Jump if cx=0
		dec	cx
		jcxz	loc_207			; Jump if cx=0
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_76e
		xchg	es:[di],al
		inc	di
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func

locloop_206:
		mov	al,ds:data_76e
		xchg	es:[di],al
		inc	di
		loop	locloop_206		; Loop if cx > 0

		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_76e
		xchg	es:[di],al
		retn
loc_207:
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_76e
		xchg	es:[di],al
		inc	di
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_76e
		xchg	es:[di],al
		retn
loc_208:
		and	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:data_76e
		xchg	es:[di],al
		retn
sprite_extract_bits_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_multiply_3		proc	near
		mov	ah,50h			; 'P'
		mul	ah			; ax = reg * al
		mov	di,46Ch
		add	di,ax
		retn
sprite_multiply_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_multiply_4		proc	near
		mov	cl,ds:data_97e
		shr	cl,1			; Shift w/zeros fill
		inc	cl
		mov	al,1
		mul	cl			; ax = reg * al
loc_209:
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		cmp	ds:data_93e,al
		jb	loc_209			; Jump if below
		mov	byte ptr ds:data_93e,0
		retn
sprite_multiply_4		endp

			                        ;* No entry point to code
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,1803h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	di,data_116e
		mov	cx,8

locloop_210:
		push	cx
		push	di
		mov	cx,12h

locloop_211:
		push	cx
		push	di
		mov	cx,38h

locloop_212:
		mov	al,2
		xchg	es:[di],al
		inc	di
		loop	locloop_212		; Loop if cx > 0

		pop	di
		add	di,280h
		pop	cx
		loop	locloop_211		; Loop if cx > 0

		pop	di
		add	di,50h
		pop	cx
		loop	locloop_210		; Loop if cx > 0

		mov	dx,3CEh
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		retn
			                        ;* No entry point to code
		and	al,3Fh			; '?'
		mov	bl,ah
		xor	ah,ah			; Zero register
		mov	dx,280h
		mul	dx			; dx:ax = reg * ax
		sub	bl,4
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		mov	di,ax
		add	di,46Ch
		retn
			                        ;* No entry point to code
		mov	bl,byte ptr ds:[9Dh]
		or	bl,bl			; Zero ?
		jnz	loc_213			; Jump if not zero
		retn
loc_213:
		cmp	bl,7
		jne	loc_214			; Jump if not equal
		retn
loc_214:
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		push	ds
		mov	ax,cs
		add	ax,1000h
		mov	es,ax
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	si,[bx]
		mov	di,data_114e
		mov	cx,480h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_func_37		proc	near
		cmp	si,0E900h
		jae	loc_215			; Jump if above or =
		retn
loc_215:
		sub	si,900h
		retn
sprite_func_37		endp

			                        ;* No entry point to code
		cmp	si,0E000h
		jb	loc_216			; Jump if below
		retn
loc_216:
		add	si,900h
		retn
			                        ;* No entry point to code
		push	si
		push	ds
		mov	si,data_59e
		mov	di,data_117e
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	cx,5

locloop_217:
		push	cx
		mov	cx,1Ch

locloop_218:
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

locloop_219:
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di],al
		inc	di
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,2
		xchg	es:[di],al
		add	di,4Fh
		loop	locloop_219		; Loop if cx > 0

		pop	di
		inc	di
		inc	di
		pop	si
		pop	ds
		pop	cx
		loop	locloop_218		; Loop if cx > 0

		add	di,248h
		pop	cx
		loop	locloop_217		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
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
		db	 3Fh, 06h,0A2h, 78h, 50h,0BEh
		db	0E5h, 48h,0C7h, 06h, 69h, 50h
		db	 6Ch, 04h,0B9h, 12h, 00h

locloop_220:
		push	cx
		mov	cx,1Ch

locloop_221:
		push	cx
		lodsb				; String [si] to al
		push	si
		call	copy_vga_buffer
		pop	si
		add	word ptr ds:data_65e,2
		pop	cx
		loop	locloop_221		; Loop if cx > 0

		add	word ptr ds:data_65e,248h
		pop	cx
		loop	locloop_220		; Loop if cx > 0

		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

copy_vga_buffer		proc	near
		push	ds
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:data_94e
		mov	ax,0A000h
		mov	es,ax
		mov	di,cs:data_65e
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	bx,offset data_5
		mov	cx,4

locloop_222:
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		dec	di
		dec	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		add	di,bx
		mov	al,1
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 3C5h, EGA sequencr func
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		dec	di
		dec	di
		mov	al,4
		out	dx,al			; port 3C5h, EGA sequencr func
		movsw				; Mov [si] to es:[di]
		add	di,bx
		loop	locloop_222		; Loop if cx > 0

		mov	al,7
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	dx,3CEh
		mov	ax,0A05h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	bl,cs:data_76e
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:data_60e[bx]	;*
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		mov	ax,0F02h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 2, color compare bits
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn
copy_vga_buffer		endp

		db	 66h, 48h, 77h, 48h, 7Fh, 48h
		db	 90h, 48h,0AAh, 48h,0B8h, 02h
		db	 06h,0EFh,0B3h, 03h,0E8h, 55h
		db	 00h,0B8h, 02h, 07h,0EFh,0B3h
		db	 05h,0EBh, 4Dh,0B8h, 02h, 04h
		db	0EFh,0B3h, 02h,0EBh, 45h,0B8h
		db	 02h, 04h,0EFh,0B3h, 05h,0E8h
		db	 3Ch, 00h,0B8h, 02h, 07h,0EFh
		db	0B3h, 04h,0EBh, 34h,0B8h, 02h
		db	 04h,0EFh,0B3h, 03h,0E8h, 2Bh
		db	 00h,0B8h, 02h, 07h,0EFh,0B3h
		db	 05h,0E8h, 22h, 00h,0B8h, 02h
		db	 06h,0EFh,0B3h, 07h,0EBh, 1Ah
		db	0B8h, 02h, 07h,0EFh,0B3h, 05h
		db	0E8h, 11h, 00h,0B8h, 02h, 04h
		db	0EFh,0B3h, 07h,0E8h, 08h, 00h
		db	0B8h, 02h, 06h,0EFh,0B3h, 04h
		db	0EBh, 00h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sprite_process_loop_3		proc	near
loc_223:
		mov	si,cs:data_65e
		mov	di,4Fh
		mov	al,8
		mov	cx,8

locloop_224:
		mov	ah,es:[si]
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		mov	es:[si],bl
		inc	si
		mov	ah,es:[si]
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		mov	es:[si],bl
		add	si,di
		loop	locloop_224		; Loop if cx > 0

		retn
sprite_process_loop_3		endp

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
		sbb	ds:data_83e,bh
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
		db	 1Eh, 50h,0B8h, 50h, 00h,0F6h
		db	0E3h, 8Ah,0DFh, 32h,0FFh, 03h
		db	0C3h, 8Bh,0F8h, 58h,0B1h, 20h
		db	0F6h,0E1h, 05h, 00h, 60h, 8Bh
		db	0F0h, 2Eh, 8Eh, 1Eh, 2Ch,0FFh
		db	0B8h, 00h,0A0h, 8Eh,0C0h,0BAh
		db	0C4h, 03h,0B0h, 02h,0EEh, 42h
		db	0BBh, 4Eh, 00h,0B9h, 04h, 00h

locloop_225:
		mov	al,1
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		add	di,bx
		mov	al,1
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		movsw				; Mov [si] to es:[di]
		mov	al,2
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		lodsw				; String [si] to ax
		mov	es:[di-2],ax
		add	di,bx
		loop	locloop_225		; Loop if cx > 0

		pop	ds
		retn
			                        ;* No entry point to code
		push	ds
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_61e[bx]
		mov	di,data_118e
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	cx,18h

locloop_226:
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di],al
		inc	di
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di],al
		inc	di
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di],al
		inc	di
		lodsb				; String [si] to al
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,1
		xchg	es:[di],al
		add	di,4Dh
		loop	locloop_226		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	ds
		retn
			                        ;* No entry point to code
		xchg	sp,ax
		dec	bx
		xchg	sp,ax
		dec	bx
		xchg	sp,ax
		dec	bx
		hlt				; Halt processor
		dec	bx
		hlt				; Halt processor
		dec	bx
		push	sp
		dec	sp
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
		db	0E2h, 05h, 5Ah, 4Dh, 8Bh,0F0h
		db	0BDh, 01h, 00h,0EBh, 0Eh, 24h
		db	 01h, 8Ah,0E0h, 32h,0C0h, 05h
		db	 5Ah, 4Eh, 8Bh,0F0h,0BDh, 04h
		db	 00h, 8Ah,0C3h, 24h, 03h, 02h
		db	0C0h,0A2h, 79h, 50h,0D1h,0EBh
		db	0D1h,0EBh,0B0h, 50h,0F6h,0E1h
		db	 03h,0C3h, 8Bh,0F8h,0B8h, 00h
		db	0A0h, 8Eh,0C0h,0BAh,0C4h, 03h
		db	0B8h, 02h, 07h,0EFh,0BAh,0CEh
		db	 03h,0B8h, 05h, 02h,0EFh,0B0h
		db	 08h,0EEh, 42h, 8Bh,0CDh,0BDh
		db	 4Ch, 00h

locloop_227:
		push	cx
		push	di
		mov	cx,10h

locloop_228:
		push	cx
		mov	cx,2

locloop_229:
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
		mov	al,bh
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		mov	al,1
		xchg	es:[di],al
		inc	di
		mov	al,bl
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		mov	al,1
		xchg	es:[di],al
		inc	di
		mov	al,ah
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		mov	al,1
		xchg	es:[di],al
		pop	cx
		loop	locloop_229		; Loop if cx > 0

		add	di,bp
		pop	cx
		loop	locloop_228		; Loop if cx > 0

		pop	di
		add	di,4
		pop	cx
		loop	locloop_227		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 0FFFFh ??I/O Non-standard
		mov	ax,0FF08h
		out	dx,ax			; port 0FFFFh ??I/O Non-standard
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
		db	 01h, 02h, 02h, 04h, 01h, 04h
		db	 05h, 06h, 06h, 05h, 05h, 06h
		db	0C3h
		db	304 dup (0)

seg_a		ends



		end	start
