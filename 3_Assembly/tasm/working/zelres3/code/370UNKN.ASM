
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_370UNKN                                 €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    5          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	0BFEAh			;*
data_9e		equ	2080h			;*
data_10e	equ	2980h			;*
data_11e	equ	29A0h			;*
data_12e	equ	29E0h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_370UNKN	proc	far

start:
		jns	loc_2			; Jump if not sign
		add	[bx+si],al
		add	byte ptr ds:[29h],al
		db	 36h,0FFh, 62h, 55h, 69h,0AAh
		db	 72h, 80h, 84h, 03h, 89h,0FEh
		db	 96h,0FDh,0F2h, 01h,0FFh,0FFh
		db	29h
loc_2:
		daa				; Decimal adjust
		push	es
		sub	[bx+di],ax
		push	cs
		sub	[bx+si],ax
		or	al,1Ch
		add	[bp+di],al
		sbb	al,37h			; '7'
		add	[bx],al
loc_3:
		db	 3Eh, 3Dh, 01h,0BDh,0F9h,0F3h
		db	 01h,0F3h, 0Ch, 3Ch, 00h, 03h
		db	 1Ch, 78h, 00h, 06h, 38h, 9Fh
		db	 06h, 1Fh, 7Bh,0EAh, 03h,0EAh
		db	 7Dh, 5Fh, 7Dh, 5Fh,0ABh,0FFh
		db	0ABh,0FFh, 7Fh,0FFh, 7Fh,0EBh
		db	 36h, 00h,0FEh,0C0h, 49h, 3Ch
		db	 02h, 3Fh,0BDh, 55h, 3Dh, 55h
		db	 57h,0FFh, 57h, 36h, 04h,0FCh
		db	0F8h,0D7h,0FFh,0F8h, 9Ch, 04h
		db	0FFh,0FCh, 00h, 8Fh, 36h, 00h
		db	 30h, 7Fh,0A0h, 00h, 5Dh, 57h
		db	 40h, 00h,0BEh,0A7h, 70h, 00h
		db	 8Dh, 56h, 60h, 00h, 9Eh,0ABh
		db	0D0h, 00h, 2Fh, 54h, 38h, 00h
		db	0C7h,0FFh, 29h, 00h,0FFh, 00h
		db	0D1h, 55h,0D1h, 55h, 29h, 00h
		db	 7Fh,0DFh, 29h, 00h, 79h,0BFh
		db	 29h, 00h,0FFh, 3Fh, 29h, 00h
		db	0FFh,0DFh, 29h, 00h,0AFh, 6Fh
		db	 29h, 00h,0C0h, 03h, 2Ah,0A8h
		db	 2Ah,0A8h, 62h, 02h, 29h, 00h
		db	 36h, 00h, 29h, 00h,0FFh,0EFh
		db	 29h, 00h, 36h, 00h, 29h, 00h
		db	0FFh
		db	0BFh, 29h, 00h,0FEh, 7Fh, 29h
		db	 00h,0FBh,0FFh, 29h, 01h, 0Fh
		db	 55h, 50h, 55h, 50h, 03h,0FCh
		db	0EFh,0FFh, 01h, 5Fh,0EDh, 5Fh
		db	 03h,0FFh,0BFh,0FFh, 0Fh,0FFh
		db	0BFh,0FFh, 0Fh,0FFh,0BFh,0FFh
		db	 0Fh,0FFh,0BFh,0FFh, 00h,0AFh
		db	0DCh,0AFh, 01h, 55h, 3Dh, 55h
		db	 54h, 1Ch, 55h,0C0h,0FDh, 50h
		db	0FDh, 53h,0FFh,0F5h,0FFh,0F5h
		db	 36h, 0Eh, 57h,0FFh, 57h,0FFh
		db	 60h, 40h, 29h, 00h,0E2h,0E0h
		db	 1Ch, 00h,0ABh, 83h,0A8h, 18h
		db	0F5h,0D2h,0F5h,0D0h,0FFh,0F5h
		db	0FFh,0F5h, 36h, 06h,0F7h,0FFh
		db	0F7h,0FFh, 10h, 29h, 01h, 70h
		db	 29h, 01h,0B0h, 0Ch, 29h, 00h
		db	 40h, 78h, 1Ch, 00h, 73h,0F0h
		db	 70h, 00h
data_5		db	0D7h			; Data table (indexed access)
		db	0B0h,0D7h, 87h,0FEh,0BCh,0FEh
		db	0BCh,0FFh,0EAh,0FFh,0EAh, 29h
		db	 0Eh, 03h, 29h, 01h, 1Fh, 29h
		db	 01h,0F6h, 01h, 29h, 00h, 5Ah
		db	 3Fh, 59h, 80h,0CBh, 81h,0C3h
		db	 99h,0AEh,0B7h,0AEh,0B7h, 75h
		db	0EAh, 75h,0EAh,0EFh, 5Fh,0EFh
		db	 5Fh, 36h, 0Eh,0FEh,0AFh,0FEh
		db	0AFh, 55h,0FFh, 55h, 36h, 02h
		db	0DAh, 36h, 00h, 78h,0E1h, 36h
		db	 00h,0CFh, 18h, 36h, 00h, 18h
		db	0CFh, 36h, 00h, 8Fh,0FDh, 36h
		db	 01h,0F7h, 36h, 00h, 07h,0FFh
		db	 7Fh,0FFh, 01h,0FFh, 3Fh,0FFh
		db	 00h, 7Fh, 0Fh,0FFh, 00h, 1Fh
		db	 03h,0FFh, 00h, 03h, 00h, 7Fh
		db	 29h, 01h, 0Fh, 29h, 04h, 36h
		db	 18h, 07h, 36h, 01h, 80h, 07h
		db	 36h, 1Eh, 69h, 02h, 62h, 02h
		db	 69h, 02h, 62h, 02h, 69h, 02h
		db	 62h, 02h, 69h, 02h, 62h, 02h
		db	 2Fh,0FFh, 29h, 00h, 02h,0FFh
		db	 29h, 01h, 2Fh, 29h, 01h,0C2h
		db	 00h, 80h,0D7h,0ACh, 54h,0ACh
		db	 2Fh,0FFh, 2Eh, 19h, 0Bh,0FEh
		db	0CBh,0FEh, 05h, 55h,0E5h, 55h
		db	0BEh,0F6h,0BEh,0F6h, 78h, 6Ah
		db	 78h, 00h,0D1h,0D6h,0D0h, 00h
		db	 01h,0FCh, 04h, 00h, 09h,0FEh
		db	 50h, 00h, 01h,0F4h, 04h, 00h
		db	 03h,0F8h, 29h, 00h, 03h,0E0h
		db	 29h, 00h, 06h, 00h,0C0h, 00h
		db	 3Eh, 29h, 01h,0B4h, 0Ch,0B1h
		db	 80h,0EBh, 3Ch,0EBh, 80h,0FEh
		db	0B4h,0FEh,0B0h,0FFh,0CCh,0FFh
		db	0CFh,0FFh,0F5h,0FFh,0F5h,0FFh
		db	0FEh,0FFh,0FEh, 29h, 0Ah, 08h
		db	 29h, 01h, 38h, 29h, 01h,0F0h
		db	 10h, 29h, 00h,0D0h, 30h,0CCh
		db	 00h, 93h,0F0h, 90h, 00h,0F3h
		db	 70h,0F3h, 00h,0FDh, 70h,0FDh
		db	 7Eh,0FFh,0D5h,0FFh,0D5h,0FFh
		db	 3Fh,0FFh, 3Fh,0FFh,0CFh,0FFh
		db	0CFh,0FFh,0CFh,0FFh,0CFh,0BFh
		db	0FFh,0BFh,0FFh,0DDh,0FFh,0DDh
		db	0FFh, 03h,0D0h, 29h, 00h, 03h
		db	0E0h, 29h, 00h, 03h,0A0h, 29h
		db	 00h, 37h,0C0h, 29h, 00h, 07h
		db	 80h, 29h, 00h, 07h, 80h, 29h
		db	 00h,0CEh, 80h, 29h, 00h, 17h
		db	 29h, 01h, 0Eh, 80h, 29h, 00h
		db	 03h, 40h, 29h, 18h, 36h, 00h
		db	0E6h, 04h, 36h, 00h, 41h,0C3h
		db	 36h, 00h, 1Eh, 3Fh, 36h, 00h
		db	 71h, 36h, 01h,0CFh, 36h, 0Bh
		db	0FEh,0AAh,0FEh,0AAh,0FFh,0FDh
		db	0FFh,0FDh, 36h, 0Bh,0FDh,0FFh
		db	0FDh,0F6h, 50h,0F6h, 50h, 40h
		db	 0Ah, 40h, 0Ah, 69h, 02h, 62h
		db	 02h, 69h, 02h,0D5h, 55h,0D5h
		db	 55h,0EAh,0AAh,0EAh,0AAh,0ADh
		db	 55h,0ADh, 55h, 00h,0AAh, 00h
		db	 69h, 00h, 09h,0AAh, 09h, 36h
		db	 07h,0FCh,0FFh,0FCh,0FFh,0F3h
		db	0FFh,0F3h,0FFh,0E6h,0FFh,0E6h
		db	0FFh,0DDh,0FFh,0DDh, 36h, 03h
		db	0CFh,0FFh,0CFh,0FFh, 50h,0FFh
		db	 50h,0F3h, 0Fh,0F3h, 0Fh,0FCh
		db	0FFh,0FCh,0E0h,0D3h,0FFh,0D3h
		db	 02h, 36h, 00h,0F8h, 9Fh, 36h
		db	 00h,0C4h,0CFh, 36h, 00h,0CFh
		db	 36h, 03h, 35h, 55h, 35h, 55h
		db	 36h, 00h, 00h, 7Fh, 36h, 00h
		db	0C3h, 36h, 01h, 7Fh, 36h, 00h
		db	0C3h,0FFh,0C3h,0FFh, 3Fh,0FFh
		db	 31h,0F0h,0FFh,0F0h, 87h, 33h
		db	0FFh, 33h, 3Fh, 55h, 52h, 55h
		db	 52h,0EAh,0A8h,0EAh,0A8h,0FFh
		db	 54h,0FFh, 54h,0FFh,0E8h,0FFh
		db	0E8h,0FFh,0F4h,0FFh,0F4h,0FFh
		db	0C8h,0FFh,0C8h,0FFh,0D0h,0FFh
		db	0D0h,0FFh, 31h,0FFh, 31h, 29h
		db	 0Fh, 35h, 00h, 34h, 06h, 00h
		db	 09h,0E0h, 60h, 1Ch, 9Dh, 23h
		db	 01h, 80h,0E8h, 7Fh, 29h, 07h
		db	 03h, 29h, 01h,0FEh, 00h, 86h
		db	0D7h,0AFh, 54h,0AFh, 2Fh,0FFh
		db	 2Eh, 19h, 0Bh,0FEh,0CBh,0FEh
		db	 05h, 55h,0E5h, 55h, 2Fh,0FFh
		db	 29h, 00h, 02h,0FFh, 29h, 00h
		db	0FCh, 2Fh, 4Ch, 00h,0BFh,0C2h
		db	0B8h,0C0h,0FFh,0FCh, 8Fh,0FCh
		db	0FFh,0EBh,0FFh,0EBh,0FBh,0B5h
		db	0FBh,0B5h, 55h, 50h, 55h, 50h
		db	 36h, 00h, 07h, 36h, 01h, 00h
		db	 07h, 36h, 00h, 29h, 00h,0BFh
		db	0FFh, 29h, 00h, 0Ch,0ACh, 29h
		db	 00h, 43h, 02h, 43h, 02h,0AAh
		db	0A0h,0AAh,0A0h, 29h, 02h,0FFh
		db	 0Fh,0FFh, 0Fh

