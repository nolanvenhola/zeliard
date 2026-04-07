
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_340MP72                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	18D1h			;*
data_2e		equ	80D1h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_340MP72	proc	far

start:
		lodsb				; String [si] to al
		adc	al,[bx+si]
		add	ds:data_2e[di],dl
		add	[si],dl
		rcl	word ptr ds:data_1e,1	; Rotate thru carry
		rcr	word ptr [bp+si],1	; Rotate thru carry
		rcr	word ptr [bx+si-2Fh],1	; Rotate thru carry
		adc	cx,0D19Ah
		pop	es
		db	0FFh,0FFh,0FFh, 0Ah, 00h, 00h
		db	 14h,0D1h, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 05h
		db	 28h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0CFh,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh,0CFh
		db	0D0h,0D1h, 49h,0DAh, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	 5Eh,0D1h, 49h,0DAh, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CAh
		db	0CBh, 01h, 12h,0CAh, 01h, 13h
		db	0D9h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CAh, 02h, 12h, 49h
		db	0D3h,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CAh,0D2h, 49h
		db	0D3h,0D9h, 88h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h, 59h, 02h, 13h
		db	0D9h, 87h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h, 49h, 01h, 13h,0D9h
		db	 89h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C6h
		db	 03h, 13h,0D9h, 8Ah,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C6h, 02h, 13h, 8Ch
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 96h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 8Ah, 50h,0C2h, 40h, 41h
		db	 50h, 81h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0C3h, 40h
		db	 41h, 70h, 41h, 40h,0C2h, 50h
		db	0C2h, 50h, 81h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0C3h
		db	 50h, 51h, 60h, 8Ch,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 96h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 8Ah
		db	 56h,0D8h, 88h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C4h, 76h,0D8h, 89h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0DAh, 86h,0C4h, 56h, 59h
		db	0DAh, 07h, 28h,0C5h,0D6h,0CBh
		db	 4Eh,0D0h,0D1h, 49h,0DAh, 86h
		db	0C5h,0D6h, 69h,0DAh, 89h,0C5h
		db	0D6h,0CBh, 4Eh,0D0h,0D1h, 49h
		db	0D4h, 86h,0C5h,0D6h, 49h, 48h
		db	0CAh, 46h,0D8h, 05h, 28h,0C5h
		db	0D6h,0CAh, 02h, 12h, 49h,0D3h
		db	0D9h, 86h,0C5h,0D6h,0CAh, 48h
		db	0CAh, 46h,0D8h, 87h,0C5h,0D6h
		db	0CAh, 02h, 12h,0CAh, 01h, 13h
		db	0D9h, 86h,0C5h,0D6h,0CAh,0C9h
		db	0CDh,0D0h,0D1h, 49h,0D4h, 05h
		db	 28h,0C5h,0D6h, 59h, 02h, 13h
		db	0D9h, 87h,0C5h,0D6h,0CBh, 4Ch
		db	0D1h,0C9h,0CAh,0C7h,0DAh, 86h
		db	0C5h,0D6h, 69h,0D3h,0D9h, 88h
		db	0C5h,0D6h,0CBh,0CDh, 4Dh,0D0h
		db	0D1h,0CAh,0DAh, 05h, 28h,0C6h
		db	 03h, 13h,0DAh, 8Ah,0C5h,0D6h
		db	0CBh,0CCh,0CEh, 4Ch,0D1h,0CAh
		db	0D8h, 86h,0C6h, 04h, 13h,0D9h
		db	 89h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 96h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 96h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0C3h
		db	 40h, 41h, 05h, 01h, 41h, 60h
		db	0C2h,0C1h,0C2h, 40h, 81h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0C3h,0C1h, 41h, 05h, 01h
		db	0C2h,0C1h, 41h, 60h,0C2h, 50h
		db	 81h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 96h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 96h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C4h, 76h,0D8h, 89h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 05h, 28h,0C4h, 05h
		db	 07h,0D8h, 88h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h, 69h, 46h,0DBh
		db	 87h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 05h, 28h
		db	0C5h,0D6h, 79h, 46h,0D8h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CAh, 68h,0CAh,0C7h,0D8h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 05h, 28h,0C5h
		db	0D6h,0CAh,0CBh, 4Ch,0D1h, 49h
		db	0DAh, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh, 6Ch,0D1h,0CAh
		db	0DAh, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 05h
		db	 28h,0C5h,0D6h,0CBh,0CDh, 4Dh
		db	0CDh,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 05h, 28h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0DAh, 05h, 28h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 05h, 28h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0DAh, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 05h
		db	 28h,0C5h,0D6h,0CBh,0CFh, 4Dh
		db	0D1h,0CAh,0D3h,0D9h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0CFh,0D0h,0D1h,0CAh,0D3h
		db	0D8h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 05h
		db	 28h,0C5h,0D6h,0CAh,0CBh, 4Eh
		db	0D1h,0CAh,0DAh, 87h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CFh
		db	 01h, 12h, 49h,0DAh, 87h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CAh
		db	 02h, 12h,0CAh,0D3h,0DBh, 87h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CAh,0D2h, 59h,0D3h,0D9h, 87h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	 79h,0DAh, 88h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h, 49h, 02h, 13h
		db	0D9h, 88h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C6h, 05h, 13h,0D9h, 88h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C6h, 02h, 13h
		db	 8Ch,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 96h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 8Ah, 40h, 41h, 50h
		db	0C2h, 50h, 81h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0C3h
		db	 40h, 41h, 70h,0C2h,0C1h,0C2h
		db	 50h, 51h, 50h, 81h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0C3h, 41h, 05h, 01h, 41h, 8Ch
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 96h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 8Ah, 46h,0D8h, 89h,0C5h
		db	0D6h,0CBh,0CFh, 4Dh,0D0h,0D1h
		db	0CAh,0DAh, 05h, 29h,0C4h, 76h
		db	0D8h, 89h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 05h
		db	 28h,0C4h, 56h, 49h,0C7h,0D8h
		db	 88h,0C5h,0D6h,0CAh,0CBh, 4Eh
		db	0D1h,0CAh,0D3h,0D9h, 05h, 29h
		db	0C5h,0D6h, 69h,0C7h,0DAh, 88h
		db	0C5h,0D6h,0CBh, 4Eh,0D0h,0D1h
		db	0CAh,0D3h,0D9h, 05h, 28h,0C5h
		db	0D6h, 49h,0C9h, 49h,0DAh, 88h
		db	0C5h,0D6h,0CAh, 02h, 12h,0CAh
		db	0D3h,0D9h, 06h, 29h,0C5h,0D6h
		db	0CAh, 58h,0CAh, 46h,0D8h, 86h
		db	0C5h,0D6h,0CAh, 03h, 12h,0CAh
		db	0D4h, 06h, 28h,0C5h,0D6h,0CAh
		db	0C9h,0CDh,0D1h,0CAh,0C7h,0D8h
		db	 87h,0C5h,0D6h, 59h, 01h, 13h
		db	0DAh, 07h, 29h,0C5h,0D6h,0CBh
		db	 5Ch,0D1h, 49h,0DAh, 86h,0C5h
		db	0D6h, 05h, 0Ah,0DAh, 06h, 28h
		db	0C5h,0D6h,0CBh,0CDh,0CEh,0CDh
		db	0D1h,0CAh,0C7h,0D4h, 86h,0C6h
		db	 03h, 13h,0D9h, 09h, 29h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D1h, 49h
		db	0D4h, 86h,0C6h, 06h, 13h,0D9h
		db	 06h, 28h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0CDh,0D1h,0CAh,0DAh, 96h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0CDh
		db	0D1h,0CAh,0D4h, 96h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0C3h,0C1h, 41h, 70h,0C2h, 40h
		db	 41h, 50h,0C2h, 60h, 81h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0C3h,0C1h,0C2h, 50h, 41h
		db	 60h, 41h, 50h, 41h, 50h, 81h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 96h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 96h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 05h
		db	 28h,0C4h, 76h,0D8h, 89h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C4h, 76h,0D8h
		db	 89h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 05h, 28h
		db	0C5h,0D6h, 69h, 46h,0D8h, 87h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	 69h, 46h,0DAh, 87h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 05h, 28h,0C5h,0D6h,0CAh
		db	 68h,0CAh,0C7h,0D8h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CAh
		db	 58h, 49h,0C7h,0D8h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 05h, 28h,0C5h,0D6h
		db	0CAh,0CBh, 5Ch,0D1h,0CAh,0DAh
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 05h, 29h
		db	0C5h,0D6h,0CBh, 4Ch,0D0h,0D1h
		db	 49h,0DAh, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 05h, 29h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0DAh, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 05h, 29h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0DAh
		db	 05h, 29h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 05h
		db	 29h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0CFh,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0DAh, 86h,0C5h
		db	0D6h,0CBh,0CCh, 5Eh,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh, 5Eh,0D1h, 49h
		db	0DAh, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CFh, 02h, 12h
		db	 49h,0DAh, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CAh, 02h, 12h
		db	 49h,0D3h,0D9h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CAh,0D2h
		db	 59h, 01h, 13h,0D9h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h, 69h
		db	 01h, 13h,0D9h, 87h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h, 49h, 01h
		db	 13h,0DBh, 89h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C6h, 04h, 13h,0D9h, 89h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C6h, 02h
		db	 13h, 8Ch,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 96h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 8Ah, 8Ch,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0C3h, 40h,0C2h, 40h, 41h
		db	 60h,0C2h, 50h, 51h, 50h, 81h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 8Ah, 8Ch,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 96h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 8Ah, 46h,0D8h, 89h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 05h, 28h,0C4h, 66h,0D8h
		db	 8Ah,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C4h
		db	 56h, 49h, 46h,0D8h, 06h, 28h
		db	0C5h,0D6h,0CBh, 5Eh,0D1h,0CAh
		db	0D3h,0D9h, 05h, 28h,0C5h,0D6h
		db	 59h, 46h,0D8h, 88h,0C5h,0D6h
		db	0CBh, 4Eh,0D0h,0D1h,0CAh,0D3h
		db	0D9h, 86h,0C5h,0D6h, 49h, 48h
		db	 49h,0DAh, 06h, 28h,0C5h,0D6h
		db	0CAh, 02h, 12h,0CAh,0D3h,0D9h
		db	 06h, 28h,0C5h,0D6h,0CAh, 48h
		db	 49h,0DAh, 88h,0C5h,0D6h,0CAh
		db	 02h, 12h, 49h,0DAh, 87h,0C5h
		db	0D6h,0CAh,0C9h, 4Ch,0D1h, 49h
		db	0D8h, 05h, 28h,0C5h,0D6h, 79h
		db	0DAh, 07h, 28h,0C5h,0D6h,0CBh
		db	 4Ch,0D1h,0CAh,0C7h,0D8h, 87h
		db	0C5h,0D6h, 79h,0D3h,0D4h, 87h
		db	0C5h,0D6h,0CBh,0CDh, 4Dh,0D1h
		db	 49h,0D4h, 05h, 28h,0C6h, 05h
		db	 13h,0D9h, 07h, 28h,0C5h,0D6h
		db	0CBh,0CCh,0CEh,0CDh,0D1h,0CAh
		db	0C7h,0D8h, 86h,0C6h, 05h, 13h
		db	0D9h, 88h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0CDh,0D1h,0CAh,0D4h, 05h
		db	 28h,0EAh, 8Fh,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0CDh,0D1h,0CAh,0DAh
		db	 96h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 85h, 01h
		db	 2Ah, 8Fh,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0C3h, 50h
		db	 41h, 50h, 51h, 60h,0C2h, 50h
		db	0C2h,0C1h, 81h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0EAh, 8Fh,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 96h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C4h
		db	 76h,0D8h, 89h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C4h, 76h,0D8h, 89h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h, 69h
		db	 46h,0D8h, 87h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h, 69h,0C7h,0D8h
		db	 88h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CAh, 68h,0CAh,0C7h,0D8h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CAh, 58h,0CAh,0DAh, 88h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CAh,0CBh, 5Ch,0D1h,0CAh,0DAh
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 05h, 28h
		db	0C5h,0D6h,0CAh,0CBh, 4Ch,0D1h
		db	 46h,0D8h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 05h, 28h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0DAh, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 05h, 28h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 05h, 28h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0DAh, 05h
		db	 28h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0DAh, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh,0CEh, 4Eh,0D1h,0CAh,0DAh
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Eh,0D1h,0CAh
		db	0D3h,0D8h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh, 4Eh,0D1h
		db	 49h,0D3h,0D9h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CFh
		db	 01h, 12h,0CAh,0D3h,0D9h, 87h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CAh, 01h, 12h, 59h,0DAh, 87h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0DAh, 86h,0C5h,0D6h
		db	0CAh,0D2h, 59h,0DAh, 88h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h, 69h
		db	 01h, 13h,0D9h, 87h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h, 49h, 02h
		db	 13h,0D9h, 88h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C6h, 04h, 13h,0D9h, 89h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C6h, 02h
		db	 13h, 8Ch,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 96h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 8Ah, 8Ch,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0C3h, 70h,0C2h, 40h,0C2h
		db	 40h, 61h, 50h,0C2h, 40h, 81h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 8Ah, 8Ch,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 96h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 8Ah, 56h,0D8h, 88h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 05h, 29h,0C4h, 05h, 07h
		db	0D8h, 88h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C4h, 56h, 59h,0C7h,0DAh, 87h
		db	0C5h,0D6h,0CBh, 6Eh,0D1h,0CAh
		db	0DAh, 05h, 29h,0C5h,0D6h, 79h
		db	0DAh, 88h,0C5h,0D6h,0CBh, 6Eh
		db	0D1h,0CAh,0DAh, 86h,0C5h,0D6h
		db	 49h, 58h,0CAh,0C7h,0D8h, 86h
		db	0C5h,0D6h,0CAh, 03h, 12h,0CAh
		db	0D3h,0D9h, 05h, 28h,0C5h,0D6h
		db	0CAh, 58h,0CAh,0C7h,0D8h, 87h
		db	0C5h,0D6h,0CAh, 03h, 12h,0CAh
		db	0D3h,0D9h, 86h,0C5h,0D6h,0CAh
		db	0C9h,0CCh, 4Ch,0D1h,0CAh,0DAh
		db	 86h,0C5h,0D6h, 79h,0D3h,0D9h
		db	 06h, 28h,0C5h,0D6h,0CBh, 5Ch
		db	0D1h,0CAh,0D8h, 87h,0C5h,0D6h
		db	 79h,0DBh,0D9h, 87h,0C5h,0D6h
		db	0CAh,0CBh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C6h, 05h, 13h,0D9h
		db	 07h, 28h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D1h,0CAh,0C7h,0D8h, 86h
		db	0C6h, 05h, 13h,0D9h, 88h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 96h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0DAh
		db	 96h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0C3h,0C1h,0C2h
		db	 05h, 01h, 41h, 70h,0C2h, 40h
		db	0C2h, 40h, 81h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0C3h
		db	 40h, 41h, 60h,0C2h, 60h, 41h
		db	 40h,0C2h, 50h, 81h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 96h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 96h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C4h, 05h
		db	 07h,0D8h, 88h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C4h, 76h,0D8h, 08h, 28h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	 79h,0DAh, 88h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h, 69h,0C7h,0D4h
		db	 07h, 28h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CAh, 58h,0CAh,0C7h
		db	0D8h, 87h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CAh, 58h,0CAh, 46h
		db	0D8h, 05h, 28h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 05h, 28h,0C5h,0D6h,0CBh, 5Ch
		db	0D1h,0CAh,0C7h,0D8h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	 4Ch,0D0h,0D1h, 49h,0DAh, 05h
		db	 28h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 05h, 28h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D1h
		db	 49h,0DAh, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0DAh, 05h, 28h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0CDh,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 05h, 28h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 05h, 28h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 86h,0C5h,0D6h
		db	0CBh,0CCh,0CFh,0D0h,0D1h, 49h
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh, 6Eh,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CFh, 01h, 12h
		db	 59h,0DAh, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CAh, 03h, 12h
		db	 49h,0DAh, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CAh,0D2h, 49h
		db	 02h, 13h,0D9h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h, 79h, 01h
		db	 13h,0D9h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h, 49h, 01h, 13h
		db	0DBh, 89h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C6h, 05h, 13h,0D9h, 01h, 28h
		db	 01h, 2Ah, 84h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C6h, 02h, 13h, 8Ch,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h, 0Bh, 2Ah, 84h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 8Ah, 60h,0C2h
		db	 40h, 41h, 40h, 81h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 85h, 0Ch, 2Ah, 84h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0C3h, 40h,0C2h,0C1h,0C2h
		db	 50h, 41h, 8Ch,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h, 0Bh, 2Ah, 84h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 8Ah, 46h,0D8h, 89h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C4h, 76h,0D8h
		db	 02h, 29h, 01h, 2Ah, 84h,0C5h
		db	0D6h,0CBh,0CCh,0CEh, 4Eh,0D1h
		db	0CAh,0DAh, 05h, 29h,0C4h, 56h
		db	 49h,0C7h,0DAh, 88h,0C5h,0D6h
		db	0CBh, 5Eh,0D1h, 49h,0DAh, 86h
		db	0C5h,0D6h, 69h,0C7h,0DAh, 88h
		db	0C5h,0D6h,0CBh, 4Eh,0D1h,0D2h
		db	0CAh,0D3h,0D9h, 05h, 29h,0C5h
		db	0D6h, 49h,0C9h, 49h,0C7h,0D8h
		db	 87h,0C5h,0D6h,0CAh, 02h, 12h
		db	 49h,0D3h,0D9h, 86h,0C5h,0D6h
		db	0CAh, 58h,0CAh,0C7h,0D8h, 87h
		db	0C5h,0D6h,0CAh, 01h, 12h,0CAh
		db	 01h, 13h,0D9h, 06h, 29h,0C5h
		db	0D6h,0CAh,0C9h,0D0h,0D1h,0C9h
		db	0CAh,0C7h,0D8h, 86h,0C5h,0D6h
		db	 79h,0D3h,0D9h, 87h,0C5h,0D6h
		db	0CBh, 5Ch,0D1h,0CAh,0D9h, 87h
		db	0C5h,0D6h, 69h,0DAh, 08h, 29h
		db	0C5h,0D6h,0CBh,0CDh,0CEh, 4Ch
		db	0D1h,0CAh,0DAh, 86h,0C6h, 05h
		db	 13h,0D9h, 88h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D1h,0CAh,0C7h,0D8h
		db	 86h,0C6h, 04h, 13h,0D9h, 08h
		db	 29h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 96h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0CDh,0D1h
		db	0CAh,0D4h, 96h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0C3h
		db	0C1h, 41h, 70h, 41h, 60h,0C2h
		db	0C1h,0C2h, 60h, 81h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0C3h,0C1h, 41h, 05h, 01h,0C2h
		db	 40h,0C2h, 40h, 41h, 60h, 81h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 96h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 96h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 05h
		db	 29h,0C4h, 76h,0D8h, 89h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C4h, 05h, 07h
		db	0D8h, 88h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0DAh, 05h
		db	 29h,0C5h,0D6h, 69h, 46h,0D8h
		db	 87h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h, 79h,0DAh, 88h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 05h, 29h,0C5h,0D6h,0CAh
		db	 58h, 49h,0DAh, 87h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CAh, 58h
		db	0CAh, 46h,0D8h, 86h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 05h, 29h,0C5h,0D6h,0CBh
		db	 5Ch,0D1h,0CAh,0C7h,0D8h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 05h, 29h,0C5h
		db	0D6h,0CBh, 5Ch,0D1h, 49h,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 86h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0DAh, 05h, 29h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 05h, 29h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0CDh,0D1h,0CAh,0D4h
		db	 05h, 29h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 05h, 29h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 05h, 29h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0DAh, 05h, 29h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 86h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 05h, 29h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0DAh, 05h, 29h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 05h, 29h,0C5h,0D6h
		db	0CBh,0CCh, 4Dh,0D0h,0D1h,0CAh
		db	0D4h, 86h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0DAh, 05h
		db	 28h,0C5h,0D6h,0CBh,0CCh, 4Dh
		db	0D0h,0D1h,0CAh,0D4h, 05h, 29h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 05h, 29h,0C5h
		db	0D6h,0CBh,0CCh, 4Dh,0D0h,0D1h
		db	0CAh,0D4h, 86h,0C5h,0D6h,0CBh
		db	0CCh, 4Dh,0D0h,0D1h,0CAh,0D4h
		db	 05h, 28h,0C5h,0D6h,0CBh,0CCh
		db	 4Dh,0D0h,0D1h,0CAh,0D4h, 86h
		db	0C5h,0D6h,0CBh,0CCh, 4Dh,0D0h
		db	0D1h,0CAh,0D4h, 05h, 29h,0C5h
		db	0D6h,0CBh,0CCh,0FFh,0FFh,0FFh
		db	0FFh,0FFh,0FFh, 19h, 00h, 28h
		db	 83h, 13h, 14h, 00h, 09h, 00h
		db	0FFh,0FFh,0FFh, 32h, 00h, 08h
		db	 82h, 12h, 53h, 00h, 01h, 00h
		db	0FFh,0FFh,0FFh, 4Ch, 00h, 08h
		db	 81h, 12h, 5Ch, 00h, 29h, 00h
		db	0FFh,0FFh,0FFh, 65h, 00h, 38h
		db	 81h, 12h,0B0h, 00h, 2Bh, 00h
		db	0FFh,0FFh,0FFh, 7Fh, 00h, 08h
		db	 83h, 12h,0CDh, 00h, 2Dh, 00h
		db	0FFh,0FFh,0FFh,0FFh,0FFh, 35h
		db	 00h, 04h,0DAh,0D1h, 00h,0FFh
		db	0E5h,0D1h,0FFh,0FFh,0FFh,0FFh
		db	 35h, 00h, 02h, 1Ah,0D2h, 00h
		db	0FFh, 25h,0D2h,0FFh,0FFh,0FFh
		db	0FFh, 35h, 00h, 01h, 9Ah,0D2h
		db	 00h,0FFh,0A5h,0D2h,0FFh,0FFh
		db	0FFh,0FFh,0FFh,0FFh, 16h,0AFh
		db	 02h, 10h
		db	'Cavern of Correr'
		db	 15h, 00h, 06h, 0Ch, 0Ch, 02h
		db	 00h, 2Ah,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 02h, 00h
		db	 2Ah, 04h, 00h, 11h, 00h, 1Ah
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 11h, 00h, 1Ah, 04h
		db	 00h, 12h, 00h, 3Ah,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 12h, 00h, 3Ah, 04h, 00h, 18h
		db	 00h, 0Ah,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 18h, 00h
		db	 0Ah, 04h, 00h, 1Ch, 00h, 0Ah
		db	0FFh, 73h, 00h, 00h, 20h, 00h
		db	 19h, 00h, 35h, 00h, 04h, 00h
		db	 00h, 2Bh, 00h, 3Ah,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 2Bh, 00h, 3Ah, 04h, 00h, 2Eh
		db	 00h, 1Ah,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 2Eh, 00h
		db	 1Ah, 04h, 00h, 36h, 00h, 2Ah
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 36h, 00h, 2Ah, 04h
		db	 00h, 3Ah, 00h, 0Ah,0FFh, 73h
		db	 00h, 00h, 20h, 00h, 16h, 00h
		db	 35h, 00h, 02h, 00h, 00h, 46h
		db	 00h, 1Ah,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 46h, 00h
		db	 1Ah, 04h, 00h, 4Bh, 00h, 3Ah
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 4Bh, 00h, 3Ah, 04h
		db	 00h, 4Eh, 00h, 2Ah,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 4Eh, 00h, 2Ah, 04h, 00h, 54h
		db	 00h, 0Ah,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 54h, 00h
		db	 0Ah, 04h, 00h, 66h, 00h, 1Ah
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 66h, 00h, 1Ah, 04h
		db	 00h, 66h, 00h, 2Ah,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 66h, 00h, 2Ah, 04h, 00h, 6Ah
		db	 00h, 0Ah,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 6Ah, 00h
		db	 0Ah, 04h, 00h, 77h, 00h, 3Ah
		db	0FFh, 73h, 00h, 05h, 20h, 00h
		db	 00h, 00h, 35h, 00h, 01h, 00h
		db	 00h,0FFh,0FFh

_340MP72	endp

seg_a		ends



		end	start
