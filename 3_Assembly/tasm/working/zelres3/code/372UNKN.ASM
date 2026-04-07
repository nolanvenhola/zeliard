
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				_372UNKN                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   5-Apr-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    5          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	8
data_2e		equ	3451h			;*
data_13e	equ	2F00h			;*
data_14e	equ	3420h			;*
data_15e	equ	34A0h			;*
data_16e	equ	0FA0Fh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_372UNKN	proc	far

start:
		std				; Set direction flag
		adc	al,0
		add	[bx+si],al
		push	es
		xor	al,0
		dec	si
		stosb				; Store al to es:[di]
		pop	cx
		push	bp
		pop	bx
		jmp	word ptr [bp+di+40h]	;*
		db	 67h, 80h, 6Ch, 01h, 6Eh, 02h
		db	 8Bh, 03h, 93h, 07h, 95h,0A8h
		db	 9Bh,0A0h,0A6h, 54h,0ACh, 08h
		db	0B1h, 20h,0B2h, 50h,0B6h, 0Fh
		db	0B9h, 04h,0BAh, 05h,0BBh, 15h
		db	0C6h,0FAh,0CDh, 0Ah,0CEh,0FEh
data_5		db	0D6h			; Data table (indexed access)
		db	 10h,0FFh,0FFh, 34h, 1Fh, 08h
		db	 34h, 01h, 18h, 34h, 00h, 14h
		db	0F3h, 14h, 00h
		db	'7?7', 0Ah, 1Bh, 'o', 1Bh, '`', 1Bh
		db	'h', 1Bh, 'h'
		db	 12h, 42h, 12h, 42h, 0Fh,0FEh
		db	 0Fh,0FEh, 20h, 34h, 01h, 60h
		db	 80h, 34h, 00h,0CBh, 04h, 80h
		db	 00h,0FEh, 9Ch, 20h, 00h,0FAh
		db	 78h,0C0h, 20h,0FFh,0E0h, 02h
		db	 00h,0FFh,0D1h, 30h, 00h,0FFh
		db	 3Eh, 34h, 01h, 1Fh, 05h, 5Fh
		db	 03h, 83h, 0Ah, 13h, 10h, 0Fh
		db	 1Ah,0AFh, 26h, 0Eh, 3Fh,0EEh
		db	 00h, 0Eh, 0Fh,0EEh, 00h, 1Ch
		db	 05h,0DCh, 00h, 1Dh, 07h, 5Ch
		db	 00h, 18h, 00h, 18h,0FFh,0FCh
		db	 34h, 00h,0FFh,0F1h, 34h, 00h
		db	0FFh, 96h, 34h, 00h,0FAh,0A0h
		db	 34h, 00h, 55h, 4Ch, 34h, 00h
		db	0AAh,0B0h, 34h, 00h, 55h, 40h
		db	 34h, 00h,0A2h, 34h, 02h, 05h
		db	 00h, 05h, 00h, 2Fh, 00h,0ABh
		db	 00h, 17h, 03h, 10h, 08h, 16h
		db	 0Eh, 76h, 21h, 46h, 39h,0F6h
		db	 06h, 00h, 37h,0F8h, 0Ah, 00h
		db	 6Fh,0F4h, 18h, 00h,0DFh,0A8h
		db	0FAh, 00h,0FAh, 00h,0FDh, 40h
		db	0FDh, 40h,0F5h, 34h, 01h,0E8h
		db	 00h,0E8h, 00h, 80h, 00h, 80h
		db	 34h, 24h, 08h, 00h, 08h, 00h
		db	 1Ch, 00h, 1Ch, 34h, 07h, 02h
		db	 00h, 02h, 00h, 07h, 00h, 07h
data_6		db	34h
		db	 03h, 04h, 00h, 2Eh, 00h
