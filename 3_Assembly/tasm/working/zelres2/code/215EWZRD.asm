
PAGE  59,132

;==========================================================================
;
;  ENEMY_WIZARD - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_36e	equ	2000h			;*
data_37e	equ	2002h			;*
data_38e	equ	2010h			;*
data_39e	equ	2012h			;*
data_40e	equ	2016h			;*
data_41e	equ	2040h			;*
data_42e	equ	2044h			;*
data_43e	equ	3016h			;*
data_44e	equ	6004h			;*
data_45e	equ	6006h			;*
data_46e	equ	6008h			;*
data_47e	equ	600Ah			;*
data_48e	equ	600Ch			;*
data_49e	equ	6010h			;*
data_50e	equ	6012h			;*
data_51e	equ	0A0C3h			;*
data_52e	equ	0A494h			;*
data_53e	equ	0A5E4h			;*
data_54e	equ	0A644h			;*
data_55e	equ	0A69Ch			;*
data_56e	equ	0A745h			;*
data_57e	equ	0AB3Ah			;*
data_58e	equ	0B08Ah			;*
data_59e	equ	0B10Ch			;*
data_60e	equ	0B1F6h			;*
data_61e	equ	0B20Eh			;*
data_62e	equ	0B20Fh			;*
data_63e	equ	0B217h			;*
data_64e	equ	0B218h			;*
data_65e	equ	0B219h			;*
data_66e	equ	0B21Ah			;*
data_67e	equ	0B21Bh			;*
data_68e	equ	0B21Ch			;*
data_69e	equ	0C006h			;*
data_70e	equ	0FF1Ah			;*
data_71e	equ	0FF2Ch			;*
data_72e	equ	0FF4Ch			;*
data_73e	equ	0FF4Eh			;*
data_74e	equ	0FF4Fh			;*
data_75e	equ	0FF50h			;*
data_76e	equ	0FF52h			;*
data_77e	equ	0FF53h			;*
data_78e	equ	0FF54h			;*
data_79e	equ	0FF56h			;*
data_80e	equ	0FF57h			;*
data_81e	equ	0FF58h			;*
data_82e	equ	0FF68h			;*
data_83e	equ	0FF6Ah			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_15		proc	far

start:
		adc	al,es:[bx+si]
		add	[si],al
		mov	al,ds:data_54e
		mov	es,ds:data_71e
		mov	di,8000h
		mov	si,0A811h
		mov	al,2
		call	word ptr cs:data_5
		push	ds
		mov	ds,cs:data_71e
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:data_42e
		pop	ds
		mov	byte ptr ds:data_73e,0
		mov	byte ptr ds:data_74e,0
		mov	byte ptr ds:data_63e,0
		call	word ptr cs:data_37e
		call	word ptr cs:data_39e
		mov	si,0A81Ch
		call	word ptr cs:data_38e
		call	wizard_process_loop
		push	cs
		pop	es
		mov	bl,ds:data_69e
		dec	bl
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:data_59e[bx]
		mov	di,data_60e
		mov	cx,0Ch
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		call	wizard_process_loop_3
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_36e
		mov	word ptr ds:data_72e,0A86Bh
loc_2:
		call	word ptr cs:data_44e
		cmp	al,0FFh
		je	loc_3			; Jump if equal
		call	wizard_func_2
		jmp	short loc_2
loc_3:
		jmp	word ptr cs:data_41e

zr2_15		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

wizard_process_loop		proc	near
		mov	si,offset data_4
		mov	al,ds:data_69e
		dec	al
		xor	ah,ah			; Zero register
		add	si,ax
		mov	dl,[si]
		push	cs
		pop	es
		mov	di,data_62e
		xor	dh,dh			; Zero register
		mov	cx,8

locloop_4:
		add	dl,dl
		jnc	loc_5			; Jump if carry=0
		mov	al,cl
		neg	al
		add	al,8
		stosb				; Store al to es:[di]
		inc	dh
loc_5:
		loop	locloop_4		; Loop if cx > 0

		mov	ds:data_61e,dh
		retn
wizard_process_loop		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

