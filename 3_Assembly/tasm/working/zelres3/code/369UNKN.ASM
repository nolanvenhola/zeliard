
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_369UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_9e		equ	1920h			;*
data_10e	equ	7F03h			;*
data_11e	equ	0AA1Dh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_369UNKN	proc	far

start:
		dec	di
		adc	ax,0
		add	byte ptr ds:[19h],al
		sbb	ax,ds:data_11e[bx+si]
		xor	[bx+di],ax
		xor	al,[bp+si]
		inc	si
		add	cx,[bx+di-60h]
		dec	dx
		inc	ax
		dec	sp
		mov	[di+4],cl
		push	bx
		or	[di+20h],bl
		db	 6Bh,0A8h, 6Dh, 0Ah, 6Eh, 10h
		db	 6Fh, 22h, 71h,0FFh, 72h, 0Fh
		db	 73h,0A2h, 79h, 2Ah, 93h,0EAh
		db	 9Bh, 50h, 9Eh,0C0h,0ACh, 05h
		db	0B2h, 0Eh,0B3h, 28h,0C2h, 55h
		db	0C5h,0E0h,0C6h, 6Ah,0C8h, 0Ch
		db	0CBh, 15h,0CDh,0D0h,0CEh, 8Ah
		db	0D1h, 9Ah,0D3h,0F0h
data_2		db	0D7h			; Data table (indexed access)
		db	 14h,0DBh, 60h,0DCh, 11h,0E2h
		db	 18h,0E5h, 54h,0E7h,0E8h,0EDh
		db	0FCh,0F1h, 07h,0FFh,0FFh, 19h
		db	 2Fh,0C0h, 19h, 00h, 03h,0A0h
		db	 19h, 00h, 03h
data_3		dw	198Bh
		db	 00h, 0Fh,0C3h, 19h, 10h, 3Ch
		db	 8Ch, 19h, 00h,0EAh,0F8h, 19h
		db	 00h,0AAh,0A0h, 19h, 00h,0AEh
		db	 88h, 19h, 01h
		db	3Fh
data_4		db	0			; Data table (indexed access)
		db	 3Dh, 00h,0FFh, 00h,0C1h, 03h
		db	0FFh, 03h,0C7h, 03h,0FCh, 03h
		db	 7Fh, 0Fh,0F0h, 0Fh,0FFh, 0Fh
		db	0F0h, 0Dh,0FFh, 0Fh,0F3h, 0Fh
		db	0FCh, 0Fh,0FFh, 00h, 3Ch,0FCh
		db	 00h,0FCh, 00h,0FFh,0C0h, 7Dh
		db	0C0h,0FFh,0F0h,0FFh,0F0h, 0Fh
		db	0F0h,0FFh,0F0h, 7Fh,0FCh, 83h
		db	0F0h,0EAh,0F8h, 19h, 00h,0AAh
		db	0A0h, 19h, 00h,0AEh, 88h, 19h
		db	 01h, 3Fh, 00h, 3Dh, 00h,0FFh
		db	 00h,0C1h, 03h,0F8h, 03h,0C7h
		db	 03h,0F0h, 03h, 7Fh, 0Fh,0C0h
		db	 0Fh,0FFh, 0Fh,0C0h, 0Dh,0FFh
		db	 0Fh,0C3h, 0Fh,0FCh, 0Fh,0F3h
		db	 00h, 3Ch,0FCh, 00h,0FCh, 00h
		db	0FFh,0C0h, 7Dh,0C0h, 0Fh,0F0h
		db	0FFh,0F0h, 03h,0F0h
loc_1:
;*		push	ax
		db	0FFh,0F0h		;  Fixup - byte match
		jge	loc_1			; Jump if > or =
;*		xor	ax,0FFEAh
		db	 83h,0F0h,0EAh		;  Fixup - byte match
		clc				; Clear carry flag
		sbb	[bx+si],ax
		stosb				; Store al to es:[di]
		mov	al,byte ptr ds:[19h]
		scasb				; Scan es:[di] for al
		mov	[bx+di],bl
		add	[bx],di
		add	[di],bh
;*		add	dh,bh
		db	 00h,0FEh		;  Fixup - byte match
