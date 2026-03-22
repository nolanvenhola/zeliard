
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR1_24	                                 лл
;лл					                                 лл
;лл      Created:   16-Feb-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_7e		equ	690Ch			;*
data_8e		equ	0F744h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr1_24		proc	far

start:
		db	0DDh, 10h, 00h, 00h, 00h, 07h
		db	0DDh, 1Ah, 04h, 81h,0F3h, 80h
		db	 00h, 1Fh, 38h, 00h, 01h,0F7h
		db	 80h, 00h, 1Fh, 78h, 00h, 01h
		db	0F7h, 80h, 00h, 1Fh,0E8h, 00h
		db	 01h,0FFh, 80h, 00h, 0Fh,0FCh
		db	 00h, 00h,0FFh,0C0h, 00h, 0Fh
		db	0FCh, 00h, 00h,0EBh,0C0h, 00h
		db	 0Eh,0FCh, 00h, 00h,0E7h,0C0h
		db	 00h, 0Ah,0DCh, 00h, 00h,0ABh
		db	0C0h, 00h, 08h, 3Ch, 00h, 00h
		db	0C7h,0E0h, 00h, 0Ch, 7Eh, 00h
		db	 00h,0EFh,0E0h, 00h, 0Fh,0BFh
		db	 00h, 00h,0FDh,0F0h, 00h, 0Fh
		db	0DFh, 80h, 01h,0D5h, 78h, 00h
		db	 1Fh, 37h, 80h, 01h,0FBh, 7Ch
		db	 00h, 3Fh,0F7h,0C0h, 03h,0FFh
		db	 7Ah, 00h, 7Fh,0FFh, 88h, 1Bh
		db	0F3h,0F8h, 81h, 3Fh, 7Fh, 88h
		db	 13h,0E7h,0F8h, 81h, 3Fh, 3Fh
		db	 88h, 13h,0E3h,0F8h, 81h, 7Ch
		db	 3Fh, 88h, 25h,0C1h,0F8h, 82h
		db	 58h, 1Fh, 88h, 27h,0E1h,0F8h
		db	 82h, 7Ch, 1Fh, 08h, 27h,0C0h
		db	0F0h, 86h, 78h, 0Fh, 08h, 47h
		db	 80h,0F0h, 84h, 71h, 0Fh, 0Ch
		db	 47h,0F0h,0F0h, 44h, 62h, 1Fh
		db	 04h, 47h,0D1h,0F0h, 44h, 47h
		db	 0Eh, 04h, 47h,0E1h,0E0h, 44h
		db	 42h, 0Eh, 04h,0CFh,0C1h,0E0h
		db	 4Ch, 84h, 1Eh, 04h,0CFh, 81h
		db	0E0h, 4Dh, 08h, 1Eh, 04h, 9Fh
		db	 01h,0E0h, 49h, 20h, 5Ch, 04h
		db	 9Fh, 0Dh,0C0h, 49h, 26h,0FCh
		db	 04h, 9Eh, 6Fh,0C0h, 49h, 26h
		db	0FCh, 04h, 9Eh,0EFh,0C0h, 48h
		db	0CEh, 7Ch, 04h, 84h, 47h,0C0h
		db	 48h, 04h,0FCh, 04h, 80h, 0Fh
		db	0C0h, 48h, 01h,0DCh, 04h, 80h
		db	 1Bh, 80h, 48h, 01h,0B8h, 04h
		db	 80h, 19h, 00h, 48h, 01h, 90h
		db	 04h, 80h, 2Eh, 00h, 48h, 0Eh
		db	 80h, 04h
data_1		db	80h			; Data table (indexed access)
		db	0E8h, 00h, 48h, 07h, 80h, 04h
		db	 80h, 38h, 00h, 48h, 03h, 00h
		db	 04h, 81h,0F8h, 00h, 48h, 03h
		db	 80h, 04h, 80h, 7Ch, 00h, 48h
		db	 1Fh
data_2		db	0C0h			; Data table (indexed access)
		db	 0Ch, 80h, 7Ch, 00h, 88h, 07h
		db	0C0h, 08h,0C0h,0FCh, 00h, 84h
		db	 0Fh,0C0h, 08h, 41h, 78h, 00h
		db	 84h, 07h, 80h, 08h, 40h, 78h
		db	 00h, 44h, 06h, 00h, 04h, 2Eh
		db	0C0h, 00h, 42h,0F9h, 00h, 04h
		db	 3Eh, 10h, 00h, 23h,0F1h, 80h
		db	 02h, 7Eh, 30h, 00h, 27h, 31h
		db	 00h, 02h, 7Bh, 10h, 00h, 27h
		db	 91h, 80h, 03h, 79h, 98h, 00h
		db	 16h, 1Dh, 00h, 01h, 61h,0D8h
		db	 00h, 16h, 1Dh, 80h, 01h, 60h
		db	0D8h, 40h, 16h, 0Ch, 8Ch, 01h
		db	 01h, 3Dh, 80h, 00h, 13h, 98h
		db	 00h, 01h, 21h, 80h, 00h, 1Ah
		db	 18h, 00h, 01h,0A0h, 80h, 00h
		db	 1Ah, 08h, 00h, 01h,0A1h, 80h
		db	 00h, 0Ah, 0Ch, 00h, 00h,0A1h
		db	0C0h, 00h, 0Ah, 1Ch, 00h, 00h
		db	0D1h,0C0h, 00h, 0Fh, 3Ch, 00h
		db	 00h,0FBh,0C0h, 00h, 0Fh,0BCh
		db	 00h, 00h,0FFh,0C0h, 00h, 0Fh
		db	0FCh, 00h, 00h,0FFh,0E0h, 00h
		db	 0Fh,0FEh, 00h, 00h,0EFh,0E0h
		db	 00h, 0Fh,0FFh, 00h, 00h,0FFh
		db	0F0h, 00h, 0Fh,0FFh, 80h, 01h
		db	0F7h,0F8h, 00h, 1Fh,0FEh, 80h
		db	 01h,0FBh,0ECh, 00h, 3Fh, 3Eh
		db	0C0h, 03h,0FBh,0CEh, 00h, 7Fh
		db	0FCh,0E8h, 1Eh,0FBh, 4Dh, 81h
		db	0AFh, 74h,0F8h, 1Eh,0F7h, 4Ah
		db	 81h,0EFh, 76h,0F8h, 1Eh,0D2h
		db	 6Dh, 81h,0EFh, 26h,0F8h, 3Ch
		db	0E2h,0EBh, 83h,0CDh,0BEh,0B8h
		db	 3Dh,0DBh,0FAh, 83h,0FBh,0BFh
		db	0C8h, 3Fh, 61h,0FCh, 86h,0D6h
		db	 1Fh,0C8h, 7Fh, 89h,0BCh, 86h
		db	0F1h, 9Bh, 8Ch, 5Fh, 1Dh,0B8h
		db	0C5h,0E1h,0BBh, 8Ch, 5Eh, 3Bh
		db	0B8h,0C5h,0E7h,0FBh, 84h, 5Ch
		db	 1Fh,0F4h, 45h,0C3h,0FFh,0E4h
		db	0F8h, 3Fh,0FCh, 4Fh, 87h,0FFh
		db	0F4h,0F8h, 7Fh,0FFh, 4Fh, 0Dh
		db	0FFh,0E4h,0F0h,0DFh,0FEh, 4Fh
		db	 1Fh,0FFh,0C4h,0F1h, 9Fh,0FCh
		db	 4Fh, 39h,0F7h,0A4h,0F3h,0BFh
		db	 7Ah, 4Fh, 3Bh,0F7h,0A4h,0F3h
		db	0BFh
		db	72h
