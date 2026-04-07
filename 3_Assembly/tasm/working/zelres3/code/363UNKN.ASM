
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_363UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_11e	equ	0DB02h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_363UNKN	proc	far

start:
		or	ax,1Ah
		add	[bx+si],al
		push	es
		lahf				; Load ah from flags
		add	ds:data_11e[bx],ah
		cmp	bh,0FFh
		lahf				; Load ah from flags
		daa				; Decimal adjust
		mov	dx,9Fh
		add	ax,9FCFh
		add	byte ptr ds:[13Fh],cl
		inc	ax
;*		cmp	dh,dh
		db	 38h,0F6h		;  Fixup - byte match
		add	ax,6109h
		std				; Set direction flag
		adc	[bp+si],al
		jcxz	$-10h			; Jump if cx=0
		adc	[bx+si],dl
		lahf				; Load ah from flags
		push	es
		out	dx,al			; port 9Fh ??I/O Non-standard
		add	[bx+si],dl
		add	byte ptr ss:[44C0h][bp+di],bh
;*		add	dl,bh
		db	 00h,0FAh		;  Fixup - byte match
		loopnz	$+0Bh			; Loop if zf=0, cx>0

;*		adc	dl,ch
		db	 10h,0EAh		;  Fixup - byte match
		lodsb				; String [si] to al
		add	ax,0AA10h
		test	al,51h			; 'Q'
		db	 64h,0AAh,0AAh, 58h, 44h,0C3h
		db	0AAh, 20h, 66h,0A1h,0AAh, 54h
		db	 55h, 00h,0EAh, 0Eh, 14h, 1Ah
		db	 32h, 25h, 88h, 40h, 08h,0B8h
		db	 62h, 00h, 80h, 0Ah, 42h, 04h
		db	 00h, 3Bh, 4Ah, 00h, 20h, 00h
		db	 2Ah,0AAh,0AAh, 54h, 40h,0AAh
		db	0AAh, 10h, 22h,0AAh,0A0h, 04h
		db	 88h, 28h, 00h,0A2h,0A0h, 9Fh
		db	 00h,0AAh,0B0h, 08h, 00h, 2Bh
		db	 8Ch, 88h, 00h,0A8h,0C0h, 2Ah
		db	 00h,0AAh, 80h, 00h, 03h, 00h
		db	 3Bh, 00h, 01h, 00h, 2Bh, 00h
		db	 20h, 00h, 13h, 00h, 21h, 00h
		db	 13h, 00h, 62h, 00h, 03h, 00h
		db	 41h, 00h, 21h, 9Fh, 01h,0C0h
		db	 01h, 9Fh, 00h,0DBh, 00h, 00h
		db	 8Eh, 00h, 04h, 00h, 0Ah, 00h
		db	 98h, 00h, 84h, 00h, 20h, 00h
		db	 10h, 00h,0E0h, 00h, 80h, 00h
		db	0C0h, 02h, 00h, 02h, 80h, 06h
		db	 40h, 06h, 10h, 28h,0D0h, 38h
		db	 9Fh, 00h, 03h, 00h, 08h, 00h
		db	 04h, 9Fh, 01h, 20h, 9Fh, 13h
		db	 0Dh,0C0h, 6Fh,0C0h, 20h, 00h
		db	 10h, 9Fh, 01h, 18h, 9Fh, 01h
		db	 04h, 9Fh, 01h, 02h, 9Fh, 0Ch
		db	 03h, 00h, 2Bh, 00h, 21h, 00h
		db	 1Bh, 00h, 20h, 00h, 13h, 00h
		db	 41h, 00h, 23h, 00h, 81h, 00h
		db	 41h, 01h, 81h, 9Fh, 00h, 03h
		db	 03h, 9Fh, 00h, 08h, 02h, 06h
		db	 01h, 80h, 00h, 8Eh, 9Fh, 01h
		db	 1Ch, 00h,0A0h, 00h, 98h, 00h
		db	0C0h, 20h,0B0h, 20h, 80h, 18h
		db	 40h, 18h,0B0h, 08h, 30h, 18h
		db	 2Ah, 30h,0BAh, 30h, 0Dh, 40h
		db	 0Fh,0C0h, 30h, 02h, 08h, 01h
		db	 80h, 00h, 40h, 03h, 9Fh, 01h
		db	 01h, 9Fh, 14h, 80h, 9Fh, 05h
		db	 80h, 9Fh, 01h, 68h, 9Fh, 10h
		db	 01h, 00h, 2Bh, 9Fh, 01h, 3Bh
		db	 00h, 01h, 00h, 2Bh, 00h, 03h
		db	 00h
		db	3Bh
		db	 00h, 23h, 00h, 10h, 00h, 26h
		db	 00h, 10h, 00h, 6Ch, 80h, 02h
		db	 21h, 88h, 40h, 44h, 80h, 00h
		db	 8Ah, 9Fh, 01h, 0Ch, 00h,0A0h
		db	 00h, 98h, 9Fh, 01h,0A0h, 9Fh
		db	 01h, 80h, 00h,0C0h, 00h,0C0h
		db	 00h,0C0h, 00h,0C0h, 00h, 40h
		db	 06h, 60h, 06h, 0Eh, 00h, 11h
		db	 0Ch, 9Fh, 01h, 04h, 9Fh, 01h
		db	 03h, 9Fh, 12h, 32h, 28h, 3Ah
		db	 38h, 0Bh, 40h, 0Bh,0C0h, 9Fh
		db	 16h,0C3h,0AAh, 20h, 66h, 81h
		db	0AAh, 54h, 55h, 1Ah, 6Ah, 24h
		db	 14h, 40h, 12h,0B5h, 88h, 00h
		db	 08h, 08h, 62h, 00h, 80h, 10h
		db	 42h, 06h, 00h
		db	 39h, 4Ah
data_1		dw	2000h			; Data table (indexed access)
		db	 16h, 2Ah, 00h, 01h, 00h, 2Bh
		db	 00h, 21h, 00h, 13h, 00h, 13h
		db	 00h, 0Bh, 9Fh, 01h, 19h, 00h
		db	 20h, 0Ch, 10h, 00h, 20h, 18h
		db	 10h, 00h, 60h, 10h, 00h, 03h
		db	 80h, 08h, 00h, 80h, 00h, 8Eh
		db	 00h, 08h, 00h, 06h, 00h, 8Ch
		db	 00h, 82h, 00h,0C0h, 00h,0CCh
		db	 00h, 68h, 00h,0E6h, 00h, 48h
		db	 00h, 54h, 00h, 38h, 00h, 08h
		db	 00h,0DCh, 00h, 3Ch, 9Fh, 00h
		db	 06h, 00h, 08h, 9Fh, 01h,0F4h
		db	 9Fh, 16h, 0Ah, 00h, 8Eh, 00h
		db	 01h, 00h, 03h, 9Fh, 00h, 40h
		db	 00h,0C0h, 00h, 30h, 00h, 30h
		db	 9Fh, 0Eh, 83h,0AAh, 40h, 66h
		db	 1Ch, 2Ah, 23h, 15h, 40h, 8Ah
		db	0AFh, 44h, 00h, 02h
data_2		db	20h			; Data table (indexed access)
		db	0A8h, 9Fh, 00h, 08h, 32h, 00h
		db	0C0h, 10h, 22h, 01h, 00h, 12h
		db	 8Ah, 00h, 20h, 0Eh, 2Ah, 00h
		db	 02h, 00h, 3Bh, 00h, 02h, 00h
		db	 2Bh, 9Fh, 01h, 1Bh, 9Fh, 01h
		db	 0Eh, 9Fh, 01h, 06h, 9Fh, 01h
		db	 07h, 00h, 02h, 00h, 01h, 00h
		db	 02h, 10h, 01h, 80h, 00h, 8Ah
		db	 9Fh, 01h, 0Eh, 00h, 80h, 00h
		db	 8Ah, 00h, 68h, 00h,0E6h, 00h
		db	 28h, 00h, 64h, 00h, 24h, 00h
		db	 2Ah, 00h, 0Fh, 00h, 03h, 00h
		db	 08h, 80h, 05h, 80h, 04h, 06h
		db	 0Ah, 9Fh, 00h,0B8h, 01h, 40h
		db	 9Fh, 09h, 02h, 9Fh, 0Ah, 18h
		db	 40h, 00h,0C0h, 30h, 20h, 00h
		db	 60h, 40h, 00h, 20h,0C0h, 00h
		db	 80h,0C1h, 80h, 02h, 00h, 02h
		db	 9Fh, 0Bh,0C3h,0AAh, 20h, 66h
		db	 81h,0AAh, 54h, 55h, 1Ah, 6Ah
		db	 24h, 14h, 40h, 12h,0B5h, 88h
		db	 00h, 08h, 08h, 62h, 00h, 80h
		db	 10h, 42h, 06h, 00h, 39h, 4Ah
		db	 00h, 20h, 16h, 2Ah, 00h, 03h
		db	 00h, 2Bh, 00h, 02h, 00h, 3Bh
		db	 00h, 02h, 00h, 1Fh, 9Fh, 01h
		db	 0Dh, 00h, 09h, 00h, 05h, 00h
		db	 10h, 00h, 08h, 00h, 10h, 00h
		db	 08h, 00h, 30h, 9Fh, 00h, 80h
		db	 00h, 8Ah, 9Fh, 01h, 0Eh, 00h
		db	 80h, 00h, 8Ah, 00h, 40h, 00h
		db	0CEh, 00h, 60h, 00h,0ECh, 00h
		db	 38h, 00h, 74h, 00h, 14h, 00h
		db	 0Ch, 00h, 14h, 00h, 0Ch, 9Fh
		db	 00h,0C0h, 9Fh, 00h, 02h, 00h
		db	 0Ch, 9Fh, 17h, 23h, 00h, 13h
		db	 00h, 10h,0C0h, 21h,0C0h, 20h
		db	 26h, 10h, 2Eh, 20h, 00h, 10h
		db	 9Fh, 01h, 20h, 9Fh, 01h, 20h
		db	 9Fh, 10h,0BBh, 00h, 04h, 0Bh
		db	0FBh, 00h, 04h, 2Fh,0EFh, 00h
		db	 20h, 3Fh,0EAh, 00h, 11h, 7Bh
		db	0AEh, 08h, 41h,0EAh,0AAh, 11h
		db	 25h, 9Fh, 06h, 2Ah, 00h, 04h
		db	 00h, 82h,0C0h, 05h, 00h,0A0h
		db	0B0h, 51h, 40h,0A8h, 28h, 52h
		db	 50h,0AAh, 2Ch, 18h, 10h,0AAh
		db	 0Ah, 14h, 54h,0EAh,0AAh, 01h
		db	 15h,0AAh,0AAh, 88h, 04h, 0Ah
		db	0AAh, 22h, 10h, 00h, 28h, 0Ah
		db	 8Ah, 9Fh, 00h, 0Eh,0AAh, 00h
		db	 20h, 32h,0E8h, 00h, 22h, 03h
		db	 2Ah, 00h,0A8h, 02h,0AAh,0A8h
		db	 0Ah, 98h, 48h,0A8h, 0Ah, 40h
		db	 00h,0A0h, 9Fh, 00h,0E0h, 80h
		db	 00h, 23h,0F4h, 9Fh, 00h, 8Ch
		db	 2Ah, 9Fh, 00h, 8Bh, 80h, 9Fh
		db	 00h,0A2h,0E8h, 08h, 00h,0A8h
		db	 9Fh, 00h, 01h, 00h, 71h, 00h
		db	 20h, 00h, 50h, 00h, 19h, 00h
		db	 21h, 00h, 04h, 00h, 08h, 00h
		db	 07h, 00h, 01h, 40h, 03h, 40h
		db	 00h, 60h, 01h, 60h, 02h, 14h
		db	 08h, 1Ch, 0Bh,0C0h, 00h,0DCh
		db	 00h, 80h, 00h,0D4h, 00h, 04h
		db	 00h,0C8h, 00h, 84h, 00h,0C8h
		db	 00h, 46h, 00h,0C0h, 00h, 82h
		db	 00h, 84h, 9Fh, 01h, 03h, 9Fh
		db	 00h, 80h, 01h, 00h, 03h,0B0h
		db	 03h,0F6h, 00h, 04h, 00h, 08h
		db	 9Fh, 01h, 18h, 9Fh, 01h, 20h
		db	 9Fh, 01h, 40h, 9Fh, 0Dh,0C0h
		db	 00h, 10h, 00h, 20h, 9Fh, 01h
		db	 04h, 9Fh, 13h, 01h, 00h, 71h
		db	 9Fh, 01h, 38h, 00h, 05h, 00h
		db	 19h, 04h, 03h, 04h, 0Dh, 18h
		db	 01h, 18h, 02h, 10h, 0Dh, 18h
		db	 0Ch, 0Ch, 54h, 0Ch, 5Dh, 02h
		db	0B0h, 03h,0F0h,0C0h, 00h,0D4h
		db	 00h, 84h, 00h,0D8h, 00h, 04h
		db	 00h,0C8h, 00h, 82h, 00h,0C4h
		db	 00h, 81h, 00h, 82h, 00h, 81h
		db	 80h, 9Fh, 00h,0C0h,0C0h, 9Fh
		db	 00h
		db	40h
