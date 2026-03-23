
PAGE  59,132

;==========================================================================
;
;  ENEMY_GOBLIN - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	8000h			;*
data_39e	equ	2000h			;*
data_40e	equ	2002h			;*
data_41e	equ	2010h			;*
data_42e	equ	2012h			;*
data_43e	equ	2014h			;*
data_44e	equ	2016h			;*
data_45e	equ	2040h			;*
data_46e	equ	2044h			;*
data_47e	equ	3016h			;*
data_48e	equ	301Ch			;*
data_49e	equ	3022h			;*
data_50e	equ	6004h			;*
data_51e	equ	6006h			;*
data_52e	equ	6008h			;*
data_53e	equ	600Ah			;*
data_54e	equ	600Ch			;*
data_55e	equ	600Eh			;*
data_56e	equ	0A0B8h			;*
data_57e	equ	0A6C8h			;*
data_58e	equ	0A839h			;*
data_59e	equ	0A8BBh			;*
data_60e	equ	0A8E3h			;*
data_61e	equ	0A8EEh			;*
data_62e	equ	0A8FAh			;*
data_63e	equ	0A8FBh			;*
data_64e	equ	0A951h			;*
data_65e	equ	0A96Dh			;*
data_66e	equ	0AD1Eh			;*
data_67e	equ	0AD1Fh			;*
data_68e	equ	0AD21h			;*
data_69e	equ	0AD22h			;*
data_70e	equ	0AD23h			;*
data_71e	equ	0AD24h			;*
data_72e	equ	0AD25h			;*
data_73e	equ	0AD26h			;*
data_74e	equ	0AD27h			;*
data_75e	equ	0AD29h			;*
data_76e	equ	0AD2Ah			;*
data_77e	equ	0AD2Ch			;*
data_78e	equ	0AD2Dh			;*
data_79e	equ	0AD2Fh			;*
data_80e	equ	0C006h			;*
data_81e	equ	0FF2Ch			;*
data_82e	equ	0FF4Ch			;*
data_83e	equ	0FF4Eh			;*
data_84e	equ	0FF4Fh			;*
data_85e	equ	0FF50h			;*
data_86e	equ	0FF52h			;*
data_87e	equ	0FF53h			;*
data_88e	equ	0FF54h			;*
data_89e	equ	0FF57h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_13		proc	far

start:
		cmp	[di],cl
		add	[bx+si],al
		add	al,0A0h
		sub	byte ptr ds:[68Eh][bx],ah
		sub	al,0FFh
		mov	di,8000h
		mov	si,data_60e
		mov	al,2
		call	word ptr cs:data_7
		push	ds
		mov	ds,cs:data_81e
		mov	si,data_1e
		mov	cx,100h
		call	word ptr cs:data_46e
		pop	ds
		mov	byte ptr ds:data_83e,0
		mov	byte ptr ds:data_84e,0
		mov	byte ptr ds:data_66e,0
		call	word ptr cs:data_40e
		call	word ptr cs:data_42e
		mov	si,data_61e
		call	word ptr cs:data_41e
		call	goblin_process_loop
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_39e
		mov	byte ptr ds:data_68e,0FFh
		mov	word ptr ds:data_67e,0A773h
		mov	word ptr ds:data_82e,0A989h
		call	word ptr cs:data_50e
		mov	cx,5

locloop_1:
		push	cx
		mov	byte ptr ds:[0FF1Ah],0
		mov	word ptr ds:data_82e,0A98Bh
		call	word ptr cs:data_50e
loc_2:
		call	goblin_multiply
		cmp	byte ptr ds:[0FF1Ah],3Fh	; '?'
		jb	loc_2			; Jump if below
		pop	cx
		loop	locloop_1		; Loop if cx > 0

		mov	byte ptr ds:data_68e,0
		mov	word ptr ds:data_82e,0A98Dh
loc_3:
		call	word ptr cs:data_50e
		cmp	al,0FFh
		je	loc_4			; Jump if equal
		call	goblin_func_1
		jmp	short loc_3
loc_4:
		jmp	word ptr cs:data_45e

zr2_13		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

