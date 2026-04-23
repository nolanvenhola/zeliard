
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_318MAPA5                                лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_13e	equ	2000h			;*
data_14e	equ	201Fh			;*
data_15e	equ	202Ah			;*
data_16e	equ	2928h			;*
data_17e	equ	2F2Eh			;*
data_18e	equ	6028h			;*
data_19e	equ	6036h			;*
data_20e	equ	8E77h			;*
data_21e	equ	9893h			;*
data_22e	equ	9A00h			;*
data_23e	equ	0A39Fh			;*
data_24e	equ	0A3BBh			;*
data_25e	equ	0A442h			;*
data_26e	equ	0A495h			;*
data_27e	equ	0A52Fh			;*
data_28e	equ	0A581h			;*
data_29e	equ	0A583h			;*
data_30e	equ	0A599h			;*
data_31e	equ	0A59Ah			;*
data_32e	equ	0A59Bh			;*
data_33e	equ	0A59Ch			;*
data_34e	equ	0A5A1h			;*
data_35e	equ	0AEABh			;*
data_36e	equ	0B600h			;*
data_37e	equ	0C010h			;*
data_38e	equ	0E939h			;*
data_39e	equ	0ED20h			;*
data_40e	equ	0FF75h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_318MAPA5	proc	far

start:
		popf				; Pop flags
		add	ax,0
		cmp	al,0A2h
;*		and	word ptr ds:[0][di],0
		db	 81h,0A5h, 00h, 00h, 00h, 00h	;  Fixup - byte match
		db	40 dup (0)
		db	 3Eh,0A0h, 8Eh,0A0h,0DEh,0A0h
		db	 2Eh,0A1h, 7Eh,0A1h,0CEh,0A1h
		db	 19h,0A2h, 01h, 01h, 02h, 03h
		db	 04h, 01h, 05h, 06h, 0Ch, 00h
		db	 01h, 00h, 00h, 0Ah, 0Bh, 01h
		db	 00h, 00h, 08h, 09h, 01h, 0Eh
		db	 00h, 00h, 00h, 01h, 07h, 0Dh
		db	 0Fh, 10h, 01h, 00h, 00h, 01h
		db	 02h, 01h, 03h, 04h, 11h, 12h
		db	 01h, 00h, 00h, 13h, 00h, 01h
		db	 18h, 19h, 1Eh, 00h, 01h, 16h
		db	 17h, 0Ah, 1Dh, 01h, 00h, 15h
		db	 1Ch, 09h, 01h, 20h, 00h, 00h
		db	 00h, 01h, 00h, 14h, 1Ah, 1Bh
		db	 01h, 07h, 1Fh, 0Fh, 10h, 01h
		db	 28h, 00h, 2Fh, 30h, 01h, 26h
		db	 27h, 2Dh, 2Eh, 01h, 13h, 00h
		db	 18h, 22h, 01h
data_4		dw	201h			; Data table (indexed access)
		db	 03h, 04h, 01h, 11h, 12h, 16h
		db	 21h, 01h
		db	 24h, 25h
data_5		dw	2C2Bh			; Data table (indexed access)
		db	 01h, 34h, 00h, 00h, 00h, 01h
		db	 00h
		db	23h
data_6		dw	2A29h			; Data table (indexed access)
		db	 01h, 32h, 33h, 35h, 36h, 01h
		db	 00h, 31h, 00h, 00h, 01h, 00h
		db	 00h, 02h, 00h, 01h, 04h, 00h
		db	 39h, 3Ah, 01h, 3Dh, 3Eh, 3Dh
		db	 42h, 01h, 3Dh, 45h, 48h, 49h
		db	 01h, 4Dh, 4Eh, 52h, 53h, 01h
		db	 00h, 00h, 00h, 01h, 01h, 00h
		db	 03h, 37h, 38h, 01h
		db	 3Bh, 3Ch, 3Fh
data_7		db	40h
		db	 01h, 43h, 44h, 46h, 47h, 01h
		db	 4Bh, 4Ch, 50h, 51h, 01h, 00h
		db	 4Ah, 00h, 4Fh, 01h, 00h, 03h
		db	 54h, 38h, 01h
		db	 57h, 3Ch, 58h, 40h
