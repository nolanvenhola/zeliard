
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_352TILPL                                €€
;€€					                                 €€
;€€      Created:   5-Apr-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    5          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_352TILPL	proc	far

start:
		int	3			; Debug breakpoint
		adc	al,[bx+si]
		add	[bx+si],al
		push	es
		adc	al,[bx+si]
		push	ss
		add	[bx],dx
		adc	[bx+si],bl
		inc	ax
		sbb	[si],ax
		sbb	al,al
		sbb	ax,[bp+di]
		sbb	ax,1EF0h
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		and	al,30h			; '0'
		and	ax,2602h
		or	[bx],ah
		or	al,29h			; ')'
		and	[bp+di-45h],al
		inc	bp
		add	byte ptr [bp+22h],47h	; 'G'
		or	cx,[bx+di-55h]
		dec	dx
		or	word ptr [bp+di-56h],4Dh
		retn	0A4Eh
			                        ;* No entry point to code
		push	cx
		cmp	dl,[bp+si-52h]
		push	bx
		push	cs
		push	di
;*		jmp	far ptr loc_10		;*
		db	0EAh
		dw	0AF59h, 885Ah		;  Fixup - byte match
data_7		db	5Bh
		db	0BCh, 5Dh,0EEh, 5Eh,0FCh, 61h
		db	0B3h, 62h, 23h, 64h,0ACh, 65h
		db	 3Ch, 67h,0A0h, 68h,0E0h, 69h
		db	 8Ah, 6Ah,0B0h, 6Bh,0FAh, 6Dh
		db	 82h, 6Eh,0F3h
		db	'o,qPr/u8v?w'
		db	0FFh, 78h, 3Eh, 79h, 55h, 7Ah
		db	0B2h, 7Bh, 8Eh, 7Dh,0A2h, 7Eh
		db	0C3h, 81h,0CEh, 84h,0E2h, 86h
		db	 2Ah, 89h, 44h, 8Dh,0BAh, 90h
		db	0C8h, 91h,0E8h, 92h, 2Bh, 93h
		db	0A8h, 94h,0CFh, 95h,0E3h, 96h
		db	 11h, 97h, 8Bh, 98h,0F8h, 9Ah
		db	 41h, 9Bh,0CBh, 9Dh,0ECh, 9Eh
		db	0FDh,0A1h, 05h,0A4h, 3Bh,0A5h
		db	 8Ch,0A7h, 14h,0A9h,0B8h,0ADh
data_8		db	0EFh			; Data table (indexed access)
		db	0B1h, 32h,0B4h,0A3h,0B5h,0CAh
		db	0B6h
data_9		db	3Dh			; Data table (indexed access)
		db	0B7h,0EBh,0B9h,0F2h,0C5h, 28h
		db	0C7h, 2Eh,0C9h, 33h,0CDh, 15h
		db	0D0h, 54h,0D1h,0BFh,0D2h,0F4h
		db	0D3h, 60h,0D4h, 8Fh,0D6h,0CCh
		db	0D7h,0F5h,0D8h,0FBh,0D9h,0FEh
		db	0DDh, 66h,0DEh, 7Fh,0DFh, 99h
		db	0E4h, 48h,0E5h, 6Ch,0E6h, 73h
		db	0E7h,0BEh,0E9h,0F7h,0EDh, 1Ch
		db	0F9h, 21h,0FFh,0FFh, 12h, 2Eh
		db	0FDh, 3Fh, 55h, 85h, 00h, 05h
		db	0F5h, 3Dh,0F1h, 5Ch, 00h, 1Ch
		db	0FDh, 3Fh,0FDh, 9Fh, 00h, 1Fh
		db	 55h, 15h, 79h, 00h, 00h, 15h
		db	 12h, 00h,0DFh, 00h, 12h, 00h
data_10		dw	0F4FFh			; Data table (indexed access)
		db	 15h, 56h, 15h, 54h
loc_2:
		push	word ptr [si+7Fh]
		xor	ax,347Fh
		div	sp			; ax,dx rem=dx:ax/reg
		jnc	loc_2			; Jump if carry=0
		jnc	loc_2			; Jump if carry=0
		std				; Set direction flag
		aas				; Ascii adjust
		push	bp
;*		test	dx,[di+0]
		db	 85h, 55h, 00h		;  Fixup - byte match
		db	0FDh, 3Fh,0FDh, 5Fh,0FDh, 00h
		db	0FDh, 3Dh,0FDh, 9Ch,0FDh, 00h
		db	 55h, 15h, 79h, 01h, 12h, 01h
		db	0DFh, 00h, 12h
loc_3:
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
		hlt				; Halt processor
		adc	ax,1256h
;*		add	bh,dh
		db	 00h,0F7h		;  Fixup - byte match
		hlt				; Halt processor
		jnc	loc_3			; Jump if carry=0
		adc	al,[bx+si]
		push	word ptr [si+7Fh]
		adc	al,ss:[bx+si]
		push	bp
		push	sp
		jns	$+3			; Jump if not sign
		push	sp
		adc	al,[bx+si]
		db	0DDh, 00h, 12h, 02h,0D8h, 00h
		db	0A3h,0A2h, 12h, 00h,0EFh,0AFh
		db	 8Ah, 0Ah, 12h, 00h,0EEh,0ABh
		db	0C8h, 02h, 12h, 00h,0AAh,0EBh
		db	 00h, 82h, 12h, 00h,0AEh,0EAh
		db	 08h, 80h, 12h, 00h,0AAh,0BBh
		db	 00h, 22h, 55h, 54h, 79h, 00h
		db	 12h, 02h,0DDh, 00h, 12h, 02h
		db	0BEh,0FDh, 28h,0A8h, 12h, 00h
		db	0EBh,0EFh, 82h, 8Bh, 12h, 00h
		db	0BBh,0BAh, 22h, 30h, 12h, 00h
		db	0AEh,0EEh, 08h, 88h, 12h, 00h
		db	0AEh,0BAh, 08h, 20h, 12h, 00h
		db	0BAh,0AEh, 20h, 08h, 12h, 00h
		db	0BAh,0BBh, 20h, 22h, 12h, 00h
		db	0ABh,0AAh, 02h, 12h, 01h,0EAh
		db	0AAh, 80h, 12h, 01h,0BAh,0AEh
		db	 20h, 08h, 12h, 00h,0AEh,0AAh
		db	 08h, 12h, 01h,0AAh,0BAh, 00h
		db	 20h, 12h, 00h, 4Bh, 00h, 12h
		db	 02h, 4Bh, 00h, 12h, 02h,0EBh
		db	0AEh, 82h, 08h, 12h, 00h,0AAh
		db	0EAh, 00h, 80h, 12h, 00h,0EEh
		db	0BAh, 88h, 20h, 12h, 00h, 4Bh
		db	 00h, 12h, 02h,0ABh,0AAh, 02h
		db	 12h, 01h,0AAh,0AEh, 00h, 08h
		db	 12h, 00h,0ABh,0AAh, 02h, 12h
		db	 01h, 4Bh, 00h, 12h, 04h, 0Ah
		db	0AFh, 12h, 01h, 03h, 02h,0EFh
		db	 12h, 01h, 10h, 22h,0BCh, 12h
		db	 02h, 0Ah,0F0h, 12h, 02h, 2Ah
		db	0C0h, 12h, 00h, 04h, 00h,0AEh
		db	0C0h, 12h, 01h,0C0h,0ABh,0C0h
		db	 12h, 02h,0ABh, 0Ah, 12h