data_3		dw	8010h			; Data table (indexed access)
		db	 60h, 9Fh, 01h, 01h, 9Fh, 05h
data_4		dw	9F01h
		db	 01h, 16h, 9Fh, 0Eh, 40h, 0Ch
		db	 80h, 10h, 00h, 01h,0C0h, 02h
		db	 9Fh, 00h, 80h, 9Fh, 14h, 01h
		db	 00h, 51h, 9Fh, 01h, 30h, 00h
		db	 05h, 00h, 19h, 9Fh, 01h, 05h
		db	 9Fh, 01h, 01h, 00h, 03h, 00h
		db	 03h, 00h, 03h, 00h, 03h, 60h
		db	 02h, 60h, 06h, 80h, 00h,0D4h
		db	 9Fh, 01h,0DCh, 00h, 80h, 00h
		db	0D4h, 00h,0C0h, 00h,0DCh, 00h
		db	0C4h, 00h, 08h, 00h, 64h, 00h
		db	 08h, 00h, 36h, 00h, 40h, 01h
		db	 11h, 84h, 22h, 02h, 14h, 4Ch
		db	 1Ch, 5Ch, 02h,0D0h, 03h,0D0h
		db	 9Fh, 17h, 70h, 30h, 88h, 9Fh
		db	 00h, 20h, 9Fh, 01h,0C0h, 9Fh
		db	 13h,0A8h, 0Ah, 98h, 48h,0A8h
		db	 0Ah, 40h, 00h,0A0h, 00h, 02h
		db	0E8h, 80h, 00h, 27h, 5Eh, 9Fh
		db	 00h, 8Ch, 9Fh, 01h, 8Ah, 08h
		db	 9Fh, 00h,0A2h,0D0h, 08h, 00h
		db	0A8h, 50h, 00h, 01h, 00h, 71h
		db	 00h, 10h, 00h, 60h, 00h, 31h
		db	 00h, 41h, 00h, 03h, 00h, 33h
		db	 00h, 16h, 00h, 67h, 00h, 12h
		db	 00h, 2Ah, 00h, 1Ch, 00h, 10h
		db	 00h, 3Bh, 00h, 3Ch, 80h, 00h
		db	0D4h, 00h, 84h, 00h,0C8h, 00h
		db	0C8h, 00h,0D0h, 9Fh, 01h, 98h
		db	 00h, 04h, 00h, 08h, 30h, 04h
		db	 00h, 08h, 18h, 06h, 9Fh, 00h
		db	 08h, 01h,0C0h, 00h, 10h, 00h
		db	 50h, 00h, 71h, 00h, 80h, 00h
		db	0C0h, 02h, 00h, 03h, 00h, 0Ch
		db	 00h, 0Ch, 9Fh, 0Fh, 60h, 00h
		db	 10h, 9Fh, 01h, 2Fh, 9Fh, 17h
		db	0A8h, 0Ah, 98h, 48h,0A8h, 0Ah
		db	 40h, 00h,0A0h, 00h, 02h,0FCh
		db	 80h, 00h, 27h, 48h, 9Fh, 00h
		db	 8Ch, 10h, 9Fh, 00h, 88h, 20h
		db	 9Fh, 00h,0A6h, 20h, 9Fh, 00h
		db	0A3h,0A0h, 00h, 01h, 00h, 51h
		db	 9Fh, 01h, 70h, 00h, 01h, 00h
		db	 51h, 00h, 16h, 00h, 67h, 00h
		db	 14h, 00h, 26h, 00h, 24h, 00h
		db	 54h, 00h,0F0h, 00h,0C0h, 01h
		db	 10h, 01h,0A0h, 40h, 00h,0DCh
		db	 00h, 40h, 00h,0D4h, 9Fh, 01h
		db	0D8h, 9Fh, 01h, 70h, 9Fh, 01h
		db	 60h, 9Fh, 01h,0E0h, 00h, 40h
		db	 00h, 80h, 00h, 40h, 00h, 80h
		db	 08h, 02h, 18h, 03h, 00h, 04h
		db	 0Ch, 06h, 9Fh, 00h, 02h, 03h
		db	 04h, 01h, 00h, 01h, 83h, 00h
		db	 40h, 00h, 40h, 9Fh, 0Ah, 60h
		db	 20h, 00h, 50h, 1Dh, 00h, 02h
		db	 80h, 9Fh, 08h, 40h, 9Fh, 0Bh
		db	0A8h, 0Ah, 98h, 48h,0A8h, 0Ah
		db	 40h, 00h,0A0h, 00h, 02h,0E8h
		db	 80h, 00h, 27h, 5Eh, 9Fh, 00h
		db	 8Ch, 9Fh, 01h, 8Ah, 08h, 9Fh
		db	 00h,0A2h,0D0h, 08h, 00h,0A8h
		db	 50h, 00h, 01h, 00h, 51h, 9Fh
		db	 01h, 70h, 00h, 01h, 00h, 51h
		db	 00h, 02h, 00h, 73h, 00h, 06h
		db	 00h, 37h, 00h, 1Ch, 00h, 2Eh
		db	 00h, 28h, 00h, 30h, 00h, 28h
		db	 00h, 30h,0C0h, 00h,0D4h, 00h
		db	 40h, 00h,0DCh, 00h, 40h, 00h
		db	0F8h, 9Fh, 01h,0B0h, 00h, 90h
		db	 00h,0A0h, 00h, 08h, 00h, 10h
		db	 00h, 08h, 00h, 10h, 00h, 0Ch
		db	 9Fh, 02h,0C4h, 00h,0C8h, 03h
		db	 08h, 03h, 84h, 64h, 04h, 74h
		db	 08h, 00h, 04h, 00h, 08h, 9Fh
		db	 01h, 04h, 9Fh, 01h, 04h, 9Fh
		db	 06h, 03h, 9Fh, 02h, 40h, 00h
		db	 30h, 9Fh, 17h, 10h, 9Fh, 00h
		db	 10h, 10h, 9Fh, 00h, 01h, 92h
		db	 9Fh, 00h, 06h, 2Ah, 9Fh, 00h
		db	 05h,0BFh, 9Fh, 00h, 23h, 6Dh
		db	 9Fh, 00h, 97h,0BEh, 9Fh, 00h
		db	 0Ah, 7Dh, 9Fh, 01h, 20h, 9Fh
		db	 04h, 04h, 9Fh, 01h, 40h, 48h
		db	 9Fh, 00h, 1Eh,0C0h, 9Fh, 00h
