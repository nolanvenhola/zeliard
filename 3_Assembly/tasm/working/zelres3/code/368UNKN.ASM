
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				_368UNKN                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   5-Apr-26		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    5          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_11e	equ	44BAh			;*
data_12e	equ	44EAh			;*
data_13e	equ	5486h			;*
data_14e	equ	5594h			;*
data_15e	equ	5D00h			;*
data_16e	equ	8000h			;*
data_17e	equ	9B0Ch			;*
data_18e	equ	5F00h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_368UNKN	proc	far

start:
		add	[bp+si],bx
		add	[bx+si],al
		add	byte ptr data_1+1,al
		and	al,0AAh
		db	 26h, 55h, 27h,0FFh, 2Dh, 80h
		db	 34h,0A0h, 36h, 02h, 37h, 0Ah
		db	 39h, 03h, 48h,0A8h, 4Bh,0EAh
		db	 4Dh, 2Ah, 4Eh, 0Fh
data_1		dw	0EE62h, 0BB66h		; Data table (indexed access)
		db	 67h,0BAh, 6Bh, 20h, 6Ch,0C0h
		db	 6Eh,0AFh
		db	 6Fh, 08h, 71h, 3Fh
loc_2:
		jc	loc_2			; Jump if carry Set
;*		js	loc_3			;*Jump if sign=1
		db	 78h, 11h		;  Fixup - byte match
		jns	$+46h			; Jump if not sign
		jnp	$+17h			; Jump if not parity
		sub	word ptr ss:data_13e[bp+di],5087h
		xchg	dx,ax
		scasb				; Scan es:[di] for al
		xchg	di,ax
		cli				; Disable interrupts
		cwd				; Word to double word
		add	ss:data_17e[bp+si],bx
		push	cx
		pushf				; Push flags
		sti				; Enable interrupts
		popf				; Pop flags
		add	al,9Eh
		inc	bp
		cmpsw				; Cmp [si] to es:[di]
		cld				; Clear direction
		lodsw				; String [si] to ax
		push	cs
		mov	cl,40h			; '@'
		mov	ah,0F0h
		mov	ch,30h			; '0'
		mov	dh,0A2h
		mov	bh,28h			; '('
		mov	cx,0C4CFh
;*		adc	bh,al
		db	 10h,0C7h		;  Fixup - byte match
		mov	cl,cl
;*		adc	dl,0E8h
		db	 82h,0D2h,0E8h		;  Fixup - byte match
		db	0D6h,0E0h,0D8h,0F3h,0D9h,0EBh
		db	0DAh, 88h,0DBh,0B0h,0E1h,0BEh
		db	0E6h, 2Bh,0E7h, 41h,0EDh,0BFh
		db	0F9h,0EFh,0FFh,0FFh, 21h, 26h
		db	 03h, 00h
data_3		db	3			; Data table (indexed access)
		db	 00h, 0Fh, 00h, 03h, 00h, 0Eh
		db	 00h, 06h, 00h, 3Eh, 00h, 06h
		db	 00h, 3Eh, 00h, 06h, 00h,0FEh
		db	 00h, 16h, 00h,0FEh, 80h, 06h
		db	 80h,0FEh, 80h, 1Eh, 80h,0FEh
		db	 80h, 1Eh, 80h,0FEh, 80h, 7Eh
		db	 80h,0FBh,0A0h, 1Bh,0A0h,0FFh
		db	0A0h, 5Fh,0A0h, 3Eh,0E8h, 1Eh
		db	0E8h, 3Fh,0EAh, 0Fh,0EAh, 21h
		db	 1Bh, 3Fh, 21h, 09h,0C0h, 21h
		db	 01h,0E0h, 00h,0E0h, 00h

locloop_4:
;*                         lock	add	[bx+si+0],dl
		db	0F0h, 00h, 50h, 00h	;  Fixup - byte match
		db	0F8h, 00h, 38h, 00h,0F8h, 00h
		db	 38h, 00h,0FAh, 00h, 7Ah, 21h
		db	 1Ah,0ACh, 00h, 50h, 00h, 03h
		db	0FAh, 00h, 5Ah, 03h,0FEh, 00h
		db	 76h, 03h,0FAh, 00h, 7Ah, 03h
		db	0FEh, 01h,0FEh, 0Fh,0EAh, 01h
		db	0EAh, 0Fh,0FAh, 03h,0FAh, 3Fh
		db	0B8h, 07h,0B8h,0FFh,0E8h, 1Fh
		db	0E8h, 21h, 0Fh, 03h, 21h, 00h
		db	 03h,0FEh, 00h, 01h,0FEh,0EBh
		db	 01h, 14h,0BBh,0AEh, 44h, 51h
		db	 21h, 0Ah, 03h,0FFh, 21h, 00h
		db	0FEh,0EFh, 01h, 10h,0FBh,0BAh
		db	 04h, 45h,0AEh,0AAh, 51h, 55h
		db	0AAh,0BAh, 55h, 45h,0CEh,0BAh
		db	31h
