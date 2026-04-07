
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_324MP2D                                 лл
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

_324MP2D	proc	far


_324MP2D	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy_1	proc	far
		pop	dx
		add	ax,[bx+si]
		add	[si],ch
		retn
strategy_1	endp

pointers	dw	offset strategy
		dw	0C2CAh
char_dev	db	'ЬТЮТшТъТ'
		db	 17h,0C3h, 58h,0C3h, 02h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h,0CAh
		db	0C2h, 07h, 09h, 47h,0C9h,0C8h
		db	 68h,0C8h,0C9h,0C8h,0CAh,0C8h
		db	 2Ah, 09h, 08h, 09h,0C8h, 68h
		db	0C8h,0C9h,0C8h
		db	48h

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy	proc	far
		retf	0C868h			; Return far
strategy	endp

		db	 26h, 09h, 08h, 09h,0C8h, 35h
		db	 09h, 0Fh, 09h,0C8h, 58h,0C8h
		db	 48h,0C8h,0C9h,0C8h, 25h, 09h
		db	 06h, 09h,0C8h, 48h,0C8h,0C9h
		db	0C8h, 58h,0C8h, 05h, 09h,0C8h
		db	 27h, 09h, 06h, 09h,0C8h, 48h
		db	0C8h,0C9h,0C8h,0C9h,0C8h,0C9h
		db	0C8h, 05h, 09h,0C8h, 27h, 09h
		db	 06h, 09h,0C8h,0C9h,0C8h, 48h
		db	0C8h,0C9h,0C8h, 58h,0C8h, 68h
		db	0C8h, 27h, 09h, 14h, 09h,0C8h
		db	 58h,0C8h, 25h, 09h, 08h, 09h
		db	0C8h, 05h, 09h,0C8h,0C9h,0C8h
		db	 48h,0C8h, 68h,0C8h, 24h, 09h
		db	 08h, 09h,0C8h,0C9h,0C8h, 08h
		db	 09h,0C8h, 29h, 09h, 05h, 09h
		db	0C8h, 78h,0C8h, 48h,0C8h, 58h
		db	0C8h,0C9h, 47h, 28h, 09h, 05h
		db	 09h,0C8h, 78h,0C8h, 48h,0C8h
		db	0C9h,0C8h,0C9h,0C8h, 48h,0C8h
		db	 58h,0C8h, 24h, 09h, 0Bh, 09h
		db	0C8h, 48h,0C8h,0C9h,0C8h,0C9h
		db	0C8h,0C9h,0C8h, 48h,0C8h, 26h
		db	 09h, 09h, 09h,0C8h, 48h,0C8h
		db	 68h,0C8h, 48h,0C8h, 48h,0C8h
		db	0C9h,0C8h, 24h, 09h, 06h, 09h
		db	0C8h, 48h,0C8h, 48h,0C8h, 68h
		db	0C8h, 48h,0C8h, 48h,0C8h, 26h
		db	 09h, 06h, 09h,0C8h, 48h,0C8h
		db	 48h,0C8h,0C9h,0C8h, 58h,0CAh
		db	 48h,0CAh,0C9h,0C8h, 26h, 09h
		db	 06h, 09h, 47h, 05h, 09h,0C8h
		db	0CAh, 58h,0C8h, 58h,0C8h, 26h
		db	 09h, 05h, 09h,0C8h,0C9h,0C8h
		db	 48h, 69h,0C8h, 49h, 4Ah,0C8h
		db	0CAh,0C9h,0C8h, 27h, 09h, 05h
		db	 09h,0C8h,0C9h,0C8h,0C9h, 47h
		db	 79h, 77h,0C9h,0C8h, 48h,0C8h
		db	 24h, 09h, 09h, 09h,0CAh,0C8h
		db	 49h, 57h,0CCh,0CEh,0CFh, 81h
		db	0C6h,0C4h, 28h, 09h, 08h, 09h
		db	0C8h,0CAh,0C7h, 48h,0CCh,0CFh
		db	0CEh,0CFh, 84h,0C4h,0C9h,0C8h
		db	 26h, 09h, 05h, 09h,0C8h, 48h
		db	0C8h,0CAh,0C9h,0CCh,0CEh,0CFh
		db	 87h,0C4h,0C9h,0CAh, 26h, 09h
		db	 05h, 09h,0C8h, 78h,0CCh, 89h
		db	0C5h, 48h,0C8h, 25h, 09h, 05h
		db	 09h, 47h, 48h,0CAh,0CCh,0CEh
		db	 89h,0C5h, 48h,0C8h, 25h, 09h
		db	 06h, 09h, 47h,0C9h,0CDh,0CFh
		db	 8Ah,0C5h, 28h, 09h, 07h, 09h
		db	0C8h,0CDh,0CEh, 8Bh,0C5h,0C9h
		db	0C8h, 26h, 09h, 07h, 09h,0C8h
		db	0CDh,0CFh, 8Bh,0C5h,0C9h,0C8h
		db	 26h, 09h, 07h, 09h,0C8h,0CCh
		db	0CEh, 8Bh,0C4h, 28h, 09h, 06h
		db	 09h,0C8h,0C9h,0CDh,0CFh, 8Bh
		db	0C4h, 58h,0C8h, 24h, 09h, 06h
		db	 09h,0C8h,0C9h,0CCh,0CFh,0CEh
		db	 8Ah,0C4h,0C8h, 27h, 09h, 05h
		db	 09h, 47h,0C9h,0CCh,0CEh,0CFh
		db	 8Ah,0C4h,0C8h, 27h, 09h, 05h
		db	 09h,0C8h,0C9h,0C8h,0C9h,0CDh
		db	0CFh, 8Ah,0C4h,0C9h,0C8h, 26h
		db	 09h, 05h, 09h,0C8h,0C9h,0C8h
		db	 48h,0CCh, 8Ah,0C4h, 58h,0C8h
		db	 24h, 09h, 05h, 09h,0C8h,0C9h
		db	0C8h, 48h,0CDh,0CEh, 89h,0C4h
		db	 28h, 09h, 07h, 09h,0C8h, 48h
		db	0CDh,0CEh, 89h,0C4h,0C9h,0C8h
		db	 26h, 09h, 07h, 09h,0C8h, 48h
		db	0CAh,0CDh, 89h,0C4h, 48h,0C8h
		db	 25h, 09h, 08h, 09h,0C8h,0C9h
		db	0C8h,0CDh,0CEh, 88h,0C4h,0C9h
		db	 47h, 25h, 09h, 05h, 09h,0C8h
		db	 68h,0C8h,0CAh,0CCh, 88h,0C4h
		db	 28h, 09h, 05h, 09h,0C8h, 48h
		db	0C8h,0C9h, 49h,0CCh,0CEh, 87h
		db	0C4h, 28h, 09h, 07h, 09h, 47h
		db	0C9h,0C8h,0CAh,0CCh,0CFh, 87h
		db	0C5h,0C9h,0C8h, 26h, 09h, 07h
		db	 09h, 47h, 48h,0CAh,0C9h,0CDh
		db	0CFh, 86h,0C5h, 48h,0C8h, 25h
		db	 09h, 05h, 09h,0C8h,0C9h, 57h
		db	0CAh, 48h,0C8h,0CCh, 86h,0C5h
		db	0C8h, 27h, 09h, 09h, 09h,0C8h
		db	 58h,0C8h,0CCh,0CEh, 85h,0C5h
		db	 28h, 09h, 09h, 09h,0C8h,0C9h
		db	0C8h,0CAh,0C8h,0CCh,0CFh, 85h
		db	0C5h, 28h, 09h, 07h, 09h,0C8h
		db	 58h,0C8h,0CAh,0C8h,0CCh,0CFh
		db	 85h,0C5h,0C9h,0C8h, 26h, 09h
		db	 05h, 09h,0C8h,0C9h,0C8h, 58h
		db	0CAh,0C9h,0C8h,0CCh,0CEh, 85h
		db	0C5h,0C9h,0C8h, 26h, 09h, 05h
		db	 09h,0C8h, 58h,0C8h, 58h,0CAh
		db	0C8h,0CCh,0CFh, 84h,0C5h,0C9h
		db	0C8h, 26h, 09h, 05h, 09h,0C8h
		db	 06h, 09h, 47h,0CCh,0CFh, 84h
		db	0C5h, 28h, 09h, 06h, 09h,0C8h
		db	 48h, 47h,0C9h, 49h,0C8h,0CCh
		db	0CFh, 84h,0C5h,0C8h, 27h, 09h
		db	 06h, 09h,0C8h,0C9h, 57h,0C9h
		db	0CBh, 47h,0CCh,0CFh, 84h,0C5h
		db	0C8h, 27h, 09h, 06h, 09h,0C8h
		db	0C9h,0C8h, 58h, 59h,0C8h, 76h
		db	 58h,0C8h, 25h, 09h, 06h, 09h
		db	0C8h,0C9h,0C8h, 48h,0CBh, 49h
		db	0C8h,0CAh, 47h, 58h,0C8h, 48h
		db	0C8h, 25h, 09h,0FFh,0FFh,0FFh
		db	0FFh,0FFh,0FFh, 18h, 00h, 12h
		db	0C1h, 02h,0ABh, 00h, 36h, 00h
		db	0FFh,0FFh,0FFh, 29h, 00h, 12h
		db	 82h, 02h,0BEh, 00h, 2Fh, 80h
		db	 0Bh, 00h, 08h,0FFh,0FFh, 0Bh
		db	 00h, 10h, 46h,0C3h,0FFh,0FFh
		db	0FFh,0FFh, 0Bh, 00h, 08h,0E4h
		db	0C2h, 00h,0FFh,0E6h,0C2h,0FFh
		db	0FFh,0FFh,0FFh, 08h, 00h,0FFh
		db	 10h,0C0h, 46h,0C3h, 0Ah,0C0h
		db	0D0h,0C2h, 2Fh,0C3h, 02h, 02h
		db	 2Ch,0C3h, 0Bh, 00h,0FFh,0FFh
		db	0FFh,0FFh, 16h,0AFh, 02h, 11h
		db	'Cavern of Peligro'
		db	 99h, 00h, 01h, 03h,0FFh, 03h
		db	 02h, 02h, 10h,0C0h, 46h,0C3h
		db	 0Ah,0C0h,0DCh,0C2h, 48h,0C3h
		db	 0Dh,0FFh, 08h, 00h,0FFh,0FFh
		db	0FFh,0FFh, 21h, 00h, 14h,0FFh
		db	 76h, 00h, 00h, 20h, 00h, 00h
		db	 00h, 0Bh, 00h, 10h, 00h, 00h
header_1	dd	0FFFFFFFFh

seg_a		ends



		end