wizard_func_2		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:data_51e[bx]	;*
wizard_func_2		endp

		db	0D5h,0A0h
data_4		db	0EBh
		db	0A0h, 0Ch,0A1h, 8Dh,0A1h,0AAh
		db	0A1h, 00h,0A3h,0BAh,0A4h, 00h
		db	0A1h, 06h,0A1h,0C6h, 06h, 1Ah
		db	0FFh, 00h
loc_6:
		call	wizard_multiply
		cmp	byte ptr ds:data_70e,50h	; 'P'
		jb	loc_6			; Jump if below
		mov	si,data_56e
		call	wizard_scan_loop
		retn
		db	0C6h, 06h, 1Ah,0FFh, 00h
loc_7:
		call	wizard_multiply
		cmp	byte ptr ds:data_70e,50h	; 'P'
		jb	loc_7			; Jump if below
		mov	si,0A74Fh
		jmp	loc_34
			                        ;* No entry point to code
		mov	si,0A759h
		jmp	loc_34
		db	0BEh, 61h
data_5		dw	0E9A7h
		db	0FCh, 05h,0E8h,0A3h, 04h,0BBh
		db	 22h, 27h,0B9h, 2Dh, 1Ch,0B0h
		db	0FFh, 2Eh,0FFh, 16h, 00h, 20h
		db	0C7h, 06h, 54h,0FFh, 25h, 27h
		db	0C6h, 06h, 52h,0FFh, 04h,0C6h
		db	 06h, 53h,0FFh, 04h,0B9h, 04h
		db	 00h,0BEh, 39h,0A8h, 2Eh,0FFh
		db	 16h, 0Eh, 60h,0C6h, 06h, 56h
		db	0FFh, 00h, 8Ah, 1Eh, 17h,0B2h
		db	 2Eh,0FFh, 16h, 10h, 60h, 73h
		db	 02h, 32h,0DBh, 88h, 1Eh, 17h
		db	0B2h, 32h,0FFh, 03h,0DBh,0FFh
		db	0A7h, 55h,0A1h, 5Dh,0A1h, 67h
		db	0A1h, 6Eh,0A1h, 86h,0A1h,0E8h
		db	 52h, 04h,0C7h, 06h, 4Ch,0FFh
		db	 0Eh,0ABh,0C3h,0C7h, 06h, 4Ch
		db	0FFh, 8Ch,0A8h,0C3h,0E8h, 2Bh
		db	 03h,0C7h, 06h, 4Ch,0FFh, 8Dh
		db	0A9h,0F6h, 06h, 53h,0FFh,0FFh
		db	 74h, 01h,0C3h,0C7h, 06h, 4Ch
		db	0FFh, 79h,0AAh,0C3h,0C7h, 06h
		db	 4Ch,0FFh,0A6h,0AAh,0C3h, 0Eh
		db	 07h,0BEh, 0Fh,0B2h,0BFh, 58h
		db	0FFh,0B9h, 08h, 00h,0F3h,0A4h
		db	0A0h, 0Eh,0B2h,0A2h, 53h,0FFh
		db	0C6h, 06h, 56h,0FFh, 00h,0C6h
		db	 06h, 18h,0B2h, 00h,0A0h, 0Eh
		db	0B2h,0A2h, 53h,0FFh, 3Ch, 03h
		db	 72h, 02h,0B0h, 03h
loc_8:
		mov	ds:data_76e,al
		mov	bx,156Eh
		mov	cx,2524h
		mov	al,0FFh
		call	word ptr cs:data_36e
		mov	byte ptr ds:data_80e,0FFh
		mov	word ptr ds:data_78e,1571h
		mov	word ptr ds:data_83e,21h
		mov	word ptr ds:data_82e,17h
		mov	si,0B08Ah
		mov	di,0B1F6h
		mov	cl,ds:data_76e
		xor	ch,ch			; Zero register
		mov	al,ds:data_79e
		call	word ptr cs:data_50e
		mov	bl,ds:data_64e
		call	word ptr cs:data_49e
		jnc	loc_9			; Jump if carry=0
		mov	word ptr ds:data_72e,0A965h
		retn
