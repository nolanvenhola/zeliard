
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_366UNKN                                 €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    5          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	9
data_2e		equ	410Ah			;*
data_3e		equ	0A825h			;*
data_30e	equ	1C09h			;*
data_31e	equ	2A22h			;*
data_32e	equ	50ACh			;*
data_33e	equ	8000h			;*
data_34e	equ	8019h			;*
data_35e	equ	8088h			;*
data_36e	equ	80F2h			;*
data_37e	equ	8882h			;*
data_38e	equ	8A88h			;*
data_39e	equ	90AFh			;*
data_40e	equ	94AAh			;*
data_41e	equ	9FEAh			;*
data_42e	equ	0A000h			;*
data_43e	equ	0A002h			;*
data_44e	equ	0A080h			;*
data_45e	equ	0A0A8h			;*
data_46e	equ	0A0AAh			;*
data_47e	equ	0A300h			;*
data_48e	equ	0A500h			;*
data_49e	equ	0AA80h			;*
data_50e	equ	0AAA0h			;*
data_51e	equ	0AAB8h			;*
data_52e	equ	0AC00h			;*
data_53e	equ	0AD82h			;*
data_54e	equ	0BA88h			;*
data_55e	equ	0E8AEh			;*
data_56e	equ	0FE00h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_366UNKN	proc	far

start:
		lds	dx,dword ptr [bx+si]	; Load seg:offset ptr
		add	[bx+si],al
		add	ds:data_1e,al
		sbb	ss:data_34e[bp+si],ch
		pop	ds
		mov	al,ds:data_3e
		daa				; Decimal adjust
		add	dh,[bx+di]
		sub	dh,[bp+di]
		add	si,ds:data_2e
		scasb				; Scan es:[di] for al
		inc	dx
		mov	dx,2046h
		dec	cx
;*		jmp	far ptr loc_1		;*
		db	0EAh
		dw	0C04Ch, 0E4Dh		;  Fixup - byte match
			                        ;* No entry point to code
		dec	si
		push	bp
		dec	di
		out	dx,al			; port 2046h ??I/O Non-standard
		push	bx
		add	[bx+si-55h],bx
		db	 60h, 08h, 61h, 88h, 64h, 22h
		db	 66h, 40h, 67h, 0Ch, 6Dh, 0Fh
		db	 6Fh, 8Ah, 71h,0FAh, 72h,0E0h
		db	 73h, 28h
data_7		dw	0B074h			; Data table (indexed access)
		db	 76h,0EBh, 77h,0ACh, 79h,0BBh
		db	 7Fh,0E8h, 81h, 30h, 85h, 3Ah
		db	 86h, 0Bh, 87h, 10h, 89h, 04h
		db	 8Dh,0EFh, 8Fh,0A2h, 93h,0B8h
		db	 9Bh, 2Eh, 9Ch, 50h, 9Dh, 6Ah
		db	 9Eh, 8Bh,0A1h,0AFh,0B6h,0BEh
		db	0B7h,0FBh,0BDh, 5Ah,0C4h, 05h
		db	0C5h, 0Dh,0C6h,0A5h,0C7h, 3Bh
		db	0C9h, 3Eh,0CBh, 9Ah,0CCh,0A9h
		db	0CDh,0F0h,0D7h, 2Bh,0D9h, 65h
		db	0DCh
		db	70h
data_8		dw	82DEh			; Data table (indexed access)
		db	0DFh, 96h,0E3h,0A3h,0EDh,0ECh
		db	0F3h,0FEh
data_9		db	0F6h			; Data table (indexed access)
		db	 1Eh,0F7h, 29h,0F9h, 2Fh,0FDh
		db	 35h,0FFh,0FFh, 09h, 33h, 02h
		db	 09h, 05h, 3Ah, 00h, 05h, 09h
		db	 01h, 30h, 09h, 01h,0C0h, 09h
		db	 00h, 0Fh, 83h, 09h, 00h
data_10		db	3Eh
		db	 8Eh,0BAh, 80h
data_11		db	0			; Data table (indexed access)
		db	 2Eh,0C0h, 20h, 00h, 0Ah,0BAh
		db	 28h, 0Ah, 00h, 2Ch,0FAh, 2Ch
		db	 09h, 00h,0AAh, 00h, 55h, 03h
		db	 80h, 00h, 40h, 00h, 0Ah, 00h
		db	 05h, 09h, 12h
data_12		db	83h			; Data table (indexed access)
		db	0BAh, 40h, 00h,0AAh,0EBh, 50h
		db	 00h, 80h,0BBh, 4Ah, 09h, 00h
		db	 2Eh,0FBh, 80h, 00h, 3Bh, 2Eh
		db	 80h, 00h,0EEh, 3Ah, 09h, 00h
		db	0EEh, 08h, 09h, 00h,0BAh, 09h
		db	 00h, 03h,0EEh, 01h, 00h, 03h
		db	0BAh, 01h, 00h, 0Fh,0B8h, 07h
		db	 00h, 2Ah,0A8h, 2Ah, 00h, 3Eh
		db	0E8h, 1Eh, 00h,0FFh,0B8h,0FCh
		db	 00h,0AAh,0EAh,0A8h, 00h,0FBh
		db	0EEh, 38h, 09h, 00h
data_13		db	3			; Data table (indexed access)
		db	 00h, 03h, 00h, 02h, 00h, 02h
		db	 00h, 0Fh, 00h, 04h, 00h, 0Fh
		db	 00h, 07h, 00h, 0Eh, 00h, 0Eh
		db	 00h, 0Bh, 00h, 08h, 00h, 0Fh
		db	 00h, 01h, 00h, 03h, 00h, 01h
		db	0FAh,0AEh,0F8h, 00h,0ABh,0BAh
		db	0A0h, 00h,0EBh,0B8h, 20h, 03h
		db	0EEh
loc_3:
		scasb				; Scan es:[di] for al
		loopnz	locloop_4		; Loop if zf=0, cx>0

		scasb				; Scan es:[di] for al
		test	al,0A0h
;*		add	dl,ch
		db	 00h,0EAh		;  Fixup - byte match
		mov	dx,20h
		cli				; Disable interrupts
		out	dx,al			; port 20h, 8259-1 int command
						;  al = 20h, end of interrupt
		js	$+2			; delay for I/O
		jmp	short loc_3

locloop_4:
		call	$+4203h
		add	ss:data_56e[bp+si],bl
		jmp	short loc_5
		db	 00h,0FAh,0BBh, 7Ah, 80h, 2Fh
		db	0AEh, 23h,0A0h, 0Eh,0EAh, 0Eh
		db	0EAh, 03h,0BAh, 03h,0BAh, 00h
		db	 2Ah, 00h, 2Ah, 09h, 02h,0FAh
		db	0BAh, 09h, 00h,0AEh,0EEh, 09h
		db	 00h,0EAh,0ABh, 09h, 00h,0AEh
		db	0EEh, 09h, 00h,0EBh,0ABh, 09h
		db	 00h,0FBh,0BAh, 09h, 00h,0AEh
		db	0EEh, 09h, 00h,0EEh,0BAh, 00h
		db	 02h,0AAh, 09h, 01h,0FAh, 80h
		db	 09h, 00h,0AEh,0A0h, 09h, 00h
		db	0FBh,0A8h, 09h, 00h,0AEh,0AAh
		db	 09h, 00h,0FBh,0AAh, 09h, 00h
		db	 8Ah,0EAh, 80h, 00h,0A8h,0AAh
		db	0A8h, 09h, 17h, 80h, 09h, 01h
		db	0A0h, 09h, 01h,0AAh, 09h, 01h
		db	0EAh,0C0h, 09h, 00h, 2Bh,0AAh
		db	 09h, 00h,0AEh,0EEh,0A0h, 00h
		db	0A3h,0AAh,0A0h, 00h, 0Ah,0AAh
		db	 0Ah, 80h, 00h,0AAh, 00h,0A8h
		db	 00h, 0Ah, 00h, 0Ah, 00h, 0Eh
