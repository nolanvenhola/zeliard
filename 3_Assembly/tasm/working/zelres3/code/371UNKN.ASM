
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_371UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_371UNKN	proc	far

start:
		cmp	bx,[bp+si]
		add	[bx+si],al
		add	byte ptr data_1,al
		db	 67h,0AAh, 6Dh, 55h, 7Bh,0FFh
		db	 93h, 80h, 97h, 01h,0A5h, 40h
		db	0C3h, 02h,0C9h, 03h,0DBh,0A0h
		db	0DEh, 05h,0E6h,0C0h,0E9h, 10h
		db	0FFh,0FFh, 66h, 1Fh, 07h, 00h
		db	 04h, 00h, 1Fh, 00h, 07h, 00h
		db	 7Eh, 00h, 1Eh, 00h,0E0h, 00h
		db	 60h, 01h, 00h, 01h, 66h, 20h
		db	 05h, 00h, 04h, 01h, 5Fh, 01h
		db	 07h, 00h, 0Fh, 00h, 0Fh, 66h
		db	 0Bh, 05h, 66h, 01h, 7Fh, 66h
		db	 00h, 03h,0FFh, 00h, 47h, 1Fh
		db	0FCh, 00h,0FCh,0FFh,0D0h, 17h
		db	0D5h, 03h, 1Eh, 04h, 9Eh, 08h
		db	 7Eh, 06h, 7Eh, 49h, 07h, 00h
		db	 77h,0F6h, 01h, 00h
data_1		dw	0FFEDh			; Data table (indexed access)
		db	0E3h,0FFh,0EBh,0AAh,0BFh,0AAh
		db	 87h, 27h, 17h, 00h, 11h, 26h
		db	 03h, 00h,0F8h, 01h,0F0h, 66h
		db	 00h, 0Ah, 80h, 66h, 00h,0C0h
		db	 1Ch,0C0h, 00h,0FEh,0F0h,0FEh
		db	 00h,0F7h, 82h,0F0h, 00h, 9Fh
		db	 5Fh, 80h, 40h,0E5h,0CDh,0E1h
		db	0C0h,0FFh,0E4h,0FFh,0E0h
		db	'=', 8, '=', 8, '(', 8, '(', 8
		db	 03h, 10h, 00h, 10h, 2Eh, 03h
		db	 66h, 00h,0F8h, 0Fh, 66h, 00h
		db	 40h,0FFh, 00h, 83h, 07h,0FFh
		db	 04h, 47h, 3Fh,0FFh, 30h, 2Fh
		db	0FAh,0F0h,0FAh,0F0h,0E8h, 00h
		db	 68h, 04h,0D0h, 00h,0D0h, 80h
		db	 40h, 00h, 40h, 94h, 66h, 00h
		db	 12h, 10h, 66h, 00h, 02h, 61h
		db	 00h, 40h,0A4h,0A6h, 08h, 00h
		db	 95h, 41h, 7Fh,0FFh, 60h, 5Fh
		db	 7Bh, 00h,0C0h, 7Bh, 01h,0C7h
		db	 7Bh, 01h,0CFh,0FFh, 7Fh, 5Ah
		db	 6Fh, 5Ah, 3Eh, 05h, 3Eh, 05h
		db	 1Fh, 00h, 1Fh, 00h, 87h, 07h
		db	 47h, 07h, 00h, 08h,0E8h, 14h
		db	 97h, 00h,0A0h, 00h, 07h, 66h
		db	 01h, 07h, 99h, 66h, 00h, 03h
		db	 99h, 10h, 66h, 00h,0E4h, 10h
		db	 66h, 00h, 36h, 1Ch, 66h, 00h
