
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_364UNKN                                 €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    5          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_34e	equ	1712h			;*
data_35e	equ	206Ah			;*
data_36e	equ	2A80h			;*
data_37e	equ	3883h			;*
data_38e	equ	3F84h			;*
data_39e	equ	4AA7h			;*
data_40e	equ	5000h			;*
data_41e	equ	543Fh			;*
data_42e	equ	5A01h			;*
data_43e	equ	60A7h			;*
data_44e	equ	6BAFh			;*
data_45e	equ	70AFh			;*
data_46e	equ	78AFh			;*
data_47e	equ	8008h			;*
data_48e	equ	932Eh			;*
data_49e	equ	960Fh			;*
data_50e	equ	0A883h			;*
data_51e	equ	0AF00h			;*
data_52e	equ	0FC8Dh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_364UNKN	proc	far

start:
		db	0C8h, 14h, 00h, 00h, 00h, 06h
		db	 12h, 00h, 19h, 80h, 1Dh, 02h
		db	 21h, 08h, 27h,0AAh, 2Dh,0A0h
loc_3:
		xor	[bx+si+39h],ax
		db	0C0h, 41h, 03h, 42h, 0Ah, 46h
		db	 2Ah, 47h, 01h, 48h, 20h, 49h
		db	0A8h, 4Bh, 0Eh, 4Dh,0ABh, 59h
		db	0EAh, 5Bh, 28h, 5Dh, 83h, 5Eh
		db	 04h, 61h, 3Ah, 62h,0B0h
loc_4:
		db	 63h,0AFh, 64h, 05h, 65h
loc_5:
		or	al,66h			; 'f'
		lodsb				; String [si] to al
		db	 67h, 10h, 69h, 50h, 6Dh,0BAh
loc_6:
		db	 6Fh,0AEh
loc_7:
		jno	$+32h			; Jump if not overflw
		jc	loc_6			; Jump if carry Set
		jnc	$-74h			; Jump if carry=0
		jnz	loc_4			; Jump if not zero
		jbe	loc_5			; Jump if below or =
;*		ja	loc_8			;*Jump if above
		db	 77h, 2Bh		;  Fixup - byte match
		jns	loc_3			; Jump if not sign
		jle	loc_7			; Jump if < or =
		and	word ptr ss:data_38e[bp+si],0B887h
		mov	ds:data_52e[si],di
		xchg	cx,ax
		xor	dx,ss:data_48e[bp+si]
;*		adc	byte ptr ds:data_49e[si],0Bh
		db	 82h, 94h, 0Fh, 96h, 0Bh	;  Fixup - byte match
		xchg	di,ax
		adc	al,98h
		adc	ax,3899h
		db	 9Bh, 0Dh, 9Ch, 3Eh, 9Dh, 54h
		db	 9Eh,0A3h, 9Fh,0E0h,0A4h,0FFh
		db	0B4h
loc_8:
		push	es
		mov	ch,3Bh			; ';'
		mov	dh,0BFh
		mov	bp,0C6ECh
		cmpsw				; Cmp [si] to es:[di]
		db	0C7h,0ADh,0C9h,0DAh,0CDh,0F8h
		db	0D0h, 55h,0D1h, 7Ah,0D3h,0E7h
		db	0D7h, 2Ch,0D8h,0CCh,0D9h,0DBh
		db	0DCh, 70h,0E1h,0CFh,0E4h, 22h
		db	0E5h, 23h,0E6h, 32h,0F9h
		db	3Dh
data_3		dw	0FFFFh			; Data table (indexed access)
data_4		db	12h
		db	 2Eh, 28h, 00h, 28h, 00h,0BAh
		db	 00h, 8Ah, 00h,0AFh, 00h,0AFh
		db	 03h, 2Ch, 20h, 2Ch, 1Fh, 12h
		db	 0Fh, 28h, 00h, 28h, 80h,0BAh
		db	 40h, 8Ah, 00h,0AFh,0B0h,0AFh
		db	 00h, 2Ch,0EFh, 2Ch, 12h, 0Fh
		db	0AAh, 00h, 55h, 0Ah, 80h, 05h
		db	 00h, 20h, 00h, 10h, 12h, 0Fh
		db	0AAh, 00h, 55h,0C0h,0AAh, 00h
		db	 01h,0FEh, 12h, 00h, 02h,0AAh
		db	 12h, 01h, 0Ah, 12h, 0Dh, 03h
		db	 12h, 01h, 02h, 12h, 01h
		db	3Bh
data_5		db	12h
		db	 01h,0EAh, 12h, 00h, 03h,0AAh
		db	 12h, 00h, 02h,0A8h, 12h, 14h
		db	0F8h, 12h, 01h,0AFh,0E0h, 12h
		db	 00h, 28h,0BFh, 12h, 0Dh, 03h
		db	 00h, 02h, 00h, 3Dh, 00h, 80h
		db	 00h, 6Eh, 12h, 00h, 03h,0AFh
		db	 12h, 00h
data_6		dw	0FF0Fh			; Data table (indexed access)
		db	 12h, 00h, 03h,0A8h, 12h, 00h
		db	0F0h, 2Bh, 12h, 00h,0EBh, 0Ah
		db	 12h, 00h, 3Ah,0B2h, 12h, 00h
		db	0AAh,0ABh, 12h, 00h, 02h,0EAh
		db	 12h, 00h, 0Fh, 23h, 00h, 02h
		db	0EAh,0FAh, 20h, 00h,0DBh,0C2h
		db	 12h, 00h,0FCh, 2Eh, 12h, 00h
		db	0ABh,0AAh, 12h, 00h, 8Ah,0B8h
		db	 12h, 00h, 2Ah,0A0h, 12h, 00h
		db	0B0h,0AEh, 12h, 00h,0ABh, 2Ah
		db	 12h, 00h, 3Eh, 82h, 28h, 12h
		db	 00h, 3Ah, 38h, 00h, 03h,0EBh
		db	 38h, 82h, 80h, 7Dh, 28h, 00h
		db	 80h,0EEh, 28h, 02h, 80h,0ACh
		db	 0Ah, 08h, 80h, 33h, 0Ah, 08h
		db	0F0h, 23h, 12h, 00h, 38h,0E2h
		db	 00h, 28h,0FFh, 00h, 08h, 38h
		db	0F6h,0C0h, 00h, 28h,0BAh, 12h
		db	 00h, 2Ah,0BFh, 00h, 20h, 38h
		db	0CFh, 01h, 08h,0A8h,0F3h, 01h
		db	 08h,0A0h,0F0h, 04h, 12h, 00h
		db	0C2h,0A0h, 12h, 00h, 27h, 00h
		db	 12h, 00h,0A8h, 33h, 02h, 08h
		db	 80h, 12h, 04h, 88h,0A0h, 12h
		db	 01h,0ABh,0A0h, 12h, 00h,0BAh
		db	0AAh, 12h, 00h,0A8h, 2Ah, 12h
		db	 00h, 2Ah,0AAh, 12h, 00h,0A3h
		db	 83h, 21h, 00h,0C0h, 12h, 03h
		db	 08h, 80h, 00h, 0Eh, 12h, 00h
		db	 03h,0EAh, 12h, 00h, 3Ah,0AEh
		db	 12h, 00h, 28h, 2Ah, 12h, 0Ch
		db	0C0h, 00h, 80h, 00h, 7Ch, 00h
		db	 02h, 00h,0B9h, 12h, 01h,0FAh
		db	0C0h, 12h, 00h,0FFh,0F0h, 12h
		db	 09h, 03h, 12h, 01h, 03h, 12h
		db	 01h, 02h, 12h, 01h, 03h, 12h
		db	 01h, 03h, 00h, 02h, 00h, 01h
		db	 00h, 08h, 83h,0E7h, 12h, 00h
		db	0B8h, 3Fh, 12h, 00h,0AAh,0EAh
		db	 12h, 00h
data_7		db	2Eh			; Data table (indexed access)
		db	0A2h, 12h, 00h, 0Ah,0A8h, 12h
		db	 00h,0BAh, 83h, 12h, 00h,0A8h
		db	0BAh, 12h, 00h, 8Ah,0BCh, 12h
		db	 00h, 2Ah,0C0h, 12h, 00h,0E8h
		db	 12h, 01h,0A0h, 12h, 01h, 80h
		db	 2Fh, 12h, 00h, 0Bh,0AAh, 12h
		db	 00h, 27h, 00h, 12h, 00h,0EAh
		db	 19h, 00h, 00h,0AFh, 12h, 15h
		db	0BEh, 12h