loc_5:
		or	[bx+di],ax
		sub	ax,100h
		add	byte ptr ss:[0A00h][bp+si],bh
		scasb				; Scan es:[di] for al
		call	sub_4
		mov	bx,offset data_10
;*		sub	dh,ch
		db	 28h,0EEh		;  Fixup - byte match
		mov	al,ds:data_43e
		stosb				; Store al to es:[di]
		add	[bp+si],ch
		add	ds:data_42e[bx+si],ah
		or	data_18,dx
		add	word ptr data_13,cx
		cmp	cl,[bx+di]
		add	[si],cx
		or	[bx+di],ax
		xor	[bx+di],cl
;*		add	dx,bp
		db	 01h,0EAh		;  Fixup - byte match
		or	[bx+si],ax
		add	sp,word ptr ds:[9][bx+si]
		db	 3Eh,0A8h, 09h, 00h,0EAh,0A0h
		db	 09h, 00h,0AAh,0AEh, 00h, 80h
		db	0AAh, 78h, 09h, 05h, 03h, 09h
		db	 01h, 3Eh, 00h, 02h, 00h,0FAh
		db	 00h, 2Ah, 0Eh,0AAh, 00h,0AAh
		db	0FAh,0AAh, 0Ah, 18h, 01h, 2Ah
		db	 18h, 01h, 09h, 00h,0E8h, 00h
		db	 20h, 00h,0A0h, 00h, 80h, 00h
		db	 80h, 00h, 28h, 00h, 28h, 00h
		db	0A0h, 00h,0A0h, 00h, 80h, 00h
		db	 80h, 00h,0A8h, 00h,0A8h, 00h
		db	 80h, 00h, 80h, 09h, 02h,0EAh
		db	 80h, 09h, 00h,0EAh, 80h, 00h
		db	 03h,0AAh, 80h, 02h, 03h,0A9h
		db	 80h, 00h, 0Eh,0AFh, 80h, 00h
		db	 0Eh,0AFh, 80h, 00h, 0Eh,0ACh
		db	 09h, 00h, 0Eh,0ACh, 08h, 02h
		db	0A7h,0A2h, 00h, 02h,0BEh, 02h
		db	 80h, 0Ah, 78h, 0Ah, 00h,0AAh
		db	0E0h,0AAh, 02h,0AAh, 82h,0AAh
		db	 0Ah,0AAh, 0Ah,0AAh, 2Ah,0AAh
		db	 2Ah,0AAh, 2Ah,0AAh, 2Ah, 18h
		db	 00h,0A0h,0AAh,0A0h, 18h, 03h
		db	0F0h,0AAh,0F0h,0ABh, 00h,0ABh
		db	 00h, 80h, 00h, 80h, 00h,0B0h
		db	 00h,0B0h, 00h, 80h, 00h, 80h
		db	 00h,0C0h, 00h,0C0h, 09h, 01h
		db	 0Eh,0BCh, 09h, 00h, 3Ah,0B0h
		db	 00h, 08h, 3Ah,0C8h, 00h, 02h
		db	 2Ah,0C2h, 00h, 2Ah,0ABh, 2Ah
		db	 00h, 6Ah,0ACh, 6Ah, 01h,0AAh
		db	0ADh,0AAh, 02h,0AAh,0F2h, 18h
		db	 00h,0ABh,0AAh,0ABh,0AAh, 80h
		db	0AAh, 80h,0ABh,0C0h,0ABh,0C0h
		db	0AAh,0B0h,0AAh,0B0h,0AAh,0ACh
		db	0AAh,0ACh,0AEh,0C0h,0AEh,0C0h
		db	0AAh,0A8h,0AAh,0A8h,0BBh, 20h
		db	0BBh, 20h, 0Eh,0AAh,0CEh,0AAh
		db	 0Ah,0A8h,0CAh,0A8h, 18h, 03h
		db	0A8h,0AAh,0A8h, 0Ah,0AAh, 0Ah
		db	0AAh,0B0h,0A0h, 00h,0A0h,0EAh
		db	 0Ah, 09h, 00h,0AFh,0BEh, 09h
		db	 00h,0AAh, 80h,0AAh, 80h,0A0h
		db	 00h,0A0h, 09h, 0Fh, 80h
		db	9
data_15		db	1			; Data table (indexed access)
		db	0A8h, 09h, 1Ch, 03h, 09h, 00h
		db	 03h,0FEh, 3Bh,0AAh, 00h, 0Ah
		db	 3Ah, 8Ch, 09h, 01h, 03h, 0Fh
		db	 09h, 01h, 2Ch, 09h, 01h, 30h
		db	 09h, 01h,0E0h, 09h, 05h, 38h
		db	 0Fh,0AAh, 8Bh,0AAh, 80h, 00h
		db	0AAh, 00h,0A8h, 22h, 2Ah, 00h
		db	 2Ah,0C8h, 02h, 00h, 02h, 09h
		db	 00h, 0Ch, 09h, 01h, 0Ch, 09h
		db	 01h, 2Ch, 09h, 01h, 72h, 00h
		db	 09h, 11h, 03h, 09h, 01h, 02h
		db	 09h, 06h, 03h,0AAh, 09h, 01h
		db	0AAh, 09h, 01h, 01h, 00h, 34h
		db	 09h, 00h,0AAh,0B4h, 09h, 00h
		db	 08h, 30h, 09h, 00h,0C0h, 30h
		db	 09h, 01h,0B0h, 09h, 00h,0FEh
		db	0C2h,0AAh, 8Bh,0AAh, 80h, 18h
		db	 01h,0A8h, 02h,0AAh, 02h,0AAh
		db	 00h, 0Ah, 00h, 0Ah, 09h, 0Ch
		db	0C0h, 00h, 3Ah,0AAh, 02h,0A0h
		db	 2Ah, 8Eh, 09h, 00h, 2Ah, 80h
		db	 09h, 00h, 0Ah, 00h, 20h, 09h
		db	 01h, 30h, 09h, 01h,0E0h, 09h
		db	 05h, 38h, 0Fh,0EEh, 8Bh, 09h
		db	 00h,0BAh,0AAh, 00h, 28h,0A2h
		db	 2Ah, 0Ch, 2Ah, 00h, 02h, 0Ch
		db	 02h, 09h, 00h, 0Ch, 09h, 01h
		db	 0Ch, 09h, 01h, 2Ch, 09h, 01h
		db	 72h, 00h, 09h, 11h, 03h, 09h
		db	 01h, 03h, 09h, 06h, 03h,0AAh
		db	 09h, 01h, 8Ah, 00h, 30h, 00h
		db	 01h, 00h, 3Ch, 09h, 00h,0FFh
		db	0F4h, 09h, 00h, 0Ch, 20h, 09h
		db	 00h,0C0h, 20h, 09h, 01h,0A0h
		db	 09h, 00h,0AEh, 82h, 8Ah, 8Bh
		db	 0Ah, 80h, 8Ah,0AAh, 0Ah,0A8h
		db	 02h,0AAh, 02h,0AAh, 00h, 0Ah
		db	 00h, 0Ah, 09h, 0Ch,0C0h, 09h
		db	 09h, 30h, 09h, 01h,0ECh, 20h
		db	 09h, 00h, 2Bh, 20h, 09h, 00h
		db	 8Bh, 80h, 02h, 00h,0B9h,0B0h
		db	 09h, 00h, 2Fh, 88h, 02h, 20h
		db	0A9h,0D8h, 00h, 28h, 00h, 14h
		db	 00h, 3Ah, 00h, 02h, 00h, 0Eh
		db	 00h, 02h, 00h, 0Bh, 09h, 01h
		db	 0Eh, 09h, 01h, 0Bh, 09h, 01h
		db	 0Eh, 09h, 00h,0A8h, 00h,0A8h
		db	 00h,0A0h, 00h,0A0h, 09h, 0Fh
		db	 80h, 09h, 01h,0A8h, 09h, 01h
		db	 0Ah,0AAh,0EAh,0AAh, 0Ah,0A8h
		db	0CAh,0A8h, 2Ah,0A4h, 2Ah,0A4h
		db	 2Ah, 8Ch, 2Ah, 8Ch, 0Ah,0A8h
		db	 0Ah,0A8h,0B0h,0A0h, 00h,0A0h
		db	0EAh
		db	 0Ah, 09h

