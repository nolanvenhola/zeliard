
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				_365UNKN                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   5-Apr-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    5          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	1277h			;*
data_29e	equ	0BA00h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_365UNKN	proc	far

start:
		jmp	short $+17h
		db	0, 0, 0
data_2		db	6			; Data table (indexed access)
		db	 12h, 00h
data_3		db	19h
		db	0AAh, 25h, 80h, 27h, 20h, 2Dh
		db	 02h, 36h,0EAh
data_4		dw	337h			; Data table (indexed access)
		db	 39h, 08h, 46h,0FFh, 4Ch,0A0h
		db	 4Dh,0C0h, 4Eh,0FAh, 4Fh, 0Eh
data_5		db	52h
		db	 0Ah, 53h,0ABh, 58h,0BAh, 59h
		db	 01h, 5Bh,0AEh, 5Ch,0E0h, 61h
		db	 3Ah, 64h, 0Ch, 65h, 8Ah, 66h
		db	0FEh, 67h,0EEh, 6Dh, 38h, 6Fh
		db	 2Ah, 71h, 28h, 72h,0B0h, 73h
		db	0ACh, 74h,0AFh, 79h,0BFh, 7Bh
		db	 0Fh, 8Dh, 30h, 91h,0A8h, 92h
		db	 2Eh, 93h, 22h, 94h, 1Fh, 95h
		db	0A2h, 9Dh,0FBh,0A4h, 07h,0B4h
		db	0B8h,0C4h, 88h,0C5h, 04h,0C6h
		db	 7Fh,0C9h, 82h,0CDh, 0Bh,0CEh
		db	 3Eh,0D2h,0BEh,0D6h, 05h,0D8h
		db	 3Fh,0D9h, 7Ah,0E5h, 10h,0E6h
		db	 7Eh,0F2h,0BBh,0FFh,0FFh, 12h
		db	 2Bh, 80h, 00h, 40h, 12h
data_6		db	0			; Data table (indexed access)
		db	 03h,0E0h, 08h, 00h, 07h,0A0h
		db	 08h, 00h, 07h,0A0h, 20h, 00h
		db	 1Eh, 80h
		db	20h
data_7		db	0			; Data table (indexed access)
		db	 1Eh, 80h, 20h, 00h, 1Eh,0A0h
		db	 0Ch, 00h, 0Eh,0B0h, 0Ch, 00h
		db	 0Fh,0ACh, 12h, 00h, 03h,0EAh
		db	 03h, 80h, 03h,0AAh, 03h
data_8		db	0A0h			; Data table (indexed access)
		db	 03h,0AAh, 00h,0A0h, 00h,0AFh
		db	 12h, 10h,0C0h, 12h, 01h,0AEh
		db	 12h, 01h,0AAh,0F0h, 12h, 00h
		db	0AAh,0ABh, 00h, 02h, 00h, 0Eh
		db	 00h, 03h, 00h, 03h, 12h, 16h
		db	0C0h, 00h,0FAh,0AAh,0B0h, 00h
		db	0BFh,0AAh,0E8h
data_9		dw	0EBECh			; Data table (indexed access)
		db	0EFh, 00h,0FAh, 03h,0FAh, 00h
		db	 28h, 00h, 2Bh, 12h, 1Eh, 0Ah
		db	 28h, 05h,0D7h,0A0h, 00h, 5Fh
		db	0FFh, 33h,0CFh
		db	3Bh
data_10		dw	12EFh, 80Eh		; Data table (indexed access)
		db	 20h, 07h,0DFh, 12h, 00h, 46h
		db	 00h, 00h, 80h,0FEh,0BAh, 8Eh
		db	0A0h,0AEh,0AAh, 12h, 00h,0B8h
		db	 12h, 01h
data_11		db	0AAh			; Data table (indexed access)
		db	0C0h, 12h, 00h,0AAh,0A0h, 12h
		db	 00h,0EAh,0ACh, 12h, 00h,0FFh
		db	0AAh, 3Ch, 00h,0FFh,0EBh, 32h
		db	 00h, 32h,0FAh, 0Eh, 00h, 0Eh
		db	0FAh, 12h, 17h, 03h,0C0h, 12h
		db	 00h, 0Fh,0C0h, 12h, 01h, 03h
		db	0FAh, 02h, 30h, 01h,0FEh, 00h
		db	0ECh, 00h,0EFh, 00h,0C8h, 00h
		db	0CBh, 00h,0CAh, 00h,0CAh, 00h
		db	 38h, 00h, 3Bh, 00h, 08h, 00h
		db	 0Bh, 00h, 08h, 00h, 07h, 00h
		db	 2Ah,0B0h, 15h, 00h, 20h,0B0h
		db	 1Fh, 00h, 80h,0B0h, 7Fh, 00h
		db	 80h,0ACh, 7Eh, 12h, 00h,0ACh
		db	0FBh, 12h, 00h,0ABh,0AEh, 12h
		db	 00h, 36h, 00h, 12h, 00h,0EAh
		db	0BEh, 00h, 03h, 00h, 03h, 00h
		db	 03h, 00h, 0Fh, 12h, 01h,0FFh
		db	 80h, 00h, 7Fh,0FFh, 12h, 00h
		db	0FFh,0EAh, 12h, 00h,0EAh,0AAh
		db	 12h, 00h, 19h, 00h,0B8h, 2Eh
		db	0BAh,0AEh,0E0h, 00h,0EEh,0AFh
		db	 28h, 00h, 2Bh,0AAh,0CAh, 00h
		db	0CAh,0AAh, 38h, 00h,0FBh,0EAh
		db	 12h, 00h,0AFh,0FAh, 02h, 2Ch
		db	0A9h,0EEh,0A0h, 0Ah,0A8h, 3Ah
		db	 80h, 00h, 80h, 12h, 10h, 03h
		db	 12h, 01h, 08h, 00h, 07h, 00h
		db	 20h, 00h, 1Fh, 12h, 01h, 3Eh
		db	 12h, 06h, 08h, 00h, 07h, 4Dh
		db	 00h, 00h, 3Fh,0B0h, 80h, 00h
		db	 7Ah,0ACh, 12h, 00h,0EAh,0AAh
		db	 0Ch, 00h,0ACh, 2Eh, 20h, 00h
		db	0A0h, 28h, 00h, 80h, 00h, 7Eh
		db	 12h, 01h,0FAh, 00h, 03h, 00h
		db	0FBh, 00h, 02h, 00h,0EAh, 0Ah
		db	 00h, 05h,0AAh,0A0h, 00h, 5Fh
		db	0FFh, 80h, 00h, 7Fh,0AAh, 80h
		db	 00h, 7Eh,0AAh, 12h, 00h,0A0h
		db	 38h,0C0h, 00h,0C0h, 00h, 80h
		db	 00h, 80h, 00h, 82h, 25h, 00h
		db	 3Eh, 08h,0E0h, 80h, 0Fh, 23h
		db	0E0h, 80h, 0Ah, 23h,0A0h,0C0h
		db	 0Ah, 22h,0E0h
data_12		db	80h
		db	 0Ah, 12h, 00h,0FAh,0AAh, 12h
		db	 00h,0EAh,0AAh, 7Bh, 00h, 74h
		db	 00h, 32h, 0Ch,0B2h, 0Ch,0C8h
		db	 02h,0C8h, 02h,0EEh, 08h,0E1h
		db	0F4h, 30h, 00h, 8Ah,0BFh, 27h
		db	 00h, 98h, 1Fh, 23h, 25h, 00h
		db	 2Ah, 22h, 25h, 00h, 2Ah, 88h
		db	 00h,0B0h,0AAh,0B0h, 00h,0BEh
		db	0AAh,0A0h, 0Eh,0AAh,0A1h, 00h
		db	 3Ah,0AAh, 85h,0A2h,0A0h, 5Dh
		db	 5Eh, 00h, 08h,0FFh,0B7h, 12h
		db	 00h,0B8h, 3Bh, 00h, 20h,0B8h
		db	 1Ah, 00h, 80h,0ABh, 6Ah, 12h
		db	 00h, 8Ah,0A2h, 12h, 00h,0A0h
		db	 12h, 01h, 19h, 00h,0C0h, 00h
		db	0EAh,0AAh,0A0h,0BAh,0AAh,0BAh
		db	 00h, 02h,0BBh,0A9h, 12h, 00h
		db	0AAh,0BFh, 12h, 00h,0A8h,0FAh
		db	 12h, 00h, 0Fh,0AAh, 12h, 00h
		db	 3Eh,0AAh, 12h, 00h,0AEh,0AAh
		db	 00h