data_7		db	60h			; Data table (indexed access)
		db	 00h,0FCh, 0Ch, 00h, 0Dh,0F8h
		db	 16h, 00h, 7Fh,0A0h,0C0h, 40h
		db	0FFh,0F0h,0E0h, 00h,0EEh,0F8h
		db	 50h, 01h, 57h, 73h, 34h, 04h
		db	 80h, 34h, 0Dh, 2Eh, 82h, 2Ch
		db	 22h, 7Fh, 7Bh, 34h, 00h,0A0h
		db	0FFh, 34h, 10h, 01h, 6Dh, 0Bh
		db	0B4h,0BFh,0FFh, 58h, 00h, 5Bh
		db	 00h, 34h, 00h,0FFh,0FEh, 34h
		db	 0Eh, 20h, 00h,0BEh, 54h, 80h
		db	 00h,0F9h, 80h, 34h, 00h,0F5h
		db	 34h, 01h,0A0h, 34h, 10h, 1Ah
		db	 00h, 1Ah, 00h, 0Fh, 00h, 0Fh
		db	 00h, 06h, 00h, 06h, 34h, 03h
		db	 01h, 00h, 01h, 00h, 07h, 00h
		db	 07h, 00h, 1Dh, 00h, 1Dh, 00h
		db	 78h, 00h, 78h,0DFh, 00h,0DFh
		db	 50h, 9Dh, 60h, 9Dh, 60h, 76h
		db	 80h, 76h, 80h,0F8h, 00h,0F8h
		db	 00h,0C0h, 00h,0C0h, 00h, 40h
		db	 00h, 40h, 34h, 08h, 0Fh, 00h
		db	 0Fh, 00h, 01h, 00h, 01h, 34h
		db	 16h,0B5h, 68h,0B5h, 68h, 3Eh
		db	 60h, 3Eh, 60h, 36h, 00h, 36h
		db	 00h, 08h, 00h, 08h, 34h, 12h
		db	 40h, 34h, 01h, 73h, 00h, 02h
		db	 00h, 27h, 00h, 06h, 00h, 0Fh
		db	 00h, 04h, 00h, 4Fh, 00h, 02h
		db	 00h,0A7h, 34h, 01h,0E3h, 00h
		db	 40h, 00h,0F4h, 3Bh,0FFh, 23h
		db	0FFh, 1Fh, 7Dh, 18h, 7Dh, 25h
		db	0F5h, 05h, 00h, 20h, 5Dh, 00h
		db	 5Dh, 51h, 34h, 01h, 6Ah,0A0h
		db	 34h, 00h, 51h, 51h, 34h, 00h
		db	 6Ah,0A8h, 34h, 00h, 40h, 00h
		db	 40h, 00h,0DDh, 00h,0DDh, 00h
		db	0A7h,0B0h, 07h,0B0h,0D8h, 00h
		db	0D8h, 34h, 03h, 49h, 34h, 01h
		db	 25h, 40h, 34h, 00h, 15h, 50h
		db	 34h, 10h, 0Eh, 00h, 0Eh, 00h
		db	 38h, 00h, 38h, 00h, 78h, 00h
		db	 78h, 00h, 74h, 00h, 74h, 34h
		db	 1Dh, 15h, 34h, 00h, 20h, 00h
		db	 78h, 34h, 01h, 3Dh, 34h, 01h
		db	 1Ah, 34h, 01h, 07h, 34h, 01h
		db	 03h, 34h, 01h, 02h, 34h, 06h
		db	 75h, 55h, 34h, 00h, 3Ah,0AAh
		db	 34h, 00h, 1Eh, 54h, 80h, 00h
		db	 0Fh, 4Ah, 40h, 00h, 07h,0A4h
		db	 34h, 00h, 03h,0D2h, 88h, 34h
		db	 00h,0E9h, 98h, 34h, 00h,0F2h
		db	 3Ch, 00h, 82h, 94h, 34h, 00h
		db	 50h,0D1h, 34h, 00h,0A8h,0A0h
		db	 34h, 00h, 4Ah, 69h, 34h, 00h
		db	 92h, 64h, 34h, 00h, 48h, 71h
		db	 34h, 00h, 54h,0E4h, 34h, 00h
		db	0A8h,0EDh, 34h, 08h,0C0h, 34h
		db	 01h, 20h, 34h, 01h, 20h, 34h
		db	 1Ah, 01h, 00h, 01h, 00h, 03h
		db	 00h, 03h, 00h, 02h, 00h, 02h
		db	 34h, 06h,0E8h, 00h,0E8h, 00h
		db	 01h,0AAh, 01h,0AAh,0E9h,0FFh
		db	0E9h,0FFh, 79h,0FFh, 79h,0FFh
		db	 84h, 82h, 84h, 82h,0A0h, 00h
		db	0A0h, 34h, 08h, 07h, 00h, 07h
		db	0AAh,0ABh,0AAh,0ABh,0FFh,0EBh
		db	0FFh,0EBh,0FFh,0ABh,0FFh,0ABh
		db	0BEh,0A7h,0BEh,0A7h, 00h, 06h
		db	 00h, 06h, 00h, 60h, 00h,0FCh
		db	 0Ch, 00h, 0Dh,0F8h, 00h, 3Ah
		db	 6Fh, 80h, 00h, 0Ah,0FDh, 34h
		db	 00h, 0Ch,0E8h, 34h, 00h, 04h
		db	0C0h, 34h, 0Fh, 83h, 44h, 34h
		db	 00h, 24h, 34h, 05h, 80h, 34h
		db	 22h, 01h, 00h, 01h, 00h, 07h
		db	 00h, 07h, 00h, 1Dh, 00h, 1Dh
		db	 00h, 78h, 00h, 78h, 1Fh, 00h
		db	 1Fh, 50h, 1Dh, 60h, 1Dh, 60h
		db	 76h, 80h, 76h, 80h,0F8h, 00h
		db	0F8h, 00h,0C0h, 00h,0C0h, 00h
		db	 40h, 00h, 40h, 34h, 07h, 75h
		db	 55h, 34h, 00h, 3Ah,0AAh, 34h
		db	 00h, 1Eh, 54h, 80h, 00h, 0Fh
		db	 4Ah, 40h, 00h, 07h,0A4h, 34h
		db	 00h, 03h,0D2h, 80h, 34h, 00h
		db	0E9h,0C0h, 34h, 00h,0EAh, 30h
		db	 34h, 07h, 40h, 34h, 01h, 20h
		db	 34h, 01h, 10h, 34h, 01h, 08h
		db	 34h, 01h, 4Dh, 34h, 01h, 17h
		db	0D0h, 34h, 01h, 0Ah, 00h, 1Fh
		db	 00h, 30h, 00h, 7Fh, 34h, 01h
		db	0BFh, 03h, 00h, 03h, 0Ch, 0Fh
		db	 40h, 0Fh, 43h, 02h,0D0h, 02h
		db	0D0h, 0Ch,0A8h, 0Ch,0A8h, 1Fh
		db	 2Ch, 1Fh, 2Eh, 34h, 02h, 20h
		db	 00h,0FCh, 00h, 01h, 00h,0FFh
		db	0C0h, 00h, 50h,0FFh,0FCh, 34h
		db	 00h, 9Fh,0FCh, 34h, 00h,0EFh
		db	0FDh, 34h, 00h,0FDh,0FAh, 34h
		db	 00h, 5Fh,0D5h, 00h, 69h, 0Ch
		db	 00h, 02h, 72h, 02h, 00h, 02h
		db	0B8h, 02h, 80h, 03h, 9Eh, 03h
		db	 80h,0D4h, 03h,0D4h, 00h, 3Fh
		db	 3Ah, 3Fh, 3Ah, 00h, 20h,0C0h
		db	 20h, 01h, 1Eh, 03h, 9Eh, 51h
		db	0D8h, 34h, 00h,0ABh, 91h, 34h
		db	 00h, 55h,0C4h, 34h, 00h, 0Ah
		db	 71h, 34h, 00h,0E8h, 1Ah, 34h
		db	 00h, 1Eh, 80h, 34h, 00h, 01h
		db	0F5h, 34h, 00h, 80h, 0Eh, 84h
		db	 00h, 46h,0C4h, 34h, 00h, 1Eh
		db	 81h, 34h, 00h,0B4h, 34h, 01h
		db	 11h, 11h, 34h, 00h, 44h, 44h
		db	 34h, 00h, 91h, 11h, 34h, 00h
		db	 44h, 44h, 34h, 00h, 91h, 11h
		db	 34h, 08h, 40h, 34h, 01h, 10h
		db	 34h, 05h, 08h, 34h, 01h, 42h
		db	 34h, 01h, 10h,0A8h, 34h, 0Dh
		db	 03h, 00h, 03h, 00h, 0Fh, 00h
		db	 0Fh, 00h, 3Fh, 00h, 3Fh, 00h
		db	 5Dh, 00h, 5Dh, 00h, 0Eh, 00h
		db	 0Eh, 3Eh, 98h, 3Eh, 9Ah, 7Ch
		db	 40h, 7Ch, 40h,0F9h, 40h,0F9h
		db	 40h,0E8h, 80h,0E8h, 80h,0D2h
		db	 00h,0D2h, 01h, 44h, 02h, 44h
		db	 07h, 08h, 0Ch, 08h, 0Fh, 20h
		db	 00h, 20h, 0Fh, 34h, 00h,0AAh
		db	 80h, 00h, 0Eh, 10h, 3Fh, 01h
		db	 50h, 07h,0FFh, 28h, 00h, 7Fh
		db	0FFh, 34h, 00h, 7Fh,0FFh, 34h
		db	 00h,0B5h,0F5h, 34h, 00h, 9Eh
		db	 34h, 01h, 20h, 15h, 20h, 0Eh
		db	0FFh, 8Eh, 84h, 0Fh,0FFh, 4Fh
		db	 00h, 07h,0FEh,0A7h, 00h, 01h
		db	0F5h, 51h, 34h, 00h,0A8h, 34h
		db	 05h, 66h,0AAh, 34h, 00h, 54h
		db	 00h, 42h, 01h, 47h,0B0h, 20h
		db	 10h, 23h, 1Ch, 94h, 00h, 94h
		db	 1Ch,0E2h, 08h,0E2h, 18h, 54h
		db	 00h, 54h, 34h, 0Bh,0C4h, 44h
		db	 34h, 00h, 61h, 11h, 34h, 00h
		db	 5Ah, 44h, 34h, 00h, 1Fh, 51h
		db	 34h, 00h, 04h, 34h, 0Dh, 44h
		db	 42h, 34h, 00h, 11h, 11h, 34h
		db	 00h, 44h, 45h, 34h, 01h,0A8h
		db	 34h, 10h, 52h, 34h, 01h, 08h
		db	 34h, 01h, 40h, 34h, 16h, 05h
		db	 00h, 05h, 34h, 1Ah,0F9h, 81h
		db	0F9h, 81h, 53h, 98h, 53h, 98h
		db	 05h, 2Ch, 05h, 2Ch, 00h, 5Ch
		db	 00h, 5Ch, 34h, 0Eh, 40h, 00h
		db	 40h, 0Eh, 40h, 54h, 40h, 54h
		db	 00h, 7Eh, 00h, 7Eh, 00h,0FFh
		db	 00h,0FFh, 00h, 1Fh, 00h, 1Fh
		db	 01h,0E0h, 01h,0E0h, 01h,0FAh
		db	 01h,0FAh, 01h,0FAh, 01h,0FAh
		db	 34h, 00h, 82h,0A8h, 34h, 00h
		db	0D4h, 00h,0A0h, 00h,0A0h, 00h
		db	 20h, 00h, 20h, 00h, 40h, 00h
		db	 40h, 34h, 03h, 80h, 00h, 80h
		db	 34h, 1Ch, 15h, 00h, 15h, 00h
		db	 3Dh, 00h, 3Dh, 01h,0F5h, 01h
		db	0F5h, 01h,0FAh, 01h,0FAh, 07h
		db	0FAh, 07h,0FAh, 00h, 1Dh, 00h
		db	 1Dh, 0Bh, 00h, 0Bh, 00h, 8Fh
		db	 9Ch, 8Fh, 9Ch,0E7h,0BCh,0E7h
		db	0BCh, 55h, 54h, 55h, 54h, 00h
		db	 06h, 00h, 06h, 00h, 39h, 00h
		db	 3Bh, 00h, 62h, 00h, 07h, 02h
		db	 84h, 02h, 8Eh, 34h, 01h, 0Fh
		db	 34h, 01h, 0Ah, 00h, 08h, 00h
		db	 0Ch, 34h, 01h, 0Ah,0A8h, 30h
		db	0A8h, 30h, 40h, 20h, 41h,0A5h
		db	 0Dh, 2Eh, 0Fh, 2Fh, 30h,0D4h
		db	0BDh,0FFh, 41h,0A0h, 7Bh,0FFh
		db	 41h, 00h, 73h,0FAh, 34h, 00h
		db	 51h, 54h, 34h, 00h, 24h, 14h
		db	 3Bh,0FFh, 23h,0FFh, 1Fh, 7Dh
		db	 18h, 7Dh, 25h,0F5h, 05h, 00h
		db	 20h, 5Dh, 00h, 5Dh, 51h, 34h
		db	 01h, 52h,0A0h, 34h, 00h, 55h
		db	 51h, 34h, 00h, 6Ah,0A8h, 34h
		db	 00h, 40h, 00h, 40h, 00h,0DDh
		db	 00h,0DDh, 00h,0A7h,0B0h, 07h
		db	0B0h,0D8h, 00h,0D8h, 34h, 03h
		db	0A0h, 34h, 01h, 51h, 40h, 34h
		db	 00h,0A8h, 34h, 04h, 06h, 00h
		db	 40h, 00h, 03h, 00h, 40h, 00h
		db	 01h, 00h, 40h, 00h, 03h, 00h
		db	 41h, 00h, 03h, 34h, 01h, 06h
		db	 00h, 46h, 00h, 07h, 00h, 44h
		db	 00h, 07h, 18h, 00h, 1Dh, 44h
		db	 37h, 00h, 3Fh,0C0h, 30h, 00h
		db	 3Fh,0CCh, 18h, 00h, 1Ah,0A1h
		db	 08h, 30h, 08h, 30h, 34h, 00h
		db	 04h, 08h, 03h,0ADh, 03h,0ADh
		db	 03h, 08h, 03h,0AFh, 59h, 00h
		db	 34h, 00h, 6Ah,0AAh, 34h, 00h
		db	 59h, 00h, 34h, 00h, 6Ah,0AAh
		db	 34h, 00h, 59h, 00h, 34h, 00h
		db	 6Ah,0AAh, 34h, 00h, 59h, 00h
		db	 34h, 00h, 6Ah,0AAh, 34h, 00h
		db	 51h, 40h, 34h, 00h,0A8h, 20h
		db	 34h, 00h, 55h, 40h, 34h, 00h
		db	0A8h,0A0h, 34h, 00h, 55h, 40h
		db	 34h, 00h,0A8h,0A0h, 34h, 00h
		db	 55h, 50h, 34h, 00h,0AAh,0A0h
		db	 34h, 03h, 07h, 00h, 44h, 00h
		db	 07h, 00h, 40h, 00h, 03h, 00h
		db	 40h, 00h, 03h, 00h, 40h, 00h
		db	 01h, 00h, 02h, 00h, 03h, 00h
		db	 46h, 00h, 07h, 00h, 44h, 00h
		db	 07h, 34h, 00h, 08h, 34h, 00h
		db	 97h, 00h, 97h