data_12		dw	0C002h			; Data table (indexed access)
		db	0B3h, 12h, 02h, 02h,0F3h, 12h
		db	 02h, 0Bh,0CBh, 12h, 02h, 2Fh
		db	 0Ch, 12h, 00h, 03h, 00h,0AFh
		db	 2Ch, 12h, 02h,0BBh, 30h, 12h
		db	 02h,0BBh, 30h, 12h, 02h,0FCh
		db	0B2h, 12h, 01h, 10h, 0Bh,0F0h
		db	 12h, 01h,0C0h, 03h,0C2h, 12h
		db	 00h, 01h, 00h, 23h, 08h, 12h
		db	 01h, 40h, 0Bh,0C2h, 12h, 00h
		db	 01h, 00h, 0Bh,0C0h, 12h, 01h
		db	 40h,0ACh,0C2h, 12h, 00h, 11h
		db	 00h,0BBh,0C0h, 12h, 00h, 04h
		db	 00h,0AFh, 0Ah, 12h, 02h, 08h
		db	0B3h, 12h, 00h, 01h, 00h, 23h
		db	0F3h, 12h, 02h, 8Bh,0CBh, 12h
		db	 00h, 0Ch, 00h, 2Fh,0CCh, 12h
		db	 02h,0AFh, 2Ch, 12h, 02h,0BBh
		db	 30h, 12h, 02h,0BBh, 30h, 12h
		db	 02h,0FCh,0B2h, 12h, 02h, 0Bh
		db	0F0h, 12h, 02h, 03h,0C2h, 12h
		db	 02h, 23h, 08h, 12h, 02h, 0Bh
		db	0C2h, 12h, 02h, 0Bh,0C0h, 12h
		db	 02h,0ACh,0C2h, 12h, 02h,0BBh
		db	0C0h, 12h, 02h,0AFh, 0Ah, 12h
		db	 02h, 08h,0B3h, 12h, 02h
		db	23h
data_13		db	0F3h			; Data table (indexed access)
		db	 12h, 02h, 8Bh,0CBh, 12h, 02h
		db	 2Fh,0CCh, 12h, 02h,0AFh, 2Ch
		db	 12h, 02h,0BBh, 30h, 12h, 02h
		db	0BBh, 30h, 12h, 02h,0FCh,0B2h
		db	 12h, 02h,0AEh, 2Bh, 12h, 02h
		db	0BCh,0AEh, 12h, 00h, 04h, 00h
		db	0FCh,0ACh, 12h, 00h, 30h, 00h
		db	0F2h,0F3h, 12h, 01h, 40h, 0Fh
		db	0C2h, 12h, 00h, 04h, 01h, 3Ch
		db	 8Bh, 12h, 02h, 32h, 2Fh, 12h
		db	 00h, 10h, 01h,0F0h,0FFh, 12h
		db	 01h, 10h,0E2h,0B8h, 12h, 01h
		db	 44h, 0Ah

locloop_4:
		cld				; Clear direction
		adc	al,[bp+si]
		mov	ah,dl
		adc	al,[bx+di]
		push	ax
		stosw				; Store ax to es:[di]
		db	0F3h, 12h, 01h, 40h,0AFh,0CBh
		db	 12h, 00h, 01h, 00h,0FFh, 0Bh
		db	 12h, 00h, 04h, 00h,0FCh, 3Ch
		db	 12h, 00h, 40h, 00h,0C0h,0B3h
		db	 12h, 02h,0AEh, 2Bh, 12h, 02h
		db	0BCh,0AEh, 12h, 02h,0F0h,0ACh
		db	 12h, 02h,0C2h,0F0h, 12h, 00h
		db	 01h, 00h, 0Fh, 02h, 12h, 02h
		db	 30h, 8Ah, 12h, 01h, 01h, 32h
		db	 2Bh, 12h, 02h,0C0h,0ABh, 12h
		db	 02h

locloop_5:
		loop	locloop_4		; Loop if cx > 0

		adc	al,[bp+si]
		or	dh,al
		adc	al,[bx+si]
		add	[bx+si],ax
		mov	ax,dx
		adc	al,[bp+si]
		stosw				; Store ax to es:[di]
		db	0F3h, 12h, 00h, 10h, 00h,0BBh
		db	0CBh, 12h, 00h,0C0h, 00h,0FCh
		db	 0Bh, 12h, 02h,0F0h, 3Ch, 12h
		db	 02h,0F0h,0B3h, 12h, 02h,0AEh
		db	 2Bh, 12h, 02h,0BCh,0AEh, 12h
		db	 02h,0FCh,0ACh, 12h, 02h,0F2h
		db	0F3h, 12h, 02h, 0Fh,0C2h, 12h
		db	 02h, 3Ch, 8Bh, 12h, 02h, 32h
		db	 2Fh, 12h, 02h,0F0h,0FFh, 12h
		db	 02h,0E2h,0B8h, 12h, 02h, 0Ah
		db	0FCh, 12h, 02h, 8Ah,0E2h, 12h
		db	 02h,0ABh,0F3h, 12h, 02h,0AFh
		db	0CBh, 12h, 02h,0FFh, 0Bh, 12h
		db	 02h,0FCh, 3Ch, 12h, 02h,0C0h
		db	0B3h, 12h, 02h,0AEh, 2Bh, 12h
		db	 00h, 01h, 00h,0BDh,0AEh, 12h
		db	 02h,0F0h,0ACh, 12h, 01h, 03h
		db	0C2h,0F3h, 12h, 01h, 40h, 0Fh
		db	 42h, 12h, 00h, 01h, 00h, 31h
		db	 8Ah, 12h, 02h, 32h, 2Fh, 12h
		db	 02h,0C0h,0FCh, 12h, 02h,0E2h
		db	0B8h, 12h, 02h, 0Ah,0F0h, 12h
		db	 02h, 8Ah,0E2h, 12h, 02h,0ABh
		db	0C3h, 12h, 01h, 10h,0AFh,0DBh
		db	 12h, 02h,0FFh, 0Bh, 12h, 00h
		db	 04h, 00h,0F4h, 3Ch, 12h, 00h
		db	 10h, 00h, 10h,0B3h, 12h, 01h
		db	0C0h, 0Bh,0C0h, 12h, 00h, 10h
		db	 00h, 13h, 02h, 12h, 02h, 23h
		db	 08h, 12h, 01h, 04h, 0Bh, 06h
		db	 12h, 02h