data_4		dw	2A45h			; Data table (indexed access)
		db	0AAh,0D5h, 55h, 24h, 00h, 26h
		db	 00h,0EAh,0AAh, 15h, 55h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h, 24h, 00h, 26h, 00h, 21h
		db	 03h, 3Fh, 21h, 00h,0FFh,0EEh
		db	 00h, 11h,0BBh,0BAh, 44h, 45h
		db	 24h, 00h, 26h, 00h,0AAh,0BAh
		db	 55h, 49h,0AAh,0AEh, 55h, 6Dh
		db	0AEh,0AAh, 5Dh, 55h, 24h, 00h
		db	 26h, 00h, 24h, 00h, 26h, 00h
		db	 24h, 00h, 26h, 00h, 24h, 00h
		db	 26h, 00h, 24h, 00h, 26h, 00h
		db	 24h, 00h, 26h, 00h, 24h, 00h
		db	 26h, 00h,0AAh,0BFh, 55h, 40h
		db	 21h, 02h, 27h, 00h, 21h, 00h
		db	0BAh,0EEh, 45h, 11h, 24h, 00h
		db	 26h, 00h, 24h, 00h, 26h, 00h
		db	 24h, 00h, 55h, 59h, 24h, 00h
		db	 65h, 55h, 24h, 00h, 26h, 00h
		db	 21h, 02h, 27h, 00h, 21h, 00h
		db	0AAh,0AEh, 56h, 51h, 24h, 00h
		db	 26h, 00h, 24h, 00h, 69h, 55h
		db	 24h, 00h, 55h, 95h, 24h, 00h
		db	 26h, 00h, 24h, 00h, 26h, 00h
		db	 24h, 00h, 26h, 00h, 24h, 00h
		db	 26h, 00h, 24h, 00h, 26h, 00h
		db	 24h, 00h, 26h, 00h, 24h, 00h
		db	 26h, 00h,0AAh,0FFh, 55h, 00h
		db	 27h, 00h, 21h, 00h,0FFh,0BBh
		db	 00h, 44h, 24h, 00h, 26h, 00h
		db	 24h, 00h, 26h, 00h, 24h, 00h
		db	 26h, 00h, 24h, 00h, 26h, 00h
		db	 24h, 00h, 26h, 00h,0FFh,0EAh
		db	 00h, 15h,0BFh,0FFh, 40h, 00h
		db	0BBh,0BFh, 44h, 40h, 21h, 02h
		db	0F0h, 21h, 01h,0BBh,0FBh, 44h
		db	 04h,0AAh,0AEh, 55h, 51h,0AEh
		db	0AAh, 52h, 55h,0ABh,0AAh, 5Bh
		db	 96h,0AAh,0EAh, 56h,0D5h, 24h
		db	 00h, 26h, 00h, 21h, 0Ah,0EEh
		db	0C0h, 11h, 00h,0AAh,0BAh, 55h
		db	 45h,0AAh,0ABh
		db	'UT$'
		db	0
		db	'&', 0
		db	'$'
		db	0
		db	'&', 0
		db	'$'
		db	0
		db	'&', 0
		db	'$'
		db	0
		db	'&', 0
		db	'$'
		db	0
		db	'&', 0
		db	'$'
		db	0
		db	'&', 0
		db	'$'
		db	0
		db	'&', 0
		db	'$'
		db	0
		db	'&', 0
		db	'$'
		db	0
		db	'&', 0
		db	0EEh,0AAh, 11h, 55h, 21h, 0Eh
		db	0C0h, 21h, 01h,0ABh,0C0h, 54h
		db	 00h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h,0AAh,0C3h, 55h
		db	 01h, 24h, 00h, 55h, 56h, 24h
		db	 00h, 55h, 56h, 24h, 00h, 55h
		db	 54h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h, 24h, 00h, 26h, 00h, 83h
		db	0F3h, 80h, 0Ch, 8Ch,0CCh,0A3h
		db	 33h, 83h, 33h,0ACh,0CCh, 00h
		db	0CEh,0BFh, 31h, 33h,0BAh,0CCh
		db	 45h,0EEh,0EBh, 11h, 14h,0FFh
		db	0BAh, 00h, 45h,0FFh,0EEh, 00h
		db	 11h, 3Fh,0BAh, 17h,0BAh, 0Fh
		db	0FAh, 07h,0FAh, 0Fh,0EAh, 01h
		db	0EAh, 03h,0BAh, 01h,0BAh, 03h
		db	0E8h, 03h,0EAh, 03h,0FFh, 21h
		db	 00h, 0Fh,0FFh, 21h, 00h, 3Fh
		db	0FFh, 21h, 05h, 03h, 21h, 01h
		db	 0Fh, 21h, 01h, 0Fh, 21h, 01h
		db	 3Fh, 21h, 01h,0FFh, 21h, 01h
		db	0FFh, 21h, 00h, 03h,0FFh, 21h
		db	 00h, 27h, 00h, 21h, 00h, 27h
		db	 00h, 21h, 00h, 27h, 00h, 21h
		db	 00h,0FFh,0FEh, 00h, 01h,0FFh
		db	0FBh, 00h, 04h,0FEh,0EEh, 01h
		db	 11h,0FBh,0BBh, 04h, 44h,0BAh
		db	0EAh, 45h, 15h, 03h,0FEh, 00h
		db	 01h, 0Fh,0FFh, 21h, 00h, 0Fh
		db	0FBh, 00h, 04h, 0Fh,0EEh, 00h
		db	 11h, 3Fh,0FAh, 00h, 05h, 3Fh
		db	0EAh, 00h, 15h, 3Eh,0EEh, 01h
		db	 11h, 3Fh,0BBh, 00h, 44h,0BEh
		db	0EAh, 41h, 15h,0EEh,0AEh, 11h
		db	 51h, 24h, 00h, 26h, 00h,0EEh
		db	0AAh, 11h, 55h, 24h, 00h, 26h
		db	 00h,0EAh,0AAh, 15h, 55h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h,0FFh,0EAh, 00h, 15h,0FEh
		db	0AEh, 01h, 51h,0FFh,0BAh, 00h
		db	 45h,0FEh,0EAh, 01h, 15h,0FFh
		db	0AEh, 00h, 51h,0FFh,0BBh, 00h
		db	 44h,0FEh,0EAh, 01h, 15h,0FFh
		db	0EEh, 00h, 11h, 3Fh,0AAh, 00h
		db	 55h, 3Eh,0EEh, 01h, 11h, 3Fh
		db	0BAh, 00h, 45h, 3Fh,0EBh, 00h
		db	 14h, 0Fh,0FAh, 00h, 05h, 0Fh
		db	0FFh, 21h, 00h, 0Fh,0FAh, 00h
		db	 05h, 03h,0FFh, 21h, 00h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h,0BAh,0AAh, 45h
		db	 55h, 24h, 00h, 26h, 00h,0EEh
		db	0AAh, 11h, 55h,0AAh,0EAh, 55h
		db	 15h, 03h,0FFh, 21h, 01h,0FEh
		db	 00h, 01h, 00h, 3Fh, 21h, 01h
		db	 0Fh, 21h, 01h, 03h, 21h, 01h
		db	 03h, 21h, 08h,0EBh,0AEh, 14h
		db	 51h,0FAh,0EBh, 05h, 14h,0EEh
		db	0BAh, 11h, 45h,0FFh,0EEh, 00h
		db	 11h,0FBh,0BEh, 04h, 41h,0EEh
		db	0EFh, 11h, 10h,0FBh,0BBh, 04h
		db	 44h, 3Eh,0BEh, 01h, 41h,0FBh
		db	0AAh, 04h, 55h,0EEh,0BAh, 11h
		db	 45h,0BBh,0AAh, 44h, 55h,0EEh
		db	0AAh, 11h, 55h,0BAh,0AAh, 45h
		db	 55h, 4Bh, 00h, 7Bh, 00h,0AEh
		db	0AAh, 51h, 55h,0EAh,0AAh, 15h
		db	 55h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h,0AAh,0ABh, 55h, 54h,0AAh
		db	0AFh, 55h, 50h,0AAh,0BEh, 55h
		db	 41h,0AAh,0FAh, 55h, 05h,0ABh
		db	0E8h, 54h, 16h,0ABh,0A0h, 54h
		db	 5Ah,0AAh, 82h, 55h, 68h,0AAh
		db	 00h, 55h,0AAh,0A8h, 00h, 56h
		db	0AEh,0A8h, 00h, 56h, 24h, 00h
		db	0A0h, 55h, 5Eh,0AAh,0E8h, 55h
		db	 16h, 24h, 00h, 54h, 55h,0A8h
		db	0BAh, 56h, 45h,0A8h,0AEh, 56h
		db	 11h,0AAh, 2Ah, 55h, 85h,0AAh
		db	 8Ah, 55h, 65h,0A2h, 8Ah, 59h
		db	 61h,0A2h,0E2h, 58h, 18h, 48h
		db	 00h, 56h, 56h,0A8h,0BAh, 56h
		db	 05h,0AAh, 2Ah, 55h, 95h,0AAh
		db	 2Bh, 55h, 84h,0AAh, 8Ah, 55h
		db	 65h,0AAh, 8Ah, 55h, 61h,0AAh
		db	0A2h, 55h, 58h, 24h, 00h, 26h
		db	 00h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h,0EAh,0AAh, 15h, 55h, 24h
		db	 00h, 26h, 00h,0EEh,0AAh, 11h
		db	 55h,0EAh,0AAh, 15h, 55h,0BBh
		db	0AAh, 44h, 55h,0FAh,0AAh, 05h
		db	 55h,0BEh,0EAh, 41h, 15h,0EEh
		db	0AEh, 11h, 51h,0BFh,0AAh, 40h
		db	 55h,0EEh,0BAh, 11h, 45h,0BBh
		db	0AAh, 44h, 55h,0AFh,0AAh, 50h
		db	 55h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 26h, 00h, 24h, 00h, 26h
		db	 00h, 24h, 00h, 15h, 55h, 24h
		db	 00h, 05h, 55h, 24h, 00h, 41h
		db	 55h,0BAh,0AAh, 40h, 55h, 2Ah
		db	0AAh, 94h, 15h, 8Ah,0AAh, 25h
		db	 05h, 22h,0AAh, 89h, 41h, 80h
		db	0AAh, 3Eh, 50h, 00h, 2Ah,0AAh
		db	 91h, 00h, 2Ah,0EAh, 90h, 0Bh
		db	0AAh,0A4h, 55h, 2Ah,0AAh, 95h
		db	 55h,0BAh,0AAh, 45h, 55h,0EAh
		db	 2Ah, 14h, 95h,0AAh, 2Ah, 54h
		db	 95h,0E8h,0AAh, 12h, 55h,0A2h
		db	0AAh, 49h, 55h,0A2h, 8Ah, 09h
		db	 65h,0C7h, 00h, 25h, 25h, 4Dh
		db	 00h, 95h, 95h,0AAh, 2Ah, 54h
		db	 95h,0A8h,0AAh, 52h, 55h,0A8h
		db	0AAh, 52h, 55h,0A2h,0AAh, 49h
		db	 55h,0A2h,0AAh, 09h, 55h, 8Ah
		db	0AAh, 25h, 55h, 24h, 00h, 55h
		db	 51h, 24h, 00h, 55h, 50h, 24h
		db	 00h, 55h, 41h, 24h, 00h, 55h
		db	 44h, 24h, 00h, 55h, 41h, 24h
		db	 00h, 55h, 40h, 24h, 00h, 55h
		db	 10h, 24h, 00h, 55h, 01h,0FEh
		db	0E8h, 7Eh,0E8h,0FFh,0A0h, 7Fh
		db	0A0h,0EEh,0A0h,0EEh,0A0h,0AAh
		db	 80h,0AAh, 80h,0AAh, 80h, 2Ah
		db	 80h,0AAh, 80h, 40h, 00h,0AAh
		db	0A0h, 54h, 00h,0AAh,0A8h, 55h
		db	 21h, 03h, 80h, 21h, 01h,0A0h
		db	 00h, 40h, 00h,0A0h, 00h, 40h
		db	 00h,0A8h, 00h, 50h, 00h,0AAh
		db	 00h, 44h, 00h,0AAh, 00h, 50h
		db	 00h,0AAh, 80h, 55h, 00h,0AAh
		db	 80h, 51h, 00h,0AAh,0A0h, 54h
		db	 40h,0AAh,0A0h, 55h, 00h,0AAh
		db	0A0h, 54h, 40h,0AAh,0A8h, 55h
		db	 00h,0AAh,0A8h, 51h, 40h,0AAh
		db	0A8h, 55h, 10h,0AAh,0A8h, 51h
		db	 40h, 24h, 00h, 51h, 40h, 24h
		db	 00h, 54h, 00h, 24h, 00h, 55h
		db	 10h, 24h, 00h, 54h, 40h, 24h
		db	 00h, 51h, 10h, 24h, 00h, 51h
		db	 10h, 24h, 00h, 54h, 40h, 24h
		db	 00h, 51h, 40h,0AAh,0A8h, 54h
		db	 40h,0AAh,0A8h, 51h, 00h,0AAh
		db	0A8h, 51h, 00h,0AAh,0A8h, 54h
		db	 00h,0AAh,0A0h, 51h, 00h,0AAh
		db	0A0h, 40h, 00h,0AAh,0A0h, 10h
		db	 00h,0AAh, 80h, 40h, 00h, 24h
		db	 00h, 86h, 00h, 24h, 00h, 55h
		db	 10h, 24h, 00h, 55h, 44h, 24h
		db	 00h, 44h, 00h, 24h, 00h, 41h
		db	 10h, 24h, 00h, 04h, 40h, 24h
		db	 00h, 11h, 00h,0AAh,0A8h, 41h
		db	 00h,0AAh, 80h, 21h, 00h,0AAh
		db	 21h, 01h,0A8h, 21h, 01h,0A0h
		db	 21h, 01h, 80h, 21h, 01h, 80h
		db	 21h, 09h, 0Fh,0EBh, 00h, 14h
		db	 03h,0BAh, 00h, 45h, 03h,0EEh
		db	 00h, 11h, 00h,0EAh, 00h, 15h
		db	 00h,0FAh, 00h, 05h, 00h, 3Bh
		db	 00h, 04h, 00h, 3Ah, 00h, 05h
		db	 00h, 3Bh, 00h, 04h, 00h, 3Eh
		db	 00h, 01h, 00h, 3Eh, 00h, 01h
		db	 00h, 0Fh, 21h, 01h, 0Fh, 21h
		db	 01h, 0Fh, 21h, 01h, 0Fh, 21h
		db	 01h, 0Fh, 21h, 01h, 03h, 21h
		db	 00h,0BBh,0EAh, 44h, 15h
loc_5:
		scasw				; Scan es:[di] for ax
		scasb				; Scan es:[di] for al
		push	ax
		push	cx
		mov	bx,data_11e
		inc	bp
		scasb				; Scan es:[di] for al
		out	dx,al			; port 0A2E8h, 8514 Bckgrnd color
		push	cx
		adc	ss:data_12e[bp+di],di
		adc	ax,0FAEEh
		adc	[di],ax
		jmp	short loc_5
			                        ;* No entry point to code
		adc	al,14h
;*		jmp	far ptr loc_1		;*
		db	0EAh
		dw	15FBh, 4		;  Fixup - byte match
			                        ;* No entry point to code
		add	sp,[bx+di]
		add	[bp+di],ax
		and	[bx+di],ax
		add	sp,[bx+di]
		add	[bp+di],ax
		and	[bx+di],ax
		add	sp,[bx+di]
		or	al,0EFh
		out	dx,al			; port 0A2E8h, 8514 Bckgrnd color
		les	ax,dword ptr [bx+si]	; Load seg:offset ptr
