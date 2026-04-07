
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_344MP81                                 лл
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

_344MP81	proc	far

start:
		pop	ds
		sbb	ax,0
		db	0C8h,0D8h, 00h, 01h, 5Ah,0D7h
		db	 7Dh,0D7h, 82h,0D7h,0A0h,0D7h
		db	 3Eh,0D8h,0B3h,0D8h,0CDh,0D8h
		db	 08h,0DEh, 00h, 14h, 0Ah, 00h
		db	 00h, 5Ah,0D7h, 85h,0C4h, 46h
		db	0CCh,0C7h,0CBh, 46h,0C9h, 46h
		db	 85h,0C4h, 46h,0CAh,0CCh,0CBh
		db	 06h, 07h, 88h,0C4h,0CAh,0CCh
		db	 08h, 07h,0CCh,0C9h, 76h,0CCh
		db	 82h, 85h,0C5h, 56h,0C9h, 05h
		db	 07h, 85h,0C4h, 09h, 07h,0CCh
		db	0CBh, 88h,0C5h, 46h,0CBh, 05h
		db	 07h,0CAh,0CCh, 08h, 07h, 81h
		db	 85h,0C4h, 56h,0CCh,0C7h, 4Bh
		db	 56h, 85h,0C4h, 76h,0CBh,0CCh
		db	 76h,0C8h, 87h,0C4h,0C7h,0C9h
		db	 46h,0C9h,0CCh, 76h,0CCh, 05h
		db	 07h,0CBh,0C7h, 81h, 85h,0C5h
		db	 66h,0CAh,0C7h,0CCh,0CBh, 46h
		db	 85h,0C5h, 46h,0CBh, 46h,0CCh
		db	 05h, 07h,0C8h, 87h,0C4h, 06h
		db	 07h,0CBh, 56h, 81h, 56h,0CAh
		db	0CBh, 56h, 81h, 85h,0C4h,0C7h
		db	0C9h, 07h, 07h, 85h,0C4h, 56h
		db	 81h, 46h,0CCh,0C9h, 46h,0CCh
		db	 46h, 87h,0C4h, 76h,0CAh, 4Bh
		db	 85h,0C4h, 46h,0CBh, 56h, 81h
		db	 85h,0C4h, 05h, 07h,0C9h, 46h
		db	 86h,0C6h, 87h, 56h,0CAh,0CBh
		db	0C7h, 87h,0C6h,0C7h, 81h, 46h
		db	 81h, 56h, 85h,0C5h, 46h,0C9h
		db	 46h,0C8h, 81h, 85h,0C4h, 09h
		db	 07h, 8Eh, 76h,0C8h, 94h,0C4h
		db	 76h,0C8h, 81h, 85h,0C4h, 07h
		db	 07h,0CCh,0C7h, 8Fh,0E9h,0E5h
		db	 46h,0C8h, 94h,0C4h,0CAh,0CCh
		db	 66h, 81h, 85h,0C4h, 56h,0C9h
		db	0CAh,0CCh,0C7h,0CCh,0CBh,0C7h
		db	 8Fh,0E5h,0E9h,0E5h,0CAh,0CCh
		db	0C7h, 93h,0C4h,0C7h,0C9h,0CCh
		db	 46h,0C8h, 81h, 85h,0C4h, 66h
		db	0CAh,0CCh,0CBh, 56h, 8Fh,0E9h
		db	0E5h, 56h,0CCh, 46h,0C9h, 05h
		db	 07h,0CBh, 46h, 87h,0C4h, 05h
		db	 07h, 81h, 85h,0C4h,0CAh,0CCh
		db	 66h,0CCh, 56h, 8Fh,0E5h,0E9h
		db	0E5h, 05h, 07h,0CBh,0C7h,0CCh
		db	 06h, 07h, 86h,0C4h, 66h,0CBh
		db	0C7h,0C8h, 85h,0C4h, 46h,0CBh
		db	 06h, 07h, 8Fh,0E9h,0E5h,0C9h
		db	 06h, 07h,0CBh,0C7h,0C9h,0C7h
		db	0C9h, 66h, 86h,0C5h, 05h, 07h
		db	0C8h, 85h,0C4h,0C7h,0CAh,0CCh
		db	 46h,0C9h, 56h, 90h,0E5h,0C7h
		db	0E5h,0C7h,0CAh,0C9h, 56h,0C9h
		db	 08h, 07h, 86h,0C5h, 46h,0C9h
		db	 66h, 85h,0C5h,0C7h,0CAh, 4Bh
		db	 05h, 07h, 8Fh,0E9h,0E5h,0C9h
		db	 56h,0CBh, 76h,0CAh,0CCh,0C7h
		db	0C9h, 56h, 86h,0C4h,0CAh, 56h
		db	0CAh, 46h, 85h,0C4h, 56h,0CCh
		db	 66h,0C9h,0C7h, 8Fh,0E5h,0E9h
		db	0E5h,0C7h,0C9h, 46h, 84h,0C4h
		db	 05h, 07h,0C8h, 86h,0C4h, 76h
		db	0CCh,0C7h, 85h,0C4h, 76h,0CAh
		db	 66h, 86h,0CFh, 88h,0E9h,0E5h
		db	0C7h,0CCh, 46h, 85h,0C5h,0C7h
		db	0C9h, 56h,0C8h, 87h,0C4h,0C7h
		db	0CCh, 66h,0CBh, 85h,0C5h,0C7h
		db	0C9h,0C7h,0CBh, 05h, 07h, 85h
		db	0CFh,0C7h, 88h,0E5h,0E9h,0E5h
		db	 46h, 86h,0C4h,0CCh,0CBh, 66h
		db	0C8h, 86h,0C4h,0CAh,0C7h,0CCh
		db	 66h, 85h,0C4h, 76h,0CAh, 66h
		db	 84h,0CFh, 46h, 88h,0E9h,0E5h
		db	0CAh,0C9h,0CBh,0C7h, 85h,0C4h
		db	 05h, 07h, 87h,0C4h, 06h, 07h
		db	 85h,0C4h, 66h,0C9h,0C7h,0CCh
		db	0CBh, 86h,0C4h,0C7h,0C9h, 88h
		db	0E5h,0C7h,0E5h, 56h, 85h,0C4h
		db	 46h,0CCh, 56h, 87h,0C5h, 56h
		db	0C9h,0C7h,0CBh,0C8h, 85h,0C6h
		db	 81h, 05h, 07h,0CAh, 86h,0D0h
		db	0C9h,0C7h, 88h,0E9h,0E5h, 66h
		db	 85h,0C4h, 46h,0CAh,0CCh,0C8h
		db	 88h,0C4h,0C7h,0CCh, 56h,0CAh
		db	0C8h, 8Bh,0C4h,0C7h,0C9h,0CCh
		db	 86h,0D0h,0C7h, 88h,0E5h,0E9h
		db	0E5h,0CAh,0C9h,0C7h, 85h,0C5h
		db	 76h, 88h,0C5h, 06h, 07h,0C1h
		db	 51h, 50h,0C2h,0C1h,0C2h, 81h
		db	0C4h,0C7h,0CCh, 46h, 86h,0D0h
		db	 88h,0E9h,0E5h,0C9h, 56h, 85h
		db	0C4h,0C7h,0C9h, 66h, 87h,0C4h
		db	0C9h,0C7h,0CCh,0C9h,0CCh, 46h
		db	 8Bh,0C4h,0C9h,0CAh,0CBh,0C7h
		db	 8Fh,0E5h,0C7h,0E5h,0C7h,0CCh
		db	0C7h, 85h,0C4h, 76h, 88h,0C4h
		db	 66h,0CBh, 46h, 84h,0C3h,0C7h
		db	 85h,0C5h, 66h, 8Fh,0E9h,0E5h
		db	0CAh,0C9h,0CCh,0C7h, 85h,0C4h
		db	 05h, 07h, 87h,0C6h, 81h, 46h
		db	 81h, 46h, 81h, 82h,0C3h, 66h
		db	 84h,0C4h,0C7h,0C9h, 46h, 8Fh
		db	0E5h,0E9h,0E5h, 46h,0CBh, 85h
		db	0C4h,0CAh,0CCh, 66h, 8Fh, 82h
		db	0C4h, 66h, 84h,0C4h, 66h, 8Fh
		db	0E9h,0E5h, 66h, 85h,0C4h, 46h
		db	0CAh,0CCh,0CBh,0C7h, 8Fh, 82h
		db	0C3h, 56h, 85h,0C4h, 46h, 4Bh
		db	0C7h, 8Eh,0E5h,0E9h,0E5h, 56h
		db	 85h,0C4h, 46h,0C9h, 46h, 90h
		db	 82h,0C4h,0C9h,0C7h,0CCh,0C7h
		db	 84h,0C5h,0C7h,0C9h,0C7h,0CBh
		db	0C7h, 8Fh,0E5h, 66h, 85h,0C6h
		db	 82h,0C7h, 81h,0C7h, 88h,0C3h
		db	 46h, 81h,0C7h, 83h, 82h,0C5h
		db	 56h, 85h,0C5h, 46h,0CAh,0CCh
		db	 90h,0C4h, 56h, 94h,0C4h,0CAh
		db	 4Bh,0C7h, 83h, 82h,0C4h,0C7h
		db	0CAh,0C7h, 85h,0C4h, 4Bh,0C7h
		db	0CBh, 90h,0C4h,0C7h,0C9h, 46h
		db	 93h,0C4h, 66h, 83h, 82h,0C4h
		db	0CCh,0C7h,0C9h, 85h,0C4h,0CAh
		db	0CBh,0C9h, 46h, 84h,0C3h,0C7h
		db	 81h, 46h, 86h,0C4h, 66h, 93h
		db	0C4h, 46h,0CCh,0C7h, 83h, 82h
		db	0C4h, 66h, 84h,0C4h, 66h, 85h
		db	0C4h,0CAh,0CCh,0C9h,0C7h, 86h
		db	0C4h,0CAh,0C7h,0CCh,0C7h, 8Ah
		db	0C3h, 88h,0C5h, 46h,0C9h,0CBh
		db	 83h, 82h,0C4h,0CAh,0CCh, 46h
		db	 84h,0C4h, 76h, 84h,0C4h, 56h
		db	 87h,0C4h, 56h, 8Bh,0C4h,0CAh
		db	0C9h, 86h,0C4h, 66h, 83h, 82h
		db	0C4h, 46h,0CBh, 85h,0C6h,0C7h
		db	 81h,0C7h, 86h,0C4h, 81h, 56h
		db	 86h,0C4h, 56h,0CBh, 8Ah,0C4h
		db	 46h,0C8h, 85h,0C4h, 56h, 84h
		db	 82h,0C5h, 56h, 85h, 05h, 13h
		db	 84h,0C4h, 66h, 86h,0C5h, 66h
		db	 8Ah,0C4h,0CAh,0C7h,0CCh, 85h
		db	0C4h,0C7h,0CCh, 46h, 83h, 82h
		db	0C4h, 56h, 84h, 06h, 13h, 84h
		db	0C4h,0C7h,0CAh,0CCh,0C8h, 86h
		db	0C4h, 66h, 8Ah,0C4h,0CCh,0C7h
		db	0CBh, 85h,0C4h,0C7h,0C9h,0CCh
		db	0C7h, 83h, 82h,0C5h,0C7h,0C9h
		db	0C7h, 85h, 05h, 13h, 84h,0C5h
		db	 46h,0CAh,0C7h, 86h,0C4h,0CAh
		db	 4Bh, 8Bh,0C5h, 56h, 85h,0C4h
		db	0C9h, 46h,0CBh, 83h, 82h,0C4h
		db	 05h, 07h, 82h, 46h, 81h, 46h
		db	 85h,0C4h,0C7h,0C9h,0C7h, 87h
		db	0C4h, 66h, 8Ah,0C4h,0C7h,0C9h
		db	0C7h, 85h,0C5h, 66h, 83h, 82h
		db	0C4h,0CAh,0CCh,0CBh, 05h, 07h
		db	0CAh,0C7h,0CCh,0C7h, 85h,0C4h
		db	 66h, 86h,0C4h, 46h,0CBh,0C7h
		db	 8Ah,0C4h, 56h, 85h,0C5h, 66h
		db	 83h, 82h,0C4h,0C9h, 66h,0C9h
		db	0CCh, 06h, 07h, 84h,0C4h,0C7h
		db	0CCh, 46h, 86h,0C4h,0C9h, 46h
		db	 8Bh,0C4h, 4Bh,0C7h, 85h,0C4h
		db	 66h, 83h, 82h,0C4h, 56h,0CCh
		db	0C7h,0CBh, 05h, 07h, 86h,0C6h
		db	 46h,0CBh, 87h,0C5h, 66h, 8Ah
		db	0C4h, 56h, 85h,0C4h, 4Bh, 81h
		db	0C7h, 83h, 82h,0C6h, 76h, 81h
		db	 56h,0CCh,0CBh,0C7h, 91h,0C4h
		db	 66h, 8Ah,0C5h,0C9h,0CBh,0CCh
		db	 85h,0C4h,0CAh, 48h,0C7h, 83h
		db	 8Bh,0C4h, 46h,0CCh,0C7h, 50h
		db	 41h, 40h, 51h, 40h, 41h,0C1h
		db	 81h,0C5h, 46h,0C9h,0C7h, 85h
		db	0C3h, 84h,0C4h,0CAh, 46h, 85h
		db	0C4h, 46h,0CCh, 46h, 82h, 8Bh
		db	0C4h, 56h, 91h,0C4h, 56h, 86h
		db	0C4h,0C7h, 83h,0C5h,0C7h,0C8h
		db	0C7h, 85h,0C4h, 66h,0C9h,0C7h
		db	 81h, 8Bh,0C5h, 66h, 85h,0C3h
		db	0C7h, 89h,0C4h, 66h, 85h,0C5h
		db	 56h, 81h,0C4h, 46h,0C8h, 85h
		db	0C5h, 46h,0CCh, 56h, 81h, 8Bh
		db	0C4h, 66h, 85h,0C5h,0C7h,0CCh
		db	0C7h, 87h,0C4h,0CAh,0CCh, 46h
		db	 85h,0C4h,0C9h,0C7h, 4Bh, 56h
		db	0C8h, 85h,0C4h, 56h,0CCh, 46h
		db	 81h, 8Bh,0C4h,0C9h,0CAh,0CCh
		db	0C7h, 85h,0C4h,0C7h,0CAh,0CCh
		db	0C7h, 86h,0C4h, 46h,0CCh,0C7h
		db	 85h,0C5h, 05h, 07h,0C9h,0C7h
		db	 85h,0C4h,0CAh, 76h, 81h, 8Bh
		db	0C4h, 56h,0CCh,0C7h, 84h,0C4h
		db	 56h,0CBh, 86h,0C4h, 66h, 85h
		db	0C4h, 46h,0C9h,0CBh,0C7h,0CAh
		db	 46h, 85h,0C4h,0C7h,0C9h,0C7h
		db	0CBh,0C7h, 82h, 51h, 60h, 41h
		db	0C1h, 81h,0C4h, 66h, 85h,0C4h
		db	0C7h,0C9h, 46h, 86h,0C5h,0C7h
		db	0CAh,0C7h,0CBh, 85h,0C4h, 07h
		db	 07h, 85h,0C4h, 46h, 41h, 50h
		db	 8Bh,0C4h,0CAh,0CCh, 46h, 85h
		db	0C4h,0CAh,0CCh, 46h, 86h,0C5h
		db	 66h, 85h,0C5h, 05h, 07h,0CCh
		db	 86h,0C6h, 81h,0C7h, 85h,0C3h
		db	0C7h, 81h, 46h, 86h,0C4h,0C7h
		db	0CAh,0CBh,0C9h, 85h,0C4h, 66h
		db	 86h,0C4h, 56h, 86h,0C4h,0CCh
		db	 56h,0C9h,0C7h,0CBh,0C7h, 8Dh
		db	0C4h, 46h,0C9h,0C7h,0C8h, 85h
		db	0C4h, 76h, 84h,0C4h,0C7h,0C9h
		db	 46h, 86h,0C4h,0C7h, 4Bh,0C7h
		db	 85h,0C4h, 06h, 07h, 8Eh,0C4h
		db	 46h,0CCh,0CAh,0C8h, 85h,0C5h
		db	 66h, 85h,0C4h, 66h, 86h,0C4h
		db	 66h, 85h,0C4h, 48h,0CCh,0CBh
		db	 91h,0C5h, 66h,0C8h, 85h,0C4h
		db	 46h,0CCh,0C7h, 85h,0C4h, 56h
		db	 87h,0C4h,0C9h,0C7h,0CCh,0C7h
		db	 85h,0C6h, 76h, 90h,0C4h, 56h
		db	0CBh,0C8h, 85h,0C5h, 76h, 84h
		db	0C4h,0CCh, 46h, 87h,0C4h, 66h
		db	 9Bh,0C4h, 66h,0C8h, 85h,0C4h
		db	 46h,0CBh, 46h, 84h,0C5h, 66h
		db	 86h,0C4h,0CAh,0CBh, 46h, 41h
		db	0C1h, 51h, 50h, 51h, 50h, 8Ch
		db	0C4h,0C7h,0CAh,0CCh,0C7h,0C8h
		db	 85h,0C4h,0C7h,0CAh,0C9h,0C7h
		db	 85h,0C4h,0C7h,0C9h,0C7h,0CCh
		db	 86h,0C4h,0C7h,0CCh, 46h, 9Bh
		db	0C4h,0C9h, 56h, 86h,0C4h,0C7h
		db	0CCh, 46h, 85h,0C4h,0CAh,0CCh
		db	 46h, 86h,0C4h, 56h, 86h,0C3h
		db	 76h, 90h,0C5h, 66h, 86h,0C4h
		db	 56h, 86h,0C4h, 56h,0CBh, 86h
		db	0C6h, 56h, 86h,0C4h, 66h,0CBh
		db	 46h, 8Eh,0C5h,0C7h,0CAh, 46h
		db	0C8h, 85h,0C4h, 46h,0CCh,0C7h
		db	 85h,0C4h, 56h,0C8h, 90h,0C5h
		db	 07h, 07h, 8Dh,0C4h,0C7h, 4Bh
		db	0C7h,0C8h, 85h,0C4h,0C9h,0CCh
		db	0C7h,0CBh, 85h,0C4h, 56h,0C8h
		db	 90h,0C4h,0CAh, 66h,0CCh, 46h
		db	 8Dh,0C4h, 46h,0C9h,0CCh, 86h
		db	0C4h
		db	66h
