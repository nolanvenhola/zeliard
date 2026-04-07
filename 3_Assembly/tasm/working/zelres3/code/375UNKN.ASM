
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_375UNKN                                 €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    5          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_375UNKN	proc	far

start:
		cmp	word ptr ds:[0],ax
		add	[bx],al
		test	word ptr [bx+si],201h
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		adc	[bx+di],dl
		adc	dl,[bp+di]
		adc	ax,1716h
		sbb	[bx+di],bl
		test	word ptr [bx+si],1007h
		test	word ptr [bx+si],1100h
		test	word ptr [bx+si],1200h
		adc	dx,[si]
		test	word ptr [bx+si],20Ah
		inc	ax
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		;  Fixup - byte match
		db	 40h, 00h, 40h, 00h, 40h, 02h
		db	 40h, 00h, 40h, 00h, 40h, 02h
		db	 40h, 01h, 80h,0F7h, 00h, 01h
		db	 02h, 40h, 00h, 40h, 00h, 40h
		db	 02h, 40h, 00h, 40h, 00h, 40h
		db	 00h, 40h, 00h, 40h, 02h, 40h
		db	 01h, 80h,0F7h, 00h, 01h, 02h
		db	 40h, 00h, 40h, 00h, 40h, 02h
		db	 40h, 00h, 40h, 00h, 40h, 00h
		db	 40h, 00h, 40h, 02h, 40h, 00h
		db	 80h, 00h, 80h, 01h, 80h, 05h
		db	 00h, 01h, 00h, 03h, 00h, 08h
		db	 40h, 00h, 40h, 00h, 40h, 04h
		db	 20h, 04h, 20h, 04h, 60h, 01h
		db	 80h, 00h, 80h, 00h, 80h,0F7h
		db	 00h, 04h, 01h,0F7h, 00h, 02h
		db	 3Bh,0F7h, 00h, 02h,0E0h, 00h
		db	 1Fh, 00h, 16h, 01h,0C6h, 02h
		db	 39h, 02h, 28h, 07h,0A0h, 00h
		db	 5Fh, 00h, 55h, 09h, 00h, 02h
		db	0FFh, 02h,0A8h, 0Ch, 00h, 23h
		db	0FFh, 21h, 55h, 37h,0A0h, 08h
		db	 5Ch, 08h, 00h, 38h, 00h, 47h
		db	0D1h, 45h, 01h, 80h, 18h, 7Ch
		db	 23h, 28h, 23h, 00h,0F8h,0F8h
		db	 07h, 50h, 06h, 03h,0C0h,0F0h
		db	 3Fh,0A0h, 28h, 06h, 00h,0C1h
		db	0FFh, 01h, 54h, 00h, 00h, 4Bh
		db	0FFh, 0Ah,0A0h, 00h, 00h, 2Fh
		db	0FFh, 29h, 15h, 00h, 6Ch, 00h
		db	 11h, 00h, 11h, 03h, 00h, 80h
		db	0FBh, 80h,0BBh, 1Ch, 00h,0C0h
		db	 3Fh,0C0h, 17h, 07h, 00h,0F8h
		db	 1Fh, 78h, 0Bh, 00h, 80h,0FFh
data_3		dw	174Fh			; Data table (indexed access)
		db	 45h, 00h, 40h,0DFh,0A3h, 42h
		db	0A0h, 00h, 00h, 3Fh,0D2h, 10h
		db	 50h, 00h, 00h, 2Fh,0F4h, 0Ah
		db	0B4h,0F7h, 00h, 05h, 80h, 00h
		db	 80h, 00h, 10h, 00h,0CCh, 00h
		db	0CCh, 00h, 05h, 00h,0FAh, 00h
		db	 6Ah, 00h, 00h, 80h,0FFh, 40h
		db	 17h, 40h, 00h, 40h,0FFh,0A0h
		db	 2Ah,0A0h, 01h, 80h,0FEh, 50h
		db	 06h, 50h, 01h,0A0h,0FEh, 54h
		db	 8Ah, 44h, 7Ch, 00h, 83h,0FFh
		db	 83h, 48h, 60h, 00h, 9Fh,0FEh
		db	 9Fh,0B4h, 20h, 00h, 5Fh,0FCh
		db	 5Ah,0E8h, 00h, 00h