locloop_6:
		add	data_24[bx],ch
		add	ss:data_49e[bp+si],ch
		sub	byte ptr ss:data_51e[bp+si],0B8h
		sbb	[bp+si],al
		scasb				; Scan es:[di] for al
		test	al,0AEh
		test	al,0AAh
		mov	al,ds:data_46e
		stosb				; Store al to es:[di]
		mov	ss:data_54e[bp+si],ch
		cmp	byte ptr ss:data_49e[bp+si],0
		stosb				; Store al to es:[di]
		or	[bp+si],cx
		add	cx,[bx+di]
		add	[bx],cx
		add	data_13,ch
		mov	al,9
		add	word ptr ds:[200h],bp
		push	cs
		mov	ax,[bx+di]
		dec	bx
		or	[bx+si],ax
		or	al,9
		add	[bx+si],si
		or	[bx+di],ax
		loopnz	locloop_6		; Loop if zf=0, cx>0

		or	[bx+si],ax
		mov	ds:data_44e,ax
		add	[bp+di],cl
		or	byte ptr [bp+si],0A8h
		or	[bx+si],ax
		mov	di,ss:data_8[bp+si]
		db	 3Eh,0EBh, 09h, 00h, 2Ah,0A0h
		db	 15h, 50h,0E0h, 2Ah, 10h, 14h
		db	 02h,0A0h, 01h, 52h, 09h, 01h
		db	 3Eh, 09h, 01h, 0Bh, 09h, 01h
		db	 0Eh, 09h, 01h, 02h, 09h, 02h
		db	0EFh,0AEh, 09h, 00h,0BBh,0EBh
		db	 09h, 00h, 2Eh,0FFh, 80h, 03h
		db	 0Bh,0A0h,0E0h, 00h, 0Eh, 00h
		db	0A0h, 09h, 01h, 80h, 09h, 1Fh
		db	0A8h, 09h, 01h,0BBh,0E0h, 09h
		db	 00h,0FFh,0AFh, 09h, 00h,0BAh
		db	0FBh, 09h, 00h,0F2h,0AEh,0F0h
		db	 00h, 76h, 01h,0C0h, 0Fh,0BEh
		db	 0Fh,0BCh, 02h,0FEh, 02h,0FEh
		db	 00h, 2Bh, 00h, 29h, 00h, 0Fh
		db	 00h, 0Dh, 80h, 09h, 00h, 05h
		db	0BEh, 09h, 00h, 05h,0EEh,0E0h
		db	 00h, 07h,0BBh
loc_7:
		scasb				; Scan es:[di] for al
		add	ds:data_55e,cl
		or	[bx+si],ax
		out	dx,ax			; port 20h, 8259-1 int command
		mov	dx,0C0h
		cli				; Disable interrupts
		out	dx,al			; port 0C0h, DMA-2 bas&add ch 0
		js	$+2			; delay for I/O
		jmp	short loc_7
			                        ;* No entry point to code
		call	$+2E03h
