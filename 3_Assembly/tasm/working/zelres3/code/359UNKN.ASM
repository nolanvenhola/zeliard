
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_359UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_21e	equ	2001h			;*
data_22e	equ	2808h			;*
data_23e	equ	28E0h			;*
data_24e	equ	28ECh			;*
data_25e	equ	2E0Eh			;*
data_26e	equ	2EC0h			;*
data_27e	equ	3300h			;*
data_28e	equ	382Bh			;*
data_29e	equ	388Ch			;*
data_30e	equ	0E000h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_359UNKN	proc	far

start:
		inc	bp
		push	ss
		add	[bx+si],al
		add	byte ptr data_2,al
		dec	bx
		or	byte ptr [di-1],53h	; 'S'
		add	si,[di+2]
		jl	$-54h			; Jump if <
		xchg	[bx+di],ax
		xchg	sp,ax
		db	0C0h, 96h, 10h, 9Ah, 20h, 9Bh
		db	0A0h, 9Dh, 40h, 9Eh, 06h,0A4h
		db	 0Fh,0A7h, 3Fh,0B1h,0A8h,0B4h
		db	0E0h,0B7h, 30h,0BBh, 28h,0C6h
		db	0F0h
data_2		dw	4D7h			; Data table (indexed access)
		db	0D9h,0EAh,0DCh,0FCh,0DFh, 55h
		db	0E7h, 08h,0FFh,0FFh, 2Eh, 3Ah
		db	 60h, 00h,0F8h, 00h, 28h, 06h
		db	 3Ch, 07h,0B2h, 00h,0FBh, 0Eh
		db	 82h, 80h,0C3h,0EAh, 2Ah, 3Eh
		db	 3Fh, 98h, 0Bh,0AAh, 0Ch, 00h
		db	 02h,0AAh, 00h, 3Fh, 00h, 3Ah
		db	 00h,0FFh, 00h, 0Ah, 03h,0AFh
		db	 2Eh, 00h, 33h, 2Eh, 01h,0AEh
		db	0C0h, 2Eh, 00h, 72h, 38h, 03h
		db	0E0h,0A9h, 88h,0BAh,0AAh, 2Eh
		db	 00h, 7Ch, 00h, 03h,0F0h, 8Eh
		db	0A0h,0EFh,0F8h, 8Ah, 80h,0CFh
		db	0EAh, 2Eh, 0Fh, 0Ah, 2Eh, 01h
		db	 2Bh, 2Eh, 01h,0BFh, 00h, 02h
		db	 2Ah,0FFh, 00h, 2Bh, 00h, 06h
		db	 00h, 07h, 28h, 00h, 3Ch, 0Eh
		db	0B2h, 00h,0F3h,0EAh, 82h, 3Eh
		db	0C7h, 98h, 2Bh,0BAh, 3Ch, 3Fh
		db	 02h,0AAh, 00h, 3Fh, 00h, 2Ah
		db	 00h, 3Fh, 2Eh, 01h,0A8h, 2Eh
		db	 00h, 33h, 2Eh, 01h,0AEh,0C0h
		db	 2Eh, 00h, 72h, 38h, 03h,0E0h
		db	0A9h, 88h,0BAh,0AAh, 2Eh, 00h
		db	 7Ch, 00h, 03h,0F0h, 03h,0A0h
		db	0ABh,0F8h, 02h,0A0h, 03h,0F0h
		db	 2Eh, 06h, 80h
		db	2Eh
data_3		dw	8001h
		db	 2Eh, 01h,0E8h, 00h, 80h, 00h
		db	0FEh, 00h, 80h, 00h,0FFh, 80h
		db	0E0h, 00h,0FFh,0EAh,0FAh, 2Eh
		db	 00h, 06h, 00h, 07h, 2Eh, 01h
		db	 0Eh, 2Ah, 00h, 3Fh,0EAh,0B2h
		db	 3Eh,0F3h, 98h, 83h,0BAh,0C4h
		db	 3Fh, 2Ah,0AAh, 3Ch,0FFh, 00h
		db	0A8h, 00h,0FEh, 2Eh, 01h

locloop_1:
		sub	ch,ds:data_27e
		add	cs:data_26e[bp],bp
		add	[bp+si+38h],dh
		add	sp,ax
		test	ax,0BA88h
		stosb				; Store al to es:[di]
;*		add	cs:[si+0],bh
		db	 2Eh, 00h, 7Ch, 00h	;  Fixup - byte match
		db	 03h,0F0h, 03h,0A8h,0ABh,0FCh
		db	 00h,0A8h, 00h,0FCh, 00h,0BFh
		db	 00h, 02h, 00h, 2Fh, 2Eh, 01h
		db	 0Ah, 2Eh, 15h, 06h, 00h
data_5		dw	2807h, 3C00h		; Data table (indexed access)
		db	 0Eh,0B2h, 00h,0F3h,0EAh, 82h
		db	 3Eh,0C7h, 98h, 2Bh,0BAh, 3Ch
		db	 3Fh, 02h,0A8h, 00h,0FEh, 02h
		db	0A0h, 03h,0FAh, 2Eh, 01h, 0Ah
		db	 2Eh, 00h, 33h, 2Eh, 01h,0AEh
		db	0C0h, 2Eh, 00h, 72h, 38h, 03h
		db	0E0h,0A9h, 88h,0BAh,0AAh, 2Eh
		db	 00h, 7Ch, 00h, 03h,0F0h, 00h
		db	0E8h,0AAh,0FCh, 00h, 2Ah, 80h
		db	 3Fh,0FFh, 80h,0E0h, 00h,0FEh
		db	 00h, 80h, 00h,0E8h, 00h, 80h
		db	 00h, 80h, 2Eh, 01h, 80h, 2Eh
		db	 01h, 80h, 2Eh, 09h, 28h, 06h
		db	 3Ch, 07h,0B2h, 00h,0F3h, 0Eh
		db	 82h, 00h,0C7h,0EAh, 2Ah, 3Eh
		db	 3Fh, 98h, 0Bh,0AAh, 0Ch, 00h
		db	 02h,0A8h, 00h,0FEh, 03h,0A0h
		db	 03h,0FAh, 0Ah, 80h, 0Fh,0C2h
		db	 2Eh, 00h, 33h, 2Eh, 01h,0AEh
		db	0C0h, 2Eh, 00h, 72h, 38h, 03h
		db	0E0h,0A9h, 88h,0BAh,0AAh, 03h
		db	0FCh,0ABh,0AAh, 03h,0FFh, 00h
		db	 2Ah,0AAh,0BFh, 2Eh, 00h,0BAh
		db	 2Eh, 00h, 03h, 00h, 02h, 00h
		db	 0Fh, 00h, 02h, 53h, 00h, 02h
		db	 00h, 30h, 3Ch, 20h, 08h, 00h
		db	0CCh, 2Eh, 00h, 03h, 0Ch, 2Eh
		db	 01h, 03h, 00h, 02h,0F0h, 3Fh
		db	 80h, 28h, 00h, 06h, 00h, 07h
		db	 28h, 00h, 3Ch, 0Eh,0B2h, 00h
		db	0F3h,0EAh, 82h, 3Eh,0C7h, 98h
		db	 2Bh,0AAh, 3Ch, 00h, 02h,0AAh
		db	 00h,0FFh, 00h,0A8h, 00h,0FEh
		db	 02h,0A0h, 03h,0F0h, 2Eh, 00h
		db	 33h, 2Eh, 01h,0AEh,0C0h
		db	2Eh
data_6		db	0			; Data table (indexed access)
		db	 72h, 38h, 03h,0A0h,0A8h,0F8h
		db	0BAh,0AAh, 03h,0FCh,0A8h,0AAh
		db	 00h,0FCh, 2Eh, 00h,0AAh, 80h
		db	 2Eh, 00h, 0Eh, 80h, 2Eh, 02h
		db	0C0h, 00h, 80h, 00h, 0Ch, 00h
		db	 08h, 2Eh, 03h,0F0h, 30h,0A0h
		db	 20h, 0Ch, 00h, 08h, 2Eh, 03h
		db	0C0h,0CFh, 80h, 2Eh, 00h, 06h
		db	 00h, 07h, 2Eh, 01h, 0Eh, 28h
		db	 00h, 3Ch,0EAh,0B2h, 3Eh,0F3h
		db	 98h, 83h,0AAh,0C4h, 00h, 2Ah
		db	0AAh, 3Ch, 3Fh, 00h,0E8h, 00h
		db	0FEh, 00h,0A8h, 00h,0FCh, 2Eh
		db	 00h, 33h, 2Eh, 01h,0AEh,0C0h
		db	 2Eh, 00h, 72h, 38h, 03h,0E0h
		db	0A9h, 88h,0BAh,0AAh, 03h,0F0h
		db	0ABh,0AAh, 03h,0F0h, 02h,0A0h
		db	0ABh,0F0h, 2Eh, 00h, 03h,0A0h
		db	 0Ch,0CFh, 2Eh, 01h, 03h, 00h
		db	 02h, 0Ch,0C0h, 2Eh, 01h, 0Fh
		db	 00h, 02h, 33h, 30h, 20h, 2Eh
		db	 04h,0C3h, 00h, 82h, 00h, 03h
		db	 2Eh, 01h, 06h, 00h, 07h, 28h
		db	 00h, 3Ch, 0Eh,0B2h, 00h,0F3h
		db	0EAh, 82h, 3Eh,0C7h, 98h, 2Bh
		db	0AAh, 3Ch, 00h, 02h,0AAh, 00h
		db	3Fh