data_5		db	5Dh
		db	 00h, 22h,0C0h,0FBh,0A0h, 04h
		db	 50h,0F5h, 40h, 0Ah,0B8h, 02h
		db	0B9h, 9Fh, 00h, 09h, 0Dh, 00h
		db	 50h, 04h, 71h, 00h, 88h, 01h
		db	0A1h, 02h, 58h, 06h,0F1h, 01h
		db	 08h, 0Dh, 69h, 02h, 90h, 1Fh
		db	0B0h, 00h, 49h, 17h, 50h, 08h
		db	0ACh,0DAh,0A0h, 25h, 5Ch, 37h
		db	 40h,0C8h,0BEh, 74h,0F2h, 8Bh
		db	 0Dh,0EBh, 81h, 14h, 7Eh, 55h
		db	 14h,0AAh,0EBh, 6Ah, 14h, 95h
		db	0EAh,0F5h, 20h, 0Ah,0D4h,0BAh
		db	 50h, 45h,0A8h, 1Eh, 50h, 01h
		db	0AEh, 0Dh,0E4h, 02h, 18h, 02h
		db	0B0h, 05h, 4Ch, 00h,0A0h, 01h
		db	 5Ah, 9Fh, 01h, 1Ch, 9Fh, 0Ah
		db	 52h, 00h, 2Dh,0D0h, 04h, 00h
		db	 2Ah,0C0h, 00h, 20h, 50h, 00h
		db	 15h, 08h, 80h, 00h, 2Bh, 80h
		db	 9Fh, 00h, 16h, 90h, 9Fh, 00h
		db	 03h, 02h, 9Fh, 00h, 05h, 9Fh
		db	 01h, 01h, 9Fh, 01h, 04h, 9Fh
		db	 01h, 08h, 08h, 9Fh, 00h, 0Ch
		db	 08h, 9Fh, 00h, 8Ch, 08h, 9Fh
		db	 00h, 46h, 30h, 9Fh, 00h, 61h
		db	 40h, 9Fh, 00h, 1Ch, 0Dh, 9Fh
		db	 04h, 01h, 40h, 9Fh, 01h,0A0h
		db	 9Fh, 01h, 30h, 9Fh, 01h, 10h
		db	 9Fh, 01h, 20h, 9Fh, 00h, 54h
		db	 80h, 9Fh, 04h, 10h, 00h, 10h
		db	 00h
		db	8, 8, 8, 8, 0Ch, 8, 0Ch, 8
		db	 0Fh, 0Ch, 0Fh, 0Ch, 06h,0C8h
		db	 07h,0C8h, 03h,0E4h, 03h,0E4h
		db	 03h, 96h, 03h,0F6h, 03h,0F7h
		db	 03h,0FFh, 9Fh, 0Bh, 04h, 00h
		db	 04h, 00h, 10h, 00h, 10h, 00h
		db	 50h, 00h, 50h, 01h,0A0h, 01h
		db	0A0h, 4Fh, 40h, 4Fh, 40h, 03h
		db	0B5h, 03h,0FFh, 03h,0D2h, 03h
		db	0DEh, 07h,0E9h, 07h,0FFh, 02h
		db	0D2h, 02h,0FDh, 03h,0ABh, 03h
		db	 74h, 25h,0F7h, 06h, 08h, 0Bh
		db	0BDh, 0Ah,0C2h, 26h,0FFh, 24h
		db	 00h, 2Ch, 80h, 3Ch, 80h,0ABh
		db	 00h,0EFh, 00h, 02h, 00h,0DAh
		db	 00h, 74h, 00h,0F4h, 00h, 9Ah
		db	 08h,0FEh, 08h, 9Ch,0C0h, 44h
		db	0C0h, 47h, 00h, 97h, 00h,0D5h
		db	 4Ah, 3Dh, 4Ah, 0Eh,0DFh, 0Ah
		db	 88h, 03h, 77h, 18h, 01h, 19h
		db	 2Ah, 04h, 00h, 16h, 06h, 19h
		db	0D6h, 08h, 68h, 0Dh, 8Ch
		db	'D$'
		db	'GI)X)R'
		db	 02h, 14h, 02h, 14h,0F5h, 00h
		db	 0Dh, 00h,0F8h, 00h, 9Ch, 00h
		db	0EAh, 40h, 42h, 40h, 17h
		db	'@?@K@K@1`1`'
		db	 12h, 10h, 12h, 10h, 08h, 04h
		db	 08h, 04h, 04h, 00h, 04h, 9Fh
		db	 02h, 80h, 04h, 00h, 06h, 01h
		db	 82h, 00h, 82h,0D0h, 80h, 02h
		db	0C0h, 0Eh, 04h, 41h, 6Ch, 49h
		db	 20h, 04h, 31h, 04h, 01h, 28h
		db	 03h,0A8h, 00h, 40h, 00h, 40h
		db	 02h, 08h, 02h, 08h, 00h, 40h
		db	 00h, 40h, 00h,0A0h, 00h,0A0h
		db	 00h, 40h, 00h, 40h, 00h, 70h
		db	 00h, 70h, 9Fh, 03h, 10h, 00h
		db	 10h,0A0h, 00h,0A0h, 00h,0A8h
		db	 01h,0E8h, 01h, 5Ah, 04h, 5Ah
		db	 04h,0AAh, 00h,0BEh, 20h, 21h
		db	 91h, 2Dh, 91h
		db	9, '@-HX X $'
		db	 00h, 24h, 9Fh, 03h, 01h, 00h
		db	 01h, 00h, 10h, 01h, 10h, 01h
		db	 00h, 8Ah, 00h, 8Ah, 84h, 22h
		db	 84h, 22h, 2Ah, 64h, 2Bh, 74h
		db	0A9h, 30h,0ADh,0F0h, 04h, 58h
		db	 25h,0D8h, 90h, 14h, 90h, 14h
		db	 50h, 04h, 50h, 04h, 20h, 00h
		db	 20h, 00h, 80h, 29h, 80h,0B9h
		db	 82h,0A0h, 83h,0A0h, 06h, 00h
		db	 06h, 00h, 08h, 05h, 08h, 05h
		db	 00h, 0Ch, 00h, 0Ch, 00h, 90h
		db	 00h, 90h, 0Ah, 10h, 0Ah, 10h
		db	 07h, 00h, 07h, 00h, 01h, 88h
		db	 01h, 88h, 40h, 40h, 40h, 40h
		db	 02h, 00h, 02h, 00h, 01h, 80h
		db	 01h, 80h, 00h, 80h, 00h, 80h
		db	 00h, 88h, 00h, 88h, 00h, 04h
		db	 00h, 04h, 00h, 40h, 00h, 40h
		db	0A7h, 02h, 11h, 80h, 11h, 80h
		db	 00h,0A0h, 00h,0E0h, 08h, 50h
		db	 08h, 50h, 09h, 00h, 09h, 80h
		db	 01h, 00h, 01h, 9Fh, 00h, 10h
		db	 00h, 10h, 00h, 60h, 00h, 60h
		db	 05h, 41h, 05h, 41h, 9Dh, 00h
		db	 9Dh, 01h, 9Fh, 01h, 06h, 20h
		db	 0Ah, 20h, 1Eh, 28h, 08h, 28h
		db	0A8h, 1Ah,0A0h, 1Ah,0A0h, 09h
		db	 35h, 09h,0F5h, 08h,0D4h, 0Ah
		db	0DEh, 24h, 21h, 24h, 61h, 11h
		db	 1Ah, 11h, 1Ah, 80h, 18h, 80h
		db	 18h, 00h, 20h, 00h, 20h, 00h
		db	 40h, 00h, 40h, 0Eh, 40h, 0Eh
		db	 40h, 20h, 02h, 30h, 02h, 00h
		db	 04h, 80h, 04h, 04h, 18h, 04h
		db	 18h, 00h,0C0h, 00h,0C0h, 00h
		db	 20h, 00h, 20h, 00h, 8Ah, 00h
		db	 8Ah, 00h, 02h, 00h, 02h, 01h
		db	 00h, 01h, 60h, 9Fh, 01h, 08h
		db	 00h, 01h, 00h,0A4h, 02h, 05h
		db	0A7h, 00h, 00h, 1Ch, 00h, 02h
		db	 00h, 08h, 00h, 17h, 9Fh, 01h
		db	 06h, 00h, 04h, 00h, 04h, 9Fh
		db	 06h,0A0h, 00h, 30h, 00h,0E0h
		db	 00h, 6Ch, 00h,0E0h, 00h,0E9h
		db	0C0h, 01h, 80h,0F2h, 50h, 30h
		db	 00h,0B7h, 48h, 60h, 10h, 60h
		db	 4Ch, 00h, 08h, 00h, 08h, 80h
		db	 00h, 80h, 00h, 0Dh, 00h, 21h
		db	0C0h, 2Fh, 03h, 13h, 70h,0E7h
		db	 02h, 17h, 51h, 40h, 00h,0BEh
		db	0D3h, 00h, 0Ch, 0Dh, 40h, 50h
		db	 0Ch, 50h, 04h, 44h,0C0h
		db	 45h, 2Ah
data_6		dw	8			; Data table (indexed access)
		db	 09h, 01h, 00h,0D0h, 00h, 2Dh
		db	 0Eh, 38h,0C1h, 07h, 02h, 08h
		db	0D1h,0C5h, 00h, 08h,0A3h, 45h
		db	 30h,0C0h, 32h,0CCh, 0Ch, 30h
		db	 0Ch, 30h, 9Fh, 02h, 02h, 00h
		db	 02h,0D0h, 00h, 03h, 00h, 08h
		db	 00h, 0Bh, 01h, 44h, 02h, 39h
		db	 02h, 05h, 00h, 10h, 00h, 2Fh
		db	 9Fh, 01h, 0Dh, 00h, 08h, 00h
		db	 08h, 9Fh, 06h, 40h, 00h, 60h
		db	 00h,0C0h, 00h,0D8h, 00h,0C0h
		db	 00h,0D3h, 80h, 03h, 00h,0E4h
		db	0A0h, 60h, 00h, 6Eh, 90h,0C0h
		db	 20h,0C0h, 98h, 00h, 04h, 00h
		db	 04h, 10h, 00h, 10h, 00h, 01h
		db	0A0h, 04h, 38h, 05h,0E0h, 02h
		db	 6Eh, 1Ch,0E0h, 02h,0EAh, 08h
		db	 00h, 17h,0DAh, 00h, 03h, 01h
		db	0A9h, 00h, 0Ch, 9Fh, 00h, 44h
		db	0C0h, 45h, 2Ah, 08h, 00h, 09h
		db	 01h, 00h, 70h, 00h, 8Dh, 63h
		db	 0Ch, 10h, 93h, 40h,0C4h, 3Ch
		db	 23h, 00h, 44h, 3Ch, 21h, 06h
		db	 0Ch, 06h, 0Ch, 0Ch, 30h, 0Ch
		db	 30h, 9Fh, 0Ah, 20h, 00h, 2Dh
		db	 9Fh, 00h, 34h, 00h, 86h, 00h
		db	0BCh, 14h, 4Dh, 23h, 9Ch, 20h
		db	 5Dh, 01h, 00h, 02h,0FEh, 9Fh
		db	 14h, 80h, 9Fh, 01h, 38h, 00h
		db	 30h, 00h, 4Bh, 9Fh, 02h,0EAh
		db	 04h, 1Ah, 04h, 43h, 00h, 5Eh
		db	 00h, 26h, 01h,0CEh, 00h, 2Eh
		db	 00h, 80h, 01h, 7Dh, 9Fh, 01h
		db	 1Ah, 00h, 03h, 9Fh, 04h, 03h
		db	 00h
