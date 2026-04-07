
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_327MP3D                                 лл
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

_327MP3D	proc	far


_327MP3D	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy_1	proc	far
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		add	[bx+si],al
attributes	dw	0C1B8h
pointers	dw	offset strategy
		dw	0C15Dh
char_dev	db	'_СaС{С}С'
		db	0A6h,0C1h,0E4h,0C1h, 03h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h, 5Dh
		db	0C1h, 8Bh,0D5h, 84h,0C6h, 53h
		db	0CAh, 81h,0DAh,0A9h, 8Bh,0D5h
		db	 85h,0C6h,0C4h,0CAh,0ACh, 8Bh
		db	0D6h, 85h,0D6h,0AEh, 0Ah, 0Dh
		db	0D7h, 7Ch,0D7h, 2Dh, 0Dh, 3Fh
		db	 0Eh, 3Fh, 0Eh, 3Fh, 0Fh, 3Fh
		db	 0Fh, 3Fh, 0Fh, 3Fh, 10h, 3Fh
		db	 10h
strategy_1	endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy	proc	far
		or	dx,[bx+di]
		db	0D8h, 0Bh, 11h, 02h, 18h, 23h
		db	 11h, 8Ch,0D9h, 8Ch, 02h, 19h
		db	0A4h, 8Ch,0DAh, 8Ch, 02h, 15h
		db	0A4h, 99h, 02h, 15h,0A4h, 99h
		db	 02h, 15h,0A4h, 99h,0C8h, 01h
		db	 1Ah,0A4h, 99h,0C4h,0D5h,0A5h
		db	 99h,0C4h,0DAh,0A5h, 99h,0C4h
		db	0C9h,0A5h, 99h, 43h,0A5h, 99h
		db	 43h,0A5h, 99h, 43h,0C8h,0A4h
		db	 99h,0C9h, 43h,0A4h, 99h,0C4h
		db	0C9h,0C4h,0A4h, 99h, 43h,0C9h
		db	0A4h, 99h, 53h,0A4h, 99h,0C4h
		db	0C9h,0C4h,0A4h, 99h,0C4h,0C9h
		db	0C4h,0A4h, 99h,0C4h,0C9h,0C4h
		db	0A4h, 99h, 43h,0CAh,0A4h, 99h
		db	 43h,0A5h, 99h,0C4h,0C5h,0CCh
		db	0A4h, 99h,0C8h,0CBh,0A5h, 99h
		db	0C8h,0CBh,0CCh,0A4h, 99h,0C4h
		db	0C5h,0CBh,0A4h, 99h,0C4h,0CBh
		db	0CCh,0A4h, 99h,0C4h,0C8h,0A5h
		db	 99h,0C4h,0C9h,0A5h, 99h,0C9h
		db	0C4h,0A5h, 99h, 43h,0C8h,0A4h
		db	 99h, 43h,0C9h,0A4h, 99h, 43h
		db	0CAh,0A4h, 99h,0C4h,0CBh,0CCh
		db	0A4h, 99h,0C4h,0C5h,0CCh,0A4h
		db	 99h, 43h,0A5h, 99h, 43h,0C8h
		db	0A4h, 99h, 53h,0A4h, 99h,0C4h
		db	0C9h,0C4h,0A4h, 99h,0C4h,0C9h
		db	0C4h,0A4h, 99h, 53h,0A4h, 99h
		db	 43h,0CAh,0A4h, 99h,0C4h,0CAh
		db	0A5h, 99h,0C4h,0D4h,0A5h, 99h
		db	0C4h,0D5h,0A5h, 99h,0C4h,0D5h
		db	0D4h,0A4h, 99h,0C4h, 01h, 15h
		db	0A4h, 8Ch,0D4h, 8Ch,0C4h, 01h
		db	 15h,0A4h, 8Ch,0D5h, 8Ch,0CAh
		db	 01h, 15h,0A4h, 8Ch,0D6h, 8Ch
		db	 02h, 16h,0A4h, 0Bh, 0Dh,0D7h
		db	 0Bh, 0Dh, 02h, 17h, 23h, 0Dh
		db	 3Fh, 0Eh, 3Fh, 0Eh, 3Fh, 0Fh
		db	 3Fh, 0Fh, 3Fh, 0Fh, 3Fh, 10h
		db	 3Fh, 10h, 0Bh, 11h,0D8h, 08h
		db	 11h,0D8h, 28h, 11h, 8Ch,0D9h
		db	 89h,0D9h,0A9h, 8Ch,0DAh, 83h
		db	0C3h,0D4h, 84h,0DAh,0A9h, 90h
		db	 43h,0C9h,0C8h, 82h,0D5h,0A9h
		db	 8Bh,0D4h, 84h, 63h,0C8h, 81h
		db	0D5h,0A9h,0FFh,0FFh,0FFh,0FFh
		db	0FFh,0FFh, 11h, 00h, 15h,0C1h
		db	 06h,0BCh, 00h, 14h, 00h,0FFh
		db	0FFh,0FFh, 34h, 00h, 15h, 82h
		db	 06h,0AEh, 00h, 04h, 80h, 13h
		db	 00h, 02h,0FFh,0FFh, 13h, 00h
		db	 04h,0D2h,0C1h,0FFh,0FFh,0FFh
		db	0FFh, 13h, 00h, 02h, 76h,0C1h
		db	 04h, 00h,0FFh,0FFh, 10h, 00h
		db	0FFh, 10h,0C0h,0D2h,0C1h, 0Ah
		db	0C0h, 63h,0C1h,0BBh,0C1h, 04h
		db	 04h,0B8h,0C1h, 0Dh, 00h,0FFh
		db	0FFh,0FFh,0FFh, 18h,0AFh, 00h
		db	 0Eh
		db	'Cavern of Riza'
		db	 99h, 00h, 02h, 05h,0FFh, 05h
		db	 04h, 04h, 10h,0C0h,0D2h,0C1h
		db	 0Ah,0C0h, 6Fh,0C1h,0D4h,0C1h
		db	 0Dh,0FFh, 10h, 00h,0FFh,0FFh
		db	0FFh,0FFh, 21h, 00h, 14h,0FFh
		db	 76h, 00h, 00h, 20h, 00h, 00h
		db	 00h, 13h, 00h, 04h, 00h, 00h
header_1	dd	0FFFFFFFFh
strategy	endp


seg_a		ends



		end
