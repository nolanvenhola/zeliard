
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_343MP80                                 лл
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

_343MP80	proc	far

start:
		jle	$+1Eh			; Jump if < or =
		add	[bx+si],al
		mov	bh,0D8h
		add	[bx+di],al
		dec	ax
		xlat				; al=[al+[bx]] table
		db	 62h,0D7h, 70h,0D7h,0AAh,0D7h
		db	 30h,0D8h,0A4h,0D8h,0BCh,0D8h
		db	 08h,0FFh,0FFh,0FFh, 0Ah, 00h
		db	 00h, 48h,0D7h, 46h, 85h,0C5h
		db	0C7h,0CCh,0C9h, 46h, 84h,0C4h
		db	 46h,0CCh, 81h, 46h, 8Bh,0C6h
		db	 06h, 07h, 8Ah,0C4h, 56h,0CCh
		db	 84h,0C5h,0C7h, 46h, 85h,0C4h
		db	 46h,0CCh,0C7h, 81h,0C8h, 83h
		db	0C4h,0CAh,0C7h, 94h,0C4h,0CCh
		db	0CAh, 8Ah,0C4h, 46h,0CBh,0C8h
		db	 84h,0C4h,0C7h, 46h, 85h,0C4h
		db	0C7h,0C9h,0C7h,0CCh, 85h,0C5h
		db	 46h, 94h,0C4h, 46h, 8Ah,0C5h
		db	 56h, 85h,0C4h,0CCh, 46h, 85h
		db	0C4h,0CCh,0C7h, 81h,0C7h, 85h
		db	0C4h,0C7h, 95h,0C4h,0CAh,0CCh
		db	 8Ah,0C4h, 56h, 85h,0C4h,0C7h
		db	0CAh,0CCh, 85h,0C4h,0C7h,0C9h
		db	 46h, 85h,0C4h,0C7h, 85h,0C3h
		db	 06h, 07h, 88h,0C4h, 46h, 8Ah
		db	0C5h, 56h, 85h,0C4h,0CCh, 46h
		db	 85h,0C4h,0CCh,0C7h, 87h,0C6h
		db	 86h,0C5h, 49h, 46h, 4Bh,0C9h
		db	0C7h,0C8h, 86h,0C4h, 46h, 8Ah
		db	0C4h,0C9h,0C7h,0C8h, 85h,0C4h
		db	0C7h,0C7h,0C9h, 85h,0C5h,0CAh
		db	0CBh, 8Eh,0C4h, 07h, 07h,0C8h
		db	 86h,0C4h, 46h, 8Ah,0C4h,0C7h
		db	0CCh,0C8h, 85h,0C4h,0CAh, 46h
		db	 85h,0C4h,0C7h, 50h, 51h,0C1h
		db	 41h, 40h, 51h, 81h,0C5h,0CCh
		db	 76h,0CCh,0C9h,0C7h, 86h,0C4h
		db	0CCh,0C7h,0C8h, 89h,0C4h, 56h
		db	 85h,0C4h,0C7h, 46h, 85h,0C4h
		db	0C7h, 8Fh,0C5h,0CAh, 07h, 07h
		db	 86h,0C4h,0C7h,0C8h, 8Ah,0C4h
		db	0C7h,0C9h,0CCh, 85h,0C4h,0C7h
		db	 46h, 85h,0C6h, 86h,0C3h, 46h
		db	 81h, 46h, 82h, 56h,0C9h, 06h
		db	 07h,0C8h, 86h,0C4h, 46h, 40h
		db	 51h, 40h,0C2h,0C1h, 81h,0C5h
		db	 56h, 85h,0C4h,0C7h, 46h, 8Ch
		db	0C5h, 09h, 07h,0CCh, 66h,0CAh
		db	0CCh,0C7h, 87h,0C4h,0C7h,0C8h
		db	 8Ah,0C4h, 46h,0CCh, 85h,0C4h
		db	0C7h, 56h, 8Bh,0C4h, 66h, 6Bh
		db	0CAh, 46h,0CCh, 66h,0CBh,0C7h
		db	 87h,0C4h,0CCh,0C7h, 85h,0C3h
		db	 81h, 06h, 07h, 85h,0C5h,0C7h
		db	 5Bh,0C8h, 8Ah,0C6h, 56h,0C9h
		db	 46h,0CBh,0C8h,0CBh, 66h, 8Ch
		db	0C4h,0CAh,0CBh, 85h,0C5h, 07h
		db	 07h, 85h,0C5h,0CAh, 46h, 81h
		db	 46h, 87h, 07h, 07h, 94h,0C4h
		db	 46h, 85h,0C5h, 4Bh, 46h,0CCh
		db	 46h, 47h, 84h,0C4h,0C9h, 05h
		db	 07h, 81h,0C7h,0CCh, 81h, 06h
		db	 07h,0CCh,0C7h, 41h, 50h, 41h
		db	 50h,0C2h,0C1h,0C2h, 50h, 41h
		db	 40h, 81h,0C4h,0C7h, 86h,0C4h
		db	 56h,0C8h,0C7h,0CCh,0C9h,0C8h
		db	 85h,0C4h,0C7h, 05h, 07h,0CCh
		db	 0Bh, 07h, 95h,0C4h, 46h, 85h
		db	0C4h,0CAh,0C9h, 05h, 07h, 85h
		db	0C4h,0C7h,0CCh, 46h,0C9h, 56h
		db	0CCh,0CAh, 56h,0C9h, 56h,0CCh
		db	0C9h,0C7h, 85h,0C3h, 46h, 81h
		db	 46h, 88h,0C3h, 5Bh,0C7h, 85h
		db	0C4h,0CCh, 06h, 07h, 85h,0C4h
		db	0C7h,0C9h, 09h, 07h, 81h, 06h
		db	 07h, 85h,0C5h, 66h,0CAh, 56h
		db	 85h,0C4h, 66h, 85h,0C4h, 56h
		db	0C9h,0CCh, 49h,0CBh, 85h,0C4h
		db	0CAh, 56h,0C8h, 81h,0C4h, 66h
		db	 84h,0C4h, 66h, 85h,0C5h,0C9h
		db	0CAh, 05h, 07h,0C8h, 84h,0C5h
		db	 66h, 85h,0C5h,0C7h,0C9h, 05h
		db	 07h, 85h,0C5h,0C7h,0C7h, 84h
		db	0C4h, 66h, 84h,0C5h, 76h, 84h
		db	0C4h,0C7h,0CCh, 46h,0CAh,0CCh
		db	0C9h, 46h, 84h,0C4h, 46h,0CBh
		db	0C7h, 85h,0C4h,0C7h,0CCh, 05h
		db	 07h, 85h,0C4h,0C7h,0C7h, 84h
		db	0C5h, 46h,0C9h,0C7h, 84h,0C4h
		db	 76h, 84h,0C5h, 08h, 07h, 84h
		db	0C5h, 46h, 81h,0C8h, 85h,0C4h
		db	0C7h,0CAh,0CBh, 66h,0C8h, 85h
		db	0C4h,0C7h, 85h,0C5h,0C7h, 87h
		db	0C5h, 76h, 84h,0C4h, 66h,0CBh
		db	0CAh,0C7h,0CBh,0C8h, 84h,0C5h
		db	 56h,0C8h, 85h,0C5h, 07h, 07h
		db	 85h,0C4h,0C7h, 85h,0C4h,0C7h
		db	 87h,0C5h, 49h,0C7h,0C9h,0C7h
		db	 84h,0C4h,0C7h,0CCh, 46h, 81h
		db	 56h, 85h,0C4h, 66h, 85h,0C4h
		db	 07h, 07h, 85h,0C6h, 81h, 85h
		db	0C4h,0CAh, 4Bh, 85h,0C4h, 56h
		db	0CCh,0C7h, 84h,0C6h, 8Dh,0C4h
		db	0C9h, 4Bh,0C7h, 85h,0C4h,0CCh
		db	0C9h, 46h,0CCh,0C7h,0C9h, 88h
		db	 40h,0C2h,0C1h, 81h,0C4h,0C9h
		db	0C7h,0CCh,0C7h, 84h,0C5h,0CBh
		db	 56h, 93h,0C4h, 56h,0CBh,0C8h
		db	 84h,0C4h, 06h, 07h, 40h, 61h
		db	 40h, 85h,0C4h, 56h, 85h,0C4h
		db	 66h, 93h,0C4h, 46h, 87h,0C5h
		db	0CAh,0CCh, 56h, 81h,0CBh,0C8h
		db	 87h, 85h,0C5h, 46h,0C9h,0CCh
		db	 84h,0C4h, 66h,0C8h, 92h,0C4h
		db	0CAh,0CBh,0CCh, 81h,0C8h, 84h
		db	0C4h, 46h,0CBh,0C7h,0CBh,0C7h
		db	0C8h, 85h,0C3h, 82h, 85h,0C4h
		db	 66h, 84h,0C4h,0CAh, 56h, 85h
		db	0C3h, 81h,0C7h,0C8h, 8Ah,0C5h
		db	 66h, 85h,0C6h, 81h, 46h, 81h
		db	0C7h,0CAh, 86h,0C4h, 46h,0C7h
		db	 84h,0C4h,0C7h,0CCh,0C7h, 85h
		db	0C5h, 56h,0CBh, 85h,0C5h,0C9h
		db	0CCh,0C7h, 8Ah,0C4h,0CCh,0C9h
		db	 46h, 92h,0C5h,0CAh,0CCh,0C7h
		db	 84h,0C5h, 66h, 84h,0C5h, 4Bh
		db	 46h, 85h,0C5h, 66h, 89h,0C5h
		db	0CAh, 56h, 92h,0C5h, 46h,0C7h
		db	 84h,0C4h, 56h, 85h,0C4h,0C9h
		db	0C7h,0CBh, 86h,0C4h, 66h, 89h
		db	0C4h