data_14		db	0Ah			; Data table (indexed access)
		db	0C0h, 12h, 00h, 19h, 00h,0A6h
		db	0C6h, 12h, 02h,0AAh,0C0h, 12h
		db	 02h,0ABh, 0Ah, 12h, 02h, 08h
		db	0B3h, 12h, 02h, 22h,0F3h, 12h
		db	 01h, 10h, 8Bh,0DBh, 12h, 01h
		db	 40h, 2Fh, 4Ch, 12h, 01h, 40h
		db	0AFh, 6Ch, 12h, 02h,0BBh, 30h
		db	 12h, 02h,0BBh, 30h, 00h, 10h
		db	 00h, 10h,0FCh,0B2h, 12h, 02h
		db	0ACh, 2Bh, 12h, 02h,0BCh,0ACh
		db	 12h, 02h,0F0h,0ACh, 12h, 02h
		db	0C2h,0F0h, 12h, 02h, 0Fh, 02h
		db	 12h, 02h, 30h, 8Ah, 12h, 02h
		db	 32h, 2Fh, 00h, 50h, 00h, 50h
		db	0C0h,0FCh, 00h, 10h, 00h, 10h
		db	0C2h,0B0h, 00h, 10h, 00h, 10h
		db	 0Ah,0F0h, 12h, 02h, 8Ah,0C2h
		db	 00h, 40h, 00h, 40h,0ABh,0C3h
		db	 00h, 40h, 00h, 40h,0AFh,0CBh
		db	 05h, 00h, 05h, 00h,0FFh, 0Bh
		db	 50h, 00h, 50h, 00h,0F0h, 3Ch
		db	 12h, 03h,0B3h, 00h, 40h, 00h
		db	 40h, 0Bh,0C0h, 01h, 00h, 01h
		db	 00h, 03h, 02h, 01h, 00h, 01h
		db	 00h, 23h, 08h, 12h, 02h, 0Bh
		db	 02h, 12h, 02h, 2Ah,0C0h, 00h
		db	 40h, 00h, 40h,0BBh,0C2h, 04h
		db	 00h, 04h, 00h,0EFh, 30h, 10h
		db	 00h, 10h, 00h,0BCh, 30h, 12h
		db	 02h, 0Bh, 12h, 03h, 03h, 02h
		db	 12h, 02h, 23h, 08h, 12h, 02h
		db	 0Bh, 02h, 12h, 02h, 2Ah,0C0h
		db	 12h, 02h,0ABh,0C2h, 12h, 02h
		db	0AEh,0C0h, 12h, 02h,0ABh, 08h
		db	 00h, 01h, 00h, 01h, 09h, 5Fh
		db	 04h, 00h, 04h, 00h, 0Dh,0DCh
		db	 12h, 02h, 21h, 7Ch, 17h, 02h
		db	 39h,0F0h, 12h, 02h, 0Bh,0C0h
		db	 00h, 40h, 00h, 40h, 2Eh,0C0h
		db	 00h, 40h, 00h, 40h,0ABh,0C0h
		db	 01h, 00h, 01h, 00h, 2Bh, 08h
		db	 12h, 02h, 0Bh, 12h, 03h, 03h
		db	 02h, 12h, 02h, 23h, 08h, 12h
		db	 02h, 0Bh, 02h, 12h, 02h, 08h
		db	0C0h, 00h, 41h, 00h, 41h,0A2h
		db	0C3h, 00h, 40h, 00h, 40h, 88h
		db	0C0h, 16h, 02h, 23h, 0Bh, 12h
		db	 02h,0CEh, 03h, 12h, 00h, 88h
		db	 00h,0CFh, 80h, 12h, 02h,0E3h
		db	0E0h, 12h, 00h, 20h, 00h, 30h
		db	0F8h, 12h, 02h, 38h,0FAh, 12h
		db	 01h, 80h, 0Ch,0EEh, 12h, 01h
		db	0C8h, 0Ch,0EEh, 12h, 00h, 08h
		db	 02h, 8Eh, 3Fh, 12h, 01h, 02h
		db	0F5h, 63h, 12h, 00h,0C0h, 00h
		db	0F7h, 40h, 12h, 02h, 3Dh, 48h
		db	 12h, 02h, 0Fh, 60h, 12h, 02h
		db	 03h,0A8h, 12h, 00h, 0Ch, 00h
		db	 0Fh,0AAh, 12h, 00h, 02h, 00h
		db	 03h,0EAh, 12h, 01h, 30h,0A0h
		db	0FAh, 12h, 00h, 08h, 00h,0CEh
		db	 20h, 12h, 02h,0CFh, 88h, 12h
		db	 00h, 82h, 00h,0E3h,0EAh, 12h
		db	 01h, 80h, 30h,0F8h, 12h, 00h
		db	 02h,0E0h, 3Bh,0FAh, 12h, 01h
		db	 80h, 0Ch,0EEh, 12h, 01h, 80h
		db	 0Ch,0EEh, 12h, 00h, 26h, 00h
		db	 8Eh, 3Fh, 12h, 00h, 02h, 08h
		db	 03h,0ECh, 12h, 01h, 02h, 80h
		db	0C3h, 12h, 00h, 02h, 00h, 23h
		db	0C8h, 12h, 02h, 80h,0E0h, 12h
		db	 02h, 03h,0A8h, 12h, 00h, 02h
		db	 20h, 83h,0BAh, 12h, 00h,0C0h
		db	 88h,0C3h,0EEh, 12h, 01h, 20h
		db	0A0h,0FAh, 12h, 00h, 82h, 02h
		db	0CFh, 83h, 12h, 00h, 28h, 00h
		db	 3Fh,0A0h, 12h, 00h, 22h, 00h
		db	0B3h,0A2h, 12h, 00h, 08h, 80h
		db	0CFh,0EAh, 12h, 00h, 02h, 00h
		db	0E3h,0FAh, 12h, 00h, 30h, 88h
		db	0F0h,0FFh, 12h, 01h, 02h, 3Ch
		db	 0Fh, 12h, 02h,0CEh, 12h, 01h
		db	 20h, 00h,0F8h, 3Ah, 12h, 00h
		db	 80h, 20h,0FAh, 3Eh, 12h, 01h
		db	 08h, 3Ah, 0Fh, 12h, 00h, 02h
		db	 00h, 0Fh, 83h, 12h, 01h, 20h
		db	 80h,0F0h, 12h, 02h,0A2h, 0Ch
		db	 12h, 02h,0F8h, 8Ch, 12h, 00h
		db	 88h, 02h,0FFh, 03h, 12h, 00h
		db	 20h, 0Ch, 3Eh, 8Fh, 12h, 00h
		db	 02h, 00h, 0Fh,0A0h, 12h, 02h
		db	 83h,0A2h, 12h, 01h, 80h,0CFh
		db	0EAh, 12h, 00h, 03h, 00h,0E3h
		db	0DAh, 12h, 01h, 80h,0E0h,0FDh
		db	 12h, 02h, 3Ch, 0Fh, 12h, 02h
		db	0CEh, 0Fh, 12h, 02h,0E8h, 3Ah
		db	 12h, 00h, 30h, 00h, 3Ah, 3Eh
		db	 12h, 02h, 3Ah, 0Fh, 12h, 02h
		db	 0Fh, 83h, 12h, 02h, 80h,0F0h
		db	 12h, 01h, 08h,0A2h, 0Ch, 12h
		db	 02h, 58h, 8Ch, 12h, 02h,0D5h
		db	 03h, 12h, 02h,0E8h, 3Ah, 12h
		db	 02h, 3Ah, 3Eh, 12h, 02h, 3Ah
		db	 0Fh, 12h, 02h, 0Fh, 83h, 12h
		db	 02h, 80h,0F0h, 12h, 02h,0A2h
		db	 0Ch, 12h, 02h, 58h, 8Ch, 12h
		db	 02h,0D5h, 03h, 12h, 02h,0E8h
		db	 3Ah, 12h, 02h, 3Ah, 3Eh, 12h
		db	 02h, 3Ah, 0Fh, 12h, 02h, 0Fh
		db	 83h, 12h, 02h, 80h,0F0h, 12h
		db	 02h,0A2h, 0Ch, 12h, 02h,0F8h
		db	 8Ch, 10h, 00h, 10h, 00h, 3Fh
		db	 03h, 12h, 02h,0F5h, 60h, 12h
		db	 02h, 37h, 40h, 10h, 00h, 10h
		db	 00h, 3Dh, 48h, 12h, 02h, 0Fh
		db	 60h, 04h, 40h, 04h, 40h, 2Fh
		db	0E8h, 12h, 02h, 03h,0AAh, 01h
		db	 00h, 01h, 00h, 03h,0EAh, 00h
		db	 40h, 00h, 40h,0A0h,0EAh, 04h
		db	 00h, 04h, 00h, 0Eh, 83h, 12h
		db	 02h, 0Fh,0A0h, 00h, 40h, 00h
		db	 40h, 83h,0E2h, 12h, 02h,0C3h
		db	0EAh