;*		jmp	far ptr loc_17		;*
		db	0EAh
		dw	15FEh, 0FB00h		;  Fixup - byte match
			                        ;* No entry point to code
		cli				; Disable interrupts
		add	al,0
		out	dx,al			; port 0A2E8h, 8514 Bckgrnd color
		call	sub_1
		sti				; Enable interrupts
		mov	data_10,al
		db	0FEh,0A0h, 01h, 0Fh,0EBh,0A0h
		db	 14h, 0Fh,0BAh, 82h, 00h, 3Dh
		db	0AAh,0A0h, 04h, 00h,0AAh, 80h
		db	 50h, 00h,0AAh, 80h, 04h, 00h
		db	0AAh, 21h, 01h,0AAh, 00h, 10h
		db	 00h,0A8h, 21h, 01h,0A8h, 21h
		db	 01h,0A8h, 21h, 01h, 24h, 00h
		db	 55h, 11h, 24h, 00h, 55h, 04h
		db	 24h, 00h, 55h, 10h, 24h, 00h
		db	 54h, 44h, 24h, 00h, 54h, 01h
		db	 24h, 00h, 10h, 44h, 24h, 00h
		db	 44h, 10h, 24h, 00h, 10h, 40h
		db	0A8h, 21h, 01h,0A8h, 00h, 10h
		db	 00h,0A0h, 00h, 40h, 00h,0A0h
		db	 21h, 01h,0A0h, 21h, 01h,0A0h
		db	 21h, 01h,0A0h, 21h, 01h, 80h
		db	 21h, 01h, 24h, 00h, 04h, 10h
		db	 24h, 00h,0B1h, 00h, 24h, 00h
		db	 00h, 10h, 2Ah,0AAh, 80h, 40h
		db	 0Ah,0AAh,0A0h, 00h, 0Ah,0AAh
		db	0A0h, 00h, 0Ah,0AAh,0A0h, 00h
		db	 02h,0AAh,0A8h, 00h, 80h, 21h
		db	 01h, 80h, 21h, 01h, 80h, 21h
		db	 01h, 80h, 21h, 01h, 80h, 21h
		db	 0Dh,0ABh,0EBh, 14h, 14h, 2Ah
		db	0BAh, 85h, 45h, 8Ah,0ABh, 60h
		db	 54h,0A0h,0AAh, 5Ah, 05h,0AAh
		db	 0Ah, 55h,0A1h,0AAh,0A2h, 55h
		db	 58h,0AAh,0A8h, 55h, 56h, 24h
		db	 00h, 26h, 00h,0BAh,0A8h, 45h
		db	 42h,0EFh,0AAh, 10h, 50h,0BAh
		db	0EAh, 45h, 10h,0EFh,0A8h, 10h
		db	 52h,0AEh,0A2h, 51h, 09h, 8Ah
		db	 0Eh, 20h,0A1h,0A0h,0BAh, 1Ah
		db	 45h, 24h, 00h, 55h, 50h, 24h
		db	 00h, 26h, 00h,0AAh,0A8h, 55h
		db	 56h,0AAh,0A2h, 55h, 59h,0AAh
		db	 8Ah, 55h, 64h,0A8h, 28h, 56h
		db	 93h,0A2h,0A0h, 59h, 0Fh,0AAh
		db	 02h, 44h,0FDh,0A8h, 0Bh, 13h
		db	0F4h,0BAh,0A8h, 45h, 03h,0AAh
		db	 02h, 54h,0FDh,0A8h, 0Ah, 43h
		db	0F5h, 80h,0A8h, 3Fh, 57h, 08h
		db	 88h,0F7h, 77h, 22h, 20h,0DDh
		db	0DEh, 20h, 00h,0DFh,0FAh, 08h
		db	 00h,0F7h,0EAh,0BAh,0EAh, 45h
		db	 10h, 2Eh,0A0h, 91h, 0Fh, 3Ah
		db	 3Ah, 84h,0C5h,0A8h,0E8h, 53h
		db	 17h,0E3h, 80h, 0Ch, 7Fh, 82h
		db	 88h, 3Dh, 76h, 8Ah, 00h, 35h
		db	0FAh, 08h, 80h,0F7h, 7Ah,0ABh
		db	0AAh, 54h, 55h, 0Ah,0B8h,0E5h
		db	 46h, 00h,0B8h,0FAh, 46h, 00h
		db	 2Eh,0FEh, 91h, 20h, 0Bh,0DFh
		db	0A4h, 00h, 02h,0FFh,0E9h, 00h
		db	 02h,0FFh,0E9h, 02h, 00h,0BDh
		db	0FAh, 28h, 00h,0D7h,0EAh, 20h
		db	 00h,0DFh,0A8h, 80h, 00h, 7Ah
		db	 80h, 21h, 00h,0EAh, 80h, 21h
		db	 00h,0AAh, 00h, 0Bh, 00h,0A0h
		db	 00h, 2Bh, 21h, 01h, 0Ah,0C0h
		db	 21h, 01h, 80h,0AFh, 7Eh, 00h
		db	 20h, 2Bh,0DFh, 00h, 0Ah, 02h
		db	0F5h, 21h, 00h, 02h,0FFh, 21h
		db	 01h,0AFh, 00h,0F0h, 00h, 0Ah
		db	 00h,0F8h, 21h, 00h, 03h,0A0h
		db	 21h, 00h, 2Bh,0FBh, 94h, 04h
		db	0AFh,0AEh, 10h, 51h,0ABh,0EBh
		db	 14h, 14h, 2Ah,0AAh, 85h, 55h
		db	 8Ah,0AAh, 60h, 44h,0A0h,0A2h
		db	 5Ah, 08h,0BAh, 0Ah, 45h,0A0h
		db	0AEh, 80h, 51h, 6Ah,0FBh,0AAh
		db	 04h, 50h,0EAh,0A8h, 15h, 42h
		db	0AAh,0A2h, 55h, 09h,0AAh, 0Ah
		db	 50h,0A5h,0A0h,0AAh, 0Ah, 55h
		db	 82h,0AAh, 29h, 55h, 2Ah,0AAh
		db	 95h, 55h, 24h, 00h, 26h, 00h
		db	 2Bh,0E0h, 94h, 1Ah, 00h,0AEh
		db	0AAh, 51h, 00h, 2Bh,0FEh, 94h
		db	 80h, 02h, 7Fh,0A9h, 28h, 00h
		db	0D7h,0FAh, 0Eh, 00h,0F1h,0FFh
		db	 00h,0E0h,0BFh, 1Fh, 00h,0AAh
		db	0BFh, 55h, 2Ah,0AAh, 95h, 55h
		db	 0Ah,0AAh,0A5h, 55h, 82h,0AAh
		db	 69h, 55h,0A0h,0AAh, 5Ah, 55h
		db	 28h, 2Ah, 96h, 95h, 0Ah, 8Ah
		db	0A5h, 65h, 00h,0AAh,0EAh, 51h
		db	 00h, 2Ah,0FAh, 90h, 24h, 00h
		db	 55h, 54h, 24h, 00h, 55h, 51h
		db	 24h, 00h, 55h, 04h,0AAh,0A8h
		db	 54h, 43h,0AAh,0A0h, 41h, 0Fh
		db	0AAh, 8Ah, 10h, 35h,0A8h, 2Ch
		db	 43h,0D3h,0A0h,0B8h, 0Fh, 47h
		db	0A0h, 28h, 4Fh,0D7h,0A0h,0E0h
		db	 0Fh, 1Fh, 02h, 88h,0FDh, 77h
		db	 22h, 20h,0DDh,0DFh, 28h, 00h
		db	0D7h,0FFh, 2Dh, 00h, 7Fh, 7Eh
		db	 88h, 00h, 77h,0FAh, 21h, 00h
		db	0FFh,0EAh, 82h,0E0h, 3Dh, 1Fh
		db	 83h,0A0h, 3Ch, 5Fh, 08h, 88h
		db	0F7h, 77h, 88h, 00h, 77h,0FFh
		db	 2Ah, 20h,0D5h,0DFh, 88h, 00h
		db	 77h,0FFh, 80h, 00h, 7Fh,0FEh
		db	0A2h, 00h, 5Dh,0EAh, 80h, 00h
		db	 7Fh,0EAh, 00h, 02h,0FAh,0A8h
		db	 21h, 00h,0EAh, 80h, 21h, 00h

locloop_6:
;*		jmp	far ptr loc_14		;*
		db	0EAh
		dw	2180h, 0AA00h		;  Fixup - byte match
			                        ;* No entry point to code
		add	byte ptr [bx+si],0F0h
		stosb				; Store al to es:[di]
		add	[bp+si],al
		mov	sp,21A8h
		add	[bp+si],ch
		mov	al,ds:data_16e
		or	bh,[bx-5Ch]
		loopnz	$+0Ch			; Loop if zf=0, cx>0

		pop	ds
		movsw				; Mov [si] to es:[di]
		loop	$+2			; Loop if cx > 0

		sbb	ax,28EAh
;*		add	bh,dl
		db	 00h,0D7h		;  Fixup - byte match
		db	0FEh
data_6		db	28h
		db	 80h,0D7h, 7Eh, 22h, 00h,0DDh
		db	0FFh, 00h
loc_7:
;*		mov	bh,bh
		db	 88h,0FFh		;  Fixup - byte match
		ja	$+4			; Jump if above
		sub	bh,ch
;*		aad	24h			; '$' undocumented inst
		db	0D5h, 24h		;  Fixup - byte match
		add	[di],dl
		push	bp
		and	al,0
		add	ax,2455h
		add	[bx+di+55h],dl
		sub	ch,ss:data_14e[bp+si]
		or	ch,byte ptr ss:[15A5h][bp+si]
		add	ch,byte ptr ss:[45E9h][bp+si]
		add	[bp+si],ch
		jmp	far ptr $-8EBh
			                        ;* No entry point to code
		movsb				; Mov [si] to es:[di]
		add	byte ptr ds:[53BFh][si],ch
		and	byte ptr [bp+si],2Bh	; '+'
		db	0DDh, 00h, 08h, 02h,0F7h, 00h
		db	 36h, 00h,0FDh
		db	21h
loc_9:
		add	[bp+si],al
		dec	word ptr [bx]
		add	al,[bx+si]
		mov	bp,803Eh
		add	[bx],ch
;*		call	sub_2			;*
		db	0E8h, 21h, 00h		;  Fixup - byte match
		or	sp,[bx+si]
		add	bl,bh
		test	ax,282h
		jge	loc_9			; Jump if > or =
		mov	al,ds:data_18e
		cli				; Disable interrupts
		loopnz	locloop_6		; Loop if zf=0, cx>0

		pop	ds
		jp	loc_7			; Jump if parity=1
		add	[bx-2],dl
		db	 2Eh, 00h,0D1h,0FFh, 08h, 80h
		db	0F7h, 7Fh, 20h, 80h,0DFh