data_13		db	3			; Data table (indexed access)
		db	0AEh,0ABh, 00h, 3Ah,0A2h,0BAh
		db	 12h, 06h, 20h, 00h, 10h, 00h
		db	 80h, 00h, 70h, 00h, 80h, 00h
		db	 6Ch, 12h, 01h,0F8h, 12h, 01h
		db	 3Ah, 00h, 20h, 00h, 1Ah, 12h
		db	 18h, 02h, 00h, 01h, 00h, 3Eh
		db	 00h, 01h, 12h, 00h, 3Eh, 80h
		db	 08h, 00h, 06h,0A0h, 12h, 00h
		db	 0Fh,0A8h, 00h, 37h, 00h,0E8h
		db	 00h,0BFh, 00h, 40h, 28h, 8Ah
		db	 17h, 75h, 80h, 02h, 7Fh,0FDh
		db	 22h, 00h,0DDh,0FFh, 00h,0AEh
		db	 00h, 51h, 00h, 20h, 00h,0DBh
		db	 02h, 00h, 01h,0EEh, 00h, 03h
		db	 83h,0B8h, 00h, 0Fh,0ABh,0E0h
		db	 00h, 0Eh,0ABh,0A0h, 08h, 3Eh
		db	0A7h, 80h, 00h, 38h,0AFh, 80h
		db	 12h, 00h, 67h, 00h, 12h, 00h
		db	 5Bh, 00h,0AAh, 80h, 55h, 6Ah
		db	0CAh,0AAh, 05h, 55h, 8Ah, 88h
		db	 00h, 77h, 3Eh,0A0h, 00h, 5Fh
		db	 3Ah,0A0h, 00h, 1Ah,0FEh, 80h
		db	 00h, 2Eh, 20h, 38h, 9Fh, 80h
		db	 00h, 38h,0BEh, 25h, 00h, 38h
		db	 7Eh,0C0h, 80h, 0Eh, 7Ah,0F0h
		db	 12h, 00h, 66h, 00h, 00h, 08h
		db	0FAh,0B7h, 82h, 00h, 7Dh,0FFh
		db	 28h, 00h, 97h,0EAh,0FBh, 80h
		db	 00h, 2Eh,0EEh, 12h, 00h, 4Eh
		db	 00h, 12h, 00h,0BAh, 28h, 00h
		db	 02h,0EAh, 12h, 00h, 19h, 00h
		db	 12h, 00h,0FAh,0AAh, 00h, 02h
		db	0FFh,0E9h, 12h, 00h,0ABh,0FFh
		db	 12h, 00h,0FAh,0AAh, 12h, 00h
		db	 19h, 00h, 12h, 00h, 19h, 00h
		db	 03h, 83h, 53h, 00h, 38h, 83h
		db	0B8h,0ABh, 32h, 00h,0B2h, 00h
		db	 28h, 00h,0A8h,0EAh, 80h, 00h
		db	0A0h, 2Ah, 12h, 00h,0AAh,0AFh
		db	 12h, 00h,0AAh,0AFh, 12h, 00h
		db	 19h, 00h,0E0h, 00h,0EAh,0AAh
		db	 0Ch, 00h, 0Eh,0AAh, 28h, 3Eh
		db	 2Ah,0BEh, 00h, 32h, 80h, 32h
		db	 12h, 00h,0AAh, 8Ah, 12h, 0Fh
		db	 08h, 00h, 04h, 00h, 20h, 00h
		db	 1Fh, 00h, 08h, 00h, 07h, 12h
		db	 18h,0F0h, 12h, 01h,0ACh, 12h
		db	 01h,0FBh, 12h, 14h, 0Ah, 00h
		db	 05h, 00h, 20h, 00h, 1Fh, 00h
		db	 80h, 00h, 7Fh, 12h, 0Ah, 02h
		db	 82h, 01h, 7Dh,0A0h, 00h, 5Fh
		db	0FFh, 12h, 00h, 46h, 00h, 12h
		db	 00h,0EBh,0FFh, 12h, 00h,0FEh
		db	0BEh, 02h, 88h, 01h, 77h, 0Eh
		db	 00h, 01h,0FFh, 38h,0A2h, 07h
		db	 5Dh,0FCh, 88h, 03h, 77h,0F3h
		db	0EAh, 0Ch, 15h, 0Ch, 88h,0F3h
		db	 77h, 22h, 20h,0DDh,0DFh, 12h
		db	 00h, 46h, 00h, 12h, 00h,0FFh
		db	0FBh, 12h, 00h,0FEh,0EAh, 12h
		db	 00h,0BBh,0BAh, 12h, 00h,0EEh
		db	0AAh, 12h, 00h,0FFh,0EAh, 80h
		db	 00h, 7Fh,0AAh, 12h, 00h,0FAh
		db	0BAh, 12h, 00h, 19h, 00h, 12h
		db	 00h,0FFh,0FBh, 12h, 00h,0BBh
		db	0BAh, 12h, 00h,0AEh,0AAh, 12h
		db	 00h,0AAh,0EAh, 80h, 00h, 7Ah
		db	0AEh, 08h, 0Ah,0B6h,0A5h, 00h
		db	 38h,0BBh, 87h, 00h,0E8h,0AEh
		db	 17h, 12h, 00h, 19h, 00h, 12h
		db	 00h, 19h, 00h, 12h, 00h,0AEh
		db	0AAh, 12h, 00h,0EAh,0AAh, 8Ah
		db	 00h, 75h,0FAh, 20h, 08h,0DFh
		db	0F7h, 80h, 00h, 7Fh,0FFh, 12h
		db	 00h,0AAh,0AFh, 03h, 80h,0A8h
		db	 7Eh, 12h, 00h,0ABh,0FAh, 08h
		db	 00h,0A7h,0EAh, 00h, 03h,0AFh
		db	0ABh, 20h, 0Ch, 9Fh,0ACh, 00h
		db	 0Eh,0FEh,0AEh, 12h, 00h,0FAh
		db	0ABh, 00h,0F0h,0EAh,0FBh, 12h
		db	 00h, 19h, 00h, 12h, 00h, 19h
		db	 00h,0E0h,0F8h,0EAh,0FAh, 20h
		db	0C2h, 2Ah,0C2h, 80h, 28h,0BFh
		db	0EBh, 00h, 08h,0FEh,0A7h, 12h
		db	 00h,0EAh,0BFh, 02h, 00h,0A9h
		db	0FEh, 03h, 20h,0EBh, 2Eh, 00h
		db	 82h,0FEh, 89h, 00h, 20h,0FFh
		db	0DFh, 12h, 00h,0AFh,0FFh, 12h
		db	 00h, 19h, 00h, 12h, 00h, 19h
		db	 00h,0C0h,0F8h,0EAh,0FAh, 83h
		db	 8Ah,0ABh, 8Ah, 12h, 00h,0BFh
		db	0FAh, 00h, 03h,0FFh,0ABh, 00h
		db	 03h,0FAh,0ABh, 00h,0F0h,0AAh
		db	0FAh, 03h, 20h,0ABh, 20h, 0Ch
		db	 80h,0ACh, 82h, 0Eh, 00h,0AEh
		db	 88h, 12h, 01h, 20h, 12h, 0Ah
		db	 80h, 00h, 7Ch, 12h, 00h, 28h
		db	0FFh,0D4h, 12h, 00h, 46h, 00h
		db	 12h, 00h,0EFh,0FFh, 12h, 00h
		db	0FBh,0EEh, 12h, 0Bh, 20h, 00h
		db	 18h, 00h, 80h, 00h, 68h, 02h
		db	 20h, 01h,0A0h, 12h, 00h,0FEh
		db	0A0h, 20h, 80h,0DAh, 80h, 12h
		db	 00h,0AEh,0BBh, 12h, 00h,0EAh
		db	0AEh, 00h, 02h,0AAh,0E9h, 12h
		db	 00h,0AAh,0BBh, 12h, 00h,0AEh
		db	0AFh, 12h, 00h,0AAh,0AEh, 00h
		db	 20h,0AAh, 9Eh, 00h, 20h,0AAh
		db	 9Eh, 20h, 00h,0DAh, 00h, 0Eh
		db	 00h,0EEh,0B0h, 08h, 00h,0E8h
		db	0ACh, 12h, 00h,0A2h,0ABh, 12h
		db	 00h,0A3h,0AAh, 20h, 00h,0A2h
		db	0AAh,0E0h, 00h,0E2h,0AAh, 80h
		db	 00h,0A2h,0AAh, 00h, 80h,0AAh
		db	 7Ah, 00h, 80h,0EAh, 7Ah, 00h
		db	 03h,0AAh,0EBh, 02h, 0Ah,0A9h
		db	0EAh, 02h, 08h,0A9h,0EAh, 12h
		db	 00h,0ABh,0EAh, 08h, 00h,0E7h
		db	0AAh, 00h, 20h,0FFh,0A8h, 12h
		db	 00h, 8Ah,0ABh, 12h, 00h, 8Ah
		db	0AAh, 12h, 00h, 8Ah,0AAh, 12h
		db	 00h, 8Ah,0AAh, 12h, 00h, 2Ah
		db	0AAh, 12h, 00h, 2Bh,0AAh, 12h
		db	 00h, 2Ah,0AAh, 12h, 00h, 19h
		db	 00h, 20h, 30h, 9Eh,0BAh, 00h
		db	 20h,0BEh,0AFh, 80h, 00h, 7Ah
		db	0AFh, 12h, 00h,0FAh, 8Bh, 03h
		db	 80h,0EBh, 8Ah, 0Ch, 80h,0ECh
		db	0A2h, 0Ah, 02h, 19h, 00h, 12h
		db	 00h,0A8h,0AAh, 12h, 00h, 19h
		db	 00h, 12h, 00h, 19h, 00h, 12h
		db	 00h,0FEh,0AAh, 12h, 00h,0FFh
		db	0EAh, 12h, 00h,0ABh,0FAh, 12h
		db	 00h,0AAh,0FEh, 12h, 00h,0AAh
		db	0AFh, 0Fh, 00h, 2Fh,0AAh,0E3h
		db	 00h,0E3h,0AAh, 20h, 00h, 2Eh
		db	0AAh, 80h, 00h, 8Bh,0AAh, 00h
		db	0E0h, 0Ah,0EAh, 00h, 88h, 02h
		db	 8Ah, 00h, 28h, 20h,0AAh, 12h
		db	 00h, 82h, 2Ah, 12h, 01h, 22h
		db	 8Ch,0A0h, 8Ch,0AAh, 93h, 00h
		db	0A2h,0A9h, 12h, 00h,0AAh,0FFh
		db	 12h, 00h, 19h, 00h, 12h, 00h
		db	 19h, 00h, 00h, 03h,0AAh,0ABh
		db	 38h, 0Ch,0BAh,0ACh,0A2h, 0Ah
		db	0A2h,0AAh, 12h, 02h, 80h, 00h
		db	 70h, 12h, 01h,0F0h, 00h, 04h
		db	 00h, 34h, 00h, 05h, 00h, 35h
		db	 00h, 03h, 00h, 2Fh, 00h, 20h
		db	 00h, 1Bh, 00h, 20h, 00h, 1Bh
		db	 12h, 06h, 08h, 00h, 20h, 00h
		db	 1Ch, 00h, 04h, 00h,0E4h, 02h
		db	 10h,0C1h,0D0h, 12h, 00h,0B3h
		db	0D3h, 02h, 06h,0ADh,0D5h, 02h
		db	 0Ch,0A9h,0DFh, 23h, 00h, 1Bh
		db	 00h, 22h, 00h, 1Ah, 12h, 01h
		db	 3Ah, 00h, 03h, 00h,0FBh, 00h
		db	 82h, 00h, 7Ah, 12h, 00h, 20h
		db	0FAh, 10h, 00h, 80h,0E8h, 78h
		db	 08h, 00h,0E8h,0E8h, 00h, 81h
		db	0AAh, 55h, 00h, 03h,0AAh,0E7h
		db	 12h, 00h,0AAh,0F6h, 00h, 80h
		db	0AAh, 69h, 12h, 00h,0AAh,0FAh
		db	 00h, 20h,0AAh,0DAh, 12h, 00h
		db	0AAh,0BAh, 00h, 20h,0EAh, 9Ah
		db	 32h, 20h,0B1h,0E0h, 20h, 00h
		db	0A3h,0A0h, 40h, 80h, 63h, 80h
		db	 40h, 80h, 43h, 80h, 12h, 00h
		db	 83h, 80h, 02h, 00h, 81h,0A0h
		db	0C0h, 20h,0C3h,0E0h, 80h, 20h
		db	 80h,0E0h, 00h, 20h,0AAh, 9Eh
		db	 12h, 00h,0AAh,0FAh, 00h, 80h
		db	0AAh, 7Ah, 00h, 80h,0AAh, 7Ah
		db	 00h, 80h,0AAh, 7Ah, 02h, 00h
		db	0A9h,0EAh, 00h, 02h,0ABh,0EAh
		db	 08h, 0Eh,0E7h,0AEh, 12h, 00h
		db	0A0h,0E8h, 20h, 08h,0A0h,0F8h
		db	0E0h, 82h,0E0h, 6Ah, 80h, 00h
		db	 8Ch,0EAh, 12h, 00h, 2Ch,0FAh
		db	 00h, 03h, 2Bh,0EBh, 00h, 02h
		db	0ABh,0EAh, 12h, 00h,0ABh,0AAh
		db	 00h, 08h,0BEh,0AAh, 12h, 00h
		db	0FAh,0A2h, 00h, 80h,0AAh, 8Fh
		db	 03h, 00h,0ABh, 2Ah, 08h, 00h
		db	0A8h,0AAh, 80h, 00h,0A2h,0AAh
		db	 88h, 00h, 8Ah,0AAh, 00h,0AAh
		db	 28h,0AAh, 12h, 00h,0AFh,0A8h
		db	 00h, 38h,0FEh,0B8h, 00h, 20h
		db	0AAh,0A0h, 12h, 00h,0AAh,0A0h
		db	 03h, 80h,0ABh, 80h, 0Ch, 80h
		db	0ACh, 80h, 0Ah, 00h,0AAh, 12h
		db	 01h, 80h, 12h, 04h, 80h, 00h
		db	 40h, 12h, 00h, 03h, 40h, 08h
		db	 00h, 05h, 12h, 00h, 80h, 0Eh
		db	 80h, 00h, 80h, 0Eh, 80h, 12h
		db	 00h, 3Eh, 12h, 01h, 3Ah, 12h
		db	 11h,0C0h, 12h, 01h,0B0h, 03h
		db	 00h, 02h,0ACh, 01h, 12h, 00h
		db	0ABh, 0Fh, 23h, 00h, 1Bh, 00h
		db	 22h, 00h, 1Ah, 12h, 01h, 3Ah
		db	 00h, 03h, 00h,0FBh, 00h, 82h
		db	 80h, 7Ah, 78h, 02h, 00h,0F9h
		db	0C0h, 08h, 80h,0E7h, 70h, 23h
		db	 00h,0DFh,0E0h, 12h, 00h,0AAh
		db	 0Fh, 12h, 00h,0AAh,0CFh, 00h
		db	 02h,0AAh, 81h, 12h, 00h,0AAh
		db	0B3h, 00h, 08h,0AAh,0A7h, 12h
		db	 00h,0AAh,0AEh, 12h, 00h,0AAh
		db	0BEh, 12h, 00h,0EAh,0BEh, 00h
		db	 08h,0BCh,0F8h, 8Ch, 00h, 7Ch
		db	0FAh, 00h, 23h,0E8h, 1Bh, 30h
		db	 02h,0F0h, 3Eh, 12h, 00h,0A0h
		db	 3Ah, 12h, 00h, 80h, 3Ah,0C0h
		db	 02h,0C0h, 2Ah,0C0h, 02h,0C0h
		db	 2Ah, 12h, 13h, 03h, 12h, 01h
		db	 3Ah, 00h, 05h, 00h,0FBh, 00h
		db	 04h, 12h, 00h, 3Eh, 80h, 08h
		db	 00h, 06h,0A0h, 00h, 03h, 0Fh
		db	0A8h, 00h, 2Bh, 03h,0D4h, 0Eh
		db	0BBh, 01h, 44h,0B8h, 8Ah, 47h
		db	 75h, 80h, 02h, 7Fh,0FDh, 22h
		db	 00h,0DDh,0FFh, 00h,0BAh, 00h
		db	 45h, 02h, 20h, 01h,0DBh, 02h
		db	 00h, 01h,0EEh, 00h, 03h, 83h
		db	0B8h, 00h, 0Fh,0ABh,0E0h, 00h
		db	 0Eh,0ABh,0A0h, 08h, 3Eh,0A7h
		db	 80h, 00h, 38h,0AFh, 80h, 12h
		db	 0Fh, 03h, 12h, 01h, 3Ah, 00h
		db	 05h, 00h,0A0h, 00h, 5Fh, 03h
		db	 80h, 00h, 7Fh, 12h, 0Ah, 0Eh
		db	 82h, 01h, 7Dh,0A0h, 00h, 5Fh
		db	0FFh, 12h, 00h, 46h, 00h, 12h
		db	 00h,0EBh,0FFh, 12h, 00h,0FEh
		db	0BEh, 0Eh, 88h, 01h, 77h,0EEh
		db	 00h, 11h,0FFh,0F8h,0A2h, 07h
		db	 5Dh,0BCh, 88h, 43h, 77h,0F3h
		db	0EAh, 0Ch, 15h, 0Ch, 88h,0F3h
		db	 77h, 22h, 20h,0DDh,0DFh, 12h
		db	 00h, 46h, 00h, 12h, 07h, 80h
		db	 00h, 40h, 82h, 00h, 7Dh,0E0h
		db	 02h, 08h,0FDh,0E4h, 00h, 80h
		db	0FFh,0BFh, 08h,0C0h,0E7h,0FFh
		db	 12h, 00h,0FEh,0AEh, 12h, 18h
		db	0F0h, 12h, 01h,0FFh, 00h, 03h
		db	 00h,0BFh,0ABh, 22h, 00h,0DEh
		db	 2Ah, 80h, 00h, 7Ah, 2Ah, 03h
		db	 00h,0FBh, 2Ah, 82h, 00h, 7Eh
		db	 2Ah, 03h, 80h,0FBh, 8Ah, 00h
		db	0C0h,0BAh,0CAh, 20h, 00h, 9Ah
		db	 8Ah, 12h, 00h,0BFh,0C0h, 12h
		db	 00h,0AAh,0F0h, 12h, 00h,0AAh
		db	0ACh, 12h, 00h,0AAh,0ABh, 12h
		db	 00h,0ABh,0AAh, 12h, 00h, 19h
		db	 00h, 12h, 00h, 19h, 00h, 12h
		db	 00h, 19h, 00h, 12h, 00h,0BAh
		db	0A2h, 00h, 30h,0BEh,0B2h, 08h
		db	 20h,0A6h,0A2h, 39h, 00h,0A7h
		db	0A8h, 12h, 00h,0AFh,0A8h, 12h
		db	 00h,0AFh,0A8h, 08h, 00h,0E7h
		db	0A8h, 00h, 0Ch,0FFh,0ACh, 12h
		db	 00h,0AAh,0ABh, 12h, 00h, 19h
		db	 00h, 12h, 00h, 19h, 00h, 12h
		db	 00h, 19h, 00h, 12h, 00h, 19h
		db	 00h, 12h, 00h