data_7		db	0
		db	 3Ah, 00h, 3Fh, 00h, 2Ah, 00h
		db	 3Fh, 2Eh, 00h, 33h, 2Eh, 01h
		db	0AEh,0C0h, 2Eh, 00h, 72h, 38h
		db	 03h,0E0h,0A9h, 88h,0BAh,0AAh
		db	 03h,0F0h,0ABh,0AAh, 0Fh,0F0h
		db	 0Ah, 80h,0AFh,0E0h, 2Eh, 01h
		db	0E8h, 2Eh, 1Dh, 3Fh, 01h, 80h
		db	 01h,0C8h, 06h, 10h, 06h,0DBh
		db	 18h, 30h, 1Dh,0BCh, 0Fh, 80h
		db	 26h, 2Bh,0EAh,0AEh, 40h, 00h
		db	 7Ch, 00h, 0Fh,0C0h, 0Eh,0A3h
		db	 3Fh,0FBh, 02h,0A2h,0EBh,0F3h
		db	 00h, 28h, 80h, 3Ch,0C0h,0B2h
		db	0E0h,0F3h, 00h, 82h,0CBh,0C7h
		db	0F8h,0A8h, 62h,0FCh,0AAh,0A0h
		db	 00h, 30h,0AAh
data_8		dw	0FC80h			; Data table (indexed access)
		db	 00h,0A8h, 00h,0FEh, 00h,0A0h
		db	 00h,0FAh, 80h,0CCh, 00h, 80h
		db	 00h, 03h,0C0h, 00h, 80h,0CCh
		db	 2Eh, 05h,0B7h, 00h, 00h, 20h
		db	 03h
data_9		db	0
		db	 02h, 00h,0F0h, 00h, 20h, 2Eh
		db	 03h, 01h, 80h, 01h,0C8h, 06h
		db	 10h, 06h,0DBh, 18h, 30h, 1Dh
		db	0BCh, 0Fh, 80h, 26h, 2Bh,0EAh
		db	0AEh, 40h, 00h, 7Ch, 00h, 0Fh
		db	0C0h, 0Eh, 80h, 2Fh,0EAh, 0Ah
		db	 80h, 0Fh,0C0h, 2Eh, 00h, 80h
		db	 00h,0C0h, 28h,0E0h, 3Ch, 00h
		db	0B2h,0CBh,0F3h,0F8h, 82h, 62h
		db	0C7h,0EAh,0A8h,0FCh, 3Ch,0AAh
		db	 80h,0FCh, 00h,0A8h, 00h,0FCh
		db	 2Eh, 01h, 2Ah, 2Eh, 03h, 03h
		db	 00h, 02h, 2Eh, 03h,0C0h, 00h
		db	 80h, 2Eh, 00h, 03h, 00h, 02h
		db	 2Eh, 03h, 3Ch, 00h, 20h,0B7h
		db	 00h, 20h, 00h, 01h, 80h, 01h
		db	0C8h, 06h, 10h, 06h,0DBh, 18h
		db	 30h, 1Dh,0BCh, 0Fh, 80h, 26h
		db	 2Bh,0EAh,0AEh, 40h, 00h, 7Ch
		db	 00h, 0Fh,0C0h, 3Ah, 80h, 3Fh
		db	0EAh, 2Ah, 00h, 3Fh, 2Eh, 01h
		db	 80h, 00h,0C0h, 00h,0E0h, 2Eh
		db	 00h,0A8h,0CBh,0FCh,0F8h,0B2h
		db	 62h,0F3h,0EAh, 82h,0FCh, 07h
		db	0AAh,0A8h,0FFh, 3Ch, 2Ah, 00h
		db	0BFh, 2Eh, 01h,0A8h, 2Eh, 03h
		db	 03h, 0Ch, 02h, 08h, 2Eh, 06h
		db	 30h, 00h, 20h, 00h, 53h, 00h
		db	 75h, 00h,0C0h, 00h, 80h, 00h
data_10		db	3			; Data table (indexed access)
		db	 2Eh, 01h, 01h, 80h, 01h,0C8h
		db	 06h, 10h, 06h,0DBh, 18h, 30h
		db	 1Dh,0BCh, 0Fh, 80h, 26h, 2Bh
		db	0EAh,0AEh, 40h, 00h
