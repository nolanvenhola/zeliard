
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_367UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_3e		equ	27A6h			;*
data_4e		equ	2A20h			;*
data_5e		equ	0FF09h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_367UNKN	proc	far

start:
                           lock	adc	ax,[bx+si]
		add	[bx+si],al
loc_2:
		push	es
		or	ss:data_5e[bp+si],ch
		or	ax,[bx+si]
		push	cs
		test	al,13h
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		sbb	[bx+di],al
;*		sbb	dx,bp
		db	 19h,0EAh		;  Fixup - byte match
		sbb	bh,ch
		sbb	bp,ss:data_4e[bp+di]
		and	[bp+di],ax
		and	dx,[di+24h]
		jg	$+27h			; Jump if >
		and	byte ptr ds:data_3e,0A9h
		sub	al,6Ah			; 'j'
		sub	ax,2E40h
		scasb				; Scan es:[di] for al
		xor	si,sp
		db	 36h, 05h, 38h,0A0h, 39h, 3Fh
		db	 3Ah,0FAh, 3Bh,0FCh, 49h,0BAh
		db	 4Bh,0FEh, 4Dh, 50h, 52h, 9Ah
		db	 56h, 04h, 58h, 15h, 5Bh,0D0h
		db	 5Eh, 1Fh, 60h,0F5h, 61h, 54h
		db	 63h, 5Fh, 67h, 8Ah, 6Bh, 0Ah
		db	 6Ch,0AFh, 6Dh, 07h, 6Eh,0CAh
		db	 73h, 57h, 76h,0D1h, 78h, 17h
		db	 79h, 1Dh, 7Bh, 47h, 81h, 10h
		db	 83h, 02h, 84h, 5Dh, 85h, 74h
		db	 86h,0F2h, 87h,0EFh, 88h,0F0h
		db	 89h, 45h, 8Ch, 75h, 8Dh, 7Dh
		db	 8Eh,0A2h, 91h,0D5h, 93h,0EBh
		db	 94h, 11h, 97h, 41h, 9Bh,0DDh
		db	 9Ch, 22h, 9Dh, 69h, 9Eh,0BFh
		db	0A3h,0C0h,0A7h, 0Dh,0B1h, 70h
		db	0B4h, 7Ch,0B5h,0A5h,0B6h,0C7h
		db	0B7h,0D7h,0B8h,0DFh,0B9h,0FBh
		db	0BDh, 14h,0C3h, 4Fh,0C8h, 51h
		db	0C9h,0A4h,0CCh,0D4h,0CEh, 71h
		db	0CFh,0DAh,0D6h,0F7h,0D8h, 28h
		db	0D9h, 37h,0DBh, 44h,0DEh, 59h
		db	0E0h, 68h,0E1h, 77h,0E2h, 82h
		db	0E3h, 92h,0E4h, 96h,0E5h,0B0h
		db	0E6h,0BCh,0E9h,0BEh,0EDh,0D3h
		db	0F8h, 0Ch,0F9h, 3Dh,0FFh,0FFh
		db	 0Bh, 33h, 03h, 0Bh, 01h, 0Fh
		db	 0Bh, 01h, 0Fh, 00h, 01h, 0Bh
		db	 0Eh, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 05h, 55h, 09h, 00h, 57h
		db	 09h, 01h, 5Fh,0FFh, 00h, 0Fh
		db	 00h, 01h, 00h, 0Fh, 00h, 01h
		db	 00h, 0Fh, 00h, 05h, 00h, 0Fh
		db	 00h, 05h, 00h, 0Fh, 00h, 07h
		db	 00h, 0Fh, 00h, 03h, 00h, 0Fh
		db	 00h, 03h, 00h, 0Fh, 00h, 07h
		db	 09h, 00h, 7Fh, 09h, 06h,0FDh
		db	 09h, 01h,0F4h, 09h, 01h,0D0h
		db	 09h, 01h, 41h, 09h, 00h,0FDh
		db	 07h, 09h, 00h,0F4h, 1Dh, 0Bh
		db	 0Eh, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 55h, 41h, 09h, 00h,0D5h
		db	 05h, 09h, 00h,0F4h, 17h, 0Bh
		db	 0Eh, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 41h, 10h, 09h, 00h, 70h
		db	 40h, 09h, 00h, 50h, 00h, 09h
		db	 00h,0D0h, 5Dh, 09h, 00h, 41h
		db	 57h, 09h, 00h, 05h, 7Fh, 09h
		db	 00h, 15h,0F5h, 09h, 00h, 55h
		db	0DDh, 09h, 00h,0D7h, 74h, 09h
		db	 00h, 7Fh,0D0h, 09h, 01h, 40h
		db	 09h, 00h,0D0h, 04h, 09h, 00h
		db	 40h, 00h, 09h, 00h, 40h, 00h
		db	 09h, 00h, 00h, 40h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 00h, 11h
		db	 09h, 00h, 00h, 04h, 09h, 00h
		db	 0Bh, 10h,0FFh,0EBh, 05h, 69h
		db	0EAh,0AAh, 2Ah, 08h, 07h, 0Bh
		db	 0Eh, 09h, 00h, 23h, 00h,0AAh
		db	0EAh,0AAh, 6Ah,0BAh,0AAh, 9Ah
		db	0AAh,0EAh,0AAh, 6Ah, 08h, 10h
		db	0BAh,0AAh, 9Ah, 08h, 0Ah,0AEh
		db	0AAh,0A6h, 08h, 08h,0AEh,0AAh
		db	0A6h, 08h, 0Ah,0BAh,0AAh, 9Ah
		db	0AAh, 0Bh, 0Eh,0EBh,0EFh, 69h
		db	 65h,0AEh,0AAh,0A6h, 08h, 04h
		db	0EAh,0AAh, 6Ah, 0Bh, 0Eh, 80h
		db	 00h, 80h, 00h,0A0h, 00h,0A0h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0AAh,0AEh,0AAh
		db	0A6h,0BAh,0AAh, 9Ah, 08h, 0Ch
		db	0AEh,0AAh,0A6h, 08h, 06h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 0Bh, 00h, 0Fh, 00h, 03h, 00h
		db	 0Fh, 00h, 03h, 00h, 0Fh, 00h
		db	 01h, 00h, 0Fh, 0Bh, 01h, 0Fh
		db	 0Bh, 01h, 0Fh, 00h, 01h, 00h
		db	 0Fh, 00h, 01h, 00h, 0Fh, 00h
		db	 01h, 00h, 0Fh, 00h, 01h, 00h
		db	 0Fh, 00h, 01h, 00h, 0Fh, 0Bh
		db	 01h, 0Fh, 0Bh, 01h, 0Fh, 0Bh
		db	 01h, 0Fh, 0Bh, 01h, 0Fh, 0Bh
		db	 01h, 0Fh, 0Bh, 00h, 09h, 00h
		db	 55h, 00h, 09h, 00h, 50h, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 00h, 03h
		db	 09h, 00h,0FDh, 00h, 09h, 00h
		db	0F4h, 00h, 09h, 00h,0D0h, 00h
		db	 09h, 00h, 40h, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 00h, 01h, 09h, 00h, 00h, 01h
		db	 09h, 00h, 00h, 04h, 09h, 00h
		db	 00h, 54h, 09h, 00h, 01h, 44h
		db	 09h, 00h, 04h, 54h, 09h, 00h
		db	 58h, 00h, 09h, 00h, 74h, 75h
		db	 09h, 00h,0D1h,0F4h, 09h, 00h
		db	 00h, 07h, 09h, 00h, 00h, 1Dh
		db	 09h, 00h, 00h, 74h, 09h, 00h
		db	 01h,0D1h, 09h, 00h, 07h, 47h
		db	 09h, 00h, 79h, 00h, 09h, 00h
		db	0F4h, 77h, 09h, 00h,0D1h, 7Fh
		db	 09h, 00h, 47h,0F4h, 09h, 00h
		db	 1Fh,0FDh, 09h, 00h, 7Fh,0FDh
		db	 09h, 00h,0DFh,0F5h, 09h, 01h
		db	0FCh, 09h, 01h,0F4h, 09h, 01h
		db	0FCh, 09h, 01h,0F4h, 08h, 03h
		db	0EAh,0AAh, 6Ah,0AAh,0ABh,0AAh
		db	0A9h,0AAh,0BEh,0AAh, 96h,0AEh
		db	0AFh,0A6h,0A5h,0AEh,0AFh,0A6h
		db	0A5h,0BAh,0EBh, 9Ah, 69h,0AAh
		db	0AFh,0AAh,0A4h, 08h, 0Eh,0BAh
		db	0AAh, 9Ah,0AAh,0FAh,0AAh, 46h
		db	0AAh,0CAh,0AAh, 22h,0AAh, 2Ah
		db	0AAh, 8Ah,0AAh,0AEh,0BCh,0A6h
		db	 92h,0AAh,0A2h,0AAh, 98h,0BAh
		db	 67h, 00h, 62h,0AAh, 2Ah,0A6h
		db	 8Ah,0A8h, 08h, 01h,0A2h, 2Ah
		db	 08h, 00h, 67h, 02h, 08h, 04h
		db	 2Ah, 08h, 10h,0BEh,0AAh, 96h
		db	0AAh,0BEh,0AAh, 96h, 08h, 0Eh
		db	0AEh,0AAh,0A6h, 08h, 08h,0AEh
		db	0AAh,0A6h, 08h, 0Fh,0EAh,0AAh
		db	 6Ah, 08h, 0Eh, 00h, 0Fh, 0Bh
		db	 01h, 0Fh, 0Bh, 01h, 0Fh, 0Bh
		db	 01h, 0Fh, 0Bh, 01h, 0Fh, 0Bh
		db	 01h, 0Fh, 0Bh, 01h, 0Fh, 0Bh
		db	 01h, 0Fh, 0Bh, 01h, 0Fh, 0Bh
		db	 01h, 0Fh, 0Bh, 01h, 0Fh, 0Bh
		db	 01h, 0Fh, 00h, 01h, 00h, 0Fh
		db	 00h, 01h, 00h, 0Fh, 00h, 01h
		db	 00h, 03h, 0Bh, 04h, 09h, 00h
		db	 4Fh, 09h, 01h, 1Fh, 09h, 01h
		db	 7Fh,0FDh, 09h, 01h,0F5h, 09h
		db	 01h,0D7h, 09h, 00h,0FDh, 5Fh
		db	 09h, 00h, 55h, 7Fh, 09h, 00h
		db	 15h, 09h, 01h, 45h, 09h, 01h
		db	 3Fh,0FDh
