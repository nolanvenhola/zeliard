
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_338MP70                                 лл
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

_338MP70	proc	far

start:
		cmp	bl,[bx]
		add	[bx+si],al
		db	 63h,0DDh,0D0h, 00h, 0Bh,0DCh
		db	 2Bh,0DCh, 36h,0DCh, 38h,0DCh
		db	0E2h,0DCh, 4Dh,0DDh, 68h,0DDh
		db	 07h,0C7h, 00h, 22h, 0Ah, 00h
		db	 00h, 0Bh,0DCh,0C5h,0D6h,0CBh
		db	0D1h,0CAh,0C7h,0CAh,0CBh,0CCh
		db	 6Ch, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 81h,0E4h, 84h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0D0h
		db	0D1h,0CAh,0D4h, 84h,0C5h,0D6h
		db	0CBh,0D1h, 02h, 13h,0CAh,0CBh
		db	 6Eh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 81h,0E5h, 84h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0D0h
		db	0D1h,0CAh,0D4h, 84h,0C6h,0D5h
		db	0CAh,0D3h,0DAh,0D7h,0C5h,0D6h
		db	 03h, 12h,0CBh,0CCh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 81h,0E6h, 84h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0D0h,0D1h,0CAh,0D4h
		db	 84h, 81h,0C6h,0D3h,0D9h, 82h
		db	0C6h, 04h, 13h,0CAh,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 81h,0E7h
		db	 84h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0D0h,0D1h,0CAh
		db	0D4h, 84h, 8Bh,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 81h
		db	0EEh, 84h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 5Dh,0D0h,0D1h
		db	0CAh,0DAh, 84h,0C1h,0C2h, 40h
		db	 87h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0CFh
		db	 4Dh,0D0h,0D1h,0CAh,0C3h,0C1h
		db	 41h,0C1h, 8Bh,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0D0h,0D1h,0CAh,0D4h
		db	 84h, 8Bh,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0D0h,0D1h,0CAh,0D4h, 84h
		db	 8Bh,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 84h
		db	 8Bh,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0D0h,0D1h,0CAh,0D4h, 84h, 8Bh
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh, 7Eh,0D1h,0CAh
		db	0D4h, 84h, 8Bh,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h, 49h,0D3h
		db	0D4h, 86h,0C5h,0D6h, 05h, 12h
		db	 49h,0DAh, 84h, 8Bh,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	0CAh,0D4h, 85h,0C6h, 02h, 13h
		db	0DAh, 87h,0C5h,0D5h, 06h, 0Ah
		db	0D3h,0D9h, 84h, 8Bh,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	0CAh,0D4h, 91h,0C5h, 07h, 13h
		db	0D9h, 85h, 8Bh,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0CAh
		db	0C3h, 40h,0C2h,0C1h, 41h, 50h
		db	 88h,0C5h,0D4h, 8Dh, 8Bh,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 91h,0C5h,0D4h
		db	 8Dh, 8Bh,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0CAh,0C3h
		db	0C1h,0C2h, 70h,0C2h, 50h, 86h
		db	0C5h,0D4h, 8Dh, 8Bh,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	0CAh,0DAh, 91h,0C5h,0D4h, 84h
		db	0C4h, 56h,0D8h, 84h, 8Bh,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 88h,0C4h, 56h
		db	0D8h, 84h,0C5h,0D4h, 84h,0C5h
		db	0D6h, 49h,0D4h, 84h, 8Bh,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 88h,0C5h,0D6h
		db	0CBh,0D1h,0DAh, 84h,0C5h,0D4h
		db	 84h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 84h, 8Bh,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0CAh,0D4h
		db	 88h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 84h,0C5h,0D4h, 84h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 84h, 8Bh,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 88h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 84h,0C5h,0D4h
		db	 84h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 84h, 8Bh,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0CAh,0D4h
		db	 88h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 84h,0C5h,0D4h, 84h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 84h, 8Bh,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 88h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 84h,0C5h,0D4h
		db	 84h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 84h, 8Bh,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0CAh,0D4h
		db	 88h,0C5h,0D6h,0CAh,0D3h,0DAh
		db	 84h,0C5h,0D4h, 84h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 84h, 8Bh,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 88h,0C6h, 01h
		db	 13h,0D9h, 85h,0C5h, 76h, 49h
		db	0CBh,0D1h,0D4h, 84h, 8Bh,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 91h,0C5h,0D6h
		db	 06h, 0Ah,0D3h,0D9h, 84h, 8Bh
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0CAh,0D4h, 91h,0C5h
		db	0D6h,0CAh, 48h, 49h, 01h, 13h
		db	0DAh, 85h, 8Bh,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0CAh
		db	0D4h, 91h,0C5h,0D6h,0CBh, 4Ch
		db	0D1h,0CAh,0DAh, 87h, 8Bh,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 91h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D9h
		db	 87h, 8Bh,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0CAh,0D4h
		db	 91h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 87h, 8Bh,0C5h
		db	0D6h,0CBh, 4Eh,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	0CAh,0DAh, 91h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 87h
		db	 8Bh,0C5h,0D6h,0CAh,0D2h,0CBh
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D1h,0CAh,0D4h, 91h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0DAh, 87h, 8Bh,0C5h,0D5h
		db	 49h,0CBh,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0CAh
		db	0D4h, 91h,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 87h,0C4h
		db	 66h,0D8h, 85h,0C6h, 01h, 13h
		db	0D6h,0CBh,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0CAh
		db	0D4h, 91h,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 87h,0D6h
		db	 69h,0C7h,0D8h, 86h,0C5h,0D6h
		db	0CBh,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0D3h,0C3h
		db	0C1h, 41h, 70h,0C2h, 50h, 41h
		db	 40h, 81h,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C4h
		db	0D6h,0CAh, 58h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	0DAh, 92h,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh, 4Ch,0D1h,0CAh,0C7h
		db	0D8h, 85h,0C5h,0D6h,0CBh,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0DBh,0D7h,0C5h, 56h
		db	0D4h,0D7h,0C4h, 0Ah, 07h,0CAh
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0CEh
		db	0D1h,0C9h,0CAh,0DAh, 85h,0C5h
		db	0D6h,0CBh,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CEh,0D1h, 46h
		db	 69h,0C7h,0DAh,0D7h,0C5h,0D6h
		db	 09h, 0Ah,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0CEh,0CDh,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CEh
		db	0D1h,0CBh,0CCh,0CDh,0D1h,0C9h
		db	 49h, 56h,0CAh,0CBh,0CCh, 08h
		db	 0Dh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0CDh, 5Dh, 08h
		db	 0Dh, 5Dh,0CDh, 06h, 0Eh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CFh
		db	0D1h,0CBh,0CCh, 7Eh, 4Dh, 06h
		db	 0Fh, 6Dh,0CFh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0D1h,0D3h,0D9h
		db	 86h,0C5h,0D6h,0CAh,0D2h, 01h
		db	 13h, 03h, 12h,0CBh,0CCh, 4Eh
		db	0D1h, 01h, 13h,0CAh, 01h, 12h
		db	0CBh,0CCh, 7Eh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D1h,0CAh,0D4h, 85h
		db	0C6h,0D5h,0CBh,0D1h,0DAh, 87h
		db	0C6h,0D5h, 49h,0DAh,0D7h,0C5h
		db	 01h, 13h, 49h, 01h, 12h, 49h
		db	0DAh,0D7h,0C5h,0D6h, 06h, 0Ah
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D1h,0CAh,0D4h, 86h,0C6h, 01h
		db	 13h,0D9h, 88h,0C6h, 01h, 13h
		db	0DBh,0C5h,0DAh, 81h,0D7h,0C6h
		db	 04h, 13h,0D9h,0D7h,0C6h, 06h
		db	 13h,0CAh,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D1h,0CAh,0D4h,0A9h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D1h,0CAh,0D4h,0A9h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D1h,0CAh,0DBh,0A9h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D1h,0CAh,0C7h,0DBh
		db	0D7h, 9Bh,0C4h, 46h,0D8h, 88h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D1h, 48h,0CAh,0DAh
		db	 99h,0C4h,0C7h, 59h, 46h,0DAh
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh, 5Ch,0D1h,0CAh
		db	0D8h, 98h,0C5h,0D6h,0CAh, 58h
		db	 49h,0DAh, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 6Dh,0D0h
		db	0D1h,0CAh,0D4h, 98h,0C5h,0D6h
		db	0CAh,0CBh, 4Ch,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0DAh, 86h,0C5h,0D6h
		db	0CBh,0CCh, 6Dh,0D0h,0D1h,0CAh
		db	0D4h, 98h,0C5h,0D6h,0CBh,0CDh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0DBh, 86h,0C5h,0D6h,0CBh
		db	0CCh, 6Dh,0D0h,0D1h,0CAh,0D4h
		db	 98h,0C5h,0D6h,0CBh,0CCh,0CEh
		db	0D0h,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 6Dh,0D0h,0D1h,0CAh,0D4h, 98h
		db	0C5h,0D6h,0CBh,0CCh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 6Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C4h
		db	 56h,0D8h, 8Dh,0C5h,0D6h,0CBh
		db	0CCh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 6Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D5h, 49h, 46h
		db	0DAh, 8Bh,0C5h,0D6h,0CBh,0CCh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 6Dh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C4h,0D6h,0CAh, 58h,0CAh
		db	 46h,0D8h, 89h,0C5h,0D6h,0CBh
		db	0CCh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 6Dh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CAh,0CBh
		db	 4Ch,0D1h, 49h,0D9h, 89h,0C5h
		db	0D6h,0CBh,0CCh,0CEh,0D0h,0D1h
		db	0CAh,0DAh, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 6Dh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CDh, 4Dh,0CDh,0D1h,0CAh
		db	0DAh, 89h,0C5h,0D6h,0CBh,0CCh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	 05h, 0Fh,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 89h,0C5h,0D6h
		db	0CBh,0CCh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CAh, 05h, 12h, 49h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 89h,0C5h
		db	0D6h,0CBh,0CCh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D5h, 05h, 0Ah, 02h, 13h
		db	0D9h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 89h
		db	0C5h,0D6h,0CBh,0CFh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C6h,0C6h, 05h, 13h,0D8h
		db	 01h, 17h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 89h,0C5h,0D6h,0CAh,0CBh, 4Eh
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 87h, 86h,0C4h, 46h,0D7h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 89h,0C5h,0D6h
		db	0CAh, 02h, 12h, 49h,0DAh, 85h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 87h, 85h,0C4h,0C7h
		db	 49h,0C7h,0DAh, 85h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 89h,0C5h,0D6h,0CAh, 02h
		db	 13h,0CAh,0D3h,0D9h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0DAh, 87h, 85h,0C5h,0D6h,0CAh
		db	0C9h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 89h,0C6h,0D3h,0DAh,0D7h
		db	0D9h,0D7h,0C6h,0D9h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0DBh, 87h, 85h,0C5h,0D6h,0CBh
		db	0CDh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 88h,0DEh, 66h, 01h, 17h
		db	0C4h,0D9h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh, 05h, 07h
		db	0DAh, 81h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 87h,0DEh,0C7h,0CBh,0D0h
		db	0D1h,0CAh, 46h,0CAh,0C7h,0D8h
		db	 85h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h, 06h, 0Ah,0C7h,0D8h, 85h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CFh, 4Dh
		db	0CFh,0D1h,0CAh,0D4h, 86h,0DEh
		db	0D5h,0CBh,0CDh,0D0h,0D1h, 58h
		db	 49h,0DAh, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h, 05h, 09h, 49h
		db	0D9h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0D4h, 85h,0C6h,0D5h,0CAh
		db	0CBh,0CFh,0D0h,0D1h, 49h,0DAh
		db	 86h,0C5h,0D6h,0CBh,0CCh,0CEh
		db	 6Ch,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0CEh, 06h, 0Dh
		db	0D1h,0CAh,0DAh, 85h,0C5h,0D6h
		db	0CBh,0CCh,0D1h,0D4h, 86h,0C5h
		db	0CAh, 03h, 12h,0CAh,0D3h,0D9h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 6Dh
		db	0D0h,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0CEh,0CCh, 5Dh
		db	0CFh, 4Dh,0CDh,0D1h,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0D4h
		db	 86h,0C6h,0D3h, 69h,0D3h,0D9h
		db	 87h,0C5h,0D6h,0CBh,0CCh, 6Dh
		db	0D0h,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh, 07h, 0Eh,0D0h
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0D4h, 88h,0C6h, 02h
		db	 13h,0DAh, 88h,0C5h,0D6h,0CBh
		db	0CCh, 6Dh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 07h
		db	 0Eh,0D0h,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0D4h, 95h
		db	0C5h,0D6h,0CBh,0CCh, 6Dh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0CFh, 7Dh,0D0h
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0C3h, 60h,0C2h, 40h
		db	0C2h, 50h,0C2h, 60h, 41h, 40h
		db	 81h,0C5h,0D6h,0CBh,0CCh,0CEh
		db	 6Eh,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh, 07h, 0Fh,0CEh,0D0h
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0DAh, 95h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h, 02h, 12h
		db	 49h,0DAh, 85h,0C5h,0D6h, 07h
		db	 12h,0CBh,0CCh,0D0h,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	 0Ah, 07h,0DAh, 8Ah,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h, 59h, 01h
		db	 13h,0D9h, 85h,0C6h,0D5h, 59h
		db	 02h, 13h, 49h,0CBh,0CCh,0D0h
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D1h, 0Ah, 0Ah, 56h,0DAh
		db	 87h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh, 01h, 13h,0DBh, 07h
		db	 28h,0C6h, 02h, 13h,0DAh,0D7h
		db	0C5h,0D6h,0CAh,0CBh,0CCh,0D0h
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D1h, 0Ch, 09h,0CAh,0C7h
		db	0D8h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0DAh, 02h, 28h
		db	 0Dh, 2Ah,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 0Bh, 0Dh,0D1h, 59h
		db	0D9h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 02h, 28h
		db	 0Dh, 2Ah,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 0Bh, 0Eh,0CDh,0D0h
		db	0D1h,0CAh,0DAh, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 02h, 28h, 0Dh, 2Ah,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh,0CEh,0CDh
		db	 06h, 0Eh,0CCh, 5Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C4h, 56h,0D8h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh, 0Ch, 0Eh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C4h,0D5h,0CAh,0C9h
		db	0CAh,0C7h,0D8h, 85h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh, 0Ch, 0Eh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D1h
		db	 49h,0DAh, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CFh, 6Dh,0CFh, 07h
		db	 0Eh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CDh,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CAh,0D2h,0CBh
		db	 5Eh, 4Dh, 07h, 0Fh,0D1h,0D3h
		db	0D9h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh, 4Eh,0D1h
		db	0D4h, 85h,0C5h,0D6h, 49h, 02h
		db	 12h,0CBh,0CCh,0D0h,0D1h, 06h
		db	 12h,0CAh,0D9h,0D7h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CAh, 01h, 12h,0CAh,0DAh, 85h
		db	0C5h,0D6h, 49h, 02h, 13h,0CAh
		db	0CBh,0D1h, 08h, 0Ah,0C7h,0D8h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h, 59h,0D3h,0D9h, 85h
		db	0C6h, 02h, 13h,0DAh,0D7h,0C5h
		db	0CAh,0CBh,0D1h, 06h, 13h,0D6h
		db	0CBh,0D1h,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C6h, 03h, 13h
		db	0D9h, 81h, 8Bh,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0D0h,0D1h,0CAh
		db	0D4h, 8Ch, 8Bh,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0D0h,0D1h,0CAh
		db	0D4h, 8Ch, 8Bh,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0D0h,0D1h,0CAh
		db	0D4h, 8Ch, 56h,0D8h, 87h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C4h, 05h
		db	 07h, 59h,0DAh, 87h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0DAh
		db	 85h,0C5h,0D6h,0CBh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h, 79h
		db	 48h,0CAh,0C7h,0D8h, 86h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CAh, 68h,0CDh,0D1h, 49h,0D4h
		db	 86h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh, 6Ch,0D0h,0D1h
		db	 49h,0D4h, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0CDh,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh,0CEh,0CDh
		db	0CEh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0CEh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 04h, 28h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 05h, 28h,0C5h,0D6h,0CBh
		db	 4Eh,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0D1h,0D4h, 04h
		db	 28h,0C5h,0D6h, 49h,0DAh, 05h
		db	 28h,0C5h,0D6h,0CAh, 01h, 12h
		db	 49h,0DAh, 04h, 28h,0C5h,0D6h
		db	0CBh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0CEh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C6h
		db	0D6h, 49h,0DAh, 04h, 28h,0C6h
		db	0D5h,0CAh,0D3h,0D9h, 05h, 28h
		db	0C6h, 01h, 13h, 59h,0D3h,0D9h
		db	 04h, 28h,0C5h,0D6h,0CBh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0EAh,0C6h, 01h
		db	 13h,0D9h, 05h, 28h,0C6h,0D3h
		db	0DBh, 08h, 28h,0C6h, 02h, 13h
		db	0D9h, 05h, 28h,0C5h,0D6h,0CBh
		db	0D0h,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh, 5Dh, 4Fh,0D1h
		db	0CAh,0D4h, 85h, 22h, 2Ah,0C5h
		db	0D6h,0CBh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 85h
		db	 22h, 2Ah,0C5h,0D6h,0CBh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 85h, 22h, 2Ah,0C5h
		db	0D6h,0CBh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0EAh,0C4h, 05h, 07h,0D8h, 06h
		db	 29h,0C4h, 09h, 07h,0D8h, 05h
		db	 29h,0C5h,0D6h,0CBh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0EAh,0C5h,0C7h, 79h
		db	0C7h,0D8h, 04h, 29h,0C4h,0D5h
		db	 09h, 0Ah,0C7h,0D9h, 04h, 29h
		db	0C5h,0D6h,0CBh,0D0h,0D1h,0CAh
		db	0DBh, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C4h,0D6h,0CAh, 68h, 49h
		db	0DAh, 04h, 29h,0C5h,0D6h,0CAh
		db	 07h, 09h, 49h,0DAh, 04h, 29h
		db	0C5h,0D6h,0CBh,0D0h,0D1h,0CAh
		db	0DAh, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CAh,0CBh, 4Ch
		db	0D1h, 49h,0D4h, 04h, 29h,0C5h
		db	0D6h,0CBh, 07h, 0Dh,0D1h,0CAh
		db	0DBh, 04h, 29h,0C5h,0D6h,0CBh
		db	0D0h,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0CEh,0CDh,0CEh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CDh, 4Dh,0CDh
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 05h, 0Eh,0D0h,0D1h
		db	0CAh,0D4h, 04h, 29h,0C5h,0D6h
		db	0CBh,0D0h,0D1h,0CAh,0DAh, 85h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0CEh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 05h, 0Eh,0D0h,0D1h,0CAh
		db	0D4h, 04h, 29h,0C5h,0D6h,0CBh
		db	0D1h, 49h,0DBh, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0CEh,0CCh, 4Dh,0CDh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 04h, 29h,0C5h
		db	0D6h,0CBh,0D1h,0CAh,0D3h,0D9h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 05h, 0Eh,0D0h,0D1h
		db	0CAh,0D4h, 04h, 29h,0C5h,0D6h
		db	 49h,0D3h,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0D0h,0D1h
		db	0CAh,0DAh, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 05h
		db	 0Eh,0D0h,0D1h,0CAh,0D4h, 04h
		db	 29h,0C5h,0D6h, 01h, 13h,0D9h
		db	 87h,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0CEh,0D0h,0D1h,0CAh,0DBh, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 6Dh,0D0h,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 04h, 29h,0C6h
		db	0D3h,0DAh, 89h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0CFh,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh, 05h, 0Eh
		db	0D0h,0D1h,0CAh,0D4h, 04h, 29h
		db	 0Bh, 2Ah,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0D0h,0D1h, 49h,0DAh, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 05h, 0Eh,0D0h,0D1h
		db	0CAh,0D4h, 04h, 29h, 0Bh, 2Ah
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0D0h
		db	0D1h,0CAh,0D3h,0D9h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	 4Bh, 7Dh,0D0h,0D1h,0CAh,0D4h
		db	 04h, 29h, 0Bh, 2Ah,0C5h,0D6h
		db	0CBh,0CCh,0D0h, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 87h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 05h
		db	 0Eh,0D0h,0D1h,0CAh,0D4h, 04h
		db	 29h, 0Bh, 2Ah,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0D0h,0D1h,0CAh,0D4h
		db	 87h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh, 05h, 0Eh,0D0h
		db	0D1h,0CAh,0D4h, 04h, 29h, 0Bh
		db	 2Ah,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0D0h,0D1h,0CAh,0D4h, 87h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 05h, 0Eh,0D0h,0D1h,0CAh
		db	0DAh, 04h, 29h, 0Bh, 2Ah,0C5h
		db	0D6h,0CBh,0CCh, 5Dh,0D0h,0D1h
		db	0CAh,0D4h, 87h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 05h
		db	 0Eh,0D0h,0D1h,0CAh, 07h, 07h
		db	0D8h, 89h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0D0h,0D1h,0CAh,0D4h, 87h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0CFh, 5Dh,0D0h
		db	0D1h, 08h, 0Ah, 46h,0DAh, 87h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0D0h
		db	0D1h,0CAh,0DAh, 87h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 05h, 0Eh,0D0h,0D1h, 08h, 09h
		db	 49h,0C7h,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0D0h,0D1h,0CAh
		db	0D4h, 87h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh, 06h, 0Eh
		db	 09h, 0Dh,0D1h,0C9h,0CAh,0C7h
		db	0D8h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0D0h,0D1h,0CAh,0DBh, 87h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh, 05h, 0Fh, 0Bh, 0Eh, 4Ch
		db	0D1h,0CAh,0DAh, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0D0h,0D1h,0CAh
		db	0D4h, 87h,0C5h,0D6h,0CBh,0CCh
		db	0CEh, 4Fh,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CAh, 04h, 12h,0CBh
		db	0CCh, 09h, 0Eh,0D0h, 4Dh,0CDh
		db	0D1h,0DBh, 85h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 87h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C6h,0D6h, 05h, 0Ah,0CBh,0CCh
		db	 6Dh,0CCh, 07h, 0Eh,0D0h,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0D0h,0D1h,0CAh,0DAh, 87h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C6h, 03h
		db	 13h, 49h,0CBh, 0Eh, 0Fh,0D1h
		db	0DAh, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0D0h,0D1h,0CAh,0D4h, 87h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 8Bh,0C5h,0D5h
		db	0CAh, 0Dh, 12h,0CBh,0D1h,0DAh
		db	 85h,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0D0h,0D1h,0CAh,0D4h, 87h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 8Bh,0C5h,0D6h, 0Eh
		db	 0Ah,0CBh,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh, 5Dh,0D0h,0D1h
		db	0CAh,0C7h,0D8h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 8Bh,0C6h, 0Dh, 13h, 49h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0D0h,0D1h, 49h
		db	0DAh, 86h,0C5h,0D6h,0CBh, 4Bh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 81h
		db	0C4h, 46h,0D8h, 95h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0CDh,0D1h
		db	0CAh,0DBh, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 81h,0C5h, 49h,0DAh, 95h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh, 5Dh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CFh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h,0C4h,0D6h,0CBh,0D1h,0DBh
		db	 95h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CAh,0CBh,0CCh, 4Eh
		db	0D1h,0CAh,0D4h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C4h, 05h, 07h
		db	0D8h, 87h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0CFh, 4Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CAh, 03h
		db	 12h, 49h,0DAh,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C5h,0D6h, 79h
		db	0C7h,0D8h, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h, 05h, 0Ah
		db	0D3h,0D9h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 86h,0C5h,0D6h,0CAh, 68h
		db	0CAh,0DAh, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C6h, 06h, 13h,0D9h
		db	 81h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 86h,0C5h,0D6h,0CAh,0CBh, 4Ch
		db	0D1h,0CAh,0DBh, 86h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0CCh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 90h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CDh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0C3h
		db	 40h, 41h, 50h,0C2h, 40h,0C2h
		db	0C1h,0C2h, 40h, 81h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 90h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0CEh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh, 5Dh,0CEh,0D0h
		db	0D1h,0CAh,0DAh, 86h,0C4h, 46h
		db	0D8h, 86h,0C5h,0D6h,0CBh,0D1h
		db	0C7h,0D8h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0CEh,0D0h,0D1h,0CAh,0C7h
		db	0D8h, 85h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0DBh
		db	 85h,0C4h,0C7h,0CAh,0C9h,0C7h
		db	0D8h, 85h,0C5h,0D6h,0CBh,0D1h
		db	0CAh,0DAh, 85h,0C5h,0D6h,0CBh
		db	0CCh,0CEh,0D0h,0CDh,0D1h,0CAh
		db	0DAh, 85h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0CEh,0D0h,0CEh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CDh,0D1h,0DAh, 85h,0C5h,0D6h
		db	0CBh,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CDh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D0h
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0CEh,0D0h,0CFh,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	0E4h, 84h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D0h,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh,0CEh,0D0h,0D1h, 49h
		db	0DBh, 85h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	0E5h, 84h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D0h,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh,0CEh,0D0h,0D1h,0CAh
		db	0D3h,0D9h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h,0E6h, 84h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D0h,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h,0E7h, 84h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D0h,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0CEh,0D0h,0D1h
		db	0CAh,0DAh, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h,0EEh, 84h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D0h,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D0h,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D0h
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D0h,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0D1h,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0CEh
		db	0D0h,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0D4h, 85h
		db	0C5h,0D6h,0CBh,0D0h,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh,0CEh
		db	0CFh,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh, 5Dh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh,0D1h,0C7h,0DAh, 84h
		db	0C5h,0D6h,0CBh,0CFh,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CFh,0D0h
		db	0D1h, 49h,0D4h, 86h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh,0D0h, 4Dh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh,0D1h,0CAh,0D4h, 84h
		db	0C5h,0D6h,0CBh,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CAh, 02h, 12h
		db	 49h,0DAh, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0CDh,0D1h,0D4h, 84h,0C5h,0D6h
		db	0CBh,0D1h,0CAh,0D4h, 85h,0C6h
		db	 05h, 13h,0DBh, 87h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0D4h, 84h,0C5h
		db	0D6h,0CBh,0D1h,0D3h,0D9h, 94h
		db	0C5h,0D6h,0CBh,0D1h,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0CEh
		db	0D0h,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0D4h
		db	 84h,0C5h,0D6h,0CBh,0D1h,0DAh
		db	 95h,0C5h,0D6h,0CBh,0D1h,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh, 5Dh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh,0CFh,0D1h
		db	0D4h, 84h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 95h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	0CAh,0D4h, 84h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 95h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0D3h,0D9h, 84h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 95h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 95h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 86h,0C4h, 05h
		db	 07h,0D8h, 87h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0DAh, 86h,0C5h,0D6h, 79h
		db	0C7h,0DAh, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CFh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C5h,0D6h,0CAh
		db	 58h, 49h,0DBh, 86h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CAh
		db	 01h, 12h,0DAh, 85h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 86h,0C5h,0D6h
		db	0CAh,0CBh,0CCh,0CDh,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h, 49h,0D3h,0D9h
		db	 85h,0C5h,0D6h,0CAh,0D3h,0D9h
		db	 86h,0C5h,0D6h,0CBh,0CDh,0CEh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh, 5Dh,0CEh,0D0h
		db	0D1h,0CAh,0DAh, 85h,0C6h, 02h
		db	 13h,0DBh, 86h,0C6h, 01h, 13h
		db	0DBh, 87h,0C5h,0D6h,0CBh,0CCh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0D1h,0D4h, 85h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0CEh
		db	0D0h,0D1h,0CAh,0D4h, 9Bh,0C5h
		db	0D6h,0CBh,0CCh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C5h,0D6h,0CBh
		db	0CCh, 5Dh,0CEh,0D0h,0D1h,0CAh
		db	0C3h, 40h, 41h, 50h,0C2h, 40h
		db	0C2h,0C1h,0C2h, 40h, 41h, 05h
		db	 01h,0C2h, 40h, 81h,0C5h,0D6h
		db	0CBh,0CCh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 85h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0CEh,0D0h,0D1h,0CAh,0D4h
		db	 9Bh,0C5h,0D6h,0CBh,0CCh,0CEh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 85h,0C5h
		db	0D6h,0CBh,0CCh, 5Dh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 85h,0C4h, 56h
		db	0DAh, 91h,0C5h,0D6h,0CBh,0CCh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0D1h,0DAh, 85h
		db	0C5h,0D6h,0CBh,0CCh,0D0h, 4Dh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 84h
		db	0C4h,0D5h, 58h, 66h,0D8h, 8Dh
		db	0C5h,0D6h,0CBh,0CCh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0CEh,0CFh,0D1h
		db	0CAh,0D4h, 84h,0C5h,0D6h,0CBh
		db	 4Ch,0D1h, 48h,0CAh,0DAh, 8Dh
		db	0C5h,0D6h,0CBh,0CCh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0D0h,0D1h, 49h
		db	0DAh, 84h,0C5h,0D6h,0CBh,0CCh
		db	0CEh, 4Ch,0D1h,0CAh,0D4h, 8Dh
		db	0C5h,0D6h,0CBh,0CCh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 85h,0C5h,0D6h
		db	0CBh, 6Eh, 01h, 12h, 49h,0DBh
		db	 84h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 8Dh,0C5h
		db	0D6h,0CBh,0CCh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 85h,0C6h,0D5h,0CAh
		db	 03h, 12h, 49h, 01h, 13h,0D9h
		db	 84h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 8Dh,0C5h
		db	0D6h,0CBh,0CCh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C5h,0D5h, 69h
		db	 01h, 13h,0D9h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C4h, 66h,0DAh,0C4h
		db	 49h,0CBh,0CCh,0CEh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C6h, 04h, 13h
		db	 89h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h, 05h, 0Ah,0CBh,0CDh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0D1h,0DBh, 8Ch, 89h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CAh, 68h,0CBh,0CDh, 5Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	 49h,0D9h, 8Ch, 89h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh, 7Ch
		db	 6Dh,0D0h,0D1h,0CAh,0DAh, 86h
		db	0C5h,0D6h,0CAh,0D3h,0DAh, 8Ch
		db	 89h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 7Dh,0CDh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C6h
		db	 01h, 13h,0DBh, 8Dh, 89h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 07h, 0Eh,0D0h,0D1h,0CAh
		db	0D4h, 97h, 50h,0C2h, 60h, 81h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0CFh, 5Dh,0D0h
		db	0CEh,0D0h,0D1h,0CAh,0C3h, 40h
		db	0C2h, 60h, 41h, 07h, 01h,0C2h
		db	 40h, 51h, 89h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 08h
		db	 0Fh,0D1h,0CAh,0DAh, 97h, 89h
		db	0C5h,0D6h,0CBh, 4Eh,0CEh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D1h, 03h, 12h,0CAh
		db	 01h, 13h,0D2h, 49h, 56h,0D7h
		db	0D8h, 88h,0C4h, 66h,0D8h, 85h
		db	 89h,0C6h,0D3h,0CAh,0D2h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D1h, 69h
		db	0D4h, 82h,0C5h,0D6h,0CAh,0CBh
		db	0D0h,0D1h, 76h,0DAh, 84h,0C5h
		db	0D6h, 59h,0C7h,0D8h, 84h, 8Ah
		db	0C6h,0D3h,0CAh,0CBh,0CCh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D1h,0CAh, 02h, 13h
		db	0D8h, 82h,0C5h,0D6h,0CBh,0D1h
		db	0CAh, 05h, 13h,0D8h, 84h,0C5h
		db	0D6h,0CBh,0CDh,0D1h,0CAh,0DAh
		db	 84h, 8Bh,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0CAh,0DAh
		db	 85h,0C5h,0D6h,0CBh,0D1h,0CAh
		db	0D4h, 8Ah,0C5h,0D6h,0CBh,0D0h
		db	0D1h,0CAh,0D4h, 84h, 8Bh,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D1h,0CAh,0D4h, 8Ah,0C5h
		db	0D6h,0CBh,0D0h,0D1h,0CAh,0D4h
		db	 84h, 8Bh,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D1h,0CAh
		db	0DBh, 8Ah,0C5h,0D6h,0CBh,0D0h
		db	0D1h,0CAh,0D4h, 84h,0C4h, 56h
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D1h,0CAh
		db	0D4h, 86h,0C4h, 56h, 49h,0CBh
		db	0D0h,0D1h,0CAh,0D4h, 84h,0C5h
		db	0D6h,0CBh,0D1h,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CAh, 58h,0CBh,0D0h,0D1h
		db	0CAh,0D4h, 84h,0C5h,0D6h,0CBh
		db	0D1h,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D1h,0CAh
		db	0D4h, 85h,0C5h,0D6h,0CBh,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	 6Ch,0D0h,0D1h,0CAh,0D4h, 84h
		db	0C5h,0D6h,0CBh,0D1h,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0D0h
		db	0D1h,0CAh,0D4h, 84h,0C5h,0D6h
		db	0CBh,0D1h,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0D1h
		db	0CAh,0D4h, 85h,0C5h,0D6h,0CBh
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 5Dh,0D0h,0D1h,0CAh
		db	0D4h, 84h,0C5h,0D6h,0CBh,0D1h
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh,0D1h,0CAh,0D4h
		db	 85h,0C5h,0D6h,0CBh,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 5Dh,0D0h,0D1h,0CAh,0D4h, 84h
		db	0C5h,0D6h,0CBh,0D1h,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0CEh,0CCh
		db	0CEh,0D0h,0D1h,0CAh,0D4h, 84h
		db	0C5h,0D6h,0CBh,0D1h,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0D1h,0CAh,0D4h, 85h,0C5h
		db	0D6h,0CBh,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 5Dh,0D0h
		db	0D1h,0CAh,0D4h, 84h,0C5h,0D6h
		db	0CBh,0D1h,0DBh, 81h,0C4h, 76h
		db	0D6h,0CBh,0CCh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 5Dh,0D0h,0D1h
		db	0CAh,0D4h, 84h,0C5h,0D6h,0CBh
		db	0D1h,0DAh,0D7h,0C5h, 68h,0CBh
		db	0CCh,0CDh,0CEh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	0D1h,0CAh,0D4h, 85h,0C5h,0D6h
		db	0CBh,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 5Dh,0D0h,0D1h
		db	0CAh,0D4h, 84h, 07h, 00h, 06h
		db	 0Eh, 00h, 03h, 17h, 00h, 03h
		db	 1Ch, 00h, 3Fh, 1Fh, 00h, 3Fh
		db	 2Dh, 00h, 19h, 40h, 00h, 3Fh
		db	 5Ah, 00h, 05h,0BAh, 00h, 04h
		db	0C3h, 00h, 31h,0FFh,0FFh, 1Ah
		db	 00h, 27h, 1Dh, 00h, 26h, 20h
		db	 00h, 24h,0FFh,0FFh,0FFh,0FFh
		db	 01h, 00h, 15h,0C0h, 07h, 0Dh
		db	 01h,0FFh, 00h,0FFh,0FFh,0FFh
		db	 31h, 00h, 3Bh,0C2h, 13h, 67h
		db	 00h, 21h, 00h,0FFh,0FFh,0FFh
		db	 53h, 00h, 01h,0C2h, 14h, 32h
		db	 00h, 08h, 00h,0FFh,0FFh,0FFh
		db	 5Ch, 00h, 29h,0C1h, 14h, 4Ch
		db	 00h, 08h, 00h,0FFh,0FFh,0FFh
		db	 5Eh, 00h, 11h,0C1h, 13h, 95h
		db	 00h, 3Ah, 00h,0FFh,0FFh,0FFh
		db	 68h, 00h, 35h,0C4h, 13h, 6Dh
		db	 00h, 2Eh, 00h,0FFh,0FFh,0FFh
		db	 78h, 00h, 16h,0C3h, 13h, 7Fh
		db	 00h, 2Eh, 00h,0FFh,0FFh,0FFh
		db	 7Fh, 00h, 07h, 80h, 0Eh, 0Bh
		db	 00h, 29h, 00h,0FFh,0FFh,0FFh
		db	 98h, 00h, 06h, 80h, 07h, 08h
		db	 00h,0FFh, 00h,0FFh,0FFh,0FFh
		db	0A5h, 00h, 2Bh, 41h, 13h,0ABh
		db	 00h, 20h, 00h, 34h, 00h, 20h
		db	0B0h, 00h, 2Bh,0C1h, 14h, 65h
		db	 00h, 38h, 00h,0FFh,0FFh,0FFh
		db	0C7h, 00h, 21h, 01h, 16h, 15h
		db	 00h, 0Eh, 00h, 34h, 00h, 10h
		db	0CAh, 00h, 3Ch,0C2h, 13h, 09h
		db	 00h, 37h, 00h,0FFh,0FFh,0FFh
		db	0CDh, 00h, 2Dh,0C3h, 14h, 7Fh
		db	 00h, 08h, 00h,0FFh,0FFh,0FFh
		db	0FFh,0FFh, 32h, 00h,0FFh, 13h
		db	0C0h,0FFh,0FFh,0FFh,0FFh, 34h
		db	 00h, 20h,0A7h,0DCh,0C1h, 13h
		db	0FFh,0FFh, 34h, 00h, 10h,0BFh
		db	0DCh, 81h, 16h,0FFh,0FFh, 34h
		db	 00h, 08h,0D8h,0DDh, 00h,0FFh
		db	0E3h,0DDh,0FFh,0FFh,0FFh,0FFh
		db	 34h, 00h, 04h, 28h,0DEh, 00h
		db	0FFh, 33h,0DEh,0FFh,0FFh,0FFh
		db	0FFh, 34h, 00h, 02h, 48h,0DEh
		db	 00h,0FFh, 53h,0DEh,0FFh,0FFh
		db	0FFh,0FFh, 34h, 00h, 01h,0C8h
		db	0DEh, 00h,0FFh,0D3h,0DEh,0FFh
		db	0FFh,0FFh,0FFh, 35h, 00h, 80h
		db	 08h,0DFh, 00h,0FFh, 13h,0DFh
		db	0FFh,0FFh,0FFh,0FFh, 35h, 00h
		db	 40h, 28h,0DFh, 00h,0FFh, 33h
		db	0DFh,0FFh,0FFh,0FFh,0FFh,0FFh
		db	0FFh, 15h,0AFh, 02h, 12h
		db	'Cavern of Caliente'
		db	 15h, 00h, 06h, 0Ch, 0Ch, 04h
		db	 00h, 07h,0FFh, 02h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 04h, 00h
		db	 07h, 02h, 00h, 04h, 00h, 09h
		db	0FFh, 03h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 04h, 00h, 09h, 03h
		db	 00h, 0Bh, 00h, 2Dh,0FFh, 00h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 0Bh, 00h, 2Dh, 00h, 00h, 0Bh
		db	 00h, 2Fh,0FFh, 01h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 0Bh, 00h
		db	 2Fh, 01h, 00h, 11h, 00h, 07h
		db	0FFh, 02h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 11h, 00h, 07h, 02h
		db	 00h, 11h, 00h, 09h,0FFh, 03h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 11h, 00h, 09h, 03h, 00h, 14h
		db	 00h, 17h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 14h, 00h
		db	 17h, 04h, 00h, 17h, 00h, 35h
		db	0FFh, 73h, 00h, 00h, 20h, 00h
		db	 19h, 00h, 34h, 00h, 08h, 00h
		db	 00h, 24h, 00h, 17h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 24h, 00h, 17h, 04h, 00h, 30h
		db	 00h, 2Fh,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 30h, 00h
		db	 2Fh, 04h, 00h, 3Dh, 00h, 3Bh
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 3Dh, 00h, 3Bh, 00h
		db	 00h, 3Dh, 00h, 3Dh,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 3Dh, 00h, 3Dh, 01h, 00h, 3Eh
		db	 00h, 0Eh,0FFh, 76h, 00h, 00h
		db	 20h, 00h, 00h, 00h, 34h, 00h
		db	 04h, 00h, 00h, 45h, 00h, 03h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 45h, 00h, 03h, 04h
		db	 00h, 47h, 00h, 2Fh,0FFh, 73h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 34h, 00h, 02h, 00h, 00h, 53h
		db	 00h, 35h,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 53h, 00h
		db	 35h, 00h, 00h, 53h, 00h, 37h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 53h, 00h, 37h, 01h
		db	 00h, 55h, 00h, 1Ch,0FFh, 00h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 55h, 00h, 1Ch, 00h, 00h, 55h
		db	 00h, 1Eh,0FFh, 01h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 55h, 00h
		db	 1Eh, 01h, 00h, 73h, 00h, 37h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 73h, 00h, 37h, 04h
		db	 00h, 8Ah, 00h, 37h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 8Ah, 00h, 37h, 04h, 00h, 95h
		db	 00h, 2Dh,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 95h, 00h
		db	 2Dh, 04h, 00h,0A0h, 00h, 1Eh
		db	0FFh, 76h, 00h, 00h, 20h, 00h
		db	 00h, 00h, 34h, 00h, 01h, 00h
		db	 00h,0A1h, 00h, 11h,0FFh, 02h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	0A1h, 00h, 11h, 02h, 00h,0A1h
		db	 00h, 13h,0FFh, 03h, 00h, 00h
		db	 10h, 00h, 00h, 00h,0A1h, 00h
		db	 13h, 03h, 00h,0B6h, 00h, 1Eh
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0B6h, 00h, 1Eh, 04h
		db	 00h,0C1h, 00h, 23h,0FFh, 73h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 35h, 00h, 80h, 00h, 00h,0C5h
		db	 00h, 09h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C5h, 00h
		db	 09h, 04h, 00h,0CCh, 00h, 09h
		db	0FFh, 73h, 00h, 05h, 20h, 00h
		db	 00h, 00h, 35h, 00h, 40h, 00h
		db	 00h,0FFh,0FFh

_338MP70	endp

seg_a		ends



		end	start