data_11		db	7Ch			; Data table (indexed access)
		db	 00h, 0Fh,0C0h, 3Ah, 00h, 3Fh
		db	0AAh,0A8h, 00h,0FCh, 02h, 2Eh
		db	 00h, 80h, 00h,0C0h, 28h,0E0h
		db	 3Ch, 00h,0B2h,0CBh,0F3h,0F8h
		db	 82h, 62h,0C7h,0BAh,0A8h,0FCh
		db	 3Ch, 2Ah, 80h,0BFh, 00h, 0Ah
		db	 80h,0AFh,0C0h, 2Eh, 00h,0A0h
		db	 2Eh, 00h, 0Ch, 00h, 08h, 00h
		db	0C0h, 00h, 80h, 00h, 03h, 00h
		db	 02h, 2Eh, 0Ah, 03h, 00h, 02h
		db	 00h,0C0h, 00h, 80h, 00h, 01h
		db	 80h, 01h,0C8h, 06h, 10h, 06h
		db	0DBh, 18h, 30h, 1Dh,0BCh, 0Fh
		db	 80h, 26h, 2Bh,0EAh,0AEh, 3Fh
		db	0C0h,0BAh,0AAh,0FFh,0C0h,0A8h
		db	 00h,0FFh,0AAh, 2Eh, 01h,0EEh
		db	 00h, 28h, 80h, 3Ch,0C0h,0B2h
		db	0E0h,0F3h, 00h, 82h,0CBh,0C7h
		db	0F8h,0A8h, 62h,0FCh,0AAh,0A0h
		db	 00h, 30h, 3Ah, 80h,0BFh, 00h
		db	 0Ah, 80h,0AFh,0C0h, 02h,0A0h
		db	 83h,0C6h, 00h, 00h,0A0h, 00h
		db	0F0h, 00h, 80h, 00h, 03h, 00h
		db	 02h, 2Eh, 08h, 03h, 00h, 02h
		db	0B7h, 00h, 9Ah, 00h, 2Eh, 02h
		db	 01h, 80h, 01h,0C8h, 06h, 10h
		db	 06h,0DBh, 18h, 30h, 1Dh,0BCh
		db	 0Ah, 80h, 2Fh, 2Bh,0EEh,0AEh
		db	 3Fh,0C0h,0AAh, 2Ah, 3Fh, 2Eh
		db	 01h, 03h,0AAh, 2Eh, 00h, 03h
		db	0A0h, 2Eh, 00h, 80h, 00h,0C0h
		db	 28h,0E0h, 3Ch, 00h,0B2h,0CBh
		db	0F3h,0F8h, 82h, 62h,0C7h,0AAh
		db	0E8h, 00h, 3Ch,0BAh, 80h,0FFh
		db	 00h, 2Ah, 00h,0BFh, 00h, 0Ah
		db	 80h, 0Fh,0C0h, 2Eh, 0Bh, 1Fh
		db	 2Eh, 01h,0FDh, 2Eh, 00h, 03h
		db	0FEh, 2Eh, 00h, 06h,0F8h, 2Eh
		db	 00h, 0Dh,0E8h, 00h, 05h, 01h
		db	 80h, 01h,0C8h, 06h, 10h, 06h
		db	0DBh, 18h, 30h, 1Dh,0BCh, 0Fh
		db	 80h, 26h, 2Bh,0EAh,0AEh, 4Fh
		db	0C0h,0AEh,0AAh, 0Fh,0C0h, 0Ah
		db	 80h, 0Fh,0EAh, 2Eh, 00h, 0Eh
		db	 80h, 2Eh, 00h, 80h, 00h,0C0h
		db	 00h,0E0h, 2Eh, 00h, 28h,0CBh
		db	 3Ch,0F8h,0B2h, 62h,0F3h,0AAh
		db	 82h, 00h, 07h,0BAh,0A8h,0FCh
		db	 3Ch, 2Ah, 00h,0BFh, 00h, 2Ah
		db	 00h, 3Fh, 2Eh, 0Bh,0D0h, 2Eh
		db	 01h, 52h, 2Eh, 01h, 8Ah, 40h
		db	 2Eh, 01h, 20h, 2Eh, 01h, 10h
		db	0A0h, 00h, 01h, 80h, 01h,0C8h
		db	 06h, 10h, 06h,0DBh, 18h, 30h
		db	 1Dh,0BCh, 0Fh, 80h, 26h, 2Bh
		db	0EAh,0AEh, 4Fh,0C0h,0ABh,0AAh
		db	 0Fh,0F0h, 02h,0A0h, 0Fh,0FAh
		db	 2Eh, 00h, 3Ah, 2Eh, 01h, 80h
		db	 00h,0C0h, 28h,0E0h, 3Ch, 00h
		db	0B2h,0CBh,0F3h,0F8h, 82h, 62h
		db	0C7h,0AAh,0A8h, 00h, 3Ch,0AAh
		db	 80h,0FCh, 00h,0E8h, 00h,0FCh
		db	 00h,0A8h, 00h,0FCh, 00h, 0Dh
		db	 90h, 00h, 03h, 0Dh, 40h, 00h
		db	 05h, 06h, 40h, 2Eh, 00h, 03h
		db	 2Eh, 02h,0A0h, 2Eh, 01h, 15h
		db	 2Eh, 08h, 28h, 06h, 3Ch, 07h
		db	0B2h, 00h,0F3h, 0Eh, 82h, 00h
		db	0C7h,0EAh, 2Ah, 3Eh, 3Fh, 98h
		db	 0Bh,0AAh, 0Ch, 00h, 02h,0AAh
		db	 00h, 3Fh, 00h, 3Ah, 00h, 3Fh
		db	 00h, 0Ah, 00h, 0Fh, 2Eh, 00h
		db	 33h, 2Eh, 01h,0AEh,0C0h, 2Eh
		db	 00h, 72h, 38h, 03h,0E0h,0A9h
		db	 88h,0BAh,0AAh, 2Eh, 00h, 7Ch
		db	 00h, 03h,0F0h, 03h,0A0h,0ABh
		db	0F0h, 8Ah, 80h,0CFh,0C0h, 2Eh
		db	 03h, 06h, 00h, 07h, 0Ah, 00h
		db	 0Fh, 0Eh, 32h, 00h, 33h,0EAh
		db	 02h, 3Eh, 27h, 98h, 0Bh,0AAh
		db	 0Ch, 00h, 02h,0AAh, 00h, 3Fh
		db	 00h, 0Eh, 00h, 0Fh, 60h, 00h
		db	0F8h, 2Eh, 01h, 23h, 2Eh, 01h
		db	0AEh,0C0h, 2Eh, 00h, 72h, 38h
		db	 03h,0E0h,0A9h, 88h,0BAh,0AAh
		db	 2Eh, 00h, 7Ch, 00h, 03h,0F0h
		db	 8Bh, 80h,0EFh,0C0h, 2Eh, 03h
		db	 06h, 00h, 07h, 2Eh, 01h, 0Eh
		db	 02h, 00h, 03h,0EAh, 0Ah, 3Eh
		db	 0Fh, 98h, 0Bh,0AAh, 0Ch, 00h
		db	 02h, 8Ah, 00h, 2Fh, 2Eh, 01h
		db	 0Ah, 60h, 00h,0F8h, 2Eh, 01h
		db	 23h, 2Eh, 01h,0AEh,0C0h, 2Eh
		db	 00h, 72h, 38h, 03h,0E0h,0A9h
		db	 88h,0BAh,0AAh, 2Eh, 00h,0AAh
		db	 8Ah, 03h,0E0h, 2Eh, 00h,0AAh
		db	 80h, 2Eh, 03h, 06h, 00h, 07h
		db	 2Eh, 01h, 0Eh, 2Eh, 01h,0EAh
		db	 00h, 3Eh, 00h, 98h, 03h,0AAh
		db	 2Eh, 00h, 02h, 80h, 00h, 20h
		db	 2Eh, 01h, 0Ah, 60h, 00h,0F8h
		db	 2Eh, 01h, 23h, 2Eh, 01h,0AEh
		db	0C0h, 2Eh, 00h, 72h, 38h, 03h
		db	0E0h,0A9h, 88h,0BAh,0AAh, 2Eh
		db	 00h,0A8h, 0Ah, 00h, 20h, 2Eh
		db	 00h,0AAh, 80h, 2Eh, 1Bh, 03h
		db	 00h, 03h, 2Eh, 16h, 32h, 00h
		db	 3Bh,0A0h, 00h, 28h, 29h, 80h
		db	 00h, 0Ah, 00h, 0Fh, 00h, 20h
		db	 00h, 33h, 00h, 20h, 00h, 3Ch
		db	 00h, 03h, 00h, 03h, 00h, 0Eh
		db	 00h, 3Ch, 00h, 38h, 2Eh, 01h
		db	 38h, 00h, 02h, 2Eh, 02h, 03h
		db	0A8h,0CBh, 00h, 0Eh, 00h, 2Ch
		db	 20h, 0Ah, 00h, 80h,0A0h,0A8h
		db	 00h, 02h, 00h, 20h, 00h, 08h
		db	 2Eh, 01h,0A0h, 2Eh, 10h, 38h
		db	 2Eh, 00h, 03h, 28h, 03h, 80h
		db	 08h,0E0h, 0Eh, 08h, 30h,0E0h
		db	 38h,0C2h, 20h,0A0h, 3Ah, 02h
		db	 90h, 28h,0DEh, 82h, 88h, 38h
		db	0E8h, 02h, 00h, 28h, 8Eh, 82h
		db	 30h,0E0h, 3Ah,0C2h, 20h,0E0h
		db	 28h, 02h, 00h,0A0h, 03h, 08h
		db	 00h, 28h, 02h, 80h, 00h, 28h
		db	 2Eh, 0Dh,0F0h, 00h,0C0h, 03h
		db	0E0h, 03h, 00h, 0Ch, 28h, 0Eh
		db	 80h,0BBh, 00h, 3Eh, 82h, 68h
		db	 28h, 6Fh, 82h

locloop_2:
;*		and	al,0E2h
		db	 80h,0E0h,0E2h		;  Fixup - byte match
		retn	0E0C8h
			                        ;* No entry point to code
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		add	al,[bx+si]
		mov	al,data_7
		add	[bx+si],ch
		sub	ax,ss:data_22e[bp+si]
		push	cs
;*		add	byte ptr [bx+si],28h	; '('
		db	 82h, 00h, 28h		;  Fixup - byte match
		or	al,ds:data_30e[bx+si]
;*		add	al,[bx+si+0]
		db	 02h, 40h, 00h		;  Fixup - byte match
		db	0E0h, 2Eh, 05h, 10h,0C0h, 2Eh
		db	 00h, 10h,0A0h, 2Eh, 00h, 20h
		db	 2Eh, 01h, 40h, 2Eh, 00h, 02h
		db	 2Eh, 01h, 50h, 2Eh, 09h, 01h
		db	 80h, 01h,0C8h, 06h, 10h, 06h
		db	0DBh, 18h, 30h, 1Dh,0BCh, 0Fh
		db	 80h, 36h, 2Bh,0EAh,0BAh, 40h
		db	 00h, 7Ch, 00h, 0Fh,0C0h, 0Ah
		db	0C0h, 0Fh,0EAh, 02h,0A2h, 03h
		db	0F3h, 00h, 28h, 80h, 3Ch,0C0h
		db	0B2h,0E0h,0F3h, 00h, 82h,0CBh
		db	0C7h,0F8h,0A8h, 62h,0FCh,0AAh
		db	0A0h, 00h, 30h,0AAh, 80h,0FCh
		db	 00h,0ACh, 00h,0FCh, 00h,0A0h
		db	 00h,0F0h, 2Eh, 00h, 10h, 00h
		db	 3Fh, 01h, 80h, 01h,0C8h, 06h
		db	 10h, 06h,0DBh, 18h, 30h, 1Dh
		db	0BCh, 0Fh, 80h, 36h, 2Bh,0EAh
		db	0BAh, 40h, 00h, 7Ch, 00h, 0Fh
		db	0C0h, 02h,0E2h, 03h,0FBh, 2Eh
		db	 04h, 80h, 00h,0C0h,0A0h,0E0h
		db	0F0h, 00h,0B0h,0CBh,0F8h,0F8h
		db	 80h, 62h,0C4h,0AAh,0A0h, 00h
		db	 30h,0AAh, 80h,0FCh, 00h,0B0h
		db	 00h,0F0h, 2Eh, 00h, 10h, 00h
		db	 3Fh, 01h, 80h, 01h,0C8h, 06h
		db	 10h, 06h,0DBh, 18h, 30h, 1Dh
		db	0BCh, 0Fh, 80h, 36h, 2Bh,0EAh
		db	0BAh, 40h, 00h,0A2h,0AAh, 0Bh
		db	0C0h, 2Eh, 00h, 02h,0AAh, 2Eh
		db	 04h, 80h, 00h,0C0h, 00h,0E0h
		db	 2Eh, 00h, 80h,0CBh,0C0h,0F8h
		db	0A0h, 62h,0F0h,0AAh,0A0h, 00h
		db	 30h,0A2h, 80h,0F8h, 2Eh, 01h
		db	0A0h, 2Eh, 00h, 10h, 00h, 3Fh
		db	 01h, 80h, 01h,0C8h, 06h, 10h
		db	 06h,0DBh, 18h, 30h, 1Dh,0BCh
		db	 0Fh, 80h, 36h, 2Bh,0EAh,0BAh
		db	 40h, 00h,0A0h, 2Ah, 08h, 2Eh
		db	 01h, 02h,0AAh, 2Eh, 04h, 80h
		db	 00h,0C0h, 00h,0E0h, 2Eh, 01h
		db	0CBh, 00h,0F8h, 00h, 62h, 00h
		db	0AAh, 80h, 2Eh, 00h, 02h
