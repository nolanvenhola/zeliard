
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_354UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_4e		equ	2A86h			;*
data_5e		equ	0B81Dh			;*
data_6e		equ	0BCF3h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_354UNKN	proc	far

start:
		add	word ptr ds:[0],700h
		not	byte ptr ds:data_4e
		retf	4828h
			                        ;* No entry point to code
;*		cmp	bx,di
		db	 39h,0FBh		;  Fixup - byte match
		db	0FEh,0FBh, 82h, 00h,0D7h,0FBh
		db	0E2h, 0Bh, 20h, 80h, 6Ah,0C6h
		db	0B0h, 38h, 80h, 68h, 57h,0FAh
		db	0F6h, 00h, 00h, 80h, 3Fh,0FDh
		db	 00h, 00h
		db	2Ah
		db	0A8h, 00h, 0Fh,0F6h, 00h, 00h
		db	 0Ah,0F6h, 00h, 03h, 26h, 24h
		db	 3Ah, 38h, 18h, 18h, 6Eh, 69h
		db	0AEh,0AEh, 80h, 86h,0FBh,0ABh
		db	0FBh,0FAh, 00h, 11h,0EAh,0E9h
		db	 0Ch, 9Ah, 40h, 02h,0EBh,0EAh
		db	 93h, 06h, 20h, 80h,0EBh,0FFh
		db	 00h, 00h, 42h, 8Ah, 3Fh, 3Ch
		db	 00h, 00h, 2Ah, 28h,0F6h, 00h
		db	 03h, 1Ah, 68h, 2Eh,0A8h, 24h
		db	 80h, 77h,0BAh,0B8h,0FAh, 88h
		db	 00h,0EBh,0BBh,0FBh, 3Fh, 00h
		db	 00h,0BFh,0BBh, 50h, 70h, 08h
		db	 02h,0EEh,0AFh, 11h, 20h, 08h
		db	 0Ah,0BCh,0FCh, 00h, 00h, 28h
		db	0A8h,0F0h,0F6h, 00h, 00h,0A0h
		db	0F6h, 00h, 04h, 28h, 48h, 16h
		db	 86h, 14h, 04h,0C6h, 00h, 39h
		db	0FBh, 45h, 00h, 20h, 80h,0D7h
		db	0FBh, 15h, 70h, 90h, 78h, 6Ah
		db	0C6h, 5Ah, 96h, 00h, 80h, 57h
		db	0FAh, 57h, 7Ah, 2Ah,0A8h, 3Fh
		db	0FDh, 15h, 55h, 00h, 0Ah, 00h
		db	 0Fh, 00h, 05h,0F6h, 00h, 03h
		db	 18h, 18h, 26h, 24h, 04h, 04h
		db	 80h, 86h, 6Eh, 69h, 40h, 41h
		db	 00h, 51h,0FBh,0ABh, 00h, 40h
		db	 44h, 12h,0EAh,0E9h,0A6h, 71h
		db	 30h, 84h,0EBh,0EAh, 58h, 6Ch
		db	 42h, 8Ah,0EBh,0FFh,0A9h, 75h
		db	 2Ah, 28h, 3Fh, 3Ch, 15h, 14h
		db	0F6h, 00h, 03h, 24h, 80h, 1Ah
		db	 68h, 10h, 40h, 88h, 40h, 77h
		db	0BAh, 47h, 40h, 10h, 04h,0EBh
		db	0BBh, 10h, 84h, 48h, 42h,0BFh
		db	0BBh,0E7h,0C9h, 19h, 0Ah,0EEh
		db	0AFh,0F7h, 85h, 28h,0A8h,0BCh
		db	0FCh, 94h, 54h,0A0h, 00h,0F0h
		db	 00h, 50h,0F6h, 00h, 04h, 28h
		db	 48h, 16h, 86h, 14h, 04h,0C6h
		db	 00h, 39h,0FBh, 45h, 00h, 20h
		db	 80h,0D7h,0FBh, 15h, 70h, 90h
		db	 78h, 6Ah,0C6h, 5Ah, 96h, 00h
		db	 80h, 57h,0FAh, 57h, 7Ah, 2Ah
		db	0A8h, 3Fh,0FDh, 15h, 55h, 00h
		db	 0Ah, 00h, 0Fh, 00h, 05h,0F6h
		db	 00h, 03h, 18h, 18h, 26h, 24h
		db	 04h, 04h, 80h, 86h, 6Eh, 69h
		db	 40h, 41h, 00h, 51h,0FBh,0ABh
		db	 00h, 40h, 44h, 12h,0EAh,0E9h
		db	0A6h, 71h, 30h, 84h,0EBh,0EAh
		db	 58h, 6Ch, 42h, 8Ah,0EBh,0FFh
		db	0A9h, 75h, 2Ah, 28h, 3Fh, 3Ch
		db	 15h, 14h,0F6h, 00h, 03h, 24h
		db	 80h, 1Ah, 68h, 10h, 40h, 88h
		db	 40h, 77h,0BAh, 47h, 40h, 10h
		db	 04h,0EBh,0BBh, 10h, 84h, 48h
		db	 42h,0BFh,0BBh,0E7h,0C9h, 19h
		db	 0Ah,0EEh,0AFh,0F7h, 85h, 28h
		db	0A8h,0BCh,0FCh, 94h, 54h,0A0h
		db	 00h,0F0h, 00h, 50h,0F6h, 00h
		db	 0Bh, 0Ah, 00h, 0Ah, 00h, 0Ah
		db	 00h, 10h, 00h, 10h, 00h, 10h
		db	 00h, 16h, 00h, 16h, 00h, 16h
		db	 00h, 05h, 00h, 05h, 00h, 05h
		db	 00h,0CAh, 00h,0CAh, 00h,0CAh
		db	 04h,0B5h, 04h,0B5h, 04h,0B5h
		db	 01h, 0Ah, 01h, 0Ah, 01h, 0Ah
		db	 00h, 05h, 00h, 05h, 00h, 05h
		db	 82h,0A0h, 82h,0A0h, 82h,0A0h
		db	 50h, 04h, 50h, 04h, 50h, 04h
		db	0A2h, 10h,0A2h, 10h,0A2h, 10h
		db	0D5h, 45h,0D5h, 45h,0D5h, 45h
		db	0BDh,0EAh,0BDh,0EAh,0BDh,0EAh
		db	0DFh,0DDh,0D2h, 9Dh,0D2h, 9Dh
		db	0E0h, 1Bh,0E0h, 13h,0E0h, 13h
		db	0A0h, 00h,0A0h, 00h,0A0h, 00h
		db	 05h, 41h, 05h, 41h, 05h
		db	 41h, 20h, 0Ah, 20h, 0Ah, 20h

