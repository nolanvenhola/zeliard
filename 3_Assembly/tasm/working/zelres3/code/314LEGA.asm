
PAGE  59,132

;==========================================================================
;
;  314LEGA - Level / Map Renderer Code Module - Tarso (zelres3 chunk)
;
;  Level renderer and per-frame map update program for the Tarso area
;  (town name 'Tarso' embedded near the module trailer). Partial prior
;  cleanup introduced the placeholder name "LEVEL_RENDERER". The main
;  proc was retained by Sourcer as the generic zr3_14. Contains helper
;  routine lvrender_get_value (defined at file offset 0x03B9).
;
;  Structure:
;    - Header pointer / descriptor area (file 0x00..0x80) mis-decoded by
;      Sourcer as sbb/and x86 instructions; preserved as raw bytes
;    - Large tile/cell layout data block
;    - Per-frame scan / NPC-cell update loop
;    - Helper/sub procs and dispatch logic
;    - Trailer: 10-word handler jump-table + continuation tile data
;      + 'Tarso' town-name string fragment
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; === AUTO PLACEHOLDERS ===
; loc_20 is a code label at segment offset 0x03B9 (defined near data at lvrender_get_value)
; === END PLACEHOLDERS ===


; The following equates show data references outside the range of the program.
; Shared references across 312-319 map-program family:
;   200Ch..6038h  - game-segment dispatch callback fn ptrs
;   0C010h        - sprite attribute record base
;   0ED20h        - char/tile lookup table
;   0FF2Eh..0FF75h - per-map global state flag bytes

data_8e		equ	200Ch			;* scroll/dispatch callback
data_9e		equ	6028h			;* game-seg callback fn A (tile dispatch)
data_10e	equ	6036h			;* game-seg callback fn B (tile-at-pos)
data_11e	equ	6038h			;* game-seg callback fn C
data_12e	equ	0A3C7h			;*
data_13e	equ	0A41Bh			;*
data_14e	equ	0A41Fh			;*
data_15e	equ	0A424h			;*
data_16e	equ	0A5D8h			;*
data_17e	equ	0A5D9h			;*
data_18e	equ	0A69Bh			;*
data_19e	equ	0A6BCh			;*
data_20e	equ	0A6C8h			;*
data_21e	equ	0A744h			;*
data_22e	equ	0A7A0h			;*
data_23e	equ	0A7A2h			;*
data_24e	equ	0A7A3h			;*
data_25e	equ	0A7B6h			;*
data_26e	equ	0A7B7h			;*
data_27e	equ	0A7B8h			;*
data_28e	equ	0A7B9h			;*
data_29e	equ	0A7BBh			;*
data_30e	equ	0A7BCh			;*
data_31e	equ	0A7BDh			;*
data_32e	equ	0A7BEh			;*
data_33e	equ	0A7BFh			;*
data_34e	equ	0A7C0h			;*
data_35e	equ	0A7C1h			;*
data_36e	equ	0A7C2h			;*
data_37e	equ	0A7C3h			;*
data_38e	equ	0A7C5h			;*
data_39e	equ	0A7C6h			;*
data_40e	equ	0A7C7h			;*
data_41e	equ	0A7C8h			;*
data_42e	equ	0A7C9h			;*
data_43e	equ	0A7CBh			;*
data_44e	equ	0A7F1h			;*
data_45e	equ	0C010h			;* sprite attribute record base
data_46e	equ	0ED20h			;* char/tile lookup table
data_47e	equ	0FF2Eh			;* global state byte
data_48e	equ	0FF2Fh			;* global state byte
data_49e	equ	0FF3Ch			;* global state byte
data_50e	equ	0FF75h			;* global state byte

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_14		proc	far

; ------------------------------------------------------------------
; start: header + embedded tile/cell layout data.
; The leading "sbb/add/and" x86 decode is Sourcer mis-parsing the
; module header fields; real code entry is via dispatch from game
; DS. The 12 zero bytes below are the reserved / padding header area.
; ------------------------------------------------------------------
start:
		sbb	[bx+si],cx		; header field bytes
		add	[bx+si],al		; header field bytes
		and	sp,ss:data_22e[bp+si]	; header field bytes
		db	12 dup (0)		; reserved / padding
		db	0A0h,0A0h,0A0h,0A0h,0A0h,0A0h
		db	 50h
		db	 0Ah, 0Ah