data_12		db	80h			; Data table (indexed access)
		db	 08h, 2Eh, 01h,0A0h, 2Eh, 17h
		db	 04h, 30h, 0Fh, 3Ch, 30h, 01h
		db	 3Ah, 3Dh, 2Eh, 1Ch, 80h, 00h
		db	 3Ah, 86h, 20h, 27h, 00h,0A0h
		db	 08h, 0Dh, 00h,0E0h, 0Ah, 42h
		db	 00h, 3Ah, 00h, 80h, 00h, 0Dh
		db	 00h, 21h, 2Eh, 01h, 0Ah, 2Eh
		db	 08h,0B0h, 2Eh, 01h, 80h, 2Eh
		db	 01h, 38h, 00h, 80h, 2Eh, 01h
		db	0A0h, 00h, 88h, 00h, 38h, 2Eh
		db	 01h, 38h, 00h, 80h, 2Eh, 0Bh
		db	 38h, 00h, 30h, 00h, 28h, 00h
		db	 02h,0C0h, 0Eh, 00h, 20h,0B0h
		db	 0Eh, 00h, 80h, 2Ch, 0Ah, 00h
		db	 80h,0BCh, 38h, 00h,0B2h, 5Bh
		db	 38h, 00h,0A0h,0DBh, 28h, 00h
		db	 82h, 5Bh, 0Ah, 00h, 80h,0BCh
		db	 0Eh, 00h, 80h, 28h, 0Eh, 00h
		db	 20h,0A0h, 38h, 00h, 22h, 80h
		db	 38h, 2Eh, 0Dh, 0Fh, 2Eh, 01h
		db	 0Eh, 2Eh, 00h,0C0h, 38h, 00h
		db	 33h,0B0h, 38h, 00h

locloop_3:
		mov	ds:data_24e,al
		add	ss:data_14[bp+si],al
		add	data_16[bx+si],al
		add	data_17[bx+si],al
		add	ds:data_28e[bx+si],al
		add	ss:data_29e[bp+di],dh
		add	ss:data_23e[bp+si],ah
		add	[bp+si],al
		mov	al,0Eh
		add	cs:data_25e[bx+si],al
		push	ss
		adc	[bx+si],al
		sbb	ds:data_21e,ch
;*		add	ax,cs:[si+0]
		db	 2Eh, 03h, 44h, 00h	;  Fixup - byte match
		db	 66h, 2Eh, 02h, 0Ch, 00h, 0Eh
		db	 2Eh, 01h, 01h, 2Eh, 03h,0C0h
		db	 00h,0F0h, 2Eh, 01h, 58h, 2Eh
		db	 00h, 80h, 01h,0C0h, 52h, 2Eh
		db	 00h, 60h, 00h, 02h, 00h,0C8h
		db	 00h, 0Ah, 2Eh, 00h, 02h, 00h
		db	 03h,0E2h, 0Ah, 3Eh, 0Fh, 98h
		db	 0Bh,0AAh, 0Ch, 00h, 02h, 8Ah
		db	 00h, 2Fh, 00h, 34h, 00h, 3Eh
		db	 00h, 68h, 00h, 78h,0C4h, 00h
		db	 38h, 80h,0FBh, 2Eh, 01h, 30h
		db	 00h, 02h, 38h, 03h,0E0h, 89h
		db	 88h,0BAh,0AAh, 2Eh, 00h,0AAh
		db	0CAh, 03h,0E0h, 01h,0A0h

locloop_4:
		stosw				; Store ax to es:[di]
		loopnz	locloop_5		; Loop if zf=0, cx>0


locloop_5:
		test	al,0
		clc				; Clear carry flag
		add	[bx+si],dl
;*		add	cs:[bp+si+0],ax
		db	 2Eh, 01h, 42h, 00h	;  Fixup - byte match
		db	 30h,0E7h, 00h, 00h, 40h, 02h
		db	 21h, 2Eh, 00h, 08h, 18h, 2Eh
		db	 00h, 04h, 4Ah, 00h, 03h, 16h
		db	 15h, 18h, 04h, 01h, 13h, 10h
		db	 00h, 80h, 2Eh, 01h,0C4h, 2Eh
		db	 00h, 1Ch,0D2h, 00h, 07h, 06h
		db	 6Ah, 00h, 01h, 80h,0F0h, 80h
		db	 2Eh, 00h,0F8h, 88h, 00h, 18h
		db	 69h, 80h, 00h, 08h,0DAh, 84h
		db	 2Eh, 01h, 45h, 2Eh, 01h, 1Fh
		db	 2Eh, 00h, 10h, 8Bh, 2Eh, 00h
		db	 03h,0CFh, 02h, 20h, 4Eh,0FFh
		db	 0Bh, 00h, 0Bh,0FBh, 0Ch, 00h
		db	 22h,0FFh, 00h, 18h, 03h,0FFh
		db	 03h, 64h,0D6h, 2Eh, 01h,0E6h
		db	 98h, 2Eh, 00h,0FFh, 41h, 2Eh
		db	 00h,0F7h,0ACh, 00h, 10h,0FFh
		db	0F8h, 2Eh, 00h,0FEh,0EFh, 2Eh
		db	 00h,0FFh,0CAh, 02h, 60h, 63h
		db	0BCh, 89h,0FCh, 00h, 01h, 2Eh
		db	 01h, 10h, 2Eh, 00h, 10h, 2Eh
		db	 01h, 01h, 2Eh, 06h, 01h, 2Eh
		db	 00h, 20h, 04h, 2Eh, 01h, 2Bh
		db	 2Eh, 08h, 02h, 2Eh, 06h, 08h
		db	 2Eh, 00h, 04h, 2Eh, 01h, 01h
		db	 2Eh, 01h,0A0h, 2Eh, 02h,0BFh
		db	 2Eh, 01h, 44h, 2Eh, 00h, 08h
		db	 88h, 2Eh, 00h, 20h, 2Eh, 02h
		db	 40h, 2Eh, 00h, 48h, 05h, 48h
		db	 00h, 06h, 88h, 06h, 00h, 14h
		db	 57h, 14h, 00h, 28h, 08h, 2Eh
		db	 00h, 72h, 2Eh, 01h, 04h, 80h
		db	 2Eh, 00h, 88h, 04h, 2Eh, 00h
		db	 49h, 40h, 2Eh, 00h, 14h, 2Eh
		db	 01h, 01h, 32h, 00h, 10h,0D5h
		db	 64h, 00h, 64h, 2Eh, 1Bh,0FFh
		db	 00h, 55h, 2Eh, 1Ah,0FFh, 00h
		db	 55h, 00h, 0Fh,0FFh, 05h, 40h
		db	 3Fh,0FFh, 14h, 05h, 3Fh,0FFh
		db	 10h
		db	55h
data_13		dw	4Dh			; Data table (indexed access)
		db	0DFh, 00h, 4Dh, 00h,0DFh, 00h
		db	 4Dh, 00h, 55h, 57h, 3Fh,0FFh
		db	 3Fh,0FFh, 0Fh,0FFh, 0Fh, 4Dh
		db	 00h,0F0h, 51h,0F0h,0FFh,0FCh
		db	 55h,0FCh,0FFh,0FCh, 57h,0FCh
		db	0FFh,0FAh, 57h,0FAh,0FFh,0FAh
		db	 7Fh,0FAh,0FFh,0EAh,0FFh,0EAh
		db	0FEh,0A8h,0FEh,0A8h,0EAh,0A0h
		db	0EAh,0A0h, 2Eh, 1Bh, 0Fh, 00h
		db	 05h, 2Eh, 0Bh, 1Fh, 2Eh, 01h
		db	0FDh, 2Eh, 00h, 03h,0FEh, 2Eh
		db	 00h, 06h,0F8h, 00h, 05h, 0Dh
		db	0E8h, 00h, 13h, 00h,0FFh, 00h
		db	 50h, 0Fh,0FFh, 05h, 01h, 3Fh
		db	0FFh, 14h, 15h, 3Fh,0FFh, 15h
		db	 55h, 4Dh, 00h,0DFh, 00h, 4Dh
		db	 00h, 55h, 5Fh, 3Fh,0FFh, 3Fh
		db	0FFh, 0Fh,0FFh, 0Fh, 4Dh, 00h
		db	0F0h, 15h,0F0h,0FFh,0FCh, 55h
		db	0FCh,0FFh,0FCh, 57h,0FCh,0FFh
		db	0FAh, 57h,0FAh,0FFh,0FAh, 7Fh
		db	0FAh,0FFh,0EAh,0FFh,0EAh,0FEh
		db	0A8h,0FEh,0A8h,0AAh,0A0h,0AAh
		db	0A0h, 2Eh, 17h, 0Fh, 00h, 05h
		db	 00h,0FFh, 00h, 54h, 2Eh, 16h
