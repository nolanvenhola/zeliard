
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_360UNKN                                 €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    5          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_14e	equ	4000h			;*
data_15e	equ	4A80h			;*
data_16e	equ	650Fh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_360UNKN	proc	far

start:
		sbb	al,cs:[bx+si]
		add	[bx+si],al
		push	es
		dec	dx
		add	[si-80h],bl
		pop	bp
		add	bx,[bp+2]
		db	 63h, 20h
data_1		db	6Fh			; Data table (indexed access)
		db	0FFh, 71h, 08h
data_2		dw	0A079h			; Data table (indexed access)
		db	 7Ch, 01h, 85h,0C0h, 8Dh, 0Fh
		db	 91h, 0Ch, 96h, 30h, 9Bh, 04h
		db	 9Dh, 40h,0A5h,0F0h,0A7h,0EAh
		db	0ADh,0AAh,0B1h, 10h,0B4h, 0Ah
		db	0B7h,0FAh
data_3		db	0B9h
		db	 06h,0FFh,0FFh, 4Ah, 37h, 03h
		db	 4Ah, 01h, 86h, 00h, 49h, 4Ah
		db	 16h, 80h, 00h, 40h, 4Ah, 01h
		db	0F0h, 4Ah, 10h, 0Ah, 4Ah, 01h
		db	2Bh
data_4		dw	14Ah, 0BFh		; Data table (indexed access)
		db	 02h, 2Ah,0FFh, 00h, 2Bh, 00h
		db	 02h, 00h, 04h, 4Ah, 0Fh, 02h
		db	 00h, 31h, 00h, 03h, 00h, 0Ch
		db	 00h, 0Ch, 00h,0F3h, 80h, 4Ah
		db	 01h, 40h, 4Ah, 01h, 20h, 00h
		db	 10h, 00h,0E0h, 00h, 10h, 00h
		db	 80h, 00h, 40h, 4Ah, 01h,0C0h
		db	 4Ah, 01h,0C0h, 4Ah, 01h,0F0h
		db	 4Ah, 07h, 80h, 4Ah, 01h, 80h
		db	 4Ah, 01h,0E8h, 00h, 80h, 00h
		db	0FEh, 00h, 80h, 00h,0FFh, 80h
		db	0E0h, 00h,0FFh,0EAh,0FAh, 4Ah
		db	 00h, 0Eh, 00h, 01h, 00h, 20h
		db	 00h, 1Ch, 00h,0E0h, 00h, 10h
		db	 00h, 20h, 00h, 10h, 00h, 80h
		db	 00h, 4Ch, 00h,0E2h, 00h, 11h
		db	 03h, 80h, 00h, 7Fh, 4Ah, 00h
		db	 0Fh,0FFh, 80h, 4Ah, 01h, 88h
		db	 00h, 44h, 00h, 20h, 00h, 10h
data_5		db	0			; Data table (indexed access)
		db	0E0h, 00h, 10h, 4Ah, 01h,0FCh
		db	 00h, 80h, 00h, 4Ch, 4Ah, 01h
		db	0F0h, 4Ah, 01h
data_6		dw	4AFFh
		db	 18h, 02h, 00h, 01h, 02h, 00h
		db	 01h, 4Ah, 00h,0BFh, 00h, 02h
		db	 00h, 2Fh, 4Ah, 01h, 0Ah, 4Ah
		db	 19h, 08h, 00h, 34h, 00h, 60h
		db	 00h, 90h, 01h,0C2h, 02h, 31h
		db	 03h, 08h, 0Ch,0C4h, 00h, 38h
		db	 0Fh,0C7h
data_7		dw	4Ah
		db	 03h,0FFh, 08h, 00h, 07h,0FFh
		db	 4Ah, 02h,0C8h, 00h, 04h, 00h
		db	 20h, 00h, 13h, 00h,0E0h, 00h
		db	 1Fh, 00h, 80h, 00h, 7Fh, 4Ah
		db	 01h,0CFh,0C0h, 4Ah, 00h,0FFh
		db	 4Ah, 01h,0FFh, 4Ah, 1Eh,0FFh
		db	 4Ah, 1Ch,0FFh, 4Ah, 00h, 3Fh
		db	 0Fh,0C0h, 03h,0F0h, 3Ch, 8Dh
		db	 00h, 00h, 70h,0FFh, 4Ah, 00h
		db	 6Fh, 00h, 4Ah, 00h, 6Fh, 00h
		db	 4Ah, 00h, 6Fh, 00h, 4Ah, 00h
		db	 7Fh,0FFh, 4Ah, 00h, 1Fh,0FFh
		db	 0Ch, 00h,0F3h,0F0h, 4Ah, 00h
		db	0FFh,0FCh
data_8		dw	4Ah			; Data table (indexed access)
		db	0FFh,0FCh, 4Ah, 00h,0FFh,0FAh
		db	 4Ah, 00h,0FFh,0FAh, 4Ah, 00h
		db	0FFh,0EAh, 4Ah, 00h,0FEh,0A8h
		db	 4Ah, 00h,0EAh,0A0h, 4Ah, 1Dh
		db	 0Fh, 00h, 0Fh, 00h,0F0h, 00h
		db	0FCh, 0Fh, 5Dh, 00h,0C0h, 3Ch
		db	 3Fh, 4Ah, 00h, 7Fh,0FFh, 4Ah
		db	 00h, 6Fh, 00h, 4Ah, 00h, 6Fh
		db	 00h, 4Ah, 00h, 3Fh,0FFh, 4Ah
		db	 00h, 0Fh,0FFh,0C0h, 00h, 3Fh
		db	0F0h, 4Ah, 00h,0FFh,0FCh, 4Ah
		db	 00h,0FFh,0FCh, 4Ah, 00h,0FFh
		db	0FAh, 4Ah, 00h,0FFh,0FAh
		db	4Ah
data_9		dw	0FF00h
		db	0EAh, 4Ah, 00h,0FEh,0A8h, 4Ah
		db	 00h,0AAh,0A0h, 4Ah, 19h, 0Fh
		db	 00h, 03h, 00h,0FCh, 4Ah, 18h
		db	0F0h, 00h,0C0h, 00h, 3Fh, 4Ah
		db	 00h, 3Ch, 03h,0C3h, 00h,0F0h
		db	 8Dh, 00h, 03h,0C0h, 1Ch, 3Fh
		db	 4Ah, 00h, 3Fh,0FFh, 4Ah, 00h
		db	 3Fh,0FFh, 4Ah, 00h, 3Fh,0FFh
		db	 4Ah, 00h, 0Fh,0FFh, 4Ah, 00h
		db	 03h,0FFh, 4Ah, 00h,0FFh,0C0h
		db	 4Ah, 00h,0FFh,0F0h, 4Ah, 00h
		db	0FFh,0F0h, 4Ah, 00h,0FFh,0E8h
		db	 4Ah, 00h,0FFh,0E8h, 4Ah, 00h
		db	0FFh,0A8h, 4Ah, 00h,0FAh,0A0h
		db	 4Ah, 00h,0AAh, 80h, 4Ah, 1Ch
		db	0F0h, 4Ah, 00h,0F0h, 8Dh, 00h
		db	 03h,0C0h, 3Ch, 3Fh, 0Fh, 00h
		db	 70h,0FFh, 4Ah, 00h, 6Fh, 00h
		db	 4Ah, 00h, 6Fh, 00h, 4Ah, 00h
data_10		db	6Fh			; Data table (indexed access)
		db	 00h, 4Ah, 00h, 3Fh,0FFh, 4Ah
		db	 00h, 0Fh,0FFh, 4Ah, 00h,0FFh
		db	 4Ah, 01h,0FFh,0F0h, 4Ah, 00h
		db	0FFh,0FCh, 4Ah, 00h,0FFh,0FCh
		db	 4Ah, 00h,0FFh,0FAh, 4Ah, 00h
		db	0FFh,0EAh, 4Ah, 00h,0FAh,0A8h
		db	 4Ah, 00h,0AAh,0A0h, 4Ah, 01h
		db	 02h, 00h, 02h, 01h, 05h, 4Ah
		db	 00h, 01h, 12h, 00h, 03h, 01h
		db	 04h, 00h, 04h, 02h, 13h
data_11		dw	400h			; Data table (indexed access)
		db	 03h, 0Ah, 4Ah, 00h, 03h, 1Bh
		db	 00h, 04h, 03h, 23h, 4Ah, 08h
		db	 82h, 4Ah, 01h,0A2h, 4Ah, 01h
		db	 50h, 4Ah, 01h,0D2h, 4Ah, 01h
		db	0DAh, 4Ah, 01h,0F3h, 4Ah, 00h
		db	 1Ch, 03h, 83h, 00h, 10h, 8Dh
		db	 00h, 02h,0C0h, 0Ch, 1Fh, 4Ah
		db	 00h, 3Fh,0BFh, 4Ah, 00h, 3Eh
		db	0FFh, 4Ah, 00h, 3Fh,0FFh, 4Ah
		db	 00h, 0Fh, 7Fh, 4Ah, 00h, 03h
		db	0FAh, 4Ah, 00h,0DBh, 40h, 4Ah
		db	 00h,0ECh,0D0h, 4Ah, 00h,0F5h
		db	 70h, 4Ah, 00h,0F5h,0C8h, 4Ah
		db	 00h,0F3h,0D0h, 4Ah, 00h,0E3h
		db	 98h, 4Ah, 00h, 82h,0A0h, 4Ah
		db	 00h, 8Ah, 80h, 03h, 71h, 00h
		db	0A2h, 10h, 01h, 20h, 76h, 40h
		db	 04h, 8Ah,0B2h, 00h, 06h, 17h
		db	 99h, 00h, 02h, 82h,0CDh, 00h
		db	 06h, 00h, 68h, 00h, 02h, 20h
		db	 25h, 00h, 03h, 00h, 04h, 64h
		db	 00h, 8Ah,0A0h, 80h, 10h, 74h
		db	 08h, 4Ah, 00h,0D0h,0E2h, 4Ah
		db	 00h,0C3h, 19h, 4Ah, 00h, 64h
		db	0A0h, 4Ah, 00h,0CDh, 01h, 4Ah
		db	 00h,0C8h, 4Ah, 01h, 80h, 04h
		db	 00h, 06h, 00h, 11h, 00h, 06h
		db	 00h, 11h, 00h, 08h, 00h, 37h
		db	 4Ah, 01h, 7Fh, 00h, 08h, 01h
		db	0F7h, 00h, 20h, 03h,0DFh, 00h
		db	0C0h, 07h, 3Fh, 4Ah, 00h, 06h
		db	0AEh, 4Ah, 00h,0C0h, 4Ah, 01h
		db	0C0h, 4Ah, 01h,0D0h, 4Ah, 01h
		db	0AAh, 4Ah, 01h,0D5h, 4Ah, 01h
		db	0B5h, 4Ah, 01h,0D3h, 40h, 4Ah
		db	 00h,0A9h, 40h, 03h, 08h, 00h
		db	0A2h, 10h, 00h, 2Ch, 77h, 40h
		db	 03h,0B0h, 14h, 00h, 01h, 67h
		db	 8Eh, 4Ah, 00h,0CEh, 53h, 00h
		db	 01h, 28h, 1Ah, 4Ah, 00h, 28h
		db	 41h, 4Ah, 00h, 05h, 02h, 64h
		db	 00h, 8Ah, 00h, 80h, 00h, 75h
		db	0D0h
		db	4Ah
