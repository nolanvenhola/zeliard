
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				_361UNKN                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   5-Apr-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    5          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_25e	equ	4000h			;*
data_26e	equ	6000h			;*
data_27e	equ	6300h			;*
data_28e	equ	8203h			;*
data_29e	equ	0AC02h			;*
data_30e	equ	0C001h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_361UNKN	proc	far

start:
		dec	si
		sbb	[bx+si],ax
		add	[bx+si],al
		push	es
		add	es:[bx+di-80h],ah
		db	 9Bh, 02h, 9Ch, 20h,0B2h,0A0h
data_2		db	0B7h			; Data table (indexed access)
		db	 01h,0B9h, 03h,0D9h, 40h,0DDh
		db	 08h,0FFh,0FFh, 26h, 23h, 2Ch
		db	 00h, 2Ch, 00h, 02h, 00h, 02h
		db	 00h, 03h, 00h
data_3		dw	2607h, 1E01h
data_4		dw	126h, 261Ah
data_5		dw	801h, 200h
data_6		dw	100h, 80h
data_7		dw	80h, 60h
data_8		dw	60h, 0B0h
data_9		dw	803Fh, 0B0h
data_10		dw	0A01Ah, 0Eh
		db	 2Ch,0A0h,0E0h, 20h, 2Ah, 80h
		db	0A2h, 00h,0A9h,0A0h,0A2h, 00h
		db	 59h,0A0h
data_11		dw	offset sub_1
		db	 03h, 26h, 0Fh, 03h, 00h, 01h
		db	 00h, 03h
data_12		db	0			; Data table (indexed access)
		db	 03h, 26h, 02h, 28h, 00h, 56h
		db	0F0h,0AEh, 00h, 5Eh,0E0h, 0Eh
		db	 80h, 2Eh,0A8h, 3Ah, 80h, 35h
		db	0A8h,0E9h, 80h, 62h, 60h,0E0h
		db	0A0h,0E1h, 40h,0A0h, 30h,0A8h
		db	 40h, 80h,0A8h,0BCh, 10h, 26h
		db	 02h, 7Fh,0FFh, 7Fh,0FEh, 7Fh
		db	0FFh, 7Fh,0FEh, 7Fh,0FFh, 55h
		db	 54h, 26h, 02h,0F7h,0F7h,0E7h
		db	0E7h,0F7h,0F7h,0E7h,0E7h,0F7h
		db	0F7h, 45h, 45h, 00h, 80h,0FEh
		db	 88h, 02h,0A0h,0FDh, 26h, 00h
		db	 80h,0EFh, 00h, 20h, 00h, 9Fh
		db	 80h, 40h, 00h, 3Eh, 26h, 01h
		db	0FAh, 00h, 08h, 00h,0E1h, 00h
		db	 08h, 00h,0E1h, 26h, 00h, 03h
		db	 26h, 01h, 02h, 00h, 01h, 26h
		db	 01h, 07h, 26h, 01h, 07h, 26h
		db	 01h, 0Eh, 26h, 01h, 0Eh, 00h
		db	 0Ch, 00h, 0Dh, 00h, 38h, 00h
		db	 38h, 08h, 00h,0D3h, 00h, 20h
		db	 00h, 95h, 00h, 20h, 00h, 8Bh
		db	 00h, 20h, 00h, 47h, 00h, 61h
		db	 00h, 4Bh, 00h, 61h, 00h, 4Bh
		db	 00h, 80h, 60h, 80h, 20h, 8Ah
		db	 10h, 8Ah, 10h, 00h, 08h, 00h
		db	 08h, 00h, 30h, 00h
		db	30h
data_13		dw	6300h
		db	 07h,0EBh, 00h, 4Eh, 0Eh,0ECh
		db	 00h,0E0h, 1Ah,0CAh, 0Ch, 0Eh
		db	 0Eh,0A2h, 00h, 8Ah, 1Eh, 6Ah
		db	 00h,0AAh, 1Ah, 55h, 26h, 02h
		db	0D0h, 00h,0D0h, 26h, 03h,0C0h
		db	 00h,0E0h, 26h, 01h,0F0h
		db	26h

_361UNKN	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		add	[bx+si+26h],dx
		add	ax,ds:data_25e[bx+si]
		add	es:[bx+si],ch
		or	ax,93h
;*		jmp	far ptr loc_21		;*
sub_1		endp

		db	0EAh
		dw	650Ah, 0B001h		;  Fixup - byte match
			                        ;* No entry point to code
		cmp	ds:data_29e[bx+si],di
		sub	bl,[si+2]
		stosw				; Store ax to es:[di]
		or	[bp+di+6],bx
		mov	al,[bx+di]
		pop	dx
		or	cl,[bp+si]
		add	[bp+si+18h],di
		add	al,[si]
		mov	si,offset data_3
		inc	ax
		db	 26h, 0Fh,0C0h, 00h,0C0h, 00h
		db	 80h, 00h, 80h, 26h, 03h, 1Ch
		db	 00h, 1Ch,0FFh, 0Eh, 80h, 0Ch
		db	 7Fh, 02h, 00h, 01h,0FFh, 26h
		db	 00h, 03h,0FBh, 26h, 01h,0FEh
		db	 26h, 01h,0BEh, 00h, 20h, 00h
		db	0D7h, 00h, 20h, 00h,0D7h, 26h
		db	 0Ch, 0Ah, 00h, 77h,0CFh
loc_10:
		jg	loc_10			; Jump if >
		dec	di
		cmp	word ptr [bx-2],1Fh
		inc	cx
loc_11:
		jnz	loc_11			; Jump if not zero
		add	es:data_12[bx+si],al
		test	al,0
		inc	bx
		add	ds:data_27e[bx+si],cl
		add	[si],ax
;*		add	cl,ah
		db	 00h,0E1h		;  Fixup - byte match
		add	[si],ax
;*		add	cl,dl
		db	 00h,0D1h		;  Fixup - byte match
		add	ax,[bp+si]
;*		add	cl,dl
		db	 00h,0D1h		;  Fixup - byte match
		add	[bp+si],al
		pop	es
		nop
		add	ax,ss:data_28e[bp+si]
		add	al,0E2h
		add	al,0E2h
		add	es:[bx+si+26h],al
		add	[bx+si+26h],ax
		add	word ptr ds:[126h][bx+si],ax
		and	byte ptr ds:data_30e,26h	; '&'
;*		add	ax,ax
		db	 01h,0C0h		;  Fixup - byte match
		add	ds:data_26e[bx+si],al
;*		add	[bx+si+0],ch
		db	 00h, 68h, 00h		;  Fixup - byte match
		db	 68h, 26h, 06h, 01h, 26h, 01h
		db	 01h, 26h, 01h, 03h, 26h, 01h
		db	 03h, 26h, 01h, 02h, 26h, 01h
		db	 01h, 00h, 01h, 26h, 03h, 03h
		db	 00h, 08h, 26h, 01h, 06h, 00h
		db	 01h, 00h, 04h, 00h, 03h, 00h
		db	 08h, 00h, 04h, 00h, 1Bh, 00h
		db	 05h, 00h, 2Bh, 00h, 17h, 00h
		db	 10h, 00h, 08h, 26h, 01h, 03h
		db	 00h, 80h
data_15		dw	4000h, 0A000h
		db	 00h, 50h, 00h, 20h, 00h, 10h
		db	 00h, 28h, 00h, 14h, 00h, 2Bh
		db	 00h, 15h, 00h, 0Bh, 00h, 07h
		db	 26h, 05h, 03h, 26h, 06h, 02h
		db	 00h, 01h, 00h, 0Ah, 80h, 05h
		db	 40h, 00h,0ABh, 00h, 55h, 00h
		db	 2Bh, 00h, 13h, 00h, 0Ah, 00h
		db	 05h, 26h, 01h, 03h, 26h, 0Ah
		db	 02h, 26h, 02h,0A3h, 00h, 51h
		db	 0Ah,0ABh, 05h, 53h, 00h, 0Ah
		db	 00h, 05h, 26h, 04h, 80h, 26h
		db	 01h, 80h, 26h, 01h,0C0h, 26h
		db	 01h,0C0h, 26h, 01h,0C0h, 26h
		db	 01h, 40h, 26h, 01h, 40h, 00h
		db	 80h, 00h, 40h, 26h, 03h, 80h
		db	 00h, 40h, 00h, 60h, 26h, 01h
		db	 20h, 00h, 10h, 00h,0E0h, 00h
		db	0D0h, 00h,0A0h, 00h, 90h, 26h
		db	 03h, 80h, 00h, 40h, 00h, 02h
		db	 00h, 01h, 00h, 0Ah, 00h, 05h
		db	 00h, 08h, 00h, 04h, 00h, 28h
		db	 00h, 14h, 00h,0E8h, 00h,0D4h
		db	 00h,0A0h, 00h, 90h, 26h, 03h
		db	 80h, 00h, 40h, 26h, 08h, 80h
		db	 00h, 40h, 02h,0A0h, 01h, 50h
		db	0EAh, 00h,0D5h, 00h,0A8h, 00h
		db	 84h, 00h,0A0h, 00h, 50h, 26h
		db	 01h,0C0h, 26h, 0Ch, 80h, 26h
		db	 00h,0CAh, 00h,0C1h, 00h,0AAh
		db	0A0h, 85h, 50h,0A0h, 00h, 50h
		db	 26h, 00h, 38h, 00h, 38h, 00h
		db	 06h, 00h, 06h, 00h, 03h, 00h
		db	 3Fh, 00h, 0Eh, 00h, 7Eh, 00h
		db	 10h, 00h,0F9h, 00h, 66h, 00h
		db	0F0h, 00h, 0Ch, 00h, 62h, 00h
		db	 2Ah, 00h, 95h, 26h, 02h, 0Ch
		db	 00h,0ACh, 00h, 60h, 00h, 76h
		db	 00h,0F0h, 00h,0FDh, 00h, 0Ch
		db	 00h,0FFh, 00h,0E6h, 00h, 2Eh
		db	 80h,0A0h, 00h,0ABh, 00h,0B0h
		db	 00h, 4Ah, 80h, 00h, 54h, 01h
		db	 28h, 07h,0A1h, 04h, 52h, 0Fh
		db	 40h, 08h
