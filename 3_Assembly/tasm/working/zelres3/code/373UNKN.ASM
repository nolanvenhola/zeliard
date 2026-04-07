
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				_373UNKN                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   5-Apr-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    5          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	0Ah
data_2e		equ	0F7Ch			;*
data_3e		equ	3400h			;*
data_4e		equ	8000h			;*
data_5e		equ	0AA00h			;*
data_6e		equ	0E13Fh			;*
data_7e		equ	0FFFDh			;*
data_18e	equ	7A00h			;*
data_19e	equ	0C0C1h			;*
data_20e	equ	0E0FFh			;*
data_21e	equ	0F307h			;*
data_22e	equ	0F87Fh			;*
data_23e	equ	0F91Fh			;*
data_24e	equ	0FF00h			;*
data_25e	equ	123h			;*
data_26e	equ	523h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_373UNKN	proc	far

start:
		inc	sp
		sbb	al,[bx+si]
		add	[bx+si],al
		push	es
		and	ax,[bx+si]
		dec	cx
		jmp	word ptr [bp-80h]	;*
		db	 6Dh, 01h, 73h, 40h, 89h, 07h
		db	 91h, 02h, 99h, 03h,0B7h,0C0h
		db	0C6h,0A0h,0E6h, 20h,0FFh,0FFh
		db	 23h, 1Fh, 08h, 23h, 01h
data_8		dw	2318h
		db	 00h, 14h,0F3h, 14h, 00h
		db	'7?7', 0Ah, 1Bh, 'o', 1Bh, '`', 1Bh
		db	'h', 1Bh, 'h'
		db	 12h, 42h, 12h, 42h, 0Fh,0FEh
		db	 0Fh,0FEh
		db	 20h, 23h
data_9		db	1
		db	 60h, 80h, 23h, 00h,0CBh, 04h
		db	 80h, 00h,0FEh, 9Ch, 20h, 00h
		db	0FAh, 78h,0C0h, 20h,0FFh,0E0h
		db	 02h, 00h,0FFh,0D1h, 30h, 00h
		db	0FFh, 3Eh, 23h, 01h, 1Fh, 05h
		db	 5Fh, 03h, 83h, 0Ah, 13h, 10h
		db	 0Fh, 1Ah,0AFh, 26h, 0Eh, 3Fh
		db	0EEh, 00h, 0Eh, 0Fh,0EEh, 00h
		db	 1Ch, 05h,0DCh, 00h, 1Dh, 07h
		db	 5Ch, 00h, 18h, 00h, 18h,0FFh
		db	0FCh
		db	23h
data_10		dw	0FF00h			; Data table (indexed access)
		db	0F1h, 23h, 00h,0FFh, 96h, 23h
		db	 00h,0FAh,0A0h, 23h, 00h, 55h
		db	 4Ch, 23h, 00h,0AAh,0B0h, 23h
		db	 00h, 55h, 40h, 23h, 00h,0A2h
		db	 23h, 02h, 05h, 00h,0A5h, 00h
		db	 8Dh, 02h,0E9h, 00h, 07h, 06h
		db	0A4h, 01h,0A5h, 2Bh,0F4h, 04h
		db	 01h, 3Fh,0E1h, 30h, 00h, 7Fh
		db	0E1h, 00h, 01h,0FFh,0C1h, 40h
		db	 01h,0FFh,0C7h,0FDh, 00h,0FDh
		db	 00h,0F7h,0B0h,0F7h, 90h,0DEh
		db	0F0h,0DEh, 10h, 77h, 40h, 00h
		db	 40h,0D5h, 00h,0D5h, 23h, 01h
		db	 41h, 40h, 23h, 00h,0EAh, 40h
		db	 80h, 00h,0FEh,0A0h, 23h, 05h
		db	 02h, 23h, 01h, 03h, 23h, 01h
		db	 03h, 23h, 01h, 03h, 23h, 01h
		db	 01h, 23h, 01h, 01h, 23h, 01h
		db	 06h, 23h, 00h,0FFh, 43h, 23h
		db	 00h, 5Ch, 83h, 23h, 01h, 01h
		db	 08h, 00h, 1Dh, 02h, 23h, 00h
		db	 12h, 80h, 23h, 00h, 0Bh, 40h
		db	 0Fh,0FCh, 0Dh, 40h, 0Fh,0D4h
		db	 23h, 00h, 80h, 00h,0FFh,0A0h
		db	 20h, 00h,0FFh, 20h, 23h, 00h
		db	0DEh, 23h, 01h,0F4h, 20h, 18h
		db	 00h, 7Fh,0A0h, 08h, 00h, 7Fh
data_11		db	0F0h			; Data table (indexed access)
		db	 23h, 00h, 3Fh, 98h, 23h, 00h
		db	 09h,0E0h, 23h, 03h, 06h, 00h
		db	 0Fh, 00h, 10h, 00h, 3Fh, 23h
		db	 01h, 75h, 00h, 08h, 00h, 6Fh
		db	 23h, 01h, 2Eh, 23h, 07h, 08h
		db	 00h, 5Fh, 02h,0C0h,0D7h,0F9h
		db	 23h, 00h,0FFh,0DEh, 23h, 00h
		db	0F6h,0F5h, 23h, 00h,0D2h,0A0h
		db	 23h, 00h, 80h, 23h, 09h, 08h
		db	 23h, 01h, 03h, 67h, 04h, 00h
		db	 06h,0FFh, 08h, 10h, 0Eh, 5Fh
		db	 00h,0B0h, 0Fh,0FDh, 23h, 00h
		db	 05h,0FAh, 23h, 02h, 01h, 42h
		db	 01h, 42h, 02h, 00h,0BEh,0B2h
		db	0B0h, 00h,0FFh,0F4h, 23h, 00h
		db	0FFh, 48h, 23h, 00h,0DAh,0A0h
		db	 23h, 00h, 24h, 23h, 0Ch, 02h
		db	 00h, 02h, 00h, 04h, 00h, 05h
		db	 23h, 03h, 08h, 00h, 0Bh, 23h
		db	 01h, 07h, 23h, 01h, 0Dh, 23h
		db	 01h, 0Fh, 23h, 01h, 1Bh, 01h
		db	0F0h, 81h,0F0h, 00h,0FAh, 50h
		db	0FAh, 00h, 3Fh, 88h, 3Fh, 00h
		db	 03h, 50h, 07h, 23h, 00h,0A8h
		db	 30h, 23h, 00h,0D4h, 1Fh, 23h
		db	 00h,0A8h, 5Fh, 23h, 00h,0D2h
		db	 2Bh, 28h, 10h, 28h, 10h, 10h
		db	 00h, 10h, 00h, 81h, 00h, 81h
		db	 00h,0FAh, 28h,0FAh, 28h, 7Eh
		db	 84h, 7Eh, 84h, 07h,0F6h, 87h
		db	0F6h, 40h, 00h,0F8h, 23h, 01h
		db	0F9h, 68h, 23h, 01h, 0Fh, 23h
		db	 01h, 1Fh, 23h, 01h, 1Fh, 23h
		db	 01h, 3Fh, 23h, 01h, 3Fh, 23h
		db	 01h, 3Eh, 23h, 01h, 37h, 23h
		db	 01h, 71h, 23h, 00h
data_12		db	0A4h			; Data table (indexed access)
		db	 07h, 23h, 00h,0A8h, 83h, 23h
		db	 00h, 40h, 01h, 23h, 00h, 82h
		db	 23h, 05h, 48h, 23h, 01h, 80h
		db	 23h, 01h,0A0h, 00h, 10h, 00h
		db	0FCh,0F4h, 14h, 00h,0FEh, 6Ah
		db	 0Ch, 00h,0FEh,0BAh, 02h, 00h
		db	0FFh, 1Bh, 00h, 80h, 3Dh,0CDh
		db	 23h, 00h, 16h, 7Dh, 23h, 00h
		db	 05h, 3Eh, 23h, 00h, 01h,0D4h
		db	 00h,0F8h, 00h,0F8h, 00h,0FFh
		db	 00h,0FDh, 00h, 1Fh, 00h, 1Ah
		db	 00h,0E3h, 00h,0E2h, 00h,0FEh
		db	 00h,0EAh, 00h,0FFh, 00h,0F5h
		db	 00h,0FFh, 00h,0EAh, 01h,0FFh
		db	 01h,0F4h, 23h, 02h,0C0h, 00h
		db	 40h, 00h,0E0h, 00h,0A0h, 00h
		db	0E0h, 00h,0A0h, 23h, 03h,0C0h
		db	 00h, 40h, 00h,0C0h, 00h, 80h
		db	 00h,0C0h, 23h, 02h, 01h, 00h
		db	 01h, 00h,0FFh, 00h,0BFh, 00h
		db	 7Fh, 00h, 5Fh, 00h, 1Fh, 00h
		db	 17h, 23h, 03h, 03h, 00h, 03h
		db	 00h, 01h, 00h, 01h, 23h, 02h
		db	0E0h, 00h, 60h, 00h,0F8h, 00h
		db	0F0h, 00h,0F8h, 00h,0E0h, 00h
		db	0E7h, 00h, 46h, 00h, 1Fh, 80h
		db	 1Dh, 00h,0FFh,0C0h,0FEh, 80h
		db	0FFh,0E0h,0FFh, 40h, 7Fh,0E0h
		db	 7Fh, 40h, 23h, 17h, 1Dh, 00h
		db	 1Dh, 00h, 3Fh, 00h, 3Ah, 01h
		db	0FFh, 01h,0EAh, 01h,0FFh, 01h
		db	0D4h, 07h,0FEh, 07h,0AAh, 00h
		db	 1Fh, 00h, 15h, 0Bh, 80h, 0Bh
		db	 00h,0FFh,0FCh, 8Dh, 14h,0FFh
		db	0FCh,0A2h,0A8h,0FFh,0FCh, 55h
		db	 54h, 23h, 00h, 79h, 80h, 23h
		db	 00h, 53h, 23h, 01h,0A2h, 23h
		db	 00h, 60h, 50h, 40h, 00h, 70h
		db	0A8h, 60h, 03h,0E0h, 43h,0C0h
		db	0FFh,0C8h,0BFh, 40h, 08h,0B0h
		db	 08h, 20h, 3Fh,0F0h, 3Fh,0A0h
		db	 0Fh,0F0h, 0Fh, 40h, 07h,0C0h
		db	 06h, 80h, 00h, 1Eh, 00h, 1Ah
		db	 01h,0FFh, 01h, 9Dh, 0Fh,0FFh
		db	 0Fh,0CAh, 7Fh,0EFh, 71h,0E9h
		db	0FFh, 80h,0FCh, 80h, 01h,0F0h
		db	 1Dh,0F0h, 00h,0FAh, 1Ch,0FAh
		db	 00h, 3Fh, 3Dh, 3Fh, 00h, 03h
		db	 3Eh, 83h, 23h, 00h, 7Fh, 48h
		db	 02h, 00h, 7Fh, 95h, 23h, 00h
		db	0FFh, 3Ah, 04h, 00h,0FFh, 75h
		db	 50h, 80h, 50h, 80h, 20h, 80h
		db	 20h, 66h, 00h, 00h, 80h, 00h
		db	0D0h,0A0h,0D0h,0A0h,0EAh, 00h
		db	0EAh, 00h, 36h, 80h,0B6h, 80h
		db	 23h, 00h, 80h, 23h, 03h, 0Ch
		db	 00h,0FEh, 6Ah, 04h, 00h,0FEh
		db	0D5h, 23h, 00h,0FDh,0AAh, 23h
		db	 00h, 2Dh, 54h, 23h, 00h,0F5h
		db	 8Ch, 00h,0FEh, 50h,0F8h, 0Fh
		db	0FFh, 0Fh,0FCh, 0Fh,0FEh, 0Fh
		db	0F0h, 23h, 00h, 80h, 23h, 05h
		db	 20h, 23h, 01h, 40h, 23h, 01h
		db	 20h, 23h, 01h, 50h, 23h, 01h
		db	 10h, 23h, 01h, 10h, 23h, 00h
		db	0F8h, 00h,0C0h, 00h, 07h, 00h
		db	 06h, 00h, 3Fh, 00h, 2Fh, 00h
		db	 07h, 00h, 07h, 00h, 01h, 00h
		db	 01h, 00h, 06h, 00h, 04h, 00h
		db	 01h, 00h, 01h, 00h, 01h, 00h
		db	 01h