loc_1:
		dec	di
		cmp	si,di
loc_2:
		db	 64h,0F3h,0BFh, 7Bh
loc_3:
		dec	di
		jnp	loc_1			; Jump if not parity
		jl	loc_2			; Jump if <
		mov	bh,57h			; 'W'
		iret				; Interrupt return
			                        ;* No entry point to code
		jnp	loc_3			; Jump if not parity
		cmp	al,0F7h
		mov	cx,0CF67h
		call	dword ptr ds:data_8e[si]	;*
		stc				; Set carry flag
		les	cx,dword ptr [di-42h]	; Load seg:offset ptr
		cbw				; Convrt byte to word
		test	bl,bl
;*		jmp	far ptr loc_10		;*
		db	0EAh
		dw	4D88h, 0E83Eh		;  Fixup - byte match
			                        ;* No entry point to code
		test	dl,bl
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		ror	byte ptr [di+3Eh],1	; Rotate
		int	4			; Overflow
		db	0DFh,0FCh, 50h
data_3		db	4Ch			; Data table (indexed access)
		db	0F3h, 46h, 04h,0CBh, 0Dh,0E0h
		db	 4Ch,0A0h, 7Eh, 04h,0EAh, 47h
		db	 40h,0CEh,0B0h, 76h, 0Ch,0EAh
		db	 07h, 40h, 8Eh,0E4h, 76h, 08h
		db	0F5h,0C7h, 60h, 87h,0D8h, 66h
		db	 08h, 77h, 06h, 60h, 87h,0F4h
		db	 62h, 08h, 7Fh, 46h, 61h, 45h
		db	 8Ch,0A2h, 14h, 29h,0A2h, 61h
		db	0C2h, 9Fh,0A2h, 1Ch, 29h,0FEh
		db	 61h,0A2h, 9Fh,0A6h, 1Ah, 28h
		db	0FEh, 63h,0A7h,0C7h,0E6h
		db	 7Eh, 7Ch, 7Eh
loc_4:
		db	 6Fh,0E7h,0C7h
loc_5:
		out	0EFh,ax			; port 0EFh ??I/O Non-standard
		jl	$+80h			; Jump if <
		jle	loc_4			; Jump if < or =
		retn
		db	0E6h, 0Fh, 7Eh, 7Eh, 61h,0F7h
		db	0E7h,0E6h, 1Fh, 7Eh, 5Eh,0E2h
		db	0F7h,0E5h,0CEh, 2Fh, 80h, 3Dh
		db	 80h, 00h, 03h, 98h, 00h, 00h
		db	 29h, 80h, 00h, 02h, 18h, 00h
		db	 00h, 20h, 00h, 00h, 02h,0DDh
		db	 00h, 00h, 21h, 80h, 00h, 02h
		db	 08h, 00h, 00h, 21h, 80h, 00h
		db	 02h, 18h, 00h, 00h, 51h, 80h
		db	 00h, 07h, 3Ch, 00h, 00h,0FBh
		db	 80h, 00h, 07h,0BCh, 00h, 00h
		db	0FFh, 80h, 00h, 0Fh,0FCh, 00h
		db	 00h,0FFh,0C0h, 00h, 0Fh,0FEh
		db	 00h, 00h,0EFh,0E0h, 00h, 0Fh
		db	0BEh, 00h, 00h,0FFh,0F0h, 00h
		db	 0Fh,0FFh, 00h, 00h,0D7h,0F8h
		db	 00h, 1Fh, 3Fh, 80h, 01h,0FFh
		db	0F8h, 00h, 1Fh,0FFh, 80h, 03h
		db	0FFh, 78h, 00h, 3Fh,0F7h, 80h
		db	 03h
data_4		db	0FBh
		db	 78h, 00h, 3Fh, 77h, 80h, 03h
		db	0FFh, 78h, 00h, 3Fh,0F7h, 80h
		db	 03h,0FEh, 78h, 00h, 7Fh,0E7h
		db	 80h, 05h,0EEh,0F8h, 00h, 5Dh
		db	0FFh, 80h, 07h,0FFh,0F8h, 00h
		db	 7Fh,0FFh, 00h, 07h, 7Fh,0F0h
		db	 00h, 7Eh,0FFh, 00h, 07h, 8Fh
		db	0B0h, 00h, 71h,0FBh, 00h, 07h
		db	 1Fh,0B0h, 00h, 63h,0FBh, 00h
		db	 06h, 7Fh,0F0h, 00h, 67h,0FEh
		db	 00h, 04h, 3Fh,0E0h, 00h, 43h
		db	0FEh, 00h, 08h, 7Fh,0E0h, 00h
		db	 87h,0FEh, 00h, 08h,0FBh,0E0h
		db	 01h
		db	0Dh

