
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_378UNKN                                 лл
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

_378UNKN	proc	far

start:
		xchg	si,ax
		or	[bx+si],ax
		add	[bx+si],al
		pop	es
		db	0F1h, 00h, 01h, 02h, 18h, 19h
		db	 1Ah, 1Bh, 1Ch, 1Dh
		db	'!"#$'
		db	'%&', 27h, '()*-./'
		db	 00h, 00h, 21h,0F1h, 00h, 00h
		db	 22h,0F1h, 00h, 00h, 1Ah, 1Bh
		db	 1Ch, 1Dh,0F1h, 00h, 01h, 25h
		db	 26h, 00h, 00h, 23h, 24h, 00h
		db	 00h, 06h, 80h,0F1h, 00h, 00h
		db	 40h, 06h, 80h, 00h, 00h, 01h
		db	 40h, 02h,0F1h, 00h, 00h, 01h
		db	 80h, 03h,0F1h, 00h, 01h, 80h
		db	 03h,0F1h, 00h, 01h, 80h, 03h
		db	 80h,0F1h, 00h, 01h, 07h,0C0h
		db	 00h, 00h, 01h, 00h, 06h,0C0h
		db	 00h, 00h, 02h,0C0h, 02h,0F1h
		db	 00h, 00h, 01h, 00h, 1Eh,0F1h
		db	 00h, 00h, 01h,0F1h, 00h, 02h
		db	 07h, 80h, 07h,0F1h, 00h, 01h
		db	 80h, 03h,0F1h, 00h, 01h,0C0h
		db	 03h, 80h,0F1h
data_2		db	0			; Data table (indexed access)
		db	 00h, 40h, 01h, 40h,0F1h, 00h
		db	 00h,0B0h, 01h, 30h,0F1h, 00h
		db	 00h,0B0h, 29h,0A0h, 29h,0A0h
		db	 00h, 00h, 44h, 14h, 44h, 14h
		db	 00h, 00h, 04h, 28h, 26h,0A8h
		db	 04h, 20h, 02h, 04h,0D3h, 44h
		db	 02h, 04h, 20h, 00h,0F3h, 89h
		db	 20h,0F1h, 00h, 00h,0A9h, 01h
		db	0F1h, 00h, 00h, 02h, 58h, 0Bh
		db	 00h, 02h, 00h, 02h, 0Ch, 13h
		db	 00h, 02h, 29h,0A0h, 29h,0A0h
		db	 00h, 00h, 47h, 54h, 47h, 54h
		db	 00h, 00h, 04h,0E8h, 26h,0E8h
		db	 04h, 00h, 80h,0A4h,0D2h,0A4h
		db	 80h, 04h, 22h,0C8h,0F2h,0C9h
		db	 22h, 08h, 00h, 80h,0A8h, 81h
		db	0F1h, 00h, 00h, 48h, 58h, 4Bh
		db	 00h, 08h, 00h, 80h, 0Ch, 93h
		db	 00h, 00h, 04h, 12h, 06h, 92h
		db	 04h, 12h, 04h, 00h, 47h, 14h
		db	 00h, 00h, 06h, 20h, 26h,0A0h
		db	 00h, 20h, 80h, 10h,0D3h, 54h
		db	 80h, 00h, 22h, 08h,0F3h, 89h
		db	 00h, 08h, 28h, 28h,0A9h, 29h
		db	0F1h, 00h, 00h, 12h, 58h, 1Bh
		db	 00h, 02h, 08h, 82h, 0Ch, 93h
		db	 08h, 02h, 04h, 12h, 06h, 92h
		db	 04h, 12h, 04h, 24h, 07h, 24h
		db	 04h, 24h, 04h, 20h, 06h,0A0h
		db	 04h, 20h, 02h, 44h, 03h, 44h
		db	 02h, 44h, 02h, 89h, 03h, 89h
		db	 02h, 89h,0F1h, 01h, 03h, 00h
		db	 0Ah, 00h, 0Bh, 00h, 0Ah, 00h
		db	 12h, 00h, 13h, 00h, 12h, 04h
		db	 10h, 06h, 92h, 04h, 10h, 00h
		db	 20h, 47h, 24h, 00h, 20h, 04h
		db	 00h, 26h,0A0h, 04h, 00h, 80h
		db	 04h,0D3h, 44h, 80h, 04h, 00h
		db	 09h,0F3h, 89h, 00h, 09h, 01h
		db	 00h,0A9h, 01h, 01h,0F1h, 00h
		db	 00h, 58h, 0Bh,0F1h, 00h, 01h
		db	 0Ch, 1Bh,0F1h, 00h, 00h, 12h
		db	 00h, 12h, 00h, 12h, 00h, 04h
		db	 00h, 04h, 00h, 04h,0F1h, 00h
		db	 03h,0C0h, 00h,0C0h, 00h,0C0h
		db	 00h, 20h, 01h,0E0h, 01h, 20h
		db	 01h, 20h, 01h,0A0h, 01h, 20h
		db	 01h, 12h, 0Ah, 5Ah, 0Bh