data_8		db	0			; Data table (indexed access)
		db	 2Ah,0ABh,0D5h, 00h, 2Ah,0AAh
		db	0C0h, 12h, 1Ah,0A8h, 00h, 54h
		db	 12h, 11h,0F0h, 12h, 01h,0CCh
		db	 12h, 01h, 2Ah,0C0h, 12h, 00h
		db	 2Ah,0ACh, 2Ah, 80h, 01h, 40h
		db	 00h, 20h, 00h, 10h, 12h, 18h
		db	 0Eh, 8Fh, 12h, 00h, 04h,0BAh
		db	 12h, 00h, 0Eh, 2Ah, 12h, 00h
		db	 0Ah,0B0h, 12h, 00h, 0Eh, 80h
		db	 12h, 00h, 6Eh, 80h, 12h, 00h
		db	 6Ah,0A0h, 12h, 00h, 33h,0B0h
		db	 00h, 20h, 0Ah, 90h, 00h,0A0h
		db	 00h, 40h, 00h,0A2h, 00h, 55h
		db	 00h, 22h, 00h, 11h, 00h, 28h
		db	 00h, 14h, 00h, 0Ah, 00h, 05h
		db	 00h, 02h, 00h, 01h, 12h, 02h
		db	 02h, 20h,0A9h,0DAh, 02h, 08h
		db	0ADh,0FAh, 12h, 00h, 0Eh,0EBh
		db	 00h, 83h, 0Ah,0ACh, 00h, 1Dh
		db	 00h,0ADh, 12h, 01h, 3Bh, 00h
		db	 08h, 00h, 3Ah, 12h, 01h, 02h
		db	 00h, 20h, 83h,0E8h, 12h, 00h
		db	 3Fh, 59h, 00h, 00h, 15h,0FCh
		db	 80h, 20h, 7Fh,0DFh, 1Dh, 00h
		db	0FEh,0FDh, 12h, 00h,0AAh,0AFh
		db	 12h, 00h, 82h,0AAh, 12h, 00h
		db	0F8h, 12h, 0Bh,0A0h, 00h, 40h
		db	 12h, 0Bh, 80h, 00h, 40h, 12h
		db	 01h, 2Ah,0FFh, 12h, 01h,0AAh
		db	 12h, 16h, 02h, 80h, 2Ah, 80h
		db	 03h,0A0h, 83h,0AAh, 00h,0E8h
		db	 00h,0E8h
loc_9:
		adc	al,[bx+si]
		db	0C0h, 12h, 01h,0F0h, 12h
loc_10:
;*		add	sp,di
		db	 01h,0FCh		;  Fixup - byte match
		adc	al,[bx+di]
		scasw				; Scan es:[di] for ax
		adc	al,[bx+di]
		sub	ax,[bx+si]
		add	ax,ds:data_50e[bx+si]
		push	cs
		sub	byte ptr ss:data_36e[bp],0
		sub	dl,[bp+si]
		add	al,[bp+di]
		add	[bp+si],al
		add	[di],cl
		add	[bx+si],cl
		add	[bx],dh
		adc	al,[bx+di]
		xor	ax,112h
;*		aam	12h			; undocumented inst
		db	0D4h, 12h		;  Fixup - byte match
		add	byte ptr data_6[bx+si],al
		mov	al,ds:data_34e
		or	[bx+si],al
		sub	ax,dx
		adc	al,[bx+si]
		stosw				; Store ax to es:[di]
		cld				; Clear direction
		add	ss:data_41e[bp+di],ch
		or	[bp+si],al
		idiv	bp			; ax,dx rem=dx:ax/reg
		sbb	[bx+si],ax
		jg	loc_10			; Jump if >
		adc	al,[bx+si]
		cli				; Disable interrupts
		stosb				; Store al to es:[di]
		adc	al,[bx+si]
		stosb				; Store al to es:[di]
;*		add	byte ptr [bx+si],2
		db	 82h, 00h, 02h		;  Fixup - byte match
		add	ds:data_47e,bh
		cmpsw				; Cmp [si] to es:[di]
		inc	ax
		and	ds:data_45e[bx+si],al
		adc	al,[bx+si]
		jmp	short loc_9
		db	0C2h, 00h, 3Ah,0ACh, 80h, 00h
		db	 7Ah,0A3h, 12h, 00h,0ECh, 2Ah
		db	 20h, 00h,0ACh, 0Ah, 12h, 00h
		db	0A0h, 02h, 12h, 00h, 03h,0EAh
		db	 12h, 00h, 0Eh,0A8h, 12h, 00h
		db	0EAh, 12h, 15h, 80h, 12h, 08h
		db	 0Ah, 00h, 05h, 12h, 0Bh, 02h
		db	 00h, 01h, 12h, 00h, 02h,0ABh
		db	 12h, 01h, 28h, 12h, 01h, 02h
		db	 12h, 01h, 0Ah, 12h, 01h, 0Ah
		db	 12h, 00h,0C0h, 2Bh, 00h,0A0h
		db	0C0h, 58h, 00h,0A0h,0B2h, 50h
		db	 12h, 08h,0C0h, 12h, 01h,0C0h
		db	 12h, 0Fh, 0Ah, 80h,0A5h, 40h
		db	 28h, 00h, 95h, 00h,0A0h, 00h
		db	 50h, 00h, 30h, 00h, 40h, 00h
		db	0A0h, 00h, 50h, 00h, 80h, 00h
		db	 40h, 00h, 80h, 00h, 40h, 12h
		db	 14h, 02h, 00h, 02h, 00h, 0Bh
		db	 00h, 08h, 00h, 0Ah, 00h, 0Ah
		db	 00h, 02h, 00h, 02h, 12h, 0Eh
		db	 80h, 00h, 80h, 00h,0A0h, 00h
		db	0A0h, 00h,0F0h, 00h,0F0h, 03h
		db	0C0h, 20h,0C0h, 1Fh, 12h, 12h
		db	 80h, 02h, 40h, 02h, 00h, 02h
		db	0B0h, 02h, 12h, 00h,0EFh, 12h
		db	 0Fh, 20h, 00h, 20h, 00h,0E8h
		db	 00h, 28h, 00h,0BCh, 00h,0BCh
		db	 00h,0B0h, 00h,0B0h, 12h, 1Ch
		db	 2Ah, 00h
data_9		db	15h
		db	 12h, 15h,0BEh,0A8h, 00h, 57h
		db	0EAh,0A8h, 00h, 03h,0AAh, 02h
		db	0A8h, 01h, 40h, 08h, 00h