loc_6:
		add	[bx+si],ax
		add	[bx+si],ax
		jcxz	loc_6			; Jump if cx=0
;*		add	[si+0],dl
		db	 00h, 54h, 00h		;  Fixup - byte match
		db	 54h,0E0h,0FFh, 10h, 05h, 10h
		db	 05h, 3Ch, 0Fh, 04h, 00h, 04h
		db	 00h, 0Eh, 12h, 03h, 0Eh, 83h
		db	 12h, 02h, 0Fh,0A0h, 12h, 02h
		db	 83h,0A2h, 01h, 00h, 01h, 00h
		db	0C3h,0EAh
loc_7:
		add	[bx+si],ax
		add	[bx+si],ax
		jcxz	loc_7			; Jump if cx=0
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		;  Fixup - byte match
		db	 40h,0E0h,0FFh, 00h, 05h, 00h
		db	 05h, 3Ch, 0Fh, 12h, 02h, 0Eh
		db	 12h, 03h, 0Eh, 83h, 12h, 02h
		db	 0Fh,0A0h, 12h, 02h, 83h,0A2h
		db	 12h, 02h,0CFh,0EAh, 12h, 02h
		db	0E3h,0DAh, 12h, 02h,0E0h, 3Dh
		db	 12h, 02h, 3Ch, 0Fh, 12h, 02h
		db	0CEh, 0Fh, 12h, 02h, 0Eh, 83h
		db	 12h, 02h, 0Fh,0A0h, 12h, 02h
		db	 83h
loc_8:
		mov	byte ptr data_12,al
		retn
			                        ;* No entry point to code
