
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				ZR2_51	                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   22-Mar-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    9          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	0AABBh			;*
data_17e	equ	2208h			;*
data_18e	equ	2722h			;*
data_19e	equ	278Ah			;*
data_20e	equ	27BAh			;*
data_21e	equ	2957h			;*
data_22e	equ	3288h			;*
data_23e	equ	4075h			;*
data_24e	equ	59AAh			;*
data_25e	equ	80AAh			;*
data_26e	equ	823Fh			;*
data_27e	equ	8802h			;*
data_28e	equ	8A82h			;*
data_29e	equ	0A0AAh			;*
data_30e	equ	0A2AAh			;*
data_31e	equ	0AA27h			;*
data_32e	equ	0AA82h			;*
data_33e	equ	0AAA0h			;*
data_34e	equ	0ABAAh			;*
data_35e	equ	0BAFFh			;*
data_36e	equ	0D3CDh			;*
data_37e	equ	0EAAAh			;*
data_38e	equ	0FBFEh			;*
data_39e	equ	0FF05h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

ZR2_51		proc	far

start:
		add	ds:data_31e,al
		sub	[di+32h],dx
		add	[bp+di],dh
		push	word ptr [di]
		db	0DDh, 37h,0D5h, 43h,0D3h, 4Bh
		db	0CDh
		db	 4Dh, 5Dh
data_2		dw	offset sub_4
data_3		dw	offset sub_2
		db	 65h,0A0h, 66h, 80h
data_4		dw	569h
		db	 6Ch, 2Ah, 71h, 0Ah
data_5		db	73h			; Data table (indexed access)
		db	 40h, 76h, 50h, 89h
data_6		db	4			; Data table (indexed access)
		db	 91h, 10h
data_7		db	93h			; Data table (indexed access)
		db	 54h, 97h,0A8h, 98h, 20h, 99h
		db	 08h
data_8		dw	159Bh			; Data table (indexed access)
		db	 9Ch, 57h, 9Dh, 75h,0A3h, 28h
		db	0A5h, 7Fh,0A6h,0EAh,0B1h, 45h
		db	0C4h, 8Ah,0CBh, 82h,0CCh, 88h
		db	0D2h,0A2h,0DBh, 41h,0E2h, 5Fh
		db	0E9h,0F5h,0F2h,0D0h,0FFh,0FFh
		db	 32h, 50h, 33h, 49h,0FDh, 32h
		db	 02h,0D5h, 29h, 48h, 5Dh, 32h
		db	 02h,0D0h, 32h, 48h, 0Dh, 32h
		db	 00h, 03h,0FFh,0D3h, 33h, 48h
		db	0FDh, 3Fh,0C0h, 03h, 00h,0D0h
		db	 32h, 48h, 0Dh, 00h,0C0h, 03h
		db	 00h,0D0h, 32h, 48h, 0Dh, 00h
		db	0C0h, 03h, 05h,0D0h
data_9		dw	4829h			; Data table (indexed access)
		db	 5Dh, 00h,0C0h, 03h, 04h,0D0h
		db	 27h, 48h,0ADh, 00h,0C0h, 33h
		db	 00h,0D0h, 29h, 48h, 5Fh,0FFh
		db	0FDh,0D5h, 55h, 50h, 27h, 4Ah
		db	0ADh,0D0h, 32h, 00h, 29h, 48h
		db	 54h, 00h, 0Dh,0D3h, 32h, 00h
		db	 27h, 48h,0A8h, 00h,0CDh

locloop_3:
		rol	word ptr [di],cl	; Rotate
		sub	[bx],ax
		push	sp
		sub	[bx+si],dx
		jnz	loc_4			; Jump if not zero