loc_1:
;*		cmp	al,al
		db	 38h,0C0h		;  Fixup - byte match
		add	[bx+si],bl
		add	byte ptr [si],6
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
		inc	si
		add	al,32h			; '2'
		mov	data_4,ax
		and	byte ptr ss:[0D31Dh][bp+di],ah
		mov	al,byte ptr ds:[995Ch]
		push	es
		or	al,[bp+si]
;*		jmp	far ptr loc_5		;*
		db	0EAh
		dw	3042h, 3042h		;  Fixup - byte match
			                        ;* No entry point to code
		lahf				; Load ah from flags
		or	ax,[bp+si]
		add	[bp+si],al
		inc	ax
		add	[bx+si+1],al
		add	[bx+si],dl
		and	[bx+si],bl
		add	byte ptr [bx+si],90h
		add	al,[bp+di]
		inc	dx
		dec	ax
		inc	cx
		lahf				; Load ah from flags
		push	ss
		rol	byte ptr [bx+si],1	; Rotate
		sbb	al,0
                           lock	add	[bx],dh
		add	[bp+di],cl
		mov	byte ptr [si],0D1h
;*		sbb	sp,ax
		db	 19h,0C4h		;  Fixup - byte match
		add	ax,10D3h
		add	[bx],cl
		mov	al,0
		sbb	[bp+di],al
		inc	bp
		or	al,41h			; 'A'
		or	al,78h			; 'x'
;*		and	bl,al
		db	 20h,0C3h		;  Fixup - byte match
;*		and	bl,al
		db	 20h,0C3h		;  Fixup - byte match
		add	[si],ax
		add	[si],ax
		add	[si],al
		add	[si],al
		jo	$+2			; delay for I/O
		jnz	loc_1			; Jump if not zero
;*		add	bp,bp
		db	 01h,0EDh		;  Fixup - byte match
		xor	byte ptr ds:[0D6C0h],al
		cmp	[bx+si],bl
		sbb	byte ptr [bx+di],66h	; 'f'
		add	[si-48h],ch
		db	 63h, 31h, 90h, 8Bh,0AFh, 00h
		db	 10h, 6Ah, 96h, 10h, 10h, 10h
		db	 10h, 9Fh, 0Ah, 20h, 00h, 2Dh
		db	 9Fh, 00h, 34h, 00h, 86h, 00h
		db	0BCh, 14h, 4Dh, 23h, 9Ch, 20h
		db	 5Dh, 01h, 00h, 02h,0FEh, 9Fh
		db	 14h, 80h, 9Fh, 01h, 38h, 00h
		db	 30h, 00h, 4Bh, 9Fh, 02h,0EAh
		db	 04h, 03h, 04h, 03h, 00h, 44h
		db	 00h, 04h, 01h,0CAh, 00h, 2Ah
		db	 00h, 80h, 01h, 7Dh, 9Fh, 01h
		db	 1Ah, 00h, 03h, 9Fh, 04h, 03h
		db	 00h, 78h,0C0h, 00h, 18h,0D3h
		db	0C4h, 18h, 00h, 1Fh
		db	56h