;*		jmp	far ptr loc_12		;*
		db	0EAh
		dw	212h, 0FAE3h		;  Fixup - byte match
			                        ;* No entry point to code
		adc	al,[bp+si]
		db	0E0h,0FFh, 12h, 02h, 3Ch, 0Fh
		db	 12h, 02h,0CEh, 12h, 03h,0CEh
		db	 03h, 12h, 02h,0CFh, 80h, 12h
		db	 02h,0E3h,0E0h, 12h, 02h, 30h
		db	0F8h, 12h, 02h, 38h,0FAh, 12h
		db	 02h, 0Ch,0EEh, 12h, 02h, 0Ch
		db	0EEh, 12h, 02h, 8Eh, 3Fh, 12h
		db	 03h,0E0h, 12h, 02h, 80h,0C0h
		db	 12h, 02h, 20h,0C8h, 12h, 02h
		db	 80h,0E0h, 12h, 02h, 03h,0A8h
		db	 12h, 02h, 83h,0BAh, 12h, 02h
		db	 03h,0EAh, 12h, 02h,0A0h,0FAh
		db	 12h, 02h,0F5h, 60h, 12h, 02h
		db	 37h, 40h, 12h, 02h, 3Dh, 48h
		db	 12h, 02h, 0Fh, 60h, 12h, 02h
		db	 03h,0A8h, 12h, 02h, 03h,0AAh
		db	 12h, 02h, 03h,0EAh, 12h, 02h
		db	0A0h,0EAh, 12h, 02h,0CEh, 03h
		db	 12h, 02h,0CFh, 80h, 12h, 02h
		db	0E3h,0E0h, 10h, 00h, 10h, 00h
		db	 30h,0F8h, 10h, 00h, 10h, 00h
		db	 38h,0FAh, 00h, 40h, 00h, 40h
		db	 0Ch,0EEh, 00h, 40h, 00h, 40h
		db	 0Ch,0EEh, 00h, 14h, 00h, 14h
		db	 8Eh, 3Fh, 12h, 02h,0E8h, 3Ah
		db	 12h, 02h, 3Ah, 3Eh, 10h, 00h
		db	 10h, 00h, 3Ah, 0Fh, 01h, 00h
		db	 01h, 00h, 0Fh, 83h, 12h, 02h
		db	 80h,0F0h, 12h, 02h,0A2h, 0Ch
		db	 00h, 04h, 00h, 04h,0F8h, 8Ch
		db	 14h, 00h, 14h, 00h, 3Fh, 03h
		db	 40h, 00h, 40h, 00h,0CEh, 20h
		db	 44h, 00h, 44h, 00h,0CFh, 88h
		db	 01h, 00h, 01h, 00h, 23h,0EAh
		db	 12h, 02h, 30h,0F8h, 00h, 40h
		db	 00h, 40h, 38h,0FAh, 00h, 40h
		db	 00h, 40h, 0Ch,0ECh, 00h, 40h
		db	 00h, 40h, 0Ch,0EEh, 12h, 02h
		db	 8Eh, 3Fh, 12h, 03h,0E0h, 12h
		db	 02h, 80h, 12h, 03h, 20h,0C8h
		db	 12h, 02h, 80h, 20h, 12h, 02h
		db	 03h, 20h, 12h, 02h, 80h, 88h
		db	 12h, 02h, 03h,0A2h, 12h, 02h
		db	0A0h,0E8h, 12h, 02h,0ABh, 22h
		db	 12h, 02h,0ABh, 2Ah, 41h, 00h
		db	 41h, 00h,0EFh, 0Ah, 01h, 00h
		db	 01h, 00h,0AFh, 2Ah, 04h, 00h
		db	 04h, 00h,0ACh, 23h, 04h, 00h
		db	 04h, 00h,0ECh, 0Eh, 10h, 00h
		db	 10h, 00h,0F0h, 0Eh, 40h, 01h
		db	 40h, 01h,0C0h, 03h, 12h, 02h
		db	 08h,0B3h, 12h, 02h, 22h,0F3h
		db	 12h, 02h,0ABh,0CBh, 00h, 04h
		db	 00h, 04h, 2Fh, 0Ch, 00h, 04h
		db	 00h, 04h,0AFh, 2Ch, 12h, 02h
		db	0BBh, 30h, 00h, 10h, 00h, 10h
		db	0BBh, 30h, 00h, 10h, 00h, 10h
		db	0FCh,0B0h, 12h, 02h, 08h,0B3h
		db	 00h, 10h, 00h, 10h, 22h,0F3h
		db	 00h, 41h, 00h, 41h,0ABh,0CBh
		db	 12h, 02h, 2Fh, 0Ch, 01h, 04h
		db	 01h, 04h,0AFh, 2Ch, 05h, 00h
		db	 05h, 00h,0BFh, 30h, 01h, 10h
		db	 01h, 10h,0BBh, 30h, 04h, 00h
		db	 04h, 00h,0FCh, 12h, 03h,0BBh
		db	 80h, 00h, 01h, 00h, 01h,0BCh
		db	 03h, 12h, 02h,0BCh, 08h, 10h
		db	 00h, 10h, 00h,0F0h, 22h, 10h
		db	 00h, 10h, 00h,0B0h, 0Ah, 40h
		db	 01h, 40h, 01h,0C0h, 2Bh, 40h
		db	 00h, 40h, 00h,0C0h, 0Ch, 12h
		db	 08h,0ABh, 2Ah, 04h, 00h, 04h
		db	 00h,0AEh, 0Ah, 01h, 00h, 01h
		db	 00h,0BBh, 23h, 41h, 01h, 41h
		db	 01h,0EBh, 0Bh, 00h, 01h, 00h
		db	 01h,0BCh, 0Bh, 19h, 02h,0ACh
		db	 1Ch, 10h, 00h, 10h, 00h,0F0h
		db	 0Ch, 40h, 00h, 40h, 00h,0C0h
		db	 12h, 03h,0AEh, 22h, 12h, 02h
		db	0FEh, 08h, 12h, 02h,0C2h, 22h
		db	 12h, 02h,0C3h, 0Ah, 12h, 02h
		db	 0Ah, 82h, 12h, 02h, 22h,0CAh
		db	 12h, 02h, 0Ah,0C2h, 12h, 02h
		db	 2Ah,0CAh, 12h, 02h,0ABh, 22h
		db	 12h, 02h,0ABh, 0Ah, 12h, 02h
		db	0A8h, 2Ah, 12h, 02h,0A8h, 8Ah
		db	 12h, 02h,0B8h, 2Ah, 12h, 02h
		db	0AEh, 0Ah, 12h, 02h,0AEh, 2Ah
		db	 12h, 02h,0BAh, 0Ah, 00h, 40h
		db	 00h, 40h,0AEh,0C2h, 12h, 02h
		db	0AFh, 12h, 03h,0BEh,0C0h, 12h
		db	 02h,0EBh, 12h, 03h,0EBh, 08h
		db	 12h, 02h,0FBh, 22h, 12h, 02h
		db	0EFh, 02h, 12h, 02h,0BBh, 02h
		db	 12h, 02h,0AFh, 08h, 01h, 00h
		db	 01h, 00h,0BFh, 3Ah, 01h, 00h
		db	 01h, 00h,0EFh, 3Ah, 00h, 01h
		db	 00h, 01h,0BBh, 0Fh, 04h, 00h
		db	 04h, 00h,0ECh, 17h, 00h, 00h
		db	 10h, 00h,0B0h, 04h, 12h, 02h
		db	0C1h, 10h, 40h, 00h, 40h, 00h
		db	0C0h, 44h, 40h, 00h, 40h, 00h
		db	0C1h, 12h, 03h,0C4h, 40h, 12h
		db	 02h, 01h, 12h, 21h, 0Ah, 3Bh
		db	 00h, 40h, 00h, 40h, 22h,0E0h
		db	 12h, 02h,0AAh,0A3h, 12h, 02h
		db	 23h, 8Fh, 01h, 00h, 01h, 00h
		db	0A3h, 2Fh, 01h, 00h, 01h, 00h
		db	 8Bh, 88h, 12h, 02h,0BBh, 03h
		db	 10h, 00h, 10h, 00h,0FCh, 82h
		db	 01h, 00h, 01h, 00h,0B3h, 02h
		db	 01h, 00h, 01h, 00h,0B3h, 08h
		db	 12h, 02h,0CFh, 02h, 12h, 02h
		db	0CFh, 08h, 12h, 02h, 2Ch, 28h
		db	 04h, 00h, 04h, 00h,0ACh, 80h
		db	 12h, 02h,0BCh, 22h, 00h, 01h
		db	 00h, 01h,0BBh, 03h, 12h, 02h
		db	 8Ah, 22h, 00h, 10h, 00h, 10h
		db	 22h, 32h, 00h, 01h, 00h, 01h
		db	 8Ah, 0Bh, 00h, 04h, 00h, 04h
		db	 22h, 0Eh, 12h, 02h, 5Ah, 00h
		db	 12h, 02h, 28h,0B2h, 00h, 01h
		db	 00h, 01h, 82h,0B3h, 12h, 02h
		db	 2Bh,0E1h, 12h, 02h,0EEh,0C0h
		db	 00h, 11h, 00h, 11h, 3Fh, 33h
		db	 00h, 10h, 00h, 10h, 82h,0B0h
		db	 01h, 40h, 01h, 40h,0ABh,0C0h
		db	 10h, 00h, 10h, 00h,0FCh, 12h
		db	 11h, 04h, 00h, 04h, 00h, 6Ch
		db	 00h, 04h, 00h, 04h, 00h, 6Ch
		db	 00h, 10h, 00h, 10h, 00h, 70h
		db	 12h, 03h, 10h, 12h, 03h, 10h
		db	 12h, 11h, 40h, 00h, 40h, 00h
		db	0C0h, 88h, 18h, 02h,0C2h,0E3h
		db	 12h, 02h, 8Ah,0ABh, 00h, 04h
		db	 00h, 04h, 2Bh,0BCh, 12h, 02h
		db	0ACh,0F0h, 04h, 10h, 04h, 10h
		db	 2Ch,0F0h, 04h, 10h, 04h, 10h
		db	0ACh, 30h, 12h, 02h, 2Ch, 12h
		db	 03h,0EEh, 22h, 12h, 02h,0BEh
		db	 0Ah, 12h, 02h,0ABh, 22h, 12h
		db	 02h,0AEh, 0Ah, 00h, 01h, 00h
		db	 01h,0ABh, 23h, 11h, 01h, 11h
		db	 01h,0BBh, 0Bh, 01h, 00h, 01h
		db	 00h,0ABh, 22h, 00h, 04h, 00h
		db	 04h,0ACh, 0Eh, 14h, 00h, 14h
		db	 00h,0BCh, 28h, 12h, 02h, 80h
		db	0A3h, 00h, 01h, 00h, 01h,0C8h
		db	 0Bh, 00h, 01h, 00h, 01h, 02h
		db	 8Fh, 00h, 01h, 00h, 01h, 08h
		db	 83h, 12h, 02h, 22h, 8Bh, 00h
		db	 04h, 00h, 04h, 8Ah, 0Ch, 12h
		db	 02h, 22h, 30h, 19h, 02h,0AEh
		db	 3Ch, 10h, 00h, 10h, 00h,0B3h
		db	 30h, 00h, 10h, 00h, 10h,0C0h
		db	0F0h, 18h, 02h, 1Ah, 00h, 12h
		db	 16h, 40h, 00h, 40h, 00h,0C0h
		db	0B0h, 00h, 10h, 00h, 10h, 02h
		db	0F0h, 00h, 40h, 00h, 40h, 0Bh
		db	0C3h, 12h, 02h, 2Fh, 0Ch, 12h
		db	 02h,0AFh, 20h, 01h, 00h, 01h
		db	 00h,0BBh, 00h, 01h, 00h, 01h
		db	 00h,0BBh, 30h, 04h, 00h, 04h
		db	 00h,0FCh, 82h, 10h, 00h, 10h
		db	 00h, 3Ah, 20h, 10h, 00h, 10h
		db	 00h,0B2h, 80h, 40h, 00h, 40h
		db	 00h,0CAh, 82h, 12h, 02h, 02h
		db	 88h, 12h, 02h,0A0h, 82h, 00h
		db	 01h, 00h, 01h, 20h, 0Bh, 12h
		db	 02h, 30h, 2Ch, 00h, 04h, 00h
		db	 04h, 30h, 8Ch, 00h, 44h, 00h
		db	 44h,0C0h,0ECh, 12h, 02h, 08h
		db	0B0h, 00h, 10h, 00h, 10h, 22h
		db	0B0h, 17h, 02h, 38h,0B0h, 12h
		db	 02h, 02h, 00h, 04h, 40h, 04h
		db	 40h, 0Ch,0C0h, 01h, 40h, 01h
		db	 40h, 03h,0C0h, 12h, 08h,0AFh
		db	0C2h, 12h, 02h,0BBh, 0Ah, 01h
		db	 00h, 01h, 00h,0AFh, 22h, 01h
		db	 00h, 01h, 00h,0BFh, 0Ah, 04h
		db	 00h, 04h, 00h,0BCh, 2Ah, 50h
		db	 00h, 50h, 00h,0F8h, 8Bh, 12h
		db	 02h, 02h, 2Eh, 12h, 02h, 2Ch
		db	0ABh, 12h, 02h,0BCh,0BBh, 00h
		db	 01h, 00h, 01h,0F3h,0AFh, 00h
		db	 04h, 00h, 04h,0CAh,0BCh, 12h
		db	 02h, 0Eh,0B0h, 00h, 10h, 00h
		db	 10h,0AAh,0F2h, 00h, 10h, 00h
		db	 10h, 2Eh,0F0h, 12h, 02h, 8Ah
		db	0B2h, 12h, 02h, 2Eh,0F0h, 12h
		db	 02h, 8Ah,0C2h, 10h, 00h, 10h
		db	 00h,0BAh,0CAh, 10h, 00h, 10h
		db	 00h, 3Bh, 83h, 12h, 02h,0AAh
		db	0E3h, 44h, 01h, 44h, 01h,0FFh
		db	0B3h, 12h, 02h, 3Ah,0B0h, 01h
		db	 00h, 01h, 00h, 3Bh,0C0h, 01h
		db	 00h, 01h, 00h, 0Fh,0C0h, 00h
		db	 40h, 00h, 40h, 0Eh,0C0h, 04h
		db	 40h, 04h, 40h, 0Eh,0C0h, 01h
		db	 00h, 01h, 00h, 03h, 12h, 1Dh
		db	 01h, 00h, 01h, 00h, 2Fh, 02h
		db	 12h, 02h,0AFh, 00h, 01h, 00h
		db	 01h, 00h,0BBh, 22h, 04h, 00h
		db	 04h, 00h,0ACh, 88h, 12h, 02h
		db	0F8h, 2Ah, 04h, 00h, 04h, 00h
		db	0ECh, 8Bh, 00h, 01h, 00h, 01h
		db	0B2h, 2Fh, 00h, 10h, 00h, 10h
		db	0C8h,0B0h, 40h, 10h, 40h, 10h
		db	0C2h,0B0h, 40h, 00h, 40h, 00h
		db	0CAh,0C0h, 12h, 02h, 22h,0C0h
		db	 00h, 40h, 00h, 40h, 8Ah,0C0h
		db	 00h, 40h, 00h, 40h, 2Ah,0C0h
		db	 00h, 40h, 00h, 40h,0AFh,0C0h
		db	 05h, 00h, 05h, 00h,0BFh, 12h
		db	 03h,0F0h, 00h, 10h, 00h, 10h
		db	 00h,0F0h, 00h, 10h, 00h, 10h
		db	 00h,0F0h, 00h, 40h, 00h, 40h
		db	 00h,0C0h, 00h, 40h, 00h, 40h
		db	 00h,0C0h, 12h, 18h, 04h, 00h
		db	 04h,0EFh, 2Eh, 04h, 10h, 04h
		db	 10h,0BCh, 38h, 10h, 40h, 10h
		db	 40h,0F0h,0E2h, 40h, 00h, 40h
		db	 00h,0C0h, 8Ah, 12h, 02h, 82h
		db	 23h, 12h, 02h, 80h, 8Bh, 01h
		db	 00h, 01h, 00h,0A3h,0ABh, 12h
		db	 02h, 82h, 8Bh, 10h, 00h, 10h
		db	 00h,0B2h, 2Bh, 10h, 01h, 10h
		db	 01h,0B2h,0AFh, 00h, 04h, 00h
		db	 04h, 82h, 3Ch, 00h, 04h, 00h
		db	 04h, 8Ah,0BCh, 00h, 04h, 00h
		db	 04h, 28h,0BCh, 12h, 02h, 22h
		db	0FCh, 12h, 02h, 88h,0F0h, 12h
		db	 02h, 20h,0E0h, 12h, 02h, 22h
		db	 82h, 12h, 02h,0B2h, 20h, 00h
		db	 01h, 00h, 01h,0B0h, 83h, 12h
		db	 02h,0B2h, 20h, 10h