data_12		db	0
		db	0D4h, 2Eh, 4Ah, 00h,0D9h,0E7h
		db	 4Ah, 00h,0A3h,0D1h, 4Ah, 00h
		db	 07h, 21h, 4Ah, 00h, 02h, 90h
		db	 4Ah, 00h, 8Ah, 04h, 4Ah, 05h
		db	 01h, 4Ah, 05h, 01h, 4Ah, 0Eh
		db	0FFh, 80h,0E0h, 00h,0FEh, 00h
		db	 80h, 00h,0E8h, 00h, 80h, 00h
		db	 80h, 4Ah, 01h, 80h, 4Ah, 01h
		db	 80h, 4Ah, 0Ch, 0Fh, 00h, 0Fh
		db	 00h,0F0h, 00h,0FFh, 03h, 00h
		db	 0Fh,0C3h, 00h, 3Ch, 0Fh, 3Ch
		db	 20h,0C3h, 67h,0FCh, 00h, 03h
		db	0E7h,0F3h, 00h, 0Ch,0C7h,0CFh
		db	 00h, 30h,0C0h, 00h, 30h, 00h
		db	0FFh, 4Ah, 01h,0FFh,0C0h, 4Ah
		db	 00h,0FFh, 30h, 00h,0C0h, 3Fh
		db	0C8h,0C0h, 30h,0CFh, 96h, 00h
		db	0C8h,0CCh,0C0h, 33h, 22h,0F3h
		db	 00h, 0Ch,0F8h, 27h,0CFh, 80h
		db	 30h,0C7h,0FFh, 10h, 00h, 07h
		db	0FFh, 70h, 00h, 0Fh,0FFh, 20h
		db	 00h, 0Ch,0FFh, 03h, 00h, 03h
		db	0C0h, 00h, 3Eh, 00h,0A8h, 00h
		db	 03h, 00h, 0Ah, 4Ah, 00h,0F3h
		db	0C0h, 0Ch, 20h,0FCh, 80h, 03h
		db	 2Ah,0FFh, 20h, 00h, 88h,0FCh
		db	 00h, 02h,0A8h,0F0h, 00h, 0Ah
		db	0A0h, 82h, 80h, 28h, 00h, 2Ah
		db	 00h, 80h, 00h,0A0h, 4Ah, 02h
		db	 0Fh, 4Ah, 01h,0FFh, 4Ah, 00h
		db	 03h,0F0h, 00h, 8Dh, 00h,0CFh
		db	 00h, 30h, 3Ch,0FFh, 02h, 00h
		db	 30h, 3Fh, 08h, 80h,0C7h, 1Fh
		db	 63h, 00h,0CEh, 0Fh, 00h, 20h
		db	0F0h, 4Ah, 01h, 33h, 00h,0CCh
		db	 00h,0FFh,0C0h, 4Ah, 00h,0CCh
		db	0F0h, 33h, 00h, 33h, 30h,0CCh
		db	0C8h,0F3h, 30h, 0Ch,0C8h,0CFh
		db	 08h, 30h,0F2h,0CFh,0C0h, 30h
		db	 2Ah,0CCh, 0Fh, 00h, 60h,0CEh
		db	 0Fh, 20h, 60h, 00h,0DCh, 29h
		db	 23h, 30h, 3Fh, 0Bh, 80h, 0Ch
		db	0FFh, 02h, 00h, 03h,0F2h, 00h
		db	 0Ch, 00h,0A8h, 00h, 02h, 00h
		db	 0Ah, 4Ah, 00h, 3Fh,0E0h,0C0h
		db	 0Ah,0FFh,0A8h, 00h, 02h,0FFh
		db	0A0h, 00h, 08h, 0Eh, 80h,0F0h
		db	 28h,0F2h, 00h, 0Ch,0A0h,0A8h
		db	 80h, 02h, 00h,0A0h, 00h, 0Ah
		db	 4Ah, 01h,0A0h, 4Ah, 00h, 0Fh
		db	 4Ah, 01h,0FFh, 4Ah, 00h, 03h
		db	0FFh, 4Ah, 00h, 0Fh,0FFh, 4Ah
		db	 00h, 3Fh,0F0h, 00h, 0Ah, 33h
		db	0C0h, 0Ch, 2Ah,0CFh, 0Fh, 30h
		db	0A0h,0CFh, 1Fh, 30h,0A0h,0F0h
		db	 4Ah, 01h,0FFh, 4Ah, 01h,0FFh
		db	 4Ah, 00h,0C0h,0FCh,0F0h, 03h
		db	 00h, 0Fh,0F8h,0A0h, 00h, 03h
		db	0F8h,0A8h, 00h,0A0h,0FAh, 0Ah
		db	 00h, 80h,0EAh, 0Ah, 00h, 33h
		db	 0Eh,0CCh,0A0h,0FFh, 4Ah, 00h
		db	0A8h, 3Fh,0C0h, 00h, 2Ah, 3Fh
		db	0F0h, 00h, 0Ah, 0Fh,0FFh, 4Ah
		db	 00h, 03h,0FEh, 4Ah, 01h,0AAh
		db	 4Ah, 01h, 0Ah, 4Ah, 01h,0EAh
		db	 0Eh, 00h, 30h,0AAh, 0Eh, 00h
		db	 03h, 88h,0F8h, 20h, 0Eh, 88h
		db	0A0h, 20h,0F2h,0A0h, 08h, 00h
		db	 8Ah, 80h, 20h, 00h,0A2h, 00h
		db	 08h, 00h,0A0h, 4Ah, 02h, 0Fh
		db	 4Ah, 01h,0FFh, 4Ah, 00h, 03h
		db	 3Fh, 00h,0C0h, 00h,0FFh, 0Fh
		db	 00h, 3Fh,0FFh, 4Ah, 00h, 3Fh
		db	0FCh, 00h, 03h,0FFh,0F3h, 00h
		db	 0Ch, 3Fh,0F3h,0C0h, 0Ch,0F0h
		db	 4Ah, 01h,0FFh, 4Ah, 01h,0FFh
		db	0C0h, 4Ah, 00h,0FFh,0F0h, 4Ah
		db	 00h,0FFh, 38h, 00h, 80h,0FCh
		db	 08h, 02h,0A0h,0F3h,0C2h, 08h
		db	 28h,0F3h, 42h, 71h, 00h,0CFh
		db	 0Ch, 30h,0F3h,0F0h,0FFh, 0Fh
		db	 00h, 2Fh,0FFh, 10h, 00h, 3Fh
		db	0FFh, 4Ah, 00h, 0Fh,0CFh, 00h
		db	 30h, 00h, 3Eh, 03h,0C0h, 00h
		db	0AAh, 4Ah, 01h, 0Ah, 4Ah, 00h
		db	0F2h, 02h, 08h, 18h,0F0h, 02h
		db	 08h, 38h,0F0h, 00h
		db	0Ah

locloop_2:
;*		cmp	ah,bh
		db	 38h,0FCh		;  Fixup - byte match
		or	[bp+si],al
		loopnz	locloop_2		; Loop if zf=0, cx>0

		and	[bx+si],al
		sub	byte ptr ss:data_15e[bp+si],0
		stosb				; Store al to es:[di]
		dec	dx
		add	data_11[bx+si],sp
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		dec	dx
;*		add	di,di
		db	 01h,0FFh		;  Fixup - byte match
		dec	dx
		add	[bp+di],al