data_14		db	0F0h			; Data table (indexed access)
		db	 00h, 50h, 00h,0FFh, 00h, 15h
		db	 00h, 03h,0FFh, 01h, 41h, 0Fh
		db	0FFh, 05h, 05h, 0Fh,0FFh, 04h
		db	 15h, 3Fh,0FFh, 15h, 55h, 3Fh
		db	0FFh, 15h, 55h, 3Fh,0FFh, 15h
		db	 57h, 0Fh,0FFh, 0Fh,0FFh, 03h
		db	0FFh, 03h, 4Dh, 00h,0C0h, 55h
		db	0C0h,0FFh,0F0h, 55h,0F0h,0FFh
		db	0F0h, 57h,0F0h,0FFh,0E8h, 5Fh
		db	0E8h,0FFh,0E8h, 7Fh,0E8h,0FFh
		db	0A8h,0FFh,0A8h,0FAh,0A0h,0FAh
		db	0A0h,0AAh, 80h,0AAh, 80h, 2Eh
		db	 0Ah,0D0h, 2Eh, 01h, 52h, 2Eh
		db	 01h, 8Ah, 40h, 2Eh, 01h, 20h
		db	 50h, 2Eh, 00h, 10h,0A8h, 2Eh
		db	 1Bh,0F0h, 00h, 50h, 00h, 0Fh
		db	0FFh, 05h, 05h, 3Fh,0FFh, 14h
		db	 15h, 3Fh,0FFh, 10h, 55h, 4Dh
		db	 00h,0DFh, 00h, 4Dh, 00h,0DFh
		db	 00h, 4Dh, 00h, 55h, 7Fh, 3Fh
		db	0FFh, 3Fh,0FFh, 0Fh,0FFh, 0Fh
		db	 4Dh, 00h, 00h, 55h, 00h,0FFh
		db	0F0h, 57h,0F0h,0FFh,0FCh, 57h
		db	0FCh,0FFh,0FCh, 5Fh,0FCh,0FFh
		db	0FAh,0FFh,0FAh,0FFh,0EAh,0FFh
		db	0EAh,0FAh,0A8h,0FAh,0A8h,0AAh
		db	0A0h,0AAh,0A0h, 2Eh, 1Bh,0FEh
		db	 00h, 5Eh, 0Dh, 90h, 00h, 2Fh
		db	 0Dh, 40h, 00h, 17h, 06h, 40h
		db	 00h, 0Ah, 03h, 2Eh, 02h,0A0h
		db	 2Eh, 01h, 15h, 2Eh, 08h, 0Fh
		db	0FFh, 05h, 07h, 3Fh,0FFh, 10h
		db	 55h, 3Fh,0FFh, 11h, 55h, 4Dh
		db	 00h, 55h, 57h, 4Dh, 00h, 55h
		db	 57h, 4Dh, 00h, 55h, 5Fh, 3Fh
		db	0FEh, 3Fh,0FEh, 0Fh,0EAh, 0Fh
		db	0EAh,0FFh,0F0h, 41h,0F0h,0FFh
		db	0FCh, 15h,0FCh,0FFh,0FCh, 55h
		db	0FCh,0FFh,0FAh, 57h,0FAh,0FFh
		db	0FAh, 5Fh,0FAh,0FFh,0EAh,0FFh
		db	0EAh,0FFh,0A8h,0FFh,0A8h,0BAh
		db	0A0h,0BAh,0A0h, 2Eh, 16h, 0Fh
		db	0C0h, 0Fh,0C0h, 3Fh,0FCh, 34h
		db	 5Ch, 2Eh, 16h, 03h,0F0h, 03h
		db	0F0h, 3Fh,0FCh, 34h, 1Ch, 3Fh
		db	0FFh, 11h, 5Fh,0FFh,0FEh, 41h
		db	 5Eh,0FFh,0FEh, 45h, 7Eh,0FFh
		db	0FBh, 55h, 7Bh,0FFh,0FAh, 55h
		db	0FAh,0FFh,0EBh, 5Fh,0EBh, 3Fh
		db	0A8h, 3Fh,0A8h, 0Eh,0A0h, 0Eh
		db	0A0h,0FFh,0FCh,0D1h, 54h, 4Dh
		db	 00h,0D5h, 57h, 4Dh, 00h,0D5h
		db	 5Fh,0FFh,0FEh,0F5h, 5Eh,0FFh
		db	0FEh,0FDh, 7Eh,0BFh,0FAh,0BFh
		db	0FAh, 2Fh,0E8h, 2Fh,0E8h, 0Eh
		db	0A0h, 0Eh,0A0h, 00h, 10h,0D0h
		db	 2Eh, 00h, 10h,0A8h, 2Eh, 00h
		db	 20h, 40h, 2Eh, 00h, 40h, 2Eh
		db	 00h, 02h, 2Eh, 01h, 50h, 2Eh
		db	 21h,0FFh,0C0h, 55h, 40h,0FFh
		db	0F0h, 05h, 50h, 00h, 3Fh, 00h
		db	 14h, 00h,0FFh, 00h, 51h, 03h
		db	0FFh, 01h, 45h, 03h,0FFh, 01h
		db	 55h, 03h,0FFh, 01h, 55h, 03h
		db	0FFh, 03h, 57h, 00h,0FFh, 00h
		db	0FFh, 00h, 3Fh, 00h, 3Fh,0FFh
		db	0FCh, 15h, 54h, 4Dh, 00h, 55h
		db	 5Fh, 4Dh, 00h, 55h, 7Fh,0FFh
		db	0FEh, 55h,0FEh,0FFh,0FEh, 5Fh
		db	0FEh,0FFh,0FAh,0FFh,0FAh,0FFh
		db	0AAh,0FFh,0AAh,0EAh,0A8h,0EAh
		db	0A8h, 2Eh, 16h, 03h,0FFh, 01h
		db	 55h, 0Fh,0FFh, 05h, 10h, 2Eh
		db	 0Bh, 1Fh, 2Eh, 01h,0FDh, 2Eh
		db	 00h, 03h,0FEh, 00h, 01h, 06h
		db	0F8h, 00h, 07h, 0Dh,0E9h, 00h
		db	 16h, 3Fh,0FFh, 14h, 05h, 4Dh
		db	 00h, 50h, 55h, 4Dh, 00h, 54h
		db	 55h, 4Dh, 00h,0DFh, 00h, 4Dh
		db	 00h,0D5h, 55h, 4Dh, 00h,0FDh
		db	 57h,0BFh,0FFh,0BFh,0FFh, 2Fh
		db	0FAh, 2Fh,0FAh,0FCh, 00h, 54h
		db	 00h,0FFh, 00h, 57h, 00h,0FFh
		db	 80h, 5Fh, 80h,0FFh, 80h, 5Fh
		db	 80h,0FEh, 80h,0FEh, 80h,0FAh
		db	 80h,0FAh, 80h,0EAh, 00h,0EAh
		db	 00h,0A8h, 00h,0A8h, 2Eh, 14h
		db	 03h, 2Eh, 01h, 07h, 2Eh, 01h
		db	 0Fh, 00h, 05h, 2Eh, 12h, 80h
		db	 2Eh, 01h,0C0h, 00h,0C0h, 00h
		db	0B4h, 01h, 00h, 03h,0FBh, 00h
		db	 3Bh, 07h,0F7h, 01h,0F7h, 01h
		db	 5Bh, 01h, 5Bh, 03h,0FFh, 03h
		db	0C7h, 1Eh,0FBh, 06h,0D3h, 3Dh
		db	 77h, 0Dh, 74h, 07h,0BFh, 03h
		db	0BDh, 1Dh, 3Dh, 05h, 3Dh, 5Bh
		db	0E0h, 5Ah,0E0h,0EFh, 80h,0EFh
		db	 80h,0F5h, 00h, 05h, 00h,0F7h
		db	0B8h, 37h, 88h,0AFh,0F8h,0AFh
		db	0F8h,0FFh, 40h, 7Fh
		db	40h
		db	0BDh,0F0h,0BDh,0B0h,0D5h, 00h
		db	0D5h, 2Eh, 08h, 03h, 2Eh, 01h
		db	 27h, 00h, 20h, 00h, 07h, 00h
		db	 03h, 00h, 03h, 00h, 03h, 1Eh
		db	 41h, 02h, 41h, 1Eh, 01h, 06h
		db	 01h, 2Eh, 06h, 80h, 2Eh, 01h
		db	0C0h, 00h,0C0h, 00h,0C0h, 00h
		db	0C0h, 00h, 80h, 1Ch, 80h, 00h
		db	 08h, 3Ch, 08h, 0Ch, 00h, 38h
		db	 00h, 38h, 03h, 83h, 03h, 83h
		db	 41h,0D2h, 41h,0D2h, 11h,0A6h
		db	 11h,0A6h, 00h, 78h, 2Eh, 00h
		db	0D6h,0FCh, 12h, 9Ch, 59h, 69h
		db	 59h, 68h, 05h, 91h, 05h, 90h
		db	0B0h, 24h, 10h, 24h,0A0h,0C0h
		db	0A0h,0C0h, 82h, 80h, 82h, 80h
		db	0D2h, 0Eh,0D2h, 00h, 26h, 1Fh
		db	 26h, 0Bh, 03h, 64h, 03h, 64h
		db	0CCh, 2Eh, 01h,0CDh, 93h,0CDh
		db	 83h, 8Ah, 80h, 8Ah, 80h, 00h
		db	 03h, 00h, 03h, 20h, 02h, 20h
		db	 02h, 00h, 01h, 00h, 01h, 40h
		db	 80h, 40h, 80h,0A0h, 01h,0A0h
		db	 01h, 70h, 01h, 70h, 01h, 08h
		db	 00h, 08h, 00h, 02h, 00h, 02h
		db	 2Eh, 03h, 80h, 00h, 80h, 2Eh
		db	 00h, 20h, 00h, 20h, 00h, 02h
		db	 00h, 02h, 00h, 0Ch, 00h, 0Ch
		db	 04h, 02h, 04h, 02h, 00h, 10h
		db	 00h, 10h, 14h, 00h, 14h, 2Eh
		db	 03h, 20h, 41h, 20h, 41h, 2Eh
		db	 02h, 01h, 00h, 01h, 00h, 13h
		db	 00h, 13h, 00h, 82h, 00h, 82h
		db	 2Eh, 03h, 40h, 22h, 40h, 22h
		db	 03h, 00h, 03h, 2Eh, 00h, 90h
		db	 00h, 90h, 00h, 82h, 00h, 82h
		db	 00h, 05h, 00h, 05h, 2Eh, 03h
		db	 10h, 00h, 10h, 00h, 05h, 00h
		db	 05h, 2Eh, 04h, 52h, 84h, 00h
		db	 06h, 73h,0C0h, 40h, 06h, 23h
		db	 41h, 63h, 02h, 10h,0C5h, 42h
		db	 00h, 21h, 83h, 00h, 40h, 23h
		db	 03h, 00h, 80h, 22h, 43h, 01h
		db	 2Eh, 00h, 82h, 2Eh, 00h,0A8h
		db	 54h, 2Eh, 00h,0A0h, 70h, 40h
		db	 64h, 30h, 10h, 20h, 4Ch, 92h
		db	 20h, 10h, 30h,0C0h, 08h, 00h
		db	 20h, 46h, 18h, 64h, 00h, 02h
		db	 30h, 82h, 10h, 40h, 28h, 00h
		db	 87h