;*		call	far ptr sub_8		;*
		db	9Ah
		dw	9AEEh, 0A829h		;  Fixup - byte match
		jmp	$+18ABh
			                        ;* No entry point to code
		add	bp,[bx+si-56h]
		db	 68h, 0Ah,0AAh, 0Ah,0AAh,0B0h
		db	0A0h, 00h,0A0h,0EAh, 0Ah, 09h
		db	 00h,0AFh,0BEh, 09h, 00h,0AAh
		db	 80h,0AAh, 80h,0A0h, 00h,0A0h
		db	 09h, 0Fh, 80h, 09h, 01h,0A8h
		db	 09h, 10h, 03h, 09h, 01h, 03h
		db	 09h, 01h, 03h, 09h, 01h, 0Eh
		db	 09h, 01h, 0Dh, 00h, 10h,0EAh
		db	0ACh, 09h, 00h,0EAh,0B0h, 00h
		db	 48h,0EAh, 88h, 00h, 02h, 6Ah
		db	0C2h, 00h, 2Ah,0ABh, 2Ah, 00h
		db	0EAh,0ACh,0EAh, 03h,0AAh,0AFh
		db	0AAh, 0Ah,0A6h,0FAh,0A6h,0AAh
		db	 5Ah,0AAh, 5Ah,0AAh,0A0h,0AAh
		db	0A0h,0A7h,0C0h,0A7h,0C0h, 5Ah
		db	0B0h, 5Ah,0B0h,0AAh,0ACh,0AAh
		db	0ACh, 6Eh,0C0h, 6Eh,0C0h,0AAh
		db	0A8h,0AAh,0A8h,0BBh, 20h,0BBh
		db	 20h, 09h, 00h, 0Fh,0AAh, 04h
		db	 01h, 0Ah,0AAh, 00h, 01h, 0Eh
		db	0AAh, 09h, 00h, 3Eh,0ABh, 10h
		db	 04h, 2Ah,0ABh, 10h, 04h, 2Ah
		db	0ABh, 09h, 00h, 3Ah,0ACh, 09h
		db	 00h,0FAh,0ACh, 00h,0AAh,0E8h
		db	0AAh, 02h,0AAh,0E2h,0AAh, 02h
		db	0A5h,0E2h,0A5h, 02h, 6Ah,0A2h
		db	 6Ah, 02h,0AAh, 82h,0AAh, 0Ah
		db	 5Ah, 0Ah, 5Ah, 29h,0AAh, 29h
		db	0AAh, 2Ah,0AAh, 2Ah,0AAh,0A0h
		db	 00h,0A0h, 00h,0A8h, 00h,0A8h
		db	 00h,0A0h, 00h,0A0h, 00h,0A8h
		db	 00h,0A8h, 00h,0A0h, 00h,0A0h
		db	 00h, 80h, 00h, 80h, 09h, 03h
		db	 80h, 00h, 80h, 09h, 02h, 03h
		db	 09h, 01h, 0Eh, 09h, 01h, 0Eh
		db	 09h, 01h, 3Eh, 09h, 01h, 3Ah
		db	 09h, 01h,0FAh, 01h, 00h, 02h
		db	0EAh, 09h, 00h, 03h,0AAh, 00h
		db	 28h,0AEh, 28h, 00h,0A8h,0ACh
		db	0A8h, 00h, 2Ah,0AEh, 2Ah, 00h
		db	0AAh,0BEh,0AAh, 02h, 2Ah,0BAh
		db	 2Ah, 00h,0AAh,0B8h,0AAh, 02h
		db	0AAh,0FAh,0AAh, 40h, 99h,0B8h
		db	 99h, 09h, 06h, 80h, 00h, 80h
		db	 09h, 03h, 80h, 00h, 80h, 09h
		db	 03h, 80h, 00h, 80h, 00h,0A0h
		db	 00h,0A0h, 09h, 11h, 40h,0C0h
		db	 09h, 00h, 4Ch, 00h, 00h, 20h
		db	0C3h,0A0h, 00h,0A8h,0A3h,0A8h
		db	 42h, 00h, 9Ah, 00h,0FEh,0EBh
		db	 7Eh, 00h,0FAh,0BBh, 7Ah, 80h
		db	 2Fh,0AEh, 23h,0A0h, 0Eh,0EAh
		db	 0Eh,0EAh, 03h,0BAh, 03h,0BAh
		db	 00h, 2Ah, 00h, 2Ah, 09h, 02h
		db	0FAh,0BAh, 09h, 00h,0AEh,0EEh
		db	 09h, 00h,0EAh,0ABh, 09h, 00h
		db	0AEh,0EEh, 09h, 00h,0EBh,0ABh
		db	 09h, 00h,0FBh,0BAh, 09h, 00h
		db	0AEh,0EEh, 09h, 00h,0EEh,0BAh
		db	 00h, 02h,0AAh, 09h, 01h,0FAh
		db	 80h, 09h, 00h,0AEh,0A0h, 09h
		db	 00h,0FBh,0A8h, 09h, 00h,0AEh
		db	0BAh, 09h, 00h,0FBh,0AAh, 09h
		db	 00h, 8Ah,0EBh, 80h, 00h,0A8h
		db	0AAh,0A8h, 09h, 13h, 80h, 09h
		db	 01h, 80h, 09h, 01h,0A0h, 09h
		db	 0Ch,0D4h, 09h, 00h, 0Fh, 43h
		db	 09h, 00h, 30h, 70h, 09h, 00h
		db	 38h,0C0h, 09h, 00h, 0Ch, 09h
		db	 03h, 3Bh,0AAh, 00h, 0Ah, 3Ah
		db	 8Ch, 09h, 01h, 03h, 0Fh, 09h
		db	 01h, 6Ch, 03h, 09h, 01h,0FCh
		db	 09h, 00h, 03h, 0Ch, 09h, 00h
		db	 03h, 0Ch, 09h, 01h,0C0h,0AAh
		db	 8Bh,0AAh, 80h, 00h,0AAh, 00h
		db	0A8h, 22h, 2Ah, 00h, 2Ah, 08h
		db	 02h,0C0h, 02h, 09h, 0Eh,0A8h
		db	 09h, 01h,0EEh, 09h, 01h, 2Ah
		db	 09h, 01h,0AEh, 19h, 00h, 00h
		db	0ABh, 80h,0A0h, 00h,0AAh, 80h
		db	0A0h, 00h,0AEh, 1Fh, 00h, 00h
		db	0AAh,0E0h,0A0h, 09h, 12h, 08h
		db	 09h, 00h, 0Ch,0F2h, 09h, 00h
		db	 03h, 3Fh, 09h, 00h, 0Eh,0BAh
		db	 09h, 13h, 02h, 00h, 02h, 00h
		db	 0Ah, 80h, 08h, 00h,0AEh,0C0h
		db	0A0h, 2Ah,0A0h, 28h, 00h, 2Bh
		db	0A0h, 20h, 00h, 2Ah, 80h, 28h
		db	 00h, 2Eh, 80h, 20h, 00h,0AAh
		db	 00h,0A0h, 00h,0AEh, 09h, 01h
		db	0E8h, 09h, 01h,0A0h, 09h, 03h
		db	 08h,0CFh, 09h, 01h,0A8h, 09h
		db	 16h, 02h,0AAh,0B0h, 00h, 2Ah
		db	 80h,0C0h, 09h, 19h, 0Fh, 55h
		db	 09h, 00h, 1Dh, 55h, 09h, 00h
		db	 3Dh, 55h, 09h, 00h, 3Dh, 55h
		db	 09h, 00h, 35h, 59h, 09h, 00h
		db	 35h, 95h, 09h, 00h, 3Dh, 55h
		db	 09h, 00h, 1Dh, 55h, 09h, 00h
		db	 50h, 02h, 00h, 04h, 91h, 0Bh
		db	 00h, 04h, 95h, 0Ah, 09h, 00h
		db	 54h, 0Fh, 09h, 00h, 65h, 0Dh
		db	 00h, 10h, 65h, 2Dh, 00h, 10h
		db	 95h, 24h, 00h, 40h, 55h, 94h
		db	 2Ah, 28h,0AAh, 28h, 2Ah, 28h
		db	0AAh, 28h, 1Ah,0AAh, 5Ah,0AAh
		db	 2Ah,0A8h, 6Ah,0A8h, 29h,0A8h
		db	 29h,0A8h, 2Ah,0A6h, 2Ah,0A6h
		db	 26h,0AAh, 26h,0AAh, 8Ah, 96h
		db	 8Ah, 96h,0C0h, 00h,0C0h, 00h
		db	 80h, 00h, 80h, 00h, 20h, 00h
		db	 20h, 00h,0B0h, 00h,0B0h, 00h
		db	0B2h, 00h,0B2h, 00h,0A3h, 00h
		db	0A3h, 00h, 8Bh, 00h, 8Bh, 00h
		db	0A8h, 00h,0A8h, 09h, 12h, 30h
		db	 09h, 01h,0F1h, 09h, 00h, 01h
		db	0D3h, 09h, 00h, 03h, 51h, 09h
		db	 13h, 01h, 00h, 02h, 00h, 01h
		db	 00h, 02h, 09h, 00h, 10h, 03h
		db	 09h, 0Ch, 30h, 09h, 00h, 30h
		db	0F0h, 30h, 08h, 88h,0E8h, 88h
		db	 0Ch, 8Ch,0ECh, 8Ch, 2Eh, 88h
		db	0AEh, 88h, 80h, 00h, 0Fh
data_16		db	55h
		db	0BEh, 09h, 00h,0D5h
data_17		db	0EEh			; Data table (indexed access)
		db	0E1h, 00h, 06h,0BBh
loc_8:
		scasb				; Scan es:[di] for al
		add	ds:data_55e,cl
		or	[bx+si],ax
		out	dx,ax			; port 0C0h, DMA-2 bas&add ch 0
		mov	dx,0C0h
		cli				; Disable interrupts
		out	dx,al			; port 0C0h, DMA-2 bas&add ch 0
		js	$+2			; delay for I/O
		jmp	short loc_8
			                        ;* No entry point to code
		call	sub_3
		add	[bp-30h],dl
		push	ax
		add	byte ptr data_7[di],ch
		and	dl,[si]
		and	al,ds:data_35e[bx+si]
		mov	[bx+si],ah
		add	[bx+si],ah
		add	[bp+si],cl
		or	[bp+si],cl
;*		or	al,ah
		db	 08h,0E0h		;  Fixup - byte match
		and	al,[bx+si]
		and	ch,data_22[bx]
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		sub	ch,ss:data_38e[bp+si]
		mov	ss:data_31e[bp+si],cl
		and	ch,[bp+si]