;*		dec	word ptr [bp+si+0]
		db	0FFh, 4Ah, 00h		;  Fixup - byte match
		db	 0Fh,0FFh, 4Ah, 00h, 8Dh, 00h
		db	 30h,0F0h, 33h,0F0h, 0Ch, 8Dh
		db	 00h,0FFh,0F0h, 00h, 0Ch,0FFh
		db	0F3h, 00h,0F0h, 4Ah, 01h,0FFh
		db	 4Ah, 01h,0FFh,0C0h, 4Ah, 00h
		db	0CFh,0F0h, 30h, 00h, 3Fh, 85h
		db	 00h, 08h,0FCh,0CCh, 03h, 12h
		db	0FCh, 86h, 03h, 21h,0F3h, 82h
		db	 0Ch, 10h, 03h, 0Fh,0FCh,0F0h
		db	 0Ch,0F0h,0F3h, 0Fh, 03h,0FFh
		db	 3Ch, 00h, 0Ch, 3Fh, 33h,0C0h
		db	 03h,0CFh, 0Ch, 30h, 03h,0F0h
		db	 00h, 0Fh, 00h,0AAh, 4Ah, 01h
		db	 0Ah, 4Ah, 00h,0F3h, 80h, 0Ch
		db	 25h, 0Ch, 80h,0F3h, 0Bh,0FFh
		db	 80h, 00h, 0Eh,0FEh, 80h, 00h
		db	 08h,0CAh,0A0h, 30h, 00h, 2Ah
		db	 80h,0C0h, 00h,0AAh, 4Ah, 01h
		db	0A0h, 4Ah, 0Eh, 5Fh, 4Ah, 00h
		db	 02h,0F9h, 00h, 06h, 15h,0CEh
		db	 00h, 31h, 30h,0DCh, 40h, 23h
		db	 78h,0F3h, 80h, 0Ch, 4Ah, 0Ah
		db	0FAh, 4Ah, 01h,0FFh,0D0h, 4Ah
		db	 00h, 7Dh, 68h, 82h, 90h,0BFh
		db	 94h, 40h, 68h,0CEh,0A2h, 31h
		db	 08h, 70h,0C7h, 8Ch, 38h, 30h
		db	0DFh, 48h, 20h, 11h,0FFh, 4Ah
		db	 00h, 0Bh, 7Fh, 00h, 80h, 00h
		db	 50h, 00h, 05h, 4Ah, 0Ah,0F2h
		db	 80h, 0Ch, 51h,0FCh, 00h, 03h
		db	 2Ah,0F4h, 00h, 01h, 44h,0A0h
		db	 00h, 5Ah,0A0h, 11h, 00h, 44h
		db	 4Ah, 18h, 5Fh, 4Ah, 00h, 0Bh
		db	0F7h, 00h, 08h, 1Fh,0FFh, 4Ah
		db	 00h, 3Dh, 5Fh, 42h,0A0h, 07h
		db	0F0h,0F8h, 0Fh, 4Ah, 0Ah,0FAh
		db	 4Ah, 01h,0FFh,0D0h, 4Ah, 00h
		db	0EBh,0E8h, 14h, 00h, 3Fh, 8Ch
		db	0C0h, 02h,0F9h, 1Eh, 06h, 01h
		db	 13h, 7Fh,0ECh, 80h, 5Bh,0E8h
		db	 24h, 17h, 1Fh, 7Fh, 00h, 80h
		db	 0Bh,0C8h, 00h, 37h, 00h,0AAh
		db	 4Ah, 0Ch,0AFh, 02h, 50h, 15h
		db	0F9h, 00h, 06h, 0Eh,0E7h, 88h
		db	 18h, 00h, 3Dh, 50h,0C0h, 00h
		db	0AAh, 4Ah, 0Eh, 0Fh, 4Ah, 01h
		db	 0Eh, 4Ah, 00h, 03h, 87h, 4Ah
		db	 00h, 0Fh,0E3h, 4Ah, 00h, 3Dh
		db	0F3h, 02h, 00h, 03h,0F9h, 04h
		db	 4Ah, 00h, 7Ah, 4Ah, 00h, 0Bh
		db	0A4h, 20h, 00h,0C0h, 4Ah, 01h
		db	0E3h, 4Ah, 01h, 67h, 4Ah, 00h
		db	0C0h, 6Ch,0F0h, 03h, 00h,0DBh
		db	0F8h, 04h, 00h,0E6h,0F8h, 01h
		db	 00h,0AEh,0FAh, 01h, 00h,0C9h
		db	0EAh, 04h, 00h, 33h,0F8h,0CCh
		db	 00h,0FFh,0E5h, 4Ah, 00h, 3Fh
		db	 03h, 00h, 04h, 30h, 1Fh, 4Ah
		db	 01h,0FEh, 00h, 01h, 03h,0FEh
		db	 4Ah, 01h,0AAh, 4Ah, 01h, 0Ah
		db	 4Ah, 00h,0A0h,0C2h, 4Ah, 00h
		db	0F4h, 4Ah, 01h,0DEh, 80h, 4Ah
		db	 00h,0CEh, 88h, 00h, 20h, 02h
		db	0A0h, 88h, 00h, 82h, 80h, 4Ah
		db	 00h, 02h, 4Ah, 06h, 03h,0E6h
		db	 20h, 00h,0C6h, 56h, 08h, 03h
		db	0E3h, 28h, 0Ch, 0Fh,0F3h, 20h
		db	 08h, 17h,0D2h, 80h, 00h, 1Eh
		db	 21h, 00h, 0Dh, 3Ch, 06h, 00h
		db	 97h, 7Eh, 84h, 00h, 0Fh,0B0h
		db	 4Ah, 00h, 4Bh,0E0h, 00h, 09h
		db	 36h,0C1h,0C0h, 18h, 2Ah, 87h
		db	0F0h, 30h, 00h, 07h,0DCh, 68h
		db	 00h, 6Eh,0A0h,0E0h, 04h, 10h
		db	 00h,0FFh, 70h, 00h, 04h,0FEh
		db	0A0h, 43h, 00h, 08h, 5Fh, 00h
		db	 04h, 4Eh,0AFh, 00h, 40h, 17h
		db	 37h, 01h,0F0h, 1Ah, 03h, 07h
		db	 50h, 40h, 00h, 01h, 40h, 38h
		db	 02h, 00h, 40h, 60h, 4Ah, 01h
		db	0C2h, 04h, 17h, 17h,0F8h, 00h
		db	 43h, 7Dh,0F8h, 4Ah, 00h,0AAh
		db	0F6h, 4Ah, 00h, 0Ch, 4Eh, 40h
		db	 25h, 00h, 90h, 24h, 7Eh,0C0h
		db	 00h, 0Ah, 75h, 4Ah, 00h, 18h
		db	 50h, 4Ah, 00h, 02h, 4Ah, 00h
		db	 80h, 0Bh, 4Ah, 00h, 28h, 07h
		db	 5Eh, 00h, 00h, 8Bh, 00h, 02h
		db	 07h,0C7h, 4Ah, 00h, 06h,0FFh
		db	 00h, 06h, 01h,0F7h, 4Ah, 00h
		db	 2Ah,0DFh, 4Ah, 00h,0BFh,0FFh
		db	 4Ah, 00h,0D0h, 03h, 4Ah, 00h
		db	0E0h, 14h, 04h, 40h,0D1h,0A8h
		db	 4Ah, 00h,0F6h,0E0h, 4Ah, 00h
		db	0FFh,0A0h, 80h, 00h,0FFh, 4Ah
		db	 01h,0FFh, 54h, 04h, 00h, 6Fh
		db	 00h, 4Ah, 00h, 7Fh,0FFh, 4Ah
		db	 00h, 15h,0FFh, 4Ah, 00h, 01h
		db	0FFh, 00h, 01h, 03h,0EFh, 4Ah
		db	 00h, 06h, 17h, 4Ah, 00h, 18h
		db	 0Bh, 4Ah, 00h, 20h, 07h, 00h
		db	 08h, 80h, 03h, 4Ah, 00h, 6Fh
		db	 00h, 4Ah, 00h,0FFh, 54h, 4Ah
		db	 00h,0BFh, 80h, 4Ah, 00h,0EFh
		db	 5Ch, 00h, 00h,0EBh, 60h, 4Ah
		db	 00h,0D0h, 88h, 4Ah, 00h,0E0h
		db	 26h, 4Ah, 00h,0C0h, 01h
		db	0Ch, '0', 0Ch, '0', 8, ' ', 8, ' '
		db	 02h, 08h, 02h, 08h, 00h,0A2h
		db	 00h, 59h, 02h, 00h, 01h,0FBh
		db	 4Ah, 00h, 03h,0FEh, 4Ah, 01h
		db	0FAh, 00h, 03h, 00h
		db	'+', 0Ch, '0', 0Ch, '0', 8, ' ', 8
		db	'c'
		db	 00h, 80h, 20h, 80h, 20h, 00h
		db	 9Eh, 4Ah, 01h,0BAh, 80h, 4Ah
		db	 00h,0EAh, 80h, 4Ah, 00h,0EAh
		db	 00h, 80h, 00h,0A8h, 4Ah, 00h
		db	 03h, 00h, 0Bh, 00h, 02h, 00h
		db	 02h, 4Ah, 16h, 80h, 00h,0A0h
		db	 00h, 80h, 00h, 80h, 4Ah, 17h
		db	 03h, 0Ch, 03h, 0Ch, 02h, 08h
		db	 02h, 08h, 02h, 08h, 02h, 08h
		db	 02h, 08h, 02h, 08h, 00h,0A2h
		db	 00h, 59h, 02h, 00h, 01h,0FBh
		db	 4Ah, 00h, 03h,0FEh, 4Ah, 01h
		db	0FAh, 30h,0C0h, 30h,0C0h, 20h
		db	 80h, 20h, 80h, 20h, 80h, 20h
		db	 80h, 20h, 80h, 20h, 80h, 20h
		db	 00h, 9Eh, 4Ah, 01h,0BAh, 80h
		db	 4Ah, 00h,0EAh, 80h, 4Ah, 00h
		db	0EAh, 4Ah, 00h, 03h, 00h, 2Bh
		db	 00h, 03h, 00h, 0Bh, 00h, 02h
		db	 00h, 02h, 4Ah, 12h, 80h, 00h
		db	0A8h, 00h, 80h, 00h,0A0h, 00h
		db	 80h, 00h, 80h, 4Ah, 14h,0C3h
		db	 00h,0C3h, 02h, 08h, 02h, 08h
		db	 02h, 08h, 02h, 08h, 00h,0A2h
		db	 00h, 59h, 02h, 00h, 01h,0FBh
		db	 4Ah, 00h, 03h,0FEh, 4Ah, 01h
		db	0FAh, 00h, 03h, 00h, 2Bh, 83h
		db	 00h, 83h, 00h, 20h, 80h, 20h
		db	 80h, 20h, 80h, 20h, 80h, 20h
		db	 00h, 9Eh, 4Ah, 01h,0BAh, 80h
		db	 4Ah, 00h,0EAh, 80h, 4Ah, 00h
		db	0EAh, 00h, 80h, 00h,0A8h, 4Ah
		db	 00h, 03h, 00h, 03h
		db	'0', 8, '0', 8, 0Ah, 8, 0Ah, 8
		db	 00h,0A2h, 00h, 59h, 02h, 00h
		db	 01h,0FBh, 4Ah, 00h, 03h,0FEh
		db	 4Ah, 01h,0FAh, 00h, 03h, 00h
		db	 2Bh, 80h, 00h, 80h, 00h, 20h
		db	 0Ch, 20h, 0Ch, 20h,0A0h, 20h
		db	0A0h, 20h, 00h, 9Eh, 4Ah, 01h
		db	0BAh, 80h, 4Ah, 00h,0EAh, 80h
		db	 4Ah, 00h,0EAh, 00h, 80h, 00h
		db	0A8h, 00h
		db	0Ch, '0', 0Ch, '0', 8, ' ', 8, ' '
		db	 02h, 08h, 02h, 08h, 00h,0A2h
		db	 00h, 59h, 02h, 00h, 01h,0FBh
		db	 4Ah, 00h, 03h,0FEh, 00h, 5Dh
		db	 00h,0FBh, 00h, 08h, 00h,0E8h
		db	0Ch, '0', 0Ch, '0', 8, ' ', 8, 'c'
		db	 00h, 80h, 20h, 80h, 20h, 00h
		db	 9Eh, 4Ah, 01h,0BAh, 80h, 4Ah
		db	 00h,0EAh, 5Ch, 00h, 00h,0AAh
		db	 80h, 30h, 00h, 3Ah, 4Ah, 00h
		db	 08h, 00h, 08h, 4Ah, 1Ah, 30h
		db	 00h, 30h, 4Ah, 20h,0C3h, 00h
		db	0C3h, 03h, 0Ch, 03h, 0Ch, 02h
		db	 08h, 02h, 08h, 02h, 08h, 02h
		db	 08h, 00h,0A2h, 00h, 59h, 02h
		db	 00h, 01h,0FBh, 4Ah, 00h, 03h
		db	0FEh, 4Ah, 02h, 83h, 00h, 83h
		db	 00h, 20h, 80h, 20h, 80h, 20h
		db	 80h, 20h, 80h, 20h, 80h, 20h
		db	 80h, 20h, 00h, 9Eh, 4Ah, 01h
		db	0BAh, 80h, 4Ah, 00h,0EAh, 80h
		db	 00h, 5Dh, 00h,0FBh, 00h, 38h
		db	 00h,0FAh, 00h,0E0h, 00h,0EAh
		db	 03h, 80h, 03h,0A8h, 02h, 00h
		db	 02h, 80h, 4Ah, 0Ah, 80h, 00h
		db	0AAh, 80h, 38h, 00h,0BAh, 00h
		db	 0Eh, 00h,0AEh, 00h, 03h, 80h
		db	 0Bh, 80h, 00h, 80h, 02h, 80h
		db	 4Ah, 1Fh,0C3h, 00h,0C3h, 03h
		db	 0Ch, 03h, 0Ch, 02h, 08h, 02h
		db	 08h, 4Ah, 12h, 83h, 00h, 83h
		db	 00h, 20h, 80h, 20h, 80h, 20h
		db	 80h, 20h, 80h, 02h, 08h, 02h
		db	 08h, 00h,0A2h, 00h, 59h, 02h
		db	 00h, 01h,0FBh, 4Ah, 00h, 03h
		db	0FEh, 00h, 5Dh, 00h,0FBh, 00h
		db	 38h, 00h,0FAh, 03h,0E0h, 03h
		db	0EAh, 0Fh, 00h, 0Fh,0A8h, 20h
		db	 80h, 20h, 80h, 20h, 00h, 9Eh
		db	 4Ah, 01h,0BAh, 80h, 4Ah, 00h
		db	0EAh, 5Ch, 00h, 00h,0AAh, 80h
		db	 38h, 00h,0BAh, 00h, 0Eh, 80h
		db	0AEh, 80h, 03h,0A0h, 0Bh,0A0h
		db	 00h, 03h, 00h, 02h, 00h, 0Fh
		db	 00h, 02h, 5Dh, 00h, 02h, 00h
		db	 30h, 3Ch, 20h, 08h, 00h,0CCh
		db	 4Ah, 00h, 03h, 0Ch, 4Ah, 01h
		db	 03h, 00h, 02h,0F0h, 3Fh, 80h
		db	 28h, 4Ah, 02h,0C0h, 00h, 80h
		db	 00h, 0Ch, 00h, 08h, 4Ah, 03h
		db	0F0h, 30h,0A0h, 20h, 0Ch, 00h
		db	 08h, 4Ah, 03h,0C0h,0CFh, 80h
		db	 4Ah, 00h,0E0h, 00h,0E0h
		db	'8 8 ', 0Ah, 8, 0Ah, 8
		db	 00h,0A2h, 00h, 59h, 02h, 00h
		db	 01h,0FBh, 4Ah, 00h, 03h,0FEh
		db	 33h,0FFh, 33h, 6Fh, 00h,0F0h
		db	0FFh,0FAh, 0Eh, 00h, 0Eh, 00h
		db	 08h, 1Ch, 08h, 1Ch, 20h,0A0h
		db	 20h,0A0h, 20h, 00h, 9Eh, 4Ah
		db	 01h,0BAh, 80h, 4Ah, 00h,0EAh
		db	 80h,0AAh, 88h,0AAh, 88h, 0Ah
		db	0ADh, 01h, 00h,0C0h, 00h,0C0h
		db	 00h, 20h, 00h, 20h,0C0h, 10h
		db	0C0h, 10h, 18h, 00h, 18h, 04h
		db	 4Ah, 01h, 73h, 4Ah, 00h,0DAh
		db	0FFh, 4Ah, 00h, 1Bh,0FFh, 4Ah
		db	 00h, 2Fh,0FFh, 10h, 00h, 10h
		db	 00h, 30h, 02h, 30h, 02h, 20h
		db	 10h, 20h, 10h, 00h, 9Dh, 01h
		db	 4Ah, 00h, 69h, 08h, 4Ah, 00h
		db	0FEh,0F2h, 4Ah, 00h,0FFh,0B0h
		db	 4Ah, 00h,0FFh,0D0h, 4Ah, 00h
		db	 67h,0FDh, 00h, 08h, 1Bh,0FEh
		db	 00h, 38h, 0Eh,0BDh, 00h, 20h
		db	 28h, 2Ch, 02h,0C0h, 42h,0C4h
		db	 01h, 80h, 01h, 80h, 4Ah, 08h
		db	0FEh,0B8h, 4Ah, 00h,0D3h, 80h
		db	 08h, 00h,0ACh,0C0h, 04h, 00h
		db	 4Dh, 30h, 06h, 00h, 26h, 00h
		db	 04h, 00h, 9Bh, 00h, 4Ah, 06h
		db	 0Ch,0CFh, 4Ah, 01h, 03h, 00h
		db	 02h, 0Ch,0C0h, 4Ah, 01h, 0Fh
		db	 00h, 02h, 33h, 30h, 20h, 4Ah
		db	 04h,0C3h, 00h, 82h, 00h, 03h
		db	 4Ah, 00h,0CCh, 00h, 80h, 00h
		db	 03h,0C0h, 00h, 80h,0CCh, 4Ah
		db	 05h, 96h, 00h, 00h, 20h, 03h
		db	 00h, 02h, 00h,0F0h, 00h, 20h
		db	 4Ah, 07h, 03h, 00h, 02h, 4Ah
		db	 03h,0C0h, 00h, 80h, 4Ah, 00h
		db	 03h, 00h, 02h, 4Ah, 03h, 3Ch
		db	 00h, 20h, 96h, 00h, 20h, 4Ah
		db	 03h, 03h, 0Ch, 02h, 08h, 4Ah
		db	 06h, 30h, 00h, 20h, 00h, 5Dh
		db	 00h, 5Eh, 00h,0C0h, 00h, 80h
		db	 00h, 03h, 4Ah, 03h, 90h, 02h
		db	 4Ah, 00h, 41h, 4Ah, 01h, 9Ch
		db	 24h, 4Ah, 00h, 48h, 02h, 4Ah
		db	 00h, 04h, 4Ah, 01h, 20h, 4Ah
		db	 01h, 44h, 4Ah, 01h, 20h, 4Ah
		db	 01h, 01h, 09h, 4Ah, 00h, 08h
		db	 16h, 4Ah, 00h, 80h, 44h, 4Ah
		db	 00h, 02h, 68h, 4Ah, 01h, 42h
		db	 4Ah, 05h, 80h, 4Ah, 08h, 01h
		db	 4Ah, 05h, 42h, 4Ah, 01h, 16h
		db	 40h, 4Ah, 00h, 22h, 01h, 4Ah
		db	 00h, 68h, 10h, 4Ah, 00h, 90h
		db	 80h, 4Ah, 01h, 04h, 4Ah, 01h
		db	 22h, 4Ah, 01h, 04h, 4Ah, 01h
		db	 20h, 4Ah, 00h, 40h, 12h, 4Ah
		db	 00h, 24h, 39h, 4Ah, 01h, 82h
		db	 4Ah, 00h, 40h, 09h, 4Ah, 0Bh
		db	 1Fh, 4Ah, 01h,0FDh, 4Ah, 00h
		db	 03h,0FEh, 4Ah, 00h, 06h,0F8h
		db	 4Ah, 00h, 0Dh,0E8h, 00h, 05h
		db	 4Ah, 0Ah,0D0h, 4Ah, 01h, 52h
		db	 4Ah, 01h, 8Ah, 40h, 4Ah, 01h
		db	 20h, 4Ah, 01h, 10h,0A0h, 00h
		db	 10h, 80h, 1Eh,0F0h, 00h, 02h
		db	 00h,0FFh, 4Ah, 01h, 0Ah, 4Ah
		db	 02h, 10h, 01h, 30h, 03h, 00h
		db	0ACh, 0Eh,0FFh, 02h, 00h, 06h
		db	0BEh, 08h, 00h, 18h, 4Ah, 00h
		db	0A8h,0FEh, 4Ah, 00h, 20h,0AAh
		db	 80h, 0Eh, 00h, 2Fh,0A0h, 28h
		db	 00h,0BFh,0A0h, 80h, 00h,0FAh
		db	0A0h, 4Ah, 00h,0ABh,0A0h, 20h
		db	 00h,0BEh, 80h,0A0h, 00h,0FAh
		db	 80h, 4Ah, 01h, 03h, 4Ah, 01h
		db	 03h, 4Ah, 01h, 03h, 00h, 03h
		db	 00h, 01h, 00h, 03h, 4Ah, 01h
		db	 02h, 4Ah, 01h, 02h, 4Ah, 01h
		db	 06h, 00h, 04h, 4Ah, 00h,0EAh
		db	 4Ah, 01h,0EAh, 00h, 0Ah, 00h
		db	0A8h, 00h,0EAh, 00h,0C0h, 00h
		db	0FAh, 4Ah, 01h,0EEh, 4Ah, 01h
		db	0FAh, 4Ah, 01h,0EFh, 4Ah, 02h
		db	 0Eh, 00h, 08h, 00h, 0Eh, 00h
		db	 0Ch, 00h, 1Ah, 00h, 18h, 00h
		db	 3Ah, 4Ah, 01h, 2Ah, 00h, 20h
		db	 00h, 2Ah, 4Ah, 01h, 08h, 00h
		db	 32h, 4Ah, 00h, 03h,0AAh,0BEh
		db	 80h, 4Ah, 00h,0B3h, 80h, 08h
		db	 00h,0BCh, 80h, 02h, 00h, 80h
		db	0A0h, 0Ah, 00h, 80h, 20h, 0Eh
		db	 5Ch, 00h, 00h, 0Bh,0A0h, 80h
		db	 00h, 0Eh, 5Ch, 00h, 00h,0FAh
		db	 80h, 4Ah, 0Bh, 02h, 4Ah, 01h
		db	 03h, 4Ah, 01h, 02h, 4Ah, 00h
		db	 20h, 00h, 30h, 00h, 08h, 00h
		db	 18h, 03h, 4Ah, 06h,0BFh, 00h
		db	 1Ah, 00h,0FEh, 80h, 40h, 00h
		db	0FAh,0A0h, 4Ah, 00h,0CEh,0A0h
		db	 20h, 00h, 08h,0E0h,0A3h, 00h
		db	 0Ch,0A0h,0ABh, 4Ah, 01h, 0Ch
		db	 03h, 18h, 00h, 3Bh, 80h, 4Ah
		db	 00h, 0Ah,0FAh, 40h, 02h,0E0h
		db	0ABh, 02h,0C0h, 3Bh,0FFh, 4Ah
		db	 00h, 0Ah,0EAh, 10h, 00h, 30h
		db	 02h, 4Ah, 01h, 03h, 02h,0A0h
		db	0F8h, 4Ah, 00h, 80h,0AAh, 00h
		db	 38h, 00h,0BFh, 5Ch, 00h, 00h
		db	0FEh, 80h, 4Ah, 00h,0AAh, 80h
		db	 4Ah, 00h,0AAh, 80h, 4Ah, 00h
		db	0FEh, 4Ah, 01h,0FAh, 4Ah, 02h
		db	 03h, 4Ah, 01h, 03h, 4Ah, 01h
		db	 03h, 00h, 03h, 00h, 01h, 00h
		db	 03h, 4Ah, 01h, 02h, 4Ah, 01h
		db	 02h, 4Ah, 01h, 02h, 4Ah, 02h
		db	0EAh, 4Ah, 01h,0EAh, 00h, 0Ah
		db	 00h,0A8h, 00h,0EAh, 00h,0C0h
		db	 00h,0FAh, 4Ah, 01h,0EEh, 4Ah
		db	 01h,0BAh, 80h, 4Ah, 00h,0AFh
		db	 80h, 4Ah, 01h, 07h, 00h, 04h
		db	 00h, 06h, 00h, 04h, 00h, 0Eh
		db	 00h, 08h, 00h, 0Ah, 4Ah, 01h
		db	 0Ah, 00h, 08h, 00h, 0Ah, 4Ah
		db	 01h, 08h, 00h, 32h, 4Ah, 00h
		db	 03h,0AAh, 2Eh, 80h, 4Ah, 00h
		db	0A8h,0A0h, 02h, 00h,0ACh,0A0h
		db	 02h, 00h,0A2h, 20h, 08h, 80h
		db	0A0h, 20h, 0Eh, 5Ch, 00h, 00h
		db	 0Bh, 5Ch, 00h, 00h, 0Eh, 5Ch
		db	 00h, 00h,0FAh, 80h, 4Ah, 07h
		db	 02h, 4Ah, 01h, 03h, 4Ah, 01h
		db	 02h, 4Ah, 07h, 03h, 80h, 00h
		db	0C0h, 03h, 4Ah, 02h,0BFh, 00h
		db	 1Ah, 00h,0FEh, 5Ch, 00h, 00h
		db	0FAh,0A0h, 4Ah, 00h,0CEh,0A0h
		db	 20h, 00h, 08h,0E0h,0A3h, 00h
		db	 0Ch,0A0h,0ABh, 00h, 02h,0A0h
		db	0F8h, 4Ah, 01h, 60h, 4Ah, 01h
		db	 70h, 00h, 22h,0E8h, 3Fh,0FFh
		db	 40h, 00h, 6Bh,0BAh, 4Ah, 00h
		db	 80h, 02h, 4Ah, 01h, 03h, 4Ah
		db	 01h, 03h, 4Ah, 01h, 03h, 00h
		db	 80h,0AAh, 00h,0E8h, 00h,0FEh
		db	 80h, 4Ah, 00h,0EAh, 80h, 4Ah
		db	 00h,0AAh, 80h, 4Ah, 00h,0AEh
		db	 80h, 4Ah, 00h,0FAh, 4Ah, 01h
		db	0FEh, 4Ah, 01h,0FAh, 4Ah, 02h
		db	 03h, 4Ah, 01h, 03h, 00h, 03h
		db	 00h, 03h, 00h, 03h, 00h, 02h
		db	 00h, 03h, 00h, 02h, 00h, 03h
		db	 4Ah, 01h, 01h, 4Ah, 01h, 01h
		db	 4Ah, 02h,0EAh, 00h, 0Ah, 00h
		db	0A8h, 00h,0EAh, 00h, 80h, 00h
		db	0FAh, 00h, 80h, 00h,0FAh, 4Ah
		db	 01h,0F8h, 4Ah, 01h,0ECh, 4Ah
		db	 01h,0F8h, 4Ah, 02h, 03h, 00h
		db	 02h, 00h, 03h, 00h, 02h, 4Ah
		db	 01h, 03h, 4Ah, 01h, 03h, 4Ah
		db	 01h, 02h, 4Ah, 01h, 03h, 4Ah
		db	 01h, 03h, 00h, 20h, 00h, 3Eh
		db	0E8h, 4Ah, 01h, 38h, 00h, 80h
		db	 00h, 2Ch, 00h, 80h, 00h, 08h
		db	 00h,0A0h, 00h, 08h, 00h,0E0h
		db	 4Ah, 01h,0E0h, 4Ah, 01h,0A0h
		db	 4Ah, 01h,0A0h, 4Ah, 13h, 04h
		db	 00h, 0Ch, 4Ah, 01h, 07h, 00h