data_3		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah	; Data table (indexed access)
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
		db	0Ah, 0Ah, '>'
		db	0A0h, 8Eh,0A0h,0DEh,0A0h, 2Eh
		db	0A1h, 7Eh,0A1h,0CEh,0A1h, 05h
		db	0A2h, 02h, 00h, 00h, 00h, 03h
		db	 02h, 00h, 00h, 04h, 00h, 02h
		db	 00h, 00h, 00h, 05h, 02h, 00h
		db	 00h, 06h, 00h, 02h, 00h, 00h
		db	 00h, 07h, 02h, 00h, 00h, 08h
		db	 00h, 02h, 00h,0ADh, 00h,0AFh
		db	 02h,0AEh, 00h,0B0h, 00h, 02h
		db	0B1h,0B2h,0B5h,0B6h, 02h,0B3h
		db	0B4h,0B7h,0B8h, 02h,0B9h,0BAh
		db	 39h, 01h, 02h, 75h,0AAh, 02h
		db	 38h, 02h, 00h, 00h, 00h, 01h
		db	 02h, 00h, 00h, 02h, 00h, 02h
		db	 00h, 00h, 00h,0BBh, 02h, 00h
		db	 00h,0BCh, 00h, 00h, 09h, 0Ah
		db	 0Bh, 0Ch, 00h, 0Dh, 0Eh, 10h
		db	 11h, 00h, 0Eh, 0Fh, 11h, 12h
data_4		db	0			; Data table (indexed access)
		db	 13h, 14h
