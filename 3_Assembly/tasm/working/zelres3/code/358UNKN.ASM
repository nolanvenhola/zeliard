
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_358UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_10e	equ	5200h			;*
data_11e	equ	5550h			;*
data_12e	equ	580Eh			;*
data_13e	equ	8000h			;*
data_14e	equ	0A000h			;*
data_15e	equ	0B903h			;*
data_16e	equ	0BA00h			;*
data_17e	equ	0BF32h			;*
data_18e	equ	0E0CBh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_358UNKN	proc	far

start:
		rcl	word ptr [bx],1		; Rotate thru carry
		add	[bx+si],al
		add	byte ptr ds:[4Bh],al
		jns	$-7Eh			; Jump if not sign
		cwd				; Word to double word
		add	dh,ds:data_15e[bx+di]
;*		and	ch,al
		db	 20h,0C5h		;  Fixup - byte match
;*		or	dl,dl			; Zero ?
		db	 08h,0D2h		;  Fixup - byte match
;*		add	di,di
		db	 01h,0FFh		;  Fixup - byte match
		dec	word ptr [bp+di+1Fh]
		push	cs
		add	data_5,cl
		add	[bp+si],al
		dec	bx
		add	[bp+si],ax
		dec	bx
		add	[bp+di],ax
		dec	bx
		add	[bp+si],ax
		dec	bx
		add	[bp+di],ax
		dec	bx
		add	[bp+si],ax
		dec	bx
		add	[bp+si],ax
		mov	al,ds:data_14e
		add	ds:data_13e[bx+si],al
		dec	bx
		add	data_4[bx+si],ax
		or	byte ptr [bp+di+1],80h
		dec	bx
		add	data_4[bx+si],ax
		or	byte ptr [bp+di+1],80h
		dec	bx
		add	cl,byte ptr data_7
;*		add	bh,al
		db	 00h,0C7h		;  Fixup - byte match
		add	[si],ch
		add	[bp+di],dl
		add	[bp+di],dh
		add	[bx],bl
		add	[si],cl
;*		add	dh,bh
		db	 00h,0FEh		;  Fixup - byte match
		add	[bp+si],dh
		add	[bp+si],bh
		add	[bx+si],cl
;*		add	dl,cl
		db	 00h,0CAh		;  Fixup - byte match
		dec	bx
		add	[bp+si],ax
		dec	bx
;*		add	al,cl
		db	 00h,0C8h		;  Fixup - byte match
		add	ds:data_10e[bx+si],ah
		add	[bp+si],cl
		mov	sp,5CF5h
		and	[bx+si],bh
		scasw				; Scan es:[di] for ax
		clc				; Clear carry flag
		mov	[bx+si],al
		test	al,0
		sub	[bx+si],al
		stosb				; Store al to es:[di]
		add	ds:data_14e[bx+si],al
		dec	bx
		add	[bx+si],cx
		dec	bx
		sbb	al,[bp+si]
		dec	bx
		add	data_3,cx
;*		jmp	far ptr loc_10		;*
		db	0EAh
		dw	3800h, 3800h		;  Fixup - byte match
		db	 4Bh, 01h, 28h, 4Bh, 01h, 28h
		db	 4Bh, 01h,0E0h, 4Bh, 01h,0A0h
		db	 4Bh, 01h, 80h, 4Bh, 01h,0C8h
		db	 4Bh, 00h, 08h, 00h,0C7h, 00h
		db	 2Ch, 00h, 13h, 00h, 32h, 00h
		db	 1Dh, 00h, 0Eh, 00h,0FDh, 00h
		db	 32h, 00h, 3Ah, 00h, 08h, 00h
		db	0CAh, 4Bh, 01h, 02h, 4Bh, 02h
		db	 20h, 00h,0E2h, 00h, 08h, 00h
		db	0E8h, 00h, 20h, 00h,0EAh, 00h
		db	8
data_2		dw	0E800h
		db	 00h, 88h, 00h, 7Ah, 00h, 80h
		db	 00h, 70h, 00h, 3Ch, 00h, 1Ch
		db	 00h, 38h, 00h, 38h, 4Bh, 1Ah
		db	 0Eh, 00h,0A8h, 00h, 57h, 0Eh
data_3		dw	0EA0h
		db	0A0h, 02h, 80h, 02h, 80h, 4Bh
		db	 00h, 02h, 80h, 4Bh, 00h, 0Eh
		db	 4Bh, 01h, 28h, 4Bh, 01h,0A0h
		db	 4Bh, 01h,0C8h, 00h, 20h, 00h
		db	0E2h, 00h,0FAh, 00h, 75h,0FFh
		db	0F0h, 33h,0FFh, 1Fh, 00h, 0Ch
		db	 00h,0FEh, 00h, 32h, 00h, 3Ah
		db	 00h, 08h, 00h,0CAh, 4Bh, 01h
		db	 02h, 4Bh, 06h, 08h, 00h,0E8h
		db	 00h, 20h, 00h,0AAh, 00h, 88h
		db	 00h,0A8h, 00h, 28h, 00h,0AAh
		db	 00h, 80h, 00h,0A0h, 4Bh, 01h
		db	 08h, 4Bh, 08h,0FFh, 00h, 7Fh
		db	 00h, 3Ch, 00h, 3Ch, 4Bh, 01h
		db	 3Ch, 00h, 20h, 00h, 1Ch, 00h
		db	 08h, 00h, 07h, 4Bh, 01h
data_4		dw	0Fh			; Data table (indexed access)
		db	 08h, 00h,0C7h, 00h, 2Ch, 00h
		db	 13h, 4Bh, 07h, 38h, 00h, 38h
		db	 00h, 28h, 00h,0A8h, 4Bh, 00h
		db	 03h,0A0h, 4Bh, 00h,0AAh, 80h
		db	 20h, 00h,0EAh, 00h,0C8h, 00h
		db	0E8h, 4Bh, 00h, 33h, 00h, 1Fh
		db	 00h, 0Ch, 00h,0FEh, 00h, 32h
		db	 00h, 3Ah, 00h, 08h, 00h,0CAh
		db	 4Bh, 01h, 02h, 4Bh, 0Ah, 20h
		db	 00h,0AAh, 00h, 88h, 00h,0A8h
		db	 00h, 28h, 00h,0AAh, 00h, 80h
		db	 00h,0A0h, 4Bh, 01h, 08h, 4Bh
		db	 0Ch, 0Fh, 00h, 07h, 00h, 03h
		db	 00h, 03h, 4Bh, 01h, 03h, 00h
		db	 02h, 00h, 01h, 00h, 02h, 00h
		db	 01h, 4Bh, 01h, 03h, 00h, 02h
		db	 00h, 01h, 4Bh, 01h, 03h,0F0h
		db	 00h,0F0h, 00h,0C0h, 00h,0C0h
		db	 4Bh, 01h,0C0h, 4Bh, 01h,0C0h
		db	 4Bh, 01h,0C0h, 4Bh, 01h,0C0h
		db	 4Bh, 01h,0C0h, 4Bh, 01h,0C0h
		db	 4Bh, 02h, 0Fh, 00h, 08h, 00h
		db	0C7h, 00h, 2Ch, 00h, 13h, 00h
		db	 33h, 00h, 1Fh, 00h, 0Ch, 00h
		db	0FEh, 00h, 32h, 00h, 3Ah, 00h
		db	 08h, 00h,0CAh, 4Bh, 01h, 02h
		db	 4Bh, 00h,0C8h, 00h, 20h, 00h
		db	0E2h, 00h,0C8h, 38h,0EAh,0B8h
		db	 20h, 28h,0AAh,0A8h, 88h, 00h
		db	0A8h, 00h, 28h, 00h,0AAh
