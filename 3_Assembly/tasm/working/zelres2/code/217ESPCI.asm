
PAGE  59,132

;==========================================================================
;
;  ENEMY_SPECIAL - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_59e	equ	2000h			;*
data_60e	equ	2002h			;*
data_61e	equ	2006h			;*
data_62e	equ	2008h			;*
data_63e	equ	2010h			;*
data_64e	equ	2012h			;*
data_65e	equ	2018h			;*
data_66e	equ	2022h			;*
data_67e	equ	2026h			;*
data_68e	equ	2028h			;*
data_69e	equ	202Ah			;*
data_70e	equ	2040h			;*
data_71e	equ	2044h			;*
data_72e	equ	2802h			;*
data_73e	equ	2C02h			;*
data_74e	equ	3000h			;*
data_75e	equ	3016h			;*
data_76e	equ	301Ah			;*
data_77e	equ	301Ch			;*
data_78e	equ	301Eh			;*
data_79e	equ	3020h			;*
data_80e	equ	362Ch			;*
data_81e	equ	51E8h			;*
data_82e	equ	6004h			;*
data_83e	equ	6014h			;*
data_84e	equ	6016h			;*
data_85e	equ	6018h			;*
data_86e	equ	601Ah			;*
data_87e	equ	0A0AFh			;*
data_88e	equ	0A114h			;*
data_89e	equ	0A1FDh			;*
data_90e	equ	0A1FEh			;*
data_91e	equ	0A28Ch			;*
data_92e	equ	0A2ACh			;*
data_93e	equ	0A380h			;*
data_94e	equ	0A9B6h			;*
data_95e	equ	0AA47h			;*
data_96e	equ	0AB47h			;*
data_97e	equ	0ABFDh			;*
data_98e	equ	0ABFFh			;*
data_99e	equ	0AC18h			;*
data_100e	equ	0AC39h			;*
data_101e	equ	0ACBDh			;*
data_102e	equ	0B029h			;*
data_103e	equ	0B51Eh			;*
data_104e	equ	0B5EBh			;*
data_105e	equ	0B9FFh			;*
data_106e	equ	0BB12h			;*
data_107e	equ	0BB14h			;*
data_108e	equ	0BB15h			;*
data_109e	equ	0BB17h			;*
data_110e	equ	0BB18h			;*
data_111e	equ	0BB19h			;*
data_112e	equ	0BB1Ah			;*
data_113e	equ	0BB1Bh			;*
data_114e	equ	0BB1Ch			;*
data_115e	equ	0BB1Dh			;*
data_116e	equ	0BB1Eh			;*
data_117e	equ	0BB1Fh			;*
data_118e	equ	0BB20h			;*
data_119e	equ	0BB21h			;*
data_120e	equ	0BB23h			;*
data_121e	equ	0BB24h			;*
data_122e	equ	0BB25h			;*
data_123e	equ	0BB26h			;*
data_124e	equ	0BB27h			;*
data_125e	equ	0BB2Eh			;*
data_126e	equ	0BB34h			;*
data_127e	equ	0BB36h			;*
data_128e	equ	0C006h			;*
data_129e	equ	0E000h			;*
data_130e	equ	0E801h			;*
data_131e	equ	0FF18h			;*
data_132e	equ	0FF1Ah			;*
data_133e	equ	0FF1Dh			;*
data_134e	equ	0FF1Eh			;*
data_135e	equ	0FF29h			;*
data_136e	equ	0FF2Ch			;*
data_137e	equ	0FF4Ch			;*
data_138e	equ	0FF4Eh			;*
data_139e	equ	0FF4Fh			;*
data_140e	equ	0FF50h			;*
data_141e	equ	0FF52h			;*
data_142e	equ	0FF53h			;*
data_143e	equ	0FF54h			;*
data_144e	equ	0FF56h			;*
data_145e	equ	0FF6Ah			;*
data_146e	equ	0FF6Ch			;*
data_147e	equ	0FF74h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_17		proc	far

start:
		cmp	ax,1Bh
		add	[bx],ah
		mov	al,ds:data_96e
		push	es
		mov	al,ds:data_81e
;*		add	bh,al
		db	 00h,0C7h		;  Fixup - byte match
		push	es
		adc	bh,byte ptr ss:data_21+0Ah[bp+di]	; ('ll upon the Spirits and ')
		call	special_process_loop_2
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_59e
		mov	word ptr ds:data_137e,0BA67h
		jmp	short loc_1
			                        ;* No entry point to code
		call	special_load_chunk
		mov	word ptr ds:data_106e,717h
		call	special_process_loop_2
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_59e
		call	special_func_16
		mov	ds:data_137e,si
loc_1:
		call	word ptr cs:data_82e
		cmp	al,0FFh
		je	loc_2			; Jump if equal
		call	special_func_2
		jmp	short loc_1
loc_2:
		jmp	word ptr cs:data_70e

zr2_17		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_load_chunk		proc	near
		mov	es,ds:data_136e
		mov	di,8000h
		mov	si,0ACB0h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:data_136e
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:data_71e
		pop	ds
		mov	byte ptr ds:data_138e,0
		mov	byte ptr ds:data_139e,0
		call	word ptr cs:data_60e
		call	word ptr cs:data_64e
		mov	bl,ds:data_128e
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_101e[bx]
		jmp	word ptr cs:data_63e
special_load_chunk		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_func_2		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:data_87e[bx]	;*
special_func_2		endp

			                        ;* No entry point to code
		retf				; Return far
data_9		db	0A0h
		db	 8Eh,0A1h, 14h,0A9h, 62h,0A8h
data_10		db	10h			; Data table (indexed access)
		db	0A4h,0B4h,0A2h, 20h,0A4h, 3Bh
		db	0A9h, 3Fh,0A9h, 43h,0A9h, 47h
		db	0A9h, 4Bh,0A9h, 4Fh,0A9h, 53h
		db	0A9h,0E8h,0B5h, 08h,0BBh, 22h
		db	 27h,0B9h, 2Dh, 1Ch,0B0h,0FFh
		db	 2Eh,0FFh, 16h, 00h, 20h,0C7h
		db	 06h, 54h,0FFh
		db	 25h, 27h
