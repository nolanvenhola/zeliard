
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				_362UNKN                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   5-Apr-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    5          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	1
data_3e		equ	5Ah
data_4e		equ	802h			;*
data_5e		equ	1038h			;*
data_6e		equ	9E01h			;*
data_7e		equ	0EE0Fh			;*
data_8e		equ	1C0h			;*
data_9e		equ	400h			;*
data_10e	equ	1E03h			;*
data_11e	equ	5AE5h			;*
data_32e	equ	2880h			;*
data_33e	equ	3D00h			;*
data_34e	equ	8000h			;*
data_35e	equ	8002h			;*
data_36e	equ	803Ah			;*
data_37e	equ	9E03h			;*
data_38e	equ	0A001h			;*
data_40e	equ	0A0CFh			;*
data_41e	equ	0BEA0h			;*
data_42e	equ	0F803h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_362UNKN	proc	far

start:
		in	ax,dx			; port 0, DMA-1 bas&add ch 0
		sbb	al,[bx+si]
		add	[bx+si],al
		push	es
		pop	dx
		add	[bp-80h],ch
		movsw				; Mov [si] to es:[di]
;*		add	di,sp
		db	 01h,0E7h		;  Fixup - byte match
		add	bh,bh
		call	dword ptr [bp+si+2Dh]	;*
		or	byte ptr [bx+si],20h	; ' '
;*		sbb	al,ah
		db	 18h,0E0h		;  Fixup - byte match
		add	ax,0D7Dh
		jge	loc_1			; Jump if > or =
		retf	0AF0Ah
			                        ;* No entry point to code
		push	es
		int	3			; Debug breakpoint
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		pop	dx
		or	al,[bp+si]
loc_1:
		mov	al,byte ptr ds:data_38e+1
		add	[bx+si],bx
;*		add	[bx+si+0],di
		db	 01h, 78h, 00h		;  Fixup - byte match
		db	0ADh, 00h,0B5h
data_14		dw	19F5h, 1DF5h
data_15		dw	0EE57h, 0EFFFh
data_16		dw	242Ah, 3F36h
data_17		dw	8AAAh, 0FFDFh
		db	 11h, 58h, 15h, 7Bh, 00h, 31h
		db	 00h, 31h, 00h, 0Ah, 00h, 0Eh
		db	 00h, 01h, 00h, 03h, 00h, 01h
		db	 00h, 03h, 00h, 02h, 00h, 06h
		db	0D9h
data_18		dw	2FF2h			; Data table (indexed access)
		db	0F6h, 4Ch, 3Eh, 90h,0DEh,0D4h
		db	 3Ch,0DDh,0CCh, 6Dh, 28h,0EDh
		db	0F8h, 20h,0C0h, 60h,0E0h, 26h
		db	 10h, 66h, 70h, 08h, 50h, 69h
		db	0D0h, 4Bh, 00h,0CFh, 5Ah, 0Ah
		db	 80h, 08h, 20h, 18h,0E0h, 05h
		db	 7Dh, 0Dh, 7Dh, 0Ah,0CAh, 0Ah
		db	0AFh, 06h,0C9h, 0Fh, 0Fh, 2Ah
		db	 20h, 36h, 3Fh, 5Ah, 03h, 30h
		db	 00h, 30h, 00h, 64h, 00h, 74h
		db	 00h, 4Ch, 00h, 7Ch, 00h, 2Bh
		db	 00h, 3Fh,0E8h, 15h,0E8h, 1Dh
		db	 56h, 8Fh,0FEh, 8Fh,0D9h,0D6h
		db	 2Fh,0D6h,0AAh, 8Ah,0DFh,0FFh
		db	 11h, 58h, 15h, 7Bh, 00h, 11h
		db	 00h, 11h, 02h, 82h
data_19		db	6			; Data table (indexed access)
		db	 8Fh, 0Ch, 2Ah, 0Ch, 3Ah, 00h
		db	 30h, 00h, 30h, 5Ah, 06h, 4Eh
		db	0BEh, 92h,0FEh,0C5h, 6Ch,0CDh
		db	0BCh, 65h,0CCh,0E5h, 3Ch,0D0h
		db	 94h,0D0h,0FCh, 0Ah,0ACh, 0Ah
		db	0BCh, 02h, 06h, 06h, 0Eh, 00h
		db	 21h, 00h, 63h, 00h, 21h, 00h
		db	 63h, 5Ah, 0Dh, 80h, 08h, 22h
		db	 18h,0E2h, 05h, 7Dh, 0Dh, 7Fh
		db	 0Ah,0CAh, 0Ah,0AFh, 06h,0C0h
		db	 0Fh, 0Fh, 00h, 01h, 00h, 01h
		db	 00h, 01h, 00h
data_20		dw	3			; Data table (indexed access)
		db	 06h, 00h, 06h, 00h, 01h, 00h
		db	 07h,0E8h, 0Bh,0E8h
data_21		db	0Fh
		db	 56h, 97h,0FEh, 9Fh,0D9h,0DAh
		db	 2Fh,0DEh, 4Fh,0BFh, 93h,0FFh
		db	 2Ah, 20h, 36h, 3Fh,0AAh, 8Ah
		db	0DFh,0FFh, 11h, 58h, 15h, 7Bh
		db	 00h, 1Fh, 00h, 1Fh, 03h, 0Eh
		db	 07h, 1Eh, 02h, 0Ch, 0Eh, 3Ch
		db	 10h, 30h, 30h, 70h, 02h, 80h
		db	 03h, 80h,0E5h, 6Ch,0EDh,0BCh
		db	 65h,0CCh,0E5h, 3Ch,0E9h, 96h
		db	0E9h,0FEh, 8Eh, 2Eh, 8Eh, 3Eh
		db	 01h, 8Ch, 03h, 9Ch, 00h, 18h
		db	 01h, 38h, 00h, 40h, 01h, 60h
		db	 00h, 20h, 00h, 20h, 5Ah, 11h
		db	 80h, 08h, 20h, 18h,0E0h, 05h
		db	 7Dh, 0Dh, 7Dh, 0Ah,0CAh, 0Ah
		db	0AFh, 5Ah, 07h, 50h, 00h, 50h
		db	 01h,0A0h, 01h,0E0h, 00h, 20h
		db	 00h,0E0h, 01h, 70h, 01h,0F0h
		db	0F4h, 98h,0F4h,0F8h, 57h, 3Ch
		db	0FFh, 3Ch, 06h,0C8h, 0Fh, 0Fh
		db	 2Ah, 24h, 36h, 3Fh,0AAh, 8Ah
		db	0DFh,0FFh, 11h, 5Eh, 15h, 7Eh
		db	 00h, 39h, 00h, 3Fh, 00h, 21h
		db	 00h, 67h, 00h, 22h, 00h,0E6h
		db	 02h,0D4h, 03h,0DCh,0D1h,0F2h
		db	 23h,0F6h, 6Ch,0BEh,0A3h,0FEh
		db	0C0h, 5Ch,0DFh,0FCh, 45h,0B8h
		db	 4Fh,0F8h, 00h, 60h, 01h,0E0h
		db	 4Ah, 80h, 7Fh, 80h, 60h, 00h
		db	0E0h, 5Ah, 03h,0C0h, 00h,0F0h
		db	0C0h, 40h, 00h, 5Eh, 38h,0C0h
		db	 00h,0D7h, 5Ch, 70h, 00h, 77h
		db	 57h, 5Ch, 00h, 5Dh, 10h, 10h
		db	 00h, 54h, 54h, 5Ah, 00h, 55h
		db	0FCh,0C0h, 00h,0B1h, 50h, 00h
		db	0A5h, 00h,0FCh, 00h, 01h, 05h
		db	0DCh, 02h, 05h, 05h, 50h, 0Ch
		db	 15h, 13h, 40h, 00h, 5Ch, 1Dh
		db	 1Ch, 10h, 45h, 2Ch, 09h, 00h
		db	 51h, 5Ch, 02h, 00h, 55h, 10h
		db	 00h,0C0h, 00h
data_22		dw	9Ch
		db	 70h, 00h, 37h, 00h, 5Ch, 00h
		db	 0Bh, 00h, 57h, 50h, 02h, 00h
		db	 95h,0FFh, 5Ah, 00h,0E5h, 50h
		db	0A0h, 00h, 5Fh, 00h,0A8h, 00h
		db	 45h, 00h, 08h, 5Ah, 00h, 15h
		db	 5Ah, 03h, 14h, 5Ah, 01h, 13h
		db	 00h, 40h, 00h, 14h, 03h,0ECh
		db	 03h,0E0h, 1Fh,0C0h, 1Fh,0C0h
		db	 07h, 00h, 07h, 00h, 01h, 70h
		db	 01h, 70h, 5Ah, 0Ah, 05h, 40h
		db	 05h, 40h, 18h, 80h, 1Eh, 80h
		db	0B5h, 00h,0ADh, 00h, 98h,0AFh
		db	0B8h,0AFh, 77h,0EAh,0F7h,0FFh
		db	 5Ah, 0Ch, 01h, 00h, 04h, 10h
		db	 07h, 18h,0BEh,0A0h,0BEh,0B0h
		db	 53h, 50h,0F5h, 50h, 33h, 60h
		db	0F0h,0F0h, 4Fh, 9Bh, 6Fh,0F4h
		db	 7Ch, 32h, 7Bh, 09h, 3Ch, 2Bh
		db	 33h,0BBh, 14h,0B6h, 1Fh,0B7h
		db	 03h, 04h, 07h, 06h, 08h, 64h
		db	 0Eh, 66h, 0Ah, 10h, 0Bh, 96h
		db	 00h,0D2h, 00h,0F3h, 24h, 54h
		db	0FCh, 6Ch, 51h, 55h,0FFh,0FBh
		db	 1Ah, 88h,0DEh,0A8h, 8Ch, 00h
		db	 8Ch, 00h, 50h, 00h, 70h, 00h
		db	 80h, 00h,0C0h, 00h, 80h, 00h
		db	0C0h, 00h, 40h, 00h, 60h, 5Ah
		db	 03h, 0Ch, 00h, 0Ch, 00h, 26h
		db	 00h, 2Eh, 00h, 32h, 00h, 3Eh
		db	 00h,0D4h, 00h,0FCh, 00h,0A8h
		db	 17h,0B8h, 17h,0F1h, 6Ah,0F1h
		db	 7Fh, 6Bh, 9Bh, 6Bh,0F4h, 5Ah
		db	 08h, 01h, 00h, 04h, 10h, 07h
		db	 18h,0BEh,0A0h,0BEh,0B0h, 53h
		db	 50h,0F5h, 50h, 93h, 60h,0F0h
		db	0F0h, 04h, 54h,0FCh, 6Ch, 7Dh
		db	 72h, 7Fh, 49h, 36h,0A3h, 3Dh
		db	0B3h, 33h,0A6h, 3Ch,0A7h, 29h
		db	 0Bh, 3Fh, 0Bh
		db	'5P=P`@p`'
		db	 84h, 00h,0C6h, 00h, 84h, 00h
		db	0C6h, 00h, 51h, 55h,0FFh,0FBh
		db	 1Ah, 88h,0DEh,0A8h, 88h, 00h
		db	 88h, 00h, 41h, 40h,0F1h, 60h
		db	 54h, 30h, 5Ch, 30h, 0Ch, 00h
		db	 0Ch, 5Ah, 07h
