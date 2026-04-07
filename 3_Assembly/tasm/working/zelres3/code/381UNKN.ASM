
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_381UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_381UNKN	proc	far

start:
		push	ax
		pop	es
		add	[bx+si],al
		add	[bx],al
		in	ax,dx			; port 0, DMA-1 bas&add ch 0
		add	[bx+di],al
		add	cl,[bx+si]
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		adc	[bx+di],dl
		adc	dl,[bp+di]
		pop	ss
		sbb	[bx+di],bl
		sbb	bl,[bp+di]
		sbb	al,25h			; '%'
		db	 26h, 27h, 28h, 29h,0EDh, 00h
		db	 01h, 0Fh,0EDh, 00h, 00h, 10h
		db	0EDh, 00h, 00h, 25h, 26h, 27h
		db	 28h, 13h, 14h, 15h, 16h, 12h
		db	 1Ah, 1Bh, 1Ch, 11h, 17h, 18h
		db	 19h, 00h, 80h, 03h, 00h, 03h
		db	 00h, 00h,0C0h, 05h, 00h, 05h
		db	 00h, 08h,0C0h, 11h, 00h, 01h
		db	 80h, 0Ch, 40h, 32h, 80h, 00h
		db	0C0h, 00h, 00h, 2Eh, 80h, 00h
		db	 80h, 00h, 00h, 15h, 00h, 01h
		db	 00h, 01h, 00h, 02h, 80h, 03h
		db	 80h, 02h, 00h, 01h, 80h, 03h
		db	 80h, 01h, 00h, 00h,0C0h, 00h
		db	0C0h, 03h, 00h, 00h,0A0h, 00h
		db	0A0h, 03h, 10h, 00h, 88h, 01h
		db	 80h, 02h, 30h, 01h, 4Ch, 03h
		db	0EDh, 00h, 00h, 01h, 74h, 01h
		db	0EDh, 00h, 01h,0A8h, 00h, 80h
		db	 00h, 80h, 01h, 40h, 01h,0C0h
		db	 00h, 40h, 01h, 80h, 01h,0C0h
		db	 01h, 80h, 00h, 4Eh, 00h, 4Eh
		db	 18h, 00h, 05h,0C7h, 05h, 07h
		db	 30h, 20h, 0Ch, 1Bh, 08h, 1Ah
		db	 40h, 60h, 3Bh, 98h, 33h, 90h
		db	 40h, 00h, 37h,0F3h, 26h, 83h
		db	 00h, 84h, 76h, 03h, 64h, 86h
		db	 02h, 00h, 30h, 00h, 22h, 00h
		db	 04h, 20h, 00h, 00h, 04h, 20h
		db	 01h, 80h,0B8h, 4Eh,0B8h, 4Eh
		db	 30h, 00h, 4Dh,0C7h, 4Dh, 07h
		db	 20h, 20h, 5Ch, 1Bh, 50h, 1Ah
		db	 00h, 60h, 38h, 98h, 20h, 90h
		db	0B0h, 00h, 06h, 30h,0F6h, 20h
		db	 60h, 84h, 06h, 00h, 66h, 84h
		db	 2Ah,0EDh, 00h, 00h
data_1		db	2Ah
		db	 00h, 14h, 20h, 00h, 00h, 14h
		db	 20h, 01h, 80h,0BEh, 7Eh,0BEh
		db	 7Eh, 30h, 30h, 4Fh,0C7h
		db	4Fh