data_8		db	1			; Data table (indexed access)
		db	 59h, 44h, 46h, 47h, 01h, 55h
		db	 56h, 00h, 00h, 01h, 00h, 03h
		db	 5Dh, 38h, 01h, 58h, 3Ch, 58h
		db	 40h, 01h, 00h, 00h, 5Bh, 5Ch
		db	 01h, 00h, 00h, 00h, 5Ah, 01h
		db	 04h, 00h, 61h, 3Ah, 01h, 62h
		db	 3Eh, 3Dh, 42h, 01h, 00h, 03h
		db	 5Eh, 38h, 01h, 5Fh, 60h, 58h
		db	 40h, 01h, 04h, 00h, 67h, 68h
		db	 01h, 00h, 03h, 65h, 66h, 01h
		db	 00h, 00h, 63h, 64h, 01h, 6Ch
		db	 6Dh, 6Fh, 70h, 01h, 6Ah, 6Bh
		db	 69h, 6Eh, 01h, 00h, 69h, 00h
		db	 00h, 01h, 71h, 45h, 72h, 73h
		db	 01h, 00h, 69h, 00h, 47h, 01h
		db	 74h, 75h, 77h, 78h, 01h, 00h
		db	 4Ch, 76h, 51h, 01h, 04h, 00h
		db	 83h, 84h, 01h, 86h, 87h, 71h
		db	 88h, 01h, 89h, 8Ah, 85h, 71h
		db	 01h, 00h, 00h, 8Bh, 00h, 01h
		db	 8Ch, 8Dh, 77h, 8Eh, 01h, 7Dh
		db	 03h, 81h, 82h, 01h, 80h, 71h
		db	 85h, 80h, 01h, 00h, 85h, 00h
		db	 47h, 01h, 00h, 00h, 41h, 79h
		db	 01h, 7Bh, 7Ch, 7Fh, 80h, 01h
		db	 00h, 7Ah, 00h, 7Eh, 01h, 00h
loc_1:
		test	ax,[bx+si]
		add	[bx+di],al
		add	al,0
		cmpsw				; Cmp [si] to es:[di]
		add	[bx+di],al
		lodsb				; String [si] to al
		lodsw				; String [si] to ax
		mov	al,0B1h
		add	ds:data_36e[si],si
		add	[bx+di],al
		mov	ds:data_20e[di],cs
		add	ds:data_22e[si],dx
		add	[bx+di],ax
		mov	al,ds:data_34e
		cmpsb				; Cmp [si] to es:[di]
		add	ss:data_35e[bp+si],bp
		scasw				; Scan es:[di] for ax
		add	ss:data_6[bp+si],si
		mov	ch,1
		add	[si+76h],cl
		push	cx
		add	ss:data_21e[bp+si],dx
		cwd				; Word to double word
		add	ss:data_23e[bp],bx
		movsb				; Mov [si] to es:[di]
		add	data_5[bx+si],bp
		add	[bx+di],al
		nop
		xchg	cx,ax
		xchg	si,ax
		xchg	di,ax
		add	data_4[si],bx
		mov	byte ptr ds:[1],al
		pop	word ptr [bx+si]
		xchg	bp,ax
		add	[bx+si],ax
		db	 9Bh, 00h, 00h, 01h, 00h, 00h
		db	0C4h,0C5h, 01h, 04h,0CAh,0CFh
		db	0D0h, 01h,0ACh,0ADh,0B0h,0B1h
		db	 01h,0B4h, 00h,0B6h, 00h, 01h
		db	 8Ch, 8Dh, 77h, 8Eh, 01h,0BCh
		db	0BDh,0C2h,0C3h, 01h,0C9h, 03h
		db	 00h,0CEh, 01h, 00h,0D1h, 00h
		db	0D2h, 01h, 00h,0B3h, 00h,0B5h
		db	 01h, 00h, 00h, 00h,0B8h, 01h
		db	 00h, 00h, 00h,0B7h, 01h,0BAh
		db	0BBh,0C0h,0C1h, 01h, 00h,0B9h
		db	0BEh,0BFh, 01h,0C7h,0C8h,0CCh
		db	0CDh, 01h, 00h,0C6h, 00h,0CBh
		db	 01h, 00h, 00h, 00h, 07h, 8Bh
		db	 36h, 10h,0C0h,0C6h, 06h, 99h
		db	0A5h, 00h