locloop_4:
		dec	word ptr [si]
		dec	word ptr [si]
		cld				; Clear direction
		retn
		db	 00h, 03h,0F3h, 30h, 29h, 00h
		db	0CCh, 0Ch, 29h, 00h, 23h, 00h
		db	 23h, 00h, 80h, 03h, 80h, 04h
		db	 00h, 18h, 00h, 27h, 36h, 03h
		db	0FCh,0FFh,0FCh, 33h, 33h, 33h
		db	 33h,0CCh,0C0h,0CCh,0C0h, 00h
		db	 3Fh, 00h, 20h, 34h, 07h, 4Bh
		db	 07h, 00h, 63h,0E8h, 9Bh, 03h
		db	 01h, 44h,0D5h,0C3h,0FFh,0C2h
		db	 3Fh,0C3h,0FFh,0C2h, 7Fh, 0Fh
		db	0FFh, 0Eh, 9Fh, 0Fh,0FFh, 09h
		db	 7Fh, 36h, 00h, 63h, 36h, 03h
		db	0E7h,0FFh,0E7h,0FFh, 42h,0BFh
		db	 42h,0BFh,0FEh,0C0h,0FEh,0C0h
		db	0FDh, 80h,0FDh, 80h,0FAh, 80h
		db	0FAh, 80h,0FDh, 40h,0FDh, 40h
		db	0FFh, 80h,0FFh, 80h,0FEh, 00h
		db	0FEh, 00h,0FCh, 00h,0FCh,0F8h
		db	0D5h, 00h,0D5h, 57h, 36h, 0Fh
		db	0FDh,0FFh,0FDh,0FFh, 07h,0FFh
		db	 04h,0FDh