data_10		db	4			; Data table (indexed access)
		db	 12h, 2Ah, 03h, 12h, 01h, 0Eh
		db	 12h, 01h, 3Ah, 12h, 01h, 2Ah
		db	 12h, 00h,0EAh, 80h, 12h, 00h
		db	 28h, 12h, 01h, 40h, 12h, 01h
		db	 40h, 12h, 01h, 40h, 12h, 01h
		db	 40h, 00h, 80h, 00h, 40h, 00h
		db	 80h, 00h, 40h, 12h, 00h, 03h
		db	 12h, 01h, 02h, 12h, 07h, 03h
		db	 00h, 02h, 00h, 3Dh, 00h, 80h
		db	 00h, 6Eh, 12h, 00h, 03h,0AFh
		db	 12h, 00h, 0Fh,0FFh, 12h, 00h
		db	 03h,0A8h, 12h, 01h, 2Bh, 12h
		db	 01h, 0Ah, 12h, 00h,0F0h, 02h
		db	 12h, 00h,0AAh,0C0h, 12h, 00h
		db	 2Ah,0AAh, 12h, 00h,0CAh,0A3h
		db	 00h, 02h, 80h,0FAh, 20h, 00h
		db	0DBh,0C2h, 12h, 00h,0FCh, 2Eh
		db	 12h, 00h,0ABh,0AAh, 12h, 00h
		db	 8Ah,0B8h, 12h, 00h, 2Ah,0A0h
		db	 12h, 00h,0C0h,0AEh, 12h, 00h
		db	0ABh, 2Ah, 12h, 00h, 3Eh,0A2h
		db	 80h, 12h, 00h, 3Ah, 80h, 00h
		db	 03h,0EBh,0A0h, 82h, 03h, 7Dh
		db	0E0h, 00h, 03h,0EEh, 28h, 02h
		db	 80h,0ACh, 3Ah, 08h, 80h, 33h
		db	 0Ah, 08h,0F0h, 23h, 12h, 00h
		db	 38h,0E2h, 12h, 00h,0FFh, 00h
		db	 08h, 00h,0F6h,0F0h, 00h, 03h
		db	0BAh,0FCh, 00h, 82h,0BFh, 6Ch
		db	 20h, 0Eh,0CFh,0A0h, 08h, 2Ah
		db	0F3h,0C0h, 08h, 28h,0F0h, 80h
		db	 12h, 00h,0C2h,0A0h,0C0h, 12h
		db	 01h, 80h, 12h, 07h,0C0h, 00h
		db	 80h, 00h, 7Ch, 00h, 02h, 00h
		db	0B9h, 12h, 01h,0FAh,0C0h, 12h
		db	 00h,0FFh,0F0h, 12h, 15h, 2Fh
		db	 12h, 00h, 0Bh,0FAh, 12h, 00h
		db	0FEh, 28h, 00h, 08h, 83h,0E7h
		db	 12h, 00h,0B8h, 3Fh, 12h, 00h
		db	0AAh,0EAh, 12h, 00h, 2Eh,0A2h
		db	 12h, 00h, 0Ah,0A8h, 12h, 00h
		db	0BAh, 80h, 12h, 00h,0A8h, 0Ah
		db	 12h, 00h, 8Ah,0BCh, 12h, 00h
		db	 2Ah,0C0h, 12h, 00h,0E8h, 12h
		db	 01h,0A0h, 12h, 01h, 80h, 12h
		db	 02h, 01h, 12h, 00h, 0Ah,0BBh
		db	 12h, 00h,0EAh,0AAh, 80h, 00h
		db	0AFh,0AEh, 12h, 0Bh,0AAh, 03h
		db	 55h, 00h,0AAh,0BFh, 40h, 12h
		db	 00h,0AAh, 80h, 12h, 00h,0A0h
		db	 12h, 13h,0AAh, 00h, 55h, 00h
		db	 02h,0A0h, 00h, 50h, 00h, 08h
		db	 00h, 04h, 12h, 18h,0C0h, 12h
		db	 01h,0B0h, 12h, 01h, 20h, 12h
		db	 02h,0EAh, 12h, 00h, 03h,0A8h
		db	 12h, 01h, 82h, 12h, 00h, 03h
		db	0A2h, 12h, 01h,0A2h, 12h, 00h
		db	 03h,0E0h, 12h, 00h, 0Eh,0EAh
		db	 12h, 00h, 3Ah,0AAh, 12h, 07h
		db	 03h, 12h, 01h, 02h, 00h, 01h
		db	 00h, 0Eh, 12h, 01h, 0Ah, 00h
		db	 04h, 00h, 08h, 00h, 04h, 00h
		db	 08h, 00h, 04h, 80h, 00h, 68h
		db	 3Ah,0A0h, 00h, 40h, 0Ah, 80h
		db	 02h, 00h, 01h, 12h, 01h, 01h
		db	 12h, 10h,0ACh, 12h, 01h,0A8h
		db	 12h, 01h,0ABh, 12h, 01h, 2Bh
		db	 12h, 01h,0DAh, 12h, 01h, 82h
		db	 12h, 01h,0ACh, 00h, 02h, 00h
		db	0B1h, 00h, 0Bh, 00h,0C4h, 00h
		db	 02h, 00h, 01h, 40h, 02h,0C0h
		db	 01h, 12h, 00h, 80h, 02h, 40h
		db	 00h, 80h, 00h, 40h, 00h, 80h
		db	 00h, 40h, 00h, 80h, 00h, 40h
		db	 00h, 80h, 00h, 40h, 02h, 20h
		db	 09h,0DAh, 02h, 08h,0EDh,0FAh
		db	 12h, 00h,0AEh,0EBh, 00h, 83h
		db	0AAh,0ACh, 00h, 1Dh, 00h,0ADh
		db	 12h, 01h, 3Bh, 00h, 08h, 00h
		db	 3Ah, 12h, 01h, 0Ah, 08h, 80h
		db	0A7h, 40h, 20h, 80h,0AFh, 70h
		db	 12h, 00h,0EBh,0BCh,0C2h, 00h
		db	 3Ah,0A7h, 80h, 00h, 7Ah, 85h
		db	 12h, 00h,0ECh, 01h, 20h, 00h
		db	0ACh, 02h, 12h, 00h,0A0h, 0Ah
		db	 12h, 00h, 80h, 02h, 80h, 12h
		db	 01h, 80h, 12h, 01h,0A0h, 00h
		db	 40h, 00h,0A0h, 00h, 40h, 00h
		db	 28h, 00h, 50h, 00h, 0Ah, 00h
		db	 01h, 12h, 00h,0A0h, 00h, 10h
		db	 12h, 00h,0ABh,0C0h, 12h, 00h
		db	 2Ah,0B0h, 12h, 01h,0ABh, 12h
		db	 15h, 02h, 12h, 01h, 0Eh, 12h
		db	 18h,0FFh,0AAh, 12h, 00h,0AAh
		db	0A0h, 12h, 07h, 0Ah, 00h, 01h
		db	 12h, 0Ch, 80h,0AAh, 02h, 80h
		db	 00h, 2Ch, 0Ah, 80h, 00h, 40h
		db	 28h, 00h, 95h, 00h, 80h, 00h
		db	 50h, 12h, 22h, 03h, 12h, 01h
		db	 0Eh, 12h, 01h, 08h, 12h, 00h
		db	 03h,0A8h, 12h, 01h, 2Bh, 12h
		db	 01h, 0Ah, 12h, 01h, 02h, 12h
		db	 00h, 40h, 12h, 01h,0EEh,0A0h
		db	 12h, 00h,0AAh,0ABh, 00h, 02h
		db	0BAh,0FAh, 20h, 00h,0DBh,0C2h
		db	 12h, 00h,0FCh, 2Eh, 12h, 00h
		db	0ABh,0AAh, 12h, 00h, 8Ah,0B8h
		db	 12h, 00h, 2Ah,0A0h, 12h, 00h
		db	 02h,0AEh, 12h, 00h,0A0h, 2Ah
		db	 12h, 00h, 3Eh,0A2h, 00h, 08h
		db	 83h,0E7h, 12h, 00h,0B8h, 3Fh
		db	 12h, 00h,0AAh,0EAh, 12h, 00h
		db	 2Eh,0A2h, 12h, 00h, 0Ah,0A8h
		db	 12h, 00h,0BAh, 03h, 12h, 00h
		db	0A8h,0EAh, 12h, 00h, 8Ah,0BCh
		db	 12h, 00h, 2Ah,0C0h, 12h, 00h
		db	0E8h, 12h, 01h,0A0h, 12h, 01h
		db	 80h, 0Fh, 12h, 00h, 03h,0AAh
		db	 12h, 00h,0AAh,0A8h, 12h, 00h
		db	0CAh,0A3h, 80h, 00h,0AFh, 02h
		db	 12h, 10h,0C0h, 12h, 01h,0B0h
		db	 12h, 01h,0ACh, 12h, 01h,0A8h
		db	 12h, 02h, 3Ah, 12h, 01h, 2Ah
		db	 12h, 01h,0EAh, 12h, 01h,0E8h
		db	 12h, 01h,0A7h, 12h, 01h, 82h
		db	 12h, 01h, 3Ah, 00h, 80h, 00h
		db	 4Eh, 00h,0E0h, 00h, 13h, 00h
		db	 80h, 01h, 40h, 03h, 80h
