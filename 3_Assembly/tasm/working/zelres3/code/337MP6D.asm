
PAGE  59,132

;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
;ЫЫ					                                 ЫЫ
;ЫЫ				ZR3_37	                                 ЫЫ
;ЫЫ					                                 ЫЫ
;ЫЫ      Created:   16-Feb-26		                                 ЫЫ
;ЫЫ      Code type: device drivr	                                 ЫЫ
;ЫЫ      Passes:    9          Analysis	Options on: none                 ЫЫ
;ЫЫ					                                 ЫЫ
;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_37		proc	far


zr3_37		endp

;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
;
;                       External Entry Point
;
;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

strategy_1	proc	far
		inc	byte ptr [bp+si]
		add	[bx+si],al
attributes	dw	0C2D0h
pointers	dw	offset strategy
		dw	0C26Fh
char_dev	db	'qВsВЌВЏВ'
		db	0BCh,0C2h,0FCh,0C2h, 06h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h, 6Fh
		db	0C2h, 83h,0C9h,0C8h, 53h,0C5h
		db	 53h,0C5h, 53h, 4Bh, 4Ch,0C9h
		db	0ABh, 83h,0C9h,0C8h, 43h,0C5h
		db	 53h,0C5h, 53h,0C7h, 4Ch, 81h
		db	 48h,0ABh, 83h,0C8h, 43h,0C5h
		db	 53h,0C5h,0E0h, 43h,0C7h, 5Bh
		db	0CAh,0CDh,0C9h,0ABh, 83h,0C8h
		db	0C4h
strategy_1	endp


;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
;
;                       External Entry Point
;
;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

strategy	proc	far
		lds	dx,dword ptr [bp+di-3Bh]	; Load seg:offset ptr
		push	bx
		db	0C7h,0CCh,0CDh,0CCh,0CBh,0CAh
		db	 48h,0ABh, 83h,0C8h,0E0h, 43h
		db	0C5h, 05h, 04h, 4Bh, 49h, 58h
		db	0ABh, 83h, 53h,0C5h,0E0h, 73h
		db	0C7h,0CCh,0CDh, 4Ah,0CDh,0CBh
		db	0C9h,0ABh, 83h,0C3h,0C4h,0C5h
		db	 05h, 04h,0C7h, 4Bh,0C9h,0CBh
		db	0C8h,0CBh,0CAh,0C8h,0ABh, 84h
		db	0C3h, 05h, 04h,0C7h, 4Bh, 49h
		db	0C9h,0C7h,0CDh,0CCh,0C8h,0ABh
		db	 85h,0C3h, 53h,0C7h,0C9h,0CCh
		db	 49h,0CCh,0C8h,0CCh,0C5h, 47h
		db	0C4h,0ABh, 85h, 42h, 43h,0C7h
		db	0C9h, 4Bh,0C7h,0CAh,0CBh,0CAh
		db	0C9h,0C8h, 43h,0ABh, 86h,0C3h
		db	 43h,0C7h, 48h,0CCh,0C9h, 49h
		db	0CCh,0CAh, 43h,0C5h,0ABh, 83h
		db	0CEh,0CFh,0D0h,0C3h,0C4h,0E0h
		db	0C4h,0C7h,0C9h,0CBh,0C9h,0CAh
		db	0CCh,0CAh,0CCh,0C8h,0C5h,0C4h
		db	0ABh, 86h,0C3h,0C4h,0E0h,0C9h
		db	 5Bh,0C9h,0CCh,0CAh, 47h, 43h
		db	0C5h,0ABh, 87h,0C3h, 68h,0CAh
		db	0C9h,0CAh,0C8h, 53h,0C5h,0C4h
		db	0ABh, 83h,0D2h, 01h, 13h,0D4h
		db	0C3h,0C9h,0CCh
		db	49h

locloop_1:
		int	3			; Debug breakpoint
		retf	0C8CCh
strategy	endp

			                        ;* No entry point to code
		inc	bx
		db	0C5h,0E0h,0C4h,0ABh, 88h