data_2		dw	2707h			; Data table (indexed access)
		db	 20h, 58h,0DBh, 50h,0DAh, 0Ch
		db	 60h, 33h, 9Bh, 23h, 12h,0B4h
		db	 00h, 03h,0F2h,0F3h, 60h, 60h
		db	 04h, 07h,0E0h, 66h,0C4h, 28h
		db	 00h, 03h,0C0h, 2Ah, 80h, 14h
		db	 20h, 01h, 40h, 15h, 20h, 01h
		db	 80h, 12h, 00h, 12h, 00h, 00h
		db	 18h, 63h,0A0h, 60h,0A0h, 04h
		db	 08h, 58h, 34h, 58h, 14h, 00h
		db	 00h, 1Fh,0DEh, 0Fh, 9Eh, 00h
		db	 00h,0CFh,0EEh,0C5h,0CCh, 21h
		db	 00h,0C0h, 6Eh, 61h, 0Ch, 00h
		db	 40h, 00h, 0Ch, 00h, 40h, 04h
		db	 20h, 00h, 00h, 04h, 20h, 0Dh
		db	 30h, 00h, 00h, 0Dh,0B0h, 35h
		db	 02h, 00h, 00h, 2Fh, 52h, 78h
		db	 90h, 00h, 00h, 45h,0B0h,0F9h
		db	0EDh, 00h, 00h,0CDh, 80h,0A4h
		db	0EDh, 00h, 00h,0F4h, 00h, 40h
		db	 84h, 00h, 00h, 60h, 84h, 2Ah
		db	0EDh, 00h, 00h, 2Ah, 00h, 14h
		db	 20h, 00h, 00h, 14h, 20h, 0Dh
		db	 30h, 00h, 00h, 0Dh, 30h, 3Dh
		db	 42h, 00h, 00h, 3Dh, 42h, 7Dh
		db	 90h, 00h, 00h, 7Dh, 90h,0E9h
		db	0EDh, 00h, 00h,0E9h, 00h,0B4h
		db	0EDh, 00h, 00h,0B4h, 00h, 60h
		db	 84h, 00h, 00h, 60h, 84h, 2Ah
		db	0EDh, 00h, 00h, 2Ah, 00h, 14h
		db	 20h, 00h, 00h, 14h, 20h,0EDh
		db	 00h, 01h, 1Ch,0EDh, 00h, 02h
		db	 60h, 08h,0EDh, 00h, 01h, 80h
		db	 02h,0EDh, 00h, 01h, 80h,0EDh
		db	 00h, 01h,0A8h, 00h, 01h, 00h
		db	 00h, 01h, 7Ah, 00h, 31h, 00h
		db	 00h, 01h, 54h, 80h, 03h,0EDh
		db	 00h, 01h, 20h, 1Ch, 0Dh, 00h
		db	 00h, 20h, 0Dh, 00h, 3Ch, 02h
		db	 02h,0D0h, 3Eh, 82h, 7Ch, 10h
		db	 03h, 00h, 7Eh, 10h,0E8h, 00h
		db	 02h, 00h,0E8h, 00h,0A0h, 00h
		db	 1Ch,0C0h,0A8h, 40h, 00h, 84h
		db	 60h, 30h, 60h, 84h, 0Ah, 00h
		db	 80h, 06h, 8Ah, 00h, 14h, 20h
		db	 00h, 01h, 14h, 20h,0C0h, 00h
		db	0C0h,0EDh, 00h, 00h,0D0h, 00h
		db	0D0h,0EDh, 00h, 00h, 74h, 00h
		db	 74h,0EDh, 00h, 00h, 7Eh, 80h
		db	 4Eh, 80h, 00h, 00h, 2Fh,0F0h
		db	 29h,0F0h, 00h, 00h, 02h,0FCh
		db	 02h, 1Ch,0EDh, 00h, 00h, 2Eh
		db	 00h, 26h,0EDh, 00h, 00h, 0Bh
		db	 00h, 01h, 00h, 00h,0C0h, 0Ah
		db	0C0h, 0Ah, 00h, 00h,0D0h, 1Ch
		db	0D0h, 1Ch, 00h, 00h, 74h, 3Ah
		db	 74h, 1Ah, 00h, 00h, 7Ch, 3Ch
		db	 4Ch, 0Ch, 00h, 00h, 2Fh, 9Eh
		db	 29h, 86h, 00h, 00h, 02h,0FEh
		db	 02h, 16h,0EDh, 00h, 00h, 2Eh
		db	 00h, 26h,0EDh, 00h, 00h, 0Bh
		db	 00h, 01h, 00h, 00h,0F0h, 0Fh
		db	 90h, 01h, 00h, 00h, 0Ch, 30h
		db	 04h,0EDh, 00h, 01h, 60h,0FFh
		db	0BFh,0EDh, 00h, 00h, 60h, 80h
		db	0BFh, 00h, 00h
		db	 0Ch, 30h