data_6		dw	0FDFFh			; Data table (indexed access)
		db	 07h,0E7h,0F1h,0E0h, 70h,0FEh
		db	0AAh,0FEh,0AAh,0FFh,0FDh,0FFh
		db	0FDh, 36h, 06h, 20h, 3Fh, 20h
		db	 3Fh,0FFh,0C5h, 13h,0C5h,0FFh
		db	0F8h,0FFh,0F8h,0FFh,0FCh, 3Fh
		db	0FCh, 69h, 02h, 62h, 02h, 69h
		db	 02h,0D5h, 55h,0D5h, 55h,0FAh
		db	0AAh,0FAh,0AAh, 7Fh, 55h, 7Fh
		db	 55h,0BEh,0AAh,0BEh,0AAh, 7Dh
		db	0D5h, 7Dh,0D5h,0BFh,0EFh, 83h
		db	0E1h, 7Fh, 9Fh, 1Fh, 81h,0FFh
		db	 3Fh,0FFh, 05h,0FFh, 7Fh,0FFh
		db	 17h,0FFh, 7Fh,0FFh, 17h,0FEh
		db	0FFh,0FEh, 1Fh,0F8h,0FFh,0F8h
		db	 3Fh,0F9h,0FFh,0F8h, 7Fh,0FFh
		db	0ECh, 5Fh,0ECh,0FFh,0F4h,0FFh
		db	0F4h,0FFh,0FCh,0FFh,0FCh,0FFh
		db	0F4h,0FFh,0F4h,0FFh,0ECh,0FFh
		db	0ECh,0FFh,0E8h,0FFh,0E8h,0FFh
		db	0D8h,0FFh,0D8h,0FFh,0D0h,0FFh
		db	0D0h,0BFh,0A0h,0BFh,0A0h, 15h
		db	0D4h, 15h,0D4h,0A2h,0AAh,0A2h
		db	0AAh, 54h, 15h, 54h, 15h, 02h
		db	0AAh, 02h,0AAh, 29h, 06h, 80h
		db	 00h, 80h, 00h,0AFh,0FEh,0AFh
		db	0FEh, 00h, 55h, 00h, 55h, 69h
		db	 02h, 62h, 02h,0A8h, 00h,0A8h
		db	 29h, 04h, 06h, 02h,0C1h, 00h
		db	 30h, 3Dh, 0Fh,0A2h,0BFh,0A2h
		db	0BFh, 15h, 53h, 15h, 53h,0AAh
		db	 8Eh,0AAh, 8Eh, 50h, 10h, 50h
		db	 10h, 00h, 07h, 00h, 07h, 00h
		db	0FFh, 00h,0FFh, 1Fh,0A8h, 9Fh
		db	0A8h, 0Ah, 8Fh,0CAh, 8Fh,0D0h
		db	 00h,0D0h, 00h,0FFh, 40h,0FFh
		db	 40h,0DFh,0FEh,0DFh,0FEh, 7Fh
		db	0FFh, 7Fh,0FFh,0FBh,0FFh,0FBh
		db	0FFh,0AFh,0FFh,0AFh, 36h, 00h
		db	0FAh,0FFh,0FAh,0FAh, 80h,0FAh
		db	 80h, 69h, 02h, 62h, 02h, 2Ah
		db	0AAh, 2Ah,0AAh, 62h, 02h, 2Ah
		db	0AAh, 29h, 00h, 15h, 45h, 29h
		db	 00h, 0Ah,0AAh, 29h, 01h, 51h
		db	 29h, 00h, 36h, 00h,0E6h, 04h
		db	 36h, 00h, 41h,0C3h, 36h, 00h
		db	 1Eh, 3Fh, 36h, 00h, 71h, 36h
		db	 00h,0FDh,0CFh,0FDh,0FFh,0E7h
		db	0FFh,0E4h,0FFh,0BFh,0FFh, 87h
		db	0FFh, 71h,0FEh, 70h, 36h, 0Eh
		db	 20h, 3Fh, 20h, 3Fh,0FFh,0C5h
		db	 10h, 85h,0FFh,0F8h, 07h,0F8h
		db	0FFh,0FCh, 87h,0FCh,0FEh,0AAh
		db	0FEh,0AAh,0FFh,0FDh,0FFh,0FDh
		db	 36h, 0Ah, 7Fh,0FFh, 7Fh,0FFh
		db	0AFh,0FFh,0AFh,0FFh, 55h, 5Fh
		db	 55h, 5Fh, 69h, 02h, 62h, 02h
		db	 69h, 02h,0D5h, 55h,0D5h, 55h
		db	0FAh,0AAh,0FAh,0AAh, 7Fh, 55h
		db	 7Fh, 55h,0BEh,0AAh,0BEh,0AAh
		db	 7Dh,0D5h, 7Dh,0D5h,0FEh,0EFh
		db	0FEh, 08h,0FDh, 9Fh,0FCh, 00h
		db	0FDh, 3Fh,0FCh, 03h,0FBh, 7Fh
		db	0F8h, 47h,0FBh, 7Fh,0F8h, 0Fh
		db	0FAh,0FFh,0F8h, 97h,0F8h,0FFh
		db	0F8h, 1Fh,0F9h,0FFh,0F9h, 3Fh
		db	 2Fh,0FFh, 29h, 00h, 02h,0FFh
		db	 29h, 01h, 2Fh, 29h, 01h, 02h
		db	 29h, 09h, 03h, 00h, 04h, 00h
		db	 18h, 00h, 27h, 36h, 03h,0FEh
		db	 01h,0FCh,0F7h, 75h, 29h, 00h
		db	0AAh, 80h, 29h, 01h, 3Fh, 00h
		db	 20h, 34h, 07h, 4Bh, 07h, 00h
		db	 63h,0E8h, 9Bh, 03h, 01h, 44h
		db	0D5h, 69h, 02h, 62h, 02h, 69h
		db	 02h, 62h, 02h, 69h, 00h, 2Ah
		db	 00h, 55h, 45h, 29h, 00h, 69h
		db	 00h, 29h, 00h, 55h, 51h, 29h
		db	 00h, 01h, 12h, 01h, 12h, 00h
		db	 02h, 00h, 02h, 80h, 01h,0FFh
		db	 41h,0B0h, 00h,0B5h,0F8h,0C8h
		db	 00h,0C9h, 00h,0A0h, 00h,0A0h
		db	 00h, 80h, 02h, 80h, 29h, 03h
		db	0AAh, 8Ah,0AAh, 8Ah, 45h, 55h
		db	 45h, 55h,0AAh, 8Ah,0AAh, 8Ah
		db	 45h, 15h, 45h, 15h, 8Ah, 0Ah
		db	 0Ah, 00h, 55h, 14h, 29h, 00h
		db	0AAh, 2Ah, 29h, 00h, 50h, 55h
		db	 29h, 00h, 36h, 00h, 07h, 36h
		db	 01h, 00h, 07h, 36h, 00h, 29h
		db	 00h,0BFh,0FFh, 29h, 00h, 0Ch
		db	0ACh, 29h, 00h, 43h, 02h, 43h
		db	 02h,0AAh,0A3h,0AAh,0A4h, 00h
		db	 18h, 00h, 27h,0FFh, 0Fh,0FFh
		db	 0Fh,0FFh, 0Ch,0FFh, 0Ch,0FCh
		db	0C3h, 00h, 01h,0F1h, 40h, 29h
		db	 01h, 3Fh, 00h, 20h, 34h, 07h
		db	 4Bh, 07h, 00h, 63h,0E8h, 9Bh
		db	 03h, 01h, 44h,0D5h,0AAh,0FEh
		db	0AAh,0FEh, 55h, 7Ch, 55h, 7Ch
		db	0AAh,0F1h,0AAh,0F0h, 55h, 45h
		db	 55h, 45h,0AAh, 80h,0AAh, 80h
		db	 54h, 1Fh, 54h, 18h,0A1h,0FFh
		db	0A1h, 06h, 0Fh,0FFh, 08h,0ADh
		db	0BFh,0D5h,0A3h,0D4h, 7Eh, 8Fh
		db	 1Eh, 82h,0D1h, 3Fh, 51h, 2Fh
		db	 05h,0FFh, 04h, 38h, 36h, 00h
		db	0D5h, 85h, 36h, 00h, 0Bh, 2Ah
		db	 36h, 00h,0EDh,0E4h, 36h, 00h
		db	0BFh, 3Fh, 36h, 00h, 0Ah, 36h
		db	 02h,0EFh, 36h, 00h, 00h, 7Fh
		db	 36h, 00h, 1Bh,0F7h, 36h, 00h
		db	 6Eh, 36h, 01h, 9Bh, 5Fh, 36h
		db	 04h,0F7h,0FFh,0EAh,0F6h,0EAh
		db	0F0h,0FFh,0AFh,0FFh,0AFh,0FFh
		db	0FAh,0FFh,0FAh, 36h, 06h,0F5h
		db	 77h,0F5h, 77h,0EAh, 99h,0EAh
		db	 99h, 55h, 44h, 55h, 44h,0AAh
		db	0A8h,0AAh,0A8h, 55h, 41h, 55h
		db	 41h,0AAh, 87h,0AAh, 85h, 54h
		db	 1Fh, 54h, 1Ah,0A8h, 3Fh,0A8h
		db	 3Fh, 50h,0BFh, 50h,0BFh,0A2h
		db	0FFh,0A2h,0FFh, 47h,0FFh, 47h
		db	0FFh, 7Fh,0FFh, 45h, 77h, 36h
		db	 00h, 8Ah,0DFh, 36h, 00h, 56h
		db	 36h, 00h,0FEh,0BFh,0FEh,0FFh
		db	0E8h,0FFh,0E8h,0FDh, 47h,0FDh
		db	 45h,0FAh, 3Fh,0FAh, 35h,0DCh
		db	0FFh,0DCh,0EBh, 36h, 00h,0CFh
		db	 36h, 03h,0DAh,0AAh,0DAh,0AAh
		db	 40h, 00h, 40h, 00h, 3Fh,0FFh
		db	 22h,0B7h, 36h, 00h, 15h, 77h
		db	 36h, 00h, 56h,0DFh, 36h, 00h
		db	0BBh, 36h, 00h,0FAh,0FFh,0FAh
		db	0FDh, 55h,0FDh, 55h, 69h, 02h
		db	 01h, 55h, 01h, 55h,0E8h, 0Ah
		db	0E8h, 0Ah,0F5h, 50h,0F5h, 50h
		db	0E2h,0FAh,0E2h,0FAh, 47h,0D5h
		db	 47h,0D5h,0AAh,0A0h,0AAh,0A0h
		db	 55h, 21h, 55h, 22h, 92h, 43h
		db	 92h, 4Ch, 24h, 00h, 24h, 03h
		db	 40h, 07h, 40h, 07h, 00h, 5Eh
		db	 00h, 5Eh, 95h,0FFh, 95h, 36h
		db	 03h, 61h,0FFh, 99h,0FFh, 83h
		db	0FFh, 73h,0FFh, 07h,0FFh,0E7h
		db	0FFh, 06h,0EFh,0C6h,0EFh, 83h
		db	 7Bh, 83h, 7Bh, 41h, 37h, 41h
		db	 37h, 00h, 95h, 00h, 95h, 80h
		db	 12h, 80h, 12h, 8Fh,0FFh, 8Fh
		db	0FFh, 0Fh,0FFh, 0Fh,0FFh, 8Bh
		db	0FBh, 8Bh,0FBh, 05h, 59h, 05h
		db	 59h, 00h,0A8h, 00h,0A8h, 00h
		db	 05h, 00h, 05h, 29h, 06h,0CFh
		db	0FFh,0CFh,0B6h,0E3h,0FFh,0E3h
		db	 36h, 03h, 7Fh,0FCh, 7Fh,0FCh
		db	 2Ah,0FFh, 2Ah,0FFh, 00h, 12h
		db	 00h, 12h, 22h, 4Ah, 22h, 4Ah
		db	 29h, 02h,0FFh,0FAh,0FFh,0FAh
		db	0FFh, 50h,0FFh, 50h,0EAh, 03h
		db	0EAh, 03h, 90h, 55h, 90h, 55h
		db	0EAh,0AAh,0EAh,0AAh, 55h, 54h
		db	 55h, 54h,0A8h, 00h,0A8h, 29h
		db	 03h, 2Fh, 7Fh, 2Fh, 7Fh, 7Fh
		db	0FDh, 7Fh,0FDh,0FAh,0AAh,0FAh
		db	0AAh, 55h, 50h, 55h, 50h,0A8h
		db	 00h,0A8h, 29h, 01h, 01h,0D0h
		db	 00h, 0Ch, 1Fh, 03h, 00h, 60h
		db	0F4h, 1Fh,0DFh,0FFh,0DFh,0FFh
		db	 97h,0FFh, 97h,0FFh, 26h,0FEh
		db	 26h,0FEh, 0Ch,0FFh, 0Ch,0FFh
		db	 21h,0FEh, 21h,0FEh, 07h,0DCh
		db	 07h,0DCh, 1Fh, 35h, 1Fh, 35h
		db	 0Ch,0AAh, 8Ch,0AAh, 81h, 12h
		db	 81h, 12h, 80h, 02h, 80h, 02h
		db	 80h, 11h, 80h, 11h, 80h, 00h
		db	 80h, 00h, 80h, 00h, 80h, 00h
		db	 80h, 00h, 80h, 29h, 00h, 02h
		db	 29h, 04h, 4Eh,0FFh, 4Eh,0FFh
		db	 45h, 7Fh, 45h, 7Fh, 02h,0AFh
		db	 02h,0AFh, 21h, 55h, 21h, 55h
		db	 88h, 2Ah, 00h, 2Ah, 02h, 85h
		db	 00h, 85h, 08h,0A8h, 29h, 00h
		db	 22h, 25h, 29h, 00h,0AAh,0A8h
		db	0AAh,0A8h, 55h, 47h, 55h, 45h
		db	0AAh, 3Fh,0AAh, 22h, 54h,0FFh
		db	 54h,0CBh,0A3h,0FFh,0A3h,0FFh
		db	 47h,0FFh, 47h,0FFh, 8Fh,0FFh
		db	 8Fh,0FFh, 0Fh,0FFh, 0Fh, 36h
		db	 01h, 82h,0BBh, 36h, 00h, 07h
		db	 6Fh,0FFh,0E8h,0AFh,0E8h,0FEh
		db	 83h,0BEh, 82h,0FAh, 3Fh,0FAh
		db	 30h,0D9h,0FFh,0D9h, 82h,0CFh
		db	0FFh,0CEh, 0Ah,0E7h,0FFh,0E7h
		db	 5Dh, 36h, 02h,0FDh, 55h,0FDh
		db	 55h, 00h, 02h, 00h, 02h,0FFh
		db	0FCh, 15h, 74h, 36h, 00h,0AAh
		db	0DEh, 36h, 00h,0DEh, 36h, 01h
		db	0BBh, 36h, 04h,0EAh,0FFh,0EAh
		db	 62h, 02h, 69h, 02h, 05h, 55h
		db	 05h, 55h,0F0h, 02h,0F0h, 02h
		db	0FDh, 40h,0FDh, 40h,0FEh,0BAh
		db	0FEh,0BAh,0FDh, 5Fh,0FDh, 5Fh
		db	0AAh,0A0h,0AAh,0A0h, 55h, 52h
		db	 55h, 52h,0AAh,0A8h,0AAh,0A8h
		db	 55h, 10h, 55h, 10h,0A2h, 20h
		db	0A2h, 20h, 04h, 00h, 04h, 29h
		db	 03h,0F4h, 00h,0F4h, 00h, 7Fh
		db	0FFh, 7Fh,0FFh, 1Fh,0FFh, 1Fh
		db	0FFh, 0Fh,0FFh, 0Fh,0FFh, 26h
		db	0EFh, 26h,0EFh, 03h, 55h, 03h
		db	 55h, 00h, 1Ch, 00h, 23h, 00h
		db	0C0h, 00h, 3Fh, 0Ch, 02h, 0Dh
		db	0FAh,0AAh, 8Ah,0AAh, 8Ah, 45h
		db	 54h, 45h, 54h,0AAh, 88h,0AAh
		db	 88h, 45h, 14h, 45h, 14h, 8Ah
		db	 00h, 0Ah, 00h, 55h, 14h, 29h
		db	 00h,0AAh, 2Ah, 29h, 00h, 50h
		db	 55h, 29h, 00h, 8Bh,0FFh, 8Bh
		db	0FFh, 05h, 7Fh, 05h, 7Fh, 02h
		db	0ABh, 02h,0ABh, 00h, 15h, 00h
		db	 15h, 29h, 0Ah, 40h, 29h, 01h
		db	0FFh,0CFh,0FFh,0CFh, 7Fh,0F1h
		db	 7Fh,0F1h,0AFh,0FAh,0AFh,0FAh
		db	 62h, 02h, 69h, 02h, 01h, 55h
		db	 01h, 55h, 29h, 06h, 36h, 02h
		db	 7Fh,0FDh, 7Fh,0FDh, 00h, 8Ah
		db	 00h, 8Ah, 62h, 02h, 69h, 02h
		db	 55h, 40h, 55h

_370UNKN	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		inc	ax
		sub	[bx+di],ax
		add	[bx+di],bp
		add	ds:data_1e,bx