data_11		db	0C6h
		db	 06h, 52h,0FFh, 04h,0C6h, 06h
		db	 53h,0FFh, 04h,0B9h, 04h, 00h
		db	0BEh, 65h,0ADh, 2Eh,0FFh, 16h
		db	 0Eh, 60h,0C6h, 06h, 56h,0FFh
		db	 00h, 8Ah, 1Eh, 14h,0BBh, 2Eh
		db	0FFh, 16h, 10h, 60h, 73h, 02h
		db	 32h,0DBh
loc_3:
		mov	ds:data_107e,bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_88e[bx]	;*
		db	 1Ch,0A1h, 26h,0A1h
data_13		dw	0A157h
		db	 78h,0A1h,0E8h, 64h, 08h,0C7h
		db	 06h, 4Ch,0FFh,0EBh,0ADh,0C3h
		db	0E8h, 5Ah, 08h,0F6h, 06h, 15h
		db	0BBh,0FFh, 75h, 07h,0C7h, 06h
		db	 4Ch,0FFh, 08h,0AEh,0C3h,0F6h
		db	 06h, 16h,0BBh,0FFh, 75h, 12h
		db	0BFh,0A7h,0AEh,0F6h, 06h, 17h
		db	0BBh,0FFh, 74h, 03h,0BFh, 03h
		db	0AFh
loc_4:
		mov	ds:data_137e,di
		retn
loc_5:
		mov	word ptr ds:data_137e,0AE42h
		retn
			                        ;* No entry point to code
		call	special_func_12
		mov	bl,ds:data_128e
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_104e[bx]
		mov	ds:data_137e,si
		call	word ptr cs:data_82e
		mov	word ptr ds:data_137e,0ADBFh
		retn
loc_6:
		call	special_func_12
		call	fill_buffer
		mov	word ptr ds:data_137e,0ADBFh
		jnc	loc_7			; Jump if carry=0
		retn
loc_7:
		mov	word ptr ds:data_137e,0AF7Ch
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:data_108e,0FFh
		call	special_scan_loop
		call	special_func_6
		mov	byte ptr ds:data_110e,0FFh
		mov	byte ptr ds:data_111e,0FFh
		mov	word ptr ds:data_137e,0AFDEh
loc_8:
		call	special_func_6
		call	word ptr cs:data_82e
		cmp	al,4
		je	loc_8			; Jump if equal
		mov	byte ptr ds:data_112e,0FFh
;*		call	special_func_4			;*
		db	0E8h, 43h, 00h		;  Fixup - byte match
		call	word ptr cs:data_82e
		call	special_check_state
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:data_102e[bx]
		mov	ds:data_137e,ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_scan_loop		proc	near
		mov	si,data_89e
		mov	byte ptr ds:data_111e,0FFh
		mov	byte ptr ds:data_113e,0FFh
		mov	cx,3

locloop_9:
		push	cx
		mov	byte ptr ds:data_132e,0
		lodsb				; String [si] to al
		push	si
		call	special_multiply
loc_10:
		cmp	byte ptr ds:data_132e,19h
		jb	loc_10			; Jump if below
		pop	si
		pop	cx
		loop	locloop_9		; Loop if cx > 0

		mov	byte ptr ds:data_111e,0
		retn
special_scan_loop		endp

			                        ;* No entry point to code
		add	[bx+di],al
		add	bh,ss:data_90e[bp]
		mov	byte ptr ds:data_111e,0FFh
		mov	cx,2

locloop_11:
		push	cx
		mov	byte ptr ds:data_132e,0
		mov	al,[si]
		dec	si
		push	si
		call	special_multiply
loc_12:
		cmp	byte ptr ds:data_132e,19h
		jb	loc_12			; Jump if below
		pop	si
		pop	cx
		loop	locloop_11		; Loop if cx > 0

		mov	byte ptr ds:data_111e,0
		mov	byte ptr ds:data_113e,0
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_check_state		proc	near
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[8Dh]
		cmp	bl,0Fh
		jb	loc_13			; Jump if below
		mov	bl,0Fh
loc_13:
		add	bx,bx
		add	bx,data_91e
		mov	dx,[bx]
		mov	cx,dx
		xor	ax,ax			; Zero register
		shr	cx,1			; Shift w/zeros fill
		cmp	word ptr ds:[8Eh],cx
		jae	loc_14			; Jump if above or =
		retn
loc_14:
		mov	ax,dx
		shr	cx,1			; Shift w/zeros fill
		sub	ax,cx
		mov	cx,ax
		mov	ax,1
		cmp	word ptr ds:[8Eh],cx
		jae	loc_15			; Jump if above or =
		retn
loc_15:
		mov	ax,2
		cmp	word ptr ds:[8Eh],dx
		jae	loc_16			; Jump if above or =
		retn
loc_16:
		xor	bx,bx			; Zero register
		mov	bl,ds:data_128e
		dec	bx
		add	bx,data_92e
		mov	ax,3
		mov	cl,byte ptr ds:[8Dh]
		cmp	cl,[bx]
		jae	loc_17			; Jump if above or =
		retn
loc_17:
		mov	byte ptr ds:data_109e,0FFh
		mov	ax,4
		retn
special_check_state		endp

			                        ;* No entry point to code
		xor	al,[bx+si]
		xchg	si,ax
		add	[si],ch
		add	ds:data_130e[si],sp
		add	bx,sp
		add	ax,offset loc_86
		mov	[bp+di],dl
		jo	loc_18			; Jump if overflow=1
		inc	ax
		pop	ds
		adc	[bx],ah
		cbw				; Convrt byte to word
		cmp	ah,[bx+si]
		dec	si
		inc	ax
		pushf				; Push flags
		push	ax
		retn
		db	 60h,0EAh, 03h, 06h, 09h, 0Bh
		db	 0Dh, 0Fh, 12h,0FFh,0C6h
loc_18:
		push	es
		push	ss
		mov	bx,data_105e
		or	[bx+si],al

locloop_19:
		push	cx
		call	word ptr cs:data_74e
		mov	byte ptr ds:data_132e,0