data_1		dw	0C485h			; Data table (indexed access)
data_3		db	46h			; Data table (indexed access)
		db	0C9h,0C7h, 90h,0C4h, 76h,0CCh
		db	0C7h, 8Eh,0C4h, 66h,0C8h, 85h
		db	0C4h, 76h, 84h,0C4h, 46h,0CCh
		db	0C7h, 86h,0C3h, 46h, 87h,0C4h
		db	 46h,0CCh,0CBh, 66h, 8Dh,0C4h
		db	0C7h,0CAh,0CCh,0C7h, 86h,0C5h
		db	 66h, 85h,0C5h, 66h, 86h,0C4h
		db	 66h, 85h,0C4h,0C9h, 66h,0CCh
		db	0CBh, 8Eh,0C4h, 66h, 86h,0C5h
		db	 56h, 86h,0C4h, 46h,0CCh, 87h
		db	0C4h,0CCh,0CAh,0CCh,0C8h, 85h
		db	0C4h, 66h,0CAh,0C7h,0C8h, 8Eh
		db	0C4h,0C9h, 46h,0C9h, 86h,0C4h
		db	0C7h,0C9h, 46h, 85h,0C4h,0C7h
		db	0CAh,0C7h,0CBh, 86h,0C4h, 66h
		db	 85h,0C4h, 07h, 07h, 8Dh,0C4h
		db	 66h, 86h,0C4h, 66h, 85h,0C5h
		db	0C7h,0C9h, 46h, 86h,0C5h,0C7h
		db	0C9h,0CBh,0CCh, 85h,0C4h, 66h
		db	0C9h,0C7h,0C8h, 86h,0C3h, 81h
		db	0C7h, 85h,0C4h,0C7h,0CCh, 46h
		db	 86h,0C4h, 56h, 86h,0C4h, 56h
		db	0C8h, 86h,0C5h, 56h,0CBh, 85h
		db	0C5h, 06h, 07h, 86h,0C5h,0CCh
		db	0C7h, 85h,0C5h, 66h, 86h,0C4h
		db	0CCh, 56h, 85h,0C4h, 46h,0CAh
		db	0C7h, 86h,0C4h, 66h, 85h,0C5h
		db	 76h,0C8h,0C7h, 86h,0C4h,0CAh
		db	0CCh,0C7h, 84h,0C4h,0CAh, 5Bh
		db	0C8h, 85h,0C4h, 66h, 85h,0C4h
		db	 66h, 86h,0C4h,0CAh, 46h,0C8h
		db	 85h,0C4h, 56h,0CAh,0CCh,0C7h
		db	 87h,0C4h,0C7h,0C9h,0C7h, 84h
		db	0C4h, 56h,0CBh, 86h,0C4h,0C7h
		db	0CAh,0CCh,0C7h, 85h,0C4h,0C7h
		db	0C9h,0CCh,0CBh, 86h,0C4h,0C9h
		db	 4Bh, 86h,0C4h,0CAh,0CCh, 76h
		db	 86h,0C4h, 56h, 84h,0C4h,0C9h
		db	0CCh, 46h, 86h,0C4h, 56h,0CBh
		db	 85h,0C4h,0C7h,0C8h,0CCh,0C7h
		db	 86h,0C4h, 56h,0CBh, 85h,0C4h
		db	 76h,0CCh, 56h, 84h,0C5h, 4Bh
		db	0C7h, 84h,0C4h, 46h,0C9h,0C7h
		db	 86h,0C4h, 46h, 81h,0C7h, 85h
		db	0C6h, 46h, 81h,0C7h, 86h,0C4h
		db	 66h, 85h,0C4h, 46h,0CCh,0C9h
		db	0CAh,0CCh,0C7h, 86h,0C4h,0CAh
		db	0CBh, 85h,0C4h, 66h, 86h,0C5h
		db	 56h, 91h,0C5h, 56h,0CCh, 85h
		db	0C4h,0C7h,0C9h,0C7h,0CBh, 46h
		db	0CBh,0C7h, 85h,0C4h, 46h, 85h
		db	0C4h,0CAh,0CCh,0C7h,0CBh, 86h
		db	0C4h,0C7h,0CCh,0C7h,0C1h, 51h
		db	 50h, 41h,0C1h, 51h, 40h,0C2h
		db	 81h,0C4h,0C7h,0C9h,0C7h,0CBh
		db	 85h,0C4h, 07h, 07h, 85h,0C6h
		db	0C7h, 86h,0C4h, 66h, 86h,0C4h
		db	0CAh,0C7h,0CCh, 91h,0C4h, 56h
		db	0C8h, 85h,0C5h, 07h, 07h, 8Dh
		db	0C5h, 66h, 86h,0C4h,0C7h,0CCh
		db	0C7h, 86h,0C3h, 81h,0C7h,0CAh
		db	 87h,0C4h, 66h, 85h,0C4h, 07h
		db	 07h,0C1h,0C2h, 40h, 51h,0C1h
		db	0C2h, 50h, 81h,0C4h,0C7h,0CAh
		db	0CCh,0C7h, 86h,0C4h, 56h,0CCh
		db	 85h,0C4h, 56h,0C8h, 86h,0C5h
		db	 56h,0C8h, 85h,0C4h,0CAh,0CCh
		db	0C7h,0C9h, 66h, 8Dh,0C5h,0C7h
		db	0C9h,0C7h,0CBh,0C8h, 85h,0C4h
		db	 46h,0C9h,0CBh, 85h,0C4h, 66h
		db	 86h,0C5h, 56h,0C8h, 85h,0C4h
		db	 05h, 07h, 8Fh,0C4h, 66h,0C8h
		db	 85h,0C5h, 66h, 85h,0C5h,0CAh
		db	0CCh, 46h, 86h,0C4h, 46h,0CCh
		db	0C7h, 85h,0C4h, 56h,0CCh, 46h
		db	 8Fh,0C4h, 66h, 86h,0C4h, 66h
		db	 85h,0C4h, 46h,0CCh,0C7h, 86h
		db	0C4h, 66h, 85h,0C4h, 66h,0CCh
		db	0CBh, 8Fh,0C4h,0CAh,0CCh,0C9h
		db	0C7h, 86h,0C4h, 66h, 85h,0C4h
		db	 46h,0C9h,0CBh, 86h,0C4h,0C7h
		db	0C9h,0C7h,0CCh, 85h,0C4h, 56h
		db	0CAh,0CCh, 85h,0C3h, 83h,0C7h
		db	 86h,0C4h, 66h, 86h,0C5h, 46h
		db	0C9h,0C7h, 85h,0C4h, 66h, 86h
		db	0C4h,0CAh, 4Bh,0C7h, 85h,0C4h
		db	 76h, 85h,0C3h, 66h, 86h,0C4h
		db	0C7h,0CCh,0CBh,0CCh, 86h,0C4h
		db	 66h, 85h,0C4h,0CAh,0C7h,0CBh
		db	0C8h, 86h,0C4h, 46h,0CBh,0C7h
		db	 85h,0C4h, 76h, 85h,0C4h,0CAh
		db	0CCh,0C9h,0C7h, 86h,0C4h, 66h
		db	 86h,0C4h,0CAh,0CCh,0C7h, 86h
		db	0C4h, 66h, 86h,0C6h,0C7h,0C8h
		db	0C7h, 86h,0C5h,0C7h,0C9h,0C7h
		db	0CBh,0C7h, 85h,0C4h, 76h, 85h
		db	0C5h,0C7h,0CAh, 46h,0C8h, 85h
		db	0C4h, 46h,0CCh,0C7h, 85h,0C4h
		db	0C7h,0C9h, 46h, 90h,0C4h,0CAh
		db	 46h,0C9h,0C7h, 85h,0C4h,0C7h
		db	0CAh,0C7h,0CBh,0C7h, 85h,0C4h
		db	 66h, 86h,0C4h, 56h,0CBh, 85h
		db	0C5h, 56h, 91h,0C4h,0C7h, 4Bh
		db	 46h, 85h,0C4h,0C7h,0C9h, 46h
		db	0CBh, 85h,0C4h, 46h,0CCh,0C7h
		db	 86h,0C4h,0C7h,0CCh, 46h, 85h
		db	0C5h, 66h, 89h,0C3h, 46h, 82h
		db	 06h, 07h,0C8h, 85h,0C5h, 66h
		db	0C8h, 85h,0C4h, 66h, 86h,0C4h
		db	0C7h,0C9h, 46h, 85h,0C4h,0CAh
		db	0CCh,0C7h,0CCh, 89h,0C5h, 46h
		db	0CCh, 05h, 07h,0CAh,0CCh,0C8h
		db	 85h,0C5h, 66h, 86h,0C6h, 81h
		db	0C7h, 88h,0C4h, 66h, 85h,0C4h
		db	 56h,0CBh, 89h,0C4h,0C7h, 5Bh
		db	0C7h,0C9h, 66h,0CBh, 86h,0C4h
		db	 46h,0CCh,0C8h,0C7h, 85h, 8Bh
		db	0C4h, 46h,0CCh,0C7h, 85h,0C4h
		db	 56h,0C8h, 89h,0C4h, 0Bh, 07h
		db	 85h,0C4h, 46h,0CAh,0CCh, 86h
		db	0C2h, 40h, 51h, 40h,0C2h,0C1h
		db	 81h,0C5h, 56h, 86h,0C4h, 46h
		db	0CCh,0C8h, 89h,0C4h, 66h, 4Bh
		db	 56h,0CAh,0CCh,0C7h, 85h,0C4h
		db	 56h,0CBh,0C7h, 51h, 40h, 8Bh
		db	0C4h, 46h,0C9h,0C7h, 85h,0C4h
		db	0C7h,0C9h,0CAh,0CBh, 89h,0C4h
		db	 0Bh, 07h, 85h,0C5h, 05h, 07h
		db	 84h,0C7h, 81h, 46h, 87h,0C4h
		db	0C7h,0CAh, 46h, 85h,0C4h, 56h
		db	 8Ah,0C4h, 66h,0CAh,0CCh, 46h
		db	0CCh,0C7h, 87h,0C4h,0CAh,0CCh
		db	0C9h, 76h,0CCh,0C7h,0C7h,0C9h
		db	0C7h,0C8h,0C7h, 86h,0C4h, 66h
		db	 85h,0C4h, 66h, 89h,0C5h, 09h
		db	 07h, 87h,0C4h, 08h, 07h,0CCh
		db	0CBh, 56h, 81h,0C8h, 85h,0C4h
		db	0C7h,0CCh,0C9h,0CBh, 85h,0C4h
		db	 46h,0C9h,0C7h, 89h,0C4h, 06h
		db	 07h,0CBh,0CCh, 56h, 85h,0C5h
		db	 66h,0CBh,0C7h,0CAh,0CCh, 46h
		db	 76h, 86h,0C4h, 66h, 85h,0C4h
		db	0C7h,0C9h, 46h, 89h,0C4h,0C9h
		db	0C7h,0CCh,0C7h,0C9h, 56h,0C8h
		db	 46h, 86h,0C4h,0C7h,0C9h, 07h
		db	 07h, 46h,0CBh,0CCh,0C7h, 86h
		db	0C4h, 56h, 86h,0C4h,0C7h,0CCh
		db	 46h, 89h,0C4h,0C7h,0CAh,0C7h
		db	0CCh, 56h, 81h,0C7h,0C8h,0C7h
		db	 86h,0C4h, 66h, 4Bh, 66h, 4Bh
		db	 46h,0C8h, 86h,0C5h, 66h, 85h
		db	0C4h, 56h,0C8h, 89h,0C4h, 56h
		db	0CBh, 46h, 82h,0C7h, 88h,0C4h
		db	0CCh, 66h,0CBh, 46h,0C9h,0CAh
		db	0C7h,0CBh,0C7h, 88h,0C4h, 66h
		db	 85h,0C4h,0CAh, 4Bh,0C8h, 89h
		db	0C6h, 46h, 8Fh,0C4h, 05h, 07h
		db	0CCh, 46h, 81h, 8Bh,0C5h, 46h
		db	0CCh,0C7h, 85h,0C4h, 46h,0CBh
		db	 9Ch,0C4h, 46h,0CBh, 46h, 85h
		db	0C2h, 40h,0C2h, 40h, 41h, 40h
		db	 81h,0C4h,0C7h,0C9h, 46h, 85h
		db	0C5h, 66h,0C1h, 41h, 50h, 51h
		db	 40h, 51h, 8Dh,0C4h,0C9h,0CAh
		db	0CCh,0C7h, 60h, 41h, 8Bh,0C4h
		db	 46h,0CCh,0CBh, 85h,0C5h, 56h
		db	 9Ch,0C5h, 66h, 86h, 81h,0C7h
		db	 89h,0C4h, 66h, 85h,0C4h,0C7h
		db	0C9h, 46h, 9Bh,0C5h,0C7h,0CCh
		db	 46h, 85h,0C3h, 56h, 88h,0C4h
		db	 66h, 85h,0C4h, 66h, 9Bh,0C4h
		db	 66h, 85h,0C4h,0C7h,0C9h,0C7h
		db	 88h,0C4h,0C9h,0CCh, 46h, 85h
		db	0C4h,0CAh, 4Bh,0C7h, 9Bh,0C4h
		db	0C7h,0C9h,0CCh,0C8h, 85h,0C5h
		db	 56h, 88h,0C4h,0C7h,0CAh, 46h
		db	 85h,0C4h, 66h, 9Bh,0C4h, 46h
		db	0CBh,0C7h, 85h,0C4h,0CAh,0CCh
		db	0C7h, 88h,0C5h,0C7h, 4Bh,0C7h
		db	 85h,0C4h, 46h,0CBh,0C7h, 9Bh
		db	0C4h, 66h, 85h,0C4h, 46h,0CCh
		db	 88h,0C4h, 56h,0CBh, 85h,0C5h
		db	0C7h,0CCh, 0Ch, 11h, 90h,0C4h
		db	0C9h, 56h, 85h,0C4h, 46h, 89h
		db	0C4h, 56h, 86h,0C4h,0C7h, 04h
		db	 11h, 08h, 13h, 90h,0C6h,0C7h
		db	 81h,0C7h, 86h,0C4h, 46h, 89h
		db	0C4h, 66h, 85h,0C4h,0C7h, 04h
		db	 11h, 08h, 13h, 9Ah,0C4h,0C7h
		db	0C8h,0CAh,0CCh, 46h, 81h,0C7h
		db	 81h, 56h,0C9h,0CCh, 46h, 85h
		db	0C6h, 81h, 04h, 11h,0D3h, 07h
		db	 12h, 9Ah,0C4h, 06h, 07h,0C9h
		db	 07h, 07h, 8Ch,0C3h, 81h,0C7h
		db	0A0h,0C4h, 66h,0C9h,0CBh, 06h
		db	 07h,0CAh,0CCh,0C7h, 8Ch,0C4h
		db	 81h,0C7h, 81h,0C7h, 94h,0C3h
		db	 46h, 87h,0C5h, 46h,0CCh, 06h
		db	 07h,0CAh, 66h,0CCh,0C7h, 8Bh
		db	0C4h, 66h,0C8h, 93h,0C4h,0CCh
		db	 46h, 86h,0C4h, 46h,0CAh, 56h
		db	 4Bh, 56h,0CCh, 06h, 07h, 89h
		db	0C4h, 46h,0C9h, 46h, 93h,0C4h
		db	 56h,0C8h, 85h,0C4h, 76h,0CAh
		db	 46h,0CBh, 46h,0C9h,0CBh, 76h
		db	 8Ah,0C4h, 56h,0CBh,0C7h, 93h
		db	0C5h,0C7h,0CAh,0CCh,0C7h, 85h
		db	0C4h, 56h,0CCh,0C7h, 84h,0C4h
		db	 07h, 07h, 8Ah,0C4h,0CAh,0CCh
		db	 46h, 94h,0C5h,0C7h,0C9h, 46h
		db	 85h,0C4h, 76h, 84h,0C5h, 56h
		db	0CCh, 46h, 8Ch,0C4h, 76h, 93h
		db	0C4h, 66h, 85h,0C4h,0C7h,0C9h
		db	0C7h, 86h,0C4h, 66h, 8Eh,0C4h
		db	 56h,0CBh,0C7h, 85h,0C3h,0C7h
		db	 81h,0C7h, 8Ah,0C4h,0CCh, 46h
		db	0CCh, 85h,0C4h, 56h, 86h,0C4h
		db	 66h,0C2h, 50h, 41h, 40h,0C2h
		db	 40h, 41h, 81h,0C5h,0C7h,0CAh
		db	0CCh,0C7h,0C8h, 85h,0C4h, 56h
		db	 8Ah,0C4h, 56h,0CBh, 85h,0C4h
		db	 4Bh,0C7h, 86h,0C4h,0C7h,0C9h
		db	0C7h, 8Fh,0C4h, 56h,0CBh,0C8h
		db	 85h,0C4h,0CAh, 4Bh,0C7h,0C8h
		db	 88h,0C4h,0C9h,0CCh, 46h, 85h
		db	0C4h, 56h, 81h,0E2h, 84h,0C4h
		db	 66h, 85h,0C3h,0C7h,0CCh, 86h
		db	0C4h,0C9h,0CAh,0C7h,0CCh,0C7h
		db	 85h,0C4h, 66h,0C8h, 88h,0C4h
		db	0C7h,0CBh,0C7h,0C8h, 85h,0C5h
		db	 46h,0CBh, 81h,0E3h, 84h,0C4h
		db	 66h, 85h,0C4h,0C7h,0CAh,0C7h
		db	 85h,0C4h, 76h, 85h,0C5h, 46h
		db	0CAh,0CCh,0C7h, 88h,0C6h, 56h
		db	 86h,0C5h, 56h, 81h,0E4h, 84h
		db	0C5h,0C7h,0C9h,0CBh,0C7h, 85h
		db	0C5h,0C7h,0C9h,0C7h, 85h,0C5h
		db	0C7h,0C9h, 46h, 86h,0C4h, 66h
		db	0CBh, 92h,0C4h,0C9h,0C7h, 82h
		db	0CDh, 84h,0C5h, 46h,0CAh,0CCh
		db	 85h,0C4h, 46h, 86h,0C5h, 76h
		db	 85h,0C4h,0C9h,0CAh,0CCh, 46h
		db	 92h,0C4h,0C7h,0C8h, 82h,0CEh
		db	 84h,0C4h, 66h, 85h,0C4h, 56h
		db	 85h,0C4h,0CAh,0CCh, 56h, 85h
		db	0C4h,0C7h,0CBh,0C7h,0CBh,0C8h
		db	 92h,0C4h, 56h, 86h,0C4h, 66h
		db	 85h,0C5h,0CCh,0C7h, 86h,0C4h
		db	 56h,0CCh, 0Dh, 07h, 86h,0C3h
		db	 81h, 46h, 86h,0C4h,0C7h,0C9h
		db	0C7h, 86h,0C4h,0C9h, 56h, 85h
		db	0C5h,0C7h,0CCh,0C7h, 85h,0C4h
		db	 56h,0C9h,0CCh, 76h, 4Bh,0C9h
		db	 76h, 86h,0C4h, 66h, 85h,0C4h
		db	0CAh,0CCh,0C7h, 86h,0C5h, 56h
		db	 86h,0C4h, 56h, 85h,0C4h, 07h
		db	 07h,0C9h, 46h,0CBh, 06h, 07h
		db	0C8h, 84h,0C4h, 56h,0C8h, 85h
		db	0C4h, 56h, 86h,0C4h, 66h, 85h
		db	0C4h,0CAh,0CBh,0C7h, 85h,0C4h
		db	 46h,0CAh,0CCh, 06h, 07h,0CAh
		db	0CCh, 46h,0CAh,0CCh, 56h, 84h
		db	0C4h,0CAh,0CCh,0C7h,0C8h, 85h
		db	0C4h, 46h,0CBh, 86h,0C4h,0C7h
		db	0CCh,0C7h, 86h,0C4h, 46h, 86h
		db	0C4h,0C9h, 56h,0CBh,0C7h,0CCh
		db	 46h, 81h, 56h,0CCh,0C9h, 0Bh
		db	 07h,0CCh, 86h,0C4h, 56h, 86h
		db	0C4h,0CAh,0C7h,0CCh,0C7h, 85h
		db	0C4h,0CCh,0C7h, 86h,0C4h, 05h
		db	 07h, 84h,0C4h, 05h, 07h, 4Bh
		db	0C7h,0C9h,0C7h,0CCh, 05h, 07h
		db	 85h,0C4h,0C7h,0CAh,0C7h, 86h
		db	0C4h, 46h,0C9h,0C7h, 85h,0C4h
		db	 56h, 85h,0C4h,0C7h,0CAh, 4Bh
		db	0C7h, 85h,0C4h,0CAh,0CCh, 56h
		db	 83h,0C4h, 46h,0C9h, 46h,0C9h
		db	0CAh, 4Bh, 85h,0C4h,0C7h,0CCh
		db	0C7h, 86h,0C4h, 03h, 17h, 85h
		db	0C4h,0C7h,0CCh,0C7h, 85h,0C4h
		db	 66h,0CBh, 85h,0C4h, 46h,0CCh
		db	0C7h, 84h,0C5h, 46h,0CAh,0CCh
		db	 66h,0CBh, 85h,0C4h,0C9h, 46h
		db	 86h,0D4h, 02h, 15h, 01h, 13h
		db	 84h,0C4h,0C9h, 46h, 85h,0C5h
		db	 66h,0C8h, 85h,0C5h, 46h,0CCh
		db	 85h,0C4h, 08h, 07h, 85h,0C4h
		db	 56h, 86h,0D4h,0D6h, 02h, 15h
		db	0D3h, 84h,0C4h, 46h, 86h,0C4h
		db	 66h, 86h,0C4h,0C9h,0C7h,0CBh
		db	 85h,0C4h,0CAh,0CCh, 46h,0CCh
		db	 66h, 85h,0C5h,0CAh, 46h, 86h
		db	0D4h, 01h, 15h,0D6h, 01h, 13h
		db	 84h,0C5h, 46h, 86h,0C4h, 66h
		db	 86h,0C4h,0C7h,0C8h,0C7h, 85h
		db	0C6h, 56h, 83h, 46h, 86h,0C4h
		db	 56h, 86h,0D4h, 03h, 15h,0D3h
		db	 84h,0C4h, 56h, 85h,0C4h,0C7h
		db	0C9h,0C7h, 87h,0C4h,0CCh,0C7h
		db	0C8h, 94h,0C4h, 46h,0CCh,0C7h
		db	 85h,0C5h,0DBh,0DCh, 01h, 1Ah
		db	 85h,0C4h, 46h, 86h,0C6h, 56h
		db	 87h,0C4h,0C9h, 96h,0C4h,0C7h
		db	0CCh,0C7h,0CBh, 85h,0C4h, 66h
		db	 85h,0C4h,0C9h,0CCh,0C7h, 90h
		db	0C5h,0C7h, 96h,0C6h, 81h,0C4h
		db	 46h, 85h,0C4h,0C7h,0CAh,0CCh
		db	0C7h, 85h,0C4h,0CAh, 46h, 51h
		db	0C1h,0C2h, 50h, 41h, 50h, 41h
		db	 81h,0C4h, 46h, 86h,0C3h, 82h
		db	0C7h, 85h,0C3h,0C7h,0C8h, 84h
		db	 81h,0C4h, 56h, 84h,0C5h, 66h
		db	 85h, 56h, 91h,0C6h, 46h, 86h
		db	0C4h, 56h, 85h,0C4h, 46h, 84h
		db	 81h,0C5h, 56h, 84h,0C4h, 46h
		db	0C9h, 81h,0C7h,0CAh,0C7h,0C9h
		db	 56h,0CCh,0C7h, 88h,0C3h, 81h
		db	 46h, 8Dh,0C4h, 4Bh, 46h, 84h
		db	0C4h, 4Bh,0C7h, 83h, 81h,0C4h
		db	 4Bh,0CBh, 84h,0C4h,0CAh,0CCh
		db	 06h, 07h,0CAh,0CCh,0CBh,0C7h
		db	 88h,0C4h,0C7h,0C9h,0C7h, 8Dh
		db	0C4h,0C7h,0CCh,0CAh,0C7h, 84h
		db	0C4h, 56h, 83h, 81h,0C4h, 46h
		db	 85h,0C4h, 06h, 07h,0CCh, 46h
		db	0CCh,0C7h, 89h,0C4h, 46h,0CAh
		db	0C7h, 8Ch,0C4h, 56h,0CCh, 84h
		db	0C5h,0C7h,0C9h,0C7h, 83h, 81h
		db	0C4h,0C7h,0CAh,0C7h, 84h,0C4h
		db	0C7h,0CAh,0CBh, 66h, 81h, 76h
		db	 88h,0C5h, 66h, 8Ch,0C4h,0C7h
		db	0CAh, 4Ah, 84h,0C4h, 46h,0C8h
		db	 83h, 81h,0C4h, 56h, 84h,0C4h
		db	 76h, 84h,0C4h,0C7h,0C9h,0C7h
		db	 88h,0C4h, 4Bh,0CBh, 8Dh,0C4h
		db	0C9h, 46h, 85h,0C4h, 56h, 83h
		db	 81h,0C5h, 46h, 85h,0C4h,0C9h
		db	 66h, 84h,0C5h, 56h, 88h,0C4h
		db	 66h, 8Ch,0C4h, 46h,0C9h,0C7h
		db	 84h,0C4h,0C9h,0C7h,0CBh, 83h
		db	 81h,0C5h, 56h, 84h,0C4h,0C7h
		db	0C9h, 87h,0C4h,0C9h,0C7h, 89h
		db	0C4h,0C7h,0C9h,0C7h,0CBh, 8Ch
		db	0C4h, 66h, 84h,0C4h, 56h, 83h
		db	 81h,0C4h,0C7h,0C9h,0C7h, 84h
		db	0C6h, 89h,0C4h, 46h, 89h,0C4h
		db	 56h,0C8h, 8Ch,0C4h,0CAh, 56h
		db	 84h,0C4h, 56h, 83h, 81h,0C4h
		db	 46h, 8Fh,0C4h,0CAh,0CCh,0C7h
		db	 88h,0C4h,0C9h, 46h,0C8h, 8Ch
		db	0C4h, 56h, 85h,0C4h,0CAh,0CCh
		db	0C7h, 83h, 81h,0C4h,0C7h,0CCh
		db	0C7h, 8Eh,0C5h, 66h, 87h,0C4h
		db	 56h, 8Dh,0C4h, 66h, 84h,0C4h
		db	 46h,0C8h, 83h, 81h,0C4h,0C7h
		db	0C9h, 46h, 8Dh,0C5h, 66h, 87h
		db	0C4h,0CCh, 46h,0CBh, 8Ch,0C4h
		db	 56h, 85h,0C5h,0C7h,0CAh,0CCh
		db	 83h, 81h,0C6h, 81h,0C7h,0CCh
		db	0CBh,0C7h, 8Ch,0C4h, 66h, 87h
		db	0C4h,0CAh, 46h,0C8h, 8Ch,0C4h
		db	0C9h,0C7h,0CCh,0C7h, 84h,0C4h
		db	 46h,0CBh, 83h, 83h,0C4h, 56h
		db	 8Ch,0C4h,0CCh, 46h, 88h,0C5h
		db	0C7h, 4Bh,0C8h, 8Ch,0C4h, 46h
		db	0CBh,0C7h, 84h,0C4h,0C7h,0C9h
		db	 46h, 82h, 83h,0C4h, 56h, 8Ch
		db	0C4h,0C9h,0CAh,0CCh,0C7h, 87h
		db	0C5h, 56h, 8Dh,0C4h,0C7h,0CAh
		db	 46h, 84h,0C4h, 56h,0C8h, 82h
		db	 83h,0C4h, 46h,0C9h,0C7h, 8Bh
		db	0C4h, 66h, 87h,0C4h, 56h, 8Dh
		db	0C4h, 46h,0C9h,0C7h, 84h,0C4h
		db	 46h, 84h, 81h,0C3h,0C8h, 76h
		db	 84h,0C3h, 46h, 84h,0C6h, 8Bh
		db	0C4h,0CCh,0C7h,0C8h, 8Dh,0C4h
		db	 56h, 85h,0C4h,0CCh,0C7h,0C8h
		db	 83h, 81h,0C5h, 56h,0CBh,0C7h
		db	 85h,0C4h,0C9h,0C7h, 90h,0C4h
		db	 56h, 8Dh,0C4h, 66h, 84h,0C4h
		db	0C7h,0CBh,0C8h, 83h, 81h,0C4h
		db	0C9h, 56h,0CCh, 85h,0C4h, 56h
		db	 8Fh,0C5h,0C7h,0CCh, 8Eh,0C4h
		db	 66h, 84h,0C4h, 56h, 83h, 81h
		db	0C6h, 66h,0CBh,0C7h, 84h,0C5h
		db	0C7h,0CCh,0C9h, 46h, 8Dh,0C4h
		db	0C7h,0C9h,0C2h, 70h,0C2h,0C1h
		db	 41h, 50h, 81h,0C4h,0CAh, 4Bh
		db	 85h,0C5h, 56h, 83h, 83h,0C4h
		db	 56h, 85h,0C4h,0C7h,0CCh,0CAh
		db	0CBh, 46h, 8Ch,0C4h, 46h, 8Eh
		db	0C4h, 46h,0CCh,0CBh, 84h,0C4h
		db	0C9h,0CAh,0CCh, 83h, 83h,0C4h
		db	 56h, 85h,0C4h,0CCh, 66h, 8Dh
		db	0C4h,0C7h,0CBh, 85h,0C3h, 88h
		db	0C4h,0C9h,0C7h, 86h,0C5h, 46h
		db	 84h, 83h,0C5h, 4Bh,0C7h, 85h
		db	0C6h, 56h, 8Fh,0C6h, 46h, 85h
		db	0C4h, 46h, 86h,0C4h, 66h, 84h
		db	0C4h,0C9h,0CCh,0C7h, 83h, 81h
		db	0C3h, 56h,0CBh,0C7h,0A0h,0C5h
		db	 56h, 85h,0C4h, 56h, 85h,0C4h
		db	0CBh,0C7h, 81h,0C8h, 82h, 81h
		db	0C4h,0C7h,0C9h,0CAh,0C7h,0CCh
		db	 8Ch,0C3h,0C7h, 81h, 46h, 8Fh
		db	0C4h, 46h,0C9h, 81h,0C7h, 81h
		db	 56h,0C9h,0CBh,0C7h, 85h,0C4h
		db	 56h,0C8h, 82h, 81h,0C4h, 56h
		db	0CBh,0C7h, 8Ch,0C4h, 46h,0CCh
		db	 56h,0C1h, 61h,0C1h,0C2h, 40h
		db	 51h, 81h,0C4h,0CAh, 07h, 07h
		db	0CCh,0CBh,0C7h, 85h,0C4h,0C9h
		db	0CBh, 46h, 82h, 81h,0C6h, 05h
		db	 07h, 8Bh,0C4h, 56h,0CCh,0C7h
		db	 8Eh,0C4h,0C7h,0CCh,0C7h,0CAh
		db	0C7h,0CAh,0CBh,0CCh, 56h, 86h
		db	0C4h, 66h, 82h, 83h,0C4h, 46h
		db	0C9h,0C7h, 8Bh,0C4h,0CAh,0CCh
		db	 76h, 86h,0C7h, 85h,0C4h, 76h
		db	0C9h, 66h, 87h,0C4h,0C7h,0CCh
		db	 46h, 82h, 83h,0C5h, 66h, 8Bh
		db	0C4h, 46h,0CBh, 05h, 07h,0CBh
		db	 05h, 07h,0CAh, 56h,0CAh,0C7h
		db	0CCh, 56h, 8Bh,0C4h, 66h, 82h
		db	 83h,0C4h, 49h,0C7h, 8Ch,0C4h
		db	0C7h,0CAh, 06h, 07h,0CAh, 66h
		db	0CAh,0CCh, 07h, 07h,0C1h,0C2h
		db	 05h, 01h, 41h, 40h, 81h,0C4h
		db	 46h,0CBh,0C8h, 82h, 83h,0C4h
		db	 66h, 8Bh,0C5h, 46h,0C9h,0C7h
		db	0C9h,0CBh, 08h, 07h,0CBh,0CCh
		db	0C7h,0CBh, 66h, 8Eh,0C4h,0C9h
		db	0CCh, 81h,0C8h, 82h, 83h,0C4h
		db	0C7h,0C9h,0CCh, 8Ch,0C5h,0C9h
		db	 08h, 07h,0C9h,0CCh, 46h,0C9h
		db	 46h, 81h, 05h, 07h, 85h,0C3h
		db	 46h, 85h,0C5h,0C7h,0C9h,0CBh
		db	 83h, 83h,0C4h, 56h,0CBh,0C7h
		db	 8Ah,0C4h,0C7h,0CAh, 4Bh, 05h
		db	 07h,0CCh, 66h, 84h,0C4h,0CAh
		db	0C7h,0C9h,0C7h, 85h,0C4h, 56h
		db	 84h,0C4h, 66h, 82h, 83h,0C5h
		db	 46h,0CCh, 56h, 89h,0C4h,0C9h
		db	0CAh, 46h,0CCh,0C7h,0C9h, 66h
		db	0CCh, 46h, 85h,0C4h,0C7h,0CCh
		db	 46h, 85h,0C4h, 4Bh,0C8h, 84h
		db	0C4h, 66h, 82h, 83h,0C5h, 56h
		db	0CBh, 46h, 89h,0C4h, 0Bh, 07h
		db	 87h,0C5h, 46h,0CCh,0C7h, 85h
		db	0C4h, 46h,0C8h, 84h,0C4h,0CAh
		db	 4Bh, 83h, 83h,0C4h, 05h, 07h
		db	 89h,0C4h, 76h,0CBh, 46h,0CAh
		db	0C9h,0C7h, 88h,0C4h, 46h,0CBh
		db	0C7h, 85h,0C4h,0C7h,0C9h,0CBh
		db	 84h,0C4h, 66h, 82h, 83h,0C4h
		db	0C7h,0CAh, 66h, 89h,0C4h,0CAh
		db	0CCh,0C7h,0C9h, 46h,0CAh, 66h
		db	 88h,0C4h, 66h, 85h,0C5h,0CAh
		db	0CCh,0C7h, 84h,0C4h,0C7h,0CCh
		db	 46h, 82h, 83h,0C4h, 76h, 8Ah
		db	0C4h,0C7h,0CAh, 4Bh, 56h,0CCh
		db	 46h, 89h,0C4h, 66h, 85h,0C5h
		db	 56h, 84h,0C5h,0C7h,0C9h,0CBh
		db	0C7h, 82h, 83h,0C4h, 46h,0C9h
		db	0CCh,0C7h, 8Ah,0C5h, 05h, 07h
		db	0CAh,0CCh, 46h, 89h,0C5h,0C9h
		db	 46h, 86h,0C4h,0C7h,0C9h,0C7h
		db	 84h,0C5h,0C7h,0CCh, 81h,0C7h
		db	 82h, 83h,0C4h,0C7h,0CAh,0CCh
		db	0C7h, 8Bh,0C4h, 56h,0CBh,0CCh
		db	 56h,0CBh,0C7h, 89h,0C5h, 46h
		db	0C9h,0C7h, 85h,0C4h, 46h, 85h
		db	0C4h, 66h, 82h, 83h,0C4h, 46h
		db	0CBh, 8Ch,0C4h, 09h, 07h, 89h
		db	0C4h,0CAh, 56h, 85h,0C4h, 4Bh
		db	0C7h, 84h,0C4h,0CAh, 46h,0C8h
		db	 82h, 83h,0C5h, 56h, 8Ch,0C5h
		db	 09h, 07h, 89h,0C4h,0C7h,0CCh
		db	 46h, 85h,0C4h, 56h, 84h,0C6h
		db	 46h,0C8h, 83h, 83h,0C4h, 46h
		db	0C8h, 83h,0C3h, 56h, 85h,0C4h
		db	 76h,0CBh, 66h, 89h,0C4h,0C7h
		db	0CBh, 46h, 85h,0C5h,0C9h,0C7h
		db	0C8h, 8Bh, 83h,0C4h, 46h,0C8h
		db	 83h,0C4h, 07h, 07h,0C9h,0CCh
		db	0C7h,0C9h, 56h, 4Bh,0CBh, 8Ah
		db	0C4h,0C7h, 4Bh, 86h,0C5h, 56h
		db	 8Bh, 83h,0C4h, 46h,0C8h, 83h
		db	0C5h, 76h, 49h,0CCh,0CAh, 76h
		db	0C9h,0C7h,0CCh,0C7h, 8Ah,0C4h
		db	 46h,0CCh,0C7h, 85h,0C4h,0CAh
		db	0CCh,0C7h, 8Bh, 83h,0C6h,0C7h
		db	0C8h, 84h,0C4h, 66h,0C9h, 46h
		db	0CCh, 76h,0CAh, 66h, 8Ah,0C4h
		db	0C9h, 56h, 85h,0C4h, 56h, 86h
		db	0C3h, 46h, 82h, 8Ah,0C4h, 07h
		db	 07h,0CBh, 46h, 81h,0C7h, 81h
		db	 46h, 8Ch,0C4h, 66h, 85h,0C5h
		db	0C7h,0C9h,0CBh, 86h,0C4h,0C9h
		db	 46h, 81h, 8Ah,0C4h,0C9h, 76h
		db	 81h, 66h, 91h,0C4h,0C7h,0CBh
		db	0C9h,0C7h, 85h,0C4h, 46h, 87h
		db	0C4h,0CAh, 56h,0C7h, 81h,0C7h
		db	 87h,0C4h, 46h,0CAh, 4Bh,0C7h
		db	 96h,0C5h, 66h, 85h,0C4h,0C7h
		db	0CAh,0CCh, 86h,0C4h,0C7h,0CCh
		db	 46h, 46h,0CAh, 56h, 81h, 06h
		db	 07h,0CCh, 46h, 96h,0C4h,0CAh
		db	 56h, 85h,0C6h, 81h, 46h, 86h
		db	0C5h,0C7h,0CAh,0CBh,0CCh, 56h
		db	 4Ah,0CAh,0CCh,0C7h,0CCh, 56h
		db	0CAh,0CCh,0C7h,0CBh,0C7h, 92h
		db	0C3h,0C7h, 81h, 56h,0CCh, 46h
		db	 8Fh,0C5h, 46h,0CBh,0CCh, 76h
		db	0CCh, 0Ah, 07h, 92h,0C4h, 05h
		db	 07h,0CCh,0C7h,0C1h, 41h, 40h
		db	 51h, 40h, 41h, 40h, 81h,0C4h
		db	0C7h,0C9h,0C7h,0CAh,0CCh,0C7h
		db	0C9h, 06h, 07h,0CAh,0CCh,0C7h
		db	0C9h, 46h, 93h,0C4h,0CAh, 56h
		db	0CAh, 56h, 8Fh,0C4h, 46h,0C9h
		db	0C7h,0CAh,0CCh,0CBh,0C7h, 84h
		db	0C4h, 07h, 07h, 92h,0C4h,0C7h
		db	0CCh, 56h,0C9h,0CCh, 66h, 87h
		db	0C3h, 46h, 82h,0C4h, 46h,0CBh
		db	0C7h, 56h, 85h,0C4h, 46h,0CCh
		db	 46h,0CCh, 46h, 92h,0C5h, 46h
		db	0CCh,0C9h, 06h, 07h, 87h,0C4h
		db	 46h,0CAh, 46h,0C9h, 56h, 46h
		db	 86h,0C4h, 06h, 07h, 93h,0C6h
		db	0C7h, 81h,0C7h,0CBh, 66h,0C9h
		db	0C7h, 88h,0C4h, 56h,0CCh,0CAh
		db	 56h,0C9h,0C7h, 87h,0C4h, 66h
		db	0C9h,0CCh, 46h, 98h,0C4h, 56h
		db	 89h,0C4h, 4Bh,0CAh, 46h,0CCh
		db	0C9h, 46h, 46h, 86h,0C4h, 56h
		db	0C9h, 46h,0CCh,0C7h, 98h,0C5h
		db	 46h, 8Ah,0C5h,0C7h,0CCh,0CBh
		db	 56h,0CBh, 46h, 81h,0C7h, 86h
		db	0C5h, 66h,0CBh, 56h, 98h,0C4h
		db	0CAh,0C7h, 8Ah,0C4h,0CAh,0C7h
		db	0C9h, 56h,0CCh, 46h, 88h,0C4h
		db	 07h, 07h, 98h,0C4h,0CCh,0C7h
		db	 84h,0C3h, 46h, 81h,0C7h, 81h
		db	0C4h, 76h,0CAh,0CCh, 46h, 88h
		db	0C4h,0C7h,0CAh, 05h, 07h, 98h
		db	0C4h,0C7h, 85h,0C5h, 05h, 07h
		db	0C9h, 05h, 07h, 82h, 88h,0C4h
		db	 46h,0CCh, 76h, 98h,0C4h,0C7h
		db	 85h,0C4h, 46h,0CCh,0C7h,0CAh
		db	0CCh,0C7h,0CAh,0CBh,0C7h, 85h
		db	 51h, 40h, 41h, 81h,0C5h,0C7h
		db	0CAh,0CCh, 76h, 98h,0C4h, 46h
		db	 84h,0C4h,0C7h,0CAh,0C7h,0CCh
		db	0CBh,0C7h,0CBh, 46h,0C2h, 40h
		db	 51h, 88h,0C4h, 76h,0C9h, 46h
		db	 98h,0C5h, 46h, 84h,0C5h, 46h
		db	0C9h,0CCh, 66h, 87h,0C7h, 87h
		db	0C4h,0C7h,0CAh,0C7h,0CAh,0CCh
		db	 56h, 41h, 40h, 61h,0C1h,0C2h
		db	 40h, 41h,0C1h, 61h, 40h, 41h
		db	 81h,0C4h,0C7h, 85h,0C4h, 05h
		db	 07h, 88h,0C3h, 56h, 85h,0C4h
		db	 46h,0CBh, 76h, 98h,0C4h,0C9h
		db	 85h,0C4h,0C9h, 56h, 8Ah,0C5h
		db	0C7h, 4Bh, 85h,0C4h, 08h, 07h
		db	 85h,0C3h, 91h,0C4h, 46h, 84h
		db	0C6h, 46h, 8Ch,0C4h,0CAh, 46h
		db	 85h,0C5h, 06h, 07h,0C8h,0C7h
		db	 85h,0C4h, 91h,0C4h,0CAh,0C7h
		db	 93h,0C4h, 56h, 85h,0C4h, 46h
		db	0C9h, 46h,0CAh,0CCh, 56h, 84h
		db	0C4h,0C7h, 90h,0C4h, 4Bh, 93h
		db	0C4h,0C9h, 46h, 85h,0C4h, 76h
		db	0CAh, 4Bh, 46h, 84h,0C5h,0C7h
		db	 90h,0C4h,0C7h,0CBh,0C7h, 92h
		db	0C4h, 56h, 85h,0C4h, 76h,0C8h
		db	 46h,0CCh,0C7h, 84h,0C4h, 46h
		db	 8Fh,0C4h,0C7h,0C9h,0C7h, 88h
		db	0C3h, 46h, 87h,0C4h,0CAh,0CCh
		db	0C7h, 85h,0C4h,0CAh, 4Bh, 46h
		db	0C8h,0CBh, 46h, 85h,0C4h,0CAh
		db	0CCh, 8Fh,0C4h, 56h, 88h,0C4h
		db	0C7h, 81h,0C7h, 86h,0C4h,0C7h
		db	0CCh, 86h,0C4h, 66h,0C8h, 66h
		db	 85h,0C4h, 4Bh,0C7h, 8Eh,0C4h
		db	 56h, 88h,0C5h, 56h, 86h,0C4h
		db	0C7h, 81h,0CBh, 85h,0C4h, 56h
		db	0CCh,0C7h,0C9h, 46h, 86h,0C4h
		db	0C7h, 4Ah, 8Eh,0C4h,0CAh, 56h
		db	 87h,0C4h,0C7h,0CAh,0C7h, 86h
		db	0C4h, 56h, 85h,0C4h, 06h, 07h
		db	 47h, 85h,0C4h, 56h, 8Eh,0C4h
		db	0C7h,0CBh,0CCh,0C7h, 87h,0C4h
		db	0CAh, 4Bh,0C7h, 85h,0C4h,0C7h
		db	0C9h,0C7h, 85h,0C4h,0C7h,0C9h
		db	0CAh,0CCh,0CBh,0C7h, 81h,0C8h
		db	 86h,0C5h,0C7h,0C9h, 46h, 8Dh
		db	0C5h, 46h,0CBh,0C7h, 87h,0C4h
		db	 46h,0CCh,0C7h, 85h,0C5h, 56h
		db	 85h,0C4h,0CAh, 05h, 07h, 87h
		db	0C5h,0C7h,0CAh, 46h, 8Dh,0C5h
		db	0C7h,0CAh,0C9h,0C7h, 87h,0C4h
		db	0C9h,0C7h,0C9h,0CCh, 85h,0C5h
		db	 56h, 85h,0C4h,0CCh, 46h,0C8h
		db	 46h, 47h, 86h,0C4h, 66h, 8Dh
		db	0C4h, 66h, 87h,0C4h, 46h,0CBh
		db	0C7h, 85h,0C4h,0CAh, 46h, 85h
		db	0C4h, 46h,0CAh, 56h, 47h, 86h
		db	0C4h, 4Bh,0C9h,0C7h, 8Dh,0C4h
		db	 66h, 87h,0C5h, 66h, 85h,0C4h
		db	 4Bh,0C7h, 85h,0C5h, 56h, 4Bh
		db	 46h, 87h,0C4h, 46h,0CBh,0C7h
		db	 8Dh,0C4h,0C7h,0C9h, 46h, 87h
		db	0C4h, 56h, 86h,0C4h,0C9h,0CCh
		db	0C7h, 85h,0C4h, 66h,0C9h,0C7h
		db	 81h,0C8h, 86h,0C4h,0C7h,0C9h
		db	 46h, 8Dh,0C4h, 4Bh, 46h, 87h
		db	0C5h,0C7h,0C9h, 46h, 85h,0C4h
		db	 46h, 86h,0C4h, 66h,0CBh, 81h
		db	 47h, 86h,0C5h, 66h, 8Dh,0C4h
		db	0CAh,0CCh, 46h, 87h,0C4h,0CCh
		db	 56h, 85h,0C5h,0CAh,0CCh,0C7h
		db	 85h,0C4h, 05h, 07h,0C8h, 87h
		db	0C4h,0C9h,0CAh,0C7h, 8Eh,0C4h
		db	 46h,0CBh, 88h,0C4h,0CAh,0CCh
		db	 46h, 85h,0C4h, 46h, 86h,0C4h
		db	 46h,0CCh,0C7h,0CCh,0C7h, 81h
		db	0C8h, 86h,0C4h,0C7h,0CAh,0CCh
		db	0C7h, 8Dh,0C4h, 46h,0CCh,0C7h
		db	 87h,0C4h, 66h, 85h,0C4h, 56h
		db	 85h,0C4h, 06h, 07h,0C8h, 86h
		db	0C4h, 66h, 8Dh,0C4h,0C9h, 56h
		db	 87h,0C4h,0C7h,0C9h,0CBh,0C7h
		db	 85h,0C4h, 56h, 85h,0C4h, 46h
		db	0C9h,0CBh,0C9h,0C7h, 81h,0C8h
		db	 86h,0C5h,0CCh, 46h,0CBh, 8Dh
		db	0C4h, 66h, 87h,0C4h, 66h, 85h
		db	0C4h,0C7h,0C9h,0C7h, 85h,0C4h
		db	0CAh, 46h, 4Bh, 46h,0C8h, 86h
		db	0C5h,0C7h,0CBh,0C9h,0C7h, 8Dh
		db	0C4h, 66h, 87h,0C4h,0CAh,0CBh
		db	0C7h, 86h,0C5h,0CCh,0CAh,0C7h
		db	 85h,0C4h, 76h,0C9h,0C7h, 81h
		db	0C8h, 85h,0C4h,0C7h,0C9h, 46h
		db	 8Dh,0C5h, 76h, 86h,0C5h,0C7h
		db	0CAh,0CCh,0C7h, 85h,0C4h, 4Bh
		db	0C7h, 85h,0C5h, 56h,0C8h, 66h
		db	 86h,0C4h, 56h, 8Eh,0C4h,0CCh
		db	 66h, 86h,0C4h, 46h,0CCh,0C7h
		db	 85h,0C4h, 46h,0CBh, 85h,0C5h
		db	 07h, 07h,0C8h, 85h,0C4h, 56h
		db	 8Eh,0C4h,0CCh,0CAh,0CCh, 46h
		db	 86h,0C5h, 56h,0CBh, 85h,0C4h
		db	 56h, 85h,0C4h,0CAh,0CCh, 56h
		db	0C9h,0C8h, 46h, 85h,0C4h,0C7h
		db	0C9h, 46h, 8Dh,0C4h,0C7h,0C9h
		db	0C7h,0CBh,0C9h,0C7h, 85h,0C4h
		db	 76h, 84h,0C4h, 56h, 85h,0C4h
		db	 66h,0CAh,0C7h,0CAh,0CCh,0C7h
		db	 85h,0C5h, 46h,0CCh,0C7h, 8Dh
		db	0C4h, 46h,0CAh,0CCh, 46h, 85h
		db	0C4h, 46h,0C9h, 46h, 84h,0C4h
		db	 66h, 84h,0C4h, 05h, 07h, 4Bh
		db	 46h, 84h,0C4h,0CAh, 46h,0CBh
		db	0C7h, 86h, 56h, 81h, 76h,0C9h
		db	 56h, 85h,0C4h,0C7h, 4Bh, 06h
		db	 07h,0C7h,0CAh,0C9h,0C7h, 84h
		db	0C5h,0C7h,0CAh, 5Bh, 06h, 07h
		db	 82h, 46h,0CAh, 4Bh, 66h, 82h
		db	0C7h,0CAh,0C7h, 4Bh, 07h, 07h
		db	0CAh, 0Bh, 07h,0CAh,0CCh, 46h
		db	 56h, 85h,0C4h, 66h,0CBh, 46h
		db	0CCh,0C7h,0C9h,0CAh,0CCh, 82h
		db	 0Fh, 07h,0CAh, 56h,0CBh, 66h
		db	 4Bh,0CBh, 56h,0CAh, 46h,0C9h
		db	0CBh, 46h,0CCh, 46h,0C7h,0CCh
		db	0CBh,0C7h, 84h,0C4h,0C7h,0C9h
		db	 66h,0C9h, 11h, 07h,0CAh, 46h
		db	0CBh, 09h, 07h,0C9h,0C7h,0CCh
		db	 56h,0C9h, 66h,0C9h, 46h,0CBh
		db	0C7h, 46h,0CCh, 85h,0C4h, 09h
		db	 07h,0C9h,0CBh, 49h, 46h,0C9h
		db	 08h, 07h,0CCh, 46h, 82h, 09h
		db	 07h, 81h,0C7h,0CCh, 06h, 07h
		db	 81h, 46h, 81h, 81h,0C4h, 46h
		db	 84h,0C4h,0C7h,0CAh, 66h,0C9h
		db	 05h, 07h, 5Bh, 46h,0CAh, 4Bh
		db	0C7h,0CAh,0CCh, 56h,0CBh, 9Bh
		db	 81h,0C5h, 46h, 84h,0C4h,0C7h
		db	0C9h,0CCh, 0Ah, 07h,0CBh, 08h
		db	 07h, 4Ah, 46h, 61h, 40h, 51h
		db	0C1h,0C2h, 40h, 41h, 40h, 51h
		db	 60h, 41h,0C1h, 81h,0C4h, 46h
		db	 84h,0C4h, 07h, 07h,0C9h, 07h
		db	 07h,0C9h, 46h, 4Bh,0CBh, 76h
		db	 9Bh, 81h,0C5h, 46h, 84h,0C4h
		db	 56h, 5Bh, 0Eh, 07h,0CCh, 05h
		db	 07h, 85h,0C3h, 76h, 88h,0C3h
		db	 81h, 46h, 84h, 81h,0C4h, 56h
		db	 81h, 06h, 07h,0CBh, 08h, 07h
		db	0CAh, 06h, 07h,0CAh,0CCh, 66h
		db	 85h,0C4h, 56h,0C9h, 46h, 87h
		db	0C4h, 56h, 84h, 81h,0C4h,0CAh
		db	0CCh,0C7h,0C9h, 06h, 07h,0CAh
		db	0CCh, 49h,0CBh, 05h, 07h, 4Bh
		db	 07h, 07h, 81h, 46h, 85h,0C5h
		db	0CAh, 4Bh, 66h, 86h,0C5h, 66h
		db	 83h, 81h,0C4h, 46h,0CCh,0CBh
		db	0CCh, 46h,0C9h,0CCh, 05h, 07h
		db	 4Bh,0CBh, 0Dh, 07h, 88h,0C4h
		db	 06h, 07h, 86h,0C4h,0C9h, 46h
		db	0C8h, 83h, 81h,0C6h, 56h,0CAh
		db	0CCh, 10h, 07h,0C9h,0C7h,0CCh
		db	 56h, 8Ch,0C4h, 46h,0C9h, 56h
		db	 87h,0C4h,0C7h,0CAh,0CCh,0C7h
		db	 83h, 85h,0C4h, 06h, 07h,0CAh
		db	 46h,0C9h,0CAh,0CCh,0CBh,0CCh
		db	 76h,0CBh,0C7h, 8Eh,0C4h, 56h
		db	0CAh,0CCh, 46h, 86h,0C4h, 56h
		db	0CBh, 83h, 85h,0C4h, 0Ch, 07h
		db	0CCh, 06h, 07h, 60h,0C2h, 40h
		db	 41h, 40h, 84h,0C4h, 76h,0CBh
		db	 87h,0C4h, 56h,0CCh, 83h, 85h
		db	0C5h, 56h,0CAh, 4Bh, 46h,0C9h
		db	0CBh, 05h, 07h, 83h, 46h, 8Fh
		db	0C4h,0CAh,0CCh, 76h, 86h,0C4h
		db	0C7h,0CBh,0C9h,0C7h, 83h, 85h
		db	0C4h, 09h, 07h, 8Fh,0C3h, 8Ah
		db	0C4h, 06h, 07h, 86h,0C5h,0C7h
		db	0CAh, 56h, 82h, 85h,0C4h, 66h
		db	0CAh, 4Bh,0CBh,0C7h, 90h,0C5h
		db	 56h, 87h,0C4h,0C7h,0CAh,0CBh
		db	 76h, 85h,0C5h, 05h, 07h, 81h
		db	 85h,0C4h, 07h, 07h,0CCh,0C7h
		db	 8Fh,0C4h, 66h, 86h,0C5h, 06h
		db	 07h, 86h,0C4h,0C7h,0CCh, 56h
		db	0C8h, 81h, 85h,0C4h, 09h, 07h
		db	 85h,0C3h, 81h, 56h, 85h,0C4h
		db	0C7h,0C9h,0C7h, 87h,0C5h, 07h
		db	 07h, 85h,0C4h, 46h,0CCh, 46h
		db	0C8h, 81h, 85h,0C4h,0C7h,0CAh
		db	0CCh, 06h, 07h, 85h,0C5h,0C7h
		db	0C8h,0C7h,0C9h,0C7h, 83h,0C3h
		db	 56h, 88h,0C4h, 76h,0CCh, 76h
		db	 81h, 56h,0CAh,0CCh,0C9h, 46h
		db	 81h, 85h,0C4h, 46h, 4Bh, 05h
		db	 07h, 85h,0C4h, 08h, 07h,0CAh
		db	0CCh,0C7h, 88h,0C4h, 56h,0CCh
		db	0C7h,0CAh,0CCh,0C7h,0CAh,0CCh
		db	 09h, 07h, 81h, 18h, 00h, 38h
		db	 1Ch, 00h, 2Fh, 3Bh, 00h, 20h
		db	 4Eh, 00h, 35h, 70h, 00h, 14h
		db	 8Ah, 00h, 39h, 9Bh, 00h, 3Fh
		db	0C6h, 00h, 30h,0D1h, 00h, 35h
		db	0F7h, 00h, 04h,0FAh, 00h, 15h
		db	0FFh,0FFh,0B5h, 00h, 0Ah,0FFh
		db	0FFh, 10h, 80h, 17h, 05h, 00h
		db	 1Ch, 00h, 38h, 40h,0B8h, 32h
		db	 00h, 3Fh, 00h, 6Bh, 80h, 29h
		db	 63h, 00h, 75h, 00h,0ABh, 40h
		db	 0Ch,0A5h, 00h,0B2h, 00h,0FFh
		db	0FFh, 0Ah, 00h, 34h,0C4h, 17h
		db	 39h, 00h, 2Eh, 00h,0FFh,0FFh
		db	0FFh, 23h, 00h, 2Bh,0C1h, 17h
		db	 39h, 00h, 22h, 00h,0FFh,0FFh
		db	0FFh, 35h, 00h, 11h, 83h, 19h
		db	 49h, 00h, 19h, 00h,0FFh,0FFh
		db	0FFh, 5Fh, 00h, 31h, 83h, 19h
		db	 77h, 00h, 18h, 00h,0FFh,0FFh
		db	0FFh, 7Bh, 00h, 05h,0C0h, 09h
		db	0CDh, 00h,0FFh, 00h,0FFh,0FFh
		db	0FFh, 97h, 00h, 0Fh,0C2h, 19h
		db	0AEh, 00h, 09h, 00h,0FFh,0FFh
		db	0FFh, 99h, 00h, 2Ch,0C3h, 17h
		db	 75h, 00h, 1Fh, 00h,0FFh,0FFh
		db	0FFh,0B3h, 00h, 23h, 82h, 1Ah
		db	 56h, 00h, 06h, 00h,0FFh,0FFh
		db	0FFh,0DEh, 00h, 13h, 01h, 1Ch
		db	 15h, 00h, 0Eh, 00h, 44h, 00h
		db	 20h,0E3h, 00h, 3Bh,0C2h, 18h
		db	 97h, 00h, 0Fh, 00h,0FFh,0FFh
		db	0FFh,0E4h, 00h, 31h, 82h, 1Ah
		db	 06h, 00h, 0Dh, 00h,0FFh,0FFh
		db	0FFh,0ECh, 00h, 04h, 40h, 17h
		db	0A9h, 00h, 12h, 00h, 44h, 00h
		db	 10h,0FAh, 00h, 26h, 84h, 19h
		db	 58h, 00h, 22h, 00h,0FFh,0FFh
		db	0FFh,0FFh,0FFh, 40h, 00h,0FFh
		db	 13h,0C0h,0FFh,0FFh,0FFh,0FFh
		db	 43h, 00h, 20h,0FDh,0D8h, 00h
		db	0FFh, 08h,0D9h,0FFh,0FFh,0FFh
		db	0FFh, 43h, 00h, 10h, 16h,0D9h
		db	 00h, 00h,0FFh,0FFh, 43h, 00h
		db	 08h, 26h,0DAh, 00h, 00h,0FFh
		db	0FFh, 43h, 00h, 04h, 8Dh,0DAh
		db	 00h,0FFh, 98h,0DAh,0FFh,0FFh
		db	0FFh,0FFh, 43h, 00h, 02h,0CDh
		db	0DCh, 00h,0FFh,0D8h,0DCh,0FFh
		db	0FFh,0FFh,0FFh, 43h, 00h, 01h
		db	 06h,0DBh, 00h, 00h,0FFh,0FFh
		db	 44h, 00h, 80h, 6Dh,0DBh, 00h
		db	0FFh, 78h,0DBh,0FFh,0FFh,0FFh
		db	0FFh, 44h, 00h, 40h,0E6h,0DCh
		db	 00h, 00h,0FFh,0FFh, 44h, 00h
		db	 20h, 03h,0D8h, 81h, 1Ch,0FFh
		db	0FFh, 44h, 00h, 10h, 27h,0D8h
		db	0C0h, 17h,0FFh,0FFh,0FFh,0FFh
		db	 15h,0AFh, 04h, 11h
		db	'Cavern of Milagro'
		db	 17h, 00h, 07h, 0Eh, 0Eh, 02h
		db	 00h, 03h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 02h, 00h
		db	 03h, 03h, 00h, 02h, 00h, 28h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 02h, 00h, 28h, 03h
		db	 00h, 0Bh, 00h, 03h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 0Bh, 00h, 03h, 03h, 00h, 0Eh
		db	 00h, 28h,0FFh, 73h, 00h, 05h
		db	 20h, 00h, 00h, 00h, 43h, 00h
		db	 20h, 00h, 00h, 12h, 00h, 0Eh
		db	0FFh,0D0h, 00h, 00h, 20h, 00h
		db	 19h, 00h, 43h, 00h, 10h, 00h
		db	 00h, 16h, 00h, 26h,0FFh, 00h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 16h, 00h, 26h, 00h, 00h, 16h
		db	 00h, 28h,0FFh, 01h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 16h, 00h
		db	 28h, 01h, 00h, 19h, 00h, 09h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 19h, 00h, 09h, 03h
		db	 00h, 1Eh, 00h, 00h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 1Eh, 00h, 00h, 03h, 00h, 1Fh
		db	 00h, 36h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 1Fh, 00h
		db	 36h, 03h, 00h, 25h, 00h, 1Eh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 25h, 00h, 1Eh, 02h
		db	 00h, 3Bh, 00h, 09h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 3Bh, 00h, 09h, 02h, 00h, 3Dh
		db	 00h, 3Eh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 3Dh, 00h
		db	 3Eh, 03h, 00h, 42h, 00h, 13h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 42h, 00h, 13h, 03h
		db	 00h, 45h, 00h, 1Eh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 45h, 00h, 1Eh, 03h, 00h, 49h
		db	 00h, 09h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 49h, 00h
		db	 09h, 02h, 00h, 4Ah, 00h, 28h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 4Ah, 00h, 28h, 03h
		db	 00h, 51h, 00h, 3Eh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 51h, 00h, 3Eh, 03h, 00h, 53h
		db	 00h, 13h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 53h, 00h
		db	 13h, 03h, 00h, 55h, 00h, 09h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 55h, 00h, 09h, 02h
		db	 00h, 55h, 00h, 33h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 55h, 00h, 33h, 02h, 00h, 5Dh
		db	 00h, 2Eh,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 19h, 00h, 43h, 00h
		db	 08h, 00h, 00h, 62h, 00h, 09h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 62h, 00h, 09h, 03h
		db	 00h, 62h, 00h, 13h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 62h, 00h, 13h, 02h, 00h, 6Dh
		db	 00h, 05h,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 6Dh, 00h
		db	 05h, 00h, 00h, 6Dh, 00h, 07h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 6Dh, 00h, 07h, 00h
		db	 00h, 75h, 00h, 33h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 75h, 00h, 33h, 02h, 00h, 79h
		db	 00h, 3Dh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 79h, 00h
		db	 3Dh, 02h, 00h, 7Dh, 00h, 25h
		db	0FFh, 76h, 00h, 00h, 20h, 00h
		db	 00h, 00h, 43h, 00h, 04h, 00h
		db	 00h, 7Dh, 00h, 3Dh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 7Dh, 00h, 3Dh, 02h, 00h, 7Eh
		db	 00h, 1Ah,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 7Eh, 00h
		db	 1Ah, 03h, 00h, 85h, 00h, 11h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 85h, 00h, 11h, 03h
		db	 00h, 86h, 00h, 1Ah,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 86h, 00h, 1Ah, 03h, 00h, 86h
		db	 00h, 25h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 86h, 00h
		db	 25h, 03h, 00h, 8Ah, 00h, 07h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 8Ah, 00h, 07h, 03h
		db	 00h, 8Bh, 00h, 29h,0FFh,0D0h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 43h, 00h, 01h, 00h, 00h, 8Eh
		db	 00h, 37h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 8Eh, 00h
		db	 37h, 02h, 00h, 90h, 00h, 2Eh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 90h, 00h, 2Eh, 03h
		db	 00h, 96h, 00h, 1Dh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 96h, 00h, 1Dh, 03h, 00h, 99h
		db	 00h, 26h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 99h, 00h
		db	 26h, 04h, 00h, 9Eh, 00h, 1Dh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 9Eh, 00h, 1Dh, 03h
		db	 00h, 9Fh, 00h, 37h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 9Fh, 00h, 37h, 03h, 00h,0A2h
		db	 00h, 01h,0FFh, 73h, 00h, 05h
		db	 20h, 00h, 00h, 00h, 44h, 00h
		db	 80h, 00h, 00h,0AAh, 00h, 11h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0AAh, 00h, 11h, 03h
		db	 00h,0B1h, 00h, 11h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0B1h, 00h, 11h, 03h, 00h,0B3h
		db	 00h, 37h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B3h, 00h
		db	 37h, 03h, 00h,0B6h, 00h, 2Fh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0B6h, 00h, 2Fh, 03h
		db	 00h,0BFh, 00h, 16h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0BFh, 00h, 16h, 04h, 00h,0C4h
		db	 00h, 13h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C4h, 00h
		db	 13h, 04h, 00h,0C8h, 00h, 1Ah
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0C8h, 00h, 1Ah, 04h
		db	 00h,0CCh, 00h, 2Eh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0CCh, 00h, 2Eh, 03h, 00h,0D1h
		db	 00h, 27h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0D1h, 00h
		db	 27h, 02h, 00h,0D4h, 00h, 03h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0D4h, 00h, 03h, 04h
		db	 00h,0D5h, 00h, 1Bh,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0D5h, 00h, 1Bh, 04h, 00h,0D6h
		db	 00h, 27h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0D6h, 00h
		db	 27h, 02h, 00h,0D8h, 00h, 3Dh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0D8h, 00h, 3Dh, 02h
		db	 00h,0DCh, 00h, 05h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0DCh, 00h, 05h, 04h, 00h,0DCh
		db	 00h, 33h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0DCh, 00h
		db	 33h, 03h, 00h,0DEh, 00h, 1Dh
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0DEh, 00h, 1Dh, 04h
		db	 00h,0DFh, 00h, 27h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0DFh, 00h, 27h, 03h, 00h,0E2h
		db	 00h, 27h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0E2h, 00h
		db	 27h, 03h, 00h,0E5h, 00h, 27h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0E5h, 00h, 27h, 03h
		db	 00h,0DBh, 00h, 1Fh,0FFh, 00h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	0DBh, 00h, 1Fh, 00h, 00h,0DBh
		db	 00h, 21h,0FFh, 01h, 00h, 00h
		db	 10h, 00h, 00h, 00h,0DBh, 00h
		db	 21h, 01h, 00h,0E8h, 00h, 27h
		db	0FFh, 76h, 00h, 00h, 20h, 00h
		db	 00h, 00h, 43h, 00h, 02h, 00h
		db	 00h,0EBh, 00h, 15h,0FFh,0D0h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 44h, 00h, 40h, 0Dh, 00h,0FAh
		db	 00h, 36h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FAh, 00h
		db	 36h, 03h, 00h,0FFh, 00h, 00h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh, 00h, 00h, 04h
		db	 00h,0C6h, 00h, 27h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0C6h, 00h, 27h, 03h, 00h,0FFh
		db	0FFh

_344MP81	endp

seg_a		ends



		end	start