data_5		dw	1615h			; Data table (indexed access)
		db	 00h, 17h, 18h, 19h, 1Ah, 00h
		db	 19h, 1Ah, 1Ch, 1Dh, 00h, 1Ah
		db	 1Bh, 1Dh, 1Eh, 00h, 1Fh, 13h
		db	 20h, 21h, 00h, 13h, 14h, 21h
		db	 16h, 00h, 20h, 21h, 22h, 23h
		db	 00h, 21h, 16h, 23h, 18h, 00h
		db	 24h, 1Ah, 25h, 1Dh, 00h, 1Ah
		db	 1Bh, 1Dh, 1Eh, 00h, 0Dh, 0Eh
		db	 26h, 27h, 00h, 0Fh, 00h, 28h
		; Tile index tables (Sourcer emitted mis-split strings; raw bytes from reference)
		db	29h, 00h, 2Ah, 2Bh, 2Eh, 2Fh, 00h, 2Ch, 2Dh, 30h, 31h, 00h
		db	32h, 33h, 36h, 37h, 00h, 34h, 35h, 19h, 1Ah, 00h, 36h, 37h
		db	3Ah, 3Bh, 00h, 19h, 1Ah, 1Ch, 1Dh, 00h, 1Ah, 00h, 1Dh, 1Eh
		db	00h, 0Dh, 0Eh, 3Dh, 27h, 00h, 3Ch, 3Dh, 3Eh, 3Fh, 00h, 3Fh
		db	40h, 43h, 44h, 00h, 41h, 42h, 45h, 46h, 00h, 47h, 48h, 49h
		db	00h, 00h, 4Ah, 0Eh, 4Dh, 27h, 00h, 34h, 35h, 58h, 59h, 00h
		db	4Bh, 4Ch, 4Eh, 4Fh, 00h, 50h, 51h, 00h, 44h, 00h, 58h, 59h
		db	5Ah, 5Bh, 00h, 53h, 54h, 56h, 57h, 00h, 4Eh, 4Fh, 54h, 55h
		db	00h, 00h, 00h, 52h, 53h, 00h, 0Dh, 0Eh, 5Dh, 27h, 00h, 0Eh
		db	0Fh, 27h, 28h, 00h, 61h, 2Ch, 6Ah, 6Bh, 00h, 2Ch, 69h, 6Bh
		db	6Ch, 00h, 6Bh, 6Ch
		db	 6Dh, 6Eh, 00h, 6Eh, 6Fh, 70h
		db	 71h, 00h, 70h, 71h, 5Ah, 72h
		db	 00h, 00h, 5Ch, 5Eh, 5Fh, 00h
		db	 5Ch, 5Dh, 5Fh, 60h, 00h, 62h
		db	 63h, 65h, 66h, 00h, 64h, 65h
		db	 67h, 68h, 00h, 0Dh, 0Eh, 73h
		db	 74h, 00h, 0Eh, 0Fh, 74h, 12h
		db	 00h, 76h, 77h, 7Ah, 7Bh, 00h
		db	 78h, 79h, 7Ch, 7Dh, 00h, 17h
		db	 7Ah, 19h, 1Ah, 00h, 19h, 1Ah
		db	 1Ch, 1Dh, 00h, 1Ah, 1Bh, 1Dh
		db	 1Eh, 00h, 7Eh, 7Fh, 82h, 83h
		db	 00h, 80h, 81h, 84h, 85h, 00h
		db	 19h, 1Ah,0A2h,0A3h, 00h, 1Ah
		db	 1Bh,0A3h,0A4h, 00h, 7Eh, 7Fh
		db	0A5h, 83h, 00h, 00h, 00h,0A0h
		db	0A1h, 00h, 7Eh, 7Fh,0ACh, 83h
		db	 00h, 1Ah, 1Bh, 1Dh,0ABh, 00h
		db	 19h, 1Ah,0A9h, 1Dh, 00h, 00h
		db	0A6h,0A7h,0A8h, 00h, 86h, 87h
		db	 88h, 89h, 00h, 8Bh, 8Ch, 8Eh
		db	 8Fh, 00h, 89h, 8Ah, 8Ch, 8Dh
		db	 00h, 92h, 93h, 96h, 97h, 00h
		db	 8Fh, 90h, 93h, 94h, 00h, 98h
		db	 99h, 1Ah, 9Bh, 00h, 99h, 9Ah
		db	 9Bh, 9Ch, 00h, 1Ah, 9Bh, 9Dh
		db	 9Eh, 00h, 9Bh, 9Ch, 9Eh, 9Fh
		db	 00h, 91h, 92h, 95h, 96h, 00h
		db	 17h, 98h, 19h, 1Ah, 00h, 19h
		db	 1Ah, 1Ch, 9Dh, 02h,0BDh,0BEh
		db	0BFh,0C0h, 02h,0C1h,0C2h,0C3h
		db	0C4h, 02h,0C5h,0C6h,0C7h,0C8h
		db	 02h,0C9h,0CAh,0CBh,0CCh, 02h
		db	0CDh,0CEh,0CFh,0D0h, 02h, 00h
		db	 00h,0D1h,0D2h, 8Bh, 36h, 10h
		db	0C0h,0C6h, 06h,0B6h,0A7h, 00h
		db	0C6h
