
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_350MPA0                                 лл
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

_350MPA0	proc	far


_350MPA0	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy_1	proc	far
		db	0F3h, 03h, 00h, 00h
attributes	dw	0C3D9h
pointers	dw	offset strategy
		dw	0C3A0h
char_dev	db	'ЂУЄУВУДУ'
		db	0C7h,0C3h,0F1h,0C3h, 0Ah,0FFh
		db	0FFh,0FFh, 0Ch, 00h, 00h,0A0h
		db	0C3h, 82h, 01h, 11h,0D2h,0D1h
		db	0D2h,0D1h,0D3h,0C3h, 53h,0C3h
		db	0C4h, 42h,0C4h,0C3h, 40h,0ABh
		db	 82h, 02h, 11h,0D2h,0D1h,0D2h
		db	0D3h,0C4h, 08h, 03h, 41h,0ABh
		db	 82h,0D1h,0D2h, 02h, 11h,0D2h
		db	0D3h,0C3h,0C4h,0C3h,0C4h, 52h
		db	0C4h
strategy_1	endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy	proc	far
		retn
strategy	endp

			                        ;* No entry point to code
		les	ax,dword ptr [bx+si-55h]	; Load seg:offset ptr
;*		add	byte ptr [bp+di],11h
		db	 82h, 03h, 11h		;  Fixup - byte match
		rcl	cl,cl			; Rotate thru carry
		rol	word ptr [bp+si-3Ch],cl	; Rotate
		retn
		db	0C4h,0C3h,0C4h,0C3h,0C4h,0C3h
		db	 41h,0ABh, 82h, 01h, 11h,0D2h
		db	 02h, 11h,0D3h, 06h, 03h,0C4h
		db	0C3h,0C4h, 40h,0ABh, 82h,0D1h
		db	0D2h,0D1h, 02h, 12h,0D3h, 05h
		db	 03h,0C4h, 52h, 41h,0ABh, 82h
		db	 05h, 11h,0D3h, 72h,0C4h, 62h
		db	0C2h,0C1h,0ABh, 82h, 01h, 11h
		db	 01h, 12h,0D1h,0D2h,0D3h, 52h
		db	0C4h, 62h,0C4h,0C3h,0C2h,0C1h
		db	0ABh, 82h, 03h, 11h,0D2h,0D1h
		db	0D3h,0C3h,0C4h, 07h, 03h, 41h
		db	0ABh, 82h,0D1h, 02h, 12h,0D1h
		db	0D2h,0D3h, 52h, 43h, 62h,0C4h
		db	 40h,0ABh, 82h, 03h, 11h,0D2h
		db	 01h, 11h, 42h,0C4h, 42h,0C4h
		db	 42h,0C4h,0C3h, 41h,0ABh, 82h
		db	 01h, 11h, 03h, 12h,0D3h, 05h
		db	 03h,0C4h, 42h,0C4h, 40h,0ABh
		db	 82h, 06h, 11h, 62h,0C4h, 72h
		db	 41h,0ABh, 82h, 01h, 11h,0C5h
		db	0C7h,0C9h,0CBh,0C9h,0CBh,0C9h
		db	 62h,0C4h, 42h,0C4h, 40h,0ABh
		db	 82h, 01h, 11h,0C6h,0C8h,0CAh
		db	0CCh,0CAh,0CCh,0CAh, 72h,0C4h
		db	 42h, 41h,0ABh, 82h,0D1h,0D2h
		db	 03h, 11h, 01h, 13h, 81h, 07h
		db	 03h, 40h,0ABh, 82h, 01h, 11h
		db	 01h, 12h,0D1h, 02h, 13h, 88h
		db	0C4h, 41h,0ABh, 82h,0D1h,0D2h
		db	 01h, 11h, 01h, 13h, 8Ah,0C4h
		db	0C1h,0C2h,0ABh, 82h,0D1h, 02h
		db	 12h,0D1h,0D3h, 8Ah,0C3h, 41h
		db	0ABh, 82h, 03h, 11h, 8Ch,0C4h
		db	0C2h,0C1h,0ABh, 82h, 02h, 11h
		db	 02h, 13h, 8Ah,0C4h,0C1h,0C2h
		db	0ABh, 82h,0D1h, 01h, 12h,0D3h
		db	 81h,0D3h, 8Ah,0C3h,0C2h,0C1h
		db	0ABh, 82h, 03h, 11h,0D3h, 8Bh
		db	0C4h, 41h,0ABh, 82h,0C5h,0C7h
		db	0C9h,0CBh,0C9h,0CDh, 8Ah,0C4h
		db	 40h,0ABh, 82h,0C6h,0C8h,0CAh
		db	0CCh,0CAh,0CEh, 8Ah,0C3h,0C1h
		db	0C2h,0ABh, 82h,0D1h,0D2h,0D1h
		db	0D3h, 8Ch,0C4h,0C2h,0C1h,0ABh
		db	 82h, 01h, 11h,0D2h,0D1h, 01h
		db	 13h, 8Ah,0C4h,0C1h,0C2h,0ABh
		db	 82h, 02h, 11h, 81h,0D3h, 8Bh
		db	0C3h,0C2h,0C1h,0ABh, 82h,0D1h
		db	0D2h,0D1h,0D3h, 8Ch,0C3h,0C1h
		db	0C2h,0ABh, 82h, 01h, 11h, 01h
		db	 12h, 8Ch,0C4h,0C2h,0C1h,0ABh
		db	 82h,0D1h,0D2h,0D1h, 01h, 13h
		db	 8Bh,0C4h,0C1h,0C2h,0ABh, 82h
		db	 01h, 11h,0D2h,0D3h, 8Ch,0C3h
		db	0C2h,0C1h,0ABh, 82h, 02h, 11h
		db	 81h,0D3h, 8Bh,0C4h,0C2h,0C1h
		db	0ABh, 82h, 01h, 11h, 01h, 13h
		db	 8Ch,0C3h,0C1h,0C2h, 8Fh, 06h
		db	 14h, 95h, 82h, 01h, 11h,0D2h
		db	0D1h,0D3h, 8Bh,0C3h, 40h, 8Fh
		db	0D4h, 85h,0D4h, 95h, 82h,0D1h
		db	0D2h,0D1h, 81h,0D3h, 8Bh,0C4h
		db	0C2h,0C1h, 8Fh,0D4h, 85h,0D4h
		db	 95h, 82h, 01h, 11h,0D2h,0D3h
		db	 8Ch,0C3h, 40h, 8Fh,0D4h, 85h
		db	0D4h, 95h, 82h, 03h, 11h,0D3h
		db	 8Bh,0C4h, 40h, 8Fh,0D4h, 85h
		db	0D4h, 95h, 82h, 02h, 11h,0D3h
		db	 81h,0D3h, 8Ah,0C3h, 41h, 8Fh
		db	0D4h, 85h,0D4h, 95h, 82h,0D1h
		db	 01h, 12h,0D1h,0D3h, 8Bh,0C4h
		db	 40h, 8Fh,0D4h, 85h,0D4h, 95h
		db	 82h, 02h, 11h,0D2h, 01h, 13h
		db	 8Ah,0C3h,0C1h,0C2h, 8Fh,0D4h
		db	 85h,0D4h, 95h, 82h, 02h, 11h
		db	0D3h, 8Ch,0C4h,0C2h,0C1h, 8Fh
		db	0D4h, 85h,0D4h, 95h, 82h, 01h
		db	 11h,0D2h,0D3h, 8Ch,0C3h, 40h
		db	 8Fh, 06h, 14h, 95h, 82h,0D1h
		db	0D2h,0D1h, 01h, 13h, 8Bh,0C4h
		db	0C1h,0C2h,0ABh, 82h, 01h, 11h
		db	 01h, 12h,0D3h, 8Bh,0C4h,0C2h
		db	0C1h,0ABh, 82h, 02h, 11h,0D3h
		db	 8Ch,0C3h, 40h,0ABh, 82h, 01h
		db	 11h,0D2h, 01h, 13h, 8Bh,0C4h
		db	 41h,0ABh, 82h,0D1h, 02h, 12h
		db	0D3h, 8Bh,0C3h,0C2h,0C1h,0ABh
		db	 82h, 02h, 11h,0D3h, 8Ch,0C4h
		db	 40h,0ABh, 82h,0C5h,0C7h,0C9h
		db	0CBh,0C9h,0CDh, 8Ah,0C4h, 41h
		db	0ABh, 82h,0C6h,0C8h,0CAh,0CCh
		db	0CAh,0CEh, 8Ah,0C3h, 40h,0ABh
		db	 82h, 02h, 11h, 01h, 13h, 8Bh
		db	0C4h,0C1h,0C2h,0ABh, 82h,0D1h
		db	 01h, 12h,0D1h, 81h,0D3h, 8Ah
		db	0C4h,0C2h,0C1h,0ABh, 82h, 01h
		db	 11h,0D2h, 02h, 13h, 8Ah,0C3h
		db	 41h,0ABh, 82h, 01h, 11h,0D2h
		db	0D1h,0D3h, 8Bh,0C4h, 40h,0ABh
		db	 82h,0D1h,0D2h, 02h, 11h,0D3h
		db	 8Ah,0C3h,0C1h,0C2h,0ABh, 82h
		db	 01h, 11h, 01h, 12h, 02h, 13h
		db	 89h,0C4h,0C2h,0C1h,0ABh, 82h
		db	 05h, 11h, 81h,0D3h, 88h,0C4h
		db	 40h,0ABh, 82h, 02h, 11h,0D2h
		db	0D1h, 02h, 13h, 88h,0C3h, 41h
		db	0ABh, 82h,0D1h, 01h, 12h, 02h
		db	 11h, 01h, 13h, 81h, 07h, 03h
		db	 40h,0ABh, 82h, 01h, 11h,0C5h
		db	0C7h,0C9h,0CBh,0C9h,0CBh,0C9h
		db	0C3h,0C4h, 42h,0C4h, 52h, 41h
		db	0ABh, 82h, 01h, 11h,0C6h,0C8h
		db	0CAh,0CCh,0CAh,0CCh,0CAh, 52h
		db	0C4h, 62h, 40h,0ABh, 82h, 02h
		db	 11h,0D2h,0D1h,0D2h,0D1h, 06h
		db	 03h,0C4h,0C3h,0C4h,0C1h,0C2h
		db	0ABh, 82h,0D1h, 01h, 12h, 02h
		db	 11h,0D2h, 52h,0C4h, 62h,0C4h
		db	0C3h,0C2h,0C1h,0ABh, 82h, 03h
		db	 11h, 01h, 12h,0D1h, 42h,0C4h
		db	0C3h,0C4h, 42h,0C4h, 42h,0C1h
		db	0C2h,0ABh, 82h, 02h, 11h,0D2h
		db	 01h, 11h,0D2h,0C4h,0C3h,0C4h
		db	0C3h,0C4h, 72h,0C2h,0C1h,0ABh
		db	 82h, 01h, 11h,0D2h, 02h, 11h
		db	0D3h, 08h, 03h,0C4h,0C1h,0C2h
		db	0ABh, 82h,0D1h,0D2h,0D1h,0D2h
		db	0D1h, 01h, 12h, 07h, 03h,0C4h
		db	0C3h,0C2h,0C1h,0ABh, 82h, 01h
		db	 11h,0D2h,0D1h,0D2h,0D1h,0D3h
		db	0C4h, 08h, 03h,0C1h,0C2h,0ABh
		db	 82h,0D1h,0D2h,0D1h,0D2h, 01h
		db	 11h,0D3h,0C3h, 53h,0C3h,0C4h
		db	 62h,0C2h,0C1h,0ABh, 82h, 01h
		db	 11h,0D2h,0D1h,0D2h,0D1h,0D3h
		db	 06h, 03h,0C4h, 42h, 41h,0ABh
		db	 82h, 03h, 11h,0D2h,0D1h,0D3h
		db	0C4h, 08h, 03h, 40h,0ABh, 82h
		db	 02h, 11h,0D2h,0D1h,0D2h,0D3h
		db	0C4h, 07h, 03h,0C4h, 41h,0ABh
		db	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 25h, 00h, 0Eh,0C0h, 1Eh, 24h
		db	 00h, 26h, 80h,0FFh,0FFh,0FFh
		db	0FFh,0FFh, 47h, 00h,0FFh,0D9h
		db	0C3h, 1Bh, 00h,0DCh,0C3h, 0Eh
		db	 0Eh, 49h, 00h,0FFh, 00h,0FFh
		db	0FFh,0FFh,0FFh, 18h,0AFh, 04h
		db	 0Eh
		db	'Jashiin\s room'
		db	0BBh, 00h, 09h, 11h, 11h,0FFh
		db	 0Eh, 0Eh, 10h,0C0h,0EFh,0C3h
		db	 0Ah,0C0h,0A6h,0C3h, 47h, 00h
		db	0FFh
		db	0FFh,0FFh,0FFh
header_1	dd	0FFFFFFFFh

seg_a		ends



		end