loc_4:
		or	[bx+di],ax
		cmc				; Complement carry
		or	[bx+di],ax
		ror	word ptr [bx+di],1	; Rotate
		add	[bx+9],ax
;*		add	ch,bh
		db	 00h,0FDh		;  Fixup - byte match
		pop	ds
		or	[bx+si],ax
		cmc				; Complement carry
		jg	loc_5			; Jump if >
;*		add	cl,dl
		db	 00h,0D1h		;  Fixup - byte match
		or	[bx+di],ax
		dec	di
		ror	byte ptr [bx+di],1	; Rotate
		add	[bx],bh
loc_5:
		ror	byte ptr [bx+di],1	; Rotate
		add	[bx+45h],bh
		or	[bx+si],ax
		std				; Set direction flag
		sbb	ax,9
		hlt				; Halt processor
		jl	$+0Bh			; Jump if <
;*		add	cl,dl
		db	 00h,0D1h		;  Fixup - byte match
		std				; Set direction flag
		or	[bx+si],ax
		db	0C7h,0FCh, 09h, 00h, 5Fh,0FCh
		db	 09h, 00h,0C7h,0FDh, 09h, 00h
		db	 1Fh,0F7h, 09h, 00h, 7Fh, 09h
		db	 0Dh, 57h,0D7h, 09h, 00h, 23h
		db	 00h, 09h, 01h,0F4h, 09h, 01h
		db	0F4h, 09h, 01h,0D5h, 09h, 01h
		db	 54h, 09h, 00h,0FDh, 54h, 09h
		db	 00h,0F5h, 54h,0FFh,0FCh, 55h
		db	 50h,0FFh,0F0h, 04h, 00h, 08h
		db	 03h,0ABh,0AAh,0A9h, 08h, 0Bh
		db	0EAh,0AAh, 6Ah, 08h, 12h,0BAh
		db	0AAh, 9Ah, 08h, 03h,0EAh,0AAh
		db	 6Ah, 08h, 08h,0ABh,0AAh,0A9h
		db	 08h, 02h,0AEh,0AAh,0A6h, 08h
		db	 0Bh, 2Ah,0AAh, 2Ah,0AAh, 0Ah
		db	0AAh, 0Ah, 08h, 08h,0EAh,0AAh
		db	 6Ah, 08h, 0Fh,0BAh,0AAh, 9Ah
		db	 08h, 0Ah,0ABh,0AAh,0A9h, 08h
		db	 0Fh,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A0h, 00h,0A0h, 00h, 80h
		db	 00h, 80h, 00h, 08h, 0Eh,0BAh
		db	0B2h, 9Ah,0B2h,0FAh,0FCh, 46h
		db	0DCh,0CAh,0FFh, 22h,0C5h, 2Bh
		db	0FFh, 8Bh, 01h,0AAh,0FFh, 2Ah
		db	 40h,0ABh,0FFh,0ABh,0C5h,0AAh
		db	0FFh,0AAh, 57h,0AAh,0BFh,0AAh
		db	 9Fh,0AAh,0FCh,0AAh,0FCh,0AAh
		db	0B0h,0AAh,0B0h,0AAh, 82h,0AAh
		db	 82h, 08h, 0Eh,0AEh,0AAh,0A6h
		db	 08h, 03h, 2Ah,0AAh, 2Ah,0AAh
		db	 2Ah,0AEh, 2Ah,0A6h,0EAh,0AAh
		db	0EAh,0AAh,0CAh,0AAh,0CAh,0AAh
		db	0CAh,0AAh,0CAh,0AAh,0CAh,0AAh
		db	0CAh,0AAh, 0Ah,0EAh, 0Ah, 6Ah
		db	 2Ah,0AAh, 2Ah,0AAh, 2Ah,0AAh
		db	 2Ah, 08h, 07h, 09h, 00h, 55h
		db	 04h, 09h, 00h, 50h, 04h, 09h
		db	 00h, 00h, 05h, 09h, 00h, 00h
		db	 01h, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 09h, 00h, 00h, 03h, 09h
		db	 00h,0FDh, 00h, 09h, 00h,0F4h
		db	 00h, 09h, 00h,0D0h, 00h, 09h
		db	 00h, 40h, 00h, 09h, 00h, 3Ch
		db	 00h, 09h, 00h, 57h, 00h, 09h
		db	 00h, 05h, 03h, 09h, 00h, 05h
		db	 0Dh,0FEh,0FFh, 16h, 37h, 09h
		db	 00h, 57h,0DDh,0FEh,0FFh, 7Eh
		db	 74h,0FBh,0FFh,0FBh,0D1h,0AFh
		db	0FFh,0AFh, 47h, 09h, 00h, 31h
		db	 1Dh, 09h, 00h,0F0h, 77h, 09h
		db	 00h,0D1h, 7Fh, 0Bh, 1Bh, 0Fh
		db	 0Bh, 18h, 0Fh,0FFh, 0Bh, 00h
		db	 09h, 00h, 05h, 57h, 00h,0FFh
		db	 00h, 01h, 03h,0FFh, 00h, 51h
		db	 03h,0FFh, 00h, 55h, 03h,0FFh
		db	 00h, 55h, 03h,0FFh, 00h, 55h
		db	 03h,0FFh, 00h, 51h, 03h,0FFh
		db	 00h, 53h, 03h,0FFh, 00h, 57h
		db	 09h, 00h, 55h, 5Dh, 09h, 00h
		db	 55h, 09h, 01h, 7Fh, 09h, 01h
		db	 7Fh, 09h, 0Ah,0FDh, 09h, 01h
		db	0F4h, 0Bh, 12h, 3Fh,0FFh, 0Bh
		db	 00h, 09h, 00h, 15h, 00h, 09h
		db	 00h, 55h, 01h, 0Bh, 0Eh, 3Fh
		db	0FFh, 0Bh, 00h,0FFh,0FEh, 01h
		db	 02h,0FFh,0FAh, 70h, 0Ah,0FFh
		db	0FAh, 50h, 0Ah, 09h, 00h,0F5h
		db	 05h, 09h, 00h,0DDh, 05h, 09h
		db	 00h,0F4h, 17h, 09h, 00h,0D4h
		db	 15h, 09h, 00h,0D0h, 5Dh, 09h
		db	 00h, 41h, 74h, 09h, 00h, 07h
		db	0D0h, 09h, 00h, 17h, 50h,0FFh
		db	0FAh,0D0h, 0Ah,0FFh,0FEh, 40h
		db	 02h,0FFh,0FEh, 40h, 02h,0FFh
		db	0FEh, 00h, 42h,0FFh,0FEh, 00h
		db	 02h,0FFh,0FEh, 00h, 12h,0FFh
		db	0FEh, 00h, 02h,0FFh,0FEh, 00h
		db	 02h, 0Bh, 0Eh,0FFh,0EBh, 05h
		db	 69h, 08h, 03h,0ABh,0AAh,0A9h
		db	0AAh,0BAh,0AAh, 9Ah, 0Bh, 0Eh
		db	0FFh,0EFh, 55h, 65h,0AEh,0ABh
		db	0A6h,0A9h, 08h, 16h,0AEh,0AAh
		db	0A6h, 08h, 08h,0AEh,0AAh,0A6h
		db	0EAh,0AAh, 6Ah, 08h, 00h,0AEh
		db	0AAh,0A6h, 08h, 02h,0ABh,0AAh
		db	0A9h, 08h, 0Fh, 0Bh, 0Eh,0EFh
		db	0E8h, 65h, 68h, 08h, 06h,0AEh
		db	0AAh,0A6h, 08h, 00h,0EAh,0AAh
		db	 6Ah, 08h, 0Eh,0ABh,0AAh,0A9h
		db	 08h, 07h, 80h, 00h, 80h, 00h
		db	 80h, 00h, 80h, 00h, 80h, 00h
		db	 80h, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h, 00h,0A0h, 00h, 03h,0FFh
		db	 00h, 57h, 03h,0FFh, 00h, 55h
		db	 00h,0FFh, 00h, 15h, 00h,0FFh
		db	 0Bh, 01h,0FFh, 0Bh, 01h,0FFh
		db	 00h, 01h, 00h,0FFh, 00h, 15h
		db	 00h,0FFh, 00h, 15h, 09h, 01h
		db	 50h, 09h, 00h,0F5h, 01h, 09h
		db	 00h, 50h, 07h, 09h, 00h, 00h
		db	 5Fh, 09h, 00h, 05h, 09h, 01h
		db	 5Fh, 09h, 01h,0DFh,0FDh, 09h
		db	 00h, 7Dh,0F4h, 00h, 3Fh, 00h
		db	 0Dh, 00h, 3Fh, 00h, 0Dh, 00h
		db	 3Fh, 00h, 03h, 00h, 3Fh, 0Bh
		db	 01h, 3Fh, 0Bh, 01h, 3Fh, 0Bh
		db	 01h, 3Fh, 0Bh, 01h, 0Fh, 0Bh
		db	 00h, 09h, 00h, 55h, 50h, 09h
		db	 00h, 55h, 00h, 09h, 00h, 50h
		db	 00h, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 7Fh
		db	 40h, 09h, 00h, 7Fh, 00h, 09h
		db	 00h,0FDh, 00h, 09h, 00h,0F4h
		db	 00h, 09h, 00h,0D0h, 00h, 09h
		db	 00h, 40h, 00h, 09h, 00h, 0Bh
		db	 00h, 09h, 00h, 0Bh, 00h,0FFh
		db	0FEh, 00h, 02h,0FFh,0FEh, 00h
		db	 06h, 09h, 00h, 00h, 04h, 09h
		db	 00h, 00h, 04h, 09h, 00h, 00h
		db	 14h, 09h, 00h, 00h, 15h, 09h
		db	 00h, 00h, 71h, 09h, 00h, 00h
		db	0F0h, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 00h
		db	 01h, 09h, 00h, 00h, 05h, 09h
		db	 00h, 00h, 57h, 09h, 00h, 01h
		db	 4Ch, 09h, 00h, 05h, 45h, 09h
		db	 00h, 17h, 1Dh, 09h, 00h, 5Dh
		db	 15h, 09h, 00h,0B4h, 00h, 09h
		db	 00h, 85h, 00h, 09h, 00h,0D1h
		db	0FCh, 09h, 00h,0C7h,0F4h, 08h
		db	 02h,0AEh,0AAh,0A6h, 08h, 00h
		db	0BAh,0AAh, 9Ah,0ABh,0EAh,0A9h
		db	 6Ah,0EAh,0FBh, 6Ah, 59h,0EAh
		db	0FFh, 6Ah, 54h,0AEh,0BCh,0A6h
		db	 92h,0AAh,0F2h,0AAh, 48h, 08h
		db	 0Bh,0BAh,0AAh, 9Ah, 08h, 04h
		db	 6Ah, 08h, 01h, 2Ah, 08h, 03h
		db	0EBh,0CAh, 69h, 22h,0AAh, 2Ah
		db	0A9h, 8Ah,0A8h,0AAh,0A6h, 2Ah
		db	0A2h,0AAh, 68h,0AAh, 8Ah, 08h
		db	 01h, 22h, 08h, 01h,0A8h,0AAh
		db	0A8h, 08h, 10h,0ABh,0AAh,0A9h
		db	 08h, 02h,0ABh,0EAh,0A9h, 6Ah
		db	0ABh,0EAh,0A9h, 6Ah, 08h, 1Bh
		db	0EAh,0AAh, 6Ah, 08h, 02h,0A0h
		db	 00h,0A0h, 00h,0A0h, 00h,0A0h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h, 08h, 1Eh, 09h, 00h, 0Bh
		db	 00h, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 00h
		db	 0Dh, 09h, 00h, 00h,0F7h, 09h
		db	 00h, 15h,0DFh, 09h, 00h, 17h
		db	 7Ch, 09h, 00h, 5Dh,0C1h, 09h
		db	 00h