goblin_func_1		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:data_56e[bx]	;*
goblin_func_1		endp

		db	0C0h,0A0h,0D2h,0A0h,0F3h,0A5h
		db	 19h,0A6h,0C6h, 06h, 1Ah,0FFh
		db	 00h, 80h, 3Eh, 1Ah,0FFh, 3Ch
		db	 72h,0F9h,0BEh, 2Fh,0A8h,0E9h
		db	 41h, 07h,0E8h, 4Ah, 05h,0BBh
		db	 1Dh, 28h,0B9h, 37h, 1Ah,0B0h
		db	0FFh, 2Eh,0FFh, 16h, 00h, 20h
		db	0C7h, 06h, 54h,0FFh, 20h, 28h
		db	0C6h, 06h, 52h,0FFh, 05h,0C6h
		db	 06h, 53h,0FFh, 05h,0B9h, 05h
		db	 00h,0BEh, 0Ch,0A9h, 2Eh,0FFh
		db	 16h, 0Eh, 60h,0C6h, 06h, 56h
		db	0FFh, 00h, 8Ah, 1Eh, 1Eh,0ADh
		db	 2Eh,0FFh
data_7		dw	1016h
		db	 60h, 73h, 02h, 32h,0DBh, 88h
		db	 1Eh, 1Eh,0ADh, 32h,0FFh, 03h
		db	0DBh,0FFh,0A7h, 1Bh,0A1h, 25h
		db	0A1h, 4Bh,0A1h, 3Bh,0A2h,0D0h
		db	0A3h, 95h,0A5h,0E8h,0F7h, 04h
		db	0C7h, 06h, 4Ch,0FFh,0D4h,0ACh
		db	0F6h, 06h, 24h,0ADh,0FFh, 74h
		db	 01h,0C3h
loc_5:
		mov	word ptr ds:data_82e,0AC9Dh
		test	byte ptr ds:data_70e,0FFh
		jz	loc_6			; Jump if zero
		retn
loc_6:
		mov	word ptr ds:data_82e,0AC5Ah
		retn
			                        ;* No entry point to code
		call	goblin_func_2
		mov	byte ptr ds:data_68e,0
		mov	si,data_59e
		call	goblin_process_loop_2
		test	word ptr ds:[8Bh],0FFFFh
		mov	word ptr ds:data_82e,0A9B2h
		jnz	loc_7			; Jump if not zero
		retn
loc_7:
		mov	bl,ds:data_80e
		xor	bh,bh			; Zero register
		dec	bl
		add	bx,bx
		mov	al,ds:data_62e[bx]
		mov	ds:data_72e,al
		mov	al,ds:data_63e[bx]
		mov	ds:data_73e,al
		mov	word ptr ds:data_82e,0A9D9h
		call	word ptr cs:data_50e
		mov	al,ds:data_72e
		add	al,30h			; '0'
		mov	ds:data_74e,al
		mov	word ptr ds:data_82e,0AD27h
		call	word ptr cs:data_50e
		mov	word ptr ds:data_82e,0A9F1h
		call	word ptr cs:data_50e
		mov	al,ds:data_73e
		add	al,30h			; '0'
		mov	ds:data_74e,al
		mov	word ptr ds:data_82e,0AD27h
		call	word ptr cs:data_50e
		mov	word ptr ds:data_82e,0A9FDh
		call	word ptr cs:data_50e
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_39e
		mov	word ptr ds:data_88e,302Eh
		call	word ptr cs:data_52e
		mov	word ptr ds:data_82e,0AA48h
		jnc	loc_8			; Jump if carry=0
		retn
loc_8:
		mov	ax,word ptr ds:[8Bh]
		mov	dl,ds:data_72e
		xor	dh,dh			; Zero register
		sub	ax,dx
		mov	word ptr ds:data_82e,0AA1Dh
		jnc	loc_9			; Jump if carry=0
		retn
loc_9:
		push	dx
		call	goblin_func_2
		pop	dx
		mov	byte ptr ds:data_70e,0FFh
		mov	word ptr ds:data_82e,0AA82h
loc_10:
		xor	cx,cx			; Zero register
loc_11:
		mov	ax,word ptr ds:[8Bh]
		sub	ax,dx
		jnc	loc_12			; Jump if carry=0
		retn
loc_12:
		push	cx
		mov	word ptr ds:[8Bh],ax
		push	dx
		xor	dl,dl			; Zero register
		mov	al,ds:data_73e
		xor	ah,ah			; Zero register
		call	word ptr cs:data_54e
		call	word ptr cs:data_44e
		call	word ptr cs:data_43e
		pop	dx
		pop	cx
		inc	cx
		and	cx,7
		jnz	loc_11			; Jump if not zero
		jmp	short loc_10
			                        ;* No entry point to code
		call	goblin_func_2
		mov	byte ptr ds:data_68e,0
		mov	si,data_59e
		call	goblin_process_loop_2
		mov	word ptr ds:data_82e,0AAA1h
		mov	ax,word ptr ds:[86h]
		mov	dl,byte ptr ds:[85h]
		or	dl,al
		or	dl,ah
		jnz	loc_13			; Jump if not zero
		retn
