
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR1_30	                                 лл
;лл					                                 лл
;лл      Created:   16-Feb-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_13e	equ	0C00h			;*
data_14e	equ	1540h			;*
data_15e	equ	86A8h			;*
data_16e	equ	8714h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_30		proc	far

start:
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		or	ax,[bx+si]
		add	[bx+si],al
		add	byte ptr data_9[bx],dl
		adc	ax,80h
		add	ds:data_16e[bx+si],sp
		add	[si],al
		add	ax,0FF57h
		rcl	data_9[bx],1		; Rotate thru carry
		das				; Decimal adjust
		nop
		add	[bx+di],al
		mov	al,ds:data_15e
		add	[di],al
		or	bh,data_4[bx]
		db	0FEh, 97h, 00h, 06h, 61h,0E4h
		db	 00h, 01h, 81h, 58h, 86h, 00h
		db	 01h,0BFh, 83h, 00h, 01h, 07h
		db	 88h, 00h, 04h, 06h,0D0h, 0Fh
		db	 90h, 8Bh, 00h, 06h, 60h, 79h
		db	 00h, 01h, 03h, 58h, 85h, 00h
		db	 01h, 1Fh, 88h, 00h, 02h, 13h
		db	0E8h, 83h, 00h, 05h, 1Fh,0FFh
		db	0A0h, 7Fh,0FEh, 85h, 00h, 03h
		db	 7Fh,0FFh, 80h, 82h, 00h, 06h
		db	 70h, 1Eh, 80h, 02h, 83h, 4Ch
		db	 84h, 00h, 02h, 07h, 80h, 86h
		db	 00h, 01h, 3Dh, 82h,0FFh, 01h
		db	 48h, 84h, 00h, 05h, 01h,0FEh
		db	 00h, 02h,0F8h, 83h, 00h, 01h
		db	 7Eh, 82h, 00h
data_1		dw	7E01h			; Data table (indexed access)
data_2		dw	82h			; Data table (indexed access)
data_3		dw	3803h
		db	 07h, 00h, 82h, 03h, 01h,0A2h
		db	 83h, 00h, 02h, 01h,0E0h, 87h
		db	 00h, 03h, 09h, 00h, 01h, 83h
		db	 00h, 01h, 2Eh, 82h, 00h, 07h
		db	 03h,0E0h, 1Ch, 87h, 80h, 00h
		db	 06h, 83h, 00h, 0Dh, 01h,0E0h
		db	 00h, 1Eh, 03h, 80h, 00h, 01h
		db	0E8h, 80h, 00h, 01h,0F8h, 88h
		db	 00h, 03h, 06h,0C0h, 04h, 82h
		db	 00h, 03h, 0Ah,0AAh, 18h, 82h
		db	 00h, 06h, 38h, 0Eh,0C0h, 60h
		db	 00h, 60h, 82h, 00h, 0Dh, 03h
		db	0F0h, 18h, 00h, 07h, 81h,0C0h
		db	 08h, 00h, 7Dh, 00h, 01h,0F8h
		db	 8Ah, 00h, 04h
data_4		db	7			; Data table (indexed access)
		db	 86h,0C0h, 18h, 82h, 00h, 03h
		db	 10h, 0Ch, 06h, 82h, 00h, 07h
		db	 01h,0F8h, 00h,0C0h, 1Fh,0F8h
		db	 60h, 82h, 00h, 05h, 3Eh, 80h
		db	 01h, 80h, 3Ah, 84h, 00h, 03h
		db	 0Eh