loc_6:
;*		jl	loc_7			;*Jump if <
		db	 7Ch, 17h		;  Fixup - byte match
		or	[bx+si],ax
		add	[bx+9],di
		add	[bx+9],bh
		add	[bx-0Ch],di
		or	[bx+si],ax
		push	bp
		inc	cx
		or	[bx+si],ax
		adc	[bx],bl
		or	[bx+si],ax
		inc	sp
;*		jg	loc_8			;*Jump if >
		db	 7Fh, 09h		;  Fixup - byte match
		add	[di],dl
;*		aad	9			; undocumented inst
		db	0D5h, 09h		;  Fixup - byte match
		add	[di],al
		jg	$+0Bh			; Jump if >
		add	[di],dl
		std				; Set direction flag
		or	[bx+si],ax
		jg	loc_6			; Jump if >
		or	[si],ax
		db	0F1h, 09h, 01h,0C7h, 09h, 01h
		db	 1Fh,0F7h, 09h, 01h, 5Fh, 09h
		db	 00h, 4Fh,0D0h, 09h, 00h, 3Fh
		db	0D0h, 09h, 00h, 7Fh, 45h, 09h
		db	 01h, 7Dh, 09h, 01h,0FCh, 09h
		db	 01h,0FDh, 09h, 01h,0FCh, 09h
		db	 00h,0FDh,0F4h, 09h, 00h,0FDh
		db	 09h, 01h,0D1h, 09h, 01h, 47h
		db	 09h, 01h, 1Fh, 09h, 06h,0FDh
		db	 09h, 00h