loc_20:
		cmp	byte ptr ds:data_132e,0Ah
		jb	loc_20			; Jump if below
		pop	cx
		loop	locloop_19		; Loop if cx > 0

		push	cs
		pop	es
		mov	al,byte ptr ds:[8Dh]
		cmp	al,10h
		jb	loc_23			; Jump if below
		mov	word ptr ds:data_126e,320h
		mov	cx,7
		mov	si,offset data_9
		mov	di,data_127e

locloop_21:
		lodsb				; String [si] to al
		add	al,2
		jnc	loc_22			; Jump if carry=0
		mov	al,0FFh
loc_22:
		stosb				; Store al to es:[di]
		loop	locloop_21		; Loop if cx > 0

		jmp	short loc_24
loc_23:
		mov	bl,9
		mul	bl			; ax = reg * al
		mov	si,data_93e
		add	si,ax
		mov	di,data_126e
		mov	cx,9
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
loc_24:
		mov	al,byte ptr ds:[8Dh]
		inc	al
		jnz	loc_25			; Jump if not zero
		mov	al,0FFh
loc_25:
		mov	byte ptr ds:[8Dh],al
		mov	ax,ds:data_126e
		mov	word ptr ds:[0B2h],ax
		mov	word ptr ds:[90h],ax
		call	word ptr cs:data_61e
		call	word ptr cs:data_62e
		push	cs
		pop	es
		mov	di,offset data_9
		mov	si,data_127e
		mov	cx,7
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,0ABh
		mov	si,data_127e
		mov	cx,7
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		test	byte ptr ds:[9Dh],0FFh
		jz	loc_26			; Jump if zero
		call	word ptr cs:data_65e
loc_26:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[8Dh]
		dec	bl
		cmp	bl,0Fh
		jb	loc_27			; Jump if below
		mov	bl,0Fh
loc_27:
		add	bx,bx
		mov	ax,ds:data_91e[bx]
		sub	word ptr ds:[8Eh],ax
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[8Dh]
		cmp	bl,0Fh
		jb	loc_28			; Jump if below
		mov	bl,0Fh
loc_28:
		add	bx,bx
		mov	ax,ds:data_91e[bx]
		cmp	word ptr ds:[8Eh],ax
		jb	loc_ret_29		; Jump if below
		dec	ax
		mov	word ptr ds:[8Eh],ax

loc_ret_29:
		retn
			                        ;* No entry point to code
		js	$+2			; delay for I/O
		or	al,6
		or	[bx+si],cl
		add	ax,[si]
		add	sp,data_17[bx+si]
		push	es
		or	[bx+si],cl
		add	ax,[si]
		add	cx,ax
		add	[si],cl
		push	es
		or	[bx+si],cl
		add	ax,[si]
		add	si,ax
		add	[si],cl
		push	es
		or	[bx+si],cl
		add	ax,[si]
		add	bx,[bx+si]
		add	[bx+si],dx
		push	es
		or	[bx+si],cl
		add	ax,[si]
		add	ax,[bx+si+1]
		adc	al,6
		or	[bx+si],cl
		add	ax,[si]
		add	di,[si+1]
		sbb	byte ptr ds:[808h],al
		add	ax,[si]
		add	cx,sp
		add	[si],bx
		or	al,8
		or	[bp+di],al
		add	al,3
		sbb	al,2
		and	[bp+si],dl
		or	al,8
		add	ax,[si]
		add	bx,[bx+si+2]
		and	al,18h
		adc	[bx+si],cl
		add	ax,[si]
		add	ax,ds:data_72e[bx+si]
		push	ds
		adc	al,10h
		add	ax,[si]
		add	bp,ds:data_73e[bx+si]
		and	al,18h
		sbb	[bp+di],al
		add	al,3
		rol	byte ptr [bp+si],1	; Rotate
		xor	[bp+si],ch
		sbb	al,20h			; ' '
		add	ax,[si]
		add	di,ax
		add	dh,[si]
		xor	[si],ah
		xor	[bx+di],cl
		or	byte ptr ds:[30Ch],al
		cmp	ds:data_80e,dh
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		or	al,9
		and	[bp+di],al
		cmp	al,3Ch			; '<'
		cmp	al,48h			; 'H'
		adc	ax,0C10h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_func_6		proc	near
		mov	byte ptr ds:data_132e,0
loc_30:
		call	special_func_15
		cmp	byte ptr ds:data_132e,8Ch
		jb	loc_30			; Jump if below
		retn
special_func_6		endp

			                        ;* No entry point to code
		mov	word ptr ds:data_137e,0ADBFh
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

fill_buffer		proc	near
		push	cs
		pop	es
		mov	si,0A907h
		mov	al,6
		call	word ptr cs:[10Ch]
		mov	ax,cs
		mov	es,ax
		mov	ds,ax
		mov	di,0E000h
		mov	dx,0A516h
		call	word ptr cs:data_13
		mov	bx,offset data_18+7	; ('e IndiharGo outside')
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_59e
		mov	bx,offset data_18+7	; ('e IndiharGo outside')
		mov	cx,2637h
		mov	al,0FFh
		call	word ptr cs:data_59e
		push	cs
		pop	es
		mov	di,data_124e
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		mov	byte ptr ds:data_122e,0
		mov	si,data_146e
		mov	di,data_124e
		mov	cx,8

locloop_31:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_32			; Jump if zero
		inc	byte ptr ds:data_122e
		stosb				; Store al to es:[di]
		loop	locloop_31		; Loop if cx > 0

loc_32:
		mov	al,ds:data_122e
		mov	ds:data_123e,al
		mov	bx,3Ch
		mov	cl,6Ch			; 'l'
		mov	si,0A51Ch
		call	word ptr cs:data_69e
		mov	word ptr ds:data_119e,60h
		mov	byte ptr ds:data_120e,7Eh	; '~'
		mov	word ptr ds:data_143e,3463h
		mov	word ptr ds:data_145e,0Ah
		mov	al,ds:data_129e
		cmp	al,5
		jb	loc_33			; Jump if below
		mov	al,5
loc_33:
		xor	ah,ah			; Zero register
		mov	cx,ax
		xor	al,al			; Zero register
		mov	si,0E001h
		jcxz	loc_34			; Jump if cx=0
		call	special_process_loop