loc_9:
		mov	ds:data_64e,bl
		mov	al,bl
		add	al,ds:data_79e
		mov	bx,data_81e
		xlat				; al=[al+[bx]] table
		push	ax
		mov	word ptr ds:data_72e,0A8C4h
		call	word ptr cs:data_44e
		pop	ax
		push	ax
		mov	si,ds:data_72e
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:data_58e[bx]
		mov	ds:data_72e,ax
		call	word ptr cs:data_44e
		pop	si
		mov	ds:data_72e,si
		call	word ptr cs:data_44e
		pop	ax
		push	ax
		xor	ah,ah			; Zero register
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		mov	si,data_60e
		add	si,ax
		mov	dl,[si]
		mov	ax,[si+1]
		mov	ds:data_67e,dl
		mov	ds:data_68e,ax
		call	word ptr cs:data_47e
		pop	bx
		mov	word ptr ds:data_72e,0A928h
		jc	loc_12			; Jump if carry Set
		push	dx
		push	ax
		mov	si,0A6h
		mov	cx,5

locloop_10:
		test	byte ptr [si],0FFh
		jz	loc_11			; Jump if zero
		inc	si
		loop	locloop_10		; Loop if cx > 0

		pop	ax
		pop	dx
		mov	word ptr ds:data_72e,0A940h
		retn
loc_11:
		pop	ax
		pop	dx
		mov	byte ptr ds:[85h],dl
		mov	word ptr ds:[86h],ax
		inc	bl
		mov	[si],bl
		mov	word ptr ds:data_72e,0A8F2h
		call	word ptr cs:data_44e
		mov	dl,ds:data_67e
		mov	ax,ds:data_68e
		mov	di,0B21Eh
		call	word ptr cs:data_45e
		mov	si,ds:data_72e
		push	si
		mov	word ptr ds:data_72e,0B21Eh
		call	word ptr cs:data_44e
		pop	si
		mov	ds:data_72e,si
loc_12:
		call	word ptr cs:data_44e
		call	word ptr cs:data_40e
		mov	word ptr ds:data_72e,0A909h
		call	word ptr cs:data_44e
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_36e
		mov	word ptr ds:data_78e,302Eh
		call	word ptr cs:data_46e
		pushf				; Push flags
		call	wizard_func_4
		popf				; Pop flags
		mov	word ptr ds:data_72e,0A8A8h
		jc	loc_13			; Jump if carry Set
		retn
loc_13:
		mov	word ptr ds:data_72e,0A965h
		retn
			                        ;* No entry point to code
		call	wizard_process_loop_2
		mov	byte ptr ds:data_79e,0
		mov	al,ds:data_77e
		cmp	al,2
		jb	loc_14			; Jump if below
		mov	al,2
loc_14:
		mov	ds:data_76e,al
		mov	bx,1778h
		mov	cx,211Ah
		mov	al,0FFh
		call	word ptr cs:data_36e
		mov	byte ptr ds:data_80e,0
		mov	word ptr ds:data_78e,197Bh
		mov	word ptr ds:data_83e,19h
		mov	si,0B08Ah
		mov	cl,ds:data_76e
		xor	ch,ch			; Zero register
		mov	al,ds:data_79e
		call	word ptr cs:data_50e
		xor	bl,bl			; Zero register
		call	word ptr cs:data_49e
		jnc	loc_15			; Jump if carry=0
		mov	word ptr ds:data_72e,0A965h
		retn