locloop_6:
		inc	byte ptr [bx+si]
		adc	bl,bh
		loopnz	$+3			; Loop if zf=0, cx>0

		aas				; Ascii adjust
		cld				; Clear direction
		add	[bp+di],dl
		lahf				; Load ah from flags
		db	0C0h, 01h, 39h,0F4h, 00h, 13h
		db	0BFh, 40h, 01h, 3Bh,0F4h, 00h
		db	 1Bh,0BFh, 40h, 01h,0FBh,0F4h
		db	 00h, 13h,0BBh, 40h, 01h, 3Bh
		db	0F4h, 00h, 15h,0BFh, 40h, 01h
		db	 5Bh,0FCh, 00h, 15h,0F9h,0C0h
		db	 00h,0DFh, 9Ch, 00h, 01h,0F9h
		db	 80h, 00h, 1Fh, 90h, 00h, 01h
		db	0EEh, 00h, 00h, 1Eh,0C0h, 00h
		db	 01h,0ECh, 00h, 00h, 1Fh, 80h
		db	 00h, 01h,0F8h, 00h, 00h, 13h
		db	 00h, 00h, 01h, 08h, 00h, 00h
		db	 26h, 40h, 00h, 00h, 44h, 00h
		db	 00h, 30h, 40h, 00h, 02h, 64h
		db	 00h, 00h, 24h, 40h, 00h, 07h
		db	0C4h, 00h, 00h, 78h, 40h, 00h
		db	 07h, 6Ch, 00h, 00h,0F4h,0C0h
		db	 00h, 0Fh, 4Ch, 00h, 01h,0EEh
		db	 80h, 00h, 29h,0E0h, 00h, 03h
		db	 9Ch, 00h, 00h, 39h,0C0h, 00h
		db	 02h, 9Ch, 00h, 00h, 68h,0E0h
		db	 00h, 07h,0CEh, 00h, 00h, 7Ch
		db	 60h, 00h, 07h,0C7h, 00h, 00h
		db	 7Ch, 70h, 00h, 07h,0C3h, 00h
		db	 00h, 7Eh, 70h, 00h, 05h,0E7h
		db	 00h, 00h, 7Eh, 50h, 40h, 07h
		db	0EFh, 8Ch, 00h,0C0h, 03h,0C7h
		db	 20h, 2Bh, 9Ah,0AAh,0B8h, 60h
		db	 03h,0C7h, 80h, 56h, 48h, 2Ah
		db	0B0h, 60h, 03h,0C3h,0C0h, 5Ch
		db	 9Ah, 0Ah,0AAh,0B8h, 60h, 01h
		db	0E1h,0E0h, 5Ch, 48h, 2Ah,0AAh
		db	0B0h, 30h, 01h,0E0h,0F0h,0B8h
		db	 9Ah,0AAh,0AAh,0C0h, 30h, 01h
		db	0E0h, 78h,0B8h, 48h, 02h,0EEh
		db	0ABh, 0Ch, 01h,0E0h, 6Ch,0B8h
		db	 9Ah,0ABh, 92h,0ADh, 40h, 53h
		db	0F0h, 96h,0B8h, 4Ah,0AEh,0BAh
		db	0A6h, 80h, 23h, 80h,0F1h, 08h
		db	 78h, 9Ah, 91h, 2Ah,0A9h, 50h
		db	 40h, 80h, 6Eh, 01h, 28h, 05h
		db	 08h, 6Ah
