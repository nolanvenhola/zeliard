
PAGE  59,132

;==========================================================================
;
;  313MEDA / _313MAPBT - Bosque Town Map Program (zelres3 chunk)
;
;  Map-program code module for Bosque Town. Loaded together with the town
;  data file map_bosque_town.bin (313MAPBT.bin). Contains a 'Vista' string
;  near the end that is part of the town's in-game text data.
;
;  Structure:
;    - Header / pointer table (file 0x00..~0x100) mis-decoded by Sourcer
;    - Large embedded tile/layout data block (bulk of the file)
;    - Per-frame tile scan / NPC cell update loop (loc_2..loc_5)
;    - Dispatch / scroll / sub_NN helper procs
;
;  Note: "MEDA" is a prior-pass working nickname for the chunk; the
;  disassembler-stored proc name _313MAPBT is authoritative.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.
; Shared references across 312-319 map-program family:
;   200Ch..603Ch  - game-segment dispatch callback fn ptrs
;   0C002h/0C010h - sprite attribute / entity record base
;   0ED20h        - char/tile lookup table
;   0FF2Eh..0FF75h - per-map global state flag bytes

data_11e	equ	200Ch			;* scroll/dispatch callback
data_12e	equ	6028h			;* game-seg callback fn A (tile dispatch)
data_13e	equ	6036h			;* game-seg callback fn B (tile-at-pos)
data_14e	equ	6038h			;* game-seg callback fn C
data_15e	equ	603Ah			;* game-seg callback fn D
data_16e	equ	603Ch			;* game-seg callback fn E
data_17e	equ	0A5DCh			;*
data_18e	equ	0A606h			;*
data_19e	equ	0A613h			;*
data_20e	equ	0A623h			;*
data_21e	equ	0A62Eh			;*
data_22e	equ	0A682h			;*
data_23e	equ	0A687h			;*
data_24e	equ	0A6C7h			;*
data_25e	equ	0A6E0h			;*
data_26e	equ	0A6E1h			;*
data_27e	equ	0A6EDh			;*
data_28e	equ	0A716h			;*
data_29e	equ	0A718h			;*
data_30e	equ	0A719h			;*
data_31e	equ	0A72Ch			;*
data_32e	equ	0A72Dh			;*
data_33e	equ	0A72Eh			;*
data_34e	equ	0A72Fh			;*
data_35e	equ	0A730h			;*
data_36e	equ	0A731h			;*
data_37e	equ	0A732h			;*
data_38e	equ	0A733h			;*
data_39e	equ	0A734h			;*
data_40e	equ	0A735h			;*
data_41e	equ	0A736h			;*
data_42e	equ	0A737h			;*
data_43e	equ	0A738h			;*
data_44e	equ	0C002h			;* sprite attribute ptr
data_45e	equ	0C010h			;* sprite attribute record base
data_46e	equ	0ED20h			;* char/tile lookup table
data_47e	equ	0FF2Eh			;* global state byte
data_48e	equ	0FF2Fh			;* global state byte
data_49e	equ	0FF30h			;* global state byte
data_50e	equ	0FF75h			;* global state byte

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_313MAPBT	proc	far

; ------------------------------------------------------------------
; start: header + embedded tile/cell layout data.
; Sourcer mis-decoded header bytes as x86 code; real entry is via
; dispatch from game DS. The far-ptr "jmp 0A7:16A1" Sourcer flagged
; is a header field word, not a real control-flow jump.
; ------------------------------------------------------------------
start:
		mov	[bx+si],cl		; header field bytes
		add	[bx+si],al		; header field bytes
;*		jmp	far ptr loc_1		;*
		db	0EAh			;  data byte (not real jmp opcode)
		dw	16A1h, 0A7h		;  header pointer words
		db	11 dup (0)
		db	32 dup (1Eh)
		db	 50h,0A0h,0A0h,0A0h,0F0h,0A0h
		db	 40h,0A1h
		db	20 dup (0)
		db	 8Bh,0A1h,0DBh,0A1h, 00h