;*		or	byte ptr ds:data_37e[bx+si],0AAh
		db	 82h, 88h, 82h, 88h,0AAh	;  Fixup - byte match
		add	byte ptr ss:[0A00h][bp+si],ch
		mov	al,0Ah
		mov	al,22h			; '"'
		stosb				; Store al to es:[di]
		and	ch,ss:data_45e[bp+si]
		add	data_11[bx+si],ah
		lodsb				; String [si] to al
		add	[bx+si],ah
		add	[bx+si],ah
		add	ds:data_33e[bx+si],al
		or	[bx+si],bp
		add	al,[bx+si]
		add	al,[bx+si]
		or	al,[bx+si]
		or	[bx+si],al
		or	al,[bx+si]
		or	[bx+si],al
		sub	al,[bx+si]
		and	[bx+si],al
		sub	[bx+si],al
		and	[bx+si],al
		mov	al,ds:data_33e
		add	ds:data_33e[bx+si],ah
		add	data_15[bx+si],ah
                           lock	or	[bx+di],ax
		mov	sp,109h
		in	al,dx			; port 0C0h, DMA-2 bas&add ch 0
		or	[bx+di],ax
		out	dx,ax			; port 0C0h, DMA-2 bas&add ch 0
		or	[bx+di],ax
		xor	cl,[bx+di]
		add	[bx+si],di
		or	[bx+di],ax
		push	cs
		or	[bx+di],ax
		or	al,9
;*		adc	al,dh
		db	 10h,0F0h		;  Fixup - byte match
		or	[bx+di],ax
		mov	sp,109h
		db	0C0h, 09h, 01h, 30h, 09h, 0Bh
		db	 80h, 09h, 01h,0BEh, 09h, 01h
		db	0EEh,0C0h, 00h, 1Ch,0BBh, 80h
		db	 00h, 15h,0AEh,0E0h, 00h, 0Dh
		db	0EFh,0B8h,0C0h, 03h,0FAh,0ECh
		db	 78h, 03h,0EBh,0E4h,0E8h, 0Bh
		db	 09h, 0Ch, 7Ch, 09h, 01h, 55h
		db	0F4h, 09h, 00h, 4Eh, 00h, 09h
		db	 00h, 59h, 55h, 09h, 00h, 56h
		db	 55h, 09h, 14h,0C0h, 09h, 01h
		db	 50h, 09h, 01h, 5Ch, 09h, 00h
		db	 02h, 00h, 02h, 09h, 09h, 03h
		db	 09h, 01h, 0Dh, 09h, 01h, 0Dh
		db	 09h, 01h, 35h, 09h, 01h, 34h
		db	0BAh,0B4h, 9Ah, 0Bh
data_18		dw	0E0FEh
		db	 7Eh, 0Fh,0FAh, 90h, 7Ah,0ADh
		db	 2Fh, 80h, 63h,0B5h, 0Eh, 40h
		db	 1Eh, 96h, 03h, 00h, 47h,0D5h
		db	 09h, 00h, 43h, 59h, 09h, 00h
		db	 0Dh, 65h, 09h
data_19		db	0			; Data table (indexed access)
		db	56h

_366UNKN	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		db	 65h, 09h, 00h, 65h, 55h, 09h
		db	 00h, 95h
data_20		db	55h			; Data table (indexed access)
		db	 09h, 00h, 69h, 59h, 09h, 00h
		db	 4Eh, 00h, 09h, 00h, 4Eh, 00h
		db	 00h, 02h, 65h, 50h, 00h, 0Ah
		db	 55h, 52h, 09h, 00h, 55h, 09h
		db	 00h, 80h, 50h, 00h, 0Eh,0A0h
		db	 09h, 00h, 0Bh,0A8h, 40h, 00h
		db	 0Eh,0AAh, 40h, 00h, 3Bh,0AAh
		db	 09h, 00h, 8Ah,0EAh, 80h, 00h
		db	0A8h,0AAh,0A8h, 09h, 02h,0D1h
		db	 09h, 01h,0D4h, 09h, 00h, 03h
		db	 54h, 09h, 00h, 03h, 40h, 00h
		db	 01h, 0Dh, 12h, 09h, 00h, 0Dh
		db	 43h, 00h, 10h, 35h, 2Dh, 00h
		db	 40h,0D4h
data_21		dw	10BAh			; Data table (indexed access)
		db	 00h, 26h, 55h
data_22		db	9			; Data table (indexed access)
		db	 00h, 35h, 5Ah, 40h, 00h, 95h
		db	0A9h, 40h, 00h, 96h, 55h, 09h
		db	 00h, 55h,0A5h, 09h, 00h, 59h
		db	 56h, 09h, 00h, 4Eh, 00h, 09h
		db	 00h,0AAh, 55h, 00h
		db	 2Ah, 5Ah, 4Ah
data_23		db	0			; Data table (indexed access)
		db	 0Ch, 55h, 09h, 00h, 03h, 05h
		db	 09h, 01h, 50h, 03h, 09h, 00h
		db	 44h,0FCh, 09h, 00h,0A3h, 0Ch
		db	 09h, 00h, 57h, 0Ch, 09h, 00h
		db	 40h,0C0h, 09h, 13h, 11h
data_24		db	0			; Data table (indexed access)
		db	 2Eh, 01h, 00h, 02h,0EAh, 04h
		db	 00h, 0Ah,0AAh, 09h, 14h,0E8h
		db	 09h, 00h, 01h,0AAh, 0Eh, 00h
		db	 10h, 96h,0AEh, 09h, 12h, 14h
		db	 10h,0EAh,0EBh

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_4:
		or	[bx+si],ax
		sbb	[bx+si],al
		or	[bx+si],ax
;*		calls	far ptr sub_9		;*
		db	9Ah
		dw	996h, 0B818h		;  Fixup - byte match
		or	[bx+di],ax
		stosb				; Store al to es:[di]
		or	byte ptr [bx+di],11h
		add	cx,[bx+di]
		add	[bp+di],ax
		test	al,9
		add	[bp+di],al
		mov	bx,9E0h
		add	[bx+si],dl
		inc	ax
		das				; Decimal adjust
		mov	dx,800Ah
		cmp	bh,byte ptr ss:[2Ah][bp+si]
		dec	cx
		add	[bp+si],ch
