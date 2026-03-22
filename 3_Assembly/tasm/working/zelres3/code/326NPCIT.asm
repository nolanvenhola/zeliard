
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR3_26	                                 лл
;лл					                                 лл
;лл      Created:   16-Feb-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_3e		equ	0CCCEh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_26		proc	far

start:
		stosb				; Store al to es:[di]
		adc	[bx+si],ax
		add	ss:data_3e[bp+di],ah
		add	[bx+di-33h],dh
		jns	$-31h			; Jump if not sign
		jnp	$-31h			; Jump if not parity
		test	cl,ch
		db	 2Eh,0CEh, 91h,0CEh,0A8h,0CEh
		db	 03h,0BCh, 00h, 15h, 0Ah, 00h
		db	 00h, 71h,0CDh, 34h, 0Fh,0D2h
		db	0D3h, 08h, 0Fh, 0Ah, 0Fh,0D2h
		db	0D3h, 1Bh, 0Fh,0D2h,0D3h, 14h
		db	 0Fh, 3Fh, 10h, 1Ah, 11h,0D8h
		db	 08h, 11h,0D8h, 0Eh, 11h,0D8h
		db	 09h, 11h, 9Bh,0D9h, 02h, 15h
		db	 86h,0D9h, 01h, 15h, 8Dh,0D9h
		db	 02h, 15h, 87h, 9Bh, 03h, 15h
		db	0CCh, 85h, 02h, 15h, 8Dh, 03h
		db	 15h, 87h, 9Bh, 03h, 15h, 86h
		db	 02h, 15h,0CCh, 8Ch,0C8h, 02h
		db	 15h, 87h, 9Bh, 03h, 15h, 86h
		db	0C4h, 01h, 15h, 8Dh,0C4h, 02h
		db	 15h,0CCh, 86h,0C8h, 8Ah,0C9h
		db	 8Fh,0C3h, 02h, 15h, 86h,0C4h
		db	 01h, 15h, 8Dh,0C4h,0C8h,0D5h
		db	0DAh, 87h,0C4h,0C8h, 89h,0C4h
		db	0C8h, 8Eh,0C4h,0C8h, 01h, 15h
		db	0CCh, 85h,0C4h,0CAh,0D5h, 8Dh
		db	 43h,0D5h, 88h, 43h, 89h, 43h
		db	 8Eh, 43h,0C8h,0D5h, 86h,0C4h
		db	 01h, 15h, 8Dh, 43h,0C8h, 88h
		db	 43h, 89h, 43h,0C8h, 8Dh,0C4h
		db	0C9h,0C4h,0C8h, 86h, 43h,0C8h
		db	 8Dh, 43h,0CAh, 88h, 43h,0C8h
		db	 88h, 43h,0C8h, 8Dh, 43h,0CAh
		db	0D5h, 86h, 43h,0CAh, 8Dh, 43h
		db	0D5h, 88h, 53h, 88h,0C9h, 43h
		db	 8Dh, 43h, 01h, 15h, 86h, 43h
		db	0D5h, 8Dh, 43h,0C8h,0CCh, 86h
		db	0C3h, 53h, 88h, 43h,0C5h, 4Ah
		db	 8Bh, 43h,0C8h,0DAh, 86h, 43h
		db	0C8h, 8Dh,0C9h, 43h, 87h,0C4h
		db	 53h, 88h,0C4h,0C5h,0C4h,0CAh
		db	 8Ch, 53h, 87h,0C9h, 43h, 8Dh
		db	 53h,0C8h, 86h,0C4h,0C9h,0C4h
		db	0CAh, 88h, 53h, 5Ah, 8Ah,0C9h
		db	0C4h,0C5h, 4Ah, 85h,0C4h,0C9h
		db	 43h,0CAh, 8Bh,0C4h,0C9h, 43h
		db	 86h,0C4h,0C4h,0C5h, 4Ah, 87h
		db	0C9h, 44h,0C4h,0C8h, 8Bh, 53h
		db	0C8h, 86h, 53h,0CAh, 8Ch, 53h
		db	0CAh, 86h,0C4h, 43h,0C8h, 88h
		db	 53h,0C5h,0CAh, 8Bh,0C4h,0C6h
		db	0C4h,0CAh, 86h, 43h,0CAh, 8Dh
		db	 43h,0CAh,0CCh, 86h,0C4h, 53h
		db	0C8h, 7Ch, 82h, 43h,0C5h,0C4h
		db	 4Ah, 8Ah, 43h,0CAh, 87h,0C4h
		db	 44h,0CBh, 8Ch,0C4h,0CAh,0D5h
		db	 87h