data_8		db	0Dh
		db	 8Fh, 0Dh, 8Fh, 0Dh,0E6h, 0Dh
		db	0E6h, 0Dh,0B3h, 0Dh,0B3h, 19h
		db	0D3h, 19h,0D3h, 19h, 91h, 19h
		db	 91h, 18h,0D0h, 18h,0D0h, 34h
		db	 17h, 03h, 34h, 01h, 07h, 00h
		db	 01h, 55h, 50h, 34h, 00h,0AAh
		db	0A8h, 34h, 00h, 55h, 50h, 34h
		db	 00h,0AAh,0A8h, 34h, 00h, 55h
		db	 50h, 34h, 00h,0AAh,0A8h, 34h
		db	 00h, 55h, 50h, 34h, 00h,0AAh
		db	0A8h, 34h, 01h, 40h, 00h, 07h
		db	 00h, 40h, 00h, 01h, 00h, 40h
		db	 34h, 01h, 80h, 34h, 01h, 80h
		db	 34h, 01h, 80h, 34h, 00h, 01h
		db	 34h, 01h, 01h, 34h, 01h, 18h
		db	 60h, 18h, 68h, 18h, 00h, 1Ah
		db	 0Ch, 18h, 00h, 1Ah, 0Eh, 08h
		db	 01h, 0Ah, 87h, 04h, 02h, 07h
		db	 83h, 06h, 01h, 07h, 81h, 06h
		db	 00h, 07h,0C1h, 02h, 00h, 07h
		db	0C1h, 55h, 54h, 34h, 00h,0AAh
		db	0A8h, 34h, 00h, 55h, 54h, 34h
		db	 00h,0AAh,0A8h, 34h, 00h, 55h
		db	 54h, 34h, 00h,0AAh,0A8h, 34h
		db	 00h, 55h, 54h, 34h, 00h,0AAh
		db	0A8h, 34h, 00h, 01h, 34h, 01h
		db	 02h, 34h, 01h, 02h, 34h, 01h
		db	 04h, 34h, 01h, 04h, 01h, 34h
		db	 00h, 08h, 34h, 01h, 08h, 02h
		db	 34h, 00h, 10h, 34h, 01h, 02h
		db	 00h, 03h,0C0h, 03h, 00h, 03h
		db	0E0h, 01h, 00h, 01h,0E0h, 00h
		db	 80h, 01h,0D0h, 34h, 01h, 60h
		db	 00h, 60h, 00h, 78h, 34h, 01h
		db	 04h, 00h,0F0h, 00h,0F0h, 59h
		db	 00h, 34h, 00h, 6Ah,0AAh, 34h
		db	 00h, 59h, 00h, 34h, 00h, 6Ah
		db	0AAh, 34h, 00h, 59h, 00h, 34h
		db	 00h, 6Ah,0AAh, 34h, 00h, 59h
		db	 00h, 34h, 00h, 6Ah, 2Ah, 34h
		db	 00h,0A6h, 00h, 34h, 00h, 4Eh
		db	 00h, 34h, 00h,0A6h, 00h, 34h
		db	 00h,0AAh, 2Ah, 34h, 00h,0A6h
		db	 00h, 34h, 00h,0AAh, 2Ah, 34h
		db	 00h, 54h, 55h, 34h, 00h,0AAh
		db	 2Ah, 34h, 15h, 01h, 34h, 01h
		db	 02h, 34h, 01h, 04h, 34h, 00h
		db	 10h, 34h, 01h, 20h, 08h, 34h
		db	 00h, 40h, 08h, 34h, 00h, 80h
		db	 14h, 34h, 00h, 80h, 30h, 34h
		db	 00h, 04h, 28h, 34h, 01h, 68h
		db	 34h, 01h,0D0h, 34h, 01h,0FCh
		db	 00h,0FCh, 00h,0FFh, 00h,0FFh
		db	 00h, 1Fh, 00h, 1Fh, 00h,0E3h
		db	 00h,0E3h, 00h,0FCh, 00h,0FCh
		db	 00h,0FFh, 00h,0FFh, 00h,0FFh
		db	 00h,0FFh, 01h,0FEh, 01h,0FEh
		db	 35h, 15h, 34h, 00h, 2Ah, 2Ah
		db	 34h, 00h, 35h, 15h, 34h, 00h
		db	 2Ah, 2Ah, 34h, 00h, 35h, 15h
		db	 34h, 00h, 2Ah, 2Ah, 34h, 00h
		db	 35h, 15h, 34h, 00h, 2Ah, 8Ah
		db	 34h, 00h, 54h, 15h, 34h, 00h
		db	0AAh, 0Ah, 34h, 00h, 54h, 15h
		db	 34h, 00h,0AAh, 0Ah, 34h, 00h
		db	 55h, 15h, 34h, 00h,0AAh, 0Ah
		db	 34h, 00h, 55h, 15h, 34h, 00h
		db	0AAh, 8Ah, 34h, 01h, 08h, 34h
		db	 01h, 38h, 34h, 01h, 07h, 34h
		db	 14h, 08h,0D4h, 34h, 00h, 01h
		db	0A8h, 34h, 00h, 83h, 54h, 34h
		db	 00h, 7Fh, 48h, 34h, 00h, 03h
		db	0D2h, 34h, 05h, 15h, 00h, 15h
		db	 00h, 3Dh, 00h, 3Dh, 01h,0FDh
		db	 01h,0FDh, 01h,0EAh, 01h,0EAh
		db	 07h,0FAh, 07h,0FAh, 00h, 1Dh
		db	 00h, 1Dh, 0Bh, 00h, 0Bh, 00h
		db	 8Fh, 9Ch, 8Fh, 9Ch,0E7h,0BCh
		db	0E7h,0BCh, 55h, 54h, 55h, 54h
		db	 35h, 05h, 34h, 00h, 2Ah, 8Ah
		db	 34h, 00h, 35h, 45h, 34h, 00h
		db	 3Ah, 82h, 34h, 00h, 35h, 51h
		db	 34h, 00h, 3Ah,0A0h, 34h, 00h
		db	 1Dh, 50h, 34h, 00h, 0Fh,0A8h
		db	 34h, 00h, 55h, 05h, 34h, 00h
		db	0AAh, 88h, 34h, 00h, 55h, 04h
		db	 34h, 00h,0AAh, 82h, 34h, 00h
		db	 55h, 40h, 34h, 00h,0AAh, 80h
		db	 34h, 00h, 55h, 41h, 34h, 00h
		db	 02h,0A0h, 34h, 09h, 08h, 00h
		db	 5Fh, 00h, 60h, 01h, 7Ch, 00h
		db	 80h, 03h,0FAh, 04h, 00h, 0Fh
		db	0FCh, 10h, 00h, 7Fh,0D2h, 34h
		db	 00h,0FEh,0ADh, 34h, 0Fh, 01h
		db	 00h, 03h, 00h, 04h, 00h, 07h
		db	 34h, 01h, 0Ch, 00h, 08h, 00h
		db	 0Ch, 00h, 08h, 00h, 7Fh, 00h
		db	0C0h, 02h,0FEh, 00h, 04h, 07h
		db	0E7h, 08h, 00h, 1Fh, 3Fh,0C0h
		db	 00h,0F7h,0F5h, 34h, 00h,0FAh
		db	 80h, 34h, 00h, 38h, 00h, 80h
		db	 00h,0D0h, 34h, 01h,0B7h, 50h
		db	 80h, 00h,0EAh, 34h, 01h,0D4h
		db	 34h, 01h, 50h, 34h, 00h, 40h
		db	 34h, 05h, 40h, 34h, 01h, 40h
		db	 34h, 05h, 40h, 34h, 01h, 40h
		db	 34h, 01h, 40h, 34h, 01h, 40h
		db	 34h, 05h, 40h, 34h, 01h, 40h
		db	 34h, 01h, 40h, 34h, 01h, 40h
		db	 34h, 01h, 40h, 34h, 01h, 80h
		db	 34h, 01h, 80h, 34h, 01h, 80h
		db	 34h, 00h, 01h, 34h, 01h, 01h
		db	 34h, 02h, 60h, 00h, 0Dh, 34h
		db	 01h, 01h, 00h, 28h, 00h, 03h
		db	 34h, 14h, 40h, 34h, 01h,0EDh
		db	 15h, 10h, 24h, 2Dh,0DBh, 03h
		db	 00h, 04h,0EEh, 04h, 00h, 1Bh
		db	 81h,0C0h, 00h, 28h, 34h, 09h
		db	 0Ah,0D4h, 08h,0D0h,0B7h, 2Fh
		db	 34h, 00h,0FDh,0ADh, 28h, 00h
		db	0D7h,0FEh, 00h, 80h, 57h, 6Bh
		db	 34h, 0Dh, 01h, 02h, 80h, 2Fh
		db	0AFh, 58h, 10h, 5Bh, 00h, 34h
		db	 00h,0BFh,0FEh, 34h, 00h, 57h
		db	 55h, 34h, 00h, 02h,0A8h, 34h
		db	 01h, 02h, 34h, 03h, 06h, 00h
		db	 06h, 00h, 39h, 00h, 3Bh, 00h
		db	 62h, 00h, 07h, 02h, 8Ch, 02h
		db	 9Eh, 00h, 30h, 00h, 7Fh, 00h
		db	 80h, 02h,0FAh, 02h, 00h, 07h
		db	0E4h, 04h, 00h, 0Ch, 5Eh, 00h
		db	 26h, 0Bh,0FFh, 09h, 00h, 5Fh
		db	0FFh, 34h, 00h, 7Fh,0FFh, 34h
		db	 00h, 3Fh,0B4h, 34h, 00h, 05h
		db	 7Fh, 00h, 40h, 34h, 01h, 40h
		db	 34h, 01h, 40h, 34h, 00h, 90h
		db	 03h,0FDh, 57h, 00h, 40h, 5Bh
		db	 00h, 34h, 00h, 5Bh, 00h, 34h
		db	 00h,0ABh, 69h, 34h, 00h,0EDh
		db	 40h, 34h, 01h, 08h, 03h,0ADh
		db	 03h,0ADh, 03h, 08h, 03h,0AFh
		db	 3Bh,0FFh, 23h,0FFh, 1Fh, 7Dh
		db	 18h, 7Dh, 25h,0F5h, 05h, 00h
		db	 20h, 5Dh, 00h, 5Dh, 51h, 34h
		db	 02h,0A0h, 34h, 00h, 28h, 51h
		db	0FCh, 00h, 80h, 28h,0F8h, 00h
		db	 08h, 55h,0FEh, 34h, 00h, 88h
		db	0F8h, 34h, 00h, 41h,0F0h, 00h
		db	 02h, 2Ah, 34h, 00h, 55h, 15h
		db	 34h, 00h, 6Ah,0AAh, 34h, 00h
		db	 59h, 00h, 34h, 00h, 6Ah,0AAh
		db	 34h, 01h,0C0h, 00h,0E8h, 0Ah
		db	 00h, 1Fh, 7Ch, 12h, 00h, 3Bh
		db	0CCh, 00h, 80h, 1Ch,0E0h, 01h
		db	 05h, 08h, 34h, 00h, 2Ah, 34h
		db	 01h, 05h, 34h, 01h, 02h, 34h
		db	 00h, 4Fh,0F4h, 34h, 00h, 4Eh
		db	 00h, 34h, 00h, 59h, 00h, 34h
		db	 00h,0A2h,0AAh, 34h, 00h, 50h
		db	 55h, 34h, 00h,0AEh, 2Ah, 34h
		db	 00h, 55h,0C5h, 34h, 00h,0AAh
		db	0A0h, 34h, 00h, 05h,0F5h, 34h
		db	 00h, 4Eh, 00h, 34h, 00h, 59h
		db	 00h, 34h, 00h, 4Eh, 00h, 34h
		db	 00h, 59h, 00h, 34h, 00h, 4Eh
		db	 00h, 34h, 00h, 59h, 00h, 34h
		db	 00h, 4Eh, 00h, 34h, 00h, 0Fh
		db	0F5h, 34h, 00h,0AAh,0A0h, 34h
		db	 00h, 59h, 00h, 34h, 00h, 4Eh
		db	 00h, 34h, 00h, 59h, 00h, 34h
		db	 00h, 4Eh, 00h, 34h, 00h, 59h
		db	 00h, 34h, 00h, 4Eh, 00h, 34h
		db	 00h, 3Bh,0FFh, 23h,0FFh, 1Fh
		db	 7Dh, 18h, 7Dh, 05h,0F5h, 05h
		db	 00h,0A0h, 5Dh, 00h, 5Dh, 54h
		db	 34h, 01h,0AAh,0A0h, 34h, 00h
		db	 59h, 00h, 34h, 00h, 4Eh, 00h
		db	 34h, 00h, 40h, 00h, 40h, 00h
		db	0DDh, 00h,0DDh, 00h,0A7h,0B0h
		db	 07h,0B0h,0D8h, 00h,0D8h, 34h
		db	 03h, 80h, 34h, 01h, 44h, 34h
		db	 01h,0AAh, 34h, 01h, 55h, 54h
		db	 34h, 00h, 2Ah,0AAh, 34h, 00h
		db	 05h, 55h, 34h, 00h, 02h,0AAh
		db	 34h, 01h, 55h, 34h, 01h, 2Ah
		db	 34h, 01h, 05h, 34h, 01h, 02h
		db	 34h, 00h, 59h, 00h, 34h, 00h
		db	 2Ah,0AAh, 34h, 00h, 45h, 55h
		db	 34h, 00h,0A0h,0AAh, 34h, 00h
		db	 5Ch, 15h, 34h, 00h,0ABh, 8Ah
		db	 34h, 00h, 55h,0C1h, 34h, 00h
		db	0AAh,0B8h, 34h, 00h
		db	'Y', 0
		db	'4', 0
		db	'N', 0
		db	'4', 0
		db	'Y', 0
		db	'4', 0
		db	'N', 0
		db	'4', 0
		db	'Y', 0
		db	'4', 0
		db	'N', 0
		db	'4', 0
		db	'UP4', 0
		db	'N', 0
		db	'4', 0
		db	'Y', 0
		db	'4', 0
		db	'N', 0
		db	'4', 0
		db	'Y', 0
		db	'4', 0
		db	'N', 0
		db	'4', 0
		db	'Y', 0
		db	'4', 0
		db	'N', 0
		db	'4', 0
		db	'Y', 0
		db	'4', 0
		db	 0Ah,0AAh, 34h, 00h, 55h, 40h
		db	 34h, 00h,0AAh,0A0h, 34h, 00h
		db	 55h, 50h, 34h, 00h,0AAh,0A0h
		db	 34h, 00h, 55h, 50h, 34h, 00h
		db	0AAh,0A8h, 34h, 00h, 55h, 50h
		db	 34h, 00h,0AAh,0A8h, 34h, 00h
		db	 59h, 00h, 34h, 00h, 2Ah,0AAh
		db	 34h, 00h, 45h, 55h, 34h, 00h
		db	0A0h,0AAh, 34h, 00h, 54h, 15h
		db	 34h, 00h,0AAh, 8Ah, 34h, 00h
		db	 55h, 41h, 34h, 00h,0AAh,0A8h
		db	 34h, 00h, 50h, 55h, 34h, 00h
		db	0AAh, 82h, 34h, 00h, 59h, 00h
		db	 34h, 00h, 4Eh, 00h, 34h, 00h
		db	 59h, 00h, 34h, 00h, 4Eh, 00h
		db	 34h, 00h, 59h, 00h, 34h, 00h
		db	 4Eh, 00h, 34h, 00h, 55h, 50h
		db	 34h, 00h,0AAh,0A8h, 34h, 00h
		db	 55h, 50h, 34h, 00h,0AAh,0A8h
		db	 34h, 00h, 41h, 50h, 34h, 00h
		db	0A8h, 28h, 34h, 00h, 55h, 34h
		db	 01h,0AAh, 88h, 34h, 00h, 59h
		db	 00h
		db	'4', 0
		db	'N', 0
		db	'4', 0
		db	'Y', 0
		db	'4', 0
		db	'N', 0
		db	'4', 0
		db	'Y', 0
		db	'4', 0
		db	'N', 0
		db	'4', 0
		db	'Y', 0
		db	'4', 0
		db	'N', 0
		db	'4', 0
		db	'Y', 0
		db	'4', 0
		db	 2Ah,0AAh, 34h, 00h, 05h, 55h
		db	 34h, 00h, 02h,0AAh, 34h, 01h
		db	 55h, 34h, 01h,0AAh, 34h, 01h
		db	 55h, 34h, 01h, 0Ah, 34h, 00h
		db	 55h, 50h, 34h, 00h,0AAh,0A8h
		db	 34h, 00h, 15h, 50h, 34h, 00h
		db	 82h,0A0h, 34h, 00h, 41h, 50h
		db	 34h, 00h,0A0h, 28h, 34h, 00h
		db	 51h, 10h, 34h, 00h, 95h, 00h
		db	 34h, 01h, 05h, 34h, 00h, 02h
		db	 22h, 34h, 00h, 80h, 89h, 80h
		db	 00h, 42h, 20h, 40h, 34h, 00h
		db	 8Ah, 00h, 02h, 42h, 23h, 40h
		db	 03h, 40h, 82h, 40h, 02h, 80h
		db	 03h, 80h, 03h, 55h, 14h, 34h
		db	 00h,0AAh, 88h, 34h, 00h, 55h
		db	 40h, 34h, 00h,0AAh,0A8h, 34h
		db	 00h, 15h, 54h, 34h, 00h, 0Ah
		db	 28h, 34h, 00h,0A5h, 14h,0A0h
		db	 00h,0A2h, 2Ah,0A0h, 34h, 18h
		db	 15h, 00h, 15h, 00h, 3Dh, 00h
		db	 3Dh, 00h, 03h, 00h, 03h, 00h
		db	 03h, 00h, 03h, 00h, 03h, 00h
		db	 03h, 00h, 02h, 00h, 02h, 00h
		db	 01h, 00h, 01h, 00h, 03h, 00h
		db	 03h, 00h, 07h, 00h, 07h, 00h
		db	 02h, 00h, 02h,0E1h, 44h,0E0h
		db	 00h,0F8h,0A2h,0F8h, 00h,0F8h
		db	 54h,0F8h, 00h, 02h, 0Ah, 02h
		db	 00h,0FFh, 04h,0FFh, 00h,0D4h
		db	 82h,0D4h, 80h,0FFh, 40h,0FFh
		db	 40h,0AAh,0A0h,0AAh,0A0h, 34h
		db	 0Ah, 3Ah, 00h, 10h, 00h, 7Fh
		db	 34h, 01h,0FFh, 80h, 40h, 00h
		db	0FDh, 40h, 34h, 00h,0EAh,0A8h
		db	 34h, 15h, 02h, 34h, 01h, 07h
		db	 34h, 01h, 0Bh, 34h, 01h, 1Fh
		db	 00h, 06h, 00h,0FFh, 00h, 10h
		db	 01h,0FFh, 00h, 40h, 0Bh,0FFh
		db	 01h, 00h, 5Fh,0FFh, 34h, 00h
		db	0FFh,0FEh, 0Eh, 00h, 7Fh,0FDh
		db	 30h, 00h,0FFh,0FAh,0A4h