;*		jmp	far ptr loc_9		;*
sub_2		endp

		db	0EAh
		dw	55BFh, 555Fh		;  Fixup - byte match
			                        ;* No entry point to code
		pop	di
		stosb				; Store al to es:[di]
		scasw				; Scan es:[di] for ax
		stosb				; Store al to es:[di]
		scasw				; Scan es:[di] for ax
		push	bp
		push	sp
		push	bp
		push	sp
		test	al,0
		test	al,29h			; ')'
		add	ax,[bp+di]
		pop	es
		db	 60h,0C7h, 18h, 03h, 87h,0E3h
		db	0FFh, 55h,0FFh, 55h,0CFh,0FFh
		db	0CFh,0FFh, 99h,0FFh, 99h,0FFh
		db	 61h,0FFh, 61h,0FFh, 17h,0F3h
		db	 17h,0F3h,0BFh,0AFh,0BFh,0AFh
		db	0FCh, 55h,0FCh, 55h,0E2h,0A8h
		db	0E2h,0A8h,0F9h, 05h,0F9h, 65h
		db	0FCh, 82h,0FCh, 82h,0FEh, 01h
		db	0FEh, 01h,0F8h, 00h,0F8h, 00h
		db	0E0h, 00h,0E0h, 00h, 80h, 00h
		db	 80h, 29h, 00h, 02h, 29h, 04h
		db	 69h, 02h, 62h, 02h, 69h, 02h
		db	 62h, 02h, 69h, 02h, 55h, 54h
		db	 55h, 54h,0AAh,0A1h,0AAh,0A1h
		db	 55h, 0Fh, 55h, 0Dh,0AAh,0FEh
		db	0AAh,0FEh, 55h, 7Ch, 55h, 7Ch
		db	0AAh,0F1h,0AAh,0F0h, 55h, 40h
		db	 55h, 40h,0A0h, 3Fh,0A0h, 2Ah
		db	 1Fh,0FFh, 15h, 41h, 36h, 00h
		db	0AAh, 07h, 36h, 00h, 50h,0ADh
		db	0A8h, 7Fh,0A8h, 75h, 42h,0FFh
		db	 42h,0DAh, 8Bh,0FFh, 8Bh, 6Fh
		db	 1Fh,0FFh, 1Fh,0FFh, 1Fh,0FFh
		db	 1Fh,0FFh, 1Fh,0FFh, 1Fh,0FFh
		db	 17h,0FFh, 17h,0FFh, 0Ah,0FDh
		db	 0Ah,0FDh, 36h, 00h, 57h, 36h
		db	 00h,0D0h,0FFh,0D0h,0FDh, 1Fh
		db	0FDh, 18h,0B9h,0FFh,0B9h,0C5h
		db	0DFh,0FFh,0DFh,0AAh, 36h, 01h
		db	0F5h,0FFh,0BFh,0FFh,0BFh,0FFh
		db	 4Fh,0FFh, 4Fh, 36h, 02h, 00h
		db	 55h, 00h, 55h,0FFh, 82h, 2Ah
		db	 82h,0FFh,0FCh, 55h, 7Ch, 36h
		db	 00h,0BBh,0DFh, 36h, 00h, 6Fh
		db	 7Fh, 36h, 06h, 69h, 02h, 62h
		db	 02h, 69h, 02h, 15h, 55h, 15h
		db	 55h,0C0h,0AAh,0C0h,0AAh,0F4h
		db	 05h,0F4h, 05h,0FAh, 80h,0FAh
		db	 80h,0F5h,0FAh,0F5h,0FAh,0AAh
		db	0A0h,0AAh,0A0h, 55h, 51h, 55h
		db	 51h,0AAh,0A0h,0AAh,0A0h, 55h
		db	 40h, 55h, 40h,0A8h, 80h,0A8h
		db	 80h, 11h, 10h, 11h, 10h, 02h
		db	 20h, 02h, 20h, 29h, 02h, 7Fh
		db	0FFh, 7Fh,0FFh, 1Fh,0FFh, 1Fh
		db	0FFh, 0Fh,0FFh, 0Fh,0FFh, 26h
		db	0EFh, 26h,0EFh, 03h, 7Bh, 03h
		db	 7Bh, 01h, 37h, 01h, 37h, 00h
		db	 95h, 00h, 95h, 00h, 12h, 00h
		db	 12h,0AAh, 88h,0AAh, 88h, 45h
		db	 54h, 45h, 54h,0AAh, 88h,0AAh
		db	 88h, 45h, 14h, 45h, 14h, 8Ah
		db	 08h, 0Ah, 00h, 55h, 14h, 29h
		db	 00h,0AAh, 2Ah, 29h, 00h, 50h
		db	 55h, 29h, 00h, 02h,0BAh, 02h
		db	0BAh, 00h,0ADh, 00h,0ADh, 00h
		db	 2Ah, 00h, 2Ah, 00h, 01h, 00h
		db	 01h, 80h, 29h, 01h, 50h, 29h
		db	 01h,0AAh, 29h, 01h, 50h, 54h
		db	 29h, 10h, 02h, 29h, 01h, 03h
		db	 80h, 29h, 00h, 01h,0E0h, 29h
		db	 01h, 6Ah, 29h, 01h, 3Dh, 29h
		db	 01h, 07h, 29h, 01h, 01h
loc_5:
		sub	[di],bp
		pop	es
		add	[bx],al
		add	[si],bl
		add	[si],bl
		sub	[bp+si],dx
		pop	es
		std				; Set direction flag
		add	al,6Dh			; 'm'
;*		aad	7Bh			; '{' undocumented inst
		db	0D5h, 7Bh		;  Fixup - byte match
		add	ax,78h
		pop	es
		add	[bx],al
		add	[bx+si],dh
		sub	[bx+di],ax
		loopnz	$+2Bh			; Loop if zf=0, cx>0

		add	[bp+di],al
		retn
			                        ;* No entry point to code
		sub	[bx+si],ax
		push	ds
		mov	di,29h
		jmp	short $-1
			                        ;* No entry point to code
		sub	[bx+si],ax
		jg	loc_5			; Jump if >
		sub	[bx+si],ax
		std				; Set direction flag
		push	cx
		sub	[bx+si],ax
		adc	ax,2947h
		add	[si],cl
		sub	[bx+di],ax
		xor	[bx+di],ch
;*		add	ax,dx
		db	 01h,0D0h		;  Fixup - byte match
		sub	[bx+di],ax
		inc	ax
		sub	[di],ax
		adc	[bx+di],ch