;*		add	cl,al
		db	 00h,0C1h		;  Fixup - byte match
		add	di,ax
		add	ax,di
		add	ax,ds:data_10e[bx+si]
		push	cs
		add	[bx],cl
		dec	data_6
		dec	data_8
		cld				; Clear direction
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		retn
		db	 00h, 3Ch,0FCh, 00h,0FCh, 00h
		db	 87h,0C0h, 7Dh,0C0h, 00h,0F0h
		db	0FFh,0F0h, 00h, 30h,0FFh,0F0h
		db	 7Ch, 3Ch, 83h,0F0h,0EAh,0F8h
		db	 19h, 00h,0AAh,0A0h, 19h, 00h
		db	0AEh, 88h, 19h, 00h, 3Ah,0EEh
		db	 19h, 00h, 39h, 9Ah, 19h, 00h
		db	 36h, 9Ah, 19h, 00h, 39h, 9Ah
		db	 19h, 00h,0E6h, 6Ah, 19h, 00h
		db	0EAh, 69h, 19h, 00h,0D9h,0AAh
		db	 19h, 00h,0EAh,0A8h, 19h, 00h
		db	0EAh,0A0h, 19h, 00h, 9Ah, 28h
		db	 19h, 00h, 9Ah, 80h, 19h, 00h
		db	 6Ah, 20h, 19h, 00h, 6Ah, 80h
		db	 19h, 00h,0AAh, 20h, 19h, 00h
		db	0A8h, 80h, 19h, 00h,0A2h, 19h
		db	 01h,0EAh,0A2h, 19h, 00h,0DAh
		db	 6Ah, 19h, 00h,0EAh,0A5h, 19h
		db	 00h,0E9h, 98h, 19h, 00h,0E6h
		db	 62h, 19h, 00h, 3Fh,0FFh, 15h
		db	 55h,0FFh,0AAh, 57h,0AAh,0FFh
		db	0A8h, 5Fh,0A8h, 22h, 19h, 01h
		db	 48h, 80h, 19h, 00h, 22h, 19h
		db	 01h, 88h, 80h, 19h, 00h, 22h
		db	 19h, 01h,0FFh, 80h, 55h, 80h
		db	 22h,0A0h, 22h,0A0h, 00h,0A0h
		db	 00h,0A0h, 19h, 07h, 03h, 19h
		db	 01h, 03h, 19h, 01h, 03h, 19h
		db	 01h, 03h, 19h, 01h, 03h, 19h
		db	 01h, 0Fh, 19h, 00h,0FFh,0EAh
		db	 5Fh,0EAh,0FFh,0AEh, 57h,0A1h
		db	0FFh,0AAh, 00h, 55h,0BBh,0A8h
		db	 44h, 56h,0EEh,0A0h, 11h, 5Ah
		db	0BAh, 88h, 45h, 66h,0EEh,0A0h
		db	 11h, 5Ah,0BAh, 88h, 45h, 66h
		db	 22h,0A0h, 22h,0A0h,0FEh, 80h
		db	 01h, 60h, 2Ah,0A0h,0D5h, 58h
		db	 1Ah,0A0h, 25h, 58h, 18h,0A8h
		db	 26h, 56h, 18h,0A8h, 26h, 56h
		db	 1Ah, 20h, 25h, 9Ah, 1Ah, 08h
		db	 25h,0A6h, 00h, 0Eh, 00h, 01h
		db	 00h, 0Fh, 19h, 01h, 0Eh, 00h
		db	 01h, 00h, 0Fh, 19h, 03h, 0Dh
		db	 00h, 03h, 19h, 01h, 03h, 19h
		db	 01h, 03h, 19h, 00h,0E8h,0A0h
		db	 16h, 5Ah,0AAh, 88h, 55h, 64h
		db	0EAh, 20h, 15h, 94h, 88h, 80h
		db	 66h, 58h, 19h, 00h, 55h, 60h
		db	 80h, 02h, 19h, 00h,0AAh, 88h
		db	 19h, 00h,0AAh,0A0h, 19h, 00h
		db	 86h, 22h, 09h, 99h, 24h, 88h
		db	 0Ah, 66h, 82h, 22h, 09h, 99h
		db	 24h, 88h, 0Ah, 66h, 81h, 00h
		db	 0Ah,0AAh, 20h, 00h, 02h,0AAh
		db	 4Ch, 00h, 19h, 00h,0A2h, 28h
		db	 19h, 00h,0AAh, 88h, 19h, 00h
		db	0A9h,0A2h, 19h, 00h,0AAh,0A8h
		db	 19h, 00h,0E6h,0A2h, 19h, 00h
		db	0EAh,0A2h, 19h, 00h, 6Ah, 68h
		db	 19h, 00h, 3Ah,0A8h, 19h, 00h
		db	 3Ah,0AAh, 19h, 00h,0A8h, 80h
		db	 19h, 00h, 22h, 20h, 19h, 00h
		db	0A8h, 80h, 19h, 00h, 2Ah, 20h
		db	 19h, 00h,0A8h, 80h, 19h, 00h
		db	 8Ah, 20h, 19h, 00h,0A8h, 80h
		db	 19h, 00h, 22h, 19h, 01h, 1Ah
		db	0A8h, 19h, 00h, 0Eh,0AAh, 19h
		db	 00h, 06h,0A6h, 19h, 00h, 03h
		db	0AAh, 19h, 00h, 01h, 6Ah, 19h
		db	 01h,0D6h, 19h, 01h, 39h, 19h
		db	 01h, 39h, 19h, 00h,0A8h, 80h
		db	 19h, 00h,0A2h, 19h, 01h,0A8h
		db	 80h, 19h, 00h,0A0h, 19h, 01h
		db	0A8h,0A0h, 19h, 00h,0AAh, 20h
		db	 19h, 00h, 6Ah, 88h, 19h, 00h
		db	0A2h,0A0h, 19h, 01h, 02h, 00h
		db	 28h, 00h, 18h, 00h, 26h, 00h
		db	 14h, 00h, 2Bh, 00h, 10h, 00h
		db	 2Fh, 19h, 01h, 3Eh, 19h, 01h
		db	 08h, 00h, 04h, 00h, 0Bh, 19h
		db	 01h, 03h,0AAh, 8Ah, 19h, 00h
		db	 73h, 00h, 19h, 00h, 2Ah,0A8h
		db	 80h, 00h, 2Ah, 22h, 80h, 00h
		db	 2Ah,0A8h, 80h, 00h, 02h,0A2h
		db	 68h, 19h, 00h,0A8h, 9Ah, 19h
		db	 00h, 22h,0A6h, 80h, 00h, 01h
		db	 00h, 02h, 19h, 13h, 01h, 00h
		db	 02h, 00h, 04h, 00h, 0Bh, 00h
		db	 1Fh,0E6h, 9Fh, 00h, 17h,0E6h
		db	 97h, 40h, 15h,0A6h, 95h, 40h
		db	 00h,0A6h, 80h, 40h, 2Ah,0A6h
		db	 80h, 40h, 08h,0B6h, 80h, 00h
		db	 22h,0F6h, 19h, 00h, 88h, 5Ah
		db	 00h,0C0h, 00h,0C0h, 00h, 40h
		db	 00h, 40h, 00h, 80h, 00h, 80h
		db	 19h, 16h, 02h, 00h, 03h, 19h
		db	 01h, 03h, 19h, 01h, 30h, 00h
		db	 0Ah, 00h,0E0h, 6Dh, 00h,0E0h
		db	 28h, 0Ah, 02h,0E0h, 08h, 0Ah
		db	 19h, 01h, 2Ah,0AAh, 00h, 7Dh
		db	0AAh, 7Dh,0C0h, 55h, 2Ah, 55h
		db	0A0h, 00h, 0Ah, 00h, 2Ah,0AAh
		db	 19h, 00h, 0Ah, 88h, 80h, 00h
		db	 02h,0A2h,0A0h, 19h, 01h, 1Dh
		db	 00h, 19h, 00h, 1Dh, 00h, 19h
		db	 0Ah, 80h, 19h, 01h, 80h, 19h
		db	 07h, 80h, 19h, 01h, 80h, 19h
		db	 00h, 03h, 19h, 01h, 05h, 19h
		db	 01h, 05h, 19h, 01h, 0Ch, 19h
		db	 01h, 0Ch, 19h, 01h, 0Ch, 19h
		db	 01h, 0Eh, 19h, 01h, 18h, 19h
		db	 01h, 3Ah, 19h, 01h, 38h, 19h
		db	 01h, 3Ah, 19h, 01h, 3Ah, 19h
		db	 01h, 36h, 19h, 01h, 3Ah, 19h
		db	 01h, 1Ah, 19h, 01h, 0Eh, 19h
		db	 00h, 1Ah,0A8h, 19h, 00h, 8Eh
		db	0AAh, 19h, 00h, 06h,0A6h, 19h
		db	 00h, 83h,0AAh, 19h, 00h, 01h
		db	 6Ah, 19h, 00h, 80h,0D6h, 19h
		db	 00h,0A2h, 39h, 19h, 00h,0A8h
		db	 39h, 19h, 01h, 1Ah, 19h, 01h
		db	 02h, 00h, 34h, 00h, 50h, 00h
		db	0ADh, 00h, 40h, 00h,0B5h, 19h
		db	 01h, 5Fh, 19h, 01h, 35h, 19h
		db	 01h, 05h, 19h, 02h,0A2h, 02h
		db	 00h, 28h,0A8h, 98h, 00h, 26h
		db	0A0h, 14h, 00h, 2Bh, 88h, 90h
		db	 00h, 2Fh, 2Ah, 00h, 40h, 3Eh
		db	 00h, 80h, 75h, 08h, 00h, 04h
		db	0FDh, 5Bh, 19h, 00h, 7Fh, 57h
		db	 10h, 01h, 2Dh,0D6h, 00h, 02h
		db	 07h, 74h, 19h, 00h, 02h,0D5h
		db	 01h, 00h, 02h, 95h, 19h, 01h
		db	 9Dh, 19h, 01h,0B4h, 00h, 01h
		db	 00h, 92h, 00h, 24h, 03h, 4Bh
		db	 00h, 28h, 00h, 02h, 00h, 23h
		db	 19h, 01h,0A3h, 19h, 00h, 02h
		db	 30h, 00h, 0Ah, 20h,0E0h, 6Dh
		db	 00h,0E0h, 28h, 0Ah, 02h,0E0h
		db	 08h, 0Ah, 19h, 01h, 2Ah,0AAh
		db	 00h, 0Eh, 00h, 01h, 00h, 0Fh
		db	 19h, 01h, 0Eh, 00h, 01h, 00h
		db	 0Fh, 19h, 01h, 30h, 00h, 0Dh
		db	 00h,0E8h, 19h, 01h,0EAh, 19h
		db	 00h, 03h,0A8h, 19h, 00h,0E8h
		db	0A0h, 16h, 5Ah,0AAh, 88h, 55h
		db	 64h,0EAh, 20h, 15h, 94h, 88h
		db	 80h, 66h, 58h, 19h, 00h, 55h
		db	 60h, 03h, 02h, 19h, 00h, 03h
		db	 88h, 19h, 00h,0A3h,0A2h, 19h
		db	 00h, 86h, 22h, 09h, 99h, 24h
		db	 88h, 0Ah, 66h, 82h, 22h, 09h
		db	 99h, 24h, 88h, 0Ah, 66h, 81h
		db	 00h, 0Ah,0AAh, 20h, 00h, 02h
		db	0AAh, 4Ch, 00h, 19h, 00h, 02h
		db	 22h, 19h, 02h, 80h, 19h, 01h
		db	 80h, 19h, 01h, 80h, 19h, 01h
		db	 80h, 19h, 01h, 80h, 19h, 01h
		db	 80h, 19h, 07h, 02h,0AAh, 19h
		db	 00h, 0Eh,0AAh, 19h, 00h, 0Ah
		db	0AAh, 19h, 00h, 3Ah, 68h, 19h
		db	 00h, 2Ah,0AAh, 19h, 00h, 6Ah
		db	0A8h, 19h, 00h,0E9h,0AAh, 19h
		db	 00h,0AAh,0A8h, 19h, 00h, 0Bh
		db	0A8h, 19h, 00h, 83h,0AAh, 19h
		db	 00h, 23h,0A9h, 19h, 00h, 89h
		db	 6Ah, 19h, 00h, 20h,0EAh, 19h
		db	 00h, 88h,0DAh, 19h, 00h, 22h
		db	 5Ah, 19h, 00h, 88h,0B6h, 19h
		db	 00h, 4Ch, 00h, 19h, 00h, 29h
		db	 22h, 19h, 00h, 8Ah, 88h, 19h
		db	 00h, 52h, 62h, 19h, 00h, 92h
		db	 98h, 19h, 00h, 61h,0A2h, 19h
		db	 00h, 98h, 48h, 19h, 00h,0A9h
		db	 22h, 19h, 04h, 80h, 19h, 01h
		db	 40h, 19h, 05h,0A0h, 19h, 01h
		db	 20h, 19h, 01h, 80h, 19h, 01h
		db	 10h, 19h, 01h,0AAh, 60h, 19h
		db	 00h,0EAh,0A8h, 19h, 00h, 6Ah
		db	0AAh, 19h, 00h, 6Ah,0A8h, 19h
		db	 00h, 2Ah, 82h, 19h, 00h, 02h
		db	0A0h, 3Ch, 00h, 50h,0AAh,0AEh
		db	 00h, 40h,0AAh,0BEh, 00h, 22h
		db	 16h, 19h, 00h, 88h, 0Eh, 19h
		db	 00h, 20h, 05h, 19h, 00h,0A0h
		db	 01h, 19h, 04h, 80h, 19h, 01h
		db	 20h, 19h, 01h, 80h, 19h, 01h
		db	 6Ah, 58h, 19h, 00h,0AAh, 96h
		db	 19h, 00h, 56h,0A6h, 19h, 00h
		db	 69h, 6Ah, 19h, 00h, 2Ah, 96h
		db	 19h, 00h, 0Ah, 9Ah, 19h, 01h
		db	 2Ah, 02h, 80h, 01h, 8Ah, 02h
		db	 60h,0A0h, 19h, 01h, 28h, 19h
		db	 01h, 88h, 19h, 01h,0A2h, 19h
		db	 01h,0A8h, 19h, 01h, 2Ah, 19h
		db	 01h,0A8h, 80h, 19h, 00h, 2Ah
		db	 19h, 02h,0AAh,0FEh, 19h, 00h
		db	 02h, 3Ah,0A0h, 19h, 00h, 2Ah
		db	0AAh, 19h, 00h, 0Fh,0AAh, 19h
		db	 00h, 0Eh,0DAh, 19h, 00h, 03h
		db	0B6h, 01h, 00h, 02h,0FAh, 19h
		db	 01h,0EEh, 24h, 19h, 01h, 8Dh
		db	 00h, 0Dh, 00h,0F5h, 00h,0F5h
		db	 00h, 14h, 80h, 14h, 00h, 02h
		db	 1Bh, 00h, 00h, 08h, 80h, 40h
		db	 00h, 0Ah,0C0h, 80h,0C0h, 0Bh
		db	 80h, 8Bh, 80h, 01h, 42h, 02h
		db	0B8h, 01h, 32h, 00h,0F8h, 00h
		db	 02h, 03h,0E8h, 19h, 01h, 86h
		db	 00h, 40h, 00h,0B9h, 19h, 01h
		db	 3Ah, 00h, 10h, 00h, 2Eh, 19h
		db	 01h, 0Eh,0AAh, 80h, 19h, 00h
		db	0A2h, 20h, 19h, 00h,0AAh, 88h
		db	 19h, 00h, 2Ah, 20h, 80h, 00h
		db	 0Ah, 88h,0A0h, 00h, 02h, 28h
		db	 68h, 00h, 01h,0FCh, 69h,0FCh
		db	 01h, 74h, 69h, 74h, 01h, 00h
		db	 02h,0FAh, 19h, 01h,0FAh, 19h
		db	 01h,0AEh, 00h, 40h, 00h,0BAh
		db	 19h, 01h,0AAh, 01h, 00h, 02h
		db	0A8h, 00h, 05h, 02h, 88h, 00h
		db	 01h, 00h, 02h, 15h, 40h, 95h
		db	 00h, 20h, 80h,0A0h, 00h, 0Ah
		db	 40h, 1Bh, 00h, 04h, 80h, 08h
		db	 00h, 21h, 80h, 02h, 00h, 88h
		db	 50h, 00h, 20h, 25h, 10h, 08h
		db	 00h, 54h, 44h, 00h, 08h, 19h
		db	 02h, 08h, 19h, 0Dh, 01h, 00h
		db	 01h, 19h, 00h, 02h, 00h, 02h
		db	 19h, 0Ah, 02h, 19h, 09h, 08h
		db	 00h, 08h, 19h, 04h, 08h, 00h
		db	 08h, 00h, 01h, 00h, 02h, 19h
		db	 01h, 0Eh, 00h, 10h, 00h, 0Ah
		db	 00h, 04h, 03h, 82h, 19h, 00h
		db	 02h,0E8h, 35h, 19h, 00h,0AAh
		db	 14h, 00h, 02h,0AAh, 19h, 00h
		db	 2Ah, 00h, 51h, 14h, 00h, 20h
		db	 05h, 00h, 82h, 0Ah, 19h, 00h
		db	0E8h,0AAh, 19h, 00h,0AAh,0A0h
		db	 19h, 00h,0AAh, 19h, 01h,0A0h
		db	 19h, 1Ch, 03h, 19h, 01h, 0Fh
		db	 19h, 01h, 3Fh, 19h, 01h, 0Eh
		db	 00h, 01h, 00h, 3Fh, 19h, 00h
		db	 03h,0DEh, 00h, 01h, 3Fh, 7Fh
		db	 19h, 00h,0DDh,0D0h, 00h, 0Dh
		db	 77h, 74h, 19h, 00h,0D5h, 51h
		db	 19h, 00h, 76h, 54h, 19h, 01h
		db	 35h, 19h, 01h,0DDh, 19h, 00h
		db	 03h, 55h, 19h, 00h, 03h, 55h
		db	 19h, 00h, 0Dh,0D6h, 19h, 00h
		db	 0Dh, 55h, 19h, 00h, 37h, 55h
		db	 19h, 00h, 35h, 55h, 19h, 00h
		db	 55h, 51h, 19h, 00h, 55h, 54h
		db	 19h, 00h, 65h, 51h, 19h, 00h
		db	 55h, 44h, 19h, 00h, 55h, 11h
		db	 19h, 00h, 54h, 55h, 19h, 00h
		db	 51h, 10h, 19h, 00h, 54h, 40h
		db	 19h, 00h, 13h,0A8h, 19h, 00h
		db	 43h,0AAh, 19h, 00h, 17h,0A9h
		db	 19h, 00h, 51h, 6Ah, 19h, 00h
		db	 40h,0EAh, 19h, 01h,0DAh, 19h
		db	 01h, 5Ah, 19h, 01h,0B6h, 19h
		db	 01h, 07h, 00h, 08h, 00h, 05h
		db	 00h, 0Ah, 00h, 04h, 00h, 0Bh
		db	 19h, 01h, 0Fh, 19h, 01h, 05h
		db	 19h, 01h, 03h, 19h, 01h, 03h
		db	 00h, 01h, 00h, 02h, 15h, 55h
		db	0C0h, 00h, 15h, 69h,0C0h, 00h
		db	 15h, 56h,0C0h, 00h, 01h, 52h
		db	 5Ch, 19h, 00h, 44h, 69h, 19h
		db	 00h, 11h,0E9h, 19h, 00h, 04h
		db	0F9h, 19h, 00h, 3Dh,0B9h, 3Ch
		db	 45h, 19h, 01h, 54h, 19h, 01h
		db	 40h, 19h, 05h, 40h, 19h, 05h
		db	 40h, 19h, 01h, 40h, 19h, 02h
		db	 16h, 19h, 01h, 0Eh, 19h, 01h
		db	 05h, 19h, 01h, 01h, 19h, 11h
		db	 01h, 00h, 02h, 19h, 01h, 07h
		db	 19h, 01h, 07h, 19h, 01h, 0Fh
		db	 00h, 04h, 00h, 0Bh, 00h, 04h
		db	 00h, 0Ah, 00h, 10h, 00h, 2Bh
		db	 00h, 40h, 00h, 95h, 00h,0AFh
		db	0E4h,0AFh, 00h, 6Ah,0E4h, 2Ah
		db	 01h, 44h, 90h, 19h, 00h, 50h
		db	 90h, 00h, 03h,0C4h, 97h,0C0h
		db	 02h,0E0h,0A6h,0E0h, 00h,0A0h
		db	 90h,0A0h, 05h, 50h, 40h, 19h
		db	 00h, 05h, 19h, 01h, 05h, 19h
		db	 01h, 15h, 19h, 01h, 01h, 00h
		db	 38h, 19h, 01h,0EAh, 01h, 50h
		db	 00h, 0Ah, 00h, 10h, 03h, 8Ah
		db	 19h, 00h, 0Eh,0AAh, 11h, 14h
		db	 19h, 00h, 45h, 44h, 19h, 00h
		db	 11h, 14h, 19h, 00h, 44h, 00h
		db	 02h,0A8h, 19h, 00h,0AAh,0A8h
		db	 19h, 00h,0A8h, 19h, 01h, 80h
		db	 19h, 03h, 05h, 19h, 00h,0A8h
		db	 14h, 00h, 02h,0A0h, 19h, 00h
		db	 0Ah, 19h, 1Ch, 03h, 19h, 01h
		db	 03h, 19h, 01h, 0Fh, 19h, 01h
		db	 3Bh, 00h, 04h, 03h,0F7h, 00h
		db	 08h,0FEh,0AFh, 19h, 11h, 03h
		db	 19h, 01h, 0Eh, 19h, 01h, 0Eh
		db	 01h,0A0h, 01h, 0Eh, 06h,0E0h
		db	 00h