loc_3:
;*		add	ch,dl
		db	 00h,0D5h		;  Fixup - byte match
		push	sp
		xor	al,0
		dec	si
		add	[si],dh
;*		add	[bx+di+0],bl
		db	 00h, 59h, 00h		;  Fixup - byte match
		db	 34h, 00h, 4Eh, 00h, 34h, 00h
		db	 59h, 00h, 34h, 00h,0AAh, 8Ah
		db	 34h, 00h, 55h, 15h, 34h, 00h
		db	0AAh, 0Ah, 34h, 04h, 80h, 34h
		db	 01h, 40h, 34h, 01h,0A8h, 34h
		db	 01h, 55h, 40h, 34h, 00h,0AAh
		db	0A8h, 34h, 00h, 59h, 00h, 34h
		db	 00h, 4Eh, 00h, 34h, 01h, 5Fh
		db	 34h, 01h,0FFh, 00h, 0Ah, 01h
		db	0FFh, 00h, 04h, 03h,0FFh, 00h
		db	 1Dh, 01h,0FFh, 00h, 28h, 03h
		db	0FFh, 00h, 09h, 07h,0FFh, 34h
		db	 00h, 0Ah,0AAh, 34h, 00h,0FFh
		db	0FDh,0A8h, 00h,0FFh,0FAh, 20h
		db	 00h,0FFh,0FDh, 80h, 00h,0FFh
		db	0FAh, 20h, 00h,0FFh,0FDh, 80h
		db	 00h,0FFh,0FEh, 48h, 00h, 55h
		db	0DFh, 34h, 01h, 0Ah, 34h, 00h
		db	 55h, 15h, 34h, 00h,0AAh, 2Ah
		db	 34h, 00h, 54h, 55h, 34h, 00h
		db	0AAh, 2Ah, 34h, 00h, 54h, 55h
		db	 34h, 00h,0AAh, 2Ah, 34h, 00h
		db	 54h, 15h, 34h, 00h,0AAh, 0Ah
		db	 34h, 00h, 59h, 00h, 34h, 00h
		db	 4Eh, 00h, 34h, 00h, 59h, 00h
		db	 34h, 00h, 4Eh, 00h, 34h, 00h
		db	 59h, 00h, 34h, 00h,0AAh, 8Ah
		db	 34h, 00h, 55h, 15h, 34h, 00h
		db	0AAh, 0Ah, 34h, 00h, 50h, 34h
		db	 01h,0AAh, 34h, 01h, 55h, 40h
		db	 34h, 00h, 4Eh, 00h, 34h, 00h
		db	 59h, 00h, 34h, 00h, 4Eh, 00h
		db	 34h, 00h, 59h, 00h, 34h, 00h
		db	 4Eh, 00h, 34h, 00h, 3Bh,0FFh
		db	 23h,0FFh, 1Fh, 7Dh, 18h, 7Dh
		db	 05h,0F5h, 05h, 34h, 00h, 5Dh
		db	 00h, 5Dh, 34h, 05h,0A8h, 40h
		db	 60h, 01h, 76h,0A0h, 40h, 01h
		db	0FCh, 40h, 00h, 40h, 00h,0DDh
		db	 00h,0DDh, 00h,0A7h,0B0h, 07h
		db	0B0h,0D8h, 00h,0D8h, 34h, 05h
		db	 08h, 34h, 01h, 04h, 34h, 01h
		db	 04h, 00h, 55h, 15h, 34h, 00h
		db	 0Ah, 8Ah, 34h, 00h, 01h, 15h
		db	 34h, 01h, 8Ah, 34h, 01h, 55h
		db	 34h, 01h,0EAh, 34h, 01h, 7Dh
		db	 00h, 20h, 00h, 0Fh, 00h, 06h
		db	 50h, 34h, 00h,0FDh,0A0h, 34h
		db	 00h, 2Fh, 50h, 34h, 00h, 31h
		db	0A8h, 34h, 00h, 1Ch, 54h, 34h
		db	 00h, 1Ch,0AAh, 80h, 00h, 16h
		db	 55h, 50h, 00h, 05h, 4Eh, 00h
		db	 34h, 02h, 0Ah, 34h, 01h, 14h
		db	 34h, 01h, 88h, 34h, 01h, 14h
		db	 34h, 01h, 08h, 34h, 01h, 80h
		db	 34h, 01h,0E2h, 34h, 01h, 50h
		db	 34h, 01h, 22h, 00h, 80h, 34h
		db	 01h, 40h, 00h, 08h, 00h,0A0h
		db	 34h, 01h, 50h, 34h, 01h,0A8h
		db	 34h, 01h, 50h, 34h, 01h,0A8h
		db	 34h, 01h, 51h, 55h, 34h, 00h
		db	0A2h,0AAh, 34h, 00h, 51h, 55h
		db	 34h, 00h,0A2h,0AAh, 34h, 00h
		db	 51h, 55h, 34h, 00h,0A8h,0AAh
		db	 34h, 00h, 50h, 55h, 34h, 00h
		db	0A8h, 2Ah, 34h, 00h, 50h, 34h
		db	 01h,0A0h, 34h, 01h, 50h, 34h
		db	 01h,0A8h, 34h, 01h, 54h, 34h
		db	 01h,0AAh, 80h, 34h, 00h, 55h
		db	 50h, 34h, 00h, 4Eh, 00h, 34h
		db	 0Ch, 80h, 34h, 01h, 54h, 34h
		db	 01h,0AAh,0A8h, 34h, 00h, 55h
		db	 40h, 34h, 00h,0A8h, 34h, 02h
		db	 1Fh, 00h, 1Fh, 00h, 1Fh, 00h
		db	 1Fh, 34h, 03h, 0Fh, 00h, 0Fh
		db	 00h, 0Fh, 00h, 0Fh, 00h, 07h
		db	 00h, 07h, 00h, 07h, 00h, 07h
		db	 00h, 07h, 00h, 07h,0E0h, 00h