data_16		dw	0AA0h
		db	 90h, 05h, 12h, 05h, 3Ah, 0Ah
		db	 39h, 00h, 3Fh, 00h, 03h, 00h
		db	 3Fh, 00h, 0Fh, 00h, 0Fh, 00h
		db	 0Fh, 20h, 00h, 57h, 40h, 80h
		db	0E0h, 44h,0A0h, 03h,0F8h, 0Bh
		db	0C8h, 0Fh, 80h, 4Fh, 80h, 5Eh
		db	 00h, 9Eh, 60h,0D4h, 10h, 28h
		db	0E0h, 28h, 20h, 17h, 50h, 44h
		db	 10h, 4Bh,0A8h, 26h, 01h, 06h
		db	 00h, 0Dh, 00h, 12h, 00h, 10h
		db	 00h, 2Fh, 00h, 10h, 00h, 2Fh
		db	 26h, 01h, 3Fh, 26h, 01h, 1Fh
		db	 00h, 01h, 00h, 1Eh, 00h, 01h
		db	 00h, 0Eh, 02h,0A0h
		db	 50h, 58h

locloop_12:
		db	 26h, 00h,0FCh, 00h, 08h, 00h
		db	 66h, 00h, 10h, 00h, 8Eh, 00h
		db	 60h, 00h, 1Dh, 00h,0C0h, 00h
		db	 3Ah, 61h, 00h, 00h, 74h, 80h
		db	 04h, 00h,0E9h, 40h, 00h, 03h
		db	 00h, 0Ch, 00h, 02h, 00h, 1Dh
		db	 26h, 01h, 3Fh, 26h, 01h,0FFh
		db	 26h, 01h, 3Dh, 00h, 20h, 00h
		db	 18h, 00h, 50h, 00h, 60h, 00h
		db	 70h, 00h, 70h, 08h, 00h,0D0h
		db	 40h, 10h, 00h,0A0h, 40h, 26h
		db	 00h,0B0h, 80h, 10h, 00h,0A8h
		db	 00h, 08h, 00h,0B4h, 00h, 14h
		db	 00h,0A8h, 00h, 0Ch, 00h, 14h
		db	 00h, 1Ch, 00h, 1Ch, 00h, 20h
		db	 00h, 57h, 40h, 80h,0E0h, 44h
		db	0A0h, 03h,0F8h, 0Bh,0C8h, 0Fh
		db	 80h, 4Fh, 80h, 5Eh, 00h, 9Eh
		db	 20h,0FEh, 00h, 06h,0E0h,0FCh
		db	0A0h, 9Dh, 40h, 79h, 40h, 7Ah
		db	 80h, 26h, 01h, 1Ah, 26h, 01h
		db	 5Fh, 26h, 01h,0AFh, 00h, 0Bh
		db	 05h,0E0h, 02h, 18h, 0Dh, 87h
		db	 01h,0C0h, 1Eh, 3Fh, 01h, 40h
		db	 1Eh,0BDh, 00h, 80h, 0Fh, 6Ah
		db	 02h, 80h, 45h, 00h, 01h, 00h
		db	0D6h, 80h, 42h, 00h, 15h, 00h
		db	 05h, 00h,0AAh, 00h, 02h, 00h
		db	0ADh
data_17		db	0
		db	 05h, 00h, 6Ah, 00h, 2Ah, 80h
		db	0A5h, 00h, 44h, 40h, 42h, 20h
		db	 26h, 06h, 03h, 06h, 03h, 19h
		db	 00h,0C6h, 00h,0D6h, 01h,0E1h
		db	 01h,0E5h, 02h,0FFh, 01h,0FFh
		db	 00h, 78h, 03h,0FBh, 26h, 01h
		db	0F4h, 26h, 06h, 80h, 00h, 20h
		db	 26h, 01h,0E8h, 00h, 88h, 00h
		db	0A8h, 00h,0F8h, 00h,0F8h, 26h
		db	 01h,0B8h, 00h, 08h, 00h, 10h
		db	 26h, 01h, 07h, 00h, 18h, 00h
		db	 13h, 94h, 38h, 00h, 23h, 8Ah
		db	 26h, 00h, 01h,0C0h, 04h, 00h
		db	 01h,0C1h, 08h, 3Dh, 06h, 8Eh
		db	 14h, 7Fh, 0Bh, 3Fh, 08h, 3Ch
		db	 16h, 3Ch, 14h, 00h, 0Ah, 1Ah
		db	 0Ah, 00h, 14h, 5Fh, 05h, 00h
		db	 0Ah,0AFh, 01h, 51h, 02h,0A8h
		db	 00h, 10h, 0Ch, 49h, 01h, 80h
		db	 1Eh, 07h, 01h, 40h, 1Eh,0BDh
		db	 00h, 80h, 0Fh, 6Ah, 26h, 03h
		db	0AAh, 00h, 55h, 02h,0B0h, 01h
		db	 4Fh, 0Ah, 80h, 05h, 7Bh, 0Fh
		db	 00h, 0Fh,0FFh, 33h,0C0h, 08h
		db	0FFh, 03h,0A0h, 20h, 2Fh, 02h
		db	 82h, 28h,0ADh, 26h, 02h, 80h
		db	 00h, 40h, 26h, 01h,0F0h, 00h
		db	 80h, 00h, 6Ch, 26h, 01h,0AEh
		db	 00h, 08h, 00h,0F6h, 26h, 01h
		db	0FAh, 80h, 26h, 00h,0BEh, 80h
		db	 3Eh, 00h, 3Eh,0AEh, 26h, 00h
		db	 0Bh,0BFh, 0Ah, 80h, 05h, 7Fh
		db	 0Ah, 00h, 05h,0FEh, 20h, 00h
		db	 1Fh,0FFh, 80h, 08h, 7Fh,0F7h
		db	 80h, 20h, 7Eh, 1Eh, 26h, 00h
		db	 28h, 28h, 26h, 00h,0BAh, 80h
		db	 26h, 00h,0EAh, 26h, 01h,0A8h
		db	 26h, 01h,0B8h, 26h, 01h,0FEh
		db	 26h, 01h,0FBh, 80h, 26h, 00h
		db	 2Eh,0A0h, 26h, 00h, 0Ah,0AAh
		db	 02h,0AAh, 01h, 55h, 0Ah,0C0h
		db	 05h, 3Fh, 2Ah, 02h, 15h,0EDh
		db	 3Ch, 00h, 3Fh,0FEh,0CFh, 00h
		db	 23h,0FFh, 0Eh, 61h, 00h,0BFh
		db	 0Ah, 08h,0A2h,0B6h,0F8h, 00h
		db	0FAh,0BAh, 26h, 04h,0C0h, 26h
		db	 01h,0B0h, 26h, 01h,0B8h, 00h
		db	 20h, 00h,0D8h, 26h, 01h,0EAh
		db	 26h, 01h,0FAh, 26h, 01h,0EAh
		db	 26h, 01h, 2Eh,0FFh, 2Ah, 00h
		db	 15h,0FEh, 28h, 00h, 17h,0FAh
		db	 20h, 00h, 1Fh,0FFh, 80h, 0Ah
		db	 7Fh,0F5h, 80h, 20h, 7Eh, 9Eh
		db	 26h, 00h,0F8h, 38h, 26h, 00h
		db	 2Ah, 0Ah, 26h, 00h,0A8h, 26h
		db	 01h,0A0h, 26h, 01h,0A0h, 26h
		db	 01h, 80h, 26h, 01h,0E0h, 26h
		db	 01h,0B8h, 26h, 01h, 2Ah, 80h
		db	 26h, 00h, 0Ah,0AAh, 26h, 07h
		db	 2Ah, 00h, 15h, 00h,0ACh, 00h
		db	 53h, 02h,0A0h, 01h, 5Eh, 03h
		db	0C0h, 03h,0FFh, 0Ch,0F0h, 02h
		db	 3Fh, 00h,0E8h, 08h, 0Bh, 26h
		db	 06h,0A0h, 00h, 50h, 26h, 01h
		db	0FCh, 00h, 20h, 00h,0DBh, 26h
		db	 01h,0EBh, 80h, 02h, 00h,0FDh
		db	 80h, 26h, 00h,0FEh,0A0h, 00h
		db	0A0h, 0Ah, 2Bh, 0Fh, 80h, 0Fh
		db	0ABh, 26h, 00h, 02h,0EFh, 02h
		db	0A0h, 01h, 5Fh, 02h, 80h, 01h
		db	 7Fh, 08h, 00h, 07h,0FFh, 9Ch
		db	 00h, 1Fh,0DFh, 20h, 80h, 1Fh
		db	 6Fh, 80h, 00h, 6Fh,0A0h, 26h
		db	 00h,0AEh,0A0h, 26h, 00h,0FAh
		db	 80h, 26h, 00h,0EAh, 26h, 01h
		db	0AEh, 26h, 01h,0FFh,0A0h, 26h
		db	 00h,0FEh,0E8h, 80h, 00h, 6Bh
		db	0A8h, 26h, 03h, 2Ah, 00h, 15h
		db	 00h,0ACh, 00h, 53h, 02h,0A0h
		db	 01h, 5Eh, 03h,0C0h, 03h,0FFh
		db	 0Ch,0F0h, 02h, 3Fh, 00h,0E8h
		db	 08h, 0Bh, 00h,0A0h, 0Ah, 2Bh
		db	 26h, 02h,0A0h, 00h, 50h, 26h
		db	 01h,0FCh, 00h, 20h, 00h,0DBh
		db	 26h, 01h,0EBh, 80h, 02h, 00h
		db	0FDh, 80h, 26h, 00h,0FEh,0A0h
		db	 80h, 00h, 6Fh,0A0h, 0Fh, 80h
		db	 0Fh,0ABh, 26h, 00h, 02h,0EFh
		db	 02h,0A0h, 01h, 5Fh, 0Ah, 80h
		db	 05h, 7Fh, 28h, 00h, 17h,0FFh
		db	 9Ch, 00h, 1Fh,0DFh, 20h, 00h
		db	 1Fh,0AFh, 26h, 00h, 0Ah, 02h
		db	 26h, 00h,0AEh,0A0h, 26h, 00h
		db	0FAh, 80h, 26h, 00h,0EAh, 26h
		db	 01h,0AEh, 26h, 01h,0FFh,0A0h
		db	 26h, 00h,0FEh,0E8h, 80h, 00h
		db	 6Bh,0A8h, 26h, 00h, 82h,0A0h
		db	 26h, 03h, 02h, 00h, 01h, 00h
		db	 08h, 00h, 07h, 00h, 2Ch, 00h
		db	 12h, 00h, 80h, 00h, 7Ah, 00h
		db	0C0h, 00h, 2Fh, 02h, 00h, 01h
		db	0AFh, 9Bh, 00h, 01h,0FDh, 26h
		db	 02h,0AAh, 00h, 55h, 00h, 30h
		db	 00h,0CBh,0C0h, 26h, 00h,0EBh
		db	0A0h, 00h,0F0h,0FEh,0F0h, 03h
		db	0B0h,0FBh, 08h, 0Fh, 80h,0FCh
		db	 08h, 02h, 80h,0BAh, 28h, 02h
		db	 00h, 01h,0FEh, 26h, 01h,0FFh
		db	 00h, 20h, 00h, 1Fh, 00h, 20h
		db	 00h, 1Fh, 00h, 82h, 00h, 7Dh
		db	 02h, 08h, 01h,0F7h, 08h, 20h
		db	 07h, 98h, 26h, 00h,0AAh,0A0h
		db	 00h,0A0h,0BAh,0A0h, 26h, 00h
		db	0EAh,0A0h, 26h, 00h,0EBh,0A0h
		db	 26h, 00h,0AAh,0A0h, 26h, 00h
		db	0BBh,0A8h, 08h, 00h,0E6h,0EAh
		db	 26h, 00h,0E8h,0AAh, 26h, 00h
		db	 28h, 28h, 26h, 03h, 02h, 00h
		db	 01h, 00h, 0Bh, 00h, 04h, 00h
		db	 20h, 00h, 1Eh, 00h, 30h, 00h
		db	 0Bh, 00h, 80h, 00h, 6Bh, 00h
		db	 80h, 00h, 7Fh, 00h, 80h, 00h
		db	 7Fh,0AAh, 80h, 55h, 40h, 0Ch
		db	 00h,0F2h,0E0h, 26h, 00h,0BAh
		db	0E8h, 00h, 3Ch,0BFh,0BCh, 00h
		db	0ECh,0FEh,0C2h, 03h,0E0h,0FFh
		db	 02h,0C0h,0A0h, 6Eh, 8Ah, 00h
		db	 28h,0AEh,0A8h, 26h, 01h, 3Fh
		db	 26h, 01h, 0Fh, 00h, 08h, 00h
		db	 07h, 00h, 02h, 00h, 01h, 26h
		db	 01h, 0Fh, 00h, 20h, 00h, 1Eh
		db	 01h, 00h, 02h,0A8h, 10h, 00h
		db	0AAh,0A0h, 26h, 00h,0FFh,0A8h
		db	 26h, 00h,0FEh,0A8h, 26h, 00h
		db	0FAh,0E8h, 26h, 00h,0FAh,0B8h
		db	 28h, 00h,0D7h,0EAh, 80h, 00h
		db	 7Eh,0BAh, 26h, 00h, 38h, 2Ah
		db	 26h, 00h,0A0h,0A8h, 26h, 07h
		db	 0Ah, 00h, 05h, 00h, 20h, 00h
		db	 1Fh, 00h,0B0h, 00h, 4Bh, 02h
		db	 00h, 01h,0EBh, 03h, 26h, 00h
		db	0BFh, 08h, 00h, 06h,0BFh, 26h
		db	 06h,0A8h, 00h, 54h, 00h,0C0h
		db	 00h, 2Eh, 26h, 01h,0AEh, 80h
		db	 03h,0C0h,0FBh,0C0h, 0Eh,0C0h
		db	0FCh, 20h, 3Eh, 00h,0F0h, 20h
		db	 08h, 0Ch, 07h,0F6h, 08h, 00h
		db	 07h,0FAh, 26h, 00h, 03h,0FFh
		db	 26h, 01h,0FFh, 00h, 80h, 00h
		db	 7Eh, 0Ah, 00h, 05h,0FEh, 20h
		db	 00h, 1Bh,0BAh, 00h, 02h, 2Ah
		db	0E9h, 0Ah, 00h,0E8h,0A0h, 02h
		db	 80h,0EAh, 80h, 26h, 00h,0EAh
		db	 80h, 26h, 00h,0AAh, 80h, 26h
		db	 00h,0AEh, 80h, 26h, 00h,0AAh
		db	0A0h, 08h, 00h,0E7h,0A8h, 02h
		db	 00h,0A9h,0A8h, 26h, 03h, 0Ah
		db	 00h, 05h, 00h, 20h, 00h, 1Fh
		db	 00h,0B0h, 00h, 4Bh, 02h, 00h
		db	 01h,0EBh, 03h, 26h, 00h,0BFh
		db	 08h, 00h, 06h,0BFh,0DDh, 00h
		db	 07h,0F6h, 26h, 02h,0A8h, 00h
		db	 54h, 00h,0C0h, 00h, 2Fh, 26h
		db	 01h,0AEh, 80h, 03h,0C0h,0FBh
		db	0C0h, 0Eh,0C0h,0ECh, 20h, 3Eh
		db	 00h,0F0h, 20h, 0Ah, 00h,0E8h
		db	0A0h, 08h, 00h, 07h,0FAh, 02h
		db	 00h, 01h,0FFh, 26h, 01h,0FFh
		db	 26h, 01h,0FFh, 0Ah, 00h, 05h
		db	0FEh, 20h, 00h, 1Fh,0BBh, 20h
		db	 02h, 1Eh,0E9h
