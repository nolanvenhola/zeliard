
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR3_20	                                 лл
;лл					                                 лл
;лл      Created:   16-Feb-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_20		proc	far

start:
		nop
		sbb	[bx+si],ax
		add	[bx+di],ch
		db	0D6h,0F0h, 00h, 55h,0D5h, 5Dh
		db	0D5h, 5Fh,0D5h, 7Dh,0D5h,0C7h
		db	0D5h, 14h,0D6h, 2Eh,0D6h, 01h
		db	 1Ah, 00h, 10h, 0Ah, 00h, 00h
		db	 55h,0D5h, 87h,0C4h, 45h,0C7h
		db	0CAh, 8Bh,0C4h, 07h, 06h,0C7h
		db	 43h,0C7h,0C6h,0C4h,0C7h, 65h
		db	0C4h, 85h,0C5h, 05h, 06h,0C8h
		db	 87h, 87h,0C4h, 55h,0C7h, 8Bh
		db	0C5h, 06h, 06h,0C9h, 91h,0CFh
		db	0CEh,0C4h, 45h,0C3h,0C7h,0C6h
		db	0C9h, 86h,0C7h, 86h,0C4h, 45h
		db	0C7h,0CAh, 8Bh, 06h, 06h,0C7h
		db	 92h,0CFh,0CEh,0C3h, 75h, 85h
		db	 42h,0C6h, 86h,0C4h, 65h,0C7h
		db	 8Ah, 75h,0C3h, 45h,0C7h,0C1h
		db	0C2h, 40h,0C2h,0C1h,0C2h, 40h
		db	0C2h, 86h,0CFh,0CEh,0CDh, 75h
		db	0C8h, 85h,0C4h,0C6h,0C6h,0C8h
		db	 85h,0C4h, 45h,0C7h,0CAh, 8Bh
		db	0C3h, 05h, 06h, 92h,0CFh,0CEh
		db	0CDh,0C3h, 45h,0C4h,0C8h, 86h
		db	 43h, 45h,0C8h, 84h,0C4h, 55h
		db	0C7h, 8Bh,0C4h, 65h,0C7h,0C6h
		db	 41h,0C1h,0C2h,0C1h,0C2h,0C1h
		db	 41h, 89h,0CFh,0CEh,0CDh,0C4h
		db	 65h,0C7h,0C9h, 84h,0C4h,0C6h
		db	 55h, 84h,0C4h, 55h,0C7h, 8Bh
		db	0C4h, 65h,0C7h,0C8h, 92h,0CFh
		db	0CEh,0CDh,0C4h, 45h,0C4h,0C6h
		db	0C9h, 85h,0C4h,0C6h,0C5h,0C6h
		db	0C8h, 84h,0C4h, 45h,0C7h, 8Ch
		db	0C4h, 75h,0C8h, 85h,0C4h,0C6h
		db	0C3h,0C6h,0C8h, 88h,0CFh,0CEh
		db	0CDh,0C5h, 55h,0C8h, 86h,0C4h
		db	0C6h,0C6h,0C8h, 85h,0C4h, 45h
		db	0C7h, 8Ch,0C4h,0C6h,0C4h, 65h
		db	0C8h, 84h,0C4h, 45h,0C8h, 89h
		db	0CFh,0CEh,0CDh, 65h,0C7h,0C8h
		db	 85h,0C5h,0C6h,0C6h, 86h,0C4h
		db	 45h, 8Dh,0C4h, 06h, 06h, 84h
		db	0C4h, 45h,0C8h, 89h,0CFh,0CEh
		db	0CDh, 65h, 87h,0C3h,0C6h, 45h
		db	0C8h, 84h,0C4h,0C6h,0C7h, 8Dh
		db	0C4h, 75h,0C8h, 85h,0C4h,0C6h
		db	0C8h, 8Ah,0CFh,0CEh,0CDh, 05h
		db	 06h,0C9h, 84h,0C4h,0C6h,0C3h
		db	0C6h, 85h,0C4h, 45h,0C7h, 8Ch
		db	0C4h, 65h,0C8h, 86h,0C4h, 45h
		db	0C8h, 89h,0CFh,0CEh,0CDh,0C3h
		db	 45h,0C3h,0C6h,0C8h, 85h,0C4h
		db	0C6h, 55h,0C8h, 83h,0C4h,0C6h
		db	0C7h, 8Dh,0C4h, 55h,0C7h,0C6h
		db	0C8h, 85h,0C4h,0C3h, 45h, 89h
		db	0CFh,0CEh,0CDh,0C4h, 55h, 87h
		db	0C4h,0C6h, 45h,0C8h, 84h,0C4h
		db	 55h,0C7h, 8Ah,0CBh, 06h, 06h
		db	 85h,0C4h, 55h,0C9h, 88h,0CFh
		db	0CEh,0CDh,0C4h, 65h,0C7h,0C9h
		db	 84h,0C5h,0C6h,0C6h,0C8h, 85h
		db	0C4h, 45h,0C7h, 8Ah,0CBh, 75h
		db	0C8h,0C9h, 85h,0C3h,0C6h,0C3h
		db	 45h,0C8h, 88h,0CFh,0CEh,0CDh
		db	0C4h, 65h,0C8h,0C9h, 84h, 45h
		db	0C6h, 86h,0C4h,0C6h,0C7h,0CAh
		db	 89h,0CBh,0C4h, 05h, 06h,0C9h
		db	 85h,0C4h, 55h,0C8h,0C9h, 88h
		db	0CFh,0CEh,0CDh,0C4h, 55h,0C3h
		db	0C6h, 85h, 45h,0C8h, 86h,0C4h
		db	 45h,0C5h,0C3h,0C6h, 86h,0CBh
		db	0C4h, 07h, 06h,0C8h, 84h,0C4h
		db	 55h,0C8h, 89h,0CFh,0CEh,0CDh
		db	0C3h,0C6h,0C3h, 65h,0C8h, 83h
		db	0C3h,0C6h,0C6h, 47h, 84h,0C4h
		db	 05h, 06h, 85h,0C4h, 65h,0C4h
		db	 65h, 85h,0C4h, 45h,0C7h, 88h
		db	0C3h,0C6h, 52h, 05h, 06h,0C8h
		db	 84h,0C4h,0C6h, 45h, 85h,0C4h
		db	 65h,0C4h, 86h, 06h, 05h,0C4h
		db	0C5h,0C8h, 85h,0C4h, 55h, 85h
		db	0C3h, 75h,0C5h, 65h,0C5h, 47h
		db	 85h, 43h, 55h, 84h,0C4h, 75h
		db	 95h,0C4h, 65h,0C9h, 83h,0C4h
		db	 0Bh, 06h,0C8h, 85h,0C4h,0C6h
		db	0C5h,0C6h,0C8h, 84h
		db	'Ce@A@A`Q@'
		db	0C2h,0C1h,0C2h, 81h,0C4h, 65h
		db	0C9h, 83h,0C4h,0C6h,0C5h, 55h
		db	 54h, 55h,0C7h, 86h,0C4h,0C6h
		db	0C6h,0C8h, 85h,0C4h, 75h,0C8h
		db	 94h, 43h, 45h,0C8h, 84h,0C4h
		db	 65h,0C8h, 83h,0C5h, 55h,0C4h
		db	0C6h,0C8h, 83h,0C4h,0C6h,0C6h
		db	0C8h, 85h,0C4h, 65h,0C8h, 86h
		db	 08h, 03h,0C8h, 85h,0C4h, 45h
		db	0C7h,0C8h, 84h, 44h, 45h,0C7h
		db	 85h,0C4h, 65h,0C9h, 83h,0C4h
		db	0C6h, 45h, 85h,0C5h, 65h,0C8h
		db	 86h,0C4h, 07h, 06h,0C7h, 85h
		db	0C5h, 55h, 8Fh,0C4h, 55h,0C7h
		db	0C8h, 83h, 43h,0C8h, 86h,0C3h
		db	 45h,0C3h, 45h,0C8h, 85h,0C4h
		db	 09h, 06h,0C8h, 83h,0C3h, 55h
		db	0C1h, 41h, 50h, 41h, 50h,0C2h
		db	0C1h,0C2h, 81h, 43h,0C3h,0C6h
		db	0C8h, 84h,0C4h,0C6h,0C6h,0C8h
		db	 85h,0C4h, 75h,0C8h, 85h,0C4h
		db	0C6h,0C7h, 82h,0C5h, 65h, 85h
		db	0C4h, 55h, 8Fh,0C4h, 45h, 47h
		db	 84h,0C4h,0C6h, 87h,0C4h, 05h
		db	 06h, 85h,0C4h,0C6h, 84h,0C4h
		db	 55h,0C8h, 84h,0C4h, 45h,0C8h
		db	 85h,0C3h,0C6h, 88h,0C4h, 55h
		db	0C8h, 84h,0C5h,0C4h, 87h,0C4h
		db	 75h,0C8h, 85h,0C4h,0C6h, 84h
		db	0C4h, 45h,0C7h, 85h,0C4h, 55h
		db	0C8h, 84h,0C4h, 45h,0C7h,0C8h
		db	 85h,0C4h, 45h,0C7h, 87h, 41h
		db	 40h, 41h, 81h,0C4h, 65h,0C8h
		db	 86h,0C4h,0C5h, 84h,0C4h, 55h
		db	 85h,0C4h, 65h,0CAh, 83h,0C4h
		db	 55h,0C8h, 85h,0C4h, 55h,0C1h
		db	 41h, 40h,0C2h,0C1h, 87h,0C4h
		db	 75h, 86h,0C3h,0C6h, 84h,0C4h
		db	 55h,0C8h, 84h,0C4h, 65h,0C8h
		db	 83h,0C4h, 65h, 85h,0C4h,0C6h
		db	0C4h,0C8h, 87h,0C6h,0C8h, 85h
		db	0C4h, 75h,0C8h,0C9h, 84h,0C4h
		db	0C7h, 84h,0C4h, 55h,0C7h, 84h
		db	0C4h, 55h,0C8h, 84h,0C3h, 55h
		db	0C7h,0C8h, 84h,0C4h, 55h,0C8h
		db	 84h,0C3h,0C6h,0C6h,0C7h,0C8h
		db	 83h,0C3h, 05h, 06h,0C8h, 85h
		db	0C4h,0C6h, 84h, 43h, 45h,0C7h
		db	0C8h, 83h,0C4h, 45h,0C7h,0C8h
		db	 84h,0C4h, 65h,0C8h,0C9h, 83h
		db	 44h,0C4h,0C8h, 85h,0C4h,0C6h
		db	 45h,0C7h,0C8h, 82h,0C4h, 55h
		db	0C3h, 45h, 86h,0C4h,0C6h, 84h
		db	0C4h, 55h, 48h, 83h, 43h, 45h
		db	0C8h, 84h,0C4h, 45h,0C4h,0C6h
		db	 8Eh,0C4h,0C6h, 08h, 06h,0C5h
		db	 55h, 86h,0C4h,0C6h, 84h,0C5h
		db	 45h,0C7h, 85h,0C4h, 55h, 85h
		db	0C4h, 65h,0C8h, 8Ch,0C3h, 45h
		db	 0Ch, 06h,0C7h,0C8h, 84h,0C4h
		db	0C6h, 84h,0C3h, 55h,0C8h, 84h
		db	0C5h, 45h,0C8h, 85h,0C4h, 55h
		db	 47h, 8Ah, 42h, 55h, 0Dh, 06h
		db	 85h,0C4h,0C5h, 84h,0C4h, 65h
		db	 84h, 65h,0C7h, 84h,0C4h, 55h
		db	0C7h,0C8h, 8Ah, 54h, 45h, 45h
		db	0C3h,0C4h, 0Ah, 06h,0C8h, 83h
		db	0C5h,0C7h, 84h,0C4h, 45h,0C8h
		db	 85h, 75h,0C8h, 83h,0C4h, 65h
		db	0C8h, 8Bh,0CFh,0CEh,0C5h,0C6h
		db	 05h, 06h,0C4h, 07h, 06h, 8Ah
		db	0C4h, 55h, 85h,0C3h, 55h,0C8h
		db	 84h, 43h, 65h,0C7h, 8Ah,0CFh
		db	0CEh,0C4h,0C6h, 75h,0C4h, 82h
		db	0C5h, 06h, 06h, 89h, 65h,0C7h
		db	0C8h, 83h,0C4h, 55h,0C8h, 84h
		db	0C4h, 55h,0C5h,0C6h,0C8h, 8Ah
		db	0CFh,0CEh,0C4h,0C6h, 65h,0C7h
		db	 84h,0C4h, 65h,0C7h, 8Ah,0C4h
		db	 55h,0C8h, 84h,0C4h, 45h,0C8h
		db	0CAh, 84h,0C5h, 65h,0C8h, 8Bh
		db	0CFh,0CEh,0C4h,0C6h, 65h,0C7h
		db	 84h,0C5h,0C6h,0C4h, 55h,0C8h
		db	 89h,0C4h, 55h,0C8h, 84h,0C4h
		db	 45h,0C7h,0CAh, 84h, 65h,0C7h
		db	0C8h, 8Bh,0CFh,0CEh,0C4h,0C6h
		db	 55h,0C7h, 86h,0C4h, 55h, 8Bh
		db	 55h,0C7h, 85h,0C4h, 65h,0C8h
		db	 83h, 55h, 47h, 8Ch,0CFh,0CEh
		db	0C4h,0C6h, 65h,0C7h,0C8h, 84h
		db	0C4h, 45h,0C7h,0C8h, 8Ah, 75h
		db	0C8h, 83h, 43h, 55h,0CAh, 83h
		db	0C3h, 45h,0C7h,0C8h, 8Ch,0CFh
		db	0CEh,0C4h,0C6h, 65h,0C8h, 85h
		db	0C4h, 45h,0C8h, 8Bh,0C3h, 65h
		db	 84h,0C4h, 55h,0C8h, 84h,0C4h
		db	 65h,0C8h, 8Bh,0CFh,0CEh,0C4h
		db	0C6h, 55h,0C7h, 86h,0C5h,0C4h
		db	0C6h, 8Ch,0C4h, 55h, 49h, 83h
		db	0C4h, 45h,0C8h, 85h,0C4h, 55h
		db	0C7h, 8Ch,0CFh,0CEh,0C4h,0C6h
		db	 55h, 96h,0C4h, 55h,0C8h, 84h
		db	0C4h, 45h,0C8h, 85h,0C4h,0C3h
		db	 45h,0C8h, 8Ch,0CFh,0CEh,0C5h
		db	0C6h, 55h,0C7h, 50h, 51h, 50h
		db	 41h, 60h, 61h, 82h,0C4h, 45h
		db	0C7h, 85h,0C4h, 45h,0C8h,0CAh
		db	 84h,0C4h, 65h,0C8h, 8Bh,0CFh
		db	0CEh,0C3h,0C6h, 45h,0C4h, 96h
		db	0C4h, 55h,0C8h, 84h,0C4h, 55h
		db	0C8h, 84h,0C4h, 55h,0C3h,0C6h
		db	0C8h, 8Ah,0CFh,0CEh,0C4h,0C6h
		db	 55h, 87h,0C3h,0C6h,0C7h,0C8h
		db	 8Bh, 43h, 45h,0C8h, 84h,0C4h
		db	 55h, 85h,0C4h, 65h,0C8h, 8Bh
		db	0CFh,0CEh,0C4h,0C6h, 45h,0C3h
		db	0C9h, 86h,0C3h, 43h,0C7h,0C8h
		db	 8Ah,0C4h, 55h, 85h, 43h, 45h
		db	0C7h,0C8h, 83h,0C4h, 65h,0C8h
		db	 8Bh,0CFh,0CEh,0C4h,0C6h, 45h
		db	0C5h,0CAh, 86h,0C4h,0C6h,0C4h
		db	0C7h,0C8h, 8Ah,0C4h, 65h,0C8h
		db	 83h,0C4h, 55h,0CAh, 84h,0C4h
		db	 55h,0C7h, 8Ch,0CFh,0CEh,0C4h
		db	0C6h, 55h,0C7h, 86h, 43h, 45h
		db	0C8h, 89h,0C3h, 65h, 85h,0C4h
		db	 45h,0C8h,0CAh, 84h,0C4h, 55h
		db	0C8h, 8Ch,0CFh,0CEh,0C3h,0C6h
		db	 45h,0C7h, 87h,0C4h, 65h, 86h
		db	0C3h, 06h, 06h,0C8h, 84h,0C5h
		db	 65h, 84h,0C4h, 45h,0C7h,0C6h
		db	0C8h, 8Ah, 52h, 45h, 45h,0C3h
		db	0C7h,0C8h, 85h,0C4h, 65h, 86h
		db	0C4h, 06h, 06h,0C7h,0CAh, 83h
		db	 65h,0C8h, 84h,0C4h, 75h,0C8h
		db	 89h, 44h, 55h, 45h,0C4h, 87h
		db	0C4h, 45h,0C4h,0C7h, 86h,0C4h
		db	 07h, 06h,0C8h, 83h, 45h,0C8h
		db	 86h,0C4h, 55h,0C4h,0C8h, 8Ch
		db	0C5h, 45h, 55h,0C8h, 86h,0C4h
		db	 65h, 86h,0C4h, 65h,0C7h, 45h
		db	0C8h, 84h, 45h,0C8h, 86h,0C4h
		db	 65h, 8Eh,0C4h,0C6h, 55h, 87h
		db	0C4h, 55h,0C8h, 86h, 43h, 75h
		db	0C7h, 85h,0C3h, 45h,0C8h, 85h
		db	0C4h, 55h, 47h, 84h, 42h,0C7h
		db	 86h,0C4h,0C6h, 45h,0C3h, 87h
		db	0C4h, 55h,0C7h,0C9h, 85h,0C4h
		db	 06h, 06h,0C8h, 84h,0C4h, 55h
		db	0C8h, 84h,0C4h, 65h,0C8h, 84h
		db	0C4h, 55h, 85h,0C4h,0C6h, 45h
		db	0C7h,0C8h, 86h,0C4h, 65h,0CAh
		db	 85h,0C4h, 06h, 06h, 85h,0C4h
		db	 45h,0C8h, 85h,0C4h, 55h,0C7h
		db	 85h, 43h, 55h, 84h,0C4h,0C6h
		db	 55h,0C8h, 86h,0C4h, 65h, 86h
		db	0C4h, 55h,0C5h, 65h,0C8h, 83h
		db	0C4h,0C3h,0C6h,0C8h, 85h,0C4h
		db	 65h, 85h,0C4h,0C6h,0C5h,0C6h
		db	0C8h, 84h,0C4h,0C6h, 45h,0C7h
		db	 82h,0D5h, 84h,0C4h, 55h,0C5h
		db	 86h,0C4h, 55h,0C3h, 55h,0C8h
		db	 84h,0C4h, 45h,0C7h,0C8h, 84h
		db	0C4h, 65h,0C7h, 84h,0C5h,0C6h
		db	0C3h,0C7h, 85h,0C4h,0C6h, 55h
		db	0C8h, 81h,0D6h, 84h,0C4h, 65h
		db	0C7h,0C8h, 84h,0C4h, 05h, 06h
		db	0C8h, 85h,0C4h, 45h,0C8h, 85h
		db	 43h, 65h,0C8h, 84h,0C4h, 45h
		db	0C8h, 84h,0C4h,0C6h, 45h,0C3h
		db	0C7h,0C8h,0D7h, 84h,0C4h, 55h
		db	0C8h, 86h,0C5h, 05h, 06h,0C8h
		db	 85h,0C4h, 55h,0C8h, 84h,0C4h
		db	 65h,0C4h,0C6h, 84h,0C4h, 45h
		db	0C4h,0C8h, 83h,0C4h,0C6h,0C6h
		db	0C7h,0C8h, 82h,0D8h, 84h,0C4h
		db	 65h,0C8h, 85h, 05h, 06h,0C7h
		db	 86h, 43h, 55h,0C8h, 83h,0C5h
		db	 75h,0C8h, 84h,0C4h, 55h,0C8h
		db	 83h,0C4h,0C6h, 45h,0C8h, 82h
		db	0D9h, 84h,0C4h, 55h,0C8h, 86h
		db	 07h, 06h,0C8h, 84h,0C4h, 55h
		db	 85h, 05h, 06h,0C8h, 84h, 43h
		db	0C8h, 85h,0C4h,0C6h, 45h,0C4h
		db	0C8h, 86h,0C4h, 65h, 86h, 55h
		db	0C5h, 65h,0C8h, 84h,0C4h, 45h
		db	0C8h, 85h, 75h,0C7h, 85h,0C4h
		db	0C6h,0C8h, 85h,0C4h,0C6h, 55h
		db	0C3h, 86h,0C4h, 55h,0C7h,0C8h
		db	 85h,0C4h, 05h, 06h,0C7h, 85h
		db	0C4h,0C6h,0C8h, 86h,0C3h, 65h
		db	0C9h, 85h,0C4h, 45h,0C8h, 84h
		db	0C4h,0C6h, 45h,0C4h, 87h,0C4h
		db	 45h,0C3h,0C7h, 86h,0C4h, 75h
		db	0C7h, 86h,0C4h,0C6h,0C7h,0C6h
		db	 85h,0C4h, 55h,0C8h,0C9h, 85h
		db	0C4h, 45h,0C8h, 84h,0C4h,0C6h
		db	 55h, 87h,0C4h, 65h, 86h, 06h
		db	 06h,0C8h, 85h,0C5h, 45h, 86h
		db	0C4h, 55h,0C8h,0C9h, 85h,0C4h
		db	0C6h,0C8h,0C9h, 84h,0C4h,0C6h
		db	 45h,0C4h,0C8h, 86h,0C4h, 65h
		db	 86h, 06h, 06h, 86h, 65h, 85h
		db	0C4h, 55h,0C8h, 86h,0C4h,0C6h
		db	0C4h,0C8h, 84h,0C4h,0C6h, 45h
		db	 88h,0C4h, 65h, 86h, 05h, 06h
		db	0C8h, 86h,0C3h, 45h,0C8h, 85h
		db	0C4h, 55h,0C8h, 86h,0C4h, 45h
		db	0C8h, 84h,0C4h,0C6h, 45h,0C3h
		db	 87h,0C4h, 55h,0C3h,0C7h, 85h
		db	0C3h, 45h,0C3h, 55h, 86h,0C4h
		db	 55h,0C8h, 84h,0C4h,0C6h,0C5h
		db	0C6h,0C8h, 86h,0C4h, 45h,0C8h
		db	 84h,0C4h,0C6h, 55h,0C7h, 86h
		db	0C4h, 65h, 86h,0C4h, 06h, 06h
		db	0C8h, 84h,0C4h, 55h,0C8h, 84h
		db	0C4h,0C6h,0C3h,0C6h,0C8h, 86h
		db	 43h, 45h, 84h,0C4h,0C6h, 65h
		db	 86h,0C4h, 65h,0C8h, 85h,0C4h
		db	 05h, 06h,0C8h, 85h, 43h, 45h
		db	0C7h, 84h,0C4h, 55h,0C8h, 86h
		db	0C4h, 45h,0C8h, 84h,0C4h,0C6h
		db	 65h, 86h,0C4h, 65h,0C4h,0C8h
		db	 84h,0C4h,0C6h,0C4h, 65h,0C7h
		db	 85h,0C4h, 65h,0C8h, 83h,0C5h
		db	 55h,0C8h, 86h,0C4h,0C6h,0C7h
		db	0C8h, 84h,0C4h,0C6h, 45h,0C7h
		db	 47h, 85h,0C4h, 65h,0C8h, 85h
		db	0C4h, 75h,0C8h, 86h,0C4h, 55h
		db	0C8h, 84h,0C3h, 45h,0C8h,0C9h
		db	 86h,0C4h, 45h,0C8h, 84h,0C4h
		db	0C6h, 55h, 87h,0C5h, 55h,0C7h
		db	0C8h, 85h,0C4h, 65h,0C7h, 87h
		db	0C5h, 55h,0C8h, 84h,0C4h, 45h
		db	0C8h, 87h, 43h, 45h, 84h,0C4h
		db	0C6h, 65h, 86h,0C3h, 55h, 87h
		db	0C4h, 75h,0C8h, 86h, 55h, 86h
		db	0C4h, 45h,0C8h, 87h,0C4h, 55h
		db	 84h,0C4h,0C6h, 55h,0C8h, 86h
		db	0C4h, 55h,0C4h, 86h,0C4h, 06h
		db	 06h,0C8h, 84h, 55h,0C8h, 85h
		db	 43h, 45h,0C8h, 86h,0C4h, 45h
		db	0C8h, 84h,0C4h,0C6h, 55h, 87h
		db	0C4h, 65h, 86h,0C4h, 05h, 06h
		db	0C8h, 85h, 65h, 85h,0C4h, 55h
		db	0C7h, 86h,0C4h, 45h, 85h,0C4h
		db	0C6h, 45h,0C8h, 87h,0C4h, 55h
		db	0C7h,0C8h, 85h,0C4h, 05h, 06h
		db	 86h,0C3h,0C6h,0C4h,0C6h,0C8h
		db	 84h,0C4h, 55h,0C7h, 86h,0C4h
		db	0C7h,0C4h,0C7h, 84h,0C4h,0C6h
		db	 55h,0C8h, 86h,0C4h, 65h, 86h
		db	 43h, 65h,0C7h, 86h,0C4h, 45h
		db	0C7h,0C8h, 84h,0C4h, 55h,0C8h
		db	 86h,0C4h, 45h,0C8h, 84h,0C4h
		db	0C6h, 55h, 87h,0C4h, 65h, 86h
		db	0C4h, 05h, 06h, 86h, 43h, 55h
		db	 84h,0C4h, 45h,0C8h, 87h,0C4h
		db	 46h, 85h,0C4h,0C6h, 55h, 87h
		db	0C4h, 65h, 86h,0C4h, 06h, 06h
		db	0C8h, 84h,0C4h, 55h,0C8h, 84h
		db	0C5h, 45h,0C8h, 87h,0C4h, 45h
		db	0C8h, 84h,0C4h,0C6h, 65h, 86h
		db	0C4h, 45h,0C3h,0C7h,0C8h, 85h
		db	0C4h, 75h,0C7h, 86h,0C4h, 45h
		db	0C8h, 85h, 45h,0C5h,0C8h, 87h
		db	0C4h,0C6h,0C4h,0C8h, 84h,0C4h
		db	0C6h, 65h,0C7h,0C8h, 84h,0C4h
		db	 55h,0CAh, 86h,0C4h, 55h,0C4h
		db	 45h,0C8h, 85h,0C4h, 55h, 85h
		db	 55h,0C8h, 87h,0C4h, 45h,0C8h
		db	 84h,0C4h,0C6h, 65h, 86h,0C4h
		db	 65h, 86h,0C5h, 05h, 06h, 86h
		db	0C4h,0C6h,0C3h, 45h,0C8h, 83h
		db	0C3h, 45h,0C8h, 87h, 43h,0C6h
		db	0C8h, 84h,0C4h,0C6h, 55h,0C8h
		db	 86h,0C4h, 55h,0C4h,0C8h, 85h
		db	0C4h, 07h, 06h,0C8h, 83h,0C4h
		db	 65h,0C8h, 83h,0C4h, 45h,0C7h
		db	 87h,0C4h,0C7h,0C6h,0C8h, 84h
		db	0C4h,0C6h, 45h,0C7h, 87h,0C4h
		db	 55h,0C9h, 86h,0C4h, 06h, 06h
		db	 85h,0C4h, 45h,0C7h,0C8h, 84h
		db	0C4h, 45h,0C7h, 87h,0C4h, 45h
		db	0C8h, 84h,0C5h,0C6h, 45h, 47h
		db	 86h,0C4h, 45h,0C4h,0C8h, 86h
		db	0C4h, 05h, 06h,0C8h, 85h, 43h
		db	 45h, 85h,0C4h, 45h,0C8h, 87h
		db	0C4h, 55h, 85h,0C4h, 55h, 87h
		db	0C5h, 55h,0CAh, 86h,0C4h, 75h
		db	0C7h, 86h,0C5h,0C3h,0C7h,0C8h
		db	 85h, 43h,0C6h,0C8h, 87h,0C4h
		db	 55h, 85h,0C4h, 55h, 87h, 75h
		db	 86h,0C4h, 05h, 06h, 8Fh,0C4h
		db	 45h,0C7h, 87h,0C4h, 55h,0C8h
		db	 84h,0C4h, 55h,0C8h, 86h, 05h
		db	 06h,0C8h, 84h,0C4h, 45h,0C4h
		db	 55h, 40h, 41h, 50h, 41h, 40h
		db	0C2h,0C1h,0C2h, 81h,0C4h, 45h
		db	0C8h, 87h,0C4h, 55h, 85h,0C4h
		db	 65h,0C8h, 85h,0C3h, 65h, 86h
		db	0C5h, 05h, 06h,0C8h, 8Eh,0C4h
		db	 45h,0C8h, 87h, 43h, 45h,0C7h
		db	0CAh, 83h,0C6h, 45h,0C4h, 45h
		db	0C7h, 84h,0C4h, 55h, 47h, 85h
		db	 65h,0C5h, 55h,0C8h, 8Ch,0C3h
		db	 65h,0C8h, 86h,0C4h, 55h,0C8h
		db	 84h,0C6h, 75h,0C8h, 84h,0C4h
		db	 55h,0C8h, 86h, 08h, 06h,0C5h
		db	0C3h, 65h,0C3h, 45h,0C5h, 42h
		db	 75h,0C8h, 86h,0C4h, 45h, 86h
		db	0C6h, 65h,0C8h, 85h,0C4h,0C6h
		db	0C4h,0C6h,0C3h,0C8h, 85h,0C3h
		db	 0Dh, 06h,0C4h, 07h, 06h,0C3h
		db	0C6h,0C8h, 86h,0C4h, 55h,0C8h
		db	 84h,0C6h, 65h, 86h,0C4h, 55h
		db	0C8h, 86h,0C4h, 08h, 06h, 44h
		db	 0Dh, 06h,0C8h, 86h,0C4h, 45h
		db	0C8h, 85h,0C6h, 55h,0C8h, 86h
		db	0C4h, 65h,0C7h, 85h,0C4h, 07h
		db	 06h,0C8h,0C9h, 81h,0C4h, 75h
		db	0C8h, 82h,0C5h, 65h,0C7h, 86h
		db	0C5h, 45h,0C7h, 85h,0C4h, 65h
		db	 86h,0C4h, 45h, 47h, 86h,0C4h
		db	 55h,0C4h,0C6h,0C7h,0C8h, 84h
		db	0C4h, 65h,0C8h, 84h,0C4h, 65h
		db	0C8h, 85h,0C3h, 55h,0C8h, 84h
		db	0C4h, 65h,0C8h, 85h,0C4h, 55h
		db	0C8h, 86h,0C4h, 05h, 06h, 85h
		db	0C4h, 65h, 85h,0C4h, 65h,0C8h
		db	 85h,0C4h, 65h,0C8h, 83h,0C4h
		db	 75h, 85h,0C4h, 65h,0C8h, 85h
		db	0C4h, 75h, 86h, 43h, 55h,0C8h
		db	 84h,0C4h, 65h,0C3h,0C8h, 84h
		db	0C4h, 55h, 85h,0C4h, 65h,0C8h
		db	 85h,0C3h, 55h, 47h, 85h,0C4h
		db	 05h, 06h,0C8h, 84h,0C4h, 05h
		db	 06h, 83h,0C4h, 05h, 06h,0C3h
		db	 82h,0C3h, 55h, 86h,0C6h, 55h
		db	 47h, 85h,0C4h, 55h,0C8h, 86h
		db	0C4h,0C6h,0C4h, 65h,0C7h,0C8h
		db	 83h,0C4h, 65h,0C8h, 84h,0C4h
		db	 45h,0C3h, 55h,0C7h, 06h, 06h
		db	0C8h, 84h,0C4h, 55h,0C8h, 86h
		db	0C4h, 65h, 86h,0C4h, 06h, 06h
		db	 84h,0C5h, 55h,0C8h, 85h,0C4h
		db	 0Ch, 06h, 86h,0C4h, 55h, 87h
		db	0C4h,0C6h,0C5h, 55h, 85h,0C4h
		db	 05h, 06h,0C8h, 84h, 65h, 86h
		db	0C4h, 07h, 06h,0C3h, 65h,0C7h
		db	0C8h, 84h,0C4h, 55h, 87h,0C4h
		db	 65h,0C7h,0C8h, 84h,0C5h, 65h
		db	 47h, 85h,0C3h, 45h, 87h, 44h
		db	 55h,0C3h,0C7h,0C5h, 06h, 06h
		db	 85h,0C4h, 55h,0C8h, 86h,0C4h
		db	 65h,0C8h, 86h,0C4h, 65h,0C8h
		db	 85h,0C4h, 55h, 90h,0C5h, 75h
		db	0C8h, 83h,0C4h, 55h, 87h,0C4h
		db	 65h,0C3h,0C7h,0C8h, 84h,0C5h
		db	 45h,0C7h,0C6h,0C7h,0C8h, 84h
		db	0C4h, 55h, 50h, 41h, 40h,0C2h
		db	 40h, 41h, 40h,0C2h, 82h,0C4h
		db	 65h,0CAh, 83h,0C5h,0C4h, 55h
		db	0C8h, 85h,0C4h, 45h,0C4h,0C7h
		db	0C8h, 87h,0C4h, 65h, 85h,0C4h
		db	 75h,0C8h, 8Eh,0C4h, 55h,0C8h
		db	 85h,0C4h, 65h, 85h,0C5h,0C6h
		db	0C7h,0C8h, 89h, 44h, 45h,0C8h
		db	 85h,0C4h, 07h, 06h,0C8h, 8Bh
		db	0C4h, 45h,0C7h, 86h, 43h, 45h
		db	 9Dh,0C4h,0C6h,0C4h, 09h, 06h
		db	0C8h, 87h,0C4h, 55h,0C8h, 85h
		db	0C4h,0C6h