loc_34:
		mov	si,0E001h
		mov	al,ds:data_129e
		mov	ds:data_142e,al
		mov	byte ptr ds:data_141e,5
		call	special_func_9
		pushf				; Push flags
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_59e
		popf				; Pop flags
		jnc	loc_35			; Jump if carry=0
		retn
loc_35:
		push	cs
		pop	es
		mov	di,data_146e
		mov	cx,8
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		cmp	byte ptr ds:data_123e,0
		stc				; Set carry flag
		jnz	loc_36			; Jump if not zero
		retn
loc_36:
		mov	si,data_124e
		mov	di,data_146e
loc_37:
		lodsb				; String [si] to al
		cmp	al,0FFh
		clc				; Clear carry flag
		jnz	loc_38			; Jump if not zero
		retn
loc_38:
		cmp	al,60h			; '`'
		clc				; Clear carry flag
		jnz	loc_39			; Jump if not zero
		retn
loc_39:
		stosb				; Store al to es:[di]
		jmp	short loc_37
fill_buffer		endp

		db	 2Ah, 2Eh, 75h, 73h, 72h, 00h
		db	'Input name:'
		db	0FFh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_process_loop		proc	near
		xor	ah,ah			; Zero register

locloop_40:
		push	cx
		push	si
		push	ax
		call	word ptr cs:data_76e
		pop	ax
		push	ax
		mov	al,ah
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		add	ax,ax
		add	ax,ax
		add	bx,ax
		add	bx,ds:data_143e
		add	bx,300h
		call	word ptr cs:data_77e
		pop	ax
		inc	al
		inc	ah
		pop	si
		pop	cx
		loop	locloop_40		; Loop if cx > 0

		retn
special_process_loop		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_func_9		proc	near
		mov	byte ptr ds:data_147e,0FFh
		mov	byte ptr ds:data_135e,0
		mov	byte ptr ds:data_135e,0
		mov	byte ptr ds:data_133e,0
		mov	byte ptr ds:data_134e,0
		mov	byte ptr ds:data_144e,0
		mov	byte ptr ds:data_121e,0
		xor	bl,bl			; Zero register
		test	byte ptr ds:data_142e,0FFh
		jz	loc_41			; Jump if zero
		call	word ptr cs:data_83e
loc_41:
		call	special_func_11
		xor	al,al			; Zero register
		call	special_func_10
loc_42:
		call	word ptr cs:data_84e
		mov	byte ptr ds:data_132e,0
		test	byte ptr ds:data_134e,0FFh
		stc				; Set carry flag
		jnz	loc_43			; Jump if not zero
		test	word ptr cs:data_131e,1
		jz	loc_44			; Jump if zero
		clc				; Clear carry flag
loc_43:
		mov	byte ptr ds:data_147e,0
		mov	byte ptr ds:data_134e,0
		retn
loc_44:
		test	byte ptr ds:data_133e,0FFh
		jz	loc_47			; Jump if zero
		push	si
		xor	bh,bh			; Zero register
		mov	bl,ds:data_144e
		add	bl,ds:data_121e
		add	bx,bx
		mov	si,[bx+si]
		push	cs
		pop	es
		mov	di,data_124e
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		mov	byte ptr ds:data_122e,0
		mov	di,data_124e
		mov	cx,8

locloop_45:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_46			; Jump if zero
		inc	byte ptr ds:data_122e
		stosb				; Store al to es:[di]
		loop	locloop_45		; Loop if cx > 0

loc_46:
		mov	al,ds:data_122e
		mov	ds:data_123e,al
		pop	si
		mov	byte ptr ds:data_133e,0
		mov	ax,ds:data_119e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	bl,ds:data_120e
		mov	cx,1010h
		xor	al,al			; Zero register
		call	word ptr cs:data_59e
		call	special_func_11
		xor	al,al			; Zero register
		call	special_func_10
		jmp	loc_42
loc_47:
		mov	cx,0A592h
		push	cx
		test	byte ptr ds:data_135e,0FFh
		jz	loc_51			; Jump if zero
		mov	al,ds:data_135e
		mov	byte ptr ds:data_135e,0
		cmp	al,0Dh
		jne	loc_48			; Jump if not equal
		retn
loc_48:
		cmp	al,8
		jne	loc_49			; Jump if not equal
		jmp	loc_71
loc_49:
		xor	bx,bx			; Zero register
		mov	bl,ds:data_122e
		cmp	byte ptr ds:data_124e[bx],60h	; '`'
		jne	loc_50			; Jump if not equal
		inc	byte ptr ds:data_123e
loc_50:
		mov	ds:data_124e[bx],al
		call	special_func_11
		mov	al,1
		jmp	loc_67
loc_51:
		int	61h			; ??INT Non-standard interrupt
		test	al,8
		jz	loc_53			; Jump if zero
		mov	al,1
		call	special_func_10
loc_52:
		int	61h			; ??INT Non-standard interrupt
		test	al,8
		jnz	loc_52			; Jump if not zero
		mov	byte ptr ds:data_135e,0
		retn
loc_53:
		test	al,4
		jz	loc_55			; Jump if zero
		mov	al,0FFh
		call	special_func_10
loc_54:
		int	61h			; ??INT Non-standard interrupt
		test	al,4
		jnz	loc_54			; Jump if not zero
		mov	byte ptr ds:data_135e,0
		retn
loc_55:
		test	byte ptr ds:data_142e,0FFh
		jnz	loc_56			; Jump if not zero
		retn
loc_56:
		and	al,3
		cmp	al,1
		jne	loc_61			; Jump if not equal
		test	byte ptr ds:data_121e,0FFh
		jz	loc_57			; Jump if zero
		mov	bl,ds:data_121e
		call	word ptr cs:data_85e
		dec	byte ptr ds:data_121e
		retn
loc_57:
		test	byte ptr ds:data_144e,0FFh
		jnz	loc_58			; Jump if not zero
		retn
loc_58:
		push	di
		push	si
		dec	byte ptr ds:data_144e
		mov	al,ds:data_144e
		add	al,ds:data_121e
		call	word ptr cs:data_76e
		mov	cx,0Ah

locloop_59:
		push	cx
		mov	bx,ds:data_143e
		add	bx,301h
		mov	al,cl
		dec	al
		mov	cl,ds:data_141e
		add	cl,cl
		mov	dl,cl
		add	cl,cl
		add	cl,cl
		add	cl,dl
		sub	cl,2
		mov	ch,ds:data_145e
		call	word ptr cs:data_78e