loc_13:
		mov	word ptr ds:data_82e,0AACAh
		call	word ptr cs:data_50e
		mov	bx,2C1Dh
		mov	cx,1237h
		mov	al,0FFh
		call	word ptr cs:data_39e
		mov	word ptr ds:data_88e,2A20h
		mov	byte ptr ds:data_86e,4
		mov	byte ptr ds:data_87e,4
		mov	byte ptr ds:data_89e,0
		mov	cx,4
		mov	si,data_64e
		call	word ptr cs:data_55e
		mov	byte ptr ds:data_75e,0
		mov	word ptr ds:data_76e,0
		mov	dl,byte ptr ds:[85h]
		mov	ax,word ptr ds:[86h]
		mov	ds:data_77e,dl
		mov	ds:data_78e,ax
loc_14:
		mov	dl,ds:data_75e
		mov	ax,ds:data_76e
		push	dx
		push	ax
		call	word ptr cs:data_53e
		call	word ptr cs:data_49e
		mov	bx,312Eh
		call	word ptr cs:data_48e
		pop	ax
		pop	dx
		call	word ptr cs:data_49e
		mov	bx,3148h
		call	word ptr cs:data_48e
		int	61h			; ??INT Non-standard interrupt
		call	goblin_func_3
		test	ah,1
		jnz	loc_18			; Jump if not zero
		mov	word ptr ds:data_82e,0AA48h
		test	ah,2
		jz	loc_15			; Jump if zero
		retn
loc_15:
		or	al,al			; Zero ?
		jnz	loc_16			; Jump if not zero
		mov	byte ptr ds:data_79e,23h	; '#'
		jmp	short loc_14
loc_16:
		mov	byte ptr ds:[0FF1Ah],0
loc_17:
		int	61h			; ??INT Non-standard interrupt
		or	al,al			; Zero ?
		jz	loc_14			; Jump if zero
		mov	al,ds:data_79e
		cmp	byte ptr ds:[0FF1Ah],al
		jb	loc_17			; Jump if below
		sub	byte ptr ds:data_79e,1
		jnc	loc_14			; Jump if carry=0
		mov	byte ptr ds:data_79e,1
		jmp	short loc_14
loc_18:
		mov	word ptr ds:data_82e,0AA48h
		mov	ax,ds:data_76e
		mov	dl,ds:data_75e
		mov	cl,dl
		or	cl,al
		or	cl,ah
		jnz	loc_19			; Jump if not zero
		retn
loc_19:
		or	dl,dl			; Zero ?
		jnz	loc_20			; Jump if not zero
		cmp	ax,3E8h
		jb	loc_21			; Jump if below
loc_20:
		mov	byte ptr ds:data_68e,0FFh
		mov	word ptr ds:data_67e,0A7C3h
loc_21:
		add	word ptr ds:[89h],ax
		adc	byte ptr ds:[88h],dl
		mov	dl,ds:data_75e
		mov	ax,ds:data_76e
		call	word ptr cs:data_53e
		mov	byte ptr ds:[85h],dl
		mov	word ptr ds:[86h],ax
		call	word ptr cs:data_44e
		mov	byte ptr ds:data_70e,0FFh
		test	byte ptr ds:data_68e,0FFh
		jnz	loc_24			; Jump if not zero
		mov	word ptr ds:data_82e,0ABF7h
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		or	dl,ah
		or	dl,al
		jnz	loc_22			; Jump if not zero
		retn
loc_22:
		mov	word ptr ds:data_82e,0AC35h
		test	al,byte ptr ds:[88h]
		jnz	loc_23			; Jump if not zero
		cmp	word ptr ds:[89h],1
		jne	loc_23			; Jump if not equal
		retn
loc_23:
		mov	word ptr ds:data_82e,0AAF4h
		call	word ptr cs:data_50e
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		mov	di,0AD30h
		call	word ptr cs:data_51e
		mov	si,ds:data_82e
		push	si
		mov	word ptr ds:data_82e,0AD30h
		call	word ptr cs:data_50e
		pop	si
		mov	ds:data_82e,si
		retn