loc_1:
		js	$+2			; delay for I/O
		jo	$+2			; delay for I/O
		inc	word ptr [bx+si]
		hlt				; Halt processor
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		cmp	ch,0
		jmp	ax			;*
			                        ;* No entry point to code
		inc	byte ptr ds:data_20e[bx+si]
		jmp	word ptr ds:data_22e[bx+si]	;*
			                        ;* No entry point to code
		jg	loc_1			; Jump if >
		lahf				; Load ah from flags
		db	0FEh, 1Fh,0F6h,0C7h,0F8h, 47h
		db	0F8h,0E9h,0C0h, 81h,0C0h,0F4h
		db	 0Eh,0A0h, 08h,0FAh, 9Fh,0A8h
		db	 1Eh, 34h, 3Fh, 20h, 3Fh, 13h
		db	0FFh, 02h,0C3h, 87h,0F8h, 85h
		db	0E8h, 3Fh,0C0h, 2Fh, 40h, 3Eh
		db	 00h, 3Ah, 00h,0E0h, 00h,0A0h
		db	 00h,0F0h, 00h,0D0h, 00h, 78h
		db	 00h, 78h, 00h,0A0h, 00h, 20h
		db	 23h, 1Ah, 02h, 23h, 01h
data_13		db	3			; Data table (indexed access)
		db	 23h, 01h, 07h, 23h, 01h, 05h
		db	 23h, 01h, 0Fh, 23h, 01h
data_14		db	0Fh
		db	 07h,0E0h, 57h,0E0h, 03h,0F4h
		db	0B3h,0F4h, 00h,0FFh,0F0h,0FFh
		db	 00h, 17h,0FAh, 17h, 10h, 00h
		db	0F9h, 23h, 01h,0F9h,0D9h, 40h
		db	 00h,0D3h,0EAh,0C0h, 00h,0E7h
		db	0F8h, 50h, 20h, 50h,0E6h, 00h
		db	 00h, 20h, 00h, 82h, 00h, 82h
		db	 00h,0F4h, 50h,0F4h, 50h, 7Dh
		db	 00h, 7Dh, 00h, 07h,0F0h, 07h
		db	0F0h, 23h, 04h, 90h, 60h, 80h
		db	 00h,0CFh,0F0h, 23h, 00h,0CEh
		db	0E2h, 80h, 00h, 9Dh,0C1h, 23h
		db	 00h,0ABh, 23h, 01h, 86h, 23h
		db	 01h, 4Ch, 23h, 01h, 90h, 23h
		db	 01h,0A0h, 23h, 01h, 54h,0A8h
		db	 23h, 00h,0AAh, 2Ch, 23h, 00h
		db	 54h, 2Ah, 23h, 00h,0EAh, 12h
		db	 23h, 00h, 5Dh, 05h, 23h, 00h
		db	 1Bh, 15h, 23h, 00h, 05h, 2Ah
		db	 23h, 00h, 01h, 54h, 00h,0FCh
		db	 00h,0FCh, 00h,0FFh, 00h,0FEh
		db	 00h, 1Fh, 00h, 16h, 00h,0E3h
		db	 00h,0E3h, 00h,0FCh, 00h,0F4h
		db	 00h,0FFh, 00h,0FDh, 00h,0FFh
		db	 00h,0FEh, 01h,0FFh, 01h,0FEh
		db	 23h, 02h,0C0h, 00h, 80h, 00h
		db	0E0h, 00h,0C0h, 00h,0E0h, 23h
		db	 05h,0C0h, 00h, 40h, 00h,0C0h
		db	 00h, 80h, 00h,0C0h, 23h, 02h
		db	 01h, 00h, 01h, 00h,0FFh, 00h
		db	0AAh, 00h, 7Eh, 00h, 52h, 00h
		db	 1Fh, 00h, 15h, 23h, 03h, 03h
		db	 00h, 02h, 00h, 01h, 00h, 01h
		db	 23h, 02h,0C0h, 00h, 40h, 00h
		db	0E8h, 00h,0A8h, 00h,0E8h, 00h
		db	0A8h, 00h, 42h, 00h, 42h, 00h
		db	 15h, 00h, 15h, 00h,0FEh, 80h
		db	0AAh, 80h,0FFh, 40h, 55h, 40h
		db	 7Fh, 40h, 55h, 40h, 01h,0FFh
		db	 01h,0FAh, 01h,0FEh, 01h,0FCh
		db	 07h,0FEh, 07h,0F8h, 00h, 1Fh
		db	 00h, 1Dh, 0Fh, 00h, 0Bh, 00h
		db	0EFh,0DCh, 8Fh
data_15		db	9Ch
		db	0F7h,0FCh,0E7h,0BCh,0FFh,0FCh
		db	 55h, 54h, 3Fh,0A0h, 3Ah,0A0h
		db	 1Fh,0D0h, 1Dh, 50h, 0Eh, 80h
		db	 0Ah, 80h, 00h, 0Ah, 00h, 0Ah
		db	 03h, 95h, 02h, 95h, 0Fh,0EAh
		db	 0Dh, 4Ah,0FBh,0A0h, 70h,0A0h
		db	0F6h, 80h, 54h, 80h, 23h, 05h
		db	 01h, 23h, 01h, 01h, 23h, 01h
		db	 03h, 23h, 01h, 03h, 23h, 01h
		db	 05h, 23h, 01h, 07h, 23h, 01h
		db	 07h, 01h,0F0h, 81h,0F0h, 00h
		db	0FAh, 40h,0FAh, 00h, 3Fh, 22h
		db	 3Fh, 00h, 03h, 53h, 43h, 23h
		db	 00h,0A3h,0D0h, 23h, 00h,0D1h
		db	0F4h, 23h, 00h, 63h,0FCh, 00h
		db	 10h,0D3h,0FEh, 50h, 20h, 50h
		db	0E6h, 00h, 00h, 20h, 00h, 82h
		db	 00h, 82h, 00h,0F4h, 50h,0F4h
		db	 50h, 7Dh, 00h, 7Dh, 00h, 07h
		db	0F0h, 87h,0F0h, 23h, 00h, 48h
		db	 23h, 01h, 94h, 23h, 02h, 0Dh
		db	 23h, 01h, 07h, 23h, 01h, 1Eh
		db	 23h, 01h, 2Eh, 23h, 01h, 1Fh
		db	 23h, 01h, 0Bh, 23h, 03h, 01h
		db	 00h, 01h, 00h, 10h

locloop_2:
		retn
			                        ;* No entry point to code
		cld				; Clear direction
		add	[bx+si],bl
		loopz	locloop_2		; Loop if zf=1, cx>0

		and	ax,[bx+si]
		sar	si,1			; Shift w/sign fill
		add	[bx+si],cl
		call	sub_1
		add	al,0B4h
		mov	si,offset data_8
		shr	bh,1			; Shift w/zeros fill
		or	al,[bx+si]
		mov	dh,[bx]
		cli				; Disable interrupts
		cmp	dl,80h
		and	ax,[bx+si]
		call	sub_2
		hlt				; Halt processor
		and	ax,[bx+di]
		clc				; Clear carry flag
		and	ax,[bx+di]
;*		jz	loc_5			;*Jump if zero
		db	 74h, 23h		;  Fixup - byte match
;*		add	ax,di
		db	 01h,0F8h		;  Fixup - byte match
		and	ax,[bx+di]
		xor	al,23h			; '#'
		add	[bx+si+23h],bx
		add	[si],ax
;*		add	ah,dh
		db	 00h,0F4h		;  Fixup - byte match
		daa				; Decimal adjust
		hlt				; Halt processor

locloop_4:
		daa				; Decimal adjust
;*		add	di,ax
		db	 01h,0C7h		;  Fixup - byte match
		add	[bx+0Fh],ax
		loopnz	locloop_6		; Loop if zf=0, cx>0

		mov	al,ds:data_21e
		pop	es
		push	bx
		add	si,cx
		add	sp,[bx+di]
;*		add	ax,si
		db	 01h,0F0h		;  Fixup - byte match
;*		add	[bx+si+0],dx
		db	 01h, 50h, 00h		;  Fixup - byte match

locloop_6:
		hlt				; Halt processor
		add	ds:data_18e[bx+si],ah
		add	[bx+si-2],cl
;*		add	dl,bh
		db	 00h,0FAh		;  Fixup - byte match
;*		add	dh,bh
		db	 00h,0FEh		;  Fixup - byte match
		xor	byte ptr ss:data_16[bp],0C0h
		or	[bx+si],ax
;*                         lock	add	al,dh
		db	0F0h, 00h,0F0h		;  Fixup - byte match
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		db	0C0h,0FDh, 00h,0FFh