data_5		db	0
		db	 80h, 00h,0A0h, 4Bh, 01h, 08h
		db	 4Bh, 1Ah, 03h, 4Bh, 01h, 0Fh
		db	0FFh, 00h, 7Fh, 00h, 3Ch, 00h
		db	 3Ch, 00h, 20h, 00h, 1Ch, 4Bh
		db	 01h, 3Ch, 00h, 80h, 00h, 70h
		db	 00h, 80h, 00h, 70h, 4Bh, 01h
		db	0C0h, 4Bh, 01h,0C8h, 4Bh, 00h
		db	 08h, 00h,0C7h, 00h, 2Ch, 00h
		db	 13h, 00h, 33h, 00h, 1Fh, 00h
		db	 0Ch, 00h,0FEh, 00h, 32h, 00h
		db	 3Ah, 00h, 08h, 00h,0CAh, 4Bh
		db	 01h, 02h, 4Bh, 02h, 20h, 00h
		db	0E2h, 00h,0C8h, 00h,0E8h, 00h
		db	 20h, 00h,0AAh, 00h, 88h, 00h
		db	0A8h, 00h, 28h, 00h,0AAh, 00h
		db	 80h, 00h,0A0h, 00h, 30h, 00h
		db	 38h, 00h, 28h, 00h, 28h, 4Bh
		db	 14h, 02h, 00h, 01h, 4Bh, 01h
		db	 0Fh, 00h, 08h, 00h,0C7h, 3Fh
		db	0C0h, 1Fh,0C0h, 0Fh, 00h, 0Fh
		db	 4Bh, 01h, 0Fh, 4Bh, 01h, 3Ch
		db	 00h, 80h, 00h, 70h, 4Bh, 01h
		db	0C0h, 4Bh, 01h,0C8h, 00h, 20h
		db	 00h,0E2h, 00h,0E0h, 2Ch,0EAh
		db	 93h,0A0h, 33h,0AAh, 9Fh, 00h
		db	 0Ch, 00h,0FEh, 00h, 32h, 00h
		db	 3Ah, 00h, 08h, 00h,0CAh, 4Bh
		db	 01h, 02h, 4Bh, 06h,0C8h, 00h
		db	0E8h, 00h, 20h, 00h,0AAh, 00h
		db	 88h, 00h,0A8h, 00h, 28h, 00h
		db	0AAh, 00h, 80h, 00h,0A0h, 4Bh
		db	 01h, 08h, 4Bh, 08h,0EAh, 00h
		db	0EAh, 00h, 28h, 00h, 28h, 4Bh
		db	 01h, 28h, 4Bh, 01h, 38h, 4Bh
		db	 01h, 0Ah, 4Bh, 01h, 0Eh, 00h
		db	 08h, 00h,0C7h, 00h, 2Ch, 00h
		db	 13h, 4Bh, 07h, 3Ch, 00h, 1Ch
		db	 00h, 38h, 00h,0F8h, 02h, 00h
		db	 01h,0F0h, 4Bh, 00h, 3Fh, 4Bh
		db	 01h,0F2h, 00h,0C8h, 00h,0E8h
		db	 00h, 20h, 00h,0E2h, 00h, 08h
		db	 00h, 68h, 00h, 20h, 00h, 6Ah
		db	 00h, 08h, 00h, 28h, 00h, 28h
		db	 00h, 7Ah, 4Bh, 01h, 30h, 4Bh
		db	 08h, 08h, 00h,0C7h, 00h, 2Ch
		db	 00h, 13h, 00h, 30h, 00h, 1Fh
		db	 00h, 08h, 00h,0FFh, 00h, 30h
		db	 00h, 3Fh, 00h, 08h, 00h,0CFh
		db	 00h, 07h, 00h, 07h, 00h, 07h
		db	 00h, 07h, 4Bh, 05h, 03h, 00h
		db	 03h, 00h,0CFh, 00h, 3Ch, 00h
		db	 37h, 00h, 33h, 00h, 3Fh, 00h
		db	 0Ch, 00h,0FEh, 00h, 32h, 00h
		db	 3Ah, 00h, 08h, 00h,0CAh, 4Bh
		db	 04h, 08h, 00h, 20h, 00h,0EAh
		db	 00h,0C8h, 00h,0E8h, 00h, 20h
		db	 00h,0AAh, 00h, 88h, 00h,0A8h
		db	 00h, 28h, 00h,0AAh, 00h, 80h
		db	 00h,0A0h, 4Bh, 0Ah, 33h, 00h
		db	 03h, 0Ch,0CFh, 00h,0CCh, 00h
		db	0F7h, 03h, 33h, 0Fh,0FFh, 00h
		db	0CCh, 03h,0FEh, 00h, 02h, 08h
		db	 8Ah, 4Bh, 08h, 30h, 00h, 30h
		db	 00h,0FCh, 80h,0CCh, 00h,0FEh
		db	 00h, 32h, 00h,0FAh, 80h, 88h
		db	 00h,0AAh, 00h, 20h, 00h,0ACh
		db	 80h, 4Bh, 0Bh, 03h, 00h, 33h
		db	 00h, 0Ch, 00h, 0Fh, 00h, 03h
		db	 00h,0CFh, 00h, 0Ch, 00h, 37h
		db	 00h, 33h, 00h,0FFh, 4Bh, 0Ch
		db	 20h, 00h,0C0h, 00h,0C0h, 4Bh
		db	 01h,0C8h, 00h,0C0h, 00h,0E0h
		db	 00h, 20h, 00h,0E8h, 4Bh, 00h
		db	 0Ch, 00h, 3Fh, 00h, 33h, 00h
		db	 3Fh, 00h, 0Ch, 00h,0CEh, 00h
		db	 02h, 00h, 3Ah, 00h, 02h, 00h
		db	 02h, 4Bh, 01h, 08h, 4Bh, 06h
		db	 80h, 00h,0A0h, 00h, 20h, 00h
		db	0A0h, 00h, 80h, 00h, 88h, 4Bh
		db	 01h, 80h, 4Bh, 01h, 20h, 4Bh
		db	 01h, 80h, 4Bh, 10h, 0Ah, 00h
		db	 6Bh, 00h,0BFh, 06h,0A3h, 01h
		db	0CFh, 01h, 31h, 03h,0E1h, 02h
		db	 01h, 07h, 8Fh, 1Ch, 0Fh, 07h
		db	 92h, 04h, 1Eh, 4Bh, 06h, 50h
		db	 00h,0D6h, 00h,0D5h, 00h,0D5h
		db	 00h,0E5h, 00h, 7Dh,0C0h,0FAh
		db	 80h,0FAh, 98h, 95h, 40h, 95h
		db	 58h, 1Ah, 20h, 1Bh,0A0h, 04h
		db	0BCh, 07h,0BCh, 07h,0DFh, 07h
		db	0DFh, 03h,0F9h, 1Bh,0FFh, 00h
		db	 7Ah, 01h,0FAh, 00h,0A5h, 00h
		db	0BDh, 00h, 0Ah, 00h,0CAh, 4Bh
		db	 01h, 03h, 4Bh, 02h, 15h, 40h
		db	 15h, 58h,0E8h,0A0h,0EEh,0A0h
		db	0D4h, 40h,0D5h,0D8h,0A2h, 80h
		db	0AEh, 80h, 15h, 00h, 75h, 00h
		db	 90h, 00h, 90h, 4Bh, 08h, 1Fh
		db	 00h, 10h, 01h,0F3h, 31h, 0Ch
		db	 0Fh,0FFh, 08h,0EFh, 1Fh,0CCh
		db	 13h,0C0h, 39h, 31h,0E7h, 10h
		db	 7Ah, 45h, 4Ah, 44h,0F4h, 03h
		db	 94h, 00h,0F4h, 00h, 94h,0C0h
		db	0F8h, 00h, 28h, 00h,0F4h, 00h
		db	0F5h, 8Ch, 02h,0B0h, 02h,0B0h
		db	 70h, 08h, 10h, 08h,0FCh,0C4h
		db	 1Bh,0C4h,0E1h,0AAh, 61h,0AAh
		db	 80h, 14h, 80h,0D4h, 26h,0A8h
		db	 26h,0A8h,0E6h, 38h, 86h, 08h
		db	0E1h,0E0h,0C1h, 20h, 75h, 86h
		db	 74h, 02h, 33h, 81h, 32h, 01h
		db	 18h, 4Eh, 19h,0C2h, 0Ch,0F0h
		db	 0Ch, 70h, 01h, 55h, 31h, 55h
		db	 00h, 0Ah, 03h, 0Ah,0F5h, 50h
		db	 95h, 53h, 6Ah, 00h, 6Ah, 00h
		db	 80h,0C6h, 80h,0C6h,0B5h, 54h
		db	0B5h, 54h, 18h,0A8h, 1Eh,0A8h
		db	0A5h, 50h,0A5h, 50h, 50h, 80h
		db	 50h, 86h,0A8h, 00h,0A8h, 60h
		db	 02h,0F6h, 02h, 16h, 0Fh, 80h
		db	 60h, 80h, 1Ah, 00h, 1Ah, 00h
		db	 40h, 07h, 40h, 07h, 20h, 18h
		db	 20h, 18h, 80h, 00h, 80h, 4Bh
		db	 01h, 60h, 00h, 48h, 40h, 48h
		db	 40h, 4Bh, 00h, 0Ch, 4Bh, 00h
		db	0D0h, 00h,0D0h, 00h, 38h, 00h
		db	 0Eh, 00h, 0Eh, 00h, 06h, 00h
		db	 06h, 00h, 06h, 00h, 04h, 00h
		db	 04h, 00h, 44h, 00h, 44h, 00h
		db	 40h, 00h, 40h,0C0h, 00h, 80h
		db	 00h,0C0h, 00h, 80h, 00h,0C0h
		db	 00h, 80h, 00h, 60h, 00h