loc_60:
		call	word ptr cs:data_84e
		cmp	byte ptr ds:data_132e,4
		jb	loc_60			; Jump if below
		mov	byte ptr ds:data_132e,0
		pop	cx
		loop	locloop_59		; Loop if cx > 0

		pop	si
		pop	di
		retn
loc_61:
		cmp	al,2
		je	loc_62			; Jump if equal
		retn
loc_62:
		mov	al,ds:data_121e
		add	al,ds:data_144e
		inc	al
		mov	ah,ds:data_142e
		dec	ah
		cmp	ah,al
		jae	loc_63			; Jump if above or =
		retn
loc_63:
		mov	al,ds:data_141e
		dec	al
		cmp	ds:data_121e,al
		jae	loc_64			; Jump if above or =
		mov	bl,ds:data_121e
		call	word ptr cs:data_86e
		inc	byte ptr ds:data_121e
		retn
loc_64:
		push	di
		push	si
		inc	byte ptr ds:data_144e
		mov	al,ds:data_144e
		add	al,ds:data_121e
		call	word ptr cs:data_76e
		mov	cx,0Ah

locloop_65:
		push	cx
		mov	bx,ds:data_143e
		add	bx,301h
		mov	al,cl
		neg	al
		add	al,0Ah
		mov	cl,ds:data_141e
		add	cl,cl
		mov	dl,cl
		add	cl,cl
		add	cl,cl
		add	cl,dl
		sub	cl,2
		mov	ch,ds:data_145e
		call	word ptr cs:data_79e
loc_66:
		call	word ptr cs:data_84e
		cmp	byte ptr ds:data_132e,4
		jb	loc_66			; Jump if below
		mov	byte ptr ds:data_132e,0
		pop	cx
		loop	locloop_65		; Loop if cx > 0

		pop	si
		pop	di
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

special_func_10:
loc_67:
		push	si
		push	ax
		mov	ax,ds:data_119e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	al,ds:data_122e
		add	al,al
		add	bh,al
		mov	bl,ds:data_120e
		add	bl,8
		mov	cx,208h
		xor	al,al			; Zero register
		call	word ptr cs:data_59e
		pop	ax
		add	ds:data_122e,al
		test	byte ptr ds:data_122e,80h
		jz	loc_68			; Jump if zero
		mov	byte ptr ds:data_122e,0
loc_68:
		cmp	byte ptr ds:data_122e,8
		jb	loc_69			; Jump if below
		dec	byte ptr ds:data_122e
loc_69:
		mov	al,ds:data_123e
		cmp	ds:data_122e,al
		jb	loc_70			; Jump if below
		mov	ds:data_122e,al
loc_70:
		mov	bx,ds:data_119e
		mov	cl,ds:data_120e
		xor	ax,ax			; Zero register
		mov	al,ds:data_122e
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	bx,ax
		add	cl,8
		mov	ax,67Fh
		call	word ptr cs:data_66e
		pop	si
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

special_func_11:
		push	si
		mov	ax,ds:data_119e
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	bl,ds:data_120e
		mov	cx,1008h
		xor	al,al			; Zero register
		call	word ptr cs:data_59e
		mov	bx,ds:data_119e
		mov	cl,ds:data_120e
		mov	si,0BB27h
		call	word ptr cs:data_69e
		pop	si
		retn
loc_71:
		push	si
		mov	bl,ds:data_122e
		or	bl,bl			; Zero ?
		jnz	loc_72			; Jump if not zero
		inc	bl
loc_72:
		xor	bh,bh			; Zero register
		push	cs
		pop	es
		mov	si,data_124e
		add	si,bx
		mov	di,si
		dec	di
		mov	al,8
		sub	al,bl
		mov	cl,al
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		test	byte ptr ds:data_123e,0FFh
		jz	loc_73			; Jump if zero
		dec	byte ptr ds:data_123e
loc_73:
		mov	byte ptr ds:data_125e,60h	; '`'
		mov	al,0FFh
		call	special_func_10
		call	special_func_11
		pop	si
		retn
special_func_9		endp

			                        ;* No entry point to code
		push	cs
		pop	es
		mov	si,data_146e
		mov	di,data_124e
		mov	cx,8

locloop_74:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_75			; Jump if zero
		stosb				; Store al to es:[di]
		loop	locloop_74		; Loop if cx > 0

loc_75:
		mov	byte ptr es:[di],2Eh	; '.'
		mov	byte ptr es:[di+1],75h	; 'u'
		mov	byte ptr es:[di+2],73h	; 's'
		mov	byte ptr es:[di+3],72h	; 'r'
		mov	byte ptr es:[di+4],0
		mov	dx,data_124e
		mov	cx,0
		mov	ah,3Ch
		int	21h			; DOS Services  ah=function 3Ch
						;  create/truncate file @ ds:dx
		jc	loc_76			; Jump if carry Set
		push	ax
		mov	dx,0
		mov	cx,100h
		mov	bx,ax
		mov	ah,40h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		pop	ax
		pushf				; Push flags
		mov	bx,ax
		mov	ah,3Eh
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		popf				; Pop flags
		jc	loc_76			; Jump if carry Set
		retn
loc_76:
		mov	ax,849h
		mov	cx,1926h
		xor	di,di			; Zero register
		call	word ptr cs:data_67e
		mov	bx,1049h
		mov	cx,3226h
		mov	al,0FFh
		call	word ptr cs:data_59e
		mov	bx,4Ch
		mov	cl,50h			; 'P'
		mov	si,0B5ACh
		call	word ptr cs:data_69e
		mov	byte ptr ds:data_133e,0
