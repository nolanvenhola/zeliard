
PAGE  59,132

;��������������������������������������������������������������������������
;��					                                 ��
;��				_312MAPST                                ��
;��					                                 ��
;��      Created:   5-Apr-26		                                 ��
;��      Code type: zero start		                                 ��
;��      Passes:    5          Analysis	Options on: none                 ��
;��					                                 ��
;��������������������������������������������������������������������������

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	8802h			;*
data_2e		equ	8E8Dh			;*
data_3e		equ	9302h			;*
data_4e		equ	0A2A1h			;*
data_14e	equ	6C6h			;*
data_15e	equ	200Ch			;*
data_16e	equ	6028h			;*
data_17e	equ	6036h			;*
data_18e	equ	6038h			;*
data_19e	equ	603Ah			;*
data_20e	equ	603Ch			;*
data_21e	equ	0A307h			;*
data_22e	equ	0A33Eh			;*
data_23e	equ	0A343h			;*
data_24e	equ	0A348h			;*
data_25e	equ	0A4EAh			;*
data_26e	equ	0A552h			;*
data_27e	equ	0A553h			;*
data_28e	equ	0A55Fh			;*
data_29e	equ	0A560h			;*
data_30e	equ	0A5EEh			;*
data_31e	equ	0A5F0h			;*
data_32e	equ	0A5F1h			;*
data_33e	equ	0A603h			;*
data_34e	equ	0A604h			;*
data_35e	equ	0A605h			;*
data_36e	equ	0A606h			;*
data_37e	equ	0A607h			;*
data_38e	equ	0A608h			;*
data_39e	equ	0A609h			;*
data_40e	equ	0A60Ah			;*
data_41e	equ	0A60Bh			;*
data_42e	equ	0A60Ch			;*
data_43e	equ	0A60Dh			;*
data_44e	equ	0A60Eh			;*
data_45e	equ	0A60Fh			;*
data_46e	equ	0A610h			;*
data_47e	equ	0A613h			;*
data_48e	equ	0A619h			;*
data_49e	equ	0A61Fh			;*
data_50e	equ	0A625h			;*
data_51e	equ	0C002h			;*
data_52e	equ	0C010h			;*
data_53e	equ	0ED20h			;*
data_54e	equ	0FF2Eh			;*
data_55e	equ	0FF2Fh			;*
data_56e	equ	0FF30h			;*
data_57e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_312MAPST	proc	far

start:
		sub	byte ptr ds:[0],al
		mov	dh,0A1h
		out	dx,al			; port 0A100h ??I/O Non-standard
		movsw				; Mov [si] to es:[di]
		db	12 dup (0)
		db	32 dup (1Eh)
		db	 3Ah,0A0h, 8Ah,0A0h,0D0h,0A0h
		db	 16h,0A1h, 66h,0A1h, 02h, 01h
		db	 02h, 03h, 04h, 02h, 11h, 07h
		db	 12h, 13h, 02h, 1Eh, 16h, 1Fh
		db	 20h, 02h, 05h, 06h, 07h, 08h
		db	 02h, 14h, 15h, 16h, 17h, 02h
		db	 21h, 22h, 23h, 24h, 02h, 09h
		db	 0Ah, 0Bh, 0Ch, 02h, 18h, 19h
		db	 1Ah, 1Bh, 02h, 25h, 26h, 27h
		db	 1Dh, 02h, 0Dh, 0Eh, 0Fh, 10h
		db	 02h, 1Ch, 10h, 1Dh, 10h, 02h
		db	 28h, 10h, 29h, 2Ah, 02h, 18h
		db	 2Bh, 1Ah, 2Ch, 02h
