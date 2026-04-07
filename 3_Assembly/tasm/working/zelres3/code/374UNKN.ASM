
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_374UNKN                                 лл
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

_374UNKN	proc	far

start:
		pop	word ptr [si]
		add	[bx+si],al
		add	[bx],al
		inc	word ptr [bx+si]
		add	[bp+si],ax
		or	[bx+di],cl
		or	cl,[bp+di]
		or	al,0Fh
		adc	[bx+di],dl
		adc	dl,[bp+di]
		adc	al,15h
		push	ss
		pop	ss
		sbb	[bx+di],bl
		inc	word ptr [bx+si]
		add	cl,[bp+di]
		inc	word ptr [bx+si]
		add	[si],cl
		inc	word ptr [bx+si]
		add	[bx],cl
		push	cs
		or	ax,0FFh
		or	al,data_1
		db	0C0h, 00h, 80h, 06h, 00h, 02h
		db	 80h, 02h, 80h, 03h, 00h, 01h
		db	 00h, 01h, 00h, 01h, 80h, 00h
data_1		db	80h
		db	 00h, 80h, 00h,0C0h, 02h, 40h
		db	 02h, 40h, 00h, 88h, 06h, 88h
		db	 06h, 80h, 01h, 20h, 03h, 20h
		db	 02h, 00h, 05h, 40h, 01h, 40h
		db	 00h, 00h, 06h, 40h, 00h,0C0h
		db	 00h, 80h, 02h, 80h, 03h, 80h
		db	 03h, 00h, 0Bh, 00h, 01h, 00h
		db	 01h, 00h, 61h, 00h, 21h, 00h
		db	 21h,0FFh, 00h, 00h, 02h, 00h
		db	 02h, 00h, 02h, 80h, 06h, 80h
		db	 04h, 80h, 01h, 00h, 03h, 00h
		db	 02h, 00h, 00h, 80h, 01h, 80h
		db	 01h, 00h, 00h,0BCh, 00h,0D4h
		db	 00h,0D4h, 03h, 00h, 0Eh, 76h
		db	 0Eh, 60h, 0Ch, 00h, 33h,0DDh
		db	 32h, 0Ch, 00h, 00h, 3Dh,0D4h
		db	 2Dh, 90h, 04h, 0Ch, 3Dh,0D5h
		db	 0Ch, 88h, 00h, 0Ch, 1Fh, 50h
		db	 1Ah, 0Ch, 00h, 00h, 37h,0D7h
		db	 32h, 86h, 00h, 03h, 3Dh, 5Dh
		db	 18h, 0Ah, 08h, 00h, 07h, 8Ch
		db	 02h, 8Ch, 1Bh, 00h, 27h,0DFh
		db	 07h, 12h, 4Ch, 00h, 3Bh,0F0h
		db	 3Ah, 80h, 80h, 03h, 7Fh, 51h
		db	 4Ah, 02h, 00h, 00h,0DEh, 43h
		db	 4Ah,0FFh, 00h, 00h,0D1h, 93h
		db	 00h, 80h, 0Ch, 00h, 64h, 4Dh
		db	 48h,0FFh, 00h, 00h, 35h, 34h
		db	 20h, 00h, 32h, 80h, 2Fh, 00h
		db	 2Fh, 00h, 40h,0C0h, 3Eh,0F0h
		db	 3Ch,0C0h, 10h, 80h,0CBh, 6Ch
		db	 88h, 60h, 03h, 00h,0A8h,0BCh
		db	 00h, 90h, 32h, 00h,0A9h,0BCh
		db	 11h, 30h, 30h, 00h, 0Bh,0A8h
		db	 33h, 20h, 01h, 00h, 8Ah,0CCh
		db	 00h, 40h,0C0h, 00h,0AAh,0BCh
		db	 40h,0FFh, 00h, 00h, 4Dh, 93h
		db	 01h, 03h, 00h, 00h,0DEh,0C6h
		db	 4Ah, 86h, 00h, 00h, 3Dh, 76h
		db	 18h, 64h, 82h, 00h, 71h,0E1h
		db	 50h,0A1h, 48h, 00h,0D7h, 3Fh
		db	0C2h, 3Eh, 80h, 10h,0DEh,0FAh
		db	0CCh,0FAh, 00h, 00h, 4Ch,0FCh
		db	 08h,0D8h, 00h, 00h, 54h,0C9h
		db	 04h, 48h, 00h, 00h,0FAh,0C9h
		db	 3Ah, 00h, 00h, 10h, 7Ch, 90h
		db	 68h, 10h, 00h, 00h, 3Eh, 2Ah
		db	 3Ah, 00h, 00h, 80h, 38h, 98h
		db	 30h, 80h, 00h, 00h, 17h, 20h
		db	 12h, 00h, 08h, 00h, 8Eh, 84h
		db	 0Ch,0FFh, 00h, 00h, 47h, 12h
		db	 06h,0FFh, 00h, 00h, 03h, 00h
		db	 02h,0FFh, 00h, 00h, 74h, 15h
		db	0FFh, 00h, 01h, 08h, 0Ah,0FFh
		db	 00h, 01h, 40h,0FFh, 00h, 02h
		db	 01h, 08h,0FFh, 00h, 07h, 20h
		db	 40h,0FFh, 00h, 01h, 02h, 04h
		db	0FFh, 00h, 02h, 40h,0FFh, 00h
		db	 01h, 01h,0FFh, 00h, 02h, 20h
		db	 04h,0FFh, 00h, 01h, 01h,0FFh
		db	 00h, 08h, 04h,0FFh, 00h, 03h
		db	 08h,0FFh, 00h, 0Dh, 01h,0FFh
		db	 00h, 02h, 20h, 04h,0FFh, 00h
		db	 01h, 01h,0FFh, 00h, 08h, 04h
		db	0FFh, 00h, 03h, 20h,0FFh, 00h
		db	 01h, 20h,0FFh, 00h, 07h, 03h
		db	0FFh, 00h, 00h, 03h, 00h, 04h
		db	0FFh, 00h, 00h, 0Ch, 00h, 10h
		db	0FFh, 00h, 00h, 30h, 00h,0C0h
		db	 00h, 0Ah, 00h,0C0h, 01h, 00h
		db	 00h, 06h, 03h, 02h, 04h, 00h
		db	 00h, 0Bh, 0Ch, 01h, 10h, 00h
		db	 00h, 52h, 30h, 12h,0C0h, 00h
		db	 00h,0EFh,0C0h, 45h,0C0h,0FFh
		db	 00h, 00h,0C0h, 00h, 20h,0FFh
		db	 00h, 00h, 30h, 00h, 08h,0FFh
		db	 00h, 00h, 0Ch, 00h, 03h, 00h
		db	 50h, 00h, 03h, 00h, 00h, 80h
		db	 60h, 00h, 40h,0C0h, 00h, 20h
		db	0D0h, 00h, 80h, 30h, 00h, 08h
		db	 4Ah, 00h, 48h, 0Ch, 00h, 03h
		db	0F7h, 00h,0A2h, 03h, 07h, 00h
		db	 3Ah,0F4h, 00h, 00h, 03h, 00h
		db	 0Dh,0E8h, 00h, 00h, 70h, 00h
		db	 08h, 70h, 00h, 00h, 63h, 06h
		db	 38h, 02h, 00h, 00h, 67h, 3Ch
		db	 33h, 8Eh, 00h, 00h,0CCh, 30h
		db	 67h, 1Fh, 00h, 00h, 98h, 20h
		db	 4Eh, 9Ah,0FFh, 00h, 01h, 90h
		db	 20h, 00h, 00h, 07h, 00h, 01h
		db	 40h, 00h, 00h, 07h, 00h, 03h
		db	0E0h, 00h, 00h, 08h, 00h, 03h
		db	0D0h, 00h, 00h, 0Ch, 00h, 07h
		db	 80h, 00h, 00h, 18h, 70h, 0Eh
		db	 48h, 00h, 00h, 19h,0C0h, 0Ch
		db	 78h, 00h, 00h, 11h, 80h, 0Ch
		db	0F0h, 00h, 00h, 23h, 00h, 39h
		db	0E8h, 00h, 00h, 01h, 80h,0FFh
		db	 00h, 01h, 01h, 80h, 00h, 80h
		db	 00h, 00h, 01h, 00h, 01h, 80h
		db	0FFh, 00h, 01h, 01h,0C0h, 00h
		db	 00h, 02h, 00h, 00h,0C0h, 00h
		db	 00h, 03h, 00h, 02h, 40h, 00h
		db	 00h, 06h, 80h, 03h,0C0h,0FFh
		db	 00h, 01h, 04h,0E0h, 00h, 00h
		db	 15h, 15h, 2Ah,0AAh, 0Ah,0AAh
		db	 15h, 54h, 6Ah, 28h, 2Ah, 2Ch
		db	 55h, 59h,0A2h,0A2h, 22h,0AAh
		db	 55h, 54h,0AAh,0A8h, 2Ah,0ACh
		db	 15h, 55h, 68h,0AAh, 28h,0AAh
		db	 55h, 59h,0AAh,0A2h, 2Ah,0AAh
		db	 55h, 54h,0AAh, 28h, 2Ah, 2Ch
		db	 15h, 15h, 6Ah,0AAh, 2Ah,0AAh
		db	 55h, 55h,0A8h,0AAh,0A8h,0AAh
		db	 15h, 45h, 0Ah, 88h, 0Ah,0C8h
		db	 55h, 95h,0A2h, 22h,0B2h,0B2h
		db	 15h, 59h, 0Ah, 22h, 0Bh, 2Ah
		db	 61h, 01h, 8Eh, 02h,0AFh, 02h
		db	 66h, 55h, 88h,0A8h,0AAh,0ACh
		db	 14h, 54h, 08h,0A8h, 0Ch,0ACh
		db	 55h, 55h,0AAh, 8Ah,0AAh, 8Ah
		db	 55h, 55h, 2Ah,0AAh, 2Ah,0AAh
		db	 80h, 60h, 00h, 80h, 80h,0A0h
		db	 55h, 55h,0A2h, 8Ah,0B2h,0CBh
		db	 55h, 55h,0A2h, 8Ah,0B2h,0CBh
		db	 55h, 55h,0A2h, 8Ah,0B2h,0CBh
		db	 55h, 55h,0A2h, 8Ah,0B2h,0CBh
		db	 55h, 60h,0A2h, 80h,0B2h,0A0h
		db	 55h, 55h,0A8h, 2Ah,0A8h, 2Ah
		db	 51h, 55h,0A8h,0AAh,0A8h,0AAh
		db	 65h, 54h, 8Ah, 88h,0AAh,0CCh
		db	 65h, 59h, 02h, 82h, 22h,0CAh
		db	 61h, 59h, 02h, 82h, 22h,0CAh
		db	 66h, 19h, 08h, 02h, 2Ah, 0Ah
		db	 65h, 19h, 0Ah, 02h, 2Bh, 0Ah
		db	 65h, 54h, 8Ah, 88h,0AAh,0CCh
		db	 51h, 55h,0FFh,0AAh, 01h, 55h
		db	 50h,0AAh, 2Ch,0AAh, 28h, 15h
		db	 14h, 0Ah,0AAh, 0Ah,0A8h, 65h
		db	 54h, 8Ah,0ABh,0AAh,0AAh, 64h
		db	 54h, 8Ah,0ABh,0AAh,0AAh, 65h
		db	 44h, 8Ah,0ABh,0AAh,0AAh, 61h
		db	 50h, 8Ah,0ACh,0AAh,0A8h, 15h
		db	 54h, 08h, 2Ah, 08h, 28h, 55h
		db	 10h,0AAh,0ACh,0AAh,0A8h, 14h
		db	 55h, 4Ah,0AAh, 0Ah,0AAh, 61h
		db	 46h, 82h, 80h, 22h,0C2h, 51h
		db	 85h, 20h, 0Ah, 30h, 8Bh, 56h
		db	 65h,0A0h, 0Ah, 32h, 2Bh, 55h
		db	 65h,0A2h, 8Ah, 33h,0ABh, 15h
		db	 65h, 62h, 8Ah, 32h,0ABh, 64h
		db	 65h, 82h, 82h, 22h,0A2h, 15h
		db	 55h, 48h,0AAh, 08h,0AAh, 45h
		db	 55h,0FFh,0AAh, 01h, 54h, 40h
		db	 08h, 80h, 0Ch,0C0h, 55h, 61h
		db	 28h, 8Ah, 2Ch,0AAh, 55h, 65h
		db	 28h, 8Ah, 2Ch,0AAh, 55h, 60h
		db	 28h, 80h, 2Ch,0A0h, 55h, 66h
		db	 28h, 88h, 2Ch,0AAh, 81h, 45h
		db	 02h, 8Ah, 82h,0CBh, 54h, 51h
		db	0FFh,0AAh, 01h, 55h, 45h,0A2h
		db	0B2h,0A2h,0B2h, 51h, 16h, 2Ah
		db	 20h, 2Bh, 22h, 96h, 55h, 28h
		db	 8Ah,0AAh,0CBh, 85h, 65h, 38h
		db	 8Ah,0BCh,0ABh, 54h, 05h, 28h
		db	 0Ah, 2Ch, 0Bh, 59h, 55h,0A2h
		db	0A2h,0AAh,0B3h, 11h, 51h, 22h
		db	0A2h, 32h,0B3h, 54h, 55h,0FFh
		db	0AAh, 01h, 51h, 51h,0AAh,0AEh
		db	0AAh,0AEh, 55h, 95h, 22h, 0Ah
		db	 22h, 8Ah, 41h, 55h, 2Ah, 8Ah
		db	 2Ah,0CAh, 45h, 55h, 2Ah, 8Ah
		db	 2Ah,0CAh, 55h, 55h, 2Ah, 8Ah
		db	 2Ah,0CAh, 55h, 55h, 2Ah, 8Ah
		db	 2Eh,0CBh, 01h, 40h, 00h, 80h
		db	 00h,0C0h, 55h, 41h,0AAh, 2Ah
		db	0AAh, 2Ah, 55h, 50h, 2Ah,0ACh
		db	 2Ah,0A8h, 56h, 54h,0A8h, 2Ah
		db	0AAh, 28h, 15h, 94h,0A8h, 23h
		db	0ACh,0A2h, 59h, 54h,0A2h, 89h
		db	0AAh,0C8h, 58h, 14h,0A0h, 0Ah
		db	0A8h, 0Ah, 55h, 64h,0A2h, 8Bh
		db	0B2h,0AAh, 65h, 64h, 02h, 82h
		db	 22h,0A0h, 54h, 50h,0AAh,0ACh
		db	0AAh,0A8h

_374UNKN	endp

seg_a		ends



		end	start