data_5		db	0C0h
		db	 80h, 82h,0C0h, 38h,0AAh, 80h
		db	 40h, 04h, 01h, 01h, 60h, 1Dh
		db	 14h, 72h, 20h, 82h, 08h, 02h
		db	 03h, 70h, 0Ch, 0Ah,0CCh, 40h
		db	 10h, 15h, 01h, 30h, 06h,0D2h
		db	 08h, 02h, 22h, 82h, 48h, 06h
		db	 44h, 05h, 01h,0A4h, 41h, 18h
		db	 06h, 12h,0B8h, 2Ah, 8Ch, 04h
		db	 8Ah, 01h,0AAh,0A4h, 15h, 40h
		db	0C0h, 0Fh, 60h, 1Dh,0D3h,0ECh
		db	 22h, 08h,0B0h, 1Eh, 14h,0C0h
		db	 12h,0C7h, 83h, 84h, 11h, 10h
		db	 16h, 14h, 02h,0DBh,0EAh,0C0h
		db	 01h,0DCh, 08h, 88h, 02h, 30h
		db	 14h, 78h,0C3h,0E9h, 82h, 40h
		db	0E4h, 0Bh, 44h, 02h, 33h, 69h
		db	0EAh, 20h,0B8h,0A8h, 04h,0CCh
		db	 05h, 02h, 01h, 03h, 30h, 03h
		db	 7Eh,0C0h, 1Bh, 0Ah,0F0h, 03h
		db	 89h, 55h, 7Ch, 1Bh, 4Fh, 1Ch
		db	 01h, 40h,0A1h,0B0h, 02h, 01h
		db	 55h, 4Eh,0D2h, 22h,0E8h, 03h
		db	 90h, 22h, 51h, 98h, 02h, 55h
		db	 55h, 58h, 60h, 03h,0E8h, 5Ah
		db	 74h, 18h, 61h,0D0h, 56h,0A3h
		db	 5Ch, 04h, 85h, 55h, 48h, 06h
		db	0C1h, 21h, 5Eh, 30h, 18h,0FCh
		db	 0Ch, 1Fh, 8Ch, 24h,0A6h, 15h
		db	 55h, 58h, 03h, 18h, 07h, 45h
		db	 4Bh, 0Ch, 1Ah,0B0h, 06h, 56h
		db	 18h, 24h, 06h,0CCh, 05h, 55h
		db	 60h,0C0h, 01h, 80h, 09h, 15h
		db	 76h, 04h, 04h,0C0h,0CBh,0ECh
		db	 1Ah, 4Ch, 15h, 55h, 70h, 30h
		db	 06h, 12h, 05h, 66h, 16h, 07h
		db	0C0h, 24h, 0Fh,0E8h, 6Bh, 98h
		db	 05h, 55h, 60h, 18h, 0Ch, 48h
		db	 15h, 73h, 04h, 08h, 06h, 9Eh
		db	0E1h,0ABh, 18h, 01h, 55h, 70h
		db	 0Ch, 0Ch,0C0h, 55h, 4Bh, 03h
		db	 10h, 40h, 87h,0A3h,0A9h, 31h
		db	0B0h, 55h, 60h, 0Ch, 30h,0CAh
		db	 15h, 59h, 9Ah, 70h, 11h, 01h
		db	0AEh, 66h,0B9h, 55h, 20h, 0Ch
		db	0C0h, 01h, 80h, 55h, 5Ch, 11h
		db	 05h, 06h,0B8h,0D9h,0ECh, 55h
		db	 60h, 0Ch, 03h, 03h, 15h, 70h
		db	 88h, 04h,0B1h,0BFh, 8Fh, 55h
		db	 80h, 18h, 06h, 03h, 55h,0C5h
		db	 2Eh,0C3h, 7Dh, 5Fh, 55h,0C0h
		db	 18h, 18h, 06h, 01h, 57h, 27h
		db	 09h, 56h, 55h, 03h,0E0h,0BCh
		db	0D0h, 80h, 0Ch, 60h, 04h, 80h
		db	 48h, 40h, 01h, 0Ah, 08h,0BFh
		db	0EDh, 99h, 0Ch,0C0h, 05h,0C1h
		db	 73h, 55h, 48h, 0Ah,0D5h, 57h
		db	 82h, 06h, 01h, 80h, 0Ch, 05h
		db	0C4h, 04h, 1Fh,0D5h, 74h, 44h
		db	 03h, 03h, 0Ch, 01h,0A5h, 52h
		db	 2Eh, 15h, 64h, 88h, 03h, 06h
		db	 0Ch, 56h, 40h, 01h, 35h, 52h
		db	 39h, 10h, 01h, 80h, 0Ch, 0Ch
		db	0ADh,0D5h,0DDh, 55h, 00h, 60h
		db	 25h, 50h, 22h, 20h,0C0h, 18h
		db	 0Dh, 24h, 40h, 01h, 75h, 20h
		db	 44h, 40h,0C0h, 30h, 0Fh, 0Dh
		db	 55h, 55h, 58h, 28h, 02h,0F5h
		db	 02h, 08h, 80h, 60h, 60h, 01h
		db	 04h, 04h, 40h, 35h, 84h, 11h
		db	 30h,0C0h, 09h,0DDh, 55h, 01h
		db	 56h, 02h,0F5h, 20h, 22h, 30h
		db	0C0h, 40h, 40h, 32h, 40h, 44h
		db	 18h, 01h, 80h, 07h,0DDh, 55h
		db	 01h, 58h, 02h,0F0h, 80h, 88h
		db	 18h, 01h, 80h, 10h, 40h, 05h
		db	 35h,0C1h, 10h, 0Ch, 01h, 80h
		db	 95h,0DDh, 55h, 00h, 56h, 02h
		db	0F5h, 72h, 20h, 0Ch, 01h, 80h
		db	 01h, 10h, 05h, 95h, 61h, 40h
		db	 0Ch, 03h, 07h, 55h, 55h, 57h
		db	 50h, 0Ah,0D5h, 22h, 80h, 06h
		db	 03h, 04h, 01h,0A0h, 45h,0D5h
		db	 65h, 06h, 06h, 03h, 55h, 55h
		db	 54h, 80h, 04h, 40h, 82h,0D5h
		db	 20h, 06h, 0Ch, 04h, 01h, 78h
		db	 1Eh, 08h, 0Ah, 81h, 07h, 55h
		db	 60h, 03h, 18h, 07h, 55h, 55h
		db	 52h,0FAh, 63h, 04h, 14h, 06h
		db	 0Ah, 55h, 20h, 03h, 18h, 01h
		db	 04h,0C4h, 46h, 02h, 28h, 09h
		db	 13h, 55h, 60h, 03h, 18h, 01h
		db	0D5h, 54h, 20h, 01h, 80h, 06h
		db	 01h, 44h, 12h, 0Fh, 55h, 20h
		db	 03h, 18h, 10h, 01h, 01h, 58h
		db	 30h, 08h, 0Ch, 19h, 55h, 60h
		db	 03h, 18h, 50h, 1Bh, 04h, 12h
		db	 2Dh, 55h, 20h, 03h, 18h, 1Eh
		db	 01h,0B0h, 04h, 5Dh, 55h,0C0h
		db	 03h, 30h, 47h,0A2h, 40h,0ADh
		db	 55h, 80h, 06h, 30h, 02h, 02h
		db	 91h, 9Dh, 54h, 80h, 06h, 30h
		db	 10h, 1Bh, 22h, 17h, 57h, 06h
		db	 30h, 20h, 1Eh, 01h, 13h,0C8h
		db	 06h, 30h, 40h, 3Ch, 29h, 06h
		db	 30h, 80h, 0Ah, 16h, 06h, 30h
		db	 01h, 4Fh, 10h, 04h, 0Ch, 30h
		db	 0Dh, 80h, 02h, 2Ah, 0Ch, 30h
		db	 01h, 98h, 01h,0F4h, 0Ch, 30h
		db	 1Ch, 80h, 84h,0C0h, 0Ch, 30h
		db	 96h, 13h, 80h, 18h, 18h,0D5h
		db	 20h,0DDh, 18h, 00h,0DDh, 55h
		db	 01h, 48h, 30h, 18h,0D5h, 55h
		db	 57h, 60h, 0Ch, 03h, 55h, 55h
		db	 54h, 80h,0C0h, 0Ch, 0Ch, 55h
		db	 54h,0DDh, 55h, 00h, 20h, 01h
		db	 80h, 06h, 01h,0D5h, 55h, 55h
		db	 60h, 03h, 03h, 02h,0DDh, 55h
		db	 00h, 70h, 06h, 01h, 80h, 01h
		db	0D5h,0DDh, 55h, 00h, 60h, 0Ch
		db	0C0h,0D5h,0DDh, 55h, 01h, 80h
		db	 0Ch, 60h, 4Eh, 01h,0D5h, 55h
		db	 56h, 06h, 30h, 02h, 55h, 55h
		db	 52h, 03h, 18h, 1Dh, 55h, 55h
		db	0C0h,0C0h, 06h,0D5h, 20h, 30h
		db	 18h, 01h,0B1h,0B0h, 1Ch, 80h
		db	 0Ch, 30h, 03h, 36h, 6Fh, 01h
		db	0E0h, 82h, 03h, 60h, 05h, 01h
		db	 28h,0D9h, 41h,0C0h,0EBh,0C7h
		db	 80h, 1Bh, 8Bh, 60h, 08h, 80h
		db	 60h, 01h,0FBh, 6Dh, 80h, 0Ah
		db	 78h, 01h, 40h, 30h, 03h,0DFh
		db	 43h, 3Eh, 80h, 88h, 0Ch, 03h
		db	0CEh, 41h, 20h, 03h, 60h, 11h
		db	 06h, 07h, 8Ch, 65h,0C0h, 78h
		db	0A8h, 80h, 01h, 80h, 07h, 86h
		db	 3Dh, 40h, 1Eh, 33h, 01h, 40h
		db	0C0h, 07h, 86h, 06h,0C6h,0C0h
		db	 0Ah, 30h, 07h, 8Ch, 1Eh,0A3h
		db	 60h, 04h, 40h, 18h, 07h, 8Ch
		db	 06h,0C1h,0B0h, 02h, 20h, 0Ch
		db	 03h,0D8h,0F1h, 38h, 01h, 10h
		db	 14h, 06h, 03h,0D8h,0A0h,0CCh
		db	 28h, 02h, 02h, 03h, 03h, 33h
		db	 03h, 64h, 40h, 02h,0E0h, 03h
		db	 36h, 01h,0E0h, 02h,0E0h, 03h
		db	 63h, 02h,0E0h, 01h, 80h, 66h
		db	 02h,0B0h, 01h, 80h, 63h, 30h
		db	 01h, 80h, 66h, 0Ch, 01h, 80h
		db	 63h, 05h, 53h,0C0h, 66h, 23h
		db	 80h,0C0h, 63h, 0Ah, 40h, 80h
		db	 60h, 36h, 14h, 82h,0C0h, 30h
		db	 0Ah, 14h, 79h, 01h, 60h, 18h
		db	0A4h, 23h, 28h, 01h,0E2h, 03h
		db	 70h, 0Dh, 12h, 41h, 8Eh, 40h
		db	 07h, 95h, 01h, 30h, 06h, 3Eh
		db	 40h,0D4h,0A0h, 36h, 22h, 82h
		db	 48h, 04h,0D8h, 42h, 48h, 80h
		db	 09h, 25h,0A4h, 41h, 18h, 07h
		db	 52h,0B0h, 95h, 1Eh, 22h, 52h
		db	0BBh,0EAh, 8Ch, 04h, 72h, 31h
		db	 7Dh, 7Bh, 31h,0AAh,0A6h, 95h
		db	 40h,0C0h, 0Fh, 60h, 73h, 11h
		db	 40h, 1Dh,0D3h,0EDh, 62h, 08h
		db	0B0h, 1Eh, 14h,0C0h, 12h,0EFh
		db	0FBh, 85h, 51h, 10h, 16h, 14h
		db	 02h,0DBh,0EAh,0C0h, 36h,0EAh
		db	0DEh, 88h, 88h, 02h, 30h, 14h
		db	 78h,0C3h,0E9h, 82h, 4Ch, 54h
		db	 64h, 0Bh, 44h, 02h, 33h, 69h
		db	0FEh, 3Bh,0B8h,0A8h, 05h, 94h
		db	 0Ch, 05h, 02h, 01h, 03h, 30h
		db	 03h, 7Eh,0C0h, 06h,0DBh, 0Ah
		db	0C0h, 33h,0C0h, 03h, 88h, 01h
		db	 7Ch, 1Bh, 1Fh, 16h, 04h, 38h
		db	0A0h, 78h,0C0h, 36h, 60h, 02h
		db	 04h, 4Eh,0D2h, 22h,0F0h,0C9h
		db	 88h,0F0h, 02h, 9Bh, 30h, 02h
		db	 40h, 18h, 60h, 03h,0E8h, 0Ah
		db	 78h,0D8h, 4Bh, 1Bh, 5Fh, 30h
		db	 04h, 80h, 1Ch,0E6h,0C1h, 20h
		db	 1Eh, 3Dh, 98h,0F6h, 30h, 88h
		db	 25h,0E0h, 06h, 1Bh, 06h, 03h
		db	 18h,0F7h
		db	40h

