
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_382UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_5e		equ	0E00h			;*
data_6e		equ	0E08h			;*
data_7e		equ	1C00h			;*
data_8e		equ	211Ch			;*
data_9e		equ	8000h			;*
data_10e	equ	8928h			;*
data_11e	equ	0A0D2h			;*
data_12e	equ	0A200h			;*
data_13e	equ	0A308h			;*
data_14e	equ	0A400h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_382UNKN	proc	far

start:
		or	word ptr ds:[0],ax
		add	[bx],al
		test	byte ptr [bx+si],1
		add	al,[bp+di]
		add	al,5
		push	es
		pop	es
		or	[bx+di],cl
		test	byte ptr [bx+si],38h	; '8'
		add	al,0F6h
		add	[bx+di],al
		db	 8Eh, 4Bh,0F6h, 00h, 02h, 21h
		db	0F6h, 00h, 0Eh, 02h,0F6h, 00h
		db	 02h, 21h,0F6h, 00h, 01h, 10h
data_3		db	2			; Data table (indexed access)
		db	0F6h, 00h, 01h, 02h,0CBh,0F6h
		db	 00h, 01h, 53h, 7Bh,0F6h, 00h
		db	 02h, 35h,0F6h, 00h, 01h, 02h
		db	 40h,0F6h, 00h, 02h, 09h,0F6h
		db	 00h, 01h, 2Bh,0D4h,0F6h, 00h
		db	 01h, 5Fh,0FDh, 02h,0A8h, 00h
		db	 80h,0BFh, 7Ah, 15h, 70h, 03h
		db	0C0h,0FCh, 3Fh,0ACh, 28h, 03h
		db	0E0h,0FCh, 1Fh, 08h, 15h, 01h
		db	 00h,0FEh,0FFh, 0Ah,0A8h, 00h
		db	 00h, 5Fh,0FAh, 04h, 90h, 00h
		db	 00h, 2Fh,0E8h, 00h, 40h, 00h
		db	 00h, 40h,0F6h, 00h, 02h, 84h
		db	0F6h, 00h, 02h, 40h, 08h,0F6h
		db	 00h, 01h,0D3h, 40h,0F6h, 00h
		db	 01h,0DEh,0CAh,0F6h, 00h, 01h
		db	0ACh,0F6h, 00h, 02h, 02h, 40h
		db	0F6h, 00h, 01h, 90h,0F6h, 00h
		db	 14h, 20h,0F6h, 00h, 02h,0D2h
		db	 71h,0F6h, 00h, 01h, 84h,0F6h
		db	 00h, 1Ah, 05h,0F6h, 00h, 02h
		db	 01h, 10h,0F6h, 00h, 01h, 09h
		db	 40h,0F6h, 00h, 01h, 03h,0A4h
		db	0F6h, 00h, 01h, 91h, 91h,0F6h
		db	 00h, 01h, 2Bh,0EAh,0F6h, 00h
		db	 01h, 57h,0D4h,0F6h, 00h, 01h
		db	 89h, 89h,0F6h, 00h, 01h, 25h
		db	0C0h,0F6h, 00h, 01h, 02h, 90h
		db	0F6h, 00h, 01h, 08h, 80h,0F6h
		db	 00h, 02h,0A0h,0F6h, 00h, 0Dh
		db	 45h, 84h,0F6h, 00h, 01h, 13h
		db	 40h,0F6h, 00h, 01h,0ABh,0A4h
		db	0F6h, 00h, 01h, 7Fh,0DBh, 07h
		db	 40h, 00h, 00h,0B7h,0FDh, 01h
		db	 80h, 00h, 00h, 0Bh, 54h,0F6h
		db	 00h, 01h, 45h, 88h,0F6h, 00h
		db	 01h, 19h, 22h,0F6h, 00h, 09h
		db	 21h,0F6h, 00h, 03h, 20h,0F6h
		db	 00h, 01h, 04h,0F6h, 00h, 02h
		db	 44h, 10h,0F6h, 00h, 02h, 01h
		db	0F6h, 00h, 01h, 08h,0F6h, 00h
		db	 03h, 04h,0FFh, 00h,0BAh, 00h
		db	0FFh, 00h,0FCh,0A0h, 40h, 00h
		db	0FCh,0A0h,0A8h, 48h, 00h, 00h
		db	0A8h, 48h, 40h, 09h, 00h, 06h
		db	 40h, 0Fh, 00h, 3Fh, 00h, 2Ah
		db	 00h, 3Fh, 00h,0E3h, 00h, 18h
		db	 00h,0FBh, 0Fh,0DDh, 00h, 68h
		db	 0Fh,0FDh,0F2h, 0Ch, 00h,0C0h
		db	0F2h,0CCh, 00h, 03h,0F6h, 00h
		db	 00h, 03h, 03h,0DFh, 01h, 7Ah
		db	 03h,0FFh,0EBh,0F3h, 3Dh, 40h
		db	0FFh,0F3h, 9Fh,0A8h,0F4h, 00h
		db	0FFh,0A8h,0FDh,0A0h,0C0h, 00h
		db	0FDh,0A0h,0ECh,0F6h, 00h, 00h
		db	0ECh,0F6h, 00h, 04h,0C0h,0D7h
		db	 00h, 7Dh,0C0h,0FFh, 02h, 32h
		db	 01h, 00h, 03h, 32h, 06h, 3Ch
		db	 02h, 2Ch, 06h, 3Ch, 0Ch,0C4h
		db	 00h,0C0h, 0Ch,0C4h, 08h, 80h
		db	 00h, 80h, 08h, 80h, 33h, 43h
		db	 00h, 03h, 33h, 43h, 41h, 43h
		db	 00h, 02h, 41h, 43h,0A4h, 8Ch
		db	 00h, 08h,0A4h, 8Ch, 00h, 0Ch
		db	0F6h, 00h, 00h, 0Ch, 00h,0FFh
		db	 03h,0B4h, 03h,0FFh, 03h, 3Ch
		db	 07h, 00h, 07h, 3Ch, 0Ch,0C0h
		db	 08h, 00h, 0Ch,0C0h,0F7h, 80h
		db	 4Dh, 80h,0FFh, 80h, 03h,0CCh
		db	 0Ch, 0Ch, 0Fh,0CCh, 07h,0E8h
		db	 0Ch, 38h, 0Fh,0F8h, 0Fh, 20h
		db	 08h, 20h, 0Fh, 20h, 0Ch,0C0h
		db	 00h, 00h, 0Ch,0C0h, 00h, 01h
		db	 00h, 06h, 00h, 07h, 04h,0AFh
		db	 01h, 10h, 05h,0BFh, 0Bh,0F4h
		db	 00h, 00h, 0Bh,0F4h, 02h,0D0h
		db	 00h, 00h, 02h,0D0h,0F6h, 00h
		db	 00h, 03h,0F6h, 00h, 01h, 01h
		db	 74h, 00h, 20h,0F6h, 00h, 00h
		db	0BAh, 00h, 20h,0F6h, 00h, 00h
		db	 30h, 00h, 00h,0D0h, 01h, 00h
		db	 06h,0D0h, 07h,0F4h,0AFh, 01h
		db	 10h,0F5h,0BFh, 6Bh,0F4h, 00h
		db	 00h, 6Bh,0F4h, 02h,0D0h, 08h
		db	 00h, 02h,0D0h, 00h, 00h,0D8h
		db	 03h,0F6h, 00h, 01h, 3Dh, 74h
		db	0F6h, 00h, 01h, 19h,0BAh,0F6h
		db	 00h, 01h, 40h, 30h, 00h, 00h
		db	0D0h, 01h, 00h, 06h,0D0h, 07h
		db	0F4h,0AFh, 01h, 10h,0F5h,0BFh
		db	 6Bh,0F4h, 00h, 00h, 6Bh,0F4h
		db	 02h,0D0h, 08h, 00h, 02h,0D0h
		db	 00h, 00h,0D8h, 03h,0F6h, 00h
		db	 01h, 3Dh, 74h, 18h, 20h, 00h
		db	 00h, 19h,0BAh, 00h, 20h, 00h
		db	 00h, 44h, 30h,0F6h, 00h, 0Bh
		db	0E7h, 98h, 08h, 41h, 08h, 41h
		db	 00h, 64h, 05h, 99h, 05h, 99h
		db	0F6h, 00h, 00h, 17h, 00h, 17h
		db	0F6h, 00h, 00h, 02h, 00h, 02h
		db	0F6h, 00h, 1Bh, 70h, 00h, 88h
		db	 00h, 88h, 00h, 29h, 00h,0D2h