data_1		db	56h
		db	0CCh, 92h,0C4h,0CCh,0C7h,0C8h
		db	 84h,0C6h, 81h, 46h, 85h,0C6h
		db	 46h,0C8h, 86h,0C4h,0C7h,0CAh
		db	0C9h,0CCh, 89h,0C4h,0C7h, 81h
		db	0CBh, 93h,0C4h,0C7h,0CCh, 98h
		db	0C4h, 66h, 89h,0C6h, 96h,0C4h
		db	0C9h,0C7h
		db	'A@a@q`A@'
		db	 81h,0C5h,0C9h, 56h,0A0h,0C4h
		db	 46h, 98h,0C4h, 66h,0A0h,0C5h
		db	 46h,0CAh, 88h,0C3h, 81h, 46h
		db	 8Ah,0CFh,0C7h,0CAh,0C9h, 46h
		db	0A0h,0C4h, 46h, 46h, 87h,0C5h
		db	 56h, 89h,0CFh, 66h,0CAh, 8Ah
		db	0C3h,0CCh,0C8h, 94h,0C4h, 46h
		db	0CCh,0C7h, 87h,0C4h,0C7h,0C9h
		db	 46h, 87h,0CFh, 56h, 8Dh,0C5h
		db	 56h,0C8h, 92h,0C4h,0CAh,0CCh
		db	 46h, 87h,0C4h, 46h,0CBh, 87h
		db	0CFh,0C7h,0C9h,0C1h,0C2h,0C1h
		db	0C2h, 60h,0C2h, 86h,0C4h,0C7h
		db	0CCh,0C9h,0C7h, 92h,0C4h, 46h
		db	0CCh,0C7h, 87h,0C5h, 66h, 85h
		db	0CFh, 56h, 8Fh,0C4h, 66h, 92h
		db	0C5h, 46h,0CAh,0CCh, 87h,0C4h
		db	0C7h,0CBh,0C7h,0CCh, 85h,0C5h
		db	0CAh, 46h, 85h,0C3h, 81h,0C7h
		db	 87h,0C5h,0C7h,0CAh,0C7h,0C8h
		db	 92h,0C5h, 46h,0C9h,0C7h, 87h
		db	0C4h, 76h, 84h,0C4h,0C7h,0CAh
		db	0C7h, 85h,0C4h, 46h, 87h,0C5h
		db	0C7h,0CCh,0C7h,0C8h, 92h,0C4h
		db	 46h, 46h, 87h,0C4h,0C7h, 4Bh
		db	0C7h,0C8h, 84h,0C4h,0C9h, 4Bh
		db	0C8h, 84h,0C5h,0C9h, 46h, 86h
		db	0C5h,0C7h,0CAh,0C9h,0C7h, 87h
		db	0C3h, 81h, 46h, 87h,0C4h, 46h
		db	 46h,0C8h, 86h,0C4h, 66h, 85h
		db	0C4h, 66h, 84h,0C4h, 56h, 86h
		db	0C4h, 66h, 87h,0C4h,0CAh,0CCh
		db	0C7h, 82h, 57h, 81h,0CAh, 56h
		db	 56h, 86h,0C5h, 66h, 85h,0C4h
		db	 46h,0CCh, 85h,0C4h,0CCh,0C9h
		db	0C7h,0C8h, 85h,0C4h,0C7h,0CCh
		db	 46h, 87h,0C4h,0CAh, 4Bh, 46h
		db	0C9h, 5Bh, 66h, 56h, 86h,0C5h
		db	0C9h,0C7h,0CCh,0CBh, 85h,0C4h
		db	 66h, 84h,0C4h, 46h,0CCh,0C7h
		db	 85h,0C4h, 66h, 87h,0C4h,0C9h
		db	0CCh, 0Ah, 07h,0C7h, 88h,0C4h
		db	 66h, 85h,0C4h, 56h, 85h,0C4h
		db	 66h, 85h,0C5h,0CAh,0C9h,0C7h
		db	 88h,0C4h, 46h,0C9h,0CAh, 56h
		db	0CAh,0C9h, 66h,0C8h, 88h,0C4h
		db	 66h, 85h,0C5h,0CCh,0C9h,0C7h
		db	 85h,0C4h,0CAh, 66h, 84h,0C4h
		db	 56h, 88h,0C4h, 0Ch, 07h, 46h
		db	 87h,0C5h, 46h,0CCh,0C7h, 85h
		db	0C4h, 56h, 85h,0C4h, 76h,0CCh
		db	 07h, 07h, 87h,0C5h, 0Ch, 07h
		db	 46h, 87h,0C4h, 56h,0CBh,0C8h
		db	 84h,0C4h, 46h,0CBh,0CCh, 84h
		db	0C5h,0C7h,0C9h,0CAh, 56h,0CBh
		db	0C9h, 06h, 07h, 86h,0C5h, 08h
		db	 07h,0C9h,0CAh,0CCh,0CAh,0C7h
		db	 88h,0C4h, 66h,0C8h, 84h,0C5h
		db	0C7h,0CAh, 46h, 84h,0C4h, 0Ah
		db	 07h,0CAh, 46h,0C8h, 86h,0C4h
		db	 76h,0CCh,0C7h, 82h, 46h,0C9h
		db	0C7h,0C7h, 88h,0C4h, 56h,0CAh
		db	 85h,0C5h, 46h,0C9h,0C7h, 84h
		db	0C4h, 0Dh, 07h, 87h,0C4h,0CCh
		db	 76h, 84h,0C4h, 46h,0C7h, 88h
		db	0C4h, 66h, 85h,0C4h, 56h, 85h
		db	0C4h,0C7h,0CBh,0CCh,0C9h, 56h
		db	0C8h, 46h,0C9h,0CCh,0C7h,0C8h
		db	 87h,0C4h, 76h, 85h,0C4h, 46h
		db	0C7h, 88h,0C4h,0C9h,0C7h,0CCh
		db	0C7h, 85h,0C4h, 66h, 84h,0C4h
		db	 56h,0CCh,0C7h, 84h,0C4h, 56h
		db	0C8h, 87h,0C4h,0CAh,0C9h,0CCh
		db	 46h, 85h,0C4h, 46h,0C7h,0C8h
		db	 87h,0C5h, 46h,0C9h,0CCh, 85h
		db	0C4h, 56h, 85h,0C5h,0C7h,0C9h
		db	 46h, 85h,0C4h,0C7h,0CBh,0C9h
		db	0C7h, 87h,0C4h, 56h, 87h,0C4h
		db	 46h,0C7h,0CAh,0C7h, 86h,0C5h
		db	 66h,0C8h, 84h,0C4h,0C9h, 46h
		db	 85h,0C5h,0C7h,0CAh, 46h, 85h
		db	0C4h, 5Bh,0C7h, 87h,0C4h, 56h
		db	 87h,0C5h,0C9h,0C7h, 46h, 87h
		db	0C4h,0C7h,0CAh,0C7h,0CCh,0C8h
		db	 84h,0C4h,0CCh, 56h, 84h,0C4h
		db	0CAh, 46h,0C8h, 85h,0C5h, 66h
		db	0C8h, 86h,0C4h, 46h,0C9h,0C7h
		db	 86h,0C4h, 46h,0C7h,0CCh, 87h
		db	0C4h, 66h, 85h,0C4h,0CBh,0CAh
		db	 46h, 84h,0C4h,0C9h, 56h, 85h
		db	0C5h,0C7h,0C9h,0C7h,0CCh,0C7h
		db	 86h,0C4h, 66h, 86h,0C4h,0C7h
		db	0CAh, 46h,0C8h, 86h,0C4h, 66h
		db	 85h,0C5h, 56h, 85h,0C4h,0CBh
		db	 46h,0C8h, 85h,0C4h,0C9h, 66h
		db	0C9h, 85h,0C4h, 56h, 87h,0C4h
		db	 46h,0CCh,0C7h, 87h,0C5h, 46h
		db	0CAh,0C8h, 85h,0C4h, 56h,0C8h
		db	 84h,0C4h,0C7h,0CCh,0C7h, 86h
		db	0C4h, 76h,0C8h, 85h,0C5h, 66h
		db	 86h,0C5h, 46h, 46h, 87h,0C4h
		db	 56h,0C8h, 85h,0C4h,0C7h,0CCh
		db	0C7h,0C8h, 84h,0C4h, 56h, 86h
		db	0C5h, 46h,0CBh,0C7h,0C8h, 86h
		db	0C4h, 46h,0CCh,0C7h, 86h,0C5h
		db	 46h, 56h, 86h,0C5h, 66h, 85h
		db	0C4h, 46h,0C9h,0C7h, 84h,0C4h
		db	 56h,0C8h, 85h,0C4h, 66h, 87h
		db	0C4h, 66h, 86h,0C4h, 46h,0CCh
		db	 56h, 85h,0C5h,0C9h, 56h, 85h
		db	0C4h,0C7h,0C9h, 46h, 84h,0C4h
		db	 46h,0CCh, 86h,0C4h, 66h, 87h
		db	0C4h, 76h, 85h,0C4h, 46h, 56h
		db	 86h,0C4h,0C7h,0C9h, 46h, 85h
		db	0C4h, 46h,0CBh,0C7h, 84h,0C5h
		db	0CAh,0C9h, 46h,0C8h, 84h,0C4h
		db	0C9h,0CCh,0CBh,0C8h, 87h,0C4h
		db	0C7h,0C9h,0CCh,0CBh,0CCh, 85h
		db	0C5h, 46h,0CAh,0C7h, 81h,0C8h
		db	 85h,0C4h, 66h, 85h,0C5h, 56h
		db	0CCh,0C8h, 83h,0C4h, 66h, 85h
		db	0C4h, 56h,0C8h, 87h,0C4h, 76h
		db	 85h,0C4h,0C9h,0C7h,0C7h,0CAh
		db	0CCh, 86h,0C4h, 46h,0CAh,0CBh
		db	 85h,0C5h, 56h,0C8h, 84h,0C4h
		db	 56h,0C8h, 85h,0C4h, 66h, 87h
		db	0C4h, 46h, 4Bh, 86h,0C4h, 46h
		db	 46h,0CCh,0CBh, 85h,0C5h, 66h
		db	 85h,0C4h, 56h, 85h,0C5h,0C7h
		db	0CAh,0C7h, 86h,0C4h, 56h,0CAh
		db	0CCh, 86h,0C4h, 76h, 85h,0C5h
		db	 46h,0C7h,0CCh,0C8h, 86h,0C4h
		db	 56h,0CCh, 85h,0C4h, 46h,0CCh
		db	0C8h, 84h,0C4h, 46h,0C9h,0C7h
		db	 85h,0C5h, 76h, 86h,0C4h, 56h
		db	0C9h, 86h,0C4h, 46h, 66h,0C8h
		db	 84h,0C4h, 66h, 85h,0C4h, 56h
		db	 85h,0C4h, 56h,0C8h, 85h,0C4h
		db	 05h, 07h, 85h,0C5h, 76h, 85h
		db	0C4h, 46h,0CBh,0CCh,0C7h,0C8h
		db	 85h,0C5h, 56h,0C8h, 85h,0C4h
		db	0CAh,0C9h,0C7h, 85h,0C4h, 56h
		db	 86h,0C4h,0C7h,0C9h, 46h,0CCh
		db	0C7h, 85h,0C5h, 76h, 85h,0C5h
		db	 46h,0C9h,0CBh, 87h,0C4h, 66h
		db	 85h,0C4h, 46h,0CBh,0C8h, 84h
		db	0C5h, 56h, 86h,0C6h,0C7h, 81h
		db	0C5h,0CBh,0C7h, 86h,0C4h, 46h
		db	 4Bh,0C7h, 85h,0C6h, 46h, 46h
		db	 87h,0C4h, 46h,0CCh,0C7h, 85h
		db	0C4h, 56h,0C8h, 84h,0C6h, 81h
		db	 46h, 89h,0C4h, 56h, 85h,0C4h
		db	 46h,0C9h,0C7h,0CCh,0C7h, 87h
		db	 89h,0C4h,0C9h,0CAh,0CBh,0CCh
		db	0C8h, 84h,0C4h,0C9h,0CCh,0C7h
		db	 92h,0C4h, 46h,0CAh, 85h,0C4h
		db	 05h, 07h, 87h, 89h,0C4h, 66h
		db	0C8h, 84h,0C4h, 56h, 92h,0C4h
		db	0C7h, 87h,0C4h, 05h, 07h, 87h
		db	 89h,0C4h, 66h, 85h,0C4h,0C7h
		db	0C9h,0C7h, 92h,0C4h,0C7h, 87h
		db	0C4h,0C7h,0CAh,0C9h, 66h, 83h
		db	 56h,0C7h, 88h,0C5h,0C7h,0CAh
		db	0C9h,0C7h, 85h,0C5h, 46h, 93h
		db	0C4h,0C9h, 46h, 85h,0C4h,0C9h
		db	0CCh,0C7h,0CCh, 66h,0CCh, 66h
		db	0C7h, 88h,0C5h, 46h,0CAh,0C7h
		db	 85h,0C4h, 56h, 92h,0C4h,0C7h
		db	0C9h,0CBh, 85h,0C4h, 07h, 07h
		db	0CCh,0C9h, 56h,0C7h, 88h,0C5h
		db	0C9h,0C7h,0CBh,0C7h, 85h,0C4h
		db	0C9h,0CAh,0C7h, 92h,0C5h, 46h
		db	 86h,0C4h, 0Ch, 07h, 46h, 87h
		db	0C4h, 66h, 85h,0C4h, 56h, 92h
		db	0C5h, 56h, 85h,0C5h, 0Ah, 07h
		db	0CCh,0C7h,0C9h,0C7h, 87h,0C4h
		db	 66h, 85h,0C4h, 56h, 92h,0C4h
		db	 46h, 86h,0C4h, 76h,0C9h,0C7h
		db	 4Bh,0C7h,0CCh, 46h,0C7h, 88h
		db	0C4h,0C7h,0C9h,0CAh,0CBh, 85h
		db	0C5h, 46h,0CBh,0C8h, 91h,0C4h
		db	0C9h,0CAh,0C7h, 85h,0C4h,0CCh
		db	0C7h,0C9h,0CCh, 46h,0CAh, 05h
		db	 07h, 81h,0C7h, 87h,0C4h, 56h
		db	0CCh, 85h,0C5h,0C7h,0C9h,0C7h
		db	0CCh, 88h,0C3h, 88h,0C4h, 4Bh
		db	0C7h, 85h,0C4h, 76h, 84h,0E9h
		db	0E5h, 46h,0C7h, 88h,0C4h, 56h
		db	0C8h, 85h,0D0h, 66h, 81h,0C8h
		db	 86h,0C4h,0CAh, 46h, 85h,0C4h
		db	 56h, 85h,0C5h, 66h, 85h,0E5h
		db	0CAh, 46h,0C9h,0C7h, 87h,0C5h
		db	0C7h,0CAh,0CCh, 87h,0D0h,0CAh
		db	 4Bh, 46h,0C8h, 85h,0C5h, 56h
		db	 85h,0C4h,0CAh, 46h, 85h,0C5h
		db	 46h,0CCh,0C7h, 85h,0E9h,0E5h
		db	0CAh,0CCh, 46h, 87h,0C4h, 66h
		db	 87h,0D0h, 66h, 81h,0C8h, 84h
		db	0C5h,0C7h,0CBh,0CCh,0C8h, 84h
		db	0C4h, 46h, 86h,0C4h, 56h, 86h
		db	0E5h,0C9h, 46h,0CCh,0C7h, 87h
		db	0C4h,0C7h,0CCh,0CBh,0C7h, 88h
		db	0D0h,0C7h,0CAh,0C9h,0C7h, 85h
		db	0C4h, 66h, 84h,0C5h,0C7h,0C9h
		db	0C8h, 85h,0C4h,0C7h, 88h,0E9h
		db	0E5h, 46h, 46h, 87h,0C4h, 56h
		db	0C8h, 89h,0D0h, 56h, 85h,0C4h
		db	0C7h,0C9h,0C8h, 85h,0C4h, 56h
		db	 85h,0C6h, 89h,0E5h, 56h, 46h
		db	 87h,0C4h,0C9h, 46h, 8Bh,0C5h
		db	 46h,0C8h, 84h,0C4h, 56h, 85h
		db	0C4h,0CCh, 46h, 03h, 12h, 01h
		db	 13h, 89h,0E9h,0E5h, 46h,0CAh
		db	0CCh, 87h,0C4h, 46h, 8Ch,0C4h
		db	0CCh,0C9h, 85h,0C4h, 66h, 84h
		db	0C4h, 56h, 03h, 12h, 01h, 13h
		db	 89h,0E5h, 56h,0C9h,0C7h, 87h
		db	0C6h, 8Eh,0C4h,0C7h,0CCh, 85h
		db	0C5h, 48h,0CCh, 85h,0C4h, 46h
		db	0C8h, 03h, 12h, 01h, 13h, 89h
		db	0E9h,0E5h,0C9h,0C7h,0CCh, 46h
		db	 95h,0C5h, 46h, 85h,0C4h, 66h
		db	 84h,0C5h,0C7h,0C9h,0C8h, 03h
		db	 12h, 01h, 13h, 89h,0E5h,0CAh
		db	 46h, 46h,0CAh,0C1h, 51h, 50h
		db	0C2h,0C1h, 51h, 50h, 41h, 50h
		db	 81h,0C4h,0C9h,0C7h, 85h,0C4h
		db	0CAh,0C9h,0CCh, 85h,0C5h, 46h
		db	 81h, 03h, 12h, 01h, 13h, 89h
		db	0E9h,0E5h, 46h, 56h, 95h,0C4h
		db	 46h, 85h,0C4h, 56h, 85h,0C6h
		db	 83h, 03h, 12h, 01h, 13h, 01h
		db	 11h, 87h,0E5h,0C9h, 46h,0C7h
		db	0CCh, 8Bh,0C3h, 8Ah,0C6h,0C7h
		db	 81h, 04h, 11h,0C4h, 66h, 88h
		db	 02h, 12h, 04h, 13h, 87h,0E9h
		db	0E5h,0CAh,0CCh, 46h, 8Bh,0C4h
		db	0C8h, 46h, 87h, 07h, 13h,0C5h
		db	 66h, 86h, 04h, 12h, 04h, 13h
		db	 87h,0E5h, 56h,0C9h,0C7h, 8Bh
		db	0C4h,0C9h,0C7h,0C8h, 86h, 08h
		db	 13h,0C5h,0C7h,0CCh,0C7h,0CBh
		db	0C8h, 83h, 06h, 12h, 04h, 13h
		db	 87h,0E9h,0E5h, 46h, 46h, 8Bh
		db	0C4h, 4Bh, 88h, 07h, 13h,0C4h
		db	 46h,0CCh,0CAh,0C9h,0C7h, 82h
		db	 06h, 12h, 04h, 13h, 87h,0E5h
		db	 56h,0C7h, 8Ch,0C5h, 46h,0CAh
		db	 87h,0C3h,0C7h, 81h, 04h, 12h
		db	0C6h, 82h,0C4h, 46h,0C9h,0C7h
		db	0C8h, 0Bh, 12h, 87h,0E9h,0E5h
		db	 4Bh,0CCh, 8Ch,0C5h, 56h, 87h
		db	0C4h, 56h, 87h,0C4h, 76h, 83h
		db	0C3h, 81h, 46h, 8Ch,0E5h, 49h
		db	0CCh,0C7h, 8Ch,0C4h, 56h,0CBh
		db	 86h,0C4h, 56h, 87h,0C4h,0CBh
		db	 56h,0C8h, 83h,0C4h,0C7h,0C9h
		db	0CAh,0C7h, 8Bh,0E9h,0E5h, 46h
		db	 8Dh,0C4h,0CCh, 46h,0C8h, 86h
		db	0C4h,0C7h,0C9h,0C7h, 87h,0C5h
		db	 4Bh,0C7h,0C8h, 84h,0C5h,0C7h
		db	 4Bh,0C7h, 8Bh,0E5h,0C9h,0C7h
		db	0CCh,0C7h, 8Ch,0C4h,0CAh,0CCh
		db	0C7h, 87h,0C5h, 66h, 86h,0C4h
		db	 46h,0C8h, 81h,0C8h, 83h,0C4h
		db	 76h,0C8h, 89h,0E9h,0E5h, 46h
		db	0C7h, 8Ch,0C4h, 66h, 86h,0C5h
		db	 56h, 87h,0C6h, 88h,0C4h,0C7h
		db	0CCh,0C7h,0CCh,0C7h, 8Ah,0E5h
		db	 56h,0C7h, 8Ch,0C5h, 46h,0CCh
		db	0C7h, 86h,0C4h,0C7h,0CAh,0C9h
		db	 46h, 8Eh,0C4h, 56h,0CAh,0CBh
		db	0C8h, 89h,0E9h,0E5h,0CCh,0C7h
		db	0C7h, 8Ch,0C4h, 56h,0C8h, 86h
		db	0C4h, 76h, 60h, 05h, 02h, 40h
		db	0C2h, 81h,0C4h,0C7h,0C9h, 56h
		db	0C8h, 89h,0E5h, 56h,0CAh, 8Ch
		db	0C4h,0CCh, 56h, 86h,0C4h, 46h
		db	 4Bh,0C7h, 8Eh,0C5h, 66h,0C8h
		db	 8Ah,0E9h,0E5h, 46h,0C7h, 8Ch
		db	0C5h, 56h,0CCh, 86h,0C4h, 66h
		db	 88h, 46h, 85h,0C5h, 46h,0C8h
		db	0C7h, 81h,0C8h, 8Ah,0C4h, 46h
		db	0C7h, 8Ch,0C4h, 46h,0CBh,0C7h
		db	0CBh, 85h,0C4h, 46h,0CCh,0CAh
		db	 46h, 84h, 66h, 85h,0C5h,0C9h
		db	 66h, 8Bh,0C4h,0C7h,0CAh,0C7h
		db	 8Ch,0C4h, 66h, 86h,0C5h, 0Dh
		db	 07h, 85h,0C4h,0C7h,0CCh, 56h
		db	 8Bh,0C4h,0C7h,0C9h,0C7h, 8Ch
		db	0C4h, 56h,0C8h, 86h,0C4h, 56h
		db	0CCh,0C7h,0CCh, 66h,0CCh, 46h
		db	 86h,0C4h,0C9h,0C7h, 5Bh,0C7h
		db	 50h, 41h, 60h, 81h,0C6h, 82h
		db	 8Dh,0C4h,0C9h, 46h,0C8h, 81h
		db	0DDh, 84h,0C4h, 06h, 07h,0C9h
		db	0CAh,0CBh, 66h, 85h,0C4h, 56h
		db	0CAh,0CCh, 46h, 8Ch, 60h, 51h
		db	 50h,0C2h, 82h,0C4h,0CAh,0C9h
		db	 46h, 81h,0DEh, 84h,0C4h, 66h
		db	0C9h, 05h, 07h,0C9h,0CCh,0C7h
		db	 85h,0C4h,0C9h,0C7h,0CCh, 46h
		db	0CBh,0CCh, 56h, 41h, 50h, 61h
		db	 8Dh,0C4h, 4Bh,0CBh,0C7h,0C8h
		db	0DFh, 84h,0C5h, 56h,0CCh, 46h
		db	 82h, 05h, 07h, 85h,0C4h, 09h
		db	 07h, 89h, 82h,0C3h, 8Ah,0C5h
		db	0C9h, 56h, 81h,0E0h, 84h,0C5h
		db	 56h,0C9h,0CCh, 85h,0C4h, 56h
		db	 85h,0C4h, 0Ah, 07h, 81h,0C7h
		db	0C8h, 85h, 82h,0C4h,0C7h, 89h
		db	0C5h, 46h,0CAh,0CCh, 81h,0E1h
		db	 84h,0C4h, 76h, 85h,0C4h,0CAh
		db	0CCh,0C7h, 85h,0C4h, 76h,0CCh
		db	0C7h,0CBh, 46h,0CCh, 66h,0C8h
		db	 83h, 82h,0C4h, 56h, 87h,0C4h
		db	 66h, 86h,0C4h, 66h, 86h,0C4h
		db	 56h, 85h,0C4h, 76h,0C8h, 83h
		db	0C4h, 05h, 07h,0C8h, 82h, 82h
		db	0C4h,0C7h,0C9h,0CCh, 81h,0C7h
		db	 85h,0C4h, 66h, 86h,0C4h, 4Bh
		db	 46h, 86h,0C4h, 46h,0CCh, 85h
		db	0C4h,0C7h,0C9h, 46h, 85h,0C4h
		db	0C9h, 46h,0CCh,0C9h, 46h, 82h
		db	 82h,0C4h, 76h, 85h,0C4h,0CCh
		db	 46h,0CCh, 86h,0C4h,0CAh,0C9h
		db	0CBh,0C7h, 86h,0C4h, 56h, 85h
		db	0C5h, 66h,0C8h, 84h,0C5h,0C7h
		db	0CCh,0CAh,0C7h,0C9h,0CCh,0C7h
		db	 82h, 82h,0C4h,0C7h,0CCh, 46h
		db	0CBh, 85h,0C5h, 66h, 86h,0C4h
		db	 76h, 85h,0C4h, 56h, 85h,0C4h
		db	0C7h,0C9h,0C7h, 81h,0C8h, 84h
		db	0C5h, 05h, 07h, 81h,0C8h, 81h
		db	 82h,0C5h, 46h,0C9h, 46h, 85h
		db	0C4h,0C9h,0C7h,0CBh,0C8h, 86h
		db	0C5h, 46h,0C9h,0CBh,0C7h, 85h
		db	0C4h,0C7h,0CAh,0C7h, 85h,0C4h
		db	 66h, 85h,0C4h,0C9h, 05h, 07h
		db	 82h, 82h,0C5h, 76h, 85h,0C5h
		db	 56h, 87h,0C4h, 76h, 85h,0C4h
		db	 46h, 86h,0C4h, 66h, 85h,0C4h
		db	 76h, 81h,0C8h, 82h, 82h,0C4h
		db	 76h, 85h,0C5h, 56h, 87h,0C4h
		db	 66h, 86h,0C4h,0C7h,0CCh,0CAh
		db	 85h,0C4h,0C7h,0CAh,0CBh,0C7h
		db	0C8h, 84h,0C4h, 56h,0CAh, 46h
		db	 83h, 82h,0C4h, 76h, 85h,0C4h
		db	 46h, 88h,0C4h, 66h, 86h,0C4h
		db	 56h, 85h,0C5h, 56h,0CCh, 85h
		db	0C5h, 05h, 07h, 83h, 82h,0C4h
		db	0C7h,0CAh,0CCh, 46h, 85h,0C4h
		db	 8Ah,0C4h,0CCh,0CAh,0C7h, 87h
		db	0C4h,0C7h,0C9h,0CCh, 85h,0C4h
		db	 66h, 85h,0C4h, 56h,0CBh,0CCh
		db	 84h, 82h,0C4h, 56h, 4Bh, 85h
		db	0C6h, 86h,0C3h, 83h,0C4h,0C7h
		db	0CCh, 88h,0C6h, 46h, 86h,0C4h
		db	0C7h,0C9h, 56h, 84h,0C6h,0C8h
		db	 81h,0C7h,0C8h, 85h, 82h,0C4h
		db	 56h,0CAh,0CCh, 8Ch,0C4h, 46h
		db	 81h, 56h,0CBh, 90h,0C4h, 46h
		db	0CCh,0C7h, 8Fh, 82h,0C4h, 46h
		db	0C9h,0C7h, 8Dh,0C4h,0C7h,0CCh
		db	 66h, 91h,0C4h,0C7h,0C9h, 46h
		db	 8Fh, 82h,0C4h, 76h, 8Ch,0C4h
		db	 06h, 07h, 90h,0C4h, 66h, 8Fh
		db	 82h,0C5h, 76h, 8Ch,0C5h,0CAh
		db	0C9h, 76h, 87h,0C3h, 46h, 86h
		db	0C4h, 56h, 90h, 82h,0C4h, 76h
		db	 8Ch,0C4h, 56h,0C9h,0C7h,0CAh
		db	0C9h,0C7h, 86h,0C4h,0CAh,0C9h
		db	0C7h, 85h,0C4h, 66h, 8Fh, 82h
		db	0C4h,0C7h,0CAh,0CCh, 46h, 8Ch
		db	0C4h, 4Bh, 05h, 07h, 86h,0C4h
		db	0C7h,0CBh,0CCh, 85h,0C4h,0C9h
		db	0C7h,0CAh, 46h, 8Eh, 82h,0C4h
		db	 76h, 8Ch,0C4h, 76h, 4Bh, 46h
		db	 85h,0C4h, 56h, 85h,0C4h, 76h
		db	 8Eh, 82h,0C4h, 46h, 4Bh,0CBh
		db	 8Ch,0C5h,0C7h,0CAh,0CCh, 05h
		db	 07h, 85h,0C4h, 46h,0CAh, 85h
		db	0C4h, 66h, 8Fh, 82h,0C4h,0C7h
		db	0CAh,0C7h,0CAh, 8Dh,0C4h, 56h
		db	0CBh,0C7h,0C9h,0C7h,0CAh,0C9h
		db	0CCh, 84h,0C4h, 46h, 86h,0C5h
		db	0C7h,0CAh,0C7h,0CBh, 8Fh, 82h
		db	0C4h, 66h, 8Dh,0C4h, 09h, 07h
		db	 01h, 1Ah, 01h, 1Ch, 66h, 85h
		db	0C5h, 76h, 8Eh, 82h,0C5h, 66h
		db	 8Dh,0C4h, 06h, 07h,0C9h,0C7h
		db	0CCh,0DBh, 01h, 1Ah,0DBh,0CBh
		db	0C7h,0C9h,0CAh, 85h,0C4h,0C7h
		db	0C9h, 46h, 8Fh, 82h,0C5h,0CAh
		db	0C7h,0C9h, 46h, 8Ch,0C4h, 09h
		db	 07h, 02h, 1Ah,0DCh,0CCh, 56h
		db	 85h,0C4h,0CAh, 4Bh,0C7h, 8Fh
		db	 82h,0C4h,0C7h,0CCh, 56h, 8Ch
		db	0C4h,0CAh,0C9h,0CCh, 05h, 07h
		db	0CAh,0DAh,0DBh, 01h, 1Ah,0C7h
		db	0CCh,0C7h, 86h,0C4h, 66h, 8Fh
		db	 82h,0C4h,0C7h,0CAh, 4Bh,0C7h
		db	 85h,0C3h, 56h,0C9h, 0Ch, 07h
		db	0DAh, 02h, 12h, 81h,0C7h, 87h
		db	0C4h, 76h, 8Eh, 82h,0C4h, 46h
		db	0CBh, 46h, 85h,0C4h,0C7h, 4Bh
		db	 05h, 07h,0CCh, 46h, 49h,0C9h
		db	0C7h, 8Eh,0C4h, 46h,0CBh,0CCh
		db	0C8h, 8Eh, 82h,0C4h, 56h,0CCh
		db	0C7h, 85h,0C5h, 06h, 07h,0CAh
		db	0C9h,0CCh, 46h,0C9h,0CCh,0C7h
		db	 50h, 41h, 60h,0C2h,0C1h, 51h
		db	 81h,0C4h, 66h,0CCh, 8Eh, 82h
		db	0C5h, 76h, 85h,0C6h, 66h,0CBh
		db	0CAh, 81h, 46h, 81h,0C5h, 66h
		db	 8Fh,0C4h,0C9h, 56h, 8Fh, 82h
		db	0C4h, 76h, 90h,0C4h, 56h, 86h
		db	0C3h,0C7h, 81h,0C7h, 86h,0C4h
		db	 66h, 8Fh, 82h,0C4h,0C9h, 66h
		db	 51h, 40h, 41h, 40h, 41h,0C1h
		db	0C2h, 40h, 81h,0C4h, 66h, 85h
		db	0C4h, 49h,0C7h, 86h,0C4h, 56h
		db	 90h, 81h,0C3h, 76h, 91h,0C4h
		db	0C7h,0CAh, 56h, 84h,0C4h, 66h
		db	 85h,0C4h, 56h, 90h, 81h,0C4h
		db	 56h, 89h,0C3h, 89h,0C4h, 4Bh
		db	0C9h, 46h, 84h,0C4h,0CAh,0CCh
		db	 46h, 85h,0C4h, 56h, 90h,0C3h
		db	0C7h, 4Bh, 8Ah,0C4h,0CAh, 88h
		db	0C4h, 66h, 85h,0C5h,0C9h,0C7h
		db	0CCh,0C7h, 85h,0C5h, 46h, 91h
		db	0CAh, 56h, 85h,0C3h, 84h,0C4h
		db	0C7h,0CAh, 81h,0C7h, 85h,0C5h
		db	0C7h,0CCh,0C7h,0CAh, 85h,0C4h
		db	 66h, 85h,0C4h, 56h, 8Bh,0C3h
		db	 66h,0C7h,0CCh,0C7h, 86h,0C5h
		db	 46h, 82h,0C4h,0CAh, 4Bh,0C7h
		db	 85h,0C4h, 46h,0CCh, 86h,0C6h
		db	0C7h, 81h,0C7h, 86h,0C4h, 56h
		db	 8Bh,0C6h, 46h,0C9h,0C7h, 89h
		db	0C5h, 76h,0C9h, 56h, 85h,0C5h
		db	 66h, 8Fh,0C4h,0C7h,0C9h,0C7h
		db	 90h, 89h,0C4h, 56h,0CCh, 76h
		db	 85h,0C4h,0C7h,0CAh,0CCh,0C7h
		db	 8Fh,0C4h,0C7h,0CAh,0C7h, 90h
		db	 89h,0C4h,0C7h,0C9h, 4Bh, 56h
		db	0C9h, 86h,0C4h, 46h,0C9h,0C7h
		db	 8Fh,0C5h, 56h,0C8h, 8Fh,0C7h
		db	0C9h,0C7h, 86h,0C4h, 46h, 82h
		db	0C4h,0CAh, 4Bh,0C7h, 85h,0C4h
		db	0C9h, 56h, 85h,0C3h,0C7h, 81h
		db	0C7h, 85h,0C3h,0C7h,0CBh, 46h
		db	 8Bh,0C3h, 46h,0CCh,0C7h, 66h
		db	 85h,0C6h, 84h,0C5h,0CAh, 48h
		db	0CBh, 85h,0C4h, 56h, 86h,0C4h
		db	 66h, 84h,0C4h, 76h, 8Ah,0C6h
		db	 46h,0CAh,0CCh,0C6h, 56h, 8Ah
		db	0C4h,0C9h,0C7h,0CBh, 86h,0C4h
		db	 66h, 85h,0C4h,0CAh,0CCh,0C9h
		db	0C7h, 84h,0C4h,0C7h,0C9h,0C7h
		db	 4Bh,0CBh, 8Eh, 81h,0C4h,0C7h
		db	0CAh,0C7h, 89h,0C6h, 46h, 87h
		db	0C4h,0C9h,0CCh,0C7h, 86h,0C5h
		db	 56h,0C8h, 84h,0C5h, 66h,0CBh
		db	 8Fh, 81h,0C6h, 76h, 91h,0C5h
		db	 66h, 85h,0C5h, 66h, 84h,0C4h
		db	 76h, 8Fh, 82h,0C4h,0C7h,0C9h
		db	0CCh, 46h, 40h, 51h, 60h, 61h
		db	 40h, 81h,0C4h,0C7h,0CAh,0CCh
		db	0C7h, 85h,0C4h,0C9h, 56h, 84h
		db	0C4h, 76h,0C8h, 8Eh, 82h,0C4h
		db	 66h, 91h,0C4h, 46h,0C9h,0C7h
		db	 85h,0C4h, 56h,0C8h, 84h,0C4h
		db	0C9h, 46h,0CAh,0C7h, 8Fh, 82h
		db	0C4h, 76h, 86h,0C3h, 46h,0CAh
		db	0C7h, 81h,0C7h,0CAh, 56h,0C9h
		db	 56h, 85h,0C5h,0C7h,0CCh,0C7h
		db	 85h,0C4h, 05h, 07h, 8Eh, 82h
		db	0C5h,0C9h, 66h, 86h,0C4h,0CAh
		db	0C9h,0CCh, 05h, 07h, 4Bh, 46h
		db	 86h,0C4h, 56h, 85h,0C5h, 66h
		db	 90h, 82h,0C4h, 76h, 86h,0C4h
		db	 66h,0CCh,0C9h, 07h, 07h, 85h
		db	0C4h, 56h, 85h,0C4h, 76h, 8Fh
		db	 82h,0C4h,0CAh,0CCh, 56h, 86h
		db	0C4h, 56h,0C9h,0CCh,0CBh,0CAh
		db	 66h,0CCh,0C7h, 86h,0C4h, 56h
		db	 85h,0C4h, 46h,0CCh,0C7h, 81h
		db	0C7h, 8Eh, 82h,0C5h, 76h, 86h
		db	0C4h, 66h, 82h, 06h, 07h, 86h
		db	0C4h,0C7h,0CAh,0CBh, 85h,0C4h
		db	 56h,0CCh, 90h, 82h,0C4h, 76h
		db	 86h,0C5h, 46h,0C8h, 84h,0C4h
		db	 76h, 86h,0C4h, 56h, 85h,0C4h
		db	0C7h, 48h,0C7h,0CBh, 8Fh, 82h
		db	0C4h, 46h,0CAh,0CCh, 87h,0C4h
		db	0CAh,0CCh,0C8h, 84h,0C5h,0C7h
		db	 4Bh,0C9h,0C7h, 86h,0C5h, 56h
		db	 85h,0C5h, 76h, 8Fh, 82h,0C4h
		db	0C7h,0CCh,0C9h, 46h, 86h,0C4h
		db	 46h, 85h,0C4h,0C7h,0CAh, 4Bh
		db	0C7h, 86h,0C5h, 56h,0C8h, 84h
		db	0C5h, 66h, 90h, 82h,0C4h, 76h
		db	 86h,0C4h,0C9h,0CCh,0CBh, 84h
		db	0C4h, 46h,0C9h,0CCh, 87h,0C4h
		db	0C9h,0CBh,0C7h, 85h,0C4h, 66h
		db	 85h,0C3h, 46h,0CAh,0CCh, 46h
		db	 84h, 82h,0C5h, 76h, 86h,0C4h
		db	 46h,0CCh, 84h,0C4h, 66h,0CCh
		db	0C7h, 85h,0C5h, 56h, 85h,0C4h
		db	 56h, 86h,0C4h,0C9h,0CCh, 46h
		db	0CCh, 85h, 82h,0C4h, 66h, 87h
		db	0C4h, 56h, 84h,0C4h,0C7h,0C9h
		db	 56h, 86h,0C4h, 46h,0CCh,0C7h
		db	 84h,0C4h, 66h, 85h,0C5h, 05h
		db	 07h, 84h, 82h,0C4h, 56h, 88h
		db	0C4h, 56h, 84h,0C5h,0C7h,0CAh
		db	0CCh,0CAh,0C7h, 86h,0C4h, 46h
		db	0CAh,0CCh, 84h,0C4h,0C9h,0CCh
		db	0CBh,0CCh, 85h,0C5h,0C7h,0CAh
		db	0C9h,0CCh,0C7h, 85h, 82h,0C6h
		db	 82h,0C7h, 88h,0C4h, 56h, 84h
		db	0C5h, 56h, 4Bh, 86h,0C4h, 66h
		db	 84h,0C4h, 46h,0C8h, 86h,0C4h
		db	 76h, 85h, 8Eh,0C5h, 56h, 84h
		db	0C4h, 05h, 07h, 85h,0C4h,0C9h
		db	 46h,0CAh,0CCh, 46h,0CCh, 56h
		db	 87h,0C4h, 66h, 86h, 51h, 70h
		db	 51h,0C1h,0C2h, 81h,0C5h,0CAh
		db	0C9h,0C7h, 84h,0C4h, 05h, 07h
		db	 85h,0C5h, 0Ch, 07h, 85h,0C5h
		db	0CCh,0C7h, 61h,0C1h,0C2h, 40h
		db	 8Eh,0C4h, 46h,0C8h, 84h,0C4h
		db	 46h, 48h,0C7h, 86h,0C5h, 66h
		db	0CAh,0C9h,0CCh, 76h,0C9h,0C8h
		db	 84h,0C4h,0CAh,0CBh, 88h,0C7h
		db	 81h,0C7h, 81h,0C7h, 89h,0C4h
		db	0C7h,0C8h, 85h,0C4h,0C7h,0CAh
		db	 4Bh, 46h, 85h,0C4h, 08h, 07h
		db	0CCh,0C9h, 46h, 47h, 83h,0C6h
		db	 46h, 85h,0C3h, 82h,0C9h, 4Bh
		db	0CAh, 46h, 88h,0C4h,0C7h,0C8h
		db	 85h,0C4h, 56h,0CAh,0CCh, 86h
		db	0C4h, 06h, 07h,0CBh,0C9h,0CBh
		db	 56h,0CAh,0C7h, 84h,0C4h,0C7h
		db	 85h,0C4h, 46h, 46h,0CCh, 66h
		db	 87h,0C4h,0C7h, 86h,0C4h, 66h
		db	0CCh,0C7h, 85h,0C4h, 56h,0CBh
		db	 8Fh,0C4h,0C9h,0C7h, 84h,0C5h
		db	 46h, 08h, 07h, 85h,0C4h,0CCh
		db	0C7h, 85h,0C4h, 76h,0C9h,0C7h
		db	 84h,0C4h,0CCh, 48h,0C7h, 8Dh
		db	0C3h, 81h,0C5h, 46h, 84h,0C5h
		db	 46h,0CAh,0CBh, 06h, 07h, 85h
		db	0C4h, 46h, 85h,0C4h,0CAh,0CCh
		db	 76h, 84h,0C4h, 66h, 8Dh,0C5h
		db	 66h, 84h,0C4h,0C7h,0CBh, 46h
		db	 83h,0C4h, 56h, 85h,0C4h,0CAh
		db	0C9h,0CBh, 84h,0C5h,0C7h,0C9h
		db	0CAh, 5Bh,0CAh, 84h,0C5h,0C7h
		db	 4Bh,0C8h, 84h,0C3h, 46h, 84h
		db	0C3h, 81h,0C4h, 56h, 85h,0C5h
		db	 46h,0C7h, 84h,0C5h, 56h, 85h
		db	0C4h, 46h,0CCh, 84h,0C4h, 66h
		db	0CCh, 46h, 84h,0C4h, 66h, 84h
		db	0C4h,0CBh,0C7h, 84h,0C5h, 46h
		db	0CCh,0C9h,0CCh, 85h,0C4h, 46h
		db	0C7h, 84h,0C4h,0CCh, 46h, 85h
		db	0C4h, 56h, 84h,0C6h, 81h,0C7h
		db	 82h,0C5h,0C7h, 85h,0C4h, 66h
		db	 84h,0C4h, 46h, 84h,0C5h, 56h
		db	 87h,0C4h,0CBh,0CAh,0C7h, 84h
		db	0C4h, 4Bh,0C7h, 85h,0C4h, 46h
		db	 91h,0C4h, 66h, 84h,0C4h, 46h
		db	 84h,0C4h, 46h, 88h,0C5h, 46h
		db	0C7h, 84h,0C4h, 56h, 85h,0C4h
		db	 46h, 91h,0C4h,0C7h,0C9h,0C7h
		db	 85h,0C5h,0C9h,0CCh, 84h,0C4h
		db	 46h, 88h,0C4h, 46h,0C8h, 84h
		db	0C4h,0C9h,0C7h,0CCh, 85h,0C4h
		db	 56h, 90h,0C4h,0C7h,0CAh, 46h
		db	 84h,0C4h,0CAh,0C7h,0C8h, 83h
		db	0C5h,0C9h,0CCh, 84h,0C3h, 83h
		db	 46h,0CCh,0CBh, 84h,0C5h, 56h
		db	 85h,0C4h,0C9h,0CCh,0CBh, 89h
		db	0C3h, 56h,0CAh, 06h, 07h, 84h
		db	0C4h, 46h, 84h,0C4h, 46h, 84h
		db	0C4h,0C7h, 81h, 56h,0C8h,0C8h
		db	 84h,0C5h, 56h, 85h,0C5h,0CAh
		db	0CCh, 46h, 88h,0C5h,0C9h, 66h
		db	0CBh,0CCh, 66h, 84h,0C4h,0C9h
		db	0C7h, 84h,0C6h, 81h,0C7h, 84h
		db	0C4h,0C7h,0CAh, 4Bh, 46h, 85h
		db	0C4h, 66h, 84h,0C4h, 56h, 89h
		db	0C4h, 56h, 81h, 46h,0C9h, 46h
		db	0CBh,0CCh, 84h,0C5h,0C7h, 8Ch
		db	0C5h, 05h, 07h, 85h,0C4h, 66h
		db	 84h,0C4h, 56h, 89h,0C4h,0C7h
		db	 84h,0C3h, 76h, 84h,0C4h,0C7h
		db	0C1h, 41h, 40h, 41h, 40h, 41h
		db	 81h,0C5h, 05h, 07h,0C8h, 84h
		db	0C4h, 66h, 82h, 46h,0CAh,0CCh
		db	0C7h, 8Ah,0C6h, 85h,0C4h, 66h
		db	 85h,0C5h,0CCh,0C7h, 8Bh,0C4h
		db	 05h, 07h,0C8h, 84h,0C5h,0C7h
		db	0CAh,0CCh, 07h, 07h, 90h,0C4h
		db	 76h, 84h,0C5h, 56h,0C8h,0C7h
		db	 81h, 46h, 85h,0C4h, 76h,0CCh
		db	0C8h, 84h,0C4h, 56h, 4Bh, 76h
		db	 91h,0C4h,0CAh,0CCh,0C7h,0C9h
		db	0C7h, 84h,0C4h,0CCh,0C9h,0CBh
		db	 05h, 07h, 84h,0C4h,0C9h, 76h
		db	0C7h, 84h,0C4h, 46h,0C9h,0CAh
		db	 05h, 07h, 91h,0C5h, 76h, 84h
		db	0C4h, 08h, 07h, 84h,0C5h, 46h
		db	0CAh, 56h,0C8h, 84h,0C6h, 0Ah
		db	 07h, 90h,0C4h, 66h, 85h,0C5h
		db	 46h,0CAh,0C9h,0CCh, 46h, 4Bh
		db	 84h,0C4h, 66h,0C9h,0C7h,0C7h
		db	 85h,0C4h, 46h,0C9h,0C7h,0CCh
		db	 76h, 90h,0C4h,0C9h,0CBh, 56h
		db	 84h,0C4h, 56h,0CBh, 47h,0C4h
		db	0C9h,0CBh, 84h,0C6h,0C7h, 82h
		db	 56h,0C7h, 85h,0C5h, 66h, 82h
		db	 56h, 91h,0C5h, 76h,0C8h, 83h
		db	0C4h,0C7h,0C9h, 84h,0C4h, 46h
		db	 89h,0C4h,0CCh,0C7h, 85h,0C5h
		db	 56h, 97h,0C5h,0C7h,0CBh,0C7h
		db	0CCh, 81h,0C8h, 83h,0C4h, 46h
		db	 84h,0C5h, 56h, 88h,0C4h,0C7h
		db	0C7h, 85h,0C4h, 46h,0C1h, 41h
		db	0C1h,0C2h, 50h,0C2h, 40h,0C2h
		db	0C1h,0C2h,0C1h,0C2h,0C1h, 87h
		db	0C4h, 66h,0CBh, 84h,0C6h, 86h
		db	0C6h,0C7h, 81h,0C7h, 88h,0C5h
		db	0C7h, 46h, 84h,0C4h, 46h, 98h
		db	0C4h, 56h, 81h,0C8h, 97h,0C5h
		db	0C7h,0C9h, 85h,0C4h,0C7h, 86h
		db	0C3h, 83h,0C7h, 8Eh,0C4h, 66h
		db	 51h, 40h, 51h,0C1h, 41h, 50h
		db	 51h, 50h, 51h, 81h,0C4h,0CAh
		db	 46h, 84h,0C4h,0CCh,0C7h, 85h
		db	0C5h, 46h,0CCh, 46h, 8Dh,0C4h
		db	 76h, 97h,0C4h,0C7h, 4Bh, 84h
		db	0C4h,0C7h,0CCh,0C7h, 84h,0C4h
		db	 56h,0CCh, 46h, 8Ch,0C5h,0CAh
		db	0CCh,0CAh, 46h, 85h,0C3h,0C7h
		db	0CCh,0C7h, 85h,0C3h, 88h,0C4h
		db	0CCh,0C7h,0CCh, 84h,0C4h,0C7h
		db	 4Bh, 84h,0C4h, 46h,0CAh,0CCh
		db	 66h, 89h,0C3h, 05h, 07h, 85h
		db	0C4h,0CAh,0CCh,0C8h, 85h,0C4h
		db	0C7h, 81h,0C7h, 85h,0C4h,0C7h
		db	 46h, 84h,0C4h,0C7h,0CAh,0C7h
		db	 84h,0C4h, 05h, 07h,0C9h, 46h
		db	 88h,0C4h, 76h, 86h,0C5h, 46h
		db	0CCh, 85h,0C4h, 46h, 86h,0C4h
		db	0C7h, 46h, 84h,0C5h, 56h, 84h
		db	0C4h, 05h, 07h,0CCh,0C7h,0CBh
		db	 88h,0C6h, 76h,0CCh, 85h,0C4h
		db	 56h, 85h,0C5h,0C7h,0CCh,0C7h
		db	 85h,0C4h,0C9h, 46h, 84h,0C4h
		db	0CAh, 46h, 84h,0C5h,0CAh, 07h
		db	 07h, 89h,0C4h,0C9h,0CCh,0C7h
		db	0C9h,0C7h, 85h,0C4h,0C9h,0C7h
		db	 86h,0C4h,0C9h, 46h, 85h,0C5h
		db	0C7h,0C7h,0C8h, 84h,0C4h, 56h
		db	 84h,0C5h,0C7h,0CCh, 05h, 07h
		db	0CCh, 89h,0C5h,0C7h, 4Bh, 46h
		db	 85h,0C4h, 56h, 85h,0C4h,0CAh
		db	0CCh,0C7h, 85h,0C5h,0C7h, 46h
		db	 84h,0C4h,0CCh,0C8h, 85h,0C4h
		db	0C9h,0C7h,0CCh,0C7h, 83h,0C4h
		db	0D7h,0D9h,0D1h, 87h,0C4h, 76h
		db	 85h,0C5h, 46h, 86h,0C4h, 56h
		db	 85h,0C4h,0CAh, 46h, 84h,0C4h
		db	 56h, 84h,0C4h, 56h, 84h,0D4h
		db	 01h, 15h,0D3h, 87h,0C4h,0C7h
		db	0C9h, 46h, 86h,0C5h, 46h, 86h
		db	0C4h,0C7h,0CAh,0CCh, 85h,0C4h
		db	0C7h, 46h, 84h,0C4h,0C7h,0CCh
		db	 85h,0C4h, 56h, 84h,0D4h, 01h
		db	 15h,0D3h, 87h,0C5h, 76h,0C8h
		db	 84h,0C4h,0C7h,0CCh,0C7h, 85h
		db	0C4h, 56h, 85h,0C5h,0C7h,0C7h
		db	 85h,0C4h, 56h, 84h,0C4h,0C7h
		db	0C9h,0C7h, 84h,0D4h,0D6h,0D5h
		db	0D3h, 87h,0C4h, 66h,0CAh, 4Bh
		db	0C8h, 82h,0C4h, 4Bh,0C7h, 85h
		db	0C4h, 56h, 85h,0C4h,0C7h, 46h
		db	 84h,0C4h, 56h, 84h,0C4h, 46h
		db	0CAh, 84h,0D4h, 02h, 15h, 87h
		db	0C6h, 0Dh, 07h, 85h,0C4h, 56h
		db	 85h,0C4h,0C7h,0C9h, 85h,0C4h
		db	0CCh, 46h, 84h,0C4h, 56h, 84h
		db	0C4h, 02h, 1Ah,0C9h, 88h,0C5h
		db	0C7h,0C9h,0CBh,0C7h,0C9h, 06h
		db	 07h, 85h,0C4h, 46h,0CAh, 85h
		db	0C4h,0CCh, 46h, 84h,0C4h,0C7h
		db	0C9h,0C7h, 84h,0C4h,0CCh, 46h
		db	 84h,0C4h, 46h,0C9h, 46h, 87h
		db	0C6h, 06h, 07h,0CCh, 46h,0C9h
		db	0C7h, 85h,0C5h, 56h, 85h,0C4h
		db	0C7h,0C9h,0CCh, 84h,0C5h, 46h
		db	 85h,0C4h,0C7h,0CCh,0C7h, 84h
		db	0C4h,0C7h,0CAh,0C7h,0CCh, 46h
		db	 88h,0C4h, 09h, 07h, 85h,0C5h
		db	 56h, 85h,0C4h,0CAh, 46h, 84h
		db	0C4h, 56h, 84h,0C4h, 56h, 84h
		db	0C5h, 46h,0CBh,0C9h,0CCh, 46h
		db	 87h,0C6h,0C7h, 85h,0C5h,0C7h
		db	0CAh,0C7h, 85h,0C4h,0C9h,0CCh
		db	 86h,0C4h,0C7h, 46h, 84h,0C5h
		db	 56h, 84h,0C4h, 46h,0CCh, 84h
		db	0C4h, 56h,0CCh,0C7h,0CAh, 46h
		db	 8Dh,0C5h, 46h, 86h,0C4h, 56h
		db	 85h,0C4h,0C7h,0C7h, 85h,0C4h
		db	0CCh, 46h, 84h,0C4h, 56h, 84h
		db	0C4h, 46h,0CAh,0C7h,0CBh,0C7h
		db	0CCh, 46h, 50h, 51h, 50h, 41h
		db	 81h,0C4h, 56h, 85h,0C4h,0CAh
		db	0CCh,0C7h, 85h,0C4h,0C7h,0C7h
		db	 85h,0C4h,0CAh, 46h, 84h,0C4h
		db	0C7h,0CAh,0C7h, 84h,0C4h, 07h
		db	 07h, 8Dh,0C4h, 46h,0CAh, 85h
		db	0C4h, 56h, 85h,0C5h,0C7h, 46h
		db	 84h,0C4h,0C9h, 46h, 84h,0C4h
		db	0C9h, 46h, 84h,0C5h,0C7h,0C9h
		db	 06h, 07h,0CCh, 56h,0CAh, 46h
		db	 85h,0C4h, 46h, 86h,0C4h, 56h
		db	 85h,0C4h,0C7h, 46h, 84h,0C4h
		db	 46h, 85h,0C5h, 56h, 84h,0C4h
		db	 46h,0CCh, 66h,0C9h, 08h, 07h
		db	 84h,0C4h, 46h, 86h,0C4h, 56h
		db	 85h,0C4h,0C7h,0C7h,0C8h, 84h
		db	0C4h, 56h, 84h,0C4h, 4Bh,0C7h
		db	 84h,0C4h, 76h,0CCh, 05h, 07h
		db	0CCh,0C9h, 46h,0CAh, 84h,0C4h
		db	 4Bh,0C8h, 85h,0C4h, 46h, 86h
		db	0C4h,0C9h,0CAh,0C7h, 84h,0C4h
		db	 56h, 84h,0C4h,0C7h,0CCh,0CBh
		db	 84h,0C6h,0C7h, 81h, 46h, 84h
		db	 46h,0CAh,0C9h,0CCh, 56h, 85h
		db	0C4h, 56h, 85h,0C4h, 56h, 85h
		db	0C4h,0C7h, 46h, 84h,0C4h, 56h
		db	 84h,0C4h, 46h, 94h,0C4h, 46h
		db	 84h,0C4h, 46h,0C8h, 85h,0C5h
		db	0C9h,0CCh,0C7h, 85h,0C4h,0C7h
		db	 46h, 84h,0C4h, 56h, 84h,0C4h
		db	 46h,0C1h, 41h, 40h, 51h, 40h
		db	0C2h, 50h, 41h,0C1h, 41h, 81h
		db	0C4h,0CCh, 85h,0C4h,0C9h,0C7h
		db	 86h,0C4h,0CAh, 4Bh, 85h,0C4h
		db	0C7h,0C7h,0CCh, 84h,0C4h,0C7h
		db	0C9h,0C7h, 84h,0C6h, 81h,0C7h
		db	 94h,0C4h, 46h, 84h,0C4h, 46h
		db	 86h,0C4h, 56h, 85h,0C4h,0CAh
		db	 46h, 84h,0C4h,0C7h,0CAh,0C7h
		db	 9Bh,0C4h, 46h, 84h,0C5h, 56h
		db	 85h,0C4h, 46h, 86h,0C4h,0C7h
		db	 46h, 84h,0C5h,0CCh, 46h, 9Bh
		db	0C4h,0C7h, 85h,0C4h, 4Bh,0C7h
		db	 85h,0C4h, 56h, 85h,0C5h,0C7h
		db	 46h, 84h,0C4h,0CCh, 46h, 9Bh
		db	0C6h, 86h,0C4h, 56h, 85h,0C4h
		db	 56h, 85h,0C5h,0C7h, 46h, 84h
		db	0C4h, 56h, 81h, 56h,0C9h, 83h
		db	0C9h, 56h, 96h,0C4h, 56h, 85h
		db	0C4h,0C9h,0CCh,0CAh, 85h,0C4h
		db	0C7h,0C9h,0C8h, 84h,0C4h,0C7h
		db	 4Bh, 09h, 07h,0C9h, 46h, 95h
		db	0C4h, 49h,0CCh, 85h,0C4h, 56h
		db	 85h,0C4h,0CAh, 46h, 84h,0C4h
		db	 46h,0CCh,0C7h,0CAh, 56h,0CBh
		db	 06h, 07h, 95h,0C5h, 46h, 81h
		db	0CBh, 84h,0C5h, 46h,0CCh, 85h
		db	0C4h,0C7h, 46h, 84h,0C4h,0C9h
		db	 06h, 07h,0C9h,0C7h,0CCh, 46h
		db	0CBh,0C7h, 86h,0C3h, 46h, 8Dh
		db	0C4h,0C7h,0C9h,0C7h,0C8h, 84h
		db	0C4h, 56h, 85h,0C4h,0C7h, 46h
		db	 84h,0C4h, 08h, 07h,0CCh, 66h
		db	 87h,0C4h, 56h, 8Ch,0C4h, 56h
		db	 85h,0C4h, 56h, 85h,0C4h,0C9h
		db	 46h, 84h,0C5h,0CCh, 08h, 07h
		db	0CAh, 66h, 86h,0C4h,0C9h,0CCh
		db	 8Dh,0C5h, 46h,0CCh,0C8h, 84h
		db	0C6h, 81h,0C7h,0C8h, 85h,0C4h
		db	0C7h,0C7h,0C8h, 84h,0C5h, 66h
		db	0C9h, 07h, 07h, 88h,0C5h, 56h
		db	 8Ch,0C5h, 66h, 8Dh,0C4h,0C7h
		db	 4Bh, 84h,0C4h, 0Ah, 07h, 8Ah
		db	0C4h, 46h,0CCh, 8Ch,0C4h,0C7h
		db	0CCh,0C7h, 8Eh,0C4h,0CAh,0C7h
		db	0CCh, 84h,0C4h,0C7h, 81h, 46h
		db	0CAh,0CCh, 66h, 81h,0C7h, 89h
		db	0C4h, 56h, 8Ch,0C4h, 56h, 8Eh
		db	0C5h,0C7h, 46h, 84h,0C6h, 83h
		db	0C4h, 46h,0CCh,0C7h,0CCh, 46h
		db	 8Ah,0C4h, 46h, 8Dh,0C4h,0CAh
		db	 46h, 8Eh,0C4h,0C7h, 46h, 88h
		db	0C4h, 66h,0C9h,0C7h, 8Bh,0C4h
		db	 56h, 8Ch,0C4h, 56h, 8Eh,0C4h
		db	0C7h, 46h, 88h,0C5h, 05h, 07h
		db	 8Bh,0C4h,0C9h,0CCh,0CBh, 8Ch
		db	0C4h,0C7h,0C9h,0C8h, 8Eh,0C4h
		db	0C7h, 46h, 88h,0C4h, 05h, 07h
		db	 8Bh,0C5h, 46h,0C8h, 8Ch,0C4h
		db	 46h,0C8h, 8Eh,0C4h,0C7h,0CAh
		db	 89h,0C4h, 05h, 07h, 8Bh,0C5h
		db	 46h,0C8h, 83h,0C3h, 46h,0C8h
		db	 85h,0C4h,0C9h, 46h, 8Eh,0C4h
		db	0CCh, 46h, 88h,0C4h,0CCh, 56h
		db	0CCh,0C7h, 41h,0C1h,0C2h, 40h
		db	 41h, 40h, 81h,0C4h, 46h, 84h
		db	0C5h,0CCh, 46h,0C8h, 84h,0C5h
		db	 56h,0C8h, 8Dh,0C5h,0C7h, 46h
		db	 88h,0C5h,0CCh, 76h, 8Bh,0C4h
		db	 46h, 84h,0C4h,0CAh,0CCh,0C7h
		db	 85h,0C4h, 66h, 8Dh,0C4h,0C7h
		db	0C9h,0C7h, 88h,0C4h,0C7h,0CCh
		db	 56h, 86h,0C3h, 85h,0CAh,0C7h
		db	 85h,0C4h, 56h,0C8h, 84h,0C4h
		db	0C7h,0CAh,0CBh, 8Eh,0C5h,0C7h
		db	 46h, 88h,0C4h, 76h, 86h,0C4h
		db	0C7h, 81h, 05h, 07h, 84h,0C5h
		db	 66h, 84h,0C5h, 56h, 8Eh,0C4h
		db	0C7h, 46h, 88h,0C4h,0C7h,0C9h
		db	 46h, 87h,0C4h, 56h,0C9h, 56h
		db	0C8h, 84h,0C4h,0C7h,0CAh,0CCh
		db	0CBh, 84h,0C4h, 56h, 8Eh,0C4h
		db	0C7h, 46h, 88h,0C6h, 46h, 81h
		db	0C7h, 87h,0C4h,0CAh, 4Bh, 66h
		db	 85h,0C4h, 46h,0C9h,0C7h, 84h
		db	0C4h,0C7h,0C9h,0CCh, 8Eh,0C4h
		db	0C7h,0CCh,0C7h, 94h,0C4h, 06h
		db	 07h, 85h,0C4h,0C9h, 56h, 84h
		db	0C6h, 81h,0C7h, 86h,0C3h, 81h
		db	 46h, 85h,0C4h,0C9h,0CCh,0C7h
		db	 94h,0C5h, 66h,0C9h,0C7h,0C8h
		db	 85h,0C4h,0CCh, 46h,0C9h, 8Dh
		db	0C4h, 46h,0CCh, 85h,0C4h,0CCh
		db	 46h, 85h,0C3h,0C7h, 81h, 46h
		db	 8Ah,0C4h, 46h,0CAh,0CCh,0C7h
		db	0C8h, 86h,0C5h, 66h, 8Dh,0C5h
		db	0CCh, 46h, 85h,0C4h,0C7h, 46h
		db	 85h,0C4h, 76h, 83h,0C3h, 46h
		db	 81h, 56h,0C9h, 46h, 89h,0C5h
		db	0CAh,0CCh, 46h, 8Dh,0C5h,0C7h
		db	0C9h,0C7h, 85h,0C4h,0C7h,0C9h
		db	0C7h, 85h,0C4h, 56h,0CAh, 46h
		db	 82h,0C6h,0C7h,0CCh,0C7h,0C9h
		db	 66h, 8Ah,0C4h, 05h, 07h,0C8h
		db	 8Ah,0C4h,0C7h, 4Bh, 85h,0C4h
		db	0C7h,0CAh,0CCh, 85h,0C5h,0CAh
		db	0CCh, 56h,0C8h, 83h,0C4h,0C7h
		db	 4Bh,0C7h,0CAh, 46h, 8Ah,0C4h
		db	 06h, 07h, 8Ah,0C4h, 56h, 85h
		db	0C4h,0C7h, 01h, 00h, 22h, 7Dh
		db	 00h, 23h, 95h, 00h, 2Bh,0B6h
		db	 00h, 3Ch,0B7h, 00h, 16h,0E3h
		db	 00h, 0Eh,0FAh, 00h, 15h,0FBh
		db	 00h, 2Ch,0FFh,0FFh, 48h, 00h
		db	 1Dh, 4Bh, 00h, 1Eh, 4Eh, 00h
		db	 1Fh,0B1h, 00h, 2Bh,0FFh,0FFh
		db	 19h, 80h,0A1h, 16h, 00h, 2Ch
		db	 00h, 5Eh, 80h,0B8h, 51h, 00h
		db	 6Ah, 00h, 81h, 80h, 8Fh, 7Bh
		db	 00h, 87h, 00h, 90h, 80h,0B6h
		db	 7Dh, 00h,0A4h, 00h,0CAh, 80h
		db	 9Eh,0BDh, 00h,0D6h, 00h,0E8h
		db	 40h,0A5h,0E6h, 00h,0F0h, 00h
		db	0F1h, 40h,0B6h,0EBh, 00h,0F8h
		db	 00h,0F4h, 40h, 88h,0EEh, 00h
		db	0F9h, 00h,0FFh,0FFh, 39h, 00h
		db	 05h,0C2h, 16h, 32h, 00h, 0Eh
		db	 00h,0FFh,0FFh,0FFh, 39h, 00h
		db	 0Fh, 03h, 19h, 66h, 00h, 35h
		db	 00h, 43h, 00h, 40h, 39h, 00h
		db	 22h, 81h, 18h, 23h, 00h, 2Bh
		db	 00h,0FFh,0FFh,0FFh, 39h, 00h
		db	 2Eh, 84h, 18h, 0Ah, 00h, 34h
		db	 00h,0FFh,0FFh,0FFh, 39h, 00h
		db	 39h,0C0h, 10h, 28h, 00h, 25h
		db	 00h,0FFh,0FFh,0FFh, 6Fh, 00h
		db	 14h, 80h, 08h, 04h, 00h,0FFh
		db	 00h,0FFh,0FFh,0FFh, 75h, 00h
		db	 1Fh, 83h, 18h, 99h, 00h, 2Ch
		db	 00h,0FFh,0FFh,0FFh,0A6h, 00h
		db	 1Eh, 84h, 19h, 1Ah, 00h, 12h
		db	 00h,0FFh,0FFh,0FFh,0A9h, 00h
		db	 12h, 80h, 18h,0ECh, 00h, 04h
		db	 00h,0FFh,0FFh,0FFh,0B9h, 00h
		db	 01h, 81h, 1Ah, 1Dh, 00h, 34h
		db	 00h,0FFh,0FFh,0FFh,0FAh, 00h
		db	 1Fh, 80h, 19h, 14h, 00h, 09h
		db	 00h,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 42h, 00h, 80h, 35h,0D9h, 00h
		db	 00h,0FFh,0FFh, 42h, 00h, 40h
		db	 95h,0D9h, 00h, 00h,0FFh,0FFh
		db	 42h, 00h, 20h, 05h,0DAh, 00h
		db	 00h,0FFh,0FFh, 42h, 00h, 10h
		db	 3Ch,0DAh, 00h,0FFh, 47h,0DAh
		db	0FFh,0FFh,0FFh,0FFh, 42h, 00h
		db	 08h,0BCh,0DAh, 00h,0FFh,0C7h
		db	0DAh,0FFh,0FFh,0FFh,0FFh, 42h
		db	 00h, 04h,0FCh,0DAh, 00h,0FFh
		db	 07h,0DBh,0FFh,0FFh,0FFh,0FFh
		db	 42h, 00h, 02h, 4Ch,0DBh, 00h
		db	0FFh, 57h,0DBh,0FFh,0FFh,0FFh
		db	0FFh, 42h, 00h, 01h,0BCh,0DBh
		db	 00h,0FFh,0C7h,0DBh,0FFh,0FFh
		db	0FFh,0FFh, 43h, 00h, 80h,0CCh
		db	0DBh, 00h,0FFh,0D7h,0DBh,0FFh
		db	0FFh,0FFh,0FFh, 43h, 00h, 40h
		db	0B9h,0D7h, 83h, 19h,0FFh,0FFh
		db	0FFh,0FFh, 16h,0AFh, 04h, 0Fh
		db	'Cavern of Absor'
		db	 17h, 00h, 07h, 0Eh, 0Eh, 02h
		db	 00h, 26h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 02h, 00h
		db	 26h, 02h, 00h, 04h, 00h, 02h
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 04h, 00h, 02h, 00h
		db	 00h, 04h, 00h, 04h,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 04h, 00h, 04h, 01h, 00h, 0Ah
		db	 00h, 26h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 0Ah, 00h
		db	 26h, 02h, 00h, 12h, 00h, 14h
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 12h, 00h, 14h, 00h
		db	 00h, 12h, 00h, 16h,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 12h, 00h, 16h, 01h, 00h, 13h
		db	 00h, 0Ch,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 13h, 00h
		db	 0Ch, 02h, 00h, 15h, 00h, 07h
		db	0FFh,0D0h, 00h, 00h, 20h, 00h
		db	 19h, 00h, 42h, 00h, 80h, 0Dh
		db	 00h, 15h, 00h, 24h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 15h, 00h, 24h, 03h, 00h, 21h
		db	 00h, 3Bh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 21h, 00h
		db	 3Bh, 03h, 00h, 27h, 00h, 37h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 27h, 00h, 37h, 04h
		db	 00h, 29h, 00h, 24h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 29h, 00h, 24h, 03h, 00h, 29h
		db	 00h, 3Bh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 29h, 00h
		db	 3Bh, 03h, 00h, 2Eh, 00h, 01h
		db	0FFh,0D0h, 00h, 00h, 20h, 00h
		db	 19h, 00h, 42h, 00h, 40h, 0Dh
		db	 00h, 2Fh, 00h, 2Eh,0FFh, 00h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 2Fh, 00h, 2Eh, 00h, 00h, 2Fh
		db	 00h, 30h,0FFh, 01h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 2Fh, 00h
		db	 30h, 01h, 00h, 30h, 00h, 11h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 30h, 00h, 11h, 03h
		db	 00h, 33h, 00h, 1Ah,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 33h, 00h, 1Ah, 03h, 00h, 3Bh
		db	 00h, 1Ah,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 3Bh, 00h
		db	 1Ah, 03h, 00h, 44h, 00h, 11h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 44h, 00h, 11h, 03h
		db	 00h, 49h, 00h, 2Bh,0FFh,0D0h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 42h, 00h, 20h, 00h, 00h, 4Dh
		db	 00h, 27h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 4Dh, 00h
		db	 27h, 03h, 00h, 55h, 00h, 27h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 55h, 00h, 27h, 03h
		db	 00h, 68h, 00h, 0Bh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 68h, 00h, 0Bh, 03h, 00h, 75h
		db	 00h, 34h,0FFh, 73h, 00h, 04h
		db	 20h, 00h, 00h, 00h, 42h, 00h
		db	 10h, 00h, 00h, 77h, 00h, 28h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 77h, 00h, 28h, 04h
		db	 00h, 79h, 00h, 16h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 79h, 00h, 16h, 03h, 00h, 7Dh
		db	 00h, 21h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 7Dh, 00h
		db	 21h, 03h, 00h, 80h, 00h, 00h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 80h, 00h, 00h, 02h
		db	 00h, 83h, 00h, 2Ah,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 83h, 00h, 2Ah, 04h, 00h, 88h
		db	 00h, 00h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 88h, 00h
		db	 00h, 03h, 00h, 93h, 00h, 16h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 93h, 00h, 16h, 03h
		db	 00h, 96h, 00h, 07h,0FFh, 77h
		db	 00h, 00h, 20h, 00h, 00h, 00h
		db	 42h, 00h, 08h, 00h, 00h, 99h
		db	 00h, 16h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 99h, 00h
		db	 16h, 03h, 00h,0A2h, 00h, 00h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0A2h, 00h, 00h, 03h
		db	 00h,0A9h, 00h, 33h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0A9h, 00h, 33h, 03h, 00h,0AAh
		db	 00h, 29h,0FFh, 73h, 00h, 05h
		db	 20h, 00h, 00h, 00h, 42h, 00h
		db	 04h, 00h, 00h,0B3h, 00h, 20h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0B3h, 00h, 20h, 02h
		db	 00h,0B7h, 00h, 20h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0B7h, 00h, 20h, 02h, 00h,0BAh
		db	 00h, 0Ah,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h,0BAh, 00h
		db	 0Ah, 00h, 00h,0BAh, 00h, 0Ch
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0BAh, 00h, 0Ch, 01h
		db	 00h,0BBh, 00h, 19h,0FFh, 73h
		db	 00h, 05h, 20h, 00h, 00h, 00h
		db	 42h, 00h, 02h, 00h, 00h,0BBh
		db	 00h, 29h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0BBh, 00h
		db	 29h, 03h, 00h,0BFh, 00h, 1Fh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0BFh, 00h, 1Fh, 02h
		db	 00h,0C5h, 00h, 04h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0C5h, 00h, 04h, 02h, 00h,0C7h
		db	 00h, 1Fh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C7h, 00h
		db	 1Fh, 02h, 00h,0CBh, 00h, 04h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0CBh, 00h, 04h, 02h
		db	 00h,0D0h, 00h, 31h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0D0h, 00h, 31h, 04h, 00h,0D1h
		db	 00h, 14h,0FFh, 73h, 00h, 03h
		db	 20h, 00h, 00h, 00h, 42h, 00h
		db	 01h, 00h, 00h,0D1h, 00h, 2Ah
		db	0FFh, 73h, 00h, 04h, 20h, 00h
		db	 00h, 00h, 43h, 00h, 80h, 00h
		db	 00h,0D3h, 00h, 0Ch,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0D3h, 00h, 0Ch, 03h, 00h,0D5h
		db	 00h, 02h,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h,0D5h, 00h
		db	 02h, 00h, 00h,0D5h, 00h, 04h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0D5h, 00h, 04h, 01h
		db	 00h,0DBh, 00h, 33h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0DBh, 00h, 33h, 03h, 00h,0E4h
		db	 00h, 3Ah,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h,0E4h, 00h
		db	 3Ah, 00h, 00h,0E4h, 00h, 3Ch
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0E4h, 00h, 3Ch, 01h
		db	 00h,0E5h, 00h, 16h,0FFh,0D0h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh,0FFh, 00h, 00h,0EBh
		db	 00h, 2Ah,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0EBh, 00h
		db	 2Ah, 03h, 00h,0FCh, 00h, 0Dh
		db	0FFh,0D0h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh,0FFh, 00h
		db	 00h,0FFh, 00h, 33h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh, 00h, 33h, 03h, 00h,0FFh
		db	0FFh

_343MP80	endp

seg_a		ends



		end	start