locloop_7:
		sbb	cx,[si]
		sbb	data_5,cl
		adc	[di],ah
		inc	ax
		or	al,34h			; '4'
		add	byte ptr [bp+di],0C0h
		add	ds:data_7e[bx+si],ax
		db	 36h, 04h, 04h, 38h, 1Ch,0CBh
		db	0ECh, 0Ch, 32h, 40h, 02h, 70h
		db	 06h, 60h,0D2h, 36h, 16h, 07h
		db	0FCh, 24h, 0Fh,0E8h, 18h, 34h
		db	 20h, 02h, 40h,0B8h, 0Ch, 60h
		db	 01h,0C8h, 33h, 04h, 08h, 06h
		db	0C6h, 9Eh,0E0h, 18h, 32h, 70h
		db	 0Ch, 0Ch, 30h, 03h,0C0h, 1Bh
		db	 03h, 30h, 0Fh, 0Ch, 87h,0A0h
		db	 31h,0B0h, 64h, 04h,0C0h, 18h
		db	 0Ch, 37h,0B0h,0A9h,0CAh, 19h
		db	 9Bh,0C6h,0D1h, 66h,0B8h, 62h
		db	 2Ch, 03h, 0Ch,0D8h,0DAh,0AFh
		db	 80h, 0Ch, 18h, 30h,0C0h, 1Dh
		db	0D9h,0ECh, 64h, 20h, 03h, 18h
		db	0CCh, 03h, 7Eh, 66h,0AFh, 30h
		db	0C3h, 30h, 0Ch, 01h,0BEh,0CEh
		db	0C9h, 08h, 13h, 78h, 06h,0CFh
		db	 34h,0A7h,0C6h, 0Ch, 01h, 80h
		db	 06h, 28h, 03h, 7Dh, 5Fh,0D2h
		db	 10h, 02h, 18h, 1Bh, 07h, 9Bh
		db	0BEh, 03h, 33h, 0Ch, 03h,0C0h
		db	 03h, 50h, 09h,0F5h, 5Dh, 81h
		db	0A4h, 80h, 4Ch, 66h, 03h,0CDh
		db	0B4h, 80h, 18h,0C0h, 03h, 01h
		db	 80h, 01h, 80h, 1Ch,0EAh,0BDh
		db	0C1h,0C1h, 64h, 2Ch,0D8h, 03h
		db	 36h, 55h,0C0h, 33h, 01h, 83h
		db	0C0h, 1Eh,0D5h, 57h,0C3h, 83h
		db	 88h, 16h, 01h,0B0h,0DBh, 0Ch
		db	0CCh, 18h, 30h, 60h, 1Fh, 80h
		db	 2Eh,0C7h, 16h, 10h, 0Bh, 03h
		db	0C0h, 02h,0E8h, 8Ch, 01h,0B0h
		db	 06h, 60h, 30h, 3Ah, 07h, 9Ah
		db	 38h, 80h, 07h, 07h, 80h, 95h
		db	 0Ch, 56h, 60h, 03h, 60h, 18h
		db	 30h, 0Fh, 34h, 71h, 03h, 80h
		db	 0Fh, 02h,0B8h, 8Ch,0ADh, 80h
		db	 05h, 02h, 80h, 0Dh, 70h, 1Eh
		db	 68h,0E2h, 04h,0C0h, 1Eh, 0Ah
		db	0BCh, 4Dh, 26h, 61h, 80h, 14h
		db	 27h,0F0h, 3Ch,0D1h,0C4h, 02h
		db	0C0h, 3Ch, 02h,0B0h, 0Fh, 18h
		db	 60h, 37h, 8Ah, 5Fh, 1Ah,0E0h
		db	 79h,0A3h, 88h, 01h, 60h, 78h
		db	 0Ah,0B8h, 01h, 80h, 0Ch, 06h
		db	 0Fh, 14h, 50h, 2Ah, 9Ah,0E0h
		db	0F3h, 47h, 04h,0B0h,0F0h, 2Ah
		db	 47h, 8Ch, 6Ch, 28h,0AAh, 16h
		db	 8Eh,0E0h, 01h,0E6h, 8Eh, 61h
		db	 70h,0F0h,0ACh,0CCh, 60h, 03h
		db	 48h,0A3h,0C5h, 15h, 4Eh,0E0h
		db	 03h,0CDh, 1Ch, 06h, 60h, 40h
		db	 38h, 01h,0E0h, 31h,0ECh,0C6h
		db	 61h, 25h, 0Fh, 05h, 29h, 4Eh
		db	0E0h, 07h, 9Ah, 38h, 36h, 08h
		db	 08h, 01h,0DFh,0CCh, 63h, 18h
		db	 0Ch, 21h, 28h, 66h, 5Fh,0F1h
		db	 5Fh,0E0h, 07h,0B4h, 58h,0F0h
		db	 40h, 20h, 20h, 2Ch, 01h, 9Dh
		db	0D5h, 8Ch,0C0h, 64h, 21h, 4Ch
		db	 1Bh,0FAh, 63h,0DFh,0E0h, 0Fh
		db	 68h,0B3h,0C2h, 01h, 30h, 80h
		db	 1Ch, 01h,0B2h,0BCh, 1Bh, 01h
		db	0A1h, 6Fh, 7Fh, 99h,0E7h,0BFh
		db	0C0h, 0Fh,0D1h, 3Fh, 10h, 23h
		db	 04h, 2Ch, 03h, 7Eh, 50h, 6Ch
		db	 0Dh, 08h,0FDh,0F4h,0C3h,0CFh
		db	 7Bh,0C0h, 0Fh,0CAh, 5Ch, 21h
		db	 30h, 20h, 16h, 02h,0BDh,0E0h
		db	0D8h, 0Ch, 08h, 40h, 01h, 73h
		db	 50h, 25h,0ECh,0A7h, 80h, 1Fh
		db	 94h, 31h, 09h, 81h, 0Eh, 07h
		db	0D7h, 81h,0B0h,0C4h, 02h, 4Eh
		db	 78h, 60h, 66h,0C7h, 80h, 1Dh
		db	 22h, 62h, 4Ch, 08h, 16h, 0Fh
		db	0AFh, 03h, 60h, 01h,0D8h, 10h
		db	0C4h,0BCh, 18h, 01h, 8Fh, 18h
		db	 14h,0C4h, 98h, 40h, 0Bh, 1Fh
		db	 7Ch, 03h, 60h, 03h, 7Ch, 20h
		db	 01h, 24h, 9Eh, 18h, 03h, 0Fh
		db	 18h, 23h, 89h, 30h, 20h, 07h
		db	 1Eh, 78h, 06h,0C0h, 06h, 7Ah
		db	 40h, 02h,0F1h,0CFh, 18h, 03h
		db	 1Eh, 18h, 47h, 12h, 03h, 04h
		db	 0Bh, 1Eh,0F0h, 06h,0C0h, 19h
		db	 28h, 80h, 05h, 32h,0B7h,0B0h
		db	 06h, 1Eh, 18h, 29h,0A4h,0C2h
		db	 07h, 1Fh,0E0h, 06h,0C0h, 31h
		db	 2Eh, 40h, 15h, 71h, 5Bh,0F0h
		db	 06h, 3Ch, 18h, 46h, 08h, 80h
		db	 87h, 0Bh, 1Fh,0E0h, 06h,0C0h
		db	 61h, 05h, 85h, 05h, 90h, 5Dh
		db	 20h, 06h, 3Ch, 18h, 29h, 10h
		db	0C0h, 85h, 14h, 07h, 1Dh,0C0h
		db	 06h, 60h, 01h, 81h, 06h, 45h
		db	 1Eh, 9Dh, 81h,0B0h, 06h, 78h
		db	 18h, 14h, 03h, 40h,0A8h, 80h
		db	 0Bh, 3Fh,0C0h, 06h, 90h, 03h
		db	 01h, 05h, 85h, 3Dh, 38h,0A0h
		db	0C1h,0F8h, 18h, 0Ch, 03h, 04h
		db	 10h, 40h, 16h, 3Ah,0C0h, 06h
		db	 48h, 0Ch, 01h, 07h, 0Ah, 7Ah
		db	 70h, 02h, 80h, 01h, 98h, 18h
		db	 03h, 0Ch, 88h, 20h, 0Eh, 3Ah
		db	0C0h, 06h, 24h, 18h, 01h, 05h
		db	 8Ah,0FEh,0E0h, 05h, 1Eh, 18h
		db	 60h, 20h, 23h, 41h, 40h, 16h
		db	 3Ah,0C0h, 03h, 10h, 80h, 90h
		db	 04h, 07h, 14h, 51h,0FDh,0C0h
		db	 0Fh, 07h, 80h, 63h, 04h, 0Eh
		db	 38h,0E0h, 01h, 88h, 20h, 04h
		db	 07h, 14h,0A3h,0F1h, 80h, 1Eh
		db	 01h,0E6h, 60h, 20h, 16h, 38h
		db	0E0h,0C4h, 01h, 04h, 2Fh, 29h
		db	0E6h,0B7h, 1Eh, 06h, 06h, 01h
		db	 0Eh, 39h,0F0h, 62h, 08h, 10h
		db	 2Fh, 30h,0C7h, 6Eh, 14h, 0Ch
		db	 0Ch, 08h, 1Ch, 39h,0F0h, 18h
		db	 11h, 7Eh, 79h, 94h, 60h, 6Ch
		db	 0Ch, 0Ch,0C3h, 40h, 2Ch, 39h
		db	 78h, 0Ch, 40h,0BCh,0CCh, 18h
		db	0C0h, 79h, 8Ch, 0Ch,0C0h, 02h
		db	 1Ch, 3Eh,0BCh, 06h, 45h,0F8h
		db	0FDh, 81h, 86h,0FCh,0C0h, 01h
		db	0B0h, 10h, 2Ch, 3Eh,0BCh, 01h
		db	 80h, 01h, 13h,0F0h,0F3h, 18h
		db	 06h, 19h,0FCh, 80h, 78h, 20h
		db	 08h, 1Eh, 1Eh,0C0h, 05h, 07h
		db	0D0h,0C0h, 18h, 30h, 3Ch, 01h
		db	 38h, 1Eh, 1Eh, 30h, 1Bh, 18h
		db	 06h, 06h, 02h, 08h, 1Eh, 08h
		db	 70h, 1Eh, 0Fh, 21h, 6Fh, 0Dh
		db	 80h, 10h, 01h, 0Fh, 10h,0E0h
		db	 0Fh, 07h, 80h, 10h, 70h, 03h
		db	 06h,0C0h, 20h, 2Dh, 01h,0C0h
		db	 0Fh, 03h,0C0h, 02h, 4Ah, 0Ch
		db	 03h, 60h, 40h, 02h, 80h, 03h
		db	 80h, 07h, 80h,0F0h, 01h,0FEh
		db	 03h, 30h, 80h, 05h, 07h, 03h
		db	0C0h,0D8h, 02h, 05h, 86h, 03h
		db	 03h, 30h, 40h, 02h, 80h, 0Eh
		db	 01h,0E0h, 36h, 04h, 26h, 01h
		db	 81h, 80h, 03h, 18h, 80h, 01h
		db	 40h, 1Ch,0F0h,0ACh, 40h, 04h
		db	 18h, 61h, 80h, 03h, 08h, 02h
		db	 80h, 2Ch, 78h, 2Ah,0E0h, 60h
		db	 06h, 60h, 06h, 10h, 01h, 40h
		db	 46h, 3Ch,0AAh,0AAh,0DBh,0C0h
		db	 1Eh, 06h, 03h, 0Ch, 08h,0A0h
		db	 83h, 19h,0AAh,0A4h, 67h, 80h
		db	 06h, 06h,0D8h, 60h, 10h, 01h
		db	 40h, 01h,0C0h, 06h, 0Ch, 0Fh
		db	 18h,0C0h, 0Ch, 08h,0A0h, 02h
		db	 30h, 1Bh, 1Eh, 01h, 98h, 18h
		db	 10h, 01h, 40h, 04h, 50h, 0Ch
		db	 1Eh, 1Eh, 0Dh, 80h,0C0h, 12h
		db	 03h, 41h, 08h,0A0h, 09h, 40h
		db	 03h, 3Ch, 1Eh, 3Ch, 60h, 6Ch
		db	 89h, 81h,0A0h, 80h, 10h, 01h
		db	 40h, 45h, 50h,0C0h, 44h, 1Eh
		db	 18h, 63h,0C1h, 93h,0B1h,0C1h
		db	 08h, 02h, 80h, 81h, 54h, 60h
		db	0B4h, 1Eh, 01h,0E0h, 39h, 32h
		db	0A0h, 80h, 10h, 01h, 40h, 10h
		db	 55h, 50h, 30h, 01h, 55h, 41h
		db	 4Fh, 28h,0D8h, 0Dh, 83h, 10h
		db	 40h, 08h, 02h, 80h, 08h, 01h
		db	 55h, 54h, 15h, 4Ch, 01h, 41h
		db	 41h, 4Fh, 28h, 36h, 03h, 30h
		db	0E0h, 80h, 10h, 04h, 40h, 40h
		db	 05h, 55h, 40h, 10h, 05h, 56h
		db	 02h, 8Ah,0A0h,0A7h, 94h, 0Ch
		db	0C1h, 2Ch,0D0h, 40h, 08h, 08h
		db	 80h, 20h, 15h, 55h, 55h, 04h
		db	 15h, 55h, 80h, 02h, 80h,0A0h
		db	0A3h,0CAh, 03h, 18h,0EBh, 68h
		db	 20h, 10h, 10h, 41h, 11h, 55h
		db	 55h, 54h, 04h, 05h, 55h,0C0h
		db	 02h, 85h, 50h, 51h,0E5h,0C3h
		db	 2Bh, 10h, 10h, 08h, 20h, 01h
		db	 05h, 55h, 55h, 70h, 02h, 8Ah
		db	 28h, 28h,0F2h, 80h, 50h, 19h
		db	 94h, 68h, 08h, 10h, 40h, 04h
		db	 08h, 80h, 45h, 55h, 48h, 02h
		db	 8Ah, 14h