data_2		db	0F5h
		db	 55h, 09h, 00h, 23h, 00h, 08h
		db	 03h,0BAh,0AAh, 9Ah, 08h, 03h
		db	0ABh,0AAh,0A9h, 08h, 02h, 2Eh
		db	 00h, 26h, 00h, 08h, 07h,0BAh
		db	0AAh, 9Ah, 08h, 02h,0EAh,0AAh
		db	 6Ah, 08h, 0Bh, 2Ah,0AAh, 2Ah
		db	0AAh, 0Ah,0AAh, 0Ah, 08h, 0Bh
		db	0AEh,0AAh,0A6h, 08h, 17h,0AEh
		db	0AAh,0A6h, 08h, 0Fh,0ABh,0AAh
		db	0A9h, 08h, 0Bh,0BAh,0AAh, 9Ah
		db	 08h, 20h, 8Ah,0AAh, 8Ah,0AAh
		db	0F2h, 6Ah,0F2h,0ABh,0FEh, 2Bh
		db	 4Eh,0AAh,0FFh,0AAh, 07h,0ABh
		db	0FFh,0ABh, 01h,0AAh,0FFh,0AAh
		db	 05h,0ABh,0FFh,0ABh, 1Fh,0AAh
		db	0FFh,0AAh,0FFh,0AAh,0FCh,0AAh
		db	0FCh,0AAh, 3Eh,0AAh, 3Eh,0AAh
		db	 82h,0AAh, 82h, 08h, 1Ah,0ABh
		db	0FAh,0A9h, 7Ah,0AFh,0FEh,0A4h
		db	 1Eh, 09h, 00h, 10h, 07h, 09h
		db	 00h, 74h, 1Fh, 09h, 00h,0FDh
		db	 7Fh, 0Fh,0FCh, 0Fh,0FCh,0ABh
		db	0F2h,0ABh,0F2h, 08h, 0Ah,0A8h
		db	 00h,0A8h, 00h, 28h, 00h, 28h
		db	 00h, 28h, 00h, 28h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 0Bh, 04h, 0Fh, 0Bh, 01h,0FFh
		db	 00h, 05h
loc_9:
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		inc	word ptr [bx+si]
		push	bp
		aas				; Ascii adjust
		inc	word ptr [bx+si]
		push	bp
		or	[bx+si],ax
		add	ax,951h
		add	[di],al
		push	bx
		or	[bx+si],ax
		adc	al,57h			; 'W'
		aas				; Ascii adjust
		inc	word ptr [bx+si]
		add	[bx+di],cx
		add	[di],dl
		push	ax
		or	[bx+si],ax
		jge	$+52h			; Jump if > or =
		or	[bx+si],ax
		jg	loc_9			; Jump if >
		or	[bx+di],ax
		hlt				; Halt processor
		or	[bx+di],ax
		hlt				; Halt processor
		or	[bx+di],ax
		hlt				; Halt processor
		or	[bx+di],ax
                           lock	or	dx,[bx]
		dec	word ptr [bp+di]
		add	[bx+di],cl
		add	[bp+di],cl
		adc	ax,0FFh
;*		add	di,di
		db	 01h,0FFh		;  Fixup - byte match