locloop_1:
		or	cl,[bx+si]
		inc	bp
		or	[di+8],al
		inc	bp
		mov	byte ptr ds:[0A2ABh],al
		stosw				; Store ax to es:[di]
		mov	byte ptr ds:[57ABh],al
		mov	bp,0BD57h
		push	di
		mov	bp,0FBBBh
		mov	cx,0B94Bh
		dec	bx
		db	0D8h, 07h,0C8h, 07h,0C8h, 07h
		db	0F6h, 00h, 03h, 50h, 00h, 50h
		db	 00h, 50h, 00h, 08h, 00h, 08h
		db	 00h, 08h, 00h, 68h, 00h, 68h
		db	 00h, 68h, 00h,0A0h, 00h,0A0h
		db	 00h,0A0h, 00h, 53h, 00h, 53h
		db	 00h, 53h, 00h,0ADh, 20h,0ADh
		db	 20h,0ADh, 20h, 50h, 80h, 50h
		db	 80h, 50h, 80h, 00h,0D7h, 00h
		db	0D7h, 00h,0D7h, 04h, 6Eh, 04h
		db	 2Ch, 04h, 2Ch, 02h, 9Ch, 02h
		db	 80h, 02h, 80h, 00h, 6Ch, 00h
		db	 68h, 00h, 68h, 08h, 76h, 08h
		db	 56h, 08h, 56h, 05h,0AEh, 05h
		db	0A2h, 05h,0A2h, 00h, 16h, 00h
		db	 14h, 00h, 14h, 02h,0EEh, 02h
		db	0EAh, 02h,0EAh,0EBh, 00h,0EBh
		db	 00h,0EBh, 00h
		db	'v 4 4 9@'
		db	 01h, 40h, 01h, 40h, 36h, 00h
		db	 16h, 00h, 16h, 00h, 6Eh, 10h
		db	 6Ah, 10h, 6Ah, 10h, 75h,0A0h
		db	 45h,0A0h, 45h,0A0h, 68h, 00h
		db	 28h, 00h, 28h, 00h, 77h, 40h
		db	 57h, 40h, 57h, 40h,0F6h, 00h
		db	 09h, 08h,0EFh, 00h, 00h, 08h
		db	0EFh, 1Dh,0E7h, 00h, 00h, 1Dh
		db	0E7h, 1Dh,0E7h, 00h, 00h, 1Dh
		db	0E7h, 3Dh,0EFh, 00h, 00h, 3Dh
		db	0EFh, 3Dh,0EEh, 00h, 00h, 3Dh
		db	0EEh, 0Dh,0EFh, 00h, 00h, 0Dh
		db	0EFh,0F6h, 00h, 09h,0B8h, 1Dh
		db	 00h, 00h,0B8h, 1Dh,0B8h, 1Dh
		db	 00h, 00h,0B8h, 1Dh,0B8h, 1Dh
		db	 00h, 00h,0B8h, 1Dh