locloop_7:
		loopnz	locloop_7		; Loop if zf=0, cx>0

		cmp	byte ptr [bx-20h],7Fh
		inc	ax
		aas				; Ascii adjust
                           lock	aas				; Ascii adjust
		mov	al,data_15
		and	ax,[bx+di]
		retn	0C000h
		db	 00h,0F8h, 00h,0A8h, 01h,0FAh
		db	 01h, 52h, 07h,0D5h, 07h, 40h
		db	 07h, 40h, 05h, 00h, 3Dh, 1Fh
		db	 28h, 15h, 78h, 3Fh, 50h, 3Dh
		db	 1Fh,0F8h, 1Fh,0E0h, 9Fh,0F8h
		db	 1Fh,0D0h, 1Fh,0F8h, 1Fh,0E0h
		db	 85h, 7Ch, 00h, 50h, 2Dh, 40h
		db	 2Ch, 00h, 7Fh,0F0h, 3Eh, 70h
		db	0DFh,0F0h, 9Eh,0F0h,0FFh,0F0h
		db	 55h, 50h, 00h, 04h, 23h, 00h
		db	 01h, 06h, 23h, 00h, 20h,0D3h
		db	 00h, 01h, 39h, 7Fh, 10h, 14h
		db	 1Eh, 5Fh, 04h, 03h, 07h,0FFh
		db	 01h, 80h, 8Bh,0FFh, 00h, 4Ch
		db	 74h,0FFh, 20h, 0Ah, 10h, 23h
		db	 01h, 18h, 23h, 01h,0CFh, 28h
		db	 00h, 28h,0FCh,0ECh, 50h,0ECh
		db	0F6h,0D8h, 06h,0D8h, 16h,0D8h
		db	 16h,0D8h, 42h, 48h, 42h, 48h
		db	 7Fh,0F0h, 7Fh,0F0h, 3Eh,0BEh
		db	 0Ch, 00h, 9Fh,0FDh, 01h, 40h
		db	 67h,0FAh, 40h, 00h, 0Ah,0D5h
		db	 23h, 00h, 32h,0AAh, 23h, 00h
		db	 0Dh, 55h, 23h, 00h

_373UNKN	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		add	ch,ss:data_11[bp+si]
		inc	bp
		and	ax,[bx+si]
		clc				; Clear carry flag
;*		add	dl,bh
		db	 00h,0FAh		;  Fixup - byte match
		mov	al,ds:data_19e
		db	0C9h, 10h,0F0h, 00h,0F5h, 58h
		db	 70h, 00h, 77h,0ECh, 70h, 00h
		db	 77h,0E0h, 38h, 00h, 3Bh,0A0h
		db	0B8h, 00h, 3Ah,0E0h, 18h, 00h
		db	 18h, 23h, 00h,0BFh, 00h,0BFh
		db	 0Dh,0EFh, 09h,0EFh, 0Fh, 7Bh
		db	 08h, 7Bh, 02h,0EEh, 02h, 23h
		db	 00h,0ABh, 00h

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_2:
		stosw				; Store ax to es:[di]
		and	ax,[bx+si]
		add	al,ss:data_17[bp+si]
;*		add	dl,[bx+0]
		db	 02h, 57h, 00h		;  Fixup - byte match
		db	0C0h, 05h,0FFh,0A0h, 00h,0A5h
		db	 00h,0B1h, 00h, 97h, 40h,0E0h
		db	 00h, 25h, 60h,0A0h, 00h, 2Fh
		db	0D4h, 80h, 00h, 87h,0F4h, 03h
		db	 00h, 87h,0FAh, 01h, 00h, 83h
		db	0FDh, 00h, 40h,0E3h,0FDh, 00h
		db	 80h, 05h,0FFh, 00h, 80h, 04h
		db	0FFh, 23h, 01h, 7Bh, 23h, 00h
		db	 04h, 2Fh, 01h, 80h, 05h,0FEh
		db	 01h, 00h, 0Fh,0FEh, 23h, 00h
		db	 19h,0FCh, 23h, 00h, 07h, 90h
		db	 23h, 00h,0C2h,0F5h, 23h, 00h
		db	0C1h, 2Ah, 23h, 00h, 80h, 23h
		db	 00h, 10h, 40h,0B8h, 23h, 00h
		db	 01h, 48h, 23h, 00h, 02h,0D0h
		db	 3Fh,0D0h, 03h, 80h, 2Bh,0D0h
		db	 23h, 06h, 40h, 23h, 01h,0C0h
		db	 23h, 01h,0C0h, 23h, 01h,0C0h
		db	 23h, 01h, 80h, 23h, 01h, 80h
		db	 23h, 01h, 60h, 00h, 01h, 00h
		db	 4Dh, 7Dh, 00h, 2Ch, 2Fh,0FFh
		db	 23h, 00h, 12h,0FFh, 23h, 00h
		db	 05h, 5Bh, 23h, 01h, 24h, 02h
		db	 80h, 02h, 80h, 05h, 10h, 05h
		db	 10h, 06h,0B6h, 06h,0B6h, 23h
		db	 01h, 10h, 23h, 00h,0A6h,0C0h
		db	 40h, 20h,0FFh, 60h, 08h, 10h
		db	0FAh, 70h, 0Dh, 00h,0BFh,0F0h
		db	 23h, 00h, 5Fh,0A0h, 23h, 02h
		db	 42h, 80h, 42h, 80h, 10h, 00h
		db	0FAh, 00h, 01h, 40h, 9Fh,0EBh
		db	 00h, 06h, 7Bh,0FFh, 00h, 04h
		db	0AFh, 6Fh, 00h, 01h, 05h, 4Bh
		db	 23h, 01h, 01h, 23h, 0Ah, 20h
		db	 00h,0F0h, 23h, 01h,0FCh, 23h
		db	 01h,0AEh, 23h, 01h,0F6h, 23h
		db	 01h, 74h, 23h, 07h, 0Ch, 74h
		db	 0Ch, 74h, 1Ah,0C8h, 1Ah,0C8h
		db	 14h, 81h, 14h, 81h, 14h, 5Fh
		db	 14h, 5Fh, 21h, 7Eh, 21h, 7Eh
		db	 6Fh,0E0h, 6Fh,0E1h, 23h, 01h
		db	 1Fh, 23h, 00h, 16h, 9Fh, 0Fh
		db	 80h, 0Fh, 81h, 5Fh, 00h, 5Fh
		db	 0Ah,0FCh, 00h,0FCh, 11h,0C0h
		db	 00h,0C0h, 0Ah, 23h, 00h, 04h
		db	 15h, 23h, 00h,0D4h, 2Ah, 23h
		db	 00h,0A8h, 15h, 23h, 00h, 50h
		db	 4Ah, 40h, 00h, 40h, 00h, 20h
		db	 00h,0A0h, 23h, 03h, 10h, 00h
		db	0D0h, 23h, 01h,0E0h, 23h, 01h
		db	0B0h
		db	23h

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_3:
		add	[bx+si+23h],si
;*		add	ax,bx
		db	 01h,0D8h		;  Fixup - byte match
		add	[bp+si],al
		add	[bx],bh
		xchg	di,ax
		or	al,0
		jg	$+41h			; Jump if >
		and	ax,[bx+si]
		jle	loc_8			; Jump if < or =
		or	[bx+si],al
		cld				; Clear direction
		cmc				; Complement carry
		and	ax,[bx+si]
		db	0F3h,0B4h, 23h, 00h,0BEh, 68h
		db	 23h, 00h, 7Ch,0A0h, 23h, 00h
		db	 2Bh, 80h, 23h, 00h,0A0h, 25h
		db	 23h, 00h, 41h, 14h, 23h, 00h
		db	 80h, 02h, 23h, 01h, 40h, 23h
		db	 05h, 12h, 23h, 01h, 01h, 23h
		db	 01h, 04h, 23h, 00h,0D0h, 23h
		db	 01h,0E8h, 23h, 01h,0E8h, 23h
		db	 01h,0F4h, 23h, 01h,0E8h, 23h
		db	 01h,0D4h, 23h, 01h,0ACh, 23h
		db	 01h, 8Eh, 23h, 00h, 07h, 00h
		db	 06h, 00h, 1Fh, 00h, 0Fh, 00h
		db	 1Fh, 00h, 17h, 00h,0E7h, 00h
		db	0E2h, 01h,0F8h, 01h,0F8h, 03h
		db	0FFh, 03h,0FEh, 07h,0FFh, 07h
		db	0FAh, 07h,0FEh, 07h,0F4h, 80h
		db	 00h, 80h, 00h,0FFh, 00h,0F4h
		db	 00h,0FEh, 00h,0E8h, 00h,0F8h
		db	 00h,0C0h, 23h, 03h,0C0h, 00h
		db	 80h, 00h, 80h, 23h, 0Ah, 03h
loc_8:
		add	[bp+di],al
		add	[bx],al
		add	[bx],al
		add	[bx],al
		add	[di],al
		and	ax,[bp+di]
		add	ax,[bx+si]
		add	al,[bx+si]
		add	ax,[bx+si]
		add	ax,[bx+si]
		add	ax,[bx+si]
		add	[bx],bx
		add	[bp+si],bl
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
;*		add	dl,ch
		db	 00h,0EAh		;  Fixup - byte match
;*		add	dl,bh
		db	 00h,0FAh		;  Fixup - byte match
;*		add	al,dl
		db	 00h,0D0h		;  Fixup - byte match
;*		add	bh,al
		db	 00h,0C7h		;  Fixup - byte match
;*		add	[bp+si+0],al
		db	 00h, 42h, 00h		;  Fixup - byte match
		db	 7Fh, 00h, 55h, 00h,0FFh, 00h
		db	0AAh, 00h,0FFh, 00h, 55h, 00h
		db	0FFh, 80h,0AAh, 80h, 0Fh,0FCh
		db	 0Fh,0E8h, 0Fh,0F0h, 0Fh,0A0h
		db	 03h,0E0h, 01h, 40h, 78h, 00h
		db	 78h, 00h,0FFh, 80h,0F9h, 80h
		db	0FFh,0F0h,0F3h,0E0h,0F7h,0EEh
		db	0D6h, 8Eh, 01h,0BFh, 01h, 35h
		db	 23h, 16h,0F8h, 00h,0A8h, 00h
		db	0FCh, 00h, 94h, 00h,0FFh, 80h
		db	0D5h, 00h,0FFh, 80h,0EAh, 80h
		db	 7Fh,0E0h, 75h, 40h,0F8h, 00h
		db	0E8h, 00h, 01h,0D0h, 00h,0D0h
		db	 3Fh,0FDh, 3Ch,0B1h, 3Eh,0F7h
		db	 3Ch, 47h, 3Eh,0DFh, 2Ah, 9Ah
		db	 07h, 2Ah, 07h, 2Ah, 03h, 64h
		db	 03h, 64h, 03h, 21h, 03h, 21h
		db	 01h, 0Bh, 01h, 0Bh, 01h,0DFh
		db	 01h,0DFh, 02h,0ECh, 02h,0EDh
		db	 23h, 01h, 01h, 23h, 02h, 05h
		db	0E8h, 05h,0E8h, 2Fh,0C0h, 2Fh
		db	0C0h,0FEh, 00h,0FEh, 2Ah,0F0h
		db	 00h,0F0h, 74h, 23h, 00h, 02h
		db	0FAh, 23h, 00h,0A9h,0F5h, 08h
		db	 00h, 5Ch,0FAh, 04h, 00h,0FEh
		db	0FDh
		db	23h