locloop_9:
		add	[bx+si],dl
;*		add	al,dh
		db	 00h,0F0h		;  Fixup - byte match
		mov	dl,40h			; '@'
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		;  Fixup - byte match
		db	0C2h, 30h, 12h, 02h, 02h,0C2h
		db	 12h, 03h,0C0h, 12h, 03h,0C3h
		db	 12h, 03h, 0Ch, 12h, 03h, 20h
		db	 12h, 03h, 3Ch, 12h, 03h, 0Ch
		db	 12h, 14h, 08h,0B3h, 00h, 10h
		db	 00h, 10h, 22h,0F3h, 00h, 40h
		db	 00h, 40h,0ABh,0CBh, 01h, 00h
		db	 01h, 00h, 2Fh, 0Ch, 01h, 00h
		db	 01h, 00h,0AFh, 2Ch, 12h, 02h
		db	0BBh, 30h, 01h, 00h, 01h, 00h
		db	0BBh, 30h, 12h, 02h,0CFh,0B3h
		db	 00h, 40h, 00h, 40h,0BBh,0E3h
		db	 01h, 40h, 01h, 40h,0BFh,0C2h
		db	 04h, 00h, 04h, 00h,0BCh, 2Ch
		db	 10h, 00h, 10h, 00h,0F2h,0ACh
		db	 40h, 10h, 40h, 10h,0C2h,0FCh
		db	 40h, 00h, 40h, 00h,0CAh,0C3h
		db	 18h, 02h,0C3h,0CCh, 12h, 02h
		db	 2Bh, 0Ch, 01h, 00h, 01h, 00h
		db	 23h, 2Ch, 12h, 02h, 0Ch, 30h
		db	 12h, 02h, 2Ch, 80h, 04h, 00h
		db	 04h, 00h, 8Ch, 30h, 12h, 02h
		db	 32h,0B0h, 12h, 02h,0B0h,0C0h
		db	 10h, 00h, 10h, 00h, 32h,0C0h
		db	 10h, 00h, 10h, 00h,0B0h,0C0h
		db	 10h, 00h, 10h, 00h,0F2h,0C0h
		db	 40h, 00h, 40h, 00h,0C3h,0C0h
		db	 12h, 02h, 0Fh,0C0h, 00h, 40h
		db	 00h, 40h, 2Bh,0C0h, 00h, 40h
		db	 00h, 40h, 2Fh,0C0h, 12h, 02h
		db	0AFh, 12h, 03h, 3Bh, 00h, 01h
		db	 00h, 01h, 00h,0BBh, 00h, 01h
		db	 00h, 01h, 00h, 2Fh, 12h, 03h
		db	0BBh, 00h, 04h, 00h, 04h, 00h
		db	0BCh, 12h, 03h,0ACh, 12h, 03h
		db	 2Ch, 00h, 04h, 00h, 04h, 00h
		db	 0Ch, 12h, 03h, 20h, 12h, 06h
		db	 01h, 00h, 01h,0AEh, 23h, 12h
		db	 02h,0BBh, 02h, 12h, 02h,0AFh
		db	 0Ah, 12h, 02h,0ABh, 08h, 00h
		db	 04h, 00h, 04h,0BFh, 2Ch, 12h
		db	 02h,0AFh, 0Ah, 00h, 01h, 00h
		db	 01h,0BBh, 2Bh, 00h, 01h, 00h
		db	 01h,0AFh, 0Bh, 00h, 10h, 00h
		db	 10h,0EBh, 38h, 00h, 01h, 00h
		db	 01h,0BCh,0CBh, 00h, 10h, 00h
		db	 10h,0FCh,0F2h, 12h, 02h,0BCh
		db	0C2h, 00h, 01h, 00h, 01h,0FCh
		db	 33h, 04h, 01h, 04h, 01h,0BCh
		db	 33h, 04h, 01h, 04h, 01h,0FCh
		db	 33h, 12h, 02h,0FCh, 33h, 10h
		db	 04h, 10h, 04h, 3Ch, 0Fh, 00h
		db	 04h, 00h, 04h, 30h, 0Ch, 00h
		db	 01h, 00h, 01h, 00h, 83h, 12h
		db	 02h, 02h, 80h, 00h, 01h, 00h
		db	 01h, 00h, 83h, 00h, 01h, 00h
		db	 01h, 00h,0A3h, 00h, 01h, 00h
		db	 01h, 00h, 23h, 12h, 03h, 03h
		db	 12h, 02h,0BCh, 08h, 00h, 04h
		db	 00h, 04h,0BCh, 8Eh, 00h, 01h
		db	 00h, 01h,0B0h, 23h, 12h, 02h
		db	0C0h, 8Ah, 00h, 10h, 00h, 10h
		db	 0Ah,0B0h, 40h, 00h, 40h, 00h
		db	0E0h, 0Ah, 12h, 02h, 88h,0BAh
		db	 12h, 02h, 82h, 80h, 12h, 02h
		db	 28h, 3Ah, 12h, 02h, 20h, 2Eh
		db	 40h, 00h, 40h, 00h,0CCh,0BBh
		db	 40h, 11h, 40h, 11h,0E0h, 3Bh
		db	 14h, 44h, 14h, 44h, 3Ch,0CEh
		db	 01h, 00h, 01h, 00h, 23h,0BAh
		db	 00h, 01h, 00h, 01h, 22h,0FBh
		db	 00h, 40h, 00h, 40h, 08h,0FFh
		db	 00h, 50h, 00h, 50h, 8Ah,0F3h
		db	 00h, 04h, 00h, 04h, 0Eh, 0Ch
		db	 01h, 10h, 01h, 10h, 83h,0F0h
		db	 00h, 40h, 00h, 40h, 23h,0C2h
		db	 12h, 02h, 88h, 08h, 12h, 02h
		db	 2Ah, 82h, 12h, 02h,0EEh,0C2h
		db	 00h, 40h, 00h, 40h,0CBh,0C8h
		db	 12h, 02h, 8Eh,0C3h, 12h, 02h
		db	0CEh,0C8h, 00h, 40h, 00h, 40h
		db	0F3h,0C2h, 11h, 00h, 11h, 00h
		db	0F3h, 0Bh, 12h, 02h,0F3h, 2Dh
		db	 12h, 02h,0EBh, 20h, 12h, 02h
		db	0EFh, 30h, 04h, 00h, 04h, 00h
		db	0ACh,0A0h, 12h, 02h,0ECh, 80h
		db	 44h, 00h, 44h, 00h,0ECh,0C0h
		db	 12h, 02h,0B3h, 12h, 03h,0F2h
		db	 00h, 50h, 00h, 50h, 00h,0F3h
		db	 00h, 10h, 00h, 10h, 00h,0B0h
		db	 00h, 10h, 00h, 10h, 00h,0F0h
		db	 12h, 03h, 30h, 12h, 00h, 01h
		db	 00h, 01h,0C2h, 03h, 12h, 02h
		db	 33h, 80h, 12h, 02h, 22h, 20h
		db	 12h, 02h, 88h, 38h, 12h, 02h
		db	0B8h,0CAh, 12h, 02h, 3Ch,0EEh
		db	 12h, 02h, 8Ch,0CEh, 12h, 02h
		db	 8Eh, 3Fh, 12h, 02h, 0Eh, 83h
		db	 12h, 02h, 07h,0A0h, 12h, 02h
		db	 87h,0A2h, 01h, 00h, 01h, 00h
		db	 03h,0EAh, 00h, 40h, 00h, 40h
		db	 21h,0FAh, 00h, 10h, 00h, 10h
		db	0E0h, 7Fh, 00h, 04h, 00h, 04h
		db	 3Ch, 4Fh, 12h, 02h,0CEh, 44h
		db	 12h, 02h, 0Eh, 20h, 12h, 02h
		db	 0Fh, 88h, 12h, 02h,0AEh,0EAh
		db	 12h, 02h, 2Ch,0B8h, 12h, 02h
		db	 38h,0BAh, 12h, 02h, 2Ch,0AEh
		db	 12h, 02h, 2Ch,0AEh, 12h, 02h
		db	 0Ch, 3Fh, 12h, 02h, 0Bh, 38h
		db	 12h, 02h, 0Fh, 32h, 12h, 02h
		db	 8Fh, 38h, 04h, 00h, 04h, 00h
		db	 0Ch,0EAh, 00h, 40h, 00h, 40h
		db	 82h,0EAh, 00h, 40h, 00h, 40h
		db	0A2h,0FAh, 12h, 02h, 20h, 3Eh
		db	 00h, 10h, 00h, 10h,0E0h, 3Eh
		db	 00h, 10h, 00h, 10h,0BCh, 3Bh
		db	 12h, 02h,0F0h, 3Ah, 00h, 04h
		db	 00h, 04h,0BCh, 0Eh, 00h, 04h
		db	 00h, 04h,0ACh, 0Eh, 00h, 04h
		db	 00h, 04h,0FCh, 0Eh, 00h, 04h
		db	 00h, 04h,0ECh, 0Eh, 12h, 02h
		db	0F0h, 03h, 12h, 02h, 30h, 03h
		db	 12h, 02h, 82h, 0Eh, 12h, 02h
		db	 23h,0A2h, 12h, 02h, 83h, 88h
		db	 12h, 02h, 20h,0E8h, 12h, 02h
		db	 88h,0E8h, 12h, 02h,0A0h,0EAh
		db	 12h, 02h, 88h,0AAh, 12h, 02h
		db	0A3h,0AAh, 12h, 02h, 83h,0A8h
		db	 12h, 02h,0A3h,0AAh, 11h, 00h
		db	 11h, 00h,0B3h,0EAh, 12h, 02h
		db	0A0h,0F8h, 40h, 00h, 40h, 00h
		db	0C8h,0FAh, 12h, 02h,0E0h,0E8h
		db	 10h
