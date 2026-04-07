
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_380UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_3e		equ	0F4FFh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_380UNKN	proc	far

start:
		dec	si
		or	[bx+si],ax
		add	[bx+si],al
		push	es
		push	ss
		add	[bp+di],dh
		push	word ptr [di]
		inc	ax
		cmp	[bx+di],ax
		cmp	al,[bp+si]
		or	ds:[bp+di-80h],al
		inc	di
		and	[bx+di+3],cl
		dec	si
		add	al,5Ah			; 'Z'
		db	0DFh, 63h,0C0h, 65h, 10h, 66h
		db	 0Fh, 67h,0F0h, 68h,0BFh, 69h
		db	0FBh, 71h,0A0h, 72h,0FDh, 73h
		db	 88h, 76h, 90h, 79h, 7Fh, 7Ch
		db	0F7h, 83h, 11h, 8Bh, 44h, 8Ch
		db	 12h, 8Dh, 70h, 8Eh,0D0h, 91h
		db	 14h, 95h, 18h, 97h,0FEh, 99h
		db	 0Bh, 9Eh, 5Bh,0A3h,0DBh,0A5h
		db	0EFh,0A6h, 0Ah,0A9h, 0Ch,0B4h
		db	0A2h,0C2h,0BBh,0C5h, 05h,0C7h
		db	 09h,0C9h, 0Dh,0CCh, 1Ah,0CFh
		db	 24h,0D3h, 30h,0DAh, 7Dh,0E2h
		db	0D5h,0E6h,0EEh,0E9h,0FCh,0F1h
		db	 19h,0F2h, 29h,0FFh,0FFh, 00h
		db	 01h, 02h, 14h, 17h, 18h, 19h
		db	 1Ah, 1Bh, 1Ch, 1Dh, 1Eh
		db	'#$'
		db	'%&', 27h, '()*+,-.'
		db	 1Eh, 16h, 01h, 23h, 16h, 01h
		db	 2Bh, 2Ch, 2Dh, 00h, 2Ah, 16h
		db	 01h, 29h, 16h, 01h, 28h, 16h
		db	 01h, 03h, 40h, 00h, 40h, 16h
		db	 06h, 01h, 80h, 16h, 02h, 03h
		db	0C0h, 00h,0C0h, 16h, 00h, 03h
		db	 80h, 01h, 80h, 16h, 00h, 03h
		db	 40h, 03h, 40h, 16h, 00h, 01h
		db	 80h, 01h, 80h, 16h, 06h, 03h
		db	 40h, 16h, 01h, 40h, 16h, 04h
		db	 01h, 80h, 16h, 02h, 03h,0C0h
		db	 16h, 01h,0C0h, 03h, 80h, 16h
		db	 00h, 01h, 80h, 03h, 40h, 16h
		db	 00h, 03h, 40h, 01h, 80h, 16h
		db	 00h, 01h, 80h, 16h, 06h, 4Fh
		db	0DFh, 16h, 02h,0BEh,0BAh, 16h
		db	 00h, 01h, 80h, 5Ch, 3Ch, 16h
		db	 00h, 03h,0C0h, 58h,0D0h, 16h
		db	 00h, 03h, 80h, 28h, 84h, 16h
		db	 00h, 03h, 40h, 21h, 40h, 16h
		db	 00h