loc_2:
		and	word ptr ss:[8CA1h][bp+si],si
		add	al,20h			; ' '
		mov	byte ptr ds:[0D31Dh],al
		sbb	byte ptr [si-67h],6
		or	al,[bp+si]
		retf	3042h
			                        ;* No entry point to code
		inc	dx
		xor	data_2[bx],bl
		add	[bp+si],al
		inc	ax
		add	[bx+si+1],al
		add	[bx+si],dl
		and	[bx+si],bl
		add	byte ptr [bx+si],90h
		add	al,[bp+di]
		inc	ax
		dec	ax
		inc	ax
		lahf				; Load ah from flags
		push	ss
		rol	byte ptr [bx+si],1	; Rotate
		sbb	al,0
		mov	al,0
		aaa				; Ascii adjust
		add	[bp+di],cl
		db	0C0h, 04h,0D8h, 19h,0C3h, 05h
		db	0D8h, 10h, 02h, 0Fh,0B1h, 00h
		db	 18h, 03h, 45h, 0Ch, 40h, 0Ch
		db	 79h, 20h,0C3h, 20h,0C3h, 01h
		db	 04h, 01h, 04h, 00h, 04h, 00h
		db	 04h, 10h, 00h, 15h, 9Fh, 00h
		db	 20h, 05h, 10h, 30h, 00h, 88h
		db	 78h, 10h, 00h, 8Ch, 26h, 01h
		db	 8Ch,0BCh, 43h, 00h, 10h,0B9h
		db	0CFh, 10h, 10h, 1Ah, 96h, 10h
		db	 10h, 10h, 10h, 9Fh, 07h, 07h
		db	 00h, 09h, 00h, 27h, 00h, 11h
		db	 03h, 07h, 00h, 97h, 02h, 00h
		db	 09h,0CFh, 10h, 0Ch, 09h,0EDh
		db	 30h, 06h, 0Ah, 06h, 00h, 80h
		db	 06h, 80h, 9Fh, 00h, 10h, 9Fh
		db	 01h, 25h, 00h, 20h, 40h, 40h
		db	 40h, 18h, 00h, 60h, 9Fh, 01h
		db	0E8h, 9Fh, 01h,0A0h, 00h, 20h
		db	 00h, 20h, 00h, 03h, 22h, 74h
		db	0A2h, 80h, 10h, 00h, 90h, 8Bh
		db	 00h, 34h, 00h, 1Ch,0D3h,0E0h
		db	 20h, 13h, 02h,0A0h,0C9h, 10h
		db	 00h,0A2h,0C5h, 03h, 0Ch, 31h
		db	 44h, 0Ch, 30h, 04h, 10h, 10h
		db	 00h, 10h, 9Fh, 00h, 01h, 00h
		db	 01h, 02h,0E0h, 01h, 24h, 8Ch
		db	0E4h, 42h, 28h, 00h,0E1h,0CAh
		db	0EEh, 9Fh, 00h,0CBh, 75h, 30h
		db	 00h, 32h,0D0h, 30h, 0Ah, 30h
		db	 0Ah, 9Fh, 07h, 03h, 00h, 04h
		db	 00h, 03h, 00h, 18h, 01h, 83h
		db	 00h, 4Bh, 01h, 00h, 04h,0E7h
		db	 0Ch, 06h, 02h, 76h, 00h, 03h
		db	 1Dh, 03h, 9Fh, 03h, 40h, 0Bh
		db	 40h, 80h, 00h, 90h, 00h, 90h
		db	 00h,0A2h, 80h, 8Ch, 40h,0B0h
		db	 40h, 9Fh, 00h,0F4h, 9Fh, 01h
		db	0D0h, 00h, 10h, 00h, 10h, 00h
		db	 64h, 22h, 13h,0A2h, 80h, 10h
		db	 40h, 90h, 8Eh, 00h, 31h, 00h
		db	 30h,0C8h,0C9h, 06h, 23h, 30h
		db	0C4h, 0Eh, 22h, 00h, 84h
		db	'<0`0`', 0Ch, '0', 0Ch, '0 '
		db	 00h, 20h, 9Fh, 00h, 08h, 00h
		db	 08h, 17h, 00h, 09h, 20h, 67h
		db	 20h, 11h, 40h, 07h, 18h, 57h
		db	 60h, 9Fh, 00h, 5Bh, 68h,0C0h
		db	 00h, 96h, 80h, 30h, 9Fh, 16h
		db	 03h, 9Fh, 01h, 18h, 00h, 04h
		db	 00h,0D0h, 00h, 0Eh, 9Fh, 0Bh
		db	 04h, 00h,0B4h,0B8h, 00h, 49h
		db	 00h, 39h, 00h, 8Ah, 28h, 38h
		db	0C4h,0BBh, 04h, 9Fh, 00h, 7Fh
		db	 40h, 03h, 9Fh, 00h,0DCh, 30h
		db	 00h, 08h, 01h, 40h, 60h, 22h
		db	 07h, 0Ch,0C0h, 50h, 25h, 30h
		db	 00h, 8Ch,0E5h, 01h,0CBh, 9Dh
		db	':P`W@', 0Ch, 'B', 0Ch, 'B'
		db	 9Fh, 00h, 55h, 00h, 70h, 20h
		db	 92h, 20h, 72h, 00h, 14h, 00h
		db	 71h, 80h, 76h, 9Fh, 01h,0BAh
		db	 80h, 9Fh, 00h, 58h, 00h,0C0h
		db	 9Fh, 1Eh, 2Eh, 00h, 12h, 00h
		db	0CEh, 00h, 22h, 9Fh, 0Ah, 40h
		db	 00h, 40h, 9Fh, 00h, 02h, 80h
		db	 02h, 08h, 00h, 18h, 04h, 00h
		db	 01h, 40h, 09h, 43h,0DBh, 00h
		db	 92h, 00h, 0Eh, 00h,0AEh, 08h
		db	 00h, 04h,0B7h, 30h, 60h, 0Fh
		db	 6Ah, 40h, 18h, 27h, 98h,0C6h
		db	 00h, 36h, 1Dh, 89h, 80h, 75h
		db	0DDh, 08h, 00h, 69h, 56h, 08h
		db	 08h, 08h, 08h, 2Bh, 90h,0C0h
		db	0A0h, 2Bh, 88h, 43h,0B0h, 9Fh
		db	 00h, 8Dh,0A8h, 9Fh, 00h,0BAh
		db	0C0h, 82h, 30h, 1Eh, 30h,0C3h
		db	 04h,0C3h, 04h, 20h, 80h, 20h
		db	 80h, 20h, 00h, 20h, 9Fh, 16h
		db	 01h, 00h, 18h, 00h, 04h, 00h
		db	 90h, 00h, 4Eh, 9Fh, 0Bh, 04h
		db	 00h,0B4h, 38h, 00h, 49h, 00h
		db	 39h, 00h, 8Ah, 28h, 38h,0C4h
		db	0BBh, 04h, 9Fh, 00h, 7Fh, 40h
		db	 03h, 9Fh, 00h,0DEh, 20h, 00h
		db	 1Bh,0CBh, 40h, 18h, 2Ah,0F8h
		db	0CDh, 84h, 31h, 85h, 84h, 20h
		db	 38h, 45h, 01h,0CBh, 99h,0FBh
		db	'P`S`', 0Ch, 'B', 0Ch, 'B'
		db	 9Fh, 00h, 55h, 00h,0C0h, 20h
		db	0C0h, 20h, 22h, 00h, 20h, 00h
		db	 50h, 80h, 57h, 9Fh, 01h,0BAh
		db	 80h, 9Fh, 00h, 58h, 00h,0C0h
		db	 00h,0C0h, 9Fh, 1Ch, 6Eh, 00h
		db	 12h, 00h,0CEh, 00h, 22h, 9Fh
		db	 0Ah, 40h, 00h, 40h, 9Fh, 00h
		db	 02h, 80h, 02h, 08h, 00h, 18h
		db	 04h, 00h, 01h, 40h, 09h, 03h
		db	 80h, 00h, 92h, 00h, 08h, 02h
		db	0A8h, 08h, 00h, 06h,0A0h, 18h
		db	 19h, 06h, 04h, 40h, 20h, 24h
		db	 19h,0C3h, 00h, 30h,0BDh, 08h
		db	 00h,0F3h, 9Dh
		db	8, 8, 'iX', 8, 8, 8, 8
		db	 03h, 90h, 18h,0A0h,0C3h, 88h
		db	 1Bh,0B0h, 80h, 08h, 4Dh,0F0h
		db	 9Fh, 00h,0AAh,0C0h, 02h, 30h
		db	 9Eh, 30h,0C3h, 04h,0C3h, 04h
		db	 20h, 80h, 20h, 80h, 20h, 00h
		db	 20h, 9Fh, 00h, 20h, 00h, 20h
		db	 00h, 18h, 00h, 18h, 00h, 01h
		db	 9Fh, 01h, 18h, 00h, 06h, 03h
		db	 30h, 03h, 0Fh, 08h, 40h, 08h
		db	 27h, 00h, 60h, 00h, 92h, 11h
		db	 80h, 10h, 5Ch, 00h, 04h, 00h
		db	 54h, 37h, 00h, 0Fh, 00h, 83h
		db	 01h, 7Bh, 95h, 9Fh, 00h, 7Fh
		db	0C0h, 9Fh, 00h, 35h, 40h, 9Fh
		db	 00h,0A8h, 00h, 60h, 00h, 60h
		db	 00h, 10h, 80h, 10h,0DBh, 01h
		db	 90h, 40h, 00h, 31h, 90h, 08h
		db	 07h, 19h, 40h, 84h, 3Bh, 00h
		db	 3Ch,0CDh, 1Ch, 00h, 1Fh,0ECh
		db	 30h, 00h, 0Fh,0A1h, 60h, 30h
		db	 1Dh, 30h, 00h, 12h, 28h, 12h
		db	 63h, 00h, 03h, 9Fh, 00h, 04h
		db	 36h, 04h, 06h, 30h,0B0h,0B0h
		db	 00h, 80h,0ACh, 20h, 9Fh, 00h
		db	 03h, 20h, 00h, 0Ch,0A6h,0ECh
		db	 88h, 01h, 55h, 01h, 00h,0C0h
		db	 00h,0C0h, 04h, 11h, 9Fh, 01h
		db	 09h, 9Fh, 00h, 10h,0CDh, 9Fh
		db	 00h, 02h, 06h, 9Fh, 00h, 20h
		db	 89h, 9Fh, 00h, 03h, 3Fh, 9Fh
		db	 00h, 15h,0FFh, 00h, 02h,0ADh
		db	0FFh, 00h, 10h, 0Dh, 40h, 03h
		db	 40h, 60h, 80h, 0Eh,0A5h, 9Fh
		db	 00h, 85h, 50h, 9Fh, 00h, 49h
		db	 50h, 80h, 00h,0AAh, 00h, 58h
		db	 00h,0D8h, 00h, 24h, 20h, 64h
		db	 20h,0F0h,0C0h,0FAh,0C0h, 02h
		db	 67h, 41h, 6Eh, 00h, 8Fh, 40h
		db	 2Fh, 1Ch, 55h, 02h, 17h,0ECh
		db	 00h,0F3h, 16h, 70h, 00h, 7Dh
		db	 30h,0C0h, 00h, 3Ah, 86h, 80h
		db	0C2h, 54h,0C1h, 00h, 48h,0A0h
		db	 48h,0FCh,0B5h, 9Fh, 00h,0FBh
		db	0A0h, 20h, 00h,0FCh,0C0h, 8Ch
		db	 00h, 92h, 04h, 9Fh, 00h, 60h
		db	 20h, 9Fh, 00h,0B2h, 9Fh, 01h
		db	 90h, 9Fh, 01h, 88h, 20h, 9Fh
		db	 00h, 82h, 04h, 83h, 04h, 20h
		db	 20h, 60h, 20h, 01h, 00h, 09h
		db	 40h, 80h, 04h, 83h, 04h, 01h
		db	0A4h, 11h,0A4h, 12h, 98h, 12h
		db	0B9h, 06h, 3Ch, 06h, 3Eh, 2Ch
		db	0ABh, 2Ch, 2Ch, 9Fh, 03h, 30h
		db	 00h, 30h, 2Ch, 0Ch, 3Ch, 0Ch
		db	0C5h, 02h,0C7h, 82h, 01h,0A2h
		db	 01h,0E2h,0AAh, 30h,0A8h, 30h
		db	 9Bh, 18h,0FBh, 18h, 86h, 00h
		db	 6Eh, 00h, 6Eh, 4Fh, 6Eh, 7Ch
		db	 65h, 16h, 65h, 3Fh, 31h, 26h
		db	 31h, 36h, 54h, 02h, 74h, 02h
		db	 66h,0ECh, 66h,0ECh, 60h, 7Eh
		db	 70h, 7Eh, 98h, 14h, 9Ch, 94h
		db	 41h, 80h, 41h, 80h,0D5h, 00h
		db	 34h, 00h, 3Ch, 00h, 7Ch, 00h
		db	 19h, 08h, 9Dh, 08h, 25h, 80h
		db	 25h, 88h, 20h, 01h, 20h,0C1h
		db	0DBh, 00h, 82h, 90h, 04h, 04h
		db	 04h, 06h, 20h, 41h, 20h,0C1h
		db	 9Fh, 03h, 30h, 00h, 06h, 00h
		db	 64h, 00h, 2Bh, 00h,0D8h, 00h
		db	 47h, 00h,0B0h, 00h, 8Ch, 00h
		db	 03h, 00h, 72h, 00h, 4Fh, 00h
		db	0A8h, 00h, 15h, 00h,0D1h,0C0h
		db	 00h, 18h, 00h, 80h, 00h, 4Ah
		db	 00h, 30h, 00h, 35h, 00h, 58h
		db	 00h, 5Ah, 00h,0D4h, 00h, 94h
		db	 00h,0ECh, 00h, 6Ch,0C0h, 40h
		db	 00h, 59h, 60h, 8Ch, 00h, 92h
		db	 20h, 00h, 0Bh, 00h, 0Bh, 00h
		db	 63h, 00h, 93h, 00h,0C0h, 01h
		db	 14h, 00h,0C0h, 01h, 2Ch, 03h
		db	 81h, 04h, 3Dh, 06h, 01h, 11h
		db	 79h, 30h, 02h, 0Ah,0F2h, 9Fh
		db	 00h, 57h, 80h, 90h, 00h,0A9h
		db	 40h, 18h, 00h, 23h, 00h, 04h
		db	 20h, 11h,0A0h,0E2h, 10h,0A4h
		db	 90h,0F2h, 28h, 15h,0A8h,0A0h
		db	 38h, 23h, 28h,0D8h, 74h, 58h
		db	 44h,0BEh, 57h,0BEh, 57h, 9Fh
		db	 07h, 1Ah, 00h, 02h, 00h, 6Bh
		db	 00h
		db	43h
loc_3:
		add	byte ptr ds:[9000h][bx+si],dl
		add	[bx+di],ah
;*		add	[bx+di+0],cl
		db	 00h, 49h, 00h		;  Fixup - byte match
		db	 61h, 00h, 88h, 00h,0C7h, 01h
		db	 14h, 9Fh, 06h, 30h, 00h, 48h
		db	 00h, 20h, 00h, 4Ch, 00h,0B0h
		db	 00h,0C2h, 00h, 90h, 00h,0E6h
		db	 00h, 48h, 00h, 66h, 00h, 80h
		db	 00h, 8Ch, 9Fh, 00h, 8Eh, 01h
		db	 38h, 00h, 05h, 00h,0B4h, 00h
		db	 03h, 00h, 30h, 00h, 07h, 01h
		db	 45h, 01h, 82h, 02h, 22h, 03h
		db	 01h, 14h, 51h, 14h, 01h, 2Ah
		db	0F1h, 00h, 05h, 55h, 85h, 81h
		db	 00h, 82h,0C0h, 47h, 00h, 48h
		db	0B0h,0C0h, 00h, 55h, 60h, 64h
		db	 10h, 6Ah,0D0h,0A0h, 08h,0A5h
		db	0E8h, 51h, 88h, 52h, 78h,0BAh
		db	 80h, 3Ah,0BCh, 7Dh, 40h, 7Dh
		db	 5Fh, 9Fh, 03h, 40h, 00h, 23h
		db	 00h, 99h, 00h, 58h, 01h,0B5h
		db	 00h, 24h, 01h, 18h, 00h, 88h
		db	 00h, 1Ch, 01h, 44h, 00h, 1Ch
		db	 00h,0D4h, 00h, 0Dh, 00h, 09h
		db	 9Fh, 04h, 60h, 00h,0C0h, 00h
		db	 4Ch, 00h,0D8h, 00h,0D8h, 00h
		db	 78h, 00h, 4Ch, 00h,0A0h, 00h
		db	0CBh, 00h, 34h, 00h, 48h, 80h
		db	 18h, 00h, 22h,0A0h, 00h, 0Dh
		db	 00h
data_7		db	49h			; Data table (indexed access)
		db	 00h, 02h, 00h, 42h, 00h, 03h
		db	 00h,0A2h, 00h, 85h, 01h, 44h
		db	 01h, 86h, 02h, 24h, 03h, 0Fh
		db	 00h, 68h, 05h, 1Ah, 0Ah, 90h
		db	 20h, 15h, 55h,0D1h, 84h, 00h
		db	 91h,0C0h,0C1h, 00h,0C8h,0E0h
		db	0C0h, 00h, 45h, 40h, 63h, 00h
		db	 60h, 50h,0E8h, 90h, 69h, 74h
		db	0B5h, 28h, 35h, 4Ah,0BAh,0E8h
		db	0A2h,0EAh, 5Eh,0ACh, 5Eh,0ADh
		db	 00h, 06h, 9Fh, 00h, 01h, 84h
		db	 00h, 32h, 03h, 21h, 01h, 59h
		db	 06h,0C2h, 02h, 3Ah, 05h, 86h
		db	 04h, 64h, 03h, 1Fh, 00h, 93h
		db	 02h, 7Ah, 01h, 42h, 00h, 0Ch
		db	 00h,0ECh, 9Fh, 00h,0C0h, 9Fh
		db	 01h, 5Ah, 00h, 80h, 00h,0AAh
		db	0D0h,0C1h,0C0h,0D6h, 14h,0A0h
		db	 80h,0A2h, 3Ch, 60h, 00h, 65h
		db	0E8h, 9Fh, 00h,0CBh, 40h, 60h
		db	 00h, 91h, 9Fh, 00h, 60h, 00h
		db	0Ch
