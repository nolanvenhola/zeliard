
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR3_22	                                 лл
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

zr3_22		proc	far

start:
		mov	dh,1Bh
		add	[bx+si],al
		das				; Decimal adjust
		db	0D8h,0E0h, 00h,0F5h,0D6h, 06h
		db	0D7h, 08h,0D7h, 57h,0D7h,0A1h
		db	0D7h, 1Ah,0D8h, 34h,0D8h, 02h
		db	0ABh, 00h, 37h, 0Ah, 2Dh,0D7h
		db	0F5h,0D6h, 81h,0C4h,0C8h, 49h
		db	0CDh, 87h,0C5h, 69h,0C8h,0CDh
		db	 87h,0C5h, 49h,0CCh, 81h,0CEh
		db	 88h,0C5h,0C9h,0CCh, 88h,0C3h
		db	 49h,0CBh,0CCh,0CEh, 86h, 81h
		db	0C4h,0C8h, 49h,0CDh, 87h,0C4h
		db	 59h, 47h,0CDh,0CEh, 86h,0C5h
		db	0CAh,0C8h,0CAh,0CCh, 89h,0C5h
		db	0C9h,0CCh, 88h,0C4h,0CAh,0CCh
		db	0C3h,0CAh,0CDh, 86h, 81h,0C4h
		db	 47h,0CDh, 82h,0CEh, 85h,0C4h
		db	 49h,0C7h,0CAh,0CDh, 88h,0C5h
		db	 59h,0C7h,0CCh, 88h,0C5h,0CAh
		db	0CCh, 88h,0C4h, 49h, 47h, 48h
		db	0CDh, 84h, 81h,0C4h,0C8h,0CBh
		db	0CDh, 88h,0C4h, 47h, 49h,0CCh
		db	 88h,0C5h, 59h,0CCh, 89h,0C5h
		db	0CAh,0CCh, 88h,0C4h,0CAh, 57h
		db	0C9h,0CCh, 85h, 81h,0C5h,0C8h
		db	0CDh, 89h,0C4h, 46h, 59h,0CDh
		db	 87h,0C5h, 49h,0CBh,0CCh, 81h
		db	0CEh, 87h,0C5h,0CDh, 89h,0C4h
		db	 57h,0CBh,0CAh,0CCh,0CEh, 84h
		db	 81h,0C5h,0C8h,0C9h,0CCh, 88h
		db	0C4h,0C8h, 69h,0CBh,0CDh, 86h
		db	0C5h,0C8h, 49h,0CCh, 89h,0C5h
		db	0CDh, 89h,0C4h, 57h,0CAh,0CCh
		db	 82h,0D5h, 83h, 81h,0C5h,0C8h
		db	0C9h,0CAh,0C7h,0CDh, 86h,0C5h
		db	0C8h, 79h,0CDh, 86h,0C5h,0C8h
		db	 49h,0CCh, 89h,0C6h,0CCh, 89h
		db	0C4h,0CAh, 47h,0CBh,0CCh,0CEh
		db	 81h,0D6h, 83h, 81h,0C5h,0C8h
		db	0C9h,0CAh,0C9h,0C8h,0CDh, 85h
		db	0C5h, 59h,0CCh, 49h,0CDh, 86h
		db	0C5h, 59h,0C7h,0C8h,0CCh, 92h
		db	0C5h, 67h,0CAh,0CCh, 81h,0D7h
		db	 83h, 81h,0C5h,0C8h,0C9h,0CCh
		db	0C3h,0CCh,0CEh, 85h,0C5h, 79h
		db	0C8h,0CDh, 86h,0C5h, 59h, 47h
		db	0CBh,0CDh, 40h, 41h, 40h,0C2h
		db	0C1h, 41h, 40h, 41h,0C1h,0C2h
		db	 81h,0C5h, 67h,0CBh,0CCh, 81h
		db	0D8h, 83h, 81h,0C4h,0C8h, 48h
		db	0CAh,0CDh, 86h,0C5h, 69h, 47h
		db	0C7h,0CCh, 85h,0C5h, 49h,0C8h
		db	0C7h,0CCh, 93h,0C5h, 67h,0CBh
		db	0CCh, 81h,0D9h, 83h, 81h,0C4h
		db	0C8h,0C9h,0CAh,0CDh, 81h,0CEh
		db	 85h,0C5h, 69h, 47h,0CDh, 86h
		db	0C5h,0CAh, 47h,0CDh, 81h,0CEh
		db	 8Ah,0D0h,0CCh, 86h,0C5h, 67h
		db	0CDh, 81h,0CEh, 84h, 81h,0C4h
		db	0C8h,0C9h,0CCh, 88h,0C5h, 69h
		db	0C8h,0CAh,0CDh, 86h,0C5h, 59h
		db	0CCh, 8Bh,0D0h,0C4h,0CCh,0CEh
		db	 85h,0C5h, 67h,0CBh,0CDh, 85h
		db	 81h,0C4h,0C8h,0C9h,0CAh,0CDh
		db	 87h,0C5h,0CAh,0C8h,0CAh,0C7h
		db	0C8h,0CDh,0CEh, 86h,0C5h,0C8h
		db	 49h,0CDh,0CEh, 89h,0D0h, 43h
		db	0CCh, 86h,0C4h, 57h, 46h,0CDh
		db	 85h, 81h,0C4h,0C8h,0C9h,0CBh
		db	0CDh, 87h,0C5h, 47h,0CAh, 47h
		db	0CDh, 87h,0C5h, 59h,0CDh, 8Ah
		db	 53h,0CDh, 86h,0C5h, 67h,0CCh
		db	 86h, 81h,0C5h, 49h,0CCh,0CEh
		db	 87h,0C5h,0C8h, 79h,0CDh,0CEh
		db	 85h,0C5h, 49h,0C8h,0C7h,0CCh
		db	 89h,0C5h, 43h,0CCh, 81h,0CEh
		db	 84h,0C5h, 57h,0CAh,0CCh,0CEh
		db	 85h, 81h,0C6h,0CBh,0CDh, 89h
		db	0C6h,0C5h, 79h,0CDh, 86h,0C5h
		db	 69h,0CDh,0CEh, 88h,0C5h,0C4h
		db	0CAh,0CCh, 86h,0C5h, 57h,0CBh
		db	0CDh, 86h, 8Eh,0C5h, 59h,0CCh
		db	0CAh,0C7h,0CDh, 85h,0C5h, 69h
		db	0CDh, 89h,0C5h,0C4h,0CAh,0CDh
		db	0CEh, 85h,0C4h, 67h,0CDh, 86h
		db	 50h, 41h, 50h,0C2h, 40h,0C2h
		db	0C1h, 81h,0C4h, 79h,0CDh, 86h
		db	0C5h, 69h,0C8h,0CCh, 88h,0C5h
		db	0C4h,0CAh,0CCh, 86h,0C4h, 57h
		db	0CBh,0CCh,0C2h, 40h, 41h,0C1h
		db	 8Eh,0C6h, 59h,0C8h,0CBh,0CDh
		db	 86h,0C5h, 69h,0C7h,0CDh,0CEh
		db	 87h, 43h,0CAh,0CCh, 81h,0CEh
		db	 84h,0C4h, 47h,0C7h,0CDh, 87h
		db	 8Fh,0C5h, 47h,0C7h,0CAh,0CCh
		db	 86h,0C5h, 59h,0C8h,0CAh,0CDh
		db	 88h,0C5h, 49h,0C7h,0CCh, 85h
		db	0C4h, 47h,0C9h,0CCh, 87h, 8Fh
		db	0C5h, 47h,0CAh,0CDh,0CEh, 86h
		db	0C5h,0CBh,0CAh,0C8h, 49h,0CCh
		db	 81h,0CEh, 86h,0C5h, 49h,0C7h
		db	0C9h,0CCh, 84h,0C4h, 47h,0C9h
		db	0CDh,0CEh, 86h, 8Fh,0C5h, 69h
		db	0CDh, 86h,0C4h, 79h,0C7h,0C9h
		db	0CDh, 86h,0C5h, 49h, 47h,0CCh
		db	 84h,0C5h, 49h,0C7h,0CDh, 87h
		db	 8Fh,0C5h, 49h,0CCh,0CEh, 87h
		db	0C4h, 79h,0C8h,0C7h,0C9h,0CDh
		db	0CEh, 84h,0C5h,0CAh,0CCh,0C3h
		db	0CCh, 85h,0C5h, 49h,0CCh, 88h
		db	 8Fh,0C5h, 69h,0C7h,0CCh, 85h
		db	0C4h, 69h, 47h,0CCh,0C6h,0CCh
		db	 85h,0C5h, 47h,0CAh,0C7h,0C9h
		db	0CCh, 83h,0C5h, 49h,0CCh,0CEh
		db	 87h, 8Fh,0C5h, 69h,0CCh, 81h
		db	0CEh, 84h,0C4h, 69h,0C8h,0C5h
		db	0C7h,0CCh, 86h,0C5h,0CCh,0C3h
		db	0CAh,0C8h,0CCh,0CEh, 83h,0C4h
		db	0CAh,0C7h,0CDh, 88h, 8Fh,0C5h
		db	0CAh,0C8h, 46h,0CCh, 86h,0C6h
		db	 79h,0CDh,0CEh, 87h,0C5h, 49h
		db	0C8h,0C7h,0CCh, 84h,0C4h,0CAh
		db	0C9h,0CCh, 88h, 8Fh,0C5h, 57h
		db	0CDh, 88h,0C5h, 69h,0CCh, 88h
		db	0C5h, 49h,0CBh,0CCh,0CEh, 84h
		db	0C6h,0CBh,0CCh, 89h, 85h,0C3h
		db	0C4h,0CDh, 87h,0C5h, 47h,0CAh
		db	0CDh, 81h,0CEh, 86h,0C6h, 59h
		db	0C7h,0CCh, 88h,0C4h, 49h,0C8h
		db	0CCh, 91h, 41h, 40h, 81h, 43h
		db	0CDh, 87h,0C5h,0C8h, 49h,0CBh
		db	0CDh, 88h,0C4h,0CAh,0C7h,0CCh
		db	 89h,0C4h,0CAh,0CBh,0CAh,0CBh
		db	0CDh,0C1h,0C2h, 40h, 41h, 50h
		db	0C2h,0C1h,0C2h, 60h, 85h, 53h
		db	0CDh, 86h,0C5h, 59h,0CDh,0CEh
		db	 88h,0C4h, 49h,0CCh, 89h,0C4h
		db	 59h,0CCh, 91h, 85h, 53h,0CCh
		db	 86h,0C5h, 59h,0C8h,0CCh, 88h
		db	0C5h, 59h,0CCh, 88h,0C4h, 49h
		db	0C7h,0CDh, 8Ah,0C3h,0C4h,0CDh
		db	 84h, 84h,0C3h, 43h,0C9h,0CDh
		db	 86h,0C4h, 59h,0C8h,0CCh, 88h
		db	0C5h, 49h,0CDh, 89h,0C4h, 49h
		db	0C8h,0CDh, 8Ah, 53h,0CDh, 83h
		db	 84h, 43h, 48h,0CDh, 86h,0C4h
		db	 49h, 47h,0CDh, 88h,0C5h, 59h
		db	0CDh,0CEh, 87h,0C5h,0CAh,0C8h
		db	0C7h,0CCh,0CEh, 89h, 43h,0C7h
		db	0CCh, 83h, 83h,0C3h, 68h,0CDh
		db	 86h,0C4h, 69h,0C9h,0CCh, 87h
		db	0C5h, 59h,0CCh, 81h,0CEh, 86h
		db	0C5h, 47h,0C7h,0CCh, 8Ah, 43h
		db	0CAh,0CDh, 83h, 83h,0C4h, 68h
		db	0CDh, 86h,0C4h, 69h,0C7h,0CDh
		db	0CEh, 86h,0C5h, 49h,0C8h,0CDh
		db	 88h,0C5h,0CCh,0C3h,0C8h,0C7h
		db	0CCh, 89h,0C4h,0CAh,0CCh, 84h
		db	 82h,0C3h, 68h,0C8h,0CCh,0CEh
		db	 85h,0C4h,0CAh, 47h, 49h,0CBh
		db	0CCh, 86h,0C5h,0CAh, 47h,0CCh
		db	0C3h,0CCh, 86h,0C5h, 59h,0C8h
		db	0CCh, 89h,0C4h,0CAh,0CDh,0CEh
		db	 83h, 82h,0C4h, 58h,0C8h,0CDh
		db	 87h,0C4h, 47h, 49h,0CDh, 88h
		db	0C5h, 05h, 0Ah,0CBh,0CCh, 84h
		db	0C5h, 59h,0C8h,0CCh, 89h,0C5h
		db	0CAh,0CDh, 84h, 82h,0C4h, 47h
		db	0C9h,0CDh, 88h,0C4h, 59h,0CDh
		db	0C3h,0CCh, 87h,0C5h, 49h,0CDh
		db	0C3h,0C8h,0CDh, 86h,0C5h, 49h
		db	 47h,0C7h,0CCh, 88h,0C5h,0CAh
		db	0CDh, 84h, 82h,0C4h, 68h,0CDh
		db	0CEh, 86h,0C4h, 79h,0CCh, 87h
		db	0C5h, 69h,0C8h,0CDh,0CEh, 85h
		db	0C5h, 49h,0C8h,0CAh,0CCh,0CEh
		db	 88h,0C5h,0CAh,0CDh, 84h, 82h
		db	0C5h, 58h,0C8h,0C9h,0CDh, 86h
		db	0C4h,0CBh,0CCh,0C3h,0CCh, 89h
		db	0C5h, 79h,0CDh, 86h,0C5h, 69h
		db	0C7h,0CCh, 88h,0C5h,0C7h,0CCh
		db	 84h, 82h,0C5h,0C9h, 57h,0C9h
		db	0CCh, 86h,0C4h, 69h,0CDh, 88h
		db	0C5h,0CAh,0C8h, 49h,0CDh, 87h
		db	0C5h, 47h, 49h,0C8h,0CCh, 88h
		db	0C5h,0CAh,0CDh, 84h, 82h,0C5h
		db	 57h, 48h,0CDh, 86h,0C5h,0CAh
		db	0C5h,0CAh, 47h,0CCh, 87h,0C5h
		db	 47h,0CAh,0C8h,0CDh, 82h,0CEh
		db	 84h,0C4h, 79h,0CCh, 88h,0C5h
		db	0CAh,0CDh,0CEh, 83h, 82h,0C5h
		db	0C8h, 58h,0CDh, 87h,0C5h,0C8h
		db	0CAh, 47h,0CAh,0CDh, 87h,0C5h
		db	 79h,0CCh, 86h,0C4h, 05h, 0Ah
		db	0CCh, 87h,0C5h,0CAh,0CDh, 84h
		db	 82h,0C4h,0C8h, 68h,0CDh, 86h
		db	0C5h, 57h, 49h,0CDh, 87h,0C5h
		db	 69h,0C8h,0CDh, 86h,0C4h, 59h
		db	 47h,0CAh,0CCh,0CEh, 86h,0C4h
		db	0CAh,0CDh,0CEh, 83h, 82h,0C4h
		db	0C8h,0C9h,0C8h,0C9h,0CDh, 87h
		db	0C5h, 59h,0CDh, 89h,0C5h, 79h
		db	0CBh,0CDh, 85h,0C5h, 49h, 47h
		db	 49h,0CCh, 87h,0C4h, 49h,0CDh
		db	 83h, 82h,0C4h, 57h,0CAh,0CCh
		db	0CEh, 86h,0C5h,0C8h,0CCh, 8Bh
		db	0C5h,0CCh,0C6h,0C8h,0CAh,0CDh
		db	 87h,0C5h,0CAh,0CCh,0C6h, 59h
		db	0CCh, 87h,0C4h,0CBh,0CCh, 84h
		db	 81h,0C3h,0CBh,0C9h,0C8h,0C9h
		db	0CCh,0CAh,0CDh, 86h,0C5h,0CCh
		db	 8Ch,0C6h,0C8h,0CCh, 8Ah,0C6h
		db	0CCh, 82h,0C4h, 49h,0CCh, 87h
		db	0C4h, 49h,0CDh, 83h, 81h,0C9h
		db	 4Ah, 48h,0C3h, 49h,0CDh, 85h
		db	0C5h,0CCh, 9Dh,0C4h, 59h,0CCh
		db	 86h,0C4h, 49h,0CCh, 81h,0C3h
		db	 81h, 81h,0C9h,0CBh, 48h, 47h
		db	 49h,0CCh, 85h,0C6h,0CCh,0C2h
		db	 60h,0C2h,0C1h,0C2h, 70h, 41h
		db	 60h,0C2h, 50h,0C2h, 40h, 41h
		db	 81h,0C4h, 59h,0CCh, 86h,0C4h
		db	 49h,0C7h, 48h, 81h,0CBh,0C9h
		db	0CBh,0C9h, 47h,0CAh, 4Ah,0CDh
		db	 85h,0C3h,0CCh, 9Dh,0C4h, 59h
		db	0CCh, 86h,0C4h, 59h,0C8h, 4Ah
		db	0CAh,0C8h, 58h, 49h,0CBh,0CEh
		db	 86h,0C4h,0CAh,0CCh, 92h,0C3h
		db	0CAh,0CCh, 87h,0C4h,0CAh,0C7h
		db	 47h,0CCh, 85h,0C4h, 59h,0C8h
		db	0C7h,0CAh, 49h, 48h,0CBh,0CCh
		db	 89h,0C4h, 49h,0CCh, 91h,0C4h
		db	 49h,0CCh, 86h,0C4h,0CAh, 47h
		db	0CCh, 86h,0C4h, 59h,0C8h,0CAh
		db	0C8h,0C6h, 47h,0C9h,0CFh,0CEh
		db	 89h,0C5h, 69h,0CCh, 82h,0C3h
		db	 49h,0CDh, 89h,0C4h,0CAh,0CBh
		db	0CAh,0CCh, 85h,0C4h, 47h,0CAh
		db	0CCh, 86h,0C4h, 57h,0CAh,0C7h
		db	0CDh, 82h,0C6h,0C8h,0CCh, 8Ah
		db	0C5h, 59h,0C7h, 06h, 0Ah,0CCh
		db	 88h,0C4h, 59h,0CCh,0CEh, 84h
		db	0C5h, 47h,0CBh,0CDh, 86h,0C5h
		db	 57h,0C7h,0CDh,0CEh, 8Fh,0C4h
		db	 79h,0CDh,0C6h, 47h,0CAh,0CDh
		db	 89h,0C5h, 49h,0C8h,0CCh, 85h
		db	0C5h, 47h,0CCh, 87h,0C5h,0C8h
		db	 49h,0CDh, 82h, 8Fh,0C5h, 47h
		db	 49h,0C7h,0CAh,0CDh,0C6h,0C8h
		db	0CCh, 8Ah,0C5h,0CAh,0C8h,0CCh
		db	 86h,0C5h,0C8h, 49h,0CCh, 86h
		db	0C5h, 49h,0CDh, 81h,0CEh, 81h
		db	 8Fh,0C5h, 67h,0CAh,0CDh, 8Eh
		db	0C5h,0C7h,0C8h,0CCh,0CEh, 85h
		db	0C5h, 59h,0CCh, 86h,0C5h,0CAh
		db	0CCh, 84h, 84h,0C3h,0CCh, 89h
		db	0C4h,0C8h,0CAh,0C7h,0CAh,0CCh
		db	 81h,0CEh, 8Dh,0C4h, 49h,0CCh
		db	 86h,0C5h,0C8h,0CAh,0CCh,0CEh
		db	 86h,0C5h,0CAh,0CDh,0CEh, 83h
		db	 84h,0C4h,0CCh, 89h,0C4h, 49h
		db	0CDh, 82h,0CEh, 8Eh,0C4h,0CAh
		db	0CBh,0CAh,0CBh,0CCh, 84h,0C5h
		db	0CAh,0CCh,0CEh, 87h,0C5h,0CAh
		db	0CDh, 84h, 84h,0C4h, 49h,0CDh
		db	 87h,0C4h, 49h,0C7h,0CDh, 41h
		db	0C1h, 41h, 09h, 01h, 81h,0C4h
		db	 59h,0CDh, 85h,0C4h,0C8h,0CAh
		db	0CCh, 87h,0C5h,0CAh,0CCh, 84h
		db	 84h,0C4h, 49h,0CCh, 87h,0C4h
		db	 59h,0CDh, 90h,0C4h, 59h,0CCh
		db	 85h,0C4h, 49h,0CBh,0CCh, 86h
		db	0C5h,0C7h,0CDh, 84h, 84h,0C4h
		db	 69h,0CCh, 85h,0C4h, 59h,0CDh
		db	 85h,0C3h,0CCh, 89h,0C4h, 59h
		db	0CCh,0CEh, 84h,0C4h,0CAh,0CCh
		db	 88h,0C6h,0CDh, 85h, 84h,0C4h
		db	0CAh,0C8h,0CAh,0CDh, 86h,0C4h
		db	 59h,0CDh, 85h,0C4h,0CAh,0CCh
		db	 88h,0C4h, 59h,0CCh, 85h,0C4h
		db	0C8h,0CDh, 8Fh, 84h,0C5h,0C8h
		db	0C7h,0CAh,0CDh, 86h,0C4h, 59h
		db	0CBh,0CCh, 84h,0C4h,0C8h,0CAh
		db	0CDh, 87h,0C4h,0C8h,0CAh,0CCh
		db	 86h,0C6h,0C8h,0CDh, 8Fh, 84h
		db	0C5h, 59h,0CCh, 81h,0CEh, 84h
		db	0C4h,0CAh, 47h, 86h,0C5h,0C8h
		db	0CCh, 81h,0CEh, 86h,0C5h,0C8h
		db	0CAh,0CCh,0CEh, 85h,0C3h,0C8h
		db	0CCh, 8Fh, 84h,0C5h, 49h,0C8h
		db	0CAh,0CCh, 85h,0C5h,0C8h,0CAh
		db	0CDh,0CEh, 85h,0C5h,0CAh,0CCh
		db	 88h,0C5h,0C8h, 49h,0CCh, 85h
		db	0C4h,0C8h,0CCh, 8Fh, 84h,0C5h
		db	 69h,0CBh,0CDh, 84h,0C5h, 59h
		db	0CDh, 85h,0C5h, 49h,0CCh, 81h
		db	0CEh, 85h,0C5h,0C8h, 49h,0CDh
		db	 85h,0C4h,0CCh,0CEh, 8Fh, 84h
		db	0C5h, 47h,0C7h,0CAh,0CCh, 85h
		db	0C5h,0CAh, 47h,0CCh, 85h,0C5h
		db	 49h,0C8h, 87h,0C5h,0C8h, 49h
		db	0CCh,0CEh, 84h,0C4h,0CDh, 90h
		db	 84h,0C5h,0C8h, 49h,0CCh, 86h
		db	0C5h, 59h,0CDh, 85h,0C5h,0C8h
		db	0CAh,0C8h,0C7h,0CDh, 85h,0C5h
		db	 47h,0CAh,0CCh, 85h,0C4h,0CDh
		db	 81h,0CEh, 8Eh, 84h,0C4h, 47h
		db	0CDh,0CFh,0CEh, 85h,0C5h, 47h
		db	0CAh,0CDh,0CEh, 84h,0C4h, 49h
		db	0CDh, 87h,0C5h, 47h,0CAh,0CDh
		db	 85h,0C5h,0CAh,0CDh, 8Fh, 84h
		db	0C4h,0C8h,0CAh,0CCh,0CFh, 86h
		db	0C5h,0C8h,0CAh,0CCh, 86h,0C4h
		db	 49h,0CDh,0CEh, 86h,0C4h,0CAh
		db	0C8h,0CDh, 86h,0C5h,0CAh,0CDh
		db	 8Fh, 84h,0C4h, 49h,0C8h,0CAh
		db	0CCh, 85h,0C5h,0C8h, 49h,0CDh
		db	 85h,0C4h, 49h,0CDh, 87h,0C4h
		db	 59h,0CCh, 85h,0C5h,0C8h,0CCh
		db	 8Fh, 84h,0C4h,0CAh,0C8h, 49h
		db	0CBh,0CCh, 84h,0C5h, 47h, 49h
		db	0CDh, 84h,0C4h, 49h,0CCh, 81h
		db	0CEh, 85h,0C4h, 59h,0CCh, 85h
		db	0C5h,0C8h,0CDh,0CEh, 8Eh, 84h
		db	0C4h,0CAh,0C8h,0C7h,0C8h,0CCh
		db	 85h,0C4h, 59h,0CDh, 85h,0C4h
		db	 49h,0C8h,0CCh, 85h,0C3h, 79h
		db	0CCh, 84h,0C5h,0CAh,0CDh, 88h
		db	0C3h,0CCh, 85h, 84h,0C4h, 47h
		db	0CAh,0CCh,0CFh, 85h,0C4h, 49h
		db	0CDh,0CEh, 85h,0C4h, 49h,0C8h
		db	 49h,0CDh, 82h,0C3h, 59h,0C8h
		db	0CCh, 86h,0C5h,0CAh,0CDh, 88h
		db	0C4h,0CCh, 85h, 84h,0C5h,0C8h
		db	0CAh,0C8h,0CDh, 81h,0CEh, 84h
		db	0C4h, 59h,0CDh, 85h,0C4h,0C8h
		db	 79h,0CDh, 81h, 49h,0C7h, 59h
		db	0CDh, 85h,0C5h,0CAh,0CCh, 88h
		db	0C4h,0CAh,0CCh, 84h, 84h,0C5h
		db	 49h,0CDh,0CFh, 86h,0C4h, 59h
		db	0CDh,0CEh, 84h,0C5h,0C8h, 59h
		db	0C8h,0CAh,0C8h, 69h,0C8h,0CAh
		db	0CDh, 86h,0C4h, 49h,0CDh, 87h
		db	0C4h, 49h,0CCh, 83h, 84h,0C5h
		db	0CAh,0CCh,0CFh, 87h,0C4h, 49h
		db	0C7h,0CCh, 85h,0C5h, 69h,0C8h
		db	0CBh, 05h, 0Ah,0CCh, 87h,0C4h
		db	 49h,0CDh, 81h,0CEh, 85h,0C4h
		db	 49h,0CCh, 83h, 84h,0C5h,0C8h
		db	0CCh, 81h,0CEh, 86h,0C4h, 49h
		db	0CDh, 86h,0C5h, 49h,0C7h, 69h
		db	0C7h,0CAh,0CCh, 8Ah,0C4h,0CAh
		db	0C7h,0CDh, 87h,0C4h,0CAh,0C8h
		db	 49h,0CCh, 81h, 84h,0C6h,0CDh
		db	 89h,0C4h,0C8h,0CAh,0CDh,0CEh
		db	 85h,0C5h, 06h, 0Ah,0C8h,0CDh
		db	 09h, 01h, 81h,0C4h,0C8h,0CAh
		db	0C7h,0CCh, 86h,0C4h, 59h,0CDh
		db	 82h, 8Fh,0C5h, 49h,0CCh, 86h
		db	0C5h, 79h,0CCh, 8Eh,0C5h, 49h
		db	0CDh, 87h,0C4h, 69h,0CDh, 81h
		db	 0Dh, 01h, 81h,0C5h, 49h,0CDh
		db	 86h,0C6h,0C8h, 69h,0CBh,0CCh
		db	 07h, 01h, 85h,0C5h, 49h,0CDh
		db	 87h,0C4h,0CAh,0C8h, 59h,0CCh
		db	 8Fh,0C5h, 47h,0CDh, 88h,0C5h
		db	 59h,0CCh, 8Eh,0C5h, 49h,0CDh
		db	 87h,0C4h, 49h,0C7h,0CCh, 82h
		db	 8Fh,0C5h, 47h,0CDh, 88h,0C5h
		db	 49h,0CCh, 89h,0C3h,0C9h, 05h
		db	 0Ah,0C8h,0C7h,0CDh, 86h,0C4h
		db	0CAh,0C7h,0CAh,0CBh,0CDh, 81h
		db	 8Fh,0C5h,0C8h,0CDh, 89h,0C4h
		db	 49h,0CCh, 89h, 06h, 0Ah,0C8h
		db	0CAh,0C7h,0CDh,0CEh, 85h,0C4h
		db	 49h,0CCh, 83h, 8Fh,0C5h, 49h
		db	0CDh, 88h,0C4h,0CAh,0CCh, 89h
		db	0C3h, 08h, 0Ah,0C8h,0CCh, 86h
		db	0C4h,0CAh,0C7h,0CCh, 83h, 8Fh
		db	0C6h, 59h,0CCh, 87h,0C4h,0CBh
		db	0CDh, 89h,0C4h, 07h, 0Ah, 47h
		db	0CDh, 86h,0C5h, 47h,0CCh,0CEh
		db	 82h, 90h,0C5h, 49h,0C8h,0CDh
		db	 86h,0C4h, 49h,0CCh, 88h,0C4h
		db	 59h, 57h, 59h,0C8h,0CDh, 86h
		db	0C5h, 49h,0C7h,0CCh, 82h, 90h
		db	0C5h, 49h,0C8h,0CDh, 86h,0C4h
		db	 59h,0CCh, 87h,0C4h, 49h,0CCh
		db	 81h,0C6h,0C9h, 59h,0C7h,0CCh
		db	 86h,0C4h, 49h,0C8h,0CAh,0CCh
		db	0CEh, 90h,0C5h, 57h,0CDh, 86h
		db	0C4h, 49h,0C8h,0CCh, 87h,0C4h
		db	0CAh,0CBh,0CDh, 83h,0CAh,0C8h
		db	0CCh, 88h,0C4h, 49h,0C8h,0CAh
		db	0CCh, 81h,0CEh, 8Fh,0C5h,0C8h
		db	0CAh,0CDh,0CEh, 86h,0C5h, 59h
		db	0CCh, 87h,0C4h,0CAh,0CCh, 84h
		db	0C5h,0CAh,0CDh, 81h,0CEh, 86h
		db	0C5h,0CAh, 47h, 49h,0CCh, 90h
		db	0C4h, 49h,0CDh, 87h,0C5h, 47h
		db	0CAh,0CCh, 87h,0C4h,0CCh, 85h
		db	0C5h, 49h,0CCh, 87h,0C6h,0C8h
		db	0CCh, 81h,0C5h,0CEh, 81h,0CDh
		db	 8Fh,0C4h, 49h,0C7h,0CDh, 86h
		db	0C5h,0C8h,0CAh,0CDh, 88h,0C4h
		db	0CBh,0CDh, 84h,0C5h, 49h,0C8h
		db	0CCh, 8Ah,0C5h,0CCh,0C3h,0CCh
		db	 8Fh,0C4h,0CAh, 47h,0CDh, 86h
		db	0C5h, 49h,0CDh, 88h,0C4h,0CDh
		db	 85h,0C5h,0C8h,0C7h,0CCh, 40h
		db	0C2h,0C1h,0C2h, 70h, 81h,0C5h
		db	 49h,0CCh, 8Fh,0C4h,0CAh,0C8h
		db	0CDh,0CEh, 86h,0C5h,0CAh,0CBh
		db	0CDh, 88h,0CAh,0CDh, 85h,0C5h
		db	 47h,0CDh,0CEh, 8Ah,0C5h, 49h
		db	 49h,0CCh, 82h,0C3h, 49h,0CCh
		db	 87h,0C4h,0C8h,0CAh,0C7h,0CBh
		db	0CCh, 85h,0C5h,0CAh,0CCh, 89h
		db	0CAh,0CDh, 85h,0C6h,0C8h,0CCh
		db	 8Ch,0C5h, 47h, 09h, 0Ah,0CCh
		db	 85h,0C4h, 57h,0CDh, 86h,0C5h
		db	 49h,0CCh, 88h,0C4h,0CCh, 94h
		db	0C5h,0C8h,0CAh,0C7h, 59h,0C8h
		db	 49h,0CCh, 88h,0C4h,0CAh,0C7h
		db	0CCh, 87h,0C5h, 59h,0CCh, 87h
		db	0C4h,0CDh,0C1h, 41h, 60h, 41h
		db	 50h,0C2h, 40h,0C2h, 40h, 82h
		db	0C4h, 49h, 79h,0C7h,0CAh,0CBh
		db	0CCh, 87h,0C5h,0CAh,0CDh, 88h
		db	0C5h, 49h,0CDh, 88h,0C4h,0CBh
		db	0CDh, 93h,0C4h, 49h, 49h,0C8h
		db	 69h,0CDh, 88h,0C5h,0CDh, 89h
		db	0C5h, 49h,0C8h,0CCh, 87h,0C4h
		db	 49h,0CDh, 83h,0C3h,0CDh, 8Dh
		db	0C4h, 49h,0CBh,0C8h, 4Ah,0CAh
		db	0C8h, 49h,0CDh, 87h,0C6h,0CDh
		db	 89h,0C5h,0CAh,0CCh, 89h,0C4h
		db	0CCh,0CAh,0C9h,0CDh, 81h,0C3h
		db	0C8h,0CAh,0C8h,0CAh,0CDh,0CEh
		db	 89h,0C4h, 49h, 83h,0C6h, 4Ah
		db	 49h,0CDh, 87h,0C3h,0CDh, 89h
		db	0C4h, 49h,0CCh, 88h,0C4h, 09h
		db	 0Ah,0CCh, 8Ah,0C6h,0CBh,0CCh
		db	 86h, 59h,0CBh,0CCh, 85h,0C5h
		db	 49h,0CDh, 87h,0C4h, 59h,0CDh
		db	 87h,0C5h, 05h, 0Ah,0C8h,0CDh
		db	0C3h, 49h,0CDh,0CEh, 8Bh, 86h
		db	 79h,0CCh, 84h,0C5h, 49h,0C8h
		db	0CBh,0CDh, 85h,0C4h, 49h,0CDh
		db	 86h,0C3h, 05h, 0Ah, 57h, 79h
		db	0CCh, 8Bh, 86h,0C4h,0C8h,0CAh
		db	0CCh, 86h,0C5h, 49h,0C7h,0CDh
		db	 86h,0C4h, 49h,0C8h,0CCh, 85h
		db	0C8h,0C7h, 69h,0C8h,0CBh,0CDh
		db	0C6h, 49h,0C8h, 49h,0C7h,0C4h
		db	0CDh, 89h, 86h,0C4h,0C7h,0CAh
		db	0CCh, 86h,0C5h, 47h,0CDh, 87h
		db	0C4h,0CAh,0C8h,0CAh,0C8h,0CCh
		db	 82h,0C3h,0CAh,0C8h,0CAh,0C8h
		db	0C7h,0CAh,0CCh,0CEh, 83h,0C6h
		db	 67h, 49h,0CCh, 85h,0C3h, 49h
		db	0CCh, 86h,0C4h,0CAh,0CCh, 87h
		db	0C5h,0C7h, 49h,0CDh, 86h,0C4h
		db	 49h,0CBh, 05h, 0Ah,0CBh,0CDh
		db	0C6h,0CBh,0CCh, 81h,0CEh, 88h
		db	0C5h,0CAh,0C8h,0CDh, 83h,0C3h
		db	0C4h,0CAh,0CCh, 81h, 86h,0C5h
		db	 49h,0CDh, 86h,0C4h, 49h,0C8h
		db	0CCh, 86h,0C4h, 06h, 0Ah,0C8h
		db	0CAh,0CCh, 50h,0C2h, 60h,0C2h
		db	 60h, 81h,0C5h, 5Ah,0CDh, 81h
		db	0C3h, 69h,0CCh,0CEh, 85h,0C5h
		db	0CAh,0CDh, 87h,0C4h,0CAh,0C7h
		db	0CCh, 87h,0C4h, 69h,0C7h,0C8h
		db	0CCh, 91h,0C6h,0CCh, 81h,0D2h
		db	0D3h,0D4h,0C9h,0C8h, 49h,0CCh
		db	 81h, 86h,0C5h, 69h,0CCh, 84h
		db	0C4h, 47h,0CDh,0CEh, 86h,0C4h
		db	 49h,0C8h,0CAh,0C9h,0CCh,0C2h
		db	 60h,0C2h, 50h,0C2h, 60h, 87h
		db	0D2h,0D3h,0D4h,0C9h, 59h,0C7h
		db	0CDh, 86h,0C6h, 59h,0CCh, 85h
		db	0C4h,0C8h,0CDh, 88h,0C4h, 49h
		db	0C8h,0CAh,0C9h,0CCh, 95h,0D2h
		db	0D3h,0D4h,0C9h, 69h,0CCh,0CDh
		db	 86h,0C5h,0CAh,0CDh, 86h,0C4h
		db	 49h,0CDh, 87h,0C4h,0CAh,0C8h
		db	 49h,0C8h,0CDh, 85h,0C3h, 68h
		db	0CCh, 81h,0CEh, 88h,0D2h,0D3h
		db	0D4h,0C8h, 59h,0C8h,0C7h,0CDh
		db	 86h,0C5h,0CAh,0CCh, 86h,0C4h
		db	 49h,0CDh, 87h,0C4h, 47h, 49h
		db	0C9h,0CDh, 85h,0C5h, 78h,0CCh
		db	 89h,0D2h,0D3h,0D4h,0C8h, 49h
		db	0C7h,0C8h,0CAh,0C7h,0CCh, 85h
		db	0C5h,0CDh, 87h,0C4h, 49h,0CDh
		db	 87h,0C4h, 49h,0CDh,0C9h,0CBh
		db	0CDh, 85h,0C6h, 5Ah, 48h,0C8h
		db	0CDh, 88h,0D2h,0D3h,0D4h,0C8h
		db	 79h,0CAh,0CDh, 85h,0C6h,0CCh
		db	 87h,0C4h, 47h,0CAh,0CDh,0CEh
		db	 85h,0C5h, 59h,0CDh, 82h,0CEh
		db	 86h,0D2h,0D3h,0CAh,0C9h,0C8h
		db	0CAh,0CCh, 87h,0D2h,0D3h,0D4h
		db	0C8h, 69h,0C8h,0CDh, 8Fh,0C5h
		db	0CAh,0C8h,0CAh,0CCh, 86h,0C5h
		db	 59h,0CDh,0CEh, 88h,0D2h,0D3h
		db	0CAh, 47h,0CCh, 81h,0CEh, 86h
		db	0D2h,0D3h,0D4h, 59h, 57h,0CAh
		db	0CDh, 0Ch, 01h, 81h,0C5h,0C8h
		db	 49h,0CBh,0CCh, 85h,0C5h, 49h
		db	0CBh,0CCh, 81h,0CEh, 86h,0D2h
		db	0D3h,0D4h,0CAh,0C8h, 49h,0CCh
		db	 87h,0D2h,0D3h,0D4h, 59h,0C8h
		db	 49h,0CCh, 8Fh,0C5h,0C7h, 49h
		db	0CDh,0CEh, 85h,0C5h, 49h,0C9h
		db	0CDh, 88h,0D2h,0D3h,0D4h, 59h
		db	0CBh,0CCh, 87h,0D2h,0D3h,0D4h
		db	 59h,0C8h, 49h, 88h,0C3h,0CCh
		db	 86h,0C5h, 47h,0CAh,0CCh, 86h
		db	0C5h, 49h, 48h,0CDh, 87h,0D2h
		db	0D3h,0D4h,0C8h,0CAh,0C8h,0CAh
		db	0CCh, 87h,0D2h,0D3h,0D4h, 49h
		db	0C7h,0CAh,0C8h,0CDh, 88h,0C5h
		db	0CAh,0CCh, 85h,0C5h,0C8h,0CAh
		db	0CDh,0CEh, 86h,0C4h,0CAh,0C4h
		db	 48h,0CDh, 87h,0D2h,0D3h,0D4h
		db	0C8h, 49h,0CCh, 82h,0CEh, 85h
		db	0D2h,0D3h,0D4h, 69h,0C8h,0CCh
		db	 88h,0C5h, 49h,0CCh, 84h,0C6h
		db	0C8h,0CCh, 88h,0C4h,0CAh, 58h
		db	0CDh, 87h,0D2h,0D3h,0D4h,0C8h
		db	 59h,0CCh, 8Ah,0C6h, 59h,0C8h
		db	0CDh, 88h,0C5h,0CAh,0CDh, 90h
		db	0C4h, 58h,0CBh,0CDh,0CEh, 86h
		db	0D2h,0D3h,0CAh,0C8h,0CAh,0CBh
		db	0CDh, 8Ch,0C6h,0C5h,0CBh,0CDh
		db	0CEh, 88h,0C5h, 49h,0CCh,0CEh
		db	 8Eh,0C5h,0C9h,0C8h,0CDh,0C3h
		db	0CCh, 87h,0D2h, 49h,0C8h,0CCh
		db	 82h,0CEh, 88h,0CEh, 83h,0C6h
		db	0CAh,0C8h,0CDh,0CCh, 87h,0C5h
		db	 49h,0CCh, 8Fh,0C4h, 47h, 58h
		db	0CDh, 86h,0D2h, 69h,0CCh, 87h
		db	0C3h,0CDh, 86h,0C6h, 47h, 88h
		db	0C5h,0C8h, 49h,0CCh, 8Eh,0C4h
		db	 78h,0CDh, 85h,0C3h,0C9h, 59h
		db	0C8h,0CAh,0CCh, 86h,0C4h,0CAh
		db	0CDh, 88h, 88h,0C4h, 69h,0CDh
		db	 8Dh,0C4h, 48h,0C8h,0CDh,0CEh
		db	 86h,0C4h, 59h, 47h,0CAh,0CCh
		db	 86h,0C4h,0CAh,0C9h,0CCh, 87h
		db	 88h,0C4h,0CBh, 49h,0CDh, 8Eh
		db	0C4h, 48h,0C8h, 48h,0CDh, 85h
		db	0C4h,0C8h, 59h,0C8h, 59h,0CCh
		db	 84h,0C5h,0CAh,0CCh, 88h, 88h
		db	0C4h, 49h,0CBh,0CDh, 81h,0CEh
		db	 8Bh,0C3h,0C4h,0C9h, 47h,0CBh
		db	0CCh, 86h,0C4h, 59h, 47h, 49h
		db	0CCh, 85h,0C6h,0CBh,0CCh, 81h
		db	0CEh, 83h,0C3h,0CAh,0CCh, 88h
		db	0C5h, 49h,0C7h,0CAh,0CCh, 8Ch
		db	0C4h, 58h,0C7h,0CDh,0CEh, 86h
		db	0C4h, 05h, 0Ah,0CCh, 82h,0CEh
		db	 8Bh,0C5h,0CAh,0CDh,0C3h,0CDh
		db	 86h,0C5h, 59h,0CCh, 8Dh,0C4h
		db	 48h,0C8h,0C9h,0CCh, 87h