_368UNKN	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
;*		jg	loc_12			;*Jump if >
		db	 7Fh, 2Ah		;  Fixup - byte match
		mov	al,[bx+si]
		xor	ax,202Ah
;*		add	bh,bl
		db	 00h,0DFh		;  Fixup - byte match
		or	ah,ss:data_15e[bp+si]
		add	[bx+si],ah
loc_10:
		add	bx,di
		add	[bx+si],cl
loc_11:
		add	si,di
		and	[bx+si],ax
		add	di,di
		and	[bx+si],ax
		add	di,di
		and	[bx+si],ax
		add	ch,ss:data_3[bp+si]
		jg	loc_10			; Jump if >
		mov	[bx+si],al
		ja	loc_11			; Jump if above
		and	[bx+si],ax
		jmp	dword ptr ss:data_1[bp+si]	;*
		db	0DFh,0AAh, 80h, 00h, 7Eh,0AAh
		db	 21h, 00h,0FAh,0AAh, 21h, 00h
		db	 24h, 00h, 21h, 00h,0AAh,0A8h
		db	 21h, 01h,0AAh, 21h, 01h, 2Ah
		db	 21h, 18h,0AAh,0A0h, 21h, 00h
		db	0AAh, 80h, 21h, 00h,0A8h, 21h
		db	 14h, 20h,0FFh,0DFh, 36h, 00h
		db	0FDh,0FDh, 00h, 20h,0FFh,0DFh
		db	 00h, 88h,0FFh, 77h, 00h, 20h
		db	0BFh,0DFh, 02h, 00h,0BDh,0FFh
		db	 00h, 08h, 2Fh,0F7h, 21h, 00h
		db	0ABh,0FEh, 02h,0A8h,0E8h, 21h
		db	 00h,0A8h,0EAh, 21h, 00h,0A0h
		db	0FAh, 21h, 01h,0FAh, 2Dh, 00h
		db	 00h, 7Ah, 80h, 21h, 00h,0EAh
		db	 80h, 21h, 00h,0EAh, 80h, 21h
		db	 00h,0AAh, 80h, 21h, 00h, 0Ah
		db	0AAh, 21h, 00h, 02h,0AAh, 21h
		db	 01h, 2Ah, 21h, 14h,0AAh, 21h
		db	 01h,0A8h, 21h, 17h, 24h, 00h
		db	 26h, 00h, 24h, 00h, 26h, 00h
		db	0AAh,0BFh, 55h, 40h,0ABh,0FEh
		db	 54h, 01h,0BFh,0FBh, 40h, 04h
		db	0FEh,0E8h, 01h, 16h,0FBh, 82h
		db	 04h, 68h,0BAh, 2Ah, 45h, 80h
		db	0AFh,0FEh, 50h, 01h,0FFh,0EFh
		db	 00h, 10h,0FBh,0B0h, 04h, 4Ah
		db	0ECh, 08h, 12h,0A2h,0C9h, 00h
		db	 68h, 38h, 2Ah, 2Fh, 2Dh, 00h
		db	0ABh,0FFh, 21h, 00h,0BFh,0FFh
		db	 21h, 00h,0E0h,0AAh, 1Ah, 37h
		db	 00h,0AFh, 34h, 00h, 2Bh,0FEh
		db	 83h, 0Ah,0AFh,0EBh, 0Ch,0ABh
		db	0AFh,0BCh, 22h,0BCh,0AFh,0C0h
		db	 22h,0C0h,0BEh,0CFh, 8Ah,0C0h
		db	0BBh, 0Fh, 8Bh, 00h, 0Fh,0FFh
		db	 21h, 00h,0A8h,0FFh,0A8h, 00h
		db	0FBh, 8Fh,0AAh, 80h,0EAh, 8Fh
		db	0EAh, 80h, 2Ah,0E3h, 2Ah,0A0h
		db	 02h,0A3h, 02h,0A0h, 02h,0A8h
		db	 02h,0A8h, 00h, 88h, 00h, 88h
		db	0EEh,0EAh, 11h, 15h,0B0h, 00h
		db	 4Ah,0AAh, 0Ah,0AAh,0A0h, 00h
		db	 2Ah,0AAh, 80h, 00h,0AFh,0FFh
		db	 21h, 00h, 27h, 00h, 21h, 00h
		db	 27h, 00h, 21h, 00h,0FFh,0C0h
		db	 00h, 3Eh,0AAh,0EEh, 55h, 11h
		db	 00h, 0Ah,0AAh,0A5h,0AAh,0A0h
		db	 00h, 0Ah,0EAh,0AAh, 21h, 00h
		db	0FFh,0FCh, 00h, 02h,0FCh, 00h
		db	 03h,0ABh,0C3h,0FFh, 38h, 00h
		db	 27h, 00h, 21h, 00h,0FFh, 33h
		db	 00h,0C8h,0FFh,0FCh, 00h, 02h
		db	 27h, 00h, 21h, 00h,0C3h,0FFh
		db	 38h, 00h,0FCh, 0Fh, 03h,0A0h
		db	0C3h,0F0h, 28h, 0Eh, 27h, 00h
		db	 21h, 00h,0FFh,0FCh, 00h, 03h
		db	 27h, 00h, 21h, 00h, 27h, 00h
		db	 21h, 00h, 27h, 00h, 21h, 00h
		db	 27h, 00h, 21h, 00h,0FFh,0C3h
		db	 00h, 3Ch,0FFh,0CFh, 00h, 30h
		db	 3Fh,0F3h, 80h, 0Ch, 00h, 33h
		db	0BAh, 8Ch,0FEh,0EAh, 01h, 15h
		db	0BBh,0BEh, 44h, 41h, 0Ah,0BFh
		db	0A5h, 40h,0A0h, 2Bh, 0Ah, 94h
		db	 00h, 82h,0AEh, 29h,0FEh,0A8h
		db	 00h, 02h,0FFh,0EEh, 21h, 00h
		db	0FFh,0FBh, 21h, 00h, 24h, 00h
		db	 51h, 55h, 24h, 00h, 15h, 55h
		db	0EAh,0AAh, 11h, 55h,0BAh,0AAh
		db	 45h, 15h,0AFh,0AAh, 50h, 45h
		db	 2Ah,0AAh, 95h, 50h, 82h,0BAh
		db	 29h, 44h,0A8h,0AEh, 02h, 51h
		db	0FFh,0FEh, 21h, 00h, 27h, 00h
		db	 21h, 00h,0FFh,0FEh, 21h, 00h
		db	 27h, 00h, 21h, 00h,0FFh,0FEh
		db	 21h, 00h,0FFh,0FBh, 21h, 00h
		db	 32h, 23h,0CCh,0CCh, 80h, 00h
		db	 2Fh,0EAh,0EEh, 0Ah, 00h,0A5h
		db	0BBh,0B0h, 00h, 0Ah,0EFh,0CEh
		db	 00h, 20h, 66h, 00h, 21h, 00h
		db	0EEh,0AEh, 21h, 00h,0EBh,0A0h
		db	 00h, 0Fh, 0Eh, 00h,0F0h,0FFh
		db	 21h, 00h,0BEh,0AAh,0AFh, 00h
		db	0ABh, 00h,0AFh, 80h,0ABh, 80h
		db	 68h, 80h, 68h, 80h,0ABh,0A8h
		db	 5Ah,0A8h,0AAh, 8Bh, 55h, 8Bh
		db	0EEh,0A8h, 11h, 54h,0AFh,0AEh
		db	 50h, 51h,0BAh,0FBh, 45h, 04h
		db	 00h, 88h, 00h, 88h, 02h, 88h
		db	 02h, 88h, 03h, 23h, 03h, 20h
		db	 3Ch,0A2h, 3Ch,0A0h,0F3h,0CAh
		db	0F3h,0C0h, 0Fh,0CAh, 0Fh,0C0h
		db	0AAh, 28h, 55h, 02h,0ABh,0AAh
		db	 54h, 55h,0AAh,0AEh, 55h, 51h
		db	 24h, 00h, 05h, 55h, 0Ah,0AAh
		db	0A0h
data_7		db	15h			; Data table (indexed access)
		db	0A0h, 2Ah, 5Ah, 80h,0BAh, 80h
		db	 44h, 2Ah,0EBh,0AAh, 14h, 50h
		db	0BEh,0EAh, 41h, 15h,0AFh,0FAh
		db	 50h, 05h, 62h, 00h, 78h, 00h
		db	0BBh,0AFh, 44h, 50h,0AAh,0ABh
		db	 55h, 54h, 24h, 00h, 26h, 00h
		db	 24h, 00h, 00h, 55h, 00h, 24h
		db	 00h, 00h,0AAh, 00h, 55h, 24h
		db	 01h, 26h, 00h,0FFh,0C3h, 00h
		db	 28h,0FFh, 2Fh, 00h, 80h,0B8h
		db	0FFh, 03h, 00h,0EFh,0BBh, 21h
		db	 00h,0AEh,0EEh, 21h, 00h, 24h
		db	 00h, 21h, 00h, 24h, 00h, 21h
		db	 00h,0AFh,0AAh, 50h, 00h, 0Fh
		db	0C0h,0E0h, 3Ah,0BBh,0EFh, 21h
		db	 00h,0EBh,0BAh, 21h, 00h,0BEh
		db	0E8h, 00h, 03h,0ABh,0AEh, 21h
		db	 00h, 24h, 00h, 21h, 00h, 24h
		db	 00h, 21h, 00h
data_8		db	24h			; Data table (indexed access)
		db	 00h, 00h, 05h,0EBh,0EAh, 14h
		db	 15h,0EEh,0BEh, 11h, 41h,0AAh
		db	0EBh, 55h, 14h,0BAh,0AEh, 45h
		db	 51h, 24h, 00h, 26h, 00h, 24h
		db	 00h, 00h, 55h, 02h,0AAh,0A8h
		db	 00h,0A8h, 00h, 56h, 24h, 01h
		db	 26h, 00h,0FBh,0BBh, 04h, 44h
		db	0EAh,0EEh, 15h, 11h,0AEh,0AAh
		db	 51h, 55h, 24h, 00h, 26h, 00h
data_9		db	24h
		db	 00h, 55h, 00h,0AAh, 80h, 00h
		db	 2Ah, 00h, 2Ah,0AAh, 95h, 00h
		db	 2Ch,0FAh, 83h, 8Ah,0BBh, 20h
		db	 00h, 0Eh,0EAh,0A0h, 00h,0ABh
		db	0AAh, 21h, 00h,0AAh, 2Ah, 00h
		db	 80h,0AAh, 82h, 00h, 28h, 24h
		db	 00h, 00h, 55h,0AAh,0AFh, 55h
		db	 50h, 02h