loc_77:
		test	byte ptr ds:data_133e,0FFh
		jz	loc_77			; Jump if zero
		mov	byte ptr ds:data_133e,0
		mov	ax,849h
		mov	cx,1926h
		xor	di,di			; Zero register
		call	word ptr cs:data_68e
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:data_59e
		jmp	loc_6
		db	0, 0
		db	'STDPLY.BIN'
		db	 00h,0BBh, 2Bh, 2Fh,0B9h, 19h
		db	 0Ch,0B0h,0FFh, 2Eh,0FFh, 16h
		db	 00h, 20h,0C7h, 06h, 54h,0FFh
		db	 2Eh, 30h, 2Eh,0FFh, 16h, 08h
		db	 60h, 9Ch,0E8h, 53h, 00h, 9Dh
		db	 72h, 01h,0C3h, 33h,0C0h, 2Eh
		db	0FFh, 2Eh, 00h,0FFh,0B0h, 01h
		db	0EBh, 18h,0B0h, 02h,0EBh, 14h
		db	0B0h, 03h,0EBh, 10h,0B0h, 04h
		db	0EBh, 0Ch,0B0h, 05h,0EBh, 08h
		db	0B0h, 06h,0EBh, 04h,0B0h, 07h
		db	0EBh, 00h, 50h,0BBh, 1Ch,0AAh
		db	 32h,0C0h,0B5h, 17h, 2Eh,0FFh
		db	 16h, 04h, 20h, 58h,0A2h, 9Dh
		db	 00h, 8Ah,0D8h,0FEh,0CBh, 32h
		db	0FFh,0C6h, 87h,0BBh, 00h,0FFh
		db	0A0h, 9Dh, 00h,0BBh,0A4h, 37h
		db	 2Eh,0FFh, 16h, 1Eh, 20h, 2Eh
		db	0FFh, 26h, 18h
		db	20h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_func_12		proc	near
		mov	bx,2717h
		mov	cx,1D41h
		xor	al,al			; Zero register
		jmp	word ptr cs:data_59e
special_func_12		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_process_loop_2		proc	near
		mov	si,data_94e
		mov	bx,ds:data_106e
		mov	cx,8

locloop_78:
		push	cx
		mov	cx,0Ch

locloop_79:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_75e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_79		; Loop if cx > 0

		sub	bh,0Ch
		add	bl,8
		pop	cx
		loop	locloop_78		; Loop if cx > 0

		retn
special_process_loop_2		endp

		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h
		db	 12h, 13h, 14h, 15h, 16h, 17h
		db	 18h, 19h, 1Ah, 1Bh, 1Ch, 1Dh
		db	 1Eh, 1Fh
		db	1Bh, ' !"#$'
		db	'%', 1Bh, '&', 27h, '()', 1Bh, '+'
		db	',-./0123456789:;<=>?@ABCDEFGHIJK'
		db	'LMNOPQRSTUVWXYZ[\]'

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_multiply		proc	near
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		mov	bx,ds:data_106e
		add	bx,210h
		mov	si,ax
		add	si,data_95e
		mov	cx,4

locloop_80:
		push	cx
		mov	cx,8

locloop_81:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:data_75e
		pop	bx
		inc	bh
		pop	cx
		loop	locloop_81		; Loop if cx > 0

		sub	bh,8
		add	bl,8
		pop	cx
		loop	locloop_80		; Loop if cx > 0

		retn
special_multiply		endp

			                        ;* No entry point to code
		sbb	bl,[bp+di]
		sbb	al,1Dh
		push	ds
		pop	ds
		sbb	sp,[bx+si]
		and	ax,261Bh
		daa				; Decimal adjust
		sub	[bx+di],ch
		sbb	bp,[bp+di]
		xor	[bx+di],dh
		xor	dh,[bp+di]
		xor	al,35h			; '5'
		db	'67<=>?@ABC'
		db	 1Ah, 1Bh, 1Ch, 1Dh, 1Eh, 1Fh
		db	1Bh, ' %', 1Bh, 'q', 27h, '(t', 1Bh
		db	'+01u34v67<=>?@ABC^_'
		db	 1Ch, 1Dh, 1Eh, 1Fh
		db	'`abcdefgij0klmnop7<=>?@ABC'
		db	 1Ah, 1Bh, 1Ch, 1Dh, 1Eh
		db	'wx %', 1Bh, 'yezrs+0{|}~'
		db	 7Fh, 36h, 37h, 3Ch, 80h, 81h
		db	 3Fh, 40h, 41h, 42h, 43h, 1Ah
		db	 1Bh, 1Ch, 1Dh, 1Eh, 1Fh, 1Bh
		db	 20h, 25h, 82h, 83h, 65h, 7Ah
		db	 84h, 85h, 2Bh, 30h, 86h, 87h
		db	 7Dh, 88h, 89h
		db	'67<=>?@ABC'
		db	 1Ah, 1Bh, 1Ch, 1Dh, 1Eh, 1Fh
		db	 1Bh, 20h, 25h, 8Ah, 8Bh, 65h
		db	 66h, 8Ch, 8Dh, 2Bh, 30h, 8Eh
		db	 8Fh, 7Dh, 90h, 91h, 92h
		db	'7<=>?@ABC'
		db	 1Ah, 1Bh, 1Ch, 1Dh, 1Eh, 1Fh
		db	 1Bh, 20h, 25h, 93h, 94h, 65h
		db	 95h, 96h, 97h, 2Bh, 30h, 31h
		db	 98h, 7Dh, 88h, 99h, 9Ah
		db	'7<=>?@ABC'
		db	 1Ah, 9Bh, 9Ch, 1Dh, 1Eh, 1Fh
		db	 1Bh, 20h, 25h, 9Dh, 9Eh, 65h
		db	 95h, 9Fh, 1Bh, 2Bh, 30h,0A0h
		db	0A1h, 7Dh, 6Eh,0A2h,0A3h, 37h
		db	 3Ch, 3Dh, 3Eh, 3Fh, 40h,0A4h
		db	0A5h
		db	43h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_func_15		proc	near
		cmp	word ptr ds:data_140e,2
		jae	loc_82			; Jump if above or =
		retn
loc_82:
		mov	word ptr ds:data_140e,0
		test	byte ptr ds:data_110e,0FFh
		jz	loc_87			; Jump if zero
		test	byte ptr ds:data_112e,0FFh
		jz	loc_83			; Jump if zero
		inc	byte ptr ds:data_114e
		and	byte ptr ds:data_114e,0Fh
		cmp	byte ptr ds:data_114e,1
		jne	loc_87			; Jump if not equal
		mov	byte ptr ds:data_110e,0
		mov	byte ptr ds:data_112e,0
		mov	byte ptr ds:data_114e,0
		mov	byte ptr ds:data_115e,0
		jmp	short loc_87