locloop_2:
		aas				; Ascii adjust
		sbb	[bx+si],ax
		add	bp,bx
		sbb	[bx+si],ax
		db	 3Eh,0BAh, 19h, 00h,0EBh,0AAh
		db	 19h, 00h,0BAh, 9Ah, 19h, 00h
		db	0EAh,0A9h, 19h, 00h,0A6h,0AAh
		db	 19h, 00h, 1Dh, 00h, 19h, 00h
		db	0BBh,0AEh, 00h, 01h,0AAh,0A3h
		db	 00h, 04h, 9Ah,0A0h, 00h, 05h
		db	0AAh, 88h, 00h, 01h,0AAh,0A2h
		db	 19h, 00h,0A8h, 88h, 19h, 00h
		db	0A2h, 20h, 19h, 00h, 88h, 19h
		db	 01h, 04h, 12h, 0Bh, 40h,0D7h
		db	 00h, 29h, 80h, 11h, 04h, 26h
		db	 80h, 10h, 05h, 27h, 40h, 00h
		db	 01h, 1Fh, 60h, 04h, 00h, 0Bh
		db	0D8h, 04h, 01h, 0Bh,0D8h, 10h
		db	 00h, 2Fh, 78h, 28h,0A2h, 19h
		db	 00h, 8Ah, 88h, 19h, 00h, 18h
		db	0A0h, 19h, 00h, 40h, 19h, 01h
		db	 14h, 19h, 01h, 44h, 19h, 01h
		db	 14h, 19h, 01h, 40h, 19h, 01h
		db	 6Fh, 00h, 19h, 00h, 88h, 19h
		db	 19h, 03h,0A8h, 19h, 00h, 03h
		db	0AAh, 19h, 00h, 03h,0A9h, 19h
		db	 00h, 01h, 6Ah, 19h, 01h,0EAh
		db	 19h, 01h,0DAh, 19h, 01h, 5Ah
		db	 19h, 01h,0B6h, 19h, 05h, 04h
		db	 19h, 01h, 15h, 19h, 01h, 01h
		db	 00h, 14h, 19h, 01h, 0Dh, 19h
		db	 01h, 03h, 19h, 12h, 40h, 01h
		db	 10h, 02h, 01h, 00h, 54h, 1Fh
		db	 01h, 00h, 50h, 55h, 05h, 04h
		db	0D0h, 50h, 00h, 01h, 35h, 50h
		db	 10h, 01h, 2Fh, 60h, 40h, 08h
		db	0BDh,0E8h, 40h, 2Bh,0BDh,0ABh
		db	 00h, 0Eh,0F6h, 0Eh, 00h, 01h
		db	 76h, 00h, 02h,0C4h,0DAh,0C0h
		db	 02h,0E0h, 5Ah,0E0h, 00h, 80h
		db	 20h, 80h, 10h, 19h, 01h, 50h
		db	 19h, 01h