data_11		db	0			; Data table (indexed access)
		db	 40h, 02h, 00h, 01h, 80h, 02h
		db	 00h, 01h, 00h, 02h, 00h, 01h
		db	 00h, 02h, 00h, 01h, 00h, 02h
		db	 00h, 01h, 00h, 02h, 20h, 01h
		db	0DAh, 02h, 08h, 0Dh,0FAh, 12h
		db	 00h, 36h,0EBh, 00h, 83h,0D2h
		db	0ACh, 00h, 02h, 52h,0ADh, 12h
		db	 00h, 40h, 3Bh, 00h, 08h, 80h
		db	 3Ah, 12h, 00h,0A0h, 02h, 12h
		db	 00h,0AAh, 00h, 02h, 80h, 38h
		db	 00h, 02h,0A0h, 01h, 12h, 00h
		db	 28h, 00h, 56h, 00h, 02h, 00h
		db	 05h, 12h, 0Ch, 2Ah,0FFh, 12h
		db	 01h,0AAh, 12h, 06h,0A8h, 00h
		db	 40h, 12h, 0Bh, 08h, 80h,0A7h
		db	 60h, 20h, 80h,0AFh, 7Bh, 12h
		db	 00h,0EBh,0BAh,0C2h, 00h, 3Ah
		db	0AAh, 80h, 00h, 7Ah, 80h, 12h
		db	 00h,0ECh, 00h, 20h, 00h,0ACh
		db	 12h, 01h,0A0h, 12h, 01h,0FFh
		db	0AAh, 12h, 00h,0AAh,0A0h, 12h
		db	 18h, 80h, 02h, 00h, 02h, 12h
		db	 01h, 02h, 12h, 01h, 0Ah, 00h
		db	 01h, 00h, 0Ah, 00h, 01h, 00h
		db	 28h, 00h, 05h, 00h,0A0h, 00h
		db	 40h, 0Ah, 00h, 04h, 12h, 01h
		db	0ABh, 12h, 01h, 2Ah,0C0h, 12h
		db	 00h,0B2h, 12h, 01h, 9Ah,0C0h
		db	 12h, 00h, 9Ah, 12h, 01h, 2Bh
		db	0C0h, 12h, 00h,0ABh,0B0h, 12h
		db	 00h,0AAh,0ACh, 00h, 02h,0ACh
		db	 29h, 00h, 0Ah,0A0h, 01h, 80h
		db	 02h, 40h, 12h, 01h, 40h, 12h
		db	 17h,0C0h, 12h, 01h, 80h, 00h
		db	 40h, 00h,0B0h, 12h, 01h,0A0h
		db	 00h, 10h, 00h, 20h, 00h, 10h
		db	 00h, 20h, 00h, 10h, 12h, 12h
		db	 0Fh, 12h, 01h, 33h, 12h, 00h
		db	 03h,0A8h, 12h, 00h, 3Ah,0A8h
		db	 12h, 00h, 03h,0A8h, 12h, 01h
		db	 2Bh, 12h, 01h, 0Ah, 12h, 00h
		db	0F8h, 02h, 12h, 00h,0AAh,0E0h
		db	 12h, 00h, 27h, 00h, 12h, 00h
		db	 02h,0ABh, 00h, 02h, 00h,0FAh
		db	 20h, 00h,0DBh,0C2h, 12h, 00h
		db	0FCh, 2Eh, 12h, 00h,0ABh,0AAh
		db	 12h, 00h, 8Ah,0B8h, 12h, 00h
		db	 2Ah,0A0h, 12h, 00h,0C2h,0AEh
		db	 12h, 00h,0AEh, 2Ah, 12h, 00h
		db	3Eh
data_12		db	0A2h			; Data table (indexed access)
		db	 00h, 08h, 83h,0E7h, 12h, 00h
		db	0B8h, 3Fh, 12h, 00h,0AAh,0EAh
		db	 12h, 00h, 2Eh,0A2h, 12h, 00h
		db	 0Ah,0A8h, 12h, 00h,0BAh, 0Eh
		db	 12h, 00h,0A8h,0EAh, 12h, 00h
		db	 82h,0BCh, 12h, 00h, 2Ah,0C0h
		db	 12h, 00h,0E8h, 0Fh, 12h, 00h
		db	0A0h,0EBh, 12h, 00h, 8Eh,0ACh
		db	 12h, 00h,0EAh,0AAh, 12h, 00h
		db	0ABh, 80h, 12h, 00h,0C8h,0F0h
		db	 80h, 00h,0AFh,0ABh, 12h, 08h
		db	0C0h, 12h, 01h, 80h, 12h, 01h
		db	0ECh, 12h, 01h,0ABh, 12h, 01h
		db	0AAh,0C0h, 12h, 00h, 2Ah, 80h
		db	 12h
		db	9
loc_11:
		add	dx,[bp+si]
		add	[bp+di],ax
		adc	dl,[bx+si]
;*		jmp	far ptr loc_2		;*
		db	0EAh
		dw	1280h, 2800h		;  Fixup - byte match
		db	 12h, 01h, 80h, 12h, 01h,0A0h
		db	 12h, 01h,0A0h, 12h, 01h,0E8h
		db	 00h, 0Ah, 00h, 25h, 01h, 0Ah
		db	 00h, 05h, 86h, 02h,0A0h, 01h
		db	 5Ah, 00h, 28h, 00h, 56h, 00h
		db	 0Ah, 00h, 05h, 00h, 0Ch, 00h
		db	 01h, 00h, 0Ah, 00h, 05h, 00h
		db	 02h, 00h, 01h, 00h, 02h, 00h
		db	 01h, 12h, 02h, 02h, 20h, 01h
		db	0DAh, 02h, 08h, 0Dh,0FAh, 12h
		db	 00h, 06h,0EBh, 00h, 83h, 1Ah
		db	0ACh, 00h, 02h, 38h,0ADh, 12h
		db	 00h,0E8h, 3Bh, 00h, 08h,0A8h
		db	 3Ah, 12h, 00h,0A0h, 02h, 12h
		db	 00h, 80h, 12h, 07h,0A0h, 00h
		db	 50h, 12h, 0Bh, 80h, 00h, 40h
		db	 00h, 08h, 80h,0A7h, 6Ah, 20h
		db	 80h,0AFh, 7Ah, 12h, 00h,0EBh
		db	0B0h,0C2h, 00h, 3Ah,0A0h, 80h
		db	 00h, 7Ah, 80h, 12h, 00h,0ECh
		db	 00h, 20h, 00h,0ACh
loc_12:
		adc	al,[bx+di]
		mov	al,byte ptr data_6
		adc	byte ptr [bp+si],18h
		add	al,[bx+si]
		add	[bp+si],dx
;*		add	dl,dh
		db	 00h,0F2h		;  Fixup - byte match
		mov	al,12h
		add	byte ptr ss:data_6[bp],ch
		test	al,0B0h
		adc	al,[bx+si]
		push	cs
		lodsb				; String [si] to al
		adc	al,[bx+si]
		add	bh,ss:data_13[bp+di]
		add	dh,data_7[bx+di]
		or	ah,byte ptr ds:[12h][bx+si]
		push	cs
		db	0C0h, 12h, 12h, 80h, 00h, 40h
		db	 00h,0B0h, 00h, 40h, 00h,0A0h
		db	 00h, 10h, 00h, 08h, 00h, 06h
		db	 80h, 0Ah, 00h, 05h, 00h, 0Ah
		db	 00h, 05h, 00h, 08h, 00h, 04h
		db	 00h, 28h, 00h, 14h, 00h,0A0h
		db	 00h, 50h, 00h, 80h, 00h, 40h
		db	 12h, 03h, 28h, 00h, 04h, 00h
		db	 08h, 00h, 04h, 00h, 0Bh, 12h
		db	 01h, 02h, 00h, 01h, 00h, 02h
		db	 12h, 20h, 0Fh, 12h, 01h, 33h
		db	 12h, 00h, 03h,0A8h, 12h, 00h
		db	 3Ah,0A8h, 00h, 03h, 12h, 01h
		db	 02h, 00h, 01h, 00h, 02h, 00h
		db	 01h, 12h, 12h, 80h, 00h, 40h
		db	 03h, 80h, 00h, 40h, 02h, 80h
		db	 00h, 40h, 02h, 80h, 00h, 40h
		db	 01h,0C0h, 12h, 01h, 10h, 00h
		db	 20h, 12h, 07h, 02h, 20h, 01h
		db	0DAh, 02h, 08h, 01h,0FAh, 12h
		db	 00h, 03h,0EBh, 00h, 83h, 06h
		db	0ACh, 00h, 02h, 0Eh,0ADh, 12h
		db	 00h, 3Ah, 3Bh, 00h, 08h,0E8h
		db	 3Ah, 12h, 00h,0A0h, 0Ah, 12h
		db	 00h, 20h, 02h, 12h, 00h, 80h
		db	 00h, 80h, 00h, 40h, 00h,0A0h
		db	 00h, 50h, 00h,0A0h, 00h, 50h
		db	 00h, 28h, 00h, 14h, 00h, 0Ah
		db	 00h, 05h, 12h, 00h,0A0h, 00h
		db	 50h, 12h, 00h, 80h, 12h, 1Dh
		db	0F2h,0B0h, 12h, 00h,0AEh, 0Ch
		db	 12h, 00h,0AAh,0ABh, 12h