data_15		dw	8000h
		db	 2Eh, 01h, 81h, 2Eh, 18h,0C2h
		db	 18h, 2Eh, 00h,0C0h, 10h, 2Eh
		db	 00h,0C0h, 10h, 2Eh, 00h, 80h
		db	 2Eh, 01h, 80h, 2Eh, 0Eh, 01h
		db	 2Eh, 00h, 21h, 2Eh, 01h, 03h
		db	 02h, 2Eh, 00h
		db	61h
data_16		db	80h			; Data table (indexed access)
		db	 00h, 06h, 73h,0C0h, 40h, 06h
		db	 23h,0C1h, 63h, 02h, 10h,0C5h
		db	 42h, 00h, 21h, 83h, 2Eh, 04h
		db	 20h, 10h, 2Eh, 00h, 60h, 04h
		db	 2Eh, 00h,0E2h, 1Ch, 2Eh, 00h
		db	0E2h, 4Ch, 40h, 64h, 30h, 10h
		db	 20h, 4Ch, 92h, 20h, 10h, 30h
		db	0C0h, 08h, 00h, 40h, 23h, 03h
		db	 00h, 80h, 22h, 43h, 01h, 2Eh
		db	 00h, 82h, 00h, 87h, 00h, 80h
		db	 2Eh, 01h, 81h, 2Eh, 0Bh, 20h
		db	 46h, 18h, 64h, 00h, 02h, 30h
		db	 82h, 10h, 40h, 28h, 2Eh, 00h
		db	0C2h, 18h, 2Eh, 00h,0C0h, 10h
		db	 2Eh, 00h,0C0h, 10h, 2Eh, 00h
		db	 80h, 2Eh, 01h, 80h, 2Eh, 05h
		db	 01h, 2Eh, 01h, 03h, 2Eh, 01h
		db	 61h, 82h, 00h, 06h, 73h,0C0h
		db	 40h, 06h, 23h,0C1h, 63h, 02h
		db	 10h,0C5h, 42h, 00h,0A9h,0B3h
		db	 2Eh, 04h, 20h, 2Eh, 01h, 60h
		db	 04h, 2Eh, 00h,0E0h, 1Ch, 2Eh
		db	 00h,0E0h, 4Ch, 40h, 64h, 30h
		db	 10h, 20h, 4Ch, 92h, 21h, 10h
		db	 00h,0C2h,0FAh, 2Eh, 15h, 08h
		db	 2Eh, 05h, 80h, 2Eh, 1Ch, 01h
		db	 2Eh, 02h, 04h, 2Eh, 00h, 10h
		db	 80h, 2Eh, 04h, 11h, 48h, 2Eh
		db	 00h,0ABh, 12h, 2Eh, 00h, 69h
		db	0A2h, 00h, 06h,0F7h,0D0h
data_17		db	40h			; Data table (indexed access)
		db	 06h,0AFh,0F9h, 2Eh, 00h, 10h
		db	 2Eh, 05h, 10h, 08h, 2Eh, 00h
		db	 80h, 10h, 2Eh, 00h, 60h, 82h
		db	 2Eh, 00h,0C4h, 18h, 2Eh, 00h
		db	0EAh,0CDh, 40h, 64h,0B5h, 90h
		db	 2Eh, 00h, 02h, 2Eh, 09h, 20h
		db	 06h, 2Eh, 01h, 02h, 2Eh, 00h
		db	 01h, 2Eh, 02h, 08h, 2Eh, 00h
		db	 80h, 04h, 2Eh, 00h, 20h, 80h
		db	 2Eh, 09h, 02h, 2Eh, 00h, 80h
		db	 20h, 2Eh, 00h, 10h, 2Eh, 02h
		db	 80h, 2Eh, 00h, 40h, 01h, 2Eh
		db	 01h, 14h, 2Eh, 01h, 81h, 2Eh
		db	 01h,0A0h, 2Eh, 00h, 02h, 79h
		db	 2Eh, 00h, 11h, 4Ah, 2Eh, 00h
		db	 03h, 10h, 2Eh, 00h, 49h, 22h
		db	 00h, 06h, 36h,0C0h, 2Eh, 01h
		db	 04h, 2Eh, 00h, 21h, 2Eh, 01h
		db	 04h, 2Eh, 01h, 20h,0C2h, 2Eh
		db	 00h, 04h,0C0h, 2Eh, 04h, 44h
		db	 18h, 2Eh, 00h,0BAh,0CCh, 2Eh
		db	 01h, 20h, 2Eh, 00h, 24h, 02h
		db	 00h, 40h, 15h, 04h, 00h, 40h
		db	 1Dh, 80h, 08h, 80h, 06h, 08h
		db	 0Ch, 80h, 01h, 00h, 06h, 80h
		db	 00h, 10h, 00h, 80h, 05h, 10h
		db	 02h, 80h, 01h, 40h, 01h, 00h
		db	 02h, 20h, 01h, 80h, 00h, 20h
		db	 01h, 2Eh, 00h, 40h, 00h, 80h
		db	 2Eh, 01h, 80h, 00h, 40h, 2Eh
		db	 01h, 80h, 2Eh, 01h, 80h, 2Eh
		db	 00h, 01h, 84h, 2Eh, 01h, 80h
		db	 2Eh, 00h, 80h, 2Eh, 01h, 04h
		db	 0Bh, 2Eh, 01h, 01h, 2Eh, 01h
		db	 80h, 2Eh, 00h, 10h, 04h, 2Eh
		db	 00h, 42h,0C0h, 2Eh, 00h, 01h
		db	 2Eh, 02h, 01h, 2Eh, 01h, 10h
		db	 2Eh, 04h, 08h, 80h, 2Eh, 01h
		db	 1Ah, 2Eh, 01h, 30h, 2Eh, 01h
		db	 91h, 2Eh, 00h, 02h, 20h, 2Eh
		db	 00h, 17h, 08h, 00h, 40h, 15h
		db	 14h, 00h, 40h, 1Dh, 90h, 08h
		db	 80h, 06h, 08h, 0Ch, 80h, 01h
		db	 00h, 06h, 80h, 00h, 10h, 00h
		db	 80h, 05h, 10h, 2Eh, 00h,0E0h
		db	 2Eh, 01h,0A8h, 2Eh, 01h,0A3h
		db	 80h, 2Eh, 00h, 8Eh,0A0h,0E0h
		db	 3Ch, 0Ah, 80h,0AAh,0A8h, 2Eh
		db	 00h, 0Ah, 80h, 2Eh, 02h,0AAh
		db	 2Eh, 02h, 03h, 00h, 20h, 00h
		db	 3Ah, 2Eh, 01h,0F2h, 2Eh, 00h
		db	 03h,0ACh, 0Fh, 03h, 00h,0A8h
		db	 0Eh,0AAh, 2Eh, 01h,0A8h
		db	2Eh