data_8		dw	4018h			; Data table (indexed access)
		db	 03h, 25h, 32h, 18h, 15h, 9Ah
		db	 6Ch, 2Ch, 23h,0ADh, 58h, 6Ah
		db	 47h, 4Ah, 00h,0F6h, 0Eh, 36h
		db	 00h, 20h, 07h, 2Eh, 00h, 16h
		db	 01h,0D9h, 9Fh, 08h, 80h, 9Fh
		db	 01h, 58h, 00h, 03h, 40h, 68h
		db	 92h, 9Fh, 00h, 6Eh, 80h, 9Fh
		db	 00h,0B0h, 9Fh, 01h, 54h, 9Fh
		db	 04h, 0Ch, 00h, 01h, 02h,0B9h
		db	 02h,0AAh, 2Fh, 76h, 28h, 11h
		db	 2Ah,0ACh, 2Ah,0A3h, 0Ah,0C0h
		db	 0Ah,0DCh, 00h, 93h, 00h,0AAh
		db	 00h, 05h, 00h, 74h, 30h, 00h
		db	 06h, 00h, 20h, 00h, 92h, 80h
		db	 0Ch, 00h,0CDh, 40h, 16h, 00h
		db	0D6h, 80h, 35h, 00h, 25h, 00h
		db	0FBh, 00h, 9Bh, 20h,0D0h, 00h
		db	 16h, 70h, 63h, 00h, 64h,0A0h
		db	 9Fh, 03h, 01h, 9Fh, 01h, 03h
		db	 00h, 01h, 00h, 56h, 00h, 52h
		db	 8Bh, 7Dh, 81h, 14h, 00h,0B0h
		db	 00h,0B3h, 00h, 02h, 00h, 0Dh
		db	 9Fh, 01h, 2Ah, 06h, 9Fh, 00h
		db	0C0h, 84h, 00h, 32h, 50h, 21h
		db	 80h, 59h,0A8h,0C2h,0C0h, 3Ah
		db	0D0h, 86h,0A0h, 64h,0A0h, 1Fh
		db	 60h, 93h, 64h, 7Ah, 00h, 42h
		db	0CCh,0ACh, 60h, 8Ch, 98h, 05h
		db	 80h, 05h, 80h, 1Dh, 00h, 1Dh
		db	 02h, 28h, 00h, 28h,0AAh, 18h
		db	 00h, 18h, 28h, 00h, 01h, 00h
		db	 01h, 00h,0D3h, 00h,0D3h, 02h
		db	0EFh, 02h,0EFh, 00h, 17h, 00h
		db	 17h, 9Fh, 01h, 58h, 9Fh, 00h
		db	 80h, 0Eh, 05h, 00h, 05h, 02h
		db	 0Bh, 00h, 0Bh, 14h, 44h, 00h
		db	 44h, 40h, 44h, 00h, 44h, 60h
		db	0A0h, 00h,0A0h, 80h, 9Fh, 01h
		db	 40h, 64h, 00h, 64h, 10h,0D0h
		db	 00h,0D0h, 80h, 40h, 00h, 41h
		db	 00h, 10h, 00h, 10h, 40h, 9Fh
		db	 02h, 24h, 12h, 24h, 12h, 02h
		db	0A0h, 02h,0A0h, 09h,0B1h, 09h
		db	0B1h, 9Fh, 01h, 06h, 00h, 80h
		db	 00h, 91h, 00h, 20h, 00h, 22h
		db	 04h, 88h, 04h, 89h, 01h, 80h
		db	 01h,0C0h, 03h, 00h, 03h, 60h
		db	 2Ch, 00h, 2Ch, 84h, 40h, 00h
		db	 40h, 40h, 00h, 08h, 40h, 08h
		db	 00h, 01h,0BAh, 01h, 9Fh, 00h
		db	 17h, 9Fh, 01h, 0Eh, 80h, 00h
		db	 08h, 0Ch, 08h, 00h, 10h, 16h
		db	 90h, 00h, 04h, 3Ah, 04h, 00h
		db	 50h, 54h, 50h, 90h, 00h,0A9h
		db	 44h, 98h, 00h,0A3h, 0Ch, 44h
		db	 21h, 51h,0A1h, 02h, 93h, 42h
		db	 93h, 03h,0AAh, 13h,0AAh, 2Fh
		db	 46h,0AFh, 46h, 1Ah, 0Eh, 1Ah
		db	 0Eh, 3Eh, 57h, 3Eh, 57h, 90h
		db	 00h, 90h, 00h, 80h, 00h,0A2h
		db	 40h, 9Fh, 00h, 08h, 08h, 40h
		db	 00h, 40h, 9Fh, 03h, 01h, 00h
		db	 01h, 00h, 10h, 00h, 10h, 00h
		db	 04h, 00h, 04h, 9Fh, 00h, 01h
		db	 00h, 09h, 08h, 04h, 08h, 24h
		db	 40h, 01h, 40h, 05h, 9Fh, 02h
		db	 08h, 00h, 08h, 9Fh, 00h, 02h
		db	 00h, 02h, 00h, 01h, 00h, 01h
		db	 00h, 04h, 00h, 04h, 9Fh, 02h
		db	 20h, 00h, 20h, 9Fh, 01h, 01h
		db	 9Fh, 04h, 01h, 80h, 51h, 9Fh
		db	 00h, 10h, 9Fh, 01h, 18h, 11h
		db	 9Fh, 00h, 09h, 9Fh, 00h, 80h
		db	 00h, 80h, 00h, 02h, 00h, 02h
		db	 9Fh, 03h,0A0h, 00h,0A0h, 01h
		db	 81h, 11h, 81h, 01h, 00h, 01h
		db	 00h, 08h, 06h, 08h, 06h, 00h
		db	 14h, 00h, 14h, 9Fh, 02h, 01h
		db	0A4h, 01h,0A4h, 0Bh,0F5h, 0Bh
		db	0F5h, 2Fh,0FFh, 2Fh,0FFh, 3Fh
		db	 5Eh, 3Fh,0FEh, 1Eh,0D5h, 1Fh
		db	0FFh, 0Bh,0A2h, 0Bh,0FFh, 05h
		db	0C4h, 05h,0FFh, 9Fh, 06h, 80h
		db	 00h, 80h, 00h, 51h, 40h, 51h
		db	 40h,0C2h,0E8h,0EAh,0E8h, 64h
		db	 5Eh, 76h,0FEh,0A9h, 8Fh,0EFh
		db	0FFh, 92h, 35h,0DFh,0F5h, 03h
		db	0A8h, 03h,0FFh, 05h,0D5h, 05h
		db	0FEh, 0Bh,0E4h, 0Bh,0FBh, 17h
		db	0A2h, 17h,0FFh, 1Bh,0ABh, 1Bh
		db	0FFh, 0Fh,0FEh, 0Fh,0FEh, 02h
		db	0B5h, 02h,0B5h, 00h, 50h, 00h
		db	 50h,0A8h, 2Ah, 5Fh,0BAh,0D5h
		db	 14h, 2Fh, 54h,0C1h, 60h, 3Bh
		db	 60h, 10h, 80h, 7Eh, 80h, 30h
		db	 40h, 35h, 40h,0ABh,0A0h,0ABh
		db	0A0h, 05h, 50h, 05h, 50h, 00h
		db	0A0h, 00h,0A0h, 00h, 2Eh, 00h
		db	 2Eh, 00h, 5Eh, 00h, 5Eh, 02h
		db	0FFh, 02h,0FFh, 05h, 5Dh, 05h
		db	 7Fh, 07h,0E2h, 07h,0FFh, 05h
		db	0D5h, 05h,0FFh, 02h,0A8h, 02h
		db	0FFh, 02h,0E8h, 02h,0FFh, 9Fh
		db	 02h,0A8h, 00h,0A8h, 00h, 68h
		db	 00h, 68h, 00h,0DAh, 80h,0DAh
		db	 80h,0F4h,0E0h,0F4h,0E0h, 7Eh
		db	0B8h,0FEh,0B8h, 3Dh, 7Eh,0FDh
		db	 7Eh,0ABh,0FFh,0DFh,0FFh, 15h
		db	0F2h, 15h,0FDh, 3Fh, 51h, 3Fh
		db	0FEh, 3Dh, 89h, 3Fh,0FFh, 17h
		db	0B0h, 17h,0FFh, 02h,0ABh, 02h
		db	0BFh, 00h,0EDh, 00h,0EFh, 00h
		db	 0Dh, 00h, 0Dh, 9Fh, 02h,0E9h
		db	 57h, 17h,0FFh,0B2h, 7Dh, 4Fh
		db	0FDh, 57h,0EAh,0BFh,0EAh, 47h
		db	 54h,0FFh, 54h, 55h, 40h,0FDh
		db	 40h,0B5h, 00h,0B5h, 00h, 56h
		db	 00h, 56h, 00h, 28h, 00h, 28h
		db	 9Fh, 00h, 03h, 00h, 03h, 00h
		db	 17h, 00h, 17h, 01h, 7Fh, 01h
		db	 7Fh, 02h,0F6h, 02h,0FFh, 09h
		db	0C2h, 09h,0FFh, 05h,0A4h, 05h
		db	0FFh, 0Fh,0A0h, 0Fh,0FFh, 06h
		db	 00h, 07h,0FFh,0B0h, 00h,0B0h
		db	 00h,0FDh, 00h,0FDh, 00h,0FAh
		db	 80h,0FAh, 80h, 5Dh, 60h,0FDh
		db	 60h, 9Ah,0F0h,0FFh,0F0h, 0Fh
		db	 50h,0FFh,0D0h, 05h,0E0h,0FFh
		db	0E0h,0A2h,0D0h, 5Fh,0D0h, 03h
		db	 51h, 03h,0FEh, 00h,0A5h, 00h
		db	0FEh, 01h, 40h, 01h, 7Fh, 05h
		db	0E5h, 05h,0FFh, 0Fh
		db	53h