loc_24:
		mov	word ptr ds:data_82e,0AB10h
		retn
			                        ;* No entry point to code
		call	goblin_func_2
		mov	byte ptr ds:data_68e,0
		mov	si,data_59e
		call	goblin_process_loop_2
		mov	word ptr ds:data_82e,0AB32h
		mov	ax,word ptr ds:[89h]
		mov	dl,byte ptr ds:[88h]
		or	dl,al
		or	dl,ah
		jnz	loc_25			; Jump if not zero
		retn
loc_25:
		mov	word ptr ds:data_82e,0AB80h
		call	word ptr cs:data_50e
		mov	bx,2C1Dh
		mov	cx,1237h
		mov	al,0FFh
		call	word ptr cs:data_39e
		mov	word ptr ds:data_88e,2A20h
		mov	byte ptr ds:data_86e,4
		mov	byte ptr ds:data_87e,4
		mov	byte ptr ds:data_89e,0
		mov	cx,4
		mov	si,data_65e
		call	word ptr cs:data_55e
		mov	byte ptr ds:data_75e,0
		mov	word ptr ds:data_76e,0
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		mov	ds:data_77e,dl
		mov	ds:data_78e,ax
loc_26:
		mov	dl,ds:data_75e
		mov	ax,ds:data_76e
		push	dx
		push	ax
		mov	cl,byte ptr ds:[88h]
		mov	bx,word ptr ds:[89h]
		sub	bx,ax
		sbb	cl,dl
		xchg	bx,ax
		xchg	dl,cl
		call	word ptr cs:data_49e
		mov	bx,312Eh
		call	word ptr cs:data_48e
		pop	ax
		pop	dx
		call	word ptr cs:data_49e
		mov	bx,3148h
		call	word ptr cs:data_48e
		int	61h			; ??INT Non-standard interrupt
		call	goblin_func_3
		test	ah,1
		jnz	loc_30			; Jump if not zero
		mov	word ptr ds:data_82e,0AA48h
		test	ah,2
		jz	loc_27			; Jump if zero
		retn
loc_27:
		or	al,al			; Zero ?
		jnz	loc_28			; Jump if not zero
		mov	byte ptr ds:data_79e,23h	; '#'
		jmp	short loc_26
loc_28:
		mov	byte ptr ds:[0FF1Ah],0
loc_29:
		int	61h			; ??INT Non-standard interrupt
		or	al,al			; Zero ?
		jz	loc_26			; Jump if zero
		mov	al,ds:data_79e
		cmp	byte ptr ds:[0FF1Ah],al
		jb	loc_29			; Jump if below
		sub	byte ptr ds:data_79e,1
		jnc	loc_26			; Jump if carry=0
		mov	byte ptr ds:data_79e,1
		jmp	short loc_26
loc_30:
		mov	word ptr ds:data_82e,0AA48h
		mov	ax,ds:data_76e
		mov	dl,ds:data_75e
		mov	cl,dl
		or	cl,al
		or	cl,ah
		jnz	loc_31			; Jump if not zero
		retn
loc_31:
		mov	byte ptr ds:data_70e,0FFh
		mov	word ptr ds:data_82e,0ABC1h
		mov	dl,ds:data_75e
		mov	ax,ds:data_76e
		or	dl,dl			; Zero ?
		jnz	loc_32			; Jump if not zero
		cmp	ax,1
		je	loc_33			; Jump if equal
loc_32:
		mov	word ptr ds:data_82e,0ABA4h
		call	word ptr cs:data_50e
		mov	dl,ds:data_75e
		mov	ax,ds:data_76e
		mov	di,0AD30h
		call	word ptr cs:data_51e
		mov	si,ds:data_82e
		push	si
		mov	word ptr ds:data_82e,0AD30h
		call	word ptr cs:data_50e
		pop	si
		mov	ds:data_82e,si
loc_33:
		call	word ptr cs:data_50e
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		sub	ax,ds:data_76e
		sbb	dl,ds:data_75e
		mov	byte ptr ds:[88h],dl
		mov	word ptr ds:[89h],ax
		mov	word ptr ds:data_82e,0ABDEh
		or	dl,ah
		or	dl,al
		jz	loc_35			; Jump if zero
		mov	word ptr ds:data_82e,0AC35h
		test	al,byte ptr ds:[88h]
		jnz	loc_34			; Jump if not zero
		cmp	word ptr ds:[89h],1
		jne	loc_34			; Jump if not equal
		retn