loc_15:
		mov	ds:data_64e,bl
		mov	word ptr ds:data_72e,0A8D7h
		call	word ptr cs:data_44e
		mov	al,ds:data_64e
		add	al,ds:data_79e
		mov	bx,data_81e
		xlat				; al=[al+[bx]] table
		push	ax
		mov	si,ds:data_72e
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:data_58e[bx]
		mov	ds:data_72e,ax
		call	word ptr cs:data_44e
		pop	si
		mov	ds:data_72e,si
		call	word ptr cs:data_44e
		pop	ax
		mov	cl,3
		mul	cl			; ax = reg * al
		mov	bx,data_60e
		add	bx,ax
		mov	dl,[bx]
		mov	ax,[bx+1]
		shr	dl,1			; Shift w/zeros fill
		rcr	ax,1			; Rotate thru carry
		mov	ds:data_67e,dl
		mov	ds:data_68e,ax
		push	ax
		push	dx
		mov	word ptr ds:data_72e,0A9C4h
		call	word ptr cs:data_44e
		pop	dx
		pop	ax
		mov	di,0B21Eh
		call	word ptr cs:data_45e
		mov	si,ds:data_72e
		push	si
		mov	word ptr ds:data_72e,0B21Eh
		call	word ptr cs:data_44e
		pop	si
		mov	ds:data_72e,si
		call	word ptr cs:data_44e
		mov	bx,3421h
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_36e
		mov	word ptr ds:data_78e,3524h
		call	word ptr cs:data_46e
		mov	word ptr ds:data_72e,0A9FEh
		jnc	loc_16			; Jump if carry=0
		retn
loc_16:
		mov	dl,ds:data_67e
		mov	ax,ds:data_68e
		call	word ptr cs:data_48e
		mov	word ptr ds:data_72e,0A9ADh
		call	word ptr cs:data_44e
		mov	al,ds:data_64e
		add	al,ds:data_79e
		mov	bx,data_81e
		xlat				; al=[al+[bx]] table
		inc	al
		mov	si,0A6h
		mov	cx,5

locloop_17:
		cmp	al,[si]
		je	loc_18			; Jump if equal
		inc	si
		loop	locloop_17		; Loop if cx > 0

loc_18:
		mov	byte ptr [si],0
		dec	al
		xor	ah,ah			; Zero register
		push	ax
		mov	al,ds:data_69e
		dec	al
		mov	si,offset data_4
		add	si,ax
		pop	ax
		mov	di,data_52e
		add	di,ax
		mov	al,[di]
		or	[si],al
		call	word ptr cs:data_40e
		call	wizard_process_loop_2
		mov	word ptr ds:data_72e,0A966h
		test	byte ptr ds:data_77e,0FFh
		jnz	loc_19			; Jump if not zero
		retn
loc_19:
		mov	word ptr ds:data_72e,0AA4Bh
		call	word ptr cs:data_44e
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_36e
		mov	word ptr ds:data_78e,302Eh
		call	word ptr cs:data_46e
		mov	word ptr ds:data_72e,0A965h
		jnc	loc_20			; Jump if carry=0
		retn
loc_20:
		call	wizard_func_4
		mov	word ptr ds:data_72e,0A98Dh
		retn
			                        ;* No entry point to code
		add	byte ptr [bx+si+20h],10h
		or	[si],al
		add	al,[bx+di]

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

wizard_process_loop_2		proc	near
		push	cs
		pop	es
		mov	si,0A6h
		mov	di,data_81e
		mov	cx,5
		xor	dl,dl			; Zero register

locloop_21:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_22			; Jump if zero
		dec	al
		stosb				; Store al to es:[di]
		inc	dl
loc_22:
		loop	locloop_21		; Loop if cx > 0

		mov	ds:data_77e,dl
		retn
wizard_process_loop_2		endp

			                        ;* No entry point to code
		mov	byte ptr ds:data_64e,0
		mov	byte ptr ds:data_79e,0
loc_23:
		push	cs
		pop	es
		mov	si,data_62e
		mov	di,data_81e
		mov	cx,8
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	al,ds:data_61e
		mov	ds:data_77e,al
		mov	al,ds:data_77e
		cmp	al,2
		jb	loc_24			; Jump if below
		mov	al,2
loc_24:
		mov	ds:data_76e,al
		mov	bx,1778h
		mov	cx,211Ah
		mov	al,0FFh
		call	word ptr cs:data_36e
		mov	byte ptr ds:data_80e,0
		mov	word ptr ds:data_78e,197Bh
		mov	word ptr ds:data_83e,19h
		mov	si,0B08Ah
		mov	cl,ds:data_76e
		xor	ch,ch			; Zero register
		mov	al,ds:data_79e
		call	word ptr cs:data_50e
		mov	bl,ds:data_64e
		call	word ptr cs:data_49e
		jnc	loc_25			; Jump if carry=0
		mov	word ptr ds:data_72e,0A965h
		retn