data_14		db	0ABh			; Data table (indexed access)
		db	0AAh, 12h, 00h, 19h, 00h, 12h
		db	 00h, 19h, 00h
data_15		db	12h			; Data table (indexed access)
		db	 0Ah, 80h, 00h, 7Ch, 12h, 01h
		db	0FFh,0F0h, 12h, 00h, 3Fh,0FFh
data_16		db	0C0h
		db	 00h,0CBh,0BFh, 12h, 00h,0B2h
		db	0AEh, 0Ch, 00h,0ACh,0ABh, 0Ch
		db	 00h,0EFh, 2Ah, 12h, 00h,0EBh
		db	 2Ah, 83h, 00h, 6Bh, 2Ah, 82h
		db	 00h, 7Ah, 2Ah, 03h, 80h,0BBh
		db	 8Ah, 00h,0C0h,0BBh,0CAh, 20h
		db	 00h, 9Ah, 8Ah, 12h
		db	 0Ah, 2Dh
data_17		db	0			; Data table (indexed access)
		db	 0Dh,0EDh,0A0h, 00h, 5Fh,0E8h
		db	 00h, 03h,0AAh,0EBh, 12h, 00h
		db	0FEh,0BEh, 12h, 00h,0BFh,0AEh
		db	 00h, 08h,0FFh,0A7h, 12h, 00h
		db	0FEh,0EBh, 00h, 02h,0BBh,0A9h
		db	 12h, 00h,0EEh,0AAh, 12h, 00h
		db	0FFh,0EAh, 80h, 00h, 7Fh,0AAh
		db	 12h, 00h,0FAh,0BAh, 12h, 00h
		db	 19h, 00h, 12h, 0Eh, 08h, 00h
		db	 04h, 12h, 01h, 3Eh, 00h, 20h
		db	 00h, 1Eh, 00h, 20h, 00h, 1Ah
		db	 00h, 20h, 00h, 1Ah, 80h, 0Ch
		db	 00h, 0Eh, 80h, 08h, 00h, 0Ah
		db	0ACh, 12h, 00h, 0Fh,0AAh, 02h
		db	0C0h, 02h,0EAh, 03h, 80h, 03h
		db	0BAh, 00h, 8Fh, 00h,0BFh, 00h
		db	 0Eh, 00h, 0Eh, 12h, 0Ch,0B0h
		db	 12h, 01h,0AAh,0F0h, 12h, 00h
		db	 19h, 00h, 80h, 00h,0BAh,0AAh
		db	 20h, 00h, 2Fh,0EAh,0A3h, 30h
		db	0AFh, 3Fh, 03h,0A8h, 03h,0ABh
		db	 12h, 01h, 03h, 12h, 1Fh, 08h
		db	 00h, 07h, 00h, 80h, 00h, 7Fh
		db	 0Ah, 00h, 05h,0EAh, 20h, 22h
		db	 1Eh,0AAh, 00h, 80h, 0Ah, 80h
		db	 12h, 03h, 80h, 00h, 7Fh, 20h
		db	 00h, 1Fh,0FFh, 12h, 00h,0FFh
		db	0AAh, 12h, 00h, 19h, 00h, 0Bh
		db	0A0h,0ABh,0AAh, 80h, 00h,0A0h
		db	 12h, 05h, 19h, 00h, 3Ch, 00h
		db	0FFh,0AAh,0E2h, 00h,0E2h,0FAh
		db	 0Ah, 0Bh, 0Ah,0FBh, 00h, 3Ch
		db	 00h,0FCh, 00h, 0Ah, 00h, 0Ah
		db	 12h, 08h,0ACh, 12h, 00h, 0Ah
		db	0AAh, 05h, 12h, 00h,0AAh,0AFh
		db	 12h, 00h,0EAh,0AAh, 80h, 00h
		db	 19h, 00h, 80h, 00h,0BAh,0AAh
		db	 12h, 00h, 0Eh,0AAh, 0Eh, 00h
		db	0FEh,0AAh