data_6		dw	60h			; Data table (indexed access)
		db	 70h, 20h, 76h, 20h, 59h, 14h
		db	 59h, 14h, 06h, 80h, 06h, 80h
		db	 01h, 90h, 61h, 90h, 00h,0C0h
		db	 00h, 40h, 01h, 82h, 00h, 8Eh
		db	 06h, 02h, 06h, 02h, 00h, 84h
		db	 00h, 84h, 01h, 0Ch, 01h, 0Ch
		db	 06h, 14h, 06h, 14h, 30h,0B0h
		db	 30h,0B0h, 03h, 80h, 03h, 86h
		db	 4Bh, 01h, 03h, 4Bh, 01h, 3Dh
		db	 00h, 0Ch, 03h,0F1h, 00h, 30h
		db	 0Fh,0BBh, 00h,0ECh, 3Fh,0EDh
		db	 03h, 8Ch, 3Bh,0AEh, 0Eh, 0Bh
		db	 0Eh, 8Bh,0A8h, 02h,0A8h, 02h
		db	 4Bh, 00h,0FCh, 00h, 0Ch, 00h
		db	0F3h, 4Bh, 01h,0FFh, 60h, 00h
		db	 0Ch, 7Ah,0C0h, 0Fh, 00h,0AFh
		db	 62h, 2Fh,0C0h,0AFh, 2Ah,0A8h
		db	0F0h,0A8h,0F0h, 0Ah, 0Ch, 0Ah
		db	 0Ch, 4Bh, 09h, 03h, 4Bh, 01h
		db	 0Fh, 4Bh, 01h,0F6h, 00h, 30h
		db	 03h,0C6h, 4Bh, 00h, 0Fh,0F2h
		db	 4Bh, 00h, 0Fh, 6Ah, 4Bh, 08h
		db	0F0h, 00h,0C0h,0C0h, 1Eh, 4Bh
		db	 01h,0DEh, 20h, 4Bh, 00h, 8Fh
		db	0E8h, 4Bh, 00h,0AAh,0A0h,0B0h
		db	 00h,0BDh, 40h, 4Bh, 00h, 36h
		db	0ACh, 00h, 2Fh, 3Ah,0AFh, 02h
		db	0A8h, 32h,0AAh, 0Ah, 00h, 0Ah
		db	 00h, 08h, 00h, 08h, 00h, 28h
		db	 00h, 28h, 00h, 20h, 00h, 20h
		db	 00h, 80h, 00h, 80h, 00h,0AFh
		db	 00h,0AFh, 00h, 2Ah,0C0h, 2Ah
		db	0C0h, 22h, 80h,0A2h, 80h, 20h
		db	0B0h, 20h,0B0h, 08h,0A0h, 08h
		db	0A0h, 00h, 80h, 00h, 80h, 4Bh
		db	 0Dh, 3Fh, 4Bh, 00h, 03h,0DFh
		db	 03h, 00h, 0Ch,0DFh, 4Bh, 00h
		db	 37h,0DFh, 4Bh, 00h, 33h,0EAh
		db	 4Bh, 00h, 2Ah, 94h, 00h, 02h
		db	 39h, 6Ah, 4Bh, 00h,0FCh, 4Bh
		db	 01h,0EFh, 80h,0C0h,0C0h, 1Ch
		db	 30h, 4Bh, 00h,0DEh, 3Ch, 4Bh
		db	 00h,0DFh,0A8h, 4Bh, 00h,0DAh
		db	 4Bh, 01h,0A8h, 00h, 22h,0F0h
		db	0AAh,0F0h, 03h,0F0h,0EBh, 34h
		db	 0Ah,0AEh,0EAh,0AEh, 0Ch, 00h
		db	 0Ch, 00h, 2Ch, 00h, 2Ch, 00h
		db	 28h, 00h, 28h, 00h,0A0h, 00h
		db	0A0h, 00h, 20h, 00h, 20h, 4Bh
		db	 03h,0AEh,0ACh,0AEh,0A0h, 0Bh
		db	0EBh, 0Bh,0EBh, 02h, 0Bh, 02h
		db	 0Bh, 00h, 83h, 00h, 83h, 4Bh
		db	 15h, 03h, 4Bh, 01h,0FBh, 00h
		db	0C0h, 03h, 37h, 00h,0C0h, 0Eh
		db	0F7h, 02h,0E0h, 3Ah,0F3h, 02h
		db	0A0h, 3Ah,0AAh, 02h, 2Ch,0DAh
		db	0ADh, 00h, 03h, 00h, 03h, 00h
		db	 0Fh,0FBh, 0Fh, 30h, 0Ch,0CEh
		db	0ECh, 00h,0B8h,0FCh,0BCh, 02h
		db	0E0h,0F2h,0EFh, 02h,0A0h,0F2h
		db	0AAh, 0Bh, 80h,0CBh, 80h, 2Ah
		db	0C0h, 6Ah, 00h, 08h, 0Ah,0E9h
		db	 4Ah, 08h, 00h, 0Ah, 80h, 20h
		db	 00h, 20h, 4Bh, 13h, 0Ah, 80h
		db	 0Ah, 80h, 02h,0B0h, 02h,0B0h
		db	 00h, 2Ch, 00h, 2Ch, 00h, 0Bh
		db	 00h, 0Bh, 00h, 02h, 00h, 02h
		db	 4Bh, 1Dh, 03h, 30h, 00h, 30h
		db	 3Dh, 0Ah,0FCh, 0Ah,0F1h, 00h
		db	0ACh, 03h,0ACh, 4Bh, 0Ch,0FCh
		db	 00h, 30h, 30h,0C7h, 80h, 4Bh
		db	 00h,0FBh,0CCh, 4Bh, 00h,0FBh
		db	0FFh, 00h,0FFh,0FAh,0FFh, 00h
		db	 08h, 03h,0CAh, 00h, 0Ah, 0Fh
		db	0AAh, 00h, 0Ah, 0Fh,0AAh, 00h
		db	 02h, 0Dh, 52h, 00h, 0Ah, 00h
		db	 0Ah, 4Bh, 0Ah, 03h,0A0h,0B3h
		db	0A0h, 0Ah,0C0h, 5Ah,0C0h, 0Bh
		db	0AFh, 2Bh,0AFh, 8Ah, 80h,0AAh
		db	 80h, 4Bh, 11h, 3Fh, 00h, 30h
		db	 00h,0CFh, 4Bh, 00h, 06h,0FFh
		db	 30h, 00h, 07h, 5Eh, 00h,0F0h
		db	 4Eh,0F5h, 03h,0F4h, 54h,0F5h
		db	 0Fh, 15h, 0Fh, 15h, 30h, 50h
		db	 30h, 50h, 4Bh, 00h,0C0h, 4Bh
		db	 01h,0BCh, 00h, 30h, 00h, 8Fh
		db	0C0h, 0Ch, 00h,0DDh,0F0h, 37h
		db	 00h,0B7h,0FCh, 31h,0C0h, 75h
		db	0DCh,0D0h, 70h,0D1h, 70h, 40h
		db	 15h, 40h, 15h, 4Bh, 09h, 0Fh
		db	0B1h, 00h, 00h, 78h, 4Bh, 00h
		db	 04h, 7Bh, 4Bh, 00h, 17h,0F5h
		db	 4Bh, 00h, 05h, 55h, 00h, 0Dh
		db	 02h,0BDh, 4Bh, 08h,0C0h, 4Bh
		db	 01h,0F0h, 4Bh, 01h, 6Fh, 00h
		db	 0Ch, 00h, 63h,0C0h, 4Bh, 00h
		db	 4Fh,0F0h, 4Bh, 00h, 56h,0F0h
		db	 00h,0F5h, 00h,0F5h, 03h, 54h
		db	 03h, 54h, 01h, 44h, 01h, 45h
		db	 0Dh, 04h, 0Dh, 04h, 05h, 10h
		db	 05h, 10h, 01h, 00h, 01h, 4Bh
		db	 09h,0B5h, 6Ch,0F4h, 00h,0F5h
		db	 5Ch, 15h, 40h, 55h, 4Ch, 00h
		db	 50h, 00h, 50h, 00h, 10h, 00h
		db	 10h, 00h, 14h, 00h, 14h, 00h
		db	 04h, 00h, 04h, 00h, 01h, 00h
		db	 01h, 4Bh, 01h, 3Fh, 4Bh, 00h
		db	 01h,0D7h,0B1h, 00h, 0Ch, 78h
		db	 4Bh, 00h, 3Ch,0FBh, 4Bh, 00h
		db	 15h,0FBh, 4Bh, 01h, 5Bh, 4Bh
		db	 01h, 15h, 0Fh, 44h, 0Fh, 55h
		db	 4Bh, 04h,0FCh, 4Bh, 01h,0FBh
		db	0C0h, 00h,0C0h,0FBh, 30h, 4Bh
		db	 00h,0FBh,0ECh, 4Bh, 00h, 57h
		db	0CCh, 4Bh, 00h, 29h, 54h, 40h
		db	 00h, 56h, 9Ch, 35h, 75h, 05h
		db	 75h,0D7h,0D0h,0D7h,0D0h,0D0h
		db	 40h,0D0h, 40h,0C1h, 00h,0C1h
		db	 4Bh, 0Fh, 0Fh,0C0h, 4Ch,0D7h
		db	 75h, 50h, 75h, 57h, 00h, 30h
		db	 00h, 30h, 00h, 34h, 00h, 34h
		db	 00h, 14h, 00h, 14h, 00h, 05h
		db	 00h, 05h, 00h, 04h, 00h, 04h
		db	 4Bh, 02h,0C0h, 00h
data_7		dw	0C0h			; Data table (indexed access)
		db	0F0h, 00h,0F0h,0DFh, 30h, 0Ch
		db	 37h, 73h, 1Dh, 00h, 3Dh, 7Fh
		db	 07h, 40h,0F7h, 5Fh, 05h, 40h
		db	 55h, 4Fh, 01h,0D0h, 01h,0D3h
		db	 03h, 54h, 00h, 56h, 4Bh, 04h
		db	0C0h, 4Bh, 01h,0DFh, 00h, 03h
		db	 00h,0ECh,0C0h, 03h, 00h,0EFh
		db	 70h, 07h, 40h,0D7h, 5Ch, 05h
		db	 40h, 55h, 5Ch, 34h, 40h,0B5h
		db	 5Bh, 01h, 50h, 01h, 53h, 0Dh
		db	 40h, 0Dh, 40h, 34h, 00h, 34h
		db	 00h,0D0h, 00h,0D0h, 00h, 40h
		db	 00h
data_8		db	40h			; Data table (indexed access)
		db	 4Bh, 0Bh, 50h, 10h, 52h, 97h
		db	 00h, 10h, 01h, 50h, 00h, 04h
		db	 00h, 04h, 4Bh, 21h, 3Fh, 0Ch
		db	 0Ch, 01h,0E3h, 4Bh, 00h, 30h
		db	0DFh, 4Bh, 00h,0FFh,0DFh,0FFh
		db	 00h,0FFh, 5Fh, 4Bh, 10h,0C0h
		db	 4Bh, 00h, 0Ch,0BCh, 0Ch, 3Fh
		db	 50h, 8Fh, 50h, 35h, 00h,0B5h
		db	0C0h, 05h,0C0h, 05h,0EDh, 03h
		db	 50h, 03h, 5Ah,0F5h,0D0h,0F5h
		db	0D5h, 01h, 51h, 01h, 55h, 4Bh
		db	 0Eh, 10h, 00h, 53h,0C0h, 50h
		db	 00h,0D5h,0F0h, 50h, 00h, 55h
		db	0F0h, 40h, 00h, 4Ah,0B0h, 50h
		db	 00h, 50h, 4Bh, 0Bh

locloop_1:
		add	[bx+si],ax
		add	data_9,cx
		add	[bx+di],dl
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		mov	cl,0
		aaa				; Ascii adjust
		sbb	ax,560h
		test	di,[bx+si]
		or	[bx+di],cl
		cli				; Disable interrupts
		xor	[si+30h],ch
		pushf				; Push flags
		xor	bh,ds:data_17e[si]