data_1		dw	63C4h			; Data table (indexed access)
		db	 7Dh, 82h, 63h,0C8h, 8Bh,0C4h
		db	0CAh,0D5h, 86h,0C6h, 43h,0C8h
		db	 8Dh,0C4h, 01h, 15h, 87h,0C6h
		db	 73h, 05h, 0Fh,0C4h,0C6h,0C4h
		db	 49h, 8Bh,0C4h, 01h, 15h, 86h
		db	 63h,0CAh, 8Ch, 43h,0C8h, 87h
		db	0C9h, 73h, 05h, 0Fh, 43h,0C5h
		db	 4Ah, 8Bh, 43h,0C8h, 86h, 53h
		db	0CAh, 8Dh, 43h, 44h, 4Ah, 84h
		db	0C4h,0C4h,0C6h, 53h, 05h, 10h
		db	 63h, 8Ch, 53h,0C8h,0CAh, 84h
		db	 43h, 01h, 15h, 8Dh, 53h,0CAh
		db	 86h,0C4h, 63h, 06h, 11h, 63h
		db	 8Ch,0C4h,0C6h,0C4h,0CAh, 85h
		db	0C9h,0C4h,0C8h,0DAh, 8Dh,0C4h
		db	0CAh,0D5h, 87h,0C4h, 53h,0CAh
		db	 87h,0C9h, 43h,0CAh, 8Ch, 43h
		db	0D5h, 86h, 43h, 44h, 4Ah, 8Bh
		db	0C4h, 01h, 15h, 87h,0C4h, 53h
		db	 88h,0C4h,0C9h,0C4h, 84h,0C3h
		db	 88h, 53h,0C8h, 85h, 43h,0C6h
		db	 43h, 8Ch, 43h,0D5h, 87h,0C4h
		db	0C9h,0C4h,0CAh, 88h, 53h, 84h
		db	0C4h, 88h,0C9h, 43h,0CAh, 85h
		db	 73h,0CAh, 8Bh, 53h,0CAh, 86h
		db	0C4h, 43h, 4Ah, 87h, 43h,0CAh
		db	 84h,0C4h,0C8h, 87h,0C4h,0C9h
		db	0DAh, 86h, 53h,0CAh, 8Dh, 43h
		db	0CAh, 87h,0C4h, 43h,0C8h, 88h
		db	0C9h,0C4h, 85h, 43h, 87h, 43h
		db	0C8h, 86h, 43h,0CAh, 8Eh,0C4h
		db	0CAh,0DAh, 87h,0C6h,0C4h, 44h
		db	 4Ah, 86h, 43h, 85h, 43h,0CAh
		db	 86h, 43h,0CAh, 86h,0C9h,0C4h
		db	 61h, 60h,0C2h,0C1h,0C2h, 50h
		db	 81h, 43h, 89h, 43h,0CAh, 88h
		db	0C4h,0CAh, 85h,0C9h,0C4h,0D4h
		db	 86h,0C4h,0CAh, 87h, 43h, 8Fh
		db	0C9h,0C4h,0C8h, 88h,0C4h,0CAh
		db	 89h,0C4h, 86h, 53h, 86h,0C4h
		db	 88h, 43h,0CAh, 84h,0C3h, 89h
		db	0C6h, 43h, 88h,0CAh, 8Ah,0CAh
		db	 86h, 53h,0C8h, 85h,0CAh, 88h
		db	 43h, 85h,0C4h, 89h, 53h,0C8h
		db	 87h, 92h,0C4h,0C6h, 43h, 8Eh
		db	0C4h,0CAh, 85h,0C4h, 89h,0C4h
		db	0C6h, 44h, 4Ah, 85h, 06h, 01h
		db	0C2h, 50h, 41h, 50h, 82h, 63h
		db	 51h, 50h,0C2h, 40h,0C2h, 40h
		db	 82h,0C4h, 86h,0C4h, 89h,0C9h
		db	 53h, 49h, 41h, 40h,0C2h, 92h
		db	 53h, 8Fh,0C9h, 85h,0C3h,0C4h
		db	 4Ah, 87h,0C4h,0D4h,0C9h,0CBh
		db	 87h,0C4h, 91h, 43h,0D5h, 8Fh
		db	0C9h, 85h, 43h, 89h, 43h,0CAh
		db	 88h, 43h, 90h,0C4h, 01h, 15h
		db	 8Fh,0C9h, 85h, 43h, 89h, 43h
		db	 89h, 43h, 90h,0C4h,0C8h,0D5h
		db	 8Fh,0CAh, 84h,0C3h, 43h,0CAh
		db	 88h, 43h,0D4h, 88h, 43h, 90h
		db	 43h,0C8h, 94h, 43h,0D5h, 89h
		db	 43h,0D5h, 88h, 53h, 8Fh,0C9h
		db	 43h,0C8h, 93h,0C4h,0C9h,0C4h
		db	0C8h, 88h, 43h,0D5h, 88h, 53h
		db	 8Fh, 43h,0C9h,0C4h, 93h, 63h
		db	0CAh, 87h, 43h,0D5h,0C8h, 87h
		db	 63h, 8Eh, 63h, 49h, 41h, 60h
		db	0C2h, 70h,0C2h, 50h, 81h, 43h
		db	0C9h,0C4h, 88h,0C6h,0C4h,0D5h
		db	0C6h, 87h, 63h, 8Eh, 43h,0CAh
		db	 94h,0C9h, 43h,0CAh, 88h, 43h
		db	0D5h,0C4h, 87h, 73h, 8Dh, 43h
		db	 47h, 8Bh,0C4h, 87h, 43h,0CAh
		db	 89h, 63h, 87h, 73h, 8Dh, 43h
		db	0CAh,0D4h, 8Bh,0C4h, 87h,0C4h
		db	0CAh,0D5h, 89h,0C4h,0C6h,0C4h
		db	0D5h,0D4h, 86h, 73h, 8Dh, 43h
		db	 01h, 15h, 8Ah,0C6h,0C4h, 87h
		db	0C4h, 01h, 15h,0CCh, 88h, 53h
		db	 01h, 15h, 86h, 73h, 8Dh, 43h
		db	0C8h,0D5h, 8Ah, 43h, 87h,0C4h
		db	0C8h,0D5h, 89h, 43h, 02h, 15h
		db	 86h, 73h, 8Dh, 53h,0C8h, 8Ah
		db	 43h, 87h, 43h,0C8h, 89h, 43h
		db	 02h, 15h, 86h, 63h, 8Eh, 63h
		db	0C8h, 89h, 43h, 87h, 53h,0C8h
		db	 88h, 43h,0C8h, 01h, 15h, 86h
		db	 63h, 8Eh,0C4h,0C9h,0C4h, 44h
		db	 4Ah, 87h, 43h,0C8h, 86h,0C4h
		db	0C9h,0C4h,0CBh, 88h, 53h, 01h
		db	 15h, 86h, 63h, 8Eh, 53h,0CAh
		db	 8Ah,0C4h,0C9h,0C4h, 86h, 53h
		db	0CAh, 88h,0C6h,0C4h,0C9h,0C8h
		db	0D5h, 86h, 53h,0D5h, 8Eh, 43h
		db	0CAh,0D5h, 8Ah,0C4h,0C6h,0C4h
		db	0CAh, 85h, 53h, 89h, 53h,0CAh
		db	0D5h, 86h, 53h,0D5h, 8Eh, 43h
		db	 01h, 15h, 8Ah,0C9h,0C4h,0CAh
		db	 86h, 43h,0C5h, 4Ah, 87h, 43h
		db	0CAh, 01h, 15h, 86h, 53h,0D5h
		db	 8Eh,0C9h,0C4h, 01h, 15h, 8Ah
		db	 43h, 87h,0C9h, 43h,0CAh, 88h
		db	 43h, 02h, 15h, 86h, 53h,0D5h
		db	 8Eh,0C4h,0CAh, 01h, 15h, 8Ah
		db	 43h,0CAh, 86h, 43h,0CAh, 89h
		db	0C4h,0C9h, 02h, 15h, 86h, 53h
		db	0D5h, 8Eh,0C4h, 02h, 15h, 8Ah
		db	0C4h,0CAh, 87h, 43h,0D5h, 89h
		db	 53h, 01h, 15h, 86h, 53h,0D5h
		db	 8Eh,0C4h, 02h, 15h, 8Ah,0C4h
		db	0D5h, 87h,0C4h,0CAh,0D5h, 89h
		db	 53h,0CAh,0D5h, 86h, 43h, 01h
		db	 15h, 8Eh,0C4h, 02h, 15h, 8Ah
		db	0C4h,0D5h, 87h,0C4h, 01h, 15h
		db	 89h, 43h, 54h,0CBh, 85h, 43h
		db	 01h, 15h, 8Eh,0C6h, 02h, 15h
		db	 8Ah,0CAh,0D5h,0CCh, 86h,0C4h
		db	 01h, 15h, 89h,0C4h,0D5h,0CAh
		db	 01h, 15h, 86h,0C4h, 02h, 15h
		db	 8Eh, 03h, 15h, 8Ah, 01h, 15h
		db	 87h,0CAh, 01h, 15h, 89h,0C4h
		db	 03h, 15h, 86h,0C4h, 02h, 15h
		db	 8Eh, 03h, 15h, 8Ah, 01h, 15h
		db	 87h, 02h, 15h,0CCh, 88h,0CAh
		db	 03h, 15h, 86h, 81h, 02h, 15h
		db	 8Eh, 03h, 15h, 8Ah, 01h, 15h
		db	 87h, 02h, 15h, 89h, 04h, 15h
		db	 86h, 81h,0D6h, 01h, 15h, 8Eh
		db	0D6h, 02h, 15h, 8Ah,0D6h,0D5h
		db	 87h,0D6h, 01h, 15h, 89h,0D6h
		db	 03h, 15h, 86h,0CDh,0D7h, 0Fh
		db	 0Dh,0D7h, 0Ch, 0Dh,0D7h, 07h
		db	 0Dh,0D7h, 08h, 0Dh, 82h,0D7h
		db	 08h, 0Dh,0D1h,0D0h, 31h, 0Eh
		db	 82h, 0Ah, 0Eh, 16h, 0Fh,0D2h
		db	0D3h, 26h, 0Fh, 3Fh, 0Fh, 07h
		db	 0Fh,0D2h,0D3h, 24h, 0Fh,0D2h
		db	0D3h, 0Eh, 0Fh, 3Fh, 10h, 09h
		db	 11h,0D8h, 0Fh, 11h,0D8h, 16h
		db	 11h,0D8h, 0Bh, 11h, 8Ah,0D9h
		db	 02h, 15h, 8Dh,0D9h, 03h, 15h
		db	 93h,0D9h, 01h, 15h, 8Ah, 8Ah
		db	 03h, 15h, 8Dh, 04h, 15h, 93h
		db	 02h, 15h, 8Ah, 8Ah, 03h, 15h
		db	 8Dh,0C3h, 03h, 15h, 93h, 02h
		db	 15h, 8Ah, 60h, 41h, 50h, 81h
		db	 01h, 15h,0C6h,0C5h, 41h, 40h
		db	0C2h, 05h, 01h, 82h, 43h,0C8h
		db	 01h, 15h, 93h,0C3h,0C6h,0C5h
		db	 51h, 50h,0C2h, 50h, 8Ah, 03h
		db	 15h, 8Dh, 63h,0CAh, 41h, 50h
		db	0C2h, 06h, 01h, 41h, 50h, 81h
		db	0C4h, 01h, 15h, 8Ah, 8Ah,0C3h
		db	 02h, 15h, 85h,0C3h, 87h, 53h
		db	0CAh,0D5h, 93h, 43h,0D5h, 87h
		db	0C4h, 82h, 8Ah,0C4h, 02h, 15h
		db	 85h, 43h, 86h, 53h, 01h, 15h
		db	 8Ah,0C3h,0C4h, 87h,0C4h,0C9h
		db	0D5h, 87h,0C4h, 82h, 8Ah,0C4h
		db	 01h, 15h,0DAh, 85h, 43h,0D4h
		db	 85h,0C9h,0C4h,0CAh, 01h, 15h
		db	 8Ah, 43h,0C5h,0C9h,0CBh, 84h
		db	 43h,0D5h, 87h,0C4h, 82h, 8Ah
		db	0C4h,0C8h,0D5h, 86h, 43h,0C8h
		db	 85h, 43h, 01h, 15h, 4Ah, 89h
		db	 43h,0CAh, 86h,0C9h, 43h, 87h
		db	 43h, 81h, 8Ah, 43h,0D5h, 86h
		db	 43h,0CAh, 85h, 43h,0C8h, 01h
		db	 15h, 8Ah,0C4h,0D4h, 87h,0C4h
		db	0C5h, 4Ah, 86h, 43h, 81h, 8Ah
		db	0C9h,0C4h,0C8h, 86h,0C4h,0C6h
		db	0D5h, 85h, 53h, 01h, 15h, 8Ah
		db	 43h,0C8h, 86h, 53h,0CAh, 86h
		db	 43h, 81h, 8Ah,0C4h,0C9h,0C5h
		db	 4Ah, 84h, 43h,0C5h, 4Ah, 83h
		db	 53h, 01h, 15h, 8Ah,0C9h, 43h
		db	 86h, 43h,0CAh, 87h,0C9h,0C4h
		db	0D4h, 8Ah, 53h, 86h, 53h,0C8h
		db	 84h,0CAh, 43h,0C8h,0D5h, 8Ah
		db	0C4h,0C9h,0C5h,0C8h, 85h,0C4h
		db	 01h, 15h, 87h, 43h,0D5h,0C8h
		db	 89h, 53h,0CAh, 85h, 43h,0DAh
		db	0C4h, 83h,0DDh,0DFh,0C4h,0C9h
		db	0C4h,0D5h, 8Ah, 53h,0CAh, 85h
		db	 43h,0D5h, 87h, 53h, 4Ah, 88h
		db	0C4h,0CAh,0D5h, 86h, 53h,0CAh
		db	 83h,0DDh,0DFh, 53h,0C8h, 8Ah
		db	 53h, 86h, 53h,0C8h, 86h, 53h
		db	0C8h, 89h,0C4h, 01h, 15h, 86h
		db	0C4h,0C6h,0C4h,0CBh, 83h,0DDh
		db	0DFh, 43h,0C5h,0C6h, 8Ah,0C4h
		db	0C9h,0C4h,0C8h, 85h, 53h,0C5h
		db	0CBh, 85h,0C4h, 44h,0CAh, 89h
		db	 43h,0C8h, 86h, 43h,0CAh,0CBh
		db	 83h,0DDh,0DFh,0C4h,0C6h,0C4h
		db	0C9h,0CBh, 89h, 63h, 85h,0C4h
		db	0C9h,0C5h,0C4h, 6Ch, 82h, 53h
		db	 6Ah, 86h, 43h,0C5h,0CBh, 85h
		db	0C6h,0C4h,0D5h,0CCh, 83h,0DDh
		db	0DFh, 63h, 8Ah, 43h,0DAh,0CAh
		db	 85h, 63h, 6Dh, 82h, 43h,0C5h
		db	0C4h,0C8h, 88h, 53h,0C8h, 85h
		db	 43h,0D5h, 84h,0DDh,0DFh, 53h
		db	0C5h, 4Ah, 88h, 43h,0C8h, 86h
		db	 43h,0C9h,0C4h, 05h, 0Fh,0C4h
		db	0C9h,0C4h, 43h,0CAh, 87h,0C4h
		db	0C6h, 43h, 85h, 43h,0DAh, 84h
		db	0DDh,0DFh, 53h,0CAh, 8Ah, 43h
		db	0CAh, 86h, 63h, 05h, 10h, 43h
		db	0D5h,0C4h,0CAh, 88h, 53h,0CAh
		db	 85h,0C4h,0CAh, 85h,0DDh,0DFh
		db	 53h,0D5h, 8Ah,0CAh,0DAh, 87h
		db	 63h, 05h, 11h,0C4h,0C5h,0C4h
		db	0C5h, 4Ah, 87h, 43h,0CAh,0CCh
		db	 85h,0C4h, 87h,0C6h,0C9h,0C4h
		db	0CAh,0D5h, 91h,0DDh,0DEh,0DFh
		db	0C4h,0C5h, 4Ah, 85h, 43h,0C5h
		db	 43h, 88h, 43h,0DAh, 86h,0C4h
		db	 87h, 53h,0D5h,0DAh, 91h,0DDh
		db	0DEh,0DFh,0C5h, 43h, 86h, 53h
		db	 4Ah, 88h, 53h,0CAh, 85h,0C6h
		db	 87h, 53h,0D5h, 92h,0DDh,0DEh
		db	0DFh, 43h,0CBh, 86h,0C9h, 43h
		db	0C4h,0CAh, 88h,0C4h,0C6h,0C4h
		db	 8Eh, 53h,0C8h, 92h,0DDh,0DEh
		db	0DFh, 43h,0CAh, 86h,0C4h,0C9h
		db	0C4h,0D5h, 89h, 43h,0CAh, 51h
		db	 50h,0C2h, 40h,0C2h, 50h, 81h
		db	0C4h,0C6h,0C4h,0CAh, 92h,0DDh
		db	0DEh,0DFh, 43h, 87h, 43h,0D5h
		db	0D5h, 89h,0C9h,0C4h, 8Fh, 53h
		db	0DAh, 94h, 48h,0C4h, 87h, 43h
		db	0CAh,0D5h, 89h, 43h, 8Fh,0C9h
		db	 43h, 95h, 43h,0CAh, 87h,0C4h
		db	 01h, 15h,0D5h, 89h,0C4h,0DAh
		db	 8Fh, 53h, 95h,0C4h,0CAh, 88h
		db	0C4h, 01h, 15h,0D5h, 89h,0E0h
		db	 90h,0C4h,0C6h,0CAh, 95h,0C4h
		db	 89h,0C4h,0C8h,0D5h,0D5h, 89h
		db	0C4h, 90h, 43h, 8Dh,0C3h, 88h
		db	0CAh, 89h, 43h,0C8h,0CAh, 89h
		db	0E0h, 90h, 43h, 41h, 50h,0C2h
		db	0C1h,0C2h, 60h, 81h,0C4h,0C8h
		db	 91h,0C6h, 43h,0D5h, 89h,0C4h
		db	 90h,0C4h,0CAh, 8Dh, 43h, 51h
		db	 50h,0C2h, 60h, 41h, 50h, 81h
		db	 53h,0CAh, 89h,0E0h, 89h,0C3h
		db	 86h,0C4h, 85h,0C8h, 88h, 43h
		db	0C8h, 90h, 53h,0D5h, 89h,0C4h
		db	0CAh, 88h,0C4h, 86h,0CAh, 84h
		db	0C3h,0C4h, 88h,0C4h,0C6h,0C4h
		db	 90h, 43h,0CAh,0D5h, 89h,0C4h
		db	0D4h, 88h,0C4h, 8Bh, 43h,0C8h
		db	 87h, 53h, 90h,0CAh,0C4h,0D5h
		db	0D5h,0D4h, 88h,0C4h,0CAh,0CBh
		db	 87h,0C4h, 51h, 60h,0C2h, 40h
		db	 81h, 43h,0CAh, 87h, 53h, 90h
		db	0C6h,0C4h,0C9h,0C4h,0D5h, 88h
		db	 43h,0CAh, 87h,0C4h,0C8h, 8Ah
		db	0C4h,0CAh, 88h,0C9h, 43h,0C8h
		db	 8Fh, 53h,0C4h,0C8h,0C5h,0CBh
		db	 86h,0C4h, 44h,0CBh, 86h, 43h
		db	 8Ah,0C4h,0D5h,0D4h, 87h, 53h
		db	0CAh, 8Fh, 53h, 43h, 88h, 53h
		db	 87h, 43h, 8Ah,0C4h,0C8h,0D5h
		db	 87h, 43h,0CAh, 90h, 43h,0C6h
		db	 43h, 88h,0C9h, 43h,0C8h, 86h
		db	 43h,0C8h, 89h, 43h,0C8h, 87h
		db	 43h,0D5h, 90h, 53h, 01h, 15h
		db	 88h, 43h,0C6h,0C4h, 86h,0C4h
		db	0C9h,0C4h, 89h,0C4h,0C6h,0C4h
		db	0CAh, 86h,0C4h,0C9h,0D5h, 90h
		db	 53h, 01h, 15h, 88h, 43h,0CAh
		db	 87h, 53h,0CAh, 88h,0C6h,0C4h
		db	0CAh, 87h, 43h,0C8h, 90h, 43h
		db	0D5h, 01h, 15h, 88h,0C4h,0CAh
		db	 88h, 53h, 89h, 43h,0C9h, 87h
		db	 53h,0C8h, 4Ah, 8Dh, 53h, 43h
		db	0C8h, 87h,0C4h,0D5h, 88h, 43h
		db	0CAh, 89h, 53h, 87h, 63h, 8Fh
		db	 53h,0C4h,0CAh, 88h,0C4h,0C8h
		db	 88h,0C4h,0C6h,0C5h,0CBh, 88h
		db	 43h, 44h, 4Ah, 84h, 53h,0CAh
		db	 8Fh, 43h,0C9h,0C4h,0D5h, 88h
		db	 53h,0CAh, 86h,0C9h,0C4h,0C8h
		db	 89h, 53h,0C8h, 86h, 53h, 90h
		db	0C6h, 43h,0C4h,0D5h, 88h,0C4h
		db	0C6h,0C4h, 87h, 43h,0CAh, 89h
		db	0C4h,0C6h,0C4h,0CAh, 86h,0C6h
		db	 43h, 90h,0C9h, 43h,0CAh,0D5h
		db	 88h,0C9h,0C4h,0CAh, 87h,0C4h
		db	0CAh,0D5h,0CCh, 88h, 43h,0D5h
		db	 87h, 43h, 44h, 4Ah, 8Dh, 53h
		db	 01h, 15h,0CCh, 87h, 43h, 88h
		db	0C4h, 01h, 15h, 89h, 43h,0C8h
		db	 87h, 53h, 90h, 43h,0D5h,0D5h
		db	0CBh, 88h,0C4h,0CAh, 88h, 43h
		db	0C8h, 89h,0C4h,0C9h,0C5h,0C8h
		db	0CBh, 85h, 43h,0D5h, 90h, 43h
		db	0C8h, 01h, 15h, 88h,0C4h, 89h
		db	0C9h, 43h,0CAh, 88h, 53h,0CAh
		db	 86h, 43h,0D5h, 90h, 53h,0C8h
		db	0D5h, 88h,0CAh, 89h, 43h,0CAh
		db	 89h, 53h, 87h,0C4h, 01h, 15h
		db	0D4h, 8Fh,0C4h,0C6h,0C4h, 44h
		db	 4Ah, 90h,0C4h,0C5h, 4Ah, 88h
		db	0C9h,0C4h,0CAh, 87h,0C4h, 02h
		db	 15h, 8Fh, 53h,0CAh,0C9h,0C5h
		db	 61h, 40h,0C2h, 07h, 01h, 82h
		db	0C4h,0CAh,0D5h, 89h, 43h,0D5h
		db	 87h,0C6h, 02h, 15h, 8Fh, 53h
		db	 01h, 15h, 92h,0C4h, 01h, 15h
		db	 89h, 43h,0D5h, 87h, 03h, 15h
		db	 8Fh,0C4h,0CAh,0D5h, 01h, 15h
		db	 92h,0C4h, 01h, 15h, 89h,0C4h
		db	0CAh,0D5h, 87h, 03h, 15h, 8Fh
		db	0C4h, 01h, 15h, 01h, 15h,0CCh
		db	 91h,0CAh, 01h, 15h,0CCh, 88h
		db	0C4h, 01h, 15h, 87h, 03h, 15h
		db	 8Fh,0CAh, 01h, 15h, 01h, 15h
		db	0CCh, 91h, 02h, 15h, 89h,0CAh
		db	 01h, 15h, 87h, 03h, 15h, 8Fh
		db	 02h, 15h, 01h, 15h, 92h, 02h
		db	 15h, 89h, 02h, 15h, 87h, 03h
		db	 15h, 8Fh, 02h, 15h, 01h, 15h
		db	0CCh, 91h,0D6h, 01h, 15h, 89h
		db	0D6h, 01h, 15h, 87h,0D6h, 02h
		db	 15h, 8Fh,0D6h, 01h, 15h, 13h
		db	 0Dh,0D7h, 08h, 0Dh, 82h,0D7h
		db	 08h, 0Dh,0D7h, 11h, 0Dh,0D7h
		db	 4Ch, 1Dh, 0Eh, 82h, 1Fh, 0Eh
		db	 1Eh, 0Fh,0D2h,0D3h, 1Eh, 0Fh
		db	 2Dh, 0Fh,0D2h,0D3h, 0Fh, 0Fh
		db	 08h, 0Fh,0D2h,0D3h, 10h, 0Fh
		db	0D2h,0D3h, 21h, 0Fh, 3Fh, 10h
		db	 10h, 11h,0D8h, 0Ch, 11h,0D8h
		db	 0Eh, 11h,0D8h, 09h, 11h,0D8h
		db	 04h, 11h, 91h,0D9h, 02h, 15h
		db	 8Ah,0D9h, 02h, 15h, 8Ch,0D9h
		db	 02h, 15h, 87h,0D9h, 02h, 15h
		db	 82h, 91h, 03h, 15h, 8Ah, 03h
		db	 15h, 8Ch, 03h, 15h, 87h, 03h
		db	 15h,0CCh, 81h, 91h, 03h, 15h
		db	 8Ah, 03h, 15h, 8Ch, 03h, 15h
		db	 87h, 03h, 15h, 82h, 91h,0C3h
		db	 02h, 15h, 8Ah, 03h, 15h, 8Ch
		db	 03h, 15h, 87h, 03h, 15h, 82h
		db	 91h,0C4h, 02h, 15h, 8Ah, 03h
		db	 15h, 8Ch,0C3h, 02h, 15h, 87h
		db	0C3h, 02h, 15h,0CCh, 81h, 91h
		db	0C4h,0C8h, 01h, 15h, 8Ah,0C3h
		db	 02h, 15h, 8Ch,0C4h, 02h, 15h
		db	 87h,0C4h, 02h, 15h, 82h, 91h
		db	 43h, 01h, 15h, 8Ah,0C4h, 02h
		db	 15h, 8Ch,0C4h, 02h, 15h, 87h
		db	0C4h, 02h, 15h, 82h, 91h, 43h
		db	 01h, 15h, 8Ah,0C4h,0C5h, 5Ah
		db	 8Bh,0C4h, 01h, 15h,0DAh, 87h
		db	0C4h,0C8h, 01h, 15h, 82h, 8Ch
		db	0E2h, 84h, 43h,0C8h,0D5h, 8Ah
		db	 43h,0D5h, 8Dh,0C4h,0C8h,0D5h
		db	 88h, 43h,0C8h,0D5h, 82h, 8Ch
		db	0E3h, 84h,0C4h,0C9h,0C4h,0DAh
		db	 8Ah, 43h,0D5h, 8Dh,0C9h,0C4h
		db	0C8h, 88h, 53h,0D5h, 82h, 8Ch
		db	0E4h, 84h, 53h, 8Bh,0C4h,0C9h
		db	0D5h, 8Dh, 53h,0C8h, 87h, 53h
		db	0D5h, 82h, 8Ch,0E5h, 84h,0C9h
		db	 43h,0C8h, 8Ah, 53h,0D4h, 8Ch
		db	 63h,0C8h, 86h, 53h,0C8h, 82h
		db	 8Ch,0E6h, 84h, 53h,0CAh, 8Ah
		db	 43h,0CAh,0D5h, 8Ch, 43h,0C9h
		db	0CAh, 87h,0C4h,0C6h, 43h, 82h
		db	 91h,0C4h,0CAh,0D5h, 8Bh,0C9h
		db	 43h,0D5h, 8Ch,0C4h,0C9h,0CAh
		db	 88h, 63h, 82h,0CBh, 90h,0C4h
		db	 01h, 15h, 8Bh, 53h,0D5h, 8Ch
		db	 43h,0D5h, 88h, 53h, 44h,0CBh
		db	 91h, 43h,0C8h, 8Bh,0C4h,0C9h
		db	 43h,0CAh, 8Bh, 53h,0CAh, 87h
		db	 73h, 81h, 91h, 53h, 8Bh, 53h
		db	0CAh, 8Ch, 43h,0CAh, 88h,0C6h
		db	 53h,0CAh, 81h, 91h,0C4h,0C6h
		db	0C4h,0C8h, 8Ah, 53h,0D5h, 8Ch
		db	0C4h,0CAh,0D6h, 88h, 53h,0CAh
		db	 82h, 91h,0C9h, 53h,0CAh, 89h
		db	 53h,0D5h, 8Ch,0C4h, 01h, 15h
		db	 88h, 53h,0D5h, 82h, 91h, 43h
		db	0C9h,0CAh, 8Ah, 53h,0C8h, 8Ch
		db	0C9h,0C8h,0D5h, 88h, 53h,0C8h
		db	 82h, 91h, 43h, 44h, 4Ah, 88h
		db	 63h,0C8h, 8Bh, 53h,0C8h, 87h
		db	 43h,0C6h,0C4h, 82h, 91h,0C4h
		db	0C9h,0C4h, 8Bh,0C6h, 53h, 49h
		db	 8Ah,0C4h,0C6h,0C4h,0CAh, 87h
		db	 63h,0CAh, 81h, 91h, 43h,0CAh
		db	 8Bh, 53h,0CAh, 8Ch, 43h,0CAh
		db	 88h, 53h,0CAh, 82h, 91h, 43h
		db	0D5h, 8Bh, 43h,0CAh,0D5h, 8Ch
		db	 43h,0D5h, 88h, 43h,0CAh,0D5h
		db	 82h, 91h, 43h,0D5h, 8Bh, 43h
		db	 01h, 15h, 8Ch, 43h,0C8h, 88h
		db	 43h, 01h, 15h, 82h, 91h,0C6h
		db	0C4h,0D5h, 8Bh, 43h,0C8h,0D5h
		db	 8Ch,0C4h,0C9h, 43h,0C8h, 86h
		db	 63h, 82h, 88h,0C3h, 88h, 43h
		db	0DAh, 8Bh, 53h,0D5h, 8Ch, 53h
		db	 5Ah, 85h, 73h, 81h, 88h,0C4h
		db	 88h,0C4h,0C5h, 4Ah, 8Ah, 53h
		db	0C8h, 8Ch,0DCh,0C5h, 43h,0CAh
		db	 86h,0C6h,0C4h,0C6h,0C4h,0C9h
		db	0CAh, 88h,0C4h, 88h,0C4h,0C9h
		db	0C4h, 8Bh, 63h,0CAh, 8Ch,0DCh
		db	0C5h,0C4h,0CBh, 86h, 53h,0CAh
		db	 82h, 88h,0C4h,0C8h, 87h, 43h
		db	0CAh, 8Bh,0C4h,0C6h, 43h, 8Fh
		db	0C4h,0C8h, 86h, 43h,0CAh,0D5h
		db	 82h, 88h,0C9h,0C4h,0C8h, 86h
		db	0C9h,0C4h, 85h,0C8h, 86h, 63h
		db	 8Fh, 43h, 86h, 43h, 01h, 15h
		db	 82h, 88h, 43h,0CAh, 86h, 43h
		db	 85h,0C4h, 86h, 53h,0CAh, 8Fh
		db	0C4h,0C9h,0CCh, 85h, 43h, 01h
		db	 15h, 82h, 88h,0C4h,0C5h, 4Ah
		db	 85h,0C4h,0CAh, 85h,0C4h,0C8h
		db	 85h, 43h,0CAh,0D5h, 8Fh, 43h
		db	 86h, 53h,0C8h, 82h, 88h, 43h
		db	0C8h, 86h,0C4h, 86h,0C4h,0CAh
		db	 85h,0C9h,0C4h, 01h, 15h, 84h
		db	0C3h, 8Ah,0C4h,0CAh, 86h, 63h
		db	0C8h, 81h, 88h, 53h,0C8h, 85h
		db	0C4h, 86h,0C4h,0D4h, 85h, 43h
		db	0CAh,0D5h, 84h,0C4h, 8Ah,0CAh
		db	 87h, 43h,0C9h,0C4h,0CAh, 81h
		db	 88h,0C4h,0C6h, 43h,0C8h, 84h
		db	0CAh, 86h,0C4h,0C8h, 85h, 43h
		db	 01h, 15h,0CCh, 83h,0C4h,0C8h
		db	 91h, 63h, 82h, 88h, 63h, 8Ch
		db	 43h, 85h, 43h, 01h, 15h, 84h
		db	 43h, 41h, 60h,0C2h,0C1h, 41h
		db	 40h,0C2h, 50h, 81h, 63h, 82h
		db	 88h, 63h, 8Ch, 43h, 85h, 43h
		db	0C8h,0D5h, 84h, 43h, 91h,0C6h
		db	 43h,0CAh, 82h, 88h,0C6h, 43h
		db	 8Dh, 43h,0D4h, 84h, 53h,0D5h
		db	0CCh, 83h, 43h,0C8h, 88h,0C3h
		db	0C8h, 86h, 53h,0D5h, 82h, 88h
		db	 43h,0D5h, 8Dh,0C4h,0C9h,0D5h
		db	 84h, 43h,0CAh,0D5h, 84h, 53h
		db	 88h, 43h, 86h, 53h,0D5h, 82h
		db	 88h, 53h,0C8h, 8Ch, 43h,0D5h
		db	 84h, 43h, 01h, 15h, 84h,0C3h
		db	0C4h,0CAh, 88h, 53h,0C8h, 84h
		db	 53h,0DAh, 82h, 88h, 63h,0C8h
		db	 8Bh, 43h,0C8h, 84h, 43h, 01h
		db	 15h, 84h, 43h,0D4h, 88h,0C4h
		db	0C6h,0C4h,0CAh, 84h, 53h, 83h
		db	 88h, 43h,0C6h,0C5h,0CBh, 8Bh
		db	 53h, 84h, 43h,0C8h,0D5h, 84h
		db	 43h,0D5h, 88h,0C9h, 43h, 84h
		db	0C3h, 43h,0C5h,0CBh, 82h, 88h
		db	 63h,0CAh, 8Bh,0C9h,0C4h,0C9h
		db	 84h, 43h,0CAh,0D5h, 84h,0C4h
		db	0C6h,0D5h, 88h, 53h,0C5h,0CCh
		db	 81h,0C3h, 43h,0C5h,0C8h, 83h
		db	 88h,0C9h,0C4h,0CAh,0D4h, 8Ch
		db	 53h, 84h, 43h,0D5h,0DAh, 84h
		db	 43h,0C8h, 88h, 53h,0C9h,0C8h
		db	0CBh,0C4h,0C9h, 43h, 49h, 82h
		db	 88h,0C4h, 02h, 15h, 8Ch, 53h
		db	 84h, 43h,0CAh, 85h, 43h,0C5h
		db	0CBh, 87h, 63h,0CAh,0C6h,0CAh
		db	0C4h,0C5h, 4Ah, 83h, 88h,0C4h
		db	0C8h, 01h, 15h, 8Ch, 43h,0C5h
		db	0CBh, 83h, 44h, 4Ah, 84h,0C9h
		db	 43h,0CAh, 87h, 43h, 44h, 5Ah
		db	 43h,0CAh, 84h, 88h, 73h, 8Bh
		db	0C4h,0C9h,0CAh, 84h,0DCh,0C5h
		db	0C8h, 85h, 53h, 88h, 63h,0CAh
		db	 82h,0CAh,0C5h,0CBh, 84h, 88h
		db	 63h,0CAh, 8Bh, 43h,0D5h, 85h
		db	 43h, 85h, 43h,0D5h, 88h, 43h
		db	 44h, 4Ah, 82h,0CAh, 85h, 88h
		db	 43h,0C9h,0C5h, 4Ah, 8Ah, 43h
		db	0D5h, 85h, 43h, 85h, 43h,0C8h
		db	 88h, 43h, 49h, 8Ah, 88h,0C9h
		db	 43h,0CAh, 8Ch, 43h,0C8h, 85h
		db	0CAh,0C4h, 85h,0C4h,0C6h,0C4h
		db	0CAh, 87h,0C4h,0C5h,0CBh, 8Bh
		db	 88h,0C4h,0C6h,0C4h,0D5h, 8Ch
		db	 53h, 86h,0C4h, 85h, 43h,0D5h
		db	 88h, 43h,0CAh, 8Bh, 88h, 43h
		db	0CAh,0D5h, 8Ch,0C9h,0C4h,0CAh
		db	 86h,0CAh, 85h, 43h,0C8h, 88h
		db	0C4h,0CAh,0D5h, 8Bh, 88h, 43h
		db	 01h, 15h, 8Ch, 43h,0D5h, 8Ch
		db	 43h,0CAh, 88h,0C4h, 01h, 15h
		db	 8Bh, 88h, 43h, 01h, 15h, 8Ch
		db	0C4h,0CAh,0D5h, 41h, 40h,0C2h
		db	 50h,0C2h, 40h, 81h, 43h,0D5h
		db	 88h,0C4h,0CAh,0D5h, 8Bh, 88h
		db	0C4h,0CAh, 01h, 15h, 8Ch,0C4h
		db	 01h, 15h, 8Ch,0C4h,0CAh,0D5h
		db	 88h,0C4h, 01h, 15h,0CCh, 8Ah
		db	 88h,0C4h, 02h, 15h, 8Ch,0C4h
		db	 01h, 15h, 8Ch,0CAh, 01h, 15h
		db	 88h,0CAh, 01h, 15h, 8Bh, 88h
		db	0C4h, 02h, 15h, 8Ch,0CAh, 01h
		db	 15h, 8Ch, 02h, 15h, 88h, 02h
		db	 15h, 8Bh, 88h,0CAh, 02h, 15h
		db	 8Ch, 02h, 15h, 8Ch, 02h, 15h
		db	 88h, 02h, 15h,0CCh, 8Ah, 88h
		db	 03h, 15h, 8Ch, 02h, 15h, 8Ch
		db	 02h, 15h, 88h, 02h, 15h,0CCh
		db	 8Ah, 88h,0D6h, 02h, 15h, 8Ch
		db	0D6h, 01h, 15h, 8Ch,0D6h, 01h
		db	 15h, 88h,0D6h, 01h, 15h, 8Bh
		db	 07h, 0Dh,0D7h, 0Eh, 0Dh,0D7h
		db	 0Dh, 0Dh,0D7h, 09h, 0Dh,0D7h
		db	 0Ch, 0Dh, 3Fh, 0Eh, 3Fh, 0Fh
		db	 05h, 00h, 1Ah,0A9h, 00h, 31h
		db	0FFh,0FFh,0FFh,0FFh, 60h, 40h
		db	0AAh, 5Dh, 00h, 63h, 00h,0FFh
		db	0FFh, 13h, 00h, 31h,0C1h, 05h
		db	 13h, 00h, 31h, 00h,0FFh,0FFh
		db	0FFh, 16h, 00h, 17h,0C3h, 05h
		db	 16h, 00h, 17h, 00h,0FFh,0FFh
		db	0FFh, 2Fh, 00h, 0Eh,0C1h, 05h
		db	 2Fh, 00h, 0Eh, 00h,0FFh,0FFh
		db	0FFh, 34h, 00h, 25h,0C2h, 05h
		db	 34h, 00h, 25h, 00h,0FFh,0FFh
		db	0FFh, 56h, 00h, 2Fh,0C4h, 05h
		db	 56h, 00h, 2Fh, 00h,0FFh,0FFh
		db	0FFh, 58h, 00h, 06h,0C3h, 05h
		db	 58h, 00h, 06h, 00h,0FFh,0FFh
		db	0FFh, 72h, 00h, 06h,0C3h, 05h
		db	 72h, 00h, 06h, 00h,0FFh,0FFh
		db	0FFh, 76h, 00h, 1Ch,0C4h, 05h
		db	 76h, 00h, 1Ch, 00h,0FFh,0FFh
		db	0FFh, 95h, 00h, 0Dh, 80h, 03h
		db	 07h, 00h,0FFh, 00h,0FFh,0FFh
		db	0FFh, 99h, 00h, 2Bh,0C2h, 05h
		db	 99h, 00h, 2Bh, 00h,0FFh,0FFh
		db	0FFh,0AEh, 00h, 04h,0C2h, 07h
		db	 34h, 00h, 15h, 00h,0FFh,0FFh
		db	0FFh,0BAh, 00h, 2Eh,0C2h, 05h
		db	0BAh, 00h, 2Eh, 00h,0FFh,0FFh
		db	0FFh,0BCh, 00h, 14h, 01h, 07h
		db	 11h, 00h, 15h, 00h, 13h, 00h
		db	 08h,0C0h, 00h, 04h, 40h, 09h
		db	 63h, 00h, 35h, 00h, 13h, 00h
		db	 01h,0FFh,0FFh, 10h, 00h,0FFh
		db	 13h,0C0h,0FFh,0FFh,0FFh,0FFh
		db	 12h, 00h, 02h,0A8h,0CEh, 00h
		db	0FFh,0B1h,0CEh,0FFh,0FFh,0FFh
		db	0FFh, 12h, 00h, 01h,0F1h,0CEh
		db	 00h, 00h,0FFh,0FFh, 13h, 00h
		db	 80h,0F1h,0CFh, 00h, 00h,0FFh
		db	0FFh, 13h, 00h, 40h,0F8h,0CFh
		db	 00h,0FFh, 01h,0D0h,0FFh,0FFh
		db	0FFh,0FFh, 13h, 00h, 20h,0C8h
		db	0D0h, 00h,0FFh,0D3h,0D0h,0FFh
		db	0FFh,0FFh,0FFh, 13h, 00h, 10h
		db	 08h,0D1h, 00h,0FFh, 13h,0D1h
		db	0FFh,0FFh,0FFh,0FFh, 13h, 00h
		db	 08h, 17h,0CEh, 81h, 07h,0FFh
		db	0FFh, 13h, 00h, 01h, 23h,0CEh
		db	0C0h, 09h,0FFh,0FFh,0FFh,0FFh
		db	 18h,0AFh, 00h, 0Eh
		db	'Cavern of Riza', 0Dh
		db	 00h, 02h, 04h, 04h, 04h, 00h
		db	 23h,0FFh, 73h, 00h, 00h, 20h
		db	 00h, 19h, 00h, 12h, 00h, 02h
		db	 0Fh, 00h, 04h, 00h, 33h,0FFh
		db	 03h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 04h, 00h, 33h, 03h, 00h
		db	 07h, 00h, 23h,0FFh, 03h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 07h
		db	 00h, 23h, 03h, 00h, 0Dh, 00h
		db	 09h,0FFh, 02h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 0Dh, 00h, 09h
		db	 02h, 00h, 13h, 00h, 09h,0FFh
		db	0D0h, 00h, 00h, 20h, 00h, 18h
		db	 00h, 12h, 00h, 01h, 00h, 00h
		db	 13h, 00h, 3Dh,0FFh, 02h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 13h
		db	 00h, 3Dh, 02h, 00h, 21h, 00h
		db	 10h,0FFh, 02h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 21h, 00h, 10h
		db	 02h, 00h, 2Dh, 00h, 33h,0FFh
		db	 01h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 2Dh, 00h, 33h, 01h, 00h
		db	 30h, 00h, 1Eh,0FFh, 01h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 30h
		db	 00h, 1Eh, 01h, 00h, 35h, 00h
		db	 1Eh,0FFh, 02h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 35h, 00h, 1Eh
		db	 02h, 00h, 37h, 00h, 3Ah,0FFh
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 37h, 00h, 3Ah, 00h, 00h
		db	 3Eh, 00h, 33h,0FFh, 03h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 3Eh
		db	 00h, 33h, 03h, 00h, 3Fh, 00h
		db	 10h,0FFh, 03h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 3Fh, 00h, 10h
		db	 03h, 00h, 3Fh, 00h, 3Fh,0FFh
		db	 03h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 3Fh, 00h, 3Fh, 03h, 00h
		db	 41h, 00h, 33h,0FFh,0D0h, 00h
		db	 00h, 00h, 00h, 00h, 00h,0FFh
		db	0FFh,0FFh, 0Fh, 00h, 48h, 00h
		db	 08h,0FFh, 03h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 48h, 00h, 08h
		db	 03h, 00h, 48h, 00h, 19h,0FFh
		db	 03h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 48h, 00h, 19h, 03h, 00h
		db	 52h, 00h, 11h,0FFh, 02h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 52h
		db	 00h, 11h, 02h, 00h, 52h, 00h
		db	 28h,0FFh, 02h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 52h, 00h, 28h
		db	 02h, 00h, 53h, 00h, 3Bh,0FFh
		db	 02h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 53h, 00h, 3Bh, 02h, 00h
		db	 58h, 00h, 3Bh,0FFh,0D0h, 00h
		db	 00h, 20h, 00h, 18h, 00h, 13h
		db	 00h, 80h, 00h, 00h, 5Dh, 00h
		db	 3Bh,0FFh, 73h, 00h, 00h, 20h
		db	 00h, 19h, 00h, 13h, 00h, 40h
		db	 00h, 00h, 5Fh, 00h, 3Bh,0FFh
		db	 03h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 5Fh, 00h, 3Bh, 03h, 00h
		db	 67h, 00h, 01h,0FFh
		db	7 dup (0)
		db	 67h, 00h, 01h, 00h, 00h, 67h
		db	 00h, 08h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 67h, 00h
		db	 08h, 02h, 00h, 6Eh, 00h, 28h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 6Eh, 00h, 28h, 02h
		db	 00h, 6Fh, 00h, 12h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 6Fh, 00h, 12h, 02h, 00h, 76h
		db	 00h, 3Bh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 76h, 00h
		db	 3Bh, 02h, 00h, 7Dh, 00h, 3Bh
		db	0FFh, 01h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 7Dh, 00h, 3Bh, 01h
		db	 00h, 80h, 00h, 23h,0FFh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 80h, 00h, 23h, 00h, 00h, 82h
		db	 00h, 17h,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 82h, 00h
		db	 17h, 00h, 00h, 82h, 00h, 2Eh
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 82h, 00h, 2Eh, 00h
		db	 00h, 83h, 00h, 02h,0FFh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 83h, 00h, 02h, 00h, 00h, 83h
		db	 00h, 12h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 83h, 00h
		db	 12h, 03h, 00h, 83h, 00h, 28h
		db	0FFh, 73h, 00h, 03h, 20h, 00h
		db	 00h, 00h, 13h, 00h, 20h, 00h
		db	 00h, 85h, 00h, 1Eh,0FFh,0D0h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh,0FFh, 00h, 00h, 8Ch
		db	 00h, 1Dh,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 8Ch, 00h
		db	 1Dh, 01h, 00h, 8Ch, 00h, 2Dh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 8Ch, 00h, 2Dh, 03h
		db	 00h, 8Ch, 00h, 38h,0FFh, 73h
		db	 00h, 02h, 20h, 00h, 00h, 00h
		db	 13h, 00h, 10h, 00h, 00h, 8Eh
		db	 00h, 38h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 8Eh, 00h
		db	 38h, 03h, 00h, 95h, 00h, 38h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 95h, 00h, 38h, 02h
		db	 00h,0A0h, 00h, 1Dh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0A0h, 00h, 1Dh, 02h, 00h,0A1h
		db	 00h, 38h,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0A1h, 00h
		db	 38h, 01h, 00h,0A4h, 00h, 0Fh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0A4h, 00h, 0Fh, 02h
		db	 00h,0B3h, 00h, 16h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0B3h, 00h, 16h, 02h, 00h,0B3h
		db	 00h, 25h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B3h, 00h
		db	 25h, 02h, 00h,0C3h, 00h, 30h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0C3h, 00h, 30h, 02h
		db	 00h,0C7h, 00h, 25h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0C7h, 00h, 25h, 03h, 00h,0FFh
		db	0FFh

zr3_26		endp

seg_a		ends



		end	start