loc_9:
		add	[bx+di],ax
		and	ax,[di]
		add	al,23h			; '#'
		add	word ptr ds:[123h],ax
		add	al,23h			; '#'
		add	word ptr ds:[123h],cx
		or	al,23h			; '#'
		add	[bx+si],cx
		or	al,0
		db	0FEh, 7Ah, 04h, 00h

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_4:
		db	0FFh, 7Dh, 23h

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_5:
		add	[di-6],bh
		and	ax,[bx+si]
loc_10:
		cmp	dh,ah
		and	ax,[bx+si]
		xor	data_10[bx],bp
		aas				; Ascii adjust
		or	bh,bh			; Zero ?
                           lock	jg	loc_9			; Jump if >
		jg	loc_10			; Jump if >
		sub	ax,23h
		push	ds
		add	ds:data_24e,cl
		add	[bx+1],bh
		inc	word ptr [bx+si]
		inc	word ptr [bx]
		inc	word ptr [bp+di]
		inc	word ptr [bx]
		inc	word ptr [bx]
		neg	byte ptr [bx]
		db	0FEh, 1Fh,0D8h, 7Fh,0F9h, 7Fh
		db	 60h, 1Fh,0E2h, 1Eh, 80h, 1Fh
		db	 23h, 01h,0E0h, 00h, 60h, 00h
		db	0FCh, 00h,0D0h, 00h,0E0h, 00h
		db	 40h, 00h, 80h, 23h, 01h, 60h
		db	 00h, 20h, 00h, 80h, 23h, 01h
		db	 80h, 23h, 02h, 07h, 00h, 07h
		db	 00h, 0Fh, 00h, 0Fh, 00h, 1Eh
		db	 00h, 1Eh, 00h, 05h, 00h, 04h
		db	 23h, 0Eh, 03h, 9Dh, 02h, 00h
		db	 70h, 3Ah, 10h, 10h,0F9h, 7Dh
		db	 78h, 60h,0FCh, 3Ch,0FCh, 10h
		db	0FFh,0C8h,0C3h, 40h, 1Fh,0E1h
		db	 17h,0A1h, 03h,0FCh, 02h,0F4h
		db	 00h, 7Ch, 00h, 54h, 07h, 74h
		db	 07h, 74h, 02h, 68h, 02h, 68h
		db	 06h, 41h, 06h, 41h, 04h, 8Bh
		db	 04h, 8Bh, 05h,0DFh, 05h,0DFh
		db	 0Ah,0E8h, 0Ah,0E9h, 23h, 01h
		db	 01h, 23h, 00h, 06h, 40h, 01h
		db	 70h, 01h, 70h, 05h,0E0h, 05h
		db	0E5h, 5Eh, 80h, 5Eh, 8Fh,0E8h
		db	 00h,0E8h, 5Fh, 23h, 01h, 9Fh
		db	 23h, 00h, 9Bh, 9Fh, 23h, 00h
		db	 57h,0C7h, 00h, 40h, 1Fh,0F3h
		db	 23h, 08h, 40h, 23h, 01h, 40h
		db	 23h, 01h,0A0h, 23h, 01h,0A0h
		db	 23h, 01h,0D0h, 23h, 01h,0D0h
		db	 23h, 01h, 1Fh, 2Ah, 23h, 00h
		db	 3Ch, 55h, 23h, 00h, 74h, 2Ah
		db	 23h, 00h, 68h, 55h, 23h, 00h
		db	0E0h,0AAh, 23h, 00h,0A8h, 54h
		db	 23h, 00h, 54h,0A0h, 23h, 00h
		db	 2Ah, 80h, 00h, 30h, 0Fh,0FBh
		db	 00h, 10h, 47h,0F9h, 23h, 00h
		db	 83h,0FCh, 00h, 08h, 00h,0DCh
		db	 23h, 01h, 75h, 23h, 01h, 36h
		db	 23h, 01h, 09h, 23h, 01h, 05h
		db	 00h, 07h, 00h, 06h, 00h, 1Fh
		db	 00h, 0Fh, 00h, 1Fh, 00h, 16h
		db	 00h,0E7h, 00h,0E2h, 01h,0F8h
		db	 01h,0F0h, 03h,0FFh, 03h,0F4h
		db	 07h,0FFh, 07h,0AAh, 07h,0FEh
		db	 07h,0D4h, 80h, 00h, 80h, 00h
		db	0FFh, 00h, 54h, 00h,0FEh, 00h
		db	0A8h, 00h,0F8h, 00h, 80h, 23h
		db	 03h,0C0h, 00h, 80h, 00h, 80h
		db	 23h, 0Ah, 03h, 00h, 03h, 00h
		db	 07h, 00h, 07h, 00h, 07h, 00h
		db	 07h, 23h, 03h, 03h, 00h, 02h
		db	 00h, 03h, 00h, 03h, 00h, 03h
		db	 00h, 01h, 1Fh, 00h, 1Ah, 00h
		db	0FFh, 00h,0FAh, 00h,0FAh, 00h
		db	0F0h, 00h,0C7h, 00h, 42h, 00h
		db	 7Fh, 00h, 55h, 00h,0FFh, 00h
		db	0EAh, 00h,0FFh, 00h,0F5h, 00h
		db	0FFh, 80h,0FAh, 80h, 0Fh,0FCh
		db	 0Eh,0A8h, 0Fh,0F0h, 0Eh,0A0h
		db	 03h,0E0h, 01h, 40h, 78h, 00h
		db	 68h, 00h,0FFh, 80h,0E9h, 80h
		db	0FFh,0F0h,0D3h, 20h,0F7h,0EEh
		db	0D2h, 8Ah, 01h,0BFh, 01h, 34h
		db	0FFh, 80h,0F5h, 00h,0FFh, 80h
		db	0FAh, 80h, 7Fh,0E0h, 75h, 40h
		db	0F8h, 00h,0E8h, 00h, 01h,0D0h
		db	 00h,0D0h, 3Fh,0FDh, 3Ch,0F1h
		db	 3Eh,0F7h, 3Ch, 47h, 3Eh,0DFh
		db	 3Ah, 9Ah
		db	0Ch, '6', 0Ch, '6', 9, '<', 9, '<'
		db	 0Eh, 71h, 0Eh, 71h, 0Ch, 5Fh
		db	 0Ch, 5Fh, 11h, 7Eh, 11h, 7Eh
		db	 1Fh,0E0h, 1Fh,0E1h, 23h, 01h
		db	 0Bh, 23h, 01h, 1Fh, 07h,0C0h
		db	 07h,0C1h, 2Fh, 80h, 2Fh, 82h
		db	 7Eh, 00h, 7Eh, 44h,0C0h, 00h
		db	0C2h,0CAh, 23h, 00h, 0Bh, 45h
		db	 23h, 00h, 2Eh, 8Ah, 23h, 00h
		db	 3Fh, 45h, 23h, 00h, 7Eh,0CAh
		db	 23h, 04h, 80h, 23h, 01h, 80h
		db	 23h, 01h,0C0h, 23h, 01h, 40h
		db	 23h, 01h,0A0h, 23h, 01h, 60h
		db	 23h, 01h,0A0h, 23h, 00h, 02h
		db	 00h, 1Fh, 00h, 02h, 00h, 3Fh
		db	 00h, 03h, 00h, 1Fh, 00h, 02h
		db	 00h, 3Eh, 00h, 02h, 00h, 1Fh
		db	 23h, 01h, 3Ch, 23h, 01h, 1Ah
		db	 23h, 01h, 20h, 23h, 00h, 3Fh
		db	 41h, 23h, 00h, 5Eh, 82h, 23h
		db	 00h, 7Dh, 85h, 23h, 00h,0BEh
		db	 0Ah, 23h, 00h, 7Dh, 2Dh, 23h
		db	 00h,0D7h, 0Ah, 00h, 50h,0ECh
		db	 6Dh, 00h, 5Fh, 00h, 05h, 23h
		db	 00h, 50h, 23h, 01h,0A0h, 23h
		db	 01h, 48h, 23h, 01h,0A0h, 23h
		db	 01h, 50h, 23h, 01h,0A0h, 23h
		db	 03h,0C0h, 23h, 02h, 7Fh, 00h
		db	 7Fh, 01h, 7Fh, 01h, 68h, 03h
		db	0F0h, 02h, 80h, 00h, 0Fh, 00h
		db	 05h, 03h,0FFh, 03h,0FAh, 07h
		db	0FFh, 07h,0F4h, 07h,0FEh, 07h
		db	0E8h, 0Fh,0FCh, 0Fh,0D0h,0E4h
		db	 2Fh, 40h, 05h,0E3h, 80h,0A2h
		db	 80h, 07h,0F0h, 05h, 50h,0CFh
		db	0E0h, 0Ah,0A0h, 8Fh,0C0h, 00h
		db	 40h, 0Fh, 80h, 02h, 80h
		db	2Fh

locloop_11:
		add	[di],al
		add	[bp],bl
		inc	dx
		add	[bx],bl
		clc				; Clear carry flag
		pop	ds
		mov	al,ds:data_23e
		pop	ds
		test	al,1Fh
		clc				; Clear carry flag
		pop	ds
		push	ax
		mov	ax,ds:data_1e
		add	dh,ds:data_3e[si]
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		dec	byte ptr ds:data_2e
		sti				; Enable interrupts
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		jns	$+11h			; Jump if not sign
		dec	word ptr [bp+si]
		stosb				; Store al to es:[di]
		mov	al,ds:data_4e