locloop_4:
		adc	al,[bx+si]
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		call	word ptr [bp+si]	;*
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
;*		jmp	far ptr loc_2		;*
		db	0EAh
		dw	12h, 19h		;  Fixup - byte match
		db	 00h, 0Ch,0AAh,0AEh,0E8h, 2Bh
		db	0EAh,0ABh, 80h, 00h, 80h, 12h
		db	 07h, 0Ch,0C0h,0ECh,0EAh, 02h
		db	 20h,0AAh, 2Ah, 00h,0A0h,0AAh
		db	0AEh,0A0h,0C0h,0AAh,0FEh, 80h
		db	 00h, 80h, 3Fh, 00h, 3Ch, 00h
		db	 3Fh, 00h, 0Fh, 00h
loc_5:
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bp+si],al
		add	[bp+si],al
		adc	al,data_3
		pop	es
		loopnz	locloop_4		; Loop if zf=0, cx>0

		add	[bx],bh
		mov	sp,0E080h
		jp	loc_5			; Jump if parity=1
		add	[si],al
;*		jmp	far ptr loc_8		;*
		db	0EAh
		dw	0C05h, 0AC00h		;  Fixup - byte match
		db	 01h, 20h, 00h,0A0h, 12h, 00h
		db	 80h, 00h, 7Eh, 12h, 01h,0FAh
		db	 00h, 03h, 00h,0FBh, 00h, 02h
		db	 00h,0EAh, 12h, 01h,0FAh, 12h
		db	 01h,0EAh, 00h, 22h, 00h,0DDh
		db	 0Eh, 80h, 01h, 7Ah, 12h, 00h
		db	0A0h, 00h,0C0h, 00h,0C0h, 00h
		db	 80h, 00h, 80h, 00h, 82h, 25h
		db	 00h, 3Eh, 88h,0E0h, 80h, 0Fh
		db	 23h,0E0h, 80h, 0Ah, 23h,0A0h
		db	 80h, 0Ah, 22h,0E0h,0C0h, 0Ah
		db	0EAh, 00h, 15h,0EAh, 88h, 00h
		db	 77h,0AAh, 12h, 00h,0FAh,0AAh
		db	 4Fh, 00h,0EEh,0AEh, 61h, 00h
		db	 58h, 00h, 2Eh, 0Ah,0A1h,0F6h
		db	 30h, 00h, 8Ah,0BFh, 27h, 00h
		db	 98h, 1Fh, 23h, 25h, 00h, 2Ah
		db	 22h, 25h, 00h, 2Ah, 08h, 00h
		db	0B0h,0AAh, 12h, 00h,0AEh,0AAh
		db	 80h, 0Eh,0AAh,0A1h, 80h, 3Ah
		db	0AAh, 85h,0A2h,0A0h, 5Dh, 5Eh
		db	 00h, 08h,0FFh,0B7h, 12h, 00h
		db	0B8h, 3Bh, 00h, 20h,0B8h, 1Ah
		db	 00h, 80h,0ABh, 6Ah, 12h, 00h
		db	 8Ah,0A2h, 12h, 00h,0A0h, 12h
		db	 01h,0EAh,0AAh, 80h, 00h,0BAh
		db	0AAh,0A0h,0BAh,0AEh,0BAh, 12h
		db	 0Eh, 20h, 00h, 10h, 00h, 80h
		db	 00h, 70h, 00h, 80h, 00h, 70h
		db	 12h, 01h,0F8h, 00h, 80h, 00h
		db	 78h, 00h,0E0h, 00h,0EAh, 00h
		db	 20h, 00h, 1Eh,0BCh, 0Ch, 00h
		db	 3Fh,0AAh, 0Ah, 00h, 0Ah,0EAh
		db	 00h, 38h, 00h,0FAh, 22h, 02h
		db	 1Dh,0AAh, 82h, 8Ah, 7Ah,0AAh
		db	 12h, 07h, 02h, 00h, 01h, 12h
		db	 00h, 74h, 00h, 12h, 00h, 19h
		db	 00h, 12h, 00h, 19h, 00h, 0Eh
		db	 00h,0FEh,0AAh, 3Ah,0C0h, 3Ah
		db	0FAh, 12h, 00h, 28h, 12h, 1Ch
		db	 03h, 00h,0ABh, 12h, 1Fh, 28h
		db	 00h, 17h, 20h, 00h,0DFh,0FEh
		db	 12h, 00h,0EAh,0AAh, 12h, 00h
		db	 19h, 00h, 12h, 00h,0AFh,0FFh
		db	 12h, 00h, 19h, 00h, 12h, 00h
		db	 19h, 00h, 12h, 02h, 0Ah, 00h
		db	0F5h, 12h, 00h, 0Eh,0AFh,0F1h
		db	 12h, 00h,0AAh,0FFh, 12h, 00h
		db	 19h, 00h, 12h, 00h, 19h, 00h
		db	 12h, 00h,0FFh,0EAh, 12h, 00h
		db	0AAh,0FFh,0B0h, 2Ch,0BAh,0AEh
		db	0A8h,0BAh,0AAh,0BAh, 12h, 18h
		db	0AAh,0ABh, 12h, 00h, 19h, 00h
		db	 2Fh, 80h, 2Fh,0AAh, 02h,0A0h
		db	 02h,0AAh, 12h, 01h, 0Ah, 12h
		db	 12h, 08h, 00h, 07h,0E0h,0C0h
		db	 00h, 3Fh,0AEh, 80h,0E0h, 7Ah
		db	0EAh, 00h, 02h,0EAh, 02h, 0Ch
		db	 00h,0ACh, 00h, 20h, 00h,0A0h
		db	 12h, 00h, 80h, 00h, 7Eh, 12h
		db	 01h,0FAh, 00h, 03h, 00h,0FBh
		db	 00h, 02h, 00h,0EAh, 12h, 01h
		db	0FAh, 12h, 01h,0EAh, 12h, 01h
		db	0FBh, 12h, 01h,0FAh, 12h, 01h
		db	 2Eh, 12h, 01h, 3Ah,0C0h, 00h
		db	 30h, 3Ah, 2Eh, 08h,0D1h,0F7h
		db	 12h, 00h,0AAh,0AFh, 0Eh, 08h
		db	0A1h,0F6h, 30h, 00h, 8Ah,0BFh
		db	 27h, 00h, 98h, 1Fh, 23h, 25h
		db	 00h, 2Ah, 22h, 25h, 00h, 2Ah
		db	 08h, 00h,0B0h,0AAh, 12h, 00h
		db	0AEh,0AAh, 00h, 0Eh,0EAh,0A1h
		db	 00h, 3Ah,0AAh, 85h,0A2h,0A0h
		db	 5Dh, 5Eh, 00h, 08h,0FFh,0B7h
		db	 12h, 00h,0B8h, 3Bh, 00h, 20h
		db	 38h, 1Ah, 00h, 80h, 2Bh, 6Ah
		db	 12h, 00h, 8Ah,0A2h, 12h, 00h
		db	0A0h, 12h, 01h, 28h,0AAh, 0Bh