data_3		db	12h			; Data table (indexed access)
		db	 0Ah, 09h, 12h, 0Dh, 13h, 09h
		db	 12h, 40h, 10h, 00h, 12h, 40h
		db	 10h,0A8h,0F1h, 00h, 00h,0B8h
		db	 00h, 14h, 82h, 00h, 00h, 17h
		db	 8Eh, 05h, 14h,0C0h, 00h, 0Dh
		db	 74h, 09h, 51h,0E0h, 01h, 09h
		db	0D1h, 08h,0A0h,0A0h, 01h, 08h
		db	0A0h, 12h, 48h, 5Ah, 0Bh, 12h
		db	0C8h, 00h, 82h, 0Ch, 13h, 00h
		db	 82h, 00h, 12h, 00h, 12h, 00h
		db	 12h, 00h, 04h, 00h, 04h, 01h
		db	 04h,0F1h, 00h, 03h,0C0h, 00h
		db	0C0h, 00h,0C4h, 10h, 20h, 01h
		db	0E0h, 01h, 21h, 01h, 20h, 00h
		db	0A0h, 01h, 20h, 40h, 02h, 08h
		db	 5Ah, 0Bh, 02h, 08h, 01h, 12h
		db	 0Dh, 13h, 01h, 12h, 04h, 52h
		db	 06h,0D2h, 04h, 52h, 00h, 00h
		db	 08h, 04h,0F1h, 00h, 01h, 30h
		db	 64h, 00h, 00h, 80h, 00h,0C1h
		db	 24h, 80h, 00h, 20h, 01h,0E1h
		db	 05h, 20h, 01h, 02h, 01h,0A2h
		db	 25h, 02h, 01h, 10h, 0Ah, 58h
		db	0CBh, 10h, 0Ah, 08h, 02h, 0Ch
		db	 13h, 08h, 02h, 04h, 10h, 06h
		db	 90h, 04h, 10h, 04h, 00h, 47h
		db	 20h, 04h, 00h, 04h, 00h, 26h
		db	0A0h, 04h, 00h,0C0h, 00h,0D3h
		db	 40h,0C0h, 00h, 20h, 80h,0F3h
		db	 80h, 20h, 80h, 21h, 00h,0A9h
		db	 00h, 21h,0F1h, 00h, 00h, 58h
		db	0F1h, 00h, 02h, 0Ch,0F1h, 00h
		db	 01h, 70h,0F1h, 00h, 00h, 10h
		db	 00h,0C8h,0F1h, 00h, 00h, 3Ah
		db	 00h, 88h,0F1h, 00h, 00h, 5Ah
		db	 00h, 10h,0F1h, 00h, 00h, 70h
		db	 00h, 0Ch,0F1h, 00h, 02h, 38h
		db	 00h, 00h, 01h, 86h, 01h, 9Ch
		db	 00h, 00h, 03h, 82h, 03h, 08h
		db	 00h, 00h, 07h, 07h, 01h, 0Ch
		db	 00h, 00h, 07h, 03h, 01h, 06h
		db	 00h, 00h, 0Fh, 01h, 03h, 17h
		db	 00h, 00h, 0Fh, 10h, 02h, 23h
		db	 00h, 00h, 0Eh, 20h, 04h, 31h
		db	 00h, 00h, 0Eh, 32h, 02h, 32h
		db	 00h, 00h, 0Eh, 31h, 02h, 32h
		db	 00h, 00h, 0Eh, 31h, 06h, 22h
		db	 00h, 00h, 0Eh, 21h, 02h, 22h
		db	 00h, 00h, 0Eh, 21h, 04h, 33h
		db	 00h, 00h, 0Eh, 30h, 02h, 21h
		db	 00h, 00h, 0Eh, 22h, 02h, 16h
		db	 00h, 00h, 06h, 11h, 00h, 16h
		db	 00h, 00h, 06h, 11h, 03h, 14h
		db	 00h, 00h, 07h, 12h, 01h, 08h
		db	 00h, 00h, 03h, 04h, 01h, 08h
		db	 00h, 00h, 01h, 00h, 50h, 70h
		db	 00h, 00h, 30h, 10h,0E8h,0C8h
		db	 00h, 00h, 1Ah, 3Ah, 48h, 8Ah
		db	 00h, 00h,0BAh, 5Ah, 10h, 10h
		db	 00h, 00h, 70h, 70h, 0Ch, 0Ch
		db	0F1h, 00h, 01h, 24h, 38h, 00h
		db	 00h, 1Ah, 06h, 1Ch, 1Ch, 00h
		db	 00h, 02h, 02h, 0Ah, 08h, 00h
		db	 00h, 05h, 07h, 8Dh, 8Ch, 00h
		db	 00h, 83h, 83h, 46h, 46h, 00h
		db	 00h,0C1h,0C1h, 47h, 47h, 00h
		db	 00h,0C0h,0C0h,0A3h,0A3h, 00h
		db	 00h, 60h, 60h,0A1h, 21h, 00h
		db	 00h, 60h,0E2h, 22h, 22h, 00h
		db	 00h,0E0h, 61h, 23h, 22h, 00h
		db	 00h,0E0h,0A1h,0A3h, 22h, 00h
		db	 00h, 60h,0E1h, 22h,0A2h, 00h
		db	 00h,0E1h, 61h, 23h,0A2h, 00h
		db	 00h, 20h, 61h, 43h, 42h, 00h
		db	 00h,0C0h,0C0h, 45h, 44h, 00h
		db	 00h,0C2h,0C1h, 86h, 84h, 00h
		db	 00h, 81h, 83h, 05h, 87h, 00h
		db	 00h, 03h, 81h, 0Ah, 0Ah, 00h
		db	 00h, 06h, 06h, 04h, 0Ch, 00h
		db	 00h, 0Ch, 04h, 50h,0F1h, 00h
		db	 00h, 30h, 00h,0E8h,0F1h, 00h
		db	 00h, 18h, 00h, 48h,0F1h, 00h
		db	 00h,0B8h, 00h, 10h,0F1h, 00h
		db	 00h, 70h, 00h, 0Ch,0F1h, 00h
		db	 02h, 24h,0F1h, 00h, 00h, 1Ah
		db	 00h, 1Ch,0F1h, 00h, 00h, 02h
		db	 00h, 0Ah,0F1h, 00h, 00h, 05h
		db	 00h, 8Dh, 80h, 00h, 00h, 83h
		db	 80h, 46h, 40h, 00h, 00h,0C1h
		db	0C0h, 47h, 40h, 00h, 00h,0C0h
		db	0C0h,0A3h,0A0h, 00h, 00h, 60h
		db	 60h,0A1h, 20h, 00h, 00h, 60h
		db	0E0h, 22h, 20h, 00h, 00h,0E0h
		db	 60h, 23h, 20h, 00h, 00h,0E0h
		db	0A0h,0A3h, 20h, 00h, 00h, 60h
		db	0E0h, 22h,0A0h, 00h, 00h,0E1h
		db	 60h, 23h,0A0h, 00h, 00h, 20h
		db	 60h, 43h, 40h, 00h, 00h,0C0h
		db	0C0h, 45h, 40h, 00h, 00h,0C2h
		db	0C0h, 86h, 80h, 00h, 00h, 81h
		db	 80h, 05h, 80h, 00h, 00h, 03h
		db	 80h, 0Ah,0F1h, 00h, 00h, 06h
		db	 00h, 04h,0F1h, 00h, 00h, 0Ch
		db	 00h, 23h,0A2h, 01h, 80h,0E1h
		db	0A1h, 23h, 62h, 01h,0C0h, 21h
		db	 61h, 43h, 02h, 01h, 40h,0C1h
		db	 00h, 45h, 04h, 01h,0A0h,0C1h
		db	 01h, 80h, 04h, 06h,0E0h, 80h
		db	 03h, 00h, 07h, 05h, 40h, 00h
		db	 01h, 08h, 0Ah, 0Bh, 80h, 08h
		db	 06h, 10h, 0Ch, 1Eh,0C0h, 10h
		db	 04h, 8Ch, 8Ch, 02h, 00h, 80h
		db	 83h, 46h, 46h, 03h, 00h,0C2h
		db	 41h, 46h, 47h, 00h, 00h,0C0h
		db	0C0h,0A2h, 23h, 01h, 00h, 60h
		db	 60h,0A1h, 01h, 00h,0C0h, 60h
		db	 02h, 22h, 82h, 00h,0E0h,0E0h
		db	 81h, 23h,0C2h, 00h,0E0h,0E0h
		db	0C1h,0A3h, 02h, 00h,0C0h, 60h
		db	 01h, 04h, 08h, 06h, 98h, 04h
		db	 08h, 00h, 20h, 03h, 28h, 00h
		db	 20h, 00h, 10h, 02h,0B0h, 00h
		db	 10h, 08h, 04h, 09h, 04h, 08h
		db	 04h, 00h, 00h, 19h, 80h, 00h
		db	 00h, 01h, 00h, 09h, 00h, 01h
		db	0F1h, 00h, 01h, 80h, 00h, 00h
		db	 01h, 00h, 01h, 00h, 01h, 00h
		db	 14h, 00h, 16h, 98h, 04h, 00h
		db	 18h, 08h, 1Bh, 28h, 00h, 08h
		db	 00h, 00h, 02h, 90h, 00h, 00h
		db	 08h, 04h, 09h, 04h, 08h, 04h
		db	 00h, 00h, 19h, 80h, 00h, 00h
		db	 01h, 28h, 09h, 28h, 01h, 00h
		db	 00h, 50h, 00h,0D0h, 00h, 00h
		db	 01h, 00h, 01h, 00h, 01h, 00h
		db	 05h, 6Ah, 00h, 00h, 05h, 6Ah
		db	 2Ah, 6Fh, 00h, 00h, 2Fh,0FFh
		db	 4Fh,0BFh, 00h, 00h, 7Fh,0FFh
		db	 3Bh,0FFh, 00h, 00h, 7Fh,0FFh
		db	0DFh,0DFh, 00h, 00h,0FFh,0FFh
		db	 7Fh,0FFh, 00h, 00h,0FFh,0FFh
		db	0BFh,0FFh, 00h, 00h,0F1h,0FFh
		db	 01h, 00h, 00h,0FFh,0FFh, 50h
		db	 05h, 00h, 00h, 50h, 05h,0ADh
		db	 59h, 00h, 00h,0EDh, 5Bh,0FBh
		db	 37h, 00h, 00h,0F1h,0FFh, 00h
		db	 7Fh, 00h, 00h,0FFh,0FFh,0DFh
		db	 7Fh, 00h, 00h,0F1h,0FFh, 01h
		db	 00h, 00h,0F1h,0FFh, 01h, 00h
		db	 00h,0FFh,0FFh,0DFh,0FFh, 00h
		db	 00h,0FFh,0FFh,0ADh, 55h, 00h
		db	 00h,0AFh,0F5h, 97h, 7Fh, 00h
		db	 00h,0F1h,0FFh, 00h, 7Fh, 00h
		db	 00h,0F1h,0FFh, 01h, 00h, 00h
		db	0FFh,0FFh,0BFh,0FFh, 00h, 00h
		db	0F1h,0FFh, 01h, 00h, 00h,0F1h
		db	0FFh, 01h, 00h, 00h,0FFh,0FFh
		db	0DFh,0FFh, 00h, 00h,0FFh,0FFh
		db	 56h,0A0h, 00h, 00h, 56h,0A0h
		db	0F6h, 54h, 00h, 00h,0FFh,0F4h
		db	0FDh,0F2h, 00h, 00h,0FFh,0FEh
		db	0FFh,0DCh, 00h, 00h,0FFh,0FEh
		db	0FBh,0FBh, 00h, 00h,0F1h,0FFh
		db	 00h,0FEh, 00h, 00h,0F1h,0FFh
		db	 00h,0FDh, 00h, 00h,0F1h,0FFh
		db	 01h, 00h, 00h,0F1h,0FFh, 01h
		db	 00h, 00h,0F1h,0FFh, 01h, 00h
		db	 00h,0F1h,0FFh, 01h, 00h, 00h
		db	0FFh,0FFh,0F8h, 70h, 00h, 00h
		db	0F8h, 70h,0E2h, 09h, 03h, 09h
		db	0E2h, 09h, 81h, 00h, 09h, 01h
		db	 81h, 00h, 10h, 08h, 18h, 0Bh
		db	 10h, 08h, 00h, 02h, 0Ch, 13h
		db	 00h, 02h,0FFh,0FFh, 00h, 00h
		db	0F1h,0FFh, 01h, 00h, 00h,0FFh
		db	0FFh, 1Fh,0FFh, 00h, 00h, 1Fh
		db	0FFh,0C0h, 70h,0C0h, 00h,0C0h
		db	 70h, 22h, 09h,0F3h, 09h, 22h
		db	 09h, 00h, 00h,0A9h, 01h,0F1h
		db	 00h, 00h, 0Ah, 58h, 0Bh, 00h
		db	 0Ah, 08h, 00h, 0Ch, 13h, 08h
		db	 00h,0FFh,0FFh, 00h, 00h,0F1h
		db	0FFh, 01h, 00h, 00h,0FFh,0FFh
		db	 1Fh,0FFh, 00h, 00h, 1Fh,0FFh
		db	0C0h, 7Fh,0C0h, 00h,0C0h, 7Fh
		db	 20h, 07h,0F3h, 00h, 20h, 07h
		db	 01h, 03h,0A9h, 00h, 01h, 03h
		db	 00h, 09h, 58h, 08h, 00h, 09h
		db	 08h, 10h, 0Ch, 10h, 08h, 10h
		db	 00h, 03h, 00h, 03h,0F1h, 00h
		db	 00h, 02h, 00h