;*		add	[bp+di+0],al
		db	 00h, 43h, 00h		;  Fixup - byte match
		db	 03h, 00h, 1Fh, 00h, 15h, 00h
		db	 5Fh, 80h, 4Ah, 80h,0ABh,0E0h
		db	 02h,0A0h, 02h,0E0h, 00h,0A0h
		db	0F8h,0BCh,0A8h, 14h,0FEh, 1Eh
		db	0A8h, 0Ah, 02h, 00h,0BEh,0B2h
		db	0B0h, 00h,0FFh,0F4h, 23h, 00h
		db	0FFh, 48h, 23h, 00h,0DAh,0A0h
		db	 23h, 00h, 24h, 23h, 00h, 10h
		db	 00h, 10h, 00h, 28h, 00h, 28h
		db	 05h, 08h, 05h, 08h, 23h, 05h
		db	 07h, 23h, 01h, 3Fh, 00h, 40h
		db	 00h,0FFh, 01h, 00h, 07h,0FFh
		db	 06h, 00h, 1Fh,0FDh, 10h, 00h
		db	 3Fh,0F4h, 23h, 00h,0FFh,0F0h
		db	 00h, 02h,0A4h, 02h, 23h, 00h
		db	 6Ah, 14h, 00h, 08h,0FAh, 3Fh
		db	 00h, 18h,0F0h, 7Fh, 00h, 20h
		db	 60h,0FFh, 00h, 20h, 00h,0FFh
		db	 23h, 00h, 11h,0BFh, 00h,0DAh
		db	0A9h,0DFh,0DFh, 64h,0DFh, 64h
		db	 02h,0F8h, 02h,0F8h, 00h, 2Ch
		db	0A0h, 2Ch, 00h, 08h,0FCh, 88h
		db	 23h, 00h,0F3h, 50h, 23h, 00h
		db	0D7h, 90h, 23h, 00h,0CBh,0A0h
		db	 23h, 00h,0AFh, 40h, 23h, 00h
		db	0EEh, 65h, 20h, 00h,0FDh,0A8h
		db	 23h, 00h,0F9h,0D5h, 00h, 07h
		db	0FCh,0C7h, 00h, 3Fh, 5Ch, 3Eh
		db	 03h, 7Fh, 0Fh, 7Eh, 00h, 5Bh
		db	 00h, 5Ah, 00h, 01h, 00h, 01h
		db	 00h,0C0h, 41h,0DEh, 00h, 80h
		db	 01h,0FBh, 00h, 40h, 00h,0FEh
		db	0C0h, 00h, 40h, 9Dh,0E0h, 00h
		db	0A0h, 2Ah,0D8h, 00h, 88h, 0Bh
		db	 5Fh, 00h, 15h, 00h,0FFh, 80h
		db	0FAh, 80h, 23h, 00h, 79h, 80h
		db	 23h, 00h, 53h, 23h, 00h, 30h
		db	0A2h, 30h, 00h, 70h, 50h, 50h
		db	 00h, 6Ch,0A8h, 64h, 03h,0D6h
		db	 43h,0C2h,0FFh,0EFh,0BFh, 4Ah
		db	 08h,0BFh, 08h, 3Ah, 23h, 00h
		db	 01h, 9Eh, 23h, 01h,0CAh, 0Ch
		db	 00h, 04h, 45h, 0Eh, 00h, 0Eh
		db	 0Ah, 16h, 00h, 16h, 15h, 1Bh
		db	0C0h, 1Bh, 42h, 0Dh,0FFh, 08h
		db	0D4h, 0Fh,0B0h, 0Eh, 80h,0FFh
		db	0E0h,0FAh,0A0h, 3Fh,0F0h, 3Dh
		db	 50h, 07h, 80h, 07h, 80h, 00h
		db	 1Eh, 00h, 1Ah, 01h,0BFh, 01h
		db	 9Dh, 0Fh,0DFh, 0Fh,0CFh,0F7h
		db	0E0h,0F1h,0E0h,0FDh, 80h,0D4h
		db	 80h, 00h,0FEh, 00h,0FAh, 00h
		db	 78h, 00h, 18h, 00h, 01h, 00h
		db	 01h, 00h, 01h, 23h, 01h, 1Fh
		db	 00h, 17h, 00h, 15h, 23h, 00h
		db	 01h,0FFh, 01h, 7Fh, 03h,0FEh
		db	 02h,0EAh, 23h, 02h, 60h, 00h
		db	 60h, 00h,0F8h, 00h, 68h, 00h
		db	 7Ch, 00h, 54h, 00h,0B8h, 00h
		db	 38h, 00h, 40h, 23h, 01h,0C0h
		db	 00h, 40h, 23h, 04h, 01h, 00h
		db	 01h, 00h,0FFh, 00h,0BFh, 00h
		db	 7Fh, 00h, 5Fh, 00h, 1Fh, 00h
		db	 17h, 23h, 03h, 03h, 00h, 03h
		db	 00h, 01h, 00h, 01h, 23h, 02h
		db	0E0h, 00h, 60h, 00h,0F8h, 00h
		db	0F0h, 00h,0F8h, 00h,0E0h, 00h
		db	0E7h, 00h, 46h, 00h, 1Fh, 80h
		db	 1Dh, 00h,0FFh,0C0h,0FEh, 80h
		db	0FFh,0E0h,0FFh, 40h, 7Fh,0E0h
		db	 7Fh, 40h, 3Fh,0E0h, 3Eh,0A0h
		db	 0Fh,0F0h, 0Fh, 50h, 07h, 84h
		db	 07h, 84h, 00h, 3Eh, 00h, 2Ah
		db	 01h, 6Fh, 01h, 09h, 01h, 9Fh
		db	 01h, 8Bh, 01h,0F4h, 01h,0D0h
		db	 03h,0E0h, 03h,0A0h, 03h,0E0h
		db	 03h,0A0h, 07h,0C0h, 07h, 40h
		db	 07h, 80h, 07h, 00h, 0Eh, 00h
		db	 0Ch, 23h, 0Fh, 01h, 00h, 4Dh
		db	 7Dh, 00h, 2Ch, 2Fh,0FFh, 23h
		db	 00h, 12h,0FFh, 23h, 00h, 05h
		db	 5Bh, 23h, 01h, 24h, 02h, 80h
		db	 02h, 80h, 15h, 10h, 15h, 10h
		db	 26h,0B6h, 26h,0B6h, 26h,0FBh
		db	 26h,0FBh, 1Bh, 60h, 1Bh, 60h
		db	 34h, 00h, 34h, 05h, 10h, 00h
		db	 11h, 3Fh, 23h, 00h, 0Bh,0CFh
		db	 00h, 80h, 0Bh,0F3h, 00h, 18h
		db	 05h,0FBh, 00h, 04h, 02h,0FDh
		db	 40h, 00h, 40h, 25h, 23h, 00h
		db	 28h, 56h, 23h, 00h,0ACh, 5Ah
		db	 23h, 00h,0AAh, 0Fh, 23h, 00h
		db	0E9h, 06h, 23h, 00h,0F5h, 23h
		db	 01h,0F4h, 88h, 68h, 00h,0FAh
		db	 95h, 23h, 04h,0A0h, 23h, 01h
		db	0ACh, 23h, 01h, 55h, 23h, 01h
		db	0EBh, 40h, 23h, 00h,0BDh, 28h
		db	 23h, 00h, 2Eh, 94h, 23h, 00h
		db	 0Fh, 54h, 23h, 00h, 01h, 9Eh
		db	 23h, 01h,0CAh, 0Ch, 00h, 04h
		db	 45h, 0Eh, 00h, 0Eh, 0Ah, 36h
		db	 00h, 26h, 15h, 6Bh,0C0h, 63h
		db	 42h,0F7h,0FFh,0D2h,0D4h,0FDh
		db	 30h, 54h, 00h,0C0h, 00h,0FAh
		db	 82h, 80h, 00h,0FAh, 80h, 23h
		db	 00h,0FDh, 23h, 00h, 03h,0FDh
		db	 02h, 00h, 07h, 54h, 05h, 00h
		db	 1Bh,0D0h, 11h, 00h,0FAh, 00h
		db	0D8h, 01h,0FFh, 01h,0D5h, 23h
		db	 00h,0A7h, 55h, 23h, 00h, 17h
		db	 55h, 23h, 00h,0AAh,0C9h,0E0h
		db	 00h,0A3h, 14h,0FCh, 00h, 54h
		db	 28h,0FEh,0C0h, 54h, 70h,0DAh
		db	 00h, 52h, 00h,0A0h, 23h, 06h
		db	 06h, 00h, 06h, 00h, 1Fh, 00h
		db	 1Eh, 00h
data_16		db	3Eh			; Data table (indexed access)
		db	 00h, 3Ah, 00h, 1Dh, 00h, 1Ch
		db	 00h, 02h, 23h, 01h, 03h, 00h
		db	 02h, 23h, 02h, 7Fh, 40h, 54h
		db	 00h, 1Eh, 80h, 10h, 00h, 81h
		db	 00h, 80h, 00h, 80h, 23h, 01h
		db	0F8h, 00h,0E8h, 00h,0A8h, 23h
		db	 01h,0FFh, 80h,0FAh, 80h, 7Fh
		db	0C0h, 55h, 40h, 07h,0FFh, 07h
		db	 55h, 0Fh,0FDh, 0Eh,0A8h, 01h
		db	0E0h, 01h, 40h, 78h, 00h, 50h
		db	 00h,0FDh,0A8h,0A9h, 80h,0FBh
		db	0FDh, 53h, 50h, 07h,0EFh, 06h
		db	 86h, 01h,0BFh, 01h, 28h, 00h
		db	 07h, 00h, 06h, 00h, 1Fh, 00h
		db	 0Fh, 00h, 1Fh, 00h, 17h, 00h
		db	0E7h, 00h,0E2h, 01h,0F8h, 01h
		db	0F8h, 03h,0FFh, 03h,0FEh, 07h
		db	0FFh, 07h,0FAh, 07h,0FEh, 07h
		db	0F4h, 80h, 00h, 80h, 00h,0FFh
		db	 00h,0F4h, 00h,0FEh, 00h,0E8h
		db	 00h,0F8h, 00h,0C0h, 23h, 03h
		db	0C0h, 00h, 80h, 00h, 80h, 23h
		db	 05h, 07h,0FCh, 07h,0D4h, 0Fh
		db	0F0h, 0Eh,0A0h, 21h,0E0h, 21h
		db	 40h, 7Ch, 00h, 7Ch, 00h,0FEh
		db	 80h,0F8h, 80h,0F9h, 80h,0D1h
		db	 80h, 2Fh, 80h, 0Bh, 80h, 07h
		db	0C0h, 07h, 40h, 07h,0C0h, 07h
		db	 40h, 03h,0E0h, 02h,0A0h, 01h
		db	0E0h, 00h,0A0h, 00h, 70h, 00h
		db	 10h, 23h, 25h, 02h, 23h, 01h
		db	 02h, 23h, 01h, 06h, 02h, 05h
		db	 02h,0A5h, 0Ch, 8Dh, 0Ch,0E9h
		db	 30h, 07h, 36h,0A4h, 01h,0A5h
		db	 2Bh,0F4h, 04h, 01h, 3Fh,0E1h
		db	 30h, 00h, 7Fh,0E1h, 00h, 01h
		db	0FFh,0C1h, 40h, 01h,0FFh,0C7h
		db	 23h, 01h, 0Eh, 00h, 08h, 00h
		db	 1Eh, 00h, 0Ch, 00h, 1Eh, 00h
		db	 10h, 00h, 3Fh, 00h, 10h, 00h
		db	 3Eh, 23h, 00h, 05h, 8Fh, 06h
		db	 00h, 1Fh,0F6h, 50h, 00h,0FFh
		db	0FDh, 00h,0A0h