data_13		db	0			; Data table (indexed access)
		db	 0Eh, 8Bh, 12h, 01h, 8Ah, 12h
		db	 01h, 22h, 00h, 10h, 00h, 0Ah
		db	 00h, 10h, 00h, 0Ah, 12h, 10h
		db	0C0h, 12h, 01h,0C0h, 12h, 01h
		db	0C0h, 12h, 01h,0C0h, 12h, 00h
		db	 18h, 00h, 06h, 00h, 9Ah, 00h
		db	 45h, 00h, 9Ah, 00h, 45h, 02h
		db	 88h, 01h, 44h, 0Ah, 28h, 05h
		db	 14h, 48h, 00h, 14h, 10h, 00h
		db	 20h, 00h, 10h, 00h, 80h, 00h
		db	 40h, 12h, 19h, 03h, 12h, 01h
		db	 30h, 12h, 00h, 03h,0A8h, 12h
		db	 01h, 2Bh, 12h, 01h, 0Ah, 12h
		db	 01h, 02h, 12h, 04h, 3Fh, 12h
		db	 01h,0EAh,0ABh, 00h, 02h,0AAh
		db	0FAh, 20h, 00h,0DBh,0C2h, 12h
		db	 00h,0FCh, 2Eh, 12h, 00h,0ABh
		db	0AAh, 12h, 00h, 8Ah,0B8h, 12h
		db	 00h, 2Ah,0A0h, 12h, 00h, 02h
		db	0AEh, 12h, 00h,0AEh, 2Ah, 12h
		db	 00h, 3Eh,0A2h, 00h, 08h, 83h
		db	0E7h, 12h, 00h,0B8h, 3Fh, 12h
		db	 00h,0AAh,0EAh, 12h, 00h, 2Eh
		db	0A2h, 12h, 00h, 0Ah,0A8h, 12h
		db	 00h,0BAh, 80h, 12h, 00h,0A8h
		db	0BAh, 12h, 00h, 8Ah,0BCh, 12h
		db	 00h, 2Ah,0C0h, 12h, 00h,0E8h
		db	 12h, 01h,0A0h, 12h, 01h, 80h
		db	 12h, 06h,0FCh, 12h, 00h,0EAh
		db	0ABh, 80h, 00h,0AFh,0AAh, 12h
		db	 18h,0C0h, 12h, 01h, 0Ch, 12h
		db	 0Eh, 03h, 12h, 01h, 0Ch, 12h
		db	 01h, 0Eh, 12h, 01h, 0Eh, 12h
		db	 01h, 0Eh, 12h, 00h, 03h,0A8h
		db	 12h, 00h, 0Eh,0A8h, 12h, 00h
		db	0FAh, 83h, 12h, 00h,0AAh, 0Eh
		db	 12h, 00h, 20h, 3Ah, 12h, 00h
		db	 80h,0E8h, 12h, 00h, 83h,0A0h
		db	 12h, 00h,0C3h, 12h, 00h, 08h
		db	 00h, 06h, 00h, 0Ah, 00h, 05h
		db	 00h, 0Eh, 12h, 01h, 0Ah, 00h
		db	 04h, 00h, 08h, 00h, 04h, 00h
		db	 08h, 00h, 04h, 00h, 02h, 00h
		db	 04h, 00h, 02h, 00h, 01h, 00h
		db	 20h, 00h, 90h, 00h,0A8h, 00h
		db	 54h, 00h, 2Ah, 00h, 15h, 00h
		db	 02h, 00h, 01h, 12h, 0Eh, 02h
		db	 20h,0A1h,0DAh, 02h, 08h,0E9h
		db	0FAh, 12h, 00h,0ABh,0EBh, 00h
		db	 83h,0A2h,0ACh, 00h, 02h, 80h
		db	0ADh, 12h, 01h, 3Bh, 00h, 08h
		db	 00h, 3Ah, 12h, 01h, 0Ah, 12h
		db	 01h, 02h, 12h
loc_13:
		push	es
		mov	al,ds:data_40e
		add	[bp+si],ch
		add	[di],dl
		adc	cl,[bp+di]
		or	ds:data_39e[bx+si],al
		and	ds:data_44e[bx+si],al
		adc	al,[bx+si]
		jmp	short loc_13
		db	0C2h, 00h, 3Ah, 8Ah, 80h, 00h
		db	 7Ah, 02h, 12h, 00h,0ECh, 00h
		db	 20h, 00h,0ACh, 12h, 01h,0A0h
		db	 12h, 01h, 80h, 12h, 08h, 0Ah
		db	 00h, 05h, 00h,0A8h, 00h, 54h
		db	 12h, 0Ch, 2Ah,0C0h, 12h, 00h
		db	 2Ah,0B0h, 12h, 00h,0C2h,0AFh
		db	 12h, 00h,0B0h,0AAh, 12h, 00h
		db	0ACh, 08h, 12h, 00h, 2Bh, 02h
		db	 12h, 00h, 0Ah,0C2h, 12h, 01h
		db	0C3h, 12h, 0Ch,0C0h, 12h, 01h
		db	 30h, 12h, 01h,0B0h, 12h, 01h
		db	0B0h, 12h, 01h,0B0h, 00h, 08h
		db	 00h, 06h, 00h, 2Ah, 00h, 15h
		db	 00h,0A8h, 00h, 54h, 00h, 80h
		db	 00h, 40h, 12h, 0Fh, 20h, 00h
		db	 90h, 00h,0A0h, 00h, 50h, 00h
		db	0B0h, 12h, 01h,0A0h, 00h, 10h
		db	 00h, 20h, 00h, 10h, 00h, 20h
		db	 00h, 10h, 00h, 80h, 00h, 10h
		db	 00h, 80h, 00h, 40h, 12h, 00h
		db	 08h, 83h,0E7h, 12h, 00h,0B8h
		db	 3Fh, 12h, 00h,0AAh,0EAh, 12h
		db	 00h, 2Eh,0A2h, 12h, 00h, 0Ah
		db	0A8h, 12h, 00h,0BAh, 83h, 12h
		db	 00h,0A8h,0BAh, 12h, 00h, 8Ah
		db	0BCh, 12h, 00h, 2Ah,0C0h, 12h
		db	 00h,0E8h, 12h, 01h,0A0h, 12h
		db	 01h, 80h, 2Fh, 12h, 00h, 0Bh
		db	0AAh, 12h, 00h, 27h, 00h, 12h
		db	 00h,0EAh, 19h, 00h, 00h,0AFh
		db	 12h, 12h, 03h, 12h, 01h, 03h
		db	 12h, 01h, 03h, 12h, 01h, 03h
		db	 12h, 00h, 0Eh, 8Fh, 12h, 00h
		db	 30h,0BAh, 12h, 00h,0EAh,0AAh
		db	 12h, 00h,0E2h,0B0h, 12h, 00h
		db	0A2h, 12h, 01h, 88h, 00h, 04h
		db	 00h,0A0h, 00h, 04h, 00h,0A0h
		db	 00h, 24h, 00h, 90h, 00h,0A6h
		db	 00h, 51h, 00h,0A6h, 00h, 51h
		db	 00h, 22h, 80h, 11h, 40h, 28h
		db	0A0h, 14h, 50h, 21h, 00h, 04h
		db	 14h, 08h, 00h, 04h, 00h, 02h
		db	 00h, 01h, 00h, 08h, 80h,0A7h
		db	 40h, 20h, 80h,0AFh, 40h, 12h
		db	 00h,0EBh,0C0h,0C2h, 00h, 3Ah
		db	0B0h, 80h, 00h, 7Ah,0A0h, 12h
		db	 00h,0ECh,0ACh, 20h, 00h,0ACh
		db	 2Bh, 12h, 00h,0A0h, 0Bh, 12h
		db	 00h, 80h, 08h, 12h, 01h, 02h
		db	 00h, 02h, 00h, 01h, 00h, 0Ah
		db	 00h, 05h, 00h, 0Ah, 00h, 05h
		db	 00h, 28h, 00h, 14h, 00h,0A0h
		db	 00h, 50h, 0Ah, 00h, 05h, 12h
		db	 01h, 02h,0ABh, 12h, 01h, 28h
		db	 12h, 01h, 01h, 12h, 01h, 01h
		db	 12h, 01h, 01h, 12h, 01h, 01h
		db	 00h, 02h, 00h, 01h, 00h, 02h
		db	 00h, 01h, 12h, 08h,0C0h, 12h
		db	 01h,0C0h, 12h, 01h, 80h, 12h
		db	 01h,0C0h, 12h, 01h,0C0h, 00h
		db	 80h, 00h, 40h, 12h, 00h, 02h
		db	0C0h, 01h, 00h, 02h, 80h, 01h
		db	 00h, 02h, 80h, 01h, 00h, 02h
		db	 40h, 01h, 00h, 03h, 12h, 01h
		db	 08h, 00h, 04h, 12h, 06h,0C0h
		db	 12h, 01h, 80h, 00h, 40h, 00h
		db	 80h, 00h, 40h, 12h, 18h, 02h
		db	 00h, 01h, 12h, 1Ah,0A8h, 00h
		db	 54h, 00h, 0Ah,0A0h, 01h, 50h
		db	 00h, 2Ah, 00h, 15h, 00h, 0Ah
		db	 00h, 01h, 12h, 1Dh, 0Bh, 12h
		db	 01h,0EAh, 12h, 00h, 03h,0AAh
		db	 12h, 00h, 02h,0A8h, 12h, 0Eh
		db	0A0h, 00h, 50h, 00h,0A8h, 00h
		db	 54h, 00h, 2Ah, 00h, 15h, 00h
		db	 08h, 00h, 04h,0C0h, 12h, 00h
		db	 01h, 70h, 12h, 01h, 5Ch, 12h
		db	 01h, 1Ch, 12h, 01h, 17h, 12h
		db	 00h,0C0h, 05h, 12h, 00h,0BCh
		db	 05h, 12h, 00h,0AAh,0C1h, 12h
		db	 00h,0AAh,0BCh, 00h, 03h, 12h
		db	 01h, 02h, 12h, 07h, 03h, 00h
		db	 02h,0C0h, 3Dh, 00h, 80h, 70h
		db	 6Eh, 12h, 00h, 53h,0AFh, 12h
		db	 00h, 4Fh,0FFh, 12h, 0Fh, 0Ah
		db	 00h, 05h, 00h, 2Ah, 00h, 15h
		db	 00h,0A8h, 00h, 54h, 00h, 20h
		db	 03h, 10h,0C0h, 12h, 01h, 80h
		db	 12h, 07h,0C0h, 00h, 80h, 00h
		db	 7Ch, 03h, 02h, 00h,0B9h, 0Dh
		db	 12h, 00h,0FAh,0C5h, 12h, 00h
		db	0FFh,0F1h, 12h, 00h, 0Dh, 40h
		db	 12h, 00h, 35h, 12h, 01h, 34h
		db	 12h, 01h,0D4h, 12h, 01h, 50h
		db	 03h, 12h, 00h, 50h, 3Eh, 12h
		db	 00h, 43h,0AAh, 12h, 00h, 3Eh
		db	0AAh, 12h, 03h, 2Ah, 00h, 15h
		db	 0Ah,0A0h, 05h, 40h,0A8h, 00h
		db	 54h, 00h,0A0h, 00h, 40h, 12h
		db	 0Fh, 80h, 00h, 40h, 12h, 29h
		db	0E0h, 12h, 01h,0ABh, 12h, 01h
		db	0AAh,0C0h, 12h, 00h, 2Ah, 80h
		db	 12h, 11h, 03h, 12h, 01h, 0Bh
		db	 12h, 01h, 0Bh, 12h, 01h, 2Bh
		db	 12h, 00h, 0Eh, 8Fh, 12h, 00h
		db	 30h,0BAh, 12h, 00h,0EAh,0AAh
		db	 12h, 00h,0E2h, 80h, 12h, 00h
		db	0A8h, 12h, 01h,0A0h, 12h, 01h
		db	0A0h, 12h, 01h,0A0h, 12h, 00h
		db	 20h, 00h, 10h, 00h,0A0h, 00h
		db	 50h, 00h, 80h, 00h, 40h, 02h
		db	 80h, 01h, 40h, 02h, 00h, 01h
		db	 00h, 02h, 00h, 01h, 00h, 02h
		db	 00h, 01h, 00h, 02h, 00h, 01h
		db	 00h, 20h, 00h, 90h, 00h,0A0h
		db	 00h, 50h, 00h,0A0h, 00h, 50h
		db	 00h
		db	20h
