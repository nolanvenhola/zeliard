
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_329MP41                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_329MP41	proc	far

start:
		db	0FEh, 13h, 00h, 00h,0B7h,0D1h
		db	0C0h, 00h, 99h,0D0h, 9Bh,0D0h
		db	 9Dh,0D0h,0ECh,0D0h, 36h,0D1h
		db	0A1h,0D1h,0BCh,0D1h, 04h,0FFh
		db	0FFh, 00h, 0Ah, 00h, 00h, 99h
		db	0D0h, 06h, 07h,0C8h, 85h,0C4h
		db	 10h, 07h,0C8h, 8Ch,0C4h, 56h
		db	0C8h, 66h,0C8h, 46h,0C8h, 86h
		db	0CEh,0C4h, 66h, 47h, 86h,0C6h
		db	 8Eh,0C4h, 06h, 07h, 88h,0C4h
		db	 0Ah, 07h, 88h,0C4h, 05h, 07h
		db	 95h,0C4h, 56h,0C8h, 46h,0C8h
		db	 46h, 86h,0C4h, 46h,0C8h, 66h
		db	 47h, 46h,0C8h, 87h,0C4h, 56h
		db	0C8h, 56h,0CAh, 40h,0C2h, 07h
		db	 01h,0C2h, 05h, 01h, 81h,0C4h
		db	 66h,0C8h, 56h,0C8h,0C7h, 85h
		db	0C4h, 0Bh, 07h, 87h,0C4h, 05h
		db	 07h, 95h,0C4h, 0Bh, 07h,0C8h
		db	 0Ch, 07h,0C8h, 88h,0C4h, 76h
		db	0C8h, 86h,0C3h, 8Eh,0C4h, 76h
		db	 47h, 09h, 07h,0C8h,0C7h, 90h
		db	0C4h, 76h,0C8h, 86h,0C4h, 8Eh
		db	0C4h, 66h,0C8h, 0Ah, 07h,0C8h
		db	 92h,0C4h, 56h, 47h, 87h,0C4h
		db	0C7h, 8Dh,0C4h, 56h,0C8h, 76h
		db	0C8h, 66h,0C8h,0C7h, 93h,0C4h
		db	 66h, 88h,0C4h,0C7h, 8Ch,0CDh
		db	 76h,0C8h, 9Eh,0C4h, 76h, 87h
		db	0C4h, 46h, 8Ah,0CDh, 66h,0CAh
		db	 50h, 41h, 08h, 01h,0C2h, 06h
		db	 01h,0C2h,0C1h,0C2h, 50h,0C2h
		db	 40h, 81h,0C4h, 05h, 07h, 86h
		db	0C4h, 46h,0C8h, 88h,0CDh, 46h
		db	 47h, 46h,0A0h,0C4h, 46h,0C8h
		db	0C7h,0C8h, 87h,0C4h, 46h,0C8h
		db	 88h,0C4h, 56h,0C8h,0C7h, 87h
		db	0C3h,0C7h, 88h,0C3h, 8Fh,0C4h
		db	 56h,0C8h, 88h,0C4h, 56h, 47h
		db	 86h,0C4h, 66h,0C8h, 87h,0C4h
		db	 46h,0C8h, 85h,0CBh,0C5h, 8Fh
		db	0C4h, 56h, 89h,0C4h,0C7h,0C8h
		db	0C7h,0C8h, 87h,0C4h,0C8h,0C7h
		db	0C8h,0C7h, 88h,0C4h, 56h, 84h
		db	0CBh,0CCh,0C5h,0C7h, 8Eh,0C4h
		db	 46h,0C8h, 89h,0C4h, 46h,0C8h
		db	 88h,0C4h,0C7h,0C8h, 8Ah,0C4h
		db	 46h,0C8h, 84h,0CBh,0CCh,0C5h
		db	0C7h,0C8h, 8Dh,0C4h,0C7h,0C8h
		db	0C7h,0C8h, 88h,0C4h, 56h,0C8h
		db	 82h,0CFh, 84h,0C4h, 46h,0C8h
		db	 89h,0C4h,0C7h,0C8h,0C7h,0C8h
		db	 83h,0CBh,0CCh,0C5h, 46h,0C8h
		db	 8Ch,0C4h, 76h, 87h,0C4h, 66h
		db	 82h,0D0h, 84h,0C4h, 56h, 89h
		db	0C4h, 66h, 83h,0CBh,0CCh,0C5h
		db	0C8h, 46h, 8Ch,0C4h, 56h,0C8h
		db	 88h,0C4h, 66h,0C8h, 81h,0D1h
		db	 84h,0C4h,0C7h,0C8h, 46h, 88h
		db	0C4h, 56h,0C8h, 83h,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 8Dh,0C4h, 46h
		db	0C8h, 89h,0C4h,0C7h, 47h, 83h
		db	0D2h, 84h,0C4h, 46h,0C8h, 89h
		db	0C4h, 46h,0C8h, 84h,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 8Dh,0C4h, 56h
		db	0C8h, 88h,0C4h, 56h,0C8h, 82h
		db	0D3h, 84h,0C4h, 46h, 8Ah,0C4h
		db	0C7h,0C8h, 46h, 83h,0CBh,0CCh
		db	0C5h, 46h,0C8h, 8Ch,0C4h, 76h
		db	 87h,0C4h, 46h,0C8h,0C7h,0C8h
		db	 86h,0C4h,0C7h, 47h, 89h,0C4h
		db	 56h,0C8h, 83h,0CBh,0CCh,0C5h
		db	 56h, 8Ch,0C4h, 66h,0C8h, 87h
		db	0C4h, 76h, 86h,0C4h, 66h, 88h
		db	0C4h,0C7h, 47h, 84h,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 8Dh,0C4h,0C7h
		db	 57h, 88h,0C4h, 76h, 86h,0C4h
		db	 47h,0C7h,0C8h, 88h,0C4h,0C8h
		db	 56h, 83h,0CBh,0CCh,0C5h, 46h
		db	0C8h, 8Ch,0C4h, 46h,0C8h, 89h
		db	0C4h, 56h,0C8h, 46h, 85h,0C4h
		db	 46h,0C8h, 46h, 87h,0C4h, 46h
		db	0C8h, 84h,0CBh,0CCh,0C5h,0C7h
		db	0C8h,0C7h, 8Ch,0C4h, 46h,0C8h
		db	 89h,0C4h, 76h,0C8h, 85h,0C4h
		db	 56h,0C8h, 46h, 86h,0C4h,0C7h
		db	 47h, 84h,0CBh,0CCh,0C5h, 46h
		db	0C8h, 8Ch,0C4h,0C7h,0C8h,0C7h
		db	 89h,0C4h,0C7h,0C8h, 46h,0C8h
		db	 86h,0C4h, 76h, 87h,0C4h, 46h
		db	 85h,0CBh,0CCh,0C5h,0C7h,0C8h
		db	 8Dh,0C4h, 56h,0C8h, 88h,0C4h
		db	 56h,0C8h, 87h,0C4h, 46h,0C8h
		db	0C7h,0C8h, 87h,0C4h, 56h, 84h
		db	0CBh,0CCh,0C5h, 47h,0C7h, 8Ch
		db	0C4h, 66h,0C8h, 87h,0C4h, 66h
		db	 87h,0C4h, 56h,0C8h,0C7h, 87h
		db	0C4h, 57h, 84h,0CBh,0CCh,0C5h
		db	 46h,0C8h, 8Ch,0C4h, 76h,0C8h
		db	 86h,0C4h, 46h, 47h, 87h,0C4h
		db	 06h, 07h, 85h,0C4h,0C7h,0C8h
		db	 85h,0CBh,0CCh,0C5h, 56h, 8Ch
		db	0C4h, 46h,0C8h, 56h, 86h,0C4h
		db	 56h, 88h,0C4h, 56h,0C8h,0C7h
		db	 87h,0C4h, 46h,0C8h, 84h,0CBh
		db	0CCh,0C5h, 46h,0C8h,0C7h, 8Bh
		db	0C4h, 66h,0C8h, 87h,0C4h,0C7h
		db	 57h, 87h,0C4h, 46h, 47h, 88h
		db	0C4h, 56h, 84h,0CBh,0CCh,0C5h
		db	 56h,0C8h, 8Ah,0CBh,0C4h, 46h
		db	0C8h, 89h,0C4h, 66h, 87h,0C4h
		db	 66h, 88h,0C4h,0C7h,0C8h, 85h
		db	0CBh,0CCh,0C5h, 08h, 07h, 84h
		db	0CBh,0CCh,0C4h, 66h,0C8h, 87h
		db	0C4h,0C7h,0C8h,0C7h,0C8h,0C7h
		db	 86h,0C4h,0C7h, 57h, 88h,0C4h
		db	0C8h,0C7h, 85h,0CBh,0CCh,0C5h
		db	 09h, 07h, 83h,0CBh,0CCh,0C4h
		db	 76h,0C8h, 86h,0C4h, 76h,0C8h
		db	 85h,0C4h, 05h, 07h, 86h,0C4h
		db	 46h, 86h,0CBh,0C5h, 09h, 07h
		db	 84h,0CBh,0C4h, 46h,0C8h, 89h
		db	0C4h, 06h, 07h, 84h,0C4h, 56h
		db	0C8h,0C7h, 87h,0C4h,0C7h, 84h
		db	0C3h, 83h,0C4h, 46h,0C8h,0C7h
		db	0C8h, 76h,0C8h, 84h,0C6h, 8Ch
		db	0C4h, 66h,0C8h,0C7h,0C8h, 84h
		db	0C4h, 66h,0C8h, 87h,0C4h, 85h
		db	0C4h, 66h,0C8h, 76h,0C8h, 56h
		db	0C8h, 84h, 8Dh,0C4h, 76h, 86h
		db	0C4h, 56h, 47h, 87h,0C4h, 84h
		db	0CBh,0C5h, 66h,0C8h, 05h, 07h
		db	0C8h, 56h, 84h, 8Dh,0C4h, 46h
		db	0C8h,0C7h,0C8h, 86h,0C4h, 46h
		db	0C8h,0C7h,0C8h, 46h,0C8h, 84h
		db	0C6h, 83h,0CBh,0CCh,0C5h, 46h
		db	0C8h, 08h, 07h,0C8h, 46h,0C8h
		db	 83h, 8Dh,0C4h, 56h,0C8h, 87h
		db	0C4h, 05h, 07h,0C8h,0C7h, 88h
		db	0CBh,0CCh,0C5h, 0Ch, 07h,0C8h
		db	 46h,0C8h, 82h, 8Dh,0C4h,0C7h
		db	0C8h,0C7h, 88h,0C4h,0C7h,0C8h
		db	 05h, 07h,0C8h, 87h,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 07h, 07h,0C8h
		db	 66h,0C8h,0C7h,0C8h, 81h,0C8h
		db	 8Ch,0C4h,0C7h,0C8h, 89h,0C4h
		db	 66h,0C8h, 46h,0C8h,0C7h, 87h
		db	0CBh,0CCh,0C5h, 08h, 07h,0C8h
		db	 08h, 07h,0C7h, 8Ch,0C4h, 46h
		db	0C8h, 88h,0C4h, 83h,0C6h, 76h
		db	0C8h, 86h,0CBh,0CCh,0C5h, 56h
		db	0C8h, 46h,0C8h,0C7h,0C8h, 09h
		db	 07h, 8Dh,0C4h, 46h, 89h,0C6h
		db	 86h,0C4h,0C7h,0C8h, 46h, 85h
		db	0CBh,0CCh,0C5h, 0Fh, 07h,0C8h
		db	0C7h, 81h, 8Dh,0C4h,0C7h,0C8h
		db	 90h,0C4h, 56h,0C8h, 85h,0CBh
		db	0CCh,0C5h,0C7h,0C8h, 76h,0C8h
		db	 08h, 07h,0C8h, 81h, 8Dh,0C4h
		db	 46h,0CAh, 40h,0C2h, 70h,0C2h
		db	0C1h,0C2h, 40h, 82h,0C4h, 46h
		db	0C8h, 86h,0CBh,0CCh,0C5h, 0Fh
		db	 07h,0C8h, 82h, 8Dh,0C4h, 66h
		db	 8Eh,0C4h, 56h, 86h,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 05h, 07h,0C8h
		db	 05h, 07h,0C8h, 83h,0C2h, 06h
		db	 01h,0C2h, 50h, 81h,0C4h, 46h
		db	0C8h,0C7h, 82h,0C3h, 8Bh,0C4h
		db	0C7h, 47h, 86h,0CBh,0CCh,0C5h
		db	 10h, 07h,0CAh,0C1h, 8Dh,0C4h
		db	 56h, 83h,0C4h, 8Bh,0C4h, 56h
		db	0C8h, 85h,0CBh,0CCh,0C5h,0C7h
		db	0C8h, 08h, 07h,0C8h, 66h, 83h
		db	 85h,0C3h, 87h,0C4h, 56h, 83h
		db	0C4h,0C7h, 8Ah,0C4h, 66h, 85h
		db	0CBh,0CCh,0C5h, 0Eh, 07h,0C8h
		db	 83h, 85h,0C4h, 87h,0C4h,0C7h
		db	0C8h,0C7h, 83h,0C4h,0C7h,0C8h
		db	 89h,0C4h, 56h,0C8h, 85h,0CBh
		db	0C5h, 05h, 07h,0C8h, 08h, 07h
		db	0C8h,0C7h, 82h, 85h,0C4h,0C7h
		db	 86h,0C4h, 46h, 84h,0C4h,0C7h
		db	 47h, 88h,0C4h,0C8h,0C7h,0C8h
		db	 84h,0C3h, 81h,0C3h, 0Bh, 07h
		db	 47h, 82h,0C4h, 56h, 81h, 85h
		db	0C4h, 56h, 84h,0C4h, 46h,0C8h
		db	 83h,0C4h,0C8h,0C7h, 89h,0C4h
		db	 46h,0C8h, 84h,0C4h, 76h,0C8h
		db	 46h,0C8h, 46h, 87h,0C4h, 66h
		db	 85h,0C4h,0C7h, 47h, 84h,0C4h
		db	0C7h,0C8h, 84h,0C4h,0C7h, 47h
		db	 88h,0C4h, 46h, 47h, 83h,0C4h
		db	 09h, 07h,0C8h, 87h,0C4h, 56h
		db	 81h, 85h,0C4h, 46h, 85h,0C4h
		db	 46h, 84h,0C4h, 56h, 88h,0C4h
		db	 56h, 84h,0C6h,0CBh,0CCh,0C5h
		db	0C7h, 47h, 56h,0C8h, 88h,0C4h
		db	 46h,0C8h, 81h, 85h,0C4h,0C7h
		db	 47h, 84h,0C4h,0C7h,0C8h, 84h
		db	0C4h, 56h,0C8h, 87h,0C4h,0C7h
		db	0C8h, 46h, 84h,0CBh,0CCh,0C5h
		db	 56h,0C8h, 46h,0C8h, 88h,0C4h
		db	 56h,0C8h, 85h,0C4h, 56h, 84h
		db	0C4h,0C7h, 85h,0C4h, 56h, 88h
		db	0C4h, 56h,0C8h, 84h,0CBh, 4Bh
		db	0C5h, 76h, 89h,0C4h, 66h, 85h
		db	0C4h, 46h,0C8h,0C7h, 83h,0C4h
		db	 86h,0C4h, 46h, 47h, 87h,0C4h
		db	 46h,0C8h, 85h,0CBh, 4Bh,0C5h
		db	 76h, 89h,0C4h, 46h,0C8h, 81h
		db	 85h,0C4h, 46h,0C8h,0C7h, 83h
		db	0C4h, 86h,0C4h, 46h,0C8h,0C7h
		db	0C8h, 86h,0C4h, 56h, 85h,0CBh
		db	 4Bh,0C5h,0C7h,0C8h, 46h, 8Ah
		db	0C4h, 56h,0C8h, 85h,0C4h, 76h
		db	 82h,0C6h, 86h,0C4h, 76h, 86h
		db	0C4h,0C7h,0C8h, 46h, 84h,0CBh
		db	 4Bh,0C5h, 46h,0C8h,0C7h, 8Ah
		db	0C4h, 66h,0C7h, 84h,0C4h, 66h
		db	0C8h, 89h,0C4h, 66h,0C8h, 86h
		db	0C4h, 56h, 85h,0CBh, 4Bh,0C5h
		db	0C8h, 46h, 8Bh,0C4h, 66h,0C8h
		db	 84h,0C4h,0C7h,0C8h,0C7h,0C8h
		db	0C7h, 89h,0C4h,0C7h,0C8h, 56h
		db	 86h,0C4h, 46h,0C8h, 85h,0CBh
		db	 4Bh,0C5h,0C7h,0C8h,0C7h,0C8h
		db	 8Ah,0C4h, 46h,0C8h,0C7h, 85h
		db	0C4h, 05h, 07h, 88h,0C4h, 56h
		db	0C8h, 46h, 85h,0C4h,0C8h, 46h
		db	 86h,0CBh,0CCh,0C5h, 56h,0C8h
		db	 8Ah,0C4h, 56h,0C8h,0C7h, 84h
		db	0C4h, 46h, 57h, 89h,0C4h, 76h
		db	 47h, 84h,0C4h, 46h,0C8h, 86h
		db	0CBh,0CCh,0C5h,0C7h,0C8h, 46h
		db	 8Ah,0C4h, 66h, 85h,0C4h, 56h
		db	 8Bh,0C4h, 76h,0C8h, 85h,0C4h
		db	 56h, 86h,0CBh,0C5h, 76h, 8Ah
		db	0C4h, 66h,0C8h, 84h,0C4h,0C7h
		db	 47h, 8Bh,0CEh, 66h,0C8h,0C7h
		db	 85h,0C4h, 46h, 47h, 85h,0CBh
		db	0C5h, 76h, 8Ah,0C4h, 56h,0C8h
		db	 85h,0C4h,0C8h,0C7h, 8Dh,0CEh
		db	 76h, 85h,0C4h,0C8h, 46h, 86h
		db	0CBh,0C5h, 46h,0C8h,0C7h,0C8h
		db	 8Ah,0C4h, 66h, 85h,0C4h, 90h
		db	0CEh, 56h, 47h, 84h,0C4h,0C7h
		db	0C8h, 46h, 85h,0CBh,0C5h, 76h
		db	 8Ah,0C4h, 56h,0C8h, 85h,0C6h
		db	 91h,0CEh, 56h, 85h,0C4h, 56h
		db	0C8h, 83h,0C3h, 81h,0C3h, 76h
		db	0C8h, 8Ah,0C4h, 46h,0C8h, 81h
		db	 98h,0C4h,0C7h,0C8h, 85h,0C4h
		db	0C7h,0C8h, 85h,0C4h, 07h, 07h
		db	 8Ah,0C4h, 46h, 82h,0C2h, 07h
		db	 01h,0C2h,0C1h,0C2h, 05h, 01h
		db	0C2h, 50h, 82h,0C4h,0C7h,0C8h
		db	 85h,0C4h,0C7h,0C8h,0C7h, 84h
		db	0C4h, 07h, 07h,0C8h, 89h,0C4h
		db	 56h,0CAh, 98h,0C4h, 46h,0C8h
		db	 84h,0C4h, 56h,0C8h, 83h,0C4h
		db	 07h, 07h,0C8h, 89h,0C4h, 56h
		db	 81h, 85h,0C3h, 92h,0C4h, 56h
		db	 84h,0C4h, 56h, 84h,0C6h, 83h
		db	0C4h, 56h,0C8h, 8Ah,0C4h, 56h
		db	0C8h, 85h,0C4h, 92h,0C4h,0C7h
		db	0C8h, 85h,0C4h,0C7h, 47h, 88h
		db	0C4h, 56h,0C8h, 8Ah,0C4h, 66h
		db	 85h,0C4h,0C7h, 91h,0C4h, 46h
		db	0C8h, 84h,0C4h,0C7h,0CAh,0C2h
		db	 50h,0C2h, 50h, 81h,0C4h, 56h
		db	0C8h, 8Ah,0C4h, 56h,0C8h,0C7h
		db	 84h,0C4h, 46h, 90h,0C4h,0C8h
		db	0C7h, 85h,0C4h, 56h, 88h,0C4h
		db	 46h,0C8h, 8Bh,0C4h, 46h,0C8h
		db	0C7h, 85h,0C4h, 56h, 8Fh,0C4h
		db	 46h,0C8h, 84h,0C4h, 66h,0C8h
		db	 86h,0C4h, 46h,0C8h, 8Bh,0C4h
		db	 56h,0C8h, 85h,0C4h, 46h,0C8h
		db	 46h, 8Dh,0C4h,0C7h, 57h, 83h
		db	0C4h, 46h,0C8h, 88h,0C4h, 56h
		db	 8Bh,0C4h, 46h,0C8h, 81h, 85h
		db	0C4h, 46h, 47h, 8Eh,0C4h, 46h
		db	0C8h, 84h,0C4h, 56h,0C8h, 87h
		db	0C4h, 56h,0C8h, 88h,0C3h, 81h
		db	0C4h, 46h, 82h, 85h,0C4h,0C7h
		db	0C8h,0C7h, 8Ah,0C3h, 84h,0C4h
		db	 56h, 84h,0C4h, 66h, 87h,0C4h
		db	 66h,0C8h, 87h,0C4h, 81h,0C6h
		db	 46h,0C8h, 81h, 85h,0C4h, 46h
		db	0C8h, 8Ah,0C4h,0C7h, 83h,0C4h
		db	0C7h,0C8h, 85h,0C4h, 56h, 47h
		db	 86h,0C4h, 66h, 88h,0C4h, 82h
		db	0C4h,0C7h,0C8h, 81h, 85h,0C4h
		db	0C7h,0C8h, 8Bh,0C4h,0C7h,0C8h
		db	 76h,0C8h, 84h,0C4h, 66h, 87h
		db	0C4h, 56h,0C8h,0C7h, 87h,0C4h
		db	0C8h, 81h,0C4h,0C7h,0C8h, 81h
		db	 85h,0C6h, 8Dh,0C4h, 05h, 07h
		db	0C8h, 85h,0C4h,0C7h,0C8h, 46h
		db	 87h,0C4h, 76h,0C8h, 86h,0C4h
		db	0C7h, 81h,0C4h,0C7h,0C8h, 81h
		db	 8Ah,0C3h, 88h,0C4h, 56h, 47h
		db	 46h, 85h,0C4h, 56h, 47h, 86h
		db	0C4h, 05h, 07h, 86h,0C4h,0C7h
		db	 81h,0C4h, 57h, 89h,0CBh,0C5h
		db	 88h,0C4h, 66h,0C8h,0C7h,0C8h
		db	 85h,0C4h, 66h, 87h,0C4h, 66h
		db	0C8h, 87h,0C4h,0C7h, 81h,0C4h
		db	 46h, 81h, 88h,0CBh,0CCh,0C5h
		db	0C7h, 87h,0C4h, 06h, 07h, 85h
		db	0C4h, 66h,0C8h, 86h,0C4h, 66h
		db	0C8h, 87h,0C4h,0C7h, 81h,0C4h
		db	0C7h,0C8h, 81h, 88h,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 86h,0C4h, 07h
		db	 07h, 84h,0C4h, 46h, 47h, 87h
		db	0C4h, 46h,0C8h, 46h, 87h,0C4h
		db	0C8h, 81h,0C6h, 83h, 88h,0CBh
		db	0CCh,0C5h,0C7h,0C8h, 86h,0C4h
		db	 76h, 47h, 85h,0C4h, 56h, 88h
		db	0C4h, 56h,0C8h, 88h,0C4h,0C8h
		db	 85h, 88h,0CBh,0CCh,0C5h, 46h
		db	0C8h, 85h,0C4h, 06h, 07h, 85h
		db	0C4h, 66h,0C8h, 86h,0C4h, 56h
		db	 47h, 87h,0C4h,0C7h,0C8h, 84h
		db	 88h,0CBh,0CCh,0C5h, 46h, 86h
		db	0C4h, 76h, 47h, 85h,0C4h, 66h
		db	 87h,0C4h,0C7h,0C8h, 46h, 88h
		db	0C4h, 46h, 84h, 88h,0CBh,0CCh
		db	0C5h,0C7h,0C8h,0C7h,0C8h, 84h
		db	0C4h, 66h, 47h,0C7h, 85h,0C4h
		db	 46h,0C8h, 88h,0C4h, 46h, 47h
		db	 88h,0C4h, 46h, 84h, 88h,0CBh
		db	0CCh,0C5h, 46h,0C8h, 85h,0C4h
		db	 05h, 07h, 86h,0C4h, 56h,0C8h
		db	 87h,0C4h,0C7h,0C8h, 8Ah,0C4h
		db	 46h,0C8h, 83h, 88h,0CBh,0CCh
		db	0C5h,0C7h, 47h, 85h,0C4h, 05h
		db	 07h, 86h,0C4h, 66h, 87h,0C4h
		db	0C7h,0C8h, 8Ah,0C4h, 56h,0C8h
		db	 82h, 88h,0CBh,0CCh,0C5h, 46h
		db	 86h,0C4h, 66h, 47h, 86h,0C4h
		db	0C7h,0C8h, 46h,0C8h, 86h,0C4h
		db	 46h,0C8h, 89h,0C4h,0C7h,0C8h
		db	 46h, 82h, 88h,0CBh,0CCh,0C5h
		db	 56h, 85h,0C4h, 46h,0C8h,0C7h
		db	0C8h, 87h,0C4h, 56h,0C8h, 87h
		db	0C4h, 46h,0C8h, 89h,0C4h,0C7h
		db	0C8h, 56h, 81h, 88h,0CBh,0CCh
		db	0C5h, 66h, 84h,0C4h, 66h, 88h
		db	0C4h, 66h,0C8h, 86h,0C4h, 56h
		db	 89h,0C4h, 56h, 47h, 81h, 88h
		db	0CBh,0CCh,0C5h,0C7h,0C8h,0C7h
		db	0C8h, 84h,0C4h, 76h, 87h,0C4h
		db	 66h, 87h,0C4h,0C7h, 47h, 89h
		db	0C4h, 66h, 82h, 88h,0CBh,0CCh
		db	0C5h, 46h,0C8h, 85h,0C4h, 56h
		db	0C8h, 46h, 86h,0C4h, 56h,0C8h
		db	 87h,0C4h, 46h, 8Ah,0C4h, 56h
		db	0C8h, 82h, 88h,0CBh,0CCh,0C5h
		db	0C7h, 47h, 85h,0C4h, 66h,0C8h
		db	 87h,0C4h, 66h, 87h,0C4h,0C7h
		db	0C8h, 8Ah,0C4h, 56h, 83h, 88h
		db	0CBh,0CCh,0C5h,0C7h,0C8h, 86h
		db	0C4h, 56h, 47h, 87h,0C4h, 46h
		db	 89h,0C4h, 46h, 8Ah,0C4h,0C7h
		db	0C8h, 46h, 82h, 88h,0CBh,0CCh
		db	0C5h, 46h, 86h,0C4h, 66h,0C8h
		db	 87h,0C4h, 56h,0C8h, 87h,0C4h
		db	 46h, 8Ah,0C4h,0C7h,0C8h, 46h
		db	 82h, 88h,0CBh,0CCh,0C5h,0C7h
		db	0C8h,0C7h, 85h,0C4h,0C7h,0C8h
		db	 56h,0C8h, 86h,0C4h, 46h,0C8h
		db	0C7h, 87h,0C4h, 56h, 89h,0C4h
		db	 56h, 83h, 88h,0CBh,0CCh,0C5h
		db	 46h,0C8h, 85h,0C4h, 06h, 07h
		db	 85h,0C4h, 66h,0C8h, 86h,0C4h
		db	 56h, 89h,0C4h, 56h, 83h, 88h
		db	0CBh,0CCh,0C5h,0C7h,0C8h, 86h
		db	0C4h, 05h, 07h, 86h,0C4h, 76h
		db	 86h,0C4h, 56h, 89h,0C4h, 56h
		db	0C8h, 82h, 88h,0CBh,0CCh,0C5h
		db	0C7h, 87h,0C4h, 56h,0C8h,0C7h
		db	 87h,0C4h, 76h, 86h,0C4h, 66h
		db	 88h,0C4h, 46h,0C8h,0C7h, 82h
		db	 88h,0CBh,0CCh,0C5h,0C7h, 87h
		db	0C4h, 66h, 47h, 86h,0C4h, 56h
		db	0C8h,0C7h, 86h,0C4h, 66h, 88h
		db	0C4h, 56h, 83h, 88h,0CBh,0CCh
		db	0C5h,0C8h, 87h,0C4h, 56h, 47h
		db	 87h,0C4h, 66h,0C8h, 86h,0C4h
		db	 76h,0C8h, 86h,0C4h, 56h, 83h
		db	 89h,0CBh,0C5h,0C8h, 87h,0C4h
		db	 05h, 07h, 86h,0C4h, 56h,0C8h
		db	0C7h, 86h,0C4h, 56h,0C8h, 76h
		db	0C8h, 82h,0C4h, 56h, 83h, 8Ah
		db	0C4h, 88h,0C4h, 56h,0C8h,0C7h
		db	 87h,0C4h, 66h,0C8h, 86h,0C4h
		db	 0Fh, 07h, 83h, 85h,0C3h, 84h
		db	0C6h, 88h,0C4h, 56h,0C8h, 88h
		db	0C4h, 46h,0C8h, 46h, 86h,0C4h
		db	0C8h, 56h,0C8h, 0Ah, 07h, 83h
		db	 85h,0C4h, 8Dh,0C4h,0C7h, 57h
		db	 88h,0C4h, 56h, 47h, 86h,0C4h
		db	 66h,0C8h, 76h, 47h, 56h, 84h
		db	 85h,0C4h,0C7h, 8Bh,0CDh, 66h
		db	 89h,0C4h, 66h, 87h,0C4h,0C7h
		db	0C8h, 66h,0C8h, 76h,0C8h, 46h
		db	 84h, 85h,0C4h, 46h,0C8h, 88h
		db	0CDh, 56h,0CAh,0C2h, 05h, 01h
		db	0C2h,0C1h, 81h,0C4h, 46h, 47h
		db	 87h,0C4h,0C7h,0C8h, 76h,0C8h
		db	 66h,0C8h, 46h, 84h, 85h,0C4h
		db	 56h, 47h, 85h,0CDh, 46h,0C8h
		db	0C7h,0C8h, 8Ah,0C4h, 66h,0C8h
		db	 86h,0C4h, 07h, 07h,0C8h, 46h
		db	0C8h, 56h, 84h, 85h,0C4h,0C7h
		db	0C8h, 66h, 83h,0CDh, 05h, 07h
		db	 84h,0C3h, 85h,0C4h, 05h, 07h
		db	 85h,0C4h, 0Eh, 07h, 84h, 85h
		db	0C4h, 56h,0C8h,0C7h,0C8h, 83h
		db	0C4h, 56h, 47h, 85h,0C4h, 85h
		db	0C4h, 76h, 86h,0C4h,0C7h,0C8h
		db	 08h, 07h,0C8h,0C7h,0C8h,0C7h
		db	 84h, 85h,0C4h, 46h, 47h, 85h
		db	0C4h, 76h, 85h,0C4h, 85h,0C4h
		db	 46h,0C8h,0C7h,0C8h, 86h,0C4h
		db	0C7h,0C8h, 09h, 07h,0C8h, 56h
		db	0C8h, 82h, 85h,0C4h, 56h,0C8h
		db	 85h,0C4h,0C7h, 57h, 86h,0C4h
		db	0C7h, 84h,0C4h, 56h,0C8h, 87h
		db	0C4h, 76h, 57h, 76h,0C8h,0C7h
		db	0C8h, 83h, 85h,0C4h,0C7h, 47h
		db	 86h,0C4h, 46h,0C8h, 87h,0C4h
		db	0C7h, 84h,0C4h, 56h, 88h,0C4h
		db	0C7h,0C8h, 0Bh, 07h,0C8h, 84h
		db	 85h,0C4h,0C7h, 88h,0C4h, 66h
		db	 86h,0C4h, 46h,0C8h, 76h,0C8h
		db	 88h,0C4h, 56h,0C8h, 0Ah, 07h
		db	0C8h, 83h, 85h,0C6h, 89h,0C4h
		db	 46h, 47h, 86h,0C4h, 66h,0C8h
		db	 46h,0C8h, 46h, 87h,0C4h, 0Fh
		db	 07h, 83h, 8Fh,0C4h, 76h, 85h
		db	0C4h, 08h, 07h, 88h,0C4h,0C7h
		db	0C8h,0C7h,0C8h, 0Ch, 07h, 82h
		db	0C2h, 08h, 01h,0C2h, 40h, 82h
		db	0C4h, 56h, 47h, 85h,0C4h, 06h
		db	 07h, 47h, 88h,0C4h, 46h,0C8h
		db	 66h,0C8h,0C7h,0CAh, 66h,0C8h
		db	0C7h,0C8h,0C7h,0CAh, 8Fh,0C4h
		db	0C7h,0C8h,0C7h,0C8h, 86h,0C4h
		db	 05h, 07h,0C8h, 8Ah,0C4h, 66h
		db	0C8h,0C7h,0C8h,0C7h,0C8h, 84h
		db	0C4h,0C7h,0C8h, 46h, 81h,0C8h
		db	 46h,0C8h, 8Bh,0C4h, 46h, 88h
		db	0C4h, 56h,0C8h, 56h,0C8h, 89h
		db	0C4h,0C8h, 76h, 87h,0C4h,0C7h
		db	0C8h, 56h, 76h, 8Ah,0C4h,0C7h
		db	0C8h, 88h,0C4h, 07h, 07h, 89h
		db	0C4h, 56h, 47h, 88h,0C4h,0C8h
		db	 82h,0C6h,0C7h, 83h,0C6h,0C7h
		db	 47h, 88h,0C4h,0C7h, 89h,0C4h
		db	 66h,0C8h,0C7h, 8Bh,0C4h, 76h
		db	 88h,0C6h, 85h, 84h,0C4h,0C7h
		db	0C8h, 88h,0C4h, 8Ah,0C4h, 56h
		db	 47h, 8Ch,0C4h, 76h, 8Eh, 50h
		db	 81h,0C4h, 46h,0C8h, 87h,0C6h
		db	 8Ah,0C4h,0C7h,0C8h, 56h, 85h
		db	0C3h, 86h,0C4h,0C7h,0C8h, 56h
		db	 50h,0C2h, 08h, 01h,0C2h, 84h
		db	0C4h, 66h, 91h,0C4h, 56h,0C8h
		db	 86h,0C4h, 86h,0C4h,0C7h,0C8h
		db	0C7h, 47h, 8Eh, 84h,0C4h, 56h
		db	0CAh,0C1h,0C2h, 40h,0C2h, 07h
		db	 01h,0C2h, 40h, 81h,0C4h, 46h
		db	0C8h, 86h,0CBh,0C5h,0C7h, 85h
		db	0C4h, 56h,0C8h, 85h,0C3h,0C7h
		db	0C8h, 87h, 84h,0C4h, 46h,0C8h
		db	 92h,0C4h, 66h, 84h,0CBh,0CCh
		db	0C5h,0C7h, 85h,0C4h, 66h,0C8h
		db	 84h,0C4h, 46h, 87h, 84h,0C6h
		db	 66h, 91h,0C4h,0C7h,0C8h,0C7h
		db	0C8h, 84h,0CBh,0CCh,0C5h,0C7h
		db	0C8h, 84h,0C4h, 76h, 84h,0C4h
		db	 56h, 86h, 85h,0C4h, 46h,0C8h
		db	0C7h, 8Ch,0C3h, 05h, 07h, 86h
		db	0CBh,0CCh,0C5h,0C8h, 85h,0C4h
		db	 46h,0C8h,0C7h,0C8h, 84h,0C4h
		db	 56h, 86h, 85h,0C6h, 56h,0C8h
		db	0C7h, 8Ah,0C3h, 05h, 07h,0C8h
		db	 86h,0CBh,0CCh,0C5h,0C7h,0C8h
		db	 84h,0C4h, 56h,0C8h, 85h,0C4h
		db	 46h,0C8h, 86h, 85h,0CBh,0CCh
		db	0C4h, 66h, 87h,0C3h, 05h, 07h
		db	 47h, 87h,0CBh,0CCh,0C5h, 46h
		db	0C8h, 83h,0C4h, 56h,0C8h, 85h
		db	0C6h,0C7h,0C8h, 83h,0C3h, 83h
		db	 85h,0CBh,0CCh,0C4h, 05h, 07h
		db	0C8h, 0Bh, 07h, 88h,0CBh,0CCh
		db	0C5h, 56h, 83h,0C4h, 56h, 8Ch
		db	0C4h,0C7h, 82h, 85h,0CBh,0CCh
		db	0C4h, 0Dh, 07h,0C8h, 46h,0C8h
		db	 84h,0C3h, 84h,0CBh,0CCh,0C5h
		db	0C7h,0C8h, 84h,0C4h,0C7h,0C8h
		db	0C7h,0CAh, 40h,0C2h, 70h, 83h
		db	0C4h,0C8h, 82h, 85h,0CBh,0CCh
		db	0C4h, 46h,0C8h, 06h, 07h,0C8h
		db	 46h, 89h,0C4h, 84h,0CBh,0CCh
		db	0C5h, 46h,0C8h, 83h,0C4h, 56h
		db	 8Ch,0C4h,0C7h,0C8h, 81h, 85h
		db	0CBh,0CCh,0C4h, 56h, 47h,0C7h
		db	 90h,0C4h,0C7h, 83h,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 84h,0C4h, 56h
		db	0C8h, 84h,0C3h, 86h,0C4h, 46h
		db	0C8h,0C8h, 84h,0CBh,0CCh,0C4h
		db	 76h,0C8h, 90h,0C4h,0C8h,0C7h
		db	 82h,0CBh,0CCh,0C5h,0C8h, 85h
		db	0C4h, 46h,0C8h, 85h,0C4h, 86h
		db	0C4h, 56h, 46h, 83h,0CBh,0CCh
		db	0C4h, 46h,0C8h,0C7h,0C8h, 91h
		db	0C4h,0C7h,0C8h, 82h,0CBh,0CCh
		db	0C5h,0C7h, 85h,0C4h,0C7h,0C8h
		db	0C7h, 85h,0C4h,0C8h, 85h,0C4h
		db	 46h,0C8h,0C8h, 84h,0CBh,0CCh
		db	0C4h,0C7h,0C8h, 46h, 92h,0C4h
		db	0C7h, 83h,0CBh,0CCh,0C5h,0C7h
		db	 85h,0C4h, 66h, 84h,0C4h,0C7h
		db	0C8h, 84h,0C4h, 56h, 85h,0CBh
		db	0CCh,0C4h,0C8h, 46h, 47h, 91h
		db	0C6h, 84h,0CBh,0CCh,0C5h,0C8h
		db	 85h,0C4h, 56h,0C8h, 84h,0C4h
		db	 46h, 84h,0C4h, 46h,0C8h, 85h
		db	0CBh,0CCh,0C4h, 05h, 07h, 95h
		db	0CBh,0CCh,0C5h,0C7h,0C8h, 84h
		db	0C4h, 56h,0C8h, 84h,0C4h, 56h
		db	 83h,0C4h, 56h, 85h,0CBh,0CCh
		db	0C4h, 66h,0C8h,0C7h,0CAh, 50h
		db	0C2h, 07h, 01h,0C2h, 40h, 85h
		db	0CBh,0CCh,0C5h, 46h,0C8h, 83h
		db	0C4h, 46h,0C8h, 85h,0C4h,0C7h
		db	 47h, 83h,0C4h,0C7h,0C8h, 81h
		db	 85h,0CBh,0CCh,0C4h, 76h, 96h
		db	0CBh,0CCh,0C5h,0C7h,0C8h,0C7h
		db	 83h,0C4h, 56h, 85h,0C4h, 46h
		db	 84h,0C4h,0C7h, 82h, 85h,0CBh
		db	0CCh,0C4h, 46h,0C8h,0C7h,0C8h
		db	 87h,0C3h, 8Eh,0CBh,0CCh,0C5h
		db	 46h, 84h,0C4h, 56h, 85h,0C4h
		db	0C7h,0C8h, 84h,0C6h, 83h, 85h
		db	0CBh,0CCh,0C4h,0C7h,0C8h, 8Ah
		db	0C4h,0C7h, 8Dh,0CBh,0CCh,0C5h
		db	 46h,0C8h, 83h,0C4h,0C7h, 47h
		db	 85h,0C4h,0C8h, 89h, 85h,0CBh
		db	0CCh,0C4h, 46h,0C8h, 89h,0C6h
		db	0C7h,0C8h, 46h, 47h, 88h,0CBh
		db	0CCh,0C5h,0C8h,0C7h, 84h,0C4h
		db	 56h,0C8h, 84h,0C4h,0CAh,0C1h
		db	0C2h, 60h,0C2h,0C1h, 81h, 85h
		db	0CBh,0CCh,0C4h, 46h, 8Bh,0C4h
		db	0C7h,0C8h,0C7h, 8Ah,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 84h,0C4h, 56h
		db	0C8h, 84h,0C4h,0C7h, 89h, 85h
		db	0CBh,0CCh,0C4h,0C7h,0C8h, 8Bh
		db	0C6h,0C8h, 86h,0C3h, 85h,0CBh
		db	0CCh,0C5h, 46h, 84h,0C4h, 66h
		db	 84h,0C4h, 47h, 88h, 85h,0CBh
		db	0CCh,0C4h, 46h,0C8h, 92h,0C4h
		db	0C7h, 84h,0CBh,0CCh,0C5h,0C7h
		db	0C8h, 84h,0C4h,0C7h,0C8h,0C7h
		db	0C8h, 84h,0C4h, 46h, 88h, 86h
		db	0CBh,0C4h, 46h, 93h,0C6h, 85h
		db	0CBh,0CCh,0C5h,0C8h,0C7h, 84h
		db	0C4h, 56h,0C8h, 84h,0C4h,0C7h
		db	0C8h,0C7h, 87h, 87h,0C4h,0C7h
		db	0C8h, 99h,0CBh,0CCh,0C5h,0C7h
		db	 85h,0C4h, 46h,0C8h, 85h,0C4h
		db	 46h,0C8h, 87h, 87h,0C6h, 9Bh
		db	0CBh,0CCh,0C5h,0C7h,0C8h, 84h
		db	0C4h, 56h, 85h,0C4h,0C7h,0C8h
		db	0C7h, 87h, 8Bh,0C3h, 97h,0CBh
		db	0CCh,0C5h, 46h,0C8h, 83h,0C4h
		db	 46h,0C8h,0C7h, 84h,0C4h,0C8h
		db	0C7h, 88h, 81h,0C3h, 89h,0C4h
		db	 97h,0CBh,0CCh,0C5h,0C7h,0C8h
		db	 84h,0C4h, 56h,0C8h, 84h,0C4h
		db	0C7h, 89h, 81h,0C4h,0C7h, 88h
		db	0C4h,0C7h, 97h,0CBh,0C5h,0C7h
		db	 85h,0C4h,0C7h,0C8h,0C7h,0C8h
		db	 84h,0C4h,0C7h, 89h, 81h,0C4h
		db	0C7h,0C8h, 87h,0C4h,0C7h,0C8h
		db	 97h,0C4h,0C8h, 85h,0C4h, 46h
		db	0C8h, 85h,0C4h, 8Ah, 81h,0C4h
		db	 56h,0C8h, 85h,0C4h,0C8h, 98h
		db	0C4h, 86h,0C4h, 56h, 85h,0C6h
		db	 8Ah, 81h,0C4h, 46h,0C8h, 86h
		db	0C4h,0C7h, 92h,0C3h, 85h,0C6h
		db	 86h,0C4h, 46h, 47h, 8Fh, 81h
		db	0C4h,0C8h, 88h,0C4h, 46h,0CAh
		db	0C1h,0C2h, 05h, 01h, 88h,0C4h
		db	 8Ch,0C4h,0C7h,0C8h,0C7h, 90h
		db	 81h,0C4h,0C7h, 88h,0C4h,0C7h
		db	 92h,0C4h,0C7h,0C8h, 8Ah,0C4h
		db	 66h,0C8h, 8Eh, 81h,0C6h, 89h
		db	0C4h,0C8h, 87h,0C3h, 8Ah,0C4h
		db	0C8h, 8Bh,0C4h, 06h, 07h, 8Ch
		db	 8Ah,0CBh,0C4h, 46h, 86h,0C4h
		db	0C7h,0C8h, 88h,0C4h, 46h, 8Ah
		db	0C4h, 76h, 47h, 8Ch, 89h,0CBh
		db	0CCh,0C4h,0C7h,0C8h, 86h,0C4h
		db	 46h,0C8h, 87h,0C4h,0C8h, 8Bh
		db	0C4h, 56h,0C8h,0C7h, 8Eh, 89h
		db	0CBh,0CCh,0C4h, 46h,0C8h, 85h
		db	0C4h, 66h, 86h,0C4h, 85h,0C3h
		db	 86h,0C4h, 66h, 47h, 8Dh, 89h
		db	0CBh,0CCh,0C4h, 56h, 85h,0C4h
		db	0C7h,0C8h,0C7h, 87h,0C6h, 84h
		db	0CBh,0C5h, 86h,0C4h, 66h,0C8h
		db	 85h,0C3h, 88h, 89h,0CBh,0CCh
		db	0C4h,0C7h,0C8h,0C7h,0C8h, 84h
		db	0C4h, 46h,0C8h, 8Bh,0CBh,0CCh
		db	0C5h,0C7h, 85h,0C4h,0C7h,0C8h
		db	0C7h,0C8h, 86h,0C4h, 88h, 89h
		db	0CBh,0CCh,0C4h, 46h, 47h, 84h
		db	0C4h, 46h,0C8h, 8Bh,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 84h,0C4h, 46h
		db	0C8h, 87h,0C4h,0C7h,0C8h, 86h
		db	 89h,0CBh,0CCh,0C4h, 76h, 83h
		db	0C4h, 56h, 8Bh,0CBh,0CCh,0C5h
		db	 56h, 83h,0C4h, 56h, 87h,0C4h
		db	0C8h,0C7h,0C8h, 85h, 89h,0CBh
		db	0CCh,0C4h,0C7h,0C8h, 46h, 84h
		db	0C4h, 46h, 47h, 8Ah,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 84h,0C4h, 56h
		db	0C8h, 86h,0C4h, 56h, 85h, 89h
		db	0CBh,0CCh,0C4h, 46h,0C8h, 85h
		db	0C4h,0C8h, 66h,0C8h, 88h,0CBh
		db	0CCh,0C5h,0C7h, 85h,0C4h, 56h
		db	 87h,0C4h, 46h,0C8h,0C7h, 84h
		db	 89h,0CBh,0CCh,0C4h,0C8h,0C7h
		db	 47h, 84h,0C4h, 66h,0C8h, 46h
		db	0C8h, 86h,0CBh,0CCh,0C5h,0C8h
		db	 85h,0C4h, 46h,0C8h, 87h,0C4h
		db	 56h, 85h, 89h,0CBh,0CCh,0C4h
		db	 56h, 84h,0C3h, 08h, 07h, 86h
		db	0CBh,0CCh,0C5h,0C7h, 85h,0C4h
		db	0C7h,0C8h,0C7h, 87h,0C4h, 46h
		db	 47h, 84h, 89h,0CBh,0CCh,0C4h
		db	 46h,0C8h, 84h,0C4h, 46h, 47h
		db	 46h,0C8h,0C7h,0C8h, 86h,0CBh
		db	0CCh,0C5h,0C8h, 85h,0C4h, 56h
		db	 87h,0C4h, 56h,0C8h, 84h, 81h
		db	0C3h, 87h,0CBh,0CCh,0C4h,0C7h
		db	0C8h, 85h,0C4h, 56h,0C8h, 46h
		db	 89h,0CBh,0CCh,0C5h,0C7h,0C8h
		db	 84h,0C4h, 66h, 86h,0C4h,0C7h
		db	0C8h,0C7h, 85h, 81h,0C4h,0C7h
		db	 87h,0CBh,0C4h, 46h, 85h,0C4h
		db	 66h,0C8h, 8Ah,0CBh,0CCh,0C5h
		db	 46h, 84h,0C4h, 66h, 86h,0C4h
		db	0C7h,0C8h, 86h, 81h,0C4h,0C7h
		db	 88h,0C6h,0C7h, 86h,0C4h, 46h
		db	0C8h,0C7h, 8Bh,0CBh,0CCh,0C5h
		db	0C8h,0C7h, 84h,0C4h, 76h, 85h
		db	0C4h, 46h,0C8h, 85h, 81h,0C4h
		db	 46h,0C8h, 8Eh,0C4h,0C7h, 47h
		db	 8Ch,0CBh,0CCh,0C5h,0C7h,0C8h
		db	 84h,0C4h, 46h, 47h,0C7h, 85h
		db	0C4h, 56h,0C8h, 84h, 81h,0C4h
		db	 56h,0CAh, 41h, 05h, 01h,0C2h
		db	 50h, 81h,0C4h, 56h,0C8h, 8Ch
		db	0CBh,0C5h, 86h,0C4h, 76h,0C8h
		db	 84h,0C4h, 66h, 84h, 81h,0C4h
		db	0C7h,0C8h,0C7h, 8Eh,0C4h, 46h
		db	0C8h, 87h,0C3h, 86h,0C6h, 86h
		db	0C4h, 66h,0C8h,0C7h, 84h,0C4h
		db	 56h, 85h, 81h,0C4h, 46h,0C8h
		db	 86h,0C3h, 87h,0C4h,0C7h,0C8h
		db	 88h,0C4h,0C7h, 8Ch,0C4h, 76h
		db	0C8h, 84h,0C4h,0C7h, 47h, 85h
		db	 81h,0C4h,0C7h,0C8h, 87h,0C4h
		db	0C8h, 86h,0C4h, 56h,0C8h, 86h
		db	0C4h, 56h, 8Ah,0C4h, 46h,0C8h
		db	 76h, 82h, 56h, 86h, 81h,0C6h
		db	 89h,0C4h,0C7h,0C8h, 85h,0C4h
		db	 46h,0C8h, 87h,0C4h,0C8h,0C7h
		db	0C8h, 8Ah,0C4h, 56h,0C8h, 56h
		db	0C8h, 82h, 46h,0C8h, 86h, 89h
		db	0C3h,0C7h,0C8h, 56h,0C8h,0C7h
		db	 82h, 56h, 88h,0C4h,0C7h, 8Ch
		db	0C4h, 0Ah, 07h, 88h, 50h,0C2h
		db	 50h, 82h,0C4h, 06h, 07h, 82h
		db	 46h,0C8h, 88h,0C4h, 8Dh,0C4h
		db	 76h,0C8h, 66h,0CAh, 40h,0C2h
		db	 70h, 88h,0C3h, 76h,0C8h, 56h
		db	0C8h, 56h,0C8h, 87h,0C6h, 8Dh
		db	0C4h, 56h, 47h, 76h,0C8h, 88h
		db	 88h,0C4h, 76h, 47h, 46h,0C8h
		db	 66h,0C8h, 94h,0C4h, 76h,0C8h
		db	 56h,0C8h, 86h,0C3h, 82h, 46h
		db	0C8h, 09h, 07h,0C8h, 76h,0C8h
		db	 46h,0C8h,0CAh, 40h,0C2h, 07h
		db	 01h,0C2h, 40h, 86h,0C4h, 09h
		db	 07h, 86h,0C4h, 46h, 56h,0C8h
		db	 56h,0C8h, 09h, 07h,0C8h, 46h
		db	0C8h,0C7h, 95h,0C4h, 05h, 07h
		db	0C8h, 56h, 86h,0CEh, 46h, 0Ah
		db	 07h,0C8h, 66h,0C8h, 0Dh, 07h
		db	0CAh, 40h,0C2h, 50h, 41h, 50h
		db	 81h,0C4h,0C7h, 47h, 46h,0C8h
		db	 66h,0C8h, 86h,0CEh,0C7h,0FFh
		db	0FFh,0FFh,0FFh, 29h, 80h,0A8h
		db	 22h, 00h, 2Fh, 00h, 3Bh, 80h
		db	0A8h, 36h, 00h, 40h, 00h, 57h
		db	 40h, 85h, 52h, 00h, 5Ch, 00h
		db	 64h, 40h, 05h, 5Fh, 00h, 69h
		db	 00h, 94h, 80h, 81h, 8Dh, 00h
		db	 99h, 00h, 97h, 80h, 9Fh, 8Eh
		db	 00h, 9Dh, 00h, 9Ch, 80h, 98h
		db	 96h, 00h,0A3h, 00h,0A0h, 80h
		db	0B7h, 9Ch, 00h,0A4h, 00h,0A3h
		db	 40h, 03h,0A1h, 00h,0A7h, 00h
		db	0ADh, 40h, 1Fh,0A8h, 00h,0B3h
		db	 00h,0AEh, 40h, 83h,0AAh, 00h
		db	0B0h, 00h,0FFh,0FFh, 10h, 00h
		db	 09h,0C2h, 08h, 56h, 00h, 09h
		db	 00h,0FFh,0FFh,0FFh, 10h, 00h
		db	 15h, 40h, 04h,0DDh, 00h,0FFh
		db	 00h, 1Ch, 00h, 20h, 10h, 00h
		db	 22h,0C3h, 08h, 77h, 00h, 15h
		db	 00h,0FFh,0FFh,0FFh, 38h, 00h
		db	 37h,0C3h, 08h, 16h, 00h, 09h
		db	 00h,0FFh,0FFh,0FFh, 63h, 00h
		db	 35h, 80h, 06h,0C0h, 00h, 04h
		db	 00h,0FFh,0FFh,0FFh,0AEh, 00h
		db	 33h,0C4h, 08h,0F5h, 00h, 35h
		db	 00h,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 1Bh, 00h, 20h, 1Ch,0D2h, 00h
		db	0FFh, 27h,0D2h,0FFh,0FFh,0FFh
		db	0FFh, 1Bh, 00h, 10h, 2Ch,0D2h
		db	 00h,0FFh, 37h,0D2h,0FFh,0FFh
		db	0FFh,0FFh, 1Bh, 00h, 08h, 4Ch
		db	0D2h, 00h,0FFh, 57h,0D2h,0FFh
		db	0FFh,0FFh,0FFh, 1Bh, 00h, 04h
		db	0BCh,0D2h, 00h,0FFh,0C7h,0D2h
		db	0FFh,0FFh,0FFh,0FFh, 1Bh, 00h
		db	 02h,0DCh,0D2h, 00h,0FFh,0E7h
		db	0D2h,0FFh,0FFh,0FFh,0FFh, 1Bh
		db	 00h, 01h, 2Ch,0D3h, 00h,0FFh
		db	 37h,0D3h,0FFh,0FFh,0FFh,0FFh
		db	 1Ch, 00h, 80h, 45h,0D3h, 00h
		db	 00h,0FFh,0FFh, 1Ch, 00h, 40h
		db	 65h,0D3h, 00h, 00h,0FFh,0FFh
		db	 1Ch, 00h, 20h,0FBh,0D0h,0C0h
		db	 04h,0FFh,0FFh,0FFh,0FFh, 16h
		db	0AFh, 00h, 12h
		db	'Cavern of Escarcha'
		db	 0Fh, 00h, 03h, 06h, 06h, 0Fh
		db	 00h, 3Eh,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 0Fh, 00h
		db	 3Eh, 01h, 00h, 13h, 00h, 34h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 13h, 00h, 34h, 02h
		db	 00h, 17h, 00h, 3Eh,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 17h, 00h, 3Eh, 01h, 00h, 1Dh
		db	 00h, 24h,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 1Dh, 00h
		db	 24h, 01h, 00h, 2Ah, 00h, 1Eh
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 2Ah, 00h, 1Eh, 00h
		db	 00h, 2Ah, 00h, 3Fh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 2Ah, 00h, 3Fh, 03h, 00h, 33h
		db	 00h, 12h,0FFh, 73h, 00h, 01h
		db	 20h, 00h, 00h, 00h, 1Bh, 00h
		db	 20h, 00h, 00h, 48h, 00h, 16h
		db	0FFh, 73h, 00h, 00h, 20h, 00h
		db	 19h, 00h, 1Bh, 00h, 10h, 00h
		db	 00h, 4Bh, 00h, 1Eh,0FFh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 4Bh, 00h, 1Eh, 00h, 00h, 4Eh
		db	 00h, 16h,0FFh, 76h, 00h, 00h
		db	 20h, 00h, 00h, 00h, 1Bh, 00h
		db	 08h, 00h, 00h, 51h, 00h, 2Ah
		db	0FFh
		db	7 dup (0)
		db	 51h, 00h, 2Ah, 00h, 00h, 62h
		db	 00h, 19h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 62h, 00h
		db	 19h, 03h, 00h, 63h, 00h, 11h
		db	0FFh
		db	7 dup (0)
		db	 63h, 00h, 11h, 00h, 00h, 67h
		db	 00h, 26h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 67h, 00h
		db	 26h, 02h, 00h, 69h, 00h, 26h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 69h, 00h, 26h, 03h
		db	 00h, 6Bh, 00h, 26h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 6Bh, 00h, 26h, 02h, 00h, 74h
		db	 00h, 1Eh,0FFh, 73h, 00h, 00h
		db	 20h, 00h, 18h, 00h, 1Bh, 00h
		db	 04h, 00h, 00h, 74h, 00h, 2Ah
		db	0FFh, 01h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 74h, 00h, 2Ah, 01h
		db	 00h, 7Ah, 00h, 38h,0FFh, 73h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 1Bh, 00h, 02h, 00h, 00h, 83h
		db	 00h, 34h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 83h, 00h
		db	 34h, 04h, 00h, 8Ah, 00h, 0Eh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 8Ah, 00h, 0Eh, 03h
		db	 00h, 8Eh, 00h, 2Ah,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 8Eh, 00h, 2Ah, 01h, 00h, 95h
		db	 00h, 0Ah,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 95h, 00h
		db	 0Ah, 03h, 00h, 9Ah, 00h, 33h
		db	0FFh, 76h, 00h, 00h, 20h, 00h
		db	 00h, 00h, 1Bh, 00h, 01h, 00h
		db	 00h,0B7h, 00h, 35h,0FFh,0D0h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 1Ch, 00h, 80h, 00h, 00h,0B8h
		db	 00h, 2Ah,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B8h, 00h
		db	 2Ah, 00h, 00h,0B9h, 00h, 11h
		db	0FFh,0D0h, 00h, 00h, 20h, 00h
		db	 18h, 00h, 1Ch, 00h, 40h, 00h
		db	 00h, 00h,0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h,0FFh
		db	0FFh

_329MP41	endp

seg_a		ends



		end	start
