
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_330MP4D                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: device drivr	                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_330MP4D	proc	far


_330MP4D	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy_1	proc	far
		dec	bp
		add	al,[bx+si]
		add	[bp+di],dh
		retn	49h
strategy_1	endp

		db	0DEh,0C1h
char_dev	db	'рСтСќСўС'
		db	 1Eh,0C2h, 4Bh,0C2h, 04h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h,0DEh
		db	0C1h, 14h, 07h,0ABh, 0Ah, 07h
		db	0C6h, 08h, 07h,0ABh, 14h, 07h
		db	0ABh, 06h, 07h,0C3h, 05h, 07h
		db	0C8h, 05h, 07h,0ABh, 66h,0C8h
		db	 0Fh, 07h,0ABh, 14h, 07h,0ABh
		db	 08h, 07h,0C3h,0C7h,0C6h, 56h
		db	0C6h, 76h,0ABh, 14h, 07h,0ABh
		db	 0Fh

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy	proc	far
		pop	es
		db	0C8h, 66h,0ABh, 14h, 07h,0ABh
		db	 14h, 07h,0ABh, 07h, 07h,0C6h
		db	 66h,0C6h, 06h, 07h,0ABh, 14h
		db	 07h,0ABh, 66h,0C8h, 05h, 07h
		db	0C8h, 08h, 07h,0ABh, 14h, 07h
		db	0ABh, 14h, 07h,0ABh, 07h, 07h
		db	0C8h, 56h,0CAh,0C9h,0C8h, 83h
		db	0C4h, 46h,0ABh, 07h, 07h,0CAh
		db	0C9h, 88h,0C4h, 46h,0ABh, 06h
		db	 07h,0CAh,0C9h, 89h,0C4h, 46h
		db	0ABh, 76h,0CAh,0C9h, 8Bh,0C4h
		db	 46h,0ABh, 76h,0C8h, 8Ch,0C4h
		db	 46h,0ABh, 76h, 8Dh,0C4h,0C8h
		db	0C7h,0ABh, 66h,0C8h, 8Dh,0C5h
		db	 46h,0ABh, 56h,0C6h,0C8h, 8Dh
		db	0C4h, 46h,0ABh, 66h,0C8h, 8Dh
		db	0C4h, 46h,0ABh, 66h,0C8h, 8Dh
		db	0C4h, 46h,0ABh, 66h,0C8h, 8Dh
		db	0C5h, 46h,0ABh, 56h,0CAh,0C9h
		db	 8Dh,0C5h, 46h,0ABh, 56h,0CAh
		db	0C9h, 8Dh,0C4h, 46h,0ABh, 56h
		db	0CAh,0C9h, 8Dh,0C4h, 46h,0ABh
		db	 56h,0CAh,0C9h, 8Dh,0C6h, 46h
		db	0ABh, 66h,0C8h, 8Dh,0C4h, 46h
		db	0ABh, 66h,0C8h, 8Dh,0C4h, 46h
		db	0ABh, 66h, 8Eh,0C5h, 46h,0ABh
		db	 56h,0C8h, 8Eh,0C4h,0C7h,0C8h
		db	0ABh, 46h,0CAh,0C9h, 8Eh,0C4h
		db	 46h,0ABh, 46h,0C8h, 8Fh,0C4h
		db	 46h,0ABh, 56h, 8Fh,0C4h, 46h
		db	0ABh, 56h,0CAh,0C9h, 8Dh,0C4h
		db	 46h,0ABh, 46h,0C8h,0CAh,0C9h
		db	 8Dh,0C4h, 46h,0ABh, 56h,0C8h
		db	0CAh,0C9h, 8Ch,0C5h, 46h,0ABh
		db	 66h,0CAh,0C9h, 8Ch,0C5h, 46h
		db	0ABh, 66h,0CAh,0C9h, 8Ch,0C4h
		db	 46h,0ABh, 56h,0C8h,0CAh,0C9h
		db	 8Ch,0C6h, 46h,0ABh, 56h,0C8h
		db	0CAh,0C9h, 8Ch,0C4h, 46h,0ABh
		db	 66h,0C8h, 8Dh,0C4h, 46h,0ABh
		db	 66h, 8Eh,0C5h, 46h,0ABh, 76h
		db	 8Dh,0C4h,0C7h,0C8h,0ABh, 66h
		db	0C8h, 8Dh,0C4h, 46h,0ABh, 66h
		db	0C8h, 8Dh,0C4h, 46h,0ABh, 76h
		db	0C8h, 8Ch,0C4h, 46h,0ABh, 76h
		db	0C8h, 8Ch,0C4h, 46h,0ABh, 66h
		db	0C8h,0CAh,0C9h, 8Bh,0C4h,0C8h
		db	0C7h,0ABh, 05h, 07h,0CAh,0C9h
		db	 8Ah,0C4h, 46h,0ABh, 05h, 07h
		db	0CAh,0C9h, 8Ah,0C5h, 46h,0ABh
		db	 56h,0C8h,0C7h,0C8h,0CAh,0C9h
		db	 8Ah,0C4h, 46h,0ABh, 06h, 07h
		db	0CAh,0C9h, 89h,0C4h, 46h,0ABh
		db	 09h, 07h,0CAh,0C9h, 86h,0C4h
		db	 46h,0ABh, 06h, 07h,0C8h, 76h
		db	0CAh,0C9h, 83h,0C4h, 46h,0ABh
		db	 0Ah, 07h,0C8h, 05h, 07h,0C6h
		db	 46h,0ABh, 08h, 07h,0C6h, 0Ah
		db	 07h,0ABh, 66h,0C6h, 0Fh, 07h
		db	0ABh, 0Bh, 07h,0C3h, 07h, 07h
		db	0ABh, 0Eh, 07h,0C8h, 76h,0ABh
		db	 0Fh, 07h,0C6h,0C7h,0C6h, 46h
		db	0ABh, 08h, 07h,0C6h, 05h, 07h
		db	0C6h, 66h,0ABh, 06h, 07h,0C8h
		db	 0Ch, 07h,0ABh, 0Dh, 07h,0C8h
		db	 05h, 07h,0ABh, 14h, 07h,0ABh
		db	 14h, 07h,0ABh, 14h, 07h,0ABh
		db	 14h, 07h,0ABh, 14h, 07h,0ABh
		db	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 1Bh, 00h, 0Eh,0C1h, 08h,0E0h
		db	 00h, 12h, 00h,0FFh,0FFh,0FFh
		db	 2Fh, 00h, 0Eh, 82h, 0Bh, 19h
		db	 00h, 0Eh, 80h, 1Ch, 00h, 10h
		db	0FFh,0FFh, 1Ch, 00h, 10h,0F7h
		db	0C1h, 0Eh, 00h,0FFh,0FFh, 18h
		db	 00h,0FFh, 10h,0C0h, 49h,0C2h
		db	 0Ah,0C0h,0E4h,0C1h, 36h,0C2h
		db	 06h, 06h, 33h,0C2h, 0Fh, 00h
		db	0FFh,0FFh,0FFh,0FFh, 16h,0AFh
		db	 02h, 11h
		db	'Cavern of Glacial'
		db	 99h, 00h, 03h, 07h,0FFh, 07h
		db	 06h, 06h, 10h,0C0h, 49h,0C2h
		db	 0Ah,0C0h,0F0h,0C1h, 18h, 00h
		db	0FFh,0FFh,0FFh,0FFh
header_1	dd	0FFFFFFFFh
strategy	endp


seg_a		ends



		end