loc_2:
;*		cmp	word ptr [si],0FFFFh
		db	 83h, 3Ch,0FFh		;  Fixup - byte match
		jz	loc_4			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:data_19e
		jc	loc_3			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:data_18e
		mov	bl,ds:data_30e
		xor	bh,bh			; Zero register
		mov	al,ds:data_39e[bx]
		mov	[di],al
loc_3:
		inc	byte ptr ds:data_30e
		add	si,10h
		jmp	short loc_2
loc_4:
		mov	si,ds:data_37e
		mov	word ptr [si],0FFFFh
		inc	byte ptr ds:data_33e
		mov	al,ds:data_33e
		mov	bx,data_24e
		xlat				; al=[al+[bx]] table
		or	al,al			; Zero ?
		jns	loc_5			; Jump if not sign
		jmp	loc_16
loc_5:
		mov	ds:data_32e,al
		mov	al,ds:data_32e
		mov	dx,10h
		cmp	al,3
		jb	loc_6			; Jump if below
		mov	dx,0Dh
loc_6:
		mov	ds:data_28e,dx
		mov	byte ptr ds:data_30e,0
		mov	bl,ds:data_32e
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	di,cs:data_26e[bx]
		mov	bp,cs:data_27e[bx]
		mov	ax,ds:data_28e
		mov	si,ds:data_37e
		mov	cx,6
loc_7:
		push	cx
		push	ax
		call	word ptr cs:data_19e
		pop	ax
		mov	ds:data_31e,bl
		jnc	loc_10			; Jump if carry=0
		mov	cx,8

locloop_8:
		rol	byte ptr ds:[bp],1	; Rotate
		jnc	loc_9			; Jump if carry=0
		inc	di
loc_9:
		loop	locloop_8		; Loop if cx > 0

		jmp	short loc_13
loc_10:
		xor	cl,cl			; Zero register
loc_11:
		push	cx
		push	ax
		rol	byte ptr ds:[bp],1	; Rotate
		jnc	loc_12			; Jump if carry=0
		mov	[si],ax
		add	cl,cl
		mov	al,ds:data_29e
		add	al,cl
		and	al,3Fh			; '?'
		mov	[si+2],al
		mov	al,ds:data_31e
		mov	[si+3],al
		mov	al,[di]
		mov	ah,al
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	[si+4],al
		and	ah,0Fh
		mov	[si+6],ah
		mov	byte ptr [si+5],0
		push	di
		mov	ax,[si+2]
		call	word ptr cs:data_18e
		mov	bl,ds:data_30e
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:data_39e[bx],al
		add	si,10h
		inc	byte ptr ds:data_30e
		pop	di
		inc	di
loc_12:
		pop	ax
		pop	cx
		inc	cl
		cmp	cl,8
		jne	loc_11			; Jump if not equal
loc_13:
		inc	bp
		inc	ax
		inc	ax
		pop	cx
		loop	locloop_14		; Loop if cx > 0

		jmp	short loc_15

locloop_14:
		jmp	loc_7
loc_15:
		mov	word ptr [si],0FFFFh
		retn
loc_16:
		mov	dx,0A290h
		push	dx
		mov	ah,al
		and	al,0F0h
		cmp	al,80h
		je	loc_19			; Jump if equal
		cmp	al,0C0h
		je	loc_20			; Jump if equal
		cmp	al,0E0h
		je	loc_18			; Jump if equal
		cmp	ah,0FFh
		je	loc_17			; Jump if equal
		retn
loc_17:
		mov	data_7,0
		retn
loc_18:
		mov	byte ptr ds:data_40e,38h	; '8'
		retn
loc_19:
		and	ah,0Fh
		xor	bx,bx			; Zero register
		add	ah,ah
		mov	bl,ah
		mov	dx,ds:data_25e[bx]
		push	si
		push	dx
		mov	bx,0E1Eh
		mov	cx,3410h
		mov	al,0FFh
		call	word ptr cs:data_13e
		pop	si
		lodsw				; String [si] to ax
		add	ax,3Ah
		mov	bx,ax
		mov	cl,22h			; '"'
		call	word ptr cs:data_15e
		pop	si
		retn
loc_20:
		mov	al,0FEh
		push	ds
		pop	es
		mov	di,data_38e
		mov	cx,2