;*		aad	29h			; ')' undocumented inst
		db	0D5h, 29h		;  Fixup - byte match
		sub	dx,[bx+si-33h]
		ror	word ptr [bp+si],cl	; Rotate
		daa				; Decimal adjust
		adc	al,0EAh
		daa				; Decimal adjust
		xor	sp,ds:data_36e[bx+si]
		add	ax,729h
		push	sp
		sub	ds:data_21e,cx
		das				; Decimal adjust
		push	ax
		int	0D3h			; ??INT Non-standard interrupt
		or	ah,[bx]
		pop	es
		test	al,27h			; '''
		push	cs
		stosw				; Store ax to es:[di]
		daa				; Decimal adjust
		das				; Decimal adjust
		mov	al,ds:data_36e
		add	ax,729h
		push	ax
		sub	[bp+si],ax
		pop	bp
		sub	[bx+di],cx
		push	di
		sub	[bx+si],ax
		pop	bp
		sub	[si],bp
		push	ax
		int	0D3h			; ??INT Non-standard interrupt
		or	ah,[bx]
		pop	es
		mov	al,ds:data_18e
		or	al,0ABh
		daa				; Decimal adjust
		xor	ds:data_36e[bx+si],ah
		add	ax,629h
		push	sp
		inc	ax
		add	[bx+di],bp
		pop	es
		jnz	loc_5			; Jump if not zero
		add	si,[bx+29h]
		das				; Decimal adjust
		push	ax
loc_4:
		int	0D3h			; ??INT Non-standard interrupt
		or	ah,[bx]
		push	es
		test	al,20h			; ' '
;*		loopnz	locloop_6		;*Loop if zf=0, cx>0

		db	0E0h, 27h		;  Fixup - byte match
		push	es
		stosw				; Store ax to es:[di]
		daa				; Decimal adjust
		add	bp,ss:data_20e[bp+di]
		das				; Decimal adjust
		mov	al,ds:data_36e
		add	ax,629h
		push	ax
		add	[bx+si],dh
		sub	[bp+di],ax
;*		aad	29h			; ')' undocumented inst
		db	0D5h, 29h		;  Fixup - byte match
		add	[di+29h],bl
		add	dx,[bx+29h]
loc_5:
		xor	[bx+si-33h],dl
		ror	word ptr [bp+si],cl	; Rotate
		daa				; Decimal adjust
		push	es
;*		mov	al,ah
		db	 88h,0E0h		;  Fixup - byte match
		cmp	ss:data_19e[bp+si],bp
		add	ax,27FBh
;*		add	dl,ch
		db	 00h,0EAh		;  Fixup - byte match
		stosb				; Store al to es:[di]
		sti				; Enable interrupts
		mov	dx,2F27h
		mov	al,ds:data_36e
		add	ax,629h
		add	al,40h			; '@'
		pop	bp
;*		aad	5			; undocumented inst
		db	0D5h, 05h		;  Fixup - byte match
		ja	loc_8			; Jump if above
		jnz	loc_7			; Jump if not zero
;*		aad	29h			; ')' undocumented inst
		db	0D5h, 29h		;  Fixup - byte match
		add	dx,[bx+55h]
		ja	loc_10			; Jump if above
		sub	[bx],bp
		push	ax
		int	0D3h			; ??INT Non-standard interrupt
		add	ah,[bx]
		push	es
		sbb	[bx+si],al
		mov	si,2AAh
		daa				; Decimal adjust
		add	ss:data_37e[bp],ch
		mov	dx,0BEAEh
		daa				; Decimal adjust
		add	ss:data_35e[bp+di],di
;*		jmp	far ptr loc_27		;*
		db	0EAh
		dw	2E27h, 0CDA0h		;  Fixup - byte match
			                        ;* No entry point to code
		rol	word ptr [di],cl	; Rotate
		sub	data_4,ax
		db	 36h,0D5h, 0Dh, 5Fh, 55h, 57h
		db	0F5h, 75h, 29h, 00h,0DDh, 29h
		db	 01h, 57h, 77h, 29h, 30h, 50h
		db	0CDh,0D3h, 0Ah, 27h, 06h, 32h
		db	 00h, 36h, 7Ah, 0Eh, 27h, 04h
		db	0BFh,0BEh,0EAh, 27h, 00h,0FFh
		db	0EBh, 27h, 30h,0A0h,0CDh
loc_7:
		rol	word ptr [di],cl	; Rotate
		sub	data_8,ax
loc_8:
		push	ss
loc_9:
;*		aad	0Dh			; undocumented inst
		db	0D5h, 0Dh		;  Fixup - byte match
loc_10:
		push	bp
		jge	$+5Fh			; Jump if > or =
		call	di			;*
		sub	[bx+si],ax
		jge	loc_9			; Jump if > or =
;*		aad	57h			; 'W' undocumented inst
		db	0D5h, 57h		;  Fixup - byte match
;*		jg	loc_11			;*Jump if >
		db	 7Fh,0F5h		;  Fixup - byte match
;*		jnz	loc_12			;*Jump if not zero
		db	 75h, 29h		;  Fixup - byte match
		das				; Decimal adjust
		push	ax
		int	0D3h			; ??INT Non-standard interrupt
		or	ah,[bx]
		add	ax,0A0h
		adc	[bx+di],al
		lahf				; Load ah from flags
		or	ax,6A55h
		daa				; Decimal adjust
		add	ds:data_34e[bx],bh
		mov	di,data_1e
;*		jmp	far ptr loc_2		;*
		db	0EAh
		dw	0FFBBh, 27ABh		;  Fixup - byte match
			                        ;* No entry point to code
		das				; Decimal adjust
		mov	al,ds:data_36e
		add	ax,529h
		push	ax
		inc	ax
		add	[si],al
		adc	ax,7D0Fh
		xlat				; al=[al+[bx]] table
		push	bp
		pop	di
		cmc				; Complement carry
		push	bp
		db	0DFh,0FFh,0DFh, 75h, 5Fh,0A5h
		db	 00h, 55h, 57h, 29h, 2Eh, 50h
		db	0CDh,0D3h, 0Ah, 27h, 04h,0A2h
		db	 28h, 40h, 00h,0BCh, 1Bh, 01h
		db	0EFh,0B9h,0BAh,0FAh,0FAh,0FBh
		db	0BAh,0FFh,0EFh,0BAh,0FEh,0FFh
		db	0EEh,0BAh, 27h, 01h,0BAh, 27h
		db	 2Bh,0A0h,0CDh,0D3h, 05h, 29h
		db	 04h, 41h, 30h, 80h, 00h, 0Fh
		db	0FFh,0C3h
data_12		db	0F5h
		db	0D1h, 5Dh, 5Fh,0FDh,0D7h,0D7h
		db	0FFh
		db	 5Dh, 77h, 33h
data_13		db	0			; Data table (indexed access)
		db	 9Ch, 00h, 29h, 2Fh, 50h,0CDh
		db	0D3h, 0Ah, 27h, 04h, 80h, 28h
		db	 32h, 01h, 02h, 80h, 6Ah,0A0h
		db	0FAh,0AFh,0BFh,0ABh,0ABh,0BFh
		db	0EAh,0BFh,0FFh,0BFh,0FFh,0FEh
		db	 27h, 00h,0FFh, 27h, 2Ch,0A0h
		db	0CDh,0D3h

ZR2_51		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3		proc	near
		add	ax,429h
		inc	ax
		adc	[bp+si],dh
		add	[di],al
		xchg	ds:data_23e[bx+si],ax
		pop	bp
		xlat				; al=[al+[bx]] table
		xlat				; al=[al+[bx]] table
		xor	ax,[bp+si]
		db	0DFh,0FFh, 7Fh,0D5h, 75h, 29h
		db	 00h, 5Dh, 29h, 2Ch, 50h,0CDh
		db	0D3h, 0Ah, 27h, 03h, 0Ah, 80h
loc_13:
		add	byte ptr ds:[500h],al
		pop	word ptr ds:[806Ah][bx+di]
		sub	ch,byte ptr ss:[0FBBBh][bp+si]
		scasw				; Scan es:[di] for ax
		db	0FFh,0EAh,0EFh,0FFh,0BBh,0EAh
		db	 27h, 00h,0EFh,0EAh, 27h, 2Ch
		db	0A0h,0CDh,0D3h, 05h, 29h, 03h
		db	 15h, 40h, 00h, 02h, 00h, 0Bh
		db	 8Fh, 81h
loc_14:
		jnz	$+42h			; Jump if not zero
loc_15:
		jge	loc_13			; Jump if > or =
		pop	di
		xor	ax,[bp+di]
		jg	loc_14			; Jump if >
;*		push	di
		db	0FFh,0F7h		;  Fixup - byte match
		jg	loc_15			; Jump if >
		sub	[di],bp
		push	ax
		int	0D3h			; ??INT Non-standard interrupt
		or	ah,[bx]
		add	cx,[bp+si]
		xor	byte ptr [bp+si],1
		pop	ss
		pop	word ptr ds:data_26e[bx+di]
;*		jmp	far ptr loc_28		;*
sub_3		endp

		db	0EAh
		dw	0AFAAh, 0EEFFh		;  Fixup - byte match
		db	0FFh,0FEh,0FBh,0FBh,0EBh,0ABh
		db	0ABh,0EFh,0FEh,0FAh,0FAh, 27h
		db	 01h,0AEh, 27h, 27h,0A0h,0CDh
		db	0D3h, 05h, 29h, 03h, 32h, 02h
		db	 96h, 7Dh,0F3h, 80h, 3Dh,0C2h
		db	0FFh,0DDh, 5Fh, 33h, 03h,0FDh
		db	0DFh,0DDh, 7Fh, 33h, 00h,0DFh
		db	 7Dh, 55h, 57h,0F5h, 75h, 29h
		db	 27h, 50h,0CDh,0D3h, 0Ah, 27h
		db	 03h, 32h, 03h, 01h, 53h,0C0h
		db	 02h, 80h,0FFh,0EAh,0AFh,0FFh
		db	0FEh,0FFh,0FBh,0EFh,0FFh
loc_16:
		jmp	short loc_16
			                        ;* No entry point to code
		xor	ax,[bx+si]
		cli				; Disable interrupts
		cli				; Disable interrupts
		daa				; Decimal adjust
		sub	al,0A0h
		int	0D3h			; ??INT Non-standard interrupt
		add	ax,29h
		push	sp
		add	[si+32h],dx
		add	ax,[bx]
		clc				; Clear carry flag
		pop	es
		sbb	[bx+si],al
		xor	cx,[bp+di]
		std				; Set direction flag
;*		aad	29h			; ')' undocumented inst
		db	0D5h, 29h		;  Fixup - byte match
		sub	al,50h			; 'P'
		int	0D3h			; ??INT Non-standard interrupt
		or	ah,[bx]
		add	[bp+si],ax
		stosb				; Store al to es:[di]
		xor	al,[bp+di]
		add	ax,0FFE6h
;*		call	sub_1			;*
		db	0E8h, 00h,0FEh		;  Fixup - byte match
		mov	si,33AFh
		add	al,0BFh
		db	0FFh,0BFh,0FFh,0FAh, 27h, 01h
		db	0AEh, 27h, 29h,0A0h,0CDh,0D3h
		db	 05h, 29h, 01h, 05h, 40h, 32h
		db	 03h, 03h, 7Eh, 7Fh,0E8h, 00h
		db	0FFh,0FEh, 3Eh, 33h, 08h,0F5h
		db	 7Dh, 55h, 5Fh,0D5h
		db	 29h, 29h
loc_17:
		push	ax
		int	0D3h			; ??INT Non-standard interrupt
		or	ah,[bx]
		add	[bp+si],ax
		xor	al,[bp+si]
		xor	byte ptr [bp+si],1
		adc	ax,62h
		jg	loc_17			; Jump if >
		or	ax,733h
		mov	di,data_38e
		cli				; Disable interrupts
;*		jmp	far ptr loc_26		;*
		db	0EAh
		dw	2A27h, 0CDA0h		;  Fixup - byte match
			                        ;* No entry point to code
		rol	word ptr [di],cl	; Rotate
		sub	[bx+di],ax
		xor	al,[bp+si]
		push	bp
		adc	al,0
		inc	cx
		inc	sp
		adc	ds:data_39e,ax
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		sbb	ax,0A33h
		db	0DFh,0F5h, 9Dh, 01h, 29h, 11h
		db	 75h, 29h, 02h, 59h, 29h, 0Eh
		db	 50h,0CDh,0D3h, 0Ah, 27h, 01h
		db	 00h,0A0h, 00h, 02h, 00h, 2Ah
		db	0A0h, 20h, 82h, 28h, 02h, 0Ah
		db	0FFh,0EFh, 1Dh, 33h, 0Bh, 27h
		db	 15h, 6Ah, 27h, 02h,0A8h, 27h
		db	 0Eh,0A0h,0CDh,0D3h, 04h, 29h
		db	 00h, 54h, 04h, 32h, 00h, 63h
		db	 00h, 55h, 01h, 45h, 5Fh,0D5h
		db	 41h,0F4h, 5Eh, 0Ch, 1Eh
loc_18:
		xor	cx,[bp+di]
		sub	[di],dx
		jnz	$+2Bh			; Jump if not zero
		add	bl,[bx+di+29h]
		push	cs
		push	ax
		int	0D3h			; ??INT Non-standard interrupt
		or	ch,ds:data_30e[bx+si]
		xor	al,[bp+di]
		test	al,0Ah
		sub	ah,[bx]
		add	ds:data_25e[bx+si],ah
		scasw				; Scan es:[di] for ax
		db	0FEh, 33h, 0Ah,0AAh,0EFh, 27h
		db	 05h,0ABh, 27h, 0Ch, 3Ah, 27h
		db	 02h,0B0h, 27h, 0Eh,0A0h,0CDh
		db	0D3h, 05h, 55h, 32h, 03h, 10h
		db	 05h, 40h, 01h, 55h, 79h, 55h
		db	 50h, 5Fh,0DCh, 44h,0FEh, 33h
		db	 0Bh,0F7h,0FFh,0D7h, 5Fh,0E9h
		db	 00h,0D5h, 29h, 08h, 57h, 29h
		db	 02h, 54h,0BDh, 29h, 02h, 72h
		db	 29h, 0Eh, 50h,0CDh,0D3h, 0Ah
		db	0A0h, 32h, 03h, 20h, 02h, 00h
		db	 82h,0AAh,0A8h,0AAh,0A0h, 2Ah
		db	0AAh, 2Ah,0ACh, 7Fh, 33h, 08h
		db	0FEh,0BEh, 27h, 15h,0DEh, 27h
		db	 02h,0E4h, 27h, 0Eh,0A0h,0CDh
		db	0D3h, 00h, 40h, 10h, 32h, 02h
		db	 01h, 05h, 40h, 01h, 55h, 50h
		db	 75h, 50h, 15h,0F5h, 05h, 58h
		db	 33h, 09h,0DFh, 33h, 01h,0DFh
		db	 75h,0FFh,0F7h,0F5h,0D5h, 29h
		db	 01h, 57h, 29h, 09h, 6Fh, 55h
		db	 54h, 29h, 00h,0C9h, 29h, 0Eh
		db	 50h,0CDh,0D3h, 32h, 06h,0A0h
		db	 00h, 0Ah, 28h,0A0h,0AAh,0A0h
		db	 0Ah,0AAh, 82h,0A9h, 7Fh, 33h
		db	 0Ah,0BAh,0BAh, 27h, 05h,0AEh
		db	 27h, 04h,0EAh, 27h, 04h,0B7h
		db	0AAh,0A0h, 0Ah,0ABh, 92h, 27h
		db	 0Eh,0A0h,0CDh,0D3h, 32h, 05h
		db	 01h, 50h, 00h, 01h, 55h, 01h
		db	0FDh, 40h, 05h, 5Dh, 41h, 57h
		db	0BFh, 8Fh, 33h, 0Ah, 5Fh,0FFh
		db	0DFh,0FDh, 55h,0FDh, 7Fh, 29h
		db	 03h, 75h, 29h, 07h, 3Fh,0D5h
		db	 00h, 01h, 57h, 01h, 29h, 0Eh
		db	 50h,0CDh,0D3h, 32h, 05h, 02h
		db	 80h, 00h, 0Ah,0AAh, 02h,0AAh
		db	 80h, 00h,0AAh,0A0h,0AAh,0BFh
		db	 03h, 33h, 09h,0AAh,0FFh, 27h
		db	 07h,0EAh, 27h, 09h,0D7h,0EAh
		db	 02h, 00h, 2Ch, 46h, 27h, 0Eh
		db	0A0h,0CDh,0D3h, 32h, 05h, 01h
		db	 40h, 00h, 05h, 54h, 15h,0F1h
		db	 40h, 01h, 55h, 51h, 55h,0DFh
		db	 01h, 33h, 0Ch,0F5h,0FDh, 7Fh
		db	75h
		db	0F5h
		db	0F7h, 57h, 75h, 37h, 01h, 77h
		db	 29h, 06h, 6Bh,0F4h, 32h, 00h
		db	 10h, 01h, 29h, 0Eh, 50h,0CDh
		db	0D3h, 32h, 05h, 82h, 32h, 01h
		db	 20h, 2Ah, 97h, 00h, 00h,0AAh
		db	0A0h,0AAh,0AFh, 03h,0FEh, 33h
		db	 05h,0BEh,0BFh,0EFh,0AAh,0BAh
		db	 27h, 13h,0B5h,0E4h, 02h, 00h
		db	 01h, 12h, 27h, 0Eh,0A0h,0CDh
		db	0D3h, 32h, 05h, 14h, 32h, 01h
		db	 44h, 55h, 7Ch, 10h, 14h, 15h
		db	 58h, 55h, 77h, 01h,0FEh, 5Fh
		db	 33h, 05h,0FDh,0F5h, 5Fh,0FFh
		db	0F7h, 29h, 00h, 75h, 55h, 5Fh
		db	0F5h, 5Dh, 29h, 00h,0D5h, 29h
		db	 08h, 6Ah,0E0h, 32h, 01h, 2Dh
		db	 29h, 0Eh, 50h,0CDh,0D3h, 32h
		db	 04h, 02h, 28h, 32h, 01h, 20h
		db	 0Ah,0AAh, 02h, 2Ah, 0Ah,0A8h
		db	 2Ah,0EAh, 01h,0A0h, 2Fh, 33h
		db	 05h,0EEh,0FBh,0AEh,0BAh,0AEh
		db	0AAh,0BEh, 27h, 03h,0ABh,0EAh
		db	 27h, 09h,0BAh,0B0h, 32h, 01h
		db	0BAh, 27h, 0Eh,0A0h,0CDh,0D3h
		db	 32h, 04h, 05h, 10h, 32h, 01h
		db	 40h, 29h, 00h, 00h, 14h, 05h
		db	 54h, 45h, 5Dh, 40h, 01h, 5Fh
		db	 33h, 07h, 7Fh,0FFh,0D9h, 10h
		db	 1Fh, 55h,0FDh, 5Fh,0F5h, 7Dh
		db	 29h, 0Ch,0B0h, 32h, 00h, 02h
		db	 29h, 0Fh, 50h,0CDh,0D3h, 32h
		db	 04h, 2Ah, 20h, 32h, 00h, 02h
		db	 20h, 2Ah,0AAh, 80h, 08h,0A8h
		db	 27h, 01h, 0Ah,0AAh,0A2h, 33h
		db	 03h,0AEh,0EEh,0AFh,0EAh,0AAh
		db	0EAh,0A4h, 00h, 06h, 27h, 03h
		db	0ABh,0BBh,0EAh, 27h, 09h,0A0h
		db	 1Ch, 64h, 0Ah, 27h, 0Fh,0A0h
		db	0CDh,0D3h, 32h, 04h, 04h, 40h
		db	 32h, 00h, 05h, 40h, 55h, 75h
		db	 00h, 05h, 45h, 5Dh, 41h, 7Dh
		db	 41h, 55h,0A5h, 00h,0D1h,0BFh
		db	 33h, 04h, 7Fh,0F7h,0E5h, 00h
		db	 01h, 55h, 57h,0DFh, 55h, 57h
		db	 75h, 29h, 0Bh, 50h, 1Eh, 40h
		db	 15h, 29h, 0Fh, 50h,0CDh,0D3h
		db	 32h, 04h, 02h, 32h, 00h, 0Ah
		db	 02h,0A0h, 2Ah,0AAh, 82h, 2Ah
		db	 00h,0AAh,0A8h,0AAh,0A8h,0EAh
		db	0AAh, 8Bh, 01h, 9Fh, 33h, 02h
		db	0FEh,0BAh,0AAh,0AEh,0A8h, 32h
		db	 00h, 2Ah,0E0h, 0Eh, 27h, 0Eh
		db	0A8h, 18h, 00h, 2Ah, 27h, 0Fh
		db	0A0h,0CDh,0D3h, 32h, 04h, 10h
		db	 32h, 00h, 15h, 05h, 40h, 29h
		db	 00h, 05h, 55h, 50h, 57h,0D4h
		db	 06h, 54h, 15h, 5Dh,0D5h, 04h
		db	 7Fh,0DFh, 33h, 02h, 55h,0FFh
		db	 57h, 40h, 32h, 01h,0E0h, 03h
		db	 29h, 00h,0DDh,0D5h, 29h, 08h
		db	 54h, 00h, 30h, 0Eh, 00h, 18h
		db	 01h, 29h, 0Eh, 50h,0CDh,0D3h
		db	 32h, 08h, 65h, 00h, 2Ah,0AAh
		db	 80h, 2Ah,0A0h, 27h, 00h, 82h
		db	0AAh, 82h,0AEh,0AAh, 0Ah, 02h
		db	0BFh, 33h, 00h,0BEh,0D0h, 00h
		db	0BFh,0EAh, 48h, 80h, 00h, 01h
		db	 32h, 00h,0AAh,0FAh,0AAh,0BAh
		db	 27h, 08h,0A1h, 40h, 68h, 03h
		db	 80h, 2Ch, 00h, 0Ah, 27h, 01h
		db	0A8h, 27h, 09h,0A0h,0CDh,0D3h
		db	 32h, 07h, 10h, 04h, 00h, 55h
		db	 15h, 01h, 55h, 40h, 45h, 75h
		db	 40h, 15h, 50h, 7Fh,0DDh, 01h
		db	 10h, 0Dh, 33h, 00h,0DDh, 32h
		db	 00h, 7Dh, 55h, 41h, 32h, 03h
		db	 13h, 18h, 01h, 29h, 09h, 32h
		db	 00h, 48h, 32h, 00h, 24h, 00h
		db	 01h, 29h, 01h, 50h, 15h, 55h
		db	 05h, 29h, 06h, 50h,0CDh,0D3h
		db	 32h, 0Ah, 22h,0AAh, 82h,0AAh
		db	0A0h, 0Ah, 27h, 00h, 2Ah,0AAh
		db	 02h, 27h, 00h, 2Fh, 80h, 0Fh
		db	0FBh,0E6h, 32h, 00h, 0Ah,0B8h
		db	 32h, 04h, 01h, 80h, 00h,0ABh
		db	 27h, 00h, 00h, 2Ah, 27h, 04h
		db	0A0h, 00h,0C0h, 18h, 00h, 06h
		db	 00h, 0Ah, 27h, 01h, 92h, 0Ah
		db	0A8h, 00h, 27h, 06h,0A0h,0CDh
		db	0D3h, 32h, 07h, 04h, 32h, 00h
		db	 9Bh, 00h, 41h, 55h, 54h, 01h
		db	 55h, 54h, 51h, 55h, 01h, 55h
		db	0FFh, 57h,0F8h, 13h, 55h, 32h
		db	 01h, 05h, 50h, 32h, 04h, 02h
		db	 32h, 00h, 15h, 55h, 44h, 00h
		db	 05h, 29h, 02h,0C0h, 15h, 2Bh
		db	0FEh, 80h,0BEh, 00h, 02h,0AAh
		db	0A8h, 01h, 55h, 01h, 32h, 00h
		db	 40h, 00h, 15h, 29h, 05h, 50h
		db	0CDh,0D3h, 32h, 0Ah, 0Ah, 2Ah
		db	 00h, 2Ah,0AAh, 00h, 8Ah,0AAh
		db	0A0h,0A2h,0A8h, 02h, 27h, 00h
		db	0ABh,0C0h, 04h, 32h, 02h,0C0h
		db	 32h, 07h, 1Bh, 82h, 08h, 32h
		db	 00h, 27h, 01h,0A9h, 32h, 00h
		db	0AAh, 32h, 00h,0FFh, 04h, 32h
		db	 08h, 02h, 27h, 05h,0E0h,0CDh
		db	0D3h, 32h, 07h, 10h, 00h, 01h
		db	 04h, 15h, 41h, 29h, 00h, 00h
		db	 05h, 5Dh, 51h, 55h,0D5h, 00h
		db	 15h, 1Fh,0F7h, 54h, 32h, 0Dh
		db	 05h, 08h, 32h, 01h, 05h, 29h
		db	 00h, 52h, 32h, 00h, 14h, 32h
		db	 00h, 3Ch, 32h, 0Ah, 29h, 05h
		db	 50h,0CDh,0D3h, 32h, 07h, 2Ah
		db	 00h,0A8h, 00h, 2Ah,0A3h, 00h
		db	0AAh, 80h, 00h, 2Ah, 27h, 01h
		db	0B0h, 2Ah, 8Ah, 27h, 00h,0A8h
		db	 32h, 0Dh, 10h, 32h, 02h, 2Ah
		db	0AAh, 80h, 32h, 10h, 0Ah,0AAh
		db	 80h, 00h, 27h, 01h,0A0h,0CDh
		db	0D3h, 32h, 07h, 04h, 00h, 55h
		db	 00h, 15h, 00h, 55h, 75h, 50h
		db	 00h, 55h, 54h, 55h, 5Fh, 54h
		db	 01h,0ADh,0D5h,0FDh, 7Fh, 40h
		db	 32h, 11h, 05h, 55h, 32h, 12h
		db	 54h, 32h, 00h, 29h, 01h, 50h
		db	0CDh,0D3h, 32h, 05h, 20h, 02h
		db	0A8h, 00h, 22h, 88h, 2Ah, 00h
		db	 28h, 8Ah,0A8h, 00h, 08h, 27h
		db	 02h,0A0h, 22h, 6Eh,0BEh,0AAh
		db	0B9h, 02h, 32h, 29h, 02h, 27h
		db	 00h,0A0h,0CDh,0D3h, 32h, 04h
		db	 06h, 80h, 00h, 50h, 00h, 05h
		db	 40h, 15h, 00h, 45h, 5Dh, 54h
		db	 32h, 00h, 10h, 55h, 57h,0F5h
		db	 54h, 11h, 5Fh, 55h, 7Dh, 5Dh
		db	0F0h, 32h, 16h, 3Ch, 32h, 11h
		db	 05h, 00h, 10h,0CDh,0D3h, 32h
		db	 07h, 80h, 00h, 02h,0A8h, 2Ah
		db	 00h, 2Ah,0AAh,0A8h, 08h, 00h
		db	 20h, 2Ah, 82h, 2Ah,0AAh, 80h
		db	 88h, 6Ah, 27h, 00h,0ABh, 80h
		db	 32h, 15h, 7Ah, 32h, 14h,0CDh
		db	0D3h, 32h, 04h, 0Ch, 32h, 00h
		db	 40h, 00h, 01h, 54h, 15h, 00h
		db	 45h, 57h, 55h, 32h, 00h, 01h
		db	 41h, 55h, 5Fh,0D5h, 10h, 04h
		db	 05h, 15h, 57h,0FDh,0F1h, 32h
		db	 09h, 25h,0D5h, 54h, 32h, 07h
		db	 70h, 70h, 32h, 13h,0CDh,0D3h
		db	 32h, 07h,0A0h, 00h, 5Bh, 00h
loc_19:
		sub	cl,[bx+si]
		sub	ah,[bx]
		add	[bp+si],si
		add	[bx+si],ah
		stosb				; Store al to es:[di]
		das				; Decimal adjust
		stosb				; Store al to es:[di]
		call	$-56FDh
		add	dh,[bp+si-56h]
		xchg	ch,al
		xor	al,[bx]
		xchg	byte ptr ds:[32EEh][bx],bh
		or	byte ptr ds:[32FCh],ch
;*		or	[bp+di+0],bx
		db	 09h, 5Bh, 00h		;  Fixup - byte match
		db	 32h, 06h,0CDh,0D3h, 32h, 07h
		db	 54h, 00h, 04h, 01h, 05h, 14h
		db	 01h, 51h,0DDh, 54h, 10h, 32h
		db	 01h, 11h,0BEh,0DDh, 40h, 01h
		db	 40h, 56h, 52h, 95h,0D7h,0C0h
		db	 32h, 00h, 40h, 32h, 01h, 2Ah
		db	 83h,0F5h,0DFh, 55h, 54h, 32h
		db	 07h, 3Eh,0F4h, 32h, 08h, 15h
		db	 01h, 10h, 32h, 06h,0CDh,0D3h
		db	 32h, 07h, 28h, 32h, 00h, 80h
		db	 2Ah,0A0h, 02h, 27h, 01h, 32h
		db	 00h, 0Ah, 80h, 08h,0AAh,0EAh
		db	0A8h, 00h,0A2h, 22h, 8Ah, 84h
		db	 27h, 00h,0A0h, 32h, 01h, 08h
		db	 0Eh,0EBh,0FFh,0BEh,0AAh,0BAh
		db	0A8h, 32h, 07h, 1Ch, 60h, 00h
		db	 03h, 80h, 32h, 00h, 02h,0A0h
		db	 28h, 32h, 00h, 02h, 00h,0AAh
		db	 08h, 20h, 32h, 04h,0CDh,0D3h
		db	 32h, 0Ah, 10h, 05h, 40h, 04h
		db	 55h, 5Dh, 45h, 40h, 00h, 11h
		db	 44h, 17h, 15h, 6Fh,0D5h, 50h
		db	 00h, 01h, 42h, 51h, 82h, 09h
		db	 26h, 5Dh, 40h, 00h, 02h,0AAh
		db	 9Fh, 5Dh, 55h, 9Dh, 00h, 41h
		db	 32h, 00h, 63h, 00h, 32h, 03h
		db	 15h, 32h, 00h, 07h,0C8h, 32h
		db	 00h,0ABh,0F1h, 50h, 32h, 01h
		db	 14h, 01h, 32h, 00h, 01h, 32h
		db	 03h,0CDh,0D3h, 32h, 06h, 80h
		db	 32h, 01h, 08h, 0Ah,0A8h, 08h
		db	 20h, 27h, 00h, 32h, 00h, 02h
		db	 0Ah,0AAh, 83h,0ACh,0AEh,0AAh
		db	0A0h, 00h, 80h,0A2h, 8Ah, 2Ah
		db	 28h,0B2h, 8Ah, 88h, 82h,0A8h
		db	0B5h,0BEh,0FAh,0EBh,0AAh, 2Ah
		db	 88h, 32h, 06h, 0Ah, 00h, 0Eh
		db	 05h,0E1h, 00h, 08h,0AAh, 2Ah
		db	0AAh, 28h, 32h, 01h, 02h, 08h
		db	 32h, 05h,0CDh,0D3h, 32h, 01h
		db	 10h, 32h, 04h, 04h, 00h, 04h
		db	 05h, 15h, 51h, 15h, 54h, 51h
		db	 40h, 00h, 9Bh, 00h, 40h, 41h
		db	 04h, 59h, 59h, 54h, 32h, 00h
		db	 20h, 00h, 84h,0ABh, 90h, 4Ch
		db	 84h, 45h, 48h,0ABh,0F7h, 5Dh
		db	0E5h, 55h, 32h, 04h, 40h, 32h
		db	 02h, 06h, 38h, 80h,0C0h, 01h
		db	 88h,0BBh, 22h,0D4h, 10h, 04h
		db	 32h, 00h, 01h, 32h, 06h,0CDh
		db	0D3h, 32h, 00h, 08h, 32h, 03h
		db	 80h, 00h, 82h, 40h, 22h, 00h
		db	0AAh, 80h,0AAh,0A8h, 08h, 32h
		db	 00h, 20h, 12h, 02h, 82h,0A0h
		db	 9Ah, 1Ah,0CAh,0A8h, 02h,0A2h
		db	 32h, 00h, 8Ah, 2Ah,0A2h
data_15		db	0A0h			; Data table (indexed access)
		db	 8Eh, 42h,0AAh, 02h,0AAh, 2Ah
		db	 80h, 02h, 80h, 32h, 04h, 02h
		db	 80h, 00h,0CFh, 30h, 32h, 02h
		db	 08h, 88h, 08h, 28h, 80h,0A0h
		db	 32h, 01h, 20h, 32h, 04h,0CDh
		db	0D3h, 32h, 06h, 10h, 00h, 05h
		db	 00h, 10h, 01h, 54h, 00h, 10h
		db	 40h, 04h, 01h, 00h, 44h, 08h
		db	 01h, 76h, 00h, 04h, 11h, 60h
		db	 05h, 54h, 01h, 32h, 01h, 04h
		db	 10h, 15h, 11h, 04h, 15h, 55h
		db	 74h, 40h, 32h, 05h, 01h, 00h
		db	 57h,0CFh,0C8h,0CFh, 30h, 32h
		db	 02h, 18h, 04h, 32h, 01h, 04h
		db	 10h, 00h, 04h, 55h, 14h, 50h
		db	 32h, 01h, 10h,0CDh,0D3h, 32h
		db	 05h, 08h, 0Ah, 20h, 02h, 00h
		db	 5Bh, 00h,0AAh,0A8h, 32h, 00h
		db	 02h, 00h,0A0h, 22h, 02h, 20h
		db	 08h, 32h, 00h, 21h, 49h, 02h
		db	0A0h, 66h, 00h, 22h, 88h, 8Ah
		db	 0Ah,0AAh,0CCh, 00h,0A8h, 27h
		db	 00h, 80h, 08h, 80h, 00h, 20h
		db	 00h, 08h, 0Ah, 28h, 8Ah, 88h
		db	0B3h,0F4h, 06h, 08h, 32h, 02h
		db	 98h, 00h, 8Ah,0A2h, 88h, 32h
		db	 01h, 08h,0A2h,0AAh, 88h, 02h
		db	0A0h, 88h, 80h,0CDh,0D3h, 32h
		db	 01h, 10h, 32h, 02h, 10h, 00h
		db	 04h, 60h, 04h, 01h, 11h, 55h
		db	 01h, 00h, 40h, 00h, 50h, 10h
		db	 32h, 00h, 15h, 10h, 00h, 40h
		db	0C6h, 06h, 10h, 50h, 85h, 00h
		db	 04h, 01h, 51h, 45h, 10h, 29h
		db	 00h, 5Dh,0D5h, 5Dh, 45h, 84h
		db	 40h, 00h, 04h, 00h, 1Ah, 1Dh

loc_ret_21:
		iret				; Interrupt return
			                        ;* No entry point to code
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		jnp	loc_ret_21		; Jump if not parity
		xor	al,[si]
;*		and	ch,dl
		db	 20h,0D5h		;  Fixup - byte match
		dec	cx
		jz	$+2			; delay for I/O
		add	[bx+si],ax
		inc	ax
		adc	[si],al
		adc	ax,1004h
		inc	ax
		xor	al,[bx+si]
		int	0D3h			; ??INT Non-standard interrupt
		add	[bp+si],al
		xor	al,[si]
		sub	al,ss:data_7[bp+si]
		pop	bx
		add	[bx+si],al
		sub	[bx+si],al
		and	byte ptr [bx+si],32h	; '2'
		add	[bp+si],cl
		add	[bx+si],ah
		or	[bp+si],cl
		or	ss:data_27e[bp+si],al
;*		add	byte ptr [bx+si],2Ah	; '*'
		db	 82h, 00h, 2Ah		;  Fixup - byte match
;*		or	byte ptr ds:data_33e[bx+si],0BAh
		db	 82h, 88h,0A0h,0AAh,0BAh	;  Fixup - byte match
		stosw				; Store ax to es:[di]
		scasb				; Scan es:[di] for al
		mov	di,320Ah
		add	ss:data_17e[bp+si],ch
		or	ah,[bp+si]
		or	ah,[bx]
		add	ss:data_24e[bp+si],al
;*		sal	byte ptr [bp+si],1	; Shift w/zeros fill
		db	0D0h, 32h		;  Fixup - byte match
		add	al,0AAh
;*		and	byte ptr [bx],0
		db	 82h, 27h, 00h		;  Fixup - byte match
		mov	ds:data_22e,al
		add	[bp+si],ax
		sub	ss:data_28e[bp+si],ch
		sub	[bx+si],al
		int	0D3h			; ??INT Non-standard interrupt
;*		add	[bp+di+0],ah
		db	 00h, 63h, 00h		;  Fixup - byte match
		db	 32h, 02h, 04h, 51h, 00h, 54h
		db	 10h, 50h, 01h, 00h, 11h, 00h
		db	 91h, 00h, 00h, 04h, 00h, 40h
		db	 10h, 89h, 01h, 01h, 00h, 01h
		db	 05h,0A0h, 0Ch,0D0h, 01h, 11h
		db	 29h, 00h, 75h,0F7h, 54h, 51h
		db	 55h, 93h, 00h, 68h, 0Eh, 44h
		db	 73h, 00h, 30h, 53h, 11h,0F4h
		db	 49h, 50h, 00h, 09h, 62h, 32h
		db	 01h, 7Dh, 5Dh,0FDh, 15h, 32h
		db	 00h, 44h, 00h, 78h, 60h, 04h
		db	 15h, 04h, 11h, 11h, 40h,0CDh
		db	0D3h, 32h, 00h, 99h, 00h, 32h
		db	 02h,0A8h, 32h, 00h, 0Ah, 28h
		db	 00h, 82h, 20h, 00h, 08h, 00h
		db	 08h, 02h, 00h, 20h, 08h, 02h
		db	 00h, 02h, 08h, 20h, 00h, 02h
		db	 28h, 02h,0A8h,0AAh, 0Ah, 2Ah
		db	0AAh, 68h, 6Ah, 27h, 00h,0AEh
		db	 27h, 00h,0A0h,0A2h, 28h, 80h
		db	 00h, 80h,0A8h, 20h,0B6h, 41h
		db	 40h, 00h, 2Fh, 1Fh, 40h, 32h
		db	 00h, 27h, 00h, 65h, 00h,0A8h
		db	 98h, 01h, 82h, 28h, 00h, 08h
		db	 0Ah, 32h, 01h,0CDh,0D3h, 32h
		db	 00h, 04h, 32h, 02h, 10h, 40h
		db	 00h, 01h, 93h, 00h, 00h, 01h
		db	 14h, 32h, 00h, 42h, 04h, 32h
		db	 03h, 40h, 00h, 04h, 14h, 32h
		db	 00h, 01h, 11h, 04h, 01h, 32h
		db	 00h, 01h,0C5h, 55h, 15h, 4Fh
		db	0F5h, 55h,0D5h, 54h, 24h, 10h
		db	 00h, 08h, 8Ch, 87h, 39h,0F5h
		db	 31h, 40h, 10h,0BEh, 30h,0E0h
		db	 02h, 01h, 55h,0F5h, 75h, 45h
		db	 51h, 00h, 10h, 04h, 05h, 32h
		db	 00h, 01h, 40h, 00h, 50h, 10h
		db	0CDh,0D3h, 00h, 5Bh, 00h, 88h
		db	 32h, 01h, 08h, 80h, 00h,0AAh
		db	0A0h, 08h, 32h, 00h, 0Ah, 32h
		db	 00h, 21h, 02h, 00h, 80h, 32h
		db	 00h, 08h, 98h, 00h, 02h, 08h
		db	 32h, 00h, 28h, 27h, 00h, 00h
		db	 20h, 02h, 27h, 06h, 88h,0AAh
		db	 99h, 00h, 6Ch, 00h,0B0h, 2Ah
		db	0A8h, 5Ah, 00h, 09h, 79h,0E3h
		db	 1Ch, 06h, 02h, 27h, 00h,0A8h
		db	 22h,0AAh, 8Ah,0AAh, 02h,0A8h
		db	 00h,0AAh, 22h, 00h, 2Ah,0A2h
		db	 80h,0CDh,0D3h, 32h, 05h, 14h
		db	 32h, 00h, 54h, 80h, 32h, 01h
		db	 05h, 32h, 00h, 10h, 32h, 00h
		db	 40h, 02h, 32h, 00h, 10h, 32h
		db	 03h, 51h, 41h, 40h, 44h, 05h
		db	 29h, 04h,0FFh, 57h, 14h, 19h
		db	 20h, 10h, 21h, 31h, 7Ah, 6Eh
		db	0B4h, 04h, 62h, 03h, 06h,0EFh
		db	0CEh, 72h, 1Ch, 05h, 29h, 00h
		db	 41h, 15h, 29h, 00h, 54h,0A7h
		db	 55h, 1Dh, 55h, 51h, 29h, 00h
		db	 44h, 10h,0CDh,0D3h, 00h, 02h
		db	 32h, 03h, 22h, 0Ch, 00h, 2Ah
		db	 40h, 20h, 02h, 32h, 00h, 80h
		db	 20h, 00h, 20h, 32h, 00h, 01h
		db	 32h, 07h,0AAh, 08h,0A0h, 8Ah
		db	 27h, 00h,0BAh,0AAh,0BAh,0BAh
		db	0FAh,0EAh, 22h, 22h, 0Ah, 08h
		db	 8Ah, 27h, 00h, 8Ah, 88h, 02h
		db	 34h, 07h, 06h,0EFh,0CEh, 72h
		db	 1Ch, 00h, 27h, 00h, 80h, 0Ah
		db	 2Ah, 27h, 00h, 2Ah, 27h, 02h
		db	 8Ah,0A2h, 98h, 00h,0CDh,0D3h
		db	 32h, 00h, 01h, 00h, 0Ah, 00h
		db	 01h, 10h, 32h, 00h, 54h, 20h
		db	 10h, 63h, 00h, 32h, 00h, 10h
		db	 32h, 01h, 02h, 00h, 40h, 32h
		db	 04h, 01h, 29h, 02h, 7Dh,0F7h
		db	 7Fh, 33h, 00h, 5Fh, 57h, 5Fh
		db	0FEh, 44h,0D5h, 45h, 75h, 5Dh
		db	 5Fh,0FDh, 6Dh, 32h, 01h, 16h
		db	 47h, 4Fh,0DEh, 7Fh, 3Ch, 12h
		db	0C1h, 44h, 00h,0D0h, 30h, 41h
		db	 55h, 11h, 55h, 45h, 55h, 15h
		db	 45h, 54h, 11h, 50h,0CDh,0D3h
		db	 32h, 0Ah, 28h, 00h, 66h, 00h
		db	 32h, 02h, 20h, 00h, 80h, 32h
		db	 05h,0A0h, 2Ah,0AAh, 8Ah, 27h
		db	 02h,0AFh,0ABh,0BEh, 88h, 22h
		db	 0Ah, 22h,0C4h, 00h,0AAh, 2Ah
		db	 27h, 00h,0A2h, 0Ah, 98h, 00h
		db	 2Ch, 81h, 9Eh,0FFh,0CEh, 7Ah
		db	 04h, 18h,0A2h,0A8h
		db	2Ah
loc_22:
		or	ah,0
;*		sub	byte ptr ss:data_32e[bp+si],0A2h
		db	 82h,0AAh, 82h,0AAh,0A2h	;  Fixup - byte match
		sub	cl,ds:data_29e[bx+si]
		int	0D3h			; ??INT Non-standard interrupt
		xor	al,[bp+di]
		add	byte ptr [bx+si],10h
		add	data_13[bx+si],al
		jnc	$+2			; delay for I/O
		xor	al,[bp+si]
		adc	[bp+si],dh
		pop	es
		add	ax,29h
		pushf				; Push flags
;*		add	bh,dl
		db	 00h,0D7h		;  Fixup - byte match
		xlat				; al=[al+[bx]] table
		idiv	di			; ax,dx rem=dx:ax/reg
		xlat				; al=[al+[bx]] table
		db	0D6h, 50h, 40h, 10h, 32h, 00h
		db	 05h, 45h, 5Fh,0DFh, 3Bh, 34h
		db	 32h, 00h, 41h, 6Bh, 21h,0D1h
		db	0FDh, 8Dh,0E4h, 02h, 14h, 41h
		db	 00h, 05h, 04h, 44h, 77h, 64h
		db	 44h, 10h, 74h, 51h, 54h, 15h
		db	0D7h,0D0h,0CDh,0D3h, 32h, 02h
		db	 1Ah, 80h, 32h, 02h, 28h, 00h
		db	 02h, 32h, 03h, 04h, 00h, 08h
		db	 32h, 06h, 27h, 00h, 2Ah, 27h
		db	 00h, 38h,0A6h, 00h,0BEh,0EAh
		db	0AAh, 80h, 00h, 02h, 27h, 00h
		db	 88h, 27h, 02h, 20h, 99h, 00h
		db	 8Ah, 84h,0E7h,0C0h,0E1h,0ECh
		db	 0Eh,0D8h, 81h, 00h,0A0h, 0Ah
		db	 22h, 8Ah, 22h, 2Ah, 27h, 00h
		db	 28h, 2Ah, 27h, 02h,0A0h,0CDh
		db	0D3h, 32h, 02h, 80h, 32h, 01h
		db	 40h, 32h, 01h, 01h, 32h, 03h
		db	 01h, 32h, 04h, 89h, 01h, 32h
		db	 00h, 01h, 55h, 57h, 29h, 00h
		db	 7Dh,0D7h,0A5h, 00h, 94h, 89h
		db	 00h, 54h, 41h, 29h, 02h, 54h
		db	 44h, 51h, 41h, 0Dh, 54h, 19h
		db	0FFh, 00h,0F9h, 60h,0FEh, 32h
		db	 00h, 90h, 32h, 00h, 14h, 54h
		db	 11h, 05h, 5Dh, 55h, 57h, 77h
		db	 67h, 54h, 29h, 00h, 50h,0CDh
		db	0D3h, 02h, 00h, 20h, 32h, 02h
		db	 08h, 32h, 0Dh, 20h, 28h, 02h
		db	 00h,0AAh,0A8h, 27h, 02h,0BAh
		db	0A6h, 00h,0AAh,0EAh,0A2h,0A0h
		db	 22h, 00h, 2Ah,0AAh, 2Ah,0AAh
		db	 2Ah, 27h, 00h, 28h, 00h, 27h
		db	 00h, 28h, 3Bh,0FFh, 00h,0F9h
		db	 60h,0FEh, 02h, 00h, 08h, 02h
		db	 88h,0A8h, 27h, 04h, 2Ah, 27h
		db	 02h,0A0h,0CDh,0D3h, 32h, 00h
		db	 10h, 32h, 02h, 04h, 01h, 14h
		db	 32h, 0Bh, 10h, 40h, 01h, 29h
		db	 07h,0F5h,0FDh, 7Dh, 45h, 54h
		db	 29h, 03h, 45h, 01h, 5Ch,0E5h
		db	 51h, 01h
		db	45h
loc_23:
		inc	cx
		push	bp
		ja	loc_23			; Jump if above
		add	[bp-4Dh],di
		mov	di,offset data_16
		inc	sp
		inc	cx
		add	[bx+di+45h],ax
		sub	[bx+si],cx
		push	ax
		int	0D3h			; ??INT Non-standard interrupt
		xor	al,[bp+si]
		add	cl,[bp+si]
		add	[bp+si],ah
		xor	byte ptr [bp+si],0Dh
		mov	ch,data_15[bx+si]
		daa				; Decimal adjust
		push	es
		scasb				; Scan es:[di] for al
		test	al,82h
		mov	ch,byte ptr ds:[127h][bx+si]
		mov	al,ds:data_19e
		push	es
		out	0F8h,ax			; port 0F8h ??I/O Non-standard
		and	[bx-2Dh],bp
		aas				; Ascii adjust
		db	 60h, 00h, 02h,0A8h, 22h, 27h
		db	 0Ah,0A0h,0CDh,0D3h, 32h, 05h
		db	 04h, 00h, 41h, 40h, 32h, 06h
		db	 15h, 14h, 01h, 73h, 00h, 00h
		db	 45h, 15h, 29h, 01h, 5Fh,0D7h
		db	 5Dh,0DFh,0DFh, 75h, 29h, 01h
		db	 54h, 11h, 29h, 01h, 44h, 15h
		db	 55h, 11h, 45h, 15h, 29h, 01h
		db	 54h,0EFh,0F8h, 06h,0BFh,0EEh
		db	 2Fh, 78h, 00h, 05h, 54h, 29h
		db	 06h, 54h, 29h, 02h, 50h,0CDh
		db	0D3h, 32h, 02h, 20h, 5Bh, 00h
		db	 28h, 20h, 00h, 80h
		db	 32h, 08h
loc_24:
		sub	[bx+si],al
		daa				; Decimal adjust
		adc	ax,0AAA8h
		mov	data_12,al
		test	al,0CFh
                           lock	pop	cx
		jg	loc_24			; Jump if >
		dec	si
		js	$+2			; delay for I/O
		or	ah,[bx]
		or	al,0A0h
		int	0D3h			; ??INT Non-standard interrupt
		xor	al,[si]
		add	al,29h			; ')'
		add	al,[bx+si]
		inc	bp
		db	 63h, 00h, 76h, 00h, 41h, 54h
		db	 55h, 11h, 00h, 15h, 29h, 01h
		db	 5Dh,0FDh,0FFh,0D7h,0D5h, 75h
		db	 29h, 09h, 50h, 29h, 00h, 50h
		db	 69h, 00h, 29h, 02h, 54h, 5Fh
		db	0F0h, 46h, 33h, 00h, 10h,0FCh
		db	 00h, 05h, 29h, 0Ch, 50h,0CDh
		db	0D3h, 32h, 00h, 02h, 08h, 02h
		db	0A8h,0AAh, 2Ah, 27h, 00h, 32h
		db	 01h, 02h, 20h,0A8h, 02h, 32h
		db	 00h, 27h, 1Bh, 2Ah, 27h, 02h
		db	0A8h, 1Fh,0F0h,0CFh, 0Fh,0FFh
		db	 81h, 80h, 00h, 0Ah, 27h, 0Ch
		db	0A0h,0CDh,0D3h, 32h, 02h, 11h
		db	 15h, 04h, 29h, 01h, 45h, 04h
		db	 11h, 54h, 00h, 44h, 01h, 54h
		db	 51h, 00h, 45h, 05h, 95h, 75h
		db	0D5h, 29h, 07h, 44h, 51h, 29h
		db	 08h, 45h, 15h, 29h, 01h, 5Dh
		db	0DDh,0D4h, 1Fh,0F0h,0CFh, 0Fh
		db	0FFh, 81h, 80h, 00h, 05h, 29h
		db	 0Ch, 50h,0CDh,0D3h, 5Bh, 00h
		db	 00h, 02h, 2Ah, 27h, 01h, 00h
		db	 20h, 88h,0AAh, 22h,0AAh, 2Ah
		db	0AAh,0A8h, 08h, 32h, 00h, 27h
		db	 18h, 0Ah, 2Ah, 27h, 04h, 1Fh
		db	0F0h,0C7h, 81h,0FFh,0A2h, 00h
		db	 04h, 0Ah, 27h, 0Ch,0A0h,0CDh
		db	0D3h, 32h, 01h, 69h, 00h, 54h
		db	 45h, 44h, 41h, 14h, 01h, 10h
		db	'DT)', 8, 'WuU])'
		db	 0Fh, 9Bh, 00h, 5Dh,0D5h, 29h
		db	 01h,0DDh, 55h, 1Fh, 78h,0E7h
		db	 80h,0F3h,0FCh, 18h, 00h, 1Dh
		db	0C5h,0DDh, 29h, 0Ah, 50h,0CDh
		db	0D3h, 32h, 01h, 80h, 20h, 80h
		db	 2Ah,0A0h, 0Ah,0A0h, 0Ah, 6Ch
		db	 00h,0AAh,0A8h,0A2h, 27h, 1Bh
		db	 82h, 27h, 06h, 8Fh, 58h, 61h
		db	0C0h, 53h,0D0h, 20h, 04h, 2Ah
		db	0A2h, 27h, 0Bh
data_16		db	0A0h
		db	0CDh,0D3h, 00h, 45h, 51h, 05h
		db	 29h, 03h, 45h, 29h, 00h, 51h
		db	 29h, 11h, 54h, 29h, 06h, 5Dh
		db	0D5h,0DDh,0D4h,0CDh,0D5h,0DDh
		db	 55h, 5Dh, 55h, 37h, 01h, 4Fh
		db	0BCh, 70h,0FFh, 1Fh,0E3h,0E0h
		db	 00h, 1Dh,0DDh,0D4h,0D5h,0DDh
		db	 5Dh,0DDh, 5Dh, 35h, 00h, 37h
		db	 00h, 4Dh, 00h,0DDh,0D0h,0CDh
		db	0D3h, 08h, 88h,0AAh,0A2h, 28h
		db	 88h, 8Ah,0A2h,0A8h, 2Ah, 27h
		db	 00h, 2Ah, 8Ah, 27h, 1Ch, 8Ah
		db	 27h, 07h, 87h,0AFh, 38h, 7Fh
		db	0FFh,0D7h,0E0h, 08h, 2Ah, 27h
		db	 0Ch,0A0h,0CDh,0D3h, 05h, 45h
		db	 11h, 14h, 29h, 04h, 54h, 29h
		db	 05h, 77h, 75h, 29h, 00h, 5Dh
		db	 57h, 29h, 0Ch,0D5h, 29h, 00h
		db	 5Dh, 29h, 00h,0D1h, 55h, 5Dh
		db	 29h, 00h, 5Dh,0D5h, 5Dh,0D5h
		db	0DDh, 47h,0EDh, 38h, 7Fh,0FFh
		db	0DFh,0E0h, 08h, 5Dh, 35h, 0Ch
		db	0D0h,0CDh,0D3h, 00h,0A0h, 02h
		db	0A2h, 0Ah,0A2h, 27h, 01h, 8Ah
		db	0A2h, 27h, 01h, 2Ah, 27h, 25h
		db	0A7h,0F6h,0CEh, 3Fh,0FFh,0DFh
		db	0C0h, 00h, 2Ah, 27h, 0Ch,0A0h
		db	0CDh,0D3h, 00h, 04h, 51h, 29h
		db	 00h, 45h, 29h, 01h, 69h, 00h
		db	 29h, 07h, 57h, 55h, 57h, 5Dh
		db	 29h, 0Ah, 4Dh, 00h, 35h, 00h
		db	 29h, 02h, 5Dh,0D5h,0DDh, 4Dh
		db	 00h,0D5h,0DDh, 5Dh, 35h, 00h
		db	0D3h,0F9h, 07h, 1Fh,0FFh,0DFh
		db	0C0h, 00h, 35h, 0Dh,0D0h,0CDh
		db	0D3h, 00h, 27h, 33h,0ABh,0FCh
		db	 40h, 8Fh, 33h, 00h,0C0h, 00h
		db	 27h, 0Dh,0A0h,0CDh,0D3h, 04h
		db	 29h, 06h, 51h, 29h, 13h, 4Dh
		db	 00h, 29h, 04h, 37h, 00h,0DDh
		db	0D5h,0DDh,0D5h,0DDh,0D5h, 55h
		db	0DDh,0D5h,0DDh,0D5h, 5Dh,0D5h
		db	0D9h,0FFh, 80h, 01h, 33h, 00h
		db	 80h, 40h, 55h, 35h, 0Ch,0D0h
		db	0CDh,0D3h, 02h,0A8h,0A2h, 8Ah
		db	 27h, 03h,0A8h, 27h, 2Ah,0B9h
		db	0FFh,0E0h, 32h, 03h, 2Ah, 27h
		db	 0Ch,0A0h,0CDh,0D3h, 05h, 29h
		db	 08h, 57h, 77h, 55h,0D5h, 29h
		db	 09h,0D5h, 55h, 37h, 00h, 55h
		db	0D5h, 29h, 05h,0DDh,0D5h, 35h
		db	 00h,0D5h, 35h, 02h, 5Dh, 35h
		db	 01h, 37h, 00h,0C0h,0FFh,0F8h
		db	 20h, 0Dh, 92h, 80h, 00h, 1Dh
		db	0DDh,0D5h, 35h, 02h, 5Dh, 35h
		db	 04h, 5Dh,0D0h,0CDh,0D3h, 0Ah
		db	 27h, 33h, 80h,0FFh,0F8h, 20h
		db	 33h, 00h, 80h, 00h, 0Ah, 27h
		db	 0Ch,0A0h,0CDh,0D3h, 05h, 55h
		db	0D5h, 29h, 0Eh, 7Dh, 5Dh,0F5h
		db	 5Dh,0F5h, 37h, 00h, 29h, 02h
		db	 4Dh, 00h, 55h, 4Dh, 02h, 55h
		db	 37h, 01h, 55h,0D5h, 55h,0DDh
		db	 5Dh, 35h, 06h, 80h, 7Fh,0FEh
		db	 00h,0FFh,0EFh,0C0h, 00h, 05h
		db	 35h, 00h, 55h, 35h, 00h,0D5h
		db	 35h, 03h, 5Dh, 35h, 00h, 50h
		db	0CDh,0D3h, 0Ah, 27h, 33h, 82h
		db	 7Fh,0F9h, 00h,0F9h,0FEh, 40h
		db	 10h, 02h, 27h, 0Ch,0A0h,0CDh
		db	0D3h, 05h, 29h, 12h,0D5h, 29h
		db	 01h, 5Dh,0DDh, 5Dh, 29h, 02h
		db	 37h, 00h, 55h,0DDh, 55h, 5Dh
		db	 55h,0D5h,0DDh, 5Dh,0D5h,0DDh
		db	0D5h,0DDh, 55h, 35h, 05h, 5Dh
		db	 3Fh,0FEh, 80h,0F8h,0FCh,0C0h
		db	 15h, 35h, 01h, 5Dh, 35h, 00h
		db	0D5h, 35h, 03h, 5Dh, 55h,0D5h
		db	 50h,0CDh,0D3h, 0Ah, 27h, 34h
		db	 3Fh,0F9h, 40h, 7Fh, 7Bh, 80h
		db	 12h, 27h, 0Dh,0A0h,0CDh,0D3h
		db	 05h, 29h, 08h, 5Dh, 29h, 0Ah
		db	0D5h, 55h,0DDh,0D5h, 5Dh, 29h
		db	 00h, 5Dh, 35h, 04h,0D5h, 55h
		db	0DDh,0D5h, 35h, 00h, 5Dh,0D5h
		db	 35h, 07h, 3Fh,0FEh, 80h, 7Fh
		db	0FFh, 00h, 15h, 35h, 04h,0D5h
		db	 5Dh,0DDh, 5Dh,0DDh, 37h, 00h
		db	 29h, 00h,0D0h,0CDh,0D3h, 0Ah
		db	 27h, 34h, 9Fh,0FEh, 80h, 3Fh
		db	0FFh, 00h, 12h, 27h, 0Dh,0A0h
		db	0CDh,0D3h, 05h, 29h, 02h,0DDh
		db	 37h, 00h, 29h, 05h,0DDh,0D5h
		db	 29h, 04h, 5Dh,0D5h, 5Dh, 29h
		db	 00h,0D5h, 55h,0D5h, 55h, 35h
		db	 00h,0D5h, 29h, 00h, 35h, 10h
		db	 9Fh,0F9h, 00h, 0Fh,0ECh, 20h
		db	 2Dh, 37h, 00h, 35h, 05h, 5Dh
		db	 35h, 00h,0D5h, 35h, 00h,0D0h
		db	0CDh, 33h, 00h,0DAh, 27h, 33h
		db	 9Fh,0F9h, 32h, 01h,0A0h, 2Ah
		db	 27h, 0Ch,0AFh,0FFh,0FDh, 27h
		db	 00h,0DDh,0D5h, 55h, 5Dh, 29h
		db	 00h, 4Dh, 00h, 29h, 00h, 5Dh
		db	 29h, 01h,0DDh, 5Dh, 55h,0DDh
		db	0D5h, 55h,0DDh, 29h, 01h,0DDh
		db	 29h, 00h, 35h, 06h,0D5h, 35h
		db	 10h,0CFh,0F6h, 32h, 00h, 23h
		db	0A0h, 2Dh,0DDh, 5Dh, 35h, 05h
		db	0D5h, 35h, 03h, 29h, 00h, 32h
		db	 00h,0D0h, 27h, 33h, 8Fh,0F6h
		db	 32h, 00h, 4Fh, 40h, 4Ah, 27h
		db	 0Ch,0ADh, 32h, 00h, 03h, 00h
		db	0D0h, 55h,0D5h, 55h,0D5h, 55h
		db	0D5h, 55h, 4Dh, 00h, 37h, 00h
		db	 5Dh,0D5h, 29h, 00h,0DDh, 5Dh
		db	0DDh,0D5h,0DDh,0D5h, 5Dh,0D5h
		db	 5Dh, 35h, 11h, 5Dh,0DDh,0D5h
		db	 35h, 00h, 37h, 00h, 35h, 01h
		db	0CFh,0F6h, 32h, 00h, 4Fh, 40h
		db	 5Dh, 35h, 09h,0D5h,0DDh, 5Dh
		db	0DDh, 00h,0C0h, 03h, 00h,0D0h
		db	 32h, 48h, 0Dh, 00h,0C0h, 03h
		db	 00h,0D0h, 32h, 48h, 0Dh, 00h
		db	0C0h, 03h,0FFh,0D3h, 33h, 48h
		db	0FDh, 3Fh,0C0h, 32h, 00h,0D0h
		db	 32h, 48h, 0Dh, 32h, 02h, 33h
		db	 49h,0FDh, 32h, 02h,0D5h, 29h
		db	 49h, 32h, 00h

seg_a		ends



		end	start