loc_2:
		mov	ax,1Dh
		add	ds:data_5e[bx+si],bh
		sbb	ax,0
		mov	ax,0B81Dh
		sbb	ax,0
		mov	ax,0F61Dh
		add	[bx+di],cl
		not	word ptr [bx+si]
		add	[bx+si],al
		not	word ptr [bx+si]
;*		idiv	word ptr ds:[0][bx+si]	; ax,dxrem=dx:ax/data
		db	0F7h,0B8h, 00h, 00h	;  Fixup - byte match
		idiv	word ptr ds:data_6e[bx+si]	; ax,dxrem=dx:ax/data
		add	[bx+si],al
		db	0F3h,0BCh,0F7h,0BCh, 00h, 00h
		db	0F7h,0BCh,0E7h,0BCh, 00h, 00h
		db	0E7h,0BCh,0E7h,0B0h, 00h, 00h
		db	0E7h,0B0h,0F6h, 00h, 09h, 0Dh
		db	0EFh, 00h, 00h, 0Dh,0EFh, 3Dh
		db	0EDh, 00h, 00h, 3Dh,0EDh, 3Dh
		db	0EFh, 00h, 00h, 3Dh,0EFh, 3Dh
		db	0EDh, 00h, 00h, 3Dh,0EDh, 0Dh
		db	0EEh, 00h, 00h, 0Dh,0EEh,0F6h
		db	 00h, 04h, 80h,0F6h, 00h, 00h
		db	 80h, 00h, 80h,0F6h, 00h, 00h
		db	 80h, 80h, 81h, 00h, 00h, 80h
		db	 81h, 80h, 81h, 1Ch, 38h, 98h
		db	0B1h, 80h, 81h, 22h, 44h,0A0h
		db	0C1h, 80h, 81h, 22h, 44h, 80h
		db	 81h, 80h, 81h, 14h, 28h, 80h
		db	 81h, 00h, 80h,0F6h, 00h, 00h
		db	 80h,0F6h, 00h, 09h,0F7h,0B0h
		db	 00h, 00h,0F7h,0B0h,0E7h,0BCh
		db	 00h, 00h,0E7h,0BCh,0F7h,0BCh
		db	 00h, 00h,0F7h,0BCh,0E7h,0BCh
		db	 00h, 00h,0E7h,0BCh,0F7h,0B0h
		db	 00h, 00h,0F7h,0B0h,0F6h, 00h
		db	 09h, 0Dh,0EEh, 00h, 00h, 0Dh
		db	0EEh, 3Dh,0EFh, 00h, 00h, 3Dh
		db	0EFh, 2Dh,0EBh, 00h, 00h, 2Dh
		db	0EBh, 2Dh,0E7h, 00h, 00h, 2Dh
		db	0E7h, 31h,0EFh, 00h, 00h, 31h
		db	0EFh, 2Dh,0EFh, 00h, 00h, 2Dh
		db	0EFh, 2Dh,0EFh, 00h, 00h, 2Dh
		db	0EFh, 00h, 80h,0F6h, 00h, 00h
		db	 80h,0B8h, 9Dh, 00h, 00h,0B8h
		db	 9Dh,0B8h, 9Dh, 00h, 00h,0B8h
		db	 9Dh,0B0h, 9Dh, 00h, 00h,0B0h
		db	 9Dh,0B8h, 9Dh, 00h, 00h,0B8h
		db	 9Dh,0B8h, 9Dh, 00h, 00h,0B8h
		db	 9Dh,0B8h, 9Dh, 00h, 00h,0B8h
		db	 9Dh,0A8h, 9Dh, 00h, 00h,0A8h
		db	 9Dh,0F6h, 00h, 03h,0F7h,0B0h
		db	 00h, 00h,0F7h,0B0h,0F3h,0BCh
		db	 00h, 00h,0F3h,0BCh,0F3h,0BCh
		db	 00h, 00h,0F3h,0BCh,0F7h,0BCh
		db	 00h, 00h,0F7h,0BCh,0F7h,0B8h
		db	 00h, 00h,0F7h,0B8h,0F3h, 34h
		db	 00h, 00h,0F3h, 34h,0F7h, 34h
		db	 00h, 00h,0F7h, 34h,0F6h, 00h
		db	 05h, 10h,0F6h, 00h, 08h, 40h
		db	0F6h, 00h, 06h, 40h, 00h, 40h
		db	 00h, 40h,0F6h, 00h, 04h, 40h
		db	 00h, 60h, 00h, 40h,0F6h, 00h
		db	 17h, 04h, 00h, 04h, 00h, 04h
		db	0F6h, 00h, 04h, 02h, 00h, 02h
		db	 00h, 02h, 00h, 04h, 00h, 44h
		db	 00h, 04h