data_18		dw	2A03h			; Data table (indexed access)
		db	 2Eh, 00h, 80h, 2Eh, 01h,0A0h
		db	 2Eh, 01h, 8Eh, 2Eh, 01h, 3Ah
		db	 4Bh, 00h,0F0h, 2Ah, 00h,0AAh
		db	0A0h, 2Eh, 00h, 2Ah, 2Eh, 03h
		db	0A8h, 2Eh, 19h, 40h, 2Eh, 02h
		db	 20h, 2Eh, 01h, 10h, 2Eh, 03h
		db	 03h, 00h, 80h, 30h, 06h, 00h
		db	 31h, 16h, 06h, 09h, 81h, 40h
		db	 00h, 07h,0C3h, 2Eh, 00h, 19h
		db	0F2h, 2Eh, 00h, 47h, 7Bh, 2Eh
		db	 00h, 10h, 2Eh, 03h, 01h, 80h
		db	 20h, 00h, 03h, 00h, 80h, 08h
		db	 1Ch, 00h, 83h, 2Eh, 01h,0BAh
		db	 2Eh, 01h,0F5h, 88h, 2Eh, 00h
		db	0B8h, 01h, 2Eh, 17h, 0Eh, 00h
		db	 01h, 0Ah,0C9h, 00h, 14h, 2Eh
		db	 18h,0D0h, 00h, 83h, 50h, 28h
		db	 00h,0BEh,0C3h, 00h,0DAh, 0Ah
		db	0C1h, 00h,0DDh, 2Eh, 01h, 0Ah
		db	 2Eh, 12h,0C3h, 7Dh,0D3h, 00h
		db	 83h, 50h,0ABh, 2Eh, 01h, 90h
		db	 2Eh, 14h, 01h, 2Eh, 01h, 03h
		db	 2Eh, 01h, 03h, 2Eh, 01h, 06h
		db	 2Eh, 01h, 07h, 00h, 07h, 2Eh
		db	 01h, 0Eh, 00h, 18h, 00h, 04h
		db	 00h, 07h, 00h, 31h, 2Eh, 02h
		db	 80h, 2Eh, 01h, 80h, 2Eh, 01h
		db	0C0h, 2Eh, 01h, 40h, 00h, 40h
		db	 2Eh, 01h,0A0h, 2Eh, 01h, 50h
		db	 00h,0C0h, 00h, 48h, 2Eh, 00h
		db	 07h, 00h, 33h, 2Eh, 01h, 1Ch
		db	 2Eh, 01h, 0Ah, 00h, 05h, 00h
		db	 05h, 00h, 06h, 2Eh, 01h, 02h
		db	 2Eh, 01h, 02h, 2Eh, 01h, 01h
		db	 2Eh, 00h,0C0h, 00h,0C8h, 2Eh
		db	 01h
		db	50h
data_19		db	2Eh
		db	 01h,0A0h, 00h, 40h, 00h, 40h
		db	 00h, 40h, 2Eh, 01h, 80h, 2Eh
		db	 01h, 80h, 2Eh, 09h, 0Ch, 2Eh
		db	 01h, 07h, 80h, 2Eh, 00h, 01h
		db	0E0h, 2Eh, 01h,0D8h, 00h, 08h
		db	 00h, 6Eh, 00h, 21h, 00h, 09h
		db	 00h, 14h, 00h, 03h, 00h, 1Ah
		db	 2Eh, 14h,0D0h, 00h, 80h, 00h
		db	 28h, 00h,0C0h, 00h,0D0h, 2Eh
		db	 00h, 01h, 00h, 1Dh, 2Eh, 01h
		db	 0Ah, 2Eh, 16h, 80h, 00h,0A8h
		db	 00h, 07h, 00h, 97h, 00h, 0Dh
		db	 80h, 0Ch, 00h, 03h,0E0h, 2Eh
		db	 01h, 78h, 2Eh, 01h, 0Ch, 2Eh
		db	 1Dh, 0Dh, 00h, 02h, 00h, 19h
		db	 00h, 04h, 00h, 03h, 00h, 1Ah
		db	 2Eh, 03h, 30h, 2Eh, 00h, 01h
		db	0E0h, 2Eh, 00h, 07h, 80h, 2Eh
		db	 00h, 1Bh, 00h, 10h, 00h, 06h
		db	 00h,0D4h, 00h, 80h, 00h, 28h
		db	 00h,0C0h, 00h,0D0h, 2Eh, 00h
		db	 01h, 00h, 1Dh, 00h,0E0h, 00h
		db	0E5h, 01h,0B0h, 00h, 30h, 07h
		db	0C0h, 2Eh, 00h, 1Eh, 2Eh, 01h
		db	 30h, 2Eh, 09h, 80h, 00h,0A8h
		db	 2Eh, 01h, 50h, 2Eh, 1Ah, 80h
		db	 2Eh, 00h, 01h, 6Ah, 2Eh, 00h
		db	 10h, 76h, 2Eh, 00h, 0Ah, 5Eh
		db	 00h, 1Ch, 01h,0FEh, 00h, 3Eh
		db	 01h, 3Fh, 00h, 1Ch, 00h, 5Dh
		db	 2Eh, 01h, 1Fh, 2Eh, 02h, 0Ch
		db	 00h, 40h, 00h, 1Fh, 40h, 2Eh
		db	 00h, 3Fh,0F4h, 80h, 2Eh, 00h
		db	 5Dh, 40h, 2Eh, 01h,0D0h, 2Eh
		db	 01h,0FAh, 2Eh, 01h,0FCh, 2Eh
		db	 00h, 40h, 00h, 1Fh, 01h,0C0h
		db	 00h, 05h, 03h, 20h, 2Eh, 00h
		db	 05h,0C0h, 2Eh, 00h, 0Ah, 2Eh
		db	 01h, 1Ch, 2Eh, 01h, 30h, 2Eh
		db	 01h, 40h, 2Eh, 03h,0F4h, 2Eh
		db	 01h,0FDh, 2Eh, 01h,0BFh, 60h
		db	 2Eh, 00h, 5Fh, 88h, 2Eh, 00h
		db	 55h,0A0h, 2Eh, 00h, 28h, 40h
		db	 2Eh, 00h, 9Ah, 00h, 2Eh, 04h
		db	 28h, 80h, 2Eh, 00h, 1Fh, 6Ah
		db	 2Eh, 00h, 07h,0F6h, 2Eh, 00h
		db	 0Bh,0FEh, 2Eh, 00h, 01h,0EDh
		db	 2Eh, 00h,0B9h,0FFh, 2Eh, 00h
		db	 07h, 3Fh, 10h, 00h, 10h,0FFh
		db	 2Eh, 00h, 04h, 20h, 00h, 04h
		db	 48h, 2Eh, 00h, 24h, 11h, 10h
		db	 00h, 01h, 84h, 74h, 00h, 0Ch
		db	0C9h,0C0h, 00h, 82h,0D6h, 50h
		db	 00h, 0Bh,0FFh, 2Eh, 00h, 02h
		db	0FEh, 00h,0ACh, 00h,0ADh,0BFh
		db	 08h, 00h, 08h, 3Fh, 40h, 00h
		db	 49h, 9Fh, 2Eh, 00h, 20h, 2Bh
		db	 08h, 2Eh, 00h, 64h,0D0h, 00h
		db	 02h, 32h, 38h, 2Eh, 00h, 04h
		db	 09h, 2Eh, 02h, 01h,0FFh, 80h
		db	 2Eh, 00h,0FDh, 40h, 2Eh, 00h
		db	0FFh, 64h, 2Eh, 00h,0BDh, 88h
		db	 2Eh, 00h,0EFh,0A5h, 2Eh, 00h
		db	0ABh,0F4h, 2Eh, 00h, 27h, 7Ah
		db	 2Eh, 00h, 04h, 45h, 2Eh, 00h
		db	 02h, 20h, 2Eh, 00h, 20h, 2Eh
		db	 01h, 05h, 04h, 2Eh, 00h, 8Ch
		db	 64h, 2Eh, 00h, 12h, 88h, 2Eh
		db	 00h, 04h, 92h, 2Eh, 00h, 41h
		db	 2Eh, 01h, 04h, 80h, 2Eh, 04h
		db	 96h, 00h, 2Eh, 00h, 01h, 2Eh
		db	 01h, 80h, 2Eh, 01h, 20h, 80h
		db	 2Eh, 04h, 02h, 2Eh, 02h, 80h
		db	 2Eh, 00h, 0Ah, 2Eh, 09h, 01h
		db	 04h, 2Eh, 01h, 01h, 2Eh, 01h
		db	 80h, 2Eh, 00h,0E7h, 00h, 2Eh
		db	 05h, 20h, 2Eh, 01h,0C2h, 2Eh
		db	 00h, 49h,0A0h, 2Eh, 00h, 11h
		db	 48h, 2Eh, 00h, 26h, 01h, 2Eh
		db	 00h, 20h, 80h, 2Eh, 00h, 80h
		db	 04h, 2Eh, 00h, 24h, 40h, 2Eh
		db	 0Ah,0D0h, 2Eh, 01h, 52h, 2Eh
		db	 01h, 8Ah, 40h, 20h, 2Eh, 00h
		db	 20h,0F5h, 00h, 40h, 10h,0BAh
		db	 00h, 0Dh, 92h, 00h, 2Dh, 0Dh
		db	 45h, 00h, 3Ah, 06h, 40h, 00h
		db	 1Fh, 03h, 2Eh, 00h, 0Ah, 00h
		db	0A0h, 2Eh, 01h, 15h, 2Eh, 08h
		db	 80h, 10h, 7Dh, 00h, 40h, 10h
		db	0BAh, 2Eh, 00h, 20h,0D4h, 2Eh
		db	 00h, 40h,0A0h, 00h, 02h, 2Eh
		db	 01h, 50h, 2Eh, 09h, 03h,0BFh
		db	 02h,0AAh, 08h, 2Eh, 01h, 18h
		db	 00h, 02h,0FEh, 30h, 00h, 20h
		db	 00h, 20h, 00h, 0Bh,0FAh, 20h
		db	 00h, 20h, 2Eh, 01h, 0Bh,0FAh
		db	 20h, 00h, 20h, 00h,0AAh,0F0h
		db	0AAh, 30h, 03h, 08h, 00h, 08h
		db	 02h, 04h,0AAh,0D7h, 00h, 02h
		db	 04h, 22h, 2Eh, 00h,0A0h, 48h
		db	 04h, 02h, 04h, 92h, 2Eh, 00h
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
		db	 50h, 20h,0D7h, 00h,0A2h, 44h
		db	 6Dh, 6Ch, 45h, 6Ch, 00h, 02h
		db	 00h, 02h, 00h, 07h, 00h, 06h
		db	 00h, 07h, 00h, 06h, 00h, 1Fh
		db	 00h, 1Fh, 00h, 78h, 00h, 70h
		db	 00h,0E0h, 00h,0C0h, 00h, 78h
		db	 00h, 70h, 00h, 1Fh, 00h, 1Bh
		db	 2Eh, 0Ah,0C0h, 00h,0C0h, 00h
		db	0F0h, 00h,0E0h, 00h, 38h, 00h
		db	 20h, 00h,0F0h, 00h,0C0h, 00h
		db	0C0h, 2Eh, 02h, 0Fh, 00h, 0Dh
		db	 00h, 0Bh, 00h, 0Ah, 00h, 0Bh
		db	 00h, 09h, 00h, 0Bh, 00h, 0Ah
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 0Ah, 00h, 0Bh, 00h, 09h
		db	 2Eh, 0Ah,0E0h, 00h,0A0h, 2Eh
		db	 03h, 90h, 00h, 90h, 00h,0F0h
		db	 00h,0C0h, 2Eh, 08h, 01h, 00h
		db	 01h, 00h, 01h, 00h, 01h, 2Eh
		db	 15h, 01h,0C0h, 00h,0D0h, 00h
		db	 19h, 80h,0DDh, 80h, 11h, 00h
		db	 5Dh,0D0h, 2Eh, 00h, 85h,0D0h
		db	 40h, 00h,0B8h, 00h, 60h, 00h
		db	 9Fh,0B0h, 40h, 00h,0BFh,0D0h
		db	 2Eh, 00h, 3Fh,0B0h, 00h, 03h
		db	 00h, 04h, 00h, 68h, 00h, 97h
		db	 0Ch, 00h, 13h, 3Dh, 18h, 00h
		db	 27h, 2Ah, 2Eh, 00h, 35h, 15h
		db	 14h,0A5h, 2Eh, 00h, 06h, 31h
		db	 2Eh, 00h, 04h, 21h, 2Eh, 02h
		db	0EFh, 50h, 2Eh, 00h,0F5h, 50h
		db	 2Eh, 00h, 55h, 58h, 2Eh, 00h
		db	0AAh,0A8h, 2Eh, 00h, 55h, 50h
		db	 29h, 40h, 2Eh, 00h, 8Ch, 60h
		db	 2Eh, 00h, 08h, 40h, 2Eh, 01h
		db	 07h, 2Eh, 01h, 0Fh, 2Eh, 01h
		db	 05h, 2Eh, 01h, 04h, 2Eh, 01h
		db	 3Fh, 2Eh, 01h, 0Fh, 2Eh, 01h
		db	 0Ah, 2Eh, 01h, 62h, 2Eh, 00h
		db	0E0h, 2Eh, 01h, 90h, 2Eh, 01h
		db	 20h, 2Eh, 01h, 20h, 2Eh, 01h
		db	 4Ch, 2Eh, 01h, 10h, 2Eh, 05h
		db	 02h, 2Eh, 01h, 01h, 95h, 2Eh
		db	 00h, 07h,0B8h, 00h, 47h, 0Fh
		db	 30h, 00h, 8Ah, 0Fh,0B0h, 00h
		db	 45h, 0Dh, 30h, 02h, 8Bh, 06h
		db	0D0h, 00h, 25h, 01h,0A8h, 00h
		db	 13h, 00h, 54h, 00h, 2Ah, 50h
		db	 80h, 2Eh, 01h, 20h,0FCh, 2Eh
		db	 00h, 10h,0AAh, 80h, 2Eh, 00h
		db	 55h, 2Eh, 00h, 10h,0FEh, 80h
		db	 00h, 20h,0FFh, 2Eh, 00h, 80h
		db	0FCh, 00h, 02h, 00h,0A8h, 2Eh
		db	 01h, 28h, 02h, 2Eh, 00h,0D5h
		db	 51h, 80h, 20h, 6Bh,0CBh,0F0h
		db	 70h, 0Fh,0EFh,0F0h,0C9h, 8Fh
		db	0C7h, 79h, 86h, 67h, 82h, 19h
		db	 82h, 17h, 82h, 0Eh, 00h, 02h
		db	 2Eh, 01h, 28h, 02h
		db	2Eh