data_1		db	1			; Data table (indexed access)
		db	 80h, 01h, 80h, 16h, 03h, 40h
		db	 16h, 03h,0A0h, 16h, 02h, 15h
		db	 15h, 16h, 02h, 2Ah,0BBh, 16h
		db	 02h, 15h,0CEh, 16h, 02h, 0Bh
		db	 75h, 16h, 02h, 40h,0BFh, 16h
		db	 02h,0A8h,0FBh, 16h, 02h, 56h
		db	0DFh, 16h, 02h, 80h, 5Ch, 16h
		db	 02h, 53h, 0Fh, 00h, 02h, 16h
		db	 00h,0E8h,0F7h, 00h, 01h, 16h
		db	 00h,0EEh, 31h, 80h, 16h, 01h
		db	0FFh, 93h, 40h, 16h, 01h,0CBh
		db	 15h,0C0h, 16h, 01h,0EFh, 87h
		db	 80h, 16h, 01h,0FEh, 9Fh, 00h
		db	 02h, 16h, 00h, 05h, 16h, 03h
		db	0A2h,0A8h, 16h, 02h,0D1h,0D4h
		db	 16h, 02h, 78h, 2Ah, 16h, 02h
		db	0AEh, 75h, 16h, 02h,0FCh, 6Ah
		db	 16h, 02h,0D8h,0D5h, 16h, 02h
		db	0FAh, 6Ah, 16h, 02h,0AEh,0FFh
		db	 16h, 02h, 55h,0DFh, 00h, 04h
		db	 16h, 00h,0B9h, 7Fh, 16h, 02h
		db	 34h,0EFh, 00h, 02h, 16h, 00h
		db	0BDh,0FFh, 16h, 02h, 4Ch,0BFh
		db	 16h, 02h,0BBh,0DFh, 16h, 02h
		db	 5Fh,0F7h, 16h, 02h, 33h, 00h
		db	 16h, 02h, 33h, 00h, 16h, 02h
		db	 33h, 00h, 16h, 02h, 33h, 00h
		db	 16h, 02h, 33h, 00h, 16h, 02h
		db	 33h, 00h, 16h, 02h, 33h, 00h
		db	 16h, 02h, 33h, 00h, 16h, 02h
		db	 33h, 00h, 16h, 02h, 33h, 00h
		db	 00h, 02h, 16h, 00h, 33h, 00h
		db	 16h, 02h, 33h, 00h, 00h, 09h
		db	 16h, 00h, 33h, 00h, 00h, 03h
		db	 16h, 00h, 33h, 00h, 00h, 05h
		db	 16h, 00h, 33h, 00h, 00h, 11h
		db	 16h, 00h, 33h, 00h, 00h, 05h
		db	 16h, 00h, 33h, 00h, 16h, 02h
		db	0FFh, 77h, 16h, 02h,0DFh,0FFh
		db	 16h, 02h,0FBh,0FFh, 16h, 02h
		db	0FFh,0FBh, 16h, 02h, 5Ah, 00h
		db	 16h, 02h, 33h, 00h, 16h, 02h
		db	0FEh,0FFh, 16h, 02h, 33h, 00h
		db	 04h, 16h, 01h, 33h, 00h, 01h
		db	 02h, 16h, 00h, 33h, 00h, 10h
		db	 20h, 16h, 00h, 33h, 00h, 19h
		db	 10h, 16h, 00h, 33h, 00h, 2Ch
		db	 74h, 16h, 00h, 33h, 00h, 59h
		db	 38h, 16h, 00h, 33h, 00h, 7Dh
		db	0D5h, 16h, 00h, 33h, 00h,0BFh
		db	0FBh, 16h, 00h, 33h, 01h,0F7h
		db	 16h, 00h, 33h, 00h, 7Fh,0FDh
		db	 41h, 85h,0BEh, 7Ah,0BCh, 7Ah
		db	 45h, 54h,0BAh,0ABh,0BAh,0ABh
		db	0EDh, 6Bh, 12h, 94h, 12h, 14h
		db	0F7h,0FEh, 08h, 01h, 08h, 01h
		db	 6Fh,0BFh, 90h, 40h, 90h, 40h
		db	0FDh,0FBh, 02h, 04h, 02h, 04h
		db	 03h,0FFh,0FCh, 00h, 6Ch, 00h
		db	 0Fh,0DFh,0F0h, 20h,0B0h, 20h
		db	 24h, 7Fh,0DBh, 80h,0DBh, 80h
		db	 0Fh, 8Fh,0F0h, 70h, 60h, 70h
		db	 27h,0FDh,0D8h, 02h, 58h, 02h
		db	 18h,0FFh,0E7h, 00h,0A7h, 00h
		db	 1Eh, 77h,0E1h, 88h, 61h, 88h
		db	 2Fh,0FFh,0D0h, 00h, 90h, 00h
		db	0F3h,0FDh, 0Ch, 02h, 0Ch, 02h
		db	0DFh,0FBh, 20h, 04h, 20h, 04h
		db	0B5h,0FFh, 4Ah, 00h, 4Ah, 00h
		db	0DDh,0EFh, 22h, 10h, 22h, 10h
		db	0F7h,0F5h, 08h, 0Ah, 08h, 0Ah
		db	 5Dh,0BFh,0A2h, 40h,0A2h, 40h
		db	0BFh, 77h, 40h, 88h, 40h, 88h
		db	 6Fh,0FDh, 90h, 02h, 90h, 02h
		db	0FFh,0F4h, 00h, 0Bh, 00h, 09h
		db	0EEh, 78h, 11h, 87h, 11h, 86h
		db	0FFh, 18h, 00h,0E7h, 00h,0E5h
		db	0BBh,0E4h, 44h, 1Bh, 44h, 1Ah
		db	0F7h,0F0h, 08h, 0Fh, 08h, 06h
		db	0FEh,0A4h, 01h, 5Bh, 01h, 5Bh
		db	0DFh,0F0h, 20h, 0Fh, 20h, 0Dh
		db	0FFh,0C0h, 00h, 3Fh, 00h, 36h
		db	 7Dh,0FFh, 82h, 00h, 82h, 00h
		db	0EFh,0BBh, 10h, 44h, 10h, 44h
		db	0BFh,0EEh, 40h, 11h, 40h, 11h
		db	0D6h,0B7h
		db	 29h, 48h