data_17		db	2			; Data table (indexed access)
		db	0FFh, 04h, 02h, 0Fh,0A7h, 00h
		db	 03h, 0Dh, 03h, 00h, 04h, 16h
		db	 17h, 01h,0B0h, 18h, 08h, 04h
		db	 00h, 08h, 00h, 03h, 23h, 07h
		db	0FEh, 9Ah, 23h, 00h,0E8h, 54h
		db	 23h, 00h,0BAh,0A0h, 23h, 00h
		db	 50h, 23h, 10h, 16h, 23h, 05h
		db	 03h, 23h, 16h,0D4h, 23h, 01h
		db	 1Eh,0D1h, 81h, 02h, 33h,0DFh
		db	 00h, 30h, 00h, 7Eh, 00h, 40h
		db	 01h,0F8h, 2Ch, 00h, 02h, 80h
		db	 23h, 09h,0ADh, 00h, 8Dh, 5Bh
		db	0FFh, 40h, 00h,0FFh,0DAh, 02h
		db	 80h,0EFh,0FFh, 00h, 08h, 15h
		db	 7Eh, 23h, 0Ch, 40h, 23h, 00h
		db	 28h,0F2h,0FAh, 05h, 81h,0DFh
		db	0FFh, 23h, 00h,0EBh,0FFh, 23h
		db	 00h,0B5h, 75h, 23h, 01h, 2Ah
		db	 23h, 06h, 2Eh, 05h, 2Eh,0A5h
		db	 10h, 8Dh, 12h,0E9h, 00h, 07h
		db	 06h,0A4h, 01h,0A5h, 2Bh,0F4h
		db	 04h, 01h, 3Fh,0E1h, 30h, 00h
		db	 7Fh,0E1h, 00h, 01h,0FFh,0C1h
		db	 40h, 01h,0FFh,0C7h, 23h, 09h
		db	 05h, 00h, 02h, 00h, 16h, 00h
		db	 0Ch, 00h, 3Fh, 00h, 40h, 00h
		db	0FFh, 01h, 00h, 07h,0FDh, 23h
		db	 00h, 0Fh,0EAh, 23h, 13h, 01h
		db	 00h, 07h, 00h,0A0h, 00h, 1Eh
		db	 03h, 23h, 00h, 01h, 23h, 01h
		db	 05h, 00h, 0Ch, 00h, 2Fh, 23h
		db	 01h, 7Eh, 00h, 80h, 01h,0F3h
		db	 1Ch, 00h, 3Fh, 7Fh, 23h, 00h
		db	0FFh,0A8h, 23h, 00h, 0Eh, 80h
		db	 23h, 00h, 8Dh, 00h, 80h, 00h
		db	0FBh, 75h, 08h, 00h,0EEh,0A0h
		db	 40h, 00h
		db	 7Dh, 40h, 23h
loc_12:
;*		add	ch,dh
		db	 00h,0F5h		;  Fixup - byte match
		and	ax,[bx+di]
		push	ax
		and	cx,[si]
		or	[bx+si],al
		push	es
		add	[bx+si+23h],ah
		sbb	dl,[bx+si]
;*		add	[bx+si+0],ah
		db	 00h, 60h, 00h		;  Fixup - byte match
		db	 10h, 00h, 80h, 23h, 15h,0A0h
		db	 00h,0A5h, 00h,0B1h, 28h, 97h
		db	 28h,0E0h, 04h, 25h, 64h,0A5h
		db	 80h, 2Fh,0D4h, 80h, 20h, 87h
		db	0FCh, 00h, 0Ch, 87h,0FEh, 80h
		db	 00h, 83h,0FFh, 80h, 02h,0E3h
		db	0FFh, 23h, 14h, 40h, 23h, 01h
		db	 40h, 23h, 01h, 60h, 23h, 01h
		db	 70h, 00h, 10h, 00h, 78h, 00h
		db	 08h, 00h, 78h, 23h, 01h,0FCh
		db	 23h, 01h, 7Ch, 23h, 01h,0F1h
		db	0A0h, 00h, 40h, 6Fh,0F8h, 00h
		db	 02h,0BFh,0FFh, 23h, 00h, 59h
		db	 7Fh, 23h, 00h, 2Ah, 17h, 23h
		db	 00h, 05h, 5Dh, 23h, 01h, 0Ah
		db	 23h, 0Eh, 04h, 00h,0FFh, 40h
		db	0C0h, 00h,0E5h,0E0h, 80h, 20h
		db	0C0h,0B0h, 20h, 00h,0E8h, 68h
		db	 0Dh, 80h, 10h, 18h, 00h, 20h
		db	 00h, 10h, 00h,0C0h, 23h, 04h
		db	0A0h, 0Dh,0A5h, 0Dh,0B1h, 00h
		db	 97h, 40h,0E0h, 00h, 25h, 60h
		db	0A0h, 00h, 2Fh,0D4h, 80h, 00h
		db	 87h,0F4h, 03h, 00h, 87h,0FAh
		db	 01h, 00h, 83h,0FDh, 00h, 40h
		db	0E3h,0FDh, 23h, 01h, 02h, 04h
		db	 00h, 5Fh, 4Fh, 00h,0B0h,0FFh
		db	0FBh, 23h, 00h,0FFh,0D7h, 23h
		db	 00h,0AEh,0ADh, 23h, 00h, 54h
		db	 23h, 09h,0B5h, 00h,0B1h, 00h
		db	0FFh,0DAh, 00h, 02h, 5Bh,0FFh
		db	 01h, 40h,0FFh,0F7h, 10h, 00h
		db	 7Eh,0A8h, 23h, 0Dh, 2Bh, 02h
		db	 60h, 8Bh, 78h, 40h, 01h,0FBh
		db	0CCh, 30h, 00h, 7Eh, 00h, 08h
		db	 00h, 1Fh, 80h, 00h, 34h, 01h
		db	 40h, 23h, 06h, 68h, 23h, 05h
		db	0C0h, 23h, 1Fh,0A0h, 23h, 01h
		db	 68h, 23h, 01h,0FCh, 00h, 02h
		db	 00h, 7Fh, 23h, 00h, 80h, 3Fh
		db	0E0h, 23h, 00h, 17h,0F0h, 00h
		db	 01h, 16h,0DFh, 23h, 00h, 05h
		db	 77h, 00h, 91h, 00h,0BEh, 23h
		db	 01h,0AFh, 23h, 01h, 0Ah, 23h
		db	 0Ch,0A0h, 00h, 20h, 00h,0F4h
		db	 23h, 01h, 7Eh, 00h, 01h, 00h
		db	0CFh, 80h, 00h, 30h,0FEh,0FCh
		db	 23h, 00h, 15h,0FFh, 23h, 00h
		db	 01h, 70h, 23h, 01h,0B1h, 23h
		db	 12h, 80h, 00h,0E0h, 00h, 05h
		db	 00h, 78h, 23h, 00h,0C0h, 80h
		db	 23h, 02h, 08h, 00h, 06h, 00h
		db	 08h, 00h, 01h, 23h, 14h, 10h
		db	 00h, 60h, 00h, 06h, 23h, 1Ch
		db	 2Ch, 23h, 00h, 01h,0FBh, 01h
		db	 00h, 07h,0DFh, 02h, 00h, 07h
		db	0FFh, 23h, 00h, 07h,0F5h, 00h
		db	 08h, 08h,0EFh, 23h, 00h, 06h
		db	0EDh, 23h, 00h, 03h, 76h, 23h
		db	 00h,0A8h, 23h, 01h, 5Ah,0D5h
		db	 00h,0A0h,0FFh,0FAh, 23h, 00h
		db	0FFh,0FEh, 80h, 00h,0FFh,0ABh
		db	 23h, 00h,0F0h, 44h, 23h, 00h
		db	 54h, 23h, 01h,0AAh, 20h, 23h
		db	 03h,0BFh, 00h,0BEh, 00h, 5Fh
		db	 00h, 5Fh, 00h, 17h, 00h, 17h
		db	 00h, 01h, 23h, 01h, 03h, 00h
		db	 03h, 00h, 01h, 00h, 01h, 23h
		db	 04h, 04h, 50h,0E0h, 00h, 80h
		db	 01h,0FCh, 00h,0E8h, 02h,0F7h
		db	 00h,0E2h, 07h, 5Fh, 80h, 15h
		db	 0Fh,0FFh,0C0h,0FEh, 8Dh,0FFh
		db	0E0h,0FFh, 4Fh, 7Fh,0C0h, 7Fh
		db	 5Fh, 01h,0F0h, 75h,0F0h, 00h
		db	0FAh,0DCh,0FAh, 00h, 3Fh,0F6h
		db	 3Fh, 00h, 03h,0FFh, 07h, 23h
		db	 00h,0F9h, 90h, 20h, 00h,0F9h
		db	0F9h, 40h, 00h
loc_14:
		sar	dx,cl			; Shift w/sign fill
		add	byte ptr [bx+si],0A7h
		clc				; Clear carry flag
		push	ax
		and	[bx+si-1Ah],bl
		add	[bx+si],al
		and	[bx+si],al
;*		add	byte ptr [bx+si],82h
		db	 82h, 00h, 82h		;  Fixup - byte match
;*		add	ah,dh
		db	 00h,0F4h		;  Fixup - byte match
		push	ax
		hlt				; Halt processor
		push	ax
		jge	$+2			; delay for I/O
		jge	$+2			; delay for I/O
		pop	es
                           lock	pop	es
                           lock	and	ax,ds:data_6e
		db	 3Eh,0AFh, 0Fh,0E0h, 0Fh, 5Fh
		db	 07h,0C0h, 07h, 9Bh, 23h, 01h
		db	 3Dh, 01h, 80h, 01h,0BDh, 0Fh
		db	 80h, 0Fh,0BEh, 75h,0E0h, 71h
		db	0C5h,0FDh,0D4h,0FCh, 81h, 80h
		db	 00h,0CFh,0F0h, 80h, 00h,0CEh
		db	0E0h, 23h, 00h, 9Dh,0C0h, 80h
		db	 0Fh,0ABh, 1Dh, 00h, 1Fh, 86h
		db	 1Eh, 00h, 1Fh, 4Eh, 5Fh, 00h
		db	 1Fh, 97h, 5Dh, 00h, 3Fh,0B2h
		db	0BDh, 23h, 02h, 03h,0FAh, 02h
		db	0AAh, 7Fh,0FFh, 55h,0FEh, 49h
		db	 00h