data_5		dw	0C631h			; Data table (indexed access)
		db	 84h, 00h, 02h, 07h, 50h, 82h
		db	 00h, 09h, 01h,0C0h, 00h, 04h
		db	 00h, 01h, 00h, 06h, 03h, 83h
		db	 00h, 02h, 1Fh,0FCh, 83h, 00h
		db	 0Ah, 1Eh, 00h, 60h, 3Bh, 40h
		db	 0Eh, 00h, 3Ah, 00h, 02h, 83h
		db	 00h, 02h, 38h, 64h, 84h, 00h
		db	 03h, 03h,0E0h, 80h, 84h, 00h
		db	 07h, 03h, 90h, 02h, 01h, 04h
		db	 01h, 80h, 83h, 00h, 01h, 60h
		db	 83h, 00h, 0Eh, 01h,0FEh, 00h
		db	 3Ah,0AAh,0D2h, 00h, 3Eh, 01h
		db	0E9h, 80h, 04h, 00h, 1Eh, 87h
		db	 00h, 01h, 70h, 82h, 00h, 0Ah
		db	 04h, 00h, 01h,0C0h, 06h, 03h
		db	 00h, 01h, 80h, 18h, 82h, 00h
		db	 01h, 60h, 86h, 00h, 0Ch, 3Fh
		db	 7Dh, 4Ch, 00h, 3Eh, 19h,0F4h
		db	0C0h, 08h, 00h, 07h,0F0h, 82h
		db	 00h, 01h, 13h, 82h, 00h, 05h
		db	 01h, 0Fh, 8Dh, 00h,0E0h, 82h
		db	 00h, 07h, 80h, 06h, 01h,0F0h
		db	 01h, 80h, 38h, 82h, 00h, 01h
		db	 60h, 86h, 00h, 82h, 3Fh, 07h
		db	0C0h, 00h, 3Fh, 80h, 7Ah,0C0h
		db	 10h, 85h, 00h, 07h, 40h,0C0h
		db	 00h, 01h, 00h, 7Fh,0FEh, 84h
		db	 00h, 01h, 07h, 82h, 00h, 03h
		db	 01h, 00h, 38h, 82h, 00h, 01h
		db	 40h, 86h, 00h, 01h, 3Bh, 83h
		db	 00h, 05h, 20h, 00h, 35h, 00h
		db	 30h, 84h, 00h, 05h, 02h, 8Fh
		db	 20h, 00h, 02h, 87h, 00h, 01h
		db	 03h, 82h, 00h, 03h, 02h, 00h
		db	 38h, 82h, 00h, 01h, 80h, 86h
		db	 00h, 01h, 3Ah, 85h, 00h, 03h
		db	0A1h, 00h, 30h, 84h, 00h, 05h
		db	 06h, 9Bh,0A0h, 00h, 04h, 87h
		db	 00h, 02h, 01h, 80h, 83h, 00h
		db	 01h, 3Eh, 82h, 00h, 01h, 40h
		db	 86h, 00h, 01h, 3Bh, 84h, 00h
		db	 05h, 05h, 78h, 00h, 30h, 80h
		db	 83h, 00h, 0Bh, 06h,0A9h,0C0h
		db	 00h, 08h,0C0h, 14h,0C0h, 00h
		db	 0Eh, 80h, 82h, 00h, 0Eh, 06h
		db	0D4h, 00h, 70h, 01h,0B4h,0E0h
		db	 6Fh, 4Fh,0FAh, 00h, 6Fh, 00h
		db	 6Ch, 84h, 00h, 05h, 68h, 30h
		db	 03h,0E3h, 40h, 85h, 00h, 02h
		db	 69h, 8Eh, 82h, 00h, 06h,0C0h
		db	 28h,0D0h
data_6		db	0
		db	 07h, 40h, 82h, 00h, 0Eh, 07h
		db	 56h, 00h, 68h, 01h, 34h,0E0h
		db	 6Ch,0AAh,0A8h, 00h, 6Fh, 00h
		db	 68h, 84h, 00h, 04h, 68h, 20h
		db	 81h,0E1h, 86h, 00h, 1Ah, 6Bh
		db	 06h, 80h, 00h, 80h, 68h,0E0h
		db	 00h, 03h,0D0h, 00h, 10h, 03h
		db	 6Bh, 00h, 68h, 03h, 69h,0E0h
		db	 68h, 6Ah,0A0h, 00h, 6Eh, 00h
		db	 68h, 84h, 00h, 05h, 68h, 61h
		db	 3Bh, 81h, 80h, 85h, 00h, 07h
		db	 6Bh, 07h, 20h, 00h, 80h, 50h
		db	 68h, 82h, 00h, 19h,0E8h, 00h
		db	 60h, 03h, 37h, 80h, 74h, 00h
		db	0D1h,0E0h, 68h, 7Ah, 90h, 00h
		db	 6Eh, 00h, 68h, 00h, 03h, 80h
		db	 00h, 68h,0C2h, 61h,0C1h, 84h
		db	 00h, 05h, 40h, 80h, 6Ah, 03h
		db	0B0h, 82h, 00h, 02h,0D0h, 70h
		db	 82h, 00h, 19h, 74h, 80h, 70h
		db	 03h,0B5h, 80h, 68h, 15h, 23h
		db	0C0h, 6Bh, 1Fh, 80h, 00h, 6Ah
		db	 00h, 68h, 00h, 0Fh, 88h, 00h
		db	 68h,0C6h, 40h, 82h, 83h, 00h
		db	 06h, 02h,0E5h,0C0h, 6Eh, 01h
		db	0C8h, 82h, 00h, 02h,0D0h, 34h
		db	 82h, 00h, 0Bh, 3Bh, 20h, 60h
		db	 01h,0B5h,0C0h, 6Ah, 02h, 87h
		db	 80h, 6Bh, 83h, 00h, 14h, 6Ch
		db	 00h, 68h, 00h, 40h, 71h, 00h
		db	 68h,0C4h,0C1h, 80h, 00h, 03h
		db	0E3h, 07h, 4Eh, 80h, 6Ch, 00h
		db	0E8h, 82h, 00h, 02h,0C0h, 3Ah
		db	 82h, 00h, 0Bh, 1Dh, 90h, 70h
		db	 01h,0B5h,0C0h