data_2		db	7
		db	 0Eh, 80h, 66h, 00h, 20h, 00h
		db	 0Fh,0C0h, 80h, 01h, 3Fh, 60h
		db	 00h, 05h,0FCh,0B0h, 00h, 02h
		db	0F5h, 40h, 00h, 01h, 6Ah,0A0h
		db	 00h, 06h, 1Dh, 40h, 00h, 05h
		db	 43h, 83h, 00h, 04h, 66h, 00h
		db	 04h, 57h, 66h, 00h,0AAh,0FFh
		db	 18h, 80h,0E7h, 7Fh, 03h, 20h
		db	0BCh,0DFh, 01h, 80h,0EAh, 7Dh
		db	 00h, 40h,0FAh,0BBh,0C0h, 00h
		db	 3Ch,0F4h, 66h, 00h,0FEh, 9Bh
		db	 66h, 00h,0E8h, 66h, 01h,0F4h
		db	 66h, 01h,0ECh, 66h, 01h,0F4h
		db	 66h, 01h,0C8h,0C0h, 66h, 00h
		db	 11h,0ECh, 00h,0B0h,0A3h, 47h
		db	 66h, 00h, 45h,0FFh, 02h, 00h
		db	 05h,0D0h, 01h, 20h, 02h,0C8h
		db	 01h,0B0h, 02h, 48h, 00h, 90h
		db	 01h, 6Ch, 00h, 40h, 00h,0BCh
		db	 00h, 30h, 00h, 4Ch, 00h, 08h
		db	 00h, 16h, 66h, 01h, 15h,0D8h
		db	 45h, 00h, 0Ah, 1Dh, 4Eh, 00h
		db	 01h, 02h, 8Ah, 00h, 15h, 00h
		db	 0Ch, 00h, 13h, 00h, 04h, 20h
		db	 1Bh, 00h, 02h, 90h, 0Dh, 66h
		db	 00h,0A8h, 07h, 66h, 00h,0D0h
		db	 05h, 66h, 00h,0FFh, 4Eh, 66h
		db	 00h,0FFh, 5Ch, 10h, 00h,0EEh
		db	0AEh, 00h, 08h,0FFh, 95h, 20h
		db	 08h,0DDh, 56h, 00h, 10h,0FAh
		db	0AFh, 00h, 60h,0D4h, 9Fh, 01h
		db	 00h, 6Ah,0FEh, 00h, 0Ch, 8Ah
		db	0D3h, 01h, 00h, 94h,0FDh, 66h
		db	 00h,0ABh, 9Fh, 00h, 06h, 85h
		db	0F8h, 66h, 01h,0A0h, 0Ah, 0Ah
		db	 0Ah, 0Ah, 28h,0BFh, 28h, 8Fh
		db	 0Bh,0FEh, 08h, 7Eh, 66h, 00h
		db	 63h,0F4h, 66h, 00h, 56h,0E8h
		db	 66h, 00h, 3Ah, 10h, 66h, 00h
		db	0F5h,0F3h, 00h, 08h,0F4h,0D5h
		db	 00h,0C0h,0F7h, 28h, 04h, 00h
		db	0DAh, 80h, 66h, 00h, 70h, 66h
		db	 13h,0A0h, 00h, 20h, 00h,0FAh
		db	 80h,0E0h, 80h,0F0h, 00h,0F0h
		db	 00h, 10h,0A8h, 10h,0A8h, 10h
		db	 14h, 10h, 14h, 08h,0C0h, 08h
		db	 00h,0C0h, 74h, 66h, 00h,0F0h
		db	 1Fh, 66h, 00h,0FFh, 02h,0C1h
		db	 00h,0FFh,0E0h,0E2h, 20h,0FFh
		db	0FCh,0F4h, 0Ch, 0Fh, 80h, 66h
		db	 00h, 01h, 50h, 66h, 00h, 38h
		db	 03h, 00h, 03h, 0Fh, 7Fh, 00h
		db	 7Fh, 41h,0EFh, 00h, 0Fh,0FAh
		db	0F9h, 02h, 01h,0B3h,0A7h, 03h
		db	 87h, 27h,0FFh, 07h,0FFh, 78h
		db	0C0h, 79h, 20h, 7Eh, 10h, 7Eh
		db	 60h,0E0h, 92h,0EEh, 00h, 80h
		db	 6Fh,0B7h, 00h,0C7h,0FFh,0D7h
		db	0FFh,0FDh, 55h,0E1h, 55h,0E8h
		db	0E4h, 88h, 00h,0C0h, 64h, 1Fh
		db	 66h, 0Bh,0A0h, 66h, 01h,0FEh
		db	 66h, 01h,0FFh,0C0h,0E2h, 00h
		db	 3Fh,0F8h, 3Fh, 00h, 0Bh,0FFh
		db	0ABh,0E8h,0FFh,0FEh,0FAh, 06h
		db	 7Bh, 01h, 03h, 7Bh, 01h,0E3h
		db	 7Bh, 01h,0F3h, 5Ah,0FEh, 5Ah
		db	0F6h,0A0h, 7Ch,0A0h, 7Ch, 00h
		db	0F8h, 00h,0F8h,0E0h,0E1h,0E0h
		db	0E2h, 0Fh, 5Fh, 0Fh, 5Fh, 00h
		db	 17h, 20h, 16h, 00h, 0Bh, 01h
		db	 0Bh, 00h, 02h, 29h, 02h, 66h
		db	 00h, 08h, 48h, 66h, 00h, 86h
		db	 40h, 02h, 00h, 65h, 25h, 00h
		db	 10h, 82h,0A9h,0E0h, 00h, 20h
		db	 00h,0F8h, 00h,0E0h, 00h, 7Eh
		db	 00h, 78h, 00h, 07h, 00h, 06h
		db	 66h, 00h, 80h, 00h, 80h, 66h
		db	 0Dh, 17h, 66h, 01h, 2Fh, 66h
		db	 01h, 37h, 66h, 01h, 2Fh, 66h
		db	 00h, 03h, 13h, 66h, 00h, 37h
		db	 88h, 0Dh, 00h,0E2h,0C5h, 66h
		db	 00h,0FFh,0A2h, 66h, 00h,0EAh
		db	 20h, 66h, 00h,0FFh, 55h, 01h
		db	 18h,0FEh,0E7h, 04h,0C0h,0FBh
		db	 3Dh, 01h, 80h,0BEh, 57h, 02h
		db	 00h,0DDh, 5Fh, 00h, 03h, 2Fh
		db	 3Ch, 66h, 00h,0D9h, 7Fh, 66h
		db	 01h, 04h, 03h,0F0h, 80h, 01h
		db	 06h,0FCh,0A0h, 00h, 0Dh, 3Fh
		db	 40h, 00h, 02h,0AFh, 80h, 00h
		db	 05h, 56h, 60h, 00h, 02h,0B8h
		db	0A0h, 00h,0C1h,0C2h, 20h, 00h
		db	 10h, 00h, 28h, 15h, 93h, 00h
		db	 00h, 02h, 00h,0E0h, 66h, 00h
		db	 99h,0E0h, 66h, 00h, 99h,0C0h
		db	 00h, 08h, 27h, 66h, 00h, 08h
		db	 6Ch, 66h, 00h, 38h,0E0h, 00h
		db	 01h, 70h, 30h, 00h,0CBh, 51h
		db	 00h, 80h,0BFh, 29h, 66h, 00h
		db	0F9h,0D5h, 60h, 00h, 1Fh,0A1h
		db	 66h, 00h, 05h, 00h, 50h, 50h
		db	 50h, 50h,0FDh, 14h,0F1h, 14h
		db	 7Fh,0D0h, 7Eh, 10h, 66h, 00h
		db	 72h,0FFh, 66h, 00h, 3Ah,0FFh
		db	 00h, 08h, 75h, 77h, 10h, 00h
		db	0A9h,0FFh, 10h, 04h, 6Ah,0BBh
		db	 08h, 00h,0F5h, 5Fh, 06h, 00h
		db	0F9h, 2Bh, 00h, 80h, 7Fh, 56h
		db	0A2h, 1Bh, 50h, 00h, 72h,0B8h
		db	 80h, 00h, 51h, 40h,0A8h, 00h
		db	 30h, 00h,0C8h, 00h, 20h, 00h
		db	0D8h, 04h, 40h, 00h,0B0h, 09h
		db	 66h, 00h,0E0h, 15h, 66h, 00h
		db	0A0h, 0Bh, 00h, 40h, 0Bh,0A0h
		db	 04h, 80h, 13h, 40h, 0Dh, 80h
		db	 12h, 40h, 09h, 00h, 36h, 80h
		db	 02h, 00h, 3Dh, 00h, 0Ch, 00h
		db	 32h, 00h, 10h, 00h, 68h, 66h
		db	 01h,0A8h, 66h, 01h, 2Fh,0C6h
		db	 66h, 00h, 17h, 6Ah, 66h, 00h
		db	 08h, 5Ch, 66h, 00h,0CFh,0AFh
		db	 10h, 00h,0ABh, 2Fh, 03h, 00h
		db	 14h,0EFh, 00h, 20h, 01h, 5Bh
		db	 66h, 01h, 0Eh, 6Dh, 02h, 67h
		db	 02h, 6Dh, 02h, 67h, 02h, 6Dh
		db	 02h, 67h, 02h, 6Dh, 02h, 67h
		db	 02h, 66h, 0Bh, 03h, 00h, 02h
		db	 00h, 07h, 00h, 01h, 00h, 0Fh
		db	 00h, 03h, 00h, 3Fh, 00h, 0Fh
		db	 00h,0F5h, 00h, 95h, 1Ch, 00h
		db	 14h, 00h, 78h, 00h, 48h, 00h
		db	0F8h, 00h, 38h, 00h,0F0h, 00h
		db	 70h, 00h,0A8h, 00h,0A8h, 00h
		db	 40h, 00h, 40h, 00h,0A0h, 00h
		db	0A0h, 00h, 40h, 00h, 40h, 66h
		db	 0Ch, 03h, 00h, 02h, 00h, 1Dh
		db	 00h, 15h, 00h, 74h, 00h, 54h
		db	 01h,0A0h, 01h, 20h, 0Eh, 82h
		db	 0Ah, 82h, 00h, 3Ah, 00h, 2Ah
		db	 03h,0D0h, 03h, 50h, 3Dh, 01h
		db	 29h, 01h,0D0h, 0Ah, 90h, 0Ah
		db	 01h, 55h, 01h, 55h, 0Ah,0AAh
		db	 0Ah,0AAh, 6Dh, 02h, 67h, 02h
		db	 66h, 02h,0A0h, 00h,0A0h, 00h
		db	 40h, 00h, 40h, 00h, 80h, 00h
		db	 80h, 66h, 03h, 80h, 00h, 80h
		db	 66h, 1Fh, 0Fh,0E0h, 0Dh,0E0h
		db	0F0h, 00h, 30h, 00h, 03h,0FAh
		db	 02h, 7Ah, 07h, 55h, 05h, 55h
		db	 0Fh,0AAh, 0Bh,0AAh, 1Fh, 55h
		db	 13h, 55h, 3Ah,0AAh, 2Ah,0AAh
		db	 75h, 55h, 45h, 55h,0FAh,0AAh
		db	 9Ah,0AAh,0F5h, 55h, 75h, 55h
		db	 00h,0C0h, 00h,0C0h, 00h, 90h
		db	 00h,0C0h, 00h,0B0h, 00h,0A0h
		db	 00h, 38h, 66h, 01h, 0Ch, 00h
		db	 10h, 00h, 0Ch, 00h, 0Ah, 00h
		db	 03h, 00h, 03h, 00h, 03h, 00h
		db	 03h, 66h, 03h, 01h, 66h, 01h
		db	 07h, 00h, 07h, 00h, 1Eh, 00h
		db	 02h, 00h, 34h, 00h, 04h, 00h
		db	 70h, 00h, 10h, 01h,0E1h, 00h
		db	 21h, 07h, 42h, 00h, 42h, 1Dh
		db	 15h, 15h, 15h, 78h, 2Ah, 18h
		db	 2Ah,0D1h, 55h, 51h, 55h, 42h
		db	0AAh, 42h,0AAh, 15h, 55h, 15h
		db	 55h, 2Ah,0AAh, 2Ah,0AAh, 6Dh
		db	 02h, 67h, 02h, 00h, 03h, 66h
		db	 01h, 07h, 00h, 01h, 00h, 07h
		db	 00h, 03h, 00h, 0Fh, 00h, 07h
		db	 00h, 1Eh, 00h, 06h, 00h, 3Bh
		db	 00h, 1Bh, 00h, 3Eh, 00h, 1Eh
		db	 00h, 7Dh, 00h, 3Dh, 80h, 00h
		db	 80h, 00h, 40h, 00h, 40h, 66h
		db	 00h, 01h, 66h, 01h, 07h, 00h
		db	 01h, 00h, 0Dh, 00h, 05h, 40h
		db	 3Ah, 40h, 3Ah, 80h,0E8h, 80h
		db	 68h, 43h,0A2h, 40h,0A2h,0C0h
		db	 00h, 80h, 00h,0D0h, 00h, 38h
		db	 00h, 30h, 00h, 4Eh, 00h, 14h
		db	 00h, 2Bh, 80h, 0Fh, 00h, 30h
		db	 80h, 0Fh, 00h, 10h,0C0h, 02h
		db	 80h, 0Dh, 40h, 01h, 80h, 06h
		db	 40h, 00h,0EAh, 00h, 6Ah, 00h
		db	0F5h, 00h, 75h, 01h,0EAh, 00h
		db	0EAh, 03h,0DDh, 00h,0DDh, 03h
		db	0FAh, 00h,0BAh, 07h,0D5h, 01h
		db	 95h, 07h,0EAh, 01h, 2Ah, 0Fh
		db	0F5h, 03h,0F5h,0AAh,0A8h,0AAh
		db	0A8h, 55h, 54h, 55h, 54h,0AAh
		db	0A8h,0AAh,0A8h, 55h, 04h, 55h
		db	 04h,0A8h, 80h,0A8h, 80h, 51h
		db	 43h, 51h, 41h,0A2h, 87h,0A2h
		db	 81h, 50h, 1Dh, 50h, 05h, 06h
		db	 85h, 02h, 85h, 0Dh, 2Ah, 05h
		db	 2Ah, 3Ch, 55h, 0Ch, 55h, 68h
		db	0AAh, 28h,0AAh,0F1h, 55h, 71h
		db	 55h,0A2h,0AAh,0A2h,0AAh, 85h
		db	 55h, 85h, 55h, 2Ah,0AAh, 2Ah
		db	0AAh,0C0h, 00h,0C0h, 00h, 10h
		db	 00h, 70h, 00h, 0Ch, 66h, 01h
		db	 03h, 00h, 0Ch, 40h, 00h,0C0h
		db	 00h, 10h, 00h, 30h, 00h, 10h
		db	 00h, 08h, 00h, 0Ch, 00h, 03h
		db	 00h, 03h, 0Eh,0EAh, 06h,0EAh
		db	 1Fh, 55h, 05h, 55h, 1Bh,0AAh
		db	 0Bh,0AAh, 3Fh, 75h, 09h, 75h
		db	 3Fh,0AAh, 13h,0AAh, 7Fh,0D5h
		db	 14h,0D5h, 7Eh,0EAh, 1Eh,0EAh
		db	0FFh, 55h, 3Fh, 55h,0AAh, 34h
		db	0AAh, 04h, 00h, 78h, 00h, 18h
		db	0A0h,0D1h,0A0h, 11h, 01h,0A0h
		db	 00h, 20h, 81h,0AFh, 81h,0A8h
		db	 47h,0FEh, 40h, 5Eh,0A3h,0FFh
		db	0A0h,0FCh, 40h,0F6h, 40h, 76h
		db	 6Dh, 02h,0AAh, 80h,0AAh, 80h
		db	 40h, 1Fh, 40h, 11h, 3Fh,0FEh
		db	 21h, 7Eh,0FAh,0A0h,0FAh,0DBh
		db	 00h, 00h,0A0h, 66h, 00h, 15h
		db	 00h, 15h, 0Ah,0AAh, 0Ah,0AAh
		db	 55h, 00h, 55h, 66h, 00h, 3Fh
		db	 00h, 21h,0FFh,0FDh, 14h,0FDh
		db	0A8h, 00h,0A8h, 66h, 04h,0AAh
		db	 00h,0AAh, 6Dh, 02h, 67h, 02h
		db	 00h, 01h, 00h, 01h,0FFh,0F0h
		db	 15h,0B0h, 50h, 0Fh, 50h, 0Ch
		db	 66h, 06h, 67h, 02h, 6Dh, 02h
		db	 67h, 02h, 6Dh, 02h, 00h, 2Ah
		db	 00h, 2Ah,0FAh, 81h,0BAh, 81h
		db	 0Fh,0F4h, 08h,0B4h, 00h, 0Fh
		db	 00h, 09h,0A0h, 00h,0A0h, 00h
		db	 55h, 40h, 55h, 40h,0A8h, 2Ah
		db	0A8h, 2Ah, 66h, 02h, 40h, 00h
		db	 40h, 00h, 40h, 00h, 40h, 00h
		db	 10h, 00h, 10h, 00h,0A0h, 00h
		db	0A0h, 00h, 78h, 00h, 78h, 00h
		db	 07h, 00h, 07h, 66h, 08h, 03h
		db	 00h, 02h, 00h, 0Fh, 00h, 08h
		db	 00h, 05h, 00h, 05h, 66h, 0Eh
		db	0EFh,0FBh,0EFh,0FBh,0FBh,0DFh
		db	 3Bh,0DFh,0FFh,0EAh, 2Dh, 2Ah
		db	0FBh,0EFh, 3Bh,0EEh, 3Fh, 7Dh
		db	 27h, 7Dh, 0Fh,0BAh, 09h,0BAh
		db	 03h,0DFh, 02h, 5Fh, 00h,0FAh
		db	 00h, 9Ah,0E8h, 60h,0E8h, 20h
		db	0D4h, 30h,0D4h, 10h,0BEh, 38h
		db	0BEh, 18h,0ADh, 14h, 2Dh, 04h
		db	 54h, 1Ch, 54h, 0Ch,0EBh, 0Ah
		db	0EBh, 02h, 75h, 06h, 75h, 02h
		db	0FBh, 86h,0FBh, 82h
