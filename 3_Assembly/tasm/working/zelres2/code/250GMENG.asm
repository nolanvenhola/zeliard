
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				ZR2_50	                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   22-Mar-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    9          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	0
data_2e		equ	18D8h			;*
data_3e		equ	29E0h			;*
data_4e		equ	4000h			;*
data_5e		equ	4CE6h			;*
data_6e		equ	53C0h			;*
data_7e		equ	8000h			;*
data_72e	equ	3004h			;*
data_73e	equ	3006h			;*
data_74e	equ	3008h			;*
data_75e	equ	3010h			;*
data_76e	equ	3020h			;*
data_77e	equ	3022h			;*
data_78e	equ	3024h			;*
data_79e	equ	3028h			;*
data_80e	equ	302Eh			;*
data_81e	equ	3030h			;*
data_82e	equ	4000h			;*
data_83e	equ	6630h			;*
data_84e	equ	6632h			;*
data_85e	equ	6634h			;*
data_86e	equ	6635h			;*
data_87e	equ	6636h			;*
data_88e	equ	6637h			;*
data_89e	equ	6820h			;*
data_90e	equ	6965h			;*
data_91e	equ	6967h			;*
data_92e	equ	6968h			;*
data_93e	equ	6969h			;*
data_94e	equ	696Bh			;*
data_95e	equ	696Ch			;*
data_96e	equ	8000h			;*
data_97e	equ	807Dh			;*
data_98e	equ	80DDh			;*
data_99e	equ	8152h			;*
data_100e	equ	815Dh			;*
data_101e	equ	8173h			;*
data_102e	equ	8194h			;*
data_103e	equ	0A000h			;*
data_104e	equ	0FF1Ah			;*
data_105e	equ	0FF21h			;*
data_106e	equ	0FF2Ch			;*
data_107e	equ	0FF50h			;*
data_108e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

ZR2_50		proc	far

start:
		add	ah,[bx+si-6]
		mov	sp,2000h
		sti				; Enable interrupts
		mov	word ptr cs:data_83e,6AA8h
		mov	ax,6
		call	word ptr cs:data_74e
		push	cs
		pop	es
		mov	si,data_99e
		mov	di,data_103e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_106e
		mov	si,data_103e
		mov	di,data_82e
		call	sub_9
		push	cs
		pop	es
		mov	si,data_101e
		mov	di,data_103e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_106e
		mov	si,data_103e
		mov	di,data_96e
		call	sub_9
		mov	es,cs:data_106e
		mov	di,data_82e
		mov	al,0FFh
		mov	bx,0B18h
		mov	cx,1858h
		call	word ptr cs:data_72e
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		push	ds
		mov	di,data_1e
		mov	ds,cs:data_106e
		mov	si,data_7e
		mov	ax,0B2h
		call	sub_11
		pop	ds
		mov	di,0
		mov	al,0FFh
		mov	bx,2D71h
		mov	cx,1858h
		call	word ptr cs:data_72e
		mov	byte ptr cs:data_104e,0
		mov	al,0FFh
		call	sub_1
		mov	cx,59h

locloop_1:
		push	cx
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	ax,cx
		dec	ax
		add	ax,ax
		push	ds
		mov	di,data_1e
		mov	ds,cs:data_106e
		mov	si,data_7e
		call	sub_11
		pop	ds
		pop	cx
		push	cx
		mov	bx,cx
		add	bx,17h
		mov	bh,2Dh			; '-'
		mov	di,0
		mov	cx,1858h
		call	word ptr cs:data_75e
		mov	al,0Ah
		call	sub_1
		pop	cx
		loop	locloop_1		; Loop if cx > 0

		push	cs
		pop	es
		mov	si,813Dh
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	si,data_103e
		mov	di,0
		call	sub_9
		mov	di,0
		call	word ptr cs:data_79e
		call	sub_3
		push	cs
		pop	es
		mov	si,817Eh
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_106e
		mov	si,data_103e
		mov	di,data_82e
		call	sub_9
		mov	ax,1
		call	word ptr cs:data_76e
		mov	ax,7
		call	word ptr cs:data_74e
		mov	es,cs:data_106e
		mov	di,data_82e
		mov	al,0FFh
		mov	bx,1D12h
		mov	cx,1C64h
		call	word ptr cs:data_72e
		call	sub_3
		push	cs
		pop	es
		mov	si,8148h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_106e
		mov	si,data_103e
		mov	di,data_82e
		call	sub_9
		mov	di,data_82e
		mov	bx,1610h
		mov	cx,2468h
		mov	al,5
		call	word ptr cs:data_77e
		call	sub_3
		push	cs
		pop	es
		mov	si,8152h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_106e
		mov	si,data_103e
		mov	di,data_82e
		call	sub_9
		push	cs
		pop	es
		mov	si,data_100e
		mov	di,data_103e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_106e
		mov	si,data_103e
		mov	di,data_96e
		call	sub_9
		xor	ax,ax			; Zero register
		call	word ptr cs:data_76e
		mov	ax,6
		call	word ptr cs:data_74e
		mov	bx,0A15h
		mov	cx,1A5Dh
		call	word ptr cs:data_78e
		mov	es,cs:data_106e
		mov	di,data_82e
		mov	bx,0B18h
		mov	cx,1858h
		call	word ptr cs:data_75e
		mov	bx,2C15h
		mov	cx,1A5Dh
		call	word ptr cs:data_78e
		mov	es,cs:data_106e
		mov	di,data_96e
		mov	bx,2D18h
		mov	cx,1858h
		call	word ptr cs:data_75e
		call	sub_3
		push	cs
		pop	es
		mov	si,8168h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_106e
		mov	si,data_103e
		mov	di,data_96e
		call	sub_9
		mov	es,cs:data_106e
		mov	di,data_96e
		mov	al,0FFh
		mov	bx,2D18h
		mov	cx,1858h
		call	word ptr cs:data_72e
		call	sub_3
		push	cs
		pop	es
		mov	si,8189h
		mov	di,0A000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_106e
		mov	si,data_103e
		mov	di,data_82e
		call	sub_9
		push	cs
		pop	es
		mov	si,data_102e
		mov	di,data_103e
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:data_106e
		mov	si,data_103e
		mov	di,data_96e
		call	sub_9
		mov	ax,2
		call	word ptr cs:data_76e
		mov	ax,7
		call	word ptr cs:data_74e
		mov	es,cs:data_106e
		mov	di,data_82e
		mov	al,0FFh
		mov	bx,0B12h
		mov	cx,1A64h
		call	word ptr cs:data_72e
		mov	es,cs:data_106e
		mov	di,data_96e
		mov	al,0FFh
		mov	bx,3325h
		mov	cx,1251h
		call	word ptr cs:data_72e
		call	sub_3
		mov	es,cs:data_106e
		mov	di,data_4e
		xor	ax,ax			; Zero register
		mov	cx,0F3Ch
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	di,data_4e
		mov	al,55h			; 'U'
		mov	cx,64h

locloop_2:
		push	cx
		mov	cx,1Ah
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		ror	al,1			; Rotate
		pop	cx
		loop	locloop_2		; Loop if cx > 0

		xor	al,al			; Zero register
		mov	di,4000h
		mov	bx,0B12h
		mov	cx,1A64h
		call	word ptr cs:data_72e
		call	sub_3
		mov	al,0FFh
		mov	bx,0
		mov	cx,50C8h
		call	word ptr cs:data_73e
		jmp	loc_51

ZR2_50		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
loc_3:
		call	sub_2
		cmp	cs:data_104e,al
		jb	loc_3			; Jump if below
		mov	byte ptr cs:data_104e,0
		retn
sub_1		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		push	si
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		pop	si
		retn
sub_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3		proc	near
		mov	byte ptr cs:data_104e,0
loc_4:
		mov	al,10h
		call	sub_1
loc_5:
		push	cs
		pop	ds
		mov	si,ds:data_83e
		lodsb				; String [si] to al
		mov	ds:data_83e,si
		test	al,80h
		jz	loc_6			; Jump if zero
		jmp	loc_10