data_5		db	80h			; Data table (indexed access)
		db	 00h, 80h, 00h, 80h, 00h, 80h
		db	 19h, 10h, 01h, 09h, 60h, 00h
		db	 04h, 01h, 40h, 00h, 01h, 02h
		db	 50h, 19h, 01h, 94h, 19h, 01h
		db	 15h, 19h, 01h, 05h, 19h, 06h
		db	 11h, 19h, 01h, 44h, 19h, 01h
		db	 10h, 19h, 01h, 20h, 19h, 01h
		db	 80h, 19h, 0Eh, 04h, 00h, 0Ah
		db	 00h, 04h, 00h, 0Ah, 00h, 04h
		db	 00h, 0Ah, 00h, 04h, 00h, 0Bh
		db	 00h, 10h, 00h, 2Fh, 00h, 40h
		db	 00h,0B5h, 19h, 01h, 2Ah, 19h
		db	 01h, 02h, 01h, 58h, 69h, 58h
		db	 19h, 00h, 68h, 00h, 02h,0A0h
		db	 68h, 19h, 00h, 80h, 68h, 00h
		db	 02h, 20h, 60h, 00h, 08h,0D0h
		db	0A0h,0D0h, 07h, 50h,0A7h, 50h
		db	 05h, 00h,0A5h, 19h, 00h, 0Ah
		db	 19h, 01h, 0Ah, 00h, 10h, 00h
		db	 02h, 00h, 54h, 01h, 80h, 00h
		db	 15h, 00h, 80h,0ACh, 00h,0E0h
		db	 10h, 05h, 41h,0C0h, 00h, 01h
		db	 55h, 19h, 00h, 55h, 54h, 00h
		db	0A4h,0A0h, 00h,0A2h, 2Ah, 19h
		db	 00h, 88h, 8Ah, 19h, 00h,0A2h
		db	 19h, 00h, 15h, 19h, 00h, 41h
		db	 55h, 19h, 00h, 55h, 50h, 19h
		db	 00h, 54h, 19h, 14h, 03h, 19h
		db	 01h, 0Dh, 19h, 01h,0EBh, 19h
		db	 00h, 03h,0BAh, 19h, 01h, 0Eh
		db	 00h, 01h, 00h, 3Fh, 19h, 01h
		db	0E3h, 00h, 04h, 3Eh, 80h, 00h
		db	 01h,0EAh,0A2h, 19h, 00h,0BAh
		db	 88h
loc_3:
		sbb	[bx+si],ax
		stosb				; Store al to es:[di]
		test	al,19h
		add	ss:data_9e[bp+si],ch