;*		add	[bx+di+0],cl
		db	 00h, 49h, 00h		;  Fixup - byte match
		db	0A8h, 00h,0A8h,0EAh,0AAh, 00h
		db	 18h, 00h, 20h, 00h, 21h,0AAh
		db	 09h, 00h, 03h,0AAh, 00h, 40h
		db	0AAh,0BAh, 01h, 00h, 6Ah,0E8h
		db	 00h, 02h,0ABh,0A2h, 04h, 08h
		db	0AAh, 88h, 00h, 02h,0AEh, 02h
		db	 00h, 8Ah,0B8h, 8Ah, 00h, 20h
		db	0B8h, 20h, 00h, 88h,0E0h, 88h
		db	 09h, 00h, 03h,0EAh, 20h, 04h
		db	 20h, 3Ah, 0Ah, 08h, 0Ah, 0Bh
		db	0A2h, 20h,0A2h, 20h, 8Ah,0A0h
		db	 8Ah,0A0h, 22h, 80h, 22h, 80h
		db	0AAh, 00h,0AAh, 00h, 80h, 00h
		db	 80h, 09h, 0Ah, 03h, 09h, 01h
		db	 0Fh, 00h, 2Eh, 09h, 01h,0B0h
		db	 09h, 01h, 2Eh, 00h, 02h, 00h
		db	 8Bh, 00h, 4Bh, 09h, 00h, 0Ch
		db	 09h, 01h, 30h, 09h, 00h, 03h
		db	0E0h,0C0h, 00h, 0Eh,0A3h, 80h
		db	0A0h, 2Bh, 0Bh, 80h, 0Ah,0EFh
		db	 09h, 00h, 8Bh,0B9h, 80h, 01h
		db	 3Ah,0E9h, 00h, 01h, 03h,0A0h
		db	 00h, 50h, 0Ah,0AAh, 05h, 54h
		db	 08h, 03h, 07h, 00h, 20h, 02h
		db	 10h,0C1h, 00h, 02h, 00h, 35h
		db	 00h, 08h, 00h, 04h, 00h, 10h
		db	 09h, 04h,0EFh,0ACh, 09h, 00h
		db	0BBh,0A0h, 09h, 00h, 2Eh, 00h
		db	 80h, 00h, 08h, 00h,0E0h, 09h
		db	 01h,0A0h, 09h, 01h, 80h, 09h
		db	 1Ch, 0Fh, 09h, 01h, 3Bh, 09h
		db	 00h, 02h,0EEh, 09h, 02h, 03h
		db	0A9h, 09h, 01h,0ABh, 00h,0E5h
		db	 00h, 0Ah, 0Bh,0AEh, 00h, 0Eh
		db	0AEh,0E8h, 09h, 00h,0EFh,0BAh
		db	 09h, 00h,0BAh,0EEh, 09h, 00h
		db	0EBh,0EFh, 09h, 00h, 02h, 2Ah
		db	 62h, 31h, 00h, 18h, 01h, 22h
		db	0A2h, 22h,0A2h, 88h,0AAh, 88h
		db	0AAh, 2Ah, 8Ah, 2Ah, 8Ah, 0Ah
		db	 2Ah, 0Ah, 2Ah,0E0h, 22h, 00h
		db	 22h,0AFh, 80h
data_27		db	9
		db	 00h, 28h, 00h, 28h, 00h,0A0h
		db	 00h,0A0h, 09h, 0Fh, 80h, 09h
		db	 01h,0A8h, 09h, 04h, 03h, 09h
		db	 01h, 0Eh, 09h, 01h, 3Ah, 09h
		db	 01h, 6Ah, 09h, 01h,0E5h, 09h
		db	 01h,0AAh, 09h, 00h, 01h,0A6h
		db	 09h, 00h, 03h,0AAh, 00h, 40h
		db	 9Ah,0BAh, 01h, 00h, 6Ah,0E8h
		db	 00h, 02h,0ABh,0A2h, 04h, 08h
		db	0AAh, 88h, 00h, 02h,0AEh, 02h
		db	 00h, 8Ah,0B8h, 8Ah, 00h, 22h
		db	0B8h, 22h, 00h, 88h,0E0h, 88h
		db	 02h,0A2h, 02h,0A2h, 20h,0AAh
		db	 20h,0AAh, 0Ah, 22h, 0Ah, 22h
		db	0AAh,0A0h,0AAh,0A0h, 8Ah,0A0h
		db	 8Ah,0A0h,0A2h, 80h,0A2h, 80h
		db	0AAh, 00h,0AAh, 00h, 80h, 00h
		db	 80h, 00h, 2Ah, 20h, 2Ah, 20h
		db	 8Ah, 80h, 8Ah, 80h, 1Fh, 02h
		db	 28h, 00h, 28h, 09h, 12h,0EAh
		db	 09h, 00h, 03h,0A8h, 09h, 00h
		db	 06h,0AAh, 09h, 00h, 1Eh, 96h
		db	 09h, 00h, 39h,0A8h, 09h, 00h
		db	 6Ah,0A0h, 00h, 01h,0EAh,0AEh
		db	 00h, 10h,0D6h,0AEh, 09h, 09h
		db	 0Fh, 09h, 00h, 80h,0FAh, 09h
		db	 00h, 0Fh,0A0h, 14h, 0Ah,0EAh
		db	 0Ah, 00h,0A2h,0A8h,0A2h, 02h
		db	 88h, 92h, 88h, 00h, 0Ah, 0Fh
		db	 8Ah, 00h, 2Ah,0F8h, 2Ah, 02h
		db	0AAh, 82h,0AAh, 2Ah,0A8h, 2Ah
		db	0A8h,0AAh,0A8h,0AAh,0A8h, 28h
		db	0AAh, 28h, 18h, 00h, 2Ah,0AAh
		db	 2Ah, 88h, 80h, 88h, 80h,0A8h
		db	 00h,0A8h, 09h, 03h,0A0h, 00h
		db	0A0h, 00h,0A8h, 00h,0A8h, 09h
		db	 07h, 80h, 00h, 80h, 09h, 1Ah
		db	 03h, 09h, 01h, 0Eh, 09h, 01h
		db	 3Ah, 09h, 19h, 0Fh, 09h, 01h
		db	0F0h, 09h, 14h,0F0h, 00h, 20h
		db	 00h, 20h, 00h, 80h, 00h, 80h
		db	 00h, 0Eh,0BAh, 09h, 00h, 3Bh
		db	0EEh, 09h, 00h,0AEh,0B9h, 00h
		db	 01h,0FAh,0D5h, 00h, 15h,0ADh
		db	 5Ch, 01h, 5Ch, 97h, 00h, 17h
		db	 00h, 70h, 00h, 70h, 09h, 03h
		db	0AAh,0BAh, 09h, 00h,0AAh,0EBh
		db	 09h, 00h, 5Ah,0BBh, 5Ah, 80h
		db	0E7h,0AEh,0E7h,0A0h, 0Eh,0EAh
		db	 0Eh,0EAh, 03h
data_28		db	0BAh			; Data table (indexed access)
		db	 03h,0BAh, 00h, 2Ah, 00h, 2Ah
		db	 09h, 02h,0AAh, 09h, 01h,0FAh
		db	0A0h, 09h, 00h,0AEh,0BAh, 09h
		db	 00h,0FBh,0AEh, 09h, 00h,0AEh
		db	0BAh, 09h, 00h,0FBh,0AAh, 09h
		db	 00h, 8Ah,0EBh, 80h, 00h,0A8h
		db	0AAh,0A8h, 09h, 08h,0BEh, 09h
		db	 00h, 58h, 00h, 09h, 00h,0FBh
		db	0AFh, 09h, 00h,0AEh,0EAh, 09h
		db	 00h,0BAh,0A0h, 09h, 00h,0A8h
		db	 09h, 01h, 0Bh,0B8h, 09h, 00h
		db	0EEh,0A0h, 09h, 00h,0BAh, 80h
		db	 09h, 00h,0AAh, 09h, 01h,0A0h
		db	 09h, 22h, 02h, 09h, 01h, 0Bh
		db	 09h, 01h,0AAh, 09h, 02h, 03h
		db	 2Fh, 09h, 00h, 0Eh,0BBh, 09h
		db	 00h, 0Bh,0BCh, 09h, 00h, 3Ah
		db	0C0h,0A0h, 09h, 01h, 80h, 09h
		db	 01h, 80h, 09h, 07h, 3Ch, 09h
		db	 01h,0C0h, 09h, 2Ah, 03h, 09h
		db	 01h, 0Ch, 09h, 01h, 3Fh, 09h
		db	 01h,0CAh, 09h, 14h,0F0h, 09h
		db	 01h,0C0h, 09h, 01h,0C0h, 09h
		db	 05h,0C0h, 09h, 01h, 3Ch,0D4h
		db	 09h, 00h,0C3h, 43h, 09h, 01h
		db	 70h, 09h, 01h,0C0h, 09h, 00h
		db	 03h, 09h, 03h, 3Bh,0AAh, 00h
		db	 0Ah, 3Ah, 8Ch, 09h, 01h, 03h
		db	 0Fh, 09h, 01h, 6Eh,0C3h, 09h
		db	 01h,0ECh, 09h, 00h, 0Eh, 08h
		db	 09h, 01h, 0Ch, 09h, 01h, 30h
		db	0AAh, 8Bh,0AAh, 80h, 09h, 02h
		db	 22h, 09h, 01h, 08h, 00h,0C0h
		db	 09h, 0Fh, 03h,0A0h, 00h, 50h
		db	 0Ah,0AAh, 05h, 54h, 08h, 20h
		db	 06h, 12h, 22h, 80h, 11h, 7Eh
		db	 09h, 01h, 0Bh, 09h, 01h, 0Eh
		db	 09h, 01h, 02h, 09h, 02h,0AAh
		db	 09h, 01h,0EAh,0C0h