data_20		db	0
		db	 15h, 51h, 0Fh, 02h, 8Ch,0E1h
		db	 03h, 47h,0F2h, 16h, 01h, 63h
		db	0F9h, 6Bh, 40h, 11h, 1Dh, 15h
		db	 78h, 00h, 64h, 00h, 30h, 00h
		db	 34h, 20h, 2Eh, 00h, 28h, 02h
		db	 2Eh, 00h,0D4h, 51h, 2Eh, 00h
		db	0E8h,0EBh, 80h, 00h, 71h, 59h
		db	0C0h, 3Ch, 26h,0B2h,0C0h, 1Eh
		db	 8Dh, 18h, 00h, 0Eh, 1Eh, 0Ch
		db	 2Eh, 00h, 0Ch, 2Eh, 01h, 28h
		db	 02h, 2Eh, 00h,0D4h, 11h, 2Eh
		db	 00h,0EAh, 6Ah, 2Eh, 00h,0F1h
		db	 5Ch, 00h, 03h,0C2h, 8Bh, 1Ch
		db	 01h, 19h, 01h, 78h, 00h, 66h
		db	 04h, 38h, 70h, 34h, 6Ah, 2Eh
		db	 00h, 28h, 02h, 2Eh, 00h, 05h
		db	 51h, 0Ah, 00h, 69h,0E3h, 0Eh
		db	 00h,0A9h, 59h,0C0h, 3Ch, 06h
		db	0B2h,0C0h, 3Eh, 85h, 38h, 70h
		db	 0Eh, 66h, 0Ch, 0Ch, 00h, 08h
		db	 00h, 18h, 00h, 04h, 00h, 28h
		db	 00h, 24h, 00h, 20h, 00h, 08h
		db	 02h, 68h, 03h, 7Dh, 52h, 07h
		db	 07h, 84h,0E4h, 03h, 83h,0F2h
		db	0D2h, 60h, 39h, 98h, 31h, 40h
		db	 1Ch, 1Dh, 18h, 2Eh, 00h, 0Ch
		db	 2Eh, 01h, 28h, 02h, 2Eh, 00h
		db	0D4h, 51h, 82h, 80h, 6Ah, 6Bh
		db	 0Bh, 00h,0FAh, 59h,0BEh, 3Eh
		db	 58h,0B8h,0C0h, 8Eh, 8Dh, 88h
		db	 00h, 0Eh, 1Eh, 0Ch, 68h, 00h
		db	 62h, 10h, 0Eh, 00h, 0Ch, 2Eh
		db	 02h, 96h, 00h, 2Eh, 01h, 01h
		db	 2Eh, 00h, 02h, 2Eh, 00h,0A0h
		db	 2Eh, 00h, 08h, 0Eh,0CAh, 00h
		db	 78h, 6Ah, 60h, 80h, 00h,0A8h
		db	 80h, 2Eh, 00h, 10h, 2Eh, 00h
		db	 80h, 02h, 80h, 20h, 00h, 20h
		db	 2Eh, 03h, 0Fh, 00h, 0Ch,0E2h
		db	 07h, 00h, 46h, 74h,0F1h, 80h
		db	0C9h, 28h, 2Eh, 03h, 10h, 00h
		db	 18h, 01h,0C0h, 01h, 80h, 00h
		db	 60h, 00h, 78h, 00h, 61h, 00h
		db	 71h,0DEh, 00h, 99h,0C0h,0F8h
		db	 0Eh,0D6h, 8Ch, 70h, 70h, 65h
		db	 6Ch, 10h, 00h, 18h, 2Eh, 00h
		db	 80h, 00h,0C0h, 18h, 00h, 18h
		db	 2Eh, 03h, 80h, 30h,0C0h, 20h
		db	 00h, 1Ch, 00h, 19h,0CEh,0C0h
		db	 8Dh,0B0h, 30h, 00h, 28h, 56h
		db	 2Eh, 01h, 0Fh, 00h, 80h, 00h
		db	0EAh, 2Eh, 00h, 03h,0CAh, 2Eh
		db	 00h, 0Eh,0B2h, 3Ch, 0Fh, 02h
		db	0A0h, 3Ah,0AAh, 2Eh, 00h, 02h
		db	0A0h, 2Eh, 03h,0AAh

_359UNKN	endp

seg_a		ends



		end	start