locloop_4:
		loopnz	$+2			; Loop if zf=0, cx>0

		call	$-17FDh
		add	[si],al
		add	[si],al
;*		add	ah,dh
		db	 00h,0F4h		;  Fixup - byte match
;*		add	ah,dh
		db	 00h,0F4h		;  Fixup - byte match
;*		add	ah,ah
		db	 00h,0E4h		;  Fixup - byte match
;*		add	ah,ah
		db	 00h,0E4h		;  Fixup - byte match
;*		add	dl,ah
		db	 00h,0E2h		;  Fixup - byte match
;*		add	dl,ah
		db	 00h,0E2h		;  Fixup - byte match
;*		add	ah,dh
		db	 00h,0F4h		;  Fixup - byte match
;*		add	ah,dh
		db	 00h,0F4h		;  Fixup - byte match
;*		add	dl,bh
		db	 00h,0FAh		;  Fixup - byte match
;*		add	dl,bh
		db	 00h,0FAh		;  Fixup - byte match
;*		add	ch,dh
		db	 00h,0F5h		;  Fixup - byte match
;*		add	ch,dh
		db	 00h,0F5h		;  Fixup - byte match
;*		add	al,bh
		db	 00h,0F8h		;  Fixup - byte match
;*		cmp	al,80h
		db	 80h,0F8h, 80h		;  Fixup - byte match
		stc				; Set carry flag