data_18		dw	26h			; Data table (indexed access)
		db	 0Ah, 82h, 02h, 80h,0EAh, 80h
		db	 26h, 00h,0FAh, 80h, 26h, 00h
		db	0AAh, 80h, 26h, 00h,0AEh,0A0h
		db	 26h, 00h,0ABh,0A8h, 08h, 00h
		db	0A7h,0A8h, 26h, 00h,0EAh,0A8h
		db	 26h, 00h, 80h,0A0h, 26h, 03h
		db	 3Ah, 00h, 01h, 00h,0A0h, 00h
		db	 43h, 02h, 88h, 01h, 04h, 03h
		db	0C0h, 03h,0F1h, 0Ch,0F0h, 02h
		db	 3Ch, 00h,0E8h, 08h, 0Ah, 00h
		db	0A0h, 0Ah, 28h, 26h, 02h, 60h
		db	 00h, 10h, 26h, 01h, 0Ch, 00h
		db	 20h, 00h, 13h, 26h, 01h, 20h
		db	 80h, 02h, 00h, 41h, 80h, 26h
		db	 01h,0A0h, 80h, 00h, 02h, 00h
		db	 0Fh, 80h, 0Fh,0A8h, 26h, 00h
		db	 02h, 80h, 02h, 20h, 01h, 15h
		db	 0Ch,0C0h, 00h, 30h, 20h, 00h
		db	 13h, 33h, 08h, 00h, 04h,0CCh
		db	 20h, 00h, 1Ch, 8Ch, 26h, 00h
		db	 0Ah, 02h, 26h, 01h,0A0h, 26h
		db	 00h, 90h, 80h, 26h, 00h, 82h
		db	 26h, 01h, 22h, 26h, 01h, 40h
		db	0A0h, 26h, 00h,0CEh,0E8h, 80h
		db	 00h, 63h, 08h, 26h, 00h, 82h
		db	 20h, 26h, 03h, 3Eh, 26h, 01h
		db	0ECh, 00h, 01h, 02h,0A0h, 00h
		db	 08h, 03h,0C0h, 03h,0C0h, 0Ch
		db	0F0h, 00h, 30h, 00h,0E8h, 00h
		db	 08h, 00h,0A0h, 00h, 20h, 26h
		db	 02h, 80h, 26h, 03h, 08h, 00h
		db	 20h, 26h, 03h, 04h, 26h, 01h
		db	 10h, 26h, 03h, 80h, 26h, 01h
		db	 0Fh, 80h, 0Fh, 80h, 26h, 01h
		db	 10h, 02h,0A0h, 26h, 00h, 0Eh
		db	 80h, 00h, 20h, 3Ah, 26h, 00h
		db	 80h, 9Ch, 00h, 08h, 04h, 20h
		db	 00h, 04h, 08h, 26h, 04h, 01h
		db	 26h, 01h, 04h, 26h, 05h, 81h
		db	 26h, 01h, 04h, 26h, 02h, 20h
		db	 80h, 00h, 02h, 26h, 08h, 0Fh
		db	 26h, 01h, 20h, 00h, 13h, 00h
		db	0B8h, 00h