_365UNKN	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		or	byte ptr [bp+di],0AAh
		add	ss:data_29e[bp+si],bh
		adc	dl,[bx+si]
		adc	byte ptr [bp+si],0
		add	sp,ax
		adc	al,[bx+si]
		cmp	dh,data_2[bx+si]
		sti				; Enable interrupts
		add	[si],al
		adc	dl,[bp+di]
		or	ax,[bx+si]
		add	al,2
		loopnz	$+3			; Loop if zf=0, cx>0

		pop	ds
		sub	[bp+si],al
		pop	ss
		db	0FEh, 12h, 0Eh, 02h,0BBh, 01h
		db	 44h,0EEh, 00h, 11h,0FFh, 12h
		db	 00h,0FFh,0FAh, 0Eh, 28h,0FEh
		db	0AAh, 82h, 08h, 7Eh,0A8h, 0Ch
		db	 00h, 2Ch, 12h, 23h, 80h, 00h
		db	 40h, 12h, 01h,0FCh, 00h,0C0h
		db	 00h, 46h, 00h, 2Eh, 00h, 1Eh
		db	0FBh, 00h, 3Ah, 00h,0BAh, 12h
		db	 0Dh, 03h, 00h, 80h, 03h, 7Fh
		db	 12h, 00h,0FFh,0BBh, 00h, 80h
		db	0BAh,0AAh, 0Fh,0A0h,0AFh,0AAh
		db	 12h, 0Eh, 02h, 00h,0FDh, 12h
		db	 00h, 02h,0AAh,0A9h, 12h, 00h
		db	 19h, 00h,0E0h, 00h,0EAh,0AAh
		db	 12h, 18h,0BCh, 12h, 00h, 80h
		db	0ABh, 40h, 2Ah, 00h, 2Ah,0AAh
		db	 00h, 0Fh, 00h, 3Fh, 00h, 02h
		db	 00h, 02h, 12h, 14h,0AAh,0ACh
		db	 80h, 00h, 19h, 00h,0A0h, 00h
		db	0AEh,0AAh, 00h,0C0h, 0Fh,0EAh
		db	 00h,0E0h, 00h,0EAh, 00h, 28h
		db	 00h, 2Ah, 00h, 38h, 00h, 3Ah
		db	 00h, 80h, 00h, 7Fh, 12h, 03h
		db	 22h, 00h, 1Dh, 02h, 80h, 01h
		db	 6Eh, 88h, 00h, 77h,0BAh, 12h
		db	 00h, 19h, 00h, 0Eh, 03h,0AEh
		db	0ABh,0BAh, 80h,0BAh, 80h, 12h
		db	 02h,0A0h, 00h, 5Fh,0EEh, 12h
		db	 00h,0FBh,0BAh, 12h, 00h,0EAh
		db	0AAh, 00h, 08h, 19h, 00h,0E8h
		db	 3Ah,0EAh,0BAh,0A0h, 00h,0A0h
		db	 12h, 0Ah, 2Eh, 12h, 00h, 80h
		db	 3Ah, 12h, 00h,0B0h, 0Ah, 12h
		db	 00h,0ACh, 03h, 12h, 00h,0AAh
		db	 00h, 0Eh, 08h,0A1h,0F6h, 30h
		db	 00h, 8Ah,0BFh, 27h, 00h, 98h
		db	 1Fh, 12h, 00h,0B8h, 3Bh, 00h
		db	 20h, 38h, 1Ah, 00h, 80h, 2Bh
		db	 6Ah, 12h, 00h, 8Ah,0A2h,0C0h
		db	 00h,0E0h, 00h,0C0h, 00h,0EAh
		db	0AAh, 03h,0C0h, 0Bh,0EAh, 00h
		db	0B0h, 00h,0BAh, 12h, 10h, 80h
		db	 12h, 01h,0E0h, 12h, 00h, 02h
		db	0B0h, 01h, 00h, 3Eh, 00h, 01h
		db	 12h, 0Fh, 20h, 00h, 10h, 00h
		db	 80h, 00h, 70h, 12h, 01h,0FCh
		db	 00h, 30h, 00h, 3Ch, 00h, 20h
		db	 00h, 1Fh, 00h, 0Ch, 00h, 0Eh
		db	 00h, 02h, 00h, 01h, 12h, 18h
		db	0F0h, 12h, 01h,0AFh, 00h,0C0h
		db	 00h,0EAh,0BCh, 20h, 00h, 2Eh
		db	0ABh, 02h,0C0h, 02h,0EAh, 00h
		db	0A8h, 00h,0AAh, 12h, 01h, 0Ah
		db	 12h, 0Dh, 03h, 12h, 01h, 0Eh
		db	 12h, 01h,0FAh, 80h, 00h, 7Fh
		db	0AAh, 02h, 88h,0EAh,0A8h, 2Ah
		db	 00h, 2Ah,0AAh, 00h, 0Fh, 00h
		db	 3Fh, 00h, 02h, 00h, 02h, 12h
		db	 0Dh, 0Fh, 12h, 01h,0FEh, 12h
		db	 00h,0AAh,0ACh, 80h, 02h,0AAh
		db	0A9h,0A0h, 00h, 19h, 00h, 12h
		db	 00h, 0Ah,0AAh, 02h, 00h, 01h
		db	0FFh, 20h, 00h, 1Fh,0EAh, 12h
		db	 00h,0FAh,0AAh, 12h, 00h, 19h
		db	 00h, 12h, 00h, 03h,0EAh, 12h
		db	 00h, 0Eh,0AAh, 00h, 0Fh,0FAh
		db	0AFh, 00h, 28h,0AAh,0A8h, 12h
		db	 00h,0AAh, 80h, 0Eh, 00h,0AEh
		db	 00h, 30h, 00h,0B0h, 12h, 05h
		db	 19h, 00h, 02h,0E0h,0AAh,0EAh
		db	 80h, 00h,0A0h, 02h, 12h, 15h
		db	 2Eh, 12h, 00h,0C0h, 3Ah, 12h
		db	 00h,0BCh, 0Ah, 12h, 00h,0ABh
		db	 03h, 12h, 00h,0AAh,0C0h, 0Eh
		db	 08h,0B1h,0F6h, 30h, 00h, 8Ah
		db	0BFh, 27h, 00h, 98h, 1Fh, 12h
		db	 00h, 38h, 3Bh, 00h, 20h, 38h
		db	 1Ah, 00h, 80h, 2Bh, 6Ah, 80h
		db	 00h, 8Ah,0A2h,0A0h, 00h,0A0h
		db	 00h, 08h, 00h, 0Ah,0AAh, 03h
		db	0C0h, 03h,0EAh, 00h,0B0h, 00h
		db	0BAh, 08h, 00h, 04h, 00h, 08h
		db	 00h, 07h, 00h, 08h, 00h, 07h
		db	 00h, 03h, 00h, 03h, 80h, 03h
		db	 00h, 03h,0F8h, 00h, 82h, 00h
		db	 7Dh, 00h, 30h, 00h, 3Fh, 00h
		db	 0Ah, 00h, 09h, 03h,0A0h, 00h
		db	 5Fh, 0Eh, 00h, 01h,0FEh, 28h
		db	 38h, 17h,0FAh, 80h,0E0h, 7Eh
		db	0E0h, 12h, 00h,0FAh, 00h, 08h
		db	 00h,0F8h, 00h, 20h, 00h,0E0h
		db	 12h, 01h,0AAh,0C0h, 00h, 03h
		db	 12h, 01h, 0Ah, 00h, 06h, 12h
		db	 01h, 3Eh, 12h, 01h, 3Ch, 12h
		db	 0Eh, 80h, 00h,0AAh,0ABh, 0Eh
		db	 00h, 3Eh,0AAh, 03h, 82h, 03h
		db	0AAh, 00h, 0Bh, 00h, 0Bh, 12h
		db	 22h, 0Ah, 20h, 05h,0DFh, 80h
		db	 00h, 7Fh,0FFh, 12h, 00h,0FEh
		db	0EEh, 12h, 12h, 80h, 00h, 40h
		db	 12h, 01h,0FFh, 12h, 01h,0EEh
		db	0B0h, 0Eh, 80h,0BEh,0AAh, 38h
		db	 03h,0B8h, 03h, 12h, 16h,0C0h
		db	 00h,0EAh,0ABh,0A0h, 00h, 19h
		db	 00h, 38h, 00h, 3Ah,0AAh, 12h
		db	 00h, 03h,0BAh, 00h,0B0h, 00h
		db	0BAh, 00h, 28h, 00h, 2Bh, 00h
		db	0ACh, 00h, 6Eh, 08h, 0Ah, 07h
		db	0FAh, 00h, 02h,0C0h, 01h, 12h
		db	 00h,0BEh,0FFh,0C0h, 00h,0EAh
		db	0AAh,0A0h, 2Ch,0AAh,0AEh, 00h
		db	0BAh, 0Eh,0BAh, 12h, 0Bh, 08h
		db	0FFh,0ABh, 12h, 00h,0EAh,0ABh
		db	 00h,0C0h,0AAh,0EAh, 0Eh,0A0h
		db	0AEh,0A0h, 08h, 00h,0A8h, 12h
		db	 0Eh, 2Eh, 00h, 2Ah,0C0h, 15h
		db	 02h,0B8h,0BDh, 47h, 00h, 22h
		db	0ABh, 99h, 12h, 00h,0AAh,0EBh
		db	 0Eh, 08h,0A1h,0F6h, 30h, 00h
		db	 8Ah,0BFh, 27h, 00h, 98h, 1Fh
		db	 12h, 16h, 08h, 80h, 07h, 7Ch
		db	 80h, 00h, 7Fh,0FFh, 00h, 0Ah
		db	 00h, 05h, 00h, 38h, 00h, 07h
		db	 00h,0A0h, 00h, 5Eh, 02h, 0Ah
		db	 01h,0FAh, 00h, 88h, 03h, 68h
		db	 08h, 00h, 07h,0A0h, 00h, 80h
		db	 0Eh, 80h, 0Ah, 00h, 06h, 12h
		db	 00h, 80h,0FAh,0AAh, 0Ah,0A0h
		db	 19h, 00h, 08h, 00h,0A8h, 0Ah
		db	 12h, 1Ah, 20h, 00h, 10h, 12h
		db	 01h, 3Ch, 00h, 80h, 00h, 7Eh
		db	 80h, 20h, 00h, 2Fh,0A8h, 08h
		db	 00h, 0Bh,0FFh, 00h,0E3h, 02h
		db	0EFh, 12h, 13h, 02h, 00h, 3Dh
		db	 80h, 20h, 7Fh,0DFh,0A3h,0A0h
		db	0AFh,0AEh, 12h, 1Ah, 20h, 00h
		db	0DCh, 12h, 00h, 80h,0BFh, 70h
		db	 12h, 00h,0AAh,0FFh,0A8h, 00h
		db	0AAh,0ABh,0AAh, 00h, 19h, 00h
		db	 0Ah, 00h, 0Ah,0AAh, 00h, 2Eh
		db	 00h,0EEh, 00h, 08h, 00h, 08h
		db	 00h, 02h, 00h, 02h, 12h, 08h
		db	0C0h, 12h, 01h,0BCh, 12h, 01h
		db	0ABh, 12h, 01h,0AAh, 4Dh, 00h
		db	 00h,0EAh,0B0h, 12h, 00h,0AAh
		db	0ACh, 0Ch, 00h,0FEh,0ABh, 33h
		db	 00h, 33h,0AAh, 0Eh, 80h, 0Eh
		db	0AAh, 02h, 00h, 02h,0BAh, 00h
		db	 30h, 00h,0BAh, 00h, 28h, 00h
		db	 2Bh, 00h, 2Ch, 00h, 2Eh, 00h
		db	 0Ah, 00h, 0Ah, 12h, 0Fh, 22h
		db	 00h, 1Dh, 88h, 00h, 77h,0FFh
		db	 12h, 00h,0FFh,0AAh,0EEh, 0Bh
		db	0EEh,0ABh, 00h, 08h, 00h, 0Bh
		db	 12h, 01h, 0Fh, 12h, 01h, 3Fh
		db	 02h, 00h, 0Dh,0FFh, 80h, 00h
		db	 7Fh,0FAh, 12h, 00h,0FAh,0AAh
		db	 12h, 00h