data_1		db	0C3h			; Data table (indexed access)
		db	0C7h
		db	'`QPQPAPAPA'
		db	 81h,0C4h, 09h, 06h,0C4h, 45h
		db	0C7h,0C8h, 85h,0C4h, 65h,0C8h
		db	 84h,0C4h, 45h, 9Eh,0C4h, 0Eh
		db	 06h,0C7h, 84h,0C4h, 55h, 86h
		db	0C4h, 45h, 47h, 85h,0C3h,0C4h
		db	0C6h,0C7h,0C8h, 89h,0C3h,0C6h
		db	0C8h, 86h,0C4h, 0Dh, 06h, 86h
		db	0C4h, 55h,0C8h, 85h,0C4h, 55h
		db	 86h,0C4h, 55h,0C4h,0C8h, 87h
		db	0C3h, 55h,0C3h, 85h, 54h,0C3h
		db	0C7h, 65h, 44h, 65h,0C8h, 85h
		db	0C4h, 55h, 86h,0C4h, 45h,0C8h
		db	 86h,0C4h, 75h,0C7h, 86h,0C4h
		db	 65h, 90h,0C5h, 65h,0C7h, 84h
		db	0C4h, 45h,0C4h,0C8h, 85h,0C5h
		db	0C7h,0C8h, 87h,0C4h, 65h,0C8h
		db	 87h,0C4h, 65h, 51h, 40h, 41h
		db	0C1h,0C2h, 40h, 41h, 40h, 82h
		db	0C4h, 55h, 85h,0C4h, 55h,0C8h
		db	 85h, 8Ah,0C4h, 45h,0C3h,0C7h
		db	 88h, 43h, 65h, 90h,0C4h, 45h
		db	0C8h, 85h, 43h, 55h, 85h, 8Ah
		db	0C5h, 75h, 87h,0C4h, 75h,0C3h
		db	 75h,0C4h, 45h,0C3h,0C8h, 85h
		db	0C4h, 55h, 85h,0C4h, 55h, 86h
		db	 8Ah, 75h, 48h, 86h,0C4h, 0Fh
		db	 06h,0C8h, 84h,0C4h, 55h,0C8h
		db	 84h,0C4h, 55h,0C7h,0C8h, 84h
		db	 8Ah, 05h, 06h,0C8h, 86h,0C4h
		db	 07h, 06h,0C4h, 44h, 75h,0C7h
		db	 84h,0C4h, 65h, 84h,0C4h, 55h
		db	0C8h, 85h, 8Ah,0C3h, 06h, 06h
		db	 85h,0C4h, 45h,0C5h, 75h,0C8h
		db	 82h,0C5h, 65h, 85h,0C5h, 55h
		db	0C8h, 84h,0C4h, 45h,0C7h, 86h
		db	 8Ah,0C4h, 05h, 06h, 86h,0C4h
		db	 06h, 06h,0C8h, 84h,0C4h, 55h
		db	0C8h, 84h, 45h,0C7h,0C8h, 85h
		db	0C5h,0C6h,0C4h,0C6h,0C8h, 85h
		db	 8Ah,0C4h, 05h, 06h,0C8h, 85h
		db	0C4h, 05h, 06h,0C7h,0C8h, 84h
		db	0C4h, 45h, 86h, 45h,0C7h, 86h
		db	 05h, 06h, 84h, 8Ah,0C4h,0C3h
		db	 75h, 86h,0C4h, 75h,0C3h,0C8h
		db	 85h,0C4h, 55h,0C8h, 84h, 45h
		db	0C8h, 86h, 75h, 85h, 8Ah,0C4h
		db	 75h,0C8h, 86h,0C4h, 05h, 06h
		db	 86h,0C4h, 65h,0C8h, 83h,0C3h
		db	0C6h,0C8h, 86h,0C4h, 55h,0C7h
		db	 49h, 83h, 8Ah,0C4h, 05h, 06h
		db	 86h,0C4h, 75h,0C7h,0C8h,0D0h
		db	 84h,0C4h, 55h,0C7h, 84h,0C4h
		db	0C6h,0C8h, 86h, 65h,0C8h,0CAh
		db	 84h, 8Ah,0C4h, 05h, 06h,0C8h
		db	 85h,0C4h, 75h,0C8h, 81h,0D1h
		db	 84h,0C4h, 55h,0C8h, 84h,0C4h
		db	0C6h,0C8h, 86h,0C3h, 55h,0C4h
		db	 49h, 83h, 89h,0C3h, 06h, 06h
		db	0C8h, 85h,0C5h, 75h, 82h,0D2h
		db	 84h,0C4h, 55h, 85h,0C4h,0C6h
		db	0C8h, 86h,0C4h, 75h, 84h, 08h
		db	 03h, 08h, 06h, 85h, 05h, 06h
		db	 82h,0D3h, 84h,0C4h, 45h,0C8h
		db	 85h,0C5h,0C6h,0C8h, 86h,0C4h
		db	 65h,0C8h, 84h,0C4h, 10h, 06h
		db	0C7h, 84h, 05h, 06h,0C8h, 81h
		db	0D4h, 84h,0C4h, 65h,0C8h, 83h
		db	 45h,0C8h, 86h,0C4h, 45h, 47h
		db	 85h, 44h, 0Dh, 06h,0C7h,0C8h
		db	 85h,0C3h, 75h,0C7h,0C8h, 85h
		db	0C3h, 55h,0C8h, 84h, 45h,0C8h
		db	 86h,0C4h, 45h,0C4h, 86h, 82h
		db	0C5h,0C4h, 65h,0C4h, 07h, 06h
		db	 86h,0C4h, 06h, 06h, 85h,0C4h
		db	 55h,0C8h, 84h,0C3h,0C6h,0C8h
		db	 86h,0C4h, 65h, 85h, 83h,0C5h
		db	 0Bh, 06h,0C8h, 86h,0C4h, 65h
		db	0C7h,0C6h, 86h,0C4h, 55h, 85h
		db	0C4h,0C6h,0C8h, 86h,0C4h, 55h
		db	0C8h,0CAh, 84h, 84h,0C4h, 0Ah
		db	 06h, 87h,0C4h, 75h,0C8h, 86h
		db	0C4h, 55h,0C7h,0C9h, 83h,0C4h
		db	 45h, 86h,0C4h, 55h, 86h, 84h
		db	0C5h,0C4h, 08h, 06h,0C8h, 87h
		db	0C4h, 65h,0C3h,0C6h, 86h,0C4h
		db	 45h,0C7h,0C6h, 84h,0C4h, 45h
		db	0C8h, 85h,0C4h, 45h, 87h, 85h
		db	0C4h, 45h,0C4h, 75h,0C7h, 88h
		db	0C4h, 75h, 87h,0C3h, 55h, 47h
		db	 83h,0C4h, 55h,0C8h, 84h,0C4h
		db	 55h,0C8h, 85h, 85h,0C4h, 06h
		db	 06h,0C9h, 89h, 43h, 65h,0C8h
		db	 86h,0C4h, 55h,0C8h, 84h, 43h
		db	 45h,0C7h, 84h,0C4h, 55h, 86h
		db	 85h,0C4h, 06h, 06h,0C9h, 89h
		db	0C4h, 65h,0C7h, 87h,0C5h, 45h
		db	 47h, 84h,0C4h, 55h, 85h, 43h
		db	 55h,0C8h, 84h, 85h,0C4h, 06h
		db	 06h,0C7h, 89h,0C4h, 05h, 06h
		db	0C8h, 85h,0C4h, 55h, 85h,0C4h
		db	 45h,0C7h,0C8h, 84h,0C4h, 45h
		db	0C7h, 86h, 85h,0C4h, 07h, 06h
		db	0C9h, 88h,0C4h,0C6h,0C4h, 65h
		db	 86h,0C4h, 55h,0C8h, 84h,0C4h
		db	 55h, 85h,0C4h, 65h,0C8h, 84h
		db	 85h,0C4h,0C6h,0C4h, 75h, 48h
		db	 88h,0C4h, 05h, 06h,0C7h, 85h
		db	0C4h, 55h,0C7h, 84h,0C4h, 65h
		db	0C8h, 83h,0C5h, 65h, 85h, 85h
		db	0C4h, 05h, 06h, 58h, 88h,0C4h
		db	 75h,0C8h, 86h,0C4h, 45h,0C5h
		db	0C6h,0C9h, 83h,0C5h, 65h, 84h
		db	0C4h, 65h, 81h,0CAh, 83h, 85h
		db	0C4h, 06h, 06h,0C9h, 89h,0C4h
		db	 75h, 87h,0C4h, 65h,0C8h, 84h
		db	0C4h, 45h,0C8h, 84h,0C4h,0C6h
		db	0C4h,0C6h, 86h, 85h,0C4h, 07h
		db	 06h, 89h,0C4h, 75h, 87h,0C4h
		db	 55h,0C7h, 85h,0C4h, 45h,0C7h
		db	 84h,0C4h, 65h,0C8h, 84h, 85h
		db	0C4h, 06h, 06h,0C9h, 89h,0C4h
		db	 05h, 06h, 86h,0C4h, 45h,0C8h
		db	 86h,0C5h, 45h,0C8h, 84h,0C4h
		db	 55h, 86h, 85h,0C4h, 07h, 06h
		db	0C9h, 88h,0C4h, 75h,0C8h, 86h
		db	0C4h, 55h, 8Eh,0C4h, 55h,0C7h
		db	 85h, 85h,0C4h, 07h, 06h,0C7h
		db	 88h,0C4h, 05h, 06h, 86h,0C4h
		db	 55h,0C1h,0C2h,0C1h,0C2h,0C1h
		db	 41h, 40h, 41h, 40h, 81h,0C4h
		db	 75h,0CAh, 83h, 85h,0C4h, 07h
		db	 06h,0C7h, 88h,0C4h, 06h, 06h
		db	 85h,0C4h, 55h,0C8h, 8Dh,0C4h
		db	 65h,0C8h, 84h, 85h,0C4h, 08h
		db	 06h,0C8h, 87h,0C5h, 05h, 06h
		db	0C8h, 85h,0C4h, 55h,0C8h, 86h
		db	0C3h,0C7h,0CAh, 83h,0C3h, 65h
		db	0C8h, 85h, 85h,0C4h, 09h, 06h
		db	0C8h, 87h,0C4h, 75h, 86h,0C4h
		db	 55h,0C7h,0C8h, 85h,0C4h, 65h
		db	0C3h, 75h,0C7h, 85h, 85h,0C4h
		db	 08h, 06h,0C3h,0C6h, 87h,0C4h
		db	 75h, 86h,0C4h, 75h,0C4h, 84h
		db	0C4h, 45h,0C4h, 08h, 06h, 84h
		db	 85h,0C4h, 0Ah, 06h,0C8h, 86h
		db	0C4h, 65h, 47h, 85h,0CCh,0C4h
		db	 75h,0C9h, 83h,0C4h, 07h, 06h
		db	0C4h, 55h,0C7h,0C8h,0C3h, 81h
		db	 85h,0C4h, 06h, 06h,0C4h, 65h
		db	0C8h, 85h,0C4h, 75h,0C7h, 86h
		db	0CCh,0C4h, 65h, 84h,0C4h, 45h
		db	 44h,0C6h,0C5h, 09h, 06h, 85h
		db	0C4h, 09h, 06h,0C5h,0C6h, 48h
		db	 84h,0C5h, 55h,0C7h, 55h,0C8h
		db	 85h,0CCh, 65h,0C8h, 83h,0C4h
		db	 45h, 84h,0C4h, 08h, 06h,0C8h
		db	 84h,0C5h, 0Bh, 06h, 87h,0C4h
		db	 45h,0C3h, 45h, 88h,0CCh, 55h
		db	 84h,0C4h,0C7h, 85h,0C4h, 08h
		db	 06h,0CAh, 84h,0C4h, 0Bh, 06h
		db	0C7h, 86h,0C4h, 05h, 06h,0C7h
		db	0C8h, 86h,0C3h, 45h,0C8h, 83h
		db	0C4h,0C6h, 85h,0C4h, 07h, 06h
		db	0C7h,0CAh, 84h,0C4h, 0Dh, 06h
		db	0C8h, 84h,0C4h, 05h, 06h,0C8h
		db	 87h,0C4h, 45h, 84h,0C4h,0C6h
		db	 85h,0C4h, 07h, 06h,0C8h,0CAh
		db	 84h,0C4h, 09h, 06h,0C3h,0C6h
		db	0C8h, 86h,0C5h, 06h, 06h,0C7h
		db	 86h,0C4h,0C6h,0C8h, 84h,0C5h
		db	0C6h, 85h, 43h, 55h,0C5h, 65h
		db	0C8h, 84h, 43h, 05h, 06h,0C3h
		db	 55h,0C8h, 88h,0C4h, 55h,0C3h
		db	0C6h,0C8h, 87h,0C4h, 45h, 84h
		db	0C3h,0C6h, 85h,0C4h, 65h,0C3h
		db	 65h,0C8h, 84h,0C4h, 0Ch, 06h
		db	0C8h, 86h,0C5h, 45h,0C7h,0C6h
		db	0C8h, 88h,0C4h,0C6h,0C7h, 84h
		db	0C4h,0C7h, 85h,0C4h, 08h, 06h
		db	 85h,0C4h, 0Ah, 06h,0C7h,0CAh
		db	 95h,0C4h, 45h, 84h,0C4h,0C8h
		db	 85h,0C4h, 08h, 06h,0C8h, 84h
		db	0C4h, 08h, 06h,0C7h,0C6h,0C7h
		db	0C1h,0C2h
		db	'@A@A@QPA'
		db	0C1h, 81h,0C4h, 45h,0C8h, 83h
		db	0C4h,0C8h, 85h,0C4h, 08h, 06h
		db	0C8h, 84h,0C5h, 09h, 06h,0CAh
		db	 97h,0C5h, 45h,0C9h, 83h,0C4h
		db	0C6h, 85h,0C4h, 05h, 06h,0C3h
		db	 45h, 85h, 65h,0C4h, 75h,0C7h
		db	 50h, 41h, 40h, 86h, 42h,0C7h
		db	0C8h, 87h,0C3h, 45h,0C9h, 83h
		db	 43h, 85h,0C4h, 08h, 06h, 85h
		db	 07h, 06h,0C3h, 45h,0C8h, 8Ch
		db	0C4h, 55h, 87h,0C4h,0C6h,0C8h
		db	 84h,0C4h,0C6h, 85h,0C4h, 45h
		db	0C4h, 05h, 06h, 85h, 08h, 06h
		db	0C8h, 85h,0C3h,0C6h, 87h,0C4h
		db	 45h,0C3h,0C8h, 86h,0C4h,0C6h
		db	 85h,0C4h,0C6h, 85h,0C5h, 07h
		db	 06h, 81h, 85h, 05h, 06h,0C7h
		db	0C8h, 87h,0C4h, 45h,0C8h, 85h
		db	0C4h, 65h,0C7h, 85h,0C4h,0C6h
		db	 85h,0C4h,0C6h, 86h,0C4h, 05h
		db	 06h,0C3h,0C7h, 85h, 05h, 06h
		db	0C8h, 87h,0C3h, 55h,0C7h,0C8h
		db	 84h,0C4h, 65h,0C8h, 85h,0C4h
		db	0C7h, 85h,0C4h,0C6h, 86h,0C5h
		db	 06h, 06h,0C8h, 85h,0C3h, 75h
		db	0C7h,0C8h, 84h,0C3h, 55h,0C7h
		db	0C6h, 86h,0C4h, 45h,0C5h,0C8h
		db	 86h,0C4h, 47h, 84h,0C4h, 45h
		db	 86h,0C5h,0C6h,0C5h, 45h,0C8h
		db	 82h, 85h,0C4h, 55h,0C7h,0C6h
		db	0C8h, 85h,0C4h, 75h,0C8h, 85h
		db	0C4h, 55h,0C7h,0C6h, 85h,0C4h
		db	0C3h,0C7h, 84h,0C4h, 45h, 8Eh
		db	 51h, 82h,0C4h, 75h, 86h,0C4h
		db	 65h, 87h,0C4h, 75h,0C7h, 84h
		db	0C4h,0C8h, 85h,0C5h, 45h,0C2h
		db	 40h, 41h, 40h,0C2h,0C1h, 41h
		db	 40h,0C2h, 85h,0C4h, 05h, 06h
		db	0C8h, 84h, 43h, 65h,0C8h, 85h
		db	0C4h, 65h,0C8h, 85h,0C4h,0C8h
		db	 85h, 55h, 8Eh, 85h,0C4h, 05h
		db	 06h,0C7h, 84h,0C4h, 06h, 06h
		db	 84h,0C4h, 55h,0C5h,0C6h,0C8h
		db	 84h,0C4h,0C6h,0C8h, 84h, 55h
		db	0C3h,0C4h,0C6h,0C3h, 45h,0C8h
		db	 87h, 85h,0C4h, 75h,0C8h, 85h
		db	0C4h, 55h,0C4h,0C7h,0C6h,0C8h
		db	 84h, 43h, 55h, 86h,0C4h, 45h
		db	0C9h, 83h,0C3h, 09h, 06h,0CAh
		db	 85h, 85h,0C4h, 65h,0C7h, 86h
		db	0C4h, 75h,0C8h, 85h,0C4h,0C6h
		db	0C4h, 45h,0C7h,0C8h, 84h,0C4h
		db	 45h,0C9h, 83h,0C4h, 08h, 06h
		db	0C3h, 49h, 84h, 85h, 43h, 55h
		db	0C8h, 86h,0C4h, 75h,0C8h, 85h
		db	0C4h, 75h, 85h,0C4h, 45h,0C9h
		db	 83h,0C4h, 0Ah, 06h, 85h, 85h
		db	0C4h, 65h, 87h,0C4h, 75h, 86h
		db	0C4h, 65h,0C5h,0C6h, 84h,0C4h
		db	0C6h,0C7h, 84h, 43h, 05h, 06h
		db	0C3h, 65h,0CAh, 83h, 85h,0C4h
		db	 75h,0C8h, 85h,0C4h, 65h, 87h
		db	0C4h, 75h, 85h,0C4h,0C6h,0C8h
		db	 84h,0C4h, 06h, 06h,0C3h, 55h
		db	 85h, 85h,0C4h, 55h,0C3h, 45h
		db	 85h,0C4h, 75h,0C8h, 85h,0C4h
		db	 65h, 47h, 84h,0C4h, 45h,0C8h
		db	 83h,0C4h, 09h, 06h,0C7h,0C8h
		db	 84h, 85h,0C4h,0C6h,0C4h, 55h
		db	 86h,0C4h, 75h,0C7h, 85h,0C4h
		db	 55h, 87h,0C4h, 45h, 84h,0C4h
		db	 09h, 06h, 86h, 85h,0C4h, 75h
		db	0C8h, 85h,0C4h, 06h, 06h, 84h
		db	0C4h, 65h,0C8h, 85h,0C4h,0C6h
		db	0C8h, 84h,0C4h, 0Ah, 06h,0C8h
		db	 84h, 85h,0C4h, 65h,0C7h, 86h
		db	0C4h, 75h,0C8h, 85h,0C4h, 55h
		db	0C5h, 45h, 84h,0C4h, 45h,0C8h
		db	 83h,0C4h, 55h,0C4h, 55h,0C4h
		db	0C7h, 55h, 49h, 82h, 85h,0C4h
		db	 05h, 06h,0C8h, 84h,0C4h, 55h
		db	0C7h, 87h,0C4h, 75h,0C7h, 84h
		db	0C5h, 45h,0C9h, 83h,0C5h, 55h
		db	0C5h, 07h, 06h,0CAh, 83h, 85h
		db	0C4h, 55h,0C3h,0C6h,0C8h, 85h
		db	0C4h, 75h, 86h,0C4h, 75h, 85h
		db	 55h,0C9h, 84h,0C5h, 09h, 06h
		db	0C8h, 84h, 85h,0C4h, 75h, 86h
		db	0C4h, 65h, 87h, 43h, 45h, 47h
		db	 85h,0C4h, 45h, 86h,0C5h, 08h
		db	 06h, 47h, 83h, 85h,0C5h, 75h
		db	 86h,0C4h, 45h,0C5h, 45h, 86h
		db	0C4h, 65h, 86h, 55h, 8Bh,0C5h
		db	 75h, 84h, 85h, 65h,0C7h,0C8h
		db	 86h,0C4h, 65h, 47h, 85h,0C4h
		db	 55h,0C5h,0C8h, 85h, 55h, 40h
		db	0C2h, 40h,0C2h,0C1h, 41h,0C1h
		db	 82h,0C4h, 45h,0C3h,0C6h,0C8h
		db	 83h, 85h,0C3h, 75h,0C8h, 85h
		db	0C5h, 75h, 86h,0C4h, 75h,0C8h
		db	 84h, 55h,0C8h, 8Bh,0C4h, 55h
		db	0C8h, 84h, 85h,0C4h, 65h,0C7h
		db	 45h, 84h, 05h, 06h,0C7h, 85h
		db	0C5h,0C6h,0C4h, 45h,0C7h, 85h
		db	 65h,0C8h, 8Ah,0C4h, 55h,0C7h
		db	 84h, 85h,0C4h, 05h, 06h,0C8h
		db	 84h,0C3h, 75h,0C8h, 85h,0C3h
		db	 05h, 06h, 84h,0C3h,0C6h,0C4h
		db	 55h,0C7h,0C8h,0C9h, 86h,0C4h
		db	 65h,0C8h, 83h, 85h,0C4h, 65h
		db	0C3h,0C8h, 85h,0C4h, 65h,0C8h
		db	 86h,0C4h, 65h,0C7h,0C8h, 84h
		db	0C4h, 07h, 06h,0C8h, 85h,0C4h
		db	0C7h, 55h,0CAh, 83h, 85h,0C4h
		db	 75h, 86h,0C4h, 75h,0C8h, 85h
		db	0C4h, 55h,0C5h,0C8h, 85h,0C4h
		db	 06h, 06h,0C8h, 86h,0C4h, 65h
		db	 84h, 85h,0C4h, 75h,0C8h, 85h
		db	 43h, 65h, 86h,0C4h, 75h, 85h
		db	0C4h, 05h, 06h,0C8h, 87h,0C4h
		db	 65h,0C8h, 83h, 85h,0C4h, 65h
		db	 87h,0C4h, 45h,0C5h,0C6h,0C7h
		db	 86h,0C4h, 45h,0C7h,0C6h, 86h
		db	0C4h, 55h,0C4h,0C6h,0C8h, 88h
		db	 43h, 45h, 85h, 85h,0C4h, 55h
		db	0C3h,0C6h,0C8h, 85h,0C4h, 45h
		db	0C3h, 45h,0C8h, 85h,0C4h, 55h
		db	 47h, 85h, 43h, 65h,0C7h, 88h
		db	0C4h, 45h,0C7h,0C8h, 84h, 85h
		db	0C4h, 65h,0C7h,0C6h, 85h,0C4h
		db	 05h, 06h, 85h,0C4h, 65h,0C8h
		db	 85h,0C4h, 75h,0C8h, 88h,0C4h
		db	 55h, 85h, 84h,0C3h, 07h, 06h
		db	 84h,0C4h, 06h, 06h, 84h,0C4h
		db	 55h,0C7h,0C6h,0C8h, 84h,0C4h
		db	 75h,0C8h, 88h,0C5h, 65h,0C8h
		db	 83h, 84h,0C4h, 65h,0C7h,0C6h
		db	 86h,0C4h, 75h,0C8h, 85h,0C4h
		db	 05h, 06h,0C9h, 83h,0C4h, 75h
		db	 89h, 75h,0CAh, 83h, 83h,0C3h
		db	 45h,0C3h, 55h,0C8h, 86h,0C4h
		db	0C6h,0C4h, 45h,0C8h, 86h,0C5h
		db	 75h, 85h,0C4h, 65h,0C8h, 89h
		db	 75h,0C8h, 83h, 81h,0C3h, 08h
		db	 06h,0C8h, 85h,0C4h, 55h,0C7h
		db	 87h, 55h,0C5h, 45h,0C8h, 84h
		db	0C4h, 65h,0C8h, 89h, 65h, 85h
		db	 81h,0C4h, 09h, 06h,0C8h, 84h
		db	0C4h, 75h, 86h, 65h,0C3h,0C6h
		db	 85h,0C4h, 75h,0C7h, 88h,0C3h
		db	 65h, 47h, 82h, 09h, 06h,0C3h
		db	0C6h,0C7h, 84h,0C4h, 05h, 06h
		db	0C8h, 84h,0C3h, 55h,0C8h, 86h
		db	0C4h, 75h,0C8h, 88h,0C4h, 06h
		db	 06h,0C3h, 55h,0C4h, 06h, 06h
		db	0C8h, 85h,0C4h, 45h,0C3h, 45h
		db	 47h, 84h,0C4h, 65h,0C8h, 85h
		db	0C4h,0C6h,0C5h, 55h,0C7h, 88h
		db	0C4h, 55h,0C4h, 65h, 09h, 06h
		db	 87h,0C4h, 65h, 87h,0C4h, 55h
		db	0C5h,0C6h, 85h,0C4h,0C6h,0C3h
		db	 65h, 88h,0C4h, 07h, 06h, 0Bh
		db	 06h, 85h,0C4h, 65h,0C8h, 86h
		db	0C4h, 05h, 06h,0C9h, 83h,0C4h
		db	 75h,0C7h,0C8h, 87h,0C4h, 07h
		db	 06h, 75h,0C3h, 65h,0C7h,0C8h
		db	 85h,0C5h, 05h, 06h,0C8h, 84h
		db	0C4h, 75h,0C8h, 84h,0C4h, 05h
		db	 06h,0C8h, 87h, 43h, 06h, 06h
		db	 06h, 06h,0C3h,0C6h,0C3h,0C6h
		db	 86h, 05h, 06h,0C8h, 85h, 43h
		db	 55h,0C7h, 85h,0C4h, 05h, 06h
		db	0C8h, 87h,0C4h, 07h, 06h, 07h
		db	 06h,0C7h,0C6h,0C8h, 86h, 05h
		db	 06h, 86h,0C4h, 75h,0C8h, 84h
		db	0C4h, 05h, 06h, 88h,0C4h, 45h
		db	0C4h, 75h,0C3h, 45h,0C7h,0C6h
		db	0C8h, 8Bh,0C3h,0C4h, 55h,0C7h
		db	 86h,0C4h, 65h,0C8h, 85h, 43h
		db	 65h,0C8h, 88h,0C4h, 06h, 06h
		db	0C4h, 45h,0C8h, 8Eh,0C4h, 75h
		db	 86h,0C4h,0C6h,0C5h, 55h,0C8h
		db	 84h,0C4h, 75h, 47h, 87h,0C4h
		db	 07h, 06h,0C7h,0C8h, 8Fh,0C4h
		db	 45h,0C3h, 45h,0C8h, 85h,0C4h
		db	 75h,0C7h,0C9h, 83h,0C4h, 05h
		db	 06h,0C7h, 87h,0C5h, 07h, 06h
		db	 91h,0C4h, 05h, 06h,0C7h, 84h
		db	0C4h, 75h, 48h, 83h,0C4h, 65h
		db	0C5h, 55h,0C8h, 85h,0C3h, 05h
		db	 06h,0C7h,0C6h,0C1h,0C2h,0C1h
		db	 41h, 40h, 51h, 50h, 41h,0C1h
		db	 81h,0C4h, 05h, 06h,0C8h, 84h
		db	0C4h, 65h,0C5h,0C8h, 84h,0C4h
		db	 06h, 06h,0C8h, 86h,0C4h, 75h
		db	0C7h,0C6h,0C7h,0C9h, 90h,0C4h
		db	 75h,0C8h, 85h,0C4h, 75h, 85h
		db	0C5h, 07h, 06h, 86h,0C4h, 06h
		db	 06h,0C7h,0C8h,0C9h, 85h, 42h
		db	0C7h, 87h,0C4h, 55h,0C4h, 87h
		db	0C4h, 55h,0C7h,0C8h, 86h,0C4h
		db	 75h,0C7h,0C8h, 86h,0C4h, 75h
		db	0C7h, 45h,0C8h, 86h,0C4h, 65h
		db	0C8h, 84h,0C4h, 75h,0C8h, 85h
		db	0C5h,0C4h,0C5h, 45h, 87h, 44h
		db	0C6h,0C5h,0C6h,0C8h, 88h, 43h
		db	 06h, 06h, 87h, 43h, 45h,0C8h
		db	 85h,0C4h, 75h,0A0h,0C4h, 06h
		db	 06h,0C7h, 45h, 85h,0C4h, 45h
		db	 87h, 43h, 65h,0C7h,0C1h, 41h
		db	 50h, 41h, 40h,0C2h, 40h, 51h
		db	 40h, 41h, 40h,0C2h, 40h, 41h
		db	0C1h,0C2h,0C1h, 81h,0C4h, 55h
		db	0C4h, 65h,0C7h,0C8h, 85h,0C4h
		db	 55h,0C8h, 85h,0C4h, 65h,0C8h
		db	0A0h,0C4h, 05h, 06h,0C7h,0C6h
		db	0C8h, 86h,0C4h, 65h,0C8h, 84h
		db	0C4h, 55h,0C7h, 87h, 52h, 55h
		db	 94h,0C4h, 07h, 06h,0C9h, 86h
		db	0C4h, 55h, 47h, 83h,0C3h, 05h
		db	 06h,0C8h, 85h,0C4h, 75h, 94h
		db	0C4h, 06h, 06h,0C8h,0C9h, 86h
		db	0C5h,0C6h,0C4h, 65h, 42h, 65h
		db	0C4h, 55h,0C8h, 84h,0C4h, 75h
		db	 94h,0C4h, 06h, 06h,0C7h, 45h
		db	 85h, 0Fh, 06h,0C8h, 85h, 43h
		db	 55h,0C4h,0C6h, 82h, 0Fh, 06h
		db	0C3h, 08h, 06h,0C7h, 86h,0C3h
		db	 0Dh, 06h,0C8h, 86h,0C4h, 05h
		db	 06h, 82h, 17h, 06h,0C4h,0C6h
		db	0C9h, 86h, 43h, 06h, 06h,0C4h
		db	 05h, 06h,0C8h, 85h,0C4h, 13h
		db	 06h,0C3h, 07h, 06h,0C5h, 65h
		db	0C9h, 86h,0C4h, 09h, 06h, 44h
		db	0C6h,0C7h,0C8h, 86h,0C4h, 06h
		db	 06h,0C4h, 55h,0C5h, 13h, 06h
		db	0C7h,0C8h,0C9h, 86h,0C4h, 05h
		db	 06h,0C7h, 8Eh,0C5h,0C6h,0C4h
		db	 0Ah, 06h,0C5h, 0Fh, 06h,0C3h
		db	 55h,0C6h, 86h,0C4h, 55h,0C4h
		db	 45h,0C7h, 41h, 50h,0C2h, 40h
		db	 41h,0C1h,0C2h,0C1h, 81h,0C3h
		db	 17h, 06h,0C4h, 07h, 06h,0C7h
		db	 87h,0C4h, 75h, 90h,0C4h, 1Fh
		db	 06h,0C7h,0C6h, 87h, 43h, 55h
		db	0C7h, 8Ah, 42h, 45h, 42h, 12h
		db	 06h,0C4h, 08h, 06h,0C7h,0C6h
		db	0C7h,0C6h,0C8h, 81h, 87h,0C4h
		db	0C5h, 55h, 8Bh,0C4h, 26h, 06h
		db	0C8h, 87h, 54h, 45h, 8Bh,0C4h
		db	 0Ah, 06h,0C5h, 55h,0C5h, 09h
		db	 06h,0C7h,0C6h,0C5h, 45h,0C3h
		db	0C7h,0C5h,0C6h,0C7h,0C6h,0C8h
		db	 82h, 97h,0C4h, 0Ah, 06h,0C3h
		db	 09h, 06h,0C8h, 91h, 97h,0C4h
		db	 13h, 06h,0C7h,0C8h, 92h, 97h
		db	 43h, 13h, 06h,0CAh, 92h, 97h
		db	0C4h, 14h, 06h,0C8h, 92h, 87h
		db	 42h,0C7h,0CAh, 8Ch,0C4h, 65h
		db	0C5h,0C4h, 05h, 06h,0C7h,0C5h
		db	 55h,0C4h, 45h,0C8h, 84h,0C3h
		db	 45h,0C7h,0C6h, 8Ah, 87h,0C4h
		db	 45h,0C7h,0CAh, 8Bh,0C5h, 09h
		db	 06h,0C7h,0C4h, 55h,0C4h, 65h
		db	 85h,0C4h, 75h,0C8h, 88h, 30h
		db	 00h, 18h,0DDh, 00h, 2Ch,0FFh
		db	0FFh,0FFh,0FFh, 07h, 40h,0ABh
		db	 01h, 00h, 0Fh, 00h, 2Ah, 40h
		db	0B5h, 20h, 00h, 35h, 00h, 2Bh
		db	 40h,0BBh, 24h, 00h, 31h, 00h
		db	 7Ch, 80h, 80h, 76h, 00h, 7Fh
		db	 00h,0FFh,0FFh, 1Ah, 00h, 0Fh
		db	 01h, 01h, 1Bh, 00h, 0Eh, 00h
		db	 03h, 00h, 80h, 3Dh, 00h, 06h
		db	0C0h, 01h,0CDh, 00h,0FFh, 00h
		db	0FFh,0FFh,0FFh, 5Fh, 00h, 32h
		db	 83h, 03h, 0Fh, 00h, 32h, 00h
		db	0FFh,0FFh,0FFh, 80h, 00h, 20h
		db	 00h, 02h, 04h, 00h,0FFh, 00h
		db	 03h, 00h, 40h, 8Dh, 00h, 20h
		db	0C2h, 01h, 2Fh, 00h, 0Eh, 00h
		db	0FFh,0FFh,0FFh, 9Fh, 00h, 32h
		db	0C3h, 03h, 4Fh, 00h, 32h, 00h
		db	0FFh,0FFh,0FFh,0FFh,0FFh, 00h
		db	 00h,0FFh, 13h,0C0h,0FFh,0FFh
		db	0FFh,0FFh, 02h, 00h, 80h, 5Eh
		db	0D6h, 00h,0FFh, 69h,0D6h,0FFh
		db	0FFh,0FFh,0FFh, 02h, 00h, 40h
		db	 7Eh,0D7h, 00h,0FFh, 89h,0D7h
		db	0FFh,0FFh,0FFh,0FFh, 02h, 00h
		db	 20h, 8Eh,0D7h, 00h,0FFh, 99h
		db	0D7h,0FFh,0FFh,0FFh,0FFh, 02h
		db	 00h, 10h, 87h,0D9h, 00h, 00h
		db	0FFh,0FFh, 03h, 00h, 80h, 80h
		db	0D5h, 81h, 01h,0FFh,0FFh, 03h
		db	 00h, 40h,0A4h,0D5h, 80h, 02h
		db	0FFh,0FFh,0FFh,0FFh, 16h,0AFh
		db	 00h, 11h
		db	'Cavern of Malicia', 9
		db	 00h, 00h, 00h, 00h, 0Ch, 00h
		db	 21h,0FFh, 01h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 0Ch, 00h, 21h
		db	 01h, 00h, 16h, 00h, 3Ch,0FFh
		db	 02h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 16h, 00h, 3Ch, 02h, 00h
		db	 1Ah, 00h, 05h,0FFh, 02h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 1Ah
		db	 00h, 05h, 02h, 00h, 1Ah, 00h
		db	 17h,0FFh, 73h, 00h, 01h, 20h
		db	 00h, 00h, 00h, 02h, 00h, 80h
		db	 00h, 00h, 1Eh, 00h, 17h,0FFh
		db	 01h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 1Eh, 00h, 17h, 01h, 00h
		db	 2Ah, 00h, 20h,0FFh, 03h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 2Ah
		db	 00h, 20h, 03h, 00h, 2Ah, 00h
		db	 29h,0FFh, 02h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 2Ah, 00h, 29h
		db	 02h, 00h, 3Ch, 00h, 20h,0FFh
		db	 02h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 3Ch, 00h, 20h, 02h, 00h
		db	 40h, 00h, 29h,0FFh, 02h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 40h
		db	 00h, 29h, 02h, 00h, 4Ah, 00h
		db	 34h,0FFh, 01h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 4Ah, 00h, 34h
		db	 01h, 00h, 4Bh, 00h, 13h,0FFh
		db	 02h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 4Bh, 00h, 13h, 02h, 00h
		db	 4Ch, 00h, 2Fh,0FFh, 00h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 4Ch
		db	 00h, 2Fh, 00h, 00h, 51h, 00h
		db	 3Ch,0FFh, 01h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 51h, 00h, 3Ch
		db	 01h, 00h, 52h, 00h, 29h,0FFh
		db	 01h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 52h, 00h, 29h, 01h, 00h
		db	 53h, 00h, 08h,0FFh, 02h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 53h
		db	 00h, 08h, 02h, 00h, 53h, 00h
		db	 2Fh,0FFh, 00h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 53h, 00h, 2Fh
		db	 00h, 00h, 54h, 00h, 20h,0FFh
		db	 01h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 54h, 00h, 20h, 01h, 00h
		db	 55h, 00h, 34h,0FFh, 02h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 55h
		db	 00h, 34h, 02h, 00h, 58h, 00h
		db	 2Fh,0FFh, 00h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 58h, 00h, 2Fh
		db	 00h, 00h, 59h, 00h, 13h,0FFh
		db	 02h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 59h, 00h, 13h, 02h, 00h
		db	 5Bh, 00h, 3Dh,0FFh, 02h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 5Bh
		db	 00h, 3Dh, 02h, 00h, 63h, 00h
		db	 1Fh,0FFh, 73h, 00h, 00h, 20h
		db	 00h, 18h, 00h, 02h, 00h, 40h
		db	 00h, 00h, 63h, 00h, 29h,0FFh
		db	 76h, 00h, 00h, 20h, 00h, 00h
		db	 00h, 02h, 00h, 20h, 00h, 00h
		db	 64h, 00h, 08h,0FFh, 02h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 64h
		db	 00h, 08h, 02h, 00h, 6Eh, 00h
		db	 34h,0FFh, 03h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 6Eh, 00h, 34h
		db	 03h, 00h, 7Ch, 00h, 15h,0FFh
		db	 01h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 7Ch, 00h, 15h, 01h, 00h
		db	 7Eh, 00h, 30h,0FFh
		db	7 dup (0)
		db	 7Eh, 00h, 30h, 00h, 00h, 80h
		db	 00h, 2Bh,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 80h, 00h
		db	 2Bh, 01h, 00h, 83h, 00h, 30h
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 83h, 00h, 30h, 00h
		db	 00h, 85h, 00h, 34h,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 85h, 00h, 34h, 01h, 00h, 8Ch
		db	 00h, 0Eh,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 8Ch, 00h
		db	 0Eh, 00h, 00h, 91h, 00h, 0Eh
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 91h, 00h, 0Eh, 00h
		db	 00h, 94h, 00h, 0Fh,0FFh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 94h, 00h, 0Fh, 00h, 00h, 95h
		db	 00h, 03h,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 95h, 00h
		db	 03h, 01h, 00h,0A8h, 00h, 03h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0A8h, 00h, 03h, 02h
		db	 00h,0ACh, 00h, 2Dh,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0ACh, 00h, 2Dh, 01h, 00h,0B8h
		db	 00h, 0Fh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B8h, 00h
		db	 0Fh, 02h, 00h,0BCh, 00h, 1Bh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0BCh, 00h, 1Bh, 02h
		db	 00h,0BDh, 00h, 26h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0BDh, 00h, 26h, 02h, 00h,0C3h
		db	 00h, 03h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C3h, 00h
		db	 03h, 03h, 00h,0C3h, 00h, 3Bh
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0C3h, 00h, 3Bh, 00h
		db	 00h,0C4h, 00h, 0Fh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0C4h, 00h, 0Fh, 02h, 00h,0C5h
		db	 00h, 3Ch,0FFh
		db	7 dup (0)
		db	0C5h, 00h, 3Ch, 00h, 00h,0C6h
		db	 00h, 1Bh,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C6h, 00h
		db	 1Bh, 01h, 00h,0C6h, 00h, 26h
		db	0FFh, 01h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0C6h, 00h, 26h, 01h
		db	 00h,0C6h, 00h, 35h,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0C6h, 00h, 35h, 01h, 00h,0C7h
		db	 00h, 2Eh,0FFh
		db	7 dup (0)
		db	0C7h, 00h, 2Eh, 00h, 00h,0C7h
		db	 00h, 3Dh,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C7h, 00h
		db	 3Dh, 00h, 00h,0C9h, 00h, 3Ch
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0C9h, 00h, 3Ch, 00h
		db	 00h,0D1h, 00h, 2Fh,0FFh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0D1h, 00h, 2Fh, 00h, 00h,0DCh
		db	 00h, 0Fh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0DCh, 00h
		db	 0Fh, 03h, 00h,0DEh, 00h, 35h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0DEh, 00h, 35h, 03h
		db	 00h,0E0h, 00h, 05h,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0E0h, 00h, 05h, 01h, 00h,0E0h
		db	 00h, 24h,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 19h, 00h, 02h, 00h
		db	 10h, 00h, 00h,0FFh,0FFh

zr3_20		endp

seg_a		ends



		end	start