data_13		dw	2			; Data table (indexed access)
		db	 03h, 4Ah, 07h, 2Fh,0C0h, 06h
		db	 80h,0BFh,0A0h, 10h, 00h,0FEh
		db	0A8h, 4Ah, 00h,0B3h,0A8h, 08h
		db	 00h, 02h, 38h, 28h,0C0h, 03h
		db	 28h,0EAh,0C0h, 04h,0A0h, 0Eh
		db	0F0h, 00h, 0Ah, 00h,0FFh, 4Ah
		db	 01h, 0Eh, 4Ah, 02h, 10h, 04h
		db	 30h, 0Fh, 4Ah, 00h, 0Ah,0FAh
		db	 04h, 00h, 06h,0A8h, 4Ah, 00h
		db	 08h, 4Ah, 00h,0A8h,0FEh, 00h
		db	0B8h, 20h,0FAh, 80h, 02h, 00h
		db	0FFh,0A0h, 4Ah, 00h,0AAh,0A0h
		db	 4Ah, 00h,0BAh,0A0h, 4Ah, 00h
		db	0BEh,0A0h, 4Ah, 00h,0FEh, 80h
		db	 4Ah, 00h,0FAh, 80h, 4Ah, 01h
		db	 03h, 4Ah, 01h, 03h, 4Ah, 01h
		db	 03h, 00h, 03h, 00h, 03h, 00h
		db	 03h, 00h, 02h, 00h, 03h, 00h
		db	 02h, 00h, 07h, 00h, 05h, 00h
		db	 07h, 00h, 06h, 4Ah, 00h,0EAh
		db	 00h, 08h, 00h,0EAh, 00h, 0Ah
		db	 00h,0A0h, 00h,0EAh, 00h,0C0h
		db	 00h,0FAh, 4Ah, 01h,0ECh, 4Ah
		db	 01h,0F2h, 4Ah, 01h,0B2h, 4Ah
		db	 02h, 0Eh, 00h, 08h, 00h, 0Ch
		db	 00h, 02h, 00h, 0Ch, 00h, 02h
		db	 00h, 33h, 00h, 08h, 4Ah, 01h
		db	 2Eh, 4Ah, 01h, 2Eh, 4Ah, 01h
		db	 3Ah, 4Ah, 00h, 03h,0AAh,0CAh
		db	 4Ah, 01h,0EAh, 80h, 4Ah, 00h
		db	 8Ah, 80h, 4Ah, 00h, 8Ah,0A0h
		db	 4Ah, 00h, 82h,0A0h, 4Ah, 00h
		db	 02h,0A0h, 4Ah, 00h, 02h,0B0h
		db	 0Ch, 00h, 20h, 0Ch, 0Ah, 80h
		db	 0Dh, 90h, 00h, 03h, 0Dh, 40h
		db	 00h, 05h, 06h, 40h, 4Ah, 00h
		db	 03h, 4Ah, 02h,0A0h, 4Ah, 01h
		db	 15h, 4Ah, 09h, 10h,0C0h, 4Ah
		db	 00h, 10h,0A0h, 4Ah, 00h, 20h
		db	 4Ah, 01h, 40h, 4Ah, 00h, 02h
		db	 4Ah, 01h, 50h, 4Ah, 0Bh, 0Ch
		db	 03h, 00h, 80h, 3Dh,0C0h, 00h
		db	 0Ah, 0Bh,0FFh, 40h, 00h,0C0h
		db	0FFh, 4Ah, 00h, 2Ah,0AAh, 10h
		db	 00h, 1Ah,0ABh, 20h, 00h, 20h
		db	 03h, 4Ah, 01h, 03h, 02h,0A0h
		db	0F8h, 4Ah, 00h, 80h,0AAh, 00h
		db	 68h, 00h,0FEh, 80h, 08h, 00h
		db	0BAh, 80h, 4Ah, 00h,0AAh, 80h
		db	 4Ah, 00h,0EEh, 80h, 4Ah, 00h
		db	0FAh, 4Ah, 01h,0EAh, 4Ah, 02h
		db	 03h, 4Ah, 01h, 03h, 4Ah, 01h
		db	 03h, 00h, 03h, 00h, 03h, 00h
		db	 03h, 00h, 02h, 00h, 03h, 00h
		db	 02h, 00h, 03h, 00h, 02h, 00h
		db	 03h, 00h, 01h, 4Ah, 00h,0EAh
		db	 4Ah, 01h,0EAh, 00h, 0Ah, 00h
		db	0A0h, 00h,0EAh, 00h,0C0h, 00h
		db	0FAh, 00h, 80h, 00h,0ECh, 4Ah
		db	 01h,0F2h, 4Ah, 01h,0E2h, 80h
		db	 4Ah, 01h, 07h, 00h, 06h, 00h
		db	 06h, 00h, 04h, 00h, 0Eh, 4Ah
		db	 01h, 02h, 00h, 08h, 4Ah, 01h
		db	 0Eh, 4Ah, 01h, 0Eh, 4Ah, 01h
		db	 3Eh, 4Ah, 00h, 03h,0AAh, 22h
		db	 80h, 4Ah, 00h, 2Ah,0A0h, 80h
		db	 00h, 22h,0A0h, 80h, 00h,0A2h
		db	0A0h, 4Ah, 00h, 22h,0A0h, 80h
		db	 00h, 82h,0A0h, 4Ah, 00h, 02h
		db	0B0h, 0Ch, 00h, 20h, 0Ch, 0Ah
		db	 80h, 4Ah, 0Bh, 1Fh, 4Ah, 01h
		db	0FDh, 4Ah, 00h, 03h,0FEh, 4Ah
		db	 00h, 06h,0F8h, 00h, 05h, 0Dh
		db	0E8h, 00h, 13h, 00h, 0Ch, 00h
		db	 08h, 00h,0C0h, 00h, 80h, 00h
		db	 03h, 00h, 02h, 4Ah, 0Ah, 03h
		db	 00h, 02h, 00h,0C0h, 00h, 80h
		db	 00h, 2Ah, 4Ah, 00h,0BAh, 08h
		db	 00h, 02h,0AAh, 00h,0C0h, 0Fh
		db	0F8h, 00h, 88h, 0Eh,0FEh, 08h
		db	 02h, 0Fh,0AFh, 4Ah, 00h, 0Fh
		db	0AAh, 4Ah, 00h, 03h,0E8h, 4Ah
		db	 00h, 03h,0EAh, 02h, 00h, 03h
		db	0A0h, 20h, 00h,0FEh, 4Ah, 01h
		db	0A0h, 4Ah, 02h, 0Ch, 4Ah, 00h
		db	0C0h, 38h, 24h, 00h,0FFh,0E0h
		db	 4Ah, 00h,0AAh, 80h, 4Ah, 01h
		db	 20h, 4Ah, 01h,0EAh, 4Ah, 01h
		db	0AAh, 00h,0F0h, 00h,0EAh, 00h
		db	0FBh, 00h, 40h, 00h,0EEh, 00h
		db	 80h, 00h,0BAh, 00h, 80h, 01h
		db	0ACh, 4Ah, 00h, 01h,0F8h, 01h
		db	 4Ah, 01h, 80h, 4Ah, 01h, 80h
		db	 4Ah, 01h, 80h, 00h, 80h, 4Ah
		db	 01h, 80h, 4Ah, 05h, 80h, 4Ah
		db	 01h, 80h, 4Ah, 01h, 03h,0BAh
		db	 01h, 80h, 03h,0CAh, 02h, 20h
		db	 03h, 2Ah, 00h, 80h, 0Eh, 02h
		db	 04h,0A0h, 0Ch, 03h, 02h,0E0h
		db	 00h, 5Dh, 00h,0E0h, 00h, 5Dh
		db	 00h,0A0h, 4Ah, 00h, 02h,0AAh
		db	 80h, 4Ah, 01h,0A0h, 4Ah, 01h
		db	 80h, 4Ah, 01h,0A0h, 4Ah, 01h
		db	0A8h, 4Ah, 01h,0E8h, 4Ah, 01h
		db	 20h, 00h, 88h, 4Ah, 01h,0EAh
		db	 80h, 4Ah, 07h,0FAh, 00h, 60h
		db	 03h,0FAh, 01h, 80h, 0Fh,0EAh
		db	 05h, 00h, 0Fh,0A2h, 04h, 08h
		db	 0Fh, 20h, 00h, 8Ah, 0Eh, 30h
		db	 00h,0AFh, 4Ah, 0Ah, 80h, 4Ah
		db	 01h, 80h, 4Ah, 01h, 80h, 4Ah
		db	 04h, 0Ch, 4Ah, 00h, 80h, 30h
		db	 0Ah, 80h, 00h, 2Eh, 02h, 4Ah
		db	 00h,0AAh, 00h, 34h, 03h,0FEh
		db	 00h, 20h, 03h,0BFh, 02h, 00h
		db	 03h,0EAh, 4Ah, 00h, 03h,0EAh
		db	 4Ah, 01h,0FAh, 4Ah, 01h,0FAh
		db	 4Ah, 00h, 80h, 30h, 00h, 80h
		db	 02h,0ECh, 4Ah, 00h,0AFh,0A0h
		db	 80h, 00h,0EAh, 0Eh, 02h, 80h
		db	0FFh,0F8h, 4Ah, 00h,0AAh,0A0h
		db	 4Ah, 00h, 80h, 08h, 4Ah, 00h
		db	 80h, 4Ah, 02h,0EAh, 4Ah, 01h
		db	0AAh, 00h,0C0h, 00h,0EAh, 00h
		db	0EBh, 00h,0A0h, 00h,0EEh, 00h
		db	 80h, 02h,0BAh, 4Ah, 00h, 03h
		db	0ACh, 01h, 00h, 03h,0F8h, 02h
		db	 4Ah, 0Bh,0D0h, 4Ah, 01h, 52h
		db	 4Ah, 01h, 8Ah, 40h, 4Ah, 01h
		db	 20h, 50h, 4Ah, 00h, 10h,0A8h
		db	 00h, 07h,0B2h, 03h, 00h, 07h
		db	 2Ah, 06h, 80h, 0Eh, 3Eh, 00h
		db	 80h, 0Ch, 8Eh, 0Ah, 20h, 0Ch
		db	 0Eh, 02h,0A0h, 00h, 5Dh, 00h
		db	0E0h, 00h, 5Dh, 00h,0A0h, 4Ah
		db	 00h, 02h,0ABh, 80h, 4Ah, 01h
		db	 80h, 4Ah, 01h,0A0h, 4Ah, 01h
		db	 80h, 4Ah, 01h,0A0h, 4Ah, 01h
		db	0A0h, 4Ah, 01h, 20h, 00h, 88h
		db	 4Ah, 01h,0AAh, 80h, 4Ah, 03h
		db	0FAh, 00h, 60h, 03h,0FAh, 01h
		db	 80h, 0Fh,0EAh, 05h, 00h, 0Fh
		db	0A2h, 04h, 08h, 0Fh, 20h, 00h
		db	 8Ah, 0Eh, 30h, 00h,0AFh, 0Ah
		db	 80h, 00h, 2Eh, 4Ah, 06h, 80h
		db	 4Ah, 01h, 80h, 4Ah, 01h, 80h
		db	 4Ah, 07h, 80h, 4Ah, 01h, 80h
		db	 03h, 02h, 4Ah, 00h,0AAh, 00h
		db	 38h, 03h,0FFh, 00h,0A0h, 03h
		db	0EBh, 02h, 00h, 03h,0CAh, 4Ah
		db	 00h, 03h,0E8h, 4Ah, 01h,0EAh
		db	 4Ah, 01h,0FAh, 4Ah, 01h,0FAh
		db	 4Ah, 01h, 06h, 4Ah, 01h, 0Ch
		db	 2Ah, 00h,0FFh,0F4h, 4Ah, 00h
		db	0AAh,0A8h, 4Ah, 00h, 80h, 02h
		db	 4Ah, 00h, 80h, 4Ah, 01h, 80h
		db	 4Ah, 01h, 80h, 4Ah, 02h,0AAh
		db	 00h,0F0h, 00h,0EAh, 00h,0FBh
		db	 00h,0C0h, 00h,0EFh, 00h
		db	40h