loc_6:
		sbb	[bx+si],ax
		mov	al,byte ptr ds:[0AABBh]
		mov	bx,112h
		adc	al,cs:[bx+si]
		db	0C0h, 2Eh, 00h, 38h,0BCh, 07h
		db	 00h, 22h,0ABh, 99h, 12h, 00h
		db	0AAh,0EBh, 0Eh, 08h,0A1h,0F6h
		db	 30h, 00h, 8Ah,0BFh, 27h, 00h
		db	 98h, 1Fh, 12h, 00h, 38h, 3Bh
		db	 00h, 20h, 38h, 1Ah, 00h, 80h
		db	 2Bh, 6Ah, 80h, 00h, 8Ah,0A2h
		db	0C0h, 00h,0E0h, 00h, 20h, 00h
		db	 19h, 00h, 03h,0C0h,0ABh,0EAh
		db	 80h,0B0h,0A0h,0BAh, 12h, 06h
		db	 20h, 00h, 10h, 00h, 80h, 00h
		db	 7Ch, 12h, 00h, 20h,0FBh,0D0h
		db	 2Ch, 00h, 2Eh,0BFh, 08h, 00h
		db	 0Bh,0AAh, 00h,0E0h, 00h,0EAh
		db	 12h, 14h,0E0h, 12h, 01h,0AEh
		db	0B8h, 12h, 00h,0AAh,0ABh,0E0h
		db	 00h,0EAh,0AAh, 38h,0F8h, 3Ah
		db	0FAh, 00h,0AAh, 00h

locloop_7:
		stosb				; Store al to es:[di]
		add	[bp+si],al
		add	[bp+si],al
		adc	ah,[bp+si]
		mov	[bx+si],al
		jbe	loc_6			; Jump if below or =
		and	[bx+si],al
		out	dx,ax			; port 20E5h ??I/O Non-standard
		dec	word ptr [bx+si]
		jcxz	$+0Ch			; Jump if cx=0
		out	dx,ax			; port 20E5h ??I/O Non-standard
		adc	dl,[bp+di]
		mov	ss:data_1e[bp+si],ch
		add	[bp],al
		mov	word ptr ds:[0ABA0h],ax
		stosb				; Store al to es:[di]
		adc	al,[bx+si]
		mov	ax,112h
		stosb				; Store al to es:[di]
		db	0C0h, 12h, 00h,0AAh,0A0h, 12h
		db	 00h,0EAh,0ACh, 12h, 00h,0FFh
		db	0AAh, 3Ch, 00h,0FFh,0EBh, 32h
		db	 00h, 32h,0FAh, 0Eh, 00h, 0Eh
		db	0FAh, 12h, 18h,0C0h, 12h, 01h
		db	0C0h