data_23		db	80h
		db	 00h, 80h, 00h, 80h, 00h,0C0h
		db	 00h, 60h, 00h, 60h, 00h, 80h
		db	 00h,0E0h, 00h,0D0h, 17h,0F0h
		db	 17h,0E9h, 6Ah,0F9h, 7Fh, 5Bh
		db	 9Bh, 7Bh,0F4h,0FDh,0F2h,0FFh
		db	0C9h, 5Ah, 0Ch, 01h, 00h, 44h
		db	 10h, 47h, 18h,0BEh,0A0h,0FEh
		db	0B0h, 53h, 50h,0F5h, 50h, 03h
		db	 60h,0F0h,0F0h, 36h,0A7h, 3Dh
		db	0B7h, 33h,0A6h, 3Ch,0A7h, 69h
		db	 97h, 7Fh, 97h, 74h, 71h, 7Ch
		db	 71h, 31h, 80h, 39h,0C0h, 18h
		db	 00h, 1Ch, 80h, 02h, 00h, 06h
		db	 80h, 04h, 00h, 04h, 00h, 04h
		db	 54h,0FCh, 6Ch, 51h, 55h,0FFh
		db	0FBh, 1Ah, 88h,0DEh,0A8h,0F8h
		db	 00h,0F8h, 00h, 70h,0C0h, 78h
		db	0E0h
		db	 30h, 40h, 3Ch
loc_2:
;*		jo	loc_4			;*Jump if overflow=1
		db	 70h, 0Ch		;  Fixup - byte match
		or	data_21,cl
		inc	ax
;*		add	ax,ax
		db	 01h,0C0h		;  Fixup - byte match
loc_3:
		pop	dx
		push	es
		or	al,[bx+si]
		or	al,[bx+si]
		add	ax,780h
		add	byte ptr [si],0
		pop	es
		add	data_29,cl
		sbb	byte ptr [bx+di],2Fh	; '/'
		pop	ds
		das				; Decimal adjust
		cmp	al,0EAh
		cmp	al,0FFh
		pop	dx
		adc	[bx+di],al
		add	[si],al
		adc	[bx],al
		sbb	ss:data_41e[bp],bh
		mov	al,53h			; 'S'
		push	ax
		cmc				; Complement carry
		push	ax
		dec	di
		mov	bp,[bx-3Ch]
		jge	loc_5			; Jump if > or =
		jg	loc_2			; Jump if >
		cmp	al,[bp+di]
		aas				; Ascii adjust
		sti				; Enable interrupts
		sbb	ax,1FA2h
		db	0F2h, 06h, 00h, 07h, 80h, 01h
		db	 52h, 01h,0FEh, 00h, 06h, 00h
		db	 07h, 5Ah, 02h, 13h, 60h,0F0h
		db	0F0h, 24h, 54h,0FCh, 6Ch, 51h
		db	 55h,0FFh,0FBh, 7Ah, 88h, 7Eh
		db	0A8h, 9Ch, 00h,0FCh, 00h, 84h
		db	 00h,0E6h, 00h, 44h, 00h, 67h
		db	 00h
		db	 2Bh, 40h
loc_5:
		cmp	ax,ax
		push	sp
		pop	dx
		add	dx,ax
		add	[bx+si],dh
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
		add	[si],cl
;*		add	al,dh
		db	 00h,0F0h		;  Fixup - byte match
;*		add	[si+0],bh
		db	 00h, 7Ch, 00h		;  Fixup - byte match
		db	 0Ch, 00h, 5Fh, 30h, 5Fh, 30h
		db	 17h,0C0h, 17h,0C0h, 14h, 00h
		db	 14h, 5Ah, 04h, 01h, 5Ah, 01h
		db	 03h, 5Ah, 01h, 03h, 5Ah, 01h
		db	 07h, 00h, 07h, 00h, 1Fh, 00h
		db	 05h, 00h, 7Fh, 00h, 4Fh, 00h
		db	 7Ah, 00h, 7Ah, 5Ah, 0Ah,0C0h
		db	 5Ah, 01h, 57h, 00h, 57h, 00h
		db	0DDh,0C0h,0DDh,0C0h, 84h, 40h
		db	0B7h, 40h,0C0h, 00h,0F0h,0C0h
		db	 00h, 35h, 00h, 31h, 00h, 56h
		db	 00h
		db	51h
loc_6:
		add	[bx+si],dh
		add	[di],dh
;*		add	[bx+si+0],ch
		db	 00h, 68h, 00h		;  Fixup - byte match
		db	 69h, 00h, 90h, 00h, 91h, 00h
		db	 7Fh, 00h, 6Ah, 5Ah, 01h, 1Fh
		db	 5Ah, 01h, 57h, 00h, 01h, 00h
		db	 01h, 5Ah, 01h, 01h, 5Ah, 03h
		db	 0Ah, 00h, 0Ah, 00h, 50h, 00h
		db	 50h, 04h, 05h, 04h, 05h, 02h
		db	 76h, 06h, 77h, 03h, 2Bh, 0Fh
		db	0FFh, 5Ah, 02h,0B0h, 00h,0F0h
		db	 00h, 56h, 80h, 5Eh, 80h,0C0h
		db	 60h,0C0h
data_24		dw	3D60h
		db	 90h, 3Dh, 90h, 9Bh, 60h,0DFh
		db	 60h, 3Eh,0D8h,0BFh,0F8h, 0Fh
		db	 9Ch, 0Fh,0FCh, 04h, 04h, 07h
		db	 1Eh, 03h,0C2h, 02h, 1Eh, 00h
		db	 25h, 06h, 0Fh, 12h,0A1h, 17h
		db	0FFh, 12h, 93h, 7Bh, 9Fh, 64h
		db	0C0h
loc_7:
		in	ax,0C0h			; port 0C0h, DMA-2 bas&add ch 0
		add	[bx+si],ah
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
		add	[bx+si],dl
		add	[bx+si],dh
		rcl	byte ptr [si+16h],cl	; Rotate thru carry
		cld				; Clear direction
;*		call	far ptr sub_5		;*
		db	9Ah
		dw	3ACEh, 0A9FEh		;  Fixup - byte match
		jbe	loc_7			; Jump if below or =
		jle	loc_6			; Jump if < or =
		adc	al,87h
		sbb	al,0Eh
		or	ds:data_5e,bh
;*		loopnz	locloop_8		;*Loop if zf=0, cx>0

		db	0E0h, 30h		;  Fixup - byte match
		loopnz	$+2			; Loop if zf=0, cx>0

		add	byte ptr [bx+si],0C0h
		add	byte ptr ds:[8000h][bx+si],al
		pop	dx
		add	bp,sp
;*		add	ah,ch
		db	 00h,0ECh		;  Fixup - byte match
		add	al,0
		add	ax,1041h
		or	bl,[si]
		or	ah,[bx+si]
		push	ax
		xor	[bx+di+24h],dl
		add	al,24h			; '$'
		add	ax,5042h
		inc	si
		jno	$+3			; Jump if not overflw
		mov	al,byte ptr ds:[2B2Ch]
		sub	ax,word ptr ds:[802Bh][bx+si]
		add	ax,5E4h
		in	al,40h			; port 40h, 8253 timer 0 clock
		mov	ax,0B840h
		db	0C0h, 2Ah,0C0h, 2Ah, 3Dh, 98h
data_25		db	3Dh			; Data table (indexed access)
		db	 98h, 9Bh, 60h,0DFh, 60h, 06h
		db	0D8h, 07h,0F8h, 03h,0B4h, 43h
		db	0FCh, 45h, 80h, 44h, 2Fh, 02h
		db	 00h, 17h,0F7h, 40h, 00h, 40h
		db	 0Bh, 10h, 00h, 10h, 01h, 02h
		db	 40h, 13h, 40h, 62h, 20h, 66h
		db	 21h, 04h, 10h, 0Ch, 18h, 18h
		db	 01h, 18h, 01h, 5Ah, 00h,0F6h
		db	0FDh, 0Ch,0EAh,0A0h,0FEh, 0Dh
		db	 3Ah, 41h, 3Eh, 03h, 1Ch, 03h
		db	 1Ch, 05h, 14h, 07h, 1Ch, 05h
		db	 18h, 07h, 18h, 02h, 18h, 06h
		db	 18h, 8Ch, 08h, 8Ch, 08h, 0Ch
		db	 00h, 0Ch, 01h, 20h,0A8h, 30h
		db	0A8h, 45h, 00h, 47h, 81h, 5Ah
		db	 00h, 0Ch, 01h, 18h, 00h, 18h
		db	 03h, 30h, 00h, 34h, 23h, 20h
		db	 00h, 21h, 0Fh, 01h, 00h, 01h
		db	 25h, 00h, 70h, 00h, 70h, 02h
		db	 26h, 02h, 2Eh, 00h, 01h, 00h
		db	 07h, 5Ah, 00h, 04h, 01h, 00h
		db	 50h, 00h, 50h, 00h, 28h, 24h
		db	 28h, 00h, 08h, 50h, 88h, 00h
		db	 08h, 3Ah, 08h, 5Ah, 00h,0E4h
		db	 40h, 01h, 00h, 01h,0A2h, 5Ah
		db	 00h, 20h, 41h, 60h, 80h, 64h
		db	 95h, 10h, 40h, 30h, 4Bh, 04h
		db	 00h, 0Ch,0A2h, 10h, 30h, 12h
		db	 32h, 08h, 80h, 08h, 82h, 5Ah
		db	 00h, 25h, 3Bh, 5Ah, 00h, 10h
		db	 5Ah, 00h, 08h, 98h, 88h, 00h
		db	 04h, 50h, 04h, 5Ah, 00h,0C4h
		db	 10h, 00h, 12h, 00h,0F2h, 00h
		db	0C4h, 05h,0C4h, 14h, 10h, 14h
		db	 10h, 40h, 00h, 5Eh, 38h,0C0h
		db	 00h,0D7h, 5Ch, 70h, 00h, 77h
		db	 57h, 5Ch, 00h, 5Dh, 00h, 10h
		db	 00h, 55h, 10h, 5Ah, 00h, 57h
		db	 48h,0C0h, 00h,0B1h,0FCh,0C0h
		db	 00h, 9Ch, 28h, 5Ah, 07h, 05h
		db	 5Ah, 01h, 17h, 00h, 04h, 00h
		db	 2Fh, 00h, 02h, 00h, 33h, 5Ah
		db	 01h, 5Fh, 5Ah, 01h, 1Fh, 00h
		db	 04h, 15h,0EAh, 00h, 80h,0AFh
		db	0F4h, 22h, 20h,0EEh,0C0h, 5Ah
		db	 00h, 7Bh, 10h, 70h, 00h,0F6h
		db	 40h, 40h, 00h,0B5h, 80h, 5Ah
		db	 00h,0D9h, 5Ah, 01h,0F4h, 40h
		db	 5Ah, 01h, 5Fh, 5Ah, 01h,0CFh
loc_9:
		add	[bp+si],al
;*		add	bh,cl
		db	 00h,0CFh		;  Fixup - byte match
		add	[bx+si],cl
;*		add	dh,bl
		db	 00h,0DEh		;  Fixup - byte match
		add	ds:data_6e[si],cl
		pop	dx
		add	[bx+di],al
		int	3			; Debug breakpoint
		add	[si],ax
		add	bx,ds:data_1e[si]
		add	bx,ds:data_4e[si]
		cli				; Disable interrupts