data_19		db	44h
		db	 02h, 26h, 01h, 02h, 40h, 00h
		db	0A2h, 0Eh, 26h, 00h, 08h, 0Ah
		db	 02h, 00h,0C0h, 26h, 02h,0A8h
		db	 00h, 44h, 00h,0C2h, 00h, 01h
		db	 26h, 00h, 80h, 90h, 40h, 03h
		db	0C0h, 87h,0C0h, 0Fh, 30h, 2Ch
		db	 80h, 3Bh, 00h, 30h, 20h, 0Ah
		db	 00h, 08h,0A0h, 08h, 00h, 02h
		db	 28h, 02h, 26h, 00h, 0Dh, 26h
		db	 01h, 8Bh, 26h, 01h, 88h, 0Ah
		db	 26h, 00h, 03h, 20h, 00h, 0Bh
		db	0B3h, 20h, 02h, 00h,0C9h, 26h
		db	 00h, 08h, 82h, 02h,0A0h, 2Ah
		db	0A0h, 26h, 00h, 5Bh, 80h, 26h
		db	 00h,0B4h,0C0h, 26h, 00h, 35h
		db	 30h, 26h, 00h, 48h, 88h, 26h
		db	 00h, 33h, 30h, 26h, 00h, 22h
		db	 28h, 26h, 00h, 80h,0A0h, 26h
		db	 03h, 0Fh, 26h, 01h, 20h, 00h
		db	 14h, 00h,0B0h, 00h, 01h, 02h
		db	 26h, 00h, 08h, 03h, 40h, 26h
		db	 00h, 0Eh, 26h, 01h, 0Ah, 08h
		db	 00h, 40h, 26h, 02h,0A8h, 26h
		db	 01h,0C0h, 00h, 01h, 26h, 01h
		db	 04h, 40h, 03h,0C0h, 13h,0C0h
		db	 0Eh,0C0h, 0Ch, 00h, 3Eh, 00h
		db	 30h, 00h, 0Ah, 00h, 08h, 00h
		db	 08h, 00h, 01h, 00h, 02h, 26h
		db	 04h, 44h, 26h, 02h, 0Eh, 80h
		db	 00h, 01h, 3Ah, 26h, 00h, 08h
		db	 20h, 02h, 26h, 02h, 08h, 20h
		db	 02h, 80h, 02h, 80h, 26h, 00h
		db	 24h, 26h, 02h, 40h, 26h, 00h
		db	 02h, 10h, 26h, 01h,0DDh, 00h
		db	 26h, 00h, 10h, 26h, 00h, 20h
		db	 26h, 01h, 40h, 20h, 26h, 03h
		db	0EEh, 26h, 00h, 03h,0B0h, 26h
		db	 00h, 0Ah, 80h, 26h, 00h, 0Fh
		db	 00h, 0Fh, 00h, 33h,0C0h, 00h
		db	0C0h, 03h,0A0h, 00h, 20h, 02h
		db	 82h, 00h, 80h,0F7h,0F4h,0E7h
		db	0E7h,0F7h,0B0h,0E7h,0E7h,0F0h
		db	0E3h, 47h, 5Fh, 85h, 04h, 7Eh
		db	 3Fh, 87h,0C1h,0FFh, 9Fh, 1Ah
		db	0AAh,0EFh,0D3h, 31h, 40h, 5Bh
		db	0FEh,0D0h,0A7h, 7Dh, 7Bh, 3Eh
		db	 00h, 3Eh, 26h, 03h, 0Ah, 80h
		db	 26h, 00h, 0Eh, 26h, 01h, 30h
		db	 26h, 01h,0A0h, 08h, 26h, 00h
		db	 80h, 20h, 26h, 00h, 40h, 26h
		db	 01h, 03h,0EAh, 26h, 00h, 0Eh
		db	0C0h, 26h, 00h, 2Ah, 02h, 26h
		db	 00h, 3Ch, 00h, 3Ch, 00h,0CFh
		db	 00h, 03h, 00h, 0Eh, 80h, 00h
		db	 80h, 0Ah, 08h, 02h, 00h,0F8h
		db	 00h,0F8h, 00h, 77h, 53h,0E7h
		db	0EFh,0F7h,0A7h,0E7h,0FFh,0F5h
		db	 57h, 47h,0E5h, 12h,0CCh,0FBh
		db	0CCh, 62h, 07h,0FDh, 86h, 3Fh
		db	 2Dh,0FBh, 78h, 6Dh,0D5h, 44h
		db	0FEh,0D6h, 5Bh, 65h,0A4h, 26h
		db	 02h, 2Ah, 26h, 01h, 38h, 26h
		db	 01h, 20h, 26h, 01h,0C0h, 0Ah
		db	 26h, 00h,0A0h, 20h, 26h, 00h
		db	 40h, 26h, 0Eh, 3Eh, 26h, 01h
		db	0ECh, 26h, 00h, 02h,0A0h, 26h
		db	 00h, 03h,0C0h, 03h,0C0h, 0Ch
		db	0F0h, 00h, 30h, 00h,0E8h, 00h
		db	 08h, 00h, 0Ah, 00h, 9Ah, 40h
		db	 00h, 42h,0D4h, 00h, 04h, 0Dh
		db	 15h, 03h, 40h, 1Fh, 42h, 27h
		db	0A4h, 3Fh,0A6h, 05h,0D0h, 0Dh
		db	0D5h,0C2h, 80h,0CAh, 86h, 52h
		db	 34h, 53h, 3Eh, 00h,0A0h, 00h
		db	 20h, 0Fh, 80h, 0Fh, 80h, 26h
		db	 02h, 02h,0A0h, 26h, 00h, 03h
		db	 80h, 26h, 00h, 0Ch, 26h, 01h
		db	 28h, 60h, 26h, 00h, 20h, 80h
		db	 26h, 05h, 3Eh, 26h, 01h,0ECh
		db	 26h, 00h, 02h,0A0h, 26h, 00h
		db	 03h,0C0h, 03h,0C0h, 0Ch,0F0h
		db	 00h, 30h, 00h,0E8h, 00h, 08h
		db	 00h,0A0h, 00h, 20h, 00h, 40h
		db	 20h, 40h, 00h,0D0h, 04h,0D0h
		db	 26h, 00h, 74h, 1Ch, 00h, 80h
		db	0F6h,0E8h, 26h, 00h,0DCh,0E4h
		db	 43h, 1Ch,0F3h,0DCh, 80h, 5Eh
		db	0C8h, 5Eh, 0Bh, 28h, 5Bh, 28h
		db	 0Fh, 80h, 0Fh, 80h, 26h, 02h
		db	 02h,0A0h, 26h, 00h, 0Eh, 80h
		db	 26h, 00h, 3Ah, 26h, 01h, 9Ch
		db	 00h, 26h, 00h, 20h, 26h, 0Ah
		db	 03h, 26h, 01h, 0Dh, 26h, 01h
		db	 2Ch, 26h, 01h, 80h, 26h, 01h
		db	0D0h, 26h, 00h, 03h, 26h, 01h
		db	 02h, 82h, 26h, 04h,0EAh, 26h
		db	 01h, 30h, 26h, 06h,0F0h, 00h
		db	0F0h, 03h,0B0h, 03h, 00h, 0Fh
		db	 80h, 0Ch, 00h, 02h, 80h, 02h
		db	 00h, 02h, 26h, 06h, 20h, 26h
		db	 01h, 60h, 26h, 01h,0A2h, 26h
		db	 00h, 03h, 0Ch, 26h, 00h, 08h
		db	 20h, 26h, 05h,0A0h, 00h,0A0h
		db	 26h, 0Eh, 08h, 26h, 0Eh, 02h
		db	 26h, 01h, 0Bh, 26h, 01h, 20h
		db	 26h, 01h, 34h, 26h, 01h,0C0h
		db	 26h, 01h,0A0h, 26h, 01h, 80h
		db	 26h, 00h,0EEh, 80h, 26h, 00h
		db	 0Ch, 26h, 06h, 3Ch, 00h, 3Ch
		db	 00h,0ECh, 00h,0C0h, 03h,0E0h
		db	 03h, 00h,0C0h,0A0h, 40h, 80h
		db	 00h, 28h, 00h, 28h, 26h, 07h
		db	 08h, 26h, 01h, 02h, 26h, 05h
		db	 28h, 26h, 00h, 01h, 60h, 26h
		db	 00h, 14h, 26h, 11h, 28h, 26h
		db	 01h, 80h, 26h, 12h, 0Fh, 26h
		db	 01h, 20h, 26h, 01h,0B0h, 26h
		db	 00h, 02h, 26h, 01h, 03h, 40h
		db	 26h, 00h, 0Eh, 26h, 09h,0A8h
		db	 26h, 01h,0C0h, 26h, 05h, 03h
		db	0C0h, 03h,0C0h, 0Eh,0C0h, 0Ch
		db	 00h, 3Eh, 00h, 30h, 00h, 0Ah
		db	 0Ch, 00h, 04h, 08h, 26h, 0Ah
		db	 80h, 26h, 00h, 0Dh, 26h, 01h
		db	 30h, 26h, 02h, 02h, 26h, 00h
		db	 0Ah, 00h, 08h, 00h, 02h, 80h
		db	 02h, 80h, 26h, 0Eh, 08h, 26h
		db	 01h, 02h, 26h, 06h, 0Fh