loc_1:
		aaa				; Ascii adjust
		cmp	al,0
;*		add	al,dh
		db	 00h,0F0h		;  Fixup - byte match
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		cli				; Disable interrupts
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+di],al
		aas				; Ascii adjust
		cmp	al,0EDh
		add	[bx+di],al
		cmp	bh,0
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
		add	[bx+si-13h],al
		add	[bx+si],al
		sbb	[bx+si],al
;*		or	ch,ch			; Zero ?
		db	 08h,0EDh		;  Fixup - byte match
		add	[bx+si],al
		or	al,0
;*		jmp	dword ptr [bp+si+0]
		db	0FFh, 6Ah, 00h		;  Fixup - byte match
		db	 00h, 0Ch, 00h, 05h,0FDh, 00h
		db	 00h, 18h, 00h, 6Ch, 7Dh, 00h
		db	 00h,0E0h, 00h, 9Eh, 7Ah,0EDh
		db	 00h, 01h, 7Ch, 7Dh,0EDh, 00h
		db	 01h, 01h, 74h,0EDh, 00h, 00h
		db	 03h, 00h, 03h, 00h, 03h,0EDh
		db	 00h, 00h, 0Eh, 00h, 08h,0EDh
		db	 00h, 00h, 3Ch, 00h, 30h, 00h
		db	 08h, 00h,0FCh, 00h,0D8h, 00h
		db	 90h, 03h,0F8h, 03h,0B0h, 02h
		db	 20h, 0Fh, 30h, 0Eh, 20h, 20h
		db	 00h, 39h,0C0h, 31h, 80h,0C2h
		db	 00h,0E3h, 00h,0C2h, 00h,0C0h
		db	 00h,0C0h, 00h,0C0h,0EDh, 00h
		db	 00h, 70h, 00h, 10h,0EDh, 00h
		db	 00h, 3Ch, 00h, 0Ch, 00h, 10h
		db	 00h, 3Fh, 00h, 1Bh, 00h, 09h
		db	 00h, 1Fh,0C0h, 0Dh,0C0h, 04h
		db	 40h, 0Ch,0F0h, 04h, 70h, 00h
		db	 04h, 03h, 9Ch, 01h, 8Ch, 00h
		db	 43h, 00h,0C7h, 00h, 43h,0EDh
		db	 00h, 8Dh, 01h, 80h,0B8h, 4Eh
		db	0B8h, 4Eh, 30h, 00h, 4Dh,0C7h
		db	 4Dh, 07h, 20h, 20h, 5Ch, 1Bh
		db	 50h, 1Ah, 00h, 60h, 38h, 98h
		db	 20h, 90h,0B0h, 00h, 06h, 30h
		db	0F6h, 20h, 60h, 84h, 06h, 00h
		db	 66h, 84h, 2Ah,0EDh, 00h, 00h
		db	 2Ah, 00h, 14h, 20h, 00h, 00h
		db	 14h, 20h, 0Dh, 30h, 00h, 00h
		db	 0Dh,0B0h, 35h, 02h, 00h, 00h
		db	 2Fh, 52h, 78h, 90h, 00h, 00h
		db	 45h,0B0h,0F9h,0EDh, 00h, 00h
		db	0CDh, 80h,0A4h,0EDh, 00h, 00h
		db	0D4h, 00h, 40h, 84h, 00h, 00h
		db	 60h, 84h, 2Ah,0EDh, 00h, 00h
		db	 2Ah, 00h, 14h, 20h, 00h, 00h
		db	 14h, 20h,0EDh, 00h, 01h, 1Ch
		db	0EDh, 00h, 02h, 60h, 08h,0EDh
		db	 00h, 01h, 80h, 02h,0EDh, 00h
		db	 01h, 80h,0EDh, 00h, 01h,0A8h
loc_2:
		add	[bx+di],al
		add	[bx+si],al