;*		xor	si,si			; Zero register
		db	 31h,0F6h		;  Fixup - byte match
loc_2:
;*		xor	di,di			; Zero register
		db	 31h,0FFh		;  Fixup - byte match
		add	al,0
		add	al,0
;*		or	al,al			; Zero ?
		db	 08h,0C0h		;  Fixup - byte match
;*		or	al,al			; Zero ?
		db	 08h,0C0h		;  Fixup - byte match
		push	bp
		mov	ax,3854h
		and	bx,word ptr ds:[1EA0h]
		aaa				; Ascii adjust
		pop	es
		db	0F1h, 07h, 1Ch, 03h, 9Ch, 03h
		db	 5Ah,0A3h, 5Ah,0A3h, 1Dh
loc_3:
		add	bh,ch
		add	ah,[di]
		mov	ah,25h			; '%'
		iret				; Interrupt return
			                        ;* No entry point to code
		xor	al,60h			; '`'
		aaa				; Ascii adjust
;*		call	far ptr sub_1		;*
		db	9Ah
		dw	344h, 5745h		;  Fixup - byte match
		push	es
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	ch,ds:data_12e[bx]
		add	bl,[bp+di+7Eh]
		or	al,1Eh
;*		xor	dh,al
		db	 30h,0C6h		;  Fixup - byte match
		add	[bp+10h],al
		or	al,0
		or	al,3
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		inc	ax
		pop	di
		inc	ax
		pop	es
		jo	loc_2			; Jump if overflow=1
		jo	loc_3			; Jump if overflow=1
		inc	ax
;*		aam	40h			; '@' undocumented inst
		db	0D4h, 40h		;  Fixup - byte match
		lodsw				; String [si] to ax
		sub	byte ptr ds:[4Bh][si],0FCh
		loopnz	locloop_1		; Loop if zf=0, cx>0

		db	 60h, 73h, 88h, 13h, 00h, 30h
		db	 88h, 30h, 00h, 08h,0E0h, 08h
		db	 1Dh, 01h, 03h, 01h, 70h, 40h
		db	 1Fh, 40h,0C0h, 21h, 5Eh,0A1h
		db	 80h, 03h, 05h, 43h, 80h, 15h
		db	 80h, 15h, 94h, 2Bh, 94h, 2Bh
		db	 83h, 1Eh, 83h, 1Fh, 08h, 4Fh
		db	 0Bh,0EFh, 01h,0C0h, 4Bh, 00h
		db	 03h,0F0h, 00h, 70h, 96h, 1Ch
		db	 90h, 0Ch, 04h, 87h, 04h, 83h
		db	 82h, 23h,0AAh, 23h, 82h,0C1h
		db	0DFh,0C1h, 90h, 28h,0FAh,0A8h
		db	0C0h, 00h,0E9h, 00h,0A0h, 7Fh
		db	0AEh,0FFh, 00h, 4Fh, 1Ah, 5Fh
		db	 10h, 5Fh, 1Dh,0DFh, 61h, 9Bh
		db	 67h, 9Bh, 74h, 60h, 34h, 60h
		db	0F8h, 00h, 18h, 0Ah, 66h, 00h
		db	 06h, 54h, 6Ch, 00h, 6Ch, 15h
		db	0F8h, 00h,0FCh, 00h,0FFh,0A6h
		db	0FFh,0A6h,0FDh, 00h,0FDh, 00h
		db	0D0h, 24h,0D0h, 24h,0A0h, 00h
		db	0A0h, 00h, 30h,0F9h, 30h, 19h
		db	 13h, 07h, 90h, 01h, 10h, 7Eh
		db	 10h, 62h, 00h, 42h, 18h, 42h
		db	 11h, 20h, 55h, 20h, 08h, 68h
		db	 28h, 68h, 05h,0A2h, 05h,0A2h
		db	 4Ah,0B4h, 4Ah,0B4h, 05h,0C0h
		db	 05h,0C0h, 9Dh, 80h, 9Dh, 80h
		db	 0Dh, 00h, 0Dh, 00h, 20h, 00h
		db	 20h, 00h, 02h, 08h, 02h, 08h
		db	 56h, 40h, 56h, 40h,0E5h, 02h
		db	0E5h, 02h,0A5h, 00h,0A5h, 0Ah
		db	 06h, 40h, 06h, 56h, 12h, 71h
		db	 12h, 77h, 03h, 58h, 03h, 5Ah
		db	 49h, 80h, 5Dh, 80h, 16h, 80h
		db	 3Eh, 80h, 09h, 00h, 19h, 00h
		db	 04h,0C0h, 04h,0C0h, 12h, 69h
		db	 12h, 69h, 44h,0B6h, 46h,0B6h
		db	 02h, 09h, 2Fh,0C9h, 08h, 80h
		db	 0Bh, 80h, 01h,0AAh, 01h,0AAh
		db	 0Ah,0D8h, 0Ah,0D8h, 05h, 41h
		db	 05h, 41h, 45h,0A0h, 45h,0A0h
		db	 35h, 48h, 35h, 48h, 52h,0C0h
		db	 52h,0C0h, 95h, 20h, 95h, 20h
		db	 81h, 00h, 81h, 4Bh, 12h, 03h
		db	 4Bh, 01h, 0Fh, 4Bh, 00h, 08h
		db	0AEh, 4Bh, 00h, 2Ah,0EAh, 4Bh
		db	 10h,0CCh, 4Bh, 01h,0AAh, 30h
		db	 4Bh, 00h,0EAh, 4Bh, 01h,0BAh
		db	0AAh, 4Bh, 14h, 03h,0B0h, 4Bh
		db	 00h, 0Bh,0AEh, 4Bh, 00h, 2Ah
		db	0EAh, 4Bh, 10h, 0Fh,0C0h, 4Bh
		db	 00h, 3Bh,0B0h, 4Bh, 00h,0AEh
		db	0ACh, 4Bh, 00h,0AAh,0AAh, 4Bh
		db	 09h, 03h, 4Bh, 01h,0CFh, 4Bh
		db	 00h, 30h, 3Eh, 4Bh, 00h, 03h
		db	0BBh, 4Bh, 00h, 0Bh,0AAh, 4Bh
		db	 00h, 2Ah,0EAh, 4Bh, 09h,0C0h
		db	 4Bh, 00h,0B0h, 0Ch, 4Bh, 00h
		db	0ABh,0C0h, 4Bh, 00h,0ABh,0B0h
		db	 4Bh, 00h,0AEh,0ACh, 4Bh, 00h
		db	0AAh,0AAh, 4Bh, 03h, 03h, 00h
		db	 23h, 00h, 0Fh, 00h, 0Fh, 4Bh
		db	 01h, 0Ah, 4Bh, 00h, 08h, 3Eh
		db	 4Bh, 00h, 03h,0BBh, 4Bh, 00h
		db	 8Bh,0AAh, 4Bh, 00h, 2Ah,0EAh
		db	 4Bh, 00h, 28h, 00h, 80h, 00h
		db	 8Ah, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h, 00h,0A0h, 08h, 4Bh, 00h
		db	0ABh,0C0h, 4Bh, 00h,0ABh,0B2h
		db	 4Bh, 00h,0AEh,0ACh, 4Bh, 00h
		db	0AAh,0AAh, 4Bh, 13h, 38h, 00h
		db	 38h, 00h,0FAh, 00h,0DAh, 00h
		db	0BEh, 00h,0B6h, 4Bh, 1Ah, 80h
		db	 00h, 80h, 4Bh, 00h, 2Ch, 00h
		db	 2Ch, 00h, 03h, 00h, 21h, 00h
		db	 0Bh, 00h, 0Bh, 4Bh, 01h, 0Ah
		db	 4Bh, 00h, 08h, 3Eh, 4Bh, 00h
		db	 03h,0BBh, 4Bh, 00h, 8Bh,0AAh
		db	 4Bh, 00h, 2Ah,0EAh, 4Bh, 02h
		db	0A0h, 00h,0A2h, 00h,0A0h, 00h
		db	0A2h, 80h,0A0h, 00h,0A0h, 28h
		db	 4Bh, 00h,0ABh,0C0h, 4Bh, 00h
		db	0ABh,0B2h, 4Bh, 00h,0AEh,0ACh
		db	 4Bh, 00h,0AAh,0AAh, 0Fh,0A8h
		db	 0Fh,0A8h, 3Fh,0EAh, 3Fh,0EAh
		db	 2Fh,0FCh, 2Fh,0DCh, 0Ah,0B0h
		db	 0Ah,0B0h, 00h, 03h, 00h, 03h
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 09h, 4Bh, 0Ah, 80h, 00h
		db	 80h, 00h, 80h, 00h, 80h, 00h
		db	0A0h, 00h,0A0h, 00h,0E0h, 00h
		db	0E0h, 4Bh, 03h,0A0h, 00h,0A0h
		db	 4Bh, 00h, 0Bh, 00h, 0Bh, 00h
		db	 0Bh, 00h, 0Bh, 4Bh, 03h, 0Fh
		db	 00h, 0Dh, 00h, 02h, 00h, 3Eh
		db	 00h, 02h, 03h,0BAh, 4Bh, 00h
		db	 0Bh,0AAh, 4Bh, 00h, 2Ah,0EAh
		db	0A0h, 00h,0A0h, 00h,0E0h, 00h
		db	0E0h, 4Bh, 03h,0E0h, 00h,0E0h
		db	 00h, 80h, 00h,0ABh,0C0h, 4Bh
		db	 00h,0ABh,0B0h, 4Bh, 00h,0AEh
		db	0ACh, 4Bh, 00h,0AAh,0AAh, 0Fh
		db	0A8h, 0Fh,0A8h, 3Fh,0EAh, 3Fh
		db	0EAh, 00h, 3Ch, 00h, 1Ch, 00h
		db	 30h, 00h, 30h, 00h,0C3h, 00h
		db	0C3h, 0Fh,0ABh, 07h,0A9h, 00h
		db	 0Bh, 00h, 09h, 4Bh, 0Fh, 03h
		db	 00h, 03h, 00h, 0Fh, 00h, 0Fh
		db	 00h, 0Bh, 00h, 09h, 4Bh, 03h
		db	 0Bh, 00h, 0Bh, 0Fh,0A0h, 0Fh
		db	0A0h,0FFh,0F8h,0F5h,0F8h, 3Eh
		db	0E8h, 1Eh,0E8h, 0Ah,0A0h, 0Ah
		db	0A0h, 80h, 00h, 80h, 00h,0E0h
		db	 00h,0E0h, 00h,0E0h, 00h,0E0h
		db	 4Bh, 03h, 0Fh,0A0h, 0Fh,0A0h
		db	0FFh,0F8h,0F5h,0F8h, 3Ch, 00h
		db	 1Ch, 00h, 08h, 00h, 08h, 00h
		db	 82h, 00h, 82h, 00h,0E2h,0A0h
		db	0E2h,0A0h,0E0h, 00h,0E0h, 4Bh
		db	 03h, 01h, 95h, 4Bh, 00h, 07h
		db	0B8h, 00h, 47h, 0Fh, 30h, 00h
		db	 8Ah, 0Fh,0B0h, 00h, 45h, 0Dh
		db	 30h, 02h, 8Bh, 06h,0D0h, 00h
		db	 25h, 01h,0A8h