data_2		db	28h
		db	 48h, 2Ah,0A2h,0D5h, 5Dh,0D5h
		db	 5Dh,0A1h, 82h, 5Eh, 7Dh, 5Eh
		db	 3Dh, 16h, 00h, 33h, 00h,0BFh
		db	0FEh, 16h, 00h, 33h, 00h,0EFh
		db	0FFh, 16h, 00h, 33h, 00h,0DFh
		db	0FDh, 16h, 00h, 33h, 00h,0ABh
		db	0BEh, 16h, 00h, 33h, 00h, 1Ch
		db	 9Ah, 16h, 00h, 33h, 00h, 2Eh
		db	 34h, 16h, 00h, 33h, 00h, 08h
		db	 98h, 16h, 00h, 33h, 00h, 04h
		db	 08h, 16h, 00h, 33h, 00h, 40h
		db	 80h, 16h, 00h, 33h, 00h, 00h
		db	 20h, 16h, 00h, 33h, 00h, 16h
		db	 02h, 33h, 00h, 40h, 16h, 01h
		db	 33h, 00h, 16h, 02h, 33h, 00h
		db	 90h, 16h, 01h, 33h, 00h,0C0h
		db	 16h, 01h, 33h, 00h,0A0h, 16h
		db	 01h, 33h, 00h, 88h, 16h, 01h
		db	 33h, 00h,0A0h, 16h, 01h,0FFh
		db	 75h, 16h, 02h,0FBh,0AAh, 20h
		db	 16h, 01h,0FEh, 9Dh, 16h, 02h
		db	0F7h, 2Ch, 40h, 16h, 01h,0FFh
		db	0BDh, 16h, 02h,0FDh, 32h, 16h
		db	 02h,0FBh,0DDh, 16h, 02h,0EFh
		db	0FAh, 16h, 02h, 4Fh,0DFh, 16h
		db	 02h,0BEh,0BAh, 16h, 02h, 5Ch
		db	0FCh, 16h, 02h, 5Bh, 70h, 16h
		db	 02h, 2Bh,0E4h, 16h, 02h, 21h
		db	0C0h, 16h, 03h,0C0h, 16h, 03h
		db	 40h, 16h, 02h,0BFh, 2Fh, 16h
		db	 02h, 7Dh, 7Fh, 16h, 02h,0ECh
		db	0B7h, 16h, 02h,0D8h,0FFh, 16h
		db	 02h,0FAh,0DFh, 16h, 02h,0D9h
		db	0FFh, 16h, 02h,0EDh,0EFh, 16h
		db	 02h,0FFh, 7Fh, 16h, 02h,0BFh
		db	 2Fh, 00h, 02h, 16h, 00h, 7Dh
		db	 7Fh, 00h, 03h, 16h, 00h,0ECh
		db	0B7h, 00h, 04h, 16h, 00h,0D8h
		db	0FFh, 00h, 1Ah, 16h, 00h,0FAh
		db	0DFh, 00h, 0Ch, 16h, 00h,0D9h
		db	0FFh, 00h, 01h, 16h, 00h,0EDh
		db	0EFh, 16h, 02h,0FFh, 7Fh, 00h
		db	 04h, 16h, 00h, 2Bh,0A8h, 16h
		db	 02h,0B1h, 46h, 16h, 02h, 64h
		db	 12h, 16h, 02h, 60h, 09h, 16h
		db	 02h,0A4h, 89h, 16h, 02h, 51h
		db	 59h, 16h, 02h, 2Dh, 62h, 16h
		db	 02h, 09h, 16h, 03h, 28h,0FFh
		db	 16h, 02h, 15h,0DCh, 16h, 02h
		db	 88h, 70h, 16h, 02h, 14h, 8Ah
		db	 16h, 02h, 0Dh, 21h, 16h, 02h
		db	 04h, 80h, 16h, 0Eh,0BDh,0A2h
		db	 16h, 02h, 6Eh,0C4h, 16h, 02h
		db	0F9h, 16h, 03h, 19h,0CAh, 16h
		db	 02h, 42h, 10h, 16h, 02h, 04h
		db	 40h, 16h, 0Eh, 57h,0FFh, 16h
		db	 02h, 61h,0FEh, 16h, 02h,0CEh
		db	0CBh, 16h, 02h, 96h,0F6h, 16h
		db	 02h,0DBh, 1Bh, 16h, 02h, 7Eh
		db	 0Eh, 16h, 03h, 2Dh, 16h, 03h
		db	 48h, 16h, 02h,0FFh,0EAh, 16h
		db	 02h,0EEh,0AFh, 16h, 02h,0FDh
		db	 4Bh, 16h, 02h,0ABh, 4Fh, 16h
		db	 02h, 7Eh,0FBh, 16h, 02h, 44h
		db	 36h, 16h, 02h, 08h, 16h, 03h
		db	 4Ch, 40h, 16h, 03h, 09h, 16h
		db	 03h, 20h, 16h, 02h, 01h, 16h
		db	 21h, 04h, 20h, 16h, 02h, 12h
		db	 16h, 03h, 10h, 80h, 16h, 02h
		db	 08h, 20h, 16h, 02h, 08h, 16h
		db	 14h, 03h, 00h, 01h, 16h, 01h
		db	 0Dh, 00h, 05h, 16h, 01h, 34h
		db	 00h, 04h, 16h, 01h,0D0h, 00h
		db	 10h, 16h, 00h, 03h, 40h, 00h
		db	 45h, 16h, 00h, 0Dh, 00h, 05h
		db	 2Fh, 16h, 00h, 34h, 00h, 14h
		db	0FBh, 16h, 00h,0D0h, 00h, 52h
		db	0DFh, 16h, 02h, 1Fh,0FFh, 04h
		db	 16h, 01h,0BFh,0FFh, 01h, 02h
		db	 16h, 00h, 7Fh,0FFh, 10h, 20h
		db	 16h, 00h, 33h, 00h, 19h, 10h
		db	 16h, 00h, 33h, 00h, 2Ch, 74h
		db	 16h, 00h, 33h, 00h, 59h, 38h
		db	 16h, 00h, 33h, 00h, 7Dh,0D5h
		db	 16h, 00h, 33h, 00h,0BFh,0FBh
		db	 16h, 00h,0FFh,0E8h, 04h, 16h
		db	 01h,0FFh,0F4h, 01h, 16h, 01h
		db	0FFh,0FDh, 10h, 20h, 16h, 00h
		db	 33h, 00h, 19h, 10h, 16h, 00h
		db	 33h, 00h, 2Ch, 74h, 16h, 00h
		db	 33h, 00h, 19h, 38h, 16h, 00h
		db	 33h, 00h, 7Dh,0D5h, 16h, 00h
		db	 33h, 00h,0BFh,0FBh, 16h, 00h
		db	 5Fh,0FFh, 16h, 02h,0BFh,0FFh
		db	 00h, 02h, 16h, 00h, 33h, 00h
		db	 16h, 02h, 33h, 00h, 00h, 09h
		db	 16h, 00h, 33h, 00h, 00h, 03h
		db	 16h, 00h, 33h, 00h, 00h, 05h
		db	 16h, 00h, 33h, 00h, 00h, 11h
		db	 16h, 00h, 33h, 00h, 00h, 05h
		db	 16h, 00h,0FFh,0E8h, 16h, 02h
		db	0FFh,0FCh, 40h, 16h, 01h, 33h
		db	 00h, 16h, 02h, 33h, 00h, 90h
		db	 16h, 01h, 33h, 00h,0C0h, 16h
		db	 01h, 33h, 00h,0A0h, 16h, 01h
		db	 33h, 00h, 88h, 16h, 01h, 33h
		db	 00h,0A0h, 00h,0C0h, 00h, 80h
		db	 16h, 01h,0B0h, 00h,0A0h, 16h
		db	 01h, 2Ch, 00h, 20h, 16h, 01h
		db	 0Bh, 00h, 08h, 16h, 01h, 02h
		db	0C0h,0A2h, 16h, 02h,0B0h,0F4h
		db	0A0h, 16h, 01h, 2Ch,0DFh, 28h
		db	 16h, 01h, 0Bh,0FBh, 4Ah, 16h
		db	 09h, 70h, 00h, 20h, 13h, 03h
		db	 00h, 30h, 13h, 03h,0A4h, 85h
		db	 00h, 30h,0AFh,0A7h, 4Fh, 82h
		db	 00h, 30h, 4Fh,0A2h, 12h, 16h
		db	 00h, 30h, 12h, 16h, 02h, 7Fh
		db	 00h, 64h, 16h, 0Ah, 40h, 12h
		db	 07h, 00h, 46h, 12h, 90h, 5Bh
		db	 03h, 00h, 92h, 5Bh, 48h, 6Ch
		db	 03h, 00h,0C8h, 7Fh,0B0h, 3Bh
		db	 03h, 00h,0B2h, 3Bh, 00h, 50h
		db	 23h, 3Ah, 00h, 50h, 00h, 04h
		db	0F7h,0FBh, 04h, 5Ch, 16h, 0Ah
		db	 20h, 00h, 49h, 00h, 23h, 03h
		db	 70h, 18h, 07h, 81h, 74h, 19h
		db	0A0h, 14h, 0Ch,0C1h,0E8h, 1Dh
		db	 40h, 0Ch, 1Fh,0E1h, 4Bh, 0Ch
		db	 06h, 80h, 30h, 31h, 26h, 81h
		db	 01h, 00h, 70h, 3Bh, 01h, 23h
		db	 16h, 0Ah, 08h, 04h, 80h,0E0h
		db	 08h,0C4h, 18h, 0Ah,0E3h,0C0h
		db	 19h, 0Ah, 00h, 1Ch,0B6h,0C1h
		db	 04h, 1Dh, 00h, 18h, 9Ch,0C3h
		db	 00h, 9Ah, 30h, 00h, 88h,0C6h
		db	 30h, 80h, 12h, 00h, 80h,0EEh
		db	 12h, 88h, 16h, 94h, 1Ah,0ACh
		db	 1Ah,0A8h, 1Ah,0A8h, 91h, 04h
		db	 3Eh, 0Ah, 04h, 10h, 04h, 10h
		db	 04h, 10h, 02h, 20h, 02h, 20h
		db	 02h, 20h, 01h, 40h, 01h, 40h
		db	 01h, 40h, 16h, 04h, 01h,0C0h
		db	 16h, 02h, 03h,0E0h, 16h, 02h
		db	 07h,0F0h, 16h, 02h, 0Fh,0F8h
		db	 16h, 02h, 0Fh,0F8h, 01h, 40h
		db	 01h, 40h, 1Fh,0FCh, 02h,0A0h
		db	 02h,0A0h, 1Eh,0BCh, 04h, 90h
		db	 04h, 90h, 1Dh, 5Ch, 0Dh, 58h
		db	 0Dh, 58h, 16h, 05h, 80h, 16h
		db	 02h, 01h,0C0h, 16h, 02h, 03h
		db	0E0h, 16h, 02h, 07h,0F0h, 00h
		db	 80h, 00h, 80h, 07h,0F0h, 01h
		db	 40h, 01h, 40h, 0Fh,0F8h, 05h
		db	0D0h, 05h,0D0h, 0Eh,0B8h, 0Eh
		db	0B8h, 0Eh,0B8h, 16h, 04h, 04h
		db	 40h, 60h, 00h, 64h, 40h, 06h
		db	0A4h,0F0h, 00h, 86h,0A4h, 03h
		db	 93h, 98h, 00h, 03h,0FBh, 01h
		db	 74h,0FCh, 00h, 59h, 74h, 00h
		db	 50h, 06h, 16h, 00h, 50h, 40h
		db	 00h, 07h, 00h, 44h, 16h, 1Bh
		db	 30h, 00h,0D7h, 4Bh, 16h, 00h
		db	 37h,0FFh, 16h, 02h, 30h, 16h
		db	 22h, 0Ch,0D2h,0EBh, 16h, 00h
		db	0FFh,0ECh, 16h, 03h, 0Ch, 16h
		db	 0Bh,0BBh, 16h, 01h,0BBh, 0Bh
		db	 7Ah, 16h, 00h, 0Bh, 7Ah, 56h
		db	 6Dh, 16h, 00h, 5Fh,0CDh,0ABh
		db	 10h, 16h, 00h,0BCh,0D9h,0B3h
		db	 48h, 16h, 00h,0BCh,0E8h, 4Dh
		db	 74h, 16h, 00h, 5Fh,0F4h, 0Bh
		db	0CAh, 16h, 00h, 0Bh,0EAh, 00h
		db	0ADh, 16h, 01h,0ADh,0DDh, 16h
		db	 01h,0DDh, 00h, 5Eh,0D0h, 16h
		db	 00h, 5Eh,0D0h,0B6h, 6Ah, 16h
		db	 00h,0B3h,0FAh, 08h,0D5h, 16h
		db	 00h, 9Bh, 3Dh, 12h,0CDh, 16h
		db	 00h, 17h, 3Dh, 2Eh,0B2h, 16h
		db	 00h, 2Fh,0FAh, 53h,0D0h, 16h
		db	 00h, 57h,0D0h,0B5h, 16h, 01h
		db	0B5h, 00h,0FBh, 5Fh, 04h,0A0h
		db	 04h,0A0h,0FDh,0DEh, 02h, 21h
		db	 02h, 21h, 5Fh, 7Fh,0A0h, 80h
		db	0A0h, 80h,0F5h,0DBh, 0Ah, 24h
		db	 0Ah, 24h, 7Bh,0F7h, 84h, 08h
		db	 84h, 08h,0D6h,0FFh, 29h, 00h
		db	 29h, 00h,0DFh, 3Fh, 20h,0C0h
		db	 20h,0C0h,0BDh,0FFh, 42h, 00h
		db	 42h, 00h,0F5h,0F7h, 0Ah, 08h
		db	 0Ah, 08h,0BFh, 5Dh, 40h,0A2h
		db	 40h,0A2h, 77h,0BFh, 88h, 40h
		db	 88h, 40h,0FDh, 6Fh, 02h, 90h
		db	 02h, 90h,0FDh,0F3h, 02h, 0Ch
		db	 02h, 0Ch,0FBh,0DFh, 04h, 20h
		db	 04h, 20h,0FFh,0B5h, 00h, 4Ah
		db	 00h, 4Ah,0EFh,0DDh, 10h, 22h
		db	 10h, 22h,0F7h, 7Bh, 08h, 84h
		db	 08h, 84h,0FFh,0D6h, 00h, 29h
		db	 00h, 29h, 3Fh,0DFh,0C0h, 20h
		db	0C0h, 20h,0FFh,0BDh, 00h, 42h
		db	 00h, 42h, 5Fh,0FBh,0A0h, 04h
		db	0A0h, 04h,0DEh,0FDh, 21h, 02h
		db	 21h, 02h, 7Fh, 5Fh, 80h,0A0h
		db	 80h,0A0h,0DBh,0F5h, 24h, 0Ah
		db	 24h, 0Ah, 24h, 7Fh,0DBh, 80h
		db	0DBh, 80h, 0Fh, 8Fh,0F0h, 70h
		db	 60h, 70h, 27h,0FDh,0D8h, 02h
		db	 58h, 02h, 18h,0FFh,0E7h, 00h
		db	0A7h, 00h, 1Eh, 77h,0E1h, 88h
		db	 61h, 88h, 2Fh,0FFh,0D0h, 00h
		db	 90h, 00h, 03h,0FFh,0FCh, 00h
		db	 6Ch, 00h, 0Fh,0DFh,0F0h, 20h
		db	0B0h, 20h, 27h,0FDh,0D8h, 02h
		db	 58h, 02h, 18h,0FFh,0E7h, 00h
		db	0A7h, 00h, 1Eh, 77h,0E1h, 88h
		db	 61h, 88h, 2Fh,0FFh,0D0h, 00h
		db	 90h, 00h, 03h,0FFh,0FCh, 00h
		db	 6Ch, 00h, 0Fh,0DFh,0F0h, 20h
		db	0B0h, 20h, 24h, 7Fh,0DBh, 80h
		db	0DBh, 80h, 0Fh, 8Fh,0F0h, 70h
		db	 60h, 70h, 1Eh, 77h,0E1h, 88h
		db	 61h, 88h, 2Fh,0FFh,0D0h, 00h
		db	 90h, 00h, 03h,0FFh,0FCh, 00h
		db	 6Ch, 00h, 0Fh,0DFh,0F0h, 20h
		db	0B0h, 20h, 24h, 7Fh,0DBh, 80h
		db	0DBh, 80h, 0Fh, 8Fh,0F0h, 70h
		db	 60h, 70h, 27h,0FDh,0D8h, 02h
		db	 58h, 02h, 18h,0FFh,0E7h, 00h
		db	0A7h, 00h,0FFh, 18h, 00h,0E7h
		db	 00h,0E5h,0BBh,0E4h, 44h, 1Bh
		db	 44h, 1Ah,0F7h,0F0h, 08h, 0Fh
		db	 08h, 06h,0FEh,0A4h, 01h, 5Bh
		db	 01h, 5Bh,0DFh,0F0h, 20h, 0Fh
		db	 20h, 0Dh,0FFh,0C0h, 00h
		db	3Fh