;*		add	ax,0DF00h
		db	 81h,0C0h, 00h,0DFh	;  Fixup - byte match
		cmpsb				; Cmp [si] to es:[di]
		or	[bx+si],al
		jg	loc_12			; Jump if >
		pop	dx
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		lds	si,dword ptr [si]	; Load seg:offset ptr
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
                           lock	adc	[bx+si],al
		jg	loc_9			; Jump if >
		and	al,[bx+si]
		cmp	bp,ax
		add	[bx+si],ax
		pop	ss
                           lock	add	ds:data_10e[bx+si],ax
		add	[bx+si],cl
		add	cx,word ptr ss:data_1e+1[bp]
		add	cx,ds:data_9e[bx]
;*		add	di,ax
		db	 01h,0C7h		;  Fixup - byte match
		pop	dx
		add	ss:data_3e[bp+di],dx
		add	bx,[bx+si]
		pop	dx
		add	[bx+di],al
		inc	word ptr [bx+si]
		sbb	[bx+si],al
		mov	si,data_9e
		aas				; Ascii adjust
;*		loopnz	locloop_10		;*Loop if zf=0, cx>0

		db	0E0h, 05h		;  Fixup - byte match
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		add	[bx+si],dh
		add	[bx+si+40h],dh
		pop	dx
		add	ds:data_8e[bx],al
		add	[bp+di],al
		loopnz	locloop_11		; Loop if zf=0, cx>0


locloop_11:
		inc	ax
		inc	ax
		cli				; Disable interrupts
		add	[bx+si+10h],ah
		db	 3Eh, 5Ah, 01h, 78h, 5Ah, 03h
		db	 7Dh, 00h, 01h
loc_12:
;*		add	[si+0],dh
		db	 00h, 74h, 00h		;  Fixup - byte match
		db	 40h, 00h,0B8h, 00h,0C1h, 01h
		db	 10h, 04h, 05h, 01h,0F5h, 00h
		db	 41h, 00h,0B0h, 00h, 01h, 00h
		db	 78h, 00h, 01h, 00h, 7Ch, 5Ah
		db	 0Bh, 02h, 5Ah, 01h, 07h, 5Ah
		db	 01h, 2Eh, 5Ah, 01h, 1Fh, 00h
		db	 01h, 00h, 1Fh, 5Ah, 00h, 02h
		db	 22h, 5Ah, 00h, 74h, 10h, 10h
		db	 00h,0B9h, 80h, 30h, 00h,0F6h
		db	0A0h, 40h, 00h,0FCh, 5Ah, 01h
		db	0BAh, 41h, 08h, 00h,0E6h, 80h
		db	 5Ah, 00h,0FBh, 24h, 5Ah, 01h
		db	 3Eh, 00h, 06h, 00h, 3Dh, 00h
		db	 10h, 00h, 7Ah, 5Ah, 01h, 72h
		db	 00h, 40h, 00h,0E0h, 00h, 80h
		db	 00h,0E0h, 5Ah, 01h,0E0h, 00h
		db	 80h, 00h,0E0h, 5Ah, 00h,0DEh
		db	 81h, 04h, 00h, 7Fh,0C8h, 5Ah
		db	 00h,0FFh, 60h, 26h, 00h,0FFh
		db	0F8h, 5Ah, 00h, 7Fh,0F4h, 10h
		db	 00h, 3Bh,0E8h, 02h, 00h, 17h
		db	0F0h, 02h, 00h, 0Fh,0E0h, 06h
		db	 5Ah, 00h, 70h, 5Ah, 01h, 79h
		db	 5Ah, 01h, 32h, 5Ah, 01h, 02h
		db	 5Ah, 0Dh, 0Bh, 5Ah, 00h, 3Fh
		db	0C0h, 08h, 00h, 7Eh, 80h, 20h
		db	 00h,0FCh, 04h,0C0h, 00h,0F2h
		db	 20h, 40h, 00h,0FBh, 5Ah, 01h
		db	 73h, 08h, 20h, 00h,0FAh, 5Ah
		db	 01h,0F8h, 00h, 60h, 00h, 70h
		db	 00h, 37h, 00h, 5Ch, 00h, 0Bh
		db	 00h, 57h, 00h, 02h, 00h, 55h
		db	 5Ah, 01h,0E4h,0F0h,0A0h, 00h
		db	 4Fh, 00h,0A8h, 00h, 55h, 00h
		db	 08h, 00h, 55h, 5Ah, 02h, 01h
		db	 5Ah, 01h, 03h, 5Ah, 01h, 05h
		db	 5Ah, 01h, 0Bh, 00h, 02h, 00h
		db	 3Fh, 5Ah, 01h, 33h, 5Ah, 01h
		db	 2Fh, 00h, 01h, 00h, 1Dh, 5Ah
		db	 00h, 02h, 5Ah, 01h, 68h, 80h
		db	 5Ah, 00h,0FAh, 50h, 5Ah, 00h
		db	0FFh, 10h, 48h, 00h,0F5h, 40h
		db	0C0h, 00h,0FDh, 00h, 40h, 00h
		db	0FFh, 00h, 18h, 00h,0FDh,0C0h
		db	 20h, 5Ah, 00h, 3Fh, 00h, 28h
		db	 00h, 7Fh, 00h, 02h, 00h, 7Eh
		db	 00h, 20h, 00h,0E8h, 5Ah, 00h
		db	 01h,0F2h, 00h, 80h, 01h,0EEh
		db	 01h, 00h, 03h,0CCh, 02h, 00h
		db	 03h,0CDh, 02h, 04h,0FEh, 80h
		db	 5Ah, 00h,0BEh,0C0h, 20h, 00h
		db	0BBh,0ECh, 01h, 00h,0FFh,0FEh
		db	 5Ah, 00h, 37h,0FCh, 14h, 00h
		db	 0Bh,0FEh, 00h,0C0h, 0Bh,0ECh
		db	 5Ah, 00h, 07h,0F0h, 01h, 00h
		db	 03h, 0Eh, 5Ah, 00h, 03h, 85h
		db	 01h, 00h, 03h, 87h, 5Ah, 00h
		db	 01h,0CFh, 00h, 06h, 00h, 9Eh
		db	5Ah
data_26		dw	300h			; Data table (indexed access)
		db	 1Fh, 00h, 08h, 01h
data_27		db	0FEh			; Data table (indexed access)
		db	 00h, 42h, 00h,0BEh, 00h, 08h
		db	 37h,0E0h, 5Ah, 00h,0F7h,0C0h
		db	 80h, 00h,0F7h,0C0h, 02h, 00h
		db	 03h,0C0h, 00h,0C0h, 13h,0E0h
		db	 5Ah, 00h, 40h,0FAh, 5Ah, 00h
		db	 80h, 3Eh, 00h, 10h, 00h, 78h
		db	 5Ah, 03h, 15h, 5Ah, 01h, 03h
		db	 5Ah, 01h, 07h, 00h, 01h, 00h
		db	 16h, 00h, 17h, 5Ah, 01h, 5Fh
		db	 00h, 5Fh, 00h, 54h, 00h, 54h
		db	 00h, 55h, 00h, 55h, 5Ah, 03h
		db	 01h, 5Ah, 01h, 02h, 5Ah, 05h
		db	 15h, 5Ah, 01h, 26h, 5Ah, 01h
		db	 1Fh, 5Ah, 01h, 1Fh, 00h, 02h
		db	 12h, 50h, 5Ah, 00h, 27h, 40h
		db	 5Ah, 00h,0BBh,0C0h, 20h, 00h
		db	0F7h,0A4h, 10h, 00h,0FDh,0C0h
		db	 24h, 00h,0FFh, 40h, 5Ah, 00h
		db	0F6h, 80h, 5Ah, 00h,0FFh, 4Bh
		db	 01h, 5Ah, 00h, 3Fh, 5Ah, 01h
		db	 3Dh, 00h, 08h, 00h, 75h, 5Ah
		db	 01h
loc_13:
		jo	$+2			; delay for I/O
		adc	[bx+si],al
		loopnz	$+5Ch			; Loop if zf=0, cx>0

;*		add	ax,dx
		db	 01h,0D0h		;  Fixup - byte match
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		;  Fixup - byte match
		db	0E0h, 00h, 80h, 00h,0C0h, 5Ah
		db	 00h, 5Fh,0FEh, 10h, 00h, 7Fh
		db	0F6h, 00h,0C0h,0FFh,0BDh, 0Ch
		db	 00h, 6Fh,0EAh, 20h, 00h, 17h
		db	0FCh, 5Ah, 00h, 13h,0E9h, 01h
		db	 00h, 17h,0F0h, 5Ah, 00h, 0Fh
		db	0A0h, 08h, 5Ah, 00h, 70h, 5Ah
		db	 01h, 79h, 00h, 40h, 00h, 33h
		db	 00h, 01h, 00h, 03h, 5Ah, 0Dh
		db	 0Bh, 5Ah, 00h, 7Fh, 5Ah, 01h
		db	0FCh, 80h, 20h, 00h,0E4h, 00h
		db	 80h, 00h,0F8h, 10h, 5Ah, 00h
		db	0FFh, 04h, 5Ah, 00h, 1Fh, 5Ah
		db	 01h,0CEh, 40h, 5Ah, 00h, 5Ch
		db	 5Ah, 03h,0C0h, 5Ah, 01h,0D0h
		db	 00h, 80h, 00h, 50h, 5Ah, 01h
		db	 40h, 5Ah, 07h, 30h, 00h, 30h
		db	 00h,0C0h, 00h,0C0h, 00h, 57h
		db	0A8h, 01h, 00h, 2Fh,0F5h, 04h
		db	 44h, 03h, 77h, 5Ah, 00h, 08h
		db	0DEh, 00h, 0Eh, 02h, 6Fh, 00h
		db	 02h, 01h,0ADh, 5Ah, 01h, 9Bh
		db	 5Ah, 00h, 02h, 2Fh, 5Ah, 08h
		db	0A0h, 5Ah, 01h,0E8h, 00h, 20h
		db	 00h,0F4h, 00h, 40h, 00h,0CCh
		db	 5Ah, 01h,0FAh, 5Ah, 01h,0F8h
		db	 00h, 20h, 00h, 81h, 5Fh, 00h
		db	 03h, 65h,0FBh, 00h, 10h,0EAh
		db	0FEh, 5Ah, 00h,0A3h,0FFh, 00h
		db	 2Ch, 0Fh,0FFh, 00h, 08h, 0Bh
		db	0FEh, 00h, 44h, 17h,0DCh, 00h
		db	 80h, 0Fh,0E8h, 01h, 80h,0FAh
		db	 5Ah, 01h,0F3h, 00h, 40h, 00h
		db	0F3h, 00h, 10h, 00h, 7Bh, 00h
		db	 31h, 00h, 79h, 80h, 5Ah, 00h
		db	 33h, 80h, 20h, 80h, 39h,0C0h
		db	 00h, 80h, 39h,0C0h, 10h, 40h
		db	 07h,0FCh, 00h,0A0h, 00h,0FFh
		db	 00h, 0Ch, 02h, 0Eh, 5Ah, 00h
		db	 03h,0E1h, 00h, 80h, 07h,0C0h
		db	 02h, 00h, 5Fh, 02h, 06h, 00h
		db	 7Ch, 08h, 5Ah, 00h, 1Eh, 5Ah
		db	 01h, 78h,0C0h, 10h, 00h, 71h
		db	0C0h, 00h, 40h,0F1h,0C0h, 20h
		db	 00h,0E3h, 80h, 5Ah, 00h,0C9h
		db	 5Ah, 01h, 18h,0C0h, 5Ah, 00h
		db	0FFh, 80h, 18h, 00h, 7Dh, 00h
		db	 20h, 00h,0C0h, 00h,0F0h,0C0h
		db	 40h, 00h, 5Eh, 38h,0C0h, 00h
		db	0D7h, 5Ch, 70h, 00h, 77h, 57h
		db	 5Ch, 00h, 5Dh, 00h, 10h, 00h
		db	 54h, 5Ah, 01h, 56h, 80h,0C0h
		db	 00h,0B3h,0D0h, 44h, 40h, 5Ah
		db	 00h, 08h, 2Eh, 00h, 08h, 01h
		db	 9Dh, 00h, 0Ch, 05h, 6Fh, 00h
		db	 02h, 00h, 3Fh, 5Ah, 00h, 82h
		db	 5Dh, 00h, 10h, 01h, 67h, 5Ah
		db	 00h, 24h,0DFh, 5Ah, 0Ch, 40h
		db	 5Ah, 01h,0E0h, 5Ah, 01h, 74h
		db	 5Ah, 01h,0F8h, 00h, 80h, 00h
		db	0F8h, 5Ah, 01h, 81h
		db	7Bh
