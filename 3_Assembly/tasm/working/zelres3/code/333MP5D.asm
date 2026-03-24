
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR3_33	                                 лл
;лл					                                 лл
;лл      Created:   16-Feb-26		                                 лл
;лл      Code type: device drivr	                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_33		proc	far


zr3_33		endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy_1	proc	far
		db	 6Bh, 02h, 00h, 00h
attributes	dw	0C23Dh
pointers	dw	offset strategy
		dw	0C1DEh
char_dev	db	'рСтСќСўС'
		db	 27h,0C2h, 69h,0C2h, 05h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h,0DEh
		db	0C1h, 8Dh,0D0h,0D1h,0D6h,0C7h
		db	0CBh, 76h,0C6h, 46h,0CBh,0C7h
		db	0A4h, 8Dh,0D0h,0D7h,0C3h,0C4h
		db	0CBh,0C5h,0C9h, 07h, 07h,0A4h
		db	 8Dh,0C3h,0C7h, 4Ah,0C8h,0C7h
		db	 4Ah,0C7h,0CBh,0C7h,0CBh, 56h
		db	0A4h, 8Dh,0C4h, 66h,0C9h, 08h
		db	 07h
strategy_1	endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy	proc	far
		movsb				; Mov [si] to es:[di]
		db	 8Dh,0C3h,0CBh, 46h, 4Ah,0C5h
		db	0CBh, 56h,0CBh, 56h,0A4h, 8Dh
		db	0C3h, 46h,0C8h, 01h, 19h, 81h
		db	0C4h, 46h,0C9h, 46h,0C5h,0C7h
		db	0A4h, 8Eh,0C4h,0CBh,0D8h,0D9h
		db	 82h,0C4h,0C7h,0C9h,0C7h,0CBh
		db	 56h,0A4h, 94h,0C3h, 66h,0C6h
		db	 46h,0A4h, 94h,0C3h,0C6h, 05h
		db	 07h,0A4h, 94h,0C4h, 46h,0C5h
		db	 46h,0C9h,0C7h,0A4h, 94h,0C4h
		db	0CCh, 01h, 19h,0D8h, 46h,0CBh
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C4h,0C9h,0C7h,0A4h
		db	 99h,0C3h,0C7h,0C9h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C3h,0C5h,0C7h,0A4h
		db	 99h,0C3h, 46h,0A4h, 99h,0C4h
		db	 46h,0A4h, 99h,0C3h, 46h,0A4h
		db	 99h,0C3h, 46h,0A4h, 99h,0C3h
		db	0C7h,0C9h,0A4h, 99h,0C3h,0C5h
		db	0C7h,0A4h, 99h,0C3h, 46h,0A4h
		db	 99h,0C3h,0C9h,0C7h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C4h, 46h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h,0C7h,0C5h,0A4h, 99h,0C3h
		db	 46h,0A4h, 99h,0C4h, 46h,0A4h
		db	 99h,0C3h, 46h,0A4h, 99h,0C3h
		db	0C7h,0C9h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h,0C5h
		db	0C7h,0A4h, 99h,0C3h, 46h,0A4h
		db	 99h,0C3h,0C9h,0C7h,0A4h, 99h
		db	0C4h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h,0C7h,0C5h,0A4h, 99h,0C3h
		db	 46h,0A4h, 99h,0C3h, 46h,0A4h
		db	 99h,0C3h, 46h,0A4h, 99h,0C3h
		db	 46h,0A4h, 99h,0C4h,0C7h,0C9h
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h,0C9h,0C7h,0A4h, 99h,0C3h
		db	 46h,0A4h, 99h,0C3h, 46h,0A4h
		db	 99h,0C3h,0C5h,0C7h,0A4h, 94h
		db	0C3h,0C6h,0D9h,0D8h, 81h, 56h
		db	0A4h, 94h,0C4h,0C7h,0C8h,0D8h
		db	 66h,0A4h, 94h,0C3h,0C7h,0D8h
		db	0C9h, 66h,0A4h, 94h,0C3h,0C7h
		db	0C9h,0C7h, 4Ah, 46h,0A4h, 8Dh
		db	0CDh,0CEh,0CFh,0C3h,0D9h,0D8h
		db	 81h,0C4h, 06h, 07h,0A4h, 8Dh
		db	0D0h,0D1h,0D2h,0C3h,0CBh,0C5h
		db	0CBh, 46h,0CBh,0C6h,0C5h, 56h
		db	0A4h, 8Dh,0D0h,0D1h,0D6h, 46h
		db	0C5h,0CBh, 05h, 07h,0CBh,0C7h
		db	0A4h, 8Dh,0D0h,0D1h,0D2h,0C5h
		db	0CBh, 46h,0CBh, 66h,0C8h, 46h
		db	0A4h, 8Dh,0D0h,0D1h,0D6h,0C7h
		db	 4Ah,0C6h, 46h,0CBh,0C9h, 46h
		db	0C5h,0C7h,0A4h, 8Dh,0D0h,0D1h
		db	0D2h,0C5h,0CBh, 46h,0C9h, 06h
		db	 07h,0A4h, 8Dh,0D0h,0D7h,0D6h
		db	0C4h, 05h, 07h,0C5h, 66h,0A4h
		db	 8Dh,0D0h,0D1h,0D2h,0C3h,0C5h
		db	0CBh, 46h,0CBh, 05h, 07h,0A4h
		db	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 11h, 00h, 15h,0C1h, 0Ch, 9Dh
		db	 00h, 10h, 00h,0FFh,0FFh,0FFh
		db	 34h, 00h, 15h, 82h, 0Eh, 0Eh
		db	 00h, 05h, 80h, 24h, 00h, 04h
		db	0FFh,0FFh, 24h, 00h, 08h, 57h
		db	0C2h,0FFh,0FFh,0FFh,0FFh, 24h
		db	 00h, 04h,0F7h,0C1h, 05h, 00h
		db	0FFh,0FFh, 20h, 00h,0FFh, 10h
		db	0C0h, 57h,0C2h, 0Ah,0C0h,0E4h
		db	0C1h, 40h,0C2h, 08h, 08h, 3Dh
		db	0C2h, 11h, 00h,0FFh,0FFh,0FFh
		db	0FFh, 16h,0AFh, 00h, 12h
		db	'Cavern of Cementar'
		db	 99h, 00h, 04h, 09h,0FFh, 09h
		db	 08h, 08h, 10h,0C0h, 57h,0C2h
		db	 0Ah,0C0h,0F0h,0C1h, 59h,0C2h
		db	 0Dh,0FFh, 20h, 00h,0FFh,0FFh
		db	0FFh,0FFh, 21h, 00h, 17h,0FFh
		db	 79h, 00h, 00h, 20h, 00h, 00h
		db	 00h, 24h, 00h, 08h, 00h, 00h
header_1	dd	0FFFFFFFFh
strategy	endp


seg_a		ends



		end