data_2		db	20h
		db	 00h, 20h, 00h, 20h, 00h, 40h
		db	 00h, 40h, 00h, 40h,0F6h, 00h
		db	 04h, 40h, 00h, 40h, 00h, 40h
		db	0F6h, 00h, 06h, 40h,0F6h, 00h
		db	 06h, 40h, 00h, 60h, 00h, 40h
		db	 00h, 00h, 04h, 00h, 05h, 00h
		db	 04h, 00h, 02h, 02h, 22h, 00h
		db	 02h, 00h, 01h, 00h, 01h, 00h
		db	 01h, 00h, 02h, 04h, 22h, 00h
		db	 02h, 00h, 21h, 00h, 21h, 00h
		db	 21h, 00h, 12h, 00h, 32h, 00h
		db	 12h, 00h, 01h, 00h, 41h, 00h
		db	 01h, 00h, 26h, 02h, 26h, 00h
		db	 26h,0F6h, 00h, 03h, 20h, 00h
		db	 20h, 00h, 20h, 00h, 40h, 00h
		db	 40h, 00h, 40h,0F6h, 00h, 00h
		db	 20h,0F6h, 00h, 02h, 40h,0F6h
		db	 00h, 02h, 20h,0F6h, 00h, 00h
		db	 40h, 00h, 40h, 00h, 40h, 00h
		db	 20h, 00h, 20h, 02h, 20h, 02h
		db	0F6h, 00h, 12h, 08h, 00h, 08h
		db	0F6h, 00h, 05h, 12h,0A5h, 12h
		db	0A5h,0F6h, 00h, 05h,0F6h,0AAh
		db	 01h,0F6h, 00h, 00h, 40h,0F6h
		db	 00h, 00h, 05h, 02h, 05h, 00h
		db	 05h, 00h, 02h, 00h, 22h, 00h
		db	 02h, 00h, 07h,0A0h, 27h,0A0h
		db	 07h, 00h, 02h, 00h, 02h, 00h
		db	 02h, 00h, 07h, 54h, 27h, 54h
		db	 07h