loc_4:
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		dec	word ptr [bx]
		mov	di,0FF0Fh
		pop	es
		db	0F2h, 07h,0F2h, 00h,0A8h, 00h
		db	0A8h,0F5h,0F0h, 0Fh,0F0h, 49h
		db	0E8h,0BFh,0E8h, 22h,0B0h,0FFh
		db	0F0h, 48h, 7Ch,0FFh,0FCh, 7Ah
		db	 9Eh,0FFh,0FEh,0DFh, 7Ah,0FFh
		db	0FAh, 89h,0B4h, 89h,0B4h, 00h
		db	0D0h, 00h,0D0h, 9Fh, 03h, 7Eh
		db	 00h, 7Eh, 01h,0F7h, 01h,0FFh
		db	 07h,0FDh, 07h,0FFh, 0Fh,0D9h
		db	 0Fh,0FFh, 0Fh,0B0h, 0Fh,0FFh
		db	 0Fh, 40h, 0Fh,0FFh, 05h,0E8h
		db	 05h,0FFh, 9Fh, 02h, 80h, 00h
		db	 80h, 00h, 50h, 00h, 50h, 00h
		db	0FAh, 00h,0FAh, 00h, 6Bh,0A0h
		db	0EFh,0A0h, 42h,0B8h,0FFh,0F8h
		db	 00h,0CCh,0FFh,0ECh, 42h,0F4h
		db	0BFh,0F4h, 02h,0ADh, 02h,0BAh
		db	 01h, 55h, 01h
		db	5Eh
data_9		db	6			; Data table (indexed access)
		db	0ACh, 06h,0BBh, 0Dh,0A4h, 0Dh
		db	0FFh, 0Fh,0DAh, 0Fh,0FFh, 07h
		db	0FFh, 07h,0FFh, 01h, 75h, 01h
		db	 75h, 9Fh, 02h,0A4h,0B4h, 5Fh
		db	0F4h,0D3h,0D4h, 2Fh,0D4h,0C0h
		db	0A8h, 3Fh,0A8h, 15h, 10h,0FFh
		db	 50h,0F1h, 28h,0FDh,0A8h, 5Fh
		db	0F4h, 5Fh,0F4h, 0Fh,0C8h, 0Fh
		db	0C8h, 01h,0A0h, 01h,0A0h, 01h
		db	 02h, 01h, 02h, 03h, 47h, 03h
		db	 47h, 07h, 12h, 07h, 12h, 09h
		db	 40h, 09h,0D0h, 25h, 04h, 25h
		db	0C4h,0B0h, 90h,0B0h, 90h, 4Dh
		db	 05h, 4Dh, 05h, 0Eh, 81h, 0Eh
		db	0A1h, 9Fh, 02h, 21h, 70h, 21h
		db	 70h, 05h, 74h, 05h,0F4h, 40h
		db	0D4h, 40h,0F4h,0B4h, 10h,0B4h
		db	 10h,0D7h, 28h,0FFh, 28h, 12h
		db	 00h,0F2h, 00h, 4Ah, 10h, 7Eh
		db	 10h, 16h, 20h, 16h, 24h, 00h
		db	 61h, 00h, 71h, 09h, 8Ah, 09h
		db	 8Ah, 00h, 20h, 00h, 20h, 9Fh
		db	 0Eh, 36h, 80h,0B6h, 80h,0A8h
		db	0D0h,0E8h,0D0h, 43h, 68h, 43h
		db	 68h, 0Ch, 40h, 8Ch, 40h, 9Fh
		db	 0Fh, 40h, 00h, 40h, 10h, 90h
		db	 10h, 90h, 0Dh, 05h, 0Dh, 25h
		db	 0Eh, 01h, 0Eh, 81h, 16h, 24h
		db	 16h, 26h, 00h, 62h, 00h, 72h
		db	 09h, 93h, 09h, 9Bh, 00h, 31h
		db	 00h, 31h,0B0h, 00h,0B0h, 00h
		db	 92h, 20h, 92h, 20h,0A0h, 00h
		db	0E0h, 00h, 4Ah, 10h, 4Ah, 10h
		db	0D4h, 80h,0F4h, 80h,0A8h,0D0h
		db	0A8h,0D0h
		db	'ChCh', 0Ch, '@', 0Ch, '@'
		db	 00h, 14h, 00h, 14h, 00h, 01h
		db	 00h, 01h, 9Fh, 16h,0C0h, 00h
		db	0C0h, 00h,0A8h, 00h,0A8h, 00h
		db	 28h, 00h, 28h, 9Fh, 13h,0A7h
		db	 02h, 00h, 42h, 00h, 42h, 04h
		db	 09h, 04h, 0Dh, 21h, 25h, 21h
		db	 25h, 05h, 63h, 05h, 63h, 00h
		db	 02h, 00h, 06h, 00h, 8Ch, 00h
		db	 8Ch, 00h, 04h, 00h, 04h, 05h
		db	 00h, 05h, 00h, 98h, 84h, 99h
		db	 84h, 00h, 20h, 40h, 20h, 82h
		db	 00h, 82h, 00h, 80h, 50h, 80h
		db	 50h, 9Fh, 1Bh, 0Ah, 9Fh, 01h
		db	 2Bh, 9Fh, 01h,0BFh, 00h, 02h
		db	 2Ah,0FFh, 00h, 2Bh, 9Fh, 06h
		db	 80h, 9Fh, 01h, 80h, 9Fh, 01h
		db	0E8h, 00h, 80h, 00h,0FEh, 00h
		db	 80h, 00h,0FFh, 80h,0E0h, 00h
		db	0FFh,0EAh,0FAh, 9Fh, 00h,0BFh
		db	 00h, 02h, 00h, 2Fh, 9Fh, 01h
		db	 0Ah, 9Fh, 14h,0FFh, 80h,0E0h
		db	 00h,0FEh, 00h, 80h, 00h,0E8h
		db	 00h, 80h, 00h, 80h, 9Fh, 01h
		db	 80h, 9Fh, 01h, 80h, 9Fh, 0Ah
		db	 03h, 00h, 02h, 00h, 0Fh, 00h
		db	 02h, 03h, 03h, 02h, 00h, 30h
		db	 3Ch, 20h, 08h, 00h,0CCh, 9Fh
		db	 00h, 03h, 0Ch, 9Fh, 01h, 03h
		db	 00h, 02h,0F0h, 3Fh, 80h, 28h
		db	 9Fh, 02h,0C0h, 00h, 80h, 00h
		db	 0Ch, 00h, 08h, 9Fh, 03h,0F0h
		db	 30h,0A0h, 20h, 0Ch, 00h, 08h
		db	 9Fh, 03h,0C0h,0CFh, 80h, 00h
		db	 0Ch,0CFh, 9Fh, 01h, 03h, 00h
		db	 02h, 0Ch,0C0h, 9Fh, 01h, 0Fh
		db	 00h, 02h, 33h, 30h, 20h, 9Fh
		db	 04h,0C3h, 00h, 82h, 00h, 03h
		db	 9Fh, 00h,0CCh, 00h, 80h, 00h
		db	 03h,0C0h, 00h, 80h,0CCh, 9Fh
		db	 05h, 30h, 30h, 00h, 20h, 03h
		db	 00h, 02h, 00h,0F0h, 00h, 20h
		db	 9Fh, 07h, 03h, 00h, 02h, 9Fh
		db	 03h,0C0h, 00h, 80h, 9Fh, 00h
		db	 03h, 00h, 02h, 9Fh, 03h, 3Ch
		db	 00h, 20h, 30h, 30h, 20h, 9Fh
		db	 03h, 03h, 0Ch, 02h, 08h, 9Fh
		db	 06h, 30h, 00h, 20h, 00h, 03h
		db	 03h,0A7h, 00h,0C0h, 00h, 80h
		db	 00h, 03h, 9Fh, 02h, 0Ch, 00h
		db	 08h, 00h,0C0h, 00h, 80h, 00h
		db	 03h, 00h, 02h, 9Fh, 0Ah, 03h
		db	 00h, 02h, 00h,0C0h, 00h, 80h
		db	 00h,0F0h, 00h,0A0h, 00h,0F0h
		db	 00h, 80h, 00h, 03h, 00h, 02h
		db	 9Fh, 08h, 03h, 00h, 02h, 30h
		db	 30h, 20h, 20h, 9Fh, 0Fh, 1Fh
		db	 9Fh, 01h,0FDh, 9Fh, 00h, 03h
		db	0FEh, 9Fh, 00h, 06h,0F8h, 9Fh
		db	 00h, 0Dh,0E8h, 00h, 05h, 9Fh
		db	 0Ah,0D0h, 9Fh, 01h, 52h, 9Fh
		db	 01h, 8Ah, 40h, 9Fh, 01h, 20h
		db	 9Fh, 01h, 10h,0A0h, 00h, 0Dh
		db	 90h, 00h, 03h, 0Dh, 40h, 00h
		db	 05h, 06h, 40h, 9Fh, 00h, 03h
		db	 9Fh, 02h,0A0h, 9Fh, 01h, 15h
		db	 9Fh, 09h, 10h,0C0h, 9Fh, 00h
		db	 10h,0A0h, 9Fh, 00h, 20h, 9Fh
		db	 01h, 40h, 9Fh, 00h, 02h, 9Fh
		db	 01h, 50h, 9Fh, 16h, 1Fh, 9Fh
		db	 01h,0FDh, 9Fh, 00h, 03h,0FEh
		db	 9Fh, 00h, 06h,0F8h, 00h, 05h
		db	 0Dh,0E8h, 00h, 13h, 9Fh, 0Ah
		db	0D0h, 9Fh, 01h, 52h, 9Fh, 01h
		db	 8Ah, 40h, 9Fh, 01h, 20h, 50h
		db	 9Fh, 00h, 10h,0A8h, 00h, 0Dh
		db	 90h, 00h, 2Fh, 0Dh, 40h, 00h
		db	 17h, 06h, 40h, 00h, 0Ah, 03h
		db	 9Fh, 02h,0A0h, 9Fh, 01h, 15h
		db	 9Fh, 09h, 10h,0D0h, 9Fh, 00h
		db	 10h,0A8h, 9Fh, 00h, 20h, 40h
		db	 9Fh, 00h, 40h, 9Fh, 00h, 02h
		db	 9Fh, 01h, 50h, 9Fh, 16h, 1Fh
		db	 9Fh, 01h,0FDh, 9Fh, 00h, 03h
		db	0FEh, 00h, 01h, 06h,0F8h, 00h
		db	 07h, 0Dh,0E9h, 00h, 16h, 9Fh
		db	 0Ah,0D0h, 9Fh, 01h, 52h, 9Fh
		db	 01h, 8Ah, 40h, 20h, 9Fh, 00h
		db	 20h,0F5h, 00h, 40h, 10h,0BAh
		db	 00h, 0Dh, 92h, 00h, 2Dh, 0Dh
		db	 45h, 00h, 3Ah, 06h, 40h, 00h
		db	 1Fh, 03h, 9Fh, 00h, 0Ah, 00h
		db	0A0h, 9Fh, 01h, 15h, 9Fh, 08h
		db	 80h, 10h, 7Dh, 00h, 40h, 10h
		db	0BAh, 9Fh, 00h, 20h,0D4h, 9Fh
		db	 00h, 40h,0A0h, 00h, 02h, 9Fh
		db	 01h, 50h, 9Fh, 09h, 03h,0BFh
		db	 02h,0AAh, 08h, 9Fh, 01h, 18h
		db	 00h, 02h,0FEh, 30h, 00h, 20h
		db	 00h, 20h, 00h, 0Bh,0FAh, 20h
		db	 00h, 20h, 9Fh, 01h, 0Bh,0FAh
		db	 20h, 00h, 20h, 00h,0AAh,0F0h
		db	0AAh, 30h, 03h, 08h, 00h, 08h
		db	 02h, 04h,0AAh, 04h, 04h, 02h
		db	 04h, 22h, 9Fh, 00h,0A0h, 48h
		db	 04h, 02h, 04h, 92h, 9Fh, 00h
		db	0A1h, 20h, 04h, 02h, 04h, 02h
		db	 3Fh,0B6h, 23h,0A6h, 20h, 34h
		db	 00h, 24h, 10h, 1Ch, 02h, 3Eh
		db	 10h, 00h, 01h, 55h, 10h, 00h
		db	 10h, 00h, 10h, 00h, 15h,0FDh
		db	 10h, 00h, 12h,0AAh, 1Dh, 50h
		db	 1Dh, 50h,0EAh,0AAh, 8Ah,0AAh
		db	 04h, 02h, 04h, 02h, 04h, 00h
		db	 20h, 80h, 04h, 02h, 44h, 22h
		db	 04h, 02h, 05h, 02h, 04h, 00h
		db	 50h, 20h, 04h, 04h,0A2h, 44h
		db	 6Dh, 6Ch, 45h, 6Ch, 00h, 02h
		db	 00h, 02h, 00h, 07h, 00h, 06h
		db	 00h, 07h, 00h, 06h, 00h, 1Fh
		db	 00h, 1Fh, 00h, 78h, 00h, 70h
		db	 00h,0E0h, 00h,0C0h, 00h, 78h
		db	 00h, 70h, 00h, 1Fh, 00h, 1Bh
		db	 9Fh, 0Ah,0C0h, 00h,0C0h, 00h
		db	0F0h, 00h,0E0h, 00h, 38h, 00h
		db	 20h, 00h,0F0h, 00h,0C0h, 00h
		db	0C0h, 9Fh, 02h, 0Fh, 00h, 0Dh
		db	 00h, 0Bh, 00h, 0Ah, 00h, 0Bh
		db	 00h, 09h, 00h, 0Bh, 00h, 0Ah
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 0Ah, 00h, 0Bh, 00h, 09h
		db	 9Fh, 0Ah,0E0h, 00h,0A0h, 9Fh
		db	 03h, 90h, 00h, 90h, 00h,0F0h
		db	 00h,0C0h, 9Fh, 08h, 07h, 9Fh
		db	 01h, 0Fh
