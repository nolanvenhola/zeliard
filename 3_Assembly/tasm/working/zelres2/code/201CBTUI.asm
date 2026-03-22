
PAGE  59,132

;==========================================================================
;
;  COMBAT_UI - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_33e	equ	2000h			;*
data_34e	equ	2018h			;*
data_35e	equ	201Ah			;*
data_36e	equ	201Ch			;*
data_37e	equ	201Eh			;*
data_38e	equ	2020h			;*
data_39e	equ	2022h			;*
data_40e	equ	2026h			;*
data_41e	equ	2028h			;*
data_42e	equ	202Eh			;*
data_43e	equ	2030h			;*
data_44e	equ	2032h			;*
data_45e	equ	2034h			;*
data_46e	equ	2036h			;*
data_47e	equ	2038h			;*
data_48e	equ	203Ah			;*
data_49e	equ	203Ch			;*
data_50e	equ	2040h			;*
data_51e	equ	0A00Bh			;*
data_52e	equ	0A0C4h			;*
data_53e	equ	0A2B9h			;*
data_54e	equ	0A452h			;*
data_55e	equ	0A520h			;*
data_56e	equ	0A9FCh			;*
data_57e	equ	0AAB8h			;*
data_58e	equ	0AAF3h			;*
data_59e	equ	0AB62h			;*
data_60e	equ	0AC32h			;*
data_61e	equ	0ACD9h			;*
data_62e	equ	0AD67h			;*
data_63e	equ	0ADE8h			;*
data_64e	equ	0ADF8h			;*
data_65e	equ	0ADF9h			;*
data_66e	equ	0ADFAh			;*
data_67e	equ	0ADFBh			;*
data_68e	equ	0ADFCh			;*
data_69e	equ	0ADFDh			;*
data_70e	equ	0ADFEh			;*
data_71e	equ	0ADFFh			;*
data_72e	equ	0AE00h			;*
data_73e	equ	0AE01h			;*
data_74e	equ	0AE02h			;*
data_75e	equ	0AE03h			;*
data_76e	equ	0AE0Ah			;*
data_77e	equ	0AE10h			;*
data_78e	equ	0C00Ah			;*
data_79e	equ	0FF18h			;*
data_80e	equ	0FF1Ah			;*
data_81e	equ	0FF4Bh			;*
data_82e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_01		proc	far

start:
		sbb	ax,0Eh
		add	[si],al
		mov	al,ds:data_51e
		mov	byte ptr ds:data_64e,0
		jmp	short loc_1
		db	0C6h, 06h,0F8h,0ADh,0FFh
loc_1:
		mov	byte ptr ds:data_74e,0
		mov	si,data_63e
		mov	cx,4

locloop_2:
		push	cx
		lodsw				; String [si] to ax
		mov	bx,ax
		lodsw				; String [si] to ax
		mov	cx,ax
		push	si
		mov	al,0FFh
		call	word ptr cs:data_33e
		pop	si
		pop	cx
		loop	locloop_2		; Loop if cx > 0

		call	combat_func_20
		push	cs
		pop	es
		mov	si,0BBh
		mov	di,data_75e
		xor	cl,cl			; Zero register
		mov	ch,1
loc_3:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_4			; Jump if zero
		mov	al,ch
		stosb				; Store al to es:[di]
		inc	cl
loc_4:
		inc	ch
		cmp	ch,8
		jne	loc_3			; Jump if not equal
		mov	ds:data_66e,cl
		mov	si,0A1h
		mov	di,data_76e
		xor	al,al			; Zero register
		stosb				; Store al to es:[di]
		xor	cl,cl			; Zero register
		mov	ch,5
loc_5:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_6			; Jump if zero
		stosb				; Store al to es:[di]
		inc	cl
loc_6:
		dec	ch
		jnz	loc_5			; Jump if not zero
		or	cl,cl			; Zero ?
		jz	loc_7			; Jump if zero
		inc	cl
loc_7:
		mov	ds:data_68e,cl
		call	combat_func_11
		call	combat_func_17
		call	combat_process_loop_2
		call	combat_process_loop
		call	combat_func_14
		call	combat_func_22
		sbb	al,al
		mov	ds:data_73e,al
		xor	cl,cl			; Zero register
		test	byte ptr ds:data_66e,0FFh
		jnz	loc_9			; Jump if not zero
		inc	cl
		test	byte ptr ds:data_68e,0FFh
		jnz	loc_9			; Jump if not zero
		test	byte ptr ds:data_64e,0FFh
		jnz	loc_8			; Jump if not zero
		inc	cl
		test	byte ptr ds:data_70e,0FFh
		jnz	loc_9			; Jump if not zero
loc_8:
		call	combat_func_22
		jnc	loc_8			; Jump if carry=0
		retn
loc_9:
		mov	ds:data_65e,cl
loc_10:
		mov	bl,ds:data_65e
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_52e[bx]	;*
			                        ;* No entry point to code
		retf	0BBA0h
			                        ;* No entry point to code
		mov	ax,ds:data_53e
		call	combat_func_20
		mov	al,2
		call	combat_func_2