data_8		dw	102Dh
		db	 2Eh, 10h, 02h, 11h, 07h, 12h
		db	 2Fh, 02h, 30h, 15h, 31h, 17h
		db	 02h, 32h, 33h, 34h, 35h, 02h
		db	 41h, 42h, 43h, 44h, 02h, 1Eh
		db	 50h, 1Fh, 51h, 02h, 36h, 37h
		db	 38h, 39h, 02h, 45h, 46h, 47h
		db	 48h, 02h, 52h, 53h, 54h, 24h
		db	 02h, 3Ah, 3Bh, 3Ch, 3Dh, 02h
		db	 49h, 4Ah, 4Bh, 4Ch, 02h, 55h
		db	 4Fh, 56h, 57h, 02h, 3Eh, 00h
		db	 3Fh, 40h, 02h, 4Dh, 4Eh, 4Fh
		db	 10h, 02h, 58h, 10h, 59h, 2Ah
		db	 02h, 49h, 5Ah, 4Bh, 5Bh, 02h
		db	 5Ch, 4Eh, 5Dh, 5Eh, 02h, 00h
		db	 32h, 5Fh, 60h, 02h, 6Bh, 6Ch
		db	 6Dh, 6Eh, 02h, 79h, 7Ah, 7Bh
		db	 7Ch, 02h, 61h, 62h, 63h, 64h
		db	 02h, 6Fh, 70h, 71h, 72h, 02h
		db	 7Dh, 7Eh, 7Fh, 24h, 02h, 65h
		db	 66h, 67h, 68h, 02h, 73h, 1Dh
		db	 74h, 75h, 02h, 80h, 4Fh, 81h
		db	 59h, 02h, 69h, 00h, 6Ah, 00h
		db	 02h, 76h, 77h, 4Fh, 78h, 02h
		db	 82h, 10h, 59h, 2Ah, 02h, 73h
		db	 83h, 74h, 84h, 02h
		db	 76h, 77h, 4Fh, 78h
data_9		dw	2
		db	85h
loc_1:
		xchg	byte ptr ds:[9302h][bx],al
		xchg	sp,ax
		xchg	bp,ax
		xchg	si,ax
		add	bl,byte ptr ds:[0A2A1h]
		mov	word ptr ds:[8802h],ax
		mov	word ptr ss:[28Bh][bp+si],cx
		xchg	di,ax
		cbw				; Convrt byte to word
		cwd				; Word to double word
;*		call	far ptr sub_7		;*
		db	9Ah
		dw	0A402h, 0A6A5h		;  Fixup - byte match
		cmpsw				; Cmp [si] to es:[di]
		add	cl,byte ptr ds:[8E8Dh][si]
		db	 67h, 02h, 9Bh, 9Ch, 9Dh, 9Eh
		db	 02h, 25h, 26h, 27h, 1Dh, 02h
		db	 8Fh, 90h, 91h, 92h, 02h, 1Dh
		db	 9Fh,0A0h, 10h, 02h, 28h, 10h
		db	 29h, 2Ah, 02h, 00h, 00h, 00h
		db	 00h, 02h, 00h, 00h, 00h, 00h
		db	 02h, 93h,0A8h, 95h,0A9h, 02h
		db	0AAh,0ABh,0ACh,0ADh, 02h, 00h
		db	0AEh, 00h,0AFh, 02h,0BBh,0BCh
		db	0BDh,0BEh, 02h, 1Eh,0CAh,0A2h
		db	0CBh, 02h,0B0h,0B1h,0B2h,0B3h
		db	 02h,0BFh,0C0h,0C1h,0C2h, 02h
		db	0CCh,0CDh,0CEh,0CFh, 02h,0B4h
		db	0B5h,0B6h,0B7h, 02h,0C3h,0C4h
		db	0C5h,0C6h, 02h,0D0h,0D1h,0D2h
		db	0D3h, 02h,0B8h, 00h,0B9h,0BAh
		db	 02h,0C7h,0C8h, 4Fh,0C9h, 02h
		db	0D4h, 10h, 1Dh, 2Ah, 02h, 00h
		db	 00h, 00h, 00h, 02h, 00h, 00h
		db	 00h, 00h, 02h,0BBh,0BCh,0BDh
		db	0BEh, 02h,0BFh,0D5h,0C1h,0D6h
		db	 8Bh, 36h, 10h,0C0h,0C6h, 06h
		db	 0Ah,0A6h, 00h,0C6h, 06h, 0Ch
		db	0A6h, 00h