data_3		db	0			; Data table (indexed access)
		db	 02h, 00h, 02h, 00h, 02h, 00h
		db	 05h,0AEh, 95h,0AEh, 95h, 01h
		db	 56h, 01h, 54h, 01h, 54h, 24h
		db	 2Ch, 20h, 28h, 20h, 28h, 01h
		db	 7Ch, 01h, 10h, 01h, 10h, 00h
		db	0ACh, 00h,0A4h, 00h,0A4h, 15h
		db	 58h, 15h, 50h, 15h, 50h, 02h
		db	0D8h, 02h,0C0h, 02h,0C0h, 40h
		db	 0Ch, 40h, 0Ch, 40h, 0Ch, 00h
		db	 0Ch, 00h, 0Ch, 00h, 0Ch, 6Ah
		db	 80h, 2Ah, 80h, 2Ah, 80h, 34h
		db	 24h, 14h, 04h, 14h, 04h, 3Eh
		db	 80h, 08h, 80h, 08h, 80h, 35h
		db	 00h, 25h, 00h, 25h, 00h, 1Ah
		db	0A8h, 0Ah,0A8h, 0Ah,0A8h, 1Bh
		db	 40h, 03h, 40h, 03h, 40h, 30h
		db	 02h, 30h, 02h, 30h, 02h, 30h
		db	 00h, 30h, 00h, 30h,0F6h, 00h
		db	 04h, 08h, 82h, 08h, 82h, 08h
		db	 82h, 20h, 10h, 20h, 10h, 20h
		db	 10h, 02h,0C0h, 02h,0C0h, 02h
		db	0C0h, 09h, 15h, 09h, 15h, 09h
		db	 15h, 46h,0ACh, 46h,0ACh, 46h
		db	0ACh,0BEh,0FFh, 3Ch,0F9h, 3Ch
		db	0F9h, 70h, 30h, 40h, 00h, 40h
		db	 00h, 1Fh,0F8h, 01h, 98h, 01h
		db	 98h, 70h, 0Eh, 10h, 0Eh, 10h
		db	 0Eh,0C7h,0A3h, 40h, 53h, 40h
		db	 03h, 8Eh, 01h, 80h,0A9h, 80h
		db	 01h, 84h, 01h, 81h,0F0h, 80h
		db	 00h, 40h, 02h, 4Ah,0E0h, 40h
		db	 00h, 50h, 0Bh, 50h, 03h, 50h
		db	 03h, 0Fh,0F8h, 0Fh, 08h, 0Fh
		db	 08h, 1Fh,0F8h, 01h, 98h, 01h
		db	 98h, 70h, 0Eh, 10h, 0Eh, 10h
		db	 0Eh,0C7h,0F3h, 40h, 03h, 40h
		db	 53h, 8Eh,0A9h, 80h, 01h, 80h
		db	0A9h, 85h,0F1h, 80h, 00h, 81h
		db	0F0h, 4Ah,0E2h, 40h, 00h, 4Ah
		db	0E0h, 50h, 0Bh, 50h, 03h, 50h
		db	 03h, 0Fh,0F8h, 0Fh, 08h, 0Fh
		db	 08h, 1Fh,0F8h, 01h, 98h, 01h
		db	 98h, 70h, 0Eh, 10h, 0Eh, 10h
		db	 0Eh,0C7h,0F3h, 40h, 53h, 40h
		db	 03h, 8Eh,0A9h, 80h,0A9h, 80h
		db	 01h, 86h,0F1h, 82h,0F0h, 80h
		db	 00h, 4Ah,0E2h, 4Ah,0E0h, 40h
		db	 00h, 50h, 0Bh, 50h, 03h, 50h
		db	 03h, 0Fh,0F8h, 0Fh, 08h, 0Fh
		db	 08h, 1Fh,0F8h, 01h, 98h, 01h
		db	 98h, 70h, 0Eh, 10h, 0Eh, 10h
		db	 0Eh,0C7h,0F3h, 40h, 53h, 40h
		db	 53h, 8Eh,0A9h, 80h,0A9h, 80h
		db	0A9h, 85h,0F1h, 81h,0F0h, 81h
		db	0F0h, 4Ah,0E2h, 4Ah,0E0h, 4Ah
		db	0E0h, 50h, 0Bh, 50h, 03h, 50h
		db	 03h, 0Fh,0F8h, 0Fh, 08h, 0Fh
		db	 08h,0F6h, 00h, 03h, 7Bh, 94h
		db	 00h, 00h, 4Ch, 7Ch,0F1h, 54h
		db	 00h, 00h, 1Fh,0F4h,0FEh, 2Ah
		db	 00h, 00h, 07h,0AAh,0EFh, 54h
		db	 00h, 00h, 11h, 54h, 6Fh,0A8h
		db	 00h, 00h, 11h,0A8h, 0Fh,0D0h
		db	 00h, 00h, 33h,0D0h, 0Fh,0E0h
		db	 00h, 00h, 17h,0E0h

_354UNKN	endp

seg_a		ends



		end	start