data_10		dw	19Fh			; Data table (indexed access)
		db	 05h, 9Fh, 01h, 04h, 9Fh, 01h
		db	 3Fh, 9Fh, 01h, 0Fh, 9Fh, 01h
		db	 0Ah, 9Fh, 01h, 62h, 9Fh, 00h
		db	0E0h, 9Fh, 01h, 90h, 9Fh, 01h
		db	 20h, 9Fh, 01h, 20h, 9Fh, 01h
		db	 4Ch, 9Fh, 01h, 10h, 9Fh, 05h
		db	 02h, 9Fh, 01h, 01h, 95h, 9Fh
		db	 00h, 07h,0B8h, 00h, 47h, 0Fh
		db	 30h, 00h, 8Ah, 0Fh,0B0h, 00h
		db	 45h, 0Dh, 30h, 02h, 8Bh, 06h
		db	0D0h, 00h, 25h, 01h,0A8h, 00h
		db	 13h, 00h, 54h, 00h, 2Ah, 50h
		db	 80h, 9Fh, 01h, 20h,0FCh, 9Fh
		db	 00h, 10h,0AAh, 80h, 9Fh, 00h
		db	 55h, 9Fh, 00h, 10h,0FEh, 80h
		db	 00h, 20h,0FFh, 9Fh, 00h, 80h
		db	0FCh, 00h, 02h, 00h,0A8h, 9Fh
		db	 04h, 03h, 00h, 01h, 10h, 0Ch
		db	 10h, 05h, 1Ch, 7Ch, 10h, 3Ch
		db	 0Fh,0FEh, 0Fh,0E8h, 1Dh, 24h
		db	 18h, 04h, 01h, 2Fh, 01h, 2Fh
		db	 03h,0FFh, 03h,0FDh, 07h, 00h
		db	 06h, 00h,0FCh, 00h,0F8h, 00h
		db	 38h, 00h,0B0h, 00h,0FFh, 00h
		db	0E5h, 00h, 7Ch, 00h, 58h, 00h
		db	0FFh, 80h,0EAh, 00h,0FEh, 00h
		db	0D0h, 00h,0F3h,0C0h, 41h, 80h
		db	 00h, 03h, 00h, 02h, 00h, 02h
		db	 00h, 02h, 00h, 02h, 00h, 02h
		db	 00h, 02h, 00h, 02h, 00h, 02h
		db	 00h, 02h, 00h, 02h, 00h, 02h
		db	 00h, 02h, 00h, 02h, 00h, 03h
		db	 00h, 03h,0C0h, 9Fh, 01h,0C0h
		db	 00h, 80h, 00h,0C0h, 00h, 40h
		db	 00h,0FCh, 00h, 9Ch, 00h,0FCh
		db	 00h, 48h, 00h,0C0h, 00h, 80h
		db	 00h,0FCh, 00h, 74h, 00h,0C0h
		db	 9Fh, 01h, 0Dh, 30h, 0Dh,0B0h
		db	 35h, 02h, 2Fh, 52h, 78h, 90h
		db	 45h,0B0h,0F9h, 00h,0CDh, 80h
		db	0A4h, 00h,0F4h, 00h, 40h, 84h
		db	 60h, 84h, 2Ah, 00h, 2Ah, 00h
		db	 14h, 20h, 14h, 20h, 10h, 04h
		db	 10h, 04h, 60h, 00h, 60h, 00h
		db	 4Dh, 30h, 4Dh,0B0h, 35h, 02h
		db	 2Fh, 52h, 78h, 90h, 45h,0B0h
		db	0F9h, 00h,0CDh, 80h,0A4h, 00h
		db	0F4h, 00h, 40h, 84h, 60h, 84h
		db	 2Ah, 00h, 2Ah, 00h, 14h, 20h
		db	 14h, 20h, 06h, 00h, 06h, 00h
		db	 21h,0C1h, 3Bh,0C1h, 12h, 01h
		db	 5Eh, 03h, 8Ch, 04h,0BCh, 24h
		db	 20h, 11h,0A0h,0D1h, 63h, 08h
		db	 63h, 88h, 9Fh, 03h, 10h, 00h
		db	 10h, 9Fh, 06h, 03h, 00h, 03h
		db	 9Fh, 00h, 04h, 00h, 04h, 9Fh
		db	 0Bh, 30h, 00h, 30h, 04h, 00h
		db	 04h, 80h, 46h, 04h, 66h, 04h
		db	 20h, 06h,0B0h, 0Eh, 50h, 15h
		db	0D0h, 75h, 44h, 91h, 46h,0D5h
		db	 1Ch, 56h, 3Ch, 56h, 00h, 02h
		db	 00h, 02h, 04h, 10h, 0Ch, 18h
		db	 00h, 20h, 01h, 20h, 00h, 66h
		db	 20h, 66h, 10h, 05h, 70h, 0Dh
		db	 22h, 03h,0EEh, 0Bh, 2Bh, 42h
		db	0ABh, 62h, 2Ah, 34h, 6Ah, 3Ch
		db	 00h, 02h, 00h, 03h, 00h, 1Ah
		db	 00h, 56h, 00h,0B6h, 00h,0B5h
		db	 00h,0FAh, 01h, 87h, 01h,0DFh
		db	 01h,0BFh, 01h,0D0h, 01h,0B2h
		db	 02h,0BFh, 02h,0FFh, 0Dh,0A0h
		db	 0Dh, 64h,0D4h, 00h,0BCh, 00h
		db	 7Bh, 00h,0FBh, 00h,0FEh, 80h
		db	0FEh, 80h, 2Ah, 80h,0FEh, 80h
		db	0FCh,0C0h,0FCh,0C0h, 24h,0E0h
		db	 6Ch,0E0h,0FEh,0D8h,0FEh,0D8h
		db	 00h, 74h,0AAh, 74h, 11h,0BFh
		db	 11h, 7Fh, 23h,0A0h, 2Fh, 6Ah
		db	 51h, 7Fh, 50h,0FFh, 51h, 61h
		db	 50h,0EBh, 43h, 7Fh, 46h,0FFh
		db	 45h, 00h, 4Dh, 00h, 5Ch, 00h
		db	 5Ch, 00h, 9Eh, 6Dh, 9Eh, 6Dh
		db	0FEh, 34h,0FEh, 34h, 0Eh, 54h
		db	 1Eh, 54h,0F3h, 1Ah,0F7h, 1Ah
		db	0C8h, 0Ah,0D9h, 0Ah,0FFh, 0Ah
		db	0FFh, 0Ah, 00h, 0Ah, 00h, 0Ah
		db	 00h, 65h, 00h, 65h, 52h,0F5h
		db	 52h,0F5h, 9Fh
		db	4Eh

_363UNKN	endp

seg_a		ends



		end	start