locloop_2:
		int	6Bh			; ??INT Non-standard interrupt
		retf	0C8CCh
		db	0C5h,0E0h,0C5h, 43h,0ABh, 89h
		db	 49h,0CCh,0CAh,0CDh,0CCh,0C5h
		db	0C4h,0C5h,0C4h,0C5h,0C4h,0ABh
		db	 92h,0C3h, 43h,0ABh, 92h,0C3h
		db	0C5h,0C4h,0ABh, 92h,0C3h,0E0h
		db	0C4h,0ABh, 92h,0C3h,0C5h,0E0h
		db	0ABh, 92h,0C3h, 43h,0ABh, 92h
		db	0C3h,0E0h,0C4h,0ABh, 92h,0C3h
		db	0E0h,0C4h,0ABh, 92h,0C3h,0E0h
		db	0C4h,0ABh, 92h,0C3h,0C5h,0C4h
		db	0ABh, 92h,0C3h,0E0h,0C4h,0ABh
		db	 92h,0C3h,0E0h,0C4h,0ABh, 92h
		db	0C3h,0C5h,0C4h,0ABh, 92h,0C3h
		db	0C4h,0C7h,0ABh, 92h,0C3h,0C5h
		db	0C4h,0ABh, 92h,0C3h,0C5h,0E0h
		db	0ABh, 92h,0C3h,0E0h,0C4h,0ABh
		db	 92h,0C3h,0C5h,0C7h,0ABh, 92h
		db	0C3h,0C5h,0C7h,0ABh, 92h,0C3h
		db	0C5h,0CAh,0ABh, 92h,0C3h,0C7h
		db	0C9h,0ABh, 92h,0C3h,0C5h,0CAh
		db	0ABh, 92h,0C3h,0C7h,0CAh,0ABh
		db	 92h,0C3h,0C4h,0C8h,0ABh, 92h
		db	0C3h,0C5h,0E0h,0ABh, 92h,0C3h
		db	0C5h,0C4h,0ABh, 92h,0C3h,0E0h
		db	0C4h,0ABh, 92h,0C3h,0C5h,0C4h
		db	0ABh, 92h,0C3h,0C5h,0C4h,0ABh
		db	 92h,0C3h,0E0h,0C4h,0ABh, 92h
		db	0C3h,0C5h,0C4h,0ABh, 92h,0C3h
		db	0C5h,0E0h,0ABh, 92h,0C3h,0E0h
		db	0C4h,0ABh, 92h,0C3h, 43h,0ABh
		db	 92h,0C3h, 43h,0ABh, 92h,0C3h
		db	0C5h,0C4h,0ABh, 92h,0C3h,0C5h
		db	0C4h,0ABh, 92h,0C3h,0E0h,0C4h
		db	0ABh, 92h,0C3h,0C5h,0C4h,0ABh
		db	 92h,0C3h,0C5h,0E0h,0ABh, 92h
		db	0C3h,0C5h,0C4h,0ABh, 92h,0C3h
		db	0C5h,0C4h,0ABh, 92h,0C3h,0C5h
		db	0C4h,0ABh, 83h,0CEh, 06h, 0Fh
		db	0D0h, 5Bh,0C8h, 43h,0E0h, 43h
		db	0ABh, 8Ah,0CCh, 48h,0C8h, 53h
		db	0C5h, 53h,0ABh, 83h,0CEh, 6Eh
		db	0D0h,0CAh, 48h, 47h, 43h,0C5h
		db	 63h,0ABh, 88h,0CCh,0C9h,0C8h
		db	 43h,0E0h,0C4h,0C5h, 73h,0ABh
		db	 87h, 4Bh,0C9h,0C8h, 53h,0C5h
		db	0C4h,0E0h, 63h,0ABh, 83h,0D2h
		db	0D3h,0D4h,0CCh,0C9h,0CAh,0C8h
		db	 0Ah, 04h,0ABh, 85h,0CCh,0C9h
		db	0CBh,0C9h,0C8h, 43h,0E0h, 07h
		db	 04h,0ABh, 85h,0CDh, 48h,0C8h
		db	 73h,0C5h,0C4h,0C5h,0E0h, 53h
		db	0ABh, 85h,0CCh,0CBh,0C8h, 43h
		db	0E0h, 43h,0C5h,0C4h,0E0h, 73h
		db	0ABh, 84h,0CCh, 48h, 73h,0C5h
		db	0C4h,0C5h, 05h, 04h,0ABh, 83h
		db	0CCh,0CAh,0CBh,0C9h,0C8h, 53h
		db	0C5h,0C4h, 44h, 05h, 04h,0ABh
		db	 83h,0C9h,0CAh,0C9h,0C8h, 53h
		db	0C5h, 06h, 04h,0E0h,0C7h,0CCh
		db	0ABh, 83h,0CAh,0CBh,0C8h, 05h
		db	 04h,0E0h, 73h,0C7h,0CCh,0C9h
		db	0ABh, 83h,0CBh,0CDh,0C8h,0C4h
		db	0E0h, 07h, 04h,0C7h,0CDh,0CCh
		db	0C9h,0CDh,0ABh,0FFh,0FFh,0FFh
		db	0FFh,0FFh,0FFh, 1Bh, 00h, 0Eh
		db	0C1h, 0Eh, 35h, 01h, 29h, 00h
		db	0FFh,0FFh,0FFh, 2Fh, 00h, 0Eh
		db	 82h, 0Eh, 1Ch, 00h, 2Eh, 80h
		db	 2Dh, 00h, 10h,0FFh,0FFh, 2Dh
		db	 00h, 20h,0EAh,0C2h,0FFh,0FFh
		db	0FFh,0FFh, 2Dh, 00h, 10h, 89h
		db	0C2h, 00h,0FFh, 8Bh,0C2h,0FFh
		db	0FFh,0FFh,0FFh, 28h, 00h,0FFh
		db	 10h,0C0h,0EAh,0C2h, 0Ah,0C0h
		db	 75h,0C2h,0D3h,0C2h, 0Ah, 0Ah
		db	0D0h,0C2h, 13h, 00h,0FFh,0FFh
		db	0FFh,0FFh, 17h,0AFh, 00h, 10h
		db	'Cavern of Tesoro'
		db	 99h, 00h, 05h, 0Bh,0FFh, 0Bh
		db	 0Ah, 0Ah, 10h,0C0h,0EAh,0C2h
		db	 0Ah,0C0h, 81h,0C2h,0ECh,0C2h
		db	 05h,0FFh, 28h, 00h,0FFh,0FFh
		db	0FFh,0FFh, 26h, 00h, 10h,0FFh
		db	 76h, 00h, 00h, 20h, 00h, 00h
		db	 00h, 2Dh, 00h, 20h, 00h, 00h
header_1	dd	0FFFFFFFFh

seg_a		ends



		end