;*		add	ax,sp
		db	 01h,0E0h		;  Fixup - byte match
		db	0C0h, 29h, 00h, 17h, 80h, 60h
		db	 00h, 60h, 29h, 01h,0BEh, 8Ah
		db	 06h, 8Ah, 94h,0EFh, 14h,0E1h
		db	 5Bh, 7Fh, 1Bh, 1Fh,0C7h,0F7h
		db	 87h,0F7h, 7Eh,0F1h, 7Eh,0F1h
		db	0F6h, 88h,0F6h, 88h,0D1h, 3Ch
		db	0D1h, 00h, 03h,0E0h, 02h, 20h
		db	0FFh, 38h, 87h, 38h,0FFh, 8Fh
		db	0FFh, 8Fh,0F5h,0EBh, 15h, 2Bh
		db	 7Fh,0FFh, 7Fh,0FFh, 9Ah, 00h
		db	 9Ah, 00h, 01h, 58h, 01h, 58h
		db	 3Ah,0DCh, 29h, 00h, 8Ch, 39h
		db	 53h, 09h, 01h,0EBh,0DCh, 2Bh
		db	0FFh, 56h, 03h, 56h,0ADh, 7Bh
		db	0ADh, 7Bh,0FFh,0CFh,0FFh,0CFh
		db	 03h,0F7h, 03h,0F7h,0A0h, 37h
		db	0ACh, 37h, 71h, 2Fh, 03h, 81h
		db	0F4h, 8Ah,0F4h, 8Ah,0A5h, 61h
		db	0A5h, 41h, 5Fh,0FCh, 5Fh, 08h
		db	 36h, 00h,0FDh,0F8h,0F4h,0F8h
		db	0F4h, 00h,0FFh, 05h,0FFh, 05h
		db	 27h,0AFh, 27h,0AFh,0F9h,0FFh
		db	 81h,0FFh,0BEh, 02h, 80h, 00h
		db	 54h, 0Eh, 51h, 80h, 17h, 78h
		db	 17h, 00h,0C2h,0D0h, 02h,0C0h
		db	 2Bh, 70h, 2Bh, 76h, 7Dh,0ADh
		db	 7Dh,0ACh,0F7h, 73h,0F7h, 73h
		db	0FFh,0DDh,0FFh,0DDh, 29h, 0Eh
		db	 30h, 29h, 01h,0E0h, 29h, 01h
		db	 40h, 29h, 01h, 81h, 80h,0B0h
		db	 29h, 00h, 6Fh, 29h, 01h,0D7h
		db	 29h, 01h, 6Dh, 29h, 01h, 91h
		db	 29h, 01h, 50h, 29h, 01h,0A0h
		db	 29h, 08h,0FFh,0DDh, 00h, 01h
		db	 4Ch, 4Ah, 29h, 18h, 02h,0D7h
		db	 02h,0D7h, 54h, 3Dh, 54h, 3Dh
		db	0AAh, 82h,0AAh, 82h, 75h, 54h
		db	 75h, 54h, 1Eh,0EAh, 1Eh,0EAh
		db	 03h,0DDh, 03h,0DDh, 00h, 6Eh
		db	 00h, 6Eh, 29h, 02h,0FFh,0FEh
		db	0FFh,0FEh, 36h, 06h, 3Fh,0FFh
		db	 3Fh,0FFh, 8Fh,0FFh, 8Fh,0FFh
		db	 53h,0FFh, 53h,0FFh,0ABh,0FFh
		db	0A8h,0FFh, 74h,0FFh, 74h, 3Fh
		db	0EFh, 00h,0E0h, 00h, 3Eh, 00h
		db	 38h, 00h,0CCh, 0Ch,0CDh, 80h
		db	0F6h,0F8h,0F6h, 00h,0E9h,0A0h
		db	0E9h, 80h,0FEh,0C1h,0FEh,0D8h
		db	0F7h, 6Fh,0F7h, 60h,0FDh,0B6h
		db	0FDh,0B0h, 00h,0FFh, 00h, 0Fh
		db	 00h, 7Fh, 00h, 07h, 00h, 7Fh
		db	 00h, 07h, 00h, 3Fh, 00h, 03h
		db	 00h, 1Fh, 00h, 01h, 00h, 0Fh
		db	 00h, 01h, 00h, 07h, 29h, 01h
		db	 03h, 29h, 00h,0FFh, 5Ch,0FFh
		db	 5Dh,0FDh,0A4h,0FDh,0A4h,0FFh
		db	0F7h,0FFh,0F7h,0FFh,0B3h,0FFh
		db	0B3h,0FEh,0FBh,0FEh,0FBh,0FFh
		db	0EDh,0FFh,0EDh,0FFh,0DAh, 7Fh
		db	0DAh,0FFh,0F7h, 7Fh,0F7h, 18h
		db	 00h, 80h, 00h,0F0h, 29h, 01h
		db	 40h, 29h, 01h, 03h, 80h, 60h
		db	 00h, 3Eh, 29h, 01h,0D8h, 00h
		db	0C0h, 00h,0C0h, 00h,0D8h, 00h
		db	 4Fh,0E0h, 40h, 29h, 00h, 03h
		db	 29h, 01h, 03h, 29h, 01h, 03h
		db	 29h, 01h, 01h, 29h, 01h, 01h
		db	 29h, 0Ch, 36h, 00h, 7Fh, 36h
		db	 00h,0F7h, 3Fh,0F7h,0FFh,0FDh
		db	 3Fh,0FDh,0FFh,0FBh, 1Fh,0FBh
		db	 36h, 00h, 0Fh, 36h, 00h,0FCh
		db	 0Fh,0FCh,0FFh,0EFh, 07h,0EFh
		db	 7Fh,0FBh, 07h,0FBh, 77h, 00h
		db	 70h, 00h,0B0h, 00h,0B6h, 00h
		db	 9Ch, 00h, 9Ch, 00h,0CDh,0F8h
		db	0CCh, 00h,0E7h, 60h,0E7h, 00h
		db	0DBh, 00h,0DBh, 30h,0EDh,0D1h
		db	0EDh,0C0h,0FEh,0CFh,0FEh,0C0h
		db	 7Fh,0FFh, 03h,0FFh, 3Fh,0FFh
		db	 01h,0FFh, 1Fh,0FFh, 00h,0FFh
		db	 1Fh,0FFh, 00h, 7Fh, 0Fh,0FFh
		db	 00h, 3Fh, 03h,0FFh, 00h, 3Fh
		db	 03h,0FFh, 00h, 3Fh, 03h,0FFh
		db	 00h, 1Fh,0DBh, 76h,0DBh, 70h
		db	0FDh, 90h,0FDh, 93h,0EFh, 5Ch
		db	0EFh, 5Ch,0F7h,0E7h,0F7h,0E7h
		db	0FEh,0D9h,0FEh,0D9h,0FFh,0BAh
		db	0FFh,0BAh, 36h, 03h,0FBh,0FFh
		db	0FBh, 29h, 06h,0F8h, 29h, 01h
		db	 60h, 29h, 01h, 03h, 00h, 60h
		db	 00h,0DEh, 08h,0C0h, 00h, 34h
		db	 38h, 30h, 00h, 2Ch,0F4h, 2Fh
		db	 00h, 38h, 20h, 29h, 00h,0E8h
		db	 30h, 29h, 00h,0F8h,0F0h,0FEh
		db	 04h, 57h,0F9h, 57h,0FCh,0FAh
		db	0AAh,0FAh,0AAh, 36h, 04h,0FEh
		db	0BFh, 36h, 01h,0C3h, 36h, 01h
		db	0F0h,0EFh,0FFh,0EFh,0FDh,0EFh
		db	0FFh,0EFh,0FFh, 57h,0FFh, 57h
		db	0FFh, 8Ah,0FFh, 8Ah,0FFh, 55h
		db	 57h, 55h, 57h, 69h, 00h, 29h
		db	 00h, 2Ah, 2Ah, 29h, 08h, 40h
		db	 29h, 01h,0C1h, 83h, 29h, 00h
		db	0E7h, 87h, 18h, 00h, 55h, 1Ah
		db	 55h,0C1h,0F5h, 60h,0F5h, 60h
		db	0FFh,0EAh,0FFh,0EAh, 00h, 38h
		db	 29h, 01h, 18h, 29h, 18h, 0Ch
		db	 29h, 00h, 10h, 04h, 29h, 00h
		db	 10h, 00h, 03h, 00h, 08h, 29h
		db	 01h, 08h, 00h, 81h, 00h, 10h
		db	 00h, 67h, 29h, 00h, 04h, 1Fh
		db	 00h, 80h, 03h, 7Bh, 29h, 00h
		db	 0Bh,0FDh, 10h, 01h, 4Fh,0FEh
		db	 29h, 00h, 3Fh,0B4h, 29h, 00h
		db	 7Fh,0D0h, 29h, 00h,0FEh, 29h
		db	 01h,0F4h, 29h, 01h, 50h, 29h
		db	 01h, 20h, 29h, 01h, 01h,0EDh
		db	 29h, 00h, 1Fh,0F6h, 29h, 00h
		db	 03h, 9Dh, 29h, 01h, 06h, 29h
		db	 01h, 04h, 29h, 01h, 04h, 29h
		db	 01h, 08h, 29h, 04h, 36h, 02h
		db	 62h, 02h, 3Eh,0BBh, 3Eh,0BBh
		db	 1Fh,0FFh, 1Fh,0FFh, 7Fh,0FFh
		db	 7Fh, 36h, 0Bh, 80h, 07h, 80h
		db	 07h,0EDh,0FCh,0EDh,0FCh, 57h
		db	0BFh, 57h,0BFh, 15h, 55h, 15h
		db	 55h, 03h, 55h, 03h, 55h, 00h
		db	 1Dh, 00h, 1Dh, 29h, 06h, 36h
		db	 0Ah, 7Fh,0FFh, 47h,0FFh,0A7h
		db	0FFh,0A0h,0FFh, 01h,0FFh, 00h
		db	 1Fh, 00h, 3Fh, 00h, 01h, 00h
		db	 03h, 29h, 08h, 20h, 29h, 01h
		db	0F0h, 29h, 01h, 60h,0C0h, 40h
		db	 00h,0FDh,0E0h,0FCh, 00h, 2Bh
		db	 98h, 2Bh, 80h, 8Eh, 73h, 8Eh
		db	 70h, 7Fh,0FFh, 0Fh,0FFh, 3Fh
		db	0FFh, 01h,0FFh, 0Fh,0FFh, 00h
		db	 3Fh, 03h,0FFh, 00h, 0Fh, 00h
		db	0FFh, 00h, 03h, 00h, 3Fh, 00h
		db	 01h, 00h, 0Fh, 29h, 01h, 03h
		db	 29h, 00h, 36h, 02h, 09h,0FFh
		db	 09h,0FFh, 7Eh, 0Fh, 7Eh, 0Fh
		db	 57h,0E8h, 57h,0E8h, 62h, 03h
		db	 5Ah, 55h, 5Ah, 29h, 06h,0C2h
		db	 29h, 01h,0CFh, 00h,0C0h, 00h
		db	 7Ch, 08h, 7Ch, 00h,0DFh,0BCh
		db	0DFh, 80h,0ADh,0F4h,0ADh,0F0h
		db	0F5h, 2Ch,0F5h, 2Ch,0FEh,0A7h
		db	0FEh,0A7h,0FFh,0DAh,0FFh,0DAh
		db	 36h, 00h, 0Fh,0FFh, 7Fh,0FFh
		db	 0Fh,0FFh, 3Fh,0FFh, 03h,0FFh
		db	 1Fh,0FFh, 03h,0FFh, 0Fh,0FFh
		db	 00h,0FFh, 07h,0FFh, 00h, 3Fh
		db	 03h,0FFh, 00h, 03h, 00h,0FFh
		db	 29h, 10h, 10h, 29h, 01h,0F0h
		db	 29h, 01h, 39h, 29h, 01h,0F0h
		db	0C0h,0F0h, 29h, 10h, 01h, 29h
		db	 00h, 07h,0FDh, 04h, 6Dh,0D5h
		db	 7Bh, 05h, 78h,0F5h, 47h,0F5h
		db	 47h, 02h, 39h, 02h, 09h,0D5h
		db	0EBh,0D4h, 2Bh,0FFh, 56h, 03h
		db	 56h,0ADh, 7Bh,0ADh, 7Bh,0FFh
		db	0CFh,0FFh,0CFh, 03h,0F7h, 03h
		db	0F7h,0A0h, 37h,0ACh, 37h, 71h
		db	 2Fh, 03h, 81h, 29h, 07h, 01h
		db	 29h, 01h, 04h, 00h, 03h, 00h
		db	 10h, 00h, 0Fh, 00h, 60h, 00h
		db	 1Dh, 03h, 29h, 00h,0FAh, 29h
		db	 00h, 0Fh,0F4h, 29h, 13h, 02h
		db	 00h, 05h, 00h, 18h, 00h, 47h
		db	 01h, 29h, 00h,0F0h, 66h, 08h
		db	 10h, 00h, 66h, 38h, 10h, 00h
		db	0F5h, 4Ch,0F5h, 40h,0FFh,0FDh
		db	0FFh,0FDh, 36h, 00h, 01h,0C4h
		db	0FFh,0FEh, 18h,0BAh,0FFh,0FEh
		db	0FFh, 89h, 00h,0F5h,0FEh,0F5h
		db	 29h, 06h, 01h, 80h, 29h, 01h
		db	0C0h, 29h, 01h, 61h, 29h, 01h
		db	 71h, 29h, 01h, 39h, 29h, 01h
		db	 3Bh, 29h, 02h,0EDh,0FFh, 29h
		db	 00h, 3Fh,0FFh, 29h, 00h, 43h
		db	0FFh, 29h, 00h,0A8h,0FFh, 29h
		db	 00h, 55h, 7Fh, 29h, 00h,0AAh
		db	 9Eh, 29h, 00h, 55h, 4Dh, 40h
		db	 00h,0AAh,0ABh, 29h, 16h, 30h
		db	 29h, 01h, 63h, 29h, 02h, 37h
		db	 29h, 01h, 35h, 29h, 01h, 14h
		db	 00h, 14h, 00h, 7Bh, 00h, 0Bh
		db	 01h,0E3h, 00h, 23h, 03h, 82h
		db	 00h,0B8h, 0Fh, 32h, 01h, 08h
		db	 1Ch, 86h, 04h, 30h,0EAh,0AFh
		db	 0Ah,0AFh, 88h, 02h, 08h, 02h
		db	0BFh,0FFh,0A4h, 6Fh,0FDh, 14h
		db	0FDh, 14h, 7Eh, 65h, 7Eh, 65h
		db	0B9h, 81h,0B9h, 81h,0BEh, 2Eh
		db	0BEh, 2Eh,0ABh,0CBh,0ABh,0CAh
		db	 29h, 13h, 01h, 29h, 01h, 01h
		db	 29h, 01h, 03h, 00h, 01h, 3Bh
		db	 0Dh, 08h, 01h, 38h, 37h, 0Bh
		db	 07h, 38h,0EEh, 18h, 0Eh, 6Fh
		db	0ABh, 6Fh,0ABh,0FAh,0DCh, 3Ah
		db	0DCh,0FFh, 68h,0FFh, 68h,0DDh
		db	0A5h,0DDh,0A0h,0FDh, 17h,0FDh
		db	 29h, 03h, 60h, 29h, 01h,0E3h
		db	 00h, 08h, 00h, 54h, 80h, 54h
		db	 80h,0EEh, 40h,0EEh, 40h,0F7h
		db	 40h,0F7h, 40h,0F6h, 40h,0F6h
		db	 40h,0EAh, 80h,0EAh, 80h, 00h
		db	 06h, 29h, 01h, 07h, 00h, 01h
		db	 00h, 1Fh, 00h, 03h, 00h, 0Fh
		db	 00h, 0Fh, 00h, 2Bh, 00h, 0Bh
		db	 02h,0EFh, 00h, 0Fh,0AFh,0F6h
		db	 00h, 06h,0FEh,0A3h, 00h, 03h
		db	0AAh, 7Eh,0AAh, 00h,0D1h,0F4h
		db	0D0h, 00h,0A3h,0D8h,0A0h, 00h
		db	 67h,0A8h, 60h, 00h, 8Fh,0A0h
		db	 80h, 00h, 5Eh, 80h, 40h, 00h
		db	0BDh,0C0h, 80h, 00h,0A4h, 50h
		db	 80h, 29h, 17h, 10h, 29h, 01h
		db	 30h, 20h, 29h, 00h, 55h, 64h
		db	 55h, 64h,0ABh, 37h,0ABh, 37h
		db	 35h, 55h, 35h, 55h,0C7h,0FFh
		db	 07h,0FFh, 2Bh,0FFh, 2Bh,0FFh
		db	 7Fh,0FFh, 7Fh, 36h, 03h, 5Dh
		db	0FFh, 5Dh,0FFh,0E8h, 78h, 84h
		db	 00h,0FFh,0FEh,0FFh,0FEh, 62h
		db	 02h,0FFh,0B2h,0FFh,0B2h, 36h
		db	 0Eh, 68h, 70h, 03h, 00h,0EAh
		db	0E3h,0EAh, 08h, 5Fh,0FFh, 5Fh
		db	0FFh,0EAh,0AAh,0EAh,0AAh,0DBh
		db	0B6h,0DBh,0B6h,0FFh,0EDh,0FFh
		db	0EDh, 36h, 04h,0A5h,0FFh,0E1h
		db	 82h, 29h, 00h,0E3h, 46h, 08h
		db	 00h, 7Ah, 8Eh, 7Ah,0A0h,0ABh
		db	0F6h,0ABh,0F6h, 5Dh, 5Bh, 5Dh
		db	 5Bh,0DAh, 95h,0DAh, 95h,0FFh
		db	0F6h,0FFh,0F6h, 36h, 02h, 29h
		db	 06h,0C0h, 80h, 29h, 00h, 86h
		db	 80h,0B0h, 00h,0CFh, 8Eh,0C0h
		db	 60h, 5Fh,0FDh, 5Fh,0FCh, 6Ah
		db	0ABh, 6Ah,0ABh, 33h,0B6h, 33h
		db	0B6h, 29h, 0Ah, 40h, 29h, 01h
		db	0C0h, 20h, 29h, 00h, 42h, 60h
		db	 38h, 00h,0FCh,0E0h,0FCh, 0Ch
		db	0ABh,0F3h,0ABh,0F0h, 29h, 12h
		db	 20h, 42h, 29h, 00h,0E0h,0E2h
		db	 29h, 00h, 63h,0A6h, 18h, 00h
		db	0FEh,0AAh,0FEh,0AAh, 39h, 57h
		db	 39h, 57h, 00h, 1Bh, 00h, 1Bh
		db	 29h, 12h,0AAh,0EEh,0AAh,0EEh
		db	 62h, 02h,0EAh, 94h,0EAh, 94h
		db	 29h, 12h,0AAh,0AFh,0AAh,0A0h
		db	 50h, 00h, 50h, 29h, 17h, 36h
		db	 00h, 00h, 0Ah, 15h,0BFh, 29h
		db	 01h, 02h, 29h, 14h, 36h, 00h
		db	 9Fh, 36h, 01h, 02h, 7Fh,0CFh
		db	0FFh, 00h, 0Fh, 05h,0BFh, 29h
		db	 01h, 1Bh, 29h, 01h, 01h, 29h
		db	 08h, 96h, 02h,0FFh,0FEh,0FFh
		db	0FEh, 36h, 08h, 0Fh,0FFh,0BFh
		db	0FFh, 00h, 5Fh, 1Bh,0FFh, 00h
		db	 07h, 02h,0FFh, 29h, 00h,0A3h
		db	 5Bh,0A3h, 5Bh,0F6h,0CEh,0F6h
		db	0CEh,0DFh,0F6h,0DFh,0F6h, 36h
		db	 10h, 3Fh, 36h, 05h, 67h, 36h
		db	 01h, 24h, 0Ch, 36h, 00h,0CAh
		db	 3Ch, 36h, 00h,0F7h, 91h, 36h
		db	 02h, 5Dh,0FFh, 5Dh,0FFh, 69h
		db	 00h, 2Ah,0AAh, 29h, 14h,0FAh
		db	 80h, 29h, 00h,0FEh, 7Ah, 29h
		db	 00h, 01h,0FDh, 29h, 00h,0BCh
		db	 29h, 01h, 0Bh, 29h, 02h,0C0h
		db	 00h, 40h, 00h, 20h, 00h, 20h
		db	 29h, 01h, 20h, 29h, 08h,0C0h
		db	 29h, 01h,0E0h, 29h, 01h,0D0h
		db	 29h, 01h,0E8h, 29h, 01h,0E8h
		db	 29h, 01h,0D4h, 21h, 29h, 00h
		db	0F4h,0F3h, 29h, 00h,0E9h, 81h
		db	 00h, 0Dh, 29h, 00h, 55h, 07h
		db	 29h, 00h, 0Ah,0A8h, 29h, 00h
		db	 03h, 55h, 10h, 00h, 02h,0AEh
		db	 10h, 40h, 00h, 35h, 18h, 60h
		db	 00h, 0Ah, 38h, 60h, 00h, 0Dh
		db	 70h,0E0h, 0Dh, 02h,0BEh,0F6h
		db	0BEh,0F6h, 78h, 6Ah, 78h, 00h
		db	0D1h,0D6h,0D0h, 00h, 0Fh,0A8h
		db	 29h, 00h, 5Fh,0A0h, 29h, 00h
		db	0BDh, 40h, 29h, 00h,0FAh, 29h
		db	 01h,0D0h, 29h, 11h, 04h, 29h
		db	 01h, 1Ch, 08h, 29h, 00h, 38h
		db	 38h, 80h, 00h,0A8h,0E8h,0A6h
		db	 29h, 04h, 08h, 29h, 05h,0C0h
		db	 29h, 04h, 0Ch, 29h, 01h, 10h
		db	 29h, 01h, 40h, 29h, 02h, 02h
		db	 29h, 01h, 04h, 29h, 01h, 30h
		db	 29h, 00h, 02h, 80h, 29h, 00h
		db	 0Bh, 00h, 01h, 00h, 55h, 29h
		db	 01h, 3Ah, 00h, 18h, 00h,0E8h
		db	 00h, 40h, 00h, 01h, 57h, 29h
		db	 00h, 0Bh,0BEh, 00h, 80h, 1Eh
		db	0BAh, 04h, 90h, 57h,0F4h, 01h
		db	 60h, 17h,0F4h, 05h,0C0h, 7Dh
		db	0D8h, 18h, 80h, 3Ah,0C0h, 29h
		db	 00h,0D4h, 29h, 01h, 0Bh,0B2h
		db	 29h, 00h, 3Fh,0ACh, 00h, 08h
		db	 5Dh, 71h, 00h, 20h, 6Fh,0A6h
		db	 01h, 80h,0EFh, 4Eh, 0Eh, 00h
		db	0FDh,0B8h, 14h, 80h,0FFh,0E4h
		db	 6Ah, 00h,0EEh,0B0h, 6Ch, 29h
		db	 10h, 01h, 29h, 01h, 01h, 29h
		db	 01h, 0Bh, 00h, 01h, 00h, 17h
		db	 00h, 03h, 0Ch, 00h, 03h,0CFh
		db	 20h, 00h, 1Fh, 3Fh, 29h, 00h
		db	0FCh,0FFh, 29h, 00h,0F3h,0EFh
		db	 29h, 00h,0CFh,0BFh, 29h, 00h
		db	 3Ah,0FFh, 29h, 00h,0E7h,0FFh
		db	 29h, 00h,0BFh,0EAh, 29h, 07h
		db	 05h, 00h, 0Ah, 00h,0C0h, 01h
		db	 3Eh, 08h, 00h, 37h,0C1h, 40h
		db	 00h,0B0h, 3Fh, 29h, 00h, 0Fh
		db	0FFh, 29h, 00h, 36h, 00h, 29h
		db	 00h,0FDh, 55h, 29h, 00h,0B8h
		db	0E0h, 29h, 00h, 46h, 01h, 29h
		db	 00h, 80h, 29h, 01h, 38h, 15h
		db	 29h, 00h, 0Ah,0AAh, 29h, 00h
		db	 55h, 01h, 29h, 00h,0A1h,0FFh
		db	 03h, 29h, 02h, 04h, 29h, 01h
		db	 03h, 29h, 08h, 40h, 31h, 29h
		db	 00h, 10h,0C5h, 29h, 00h, 11h
		db	 74h, 29h, 0Ch, 40h, 29h, 01h
		db	0C0h, 04h, 29h, 00h, 40h, 0Ch
		db	 29h, 00h, 01h, 1Fh, 29h, 00h
		db	 43h,0D7h, 29h, 02h, 36h, 00h
		db	 29h, 00h,0FFh, 97h, 29h, 00h
		db	0FEh,0FBh, 29h, 00h, 4Dh,0FFh
		db	 29h, 00h,0F9h,0FFh, 29h, 00h
		db	0F5h
