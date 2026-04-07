
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_345MP82                                 лл
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

_345MP82	proc	far

start:
		lds	dx,dword ptr [di]	; Load seg:offset ptr
		add	[bx+si],al
		dec	si
		rol	ax,cl			; Rotate
		add	[bx+di-2Eh],dl
		db	 68h,0D2h, 6Ah,0D2h,0B9h,0D2h
		db	 0Fh,0D3h, 39h,0D3h, 53h,0D3h
		db	 08h,0FFh,0FFh,0FFh, 0Ah, 00h
		db	 00h, 51h,0D2h,0CCh,0CAh,0CCh
		db	 56h,0CAh,0CCh, 94h,0C4h, 46h
		db	0C2h, 40h, 41h, 50h,0C2h, 81h
		db	0C4h, 07h, 07h, 84h,0C4h, 46h
		db	0CCh, 05h, 07h,0CBh, 81h, 76h
		db	0CBh, 94h,0C4h,0C7h,0C9h, 8Ah
		db	0C4h,0CAh, 56h,0CAh,0CCh, 46h
		db	 84h,0C4h, 06h, 07h,0CAh,0CCh
		db	 83h,0C4h, 66h, 94h,0C4h,0CCh
		db	0C7h,0C8h, 89h,0C4h,0C7h,0CAh
		db	0CCh,0C9h, 66h, 84h,0C6h, 81h
		db	0C7h,0CCh, 05h, 07h, 83h,0C4h
		db	 66h, 94h,0C4h,0CAh,0CCh,0C7h
		db	 89h,0C4h, 46h,0CCh, 56h,0CCh
		db	0C8h, 89h,0C4h, 46h,0C8h, 81h
		db	 83h,0C5h,0C7h,0C9h, 46h, 94h
		db	0C4h,0C7h, 4Bh,0C8h, 88h,0C5h
		db	 46h,0C9h,0C7h,0CAh,0CCh,0CAh
		db	0CCh, 89h,0C4h,0C9h,0CCh, 82h
		db	 83h,0C4h, 66h, 85h,0C3h,0C7h
		db	0C9h,0C7h, 8Bh,0C5h, 46h,0C9h
		db	0CBh, 88h,0C4h, 76h,0CBh,0C7h
		db	0CBh, 89h,0C5h, 46h, 82h, 83h
		db	0C4h, 56h, 86h,0C4h, 56h, 8Bh
		db	0C4h, 05h, 07h, 82h,0C7h, 81h
		db	0C7h, 81h, 66h,0CAh, 66h, 89h
		db	0C6h,0C7h, 83h, 83h,0C4h, 66h
		db	 85h,0C5h, 56h, 8Bh,0C6h, 82h
		db	0C4h, 46h,0C9h,0CCh,0CBh,0CCh
		db	 56h,0C9h,0C7h,0CAh,0CCh, 56h
		db	0C9h, 66h, 8Bh, 83h,0C4h,0CAh
		db	 4Bh,0C7h, 85h,0C5h, 56h, 8Eh
		db	0C4h,0CAh,0CCh, 0Bh, 07h,0C9h
		db	 05h, 07h,0C8h, 8Ah, 83h,0C5h
		db	 46h,0CAh,0CCh, 85h,0C4h, 56h
		db	 41h, 50h,0C2h,0C1h, 51h, 50h
		db	 81h,0C5h, 46h,0CCh, 46h,0CAh
		db	 4Bh, 49h, 4Bh,0C7h,0CCh, 07h
		db	 07h, 8Ah, 83h,0C5h, 56h,0CBh
		db	 85h,0C4h,0CCh, 46h, 81h, 03h
		db	 11h, 01h, 13h, 87h,0C4h,0C7h
		db	0C9h, 66h,0C9h,0CCh, 56h,0CAh
		db	 4Bh, 76h, 8Dh, 83h,0C4h,0C9h
		db	0CCh, 46h, 85h,0C4h,0CAh,0CCh
		db	0C7h, 81h, 03h, 11h, 01h, 13h
		db	 87h,0C4h,0CAh, 4Bh,0CBh, 82h
		db	 46h,0CBh, 76h,0CCh,0CBh, 90h
		db	 83h,0C4h, 56h,0C8h, 85h,0C5h
		db	0C7h,0C9h,0C7h, 81h, 03h, 11h
		db	 01h, 13h, 87h,0C4h, 56h, 9Dh
		db	 83h,0C4h, 66h, 85h,0C4h, 66h
		db	 03h, 11h, 01h, 13h, 87h,0C4h
		db	0CCh, 46h,0C2h, 40h,0C2h,0C1h
		db	0C2h, 50h, 41h,0C1h,0C2h, 40h
		db	0C2h, 8Dh, 83h,0C4h, 66h, 85h
		db	0C4h,0C7h, 4Bh, 81h, 03h, 11h
		db	 01h, 13h, 87h,0C5h,0C7h,0CCh
		db	0C7h, 9Dh, 83h,0C4h,0C9h,0CAh
		db	0CCh,0C7h, 85h,0C4h, 66h, 03h
		db	 11h, 01h, 13h, 87h,0C5h, 46h
		db	 86h,0C3h, 46h, 81h,0C7h, 93h
		db	 83h,0C4h, 56h,0CBh, 85h,0C4h
		db	0CAh,0CCh, 46h, 03h, 11h, 01h
		db	 13h, 87h,0C4h, 46h, 86h,0C4h
		db	 66h, 93h, 83h,0C4h, 66h, 85h
		db	0C4h,0C7h,0C9h,0CCh, 81h, 03h
		db	 11h, 01h, 13h, 87h,0C6h,0C7h
		db	 87h,0C4h,0C9h,0C7h,0CCh,0C7h
		db	 93h, 83h,0C5h, 66h, 85h,0C4h
		db	 56h, 81h, 03h, 11h, 01h, 13h
		db	 90h,0C4h,0CAh,0CCh,0C7h,0CCh
		db	0C7h, 92h, 83h,0C4h, 46h,0C9h
		db	0C7h, 85h,0C4h, 56h, 81h, 03h
		db	 11h, 01h, 13h, 90h,0C4h, 56h
		db	0CCh,0C7h, 92h, 83h,0C4h, 66h
		db	 85h,0C5h, 46h,0C8h, 81h, 03h
		db	 11h, 01h, 13h, 90h,0C4h,0CAh
		db	 66h, 92h, 83h,0C5h,0C7h,0CAh
		db	0C7h,0C8h, 85h,0C4h, 46h, 86h
		db	0C3h, 46h, 8Fh,0C4h, 66h, 93h
		db	 83h,0C4h, 46h,0CCh,0C8h, 85h
		db	0C4h,0C7h,0C9h,0C7h, 85h,0C4h
		db	0CAh,0C7h, 8Fh,0C5h, 46h,0CCh
		db	0C7h, 85h,0C3h,0C7h, 82h,0C7h
		db	 89h, 83h,0C4h, 66h, 85h,0C4h
		db	 56h, 85h,0C4h, 4Bh,0C7h, 8Eh
		db	0C4h, 56h, 86h,0C4h, 46h,0CCh
		db	0C9h,0C7h, 88h, 83h,0C4h,0CAh
		db	0CCh,0C9h,0CCh, 85h,0C5h, 46h
		db	0C9h,0C7h, 84h,0C4h,0C9h,0CBh
		db	 8Fh,0C4h, 66h, 85h,0C5h, 56h
		db	0CCh, 46h, 87h, 83h,0C4h, 66h
		db	 85h,0C5h,0CAh,0CCh, 46h, 84h
		db	0C4h, 46h, 8Fh,0C4h,0C7h,0C9h
		db	 46h, 85h,0C4h, 56h,0CCh,0C7h
		db	0C8h, 87h, 83h,0C4h, 46h,0CAh
		db	0CCh,0C8h, 84h,0C4h,0C7h,0CCh
		db	0C7h,0C8h, 84h,0C5h,0C7h,0CCh
		db	 8Fh,0C4h, 46h,0C9h,0C7h, 85h
		db	0C5h,0C7h,0C9h, 46h,0CBh, 88h
		db	 83h,0C4h, 66h,0CBh, 84h,0C4h
		db	0C7h,0CAh,0CCh,0C7h, 84h,0C4h
		db	0CAh,0C9h, 41h, 50h, 61h,0C1h
		db	0C2h,0C1h,0C2h,0C1h, 81h,0C4h
		db	 56h, 86h,0C4h, 46h,0CCh, 46h
		db	 88h, 83h,0C4h, 76h, 84h,0C4h
		db	 66h, 84h,0C4h, 46h, 8Fh,0C4h
		db	0CBh,0C7h,0C9h,0C7h, 85h,0C4h
		db	 56h,0C8h, 89h, 83h,0C4h,0C7h
		db	0C9h, 66h, 83h,0C4h,0C7h,0C9h
		db	0C7h, 85h,0C4h, 46h, 84h,0C3h
		db	 56h, 87h,0C4h, 56h, 86h,0C4h
		db	0C9h,0C7h,0C8h, 84h,0C3h,0C7h
		db	 84h, 83h,0C5h, 05h, 07h, 83h
		db	0C5h, 56h,0C8h, 84h,0C4h, 46h
		db	 84h,0C4h, 66h, 86h,0C4h,0CAh
		db	0CCh, 46h, 85h,0C4h,0C7h,0CAh
		db	0C7h, 84h,0C4h, 46h, 83h, 83h
		db	0C5h, 0Ch, 07h,0C8h, 84h,0C5h
		db	0C7h,0C8h, 84h,0C4h,0CCh, 56h
		db	 86h,0C4h, 46h,0CCh,0C7h, 85h
		db	0C6h, 46h, 85h,0C4h, 56h, 82h
		db	 83h,0C4h, 76h,0CAh,0CCh, 56h
		db	0CAh,0CCh, 46h, 84h,0C4h, 46h
		db	 84h,0C4h,0C7h,0C9h,0C7h,0CAh
		db	0C7h, 85h,0C5h,0C7h,0CBh,0C7h
		db	0CBh, 8Dh,0C5h,0C9h,0CBh,0C7h
		db	 82h, 83h,0C4h,0C7h,0CAh, 46h
		db	0C9h, 06h, 07h,0CCh, 06h, 07h
		db	 85h,0C5h, 56h,0CBh,0C7h, 85h
		db	0C4h, 66h, 40h, 51h,0C1h,0C2h
		db	 50h, 41h, 81h,0C4h,0CAh,0CCh
		db	0C7h, 82h, 83h,0C4h, 46h, 4Bh
		db	 56h,0CCh,0C7h,0CCh, 56h,0C9h
		db	0CCh, 05h, 07h, 84h,0C4h,0C7h
		db	0CBh, 46h,0CCh, 85h,0C5h, 66h
		db	 8Dh,0C4h, 46h,0CCh, 82h, 83h
		db	0C4h, 56h,0CCh, 46h,0CAh, 46h
		db	0CCh, 07h, 07h,0CAh,0CCh,0C7h
		db	 84h,0C4h, 56h, 81h,0C7h, 85h
		db	0C4h,0C7h,0CCh, 66h, 81h, 56h
		db	 87h,0C4h, 56h, 82h, 83h,0C4h
		db	 56h,0CAh,0CBh, 66h,0CBh, 56h
		db	0CAh,0CCh,0CBh, 56h,0CBh,0C9h
		db	 84h,0C4h,0C7h,0C9h, 56h, 85h
		db	0C4h, 0Ch, 07h, 84h,0C4h, 46h
		db	 83h, 83h,0C4h,0CAh,0C9h, 66h
		db	0C9h, 46h, 81h,0C7h, 82h, 46h
		db	0C9h, 81h, 66h, 84h,0C4h, 46h
		db	0CAh, 46h, 85h,0C4h,0CAh,0C7h
		db	0C9h,0CCh, 66h,0C9h, 66h, 84h
		db	0C5h,0C7h,0C9h,0C7h, 82h, 83h
		db	0C5h, 06h, 07h, 8Bh,0C4h, 46h
		db	 84h,0C5h, 66h, 86h,0C4h,0C7h
		db	0CBh, 46h,0CCh, 06h, 07h,0C8h
		db	 84h,0C5h, 4Bh,0C7h, 82h, 83h
		db	0C4h, 46h,0CAh,0CCh,0C7h,0C1h
		db	 51h, 40h, 41h,0C1h,0C2h,0C1h
		db	0C2h, 81h,0C4h,0C7h,0C8h, 84h
		db	0C4h,0C7h,0CAh,0CBh,0C9h,0C7h
		db	 85h,0C4h,0C7h,0CCh,0CAh, 56h
		db	0C9h, 76h, 85h,0C4h,0C7h,0CAh
		db	0CCh, 82h, 83h,0C4h, 76h, 8Dh
		db	0C4h,0C7h,0C8h, 84h,0C4h, 46h
		db	0CCh, 46h, 85h,0C4h, 09h, 07h
		db	 86h,0E5h, 66h, 82h, 83h,0C4h
		db	 76h, 85h,0C3h, 46h, 85h,0C5h
		db	 46h, 84h,0C4h, 4Bh,0C7h,0CBh
		db	 86h,0C5h,0C7h,0CCh,0C7h,0C9h
		db	0CCh, 66h,0C8h, 85h,0E5h,0E9h
		db	0E5h, 56h, 82h, 83h,0C6h,0C7h
		db	 81h, 46h, 86h,0C5h,0C7h,0C9h
		db	0C7h, 84h,0C4h,0C9h,0C7h, 84h
		db	0C4h,0C7h,0C9h,0C7h, 87h,0C4h
		db	0CAh,0C7h,0CCh, 46h,0CAh,0C9h
		db	0C7h, 87h,0E9h,0E5h,0C9h,0CBh
		db	 46h, 82h, 8Eh,0C4h, 56h, 84h
		db	0C5h, 46h, 84h,0C4h,0C7h,0CAh
		db	0CCh,0C7h, 86h,0C4h,0C7h, 81h
		db	0C9h,0C7h,0CCh,0C7h,0CCh,0C7h
		db	 87h,0E5h,0C7h,0E5h,0CCh, 46h
		db	 82h, 41h, 40h,0C2h, 50h, 51h
		db	0C1h, 82h,0C4h,0CAh,0CCh,0C7h
		db	 84h,0C4h, 46h, 84h,0C4h, 46h
		db	0C9h,0C7h, 86h,0C4h, 06h, 07h
		db	0CBh, 87h,0E9h,0E5h,0C7h,0CAh
		db	0CCh,0C7h, 40h, 8Eh,0C4h,0C7h
		db	0C9h,0CBh, 84h,0C4h,0CAh,0CBh
		db	 84h,0C5h, 56h, 87h,0C6h, 46h
		db	 81h, 56h, 89h,0E5h, 76h, 82h
		db	 85h,0C3h, 46h, 86h,0C4h, 56h
		db	 84h,0C4h,0CCh,0C9h, 84h,0C5h
		db	 66h, 96h,0E9h,0E5h, 66h, 82h
		db	 85h,0C4h,0C9h,0CCh,0C8h, 85h
		db	0C4h,0CAh, 46h, 84h,0C4h, 46h
		db	 84h,0C4h,0C7h,0CAh, 46h, 41h
		db	 50h, 51h, 50h, 51h, 50h, 85h
		db	0E5h,0E9h,0E5h,0CCh, 46h, 82h
		db	 85h,0C4h, 56h, 85h,0C4h, 4Bh
		db	0C7h, 84h,0C4h,0C7h,0C8h, 84h
		db	0C4h,0C7h,0CBh,0C7h, 97h,0E9h
		db	0E5h,0C9h,0CAh,0CBh, 83h, 85h
		db	0C5h,0C7h,0CAh,0CCh,0C8h, 84h
		db	0C4h, 56h, 84h,0C4h, 46h, 84h
		db	0C4h, 56h, 97h,0E5h,0C7h,0E5h
		db	 56h, 82h, 85h,0C4h, 46h,0CBh
		db	 85h,0C4h,0C9h, 46h, 84h,0C5h
		db	 46h, 84h,0C4h, 46h,0CAh, 97h
		db	0E9h,0E5h, 56h, 83h, 85h,0C4h
		db	 46h,0CAh,0C8h, 84h,0C4h,0C7h
		db	0CAh,0CCh, 84h,0C4h,0CAh,0CCh
		db	 84h,0C4h,0C9h,0CCh,0C7h, 97h
		db	0E5h,0E9h,0E5h, 56h, 82h, 85h
		db	0C4h,0C7h,0C9h,0C7h,0C8h, 84h
		db	0C5h, 46h,0CCh, 84h,0C4h,0C7h
		db	0C9h, 84h,0C4h,0C7h,0CCh, 98h
		db	0E9h,0E5h, 46h,0C9h,0C7h, 82h
		db	 85h,0C4h, 46h, 86h,0C4h, 46h
		db	0CBh, 84h,0C4h,0C7h, 85h,0C4h
		db	0C7h, 99h,0E5h,0E9h,0E5h, 56h
		db	 82h, 85h,0C4h, 56h, 85h,0C4h
		db	0C7h,0CCh,0C7h, 84h,0C6h,0C7h
		db	 85h,0C5h,0C7h, 99h,0E9h,0E5h
		db	0C9h,0CCh, 46h, 82h, 85h,0C4h
		db	 4Bh,0C7h, 85h,0C5h, 46h,0CCh
		db	 8Bh,0C4h, 46h, 98h,0E5h,0CAh
		db	0E5h,0CAh,0CCh,0C7h, 82h, 85h
		db	0C4h,0C9h,0CAh,0CCh, 85h,0C4h
		db	0C7h,0CAh,0C7h, 8Bh,0C4h,0CAh
		db	0CCh, 98h,0E9h,0E5h,0C7h,0CBh
		db	0C7h, 83h, 85h,0C5h, 46h,0CBh
		db	 85h,0C4h, 46h,0C8h, 8Bh,0C4h
		db	0C7h,0CCh, 98h,0E5h, 66h, 83h
		db	 85h,0C4h, 56h, 85h,0C4h,0C7h
		db	0C9h, 8Ch,0C4h,0C7h,0C9h,0CBh
		db	 97h,0E9h,0E5h, 66h, 82h, 85h
		db	0C4h, 46h, 86h,0C4h, 56h, 47h
		db	 88h, 76h, 97h,0E5h,0E9h,0E5h
		db	0C9h, 46h, 82h, 85h,0C4h,0C7h
		db	0CCh,0C7h, 85h,0C4h, 46h,0CAh
		db	 46h, 81h,0C7h, 85h, 76h, 98h
		db	0E9h,0E5h, 66h, 82h, 85h,0C4h
		db	0C7h,0C9h,0CCh, 85h,0C4h,0C7h
		db	 4Bh, 0Ch, 07h,0C9h,0C7h, 97h
		db	0E5h,0E9h,0E5h,0CCh, 46h, 82h
		db	 85h,0C4h,0CAh,0CBh,0C7h, 85h
		db	0C4h,0CAh,0C7h,0CCh, 56h,0C9h
		db	0CCh, 46h,0C9h,0C7h,0CAh,0CCh
		db	 66h, 97h,0E9h,0E5h,0C9h, 4Bh
		db	0C7h, 82h, 85h,0C5h, 56h, 85h
		db	0C4h, 56h,0CBh,0C9h, 07h, 07h
		db	0C9h,0CCh, 56h,0C2h, 40h, 41h
		db	 50h, 51h,0C1h, 41h, 40h, 41h
		db	 85h,0E5h,0C8h, 56h,0CCh, 82h
		db	 85h,0C5h, 46h,0C8h, 85h,0C4h
		db	0CAh,0CCh, 76h,0CAh,0CCh, 76h
		db	0CCh,0CBh,0C7h, 98h,0E9h,0E5h
		db	0CBh, 56h, 82h, 85h,0C4h,0CAh
		db	0CCh,0C7h, 85h,0C4h, 08h, 07h
		db	0CCh,0CBh, 46h,0CAh,0C7h,0CCh
		db	 46h, 85h,0C3h, 66h, 86h,0C3h
		db	0CAh,0C8h, 84h,0E5h,0E9h,0CAh
		db	0CCh, 46h, 82h, 85h,0C4h,0CCh
		db	 46h, 85h,0C5h,0C7h,0C9h, 56h
		db	0CAh, 46h, 81h,0CCh, 07h, 07h
		db	 85h,0C4h, 56h,0CCh,0C7h, 85h
		db	0C4h, 66h, 81h, 66h,0C9h,0CAh
		db	0C7h, 82h, 85h,0C4h,0C7h,0CCh
		db	0C7h, 85h,0C4h, 05h, 07h,0C8h
		db	 82h, 06h, 07h,0CCh,0C7h, 85h
		db	0C4h, 46h,0C9h,0C7h,0CBh, 85h
		db	0C4h,0CAh,0CCh, 56h,0CBh,0C9h
		db	 46h, 85h, 85h,0C4h, 46h,0CBh
		db	 85h,0C4h,0C7h,0CAh, 4Bh,0C7h
		db	0C8h, 86h, 56h,0CCh,0C7h, 86h
		db	0C5h, 56h,0CAh, 86h,0C5h,0C7h
		db	0CCh,0C9h, 56h,0CBh,0C7h, 86h
		db	 85h,0C4h,0C7h,0C9h,0C7h, 85h
		db	0C4h, 46h,0C9h,0CBh,0C7h, 89h
		db	0C4h,0C7h,0CAh,0C7h, 85h,0C4h
		db	 76h, 85h,0C4h,0C7h,0CAh,0C7h
		db	0CCh,0C7h, 89h, 85h,0C4h, 46h
		db	0CBh, 85h,0C4h, 66h, 8Ah,0C4h
		db	0C9h,0CCh,0C7h, 85h,0C4h,0C7h
		db	 4Bh, 46h, 85h,0C6h, 56h, 8Bh
		db	 85h,0C4h, 56h,0C8h, 84h,0C4h
		db	 66h, 8Ah,0C4h, 56h, 85h,0C4h
		db	0C7h,0CAh, 56h, 94h, 85h,0C5h
		db	 56h,0C8h, 84h,0C4h,0C7h,0CCh
		db	 46h, 8Ah,0C5h, 46h, 86h,0C4h
		db	 56h,0CCh, 56h, 92h, 85h,0C4h
		db	0CAh,0CCh,0C7h, 85h,0C4h,0C9h
		db	 46h, 8Bh,0C4h, 56h, 85h,0C5h
		db	 46h,0C9h, 56h,0C9h,0CCh,0C7h
		db	 90h, 85h,0C4h, 46h,0CCh, 85h
		db	0C4h,0C7h,0CAh,0C7h,0C8h, 8Ah
		db	0C5h, 56h, 85h,0C4h, 66h,0CAh
		db	0CBh, 66h,0C8h,0C7h, 8Dh, 85h
		db	0C6h, 46h,0CBh, 85h,0C4h, 4Bh
		db	0C7h,0C8h, 8Ah,0C4h,0C7h,0C9h
		db	 86h,0C4h, 46h,0CBh, 56h,0CCh
		db	0C7h,0C8h,0C7h, 8Fh, 87h,0C4h
		db	0C7h, 85h,0C5h, 46h,0CBh, 8Bh
		db	0C4h, 46h, 86h,0C4h, 56h, 81h
		db	0C7h, 94h, 87h,0C4h,0CAh, 85h
		db	0C4h, 66h, 8Ah,0C4h,0CAh, 46h
		db	 85h,0C5h, 66h, 95h, 87h,0C6h
		db	0C8h, 85h,0C4h, 46h,0CAh,0CCh
		db	 8Ah,0C4h,0C7h,0CCh,0C7h, 85h
		db	0C4h,0C7h,0C9h, 46h, 84h,0C3h
		db	0C7h,0CAh, 81h,0C7h, 8Ch, 8Eh
		db	0C4h,0C9h,0C7h,0CCh,0C7h, 8Ah
		db	0C4h, 46h,0CCh, 85h,0C4h, 46h
		db	0CCh,0C7h, 84h,0C5h, 46h,0CBh
		db	0C7h, 8Ch, 8Eh,0C4h, 66h, 8Ah
		db	0C4h, 46h,0CCh, 85h,0C4h,0C7h
		db	0CBh, 46h, 84h,0C4h,0C9h,0CCh
		db	 46h, 8Ch, 8Eh,0C4h,0C7h,0CAh
		db	 46h, 8Ah,0C5h, 56h, 85h,0C4h
		db	0C7h,0CAh,0CCh, 85h,0C4h, 56h
		db	 8Dh, 8Eh,0C4h,0C7h,0CCh,0C7h
		db	0C8h,0C7h, 89h,0C4h,0C7h,0CBh
		db	0C7h, 85h,0C4h,0C7h,0CCh,0CAh
		db	0C7h, 84h,0C4h, 56h, 8Dh, 8Eh
		db	0C5h, 46h,0CCh, 46h, 89h,0C4h
		db	0C9h, 46h, 85h,0C4h, 46h,0CCh
		db	0C7h, 84h,0C4h,0CAh,0CCh, 46h
		db	 85h,0C3h,0C7h, 81h, 46h, 82h
		db	 83h,0C3h, 56h, 87h,0C4h, 46h
		db	0CAh,0CCh, 46h, 88h,0C4h,0CAh
		db	0CCh,0C7h, 85h,0C4h, 66h, 84h
		db	0C4h,0C7h,0CCh, 46h, 85h,0C4h
		db	0CCh,0CAh,0C9h, 83h, 83h,0C5h
		db	 46h,0CCh,0C7h, 86h,0C4h, 56h
		db	0CBh, 46h, 88h,0C4h,0C7h,0CCh
		db	0C7h, 85h,0C4h,0C9h, 56h, 84h
		db	0C4h, 46h,0CCh,0C7h, 85h,0C4h
		db	0C7h,0CBh,0C7h, 83h, 83h,0C4h
		db	0C7h,0CAh,0C9h, 4Bh,0C7h, 82h
		db	 08h, 07h, 88h,0C4h,0C9h,0C7h
		db	0CCh, 85h,0C5h, 56h, 85h,0C4h
		db	0C7h,0C9h,0C7h, 86h,0C4h,0C7h
		db	0C9h,0CCh,0C7h, 82h, 83h,0C4h
		db	 66h,0CAh, 76h,0CCh, 56h,0CAh
		db	 46h, 88h,0C4h, 46h, 86h,0C5h
		db	 66h, 84h,0C5h,0C7h,0CBh, 46h
		db	 85h,0C4h,0CAh, 46h, 83h, 83h
		db	0C4h,0C7h,0CCh, 56h, 4Bh,0C7h
		db	0CAh,0CCh,0C7h,0CCh, 46h, 8Bh
		db	0C5h, 46h, 86h,0C4h, 46h,0CBh
		db	0C7h, 84h,0C4h, 46h,0CCh,0C7h
		db	 85h,0C4h,0C7h,0C8h, 46h, 82h
		db	 83h,0C4h,0C7h,0CCh, 46h,0CAh
		db	0C7h,0CCh, 46h,0C9h, 46h,0CBh
		db	0C8h, 8Bh,0C4h, 56h, 85h,0C4h
		db	0C7h,0CAh,0CCh,0C7h, 84h,0C4h
		db	 56h, 86h,0C5h, 66h, 82h, 83h
		db	0C4h,0C9h,0CAh,0CBh, 56h, 81h
		db	0CBh, 66h, 8Dh,0C4h, 56h, 85h
		db	0C4h, 56h,0CCh, 84h,0C4h, 66h
		db	 85h,0C4h,0C7h,0C9h, 46h, 82h
		db	 83h,0C4h, 05h, 07h, 93h,0C4h
		db	0CAh,0CCh,0C7h, 85h,0C4h,0CAh
		db	 56h, 84h,0C4h,0CAh,0CBh, 46h
		db	 85h,0C4h,0C7h,0CCh,0C7h, 83h
		db	 83h,0C4h, 46h,0CCh, 46h, 8Eh
		db	 46h, 84h,0C4h, 46h,0CCh, 85h
		db	0C5h,0C7h,0CCh, 46h, 84h,0C4h
		db	 56h, 86h,0C4h,0CAh,0C7h,0CCh
		db	0C7h, 82h, 83h,0C5h, 46h,0CAh
		db	0CCh, 8Bh,0C7h, 81h, 66h, 84h
		db	0C4h,0C9h,0C7h,0CCh,0C7h, 84h
		db	0C4h,0C7h,0C9h,0CCh,0C7h, 84h
		db	0C5h,0C7h,0CAh, 46h, 85h,0C4h
		db	 66h, 82h, 83h,0C5h, 66h, 85h
		db	0C3h,0C7h, 81h, 08h, 07h, 84h
		db	0C5h, 66h, 84h,0C4h, 46h,0CCh
		db	 85h,0C4h, 46h,0C9h,0C7h, 85h
		db	0C4h, 66h, 82h, 83h,0C4h, 66h
		db	 85h,0C4h, 46h, 49h,0CCh, 76h
		db	 85h,0C4h, 66h,0CAh, 66h,0CCh
		db	 46h, 85h,0C4h,0C7h, 4Bh,0C7h
		db	 85h