loc_1:
		mov	al,ds:data_11e
		add	dl,al
		std				; Set direction flag
		add	al,0FDh
		add	al,0
		add	[bx-55h],dl
		push	di
		stosw				; Store ax to es:[di]
		add	[bx+si],al
loc_3:
		add	ax,590h
		nop
loc_5:
		add	[si],ax
		add	[si],ax
		add	[si],ax
		add	ss:data_12e[bp+si],ah
		add	ss:data_7e[bp+si],ah
		add	[si],bl
		add	[si],bl
		add	ds:data_5e,cl
		add	byte ptr ds:[300h],cl
		add	[bp+di],al
		add	[bp+di],al
		add	[bp+di],al
		add	[bp+di],al
		add	[bp+di],al
		add	[bp+si],al
		add	[bp+si],al
		add	[bp+si],al
		test	byte ptr [bx+si],3
		add	al,0
		add	al,0
		add	al,0
		and	[bx+si],ax
		and	[bx+si],ax
		and	[bx+si],ax
		add	ds:data_9e[bx+si],al
		add	byte ptr ds:[10h][bx+si],al
		adc	[bx+si],al
		adc	[bx+si],al
		or	[bx+si],ah
		or	[bx+si],ah
		or	[bx+si],ah
		add	[bx+si],dl
		add	[bx+si],dl
		add	[bx+si],dl
		movsb				; Mov [si] to es:[di]
		add	ds:data_14e[si],ah
		add	ds:data_6e,cl
		or	ds:data_13e,cl
		or	ss:data_13e[bp+di],ah
		or	[bx+di-7Ch],dh
		jno	loc_1			; Jump if not overflw
