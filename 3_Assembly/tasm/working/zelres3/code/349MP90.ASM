
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_349MP90                                 лл
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

_349MP90	proc	far

start:
		db	0DCh, 01h, 00h, 00h,0D5h,0C1h
		db	 2Ah, 00h,0B9h,0C1h,0BBh,0C1h
		db	0BDh,0C1h,0BFh,0C1h,0C1h,0C1h
		db	0C3h,0C1h,0DAh,0C1h, 09h,0FFh
		db	0FFh,0FFh, 0Dh, 00h, 00h,0B9h
		db	0C1h,0C1h, 07h, 09h,0C1h, 58h
		db	 81h,0CAh,0CCh,0AEh, 48h,0C2h
		db	 07h, 09h,0C8h, 48h, 82h,0CBh
		db	0CDh,0AEh, 48h,0C3h,0C7h, 48h
		db	 81h,0C9h,0C1h, 48h,0C5h, 81h
		db	0C9h, 82h,0CAh,0CCh,0AEh,0C9h
		db	0C6h,0C4h, 78h,0C2h, 05h, 09h
		db	 81h,0CBh,0CDh,0AEh, 48h,0C5h
		db	0C9h,0C1h, 48h,0C6h,0C3h,0C7h
		db	 81h, 48h,0C1h, 82h,0CAh,0CCh
		db	0AEh, 48h, 48h,0C8h, 58h,0C4h
		db	 81h,0C1h, 82h,0C8h, 82h,0CBh
		db	0CDh,0AEh, 48h,0C9h, 81h,0C5h
		db	 81h,0C9h, 81h,0C5h,0C9h,0C8h
		db	 82h,0C5h, 82h,0CAh,0CCh,0AEh
		db	0C9h,0C1h,0C9h,0C1h, 48h, 81h
		db	0C1h, 82h,0C5h, 81h,0C9h, 83h
		db	0CBh,0CDh,0AEh,0C9h,0C8h,0C9h
		db	0C2h, 81h,0C9h, 81h,0C2h, 81h
		db	0C9h, 86h,0CAh,0CCh,0AEh,0C9h
		db	0C5h,0C6h,0C3h,0C7h, 81h,0C6h
		db	0C3h,0C7h, 87h,0CBh,0CDh,0AEh
		db	 48h, 81h,0C4h, 81h,0C9h, 81h
		db	0C4h, 81h,0C9h, 86h,0CAh,0CCh
		db	0AEh, 48h,0C1h,0C5h,0C9h,0C1h
		db	 81h,0C5h, 88h,0CBh,0CDh,0AEh
		db	 48h,0C2h, 81h,0C9h,0C8h,0C9h
		db	 89h,0CAh,0CCh,0AEh,0C9h, 81h
		db	0C3h,0C7h, 81h,0C5h, 82h,0C9h
		db	 87h,0CBh,0CDh,0AEh,0C9h,0C6h
		db	0C4h, 83h,0C9h, 89h,0CAh,0CCh
		db	0AEh, 48h,0C5h, 58h, 89h,0CEh
		db	0CBh,0CDh,0AEh,0C9h, 81h, 8Dh
		db	0CFh,0CAh,0CCh,0AEh,0C9h,0C1h
		db	 81h,0C9h, 81h,0C9h, 89h,0CFh
		db	0CBh,0CDh,0AEh,0C9h,0C2h,0C7h
		db	 81h,0C9h, 8Ah,0CFh,0CAh,0CCh
		db	0AEh,0C6h,0C3h, 81h,0C1h, 8Bh
		db	0D0h,0CBh,0CDh,0AEh,0C9h,0C4h
		db	 81h,0C8h, 8Bh,0CFh,0CAh,0CCh
		db	0AEh,0C9h,0C5h,0C1h,0C5h, 8Ah
		db	0E2h,0D0h,0CBh,0CDh,0AEh, 48h
		db	0C2h, 8Ah,0DFh,0E3h,0CFh,0CAh
		db	0CCh,0AEh, 48h,0C3h,0C7h, 81h
		db	0C9h, 86h,0DCh,0E0h,0D7h,0CFh
		db	0CBh,0CDh,0AEh,0C9h,0C6h,0C4h
		db	 89h,0DCh,0E1h,0D7h,0D0h,0CAh
		db	0CCh,0AEh, 48h,0C5h,0C9h, 88h
		db	0DCh, 01h, 17h,0D0h,0CBh,0CDh
		db	0AEh, 48h, 84h,0D1h, 85h,0E2h
		db	0D7h,0E4h,0CFh,0CAh,0CCh,0AEh
		db	0C9h, 81h, 81h,0C9h, 82h,0D2h
		db	0D3h, 83h,0DBh,0DEh,0E4h,0E5h
		db	0CFh,0CBh,0CDh,0AEh,0C9h,0C1h
		db	 82h,0D1h, 82h,0D4h,0D5h, 01h
		db	 18h, 01h, 17h,0E4h,0E6h,0D0h
		db	0CAh,0CCh,0AEh,0C9h,0C8h,0C9h
		db	 81h,0D2h,0D3h, 82h,0D6h,0D9h
		db	 01h, 17h,0E4h, 01h, 26h,0CFh
		db	0CBh,0CDh,0AEh,0C9h,0C5h, 83h
		db	0D4h,0D5h, 04h, 17h, 02h, 26h
		db	0D0h,0CAh,0CCh,0AEh, 48h, 8Eh
		db	0CBh,0CDh,0B0h, 8Eh,0CAh,0CCh
		db	0B0h, 8Eh,0CBh,0CDh,0B0h, 8Eh
		db	0CAh,0CCh,0B0h, 8Eh,0CBh,0CDh
		db	0B0h, 8Eh,0CAh,0CCh,0B0h, 8Eh
		db	0CBh,0CDh,0B0h, 8Eh,0CAh,0CCh
		db	0B0h, 8Eh,0CBh,0CDh,0B0h, 8Eh
		db	0CAh,0CCh,0B0h, 8Eh,0CBh,0CDh
		db	0B0h
		db	10 dup (0FFh)
		db	 18h,0AFh, 04h, 0Eh
		db	'Jashiin\s room['
		db	 00h, 08h, 10h, 10h,0FFh,0FFh

_349MP90	endp

seg_a		ends



		end	start