data_14		dw	1000h			; Data table (indexed access)
		db	 00h, 28h, 00h, 14h, 00h, 08h
		db	 00h, 04h, 00h, 08h, 00h, 04h
		db	 00h, 02h, 00h, 01h, 12h, 01h
		db	 02h,0AAh, 12h, 00h,0F0h, 2Bh
		db	 12h, 00h,0EBh, 0Ah, 12h, 00h
		db	3Ah
data_15		db	0B2h			; Data table (indexed access)
		db	 12h, 00h, 0Ah,0ABh, 12h, 00h
		db	 02h,0EAh, 12h, 01h, 23h, 00h
		db	 02h, 00h,0FAh, 20h, 00h,0DBh
		db	0C2h, 12h, 00h,0FCh, 2Eh, 12h
		db	 00h,0ABh,0AAh, 12h, 00h, 8Ah
		db	0B8h, 12h, 00h, 2Ah,0A3h, 12h
		db	 00h,0B0h,0AEh, 12h, 00h,0ABh
		db	 2Ah, 12h, 00h, 3Eh, 82h, 02h
		db	 20h, 09h,0DAh, 02h, 08h, 0Dh
		db	0FAh, 12h, 00h, 0Eh,0EBh, 00h
		db	 83h, 0Ah,0ACh, 00h, 1Dh, 00h
		db	0ADh, 12h, 01h, 3Bh, 00h, 08h
		db	 00h, 3Ah, 12h, 01h, 02h, 00h
		db	 20h, 83h,0E8h, 12h, 00h, 3Fh
		db	 59h, 00h, 00h, 15h,0FCh, 80h
		db	 20h, 7Fh,0DFh, 1Dh, 00h,0FEh
		db	0FDh, 12h, 00h,0AAh,0AFh, 12h
		db	 00h, 82h, 08h, 12h, 00h,0FAh
		db	0AAh, 02h, 80h, 2Ah, 80h, 03h
		db	0A0h, 83h,0AAh, 00h,0E8h, 00h
		db	0E8h, 12h, 00h,0C0h, 12h, 01h
		db	0FCh, 12h, 01h,0FAh, 12h, 01h
		db	 2Ah, 12h, 01h,0A8h, 00h, 03h
		db	 80h, 83h,0A8h, 0Eh, 80h,0AEh
		db	 80h, 2Ah, 00h, 2Ah, 12h, 02h
		db	 03h, 00h, 02h
loc_14:
		add	[di],bh
		add	[bx+si],cl
;*		add	bh,dh
		db	 00h,0F7h		;  Fixup - byte match
		adc	al,[bx+di]
		hlt				; Halt processor
		adc	al,[bx+di]
		push	ss
		add	[bx+si],cl
		and	di,12h
		add	data_22[bx+si],bh
		add	ss:data_32[bp+si],bh
		add	ss:data_24[bp],ch
		add	byte ptr ss:data_25[bp+si],cl
		add	ss:data_19[bp+si],bh
		add	data_32[bx+si],ch
		add	byte ptr ss:[12BCh][bp+si],al
		add	ss:data_23[bp+si],ch
;*		add	al,ch
		db	 00h,0E8h		;  Fixup - byte match
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		adc	al,[bx+si]
		mov	al,data_33
		add	byte ptr ss:[12ACh][bp],cl
;*		add	dl,ch
		db	 00h,0EAh		;  Fixup - byte match
		test	al,12h
		add	ss:data_23[bp+di],ch
;*		add	al,cl
		db	 00h,0C8h		;  Fixup - byte match
		add	ds:data_51e[bx+si],al
		or	byte ptr [bx+si],0
		sub	ax,dx
		adc	al,[bx+si]
		stosw				; Store ax to es:[di]
		cld				; Clear direction
		add	ss:data_41e[bp+di],ch
		or	[bp+si],al
		idiv	bp			; ax,dx rem=dx:ax/reg
		sbb	[bx+si],ax
;*		jg	loc_15			;*Jump if >
		db	 7Fh,0BFh		;  Fixup - byte match
		adc	al,[bx+si]
		cli				; Disable interrupts
		stosb				; Store al to es:[di]
		adc	al,[bx+si]
		and	byte ptr ss:[12h][bp+si],al
		stosb				; Store al to es:[di]
		scasw				; Scan es:[di] for ax
		or	ds:data_43e[bx+si],al
		and	ds:data_46e[bx+si],al
		adc	al,[bx+si]