data_7		dw	406Ch			; Data table (indexed access)
		db	 1Fh, 00h, 6Bh, 83h, 00h, 14h
		db	 6Ch, 00h, 68h, 08h, 00h, 0Ch
		db	 80h, 69h, 8Ch, 80h,0F8h, 00h
		db	 30h, 3Eh, 23h, 87h, 00h, 6Ch
		db	 00h, 70h, 82h, 00h, 02h,0D0h
		db	 1Dh, 82h, 00h, 0Bh, 0Eh,0A8h
		db	 68h, 01h,0B4h,0C0h, 6Eh,0A8h
		db	0FEh, 00h, 6Bh, 83h, 00h, 09h
		db	 68h, 00h, 68h, 10h, 03h, 86h
		db	 40h, 69h, 8Dh, 84h, 00h, 17h
		db	 01h,0C8h, 18h, 40h, 68h, 00h
		db	 1Ch, 00h, 10h, 00h, 60h, 77h
		db	 82h,0E0h, 70h, 01h, 0Eh, 40h
		db	 74h, 80h, 72h, 10h, 63h, 86h
		db	 00h, 1Fh, 3Bh,0DFh, 54h, 02h
		db	 7Fh,0D0h, 40h, 00h, 40h, 01h
		db	0C0h, 00h, 02h, 00h, 3Fh, 10h
		db	 00h, 3Fh, 80h, 20h, 08h, 18h
		db	 3Ah,0E7h, 40h, 60h, 02h, 87h
		db	0B0h, 3Ch,0E0h, 82h, 30h, 02h
		db	 31h, 80h, 85h, 00h, 07h, 43h
		db	0C3h,0FFh,0B6h, 00h,0F5h, 0Eh
		db	 82h, 80h, 02h, 18h, 60h, 83h
		db	 00h, 02h, 03h,0C4h, 83h, 00h
		db	 0Ch, 40h, 10h, 08h, 01h, 03h
		db	 80h, 40h, 06h, 83h, 18h, 0Eh
		db	0E6h, 82h, 18h, 02h, 21h, 80h
		db	 85h, 00h, 0Ch, 84h, 00h, 43h
		db	 86h, 00h, 3Eh,0AAh, 41h, 00h
		db	 0Eh, 30h, 02h, 83h, 00h, 01h
		db	0F3h, 83h, 00h, 05h,0C0h, 33h
		db	 00h, 1Ah, 10h, 82h, 00h, 09h
		db	 06h, 81h, 8Ch, 06h,0E0h, 04h
		db	 00h, 01h, 80h, 85h, 00h, 0Ch
		db	 2Dh, 02h, 83h, 06h, 2Ah, 87h
		db	0FEh, 03h, 08h,0E3h, 18h, 04h
		db	 83h, 00h, 02h, 39h, 80h, 82h
		db	 00h, 05h,0C4h, 30h,0E0h, 99h
		db	0C4h, 82h, 00h, 08h, 07h, 51h
		db	 86h, 06h, 66h, 63h, 80h, 41h
		db	 86h, 00h, 0Ch,0AFh, 05h, 03h
		db	 42h, 3Fh, 20h, 00h, 03h, 18h
		db	 71h, 18h