loc_9:
		or	[bx+si],ax
		sub	sp,word ptr ds:[9][bx+si]
		scasb				; Scan es:[di] for al
		out	dx,al			; port 800Ah ??I/O Non-standard
		mov	al,ds:data_47e
		stosb				; Store al to es:[di]
		mov	al,byte ptr ds:[0A00h]
		stosb				; Store al to es:[di]
		or	al,byte ptr ds:[2A00h][bx+si]
		add	[bx+si],ch
		or	[bp+si],dx
		mov	al,data_13
		out	dx,al			; port 800Ah ??I/O Non-standard
		or	byte ptr [bx+di],0
		stosb				; Store al to es:[di]

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_5:
		stosw				; Store ax to es:[di]
		or	[bx+si],ax
		stosb				; Store al to es:[di]
		jmp	far ptr $+1B73h
sub_3		endp

			                        ;* No entry point to code
		stosb				; Store al to es:[di]
		db	0C0h, 8Ah, 22h, 09h, 11h, 02h
		db	 09h, 00h, 03h, 0Ch, 09h, 00h
		db	 2Ch,0B3h, 09h, 00h,0FAh,0CFh
		db	 09h, 02h, 80h, 09h, 01h, 80h
		db	 09h, 01h, 84h, 00h, 0Bh,0A0h
		db	 88h, 01h, 3Bh,0AAh, 88h, 04h
		db	 3Bh,0ABh,0A0h, 00h, 2Eh,0ACh
		db	 20h, 00h,0EEh,0ACh, 09h, 0Ah
		db	 50h, 00h,0AEh
loc_10:
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		add	al,0
		cli				; Disable interrupts
		stosw				; Store ax to es:[di]
		and	[bx+si],al
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
;*		jmp	far ptr loc_16		;*
		db	0EAh
		dw	0A4h, 0BBABh		;  Fixup - byte match
			                        ;* No entry point to code
		movsb				; Mov [si] to es:[di]
		add	byte ptr ss:[9EEh][bp+di],ch
		adc	data_13[bx+si],dh
		lodsb				; String [si] to al
		or	[bx+di],ax
		lodsb				; String [si] to al
		or	[bx+di],ax
		sti				; Enable interrupts
		add	ds:data_52e[bx+si],ah
		jo	loc_9			; Jump if overflow=1
		add	bh,ds:data_36e[bx+si]
		or	data_12[bx+di],dh
		add	dh,[bx]
;*		add	byte ptr [bx+si],2Ah	; '*'
		db	 82h, 00h, 2Ah		;  Fixup - byte match
		out	dx,al			; port 0C500h ??I/O Non-standard
		sub	al,[bx+si]
;*		jmp	far ptr loc_14		;*
		db	0EAh
		dw	0EA88h, 0AA02h		;  Fixup - byte match
			                        ;* No entry point to code
		mov	dx,0AAAh
		sbb	[bx+di],al
		and	[bx+si],al
		das				; Decimal adjust
		stosb				; Store al to es:[di]
		sub	[bx+si],ax
		sub	ch,dh
		mov	[bx+si],al
		mov	bp,dx
		stosb				; Store al to es:[di]
		inc	ax
		stosb				; Store al to es:[di]
		mov	dx,80AAh
		stosb				; Store al to es:[di]
		mov	di,data_55e
		scasb				; Scan es:[di] for al
		jmp	short loc_10
			                        ;* No entry point to code
		test	al,0AAh
		test	al,0BBh
		and	ss:data_19[bp+di],bh
		add	ss:data_22[bp+si],ch
		add	ss:data_23[bp+si],ch