loc_11:
		int	61h			; ??INT Non-standard interrupt
		and	al,3
		jnz	loc_11			; Jump if not zero
loc_12:
		call	combat_func_22
		jnc	loc_13			; Jump if carry=0
		retn
loc_13:
		int	61h			; ??INT Non-standard interrupt
		and	al,0Eh
		jz	loc_12			; Jump if zero
		and	al,0Ch
		jnz	loc_14			; Jump if not zero
		jmp	loc_17
loc_14:
		test	al,4
		jnz	loc_15			; Jump if not zero
		mov	al,ds:data_67e
		inc	al
		mov	ah,ds:data_66e
		dec	ah
		cmp	ah,al
		jb	loc_12			; Jump if below
		xor	al,al			; Zero register
		call	combat_func_2
		inc	byte ptr ds:data_67e
		mov	al,2
		call	combat_func_2
		mov	byte ptr ds:data_82e,0Ch
		call	combat_func_1
		jmp	short loc_12
loc_15:
		test	byte ptr ds:data_67e,0FFh
		jz	loc_12			; Jump if zero
		xor	al,al			; Zero register
		call	combat_func_2
		dec	byte ptr ds:data_67e
		mov	al,2
		call	combat_func_2
		mov	byte ptr ds:data_82e,0Ch
		call	combat_func_1
		jmp	short loc_12

zr2_01		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_1		proc	near
		mov	bx,data_75e
		mov	al,ds:data_67e
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[9Dh],al
		mov	bx,2711h
		mov	cx,1009h
		xor	al,al			; Zero register
		call	word ptr cs:data_33e
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_57e[bx]
		mov	bx,9Eh
		mov	cl,12h
		mov	ah,1
;*		call	combat_func_21			;*
		db	0E8h,0C7h, 08h		;  Fixup - byte match
		mov	al,byte ptr ds:[9Dh]
		mov	bx,37A4h
		call	word ptr cs:data_37e
		call	word ptr cs:data_34e
loc_16:
		int	61h			; ??INT Non-standard interrupt
		and	al,0Ch
		jnz	loc_16			; Jump if not zero
		retn
combat_func_1		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_2		proc	near
		mov	bh,ds:data_67e
		xor	bl,bl			; Zero register
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,0E1Ah
		jmp	word ptr cs:data_42e
combat_func_2		endp

loc_17:
		mov	cl,1
		test	byte ptr ds:data_68e,0FFh
		jnz	loc_18			; Jump if not zero
		test	byte ptr ds:data_64e,0FFh
		mov	cl,2
		test	byte ptr ds:data_70e,0FFh
		jnz	loc_18			; Jump if not zero
		jmp	loc_12
loc_18:
		mov	byte ptr ds:data_82e,0Dh
		mov	ds:data_65e,cl
		mov	al,5
		call	combat_func_2
		jmp	loc_10
			                        ;* No entry point to code
		call	combat_func_20
		mov	al,2
		call	combat_func_4
loc_19:
		int	61h			; ??INT Non-standard interrupt
		and	al,3
		jnz	loc_19			; Jump if not zero
loc_20:
		call	combat_func_22
		jnc	loc_21			; Jump if carry=0
		retn
loc_21:
		int	61h			; ??INT Non-standard interrupt
		and	al,0Fh
		jz	loc_20			; Jump if zero
		mov	ah,al
		and	al,0Ch
		jnz	loc_22			; Jump if not zero
		jmp	loc_25
loc_22:
		test	al,4
		jnz	loc_23			; Jump if not zero
		mov	al,ds:data_69e
		inc	al
		mov	ah,ds:data_68e
		dec	ah
		cmp	ah,al
		jb	loc_20			; Jump if below
		xor	al,al			; Zero register
		call	combat_func_4
		inc	byte ptr ds:data_69e
		mov	al,2
		call	combat_func_4
		mov	byte ptr ds:data_82e,0Ch
		call	combat_func_3
		jmp	short loc_20
loc_23:
		test	byte ptr ds:data_69e,0FFh
		jz	loc_20			; Jump if zero
		xor	al,al			; Zero register
		call	combat_func_4
		dec	byte ptr ds:data_69e
		mov	al,2
		call	combat_func_4
		mov	byte ptr ds:data_82e,0Ch
		call	combat_func_3
		jmp	short loc_20

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_3		proc	near
		mov	bx,data_76e
		mov	al,ds:data_69e
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[9Eh],al
		mov	bx,1742h
		mov	cx,1611h
		xor	al,al			; Zero register
		call	word ptr cs:data_33e
		mov	bl,byte ptr ds:[9Eh]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_58e[bx]
		mov	bx,5Ch
		mov	cl,43h			; 'C'
		mov	ah,1
;*		call	combat_func_21			;*
		db	0E8h,0D6h, 07h		;  Fixup - byte match
		mov	bx,5Ch
		mov	cl,4Bh			; 'K'
		mov	ah,1
;*		call	combat_func_21			;*
		db	0E8h,0CCh, 07h		;  Fixup - byte match