data_9		dw	1300h
		db	 00h, 54h, 00h, 2Ah, 50h, 80h
		db	 4Bh, 01h, 20h,0FCh, 4Bh, 00h
		db	 10h,0AAh, 80h, 4Bh, 00h, 55h
		db	 4Bh, 00h, 10h,0FEh, 80h, 00h
		db	 20h,0FFh, 4Bh, 00h, 80h,0FCh
		db	 00h, 02h, 00h,0A8h, 4Bh, 00h
		db	 08h, 00h, 08h, 00h, 18h, 00h
		db	 19h, 00h, 38h, 00h

locloop_4:
		cmp	[bx+si],al
		cmp	al,0
		db	 3Eh, 4Bh, 03h, 18h, 00h, 59h
		db	 00h, 18h, 00h, 19h, 4Bh, 00h
		db	0D2h, 00h, 20h, 00h, 20h, 00h
		db	 30h, 00h, 30h, 00h, 38h, 00h
		db	0B8h, 00h, 38h, 00h, 38h, 00h
		db	 28h, 00h,0A8h, 00h, 68h, 00h
		db	0E8h, 00h, 08h, 00h, 09h, 00h
		db	 20h, 00h,0A0h, 4Bh, 00h, 0Ah
		db	 00h, 1Bh, 00h, 0Ah, 00h, 1Ah
		db	 4Bh, 01h, 01h, 00h, 0Eh, 00h
		db	 0Dh, 00h, 02h, 00h, 3Eh, 00h
		db	 02h, 03h,0BAh, 4Bh, 00h, 0Bh
		db	0AAh, 4Bh, 00h, 2Ah,0EAh, 20h
		db	 00h,0A4h, 00h, 60h, 00h,0E0h
		db	 4Bh, 01h, 80h, 00h, 60h, 00h
		db	 60h, 00h, 80h, 00h,0ABh,0C0h
		db	 4Bh, 00h,0ABh,0B0h, 4Bh, 00h
		db	0AEh,0ACh, 4Bh, 00h,0AAh,0AAh
		db	 4Bh, 05h, 04h, 4Bh, 00h, 20h
		db	 09h, 4Bh, 00h, 08h, 0Ch, 4Bh
		db	 00h, 01h, 1Ah, 4Bh, 00h, 02h
		db	0DCh, 3Ch, 00h, 3Dh, 6Dh, 0Eh
		db	 00h, 2Eh, 7Dh, 4Bh, 04h, 08h
		db	 4Bh, 02h, 04h, 01h, 00h, 91h
		db	 10h, 03h, 80h, 13h, 80h, 07h
		db	 80h, 97h,0E8h, 02h, 00h,0A3h
		db	0B0h, 18h, 00h, 7Dh, 40h, 00h
		db	0E0h, 06h,0FFh, 00h, 60h, 0Ah
		db	 6Fh, 68h, 24h, 69h,0EFh, 06h
		db	 92h, 06h,0BFh, 00h, 6Ah, 00h
		db	 6Dh, 00h, 02h, 00h, 3Eh, 00h
		db	 02h, 03h,0BAh, 4Bh, 00h, 0Bh
		db	0AAh, 24h, 04h,0BFh, 44h, 08h
		db	0E0h, 8Fh,0E0h, 73h, 00h,0F7h
		db	0C0h, 04h, 00h, 85h, 00h, 68h
		db	 00h,0EAh, 00h, 80h, 00h,0ABh
		db	0C0h, 4Bh, 00h,0ABh,0B0h, 4Bh
		db	 00h,0AEh,0ACh, 4Bh, 01h, 80h
		db	 4Bh, 00h, 24h, 04h, 4Bh, 00h
		db	 40h, 88h, 4Bh, 00h, 0Ch, 35h
		db	 4Bh, 00h, 28h, 86h, 4Bh, 00h
		db	 84h, 2Ah, 4Bh, 00h, 10h, 8Ah
		db	 4Bh, 00h, 02h, 10h, 4Bh, 01h
		db	 80h, 4Bh, 00h, 80h, 4Bh, 01h
		db	 14h, 50h, 4Bh, 00h, 22h, 80h
		db	 4Bh, 00h,0D4h, 08h, 4Bh, 00h
		db	 71h, 41h, 4Bh, 00h, 0Dh, 08h
		db	 4Bh, 00h, 02h, 81h, 4Bh, 00h
		db	 08h, 10h, 4Bh, 01h, 80h, 4Bh
		db	 01h, 04h, 4Bh, 00h, 02h, 04h
		db	 4Bh, 02h, 26h, 00h, 26h, 00h
		db	 94h, 80h, 94h,0BCh, 00h, 18h
		db	 03h,0B8h, 4Bh, 00h, 02h, 4Bh
		db	 01h, 04h, 20h, 4Bh, 0Bh, 18h
		db	 00h, 18h, 03h, 00h, 2Bh,0C0h
		db	 00h, 2Ah,0ABh,0BAh, 00h, 80h
		db	 00h, 80h, 01h, 80h, 41h, 80h
		db	 41h, 00h, 60h, 80h, 20h, 00h
		db	 31h, 83h, 18h, 05h, 00h, 8Fh
		db	 00h, 4Fh, 06h, 18h, 01h,0BFh
		db	 00h, 13h, 00h, 2Fh, 00h, 0Ch
		db	 01h, 00h, 01h, 00h, 01h, 80h
		db	 01h, 82h, 00h, 82h, 01h, 06h
		db	0C0h, 04h,0C1h, 8Ch,0F0h, 10h
		db	0F1h, 08h,0FAh, 00h, 18h, 60h
		db	0FDh, 80h,0C8h, 00h,0FEh, 00h
		db	0B8h, 4Bh, 00h,0D4h, 00h, 07h
		db	 02h,0A2h, 01h, 05h, 00h, 41h
		db	 06h, 4Bh, 01h, 0Ch, 42h, 10h
		db	 00h, 08h, 46h, 10h, 40h, 10h
		db	 22h, 10h, 20h, 10h, 20h, 00h
		db	 10h, 00h, 10h,0CBh, 00h, 30h
		db	 00h,0A5h,0C0h, 40h, 00h, 02h
		db	 60h, 80h, 00h, 02h, 00h, 40h
		db	 30h, 4Bh, 00h, 62h, 18h, 00h
		db	 08h, 46h, 18h, 04h, 08h, 04h
		db	0C5h, 00h, 00h, 08h, 4Bh, 18h
		db	 30h, 4Bh, 01h, 10h, 00h, 20h
		db	 4Bh, 12h, 10h, 4Bh, 01h, 30h
		db	 4Bh, 01h, 60h, 00h, 01h, 80h
		db	 00h, 20h, 01h,0D0h, 00h, 14h
		db	 07h, 08h, 00h, 22h, 1Ch, 04h
		db	 4Bh, 00h, 30h, 02h, 03h, 7Ch
		db	 64h, 01h, 00h,0CAh, 40h, 34h
		db	 82h,0AAh, 84h, 00h, 80h, 00h
		db	 80h, 00h, 50h, 00h, 02h,0E0h
		db	 20h, 00h, 04h, 38h,0A0h, 00h
		db	 08h, 0Ch, 02h, 00h, 56h, 06h
		db	 07h, 40h, 27h,0C3h, 0Fh,0F0h
		db	 83h,0F1h,0D5h, 41h, 11h, 41h
		db	 20h, 01h, 20h, 01h, 4Bh, 17h
		db	 20h, 4Bh, 01h,0D0h, 00h, 08h
		db	 4Bh, 14h, 06h, 4Bh, 01h, 05h
		db	 80h, 04h, 00h, 08h,0E0h, 00h
		db	 80h, 00h, 1Ch, 01h, 80h, 00h
		db	 36h, 00h, 04h, 00h, 63h, 01h
		db	 4Bh, 00h, 43h, 02h, 3Fh, 04h
		db	 80h, 02h, 0Bh, 02h,0B4h, 03h
		db	0AAh, 05h, 00h, 01h, 00h, 01h
		db	 00h, 01h, 80h, 08h, 30h, 00h
		db	0C0h, 10h, 10h, 20h, 40h, 10h
		db	 10h, 0Ah, 40h, 2Eh, 10h,0CFh
		db	 40h, 27h,0D0h,0FFh,0F8h, 13h
		db	0F8h, 55h, 48h, 51h, 48h, 00h
		db	 40h, 00h, 40h, 4Bh, 1Bh, 20h
		db	 00h, 04h, 4Bh, 10h, 04h, 4Bh
		db	 01h, 06h, 4Bh, 01h, 0Eh, 00h
		db	 01h, 00h, 0Eh, 00h, 01h, 90h
		db	 00h, 0Eh, 06h, 4Bh, 00h, 0Eh
		db	 18h, 4Bh, 00h, 06h, 20h, 01h
		db	 00h, 06h, 03h, 7Dh, 04h, 02h
		db	 40h,0C9h, 00h, 36h, 82h,0ABh
		db	 84h, 01h, 80h, 04h, 80h, 04h
		db	 00h, 60h, 1Ah, 00h, 04h, 30h
		db	 1Ah, 00h, 08h, 0Ch, 32h, 00h
		db	 88h, 06h,0EEh, 00h, 7Ch, 41h
		db	0C6h,0C0h,0FFh,0F0h, 33h,0F0h
		db	 56h, 41h, 52h, 41h, 00h, 01h
		db	 00h, 01h, 4Bh, 19h, 30h, 00h
		db	 04h, 00h, 38h, 4Bh, 12h, 04h
		db	 00h, 10h, 00h, 07h, 00h, 30h
		db	 00h, 01h,0C0h, 70h, 4Bh, 02h
		db	 3Ch, 00h, 40h, 00h, 36h, 00h
		db	 40h, 00h, 32h, 00h, 01h, 00h
		db	 10h, 03h, 8Fh, 04h, 10h, 00h
		db	 5Bh, 00h, 34h, 03h, 72h, 05h
		db	 10h, 01h, 00h, 01h, 00h, 08h
		db	 70h, 60h, 4Bh, 00h, 38h,0D0h
		db	 00h, 80h, 18h, 20h, 00h, 0Ah
		db	 10h, 6Eh, 00h, 7Fh, 50h, 87h
		db	0C0h, 3Fh,0F0h,0B3h,0F0h, 95h
		db	 40h, 91h, 40h, 10h, 00h, 10h
		db	 4Bh, 1Ah, 20h, 00h, 04h, 00h
		db	 70h, 4Bh, 0Eh, 06h, 4Bh, 01h
		db	 06h, 4Bh, 01h, 08h, 00h, 02h
		db	 4Bh, 01h, 07h, 4Bh, 02h, 78h
		db	 4Bh, 01h,0CCh, 4Bh, 01h, 84h
		db	 4Bh, 00h, 01h, 82h, 00h, 3Ch
		db	 05h, 01h, 02h,0CBh, 02h, 34h
		db	 02h,0AAh, 06h, 4Bh, 03h, 10h
		db	 00h, 0Dh, 80h, 4Bh, 00h, 19h
		db	0C0h, 02h, 00h, 30h,0C0h, 0Ah
		db	 00h, 6Eh,0C0h, 7Fh, 00h, 07h
		db	40h