data_8		db	8			; Data table (indexed access)
		db	 83h, 00h, 02h, 1Ch,0C0h, 82h
		db	 00h, 05h,0D4h, 18h, 08h, 10h
		db	0F9h, 82h, 00h, 0Ah, 03h,0ACh
		db	0C6h, 06h, 60h, 00h, 7Eh, 03h
		db	 00h, 1Eh, 84h, 00h, 0Ah, 50h
		db	 02h, 03h, 4Fh, 00h,0F2h, 00h
		db	 01h, 80h, 31h, 82h, 18h, 83h
		db	 00h, 16h, 0Eh, 60h, 04h, 00h
		db	0D3h, 0Ch, 10h, 00h, 1Eh, 40h
		db	 00h, 01h,0D7h,0C6h, 06h, 7Fh
		db	0E0h, 00h, 02h, 00h,0F8h,0C0h
		db	 83h, 00h, 06h,0A8h, 08h, 00h
		db	 43h, 40h, 0Eh, 82h, 00h, 02h
		db	0E0h, 20h, 82h, 10h, 14h, 00h
		db	 06h, 00h, 06h, 30h, 08h, 00h
		db	0E8h, 83h,0A0h, 41h, 87h, 40h
		db	 00h, 06h, 7Ah,0BCh, 86h, 00h
		db	 03h, 82h, 00h, 08h, 04h, 07h
		db	 20h, 7Fh,0F0h, 80h,0F5h, 50h
		db	 82h, 03h, 02h, 89h,0A0h, 84h
		db	 00h, 0Eh, 20h, 30h, 00h, 1Ch
		db	 40h, 07h, 30h, 10h, 00h, 13h
		db	 01h,0D3h, 7Fh,0F0h, 85h, 00h
		db	 11h, 30h, 01h, 03h, 20h, 03h
		db	 18h, 34h, 00h, 28h, 68h, 3Ah
		db	 20h, 00h, 02h,0AAh,0F4h, 18h
		db	 82h, 00h, 05h, 0Fh,0F8h, 00h
		db	 04h, 40h, 86h, 00h, 1Bh, 83h
		db	 00h,0EAh, 60h, 07h,0C0h, 01h
		db	0C0h, 80h, 00h, 38h, 02h, 1Ch
		db	 90h, 03h, 18h, 2Ch, 00h, 50h
		db	 75h, 9Eh,0E0h, 00h, 55h,0FCh
		db	 3Fh,0D0h, 85h, 00h, 01h, 08h
		db	 87h, 00h, 08h, 02h, 00h, 7Ah
		db	 8Eh, 80h, 3Fh,0F8h, 04h, 82h
		db	 00h, 0Eh, 18h, 02h, 0Ch, 50h
		db	 03h, 18h, 6Ch, 00h, 40h, 3Bh
		db	 10h, 80h, 11h, 78h, 82h, 00h
		db	 02h,0FEh, 80h, 84h, 00h, 01h
		db	 10h, 87h, 00h, 05h, 06h, 02h
		db	 1Fh,0AAh, 80h, 82h, 00h, 01h
		db	 60h, 82h, 00h, 0Dh, 1Ch, 01h
		db	0C0h, 50h, 03h, 18h, 66h, 03h
		db	 00h, 1Eh,0A9h, 00h, 22h, 83h
		db	 00h, 02h, 07h,0E8h, 8Ch, 00h
		db	 82h, 04h, 02h, 01h,0FFh, 82h
		db	 00h, 01h, 0Eh, 83h, 00h, 0Dh
		db	 0Eh, 00h,0F0h, 40h, 03h, 18h
		db	 70h,0F8h, 00h, 07h,0FEh, 00h
		db	 40h, 84h, 00h, 01h, 7Dh, 84h
		db	 00h, 01h, 08h, 87h, 00h, 04h
		db	 0Ch, 2Ch, 02h, 80h, 82h, 00h
		db	 05h,0C0h, 07h,0F0h, 00h, 07h
		db	 82h, 00h, 05h, 80h, 03h, 10h
		db	 3Ch, 02h, 84h, 00h, 01h,0C0h
		db	 84h, 00h, 02h, 0Fh,0C8h, 83h
		db	 00h, 01h,0C0h, 87h, 00h, 04h
		db	 08h, 6Ch, 14h,0F0h, 83h, 00h
		db	 05h, 02h,0E3h,0C0h, 03h,0C0h
		db	 82h, 00h, 04h, 02h, 20h, 0Fh
		db	0F0h, 84h, 00h, 01h, 80h, 85h
		db	 00h, 04h, 7Fh,0A0h, 00h, 3Ch
		db	 88h, 00h, 04h, 10h, 64h, 34h
		db	 70h, 82h, 00h, 0Ah, 15h, 55h
		db	 54h, 07h, 00h,0F8h, 01h, 00h
		db	 06h, 20h, 8Ch, 00h, 01h, 01h
		db	 82h,0FFh,0A0h, 00h, 02h, 0Ah
		db	0C0h, 82h, 00h, 02h, 60h, 2Eh
		db	 86h, 00h, 05h, 1Fh,0FAh,0A8h
		db	 00h, 2Fh, 97h, 00h, 02h, 10h
		db	 78h, 82h, 00h, 02h, 60h, 5Ch
		db	 85h, 00h, 03h, 01h,0F5h, 40h
		db	 82h, 00h, 01h, 01h, 97h, 00h
		db	 02h, 10h, 1Eh, 82h, 00h, 02h
		db	 60h,0BCh, 85h, 00h, 02h, 1Fh
		db	 40h, 8Ch, 00h, 02h, 01h, 2Fh
		db	 83h,0FFh, 01h, 80h, 84h, 00h
		db	 03h, 7Fh,0FFh,0E0h, 82h, 00h
		db	 06h, 18h, 07h, 80h, 00h,0E0h
		db	0BCh, 84h, 00h, 02h, 07h,0E0h
		db	 86h, 00h, 01h, 0Fh, 82h,0FFh
		db	 01h,0FEh, 85h, 00h, 04h, 5Fh
		db	 80h, 00h, 7Eh, 83h, 00h, 0Ch
		db	 7Fh, 80h, 00h, 1Fh, 80h, 00h
		db	 0Ch, 01h,0C0h, 01h,0C0h,0BEh
		db	 83h