loc_2:
		db	0C0h, 00h,0C0h, 00h, 10h, 00h
		db	 78h, 00h, 0Ah, 00h, 05h, 00h
		db	 03h, 80h, 0Ch, 40h, 01h,0E0h
		db	 02h, 10h, 00h,0B8h, 01h, 54h
		db	 00h, 38h, 00h, 4Eh, 00h, 04h
		db	 00h, 0Bh, 05h, 50h, 05h, 50h
		db	 93h, 02h, 50h, 00h, 50h, 00h
		db	0A0h, 00h,0A0h, 00h, 54h, 00h
		db	 54h, 00h, 28h, 00h, 28h, 00h
		db	 40h, 00h, 40h, 00h, 80h, 00h
		db	 80h, 66h, 00h, 7Dh, 00h, 4Dh
		db	 00h, 1Eh, 00h, 16h, 00h, 0Fh
		db	 00h, 0Bh, 00h, 03h, 00h, 03h
		db	 05h,0C1h, 05h,0C1h, 7Ch, 00h
		db	 0Ch, 00h,0F0h, 00h,0F0h, 00h
		db	 80h, 2Ch, 80h, 00h,0DDh, 05h
		db	0DDh, 05h,0EAh, 83h,0EAh, 81h
		db	0DDh, 63h,0DDh, 61h,0EAh, 23h
		db	0EAh, 21h,0F5h, 33h,0F5h, 31h
		db	0EAh, 82h,0EAh, 82h, 75h, 47h
		db	 75h, 43h, 7Ah, 84h, 7Ah, 84h
		db	 2Ah, 80h, 2Ah, 80h, 14h, 3Ch
		db	 14h, 3Ch, 20h,0ECh, 20h, 2Ch
		db	 03h,0ECh, 00h,0ECh, 07h,0A8h
		db	 03h,0A8h, 8Fh, 48h, 83h, 48h
		db	 0Fh, 48h, 07h, 48h, 1Fh, 48h
		db	 07h, 48h, 9Eh, 89h, 8Eh, 89h
		db	 3Eh, 92h, 0Eh, 92h,0FDh, 00h
		db	 2Dh, 00h,0FDh, 2Ah, 9Dh, 2Ah
		db	0FAh, 15h,0FAh, 15h,0FAh, 2Bh
		db	0FAh, 2Bh,0FAh, 55h,0FAh, 55h
		db	0FAh, 2Fh,0FAh