loc_24:
		int	61h			; ??INT Non-standard interrupt
		and	al,0Ch
		jnz	loc_24			; Jump if not zero
		retn
combat_func_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_4		proc	near
		mov	bh,ds:data_69e
		xor	bl,bl			; Zero register
		mov	cx,bx
		add	bx,bx
		add	bx,bx
		add	bx,cx
		add	bx,0E53h
		jmp	word ptr cs:data_42e
combat_func_4		endp

loc_25:
		test	ah,1
		jz	loc_27			; Jump if zero
		test	byte ptr ds:data_66e,0FFh
		jnz	loc_26			; Jump if not zero
		jmp	loc_20
loc_26:
		mov	byte ptr ds:data_65e,0
		jmp	short loc_30
loc_27:
		test	byte ptr ds:data_64e,0FFh
		jz	loc_28			; Jump if zero
		jmp	loc_20
loc_28:
		test	byte ptr ds:data_70e,0FFh
		jnz	loc_29			; Jump if not zero
		jmp	loc_20
loc_29:
		mov	byte ptr ds:data_65e,2
loc_30:
		mov	byte ptr ds:data_82e,0Dh
		mov	al,5
		call	combat_func_4
		jmp	loc_10
			                        ;* No entry point to code
		call	combat_func_20
		mov	al,2
		call	combat_func_6
loc_31:
		int	61h			; ??INT Non-standard interrupt
		and	al,3
		jnz	loc_31			; Jump if not zero
loc_32:
		call	combat_func_22
		jnc	loc_33			; Jump if carry=0
		retn
loc_33:
		cmp	word ptr ds:data_79e,286h
		jne	loc_34			; Jump if not equal
		jmp	loc_42
loc_34:
		int	61h			; ??INT Non-standard interrupt
		and	ah,1
		jz	loc_35			; Jump if zero
		jmp	loc_44
loc_35:
		and	al,0Dh
		jz	loc_32			; Jump if zero
		push	ax
		call	combat_func_10
		pop	ax
		and	al,0Ch
		jnz	loc_36			; Jump if not zero
		jmp	loc_40
loc_36:
		test	al,4
		jnz	loc_37			; Jump if not zero
		mov	al,ds:data_72e
		inc	al
		mov	ah,ds:data_70e
		dec	ah
		cmp	ah,al
		jb	loc_32			; Jump if below
		xor	al,al			; Zero register
		call	combat_func_6
		inc	byte ptr ds:data_72e
		mov	al,2
		call	combat_func_6
		mov	byte ptr ds:data_82e,0Ch
		call	combat_func_5
		jmp	short loc_32
loc_37:
		test	byte ptr ds:data_72e,0FFh
		jz	loc_32			; Jump if zero
		xor	al,al			; Zero register
		call	combat_func_6
		dec	byte ptr ds:data_72e
		mov	al,2
		call	combat_func_6
		mov	byte ptr ds:data_82e,0Ch
		call	combat_func_5
		jmp	short loc_32

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_5		proc	near
		mov	bx,data_77e
		mov	al,ds:data_72e
		xlat				; al=[al+[bx]] table
		mov	ds:data_71e,al
		mov	bx,1570h
		mov	cx,1811h
		xor	al,al			; Zero register
		call	word ptr cs:data_33e
		mov	bl,ds:data_71e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_60e[bx]
		mov	bx,54h
		mov	cl,70h			; 'p'
		mov	ah,1
;*		call	combat_func_21			;*
		db	0E8h,0C2h, 06h		;  Fixup - byte match
		mov	bx,54h
		mov	cl,78h			; 'x'
		mov	ah,1
;*		call	combat_func_21			;*
		db	0E8h,0B8h, 06h		;  Fixup - byte match
loc_38:
		int	61h			; ??INT Non-standard interrupt
		and	al,0Ch
		jnz	loc_38			; Jump if not zero
		retn
combat_func_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_6		proc	near
loc_39:
		mov	bh,ds:data_72e
		xor	bl,bl			; Zero register
		mov	cx,bx
		add	bx,bx
		add	bx,bx
		add	bx,cx
		add	bx,0E81h
		jmp	word ptr cs:data_42e
combat_func_6		endp

loc_40:
		mov	cl,1
		test	byte ptr ds:data_68e,0FFh
		jnz	loc_41			; Jump if not zero
		xor	cl,cl			; Zero register
		test	byte ptr ds:data_66e,0FFh
		jnz	loc_41			; Jump if not zero
		jmp	loc_32
loc_41:
		mov	ds:data_65e,cl
		mov	byte ptr ds:data_82e,0Dh
		mov	al,5
		call	combat_func_6
		jmp	loc_10
loc_42:
		test	byte ptr ds:data_74e,0FFh
		jz	loc_43			; Jump if zero
		jmp	loc_32
loc_43:
		call	combat_func_9
		mov	bx,1B43h
		mov	cx,1A24h
		mov	al,0FFh
		call	word ptr cs:data_33e
		mov	si,0AAA2h
		mov	bx,80h
		mov	cl,4Ch			; 'L'
		mov	ah,1