;*		jmp	far ptr loc_15		;*
		db	0EAh
		dw	2A00h, 0AAFFh		;  Fixup - byte match
			                        ;* No entry point to code
		adc	byte ptr ss:[9][bp+si],ch
		db	0C0h, 00h, 09h, 00h, 54h, 00h
		db	 09h, 00h, 75h, 00h, 09h, 00h
		db	 15h, 00h, 09h, 00h, 1Dh, 00h
		db	 09h, 00h, 1Dh, 00h, 09h, 00h
		db	 1Fh, 40h, 09h, 00h, 7Dh, 40h
		db	0FFh,0AAh, 10h,0AAh,0FFh,0AAh
		db	 0Ch,0AAh,0FFh,0EAh, 0Ch, 2Ah
		db	0FFh,0EAh, 03h, 2Ah,0FFh,0EAh
		db	 03h, 6Ah,0FFh,0FAh, 00h,0DAh
		db	0FFh,0FAh, 00h,0DAh,0FFh,0FAh
		db	 00h,0DAh, 0Bh, 12h,0FAh,0EEh
		db	 5Ah, 66h,0AAh,0ABh,0AAh,0A9h
		db	0ABh,0AAh,0A9h,0AAh, 0Bh, 12h
		db	0FCh, 00h, 54h, 00h,0ABh,0EBh
		db	0A9h, 69h, 08h, 03h,0AEh,0AAh
		db	0A6h, 08h, 0Ah,0EAh,0AAh, 6Ah
		db	 08h, 08h,0EAh,0AAh, 6Ah, 08h
		db	 03h,0EAh,0AAh, 6Ah, 08h, 02h
		db	0BAh,0AAh, 9Ah, 08h, 0Fh, 0Bh
		db	 16h, 80h, 00h, 80h, 00h,0ABh
		db	 00h,0A9h, 00h,0AAh, 80h,0AAh
		db	 80h,0AAh,0B0h,0AAh, 90h,0AAh
		db	0A8h,0AAh,0A8h,0AAh,0A8h,0AAh
		db	0A8h, 08h, 02h,0BAh,0AAh, 9Ah
		db	 08h, 07h, 3Fh,0FFh, 04h, 57h
		db	 3Fh,0FFh, 04h, 57h, 3Fh,0FFh
		db	 01h, 15h, 0Fh,0FFh, 01h, 05h
		db	 0Fh,0FFh, 0Bh, 00h, 0Fh,0FFh
		db	 0Bh, 00h, 03h,0FFh, 00h, 05h
		db	 03h,0FFh, 00h, 35h, 09h, 01h
		db	 50h, 09h, 00h,0F5h,0C1h, 09h
		db	 00h, 5Dh, 07h, 09h, 00h, 50h
		db	 0Fh, 09h, 00h, 00h, 7Fh, 09h
		db	 00h, 07h, 09h, 01h, 5Fh, 09h
		db	 01h, 7Fh,0FFh, 03h,0FFh, 00h
		db	 3Fh, 03h,0FFh, 00h, 37h, 03h
		db	0FFh, 00h, 57h, 00h,0FFh, 00h
		db	 01h, 00h,0FFh, 0Bh, 01h,0FFh
		db	 0Bh, 01h,0FFh, 0Bh, 01h,0FFh
		db	 0Bh, 00h, 09h, 04h, 7Fh, 75h
		db	 09h, 00h,0D5h, 54h, 09h, 00h
		db	 54h, 00h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 7Fh, 40h, 09h, 00h
		db	0FDh, 40h, 09h, 01h, 40h, 09h
		db	 00h,0FDh, 40h, 09h, 00h,0FDh
		db	 00h, 09h, 00h,0F5h, 00h, 09h
		db	 00h,0F4h, 00h, 09h, 00h,0D4h
		db	 00h,0FFh,0FAh, 00h,0DAh,0FFh
		db	0FEh, 00h,0F6h,0FFh,0FEh, 00h
		db	0F6h,0FFh,0FEh, 00h,0F6h,0FFh
		db	0FEh, 00h,0C6h,0FFh,0FEh, 00h
		db	0C6h, 09h, 00h, 03h,0C0h, 09h
		db	 00h, 03h,0C0h, 09h, 00h, 50h
		db	 00h, 09h, 00h, 40h, 00h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 00h, 01h, 09h, 00h, 00h
		db	 05h, 09h, 00h, 00h, 57h, 09h
		db	 00h, 01h, 40h, 09h, 00h, 05h
		db	 00h, 09h, 00h, 17h, 10h, 09h
		db	 00h, 5Dh, 10h, 09h, 00h, 7Ch
		db	 70h, 09h, 00h, 74h, 70h, 09h
		db	 00h,0FDh,0C0h, 09h, 01h,0C4h
		db	 08h, 02h,0BAh,0AAh, 9Ah, 08h
		db	 00h,0EAh,0AAh, 6Ah,0AFh,0AAh
		db	0A5h,0AAh,0ABh,0EEh,0A9h, 66h
		db	0ABh,0FEh,0A9h, 51h,0BAh,0F2h
		db	 9Ah, 48h,0ABh,0CAh,0A9h, 22h
		db	0AFh, 2Ah,0A4h, 8Ah,0A8h,0AAh
		db	0A6h, 2Ah,0A2h,0AAh, 98h,0AAh
		db	 8Ah,0AAh,0A2h,0AAh, 2Ah, 08h
		db	 01h, 8Ah, 08h, 01h,0A2h,0AAh
		db	0A2h, 08h, 10h,0AEh,0AAh,0A6h
		db	 08h, 02h,0AFh,0AAh,0A5h,0AAh
		db	0AFh,0AAh,0A5h, 08h, 1Bh,0AEh
		db	0AAh,0A6h, 08h, 03h, 80h, 00h
		db	 80h, 00h, 80h, 00h, 80h, 00h
		db	 80h, 00h, 80h, 00h, 80h, 00h
		db	 80h, 00h, 80h, 00h, 80h, 00h
		db	0A0h, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h, 00h,0A0h, 00h,0A8h, 00h
		db	0A8h, 00h,0A8h, 00h,0A8h, 00h
		db	0A8h, 00h,0A8h, 00h,0A8h, 00h
		db	0A8h, 0Bh, 00h,0FFh, 0Bh, 01h
		db	 3Fh, 0Bh, 01h, 3Fh, 00h, 01h
		db	 00h, 3Fh, 00h, 0Dh, 00h, 3Fh
		db	 00h, 03h, 00h, 3Fh, 00h, 03h
		db	 00h, 3Fh, 0Bh, 01h, 3Fh, 0Bh
		db	 00h, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 00h
		db	 15h, 09h, 00h, 55h, 5Fh, 09h
		db	 04h, 57h, 09h, 02h,0DFh, 09h
		db	 00h, 0Dh,0F3h, 00h, 0Fh, 00h
		db	 03h, 00h, 0Fh, 0Bh, 01h, 0Fh
		db	 0Bh, 01h, 0Fh, 0Bh, 01h, 0Fh
		db	 0Bh, 01h, 0Fh, 0Bh, 01h, 03h
		db	 0Bh, 04h, 09h, 00h, 00h, 0Fh
		db	 09h, 00h,0F5h, 09h, 01h, 7Fh
		db	 09h, 01h, 3Fh, 09h, 01h, 05h
		db	 4Fh, 09h, 00h, 10h, 1Fh, 09h
		db	 00h, 04h, 7Fh, 09h, 00h, 15h
		db	0D5h, 09h, 00h, 05h, 7Fh, 09h
		db	 00h, 55h, 09h, 01h, 7Fh, 09h
		db	 05h,0FDh, 09h, 06h,0F7h, 09h
		db	 01h, 5Fh, 09h, 01h,0FCh, 09h
		db	 01h,0F0h, 09h, 01h,0CDh, 09h
		db	 01h,0FDh, 09h, 01h,0FCh, 09h
		db	 01h,0FDh, 09h, 01h,0FCh, 09h
		db	 00h,0FDh,0F4h, 09h, 15h,0FDh
		db	 09h, 00h,0F5h, 55h, 09h, 00h
		db	 23h, 00h, 08h, 03h,0EAh,0AAh
		db	 6Ah, 08h, 03h,0AEh,0AAh,0A6h
		db	 08h, 02h, 49h, 00h, 52h, 00h
		db	 08h, 07h,0EAh,0AAh, 6Ah, 08h
		db	 12h, 2Ah,0AAh, 2Ah,0AAh, 0Ah
		db	0AAh, 0Ah, 08h, 07h,0BAh,0AAh
		db	 9Ah, 08h, 0Fh,0AEh,0AAh,0A6h
		db	 08h, 0Ch,0EAh,0AAh, 6Ah, 08h
		db	 06h,0ABh,0CAh,0A9h, 4Ah,0AFh
		db	0FAh,0A4h,0DAh,0ABh,0F2h,0A9h
		db	 72h,0AFh,0FCh,0ACh,0D4h,0ABh
		db	0FCh,0A8h,0FCh,0AFh,0F2h,0ADh
		db	0F2h,0ABh,0F2h,0ABh, 72h,0AAh
		db	0CAh,0AAh,0CAh, 08h, 06h, 0Bh
		db	 0Fh,0FFh, 0Bh, 00h, 0Fh,0FFh
		db	 00h, 55h, 3Fh,0FFh, 05h, 5Fh
		db	 3Fh,0FFh, 07h, 7Fh, 0Bh, 0Fh
		db	 03h, 0Bh, 01h, 03h, 0Bh, 01h
		db	 03h, 0Bh, 01h, 03h, 0Bh, 00h
		db	 09h, 00h, 15h,0FDh, 09h, 00h
		db	 15h,0F4h, 09h, 00h, 1Fh,0C0h
		db	 09h, 00h, 1Fh, 01h, 09h, 00h
		db	 7Dh, 05h, 09h, 00h, 74h, 1Dh
		db	 09h, 00h, 70h, 1Fh, 09h, 00h
		db	0D0h, 77h, 0Bh, 0Eh, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 55h, 75h
		db	 09h, 00h,0D5h, 00h, 09h, 00h
		db	 50h, 05h, 0Bh, 0Eh, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 01h, 10h
		db	 09h, 00h, 70h, 40h, 09h, 00h
		db	0D0h, 15h, 09h, 00h, 00h, 5Dh
		db	 09h, 00h, 05h,0D7h, 09h, 00h
		db	 1Fh,0FDh, 09h, 00h, 5Fh,0D4h
		db	 09h, 01h, 40h, 09h, 00h,0F5h
		db	 00h, 09h, 00h,0D0h, 00h, 09h
		db	 00h, 40h, 00h, 09h, 01h, 50h
		db	 09h, 00h, 75h, 00h, 09h, 00h
		db	 50h, 00h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 10h, 09h, 00h
		db	 00h, 01h,0FFh,0EAh, 00h, 2Ah
		db	0FFh,0AAh, 50h,0AAh,0FFh,0AAh
		db	 54h,0AAh, 0Bh, 0Eh, 09h, 00h
		db	 23h, 00h,0AAh,0ABh,0AAh,0A9h
		db	0AAh,0EAh,0AAh, 6Ah,0ABh,0AAh
		db	0A9h,0AAh,0FEh,0AAh, 02h,0AAh
		db	0FEh,0AAh, 02h,0AAh,0FEh,0AAh
		db	 02h,0AAh,0FAh,0AAh, 0Ah,0AAh
		db	0FAh,0AAh, 0Ah,0AAh,0FAh,0AAh
		db	 0Ah,0AAh,0FAh,0AAh, 0Ah,0AAh
		db	0FAh,0AAh, 0Ah,0AAh, 0Bh, 0Eh
		db	0F0h, 00h, 50h, 00h,0ABh,0FBh
		db	0A9h, 59h, 08h, 06h, 0Bh, 16h
		db	0ECh, 00h, 64h, 00h,0AAh, 00h
		db	0AAh, 00h,0AAh,0ABh,0AAh,0A9h
		db	0AAh,0EAh,0AAh, 6Ah, 08h, 02h
		db	0BAh,0AAh, 9Ah, 08h, 10h, 00h
		db	0AAh, 00h,0BAh, 80h, 9Ah, 80h
		db	0AAh, 80h,0AAh, 80h,0AAh, 80h
		db	0AAh, 80h,0AAh, 80h,0AAh, 80h
		db	0EAh, 80h, 6Ah, 80h,0AAh, 80h
		db	0AAh, 80h,0AAh, 00h,0AAh, 0Bh
		db	 00h, 03h, 0Bh, 01h, 03h, 0Bh
		db	 01h, 03h, 0Bh, 01h, 0Fh, 0Bh
		db	 01h, 0Fh, 0Bh, 01h, 0Fh, 0Bh
		db	 01h, 0Fh, 00h, 01h, 00h, 0Fh
		db	 00h, 01h, 09h, 00h,0C0h, 7Dh
		db	 09h, 00h, 01h,0F4h, 09h, 00h
		db	 07h,0D0h, 09h, 00h, 17h,0D0h
		db	 09h, 00h, 5Fh, 40h, 09h, 00h
		db	 7Fh, 40h, 09h, 00h,0FDh, 00h
		db	 09h, 00h,0F4h, 0Bh, 00h, 0Fh
		db	 00h, 01h, 00h, 0Fh, 00h, 01h
		db	 00h, 0Fh, 00h, 03h, 00h, 0Fh
		db	 00h, 03h, 00h, 0Fh, 00h, 03h
		db	 00h, 0Fh, 00h, 01h, 00h, 0Fh
		db	 00h, 01h, 00h, 0Fh, 00h, 01h
		db	 09h, 00h,0F4h, 00h, 09h, 00h
		db	0D0h, 00h, 09h, 00h,0D0h, 00h
		db	 09h, 00h, 40h, 00h, 09h, 00h
		db	 40h, 01h, 09h, 00h, 00h, 01h
		db	 09h, 00h, 00h, 07h, 09h, 00h
		db	 00h, 05h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 00h, 01h
		db	 09h, 00h, 00h, 17h, 09h, 00h
		db	 00h, 5Dh, 09h, 00h, 01h, 74h
		db	 09h, 00h, 01h,0D1h, 09h, 00h
		db	 00h, 01h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 05h, 50h, 09h, 00h
		db	 5Fh, 71h, 09h, 01h, 00h, 09h
		db	 00h, 40h,0DDh, 09h, 00h, 37h
		db	0FDh, 09h, 00h,0DFh,0FCh, 09h
		db	 00h, 07h, 47h, 09h, 00h, 1Dh
		db	 1Fh, 09h, 00h, 74h, 7Fh, 09h
		db	 00h, 71h, 09h, 01h,0D1h, 09h
		db	 01h,0C7h, 09h, 01h, 47h, 09h
		db	 01h, 1Fh, 09h, 02h,0FCh, 09h
		db	 01h,0FDh, 09h, 01h,0FDh, 09h
		db	 01h,0F5h, 09h, 01h,0FCh, 09h
		db	 01h,0F4h, 09h, 01h,0FCh, 09h
		db	 01h,0F4h,0EAh,0AAh, 2Ah,0AAh
		db	0EAh,0AEh, 2Ah,0A6h,0EAh,0AAh
		db	 2Ah,0AAh,0EAh,0ABh, 2Ah,0A9h
		db	0AAh,0EAh,0AAh, 6Ah,0AAh,0EAh
		db	0AAh, 6Ah,0ABh,0AEh,0A9h,0A6h
		db	 08h, 0Ah,0BAh,0AAh, 9Ah,0AAh
		db	0EAh,0AAh, 6Ah,0AAh,0FBh,0AAh
		db	 59h,0AAh,0FFh,0AAh, 54h, 6Ah
		db	0BCh,0AAh, 92h, 2Ah,0F2h,0AAh
		db	 48h, 08h, 00h,0EBh,0AAh, 69h
		db	 08h, 01h,0A9h,0ABh, 0Eh, 00h
		db	0A6h,0AAh,0A2h,0AAh, 68h,0AAh
		db	 8Ah, 08h, 01h, 22h, 08h, 00h
		db	 0Eh, 02h, 08h, 02h,0CAh,0AAh
		db	 22h,0AAh, 2Ah,0AAh, 8Ah, 08h
		db	 01h, 2Ah, 08h, 08h,0ABh,0AAh
		db	0A9h,0AAh,0ABh,0AAh,0A9h, 08h
		db	 03h, 00h,0AAh, 00h,0AAh, 00h
		db	0AAh, 00h,0AAh, 00h,0AAh, 00h
		db	0AAh, 00h,0AAh, 00h,0AAh, 00h
		db	0AAh, 00h,0A8h, 00h,0A8h, 00h
		db	0E8h, 00h, 68h, 00h,0A8h, 00h
		db	0A8h, 00h, 08h, 0Bh,0AEh,0AAh
		db	0A6h, 08h, 0Eh, 09h, 00h, 00h
		db	 05h, 09h, 00h, 00h, 14h, 09h
		db	 00h, 00h, 14h, 09h, 00h, 00h
		db	 11h, 09h, 00h, 00h, 11h, 09h
		db	 00h, 00h, 51h, 09h, 00h, 00h
		db	 41h, 09h, 00h, 00h, 45h, 00h
		db	 0Fh, 0Bh, 01h, 0Fh, 0Bh, 01h
		db	 0Fh, 0Bh, 01h, 0Fh, 0Bh, 01h
		db	 0Fh, 0Bh, 01h, 0Fh, 0Bh, 01h
		db	 03h, 0Bh, 04h, 09h, 00h, 00h
		db	 47h, 09h, 00h, 00h, 45h, 09h
		db	 00h, 01h, 1Dh, 09h, 00h, 01h
		db	 1Dh, 09h, 00h, 01h, 15h, 09h
		db	 00h, 01h, 14h, 09h, 00h, 01h
		db	 14h, 09h, 00h, 00h, 04h