;*		add	bl,ch
		db	 00h,0EBh		;  Fixup - byte match
		stosb				; Store al to es:[di]
		or	[bx+si],ax
		sbb	[bx+si],al
		or	[bx+si],ax
		out	dx,ax			; port 80AAh ??I/O Non-standard
		stosw				; Store ax to es:[di]
		or	[bx+si],ax
		out	dx,al			; port 80AAh ??I/O Non-standard
		cli				; Disable interrupts
		or	[bx+si],ax
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		stosb				; Store al to es:[di]
		or	[si],cx
		or	byte ptr [bx+di],1
		stosb				; Store al to es:[di]
		or	[bx+di],ax
		test	al,0A0h
		or	[bx+si],ax
		stosb				; Store al to es:[di]
		or	byte ptr [bx+di],0
		or	byte ptr [bx+di],21h	; '!'
		sub	ch,ds:data_30e[bx+si]
		add	di,di
		adc	al,0
		xchg	si,ax
		stosb				; Store al to es:[di]
		xchg	sp,ax
		add	ds:data_40e,dl
		add	[bx],dl
		stosb				; Store al to es:[di]
		xchg	sp,ax
		add	dl,[bx]
		test	ax,90h
		push	ds
		scasw				; Scan es:[di] for ax
		nop
		add	ds:data_39e,bl
		add	ds:data_32e,bl
		add	[bp-54h],bl
		or	[bx+si],ax
		aas				; Ascii adjust
		out	dx,al			; port 80D4h ??I/O Non-standard
		or	[bx+si],ax
		sti				; Enable interrupts
		mov	bx,offset data_9
		jnz	$-100h			; Jump if not zero
		add	ah,ds:data_41e[bx+si]
		add	ah,ss:data_53e[bp+si]
		or	byte ptr ds:[0AB08h][bx+si],ch
		and	ch,byte ptr ss:[0A922h][bp+si]
		or	byte ptr ds:[0A008h][bx+si],ah
		or	[bx+si],ax
		in	al,dx			; port 80D4h ??I/O Non-standard
		or	[bx+di],ax
		stosb				; Store al to es:[di]
		db	0C0h, 09h, 00h,0EAh,0B0h, 09h
		db	 00h,0BAh,0ACh, 09h, 00h,0BEh
		db	0E8h, 09h, 00h,0AAh,0ABh, 09h
		db	 00h,0EFh,0ABh, 80h, 00h, 7Ah
		db	0B8h, 09h, 00h, 3Eh,0ECh, 08h
		db	 00h, 06h,0A0h, 09h, 00h, 0Fh
		db	0B0h, 09h, 00h, 03h, 80h, 09h
		db	 00h, 02h, 09h, 20h, 02h, 09h
		db	 05h,0BAh, 00h, 45h, 00h, 02h
		db	 00h, 21h, 09h, 01h, 08h, 09h
		db	 01h, 02h, 00h, 02h, 00h, 01h
		db	 00h, 08h, 00h, 04h, 09h, 11h
		db	 03h, 09h, 01h, 03h, 09h, 01h
		db	 0Dh, 09h, 01h, 3Dh, 09h, 01h
		db	 35h, 09h, 01h, 3Ch, 09h, 01h
		db	 03h, 01h, 00h,0D2h,0F5h, 04h
		db	 00h, 5Bh,0EAh, 09h, 00h, 5Fh
		db	 55h, 09h, 00h, 7Dh, 69h, 09h
		db	 00h, 75h, 55h, 09h, 00h,0DAh
		db	 56h, 09h, 00h,0D5h, 55h, 09h
		db	 00h,0D5h,0A5h, 09h, 00h, 95h
		db	0A5h, 09h, 00h,0A5h, 55h, 09h
		db	 00h,0A5h, 55h, 09h, 00h, 55h
		db	 50h, 09h, 00h, 55h, 54h, 09h
		db	 00h, 95h, 40h, 09h, 00h, 55h
		db	 09h, 01h, 45h, 40h, 09h, 01h
		db	 03h, 09h, 01h, 07h, 09h, 01h
		db	 07h, 09h, 01h, 01h, 09h, 10h
		db	 55h, 54h, 09h, 00h, 55h, 45h
		db	 09h, 00h, 55h, 50h, 09h, 00h
		db	 40h, 09h, 11h, 54h, 09h, 01h
		db	 40h, 09h, 19h, 9Ah,0B0h, 09h
		db	 00h,0A9h,0A8h, 09h, 00h,0AAh
		db	 5Ah, 10h, 00h, 2Ah,0AAh, 09h
		db	 00h, 0Eh, 98h, 01h, 00h, 02h
		db	0AAh, 09h, 01h,0E6h, 00h, 40h
		db	 00h,0AAh, 09h, 08h, 80h, 09h
		db	 01h, 20h, 09h, 01h, 80h, 09h
		db	 01h, 80h, 09h, 01h,0A0h, 09h
		db	 01h, 80h, 00h, 80h, 00h, 03h
		db	0A9h,0BEh, 09h, 00h,0ABh,0EEh
		db	0E5h, 00h, 0Ah,0BBh
		db	0AEh, 00h, 0Eh,0AEh,0E8h, 09h
		db	 00h,0EFh,0BAh,0C0h, 00h,0FAh
		db	0EEh, 78h, 00h,0EBh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		out	dx,ax			; port 4500h ??I/O Non-standard
		call	$+203h
		and	[bp+si+46h],ah
		add	ss:data_50e[bp+si],ch
		db	 64h, 02h, 88h, 8Ah, 88h, 8Ah
		db	 20h, 02h, 20h, 02h, 36h, 02h
		db	0E0h, 22h, 00h, 22h,0AFh, 80h
		db	 09h, 00h, 28h, 00h, 28h, 00h
		db	0A0h, 00h,0A0h, 09h, 0Fh, 80h
		db	 09h, 01h,0A8h, 09h, 04h, 3Ah
		db	 09h, 01h, 38h, 09h, 16h,0A0h
		db	 00h,0A6h,0B0h, 80h, 02h, 9Ah
		db	0B2h, 80h, 02h,0BAh, 62h, 00h
		db	 0Ah, 6Ah,0EAh, 00h, 0Ah,0A9h
		db	0CAh, 00h, 2Ah,0A7h, 2Ah, 00h
		db	0AAh,0AEh,0AAh, 02h,0AAh,0FAh
		db	 18h, 00h, 00h,0AAh, 00h,0A8h
		db	 00h,0A8h, 09h, 0Fh, 80h, 09h
		db	 01h,0A8h, 09h, 01h, 1Ah,0AAh
		db	0DAh,0AAh, 6Ah,0A8h,0EAh,0A8h
		db	 6Ah,0AAh, 6Ah,0AAh, 2Ah,0ABh
		db	 2Ah,0ABh, 0Ah,0AAh, 0Ah,0AAh
		db	0B0h,0A0h, 00h,0A0h,0EAh, 0Ah
		db	 09h, 00h,0AFh,0BEh, 09h, 02h
		db	 0Ch, 09h, 01h, 05h, 09h, 01h
		db	 1Bh, 80h, 09h, 00h, 0Eh, 80h
		db	 09h, 00h, 0Dh, 80h, 04h, 00h
		db	 1Bh, 09h, 01h, 1Ah, 09h, 01h
		db	 34h, 00h, 40h, 00h, 10h, 00h
		db	 80h, 00h, 80h, 09h, 26h, 48h
		db	 09h, 01h, 1Ah, 09h, 00h, 16h
		db	0D8h, 09h, 00h, 01h,0D3h, 09h
		db	 01h, 0Ch, 09h, 14h, 80h, 09h
		db	 01h,0A0h, 09h, 01h,0E0h, 09h
		db	 02h, 03h, 09h, 13h, 01h, 09h
		db	 01h, 03h, 09h, 02h, 90h, 09h
		db	 01h, 70h, 00h, 30h, 09h, 01h
		db	 30h, 09h, 01h, 70h, 09h, 01h
		db	 70h, 09h, 01h,0A0h, 09h, 01h
		db	 40h, 09h
loc_11:
		add	ss:data_21[bp+si],bp
;*		add	dl,ch
		db	 00h,0EAh		;  Fixup - byte match
		stosw				; Store ax to es:[di]
		or	[bx+si],ax
		sub	bp,[bp+si]
		or	[bx+si],ax
loc_12:
		scasb				; Scan es:[di] for al
		out	dx,al			; port 4500h ??I/O Non-standard
		mov	al,ds:data_48e
		sub	ah,data_20[di]
		or	dl,[bx-26h]
		add	[bp+si],al
		jmp	short $+22h
sub_6		endp

		db	 00h, 20h,0A5h, 40h, 05h, 40h
		db	0A8h, 00h,0A8h, 09h, 24h, 02h
data_29		db	9			; Data table (indexed access)
		db	 01h, 2Bh, 09h, 00h,0BBh,0AAh
		db	 09h, 14h,0BEh,0A8h, 09h, 00h
		db	0D5h,0F5h, 09h, 00h,0AAh,0A8h
		db	0AAh,0A8h, 09h, 16h, 40h, 09h
		db	 03h, 28h, 00h, 02h, 00h, 0Ch
		db	 09h, 01h, 17h, 09h, 01h, 13h
		db	 40h, 09h, 00h, 0Ch,0A0h, 09h
		db	 00h, 0Ch,0A0h, 09h, 00h, 0Ah
		db	 10h, 09h, 00h, 04h, 0Ch, 09h
		db	 00h, 01h, 19h, 00h, 00h, 80h
		db	 00h, 80h, 00h, 80h, 09h, 20h
		db	 05h, 09h, 00h,0DDh, 6Bh, 09h
		db	 00h, 65h,0BAh, 09h, 00h,0AAh
		db	 56h, 00h, 06h,0DBh, 90h,0DBh
		db	 90h, 09h, 03h, 01h, 09h, 01h
		db	 1Eh, 09h, 00h, 5Dh,0B5h, 00h
		db	 05h, 65h,0E0h, 00h,0E0h,0FAh
		db	 00h, 1Ah, 00h,0A0h, 00h,0A0h
		db	 09h, 07h

seg_a		ends



		end	start