loc_6:
		cmp	al,20h			; ' '
		je	loc_7			; Jump if equal
		cmp	al,2Eh			; '.'
		je	loc_7			; Jump if equal
		cmp	al,2Ch			; ','
		je	loc_7			; Jump if equal
		cmp	al,22h			; '"'
		je	loc_7			; Jump if equal
		cmp	al,27h			; '''
		je	loc_7			; Jump if equal
		mov	ah,ds:data_88e
		mov	ds:data_108e,ah
loc_7:
		push	ax
		mov	bx,ds:data_84e
		add	bx,4
		mov	al,ds:data_85e
		mov	dl,0Ah
		mul	dl			; ax = reg * al
		add	ax,8Fh
		mov	cx,ax
		pop	ax
		push	bx
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	dl,ds:data_97e[bx]
		mov	dh,bh
		pop	bx
		push	ax
		sub	bx,dx
		push	ax
		push	bx
		push	cx
		inc	bx
		inc	cx
		mov	ah,ds:data_86e
		call	word ptr cs:data_81e
		pop	cx
		pop	bx
		pop	ax
		mov	ah,ds:data_87e
		call	word ptr cs:data_81e
		pop	ax
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	cl,ds:data_98e[bx]
		mov	ch,bh
		add	ds:data_84e,cx
		cmp	al,20h			; ' '
		je	loc_8			; Jump if equal
		jmp	loc_4
loc_8:
		mov	si,ds:data_83e
		call	sub_4
		mov	dx,ds:data_84e
		add	dx,cx
		cmp	dx,138h
		jb	loc_9			; Jump if below
		jmp	loc_30
loc_9:
		jmp	loc_4
loc_10:
		cmp	al,0FFh
		jne	loc_11			; Jump if not equal
		retn
loc_11:
		cmp	al,0FDh
		jne	loc_12			; Jump if not equal
		retn
loc_12:
		mov	ah,al
		and	ah,0F0h
		cmp	ah,80h
		jne	loc_13			; Jump if not equal
		jmp	loc_38
loc_13:
		cmp	ah,90h
		jne	loc_14			; Jump if not equal
		jmp	loc_34
loc_14:
		cmp	ah,0A0h
		jne	loc_15			; Jump if not equal
		jmp	loc_36
loc_15:
		cmp	ah,0B0h
		jne	loc_16			; Jump if not equal
		jmp	loc_39
loc_16:
		cmp	ah,0C0h
		jne	loc_17			; Jump if not equal
		jmp	loc_41
loc_17:
		mov	bx,701h
		cmp	al,0FBh
		jne	loc_18			; Jump if not equal
		jmp	loc_28
loc_18:
		mov	bx,700h
		cmp	al,0FAh
		jne	loc_19			; Jump if not equal
		jmp	loc_28
loc_19:
		mov	bx,602h
		cmp	al,0F9h
		je	loc_28			; Jump if equal
		cmp	al,0F5h
		jne	loc_20			; Jump if not equal
		jmp	loc_32
loc_20:
		cmp	al,0F6h
		jne	loc_21			; Jump if not equal
		jmp	loc_33
loc_21:
		xor	ah,ah			; Zero register
		cmp	al,0F7h
		je	loc_29			; Jump if equal
		inc	ah
		cmp	al,0F3h
		je	loc_29			; Jump if equal
		inc	ah
		cmp	al,0F2h
		je	loc_29			; Jump if equal
		inc	ah
		cmp	al,0F1h
		je	loc_29			; Jump if equal
		cmp	al,0FEh
		je	loc_31			; Jump if equal
		mov	ah,ds:data_88e
		mov	byte ptr ds:data_88e,0
		cmp	al,0F0h
		jne	loc_22			; Jump if not equal
		jmp	loc_4
loc_22:
		mov	byte ptr ds:data_88e,3Dh	; '='
		cmp	al,0EFh
		jne	loc_23			; Jump if not equal
		jmp	loc_4
loc_23:
		mov	byte ptr ds:data_88e,3Eh	; '>'
		cmp	al,0EEh
		jne	loc_24			; Jump if not equal
		jmp	loc_4
loc_24:
		mov	byte ptr ds:data_88e,3Fh	; '?'
		cmp	al,0EDh
		jne	loc_25			; Jump if not equal
		jmp	loc_4
loc_25:
		mov	byte ptr ds:data_88e,40h	; '@'
		cmp	al,0ECh
		jne	loc_26			; Jump if not equal
		jmp	loc_4
loc_26:
		mov	byte ptr ds:data_88e,41h	; 'A'
		cmp	al,0EBh
		jne	loc_27			; Jump if not equal
		jmp	loc_4
loc_27:
		mov	ds:data_88e,ah
		jmp	loc_4
loc_28:
		mov	ds:data_86e,bl
		mov	ds:data_87e,bh
		jmp	loc_4
loc_29:
		mov	word ptr ds:data_84e,0
		mov	ds:data_85e,ah
		jmp	loc_4
loc_30:
		mov	word ptr ds:data_84e,0
		inc	byte ptr ds:data_85e
		jmp	loc_4
loc_31:
		mov	bx,8Fh
		mov	cx,5039h
		xor	al,al			; Zero register
		call	word ptr cs:data_62
		xor	ah,ah			; Zero register
		jmp	short loc_29
loc_32:
		mov	al,0F0h
		call	sub_1
		jmp	loc_4
loc_33:
		mov	al,0F0h
		call	sub_1
		mov	al,0F0h
		call	sub_1
		mov	al,0F0h
		call	sub_1
		jmp	loc_4
loc_34:
		mov	es,cs:data_106e
		and	al,0Fh
		cmp	al,6
		jae	loc_35			; Jump if above or =
		mov	ah,1Bh
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,58C0h
		mov	di,ax
		mov	bx,1350h
		mov	cx,920h
		call	word ptr cs:data_75e
		jmp	loc_5
loc_35:
		sub	al,6
		mov	ah,21h			; '!'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,6D00h
		mov	di,ax
		mov	bx,1238h
		mov	cx,0B10h
		call	word ptr cs:data_75e
		jmp	loc_5
loc_36:
		push	cs
		pop	es
		and	al,0Fh
		cmp	al,3
		jae	loc_37			; Jump if above or =
		mov	ah,0A5h
		mul	ah			; ax = reg * al
		add	ax,7437h
		mov	di,ax
		mov	bx,3548h
		mov	cx,50Bh
		call	word ptr cs:data_75e
		jmp	loc_5
loc_37:
		sub	al,3
		mov	ah,0A8h
		mul	ah			; ax = reg * al
		add	ax,7626h
		mov	di,ax
		mov	bx,343Eh
		mov	cx,708h
		call	word ptr cs:data_75e
		jmp	loc_5
loc_38:
		mov	es,cs:data_106e
		and	al,0Fh
		mov	ah,3Fh			; '?'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,98C0h
		mov	di,ax
		mov	bx,3850h
		mov	cx,718h
		call	word ptr cs:data_75e
		jmp	loc_5
loc_39:
		mov	es,cs:data_106e
		and	al,0Fh
		cmp	al,6
		jae	loc_40			; Jump if above or =
		mov	ah,51h			; 'Q'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,98C0h
		mov	di,ax
		mov	bx,3450h
		mov	cx,918h
		call	word ptr cs:data_75e
		jmp	loc_5
loc_40:
		sub	al,6
		mov	ah,2Dh			; '-'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,0A7F0h
		mov	di,ax
		mov	bx,3338h
		mov	cx,0A18h
		call	word ptr cs:data_75e
		jmp	loc_5
loc_41:
		and	al,0Fh
		push	cs
		pop	es
		mov	ah,30h			; '0'
		mul	ah			; ax = reg * al
		add	ax,781Eh
		mov	di,ax
		mov	bx,3840h
		mov	cx,208h
		call	word ptr cs:data_75e
		jmp	loc_5
sub_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_4		proc	near
		xor	cx,cx			; Zero register
loc_42:
		lodsb				; String [si] to al
		cmp	al,20h			; ' '
		jne	loc_43			; Jump if not equal
		retn
loc_43:
		cmp	al,0FFh
		jne	loc_44			; Jump if not equal
		retn
loc_44:
		cmp	al,0FEh
		jne	loc_45			; Jump if not equal
		retn
loc_45:
		cmp	al,0FDh
		jne	loc_46			; Jump if not equal
		retn
loc_46:
		cmp	al,0F7h
		jne	loc_47			; Jump if not equal
		retn
loc_47:
		cmp	al,0F3h
		jne	loc_48			; Jump if not equal
		retn
loc_48:
		cmp	al,0F2h
		jne	loc_49			; Jump if not equal
		retn
loc_49:
		cmp	al,0F1h
		jne	loc_50			; Jump if not equal
		retn
loc_50:
		or	al,al			; Zero ?
		js	loc_42			; Jump if sign=1
		sub	al,20h			; ' '
		jc	loc_42			; Jump if carry Set
		mov	bl,al
		xor	bh,bh			; Zero register
		add	cl,cs:data_98e[bx]
		adc	ch,bh
		jmp	short loc_42
sub_4		endp

			                        ;* No entry point to code
		test	al,6Ah			; 'j'
		db	0, 0, 0, 0, 0, 0
loc_51:
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		mov	byte ptr ds:data_95e,0
		mov	si,81E0h
		mov	es,cs:data_106e
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	si,819Fh
		mov	di,0
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,81AAh
		mov	di,3400h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,81B5h
		mov	di,5E00h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,81C0h
		mov	di,8A00h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,81CBh
		mov	di,0B800h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,81D6h
		mov	di,0E200h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	ax,7
		call	word ptr cs:data_74e
		push	ds
		mov	ds,cs:data_106e
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	word ptr ds:data_90e,787Eh
		call	sub_5
loc_52:
		call	sub_8
		jmp	short loc_52

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_5		proc	near
		mov	byte ptr ds:data_104e,0
loc_53:
		mov	si,ds:data_90e
		lodsb				; String [si] to al
		mov	ds:data_90e,si
		cmp	al,0F7h
		je	loc_64			; Jump if equal
		cmp	al,0F8h
		jne	loc_54			; Jump if not equal
		jmp	loc_65
loc_54:
		cmp	al,0F9h
		jne	loc_55			; Jump if not equal
		jmp	loc_66
loc_55:
		cmp	al,0FAh
		jne	loc_56			; Jump if not equal
		jmp	loc_68
loc_56:
		cmp	al,0FBh
		jne	loc_57			; Jump if not equal
		jmp	loc_69
loc_57:
		cmp	al,0FCh
		jne	loc_58			; Jump if not equal
		jmp	loc_70
loc_58:
		cmp	al,0FDh
		jne	loc_59			; Jump if not equal
		jmp	loc_71
loc_59:
		cmp	al,0FEh
		jne	loc_60			; Jump if not equal
		jmp	loc_74
loc_60:
		cmp	al,0FFh
		jne	loc_61			; Jump if not equal
		jmp	loc_73
loc_61:
		cmp	al,9
		jne	loc_62			; Jump if not equal
		jmp	loc_72
loc_62:
		push	ax
		xor	al,al			; Zero register
		call	sub_6
		mov	al,ds:data_92e
		mov	cl,0Eh
		mul	cl			; ax = reg * al
		mov	cl,al
		add	cl,90h
		mov	bl,ds:data_91e
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	bx,bx
		pop	ax
		mov	ah,7
		call	word ptr cs:data_81e
		inc	byte ptr ds:data_91e
loc_63:
		mov	al,0FFh
		call	sub_6
		mov	al,ds:data_94e
		call	sub_7
		jmp	loc_53
loc_64:
		call	sub_8
		test	byte ptr ds:data_105e,0FFh
		jz	loc_64			; Jump if zero
		mov	byte ptr ds:data_105e,0
		mov	word ptr ds:data_107e,0
		jmp	loc_53
loc_65:
		lodsw				; String [si] to ax
		mov	ds:data_90e,si
		mov	ds:data_93e,ax
		jmp	loc_53
loc_66:
		xor	al,al			; Zero register
		call	sub_6
loc_67:
		call	sub_8
		mov	ax,ds:data_107e
		cmp	ax,ds:data_93e
		jb	loc_67			; Jump if below
		mov	word ptr ds:data_107e,0
		jmp	loc_53
loc_68:
		lodsb				; String [si] to al
		mov	ds:data_90e,si
		mov	ds:data_94e,al
		jmp	loc_53
loc_69:
		lodsw				; String [si] to ax
		mov	ds:data_92e,al
		mov	ds:data_91e,ah
		mov	ds:data_90e,si
		jmp	loc_53
loc_70:
		mov	bx,8Ch
		mov	cx,503Ch
		xor	al,al			; Zero register
		call	word ptr cs:data_62
		mov	byte ptr ds:data_91e,0
		mov	byte ptr ds:data_92e,0
		jmp	loc_53
loc_71:
		xor	al,al			; Zero register
		call	sub_6
		mov	byte ptr ds:data_91e,0
		inc	byte ptr ds:data_92e
		jmp	loc_53
loc_72:
		xor	al,al			; Zero register
		call	sub_6
		add	byte ptr ds:data_91e,4
		and	byte ptr ds:data_91e,0FCh
		jmp	loc_63

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_6:
		push	ax
		mov	al,ds:data_92e
		mov	cl,0Eh
		mul	cl			; ax = reg * al
		add	al,90h
		mov	ah,ds:data_91e
		add	ah,ah
		mov	bx,ax
		pop	ax
		jmp	word ptr cs:data_80e
loc_73:
		xor	al,al			; Zero register
		call	sub_6
		retn
loc_74:
		xor	al,al			; Zero register
		call	sub_6
		mov	bl,ds:data_95e
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:data_89e[bx]	;*
		inc	byte ptr ds:data_95e
		jmp	loc_53
sub_5		endp

			                        ;* No entry point to code
		db	 2Eh, 68h, 5Ah, 68h, 91h, 68h
		db	0B5h, 68h,0C2h, 68h,0CFh, 68h
		db	 32h, 69h, 1Eh, 8Ch,0C8h, 05h
		db	 00h, 20h, 8Eh,0D8h, 2Eh, 8Eh
		db	 06h, 2Ch,0FFh,0BEh, 00h, 00h
		db	0BFh, 00h, 40h,0E8h, 29h, 01h
		db	 1Fh, 2Eh, 8Eh, 06h, 2Ch,0FFh
		db	0BFh, 00h, 40h,0B0h,0FFh,0BBh
		db	 08h, 0Bh,0B9h, 9Ah, 39h, 2Eh
		db	0FFh, 26h, 04h, 30h, 1Eh, 8Ch
		db	0C8h, 05h, 00h, 20h, 8Eh,0D8h
		db	 2Eh, 8Eh, 06h, 2Ch,0FFh,0BFh
		db	 00h, 40h,0BEh, 00h, 34h,0E8h
		db	0FDh, 00h, 1Fh,0BBh, 08h, 0Bh
		db	0B9h, 9Ah, 39h, 2Eh,0FFh, 16h
		db	 06h, 30h, 2Eh, 8Eh, 06h, 2Ch
		db	0FFh,0BFh, 00h, 40h,0B0h,0FFh
		db	0BBh, 14h, 21h,0B9h, 72h, 2Fh
		db	 2Eh,0FFh, 26h, 04h, 30h, 1Eh
		db	 8Ch,0C8h, 05h, 00h, 20h, 8Eh
		db	0D8h, 2Eh, 8Eh, 06h, 2Ch,0FFh
		db	0BEh, 00h, 5Eh,0BFh, 00h, 40h
		db	0E8h,0C6h, 00h, 1Fh, 2Eh, 8Eh
		db	 06h, 2Ch,0FFh,0BFh, 00h, 40h
		db	 2Eh,0FFh, 26h, 2Ah, 30h, 2Eh
		db	 8Eh, 06h, 2Ch,0FFh,0BFh, 00h
		db	 40h, 2Eh,0FFh, 26h, 2Ch, 30h
		db	0B0h,0FFh,0BBh, 00h, 00h,0B9h
		db	0C8h, 50h, 2Eh,0FFh, 26h, 06h
		db	 30h, 1Eh, 8Ch,0C8h, 05h, 00h
		db	 20h, 8Eh,0D8h, 2Eh, 8Eh, 06h
		db	 2Ch,0FFh,0BEh, 00h, 8Ah,0BFh
		db	 00h, 40h,0E8h, 88h, 00h,0BEh
		db	 00h,0B8h,0BFh,0C0h, 93h,0B9h
		db	0F0h, 14h,0F3h,0A5h, 1Fh,0BFh
		db	 00h, 40h, 33h,0C0h,0B9h, 28h
		db	 00h,0F3h,0ABh, 2Eh, 8Eh, 06h
		db	 2Ch,0FFh,0BFh, 00h, 40h,0B0h
		db	0FFh,0BBh, 00h, 00h,0B9h, 86h
		db	 50h, 2Eh,0FFh, 16h, 04h, 30h
		db	 1Eh, 8Ch,0C8h, 05h, 00h, 20h
		db	 8Eh,0D8h, 2Eh, 8Eh, 06h, 2Ch
		db	0FFh,0BEh, 00h,0E2h,0BFh,0A0h
		db	0BDh,0E8h, 4Ch, 00h, 1Fh, 2Eh
		db	 8Eh, 06h, 2Ch,0FFh,0BFh,0A0h
		db	0BDh,0E9h, 20h, 01h, 2Eh, 8Eh
		db	 06h, 2Ch,0FFh,0BFh, 00h, 40h
		db	0BBh, 00h, 00h,0B9h, 86h, 50h
		db	 2Eh,0FFh, 26h, 10h
		db	30h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_7		proc	near
loc_75:
		call	sub_8
		cmp	cs:data_104e,al
		jb	loc_75			; Jump if below
		mov	byte ptr cs:data_104e,0
		retn
sub_7		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_8		proc	near
		push	si
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		pop	ax
		pop	si
		retn
sub_8		endp

		db	8 dup (0)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_9		proc	near
		call	sub_10
		jmp	short loc_80

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_10:
		push	di
		lodsw				; String [si] to ax
		mov	cx,ax
		push	cx
		mov	bp,si
		add	si,cx

locloop_76:
		push	cx
		xor	al,al			; Zero register
		mov	cx,8

locloop_77:
		rol	byte ptr ds:[bp],1	; Rotate
		jc	loc_78			; Jump if carry Set
		stosb				; Store al to es:[di]
		loop	locloop_77		; Loop if cx > 0

		jmp	short loc_79
loc_78:
		movsb				; Mov [si] to es:[di]
		loop	locloop_77		; Loop if cx > 0

loc_79:
		inc	bp
		pop	cx
		loop	locloop_76		; Loop if cx > 0

		pop	cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		pop	di
		retn
loc_80:
		xor	dh,dh			; Zero register

locloop_81:
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		mov	ah,dh
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		add	ah,ah
		add	ah,ah
		or	ah,dh
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		add	ah,ah
		add	ah,ah
		or	ah,dh
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		add	ah,ah
		add	ah,ah
		or	ah,dh
		mov	al,ah
		stosb				; Store al to es:[di]
		loop	locloop_81		; Loop if cx > 0

		retn
sub_9		endp

loc_82:
		test	byte ptr [si],40h	; '@'
		jz	loc_86			; Jump if zero
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cx,ax
		cmp	ax,0FFFFh
		jne	loc_83			; Jump if not equal
		retn
loc_83:
		and	cx,3FFFh
		test	ax,8000h
		jz	loc_85			; Jump if zero
loc_84:
		lodsb				; String [si] to al
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		jmp	short loc_82
loc_85:
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		jmp	short loc_82
loc_86:
		lodsb				; String [si] to al
		mov	cl,al
		and	cx,3Fh
		test	al,80h
		jz	loc_85			; Jump if zero
		jmp	short loc_84

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_11		proc	near
		mov	bx,18h
		mul	bx			; dx:ax = reg * ax
		add	si,ax
		xor	ax,ax			; Zero register
		push	si
		mov	cx,414h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	cx,0Ch
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	si
		add	si,data_2e
		push	si
		mov	cx,414h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	cx,0Ch
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	si
		add	si,data_2e
		mov	cx,414h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	cx,0Ch
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
sub_11		endp

			                        ;* No entry point to code
		push	ds
		push	es
		pop	ds
		push	di
		pop	si
		mov	es,cs:data_106e
		mov	di,data_5e
		mov	cx,35h

locloop_87:
		push	cx
		push	di
		mov	cx,13h

locloop_88:
		lodsw				; String [si] to ax
		or	es:[di],ax
		or	es:data_3e[di],ax
		or	es:data_6e[di],ax
		inc	di
		inc	di
		loop	locloop_88		; Loop if cx > 0

		pop	di
		add	di,50h
		pop	cx
		loop	locloop_87		; Loop if cx > 0

		mov	di,data_5e
		mov	cx,35h

locloop_89:
		push	cx
		push	di
		mov	cx,13h

locloop_90:
		lodsw				; String [si] to ax
		not	ax
		and	es:[di],ax
		and	es:data_3e[di],ax
		and	es:data_6e[di],ax
		inc	di
		inc	di
		loop	locloop_90		; Loop if cx > 0

		pop	di
		add	di,50h
		pop	cx
		loop	locloop_89		; Loop if cx > 0

		pop	ds
		retn
		db	0F0h,0FAh,0F3h
		db	'At long last, Jashiin was destro'
		db	'yed and the nine Tears of Esmesa'
		db	'nti were returned to their right'
		db	'ful place.'
		db	0F5h,0F5h,0F5h,0FEh,0F3h
		db	'Princess Felicia was restored to'
		db	' her true form.'
		db	0F5h,0F5h,0F5h,0FBh,0FEh,0F3h
		db	0EFh, 22h, 95h, 59h, 6Fh, 75h
		db	 20h, 90h, 61h, 72h, 65h, 94h
		db	 20h, 90h, 61h, 95h, 73h, 20h
		db	 92h, 62h, 65h, 95h, 61h, 75h
		db	 92h, 74h, 69h, 95h, 66h, 75h
		db	 93h, 6Ch, 20h, 90h, 61h, 95h
		db	 73h, 20h, 90h, 61h, 20h, 93h
		db	 72h, 6Fh, 91h, 73h, 65h, 20h
		db	 92h, 69h, 94h, 6Eh, 20h, 93h
		db	 62h, 95h, 6Ch, 6Fh, 6Fh, 94h
		db	 6Dh, 21h, 22h,0F5h,0F2h,0EBh
		db	0A3h, 22h,0A4h,0A0h, 54h,0A5h
		db	 68h,0A4h, 61h,0A3h,0A2h, 6Eh
		db	0A1h, 6Bh, 20h,0A2h, 79h, 6Fh
		db	 75h, 2Ch, 20h,0A1h,0A3h, 44h
		db	0A4h, 75h,0A5h, 6Bh,0A4h, 65h
		db	0A3h, 20h,0A0h, 47h, 61h, 72h
		db	0A1h, 6Ch, 61h,0A2h, 6Eh, 64h
		db	 2Eh, 22h,0A1h,0F5h,0F5h,0F5h
		db	0FEh,0F3h, 22h,0A1h, 59h, 6Fh
		db	 75h, 20h,0A0h, 68h, 61h,0A2h
		db	 76h, 65h, 20h,0A1h, 64h, 6Fh
		db	0A2h, 6Eh, 65h, 20h,0A0h, 61h
		db	 20h,0A1h, 67h, 72h, 65h,0A0h
		db	 61h, 74h, 20h,0A1h, 64h, 65h
		db	 65h, 64h, 20h,0A2h, 69h, 6Eh
		db	 20h,0A0h, 64h, 65h, 66h, 65h
		db	 61h,0A1h, 74h,0A2h, 69h, 6Eh
		db	 67h, 20h,0A1h, 4Ah, 61h, 73h
		db	 68h, 69h,0A2h, 69h, 6Eh, 2Eh
		db	0A1h, 20h, 20h,0F5h,0A0h,0A4h
		db	 41h,0A5h, 6Ch,0A4h,0A2h, 74h
		db	0A3h, 68h, 6Fh, 75h,0A1h, 67h
		db	 68h, 20h,0A0h, 6Dh, 79h, 20h
		db	0A1h, 62h, 6Fh, 64h,0A1h, 79h
		db	 20h,0A0h, 77h, 61h,0A1h, 73h
		db	 20h,0A1h, 68h,0A0h, 65h, 72h
		db	 65h, 2Ch, 20h,0A4h, 6Dh,0A5h
		db	0A1h, 79h,0A4h, 20h,0A3h,0A1h
		db	 73h, 6Fh,0A2h, 75h, 6Ch, 20h
		db	0A0h, 77h, 61h,0A2h, 73h, 20h
		db	0A2h, 77h,0A1h, 69h, 74h, 68h
		db	 20h,0A0h, 74h, 68h, 65h, 20h
		db	0A1h, 48h, 6Fh,0A2h, 6Ch, 79h
		db	 20h,0A2h, 53h,0A1h, 70h, 69h
		db	0A0h, 72h,0A2h, 69h, 74h, 2Ch
		db	 20h,0A0h, 77h, 61h, 74h,0A1h
		db	 63h, 68h,0A2h, 69h, 6Eh, 67h
		db	 20h,0A1h, 79h, 6Fh, 75h, 2Eh
		db	 22h,0F5h,0F5h,0F5h,0FEh,0F3h
		db	 22h,0A0h, 49h, 20h,0A1h, 64h
		db	 6Fh,0A2h, 6Eh, 27h, 74h, 20h
		db	0A1h, 6Bh,0A2h, 6Eh, 6Fh, 77h
		db	 20h,0A0h, 68h, 6Fh,0A2h, 77h
		db	 20h,0A1h, 74h, 6Fh, 20h,0A0h
		db	 74h, 68h, 61h,0A2h, 6Eh, 6Bh
		db	 20h,0A1h, 79h, 6Fh, 75h, 20h
		db	0A2h, 66h, 6Fh, 72h, 20h,0A1h
		db	 72h, 65h,0A2h, 73h, 63h, 75h
		db	0A1h, 69h, 6Eh, 67h, 20h,0A2h
		db	 6Dh, 65h, 20h,0A0h, 61h, 6Eh
		db	 64h, 20h,0A1h, 73h, 61h, 76h
		db	0A2h, 69h, 6Eh, 67h, 20h,0A0h
		db	 6Dh, 79h, 20h,0A1h, 63h, 6Fh
		db	0A0h, 75h, 6Eh,0A2h, 74h, 72h
		db	 79h, 2Eh, 22h,0A1h,0F5h,0F5h
		db	0F5h,0FEh,0FDh,0F3h
		db	'"Father!"'
		db	0F5h,0F5h,0F2h,0EEh
		db	'"My darling Felicia!  '
		db	0F5h
		db	'Ho'
		db	'w I'
		db	27h, 've longed to hold you in my'
		db	' arms and hear your sweet voice!'
		db	'"'
		db	0F5h,0F5h,0F5h,0FAh,0FEh,0F3h
		db	0F0h
		db	'Outside, the land cursed by the '
		db	'evil magic of Jashiin began to r'
		db	'esume its original lushness.'
		db	0F5h,0F5h,0F5h,0FEh,0F3h
		db	'The dreadful power of Jashiin wa'
		db	's washed from the earth, and the'
		db	' land of Zeliard was peaceful on'
		db	'ce more.'
		db	0F5h,0F5h,0F5h,0FEh,0FDh,0FAh
		db	0F3h
		db	'The Guardian Spirit of the Holy '
		db	'Land of Zeliard appeared before '
		db	'Duke Garland once again.'
		db	0F5h,0F5h,0F5h,0FEh,0F3h,0FBh
		db	0ECh
		db	'"You have suffered many hardship'
		db	's to defeat Jashiin, Duke Garlan'
		db	'd."'
		db	0F5h,0F5h,0F5h,0FEh,0FDh,0FBh
		db	0F3h, 22h, 83h, 59h, 6Fh, 75h
		db	 20h, 81h, 66h, 6Fh, 75h, 82h
		db	 67h, 68h, 74h, 20h, 83h, 62h
		db	 81h, 72h, 61h, 83h, 76h, 65h
		db	 82h, 6Ch, 79h, 20h, 83h, 74h
		db	 6Fh, 20h, 80h, 61h, 83h, 63h
		db	 63h, 6Fh, 84h, 6Dh, 82h, 70h
		db	 6Ch, 69h, 83h, 73h, 68h, 20h
		db	 82h, 74h, 68h, 69h, 83h, 73h
		db	 20h, 83h, 71h, 75h, 81h, 65h
		db	 83h, 73h, 74h, 2Eh, 20h, 20h
		db	0F5h, 80h, 42h, 75h, 83h, 74h
		db	 20h, 82h, 74h, 68h, 69h, 83h
		db	 73h, 20h, 80h, 77h, 61h, 83h
		db	 73h, 20h, 6Fh, 84h, 6Eh, 82h
		db	 6Ch, 79h, 20h, 81h, 74h, 68h
		db	 65h, 20h, 82h, 62h, 65h, 67h
		db	 69h, 6Eh, 84h, 6Eh, 69h, 6Eh
		db	 83h, 67h, 2Eh, 20h, 20h, 84h
		db	0F5h, 83h, 59h, 6Fh, 75h, 80h
		db	 72h, 20h, 81h, 6Eh, 65h, 83h
		db	 78h, 74h, 20h, 82h, 6Dh, 69h
		db	 83h, 73h, 73h, 82h, 69h, 6Fh
		db	 84h, 6Eh, 20h, 80h, 61h, 77h
		db	 61h, 82h, 69h, 83h, 74h, 73h
		db	 20h, 83h, 79h, 6Fh, 75h, 20h
		db	 82h, 69h, 84h, 6Eh, 20h, 80h
		db	 61h, 20h, 82h, 6Eh, 65h, 83h
		db	 77h, 20h, 80h, 6Ch, 61h, 84h
		db	 6Eh, 64h, 2Eh, 22h,0F5h,0F5h
		db	0F5h,0FEh,0F7h,0EFh, 22h, 90h
		db	 4Dh, 92h, 79h, 20h, 91h, 6Eh
		db	 65h, 93h, 78h, 74h, 20h, 92h
		db	 6Dh, 69h, 93h, 73h, 73h, 69h
		db	 6Fh, 94h, 6Eh, 3Fh, 22h, 97h
		db	 20h, 98h, 20h, 97h, 20h, 96h
		db	0F5h,0F3h,0ECh, 22h, 81h, 54h
		db	 68h, 65h, 80h, 72h, 65h, 20h
		db	 80h, 61h, 72h, 65h, 20h, 81h
		db	 6Dh, 61h, 84h, 6Eh, 79h, 20h
		db	 83h, 77h, 68h, 6Fh, 20h, 81h
		db	 68h, 61h, 83h, 76h, 65h, 20h
		db	 82h, 6Eh, 65h, 65h, 83h, 64h
		db	 20h, 6Fh, 66h, 84h, 20h, 83h
		db	 79h, 6Fh, 80h, 75h, 72h, 20h
		db	 83h, 73h, 81h, 70h, 65h, 82h
		db	 63h, 69h, 80h, 61h, 83h, 6Ch
		db	 20h, 80h, 74h, 61h, 81h, 6Ch
		db	 65h, 84h, 6Eh, 82h, 74h, 73h
		db	 2Eh, 20h, 20h, 84h,0F5h, 83h
		db	 46h, 6Fh, 6Ch, 6Ch, 6Fh, 77h
		db	 20h, 82h, 6Dh, 65h, 20h, 80h
		db	 61h, 84h, 6Eh, 64h, 20h, 80h
		db	 49h, 20h, 83h, 77h, 82h, 69h
		db	 6Ch, 6Ch, 20h, 83h, 73h, 68h
		db	 6Fh, 77h, 81h, 20h, 85h, 79h
		db	 6Fh, 75h, 20h, 81h, 74h, 68h
		db	 65h, 20h, 83h, 77h, 80h, 61h
		db	 82h, 79h, 2Eh, 84h, 20h,0F5h
		db	 83h, 57h, 82h, 65h, 20h, 80h
		db	 6Dh, 75h, 83h, 73h, 74h, 20h
		db	 81h, 64h, 65h, 80h, 70h, 61h
		db	 72h, 83h, 74h, 20h, 85h, 71h
		db	 75h, 82h, 69h, 63h, 83h, 6Bh
		db	 82h, 6Ch, 79h, 2Eh, 22h, 84h
		db	0F5h,0F5h,0F5h,0FEh,0F0h,0F3h
		db	0FAh
		db	'There was no time to rest, '
		db	 97h, 61h, 6Eh, 98h
		db	'd no time t'
		db	'o stay in this peaceful land.'
		db	0F5h,0F5h,0F5h,0FDh,0FEh,0F3h
		db	0FBh,0EBh, 97h, 22h, 96h,0B0h
		db	 4Dh, 75h,0B3h, 73h,0B4h, 74h
		db	 20h, 79h, 6Fh, 75h, 20h,0B2h
		db	 6Ch, 65h,0B1h, 61h,0B3h, 76h
		db	 65h,0B4h, 20h,0B3h, 73h, 6Fh
		db	 20h,0B5h, 73h, 6Fh, 6Fh,0B4h
		db	 6Eh, 2Ch, 20h,0B7h,0B3h, 44h
		db	0B8h, 75h,0B1h,0B7h, 6Bh,0B6h
		db	 65h, 20h,0B0h, 47h, 61h, 72h
		db	 6Ch, 61h,0B4h, 6Eh, 64h, 3Fh
		db	 20h, 20h,0F5h,0F2h,0B7h,0B0h
		db	 49h,0B8h, 20h,0B7h,0B5h, 77h
		db	0B6h,0B0h, 61h, 73h, 20h,0B3h
		db	 68h, 6Fh, 70h,0B2h, 69h,0B4h
		db	 6Eh,0B3h, 67h, 2Eh, 2Eh, 2Eh
		db	0B4h, 22h,0F5h,0F5h,0F5h,0FEh
		db	0F7h,0EFh, 22h, 95h, 50h, 72h
		db	 92h, 69h, 94h, 6Eh, 91h, 63h
		db	 65h, 93h, 73h, 73h, 20h, 91h
		db	 46h, 65h, 92h, 6Ch, 69h, 63h
		db	 69h, 90h, 61h, 2Ch, 20h, 97h
		db	 90h, 49h, 98h, 92h, 20h, 97h
		db	 90h, 6Dh, 96h, 75h, 93h, 73h
		db	 74h, 20h, 92h, 62h, 69h, 93h
		db	 64h, 20h, 93h, 79h, 6Fh, 75h
		db	 20h, 91h, 66h, 61h, 90h, 72h
		db	 65h, 91h, 77h, 65h, 93h, 6Ch
		db	 6Ch, 2Eh, 94h, 20h, 20h,0F5h
		db	 93h, 4Dh, 6Fh, 72h, 94h, 6Eh
		db	 69h, 6Eh, 95h, 67h, 20h, 92h
		db	 69h, 95h, 73h, 20h, 90h, 63h
		db	 6Fh, 6Dh, 92h, 69h, 94h, 6Eh
		db	 67h, 20h, 93h, 73h, 6Fh, 6Fh
		db	 94h, 6Eh, 2Ch, 20h, 90h, 61h
		db	 94h, 6Eh, 64h, 20h, 90h, 49h
		db	 92h, 20h, 97h, 92h, 77h, 98h
		db	 69h, 93h, 97h, 6Ch, 96h, 6Ch
		db	 20h, 92h, 6Dh, 69h, 93h, 73h
		db	 73h, 20h, 91h, 74h, 68h, 65h
		db	 20h, 90h, 6Ch, 91h, 69h, 67h
		db	 93h, 68h, 74h, 20h, 6Fh, 95h
		db	 66h, 20h, 93h, 53h, 92h, 70h
		db	 69h, 72h, 69h, 93h, 74h, 20h
		db	 75h, 94h, 6Eh, 91h, 6Ch, 65h
		db	 93h, 73h, 73h, 20h, 90h, 49h
		db	 92h, 20h, 73h, 90h, 74h, 61h
		db	 72h, 94h, 74h, 20h, 91h, 62h
		db	 65h, 93h, 66h, 6Fh, 90h, 72h
		db	 65h, 20h, 91h, 74h, 68h, 65h
		db	 20h, 90h, 64h, 61h, 94h, 77h
		db	 6Eh, 2Eh, 22h,0F5h,0F5h,0F5h
		db	0FEh,0F0h,0F3h,0FAh
		db	'Th'
		db	'e Duke answered quickly, as if t'
		db	'o head off the'
		db	' next words of Princess Felicia.'
		db	0F5h,0F5h,0F5h,0FDh,0FEh,0F3h
		db	0FAh
		db	'For if he heard those words, he '
		db	'might not be able to leave, as h'
		db	'e knew '
		db	'he must.  '
		db	0F5h
		db	'He turned and walked away...'
		db	0F5h,0F5h,0F5h,0FEh,0F7h,0FBh
		db	0EBh, 22h,0C0h, 44h, 6Fh,0C1h
		db	 6Eh, 27h, 74h, 20h,0C0h, 67h
		db	 6Fh, 2Ch, 20h,0C1h, 44h, 75h
		db	0C0h, 6Bh, 65h, 20h,0C0h, 47h
		db	 61h, 72h,0C1h, 6Ch, 61h, 6Eh
		db	0C0h, 64h, 21h, 22h,0F5h,0F0h
		db	0F3h,0FAh
		db	'... and did not look back.'
		db	0F5h,0FDh,0F2h
		db	'Duke Garlan'
		db	'd lef'
		db	't t'
		db	'he castle, and he felt as if his'
		db	' heart might break.'
		db	0F5h,0F5h,0F5h,0FEh,0F7h
		db	 41h, 73h, 20h, 73h
		db	'he watched him go, Princess Feli'
		db	'cia said to herself, '
		db	0F5h,0F2h,0FBh
		db	'"He will return.  '
		db	0F5h
		db	'The road to his destiny, began h'
		db	'ere, and it shall end here."'
		db	0F5h,0F5h,0F5h,0FEh,0F3h
		db	'"When his work in the world is d'
		db	'one, he', 27h, 'l'
		db	'l come back to me.  '
		db	0F5h
		db	'Until then, I can only believe i'
		db	't, and wait for him."'
		db	0F5h,0F5h,0F5h,0F5h,0F5h,0FDh
		db	0FFh, 77h, 00h, 77h, 77h, 70h
		db	 5Dh,0DDh,0DDh,0DDh,0DCh, 3Fh
		db	0E0h, 94h, 77h, 70h, 1Dh,0D9h
		db	0E3h,0DDh,0C0h, 07h, 75h, 07h
		db	 77h, 00h, 01h,0DCh, 1Dh,0DCh
		db	 00h, 80h, 77h, 77h, 70h, 04h
		db	 88h, 1Dh,0DDh, 80h, 08h,0B2h
		db	 03h, 70h, 00h, 74h,0FCh, 00h
		db	 00h, 00h,0D8h,0D6h, 00h, 00h
		db	 07h, 74h,0FFh,0E0h, 7Fh,0FFh
		db	0F1h, 7Fh,0FFh,0FFh,0FFh,0FCh
		db	 3Fh,0F9h,0F7h,0FFh,0F8h, 9Fh
		db	0F9h,0EFh,0FFh,0E0h,0C7h,0FFh
		db	0FFh,0FFh, 84h,0F1h,0FEh, 1Fh
		db	0FEh, 0Ch,0FCh, 7Fh,0FFh,0F0h
		db	 1Ch,0FFh, 1Fh,0FFh, 80h, 7Ch
		db	0FFh, 03h,0F8h, 01h,0FCh,0FFh
		db	 30h, 00h, 07h,0FCh,0FFh, 30h
		db	 00h, 1Fh,0FCh,0FFh,0A0h, 7Fh
		db	0FFh,0F1h, 7Fh,0FFh,0FFh,0FFh
		db	0FCh, 3Fh,0F0h, 83h,0FFh,0F8h
		db	 9Fh,0E1h,0E0h,0FFh,0E0h,0C7h
		db	0F9h, 03h,0FFh, 84h,0F1h,0FEh
		db	 1Fh,0FEh, 08h,0F4h, 7Fh,0FFh
		db	0F0h, 14h,0FDh, 1Fh,0FFh, 80h
		db	 28h,0F7h, 03h,0F8h, 01h, 74h
		db	0FDh, 20h, 00h, 02h,0F8h,0F7h
		db	 20h, 00h, 17h,0FCh, 77h, 00h
		db	 77h, 77h, 70h, 5Dh,0DDh,0DDh
		db	0DDh,0DCh, 3Fh,0FFh,0FCh, 77h
		db	 70h, 1Dh,0D9h,0C3h,0DDh,0C0h
		db	 07h, 77h,0FFh, 77h, 00h, 01h
		db	0DCh, 1Dh,0DCh, 00h, 80h, 77h
		db	 77h, 70h, 04h, 88h, 1Dh,0DDh
		db	 80h, 08h,0B2h, 03h, 70h, 00h
		db	 74h,0FCh, 00h, 00h, 00h,0D8h
		db	0D6h, 00h, 00h, 07h, 74h,0FFh
		db	0E0h, 7Fh,0FFh,0F1h, 7Fh,0FFh
		db	0FFh,0FFh,0FCh, 3Fh,0FFh,0FFh
		db	0FFh,0F8h, 9Fh,0F9h,0EFh,0FFh
		db	0E0h,0C7h,0FFh,0FFh,0FFh, 84h
		db	0F1h,0FEh, 1Fh,0FEh, 0Ch,0FCh
		db	 7Fh,0FFh,0F0h, 1Ch,0FFh, 1Fh
		db	0FFh, 80h, 7Ch,0FFh, 03h,0F8h
		db	 01h,0FCh,0FFh, 30h, 00h, 07h
		db	0FCh,0FFh, 30h, 00h, 1Fh,0FCh
		db	0FFh,0A0h, 7Fh,0FFh,0F1h, 7Fh
		db	0FFh,0FFh,0FFh,0FCh, 3Fh,0FFh
		db	0FFh,0FFh,0F8h, 9Fh,0E1h,0C0h
		db	0FFh,0E0h,0C7h,0FFh, 87h,0FFh
		db	 84h,0F1h,0FEh, 1Fh,0FEh, 08h
		db	0F4h, 7Fh,0FFh,0F0h, 14h,0FDh
		db	 1Fh,0FFh, 80h, 28h,0F7h, 03h
		db	0F8h, 01h, 74h,0FDh, 20h, 00h
		db	 02h,0F8h,0F7h, 20h, 00h, 17h
		db	0FCh, 77h, 00h, 77h, 77h, 70h
		db	 5Dh,0DDh,0DDh,0DDh,0DCh, 37h
		db	0E0h, 94h, 77h, 70h, 1Dh,0D1h
		db	0E3h,0DDh,0D0h, 07h, 70h, 03h
		db	 77h, 40h, 05h,0DDh, 0Dh,0DDh
		db	 00h, 81h, 76h, 17h, 74h, 04h
		db	 88h, 5Dh,0DDh,0D0h, 08h,0B2h
		db	 17h, 77h, 00h, 74h,0FCh, 01h
		db	0D8h, 00h,0D8h,0D6h, 00h, 00h
		db	 07h, 74h,0FFh,0E0h, 7Fh,0FFh
		db	0F1h, 7Fh,0FFh,0FFh,0FFh,0FCh
		db	 3Fh,0F9h,0F7h,0FFh,0F8h, 9Fh
		db	0F9h,0E3h,0FFh,0F0h,0CFh,0FEh
		db	 0Fh,0FFh,0C4h,0E7h,0FFh,0FFh
		db	0FFh, 0Ch,0F9h,0FFh, 1Fh,0FCh
		db	 1Ch,0FEh, 7Fh,0FFh,0F0h, 7Ch
		db	0FFh, 1Fh,0FFh, 81h,0FCh,0FFh
		db	 23h,0F8h, 07h,0FCh,0FFh, 30h
		db	 00h, 1Fh,0FCh,0FFh,0A0h, 7Fh
		db	0FFh,0F1h, 7Fh,0FFh,0FFh,0FFh
		db	0FCh, 3Fh,0F0h, 83h,0FFh,0F8h
		db	 9Fh,0E1h,0E0h,0FFh,0F0h,0CFh
		db	0F8h, 01h,0FFh,0C4h,0E7h,0FDh
		db	 07h,0FFh, 08h,0F1h,0FFh, 0Fh
		db	0FCh, 14h,0FCh, 7Fh,0FFh,0F0h
		db	 28h,0F7h, 1Fh,0FFh, 81h, 74h
		db	0FDh, 23h,0F8h, 02h,0F8h,0F7h
		db	 20h, 00h, 17h,0FCh, 20h, 00h
		db	 70h, 00h, 00h, 03h, 02h, 88h
		db	 00h, 0Dh,0D8h, 00h, 01h,0C0h
		db	 02h, 00h, 07h, 77h, 19h, 81h
		db	 40h, 00h, 26h, 05h,0DDh,0FCh
		db	0A9h, 80h, 00h, 75h, 03h, 77h
		db	 7Fh, 77h, 00h, 00h, 3Fh, 03h
		db	0DDh,0D4h, 5Dh,0C0h, 03h, 6Ah
		db	 03h, 77h,0FFh, 77h, 08h, 01h
		db	0FDh, 03h,0DFh,0FDh,0C5h, 18h
		db	0F1h, 78h, 78h, 27h,0E0h, 1Fh
		db	 1Fh,0F8h, 03h,0BFh,0FFh, 80h
		db	 07h,0C0h, 1Eh, 00h,0F7h,0FFh
		db	 11h, 81h,0CCh, 00h, 06h, 7Fh
		db	0FFh,0F0h, 23h, 90h, 27h, 41h
		db	 7Bh,0FFh,0F8h, 17h, 82h, 23h
		db	0B0h, 73h,0FFh,0F4h, 5Fh,0CEh
		db	 23h,0EAh,0F3h,0FFh,0FFh,0FFh
		db	 8Eh, 63h,0FFh,0E3h,0FFh,0FFh
		db	0E7h, 1Ch, 71h, 50h, 78h, 22h
		db	0A0h, 0Bh, 17h,0D8h, 02h,0AFh
		db	0FDh, 00h, 07h,0C0h, 16h, 00h
		db	 57h,0FFh, 11h, 81h,0CCh, 00h
		db	 06h, 2Fh,0FFh,0F0h, 23h, 90h
		db	 25h, 41h, 53h,0FFh,0F8h, 17h
		db	 82h, 22h,0B0h, 63h,0FFh,0F4h
		db	 5Fh,0CEh, 23h,0EAh,0D3h,0FFh
		db	0FFh,0FFh, 8Eh, 63h,0FFh,0A3h
		db	0FFh,0FFh,0E7h, 1Ch, 20h, 00h
		db	 70h, 00h, 00h, 03h, 02h, 88h
		db	 00h, 0Dh,0D8h, 00h, 01h,0C0h
		db	 02h, 00h, 07h, 77h, 00h, 01h
		db	 40h, 00h, 00h, 05h,0DDh,0FCh
		db	 29h, 80h, 00h, 61h, 03h, 77h
		db	 7Fh, 77h, 00h, 00h, 3Fh, 03h
		db	0DDh,0D4h, 5Dh,0C0h, 03h, 6Ah
		db	 03h, 77h,0FFh, 77h, 08h, 01h
		db	0FDh, 03h,0DFh,0FDh,0C5h, 18h
		db	0F1h, 78h, 78h, 27h,0FFh,0FFh
		db	 1Fh,0F8h, 5Bh,0BFh,0FFh,0F4h
		db	 07h,0C0h, 1Eh, 26h,0F7h,0FFh
		db	 40h, 01h,0CCh, 00h, 00h, 7Fh
		db	0FFh,0F0h, 23h, 90h, 27h, 41h
		db	 7Bh,0FFh,0F8h, 17h, 82h, 23h
		db	0B0h, 73h,0FFh,0F4h, 5Fh,0CEh
		db	 23h,0EAh,0F3h,0FFh,0FFh,0FFh
		db	 8Eh, 63h,0FFh,0E3h,0FFh,0FFh
		db	0E7h, 1Ch, 71h, 50h, 78h, 22h
		db	0A0h, 0Bh, 17h,0D8h, 02h,0AFh
		db	0FDh, 00h, 07h,0C0h, 16h, 00h
		db	 57h,0FFh, 00h, 01h,0CCh, 00h
		db	 00h, 2Fh,0FFh,0F0h, 23h, 90h
		db	 25h, 41h, 53h,0FFh,0F8h, 17h
		db	 82h, 22h,0B0h, 63h,0FFh,0F4h
		db	 5Fh,0CEh, 23h,0EAh,0D3h,0FFh
		db	0FFh,0FFh, 8Eh, 63h,0FFh,0A3h
		db	0FFh,0FFh,0E7h, 1Ch, 20h, 00h
		db	 70h, 00h, 00h, 02h, 02h, 88h
		db	 00h, 0Dh,0D8h, 00h, 01h, 40h
		db	 02h, 00h, 07h, 77h, 00h, 01h
		db	 40h, 00h, 00h, 05h,0DDh, 80h
		db	 01h, 80h, 00h, 00h, 03h, 77h
		db	 40h, 03h, 00h, 00h, 00h, 03h
		db	0DDh,0D0h, 0Dh,0C0h, 03h, 40h
		db	 03h, 77h,0FFh, 77h, 08h, 01h
		db	0FDh, 03h,0DFh,0FDh,0C5h, 18h
		db	0F1h, 78h, 78h, 27h,0E7h, 5Fh
		db	 1Fh,0F9h,0EFh,0BFh,0FFh, 3Fh
		db	0F7h,0C0h, 1Eh,0BFh,0F7h,0FFh
		db	0FFh,0FFh,0CCh, 00h, 7Fh,0FFh
		db	0FFh, 9Fh,0E1h, 90h, 27h, 3Fh
		db	 7Bh,0FFh,0C0h, 03h, 82h, 23h
		db	 00h, 73h,0FFh,0F0h, 0Fh,0CEh
		db	 23h,0C0h,0F3h,0FFh,0FFh,0FFh
		db	 8Eh, 63h,0FFh,0E3h,0FFh,0FFh
		db	0E7h, 1Ch, 71h, 50h, 78h, 22h
		db	0A2h, 0Ah, 17h,0D8h,0AAh,0AFh
		db	0FDh, 1Dh, 23h, 40h, 16h, 18h
		db	 57h,0FFh,0BAh, 41h,0CCh, 00h
		db	 30h, 2Fh,0FFh, 94h, 01h, 90h
		db	 25h, 00h, 13h,0FFh,0C0h, 03h
		db	 82h, 22h, 00h, 63h,0FFh,0F0h
		db	 0Fh,0CEh, 23h,0C0h,0D3h,0FFh
		db	0FFh,0FFh, 8Eh, 63h,0FFh,0A3h
		db	0FFh,0FFh,0E7h, 1Ch,0AAh,0AAh
		db	 5Fh, 55h,0B1h,0AAh, 56h, 54h
		db	 0Ah,0A0h, 05h, 00h, 80h, 00h
		db	 40h, 00h,0FFh,0FFh,0FFh,0FFh
		db	0F9h,0FFh, 7Fh,0FEh, 1Fh,0F0h
		db	 8Fh, 83h,0C0h, 07h,0C0h, 1Eh
		db	0FFh,0FFh,0E6h,0FFh,0E0h, 7Fh
		db	 79h,0FCh, 1Fh,0F0h, 8Fh, 80h
		db	0C0h, 05h,0C0h, 0Ah,0AAh,0AAh
		db	 55h,0D5h,0A0h, 2Ah, 56h, 54h
		db	 0Ah,0A0h, 05h, 00h, 80h, 00h
		db	 40h, 00h,0FFh,0FFh,0FFh,0FFh
		db	0FFh,0FFh, 7Fh,0FEh, 1Fh,0F0h
		db	 8Fh, 83h,0C0h, 07h,0C0h, 1Eh
		db	0FFh,0FFh,0E4h, 7Fh,0FFh,0FFh
		db	 79h,0FCh, 1Fh,0F0h, 8Fh, 80h
		db	0C0h, 05h,0C0h, 0Ah,0FEh,0F7h
		db	0F8h, 00h, 04h,0FEh,0FCh,0FBh
		db	 01h, 11h,0FAh, 00h, 53h, 54h
		db	 41h, 46h, 46h,0F9h,0FCh,0F8h
		db	 20h, 01h,0F9h,0FCh,0FAh, 07h
		db	0F8h, 25h, 05h,0FDh
		db	9, 'PRODUCER - JAPANESE VERSION'
		db	0FDh
		db	9, 9, 9, 9, '   Mitsuhiro Mazda'
		db	0F9h,0FCh,0FDh
		db	9, 'PRODUCER - ENGLISH VERSION'
		db	0FDh
		db	9, 9, 9, 9, '     Josh Mandel'
		db	0F9h,0FCh,0FDh
		db	9, 'LEAD PROGRAMMER'
		db	0FDh
		db	9, 9, 9, 9, 9, 'Tomoyuki Shimada'
		db	0F9h,0FCh,0FDh
		db	9, 'GRAPHIC DESIGNERS'
		db	0FDh
		db	9, 9, 9, 9, 9, 'Akihiko Yoshida'
		db	0FDh
		db	9, 9, 9, 9, 9, 'Masatoshi Azumi'
		db	0F9h,0FCh,0FDh
		db	9, 'ENGLISH TEXT TRANSLATION'
		db	0FDh
		db	9, 9, 9, 9, 9, ' Marti McKenna'
		db	0F9h,0FCh
		db	9, 'MUSIC COMPOSERS'
		db	0FDh
		db	9, 9, 9, 9, '-- MECANO ASSOCIATES'
		db	' --'
		db	0FDh
		db	9, 9, 9, 9, '   Fumihito Kasatani'
		db	0FDh
		db	9, 9, 9, 9, '   Nobuyuki Aoshima'
		db	0F9h,0FCh,0FDh
		db	9, 'STORY MAKER'
		db	0FDh
		db	9, 9, 9, 9, 9, 'Masaru Takeuchi'
		db	0F9h,0FCh,0FDh
		db	9, 'SOUND EFFECTS'
		db	0FDh
		db	9, 9, 9, 9, 9, 'Tomoyuki Shimada'
		db	0F9h,0F8h, 00h, 03h,0FCh,0FEh
		db	0F7h,0FEh,0FBh, 01h, 0Dh,0FAh
		db	 00h
		db	'SPECIAL THANKS'
		db	0F9h,0FCh,0F8h, 20h, 01h,0F9h
		db	0FCh,0FAh, 07h,0F8h, 00h, 07h
		db	0FDh
		db	9, 'Toshiyuki Uchida', 9, 'Yuzo S'
		db	'unaga'
		db	0FDh
		db	9, 'Takeshi Miyaji', 9, 9, 'Naozu'
		db	'mi Honma'
		db	0FDh
		db	9, 'Ray E'
		db	'. Nakazato', 9, 9, 'Toshi Masubu'
		db	'chi'
		db	0F9h,0FCh,0FDh
		db	9, 'Hiroyuki Koyama', 9, 9, 'Sato'
		db	'shi Uesaka'
		db	0FDh
		db	'   '
		db	'  -- Si'
		db	'erra On-Line Japan, Inc. --'
		db	0FDh
		db	9, 9, 9, ' Eiji (Ed) Nagano'
		db	0F9h,0FCh
		db	9, 'ADVISERS'
		db	0FDh
		db	9, 9, 9, 9, 9, '  Osamu Harada'
		db	0FDh
		db	9, 9, 9, 9, 9, '  Hiromi Ohba'
		db	0FDh
		db	9, 9, 9, 9, 9, '  Greg Miyaji'
		db	0F9h,0FCh,0F8h, 80h, 05h,0FDh
		db	9, 'SYSTEM DESIGNER'
		db	0FDh
		db	9, 9, 9, 9, 9, 'Rocky Cave Maker'
		db	0F9h,0F8h, 20h, 01h,0FCh,0F9h
		db	0F8h, 00h, 03h,0FCh,0FBh, 01h
		db	 0Ch,0FAh, 00h
		db	'SERVING MONSTERS'
		db	0F9h,0FCh,0F8h, 20h, 01h,0F9h
		db	0FCh,0FAh, 07h,0F8h, 40h, 01h
		db	9, 'Cavern of Maricia', 9, 9, 'CA'
		db	'NGREJO'
		db	0F9h,0FDh
		db	9, 9, 'Peligro', 9, 9, 9, 9, 'PUL'
		db	'PO'
		db	0F9h,0FDh
		db	9, 9, 'Riza', 9, 9, 9, 9, 'POLLO'
		db	0F9h,0F9h,0FCh
		db	9, 'Cavern of Glacial', 9, 9, 'AG'
		db	'ER'
		db	0F9h,0FDh
		db	9, 9, 'Cementar', 9, 9, 9, 'VISTA'
		db	0F9h,0FDh
		db	9, 9, 'Tesoro', 9, 9, 9, 9, 'TARS'
		db	'O'
		db	0F9h,0F9h,0FCh
		db	9, 9, 'Llama Town', 9, 9, 9, 'PAG'
		db	'URO'
		db	0F9h,0FDh
		db	9, 'Cavern of Caliente', 9, 9, 'D'
		db	'RAGON'
		db	0F9h,0FDh
		db	9, 9, 'Absor', 9, 9, 9, 9, 'ALGUI'
		db	'EN'
		db	0F9h,0F9h,0FCh,0FAh, 00h,0FEh
		db	9, 'Copyright (C)1987,19'
		db	'90 GAME ARTS'
		db	0FDh
		db	9, 'Copyright ('
		db	'C)1990 Sierra On-Line'
		db	0FDh
		db	'  This edition first publ'
		db	'ished 1987 by'
		db	0FDh
		db	'  GAME ARTS Co.,Ltd./ Tomoyuki S'
		db	'himada'
		db	0FEh,0F7h,0FEh,0FFh, 00h, 00h
		db	 00h, 00h, 00h, 00h, 01h, 02h
		db	 03h, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 05h, 06h, 07h, 08h
		db	 09h, 0Ah, 0Bh, 0Ch, 0Dh, 0Eh
		db	 0Fh, 10h, 11h, 12h, 13h, 14h
		db	 15h, 16h, 00h, 00h, 00h, 17h
		db	 18h, 19h, 1Ah, 1Bh, 1Ch, 1Dh
		db	 1Eh, 1Fh
		db	' !"#$'
		db	'%&', 27h, '()*+,-.'
		db	 00h, 00h, 2Fh, 30h, 31h, 32h
		db	 33h, 00h, 00h, 34h, 35h, 36h
		db	 37h, 38h, 00h, 39h, 26h, 3Ah
		db	 00h
		db	18 dup (0)
		db	 3Bh, 3Ch, 3Dh, 00h, 00h, 00h
		db	 3Eh, 3Fh, 40h, 41h
		db	30 dup (0)
		db	 42h, 43h, 44h, 45h
		db	30 dup (0)
		db	 46h, 47h, 16h
		db	31 dup (0)
		db	 48h, 49h, 4Ah
		db	97 dup (0)
		db	 4Bh, 4Ch, 4Dh
		db	31 dup (0)
		db	 4Eh, 4Fh, 50h
		db	32 dup (0)
		db	51h
		db	33 dup (0)
		db	 52h, 53h
		db	32 dup (0)
		db	 54h, 55h, 56h
		db	31 dup (0)
		db	 57h, 58h, 59h, 5Ah
		db	30 dup (0)
		db	 5Bh, 5Ch, 5Dh, 5Eh
		db	30 dup (0)
		db	 5Fh, 60h, 61h, 62h
		db	30 dup (0)
		db	 63h, 64h
		db	32 dup (0)
		db	 65h, 66h, 67h, 68h, 69h
		db	29 dup (0)
		db	'jklmnopqrs'
		db	24 dup (0)
		db	'tuvwxyz{|}'
		db	24 dup (0)
		db	 7Eh, 7Fh, 80h, 81h, 82h, 83h
		db	 84h, 85h, 86h, 87h
data_62		dw	8988h
		db	 00h, 00h, 00h, 00h, 0Fh, 8Ah
		db	 8Bh, 8Ch, 00h
		db	13 dup (0)
		db	 2Fh, 8Dh, 8Eh, 8Fh, 90h, 91h
		db	 92h, 93h, 94h, 95h, 96h, 97h
		db	 00h, 00h, 00h, 98h, 99h, 9Ah
		db	 9Bh, 9Ch, 9Dh
		db	14 dup (0)
		db	 9Eh, 9Fh,0A0h,0A1h,0A2h,0A3h
		db	0A4h,0A5h,0A6h,0A7h,0A8h,0A9h
		db	 16h, 00h,0AAh,0ABh,0ACh,0ADh
		db	0AEh,0AFh
		db	14 dup (0)
		db	0B0h,0B1h,0B2h,0B3h,0B4h,0B5h
		db	0B6h,0B7h,0B8h, 26h, 26h,0B9h
		db	0BAh,0BBh,0BCh,0BDh,0BEh,0BFh
		db	0C0h,0C1h
		db	13 dup (0)
		db	2, 2, 3, 1, 0, 0
		db	2, 2, 3, 1, 1, 1
		db	2, 2, 0, 1, 2, 1
		db	7 dup (1)
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
		db	'!waku.grp'
		db	 00h, 00h, 1Ch, 73h, 65h, 69h
		db	 2Eh, 67h, 72h, 70h, 00h, 00h
		db	'&yuup.grp'
		db	 00h, 00h, 1Dh
		db	'seip.grp'
		db	 00h, 00h, 11h
		db	'himp.grp'
		db	 00h, 00h, 18h
		db	'new1.grp'
		db	 00h, 00h, 19h
		db	'new2.grp'
		db	 00h, 00h, 15h
		db	'ne80.grp'
		db	 00h, 00h, 16h
		db	'ne81.grp'
		db	0, 1
		db	'6end5.grp'
		db	0, 1
		db	'5end4.grp'
		db	0, 1
		db	'7end6.grp'
		db	0, 1
		db	'8end7.grp'
		db	0, 1
		db	'4en72.grp'
		db	0, 1
		db	'9fin.grp'
		db	0, 0
		db	27h, 'zend.msd'
		db	0

seg_a		ends



		end	start