data_10		db	80h
		db	0A8h, 2Bh,0AAh, 28h, 00h, 83h
		db	0A0h,0A8h, 0Ah, 02h, 24h, 00h
		db	 00h, 05h,0AAh,0ABh, 00h, 54h
		db	0AAh,0BEh, 15h, 41h, 66h, 00h
		db	 79h, 00h,0EEh,0AAh, 11h, 55h
		db	0EFh,0BEh, 10h, 41h,0BEh,0BBh
		db	 41h, 44h, 24h, 00h, 26h, 00h
		db	 24h, 00h, 26h, 00h, 24h, 00h
		db	 55h, 00h,0AAh, 21h, 00h,0AAh
		db	 00h,0ABh,0AAh, 54h,0AAh,0EEh
		db	 55h, 11h, 24h, 00h, 55h, 54h
		db	 24h, 00h, 55h, 40h,0AAh,0A0h
		db	 50h, 0Ah,0A8h, 0Ah, 02h,0A5h
		db	 02h,0ABh,0A9h, 54h,0AAh,0FAh
		db	 55h, 05h,0BBh,0EAh, 44h, 15h
		db	0BEh,0AAh, 41h, 54h, 24h, 00h
		db	 26h, 00h, 24h, 00h, 26h, 00h
		db	0AAh,0BFh, 55h, 40h,0ABh,0FEh
		db	 54h, 01h,0BFh,0FBh, 40h, 04h
		db	0FEh,0E8h, 01h, 16h,0FBh, 82h
		db	 04h, 68h,0BAh, 2Bh, 45h, 80h
		db	0AFh,0FEh, 50h, 01h,0FFh,0EFh
		db	 00h, 10h,0FBh,0B0h, 04h, 4Ah
		db	0ECh, 02h, 12h,0ACh, 82h, 8Eh
		db	 68h, 20h, 2Ah, 8Fh, 80h, 20h
		db	0AFh, 30h, 00h,0CEh,0FFh, 0Fh
		db	 00h,0A0h,0E0h,0AFh, 1Ah, 00h
		db	 0Ah,0FFh,0A0h, 00h, 2Bh,0FFh
		db	 80h, 00h,0BFh,0FFh, 21h, 00h
		db	 3Fh,0FFh, 80h, 00h, 27h, 00h
		db	 21h, 00h, 0Fh,0FFh,0A0h, 00h
		db	 03h,0FFh,0E8h, 00h,0FCh,0FFh
		db	 03h, 00h,0FCh,0FFh, 02h, 00h
		db	0FCh,0FFh, 02h, 00h,0F3h,0FFh
		db	 0Ch, 00h,0F3h,0FFh, 08h, 00h
		db	 27h, 00h, 21h, 00h,0FFh,0F0h
		db	 00h, 0Eh,0FFh,0F3h, 00h, 0Ch
		db	0EEh,0EAh, 11h, 15h,0B0h, 00h
		db	 4Ah,0AAh, 0Ah,0AAh,0A0h, 00h
		db	 24h, 00h, 21h, 00h,0A3h,0FFh
		db	 08h, 00h, 0Fh,0FFh,0E0h, 00h
		db	 27h, 00h, 21h, 00h, 3Fh,0FFh
		db	 80h, 00h,0AAh,0EEh, 55h, 11h
		db	 00h, 0Ah,0AAh,0A5h,0AAh,0A0h
		db	 00h, 0Ah,0EAh,0AAh, 21h, 00h
		db	 27h, 00h, 21h, 00h, 27h, 00h
		db	 21h, 00h, 27h, 00h, 21h, 00h
		db	0FFh,0FCh, 00h, 02h, 3Fh,0FFh
		db	 80h, 00h,0CFh,0FFh, 20h, 00h
		db	 27h, 00h, 21h, 00h,0FCh,0C0h
		db	 03h, 3Eh,0FCh, 3Fh, 03h, 80h
		db	 03h,0FFh,0E8h, 00h, 3Fh,0FFh
		db	 80h, 00h,0CFh,0FFh, 30h, 00h
		db	0FFh,0C0h, 00h, 3Eh,0F0h, 0Fh
		db	 0Eh,0A0h, 03h,0F0h,0E8h, 0Eh
		db	 27h, 00h, 21h, 00h, 27h, 00h
		db	 21h, 00h, 27h, 00h, 21h, 00h
		db	 27h, 00h, 21h, 00h, 27h, 00h
		db	 21h, 00h,0FEh,0EAh, 01h, 15h
		db	0BBh,0BEh, 44h, 41h, 0Ah,0BFh
		db	0A5h, 40h,0A0h, 2Bh, 0Ah, 94h
		db	 8Ah, 82h, 30h, 29h, 3Eh, 88h
		db	0C0h, 32h, 3Fh, 00h, 80h,0FAh
		db	0C0h, 03h, 3Ah,0E8h, 24h, 00h
		db	 51h, 55h, 24h, 00h, 15h, 55h
		db	0EAh,0AAh, 11h, 55h,0BAh,0AAh
		db	 45h, 15h,0AFh,0AAh, 50h, 45h
		db	 2Ah,0AAh, 95h, 50h, 02h,0BAh
		db	0E9h, 44h, 28h,0AEh, 82h, 51h
		db	 03h,0CEh,0ACh, 20h,0FFh,0CFh
		db	 00h, 30h, 3Fh, 3Eh, 2Dh, 00h
		db	0C0h,0C3h, 3Ah, 3Ch,0F3h,0FCh
		db	 08h, 03h,0F3h,0F8h, 08h, 03h
		db	0CEh,0EFh, 20h, 00h,0BBh,0BAh
		db	 21h, 00h,0EEh, 0Ah, 00h,0A5h
		db	0BBh,0B0h, 00h, 0Ah,0E3h,0CEh
		db	 0Ch, 20h, 0Bh,0BBh,0F0h, 00h
		db	0EEh,0AEh, 21h, 00h,0EBh,0ABh
		db	 21h, 00h, 0Eh,0A0h,0F0h, 0Fh
		db	0BAh,0A0h, 00h, 0Eh,0CFh,0FAh
		db	 20h, 0Ah,0FFh,0AFh, 00h,0A0h
		db	0F7h,0FEh, 07h, 0Ah,0AFh,0E0h
		db	 5Ch,0A0h,0AAh, 80h, 55h, 80h
		db	0EEh,0A8h, 11h, 54h,0AFh,0AEh
		db	 50h, 51h,0BAh,0FBh, 45h, 04h
		db	 0Fh,0FFh, 21h, 00h,0A0h,0FFh
		db	0A0h, 00h,0FBh, 2Fh,0AAh, 20h
		db	 2Ah, 8Fh, 2Ah, 80h, 0Ah,0E3h
		db	 0Ah,0A0h, 02h,0A3h, 02h,0A0h
		db	0AAh,0A2h, 55h,0A2h,0ABh,0AAh
		db	 54h, 55h, 27h, 00h, 21h, 00h
		db	0FFh,0EFh, 21h, 00h,0BBh,0FFh
		db	 21h, 00h, 0Fh,0BBh,0E0h, 00h
		db	0E0h, 2Eh, 0Eh, 80h, 0Ah, 82h
		db	0E0h, 28h,0AAh, 08h, 00h,0A2h
		db	0AFh,0AAh, 50h, 00h,0FFh,0FAh
		db	 21h, 00h,0BBh,0EFh, 21h, 00h
		db	0E0h,0BAh, 0Bh, 00h,0B2h,0EBh
		db	 08h, 00h,0A8h,0A0h, 02h, 0Eh
		db	0A8h, 00h, 03h,0AAh, 02h, 2Ah
		db	0ACh,0C0h,0A8h, 2Ah, 03h, 85h
		db	0EEh,0AEh, 21h, 00h,0BAh,0BBh
		db	 21h, 00h,0EEh,0C0h, 00h, 3Bh
		db	0A0h, 00h, 0Eh,0BAh, 00h,0A0h
		db	0EAh, 0Bh, 24h, 00h, 21h, 00h
		db	 24h, 00h, 00h, 55h,0AAh,0AFh
		db	 55h, 50h,0A8h, 00h, 03h,0BAh
		db	 80h, 00h, 3Eh,0EAh, 00h, 08h
		db	0EAh,0A2h, 2Ah,0AAh, 80h, 05h
		db	0AAh,0ABh, 00h, 54h,0AAh,0BEh
		db	 15h, 41h, 66h, 00h, 79h, 00h
		db	0EEh,0AAh, 11h, 55h,0AFh,0FEh
		db	 50h, 01h,0FFh,0EFh, 00h, 10h
		db	0FBh,0B0h, 04h, 4Ah,0ECh, 0Ah
		db	 12h,0A0h, 82h,0AAh, 68h, 00h
		db	 2Ah,0BFh, 80h, 00h,0AFh,0FFh
		db	 21h, 00h,0FFh,0F3h, 00h, 0Ch
		db	0E0h, 2Fh, 1Ah,0C0h, 0Ah, 3Fh
		db	0A0h, 80h, 2Bh,0C3h, 80h, 2Ch
		db	0BFh,0FCh, 00h, 02h, 3Fh,0FFh
		db	 80h, 00h, 27h, 00h, 21h, 00h
		db	 4Eh, 00h,0A0h,0F0h, 00h,0F3h
		db	0EBh, 0Ch,0FFh,0FCh, 00h, 02h
		db	 27h, 00h, 21h, 00h, 27h, 00h
		db	 21h, 00h, 3Fh,0FCh, 80h, 03h
		db	0CFh,0FFh, 20h, 00h, 27h, 00h
		db	 21h, 00h, 27h, 00h, 21h, 00h
		db	 27h, 00h, 21h, 00h,0AAh,0EEh
		db	 55h, 11h, 00h, 0Ah,0AAh,0A5h
		db	0A2h,0A0h, 08h, 0Ah,0E2h,0AAh
		db	 08h, 00h,0F3h,0FFh, 08h, 00h
		db	0CFh,0FFh, 20h, 00h,0CFh,0FCh
		db	 30h, 02h,0FFh,0F3h, 00h, 0Ch
		db	0F3h,0FFh, 08h, 00h, 3Fh,0FFh
		db	0C0h, 00h, 3Fh,0FFh, 80h, 00h
		db	0CFh,0FFh, 30h, 00h, 27h, 00h
		db	 21h, 00h, 27h, 00h, 21h, 00h
		db	 27h, 00h, 21h, 00h, 27h, 00h
		db	 21h, 00h,0FFh,0FCh, 00h, 02h
		db	0FFh,0FCh, 00h, 03h,0FFh,0F3h
		db	 00h, 0Ch, 27h, 00h, 21h, 00h
		db	 27h, 00h, 21h, 00h, 27h, 00h
		db	 21h, 00h, 27h, 00h, 21h, 00h
		db	 27h, 00h, 21h, 00h,0FFh,0FEh
		db	 21h, 00h, 27h, 00h, 21h, 00h
		db	 3Fh,0FEh, 80h, 00h, 3Fh,0FFh
		db	0C0h, 00h,0FFh,0FEh, 21h, 00h
		db	0FFh,0FBh, 21h, 00h,0FEh,0EFh
		db	 21h, 00h,0BBh,0B8h, 00h, 03h
		db	0EEh, 0Ah, 00h,0A5h,0BBh,0B0h
		db	 00h, 0Ah,0EFh,0CEh, 00h, 20h
		db	 66h, 00h, 21h, 00h,0EEh,0AEh
		db	 21h, 00h,0EBh,0ABh, 21h, 00h
		db	0AEh,0ACh, 00h, 03h,0BAh,0A8h
		db	 00h, 02h, 00h, 0Fh,0BFh,0B0h
		db	0CCh, 00h, 22h,0ABh, 2Bh,0C0h
		db	 80h, 3Bh,0AAh,0BBh, 50h, 00h
		db	 24h, 00h, 55h, 00h,0EEh,0AAh
		db	 11h, 54h,0AFh,0AEh, 50h, 51h
		db	0BAh,0FBh, 45h, 04h,0FFh,0F3h
		db	 00h, 0Ch,0FFh, 0Fh, 00h,0A0h
		db	 0Ch,0E0h,0A2h, 0Bh, 03h,0BBh
		db	0ECh, 00h, 28h, 2Ah,0C2h, 80h
		db	0C9h, 00h,0B7h, 00h, 24h, 00h
		db	 55h, 00h,0BBh,0AAh, 44h, 55h
		db	0CFh,0FAh, 20h, 0Ah,0FFh,0AFh
		db	 00h,0A0h,0F7h,0FEh, 07h, 0Ah
		db	0AFh,0EBh, 0Ch,0ABh,0AFh,0BCh
		db	 22h,0BCh,0AFh,0C0h, 22h,0C0h
		db	0BEh,0CFh, 8Ah,0C0h,0BBh, 0Fh
		db	 8Bh, 00h, 0Fh,0BCh, 00h, 03h
		db	0A0h,0FBh,0A0h, 00h,0FBh, 2Ch
		db	0AAh, 23h,0EAh, 8Bh,0EAh, 80h
		db	 2Ah,0E2h, 2Ah,0A0h, 02h,0A2h
		db	 02h,0A0h, 02h,0A8h, 02h,0A8h
		db	 00h, 88h, 00h, 88h,0EEh,0A2h
		db	 00h, 0Ch, 3Ah,0B3h, 80h, 0Ch
		db	 0Eh,0E8h,0A0h, 03h,0A0h, 2Ah
		db	 0Eh, 80h,0AAh, 21h, 00h,0AEh
		db	0A0h,0A8h, 0Fh, 03h,0A2h,0AAh
		db	 0Ch, 55h,0AAh,0AFh, 55h, 50h
		db	0AAh, 82h, 00h, 38h,0AAh, 0Ah
		db	 00h, 34h, 00h, 28h, 0Ah, 82h
		db	 02h,0AAh,0B8h, 05h, 2Ah,0ABh
		db	 80h, 54h,0AAh,0BEh, 15h, 41h
		db	 66h, 00h, 79h, 00h,0EEh,0AAh
		db	 11h, 55h, 24h, 00h, 26h, 00h
		db	 24h, 00h, 26h, 00h,0AAh,0BFh
		db	 55h, 40h,0ABh,0FEh, 54h, 01h
		db	0BFh,0FBh, 40h, 04h,0FEh,0E8h
		db	 01h, 16h,0FBh, 82h, 04h, 68h
		db	0BAh, 03h, 45h,0A8h,0E0h, 80h
		db	 1Ah, 2Bh, 0Ah,0FFh,0A0h, 00h
		db	 2Bh,0FFh, 80h, 00h,0BFh,0FFh
		db	 21h, 00h, 3Fh,0FFh, 80h, 00h
		db	 27h, 00h, 21h, 01h,0FFh,0AFh
		db	 21h, 00h, 3Fh,0EBh,0C0h, 3Fh
		db	0FFh,0C0h, 00h, 03h,0FFh,0ACh
		db	 00h,0F0h, 0Fh, 0Ah,0F0h,0FFh
		db	 30h, 00h, 8Eh,0FFh, 3Fh, 00h
		db	 80h,0FFh,0CFh, 00h, 20h,0FFh
		db	0F0h, 00h, 0Eh, 0Fh,0FFh,0F0h
		db	 00h,0EEh,0EAh, 11h, 15h,0B0h
		db	 00h, 4Ah,0AAh, 0Ah, 2Ah,0A0h
		db	 80h,0AAh, 8Ah, 00h, 20h,0AFh
		db	0F0h, 00h, 0Eh, 27h, 00h, 21h
		db	 00h, 27h, 00h, 21h, 00h, 27h
		db	 00h, 21h, 00h,0AAh,0EEh, 55h
		db	 11h, 00h, 0Ah,0AAh,0A5h,0AAh
		db	0A0h, 00h, 0Ah,0EAh,0AAh, 21h
		db	 00h, 27h, 00h, 21h, 00h, 0Fh
		db	0FFh,0E0h, 00h,0F3h,0FFh, 08h
		db	 00h,0FCh,0FFh, 02h, 00h, 27h
		db	 00h, 21h, 00h, 27h, 00h, 21h
		db	 00h, 27h, 00h, 21h, 00h, 27h
		db	 00h, 21h, 00h, 03h,0C0h,0ACh
		db	 3Fh,0FCh, 3Fh, 02h,0C0h,0FFh
		db	0CFh, 00h, 20h, 3Fh,0F0h, 80h
		db	 0Ah,0CFh, 3Fh, 20h,0C0h,0F3h
		db	 0Fh, 0Ch,0A0h,0F3h,0CFh, 08h
		db	 30h,0FCh,0FFh, 02h, 00h,0FFh
		db	 3Fh, 00h, 80h, 27h, 00h, 21h
		db	 00h, 27h, 00h, 21h, 00h, 27h
		db	 00h, 21h, 00h,0FEh,0EAh, 01h
		db	 15h,0BBh,0BEh, 44h, 41h, 0Ah
		db	0BFh,0A5h, 40h,0A0h, 2Bh, 0Ah
		db	 94h,0A2h, 82h, 08h, 29h,0FCh
		db	0A8h, 03h, 02h,0FCh,0EEh, 02h
		db	 00h,0FFh, 3Bh, 00h, 80h,0EEh
		db	 0Ah, 00h,0A5h,0BBh,0B0h, 00h
		db	 0Ah,0EFh,0CEh, 00h, 20h, 66h
		db	 00h, 21h, 00h,0EEh,0AEh, 21h
		db	 00h,0EBh,0ABh, 21h, 00h,0AEh
		db	0ACh, 00h, 03h,0BAh,0A8h, 00h
		db	 02h, 21h, 00h,0BAh,0FFh, 21h
		db	 00h,0EEh,0BAh, 2Bh, 0Ch, 80h
		db	0A3h,0AAh,0B3h, 50h, 08h, 24h
		db	 00h, 55h, 00h,0EEh,0AAh, 11h
		db	 54h,0AFh,0AEh, 50h, 51h,0BAh
		db	0FBh, 45h, 04h,0F3h,0FFh, 0Ch
		db	 00h, 03h, 3Fh,0FCh,0C0h, 00h
		db	 03h,0ABh,0ACh,0B0h, 80h, 0Eh
		db	 3Ah,0EAh,0A8h, 00h, 03h,0AAh
		db	0A0h, 00h, 0Eh, 24h, 00h, 55h
		db	 00h,0BBh,0AAh, 44h, 55h, 27h
		db	 00h, 21h, 00h,0FFh,0EFh, 21h
		db	 00h, 8Bh,0FFh, 30h, 00h, 03h
		db	0B8h,0BCh, 03h, 00h, 0Eh,0AEh
		db	0F0h,0A0h, 00h, 0Ah,0BAh, 24h
		db	 00h, 21h, 00h,0AFh,0AAh, 50h
		db	 00h,0FFh,0FAh, 21h, 00h,0BBh
		db	0EFh, 21h, 00h,0EBh,0B0h, 00h
		db	 0Eh,0BEh,0C3h, 00h,0B7h, 00h
		db	 2Ch,0C3h,0C3h, 08h, 2Ah,0B3h
		db	 80h, 00h, 02h,0EAh,0ECh, 24h
		db	 00h, 00h, 05h,0CEh,0C0h, 20h
		db	 00h,0B8h, 0Fh, 21h, 00h,0E0h
		db	0FAh, 00h, 0Ah, 83h,0A0h, 00h
		db	0A0h, 8Eh, 80h, 02h, 80h, 8Eh
		db	 80h, 02h, 80h, 3Eh,0AAh, 0Ah
		db	 55h,0AAh,0AFh, 55h, 50h, 0Ah
		db	0AAh, 21h, 00h,0A0h,0AAh,0A0h
		db	 00h,0AAh, 0Ah,0AAh, 00h, 02h
		db	 4Ah, 02h, 45h, 02h,0ABh, 02h
		db	 54h, 2Ah,0BEh, 15h, 41h, 66h
		db	 00h, 79h, 00h,0EEh,0AAh, 11h
		db	 55h,0AFh,0FEh, 50h, 01h,0FFh
		db	0EFh, 00h, 10h,0FBh,0B0h, 04h
		db	 4Ah,0ECh, 0Ah, 12h,0A0h, 82h
		db	0AAh, 68h, 00h, 2Ah,0BFh, 80h
		db	 00h, 80h,0FFh, 3Fh, 00h,0F3h
		db	 00h, 0Ch,0EEh,0E0h,0AFh, 1Ah
		db	 00h, 0Ah,0FFh,0A0h, 00h, 2Bh
		db	0FFh, 80h, 00h,0BFh,0FFh, 21h
		db	 00h, 3Fh,0FFh, 80h, 21h, 00h
		db	0FCh,0FFh, 03h, 21h, 00h,0AFh
		db	0FAh, 21h, 00h,0EBh,0ABh,0F3h
		db	0FFh, 08h, 00h,0FCh, 3Fh, 03h
		db	 80h,0FFh,0CFh, 00h, 30h, 27h
		db	 00h, 21h, 00h, 27h, 00h, 21h
		db	 00h, 0Ch,0FFh,0F3h, 21h, 01h
		db	0AEh,0BAh,0FCh, 39h, 00h,0ACh
		db	0F0h,0FFh, 0Ah, 00h,0FCh,0FFh
		db	 03h, 00h,0FFh, 3Fh, 00h, 80h
		db	 27h, 00h, 21h, 00h, 27h, 00h
		db	 21h, 00h, 03h,0F0h,0F8h, 0Eh
		db	 00h, 03h,0BAh,0B8h,0FFh,0C3h
		db	 00h, 38h,0FFh, 3Fh, 00h,0C0h
		db	0FCh,0FFh, 03h, 00h,0FCh, 0Fh
		db	 02h,0B0h,0C3h,0FFh, 38h, 00h
		db	 3Ch,0FCh,0C3h, 39h, 00h,0F0h
		db	0ACh, 0Eh,0FCh, 0Fh, 03h,0A0h
		db	 0Fh,0F3h,0E0h, 08h,0CFh,0FAh
		db	 20h, 0Ah,0FFh,0AFh, 00h,0A0h
		db	0F7h,0FEh, 07h, 0Ah,0FFh,0EBh
		db	 0Ch,0ABh,0EFh,0BCh, 22h,0BCh
		db	0EFh,0C0h, 22h,0C0h,0BEh,0CFh
		db	 8Ah,0C0h,0BBh, 0Fh, 8Bh, 00h
		db	 0Eh, 0Ah, 00h,0A5h,0A8h,0B0h
		db	0A8h, 0Ah,0FBh, 8Eh,0AAh, 80h
		db	0EAh, 8Bh,0EAh, 80h, 2Ah,0E2h
		db	 2Ah,0A0h, 02h,0A3h, 02h,0A0h
		db	 02h,0A8h, 02h,0A8h, 00h, 88h
		db	 00h, 88h, 00h, 3Fh,0BAh,0C0h
		db	 03h,0C0h,0A8h, 3Fh, 2Bh,0FFh
		db	 80h, 00h,0AAh,0BBh, 50h, 00h
		db	 24h, 00h, 55h, 00h,0EEh,0AAh
		db	 11h, 54h,0AFh,0AEh, 50h, 51h
		db	0BAh,0FBh, 45h, 04h, 0Fh, 3Fh
		db	0F0h,0C0h,0F0h,0FFh, 0Fh, 00h
		db	0FEh, 2Fh, 00h,0C0h, 66h, 00h
		db	 21h, 00h,0EAh,0AAh, 21h, 00h
		db	 24h, 00h, 21h, 00h, 24h, 00h
		db	 55h, 00h,0BBh,0AAh, 44h, 55h
		db	0FFh,0FAh, 21h, 00h, 03h,0EFh
		db	0E8h, 00h,0EBh,0BAh, 21h, 00h
		db	0BEh,0EBh, 21h, 00h,0ABh,0AEh
		db	 21h, 00h,0AAh, 82h, 00h, 38h
		db	0A8h, 2Ah, 02h, 80h,0A2h,0AAh
		db	 0Ch, 05h,0AFh, 00h,0ABh, 00h
		db	0AFh, 80h,0ABh, 80h,0E8h, 80h
		db	 28h, 80h,0EBh,0A8h, 2Ah,0A8h
		db	0AAh, 8Bh, 0Ah, 8Bh,0A6h,0A0h
		db	 06h,0A0h, 8Ah,0AAh, 20h, 55h
		db	0AAh,0AFh, 55h, 50h, 00h, 88h
		db	 00h, 88h, 02h, 88h, 02h, 88h
		db	 03h, 22h, 03h, 20h, 3Ch, 8Ah
		db	 3Ch, 85h,0F3h,0ABh,0F3h, 54h
		db	 2Ah,0BEh, 15h, 41h, 66h, 00h
		db	 79h, 00h,0EEh,0AAh, 11h, 55h
		db	0AFh,0FEh, 50h, 01h,0FFh,0EFh
		db	 00h, 10h,0FBh,0B0h, 04h, 4Ah
		db	0ECh, 02h, 12h,0ACh, 82h, 22h
		db	 68h,0CCh, 2Ah, 03h, 80h,0FCh
		db	 2Ch,0CFh,0C3h, 30h,0FCh,0CFh
		db	 03h, 30h,0E0h,0ACh, 1Ah, 03h
		db	 0Ah,0F3h,0A0h, 0Ch, 2Bh,0F3h
		db	 80h, 0Ch,0BFh,0F0h, 00h, 0Fh
		db	 3Fh,0F3h, 80h, 0Ch,0FFh,0CFh
		db	 00h, 30h, 0Fh,0CFh,0A0h, 30h
		db	 03h,0DFh,0E8h, 20h,0F3h,0CFh
		db	 0Ch, 30h,0F3h, 4Fh, 0Ch,0B0h
		db	0CFh, 3Ch, 30h,0C3h,0DFh, 3Ch
		db	 20h,0C3h, 0Fh, 3Ch,0F0h,0C3h
		db	 3Fh, 0Ch,0C0h,0F3h, 7Fh, 0Fh
		db	 80h,0F0h, 3Fh, 4Ch,0C0h,0B3h
		db	0EEh,0EAh, 11h, 15h,0B0h, 00h
		db	 4Ah,0AAh, 0Ah,0A2h,0A0h, 0Ch
		db	 8Ah,0A2h, 30h, 0Ch,0AFh,0CFh
		db	 00h, 30h,0B9h, 00h,0B5h, 00h
		db	0FFh,0CEh, 00h, 31h, 3Fh,0CFh
		db	0C0h, 30h,0AAh,0EEh, 55h, 11h
		db	 00h, 0Ah,0AAh,0A5h, 80h,0A0h
		db	 61h, 0Ah, 80h, 22h, 60h, 4Ch
		db	 80h, 1Ch, 60h, 63h, 80h, 1Ch
		db	 68h, 63h,0E0h, 07h, 18h, 18h
		db	 80h, 07h, 68h, 18h, 3Fh, 3Eh
		db	0C0h,0C1h,0FFh, 2Ah, 00h,0D5h
		db	0FCh, 82h, 03h, 69h,0F2h, 00h
		db	 0Dh, 82h,0F0h, 80h, 0Eh, 60h
		db	0FAh, 00h, 05h, 80h,0E2h, 00h
		db	 19h, 8Ch,0E0h, 00h, 1Ah, 00h
		db	 80h, 07h, 60h, 18h, 00h, 07h
		db	0A0h, 58h, 00h, 1Ch, 8Ch, 63h
		db	 00h, 03h, 80h, 5Ch, 00h, 03h
		db	 01h, 7Ch, 01h,0CFh, 06h, 30h
		db	 04h,0CFh, 1Bh, 30h, 04h,0CFh
		db	 1Bh, 30h,0FEh,0EAh, 01h, 15h
		db	0BBh			; Data table (indexed access)
		db	0BEh, 44h, 41h, 0Ah,0BFh,0A5h
		db	 40h, 80h, 2Bh, 3Ah, 94h, 88h
		db	 82h, 33h, 29h,0C2h, 28h, 3Ch
		db	0C2h, 33h, 2Ch,0CCh,0C3h, 33h
		db	 3Bh,0CCh,0C0h, 33h,0CEh,0CCh
		db	 30h,0C0h,0CFh, 3Fh, 30h,0F0h
		db	0CCh, 0Fh, 33h,0F0h,0CCh, 0Fh
		db	 33h,0F0h, 32h, 0Fh,0CCh, 3Ch
		db	 33h,0C3h,0CCh, 3Ch, 23h,0C3h
		db	0CCh,0B8h, 32h, 03h,0CCh, 2Eh
		db	 0Ah,0C0h,0A5h, 3Bh,0B0h,0C0h
		db	 0Ah,0EFh,0CEh, 00h, 20h, 38h
		db	0BBh,0C3h, 00h, 2Eh,0A2h,0C0h
		db	 0Ch,0CBh, 2Bh, 30h,0C0h, 8Eh
		db	 2Ch, 30h,0C3h, 8Ah,0A8h, 30h
		db	 02h, 0Fh,0CFh,0B0h, 30h,0CFh
		db	0CCh, 20h, 33h, 2Bh,0F7h, 80h
		db	 08h, 8Ah,0B3h, 70h, 0Ch, 28h
		db	0A2h,0D7h, 0Ch, 2Ch, 80h,0D3h
		db	 7Fh, 23h,0A0h,0DCh, 5Fh, 82h
		db	0FBh, 7Dh, 04h, 3Fh, 0Fh,0C0h
		db	0F0h,0CCh, 0Fh, 33h,0F0h,0CDh
		db	 02h, 32h,0FDh, 88h, 08h, 33h
		db	0F6h,0E0h, 00h, 0Fh,0E8h, 04h
		db	 40h,0FBh,0B0h, 10h, 00h,0EFh
		db	0D7h, 01h, 00h,0FEh,0DDh,0A2h
		db	0ACh, 5Dh, 53h,0A2h,0A8h, 0Dh
		db	 57h, 08h,0A8h,0A3h, 17h,0A0h
		db	 2Ah, 5Ah, 80h,0BAh, 80h, 44h
		db	 2Ah,0EBh,0AAh, 14h, 50h,0BEh
		db	0EAh, 41h, 15h,0AFh,0FAh, 50h
		db	 05h,0C0h, 00h, 1Fh, 55h,0B0h
		db	 03h, 47h,0D4h,0A8h, 0Bh, 55h
		db	 54h, 2Ah, 0Ah,0D5h, 55h,0AAh
		db	 0Ah, 00h,0F5h, 00h, 02h,0AAh
		db	0DCh,0AAh, 00h, 55h, 24h, 01h
		db	 26h, 00h, 00h, 01h,0E8h,0C6h
		db	 80h, 01h, 68h, 06h, 20h, 01h
		db	 98h, 06h, 00h, 0Bh,0A0h, 10h
		db	 00h, 06h, 00h, 18h, 00h, 1Ah
		db	 00h, 60h, 28h,0AAh, 41h, 00h
		db	 2Fh,0A8h, 50h, 03h, 1Ch,0F8h
		db	 63h, 03h,0B0h,0ECh, 0Fh, 03h
		db	0E3h, 8Ah, 0Ch, 30h,0B2h,0EBh
		db	 0Ch, 00h,0A3h,0AEh, 0Ch, 00h
		db	 82h,0A8h, 3Ch, 03h, 40h, 80h
		db	 9Fh, 3Fh, 21h, 00h,0F5h,0F7h
		db	 02h, 88h,0D5h, 77h, 03h, 8Bh
		db	0F4h, 74h, 0Ah,0EEh,0D5h, 11h
		db	 0Eh,0AAh, 51h, 55h, 0Ah, 8Ah
		db	0D5h, 75h, 0Ah,0AAh, 75h, 00h
		db	 8Ah, 80h, 30h, 2Ah, 00h, 2Ah
		db	0AAh, 95h,0E4h, 22h, 0Bh, 44h
		db	0B0h, 33h, 0Fh, 4Ch,0D6h, 00h
		db	 0Dh, 0Fh,0A4h, 80h, 09h, 3Dh
		db	 80h, 00h, 3Fh,0D7h, 21h, 00h
		db	0FDh, 5Dh, 00h,0A2h, 5Dh, 5Dh
		db	 8Ah,0A3h, 75h, 5Ch, 8Ah,0AAh
		db	 30h, 00h, 08h, 8Ah, 73h, 30h
		db	 0Ah,0A8h,0D0h, 02h, 2Ah,0AAh
		db	0C0h, 05h, 00h,0ABh,0DFh, 54h
		db	 22h,0BEh,0DDh, 41h,0B3h,0BBh
		db	 4Ch, 44h,0EEh,0AAh, 11h, 55h
		db	 21h, 00h,0FEh,0A8h, 80h, 20h
		db	 7Ah, 80h, 00h, 2Ch,0EAh, 80h
		db	 00h,0ABh,0AAh, 21h, 00h, 0Ah
		db	0A0h, 21h, 01h,0A0h, 21h, 01h
		db	0A0h, 00h, 30h, 00h, 80h, 21h
		db	 00h, 80h, 21h, 01h, 30h, 21h
		db	 07h, 02h,0B0h, 21h, 00h, 08h
		db	 21h, 01h, 20h, 21h, 00h, 0Ah
		db	 80h, 21h, 00h, 20h, 00h,0FCh
		db	 21h, 01h,0BBh, 21h, 00h, 0Ah
		db	0ABh,0B0h, 00h, 08h, 0Ah,0AFh
		db	 21h, 01h, 2Ah, 02h, 80h, 21h
		db	 00h, 02h, 21h, 01h, 0Ah, 00h
		db	0C0h, 00h, 2Ah, 21h, 01h, 80h
		db	 21h, 0Bh,0F0h, 21h, 0Dh, 02h
		db	 21h, 01h, 0Ch, 21h, 07h, 80h
		db	 21h, 00h, 0Eh, 20h, 21h, 01h
		db	 08h, 21h, 01h, 02h,0A0h, 21h
		db	 01h, 08h, 00h, 2Fh, 2Bh,0D0h
		db	 0Ch, 03h, 02h,0FCh, 3Ch, 36h
		db	 00h,0FDh,0FAh, 21h, 00h,0AFh
		db	0A0h, 21h, 00h, 0Bh, 21h, 01h
		db	 0Bh, 21h, 01h, 0Bh, 00h, 0Ch
		db	 00h, 02h, 21h, 01h, 02h, 21h
		db	 0Bh, 0Fh, 21h, 0Dh, 3Bh, 21h
		db	 01h,0EEh, 80h, 00h, 0Eh,0FAh
		db	 20h, 00h,0FBh,0A0h, 21h, 00h
		db	0A8h, 00h, 02h, 21h, 02h, 80h
		db	 21h, 01h, 80h, 00h, 03h, 00h
		db	0A0h, 21h, 00h,0A0h, 00h, 28h
		db	 00h, 80h, 02h, 2Ah,0C0h, 80h
		db	 0Ah, 2Eh,0ACh, 80h, 00h,0AAh
		db	0FBh, 21h, 00h, 02h,0AAh, 28h
		db	 21h, 01h, 80h, 21h, 03h,0ACh
		db	 21h, 0Dh,0C0h, 21h, 01h,0BCh
		db	 21h, 01h,0AAh,0A0h, 21h, 05h
		db	 3Eh, 21h, 03h, 02h, 21h, 01h
		db	 02h, 21h, 03h, 03h, 21h, 01h
		db	 3Fh, 21h, 00h, 03h,0EAh, 21h
		db	 07h, 0Bh, 00h, 3Ch, 00h, 02h
		db	 03h,0ECh, 80h, 02h, 3Fh,0B8h
		db	 80h, 02h,0EEh,0EAh, 21h, 00h
		db	0BAh, 80h, 21h, 00h, 80h, 21h
		db	 00h, 28h, 21h, 01h, 02h, 00h
		db	 80h,0AFh, 7Eh, 00h, 20h, 2Bh
		db	0DFh, 00h, 0Ah, 02h,0F5h, 21h
		db	 00h, 02h,0FFh, 21h, 01h,0AFh
		db	 00h,0F0h, 00h, 0Ah, 00h,0FAh
		db	 00h, 02h, 03h,0AAh, 00h, 0Ah
		db	0FCh, 21h, 01h,0BBh, 21h, 00h
		db	 0Ah,0ABh,0B0h, 00h, 08h, 0Ah
		db	0AFh, 21h, 01h, 2Ah, 02h, 80h
		db	 00h, 0Eh, 02h, 0Eh, 00h, 03h
		db	 0Ah, 03h,0C0h, 00h, 2Ah, 21h
		db	 01h, 80h, 21h, 0Bh,0F0h, 21h
		db	 01h,0A8h, 00h,0A8h, 00h,0E8h
		db	 00h,0E8h, 00h,0E0h, 00h,0E0h
		db	 00h, 02h,0A8h, 00h,0A8h, 0Eh
		db	 80h, 02h, 80h, 02h, 00h, 02h
		db	 21h, 01h, 80h, 21h, 00h, 0Eh
		db	 20h, 21h, 01h, 08h, 21h, 01h
		db	 02h,0A0h, 21h, 01h, 08h,0FCh
		db	 21h, 01h,0BBh, 21h, 00h, 0Ah
		db	0ABh,0B0h, 00h, 08h, 0Ah,0AFh
		db	 21h, 01h,0AAh, 02h, 80h, 00h
		db	 2Bh, 02h, 2Bh, 00h, 0Eh, 0Ah
		db	 02h,0C0h, 0Ah, 2Ah, 0Ah, 21h
		db	 00h, 80h, 21h, 0Bh,0F0h, 21h
		db	 01h,0A0h, 00h,0A0h, 00h,0A0h
		db	 00h,0A0h, 00h,0E8h, 00h,0E8h
		db	 00h, 02h, 80h, 00h, 80h, 0Eh
		db	 80h, 02h, 80h, 0Ah, 00h, 0Ah
		db	 00h, 0Dh, 00h, 8Dh, 00h, 0Ch
		db	 0Eh, 2Ch, 21h, 01h, 08h, 21h
		db	 01h, 02h,0A0h, 21h, 01h, 08h
		db	0ACh, 03h, 21h, 01h, 03h, 21h
		db	 01h, 02h, 00h, 02h, 00h, 02h
		db	 00h, 02h,0C0h, 21h, 01h,0BCh
		db	 21h, 01h,0AAh,0A0h, 21h, 04h
		db	0B8h, 00h,0B8h, 00h,0A8h, 00h
		db	0A8h, 00h,0F8h, 00h,0F8h, 00h
		db	0F8h, 00h,0F8h, 00h,0A0h, 00h
		db	0A0h, 21h, 0Bh,0FCh, 21h, 01h
		db	0BBh, 21h, 00h, 0Ah,0ABh,0B0h
		db	 00h, 08h, 0Ah,0AFh, 21h, 01h
		db	 2Ah, 02h, 80h, 00h, 0Ah, 02h
		db	 0Ah, 21h, 00h, 0Ah, 00h,0C0h
		db	 00h, 2Ah, 21h, 01h, 80h, 21h
		db	 0Bh,0F0h, 21h, 01h,0A0h, 00h
		db	0A0h, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h, 00h,0A0h, 00h, 02h, 80h
		db	 00h, 80h, 0Eh, 00h, 02h, 00h
		db	 0Ah, 00h, 0Ah, 00h, 08h, 00h
		db	 88h, 00h, 28h, 0Eh, 28h, 00h
		db	 28h, 00h, 28h, 00h, 28h, 00h
		db	 2Ah,0A0h, 0Ah, 00h, 0Ah, 08h
		db	 2Ah, 00h, 2Ah, 02h, 2Ah, 00h
		db	 2Ah, 00h, 3Ah, 00h, 0Ah, 00h
		db	 2Ah, 00h, 2Ah, 00h, 2Eh, 0Fh
		db	 2Eh, 00h, 08h, 00h, 08h, 21h
		db	 07h, 20h, 00h, 20h, 00h, 20h
		db	 00h, 20h, 00h,0A0h, 00h,0A0h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0A8h, 00h, 20h, 00h, 20h
		db	 00h,0A0h, 00h,0A0h, 00h,0A8h
		db	 00h,0A8h, 21h, 0Ch, 02h, 00h
		db	 02h, 00h, 02h, 00h, 02h, 00h
		db	 02h, 00h, 02h, 21h, 06h,0A8h
		db	 00h,0A8h, 00h,0A8h, 00h,0A8h
		db	 00h,0E8h, 00h, 28h, 00h,0EAh
		db	 00h, 2Ah, 00h,0AAh, 00h,0AAh
		db	 00h,0BEh, 00h,0BEh, 00h,0B8h
		db	 00h,0B8h, 21h, 05h, 80h, 21h
		db	 0Bh,0F0h, 21h, 01h,0A0h, 00h
		db	0A0h, 00h, 20h, 00h, 20h, 00h
		db	 20h, 00h, 20h, 00h, 02h, 21h
		db	 01h, 0Ch, 21h, 01h, 08h, 00h
		db	 08h, 00h, 08h, 00h, 88h, 00h
		db	 08h, 0Eh, 28h, 00h, 08h, 00h
		db	 08h, 00h, 08h, 00h, 0Ah,0A0h
		db	 21h, 01h, 08h, 21h, 01h, 02h
		db	 21h, 02h, 08h, 00h, 08h, 21h
		db	 04h, 0Fh, 21h, 00h, 08h, 00h
		db	 08h, 21h, 07h
sub_1		endp


seg_a		ends



		end	start