loc_2:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jz	loc_4			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:data_17e
		jc	loc_3			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:data_16e
		mov	bl,ds:data_40e
		xor	bh,bh			; Zero register
		mov	al,ds:data_53e[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	loc_3			; Jump if zero
		test	byte ptr ds:data_42e,80h
		jnz	loc_3			; Jump if not zero
		mov	al,[si+5]
		and	al,1Fh
		mov	ds:data_42e,al
loc_3:
		inc	byte ptr ds:data_40e
		add	si,10h
		jmp	short loc_2
loc_4:
		mov	si,ds:data_52e
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:data_42e,0FFh
		jz	loc_9			; Jump if zero
		mov	al,ds:data_42e
		push	ax
		and	al,1Fh
		call	word ptr cs:data_18e
		mov	bl,ah
		pop	ax
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		cmp	al,4
		jne	loc_5			; Jump if not equal
		add	bx,bx
		add	bx,bx
		mov	byte ptr ds:data_57e,24h	; '$'
		jmp	short loc_6
loc_5:
		mov	byte ptr ds:data_57e,25h	; '%'
loc_6:
		call	sub_6
		mov	ax,data_8
		add	ax,0Fh
		mov	bx,ax
		sub	ax,ds:data_51e
		jc	loc_7			; Jump if carry Set
		xchg	bx,ax
loc_7:
		mov	ax,ds:data_30e
		sub	ax,bx
		jnc	loc_8			; Jump if carry=0
		call	sub_5
		call	sub_5
		jmp	short loc_9
loc_8:
		call	sub_4
		call	sub_4
loc_9:
		test	byte ptr ds:data_34e,0FFh
		jz	loc_10			; Jump if zero
		jmp	loc_22
loc_10:
		test	byte ptr ds:data_35e,0FFh
		jnz	loc_14			; Jump if not zero
		call	word ptr cs:data_9
		and	al,0Fh
		jz	loc_11			; Jump if zero
		jmp	loc_22
loc_11:
		test	byte ptr ds:data_54e,0FFh
		jz	loc_12			; Jump if zero
		jmp	loc_22
loc_12:
		mov	byte ptr ds:data_35e,0FFh
		mov	byte ptr ds:data_37e,0FFh
		mov	byte ptr ds:data_36e,0FFh
		mov	byte ptr ds:data_38e,0
		mov	byte ptr ds:data_39e,0
		mov	ax,data_8
		add	ax,0Eh
		mov	bx,ax
		sub	ax,ds:data_51e
		jc	loc_13			; Jump if carry Set
		xchg	bx,ax
loc_13:
		mov	ax,ds:data_30e
		sub	ax,bx
		jnc	loc_14			; Jump if carry=0
		mov	byte ptr ds:data_36e,0
loc_14:
		add	byte ptr ds:data_33e,2
		and	byte ptr ds:data_33e,6
		test	byte ptr ds:data_37e,0FFh
		jz	loc_17			; Jump if zero
		inc	byte ptr ds:data_39e
		and	byte ptr ds:data_39e,3
		jz	loc_15			; Jump if zero
		jmp	loc_29
loc_15:
		mov	byte ptr ds:data_37e,0
		test	byte ptr ds:data_35e,80h
		jz	loc_16			; Jump if zero
		jmp	loc_29
loc_16:
		mov	byte ptr ds:data_35e,0
		jmp	loc_29
loc_17:
		mov	bl,ds:data_38e
		inc	byte ptr ds:data_38e
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:data_21e[bx]	;*
		jmp	loc_29
			                        ;* No entry point to code
		; Original emitted explicit DS: segment overrides (3E prefix) on several
		; mov instructions; TASM drops them. Replace with raw bytes from reference.
		db	34h, 0A3h, 3Eh, 0A3h, 3Eh, 0A3h, 3Eh, 0A3h, 48h, 0A3h, 48h, 0A3h
		db	43h, 0A3h, 43h, 0A3h, 43h, 0A3h, 1Bh, 0A3h, 0C6h, 06h, 05h, 0A6h
		db	7Fh, 0C6h, 06h, 07h, 0A6h, 7Fh, 0C6h, 06h, 0Fh, 0A6h, 00h, 0FEh
		db	06h, 0F0h, 0A5h, 80h, 26h, 0F0h, 0A5h, 3Fh, 0C3h

_312MAPST	endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_2		proc	near
		dec	byte ptr ds:data_31e
		and	byte ptr ds:data_31e,3Fh	; '?'
		retn
sub_2		endp

			                        ;* No entry point to code
		call	sub_2
		jmp	short loc_18
		db	0E8h,0E4h,0FFh,0EBh, 00h
loc_18:
		test	byte ptr ds:data_45e,0FFh
		jz	loc_19			; Jump if zero
		retn
loc_19:
		mov	ax,data_8
		add	ax,0Ch
		mov	bx,ax
		sub	ax,ds:data_51e
		jc	loc_20			; Jump if carry Set
		xchg	bx,ax
loc_20:
		mov	ax,ds:data_30e
		sub	ax,bx
		jnz	loc_21			; Jump if not zero
		retn
loc_21:
		pop	ax
		test	byte ptr ds:data_36e,0FFh
		jnz	loc_26			; Jump if not zero
		jmp	short loc_28
loc_22:
		test	byte ptr ds:data_54e,0FFh
		jz	loc_23			; Jump if zero
		jmp	loc_46
loc_23:
		dec	byte ptr ds:data_41e
		jnz	loc_24			; Jump if not zero
		mov	byte ptr ds:data_41e,2
		inc	byte ptr ds:data_33e
		and	byte ptr ds:data_33e,7
loc_24:
		mov	ax,data_8
		add	ax,12h
		mov	bx,ax
		sub	ax,ds:data_51e
		jnc	loc_25			; Jump if carry=0
		xchg	bx,ax
loc_25:
		sub	ax,ds:data_30e
		jnc	loc_27			; Jump if carry=0
		test	byte ptr ds:data_33e,0FFh
		jnz	loc_29			; Jump if not zero
loc_26:
		call	sub_5
		jnc	loc_29			; Jump if carry=0
		mov	byte ptr ds:data_45e,0FFh
		jmp	short loc_29
loc_27:
		cmp	byte ptr ds:data_33e,4
		jne	loc_29			; Jump if not equal
loc_28:
		call	sub_4
		jnc	loc_29			; Jump if carry=0
		mov	byte ptr ds:data_45e,0FFh
loc_29:
		mov	bl,ds:data_33e
		xor	bh,bh			; Zero register
		mov	dl,ds:data_25e[bx]
		xor	dh,dh			; Zero register
		mov	di,data_46e
		mov	cx,0Ch

locloop_30:
		mov	[di],dx
		add	di,2
		inc	dh
		loop	locloop_30		; Loop if cx > 0

		test	byte ptr ds:data_35e,0FFh
		jnz	loc_37			; Jump if not zero
		test	byte ptr ds:data_34e,0FFh
		jz	loc_31			; Jump if zero
		cmp	byte ptr ds:data_34e,1
		je	loc_36			; Jump if equal
		jmp	short loc_33
loc_31:
		call	word ptr cs:data_9
		and	al,1
		jnz	loc_37			; Jump if not zero
		mov	ax,data_8
		add	ax,12h
		mov	bx,ax
		sub	ax,ds:data_51e
		jc	loc_32			; Jump if carry Set
		xchg	bx,ax
loc_32:
		mov	ax,ds:data_30e
		sub	ax,bx
		jnc	loc_35			; Jump if carry=0
		dec	bx
		dec	bx
		mov	ax,ds:data_30e
		add	ax,7
		sub	ax,bx
		jnc	loc_37			; Jump if carry=0
		cmp	byte ptr ds:data_33e,6
		jne	loc_37			; Jump if not equal
		mov	byte ptr ds:data_34e,2
loc_33:
		mov	byte ptr ds:data_49e,0Ch
		mov	byte ptr ds:data_50e,0Dh
		test	byte ptr ds:data_33e,0FFh
		jnz	loc_34			; Jump if not zero
		call	sub_3
loc_34:
		jmp	short loc_37
loc_35:
		cmp	byte ptr ds:data_33e,2
		jne	loc_37			; Jump if not equal
		mov	byte ptr ds:data_34e,1
loc_36:
		mov	byte ptr ds:data_47e,0Eh
		mov	byte ptr ds:data_48e,0Fh
		cmp	byte ptr ds:data_33e,4
		jne	loc_37			; Jump if not equal
		call	sub_3
loc_37:
		mov	byte ptr ds:data_40e,0
		mov	di,0A610h
		mov	si,ds:data_52e
		mov	ax,ds:data_30e
		mov	cx,4

locloop_38:
		push	cx
		push	ax
		call	word ptr cs:data_17e
		pop	ax
		mov	ds:data_43e,bl
		jnc	loc_39			; Jump if carry=0
		add	di,6
		jmp	short loc_41
loc_39:
		mov	bl,ds:data_31e
		mov	cx,3

locloop_40:
		push	cx
		mov	[si],ax
		mov	[si+2],bl
		mov	dl,ds:data_43e
		mov	[si+3],dl
		mov	dl,[di]
		mov	[si+4],dl
		mov	byte ptr [si+5],0
		mov	dl,[di+1]
		mov	[si+6],dl
		add	di,2
		push	ax
		push	bx
		push	di
		mov	ax,[si+2]
		call	word ptr cs:data_16e
		mov	bl,ds:data_40e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_53e[bx],al
		add	si,10h
		inc	byte ptr ds:data_40e
		pop	di
		pop	bx
		pop	ax
		add	bl,2
		and	bl,3Fh			; '?'
		pop	cx
		loop	locloop_40		; Loop if cx > 0

loc_41:
		inc	ax
		inc	ax
		pop	cx
		loop	locloop_38		; Loop if cx > 0

		mov	word ptr [si],0FFFFh
		retn
			                        ;* No entry point to code
		add	al,[bx+di]
		add	[bp+di],al
		add	al,3
		add	[bx+di],al

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_3		proc	near
		mov	al,ds:data_31e
		add	al,3
		and	al,3Fh			; '?'
		mov	ds:data_29e,al
		mov	ds:data_27e,al
		mov	ax,ds:data_30e
		inc	ax
		call	word ptr cs:data_17e
		mov	ds:data_26e,bl
		mov	ax,ds:data_30e
		add	ax,7
		call	word ptr cs:data_17e
		mov	ds:data_28e,bl
		mov	al,ds:data_34e
		dec	al
		mov	cl,0Dh
		mul	cl			; ax = reg * al
		add	ax,0A552h
		mov	bx,ax
		call	word ptr cs:data_19e
		mov	byte ptr ds:data_34e,0
		retn
sub_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_4		proc	near
		cmp	byte ptr ds:data_30e,32h	; '2'
		stc				; Set carry flag
		jnz	loc_42			; Jump if not zero
		retn
loc_42:
		inc	byte ptr ds:data_30e
		clc				; Clear carry flag
		retn
sub_4		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_5		proc	near
		cmp	byte ptr ds:data_30e,11h
		stc				; Set carry flag
		jnz	loc_43			; Jump if not zero
		retn
loc_43:
		dec	byte ptr ds:data_30e
		clc				; Clear carry flag
		retn
sub_5		endp

		db	 00h, 00h, 15h, 00h, 32h, 04h
		db	 50h
		db	8 dup (0)
		db	 14h, 00h, 32h, 00h, 50h, 00h
		db	 00h, 00h, 00h, 00h, 00h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_6		proc	near
		mov	ax,ds:data_32e
		sub	ax,bx
		jnc	loc_44			; Jump if carry=0
		xor	ax,ax			; Zero register
loc_44:
		mov	ds:data_32e,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:data_15e
		pop	ax
		or	ax,ax			; Zero ?
		jz	loc_45			; Jump if zero
		retn
loc_45:
		mov	byte ptr ds:data_54e,0FFh
		mov	byte ptr ds:data_44e,0
		mov	byte ptr ds:data_34e,0
		jmp	word ptr cs:data_20e
sub_6		endp

loc_46:
		cmp	byte ptr ds:data_44e,28h	; '('
		jae	loc_51			; Jump if above or =
		mov	byte ptr ds:data_55e,0FFh
		inc	byte ptr ds:data_44e
		cmp	byte ptr ds:data_44e,15h
		jae	loc_50			; Jump if above or =
		test	byte ptr ds:data_44e,3
		jnz	loc_47			; Jump if not zero
		mov	byte ptr ds:data_57e,28h	; '('
loc_47:
		inc	byte ptr ds:data_33e
		and	byte ptr ds:data_33e,7
loc_48:
		mov	bx,data_25e
		mov	al,ds:data_33e
		xlat				; al=[al+[bx]] table
		xor	ah,ah			; Zero register
		mov	di,data_46e
		mov	cx,0Ch

locloop_49:
		mov	[di],ax
		add	di,2
		inc	ah
		loop	locloop_49		; Loop if cx > 0

		jmp	loc_37
loc_50:
		mov	byte ptr ds:data_33e,2
		jmp	short loc_48
loc_51:
		mov	byte ptr ds:data_56e,0FFh
		retn
			                        ;* No entry point to code
		xor	[bx+si],al
		or	al,0F4h
;*		add	ax,bp
		db	 01h,0E8h		;  Fixup - byte match
		add	cx,[si]
;*		add	bl,bh
		db	 00h,0FBh		;  Fixup - byte match
		movsw				; Mov [si] to es:[di]
		pop	ax
		add	dl,[bp+si]
		mov	bx,400h
		inc	cx
		db	 67h, 61h, 72h, 00h
		db	7 dup (0)
		db	2, 0
		db	27 dup (0)

seg_a		ends



		end	start