loc_1:
		les	cx,dword ptr [bx+di-38h]	; Load seg:offset ptr
		pop	cx
		int	8Eh			; ??INT Non-standard interrupt
		db	0C4h,0CAh,0CDh,0CAh,0CDh, 86h
		db	0C4h,0CAh,0CDh, 8Fh,0C5h, 48h
		db	0C8h,0CDh, 88h,0C4h,0CAh,0CDh
		db	0C3h,0CAh,0CDh,0C3h,0CDh, 8Eh
		db	0C4h, 49h,0CCh, 87h,0C6h,0CBh
		db	0CDh, 81h,0CEh, 8Dh,0C5h, 47h
		db	0CDh,0CEh, 88h,0C4h, 06h, 0Ah
		db	0CDh, 87h,0C3h, 79h,0CBh, 49h
		db	0CDh, 81h,0CEh, 97h,0C5h, 47h
		db	0C9h,0CCh, 88h,0C5h,0CAh,0C8h
		db	 69h,0C8h,0CDh, 87h,0C4h,0CAh
		db	 47h, 69h,0CBh,0CAh,0CDh, 98h
		db	0C5h,0C9h,0C8h,0C7h,0CDh,0CEh
		db	 87h,0C5h, 47h, 49h, 47h,0CAh
		db	0CDh,0CEh, 86h,0C4h, 47h,0CBh
		db	 79h,0C7h,0CCh, 98h,0C5h, 68h
		db	0CCh, 87h,0C5h,0C8h, 79h,0CDh
		db	0CEh, 87h,0C4h,0C8h,0CCh,0C3h
		db	 79h,0CDh, 99h,0C5h, 78h,0CBh
		db	0CCh, 85h,0C5h, 49h,0CBh, 49h
		db	 47h,0CDh, 87h,0C4h, 07h, 0Ah
		db	0CEh, 99h,0C5h, 48h,0C7h,0C9h
		db	0CBh,0CDh, 81h,0CEh, 84h,0C5h
		db	 69h,0C7h,0CDh,0C3h,0CAh,0CCh
		db	 86h,0C5h, 59h,0C7h,0CAh,0C8h
		db	0CDh, 81h, 9Ah,0C5h, 05h, 09h
		db	0CDh, 85h,0C5h,0C8h, 59h,0CCh
		db	 84h,0CEh, 85h,0C5h,0CAh,0C7h
		db	 59h,0CDh, 82h, 9Ah,0C5h, 57h
		db	0C9h,0CDh, 87h,0C4h, 59h,0CDh
		db	 81h,0CEh, 89h,0C5h, 79h,0C8h
		db	0CAh,0CCh, 9Ah,0C5h, 47h,0CDh
		db	 82h,0CEh, 86h,0C5h, 49h,0C8h
		db	 49h,0CCh, 81h,0CEh, 87h,0C5h
		db	0C4h,0CAh, 67h,0CCh, 81h, 9Ah
		db	0C5h,0C8h,0C9h,0CDh,0CEh, 88h
		db	0C5h,0CAh, 47h, 59h,0CCh, 82h
		db	0CEh, 85h,0C6h,0C5h,0CAh, 47h
		db	 49h,0C7h,0CDh, 86h,0C3h,0CCh
		db	 88h,0C3h,0CAh,0CDh, 87h,0C5h
		db	 48h,0CCh, 89h,0C5h, 47h,0CBh
		db	0CAh,0CCh,0CAh, 47h,0CDh, 88h
		db	0C6h,0CAh,0C8h,0CAh,0CDh, 82h
		db	 86h,0C4h,0CDh, 88h,0C4h, 49h
		db	0CDh, 86h,0C5h,0CCh,0CEh, 8Ah
		db	0C5h, 07h, 0Ah,0CDh, 89h,0C4h
		db	0C8h,0CCh,0CEh, 82h, 86h,0C4h
		db	0C9h,0CBh,0CDh, 86h,0C4h,0C8h
		db	0CAh,0CDh,0CEh, 85h,0C5h,0CDh
		db	 8Bh,0C5h, 59h,0CDh,0C3h, 69h
		db	0CDh,0CEh, 87h,0C4h,0CAh,0CDh
		db	 83h, 85h,0C3h, 48h,0CCh,0CEh
		db	 86h,0C5h, 47h,0CCh, 86h,0C6h
		db	0CDh, 8Bh,0C5h, 07h, 0Ah,0C8h
		db	0CAh,0CDh, 87h,0C4h,0CAh,0CCh
		db	 81h,0CEh, 81h, 84h,0C3h, 48h
		db	0C8h,0CDh, 87h,0C5h,0C8h,0CAh
		db	0CDh, 86h,0C3h,0CDh, 8Bh,0C5h
		db	0C8h, 69h, 47h,0C7h, 49h,0CBh
		db	0CDh, 86h,0C4h, 49h,0C7h,0CCh
		db	 81h, 84h,0C4h,0C9h, 47h,0C7h
		db	0CCh, 86h,0C5h, 4Ah,0C7h,0CDh
		db	 85h,0C4h,0CDh, 8Bh,0C5h, 49h
		db	0C8h,0CAh, 47h,0CAh,0C8h,0CCh
		db	 81h,0CEh, 87h,0C4h, 49h,0CCh
		db	 82h, 84h,0C4h, 48h,0CDh, 88h
		db	0C4h,0CDh, 81h,0CAh,0CDh, 85h
		db	0C4h,0C9h,0CCh, 8Ah,0C5h,0CAh
		db	0C8h,0CDh,0C6h, 59h,0CDh, 81h
		db	0CEh, 88h,0C5h, 49h,0CDh, 81h
		db	0CEh, 84h,0C4h, 58h,0CDh, 87h
		db	0C4h,0CAh,0CDh,0C6h,0C7h,0CCh
		db	 84h,0C4h,0C9h,0CDh,0CEh, 89h
		db	0C4h,0CAh,0CBh,0CCh, 83h,0C3h
		db	0CAh,0CDh, 89h,0C5h,0CAh,0CCh
		db	 83h, 84h,0C4h,0C9h, 47h,0CDh
		db	0CEh, 86h,0C4h, 49h,0CBh,0CCh
		db	 85h,0C4h,0C9h,0CBh,0CDh, 89h
		db	0C4h,0CAh,0CCh, 84h,0C4h,0CAh
		db	0C8h,0CDh, 88h,0C5h, 49h,0C7h
		db	0CCh,0CEh, 84h,0C5h, 47h,0C9h
		db	0CDh, 87h,0C4h, 59h,0CBh,0CCh
		db	 84h,0C4h, 48h,0CDh,0CEh, 88h
		db	0C4h,0CAh,0CCh,0CEh, 83h,0C4h
		db	 59h,0CCh,0CEh, 86h,0C5h, 49h
		db	0CCh, 82h, 84h,0C5h, 47h,0C9h
		db	0CCh, 87h,0C4h, 59h,0CDh,0CEh
		db	 84h,0C4h, 48h,0CDh, 89h,0C4h
		db	0CAh,0CDh, 84h,0C4h, 59h,0CCh
		db	 87h,0C5h, 49h,0CDh, 82h, 84h
		db	0C5h,0C8h,0CCh, 89h,0C5h, 47h
		db	0CAh,0CCh, 85h,0C5h, 48h,0C8h
		db	0C9h,0CCh, 87h,0C4h,0CAh,0CDh
		db	 84h,0C4h, 59h,0CCh, 81h,0CEh
		db	 85h,0C5h,0CAh,0CCh, 83h, 84h
		db	0C5h,0C9h,0CDh, 82h,0CEh, 86h
		db	0C5h, 47h,0CCh,0CEh, 85h,0C5h
		db	0C9h,0C7h, 48h,0CDh,0CEh, 86h
		db	0C5h,0CAh,0CCh,0CEh, 83h,0C4h
		db	 59h,0CCh, 87h,0C5h,0C8h,0CCh
		db	 83h, 84h,0C5h, 58h,0CDh, 87h
		db	0C5h, 49h,0CCh, 86h,0C5h,0C9h
		db	0C8h,0C9h,0C8h,0CDh, 87h,0C5h
		db	0CAh,0CCh, 84h,0C4h, 49h,0C8h
		db	0C7h,0CDh, 86h,0C5h, 49h,0CDh
		db	 82h, 84h,0C5h, 58h,0CDh, 87h
		db	0C5h,0C6h,0C7h,0CCh, 86h,0C5h
		db	 47h, 48h,0CDh,0CEh, 86h,0C5h
		db	0CAh,0CDh, 84h,0C4h,0CAh,0C7h
		db	0CAh,0CCh, 87h,0C5h, 49h,0C8h
		db	0CCh, 81h, 84h,0C5h,0C9h,0C8h
		db	0CBh,0CCh, 87h,0C6h,0C7h,0CCh
		db	 87h,0C4h, 58h,0C7h,0C9h,0CDh
		db	 86h,0C6h,0CDh, 85h,0C4h, 47h
		db	0CCh, 88h,0C5h,0CAh,0CCh, 83h
		db	 84h,0C5h,0C8h,0C9h,0CDh, 92h
		db	0C4h, 78h,0CCh,0CDh, 8Ch,0C4h
		db	 49h,0CCh, 88h,0C5h, 49h,0CDh
		db	 82h, 84h,0C5h, 48h,0CDh, 92h
		db	0C4h, 05h, 09h,0CAh,0CDh, 8Bh
		db	0C5h, 59h,0CCh, 87h,0C5h,0CAh
		db	0CDh, 81h,0CEh, 81h, 84h,0C5h
		db	 48h,0CDh, 92h,0C4h, 05h, 09h
		db	0C8h,0CDh, 8Bh,0C5h, 49h,0CBh
		db	0CCh, 87h,0C5h, 49h,0CDh, 82h
		db	 84h,0C5h, 48h,0CCh, 92h,0C4h
		db	 58h,0C8h, 48h,0C8h,0CDh,0CEh
		db	 89h,0C3h,0C8h, 49h,0CCh, 88h
		db	0C5h,0C8h,0CAh,0CDh, 82h, 84h
		db	0C5h, 48h,0CDh, 40h, 41h, 60h
		db	 41h, 40h,0C2h, 40h,0C2h,0C1h
		db	 81h,0C4h,0C9h, 47h,0C7h, 48h
		db	0CAh,0CDh, 8Ah,0C4h,0C8h, 59h
		db	0CCh,0CEh, 86h,0C5h,0CAh,0CCh
		db	 83h, 84h,0C4h, 48h,0CDh, 92h
		db	0C5h, 47h, 48h, 47h, 49h,0CDh
		db	 89h,0C4h,0C8h, 59h,0CCh, 87h
		db	0C5h, 49h,0C8h,0CCh, 81h, 84h
		db	0C4h, 48h,0CDh, 92h,0C4h,0C9h
		db	0C8h,0C9h, 47h,0C9h,0CAh,0C8h
		db	0CAh,0CCh, 81h,0C3h,0CAh,0CDh
		db	 84h,0C4h,0C8h, 49h,0C8h,0CCh
		db	 87h,0C5h, 49h,0CCh, 82h, 84h
		db	0C4h, 48h,0CDh,0CEh, 91h,0C4h
		db	0C9h,0C8h,0C9h, 47h,0C9h, 49h
		db	0C8h, 49h, 47h,0CCh, 84h,0C4h
		db	0C8h,0CAh,0C8h,0CCh,0CEh, 87h
		db	0C4h, 49h,0CDh, 82h, 84h,0C4h
		db	0C9h,0C8h,0C9h,0CDh, 91h,0C5h
		db	0C9h, 67h,0C9h, 69h, 47h,0CDh
		db	 85h,0C4h,0C8h,0CAh,0C8h,0CCh
		db	0C3h,0CBh,0CCh, 85h,0C4h,0C8h
		db	0CAh,0CDh, 81h,0CEh, 84h,0C4h
		db	0C8h, 58h,0CDh,0CEh, 8Fh,0C5h
		db	0C9h, 47h,0C9h,0C8h,0C9h,0CAh
		db	0C8h,0CAh,0CDh, 88h,0C4h,0C9h
		db	 59h, 5Ah,0CCh, 84h,0C4h,0CAh
		db	0CCh, 83h, 84h,0C4h,0C8h, 68h
		db	 47h,0CCh, 8Dh,0C5h,0C9h,0C8h
		db	 48h,0C8h,0C9h,0C8h,0CAh,0CCh
		db	 88h,0C3h,0C4h,0C9h, 59h,0CBh
		db	0CCh, 86h,0C4h, 49h,0CDh, 82h
		db	 84h,0C4h, 09h, 09h, 46h,0CCh
		db	 88h,0C5h, 48h,0C7h, 58h, 49h
		db	0CDh, 81h,0CEh, 86h, 43h,0C9h
		db	 49h,0CDh, 81h,0CEh, 86h,0C4h
		db	 49h,0C8h,0CCh, 81h, 84h,0C4h
		db	 05h, 09h, 67h, 78h,0CCh, 85h
		db	0C5h,0C9h,0C8h, 68h, 49h,0CCh
		db	0CEh, 86h,0C3h, 53h, 59h,0CCh
		db	 87h,0C4h, 49h,0CCh,0CEh, 81h
		db	 84h,0C4h, 58h, 06h, 08h, 58h
		db	0C8h, 48h,0CCh, 83h,0C3h,0C9h
		db	0C8h, 78h,0C8h,0C7h,0CDh, 87h
		db	 63h, 59h,0CCh, 87h,0C4h, 49h
		db	0CDh, 82h, 84h,0C4h, 48h, 07h
		db	 08h,0C7h,0CCh,0C3h,0C8h, 48h
		db	 47h, 78h,0C8h,0C9h,0C8h, 48h
		db	0CAh,0CBh,0CDh, 86h,0C3h, 43h
		db	 69h,0CCh, 88h,0C4h, 49h,0CDh
		db	 82h, 84h,0C4h,0C7h, 58h, 77h
		db	0C7h,0CCh,0C3h,0C9h,0C8h,0C9h
		db	 47h, 48h,0C8h, 48h, 67h,0C9h
		db	0CDh,0CEh, 87h,0C3h, 43h, 59h
		db	0CBh,0CCh, 81h,0CEh, 87h,0C5h
		db	0C4h,0CCh, 81h,0CEh, 81h, 84h
		db	0C4h, 58h, 05h
		db	8, 'hWHGHGh'
		db	0CDh, 87h, 43h, 59h,0C8h,0CDh
		db	 8Ah,0C5h, 49h,0CCh, 82h, 84h
		db	0C4h, 58h, 0Bh, 08h, 58h, 57h
		db	0C9h, 47h, 68h,0C7h,0CDh, 85h
		db	0C3h, 43h, 59h,0C8h,0CDh, 81h
		db	0CEh, 88h,0C5h, 49h,0C8h,0CBh
		db	0CDh, 84h,0C4h, 58h, 08h, 08h
		db	0C9h,0C8h, 58h, 67h, 05h, 09h
		db	0CBh,0CCh, 86h, 53h,0CAh, 53h
		db	0CCh, 8Ah,0C5h,0CAh, 47h,0CCh
		db	 81h, 84h,0C4h, 58h, 06h, 08h
		db	0C9h,0C8h,0C9h,0C8h,0C9h,0C8h
		db	0C9h, 47h,0C9h,0C8h,0C7h,0C9h
		db	0C8h, 48h,0CCh, 88h, 53h,0CAh
		db	0C4h,0CAh,0C4h,0CCh,0CEh, 89h
		db	0C5h,0C8h,0CCh, 83h, 84h,0C5h
		db	 48h, 07h, 08h, 58h,0C8h,0C9h
		db	0C8h,0C9h,0C8h, 78h,0C8h, 48h
		db	0CDh, 88h, 53h, 49h, 43h,0CDh
		db	 8Ah,0C4h, 49h,0CBh,0CDh, 81h
		db	 84h,0C5h, 47h,0C9h, 67h,0C9h
		db	 77h, 48h, 57h, 78h,0C8h, 58h
		db	0CCh,0CEh, 86h, 63h, 49h,0C4h
		db	0CDh, 81h,0CEh, 88h,0C4h, 49h
		db	0CDh, 82h, 84h,0C5h,0C8h, 48h
		db	 07h, 08h, 58h,0C8h,0C9h,0C8h
		db	 48h, 82h, 67h, 48h,0CDh, 87h
		db	 43h,0CAh,0C4h, 49h,0C4h,0CCh
		db	 8Ah,0C4h, 49h,0CCh, 81h,0CEh
		db	 84h,0C5h, 58h, 77h,0C7h,0C9h
		db	 67h,0C9h,0C7h, 48h,0C7h, 82h
		db	0C8h, 05h, 09h,0CDh,0CEh, 85h
		db	0C5h,0C4h, 59h,0C5h,0CAh,0CCh
		db	 8Ah,0C4h,0CAh,0C8h,0CCh, 82h
		db	 84h,0C5h, 58h, 09h, 08h,0C9h
		db	0C7h, 4Ah,0CEh, 83h,0C4h, 05h
		db	 09h,0C8h,0CDh, 85h,0C5h,0C4h
		db	 59h,0C5h,0CAh,0CDh, 8Ah,0C4h
		db	 47h,0CDh, 82h, 84h,0C5h, 58h
		db	 47h,0C9h, 05h, 08h, 48h,0CBh
		db	0CDh,0CEh, 84h,0C4h, 48h,0C8h
		db	 58h,0C8h,0CDh, 85h,0C5h,0C4h
		db	 79h,0CDh, 8Ah,0C5h, 47h,0CAh
		db	0CDh, 81h, 84h,0C5h,0C9h, 47h
		db	0C7h,0C9h,0CBh,0C8h,0C5h,0C9h
		db	 67h, 46h,0CCh, 85h,0C4h,0C9h
		db	0C8h, 58h,0C8h,0CAh,0CDh, 85h
		db	0C5h,0C4h, 79h,0CDh, 8Ah,0C5h
		db	0CAh,0CDh, 82h,0CEh, 84h,0C5h
		db	0CCh,0C6h,0CBh,0CDh, 83h,0C6h
		db	0C9h,0C8h, 48h,0C8h,0C7h,0CCh
		db	 86h,0C4h, 47h, 68h,0CAh,0CDh
		db	 85h,0C5h, 05h, 0Ah,0CDh, 83h
		db	0C3h,0CDh, 85h,0C5h,0CDh,0C3h
		db	0CCh, 82h, 84h,0C5h,0CAh,0CDh
		db	 86h,0C4h, 68h,0CDh, 87h,0C4h
		db	0C8h, 78h,0CAh,0CDh, 85h,0C5h
		db	 79h,0CDh, 84h,0C5h,0CDh, 85h
		db	0C5h, 49h,0CCh,0CEh, 81h, 84h
		db	0C5h,0CCh, 87h,0C4h,0C8h,0C9h
		db	0C8h,0C7h,0CDh, 87h,0C4h, 05h
		db	 09h,0CDh, 86h,0C5h, 79h,0CDh
		db	 84h,0C5h,0CDh, 85h,0C5h,0C4h
		db	0C8h,0CDh, 82h, 84h,0CAh,0C9h
		db	0CDh, 86h,0C4h,0C8h, 48h,0CAh
		db	0C7h,0CCh, 86h,0C5h,0C9h, 47h
		db	0C7h,0C9h,0CDh, 87h,0C5h, 69h
		db	0CCh, 85h,0C5h,0CDh, 85h,0C5h
		db	0C4h,0CCh, 83h, 84h,0CAh,0CDh
		db	 87h,0C4h,0C8h, 48h,0CAh,0CDh
		db	 87h,0C5h, 47h, 58h,0CDh, 87h
		db	0C4h, 69h,0CDh, 85h,0C5h,0CAh
		db	0CDh, 84h,0C6h,0CBh,0CDh, 83h
		db	 83h,0D0h,0CAh,0CBh,0CCh, 86h
		db	0C4h, 58h,0CDh,0CEh, 87h,0C5h
		db	 68h,0C8h,0CDh, 87h,0C4h, 69h
		db	0CDh, 85h,0C5h,0CAh,0CDh, 8Ah
		db	 82h,0D0h,0C8h,0CAh,0CDh, 87h
		db	0C4h,0C8h, 48h,0C8h,0CDh, 87h
		db	0C5h, 58h, 47h,0CDh, 87h,0C4h
		db	 69h,0CCh, 85h,0C5h,0CAh,0CCh
		db	 81h,0CEh, 88h, 81h,0D0h, 47h
		db	0CCh, 88h,0C4h, 48h,0C8h,0C7h
		db	0CDh,0CEh, 86h,0C6h, 57h,0CCh
		db	0C6h,0CDh, 87h,0C4h, 59h,0CCh
		db	 86h,0C5h, 49h,0CDh, 89h, 81h
		db	 57h,0CAh,0CDh, 87h,0C4h, 58h
		db	0CCh, 96h,0C4h, 59h,0CCh, 86h
		db	0C5h,0CAh,0C8h,0CCh, 89h, 81h
		db	0C4h,0CAh,0C8h,0CAh,0CCh, 87h
		db	0C5h, 58h,0C8h,0CBh,0CDh, 40h
		db	 41h, 70h,0C2h, 40h,0C2h, 60h
		db	 83h,0C4h, 49h,0CCh, 81h,0CEh
		db	 85h,0C5h,0CAh,0C8h,0CDh, 89h
		db	 81h,0C4h, 47h, 49h,0CDh, 86h
		db	0C5h, 58h,0CAh,0CDh, 95h,0C4h
		db	 49h,0CCh, 87h,0C5h,0CAh,0C8h
		db	0CBh,0CDh, 88h, 81h,0C4h, 47h
		db	0C7h,0CDh, 87h,0C5h, 48h,0C8h
		db	0CCh, 88h,0C3h,0C7h, 68h,0CDh
		db	 87h,0C4h,0CAh,0CCh, 88h,0C5h
		db	0CAh,0C8h,0C9h,0CCh,0CEh, 87h
		db	 81h,0C4h, 47h,0CDh, 88h,0C5h
		db	 48h,0C8h,0CDh, 88h,0C4h, 79h
		db	0C9h,0CDh, 85h,0C3h,0C4h,0CAh
		db	0CCh, 81h,0CEh, 86h,0C4h,0CAh
		db	0C8h,0C9h,0CCh, 88h, 81h,0C4h
		db	 47h,0CDh, 88h,0C5h, 47h,0CCh
		db	 81h,0CEh, 87h,0C4h, 59h,0C7h
		db	 49h,0CCh, 84h,0C3h, 43h,0CCh
		db	 89h,0C4h,0C9h,0CBh, 46h,0CCh
		db	 87h, 81h,0C4h, 47h,0CCh, 88h
		db	0C5h,0C9h,0CDh, 81h,0CEh, 88h
		db	0C4h, 07h, 0Ah, 47h, 69h,0CDh
		db	 89h,0C4h,0CCh,0CEh,0C6h, 46h
		db	0CCh, 86h,0C3h,0C4h,0C8h,0CAh
		db	0CCh, 88h,0C5h, 58h,0CDh, 88h
		db	0C4h, 06h, 0Ah, 67h, 59h,0CCh
		db	0CEh, 88h,0C4h,0C7h,0CCh,0C3h
		db	0C7h,0C8h,0CBh,0C7h,0CDh, 84h
		db	 43h,0C8h,0CAh,0CDh, 88h,0C5h
		db	 58h,0CAh,0CDh, 87h,0C5h,0CAh
		db	0C8h, 69h, 47h,0CBh,0CCh,0C6h
		db	 69h,0CCh, 88h,0C4h,0C7h,0C9h
		db	0C8h,0C9h,0C8h,0C7h, 47h, 56h
		db	0CDh, 67h,0CDh, 88h,0C5h, 58h
		db	0CAh,0CCh, 87h,0C5h,0CAh,0C8h
		db	 59h, 47h,0C7h,0CDh, 83h,0C4h
		db	 49h,0CCh, 81h,0CEh, 86h,0C5h
		db	0CAh, 47h,0CCh, 81h,0C6h,0CBh
		db	 67h,0C9h, 47h,0C9h,0CCh, 89h
		db	0C5h,0C7h, 48h,0CCh, 88h,0C5h
		db	0C8h, 59h,0C8h,0CBh,0CDh, 85h
		db	0C4h, 59h,0CCh, 87h,0C5h,0CAh
		db	0C7h,0CCh, 84h,0C5h,0C7h, 57h
		db	 47h, 49h,0CDh, 88h,0C5h,0C9h
		db	0C8h,0C9h,0CDh,0CEh, 87h,0C5h
		db	 69h,0CCh, 87h,0C4h, 49h,0C8h
		db	0CCh, 87h,0C5h,0CAh,0CCh, 81h
		db	0CEh, 83h,0C6h,0CBh,0C8h,0CDh
		db	0C6h,0C5h, 43h,0CAh,0CDh, 88h
		db	0C5h, 47h,0CDh, 89h,0C5h, 79h
		db	0CCh,0CEh, 85h,0C4h, 47h,0CCh
		db	 88h,0C5h,0CAh,0CCh, 87h,0C5h
		db	0CDh, 81h, 47h,0CAh,0CCh, 82h
		db	0CEh, 86h,0C5h,0C8h,0C7h,0C9h
		db	0CAh,0CDh, 87h,0C5h,0C8h,0CAh
		db	0C8h, 59h,0CCh, 85h,0C4h,0C8h
		db	 49h,0CCh,0CEh, 86h,0C5h,0CAh
		db	0C8h,0CCh, 86h,0C6h,0C8h,0C7h
		db	 47h,0CDh, 8Ah,0C5h, 58h,0CAh
		db	0CDh,0CEh, 86h,0C5h,0C8h, 59h
		db	0CBh,0CDh, 86h,0C4h, 59h,0CCh
		db	 87h,0C5h,0CAh,0C8h,0CCh, 81h
		db	0CEh, 85h,0C5h,0C8h, 47h,0CAh
		db	0CCh, 89h,0C5h, 58h,0C7h,0CCh
		db	 87h,0C5h, 57h,0CAh,0CCh, 81h
		db	0CEh, 85h,0C4h, 49h,0C7h,0CCh
		db	 87h,0C5h,0CAh,0C8h,0CCh, 87h
		db	0C6h,0C5h,0C8h,0C4h,0C9h,0CAh
		db	0CDh,0CEh, 87h,0C4h, 58h,0CDh
		db	 81h,0CEh, 86h,0C5h, 47h, 59h
		db	0CDh, 86h,0C4h, 69h,0CCh, 86h
		db	0C4h, 49h,0CCh, 88h,0C6h,0C6h
		db	0C4h,0C9h, 49h,0CDh, 87h,0C4h
		db	 48h,0C7h,0CAh,0CDh, 87h,0C4h
		db	 49h,0C8h, 59h,0CCh, 85h,0C4h
		db	 69h,0CCh,0CEh, 85h,0C4h,0CAh
		db	 47h,0CCh, 88h, 81h,0C4h,0C9h
		db	0C8h,0CDh, 88h,0C9h, 47h,0CBh
		db	0CDh, 88h,0C6h, 69h,0C8h,0CAh
		db	0CCh, 85h,0C4h, 49h,0CBh,0CCh
		db	 87h,0C4h, 57h, 89h, 81h,0C4h
		db	0C9h,0CDh, 81h,0CEh, 87h,0C4h
		db	0C8h,0C9h,0CDh, 81h,0CEh, 88h
		db	0C4h, 49h, 47h,0CCh, 86h,0C5h
		db	 47h, 49h,0CDh, 86h,0C4h,0CAh
		db	0C7h,0CCh, 89h, 81h,0C4h,0C9h
		db	0CAh,0CCh, 88h,0C4h, 58h,0CAh
		db	0CDh, 88h,0C4h,0CAh, 57h,0CCh
		db	 86h,0C5h,0C8h,0CAh,0C7h,0CAh
		db	0CCh, 86h,0C6h,0CAh,0CCh, 8Ah
		db	 81h,0C4h,0C9h, 49h,0CDh, 87h
		db	0C4h, 58h,0CAh,0CDh, 88h, 43h
		db	0C7h,0CAh,0CCh,0CEh, 86h,0C5h
		db	0C8h, 49h,0CCh, 94h, 81h,0C4h
		db	0C9h,0CAh,0C7h,0CDh, 87h,0C4h
		db	 58h,0CAh,0CCh, 88h, 43h,0CAh
		db	 4Bh, 81h,0CEh, 85h,0C6h, 69h
		db	0CCh, 93h, 81h,0C4h,0C9h, 49h
		db	0CCh, 87h,0C5h, 58h,0C7h,0CDh
		db	 88h, 43h,0CAh,0CCh,0C3h,0CCh
		db	 87h,0C4h,0CAh, 4Ah,0CDh,0C3h
		db	0CCh,0C3h,0CCh, 8Fh, 81h,0C4h
		db	0C8h,0CCh, 89h,0C5h, 48h,0C7h
		db	0CDh, 81h,0CEh, 87h, 43h, 59h
		db	0C7h,0CCh, 86h,0C4h,0CCh,0C3h
		db	0CCh, 81h, 59h,0CCh, 8Fh, 81h
		db	0C8h,0CBh,0CCh, 89h,0C5h, 58h
		db	0CAh,0CCh, 88h, 43h, 69h,0C7h
		db	0CCh, 85h,0C4h, 59h,0C7h, 49h
		db	0C8h, 05h, 0Ah,0CDh, 89h, 81h
		db	0C4h,0CCh, 81h,0CEh, 88h,0C5h
		db	 48h,0C8h,0CAh,0CDh, 88h, 43h
		db	0CAh, 47h,0C7h,0CCh, 86h,0C4h
		db	 79h,0C8h, 59h,0C8h, 4Ah,0CCh
		db	 8Ah, 81h,0C4h,0CCh, 8Ah,0C5h
		db	 57h,0CAh,0CDh,0CEh, 87h, 43h
		db	0C8h,0CAh,0C8h,0CCh, 87h,0C4h
		db	0CAh,0C8h, 79h,0C8h,0CAh,0CCh
		db	 8Dh, 81h,0C4h,0C5h,0CCh, 89h
		db	0C5h, 47h,0CBh,0CCh, 89h, 43h
		db	 47h,0CAh,0CCh,0CEh, 86h,0C4h
		db	0C8h, 59h, 47h,0CBh,0CCh, 8Fh
		db	 81h,0C5h,0C8h,0CBh,0CCh, 88h
		db	0C5h, 47h,0CDh, 81h,0CEh, 88h
		db	0C4h,0C8h,0CAh,0C7h,0CAh,0CCh
		db	 87h,0C4h,0C8h, 49h,0C8h,0CDh
		db	 92h, 81h,0C5h,0C8h,0CCh, 89h
		db	0C5h, 58h,0CDh, 89h,0C4h,0C8h
		db	 49h,0CCh, 88h,0C6h, 69h,0CBh
		db	0CDh, 70h,0C2h,0C1h,0C2h, 70h
		db	0C2h, 50h, 81h,0C5h, 47h,0CCh
		db	 88h,0C5h, 58h,0CAh,0CDh, 88h
		db	0C4h,0C5h, 49h,0CCh, 89h,0C5h
		db	0CAh,0CBh,0CCh, 93h, 66h, 00h
		db	 3Dh, 7Ch, 00h, 3Dh, 80h, 00h
		db	 3Ch, 9Dh, 00h, 10h, 9Dh, 00h
		db	 27h,0FFh,0FFh,0FFh,0FFh, 42h
		db	 40h,0B9h, 3Eh, 00h, 46h, 00h
		db	 71h, 40h,0B5h, 6Dh, 00h, 78h
		db	 00h, 75h, 80h,0A7h, 72h, 00h
		db	 79h, 00h, 81h, 80h, 91h, 79h
		db	 00h, 8Ah, 00h, 87h, 40h, 88h
		db	 84h, 00h, 8Ch, 00h,0FFh,0FFh
		db	 2Fh,0D7h, 01h, 03h
		db	',Danger!!/ Don\t open/'
		db	14h
		db	'the box ahead.'
		db	0FFh, 06h, 00h, 3Dh,0C0h, 02h
		db	0D1h, 00h,0FFh, 00h,0FFh,0FFh
		db	0FFh, 5Fh, 00h, 23h, 42h, 03h
		db	 0Fh, 00h, 23h, 00h, 0Bh, 00h
		db	 80h, 92h, 00h, 23h, 82h, 03h
		db	 42h, 00h, 23h, 00h,0FFh,0FFh
		db	0FFh,0ABh, 00h, 36h, 01h, 04h
		db	 18h, 00h, 12h, 00h, 0Bh, 00h
		db	 40h,0BEh, 00h, 2Fh,0C2h, 04h
		db	 29h, 00h, 12h, 00h,0FFh,0FFh
		db	0FFh,0CDh, 00h, 2Fh, 40h, 05h
		db	 15h, 00h, 06h, 00h, 0Bh, 00h
		db	 20h,0FFh,0FFh, 08h, 00h,0FFh
		db	 13h,0C0h,0FFh,0FFh,0FFh,0FFh
		db	 0Ah, 00h, 80h, 5Dh,0D9h, 00h
		db	 00h, 5Ah,0D9h, 03h, 29h,0FFh
		db	0FFh, 0Ah, 00h, 40h, 84h,0D9h
		db	 00h,0FFh, 8Fh,0D9h,0FFh,0FFh
		db	0FFh,0FFh, 0Ah, 00h, 20h, 44h
		db	0DAh, 00h,0FFh, 4Fh,0DAh,0FFh
		db	0FFh,0FFh,0FFh, 0Ah, 00h, 10h
		db	0FDh,0DAh, 00h, 00h,0FFh,0FFh
		db	 0Ah, 00h, 08h, 14h,0DBh, 00h
		db	0FFh, 1Fh,0DBh,0FFh,0FFh,0FFh
		db	0FFh, 0Ah, 00h, 04h, 44h,0DBh
		db	 00h,0FFh, 4Fh,0DBh,0FFh,0FFh
		db	0FFh,0FFh, 0Bh, 00h, 80h, 66h
		db	0D7h,0C2h, 03h,0FFh,0FFh, 0Bh
		db	 00h, 40h, 7Eh,0D7h, 81h, 04h
		db	0FFh,0FFh, 0Bh, 00h, 20h, 96h
		db	0D7h,0C0h, 05h,0FFh,0FFh, 0Bh
		db	 00h, 04h,0CDh,0D8h, 00h, 00h
		db	0FFh,0FFh,0FFh,0FFh, 16h,0AFh
		db	 02h, 11h
		db	'Cavern of Peligro'
		db	 0Bh, 00h, 01h, 02h, 02h, 02h
		db	 00h, 13h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 02h, 00h
		db	 13h, 04h, 00h, 0Bh, 00h, 32h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 0Bh, 00h, 32h, 02h
		db	 00h, 0Ch, 00h, 0Bh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 0Ch, 00h, 0Bh, 02h, 00h, 10h
		db	 00h, 19h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 10h, 00h
		db	 19h, 03h, 00h, 14h, 00h, 28h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 14h, 00h, 28h, 02h
		db	 00h, 20h, 00h, 28h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 20h, 00h, 28h, 02h, 00h, 21h
		db	 00h, 1Bh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 21h, 00h
		db	 1Bh, 03h, 00h, 24h, 00h, 37h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 24h, 00h, 37h, 02h
		db	 00h, 26h, 00h, 0Dh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 26h, 00h, 0Dh, 02h, 00h, 2Fh
		db	 00h, 3Fh,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 18h, 00h, 0Bh, 00h
		db	 04h, 00h, 00h, 34h, 00h, 37h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 34h, 00h, 37h, 02h
		db	 00h, 37h, 00h, 0Dh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 37h, 00h, 0Dh, 03h, 00h, 38h
		db	 00h, 2Ch,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 38h, 00h
		db	 2Ch, 02h, 00h, 43h, 00h, 22h
		db	0FFh, 7Ch, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh,0FFh, 00h
		db	 00h, 44h, 00h, 2Ah,0FFh, 00h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 44h, 00h, 2Ah, 00h, 00h, 44h
		db	 00h, 2Ch,0FFh, 01h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 44h, 00h
		db	 2Ch, 01h, 00h, 47h, 00h, 0Dh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 47h, 00h, 0Dh, 02h
		db	 00h, 47h, 00h, 17h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 47h, 00h, 17h, 02h, 00h, 47h
		db	 00h, 22h,0FFh, 73h, 00h, 00h
		db	 29h, 00h, 05h, 00h, 0Ah, 00h
		db	 80h, 00h, 00h, 52h, 00h, 37h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 52h, 00h, 37h, 02h
		db	 00h, 53h, 00h, 13h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 53h, 00h, 13h, 04h, 00h, 59h
		db	 00h, 2Ch,0FFh, 76h, 00h, 00h
		db	 20h, 00h, 00h, 00h, 0Ah, 00h
		db	 40h, 00h, 00h, 59h, 00h, 31h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 59h, 00h, 31h, 04h
		db	 00h, 5Dh, 00h, 0Eh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 5Dh, 00h, 0Eh, 03h, 00h, 6Bh
		db	 00h, 17h,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 6Bh, 00h
		db	 17h, 00h, 00h, 6Bh, 00h, 19h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 6Bh, 00h, 19h, 01h
		db	 00h, 6Dh, 00h, 0Eh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 6Dh, 00h, 0Eh, 02h, 00h, 82h
		db	 00h, 1Fh,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 82h, 00h
		db	 1Fh, 04h, 00h, 82h, 00h, 25h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 82h, 00h, 25h, 02h
		db	 00h, 89h, 00h, 2Eh,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 89h, 00h, 2Eh, 04h, 00h, 8Eh
		db	 00h, 38h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 8Eh, 00h
		db	 38h, 02h, 00h, 8Fh, 00h, 1Ch
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 8Fh, 00h, 1Ch, 04h
		db	 00h, 93h, 00h, 0Eh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 93h, 00h, 0Eh, 02h, 00h, 95h
		db	 00h, 2Ch,0FFh, 76h, 00h, 00h
		db	 20h, 00h, 00h, 00h, 0Ah, 00h
		db	 20h, 00h, 00h, 98h, 00h, 07h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 98h, 00h, 07h, 04h
		db	 00h, 9Ch, 00h, 32h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 9Ch, 00h, 32h, 04h, 00h, 9Ch
		db	 00h, 38h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 9Ch, 00h
		db	 38h, 03h, 00h,0A2h, 00h, 33h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0A2h, 00h, 33h, 04h
		db	 00h,0A3h, 00h, 02h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0A3h, 00h, 02h, 03h, 00h,0A4h
		db	 00h, 09h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0A4h, 00h
		db	 09h, 04h, 00h,0A8h, 00h, 18h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0A8h, 00h, 18h, 03h
		db	 00h,0ACh, 00h, 22h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0ACh, 00h, 22h, 04h, 00h,0B0h
		db	 00h, 20h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B0h, 00h
		db	 20h, 04h, 00h,0B3h, 00h, 02h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0B3h, 00h, 02h, 03h
		db	 00h,0B3h, 00h, 18h,0FFh,0D0h
		db	 00h, 00h, 20h, 00h, 18h, 00h
		db	 0Ah, 00h, 10h, 00h, 00h,0B8h
		db	 00h, 18h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B8h, 00h
		db	 18h, 02h, 00h,0B9h, 00h, 0Bh
		db	0FFh, 73h, 00h, 01h, 20h, 00h
		db	 00h, 00h, 0Ah, 00h, 08h, 00h
		db	 00h,0C3h, 00h, 3Fh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0C3h, 00h, 3Fh, 02h, 00h,0C6h
		db	 00h, 05h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C6h, 00h
		db	 05h, 04h, 00h,0C9h, 00h, 25h
		db	0FFh, 73h, 00h, 03h, 20h, 00h
		db	 00h, 00h, 0Ah, 00h, 04h, 00h
		db	 00h,0D2h, 00h, 25h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0D2h, 00h, 25h, 02h, 00h,0D3h
		db	 00h, 0Bh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0D3h, 00h
		db	 0Bh, 02h, 00h,0D3h, 00h, 17h
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0D3h, 00h, 17h, 00h
		db	 00h,0D3h, 00h, 19h,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	0D3h, 00h, 19h, 01h, 00h,0D8h
		db	 00h, 26h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0D8h, 00h
		db	 26h, 02h, 00h,0DEh, 00h, 19h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0DEh, 00h, 19h, 03h
		db	 00h,0FFh,0FFh

zr3_22		endp

seg_a		ends



		end	start