_375UNKN	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		db	 3Eh,0FDh, 34h, 51h, 10h, 00h
		db	 2Ch, 39h, 08h, 21h, 21h, 02h
		db	 18h,0B1h, 10h, 81h, 03h, 04h
		db	 70h,0CBh, 20h, 8Bh,0C6h, 00h
		db	 31h,0FFh, 11h,0DDh, 00h, 80h
		db	 1Fh, 7Fh, 15h, 20h, 0Ch, 00h
		db	 73h,0FEh, 73h,0D0h, 3Bh, 40h
		db	0C4h,0BEh,0C4h,0A8h, 76h, 00h
		db	 89h,0FCh, 89h, 50h, 10h, 01h
		db	0EFh,0F8h,0AAh, 80h, 00h, 02h
		db	0FFh,0C1h, 54h, 01h, 00h, 18h
		db	0FEh, 07h, 80h, 02h, 00h,0C0h
		db	0C1h, 3Fh, 01h, 14h, 00h, 00h
		db	 1Fh,0FCh, 1Dh, 10h, 00h, 00h
		db	 7Fh,0D0h, 28h,0F7h, 00h, 00h
		db	0F8h, 03h, 60h, 03h, 00h,0ACh
		db	0E5h, 53h,0C5h, 53h, 03h,0DCh
		db	 44h, 23h, 04h, 23h, 06h,0E0h
		db	0C9h, 1Fh, 89h, 1Eh, 0Ch, 00h
		db	0D3h,0FFh, 13h,0F5h, 04h, 00h
		db	0CBh,0FFh, 8Bh, 50h, 32h,0A0h
		db	 08h, 5Ch, 08h,0F7h, 00h, 00h
		db	 5Fh,0D1h, 5Dh, 01h, 00h, 08h
		db	0FCh, 33h,0A8h, 33h, 00h,0A0h
		db	0F8h, 5Fh, 50h, 5Eh, 01h, 00h
		db	0F2h,0FFh,0A2h,0E8h, 02h, 00h
		db	0C5h,0FFh, 05h, 54h, 00h, 00h
		db	 4Bh,0FFh, 0Ah,0A0h, 00h, 00h
		db	 2Fh,0FFh, 2Dh, 55h, 08h, 00h
		db	0D7h,0FFh, 17h,0E8h, 00h, 00h
		db	 3Fh,0FFh, 3Fh,0D8h, 10h, 00h
		db	 6Fh,0FAh, 6Dh, 60h, 40h, 00h
		db	0BFh,0E4h,0AAh,0F7h, 00h, 00h
		db	0FFh, 14h,0F4h,0F7h, 00h, 00h
		db	0FCh,0A8h, 50h, 80h, 00h, 00h
		db	0F3h,0FEh, 83h,0F4h, 00h, 00h
		db	0EFh,0FFh, 4Fh,0A8h, 84h, 04h
		db	 6Bh,0E3h, 4Bh, 43h, 08h, 08h
		db	0C7h,0C7h, 85h, 04h, 08h, 20h
		db	 87h, 1Eh, 84h, 14h, 00h, 00h
		db	 9Eh, 3Eh, 14h, 28h, 00h, 20h
		db	 1Ch, 18h, 18h, 10h, 10h, 00h
		db	 0Ch, 38h, 08h, 30h, 00h, 00h
		db	 1Ch,0F7h, 10h, 00h, 00h, 00h
		db	 08h, 00h, 08h, 00h, 03h, 80h
		db	 04h, 7Fh, 04h, 74h, 0Eh, 00h
		db	 01h,0FCh, 01h,0A0h, 0Ch, 00h
		db	 13h,0E0h, 11h, 40h, 08h, 00h
		db	 17h, 94h, 16h,0F7h, 00h, 00h
		db	 1Eh, 28h, 1Ah,0F7h, 00h, 00h
		db	 1Ch, 30h, 10h, 10h, 00h, 00h
		db	 0Ch, 10h, 08h, 10h, 00h, 00h
		db	 08h, 00h, 08h,0F7h, 00h, 00h
		db	 10h, 40h,0F7h, 00h, 01h, 82h
		db	 02h,0F7h, 00h, 01h, 8Ah, 08h
		db	 80h,0F7h, 00h, 00h, 54h, 5Ch
		db	 00h, 08h, 00h, 00h, 5Ch, 38h
		db	 10h, 10h, 00h, 00h, 38h, 10h
		db	 20h,0F7h, 00h, 00h, 38h, 80h
		db	 10h,0F7h, 00h, 00h, 10h, 00h
		db	 10h,0F7h, 00h, 06h, 08h, 08h
		db	0F7h, 00h, 01h,0F7h, 08h, 01h
		db	0F7h, 00h, 00h, 80h,0F7h, 00h
		db	 02h, 80h, 00h, 80h, 00h, 00h
		db	 40h, 02h,0F7h, 00h, 01h, 40h
		db	 42h, 40h, 02h,0F7h, 00h, 00h
		db	 40h, 00h, 40h,0F7h, 00h, 00h
		db	 03h,0F7h, 00h, 02h, 0Ch,0F7h
		db	 00h, 00h, 20h, 00h, 11h, 00h
		db	 01h, 00h, 80h, 00h, 47h, 00h
		db	 06h, 02h, 00h, 01h, 1Fh, 00h
		db	 08h, 00h, 00h, 0Ch, 7Fh, 00h
		db	 54h, 20h, 00h, 11h,0FFh, 00h
		db	0A0h, 00h, 00h,0C7h,0FFh, 05h
		db	 55h, 00h, 00h,0C0h,0F7h, 00h
		db	 02h, 30h,0F7h, 00h, 02h, 8Ch
		db	 00h, 80h, 00h, 02h, 00h,0E1h
		db	 00h, 40h, 00h, 00h, 80h,0F0h
		db	 40h,0A0h, 00h, 02h, 20h,0C4h
		db	 10h, 04h,0F7h, 00h, 00h, 4Bh
		db	 8Ch, 0Ah, 80h, 00h, 02h, 2Fh
		db	0E1h, 2Dh, 40h,0F7h, 00h, 00h
		db	 40h, 00h, 40h, 00h, 40h, 00h
		db	 20h, 00h, 20h, 00h, 80h, 00h
		db	 60h, 00h, 60h,0F7h, 00h, 00h
		db	0C0h, 00h,0C0h, 00h, 40h, 00h
		db	 20h, 00h, 20h, 02h, 00h, 00h
		db	 70h, 00h, 70h, 00h, 40h, 06h
		db	0B0h, 04h,0A0h, 00h,0C0h, 07h
		db	 30h, 04h, 00h, 04h, 00h, 02h
		db	0F8h, 02h,0E8h, 08h, 00h, 06h
		db	0E8h, 06h,0C0h, 0Ch, 00h, 03h
		db	 5Ch, 03h, 0Ch, 18h, 00h, 07h
		db	0BCh, 07h, 98h, 11h, 00h, 0Eh
		db	0F8h, 0Ch,0D0h, 11h, 80h, 0Ch
		db	 68h, 08h, 20h, 00h, 80h, 1Ah
		db	 5Ch, 18h, 48h, 00h, 00h, 16h
		db	0BCh, 12h, 90h, 00h, 00h, 17h
		db	 78h, 13h, 30h, 04h, 80h, 0Bh
		db	 7Eh, 0Bh, 6Ah, 18h, 00h, 25h
		db	0FEh, 25h,0FAh, 40h, 00h, 32h
		db	0F4h, 32h,0E4h, 48h, 00h, 07h
		db	0F9h, 07h, 01h,0A0h, 02h, 1Fh
		db	0C1h, 1Dh, 01h, 80h, 00h, 7Eh
		db	 1Fh, 50h, 12h, 00h, 00h,0D1h
		db	0FFh, 81h, 00h, 05h, 15h, 0Ah
		db	0AAh, 02h,0AAh, 05h, 54h, 1Ah
		db	 28h, 0Ah, 2Ch, 15h, 59h, 2Ah
		db	0A2h, 0Ah,0AAh, 15h, 54h, 6Ah
		db	0A8h, 2Ah,0ACh, 15h, 55h, 2Ah
		db	0AAh, 0Ah,0AAh, 15h, 59h, 2Ah
		db	0A2h, 0Ah,0AAh, 05h, 54h, 1Ah
		db	 28h, 0Ah, 2Ch, 05h, 15h, 0Ah
		db	0AAh, 02h,0AAh, 55h, 55h,0A8h
		db	0AAh,0A8h,0AAh, 15h, 45h, 0Ah
		db	 88h, 0Ah,0C8h, 55h, 95h,0A2h
		db	 22h,0B2h,0B2h, 15h, 59h, 0Ah
		db	 22h, 0Bh, 2Ah, 61h, 01h, 8Eh
		db	 02h,0AFh, 02h, 66h, 55h, 88h
		db	0A8h,0AAh,0ACh, 14h, 54h, 08h
		db	0A8h, 0Ch,0ACh, 55h, 55h,0AAh
		db	 8Ah,0AAh, 8Ah, 55h, 55h, 2Ah
		db	0AAh, 2Ah,0AAh, 80h, 60h, 00h
		db	 80h, 80h,0A0h, 55h, 55h,0A2h
		db	 8Ah,0B2h,0CBh, 55h, 55h,0A2h
		db	 8Ah,0B2h,0CBh, 55h, 55h,0A2h
		db	 8Ah,0B2h,0CBh, 55h, 55h,0A2h
		db	 8Ah,0B2h,0CBh, 55h, 60h,0A2h
		db	 80h,0B2h,0A0h, 55h, 55h,0A8h
		db	 2Ah,0A8h, 2Ah, 51h, 55h,0A8h
		db	0AAh,0A8h,0AAh, 65h, 54h, 8Ah
		db	 88h,0AAh,0CCh, 65h, 59h, 02h
		db	 82h, 22h,0CAh, 61h, 59h, 02h
		db	 82h, 22h,0CAh, 66h, 19h, 08h
		db	 02h, 2Ah, 0Ah, 65h, 19h, 0Ah
		db	 02h, 2Bh, 0Ah, 65h, 54h, 8Ah
		db	 88h,0AAh,0CCh, 51h, 55h,0F7h
		db	0AAh, 01h, 55h, 00h,0AAh,0C0h
		db	0AAh, 80h, 15h, 00h, 0Ah,0C0h
		db	 0Ah, 80h, 65h, 40h, 8Ah,0B0h
		db	0AAh,0A0h, 64h, 50h, 8Ah,0A8h
		db	0AAh,0A0h, 65h, 40h, 8Ah,0A8h
		db	0AAh,0A0h, 61h, 50h, 8Ah,0ACh
		db	0AAh,0A8h, 15h, 50h, 0Ah,0A8h
		db	 0Ah,0A0h, 55h, 00h,0AAh,0B0h
		db	0AAh,0A0h,0F7h, 00h, 03h, 0Eh
		db	0F7h, 00h, 00h, 04h, 00h, 10h
		db	 44h,0EFh,0BAh, 10h, 44h, 55h
		db	 54h,0AAh,0AAh, 55h, 54h, 0Eh
		db	0F7h, 00h, 00h, 04h, 00h, 3Fh
		db	 80h, 00h, 00h, 05h, 00h,0FFh
		db	0E0h, 00h, 00h, 15h, 40h, 3Fh
		db	 80h, 00h, 00h, 15h,0F7h, 00h
		db	 00h, 0Eh,0F7h, 00h, 00h, 04h
		db	 00h, 0Ah, 00h, 04h, 00h, 00h
		db	 0Ch, 0Eh,0F7h, 00h, 01h, 3Eh
		db	 0Eh, 00h, 00h, 04h, 35h,0FEh
		db	 0Ah, 00h, 05h, 54h, 31h,0FEh
		db	 0Eh, 00h, 11h, 54h, 04h, 3Eh
		db	 0Ah, 00h, 04h, 14h, 04h, 08h
		db	 0Ah, 00h, 04h, 00h, 03h,0FCh
		db	0F7h, 00h, 00h, 10h, 0Fh,0FEh
		db	 00h, 00h, 01h, 54h, 03h,0F8h
		db	 00h, 00h, 01h, 50h, 00h,0E0h
		db	0F7h, 00h, 00h, 40h, 10h, 45h
		db	0EFh,0BAh, 10h, 45h, 55h, 55h
		db	0AAh,0AAh, 55h, 55h, 00h,0E0h
		db	0F7h, 00h, 00h, 40h,0F7h, 00h
		db	 03h, 30h, 00h, 00h,0E0h, 00h
		db	 00h,0F8h, 40h, 00h,0A0h, 10h
		db	 40h,0FFh, 18h, 00h,0E0h, 15h
		db	 10h,0FFh, 18h, 00h,0E0h, 55h
		db	 10h,0F8h, 40h, 00h,0A0h, 10h
		db	 40h, 20h, 00h, 00h,0E0h,0F7h
		db	 00h, 00h, 40h, 00h,0A0h, 00h
		db	 40h, 00h, 40h, 00h,0A0h, 00h
		db	 40h, 00h, 00h, 07h, 08h, 00h
		db	 00h, 01h, 00h, 17h,0FCh, 05h
		db	0A0h, 04h, 00h, 9Fh,0F2h, 05h
		db	0E0h, 00h, 20h,0DFh,0F9h, 0Bh
		db	 60h, 00h, 00h,0FFh,0F0h, 55h
		db	0A0h, 04h, 00h, 6Fh,0A0h, 06h
		db	 80h, 04h, 00h, 0Fh, 18h, 04h
		db	0F7h, 00h, 00h, 46h, 06h,0F7h
		db	 00h, 08h, 80h, 00h, 00h, 01h
		db	 00h, 25h, 98h, 01h, 00h, 04h
		db	 40h, 07h,0E0h, 04h,0C0h, 04h
		db	 00h, 1Fh,0C4h, 05h, 04h, 01h
		db	 80h, 03h,0A0h, 03h, 80h, 00h
		db	 00h, 04h, 08h, 04h,0F7h, 00h
		db	 06h, 9Fh, 08h, 00h, 00h, 18h
		db	 08h, 7Fh,0FEh, 18h, 08h, 10h
		db	 00h, 3Fh,0FDh, 11h, 40h, 00h
		db	 00h, 3Fh,0FEh, 03h,0A0h, 00h
		db	 02h, 3Fh,0FFh, 01h,0C2h, 28h
		db	 04h, 7Fh,0FEh, 28h, 04h, 00h
		db	 20h, 3Dh,0FEh, 00h, 20h, 00h
		db	 00h, 42h, 23h,0F7h, 00h, 07h
		db	 10h, 20h, 00h, 20h, 01h, 80h
		db	 05h,0C0h, 01h,0C0h, 0Ch, 20h
		db	 2Fh,0F8h, 2Ch,0A0h, 02h, 20h
		db	 07h,0E0h, 03h, 20h, 02h, 80h
		db	 1Bh,0A4h, 02h, 80h, 00h, 00h
		db	 01h,0F7h, 00h, 0Ah, 01h, 00h
		db	 00h, 80h, 00h, 00h, 03h, 80h
		db	 06h, 60h, 00h, 00h, 09h,0E0h
		db	 0Eh, 70h, 00h, 00h, 11h,0F0h
		db	 19h, 58h, 00h, 00h, 27h,0F8h
		db	 08h,0F8h, 00h, 00h, 3Fh,0F8h
		db	 17h,0B0h, 00h, 00h, 1Fh,0F0h
		db	 06h,0C0h, 00h, 00h, 07h,0C0h
sub_1		endp


seg_a		ends



		end	start