loc_34:
		mov	word ptr ds:data_82e,0AAF4h
		call	word ptr cs:data_50e
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		mov	di,0AD30h
		call	word ptr cs:data_51e
		mov	si,ds:data_82e
		push	si
		mov	word ptr ds:data_82e,0AD30h
		call	word ptr cs:data_50e
		pop	si
		mov	ds:data_82e,si
loc_35:
		mov	dl,ds:data_75e
		mov	ax,ds:data_76e
		call	word ptr cs:data_54e
		jmp	word ptr cs:data_44e
			                        ;* No entry point to code
		call	goblin_func_2
		mov	word ptr ds:data_82e,0ABF7h
		mov	al,byte ptr ds:[88h]
		xor	ah,ah			; Zero register
		or	ax,word ptr ds:[89h]
		jnz	loc_36			; Jump if not zero
		retn
loc_36:
		mov	byte ptr ds:data_70e,0FFh
		mov	word ptr ds:data_82e,0AC35h
		test	al,byte ptr ds:[88h]
		jnz	loc_37			; Jump if not zero
		cmp	word ptr ds:[89h],1
		jne	loc_37			; Jump if not equal
		retn
loc_37:
		mov	word ptr ds:data_82e,0AC10h
		call	word ptr cs:data_50e
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		mov	di,0AD30h
		call	word ptr cs:data_51e
		mov	si,ds:data_82e
		push	si
		mov	word ptr ds:data_82e,0AD30h
		call	word ptr cs:data_50e
		pop	si
		mov	ds:data_82e,si
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_68e,0
		mov	si,data_58e
		call	goblin_func_7
		mov	byte ptr ds:data_68e,0FFh
		mov	word ptr ds:data_67e,0A773h
		mov	byte ptr ds:[0FF1Ah],0
loc_38:
		call	goblin_multiply
		cmp	byte ptr ds:[0FF1Ah],64h	; 'd'
		jb	loc_38			; Jump if below
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_71e,0FFh
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

goblin_func_2		proc	near
		mov	bx,2717h
		mov	cx,1C41h
		xor	al,al			; Zero register
		jmp	word ptr cs:data_39e
goblin_func_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

goblin_func_3		proc	near
		mov	dl,ds:data_75e
		mov	bx,ds:data_76e
		test	al,8
		jz	loc_39			; Jump if zero
		sub	bx,0Ah
		sbb	dl,0
		jnc	loc_42			; Jump if carry=0
		xor	bx,bx			; Zero register
		xor	dl,dl			; Zero register
		jmp	short loc_42
loc_39:
		test	al,4
		jz	loc_40			; Jump if zero
		add	bx,0Ah
		adc	dl,0
		mov	cx,bx
		sub	cx,ds:data_78e
		mov	cl,dl
		sbb	cl,ds:data_77e
		jc	loc_42			; Jump if carry Set
		mov	dl,ds:data_77e
		mov	bx,ds:data_78e
		jmp	short loc_42
loc_40:
		test	al,2
		jz	loc_41			; Jump if zero
		sub	bx,1
		sbb	dl,0
		jnc	loc_42			; Jump if carry=0
		xor	bx,bx			; Zero register
		xor	dl,dl			; Zero register
		jmp	short loc_42
loc_41:
		test	al,1
		jz	loc_42			; Jump if zero
		add	bx,1
		adc	dl,0
		mov	cx,bx
		sub	cx,ds:data_78e
		mov	cl,dl
		sbb	cl,ds:data_77e
		jc	loc_42			; Jump if carry Set
		mov	dl,ds:data_77e
		mov	bx,ds:data_78e
loc_42:
		mov	ds:data_75e,dl
		mov	ds:data_76e,bx
		retn
goblin_func_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

goblin_process_loop		proc	near
		mov	si,data_57e
		mov	bx,717h
		mov	cx,8

locloop_43:
		push	cx
		mov	cx,0Ch

locloop_44:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_47e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_44		; Loop if cx > 0

		sub	bh,0Ch
		add	bl,8
		pop	cx
		loop	locloop_43		; Loop if cx > 0

		retn