_360UNKN	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		add	byte ptr data_8[bx],bh
		stosw				; Store ax to es:[di]
		dec	dx
;*		add	[bx+0],di
		db	 01h, 7Fh, 00h		;  Fixup - byte match
		db	 40h, 00h, 3Eh, 4Ah, 02h, 80h
		db	 4Ah, 01h, 80h, 00h, 80h, 4Ah
		db	 01h, 80h, 4Ah, 01h, 80h, 4Ah
		db	 01h, 80h, 4Ah, 05h, 80h, 4Ah
		db	 02h, 3Ah, 00h, 20h, 00h, 28h
		db	 00h, 22h, 00h, 38h, 00h, 02h
		db	 00h, 20h, 00h, 0Bh, 00h, 20h
		db	 00h, 0Fh, 4Ah, 01h, 0Fh, 4Ah
		db	 01h, 0Eh, 4Ah, 01h, 0Ah, 80h
		db	 4Ah, 01h, 80h, 4Ah, 03h, 80h
		db	 4Ah, 01h, 80h, 4Ah, 01h, 80h
		db	 4Ah, 01h, 80h, 4Ah, 01h, 80h
		db	 4Ah, 01h,0A8h, 4Ah, 07h, 03h
		db	0E8h, 01h, 80h, 0Fh,0EAh, 06h
		db	 00h, 3Fh,0AAh, 14h, 00h, 3Eh
		db	 8Ah, 10h, 20h, 3Ch, 80h, 02h
		db	 28h, 38h,0C0h, 02h,0BEh, 4Ah
		db	 15h, 30h, 00h, 80h, 00h,0C0h
		db	 4Ah, 01h, 80h, 2Ah, 4Ah, 00h
		db	0BAh, 08h, 0Ah, 03h,0AFh, 03h
		db	 40h, 0Fh,0FEh, 02h, 00h, 0Eh
		db	0AAh, 08h, 00h, 0Fh,0A8h, 4Ah
		db	 00h, 0Fh,0A8h, 4Ah, 00h, 03h
		db	0EAh, 4Ah, 00h, 03h,0EAh, 08h
		db	 00h, 0Fh, 79h, 00h, 00h,0FDh
		db	 4Ah, 01h,0A0h, 4Ah, 05h,0E0h
		db	 18h, 4Ah, 00h,0AEh,0A0h, 4Ah
		db	 00h, 2Ah, 80h, 4Ah, 01h, 20h
		db	 4Ah, 01h,0EAh, 4Ah, 01h,0AAh
		db	 00h,0F0h, 00h,0EAh, 00h,0FBh
		db	 00h, 40h, 00h,0EFh, 00h, 60h
		db	 00h, 2Bh, 4Ah, 00h, 01h,0CFh
		db	 4Ah, 00h, 01h,0CFh, 00h, 80h
		db	 4Ah, 00h, 80h, 4Ah, 01h, 80h
		db	 4Ah, 01h, 80h, 00h, 80h, 4Ah
		db	 01h, 80h, 4Ah, 01h, 80h, 4Ah
		db	 01h, 80h, 4Ah, 01h, 80h, 4Ah
		db	 01h, 03h,0A3h, 01h, 00h, 03h
		db	0ABh, 01h, 00h, 07h,0A3h, 03h
		db	 00h, 0Eh,0A3h, 04h, 00h, 0Eh
		db	 83h, 04h, 00h, 0Ah, 80h, 4Ah
		db	 00h, 0Eh, 80h, 00h, 20h, 30h
		db	 00h, 02h,0A8h,0E0h, 4Ah, 01h
		db	 30h, 00h, 80h, 00h, 30h, 00h
		db	 80h, 00h, 88h, 00h, 20h, 4Ah
		db	 01h,0B8h, 4Ah, 01h,0E8h, 4Ah
		db	 01h,0E8h, 4Ah, 01h,0EAh, 80h
		db	 0Dh, 90h, 00h, 2Fh, 0Dh, 40h
		db	 00h, 17h, 06h, 40h, 00h, 0Ah
		db	 03h, 4Ah, 02h,0A0h, 4Ah, 01h
		db	 15h, 4Ah, 08h,0F0h, 00h,0A0h
		db	 00h,0F0h, 00h, 80h, 00h, 03h
		db	 00h, 02h, 4Ah, 08h, 03h, 00h
		db	 02h, 96h, 00h, 63h, 00h, 4Ah
		db	 02h, 0Ah, 80h, 00h, 2Eh, 02h
		db	 20h, 00h,0BAh, 00h,0B0h, 03h
		db	0FFh, 4Ah, 00h, 03h,0FEh, 4Ah
		db	 00h, 03h,0AAh, 4Ah, 00h, 03h
		db	0EAh, 4Ah, 01h,0FAh, 4Ah, 01h
		db	0FAh, 4Ah, 00h, 80h, 30h, 02h
		db	 00h, 03h,0E8h,0A8h, 00h,0FFh
		db	0C0h, 4Ah, 00h,0FAh, 0Eh, 4Ah
		db	 00h,0AAh,0A8h, 4Ah, 00h, 2Ah
		db	0A0h, 4Ah, 00h, 80h, 08h, 4Ah
		db	 00h, 80h, 4Ah, 02h,0FAh, 4Ah
		db	 01h,0EAh, 00h,0F0h, 00h,0DAh
		db	 00h,0FFh, 00h, 40h, 01h, 7Fh
		db	 00h, 20h, 03h, 2Fh, 00h, 08h
		db	 03h, 8Bh, 01h, 00h, 03h, 8Fh
		db	 01h, 4Ah, 00h, 10h,0D0h, 4Ah
		db	 00h, 10h,0A8h, 4Ah, 00h, 20h
		db	 40h, 4Ah, 00h, 40h, 4Ah, 00h
		db	 02h, 4Ah, 01h, 50h, 4Ah, 09h
		db	 07h, 8Eh, 02h, 08h, 06h,0ACh
		db	 06h, 0Ah, 0Eh, 8Ch, 04h, 03h
		db	 0Eh, 8Ah, 08h, 00h, 0Eh, 84h
		db	 00h, 03h, 0Eh, 82h, 4Ah, 00h
		db	 1Eh, 80h, 00h, 20h, 30h, 00h
		db	 03h,0A8h, 80h, 4Ah, 01h,0A0h
		db	 4Ah, 01h,0A0h, 4Ah, 01h, 80h
		db	 00h, 20h, 4Ah, 01h,0A0h, 4Ah
		db	 01h,0E0h, 4Ah, 01h,0E8h, 4Ah
		db	 01h,0AAh, 80h, 00h, 08h, 00h
		db	 08h, 10h,0A0h, 10h,0B0h, 04h
		db	 02h, 07h,0C0h, 00h, 03h, 07h
		db	 00h, 04h, 02h, 07h, 80h, 04h
		db	 00h, 07h, 00h, 02h, 00h, 03h
		db	 83h, 01h, 00h, 03h,0A3h, 4Ah
		db	 0Bh, 1Fh, 4Ah, 01h,0FDh, 4Ah
		db	 00h, 03h,0FEh, 00h, 01h, 06h
		db	0F8h, 00h, 07h, 0Dh,0E9h, 00h
		db	 16h, 03h, 00h, 03h,0D4h, 00h
		db	 60h, 00h,0FFh, 00h, 04h, 00h
		db	 0Fh, 4Ah, 01h, 01h, 4Ah, 01h
		db	 03h, 4Ah, 01h, 03h, 4Ah, 01h
		db	 03h, 4Ah, 01h, 03h, 4Ah, 0Ah
		db	0D0h, 4Ah, 01h, 52h, 4Ah, 01h
		db	 8Ah, 40h, 20h, 4Ah, 00h, 20h
		db	0F5h, 00h, 40h, 10h,0BAh, 00h
		db	 03h, 00h, 03h,0D4h, 00h, 60h
		db	 00h,0FFh, 00h, 04h, 00h, 0Fh
		db	 4Ah, 01h, 31h, 00h, 58h, 00h
		db	 7Fh, 00h, 20h, 00h, 7Fh, 4Ah
		db	 01h, 2Fh, 4Ah, 01h, 0Ah, 0Dh
		db	 92h, 00h, 2Dh, 0Dh, 45h, 00h
		db	 3Ah, 06h, 40h, 00h, 1Fh, 03h
		db	 4Ah, 00h, 0Ah, 00h,0A0h, 4Ah
		db	 01h, 15h, 4Ah, 08h, 03h, 00h
		db	 03h,0D4h, 00h, 60h, 00h,0FFh
		db	 0Bh, 44h, 02h, 0Fh, 2Fh, 80h
		db	 28h, 31h,0FFh,0E0h, 6Dh, 0Bh
		db	0FFh,0E4h, 16h, 92h, 3Fh, 52h
		db	 08h, 0Dh, 02h, 88h, 00h, 36h
		db	 80h, 10h, 7Dh, 00h, 40h, 10h
		db	0BAh, 4Ah, 00h, 20h,0D4h, 4Ah
		db	 00h, 40h,0A0h, 00h, 02h, 4Ah
		db	 01h, 50h, 4Ah, 09h, 10h, 00h
		db	 10h, 00h, 08h, 00h, 0Dh, 08h
		db	 83h, 00h, 03h,0E0h, 80h, 00h
		db	 01h,0C0h, 82h, 00h, 03h,0C0h
		db	 4Ah, 00h, 01h,0C0h, 02h, 00h
		db	 83h,0C0h, 02h, 00h, 83h, 80h
		db	 03h,0BFh, 02h,0AAh, 08h, 4Ah
		db	 01h, 18h, 00h, 02h,0FEh, 30h
		db	 00h, 20h, 00h, 20h, 00h, 0Bh
		db	0FAh, 20h, 00h, 20h, 4Ah, 01h
		db	 0Bh,0FAh, 20h, 00h, 20h, 00h
		db	 0Eh, 00h, 5Fh, 80h, 4Ah, 00h
		db	0FFh, 4Ah, 01h,0D4h, 4Ah, 01h
		db	 80h, 4Ah, 01h, 80h, 4Ah, 01h
		db	 80h, 4Ah, 01h, 80h, 4Ah, 01h
		db	 80h, 00h, 0Eh, 00h, 5Fh, 80h
		db	 4Ah, 00h,0FFh, 4Ah, 01h,0D4h
		db	 4Ah, 01h, 80h, 4Ah, 01h,0A8h
		db	 4Ah, 01h,0B8h, 4Ah, 01h,0A8h
		db	 4Ah, 01h, 20h, 00h, 0Eh, 00h
		db	 5Fh, 80h, 4Ah, 00h,0FFh, 4Ah
		db	 00h, 74h,0D4h, 4Ah, 00h, 3Fh
		db	 81h, 8Ch, 00h,0FBh,0ACh, 02h
		db	 00h, 56h,0B3h, 00h, 03h,0A8h
		db	0A8h, 4Ah, 01h, 24h, 4Ah, 00h
		db	 0Bh, 00h, 01h, 00h, 2Fh, 00h
		db	 08h, 00h, 7Ah, 4Ah, 01h, 6Ch
		db	 00h, 0Dh, 00h, 40h, 00h, 0Ch
		db	 00h, 40h, 20h, 1Fh, 40h, 20h
		db	 60h, 0Fh, 80h,0C0h,0ECh,0CAh
		db	0F0h, 00h,0A0h, 00h,0A8h, 12h
		db	 00h, 1Ah, 0Ah, 13h, 00h, 1Ah
		db	 6Ah, 14h,0E0h, 1Fh, 06h, 00h
		db	 70h, 1Eh, 02h, 40h,0F0h, 7Eh
		db	 0Ah, 00h,0C0h, 0Dh, 08h, 00h
		db	0A1h, 9Ah, 01h, 00h,0F9h,0BFh
		db	 40h, 00h, 73h, 7Dh, 22h, 11h
		db	 78h,0C5h, 01h,0AFh, 1Ch, 07h
		db	 01h, 4Fh, 0Ch, 0Eh, 61h, 7Dh
		db	 60h, 2Ch, 1Ch,0F0h, 1Ch,0B0h
		db	 00h,0E3h, 00h,0A3h, 86h, 00h
		db	0E1h,0D4h,0D8h, 00h, 82h,0A0h
		db	0E0h, 00h,0C9h, 00h,0E5h, 10h
		db	 80h, 00h,0D0h, 4Ah, 01h, 2Eh
		db	 64h, 00h, 60h, 61h,0C0h, 61h
		db	 80h, 1Ch, 00h, 14h, 00h,0AAh
		db	0F0h,0AAh, 30h, 03h, 08h, 00h
		db	 08h, 02h, 04h,0AAh, 9Bh, 00h
		db	 02h, 04h, 22h, 4Ah, 00h,0A0h
		db	 48h, 04h, 02h, 04h, 92h, 4Ah
		db	 00h,0A1h, 20h, 04h, 02h, 04h
		db	 02h, 3Fh,0B6h, 23h,0A6h, 20h
		db	 34h, 00h, 24h, 10h, 1Ch, 02h
		db	 3Eh, 10h, 00h, 01h, 55h, 10h
		db	 00h, 10h, 00h, 10h, 00h, 15h
		db	0FDh, 10h, 00h, 12h,0AAh, 1Dh
		db	 50h, 1Dh, 50h, 40h, 82h, 00h
		db	 02h, 00h, 41h, 00h, 01h, 28h
		db	 61h, 00h, 01h, 0Ch, 31h, 00h
		db	 01h, 0Fh,0C9h, 01h, 81h, 45h
		db	0A3h, 01h, 82h, 57h, 83h, 03h
		db	 02h, 13h,0A3h, 03h, 02h, 4Ah
		db	 02h, 40h, 42h, 40h, 00h,0C1h
		db	 84h,0C0h, 00h, 87h, 10h, 80h
		db	 00h,0C3h, 40h,0C0h, 00h, 88h
		db	 92h, 80h, 1Ah, 83h,0DBh, 80h
		db	 12h, 8Fh, 17h, 80h, 18h,0EAh
		db	0AAh, 8Ah,0AAh, 04h, 02h, 04h
		db	 02h, 04h, 00h, 20h, 80h, 04h
		db	 02h, 44h, 22h, 04h, 02h, 05h
		db	 02h, 04h, 00h, 50h, 20h, 9Bh
		db	 00h,0A2h, 44h, 6Dh, 6Ch, 45h
		db	 6Ch, 00h, 02h, 00h, 02h, 00h
		db	 07h, 00h, 06h, 00h, 07h, 00h
		db	 06h, 00h, 1Fh, 00h, 1Fh, 00h
		db	 78h, 00h, 70h, 00h,0E0h, 00h
		db	0C0h, 00h, 78h, 00h, 70h, 00h
		db	 1Fh, 00h, 1Bh, 4Ah, 0Ah,0C0h
		db	 00h,0C0h, 00h,0F0h, 00h,0E0h
		db	 00h, 38h, 00h, 20h, 00h,0F0h
		db	 00h,0C0h, 00h,0C0h, 4Ah, 02h
		db	 0Fh, 00h, 0Dh, 00h, 0Bh, 00h
		db	 0Ah, 00h, 0Bh, 00h, 09h, 00h
		db	 0Bh, 00h, 0Ah, 00h, 0Bh, 00h
		db	 09h, 00h, 0Bh, 00h, 0Ah, 00h
		db	 0Bh, 00h, 09h, 4Ah, 02h, 86h
		db	 78h, 06h, 78h, 32h, 9Ch, 00h
		db	 14h, 0Dh,0B3h, 4Ah, 00h, 1Ah
		db	 4Fh, 4Ah, 00h, 80h, 66h, 00h
		db	 20h, 00h, 72h, 00h, 20h, 00h
		db	0F1h, 4Ah, 00h, 01h,0FDh, 00h
		db	 80h, 86h, 24h, 86h, 00h, 38h
		db	 00h, 28h, 00h, 0Ch, 20h, 4Ah
		db	 00h, 6Ah, 4Ah, 01h, 64h, 4Ah
		db	 01h,0CAh, 4Ah, 01h, 27h, 4Ah
		db	 01h, 3Fh, 80h, 4Ah, 00h, 03h
		db	0F9h, 03h, 40h, 07h,0A1h, 06h
		db	 00h, 06h, 64h, 4Ah, 00h, 0Ch
		db	 21h, 00h, 80h, 0Ch, 20h, 01h
		db	 80h, 04h, 20h, 01h, 80h, 00h
		db	 7Ch, 00h,0D0h, 4Ah, 00h, 1Dh
		db	 50h, 9Eh, 80h, 4Ah, 00h, 25h
		db	 60h, 4Ah, 00h, 06h,0A0h, 4Ah
		db	 00h, 04h, 50h, 01h, 80h, 04h
		db	 10h, 03h,0C0h, 04h, 20h, 03h
		db	 80h, 4Ah, 00h, 0Bh, 80h, 4Ah
		db	 00h, 0Ah,0B8h, 3Fh,0C7h, 01h
		db	0C5h, 1Eh,0DEh, 20h, 9Ah, 47h
		db	0FEh, 60h, 38h, 87h,0FFh,0E8h
		db	 30h, 1Fh,0FDh,0E0h, 28h,0EDh
		db	0FFh, 52h, 14h, 7Bh,0FFh, 00h
		db	 19h, 35h,0FFh, 08h, 04h, 16h
		db	 3Eh, 4Ah, 00h, 7Ah,0FCh, 18h
		db	 02h,0CFh,0F0h, 07h, 0Dh, 5Bh
		db	0D4h, 00h,0CAh,0E7h, 40h, 00h
		db	0D4h, 7Fh,0A2h, 01h, 80h,0F6h
		db	 40h, 0Fh, 00h,0DDh, 00h, 18h
		db	 00h, 41h,0F7h, 00h, 02h, 06h
		db	0FFh, 4Ah, 00h, 11h, 3Fh, 4Ah
		db	 00h, 81h, 9Fh, 4Ah, 00h, 03h
		db	0F3h, 02h, 00h, 07h,0ACh, 06h
		db	 02h, 0Fh,0E8h, 00h, 06h, 05h
		db	0D0h, 00h, 06h,0FEh, 04h, 4Ah
		db	 00h,0FFh, 10h,0C0h, 00h,0F6h
		db	 4Ah, 01h,0F9h, 02h, 4Ah, 00h
		db	 4Fh, 80h, 4Ah, 00h, 27h, 40h
		db	0C0h, 00h, 37h,0A0h,0C0h, 00h
		db	 17h, 85h, 00h, 4Ah, 00h, 02h
		db	 00h, 02h, 00h, 08h, 00h, 08h
		db	 4Ah, 03h, 12h, 00h, 10h, 20h
		db	 24h, 4Ah, 01h, 1Ah, 00h, 10h
		db	 00h, 03h, 4Ah, 00h, 01h, 0Fh
		db	 00h, 04h, 60h, 00h, 60h, 00h
		db	 10h, 00h, 10h, 4Ah, 03h, 04h
		db	 00h, 04h, 00h, 10h, 80h, 4Ah
		db	 00h,0C0h, 4Ah, 01h, 48h, 20h
		db	 4Ah, 00h, 22h, 4Ah, 01h, 08h
		db	 06h, 00h, 02h, 00h, 46h, 4Ah
		db	 00h, 02h,0A4h, 4Ah, 00h, 13h
		db	 5Bh, 4Ah, 00h, 05h,0BBh, 4Ah
		db	 00h, 01h, 7Fh, 4Ah, 00h, 0Ah
		db	0D7h, 4Ah, 00h, 64h, 22h, 4Ah
		db	 00h, 9Dh, 00h, 4Ah, 00h,0C8h
		db	 4Ah, 01h,0EAh, 24h, 4Ah, 00h
		db	0F6h, 80h, 4Ah, 00h,0ECh, 4Ah
		db	 01h,0FDh, 40h, 4Ah, 00h,0D6h
		db	0A0h, 4Ah, 00h, 94h, 8Ch, 4Ah
		db	 08h,0E0h, 00h,0A0h, 4Ah, 03h
		db	 90h, 00h, 90h, 00h,0F0h, 00h
		db	0C0h, 4Ah, 08h, 07h, 4Ah, 01h
		db	 0Fh, 4Ah, 01h, 05h, 4Ah, 01h
		db	 04h, 4Ah, 01h, 3Fh, 4Ah, 01h
		db	 0Fh, 4Ah, 01h, 0Ah, 4Ah, 01h
		db	 62h, 4Ah, 00h,0E0h, 4Ah, 01h
		db	 90h, 4Ah, 01h, 20h, 4Ah, 01h
		db	 20h, 4Ah, 01h, 4Ch, 4Ah, 01h
		db	 10h, 4Ah, 05h, 02h, 4Ah, 01h
		db	 01h, 95h, 4Ah, 00h, 07h,0B8h
		db	 00h, 47h, 0Fh, 30h, 00h, 8Ah
		db	 0Fh,0B0h, 00h, 45h, 0Dh, 30h
		db	 02h, 8Bh, 06h,0D0h, 00h, 25h
		db	 01h,0A8h, 00h, 13h, 00h, 54h
		db	 00h, 2Ah, 50h, 80h, 4Ah, 01h
		db	 20h,0FCh, 4Ah, 00h, 10h,0AAh
		db	 80h, 4Ah, 00h, 55h, 4Ah, 00h
		db	 10h,0FEh, 80h, 00h, 20h,0FFh
		db	 4Ah, 00h, 80h,0FCh, 00h, 02h
		db	 00h,0A8h, 4Ah, 01h, 06h, 92h
		db	 4Ah, 00h, 47h, 24h, 4Ah, 00h
		db	 26h,0A0h, 4Ah, 00h,0D3h, 44h
		db	 4Ah, 00h,0F3h, 89h, 4Ah, 00h
		db	0A9h, 01h, 4Ah, 00h, 58h, 0Bh
		db	 4Ah, 00h, 0Ch, 13h, 29h,0A0h
		db	 29h,0A0h, 44h, 14h, 44h, 14h
		db	 00h, 08h, 26h,0A8h, 4Ah, 00h
		db	0D3h, 44h, 4Ah, 00h,0F3h, 89h
		db	 4Ah, 00h,0A9h, 01h, 4Ah, 00h
		db	 58h, 0Bh, 4Ah, 00h, 0Ch, 13h
		db	 4Ah, 00h, 06h, 92h, 4Ah, 00h
		db	 05h, 24h, 4Ah, 00h, 06h,0A0h
		db	 4Ah, 00h, 03h, 40h, 4Ah, 00h
		db	 02h, 84h, 4Ah, 00h, 11h, 4Ah
		db	 01h, 40h, 34h, 4Ah, 00h,0A2h
		db	0A9h, 4Ah, 00h, 06h, 92h, 4Ah
		db	 00h, 05h, 24h, 4Ah, 00h, 06h
		db	0A0h, 4Ah, 00h, 03h, 40h, 4Ah
		db	 00h, 02h, 80h, 4Ah, 00h, 01h
		db	 4Ah, 06h, 01h, 00h, 01h, 4Ah
		db	 01h, 01h, 4Ah, 01h, 01h, 4Ah
		db	 01h, 01h, 4Ah, 01h, 01h, 00h
		db	 01h, 00h, 01h, 00h, 01h, 4Ah
		db	 08h, 20h, 4Ah, 05h, 40h, 02h
		db	 4Ah, 00h, 20h, 02h, 4Ah, 00h
		db	 40h, 0Bh, 4Ah, 01h, 06h, 4Ah
		db	 00h, 24h, 05h, 4Ah, 00h, 99h
		db	 12h, 4Ah, 00h, 80h, 00h,0C0h
		db	 00h, 60h, 00h,0D5h, 00h, 7Fh
		db	 00h, 61h,0F0h,0E1h,0F0h, 54h
		db	 30h,0DEh, 30h, 97h, 50h,0BFh
		db	0D0h, 75h, 50h, 1Fh,0D0h, 75h
		db	0E0h, 9Fh,0E0h, 4Ah, 0Dh, 80h
		db	 4Ah, 05h, 80h