data_15		db	40h			; Data table (indexed access)
		db	 10h, 40h,0B8h,0FAh, 10h, 00h
		db	 10h
data_16		db	0			; Data table (indexed access)
		db	0B2h, 3Eh, 00h, 10h, 00h, 10h
		db	0A8h, 3Bh, 04h, 10h, 04h, 10h
		db	0ACh, 3Eh, 00h, 10h, 00h, 10h
		db	0ACh, 3Fh, 10h, 00h, 10h, 00h
		db	0FCh, 0Eh, 12h, 02h,0F0h, 0Fh
		db	 50h, 00h, 50h, 00h,0F0h, 0Fh
		db	 40h, 04h, 40h, 04h,0F0h, 0Fh
		db	 40h, 01h, 40h, 01h,0C0h, 03h
		db	 00h, 01h, 00h, 01h, 00h, 03h
		db	 00h, 01h, 00h, 01h, 00h, 03h
		db	 00h, 01h, 00h, 01h, 00h, 03h
		db	 12h, 20h, 8Ah, 0Ch, 19h, 02h
		db	 2Eh, 8Eh, 00h, 44h, 00h, 44h
		db	 82h,0CEh, 12h, 02h,0A0h, 8Fh
		db	 00h, 01h, 00h, 01h, 8Eh, 33h
		db	 00h, 01h, 00h, 01h,0A8h,0C3h
		db	 12h, 02h,0EEh, 03h, 41h, 00h
		db	 41h, 00h,0FBh, 03h, 12h, 02h
		db	0E0h,0EEh, 12h, 02h,0E8h,0FAh
		db	 12h, 02h, 38h,0FEh, 12h, 02h
		db	 3Ah, 3Eh, 12h, 02h, 8Eh, 3Eh
		db	 00h, 01h, 00h, 01h,0EEh, 83h
		db	 12h, 02h,0AEh,0A0h, 04h, 00h
		db	 04h, 00h,0EEh,0A8h, 04h, 00h
		db	 04h, 00h,0FEh,0AAh, 12h, 02h
		db	0B3h,0A8h, 01h, 00h, 01h, 00h
		db	0F3h,0E8h, 00h, 40h, 00h, 40h
		db	0C0h,0EAh, 40h, 00h, 40h, 00h
		db	0C0h,0EAh, 40h, 00h, 40h, 00h
		db	0C0h,0EAh, 12h, 02h,0C0h,0EAh
		db	 00h, 04h, 00h, 04h, 00h, 3Eh
		db	 00h, 04h, 00h, 04h, 00h, 3Dh
		db	 12h, 03h, 35h, 00h, 14h, 00h
		db	 14h, 00h, 3Dh, 12h, 03h, 03h
		db	 00h, 01h, 00h, 01h, 00h, 03h
		db	 12h, 11h, 04h, 00h, 04h,0AEh
		db	 8Eh, 12h, 02h,0AEh, 83h, 10h
		db	 00h, 10h, 00h,0B2h,0A0h, 12h
		db	 02h,0B3h,0A0h, 12h, 02h,0B0h
		db	0E8h, 40h, 00h, 40h, 00h,0C0h
		db	0E8h, 12h, 03h, 38h, 12h, 08h
		db	0E8h, 2Ah, 12h, 02h,0EAh, 0Ah
		db	 12h, 02h,0CEh, 8Ah, 12h, 02h
		db	 0Fh, 02h, 12h, 02h, 20h,0E2h
		db	 12h, 02h, 88h,0E2h, 12h, 02h
		db	 20h,0E2h, 12h, 02h,0C8h,0E2h
		db	 12h, 02h, 20h,0EEh, 00h
		db	50h