data_4		db	1			; Data table (indexed access)
		db	 00h, 02h, 03h, 00h, 00h, 04h
		db	 05h, 06h, 00h, 00h, 07h, 16h
		db	 09h, 00h, 08h, 0Bh, 0Ah, 0Ch
		db	 00h, 0Dh, 0Eh, 0Fh, 10h, 00h
		db	 11h, 12h, 13h, 0Ah, 00h, 14h
		db	 00h, 0Ah, 15h, 00h, 00h, 17h
		db	 18h, 19h, 00h, 1Ah, 1Bh, 1Ch
data_5		dw	0Ah
		db	 1Dh, 1Eh, 1Fh
data_6		db	' ', 0
		db	'!"', 0Ah, '#', 0
		db	0Ah, '$'
		db	0Ah, '%', 0
		db	'&', 0Ah, 27h, 0Ah, 0
		db	'(', 0Ah, ')', 0Ah, 0
		db	'*', 0Ah, '+', 0Ah, 0
		db	0Ah, 0Ah, 0Ah, ',', 0
		db	'-', 0
		db	0Ah, '.', 0
		db	0Ah, '/', 0Ah, '0', 0
		db	0Ah, '123', 0
		db	'4', 0
		db	'56'
		db	 00h, 00h, 00h, 37h, 38h, 00h
		db	 00h, 39h, 3Ah, 3Bh, 00h, 00h
		db	 00h
		db	3Ch
		db	'=', 0
		db	'>?@A', 0
		db	'BCDE', 0
		db	'FGHI', 0
		db	'Z[\]', 0
		db	'^_`a', 0
		db	'bcde', 0
		db	'fghi', 0
		db	'jklm', 0
		db	'nopq', 0
		db	'rstu', 0
		db	'vwxy', 0
		db	'z{|}', 0
		db	 7Eh, 7Fh, 68h, 69h, 00h, 80h
		db	 81h, 6Ch, 6Dh, 00h, 82h, 83h
		db	 70h, 71h, 00h, 72h, 84h, 85h
		db	 86h, 00h, 76h, 87h, 88h, 89h
		db	 00h, 62h, 63h, 8Ah, 8Bh, 00h
		db	 8Ch, 8Dh, 68h, 69h, 00h, 8Eh
		db	 8Fh, 6Ch, 6Dh, 00h, 90h, 91h
		db	 70h, 71h, 00h, 92h, 84h, 93h
		db	 94h, 00h, 95h, 96h, 97h, 98h
		db	 00h, 99h, 63h, 8Ah, 9Ah, 00h
		db	 9Bh, 9Ch, 68h, 69h, 00h, 9Dh
		db	 9Eh, 6Ch, 6Dh, 00h, 9Fh,0A0h
		db	 70h, 71h, 00h, 72h,0A1h,0A2h
		db	0A3h, 00h, 76h, 77h,0A4h,0A5h
		db	 00h, 62h, 63h,0A6h,0A7h, 00h
		db	0A8h,0A9h, 68h, 69h, 00h, 6Ah
		db	0AAh, 6Ch, 6Dh, 00h,0ABh,0ACh
		db	 70h, 71h, 00h, 5Ah,0ADh,0AEh
		db	0AFh, 00h,0B0h,0B1h,0B2h,0B3h
		db	 00h,0B4h, 7Bh,0B5h,0B6h, 00h
		db	0B7h,0B8h,0B9h,0BAh, 00h,0BBh
		db	0BCh, 6Ch,0BDh, 00h,0BEh,0BFh
		db	 70h, 71h, 00h, 42h, 43h, 44h
		db	0CCh, 00h, 4Ah, 4Bh, 4Ch, 4Dh
		db	 00h, 4Eh, 4Fh, 50h, 51h, 00h
		db	 52h, 53h, 54h, 55h, 00h, 56h
		db	 57h, 58h, 59h, 00h,0C0h,0C1h
		db	0C2h,0C3h, 00h,0C4h,0C5h,0C6h
		db	0C7h, 00h, 00h, 00h,0C8h,0C9h
		db	 00h, 00h, 00h,0CAh,0CBh, 00h
		db	0C0h,0C1h,0CDh,0CEh, 00h,0CFh
		db	0C5h,0C6h,0C7h, 00h,0C0h,0C1h
		db	0D0h,0D1h, 00h,0D2h,0C5h,0C6h
		db	0C7h, 00h, 00h, 00h,0C8h,0D3h
		db	 00h, 00h, 00h, 00h,0D4h, 00h
		db	0C0h,0C1h,0D5h,0D6h, 00h,0D7h
		db	0C5h,0D8h,0C7h, 00h, 00h,0D9h
		db	0DAh,0DBh, 00h,0C0h,0C1h,0C2h
		db	0DCh, 00h,0DDh,0C5h,0DEh,0C7h
		db	 8Bh, 36h, 10h,0C0h,0C6h, 06h
		db	 31h,0A7h, 00h,0C6h, 06h, 32h
		db	0A7h, 00h