loc_83:
		inc	byte ptr ds:data_118e
		cmp	byte ptr ds:data_118e,14h
		jae	loc_84			; Jump if above or =
		retn
loc_84:
		mov	byte ptr ds:data_118e,0
		inc	byte ptr ds:data_115e
		mov	bl,ds:data_115e
		dec	bl
		and	bl,7
		xor	bh,bh			; Zero register
		mov	al,ds:data_98e[bx]
		call	special_multiply
		inc	byte ptr ds:data_114e
loc_86:
		and	byte ptr ds:data_114e,0Fh
loc_87:
		test	byte ptr ds:data_111e,0FFh
		jz	loc_88			; Jump if zero
		retn
loc_88:
		inc	byte ptr ds:data_117e
		cmp	byte ptr ds:data_117e,14h
		jae	loc_89			; Jump if above or =
		retn
loc_89:
		mov	byte ptr ds:data_117e,0
		mov	bl,ds:data_116e
		not	byte ptr ds:data_116e
		and	bl,1
		xor	bh,bh			; Zero register
		mov	di,0ABFBh
		test	byte ptr ds:data_113e,0FFh
		jz	loc_90			; Jump if zero
		mov	di,data_97e
loc_90:
		mov	al,[bx+di]
		mov	bx,ds:data_106e
		add	bx,718h
		jmp	word ptr cs:data_75e
special_func_15		endp

		db	29h
data_17		dw	672Ah			; Data table (indexed access)
		db	 68h, 05h, 06h, 07h, 06h, 05h
		db	 04h, 03h, 04h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

special_func_16		proc	near
		mov	si,0AD9Dh
		mov	bl,ds:data_128e
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:data_99e[bx]	;*
special_func_16		endp

			                        ;* No entry point to code
		sub	ds:data_100e[si],ch
		dec	dx
		lodsb				; String [si] to al
		pop	bx
		lodsb				; String [si] to al
		db	 6Ch,0ACh, 7Dh,0ACh, 8Eh,0ACh
		db	 9Fh,0ACh,0F6h, 06h,0E5h, 00h
		db	 80h, 74h, 01h,0C3h,0BEh,0B8h
		db	0B1h, 80h, 0Eh,0E5h, 00h, 80h
		db	0C3h,0F6h, 06h,0E5h, 00h, 40h
		db	 74h, 01h,0C3h
loc_91:
		mov	si,0B22Dh
		or	data_11,40h		; '@'
		retn
			                        ;* No entry point to code
		test	data_11,20h		; ' '
		jz	loc_92			; Jump if zero
		retn
loc_92:
		mov	si,0B29Fh
		or	data_11,20h		; ' '
		retn
			                        ;* No entry point to code
		test	data_11,10h
		jz	loc_93			; Jump if zero
		retn
loc_93:
		mov	si,0B317h
		or	data_11,10h
		retn
			                        ;* No entry point to code
		test	data_11,8
		jz	loc_94			; Jump if zero
		retn
loc_94:
		mov	si,0B38Ch
		or	data_11,8
		retn
			                        ;* No entry point to code
		test	data_11,4
		jz	loc_95			; Jump if zero
		retn
loc_95:
		mov	si,0B400h
		or	data_11,4
		retn
			                        ;* No entry point to code
		test	data_11,2
		jz	loc_96			; Jump if zero
		retn
loc_96:
		mov	si,0B488h
		or	data_11,2
		retn
			                        ;* No entry point to code
		test	data_11,1
		jz	loc_97			; Jump if zero
		retn
loc_97:
		mov	si,data_103e
		or	data_11,1
		retn
			                        ;* No entry point to code
		add	[bp+si],bx
		dec	bx
		inc	bp
		dec	si
		dec	dx
		pop	cx
		inc	cx
		db	 2Eh, 47h, 52h, 50h, 00h,0CDh
		db	0ACh,0DFh,0ACh,0F2h,0ACh, 05h
		db	0ADh, 19h,0ADh, 2Ch,0ADh, 3Fh
		db	0ADh, 51h,0ADh, 16h,0AFh, 00h
		db	 0Eh
		db	'The Sage Marid'
		db	 15h,0AFh, 00h, 0Fh
		db	'The Sage Yasmin'
		db	 14h,0AFh, 00h, 0Fh
		db	'The Sage Hajjar'
		db	 14h,0AFh, 02h, 10h
		db	'The Sage Chiriga'
		db	 14h,0AFh, 00h, 0Fh
		db	'The Sage Hisham'
		db	 14h,0AFh, 00h, 0Fh
		db	'The Sage Maryam'
		db	 15h,0AFh, 00h, 0Eh
		db	'The Sage Saied'
		db	 14h,0AFh, 00h, 10h
data_18		db	'The Sage IndiharGo outside', 0
		db	'See Power', 0
		db	'Listen Knowledge', 0
		db	'Record Experience', 0
		db	0Ch, 'How can I help you, Brav'
		db	 65h, 20h, 4Fh, 6Eh, 65h, 3Fh
		db	 2Fh,0FFh, 00h
		db	0Ch, 'Is there anything else I ca'
		db	'n do for you?/'
		db	0FFh, 00h
		db	0Ch, 'The Spirits are with you.'
		db	 11h,0FFh,0FFh, 0Ch