data_20		db	26h			; Data table (indexed access)
		db	 01h, 20h, 26h, 01h,0B0h, 26h
		db	 00h, 02h, 26h, 01h, 03h, 40h
		db	 26h, 00h, 0Eh, 26h, 01h, 0Ah
		db	 08h, 26h, 04h,0A8h, 26h, 01h
		db	0C0h, 26h, 05h, 03h,0C0h, 03h
		db	0C0h, 0Eh,0C0h, 0Ch, 00h, 3Eh
		db	 00h, 30h, 00h, 0Ah, 00h, 08h
		db	 00h, 08h, 26h, 01h, 02h, 26h
		db	 09h, 0Eh, 80h, 26h, 00h, 3Ah
		db	 26h, 01h, 20h, 02h, 26h, 04h
		db	 02h, 80h, 02h, 80h, 26h, 0Eh
		db	 08h, 26h, 0Ah, 10h, 00h, 10h
		db	 26h, 02h, 01h, 09h, 01h, 09h
		db	 00h, 4Dh, 00h, 4Ch, 0Ch, 15h
		db	 10h, 14h, 00h, 82h, 0Bh, 42h
		db	 00h, 10h, 05h, 68h, 26h, 01h
		db	0ABh, 01h, 00h, 01h, 00h, 40h
		db	 00h, 40h, 00h, 10h, 00h, 10h
		db	 00h, 8Ah, 00h, 8Ah, 2Ch,0D0h
		db	 80h, 52h, 50h, 84h, 00h,0AAh
		db	0A0h, 20h, 00h, 55h,0F0h, 26h
		db	 00h, 9Eh,0B0h, 00h, 80h, 02h
		db	 7Bh, 26h, 00h, 01h,0ABh, 01h
		db	 80h, 02h, 6Fh, 02h,0A0h, 01h
		db	 5Fh, 02h, 80h, 01h, 7Fh, 08h
		db	 00h, 07h,0FFh, 9Ch, 00h, 1Fh
		db	0DFh, 20h, 80h, 1Fh, 6Fh, 38h
		db	 12h, 3Ch,0D2h, 72h, 7Bh, 7Fh
		db	0FBh, 64h, 2Dh, 7Fh,0EDh, 03h
		db	0F1h, 1Dh, 56h, 11h, 0Fh, 7Dh
		db	0AFh, 08h,0CCh,0FBh,0DEh, 11h
		db	 22h,0E7h, 2Bh,0C2h,0D4h, 7Ah
		db	0D7h, 10h, 13h, 10h, 13h, 22h
		db	0D5h, 22h,0C5h, 05h,0F7h, 05h
		db	 57h, 4Bh,0D4h, 4Bh, 54h, 15h
		db	 7Bh, 15h, 5Ah, 14h, 4Dh, 14h
		db	 4Ch, 11h,0BFh, 11h,0B3h, 18h
		db	 56h, 25h, 56h, 10h, 04h, 10h
		db	 04h,0A2h, 40h,0A2h, 40h, 69h
		db	 10h, 69h, 10h,0D4h, 44h,0D4h
		db	 44h,0D6h, 80h, 56h, 80h,0EAh
		db	 10h, 6Ah, 10h,0D7h, 84h,0D7h
		db	 84h,0BDh, 40h,0BDh, 40h, 00h
		db	 87h, 06h, 47h, 00h, 10h, 00h
		db	0A4h, 26h, 00h, 01h,0CBh, 26h
		db	 01h,0EBh, 26h, 00h, 02h,0EFh
		db	 02h, 80h, 01h, 7Fh, 26h, 00h
		db	 05h,0FFh, 26h, 00h, 2Eh, 7Ch
		db	 7Dh, 08h, 7Dh, 08h,0D0h, 60h
		db	0D0h, 62h,0B5h, 20h, 35h, 14h
		db	 01h, 80h,0A0h, 60h, 08h, 00h
		db	0F2h,0C0h, 26h, 00h, 7Ah, 26h
		db	 01h,0EEh, 26h, 01h, 7Eh,0A0h
		db	 02h, 0Ch,0F2h, 0Ch, 0Ch,0F7h
		db	0ACh,0F6h, 00h, 5Ah, 67h,0DAh
		db	 40h, 00h, 7Fh,0B0h, 01h, 12h
		db	0F7h,0DEh, 00h, 2Ch,0FCh, 2Eh
		db	 2Eh,0CDh,0FEh, 8Eh,0FDh, 4Ah
		db	 4Ch, 08h, 26h, 01h, 15h, 26h
		db	 00h, 22h,0F0h, 00h, 06h, 0Ah
		db	0AEh, 26h, 00h, 8Fh, 26h, 00h
		db	 20h, 06h,0A9h, 00h, 10h, 23h
		db	 11h, 04h, 00h, 0Dh, 46h, 0Ch
		db	 00h, 7Dh, 50h, 41h, 00h, 41h
		db	 26h, 00h, 02h, 00h, 02h, 00h
		db	 49h, 00h, 49h, 02h, 0Ch, 12h
		db	 0Ch, 00h,0A4h, 00h,0A4h, 00h
		db	 01h,0BEh,0A9h, 1Ah, 80h, 1Ah
		db	0FDh, 26h, 00h, 2Eh, 7Ch, 26h
		db	 02h, 20h, 00h, 20h, 00h, 5Ah
		db	 28h, 5Ah, 28h,0E8h, 00h,0E8h
		db	 00h,0A2h, 41h,0A2h, 41h, 80h
		db	 00h, 9Ah,0D0h, 32h, 00h,0FEh
		db	 0Ch, 08h, 00h, 7Eh,0A0h, 26h
		db	 00h, 02h,0E0h, 26h, 00h, 4Fh
		db	 50h, 26h, 00h, 16h, 04h, 26h
		db	 00h,0B0h, 02h, 26h, 00h, 48h
		db	 01h, 26h, 00h, 82h,0A2h, 26h
		db	 00h, 8Eh, 91h,0C0h, 00h,0DAh
		db	 08h, 00h, 04h,0E6h,0B5h, 26h
		db	 00h,0ADh, 26h, 00h, 40h, 48h
		db	 42h,0A0h, 00h,0A1h, 5Ah, 40h
		db	 00h, 46h, 3Ch,0E0h, 00h,0E8h
		db	 28h, 80h, 40h, 80h, 50h, 13h
		db	 00h, 03h, 08h, 00h,0C0h, 2Ah
		db	0C4h, 00h, 20h, 6Ch, 20h, 26h
		db	 00h,0B8h, 26h, 00h,0C7h, 94h
		db	0C7h, 03h,0F2h, 23h,0D2h, 07h
		db	0F9h, 17h,0A1h, 03h,0E2h, 03h
		db	0C0h,0F0h,0C4h,0F0h, 04h, 00h
		db	 04h, 22h, 05h, 26h, 00h, 08h
		db	 46h, 00h, 40h, 51h, 50h, 26h
		db	 00h,0D4h,0A1h, 00h, 08h,0ADh
		db	 08h, 26h, 00h, 48h, 02h, 26h
		db	 00h, 21h, 5Ah, 10h, 00h, 12h
		db	 34h, 26h, 00h, 48h, 26h, 01h
		db	 82h,0A2h, 26h, 00h, 8Eh, 91h
		db	 26h, 00h, 1Ah, 08h, 00h, 40h
		db	 20h, 44h, 02h, 00h, 4Ah, 08h
		db	 00h, 04h, 90h, 44h, 26h, 00h
		db	 94h, 10h, 26h, 01h, 40h, 26h
		db	 00h, 25h, 26h, 06h, 40h, 11h
		db	 00h, 11h, 26h, 03h, 11h, 04h
		db	 11h, 04h, 46h, 20h, 46h, 20h
		db	 26h, 01h, 60h, 26h, 00h, 02h
		db	 20h, 26h, 00h, 80h, 00h, 01h
		db	 00h, 01h, 10h, 26h, 03h, 08h
		db	 00h, 08h, 11h,0E0h, 11h,0E0h
		db	 02h,0ACh, 02h,0ACh, 26h, 00h
		db	 02h, 80h, 26h, 01h, 54h, 01h
		db	 00h, 09h, 10h, 26h, 00h, 01h
		db	 44h, 26h, 00h, 25h, 26h, 01h
		db	 0Ch, 0Ah, 26h, 00h, 84h, 20h
		db	 26h, 01h, 80h, 26h, 00h, 01h
		db	 40h, 26h, 01h, 10h, 26h, 00h
		db	 08h, 40h, 02h, 00h, 42h, 04h
		db	 26h, 01h, 80h, 26h, 01h, 02h
		db	 26h, 22h, 08h, 90h, 08h, 90h
		db	 26h, 01h, 10h, 26h, 01h, 01h
		db	 26h, 01h, 04h, 26h, 04h, 08h
		db	 26h, 1Ch, 0Ah, 26h, 01h, 2Bh
		db	 26h, 01h,0BFh, 00h, 02h, 2Ah
		db	0FFh, 00h, 2Bh, 26h, 06h, 80h
		db	 26h, 01h, 80h, 26h, 01h,0E8h
		db	 00h, 80h, 00h,0FEh, 00h, 80h
		db	 00h,0FFh, 80h,0E0h, 00h,0FFh
		db	0EAh,0FAh, 26h, 00h,0BFh, 00h
		db	 02h, 00h, 2Fh, 26h, 01h, 0Ah
		db	 26h, 14h,0FFh, 80h,0E0h, 00h
		db	0FEh, 00h, 80h, 00h,0E8h, 00h
		db	 80h, 00h, 80h, 26h, 01h, 80h
		db	 26h, 01h, 80h, 26h, 0Ah, 03h
		db	 00h, 02h, 00h, 0Fh, 00h, 02h
		db	0B9h, 00h, 02h, 00h, 30h, 3Ch
		db	 20h, 08h, 00h,0CCh, 26h, 00h
		db	 03h, 0Ch, 26h, 01h, 03h, 00h
		db	 02h,0F0h, 3Fh, 80h, 28h, 26h
		db	 02h,0C0h, 00h, 80h, 00h, 0Ch
		db	 00h, 08h, 26h, 03h,0F0h, 30h
		db	0A0h, 20h, 0Ch, 00h, 08h, 26h
		db	 03h,0C0h,0CFh, 80h, 00h, 0Ch
		db	0CFh, 26h, 01h, 03h, 00h, 02h
		db	 0Ch,0C0h, 26h, 01h, 0Fh, 00h
		db	 02h, 33h, 30h, 20h, 26h, 04h
		db	0C3h, 00h, 82h, 00h, 03h, 26h
		db	 00h,0CCh, 00h, 80h, 00h, 03h
		db	0C0h, 00h, 80h,0CCh, 26h, 05h
		db	 30h, 30h, 00h, 20h, 03h, 00h
		db	 02h, 00h,0F0h, 00h, 20h, 26h
		db	 07h, 03h, 00h, 02h, 26h, 03h
		db	0C0h, 00h, 80h, 26h, 00h, 03h
		db	 00h, 02h, 26h, 03h, 3Ch, 00h
		db	 20h, 30h, 30h, 20h, 26h, 03h
		db	 03h, 0Ch, 02h, 08h, 26h, 06h
		db	 30h, 00h, 20h, 00h,0B9h, 00h
		db	 9Bh, 00h,0C0h, 00h, 80h, 00h
		db	 03h, 26h, 02h, 0Ch, 00h, 08h
		db	 00h,0C0h, 00h, 80h, 00h, 03h
		db	 00h, 02h, 26h, 0Ah, 03h, 00h
		db	 02h, 00h,0C0h, 00h, 80h, 00h
		db	0F0h, 00h,0A0h, 00h,0F0h, 00h
		db	 80h, 00h, 03h, 00h, 02h, 26h
		db	 08h, 03h, 00h, 02h, 30h, 30h
		db	 9Ch, 00h, 26h, 0Fh, 1Fh, 26h
		db	 01h,0FDh, 26h, 00h, 03h,0FEh
		db	 26h, 00h, 06h,0F8h, 26h, 00h
		db	 0Dh,0E8h, 00h, 05h, 26h, 0Ah
		db	0D0h, 26h, 01h, 52h, 26h, 01h
		db	 8Ah, 40h, 26h, 01h, 20h, 26h
		db	 01h, 10h,0A0h, 00h, 0Dh, 90h
		db	 00h, 03h, 0Dh, 40h, 00h, 05h
		db	 06h, 40h, 26h, 00h, 03h, 26h
		db	 02h,0A0h, 26h, 01h, 15h, 26h
		db	 18h, 0Bh, 00h, 0Ah, 00h, 24h
		db	0C0h, 00h, 80h, 01h, 5Eh, 01h
		db	 5Eh, 0Ah, 04h, 0Ah,0E4h, 26h
		db	 0Fh,0BDh, 00h, 0Dh, 0Bh,0E8h
		db	 00h,0E8h,0AFh,0D0h, 87h,0D0h
		db	0FEh, 80h, 3Eh, 80h,0B4h, 0Dh
		db	0B5h,0CDh, 05h, 6Bh, 05h, 6Bh
		db	 00h