data_9		dw	200h			; Data table (indexed access)
		db	 01h,0F8h, 87h, 00h, 01h, 02h
		db	 82h, 00h, 01h,0B0h, 86h, 00h
		db	 07h,0F8h, 1Fh, 01h,0E0h, 00h
		db	 1Fh, 80h, 83h, 00h, 0Ch, 78h
		db	 00h, 07h, 00h,0E0h, 07h, 80h
		db	 5Fh, 80h, 00h, 01h,0FEh, 89h
		db	 00h, 07h, 80h, 02h,0C0h, 00h
		db	 7Fh,0FFh,0C0h, 82h, 00h, 06h
		db	 0Eh, 63h,0C0h, 18h, 00h,0F8h
		db	 82h, 00h, 0Dh, 03h,0FCh, 06h
		db	 00h, 01h,0C0h, 70h, 1Eh, 00h
		db	 17h
loc_1:
		cli				; Disable interrupts
;*		add	si,di
		db	 01h,0FEh		;  Fixup - byte match
		mov	al,[bx+si]
		pop	es
		inc	ax
		or	ax,[bx+si]
		jg	loc_1			; Jump if >
		push	bp
		cld				; Clear direction
;*		add	byte ptr [bx+si],6
		db	 82h, 00h, 06h		;  Fixup - byte match
;*		add	cx,si
		db	 01h,0F1h		;  Fixup - byte match
		loopnz	$+8			; Loop if zf=0, cx>0

		pop	es
		add	byte ptr ss:data_13e[bp+si],1Ch
		add	ax,[bx+di]
		add	byte ptr [bx+si],7Ch	; '|'
;*		cmp	ax,si
		db	 39h,0F0h		;  Fixup - byte match
		add	[bp+si],al
		db	0FFh,0FEh, 89h, 00h, 01h, 80h
		db	 82h, 00h, 09h, 71h,0E0h, 01h
		db	 1Eh, 00h, 60h, 01h, 80h,0C0h
		db	 82h, 00h, 02h, 07h,0FFh, 83h
		db	 00h, 09h, 07h, 80h, 78h, 05h
		db	 60h, 1Fh,0E0h, 05h, 80h, 83h
		db	 00h, 04h, 70h, 0Eh, 39h, 80h
		db	 84h, 00h, 02h,0A8h,0E0h, 82h
		db	 00h, 09h, 07h,0C0h, 00h,0F8h
		db	 00h,0C0h, 71h, 80h, 60h, 88h
		db	 00h, 0Eh, 7Fh, 80h, 04h,0BFh
		db	0FFh,0C0h, 05h, 83h,0FFh, 00h
		db	 01h,0C0h, 07h, 83h, 86h, 00h
		db	 01h, 1Ch, 82h, 00h, 01h, 1Fh
		db	 82h, 00h, 07h, 60h, 01h, 80h
		db	0C3h, 00h, 60h, 04h, 82h, 00h
		db	 01h, 18h, 86h, 00h, 0Ch, 05h
		db	 57h,0FDh, 00h, 01h, 9Eh, 17h
		db	0C0h, 03h, 00h, 01h,0FCh, 86h
		db	 00h, 04h, 03h,0C0h, 01h,0F8h
		db	 82h, 00h, 07h, 20h, 01h, 80h
		db	 7Ch, 00h, 60h, 04h, 82h, 00h
		db	 01h, 18h, 86h, 00h, 09h, 01h
		db	 82h,0B0h, 00h, 01h,0E0h, 0Bh
		db	0E0h, 06h, 85h, 00h, 02h, 2Fh
		db	 80h, 83h