loc_1:
		push	es
		mov	bh,0A7h
		add	ss:data_49e[bp+di],al
		jz	loc_5			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:data_10e
		jc	loc_4			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:data_9e
		mov	bl,ds:data_25e
		xor	bh,bh			; Zero register
		mov	al,ds:data_46e[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	loc_4			; Jump if zero
		mov	al,[si+5]
		and	al,1Fh
		mov	ds:data_26e,al
loc_4:
		inc	byte ptr ds:data_25e
		add	si,10h
;*		jmp	short loc_2		;*
		db	0EBh, 0C4h		; jmp short 235h (absolute)
loc_5:
		mov	si,ds:data_45e
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:data_26e,0FFh
		jz	loc_8			; Jump if zero
		mov	al,ds:data_26e
		push	ax
		call	word ptr cs:data_11e
		mov	bl,ah
		xor	bh,bh			; Zero register
		pop	ax
		cmp	al,9
		je	loc_7			; Jump if equal
		cmp	al,1
		jne	loc_6			; Jump if not equal
		add	bx,bx
		jmp	short loc_7
loc_6:
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
loc_7:
		call	lvrender_func_4
		mov	byte ptr ds:data_50e,2Fh	; '/'
		cmp	byte ptr ds:data_22e,2Fh	; '/'
		jae	loc_8			; Jump if above or =
		mov	byte ptr ds:data_33e,14h
		mov	byte ptr ds:data_31e,0FFh
loc_8:
		test	byte ptr ds:data_47e,0FFh
		jz	loc_9			; Jump if zero
		jmp	loc_47
loc_9:
		test	byte ptr ds:data_34e,0FFh
		jz	loc_10			; Jump if zero
		jmp	loc_20
loc_10:
		test	byte ptr ds:data_36e,0FFh
		jz	loc_11			; Jump if zero
		cmp	byte ptr ds:data_40e,0Dh
		jae	loc_11			; Jump if above or =
		jmp	loc_18
loc_11:
		test	byte ptr ds:data_31e,0FFh
		jnz	loc_13			; Jump if not zero
		mov	byte ptr ds:data_33e,3Ch	; '<'
		inc	byte ptr ds:data_28e
		and	byte ptr ds:data_28e,7
		mov	al,ds:data_28e
		push	cs
		pop	es
		mov	di,data_14e
		mov	cx,5
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jnz	loc_12			; Jump if not zero
		push	ax
		call	lvrender_func_1
		sbb	al,al
		mov	ds:data_31e,al
		pop	ax
		cmp	al,7
		jne	loc_12			; Jump if not equal
		call	lvrender_func_1
		sbb	al,al
		mov	ds:data_31e,al
loc_12:
		jmp	short loc_18
loc_13:
		dec	byte ptr ds:data_33e
		jnz	loc_14			; Jump if not zero
		mov	byte ptr ds:data_31e,0
		jmp	short loc_18
loc_14:
		mov	al,ds:data_28e
		or	al,al			; Zero ?
		jnz	loc_15			; Jump if not zero
		mov	al,8
loc_15:
		cmp	al,6
		jne	loc_16			; Jump if not equal
		sub	al,2
loc_16:
		dec	al
		mov	ds:data_28e,al
		push	cs
		pop	es
		mov	di,data_15e
		mov	cx,5
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jnz	loc_18			; Jump if not zero
		push	ax
		call	lvrender_get_value
		cmc				; Complement carry
		sbb	al,al
		mov	ds:data_31e,al
		pop	ax
		cmp	al,6
		je	loc_17			; Jump if equal
		cmp	al,3
		jne	loc_14			; Jump if not equal
loc_17:
		call	lvrender_get_value
		cmc				; Complement carry
		sbb	al,al
		mov	ds:data_31e,al
loc_18:
		test	byte ptr ds:data_31e,0FFh
		jnz	loc_19			; Jump if not zero
		cmp	byte ptr ds:data_28e,6
		jne	loc_19			; Jump if not equal
		call	word ptr cs:[11Ah]	; was: call word ptr cs:data_6 (fn ptr at offset 11Ah)
		and	al,1
		jnz	loc_19			; Jump if not zero
		test	byte ptr ds:data_36e,0FFh
		jnz	loc_19			; Jump if not zero
		mov	ax,cs:data_22e
		sub	ax,14h
		jc	loc_19			; Jump if carry Set
		mov	byte ptr ds:data_34e,0FFh
		mov	byte ptr ds:data_35e,0
		mov	byte ptr ds:data_32e,0
		mov	byte ptr ds:data_28e,8
		mov	byte ptr ds:data_50e,30h	; '0'
loc_19:
		inc	byte ptr ds:data_29e
		and	byte ptr ds:data_29e,3
		mov	al,ds:data_29e
		mov	bx,data_13e
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[0A7BAh],al
		jmp	$+9Ah
loc_20:
		db	0FEh, 06h,0C1h,0A7h, 8Ah, 1Eh
		db	0C1h,0A7h,0FEh,0CBh, 32h,0FFh
		db	 03h,0DBh,0FFh,0A7h,0C7h,0A3h
		db	0CDh,0A3h,0FEh,0A3h, 0Ah,0A4h
		db	0C6h, 06h,0BAh,0A7h, 06h,0C6h
		db	 06h,0B9h,0A7h, 08h,0C6h, 06h
		db	0C2h,0A7h,0FFh,0A1h,0A0h,0A7h
		db	 05h, 04h, 00h,0A3h,0C3h,0A7h
		db	0A0h,0A2h,0A7h, 24h, 3Fh,0A2h
		db	0C5h,0A7h,0C6h, 06h,0C6h,0A7h
		db	 00h,0C6h, 06h,0C7h,0A7h, 00h
		db	0C6h, 06h,0C8h,0A7h, 00h,0EBh
		db	 4Eh,0C6h, 06h,0BAh,0A7h, 07h
		db	0C6h, 06h,0B9h,0A7h, 06h,0EBh
		db	 42h,0C6h, 06h,0BAh,0A7h, 00h
		db	0C6h, 06h,0C0h,0A7h, 00h,0C6h
		db	 06h,0B9h,0A7h, 06h,0EBh, 31h
		db	 00h, 01h, 02h, 01h, 02h, 05h
		db	 06h, 07h, 00h, 01h, 03h, 06h
		db	 07h, 07h

zr3_14		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

lvrender_func_1		proc	near
		mov	ax,ds:data_22e
		dec	ax
		mov	bx,0Eh
		sub	bx,ax
		mov	ds:data_22e,ax
		cmc				; Complement carry
		jnc	$+3			; Jump if carry=0
		retn
lvrender_func_1		endp

		db	0F8h,0C3h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

lvrender_get_value		proc	near
		mov	ax,ds:data_22e
		inc	ax
		mov	bx,32h
		sub	bx,ax
		jnc	$+3			; Jump if carry=0
		retn
lvrender_get_value		endp

		db	0A3h,0A0h,0A7h,0F8h,0C3h
		db	 0Eh, 07h
		db	0BFh,0C9h,0A7h,0B9h, 28h, 00h
		db	0B8h,0FFh,0FFh,0F3h,0ABh, 8Ah
		db	 1Eh,0B9h,0A7h, 32h,0FFh, 03h
		db	0DBh, 8Bh,0B7h,0C8h,0A6h, 8Bh
		db	0AFh, 44h,0A7h
		db	0BFh,0CBh,0A7h,0B9h, 08h, 00h

locloop_23:
		push	cx
		mov	cx,8

locloop_24:
		rol	byte ptr ds:[bp],1	; Rotate
		jnc	loc_25			; Jump if carry=0
		movsb				; Mov [si] to es:[di]
		dec	di
loc_25:
		inc	di
		loop	locloop_24		; Loop if cx > 0

		inc	di
		inc	di
		inc	bp
		pop	cx
		loop	locloop_23		; Loop if cx > 0

		mov	al,byte ptr ds:[0A7BAh]
		add	al,al
		mov	di,data_44e
		cmp	byte ptr ds:data_28e,6
		je	loc_26			; Jump if equal
		cmp	byte ptr ds:data_28e,8
		jb	loc_27			; Jump if below
loc_26:
		inc	di
loc_27:
		stosb				; Store al to es:[di]
		add	di,13h
		inc	al
		stosb				; Store al to es:[di]
		mov	byte ptr ds:data_25e,0
		mov	ax,ds:data_22e
		mov	si,ds:data_45e
		mov	di,0A7C9h
		mov	cx,8
loc_28:
		push	cx
		push	di
		push	ax
		call	word ptr cs:data_10e
		pop	ax
		mov	ds:data_30e,bl
		jc	loc_32			; Jump if carry Set
		xor	cl,cl			; Zero register
loc_29:
		push	cx
		push	ax
		cmp	byte ptr [di],0FFh
		je	loc_31			; Jump if equal
		mov	[si],ax
		mov	al,ds:data_23e
		add	al,cl
		and	al,3Fh			; '?'
		mov	[si+2],al
		mov	al,ds:data_30e
		mov	[si+3],al
		mov	al,[di]
		mov	[si+6],al
		mov	ah,al
		add	al,al
		sbb	al,al
		and	al,60h			; '`'
		mov	bl,ah
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		and	bl,7
		or	al,bl
		mov	[si+4],al
		mov	byte ptr [si+5],0
		test	byte ptr ds:data_26e,0FFh
		jz	loc_30			; Jump if zero
		or	byte ptr [si+5],20h	; ' '
loc_30:
		push	di
		mov	ax,[si+2]
		call	word ptr cs:data_9e
		mov	bl,ds:data_25e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_46e[bx],al
		pop	di
		add	si,10h
		inc	byte ptr ds:data_25e
loc_31:
		inc	di
		pop	ax
		pop	cx
		inc	cl
		cmp	cl,0Ah
		jne	loc_29			; Jump if not equal
loc_32:
		inc	ax
		pop	di
		add	di,0Ah
		pop	cx
		loop	locloop_33		; Loop if cx > 0

		jmp	short loc_34

locloop_33:
		jmp	loc_28
loc_34:
		call	lvrender_func_3
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:data_36e,0FFh
		jnz	loc_35			; Jump if not zero
		retn
loc_35:
		test	byte ptr ds:data_41e,0FFh
		jnz	loc_41			; Jump if not zero
		cmp	byte ptr ds:data_37e,12h
		jae	loc_36			; Jump if above or =
		mov	byte ptr ds:data_41e,0FFh
		mov	byte ptr ds:data_39e,3
		mov	byte ptr ds:data_50e,32h	; '2'
		retn
loc_36:
		mov	bl,ds:data_40e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	al,ds:data_16e[bx]
		add	ds:data_37e,al
		mov	al,ds:data_17e[bx]
		add	ds:data_38e,al
		cmp	byte ptr ds:data_40e,10h
		adc	byte ptr ds:data_40e,0
		mov	al,ds:data_39e
		inc	al
		cmp	al,3
		jb	loc_37			; Jump if below
		xor	al,al			; Zero register
loc_37:
		mov	ds:data_39e,al
		cmp	byte ptr ds:data_40e,9
		jne	loc_38			; Jump if not equal
		mov	byte ptr ds:data_50e,31h	; '1'
loc_38:
		cmp	byte ptr ds:data_40e,0Ch
		jne	loc_39			; Jump if not equal
		mov	byte ptr ds:data_50e,31h	; '1'
loc_39:
		cmp	byte ptr ds:data_40e,0Fh
		jne	loc_ret_40		; Jump if not equal
		mov	byte ptr ds:data_50e,31h	; '1'

loc_ret_40:
		retn
loc_41:
		inc	byte ptr ds:data_39e
		cmp	byte ptr ds:data_39e,6
		jae	loc_42			; Jump if above or =
		retn
loc_42:
		mov	byte ptr ds:data_36e,0
		retn
		db	0FFh, 00h,0FFh, 00h,0FFh, 01h
		db	 00h, 02h,0FFh, 02h, 00h, 02h
		db	0FFh, 02h,0FFh,0FEh,0FFh, 00h
		db	0FFh, 02h,0FFh,0FFh,0FFh, 00h
		db	0FFh, 01h,0FFh, 00h,0FFh, 00h
		db	0FFh, 00h,0FFh, 00h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

lvrender_func_3		proc	near
		test	byte ptr ds:data_36e,0FFh
		jnz	loc_43			; Jump if not zero
		retn
loc_43:
		mov	ax,ds:data_37e
		push	ax
		call	word ptr cs:data_10e
		pop	ax
		jnc	loc_44			; Jump if carry=0
		retn
loc_44:
		mov	[si],ax
		mov	al,ds:data_38e
		mov	[si+2],al
		mov	[si+3],bl
		mov	byte ptr [si+4],26h	; '&'
		mov	byte ptr [si+5],0
		mov	al,ds:data_39e
		mov	[si+6],al
		mov	ax,[si+2]
		call	word ptr cs:data_9e
		mov	bl,ds:data_25e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_46e[bx],al
		add	si,10h
		retn
lvrender_func_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

lvrender_func_4		proc	near
		mov	ax,ds:data_24e
		sub	ax,bx
		jnc	loc_45			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_45:
		mov	ds:data_24e,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:data_8e
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_46			; Jump if zero
		retn
loc_46:
		mov	byte ptr ds:data_27e,0
		mov	byte ptr ds:data_36e,0
		mov	byte ptr ds:data_47e,0FFh
		retn
lvrender_func_4		endp

loc_47:
		cmp	byte ptr ds:data_27e,28h	; '('
;*		jae	loc_50			;*Jump if above or =
		db	073h, 04Dh		; jnc 6C6h (absolute)
		mov	byte ptr ds:data_48e,0FFh
		inc	byte ptr ds:data_27e
		cmp	byte ptr ds:data_27e,0Ah
		jae	loc_49			; Jump if above or =
		mov	al,ds:data_27e
		mov	bx,data_18e
		xlat				; al=[al+[bx]] table
		mov	ds:data_28e,al
		cmp	al,3
		jb	loc_48			; Jump if below
		mov	byte ptr ds:data_50e,33h	; '3'
loc_48:
		jmp	loc_19
		db	0, 1, 2, 3, 6, 7
		db	6, 3, 2, 1
loc_49:
		mov	ah,ds:data_27e
		mov	al,6
		cmp	ah,6
		jae	$+8			; Jump if above or =
		mov	al,ah
		mov	bx,data_19e
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[0A7BAh],al
		jmp	$-26Dh

; ------------------------------------------------------------------
; Module trailer: dispatch-table handler body + jump-table words
; + tile/cell continuation data + 'Tarso' town-name fragment.
; Entered via dispatch call [data_21e+bx] from main loop.
; ------------------------------------------------------------------
			                        ;* No entry point to code
		add	ax,[bp+di]		; data bytes
		add	al,4			; data bytes
		add	ax,0C605h		; data bytes
		push	es			; data byte
;*		xor	bh,bh			; Zero register
		db	030h, 0FFh		; xor bh,bh (alt encoding) -- data bytes
;*		inc	bx
		db	0FFh, 0C3h		; inc bx (alt encoding) -- data bytes
; jump-table: 10 word entries pointing into cs:A6DC..A798 handlers
		db	0DCh,0A6h,0E3h,0A6h,0ECh,0A6h
		db	0F6h,0A6h, 01h,0A7h, 0Ch,0A7h
		db	 18h,0A7h, 22h,0A7h, 2Eh,0A7h
		db	 39h,0A7h, 11h, 10h, 12h, 13h
		db	 14h, 15h, 16h, 11h, 17h, 19h
		db	 10h, 12h, 18h, 1Ah, 1Bh, 1Ch
		db	 1Dh, 1Fh, 21h, 23h, 10h, 1Eh
		db	' "$'
		db	'%)*', 27h, '&('
		db	 10h, 1Eh
		db	' "$'
		db	'%20-1+.'
		db	 10h, 1Eh
		db	' ,/=:<;3'
		db	10h
		db	'456789BC@D>'
		db	10h
		db	'?AEFXYZOPRTVQSUW'
		db	0CAh, 42h, 47h, 40h, 48h, 3Eh
		db	 10h, 3Fh, 41h, 45h, 46h,0CEh
		db	 42h, 4Dh, 40h, 4Ch, 3Eh, 10h
		db	 3Fh, 41h, 45h, 46h, 58h,0A7h
		db	 60h,0A7h, 68h,0A7h, 70h,0A7h
		db	 78h,0A7h, 80h,0A7h, 88h,0A7h
		db	 90h,0A7h, 98h,0A7h, 98h,0A7h
		db	 00h, 00h, 00h, 00h, 20h,0ABh
		db	 01h, 00h, 00h, 00h, 00h, 00h
		db	 2Ch,0ADh, 01h, 00h, 00h, 00h
		db	 00h, 00h, 2Bh, 80h, 2Bh, 01h
		db	 00h, 00h, 05h, 10h, 28h, 80h
		db	 2Bh, 01h, 08h, 04h, 18h, 00h
		db	 28h, 80h, 2Bh, 00h, 00h, 02h
		db	 14h, 10h, 20h,0A8h, 0Ch, 03h
		db	 00h, 00h, 03h, 05h, 10h, 55h
		db	 00h, 01h, 00h, 00h, 00h, 00h
		db	 0Bh,0ABh, 53h, 00h, 01h, 00h
		db	 03h, 05h, 10h, 55h, 00h, 01h
		db	 26h, 00h, 07h, 80h, 02h, 70h
		db	 17h, 08h,0FFh,0ADh,0A7h,0DCh
		db	 05h, 11h,0BBh, 02h, 05h
; 'Tarso' - town-name / label string fragment
		db	'Tarso'
; trailing zero padding to round module size up
		db	99 dup (0)

seg_a		ends



		end	start