loc_13:
		pop	bp
;*		add	[si+0],bl
		db	 00h, 5Ch, 00h		;  Fixup - byte match
		db	 03h, 26h, 10h,0FFh, 74h,0FFh
		db	 74h,0EFh, 80h,0ECh, 00h,0FBh
		db	0A9h, 26h, 00h, 76h, 80h, 26h
		db	 11h, 10h,0C0h, 26h, 00h, 10h
		db	0A0h, 26h, 00h, 20h, 26h, 01h
		db	 40h, 26h, 00h, 02h, 26h, 01h
		db	 50h, 26h, 16h, 1Fh, 26h, 01h
		db	0FDh, 26h, 00h, 03h,0FEh, 26h
		db	 00h, 06h,0F8h, 00h, 05h, 0Dh
		db	0E8h, 00h, 13h, 26h, 0Ah,0D0h
		db	 26h, 01h, 52h, 26h, 01h, 8Ah
data_21		db	40h			; Data table (indexed access)
		db	 26h, 01h, 20h, 50h, 26h, 00h
		db	 10h,0A8h, 00h, 0Dh, 90h, 00h
		db	 2Fh, 0Dh, 40h, 00h, 17h, 06h
		db	 40h, 00h, 0Ah, 03h, 26h, 02h
		db	0A0h, 26h, 01h, 15h, 26h, 18h
		db	0BDh, 00h,0B0h, 00h, 17h,0D0h
		db	 17h, 00h, 0Bh,0F5h, 0Bh,0E1h
		db	 01h, 7Fh, 01h, 7Ch, 26h, 0Fh
		db	0D0h, 00h, 50h, 03h, 24h, 01h
		db	 00h, 7Ah, 80h, 7Ah, 80h, 20h
		db	 50h, 27h, 50h, 2Eh,0FFh, 2Eh
		db	0FFh, 01h,0F7h, 00h, 37h, 95h
		db	0DFh, 26h, 00h, 01h, 6Eh, 26h
		db	 10h,0B0h, 2Dh,0B3h,0ADh,0D6h
		db	0A0h,0D6h,0A0h,0BAh, 00h, 3Ah
		db	 00h,0C0h, 26h, 12h, 10h,0D0h
		db	 26h, 00h, 10h,0A8h, 26h, 00h
		db	 20h, 40h, 26h, 00h, 40h, 26h
		db	 00h, 02h, 26h, 01h, 50h, 26h
		db	 16h, 1Fh, 26h, 01h,0FDh, 26h
		db	 00h, 03h,0FEh, 00h, 01h, 06h
		db	0F8h, 00h, 07h, 0Dh,0E9h, 00h
		db	 16h, 26h, 0Ah,0D0h, 26h, 01h
		db	 52h, 26h, 01h, 8Ah, 40h, 20h
		db	 26h, 00h, 20h,0F5h, 00h, 40h
		db	 10h,0BAh, 00h, 0Dh, 92h, 00h
		db	 2Dh, 0Dh, 45h, 00h, 3Ah, 06h
		db	 40h, 00h, 1Fh, 03h, 26h, 00h
		db	 0Ah, 00h,0A0h, 26h, 01h, 15h
		db	 26h, 09h, 07h, 26h, 01h, 1Fh
		db	 00h, 07h, 00h, 3Fh, 00h, 1Fh
		db	 00h, 7Eh, 00h, 1Eh, 00h, 7Eh
		db	 00h, 1Eh, 00h, 3Fh, 00h, 0Fh
		db	 00h, 25h, 00h, 05h, 36h,0EBh
		db	 30h, 6Bh, 50h, 26h, 01h,0A0h
		db	 00h,0A0h, 00h, 40h, 00h, 40h
		db	 00h, 80h, 00h, 80h, 00h, 80h
		db	 00h, 80h, 00h, 40h, 00h, 40h
		db	 00h,0A0h, 00h,0A0h, 00h,0FDh
		db	 40h,0FDh, 40h, 87h, 7Fh, 85h
		db	 7Fh, 3Fh, 97h, 0Fh, 94h, 2Eh
		db	 03h, 2Eh, 73h, 0Ah,0BAh, 0Ah
		db	0B8h, 00h, 06h, 26h, 0Ch,0FFh
		db	0FAh,0FFh,0FAh, 7Fh, 60h, 3Fh
		db	 60h,0FFh, 54h, 2Fh, 00h,0BFh
		db	0D0h, 0Fh,0D0h,0DFh,0E8h, 03h
		db	0E8h, 07h,0F2h, 00h,0F2h, 01h
		db	 7Dh, 00h, 1Dh, 00h, 5Dh, 26h
		db	 00h, 14h,0A0h, 00h,0A0h, 3Dh
		db	 00h, 0Dh, 00h, 7Eh, 00h, 1Eh
		db	 00h, 7Dh, 40h, 1Dh, 40h,0FEh
		db	 00h, 3Eh, 00h,0FEh, 00h, 3Eh
		db	 00h, 7Ah, 40h, 1Ah, 40h,0BEh
		db	 80h, 0Eh, 00h, 5Eh, 80h, 06h
		db	 80h, 22h,0A0h, 02h,0A0h, 10h
		db	0EBh, 16h,0E9h, 00h,0F0h, 0Eh
		db	0F0h, 01h,0E0h, 01h,0ECh, 0Fh
		db	0F1h, 0Fh,0F4h, 02h,0D2h, 02h
		db	0D2h, 26h, 0Eh, 1Ah,0F0h, 1Ah
		db	0F0h, 2Eh,0FDh, 00h, 7Dh,0A0h
		db	 76h, 00h, 02h, 80h, 02h, 80h
		db	 26h, 13h, 01h, 40h, 26h, 00h
		db	0B5h,0FEh, 01h,0A0h, 2Fh,0F5h
		db	 2Fh,0F4h, 02h,0FFh, 02h,0FFh
		db	 26h, 13h, 08h, 26h, 00h, 80h
		db	 20h, 26h, 00h, 60h, 85h, 26h
		db	 01h, 2Bh, 00h, 2Bh, 00h,0AFh
		db	 00h,0AFh, 05h,0FFh, 05h,0D2h
		db	 2Bh, 5Fh, 26h, 01h, 05h, 26h
		db	 05h, 02h, 00h, 02h, 00h, 2Bh
		db	 00h, 2Bh, 60h, 30h, 6Fh, 20h
		db	0F8h, 7Dh,0FBh, 7Dh,0BFh,0F8h
		db	 3Fh,0F8h,0E7h, 40h, 07h, 40h
		db	0D5h, 26h, 01h, 2Bh, 00h, 2Ah
		db	 00h,0FEh, 00h,0F8h, 00h,0B8h
		db	 00h, 80h, 26h, 00h, 0Ah, 26h
		db	 01h, 05h, 00h, 05h, 00h, 02h
		db	 00h, 02h, 00h, 01h, 00h, 01h
		db	 00h, 01h, 00h, 01h, 00h, 02h
		db	 00h, 02h, 00h, 05h, 00h, 05h
		db	 02h,0BFh, 02h,0BFh,0E0h, 26h
		db	 01h,0F8h, 00h,0E0h, 00h,0FCh
		db	 00h,0F8h, 00h, 7Eh, 00h, 78h
		db	 00h, 7Eh, 00h, 78h, 00h,0FCh
		db	 00h,0F0h, 00h,0A4h, 00h,0A0h
		db	 00h,0D7h, 6Ch,0D6h, 0Ch, 5Fh
		db	0FFh, 5Fh,0FFh, 06h,0FEh, 06h
		db	0FCh, 2Ah,0FFh, 00h,0F4h, 0Bh
		db	0FDh, 0Bh,0F0h, 17h,0FBh, 17h
		db	0C0h, 4Fh,0E0h, 4Fh, 00h,0BEh
		db	 80h,0B8h, 00h,0BAh, 26h, 01h
		db	0FEh,0E1h,0FEh,0A1h,0E9h,0FCh
		db	 29h,0F0h,0C0h, 74h,0CEh, 74h
		db	 5Dh, 50h, 1Dh, 50h, 60h, 26h
		db	 0Dh, 05h, 28h, 05h, 26h, 00h
		db	0BCh, 00h,0B0h, 00h, 7Eh, 00h
		db	 78h, 02h,0BEh, 02h,0B8h, 00h
		db	 7Fh, 00h, 7Ch, 00h, 7Fh, 00h
		db	 7Ch, 02h, 5Eh, 02h, 58h, 01h
		db	 7Dh, 00h, 70h, 26h, 0Ah, 0Fh
		db	 58h, 0Fh, 58h,0BFh, 74h,0BEh
		db	 00h, 6Eh, 05h, 40h, 00h, 40h
		db	 01h, 00h, 01h, 26h, 02h, 01h
		db	 7Ah, 01h, 60h, 05h, 44h, 05h
		db	 40h,0D7h, 08h, 97h, 68h, 0Fh
		db	 00h, 0Fh, 70h, 07h, 80h, 37h
		db	 80h, 8Fh,0F0h