;*		jno	loc_2			;*Jump if not overflw
		db	 71h, 84h		;  Fixup - byte match
		jz	loc_3			; Jump if zero
;*		jz	loc_4			;*Jump if zero
		db	 74h, 91h		;  Fixup - byte match
		jz	loc_5			; Jump if zero
		sub	ds:data_10e[bx+di],cl
		sub	ds:data_8e[bx+di],cl
		sbb	al,21h			; '!'
		sbb	al,21h			; '!'
		xor	al,84h
		xor	al,84h
		xor	al,84h
		sbb	[bx+si],dx
		sbb	[bx+si],dx
		sbb	[bx+si],dx
		adc	ah,[bx+si+12h]
		db	 60h, 12h, 60h,0F6h, 00h, 1Bh
		db	 80h, 00h, 80h, 00h, 80h, 00h
		db	 80h, 00h, 80h, 00h, 80h, 00h
		db	 40h, 00h, 40h, 00h, 40h, 00h
		db	 47h, 15h, 47h, 15h, 47h, 15h
		db	 95h, 4Ah, 95h, 4Ah, 95h, 4Ah
		db	 6Ah,0A4h, 6Ah,0A4h, 6Ah,0A4h
		db	 55h, 50h, 55h, 50h, 55h, 50h
		db	 2Ah, 86h, 2Ah, 86h, 2Ah, 86h
		db	 95h, 1Ah, 95h, 1Ah, 95h, 1Ah
		db	 48h, 55h, 48h, 55h, 48h, 55h
		db	0A0h, 2Ah,0A0h, 2Ah,0A0h, 2Ah
		db	 47h, 15h, 47h, 15h, 47h, 15h
		db	 95h, 4Ah, 95h, 4Ah, 95h, 4Ah
		db	 6Ah,0A4h, 6Ah,0A4h, 6Ah,0A4h
		db	0D5h, 50h,0D5h, 50h, 55h, 50h
		db	0AAh, 86h,0AAh, 86h, 2Ah, 86h
		db	 95h, 1Ah, 95h, 1Ah, 95h, 1Ah
		db	 48h, 55h, 48h, 55h, 48h, 55h
		db	0A0h, 2Ah,0A0h, 2Ah, 20h, 2Ah
		db	 40h, 00h, 40h, 00h, 40h, 00h
		db	 10h, 03h, 10h, 03h, 10h, 00h
		db	 10h, 1Fh, 10h, 1Fh, 10h, 15h
		db	 28h,0BBh, 28h,0BBh, 28h,0ABh
		db	 14h,0EDh, 14h,0EDh, 14h,0EDh
		db	 89h, 40h, 89h, 40h, 89h, 40h
		db	 44h, 1Ch, 44h, 1Ch, 44h, 1Ch
		db	 00h,0A1h, 00h,0A1h, 00h,0A1h
		db	0C7h, 15h,0C7h, 15h,0C7h, 15h
		db	0D5h, 4Ah,0D5h, 4Ah,0D5h, 4Ah
		db	0EAh,0A4h,0EAh,0A4h,0EAh,0A4h
		db	0D5h, 50h,0D5h, 50h, 55h, 50h
		db	0EAh, 86h,0EAh, 86h,0AAh, 86h
		db	0D5h, 1Ah,0D5h, 1Ah, 15h, 1Ah
		db	0C8h, 55h,0C8h, 55h,0C8h, 55h
		db	0E0h, 2Ah,0E0h, 2Ah, 20h, 2Ah
		db	 00h, 01h, 00h, 01h,0F6h, 00h
		db	 00h, 03h, 00h, 03h,0F6h, 00h
		db	 00h, 3Fh, 00h, 3Fh, 00h, 3Ah
		db	 00h,0FFh, 00h,0FFh, 00h, 8Fh
		db	 07h,0FFh, 07h,0FFh, 07h, 77h
		db	 5Fh,0FFh, 5Fh,0FFh, 55h,0FFh
		db	0FFh,0EAh,0FFh,0EAh, 4Fh,0EAh
		db	0FDh, 55h,0FDh, 55h,0DDh, 55h
		db	0F6h, 00h, 1Bh, 03h,0D7h, 03h
		db	0D7h, 03h,0D7h, 3Fh,0FFh, 3Fh
		db	0FFh, 29h, 9Bh,0F7h,0FFh,0F7h
		db	0FFh, 86h,0FFh,0F6h, 00h, 04h
		db	 01h, 00h, 01h, 00h, 01h, 00h
		db	 3Fh, 00h, 3Fh, 00h, 3Ah, 00h
		db	0FFh, 00h,0FFh, 00h, 8Fh, 07h
		db	0FFh, 07h,0FFh, 07h, 77h, 5Fh
		db	0FFh, 5Fh,0FFh, 55h,0FFh,0FFh
		db	0EAh,0FFh,0EAh, 7Fh,0EAh,0FDh
		db	 55h,0FDh, 55h,0FDh, 55h,0FFh
		db	 15h,0FFh, 15h, 97h, 15h,0F5h
		db	 4Ah,0F5h, 4Ah, 75h, 4Ah,0FAh
		db	0A4h,0FAh,0A4h,0FAh,0A4h,0D5h
		db	 50h,0D5h, 50h,0D5h, 50h, 2Ah
		db	 86h, 2Ah, 86h, 2Ah, 86h, 95h
		db	 1Ah, 95h, 1Ah, 95h, 1Ah, 48h
		db	 55h, 48h, 55h, 48h, 55h,0A0h
		db	 2Ah,0A0h, 2Ah,0A0h, 2Ah, 00h
		db	 01h, 00h, 01h, 00h, 01h, 00h
		db	 03h, 00h, 03h, 00h, 03h, 00h
		db	 07h, 00h, 07h, 00h, 05h, 00h
		db	 3Fh, 00h, 3Fh, 00h, 3Fh, 01h
		db	0FFh, 01h,0FFh, 01h,0D7h, 07h
		db	0FCh, 07h,0FCh, 04h
		db	7Ch