;*		call	combat_func_21			;*
		db	0E8h, 4Dh, 06h		;  Fixup - byte match
		mov	al,byte ptr ds:[8Dh]
		xor	ah,ah			; Zero register
		inc	ax
		mov	cx,2
		mov	bl,6
		mov	dx,2C4Ch
		call	combat_func_19
		mov	si,0AAA8h
		mov	bx,80h
		mov	cl,56h			; 'V'
		mov	ah,1
;*		call	combat_func_21			;*
		db	0E8h, 2Fh, 06h		;  Fixup - byte match
		mov	ax,word ptr ds:[8Eh]
		mov	cx,5
		mov	bl,6
		mov	dx,2856h
		call	combat_func_19
		jmp	loc_32
loc_44:
		test	byte ptr ds:data_71e,0FFh
		jnz	loc_45			; Jump if not zero
		jmp	loc_32
loc_45:
		call	combat_func_10
		mov	ax,0A2C7h
		push	ax
		mov	ax,0A5B4h
		push	ax
		mov	cl,ds:data_72e
		xor	ch,ch			; Zero register
		mov	bx,0A6h
loc_46:
		test	byte ptr [bx],0FFh
		jz	loc_47			; Jump if zero
		inc	ch
loc_47:
		inc	bx
		cmp	ch,cl
		jne	loc_46			; Jump if not equal
		mov	byte ptr [bx-1],0
		call	combat_func_11
		mov	al,ds:data_71e
		mov	ds:data_81e,al
		mov	bl,ds:data_71e
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_54e[bx]	;*
		db	 62h,0A4h, 83h,0A4h, 96h,0A4h
		db	0BEh,0A4h, 2Ch,0A5h,0EAh,0A4h
		db	0DBh,0A4h, 8Bh,0A5h,0C6h, 06h
		db	 75h,0FFh, 0Eh, 83h, 06h, 90h
		db	 00h, 50h,0A1h, 90h, 00h, 2Bh
		db	 06h,0B2h, 00h, 72h, 06h,0A1h
		db	0B2h, 00h,0A3h, 90h, 00h, 2Eh
		db	0FFh, 16h, 08h, 20h,0E9h, 57h
		db	 01h,0C6h, 06h, 75h,0FFh, 0Eh
		db	0A1h,0B2h, 00h,0A3h, 90h, 00h
		db	 2Eh,0FFh, 16h, 08h, 20h,0E9h
		db	 44h, 01h,0C6h, 06h, 75h,0FFh
		db	 0Eh,0F6h, 06h, 9Dh, 00h,0FFh
		db	 75h, 01h,0C3h
loc_48:
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,byte ptr ds:[0B4h][bx]
		mov	byte ptr ds:[0ABh][bx],al
		call	word ptr cs:data_34e
		call	combat_func_18
		jmp	loc_53
			                        ;* No entry point to code
		mov	byte ptr ds:data_82e,0Eh
		push	cs
		pop	es
		mov	si,0B4h
		mov	di,0ABh
		mov	cx,7
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		call	word ptr cs:data_34e
		call	combat_func_18
		jmp	loc_53
			                        ;* No entry point to code
		mov	byte ptr ds:data_82e,0Eh
		inc	byte ptr ds:[0E4h]
		call	combat_func_16
		jmp	loc_53
			                        ;* No entry point to code
		mov	byte ptr ds:data_82e,0Eh
		test	byte ptr ds:[93h],0FFh
		jnz	loc_49			; Jump if not zero
		retn