data_22		dw	0F02Fh			; Data table (indexed access)
		db	 4Bh, 40h, 4Bh, 40h, 26h, 16h
		db	 10h, 26h, 01h, 04h, 01h, 26h
		db	 00h,0A1h, 06h, 26h, 10h, 02h
		db	 80h, 26h, 00h, 7Fh,0ADh, 05h
		db	 80h,0AFh,0F4h, 2Fh,0F4h,0FFh
		db	 40h,0FFh, 40h, 0Ch, 06h, 04h
		db	0F6h,0BEh, 1Fh,0BEh,0DFh, 1Fh
		db	0FDh, 1Fh,0FCh, 02h,0E7h, 02h
		db	0E0h, 00h,0ABh, 26h, 01h,0D4h
		db	 00h, 54h, 00h, 7Fh, 00h, 1Fh
		db	 00h, 1Dh, 00h, 01h,0D4h, 00h
		db	0D4h, 00h,0F5h, 00h,0F5h, 00h
		db	0FFh,0A0h, 4Bh,0A0h,0FAh,0D4h
		db	 26h, 00h,0A0h, 26h, 05h, 40h
		db	 00h, 40h, 00h,0D4h, 00h,0D4h
		db	 26h, 13h, 0Bh, 00h, 0Ah, 00h
		db	 24h,0C0h, 00h, 80h, 01h, 5Eh
		db	 01h, 5Eh, 26h, 1Ah,0A0h, 00h
		db	 80h, 00h, 0Ah, 04h, 0Ah,0E4h
		db	0B4h, 0Dh,0B5h,0CDh, 05h, 6Bh
		db	 05h, 6Bh, 00h, 5Dh, 00h, 5Ch
		db	 00h, 03h, 26h, 0Ch,0FAh, 00h
		db	 3Ah, 00h,0FFh,0A0h,0FFh,0A0h
		db	0FEh,0F4h,0FEh,0F4h, 7Fh,0DEh
		db	 7Fh,0DEh, 6Fh,0F4h, 0Fh,0F4h
		db	 00h, 5Eh, 03h, 5Eh, 26h, 00h
		db	 0Ch, 40h, 26h, 00h,0B1h, 10h
		db	 26h, 0Eh, 0Bh, 00h, 0Ah, 00h
		db	 24h,0C0h, 00h, 80h, 01h, 5Eh
		db	 01h, 5Eh, 0Ah, 04h, 0Ah,0E4h
		db	 26h, 16h,0A0h, 00h, 80h, 00h
		db	0FAh, 00h, 3Ah, 00h,0B4h, 0Dh
		db	0B5h,0CDh, 05h, 6Bh, 05h, 6Bh
		db	 00h, 5Dh, 00h, 5Ch, 00h, 03h
		db	 26h, 07h, 01h, 26h, 01h, 03h
		db	 26h, 02h,0FFh,0A0h,0FFh,0A0h
		db	0FEh,0F4h,0FEh,0F4h, 7Fh,0DEh
		db	 7Fh,0DEh, 6Fh,0F4h, 0Fh,0F4h
		db	 00h, 5Eh, 03h, 5Eh, 26h, 00h
		db	 53h, 26h, 01h, 03h, 26h, 01h
		db	 2Ch,0A0h,0FAh, 00h, 3Ah, 00h
		db	0FFh,0A0h,0FFh,0A0h,0FEh,0F4h
		db	0FEh,0F4h
data_23		db	7Fh			; Data table (indexed access)
		db	0DEh, 7Fh,0DEh, 6Eh, 74h, 0Eh
		db	 74h, 00h, 1Eh, 03h, 9Eh, 26h
		db	 00h, 08h,0C0h, 26h, 00h, 85h
		db	 90h,0B4h, 0Dh,0B5h,0CDh, 05h
		db	 6Bh, 05h, 6Bh, 00h, 5Dh, 00h
		db	 5Ch, 00h, 03h, 26h, 0Bh, 03h
		db	 26h, 02h,0FFh,0A0h,0FFh,0A0h
		db	0FEh,0F4h,0FEh,0F4h
loc_15:
		jg	$-20h			; Jump if >
		jg	$-20h			; Jump if >
		db	 6Fh,0F4h, 0Fh,0F4h, 00h, 5Eh
		db	 0Fh, 5Eh, 26h, 00h,0F9h, 26h
		db	 01h, 02h, 26h, 01h, 14h, 40h
		db	 26h, 1Bh, 05h, 00h, 01h, 26h
		db	 13h,0D0h, 00h, 50h, 03h, 24h
		db	 01h, 00h, 7Ah, 80h, 7Ah, 80h
		db	 00h, 5Fh, 00h, 5Ch, 05h,0FFh
		db	 05h,0FFh, 2Fh, 7Fh, 2Fh, 7Fh
		db	 7Bh,0FEh
loc_16:
		jnp	loc_16			; Jump if not parity
		das				; Decimal adjust
		imul	byte ptr [bx]		; ax = data * al
                           lock	jp	$+2			; delay for I/O
		jp	loc_15			; Jump if parity=1
		add	es:[bp+si],al
		xor	byte ptr data_18,ah
loc_17:
		lea	sp,[bx+si]		; Load effective addr
		push	ax
		daa				; Decimal adjust
		push	ax
		mov	al,2Dh			; '-'
		mov	bl,0ADh
		db	0D6h,0A0h,0D6h,0A0h,0BAh, 00h
		db	 3Ah, 00h,0C0h, 26h, 26h, 05h
		db	 00h, 01h, 00h, 5Fh, 00h, 5Ch
		db	 26h, 0Fh,0D0h, 00h, 50h, 03h
		db	 24h, 01h, 00h, 7Ah, 80h, 7Ah
		db	 80h, 20h, 50h, 27h, 50h, 05h
		db	0FFh, 05h,0FFh, 2Fh, 7Fh, 2Fh
		db	 7Fh, 7Bh,0FEh
loc_18:
		jnp	loc_18			; Jump if not parity
		das				; Decimal adjust
		imul	byte ptr [bx]		; ax = data * al
                           lock	jp	$+2			; delay for I/O
		jp	loc_17			; Jump if parity=1
		db	 26h, 01h,0CAh, 26h, 01h,0C0h
		db	 26h, 00h, 05h, 34h,0B0h, 2Dh
		db	0B3h,0ADh,0D6h,0A0h,0D6h,0A0h
		db	0BAh, 00h, 3Ah, 00h,0C0h, 26h
		db	 07h, 80h, 26h, 01h,0C0h, 26h
		db	 04h, 5Fh, 00h, 5Ch, 05h,0FFh
		db	 05h,0FFh, 2Fh, 7Fh, 2Fh, 7Fh
		db	 7Bh,0FEh
loc_19:
		jnp	loc_19			; Jump if not parity
		db	 2Eh, 76h, 2Eh, 70h, 78h, 00h
		db	 79h,0C0h, 26h, 00h, 03h, 10h
		db	 26h, 00h, 09h,0A1h, 05h,0FFh
		db	 05h,0FFh, 2Fh, 7Fh, 2Fh, 7Fh
		db	 7Bh,0FEh, 7Bh,0FEh, 2Fh,0F6h
		db	 2Fh,0F0h, 7Ah, 00h, 7Ah,0F0h
		db	 26h, 01h, 9Fh, 26h, 01h, 40h
		db	 26h, 00h, 02h, 28h,0B0h, 2Dh
		db	0B3h,0ADh,0D6h,0A0h,0D6h,0A0h
		db	0BAh, 00h, 3Ah, 00h,0C0h, 26h
		db	 0Bh,0C0h, 26h, 0Bh,0DDh, 02h
		db	 00h, 80h, 00h, 80h, 20h, 26h
		db	 01h, 22h, 10h, 02h, 10h, 31h
		db	 04h, 01h, 04h, 54h, 01h, 04h
		db	 01h, 26h, 02h, 84h,0B0h