data_18		db	12h
		db	 01h,0B0h, 12h, 01h,0B0h, 12h
		db	 01h,0B0h, 03h, 00h, 08h,0ACh
		db	 06h, 12h, 00h,0ACh, 3Bh, 12h
		db	 00h,0ABh,0AEh, 12h, 00h, 36h
		db	 00h, 12h, 00h,0EAh,0BEh, 00h
		db	 03h, 00h, 03h, 00h, 0Bh, 00h
		db	 07h, 00h, 80h, 00h, 7Fh, 0Eh
		db	 00h, 01h,0FFh,0A0h, 00h, 5Fh
		db	0FEh, 12h, 00h,0FFh,0AAh, 12h
		db	 00h, 19h, 00h,0B8h, 2Eh,0BAh
		db	0AEh, 38h, 00h, 07h,0AAh,0A0h
		db	 00h, 5Eh,0AAh, 12h, 00h,0FAh
		db	0AAh, 12h, 00h, 19h, 00h, 4Fh
		db	 00h, 5Bh, 00h, 2Eh, 0Ah,0A1h
		db	0F6h, 30h, 00h, 8Ah,0BFh, 27h
		db	 00h, 98h, 1Fh, 12h, 00h,0B0h
		db	 12h, 01h,0B0h, 12h, 01h,0B0h
		db	 12h, 01h,0ACh, 12h, 01h,0ACh
		db	 12h, 01h,0ABh, 12h, 01h,0EAh
		db	0C0h, 12h, 00h,0EAh,0BCh, 00h
		db	 03h, 00h, 03h, 00h, 03h, 00h
		db	 03h, 12h, 16h,0E0h, 00h,0EEh
		db	0AFh, 28h, 00h, 2Bh,0AAh,0CAh
		db	 00h,0CAh,0AAh, 38h, 00h, 3Bh
		db	0EAh, 12h, 00h, 0Fh,0FAh, 02h
		db	 2Ch, 01h,0EEh, 00h, 0Ah, 00h
		db	 3Ah, 12h, 03h, 80h, 00h, 7Eh
		db	 12h, 01h,0FAh, 00h, 03h, 00h
		db	0FBh, 00h, 02h, 00h,0EAh, 00h
		db	0E8h, 00h, 16h, 03h,0BAh, 00h
		db	 45h, 02h,0EEh, 01h, 21h, 02h
		db	0EEh, 01h, 21h, 02h,0EEh, 01h
		db	 21h, 02h,0BAh, 01h, 45h, 00h
		db	0ABh, 00h, 57h, 00h, 0Ch, 00h
		db	 0Ch, 00h, 02h, 00h, 02h, 0Eh
		db	 08h, 01h,0F4h, 30h, 00h, 0Ah
		db	0BFh, 27h, 00h, 18h, 1Fh, 12h
		db	 00h,0ACh, 12h, 01h,0AAh, 12h
		db	 01h,0AAh,0A0h, 12h, 00h,0EAh
		db	0AAh, 80h, 00h, 19h, 00h, 80h
		db	 00h,0BAh,0AAh, 12h, 00h, 0Eh
		db	0AAh, 0Eh, 00h, 0Eh,0AAh, 0Ch
		db	0C0h, 0Ch,0EAh, 02h, 20h, 02h
		db	 2Ah, 00h,0A0h, 00h,0AEh, 00h
		db	0C0h, 00h,0FEh, 12h, 01h, 3Fh
		db	 00h, 3Ch, 00h, 3Fh, 00h, 0Fh
		db	 00h, 0Fh, 00h, 02h, 00h, 02h
		db	 00h, 80h, 00h, 7Eh, 12h, 01h
		db	0FAh, 00h, 03h, 00h,0FBh, 00h
		db	 02h, 00h,0EAh, 12h, 01h,0FAh
		db	 12h, 01h,0EAh, 00h,0E8h, 00h
		db	 16h, 03h,0BAh, 00h, 45h, 02h
		db	0EEh, 01h, 21h, 02h,0EEh, 01h
		db	 21h, 02h,0EEh, 01h, 21h, 02h
		db	0BAh, 01h, 45h, 00h,0AAh, 80h
		db	 56h, 0Eh, 0Ah, 81h,0F6h, 30h
		db	 00h, 8Ah,0BFh, 27h, 00h, 98h
		db	 1Fh, 80h, 00h, 78h, 00h,0E0h
		db	 00h,0EAh, 00h, 20h, 00h, 1Eh
		db	0BCh, 0Ch, 00h, 3Fh,0AAh, 0Ah
		db	 00h, 0Ah,0EAh, 00h, 38h, 00h
		db	0FAh, 00h, 02h, 00h, 02h, 12h
		db	 10h,0ACh, 12h, 01h, 19h, 00h
		db	 12h, 00h, 19h, 00h, 0Eh, 00h
		db	0FEh,0AAh, 3Ah,0C0h, 3Ah,0FAh
		db	 12h, 10h, 80h, 12h, 01h,0AFh
		db	0FFh, 12h, 00h, 19h, 00h, 12h
		db	 00h, 19h, 00h, 12h, 18h,0FFh
		db	0C0h, 12h, 00h,0AAh,0FFh, 12h
		db	 01h, 2Eh, 12h, 01h, 3Ah, 12h
		db	 01h, 3Ah, 00h, 3Ah, 00h, 05h
		db	 00h,0EEh, 00h, 11h, 0Eh, 0Bh
		db	 01h,0F4h, 30h, 00h, 0Ah,0BFh
		db	 27h, 00h, 18h, 1Fh, 12h, 1Bh
		db	 80h, 00h, 7Fh, 12h, 01h, 2Eh
		db	 12h, 01h, 3Ah, 12h, 01h, 0Ah
		db	 12h, 01h, 03h, 12h, 02h, 0Eh
		db	 08h, 01h,0F6h, 30h, 00h, 0Ah
		db	0BFh, 27h, 00h, 98h, 1Fh, 12h
		db	 19h, 0Fh, 12h, 01h,0FEh, 12h
		db	 0Eh, 02h, 00h, 01h,0FFh, 20h
		db	 00h, 1Fh,0EAh, 12h, 00h,0FAh
		db	0AAh, 12h, 00h, 19h, 00h, 12h
		db	 01h, 2Eh, 12h, 01h
data_19		db	3Ah			; Data table (indexed access)
		db	 12h, 01h, 0Ah, 12h, 01h, 03h
		db	 12h, 00h, 80h, 00h, 0Eh, 08h
		db	0B1h,0F6h, 30h, 00h, 8Ah,0BFh
data_20		db	27h			; Data table (indexed access)
		db	 00h, 98h, 1Fh,0C0h, 00h,0EAh
		db	0ABh,0A0h, 00h, 19h, 00h, 38h
		db	 00h, 3Ah,0AAh, 12h, 00h, 03h
		db	0BAh, 00h,0B0h, 00h,0BAh, 00h
		db	 28h, 00h, 2Bh, 00h
		db	2Ch
data_21		db	0			; Data table (indexed access)
		db	2Eh
data_22		db	0			; Data table (indexed access)
data_23		db	0Ah			; Data table (indexed access)
data_24		db	0			; Data table (indexed access)
		db	 0Ah, 00h
data_25		db	8			; Data table (indexed access)
		db	 00h, 0Bh, 12h, 01h, 03h, 12h
		db	 01h, 02h
data_26		dw	1512h			; Data table (indexed access)
		db	 2Eh, 00h,0E8h,0C0h, 16h, 03h
data_27		db	0BAh			; Data table (indexed access)
		db	0BCh, 45h, 00h,0EEh,0ABh, 21h
		db	 00h, 2Eh,0AAh,0E1h, 0Eh, 08h
		db	0A1h,0F6h, 30h, 00h, 8Ah,0BFh
		db	 27h, 00h, 98h, 1Fh, 00h, 08h
		db	 00h, 0Ah, 12h, 01h, 02h, 12h
		db	 01h, 02h, 12h, 13h,0A8h, 00h
		db	 56h, 02h,0BAh,0C1h, 45h, 02h
		db	0EEh,0BDh, 21h, 00h,0EEh