data_28		db	0			; Data table (indexed access)
		db	 20h, 13h,0FEh, 5Ah, 00h, 06h
		db	0FFh, 00h, 64h, 1Fh,0FFh, 5Ah
		db	 00h, 2Fh,0FEh, 00h, 08h, 17h
		db	0DCh, 00h, 40h, 0Fh,0E8h, 00h
		db	 40h, 07h,0F0h, 00h, 60h, 7Ch
		db	 00h, 60h, 00h,0BCh, 00h, 08h
		db	 00h, 5Eh, 5Ah, 01h, 4Eh, 00h
		db	 02h, 00h, 07h, 00h, 01h, 00h
		db	 07h, 5Ah, 01h, 07h, 00h, 01h
		db	 00h, 07h, 5Ah, 01h, 03h,0FCh
		db	 00h, 10h, 01h, 7Eh, 00h, 04h
		db	 20h, 3Fh, 00h, 03h, 04h, 4Fh
		db	 00h, 02h, 00h,0DFh, 5Ah, 00h
		db	 10h,0CEh, 00h, 04h, 00h, 5Fh
		db	 5Ah, 01h, 1Fh, 00h, 06h, 0Eh
		db	 5Ah, 01h, 9Eh, 5Ah, 01h, 4Ch
		db	 5Ah, 01h, 40h, 5Ah, 0Dh,0D0h
		db	 5Ah, 04h, 57h, 5Ah, 01h, 5Eh
		db	 00h, 08h, 00h, 16h, 5Ah, 01h
		db	 1Eh, 17h,0C4h, 00h, 1Bh, 00h
		db	 50h, 00h, 0Fh, 00h, 50h, 00h
		db	 03h, 00h, 54h, 00h, 01h, 00h
		db	 40h, 5Ah, 00h, 01h, 16h, 5Ah
		db	 00h, 0Ah, 5Fh, 5Ah, 00h, 08h
		db	0FFh, 00h, 12h, 02h,0AFh, 00h
		db	 03h, 00h,0BFh, 00h, 02h, 00h
		db	0FFh, 00h, 18h, 03h,0BFh, 00h
		db	 04h, 80h, 5Ah, 01h,0C0h, 5Ah
		db	 01h,0A0h, 5Ah, 01h,0D0h, 00h
		db	 40h, 00h,0FCh, 5Ah, 01h,0CCh
		db	 5Ah, 01h,0F4h, 00h, 80h, 00h
		db	0B8h, 5Ah, 01h, 01h, 7Fh, 5Ah
		db	 00h, 03h, 7Dh, 00h, 04h, 37h
		db	0DDh, 00h, 80h, 7Fh,0FFh, 5Ah
		db	 00h, 3Fh,0ECh, 00h, 28h, 7Fh
		db	0D0h, 03h, 00h, 37h,0D0h, 5Ah
		db	 00h, 0Fh,0E0h, 00h, 80h,0FCh
		db	 00h, 14h, 00h,0FEh, 00h, 40h
		db	 00h, 7Eh, 00h, 04h, 00h, 17h
		db	 5Ah, 01h, 4Fh, 80h, 01h, 00h
		db	 77h, 80h, 00h, 80h, 33h,0C0h
		db	 00h, 40h,0B3h,0C0h, 20h, 40h
		db	 07h,0ECh, 5Ah, 00h, 03h,0EFh
		db	 00h, 01h, 03h,0EFh, 00h, 40h
		db	 03h,0C0h, 03h, 00h, 07h,0C8h
		db	 5Ah, 00h, 5Fh, 02h, 5Ah, 00h
		db	 7Ch, 01h, 08h, 00h, 1Eh, 5Ah
		db	 01h, 70h,0C0h, 5Ah, 00h,0A1h
		db	0C0h, 00h, 80h,0E1h,0C0h, 5Ah
		db	 00h,0F3h, 80h, 60h, 00h, 79h
		db	 5Ah, 01h,0F8h,0C0h, 10h, 00h
		db	 7Fh, 80h, 42h, 00h, 7Dh, 00h
		db	 10h, 00h,0C0h, 00h, 9Ch,0B8h
		db	 70h, 00h, 37h, 10h, 5Ch, 00h
		db	 0Bh, 00h, 57h, 00h, 02h, 00h
		db	 55h, 5Ah, 01h, 01h, 00h, 80h
		db	 00h, 0Dh, 00h,0D0h, 00h, 01h
		db	 00h, 5Ch, 00h, 0Ah, 48h, 5Ah
		db	 00h, 02h,0E4h, 5Ah, 00h, 03h
		db	0DDh, 00h, 04h, 25h,0EFh, 00h
		db	 08h, 03h,0BFh, 00h, 24h, 02h
		db	0FFh, 5Ah, 00h, 01h, 6Fh, 5Ah
		db	 00h,0D2h,0FFh, 00h, 80h, 5Ah
		db	 02h, 80h, 5Ah, 01h, 40h, 5Ah
		db	 05h,0A8h, 5Ah, 01h, 64h, 5Ah
		db	 01h,0F8h, 5Ah, 01h,0F8h, 00h
		db	 40h, 00h, 7Fh,0FAh, 00h, 08h
		db	 6Fh,0FEh, 03h, 00h,0BDh,0FFh
		db	 00h, 30h, 57h,0F6h, 00h, 04h
		db	 3Fh,0E8h, 5Ah, 00h, 97h,0C8h
		db	 00h, 80h, 0Fh,0E8h, 5Ah, 00h
		db	 05h,0F0h, 00h, 10h,0FCh, 5Ah
		db	 01h,0BCh, 00h, 10h, 00h,0AEh
		db	 5Ah, 01h, 0Eh, 00h, 08h, 00h
		db	 07h, 5Ah, 01h, 0Bh, 00h, 02h
		db	 00h, 07h, 00h, 01h, 00h, 03h
		db	 5Ah, 02h,0FEh, 5Ah, 00h, 01h
		db	 3Fh, 00h, 04h, 00h, 27h, 00h
		db	 01h, 08h, 1Fh, 5Ah, 00h, 20h
		db	0FFh, 5Ah, 01h,0F8h, 5Ah, 00h
		db	 02h, 73h, 5Ah, 01h, 3Ah, 5Ah
		db	 00h, 0Eh, 5Ah, 01h, 9Eh, 00h
		db	 02h, 00h,0CCh, 00h, 80h, 00h
		db	0C0h, 5Ah, 0Dh,0D0h, 5Ah, 02h
		db	 58h, 5Ah, 00h, 01h,0D3h, 5Ah
		db	 00h, 03h,0A4h, 00h, 80h, 07h
		db	0C1h, 03h, 00h, 07h, 5Ah, 01h
		db	 0Eh, 80h, 06h, 00h, 0Eh, 02h
		db	 5Ah, 00h, 17h, 08h, 5Ah, 00h
		db	 01h, 95h, 5Ah, 00h, 07h,0B8h
		db	 00h, 47h, 0Fh, 30h, 00h, 8Ah
		db	 0Fh,0B0h, 00h, 45h, 0Dh, 30h
		db	 02h, 8Bh, 06h,0D0h, 00h, 25h
		db	 01h,0A8h, 00h, 13h, 00h, 54h
		db	 00h, 2Ah, 0Fh, 83h, 03h, 00h
		db	 17h, 85h
		db	5Ah
loc_14:
		add	[bp-39h],al
		pop	dx
		add	ds:data_11e[bx+di],al
		add	[bp+si],dl
		sti				; Enable interrupts
		pop	dx
		add	[bx+di],ah
		inc	word ptr [bx+si]
		xor	[bx+si],al
;*		call	dword ptr [bp+si+0]
		db	0FFh, 5Ah, 00h		;  Fixup - byte match
		db	 48h, 3Fh, 5Ah, 00h,0A8h, 5Ah
		db	 01h, 7Ch, 80h, 18h, 00h, 5Ch
		db	 5Ah, 01h,0DBh, 5Ah, 01h,0B8h
		db	 00h, 10h, 00h,0F3h, 5Ah, 01h
		db	0FCh, 00h, 20h, 00h,0FBh, 80h
		db	 5Ah, 00h, 20h, 1Fh, 00h, 01h
		db	 00h, 0Fh, 5Ah, 01h, 03h, 5Ah
		db	 00h, 20h, 5Ah, 01h, 04h, 5Ah
		db	 02h, 20h, 5Ah, 05h, 80h, 5Ah
		db	 00h,0FEh,0E0h, 5Ah, 00h,0FFh
		db	0E0h, 0Ch, 00h,0FFh,0F4h, 61h
		db	 00h,0FFh,0E8h, 5Ah, 00h, 7Fh
		db	0F0h, 02h

locloop_15:
		add	[bx],bh
;*		aam	10h			; undocumented inst
		db	0D4h, 10h		;  Fixup - byte match
		add	[bp+di],bl
		call	sub_2
loc_16:
		pop	ss
                           lock	pop	dx
		add	[bp+si],ax
		pop	dx
		add	[bx+di],ax
		pop	dx
		add	[bx],cx
		pop	dx
		add	[bx],bp
		add	[bp+si],al
		add	[bx],bl
		pop	dx
		add	[bx],bx
		add	[bx+si],cl
		add	[bx],cl
		pop	dx
		add	data_20[bx],di
		jg	loc_16			; Jump if >
		pop	dx
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
;*		add	[bx+si+0],ah
		db	 00h, 60h, 00h		;  Fixup - byte match
		db	0F0h, 40h, 5Ah, 00h, 4Ch, 5Ah
		db	 01h, 19h, 5Ah, 01h, 14h, 5Ah
		db	 01h,0CEh, 5Ah, 01h,0D7h, 80h
		db	 5Ah, 09h, 06h, 5Ah, 01h, 13h
		db	 00h, 01h, 00h, 0Ah, 5Ah, 01h
		db	 2Eh, 00h, 0Ch, 00h, 69h, 5Ah
		db	 01h, 14h, 5Ah, 04h, 80h, 5Ah
		db	 01h, 80h, 5Ah, 01h,0A0h, 5Ah
		db	 01h, 80h, 5Ah, 01h