goblin_process_loop		endp

		db	'lmnopqrstuvwxy'
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 7Ah, 7Bh, 7Ch, 7Dh
		db	 08h, 09h, 0Ah, 0Bh, 0Ch, 0Dh
		db	 0Eh, 0Fh, 7Eh, 7Fh, 80h, 81h
		db	 10h, 11h, 12h, 13h, 14h, 15h
		db	 16h, 17h, 82h, 83h, 84h, 85h
		db	 18h, 19h, 1Ah, 1Bh, 1Ch, 1Dh
		db	 1Eh, 1Fh, 86h, 87h, 88h, 89h
		db	' !"#$'
		db	'%&', 27h
		db	 8Ah, 8Bh, 8Ch, 8Dh, 8Eh, 8Fh
		db	 90h, 91h, 92h, 93h, 94h, 95h
		db	 96h, 97h, 98h, 99h, 9Ah, 9Bh
		db	 9Ch, 9Dh, 9Eh, 9Fh,0A0h,0A1h
		db	0A2h,0A3h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

goblin_multiply		proc	near
		test	byte ptr ds:data_68e,0FFh
		jnz	loc_45			; Jump if not zero
		retn
loc_45:
		cmp	word ptr ds:data_85e,1Eh
		jae	loc_46			; Jump if above or =
		retn
loc_46:
		mov	word ptr ds:data_85e,0
		inc	byte ptr ds:data_69e
		mov	al,ds:data_69e
		and	al,1
		mov	cl,28h			; '('
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,ds:data_67e
goblin_multiply		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

goblin_process_loop_2		proc	near
		mov	bx,91Fh
		mov	cx,5

locloop_47:
		push	cx
		mov	cx,8

locloop_48:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_47e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_48		; Loop if cx > 0

		sub	bh,8
		add	bl,8
		pop	cx
		loop	locloop_47		; Loop if cx > 0

		retn
goblin_process_loop_2		endp

		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h
		db	 12h, 13h, 14h, 15h, 16h, 17h
		db	 18h, 19h, 1Ah, 1Bh, 1Ch, 1Dh
		db	 1Eh, 1Fh
		db	' !"#$'
		db	'%&', 27h
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 0Eh, 0Fh, 28h, 29h
		db	 12h, 13h, 14h, 15h, 16h, 17h
		db	 2Ah, 2Bh, 2Ch, 1Bh, 1Ch, 1Dh
		db	 1Eh, 1Fh
		db	' -.#$'
		db	'%&', 27h
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 41h, 42h
		db	 43h, 44h, 45h, 0Fh, 10h, 11h
		db	 46h, 4Dh, 4Eh, 49h, 4Ah, 39h
		db	 18h, 19h, 1Ah
		db	'OPQL= !"RS>?@'
		db	 00h, 01h, 54h, 55h, 56h, 05h
		db	 06h, 07h, 08h, 09h, 57h, 58h
		db	 59h, 5Ah, 5Bh, 0Fh, 10h, 5Ch
		db	 5Dh, 5Eh, 5Fh, 60h, 61h, 17h
		db	 18h, 19h
		db	'bcdefg !"hi>jk'

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

goblin_func_7		proc	near
		mov	byte ptr ds:[0FF1Ah],0
		lodsw				; String [si] to ax
		cmp	ax,0FFFFh
		jne	loc_49			; Jump if not equal
		retn
loc_49:
		push	si
		mov	si,ax
		call	goblin_process_loop_2
		cmp	byte ptr ds:[0FF1Ah],28h	; '('
		jb	$-5			; Jump if below
		pop	si
		jmp	short $-1Ah
