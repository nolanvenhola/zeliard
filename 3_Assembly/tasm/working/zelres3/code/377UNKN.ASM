
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_377UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_4e		equ	0F704h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_377UNKN	proc	far

start:
;*		jmpn	$+6			;*
		db	0E9h, 03h, 00h		;  Fixup - byte match
		db	 00h, 00h, 07h,0F7h, 00h, 01h
		db	 02h, 08h, 0Bh, 0Dh, 0Eh, 0Fh
		db	 10h, 11h, 12h, 13h,0F7h, 00h
		db	 09h, 0Dh,0F7h, 00h, 00h, 0Eh
		db	0F7h, 00h, 00h, 0Bh, 0Ch,0F7h
		db	 00h, 0Bh
data_1		db	4
		db	0F7h, 00h, 00h, 01h,0B0h, 04h
		db	0F7h, 00h, 00h, 01h, 20h, 04h
		db	0F7h, 00h, 01h, 40h,0F7h, 00h
		db	 01h, 05h, 40h, 01h,0F7h, 00h
		db	 00h, 02h,0A0h, 01h,0F7h, 00h
		db	 00h, 02h,0A0h, 02h,0F7h, 00h
		db	 01h, 80h,0F7h, 00h, 01h, 01h
		db	0F7h, 00h, 00h, 18h, 04h, 01h
		db	0B0h, 00h, 00h, 3Eh, 02h, 08h
		db	 20h, 00h, 00h, 7Fh, 81h, 16h
		db	0F7h, 00h, 00h, 1Fh,0E1h, 0Ch
		db	0C0h, 00h, 00h, 07h,0E8h, 01h
		db	 80h, 00h, 00h, 41h,0DAh, 00h
		db	 00h, 02h, 00h, 10h, 54h,0F7h
		db	 00h, 01h, 20h, 08h, 01h, 00h
		db	 00h,0FFh,0F7h, 00h, 01h
data_2		db	7
		db	 4Eh,0F7h, 00h, 00h,0B1h, 0Ah
		db	 60h, 00h, 00h, 05h, 9Fh, 3Ch
		db	 70h, 00h, 00h, 03h,0EFh, 70h
		db	0C9h, 00h, 00h, 0Fh,0C7h, 41h
		db	 83h, 00h, 00h, 3Fh, 87h, 4Eh
		db	 06h, 00h, 00h, 3Eh, 06h, 78h
		db	0F7h, 00h