;*		add	[bp+si+0],di
		db	 01h, 7Ah, 00h		;  Fixup - byte match
		db	 31h, 00h, 00h, 01h, 54h, 80h
		db	 03h,0EDh, 00h, 01h, 20h, 1Ch
		db	 0Dh, 30h, 00h, 00h, 0Dh,0B0h
		db	 35h, 02h, 00h, 00h, 2Fh, 52h
		db	 78h, 90h, 00h, 00h, 45h,0B0h
		db	0F9h,0EDh, 00h, 00h,0CDh, 80h
		db	0A4h,0EDh, 00h, 00h,0D4h, 00h
		db	 40h, 84h, 00h, 00h, 60h, 84h
		db	 2Ah,0EDh, 00h
loc_3:
		add	[bp+si],ch
		add	[si],dl
		and	[bx+si],al
		add	[si],dl
;*		and	ch,ch
		db	 20h,0EDh		;  Fixup - byte match
		add	[bx+di],al
		sbb	al,0EDh
		add	[bp+si],al
		db	 60h, 08h,0EDh, 00h, 01h, 80h
		db	 02h,0EDh, 00h, 01h, 80h,0EDh
		db	 00h, 01h,0A8h, 00h, 01h, 00h
		db	 00h, 01h, 7Ah, 00h, 31h, 00h
		db	 00h, 01h, 54h, 80h, 03h,0EDh
		db	 00h
loc_4:
		add	[bx+si],sp
		sbb	al,0C0h
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+si],al
		rol	byte ptr [bx+si],1	; Rotate
		shr	ch,1			; Shift w/zeros fill
		add	[bx+si],al
		jz	$+2			; delay for I/O
		jz	loc_4			; Jump if zero
		add	[bx+si],al
		jle	loc_2			; Jump if < or =
		dec	si
		add	byte ptr [bx+si],0
		das				; Decimal adjust
;*                         lock	sub	ax,si
		db	0F0h, 29h,0F0h		;  Fixup - byte match
		add	[bx+si],al
		add	bh,ah
		add	bl,[si]
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+si],al
		add	cs:data_1,ah
		add	[bp+di],cl
		add	[bx+di],al
		add	[bx+si],al
		or	ax,30h
		add	[di],cl
		mov	al,35h			; '5'
		add	al,[bx+si]
		add	[bx],ch
		push	dx
		js	loc_3			; Jump if sign=1
		add	[bx+si],al
		inc	bp
		mov	al,0F9h
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+si],al
		int	80h			; ??INT Non-standard interrupt
		movsb				; Mov [si] to es:[di]
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+si],al
;*		aam	0			; undocumented inst
		db	0D4h, 00h		;  Fixup - byte match
		inc	ax
		test	al,[bx+si]
		add	[bx+si-7Ch],ah
		sub	ch,ch
		add	[bx+si],al
		sub	al,[bx+si]
		adc	al,20h			; ' '
		add	[bx+si],al
		adc	al,20h			; ' '
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+di],al
		sbb	al,0EDh
		add	[bp+si],al
		db	 60h, 08h,0EDh, 00h, 01h, 80h
		db	 02h,0EDh, 00h, 01h, 80h,0EDh
		db	 00h, 01h,0A8h, 00h, 01h, 00h
		db	 00h, 01h, 7Ah, 00h, 31h, 00h
		db	 00h, 01h, 54h, 80h, 03h,0EDh
		db	 00h
loc_6:
		add	[bx+si],sp
		sbb	al,0C0h
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+si],al
		rol	byte ptr [bx+si],1	; Rotate
		shr	ch,1			; Shift w/zeros fill
		add	[bx+si],al
		jz	$+2			; delay for I/O
		jz	loc_6			; Jump if zero
		add	[bx+si],al
;*		jle	loc_5			;*Jump if < or =
		db	 7Eh, 80h		;  Fixup - byte match
		dec	si
		add	byte ptr [bx+si],0
		das				; Decimal adjust
;*                         lock	sub	ax,si
		db	0F0h, 29h,0F0h		;  Fixup - byte match
		add	[bx+si],al
		add	bh,ah
		add	bl,[si]
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+si],al
		add	cs:data_1,ah
		add	[bp+di],cl
		add	[bx+di],al
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+si],al
		aas				; Ascii adjust
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bp+si],al
		sbb	[bx+si],al