data_21		db	'I shall call upon the Spirits an'
		db	'd their po'
		db	'wers..... /'
		db	0FFh, 04h,0FFh, 01h
		db	0Ch, 'I fear the spirits are no l'
		db	'onger with you. No matter how ma'
		db	'ny times I try, it comes out'
		db	' the same. '
		db	0FFh, 00h, 0Ch
		db	'You are brave, but your experien'
		db	'ce is lacking. Come back when yo'
		db	'u have accomplished more.'
		db	0FFh, 00h
		db	0Ch, 'I can no longer impart the '
		db	'power of the Spirits to you. Con'
		db	'tinue on your quest. You will so'
		db	'on find others to help you.'
		db	0FFh, 00h
		db	0Ch, 'I shall record your experie'
		db	'nces./'
		db	0FFh, 03h
		db	'Place is saved on user disk. Wil'
		db	'l you continue your quest?'
		db	0FFh, 02h,0FFh, 06h, 13h,0FFh
		db	 04h
		db	4Fh
		db	'h, Holy Spirits, purify my thoug'
		db	'hts and grant me strength. '
		db	0FFh, 04h,0FFh, 04h, 0Dh, 15h
		db	0FFh, 00h,0FFh, 00h,0FFh,0FFh
		db	 33h,0B0h, 69h,0B0h, 8Fh,0B0h
		db	0E2h,0B0h, 3Fh,0B1h
		db	59h
		db	'our experience is lacking. Perse'
		db	'vere in your quest.'
		db	0FFh, 00h
		db	'You must accumulate more experie'
		db	'nce.'
		db	0FFh, 00h
		db	'I can see the faint light of the'
		db	' Spirits in you. You must endure'
		db	' a little longer.'
		db	0FFh, 00h
		db	'The light of the Spirits is burs'
		db	'ting forth within you. '
		db	0FFh, 04h
		db	0Dh, 'Indeed, your power has grow'
		db	'n.'
		db	0FFh, 05h,0FFh, 04h,0FFh, 00h
		db	'I can no longer impart the power'
		db	' of the Spirits to you. Continue'
		db	' on your quest. You'
		db	' wi'
		db	'll so'
		db	'on find others to help you. '
		db	0FFh, 00h, 49h, 20h
		db	'am the Sage Marid./You are very '
		db	'brave to embark on such a danger'
		db	'ous journey. I&shall assist you '
		db	'i'
		db	'n your travels. '
		db	0FFh, 00h, 49h, 20h
		db	'am the Sage Yasmin./I have been '
		db	'expecting you. I&shall teach you'
		db	' the Magic Spell of Throwing '
		db	'Swords: Espada.'
		db	0FFh, 07h,0FFh, 00h
		db	'I am the Sage Hajjar./I am happy'
		db	' to see you\ve made it this far.'
		db	' I&shall teach you the'
		db	' Magic Spell of Arrows: Saeta.'
		db	0FFh, 08h,0FFh, 00h
		db	'I am the Sage Chiriga./You have '
		db	'come far, and you must be cold. '
		db	'I&shall teach you the Magic '
		db	'Spell of Fire: Fuego.'
		db	0FFh, 09h,0FFh, 00h
		db	'I am the Sage Hisham./You are do'
		db	'ing well to stand before me. I&s'
		db	'hall teach you '
		db	'the Magic '
		db	'Spell of Flame: Lanzar.'
		db	0FFh, 0Ah,0FFh, 00h
		db	'I am the Sage Maryam./You have m'
		db	'ade the Spirits proud with your '
		db	'bravery. I&shall teach you the M'
		db	'agic Spell of Falling Rocks: Ras'
		db	'car.'
		db	0FFh, 0Bh,0FFh, 00h
		db	'I am the Sage Saied./You have li'
		db	'ved through much, but your journ'
		db	'ey is not over. You must be hot.'
		db	' I&shall teach you the Magic Spe'
		db	'll of Water: Agua.'
		db	0FFh, 0Ch,0FFh, 00h
		db	'I am the Sage of All Sages, Indi'
		db	'har./Brave lad, you\ve done well'
		db	' to get this far./'
		db	0Fh
		db	'I&shall teach you the Magic Spel'
		db	'l of Lightning: Guerra.'
		db	0FFh, 0Dh,0FFh, 00h
		db	'      Disk error.', 0Dh, 'Please'
		db	' check your disk', 0Dh, '  and p'
		db	'ress spacebar.'
		db	0FFh,0FBh,0B5h, 70h,0B6h,0EBh
		db	0B6h, 6Dh,0B7h, 1Ch,0B8h,0B2h
		db	0B8h, 54h,0B9h,0AFh,0B9h
		db	0Ch, 'My master, the Sage Yasmin,'
		db	' resides in the underground town'
		db	'. She is a person you can turn t'
		db	'o if you are in need. '
		db	 11h,0FFh, 00h, 0Ch
		db	'When you leave the city, climb t'
		db	'o the plateau on the left. You\l'
		db	'l see a door that looks like the'
		db	' exit from this world. '
		db	 11h,0FFh, 00h, 0Ch
		db	'The exit from this world is very'
		db	' near the exit from the village.'
		db	' However, before you go there yo'
		db	'u must have the Hero\s Crest. '
		db	 11h,0FFh, 00h, 0Ch
		db	'This is a message from the Spiri'
		db	'ts: Bend when you walk a low roa'
		db	'd. Walk not on the steep path wi'
		db	'th the needles of ice, choose an'
		db	'other path instead. Heed well th'
		db	'ese words. '
		db	 11h,0FFh, 00h, 0Ch
		db	'You can\t defeat the demons at t'
		db	'he edge of the badlands without '
		db	'the Knight\s Sword. Until you ge'
		db	't that sword, do not open the do'
		db	'or of the demons. '
		db	 11h,0FFh, 00h, 0Ch
		db	'Once you leave this world, get t'
		db	'he Silkarn shoes made by the spi'
		db	'rits at the behest of Percel. If'
		db	' you do not get those, you canno'
		db	't travel far from this world. '
		db	 11h,0FFh, 00h, 0Ch
		db	'That world is controlled by drag'
		db	'ons. To get there, you have to o'
		db	'pen three closed doors.'
		db	 11h,0FFh, 00h, 0Ch
		db	'At the edge of this world is the'
		db	' final foe, Jashiin./To fight Ja'
		db	'shiin, you must have the Sword o'
		db	'f the Fairy Flame. And to get th'
		db	'ere, you must topple the invinci'
		db	'ble monster Alguien.'
		db	 11h,0FFh, 00h, 0Ch
		db	'While you were unconscious, the '
		db	'spirits brought you here./'
		db	0FFh, 04h,0FFh, 04h
		db	'Be careful not to exhaust yourse'
		db	'lf in battle./'
		db	0FFh, 04h
		db	'Now be on your way. '
		db	0FFh, 04h, 54h
		db	'he spirits ar'
		db	'e looking after you. '
		db	 11h,0FFh,0FFh, 00h
		db	42 dup (0)

seg_a		ends



		end	start