loc_5:
		aas				; Ascii adjust
		adc	ss:data_11e[bp+di],dh
		inc	ax
		push	cx
		inc	ax
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		;  Fixup - byte match
		db	 40h, 4Bh, 13h, 08h, 4Bh, 01h
		db	 0Ch, 4Bh, 01h, 06h, 01h, 80h
		db	 4Bh, 16h, 0Ch, 4Bh, 01h, 08h
		db	 00h, 04h, 4Bh, 00h, 0Ah, 07h
		db	 40h, 00h, 04h, 1Ch, 20h, 00h
		db	 05h, 30h, 10h, 00h, 40h, 60h
		db	 6Ah, 02h,0E0h,0C3h,0E4h, 0Fh
		db	0F0h, 8Fh,0C1h, 82h,0ABh, 82h
		db	 88h, 80h, 04h, 80h, 04h, 04h
		db	 00h, 0Bh, 80h, 28h, 00h, 10h
		db	0E0h, 44h, 00h, 20h, 38h, 4Bh
		db	 00h, 40h, 0Ch, 3Eh,0C0h, 80h
		db	 26h, 53h, 00h, 2Ch, 02h, 55h
		db	 41h, 00h, 21h, 00h, 01h, 00h
		db	 01h, 4Bh, 15h, 60h, 4Bh, 00h
		db	 01h,0A0h, 00h, 20h, 07h, 10h
		db	 4Bh, 16h, 04h, 4Bh, 01h, 0Bh
		db	 00h, 10h, 00h, 01h, 80h, 0Ch
		db	 10h, 03h, 00h,0C5h, 00h, 02h
		db	 04h,0C5h, 00h, 02h, 50h, 08h
		db	 74h, 02h,0F3h, 0Bh,0E4h, 1Fh
		db	0FFh, 1Fh,0C8h, 12h,0AAh, 12h
		db	 8Ah, 02h, 00h, 02h, 00h, 01h
		db	 00h, 38h, 00h, 01h, 80h, 6Ch
		db	 00h, 20h, 00h,0C6h, 4Bh, 00h
		db	 80h,0C2h, 00h,0FCh, 40h, 01h
		db	 20h,0D0h, 40h, 2Dh, 40h, 55h
		db	0C0h, 00h,0A0h, 00h, 80h, 00h
		db	 80h, 4Bh, 11h, 20h, 4Bh, 01h
		db	 60h, 4Bh, 01h, 70h, 00h, 80h
		db	 00h, 70h, 4Bh, 1Ah, 04h, 00h
		db	 20h, 00h, 06h, 4Bh, 00h, 58h
		db	 0Ch, 20h, 00h, 58h, 30h, 10h
		db	 00h, 4Ch, 60h, 11h, 00h, 77h
		db	 82h, 3Eh, 03h, 63h, 0Fh,0FFh
		db	 0Fh,0CCh, 82h, 6Ah, 82h, 4Ah
		db	 80h, 00h, 80h, 00h, 09h, 80h
		db	 70h, 4Bh, 00h, 60h, 70h, 4Bh
		db	 00h, 18h, 60h, 00h, 80h, 04h
		db	 60h, 00h,0BEh,0C0h, 40h, 20h
		db	 93h, 02h, 6Ch, 00h,0D5h, 41h
		db	 80h, 21h, 20h, 01h, 20h, 01h
		db	 4Bh, 13h, 20h, 00h, 08h, 00h
		db	0E0h, 00h, 0Ch, 03h, 80h, 00h
		db	 0Eh, 4Bh, 18h, 0Ch, 00h, 20h
		db	 00h, 1Ch, 00h, 0Eh, 10h, 00h
		db	 06h, 1Ch, 4Bh, 00h, 0Bh, 18h
		db	 4Bh, 00h, 05h, 08h, 50h, 00h
		db	 76h, 0Ah,0FEh, 03h,0E1h, 0Fh
		db	0FCh, 0Fh,0CDh, 02h,0A9h, 02h
		db	 89h, 00h, 08h, 00h, 08h, 4Bh
		db	 00h, 3Ch, 00h, 02h, 00h, 6Ch
		db	 00h, 02h, 00h, 4Ch, 00h, 80h
		db	 00h, 08h, 00h,0F1h,0C0h, 08h
		db	 20h,0DAh, 00h, 2Ch, 00h, 4Eh
		db	0C0h, 08h,0A0h, 00h, 80h, 00h
		db	 80h, 4Bh, 0Fh, 60h, 4Bh, 01h
		db	 60h, 4Bh, 01h, 10h, 00h, 40h
		db	 4Bh, 01h,0E0h, 4Bh, 18h, 04h
		db	 00h, 20h, 00h, 0Eh, 4Bh, 00h
		db	 08h, 01h,0B0h, 4Bh, 00h, 03h
		db	 98h, 00h, 40h, 03h, 0Ch, 00h
		db	 50h, 03h, 76h, 00h,0FEh, 02h
		db	0E0h, 08h,0FCh, 0Ah,0CDh, 02h
		db	0AAh, 02h, 8Ah, 02h, 00h, 02h
		db	 4Bh, 01h, 1Eh, 4Bh, 01h, 33h
		db	 4Bh, 01h, 21h, 4Bh, 01h, 41h
		db	 80h, 3Ch, 00h, 80h,0A0h,0D3h
		db	 40h, 2Ch, 40h, 55h, 40h, 00h
		db	 60h, 4Bh, 15h, 20h, 00h, 01h
		db	 10h, 60h, 04h, 00h, 30h,0C0h
		db	 00h, 08h, 61h, 80h, 4Bh, 0Dh
		db	 08h, 4Bh, 00h, 02h, 04h, 4Bh
		db	 00h, 03h, 06h, 08h, 00h, 01h
		db	 83h, 4Bh, 00h, 60h, 81h, 00h
		db	 42h,0C9h, 4Bh, 00h, 11h, 51h
		db	 80h, 01h, 07h, 61h, 80h, 02h
		db	0A7h, 9Bh,0E0h, 01h,0BAh,0CBh
		db	0E0h, 01h,0C8h, 63h,0F0h, 03h
		db	0F7h, 1Bh, 07h, 00h,0EAh, 00h
		db	 0Ah, 10h, 00h, 09h, 81h, 40h
		db	 00h, 07h, 03h, 80h, 00h, 1Ah
		db	 07h, 4Bh, 00h, 66h, 0Ch, 01h
		db	 00h, 86h, 30h, 90h, 00h, 60h
		db	0D0h, 6Ah, 00h, 02h, 00h, 50h
		db	 4Bh, 02h, 21h, 4Bh, 00h, 10h
		db	 94h, 4Bh, 00h, 04h, 2Ch, 4Bh
		db	 00h, 40h, 22h, 4Bh, 00h, 91h
		db	 0Bh, 4Bh, 00h, 20h, 25h, 4Bh
		db	 00h, 10h, 81h, 06h, 3Ch, 00h
		db	 13h, 18h,0C0h, 40h, 4Bh, 01h
		db	 10h, 84h, 4Bh, 00h, 82h, 4Bh
		db	 01h,0A0h, 44h, 4Bh, 00h, 84h
		db	 4Bh, 01h, 55h, 10h, 4Bh, 00h
		db	 80h, 00h, 3Ch,0F0h, 70h, 00h
		db	 06h, 18h, 01h, 28h, 34h, 81h
		db	 00h, 52h, 29h, 80h