_362UNKN	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		db	 60h, 5Ah, 01h, 08h, 5Ah, 01h
		db	 68h, 00h, 40h, 5Ah, 00h, 17h
		db	 00h, 02h, 00h, 3Fh, 00h, 0Ch
		db	 00h, 17h, 00h, 03h, 00h, 25h
		db	 5Ah, 00h, 12h,0DBh, 5Ah, 00h
		db	 0Bh,0EFh, 00h, 04h, 1Dh,0EDh
		db	 5Ah, 00h, 6Fh,0BEh, 5Ah, 01h
		db	 10h, 5Ah, 00h,0A0h, 80h, 00h
		db	 80h,0F4h, 04h, 5Ah, 00h,0C9h
		db	 10h, 5Ah, 00h,0BCh, 00h, 90h
		db	 00h,0BDh, 5Ah, 01h,0ABh,0C8h
		db	 01h, 80h,0F7h, 54h, 5Ah, 00h
		db	 3Dh,0DFh, 08h, 04h,0D0h,0BFh
		db	 00h, 01h, 30h, 03h, 20h, 00h
		db	 68h, 5Ah, 01h, 30h, 5Ah, 01h
		db	 14h, 5Ah, 02h, 02h, 5Ah, 00h
		db	 10h, 5Ah, 01h,0FDh, 98h, 40h
		db	 00h,0FFh,0B4h, 00h, 10h,0FFh
		db	 7Ch, 18h, 50h,0FFh,0E8h, 5Ah
		db	 00h, 7Fh,0F0h, 08h, 00h, 3Fh
		db	0D4h, 01h, 00h, 1Bh,0E8h, 00h
		db	 40h, 17h,0F0h, 5Ah, 00h, 02h
		db	 10h, 5Ah, 01h, 01h, 5Ah, 01h
		db	 07h, 00h, 01h, 00h, 2Fh, 5Ah
		db	 01h, 1Fh, 5Ah, 01h, 0Fh, 00h
		db	 06h, 00h, 0Fh, 5Ah, 01h,0BFh
		db	 00h, 02h, 3Fh,0E0h, 02h, 00h
		db	0FFh, 00h, 60h, 00h,0F0h, 40h
		db	 5Ah, 00h, 4Ch, 5Ah, 01h, 18h
		db	 5Ah, 01h, 14h, 80h, 5Ah, 00h
		db	0CEh, 20h, 04h, 00h,0D7h, 80h
		db	 5Ah, 01h, 15h, 5Ah, 03h, 07h
		db	 00h, 02h, 00h, 1Dh, 01h,0C0h
		db	 01h, 8Eh, 07h,0F4h, 07h,0E0h
		db	 1Fh,0C0h, 1Fh,0C0h, 07h,0A0h
		db	 07h,0A0h, 01h,0F0h, 01h,0F0h
		db	 5Ah, 00h, 14h, 5Ah, 01h,0C0h
		db	 5Ah, 01h, 98h, 00h, 0Ch, 00h
		db	 20h, 00h, 7Ch, 00h, 0Ch, 00h
		db	 55h, 30h, 55h, 30h, 15h, 40h
		db	 15h, 40h, 14h, 00h, 14h, 5Ah
		db	 00h, 20h, 5Ah, 01h, 60h, 5Ah
		db	 00h, 08h, 7Bh, 08h, 03h, 00h
		db	0AFh, 00h,0AFh, 01h,0FFh, 01h
		db	0FFh, 13h, 83h, 03h, 8Ch, 11h
		db	 26h, 09h, 21h, 01h, 60h, 0Dh
		db	 9Ch, 04h, 5Ah, 01h, 06h, 5Ah
		db	 01h,0DEh, 00h,0C0h, 00h,0F5h
		db	 00h,0F5h, 00h,0F5h, 40h,0F5h
		db	 40h, 01h, 40h,0E1h, 48h, 44h
		db	 80h,0C4h, 98h, 10h, 80h, 7Fh
		db	0B0h, 00h, 7Ah, 00h, 7Ah, 00h
		db	 35h, 00h, 31h, 00h, 56h, 00h
		db	 51h, 00h, 30h, 00h, 35h,0BAh
		db	 68h, 00h, 69h, 00h, 90h, 00h
		db	 91h, 00h, 7Fh, 00h, 6Ah, 00h
		db	 01h, 00h, 7Ch,0C0h, 00h,0F0h
		db	0C0h, 40h, 00h, 5Eh, 38h,0C0h
		db	 00h,0D7h, 5Ch, 70h, 00h, 77h
		db	 57h, 5Ch, 00h, 5Dh, 10h, 10h
		db	 00h, 54h, 54h, 5Ah, 00h, 55h
		db	0FCh,0C0h, 00h,0B1h, 50h, 5Ah
		db	 01h, 17h, 5Ah, 01h, 19h, 5Ah
		db	 01h, 16h, 00h, 01h, 00h, 10h
		db	 00h, 1Ch, 00h, 1Ch, 00h, 05h
		db	 00h, 09h, 00h, 51h, 00h, 02h
		db	 00h, 55h, 5Ah, 00h, 50h, 80h
		db	 5Ah, 01h, 20h,0FCh, 5Ah, 00h
		db	 10h,0AAh, 80h, 5Ah, 00h, 55h
		db	 5Ah, 00h, 10h,0FEh, 80h, 00h
		db	 20h,0FFh, 5Ah, 00h, 80h,0FCh
		db	 00h, 02h, 00h,0A8h, 00h, 1Ah
		db	 5Ah, 01h,0CBh, 80h, 5Ah, 00h
		db	 25h,0C0h, 01h, 00h, 83h,0E0h
		db	 00h,0C0h, 00h,0E0h, 5Ah, 00h
		db	 01h, 70h, 00h, 60h, 40h, 70h
		db	 5Ah, 00h, 10h,0E8h, 5Ah, 01h
		db	 15h, 5Ah, 00h, 01h, 3Eh, 00h
		db	 18h, 00h, 3Ah, 5Ah, 01h,0DBh
		db	 5Ah, 01h, 1Dh, 00h, 08h, 00h
		db	0CFh, 5Ah, 01h, 3Fh, 00h, 04h
		db	 01h,0DFh, 5Ah, 00h,0C1h,0F0h
		db	 00h,0C0h,0A1h,0E8h, 5Ah, 00h
		db	0E3h, 62h, 5Ah, 00h,0A7h, 81h
		db	 5Ah, 00h,0DFh, 48h, 5Ah, 00h
		db	0FFh, 84h, 0Ch, 00h,0FFh, 5Ah
		db	 01h,0FCh, 12h, 5Ah, 00h, 07h
		db	 7Fh, 5Ah, 00h, 07h,0FFh, 00h
		db	 30h, 2Fh,0FFh, 00h, 86h, 17h
		db	0FFh, 5Ah, 00h, 0Fh,0FEh, 00h
		db	 40h, 2Bh,0FCh, 00h, 08h, 17h
		db	0D8h, 5Ah, 00h, 0Fh,0E8h, 5Ah
		db	 00h,0B8h, 04h,0C0h, 00h,0F0h
		db	 5Ah, 01h,0C0h, 5Ah, 02h, 04h
		db	 5Ah, 01h, 20h, 5Ah, 00h, 04h
		db	 5Ah, 05h, 01h, 5Ah, 01h, 07h
		db	0FEh, 5Ah, 01h,0FFh, 00h, 06h
		db	 02h, 0Fh, 5Ah, 01h, 32h, 5Ah
		db	 01h, 98h, 5Ah, 01h, 28h, 5Ah
		db	 01h, 73h, 5Ah, 00h, 01h,0EBh
		db	 5Ah, 00h, 40h, 5Ah, 01h, 80h
		db	 5Ah, 01h,0F0h, 5Ah, 01h,0F4h
		db	 00h, 40h, 00h,0F8h, 5Ah, 01h
		db	0F8h, 00h, 10h, 00h,0F0h, 5Ah
		db	 01h,0FDh, 00h, 80h, 5Ah, 04h
		db	 01h, 5Ah, 01h, 01h, 5Ah, 01h
		db	 05h, 5Ah, 01h, 01h
data_29		db	5Ah
		db	1, 6

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_3:
		pop	dx
		add	[bx+si],dx
		pop	dx
		add	data_22,dx
		pop	dx
		push	es
		db	 60h, 5Ah, 01h,0C8h, 00h, 80h
		db	 00h, 50h, 5Ah, 01h, 74h, 00h
		db	 30h, 00h, 96h, 5Ah, 01h, 28h
		db	 5Ah, 01h, 08h, 5Ah, 01h, 01h
		db	 05h, 01h, 00h, 20h, 2Fh, 5Ah
		db	 00h, 08h, 93h, 5Ah, 01h, 3Dh
		db	 00h, 09h, 00h,0BDh, 5Ah, 00h
		db	 13h,0D5h, 01h, 80h, 2Ah,0EFh
		db	 5Ah, 00h,0E8h, 00h, 40h, 00h
		db	0FCh, 00h, 30h, 00h,0E8h, 00h
		db	0C0h, 00h,0A4h, 5Ah, 01h,0DBh
		db	 48h, 5Ah, 00h,0F7h,0D0h, 20h
		db	 00h,0B7h,0B8h, 5Ah, 00h, 7Dh
		db	0F6h, 5Ah, 00h, 19h,0BFh, 00h
		db	 02h, 2Dh,0FFh, 08h, 00h, 3Eh
		db	0FFh, 0Ah, 18h, 17h,0FFh, 5Ah
		db	 00h, 0Fh,0FEh, 00h, 10h, 2Bh
		db	0FCh, 00h, 80h, 17h,0D8h, 02h
		db	 00h, 0Fh,0E8h, 5Ah, 00h,0FBh
		db	0BCh
data_30		db	20h			; Data table (indexed access)
		db	 10h,0FDh, 0Bh, 80h, 00h,0C0h
		db	 0Ch, 00h, 04h, 00h, 16h, 5Ah
		db	 01h, 0Ch, 5Ah, 01h, 28h, 5Ah
		db	 00h, 40h, 5Ah, 02h, 08h, 5Ah
		db	 00h, 07h,0FCh, 00h, 40h, 00h
		db	0FFh, 00h, 06h, 02h, 0Fh, 5Ah
		db	 01h, 32h, 5Ah, 01h, 18h, 5Ah
		db	 00h, 01h, 28h, 5Ah, 00h, 04h
		db	 73h, 00h, 20h, 01h,0EBh, 5Ah
		db	 00h
