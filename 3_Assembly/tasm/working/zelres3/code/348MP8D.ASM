
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_348MP8D                                 лл
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

_348MP8D	proc	far


_348MP8D	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy_1	proc	far
		xchg	cx,ax
		add	al,[bx+si]
		add	[bx-3Eh],ah
pointers	dw	offset strategy
		dw	0C229h
char_dev	db	'+Т-ТGТIТ'
		db	 54h,0C2h, 8Fh,0C2h, 08h,0FFh
		db	0FFh,0FFh, 0Ch, 00h, 00h, 29h
		db	0C2h, 83h,0C5h, 05h, 07h,0C8h
		db	0CBh, 46h, 47h,0C7h,0C8h,0C9h
		db	 56h,0AAh, 83h,0C4h, 05h, 07h
		db	 47h, 46h, 47h, 46h,0C8h, 56h
		db	0AAh, 83h,0C4h, 46h,0CAh, 46h
		db	0C9h, 47h, 66h,0C8h,0C7h,0C8h
		db	 56h,0AAh, 83h,0C4h
strategy_1	endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy	proc	far
		add	ax,5707h
		db	0C7h,0C9h,0C7h,0C8h, 46h,0CAh
		db	 46h,0AAh, 83h,0C4h, 06h, 07h
		db	 67h,0C7h,0C8h,0C7h,0C8h, 56h
		db	0AAh, 83h,0C6h, 46h,0CAh, 66h
		db	 77h, 46h,0C8h, 56h,0AAh, 84h
		db	0C4h, 66h,0CAh, 46h, 67h, 46h
		db	0C8h, 56h,0AAh, 84h,0C5h,0C7h
		db	0C9h,0C7h,0C8h,0CBh,0C8h,0CBh
		db	0CAh,0C7h,0C8h, 56h,0C8h, 56h
		db	0AAh, 84h,0C4h, 76h,0CBh,0C7h
		db	0CCh, 56h,0C9h,0C7h,0C8h, 56h
		db	0AAh, 84h,0C4h, 66h,0CAh,0C8h
		db	0CBh,0C7h,0CAh, 07h, 07h,0AAh
		db	 84h,0C4h,0C8h,0C7h,0CAh,0CCh
		db	 06h, 07h,0C8h, 76h,0AAh, 84h
		db	0C6h, 66h,0CBh,0C7h,0CBh,0C8h
		db	0C7h,0C8h, 76h,0C9h,0C7h,0AAh
		db	 86h,0C4h, 56h,0C9h,0C7h,0CBh
		db	 46h, 4Ah, 76h,0AAh, 86h,0C6h
		db	0C7h,0C8h, 56h,0C8h,0C7h, 47h
		db	 4Ah, 66h,0AAh, 8Ah,0C4h, 05h
		db	 07h,0CAh,0CBh, 56h,0AAh, 8Ah
		db	0C6h, 46h, 47h, 06h, 07h,0AAh
		db	 92h,0C4h,0C9h, 46h,0AAh, 92h
		db	0C5h,0C7h,0C8h,0C7h,0AAh, 92h
		db	0C4h,0C8h, 46h,0AAh, 92h,0C4h
		db	0CAh, 46h,0AAh, 92h,0C5h,0CCh
		db	 46h,0AAh, 92h,0C4h,0C7h,0CCh
		db	0C7h,0AAh, 92h,0C4h,0C7h,0C8h
		db	0C7h,0AAh, 92h,0C5h,0C7h,0CAh
		db	0C7h,0AAh, 92h,0C4h,0C8h,0C9h
		db	0C7h,0AAh, 92h,0C4h, 56h,0AAh
		db	 92h,0C4h,0CAh, 46h,0AAh, 92h
		db	0C4h,0C7h,0CCh,0C7h,0AAh, 92h
		db	0C4h, 46h,0CCh,0AAh, 92h,0C4h
		db	 56h,0AAh, 92h,0C5h,0C8h,0C9h
		db	0C7h,0AAh, 92h,0C4h,0C7h,0C8h
		db	0C7h,0AAh, 92h,0C4h,0CAh, 46h
		db	0AAh, 92h,0C5h, 56h,0AAh, 92h
		db	0C4h,0C7h,0CAh,0C7h,0AAh, 92h
		db	0C4h, 56h,0AAh, 92h,0C4h,0C7h
		db	0CCh,0C7h,0AAh, 92h,0C5h,0C9h
		db	0C7h,0CBh,0AAh, 92h,0C5h, 56h
		db	0AAh, 92h,0C5h, 56h,0AAh, 92h
		db	0C5h, 56h,0AAh, 92h,0C4h,0C7h
		db	0C9h,0C7h,0AAh, 92h,0C4h, 56h
		db	0AAh, 92h,0C4h,0CAh, 46h,0AAh
		db	 92h,0C4h,0C7h,0C8h,0C7h,0AAh
		db	 92h,0C5h,0C8h, 46h,0AAh, 92h
		db	0C4h,0C7h,0C9h,0C7h,0AAh, 92h
		db	0C4h, 56h,0AAh, 92h,0C4h,0CCh
		db	 46h,0AAh, 92h,0C5h,0C7h,0CBh
		db	0C7h,0AAh, 92h,0C4h, 56h,0AAh
		db	 92h,0C4h,0C9h, 46h,0AAh, 92h
		db	0C4h,0CAh, 46h,0AAh, 92h,0C4h
		db	 56h,0AAh, 92h,0C5h,0C7h,0CAh
		db	0C7h,0AAh, 92h,0C5h,0CAh, 46h
		db	0AAh, 92h,0C4h, 56h,0AAh, 92h
		db	0C4h, 56h,0AAh, 8Ah,0C3h,0CAh
		db	0C7h,0CAh,0C7h,0C8h, 05h, 07h
		db	0AAh, 8Ah,0C4h, 66h,0C8h, 05h
		db	 07h,0AAh, 86h,0C3h,0CAh, 81h
		db	 76h,0CBh,0C8h,0CBh,0C9h, 66h
		db	0AAh, 86h,0C4h,0C8h,0C7h,0C8h
		db	 46h,0C9h, 46h,0CBh,0C8h,0CBh
		db	0C7h,0CAh, 46h,0AAh, 84h,0C3h
		db	0C8h, 46h,0C9h,0CAh,0C7h,0CBh
		db	 05h, 07h,0CBh, 56h,0AAh, 84h
		db	0C4h, 06h, 07h,0CBh, 46h,0CAh
		db	 05h, 07h,0AAh, 84h,0C5h,0C8h
		db	0C7h,0C9h, 76h,0CCh, 05h, 07h
		db	0CAh,0C7h,0AAh, 84h,0C4h,0CAh
		db	 0Ah, 07h,0CAh, 66h,0AAh, 84h
		db	0C4h, 05h, 07h,0CAh,0C7h,0CBh
		db	 46h,0C8h, 76h,0AAh, 83h,0C3h
		db	0C7h,0C8h, 46h,0C8h,0CBh,0CAh
		db	 56h, 4Ah,0C8h, 76h,0AAh, 83h
		db	0C4h, 66h,0C8h,0C7h,0CBh, 66h
		db	0C8h,0CCh, 76h,0AAh, 83h,0C4h
		db	0C7h,0C9h, 46h,0CAh,0C8h,0CCh
		db	 56h, 57h, 76h,0AAh,0FFh,0FFh
		db	0FFh,0FFh,0FFh,0FFh, 15h, 00h
		db	 0Eh,0C1h, 18h,0DEh, 00h, 13h
		db	 00h,0FFh,0FFh,0FFh, 32h, 00h
		db	 0Eh, 82h, 1Bh, 10h, 00h, 33h
		db	 80h, 45h, 00h, 40h,0FFh,0FFh
		db	 45h, 00h, 40h, 42h,0C2h, 33h
		db	 00h,0FFh,0FFh,0FFh,0FFh, 16h
		db	0AFh, 04h, 0Fh
		db	'Cavern of Absor'
		db	 99h, 00h, 07h, 0Fh,0FFh, 0Fh
		db	 0Eh, 0Eh, 10h,0C0h, 7Dh,0C2h
		db	 0Ah,0C0h, 3Bh,0C2h, 7Fh,0C2h
		db	 00h,0FFh,0FFh,0FFh, 24h, 00h
		db	 10h,0FFh, 79h, 00h, 00h, 20h
		db	 00h, 00h, 00h,0FFh,0FFh,0FFh
		db	 00h, 00h
header_1	dd	0FFFFFFFFh
strategy	endp


seg_a		ends



		end