loc_3:
		db	 2Eh, 55h, 50h, 55h, 50h, 0Ah
		db	0A8h, 0Ah,0A8h, 00h, 10h, 00h
		db	 10h,0FAh, 00h,0FAh, 00h, 7Fh
		db	0A0h, 7Fh,0A0h,0FDh, 10h,0FDh
		db	 10h,0FDh, 10h, 8Dh, 10h,0EAh
		db	 60h, 6Ah, 60h,0FAh, 5Fh,0FAh
		db	 58h,0F4h,0BEh,0F4h,0BAh,0E4h
		db	 5Ah,0E4h, 5Ah,0D4h,0B4h,0D4h
		db	0B4h,0A9h, 68h,0A9h, 68h, 40h
		db	0A0h, 40h,0A0h, 07h, 00h, 07h
		db	 02h,0A8h, 00h,0A8h, 0Bh,0A0h
		db	 80h,0A0h, 93h, 00h, 00h, 80h
		db	 66h, 09h, 40h, 66h, 01h,0A0h
		db	 66h, 01h,0B0h, 66h, 01h,0D8h
		db	 66h, 0Fh, 05h,0C0h, 05h,0C0h
		db	 7Ch, 00h, 0Ch, 00h,0F0h, 00h
		db	0F0h, 00h, 80h, 2Ch, 80h, 66h
		db	 17h, 56h, 50h, 56h, 50h,0FFh
		db	 5Ah,0FFh, 5Ah,0D4h, 00h,0D0h
		db	 00h, 2Bh, 40h, 04h, 00h, 02h
		db	 94h, 00h, 60h, 00h, 2Bh, 00h
		db	 0Bh, 66h, 26h, 01h, 5Fh, 01h
		db	 42h,0EFh,0FFh, 88h,0A9h, 66h
		db	 16h, 7Bh, 00h, 0Ch,0FBh,0FFh
		db	0FDh,0BBh,0F9h, 66h, 16h,0B2h
		db	 00h, 80h, 00h,0FFh,0A8h,0FFh
		db	0A8h, 41h,0FDh, 41h,0C0h, 2Ah
		db	0EDh, 28h, 00h, 76h,0BBh, 40h
		db	 8Bh, 95h,0E7h, 95h, 27h,0D0h
		db	0BBh,0D0h, 8Bh,0FAh, 3Dh,0FAh
		db	 0Dh,0FDh, 1Ch,0FDh, 04h,0FAh
		db	 1Eh,0FAh, 06h, 7Bh, 00h, 15h
		db	 7Bh, 01h,0EFh, 7Bh, 00h,0FEh
		db	0FFh,0FEh,0FFh,0F6h,0FFh,0F6h
		db	0B6h,0A9h,0B6h,0A9h, 5Ah,0AAh
		db	 5Ah,0AAh,0A6h,0FFh,0A6h, 00h
		db	 1Fh,0FFh, 00h,0AAh,0FFh,0F6h
		db	0FFh,0F6h,0FDh,0AAh,0FDh,0AAh
		db	0EAh,0AAh,0EAh, 67h, 03h, 80h
		db	 1Fh, 80h, 00h, 7Fh,0FFh, 00h
		db	 12h, 7Bh, 00h, 53h, 7Fh, 7Bh
		db	 02h, 94h, 7Eh, 94h, 7Eh,0AAh
		db	0ABh,0AAh,0ABh,0A8h, 05h,0A8h
		db	 05h, 67h, 02h, 7Bh, 00h, 00h
		db	 0Dh, 7Bh, 00h,0BDh, 7Bh, 04h
		db	0BFh,0FFh,0BFh,0A0h, 00h,0A0h
		db	 00h, 68h, 00h, 68h, 00h, 52h
		db	 00h, 52h, 00h, 88h, 00h, 88h
		db	 00h, 42h, 80h, 42h, 80h,0FCh
		db	 00h,0E4h, 00h,0FFh,0E0h,0FFh
		db	0E0h,0DDh,0DCh,0DDh,0DCh,0FCh
		db	 9Dh,0FCh, 80h,0FAh, 2Ah,0FAh
		db	 08h,0F8h,0FFh,0F8h, 96h,0D4h
		db	 1Fh,0D4h, 11h,0A9h, 00h,0A9h
		db	 00h, 40h,0A0h, 40h,0A0h, 07h
		db	 00h, 07h, 02h,0A8h, 00h,0A8h
		db	 0Bh, 7Bh, 00h, 0Ah, 4Fh, 7Bh
		db	 00h, 17h,0FFh, 5Fh,0FFh, 0Fh
		db	 7Bh, 00h,0FDh, 8Fh,0FDh,0BFh
		db	0D2h,0B8h, 52h, 07h,0FCh, 07h
		db	 84h, 00h, 7Fh, 80h, 78h, 00h
		db	 07h,0D0h, 06h,0FFh,0D7h,0FFh
		db	0D7h,0FAh,0AAh,0FAh,0AAh, 6Dh
		db	 02h, 67h, 02h,0D5h, 55h,0D5h
		db	 55h, 52h,0AAh, 52h,0AAh,0CAh
		db	 55h, 4Ah, 55h,0FDh, 6Ah, 2Dh
		db	 6Ah, 66h, 02h, 80h, 00h, 80h
		db	 66h, 03h,0A0h, 00h,0A0h, 00h
		db	 50h, 00h, 50h, 66h, 03h, 40h
		db	 00h, 40h, 00h,0A8h, 00h,0A8h
		db	 00h, 7Fh, 2Ah, 7Fh, 2Ah, 07h
		db	0E5h, 07h,0E5h, 01h,0F8h, 01h
		db	0F8h, 00h, 7Fh, 00h, 7Fh, 00h
		db	 0Fh, 00h, 0Fh, 00h, 01h, 00h
		db	 01h, 66h, 00h,0B0h, 66h, 01h
		db	0FBh,0A0h, 6Dh, 02h, 67h, 02h
		db	 95h, 55h, 95h, 55h, 5Ah,0AAh
		db	 5Ah,0AAh,0EAh, 55h,0EAh, 55h
		db	0FDh,0AAh,0FDh,0AAh, 3Eh,0D5h
		db	 3Eh,0D5h, 0Eh,0AAh, 0Eh,0AAh
		db	 54h, 00h, 54h, 00h,0A8h, 00h
		db	0A8h, 00h, 54h, 00h, 54h, 00h
		db	0AAh, 00h,0AAh, 00h, 54h, 00h
		db	 54h, 00h,0AAh, 00h,0AAh, 00h
		db	 54h, 00h, 54h, 00h,0AAh, 00h
		db	0AAh, 00h, 07h,0AAh, 07h,0AAh
		db	 01h,0F9h,0A1h,0F9h, 10h, 3Fh
		db	0E4h, 3Fh, 00h, 03h,0FBh, 43h
		db	 40h, 00h,0BCh,0F4h, 66h, 00h
		db	0AFh,0EDh, 00h,0C0h, 9Fh, 3Fh
		db	 00h, 08h, 03h,0F3h, 55h, 54h
		db	 55h, 54h, 5Ah,0AAh, 5Ah,0AAh
		db	0ABh, 54h,0ABh, 54h,0F5h,0AAh
		db	0F5h,0AAh, 3Eh,0AAh, 3Eh,0AAh
		db	 01h,0EBh, 01h,0EBh, 00h, 1Fh
		db	0C0h, 1Fh, 66h, 00h,0E0h, 66h
		db	 0Fh,0D4h, 00h,0F0h, 00h, 2Dh
		db	 40h, 02h, 10h, 02h,0F4h, 10h
		db	 66h, 00h, 06h, 00h, 2Eh, 66h
		db	 0Ch, 60h, 00h,0D5h, 00h,0FAh
		db	0A0h, 2Dh, 84h, 02h, 78h, 05h
		db	0FCh, 12h, 03h, 00h, 25h, 00h
		db	0DAh, 66h, 0Fh, 01h, 00h, 01h
		db	 85h, 6Fh, 80h, 01h, 7Bh, 00h
		db	 1Eh, 27h,0FFh,0FBh, 2Bh,0FBh
		db	 66h, 07h, 0Bh, 00h, 0Ah, 06h
		db	0FFh, 06h, 88h, 40h, 0Fh, 40h
		db	 08h,0FEh, 87h, 7Eh, 84h,0A8h
		db	 8Fh,0A8h, 89h, 76h, 0Fh, 76h
		db	 09h, 00h,0FFh, 00h, 85h, 1Fh
		db	0FEh, 18h,0FEh,0FFh,0A0h, 07h
		db	0A0h,0F0h, 00h, 20h, 00h,0FFh
		db	0FCh,0B9h, 04h,0DDh, 77h,0DDh
		db	 77h,0C0h, 00h,0C0h, 00h, 8Ah
		db	0AAh, 8Ah,0AAh,0FFh,0B4h,0FFh
		db	0B4h,0A0h, 00h,0A0h, 00h, 05h
		db	 55h, 05h, 55h, 67h, 02h, 66h
		db	 02h,0FFh,0D4h,0A1h, 94h, 2Bh
		db	0FFh, 2Bh,0F4h, 80h, 00h, 80h
		db	 66h, 03h, 82h,0AAh, 82h,0AAh
		db	 6Dh, 02h, 67h, 02h, 6Dh, 02h
		db	 66h, 02h,0FFh, 50h, 46h, 50h
		db	 57h,0FFh, 57h,0A8h, 66h, 02h
		db	0A8h, 22h,0A8h, 22h, 6Dh, 02h
		db	 67h, 02h, 6Dh, 02h, 67h, 02h
		db	 01h, 55h, 01h, 55h,0E8h, 0Ah
		db	 28h, 0Ah, 0Bh, 7Fh, 0Bh, 54h
		db	 80h, 01h, 80h, 01h, 55h, 54h
		db	 55h, 54h, 67h, 02h, 6Dh, 02h
		db	 67h, 02h, 6Dh, 02h,0A0h,0AAh
		db	0A0h,0AAh,0F8h, 00h, 88h, 00h
		db	 5Fh,0F8h, 58h, 78h, 00h,0BFh
		db	 00h,0B9h,0A2h, 02h,0A2h, 02h
		db	 55h, 54h, 55h, 54h, 67h, 02h
		db	'UPUP(', 8, '(', 8, 'f'
		db	 06h,0E0h, 00h,0E0h, 00h,0FFh
		db	 00h, 85h, 00h, 07h,0E0h, 06h
		db	 60h,0AAh,0FCh,0AAh,0CCh, 14h
		db	 5Eh, 14h, 5Ah, 00h, 03h, 00h
		db	 03h, 1Fh,0FFh, 1Fh, 1Fh, 02h
		db	0FFh, 02h,0E3h, 00h, 7Fh, 00h
		db	 79h, 00h, 1Fh, 00h, 1Ch, 05h
		db	0C7h, 05h,0C7h, 7Ch, 01h, 0Ch
		db	 01h,0F0h, 00h,0F0h, 00h, 80h
		db	 2Ch, 80h, 00h,0FFh,0BEh,0FFh
		db	0BEh,0EFh,0D5h,0EFh,0D5h,0FEh
		db	0EAh,0FEh,0EAh,0FFh, 45h,0BFh
		db	 45h,0FEh,0AAh, 1Eh,0AAh,0EDh
		db	 45h, 8Dh, 45h,0FAh, 2Ah,0CAh
		db	 2Ah, 77h, 54h, 77h, 54h,0ABh
		db	 1Fh,0ABh, 17h, 15h, 3Ch, 15h
		db	 24h, 94h, 7Ah, 94h, 4Ah, 69h
		db	0F4h, 69h,0B4h,0A3h,0E8h,0A3h
		db	0E8h, 07h,0A0h, 07h,0A0h, 9Eh
		db	 81h, 9Eh, 81h,0B0h, 02h,0B0h
		db	 02h, 00h, 06h, 00h, 11h, 00h
		db	 80h, 00h, 3Dh, 17h, 60h, 00h
		db	 08h, 68h, 66h, 0Ah, 17h, 66h
		db	 08h, 67h, 02h, 6Dh, 02h, 67h
		db	 02h, 55h, 50h, 55h, 50h, 80h
		db	 0Ah, 80h, 0Ah, 48h, 80h, 48h
		db	 80h, 66h, 02h, 7Fh, 40h, 62h
		db	 40h, 8Bh,0F8h, 8Bh, 48h, 40h
		db	 07h, 40h, 05h,0AAh,0A2h,0AAh
		db	0A2h, 4Ah,0A8h, 4Ah,0A8h,0A0h
		db	 00h,0A0h, 66h, 07h, 55h, 02h
		db	 55h, 02h, 00h,0A4h, 00h,0A4h
		db	0F8h, 10h, 58h, 10h,0AFh, 82h
		db	0AFh, 82h, 00h, 79h, 00h, 79h
		db	 00h, 07h, 00h, 07h, 66h, 06h
		db	 6Dh, 02h, 67h, 02h, 84h, 54h
		db	 84h, 54h,0FAh, 00h,0FAh, 00h
		db	 7Fh,0A0h, 7Fh,0A0h,0FDh, 10h
		db	0FDh, 10h,0FDh, 10h, 8Dh, 10h
		db	0EAh, 60h, 6Ah, 60h, 66h, 09h
		db	 01h, 00h, 07h, 00h, 08h, 00h
		db	 30h, 00h, 4Fh, 00h,0C0h, 03h
		db	 39h, 10h, 00h, 2Fh, 91h,0C0h
		db	 00h, 36h, 40h, 67h, 02h, 6Dh
		db	 02h, 67h, 02h, 6Dh, 02h, 67h
		db	 02h, 6Dh, 02h, 67h, 02h, 6Dh
		db	 02h, 66h, 16h, 07h,0F0h, 04h
		db	 10h, 00h, 0Fh, 00h, 08h, 00h
		db	 40h, 00h,0BFh, 1Ah, 00h, 05h
		db	0FAh,0A0h, 00h, 5Fh,0A0h, 00h
		db	 01h,0FAh, 86h, 00h, 04h,0D0h
		db	 1Bh, 00h, 20h,0E8h, 5Fh, 00h
		db	0C0h, 01h, 3Fh, 03h, 00h, 04h
		db	0FDh, 5Ch, 00h, 50h, 00h, 0Bh
		db	0C0h, 0Ah, 40h, 80h,0BCh, 80h
		db	 84h, 50h, 0Bh, 50h, 08h, 2Ah
		db	 80h, 2Ah, 80h, 05h, 50h, 05h
		db	 50h, 4Ah,0AAh, 4Ah,0AAh, 15h
		db	 55h, 15h, 55h, 66h, 0Ah,0C0h
		db	 00h, 40h, 00h,0B8h, 00h,0A8h
		db	 00h, 2Eh, 00h, 2Eh, 00h, 05h
		db	 80h, 05h, 80h, 41h, 70h, 41h
		db	 70h, 00h, 38h, 00h, 28h, 00h
		db	 1Eh, 00h, 12h, 00h, 1Fh, 66h
		db	 01h, 1Fh, 00h, 10h, 00h, 1Fh
		db	 00h, 11h, 00h, 0Fh, 66h, 01h
		db	 0Fh, 00h, 0Bh, 00h, 07h, 00h
		db	 01h, 66h, 0Ah,0C0h, 00h, 40h
		db	 00h,0E0h, 00h, 80h, 00h,0F0h
		db	 00h,0C0h, 00h,0F4h, 00h, 74h
		db	 00h,0FFh, 00h, 6Fh, 00h,0EAh
		db	0AAh,0EAh,0AAh, 15h, 55h, 15h
		db	 55h,0EAh,0AAh,0EAh,0AAh, 75h
		db	 55h, 75h, 55h, 02h, 2Ah, 02h
		db	 2Ah, 7Dh, 55h, 7Dh, 55h,0EAh
		db	0AAh,0EAh,0AAh, 6Dh, 02h,0A8h
		db	0B8h,0A8h,0B8h, 54h, 1Eh, 54h
		db	 1Eh,0AAh, 8Bh,0AAh, 8Bh, 55h
		db	 47h, 55h, 47h,0AAh,0A1h,0AAh
		db	0A1h, 55h, 54h, 55h, 54h, 67h
		db	 02h, 6Dh, 02h, 66h, 02h, 80h
		db	 66h, 01h,0E0h, 00h,0E0h, 00h
		db	 78h, 00h, 78h, 00h, 2Ch, 00h
		db	 2Ch, 00h, 0Eh, 00h, 0Eh, 00h
		db	 87h, 80h, 85h, 80h, 42h,0E0h
		db	 42h, 60h, 00h, 07h, 00h, 01h
		db	 00h, 07h, 00h, 04h, 00h, 03h
		db	 00h, 02h, 00h, 07h, 00h, 06h
		db	 00h, 03h, 00h, 02h, 00h, 07h
		db	 00h, 06h, 00h, 03h, 00h, 02h
		db	 00h, 03h, 00h, 03h,0FFh,0C0h
		db	 3Fh,0C0h,0FBh,0A0h, 6Bh,0A0h
		db	0FFh,0D0h,0FFh,0D0h,0EFh,0F8h
		db	 0Fh,0F8h,0FFh,0D4h, 5Fh,0D4h
		db	0FBh,0FAh,0FBh,0FAh,0FFh,0D5h
		db	 3Fh,0D5h,0FEh,0EAh, 3Eh,0EAh
		db	0FFh,0F5h, 7Fh,0F5h,0EFh,0AAh
		db	0EFh,0AAh, 7Eh,0F5h, 5Eh,0F5h
		db	0FEh,0AAh,0FEh,0AAh, 77h,0D5h
		db	 77h,0D5h, 7Ah,0AAh, 7Ah,0AAh
		db	0F7h,0D5h,0F7h,0D5h,0DAh, 2Ah
		db	0DAh, 2Ah, 40h, 00h, 40h, 00h
		db	0A0h, 00h,0A0h, 00h, 40h, 00h
		db	 40h, 00h,0B0h, 00h,0B0h, 00h
		db	 48h, 00h, 48h, 00h, 94h, 00h
		db	 94h, 00h, 54h, 00h, 54h, 00h
		db	0AAh, 00h,0AAh, 66h, 00h, 38h
		db	 40h, 45h, 03h, 00h, 04h,0FEh
		db	 30h, 60h, 4Fh, 9Fh, 02h, 00h
		db	0FDh,0FAh, 00h, 0Ah,0FFh, 55h
		db	 01h, 80h,0EAh, 7Fh, 18h, 00h
		db	0A7h,0EFh, 80h, 00h, 7Eh,0BEh
		db	 1Fh, 55h, 1Fh, 55h, 1Ah,0AAh
		db	 1Ah,0AAh, 37h, 55h, 37h, 55h
		db	 22h,0AAh, 22h,0AAh, 0Dh, 15h
		db	 0Dh, 15h,0CAh,0AAh,0CAh,0AAh
		db	0E1h, 55h,0E1h, 55h,0B8h, 0Ah
		db	0B8h, 0Ah, 55h, 00h, 55h, 00h
		db	0AAh, 80h,0AAh, 80h, 55h, 00h
		db	 55h, 00h,0AAh, 80h,0AAh, 80h
		db	 55h, 40h, 55h, 40h,0AAh,0A0h
		db	0AAh,0A0h, 55h, 50h, 55h, 50h
		db	0AAh,0A0h,0AAh,0A0h, 66h, 03h
		db	 01h, 00h, 01h, 00h, 02h, 00h
		db	 02h, 00h, 10h, 00h, 10h, 00h
		db	 05h, 00h, 04h, 00h, 1Eh, 00h
		db	 02h, 00h,0E0h, 00h, 20h, 66h
		db	 02h, 67h, 02h, 54h, 00h, 54h
		db	 00h, 81h, 5Fh, 81h, 41h, 3Fh
		db	0F0h, 25h, 10h,0F0h, 00h, 10h
		db	 66h, 00h, 05h, 00h, 05h, 02h
		db	0AAh, 02h,0AAh, 54h, 15h, 54h
		db	 15h, 80h, 00h, 80h, 00h, 0Fh
		db	0FFh, 00h,0AFh,0F0h, 0Ah, 30h
		db	 0Ah, 66h, 06h, 6Dh, 02h, 67h
		db	 02h, 6Dh, 02h, 00h,0AAh, 00h
		db	0AAh,0D4h, 00h, 84h, 00h,0BFh
		db	0DFh,0BFh, 4Fh, 00h, 15h, 00h
		db	 15h, 66h, 02h, 55h, 00h, 55h
		db	 00h, 67h, 02h, 6Dh, 02h, 67h
		db	 02h, 01h, 55h, 01h, 55h,0E8h
		db	 02h,0C8h, 02h, 7Fh, 74h, 7Eh
		db	 54h, 05h, 5Eh, 05h, 5Eh, 00h
		db	 05h, 00h, 05h,0A8h, 00h,0A8h
		db	 00h
		db	'UPUP,U$'
		db	'U'
		db	 1Eh, 2Ah, 1Eh, 2Ah, 8Bh, 05h
		db	 8Bh,0DEh, 00h, 8Ah, 05h, 8Ah
		db	0B5h, 81h, 95h, 81h, 7Fh,0E2h
		db	 7Ah,0E2h,0FFh,0C7h, 3Fh, 07h
		db	 6Fh, 03h, 6Eh, 03h, 55h, 50h
		db	 55h, 50h,0AAh,0A8h,0AAh,0A8h
		db	 55h, 54h, 55h, 54h,0AAh, 88h
		db	0AAh, 88h, 54h, 44h, 54h, 44h
		db	0A8h, 8Ah,0A8h, 8Ah, 55h, 01h
		db	 55h, 01h,0FFh,0AAh,0FFh, 67h
		db	 00h, 2Ah,0AAh, 2Ah, 04h, 55h
		db	 04h, 55h, 00h, 22h, 00h, 22h
		db	 00h, 15h, 00h, 15h, 00h, 02h
		db	 00h, 02h, 66h, 0Ah, 06h, 17h
		db	 04h, 17h, 0Ch, 2Ah, 08h, 2Ah
		db	 1Ch, 7Dh, 18h, 7Dh, 28h,0B5h
		db	 20h,0B5h, 38h, 2Ah, 30h, 2Ah
		db	 50h,0D5h, 40h,0D5h, 60h,0AAh
		db	 40h,0AAh, 61h,0D5h, 41h,0D5h
		db	0DFh,0FDh,0DFh,0FDh,0AAh,0AFh
		db	0AAh,0AFh, 6Dh, 02h,0B4h,0A2h
		db	0B4h,0A2h,0AAh, 04h,0AAh, 04h
		db	 55h, 10h, 55h, 10h,0E8h, 40h
		db	0E8h, 40h, 45h, 00h, 45h, 66h
		db	 03h,0C0h, 00h,0C0h, 00h,0D0h
		db	 00h,0D0h, 00h,0A0h, 00h,0A0h
		db	 66h, 0Fh, 01h, 54h, 01h, 54h
		db	 3Ch, 28h, 3Ch, 28h, 37h, 04h
		db	 34h, 04h, 37h,0C0h, 37h, 00h
		db	 15h,0E0h, 15h,0C0h, 12h,0F1h
		db	 12h,0C1h, 12h,0F0h, 12h,0E0h
		db	 12h,0F8h, 12h,0E0h,0A0h,0AAh
		db	0A0h,0AAh,0C1h, 55h, 81h, 55h
		db	0C6h,0AAh, 86h,0AAh,0C4h, 55h
		db	 84h, 55h,0CCh,0AAh, 8Ch,0AAh
		db	 41h, 55h, 41h, 55h,0E2h,0AAh
		db	0C2h,0AAh, 21h, 54h, 21h, 54h
		db	0A2h, 00h,0A2h, 00h, 50h, 00h
		db	 50h, 00h, 50h, 00h, 50h, 00h
		db	 40h, 00h, 40h, 00h, 83h,0A0h
		db	 83h,0A0h, 00h, 3Eh, 00h, 30h
		db	 00h, 0Fh, 00h, 0Fh, 34h, 01h
		db	 00h, 01h, 67h, 02h, 15h, 50h
		db	 15h, 50h, 08h, 00h, 08h, 66h
		db	 00h, 5Fh, 00h, 5Fh, 05h,0FEh
		db	 05h,0FEh, 08h,0BFh, 08h,0BFh
		db	 08h,0BFh, 08h,0B1h, 06h, 57h
		db	 06h, 56h, 11h, 78h, 11h, 70h
		db	 09h, 7Ch, 09h, 70h, 00h,0BFh
		db	 00h,0B4h, 54h,0BFh, 54h,0B9h
		db	0A8h, 5Fh,0A8h, 5Fh,0D4h, 5Fh
		db	0D4h, 5Fh,0AAh, 5Fh,0AAh, 5Fh
		db	0F4h, 5Fh, 74h, 5Fh, 01h, 05h
		db	 01h, 05h, 00h, 01h, 00h, 01h
		db	 66h, 09h, 02h, 66h, 01h, 05h
		db	 66h, 01h, 0Dh, 66h, 01h, 1Bh
		db	0FAh, 5Fh, 1Ah
		db	'_}/]/Z', 27h, 'Z', 27h, '-+-+'
		db	 16h, 95h, 16h, 95h, 05h, 02h
		db	 05h, 02h, 00h,0E0h, 40h,0E0h
		db	 00h, 15h,0D0h, 15h, 01h,0C0h
		db	 74h, 66h, 00h, 60h, 80h, 66h
		db	 00h, 03h, 00h, 0Ch, 00h, 40h
		db	 00h,0BFh, 07h, 20h, 08h, 0Dh
		db	0BCh, 32h, 02h, 01h, 40h,0F0h
		db	 66h, 00h, 03h, 80h, 66h, 00h
		db	 08h, 00h, 17h,0EFh, 40h, 00h
		db	0BEh, 2Fh, 20h, 00h,0DFh, 3Fh
		db	 66h, 00h, 3Fh,0EAh, 66h, 00h
		db	0F2h, 00h, 03h, 80h,0E8h, 66h
		db	 00h, 40h, 80h, 66h, 05h,0ABh
		db	0FFh, 66h, 00h,0FFh,0F0h, 66h
		db	 00h,0F5h, 66h, 01h, 80h, 66h
		db	 0Fh, 1Ch, 00h,0A2h, 02h, 00h
		db	0C0h, 7Fh, 20h, 06h, 0Ch,0F9h
		db	0F2h, 00h, 40h, 5Fh,0BFh, 50h
		db	 00h,0AAh,0FFh, 01h, 80h,0FEh
		db	 57h, 00h, 18h,0F7h,0E5h, 00h
		db	 01h, 7Dh, 7Eh, 66h, 0Eh, 03h
		db	0A0h, 03h,0A0h, 00h, 3Eh, 00h
		db	 30h, 00h, 0Fh, 00h, 0Fh, 34h
		db	 01h, 00h, 01h, 00h, 05h, 00h
		db	 05h, 00h, 17h, 00h, 17h, 00h
		db	 4Eh, 00h, 4Eh, 00h, 11h, 00h
		db	 11h, 01h, 42h, 01h, 42h, 00h
		db	 3Fh, 00h, 20h, 07h,0FFh, 05h
		db	 10h, 3Fh,0FFh, 32h, 8Bh, 7Fh
		db	0FFh, 7Fh, 7Bh, 00h, 75h,0FFh
		db	 75h,0D5h, 15h,0D5h, 15h, 6Dh
		db	 02h, 7Bh, 00h, 80h, 05h, 7Bh
		db	 00h, 29h,0BDh, 7Bh, 00h,0BFh
		db	0FFh,0FDh,0FFh,0FDh, 7Bh, 03h
		db	 5Fh, 57h, 5Fh, 57h, 6Dh, 06h
		db	0F8h, 01h, 50h, 01h,0FFh,0FEh
		db	0F8h,0AAh, 7Bh, 01h,0FEh,0FEh
		db	0EEh,0FEh,0EEh, 7Bh, 01h,0A8h
		db	0AAh,0FFh,0AAh,0F7h, 6Dh, 02h
		db	 49h, 55h, 49h, 55h, 95h, 4Ah
		db	 95h, 4Ah, 55h, 52h, 55h, 52h
		db	0FFh, 65h, 2Fh, 65h,0AAh,0B8h
		db	0AAh,0B8h,0FFh, 82h, 43h, 82h
		db	0ABh, 54h, 0Bh, 14h, 55h, 6Eh
		db	 55h, 02h, 47h,0A9h, 40h,0A9h
		db	 9Dh, 0Bh, 85h, 0Bh,0BCh, 5Fh
		db	 84h, 5Fh, 38h,0BFh, 18h,0BFh
		db	 78h, 5Fh, 18h, 5Fh, 0Fh,0FFh
		db	 08h,0BFh, 7Fh,0FFh, 44h,0FFh
		db	 3Fh,0FEh, 23h,0FEh, 7Bh, 00h
		db	 45h,0FFh,0FEh,0EAh, 1Eh,0EAh
		db	 45h,0D5h, 45h,0D5h,0FEh,0AAh
		db	 3Eh,0AAh,0DDh, 55h,0DDh, 55h
		db	0FFh,0FEh,0FFh,0FEh,0F7h, 75h
		db	0F7h, 75h,0EAh,0AAh,0EAh,0AAh
		db	 6Dh, 02h, 67h, 02h, 6Dh, 02h
		db	 67h, 02h, 6Dh, 02h,0EBh,0AAh
		db	0EBh,0AAh, 6Dh, 02h, 67h, 02h
		db	 6Dh, 02h,0AAh,0ABh,0AAh,0ABh
		db	 55h, 4Ah, 55h, 4Ah,0AAh, 53h
		db	0AAh, 52h, 56h,0BFh, 56h,0B4h
		db	 95h, 52h, 95h, 50h, 6Dh, 02h
		db	 67h, 01h,0A0h, 55h, 5Fh, 55h
		db	 51h, 4Bh,0FDh, 4Ah, 1Dh, 3Fh
		db	0E0h, 21h,0E0h,0FEh, 00h, 1Eh
		db	 01h,0E0h, 00h, 60h, 0Bh,0B9h
		db	 3Fh, 99h, 3Fh, 54h, 5Fh, 10h
		db	 5Fh,0FFh, 1Fh, 69h, 1Fh,0F8h
		db	 2Bh, 88h, 2Bh, 00h, 95h, 00h
		db	 95h, 05h, 02h, 05h, 02h, 00h
		db	0E0h, 40h,0E0h, 00h, 15h,0D0h
		db	 15h, 00h, 03h, 00h, 02h, 00h
		db	 06h, 00h, 06h, 00h, 0Bh, 00h
		db	 09h, 00h, 07h, 00h, 03h, 00h
		db	 0Ah, 00h, 0Ah, 00h, 0Fh, 00h
		db	 03h, 00h, 06h, 00h, 06h, 00h
		db	 0Dh, 00h, 05h, 67h, 02h, 6Dh
		db	 02h,0AAh,0A9h,0AAh,0A9h, 55h
		db	 5Ah, 55h, 5Ah,0AAh, 57h,0AAh
		db	 57h, 55h,0BFh, 55h,0BFh,0ABh
		db	 7Ch,0ABh, 7Ch, 55h, 70h, 55h
		db	 70h, 54h,0FEh, 54h,0FEh,0A7h
		db	0E0h,0A7h,0E0h, 1Fh, 80h, 1Fh
		db	 80h,0FEh, 00h,0FEh, 00h,0F0h
		db	 00h,0F0h, 00h, 80h, 00h, 80h
		db	 66h, 02h, 0Dh, 66h, 00h, 05h
		db	0DFh, 02h, 00h,0FDh, 66h, 00h
		db	 58h, 5Fh,0A0h, 00h,0DEh, 00h
		db	0FAh, 80h, 00h, 61h, 5Fh, 20h
		db	 00h,0D8h, 0Bh, 04h, 00h,0FAh
		db	 17h, 03h, 00h,0FCh, 80h, 00h
		db	0C0h,0BFh, 20h, 2Ah,0AAh, 2Ah
		db	0AAh, 55h, 5Ah, 55h, 5Ah, 2Ah
		db	0D5h, 2Ah,0D5h, 55h,0AFh, 55h
		db	0AFh, 55h, 7Ch, 55h, 7Ch,0D7h
		db	 80h,0D7h, 80h,0F8h, 00h,0F8h
		db	 03h, 66h, 01h, 07h, 55h,0E0h
		db	 55h,0E0h, 9Fh, 80h, 9Fh, 85h
		db	0FCh, 08h,0FCh, 27h,0C0h, 00h
		db	0C2h,0DFh, 00h, 02h, 2Fh, 3Dh
		db	 66h, 00h,0B7h,0F5h, 03h, 00h
		db	0FCh,0F9h, 10h, 00h,0CFh,0C0h
		db	 66h, 08h, 80h, 00h,0E0h, 00h
		db	 10h, 00h, 0Ch, 00h,0F2h, 00h
		db	 03h, 00h, 9Ch,0C0h, 00h, 08h
		db	 89h,0F4h, 00h, 03h, 02h, 6Ch
		db	 66h, 07h, 07h, 00h, 04h, 00h
		db	0FFh, 00h, 85h, 07h,0E0h, 04h
		db	'`?U#Uz(Z('
		db	0C0h, 00h,0C0h, 66h, 00h, 1Fh
		db	 00h, 11h, 1Fh,0FAh, 12h, 5Ah
		db	0FDh, 00h, 2Dh, 00h, 40h, 45h
		db	 40h, 45h, 2Ah,0AAh, 2Ah,0AAh
		db	 6Dh, 02h, 0Bh,0EAh, 0Bh,0EAh
		db	 10h, 14h, 10h, 14h,0FEh,0D0h
		db	 2Ah,0D0h, 80h, 01h, 80h, 01h
		db	 2Ah,0AAh, 2Ah,0AAh, 6Dh, 02h
		db	 67h, 02h, 6Dh, 02h, 67h, 02h
		db	 75h, 05h, 75h, 05h, 66h, 02h
		db	 14h, 45h, 14h, 45h, 67h, 02h
		db	 6Dh, 02h, 67h, 02h, 6Dh, 02h
		db	0AAh, 80h,0AAh, 80h, 50h, 17h
		db	 50h, 14h, 66h, 02h, 55h, 04h
		db	 55h, 04h, 67h, 02h, 6Dh, 02h
		db	 67h, 02h, 66h, 02h, 0Ah,0FFh
		db	 0Ah, 62h,0FFh,0EAh, 15h,0EAh
		db	 2Dh,0FFh, 2Dh,0FFh, 00h, 05h
		db	 00h, 05h,0AAh,0A0h,0AAh,0A0h
		db	 6Dh, 02h, 66h, 02h, 2Bh,0FFh
		db	 29h, 85h,0FFh,0D4h, 2Fh,0D4h
		db	 00h, 01h, 00h, 01h,0FFh, 00h
		db	0A1h, 00h, 7Fh,0F8h, 7Fh, 18h
		db	 05h,0FFh, 05h,0E0h, 00h, 0Fh
		db	 00h, 04h, 3Fh,0FFh, 20h, 9Dh
		db	0EEh,0BBh,0EEh,0BBh, 00h, 03h
		db	 00h, 03h, 55h, 51h, 55h, 51h
		db	 66h, 06h,0D0h, 00h, 50h, 00h
		db	0FFh, 60h, 11h, 60h,0F0h, 02h
		db	 10h, 02h,0E1h, 7Fh, 21h, 7Eh
		db	0F1h,0FFh, 91h,0FFh,0F0h, 7Fh
		db	 90h, 7Fh, 66h, 0Eh, 80h, 00h
		db	 80h, 00h,0F6h,0A1h, 80h, 01h
		db	 7Bh, 00h,0E4h, 78h,0DFh,0FFh
		db	0DFh,0D4h, 66h, 16h,0F4h, 48h
		db	 80h, 48h,0FFh,0FEh, 23h,0FEh
		db	 1Eh,0AAh, 1Eh,0AAh, 0Dh, 00h
		db	 0Dh, 00h, 08h, 1Fh, 08h, 12h
		db	 41h,0F5h, 40h, 75h, 9Eh, 00h
		db	 86h, 00h,0E0h, 00h, 20h, 66h
		db	 07h, 02h,0FEh, 02h, 46h, 1Fh
		db	0D1h, 12h,0D1h,0E0h, 02h,0A0h
		db	 02h, 45h, 55h, 45h, 55h, 1Ah
		db	 92h, 1Ah, 92h, 00h, 1Dh, 00h
		db	 1Dh, 66h, 0Ah, 6Dh, 02h, 67h
		db	 02h, 6Dh, 02h, 0Bh, 6Ah, 0Bh
		db	 6Ah, 50h, 07h, 50h, 07h, 01h
		db	 12h, 01h, 12h, 66h, 04h,0FFh
		db	0D5h, 66h, 00h, 0Fh,0FFh, 66h
		db	 01h,0AFh, 66h, 01h, 01h, 66h
		db	 0Eh,0F8h,0FFh,0E8h,0FFh, 3Ch
		db	0EFh, 24h,0EFh, 5Eh, 3Dh, 52h
		db	 3Dh, 2Fh, 9Fh, 2Dh, 9Fh, 17h
		db	0C5h, 17h,0C5h, 05h,0E0h, 05h
		db	0E0h, 81h, 79h, 81h, 79h, 40h
		db	 0Dh, 40h, 0Dh,0FDh,0F7h,0FDh
		db	0F7h,0FEh,0AAh,0FEh,0AAh,0D7h
		db	 55h,0D7h, 55h, 62h,0AAh, 62h
		db	0AAh,0D5h, 55h,0D5h, 55h,0A2h
		db	0AAh,0A2h,0AAh, 54h, 55h, 54h
		db	 55h, 2Ah,0AAh, 2Ah,0AAh, 55h
		db	 50h, 55h, 50h,0AAh, 80h,0AAh
		db	 80h, 54h, 00h, 54h, 00h,0A8h
		db	 00h,0A8h, 00h, 43h,0A0h, 43h
		db	0A0h, 80h, 3Eh, 80h, 30h, 00h
		db	 0Fh, 00h, 0Fh, 34h, 01h, 00h
		db	 01h, 00h, 10h,0F7h,0E8h, 00h
		db	 02h,0F4h, 7Dh, 00h, 04h,0FCh
		db	0FBh, 66h, 00h, 57h,0FCh, 66h
		db	 01h, 4Fh, 01h,0C0h, 00h, 17h
		db	 02h, 66h, 00h, 01h, 66h, 04h
		db	0AFh,0F8h, 66h, 00h, 5Fh,0FFh
		db	 66h, 00h,0F7h,0FFh, 01h, 04h
		db	0FEh, 59h, 66h, 00h,0BBh,0FFh
		db	 66h, 00h, 01h,0A7h, 2Eh, 00h
		db	 2Eh, 00h, 7Fh, 9Ch, 7Fh, 9Ch
		db	 66h, 18h,0C0h, 66h, 01h,0E0h
		db	 66h, 09h, 3Ch, 66h, 01h,0D0h
		db	 66h, 0Fh, 17h, 3Fh, 17h, 3Fh
		db	 66h, 1Ah,0CEh, 02h,0CEh, 3Ch
		db	 3Fh, 80h, 3Fh, 9Fh, 07h, 80h
		db	 07h, 8Bh, 01h, 21h, 01h, 26h
		db	 00h, 70h, 00h, 33h, 00h, 38h
		db	 00h, 0Bh, 66h, 03h, 1Eh, 00h
		db	 06h, 66h, 00h, 78h, 66h, 01h
		db	0FCh, 66h, 01h,0FEh, 00h, 10h
		db	 00h,0ABh, 00h, 08h, 00h,0F5h
		db	 00h, 20h, 00h,0C7h, 80h, 66h
		db	 00h,0FFh, 80h, 02h, 00h, 75h
		db	 80h, 66h, 19h, 03h, 66h, 01h
		db	 07h, 66h, 00h, 1Fh,0F5h, 66h
		db	 00h,0FFh,0FAh, 66h, 00h,0FFh
		db	0EFh, 20h, 80h, 9Ah, 7Fh, 66h
		db	 00h,0FFh,0DDh, 66h, 00h,0E5h
		db	 80h, 00h, 74h, 00h, 74h, 39h
		db	0FEh, 39h,0FEh, 66h, 01h, 1Eh
		db	 66h, 01h, 3Fh, 66h, 01h, 7Fh
		db	 00h, 08h, 00h,0D5h, 00h, 10h
		db	 00h,0AFh, 00h, 04h, 01h,0E3h
		db	 66h, 00h, 01h,0FFh, 00h, 40h
		db	 01h,0AEh, 40h, 73h, 3Ch, 73h
		db	 01h,0FCh,0F9h,0FCh, 01h,0E0h
		db	0D1h,0E0h, 84h, 80h, 64h, 80h
		db	 0Eh, 00h,0CCh, 00h, 1Ch, 00h
		db	0D0h, 66h, 03h, 78h, 00h, 60h
		db	 00h,0FCh,0E8h,0FCh,0E8h, 66h
		db	 25h, 3Ch, 66h, 01h, 0Bh, 66h
		db	 0Fh, 0Eh, 00h, 06h, 00h, 0Eh
		db	 00h, 06h, 66h, 03h, 07h, 00h
		db	 03h, 00h, 07h, 00h, 03h, 00h
		db	 07h, 00h, 03h, 66h, 03h, 07h
		db	 00h, 05h, 66h, 00h, 7Fh,0C0h
		db	 06h, 00h, 79h, 80h, 66h, 00h
		db	0EBh,0C0h, 66h, 00h, 3Eh, 80h
		db	 18h, 00h, 26h,0C0h, 66h, 00h
		db	 5Fh, 80h, 66h, 00h, 3Dh,0C0h
		db	 08h, 00h, 17h, 80h, 00h, 07h
		db	 00h, 05h, 66h, 03h, 0Fh, 00h
		db	 03h, 00h, 0Eh, 00h, 02h, 66h
		db	 03h, 38h, 00h, 09h, 00h, 70h
		db	 00h, 13h, 66h, 01h, 0Dh, 66h
		db	 00h, 33h, 66h, 01h, 5Fh, 00h
		db	 20h, 00h, 55h, 66h, 01h, 7Ch
		db	 00h, 08h, 00h,0B4h, 66h, 01h
		db	0E8h, 00h, 40h, 00h,0B0h, 66h
		db	 01h,0A0h, 66h, 0Fh, 18h, 00h
		db	 24h, 00h, 18h,0EDh, 07h, 12h
		db	 0Ch, 00h, 03h,0FFh, 06h, 00h
		db	 01h, 66h, 13h, 20h, 00h,0D0h
		db	 00h, 02h, 80h,0FDh, 7Ch, 66h
		db	 00h, 7Dh, 50h, 03h, 07h, 00h
		db	 88h, 01h, 66h, 00h,0E3h, 00h
		db	 80h, 00h, 70h, 00h, 40h, 00h
		db	 38h, 66h, 01h, 3Ch, 66h, 01h
		db	 0Ch, 66h, 01h, 06h, 66h, 01h
		db	 01h, 66h, 00h, 80h, 00h,0E0h
		db	 00h, 18h, 00h, 06h, 80h,0F9h
		db	 40h, 00h, 07h, 0Fh, 77h, 00h
		db	 10h, 00h,0C8h, 00h, 01h, 00h
		db	 1Ah, 66h, 01h, 02h, 66h, 00h
		db	 80h, 66h, 0Bh, 80h, 1Dh, 80h
		db	 00h, 3Bh,0CEh, 08h, 4Eh, 80h
		db	 00h, 44h, 11h, 02h, 84h,0B5h
		db	 53h, 66h, 00h, 15h, 76h, 07h
		db	 89h, 00h, 96h, 1Eh, 00h, 02h
		db	 5Dh,0C0h, 80h, 01h, 68h,0C0h
		db	 20h,0CDh, 50h, 22h, 00h, 55h
		db	0A0h, 80h, 00h, 5Dh, 66h, 01h
		db	 54h, 66h, 01h,0A0h, 00h, 03h
		db	 80h, 00h, 2Eh, 06h, 66h, 00h
		db	 01h,0C0h, 00h, 30h, 00h, 02h
		db	 00h,0FDh, 00h, 04h,0E0h,0B0h
		db	 10h, 4Ch, 3Dh, 80h, 40h, 0Fh
		db	 02h, 66h, 00h, 01h,0C0h, 66h
		db	 01h, 01h, 00h, 02h, 00h, 02h
		db	 00h, 05h, 00h, 0Ch, 00h, 13h
		db	 00h, 18h, 00h, 24h, 00h, 20h
		db	 00h, 53h, 00h, 61h, 00h, 92h
		db	 00h, 83h, 01h, 64h, 01h,0C3h
		db	 00h,0C5h, 60h, 00h, 88h, 00h
		db	 01h, 00h,0BCh, 00h, 06h,0E8h
		db	 10h, 66h, 00h, 16h, 66h, 08h
		db	0E8h, 66h, 05h, 03h, 00h, 04h
		db	0AFh, 06h, 00h, 01h, 0Dh, 00h
		db	 02h, 0Fh, 12h, 08h, 02h, 16h
		db	 1Ah, 00h, 06h, 1Ch, 1Eh, 00h
		db	 06h, 38h, 16h, 00h, 05h, 30h
		db	 35h, 00h, 03h, 20h, 13h, 66h
		db	 00h, 20h, 66h, 01h, 10h, 66h
		db	 01h, 18h, 66h, 01h, 0Ah, 66h
		db	 01h, 04h, 66h, 01h, 02h, 66h
		db	 01h, 01h, 66h, 04h, 02h, 00h
		db	 0Ah, 66h, 01h, 0Eh, 66h, 01h
		db	 03h, 66h, 01h, 02h, 66h, 0Eh
		db	 80h, 00h, 80h, 00h,0D0h, 00h
		db	0D0h, 00h, 2Fh, 5Eh, 2Fh, 5Eh
		db	 01h, 5Ch, 81h, 5Ch, 00h, 08h
		db	0B4h, 08h, 66h, 00h, 1Fh, 5Ah
		db	 66h, 00h, 05h, 7Dh, 66h, 01h
		db	 2Ah, 66h, 00h, 03h,0FEh, 00h
		db	 60h, 01h, 9Eh, 66h, 00h, 03h
		db	0D7h, 66h, 00h, 01h, 7Ch, 00h
		db	 18h, 03h, 64h, 66h, 00h, 01h
		db	0FAh, 66h, 00h, 03h,0BCh, 00h
		db	 10h, 01h,0E8h, 70h, 00h, 60h
		db	 00h, 70h, 00h, 60h, 66h, 03h
		db	0E0h, 00h,0C0h, 00h,0E0h, 00h
		db	0C0h, 00h,0E0h, 00h,0C0h, 66h
		db	 03h,0E0h, 00h,0A0h, 66h, 02h
		db	0CCh, 66h, 01h,0FAh, 00h, 04h
		db	 00h,0AAh, 66h, 01h, 3Eh, 00h
		db	 10h, 00h, 2Dh, 66h, 01h, 17h
		db	 00h, 02h, 00h, 0Dh, 66h, 01h
		db	 05h,0E0h, 00h,0A0h, 66h, 03h
		db	0F0h, 00h,0C0h, 00h, 70h, 00h
		db	 40h, 66h, 03h, 1Ch, 00h, 90h
		db	 00h, 0Eh, 00h,0C8h, 66h, 01h
		db	0B0h, 00h, 7Fh,0FDh, 66h, 00h
		db	0DFh,0F7h, 66h, 00h,0F7h,0DFh
		db	 66h, 00h,0FDh, 7Fh, 66h, 00h
		db	0FDh, 7Fh, 66h, 00h,0F7h,0DFh
		db	 66h, 00h,0DFh,0F7h, 66h, 00h
		db	 7Fh,0FDh, 66h, 00h, 91h,0E0h
		db	 69h, 66h, 00h, 78h,0BAh, 40h
		db	 01h, 03h, 16h, 80h, 04h, 03h
		db	 0Ah,0B3h, 00h, 44h, 05h,0AAh
		db	 00h, 01h, 00h,0BAh, 66h, 01h
		db	 2Ah, 66h, 01h, 05h, 66h, 0Ah
		db	0B8h, 01h, 00h, 01h, 73h,0DCh
		db	 72h, 10h, 00h, 01h, 88h, 22h
		db	 21h, 40h,0CAh,0ADh, 66h, 00h
		db	 6Eh,0A8h, 66h, 01h, 01h, 00h
		db	 07h, 00h, 18h, 01h, 60h, 02h
		db	 9Fh,0E0h, 00h,0EEh,0F0h, 08h
		db	 00h, 13h, 00h, 80h, 00h, 58h
		db	 66h, 01h, 40h, 66h, 02h, 01h
		db	0E0h,0C0h, 11h, 66h, 00h, 80h
		db	0C7h, 00h, 01h, 00h, 0Eh, 00h
		db	 02h, 00h, 1Ch, 66h, 01h, 3Ch
		db	 66h, 01h, 30h, 66h, 01h, 60h
		db	 66h, 01h, 80h, 66h, 14h, 04h
		db	 00h, 0Bh, 01h, 40h, 3Eh,0BFh
		db	 66h, 00h, 0Ah,0BEh, 66h, 0Fh
		db	 18h, 00h, 24h,0B7h, 18h, 48h
		db	0E0h, 00h, 30h,0FFh,0C0h, 00h
		db	 60h, 00h, 80h, 66h, 05h, 01h
		db	 66h, 01h, 03h, 66h, 01h, 03h
		db	 66h, 01h, 06h, 66h, 01h, 0Eh
		db	 66h, 01h, 0Eh, 66h, 01h, 1Ch
		db	 80h, 00h, 40h, 00h, 40h, 00h
		db	0A0h, 00h, 30h, 00h,0C8h, 00h
		db	 18h, 00h, 24h, 00h, 04h, 00h
		db	0CAh, 00h, 86h, 00h, 49h, 00h
		db	0C1h, 00h, 26h, 80h, 40h, 80h
		db	0A3h, 40h, 00h, 08h, 00h, 14h
		db	 00h, 18h, 00h, 24h, 00h, 10h
		db	 00h, 28h, 66h, 01h, 70h, 00h
		db	 20h, 00h, 40h, 66h, 01h,0C0h
		db	 66h, 01h, 80h, 66h, 03h,0C0h
		db	0F5h, 20h, 00h, 60h,0B0h, 80h
		db	 40h, 00h, 48h,0F0h, 40h, 10h
		db	 58h, 68h, 60h, 00h, 78h, 38h
		db	 60h, 00h, 68h, 1Ch,0A0h, 00h
		db	0ACh, 0Ch,0C0h, 00h,0C8h, 04h
		db	 00h, 01h, 00h, 01h, 00h, 0Bh
		db	 00h, 0Bh, 7Ah,0F4h, 7Ah,0F4h
		db	 3Ah, 80h, 3Ah, 81h, 10h, 00h
		db	 10h, 2Dh, 66h, 00h, 5Ah,0F8h
		db	 66h, 00h,0BEh,0A0h, 66h, 00h
		db	 54h, 00h, 40h, 00h, 50h, 66h
		db	 01h, 70h, 66h, 01h,0C0h, 66h
		db	 01h, 40h, 66h, 0Fh,0FDh, 03h
		db	0FDh, 2Ch,0A0h, 00h,0AAh,0D0h
		db	 00h, 01h, 00h, 0Ah, 02h, 30h
		db	 0Dh, 4Dh, 00h, 03h, 01h,0A0h
		db	 00h, 04h, 00h, 30h, 66h, 01h
		db	 05h, 66h, 02h, 01h, 11h,0FEh
		db	 4Ch, 00h, 19h, 40h, 00h,0A1h
		db	 47h, 52h,0A0h, 00h,0FFh, 54h
		db	 27h,0D7h,0A0h,0D6h,0A0h, 66h
		db	 01h, 55h, 66h, 00h,0EAh,0A9h
		db	 00h, 01h, 15h,0D0h,0FDh, 03h
		db	0FDh, 2Ch,0A0h, 00h,0AAh,0D0h
		db	 66h, 07h, 03h, 66h, 01h, 04h
		db	 66h, 08h, 97h, 00h,0FEh,0CCh
		db	 00h, 01h, 40h, 18h, 20h, 07h
		db	 00h, 60h, 00h,0FFh, 00h, 27h
		db	0D7h,0A0h,0D6h,0A0h, 66h, 01h
		db	0A9h, 11h, 66h, 00h,0D1h, 02h
		db	 01h, 11h,0A0h, 24h, 02h, 03h
		db	 45h, 0Ch, 00h, 22h, 1Dh, 10h
		db	 00h, 2Eh,0A8h, 04h, 00h, 02h
		db	 66h, 0Fh, 88h, 80h, 32h, 7Fh
		db	 98h, 66h, 00h, 02h,0E2h, 85h
		db	 05h, 4Ah,0FFh, 00h,0E4h, 2Ah
		db	 05h,0EBh, 05h, 6Bh, 66h, 00h
		db	0AAh, 66h, 01h, 95h, 57h, 66h
		db	 00h, 4Bh,0A8h,0C0h,0BFh, 34h
		db	0BFh, 00h, 05h, 0Bh, 55h, 80h
		db	 00h, 50h, 00h, 0Ch, 40h,0B2h
		db	0B0h,0C0h, 00h, 05h, 80h, 20h
		db	 00h, 0Ch, 66h, 01h,0A0h, 66h
		db	 03h, 93h, 00h, 33h, 7Fh, 80h
		db	 00h, 18h, 02h,0E0h, 04h, 06h
		db	 00h,0FFh, 00h,0E4h, 00h, 05h
		db	0EBh, 05h, 6Bh, 66h, 00h, 95h
		db	 66h, 00h, 88h, 8Bh, 00h, 80h
		db	 40h, 05h, 88h,0C0h,0BFh, 34h
		db	0BFh, 00h, 05h, 0Bh, 55h, 66h
		db	 06h,0C0h, 66h, 01h, 20h, 66h
		db	 09h, 40h, 24h,0A2h,0C0h, 00h
		db	 30h,0B8h, 44h, 00h, 08h, 15h
		db	 74h, 00h, 20h, 00h, 40h, 66h
		db	 28h,0B0h, 66h, 01h,0FBh,0A0h
		db	 66h, 04h,0E0h, 00h, 18h, 00h
		db	0E7h, 66h, 01h,0FFh,0F0h, 40h
		db	 00h,0BCh,0FCh, 66h, 00h,0AFh
		db	0EFh, 00h,0C0h, 9Fh, 3Fh, 00h
		db	 08h, 03h,0F3h, 66h, 19h, 0Dh
		db	 66h, 00h, 05h,0DFh, 66h, 05h
		db	 07h, 00h, 18h, 00h,0E7h, 66h
		db	 00h, 0Fh,0FFh, 00h, 02h, 3Fh
		db	 3Dh, 66h, 00h,0F7h,0F5h, 03h
		db	 00h,0FCh,0F9h, 10h, 00h,0CFh
		db	0C0h, 00h, 2Bh, 00h, 0Bh, 02h
		db	0D4h, 00h, 20h, 29h, 40h, 06h
		db	 00h,0D4h, 00h,0D0h, 66h, 20h
		db	 2Bh, 00h, 0Fh, 02h,0B4h, 08h
		db	 40h, 2Fh, 40h, 00h, 08h, 60h
		db	 00h, 74h, 66h, 0Eh, 06h, 00h
		db	0ABh, 05h, 5Fh, 21h,0B4h, 1Eh
		db	 40h, 3Fh,0A0h,0C0h, 48h,0A4h
		db	 00h, 5Bh, 66h, 00h, 03h, 00h
		db	 03h, 00h, 08h, 00h, 0Eh, 00h
		db	 30h, 66h, 01h,0C0h, 02h, 30h
		db	 03h, 00h, 08h, 00h, 0Ch, 00h
		db	 08h, 00h, 10h, 00h, 30h, 00h
		db	0C0h, 00h,0C0h, 66h, 00h, 03h
		db	 00h, 03h, 00h, 08h, 00h, 1Eh
		db	 00h, 50h, 00h,0A0h, 01h,0C0h
		db	 02h, 30h, 07h, 80h, 08h, 40h
		db	 1Dh, 00h, 2Ah, 80h, 1Ch, 00h
		db	 72h, 00h, 20h, 00h,0D0h, 66h
		db	 00h, 01h, 00h, 01h, 00h, 02h
		db	 00h, 05h, 00h, 0Eh, 66h, 01h
		db	 24h, 00h, 28h, 00h, 34h, 00h
		db	 04h, 00h, 30h, 00h, 40h, 00h
		db	0D0h, 00h, 10h, 01h,0C0h, 01h
		db	 80h, 03h, 00h, 03h, 00h, 09h
		db	 00h, 03h, 00h, 0Dh, 00h, 05h
		db	 00h, 1Ch, 66h, 01h, 30h, 00h
		db	 08h, 00h, 30h, 00h, 50h, 00h
		db	0C0h, 00h,0C0h, 00h,0C0h, 00h
		db	0C0h, 66h, 00h, 03h, 00h, 01h
		db	 00h, 0Bh, 00h, 1Ch, 00h, 0Ch
		db	 00h, 72h, 00h, 28h, 01h,0D4h
		db	 00h,0F0h, 01h, 0Ch, 00h,0F0h
		db	 03h, 08h, 01h, 40h, 02h,0B0h
		db	 01h, 80h, 02h, 60h, 80h, 00h
		db	 80h, 00h, 40h, 00h,0A0h, 00h
		db	 70h, 66h, 01h, 24h, 00h, 14h
		db	 00h, 2Ch, 00h, 20h, 00h, 0Ch
		db	 00h, 02h, 00h, 0Bh, 00h, 08h
		db	 00h, 03h, 80h, 01h, 80h

_371UNKN	endp

seg_a		ends



		end	start