data_6		db	1Eh			; Data table (indexed access)
		db	 79h, 40h, 28h, 03h, 30h, 34h
		db	 10h, 20h, 80h, 04h, 80h, 81h
		db	 15h, 55h, 4Ch, 01h, 54h, 1Eh
		db	 07h, 9Eh,0A0h, 1Eh,0D8h, 1Ah
		db	 20h, 40h, 01h, 36h, 10h, 02h
		db	 81h, 55h, 55h, 56h, 01h, 54h
		db	 0Dh, 81h,0E5h, 50h, 0Fh, 36h
		db	0ADh, 12h, 23h, 06h, 10h, 20h
		db	 84h, 15h, 55h, 57h,0C0h, 33h
		db	 03h, 36h,0C0h, 02h, 80h, 36h
		db	 03h, 60h, 02h, 80h, 63h,0A0h
		db	 02h, 80h, 66h, 02h, 80h, 63h
		db	 66h, 63h, 05h, 50h, 66h, 22h
		db	 63h, 0Ah, 41h, 36h, 14h, 82h
		db	 0Ah, 14h, 79h, 01h,0A4h, 40h
		db	 28h, 01h,0E2h, 03h, 40h, 01h
		db	 12h,0F8h, 0Eh, 40h, 07h, 95h
		db	 01h, 3Eh, 80h, 14h,0A0h, 36h
		db	 22h, 82h, 50h, 02h,0D8h, 80h
		db	 08h, 80h, 09h, 25h,0A4h, 41h
		db	 01h, 52h,0C0h, 15h, 1Eh, 22h
		db	 52h,0B9h, 6Ah, 80h, 02h, 72h
		db	 20h, 7Dh, 7Bh, 31h,0AAh,0A6h
		db	 95h, 40h, 03h, 60h, 73h, 11h
		db	 40h, 1Dh,0D3h,0EDh, 62h, 08h
		db	 80h, 06h, 14h,0C0h, 12h,0C7h
		db	0D3h, 85h, 51h, 10h, 10h, 0Ch
		db	 02h,0DBh,0EAh,0C0h,0ABh,0DEh
		db	 88h, 88h, 02h, 0Ch, 78h,0C3h
		db	0E9h, 82h, 44h, 54h,0E4h, 0Bh
		db	 44h, 02h, 30h, 09h,0EAh, 20h
		db	0B8h,0A8h, 04h, 8Ah, 4Ch, 05h
		db	 02h, 01h, 03h, 7Eh,0C0h, 1Bh
		db	 0Ah, 41h,0F2h, 80h, 03h, 89h
		db	 55h, 70h, 03h, 4Fh, 1Ch, 01h
		db	 68h, 83h,0B4h, 40h, 02h, 01h
		db	 55h, 48h, 12h, 22h,0F9h, 09h
		db	 98h,0B3h, 40h, 05h, 9Ah, 20h
		db	 02h, 55h, 55h, 58h,0E8h, 5Ah
		db	 7Ch, 98h, 49h, 80h, 04h, 73h
		db	 5Dh, 40h, 04h, 85h, 55h, 48h
		db	 01h, 21h, 5Eh, 35h, 18h,0F6h
		db	 30h, 0Ah,0CCh, 24h, 06h, 15h
		db	 55h, 58h, 07h, 45h, 4Bh, 0Ch
		db	 18h, 0Ch, 0Ch, 06h, 18h, 24h
		db	 0Ch, 05h, 55h, 60h, 09h, 15h
		db	 76h, 04h, 04h, 30h, 14h,0CBh
		db	0ECh, 0Ch, 15h, 55h, 70h, 12h
		db	 05h, 66h, 16h, 07h,0D4h, 24h
		db	 0Fh,0E8h, 18h, 05h, 55h, 60h
		db	 48h, 15h, 73h, 04h, 08h, 07h
		db	 55h, 86h, 9Eh,0E0h, 18h, 01h
		db	 55h, 70h,0C0h, 55h, 4Bh, 03h
		db	 30h, 4Bh, 55h, 5Ch, 87h,0A0h
		db	 31h,0B0h, 55h, 60h,0CAh, 15h
		db	 59h, 9Bh, 10h, 86h, 15h, 55h
		db	 91h, 66h,0B9h, 55h, 20h, 01h
		db	 80h, 55h, 5Ch, 19h, 20h,0C0h
		db	 05h, 55h, 4Dh,0D9h,0ECh, 55h
		db	 60h, 03h, 15h, 70h,0D2h, 24h
		db	 01h, 55h, 58h, 01h,0BEh,0CFh
		db	 55h, 80h, 03h, 55h,0C7h, 08h
		db	 01h, 80h, 55h, 56h, 28h, 03h
		db	 7Dh, 5Fh, 55h,0C0h, 06h, 01h
		db	 57h, 33h, 0Ch, 01h, 02h,0C1h
		db	 55h, 57h, 50h, 09h,0F5h, 5Ch
		db	0D0h, 80h, 04h, 80h, 48h,0C0h
		db	 01h, 02h, 01h, 80h, 55h, 54h
		db	 80h, 1Ch,0EAh,0BDh, 99h, 05h
		db	0C1h, 73h, 09h, 02h, 40h, 01h
		db	 55h, 55h, 80h, 1Eh,0D5h, 57h
		db	 82h, 0Ch, 05h,0CCh, 04h, 08h
		db	 24h, 05h, 55h, 55h, 60h, 1Fh
		db	 80h, 2Eh, 44h, 0Ch, 01h,0B0h
		db	 06h, 61h, 55h, 55h, 70h, 3Ah
		db	 06h, 88h, 0Ch, 56h, 60h, 03h
		db	 62h,0D5h, 55h, 48h, 30h, 0Dh
		db	 10h, 0Ch,0ADh, 80h, 27h, 07h
		db	 95h, 55h, 58h, 30h, 1Ah, 20h
		db	 0Dh, 26h, 20h, 41h, 8Fh, 55h
		db	 41h, 75h, 70h, 64h, 40h, 0Fh
		db	 18h, 04h, 20h, 3Dh, 9Eh, 15h
		db	 0Ah, 0Ah,0E0h, 02h, 48h, 80h
		db	 01h, 80h, 0Ch, 06h, 4Bh, 3Ch
		db	 55h, 80h, 10h, 60h, 04h, 91h
		db	 0Ch, 02h, 4Ch, 79h,0EBh, 02h
		db	 8Ah,0E0h, 21h, 22h, 60h, 42h
		db	 49h,0E3h, 6Dh, 15h, 44h, 60h
		db	 42h, 44h, 06h, 08h, 41h, 2Fh
		db	 0Ch,0D8h,0A8h, 0Ah,0E0h, 84h
		db	 88h, 18h, 48h, 21h, 78h, 63h
		db	 60h, 11h, 55h, 60h, 43h, 10h
		db	0C0h, 02h, 44h, 23h,0CCh, 1Bh
		db	 22h, 8Ah,0E0h, 26h, 20h, 03h
		db	 10h,0A1h, 6Fh, 78h, 05h, 15h
		db	 15h,0C0h, 49h, 40h, 06h, 02h
		db	 05h, 08h,0FDh, 40h, 82h, 2Ah
		db	 2Ah,0C0h, 26h, 80h, 0Ch, 01h
		db	 08h, 08h, 40h, 01h, 70h,0A4h
		db	0A4h, 04h, 05h, 80h, 4Dh, 12h
		db	 01h, 84h, 02h, 4Bh,0CCh, 60h
		db	 0Ah, 83h, 80h, 30h, 24h, 03h
		db	 08h, 10h,0C4h,0ECh, 18h, 01h
		db	 07h, 48h, 42h, 06h, 04h, 20h
		db	 01h, 84h,0B6h, 18h, 02h, 0Bh
		db	 30h, 81h, 0Ch, 02h, 40h, 03h
		db	0B1h,0DBh, 18h, 01h, 16h, 48h
		db	 40h, 80h, 30h, 04h, 80h, 05h
		db	0C2h,0BDh,0B0h, 02h, 0Eh, 30h
		db	 80h, 10h, 01h, 20h, 02h, 45h
		db	 15h, 21h, 5Eh,0A0h, 04h, 1Ch
		db	 48h, 40h, 40h, 01h, 85h, 05h
		db	 90h, 5Fh, 02h, 2Ch, 30h, 20h
		db	 80h, 02h, 4Fh, 1Eh, 95h, 01h
		db	0B0h, 04h, 58h, 48h, 10h, 01h
		db	 01h, 8Fh, 3Dh, 28h, 40h,0A0h
		db	0C0h,0B8h, 90h, 08h, 08h, 03h
		db	 1Eh,0DAh, 52h, 02h, 80h, 01h
		db	 98h, 01h, 08h, 04h, 10h, 01h
		db	 9Eh, 01h,0BEh,0B0h, 05h, 1Eh
		db	 02h, 10h, 80h, 80h, 03h, 36h
		db	 53h, 7Dh, 60h, 0Fh, 07h, 90h
		db	 20h, 03h, 6Ch,0A6h,0F0h,0C0h
		db	 1Eh, 01h,0C4h, 03h, 6Dh,0E6h
		db	0B5h, 80h, 1Eh, 06h, 03h,0C0h
		db	 45h, 6Bh, 15h, 10h, 0Ch, 03h
		db	0CDh, 94h, 42h, 6Eh, 04h, 06h
		db	0C4h, 98h, 81h, 7Ch, 80h, 09h
		db	0E8h, 91h, 84h, 80h,0D4h, 10h
		db	 51h, 08h, 46h, 19h,0A8h, 50h
		db	0C0h, 48h, 18h, 12h, 02h, 03h
		db	 80h, 48h, 03h, 24h, 0Ah, 0Ch
		db	 12h, 02h, 03h, 80h, 24h, 22h
		db	 03h, 12h, 01h, 28h, 01h, 01h
		db	 80h, 24h, 02h, 40h, 61h, 80h
		db	 42h, 12h, 06h, 64h, 03h, 80h
		db	 02h, 04h, 0Ah, 48h, 1Ch, 04h
		db	 03h, 04h, 08h, 44h, 90h, 06h
		db	 04h, 58h, 80h, 40h, 08h, 09h
		db	 80h, 01h, 08h,0C0h, 40h, 08h
		db	 01h,0B3h, 03h, 18h, 80h, 10h
		db	 2Ah, 10h, 63h, 0Dh,0A0h, 40h
		db	 54h, 80h, 66h, 38h, 20h, 6Ch
		db	0ACh, 63h, 18h, 22h,0C3h, 01h
		db	 46h, 66h, 09h, 30h, 60h, 02h
		db	 8Dh, 41h, 73h, 28h, 01h, 98h
		db	 24h, 02h, 8Dh, 41h, 73h, 28h
		db	 36h, 06h, 05h, 06h,0A0h,0B9h
		db	0BCh, 0Ch,0C1h, 80h, 05h, 06h
		db	0A0h,0ACh,0DEh, 03h, 18h,0C0h
		db	 05h, 03h, 50h, 56h, 6Fh,0C3h
		db	 30h, 05h, 01h,0A8h, 2Bh, 3Dh
		db	 80h, 50h, 18h,0D8h, 05h,0D4h
		db	 1Eh,0DEh,0C0h, 28h, 03h
loc_9:
		add	al,ss:data_6[bx+si]
		out	0E0h,ax			; port 0E0h, Memory encode reg2
		push	ds
		iret				; Interrupt return
			                        ;* No entry point to code
		adc	al,2
		adc	byte ptr [di],83h
		jnp	loc_9			; Jump if not parity
		add	ax,800Dh
		xor	ax,ax			; Zero register
		add	al,[bp+si]

zr1_24		endp

seg_a		ends



		end	start
