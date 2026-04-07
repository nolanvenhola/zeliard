
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_346MP83                                 лл
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

_346MP83	proc	far

start:
		scasw				; Scan es:[di] for ax
		or	al,0
		add	[bx+si],bh
		int	3			; Debug breakpoint
		add	byte ptr [bx+si],76h	; 'v'
		retf				; Return far
		db	 7Bh,0CBh, 98h,0CBh,0FCh,0CBh
		db	 22h,0CCh, 24h,0CCh, 3Dh,0CCh
		db	 08h,0FFh,0FFh,0FFh, 0Ah, 00h
		db	 00h, 76h,0CBh, 10h, 13h,0C5h
		db	 66h, 89h,0C4h, 66h, 51h, 40h
		db	 51h, 40h, 51h, 87h,0C4h,0C7h
		db	0CCh, 85h, 82h, 09h, 13h, 04h
		db	 12h,0C4h, 56h, 8Ah,0C4h, 4Bh
		db	0C7h, 95h,0C5h, 46h,0C9h, 84h
		db	 82h,0C3h, 83h, 03h, 12h, 01h
		db	 13h, 85h,0C4h,0CAh, 66h, 88h
		db	0C5h,0CAh,0CCh, 46h, 87h,0C3h
		db	 46h, 81h, 46h, 87h,0C4h,0C7h
		db	 4Bh, 84h, 82h,0C4h,0C7h, 82h
		db	 03h, 12h, 01h, 13h, 85h,0C4h
		db	0CCh,0C7h,0CAh,0CCh, 89h,0C5h
		db	 46h,0CCh, 88h,0C5h,0CAh,0CCh
		db	0C9h,0CCh,0C7h, 87h,0C4h, 46h
		db	0CCh, 84h, 82h,0C4h, 46h, 81h
		db	 03h, 12h, 01h, 13h, 85h,0C4h
		db	0CAh, 5Bh, 89h,0C4h, 66h, 87h
		db	0C5h, 46h,0CCh,0CAh,0CBh,0C7h
		db	 86h,0C4h,0CAh,0C7h,0CBh, 84h
		db	 82h,0C4h,0CAh,0C7h, 81h, 03h
		db	 12h, 01h, 13h, 85h,0C4h,0C7h
		db	0C9h,0CCh,0CBh, 89h,0C4h,0C7h
		db	0CAh,0C9h,0C7h, 87h,0C4h,0C7h
		db	0C9h,0C7h,0CCh,0C7h, 87h,0C4h
		db	 46h, 85h, 82h,0C5h, 46h, 81h
		db	 03h, 12h, 01h, 13h, 85h,0C4h
		db	0CAh, 56h, 89h,0C6h, 56h, 88h
		db	0C4h, 56h,0CAh,0C7h, 87h,0C4h
		db	0CCh,0C9h, 85h, 82h,0C4h, 56h
		db	 03h, 12h, 01h, 13h, 85h,0C5h
		db	 76h, 94h,0C4h, 05h, 07h, 86h
		db	0C4h,0C7h,0CCh,0CBh, 84h, 82h
		db	0C4h,0C7h,0C9h,0C7h, 03h, 12h
		db	 01h, 13h, 85h,0C4h, 66h, 95h
		db	0C4h,0C7h,0CAh,0C7h,0C9h, 56h
		db	 85h,0C4h, 46h, 85h, 82h,0C4h
		db	0CCh, 46h, 03h, 12h, 01h, 13h
		db	 85h,0C4h,0C7h,0CAh,0CCh,0C9h
		db	 95h,0C4h, 46h,0CCh, 66h, 85h
		db	0C6h,0C7h,0CAh,0C8h, 84h, 82h
		db	0C4h,0CAh,0C7h, 81h, 03h, 12h
		db	 01h, 13h, 85h,0C4h,0C9h,0C7h
		db	0CCh, 46h, 88h,0C3h,0C7h,0CCh
		db	0C7h, 88h,0C5h,0C7h,0C9h,0CBh
		db	0CCh, 46h, 8Eh,0C2h, 81h,0C4h
		db	0C9h,0CCh,0C7h, 03h, 12h, 01h
		db	 13h, 85h,0C4h,0C7h,0C9h,0C7h
		db	0CCh, 89h,0C4h,0CCh,0C7h,0CBh
		db	 88h,0C4h, 46h,0CCh, 66h, 51h
		db	0C1h, 41h, 40h, 41h, 40h,0C2h
		db	 82h,0C5h,0C7h,0CBh,0C7h, 03h
		db	 12h, 01h, 13h, 85h,0C4h, 46h
		db	 49h,0CBh, 88h,0C4h, 66h, 87h
		db	0C4h, 56h,0CCh, 46h, 8Eh, 82h
		db	0C6h, 46h, 81h, 03h, 12h, 01h
		db	 13h, 85h,0C4h,0C9h,0CBh,0C7h
		db	0CCh, 89h,0C5h, 46h,0CAh,0C7h
		db	 87h,0C4h, 46h, 8Ah,0C3h,0CAh
		db	0CCh, 46h, 83h, 86h, 03h, 12h
		db	 01h, 13h, 85h,0C5h, 76h, 88h
		db	0C5h,0C7h,0C9h,0CBh,0C7h, 87h
		db	0C6h,0C7h, 81h,0C7h, 89h,0C4h
		db	0C7h,0CCh,0C9h, 46h, 82h, 86h
		db	 03h, 12h, 01h, 13h, 85h,0C5h
		db	 66h, 89h,0C4h, 46h,0CAh,0CBh
		db	 94h,0C4h, 46h,0CCh, 46h, 82h
		db	 86h, 03h, 12h, 01h, 13h, 85h
		db	0C4h,0CCh,0C7h, 8Bh,0C4h, 66h
		db	0C1h, 41h, 40h,0C2h, 60h, 8Ah
		db	0C4h,0C7h,0CCh,0CAh,0C7h, 83h
		db	 86h, 03h, 12h, 01h, 13h, 85h
		db	0C4h,0C7h,0C9h, 8Bh,0C4h,0CBh
		db	0CCh, 46h, 94h,0C4h, 56h, 84h
		db	 86h, 03h, 12h, 01h, 13h, 85h
		db	0C4h, 46h, 8Bh,0C5h, 46h, 96h
		db	0C5h, 46h, 81h,0C8h, 83h, 86h
		db	 03h, 12h,0C3h,0C7h, 85h,0C4h
		db	0CAh,0C7h, 8Bh,0C4h,0C7h, 97h
		db	0C5h, 56h, 81h,0C8h, 82h, 86h
		db	 03h, 12h,0C4h,0C7h,0CCh, 84h
		db	0C4h,0C7h,0CBh, 84h,0C3h,0C7h
		db	 85h,0C4h,0C8h, 97h,0C4h, 56h
		db	 81h,0C8h, 82h, 86h, 03h, 12h
		db	0C5h,0C9h,0C7h, 84h,0C6h,0C7h
		db	 85h,0C5h,0C9h,0C7h, 84h,0C4h
		db	0C9h, 97h,0C4h, 46h,0C9h,0C7h
		db	 83h, 86h, 03h, 12h,0C4h,0C7h
		db	 8Ch,0C4h,0CCh,0C7h, 84h,0C6h
		db	0C8h, 97h,0C4h,0C7h,0CAh, 4Bh
		db	0C7h, 82h, 86h, 03h, 12h,0C4h
		db	0CAh, 41h,0C1h, 51h, 40h,0C2h
		db	 40h, 81h,0C4h,0CAh,0CCh, 9Dh
		db	0C4h,0C9h,0CCh,0C7h,0CBh, 83h
		db	 86h, 03h, 12h,0C4h,0C7h,0CBh
		db	 8Bh,0C5h, 46h,0CBh, 9Ch,0C4h
		db	 49h,0CCh,0C7h, 83h, 86h, 03h
		db	 12h,0C4h,0CCh, 85h,0C3h,0C7h
		db	 85h,0C4h, 56h, 92h,0C3h, 81h
		db	0C7h, 87h,0C4h, 66h, 83h, 86h
		db	 03h, 12h,0C4h,0C7h,0CCh, 84h
		db	0C4h,0C9h,0C7h, 84h,0C4h,0CAh
		db	0CCh, 66h, 8Fh,0C4h, 81h, 46h
		db	 86h,0C4h, 46h, 81h,0C8h, 83h
		db	 86h, 03h, 12h,0C5h, 46h, 84h
		db	0C4h, 4Bh, 84h,0C4h,0C7h, 4Bh
		db	 56h,0C9h, 8Eh,0C4h, 46h,0C9h
		db	0C7h, 85h,0C5h, 56h, 84h, 86h
		db	 03h, 12h,0C4h, 46h, 84h,0C5h
		db	0CAh,0CBh, 84h,0C5h, 56h,0CCh
		db	0C9h, 56h, 8Dh,0C4h,0C7h,0CCh
		db	0C7h, 86h,0C4h,0C7h,0C9h, 46h
		db	 83h, 86h, 03h, 12h,0C4h,0C9h
		db	0C7h, 84h,0C4h, 46h, 84h,0C4h
		db	 83h,0C7h,0CAh, 46h, 8Eh,0C5h
		db	0CAh,0C7h,0CCh, 86h,0C4h, 46h
		db	0CCh, 81h,0C8h, 82h, 86h, 03h
		db	 12h,0C6h,0CAh, 85h,0C4h,0C7h
		db	 85h,0C4h, 83h, 46h, 90h,0C4h
		db	 56h, 86h,0C4h, 76h, 82h, 86h
		db	 03h, 12h, 01h, 13h, 85h,0C4h
		db	 46h, 84h,0C6h, 89h,0C3h, 81h
		db	0C7h, 81h, 46h, 86h,0C4h,0C7h
		db	0C9h, 46h, 85h,0C4h, 66h, 83h
		db	 86h, 03h, 12h, 01h, 13h, 85h
		db	0C4h,0C7h, 8Fh,0C4h,0C7h,0C9h
		db	 66h, 85h,0C4h, 56h, 86h,0C4h
		db	 56h, 81h,0C7h, 82h, 86h, 03h
		db	 12h, 01h, 13h, 85h,0C4h,0C7h
		db	 8Fh,0C4h,0C7h,0CAh, 4Bh, 46h
		db	 85h,0C4h,0CAh,0CCh, 87h,0C4h
		db	0CAh,0CCh, 46h, 83h, 86h, 03h
		db	 12h, 01h, 13h, 85h,0C4h, 46h
		db	 8Eh,0C4h,0C9h, 46h,0CCh,0C9h
		db	0C7h, 85h,0C5h,0C7h,0CCh,0CBh
		db	 86h,0C4h,0C7h,0C9h,0CCh, 84h
		db	 86h, 03h, 12h, 01h, 13h, 85h
		db	0C4h,0CAh,0C9h, 8Eh,0C5h, 56h
		db	0CAh,0CCh, 86h,0C4h,0C9h,0C7h
		db	0CCh, 86h,0C5h, 46h,0CCh, 84h
		db	 86h, 03h, 12h, 01h, 13h, 85h
		db	0C4h, 46h,0CCh,0CAh, 8Ch,0C4h
		db	0C7h,0C9h, 46h,0CBh,0C7h, 85h
		db	0C6h, 56h, 86h,0C4h, 46h,0CAh
		db	0CBh, 83h, 86h, 03h, 12h, 01h
		db	 13h, 85h,0C4h, 56h,0C9h,0C7h
		db	 8Bh,0C5h, 76h, 90h,0C4h, 46h
		db	0C9h,0C7h, 83h, 82h,0C3h, 46h
		db	 81h, 03h, 12h, 01h, 13h, 85h
		db	0C4h,0CAh,0CCh,0C7h,0CBh,0CCh
		db	0C8h, 8Ah,0C4h, 05h, 07h, 05h
		db	 01h, 61h, 60h, 81h,0C5h, 76h
		db	 82h, 82h,0C4h,0C7h,0C9h, 8Ch
		db	0C5h,0C7h,0CCh, 46h, 8Ch,0C4h
		db	0C7h,0C9h,0C7h,0CCh,0C7h, 90h
		db	0C4h,0C7h,0CAh,0CCh,0C7h, 83h
		db	 82h,0C5h,0C7h,0CCh, 8Ch,0C4h
		db	0C7h,0CBh,0C9h,0C7h, 8Ch,0C4h
		db	0CAh,0C7h,0CCh,0CAh,0CCh,0C7h
		db	 86h,0C3h, 46h, 86h,0C4h, 46h
		db	 4Ah, 83h, 82h,0C4h,0CAh,0C7h
		db	0CBh, 8Bh,0C5h, 46h,0CBh, 8Dh
		db	0C4h,0CCh, 46h,0C9h,0C7h, 87h
		db	0C4h,0CBh,0CCh,0C7h, 85h,0C4h
		db	 56h, 84h, 81h,0E5h, 66h, 8Bh
		db	0C4h,0C7h,0CCh,0C7h, 8Dh,0C4h
		db	0CAh,0CBh,0C7h,0CCh,0C7h, 87h
		db	0C4h,0C7h,0C9h,0C7h, 85h,0C4h
		db	0C7h,0C8h,0CAh, 84h,0E5h,0C8h
		db	0CAh,0C7h, 8Dh,0C4h,0CCh,0CAh
		db	0C7h, 8Dh,0C5h, 46h,0CAh,0CBh
		db	 46h, 86h,0C4h,0CAh,0CCh,0CBh
		db	 85h,0C5h, 81h, 46h, 84h,0E9h
		db	0E5h,0C7h,0CBh,0C7h, 60h, 61h
		db	 50h, 81h,0C4h,0CAh,0CCh, 84h
		db	0C3h, 89h,0C4h, 56h,0CAh,0C7h
		db	 87h,0C4h, 46h, 86h,0C6h, 81h
		db	0C7h, 84h,0E5h,0E5h, 56h, 8Dh
		db	0C4h, 46h, 84h,0C4h, 89h,0C6h
		db	 81h, 66h, 87h,0C4h,0C7h,0C9h
		db	0C7h, 8Bh,0E5h,0E9h,0E9h,0E5h
		db	 56h, 86h,0C3h,0C7h, 84h,0C4h
		db	0C7h, 85h,0C5h, 96h,0C5h,0CCh
		db	0C7h, 8Ch,0E9h,0E5h,0E5h,0C7h
		db	 4Bh, 87h,0C4h,0CAh, 84h,0C5h
		db	 46h, 84h,0C5h,0C7h, 95h,0C4h
		db	0C7h,0CCh,0C7h, 8Bh,0E5h,0E9h
		db	0E9h,0E5h,0C7h,0C9h, 87h,0C4h
		db	0C7h, 84h,0C6h,0C7h, 85h,0C4h
		db	0CAh,0CCh, 94h,0C4h,0C9h,0CAh
		db	0C7h, 8Bh,0E9h,0E5h,0E5h, 56h
		db	0CBh, 86h,0C4h,0C7h, 8Bh,0C4h
		db	0CCh,0C7h, 94h,0C6h, 46h, 8Ch
		db	0E5h,0E9h,0E9h,0E5h, 56h, 86h
		db	0C5h,0C7h, 8Bh,0C4h,0CBh,0CCh
		db	 46h, 9Bh,0CFh, 85h,0E9h,0E5h
		db	0E5h,0CAh,0CCh, 56h, 85h,0C4h
		db	0C9h,0C7h, 8Ah,0C4h,0CCh,0CAh
		db	0CCh,0C7h,0C1h, 51h, 40h, 41h
		db	 40h, 41h, 8Eh,0CFh,0C7h, 85h
		db	0E5h,0E9h,0E9h,0E5h,0CCh, 46h
		db	 86h,0C5h, 76h, 87h,0C4h, 56h
		db	 9Bh,0C4h,0C7h, 85h,0E9h,0E5h
		db	0E5h, 46h,0CAh,0C9h, 86h,0C4h
		db	0CCh, 56h,0CCh,0C7h, 86h,0C5h
		db	0C7h,0C9h, 9Ch,0D0h,0CAh, 85h
		db	0E5h,0E9h,0C9h,0E5h, 56h, 86h
		db	0C4h,0CAh,0CBh,0C9h, 46h,0CCh
		db	 86h,0C4h,0C7h,0CCh, 9Dh,0D0h
		db	 85h,0E9h,0E5h,0E5h, 46h, 88h
		db	0C4h, 56h,0CAh,0CCh,0CBh, 86h
		db	0C6h, 46h,0A3h,0E5h,0E9h,0E9h
		db	0E5h, 46h, 87h,0C4h,0C7h, 81h
		db	 56h,0CAh,0ACh,0E9h,0E5h,0E5h
		db	0C7h,0C9h, 46h, 86h,0C4h,0C9h
		db	 46h,0CCh, 46h, 40h,0C2h,0C1h
		db	 41h, 40h,0A4h,0E5h,0E9h,0C7h
		db	0E5h,0C7h,0C9h,0C7h, 86h,0C4h
		db	0C7h,0C9h, 46h,0CBh,0ADh,0E9h
		db	0E5h,0E5h,0CBh,0CAh,0CCh, 87h
		db	0C5h,0C7h,0CAh,0CCh,0C9h,0C7h
		db	 86h,0C3h, 46h, 90h,0C3h,0C7h
		db	 81h, 46h, 8Fh,0E5h,0E9h, 46h
		db	0CCh, 46h, 86h,0C4h, 56h,0CCh
		db	0C7h, 86h,0C4h,0CAh,0C9h,0C7h
		db	 8Fh,0C4h, 46h,0CAh, 46h, 8Eh
		db	0E9h,0E5h,0E5h, 46h, 88h,0C6h
		db	 56h, 81h,0CBh, 86h,0C5h,0C7h
		db	0CBh,0C9h, 8Fh,0C4h,0CAh, 4Bh
		db	 46h, 8Eh,0E5h,0E9h,0C7h,0E5h
		db	 95h,0C4h,0C7h,0C9h,0CCh, 8Fh
		db	0C4h, 46h,0C9h,0CCh, 56h, 8Ch
		db	0E9h,0E5h,0E5h,0C9h,0C1h, 51h
		db	 40h, 51h,0C1h,0C2h, 50h,0C2h
		db	 86h,0C4h,0CAh,0CCh,0C7h, 8Fh
		db	0C5h, 56h,0C9h,0C7h, 8Eh,0E5h
		db	0E9h,0C7h,0E5h, 95h,0C4h,0C7h
		db	0C9h,0CBh, 8Fh,0C5h,0C7h,0C9h
		db	0C7h,0CAh,0CCh, 8Eh,0E9h,0E5h
		db	0E5h,0CAh, 8Dh,0C3h, 46h, 85h
		db	0C5h,0CAh,0CCh, 90h,0C4h,0C7h
		db	0CAh,0CCh, 56h, 87h,0CFh, 85h
		db	0E5h,0E9h,0CAh,0E5h,0C7h, 8Ch
		db	0C4h,0CAh,0C9h,0C7h, 84h,0C6h
		db	 46h, 84h,0C3h, 82h,0C7h, 88h
		db	0C4h,0C9h,0CCh,0C7h,0CCh,0C9h
		db	 46h, 85h,0CFh,0C9h, 85h,0E9h
		db	0E5h,0E5h,0C7h,0E5h,0C7h, 8Bh
		db	0C4h,0CAh,0CBh,0CCh, 8Bh,0C4h
		db	0C7h, 81h, 46h, 87h,0C4h, 66h
		db	0CCh,0C7h, 86h,0C4h,0C7h, 85h
		db	0E5h,0E9h,0C7h,0E5h,0CCh,0C7h
		db	 8Bh,0C5h, 46h,0C9h,0C7h, 8Ah
		db	0C4h,0C9h,0C7h,0CCh,0C7h, 87h
		db	0C4h, 66h,0C9h,0C7h, 86h,0D0h
		db	0C7h, 85h,0E9h,0E5h,0E5h,0C7h
		db	0E5h,0CBh, 8Bh,0C4h,0CCh, 46h
		db	0CCh, 8Ah,0C5h, 56h,0CCh,0C7h
		db	 86h,0C5h, 46h,0CAh, 46h, 88h
		db	0D0h, 85h,0E5h,0E9h,0C8h,0E5h
		db	 46h, 8Bh,0C5h,0C9h, 56h, 8Ah
		db	0C4h,0CAh,0C7h,0CCh,0C7h,0CBh
		db	 86h,0C4h,0C7h,0C9h,0C7h,0CCh
		db	0C7h, 8Eh,0E9h,0E5h,0E5h,0C9h
		db	 46h, 8Bh,0C4h,0CAh, 4Bh,0C7h
		db	 8Ah,0C4h,0C7h,0C9h,0CAh,0CBh
		db	0C7h, 86h,0C5h, 46h,0C9h,0C7h
		db	0CCh,0C7h, 8Dh,0E5h,0E9h,0C7h
		db	0E5h,0CCh,0C7h, 8Bh,0C4h, 46h
		db	0CCh,0C9h,0C7h, 89h,0C4h, 46h
		db	0C9h, 46h, 86h,0C4h, 56h,0CCh
		db	0C7h, 8Eh,0E9h,0E5h,0E5h,0C8h
		db	0E5h,0CCh, 8Bh,0C4h,0C9h,0CBh
		db	0CAh, 56h, 88h,0C4h, 66h, 87h
		db	0C6h, 46h,0CAh,0CCh,0C7h, 8Eh
		db	0E5h,0E9h,0E9h,0E5h,0CCh,0CAh
		db	 8Bh,0C5h, 46h,0C9h,0C7h, 8Ah
		db	0C5h,0C7h,0CCh,0CAh,0CCh,0C7h
		db	 9Bh,0E5h,0E5h, 46h,0CCh, 8Bh
		db	0C4h,0CCh, 46h,0CBh,0C7h, 89h
		db	0C4h,0C9h, 66h,0C2h,0C1h, 41h
		db	 70h, 71h,0C1h,0C2h, 60h, 88h
		db	 81h,0E5h, 56h, 8Ah,0C4h,0C7h
		db	0CBh, 46h,0C9h, 89h,0C5h, 46h
		db	0CCh,0CAh,0CCh, 9Ch, 82h,0C4h
		db	 46h, 85h,0C3h, 46h, 81h, 46h
		db	0C9h,0CBh, 66h, 88h,0C6h, 56h
		db	0CCh,0C7h, 8Ch,0C3h, 81h, 56h
		db	 81h, 05h, 07h, 84h, 82h,0C4h
		db	0C7h,0CAh, 85h,0C4h, 46h,0CAh
		db	 46h,0CAh,0C7h, 82h, 03h, 11h
		db	 05h, 12h, 04h, 13h, 8Dh,0C4h
		db	 56h,0CAh, 4Bh,0C7h,0CAh,0CCh
		db	 46h, 84h, 82h,0C4h, 56h, 84h
		db	0C5h,0C7h,0C9h, 46h,0C9h,0C7h
		db	 83h, 03h, 11h, 05h, 12h, 04h
		db	 13h, 8Dh,0C4h, 46h,0C9h,0C7h
		db	0C9h, 56h,0CAh,0CBh, 85h, 82h
		db	0C5h,0C9h,0CCh, 85h,0C4h, 46h
		db	0CCh, 46h, 84h, 01h, 11h, 0Ch
		db	 13h, 8Dh,0C4h,0CAh, 66h,0CAh
		db	0C9h,0CCh, 46h,0CCh, 84h, 82h
		db	0C4h, 4Bh, 85h,0C4h,0CAh, 46h
		db	0CCh,0C7h, 84h, 01h, 11h, 0Ch
		db	 13h, 8Dh,0C5h,0CCh,0CAh, 56h
		db	0CCh, 81h,0C7h,0C9h,0C7h,0CBh
		db	 84h, 82h,0C4h,0C7h,0CBh,0CAh
		db	 84h,0C4h, 46h,0C9h,0C7h,0CBh
		db	 8Ah,0C3h,0C7h,0CAh,0CCh, 46h
		db	 90h,0C5h,0C7h,0CCh, 56h,0C9h
		db	0CCh, 66h, 84h, 82h,0C4h, 46h
		db	0CCh, 84h,0C5h,0CAh,0CCh,0C7h
		db	 8Ch,0C5h, 56h,0CCh,0C7h, 90h
		db	0C4h,0CAh,0C7h,0CCh, 46h,0C9h
		db	 46h, 87h, 82h,0C4h,0C7h, 81h
		db	0C7h, 84h,0C5h, 46h,0CCh, 8Ch
		db	0C4h,0C7h,0C9h, 46h,0CCh,0C7h
		db	 8Fh,0C6h,0C7h, 81h, 56h, 8Ah
		db	 82h,0C4h, 46h, 85h,0C4h,0C9h
		db	 56h, 8Bh,0C4h,0C7h,0CAh,0CCh
		db	0CBh, 46h, 9Fh, 82h,0C4h,0CBh
		db	 86h,0C4h, 46h,0CAh, 46h, 8Ah
		db	0C4h,0C9h, 46h,0CAh,0CCh,0C7h
		db	 9Fh, 82h,0C4h,0CAh,0CCh, 85h
		db	0C4h, 46h,0CCh,0C7h, 8Bh,0C4h
		db	 76h, 90h,0C3h, 81h, 46h, 8Ch
		db	 82h,0C4h,0C7h, 86h,0C4h, 56h
		db	0CCh, 8Bh,0C4h, 66h, 87h,0C3h
		db	0CAh,0C7h, 87h,0C4h,0CAh,0CCh
		db	 46h, 8Bh, 82h,0C5h, 56h, 84h
		db	0C4h, 66h, 8Bh,0C5h, 46h,0CCh
		db	0CBh,0CCh,0C7h, 85h,0C4h,0C7h
		db	0CAh,0C7h, 86h,0C4h,0C7h,0CAh
		db	 4Bh, 8Bh, 82h,0C4h, 46h, 85h
		db	0C4h, 05h, 07h, 89h,0C4h, 46h
		db	0CAh,0CCh,0C7h, 86h,0C4h,0C7h
		db	0CCh, 46h, 85h,0C5h,0C7h,0CCh
		db	0C9h,0C7h, 8Bh, 82h,0C5h,0C7h
		db	 86h,0C5h,0C7h,0C9h,0CCh,0C7h
		db	 8Bh,0C4h, 05h, 07h, 85h,0C5h
		db	0CCh,0C9h,0CCh,0C7h, 85h,0C4h
		db	 56h, 8Ch,0C2h, 81h,0C4h,0C7h
		db	0CCh,0C7h, 84h,0C4h,0CAh,0CCh
		db	0C7h,0CBh, 8Bh,0C4h,0C7h,0C9h
		db	0C7h,0CAh,0CCh,0C7h, 85h,0C5h
		db	 56h,0CBh, 85h,0C4h, 76h,0C2h
		db	0C1h, 51h, 40h, 41h,0C1h, 82h
		db	0C4h,0CCh,0C9h, 81h, 03h, 11h
		db	0C4h, 46h, 8Dh,0C4h, 05h, 07h
		db	 85h,0C4h, 56h,0C9h, 85h,0C4h
		db	0C9h,0CCh, 46h, 8Bh, 82h,0C4h
		db	 46h, 81h, 03h, 11h,0C4h,0C7h
		db	 8Eh,0C5h, 56h,0CCh,0C9h,0CBh
		db	 85h,0C4h,0CCh,0C7h,0CAh, 81h
		db	0C7h, 03h, 11h,0C4h,0CAh,0CBh
		db	 46h, 86h,0C3h, 46h, 82h, 82h
		db	0C4h,0C7h, 82h, 03h, 11h,0C4h
		db	0CAh, 40h, 41h, 50h, 61h, 40h
		db	 81h,0C5h, 46h,0C9h,0CCh, 46h
		db	 85h,0C4h,0CAh,0CBh, 46h, 81h
		db	 03h, 11h,0C5h, 46h,0CCh, 81h
		db	0C7h, 85h,0C4h,0C7h, 83h, 82h
		db	0C6h, 81h,0C7h, 81h, 03h, 11h
		db	0C4h,0C7h, 8Eh,0C4h,0C7h,0CAh
		db	0CCh,0CBh, 46h, 85h,0C4h, 76h
		db	 03h, 11h,0C4h,0C7h,0C9h,0C7h
		db	0CCh, 86h,0C4h,0C9h,0C7h, 82h
		db	 86h, 03h, 11h,0C5h, 46h, 84h
		db	0C3h,0C7h,0C9h,0C7h, 85h,0C4h
		db	0C7h, 81h, 46h,0CBh,0C7h, 85h
		db	0C4h, 76h, 03h, 11h,0C5h, 46h
		db	0C9h,0C7h, 86h,0C4h, 46h, 82h
		db	 86h, 03h, 11h,0C4h,0CCh,0C7h
		db	 84h,0C4h, 46h,0CCh, 85h,0C6h
		db	 82h, 56h, 86h,0C5h, 46h,0CCh
		db	0C7h, 81h, 03h, 11h,0C4h,0CAh
		db	0CCh, 46h, 86h,0C4h,0C7h,0CAh
		db	0C7h, 81h, 86h, 03h, 11h,0C4h
		db	0C9h,0CCh, 84h,0C4h, 56h, 91h
		db	0C4h, 56h,0CCh, 85h,0C4h,0CCh
		db	0C9h, 46h, 86h,0C4h,0CCh,0C9h
		db	0C7h, 81h, 86h, 03h, 11h,0C6h
		db	0C7h, 85h,0C4h,0CAh,0CCh,0CBh
		db	 91h,0C4h,0CCh,0C9h, 46h, 85h
		db	0C6h, 81h, 46h, 87h,0C4h,0C7h
		db	0CCh,0C7h,0C8h,0C7h, 85h, 03h
		db	 11h, 01h, 13h, 85h,0C4h, 46h
		db	0CCh,0C7h, 90h,0C4h, 56h, 91h
		db	0C5h,0CAh,0CBh, 46h, 86h, 03h
		db	 11h, 01h, 13h, 85h,0C4h, 66h
		db	 90h,0C4h, 56h, 41h, 05h, 01h
		db	 61h, 60h, 81h,0C4h,0C7h, 4Bh
		db	0C7h, 86h, 03h, 11h, 01h, 13h
		db	 85h,0C4h, 66h, 90h,0C4h,0CAh
		db	 46h, 91h,0C4h, 46h, 82h, 86h
		db	 03h, 11h, 01h, 13h, 85h,0C5h
		db	 46h,0C9h,0C7h, 90h,0C4h,0CCh
		db	0CBh,0C7h, 85h,0C3h, 81h, 46h
		db	 88h,0C6h,0C7h, 83h, 86h, 03h
		db	 11h, 01h, 13h, 85h,0C5h,0C7h
		db	 4Bh, 85h,0C3h, 82h,0C7h, 88h
		db	0C4h,0C9h,0CAh,0CCh, 85h,0C4h
		db	 46h, 8Eh, 86h, 03h, 11h, 01h
		db	 13h, 85h,0C5h,0C7h,0CAh,0CBh
		db	0C7h, 84h,0C4h,0C7h, 81h, 46h
		db	 87h,0C4h, 56h, 85h,0C4h,0C9h
		db	 46h, 8Dh, 86h, 03h, 11h, 01h
		db	 13h, 85h,0C4h, 56h,0CCh, 84h
		db	0C5h,0CAh,0C7h,0C9h,0C7h, 87h
		db	0C5h, 46h, 86h,0C4h,0C7h,0C9h
		db	 86h, 46h, 86h, 86h, 03h, 11h
		db	 01h, 13h, 85h,0C4h, 56h, 85h
		db	0C4h,0C9h, 4Bh,0C7h, 87h,0C4h
		db	 56h, 85h,0C5h,0CAh,0CCh, 85h
		db	0C3h,0C9h,0C7h, 86h, 86h, 03h
		db	 11h, 01h, 13h, 85h,0C4h,0C9h
		db	 46h, 85h,0C4h, 49h,0CCh,0C7h
		db	 87h,0C4h, 56h, 85h,0C4h, 46h
		db	0CBh, 84h,0C5h,0CCh,0C7h, 86h
		db	 86h, 03h, 11h, 01h, 13h, 85h
		db	0C4h,0C7h,0CAh,0CCh,0C7h, 84h
		db	0C5h, 56h,0CBh, 87h,0C4h,0C7h
		db	0CCh,0C9h,0C7h, 84h,0C5h, 56h
		db	 84h,0C4h,0C7h,0CBh,0C7h, 85h
		db	 86h, 03h, 11h, 01h, 13h, 85h
		db	0C4h, 46h,0CAh,0CCh, 84h,0C4h
		db	0CAh,0C9h,0C7h, 88h,0C4h,0CAh
		db	0CCh,0C7h, 85h,0C4h, 46h, 85h
		db	0C4h, 56h, 85h, 86h, 03h, 11h
		db	 01h, 13h, 85h,0C4h, 46h,0CCh
		db	0CBh, 84h,0C6h, 46h,0CBh,0C7h
		db	 87h,0C4h,0CBh,0C7h,0CCh,0C7h
		db	 84h,0C4h, 46h, 85h,0C4h, 46h
		db	 86h, 86h, 03h, 11h, 01h, 13h
		db	 85h,0C4h, 46h, 92h,0C5h,0C7h
		db	0CCh, 46h, 84h,0C4h, 4Bh, 85h
		db	0C4h,0CBh,0CAh, 86h, 86h, 03h
		db	 11h, 01h, 13h, 85h,0C4h, 56h
		db	 50h, 41h, 40h, 41h,0C1h, 41h
		db	 60h, 81h,0C4h,0C9h, 46h, 85h
		db	0C4h,0CAh,0CCh, 85h,0C6h,0CCh
		db	0CBh, 86h, 86h, 03h, 11h, 01h
		db	 13h, 85h,0C4h,0CAh, 46h, 91h
		db	0C6h, 46h,0CBh, 85h,0C4h,0C9h
		db	0CAh, 8Eh, 86h, 03h, 11h, 01h
		db	 13h, 85h,0C4h,0C7h, 4Bh, 8Ah
		db	0C3h, 46h, 8Dh,0C4h,0C7h,0CCh
		db	0C7h, 8Dh, 86h, 03h, 11h, 01h
		db	 13h, 85h,0C4h, 66h, 89h,0C4h
		db	0C9h,0CCh, 8Dh,0C5h, 56h, 89h
		db	0C3h, 83h, 86h, 03h, 11h, 01h
		db	 13h, 85h,0C4h,0C9h,0C7h, 4Bh
		db	0C7h, 88h,0C4h, 46h,0CBh, 8Ch
		db	0C4h, 46h,0CAh, 89h,0C4h,0C7h
		db	 82h,0CCh, 85h, 03h, 11h, 01h
		db	 13h, 85h,0C4h,0C7h,0CAh,0C7h
		db	0CBh, 89h,0C5h, 56h, 8Ch,0C4h
		db	0C7h,0CCh, 8Ah,0C4h, 46h,0CAh
		db	 4Bh, 84h, 03h, 11h, 01h, 13h
		db	 85h,0C4h, 66h, 89h,0C4h,0C7h
		db	0C9h, 46h, 8Bh,0C6h,0CAh,0C7h
		db	0CBh, 89h,0C4h, 56h, 46h,0CBh
		db	 83h, 03h, 11h, 01h, 13h, 85h
		db	0C5h, 46h,0C9h,0C7h, 89h,0C4h
		db	 56h, 99h,0C5h,0C7h,0C9h,0C7h
		db	 81h,0C4h,0C7h,0C8h,0C7h, 81h
		db	 03h, 11h, 01h, 13h, 85h,0C4h
		db	 66h, 89h,0C5h,0CCh,0CAh, 46h
		db	 41h, 40h, 61h,0C1h,0C2h,0C1h
		db	 51h,0C1h, 89h,0C4h,0C7h, 82h
		db	 81h,0C6h, 46h,0C8h, 81h, 03h
		db	 11h, 01h, 13h, 85h,0C4h,0C7h
		db	0C9h,0C7h,0CCh, 89h,0C4h,0C7h
		db	0CCh,0C7h, 99h,0C6h, 83h, 82h
		db	0C4h, 56h, 03h, 11h, 01h, 13h
		db	 85h,0C4h, 46h,0CCh, 8Ah,0C4h
		db	0CAh, 46h, 9Dh, 82h,0C6h, 81h
		db	 46h, 03h, 11h, 01h, 13h, 04h
		db	 11h,0C4h, 46h,0CAh,0CBh, 89h
		db	0C4h,0CCh, 56h, 94h,0C3h,0C9h
		db	 86h, 82h, 0Eh, 13h,0C5h,0C7h
		db	0C9h,0C7h, 8Ah,0C4h,0C7h,0C9h
		db	 46h, 94h,0C4h,0C7h, 86h, 10h
		db	 13h,0C4h,0C7h,0CCh,0C7h, 8Ah
		db	0C4h, 56h, 95h,0C5h, 46h, 85h
		db	 11h, 00h, 18h,0FFh,0FFh, 07h
		db	 00h, 1Eh, 32h, 00h, 2Eh, 35h
		db	 00h, 2Ch, 38h, 00h, 2Ah, 41h
		db	 00h, 07h, 44h, 00h, 08h, 47h
		db	 00h, 09h, 4Ah, 00h, 0Ah, 7Ch
		db	 00h, 29h,0FFh,0FFh, 13h, 80h
		db	0AFh, 0Dh, 00h, 18h, 00h, 18h
		db	 80h, 84h, 0Eh, 00h, 23h, 00h
		db	 18h, 40h,0A3h, 12h, 00h, 1Dh
		db	 00h, 20h, 80h, 21h, 13h, 00h
		db	 30h, 00h, 25h, 80h, 99h, 1Dh
		db	 00h, 2Ch, 00h, 25h, 40h, 9Bh
		db	 1Dh, 00h, 2Fh, 00h, 32h, 40h
		db	0B9h, 2Bh, 00h, 39h, 00h, 36h
		db	 80h, 9Eh, 34h, 00h, 3Bh, 00h
		db	 3Eh, 40h,0A0h, 3Bh, 00h, 41h
		db	 00h, 43h, 40h,0B9h, 3Ch, 00h
		db	 4Ah, 00h, 50h, 40h, 26h, 4Ch
		db	 00h, 55h, 00h, 65h, 40h, 9Ch
		db	 61h, 00h, 68h, 00h, 6Eh, 40h
		db	0BDh, 68h, 00h, 73h, 00h, 77h
		db	 80h,0BAh, 70h, 00h, 7Ch, 00h
		db	0FFh,0FFh, 06h, 00h, 0Dh,0C2h
		db	 18h,0E4h, 00h, 31h, 00h,0FFh
		db	0FFh,0FFh, 1Dh, 00h, 34h,0C1h
		db	 17h,0B9h, 00h, 01h, 00h,0FFh
		db	0FFh,0FFh, 56h, 00h, 06h,0C2h
		db	 18h,0B3h, 00h, 23h, 00h,0FFh
		db	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 15h,0AFh, 02h, 10h
		db	'Cavern of Falter'
		db	 17h, 00h, 07h, 0Eh, 0Eh, 06h
		db	 00h, 00h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 06h, 00h
		db	 00h, 03h, 00h, 0Ch, 00h, 1Dh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 0Ch, 00h, 1Dh, 03h
		db	 00h, 15h, 00h, 36h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 15h, 00h, 36h, 03h, 00h, 21h
		db	 00h, 0Fh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 21h, 00h
		db	 0Fh, 03h, 00h, 46h, 00h, 0Dh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 46h, 00h, 0Dh, 03h
		db	 00h, 63h, 00h, 24h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 63h, 00h, 24h, 03h, 00h, 71h
		db	 00h, 0Fh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 71h, 00h
		db	 0Fh, 03h, 00h,0FFh,0FFh

_346MP83	endp

seg_a		ends



		end	start