loc_1:
		add	ds:data_3e,dh
		add	[bp+di],cl
		add	[bx+di],cl
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		js	$+13h			; Jump if sign=1
		xchg	[bx+di],dx
		xchg	dh,bh
                           lock	or	[bx],cl
		or	byte ptr ds:[0A4FEh],al
		add	[bp+di+1],bx
		pop	bx
		db	0DFh,0F0h, 20h, 0Fh, 20h, 0Dh
		db	0FFh,0C0h, 00h, 3Fh, 00h, 36h
		db	0FFh,0F4h, 00h, 0Bh, 00h, 09h
		db	0EEh, 78h, 11h, 87h, 11h, 86h
		db	0FFh, 18h, 00h,0E7h, 00h,0E5h
		db	0BBh,0E4h, 44h, 1Bh, 44h, 1Ah
		db	0DFh,0F0h
loc_2:
		and	[bx],cl
		and	[di],cl
;*		inc	ax
		db	0FFh,0C0h		;  Fixup - byte match
		add	[bx],bh
		add	ds:data_3e,dh
		add	[bp+di],cl
		add	[bx+di],cl
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		js	$+13h			; Jump if sign=1
		xchg	[bx+di],dx
		xchg	bh,bh
		sbb	[bx+si],al
		out	0,ax			; port 0, DMA-1 bas&add ch 0
		in	ax,0BBh			; port 0BBh ??I/O Non-standard
		in	al,44h			; port 44h ??I/O Non-standard
		sbb	ax,[si+1Ah]
		div	ax			; ax,dx rem=dx:ax/reg
		or	[bx],cl
		or	byte ptr ds:[0A4FEh],al
		add	[bp+di+1],bx
		pop	bx
		push	ss
		add	[bp+di],dh