loc_10:
		or	[bx+si],ax
		pop	ds
		or	[bx+di],ax
;*		jg	loc_11			;*Jump if >
		db	 7Fh,0FDh		;  Fixup - byte match
		or	[bx+si],ax
		jg	loc_10			; Jump if >
		or	[bx+di],ax
		ror	word ptr [bx+di],1	; Rotate
		add	[bx+47h],bh
		or	[bx+si],ax
		std				; Set direction flag
		pop	di
		or	[bx+si],ax
		jnz	loc_13			; Jump if not zero
		or	[bx+si],ax
;*		aam	9			; undocumented inst
		db	0D4h, 09h		;  Fixup - byte match
		add	dl,al
		or	[bx+si],ax
		pop	di
		ror	byte ptr [bx+di],1	; Rotate
		add	[bx+45h],bh
		or	[bx+si],ax
		std				; Set direction flag
		sbb	ax,9
		hlt				; Halt processor
		jl	loc_12			; Jump if <
;*		add	cl,dl
		db	 00h,0D1h		;  Fixup - byte match
		std				; Set direction flag
		or	[bx+si],ax
		sar	sp,cl			; Shift w/sign fill
		or	[bx+si],ax
loc_12:
		inc	di
		cld				; Clear direction
		or	[bx+si],ax
		ror	word ptr [bx+di],cl	; Rotate