data_10		db	0			; Data table (indexed access)
		db	 02h, 12h,0FFh, 84h, 00h, 02h
		db	 01h, 80h, 82h, 00h, 02h, 60h
		db	 06h, 82h, 00h, 01h, 18h, 86h
		db	 00h, 02h, 01h, 80h, 84h, 00h
		db	 03h, 05h,0E0h, 0Ch, 85h, 00h
		db	 02h,0BFh,0E0h, 8Ah, 00h, 01h
		db	0C0h, 82h, 00h, 02h,0C0h, 06h
		db	 82h, 00h, 01h, 38h, 86h, 00h
		db	 02h, 05h, 80h, 84h, 00h, 03h
		db	 0Bh,0C0h, 0Ch, 84h, 00h, 05h
		db	 01h, 70h,0E0h, 00h, 01h, 88h
		db	 00h, 05h, 60h, 00h, 01h, 80h
		db	 07h, 82h, 00h, 01h, 70h, 86h
		db	 00h, 02h, 05h, 80h, 84h, 00h
		db	 04h, 5Eh, 00h, 0Ch, 3Eh, 83h
		db	 00h, 05h, 01h, 7Ch, 70h, 00h
		db	 03h, 88h, 00h, 08h, 18h, 00h
		db	 06h, 00h, 05h, 80h, 01h,0F0h
		db	 86h, 00h, 02h, 05h, 80h, 83h
		db	 00h, 05h, 0Ah, 80h, 00h, 0Ch
		db	 79h, 83h, 00h, 0Bh, 01h, 5Ch
		db	 30h, 00h, 06h, 30h, 0Eh, 38h
		db	 00h, 01h, 70h, 82h, 00h, 0Fh
		db	 01h, 2Fh, 00h, 0Eh, 00h, 4Bh
		db	0F8h, 10h,0BFh,0FDh,0C0h, 17h
		db	 80h, 17h, 80h, 83h, 00h, 05h
		db	 17h, 8Ch, 3Fh,0F0h, 40h, 85h
		db	 00h, 07h, 16h, 61h,0C0h, 00h
		db	 30h, 1Ch, 2Ch, 82h, 00h, 01h
		db	0BCh, 83h, 00h, 0Eh,0AFh, 80h
		db	 17h, 00h,0CBh,0F8h, 13h, 57h
		db	0F7h, 00h, 17h, 80h, 17h, 80h
		db	 83h, 00h, 05h, 17h, 9Ch, 7Fh
		db	0F8h, 60h, 85h, 00h, 05h, 14h
		db	0C1h, 60h, 00h, 60h, 82h, 1Ch
		db	 82h, 00h, 12h, 2Fh, 00h, 08h
		db	 00h, 97h,0C0h, 17h, 80h, 97h
		db	0F8h, 17h, 95h, 5Ch, 00h, 17h
		db	 80h, 17h, 80h, 83h, 00h, 05h
		db	 17h, 98h,0FCh, 78h, 60h, 85h
		db	 00h, 07h, 14h,0C0h,0E0h, 00h
		db	 60h, 38h, 16h, 82h, 00h, 1Ah
		db	 17h,0C0h, 18h
data_11		dw	0CB00h, 0BE0h		; Data table (indexed access)
		db	0C3h, 2Fh,0F8h, 17h, 85h, 60h
		db	 00h, 17h, 80h, 17h, 80h, 1Fh
		db	0E0h, 00h

locloop_2:
		pop	ss
;*		cmp	ax,si
		db	 39h,0F0h		;  Fixup - byte match
;*		xor	al,al			; Zero register
		db	 30h,0C0h		;  Fixup - byte match
		add	word ptr [bx+si],9
		mov	ax,ds:data_14e