;*		add	bh,dh
		db	 00h,0F7h		;  Fixup - byte match
		call	word ptr ds:[3300h]
;*		add	ch,bh
		db	 00h,0FDh		;  Fixup - byte match
		jg	loc_1			; Jump if >
		inc	cx
		jp	$-40h			; Jump if parity=1
		jp	$-42h			; Jump if parity=1
		push	sp
		inc	bp
		stosw				; Store ax to es:[di]
		mov	dx,0BAABh
		db	 6Bh,0EDh, 94h, 12h, 14h, 12h
		db	0FEh,0F7h, 01h, 08h, 01h, 08h
		db	0BFh, 6Fh, 40h, 90h, 40h, 90h
		db	0FBh,0FDh, 04h, 02h, 04h, 02h
		db	0FFh, 7Dh, 00h, 82h, 00h, 82h
		db	0BBh,0EFh, 44h, 10h, 44h, 10h
		db	0EEh,0BFh, 11h, 40h, 11h, 40h
		db	0B7h,0D6h, 48h, 29h, 48h, 28h
		db	0A2h, 2Ah, 5Dh,0D5h, 5Dh,0D5h
		db	 82h,0A1h, 7Dh, 5Eh, 3Dh, 5Eh
		db	 16h, 00h, 33h, 00h,0FEh,0BFh
		db	 16h, 00h, 33h, 01h,0EFh

_380UNKN	endp

seg_a		ends



		end	start