;*		jmp	short loc_16		;*
		db	0EBh,0B0h		;  Fixup - byte match
		db	0C2h, 00h, 3Ah,0A0h, 80h, 00h
		db	 7Ah, 80h, 12h, 00h,0ECh, 00h
		db	 20h, 00h,0ACh, 12h, 01h, 80h
		db	 12h, 01h,0F2h,0B0h, 12h, 00h
		db	0AEh, 0Ch, 12h, 00h,0AAh,0ABh
		db	 12h, 00h, 02h, 8Bh, 12h, 01h
		db	 2Ah, 12h, 01h, 0Ah, 12h, 01h
		db	 0Ah, 12h, 01h, 0Ah, 12h, 10h
		db	0C0h, 12h, 01h,0E0h, 12h, 01h
		db	0E0h, 12h, 01h,0E8h, 12h, 00h
		db	 08h, 00h, 06h, 00h, 0Ah, 00h
		db	 05h, 00h, 0Ah, 00h, 05h, 00h
		db	 08h, 00h, 04h, 00h, 28h, 00h
		db	 14h, 00h, 20h, 00h, 10h, 00h
		db	 20h, 00h, 10h, 00h, 80h, 00h
		db	 40h, 08h, 00h, 04h, 00h, 0Ah
		db	 00h, 05h, 00h, 02h, 00h, 01h
		db	 00h, 02h, 80h, 01h, 40h, 00h
		db	 80h, 00h, 40h, 00h, 80h, 00h
		db	 40h, 00h, 80h, 00h, 40h, 00h
		db	 80h, 00h, 40h, 12h, 17h, 01h
		db	 12h, 01h, 05h, 00h, 02h, 12h
		db	 01h, 0Ch, 12h, 01h, 6Bh, 12h
		db	 00h, 01h,0D4h, 12h, 00h, 06h
		db	0A0h, 28h, 00h, 14h, 0Fh,0A8h
		db	 00h, 50h, 33h, 40h, 00h, 80h
		db	 54h, 12h, 01h,0D4h, 00h, 0Ch
		db	 00h, 02h, 00h, 10h, 00h, 08h
		db	 00h, 10h, 00h, 08h, 00h, 20h
		db	 00h, 10h, 00h, 20h, 00h, 10h
		db	 00h, 20h, 00h, 10h, 12h, 08h
		db	 03h
data_16		db	40h			; Data table (indexed access)
		db	 12h, 00h, 05h, 40h, 12h, 00h
		db	 0Dh, 12h, 01h, 0Dh, 12h, 01h
		db	 05h, 12h, 01h, 02h, 12h, 01h
		db	 2Ah, 01h, 12h, 00h, 32h, 03h
		db	 12h, 18h,0F8h, 12h, 01h,0AFh
		db	0E0h, 12h, 00h,0A8h,0BFh, 12h
		db	 00h, 03h,0A8h, 12h, 01h, 2Bh
		db	 12h, 00h,0F8h, 02h, 12h, 00h
		db	0AAh,0E0h, 12h, 00h, 27h, 00h
		db	 12h, 00h, 02h,0ABh, 00h, 02h
		db	 00h,0FAh, 20h, 00h,0DBh,0C2h
		db	 12h, 00h,0FCh, 2Eh, 12h, 00h
		db	0ABh,0AAh, 12h, 00h, 8Ah,0B8h
		db	 12h, 00h, 2Ah,0A0h, 12h, 00h
		db	0C2h,0AEh, 12h, 00h,0AEh, 2Ah
		db	 12h, 00h, 3Eh,0A2h, 12h, 19h
		db	 1Fh, 12h, 00h, 07h,0F5h, 00h
		db	 08h, 83h,0E7h, 12h, 00h,0B8h
		db	 3Fh, 12h, 00h,0AAh,0EAh, 12h
		db	 00h, 2Eh,0A2h, 12h, 00h, 0Ah
		db	0A8h, 12h, 00h,0BAh, 83h, 12h
		db	 00h,0A8h,0BAh, 12h, 00h, 8Ah
		db	0BCh, 12h, 00h,0FDh, 15h, 12h
		db	 00h, 15h,0C0h, 12h, 00h,0D4h
		db	 12h, 01h, 40h, 1Fh, 12h, 00h
		db	 07h, 55h, 12h, 00h,0D0h, 00h
		db	 12h, 00h,0D5h, 31h, 00h, 00h
		db	 5Fh, 12h, 01h, 30h, 12h, 01h
		db	0D6h, 12h, 01h, 2Bh, 80h, 12h
		db	 00h, 05h, 60h, 00h, 14h,0F0h
		db	 28h, 00h, 15h,0CCh, 0Ah, 00h
		db	 02h, 2Ah, 01h, 12h, 00h, 2Bh
		db	 12h, 17h, 80h, 12h, 01h,0A0h
		db	 00h, 40h, 12h, 01h, 02h,0C0h
		db	 12h, 00h, 02h,0A0h, 12h, 01h
		db	0B0h, 12h, 01h,0B0h, 12h, 01h
		db	0A0h, 12h, 01h, 40h, 12h, 00h
		db	 80h, 54h, 12h, 00h,0C0h, 4Ch
		db	 30h, 00h, 40h, 00h, 08h, 00h
		db	 10h, 00h, 08h, 00h, 10h, 00h
		db	 04h, 00h, 08h, 00h, 04h, 00h
		db	 08h, 00h, 04h, 00h, 08h, 12h
		db	 09h, 32h, 06h, 12h, 00h, 1Ah
		db	 06h, 0Ah, 00h, 04h, 0Eh, 0Ah
		db	 00h, 05h, 0Dh, 02h, 0Ah, 05h
		db	 04h, 02h, 0Ah, 05h, 04h, 02h
		db	 8Ah, 01h, 04h, 00h, 8Ah, 01h
		db	 04h, 00h, 8Ah, 00h, 04h, 00h
		db	 44h, 00h, 02h, 00h, 05h, 00h
		db	 02h, 00h, 02h, 00h, 01h, 00h
		db	 01h, 12h, 0Ch, 02h, 20h, 01h
		db	0DAh, 02h, 08h, 01h,0FAh, 12h
		db	 00h, 02h,0EBh, 00h, 83h, 18h
		db	0ACh, 00h, 02h, 68h,0ADh, 12h
		db	 00h, 68h, 3Bh, 00h, 08h, 40h
		db	 3Ah, 12h, 00h, 40h, 1Ah, 08h
		db	 80h,0B7h, 00h, 20h, 80h,0BFh
		db	 12h, 01h,0AEh, 80h, 82h, 00h
		db	 6Ah, 30h, 80h, 00h, 6Ah, 2Ch
		db	 12h, 00h,0BCh, 2Ch, 20h, 00h
		db	0B8h, 04h, 12h, 00h,0B8h, 04h
		db	 12h, 00h, 80h, 02h, 12h, 00h
		db	 80h, 12h, 19h, 50h, 01h, 12h
		db	 01h, 01h, 12h, 18h, 60h, 4Ch
		db	 12h, 00h, 60h, 58h, 00h, 50h
		db	 70h, 20h, 00h, 50h,0B0h,0A0h
		db	 50h, 40h, 20h,0A0h, 50h, 40h
		db	 20h,0A0h, 51h, 40h, 20h, 80h
		db	 51h, 00h, 20h, 80h, 51h, 00h
		db	 20h, 00h, 22h, 00h, 40h, 00h
		db	0A0h, 00h, 40h, 00h, 40h, 00h
		db	 80h, 00h, 80h, 12h, 0Fh, 27h
		db	 00h, 12h, 00h,0A8h, 33h, 02h
		db	 08h, 80h, 12h, 00h,0C0h, 12h
		db	 00h, 0Ch, 8Ch,0A0h, 12h, 00h
		db	 03h,0ABh,0A0h, 12h, 00h,0BAh
		db	0AAh, 12h, 00h,0A8h, 2Ah, 12h
		db	 00h, 2Ah,0AAh, 12h, 00h,0A3h
		db	 83h, 21h, 00h,0C0h, 00h, 71h
		db	 00h, 12h, 00h, 08h, 80h, 00h
		db	 0Eh, 30h, 00h, 03h,0EAh,0C0h
		db	 00h, 3Ah,0AEh, 12h, 00h, 28h
		db	 2Ah, 12h, 00h, 27h, 00h, 12h
		db	 00h,0A8h, 33h, 02h, 38h, 80h
		db	 00h, 03h,0C0h, 12h, 00h, 0Ch
		db	0BCh,0A0h, 00h
data_17		db	3			; Data table (indexed access)
data_18		db	0C3h			; Data table (indexed access)
		db	0A8h, 20h, 12h, 00h,0BAh,0AAh
		db	 12h, 00h,0A8h
		db	2Ah
data_19		db	12h			; Data table (indexed access)
		db	 00h, 2Ah,0AAh, 12h, 00h,0A3h
		db	 83h, 08h, 38h,0C0h, 00h, 3Fh
		db	 30h, 12h, 00h,0C8h, 80h, 00h
		db	 0Eh,0F3h, 12h, 00h,0EAh,0C0h
		db	 00h, 3Ah,0AEh
data_20		db	12h			; Data table (indexed access)
		db	 00h, 28h, 2Ah, 12h, 00h, 27h
		db	 00h, 12h, 00h,0A8h, 33h, 0Eh
		db	0F8h, 80h, 00h
data_21		db	3Fh			; Data table (indexed access)
		db	0CFh, 12h, 00h, 0Fh