locloop_15:
		jg	locloop_15		; Jump if >
		dec	cx
		add	ds:data_7e[bx],bh
		call	$-573Fh
		mov	si,data_5e
		and	ax,[bx+si]
		add	ax,[bx+si]
		add	bl,[bx+si]
		add	[bx+si],bl
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
;*		add	[di+0],dl
		db	 00h, 55h, 00h		;  Fixup - byte match
		db	 7Ah, 00h, 58h, 00h,0AAh, 00h
		db	 0Ah, 00h, 2Ah, 00h, 20h, 00h
		db	 3Ah, 00h, 32h, 00h, 7Eh, 00h
		db	 7Ah, 00h,0FCh, 00h,0FCh, 23h
		db	 01h, 10h, 2Ch, 60h, 50h, 11h
		db	0FBh, 81h, 80h, 07h,0DFh, 02h
		db	 00h, 07h,0FFh, 02h, 00h, 07h
		db	0F5h, 00h, 08h, 08h,0EFh, 23h
		db	 00h, 06h,0EDh, 23h, 00h, 03h
		db	 76h, 23h, 01h, 15h, 00h, 0Dh
		db	0AAh,0FFh, 04h, 00h, 5Fh,0FFh
		db	 23h, 00h, 7Fh,0FFh, 23h, 00h
		db	0D4h, 81h, 23h, 01h, 3Ch, 23h
		db	 01h,0A8h, 23h, 00h, 04h, 55h
		db	 23h, 00h, 34h, 23h, 01h,0EAh
		db	 80h, 23h, 00h,0FAh, 40h, 23h
		db	 00h,0FDh, 20h, 0Ch, 00h,0AEh
		db	0A0h, 02h, 00h,0F7h, 10h, 23h
		db	 00h,0BDh, 20h, 23h, 00h, 6Ah
		db	 40h, 04h,0B2h, 04h,0B2h
		db	0Ch, '$'
		db	0Ch, '$'
		db	8, 'A', 8, 'A', 0Ah, '/', 0Ah, '/'
		db	 00h,0BEh, 00h,0BEh, 0Fh,0E0h
		db	 0Fh,0E0h, 23h, 06h, 0Fh, 80h
		db	 0Fh,0AEh, 5Fh, 00h, 5Fh, 3Bh
		db	0FCh, 00h,0FCh, 6Fh,0C0h, 00h
		db	0E0h,0FFh, 23h, 00h, 09h, 9Fh
		db	 23h, 00h, 9Fh, 9Fh, 02h, 80h
		db	 5Fh,0CBh, 01h, 00h, 1Fh,0E5h
		db	 23h, 01h, 20h, 00h, 07h, 80h
		db	 01h, 00h, 3Fh, 40h, 15h, 00h
		db	0EFh

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_7:
		loopnz	locloop_16		; Loop if zf=0, cx>0

;*		add	dx,bx
		db	 01h,0DAh		;  Fixup - byte match
		db	0F1h, 88h, 01h,0BFh,0B0h, 15h
		db	 01h, 5Fh,0F0h, 08h, 00h,0AAh
		db	0F8h, 23h, 03h,0FDh, 00h, 68h
		db	 00h,0FAh, 00h,0D0h, 00h,0E8h
		db	 00h,0C0h, 00h, 80h, 23h, 01h
		db	0C0h, 23h, 01h, 80h, 23h, 06h
		db	 18h, 00h, 18h, 00h,0FFh, 00h
		db	0FEh, 00h, 7Eh, 00h, 3Ah, 00h
		db	 55h, 00h, 50h, 00h, 54h, 00h
		db	 04h, 00h, 5Ch, 00h, 4Ch, 00h
		db	 7Eh, 00h, 5Eh, 00h, 3Fh, 00h
		db	 3Fh, 23h, 02h, 5Fh,0C0h, 5Dh
		db	 40h,0FFh,0FEh, 7Fh,0AAh, 49h
		db	 00h, 7Fh,0FEh, 49h, 00h,0BFh
		db	0FDh, 17h,0FFh, 15h, 7Dh, 00h
		db	 7Dh, 00h, 55h,0C0h, 00h, 40h
		db	 23h, 00h,0C0h

locloop_16:
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		db	0F3h, 00h, 40h, 07h,0F3h, 00h
		db	 40h, 03h,0F9h,0F0h, 00h,0B8h
		db	0D5h,0F8h, 40h,0F0h, 61h,0F8h
		db	0C0h,0E2h,0F2h,0F8h, 00h, 92h
		db	0E9h,0FCh, 00h,0A9h, 4Dh, 01h
		db	 54h,0F0h, 23h, 00h,0A0h,0F8h
		db	 23h, 00h, 40h,0D8h, 23h, 01h
		db	0BCh, 23h, 00h, 80h,0BCh, 80h
		db	 00h,0B0h, 7Ch,0B0h, 05h, 2Eh
		db	0A1h, 0Ch, 2Bh,0BFh, 81h, 0Ah
		db	 23h, 00h, 34h, 08h, 00h, 06h
		db	0EAh, 88h, 00h, 01h,0FAh, 40h
		db	 23h, 00h,0FDh, 20h, 0Ch, 00h
		db	0AEh,0A0h, 02h, 00h,0F7h, 10h
		db	 23h, 00h,0BDh, 20h, 23h, 00h
		db	 6Ah, 40h, 23h, 03h, 02h, 23h
		db	 01h, 2Bh, 23h, 00h, 02h,0FFh
		db	 23h, 00h, 07h,0BFh, 23h, 00h
		db	 0Eh,0FFh, 00h, 0Bh, 1Fh,0FFh
		db	 00h, 2Bh, 3Dh,0FFh, 08h, 6Fh
		db	 00h, 13h, 23h, 00h, 25h, 5Ch
		db	 23h, 00h, 6Fh, 7Ah, 00h, 30h
		db	0FFh,0F6h, 0Ah,0C0h,0FFh,0F4h
		db	0D5h

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_8:
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
;*		aam	58h			; 'X' undocumented inst
		db	0D4h, 58h		;  Fixup - byte match
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		cbw				; Convrt byte to word
		test	byte ptr [bx+si],0FFh
		db	 68h,0ECh, 00h, 1Bh,0FFh, 01h
		db	0FFh, 3Bh,0FFh, 18h,0EFh, 1Ch
		db	0AFh, 04h, 27h, 0Eh,0B5h, 00h
		db	 30h, 07h,0EFh, 00h, 4Fh, 02h
		db	0FFh, 00h, 02h, 00h, 0Ah, 23h
		db	 04h,0FFh,0B4h,0FAh, 20h,0FEh
		db	 68h,0D8h, 00h,0F5h, 98h,0A1h
		db	 80h, 7Eh,0D0h, 08h, 00h, 93h
		db	 40h, 80h, 00h,0D5h, 23h, 01h
		db	0D0h, 23h, 05h,0C8h, 23h, 01h
		db	 3Ah,0A4h, 23h, 00h, 5Eh,0F6h
		db	 0Ch, 00h, 6Fh,0FFh, 03h, 50h
		db	 2Fh,0FFh, 00h,0ABh, 2Bh,0FFh
		db	 00h, 1Ah, 19h,0FFh, 00h, 6Fh
		db	 16h,0FFh, 00h, 37h, 23h, 02h
		db	 40h, 23h, 01h,0D4h, 23h, 01h
		db	0FFh, 40h, 23h, 00h,0FDh,0E0h
		db	 23h, 00h,0FFh, 70h,0D0h, 00h
		db	0FFh,0F8h,0D4h, 00h,0FFh,0BCh
		db	0F6h, 10h, 2Dh,0FFh, 04h, 5Fh
		db	 16h, 7Fh, 00h, 1Bh, 19h,0AFh
		db	 01h, 85h, 0Bh, 7Eh, 00h, 10h
		db	 02h,0C9h, 00h, 01h, 00h,0ABh
		db	 23h, 01h, 0Bh, 23h, 04h,0FFh
		db	0D8h,0FFh, 80h,0FFh,0DCh,0F7h
		db	 18h,0F5h, 38h,0E4h, 20h,0ADh
		db	 70h, 0Ch, 00h,0F7h,0E0h,0F2h
		db	 00h,0FFh, 73h, 00h, 00h, 50h
		db	 23h, 09h, 10h, 80h, 23h, 00h
		db	 30h, 23h, 01h, 10h, 23h, 05h
		db	 20h, 23h, 02h, 01h, 23h, 00h
		db	 10h, 05h, 23h, 01h, 88h, 23h
		db	 01h, 18h, 23h, 00h, 42h, 1Ch
		db	 23h, 01h, 0Ah, 23h, 00h, 40h
		db	 08h, 23h, 00h, 40h, 08h, 23h
		db	 00h, 51h, 23h, 01h,0B0h, 08h
		db	 23h, 00h, 02h, 05h, 23h, 01h
		db	 07h, 00h, 01h, 10h, 8Fh, 00h
		db	 03h, 14h, 0Bh, 00h, 01h, 3Ah
		db	 17h, 08h, 00h, 5Eh,0BFh, 18h
		db	 03h, 7Bh,0DBh, 12h, 00h,0D7h
		db	0EFh, 00h, 08h, 62h, 00h, 20h
		db	 00h,0B4h, 23h, 01h,0E5h, 04h
		db	 40h, 00h, 4Eh, 94h, 04h, 00h
		db	 47h, 0Eh, 42h, 04h,0DAh, 92h
		db	 80h, 00h,0ADh,0EDh, 84h, 44h
		db	 7Eh,0AFh, 10h, 23h, 04h, 20h
		db	 23h, 01h, 04h, 23h, 01h, 81h
		db	 23h, 01h, 03h, 23h, 00h, 20h
		db	 07h, 00h, 01h, 00h, 02h, 23h
		db	 01h, 04h, 23h, 04h, 40h, 80h
		db	 23h, 04h, 08h, 23h, 01h, 40h
		db	 23h, 02h, 04h, 23h, 00h,0C0h
		db	 00h, 80h, 00h, 80h, 23h, 01h
		db	 28h, 23h, 02h, 02h, 23h, 00h
		db	 08h, 23h, 01h, 20h, 0Dh, 23h
		db	 00h, 1Ah, 1Ch, 10h, 08h, 2Fh
		db	 32h, 04h, 00h, 74h,0A5h, 00h
		db	 01h,0FAh, 9Dh, 30h, 00h, 20h
		db	 02h, 23h, 01h, 80h, 23h, 00h
		db	 80h, 04h, 23h, 01h, 44h, 23h
		db	 00h, 43h, 0Ch, 23h, 00h,0E8h
		db	0DEh,0C0h, 08h,0D1h,0BBh, 00h
		db	 10h, 2Eh, 6Fh, 23h, 01h, 03h
		db	 23h, 00h, 01h, 02h, 23h, 01h
		db	 05h, 23h, 01h