;*		or	[bx+si+0],ax
		db	 09h, 40h, 00h		;  Fixup - byte match
		db	0B0h, 01h, 00h, 02h,0D0h, 01h
		db	 41h, 02h, 9Ch, 31h, 00h, 02h
		db	0F4h, 00h, 40h, 03h,0B7h, 19h
		db	 00h, 01h,0FDh, 0Dh,0A6h, 19h
		db	 00h, 3Bh, 9Ah, 19h, 00h,0E9h
		db	0AAh, 19h, 00h,0EAh,0AAh, 19h
		db	 00h, 66h,0A2h, 19h, 00h, 68h
		db	 88h, 19h, 00h, 51h, 02h, 19h
		db	 00h, 04h, 08h,0F0h, 00h, 98h
		db	0A8h, 19h, 00h, 6Ah, 80h, 19h
		db	 00h,0A2h, 20h, 19h, 00h,0A8h
		db	 88h, 19h, 00h, 22h, 28h, 19h
		db	 00h, 88h, 80h, 19h, 00h, 20h
		db	 19h, 05h, 23h,0A8h, 19h, 00h
		db	 8Bh,0AAh, 19h, 00h, 23h, 99h
		db	 19h, 00h, 83h,0AAh, 19h, 01h
		db	0AAh, 19h, 01h,0E6h, 19h, 01h
		db	0EAh, 19h, 01h, 6Ah, 19h, 03h
		db	0ABh, 19h, 01h,0AEh, 19h, 01h
		db	0FBh, 19h, 01h,0EEh, 19h, 01h
		db	0FEh, 01h, 00h, 02h,0EAh, 19h
		db	 00h, 01h,0B9h, 01h, 00h, 02h
		db	0F9h, 05h, 40h, 50h, 00h, 01h
		db	 10h, 90h, 19h, 00h, 40h, 90h
		db	 00h, 03h,0F0h, 43h,0F0h, 05h
		db	0D0h, 45h,0D0h, 05h, 60h, 45h
		db	 60h, 19h, 02h, 11h, 40h, 19h
		db	 10h, 0Dh, 19h, 00h, 40h, 15h
		db	 0Ch, 00h,0E1h, 00h, 04h, 15h
		db	0A1h, 00h, 01h, 05h, 54h, 01h
		db	 00h, 02h,0A9h, 06h, 00h, 09h
		db	0E4h, 18h, 02h, 67h,0A6h, 00h
		db	 02h, 16h, 96h, 19h, 00h, 01h
		db	 50h, 01h, 19h, 00h, 50h, 4Dh
		db	 00h, 50h, 00h, 01h, 11h, 50h
		db	 00h, 44h, 19h, 01h, 11h, 19h
		db	 01h,0C4h, 00h,0C0h, 00h,0E8h
		db	 00h,0E8h, 00h,0A0h, 00h,0A0h
		db	 00h, 40h, 19h, 01h, 40h, 19h
		db	 08h,0D5h, 19h, 01h, 0Dh, 19h
		db	 17h, 45h, 74h, 00h, 01h, 11h
		db	 54h, 19h, 00h, 06h,0D5h, 40h
		db	 19h, 00h, 0Dh, 50h, 19h, 00h
		db	 03h, 54h, 19h, 01h, 10h, 19h
		db	 16h, 80h, 19h, 05h, 80h, 19h
		db	 06h, 3Ah, 19h, 01h, 3Ah, 19h
		db	 01h, 1Ah, 19h, 01h, 0Eh, 19h
		db	 01h, 0Eh, 19h, 01h, 03h, 19h
		db	 01h, 01h, 19h, 04h, 6Ah, 88h
		db	 19h, 00h,0AAh,0A0h, 19h, 00h
		db	0A6h, 0Ah, 19h, 00h,0AAh,0A0h
		db	 19h, 00h,0A6h, 88h, 19h, 00h
		db	 1Dh, 00h, 19h, 00h,0AAh, 2Ah
		db	 19h, 00h, 6Ah,0AAh, 19h, 00h
		db	 40h, 19h, 01h, 80h, 19h, 01h
		db	 20h, 19h, 01h,0A0h, 19h, 01h
		db	 88h, 19h, 01h, 22h, 19h, 01h
		db	 88h, 80h, 19h, 00h, 22h, 20h
		db	 19h, 00h, 16h, 08h, 00h,0C0h
		db	 01h, 42h, 02h,0B0h, 03h, 40h
		db	 00h,0B4h, 01h, 00h, 02h,0FDh
		db	 19h, 01h,0FFh, 00h, 04h, 00h
		db	 2Bh, 19h, 01h, 02h, 19h, 02h
		db	 4Ch, 00h, 19h, 00h, 22h, 28h
		db	 19h, 01h,0AEh, 00h, 0Eh, 00h
		db	0BAh,0A8h,0BAh, 00h, 2Ah, 6Ah
		db	 2Ah, 00h, 28h,0DAh, 28h, 00h
		db	 02h,0F6h, 80h, 00h, 08h,0B6h
		db	 80h, 19h, 12h, 80h, 19h, 05h
		db	 80h, 19h, 02h, 0Fh, 3Dh, 8Fh
		db	 10h, 02h, 2Dh,0A2h, 00h, 02h
		db	 0Eh,0A2h, 04h, 00h, 0Ah,0E8h
		db	 04h, 00h, 0Bh,0A8h, 00h, 02h
		db	 0Fh,0A0h, 10h, 22h, 2Ah, 19h
		db	 00h, 88h, 19h, 00h, 80h, 00h
		db	 80h, 00h, 80h, 00h, 80h, 00h
		db	0A0h, 00h, 80h, 00h, 80h, 19h
		db	 01h, 28h, 19h, 01h, 8Ah, 19h
		db	 01h, 20h, 19h, 01h, 85h, 19h
		db	 01h, 14h, 40h, 19h, 00h, 40h
		db	 00h, 05h, 40h, 19h, 00h, 55h
		db	 40h, 19h, 00h, 54h, 19h, 01h
		db	 40h, 19h, 01h, 40h, 19h, 08h
		db	 3Eh, 00h, 01h, 00h, 3Bh, 00h
		db	 04h, 00h, 03h, 00h, 04h, 00h
		db	 28h, 00h, 01h, 03h,0AAh, 19h
		db	 00h, 0Eh,0B8h, 19h, 00h,0EBh
		db	0A8h, 19h, 00h,0BAh,0A8h, 19h
		db	 00h,0E8h,0A0h, 16h, 5Ah,0BAh
		db	 88h, 45h, 64h,0EAh, 20h, 15h
		db	 94h, 3Ch, 80h, 42h, 58h, 19h
		db	 00h, 15h, 60h, 3Bh, 19h, 01h
		db	 3Eh, 88h, 19h, 00h,0EAh,0A0h
		db	 19h, 00h, 08h, 00h, 08h, 19h
		db	 00h, 08h, 00h, 08h, 02h, 00h
		db	 02h, 19h, 04h, 01h, 00h, 01h
		db	 19h, 0Bh, 3Ah, 19h, 01h,0EAh
		db	 19h, 00h, 03h,0BAh, 19h, 00h
		db	 0Eh,0E9h, 19h, 00h, 3Bh,0AAh
		db	 19h, 00h, 3Ah,0AAh, 19h, 00h
		db	0EEh,0AAh, 19h, 00h,0EAh, 88h
		db	 19h, 00h,0E6h,0A0h, 19h, 00h
		db	0AAh, 08h, 19h, 00h, 98h, 20h
		db	 19h, 00h,0A2h, 19h, 01h, 82h
		db	 19h, 01h, 28h, 08h, 19h, 00h
		db	 90h, 22h, 19h, 00h, 42h, 28h
		db	 19h, 00h,0FAh, 88h, 19h, 00h
		db	0E8h,0A2h, 19h, 00h,0EAh, 88h
		db	 19h, 00h,0EAh, 22h, 19h, 00h
		db	0E6h,0AAh, 19h, 00h,0DAh, 22h
		db	 19h, 00h,0EAh,0A8h, 19h, 00h
		db	0EAh, 62h, 19h, 00h, 08h, 88h
		db	 19h, 00h, 22h, 20h, 19h, 00h
		db	 08h, 80h, 19h, 00h, 22h, 20h
		db	 19h, 00h, 88h, 80h, 19h, 00h
		db	 82h, 20h, 19h, 00h, 88h,0A0h
		db	 19h, 00h,0A2h, 80h, 19h, 00h
		db	0A8h,0A1h, 19h, 00h, 9Ah, 0Ah
		db	 19h, 00h, 2Ah, 1Bh, 00h, 00h
		db	 26h, 20h, 80h, 00h, 28h, 88h
		db	 80h, 00h, 02h, 22h, 68h, 19h
		db	 00h, 08h, 9Ah, 19h, 00h, 02h
		db	0A6h, 80h, 08h,0A0h, 19h, 00h
		db	 22h, 80h, 19h, 00h,0A0h, 19h
		db	 05h, 80h, 19h, 05h, 80h, 19h
		db	 05h,0EAh,0A8h, 19h, 00h,0E9h
		db	0A2h, 19h, 00h,0EAh,0AAh, 19h
		db	 00h,0EAh,0AAh, 19h, 00h,0E9h
		db	0AAh, 19h, 00h, 1Dh, 00h, 19h
		db	 00h, 3Ah, 98h, 19h