;*		or	ch,ch			; Zero ?
		db	 08h,0EDh		;  Fixup - byte match
		add	[bx+si],al
		sbb	[bx+si],al
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+si],al
		pop	ds
		add	[bp+si],ch
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+si],al
		sbb	[bx+si],al
		dec	si
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bx+si],al
		cmp	al,0
		push	ds
		in	ax,dx			; port 50h ??I/O Non-standard
		add	[bp+si],al
		db	 2Eh,0EDh, 00h, 02h, 14h, 00h
		db	 00h,0CEh, 1Dh,0EDh, 00h, 01h
		db	 66h, 18h, 62h, 08h, 00h, 00h
		db	 66h, 18h,0BBh,0FFh, 00h, 00h
		db	0C6h, 18h, 42h, 2Ch, 00h, 00h
		db	 06h, 18h, 7Bh, 2Ch, 00h, 00h
		db	 03h,0F1h, 01h, 5Ch,0EDh, 00h
		db	 01h, 7Fh, 3Ch,0EDh, 00h, 01h
		db	 3Fh, 81h, 00h, 00h,0FEh, 7Fh
		db	 08h, 08h, 00h, 00h,0C3h, 30h
		db	 43h, 10h, 00h, 00h,0C3h, 3Eh
		db	 7Dh,0D9h, 00h, 00h,0FEh, 30h
		db	 62h, 10h, 00h, 00h,0CCh, 30h
		db	 6Fh,0D9h, 00h, 00h,0E7h, 7Fh
		db	 64h, 1Ah,0EDh, 00h, 01h,0E6h
		db	 79h,0EDh, 00h, 01h,0C3h, 10h
		db	 00h, 00h,0DFh,0F0h, 82h, 50h
		db	 00h, 00h, 88h, 60h, 88h, 60h
		db	 00h, 00h, 01h,0C1h,0FEh, 7Eh
		db	 00h, 00h, 03h, 83h, 04h, 80h
		db	 00h, 00h, 8Eh, 23h, 63h,0C5h
		db	 00h, 00h,0DFh,0F7h,0FDh, 1Bh
		db	0EDh, 00h, 01h,0EEh, 3Bh,0EDh
		db	 00h, 01h, 04h, 01h, 00h, 00h
		db	 60h,0EDh, 00h, 02h,0F0h, 00h
		db	 70h,0EDh, 00h, 00h, 98h, 00h
		db	0EFh,0EAh, 00h, 00h,0FCh, 00h
		db	0A5h,0FCh, 00h, 00h, 0Ch, 00h
		db	0CCh,0FDh, 00h, 00h, 0Eh, 10h
		db	 86h, 77h, 00h, 30h, 00h, 00h
		db	 80h, 7Eh,0EDh, 00h, 01h, 1Eh
		db	 34h,0EDh, 00h, 00h, 1Fh, 00h
		db	 01h,0EDh, 00h, 00h, 0Ch,0EDh
		db	 00h, 02h, 0Fh, 00h, 07h,0EDh
		db	 00h, 00h, 0Ch, 00h, 04h,0EDh
		db	 00h, 00h, 0Ch, 00h, 06h,0EDh
		db	 00h, 00h, 1Fh, 00h, 07h,0EDh
		db	 00h, 02h, 0Eh,0EDh, 00h, 02h
		db	 04h, 00h, 00h,0FEh, 0Fh, 14h
		db	 01h, 00h, 00h, 04h, 38h, 04h
		db	 08h, 00h, 00h,0E0h, 0Fh, 5Fh
		db	0FDh,0EDh, 00h, 02h, 38h, 00h
		db	 00h, 04h, 30h,0FBh, 7Fh, 00h
		db	 00h,0FEh, 0Fh, 43h,0FEh,0EDh
		db	 00h, 01h,0FFh, 79h,0EDh, 00h
		db	 02h, 3Eh, 00h, 00h,0F0h, 07h
		db	 30h,0EDh, 00h, 00h, 0Ch, 18h
		db	 0Ch,0EDh, 00h, 00h,0F0h, 30h
		db	 1Fh,0DFh, 00h, 00h, 1Ch, 30h
		db	 8Ch,0DFh, 00h, 00h, 0Ch, 18h
		db	0F7h,0FEh, 00h, 00h,0F8h, 07h
		db	 88h, 7Dh,0EDh, 00h, 01h,0FEh
		db	 7Eh,0EDh, 00h, 02h,0FFh,0EDh
		db	 00h, 01h,0C1h, 03h, 00h, 02h
		db	 00h, 00h, 70h, 1Ch, 00h, 10h
		db	 00h, 00h, 2Fh,0F4h, 05h,0EDh
		db	 00h, 00h, 1Dh, 30h, 10h,0EDh
		db	 00h, 00h,0B2h, 72h,0EDh, 00h
		db	 01h, 11h,0C0h,0EDh, 00h, 01h
		db	 3Eh, 0Ch,0EDh, 00h, 01h,0D0h
		db	 85h,0EDh, 00h, 01h,0C1h, 03h
		db	 40h, 03h, 00h, 00h, 70h, 1Ch
		db	 10h, 18h, 00h, 00h, 2Fh,0F4h
		db	 05h, 20h, 00h, 00h, 1Dh, 30h
		db	 11h, 20h, 00h, 00h,0B2h, 72h
		db	 02h, 40h, 00h, 00h, 11h,0C0h
		db	 11h,0EDh, 00h, 00h, 3Eh, 0Ch
		db	 20h, 08h, 00h, 00h,0D0h, 85h
		db	 80h, 84h, 00h, 00h,0C1h, 03h
		db	0C0h, 03h, 00h, 00h, 70h, 1Ch
		db	 30h, 18h, 00h, 00h, 2Fh,0F4h
		db	 0Dh, 80h, 00h, 00h, 1Dh, 30h
		db	 19h, 30h, 00h, 00h,0B2h, 72h
		db	 02h, 60h, 00h, 00h, 11h,0C0h
		db	 11h, 80h, 00h, 00h, 3Eh, 0Ch
		db	 28h, 0Ch, 00h, 00h,0D0h, 85h
		db	0C0h, 84h, 00h, 00h,0C1h, 03h
		db	 40h, 03h, 00h, 00h, 70h, 1Ch
		db	 10h, 18h, 00h, 00h, 2Fh,0F4h
		db	 05h, 20h, 00h, 00h, 1Dh, 30h
		db	 11h, 20h, 00h, 00h,0B2h, 72h
		db	 02h, 40h, 00h, 00h, 11h,0C0h
		db	 11h,0EDh, 00h, 00h, 3Eh, 0Ch
		db	 20h, 08h, 00h, 00h,0D0h, 85h
		db	 80h, 84h, 00h, 00h, 01h, 00h
		db	 01h,0EDh, 00h, 06h, 01h, 00h
		db	 01h,0EDh, 00h, 00h, 14h,0EDh
		db	 00h, 02h,0A0h,0A4h, 20h, 24h
		db	0EDh, 00h, 05h, 01h, 00h, 01h
		db	0EDh, 00h, 0Ch, 03h, 40h, 00h
		db	 00h, 06h, 80h, 10h, 28h, 00h
		db	 00h, 0Fh, 40h, 00h, 04h, 00h
		db	 00h, 0Ah, 00h,0B0h,0F5h, 00h
		db	 00h, 04h, 00h, 08h,0F4h,0EDh
		db	 00h, 01h, 15h, 68h,0EDh, 00h
		db	 01h, 03h, 40h,0EDh, 00h, 05h
		db	 02h,0C0h, 02h,0C0h, 00h, 00h
		db	 1Fh, 68h, 10h, 28h, 00h, 00h
		db	 3Dh, 54h, 20h, 54h, 00h, 00h
		db	0BDh,0E9h,0B1h,0E9h, 00h, 00h
		db	 2Dh,0F4h, 29h,0F4h, 00h, 00h
		db	 16h,0A8h, 16h,0A8h, 00h, 00h
		db	 02h,0C0h, 02h,0C0h, 00h, 00h

_381UNKN	endp

seg_a		ends



		end	start