data_31		db	8
		db	 40h, 5Ah, 00h, 80h, 5Ah, 01h
		db	0E0h, 00h, 80h, 00h,0F4h, 5Ah
		db	 01h,0F8h, 5Ah, 01h,0F0h, 00h
		db	 60h, 00h,0F0h, 5Ah, 01h,0FDh
		db	 00h, 40h, 00h, 16h, 80h,0E9h
		db	 50h, 00h, 08h,0FFh,0F6h, 5Ah
		db	 00h, 05h, 7Fh, 54h, 5Ah, 00h
		db	 16h, 95h, 5Ah, 01h,0E5h, 00h
		db	0A0h, 00h, 5Fh, 00h,0A8h, 00h
		db	 45h, 00h, 08h, 5Ah, 00h, 15h
		db	 5Ah, 03h, 14h, 5Ah, 01h, 13h
		db	 00h, 40h, 00h, 14h, 01h, 50h
		db	 01h, 40h, 05h,0C0h, 05h,0C0h
		db	 0Fh, 00h, 0Fh, 00h, 1Fh, 70h
		db	 1Fh, 70h, 54h, 5Ah, 03h,0D0h
		db	 00h, 30h, 00h,0C0h, 00h, 0Ch
		db	 00h,0F0h, 00h, 7Ch, 00h, 0Ch
		db	 00h, 5Eh, 00h, 5Eh, 00h, 17h
		db	 80h, 17h, 80h, 15h,0B0h, 15h
		db	0B0h, 5Ah, 07h, 80h, 5Ah, 00h
		db	 01h, 80h, 5Ah, 00h
loc_17:
;*		add	ax,sp
		db	 01h,0E0h		;  Fixup - byte match
		pop	dx
		add	[bp+di],al
		stosw				; Store ax to es:[di]
		add	bp,ss:data_7e[bp+di]
		add	ch,dh
		aas				; Ascii adjust
		retn	0DB27h
sub_2		endp

			                        ;* No entry point to code
		pop	dx
		adc	al,ds:data_34e[bx+si]
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
		add	[bx+si],ah
		add	ds:data_33e[bx+si],ah
		db	 60h, 3Dh, 78h, 1Ah,0A0h, 18h
		db	0AFh, 2Bh, 60h, 28h,0EBh, 18h
		db	 38h, 1Ah,0BBh, 34h, 2Eh, 34h
		db	0AEh, 48h, 08h, 48h,0AAh, 3Fh
		db	 80h, 35h, 2Ah, 00h,0E0h, 3Eh
		db	 58h, 5Ah, 00h, 60h, 5Ah, 01h
		db	 1Ch, 5Ah, 01h,0AEh, 5Ah, 01h
		db	0ABh, 80h, 5Ah, 00h, 88h, 00h
		db	 08h, 00h, 22h, 5Ah, 01h,0FEh
		db	 5Ah, 01h,0A8h, 5Ah, 00h, 0Eh
		db	 5Fh,0E4h, 34h, 01h,0CBh, 41h
		db	 11h,0A0h, 2Eh, 5Fh, 5Ah, 00h
		db	 0Ah,0DFh, 06h, 40h, 00h, 4Eh
		db	 02h, 2Fh, 00h, 4Dh, 02h, 8Ah
		db	 00h, 15h, 02h,0AAh, 5Ah, 14h
		db	 80h, 5Ah, 01h,0C8h, 00h, 80h
		db	 00h,0B2h, 00h, 30h, 5Ah, 00h
		db	 40h, 5Ah, 01h, 30h, 5Ah, 01h
		db	 18h, 5Ah, 01h, 0Eh, 00h, 08h
		db	 00h, 0Eh, 00h, 04h, 00h, 0Bh
		db	 5Ah, 01h, 16h, 5Ah, 01h, 07h
		db	 5Ah, 00h, 1Ch, 5Ah, 01h, 0Eh
		db	 80h, 04h, 00h, 0Bh, 40h, 5Ah
		db	 00h, 07h, 80h, 5Ah, 00h, 85h
		db	0C0h, 01h, 00h, 03h,0E0h, 5Ah
		db	 00h, 8Fh,0A0h, 03h, 00h, 5Dh
		db	0E0h, 5Ah, 01h, 0Eh, 00h, 04h
		db	 00h, 0Bh, 5Ah, 01h, 16h, 5Ah
		db	 01h, 37h, 5Ah, 01h, 3Fh, 00h
		db	 18h, 00h, 5Bh, 00h, 01h, 00h
		db	 6Fh, 5Ah, 01h, 5Fh, 5Ah, 00h
		db	0FDh,0C0h, 30h, 00h, 7Bh,0C0h
		db	 40h, 00h,0EFh, 5Ah, 01h,0FBh
		db	 00h, 80h, 00h,0F4h, 5Ah, 01h
		db	0ECh, 5Ah, 01h,0F8h, 5Ah, 01h
		db	0B0h, 5Ah, 02h, 3Fh, 00h, 04h
		db	 00h, 37h, 00h, 01h, 00h, 1Dh
		db	 5Ah, 01h, 1Eh, 00h, 08h, 00h
		db	 0Fh, 00h, 04h, 00h, 05h, 5Ah
		db	 01h, 03h, 00h, 01h, 00h, 07h
		db	 5Ah, 00h,0F4h, 5Ah, 01h,0F8h
		db	 00h, 10h, 00h,0BAh, 5Ah, 01h
		db	 9Ch, 5Ah, 01h, 2Fh, 00h, 04h
		db	 00h,0CEh, 00h, 04h, 00h, 8Bh
		db	 80h, 5Ah, 00h, 40h,0E0h, 5Ah
		db	 00h, 40h, 5Ah, 06h, 10h, 5Ah
		db	 01h, 06h, 5Ah, 01h, 0Ah, 5Ah
		db	 01h, 0Bh, 5Ah, 01h, 12h, 5Ah
		db	 01h, 05h, 5Ah, 10h, 84h, 5Ah
		db	 01h, 02h, 5Ah, 01h, 86h, 80h
		db	 5Ah, 00h, 05h, 40h, 5Ah, 01h
		db	 0Bh, 5Ah, 01h, 0Eh, 00h, 02h
		db	 00h, 17h, 5Ah, 01h, 3Ah, 5Ah
		db	 01h, 2Eh, 5Ah, 01h, 5Bh, 5Ah
		db	 01h, 6Ch, 5Ah, 01h, 7Bh, 00h
		db	 10h, 46h, 80h, 5Ah, 00h, 8Fh
		db	 40h, 5Ah, 00h, 25h, 5Ah, 01h
		db	 7Ah, 5Ah, 01h,0EAh, 5Ah, 01h
		db	0F4h, 00h, 40h, 00h,0F8h, 5Ah
		db	 01h,0F0h, 00h, 80h, 5Ah, 00h
		db	 36h, 00h, 02h, 00h, 36h, 5Ah
		db	 01h, 1Dh, 5Ah, 01h, 16h, 5Ah
		db	 01h, 03h, 5Ah, 01h, 01h, 5Ah
		db	 08h,0A0h, 5Ah, 01h,0E0h, 5Ah
		db	 01h,0D0h, 5Ah, 01h, 60h, 5Ah
		db	 01h, 10h, 5Ah, 01h, 14h, 5Ah
		db	 05h, 02h, 5Ah, 01h, 8Ch, 10h
		db	 82h,0F3h, 01h, 0Bh, 05h, 6Bh
		db	 21h, 95h, 01h, 95h,0A1h, 8Eh
		db	 15h,0AEh, 32h, 9Bh, 4Eh,0BBh
		db	 08h, 7Dh,0FCh, 7Dh, 01h, 8Bh
		db	 29h, 8Bh, 00h,0A0h, 5Ah, 05h
		db	 02h, 5Ah, 01h, 10h, 5Ah, 01h
		db	 22h, 5Ah, 01h, 28h, 5Ah, 01h
		db	 12h, 00h, 02h, 00h, 40h, 5Ah
		db	 01h, 48h, 5Ah, 00h, 40h, 80h
		db	 5Ah, 00h, 81h, 5Ah, 01h, 05h
		db	 00h, 04h, 00h, 02h, 5Ah, 01h
		db	 22h, 5Ah, 01h, 44h, 5Ah, 05h
		db	 10h, 5Ah, 06h, 24h, 5Ah, 01h
		db	 10h, 5Ah, 05h, 01h, 00h, 01h
		db	 00h, 04h, 5Ah, 05h, 01h, 5Ah
		db	 02h,0D7h, 70h, 20h, 82h, 27h
		db	0A2h, 89h, 90h, 8Bh, 90h, 25h
		db	 80h, 65h, 80h,0CCh, 50h,0DCh
		db	 48h, 22h, 10h, 62h,0ACh, 42h
		db	 00h, 40h,0F6h, 8Ah, 00h, 80h
		db	 7Ch, 00h,0A9h, 00h, 01h, 00h
		db	0FEh, 00h, 7Eh, 00h,0AEh, 5Ah
		db	 01h, 2Bh, 5Ah, 01h, 02h, 01h
		db	0D8h, 5Ah, 00h, 03h,0E8h, 5Ah
		db	 00h, 03h,0F0h, 03h, 5Ah, 00h
		db	 40h, 01h, 00h,0E2h, 6Eh, 00h
		db	 00h,0BBh,0D0h, 60h, 00h, 59h
		db	 7Ch, 38h, 00h, 10h, 4Eh,0A8h
		db	 5Ah, 00h, 1Ch, 28h, 5Ah, 01h
		db	0F8h, 00h, 40h, 00h, 28h, 00h
		db	 40h, 5Ah, 10h, 03h, 5Ah, 01h
		db	0EAh, 00h,0A8h, 03h,0BAh, 00h
		db	0BAh, 02h, 23h, 02h,0EFh, 5Ah
		db	 06h, 80h, 5Ah, 01h,0C0h, 5Ah
		db	 01h,0C0h, 5Ah, 01h,0A0h, 00h
		db	0A0h, 00h,0E8h, 00h,0E8h, 00h
		db	0AAh, 00h,0AAh, 5Ah, 00h, 03h
		db	 03h, 0Fh, 18h, 62h, 04h, 1Ah
		db	 10h, 83h, 2Ah, 6Bh, 80h, 0Eh
		db	 6Ah,0EEh, 00h, 3Ah, 08h,0BAh
		db	 08h, 08h, 22h, 2Ah, 5Ah, 00h
		db	 3Fh,0AAh, 00h, 03h, 0Ah, 8Dh
		db	0BAh, 00h,0BAh, 00h, 88h, 00h
		db	0B8h, 00h, 0Ah, 00h,0EAh, 00h
		db	 0Eh, 00h,0AEh, 00h, 3Ah, 00h
		db	0BAh, 00h, 2Ah, 80h,0AAh, 80h
		db	0FEh, 00h, 56h, 00h, 80h, 00h
		db	 3Eh, 5Ah, 00h, 03h, 00h, 39h
		db	 00h, 0Eh, 00h,0ECh, 00h, 3Ah
		db	 00h,0D0h, 0Ah,0EAh, 00h, 40h
		db	0FFh,0A9h, 5Ah, 00h, 0Ah,0A7h
		db	 00h, 05h, 00h,0FAh, 00h, 15h
		db	 00h,0A2h, 00h, 10h, 80h, 00h
		db	 3Ah, 6Eh, 00h, 00h, 3Bh,0A0h
		db	0A0h, 00h, 0Ah,0E0h,0A8h, 00h
		db	 02h,0A8h, 3Bh, 00h, 38h,0A8h
		db	0A2h, 00h, 90h, 3Ch, 8Ah, 00h
		db	 40h, 3Ah,0AAh, 5Ah, 00h, 08h
		db	 00h, 2Ah, 5Ah, 03h, 0Bh, 00h
		db	 0Ch, 00h, 03h, 00h, 30h, 00h
		db	 0Fh, 00h, 3Eh, 00h, 30h, 0Ch
		db	0FAh, 0Ch,0FAh, 03h,0A8h, 03h
		db	0A8h, 00h, 28h, 00h, 28h,0A8h
		db	 5Ah, 03h, 28h, 5Ah, 01h,0C8h
		db	 00h, 02h, 80h, 28h, 80h, 3Ah
		db	0E0h, 02h,0E0h, 03h,0A8h, 03h
		db	0A8h, 00h,0E0h, 00h,0E0h, 0Eh
		db	 80h, 0Eh, 80h, 5Ah, 0Bh, 03h
		db	 5Ah, 01h,0EAh, 00h,0A8h, 03h
		db	0BAh, 00h,0BAh, 02h, 23h, 02h
		db	0EFh, 00h, 03h, 03h, 0Fh, 5Ah
		db	 02h, 80h, 5Ah, 01h,0C0h, 5Ah
		db	 01h,0C0h, 5Ah, 01h,0A0h, 00h
		db	0A0h, 00h,0E8h, 00h,0E8h, 00h
		db	0AAh, 00h,0AAh, 00h,0BAh, 00h
		db	0BAh, 00h, 18h, 62h, 04h, 1Ah
		db	 10h, 83h, 2Ah, 6Bh, 80h, 0Eh
		db	 6Ah,0EEh, 00h, 3Ah, 00h,0BAh
		db	 00h, 08h, 08h,0AAh, 5Ah, 00h
		db	 12h,0EAh, 08h, 03h, 37h, 8Dh
		db	 00h, 03h, 14h, 39h, 88h, 00h
		db	0B8h, 00h, 0Ah, 00h,0EAh, 00h
		db	 0Eh, 00h,0AEh, 00h, 3Ah, 00h
		db	0BAh, 00h, 2Ah, 80h,0AAh, 80h
		db	0FEh, 00h, 56h, 5Ah, 01h,0F8h
		db	 5Ah, 01h,0EAh, 5Ah, 00h, 0Eh
		db	 00h,0ECh, 00h, 3Ah, 00h,0D0h
		db	 00h,0EAh, 00h, 40h, 00h,0AAh
		db	 5Ah, 00h, 0Fh, 27h, 00h, 05h
		db	 00h,0F2h, 00h, 15h, 00h,0AAh
		db	 00h, 10h, 00h,0AAh, 5Ah, 02h
		db	0AAh, 00h, 80h, 00h, 2Eh, 5Ah
		db	 01h, 2Bh, 00h, 80h, 00h, 0Eh
		db	 80h,0A0h, 20h,0AEh, 6Eh, 00h
		db	 00h, 0Dh, 00h, 80h, 00h, 1Ah
		db	 00h, 90h, 00h, 2Ah, 5Ah, 02h
		db	 03h, 5Ah, 01h, 0Bh, 00h, 01h
		db	 00h, 0Ah, 5Ah, 01h, 02h, 5Ah
		db	 07h, 0Ch, 00h, 0Ch, 00h, 03h
		db	 00h, 03h, 5Ah, 00h,0A8h, 5Ah
		db	 01h,0C0h, 5Ah, 01h,0E0h, 00h
		db	 80h, 00h, 68h, 00h,0E8h, 5Ah
		db	 01h,0FAh, 00h,0FAh, 00h, 2Ah
		db	 00h, 2Ah, 00h,0AAh, 00h,0AAh
		db	 5Ah, 00h, 03h, 03h, 0Fh, 18h
		db	 62h, 04h, 1Ah, 10h, 83h, 2Ah
		db	 6Bh, 80h, 0Eh, 6Ah,0EEh, 00h
		db	 3Ah, 00h,0BAh, 00h, 08h, 00h
		db	 2Ah, 5Ah, 00h, 01h, 6Ah, 01h
		db	 03h, 0Ah,0CDh, 08h, 03h, 15h
		db	 39h, 00h, 0Eh, 08h,0ECh, 00h
		db	 3Ah, 00h,0D0h, 00h,0EAh, 00h
		db	 40h, 00h,0AAh, 5Ah, 01h, 80h
		db	 00h, 02h, 00h,0B0h, 00h, 0Bh
		db	 00h, 80h, 00h, 3Ah, 5Ah, 00h
		db	0EAh, 5Ah, 01h,0AAh, 5Ah, 01h
		db	0E8h, 5Ah, 01h,0B0h, 00h, 03h
		db	0E8h,0B0h, 00h, 0Ah, 00h,0E0h
		db	 00h, 0Ah, 00h, 80h, 00h, 2Ah
		db	 00h, 80h, 5Ah, 02h, 28h, 5Ah
		db	 01h, 03h, 5Ah, 01h, 19h, 00h
		db	 30h, 00h, 04h, 00h, 3Eh, 00h
		db	 30h, 0Ch,0FAh, 0Ch,0FAh, 03h
		db	0A8h, 03h,0A8h, 00h, 28h, 00h
		db	 28h,0A8h, 5Ah, 03h,0E0h, 00h
		db	 40h, 00h,0B8h, 00h, 02h, 80h
		db	 70h, 80h, 2Ah,0E0h, 02h,0E0h
		db	 03h,0A8h, 03h,0A8h, 00h,0E0h
		db	 00h