goblin_func_7		endp

			                        ;* No entry point to code
		inc	bx
		test	al,6Bh			; 'k'
		test	al,93h
		test	al,0BBh
		test	al,0FFh
		db	0FFh,0BBh,0A8h, 93h,0A8h, 6Bh
		db	0A8h, 43h,0A8h,0FFh,0FFh, 00h
		db	 01h, 02h, 03h, 04h, 05h, 06h
		db	 07h, 08h, 09h, 0Ah, 0Bh, 0Ch
		db	 0Dh, 0Eh, 0Fh, 10h, 11h, 12h
		db	 13h, 14h, 15h, 16h, 17h, 18h
		db	 19h, 1Ah, 2Fh, 30h, 1Dh, 1Eh
		db	 1Fh
		db	' !"#$'
		db	'%&', 27h
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h
		db	 12h, 13h, 14h, 15h, 16h, 17h
		db	 18h, 19h, 1Ah, 2Fh, 30h, 1Dh
		db	 1Eh, 1Fh
		db	' !"#123', 27h
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 34h, 35h, 0Eh, 0Fh, 10h, 11h
		db	 12h, 13h, 36h, 37h, 38h, 39h
		db	 18h, 19h, 1Ah
		db	'/:;<= !"#$'
		db	'>?@'
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 41h, 42h
		db	 43h, 44h, 45h, 0Fh, 10h, 11h
		db	 46h, 47h, 48h, 49h, 4Ah, 39h
		db	 18h, 19h, 1Ah
		db	'/0KL= !"#$'
		db	'>?@'
		db	 01h, 16h
		db	'BANK.GRP'
		db	 00h, 18h,0AFh, 02h
		db	8, 'The Bank'
		db	1, 6, 1, 6, 1, 8
		db	1, 4, 1, 2, 1, 4
		db	4, 2, 1, 6, 1
		db	8
		db	'Go outside', 0
		db	'Exchange almas', 0
		db	'Deposit money', 0
		db	'Withdraw money', 0
		db	'Check balance', 0
		db	'GOLD CARRIED'
		db	0, 0, 0
		db	' DEPOSIT AMT'
		db	0
		db	'GOLD IN BANK'
		db	0, 0, 0
		db	'WITHDRAW AMT'
		db	 00h, 0Ch,0FFh, 2Eh,0FFh
		db	'Oh, excuse me. '
		db	0FFh, 00h
		db	'Can I help you?/'
		db	0FFh, 01h,0FFh,0FFh, 0Ch
		db	'Sir, you aren\t carryi'
		db	'ng any almas. '
		db	0FFh, 01h
		db	0Ch, 'Our exchange rate is '
		db	0FFh, 00h
		db	'&almas to '
		db	0FFh, 00h
		db	'&golds./Will that be all right?'
		db	0FFh, 0Ch
		db	'I\m sorry, you do'
		db	' not have enough almas.'
		db	0FFh, 01h
		db	0Ch, 'I don\'
		db	't'
		db	' und'
		db	'erstand'
		db	'. Please state'
		db	' your business clearly.'
		db	0FFh, 01h
		db	0Ch, 'Will there be anything else'
		db	'?'
		db	0FFh, 01h
		db	0Ch, 'You'
		db	' aren\t c'
		db	'arrying any gold, are you?'
		db	0FFh, 01h
		db	0Ch, 'How much gold w'
		db	'ould you like to deposit?'
		db	0FFh
		db	0Dh, 'Your balance is '
		db	0FFh, 00h, 26h, 67h, 6Fh, 6Ch
		db	 64h, 73h, 2Eh,0FFh, 01h
		db	0Ch, 'Thank you. Please come agai'
		db	'n.'
		db	0FFh, 03h,0FFh, 01h
		db	0Ch, 'I\m afrai'
		db	'd we have a p'
		db	'roblem here. You '
		db	'don\'
		db	't have any gold in your account.'
		db	0FFh, 01h
		db	0Ch, 'How mu'
		db	'ch do you wish to withdraw?/'
		db	0FFh
		db	'Here you are, sir. '
		db	0FFh, 00h, 26h, 67h, 6Fh, 6Ch
		db	 64h, 73h, 2Eh,0FFh
		db	'Here you are, sir. One gold.'
		db	0FFh
		db	0Dh, 'Your account is empty.'
		db	0FFh, 01h
		db	0Ch, 'Your account is empty.'
		db	0FFh, 01h
		db	0Ch, 'You have '
		db	0FFh, 00h
		db	'&golds in your account.'
		db	0FFh, 01h
		db	0Ch, 'You '
		db	'have one gold in your account.'
		db	0FFh, 01h
		db	0Ch, 'Unless'
		db	' you h'
		db	'ave bus'
		db	'ine'
		db	'ss, don\t com'
		db	'e in here. I\m a busy man.'
		db	0FFh, 02h, 11h,0FFh,0FFh, 0Ch
		db	'N'
		db	'ext '
		db	'time please depos'
		db	'it a large sum in savings. '
		db	0FFh, 02h, 11h,0FFh,0FFh, 0Ch
		db	'Th'
		db	'ank you. Come again t'
		db	'o make a deposit'
		db	' for a large sum in savings. '
		db	0FFh, 02h, 11h,0FFh,0FFh, 00h
		db	8 dup (0)
		db	 30h,0FFh
		db	15 dup (0)

seg_a		ends



		end	start