locloop_21:
		push	cx
		push	di
		mov	cx,1Ah
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	di
		add	di,1Ch
		pop	cx
		loop	locloop_21		; Loop if cx > 0

		retn
		db	10 dup (0)
		db	 80h, 00h, 00h
		db	28 dup (0)
		db	0C0h, 00h, 01h, 01h, 02h, 02h
		db	 03h, 03h, 03h, 03h, 03h, 81h
		db	 03h, 03h, 03h
		db	26 dup (3)
		db	0C0h, 03h, 03h, 03h, 04h, 04h
		db	 05h, 82h, 05h, 05h
		db	28 dup (5)
		db	0C0h, 05h, 05h, 06h, 06h, 07h
		db	0E0h, 08h, 08h, 09h, 09h, 0Ah
		db	 0Ah, 0Ah,0FFh, 48h,0A4h, 63h
		db	0A4h, 7Ah,0A4h, 08h, 00h
		db	'Finally, you reached me.'
		db	0FFh, 18h, 00h
		db	'I enjoyed your show.'
		db	0FFh, 08h, 00h
		db	'Come on!  I\ll kill you.'
		db	0FFh,0ABh,0A4h,0B1h,0A4h,0BAh
		db	0A4h,0C4h,0A4h,0CFh,0A4h,0DBh
		db	0A4h,0E8h,0A4h,0F3h,0A4h,0FFh
		db	0A4h
loc_22:
		push	cs
		movsw				; Mov [si] to es:[di]
		pop	ds
		movsw				; Mov [si] to es:[di]
		add	ax,403h
		add	al,[bx+si]
		add	[di],cx
		push	cs
		or	cx,[si]
		push	es
		pop	es
		or	cl,[bx+si]
		or	[bx+si],bx
		push	ss
		pop	ss
		adc	dl,[bp+di]
		adc	al,15h
		adc	[bx+si],dx
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		and	bx,ds:data_14e
		and	[bp+si],sp
		sbb	[bp+si],bx
		sbb	bx,[si]
		sbb	ax,2327h
		push	ds
		and	al,25h			; '%'
		and	bl,es:[bx+di]
		sbb	bl,[bp+di]
		sbb	al,1Dh
		sub	bp,[bp+si]
		and	bx,ds:data_16e
		and	bl,es:[bx+di]
		sbb	bl,[bp+di]
		sbb	al,1Dh
		and	bx,ds:data_17e
		and	bl,es:[bx+di]
		sub	al,2Dh			; '-'
		sbb	al,1Dh
		xor	dh,[di]
		push	ds
		xor	[si],si
		aaa				; Ascii adjust
		cmp	[bx+di],bx
		xor	[bp+di],dh
		cmp	ss:[si+42h],al
		inc	bx
		inc	bp
		push	ds
		aas				; Ascii adjust
		inc	ax
		inc	cx
		cmp	[bx+di],bx
		cmp	bh,[bp+di]
		cmp	al,3Eh			; '>'
		cmp	ax,5554h
		push	dx
		push	bx
		dec	di
		push	ax
		push	cx
		dec	dx
		dec	bx
		dec	sp
		dec	bp
		dec	si
		sbb	[bp+47h],ax
		dec	ax
		dec	cx
		db	'ace`bd[\]^NVWXYZE'
		db	0A5h, 4Bh,0A5h, 51h,0A5h, 57h
		db	0A5h, 5Dh,0A5h, 63h,0A5h, 57h
		db	0A5h, 69h,0A5h, 6Fh,0A5h, 75h
		db	0A5h, 7Bh,0A5h, 00h, 00h, 04h
		db	 0Ch, 08h, 18h, 00h, 00h, 0Ch
		db	 0Ch, 38h, 18h, 00h, 04h, 0Ch
		db	 3Ch, 18h, 08h, 00h, 00h, 04h
		db	 7Ch, 7Ch, 00h, 00h, 00h, 14h
		db	 7Ch, 7Ch, 00h, 00h, 20h, 24h
		db	 7Ch, 7Ch, 00h, 00h, 00h, 30h
		db	 7Ch, 7Ch, 00h, 00h
		db	' p||', 8, '``p||'
		db	 00h, 00h,0E0h,0E0h, 7Ch, 7Ch
		db	 00h, 10h, 00h, 01h,0FAh, 00h
		db	0C8h, 00h, 05h,0FFh, 8Eh,0A5h
		db	 00h, 00h, 11h,0BBh, 02h, 07h
		db	 4Ah, 61h, 73h, 68h, 69h, 69h
		db	 6Eh, 00h, 00h, 00h, 00h

_318MAPA5	endp

seg_a		ends



		end	start