locloop_18:
		loopnz	locloop_19		; Loop if zf=0, cx>0

		or	byte ptr ds:data_32e,0
		add	ax,0A328h
		sbb	byte ptr [bx+si],0
		xchg	[bx+si+11h],ax

locloop_19:
		inc	ax
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		cmpsw				; Cmp [si] to es:[di]
		add	sp,ds:data_37e[bx]
		add	bx,ss:data_42e[bp]
		add	di,ax
		add	ds:data_38e[bx+si],sp
		add	ds:data_34e[bx+si],al
		add	sp,ax
		add	ax,[bx+si]
		iret				; Interrupt return
			                        ;* No entry point to code
		mov	al,ds:data_40e
		cmp	al,ds:data_36e[bx+si]
		add	al,ds:data_35e[bx+si]
		pop	dx
		push	cs
		add	[bx+si],ax
		or	bh,bh			; Zero ?
		xor	[bx+si],al
		dec	di
;*		call	dword ptr [bp+si+0]
		db	0FFh, 5Ah, 00h		;  Fixup - byte match
		db	0FEh,0A0h, 00h, 2Ah, 68h, 5Ah
		db	 00h,0A9h, 5Ah, 01h,0A7h, 00h
		db	 05h, 00h,0FAh, 00h, 15h, 00h
		db	0A2h, 00h, 10h, 5Ah, 00h,0E8h
		db	 5Ah, 01h, 98h, 5Ah, 01h, 68h
		db	 00h, 80h, 00h, 08h, 00h, 38h
		db	 00h, 38h, 00h,0A0h, 00h, 90h
		db	 00h, 8Ah, 00h, 40h, 00h,0AAh
		db	 5Ah, 02h, 2Ah, 5Ah, 03h, 0Bh
		db	 00h, 0Ch, 00h, 03h, 00h, 30h
		db	 00h, 0Fh, 00h, 3Eh, 00h, 30h
		db	 00h, 7Ah, 00h, 7Ah, 01h,0E8h
		db	 01h,0E8h, 0Dh,0A8h, 0Dh,0A8h
		db	0A8h, 5Ah, 03h, 28h, 5Ah, 01h
		db	0C8h, 00h, 02h, 00h, 28h, 00h
		db	 0Ah, 80h, 02h, 80h, 03h,0A0h
		db	 03h,0A0h, 00h,0F0h, 00h,0F0h
		db	 0Eh,0F8h, 0Eh,0F8h, 10h, 02h
		db	 10h, 02h, 80h, 00h, 80h, 00h
		db	 08h, 40h, 08h, 40h, 26h, 12h
		db	 26h, 12h, 03h, 42h, 03h, 42h
		db	 04h, 31h, 04h, 31h, 21h, 5Fh
		db	 21h, 5Fh, 02h,0B7h, 02h,0B7h
		db	 5Ah, 03h, 04h, 00h, 04h, 40h
		db	 00h, 40h, 00h, 42h, 20h, 42h
		db	 20h, 4Dh, 00h, 4Dh, 00h,0ADh
		db	 41h,0ADh, 41h,0EEh, 96h,0EEh
		db	 96h,0B5h,0C0h,0B5h,0C0h, 89h
		db	 74h, 89h, 74h, 02h,0A2h, 02h
		db	0A0h, 48h,0DEh, 48h, 00h, 2Bh
		db	 60h, 5Ah, 00h, 0Ch, 15h, 5Ah
		db	 00h,0E7h, 00h, 5Ah, 01h, 01h
		db	 00h,0E0h, 00h, 40h, 01h, 10h
		db	 24h,0E8h, 24h,0ECh, 00h, 30h
		db	 01h, 74h, 02h, 05h, 02h, 25h
		db	 07h, 80h, 04h, 90h,0C7h,0A2h
		db	 03h,0A2h,0FBh, 40h, 7Bh, 40h
		db	 7Eh, 80h, 7Eh, 80h, 15h, 00h
		db	 15h, 00h, 21h, 00h, 21h, 5Ah
		db	 00h, 14h, 00h, 14h, 88h, 40h
		db	 88h, 40h, 05h, 1Dh, 05h, 1Dh
		db	 11h,0CDh, 11h,0CDh, 05h, 06h
		db	 05h, 06h, 00h, 29h, 00h, 29h
		db	 00h, 9Ch, 00h, 9Ch, 80h, 00h
		db	 80h, 00h, 48h, 00h, 48h, 00h
		db	 01h, 10h, 01h, 10h, 08h, 74h
		db	 08h, 34h, 20h,0D4h, 20h, 54h
		db	 40h,0D4h, 40h, 14h, 06h,0F4h
		db	 10h,0F4h, 27h, 68h, 2Bh, 68h
		db	 5Ah, 13h, 01h, 00h, 01h, 00h
		db	 07h, 00h, 01h, 00h, 04h, 00h
		db	 05h, 5Ah, 06h, 01h, 5Ah, 01h
		db	 01h, 80h, 5Ah, 00h, 07h, 80h
		db	 5Ah, 00h,0D5h, 40h, 51h, 40h
		db	 75h,0D0h, 75h,0D0h, 47h, 54h
		db	0DFh, 54h, 5Ah, 01h, 06h, 00h
		db	 30h, 00h, 08h, 00h, 21h, 00h
		db	 54h, 01h, 5Ah, 00h,0D5h, 5Ah
		db	 01h, 11h, 00h, 10h, 00h, 44h
		db	 5Ah, 01h, 7Fh, 5Ah, 01h, 15h
		db	 07h, 74h, 1Fh, 74h,0C5h, 10h
		db	 35h, 70h, 06h, 14h,0D7h,0D4h
		db	 1Ch, 1Ch,0DDh, 5Ch, 74h, 74h
		db	 75h, 74h, 10h, 55h, 55h, 55h
		db	 01h,0FCh, 54h,0ACh, 07h, 00h
		db	 1Ah, 7Ch, 00h, 80h, 01h, 47h
		db	 03h, 01h, 08h,0DDh, 30h, 06h
		db	 0Eh, 9Ah, 20h, 1Ch, 52h, 08h
		db	 00h, 15h, 38h, 5Ah, 00h, 14h
		db	 5Ah, 01h, 1Fh, 00h, 02h, 00h
		db	 14h, 00h, 02h, 70h, 00h, 27h
		db	0FAh, 80h, 60h, 82h, 9Fh, 65h
		db	 80h, 9Ah, 7Ch, 40h, 00h,0BBh
		db	 50h, 02h, 60h, 72h, 00h,0F4h
		db	 40h,0B2h, 00h, 51h, 40h,0A8h
		db	 00h, 55h, 40h, 5Ah, 09h, 01h
		db	 5Ah, 01h, 03h, 5Ah, 01h, 03h
		db	 5Ah, 01h, 07h, 00h, 07h, 00h
		db	 1Fh, 00h, 05h, 00h, 7Fh, 00h
		db	 4Fh, 5Ah, 0Eh,0C0h, 5Ah, 01h
		db	 57h, 00h, 57h, 00h,0DDh,0C0h
		db	0DDh,0C0h, 84h, 40h,0B7h, 40h
		db	 00h, 7Ah, 00h, 7Ah, 00h, 35h
		db	 00h, 31h, 00h, 56h, 00h, 51h
		db	 00h, 30h, 00h, 35h, 00h, 68h
		db	 00h, 69h, 00h, 90h, 00h, 91h
		db	 00h, 7Fh, 00h, 6Ah, 00h, 01h
		db	 00h, 7Ch, 61h, 08h, 01h, 48h
		db	0F0h, 30h, 20h,0F0h,0EAh,0C2h
		db	 68h, 52h,0F1h,0CBh, 70h,0CBh
		db	0F7h,0ADh,0F7h,0ADh,0F5h, 07h
		db	0F5h, 07h, 68h, 12h, 68h, 12h
		db	 02h, 01h, 02h, 01h, 8Bh,0A0h
		db	 99h,0A0h, 11h, 40h, 15h, 40h
		db	 08h, 00h, 08h, 5Ah, 03h, 42h
		db	 00h, 42h, 00h, 80h, 20h, 80h
		db	 20h, 84h, 04h, 84h, 04h, 02h
		db	 20h, 02h, 20h, 5Ah, 0Fh, 0Ah
		db	 5Ah, 01h, 2Bh, 5Ah, 01h,0BFh
		db	 00h, 02h, 2Ah,0FFh, 00h, 2Bh
		db	 5Ah, 06h, 80h, 5Ah, 01h, 80h
		db	 5Ah, 01h,0E8h, 00h, 80h, 00h
		db	0FEh, 00h, 80h, 00h,0FFh, 80h
		db	0E0h, 00h,0FFh,0EAh,0FAh, 5Ah
		db	 00h,0BFh, 00h, 02h, 00h, 2Fh
		db	 5Ah, 01h, 0Ah, 5Ah, 14h,0FFh
		db	 80h,0E0h, 00h,0FEh, 00h, 80h
		db	 00h,0E8h, 00h, 80h, 00h, 80h
		db	 5Ah, 01h, 80h, 5Ah, 01h, 80h
		db	 5Ah, 0Ah, 03h, 00h, 02h, 00h
		db	 0Fh, 00h, 02h, 03h, 03h, 02h
		db	 00h, 30h, 3Ch, 20h, 08h, 00h
		db	0CCh, 5Ah, 00h, 03h, 0Ch, 5Ah
		db	 01h, 03h, 00h, 02h,0F0h, 3Fh
		db	 80h, 28h, 5Ah, 02h,0C0h, 00h
		db	 80h, 00h, 0Ch, 00h, 08h, 5Ah
		db	 03h,0F0h, 30h,0A0h, 20h, 0Ch
		db	 00h, 08h, 5Ah, 03h,0C0h,0CFh
		db	 80h, 00h, 0Ch,0CFh, 5Ah, 01h
		db	 03h, 00h, 02h, 0Ch,0C0h, 5Ah
		db	 01h, 0Fh, 00h, 02h, 33h, 30h
		db	 20h, 5Ah, 04h,0C3h, 00h, 82h
		db	 00h, 03h, 5Ah, 00h,0CCh, 00h
		db	 80h, 00h, 03h,0C0h, 00h, 80h
		db	0CCh, 5Ah, 05h, 30h, 30h, 00h
		db	 20h, 03h, 00h, 02h, 00h,0F0h
		db	 00h, 20h, 5Ah, 07h, 03h, 00h
		db	 02h, 5Ah, 03h,0C0h, 00h, 80h
		db	 5Ah, 00h, 03h, 00h, 02h, 5Ah
		db	 03h, 3Ch, 00h, 20h, 30h, 30h
		db	 20h, 5Ah, 03h, 03h, 0Ch, 02h
		db	 08h, 5Ah, 06h, 30h, 00h, 20h
		db	 00h, 03h, 03h,0E7h, 00h,0C0h
		db	 00h, 80h, 00h, 03h, 5Ah, 02h
		db	 0Ch, 00h, 08h, 00h,0C0h, 00h
		db	 80h, 00h, 03h, 00h, 02h, 5Ah
		db	 0Ah, 03h, 00h, 02h, 00h,0C0h
		db	 00h, 80h, 00h,0F0h, 00h,0A0h
		db	 00h,0F0h, 00h, 80h, 00h, 03h
		db	 00h, 02h, 5Ah, 08h, 03h, 00h
		db	 02h, 30h, 30h, 20h, 20h, 5Ah
		db	 0Fh, 1Fh, 5Ah, 01h,0FDh, 5Ah
		db	 00h, 03h,0FEh, 5Ah, 00h, 06h
		db	0F8h, 5Ah, 00h, 0Dh,0E8h, 00h
		db	 05h, 5Ah, 0Ah,0D0h, 5Ah, 01h
		db	 52h, 5Ah, 01h, 8Ah, 40h, 5Ah
		db	 01h, 20h, 5Ah, 01h, 10h,0A0h
		db	 00h, 0Dh, 90h, 00h, 03h, 0Dh
		db	 40h, 00h, 05h, 06h, 40h, 5Ah
		db	 00h, 03h, 5Ah, 02h,0A0h, 5Ah
		db	 01h, 15h, 5Ah, 09h, 10h,0C0h
		db	 5Ah, 00h, 10h,0A0h, 5Ah, 00h
		db	 20h, 5Ah, 01h, 40h, 5Ah, 00h
		db	 02h, 5Ah, 01h, 50h, 5Ah, 16h
		db	 1Fh, 5Ah, 01h,0FDh, 5Ah, 00h
		db	 03h,0FEh, 5Ah, 00h, 06h,0F8h
		db	 00h, 05h, 0Dh,0E8h, 00h, 13h
		db	 5Ah, 0Ah,0D0h, 5Ah, 01h, 52h
		db	 5Ah, 01h, 8Ah, 40h, 5Ah, 01h
		db	 20h, 50h, 5Ah, 00h, 10h,0A8h
		db	 00h, 0Dh, 90h, 00h, 2Fh, 0Dh
		db	 40h, 00h, 17h, 06h, 40h, 00h
		db	 0Ah, 03h, 5Ah, 02h,0A0h, 5Ah
		db	 01h, 15h, 5Ah, 09h, 10h,0D0h
		db	 5Ah, 00h, 10h,0A8h, 5Ah, 00h
		db	 20h, 40h, 5Ah, 00h, 40h, 5Ah
		db	 00h, 02h, 5Ah, 01h, 50h, 5Ah
		db	 16h, 1Fh, 5Ah, 01h,0FDh, 5Ah
		db	 00h, 03h,0FEh, 00h, 01h, 06h
		db	0F8h, 00h, 07h, 0Dh,0E9h, 00h
		db	 16h, 5Ah, 0Ah,0D0h, 5Ah, 01h
		db	 52h, 5Ah, 01h, 8Ah, 40h, 20h
		db	 5Ah, 00h, 20h,0F5h, 00h, 40h
		db	 10h,0BAh, 00h, 0Dh, 92h, 00h
		db	 2Dh, 0Dh, 45h, 00h, 3Ah, 06h
		db	 40h, 00h, 1Fh, 03h, 5Ah, 00h
		db	 0Ah, 00h,0A0h, 5Ah, 01h, 15h
		db	 5Ah, 08h, 80h, 10h, 7Dh, 00h
		db	 40h, 10h,0BAh, 5Ah, 00h, 20h
		db	0D4h, 5Ah, 00h, 40h,0A0h, 00h
		db	 02h, 5Ah, 01h, 50h, 5Ah, 09h
		db	 03h,0BFh, 02h,0AAh, 08h, 5Ah
		db	 01h, 18h, 00h, 02h,0FEh, 30h
		db	 00h, 20h, 00h, 20h, 00h, 0Bh
		db	0FAh, 20h, 00h, 20h, 5Ah, 01h
		db	 0Bh,0FAh, 20h, 00h, 20h, 00h
		db	0AAh,0F0h,0AAh, 30h, 03h, 08h
		db	 00h, 08h, 02h, 04h,0AAh, 04h
		db	 04h, 02h, 04h, 22h, 5Ah, 00h
		db	0A0h, 48h, 04h, 02h, 04h, 92h
		db	 5Ah, 00h,0A1h, 20h, 04h, 02h
		db	 04h, 02h, 3Fh,0B6h, 23h,0A6h
		db	 20h, 34h, 00h, 24h, 10h, 1Ch
		db	 02h, 3Eh, 10h, 00h, 01h, 55h
		db	 10h, 00h, 10h, 00h, 10h, 00h
		db	 15h,0FDh, 10h, 00h, 12h,0AAh
		db	 1Dh, 50h, 1Dh, 50h,0EAh,0AAh
		db	 8Ah,0AAh, 04h, 02h, 04h, 02h
		db	 04h, 00h, 20h, 80h, 04h, 02h
		db	 44h, 22h, 04h, 02h, 05h, 02h
		db	 04h, 00h, 50h, 20h, 04h, 04h
		db	0A2h, 44h, 6Dh, 6Ch, 45h, 6Ch
		db	 00h, 02h, 00h, 02h, 00h, 07h
		db	 00h, 06h, 00h, 07h, 00h, 06h
		db	 00h, 1Fh, 00h, 1Fh, 00h, 78h
		db	 00h, 70h, 00h,0E0h, 00h,0C0h
		db	 00h, 78h, 00h, 70h, 00h, 1Fh
		db	 00h, 1Bh, 5Ah, 0Ah,0C0h, 00h
		db	0C0h, 00h,0F0h, 00h,0E0h, 00h
		db	 38h, 00h, 20h, 00h,0F0h, 00h
		db	0C0h, 00h,0C0h, 5Ah, 02h, 0Fh
		db	 00h, 0Dh, 00h, 0Bh, 00h, 0Ah
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 0Ah, 00h, 0Bh, 00h, 09h
		db	 00h, 0Bh, 00h, 0Ah, 00h, 0Bh
		db	 00h, 09h, 5Ah, 0Ah,0E0h, 00h
		db	0A0h, 5Ah, 03h, 90h, 00h, 90h
		db	 00h,0F0h, 00h,0C0h, 5Ah, 08h
		db	 07h, 5Ah, 01h, 0Fh, 5Ah, 01h
		db	 05h, 5Ah, 01h, 04h, 5Ah, 01h
		db	 3Fh, 5Ah, 01h, 0Fh, 5Ah, 01h
		db	 0Ah, 5Ah, 01h, 62h, 5Ah, 00h
		db	0E0h, 5Ah, 01h, 90h, 5Ah, 01h
		db	 20h, 5Ah, 01h, 20h, 5Ah, 01h
		db	 4Ch, 5Ah, 01h, 10h, 5Ah, 05h
		db	 02h, 5Ah, 01h

seg_a		ends



		end	start