data_28		dw	21ABh			; Data table (indexed access)
		db	 00h, 2Eh,0AAh,0E1h, 0Eh, 08h
		db	0A1h,0F6h, 30h, 00h, 8Ah,0BFh
		db	 27h, 00h, 98h, 1Fh, 00h, 80h
		db	 00h, 7Eh, 12h, 01h,0FAh, 00h
		db	 03h, 00h,0FBh, 00h, 02h, 00h
		db	0EAh, 12h, 01h,0AAh, 12h, 01h
		db	0AAh, 12h, 01h,0BEh, 03h,0A0h
		db	 00h, 5Ah, 0Eh,0E8h, 01h, 16h
		db	 0Bh,0B8h, 04h, 86h, 0Bh,0B8h
		db	 04h, 86h, 0Bh,0B8h, 04h, 86h
		db	 0Ah,0EAh, 05h, 16h, 0Eh, 0Ah
		db	 01h,0F6h, 30h, 00h, 0Ah,0BFh
		db	 27h, 00h, 18h, 1Fh, 12h, 00h
		db	 38h, 3Bh, 00h, 20h, 38h, 1Ah
		db	 25h, 00h, 6Bh, 6Ah, 80h, 00h
		db	 4Ah,0A2h,0B0h, 00h, 40h, 00h
		db	0BFh, 80h, 40h, 6Ah,0AEh, 80h
		db	 51h, 6Ah, 2Ah,0BAh, 15h,0BAh
		db	 12h, 00h,0A0h, 38h,0C0h, 00h
		db	0C0h, 00h, 80h, 00h, 80h, 00h
		db	 82h, 20h, 81h,0DEh, 08h, 00h
		db	 87h,0FFh, 20h, 00h, 83h,0FAh
		db	 22h, 00h,0C0h,0FAh, 22h,0C0h
		db	 90h, 3Ah, 00h,0AEh, 00h, 51h
		db	 00h, 20h, 00h,0DBh, 02h, 00h
		db	 01h,0EEh, 00h, 02h, 83h,0B9h
		db	 00h, 08h,0ABh,0E7h, 00h, 08h
		db	0ABh,0A7h, 08h, 22h,0A7h, 9Ch
		db	 00h, 38h,0AFh, 80h, 12h, 00h
		db	 67h, 00h, 12h, 00h, 5Bh, 00h
		db	0AAh, 80h, 55h, 6Ah, 0Ah,0AAh
		db	0F5h, 55h, 00h, 88h,0FFh, 77h
		db	 3Eh,0A0h,0C0h, 5Fh, 3Ah, 20h
		db	 00h,0DAh, 30h, 00h, 0Fh,0EEh
		db	 20h, 38h, 9Fh, 83h, 00h, 20h
		db	0BEh, 9Fh, 80h, 20h, 7Eh,0DFh
		db	 80h, 08h, 7Ah,0F7h, 12h, 00h
		db	 66h, 00h, 00h, 08h,0FAh,0B7h
		db	 82h, 00h, 7Dh,0FFh, 28h, 00h
		db	 97h,0EAh, 12h, 00h,0FFh,0EEh
		db	 12h, 00h,0FFh,0FAh, 12h, 00h
		db	0FFh,0BAh, 12h, 00h,0FEh,0EAh
		db	 12h, 00h, 19h, 00h, 12h, 00h
		db	0FAh,0AAh, 00h, 02h,0FFh,0E9h
		db	 12h, 00h,0ABh,0FFh, 0Ah, 00h
		db	0B5h,0EAh, 12h, 00h,0BFh,0EAh
		db	 12h, 00h,0BCh,0AAh, 12h, 00h
		db	0BEh,0AAh, 00h, 0Eh,0FAh,0A1h
		db	 80h, 3Ah,0AAh, 85h,0A2h,0A0h
		db	 5Dh, 5Eh, 00h, 08h,0FFh,0B7h
		db	 12h, 00h,0A0h, 00h,0C0h, 00h
		db	0C0h, 00h, 80h, 00h, 80h, 00h
		db	 82h, 20h, 81h,0DEh, 08h, 00h
		db	 87h,0FFh, 20h, 00h, 83h,0FAh
		db	 22h, 00h,0C0h,0FAh, 22h,0C0h
		db	 90h, 3Ah, 12h, 19h, 03h, 00h
		db	 02h, 00h, 01h, 03h,0A0h, 00h
		db	 5Fh, 0Eh, 00h, 01h,0FEh, 28h
		db	 38h, 17h,0FAh, 00h,0E0h, 3Eh
		db	0E0h, 12h, 00h,0FAh, 00h, 08h
		db	 00h,0F8h, 00h, 20h, 00h,0E0h
		db	 12h, 01h, 80h, 12h, 17h, 0Dh
		db	 6Ch, 03h,0ACh, 3Ah,0B7h, 07h
		db	0C8h, 24h,0A8h, 3Fh,0BEh, 0Eh
		db	 8Ah, 0Eh, 8Ah, 12h, 22h, 02h
		db	 00h, 06h, 12h, 00h, 06h, 00h
		db	 07h, 20h, 08h, 20h, 3Dh, 03h
		db	0D4h, 00h, 7Eh, 0Eh,0BFh, 01h
		db	 62h, 12h, 0Eh, 80h, 10h,0ADh
		db	 31h, 01h, 04h, 49h, 04h, 20h
		db	 00h,0B0h, 00h, 8Fh, 80h,0E9h
		db	 80h, 26h, 51h, 29h,0FFh, 00h
		db	 26h, 03h,0EFh, 2Ah, 0Ah, 2Ah
		db	 3Fh, 80h,0B8h, 80h,0BCh, 00h
		db	 02h, 00h, 42h, 20h, 00h, 20h
		db	 12h, 07h,0EAh, 24h, 3Eh,0FEh
		db	 96h,0EAh,0DFh,0CAh, 28h, 00h
		db	0B8h, 00h, 01h, 80h,0A1h,0C0h
		db	 02h, 00h, 0Bh, 49h, 20h, 00h
		db	 20h, 12h, 07h,0C2h,0BAh,0E3h
		db	0DEh,0BBh,0A8h,0BBh,0A8h, 12h
		db	 16h, 6Ah,0A9h, 9Bh,0E9h,0A8h
		db	 20h,0A8h, 20h, 12h, 23h, 10h
		db	 12h, 03h, 02h, 00h, 89h, 00h
		db	 05h, 00h, 01h, 00h, 0Ah, 00h
		db	 3Fh, 00h, 08h, 12h, 0Ah, 80h
		db	 12h, 03h, 02h, 12h, 01h, 28h
		db	 00h,0B0h, 00h, 41h, 00h, 70h
		db	 00h,0CCh, 80h, 00h, 06h, 00h
		db	 09h, 00h,0C7h, 00h, 49h, 12h
		db	 01h, 13h, 12h, 01h, 84h, 12h
		db	 01h, 08h, 12h, 0Ah, 5Eh, 01h
		db	0FEh,0D7h, 4Bh, 28h,0CFh, 28h
		db	 12h, 00h,0A0h, 08h, 01h, 00h
		db	 09h, 12h, 01h, 80h, 12h, 01h
		db	 04h, 12h, 0Fh, 0Ch, 02h, 0Ch
		db	 02h, 12h, 0Ah, 08h, 80h, 08h
		db	0C8h, 12h, 01h, 03h, 12h, 02h
		db	0C0h, 00h,0C0h, 12h, 07h, 02h
		db	 00h, 02h, 12h, 01h, 80h, 00h
		db	 80h, 00h,0C0h, 00h, 02h, 0Ch
		db	 23h, 0Ch, 12h, 01h, 08h, 02h
		db	 00h, 2Dh, 00h, 00h, 20h, 00h
		db	 30h, 88h, 00h, 88h, 08h, 32h
		db	 00h, 32h, 12h, 03h, 30h, 08h
		db	 30h, 08h, 12h, 03h, 02h,0C0h
		db	 02h, 12h, 00h,0C0h, 00h, 02h
		db	 00h, 03h, 00h, 80h, 00h,0E0h
		db	 12h, 04h, 80h, 00h, 80h, 12h
		db	 03h, 0Ch, 00h, 0Ch, 12h, 01h
		db	 01h, 20h, 08h, 34h, 28h, 00h
		db	 80h, 00h, 80h, 02h, 50h, 02h
		db	 50h, 12h, 01h, 80h, 04h, 00h
		db	 04h, 00h, 28h, 00h, 28h, 12h
		db	 03h, 04h, 01h, 04h, 01h, 00h
		db	 10h, 00h, 10h, 48h, 00h, 48h
		db	 48h, 05h, 48h, 85h, 48h, 00h
		db	 20h, 04h, 24h, 12h, 03h, 10h
		db	 00h, 10h, 12h, 01h, 02h, 08h
		db	 00h, 48h, 12h, 03h, 20h, 00h
		db	 20h, 12h, 03h, 02h, 00h, 02h
		db	 80h, 01h, 00h, 11h, 12h, 02h
		db	 09h, 12h, 00h, 40h, 01h, 00h
		db	 10h, 00h, 10h, 12h, 03h, 08h
		db	 00h, 08h, 12h, 01h, 04h, 00h
		db	 40h, 00h, 60h, 02h, 10h, 02h
		db	 54h, 24h, 14h, 24h, 14h, 00h
		db	 02h, 00h, 02h
sub_1		endp


seg_a		ends



		end	start