data_6		dw	3A00h
		db	0AAh, 19h, 00h, 88h, 80h, 19h
		db	 00h,0A2h, 80h, 19h, 00h, 88h
		db	 80h, 19h, 00h,0A2h, 19h, 01h
		db	 8Ah, 19h, 01h,0A2h, 19h, 01h
		db	 8Ah, 19h, 02h,0D8h, 00h,0D8h
		db	 2Ah,0A2h, 19h, 00h, 0Eh,0A8h
		db	 19h, 00h, 0Bh,0AAh, 19h, 00h
		db	 03h,0AAh, 19h, 00h, 02h,0EAh
		db	 19h, 01h,0AAh, 19h, 07h, 0Fh
		db	 82h,0F4h, 00h,0F4h, 08h,0D0h
		db	 00h,0D0h, 22h, 50h, 00h, 50h
		db	0A8h, 00h, 03h,0FEh,0A0h, 00h
		db	 0Eh,0AAh, 80h, 00h, 39h,0F7h
		db	 19h, 00h, 2Eh,0AAh, 19h, 00h
		db	0BAh, 55h, 80h, 19h, 01h,0A2h
		db	 19h, 01h, 88h,0D2h, 00h,0D0h
		db	 00h, 40h,0A0h, 40h, 00h, 02h
		db	0FFh,0E8h, 19h, 00h, 5Eh,0A8h
		db	 00h, 02h, 95h,0A0h, 00h, 08h
		db	 55h, 80h, 19h, 06h, 20h, 19h
		db	 01h, 80h, 00h, 0Ah, 00h, 20h
		db	 00h, 0Ah, 00h, 80h, 00h, 0Ah
		db	 19h, 01h, 2Ah, 19h, 01h,0AAh
		db	 19h, 02h, 3Dh, 19h, 01h,0F5h
		db	 19h, 18h, 95h, 19h, 01h, 40h
		db	 19h, 18h, 28h, 07h, 82h, 19h
		db	 00h, 01h, 02h, 00h, 02h, 19h
		db	 11h, 02h, 19h, 02h,0A2h, 00h
		db	 28h, 00h, 82h, 00h,0A0h, 00h
		db	 02h, 00h, 80h, 00h, 02h, 19h
		db	 01h,0AAh, 19h, 01h,0AAh, 00h
		db	0A0h, 00h, 08h, 00h, 80h, 00h
		db	 28h, 00h, 3Ah,0EEh, 19h, 00h
		db	 39h, 9Ah, 19h, 00h, 36h, 9Ah
		db	 19h, 00h, 39h, 9Ah, 19h, 00h
		db	 26h, 6Ah, 19h, 00h, 2Ah, 69h
		db	 19h, 00h, 09h,0AAh, 19h, 00h
		db	 0Ah,0A8h, 19h, 00h,0EAh,0A0h
		db	 19h, 00h, 9Ah, 28h, 19h, 00h
		db	 9Ah, 88h, 19h, 00h, 6Ah, 28h
		db	 19h, 00h, 6Ah, 8Ah, 19h, 00h
		db	0AAh, 2Ah, 19h, 00h,0A8h, 8Ah
		db	 19h, 00h,0A2h
data_7		dw	192Ah			; Data table (indexed access)
		db	 00h, 0Ah,0AAh, 19h, 00h, 02h
		db	 9Ah, 19h, 00h, 02h,0AAh, 19h
		db	 01h,0A9h, 19h, 01h,0A6h, 19h
		db	 01h, 3Fh, 00h, 15h, 00h,0FFh
		db	 00h, 57h, 00h,0FFh, 00h, 5Fh
		db	0A2h, 22h, 19h, 00h, 6Ah, 48h
		db	 19h, 00h,0A5h, 22h, 19h, 00h
		db	 98h, 88h, 19h, 00h, 62h, 22h
		db	 19h, 00h, 71h, 00h,0C2h, 00h
		db	0AAh, 22h,0AAh, 22h,0A8h, 00h
		db	0A8h, 19h, 03h, 80h, 19h, 05h
		db	 80h, 19h, 05h, 80h, 00h, 80h
		db	 00h,0A0h, 00h,0A0h, 00h,0A0h
		db	 00h,0A0h, 19h, 00h,0FFh, 00h
		db	 5Fh, 00h,0FFh, 00h, 57h, 03h
		db	0FFh, 19h, 00h, 03h,0BBh, 00h
		db	 44h, 03h,0EEh, 00h, 11h, 03h
		db	0BAh, 00h, 45h, 03h,0EEh, 00h
		db	 11h, 03h,0BAh, 00h, 45h,0EAh
		db	 22h,0EAh, 22h,0AEh,0FEh,0A1h
		db	 01h,0AAh, 2Ah, 55h,0D5h,0A8h
		db	 1Ah, 56h, 25h,0A0h, 18h, 5Ah
		db	 26h, 88h, 18h, 66h, 26h,0A0h
		db	 1Ah, 5Ah, 25h, 88h, 18h, 66h
		db	 26h,0A0h, 00h,0A0h, 00h, 80h
		db	 00h, 60h, 00h,0A0h, 00h, 58h
		db	 00h,0A0h, 00h, 58h, 00h,0A0h
		db	 00h, 58h, 00h, 88h, 00h, 66h
		db	 00h, 20h, 00h, 9Ah, 00h, 88h
		db	 00h, 66h, 00h, 03h,0EEh, 00h
		db	 11h, 03h,0BAh, 00h, 45h, 03h
		db	0EAh, 00h, 15h, 02h,0A2h, 01h
		db	 59h, 01h, 08h, 00h,0A6h, 01h
		db	0E0h, 00h, 0Ah, 04h,0EEh, 19h
		db	 00h, 07h,0BAh, 19h, 00h,0A0h
		db	 8Ah, 5Ah, 25h, 80h, 02h, 6Ah
		db	 29h, 88h, 02h, 66h, 09h, 5Dh
		db	 00h, 9Ah, 0Ah, 84h, 08h, 6Ah
		db	 82h, 00h, 20h,0AAh, 02h, 00h
		db	 88h, 19h, 00h,0A2h, 22h, 19h
		db	 00h, 20h, 00h, 9Ah, 40h, 88h
		db	 00h, 66h, 40h, 20h, 00h, 9Ah
		db	 40h, 88h, 00h
		db	66h