loc_6:
                           lock	sub	[bx+si],ax
;*		loopnz	locloop_7		;*Loop if zf=0, cx>0

		db	0E0h, 1Ah		;  Fixup - byte match
		sub	[bx+si],ax
		xchg	bp,ax
		inc	ax
		mov	di,data_12e
		add	ds:data_11e[bx],ch
;*		add	bh,ch
		db	 00h,0EFh		;  Fixup - byte match
		mov	al,byte ptr ds:[2]
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		add	byte ptr [bp+si],0
		mov	si,data_10e
		add	ss:data_9e[bp],bh
		add	ss:data_5[bp+si],bh
		cli				; Disable interrupts
		sub	[bp+di],ax
		inc	ax
		or	bp,[bx+di]
		add	[bx+di],bl
		lodsw				; String [si] to ax
		sub	[bx+si],ax
		in	al,29h			; port 29h ??I/O Non-standard
		add	[di],ax
		push	bp
		sub	[bx+si],ax
		push	bp
		sub	byte ptr [bx+di],1
		jmp	dword ptr [bx+di]	;*
		db	 00h, 36h, 00h, 29h, 00h,0FFh
		db	0C6h, 00h, 40h, 29h, 00h, 04h
		db	 01h, 29h, 01h, 14h, 29h, 00h
		db	0D0h, 17h, 00h, 02h,0F4h, 4Fh
		db	 29h, 00h,0DFh,0FFh, 82h, 0Eh
		db	 36h, 00h, 0Ah, 08h,0FFh,0D7h
		db	0A0h, 80h, 05h, 7Eh, 29h, 00h
		db	 57h,0F7h, 03h, 80h, 7Fh, 7Fh
		db	 29h, 00h,0F7h, 7Fh, 80h, 0Eh
		db	0F7h,0FFh, 02h, 28h,0FFh,0FDh
		db	 20h,0B0h,0FFh, 77h,0B8h, 00h
		db	 75h,0DFh, 20h, 00h,0EAh,0A8h
		db	0EAh,0ABh,0FFh,0F5h,0FFh,0F5h
		db	 36h, 00h,0CCh,0E6h, 36h, 00h
		db	 00h, 06h, 36h, 00h, 9Ch, 4Fh
		db	 36h, 06h,0BBh,0EFh,0BBh,0EFh
		db	0FBh,0FBh, 00h, 80h,0FFh,0FBh
		db	 22h, 80h,0DFh,0BDh, 0Bh, 20h
		db	0FEh,0BAh, 28h, 00h,0EBh,0EAh
		db	 29h, 00h,0BBh,0A6h, 29h, 00h
		db	0AAh,0ABh, 29h, 00h,0BAh,0AFh
		db	 20h, 00h,0E8h, 29h, 01h,0AAh
		db	 29h, 01h,0EBh, 72h, 00h, 00h
		db	0AFh,0CCh, 02h, 00h,0BEh,0E0h
		db	 29h, 00h,0EFh,0A2h, 08h, 00h
		db	0BFh,0BBh, 2Eh, 00h,0EEh,0FFh
		db	 08h, 29h, 03h, 10h, 29h, 09h
		db	 10h, 80h, 29h, 04h,0D0h, 29h
		db	 01h, 0Ch, 29h, 02h, 14h, 00h
		db	 6Bh, 11h, 00h, 2Eh,0F0h, 80h
		db	 00h, 78h, 0Fh, 29h, 00h, 07h
		db	0FFh, 29h, 00h, 36h, 00h, 29h
		db	 00h, 36h, 00h, 29h, 00h, 36h
		db	 00h, 29h, 00h,0FFh,0FEh, 29h
		db	 0Fh, 02h, 29h, 01h, 08h, 29h
		db	 01h, 20h, 29h, 01h, 82h, 29h
		db	 02h, 36h, 00h, 29h, 00h, 36h
		db	 00h, 29h, 00h, 36h, 00h, 29h
		db	 00h,0FFh,0FDh, 29h, 00h,0FEh
		db	 29h, 01h, 02h,0AAh, 29h, 00h
		db	0A8h, 29h, 01h, 03h, 37h,0B0h
		db	 3Eh, 00h, 08h, 0Ah,0BAh, 29h
		db	 00h,0ABh,0E8h, 29h, 00h,0FFh
		db	 80h, 28h, 00h,0EAh, 29h, 01h
		db	0A2h, 29h, 01h, 08h, 29h, 01h
		db	 30h, 29h, 18h, 7Fh, 00h, 0Ch
		db	 0Fh,0F0h, 16h, 00h,0E9h, 03h
		db	 00h, 8Ah, 29h, 01h, 2Bh, 29h
		db	 01h, 2Fh, 29h, 01h,0AFh, 29h
		db	 00h, 08h,0BFh, 00h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		or	[bp+si],ah
		mov	di,2C00h
		xor	bh,dh
		sub	[bx+si],ax
		aas				; Ascii adjust
		db	0FEh, 29h, 00h,0FFh,0A3h, 29h
		db	 00h,0FEh,0AEh, 29h, 00h,0FAh
		db	 08h, 80h, 00h,0E8h, 30h, 29h
		db	 00h,0A0h,0C0h, 29h, 00h,0CFh
		db	 29h, 01h, 20h, 29h, 01h, 80h
		db	 29h, 11h, 75h, 13h, 8Ah,0ECh
		db	 29h, 00h,0FCh, 29h, 01h, 03h
		db	0FFh, 29h, 00h, 36h, 00h, 29h
		db	 0Bh, 0Dh, 05h, 52h,0D2h, 40h
		db	 2Dh,0BFh, 29h, 01h, 0Fh, 29h
		db	 00h,0FFh,0F1h, 29h, 00h,0FDh
		db	 1Fh, 29h, 0Ah, 21h, 00h, 4Ch
		db	 50h, 29h, 00h, 36h, 00h, 29h
		db	 00h,0BBh,0FFh, 29h, 00h,0FAh
		db	0A0h, 29h, 02h, 2Fh,0EAh, 02h
		db	 00h,0AFh,0E8h, 29h, 00h,0FFh
		db	0E8h, 03h, 00h,0EFh,0FAh, 03h
		db	 80h, 36h, 00h, 08h, 00h, 36h
		db	 00h, 0Eh, 20h, 36h, 00h, 2Fh
		db	 88h,0FFh,0FBh, 22h, 82h, 30h
		db	 29h, 01h, 60h, 00h, 20h, 00h
		db	0E0h, 00h, 20h, 00h