loc_1:
		lds	sp,dword ptr [bp-7Eh]	; Load seg:offset ptr
		add	sp,46h
		retf	85C7h			; Return far
		db	0C5h, 76h,0CCh,0CAh,0C9h, 46h
		db	 85h,0C4h, 46h,0CAh,0C7h,0CCh
		db	0C9h, 56h,0CAh,0CCh,0CBh, 85h
		db	0C4h,0C7h,0CAh,0CBh,0C7h, 85h
		db	0C5h,0C7h,0CCh, 46h, 82h, 83h
		db	0C4h,0C7h,0CAh,0CCh,0C7h, 85h
		db	0C4h, 09h, 07h, 85h,0C4h, 76h
		db	0CCh,0CBh, 56h, 87h,0C5h, 46h
		db	0C9h,0CCh, 85h,0C4h, 46h,0CCh
		db	0C7h, 82h, 83h,0C4h, 56h, 86h
		db	0C4h, 66h,0C9h,0C8h,0CAh,0CCh
		db	 46h, 85h,0C6h, 66h, 81h, 56h
		db	 89h,0C4h, 46h,0CCh,0C7h, 85h
		db	0C4h,0C7h,0C9h, 4Ah, 82h, 83h
		db	0C4h, 46h,0C9h,0C8h, 85h,0C4h
		db	 46h,0CCh, 76h,0CBh, 98h,0C4h
		db	 66h, 85h,0C4h,0CAh, 56h, 82h
		db	 83h,0C4h, 66h, 85h,0C4h, 46h
		db	0CAh,0CCh, 46h,0C9h,0C7h, 99h
		db	0C4h, 46h,0CCh,0C7h, 85h,0C4h
		db	0C9h, 56h, 82h, 83h,0C4h, 66h
		db	 85h,0C4h,0C9h, 46h,0CCh, 76h
		db	 8Dh,0C3h, 46h, 88h,0C4h,0C7h
		db	0C9h,0C7h,0CAh, 85h,0C4h, 56h
		db	 83h, 83h,0C4h,0CAh,0CCh, 46h
		db	 85h,0C4h, 66h,0CAh,0CCh,0CBh
		db	 56h, 8Ch,0C4h, 46h, 88h,0C4h
		db	 66h, 85h,0C4h, 66h, 82h, 83h
		db	0C4h,0C9h,0CCh,0CBh,0C7h, 85h
		db	0C4h, 09h, 07h, 8Ch,0C5h, 56h
		db	 87h,0C5h,0C7h,0CCh, 46h, 85h
		db	0C5h,0C7h,0CBh,0C9h,0C7h, 82h
		db	 83h,0C5h, 56h,0CCh, 85h,0C5h
		db	 46h,0CAh, 08h, 07h, 8Ah,0C4h
		db	 4Bh,0CAh, 87h,0C4h, 46h,0CCh
		db	0C7h, 85h,0C4h, 46h,0CCh,0C7h
		db	 82h, 83h,0C4h, 66h, 85h,0C4h
		db	 07h, 07h,0CAh,0C7h,0C9h, 56h
		db	 88h,0C4h,0CAh,0CCh,0C7h, 87h
		db	0C5h, 56h, 86h,0C4h, 66h, 82h
		db	 83h,0C4h, 66h, 85h,0C4h,0C7h
		db	0CCh, 56h,0C9h, 06h, 07h,0C9h
		db	0C7h, 87h,0C4h,0C9h,0C7h,0CBh
		db	 87h,0C4h,0C7h,0CCh, 46h, 85h
		db	0C5h,0C7h,0C9h, 46h, 82h, 83h
		db	0C4h,0C7h,0CAh, 46h, 85h,0C4h
		db	 46h, 4Bh, 08h, 07h,0CAh,0CCh
		db	 56h, 84h,0C4h, 46h, 88h,0C4h
		db	0C7h,0C9h,0CBh, 86h,0C5h,0C7h
		db	0CAh,0CCh,0C7h, 82h, 83h,0C4h
		db	0C9h,0C7h,0CCh,0C7h, 85h,0C4h
		db	 66h,0CBh, 56h,0CAh,0CCh,0CAh
		db	0CCh, 46h,0CAh, 48h,0C7h, 84h
		db	0C4h, 46h, 88h,0C4h,0CCh, 46h
		db	 86h,0C4h,0CCh, 46h,0CCh, 82h
		db	 83h,0C4h, 56h, 86h,0C4h,0C9h
		db	0C7h,0CAh,0CCh,0C7h,0CCh, 56h
		db	0CCh,0C7h,0CCh, 56h,0CCh,0CBh
		db	 85h,0C4h, 56h, 87h,0C4h, 46h
		db	0CAh, 86h,0C4h, 46h,0CBh, 83h
		db	 83h,0C5h, 56h,0C8h, 85h,0C5h
		db	 09h, 07h,0CCh,0C9h,0CBh, 66h
		db	 85h,0C5h,0C7h,0C9h,0C7h, 87h
		db	0C4h, 66h, 85h,0C4h,0CAh, 56h
		db	 82h, 83h,0C4h, 46h, 87h,0C5h
		db	 09h, 07h, 81h,0CBh, 05h, 07h
		db	 84h,0C5h,0CAh,0CCh, 88h,0C4h
		db	0C9h, 56h, 85h,0C4h, 66h, 82h
		db	 83h,0C4h, 46h, 87h,0C4h, 46h
		db	0CCh,0CAh, 56h,0C9h,0C7h, 82h
		db	0C7h, 82h,0C4h,0CAh,0CCh,0C7h
		db	 84h,0C4h,0C9h,0C7h,0CCh, 87h
		db	0C4h,0C7h,0CAh,0CCh,0C7h, 85h
		db	0C4h,0C7h,0CCh, 46h, 82h, 83h
		db	0C4h,0C7h, 49h,0C7h, 85h,0C4h
		db	 56h,0CCh, 66h, 86h,0C4h,0C7h
		db	0C9h,0CBh, 84h,0C4h, 46h,0CBh
		db	 87h,0C4h,0C7h,0CCh,0CBh,0C7h
		db	 85h,0C5h, 46h,0CCh,0C7h, 82h
		db	 83h,0C4h,0CAh, 4Bh,0C7h, 85h
		db	0C4h, 66h,0CCh, 46h, 87h,0C4h
		db	 56h, 84h,0C4h,0CCh, 46h, 87h
		db	0C5h, 46h,0CCh,0C7h, 85h,0C4h
		db	0C7h,0CAh,0CBh,0C7h, 82h, 83h
		db	0C4h,0C9h,0CAh,0CCh,0C8h, 85h
		db	0C5h, 46h,0CAh,0CCh,0CBh, 89h
		db	0C5h, 56h, 84h,0C4h, 46h, 88h
		db	0C4h, 56h,0CBh, 85h,0C4h,0CBh
		db	 56h, 82h, 83h,0C4h, 56h,0C8h
		db	 85h,0C4h,0C7h,0CCh, 56h, 89h
		db	0C4h, 56h, 84h,0C4h,0C9h,0C7h
		db	 88h,0C6h, 46h, 81h,0C7h, 85h
		db	0C4h, 56h, 83h, 83h,0C4h, 66h
		db	 85h,0C4h,0CAh,0CCh, 56h, 89h
		db	0C4h, 56h, 84h,0C4h, 56h, 91h
		db	0C4h, 66h, 82h, 83h,0C4h,0CAh
		db	0CCh,0CAh,0CCh, 85h,0C4h, 46h
		db	0CCh,0C7h, 8Ah,0C4h,0CAh,0CCh
		db	 85h,0C5h, 66h,0C1h, 41h,0C1h
		db	 41h,0C1h, 41h, 40h, 41h, 40h
		db	 81h,0C4h,0C7h,0C9h,0CCh,0C7h
		db	 82h, 83h,0C4h,0C7h,0C9h,0CCh
		db	0C9h, 85h,0C4h, 4Bh,0C7h,0CBh
		db	0C7h, 89h,0C4h,0CAh,0CCh,0C7h
		db	 84h,0C4h, 46h,0C9h,0C7h, 90h
		db	0C4h, 56h,0CCh, 82h, 83h,0C4h
		db	 56h,0CBh, 85h,0C4h,0C7h,0CCh
		db	 56h, 89h,0C4h,0C9h,0CCh,0CBh
		db	 84h,0C4h,0CAh,0CCh, 46h, 86h
		db	0C3h,0CAh,0C7h, 81h,0C7h, 85h
		db	0C4h, 66h, 82h, 83h,0C4h,0C7h
		db	0CAh, 46h, 85h,0C4h, 46h,0CAh
		db	0CCh,0C7h, 89h,0C5h,0C7h,0C9h
		db	0C7h, 84h,0C4h, 56h, 87h,0C4h
		db	 56h, 86h,0C4h, 56h, 83h, 83h
		db	0C5h, 66h, 85h,0C4h, 76h, 89h
		db	0C4h,0CAh, 46h, 84h,0C4h,0C7h
		db	 4Bh,0C7h, 86h,0C4h,0C7h,0C9h
		db	0CBh,0C7h, 85h,0C4h, 56h, 83h
		db	 83h,0C4h, 66h, 85h,0C6h,0C7h
		db	 01h, 11h,0C7h, 01h, 11h, 88h
		db	0C5h,0C7h,0CBh,0C7h, 84h,0C4h
		db	0C7h,0CAh,0CBh,0C7h, 86h,0C5h
		db	0CAh,0CCh, 46h, 85h,0C5h, 56h
		db	 83h, 83h,0C5h, 46h,0C9h,0C7h
		db	 84h, 07h, 13h, 88h,0C4h,0C7h
		db	 86h,0C4h, 46h,0CBh,0CCh, 86h
		db	0C4h, 46h,0CCh,0C7h, 85h,0C4h
		db	0CAh,0CCh, 46h, 82h, 83h,0C4h
		db	 66h,0C8h, 83h, 07h, 13h, 88h
		db	0C4h,0C7h, 86h,0C4h,0C7h,0C9h
		db	0C7h,0CBh, 86h,0C4h,0C7h, 4Bh
		db	0C7h, 85h,0C4h,0C7h,0C9h,0CCh
		db	0C7h, 82h, 83h,0C4h,0CAh,0CCh
		db	 46h,0C8h, 02h, 12h, 07h, 13h
		db	 88h,0C4h,0CCh, 81h,0C7h, 84h
		db	0C4h, 66h, 86h,0C4h, 46h,0C9h
		db	0CCh, 85h,0C4h, 46h,0C9h,0C7h
		db	 82h, 83h,0C4h, 46h,0CCh, 46h
		db	 02h, 12h, 07h, 13h, 88h,0C4h
		db	0CAh,0CBh,0C7h, 84h,0C5h, 66h
		db	 86h,0C4h, 56h,0CBh, 85h,0C4h
		db	 46h,0CCh,0C7h, 82h, 83h,0C4h
		db	 76h, 0Ah, 12h, 88h,0C4h,0C7h
		db	0C9h,0CCh, 84h,0C4h,0CAh,0CCh
		db	 46h, 86h,0C5h, 56h, 86h,0C5h
		db	 56h,0CBh, 82h, 83h,0C4h,0C9h
		db	0CAh,0CCh, 46h,0C8h, 92h,0C4h
		db	 56h, 84h,0C4h, 46h,0CCh,0C7h
		db	 86h,0C4h, 66h, 85h,0C5h, 66h
		db	 82h, 83h,0C4h, 46h, 4Bh, 46h
		db	 92h,0C4h, 56h, 84h,0C4h,0C9h
		db	 56h, 86h,0C4h, 66h, 85h,0C4h
		db	 66h, 82h, 83h,0C4h, 66h,0CBh
		db	0C7h, 92h,0C5h,0CAh,0CBh,0C7h
		db	 84h,0C5h,0C7h,0CAh, 4Bh, 86h
		db	0C4h, 66h, 85h,0C4h, 66h, 82h
		db	 83h,0C4h, 46h,0CAh,0CCh,0C7h
		db	 93h,0C4h,0C7h,0CCh,0C7h, 84h
		db	0C4h,0C7h,0CCh,0C7h,0CBh, 86h
		db	0C4h,0C9h,0CAh,0CCh,0C7h, 85h
		db	0C4h,0C7h,0C9h, 46h, 82h, 83h
		db	0C4h, 76h,0C1h, 51h, 40h, 51h
		db	 60h, 41h, 40h, 82h,0C4h, 46h
		db	0CCh, 84h,0C5h, 66h, 86h,0C4h
		db	0C7h,0CCh,0C9h,0CCh, 85h,0C4h
		db	0CAh,0CBh, 46h, 82h, 83h,0C5h
		db	 76h, 93h,0C4h,0C7h,0CAh,0C7h
		db	 84h,0C4h, 76h, 85h,0C4h,0C7h
		db	0CAh, 46h, 85h,0C4h, 46h,0CCh
		db	0C7h, 82h, 83h,0C4h, 76h, 86h
		db	0C3h,0C7h, 81h, 56h, 87h,0C4h
		db	0CCh,0CBh,0C7h, 84h,0C4h, 56h
		db	0C9h,0C7h, 85h,0C4h, 46h,0CCh
		db	 86h,0C4h, 56h, 83h, 83h,0C4h
		db	0C7h,0C9h,0CCh,0C7h,0C8h, 86h
		db	0C4h,0C7h,0CAh,0CCh, 46h, 87h
		db	0C4h,0C9h,0CCh,0C7h, 84h,0C4h
		db	 05h, 07h, 84h,0C5h, 56h, 86h
		db	0C4h, 46h, 84h, 83h,0C4h, 66h
		db	 87h,0C5h, 46h,0C9h,0CCh, 46h
		db	 86h,0C4h, 56h, 84h,0C4h,0CAh
		db	0CCh, 66h, 03h, 12h,0C4h, 46h
		db	0CAh, 86h,0C5h, 66h, 82h, 83h
		db	0C4h, 66h, 87h,0C5h, 56h,0CBh
		db	 46h, 86h,0C4h,0CAh,0CCh,0C7h
		db	 84h,0C4h,0C7h,0C9h,0CCh, 56h
		db	 03h, 12h,0C4h, 56h, 86h,0C4h
		db	0C7h,0CAh,0CCh, 83h, 83h,0C4h
		db	 56h, 88h,0C4h, 66h,0CCh, 87h
		db	0C4h, 46h,0CBh, 84h,0C4h,0CAh
		db	0CCh,0C7h,0CCh, 46h, 03h, 12h
		db	0C4h, 66h, 85h,0C5h, 66h, 82h
		db	 83h,0C4h, 46h,0C9h,0C8h, 87h
		db	0C4h, 05h, 07h, 86h,0C6h,0C7h
		db	 81h,0C7h, 84h,0C4h, 66h,0CBh
		db	0C7h, 03h, 12h,0C5h, 46h,0C9h
		db	0C7h, 85h,0C4h, 66h, 82h, 83h
		db	0C4h, 56h,0C8h, 87h,0C4h,0C7h
		db	0C9h, 66h, 8Eh,0C5h, 46h,0CAh
		db	0CCh, 46h, 03h, 12h,0C4h,0C7h
		db	0CCh, 46h, 85h,0C4h,0CAh, 56h
		db	 82h, 83h,0C4h,0CAh,0CCh, 46h
		db	 87h,0C4h, 05h, 07h, 8Eh,0C4h
		db	 46h,0C9h,0C7h,0CCh,0C7h, 84h
		db	0C4h,0C9h,0CAh,0CCh,0C7h, 85h
		db	0C4h, 66h, 82h, 83h,0C4h,0C7h
		db	0CAh, 46h, 87h,0C4h,0CAh,0CCh
		db	0CAh,0CBh, 56h, 8Dh,0C5h, 56h
		db	0CCh,0CBh, 85h,0C4h, 46h,0CBh
		db	0C7h, 85h,0C4h, 66h, 82h, 83h
		db	0C4h,0C7h,0C9h,0CCh,0C7h, 87h
		db	0C4h,0C9h,0C7h,0CCh,0C7h,0C9h
		db	 76h, 81h, 46h, 87h,0C5h,0C7h
		db	0CAh, 56h, 85h,0C4h,0C7h,0CCh
		db	0C7h,0CBh, 85h,0C4h,0C7h,0C9h
		db	0CCh,0C7h, 82h, 83h,0C5h, 46h
		db	 4Ah, 87h,0C4h, 08h, 07h,0CAh
		db	0CCh, 56h, 86h,0C4h, 76h, 85h
		db	0C4h, 56h, 86h,0C4h, 56h,0CBh
		db	 82h, 83h,0C5h, 66h, 87h,0C4h
		db	0C7h,0CAh,0CCh, 56h,0CAh,0CCh
		db	0C7h,0CBh,0C7h,0CCh, 46h, 86h
		db	0C4h,0C7h,0C9h, 56h, 85h,0C4h
		db	 66h, 85h,0C4h, 46h,0C9h,0C7h
		db	 82h, 83h,0C5h,0C7h,0CAh, 4Bh
		db	 87h,0C5h, 56h,0CCh, 56h,0CAh
		db	0CCh, 56h,0CBh, 87h,0C4h, 66h
		db	 86h,0C4h, 46h, 87h,0C5h, 66h
		db	 82h, 83h,0C4h, 66h, 87h,0C4h
		db	0C7h,0C9h, 0Ah, 07h, 87h,0C4h
		db	 66h, 86h,0C4h, 46h, 87h,0C4h
		db	 66h, 82h, 83h,0C5h, 56h, 88h
		db	0C4h, 56h,0CBh, 66h, 4Bh,0C7h
		db	0C9h,0C7h, 87h,0C4h,0CAh,0CCh
		db	0C7h, 87h,0C4h,0C7h,0CBh,0CAh
		db	0C9h,0C7h, 84h,0C4h,0C7h,0CCh
		db	 46h, 82h, 83h,0C4h,0C7h,0CAh
		db	 46h, 87h,0C6h, 46h, 83h,0C4h
		db	0C7h,0CAh,0CCh,0C7h,0CCh,0C7h
		db	 88h,0C4h,0C7h,0CCh,0CBh, 87h
		db	0C5h, 46h,0CCh,0C7h,0CCh,0C7h
		db	 81h, 76h,0CBh,0C7h, 82h, 83h
		db	0C4h,0C7h,0C9h, 46h, 8Dh,0C5h
		db	 76h,0CBh, 88h,0C5h,0C7h,0C9h
		db	0CCh, 87h,0C4h,0CAh,0C9h, 56h
		db	0CCh, 07h, 07h, 82h, 83h,0C4h
		db	 66h, 40h, 41h,0C1h, 41h, 40h
		db	 41h,0C1h, 81h,0C4h,0C7h,0C9h
		db	 46h, 8Ah,0C4h, 56h, 87h,0C5h
		db	 56h,0CAh,0C9h, 66h,0C9h, 66h
		db	 82h, 83h,0C4h, 56h,0C8h, 8Dh
		db	0C4h,0CAh, 56h, 8Ah,0C4h,0CAh
		db	0CCh,0C7h, 87h,0C4h, 66h,0CAh
		db	0CCh,0C7h,0CBh,0C7h,0C9h, 46h
		db	0C9h,0C7h, 82h, 83h,0C4h, 56h
		db	0C8h, 8Dh,0C4h,0C7h,0CCh,0CAh
		db	0C7h, 8Ah,0C4h,0C7h,0CCh, 88h
		db	0C4h,0C7h,0CCh, 56h,0C8h,0CBh
		db	 66h,0C9h,0CAh, 83h, 83h,0C4h
		db	 66h, 8Dh,0C4h, 46h,0CCh,0C7h
		db	 8Ah,0C4h,0C9h,0C7h,0CBh, 87h
		db	0C4h, 46h,0CAh,0C7h,0C9h, 56h
		db	 81h,0C7h,0CBh, 56h, 82h, 83h
		db	0C4h,0CAh,0CCh,0C9h,0C7h, 8Dh
		db	0C4h,0C7h,0CBh,0C7h,0CBh, 8Ah
		db	0C4h,0CCh,0CAh,0C7h, 87h,0C6h
		db	 56h, 81h, 46h, 82h, 46h,0CAh
		db	0CCh, 46h, 82h, 83h,0C4h,0C7h
		db	0CAh,0CCh,0C7h, 8Dh,0C5h, 66h
		db	 8Ah,0C4h, 56h, 91h,0C4h, 66h
		db	 82h, 83h,0C5h,0C7h,0CCh,0C9h
		db	0CBh, 8Dh,0C4h,0CAh,0CCh,0C9h
		db	0C7h, 8Ah,0C5h,0C7h,0CCh,0C2h
		db	 40h, 51h,0C1h, 41h,0C1h,0C2h
		db	 50h, 51h, 81h,0C5h, 56h, 83h
		db	 83h,0C4h,0C7h,0CAh,0CBh,0C7h
		db	 8Dh,0C4h,0C7h,0CCh, 46h, 8Ah
		db	0C5h,0CAh,0CBh, 92h,0C4h, 56h
		db	 83h, 83h,0C4h, 46h, 4Bh, 8Dh
		db	0C4h,0CCh,0CAh,0CCh,0C7h, 8Ah
		db	0C4h,0CCh,0C7h, 8Ah,0C3h, 87h
		db	0C6h, 81h,0C7h, 84h, 83h,0C4h
		db	 66h, 85h,0C3h, 81h,0C7h, 85h
		db	0C4h, 46h,0CCh,0C7h, 8Ah,0C4h
		db	0C9h,0C7h, 8Ah,0C4h,0C7h, 8Dh
		db	 83h,0C4h, 66h, 85h,0C4h,0CAh
		db	0CBh,0C9h, 84h,0C5h, 56h,0CBh
		db	 8Ah,0C4h,0C7h, 8Bh,0C5h, 56h
		db	 8Bh, 83h,0C4h,0C9h,0CAh, 46h
		db	 85h,0C4h, 56h, 84h,0C5h,0C7h
		db	0C9h, 46h, 8Ah,0C6h, 8Ch,0C4h
		db	0C7h,0C9h,0C7h, 8Bh, 83h,0C4h
		db	0C7h,0CAh,0CCh,0C7h, 85h,0C4h
		db	0CCh, 46h, 84h,0C4h,0CCh, 56h
		db	 97h,0C4h,0CCh, 46h, 8Bh, 83h
		db	0C4h, 66h, 85h,0C4h,0CAh,0CBh
		db	0C7h, 84h,0C4h,0CAh,0CBh,0CCh
		db	 98h,0C4h,0C7h,0CCh,0C8h, 8Bh
		db	 83h,0C4h, 56h,0C8h, 85h,0C5h
		db	 46h, 85h,0C4h, 46h,0CCh,0C7h
		db	 97h,0C5h,0C7h,0CCh,0CBh, 8Bh
		db	 83h,0C4h, 66h, 85h,0C4h,0CCh
		db	0C7h, 85h,0C4h,0C9h, 46h,0CBh
		db	 97h,0C4h,0CAh, 46h, 8Bh, 83h
		db	0C5h, 56h,0C8h, 85h,0C4h,0C7h
		db	0CCh, 84h,0C3h,0CAh,0C7h, 9Ah
		db	0C4h, 46h,0C8h, 8Bh, 83h,0C4h
		db	0CAh,0CCh, 46h, 85h,0C4h,0CAh
		db	0C7h, 84h,0C4h,0C7h, 9Ah,0C3h
		db	 56h, 8Ch, 83h,0C5h,0C7h,0C9h
		db	0CCh,0C7h, 85h,0C4h, 46h, 84h
		db	0C4h, 46h, 51h, 40h, 41h,0C1h
		db	 41h, 40h, 41h, 8Bh,0C4h, 76h
		db	 8Ah, 83h,0C4h, 66h, 85h,0C5h
		db	 46h, 84h,0C5h,0CAh, 9Ah,0C4h
		db	0CAh,0CCh, 66h, 89h, 83h,0C4h
		db	 46h,0CCh,0C7h, 85h,0C5h,0C7h
		db	0C9h, 84h,0C4h,0CAh,0CBh, 85h
		db	0C3h, 93h,0C4h,0CAh,0C7h,0C9h
		db	0CCh, 56h, 88h, 83h,0C4h,0C7h
		db	0CAh, 4Bh, 85h,0C4h, 46h, 84h
		db	0C6h,0C9h,0C7h, 85h,0C4h,0C7h
		db	 81h,0C7h, 90h,0C5h, 46h,0CAh
		db	0C9h,0CCh, 56h, 87h, 83h,0C4h
		db	 46h,0C9h,0CBh, 85h,0C4h, 46h
		db	 85h,0C4h, 46h, 84h,0C4h, 66h
		db	 8Fh,0C5h, 66h,0CCh,0CBh,0C8h
		db	 88h, 83h,0C5h, 66h, 85h,0C4h
		db	0CAh,0C7h, 85h,0C4h,0CAh,0CCh
		db	 84h,0C4h,0CAh,0C9h,0C7h,0C8h
		db	 8Fh,0C4h,0C9h,0CCh, 56h, 8Ah
		db	 83h,0C4h, 66h, 85h,0C4h, 4Bh
		db	0C7h, 84h,0C5h, 46h, 84h,0C4h
		db	 4Bh,0C7h, 90h,0C4h, 46h,0CBh
		db	0C8h, 8Bh, 83h,0C4h, 46h,0CAh
		db	0C7h, 85h,0C4h,0C9h,0CCh,0C7h
		db	 84h,0C4h, 46h, 84h,0C4h,0C7h
		db	0CBh, 46h, 8Fh,0C4h, 81h, 46h
		db	 8Ch, 83h,0C4h, 56h,0C8h, 85h
		db	0C5h, 46h, 85h,0C4h,0CCh,0C7h
		db	 84h,0C5h, 46h,0CCh, 46h, 84h
		db	0C3h, 89h,0C4h, 56h, 84h,0C3h
		db	 87h, 83h,0C4h, 56h,0C8h, 85h
		db	0C4h, 56h, 84h,0C4h,0C7h,0CCh
		db	 84h,0C5h,0CAh,0CCh, 46h, 85h
		db	0C4h,0C7h, 88h,0C4h,0CAh,0C7h
		db	0C8h, 84h,0C4h, 56h, 84h, 83h
		db	0C4h,0C9h,0CAh, 46h, 85h,0C5h
		db	0CCh,0CAh, 85h,0C4h,0C9h,0C7h
		db	 84h,0C4h, 46h,0CCh,0C8h, 85h
		db	0C5h,0C9h,0C8h, 87h,0C4h,0CCh
		db	 86h,0C4h, 46h,0C9h,0C7h,0C8h
		db	 82h, 83h,0C4h,0CAh,0CCh, 46h
		db	 85h,0C4h,0C9h,0CCh,0C7h, 84h
		db	0C4h,0C7h,0CBh, 84h,0C4h,0C7h
		db	0C9h,0CBh,0C7h, 85h,0C4h,0C7h
		db	 88h,0C5h,0C7h, 84h,0C3h, 46h
		db	0CAh,0CCh, 56h, 82h, 83h,0C4h
		db	0C7h,0CAh,0CCh,0C7h, 85h,0C4h
		db	 56h, 84h,0C4h, 46h, 84h,0C4h
		db	 66h, 85h,0C6h,0CAh, 88h,0C4h
		db	0C7h, 84h,0C5h,0CAh,0CBh, 46h
		db	0CCh, 47h, 82h, 83h,0C5h,0C7h
		db	0CCh,0C9h,0CCh, 85h,0C6h, 81h
		db	 46h, 84h,0C6h, 81h,0C7h, 84h
		db	0C4h,0CCh, 46h, 90h,0C4h,0C9h
		db	 84h,0C6h, 46h,0C9h,0C7h,0CBh
		db	 84h, 83h,0C5h, 56h,0CCh, 94h
		db	0C4h, 56h, 90h,0C4h,0C9h,0C8h
		db	 8Dh, 83h,0C4h, 56h,0CBh, 94h
		db	0C5h, 46h, 41h,0C1h, 41h, 60h
		db	0C2h,0C1h, 86h,0C5h,0C7h, 8Eh
		db	 83h,0C4h, 66h, 94h,0C4h,0CAh
		db	0CCh, 91h,0C4h,0C7h,0C8h, 8Dh
		db	 81h, 06h, 07h, 94h,0C4h, 46h
		db	 85h,0C3h,0C7h, 8Ah,0C5h,0C7h
		db	0C8h, 83h,0C3h, 46h, 81h, 46h
		db	0C8h, 81h,0C7h, 81h,0CBh,0CCh
		db	 76h,0C8h, 94h,0C4h,0C9h, 4Bh
		db	 84h,0C5h,0CAh,0C7h, 89h,0C5h
		db	0C7h, 84h,0C4h,0CAh, 46h,0CAh
		db	0CCh, 66h,0CAh, 4Bh,0C7h, 49h
		db	 46h, 94h,0C4h,0C7h,0CAh,0CCh
		db	 84h,0C4h,0C7h,0C8h, 89h,0C4h
		db	0C7h, 84h,0C5h, 76h,0CBh, 56h
		db	 76h, 4Bh,0C7h, 94h,0C4h, 46h
		db	0CBh, 84h,0C6h,0C9h, 83h,0C3h
		db	 86h,0C4h,0CAh, 84h,0C4h, 46h
		db	0C9h, 46h, 4Bh,0C9h,0C7h,0CCh
		db	 66h,0C9h, 46h, 94h,0C5h, 46h
		db	0C8h, 89h,0C5h,0C7h, 82h, 56h
		db	0C9h,0C7h,0C8h, 83h,0C5h,0C9h
		db	0CCh, 56h,0C9h, 46h,0CAh, 03h
		db	 00h, 36h, 37h, 00h, 16h, 50h
		db	 00h, 39h, 8Dh, 00h, 1Ch, 9Eh
		db	 00h, 0Dh,0B8h, 00h, 02h,0B8h
		db	 00h, 0Dh,0FFh,0FFh,0FFh,0FFh
		db	 0Bh, 80h, 3Bh, 07h, 00h, 0Fh
		db	 00h, 0Fh, 40h, 34h, 0Ah, 00h
		db	 14h, 00h, 16h, 80h,0BBh, 12h
		db	 00h, 1Ah, 00h, 2Dh, 80h, 34h
		db	 28h, 00h, 32h, 00h, 3Ah, 80h
		db	0B4h, 35h, 00h, 3Fh, 00h,0A3h
		db	 80h, 2Bh, 9Fh, 00h,0A7h, 00h
		db	0A4h, 80h, 3Bh,0A1h, 00h,0A7h
		db	 00h,0A9h, 40h,0A6h,0A2h, 00h
		db	0AFh, 00h,0ADh, 80h,0BBh,0AAh
		db	 00h,0B0h, 00h,0AEh, 80h,0ABh
		db	0AAh, 00h,0B2h, 00h,0B9h, 80h
		db	 2Bh,0B5h, 00h,0BDh, 00h,0FFh
		db	0FFh, 14h, 00h, 09h,0C0h, 17h
		db	0FAh, 00h, 1Fh, 00h,0FFh,0FFh
		db	0FFh, 1Ah, 00h, 12h,0C4h, 17h
		db	0A6h, 00h, 1Eh, 00h,0FFh,0FFh
		db	0FFh, 49h, 00h, 19h,0C3h, 18h
		db	 35h, 00h, 11h, 00h,0FFh,0FFh
		db	0FFh, 58h, 00h, 22h,0C4h, 18h
		db	0FAh, 00h, 26h, 00h,0FFh,0FFh
		db	0FFh, 66h, 00h, 35h,0C3h, 17h
		db	 39h, 00h, 0Fh, 00h,0FFh,0FFh
		db	0FFh, 77h, 00h, 18h,0C3h, 18h
		db	 5Fh, 00h, 31h, 00h,0FFh,0FFh
		db	0FFh,0AEh, 00h, 09h,0C2h, 18h
		db	0E3h, 00h, 3Bh, 00h,0FFh,0FFh
		db	0FFh,0FFh,0FFh, 44h, 00h, 08h
		db	 83h,0D3h, 00h,0FFh, 8Eh,0D3h
		db	0FFh,0FFh,0FFh,0FFh, 44h, 00h
		db	 04h, 8Ch,0D4h, 00h, 00h,0FFh
		db	0FFh, 44h, 00h, 02h,0DCh,0D4h
		db	 00h, 00h,0FFh,0FFh, 44h, 00h
		db	 01h, 5Ch,0D5h, 00h, 00h,0FFh
		db	0FFh,0FFh,0FFh, 15h,0AFh, 04h
		db	 11h
		db	'Cavern of Desleal'
		db	 17h, 00h, 07h, 0Eh, 0Eh, 05h
		db	 00h, 01h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 05h, 00h
		db	 01h, 02h, 00h, 16h, 00h, 26h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 16h, 00h, 26h, 03h
		db	 00h, 19h, 00h, 01h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 19h, 00h, 01h, 03h, 00h, 1Ah
		db	 00h, 30h,0FFh, 76h, 00h, 00h
		db	 20h, 00h, 00h, 00h, 44h, 00h
		db	 08h, 00h, 00h, 22h, 00h, 26h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 22h, 00h, 26h, 03h
		db	 00h, 29h, 00h, 1Bh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 29h, 00h, 1Bh, 02h, 00h, 2Eh
		db	 00h, 14h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 2Eh, 00h
		db	 14h, 02h, 00h, 32h, 00h, 1Bh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 32h, 00h, 1Bh, 02h
		db	 00h, 3Ch, 00h, 03h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 3Ch, 00h, 03h, 03h, 00h, 3Ch
		db	 00h, 0Ah,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 3Ch, 00h
		db	 0Ah, 00h, 00h, 3Ch, 00h, 0Ch
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 3Ch, 00h, 0Ch, 01h
		db	 00h, 47h, 00h, 14h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 47h, 00h, 14h, 04h, 00h, 49h
		db	 00h, 35h,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 49h, 00h
		db	 35h, 00h, 00h, 49h, 00h, 37h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 49h, 00h, 37h, 01h
		db	 00h, 4Dh, 00h, 24h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 4Dh, 00h, 24h, 03h, 00h, 56h
		db	 00h, 1Bh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 56h, 00h
		db	 1Bh, 03h, 00h, 5Eh, 00h, 2Dh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 5Eh, 00h, 2Dh, 03h
		db	 00h, 6Ah, 00h, 2Dh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 6Ah, 00h, 2Dh, 03h, 00h, 6Ch
		db	 00h, 0Bh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 6Ch, 00h
		db	 0Bh, 03h, 00h, 6Fh, 00h, 06h
		db	0FFh,0D0h, 00h, 00h, 20h, 00h
		db	 19h, 00h, 44h, 00h, 04h, 00h
		db	 00h, 70h, 00h, 22h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 70h, 00h, 22h, 03h, 00h, 74h
		db	 00h, 0Bh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 74h, 00h
		db	 0Bh, 03h, 00h, 75h, 00h, 01h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 75h, 00h, 01h, 02h
		db	 00h, 76h, 00h, 22h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 76h, 00h, 22h, 03h, 00h, 7Ch
		db	 00h, 1Eh,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 19h, 00h, 44h, 00h
		db	 02h, 00h, 00h, 80h, 00h, 1Ah
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 80h, 00h, 1Ah, 02h
		db	 00h, 89h, 00h, 01h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 89h, 00h, 01h, 02h, 00h, 8Ah
		db	 00h, 1Ah,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 8Ah, 00h
		db	 1Ah, 02h, 00h, 8Ch, 00h, 0Dh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 8Ch, 00h, 0Dh, 03h
		db	 00h, 8Dh, 00h, 37h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 8Dh, 00h, 37h, 03h, 00h, 90h
		db	 00h, 0Dh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 90h, 00h
		db	 0Dh, 03h, 00h, 91h, 00h, 22h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 91h, 00h, 22h, 03h
		db	 00h, 93h, 00h, 32h,0FFh,0D0h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 44h, 00h, 01h, 00h, 00h, 9Dh
		db	 00h, 01h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 9Dh, 00h
		db	 01h, 02h, 00h, 9Dh, 00h, 13h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 9Dh, 00h, 13h, 02h
		db	 00h,0AFh, 00h, 2Eh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0AFh, 00h, 2Eh, 03h, 00h,0B1h
		db	 00h, 01h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B1h, 00h
		db	 01h, 02h, 00h,0B7h, 00h, 2Eh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0B7h, 00h, 2Eh, 03h
		db	 00h,0BAh, 00h, 1Ah,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0BAh, 00h, 1Ah, 03h, 00h,0FFh
		db	0FFh

_345MP82	endp

seg_a		ends



		end	start