data_3		dw	3800h, 0FF00h		; Data table (indexed access)
		db	0FFh,0F7h, 00h, 01h, 5Eh,0CEh
		db	 00h, 00h,0A1h, 31h, 80h, 20h
		db	 00h, 00h, 7Fh,0DFh,0E0h, 70h
		db	 00h, 00h, 1Fh,0EFh,0F8h,0E9h
		db	 00h, 00h, 87h,0E7h, 19h, 83h
		db	 00h, 00h, 07h, 87h, 0Dh, 06h
		db	 00h, 00h, 03h, 06h, 0Bh,0F7h
		db	 00h, 00h, 07h,0F7h, 00h, 04h
		db	0FFh,0FFh,0F7h, 00h, 01h,0F2h
		db	 3Ch, 00h, 00h, 0Dh,0C3h,0E8h
		db	 78h, 00h, 00h, 17h,0E7h,0F8h
		db	0E9h, 00h, 00h, 87h,0E7h, 19h
		db	 83h, 00h, 00h, 07h, 87h, 0Dh
		db	 06h, 00h, 00h, 03h, 06h, 0Bh
		db	0F7h, 00h, 00h, 07h, 00h,0F8h
		db	0F7h, 00h, 00h, 07h, 00h, 00h
		db	 80h, 00h, 00h,0FFh, 60h, 87h
		db	0F7h, 00h, 00h, 7Ch,0F0h,0CDh
		db	0E0h, 00h, 00h, 3Ch, 1Ch, 79h
		db	0D8h, 00h, 00h, 19h, 26h, 38h
		db	0F4h, 00h, 00h, 18h, 8Ah, 10h
		db	 3Ch, 00h, 00h, 10h, 32h, 00h
		db	 0Ch,0F7h, 00h, 00h, 0Eh,0F7h
		db	 00h, 01h, 28h, 02h,0F7h, 00h
		db	 01h,0D5h, 51h, 80h, 20h, 00h
		db	 00h, 6Bh,0CBh,0F0h, 70h, 00h
		db	 00h, 0Fh,0EFh,0F0h,0C9h, 00h
		db	 00h, 8Fh,0C7h, 79h, 86h, 00h
		db	 00h, 67h, 82h, 19h, 82h, 00h
		db	 00h, 17h, 82h, 0Eh,0F7h, 00h
		db	 00h, 02h,0F7h, 00h, 02h, 02h
		db	0F7h, 00h, 03h, 10h,0F7h, 00h
		db	 01h, 28h, 82h,0F7h, 00h, 01h
		db	 50h, 24h,0F7h, 00h, 01h, 84h
		db	 90h,0F7h, 00h, 01h, 02h, 10h
		db	0F7h, 00h, 01h, 01h,0F7h, 00h
		db	 04h, 02h, 80h, 00h, 00h, 01h
		db	 40h, 01h,0F7h, 00h, 00h, 02h
		db	 20h, 01h, 80h,0F7h, 00h, 00h
		db	 20h, 01h,0F7h, 00h, 01h, 40h
		db	 00h, 80h,0F7h, 00h, 02h, 80h
		db	0F7h, 00h, 00h, 40h,0F7h, 00h
		db	 02h, 80h,0F7h, 00h, 02h, 80h
		db	0F7h, 00h, 02h, 20h,0F7h, 00h
		db	 01h, 24h, 02h, 00h, 40h, 00h
		db	 00h, 15h, 04h, 00h, 40h, 00h
		db	 00h, 1Dh, 80h, 08h, 80h, 00h
		db	 00h, 06h, 08h, 0Ch, 80h, 00h
		db	 00h, 01h, 00h, 06h, 80h,0F7h
		db	 00h, 00h, 10h, 00h, 80h, 00h
		db	 00h, 05h, 10h, 20h,0F7h, 00h
		db	 00h, 40h, 00h, 30h,0F7h, 00h
		db	 00h, 48h, 00h, 3Ah,0F7h, 00h
		db	 00h, 46h, 00h, 1Dh, 01h, 00h
		db	 00h, 23h, 00h, 0Eh, 83h, 00h
		db	 00h, 31h,0C0h, 07h, 47h, 00h
		db	 00h, 18h,0E0h, 03h,0A7h, 00h
		db	 00h, 8Ch, 70h, 81h,0D3h, 00h
		db	 00h, 46h, 38h, 91h, 89h, 00h
		db	 00h, 70h, 66h,0CAh,0C9h, 00h
		db	 00h, 3Ah, 3Fh, 64h, 65h, 00h
		db	 00h, 1Ch, 1Eh,0B2h, 32h, 00h
		db	 00h, 8Eh, 0Eh, 19h, 09h, 00h
		db	 00h, 07h, 17h, 8Dh,0E4h, 00h
		db	 00h, 83h, 8Bh, 46h,0F6h, 00h
		db	 00h,0C1h,0C1h, 2Bh, 6Bh, 00h
		db	 00h,0E8h,0E8h, 00h, 03h, 00h
		db	 03h, 00h, 03h, 00h, 05h, 00h
		db	 0Dh, 00h, 0Dh, 00h, 04h, 00h
		db	 34h, 00h, 34h, 00h, 10h, 00h
		db	0D0h, 00h,0D3h, 00h, 40h, 03h
		db	 40h, 03h, 45h, 05h, 00h, 0Dh
		db	 00h, 0Dh, 17h, 14h, 00h, 34h
		db	 00h, 34h, 48h,0D0h, 00h,0D0h
		db	 00h,0D0h, 82h,0C0h, 00h,0C0h
		db	 00h,0C0h, 00h,0A0h, 00h,0B0h
		db	 00h,0B0h, 00h, 20h, 00h, 2Ch
		db	 00h, 2Ch, 00h, 08h, 00h, 0Bh
		db	 00h,0CBh, 00h, 02h, 00h, 02h
		db	0C0h,0A2h,0C0h, 00h,0A0h, 00h
		db	0B0h,0E8h,0B0h, 00h, 28h, 00h
		db	 2Ch, 12h, 2Ch, 00h, 0Bh, 00h
		db	 0Bh, 41h, 0Bh, 7Eh,0BFh, 00h
		db	 00h, 41h, 60h,0FAh,0A6h, 00h
		db	 00h, 05h, 47h,0EAh,0A2h, 00h
		db	 00h, 15h, 51h,0AAh,0A3h, 00h
		db	 00h, 55h, 53h,0EBh,0A2h, 00h
		db	 00h,0FDh, 51h,0EAh,0A2h, 00h
		db	 00h, 95h, 51h,0EBh,0A6h, 00h
		db	 00h, 1Dh, 47h,0AEh,0AAh, 00h
		db	 00h,0FBh,0DFh,0FFh,0FBh,0F7h
		db	 00h, 00h, 04h, 98h,0FEh, 00h
		db	 00h, 1Ch,0FCh, 8Ah, 62h, 00h
		db	 00h, 44h, 15h,0FEh, 6Ah, 00h
		db	 00h,0F0h, 75h, 8Eh, 2Ah, 00h
		db	 00h, 40h, 55h, 8Eh, 22h, 00h
		db	 00h, 40h, 55h, 9Ch,0FEh, 00h
		db	 00h, 18h,0FCh,0FEh,0AAh, 00h
		db	 00h,0ABh,0FFh,0F9h,0BEh,0F7h
		db	 00h, 00h, 41h, 69h,0A6h, 00h
		db	 00h, 54h, 45h, 2Eh, 88h, 00h
		db	 00h, 11h, 41h, 2Eh, 88h, 00h
		db	 00h, 11h, 14h, 2Ah, 9Fh, 00h
		db	 00h, 15h, 1Fh, 2Ah, 2Ah, 00h
		db	 00h, 11h, 14h, 7Eh, 2Ah, 00h
		db	 00h, 7Fh, 14h, 2Ah,0AAh, 00h
		db	 00h,0F7h,0FFh, 00h,0AFh,0F7h
		db	 00h, 00h, 50h, 8Fh,0BCh, 00h
		db	 00h, 4Fh,0C0h,0A2h, 38h, 00h
		db	 00h, 45h, 01h,0A2h, 32h, 00h
		db	 00h, 45h, 01h,0A2h, 23h, 00h
		db	 00h, 45h, 13h, 23h, 22h, 00h
		db	 00h, 44h, 05h, 0Fh,0A2h, 00h
		db	 00h, 4Fh,0C5h,0AFh,0AAh, 00h
		db	 00h,0FAh,0FFh,0ABh,0FEh, 00h
		db	 00h, 54h, 82h,0AAh,0BFh, 00h
		db	 00h,0D5h, 41h, 2Bh,0EFh, 00h
		db	 00h, 15h, 7Fh, 8Ah,0EAh, 00h
		db	 00h, 15h, 17h,0EBh,0AAh, 00h
		db	 00h,0F4h,0D7h, 8Bh,0AAh, 00h
		db	 00h, 44h, 5Fh, 8Eh,0ABh, 00h
		db	 00h, 41h, 5Fh,0AFh,0AEh, 00h
		db	 00h,0FDh,0FEh, 0Fh,0A0h, 00h
		db	 00h, 0Fh,0A0h, 3Fh,0ECh, 00h
		db	 00h, 30h,0ECh,0FFh,0EAh, 00h
		db	 00h,0C0h, 2Ah,0BFh,0AAh, 00h
		db	 00h,0B0h,0F7h,0AAh, 00h, 00h
		db	 00h,0AAh,0AAh,0ABh,0EAh, 00h
		db	 00h,0ABh,0EAh, 2Fh,0F8h, 00h
		db	 00h, 2Dh, 58h, 0Bh,0E0h, 00h
		db	 00h, 09h, 60h, 0Fh,0F0h, 00h
		db	 00h, 05h, 50h, 3Fh,0FCh, 00h
		db	 00h, 10h, 74h,0FFh,0FEh, 00h
		db	 00h, 40h, 1Eh,0FFh,0FAh, 00h
		db	 00h, 50h, 7Ah,0FFh,0FAh, 00h
		db	 00h, 75h,0FAh,0FFh,0EAh, 00h
		db	 00h,0FFh,0EAh, 2Eh,0A8h, 00h
		db	 00h, 2Eh,0A8h, 0Ah,0A0h, 00h
		db	 00h, 0Ah,0A0h

_377UNKN	endp

seg_a		ends



		end	start