data_24		db	84h
		db	 00h, 0Bh,0DCh, 0Bh, 00h, 0Eh
		db	0D6h, 0Eh, 50h, 97h,0A1h, 96h
		db	 20h, 5Fh, 41h, 1Ch, 40h, 5Eh
		db	0A0h, 58h,0A0h, 51h, 40h, 51h
		db	 40h, 6Eh, 35h, 0Eh, 25h, 56h
		db	 03h, 16h, 03h, 3Dh, 01h, 00h
		db	 0Dh, 05h, 63h, 04h, 0Bh, 20h
		db	 52h, 20h, 52h, 04h, 01h, 04h
		db	 01h, 00h, 40h, 00h, 40h, 26h
		db	 02h,0C2h, 00h,0DAh, 00h,0C0h
		db	 40h,0DCh, 40h,0E0h, 08h,0E0h
		db	 08h,0FCh, 00h,0FCh, 00h,0D0h
		db	 40h,0D0h, 40h, 26h, 02h, 04h
		db	 00h, 04h, 26h, 03h, 44h, 00h
		db	 44h, 26h, 00h, 48h, 00h, 08h
		db	 02h, 26h, 02h, 02h, 26h, 00h
		db	 41h, 51h, 40h, 26h, 00h,0B6h
		db	 26h, 00h, 01h, 7Dh, 26h, 00h
		db	 14h,0BFh, 26h, 00h, 01h, 00h
		db	 01h, 00h, 20h, 04h, 20h, 04h
		db	 80h, 26h, 01h, 24h, 80h, 26h
		db	 00h, 93h, 01h, 00h, 01h,0DFh
		db	 26h, 01h, 7Eh, 26h, 01h,0DFh
		db	 50h, 26h, 00h, 21h,0FFh, 20h
		db	 00h, 04h, 2Fh, 26h, 00h, 03h
		db	 0Fh, 00h, 60h, 99h, 07h, 80h
		db	 60h, 06h, 5Fh, 26h, 00h, 20h
		db	 06h, 26h, 00h, 04h, 03h, 04h
		db	 00h, 20h, 41h, 20h, 40h,0F4h
		db	 26h, 00h, 30h,0FEh, 26h, 00h
		db	 30h,0F6h, 40h, 26h, 00h, 7Bh
		db	 08h, 26h, 00h, 5Ch, 40h, 26h
		db	 00h, 92h, 01h, 00h, 01h, 26h
		db	 02h, 02h, 08h, 02h, 08h, 00h
		db	 84h, 26h, 00h, 20h, 10h, 26h
		db	 00h, 04h, 80h, 26h, 04h, 48h
		db	 26h, 05h, 80h, 26h, 05h, 01h
		db	 26h, 01h, 08h, 20h, 26h, 00h
		db	 80h, 02h, 26h, 00h, 02h, 26h
		db	 02h, 44h, 26h, 05h, 20h, 26h
		db	 03h, 02h, 08h, 26h, 05h, 40h
		db	 26h, 01h, 02h, 26h, 02h, 20h
		db	 26h, 00h, 08h, 80h,0A0h, 26h
		db	 00h, 02h, 60h, 00h, 02h, 26h
		db	 04h, 06h, 26h, 01h, 02h, 00h
		db	 02h, 26h, 04h, 02h, 20h, 26h
		db	 00h, 50h, 01h, 26h, 00h, 02h
		db	 26h, 01h, 10h, 84h, 26h, 00h
		db	 80h, 10h, 7Dh, 00h, 40h, 10h
		db	0BAh, 26h, 00h, 20h,0D4h, 26h
		db	 00h, 40h,0A0h, 00h, 02h, 26h
		db	 01h, 50h, 26h, 09h, 03h,0BFh
		db	 02h,0AAh, 08h, 26h, 01h, 18h
		db	 00h, 02h,0FEh, 30h, 00h, 20h
		db	 00h, 20h, 00h, 0Bh,0FAh, 20h
		db	 00h, 20h, 26h, 01h, 0Bh,0FAh
		db	 20h, 00h, 20h, 00h,0AAh,0F0h
		db	0AAh, 30h, 03h, 08h, 00h, 08h
		db	 02h, 04h,0AAh, 04h, 04h, 02h
		db	 04h, 22h, 26h, 00h,0A0h, 48h
		db	 04h, 02h, 04h, 92h, 26h, 00h
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
		db	 26h, 0Ah,0C0h, 00h,0C0h, 00h
		db	0F0h, 00h,0E0h, 00h, 38h, 00h
		db	 20h, 00h,0F0h, 00h,0C0h, 00h
		db	0C0h, 26h, 02h, 0Fh, 00h, 0Dh
		db	 00h, 0Bh, 00h, 0Ah, 00h, 0Bh
		db	 00h, 09h, 00h, 0Bh, 00h, 0Ah
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 0Ah, 00h, 0Bh, 00h, 09h
		db	 26h, 0Ah,0E0h, 00h,0A0h, 26h
		db	 03h, 90h, 00h, 90h, 00h,0F0h
		db	 00h,0C0h, 26h, 08h, 07h, 26h
		db	 01h, 0Fh, 26h, 01h, 05h, 26h
		db	 01h, 04h, 26h, 01h, 3Fh, 26h
		db	 01h, 0Fh, 26h, 01h, 0Ah, 26h
		db	 01h, 62h, 26h, 00h,0E0h, 26h
		db	 01h, 90h, 26h, 01h, 20h, 26h
		db	 01h, 20h, 26h, 01h, 4Ch, 26h
		db	 01h, 10h, 26h, 05h, 02h, 26h
		db	 01h, 01h, 95h, 26h, 00h, 07h
		db	0B8h, 00h, 47h, 0Fh, 30h, 00h
		db	 8Ah, 0Fh,0B0h, 00h, 45h, 0Dh
		db	 30h, 02h, 8Bh, 06h,0D0h, 00h
		db	 25h, 01h,0A8h, 00h, 13h, 00h
		db	 54h, 00h, 2Ah, 50h, 80h, 26h
		db	 01h, 20h,0FCh, 26h, 00h, 10h
		db	0AAh, 80h, 26h, 00h, 55h, 26h
		db	 00h, 10h,0FEh, 80h, 00h, 20h
		db	0FFh, 26h, 00h, 80h,0FCh, 00h
		db	 02h, 00h,0A8h, 26h, 03h, 7Fh
		db	0FFh, 7Fh,0FEh, 7Fh,0FFh, 7Fh
		db	0FEh, 7Fh,0FFh, 55h, 54h, 26h
		db	 02h,0F0h, 00h,0E0h, 00h,0F1h
		db	0C0h,0E1h,0C0h,0F3h,0F0h, 43h
		db	0F0h, 26h, 02h, 7Fh,0FFh, 7Fh
		db	0FEh, 7Fh,0FFh, 7Fh,0FEh, 7Fh
		db	0FFh, 55h, 54h, 26h, 03h, 07h
		db	 00h, 07h, 00h, 77h, 00h, 67h
		db	 03h,0F7h, 03h,0A5h, 01h,0F7h
		db	 00h,0A7h, 1Eh, 67h, 1Eh, 07h
		db	 3Fh,0E7h, 3Fh,0E5h, 7Fh,0FEh
		db	 5Fh,0FEh, 7Fh,0FEh, 2Bh,0FCh
		db	 87h,0FCh, 85h, 50h,0D0h, 78h
		db	0D0h, 60h,0E7h,0E6h, 45h, 44h
		db	0F3h,0F0h,0E2h, 80h,0F0h, 38h
		db	0E0h, 38h,0F3h,0FCh, 43h,0F8h
		db	 3Fh,0FEh, 3Fh,0F8h, 7Fh,0FEh
		db	 7Fh,0F4h, 3Fh,0F1h, 3Eh,0A1h
		db	 1Fh, 07h, 15h, 07h, 63h,0F7h
		db	 43h, 45h, 26h, 06h, 3Ch, 00h
		db	 3Ch, 00h, 7Fh, 80h, 7Fh, 80h
		db	0FFh,0F0h, 9Fh,0F0h, 1Fh,0FCh
		db	 17h,0F8h, 83h,0F8h, 82h,0E0h
		db	 00h, 70h, 00h, 40h, 26h, 07h
		db	 38h, 00h, 3Ch, 01h,0F4h, 01h
		db	0FEh, 0Fh,0FCh, 0Fh,0FFh, 3Fh
		db	0E8h, 3Fh,0F8h, 1Fh, 41h, 1Fh
		db	0C1h, 0Ah, 02h, 0Eh, 02h,0A0h
		db	 00h,0A0h, 00h, 40h, 00h, 40h
		db	 00h,0E0h, 00h,0E0h, 00h, 80h
		db	 40h, 80h, 40h, 13h, 00h, 03h
		db	 00h, 07h,0C7h, 07h, 87h, 57h
		db	0E3h, 17h, 02h,0BEh, 91h, 14h
		db	 01h, 26h, 07h, 80h, 00h, 80h
		db	 00h, 80h, 00h, 80h, 20h, 08h
		db	 20h, 08h, 04h, 00h, 04h, 26h
		db	 00h, 1Eh, 00h, 1Eh, 3Dh, 15h
		db	 3Dh, 15h, 00h, 01h, 26h, 01h
		db	0F2h, 00h, 10h, 00h,0B0h, 00h
		db	 30h, 00h, 50h, 00h, 50h, 26h
		db	 00h, 3Fh, 55h, 0Ah, 52h, 1Eh
		db	0F7h, 04h, 21h, 06h, 31h, 02h
		db	 10h, 02h, 10h,0E3h,0C0h,0E0h
		db	 00h, 71h,0E0h, 70h,0E0h, 69h
		db	0A0h, 68h,0A0h, 54h, 00h, 57h
		db	0E8h, 26h, 00h, 55h, 50h, 94h
		db	0A0h,0BDh,0E0h, 08h, 40h, 8Ch
		db	 60h, 84h, 20h, 84h, 20h, 26h
		db	 06h,0E0h, 00h,0C0h, 00h, 78h
		db	 26h, 01h, 86h, 61h, 00h, 00h
		db	0F8h, 50h,0E0h, 00h,0FFh, 80h
		db	0D1h, 80h,0FFh,0D0h,0E9h, 40h
		db	 00h, 01h, 00h, 01h, 00h, 07h
		db	 00h, 07h, 00h,0FFh, 00h, 7Eh
		db	 1Fh, 3Ah, 1Dh, 10h, 35h, 14h
		db	 30h, 02h, 26h, 00h, 3Fh,0AAh
		db	 26h, 00h, 3Fh, 55h, 26h, 00h
		db	 2Fh,0A8h, 3Fh,0A0h, 30h, 80h
		db	0EFh, 50h, 89h, 00h,0F5h, 50h
		db	0A0h, 00h,0A2h,0A8h, 26h, 02h
		db	0A9h, 50h, 26h, 00h,0AAh,0A8h
		db	 26h, 00h, 05h, 50h, 26h, 00h
		db	 05h, 20h, 26h, 02h, 7Fh,0FFh
		db	 7Fh,0FEh, 7Fh,0FFh, 7Fh,0FEh
		db	 7Fh,0FFh, 05h, 50h, 26h, 02h
		db	0F7h,0F7h,0E7h,0E7h,0F7h,0F7h
		db	0E7h,0E7h,0F7h,0F7h, 05h
		db	40h

seg_a		ends



		end	start