data_22		db	0BFh			; Data table (indexed access)
		db	0A0h, 00h, 03h,0CFh,0A8h, 20h
		db	 00h, 30h,0BAh, 8Ah, 00h, 30h
		db	0A8h, 0Ah, 12h, 00h, 2Ah,0AAh
		db	 12h, 00h,0A3h, 83h, 08h, 38h
		db	0C0h, 00h, 3Fh, 30h, 12h, 00h
		db	0CCh,0C0h, 00h, 0Eh,0F3h, 30h
		db	 00h,0CAh,0CCh, 00h, 32h,0AEh
		db	 0Ch, 00h, 20h, 2Ah, 12h, 00h
		db	 27h, 00h, 12h, 00h,0A8h, 33h
		db	 0Eh,0F8h, 80h, 00h, 3Eh,0EFh
		db	 12h, 00h, 0Bh,0ABh
data_23		db	0A0h			; Data table (indexed access)
		db	 00h, 0Fh,0AFh,0A0h, 00h, 0Ch
		db	0BCh,0B2h, 02h, 00h, 23h,0A8h
		db	 08h, 12h, 00h, 2Ah,0AAh, 12h
		db	 00h,0A3h, 83h, 38h,0F8h,0C0h
		db	 00h,0EBh, 33h, 12h, 00h,0AFh
		db	0C0h, 00h, 0Eh
data_24		db	0B3h			; Data table (indexed access)
		db	 30h, 00h,0CAh,0CFh, 00h
data_25		dw	0AE30h			; Data table (indexed access)

_364UNKN	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		or	al,0
		and	[bp+si],ch
		adc	al,[bx+si]
		daa				; Decimal adjust
		add	[bp+si],dl
		add	data_15[bx+si],ch
		clc				; Clear carry flag
		add	byte ptr [bx+si],3Eh	; '>'
		out	dx,ax			; port 4131h ??I/O Non-standard
		adc	al,[bx+si]
loc_17:
		or	di,ss:data_3[bp+di]
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		mov	di,offset data_3
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		mov	sp,2B0h
		add	bp,ss:data_25[bp]
		add	[bp+si],bp
		stosb				; Store al to es:[di]
		adc	al,[bx+si]
		mov	ds:data_37e,ax
		mov	ax,0C0h
		jmp	short loc_17
sub_2		endp

		db	 12h, 00h,0AFh,0ACh, 00h
data_30		db	2			; Data table (indexed access)
		db	0BEh,0B0h, 00h, 0Ah,0CEh,0C0h
data_31		db	30h			; Data table (indexed access)
		db	 2Eh, 0Ah
data_32		db	0C0h			; Data table (indexed access)
data_33		db	20h			; Data table (indexed access)
		db	 2Ah, 03h,0BCh, 28h, 00h, 03h
		db	0ECh, 83h, 02h, 00h,0ACh, 12h
		db	 01h,0E0h,0C0h, 12h, 00h, 30h
		db	0F0h, 12h, 01h,0FCh, 12h, 01h
		db	0AFh, 12h, 01h, 2Bh, 00h, 0Eh
		db	 19h, 00h,0A8h, 0Eh, 80h,0ACh
		db	 80h, 2Bh, 00h, 28h, 00h, 03h
		db	 12h, 00h, 03h, 00h, 02h, 00h
		db	 0Dh, 00h, 08h, 00h, 37h, 12h
		db	 01h, 3Ah, 12h, 01h,0E8h, 12h
		db	 00h, 27h, 00h, 12h, 00h,0A8h
		db	 33h, 02h, 08h, 80h, 12h, 00h
		db	 3Ch, 12h, 00h, 0Fh,0BBh,0A0h
		db	 12h, 00h, 34h,0ABh, 80h, 00h
		db	 13h,0BAh, 88h, 00h, 11h,0A8h
		db	 08h, 12h, 00h, 2Ah,0AAh, 12h
		db	 00h,0A3h, 83h, 21h, 00h,0C0h
		db	 00h, 01h,0C0h, 12h, 00h, 3Bh
		db	0B0h, 00h, 0Eh, 70h,0C0h, 03h
		db	 2Ah, 4Ch, 00h, 32h,0AEh, 12h
		db	 00h, 28h, 2Ah, 02h, 8Ch, 2Ah
		db	 80h, 03h,0B0h, 83h, 8Ah, 00h
		db	0FBh, 00h,0C8h, 00h, 3Ch,0C0h
		db	 12h, 00h, 74h,0F0h, 12h, 00h
		db	0DDh,0FCh, 12h, 00h, 74h,0AFh
		db	 12h, 00h, 14h, 2Bh, 00h, 0Ch
		db	 19h, 00h,0A8h, 0Ch, 80h,0A0h
		db	 80h, 26h, 00h, 20h, 00h, 3Dh
		db	 12h, 00h, 03h, 16h, 02h, 00h
		db	 0Dh, 04h, 08h, 00h, 37h, 12h
		db	 01h, 3Ah, 12h, 01h,0E8h, 12h
		db	 00h, 27h, 00h, 12h, 00h,0A8h
		db	 33h, 02h, 08h, 80h, 12h, 00h
		db	0C0h, 12h, 00h, 0Ch, 8Ch,0A0h
		db	 12h, 00h, 03h,0ABh,0A0h, 12h
		db	 00h,0BAh,0AAh, 00h, 0Ch,0A8h
		db	 22h, 12h, 00h, 2Ah,0AAh, 12h
		db	 00h,0A3h, 83h, 21h, 00h,0C0h
		db	 00h, 71h, 00h, 12h, 00h, 08h
		db	 80h, 00h, 0Eh, 30h, 00h, 03h
		db	0EAh,0CCh, 00h, 32h,0AEh, 0Ch
		db	 00h, 20h, 2Ah, 02h, 80h, 2Ah
		db	 80h, 03h,0A0h, 83h,0AAh, 00h
		db	0ECh, 00h,0E0h, 00h, 0Ch,0C0h
		db	 12h, 01h,0F0h, 12h, 00h, 0Ch
		db	0FCh, 12h, 01h,0AFh, 12h, 01h
		db	 2Bh, 00h, 03h, 80h, 83h,0A8h
		db	 0Eh, 80h,0A2h, 80h, 2Ah, 00h
		db	 2Ah, 12h, 02h, 03h, 0Ch, 02h
		db	 00h, 0Dh, 00h, 08h, 00h, 37h
		db	 12h, 01h, 3Ah, 12h, 01h,0E8h
		db	 12h, 07h, 08h, 12h, 05h, 08h
		db	 12h, 05h, 08h, 12h, 01h, 0Ch
		db	 12h, 00h, 08h, 12h, 05h, 08h
		db	 12h, 01h, 0Eh, 12h, 01h, 17h
		db	 12h, 01h, 36h, 12h, 01h, 1Eh
		db	 12h, 01h, 0Ch, 12h, 02h, 0Eh
		db	 12h, 01h, 1Ch, 12h, 01h, 3Ah
		db	 12h, 01h, 1Bh, 12h, 01h, 1Eh
		db	 12h, 01h, 0Ch, 12h, 09h, 0Ch
		db	 12h, 11h, 08h, 12h, 05h, 08h
		db	 12h, 0Ch, 08h, 12h, 05h, 08h
		db	 12h, 01h, 0Eh, 12h, 01h, 17h
		db	 12h, 06h, 08h, 12h, 01h, 0Ch
		db	 12h, 01h, 0Eh, 12h, 01h, 1Ch
		db	 12h, 01h, 3Ah, 12h, 01h, 1Bh
		db	 12h, 00h, 02h,0DEh, 12h, 00h
		db	 36h, 12h, 01h, 1Eh, 12h, 01h
		db	 0Ch, 12h, 11h, 88h, 12h, 0Eh
		db	0C0h, 12h, 00h, 65h, 00h, 12h
		db	 01h, 0Bh, 12h, 00h, 03h, 3Ch
		db	 12h, 00h, 0Ch,0CBh, 12h, 04h
		db	 08h, 12h, 05h, 08h, 12h, 01h
		db	 0Eh, 12h, 01h, 17h, 30h, 12h
		db	 00h,0F6h, 12h, 01h,0DEh,0F0h
		db	 12h, 14h, 0Ch, 12h, 02h,0F3h
		db	 12h, 00h, 33h, 3Fh, 12h, 15h
		db	0C0h, 12h, 00h,0CCh, 12h, 01h
		db	 3Fh,0CCh, 12h, 1Ch, 0Ch,0CFh
		db	 12h, 1Ch, 0Ch,0C0h, 12h, 00h

seg_a		ends



		end	start