;*		add	cl,bh
		db	 00h,0F9h		;  Fixup - byte match
		add	[bp+si],al
		add	byte ptr [bp+si],80h
		inc	word ptr [bx+si]
		inc	word ptr [bx+si]
;*		aam	80h			; undocumented inst
		db	0D4h, 80h		;  Fixup - byte match
;*		aam	80h			; undocumented inst
		db	0D4h, 80h		;  Fixup - byte match
		inc	word ptr [bx+si-1]
		inc	ax
		stosb				; Store al to es:[di]
		mov	al,byte ptr ds:[0A0AAh]
		xor	al,17h
		adc	ax,34h
		add	ax,346Fh
		sbb	[bx+di],ax
		xor	al,0
;*		aad	57h			; 'W' undocumented inst
		db	0D5h, 57h		;  Fixup - byte match
		add	byte ptr [bx+di],34h	; '4'
		push	ss
		push	bp
		db	0DFh, 34h, 00h, 5Bh, 00h,0A2h
		db	 34h, 17h, 50h, 34h, 01h,0FDh
		db	 5Dh, 34h, 1Ch,0F5h,0D4h, 34h
		db	 1Eh, 06h, 00h, 3Ch, 9Fh, 34h
		db	 00h, 60h, 17h, 34h, 00h, 80h
		db	 05h, 34h, 00h, 80h, 02h, 34h
		db	 01h, 43h, 34h, 00h, 94h, 03h
		db	 34h, 00h, 40h, 07h, 34h, 01h
		db	 0Fh, 00h, 02h, 5Bh, 00h, 08h
		db	0A0h,0FFh,0F6h, 34h, 00h, 57h
		db	 7Fh, 00h, 28h,0BFh,0FEh, 02h
		db	 80h,0FFh,0EDh, 28h, 00h,0FFh
		db	0AAh, 80h, 00h,0F7h, 55h, 34h
		db	 00h,0CAh,0A8h, 34h, 00h,0DBh
		db	0FFh, 01h, 29h, 7Fh,0FAh, 30h
		db	 00h,0EAh,0B5h, 34h, 00h,0AAh
		db	0A0h, 34h, 00h, 54h, 1Fh, 00h
		db	 14h,0A3h,0FEh, 02h, 80h, 1Fh
		db	0F5h, 04h, 00h,0FFh,0AAh, 30h
		db	 00h, 5Bh, 00h, 40h, 00h,0AAh
		db	0A8h, 34h, 00h, 10h, 7Fh, 34h
		db	 00h,0FFh,0EAh, 64h, 80h,0FAh
		db	0A5h, 34h, 00h,0AAh,0A8h, 34h
		db	 00h, 55h, 41h, 34h, 00h,0AAh
		db	 02h, 34h, 00h,0FFh,0FEh, 34h
		db	 00h, 2Ah,0BFh, 34h, 00h,0FEh
		db	0E1h, 34h, 00h,0AAh, 74h, 34h
		db	 00h, 57h,0C9h, 02h, 00h,0AFh
		db	 22h, 08h, 00h, 7Ch, 80h, 20h
		db	 00h,0F4h, 28h, 80h, 00h,0A2h
		db	 00h, 07h,0C0h,0ECh, 00h, 0Fh
		db	0E0h, 40h, 00h, 1Fh,0E0h, 40h
		db	 00h, 07h,0F0h, 00h, 80h, 01h
		db	0D8h, 34h, 00h, 02h,0E8h, 01h
		db	 00h, 07h,0D4h, 03h, 00h, 07h
		db	0C4h, 00h

locloop_5:
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		xor	al,1
		pop	ds
		xor	al,1
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		xor	al,1
		push	ds
		xor	al,1
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		xor	al,1
		push	cs
		xor	al,1
		push	es
		xor	al,1
		add	[si],si
		add	ds:data_2e[di],dh
		add	byte ptr ss:[0Bh][bp+si],ch
		add	[bx+si+5Fh],dx
		add	[si],al
		movsw				; Mov [si] to es:[di]
		aas				; Ascii adjust
		xor	al,0
		inc	cx
		jg	$+2			; delay for I/O
		xor	ss:data_7[bp+si],al
		inc	ax
		pop	es
		call	sub_1
		scasw				; Scan es:[di] for ax

_372UNKN	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		mov	al,ds:data_1e
		call	word ptr [di-80h]
;*		add	dl,bh
		db	 00h,0FAh		;  Fixup - byte match
		stosb				; Store al to es:[di]
		xor	al,0
		cmc				; Complement carry
		push	bp
		xor	al,0
;*		jmp	far ptr loc_9		;*
sub_1		endp

		db	0EAh
		dw	34A2h, 0D500h		;  Fixup - byte match
			                        ;* No entry point to code
		push	cx
		xor	al,0
		stosb				; Store al to es:[di]
		mov	al,data_5
		or	ax,3454h
		add	[bp+si],al
		mov	dh,[si]
		add	[si+5],dl
		add	[bx+di],al
		or	cl,[bp+di+34h]
		add	[bx],dx
		add	[si],al
;*		sub	byte ptr [bx],34h	; '4'
		db	 82h, 2Fh, 34h		;  Fixup - byte match
		add	[bx+si+57h],dl
		add	ds:data_13e[bx+di],bh
		xor	al,1
		pop	di
		add	[si],al
		add	[bx],ch
		add	[si],al
		loopnz	locloop_5		; Loop if zf=0, cx>0

		xor	al,0
