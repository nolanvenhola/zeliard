
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR3_32	                                 лл
;лл					                                 лл
;лл      Created:   16-Feb-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_32		proc	far

start:
		jno	loc_2			; Jump if not overflw
		add	[bx+si],al
		or	bl,bl			; Zero ?
;*                         lock	add	cl,al
		db	0F0h, 00h,0C1h		;  Fixup - byte match
;*		fld	st(6)			; Push onto stack
		db	0D9h,0C6h		;  Fixup - byte match
;*		fxch	st			; Exchange st & st(#)
		db	0D9h,0C8h		;  Fixup - byte match
;*		fst	dword ptr [bx+si]	; Store st to memory
		db	0D9h, 10h		;  Fixup - byte match
;*		fisub	dword ptr [bp-26h]	; st = st - memory
		db	0DAh, 66h,0DAh		;  Fixup - byte match
		hlt				; Halt processor
;*		fimul	dword ptr [bx]		; st = st * memory
		db	0DAh, 0Fh		;  Fixup - byte match
;*		fild	dword ptr [di]		; Push integer to stk
		db	0DBh, 05h		;  Fixup - byte match
		popf				; Pop flags
		add	[bx+di],dl
		or	al,[bx+si]
;*		add	cl,al
		db	 00h,0C1h		;  Fixup - byte match
;*		fldenv	byte ptr [bp-34h]	; Load Envirnmt state
		db	0D9h, 66h,0CCh		;  Fixup - byte match
loc_2:
		xchg	al,ah
		lds	cx,dword ptr [bx+di]	; Load seg:offset ptr
		pop	es
		retf
			                        ;* No entry point to code
		push	ax
		retn	0C2C1h
			                        ;* No entry point to code
		inc	ax
		retn	8150h
			                        ;* No entry point to code
		les	ax,dword ptr [bp-7Bh]	; Load seg:offset ptr
		les	dx,dword ptr [bp-34h]	; Load seg:offset ptr
		mov	bl,dl
;*		fiadd	word ptr [bp+66h]
		db	0DEh, 46h, 66h		;  Fixup - byte match
		add	[bx+si],bx
		test	ax,sp
;*		jbe	loc_1			;*Jump if below or =
		db	 76h,0C8h		;  Fixup - byte match
		jbe	$-70h			; Jump if below or =
		retn
			                        ;* No entry point to code
		inc	si
		test	ax,bx
		db	0C7h,0C9h,0C7h, 8Bh,0DBh,0DFh
		db	0C9h,0C7h, 56h,0CCh, 87h,0C3h
		db	 46h,0CAh,0C7h,0D8h, 82h,0C4h
		db	 56h, 01h, 18h, 84h,0C4h,0C7h
		db	0D8h, 85h,0C3h,0C8h, 01h, 18h
		db	 84h,0C4h, 56h,0C6h, 8Ah,0DBh
		db	0DFh, 46h, 56h,0C8h, 02h, 18h
		db	 84h,0C3h, 56h, 01h, 18h, 82h
		db	0C3h, 46h,0C8h, 02h, 18h, 83h
		db	0C4h,0C7h, 86h,0C3h,0C7h,0D8h
		db	 85h,0C3h, 66h,0D8h, 89h,0DBh
		db	0DFh, 46h, 66h,0D8h, 86h,0C3h
		db	0C7h,0C8h, 01h, 18h, 83h,0C3h
		db	 01h, 2Ch,0C7h,0D8h, 85h,0C3h
		db	0C7h, 01h, 18h, 84h,0C4h, 87h
		db	0C3h, 56h,0C8h, 02h, 18h, 87h
		db	0DBh,0DFh, 46h, 56h,0CCh, 87h
		db	0C4h,0C7h,0CCh, 85h,0C3h,0ECh
		db	0C7h,0CCh, 86h,0C3h,0C5h,0C7h
		db	0C6h, 8Ch,0C3h, 66h,0D8h, 89h
		db	0DBh,0DFh, 46h, 56h,0CCh, 8Fh
		db	0C3h, 56h,0D8h, 85h,0C3h, 46h
		db	0C8h, 01h, 18h, 8Ah,0C3h, 66h
		db	 8Ah,0DBh,0DFh, 46h, 46h,0C8h
		db	 01h, 18h, 8Eh,0C3h, 46h,0C8h
		db	 01h, 18h, 84h,0C4h, 46h, 01h
		db	 18h, 8Bh,0C3h, 56h,0CBh, 8Ah
		db	0DBh,0DFh,0C7h,0C9h, 56h,0D9h
		db	 01h, 18h, 8Dh,0C3h,0C5h,0C7h
		db	0CCh, 86h,0C3h,0C7h,0CAh, 01h
		db	 18h, 8Bh,0C3h,0C5h, 46h,0C9h
		db	 01h, 18h, 88h,0DBh,0DFh, 46h
		db	 46h,0CCh, 90h,0C4h,0C7h,0CBh
		db	 87h,0C4h, 46h,0CCh, 8Ch,0C3h
		db	 66h,0D8h, 89h,0DBh,0DFh, 46h
		db	0C7h,0C9h, 03h, 18h, 8Dh,0C4h
		db	 46h, 87h,0C4h,0ECh,0C6h, 8Dh
		db	0C3h, 56h,0CCh, 8Ah,0DDh,0E0h
		db	 46h, 46h,0CCh, 90h,0C3h, 46h
		db	0C6h, 86h,0C3h, 46h, 01h, 18h
		db	 8Bh,0C3h, 56h, 8Ch,0DBh,0DFh
		db	0C7h, 46h,0CCh, 90h,0C3h, 46h
		db	0CAh, 01h, 18h, 84h,0C3h,0C7h
		db	0C8h, 02h, 18h, 8Ah,0C3h,0C5h
		db	0C7h,0C9h, 86h,0C3h, 85h,0DDh
		db	0DFh,0C7h, 46h,0C8h, 01h, 18h
		db	 8Eh,0C3h, 56h,0D8h, 85h,0C3h
		db	0ECh,0CCh, 8Dh,0C3h, 56h,0C6h
		db	 85h,0C4h,0C7h, 85h,0C4h,0C9h
		db	 46h, 01h, 18h, 85h,0C4h,0C7h
		db	0C6h, 87h,0C3h,0C5h,0C7h,0CCh
		db	 86h,0C3h,0C7h,0CCh, 8Dh,0C4h
		db	 56h,0C6h, 85h,0C3h, 46h, 84h
		db	0C3h,0C7h, 46h,0CCh, 86h,0C4h
		db	0C5h, 46h,0D8h, 85h,0C3h, 56h
		db	 86h,0C4h,0C7h,0CCh, 8Dh,0C4h
		db	 56h,0C8h, 01h, 18h, 83h,0C4h
		db	0C7h,0C8h,0D8h, 83h,0C4h,0C7h
		db	 46h,0CCh, 86h,0C4h, 46h,0C8h
		db	 01h, 18h, 84h,0C4h, 46h,0CCh
		db	 86h,0C3h,0CAh,0C7h, 01h, 18h
		db	 83h,0C4h, 87h,0C3h, 66h,0D8h
		db	 85h,0C3h,0CCh, 84h,0C3h,0C7h
		db	 56h, 02h, 18h, 83h,0C3h, 46h
		db	0CCh, 86h,0C3h,0ECh,0C7h,0C6h
		db	 86h,0C3h,0C7h, 01h, 18h, 84h
		db	0C4h,0C7h, 86h,0C3h, 56h,0CCh
		db	 86h,0C4h, 85h,0C3h,0C7h,0C7h
		db	0C8h,0D8h,0D9h,0D8h, 84h,0C3h
		db	0C9h, 46h, 02h, 18h, 83h,0C3h
		db	 46h,0C8h,0D8h, 85h,0C4h, 01h
		db	 18h, 85h,0C3h,0C8h, 01h, 18h
		db	 84h,0C3h, 56h, 8Dh,0C3h,0C7h
		db	 46h,0CCh, 86h,0C4h,0C7h, 01h
		db	 18h, 86h,0C3h, 01h, 2Ch,0CCh
		db	 8Eh,0C3h,0C7h,0CCh, 85h,0C3h
		db	 56h, 8Dh,0C3h,0C7h,0C7h,0CCh
		db	 91h,0C3h, 01h, 2Ch,0C7h, 02h
		db	 18h, 8Bh,0C3h,0C9h, 86h,0C3h
		db	 66h, 01h, 18h, 8Ah,0C3h,0C7h
		db	 56h, 50h,0C2h,0C1h,0C2h, 50h
		db	0C2h,0C1h,0C2h, 50h, 81h,0C3h
		db	 46h,0CAh,0D8h, 8Dh,0C4h,0C7h
		db	0C6h, 85h,0C3h, 46h,0CAh, 01h
		db	 18h, 8Bh,0C4h,0C7h, 46h,0CCh
		db	 90h,0C4h, 56h,0D8h, 8Dh,0C3h
		db	0C7h,0C8h, 01h, 18h, 83h,0C3h
		db	 46h,0CCh, 8Dh,0C3h,0C7h,0C7h
		db	0C8h, 01h, 18h, 85h,0C4h,0C7h
		db	 01h, 18h, 86h,0C3h, 46h,0CCh
		db	 8Eh,0C3h,0C7h, 01h, 18h, 84h
		db	0C3h, 56h, 02h, 18h, 8Ah,0C4h
		db	0C7h, 46h,0D8h, 86h,0C3h,0C7h
		db	0C8h, 01h, 18h, 85h,0EBh,0C7h
		db	0C9h, 8Fh,0C3h, 46h, 85h,0C3h
		db	 56h,0C8h,0D8h, 8Bh,0C3h,0C7h
		db	 56h, 86h,0C3h, 56h, 01h, 18h
		db	 84h,0C4h,0ECh,0C7h,0C6h, 8Eh
		db	0C3h, 46h, 85h,0C4h, 66h, 01h
		db	 18h, 8Ah,0C3h,0C7h, 46h,0C9h
		db	0D8h, 85h,0C4h, 56h,0C8h,0D8h
		db	 84h,0EBh, 01h, 2Ch,0C7h, 01h
		db	 18h, 84h,0C4h,0C7h,0C8h, 46h
		db	0CAh, 82h,0ECh,0C7h, 01h, 18h
		db	 84h,0C3h,0C7h,0CAh,0C7h, 8Dh
		db	0C3h,0C7h, 46h, 02h, 18h, 84h
		db	0C4h, 46h, 02h, 18h, 84h,0EBh
		db	0ECh, 01h, 18h, 86h,0C3h, 66h
		db	0ECh, 82h,0ECh, 46h, 01h, 18h
		db	 83h,0C4h,0C7h,0CCh, 8Eh,0C3h
		db	0C5h, 46h,0CCh, 86h,0C3h, 46h
		db	0CCh, 88h, 01h, 18h, 86h,0C3h
		db	 56h, 01h, 2Ch,0C7h,0C5h,0C7h
		db	0ECh,0C9h, 96h,0C3h,0C7h, 46h
		db	0CCh, 86h,0C4h,0C7h,0CAh,0C7h
		db	 01h, 18h, 86h,0D9h, 02h, 18h
		db	 84h,0C4h,0C5h, 46h,0ECh,0CAh
		db	0D8h, 76h, 95h,0C3h,0C7h,0C7h
		db	0C6h,0C7h, 01h, 18h, 90h,0D9h
		db	 87h,0C4h, 66h, 01h, 18h, 81h
		db	0C3h, 56h, 02h, 18h, 92h,0C3h
		db	0C7h, 46h,0C8h, 02h, 18h, 97h
		db	0C3h, 46h,0C8h, 01h, 18h, 83h
		db	0C3h, 46h, 01h, 18h, 93h,0C4h
		db	0C7h, 46h, 01h, 18h, 85h,0C4h
		db	0C7h,0C6h, 89h, 01h, 18h, 86h
		db	0C3h, 56h, 85h,0C3h, 56h, 94h
		db	0C4h,0C7h,0C7h,0C9h,0CCh, 86h
		db	0C3h,0C7h,0CAh, 01h, 18h, 87h
		db	0D9h, 87h,0C3h,0C7h,0C9h, 86h
		db	0C4h,0C5h,0C7h,0C9h, 94h,0C3h
		db	0C7h, 46h,0CCh, 86h,0C3h, 56h
		db	0C6h,0D8h, 84h,0EBh, 01h, 2Ch
		db	 87h,0C3h,0C7h,0D8h, 86h,0C4h
		db	 56h,0D8h, 93h,0C3h,0C7h,0C7h
		db	0CCh,0C8h,0D8h, 85h,0C4h, 46h
		db	0C8h,0D8h, 85h,0EBh, 01h, 2Ch
		db	0C7h, 02h, 18h, 83h,0C3h,0C7h
		db	 87h,0C3h, 46h,0C8h, 01h, 18h
		db	 92h,0C3h,0C7h, 46h,0D9h, 01h
		db	 18h, 84h,0C4h,0C7h,0C8h, 01h
		db	 18h, 85h,0EBh, 01h, 2Ch,0C8h
		db	0C7h,0D8h
		db	 84h,0C4h,0D8h, 87h,0C3h, 56h
		db	0D8h, 93h,0C3h,0C7h, 46h,0CCh
		db	 86h,0C4h,0C7h, 01h, 18h, 86h
		db	0EBh,0ECh, 46h,0CCh, 8Eh,0C3h
		db	 56h, 01h, 18h, 92h,0C4h,0C7h
		db	 46h,0C6h, 90h,0C3h,0C5h, 56h
		db	 40h,0C2h,0C1h,0C2h, 40h, 87h
		db	0C3h,0ECh,0C7h,0CAh,0D8h, 93h
		db	0C3h,0C7h, 56h, 70h,0C2h,0C1h
		db	0C2h,0C1h,0C2h, 40h,0C2h, 40h
		db	 81h,0C3h, 66h, 8Eh,0C3h, 46h
		db	0CCh, 94h,0C3h,0C5h, 46h,0C8h
		db	 02h, 18h, 8Dh,0C4h, 66h, 01h
		db	 18h, 8Ch,0C3h,0C7h,0C9h, 95h
		db	0C3h,0C7h, 56h,0C9h,0C7h, 55h
		db	 02h, 18h, 88h,0C4h,0C7h, 01h
		db	 2Ch,0C8h,0D8h, 8Dh,0C3h, 46h
		db	0C6h, 94h,0C3h,0C7h, 05h, 07h
		db	0C6h,0C8h,0C7h,0C6h,0C8h, 01h
		db	 18h, 86h,0C3h, 02h, 2Ch,0CCh
		db	 8Eh,0C3h,0C5h,0C7h,0C8h,0D8h
		db	 84h,0C4h, 8Eh,0C4h,0C7h, 66h
		db	0CCh,0CAh, 76h,0C6h, 87h,0C3h
		db	0C7h, 01h, 2Ch,0C7h, 86h,0C4h
		db	0C6h, 86h,0C3h, 46h, 02h, 18h
		db	 83h,0C3h,0C7h, 01h, 18h, 8Bh
		db	0C4h,0C7h, 66h,0C8h, 46h,0CAh
		db	 66h, 02h, 18h, 84h,0C3h, 56h
		db	0C9h, 86h,0C4h,0CCh, 86h,0C4h
		db	0C7h,0CCh, 86h,0C3h,0C6h, 8Bh
		db	0C3h,0C6h, 46h, 56h, 4Bh,0C3h
		db	 4Bh, 56h,0C8h,0C6h,0D8h, 85h
		db	0C3h,0C5h, 56h, 01h, 18h, 8Ch
		db	0C4h, 46h, 86h,0C3h,0C7h,0CAh
		db	 01h, 18h, 88h,0C4h,0C7h,0C5h
		db	0C7h,0CAh,0C7h, 01h, 18h, 84h
		db	0C4h, 56h,0C6h, 86h,0C3h, 66h
		db	0D8h, 8Dh,0C3h, 46h, 01h, 18h
		db	 84h,0C4h, 46h,0D8h, 89h,0C3h
		db	 56h,0CCh, 87h,0C3h, 66h, 02h
		db	 18h, 83h,0C3h, 56h,0C8h,0D8h
		db	 8Dh,0C3h, 46h,0CCh, 85h,0C3h
		db	0C7h,0C6h, 8Ah,0C3h, 56h, 88h
		db	0C3h, 46h,0C5h,0C7h,0C6h, 85h
		db	0C3h, 56h,0CCh, 8Eh,0C3h,0ECh
		db	0C7h,0D8h, 85h,0C3h, 56h, 01h
		db	 18h, 85h,0C4h,0C6h, 66h,0C1h
		db	0C2h, 40h, 84h,0C3h,0C5h, 66h
		db	0D8h, 84h,0C3h, 56h,0C9h, 8Eh
		db	0C3h,0ECh,0C8h, 02h, 18h, 83h
		db	0C4h, 46h,0C8h,0D8h, 86h,0C3h
		db	 56h,0CAh,0C7h,0D8h, 87h,0C4h
		db	 56h,0C8h,0C7h,0D8h, 84h,0C4h
		db	 56h, 02h, 18h, 8Ch,0C4h, 56h
		db	0D8h, 84h,0C3h, 46h, 01h, 18h
		db	 86h,0C3h, 66h,0D8h, 88h,0C3h
		db	0CCh, 56h,0CCh, 85h,0C3h, 56h
		db	0C8h, 02h, 18h, 8Bh,0C3h,0C5h
		db	0C7h,0CCh, 85h,0C3h,0CAh,0CCh
		db	 88h,0C3h, 66h, 81h,0D8h, 89h
		db	0C4h, 56h, 85h,0C4h, 56h,0CCh
		db	 8Eh,0C3h, 56h, 85h,0C3h,0C7h
		db	0C6h, 86h,0C3h,0C6h, 66h, 01h
		db	 18h, 8Ah,0C3h, 46h,0CCh, 85h
		db	0C3h, 46h,0CCh, 86h,0C3h,0C7h
		db	 87h,0C3h, 46h,0CCh, 85h,0C4h
		db	 46h,0CCh, 85h,0C4h, 56h,0C8h
		db	0C7h,0D8h, 81h, 8Ah,0C3h, 46h
		db	0C6h, 85h,0C3h,0CAh,0C7h,0C8h
		db	 86h,0C3h,0C5h,0C7h, 86h,0C3h
		db	0C7h,0C6h, 86h,0C4h,0C7h,0CCh
		db	 86h,0C4h, 56h,0CCh, 83h, 8Ah
		db	0C4h, 56h,0D8h, 84h,0C3h, 66h
		db	0D8h, 84h,0C3h, 56h, 85h,0C3h
		db	0C7h,0CAh, 02h, 18h, 83h,0C3h
		db	0C7h,0C6h, 86h,0C3h, 56h,0C6h
		db	 83h, 8Ah,0C3h, 46h,0C8h, 01h
		db	 18h, 83h,0C3h, 56h, 02h, 18h
		db	 83h,0C3h, 56h,0D8h, 84h,0C4h
		db	 46h, 01h, 18h, 84h,0C3h, 46h
		db	 02h, 18h, 83h,0C3h,0C5h, 56h
		db	0D8h, 82h, 8Ah,0C3h,0C5h, 46h
		db	0D8h, 84h,0C3h, 46h,0CCh,0C8h
		db	0D8h, 84h,0C3h,0C8h,0C7h, 01h
		db	 18h, 84h,0C3h,0C7h,0CCh, 86h
		db	0C3h, 46h,0CAh, 01h, 18h, 83h
		db	0C3h, 56h,0CAh, 02h, 18h, 8Ah
		db	0C3h, 46h, 01h, 18h, 84h,0C4h
		db	 46h,0CAh,0C7h, 85h,0C3h,0C7h
		db	0D8h, 86h,0C3h,0C7h,0D8h, 86h
		db	0C3h,0C7h,0C9h,0C7h,0D8h, 84h
		db	0C3h, 56h, 02h, 18h, 81h, 8Ah
		db	0C3h,0C7h,0CCh, 86h,0C3h, 66h
		db	 97h,0C3h, 46h,0CCh, 85h,0C3h
		db	 46h,0C8h,0D8h, 83h, 8Ah,0C3h
		db	0C7h, 87h,0C3h, 66h, 40h,0C2h
		db	0C1h,0C2h, 70h,0C2h,0C1h,0C2h
		db	 50h,0C2h,0C1h,0C2h, 40h, 82h
		db	0C4h, 46h,0C6h, 85h,0C3h, 56h
		db	0D8h, 83h, 8Ah,0C3h,0C7h,0C6h
		db	 86h,0C3h, 56h,0CAh, 01h, 18h
		db	 95h,0C3h, 56h, 01h, 18h, 83h
		db	0C3h, 46h,0CCh, 84h, 8Ah,0C3h
		db	 46h, 02h, 18h, 83h,0C3h,0C9h
		db	 66h,0C8h, 66h, 55h, 46h,0C8h
		db	 56h, 65h,0C7h,0C6h, 66h,0C8h
		db	0C7h,0D8h, 84h,0C3h, 56h, 84h
		db	0C1h, 41h,0C1h, 86h,0C3h, 46h
		db	 01h, 18h, 84h,0C3h, 0Fh, 07h
		db	0C6h,0C8h, 56h,0CAh, 07h, 07h
		db	0D8h, 85h,0C3h, 56h,0C1h,0C2h
		db	 40h, 8Ah,0C3h, 56h, 85h,0C3h
		db	 46h,0C8h, 66h,0C8h, 56h,0CAh
		db	0C8h,0CCh, 0Eh, 07h, 01h, 18h
		db	 85h,0C3h, 56h, 84h, 81h,0C4h
		db	0C7h,0C6h, 86h,0C3h, 56h, 85h
		db	0C4h, 46h, 01h, 18h, 85h,0C3h
		db	0C7h, 4Bh, 46h, 4Bh, 46h,0C5h
		db	 66h,0C8h,0C7h, 01h, 18h, 88h
		db	0C3h, 46h,0CAh, 01h, 18h, 82h
		db	 81h,0C4h,0C7h,0C8h, 46h, 84h
		db	0C4h, 56h, 98h,0C4h,0C7h,0ECh
		db	 56h, 01h, 18h, 8Ah,0C4h, 56h
		db	0D8h, 83h, 81h,0C3h, 66h,0D8h
		db	 83h,0C4h,0C7h,0C5h,0C7h, 60h
		db	0C2h, 50h,0C2h, 60h,0C2h,0C1h
		db	0C2h, 50h,0C2h, 50h, 81h,0C3h
		db	0C7h,0ECh, 56h, 8Ch,0C3h, 46h
		db	0CCh, 84h, 81h,0C3h, 46h,0CAh
		db	0D8h, 84h,0C3h, 56h, 01h, 18h
		db	 96h,0C4h, 46h,0C5h,0C8h, 01h
		db	 18h, 8Bh,0C3h, 46h,0D8h, 84h
		db	 81h,0C4h, 46h,0CCh, 85h,0C3h
		db	 08h, 07h, 04h, 18h, 8Dh,0C3h
		db	0ECh, 46h, 01h, 18h, 84h,0C4h
		db	0C7h,0C6h, 85h,0C4h, 56h,0D8h
		db	 83h, 81h,0C3h,0C7h,0CAh, 01h
		db	 18h, 84h,0C3h, 0Bh, 07h, 02h
		db	 18h, 8Ch,0C3h,0ECh,0C7h,0CCh
		db	 86h,0C3h,0C7h, 02h, 18h, 83h
		db	0C3h, 46h,0C6h, 84h, 81h,0C3h
		db	 46h, 02h, 18h, 83h,0C3h, 09h
		db	 07h,0CCh, 46h,0CAh, 03h, 18h
		db	 89h,0C4h,0ECh, 46h,0C6h, 85h
		db	0C3h,0C7h,0C8h,0D8h, 84h,0C3h
		db	 56h, 84h, 81h,0C3h, 46h,0D8h
		db	 85h,0C3h, 76h,0CCh,0C8h,0C7h
		db	 4Bh,0C8h, 06h, 07h, 01h, 18h
		db	 87h,0C3h,0C7h,0ECh,0C7h, 02h
		db	 18h, 83h,0C3h, 46h,0D8h, 84h
		db	0C3h, 46h,0C9h, 01h, 18h, 82h
		db	 81h,0C4h,0C7h,0CCh, 86h,0C4h
		db	0C7h,0C9h, 46h, 02h, 18h, 82h
		db	0C4h, 07h, 07h,0C8h, 02h, 18h
		db	 85h,0C3h,0C7h,0ECh,0C8h, 01h
		db	 18h, 84h,0C3h,0C7h,0C6h, 85h
		db	0C3h, 56h,0D8h, 83h, 81h,0C3h
		db	0C7h, 96h,0C4h, 76h,0D8h, 86h
		db	0C3h,0C7h,0ECh,0C7h,0D8h, 85h
		db	0C4h, 46h,0D8h, 84h,0C3h, 56h
		db	 84h, 81h,0C3h,0C9h,0C7h, 70h
		db	0C2h,0C1h,0C2h, 60h,0C2h, 40h
		db	0C2h, 60h, 82h,0C3h, 56h,0C8h
		db	0D8h, 86h,0C4h, 46h,0CCh, 86h
		db	0C4h,0C7h,0C8h, 01h, 18h, 83h
		db	0C3h, 46h,0D8h, 84h, 81h,0C3h
		db	 46h,0D8h, 95h,0C3h, 56h,0CCh
		db	 87h,0C4h, 46h,0C6h, 86h,0C3h
		db	 46h,0D8h, 84h,0C3h,0C7h,0C9h
		db	0D8h, 84h, 81h,0C3h, 46h, 85h
		db	0C4h,0C7h,0D8h, 8Eh,0C4h, 56h
		db	0C6h, 87h,0C3h, 46h,0C8h, 01h
		db	 18h, 84h,0C3h,0C5h,0C7h,0D8h
		db	 84h,0C3h,0C7h,0CCh, 85h, 81h
		db	0C3h,0C7h,0C8h, 01h, 18h, 83h
		db	0C4h, 46h, 01h, 18h, 8Ch,0C4h
		db	 46h,0CAh,0C7h, 01h, 18h, 85h
		db	0C3h, 56h, 02h, 18h, 83h,0C3h
		db	0C7h,0CCh, 85h,0C4h,0C7h,0CCh
		db	 85h, 81h,0C4h, 46h,0D8h, 84h
		db	0C3h, 46h, 8Eh,0C3h, 56h,0C6h
		db	0D8h, 86h,0C3h, 56h,0D8h, 85h
		db	0C3h,0C7h, 86h,0C3h,0C7h, 01h
		db	 18h, 84h, 81h,0C4h,0C7h,0CCh
		db	 85h,0C3h, 46h,0C6h, 8Dh,0C3h
		db	0C7h,0C5h, 46h,0D8h, 86h,0C3h
		db	 46h,0CCh, 86h,0C3h,0C7h,0C6h
		db	0D8h, 84h,0C3h,0C7h, 02h, 18h
		db	 83h, 81h,0C3h,0C7h, 86h,0C3h
		db	0C7h,0C5h,0C6h, 8Dh,0C3h, 56h
		db	0CCh, 87h,0C4h, 46h,0C9h, 86h
		db	0C3h, 46h, 01h, 18h, 83h,0C3h
		db	0C7h,0D8h, 85h,0C4h, 46h,0CCh
		db	 85h,0C4h, 66h,0D8h, 8Bh,0C3h
		db	 46h,0C6h, 88h,0C3h, 46h,0CCh
		db	 86h,0C3h, 46h,0C8h, 01h, 18h
		db	 82h,0C4h,0C7h, 86h, 66h,0D8h
		db	 84h,0C3h, 66h, 01h, 18h, 8Ah
		db	0C4h, 46h,0C6h, 88h,0C3h, 46h
		db	 02h, 18h, 84h,0C3h, 56h,0C6h
		db	 83h,0C3h,0CCh, 85h,0C4h,0C5h
		db	 46h,0CAh, 02h, 18h, 82h,0C4h
		db	 56h,0CCh, 8Ch,0C4h,0C5h, 46h
		db	0C6h, 87h,0C3h,0C7h,0C8h,0D8h
		db	 86h,0C4h, 76h,0C8h, 46h,0CCh
		db	 85h,0C3h, 46h,0C8h, 01h, 18h
		db	 84h,0C3h,0C9h, 56h, 01h, 18h
		db	 8Ah,0C3h, 56h,0CAh, 01h, 18h
		db	 85h,0C3h, 46h, 01h, 18h, 85h
		db	0C4h,0C5h, 07h, 07h, 85h,0C3h
		db	 56h,0CCh, 85h,0C3h,0C7h,0C9h
		db	 46h,0D8h, 8Bh,0C4h, 66h,0D8h
		db	 86h,0C3h, 56h, 86h,0C3h, 06h
		db	 07h,0C8h,0C7h, 01h, 18h, 83h
		db	0C3h, 56h,0CCh, 85h,0C3h, 56h
		db	0CCh, 8Ch,0C3h, 56h,0CCh, 87h
		db	0C4h, 46h,0C9h, 86h,0C3h, 06h
		db	 07h, 02h, 18h, 84h,0C4h, 46h
		db	0CCh, 86h,0C3h, 56h,0C8h, 01h
		db	 18h, 8Ah,0C3h, 46h,0CCh
data_1		dw	0C388h, 8656h		; Data table (indexed access)
		db	0C3h, 06h, 07h,0D8h, 86h,0C3h
		db	 46h, 87h,0C3h,0C7h,0C9h,0C7h
		db	0CCh, 8Ch,0C3h, 46h,0C9h, 88h
		db	0C3h, 56h, 01h, 18h, 84h,0C3h
		db	 05h, 07h,0CCh, 87h,0C3h, 46h
		db	0CCh, 86h,0C4h, 56h,0CCh, 8Ch
		db	0C3h,0C7h,0C6h,0C8h,0C6h, 87h
		db	0C4h, 46h,0C8h,0D8h, 85h,0C4h
		db	 05h, 07h, 01h, 18h, 86h,0C3h
		db	 46h,0CAh, 01h, 18h, 84h,0C3h
		db	0C9h, 46h, 8Dh,0C3h, 66h,0D8h
		db	 86h,0C4h, 46h,0CCh,0D8h, 85h
		db	0C3h,0C7h,0C5h, 66h,0C8h, 01h
		db	 18h, 85h,0C3h, 56h, 02h, 18h
		db	 83h,0C3h, 46h, 01h, 18h, 8Ch
		db	0C3h, 56h,0C6h, 87h,0C3h, 56h
		db	 86h,0C3h, 05h, 07h,0CCh, 87h
		db	0C4h, 46h,0CCh, 86h,0C4h, 46h
		db	0CCh, 85h,0C4h, 46h,0C6h, 84h
		db	0C4h, 56h,0CAh, 02h, 18h, 84h
		db	0C3h,0C5h, 46h, 86h,0C3h, 66h
		db	 48h, 88h,0C4h, 46h, 87h,0C4h
		db	 46h,0C8h, 01h, 18h, 83h,0C3h
		db	0C7h,0C9h,0C7h,0C8h,0C6h,0C7h
		db	0C9h, 76h, 01h, 18h, 85h,0C3h
		db	 46h,0CCh, 86h,0C3h, 46h, 48h
		db	0C7h,0C6h, 88h,0C3h, 46h,0C6h
		db	 86h,0C3h, 56h,0D8h, 84h,0C3h
		db	 56h,0C6h,0C8h,0C7h,0CAh, 66h
		db	0CCh, 87h,0C3h, 56h, 86h,0C3h
		db	 05h, 07h, 02h, 18h, 85h,0C3h
		db	 56h, 02h, 18h, 83h,0C3h,0C5h
		db	0C7h,0CCh, 85h,0C4h, 0Ah, 07h
		db	0C6h, 87h,0C3h, 56h, 86h,0C3h
		db	 76h,0C8h, 01h, 18h, 86h,0C4h
		db	 56h,0C8h,0D8h, 84h,0C3h, 46h
		db	 86h,0C4h, 56h,0C8h, 56h,0C5h
		db	 66h,0C6h, 86h,0C3h, 46h,0CAh
		db	 86h,0C3h,0C5h, 76h,0D8h, 87h
		db	0C3h,0C5h, 56h, 85h,0C4h, 46h
		db	0CCh, 85h,0C3h, 66h, 4Bh, 05h
		db	 07h,0C8h, 01h, 18h, 84h,0C4h
		db	 46h, 02h, 18h, 84h,0C3h, 76h
		db	0CCh, 88h,0C3h,0C5h, 46h,0CCh
		db	 85h,0C3h, 56h,0D8h, 84h,0C3h
		db	0C5h,0C7h, 02h, 18h, 84h,0C4h
		db	 56h,0D8h, 85h,0C4h, 56h,0D8h
		db	 85h,0C3h, 66h,0C9h, 89h,0C3h
		db	 56h, 86h,0C3h,0C9h,0C8h, 02h
		db	 18h, 83h,0C3h, 46h,0C8h,0D8h
		db	 85h,0C3h,0C7h,0CAh,0C7h,0D8h
		db	 85h,0C3h, 46h,0C8h, 02h, 18h
		db	 83h,0C4h, 76h,0CCh, 88h,0C4h
		db	 56h, 01h, 18h, 84h,0C3h, 46h
		db	 01h, 18h, 84h,0C3h, 46h,0CCh
		db	 01h, 18h, 84h,0C3h,0C7h,0CCh
		db	 87h,0C3h, 56h,0D8h, 85h,0C4h
		db	 46h, 48h,0C7h,0C6h, 88h,0C4h
		db	 56h, 02h, 18h, 83h,0C3h, 46h
		db	0CCh, 85h,0C3h,0C7h,0CCh, 87h
		db	0C4h, 46h,0C6h, 86h,0C3h, 56h
		db	 86h,0C3h, 05h, 07h, 01h, 18h
		db	 86h,0C3h, 56h, 02h, 18h, 83h
		db	0C3h, 46h, 86h,0C3h,0C7h,0C6h
		db	 87h,0C4h, 46h,0CAh, 01h, 18h
		db	 83h,0C4h, 66h, 86h,0C3h, 66h
		db	0CAh,0C7h,0C8h, 02h, 18h, 84h
		db	0C3h, 46h,0CCh, 86h,0C4h, 46h
		db	0C6h, 85h,0C4h,0C7h,0C8h, 01h
		db	 18h, 85h,0C3h, 66h, 01h, 18h
		db	 81h,0C3h, 76h, 86h,0C3h, 05h
		db	 07h,0CCh, 87h,0C3h, 56h, 86h
		db	0C4h,0C7h,0C8h, 01h, 18h, 84h
		db	0C4h,0C7h,0CCh, 89h,0C4h, 08h
		db	 07h,0CAh,0C8h, 01h, 18h, 84h
		db	0C3h, 06h, 07h, 01h, 18h, 85h
		db	0C3h, 46h, 4Bh, 85h,0C3h, 56h
		db	0D8h, 84h,0C3h,0C7h,0C9h, 89h
		db	0C3h, 76h,0C5h, 76h,0D8h, 85h
		db	0C3h,0C5h, 76h,0CCh, 87h,0C4h
		db	 66h, 85h,0C3h, 46h,0CCh, 85h
		db	0C3h, 46h,0C6h, 8Ah,0C3h, 07h
		db	 07h,0CCh, 86h,0C3h, 06h, 07h
		db	0D8h, 86h,0C3h, 66h, 85h,0C3h
		db	0C7h,0C9h, 86h,0C3h, 46h,0C8h
		db	 01h, 18h, 88h,0C4h, 06h, 07h
		db	0C6h, 87h,0C4h, 06h, 07h,0D8h
		db	 86h,0C4h, 46h,0CAh,0C7h,0D8h
		db	 84h,0C3h, 46h,0C6h, 85h,0C3h
		db	0C5h, 46h,0D8h, 89h,0C3h,0C9h
		db	 76h,0CAh, 01h, 18h, 86h,0C3h
		db	 05h, 07h,0C8h, 02h, 18h, 84h
		db	0C3h, 56h, 02h, 18h, 83h,0C3h
		db	 46h,0C8h, 01h, 18h, 83h,0C3h
		db	0C7h,0CCh, 8Bh,0C3h, 05h, 07h
		db	0CCh, 88h,0C3h,0C7h,0C5h, 46h
		db	0CCh,0C7h,0CCh, 87h,0C3h, 56h
		db	 86h,0C3h,0C9h, 46h,0D8h, 84h
		db	0C4h, 46h,0D8h, 8Ah,0C3h, 06h
		db	 07h,0C6h, 87h,0C3h,0C7h,0C9h
		db	 46h,0C8h,0C7h, 88h,0C3h, 46h
		db	 4Bh, 85h,0C3h, 56h, 93h,0C3h
		db	 46h,0C5h, 56h,0C8h, 01h, 18h
		db	 86h,0C3h, 46h,0C9h, 56h,0C6h
		db	 87h,0C4h, 66h, 85h,0C4h, 56h
		db	 40h,0C2h, 40h,0C2h, 40h,0C2h
		db	 40h, 88h,0C3h, 66h,0C8h,0C7h
		db	 01h, 18h, 87h,0C3h, 06h, 07h
		db	 01h, 18h, 85h,0C4h, 66h, 85h
		db	0C3h, 46h,0C9h, 01h, 18h, 91h
		db	0C3h, 46h, 02h, 18h, 8Ah,0C3h
		db	0C7h, 48h, 56h,0CAh,0D8h, 86h
		db	0C3h, 56h,0C8h,0D8h, 84h,0C3h
		db	 76h,0C6h,0C7h, 45h, 9Dh,0C3h
		db	 05h, 07h, 01h, 18h, 86h,0C3h
		db	 66h, 85h,0C3h, 66h,0CAh, 56h
		db	0C8h, 02h, 18h, 9Ah,0C3h, 66h
		db	 01h, 18h, 88h,0C3h, 66h, 01h
		db	 18h, 83h,0C3h, 56h, 4Bh, 01h
		db	 18h, 66h, 9Bh,0C3h,0ECh, 46h
		db	0CAh, 02h, 18h, 87h,0C3h, 66h
		db	0D8h, 84h,0C3h,0C7h,0CAh, 02h
		db	 18h, 82h,0C3h, 46h,0CAh, 01h
		db	 18h, 89h,0C4h,0C7h,0C6h, 01h
		db	 18h, 83h,0C4h,0C7h, 45h, 05h
		db	 2Ch, 46h,0CCh, 8Ah,0C4h, 66h
		db	 85h,0C4h, 46h,0D8h, 84h,0C4h
		db	 56h,0D8h, 8Ah,0C4h, 46h,0C5h
		db	 76h, 4Ah,0ECh, 46h, 03h, 2Ch
		db	 46h, 01h, 18h, 88h,0E1h,0C7h
		db	 58h,0CCh, 85h,0C3h, 46h,0C6h
		db	 85h,0C3h, 56h, 8Ah,0C3h, 05h
		db	 07h,0C5h, 66h,0C5h,0C7h, 01h
		db	 2Ch, 66h,0D8h, 88h,0E1h, 46h
		db	 46h,0C9h,0CCh, 85h,0C3h, 46h
		db	0C6h, 85h,0C3h, 56h,0C8h, 01h
		db	 18h, 87h,0C3h, 08h, 07h,0CCh
		db	0C8h, 5Bh,0C7h,0C9h,0ECh, 46h
		db	0D8h, 87h,0E1h, 44h,0C7h, 66h
		db	 85h,0C4h, 46h,0CAh, 01h, 18h
		db	 83h,0C4h, 76h,0D8h, 87h,0C4h
		db	0C7h,0C9h, 56h,0CCh,0C7h,0C9h
		db	0C7h, 01h, 18h, 83h,0C3h, 58h
		db	0C7h,0D8h, 86h,0E1h,0C5h, 56h
		db	0C7h,0C8h,0C7h, 01h, 18h, 84h
		db	0C4h, 46h, 01h, 18h, 84h,0C3h
		db	 66h,0CAh,0C7h, 87h,0C4h, 66h
		db	0C8h, 01h, 18h, 87h,0C3h, 56h
		db	0CCh, 86h,0E1h, 76h, 4Bh, 46h
		db	0D8h, 84h,0C3h,0C7h,0CCh, 86h
		db	0C3h,0C7h,0C5h, 56h,0C8h, 46h
		db	 01h, 18h, 83h,0C3h, 66h, 03h
		db	 18h, 86h,0C3h, 56h,0C6h, 85h
		db	0E1h, 56h,0C8h,0C7h,0CCh, 84h
		db	0D8h, 84h,0C3h, 46h,0CCh, 85h
		db	0C4h, 07h, 07h, 85h,0C4h, 46h
		db	0CAh, 01h, 18h, 89h,0C4h, 66h
		db	 01h, 18h, 83h,0C4h, 56h, 01h
		db	 18h, 81h, 89h,0C3h,0C7h,0C8h
		db	 01h, 18h, 84h,0C3h, 05h, 07h
		db	0C8h, 01h, 18h, 84h,0C3h, 46h
		db	0D8h, 8Bh,0C4h, 48h,0C7h,0CAh
		db	0D8h, 84h,0C4h,0C5h, 56h,0D8h
		db	 81h, 82h,0C3h, 46h,0D8h, 83h
		db	0C4h,0C7h,0CCh, 86h,0C3h,0C7h
		db	0C5h, 66h,0C9h, 86h,0C3h, 46h
		db	 50h,0C2h, 40h,0C2h,0C1h,0C2h
		db	 40h, 81h,0C3h, 66h, 85h,0C3h
		db	 46h,0C8h, 01h, 18h, 81h, 82h
		db	0C3h, 46h,0CAh,0D8h,0C7h,0C6h
		db	 56h,0C6h, 85h,0C3h, 06h, 07h
		db	 02h, 18h, 83h,0C3h,0C7h,0CAh
		db	0D8h, 8Bh,0C3h, 66h, 85h,0C3h
		db	 56h, 83h, 82h,0C4h,0C9h, 56h
		db	0C6h,0C8h, 56h,0C8h, 01h, 18h
		db	 83h,0C3h, 76h,0C8h,0C7h,0D8h
		db	 85h,0C4h,0C7h, 02h, 18h, 83h
		db	0C3h,0C7h,0D8h, 84h,0C4h, 46h
		db	0C9h,0C6h,0D8h, 84h,0C3h, 46h
		db	 01h, 18h, 82h, 82h,0C3h,0C7h
		db	0C9h, 05h, 07h, 02h, 18h, 84h
		db	0C3h, 46h,0C9h,0C7h, 01h, 18h
		db	 87h,0C3h, 46h, 85h,0C3h,0C7h
		db	 85h,0DAh,0DFh, 46h,0CCh, 85h
		db	0C4h, 46h, 84h, 82h,0DAh,0DFh
		db	 46h,0CCh,0C8h, 02h, 18h, 87h
		db	0C4h,0C7h, 02h, 18h, 89h,0C3h
		db	 46h, 85h,0EBh,0ECh, 01h, 18h
		db	 83h,0DBh,0E0h, 56h, 85h,0C3h
		db	0C7h,0C8h, 01h, 18h, 82h, 82h
		db	0DBh,0E0h,0C7h,0C8h, 01h, 18h
		db	 98h,0C3h,0C7h,0D8h, 85h,0EBh
		db	0D8h, 85h,0DBh,0DEh,0C9h, 46h
		db	 85h,0C4h, 46h, 02h, 18h, 81h
		db	 82h,0DBh,0DEh, 46h, 60h,0C2h
		db	 40h,0C2h, 50h, 41h, 70h,0C2h
		db	 40h,0C2h, 50h, 81h,0C3h,0C8h
		db	 01h, 18h, 8Bh,0DBh,0DFh, 46h
		db	0CCh, 85h,0C4h, 46h, 84h, 82h
		db	0DBh,0DFh,0C7h,0CCh, 9Ah,0C3h
		db	 46h, 87h, 01h, 18h, 83h,0DBh
		db	0DFh,0C7h,0C9h,0CCh, 85h,0C3h
		db	 46h, 84h, 82h,0DDh,0DFh,0C7h
		db	0CCh, 85h,0C4h,0C7h,0C6h, 89h
		db	0C4h,0C7h,0D8h, 86h,0C3h, 46h
		db	 8Ch,0DBh,0DFh, 46h,0CCh, 85h
		db	0C3h,0C5h,0C7h, 84h, 82h,0C4h
		db	0C7h,0C8h,0D8h, 85h,0C4h, 56h
		db	0D8h, 87h,0C3h, 46h, 01h, 18h
		db	 84h,0C4h,0C7h,0CAh,0D8h, 8Bh
		db	0DBh,0DFh, 56h, 85h,0C3h, 46h
		db	 01h, 18h, 82h, 82h,0C3h, 46h
		db	 01h, 18h, 84h,0C3h
data_2		db	46h			; Data table (indexed access)
		db	0C8h, 01h, 18h, 86h,0C3h,0C7h
		db	0D8h, 86h,0C4h,0C7h, 01h, 18h
		db	 86h,0D8h, 84h,0DBh,0DFh, 46h
		db	0CCh, 85h,0C3h, 46h,0CCh, 83h
		db	 82h,0C4h, 46h,0CCh, 85h,0C3h
		db	0C9h, 46h, 02h, 18h, 85h,0C3h
		db	0C7h,0C8h, 01h, 18h, 84h,0C3h
		db	0C7h, 8Dh,0DBh,0DFh,0C7h,0C8h
		db	 02h, 18h, 83h,0C3h, 46h, 84h
		db	 82h,0C3h, 46h,0CAh,0D8h, 84h
		db	0C3h, 66h,0C8h, 02h, 18h, 83h
		db	0C3h, 46h,0D8h, 84h,0C4h, 46h
		db	 86h,0EBh,0C7h,0D8h, 84h,0DBh
		db	0DFh,0C7h,0C6h,0C8h, 01h, 18h
		db	 83h,0C4h, 46h, 84h, 82h,0C3h
		db	0C5h,0C7h,0CCh, 85h,0C3h, 76h
		db	 01h, 18h, 84h,0C4h, 46h,0C8h
		db	 01h, 18h, 82h,0C3h, 56h,0D8h
		db	 84h,0EBh,0ECh, 85h,0DBh,0DFh
		db	 56h,0D8h, 84h,0C3h, 46h, 84h
		db	 82h,0C3h, 46h,0CCh, 85h,0C3h
		db	0ECh, 56h,0CCh, 86h,0C4h, 76h
		db	 45h, 56h,0C8h, 01h, 18h, 83h
		db	0EBh,0ECh,0D9h, 84h,0DBh,0DFh
		db	 46h,0CCh, 85h,0DAh,0DFh,0C7h
		db	 84h, 82h,0C4h, 46h, 01h, 18h
		db	 84h,0C3h,0ECh, 46h,0C8h, 01h
		db	 18h, 85h,0C3h, 08h, 07h,0CCh
		db	 86h,0EBh,0ECh,0D9h,0D8h, 83h
		db	0DBh,0DFh,0C7h,0C9h, 86h,0DBh
		db	0DFh,0C9h, 84h, 82h,0C4h, 46h
		db	0C8h, 01h, 18h, 83h,0C4h,0ECh
		db	 56h,0C8h, 01h, 18h, 84h,0C4h
		db	 06h, 07h,0C9h, 46h,0D8h, 8Ch
		db	0DBh,0DFh, 46h,0C6h, 85h,0DBh
		db	0DFh,0C7h,0CCh, 83h, 82h,0C3h
		db	 46h,0D8h, 85h,0C3h,0ECh, 56h
		db	 01h, 18h, 86h,0C4h, 46h,0C5h
		db	 05h, 07h, 01h, 18h, 8Bh,0DBh
		db	0DFh, 46h,0C8h, 01h, 18h, 83h
		db	0DBh,0DFh,0C7h, 84h, 82h,0C3h
		db	 46h,0CCh, 85h,0C3h, 01h, 2Ch
		db	0CAh,0C7h,0D8h, 87h,0C3h, 56h
		db	0ECh, 56h,0CCh, 89h,0D8h, 84h
		db	0DBh,0DFh,0C9h, 46h,0D8h, 84h
		db	0DBh,0DFh,0C7h,0CBh,0D8h, 82h
		db	 82h,0C4h, 46h,0CCh, 85h,0C3h
		db	 01h, 2Ch,0C7h,0CCh, 88h,0C4h
		db	 56h,0ECh, 46h,0CCh,0C8h, 02h
		db	 18h, 8Bh,0DBh,0DFh, 56h, 85h
		db	0DBh,0E0h,0C7h,0CCh, 83h, 82h
		db	0C3h, 46h,0C9h, 85h,0C3h, 01h
		db	 2Ch,0C7h,0CCh, 8Ah,0C4h,0C7h
		db	0ECh, 46h,0C8h,0C7h,0D8h, 88h
		db	0D8h, 84h,0DBh,0DFh, 46h,0C8h
		db	 01h, 18h, 83h,0DBh,0DEh,0C9h
		db	 84h, 82h,0C3h, 46h,0CCh, 85h
		db	0C3h, 46h,0CCh, 8Bh,0C3h,0C7h
		db	 01h, 2Ch, 46h, 02h, 18h, 87h
		db	0D9h,0D8h, 83h,0DBh,0DFh,0C9h
		db	0C7h,0CCh, 85h,0DBh,0DFh,0C7h
		db	 01h, 18h, 82h, 82h,0C4h, 56h
		db	0D8h, 84h,0C3h, 56h,0D8h, 8Ah
		db	0C4h,0C7h, 01h, 2Ch,0C7h,0CCh
		db	 88h,0EBh,0ECh, 85h,0DBh,0DFh
		db	 56h, 85h,0DBh,0DFh,0C7h,0D8h
		db	 83h, 82h,0C3h,0C7h,0C8h, 01h
		db	 18h, 84h,0C4h, 46h,0CAh, 01h
		db	 18h, 89h,0C3h,0C7h, 01h, 2Ch
		db	0C7h,0CCh, 88h,0EBh,0CAh,0D8h
		db	 84h,0DBh,0DFh, 46h,0CCh,0D8h
		db	 84h,0DBh,0DFh
		db	0CCh, 84h, 82h,0C3h, 46h,0D8h
		db	 85h,0C3h, 46h,0CCh, 8Bh,0C3h
		db	 46h,0ECh,0C7h, 01h, 18h, 87h
		db	0EBh,0ECh, 85h,0DBh,0DFh, 46h
		db	0CCh, 85h,0DBh,0DFh,0C7h, 84h
		db	 82h,0C3h,0C7h,0CCh, 86h,0C3h
		db	 46h, 03h, 18h, 82h,0C4h,0D8h
		db	 84h,0C4h,0C7h,0C5h,0ECh,0C7h
		db	0CCh, 88h,0C3h,0ECh, 85h,0DBh
		db	0DFh,0C7h,0C6h, 86h,0DBh,0DFh
		db	0C6h, 84h, 82h,0C3h,0C7h,0C9h
		db	 86h,0C4h, 46h,0D8h, 85h,0C4h
		db	0C6h, 84h,0C3h, 46h,0ECh,0C8h
		db	0C7h,0D8h, 87h,0C3h,0C7h, 85h
		db	0DBh,0DFh,0C7h,0C8h, 02h, 18h
		db	 83h,0DBh,0DFh,0C7h, 01h, 18h
		db	 82h, 82h,0C3h,0C7h,0CCh, 86h
		db	0C3h,0C7h,0CCh, 86h,0C3h,0C7h
		db	0D8h, 83h,0C3h, 46h,0ECh,0C6h
		db	0C8h, 02h, 18h, 83h,0DAh,0DEh
		db	 46h, 01h, 18h, 83h,0DBh,0DFh
		db	 56h,0D8h, 84h,0DBh,0E0h,0C7h
		db	0D8h, 83h, 82h,0C4h, 46h,0CCh
		db	 85h,0C3h, 46h,0CCh, 85h,0C4h
		db	0C7h, 84h,0C3h, 46h,0ECh, 46h
		db	 01h, 18h, 84h,0DBh,0DFh, 46h
		db	 85h,0DBh,0DFh, 56h,0D8h, 84h
		db	0DBh,0DEh,0C6h, 84h, 82h,0C4h
		db	 46h,0D8h, 85h,0C3h,0C7h,0C8h
		db	0CCh, 85h,0C4h,0C7h, 84h,0C3h
		db	 02h, 2Ch,0C7h,0CCh, 86h,0DBh
		db	0DFh,0C7h,0CAh,0D8h, 84h,0DBh
		db	0DFh, 46h,0CCh, 85h,0DBh,0DFh
		db	0C7h, 01h, 18h, 82h, 82h,0C3h
		db	0C7h,0C8h, 01h, 18h, 84h,0C3h
		db	 46h,0CCh, 85h,0C3h,0D8h, 84h
		db	0C3h, 02h, 2Ch,0CAh,0CCh, 85h
		db	0DAh,0DEh, 56h, 85h,0DBh,0DFh
		db	 56h, 85h,0DDh,0DFh,0C7h, 02h
		db	 18h, 81h, 82h,0C3h, 46h, 86h
		db	0C3h, 46h,0CCh, 85h,0C3h,0C7h
		db	0D8h, 83h,0C4h, 02h, 2Ch,0C7h
		db	0CCh, 85h,0DBh,0DFh, 56h, 85h
		db	0DBh,0DFh,0C9h, 46h, 85h,0C3h
		db	0C7h,0C6h, 84h, 82h,0C3h,0C7h
		db	0C8h,0C7h, 85h,0C3h,0C7h,0C8h
		db	 01h, 18h, 84h,0C4h,0C7h,0D8h
		db	 83h,0C4h, 46h,0ECh,0C7h,0CCh
		db	 85h,0DBh,0DFh, 46h,0CAh, 85h
		db	0DBh,0DFh, 56h, 85h,0C3h, 46h
		db	0C6h, 83h, 82h,0C3h, 46h, 01h
		db	 18h, 84h,0C3h, 46h,0CCh, 85h
		db	0C3h,0C7h,0C8h, 01h, 18h, 81h
		db	0C3h,0C7h,0C9h,0ECh,0C7h,0D8h
		db	 85h,0DBh,0DFh, 56h, 01h, 18h
		db	 83h,0DBh,0DFh, 46h,0C6h, 85h
		db	0C4h, 46h, 01h, 18h, 82h, 82h
		db	0C4h,0C7h,0D8h, 86h,0C3h, 56h
		db	 85h,0C3h, 66h,0C6h, 56h,0ECh
		db	 46h,0D8h, 84h,0DBh,0DFh,0C7h
		db	0CAh, 02h, 18h, 83h,0DBh,0DFh
		db	 46h,0C8h,0D8h, 84h,0DAh,0DFh
		db	 46h, 01h, 18h, 81h, 8Bh,0C4h
		db	 46h,0CAh,0D8h, 84h,0C3h, 01h
		db	 2Ch, 66h,0ECh,0C7h,0ECh,0C7h
		db	0CAh,0D9h, 01h, 18h, 82h,0DBh
		db	0DFh, 46h, 86h,0DBh,0DFh, 46h
		db	 01h, 18h, 84h,0DBh,0DFh,0C7h
		db	0CCh, 83h,0C2h, 50h,0C2h,0C1h
		db	0C2h,0C1h, 83h,0C4h,0C7h,0ECh
		db	0CCh, 85h,0C3h, 01h, 2Ch, 46h
		db	 4Bh, 66h,0ECh, 01h, 18h, 83h
		db	0DBh,0DFh, 56h, 01h, 18h, 83h
		db	0DBh,0DFh,0C7h,0CCh, 86h,0DBh
		db	0DFh,0C7h,0CAh,0C7h,0C1h,0C2h
		db	 8Bh,0C3h,0ECh,0C7h,0CCh, 85h
		db	0C3h,0ECh,0C7h,0CAh,0D8h, 83h
		db	0DBh,0DFh,0C7h,0CCh, 85h,0DBh
		db	0DFh, 46h,0CCh, 85h,0DBh,0DFh
		db	 46h, 86h,0DBh,0DFh, 46h,0CCh
		db	 82h,0D8h, 8Ah,0C3h,0ECh,0C7h
		db	0C6h, 85h,0C3h,0C5h,0C7h, 02h
		db	 18h, 82h,0DBh,0DFh,0C7h,0CCh
		db	 85h,0DBh,0E0h, 46h,0D8h, 85h
		db	0DBh,0DFh, 46h,0C6h, 85h,0DBh
		db	0E0h, 66h,0D8h,0C7h, 02h, 18h
		db	 87h,0C3h,0ECh, 46h,0D8h, 84h
		db	0C3h, 46h,0D8h, 84h,0DBh,0DFh
		db	 46h,0D9h,0D8h, 83h,0DBh,0DEh
		db	 46h, 01h, 18h, 84h,0DBh,0DFh
		db	 56h,0D8h, 84h,0DBh,0DEh,0C9h
		db	 46h,0CAh,0C7h,0C8h, 46h, 01h
		db	 18h, 86h,0C4h,0ECh,0C7h,0C8h
		db	 01h, 18h, 83h,0C4h,0C7h, 01h
		db	 18h, 84h,0DBh,0DFh,0C7h,0D9h
		db	0D8h, 84h,0DBh,0DFh, 46h,0CCh
		db	 85h,0DBh,0DFh, 46h,0CAh, 01h
		db	 18h, 83h,0DBh,0DFh, 76h,0C6h
		db	0C8h, 02h, 18h, 86h,0C3h,0ECh
		db	0C7h,0CCh, 8Dh,0DBh,0DFh,0C9h
		db	 01h, 18h, 84h,0DBh,0DFh, 46h
		db	0CAh, 85h,0DBh,0DFh, 46h,0CCh
		db	 85h,0DBh,0DFh, 76h, 56h, 45h
		db	 82h,0C3h,0C6h, 82h,0C3h, 56h
		db	 50h,0C2h,0C1h,0C2h, 40h,0C2h
		db	0C1h, 83h,0DBh,0DFh, 46h, 01h
		db	 18h, 83h,0DBh,0DFh, 46h,0CCh
		db	 85h,0DBh,0DFh, 56h, 85h,0DBh
		db	0DFh, 56h,0ECh,0C7h, 08h, 07h
		db	0C9h, 66h,0CCh, 8Dh,0DBh,0DFh
		db	0C7h,0CCh, 85h,0DBh,0DFh, 46h
		db	0CCh, 85h,0DBh,0DFh,0C5h, 46h
		db	 85h,0DBh,0DFh,0C7h,0C9h,0C7h
		db	 01h, 2Ch, 66h,0ECh,0C7h,0C9h
		db	 05h, 07h,0CAh,0CCh, 85h,0C4h
		db	0C6h, 86h,0DBh,0DFh,0C7h,0CCh
		db	 85h,0DBh,0DFh, 46h,0C8h, 01h
		db	 18h, 83h,0DBh,0DFh, 46h,0C6h
		db	 85h,0DBh,0DFh, 66h,0ECh,0C8h
		db	0CCh, 01h, 18h,0CCh, 08h, 07h
		db	 01h, 18h, 84h,0C3h,0C7h, 01h
		db	 18h, 84h,0DBh,0DFh,0C7h,0CCh
		db	 85h,0DBh,0DEh, 46h,0C8h, 85h
		db	0DBh,0DFh, 56h, 01h, 18h, 83h
		db	0DBh,0DFh, 66h,0CCh, 02h, 18h
		db	 86h,0C3h, 66h,0D8h, 85h,0C4h
		db	 46h, 01h, 18h, 83h,0DBh,0DFh
		db	0C7h,0C8h, 01h, 18h, 83h,0DBh
		db	0DFh, 46h, 01h, 18h, 84h,0DBh
		db	0DFh, 46h,0C8h,0D8h, 84h,0DBh
		db	0DFh, 66h,0C8h,0D8h, 89h,0DBh
		db	0DFh, 46h,0C6h, 85h,0C4h, 46h
		db	0C6h, 84h,0DBh,0DFh,0C7h,0D9h
		db	0D8h, 84h,0DBh,0DFh, 46h,0C6h
		db	 85h,0DBh,0DFh, 46h, 01h, 18h
		db	 84h,0DBh,0DEh,0C9h, 56h,0D8h
		db	 60h,0C2h,0C1h,0C2h, 40h, 81h
		db	0DBh,0DFh,0C9h,0C8h, 01h, 18h
		db	 84h,0C3h,0C7h,0C8h, 02h, 18h
		db	 82h,0DBh,0DFh,0C7h,0CCh, 85h
		db	0DBh,0DFh, 56h,0D8h, 84h,0DBh
		db	0DFh,0C7h,0CAh,0CCh, 85h,0DBh
		db	0DFh, 56h, 40h, 8Ah,0DBh,0DFh
		db	 46h,0C6h, 85h,0C3h, 46h, 01h
		db	 18h, 83h,0DBh,0DFh,0C7h,0CCh
		db	 85h,0DBh,0DFh, 56h,0D8h, 84h
		db	0DBh,0DFh,0C7h,0CCh, 86h,0DBh
		db	0E0h, 56h, 82h, 83h,0C4h, 86h
		db	0DBh,0DFh, 46h,0CCh, 85h,0C3h
		db	 46h,0CCh, 84h,0DBh,0DFh,0C9h
		db	0D9h, 85h,0DBh,0DFh, 56h, 01h
		db	 18h, 83h,0DBh,0DFh,0C7h,0D8h
		db	 86h,0DBh,0DEh, 46h,0C8h, 01h
		db	 18h,0D8h, 82h,0C4h, 01h, 18h
		db	 84h,0DBh,0DFh, 46h,0CCh, 85h
		db	0C3h,0C9h, 4Bh, 84h,0DBh,0DFh
		db	0C7h,0CCh, 85h,0DBh,0DFh, 46h
		db	 02h, 18h, 83h,0DDh,0E0h, 01h
		db	 18h, 86h,0DBh,0DFh, 56h, 01h
		db	 18h, 83h,0C3h,0C8h, 01h, 18h
		db	 83h,0DBh,0DFh, 46h, 01h, 18h
		db	 84h,0C3h,0C7h,0CCh, 85h,0DBh
		db	0DFh,0C7h,0CCh, 85h,0DBh,0DFh
		db	 46h,0C6h, 8Fh,0C4h,0C7h,0ECh
		db	 46h, 82h, 83h,0C3h,0C7h,0CAh
		db	0C6h, 83h,0DDh,0E0h, 56h, 01h
		db	 18h, 83h,0C4h, 46h,0CCh, 84h
		db	0DBh,0DFh,0C7h, 86h,0DBh,0DFh
		db	 56h, 50h,0C2h,0C1h,0C2h, 60h
		db	 41h, 40h, 81h,0C4h,0C7h,0ECh
		db	 46h, 82h, 83h,0C3h, 46h,0D8h
		db	 84h,0DBh,0DFh, 46h,0C6h, 84h
		db	0C3h,0ECh,0C7h,0CCh, 84h,0DBh
		db	0DFh,0C8h, 02h, 18h, 83h,0DBh
		db	0DFh, 56h, 8Fh,0C3h,0C7h,0ECh
		db	0C7h,0C8h, 01h, 18h, 83h,0C3h
		db	0C7h, 86h,0DBh,0DFh, 46h,0C6h
		db	 84h,0C3h,0ECh,0C7h,0C8h,0D8h
		db	 83h,0DBh,0DFh, 46h,0D9h,0D8h
		db	 83h,0DBh,0E0h, 56h, 02h, 18h
		db	 8Ch,0C4h, 66h,0D8h, 81h, 83h
		db	0C4h,0C7h, 86h,0DBh,0DFh,0C9h
		db	 56h,0D8h, 81h,0C4h,0C7h,0ECh
		db	0C7h,0CCh, 84h,0DBh,0DFh, 46h
		db	0D9h, 01h, 18h, 82h,0DBh,0DEh
		db	 76h, 04h, 18h, 88h,0DAh,0DFh
		db	 46h,0CCh, 82h, 83h,0C3h,0D8h
		db	 86h,0DBh,0DFh, 56h,0C8h,0C6h
		db	0C8h, 66h, 01h, 18h, 83h,0DBh
		db	0DFh,0C7h,0C9h,0D8h, 84h,0DBh
		db	0DFh, 05h, 07h,0C8h,0C7h, 02h
		db	 18h, 87h,0DBh,0DFh,0C9h, 46h
		db	 82h, 8Bh,0DBh,0DFh, 07h, 07h
		db	0C8h,0C7h, 01h, 18h, 83h,0DBh
		db	0DFh,0C7h,0CCh, 85h,0DBh,0DFh
		db	 06h, 07h,0C6h, 8Ah,0DBh,0DFh
		db	 56h, 82h, 8Bh,0DDh,0E0h,0C7h
		db	0C9h, 56h,0ECh, 56h,0C6h, 85h
		db	0DBh,0DFh,0C7h,0CCh, 85h,0DBh
		db	0DFh, 06h, 07h,0C8h,0C6h, 89h
		db	0DBh,0DFh, 46h,0CCh, 82h, 8Ch
		db	0DBh,0DFh, 46h,0CCh,0CAh, 46h
		db	0CAh,0C7h, 02h, 18h, 83h,0DBh
		db	0DFh,0C7h,0CCh, 85h,0DBh,0DFh
		db	 05h, 07h,0C5h, 56h,0C6h,0D8h
		db	 86h,0DBh,0DFh,0C7h,0C8h,0C7h
		db	 01h, 18h,0D8h, 8Bh,0DBh,0DFh
		db	 46h,0C8h, 76h,0C6h, 85h,0DBh
		db	0DFh,0C7h,0C8h, 01h, 18h, 83h
		db	0DBh,0DFh, 09h, 07h,0C8h, 02h
		db	 18h, 84h,0DBh,0DFh, 56h, 01h
		db	 18h, 8Ch,0DBh,0DFh, 46h, 4Bh
		db	0D8h, 81h,0C3h, 46h,0D8h, 84h
		db	0DBh,0DFh, 46h, 85h,0DBh,0E0h
		db	 07h, 07h,0C8h, 4Bh, 87h,0DBh
		db	0DFh,0C9h,0C7h,0CCh, 82h, 8Ch
		db	0DBh,0DFh,0C8h, 01h, 18h, 83h
		db	0C3h,0C7h,0C8h, 01h, 18h, 83h
		db	0DBh,0DFh,0C8h, 02h, 18h, 83h
		db	0DBh,0E0h, 0Ah, 07h,0D8h, 86h
		db	0DBh,0DFh, 46h,0CCh, 82h, 8Ch
		db	0DBh,0DFh,0C7h,0D8h, 84h,0C4h
		db	0C7h,0CCh, 85h,0DBh,0DFh,0C7h
		db	0C6h, 85h,0DBh,0DFh, 09h, 07h
		db	0CCh, 87h,0DBh,0DFh, 56h, 82h
		db	 8Ch,0DBh,0DFh,0C7h,0CCh, 84h
		db	0C3h, 46h,0CCh, 84h,0DBh,0DFh
		db	0C7h,0CCh, 85h,0DBh,0DFh, 46h
		db	0ECh, 66h,0ECh, 46h, 88h,0DBh
		db	0DFh, 56h, 01h, 18h,0D8h, 8Bh
		db	0DDh,0E0h,0C7h, 01h, 18h, 83h
		db	0C3h, 46h,0CCh, 84h,0DBh,0DFh
		db	0C7h,0CCh, 85h,0DBh,0DFh, 05h
		db	 07h,0ECh, 56h, 88h,0DBh,0DFh
		db	 46h,0CAh, 01h, 18h, 8Dh,0DBh
		db	0DFh,0D8h, 84h,0C3h, 46h, 01h
		db	 18h, 83h,0DDh,0DFh,0C7h,0D9h
		db	 01h, 18h, 83h,0DBh,0DFh, 56h
		db	0ECh, 46h,0ECh, 56h,0C6h, 87h
		db	0DBh,0DFh, 46h,0CCh, 82h, 83h
		db	0C4h, 46h, 87h,0DDh,0E0h, 85h
		db	0C4h,0C7h,0CAh,0CCh, 85h,0C3h
		db	0C7h,0C8h,0D8h, 84h,0DDh,0DFh
		db	 56h,0ECh, 56h,0ECh, 46h,0C8h
		db	 02h, 18h, 84h,0DBh,0DFh, 46h
		db	0C6h, 82h, 83h,0C3h,0C5h,0C7h
		db	 01h, 18h, 8Ch,0C4h, 46h,0CCh
		db	 85h,0C3h,0C7h, 01h, 18h, 84h
		db	0C3h, 66h,0ECh, 66h,0ECh, 46h
		db	 01h, 18h, 85h,0DBh,0DFh, 46h
		db	0C6h, 82h, 83h,0C4h, 56h,0C1h
		db	0C2h, 40h,0C2h,0C1h, 41h, 60h
		db	 81h,0C3h, 46h, 01h, 18h, 84h
		db	0C4h,0C7h,0D8h, 85h,0C4h, 08h
		db	 07h,0ECh,0C7h,0CAh, 87h,0DBh
		db	0DFh, 56h,0D8h, 81h, 83h,0C3h
		db	 56h, 01h, 18h, 8Bh,0C3h, 46h
		db	0CCh, 8Bh,0C3h, 66h, 5Bh, 05h
		db	 07h,0CCh, 87h,0DBh,0DFh,0C9h
		db	0C7h,0CCh, 82h, 83h,0C3h,0C7h
		db	0C8h, 56h,0CAh,0C7h, 01h, 18h
		db	 87h,0C3h, 56h, 40h,0C2h, 40h
		db	0C2h,0C1h,0C2h, 40h, 81h,0C3h
		db	 56h, 4Bh, 82h,0C4h, 76h,0CCh
		db	 87h,0DBh,0DFh,0C7h,0C9h, 01h
		db	 18h, 81h, 84h,0C3h, 07h, 07h
		db	 01h, 18h, 85h,0C3h, 66h,0D8h
		db	 89h,0C3h, 46h, 01h, 18h, 83h
		db	0C3h, 56h,0CAh,0C6h, 88h,0DBh
		db	0DFh, 46h,0CCh, 82h,0D8h, 83h
		db	0C3h, 46h,0C8h, 66h,0C8h,0D8h
		db	 86h,0C3h, 56h,0C8h,0C7h, 02h
		db	 18h, 85h,0C3h, 56h,0D8h, 84h
		db	0C4h, 76h,0C6h, 87h,0DBh,0DFh
		db	 46h,0CBh, 01h, 18h, 84h,0C4h
		db	0C7h, 01h, 18h, 81h,0C3h, 56h
		db	 01h, 18h, 85h,0C3h, 05h, 07h
		db	0CAh,0C8h, 02h, 18h, 82h,0C4h
		db	 46h,0CCh, 85h,0C3h, 76h,0C8h
		db	 01h, 18h, 85h,0DBh,0DFh, 46h
		db	0C8h,0D8h, 81h, 8Ah,0EBh, 48h
		db	 87h,0C3h, 07h, 07h,0C6h,0C8h
		db	0C7h,0CBh, 66h,0D8h, 85h,0C3h
		db	 05h, 07h, 03h, 18h, 83h,0DBh
		db	0DFh, 46h,0CCh, 82h, 08h, 01h
		db	 81h,0EBh,0ECh,0D8h, 87h,0C4h
		db	 56h,0C9h, 06h, 07h,0C8h, 56h
		db	0C9h, 86h,0C4h, 05h, 07h, 87h
		db	0DBh,0DFh, 56h, 40h, 8Ah,0EBh
		db	 01h, 2Ch,0D8h, 86h,0C3h, 05h
		db	 07h,0CBh, 56h,0CAh,0CBh, 66h
		db	0D8h, 85h,0C3h, 76h, 01h, 18h
		db	 86h,0DBh,0DFh, 56h, 82h, 84h
		db	0C4h, 88h,0D9h,0D8h, 85h,0C3h
		db	 08h, 07h,0D8h,0CCh, 81h,0C3h
		db	 46h,0C8h, 01h, 18h, 84h,0C3h
		db	 05h, 07h, 87h,0DBh,0DFh, 46h
		db	 01h, 18h, 81h, 84h,0C3h,0D8h
		db	 87h,0D8h, 86h,0C3h, 76h,0CCh
		db	0CAh, 02h, 18h, 82h,0C3h, 46h
		db	0CCh, 86h,0C3h,0C5h, 66h,0CCh
		db	 87h,0DBh,0DFh,0C9h,0C7h,0CCh
		db	 82h, 84h,0C3h,0D8h, 8Eh,0C3h
		db	0C7h,0C9h, 66h,0D8h, 85h,0C4h
		db	0C7h,0C9h, 87h,0C4h, 76h,0CCh
		db	 87h,0DBh,0DFh, 46h,0CBh,0D8h
		db	 81h, 83h,0E1h,0C7h, 01h, 18h
		db	 86h,0D8h, 86h,0C4h, 66h,0CBh
		db	 01h, 18h, 85h,0C4h, 46h,0C6h
		db	 86h,0C4h, 66h,0C8h,0C7h, 01h
		db	 18h, 85h,0DBh,0DFh,0C7h,0C8h
		db	 01h, 18h, 81h, 82h,0E1h,0C7h
		db	 01h, 18h, 85h,0EBh,0ECh, 01h
		db	 18h, 85h,0C3h, 66h,0CCh, 87h
		db	0C3h, 46h,0C8h, 01h, 18h, 84h
		db	0C3h,0C7h,0C5h, 46h,0C6h,0C8h
		db	 02h, 18h, 84h,0DBh,0DFh,0C7h
		db	0CCh, 83h, 81h,0E1h, 46h, 01h
		db	 18h, 84h,0EBh, 02h, 2Ch,0D8h
		db	 85h,0C3h, 46h,0CCh,0C8h,0CCh
		db	 87h,0C3h, 46h,0D8h, 86h,0C4h
		db	 76h,0CCh, 87h,0DBh,0DFh,0C7h
		db	 01h, 18h, 82h, 81h,0C4h,0C7h
		db	0D8h, 86h,0EBh,0ECh,0C7h,0ECh
		db	0C8h, 01h, 18h, 83h,0C3h, 46h
		db	0C8h,0C5h, 01h, 18h, 86h,0C3h
		db	 46h,0C6h, 86h,0C3h, 66h,0CAh
		db	0CCh, 87h,0DDh,0DFh,0C7h,0CCh
		db	 83h, 81h,0C3h,0C7h,0CCh, 85h
		db	0DAh,0DFh, 05h, 07h,0D8h,0C8h
		db	 66h,0CCh, 89h,0C3h, 46h,0C6h
		db	 86h,0C3h, 66h,0CCh, 88h,0C3h
		db	0C7h,0CBh, 84h, 81h,0C4h,0C7h
		db	 01h, 18h, 84h,0DBh,0DFh, 06h
		db	 07h,0C6h,0C8h, 46h,0C8h,0C7h
		db	 01h, 18h, 87h,0C4h, 56h,0D8h
		db	 85h,0C3h, 76h,0C6h, 87h,0C3h
		db	0C8h,0C7h, 01h, 18h, 82h, 81h
		db	0C3h,0C9h, 86h,0DBh,0DFh, 06h
		db	 07h,0CAh, 56h, 02h, 18h, 88h
		db	0C3h,0C7h,0C8h, 01h, 18h, 85h
		db	0C3h, 76h,0C8h, 01h, 18h, 85h
		db	0C3h,0C7h,0D8h, 84h, 81h,0C3h
		db	0C7h, 01h, 18h, 84h,0DBh,0DFh
		db	 05h, 07h,0CCh, 46h,0CCh, 8Ch
		db	0C3h, 46h, 02h, 18h, 84h,0C3h
		db	 76h,0C6h, 87h,0C4h, 01h, 18h
		db	 84h, 89h,0DBh,0DFh,0C7h,0C9h
		db	 46h,0C8h, 02h, 18h, 8Eh,0C4h
		db	0C7h,0D8h, 87h,0C3h, 66h,0CAh
		db	0C6h, 8Eh,0C1h,0C2h, 60h,0C2h
		db	0C1h, 81h,0DBh,0DFh, 76h, 01h
		db	 18h, 99h,0C4h, 05h, 07h, 40h
		db	0C2h, 40h,0C2h, 50h,0C2h,0C1h
		db	0C2h, 40h, 89h,0DBh,0DFh, 76h
		db	 50h,0C2h, 40h,0C2h, 50h,0C2h
		db	0C1h,0C2h, 40h,0C2h, 70h,0C2h
		db	 60h, 81h,0C4h,0C7h,0CBh, 56h
		db	0C6h, 8Eh,0C6h, 88h,0DBh,0DFh
		db	 66h, 01h, 18h, 9Ah,0C3h, 66h
		db	0C8h,0C7h, 02h, 18h, 8Ah,0C4h
		db	0C8h,0C6h, 87h,0DBh,0DFh, 56h
		db	 01h, 18h, 86h,0C4h, 46h, 02h
		db	 18h, 8Fh,0C3h, 05h, 07h,0C6h
		db	 01h, 18h,0CAh,0C6h, 01h, 18h
		db	 86h,0C3h,0C7h,0CAh,0C8h,0C6h
		db	 85h,0DBh,0DFh,0C9h, 56h,0CAh
		db	 01h, 18h, 84h,0C3h, 66h,0C8h
		db	 02h, 18h, 8Ch,0C4h, 0Dh, 07h
		db	 02h, 18h, 82h,0C3h, 66h, 01h
		db	 18h, 83h,0DBh,0DFh, 56h, 01h
		db	 18h, 86h,0C4h, 06h, 07h,0C9h
		db	 01h, 18h, 05h, 07h,0C6h, 76h
		db	0C5h, 76h,0CAh, 76h,0CAh, 46h
		db	0C6h,0CAh,0C6h,0C7h, 05h, 07h
		db	0C8h, 45h, 66h,0CCh, 88h,0C3h
		db	 46h,0C9h, 76h,0C8h, 66h,0C5h
		db	 66h,0C5h, 0Eh, 07h,0C6h,0C8h
		db	 76h, 08h, 07h,0CAh, 66h,0CCh
		db	 87h,0C3h, 11h, 07h, 4Bh, 0Fh
		db	 07h,0CCh,0C8h,0C7h, 01h, 2Ch
		db	 0Ch, 07h,0C8h, 01h, 18h, 86h
		db	0C4h, 09h, 07h,0CBh, 66h,0C8h
		db	0D8h, 83h,0C4h, 0Dh, 07h,0CCh
		db	0C8h, 82h, 46h, 66h,0CCh,0C8h
		db	0C7h,0CCh,0C8h, 05h, 07h, 01h
		db	 18h, 85h,0C4h, 0Ch, 07h,0CAh
		db	 01h, 18h, 84h,0C3h, 06h, 07h
		db	0C8h, 06h, 07h,0ECh, 82h, 01h
		db	 2Ch, 06h, 07h,0C8h, 05h, 07h
		db	0CAh, 02h, 18h, 84h,0C3h, 0Dh
		db	 07h, 02h, 18h, 83h,0C3h, 56h
		db	0CAh, 66h,0D8h, 81h,0C4h,0C7h
		db	0C8h,0C7h,0D8h, 83h,0C3h,0C7h
		db	 56h,0C8h,0C7h, 03h, 18h, 81h
		db	0C3h, 56h,0CCh, 87h,0C3h,0C7h
		db	0C5h, 0Bh, 07h,0D8h, 85h,0C3h
		db	 76h, 02h, 18h, 83h,0C3h,0C7h
		db	0D8h, 84h,0C3h,0C7h, 76h,0CCh
		db	 01h, 18h, 83h,0C3h, 46h,0CCh
		db	 87h,0C3h, 06h, 07h,0ECh, 66h
		db	0C8h, 02h, 18h, 84h,0C4h, 46h
		db	 02h, 18h, 86h,0C3h, 46h,0D8h
		db	 83h,0C3h,0C5h, 66h,0CCh, 86h
		db	0C3h,0C7h,0C8h, 01h, 18h, 86h
		db	0C3h, 06h, 07h,0ECh, 76h, 93h
		db	0C4h,0C7h, 85h,0C4h,0C7h, 66h
		db	0CAh, 01h, 18h, 84h,0C3h,0C7h
		db	 01h, 18h, 87h,0C4h, 06h, 07h
		db	 01h, 2Ch, 66h,0C1h,0C2h, 40h
		db	0C2h, 50h,0C2h,0C1h,0C2h, 50h
		db	0C2h, 50h, 81h,0C3h,0D8h, 85h
		db	0C4h,0C7h, 66h,0CCh, 86h,0C4h
		db	0CCh, 89h,0C3h, 07h, 07h, 02h
		db	 2Ch, 46h, 01h, 18h, 91h,0C3h
		db	0D8h, 85h,0C3h,0C7h, 56h,0CCh
		db	 92h,0C3h,0C7h,0C5h, 76h,0CAh
		db	0CCh,0C7h,0ECh, 56h, 88h,0C4h
		db	 02h, 18h, 86h,0C4h,0D8h, 85h
		db	0C3h,0C7h, 76h,0C1h,0C2h,0C1h
		db	0C2h, 60h,0C2h, 40h,0C2h, 40h
		db	0C2h,0C1h, 81h,0C3h, 05h, 07h
		db	0CCh,0C8h, 76h,0C8h, 02h, 18h
		db	 85h,0C3h, 46h, 02h, 18h, 8Bh
		db	0C3h,0C7h, 66h,0CCh, 91h,0C4h
		db	 09h, 07h,0CAh, 76h, 01h, 18h
		db	 84h,0C3h,0C7h,0CAh,0C7h,0C6h
		db	 8Ch,0C3h,0C7h, 76h,0D8h, 85h
		db	0C4h,0C7h, 45h, 01h, 18h, 84h
		db	0C4h, 05h, 07h,0C8h, 02h, 18h
		db	 05h, 07h,0CAh, 02h, 18h, 83h
		db	0C3h, 56h, 01h, 18h, 8Bh,0C4h
		db	0C7h, 56h,0C8h, 02h, 18h, 84h
		db	0C3h, 56h,0CAh, 56h,0C6h, 81h
		db	0C3h, 56h,0C8h, 01h, 18h, 88h
		db	0C4h, 46h,0D8h, 85h,0C3h, 56h
		db	0C6h, 8Bh,0DAh,0DFh,0C9h, 66h
		db	0CCh, 86h,0C3h, 76h,0C6h,0C8h
		db	 66h, 01h, 18h, 8Ch,0C3h, 46h
		db	 85h,0C4h, 56h,0C8h, 01h, 18h
		db	 89h,0DBh,0DFh,0C7h, 5Ah, 00h
		db	 12h,0FFh,0FFh,0FFh,0FFh, 04h
		db	 80h,0B9h,0E7h, 00h, 0Bh, 00h
		db	 09h, 40h,0A6h, 04h, 00h, 0Eh
		db	 00h, 0Ah, 40h, 8Ch, 06h, 00h
		db	 0Ch, 00h, 19h, 80h, 38h, 12h
		db	 00h, 20h, 00h, 22h, 80h,0B0h
		db	 1Bh, 00h, 28h, 00h, 2Ah, 80h
		db	0B8h, 23h, 00h, 31h, 00h, 2Bh
		db	 80h,0A0h, 21h, 00h, 34h, 00h
		db	 37h, 40h, 85h, 2Eh, 00h, 3Fh
		db	 00h, 70h, 80h, 9Ah, 63h, 00h
		db	 79h, 00h,0BDh, 80h, 85h,0B6h
		db	 00h,0C0h, 00h,0FFh,0FFh, 09h
		db	 00h, 19h, 82h, 0Bh, 09h, 00h
		db	 19h, 00h,0FFh,0FFh,0FFh, 58h
		db	 00h, 22h, 83h, 0Bh, 58h, 00h
		db	 22h, 00h,0FFh,0FFh,0FFh, 64h
		db	 00h, 3Bh, 84h, 0Bh, 64h, 00h
		db	 3Bh, 00h,0FFh,0FFh,0FFh, 83h
		db	 00h, 35h, 82h, 0Bh, 83h, 00h
		db	 35h, 00h,0FFh,0FFh,0FFh, 8Dh
		db	 00h, 3Eh, 82h, 0Bh, 8Dh, 00h
		db	 3Eh, 00h,0FFh,0FFh,0FFh, 9Dh
		db	 00h, 10h, 01h, 0Dh, 11h, 00h
		db	 15h, 00h, 24h, 00h, 10h,0CEh
		db	 00h, 27h, 84h, 0Bh,0CEh, 00h
		db	 27h, 00h,0FFh,0FFh,0FFh,0FFh
		db	0FFh, 20h, 00h,0FFh, 13h,0C0h
		db	0FFh,0FFh,0FFh,0FFh, 23h, 00h
		db	 40h, 88h,0DBh, 00h, 00h,0FFh
		db	0FFh, 23h, 00h, 20h, 5Fh,0DCh
		db	 00h,0FFh, 6Ah,0DCh,0FFh,0FFh
		db	0FFh,0FFh, 23h, 00h, 10h,0AFh
		db	0DCh, 00h,0FFh,0BAh,0DCh,0FFh
		db	0FFh,0FFh,0FFh, 23h, 00h, 08h
		db	0CFh,0DDh, 00h,0FFh,0DAh,0DDh
		db	0FFh,0FFh,0FFh,0FFh, 23h, 00h
		db	 04h,0FFh,0DDh, 00h,0FFh, 0Ah
		db	0DEh,0FFh,0FFh,0FFh,0FFh, 23h
		db	 00h, 02h, 1Fh,0DEh, 00h,0FFh
		db	 2Ah,0DEh,0FFh,0FFh,0FFh,0FFh
		db	 23h, 00h, 01h, 5Fh,0DEh, 00h
		db	0FFh, 6Ah,0DEh,0FFh,0FFh,0FFh
		db	0FFh, 24h, 00h, 80h, 7Fh,0DEh
		db	 00h,0FFh, 8Ah,0DEh,0FFh,0FFh
		db	0FFh,0FFh, 24h, 00h, 40h,0DFh
		db	0DEh, 00h, 00h,0FFh,0FFh, 24h
		db	 00h, 20h,0CFh,0DEh, 00h,0FFh
		db	0DAh,0DEh,0FFh,0FFh,0FFh,0FFh
		db	 24h, 00h, 10h, 4Fh,0DAh, 81h
		db	 0Dh,0FFh,0FFh,0FFh,0FFh, 16h
		db	0AFh, 00h, 12h
		db	'Cavern of Cementar'
		db	 11h, 00h, 04h, 08h, 08h, 03h
		db	 00h, 2Bh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 03h, 00h
		db	 2Bh, 02h, 00h, 05h, 00h, 3Bh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 05h, 00h, 3Bh, 02h
		db	 00h, 08h, 00h, 11h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 08h, 00h, 11h, 03h, 00h, 0Fh
		db	 00h, 2Bh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 0Fh, 00h
		db	 2Bh, 02h, 00h, 12h, 00h, 3Ch
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 12h, 00h, 3Ch, 03h
		db	 00h, 17h, 00h, 17h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 17h, 00h, 17h, 04h, 00h, 19h
		db	 00h, 03h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 19h, 00h
		db	 03h, 04h, 00h, 1Ah, 00h, 23h
		db	0FFh,0D0h, 00h, 00h, 20h, 00h
		db	 19h, 00h, 23h, 00h, 40h, 00h
		db	 00h, 1Ch, 00h, 13h,0FFh,0F1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh,0FFh, 00h, 00h, 1Eh
		db	 00h, 13h,0FFh,0F1h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	0FFh, 00h, 00h, 1Fh, 00h, 3Ch
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 1Fh, 00h, 3Ch, 03h
		db	 00h, 20h, 00h, 13h,0FFh,0F1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh,0FFh, 00h, 00h, 21h
		db	 00h, 03h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 21h, 00h
		db	 03h, 04h, 00h, 24h, 00h, 22h
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 24h, 00h, 22h, 00h
		db	 00h, 24h, 00h, 24h,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 24h, 00h, 24h, 01h, 00h, 2Ch
		db	 00h, 11h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 2Ch, 00h
		db	 11h, 03h, 00h, 3Ah, 00h, 08h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 3Ah, 00h, 08h, 02h
		db	 00h, 3Bh, 00h, 36h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 3Bh, 00h, 36h, 02h, 00h, 48h
		db	 00h, 22h,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 48h, 00h
		db	 22h, 00h, 00h, 48h, 00h, 24h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 48h, 00h, 24h, 01h
		db	 00h, 51h, 00h, 2Eh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 51h, 00h, 2Eh, 03h, 00h, 52h
		db	 00h, 36h,0FFh, 73h, 00h, 05h
		db	 20h, 00h, 00h, 00h, 23h, 00h
		db	 20h, 00h, 00h, 53h, 00h, 18h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 53h, 00h, 18h, 02h
		db	 00h, 58h, 00h, 03h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 58h, 00h, 03h, 04h, 00h, 5Dh
		db	 00h, 37h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 5Dh, 00h
		db	 37h, 04h, 00h, 60h, 00h, 07h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 60h, 00h, 07h, 03h
		db	 00h, 61h, 00h, 10h,0FFh, 76h
		db	 00h, 00h, 20h, 00h, 00h, 00h
		db	 23h, 00h, 10h, 00h, 00h, 63h
		db	 00h, 2Eh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 63h, 00h
		db	 2Eh, 03h, 00h, 64h, 00h, 24h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 64h, 00h, 24h, 03h
		db	 00h, 6Dh, 00h, 1Eh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 6Dh, 00h, 1Eh, 02h, 00h, 78h
		db	 00h, 10h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 78h, 00h
		db	 10h, 03h, 00h, 7Dh, 00h, 02h
		db	0FFh,0F1h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh,0FFh, 00h
		db	 00h, 85h, 00h, 28h,0FFh,0F1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh,0FFh, 00h, 00h, 87h
		db	 00h, 28h,0FFh,0F1h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	0FFh, 00h, 00h, 89h, 00h, 28h
		db	0FFh,0F1h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh,0FFh, 00h
		db	 00h, 8Dh, 00h, 26h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 8Dh, 00h, 26h, 02h, 00h, 8Fh
		db	 00h, 28h,0FFh,0F1h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	0FFh, 00h, 00h, 90h, 00h, 09h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 90h, 00h, 09h, 03h
		db	 00h, 91h, 00h, 28h,0FFh,0F1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh,0FFh, 00h, 00h, 93h
		db	 00h, 28h,0FFh,0F1h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	0FFh, 00h, 00h, 93h, 00h, 38h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 93h, 00h, 38h, 02h
		db	 00h, 96h, 00h, 16h,0FFh, 00h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 96h, 00h, 16h, 00h, 00h, 96h
		db	 00h, 18h,0FFh, 01h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 96h, 00h
		db	 18h, 01h, 00h, 98h, 00h, 05h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 98h, 00h, 05h, 04h
		db	 00h, 9Eh, 00h, 18h,0FFh, 73h
		db	 00h, 01h, 20h, 00h, 00h, 00h
		db	 23h, 00h, 08h, 00h, 00h,0A7h
		db	 00h, 2Eh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0A7h, 00h
		db	 2Eh, 03h, 00h,0ACh, 00h, 24h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0ACh, 00h, 24h, 02h
		db	 00h,0B5h, 00h, 12h,0FFh, 73h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 23h, 00h, 04h, 00h, 00h,0B9h
		db	 00h, 1Bh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B9h, 00h
		db	 1Bh, 02h, 00h,0BFh, 00h, 12h
		db	0FFh, 76h, 00h, 00h, 20h, 00h
		db	 00h, 00h, 23h, 00h, 02h, 00h
		db	 00h,0BFh, 00h, 38h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0BFh, 00h, 38h, 02h, 00h,0C3h
		db	 00h, 18h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C3h, 00h
		db	 18h, 04h, 00h,0CEh, 00h, 0Bh
		db	0FFh,0F1h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh,0FFh, 00h
		db	 00h,0CFh, 00h, 1Fh,0FFh, 73h
		db	 00h, 00h, 20h, 00h, 18h, 00h
		db	 23h, 00h, 01h, 00h, 00h,0CFh
		db	 00h, 32h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0CFh, 00h
		db	 32h, 04h, 00h,0D0h, 00h, 09h
		db	0FFh, 73h, 00h, 06h, 20h, 00h
		db	 00h, 00h, 24h, 00h, 80h, 00h
		db	 00h,0D0h, 00h, 0Bh,0FFh,0F1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh,0FFh, 00h, 00h,0D3h
		db	 00h, 10h,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h,0D3h, 00h
		db	 10h, 00h, 00h,0D3h, 00h, 12h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0D3h, 00h, 12h, 01h
		db	 00h,0E0h, 00h, 0Eh,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0E0h, 00h, 0Eh, 04h, 00h,0E2h
		db	 00h, 29h,0FFh, 73h, 00h, 00h
		db	 20h, 00h, 19h, 00h, 24h, 00h
		db	 20h, 00h, 00h,0E2h, 00h

locloop_3:
		cmp	al,0FFh
		rol	byte ptr [bx+si],1	; Rotate
		add	[bx+si],ah
		add	[bp+di],bl
		add	[si],ah
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		;  Fixup - byte match
		db	 00h, 00h,0FFh, 00h,0FFh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h,0FFh
		db	0FFh

zr3_32		endp

seg_a		ends



		end	start
