
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_337MP6D                                 лл
;лл					                                 лл
;лл      Created:   29-Mar-26		                                 лл
;лл      Code type: special		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'M4'                      ; Target assembler: MASM-4.0

include  srmacros.inc


;------------------------------------------------------------  seg_a   ----

seg_a		segment	byte public
		assume cs:seg_a  , ds:seg_a

			                        ;* No entry point to code
		inc	byte ptr [bp+si]
		add	[bx+si],al
		rol	dl,1			; Rotate
		dec	cx
		add	[bx-3Eh],ch
		jno	$-3Ch			; Jump if not overflw
		jnc	$-3Ch			; Jump if carry=0
		db	 8Dh,0C2h, 8Fh,0C2h,0BCh,0C2h
		db	0FCh,0C2h, 06h,0FFh,0FFh, 00h
		db	 0Ch, 00h, 00h, 6Fh,0C2h, 83h
		db	0C9h,0C8h, 53h,0C5h, 53h,0C5h
		db	 53h, 4Bh, 4Ch,0C9h,0ABh, 83h
		db	0C9h,0C8h, 43h,0C5h, 53h,0C5h
		db	 53h,0C7h, 4Ch, 81h, 48h,0ABh
		db	 83h,0C8h, 43h,0C5h, 53h,0C5h
		db	0E0h, 43h,0C7h, 5Bh,0CAh,0CDh
		db	0C9h,0ABh, 83h,0C8h,0C4h,0C5h
		db	 53h,0C5h, 53h,0C7h,0CCh,0CDh
		db	0CCh,0CBh,0CAh, 48h,0ABh, 83h
		db	0C8h,0E0h, 43h,0C5h, 05h, 04h
		db	 4Bh, 49h, 58h,0ABh, 83h, 53h
		db	0C5h,0E0h, 73h,0C7h,0CCh,0CDh
		db	 4Ah,0CDh,0CBh,0C9h,0ABh, 83h
		db	0C3h,0C4h,0C5h, 05h, 04h,0C7h
		db	 4Bh,0C9h,0CBh,0C8h,0CBh,0CAh
		db	0C8h,0ABh, 84h,0C3h, 05h, 04h
		db	0C7h, 4Bh, 49h,0C9h,0C7h,0CDh
		db	0CCh,0C8h,0ABh, 85h,0C3h, 53h
		db	0C7h,0C9h,0CCh, 49h,0CCh,0C8h
		db	0CCh,0C5h, 47h,0C4h,0ABh, 85h
		db	 42h, 43h,0C7h,0C9h, 4Bh,0C7h
		db	0CAh,0CBh,0CAh,0C9h,0C8h, 43h
		db	0ABh, 86h,0C3h, 43h,0C7h, 48h
		db	0CCh,0C9h, 49h,0CCh,0CAh, 43h
		db	0C5h,0ABh, 83h,0CEh,0CFh,0D0h
		db	0C3h,0C4h,0E0h,0C4h,0C7h,0C9h
		db	0CBh,0C9h,0CAh,0CCh,0CAh,0CCh
		db	0C8h,0C5h,0C4h,0ABh, 86h,0C3h
		db	0C4h,0E0h,0C9h, 5Bh,0C9h,0CCh
		db	0CAh, 47h, 43h,0C5h,0ABh, 87h
		db	0C3h, 68h,0CAh,0C9h,0CAh,0C8h
		db	 53h,0C5h,0C4h,0ABh, 83h,0D2h
		db	 01h, 13h,0D4h,0C3h,0C9h,0CCh
		db	49h

locloop_1:
		int	3			; Debug breakpoint
		retf	0C8CCh
			                        ;* No entry point to code
		inc	bx
		db	0C5h,0E0h,0C4h,0ABh, 88h

locloop_2:
		int	6Bh			; ??INT Non-standard interrupt
		retf	0C8CCh			; Return far
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
		db	0FFh,0FFh,0FFh,0FFh

seg_a		ends



		end