loc_6:
		aas				; Ascii adjust
                           lock	aas				; Ascii adjust
                           lock	aaa				; Ascii adjust
                           lock	inc	word ptr ds:[80FFh][bx+si]
		mov	di,0C780h
		pop	ds
		db	0C7h, 1Fh,0C5h, 1Fh
loc_8:
		lahf				; Load ah from flags
		iret				; Interrupt return
			                        ;* No entry point to code
		lahf				; Load ah from flags
		iret				; Interrupt return
			                        ;* No entry point to code
		xchg	dx,ax
		iret				; Interrupt return
			                        ;* No entry point to code
		jg	loc_6			; Jump if >
;*		jg	loc_7			;*Jump if >
		db	 7Fh,0E6h		;  Fixup - byte match
		dec	di
		out	7Fh,al			; port 7Fh ??I/O Non-standard
                           lock	jg	loc_8			; Jump if >
		pop	di
                           lock	aas				; Ascii adjust
		db	0C6h, 3Fh,0C6h, 37h,0C4h, 9Fh
		db	 1Fh, 9Fh, 1Fh, 9Fh, 13h,0CCh
		db	 7Fh,0CCh, 7Fh,0CCh, 5Fh,0E0h
		db	 3Fh,0E0h, 3Fh,0E0h, 3Fh,0FFh
		db	0FDh,0FFh,0FDh,0FFh,0FDh,0DDh
		db	0EAh,0DDh,0EAh,0DDh,0EAh, 6Ah
		db	0A4h, 6Ah,0A4h, 6Ah,0A4h, 55h
		db	 50h, 55h, 50h, 55h, 50h, 2Ah
		db	 86h, 2Ah, 86h, 2Ah, 86h, 95h
		db	 1Ah, 95h, 1Ah, 95h, 1Ah, 48h
		db	 55h, 48h, 55h, 48h, 55h,0A0h
		db	 2Ah,0A0h, 2Ah,0A0h, 2Ah, 00h
		db	 01h, 00h, 01h, 00h, 01h, 00h
		db	 03h, 00h, 03h, 00h, 03h, 00h
		db	 07h, 00h, 07h, 00h, 05h, 00h
		db	 3Eh, 00h, 3Eh, 00h, 26h, 01h
		db	0F3h, 01h,0F3h, 01h, 53h, 07h
		db	0E7h, 07h,0E7h, 04h, 27h, 3Fh
		db	0DFh, 3Fh,0DFh, 37h,0DFh,0FDh
		db	0DEh,0FDh,0DEh,0BDh,0DEh,0FFh
		db	 1Fh,0FFh, 1Fh,0F9h, 1Fh,0FFh
		db	0CFh,0FFh,0CFh,0C7h, 4Fh,0FFh
		db	0E6h,0FFh,0E6h,0AFh,0A6h, 7Fh
		db	0F0h, 7Fh,0F0h, 5Fh,0F0h, 3Fh
		db	0C6h, 3Fh,0C6h, 3Fh,0C6h, 9Fh
		db	 1Fh, 9Fh, 1Fh, 9Fh, 13h,0CCh
		db	 7Fh,0CCh, 7Fh,0CCh, 6Fh,0E0h
		db	 3Fh,0E0h, 3Fh,0E0h, 3Fh, 40h
		db	 15h, 40h, 15h, 40h, 15h, 80h
		db	 0Ah, 80h, 0Ah, 80h, 0Ah, 00h
		db	 04h, 00h, 04h, 00h, 04h,0F6h
		db	 00h, 04h, 06h, 00h, 06h, 00h
		db	 06h, 80h, 1Ah, 80h, 1Ah, 80h
		db	 1Ah, 40h, 55h, 40h, 55h, 40h
		db	 55h,0A0h, 2Ah,0A0h, 2Ah,0A0h
		db	 2Ah, 40h, 15h, 40h, 15h, 40h
		db	 15h, 80h, 0Ah, 80h, 0Ah, 80h
		db	 0Ah, 00h, 04h, 00h, 04h, 00h
		db	 04h,0F6h, 00h, 09h, 80h, 00h
		db	 80h, 00h, 80h, 00h, 40h, 00h
		db	 40h, 00h, 40h, 00h,0A0h, 00h
		db	0A0h, 00h,0A0h, 00h, 40h, 10h
		db	 40h, 10h, 40h, 10h, 80h, 00h
		db	 80h, 00h, 80h, 00h, 00h, 04h
		db	 00h, 04h, 00h, 04h,0F6h, 00h
		db	 09h, 80h, 00h, 80h, 00h, 80h
		db	0F6h, 00h, 04h, 20h, 00h, 20h
		db	 00h, 20h, 00h

_382UNKN	endp

seg_a		ends



		end	start