loc_2:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jz	loc_5			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:data_13e
		jc	loc_4			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:data_12e
		mov	bl,ds:data_36e
		xor	bh,bh			; Zero register
		mov	al,ds:data_46e[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	loc_4			; Jump if zero
		test	byte ptr ds:data_37e,80h
		jnz	loc_4			; Jump if not zero
		mov	al,[si+5]
		and	al,1Fh
		test	byte ptr [si+4],8
		jz	loc_3			; Jump if zero
		or	al,80h
loc_3:
		mov	ds:data_37e,al
loc_4:
		inc	byte ptr ds:data_36e
		add	si,10h
		jmp	short loc_2
loc_5:
		mov	si,ds:data_45e
		mov	word ptr [si],0FFFFh
		mov	al,ds:data_37e
		and	al,1Fh
		jz	loc_8			; Jump if zero
		push	ax
		call	word ptr cs:data_14e
		mov	bl,ah
		pop	ax
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		cmp	al,1
		jne	loc_6			; Jump if not equal
		cmp	byte ptr data_6+0Dh,4	; ('')
		jb	loc_6			; Jump if below
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,bx
		mov	byte ptr ds:data_50e,2Dh	; '-'
		jmp	short loc_7
loc_6:
		mov	byte ptr ds:data_50e,2Eh	; '.'
loc_7:
		call	sub_9
loc_8:
		test	byte ptr ds:data_47e,0FFh
		jz	loc_9			; Jump if zero
		jmp	loc_42
loc_9:
		test	byte ptr ds:data_39e,0FFh
		jnz	loc_13			; Jump if not zero
		cmp	byte ptr ds:data_29e,7
		jne	loc_11			; Jump if not equal
		mov	ax,data_5
		add	ax,10h
		mov	bx,ax
		sub	ax,ds:data_44e
		jc	loc_10			; Jump if carry Set
		xchg	bx,ax
loc_10:
		mov	ax,ds:data_28e
		add	ax,4
		sub	ax,bx
		jnc	loc_11			; Jump if carry=0
		mov	ax,ds:data_28e
		add	ax,6
		sub	ax,bx
		jc	loc_11			; Jump if carry Set
		mov	byte ptr ds:data_40e,3
		mov	byte ptr ds:data_39e,0FFh
loc_11:
		test	byte ptr ds:data_41e,0FFh
		jnz	loc_12			; Jump if not zero
		call	sub_6
		jnc	loc_16			; Jump if carry=0
		mov	byte ptr ds:data_41e,0FFh
		jmp	short loc_16
loc_12:
		call	sub_5
		jnc	loc_16			; Jump if carry=0
		mov	byte ptr ds:data_41e,0
		jmp	short loc_16
loc_13:
		test	byte ptr ds:data_40e,0FFh
		jz	loc_14			; Jump if zero
		dec	byte ptr ds:data_40e
		jmp	short loc_16
loc_14:
		test	byte ptr ds:data_39e,80h
		jz	loc_15			; Jump if zero
		call	sub_4
		jnc	loc_17			; Jump if carry=0
		mov	byte ptr ds:data_39e,7Fh
		jmp	short loc_17
loc_15:
		call	sub_3
		jnc	loc_17			; Jump if carry=0
		mov	byte ptr ds:data_39e,0
		jmp	short loc_17
loc_16:
		mov	bx,ds:data_28e
		sub	bx,9
		mov	al,ds:data_27e[bx]
		mov	ds:data_29e,al
loc_17:
		call	sub_1
		test	byte ptr ds:data_42e,0FFh
		jz	loc_18			; Jump if zero
		dec	byte ptr ds:data_42e
		jmp	loc_30
loc_18:
		inc	byte ptr ds:data_35e
		cmp	byte ptr ds:data_35e,5
		jne	loc_19			; Jump if not equal
		mov	byte ptr ds:data_42e,3
		mov	byte ptr ds:data_35e,0
loc_19:
		cmp	byte ptr ds:data_35e,4
		jne	loc_20			; Jump if not equal
		call	sub_2
loc_20:
		jmp	loc_30

_313MAPBT	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		mov	ax,data_5
		add	ax,10h
		mov	bx,ax
		sub	ax,ds:data_44e
		jc	loc_21			; Jump if carry Set
		xchg	bx,ax
loc_21:
		mov	ax,ds:data_28e
		inc	ax
		sub	ax,bx
		jnc	loc_22			; Jump if carry=0
		mov	ax,ds:data_28e
		add	ax,0Ah
		sub	ax,bx
		jc	loc_22			; Jump if carry Set
		mov	byte ptr ds:data_34e,2
		retn
loc_22:
		mov	ax,ds:data_28e
		add	ax,0FFFAh
		sub	ax,bx
		jnc	loc_24			; Jump if carry=0
		mov	ax,ds:data_28e
		add	ax,11h
		sub	ax,bx
		jc	loc_24			; Jump if carry Set
		mov	ax,ds:data_28e
		add	ax,7
		inc	bx
		sub	ax,bx
		jc	loc_23			; Jump if carry Set
		mov	byte ptr ds:data_34e,1
		retn
loc_23:
		mov	byte ptr ds:data_34e,3
		retn
loc_24:
		mov	ax,ds:data_28e
		add	ax,7
		inc	bx
		sub	ax,bx
		jc	loc_25			; Jump if carry Set
		mov	byte ptr ds:data_34e,0
		retn
loc_25:
		mov	byte ptr ds:data_34e,4
		retn
sub_1		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_2		proc	near
		mov	ax,ds:data_28e
		add	ax,6
		call	word ptr cs:data_13e
		jc	loc_26			; Jump if carry Set
		mov	ds:data_25e,bl
		mov	al,ds:data_29e
		add	al,0Ch
		and	al,3Fh			; '?'
		mov	ds:data_26e,al
		mov	bx,0A6E0h
		call	word ptr cs:data_15e
loc_26:
		mov	ax,ds:data_28e
		add	ax,7
		call	word ptr cs:data_13e
		jnc	loc_27			; Jump if carry=0
		retn
loc_27:
		mov	ds:data_25e,bl
		mov	al,ds:data_29e
		add	al,0Ah
		and	al,3Fh			; '?'
		mov	ds:data_26e,al
		mov	bx,0A6E0h
		jmp	word ptr cs:data_15e
sub_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_3		proc	near
		dec	byte ptr ds:data_29e
		cmp	byte ptr ds:data_29e,7
		retn
sub_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_4		proc	near
		inc	byte ptr ds:data_29e
		cmp	byte ptr ds:data_29e,0Bh
		cmc				; Complement carry
		retn
sub_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_5		proc	near
		cmp	byte ptr ds:data_28e,31h	; '1'
		cmc				; Complement carry
		jnc	loc_28			; Jump if carry=0
		retn
loc_28:
		inc	byte ptr ds:data_28e
		retn
sub_5		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_6		proc	near
		cmp	byte ptr ds:data_28e,0Ah
		jae	loc_29			; Jump if above or =
		retn
loc_29:
		dec	byte ptr ds:data_28e
		retn
sub_6		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_7		proc	near
loc_30:
		push	cs
		pop	es
		mov	di,data_43e
		mov	al,0FFh
		mov	cx,150h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	byte ptr ds:data_31e,0
		mov	byte ptr ds:data_32e,0
		mov	si,data_17e
		mov	bp,data_18e
		mov	cx,0Dh
		call	sub_8
		mov	byte ptr ds:data_31e,1
		mov	byte ptr ds:data_32e,8
		mov	si,data_19e
		mov	bp,data_20e
		mov	cx,0Bh
		call	sub_8
		mov	byte ptr ds:data_31e,4
		mov	byte ptr ds:data_32e,3
		mov	bl,ds:data_34e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_21e[bx]
		mov	bp,data_22e
		mov	cx,5
		call	sub_8
		mov	byte ptr ds:data_32e,7
		mov	bl,ds:data_35e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:data_23e[bx]
		mov	bp,ds:data_24e[bx]
		mov	cx,5
		call	sub_8
		mov	byte ptr ds:data_36e,0
		mov	ax,ds:data_28e
		mov	di,ds:data_45e
		mov	si,data_43e
		mov	cx,0Eh

locloop_31:
		push	cx
		push	si
		push	ax
		call	word ptr cs:data_13e
		pop	ax
		mov	ds:data_33e,bl
		jc	loc_35			; Jump if carry Set
		xor	cl,cl			; Zero register
loc_32:
		push	cx
		push	ax
		cmp	byte ptr [si],0FFh
		je	loc_34			; Jump if equal
		mov	[di],ax
		mov	al,ds:data_29e
		add	al,cl
		and	al,3Fh			; '?'
		mov	[di+2],al
		mov	al,ds:data_33e
		mov	[di+3],al
		mov	al,[si]
		mov	[di+4],al
		mov	al,[si+1]
		mov	[di+6],al
		mov	byte ptr [di+5],0
		test	byte ptr ds:data_37e,0FFh
		jz	loc_33			; Jump if zero
		or	byte ptr [di+5],20h	; ' '
loc_33:
		push	di
		mov	ax,[di+2]
		call	word ptr cs:data_12e
		mov	bl,ds:data_36e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_46e[bx],al
		pop	di
		add	di,10h
		inc	byte ptr ds:data_36e
loc_34:
		inc	si
		inc	si
		pop	ax
		pop	cx
		inc	cl
		cmp	cl,0Ch
		jne	loc_32			; Jump if not equal
loc_35:
		inc	ax
		pop	si
		add	si,18h
		pop	cx
		loop	locloop_31		; Loop if cx > 0

		mov	word ptr [di],0FFFFh
		retn
sub_7		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_8		proc	near
		push	cs
		pop	es
		mov	al,ds:data_31e
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	dx,ax
		add	ax,ax
		add	ax,dx
		mov	dl,ds:data_32e
		xor	dh,dh			; Zero register
		add	dx,dx
		add	ax,dx
		mov	di,ax
		add	di,data_43e

locloop_36:
		push	cx
		mov	cx,8

locloop_37:
		rol	byte ptr ds:[bp],1	; Rotate
		jnc	loc_38			; Jump if carry=0
		movsw				; Mov [si] to es:[di]
		dec	di
		dec	di
loc_38:
		inc	di
		inc	di
		loop	locloop_37		; Loop if cx > 0

		add	di,8
		inc	bp
		pop	cx
		loop	locloop_36		; Loop if cx > 0

		retn
sub_8		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_9		proc	near
		mov	ax,ds:data_30e
		sub	ax,bx
		jnc	loc_39			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_39:
		mov	ds:data_30e,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:data_11e
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_40			; Jump if zero
		retn
loc_40:
		test	byte ptr ds:data_47e,0FFh
		jz	loc_41			; Jump if zero
		retn
loc_41:
		mov	byte ptr ds:data_38e,0
		mov	byte ptr ds:data_47e,0FFh
		jmp	word ptr cs:data_16e
sub_9		endp

loc_42:
		cmp	byte ptr ds:data_38e,28h	; '('
		jae	loc_44			; Jump if above or =
		mov	byte ptr ds:data_48e,0FFh
		inc	byte ptr ds:data_38e
		cmp	byte ptr ds:data_38e,14h
		jae	loc_43			; Jump if above or =
		mov	byte ptr ds:data_35e,0
		call	sub_1
		call	sub_7
		mov	byte ptr ds:data_50e,23h	; '#'
		retn
loc_43:
		mov	byte ptr ds:data_34e,5
		jmp	loc_30
loc_44:
		mov	byte ptr ds:data_49e,0FFh
		retn
		db	 00h, 07h, 00h, 08h, 00h, 09h
		db	 00h, 00h, 00h, 02h, 00h, 0Ah
		db	 00h, 0Bh, 00h, 0Ch, 00h, 03h
		db	 01h, 07h, 00h, 04h, 00h, 05h
		db	 01h, 09h, 00h, 06h, 00h, 0Dh
		db	 00h, 0Eh, 00h, 0Fh, 00h, 01h
		db	 01h, 00h, 01h, 01h, 01h, 02h
		db	 2Ah, 80h, 55h, 00h, 41h, 00h
		db	 40h, 00h, 41h, 00h, 55h, 80h
		db	 2Ah, 01h, 03h, 01h, 04h, 0Eh
		db	 02h, 0Eh, 00h, 0Eh, 01h, 0Eh
		db	 03h, 01h, 05h, 01h, 06h,0C0h
		db	 10h, 40h, 00h, 00h, 00h, 00h
		db	 00h, 40h, 10h,0C0h, 3Ah,0A6h
		db	 46h,0A6h, 52h,0A6h, 5Eh,0A6h
		db	 6Ah,0A6h, 76h,0A6h, 01h, 0Ah
		db	 01h, 0Dh, 01h, 0Bh, 01h, 0Eh
		db	 01h, 0Ch, 01h, 0Fh, 02h, 00h
		db	 02h, 03h, 02h, 01h, 02h, 04h
		db	 02h, 02h, 02h, 05h, 02h, 06h
		db	 02h, 09h, 02h, 07h, 02h, 0Ah
		db	 02h, 08h, 02h, 0Bh, 02h, 0Ch
		db	 02h, 0Fh, 02h, 0Dh, 03h, 00h
		db	 02h, 0Eh, 03h, 01h, 03h, 02h
		db	 03h, 05h, 03h, 03h, 03h, 06h
		db	 03h, 04h, 03h, 07h, 03h, 08h
		db	 03h, 0Bh, 03h, 09h, 03h, 0Ch
		db	 03h, 0Ah, 03h, 0Dh,0A0h, 00h
		db	0A0h, 00h,0A0h, 91h,0A6h, 9Bh
		db	0A6h,0A5h,0A6h,0B1h,0A6h,0BDh
		db	0A6h, 0Eh, 06h, 0Eh, 04h, 01h
		db	 08h, 0Eh, 05h, 0Eh, 07h, 0Eh
		db	 06h, 0Eh, 08h, 03h, 0Eh, 0Eh
		db	 09h, 0Eh, 07h, 0Eh, 0Ch, 0Eh
		db	 0Ah, 0Eh, 0Dh, 01h, 08h, 0Eh
		db	 0Bh, 0Eh, 07h, 0Eh, 06h, 0Eh
		db	 0Eh, 0Fh, 00h, 01h, 08h, 0Eh
		db	 0Fh, 0Eh, 07h, 0Eh, 06h, 0Fh
		db	 01h, 01h, 08h, 0Fh, 02h, 0Eh
		db	 07h,0D1h,0A6h,0D1h,0A6h,0D6h
		db	0A6h,0DBh,0A6h,0D1h,0A6h, 10h
		db	 20h, 80h, 20h, 10h, 10h, 30h
		db	 80h, 20h, 10h, 10h, 28h, 80h
		db	 20h, 10h, 00h, 00h, 30h, 00h
		db	 32h, 06h, 50h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 0Ch, 0Bh
		db	 0Ah, 09h, 08h
		db	31 dup (7)
		db	 08h, 09h, 0Ah, 0Bh, 0Ch, 30h
		db	 00h, 0Bh,0BCh, 02h,0B8h, 0Bh
		db	 0Ch, 00h, 23h,0A7h, 20h, 03h
		db	 11h,0BBh, 02h, 05h
; 'Vista' - string literal (Bosque town sub-location / vista name)
		db	'Vista'
; trailing zero padding to round module size up
		db	348 dup (0)

seg_a		ends



		end	start