loc_17:
		adc	[bp+di],ah
		add	[bp+si],ax
		and	ax,[bx+si]
		and	[bp+di],ah
		or	ax,23C4h
		add	ds:data_25e[bx+si],ax
		and	word ptr [bp+di],4001h
		and	ax,[bp+si]
		add	al,23h			; '#'
		add	ds:data_26e[bx+si],al
		inc	ax
		add	[bp+di],sp
		add	[bx+di],ah
		add	ah,[bp+di]
		add	[bx+si],ah
		add	ax,23h
		jc	$+9			; Jump if carry Set
		add	[bx+di],al
		js	loc_17			; Jump if sign=1
		add	[bp+di],al
		sti				; Enable interrupts
		pop	ss
		and	[bx+di],al
		db	0DDh, 8Bh, 08h, 00h,0F6h, 74h
		db	 40h, 00h, 40h, 14h, 23h, 00h
		db	0C0h, 23h, 01h, 90h, 14h, 23h
		db	 00h,0B0h, 1Ch, 20h, 00h,0B8h
		db	 5Eh, 10h, 08h, 4Ch,0D4h, 23h
		db	 00h,0A5h, 3Eh, 80h, 14h,0B9h
		db	 5Fh, 23h, 00h, 01h, 04h, 23h
		db	 00h, 08h, 01h, 23h, 01h, 40h
		db	 23h, 00h, 40h, 23h, 02h, 02h
		db	 23h, 00h, 20h, 02h, 23h, 00h
		db	 70h, 8Ah, 23h, 00h, 70h, 0Fh
		db	 23h, 00h, 80h, 20h, 23h, 00h
		db	 01h, 02h, 23h, 00h, 80h, 23h
		db	 02h, 08h, 23h, 08h, 80h, 04h
		db	 23h, 00h, 20h, 0Eh, 23h, 00h
		db	 20h, 57h, 00h, 04h, 10h, 3Fh
		db	 23h, 00h, 60h,0AFh, 00h, 06h
		db	 29h, 7Fh, 00h, 02h, 70h,0EFh
		db	 00h, 0Bh, 69h, 5Fh, 00h, 06h
		db	0F5h,0B5h, 20h, 01h,0F5h, 7Eh
		db	 00h, 18h, 80h, 4Eh, 23h, 00h
		db	 60h, 0Ah, 40h, 00h,0E1h, 1Ch
		db	 23h, 00h, 70h, 0Ch, 20h, 00h
		db	0E8h, 56h, 23h, 00h,0FDh, 6Eh
		db	0C0h, 04h,0DBh, 96h, 23h, 00h
		db	0F7h,0EBh, 11h, 23h, 14h,0AEh
		db	 00h,0AEh, 05h, 4Ah, 05h,0FEh
		db	 17h,0B0h, 1Ch, 4Fh, 23h, 12h
		db	0AEh,0A4h,0AEh,0A4h, 80h, 00h
		db	 80h, 00h,0B5h, 20h,0F5h, 20h
		db	 03h, 06h, 3Ch,0F9h, 14h, 00h
		db	 1Fh,0FFh, 05h, 4Ah, 05h,0FEh
		db	 00h,0AEh, 00h,0AEh, 23h, 10h
		db	0FDh,0A4h,0B5h, 20h,0F5h, 20h
		db	 80h, 00h, 80h, 00h,0AEh,0A4h
		db	0AEh,0A4h, 23h, 23h, 15h, 00h
		db	 15h, 00h, 5Ah, 00h, 5Ah, 02h
		db	0BFh, 02h,0BFh, 23h, 07h, 80h
		db	 00h, 80h, 14h, 00h, 14h, 00h
		db	0A0h, 28h,0A0h, 28h, 0Bh, 40h
		db	 0Bh, 64h,0F4h, 20h,0F7h, 60h
		db	0C5h, 02h,0FDh, 02h, 0Bh, 46h
		db	 0Bh,0F9h, 0Dh,0C0h, 0Eh, 3Fh
		db	 36h, 8Bh, 39h, 7Fh, 0Ch, 2Dh
		db	 33h,0FDh, 0Ah,0A0h, 0Ah,0A0h
		db	 23h, 0Ah, 28h, 50h,0E8h, 50h
		db	0D6h, 00h,0D6h, 00h, 50h, 00h
		db	 50h, 23h, 20h, 01h, 00h, 01h
		db	 00h, 03h, 00h, 03h, 00h, 0Eh
		db	 00h, 0Eh, 00h, 1Bh, 00h, 1Bh
		db	 00h, 5Dh, 00h, 5Eh, 23h, 02h
		db	 10h, 00h, 10h, 00h, 20h,0C0h
		db	 20h,0C0h, 42h, 80h, 42h,0C0h
		db	 8Dh, 04h, 8Fh, 04h, 5Ah, 28h
		db	 5Eh, 28h, 8Dh, 60h,0FDh, 60h
		db	 9Bh,0C0h, 7Bh,0C0h, 01h,0D5h
		db	 01h,0FAh, 03h,0B0h, 03h,0CFh
		db	 07h,0E1h, 07h, 1Fh, 0Dh, 86h
		db	 0Eh, 7Eh, 0Ch, 3Ah, 0Fh,0FAh
		db	 05h, 50h, 05h, 50h, 23h, 06h
		db	 35h, 00h,0F5h, 00h,0D4h, 00h
		db	0D4h, 00h,0A8h, 00h,0A8h, 00h
		db	0C0h, 00h,0C0h, 00h, 80h, 00h
		db	 80h, 23h, 1Fh, 25h, 75h, 25h
		db	 75h, 00h, 01h, 00h, 01h, 04h
		db	0ADh, 04h,0AFh, 23h, 12h, 75h
		db	 00h, 75h, 00h, 52h,0A0h, 7Fh
		db	0A0h, 0Dh,0E8h,0F2h, 38h, 23h
		db	 00h, 25h,0BFh, 04h,0ADh, 04h
		db	0AFh, 00h, 01h, 00h, 01h, 25h
		db	 75h, 25h, 75h, 23h, 0Eh, 60h
		db	0C0h, 9Fh, 3Ch, 00h, 28h,0FFh
		db	0F8h, 52h,0A0h, 7Fh,0A0h, 75h
		db	 00h, 75h, 23h, 17h, 01h, 00h
		db	 01h, 23h, 00h, 28h, 00h, 28h
		db	 14h, 05h, 14h, 05h, 02h,0D0h
		db	 26h,0D0h, 04h, 2Fh, 06h,0EFh
		db	 40h,0A3h, 40h,0BFh, 23h, 12h
		db	0A8h, 00h,0A8h, 00h, 5Ah, 00h
		db	 5Ah, 00h,0FDh, 40h,0FDh, 40h
		db	 0Ah, 14h, 0Ah, 17h, 00h, 6Bh
		db	 00h, 6Bh, 00h, 0Ah, 00h, 0Ah
		db	 23h, 12h, 62h,0D0h, 9Fh,0D0h
		db	 03h,0B0h,0FCh, 70h,0D1h, 6Ch
		db	0FEh, 9Ch,0B4h, 30h,0BFh,0CCh
		db	 05h, 50h, 05h, 50h, 23h, 0Fh
		db	 08h, 00h, 08h, 03h, 04h, 03h
		db	 04h, 01h, 42h, 03h, 42h, 20h
		db	0B1h, 20h,0F1h, 14h, 5Ah, 14h
		db	 7Ah, 06h,0B1h, 06h,0BFh, 03h
		db	0D9h, 03h,0DEh, 23h, 0Ah, 80h
		db	 00h, 80h, 00h,0C0h, 00h,0C0h
		db	 00h, 70h, 00h, 70h, 00h,0D8h
		db	 00h,0D8h, 00h,0BAh, 00h, 7Ah
		db	 23h, 00h,0ACh, 00h,0AFh, 00h
		db	 2Bh, 00h, 2Bh, 00h, 15h, 00h
		db	 15h, 00h, 03h, 00h, 03h, 00h
		db	 01h, 00h, 01h, 23h, 0Ah,0ABh
		db	 80h, 5Fh, 80h, 0Dh,0C0h,0F3h
		db	0C0h, 87h,0E0h,0F8h,0E0h, 61h
		db	0B0h, 7Eh, 70h, 5Ch, 30h, 5Fh
		db	0F0h, 0Ah,0A0h, 0Ah,0A0h, 23h
		db	 07h, 01h,0FFh, 47h, 23h, 00h
		db	 5Ch, 87h, 23h, 01h, 05h, 08h
		db	 00h, 1Dh, 03h, 23h, 00h, 12h
		db	 83h, 23h, 00h, 0Bh, 43h, 0Fh
		db	0F8h, 0Dh, 41h, 0Fh,0D0h, 23h
		db	 02h,0FFh, 40h, 80h, 00h,0FEh
		db	 80h, 23h, 00h,0EAh, 23h, 01h
		db	 42h, 00h,0C0h, 00h,0FAh, 00h
		db	 80h, 00h,0FFh, 23h, 01h,0F9h
		db	 80h, 23h, 00h, 5Eh, 23h, 08h
		db	 01h, 00h, 03h, 23h, 01h, 07h
		db	 23h, 01h, 06h, 23h, 01h, 02h
		db	 23h, 09h, 04h, 60h, 2Ch,0FDh
		db	 7Ch, 23h, 00h,0FFh,0FCh, 23h
		db	 00h, 5Fh, 68h, 80h, 00h,0FDh
		db	 2Ah, 23h, 00h,0E8h, 23h, 09h
		db	 08h, 0Bh, 00h, 0Bh, 36h, 7Fh
		db	 40h, 00h, 6Fh,0FFh, 81h, 00h
		db	0E5h,0FDh, 0Bh, 00h,0FFh,0D2h
		db	 23h, 00h, 5Fh,0A0h, 23h, 02h
		db	 01h, 42h, 01h, 42h, 20h, 00h
		db	0EBh, 20h, 23h, 00h,0FFh, 40h
		db	 23h, 00h,0F4h, 80h, 23h, 00h
		db	0AAh, 23h, 01h, 40h, 23h, 0Ch
		db	 40h, 01h, 7Fh, 00h, 20h, 00h
		db	0FFh, 23h, 01h, 3Bh, 23h, 00h
		db	 02h, 86h, 00h, 60h, 01h,0F8h
		db	 00h, 40h, 03h,0FEh, 23h, 00h
		db	 03h,0FDh, 23h, 00h, 07h, 54h
		db	 23h, 00h,0E2h,0F5h, 23h, 00h
		db	0D1h, 2Ah, 23h, 00h,0A0h, 23h
		db	 00h, 10h, 40h,0B8h, 23h, 00h
		db	0A1h, 48h, 23h, 00h, 82h,0D0h
		db	 17h,0D0h, 03h, 80h, 0Bh,0D0h
		db	 23h, 01h, 10h, 04h,0D7h, 00h
		db	 91h, 00h,0FFh, 23h, 00h, 01h
		db	 2Fh, 23h, 01h, 55h, 23h, 01h
		db	 91h, 00h, 80h, 02h, 80h, 05h
		db	 10h, 05h, 10h, 06h,0B6h, 06h
		db	0B6h, 23h, 00h, 50h, 01h,0C0h
		db	 00h,0FAh, 6Ch, 04h, 02h,0FFh
		db	0F6h, 00h, 81h,0BFh,0A7h, 00h
		db	0D0h, 4Bh,0FFh, 23h, 00h, 05h
		db	0FAh, 23h, 02h, 42h, 80h, 42h
		db	 80h, 23h, 03h, 02h, 6Ah,0BFh
		db	 00h, 60h, 77h,0FFh, 00h, 40h
		db	 16h,0FAh, 00h, 10h, 24h,0BFh
		db	 23h, 01h, 17h, 23h, 10h,0C0h
		db	 23h, 01h,0E0h, 23h, 01h, 60h
		db	 23h, 01h, 40h, 23h, 07h
sub_1		endp


seg_a		ends



		end	start