loc_25:
		mov	ds:data_64e,bl
		mov	word ptr ds:data_72e,0AACAh
		call	word ptr cs:data_44e
		mov	al,ds:data_64e
		add	al,ds:data_79e
		mov	bx,data_81e
		xlat				; al=[al+[bx]] table
		push	ax
		mov	si,ds:data_72e
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:data_58e[bx]
		mov	ds:data_72e,ax
		call	word ptr cs:data_44e
		pop	si
		mov	ds:data_72e,si
		call	word ptr cs:data_44e
		pop	ax
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:data_57e[bx]
		mov	ds:data_72e,ax
		call	word ptr cs:data_44e
		mov	word ptr ds:data_72e,0AAE9h
		call	word ptr cs:data_44e
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:data_36e
		mov	word ptr ds:data_78e,302Eh
		call	word ptr cs:data_46e
		pushf				; Push flags
		call	wizard_func_4
		popf				; Pop flags
		mov	word ptr ds:data_72e,0A965h
		jnc	loc_26			; Jump if carry=0
		retn
loc_26:
		mov	word ptr ds:data_72e,0AAA6h
		call	word ptr cs:data_44e
		jmp	loc_23

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

wizard_func_4		proc	near
		mov	bx,2717h
		mov	cx,1D41h
		xor	al,al			; Zero register
		jmp	word ptr cs:data_36e
wizard_func_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

wizard_process_loop_3		proc	near
		mov	si,data_53e
		mov	bx,717h
		mov	cx,8

locloop_27:
		push	cx
		mov	cx,0Ch

locloop_28:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_43e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_28		; Loop if cx > 0

		sub	bh,0Ch
		add	bl,8
		pop	cx
		loop	locloop_27		; Loop if cx > 0

		retn
wizard_process_loop_3		endp

		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 1Ch, 1Dh, 1Eh, 1Fh, 20h, 21h
		db	 06h, 09h, 7Dh, 7Eh, 7Fh, 80h
		db	 22h, 23h, 24h, 25h, 26h, 27h
		db	 06h, 0Ah, 81h, 82h, 83h, 84h
		db	 28h, 29h, 2Ah, 2Bh, 2Ch, 2Dh
		db	 06h, 0Bh, 85h, 86h, 87h, 88h
		db	 2Eh, 2Fh, 30h, 31h, 32h, 33h
		db	 06h, 0Ch, 89h, 8Ah, 8Bh, 8Ch
		db	 34h, 35h, 36h, 37h, 38h, 39h
		db	 06h, 0Dh, 8Dh, 8Eh, 8Fh, 90h
		db	 3Ah, 3Bh, 3Ch, 3Dh, 3Eh, 3Fh
		db	 07h, 0Eh, 91h, 92h, 93h, 94h
		db	 10h, 11h, 12h, 13h, 14h, 15h
		db	 08h, 0Fh, 95h, 96h, 97h, 98h
		db	 16h, 17h, 18h, 19h, 1Ah
		db	1Bh

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

wizard_multiply		proc	near
		cmp	word ptr ds:data_75e,2
		jae	loc_29			; Jump if above or =
		retn
loc_29:
		mov	word ptr ds:data_75e,0
		inc	byte ptr ds:data_65e
		cmp	byte ptr ds:data_65e,14h
		jae	loc_30			; Jump if above or =
		retn
loc_30:
		mov	byte ptr ds:data_65e,0
		mov	al,ds:data_66e
		inc	al
		cmp	al,3
		jb	loc_31			; Jump if below
		xor	al,al			; Zero register
loc_31:
		mov	ds:data_66e,al
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	si,data_55e
		add	si,ax
		mov	bx,0D17h
		mov	cx,6

locloop_32:
		push	cx
		mov	cx,6

locloop_33:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_43e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_33		; Loop if cx > 0

		sub	bh,6
		add	bl,8
		pop	cx
		loop	locloop_32		; Loop if cx > 0

		retn