data_8		dw	1940h
		db	 00h,0AAh, 40h, 19h, 00h, 99h
		db	 00h,0A0h, 19h, 01h, 20h, 19h
		db	 12h, 01h, 19h, 01h, 01h, 19h
		db	 01h, 01h, 19h, 01h, 01h, 19h
		db	 00h, 12h,0EAh, 19h, 00h, 1Eh
		db	0BAh, 19h, 00h, 5Eh,0EAh, 19h
		db	 00h, 4Bh,0A6h, 19h, 00h, 7Eh
		db	0AAh, 19h, 00h, 7Eh, 6Ah, 19h
		db	 00h, 3Ah,0A8h, 19h, 00h, 2Eh
		db	0AAh, 19h, 00h, 4Ch, 00h, 19h
		db	 00h,0A2h, 22h, 19h, 00h, 4Ch
		db	 00h, 19h, 00h, 6Fh, 00h, 19h
		db	 00h,0CEh, 00h, 19h, 00h, 02h
		db	 20h, 19h, 00h, 8Ah,0A8h, 19h
		db	 00h, 2Ah,0A0h, 19h, 00h,0A0h
		db	 19h, 05h, 80h, 19h, 16h, 05h
		db	 19h, 01h, 04h, 19h, 01h, 04h
		db	 19h, 01h, 04h, 19h, 01h, 04h
		db	 19h, 01h, 14h, 19h, 01h, 11h
		db	 19h, 01h, 14h, 19h, 00h, 2Ah
		db	0A8h, 19h, 00h,0EEh,0AAh, 19h
		db	 00h,0FAh,0AAh, 19h, 00h,0EAh
		db	 68h, 19h, 00h,0EAh,0AAh, 19h
		db	 00h, 2Ah,0A2h, 19h, 00h, 3Ah
		db	0A8h, 19h, 00h, 0Ah, 22h, 19h
		db	 00h, 88h, 80h, 19h, 00h, 2Ah
		db	 80h, 19h, 00h,0A2h, 19h, 01h
		db	 8Ah, 19h, 01h, 28h, 19h, 05h
		db	 08h, 19h, 01h, 02h, 19h, 01h
		db	 4Eh, 88h, 19h, 00h, 04h,0AAh
		db	 38h, 00h, 14h, 00h,0ABh, 05h
		db	 10h, 00h,0AFh,0D5h, 14h, 00h
		db	 8Bh, 5Fh, 19h, 00h, 69h, 7Eh
		db	 19h, 00h, 9Ah, 2Bh, 00h, 04h
		db	0A6h, 8Bh, 28h, 80h, 19h, 00h
		db	 8Ah, 20h, 19h, 00h, 28h,0BCh
		db	 00h, 3Ch, 03h,0D5h, 43h,0D5h
		db	 01h, 74h, 51h, 74h, 00h, 10h
		db	0D4h, 10h, 00h, 05h,0B5h, 19h
		db	 00h, 22h,0FDh, 19h, 13h, 80h
		db	 19h, 01h, 80h, 19h, 05h, 40h
		db	 08h,0B9h, 40h, 00h, 0Fh,0BEh
		db	 4Fh, 80h, 01h,0AEh, 51h, 08h
		db	 00h, 07h, 94h, 02h, 00h, 01h
		db	0E4h, 02h, 00h, 01h, 94h, 00h
		db	 02h, 01h, 50h, 00h, 08h, 19h
		db	 00h,0E0h, 00h,0E0h, 00h,0D0h
		db	 00h,0D0h, 00h, 50h, 00h, 50h
		db	 00h, 08h, 19h, 01h, 28h, 19h
		db	 01h, 8Ah, 19h, 01h, 22h, 19h
		db	 01h, 88h, 80h, 19h, 01h, 7Dh
		db	0AAh, 7Dh,0C0h, 55h, 2Ah, 55h
		db	0A0h, 00h, 0Ah, 00h, 28h, 88h
		db	 19h, 00h, 0Ah, 03h, 80h, 19h
		db	 00h, 8Eh,0A0h, 19h, 00h, 0Ah
		db	0AAh, 80h, 19h, 00h,0AAh, 02h
		db	 00h, 2Ah, 19h, 01h, 08h, 00h
		db	0E0h, 00h, 02h, 03h,0A8h, 0Eh
		db	 80h, 30h, 2Ah, 02h, 00h,0E8h
		db	 2Ah, 80h, 00h, 2Ah,0A8h, 19h
		db	 00h,0AAh, 80h, 19h, 00h,0A0h
		db	 00h, 2Ah, 19h, 01h, 1Bh, 00h
		db	 19h, 00h, 20h, 00h, 0Ah, 80h
		db	 19h, 00h,0AAh, 80h, 19h, 00h
		db	0A8h, 19h, 1Ch, 04h, 19h, 05h
		db	 11h, 19h, 01h, 05h, 19h, 05h
		db	 01h, 19h, 00h, 01h, 04h, 19h
		db	 01h, 1Ah, 19h, 01h, 65h, 19h
		db	 00h, 40h, 65h, 19h, 00h, 04h
		db	 15h, 19h, 00h, 45h, 55h, 19h
		db	 00h, 04h, 19h, 00h, 02h, 00h
		db	 03h, 19h, 00h, 10h, 03h, 19h
		db	 00h, 44h, 30h, 00h, 0Ah, 40h
		db	0E0h, 6Dh, 00h,0E0h, 28h, 0Ah
		db	 02h,0E0h, 08h, 0Ah, 19h, 01h
		db	 2Ah,0AAh, 00h, 7Dh,0AAh, 7Dh
		db	0C0h, 55h, 2Ah, 55h,0A0h, 00h
		db	 0Ah, 00h, 2Ah,0AAh, 19h, 00h
		db	 0Ah, 88h, 80h, 00h, 02h,0A2h
		db	0A0h, 19h, 00h, 01h,0AAh,0A8h
		db	 00h, 10h,0AAh, 8Ah, 19h, 07h
		db	 01h, 19h, 00h, 84h, 40h, 19h
		db	 00h, 82h, 94h, 19h, 00h, 09h
		db	 64h, 19h, 00h, 16h, 51h, 80h
		db	 00h, 59h, 10h, 19h, 03h, 3Dh
		db	 19h, 01h,0F5h, 19h, 0Ah, 40h
		db	 19h, 01h, 04h, 19h, 01h, 40h
		db	 19h, 12h, 10h, 19h, 04h, 01h
		db	 19h, 05h, 04h, 19h, 06h, 10h
		db	 19h, 04h, 10h, 09h, 19h, 01h
		db	 05h, 19h, 00h, 01h, 19h, 02h
		db	 05h, 19h, 04h, 6Eh, 00h, 19h
		db	 00h, 01h, 19h, 02h, 04h, 19h
		db	 00h, 04h, 19h, 01h, 10h, 19h
		db	 02h, 40h, 19h, 07h, 02h, 40h
		db	 43h, 19h, 01h, 03h, 19h, 01h
		db	 30h, 00h, 0Ah, 00h,0E0h, 6Dh
		db	 00h,0E0h, 28h, 0Ah, 02h,0E0h
		db	 08h, 0Ah, 19h, 01h, 2Ah,0AAh
		db	 19h, 0Ch, 01h, 19h, 0Eh, 4Dh
		db	 00h, 19h, 06h, 10h, 19h, 00h
		db	 81h, 19h, 01h, 80h, 19h, 05h
		db	 31h, 00h, 80h, 00h, 10h, 40h
		db	 80h, 00h, 01h, 19h, 00h, 3Dh
		db	 10h, 19h, 00h,0F5h, 19h, 02h
		db	 10h, 40h, 19h, 00h, 24h, 19h
		db	 05h, 31h, 00h, 19h, 00h, 10h
		db	 19h, 15h, 04h, 08h, 04h, 08h
		db	 00h, 01h, 19h, 00h, 21h,0C0h
		db	 20h, 40h, 19h, 0Ah, 02h, 00h
		db	 02h, 19h, 07h,0ECh, 30h, 6Ch
		db	 30h, 03h, 02h, 03h, 02h, 00h
		db	 38h, 00h,0E2h, 00h,0B0h, 08h
		db	 00h, 33h, 86h, 13h, 82h, 22h
		db	 1Eh, 22h, 0Eh, 08h, 78h, 08h
		db	 18h, 0Bh,0E0h, 09h,0E0h, 0Bh
		db	0E3h, 0Bh,0E0h, 0Fh,0FBh, 00h
		db	 38h,0F8h, 0Ch, 38h, 04h, 7Bh
		db	 86h, 39h, 82h,0F0h,0A3h,0F0h
		db	0A3h, 7Eh, 20h, 0Eh, 20h, 7Fh
		db	 8Ch, 03h, 80h,0EAh,0F8h, 19h
		db	 00h,0AAh,0A0h, 19h, 00h,0AEh
		db	 88h, 19h, 05h, 20h, 00h, 20h
		db	 01h, 19h, 06h, 0Eh, 00h, 06h
		db	 00h, 08h, 00h, 08h, 00h, 02h
		db	 00h, 02h, 01h, 04h, 01h, 04h
		db	 00h, 08h, 00h, 08h, 00h, 80h
		db	 00h, 80h, 19h, 02h, 40h,0AEh
		db	 40h,0AAh, 03h, 8Bh, 00h, 8Ah
		db	 04h, 00h, 04h, 00h, 03h, 06h
		db	 01h, 02h, 18h, 00h, 08h, 00h
		db	0C0h, 00h,0C0h, 00h, 01h, 00h
		db	 01h, 00h, 60h, 19h, 02h, 64h
		db	 00h, 24h, 8Eh, 01h, 82h, 31h
		db	 00h, 80h, 01h, 80h, 00h, 66h
		db	 00h, 20h, 38h, 23h, 08h, 22h
		db	 19h, 02h, 60h,0C0h, 20h, 40h
		db	 08h, 10h, 08h, 10h, 19h, 06h
		db	 18h, 06h, 08h, 02h, 04h, 02h
		db	 04h, 02h, 19h, 02h, 06h, 00h
		db	 02h, 00h, 0Ch, 19h, 01h, 04h
		db	 30h, 04h, 10h, 00h, 10h, 00h
		db	 10h, 19h, 02h, 01h, 82h, 00h
		db	 82h, 00h,0C1h, 00h, 40h, 19h
		db	 02h, 60h,0C0h, 20h,0C0h, 00h
		db	 01h, 19h, 01h, 30h, 00h, 10h
		db	 0Ch, 00h, 04h, 00h, 10h, 00h
		db	 10h, 19h, 04h, 03h, 19h, 00h
		db	 0Fh,0C3h, 19h, 00h, 0Ch, 01h
		db	 0Ch, 01h,0C1h, 20h, 41h, 20h
		db	 00h, 50h, 00h, 50h, 00h, 61h
		db	 00h, 61h, 7Ch, 2Ch, 00h, 20h
		db	0EAh,0F8h, 19h, 00h,0AAh,0A0h
		db	 19h, 00h,0AEh, 88h, 19h, 01h
		db	 80h, 00h, 80h, 10h, 80h, 00h
		db	 80h, 10h, 00h, 10h, 00h, 04h
		db	 81h, 04h, 80h, 00h, 03h, 00h
		db	 01h, 18h, 02h, 08h, 02h, 10h
		db	 00h, 10h, 19h, 00h, 20h, 00h
		db	 20h, 19h, 07h, 10h, 00h, 10h
		db	 19h, 03h, 40h, 00h, 40h, 19h
		db	 03h, 02h, 00h, 02h, 19h, 03h
		db	 04h, 00h, 04h, 01h, 19h, 0Ah
		db	 0Ch, 00h, 04h, 40h, 00h, 40h
		db	 19h, 10h, 02h, 00h, 02h, 00h
		db	 0Fh, 00h, 09h, 00h,0BFh, 00h
		db	 23h, 03h,0F4h, 00h,0D4h, 02h
		db	 4Bh, 00h, 40h, 0Fh,0C3h, 19h
		db	 08h,0A8h, 00h,0A8h, 00h,0AAh
		db	 80h, 0Ah, 80h, 3Ch, 8Ch, 19h
		db	 00h,0EAh,0F8h, 19h, 00h,0AAh
		db	0A0h, 19h, 00h,0AEh, 88h, 19h
		db	 11h, 17h, 00h, 17h, 01h, 7Fh
		db	 01h, 51h, 03h,0F9h, 03h, 00h
		db	 07h,0FBh, 06h, 10h, 19h, 0Eh
		db	0E8h, 00h,0E8h, 00h,0FEh, 80h
		db	 1Eh, 80h,0FFh,0C0h,0F9h,0C0h
		db	0FFh,0E0h, 7Eh,0E0h, 0Fh,0FFh
		db	 0Ch, 22h, 0Fh,0FCh, 0Ch, 87h
		db	 0Fh,0F4h, 0Dh, 4Fh, 0Fh,0F9h
		db	 0Ch,0FFh, 07h,0CFh, 06h,0CFh
		db	 02h,0DFh, 02h,0C7h, 00h,0AAh
		db	 00h,0AAh, 00h, 15h, 00h, 15h
		db	 9Fh,0D0h,0FFh,0D0h, 2Fh,0D0h
		db	0FFh,0D0h, 2Fh,0A0h,0FFh,0A0h
		db	 9Ch, 50h,0FCh, 50h,0FDh,0A0h
		db	0FCh,0A0h, 65h, 40h, 65h, 40h
		db	0AAh, 80h,0AAh, 80h, 54h, 00h
		db	 54h, 19h, 10h, 17h, 00h, 17h
		db	 01h, 7Fh, 01h, 51h, 03h,0FFh
		db	 03h, 05h, 07h,0FFh, 06h, 12h
		db	 19h, 0Eh,0E8h, 00h,0E8h, 00h
		db	0FEh, 80h, 1Eh, 80h,0FFh,0C0h
		db	0F9h,0C0h,0DFh,0E0h, 7Eh,0E0h
		db	 0Fh, 9Fh, 0Ch, 02h, 0Fh,0B8h
		db	 0Ch, 87h, 0Fh,0F0h, 0Dh, 4Fh
		db	 0Fh,0E0h, 0Ch,0FFh, 07h,0F2h
		db	 06h,0DFh, 02h,0FEh, 02h,0FEh
		db	 00h,0AAh, 00h,0AAh, 00h, 15h
		db	 00h, 15h, 08h, 50h,0FCh, 50h
		db	 05h,0D0h,0FCh,0D0h, 07h,0A0h
		db	0FFh,0A0h, 0Bh, 50h,0FFh, 50h
		db	 2Ch,0A0h,0FCh,0A0h, 65h, 40h
		db	 65h, 40h,0AAh, 80h, 2Ah, 80h
		db	 54h, 00h, 54h, 19h, 10h, 17h
		db	 00h, 17h, 01h, 7Fh, 01h, 51h
		db	 03h,0FFh, 03h, 05h, 07h,0FDh
		db	 06h, 12h, 19h, 0Eh,0E8h, 00h
		db	0E8h, 00h,0FEh, 80h, 1Eh, 80h
		db	 8Fh,0C0h,0C9h,0C0h,0DFh,0E0h
		db	 4Eh,0E0h, 0Fh,0FFh, 0Ch, 22h
		db	 0Fh,0FFh, 0Ch, 87h, 0Fh, 9Fh
		db	 0Dh, 72h, 00h,0BFh, 0Ch, 8Fh
		db	 07h,0F9h, 06h,0DFh, 02h,0E6h
		db	 02h,0FFh, 00h,0A8h, 00h,0AAh
		db	 00h, 15h, 00h, 15h,0D9h,0D0h
		db	0FFh,0D0h,0F5h,0D0h,0FFh,0D0h
		db	0EFh,0A0h,0FFh,0A0h,0FEh, 50h
		db	0FFh, 50h,0E0h,0A0h,0F8h,0A0h
		db	 65h, 40h, 61h, 40h, 8Ah, 80h
		db	0AAh, 80h, 54h, 00h, 54h, 19h
		db	 10h, 16h, 00h, 16h, 01h, 1Fh
		db	 01h, 11h, 03h, 8Fh, 03h, 05h
		db	 07h,0CAh, 06h, 06h, 19h, 0Eh
		db	 68h, 00h, 68h, 00h, 7Eh, 80h
		db	 1Eh, 80h, 7Fh, 00h, 39h, 00h
		db	0CCh, 00h, 7Ch, 00h, 0Fh,0E6h
		db	 0Ch, 28h, 0Fh, 99h, 0Ch, 80h
		db	 0Fh, 7Ah, 0Dh, 1Eh, 00h, 8Eh
		db	 00h, 8Ch, 07h,0B1h, 00h,0D0h
		db	 02h,0EBh, 02h,0F9h, 00h,0A2h
		db	 00h,0A2h, 00h, 11h, 00h, 11h
		db	0C7h,0D0h, 60h, 90h, 9Fh,0D0h
		db	 87h,0D0h, 50h,0A0h, 70h,0A0h
		db	 8Fh, 10h, 03h, 10h, 92h, 80h
		db	0BAh, 80h, 45h, 40h, 45h, 40h
		db	0A2h, 80h,0A2h, 80h, 50h, 00h
		db	 50h, 00h, 08h, 00h, 08h, 00h
		db	0C0h, 85h, 00h, 05h, 80h, 1Fh
		db	 00h, 13h, 03h, 1Ch, 01h, 14h
		db	 18h, 8Ah, 18h, 8Ah, 00h, 0Ch
		db	 00h, 0Ch, 4Eh, 04h, 42h, 04h
		db	 1Ch, 01h, 0Ch, 11h, 60h, 02h
		db	 20h, 02h, 00h, 30h, 00h, 10h
		db	 18h, 01h, 18h, 31h, 00h, 80h
		db	 19h, 00h, 1Eh, 60h, 04h, 60h
		db	 07h, 20h, 03h, 20h, 63h, 00h
		db	 63h, 00h, 20h, 00h, 28h, 00h
		db	 33h, 00h, 03h, 0Bh, 62h, 00h
		db	'b', 27h, '(`(a', 8, ' ', 8, '('
		db	 19h, 02h, 88h, 04h, 88h, 04h
		db	 66h,0C0h, 26h,0C0h, 09h, 91h
		db	 09h, 90h, 04h, 00h, 44h, 19h
		db	 00h,0F4h, 84h, 14h, 20h, 7Eh
		db	 20h, 3Eh, 00h, 0Ch, 20h, 04h
		db	 0Eh,0E0h, 08h,0E0h, 47h, 48h
		db	 07h, 48h,0A2h, 80h, 22h, 80h
		db	 50h, 00h, 50h, 19h, 00h, 02h
		db	 00h, 06h, 03h, 80h, 01h, 90h
		db	 18h, 10h, 18h, 14h, 40h, 80h
		db	 40h, 88h, 00h, 01h, 00h, 01h
		db	 8Ch, 00h, 84h, 08h, 00h, 40h
		db	 00h, 40h, 12h, 0Ch, 12h, 0Ch
		db	 60h, 04h, 20h, 04h, 19h, 00h
		db	 08h, 80h, 08h, 00h, 08h, 19h
		db	 00h,0C1h, 40h,0C1h, 02h, 08h
		db	 02h, 08h, 30h, 00h, 20h, 00h
		db	 01h, 40h, 01h, 40h, 3Bh, 02h
		db	 3Bh, 02h

_369UNKN	endp

seg_a		ends



		end	start