;*		add	bx,dx
		db	 01h,0D3h		;  Fixup - byte match
		std				; Set direction flag
		or	[bx+si],ax
		dec	di
		std				; Set direction flag
		or	[bx+si],ax
		pop	ss
		std				; Set direction flag
		or	[bx+si],ax
		pop	ds
		or	[bx+di],ax
		pop	di
		or	[bx+di],ax
		push	di
		xlat				; al=[al+[bx]] table
		or	[bx+si],ax
		and	ax,[bx+si]
loc_13:
		or	[bx+si],ax
		dec	di
		hlt				; Halt processor
		or	[bx+si],ax
		pop	ds
;*		aam	9			; undocumented inst
		db	0D4h, 09h		;  Fixup - byte match
		add	[di],bh
		push	bp
		or	[bx+si],ax
		cmc				; Complement carry
		push	sp
		or	[bx+si],ax
		cmc				; Complement carry
		push	sp
		or	[bx+si],ax
		cmc				; Complement carry
		push	sp
		db	0FFh,0FCh,0F5h, 50h,0FFh,0F0h
		db	 04h, 00h, 09h, 00h,0C0h, 7Dh
		db	 09h, 00h, 01h,0F4h, 09h, 00h
		db	 07h,0D0h, 09h, 00h, 17h,0D0h
		db	 09h, 00h, 5Fh, 40h, 09h, 00h
		db	 7Fh, 43h, 09h, 00h,0FDh, 04h
		db	 09h, 00h,0F4h, 30h, 09h, 00h
		db	0F4h, 34h, 09h, 00h,0D0h, 3Dh
		db	 09h, 00h,0D0h, 0Fh,0FFh,0FEh
		db	 40h, 02h, 09h, 00h, 40h, 01h
		db	 09h, 00h, 00h, 01h, 09h, 00h
		db	 00h, 07h, 09h, 00h, 00h, 05h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 00h, 01h, 09h, 00h
		db	 00h, 17h, 09h, 00h,0F0h, 5Ch
		db	0FBh,0FFh, 59h, 71h,0FEh,0BFh
		db	 3Eh, 95h, 09h, 00h, 00h, 01h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 05h, 50h, 09h, 00h, 5Fh, 71h
		db	 09h, 01h, 00h, 09h, 00h, 70h
		db	0DDh,0EFh,0FFh,0E7h,0FDh, 09h
		db	 01h,0FCh,0FAh,0FFh, 5Ah,0F7h
		db	0FAh,0BFh,0FAh,0BFh,0EBh,0EFh
		db	0E8h, 6Fh,0AFh,0FAh,0A1h,0FAh
		db	 09h, 00h,0D1h, 09h, 00h,0FEh
		db	0C7h,0F2h, 09h, 00h, 47h,0FCh
		db	 09h, 00h, 1Fh,0FFh,0EFh,0FFh
		db	0ECh,0FCh,0EFh,0FFh,0ECh,0FDh
		db	0AEh,0FFh,0AEh,0FDh,0BFh,0FFh
		db	0B3h,0F5h,0FBh,0FFh,0CBh,0FCh
		db	0EFh,0FFh, 2Fh,0F4h, 09h, 01h
		db	0FCh, 09h, 01h,0F4h, 0Bh, 17h
		db	 0Fh, 0Bh, 01h,0FFh, 0Bh, 00h
		db	 03h,0FFh, 0Bh, 00h, 0Fh,0FFh
		db	 00h, 01h, 0Fh,0FFh, 00h, 04h
		db	 3Fh,0FFh, 00h, 10h, 3Fh,0FFh
		db	 00h, 44h, 3Fh,0FFh, 00h, 40h
		db	 3Fh,0FFh, 00h, 40h, 3Fh,0FFh
		db	 0Bh, 14h, 0Fh,0FFh, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 00h, 15h, 0Bh, 0Eh, 3Fh,0FFh
		db	 0Bh, 00h, 09h, 00h, 01h, 10h
		db	 09h, 00h, 00h, 40h, 09h, 00h
		db	0D0h, 01h, 09h, 00h, 41h, 5Dh
		db	 09h, 00h, 35h,0C0h, 09h, 00h
		db	 1Ch, 00h, 09h, 00h, 40h, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 0Bh, 10h
		db	 09h, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 09h, 00h, 50h, 00h
		db	 09h, 00h, 44h, 0Bh, 0Fh,0FFh
		db	0F0h, 01h, 10h,0FFh,0EBh, 00h
		db	 29h,0FAh,0AAh, 0Ah,0AAh,0EAh
		db	0AEh, 2Ah,0A6h, 09h, 00h, 0Bh
		db	 00h,0FFh,0FEh, 00h, 02h,0FFh
		db	0FEh, 00h, 02h,0FFh,0FAh, 00h
		db	 0Ah,0FFh,0FAh, 00h, 0Ah,0FFh
		db	0FAh, 00h, 0Ah,0FFh,0EAh, 00h
		db	 2Ah,0FFh,0EAh, 00h, 2Ah, 08h
		db	 0Eh,0ABh,0AAh,0A9h, 08h, 08h
		db	0EAh,0AAh, 6Ah, 0Bh, 12h,0ACh
		db	 00h,0A4h, 00h,0ABh,0F0h,0A9h
		db	 50h,0AAh,0ABh,0AAh,0A9h,0EAh
		db	0ABh, 6Ah,0A9h, 08h, 03h,0ABh
		db	0AAh,0A9h, 08h, 03h,0EAh,0AAh
		db	 6Ah, 08h, 0Ah,0A8h, 00h,0A8h
		db	 00h,0BBh, 00h, 99h, 00h,0AAh
		db	 80h,0AAh, 80h,0AAh,0B0h,0AAh
		db	 90h,0AAh,0A0h,0AAh,0A0h,0AAh
		db	0A8h,0AAh,0A8h,0ABh,0A8h,0A9h
		db	0A8h,0AAh,0A8h,0AAh,0A8h, 0Bh
		db	 17h, 03h, 0Bh, 01h, 03h, 0Bh
		db	 00h, 09h, 00h, 01h, 00h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 04h
		db	 00h, 09h, 00h, 04h, 00h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 09h, 00h, 10h, 00h, 09h
		db	 00h, 0Bh, 01h, 03h, 0Bh, 01h
		db	 03h, 0Bh, 01h, 03h, 0Bh, 01h
		db	 03h, 0Bh, 01h, 03h, 0Bh, 01h
		db	 03h, 00h, 01h, 00h, 0Fh, 00h
		db	 01h, 00h, 0Fh, 00h, 01h, 09h
		db	 00h, 0Bh, 00h, 09h, 00h, 00h
		db	 01h, 09h, 00h, 40h, 01h, 09h
		db	 00h, 40h, 04h, 09h, 00h, 40h
		db	 04h, 09h, 00h, 00h, 04h, 09h
		db	 00h, 00h, 11h, 09h, 00h, 00h
		db	 11h, 09h, 00h, 0Bh, 00h, 09h
		db	 00h, 00h, 05h, 09h, 00h, 00h
		db	 5Dh, 09h, 00h, 01h, 74h, 09h
		db	 00h, 07h, 51h, 09h, 00h, 15h
		db	 5Fh, 09h, 00h, 1Dh, 7Fh, 09h
		db	 00h, 75h, 7Fh, 09h, 00h, 15h
		db	 50h, 09h, 00h, 75h, 55h, 09h
		db	 00h, 50h, 00h, 09h, 00h, 05h
		db	 54h, 09h, 00h, 5Dh,0F5h, 09h
		db	 01h,0FDh, 09h, 08h, 45h, 09h
		db	 01h, 17h,0FDh, 09h, 00h, 1Fh
		db	0DFh, 09h, 00h, 5Fh, 09h, 01h
		db	 5Fh, 09h, 01h, 5Fh, 09h, 01h
		db	 7Dh,0FDh, 09h, 00h, 77h, 09h
		db	 09h,0FDh, 7Fh, 09h, 04h, 5Fh
		db	 09h, 02h,0FDh, 09h, 01h,0D5h
		db	 09h, 00h,0FDh, 40h,0FFh,0EAh
		db	 00h, 2Ah,0FFh,0AAh, 54h,0AAh
		db	0FFh,0AAh, 00h,0AAh,0FFh,0AAh
		db	 40h,0AAh,0FFh,0AEh, 50h,0A6h
		db	0FEh,0AEh,0D2h,0A6h,0FEh,0BAh
		db	0F2h, 9Ah,0FEh,0AAh,0C2h, 08h
		db	 03h,0EAh,0AAh, 6Ah,0AAh,0ABh
		db	0AAh,0A9h,0AAh,0BEh,0AAh, 96h
		db	0AAh,0AFh,0BAh,0A5h, 9Ah,0AFh
		db	0FAh,0A5h, 46h,0EBh,0CAh, 69h
		db	 22h,0AFh, 2Ah,0A4h, 8Ah,0FEh
		db	0AEh, 32h,0A6h,0FEh,0AAh, 32h
		db	0AAh,0FAh,0BAh,0CAh, 8Ah,0FAh
		db	0AAh,0CAh,0A6h,0FAh,0A8h,0CAh
		db	0AAh,0FAh,0A2h,0CAh,0AAh,0FAh
		db	 8Ah, 4Ah, 8Ah,0FAh,0AAh, 0Ah
		db	0AAh,0BCh,0AAh, 92h, 2Ah,0A2h
		db	0AAh, 98h,0AAh, 8Ah,0AAh, 62h
		db	0AAh, 2Ah,0AAh, 8Ah, 08h, 03h
		db	 2Ah, 08h, 01h, 8Ah,0AAh, 8Ah
		db	 08h, 14h,0ABh,0AAh,0A9h, 08h
		db	 0Bh,0A0h,0AAh,0A0h,0AAh,0A0h
		db	0AAh,0A0h,0AAh,0A0h,0AAh,0A0h
		db	0AAh, 80h,0AAh, 80h,0AAh, 80h
		db	0AAh, 80h,0AAh, 80h,0AAh, 80h
		db	0AAh, 80h,0AAh, 80h,0AEh, 80h
		db	0A6h, 80h,0AAh, 00h,0AAh, 00h
		db	0AAh, 00h,0AAh, 00h,0AAh, 00h
		db	0AAh, 00h,0AAh, 00h,0AAh, 00h
		db	0EAh, 00h, 6Ah, 00h,0AAh, 00h
		db	0AAh, 00h,0AAh, 00h,0AAh, 00h
		db	0A8h, 00h,0A8h, 00h, 09h, 00h
		db	 00h, 11h, 09h, 00h, 00h, 11h
		db	 09h, 00h, 00h, 47h, 09h, 00h
		db	 00h, 45h, 09h, 00h, 00h, 45h
		db	 09h, 00h, 00h, 0Dh, 09h, 00h
		db	 00h, 04h, 09h, 00h, 00h, 04h
		db	 09h, 00h, 00h, 04h, 09h, 00h
		db	 00h, 04h, 09h, 00h, 00h, 04h
		db	 09h, 00h, 00h, 05h, 09h, 00h
		db	 00h, 04h, 09h, 00h, 01h, 0Ch
		db	 09h, 00h, 01h, 10h, 09h, 00h
		db	 00h, 04h, 09h, 00h,0D7h,0DFh
		db	 09h, 00h, 47h, 09h, 01h, 47h
		db	 09h, 01h, 1Fh,0FDh, 09h, 00h
		db	 1Fh,0F4h, 09h, 00h, 1Fh,0F4h
		db	 09h, 00h, 7Fh,0F1h, 09h, 00h
		db	 7Fh,0D1h, 09h, 00h,0F4h, 15h
		db	 09h, 00h,0D1h, 7Dh, 09h, 00h
		db	 45h,0DDh, 09h, 00h, 1Fh, 75h
		db	 09h, 00h, 7Fh, 75h, 09h, 00h
		db	 7Dh,0D5h, 09h, 01h, 54h, 09h
		db	 00h,0F5h, 54h, 09h, 00h, 7Fh
		db	0D3h, 09h, 00h, 7Fh,0FDh, 09h
		db	 00h, 5Fh, 09h, 01h, 17h,0DDh
		db	 09h, 00h, 17h,0DDh, 09h, 00h
		db	 07h,0F5h, 09h, 00h, 47h,0D5h
		db	 09h, 00h, 41h, 55h, 09h, 00h
		db	0DDh, 54h, 09h, 00h,0F5h, 54h
		db	 09h, 00h, 23h, 00h, 09h, 00h
		db	 55h, 54h, 09h, 00h, 55h, 54h
		db	 09h, 00h, 55h, 54h,0FFh,0FCh
		db	 55h, 50h,0FFh,0F0h, 04h, 00h
		db	0EAh,0AAh, 2Ah,0AAh,0EAh,0AAh
		db	 2Ah,0AAh,0EAh,0AAh, 2Ah,0AAh
		db	0EAh,0AAh, 2Ah,0AAh,0EAh,0AAh
		db	 2Ah,0AAh,0EAh,0BAh, 2Ah, 9Ah
		db	 08h, 0Ah,0EAh,0AAh, 6Ah, 08h
		db	 03h,0AEh,0AAh,0A6h, 08h, 03h
		db	0BAh,0AAh, 9Ah, 08h, 0Fh,0ABh
		db	0AAh,0A9h, 08h, 0Bh, 2Ah,0AAh
		db	 2Ah,0AAh, 0Ah,0AAh, 0Ah,0AAh
		db	0EAh,0AAh, 6Ah, 08h, 08h,0BAh
		db	0AAh, 9Ah, 08h, 17h,0BAh,0AAh
		db	 9Ah, 08h, 0Fh,0AEh,0AAh,0A6h
		db	 09h, 00h, 15h, 50h, 09h, 00h
		db	 75h, 55h, 09h, 00h, 50h, 00h
		db	 09h, 00h, 05h, 54h, 09h, 00h
		db	 5Dh,0F5h, 09h, 00h,0F0h, 3Dh
		db	0FFh,0BFh,0C7h, 8Fh,0FFh,0EFh
		db	 11h,0EFh,0FFh,0AFh, 11h,0AFh
		db	0FFh,0EFh, 37h,0EFh,0FFh,0AFh
		db	0CDh,0AFh,0FAh,0BFh,0FAh,0BFh
		db	 09h, 00h, 5Fh, 09h, 02h,0FDh
		db	 09h, 01h,0D5h, 09h, 00h,0FDh
		db	40h

_367UNKN	endp

seg_a		ends



		end	start