wizard_multiply		endp

		db	 1Ch, 1Dh, 1Eh, 1Fh
		db	' !"#$'
		db	'%&', 27h, '()*+,-./0123456789:;<'
		db	'=>?_`abcdefghij(klmno.p01R3qrstu'
		db	'vwxyz{|@ABCDEFGHIJK(LMNOP.Q01RST'
		db	'UV7WXYZ[\]^'

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

wizard_scan_loop		proc	near
loc_34:
		mov	byte ptr ds:data_70e,0
		lodsw				; String [si] to ax
		cmp	ax,0FFFFh
		jne	loc_35			; Jump if not equal
		retn
loc_35:
		push	si
		mov	si,ax
		mov	bx,91Fh
		mov	cx,7

locloop_36:
		push	cx
		mov	cx,4

locloop_37:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_43e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_37		; Loop if cx > 0

		sub	bh,4
		add	bl,8
		pop	cx
		loop	locloop_36		; Loop if cx > 0

loc_38:
		call	wizard_multiply
		cmp	byte ptr ds:data_70e,28h	; '('
		jb	loc_38			; Jump if below
		pop	si
		jmp	short loc_34
wizard_scan_loop		endp

		db	 69h,0A7h, 85h,0A7h,0A1h,0A7h
		db	0BDh,0A7h,0FFh,0FFh,0BDh,0A7h
		db	0A1h,0A7h, 85h,0A7h, 69h,0A7h
		db	0FFh,0FFh,0BDh,0A7h,0D9h,0A7h
		db	0F5h,0A7h,0FFh,0FFh,0F5h,0A7h
		db	0D9h,0A7h,0BDh,0A7h,0FFh,0FFh
		db	 7Dh, 7Eh, 7Fh, 80h, 81h, 82h
		db	 83h, 84h, 85h, 86h, 87h, 88h
		db	 89h, 8Ah, 8Bh, 8Ch, 8Dh, 8Eh
		db	 8Fh, 90h, 91h, 92h, 93h, 94h
		db	 95h, 96h, 97h, 98h, 99h, 9Ah
		db	 7Fh, 80h, 9Bh, 9Ch, 83h, 84h
		db	 9Dh, 9Eh, 9Fh, 88h,0A0h,0A1h
		db	0A2h,0A3h, 8Dh,0A4h,0A5h,0A6h
		db	 91h, 92h, 93h, 94h, 95h, 96h
		db	 97h, 98h, 99h, 9Ah, 7Fh, 80h
		db	 9Bh, 9Ch, 83h, 84h, 9Dh, 9Eh
		db	 9Fh, 88h,0A0h,0A1h,0A2h,0A3h
		db	 8Dh,0A4h,0A5h,0A6h, 91h, 92h
		db	 93h, 94h, 95h, 96h, 97h, 98h
		db	 99h, 9Ah,0B8h,0BFh,0A7h,0B3h
		db	0B9h,0C0h, 85h,0A9h,0BAh,0C1h
		db	0ACh,0B4h,0BBh,0C2h, 8Dh,0B5h
		db	0BCh,0C3h, 91h,0B6h,0BDh,0C4h
		db	 95h,0B7h,0BEh,0C5h, 99h, 9Ah
		db	0C7h,0C6h,0A7h,0CAh,0C9h,0C8h
		db	 85h,0A9h,0CCh,0CBh,0ACh,0B4h
		db	0BBh,0C2h, 8Dh,0B5h,0BCh,0C3h
		db	 91h,0B6h,0BDh,0C4h, 95h,0B7h
		db	0BEh,0C5h, 99h, 9Ah,0CEh,0CDh
		db	0A7h,0D1h,0D0h,0CFh, 85h,0A9h
		db	0D3h,0D2h,0ACh,0B4h,0BBh,0C2h
		db	 8Dh,0B5h,0BCh,0C3h, 91h,0B6h
		db	0BDh,0C4h, 95h,0B7h,0BEh,0C5h
		db	 01h, 18h
		db	'DRUG.GRP'
		db	 00h, 0Eh,0AFh, 00h, 19h, 57h
		db	 69h
		db	'tchcraft Implement shopGo outsid'
		db	'e', 0
		db	'Buy item', 0
		db	'Sell item', 0
		db	'Description of item', 0
		db	'Oh... '
		db	0FFh, 00h
		db	'hello, can I help you?/'
		db	0FFh, 02h
		db	0Ch, 'What are you looking for?'
		db	0FFh, 03h
		db	0Ch, 'What are you looking for?'
		db	0FFh, 04h
		db	0Ch, 'You\d like a '
		db	0FFh, 00h, 2Eh, 2Fh,0FFh
		db	0Ch, 'You\d like to sell a '
		db	0FFh, 00h, 2Eh, 2Fh,0FFh
		db	'That will be '
		db	0FFh, 00h, 26h, 67h, 6Fh, 6Ch
		db	 64h, 73h, 2Eh,0FFh
		db	0Dh, 'Will there be something els'
		db	'e?'
		db	0FFh
		db	'You have no money, sir.'
		db	0FFh, 59h, 6Fh
		db	'u can\t po'
		db	'ssibly carry any more./'
		db	0FFh, 02h
		db	0Ch
		db	'Is ther'
		db	'e something I&can do for you?/'
		db	0FFh, 02h
		db	0Ch, 'What would you like to sell'
		db	'?/'
		db	0FFh, 05h
		db	0Ch, 'Thank you very much./'
		db	0FFh
		db	'I\ll give you '
		db	0FFh, 00h
		db	'&gol'
		db	'ds fo'
		db	'r that./Will that be all right?'
		db	0FFh, 00h
		db	0Ch
		db	'Oh, '
		db	'I'
		db	'&see. Well,'
		db	' th'
		db	'at\s the best'
		db	' I&can do. I\m sorr'
		db	'y it is\t satisfactory.'
		db	0FFh, 02h
		db	'Do you ha'
		db	've '
		db	'anyth'
		db	'ing else you\d like to sell?'
		db	0FFh, 0Ch
		db	'You aren\t carrying any magi'
		db	'c items, sir./'
		db	0FFh, 02h
		db	0Ch, 'W'
		db	'hich item can I tell you about?/'
		db	0FFh, 06h
		db	0Ch, 'You\re interested in the '
		db	0FFh, 00h, 2Eh, 2Fh,0FFh
		db	0Ch, 'Can I tell you about anythi'
		db	'ng else?'
		db	0FFh, 0Ch,0FFh, 07h
		db	'Thank you, sir. '
		db	0FFh
		db	8, 'Please come again.'
		db	0FFh, 01h, 11h,0FFh,0FFh, 4Ah
		db	0ABh,0C5h,0ABh, 9Ch,0ACh, 39h
		db	0ADh,0FDh,0ADh,0A6h,0AEh, 3Dh
		db	0AFh,0D3h,0AFh
		db	'Well, it\s a special blend of yu'
		db	'nkel fruit and ripodi leaf./It\s'
		db	' low in price and as a mild heal'
		db	'th tonic, it\s perfect.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is is the fruit of the Juu-en tr'
		db	'ee which bears only once every t'
		db	'en years./The price is a bit hig'
		db	'h, but it provides excellent rel'
		db	'ief from wounds and exhaustion -'
		db	'- it\s quite a bit better than t'
		db	'he Ken\ko potion.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is potion is made from the broth'
		db	' of mistletoe simmered on the ni'
		db	'ght of a full moon./It restores '
		db	'magical powers. It\s very bitter'
		db	', but the price is low.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is is made from a mixture of the'
		db	' powdered dragon scales and crus'
		db	'hed Wise Man\s Stone steamed for'
		db	' one hundred days./It will fully'
		db	' restore your magical powers. Th'
		db	'e price, however..... is high.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is stone protects the aura that '
		db	'living beings exude./It surround'
		db	's the aura to prevent interferen'
		db	'ce from other auras and acts as '
		db	'a protection against enemy attac'
		db	'ks.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is is a liquified metal made fro'
		db	'm mercury and iron./If you paint'
		db	' it on a shield weakened by batt'
		db	'le, the shield will regain its o'
		db	'riginal strength.'
		db	 11h, 0Ch,0FFh,0FFh, 48h, 6Dh
		db	'm... I don\t know much about thi'
		db	's one, but I do know that it inc'
		db	'reases the offensive power of a '
		db	'sword./Don\t worry, it hasn\t ki'
		db	'lled anyone yet.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is feather remembers the voice o'
		db	'f the last wise man who spoke to'
		db	' you./If you hold it in your rig'
		db	'ht hand and swing it once, you\l'
		db	'l return to him. It\s never fail'
		db	'ed anyone I know.'
		db	 11h, 0Ch,0FFh,0FFh, 9Ah,0B0h
		db	0A8h,0B0h,0B5h,0B0h,0C5h,0B0h
		db	0D4h,0B0h,0E0h,0B0h,0F4h,0B0h
		db	0FEh,0B0h
		db	4Bh
		db	'en\ko Potion', 0
		db	'Juu-en Fruit', 0
		db	'Elixir of Kashi', 0
		db	'Chikara Powder', 0
		db	'Magia Stone', 0
		db	'Holy Water of Acero', 0
		db	'Sabre Oil', 0
		db	'Kioku Feather', 0
		db	 1Eh,0B1h, 36h,0B1h, 4Eh,0B1h
		db	 66h,0B1h, 7Eh,0B1h, 96h,0B1h
		db	0AEh,0B1h,0C6h,0B1h,0DEh,0B1h
		db	 00h, 32h, 00h, 00h,0F0h, 00h
		db	 00h, 3Ch, 00h, 00h, 40h, 01h
		db	 00h,0E8h, 03h, 00h, 64h, 00h
		db	 00h,0B0h, 04h, 00h, 5Eh, 01h
		db	 00h, 32h, 00h, 00h,0F0h, 00h
		db	 00h, 3Ch, 00h, 00h, 40h, 01h
		db	 00h,0E8h, 03h, 00h, 64h, 00h
		db	 00h,0B0h, 04h, 00h, 5Eh, 01h
		db	 00h, 32h, 00h, 00h,0F0h, 00h
		db	 00h, 3Ch, 00h, 00h, 40h, 01h
		db	 00h,0DCh, 05h, 00h, 64h, 00h
		db	 00h,0B0h, 04h, 00h, 5Eh, 01h
		db	 00h, 32h, 00h, 00h, 2Ch, 01h
		db	 00h, 78h, 00h, 00h, 40h, 01h
		db	 00h,0DCh, 05h, 00h, 64h, 00h
		db	 00h,0B0h, 04h, 00h, 5Eh, 01h
		db	 00h, 05h, 00h, 00h, 58h, 02h
		db	 00h,0F0h, 00h, 00h,0E0h, 01h
		db	 00h,0D0h, 07h, 00h,0C8h, 00h
		db	 00h,0D0h, 07h, 00h, 5Eh, 01h
		db	 00h, 05h, 00h, 00h, 58h, 02h
		db	 00h,0F0h, 00h, 00h,0E0h, 01h
		db	 00h,0D0h, 07h, 00h,0C8h, 00h
		db	 00h,0D0h, 07h, 00h, 5Eh, 01h
		db	 00h, 05h, 00h, 00h, 84h, 03h
		db	 00h, 68h, 01h, 00h,0C0h, 03h
		db	 00h,0C4h, 09h, 00h, 90h, 01h
		db	 00h, 60h, 09h, 00h, 5Eh, 01h
		db	 00h, 05h, 00h, 00h, 84h, 03h
		db	 00h, 68h, 01h, 00h,0C0h, 03h
		db	 00h,0C4h, 09h, 00h, 90h, 01h
		db	 00h, 60h, 09h, 00h, 5Eh, 01h
		db	 00h, 02h, 00h, 00h,0C8h, 00h
		db	 00h, 28h, 00h, 00h, 18h, 01h
		db	 00h, 20h, 03h, 00h, 50h, 00h
		db	 00h,0E8h, 03h, 00h, 96h
		db	49 dup (0)

seg_a		ends



		end	start