loc_6:
		add	[bx],dl
		xor	ds:data_16e[bx+si],dl
		pop	cx
		clc				; Clear carry flag
		add	ds:data_18e[si],di
;*		add	dl,cl
		db	 00h,0CAh		;  Fixup - byte match
		jc	loc_6			; Jump if carry Set
		add	[bx+18h],dh
		pop	es
		add	[bp+si],ch
		add	[bp+si],cl
		adc	[bx+si],al
		retn
		db	 0Ch, 80h, 00h, 3Dh, 06h, 80h
		db	 00h, 1Ah, 06h, 4Bh, 00h, 64h
		db	 0Ch, 4Bh, 00h, 82h, 38h, 94h
		db	 00h, 64h,0E0h, 68h, 00h, 01h
		db	 00h, 50h, 4Bh, 12h, 20h, 4Bh
		db	 04h, 08h, 4Bh, 02h, 21h, 4Bh
		db	 18h, 80h, 08h, 4Bh, 00h, 04h
		db	 40h, 4Bh, 03h,0C8h, 10h, 00h
		db	 02h,0D5h, 00h, 05h, 05h, 24h
		db	 40h, 2Eh, 04h, 7Eh, 10h, 6Fh
		db	 02h,0F8h, 00h, 32h, 01h,0BCh
		db	 19h, 1Dh, 00h, 41h,0AAh,0CAh
		db	 00h, 02h, 00h, 04h, 68h, 4Bh
		db	 00h, 40h,0B4h, 4Bh, 00h, 20h
		db	 6Ah, 4Bh, 00h, 02h, 93h, 00h
		db	 40h, 48h, 0Ah, 00h, 51h, 12h
		db	 94h, 00h,0A5h,0A8h, 4Bh, 00h
		db	 5Eh,0B5h, 4Bh, 0Ch, 18h, 00h
		db	 18h, 00h, 74h, 00h, 74h, 00h
		db	 16h, 03h, 10h, 00h, 02h, 8Fh
		db	 4Bh, 00h, 01h, 6Fh, 4Bh, 01h
		db	 2Ch, 00h, 13h, 00h, 33h, 00h
		db	 1Fh, 00h, 0Ch, 00h,0FEh, 00h
		db	 32h, 00h, 3Ah, 00h, 08h, 00h
		db	0CAh, 4Bh, 01h, 02h, 4Bh, 07h
		db	 08h, 00h,0C7h, 00h, 2Ch, 00h
		db	 13h, 00h, 33h, 00h, 1Fh, 00h
		db	 0Ch, 00h,0FEh, 00h, 32h, 00h
		db	 3Ah, 00h, 08h, 00h,0CAh, 4Bh
		db	 01h, 02h, 00h, 07h, 00h, 07h
		db	 20h, 00h,0E2h, 00h,0C8h, 00h
		db	0E8h, 00h, 20h, 00h,0AAh, 00h
		db	 88h, 00h,0A8h, 00h, 28h, 00h
		db	0AAh, 00h, 80h, 00h,0A0h, 4Bh
		db	 01h, 08h, 4Bh, 0Fh, 18h, 00h
		db	 18h, 00h, 7Ch, 00h, 7Ch, 00h
		db	 18h, 00h, 1Eh,0C0h, 01h, 00h
		db	 02h,0EEh, 00h, 63h, 00h, 9Fh
		db	 4Bh, 01h, 7Fh, 00h, 33h, 00h
		db	 1Fh, 00h, 0Ch, 00h,0FEh, 00h
		db	 32h, 00h, 3Ah, 00h, 08h, 00h
		db	0CAh, 4Bh, 01h, 02h, 4Bh, 0Ah
		db	0C0h, 00h, 80h, 00h, 0Ch, 00h
		db	 08h, 4Bh, 03h,0F0h, 30h,0A0h
		db	 20h, 0Ch, 00h, 08h, 4Bh, 03h
		db	0C0h,0CFh, 80h, 00h, 0Ch,0CFh
		db	 4Bh, 01h, 03h, 00h, 02h, 0Ch
		db	0C0h, 4Bh, 01h, 0Fh, 00h, 02h
		db	 33h, 30h, 20h, 4Bh, 04h,0C3h
		db	 00h, 82h, 00h, 03h, 4Bh, 00h
		db	0CCh, 00h, 80h, 00h, 03h,0C0h
		db	 00h, 80h,0CCh, 4Bh, 05h, 30h
		db	 30h, 00h, 20h, 03h, 00h, 02h
		db	 00h,0F0h, 00h, 20h, 4Bh, 07h
		db	 03h, 00h, 02h, 4Bh, 03h,0C0h
		db	 00h, 80h, 4Bh, 00h, 03h, 00h
		db	 02h, 4Bh, 03h, 3Ch, 00h, 20h
		db	 30h, 30h, 20h, 4Bh, 03h, 03h
		db	 0Ch, 02h, 08h, 4Bh, 06h, 30h
		db	 00h, 20h, 00h,0B1h, 00h, 99h
		db	 00h,0C0h, 00h, 80h, 00h, 03h
		db	 4Bh, 02h, 0Ch, 00h, 08h, 00h
		db	0C0h, 00h, 80h, 00h, 03h, 00h
		db	 02h, 4Bh, 0Ah, 03h, 00h, 02h
		db	 00h,0C0h, 00h, 80h, 00h,0F0h
		db	 00h,0A0h, 00h,0F0h, 00h, 80h
		db	 00h, 03h, 00h, 02h, 4Bh, 08h
		db	 03h, 00h, 02h, 30h, 30h,0B9h
		db	 00h, 4Bh, 0Fh, 1Fh, 4Bh, 01h
		db	0FDh, 4Bh, 00h, 03h,0FEh, 4Bh
		db	 00h, 06h,0F8h, 4Bh, 00h, 0Dh
		db	0E8h, 00h, 05h, 4Bh, 0Ah,0D0h
		db	 4Bh, 01h, 52h, 4Bh, 01h, 8Ah
		db	 40h, 4Bh, 01h, 20h, 4Bh, 01h
		db	 10h,0A0h, 00h, 0Dh, 90h, 00h
		db	 03h, 0Dh, 40h, 00h, 05h, 06h
		db	 40h, 4Bh, 00h, 03h, 4Bh, 02h
		db	0A0h, 4Bh, 01h, 15h, 4Bh, 09h
		db	 10h,0C0h, 4Bh, 00h, 10h,0A0h
		db	 4Bh, 00h, 20h, 4Bh, 01h, 40h
		db	 4Bh, 00h, 02h, 4Bh, 01h, 50h
		db	 4Bh, 16h, 1Fh, 4Bh, 01h,0FDh
		db	 4Bh, 00h, 03h,0FEh, 4Bh, 00h
		db	 06h,0F8h, 00h, 05h, 0Dh,0E8h
		db	 00h, 13h, 4Bh, 0Ah,0D0h, 4Bh
		db	 01h, 52h, 4Bh, 01h, 8Ah, 40h
		db	 4Bh, 01h, 20h, 50h, 4Bh, 00h
		db	 10h,0A8h, 00h, 0Dh, 90h, 00h
		db	 2Fh, 0Dh, 40h, 00h, 17h, 06h
		db	 40h, 00h, 0Ah, 03h, 4Bh, 02h
		db	0A0h, 4Bh, 01h, 15h, 4Bh, 09h
		db	 10h,0D0h, 4Bh, 00h, 10h,0A8h
		db	 4Bh, 00h, 20h, 40h, 4Bh, 00h
		db	 40h, 4Bh, 00h, 02h, 4Bh, 01h
		db	 50h, 4Bh, 16h, 1Fh, 4Bh, 01h
		db	0FDh, 4Bh, 00h, 03h,0FEh, 00h
		db	 01h, 06h,0F8h, 00h, 07h, 0Dh
		db	0E9h, 00h, 16h, 4Bh, 0Ah,0D0h
		db	 4Bh, 01h, 52h, 4Bh, 01h, 8Ah
		db	 40h, 20h, 4Bh, 00h, 20h,0F5h
		db	 00h, 40h, 10h,0BAh, 00h, 0Dh
		db	 92h, 00h, 2Dh, 0Dh, 45h, 00h
		db	 3Ah, 06h, 40h, 00h, 1Fh, 03h
		db	 4Bh, 00h, 0Ah, 00h,0A0h, 4Bh
		db	 01h, 15h, 4Bh, 08h, 80h, 10h
		db	 7Dh, 00h, 40h, 10h,0BAh, 4Bh
		db	 00h, 20h,0D4h, 4Bh, 00h, 40h
		db	0A0h, 00h, 02h, 4Bh, 01h, 50h
		db	 4Bh, 09h, 03h,0BFh, 02h,0AAh
		db	 08h, 4Bh, 01h, 18h, 00h, 02h
		db	0FEh, 30h, 00h, 20h, 00h, 20h
		db	 00h, 0Bh,0FAh, 20h, 00h, 20h
		db	 4Bh, 01h, 0Bh,0FAh, 20h, 00h
		db	 20h, 00h,0AAh,0F0h,0AAh, 30h
		db	 03h, 08h, 00h, 08h, 02h, 04h
		db	0AAh, 04h, 04h, 02h, 04h, 22h
		db	 4Bh, 00h,0A0h, 48h, 04h, 02h
		db	 04h, 92h, 4Bh, 00h,0A1h, 20h
		db	 04h, 02h, 04h, 02h, 3Fh,0B6h
		db	 23h,0A6h, 20h, 34h, 00h, 24h
		db	 10h, 1Ch, 02h, 3Eh, 10h, 00h
		db	 01h, 55h, 10h, 00h, 10h, 00h
		db	 10h, 00h, 15h,0FDh, 10h, 00h
		db	 12h,0AAh, 1Dh, 50h, 1Dh, 50h
		db	0EAh,0AAh, 8Ah,0AAh, 04h, 02h
		db	 04h, 02h, 04h, 00h, 20h, 80h
		db	 04h, 02h, 44h, 22h, 04h, 02h
		db	 05h, 02h, 04h, 00h, 50h, 20h
		db	 04h, 04h,0A2h, 44h, 6Dh, 6Ch
		db	 45h, 6Ch, 00h, 02h, 00h, 02h
		db	 00h, 07h, 00h, 06h, 00h, 07h
		db	 00h, 06h, 00h, 1Fh, 00h, 1Fh
		db	 00h, 78h, 00h, 70h, 00h,0E0h
		db	 00h,0C0h, 00h, 78h, 00h, 70h
		db	 00h, 1Fh, 00h, 1Bh, 4Bh, 0Ah
		db	0C0h, 00h,0C0h, 00h,0F0h, 00h
		db	0E0h, 00h, 38h, 00h, 20h, 00h
		db	0F0h, 00h,0C0h, 00h,0C0h, 4Bh
		db	 02h, 0Fh, 00h, 0Dh, 00h, 0Bh
		db	 00h, 0Ah, 00h, 0Bh, 00h, 09h
		db	 00h, 0Bh, 00h, 0Ah, 00h, 0Bh
		db	 00h, 09h, 00h, 0Bh, 00h, 0Ah
		db	 00h, 0Bh, 00h, 09h, 4Bh, 0Ah
		db	0E0h, 00h,0A0h, 4Bh, 03h, 90h
		db	 00h, 90h, 00h,0F0h, 00h,0C0h
		db	 4Bh, 08h, 02h, 00h, 03h, 00h
		db	 1Ah, 00h, 56h, 00h,0B6h, 00h
		db	0B5h, 00h,0FAh, 01h, 87h, 01h
		db	0DFh, 01h,0BFh, 01h,0D0h, 01h
		db	0B2h, 02h,0BFh, 02h,0FFh, 0Dh
		db	0A0h, 0Dh, 64h,0D4h, 00h,0BCh
		db	 00h, 7Bh, 00h,0FBh, 00h,0FEh
		db	 80h,0FEh, 80h, 2Ah, 80h,0FEh
		db	 80h,0FCh,0C0h,0FCh,0C0h, 24h
		db	0E0h, 6Ch,0E0h,0FEh,0D8h,0FEh
		db	0D8h, 00h, 74h,0AAh, 74h, 11h
		db	0BFh, 11h, 7Fh, 23h,0A0h, 2Fh
		db	 6Ah, 51h, 7Fh, 50h,0FFh, 51h
		db	 61h, 50h,0EBh, 43h, 7Fh, 46h
		db	0FFh, 45h, 00h, 4Dh, 00h, 5Ch
		db	 00h, 5Ch, 00h, 9Eh, 6Dh, 9Eh
		db	 6Dh,0FEh, 34h,0FEh, 34h, 0Eh
		db	 54h, 1Eh, 54h,0F3h, 1Ah,0F7h
		db	 1Ah,0C8h, 0Ah,0D9h, 0Ah,0FFh
		db	 0Ah,0FFh, 0Ah, 00h, 0Ah, 00h
		db	 0Ah, 00h, 65h, 00h, 65h, 52h
		db	0F5h, 52h,0F5h, 50h, 24h, 4Bh
		db	 00h, 81h, 20h, 4Bh, 01h, 04h
		db	 4Bh, 00h,0B9h, 00h, 4Bh, 01h
		db	 04h, 4Bh, 00h, 21h, 20h, 4Bh
		db	 01h, 04h, 4Bh, 00h, 20h, 40h
		db	 4Bh, 01h, 04h, 4Bh, 05h, 04h
		db	 4Bh, 05h, 04h, 4Bh, 00h, 02h
		db	 4Bh, 01h, 02h, 84h, 4Bh, 00h
		db	 21h, 4Bh, 02h, 04h, 4Bh, 00h
		db	 04h, 40h, 4Bh, 00h, 10h, 04h
		db	 4Bh, 01h, 80h, 4Bh, 00h, 04h
		db	 04h, 4Bh, 00h, 20h, 4Bh, 01h
		db	 61h, 44h, 4Bh, 00h, 82h, 90h
		db	 4Bh, 0Dh, 01h, 4Bh, 09h, 01h
		db	 4Bh, 01h, 02h, 4Bh, 00h, 01h
		db	 6Ch, 00h, 24h, 40h, 8Eh, 00h
		db	 02h, 01h, 6Ch, 00h, 24h, 00h
		db	 86h, 00h, 02h, 01h, 4Ch, 00h
		db	 04h, 40h,0CCh, 00h, 40h, 89h
		db	 6Dh, 80h, 21h, 00h, 8Eh, 00h
		db	 02h, 4Bh, 07h, 04h, 4Bh, 05h
		db	 04h, 4Bh, 05h, 44h, 4Bh, 00h
		db	 02h, 90h, 4Bh, 00h, 41h, 6Ch
		db	 00h, 24h, 20h, 8Eh, 20h, 02h
		db	 01h, 6Ch, 00h, 24h, 00h, 86h
		db	 00h, 02h, 21h, 4Ch, 00h, 04h
		db	 70h,0CCh, 20h, 40h, 71h, 6Dh
		db	 00h, 21h,0A4h, 8Eh, 00h, 02h
		db	 00h, 05h, 4Bh, 01h, 10h, 4Bh
		db	 01h, 0Dh, 00h, 08h, 00h, 02h
		db	 4Bh, 01h, 11h, 4Bh, 01h, 05h
		db	 00h, 04h, 01h, 09h, 4Bh, 00h
		db	 84h,0AAh, 00h, 20h, 29h, 6Ch
		db	 08h, 24h, 24h, 8Eh, 00h, 02h
		db	 4Dh, 6Ch, 08h, 24h, 20h, 86h
		db	 00h, 02h, 69h, 4Ch, 08h, 04h
		db	 64h,0CCh, 00h, 40h, 21h, 6Dh
		db	 00h, 21h, 24h, 8Eh, 00h, 02h
		db	 00h, 07h, 4Bh, 01h, 0Fh, 4Bh
		db	 01h, 05h, 4Bh, 01h, 04h, 4Bh
		db	 01h, 3Fh, 4Bh, 01h, 0Fh, 4Bh
		db	 01h, 0Ah, 4Bh, 01h, 62h, 4Bh
		db	 00h,0E0h, 4Bh, 01h, 90h, 4Bh
		db	 01h, 20h, 4Bh, 01h, 20h, 4Bh
		db	 01h, 4Ch, 4Bh, 01h, 10h, 4Bh
		db	 05h, 02h, 4Bh, 12h, 0Ah, 4Bh
		db	 01h, 2Bh, 4Bh, 01h,0BFh, 00h
		db	 02h, 2Ah,0FFh, 00h, 2Bh, 4Bh
		db	 06h, 80h, 4Bh, 01h, 80h, 4Bh
		db	 01h,0E8h, 00h, 80h, 00h,0FEh
		db	 00h, 80h, 00h,0FFh, 80h,0E0h
		db	 00h,0FFh,0EAh,0FAh, 4Bh, 00h
		db	0BFh, 00h, 02h, 00h, 2Fh, 4Bh
		db	 01h, 0Ah, 4Bh, 14h,0FFh, 80h
		db	0E0h, 00h,0FEh, 00h, 80h, 00h
		db	0E8h, 00h, 80h, 00h, 80h, 4Bh
		db	 01h, 80h, 4Bh, 01h, 80h, 4Bh
		db	 0Ah, 03h, 00h, 02h, 00h, 0Fh
		db	 00h, 02h,0B1h, 00h, 02h, 00h
		db	 30h, 3Ch, 20h, 08h, 00h,0CCh
		db	 4Bh, 00h, 03h, 0Ch, 4Bh, 01h
		db	 03h, 00h, 02h,0F0h, 3Fh, 80h
		db	 28h, 04h, 18h, 08h, 30h, 0Ch
		db	 30h, 18h,0E3h, 0Ch,0E1h, 39h
		db	0CFh, 1Ch,0E2h, 39h,0CFh, 1Dh
		db	0C3h, 7Bh, 9Fh, 3Dh,0C7h, 7Bh
		db	0BFh, 3Dh,0CFh,0FBh,0BFh, 3Dh
		db	 8Dh,0F9h, 1Ch, 07h, 00h,0FEh
		db	 00h, 1Ch, 0Ch,0F8h,0F8h, 3Ch
		db	 78h,0FDh,0F1h,0FEh,0E1h,0FEh
		db	0C7h,0FFh,0C7h,0FFh,0DEh,0F5h
		db	0EEh,0F1h,0ECh,0BDh,0FCh, 81h
loc_7:
		clc				; Clear carry flag
		sbb	di,bp
		jcxz	loc_7			; Jump if cx=0
		cmp	ax,0F983h
		or	[si+0Dh],bh
		js	$+1Eh			; Jump if sign=1
		jle	loc_8			; Jump if < or =
;*		jl	loc_9			;*Jump if <
		db	 7Ch, 3Fh		;  Fixup - byte match
		db	 3Eh, 1Eh, 3Ch, 7Fh, 1Fh, 03h
		db	 1Eh, 07h, 0Fh, 81h, 0Fh,0B1h
loc_8:
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
		add	ax,ax
;*		add	[si+0],bh
		db	 00h, 7Ch, 00h		;  Fixup - byte match
		db	 78h, 77h,0F3h, 87h,0FEh,0D0h
		db	 9Eh, 1Fh, 9Ch, 07h, 58h,0B7h
		db	 50h,0DBh, 00h,0DAh, 00h,0DCh
		db	 60h,0D8h, 40h,0D0h,0C0h,0C3h
		db	 80h, 03h, 00h, 1Eh, 00h, 1Ch
		db	 00h, 78h, 00h

_358UNKN	endp

seg_a		ends



		end	start