;*		adc	byte ptr [bx+si+0],0C0h
		db	 80h, 50h, 00h,0C0h	;  Fixup - byte match
		db	 38h, 0Eh, 82h, 00h, 0Ch, 0Bh
		db	0E0h, 08h, 00h, 4Bh,0F0h, 17h
		db	0EAh,0DFh,0F8h, 17h, 80h, 82h
		db	 00h, 18h, 17h, 80h, 17h, 80h
		db	0F0h, 1Ch, 00h, 17h, 31h,0E0h
		db	 61h, 80h, 07h,0F8h, 01h, 52h
		db	0A0h, 11h, 80h, 38h, 00h, 80h
		db	 38h, 0Bh, 82h, 00h, 0Ch, 04h
		db	0F8h, 1Ch, 00h, 4Bh,0F0h, 15h
		db	0FDh, 7Fh,0F0h, 17h, 80h, 82h
		db	 00h, 14h, 17h, 80h, 17h, 83h
		db	 80h, 03h, 00h, 17h, 33h,0E0h
		db	 3Eh, 00h, 7Ch, 0Fh, 80h,0A1h
		db	 40h, 13h, 00h, 14h, 82h, 00h
		db	 0Bh, 38h, 05h, 80h, 00h, 02h
		db	 7Ch, 0Ch, 00h, 4Bh,0F8h, 13h
		db	 82h,0FFh, 03h,0F0h, 17h, 80h
		db	 82h, 00h, 0Fh, 17h, 80h, 17h
		db	 87h, 00h, 01h, 80h, 16h, 63h
		db	0C0h, 00h, 01h,0C0h, 00h, 70h
		db	 82h, 00h, 03h, 13h, 00h, 06h
		db	 82h, 00h, 10h, 38h, 02h,0E0h
		db	 00h, 01h, 5Eh, 16h, 00h, 4Bh
		db	0F8h, 11h, 7Fh,0FFh,0E0h, 17h
		db	 80h, 82h, 00h, 05h, 17h, 80h
		db	 17h, 8Eh, 0Fh, 82h,0C0h, 1Ah
		db	 16h, 62h,0C0h, 00h, 07h, 00h
		db	 78h, 1Ch, 78h,0A0h, 16h, 00h
		db	 63h, 30h, 0Ch, 03h, 86h, 0Eh
		db	 79h, 50h, 0Ch, 00h,0C1h, 8Ch
		db	 0Bh, 98h, 83h, 0Ch, 01h, 60h
		db	 85h, 00h, 0Dh, 7Fh,0E0h,0ABh
		db	0FDh, 80h, 2Fh,0E0h, 3Ch, 30h
		db	 00h, 18h, 00h, 3Ch, 82h, 00h
		db	 01h,0F8h, 83h, 00h, 10h, 18h
		db	 06h, 03h, 07h, 00h,0A0h, 10h
		db	 01h, 40h, 46h, 03h, 99h, 86h
		db	 06h