loc_1:
		push	cs
		add	[si],cl
		add	[bp+si],cl
		add	[bp+si],bh
		add	[bx+si],dh
;*		add	[bx+si+0],bl
		db	 00h, 58h, 00h		;  Fixup - byte match
		db	0D8h, 00h, 80h, 00h,0E1h, 03h
		db	0E1h, 03h, 01h, 07h, 51h, 0Fh
		db	 51h, 08h, 01h, 04h, 62h, 34h
		db	 63h, 30h, 02h, 40h, 22h,0C0h
		db	 23h, 80h, 02h,0C0h, 00h,0C0h
		db	0F1h, 00h, 00h, 40h, 00h, 70h
		db	 00h, 30h, 00h, 50h, 00h, 5Ch
		db	 00h, 0Ch, 00h, 1Ah, 00h, 1Bh
		db	 00h, 01h, 00h, 87h, 00h, 87h
		db	0C0h, 80h,0C0h, 8Ah,0E0h, 8Ah
		db	0F0h, 80h, 10h, 46h, 20h,0C6h
		db	 2Ch, 40h, 0Ch, 44h, 02h,0C4h
		db	 03h, 40h, 01h, 04h, 10h, 06h
		db	 92h, 04h, 10h, 00h, 20h, 47h
		db	 24h, 00h, 20h, 04h, 00h, 26h
		db	0A0h, 04h, 00h, 80h, 04h,0D3h
		db	 44h, 80h, 04h, 00h, 09h,0F3h
		db	 89h, 00h, 09h, 01h, 00h,0A9h
		db	 01h, 01h,0F1h, 00h, 00h, 58h
		db	 0Bh,0F1h, 00h, 01h, 0Ch, 1Bh
		db	 00h, 00h, 04h, 10h, 06h, 92h
		db	 04h, 10h, 00h, 20h, 47h, 24h
		db	 00h, 20h, 04h, 00h, 26h,0A0h
		db	 04h, 00h, 80h, 04h,0D3h, 44h
		db	 80h, 04h, 00h, 09h,0F3h, 89h
		db	 00h, 09h, 01h, 00h,0A9h, 01h
		db	 01h,0F1h, 00h, 00h, 58h, 0Bh
		db	0F1h, 00h, 01h, 0Ch, 1Bh, 00h
		db	 00h, 04h, 10h, 06h, 92h, 04h
		db	 10h, 00h, 20h, 47h, 24h, 00h
		db	 20h, 04h, 00h, 26h,0A0h, 04h
		db	 00h, 80h, 04h,0D3h, 44h, 80h
		db	 04h, 00h, 09h,0F3h, 89h, 00h
		db	 09h, 01h, 00h,0A9h, 01h, 01h
		db	0F1h, 00h, 00h, 58h, 0Bh,0F1h
		db	 00h, 01h, 0Ch, 1Bh, 00h, 00h
		db	 04h, 10h, 06h, 92h, 04h, 10h
		db	 00h, 20h, 47h, 24h, 00h, 20h
		db	 04h, 00h, 26h,0A0h, 04h, 00h
		db	 80h, 04h,0D3h, 44h, 80h, 04h
		db	 00h, 09h,0F3h, 89h, 00h, 09h
		db	 01h, 00h,0A9h, 01h, 01h,0F1h
		db	 00h, 00h, 58h, 0Bh,0F1h, 00h
		db	 01h, 0Ch, 1Bh, 00h, 00h,0CBh
		db	 21h,0FFh, 27h,0FFh, 27h, 00h
		db	 80h, 01h,0DCh,0FEh, 89h, 28h
		db	 88h, 7Ch,0D8h,0A9h, 8Bh, 00h
		db	0A2h, 01h,0F3h,0FEh,0A6h, 28h
		db	0A0h, 7Ch,0E0h,0A9h,0AFh, 28h
		db	 8Ah, 7Ch,0CFh,0A9h, 9Ah, 00h
		db	 8Ah, 01h, 8Fh,0FEh,0BAh, 00h
		db	 00h, 55h, 55h, 00h, 00h,0C0h
		db	 00h,0C0h, 00h,0C0h, 00h,0B8h
		db	 00h,0F8h, 00h,0B8h, 00h, 69h
		db	 80h, 7Dh, 80h,0E9h, 80h, 2Ah
		db	0B8h, 3Bh,0F8h, 6Bh,0B8h, 04h
		db	 84h, 17h,0D4h,0E7h, 84h, 9Ah
		db	 80h,0DFh,0A0h, 9Eh, 80h, 02h
		db	 80h, 07h,0C0h, 3Ah, 80h, 00h
		db	 30h, 55h, 70h, 00h, 30h, 04h
		db	 10h, 06h, 92h, 04h, 10h, 00h
		db	 20h, 47h, 24h, 00h, 20h, 04h
		db	 00h, 26h,0A0h, 04h, 00h, 80h
		db	 04h,0D3h, 44h, 80h, 04h, 00h
		db	 09h,0F3h, 89h, 00h, 09h, 01h
		db	 00h,0A9h, 01h, 01h,0F1h, 00h
		db	 00h, 58h, 0Bh,0F1h, 00h, 01h
		db	 0Ch, 1Bh, 00h, 00h, 04h, 10h
		db	 06h, 92h, 04h, 10h, 00h, 20h
		db	 47h, 24h, 00h, 20h, 04h, 00h
		db	 26h,0A0h, 04h, 00h, 80h, 04h
		db	0D3h, 44h, 80h, 04h, 00h, 09h
		db	0F3h, 89h, 00h, 09h, 01h, 00h
		db	0A9h, 01h, 01h,0F1h, 00h, 00h
		db	 58h, 0Bh,0F1h, 00h, 01h, 0Ch
		db	 1Bh, 00h, 00h, 29h,0A0h, 29h
		db	0A0h, 00h, 00h, 44h, 14h, 44h
		db	 14h,0F1h, 00h, 00h, 08h, 26h
		db	0A8h,0F1h, 00h, 01h,0D3h, 44h
		db	0F1h, 00h, 01h,0F3h, 89h,0F1h
		db	 00h, 01h,0A9h, 01h,0F1h, 00h
		db	 01h, 58h, 0Bh,0F1h, 00h, 01h
		db	 0Ch, 13h,0F1h, 00h, 01h, 06h
		db	 92h,0F1h, 00h, 01h, 47h, 24h
		db	0F1h, 00h, 01h, 26h,0A0h,0F1h
		db	 00h, 01h,0D3h, 44h,0F1h, 00h
		db	 01h,0F3h, 89h,0F1h, 00h, 01h
		db	0A9h, 01h,0F1h, 00h, 01h, 58h
		db	 0Bh,0F1h, 00h, 01h, 0Ch, 13h
		db	 00h, 00h, 04h, 9Bh, 04h,0FFh
		db	 04h,0FFh,0A6h, 80h,0FFh, 80h
		db	0FFh,0BFh,0AAh,0A8h,0FFh,0FCh
		db	0AAh,0A9h, 20h,0A8h, 35h,0FCh
		db	 20h,0A9h, 00h, 28h, 01h, 7Ch
		db	 00h, 29h, 00h, 38h, 00h, 3Ch
		db	 00h, 39h, 00h,0F8h, 00h,0FCh
		db	 00h,0F9h,0F1h, 00h, 00h, 15h
		db	 00h, 00h,0B2h, 66h,0FFh, 67h
		db	0FFh, 67h, 04h,0A8h, 04h,0F9h
		db	0FDh,0AAh,0A8h,0A8h,0FCh,0F9h
		db	0A9h,0AAh,0A8h,0A8h,0FCh,0F9h
		db	0A9h,0AAh,0A8h,0A8h,0FCh,0F9h
		db	0A9h,0AAh,0A8h,0A8h,0FCh,0F9h
		db	0A9h,0AAh,0AAh, 02h,0FEh, 03h
		db	0AAh,0FEh, 00h, 00h, 55h, 55h
		db	 00h, 00h,0A7h, 76h,0BFh,0FFh
		db	0BFh,0FFh, 0Ah, 84h, 1Fh,0C4h
		db	 6Ah, 9Dh, 82h, 0Ah, 87h, 0Eh
		db	0BAh, 7Ah, 82h, 4Ah, 92h, 4Eh
		db	0A6h,0DAh, 88h, 8Ah, 98h,0CEh
		db	0ABh, 9Ah, 88h, 8Ah, 9Dh,0CEh
		db	0A8h, 9Ah, 08h, 84h, 1Ch,0C4h
		db	 68h, 9Dh, 00h, 00h, 50h, 55h
		db	0F1h, 00h, 00h, 80h, 00h, 80h
		db	0F1h, 00h, 00h, 80h, 00h, 80h
		db	 00h, 00h, 03h,0A0h, 00h,0A0h
		db	 00h, 00h, 0Bh,0A8h, 08h,0A8h
		db	 00h, 00h, 0Ah,0A8h, 0Ah,0A8h
		db	 00h, 00h, 0Ah,0F8h, 0Ah,0F8h
		db	 00h, 00h, 02h,0E0h, 02h,0E0h
		db	0F1h, 00h, 0Dh, 01h, 98h,0F1h
		db	 00h, 01h, 1Ch, 7Ch, 08h, 30h
		db	 00h, 00h, 7Fh,0FAh, 39h, 80h
		db	 00h, 00h, 7Ch,0FDh, 18h, 40h
		db	 00h, 00h, 1Eh, 7Ah, 04h,0F1h
		db	 00h, 00h, 03h,0D0h,0F1h, 00h
		db	 02h,0C0h,0F1h, 00h, 01h, 18h
		db	0F1h, 00h, 02h, 3Eh, 1Ch, 18h
		db	 08h, 00h, 00h, 3Fh, 3Eh, 14h
		db	 30h, 00h, 00h, 7Fh,0FAh, 30h
		db	 20h, 00h, 00h, 7Ch, 7Dh, 10h
		db	 20h, 00h, 00h, 1Eh, 7Ah, 00h
		db	 10h,0F1h, 00h, 00h, 3Ah,0F1h
		db	 00h, 02h, 0Ch,0F1h, 00h, 08h
		db	 3Ah, 00h, 30h,0F1h, 00h, 00h
		db	 7Dh, 00h, 30h, 00h, 00h, 39h
		db	0FDh, 30h,0C0h, 00h, 00h, 7Fh
		db	0EAh, 62h,0F1h, 00h, 00h,0F7h
		db	 4Ch, 40h,0F1h, 00h, 00h, 6Ah
		db	0F1h, 00h, 02h, 38h,0F1h, 00h
		db	 02h, 03h,0C0h, 03h,0F1h, 00h
		db	 00h, 0Fh,0F0h, 06h,0F1h, 00h
		db	 00h, 1Fh,0D0h, 04h,0F1h, 00h
		db	 00h, 0Fh,0A0h,0F1h, 00h, 01h
		db	 03h,0D0h, 02h,0F1h, 00h, 00h
		db	 07h,0D8h, 07h,0F1h, 00h, 00h
		db	 07h,0B0h, 04h,0F1h, 00h, 00h
		db	 01h,0C0h, 00h, 00h

_378UNKN	endp

seg_a		ends



		end	start