data_17		dw	5000h			; Data table (indexed access)
		db	 8Ch,0FAh, 12h, 02h, 2Ch, 3Ah
		db	 00h, 10h, 00h, 10h, 80h, 3Ah
		db	 00h, 10h, 00h, 10h, 30h, 3Ah
		db	 12h, 02h,0C0h, 3Bh, 00h, 04h
		db	 00h, 04h,0C0h, 0Ch, 12h, 08h
		db	0C8h,0EAh, 12h, 02h,0A3h, 3Ah
		db	 12h, 02h, 8Ch, 3Ah, 18h, 02h
		db	0E8h,0EEh, 10h, 00h, 10h, 00h
		db	 30h, 3Ah, 17h, 02h, 30h, 3Ah
		db	 00h, 10h, 00h, 10h, 00h, 3Ah
		db	 12h, 03h, 0Eh, 12h, 02h, 0Eh
		db	 0Bh, 00h, 04h, 00h, 04h, 7Bh
		db	 00h, 00h, 04h, 00h, 04h, 0Eh
		db	0CFh, 12h, 02h, 83h, 0Fh, 00h
		db	 04h, 00h, 04h, 20h, 0Eh, 40h
		db	 04h, 40h, 04h,0CCh, 0Fh, 50h
		db	 04h, 50h, 04h,0F0h, 0Eh, 40h
		db	 00h, 40h, 00h,0C0h, 03h, 00h
		db	 01h, 00h, 01h,0CEh, 23h, 12h
		db	 02h,0CFh, 88h, 12h, 02h,0E3h
		db	0E2h, 12h, 02h, 30h,0C8h, 12h
		db	 02h, 38h,0F2h, 12h, 02h, 0Ch
		db	0ECh
data_18		db	12h			; Data table (indexed access)
		db	 02h, 0Ch,0EEh, 12h, 02h, 8Eh
		db	 3Ch, 12h, 03h,0E0h, 40h, 00h
		db	 40h, 00h, 1Ah, 00h, 40h, 00h
		db	 40h, 00h,0E0h,0C8h, 12h, 02h
		db	 80h,0ECh, 01h, 00h, 01h, 00h
		db	 03h,0BBh, 11h, 00h, 11h, 00h
		db	0B3h,0B2h, 00h, 40h, 00h, 40h
		db	 03h,0E2h, 12h, 02h,0A0h,0E2h
		db	 12h, 02h, 83h,0EAh, 12h, 02h
		db	0A0h,0FAh, 12h, 02h,0AAh
		db	3Eh

_352TILPL	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		add	[bx+si],ax
		add	[bx+si],ax
		stosw				; Store ax to es:[di]
		aas				; Ascii adjust
		add	[si],al
		add	[si],al
		lodsb				; String [si] to al
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		adc	[si],al
		adc	[si],al
		mov	al,0Eh
		inc	ax
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		;  Fixup - byte match
		db	0F0h, 3Eh, 40h, 00h, 40h, 00h
data_19		dw	3AC0h			; Data table (indexed access)
		db	 00h, 10h, 00h, 10h,0C0h
data_20		db	3Bh			; Data table (indexed access)
		db	 00h, 10h, 00h, 10h, 00h, 38h
		db	 00h, 10h, 00h, 10h, 00h, 3Ch
		db	 12h, 03h, 0Ch, 00h, 04h, 00h
		db	 04h, 00h, 0Ch, 12h, 03h
data_21		db	0Ch			; Data table (indexed access)
		db	 12h, 0Eh, 20h,0ACh, 12h, 02h
		db	 83h
		db	38h
data_22		db	0			; Data table (indexed access)
		db	 40h, 00h, 40h, 20h
data_23		db	0EFh			; Data table (indexed access)
		db	 00h, 10h, 00h, 10h, 88h, 3Bh
		db	 01h, 10h, 01h, 10h,0ABh, 3Ah
		db	 00h, 04h, 00h, 04h,0CAh, 3Fh
		db	 00h, 04h, 00h, 04h,0BAh, 0Eh
		db	 00h, 01h, 00h, 01h,0EEh, 83h
		db	 10h, 00h, 10h, 00h, 3Ah,0A8h
		db	 00h, 10h, 00h, 10h, 0Eh,0B8h
		db	 01h, 00h, 01h, 00h, 03h,0AAh
		db	 12h, 02h, 03h,0AAh, 00h, 50h
		db	 00h, 50h, 00h,0FEh, 12h, 03h
		db	 03h, 12h, 0Eh,0C0h,0FAh, 00h
		db	 10h, 00h, 10h, 8Ch, 3Eh, 00h
		db	 04h, 00h, 04h, 30h, 0Fh, 12h
		db	 02h,0C8h, 80h, 12h, 02h,0C2h
		db	 22h, 12h, 02h,0B3h,0A8h, 12h
		db	 02h,0ECh,0FEh, 12h, 02h,0BBh
		db	 0Bh, 12h, 02h,0EEh,0FAh, 41h
		db	 00h, 41h, 00h,0F3h,0FFh, 00h
		db	 40h, 00h, 40h, 00h,0FCh, 00h
		db	 40h, 00h, 40h, 1Ah, 00h
data_24		db	12h			; Data table (indexed access)
		db	1Ah
data_25		db	0B2h			; Data table (indexed access)
		db	 38h, 12h, 02h
data_26		db	0B8h			; Data table (indexed access)
		db	 38h, 12h, 02h,0EEh, 3Eh, 10h
		db	 00h, 10h, 00h, 3Ch, 83h, 04h
		db	 00h, 04h, 00h, 0Eh, 20h, 12h
		db	 02h, 03h, 8Eh, 01h, 00h, 01h
		db	 00h, 03h,0AAh, 01h, 00h, 01h
		db	 00h, 03h,0F8h
sub_1		endp


seg_a		ends



		end	start