loc_3:
		dec	dx
		add	[bx+di],al
		dec	dx
		add	ah,[bx+si]
		dec	dx
		add	ax,[bx+di]
		add	[bx+di],al
		dec	dx
		add	ax,[bx]
		add	[bx+si],cl
		add	[di],bl
		add	ss:data_16e[bp+di],dl
;*		adc	di,bp
		db	 11h,0EFh		;  Fixup - byte match
		aas				; Ascii adjust
		iret				; Interrupt return
sub_1		endp

		db	 27h,0CFh, 4Ah, 00h, 15h, 55h
		db	 4Ah, 01h, 80h, 4Ah, 00h, 01h
		db	 20h, 4Ah, 00h, 01h, 4Ah, 01h
		db	 10h, 40h, 4Ah, 00h,0A1h,0A2h
		db	 4Ah, 00h, 0Ah,0A0h, 4Ah, 00h
		db	 25h, 08h, 4Ah, 00h, 5Ah, 55h
		db	 75h,0C0h
		db	0BFh,0C0h,0F5h,0E0h, 3Fh,0E0h
		db	 57h, 00h, 7Fh, 00h, 14h,0F0h
		db	 3Ch, 30h, 19h,0A0h, 98h,0E0h
		db	0DAh,0F0h,0D9h,0F0h, 83h,0E0h
		db	 83h,0E0h, 4Ah, 00h, 05h, 50h
		db	 29h, 00h, 29h, 00h, 40h, 80h
		db	 44h, 80h, 00h, 10h, 16h,0B8h
		db	 4Ah, 00h, 13h, 50h, 00h, 04h
		db	 0Bh, 8Ch, 4Ah, 00h, 01h, 50h
		db	 4Ah, 00h, 01h, 48h, 4Ah, 00h
		db	 05h, 4Ah, 00h,0A0h, 01h,0A0h
		db	 04h, 14h

locloop_4:
		add	al,14h
		adc	[bx+si],cl
		push	ds
		test	al,4Ah			; 'J'
		add	[bp+di],dl
		inc	sp
		dec	dx
;*		add	bl,cl
		db	 00h,0CBh		;  Fixup - byte match
;*		mov	[bp+si+0],cl
		db	 88h, 4Ah, 00h		;  Fixup - byte match
		db	 05h, 40h, 4Ah, 00h, 01h, 4Ah
		db	 01h, 05h, 4Ah, 07h

locloop_5:
		add	[bx+si],ax
		add	[bp+si+2],cx
		add	byte ptr [bx+di],40h	; '@'
		add	[bx+si+4Ah],ax
		add	ds:data_14e[bx+si],ax
		add	[bx+si+4Ah],ax
		add	[bx+si],sp

seg_a		ends



		end	start