data_12		dw	600Ch			; Data table (indexed access)
		db	 85h, 00h, 0Dh,0FFh,0E0h, 00h
		db	 41h, 80h, 0Ah,0FFh,0F0h, 60h
		db	0FCh, 0Ch, 00h,0F0h, 82h, 00h
		db	 01h, 3Eh, 82h, 00h, 06h, 03h
		db	 38h, 0Ch,0C6h, 1Fh,0C0h, 82h
		db	 00h, 09h, 01h, 60h, 63h, 01h
		db	 98h, 03h, 00h, 18h, 60h, 85h
		db	 00h, 0Dh, 7Bh,0E0h,0A0h, 41h
		db	 80h, 01h, 55h, 80h,0C3h,0FFh
		db	 06h, 01h,0C0h, 82h, 00h, 09h
		db	 0Fh, 80h, 00h, 1Ch, 38h, 0Ch
		db	 38h,0E7h,0F8h, 82h, 00h, 09h
		db	 01h, 70h, 21h, 01h, 99h, 98h
		db	0E0h, 70h, 60h, 85h, 00h, 06h
		db	0F2h,0C1h, 40h,0C1h,0D5h, 40h
		db	 82h, 00h, 05h,0C7h, 1Fh, 86h
		db	 03h, 80h, 82h, 00h, 09h, 07h
		db	0C0h, 00h, 70h, 3Ch, 06h, 03h
		db	 06h, 3Eh, 83h, 00h, 08h,0B8h
		db	 31h, 81h, 98h, 00h, 1Fh, 80h
		db	0C0h, 85h, 00h, 06h, 70h, 02h
		db	 80h,0DDh,0C0h, 1Ch, 82h, 00h
		db	 04h, 66h, 0Fh, 86h, 07h, 83h
		db	 00h, 0Ah, 03h,0E0h, 01h,0C0h
		db	 2Eh, 03h, 06h, 0Ch, 07h, 80h
		db	 82h, 00h, 05h, 5Eh, 30h, 81h
		db	 9Fh,0F8h, 82h, 00h, 02h,0C0h
		db	0FEh, 84h, 00h, 0Ch,0B8h, 1Dh
		db	 00h,0F0h,0E0h, 01h, 80h, 00h
		db	 38h, 0Fh, 86h, 07h, 83h, 00h
		db	 0Ah, 01h,0F0h, 03h, 80h, 2Fh
		db	 80h,0ECh, 71h,0E1h,0C0h, 82h
		db	 00h, 04h, 2Fh,0F0h,0C1h, 80h
		db	 82h, 00h, 0Eh, 01h, 87h, 01h
		db	0C0h, 7Fh,0FCh, 00h, 57h,0F4h
		db	 03h,0C0h,0B0h, 00h, 60h, 82h
		db	 00h, 15h, 1Fh, 0Ch, 0Eh, 00h
		db	 1Fh, 00h, 01h,0F8h, 07h, 00h
		db	 17h, 80h, 1Fh, 86h, 18h,0C0h
		db	 00h, 1Fh, 85h, 7Fh, 41h, 82h
		db	0FFh, 0Fh, 80h, 07h, 18h, 00h
		db	 70h, 80h, 0Fh,0C0h, 0Ah,0A0h
		db	 1Ch,0C0h, 7Ch, 5Fh,0FCh, 82h
		db	 00h, 25h,0FCh, 18h, 0Eh, 00h
		db	 60h,0C0h, 00h,0F8h, 0Eh, 00h
		db	0E0h,0C0h, 2Fh, 80h, 03h,0F0h
		db	 0Fh,0F0h,0E0h, 00h, 0Eh, 00h
		db	 80h, 20h, 00h,0FCh, 0Eh, 00h
		db	 1Ch, 17h, 05h,0F8h, 01h,0FDh
		db	 55h, 0Bh,0FCh, 85h, 00h, 02h
		db	 03h,0E0h, 87h, 00h, 07h,0C1h
		db	 15h,0F0h, 38h, 0Fh,0FEh, 07h
		db	 82h, 00h, 0Eh, 07h, 00h, 9Ch
		db	 10h, 00h,0FCh, 1Eh, 00h, 38h
		db	 0Bh,0C1h, 70h, 07h,0AAh, 82h
		db	 00h, 02h, 2Fh,0C0h, 84h, 00h
		db	 02h, 07h,0C0h, 86h, 00h, 05h
		db	 01h, 83h, 85h, 7Fh,0F0h, 82h
		db	 00h, 01h, 78h, 82h, 00h, 0Eh
		db	 07h, 00h, 7Eh, 10h, 00h,0FCh
		db	 1Eh, 00h,0F0h, 04h,0FFh,0E0h
		db	 0Eh, 80h, 82h, 00h, 02h, 01h
		db	 78h, 84h, 00h, 02h, 0Fh, 80h
		db	 86h, 00h, 08h, 01h, 85h, 00h
		db	 55h, 40h, 00h, 0Fh, 80h, 82h
		db	 00h, 0Dh, 03h, 80h, 3Ch, 10h
		db	 00h,0FCh, 1Fh, 07h,0E0h, 01h
		db	56h

locloop_3:
		sbb	byte ptr [si],84h
		add	[bx+di],al
		pop	ss
		test	al,[bx+si]
		add	data_3,di
		add	al,[bp+di]
		or	ax,data_5[si]
                           lock	add	word ptr [bx+si],9
;*		add	ax,ax
		db	 01h,0C0h		;  Fixup - byte match
		add	[bx+si],dh
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		inc	data_1[bx+si]
		add	[bx+si],si
		test	al,[bx+si]
		add	al,[bp+si]
;*                         lock	add	byte ptr [bx+si],2
		db	0F0h, 82h, 00h, 02h	;  Fixup - byte match
;*		add	ax,si
		db	 01h,0F0h		;  Fixup - byte match
		xchg	[bx+si],ax
		or	[bp+di],ax
		push	ds
		add	ax,0E0h
		pop	es
		add	[bx-8],bh
;*		add	byte ptr [bx+si],7
		db	 82h, 00h, 07h		;  Fixup - byte match
;*                         lock	add	[bx+si+0],ah
		db	0F0h, 00h, 60h, 00h	;  Fixup - byte match
		db	0F8h, 03h,0FCh, 84h, 00h, 01h
		db	 20h, 85h, 00h, 04h, 17h, 80h
		db	 00h, 3Fh, 88h, 00h, 06h, 06h
		db	 16h, 0Bh,0F8h, 00h, 1Ch, 83h
		db	0FFh, 07h,0E0h, 00h, 3Eh, 01h
		db	0C0h, 01h,0F8h, 8Dh, 00h, 03h
		db	 5Fh,0FFh,0C0h, 88h, 00h, 10h
		db	 0Eh, 1Eh, 0Bh,0F8h, 00h, 7Fh
		db	0EAh,0AAh,0ABh,0FFh, 00h, 03h
		db	0FEh, 00h, 01h,0F0h, 98h, 00h
		db	0FFh,0FFh

zr1_30		endp

seg_a		ends



		end	start
