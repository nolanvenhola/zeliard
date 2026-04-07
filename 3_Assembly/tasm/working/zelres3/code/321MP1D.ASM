
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_321MP1D                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: device drivr	                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_321MP1D	proc	far


_321MP1D	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy_1	proc	far
		cmp	[bp+si],al
		add	[bx+si],al
attributes	dw	0C20Ah
pointers	dw	offset strategy
		dw	0C1A4h
char_dev	db	'ІСЈСТСФС'
		db	0F5h,0C1h, 36h,0C2h, 01h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h,0A4h
		db	0C1h, 3Fh, 06h, 3Fh, 06h, 3Fh
		db	 06h, 3Fh, 06h, 3Fh, 06h, 3Fh
		db	 06h, 3Fh, 06h, 3Fh, 06h, 3Fh
		db	 06h, 3Fh, 06h, 3Fh, 06h, 3Fh
		db	 06h, 3Fh, 06h, 3Fh, 06h, 3Fh
		db	 06h, 09h, 06h,0C5h, 45h, 64h
		db	 2Eh, 06h, 06h, 06h,0C5h,0C8h
		db	46h
strategy_1	endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy	proc	far
		dec	cx
		db	0C9h, 69h,0C4h, 2Ch, 06h, 05h
		db	 06h,0C7h, 59h,0C9h,0CAh, 48h
		db	 83h,0CAh,0C4h, 2Ch, 06h, 75h
		db	 46h, 69h, 87h,0C4h, 2Ch, 06h
		db	 65h,0C5h, 69h, 89h,0C4h, 2Ch
		db	 06h, 65h,0C7h,0C9h,0CAh, 8Bh
		db	0C4h, 2Ch, 06h, 65h,0C7h,0C9h
		db	 8Ch,0C4h, 2Ch, 06h, 65h,0C8h
		db	0C9h, 8Ch,0C5h, 2Ch, 06h, 65h
		db	0C8h,0C9h, 8Ch,0C4h, 2Ch, 06h
		db	 65h,0C8h,0C9h, 8Ch,0C4h, 2Ch
		db	 06h, 65h,0C8h,0C9h, 8Ch,0C4h
		db	 2Ch, 06h, 55h,0C5h,0C8h,0C9h
		db	 8Ch,0C5h, 2Ch, 06h, 55h,0C8h
		db	 48h, 8Ch,0C5h, 2Ch, 06h, 55h
		db	0C8h,0C9h, 8Dh,0C4h, 2Ch, 06h
		db	 55h,0C8h,0C9h, 8Dh,0C4h, 2Ch
		db	 06h, 55h,0C8h,0CAh, 8Dh,0C4h
		db	 2Ch, 06h, 55h,0C7h,0CAh, 8Dh
		db	0C4h, 2Ch, 06h, 55h,0C7h,0CAh
		db	 8Dh,0C4h, 2Ch, 06h, 55h,0C7h
		db	0CAh, 8Dh,0C5h, 2Ch, 06h, 45h
		db	0C5h,0C8h,0CAh, 8Dh,0C4h, 2Ch
		db	 06h, 45h,0C8h, 49h, 8Dh,0C4h
		db	 2Ch, 06h, 45h,0C8h, 49h, 8Dh
		db	0C4h, 2Ch, 06h, 45h,0C7h, 49h
		db	 8Dh,0C4h, 2Ch, 06h, 45h,0C7h
		db	 49h, 8Dh,0C4h, 2Ch, 06h, 45h
		db	0C8h, 49h, 8Dh,0C4h, 2Ch, 06h
		db	 45h,0C3h,0C8h, 49h, 8Ch,0C5h
		db	 2Ch, 06h, 55h,0C7h, 49h, 8Ch
		db	 2Dh, 06h, 55h,0C7h, 49h, 8Ch
		db	0C4h, 2Ch, 06h, 55h,0C8h, 49h
		db	 8Ch, 2Dh, 06h, 55h,0C8h, 49h
		db	 8Ch,0C4h, 2Ch, 06h, 55h,0C3h
		db	0C8h,0CAh, 8Ch,0C4h, 2Ch, 06h
		db	 65h,0C8h,0CAh, 8Ch, 2Dh, 06h
		db	 65h,0C8h,0CAh, 8Ch,0C4h, 2Ch
		db	 06h, 65h,0C8h,0CAh, 8Ch,0C4h
		db	 2Ch, 06h, 65h,0C8h, 49h, 8Bh
		db	0C4h, 2Ch, 06h, 65h,0C7h, 49h
		db	 8Bh,0C4h, 2Ch, 06h, 65h,0C7h
		db	 49h, 8Bh,0C4h, 2Ch, 06h, 65h
		db	0C8h, 49h, 8Bh,0C4h, 2Ch, 06h
		db	 65h,0C3h,0C7h,0CAh, 8Bh,0C4h
		db	 2Ch, 06h, 75h,0C7h,0CAh, 8Bh
		db	 2Dh, 06h, 75h,0C8h,0CAh,0C9h
		db	0CAh, 89h,0C4h, 2Ch, 06h, 05h
		db	 06h,0CAh, 48h, 59h, 86h,0C4h
		db	 2Ch, 06h, 05h, 06h,0C3h,0C8h
		db	 46h, 58h, 79h,0C4h, 2Ch, 06h
		db	 08h, 06h, 42h,0C6h,0C8h,0C7h
		db	0C9h, 59h,0C4h, 2Ch, 06h, 0Bh
		db	 06h,0C3h, 55h, 42h, 2Dh, 06h
		db	 3Fh, 06h, 3Fh, 06h, 3Fh, 06h
		db	 3Fh, 06h, 3Fh, 06h, 3Fh, 06h
		db	 3Fh, 06h, 3Fh, 06h, 3Fh, 06h
		db	 3Fh, 06h, 3Fh, 06h, 3Fh, 06h
		db	 3Fh, 06h,0FFh,0FFh,0FFh,0FFh
		db	0FFh,0FFh, 1Bh, 00h, 0Eh,0C1h
		db	 00h, 1Ah, 00h, 0Fh, 00h,0FFh
		db	0FFh,0FFh, 2Fh, 00h, 0Eh, 82h
		db	 00h, 8Dh, 00h, 20h, 80h, 03h
		db	 00h, 20h,0FFh,0FFh, 02h, 00h
		db	 08h, 24h,0C2h, 00h,0FFh, 2Fh
		db	0C2h,0FFh,0FFh,0FFh,0FFh, 03h
		db	 00h, 20h,0BEh,0C1h, 00h,0FFh
		db	0C0h,0C1h,0FFh,0FFh,0FFh,0FFh
		db	 00h, 00h,0FFh, 10h,0C0h, 24h
		db	0C2h, 0Ah,0C0h,0AAh,0C1h, 0Dh
		db	0C2h, 00h, 00h, 0Ah,0C2h, 09h
		db	 00h,0FFh,0FFh,0FFh,0FFh, 16h
		db	0AFh, 00h, 11h
		db	'Cavern of Malicia'
		db	 99h, 00h, 00h, 01h,0FFh, 01h
		db	 00h, 00h, 10h,0C0h, 24h,0C2h
		db	 0Ah,0C0h,0B6h,0C1h, 26h,0C2h
		db	 05h,0FFh, 00h, 00h,0FFh,0FFh
		db	0FFh,0FFh, 26h, 00h, 10h,0FFh
		db	 76h, 00h, 00h, 20h, 00h, 00h
		db	 00h, 02h, 00h, 08h, 00h, 00h
header_1	dd	0FFFFFFFFh
strategy	endp


seg_a		ends



		end