data_7		db	0E0h			; Data table (indexed access)
		db	 00h, 60h, 00h,0D0h, 00h, 50h
		db	 00h,0AAh, 00h,0AAh, 00h, 5Bh
		db	 00h, 5Bh, 00h, 09h, 28h, 09h
		db	 28h, 29h, 06h, 20h, 29h, 01h
		db	 80h, 29h, 01h,0C0h, 08h, 29h
		db	 00h, 80h, 29h, 01h,0B8h, 30h
		db	 29h, 00h,0FAh,0E8h, 29h, 01h
		db	 9Bh, 29h, 00h, 0Ah,0BEh, 00h
		db	 02h, 2Fh,0FFh, 00h, 68h, 7Fh
		db	0FFh, 0Dh,0ABh, 36h, 00h, 1Fh
		db	0F5h,0DFh,0FFh, 05h, 5Dh, 3Ah
		db	0AFh, 29h, 00h, 05h, 75h, 29h
		db	 00h, 28h, 01h, 29h, 00h, 80h
		db	 15h, 29h, 01h,0BFh, 29h, 00h
		db	0FBh, 7Bh,0A0h, 2Bh, 36h, 00h
		db	0AEh, 6Fh,0FBh,0FFh,0C0h, 15h
		db	0A8h, 3Fh, 29h, 04h, 08h, 29h
		db	 01h,0F7h, 80h, 29h, 00h,0EFh
		db	0F8h, 00h, 80h, 36h, 00h, 15h
		db	 14h,0FFh,0FEh,0AFh, 6Eh, 36h
		db	 00h, 93h,0AAh,0FFh,0FBh, 04h
		db	 40h,0F7h,0ACh, 29h, 04h,0E8h
		db	 29h, 01h, 40h, 29h, 01h, 97h
		db	 34h, 29h, 00h, 36h, 00h,0BCh
		db	0ACh,0D7h, 2Bh, 29h, 00h,0B9h
		db	 29h, 15h,0BDh,0D5h, 29h, 14h
		db	 04h,0BDh, 29h, 00h, 13h, 7Bh
		db	 00h, 2Bh, 57h,0FFh, 06h, 6Fh
		db	 07h,0FFh, 00h, 15h, 00h, 2Dh
		db	 29h, 0Ch, 45h, 50h, 29h, 00h
		db	 36h, 00h, 98h, 44h, 36h, 00h
		db	 22h, 79h,0D5h, 75h, 29h, 00h
		db	 28h,0A8h, 29h, 09h, 55h, 29h
		db	 00h, 55h,0FFh, 00h,0A5h, 36h
		db	 00h,0D5h, 7Ah, 36h, 00h,0D7h
		db	 77h, 36h, 00h, 3Dh,0D0h,0B7h
		db	0FFh, 01h,0A0h, 55h, 6Ah, 29h
		db	 08h,0EAh, 80h, 29h, 00h,0FFh
		db	0A8h, 1Ch, 00h,0FFh,0DBh,0A0h
		db	 00h,0B9h, 50h, 29h, 00h, 04h
		db	 29h, 15h,0ABh,0B4h, 01h, 29h
		db	 1Eh, 03h, 00h, 2Ch, 00h,0D3h
		db	 0Bh, 00h, 34h,0E0h,0C0h, 00h
		db	 2Ch, 1Fh, 29h, 09h, 0Bh, 00h
		db	0A9h, 0Fh, 56h,0CCh, 00h, 33h
		db	 80h, 29h, 00h,0C0h, 7Fh, 29h
		db	 00h, 3Fh,0FFh, 29h, 00h, 36h
		db	 00h, 29h, 05h, 2Dh, 17h, 20h
		db	 68h,0DFh, 29h, 00h,0F0h, 04h
		db	 29h, 00h, 1Fh,0FFh, 29h, 00h
		db	 36h, 00h, 29h, 00h, 36h, 00h
		db	 29h, 00h, 36h, 00h, 29h, 01h
		db	 0Ah, 49h,0E4h,0B6h, 1Bh, 29h
		db	 00h,0A8h, 29h, 01h, 36h, 00h
		db	 29h, 00h, 36h, 00h, 29h, 00h
		db	 36h, 00h, 29h, 00h, 36h, 00h
		db	 29h, 00h, 36h, 00h,0BBh, 48h
		db	 44h,0B5h, 29h, 01h,0FFh, 29h
		db	 00h,0FFh,0E0h, 29h, 00h, 36h
		db	 00h, 29h, 00h,0FAh,0FCh, 29h
		db	 00h, 9Fh,0C0h, 29h, 00h,0FCh
		db	 29h, 01h,0C0h, 29h, 01h, 40h
		db	 29h, 01h,0FEh,0D0h, 29h, 00h
		db	 7Fh,0FFh, 29h, 00h,0FDh, 94h
		db	 29h, 18h,0C0h, 29h, 01h,0BCh
		db	 29h, 01h, 0Bh, 29h, 02h,0C0h
		db	 00h, 40h, 00h, 20h, 00h, 20h
		db	 29h, 02h, 36h, 00h, 29h, 00h
		db	0FFh,0BCh, 29h, 00h,0FFh, 70h
		db	 29h, 00h,0FEh,0E0h, 00h, 04h
		db	0FEh,0C0h, 00h, 0Eh,0FDh,0C0h
		db	 00h, 0Ah,0FDh, 80h, 00h, 18h
		db	0FDh, 83h, 29h, 0Fh, 01h, 00h
		db	 02h, 00h, 04h, 00h, 0Bh, 00h
		db	 10h, 00h, 2Dh, 00h, 40h, 00h
		db	0B4h, 00h, 32h, 00h, 0Dh, 01h
		db	0C0h, 02h, 34h, 0Ch, 00h, 13h
		db	0A1h, 20h, 00h, 5Dh, 0Fh, 29h
		db	 00h,0E8h,0FFh, 29h, 00h,0A7h
		db	0FFh, 29h, 00h, 1Fh,0FFh, 29h
		db	 00h, 36h, 00h, 29h, 00h, 43h
		db	0FFh, 29h, 00h, 3Fh,0FFh, 29h
		db	 00h, 36h, 00h, 29h, 00h, 36h
		db	 00h, 29h, 00h, 36h, 00h, 29h
		db	 00h, 36h, 00h, 29h, 00h, 36h
		db	 00h, 29h, 00h,0FFh,0BFh, 29h
		db	 00h
		db	'6', 0
		db	')', 0
		db	'6', 0
		db	')', 0
		db	'6', 0
		db	')', 0
		db	'6', 0
		db	')', 0
		db	'6', 0
		db	')', 0
		db	'6', 0
		db	')', 0
		db	'6', 0
		db	')', 0
		db	'6', 0
		db	')', 0
		db	'6', 0
		db	')', 0
		db	0FFh,0BCh, 29h, 00h,0FFh, 70h
		db	 29h, 00h,0FEh,0E0h, 29h, 00h
		db	0FEh,0C0h, 29h, 00h,0FDh,0C0h
		db	 29h, 00h,0FDh, 80h, 29h, 00h
		db	0FDh, 80h, 29h, 13h, 01h, 00h
		db	 02h, 00h, 04h, 00h, 03h, 00h
		db	 08h, 00h, 07h, 01h, 80h, 02h
		db	 6Bh, 06h, 00h, 09h,0A7h, 04h
		db	 00h, 1Bh, 5Fh, 28h, 00h, 56h
		db	0BFh, 60h, 00h, 9Ah, 7Fh, 80h
		db	 00h, 74h,0FFh, 29h, 00h,0EBh
		db	0FAh, 29h, 00h,0D7h,0EFh, 29h
		db	 00h, 36h, 00h, 29h, 00h, 36h
		db	 00h, 29h, 00h, 36h, 00h, 29h
		db	 00h, 36h, 00h, 29h, 00h, 36h
		db	 00h, 29h, 00h, 36h, 00h, 29h
		db	 00h,0FFh,0FEh, 29h, 00h,0BFh
		db	0D0h, 29h, 00h,0FFh,0FDh, 29h
		db	 00h,0FFh,0EFh, 29h, 00h,0FFh
		db	0FBh, 29h, 00h,0FFh,0FBh, 29h
		db	 00h,0FFh,0FDh, 29h, 00h,0FAh
		db	 80h, 29h, 00h, 80h, 7Ah, 29h
		db	 00h, 62h, 00h, 29h, 00h, 36h
		db	 00h, 29h, 00h, 36h, 00h, 29h
		db	 00h, 36h, 00h, 29h, 00h,0FDh
		db	 50h, 29h, 00h,0A0h, 0Fh, 29h
		db	 00h, 1Ah,0AAh, 29h, 00h,0AAh
		db	 80h, 29h, 01h, 3Fh, 29h, 00h
		db	 36h, 00h, 29h, 00h,0FFh,0FDh
		db	 29h, 00h,0EDh, 40h, 29h, 01h
		db	 3Dh, 29h, 00h, 55h, 28h, 29h
		db	 00h, 94h, 1Fh, 29h, 00h, 0Fh
		db	0FFh, 29h, 00h, 36h, 00h, 29h
		db	 00h, 36h, 00h, 29h, 00h,0B7h
		db	 77h, 29h, 01h, 02h, 29h, 00h
		db	 55h, 54h, 29h, 00h, 08h, 01h
		db	 29h, 00h, 36h, 00h, 29h, 00h
		db	 36h, 00h, 29h, 00h,0FFh,0FEh
		db	 29h, 00h,0FFh, 29h, 01h,0BFh
		db	 80h, 29h, 00h, 55h,0C0h, 29h
		db	 00h,0AAh,0B4h, 29h, 00h, 62h
		db	 00h, 29h, 00h,0FAh,0ABh, 29h
		db	 00h,0FDh, 54h, 29h, 00h,0F7h
		db	 29h, 15h,0D0h, 29h, 01h, 3Ch
		db	 29h, 04h, 10h, 00h, 0Eh, 00h
		db	 20h, 00h, 5Dh, 00h, 40h, 00h
		db	0BAh, 01h, 29h, 00h,0F5h, 06h
		db	 00h, 01h,0EBh, 08h, 00h, 07h
		db	0D6h, 10h, 00h, 0Fh,0ABh, 10h
		db	 00h, 2Fh, 5Fh, 29h, 00h, 8Fh
		db	0E7h, 29h, 00h, 39h,0EBh, 29h
		db	 00h,0FFh, 5Ah, 29h, 00h,0EFh
		db	0A1h, 29h, 00h,0BFh, 1Ah, 29h
		db	 00h, 74h,0EAh, 29h, 00h,0D3h
		db	 54h, 29h, 00h,0CCh,0A3h, 29h
		db	 00h,0FAh, 1Ah, 29h, 00h,0A1h
		db	0D5h, 29h, 00h, 1Ah,0A1h, 29h
		db	 00h,0D5h, 1Fh, 29h, 00h,0A8h
		db	0FFh, 29h, 00h, 8Fh,0FFh, 29h
		db	 00h, 4Fh,0FFh, 29h, 00h,0F6h
		db	 39h, 29h, 00h,0AAh, 03h, 29h
		db	 00h, 03h,0FFh, 29h, 00h, 36h
		db	 00h, 29h, 00h, 36h, 00h, 29h
		db	 00h, 36h, 00h, 29h, 00h,0F7h
		db	0F3h, 29h, 00h, 1Fh, 3Fh, 29h
		db	 00h, 36h, 00h, 29h, 09h, 01h
		db	 00h, 01h, 00h, 02h, 00h, 01h
		db	 00h, 02h, 29h, 01h, 07h, 01h
		db	 70h, 00h, 09h, 5Fh,0F0h, 00h
		db	 0Ah, 60h, 00h, 1Dh,0BDh,0C0h
		db	 00h, 3Eh, 7Ch, 80h, 00h, 7Dh
		db	 53h, 29h, 00h,0FAh, 8Eh, 29h
		db	 00h,0FDh, 54h, 29h, 00h,0FEh
		db	0A9h, 29h, 00h,0FDh, 59h, 29h
		db	 00h,0D5h, 6Eh, 29h, 00h, 35h
		db	 1Fh, 29h, 00h,0A8h,0FFh, 29h
		db	 00h, 47h,0FFh, 29h, 00h, 9Fh
		db	0D0h, 29h, 00h, 78h, 15h, 29h
		db	 00h, 0Ah,0AAh, 29h, 00h, 55h
		db	 01h, 29h, 00h,0A1h,0FFh, 29h
		db	 00h,0FFh,0FBh, 29h, 00h,0D5h
		db	 29h, 02h,0AAh, 29h, 00h, 55h
		db	 40h, 29h, 01h, 7Fh, 29h, 00h
		db	 36h, 00h, 29h, 00h, 36h, 00h
		db	 29h, 00h,0BFh,0FFh, 29h, 00h
		db	0B3h, 57h, 29h, 04h, 69h, 00h
		db	 29h, 04h, 36h, 00h, 29h, 00h
		db	 36h, 00h, 29h, 00h, 36h, 00h
		db	 29h, 00h, 36h, 00h,0AAh, 00h
		db	0AAh, 00h,0D0h,0C0h,0D0h, 00h
		db	0A0h, 20h,0A0h, 00h, 66h, 00h
		db	 60h, 00h, 83h, 00h, 80h, 00h
		db	 40h, 00h, 40h, 00h, 80h, 00h
		db	 80h, 00h, 80h, 00h, 80h, 29h
		db	 01h,0C0h, 03h, 29h, 00h, 30h
		db	 0Ch, 29h, 00h, 0Ch, 30h, 29h
		db	 00h, 03h,0C0h, 29h, 00h, 03h
		db	0C0h, 29h, 00h, 0Ch, 30h, 29h
		db	 00h, 30h, 0Ch, 29h, 00h,0C0h
		db	 03h
sub_3		endp


seg_a		ends



		end	start