loc_49:
		mov	bl,byte ptr ds:[93h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,ds:data_55e[bx]
		add	word ptr ds:[94h],ax
		mov	ax,word ptr ds:[94h]
		sub	ax,word ptr ds:[96h]
		jc	loc_50			; Jump if carry Set
		mov	ax,word ptr ds:[96h]
		mov	word ptr ds:[94h],ax
loc_50:
		call	word ptr cs:data_35e
		jmp	loc_53
			                        ;* No entry point to code
		push	ax
;*		add	[bp+si+0],bl
		db	 00h, 5Ah, 00h		;  Fixup - byte match
		db	 64h, 00h, 6Eh, 00h, 73h, 00h
		db	 78h, 00h, 0Eh, 07h,0C6h, 06h
		db	 75h,0FFh, 0Eh,0C6h, 06h, 84h
		db	0A5h, 00h,0C6h, 06h, 85h,0A5h
		db	 01h,0BEh, 84h,0A5h,0BFh, 60h
		db	0EBh,0B9h, 07h, 00h,0F3h,0A4h
		db	0C6h, 06h, 84h,0A5h, 04h,0C6h
		db	 06h, 85h,0A5h,0FFh,0BEh, 84h
		db	0A5h,0BFh, 67h,0EBh,0B9h, 07h
		db	 00h,0F3h,0A4h,0C6h, 06h, 84h
		db	0A5h, 08h,0BEh, 84h,0A5h,0BFh
		db	 6Eh,0EBh,0B9h, 07h, 00h,0F3h
		db	0A4h,0C6h, 06h, 84h,0A5h, 0Ch
		db	0C6h, 06h, 85h,0A5h, 01h,0BEh
		db	 84h,0A5h,0BFh, 75h,0EBh,0B9h
		db	 07h, 00h,0F3h,0A4h,0EBh, 56h
		db	 00h, 00h, 50h, 00h, 00h, 00h
		db	 00h,0C6h, 06h, 75h,0FFh, 0Fh
		db	0E8h, 47h, 00h,0E8h, 1Eh, 00h
		db	 58h, 58h,0C6h, 06h, 24h,0FFh
		db	 08h,0C6h, 06h, 1Ah,0FFh, 00h
loc_51:
		cmp	byte ptr ds:data_80e,78h	; 'x'
		jb	loc_51			; Jump if below
		call	word ptr cs:data_50e
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_7		proc	near
		xor	al,al			; Zero register
		call	combat_func_6
		mov	bx,0E83h
		mov	cx,1E10h
		xor	al,al			; Zero register
		call	word ptr cs:data_33e
		test	byte ptr ds:data_70e,0FFh
		jnz	loc_52			; Jump if not zero
		mov	byte ptr ds:data_70e,1
loc_52:
		call	combat_process_loop
		mov	al,2
		jmp	loc_39
combat_func_7		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_8		proc	near
loc_53:
		call	combat_func_9
		mov	bx,0F43h
		mov	cx,3224h
		mov	al,0FFh
		call	word ptr cs:data_33e
		mov	si,0AAACh
		mov	bx,44h
		mov	cl,4Ch			; 'L'
		mov	ah,1
;*		call	combat_func_21			;*
		db	0E8h, 34h, 04h		;  Fixup - byte match
		mov	bl,ds:data_71e
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_59e[bx]
		mov	bx,48h
		mov	cl,56h			; 'V'
		mov	ah,1
;*		jmp	loc_76			;*
combat_func_8		endp

		db	0E9h, 1Ch, 04h		;  Fixup - byte match

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_9		proc	near
		test	byte ptr ds:data_74e,0FFh
		jz	loc_54			; Jump if zero
		retn
loc_54:
		mov	byte ptr ds:data_74e,0FFh
		mov	ax,643h
		xor	di,di			; Zero register
		mov	cx,1C24h
		jmp	word ptr cs:data_40e
combat_func_9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_10		proc	near
		test	byte ptr ds:data_74e,0FFh
		jnz	loc_55			; Jump if not zero
		retn
loc_55:
		mov	byte ptr ds:data_74e,0
		mov	ax,643h
		xor	di,di			; Zero register
		mov	cx,1C24h
		jmp	word ptr cs:data_41e
combat_func_10		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_func_11		proc	near
		push	cs
		pop	es
		mov	si,0A6h
		mov	di,data_77e
		xor	al,al			; Zero register
		stosb				; Store al to es:[di]
		xor	cl,cl			; Zero register
		mov	ch,5
loc_56:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_57			; Jump if zero
		stosb				; Store al to es:[di]
		inc	cl
loc_57:
		dec	ch
		jnz	loc_56			; Jump if not zero
		or	cl,cl			; Zero ?
		jz	loc_58			; Jump if zero
		inc	cl
loc_58:
		mov	ds:data_70e,cl
		retn
combat_func_11		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_process_loop		proc	near
		test	byte ptr ds:data_70e,0FFh
		jz	loc_61			; Jump if zero
		mov	cl,ds:data_70e
		xor	ch,ch			; Zero register
		mov	bx,0E83h
		mov	si,data_77e

locloop_59:
		push	cx
		lodsb				; String [si] to al
		push	si
		push	bx
		call	word ptr cs:data_46e
		pop	bx
		pop	si
		add	bx,500h
		pop	cx
		loop	locloop_59		; Loop if cx > 0

		mov	byte ptr ds:data_71e,0
		mov	byte ptr ds:data_72e,0
		test	byte ptr ds:data_64e,0FFh
		jz	loc_60			; Jump if zero
		retn
loc_60:
		mov	bx,0E81h
		mov	al,5
		call	word ptr cs:data_42e
		mov	bx,1570h
		mov	cx,1811h
		xor	al,al			; Zero register
		call	word ptr cs:data_33e
		mov	si,0AA9Ah
		mov	bx,54h
		mov	cl,71h			; 'q'
		mov	ah,1
;*		jmp	loc_76			;*
		db	0E9h, 67h, 03h		;  Fixup - byte match
loc_61:
		mov	bx,54h
		mov	cl,71h			; 'q'
		mov	si,0AA92h
		mov	ah,1
;*		jmp	loc_76			;*
combat_process_loop		endp

		db	0E9h, 5Ah, 03h		;  Fixup - byte match

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

combat_process_loop_2		proc	near
		test	byte ptr ds:data_68e,0FFh
		jz	loc_63			; Jump if zero
		mov	cl,ds:data_68e
		xor	ch,ch			; Zero register
		mov	bx,0E55h
		mov	si,data_76e

locloop_62:
		push	cx
		lodsb				; String [si] to al
		push	si
		push	bx
		call	word ptr cs:data_45e
		pop	bx
		pop	si
		add	bx,500h
		pop	cx
		loop	locloop_62		; Loop if cx > 0

		push	cs
		pop	es
		mov	di,data_76e
		mov	al,byte ptr ds:[9Eh]
		mov	cx,6
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		neg	cx
		add	cx,5
		mov	ds:data_69e,cl
		mov	ch,cl
		xor	cl,cl			; Zero register
		mov	bx,cx
		add	cx,cx
		add	cx,cx
		add	cx,bx
		add	cx,0E53h
		mov	bx,cx
		mov	al,5
		call	word ptr cs:data_42e
		mov	bl,byte ptr ds:[9Eh]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_58e[bx]
		mov	bx,5Ch
		mov	cl,43h			; 'C'
		mov	ah,1
;*		call	combat_func_21			;*
		db	0E8h,0F0h, 02h		;  Fixup - byte match
		mov	bx,5Ch
		mov	cl,4Bh			; 'K'
		mov	ah,1
;*		jmp	loc_76			;*
		db	0E9h,0E6h, 02h		;  Fixup - byte match
loc_63:
		mov	bx,5Ch
		mov	cl,43h			; 'C'
		mov	si,0AA92h
		mov	ah,1
;*		jmp	loc_76			;*
		db	0E9h,0D9h, 02h		;  Fixup - byte match

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

combat_func_14:
		test	byte ptr ds:[92h],0FFh
		jz	loc_64			; Jump if zero
		mov	bx,174Dh
		mov	al,byte ptr ds:[92h]
		call	word ptr cs:data_36e
		mov	bl,byte ptr ds:[92h]
		xor	bh,bh			; Zero register
		dec	bl
		add	bx,bx
		mov	si,ds:data_61e[bx]
		mov	bx,344Eh
		xor	cl,cl			; Zero register
		call	word ptr cs:data_47e
		mov	bx,3456h
		xor	cl,cl			; Zero register
		call	word ptr cs:data_47e
		call	combat_func_16
loc_64:
		test	byte ptr ds:[93h],0FFh
		jz	loc_65			; Jump if zero
		mov	bx,2E61h
		mov	al,byte ptr ds:[93h]
		call	word ptr cs:data_38e
		mov	bl,byte ptr ds:[93h]
		xor	bh,bh			; Zero register
		dec	bl
		add	bx,bx
		mov	si,ds:data_62e[bx]
		mov	bx,3461h
		xor	cl,cl			; Zero register
		call	word ptr cs:data_47e
		mov	bx,3469h
		xor	cl,cl			; Zero register
		call	word ptr cs:data_47e
		call	combat_func_15
loc_65:
		test	byte ptr ds:[98h],0FFh
		jz	loc_66			; Jump if zero
		mov	bx,2E75h
		xor	al,al			; Zero register
		call	word ptr cs:data_48e
		mov	bx,0C8h
		mov	cl,7Eh			; '~'
		mov	al,5Eh			; '^'
		mov	ah,1
		call	word ptr cs:data_39e
		mov	al,byte ptr ds:[98h]
		xor	ah,ah			; Zero register
		mov	cx,1
		mov	bl,1
		mov	dx,347Eh
		call	combat_func_19
loc_66:
		test	byte ptr ds:[99h],0FFh
		jz	loc_67			; Jump if zero
		mov	bx,3A75h
		mov	al,1
		call	word ptr cs:data_48e
		mov	bx,0F8h
		mov	cl,7Eh			; '~'
		mov	al,5Eh			; '^'
		mov	ah,1
		call	word ptr cs:data_39e
		mov	al,byte ptr ds:[99h]
		xor	ah,ah			; Zero register
		mov	cx,1
		mov	bl,1
		mov	dx,407Eh
		call	combat_func_19
loc_67:
		mov	si,9Ah
		mov	bx,3089h
		mov	cx,3

locloop_68:
		push	cx
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_69			; Jump if zero
		mov	al,cl
		neg	al
		add	al,3
		push	bx
		push	si
		call	word ptr cs:data_49e
		pop	si
		pop	bx
		add	bx,600h
loc_69:
		pop	cx
		loop	locloop_68		; Loop if cx > 0

		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

combat_func_15:
		mov	ax,word ptr ds:[96h]
		mov	dx,3469h
		mov	cx,3
		mov	bl,4
		call	combat_func_19
		mov	bx,0CAh
		mov	cl,69h			; 'i'
		mov	al,28h			; '('
		mov	ah,4
		call	word ptr cs:data_39e
		mov	bx,0E0h
		mov	cl,69h			; 'i'
		mov	al,29h			; ')'
		mov	ah,4
		jmp	word ptr cs:data_39e

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

combat_func_16:
		test	byte ptr ds:[0E4h],0FFh
		jnz	loc_70			; Jump if not zero
		retn
loc_70:
		mov	bx,3257h
		mov	cx,408h
		xor	al,al			; Zero register
		call	word ptr cs:data_33e
		mov	bx,0CAh
		mov	cl,57h			; 'W'
		mov	al,28h			; '('
		mov	ah,1
		call	word ptr cs:data_39e
		mov	al,byte ptr ds:[0E4h]
		xor	ah,ah			; Zero register
		mov	dx,3457h
		mov	bl,1
		mov	cx,1
		call	combat_func_19
		mov	bx,0D4h
		mov	cl,57h			; 'W'
		mov	al,29h			; ')'
		mov	ah,1
		jmp	word ptr cs:data_39e

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

combat_func_17:
		test	byte ptr ds:data_66e,0FFh
		jz	loc_72			; Jump if zero
		mov	cl,ds:data_66e
		xor	ch,ch			; Zero register
		mov	bx,0E1Ch
		mov	si,data_75e

locloop_71:
		push	cx
		lodsb				; String [si] to al
		push	si
		push	bx
		call	word ptr cs:data_37e
		pop	bx
		pop	si
		add	bx,800h
		pop	cx
		loop	locloop_71		; Loop if cx > 0

		call	combat_func_18
		push	cs
		pop	es
		mov	di,data_75e
		mov	al,byte ptr ds:[9Dh]
		mov	cx,7
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		neg	cx
		add	cx,6
		mov	ds:data_67e,cl
		mov	ch,cl
		xor	cl,cl			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,0E1Ah
		mov	bx,cx
		mov	al,5
		call	word ptr cs:data_42e
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_57e[bx]
		mov	bx,9Eh
		mov	cl,12h
		mov	ah,1
;*		jmp	loc_76			;*
		db	0E9h, 0Fh, 01h		;  Fixup - byte match
loc_72:
		mov	bx,9Eh
		mov	cl,12h
		mov	si,0AA92h
		mov	ah,1
;*		jmp	loc_76			;*
		db	0E9h, 02h, 01h		;  Fixup - byte match

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

combat_func_18:
		mov	dx,0E2Eh
		mov	si,data_75e
		mov	cl,ds:data_66e
		xor	ch,ch			; Zero register

locloop_73:
		push	cx
		lodsb				; String [si] to al
		push	si
		push	dx
		dec	al
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	al,byte ptr ds:[0ABh][bx]
		mov	ah,byte ptr ds:[0B4h][bx]
		push	ax
		push	dx
		push	ax
		push	dx
		mov	bx,dx
		mov	cx,508h
		xor	al,al			; Zero register
		call	word ptr cs:data_33e
		pop	dx
		pop	ax
		xor	ah,ah			; Zero register
		mov	bl,1
		mov	cx,3
		call	combat_func_19
		pop	dx
		add	dx,9
		push	dx
		sub	dx,200h
		mov	cl,dl
		mov	bl,dh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		inc	bx
		inc	bx
		mov	al,28h			; '('
		mov	ah,4
		call	word ptr cs:data_39e
		pop	dx
		pop	ax
		mov	al,ah
		push	dx
		xor	ah,ah			; Zero register
		mov	bl,4
		mov	cx,3
		call	combat_func_19
		pop	dx
		add	dx,400h
		mov	cl,dl
		mov	bl,dh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		dec	bx
		mov	al,29h			; ')'
		mov	ah,4
		call	word ptr cs:data_39e
		pop	dx
		add	dx,800h
		pop	si
		pop	cx
		loop	locloop_73		; Loop if cx > 0

		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

combat_func_19:
		push	bx
		push	dx
		push	cx
		xor	dl,dl			; Zero register
		mov	di,0AE16h
		call	word ptr cs:data_44e
		pop	cx
		mov	di,0AE16h
		mov	al,7
		sub	al,cl
		xor	ah,ah			; Zero register
		add	di,ax
		pop	ax
		pop	bx
		xor	bh,bh			; Zero register
		jmp	word ptr cs:data_43e

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

combat_func_20:
		mov	si,data_56e
		mov	cx,4

locloop_74:
		push	cx
		mov	dh,cl
		lodsw				; String [si] to ax
		mov	bx,ax
		lodsb				; String [si] to al
		mov	cl,al
		mov	dl,ds:data_65e
		neg	dh
		add	dh,4
		mov	ah,3
		cmp	dl,dh
		jne	loc_75			; Jump if not equal
		mov	ah,2
loc_75:
;*		call	combat_func_21			;*
		db	0E8h, 33h, 00h		;  Fixup - byte match
		pop	cx
		loop	locloop_74		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		xor	al,0
		adc	dl,[bp+di+45h]
		dec	sp
		inc	bp
		inc	bx
		push	sp
		sub	ax,414Dh
		inc	di
		dec	cx
		inc	bx
		cmp	al,[bx+si]
		xor	al,0
		inc	bx
		push	di
		inc	bp
		inc	cx
		push	dx
		cmp	al,[bx+si]
		xor	al,0
;*		jno	loc_79			;*Jump if not overflw
		db	 71h, 55h		;  Fixup - byte match
		push	bx
		inc	bp
		cmp	al,[bx+si]
		mov	ax,4300h
		dec	cx
		dec	si
		push	si
		inc	bp
		dec	si
		push	sp
		dec	di
		push	dx
		pop	cx
		add	ds:data_78e[si],ch
		jnz	loc_77			; Jump if not zero
		retn
loc_77:
		push	si
		cmp	ah,1
		je	loc_78			; Jump if equal
		push	bx
		push	cx
		push	ax
		inc	bx
		inc	cl
		mov	ah,5
		call	word ptr cs:data_39e
		pop	ax
		pop	cx
		pop	bx
loc_78:
		push	bx
		push	cx
		push	ax
		call	word ptr cs:data_39e
		pop	ax
		pop	cx
		pop	bx
		pop	si
		add	bx,8
;*		jmp	short loc_76		;*
		db	0EBh,0D3h		;  Fixup - byte match

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

combat_func_22:
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		test	byte ptr ds:data_73e,0FFh
		jz	loc_81			; Jump if zero
		call	combat_func_23
		cmc				; Complement carry
		jc	loc_80			; Jump if carry Set
		retn
loc_80:
		clc				; Clear carry flag
		mov	byte ptr ds:data_73e,0
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

combat_func_23:
loc_81:
		test	word ptr ds:data_79e,1
		stc				; Set carry flag
		jz	loc_82			; Jump if zero
		retn
loc_82:
		clc				; Clear carry flag
		retn
combat_process_loop_2		endp

		db	 4Eh, 4Fh, 54h, 48h, 49h, 4Eh
		db	 47h, 00h, 4Eh, 4Fh, 20h, 55h
		db	 53h, 45h, 00h, 00h, 4Ch, 45h
		db	 56h, 45h, 4Ch, 00h, 45h, 58h
		db	 50h, 00h
		db	'I have used'
		db	 00h,0C6h,0AAh,0CDh,0AAh,0D3h
		db	0AAh,0D9h,0AAh,0E0h,0AAh,0E7h
		db	0AAh,0ECh,0AAh
		db	'Espada', 0
		db	'Saeta', 0
		db	'Fuego', 0
		db	'Lanzar', 0
		db	'Rascar', 0
		db	'Agua', 0
		db	'Guerra', 0
		db	 9Ah,0AAh,0FFh,0AAh, 12h,0ABh
		db	 25h,0ABh, 39h,0ABh, 4Dh,0ABh
		db	'Feruza', 0
		db	'      shoes', 0
		db	'Pirika', 0
		db	'      shoes', 0
		db	'Silkarn', 0
		db	'      shoes', 0
		db	'Ruzeria', 0
		db	'      shoes', 0
		db	'Asbestos', 0
		db	'       cape', 0
		db	 72h,0ABh, 8Ah,0ABh,0A2h,0ABh
		db	0BAh,0ABh,0D2h,0ABh,0EAh,0ABh
		db	 02h,0ACh, 1Ah,0ACh
		db	'       a Ken\ko Potion.', 0
		db	'        a Juu-en Fruit.', 0
		db	'     a Elixir of Kashi.', 0
		db	'      a Chikara Powder.', 0
		db	'         a Magia Stone.', 0
		db	' a Holy Water of Acero.', 0
		db	'           a Sabre Oil.', 0
		db	'       a Kioku Feather.', 0
		db	 9Ah,0AAh, 44h,0ACh, 58h,0ACh
		db	 6Dh,0ACh, 81h,0ACh, 96h,0ACh
		db	0A3h,0ACh,0BBh,0ACh,0C6h,0ACh
		db	'Ken\ko', 0
		db	'      Potion', 0
		db	'Juu-en ', 0
		db	'       Fruit', 0
		db	'Elixir', 0
		db	'    of Kashi', 0
		db	'Chikara', 0
		db	'      Powder', 0
		db	'Magia Stone'
		db	0, 0
		db	'Holy Water', 0
		db	'    of Acero', 0
		db	'Sabre Oil'
		db	 00h, 00h, 4Bh, 69h, 6Fh, 6Bh
		db	 75h, 00h
		db	'     feather'
		db	 00h,0E5h,0ACh,0F9h,0ACh, 10h
		db	0ADh, 21h,0ADh, 34h,0ADh, 4Eh
		db	0ADh
		db	'Training', 0
		db	'     Sword', 0
		db	'Wise man\s', 0
		db	'      Sword', 0
		db	'Spirit', 0
		db	'    Sword', 0
		db	'Knight\s', 0
		db	'    Sword', 0
		db	'Illumination', 0
		db	'       Sword', 0
		db	'Enchantment', 0
		db	'       Sword', 0
		db	 73h,0ADh, 84h,0ADh, 9Ch,0ADh
		db	0AEh,0ADh,0C0h,0ADh,0D2h,0ADh
		db	 43h, 6Ch
		db	'ay', 0
		db	'     Shield', 0
		db	'Wise Man\s', 0
		db	'      Shield', 0
		db	'Stone', 0
		db	'     Shield', 0
		db	'Honor', 0
		db	'     Shield', 0
		db	'Light', 0
		db	'     Shield', 0
		db	'Titanium', 0
		db	'      Shield', 0
		db	0Eh
		db	0Ch, '38?', 0Ch, '0"m', 0Ch, '0"?'
		db	'-^'
		db	17h
		db	37 dup (0)

seg_a		ends



		end	start