;*		sal	byte ptr [si],cl	; Shift w/zeros fill
		db	0D2h, 34h		;  Fixup - byte match
;*		add	ax,cx
		db	 01h,0C8h		;  Fixup - byte match
		nop
		xor	al,0
		mov	ds:data_14e,al
		add	[bx+si-80h],cl
		xor	al,0
		and	ch,[bx+si]
		xor	al,0
		rol	data_5[bx+si],1		; Rotate
		stosb				; Store al to es:[di]
		and	al,34h			; '4'
		add	[bp+si],al
		add	[bx],cl
		inc	sp
		xor	al,0
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
                           lock	xor	al,0
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		inc	ax
		xor	al,0
		push	es
		mov	ax,4000h
		add	ax,0F6h
		xor	[bp+di],al
		std				; Set direction flag
		xor	al,0
		add	dh,dh
		add	[bx+si],cl
;*		add	[di+0],di
		db	 01h, 7Dh, 00h		;  Fixup - byte match
		db	 1Fh, 05h, 5Fh, 03h, 83h, 0Ah
		db	 13h, 10h, 0Fh, 1Ah,0AFh, 26h
		db	 0Eh, 3Fh,0EEh, 00h, 0Eh, 0Fh
		db	0EEh, 00h, 1Ch, 05h,0DCh, 00h
		db	 1Dh, 87h, 5Ch, 00h, 18h
data_11		dw	18D0h			; Data table (indexed access)
		db	 01h,0A5h, 34h, 01h, 40h, 34h
		db	 01h, 20h, 34h, 01h, 02h, 34h
		db	 01h, 10h, 34h, 01h, 04h, 34h
		db	 01h, 01h, 34h, 04h, 40h, 57h
		db	 34h, 00h,0A8h, 2Fh, 34h, 01h
		db	 57h, 00h, 6Eh, 00h, 2Bh, 34h
		db	 00h, 21h, 15h, 00h, 01h, 8Ah
		db	 0Eh, 34h, 00h, 01h, 45h, 34h
		db	 00h, 40h, 2Ah, 34h, 00h,0D4h
		db	 88h, 34h, 00h,0EAh, 22h, 34h
		db	 00h,0D5h, 48h, 34h, 00h,0FAh
		db	0A0h, 34h, 00h,0FDh, 55h, 80h
		db	 00h,0BFh,0AAh, 10h, 00h,0FFh
		db	0F5h, 02h, 00h,0BFh,0FAh, 00h
		db	 80h, 00h, 02h, 00h, 7Fh, 34h
		db	 01h, 2Fh, 34h, 01h, 0Bh, 80h
		db	 34h, 00h, 03h, 20h, 34h, 00h
		db	 02h, 48h, 34h, 01h, 52h, 34h
		db	 01h,0A8h, 40h, 34h, 00h, 80h
		db	 05h,0F4h,0A5h, 00h, 8Dh,0D2h
		db	0E9h, 00h, 07h, 86h,0A4h, 01h
		db	0A5h, 2Bh,0F4h, 04h, 01h, 3Fh
		db	0E1h, 30h, 00h, 7Fh,0E1h, 00h
		db	 01h,0FFh,0C1h, 40h, 01h,0FFh
		db	0C7h,0FDh, 00h,0FDh, 00h,0F7h
		db	0B0h,0F7h, 90h,0DEh,0F0h,0DEh
		db	 10h, 77h, 40h, 00h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		inc	ax
;*		aad	0			; undocumented inst
		db	0D5h, 00h		;  Fixup - byte match
;*		aad	34h			; '4' undocumented inst
		db	0D5h, 34h		;  Fixup - byte match
		add	[bx+di+40h],ax
		xor	al,0
;*		jmp	far ptr loc_11		;*
sub_2		endp

		db	0EAh
		dw	8040h, 0FE00h		;  Fixup - byte match
			                        ;* No entry point to code
		mov	al,byte ptr ds:[1108h]
		xor	al,0
		add	[bx+si],bp
		xor	al,1
		and	ax,134h
		add	[si],si
		adc	[di],dl
		inc	word ptr [bx+si]
		sbb	[bp+di-1],bh
		xor	al,0
		push	di
		inc	word ptr [bx+si]
		add	ch,[bp+di]
;*		jg	loc_6			;*Jump if >
		db	 7Fh, 34h		;  Fixup - byte match
		add	[di],al
		push	di
		xor	al,1
		and	al,34h			; '4'
		or	[di+34h],dl
		add	ss:data_15e[bp+si],bp
;*		add	ch,dl
		db	 00h,0D5h		;  Fixup - byte match
		push	sp
		add	byte ptr [bx+si],0FAh
		stosb				; Store al to es:[di]
		xor	al,0
		std				; Set direction flag
		push	bp
		adc	[bx+si],al
		jmp	dword ptr ss:[4][bp+si]	;*
			                        ;* No entry point to code
		aas				; Ascii adjust
		cmc				; Complement carry
		add	ds:data_16e[bx+si],al
		xor	al,2
		inc	word ptr [bp+di+34h]
		add	[si-7Dh],bl
		xor	al,1
		add	[bx+si],cx
		add	[di],bl
;*		add	al,[bx+si+0]
		db	 02h, 40h, 00h		;  Fixup - byte match
		db	 02h, 80h,0A8h, 00h, 01h, 40h
		db	 49h,0FCh, 09h, 40h,0A9h,0D5h
		db	 34h, 00h, 80h, 00h,0FFh,0A0h
		db	 20h, 00h,0FFh, 20h, 04h, 00h
		db	0DEh, 08h, 20h, 00h,0F4h, 90h
		db	 34h, 00h, 7Fh,0A8h, 08h, 00h
		db	 3Fh,0D5h, 04h, 19h, 2Fh, 3Fh
		db	 00h,0A0h, 08h,0BFh, 34h, 18h
		db	 80h, 34h, 01h,0C0h, 00h, 03h
		db	0FDh, 00h, 10h, 00h, 7Fh, 00h
		db	 02h, 00h, 3Fh, 00h, 06h, 00h
		db	 1Fh, 00h, 01h, 00h, 0Fh, 00h
		db	 01h, 00h, 07h, 00h, 01h, 00h
		db	 07h, 34h, 01h, 06h, 34h, 00h
		db	 54h, 34h, 01h,0A9h, 54h, 01h
		db	 54h,0D3h, 88h, 03h, 88h,0E3h
		db	 99h, 03h, 99h,0C3h, 88h, 03h
		db	 88h, 83h,0C8h, 03h,0C9h, 03h
		db	0C0h, 03h,0C1h, 61h,0C2h, 61h
		db	0C2h, 42h, 00h, 02h,0FEh, 34h
		db	 00h, 14h, 79h, 48h, 00h,0FEh
		db	0ADh, 80h, 00h, 9Fh,0A0h, 80h
		db	 00h,0E5h, 80h, 40h, 00h, 7Dh
		db	 34h, 01h, 94h, 34h, 05h,0C0h
		db	 34h, 01h, 80h, 34h, 18h, 0Ch
		db	 34h, 01h, 0Ch, 34h, 01h, 08h
		db	 34h, 01h, 08h, 34h, 10h, 41h
		db	0F0h, 41h,0F0h, 00h,0FAh, 50h
		db	0FAh, 00h, 3Fh, 68h, 3Fh, 00h
		db	 03h, 74h, 07h, 34h, 00h, 7Ah
		db	 10h, 34h, 00h, 3Dh, 15h, 34h
		db	 00h, 7Ah,0C5h, 20h, 00h, 7Dh
		db	 41h, 50h, 20h, 58h,0B1h, 00h
		db	 00h, 20h, 00h, 82h, 00h, 82h
		db	 00h,0F4h, 50h,0F4h, 50h, 7Dh
		db	 00h
loc_7:
		jge	$+2			; delay for I/O
		pop	es
;*                         lock	xchg	si,ax
		db	0F0h, 87h,0F0h		;  Fixup - byte match
		xor	al,0
		clc				; Clear carry flag
		add	[bx+si],ah
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		sub	[bx+si],dh
		add	[si-58h],bh
		adc	[bx+si],al
		db	 3Eh, 50h, 08h, 00h, 1Eh,0AAh
		db	 34h, 00h, 1Ch,0D4h, 34h, 00h
		db	 0Ah,0E8h, 34h, 00h, 0Fh,0D4h
		db	 34h, 00h, 07h, 32h, 34h, 00h
		db	 01h, 14h
		db	30h
loc_8:
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		xchg	sp,ax
		adc	[bx+si],al
		jg	loc_7			; Jump if >
		or	[bx+si],al
		aas				; Ascii adjust
;*		jmp	far ptr loc_10		;*
		db	0EAh
		dw	34h, 0E317h		;  Fixup - byte match
		db	 00h,0C0h, 05h,0D5h, 00h, 80h
		db	 02h,0F5h, 34h, 00h, 01h, 7Ah
		db	 34h, 01h, 14h, 34h, 1Bh, 3Fh
		db	 00h, 0Ch, 34h, 0Fh, 10h, 34h
		db	 01h, 38h, 34h, 01h,0FEh, 00h
		db	 30h, 03h,0FFh, 00h, 40h, 00h
		db	0FFh, 00h, 32h, 03h,0FFh, 00h
		db	 80h, 07h,0FFh, 01h, 00h, 1Fh
		db	0FFh, 04h, 00h, 3Fh,0FDh, 06h
		db	 00h, 7Fh,0DAh, 10h, 00h,0FFh
		db	0B5h, 20h, 00h,0F5h, 34h, 01h
		db	0EAh, 00h, 80h, 00h,0FFh,0CFh
		db	 0Ah, 00h, 5Bh, 00h, 34h, 00h
		db	0FBh,0BFh, 34h, 00h, 59h, 00h
		db	 34h, 00h, 4Eh, 00h, 34h, 00h
		db	 50h, 54h, 34h, 04h, 3Fh,0FFh
		db	 01h, 00h,0FFh,0FAh, 34h, 00h
		db	0AFh, 55h, 34h, 00h,0F8h, 34h
		db	 01h, 7Fh,0E0h, 34h, 00h,0A2h
		db	0BDh, 34h, 00h, 15h, 55h, 34h
		db	 01h,0AAh, 34h, 00h,0E0h, 34h
		db	 01h,0A8h, 34h, 01h, 55h, 34h
		db	 01h,0AAh,0A0h, 34h, 00h, 05h
		db	 54h, 34h, 00h, 40h, 2Ah, 34h
		db	 00h, 7Ah, 85h, 34h, 00h,0AAh
		db	0E8h, 34h, 14h,0A0h, 34h, 01h
		db	 55h, 34h, 02h,0A9h, 34h, 05h
		db	0FFh, 34h, 00h, 0Fh,0FFh, 06h
		db	 49h, 3Fh,0FFh, 20h, 15h, 70h
		db	 7Fh, 00h, 01h,0C0h, 0Fh, 34h
		db	 01h, 03h, 34h, 01h, 01h, 34h
		db	 00h, 41h, 5Fh, 34h, 00h, 5Bh
		db	 00h, 00h, 05h, 5Bh, 00h, 10h
		db	 40h, 5Bh, 00h, 34h, 00h, 5Bh
		db	 00h, 80h, 00h,0FFh,0FBh,0A0h
		db	 00h,0FFh,0EAh, 40h, 00h,0FFh
		db	 55h,0A0h, 00h,0FFh,0FAh, 34h
		db	 00h, 5Bh, 00h, 5Ah, 20h, 5Bh
		db	 00h, 34h, 00h, 5Bh, 00h, 34h
		db	 00h,0FFh, 79h, 34h, 00h, 96h
		db	0AAh, 34h, 00h, 4Eh, 00h, 34h
		db	 00h, 59h, 00h, 34h, 00h,0A0h
		db	 34h, 01h,0FAh, 80h, 34h, 00h
		db	 5Bh, 00h, 92h, 00h, 5Bh, 00h
		db	 34h, 00h,0F3h, 2Ah, 34h, 00h
		db	 4Eh, 00h, 34h, 00h, 4Eh, 00h
		db	 34h, 00h, 50h, 34h, 01h, 55h
		db	 56h, 34h, 00h, 0Ah,0A9h, 34h
		db	 01h, 05h, 34h, 00h,0FFh, 8Ah
		db	 34h, 00h, 15h, 78h, 34h, 00h
		db	0AAh,0A8h, 34h, 00h,0A2h, 84h
		db	 34h, 04h,0D3h, 08h, 34h, 00h
		db	 80h, 18h, 34h, 00h, 14h,0F3h
		db	 14h, 00h
		db	'7?7', 0Ah, 1Bh, 'o', 1Bh, '`', 1Bh
		db	'h', 1Bh, 'h'
		db	 92h, 42h, 12h, 42h, 0Fh,0FEh
		db	 0Fh,0FEh, 20h, 34h, 01h, 60h
		db	 80h, 34h, 00h,0CBh, 04h, 80h
		db	 00h,0FEh, 9Ch, 20h, 00h,0FAh
		db	 79h,0C0h, 20h,0FFh,0E0h, 02h
		db	 00h,0FFh,0D1h, 30h, 00h,0FFh
		db	 3Eh, 34h, 0Ch, 80h, 34h, 01h
		db	 28h, 34h, 01h,0A8h, 00h, 03h
		db	 00h, 02h, 00h, 07h,0C0h, 04h
		db	 00h, 0Fh,0F0h,0FEh,0AAh, 80h
		db	 00h,0BDh, 55h, 80h, 00h,0EAh
		db	0AAh, 80h, 00h,0FDh, 55h, 80h
		db	 00h,0EAh,0A8h, 40h, 00h,0F5h
		db	 40h, 60h, 00h, 7Ah, 82h, 20h
		db	 00h, 3Dh, 05h, 34h, 00h, 4Eh
		db	 00h, 34h, 00h, 54h, 34h, 01h
		db	 80h, 34h, 06h, 1Bh, 00h, 01h
		db	 05h,0FEh, 00h, 60h,0FFh,0FEh
		db	 65h, 00h, 2Dh, 72h, 00h, 40h
		db	 34h, 07h, 2Fh, 34h, 00h, 17h
		db	0FEh, 34h, 00h,0FEh,0E7h, 20h
		db	 00h,0E8h,0ADh, 34h, 00h, 15h
		db	 50h, 34h, 00h,0A2h, 80h, 34h
		db	 08h,0FFh,0E4h, 34h, 00h,0FAh
		db	0AAh, 34h, 00h, 55h, 54h, 34h
		db	 00h, 50h, 34h, 09h, 04h, 00h
		db	 1Eh,0A8h, 34h, 00h, 1Eh, 08h
		db	 34h, 00h, 0Ch, 30h, 34h, 00h
		db	 1Dh, 40h, 10h, 00h, 39h, 40h
		db	 20h, 00h, 73h, 40h, 34h, 00h
		db	0F6h, 63h, 00h, 00h,0E6h, 80h
		db	 0Ch, 18h, 00h, 10h, 03h,0E0h
		db	 34h, 18h, 01h, 75h, 34h, 01h
		db	 2Ah, 34h, 01h, 15h, 34h, 01h
		db	 02h, 34h, 10h, 54h, 34h, 01h
		db	0A0h, 34h, 05h, 80h, 34h, 12h
		db	 05h, 00h,0A5h, 00h, 8Dh, 02h
		db	0E9h, 00h, 07h, 06h,0A4h, 01h
		db	0A5h, 2Bh,0F4h, 04h, 01h, 3Fh
		db	0E1h, 30h, 00h, 7Fh,0E1h, 00h
		db	 01h,0FFh,0C1h, 40h, 01h,0FFh
		db	0C7h,0FDh, 00h,0FDh, 01h,0F7h
		db	0B3h,0F7h, 97h,0DEh,0F0h,0DEh
		db	 12h, 77h, 40h, 00h, 4Ah,0D5h
		db	 00h,0D5h, 04h, 34h, 00h, 41h
		db	 40h, 34h, 00h,0EAh, 40h, 80h
		db	 00h,0FEh,0A5h, 80h, 00h,0ECh
		db	 80h, 40h, 00h,0D8h, 00h, 10h
		db	 00h,0D9h, 34h, 01h,0A0h, 34h
		db	 01h, 02h, 34h, 05h, 28h, 34h
		db	 01h, 40h, 34h, 01h,0FFh, 43h
		db	 34h, 00h, 5Ch, 83h, 34h, 01h
		db	 01h, 08h, 00h, 1Dh, 02h, 34h
		db	 00h, 12h, 80h, 34h, 00h, 0Bh
		db	 40h, 0Fh,0FCh, 0Dh, 40h, 0Fh
		db	0D5h, 34h, 02h, 48h, 00h, 0Dh
		db	 54h, 4Dh, 54h, 17h, 88h, 97h
		db	 88h, 37h, 99h, 37h, 99h, 33h
		db	 88h, 33h, 88h, 23h,0C8h, 23h
		db	0C9h, 03h,0C0h, 03h,0C1h, 01h
		db	0C2h, 01h,0C2h

seg_a		ends



		end	start
