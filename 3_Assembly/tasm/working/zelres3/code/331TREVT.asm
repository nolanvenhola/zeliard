
PAGE  59,132

;==========================================================================
;
;  TRIGGER_EVENTS - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_31		proc	far

start:
		xchg	sp,ax
		sbb	ax,0
		std				; Set direction flag
;*		fdiv	st,st			; st = st / st(#)
		db	0D8h,0F0h		;  Fixup - byte match
;*		add	bl,ch
		db	 00h,0EBh		;  Fixup - byte match
		xlat				; al=[al+[bx]] table
		stc				; Set carry flag
		xlat				; al=[al+[bx]] table
		sti				; Enable interrupts
		xlat				; al=[al+[bx]] table
		or	bx,ax
		jns	$-26h			; Jump if not sign
		call	trigger_func_1
;*		fld	dword ptr [di]		; Push onto stack
		db	0D9h, 05h		;  Fixup - byte match
		db	0FFh,0FFh,0FFh, 0Ah, 00h, 00h
		db	0EBh,0D7h, 83h,0C4h, 56h,0C9h
		db	0C7h,0CCh, 88h,0C3h, 66h,0CCh
		db	 92h,0C3h, 46h,0C5h, 01h, 18h
		db	 85h,0C3h, 66h, 02h, 18h, 83h
		db	 83h,0C4h, 66h,0C8h,0CCh, 88h
		db	0C3h, 66h,0CCh, 40h,0C2h, 40h
		db	0C2h,0C1h,0C2h, 40h,0C2h, 60h
		db	0C2h,0C1h, 81h,0C3h, 56h,0CAh
		db	 02h, 18h, 83h,0C3h, 56h,0C9h
		db	0C7h, 85h, 83h,0C4h, 76h,0CCh
		db	 88h,0C3h, 56h,0CCh, 93h,0C3h
		db	0C5h, 56h,0D8h, 85h,0C3h, 66h
		db	 01h, 18h, 84h, 83h,0C4h, 66h
		db	0CAh, 01h, 18h, 87h,0C3h, 56h
		db	0C6h, 86h,0C4h, 45h, 8Ah,0C4h
		db	 46h,0CCh, 87h,0C4h, 56h, 01h
		db	 18h, 85h, 83h,0C3h, 66h,0CCh
		db	 89h,0C3h, 46h,0CBh,0C7h, 02h
		db	 18h, 83h,0C3h, 46h, 01h, 18h
		db	 88h,0C3h, 46h, 01h, 18h, 86h
		db	0C4h, 66h, 86h, 83h,0C3h,0CAh
		db	 66h,0D8h, 88h,0C3h, 46h,0C6h
		db	 87h,0C3h,0C5h,0CCh, 8Ah,0C4h
		db	0C7h,0C8h, 02h, 18h, 85h,0C3h
		db	 66h, 01h, 18h, 84h, 83h,0C3h
		db	 76h,0CCh, 88h,0C4h,0C7h,0C8h
		db	 46h, 01h, 18h, 84h,0C3h,0C8h
		db	0C7h,0D8h, 89h,0C3h, 46h,0C6h
		db	 87h,0C3h, 46h,0C9h,0C7h,0C8h
		db	0D9h, 01h, 18h, 82h, 83h,0C3h
		db	 76h,0D8h, 88h,0C3h, 46h,0CCh
		db	 87h,0C4h,0C7h,0CCh, 01h, 18h
		db	 88h,0C3h, 56h, 01h, 18h, 85h
		db	0C3h, 66h, 01h, 18h, 84h, 84h
		db	0C4h, 46h,0C9h,0C7h, 02h, 18h
		db	 86h,0C3h,0C7h,0CCh, 88h,0C3h
		db	 56h, 89h,0C3h, 46h,0C8h,0C6h
		db	 86h,0C4h, 56h,0D8h, 86h, 84h
		db	0C4h, 56h, 8Ah,0C3h, 46h, 88h
		db	0C3h, 46h,0CAh,0D9h,0D8h, 87h
		db	0C3h, 66h,0C6h, 84h,0C3h, 76h
		db	 01h, 18h, 84h, 84h,0C4h, 46h
		db	 03h, 18h, 87h,0C3h, 46h, 01h
		db	 18h, 86h,0C3h, 56h,0CCh, 88h
		db	0C3h, 56h,0C6h,0C8h,0CAh,0D8h
		db	0C3h,0C6h,0CAh,0C8h, 56h,0CAh
		db	0C7h,0D8h, 84h, 84h,0C3h, 66h
		db	 03h, 18h, 85h,0C3h,0C7h,0CCh
		db	 88h,0C3h, 56h,0C8h,0C6h, 02h
		db	 18h, 84h,0C3h, 66h,0C6h,0C8h
		db	 07h, 07h,0C8h, 02h, 18h, 83h
		db	 84h,0C3h, 66h,0CCh, 88h,0C3h
		db	0C7h,0CCh, 88h,0C4h, 56h,0C5h
		db	0D8h, 87h,0C3h,0C5h, 0Bh, 07h
		db	0D8h, 87h, 84h,0C3h, 66h,0CCh
		db	 88h,0C4h, 46h,0C6h,0D8h, 86h
		db	0C3h,0C7h,0CCh,0C7h,0CCh, 88h
		db	0C3h, 56h,0C9h, 46h,0CCh,0C8h
		db	0CCh, 46h,0C8h,0D9h, 01h, 18h
		db	 86h, 84h,0C3h, 46h,0C9h,0C7h
		db	0CCh, 88h,0C3h,0C7h,0C5h,0C7h
		db	 01h, 18h, 85h,0C3h, 56h,0CCh
		db	 88h,0C3h, 66h,0CCh, 47h,0CCh
		db	0C7h,0D9h, 02h, 18h, 88h, 84h
		db	0C3h, 56h,0C6h, 89h,0C4h, 56h
		db	0C6h, 86h,0C3h, 66h, 88h,0C3h
		db	 76h,0CCh, 01h, 18h, 8Dh, 84h
		db	0C3h, 66h,0CCh, 88h,0C4h, 76h
		db	0C6h, 84h,0C4h,0C7h,0C9h,0C8h
		db	0CCh, 88h,0C3h, 66h,0D9h, 01h
		db	 18h, 8Eh, 84h,0C3h,0C7h,0CAh
		db	 46h,0CCh, 88h,0C3h, 56h,0C5h
		db	 46h,0CBh, 02h, 25h, 76h,0D9h
		db	 01h, 18h, 85h,0C3h, 46h,0CCh
		db	 01h, 18h, 90h, 84h,0C3h, 56h
		db	0C8h, 01h, 18h, 87h,0C3h, 76h
		db	0C8h,0C7h,0E6h, 01h, 25h, 66h
		db	 89h,0C4h, 46h,0CCh, 87h,0C4h
		db	0C7h, 89h, 84h,0C3h, 56h,0CCh
		db	 89h,0C3h, 56h,0CCh,0C7h, 4Bh
		db	 83h,0C3h, 56h,0CCh, 01h, 18h
		db	 86h,0C4h, 46h,0CCh, 87h,0C4h
		db	 46h, 01h, 18h, 86h, 84h,0C3h
		db	 66h, 01h, 18h, 87h,0C3h, 46h
		db	0C9h,0C7h, 01h, 18h, 84h,0C4h
		db	 56h,0CCh,0C6h, 87h,0C3h, 56h
		db	 02h, 18h, 84h,0C3h, 46h,0C8h
		db	 02h, 18h, 84h, 84h,0C3h, 46h
		db	0CAh,0C8h, 03h, 18h, 85h,0C3h
		db	 56h, 01h, 18h, 85h,0C4h, 66h
		db	0C8h, 01h, 18h, 85h,0C4h, 46h
		db	0C8h,0D8h, 86h,0C3h, 56h,0CCh
		db	 86h, 84h,0C3h, 56h,0D8h, 89h
		db	0C4h, 56h,0CCh, 86h,0C3h, 46h
		db	0CAh, 4Bh, 87h,0C3h, 46h, 02h
		db	 18h, 85h,0C3h,0C5h, 46h,0CCh
		db	 86h, 84h,0C3h, 46h,0C8h,0D8h
		db	 89h,0C3h, 56h,0CCh, 86h,0C3h
		db	 56h,0CCh, 88h,0C3h, 46h,0C6h
		db	 87h,0C3h, 56h,0C8h, 01h, 18h
		db	 84h, 84h,0C3h, 56h,0C6h, 89h
		db	0C3h, 56h,0D9h,0D8h, 85h,0C3h
		db	 56h,0CCh, 88h,0C3h, 46h,0C8h
		db	 01h, 18h, 85h,0C4h, 56h,0CCh
		db	 86h, 84h,0C3h, 56h,0C8h, 01h
		db	 18h, 87h,0C3h, 56h,0CCh, 01h
		db	 18h, 84h,0C4h, 56h, 01h, 18h
		db	 87h,0C3h, 56h,0D8h, 86h,0C3h
		db	 66h, 02h, 18h, 83h, 84h,0C3h
		db	 56h,0C6h, 89h,0C4h, 46h,0C8h
		db	0CCh, 86h,0C3h, 56h,0C6h, 88h
		db	0C3h, 46h,0CCh, 87h,0C3h, 66h
		db	0CCh, 85h, 84h,0C3h, 56h,0C8h
		db	 01h, 18h, 87h,0C4h, 56h,0CCh
		db	 86h,0C4h, 56h, 01h, 19h, 01h
		db	 18h, 85h,0C3h, 46h,0CCh, 87h
		db	0C3h, 76h,0D8h, 84h, 84h,0C3h
		db	0C7h,0C9h,0C7h,0CCh, 89h,0C3h
		db	 56h,0C8h,0D9h,0D8h, 84h,0C3h
		db	 46h,0C9h,0CCh, 88h,0C3h
		db	46h

zr3_31		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

trigger_func_1		proc	near
		retf	86D8h
trigger_func_1		endp

			                        ;* No entry point to code
		retn
		db	 66h,0C8h,0C7h, 01h, 18h, 82h
		db	 84h,0C3h, 56h,0CCh, 89h,0C3h
		db	 56h,0CCh, 86h,0C3h, 56h,0CCh
		db	 88h,0C3h, 46h,0C6h, 87h,0C3h
		db	 66h, 02h, 18h, 83h, 84h,0C3h
		db	 56h,0CCh, 89h,0C3h, 56h,0CCh
		db	 86h,0C3h, 56h,0CCh, 88h,0C3h
		db	 56h, 01h, 18h, 85h,0C3h, 56h
		db	0C8h,0D8h, 85h, 84h,0C3h, 56h
		db	0C6h, 01h, 18h, 87h,0C3h, 46h
		db	0CAh, 01h, 18h, 85h,0C3h, 56h
		db	0C6h, 88h,0C3h,0C7h,0C8h, 03h
		db	 18h, 84h,0C3h,0C7h,0CAh,0C7h
		db	0CCh, 86h, 84h,0C3h, 66h,0C6h
		db	 88h,0C4h, 56h,0CCh, 86h,0C3h
		db	 56h,0C5h,0D8h, 87h,0C3h, 46h
		db	 01h, 18h, 86h,0C3h, 56h,0CCh
		db	 86h, 84h,0C3h, 66h,0C8h, 02h
		db	 18h, 85h,0C4h, 56h,0CCh, 01h
		db	 18h, 84h,0C3h, 56h,0CCh, 88h
		db	0C3h, 46h,0CCh, 87h,0C3h, 56h
		db	0CCh, 86h, 84h,0C3h, 46h,0CAh
		db	0C7h, 01h, 18h, 87h,0C3h,0CAh
		db	0C7h,0C8h,0CCh, 86h,0C3h, 56h
		db	0C6h, 02h, 18h, 85h,0C3h,0C7h
		db	0CAh,0CCh, 87h,0C4h, 56h,0C6h
		db	 86h, 84h,0C3h, 66h,0CCh, 88h
		db	0C4h, 56h,0CCh, 86h,0C3h, 56h
		db	0CCh, 88h,0C4h, 46h,0C6h, 87h
		db	0C3h, 66h,0C8h, 01h, 18h, 83h
		db	 84h,0C3h, 66h,0CCh, 88h,0C4h
		db	 56h, 01h, 18h, 85h,0C3h,0C7h
		db	0CAh,0C8h,0CCh, 88h,0C4h, 46h
		db	0C8h, 01h, 18h, 85h,0C3h, 66h
		db	0CCh, 85h, 84h,0C3h, 66h,0CCh
		db	 88h,0C3h, 56h,0C6h, 86h,0C3h
		db	 56h,0CCh, 01h, 18h, 86h,0C3h
		db	0C7h, 04h, 18h, 84h,0C4h, 46h
		db	0C8h, 03h, 18h, 83h, 84h,0C3h
		db	 56h,0C8h, 02h, 18h, 86h,0C3h
		db	 56h,0C8h,0D9h,0D8h, 84h,0C3h
		db	 56h,0C5h,0D8h, 87h,0C3h,0CAh
		db	 89h,0C3h, 66h, 01h, 18h, 84h
		db	 84h,0C3h, 66h,0CCh, 88h,0C4h
		db	 56h,0CCh, 86h,0C3h, 46h,0C9h
		db	0CCh, 88h,0C3h,0C7h, 89h,0C3h
		db	 56h,0C8h,0D8h, 85h, 84h,0C3h
		db	 66h,0CCh, 88h,0C3h,0C7h,0C9h
		db	0C7h,0CCh, 86h,0C4h, 46h,0C6h
		db	0CCh, 88h,0C3h, 01h, 18h, 88h
		db	0C3h, 56h,0C6h, 86h, 84h,0C3h
		db	 56h,0C8h, 01h, 18h, 87h,0C3h
		db	 56h,0CCh, 86h,0C4h, 56h,0D9h
		db	0D8h, 87h,0C4h,0D8h, 89h,0C3h
		db	0C5h, 46h,0C6h, 86h, 84h,0C3h
		db	 56h,0CCh, 89h,0C3h, 56h,0CCh
		db	 86h,0C3h, 56h,0CCh, 93h,0C3h
		db	 66h,0D8h, 85h, 84h,0C3h,0C7h
		db	0C9h,0C7h,0CCh, 89h,0C3h, 56h
		db	0D9h,0D8h, 85h,0C3h, 46h,0C9h
		db	0C7h, 50h,0C2h, 50h,0C2h,0C1h
		db	0C2h, 60h,0C2h, 50h, 81h,0C3h
		db	 56h,0CAh, 02h, 18h, 83h, 84h
		db	0C3h, 56h,0C8h,0D8h, 88h,0C3h
		db	 46h,0C6h, 87h,0C3h, 56h,0D9h
		db	 01h, 18h, 91h,0C4h, 66h,0CCh
		db	 85h, 84h,0C3h, 56h, 02h, 18h
		db	 87h,0C3h, 46h,0D9h,0D8h, 86h
		db	0C3h,0CAh,0C7h,0C6h,0CCh, 93h
		db	0C3h, 66h,0C6h, 85h, 84h,0C3h
		db	 46h,0C8h,0CCh, 89h,0C3h,0C5h
		db	 46h,0C6h, 86h,0C3h, 46h, 4Bh
		db	 93h,0C3h, 76h, 01h, 18h, 83h
		db	 84h,0C3h, 56h,0CCh, 89h,0C3h
		db	 46h, 01h, 18h, 86h,0C3h, 66h
		db	 01h, 18h, 91h,0C4h, 66h,0C8h
		db	 02h, 18h, 82h, 84h,0C3h, 46h
		db	0C9h,0CCh, 89h,0C3h, 56h,0CCh
		db	 86h,0C4h, 76h,0C5h,0C8h, 02h
		db	 23h,0C7h,0C5h, 56h,0C8h,0E6h
		db	 01h, 25h, 07h, 07h,0CBh,0CCh
		db	 85h, 84h,0C3h, 56h,0CCh, 89h
		db	0C4h, 46h, 4Bh,0D8h, 85h,0C4h
		db	 56h,0C8h, 56h,0E3h,0E4h,0E3h
		db	0C8h, 46h,0C5h, 46h, 01h, 25h
		db	0E6h,0C7h,0C8h, 05h, 07h,0CAh
		db	0CCh, 85h, 84h,0C3h, 56h, 01h
		db	 18h, 88h,0C3h, 46h,0CCh,0C7h
		db	 86h,0C3h, 66h, 01h, 18h, 8Dh
		db	0C4h,0C7h,0CBh, 05h, 07h,0CCh
		db	 85h, 84h,0C3h,0C7h,0C8h, 03h
		db	 18h, 87h,0C3h, 46h,0C8h, 4Bh
		db	 85h,0C3h,0C7h,0C5h, 46h,0D8h
		db	 8Eh,0C3h, 66h,0C5h, 46h,0C8h
		db	0C7h, 01h, 18h, 83h, 84h,0C3h
		db	0C7h,0CCh, 8Bh,0C3h,0C7h,0CCh
		db	0C7h, 87h,0C3h, 56h,0CCh, 8Fh
		db	0C4h, 06h, 07h,0C6h, 86h, 84h
		db	0C3h,0C7h,0CCh, 8Bh,0C3h,0C7h
		db	0C5h,0D9h, 01h, 18h, 85h,0C4h
		db	 56h,0CCh, 50h, 41h, 40h,0C2h
		db	 50h,0C2h, 40h, 81h,0C3h,0C7h
		db	0C5h, 05h, 07h,0C8h, 02h, 18h
		db	 82h, 84h,0C3h,0C7h,0CCh, 8Bh
		db	0C3h, 46h,0CCh, 87h,0C4h, 46h
		db	0C5h,0CCh,0D8h, 8Eh,0C3h, 05h
		db	 07h,0C9h,0C7h, 01h, 18h, 84h
		db	 84h,0C3h, 46h, 01h, 18h, 89h
		db	0C3h,0C7h,0C9h, 02h, 18h, 85h
		db	0C3h, 46h, 01h, 18h, 85h,0C4h
		db	0C7h, 88h,0C3h, 06h, 07h,0CCh
		db	 86h, 84h,0C3h,0C8h, 03h, 18h
		db	 88h,0C3h, 46h,0CCh, 87h,0C4h
		db	 56h,0C8h,0D9h,0D8h, 83h,0C3h
		db	0C7h, 01h, 18h, 86h,0C3h, 06h
		db	 07h,0CCh, 86h, 84h,0C3h,0CCh
		db	 8Ch,0C4h,0C7h,0C8h,0CCh, 87h
		db	0C3h, 56h,0CCh, 85h,0C4h, 46h
		db	 87h,0C3h, 66h,0C9h, 46h, 02h
		db	 18h, 84h, 84h,0C3h,0C7h,0D8h
		db	 8Bh,0C4h,0C7h, 89h,0C3h, 66h
		db	0D8h, 84h,0C3h, 46h, 01h, 18h
		db	 85h,0C4h,0C7h,0C8h, 05h, 07h
		db	0C6h, 85h, 84h,0C3h,0CCh, 8Ch
		db	0C3h,0C8h,0CCh,0D9h,0D8h, 86h
		db	0C4h, 46h,0C8h,0CCh, 85h,0C3h
		db	0C7h,0C5h,0C7h, 01h, 18h, 84h
		db	0C4h,0CCh,0C7h,0CCh, 66h,0CAh
		db	0C7h, 02h, 18h, 82h, 84h,0C3h
		db	0C7h, 01h, 18h, 8Ah,0C4h,0CCh
		db	 89h,0C3h,0C7h,0CAh,0C7h,0CCh
		db	 85h,0C3h, 56h, 8Bh,0C3h, 56h
		db	 86h, 84h,0C3h,0C7h,0CCh, 96h
		db	0C4h, 46h,0CCh, 86h,0C3h, 46h
		db	0C8h,0C7h, 8Ah,0C3h, 46h,0CBh
		db	0C6h, 85h, 84h,0C3h,0C8h,0C7h
		db	 40h,0C2h, 60h,0C2h,0C1h,0C2h
		db	 05h, 01h,0C2h,0C1h,0C2h, 40h
		db	 81h,0C4h, 46h,0CAh,0CCh, 85h
		db	0C3h, 56h,0C8h, 8Ah,0C3h, 56h
		db	0C8h,0D8h, 84h, 84h,0C3h,0C7h
		db	0D8h, 96h,0C3h, 66h, 85h,0C3h
		db	0C7h,0C9h, 46h,0CCh, 89h,0C3h
		db	 56h,0C6h, 85h, 84h,0C3h,0CCh
		db	 88h,0C4h,0C6h,0D8h, 87h,0C4h
		db	0C6h, 83h,0C3h,0ECh, 46h,0C8h
		db	0D8h, 84h,0C4h, 66h,0CCh, 89h
		db	0C3h, 66h, 01h, 18h, 83h, 84h
		db	0C3h,0CCh, 01h, 18h, 86h,0C4h
		db	0C6h, 88h,0C3h,0C7h,0ECh, 82h
		db	 01h, 2Ch, 46h,0CCh, 85h,0C3h
		db	 56h,0C8h,0C7h, 89h,0C3h, 46h
		db	0CAh,0C6h, 85h, 84h,0C3h,0D8h
		db	 88h,0C3h,0C8h,0C6h, 87h,0C3h
		db	 01h, 2Ch, 82h,0ECh, 56h, 86h
		db	0C4h, 66h,0C6h,0CCh, 88h,0C3h
		db	 66h,0C6h, 84h, 84h,0C3h, 01h
		db	 18h, 87h,0C3h,0C7h,0C8h, 01h
		db	 18h, 85h,0C3h,0ECh, 05h, 07h
		db	0C9h,0CCh, 87h,0C3h, 46h,0C8h
		db	 89h,0C3h,0C9h,0C7h,0CBh,0C8h
		db	 01h, 18h, 83h, 84h,0C3h, 89h
		db	0C3h,0CAh,0C7h,0C6h, 86h,0C3h
		db	 01h, 2Ch,0CAh,0C7h,0ECh, 56h
		db	0CCh, 87h,0C4h, 56h,0CCh, 88h
		db	0C3h, 56h, 01h, 18h, 84h, 8Eh
		db	0C3h, 56h,0D8h, 85h,0C3h, 07h
		db	 07h,0C8h, 01h, 18h, 85h,0C3h
		db	0C7h,0CAh, 46h, 87h,0C4h, 56h
		db	0CCh, 86h,0C2h, 70h,0C2h, 40h
		db	0C2h, 40h, 82h,0C3h,0C7h,0CAh
		db	 02h, 18h, 84h,0C3h, 76h,0C9h
		db	 5Bh, 87h,0C4h, 56h,0C8h, 01h
		db	 18h, 85h,0C4h, 46h,0C8h,0C7h
		db	 40h,0C2h, 40h,0C2h, 8Eh,0C3h
		db	 46h,0CCh, 86h,0C3h, 07h, 07h
		db	 8Ah,0C3h, 46h,0C6h, 86h,0C4h
		db	 46h, 01h, 18h, 86h,0C7h, 45h
		db	 02h, 18h, 88h,0C3h,0C7h,0ECh
		db	0C6h, 86h,0C3h, 05h, 07h,0C8h
		db	 03h, 18h, 87h,0C3h, 56h, 01h
		db	 18h, 84h,0C3h, 56h,0C6h, 85h
		db	0C4h, 46h,0C8h, 56h, 01h, 18h
		db	 86h,0C4h,0ECh,0C7h,0C8h, 01h
		db	 18h, 84h,0C3h, 05h, 07h, 01h
		db	 18h, 8Ah,0C3h
		db	0C7h,0CAh,0C7h,0C6h, 85h,0C3h
		db	 46h,0C9h,0C7h, 01h, 18h, 83h
		db	0C3h, 66h,0CAh, 01h, 18h, 87h
		db	0EBh,0ECh,0C7h,0CCh, 86h,0C3h
		db	 66h,0CCh, 8Dh,0C4h, 56h,0C8h
		db	 01h, 18h, 83h,0C3h, 56h,0CCh
		db	 85h,0C3h, 76h,0CCh, 88h,0EBh
		db	0ECh, 88h,0C4h, 66h,0CAh, 02h
		db	 18h, 8Ah,0C4h, 66h, 85h,0C4h
		db	 56h,0CCh, 85h,0C4h,0C7h,0CAh
		db	 46h, 02h, 18h, 87h,0EBh,0ECh
		db	 88h,0C4h, 76h,0CCh, 8Eh,0C3h
		db	0CCh, 86h,0C3h,0C7h,0C8h, 02h
		db	 18h, 84h,0C4h, 56h,0C6h,0CCh
		db	 89h,0EBh,0ECh, 88h,0C3h, 76h
		db	0CCh, 8Eh,0C3h,0CCh, 86h,0C3h
		db	 46h,0CBh, 02h, 18h, 83h,0C3h
		db	 56h,0C8h, 02h, 18h, 91h,0C3h
		db	 66h,0C6h, 8Fh,0C3h,0D8h, 86h
		db	0C3h, 56h,0CCh, 85h,0C3h, 56h
		db	0CCh, 94h,0C3h,0C7h,0CAh, 56h
		db	0CCh, 8Eh,0C4h, 87h,0C3h, 56h
		db	0CCh, 85h,0C3h, 56h, 02h, 18h
		db	 88h,0EBh,0ECh, 88h,0C3h, 66h
		db	0C8h,0CCh, 96h,0C3h, 66h, 85h
		db	0C3h, 66h,0CCh, 89h,0EBh,0ECh
		db	 88h,0C3h, 66h,0CCh, 88h,0C4h
		db	0C6h, 8Dh,0C3h, 46h,0C8h, 01h
		db	 18h, 84h,0C3h, 56h,0C8h, 01h
		db	 18h, 88h,0EBh,0ECh, 88h,0C3h
		db	0C5h, 56h,0CCh, 88h,0C3h,0C6h
		db	 8Dh,0C3h, 46h,0CCh, 86h,0C4h
		db	 66h,0CCh, 89h,0EBh,0ECh, 88h
		db	0C3h, 56h,0C6h, 89h,0C3h,0C7h
		db	 01h, 18h, 8Bh,0C4h, 46h, 01h
		db	 18h, 85h
loc_1:
		les	dx,dword ptr [bp-3Ah]	; Load seg:offset ptr
		int	3			; Debug breakpoint
		xchg	bx,ax
		retn
		db	 66h, 03h, 18h, 85h,0C3h,0C7h
		db	0C8h, 02h, 18h, 89h,0C3h, 56h
		db	0CCh, 85h,0C3h, 46h,0C9h,0C7h
		db	0CCh, 93h,0C3h, 56h,0C8h, 02h
		db	 18h, 86h,0C3h,0C7h,0CCh, 8Ch
		db	0C3h,0C7h,0CAh,0C7h,0CCh, 85h
		db	0C4h, 56h,0CCh, 8Ah,0EBh,0C5h
		db	 88h,0C3h, 76h,0CCh, 87h,0C4h
		db	 46h, 01h, 18h, 8Ah,0C3h, 56h
		db	0D8h, 85h,0C3h, 66h,0D8h, 89h
		db	0EBh,0C7h,0D8h, 87h,0C4h, 56h
		db	0CAh,0C7h,0CCh, 87h,0C3h,0C7h
		db	0CCh, 8Ch,0C3h, 56h,0C8h, 01h
		db	 18h, 83h,0C3h, 56h,0C6h, 02h
		db	 18h, 87h,0EBh,0ECh,0C7h,0C6h
		db	 86h,0C4h, 76h,0CCh, 87h,0C3h
		db	0C7h, 02h, 18h, 8Ah,0C4h, 46h
		db	0CBh, 01h, 18h, 84h,0C3h, 66h
		db	 01h, 18h, 88h,0EBh,0ECh,0C7h
		db	0C8h, 01h, 18h, 84h,0C3h, 66h
		db	0C6h, 88h,0C4h, 46h,0CAh, 01h
		db	 18h, 89h,0C4h, 46h,0CCh, 86h
		db	0C3h, 66h,0CCh, 89h,0EBh,0ECh
		db	0CAh,0CCh, 86h,0C3h, 66h, 02h
		db	 18h, 86h,0C4h, 46h,0CCh, 8Bh
		db	0C3h, 46h,0CCh, 86h,0C3h, 56h
		db	0CAh,0CCh, 89h,0EBh,0ECh,0C7h
		db	 01h, 18h, 85h,0C4h,0C7h,0C9h
		db	 46h,0C8h, 02h, 18h, 85h,0C3h
		db	0C7h,0CCh, 8Ch,0C3h, 46h,0CCh
		db	 86h,0C3h, 66h,0C6h,0D8h, 88h
		db	0C3h,0ECh,0C6h, 87h,0C3h, 76h
		db	0CCh, 87h,0C3h,0C7h,0C8h,0CCh
		db	 8Bh,0C3h,0C7h,0C6h, 87h,0C3h
		db	0C7h,0C5h, 56h, 02h, 18h, 81h
		db	0EDh, 84h,0C3h,0ECh,0C7h, 87h
		db	0C3h, 56h,0CCh, 89h,0C3h, 46h
		db	0CCh, 8Bh,0C3h,0C7h,0CBh,0CCh
		db	 86h,0C3h, 66h,0C6h, 02h, 18h
		db	 81h,0EEh, 84h,0C4h,0ECh,0CBh
		db	0C6h, 86h,0C3h, 76h,0CCh, 87h
		db	0C3h,0C7h,0C6h, 8Ch,0C4h,0C7h
		db	0CAh,0C7h,0D8h, 85h,0C4h, 76h
		db	0CCh, 83h,0EFh, 84h,0C4h, 46h
		db	0CAh, 02h, 18h, 83h,0C3h, 56h
		db	0C9h,0C7h,0CCh, 87h,0C3h,0C7h
		db	0CAh, 02h, 18h, 89h,0C4h, 46h
		db	0C8h, 01h, 18h, 84h,0C3h, 76h
		db	0D8h, 83h,0E7h, 84h,0C4h,0C7h
		db	0ECh,0C7h, 01h, 18h, 84h,0C3h
		db	 76h,0CCh, 87h,0C3h,0C7h, 02h
		db	 18h, 8Ah,0C3h, 46h, 01h, 18h
		db	 85h,0C3h, 66h,0CAh,0CCh, 83h
		db	0E8h, 84h,0C3h,0ECh,0C7h,0C6h
		db	 86h,0C3h,0C5h, 56h,0C8h, 02h
		db	 18h, 85h,0C3h,0C7h,0CCh, 8Ch
		db	0C3h,0C7h,0CCh, 87h,0C3h,0C5h
		db	 66h,0CCh, 88h,0C3h,0C7h,0C8h
		db	0C7h,0D8h, 85h,0C3h, 66h, 01h
		db	 18h, 87h,0C4h,0C7h,0CCh, 8Ch
		db	0C3h,0C7h,0CCh, 87h,0C3h, 56h
		db	0C8h,0C7h, 02h, 18h, 86h,0C3h
		db	0ECh,0C7h, 02h, 18h, 84h,0C3h
		db	 66h,0CCh, 88h,0C4h, 46h,0C6h
		db	 8Bh,0C3h,0C7h,0CBh, 02h, 18h
		db	 84h,0C4h,0C7h,0C5h, 46h, 02h
		db	 18h, 87h,0C3h,0ECh,0C6h, 87h
		db	0C3h, 76h, 03h, 18h, 84h,0C3h
		db	 46h,0C8h, 01h, 18h, 89h,0C3h
		db	0C7h,0C8h, 01h, 18h, 85h,0C3h
		db	 66h,0C5h,0C7h, 88h,0C3h,0C7h
		db	0C9h, 4Bh, 85h,0C3h,0C7h,0ECh
		db	0C7h,0CAh, 02h, 18h, 86h,0C3h
		db	0C7h,0CAh,0D8h, 8Bh,0C3h,0C7h
		db	0CCh, 87h,0C4h, 76h,0CCh, 88h
		db	0C3h,0C7h,0C8h,0CBh, 86h,0C4h
		db	0C7h,0ECh, 46h,0CCh, 88h,0C3h
		db	 46h,0CCh, 8Bh,0C4h,0C9h,0CCh
		db	 87h,0C4h, 76h, 03h, 18h, 85h
		db	0C3h, 46h,0CCh, 86h,0C3h,0C7h
		db	0ECh, 46h,0CCh, 88h,0C3h,0C7h
		db	0D8h, 8Ch,0C3h,0C7h,0CCh, 01h
		db	 18h, 85h,0C3h, 66h,0CAh, 02h
		db	 18h, 86h,0C4h,0C7h,0CCh, 87h
		db	0C3h, 46h,0ECh,0C7h, 01h, 18h
		db	 87h,0C3h,0C7h,0CCh, 8Ch,0C4h
		db	0C7h,0CCh, 87h,0C3h, 05h, 07h
		db	0CCh, 91h,0C3h, 46h,0ECh,0C7h
		db	0C8h, 02h, 18h, 85h,0C3h,0D8h
		db	 8Dh,0C4h,0C7h,0CCh, 87h,0C3h
		db	 06h, 07h, 60h, 41h, 50h,0C2h
		db	 60h,0C2h,0C1h, 81h,0C3h, 76h
		db	0CCh, 87h,0C4h,0CCh, 8Dh,0C3h
		db	0C8h,0C7h, 01h, 18h, 85h,0C3h
		db	 05h, 07h,0CCh, 91h,0C3h, 56h
		db	0C8h, 01h, 18h, 8Fh,0C4h, 86h
		db	0C3h,0C7h, 03h, 18h, 84h,0C3h
		db	 05h, 07h, 02h, 18h, 88h,0C4h
		db	0C7h,0D8h, 84h,0C3h, 76h, 40h
		db	0C2h,0C1h,0C2h, 40h, 41h, 40h
		db	0C2h, 40h, 82h,0C4h, 86h,0C3h
		db	0CCh, 88h,0C4h, 76h,0C8h, 01h
		db	 18h, 89h,0C3h,0C7h, 01h, 18h
		db	 83h,0C3h,0C7h,0ECh, 56h,0C8h
		db	 01h, 18h, 8Dh,0C3h, 86h,0C3h
		db	0CCh, 88h,0C3h, 05h, 07h,0CCh
		db	 8Ah,0C3h,0C7h,0C6h, 83h,0C4h
		db	0C7h,0C5h, 76h,0D8h,0CBh,0C7h
		db	 01h, 18h, 89h,0C4h,0C7h,0CCh
		db	 85h,0C4h, 01h, 18h, 87h,0C3h
		db	 05h, 07h,0CCh, 8Ah,0C3h,0C7h
		db	0C8h,0C7h,0D8h, 81h,0C3h, 0Ah
		db	 07h,0C8h,0C7h, 01h, 18h, 86h
		db	0C4h,0C7h,0CCh, 85h,0C4h, 89h
		db	0C3h, 05h, 07h,0CCh, 8Ah,0C4h
		db	 09h, 07h,0C9h,0C7h,0C8h, 46h
		db	0CCh,0C8h, 46h,0D8h, 87h,0C3h
		db	0C7h,0C8h,0D8h, 8Eh,0C4h,0C7h
		db	0C5h, 76h, 03h, 18h, 86h,0C4h
		db	 09h, 07h,0CCh, 82h,0C4h,0CCh
		db	0C8h,0D8h, 46h,0C8h, 01h, 18h
		db	 85h,0C3h,0C7h,0CCh, 8Fh,0C3h
		db	 76h,0C8h,0C7h, 02h, 18h, 87h
		db	0C3h, 07h, 07h,0C8h, 01h, 18h
		db	 86h,0C4h, 56h, 86h,0C3h, 46h
		db	 03h, 18h, 8Bh,0C4h,0C5h, 76h
		db	 01h, 18h, 89h,0C3h, 05h, 07h
		db	0C8h,0C7h,0CBh, 02h, 18h, 86h
		db	0C3h, 46h,0D8h, 85h,0C4h,0C7h
		db	0C8h, 02h, 18h, 8Ch,0C3h, 05h
		db	 07h,0CCh, 8Ah,0C3h, 56h,0C5h
		db	0C7h,0CCh, 81h,0C3h,0CCh, 89h
		db	0C3h,0C6h, 46h, 01h, 18h, 83h
		db	0C3h, 46h,0CCh, 8Eh,0C4h, 76h
		db	0C6h,0C8h, 02h, 18h, 87h,0C3h
		db	 56h, 02h, 18h, 8Dh,0C3h,0C7h
		db	0C6h,0C8h, 01h, 18h, 82h,0C3h
		db	0C7h, 01h, 18h, 88h,0C4h, 45h
		db	 02h, 23h,0C7h,0CCh, 46h,0CCh
		db	 56h, 01h, 18h, 87h,0E1h, 66h
		db	 50h,0C2h, 40h,0C2h, 40h,0C2h
		db	0C1h,0C2h, 50h, 81h,0C3h, 46h
		db	0C8h, 05h, 07h,0CCh, 89h,0C3h
		db	 46h, 02h, 23h,0C7h, 82h,0C4h
		db	 66h,0CCh, 87h,0E1h,0C7h,0C8h
		db	0CCh,0CAh,0C7h,0D8h, 8Fh,0C4h
		db	0CCh,0C8h, 05h, 07h,0C8h,0C7h
		db	 02h, 18h, 85h,0C3h,0C7h,0C9h
		db	0C7h,0EAh,0E9h,0D9h,0D8h, 82h
		db	0C3h, 46h,0CAh, 02h, 18h, 85h
		db	0E1h, 76h,0CCh, 87h,0DAh,0DEh
		db	0C6h, 87h,0C3h, 46h,0C9h, 56h
		db	0CAh,0C7h,0CCh, 85h,0C4h, 45h
		db	 56h,0CCh, 84h, 82h,0C3h, 46h
		db	 01h, 18h, 86h,0E1h,0C7h,0C5h
		db	 66h,0CCh, 87h,0DBh,0DFh, 46h
		db	 01h, 18h, 84h,0C4h, 09h, 07h
		db	0D8h, 81h,0C4h,0C6h,0C7h,0C8h
		db	 56h,0CCh, 85h, 82h,0C3h, 46h
		db	0CCh, 87h,0C4h, 05h, 07h,0CCh
		db	 87h,0DBh,0DFh, 46h,0CCh, 87h
		db	0C3h, 06h, 07h,0CCh,0C6h, 81h
		db	0C4h,0C8h, 66h,0C8h, 02h, 18h
		db	 83h, 82h,0C3h, 46h,0CCh, 87h
		db	0C4h, 06h, 07h, 01h, 18h, 85h
		db	0DBh,0DFh,0C7h,0C8h,0CCh, 01h
		db	 18h, 85h,0C4h, 06h, 07h,0CAh
		db	 09h, 07h,0C6h, 84h, 82h,0C3h
		db	 46h, 02h, 18h, 85h,0C3h, 76h
		db	0CAh, 01h, 18h, 86h,0DBh,0DFh
		db	 46h,0CCh, 88h,0C4h, 46h,0C9h
		db	 07h, 07h,0CCh, 05h, 07h,0C6h
		db	 83h, 82h,0C3h, 46h,0CCh, 02h
		db	 18h, 84h,0C3h, 05h, 07h,0CCh
		db	 87h,0DDh,0E0h, 56h,0CCh, 88h
		db	0DBh,0DFh, 06h, 07h, 01h, 18h
		db	 82h,0C4h, 56h,0C9h,0CCh, 01h
		db	 18h, 81h, 82h,0C3h, 66h,0CCh
		db	 85h,0C3h, 06h, 07h, 02h, 18h
		db	 85h,0DBh,0DFh, 46h,0C8h, 01h
		db	 19h,0D8h, 85h,0DCh,0DFh, 66h
		db	0CAh,0C5h, 02h, 18h, 83h,0C4h
		db	 56h,0CCh, 83h, 82h,0C4h, 56h
		db	0CCh, 86h,0C3h, 76h,0CAh,0C7h
		db	 01h, 18h, 86h,0DBh,0DFh, 66h
		db	0D8h, 86h,0DDh,0E0h,0C7h,0C9h
		db	 46h,0CCh, 88h,0C3h,0C7h,0C8h
		db	0CCh, 01h, 18h, 81h, 82h,0C3h
		db	0C7h,0C8h, 02h, 18h, 85h,0C4h
		db	 05h, 07h,0CCh, 88h,0DBh,0DFh
		db	0C9h, 46h,0CAh,0C7h, 01h, 18h
		db	 85h,0DBh,0DFh, 76h,0D8h, 86h
		db	0C3h, 46h, 01h, 18h, 82h, 82h
		db	0C3h, 46h, 01h, 18h, 86h,0C3h
		db	 06h, 07h,0CCh, 87h,0DDh,0E0h
		db	 66h,0CCh, 02h, 18h, 84h,0DCh
		db	0DFh, 66h,0C8h,0C7h, 01h, 18h
		db	 84h,0C3h,0C7h,0CCh, 84h, 82h
		db	0C3h,0C7h,0CCh, 83h,0EDh, 84h
		db	0C3h, 06h, 07h,0CCh, 88h,0DBh
		db	 66h,0CCh, 87h,0DBh,0E0h, 76h
		db	0CCh, 86h,0C4h,0C7h,0CCh, 84h
		db	 82h,0C3h, 46h, 01h, 18h, 81h
		db	0EEh, 84h,0C3h, 46h,0C9h, 66h
		db	 02h, 18h, 86h,0DBh, 66h,0D9h
		db	0D8h, 86h,0DBh,0DEh, 66h,0CCh
		db	 87h,0C4h,0C7h, 01h, 18h, 83h
		db	 82h,0C3h, 46h,0CCh, 82h,0EFh
		db	 84h,0C4h, 76h,0C8h,0C7h,0CCh
		db	 88h,0DBh,0E0h, 56h,0C8h, 02h
		db	 18h, 84h,0DBh,0DFh,0C7h,0C9h
		db	 46h,0CCh, 87h,0C3h,0C7h, 85h
		db	 82h,0C3h, 46h,0C8h,0CCh, 81h
		db	0E7h, 84h,0C4h, 06h, 07h, 89h
		db	0DBh,0DEh, 76h,0D8h, 85h,0DBh
		db	0DFh, 66h,0CAh,0D8h, 86h,0C3h
		db	0C7h,0CCh, 84h, 82h,0C3h, 56h
		db	 01h, 18h,0E8h, 84h,0C3h, 07h
		db	 07h, 88h,0DBh,0DFh, 66h,0CCh
		db	 86h,0DBh,0DFh, 76h,0C8h, 01h
		db	 18h, 84h,0C3h,0C7h,0CAh,0C7h
		db	 01h, 18h, 81h, 82h,0C3h, 56h
		db	0CCh, 86h,0C3h, 07h, 07h, 03h
		db	 18h, 84h,0DBh,0DFh, 56h,0CAh
		db	0CCh, 86h,0DBh,0DFh, 66h,0CCh
		db	 87h,0C3h,0C7h,0CCh,0D8h, 83h
		db	 82h,0C3h, 46h, 03h, 18h, 84h
		db	0C3h,0CAh, 76h,0C8h, 02h, 18h
		db	 86h,0DBh,0DFh, 66h,0CCh, 86h
		db	0DBh,0DFh, 66h,0CCh, 87h,0C3h
		db	0C7h, 01h, 18h, 83h, 82h,0C3h
		db	 46h, 02h, 18h, 85h,0C3h, 05h
		db	 07h,0CCh, 89h,0DBh,0DFh,0C9h
		db	 56h,0CCh, 86h,0DBh,0DFh,0C9h
		db	 56h,0CAh,0C7h, 01h, 18h, 84h
		db	0C3h,0C7h,0CCh, 84h, 82h,0C3h
		db	 56h,0D8h, 86h,0C3h, 66h,0C9h
		db	0C7h,0CCh, 89h,0DBh,0DFh, 56h
		db	0CCh, 87h,0DBh,0DFh, 66h, 01h
		db	 18h, 86h,0C3h, 46h,0CCh, 83h
		db	 82h,0C3h, 46h,0CCh, 87h,0C4h
		db	 05h, 07h,0CCh, 89h,0DBh,0DFh
		db	 46h,0ECh,0C7h,0D9h,0D8h, 85h
		db	0DBh,0DFh, 66h,0CCh, 87h,0C4h
		db	0C7h,0CAh, 01h, 18h, 82h, 82h
		db	0C3h,0C7h,0CAh, 02h, 18h, 85h
		db	0C3h, 05h, 07h, 01h, 18h, 88h
		db	0DBh,0DFh, 46h,0ECh,0C7h,0C8h
		db	 01h, 18h, 84h,0DBh,0DFh, 66h
		db	0C8h, 02h, 18h, 84h,0C4h, 46h
		db	0CCh, 83h, 82h,0C3h, 46h, 01h
		db	 18h, 86h,0C3h,0C8h,0CCh, 56h
		db	0C8h,0C7h, 02h, 18h, 86h,0DBh
		db	0E0h, 46h,0ECh,0C7h,0CCh, 86h
		db	0DBh,0DFh, 76h,0C5h,0D8h, 85h
		db	0C3h,0C7h,0CCh, 84h, 82h,0C3h
		db	 46h,0D8h, 87h,0C4h,0CCh, 82h
		db	0C3h, 46h,0D8h, 89h,0DBh,0DEh
		db	 46h,0ECh,0CCh, 87h,0DBh,0E0h
		db	 76h,0CCh, 86h,0C3h,0CCh,0C7h
		db	0CCh, 83h, 82h,0C4h, 56h, 01h
		db	 18h, 8Ah,0C3h,0C7h,0CCh, 89h
		db	0DBh,0DFh,0C9h,0C7h,0ECh, 02h
		db	 18h, 85h,0DBh,0DEh, 05h, 07h
		db	 01h, 18h, 84h,0C3h, 46h,0CCh
		db	 83h, 82h,0C3h, 66h, 40h,0C2h
		db	0C1h,0C2h, 50h,0C2h,0C1h, 81h
		db	0C3h, 46h, 89h,0DBh,0DFh, 56h
		db	0CAh, 02h, 18h, 84h,0DBh,0DFh
		db	 76h,0CAh,0C7h, 01h, 18h, 83h
		db	0C3h,0C7h,0CAh, 01h, 18h, 82h
		db	 82h,0C3h,0C7h,0CCh,0C8h, 02h
		db	 18h, 89h,0C4h,0C7h,0C8h, 04h
		db	 18h, 84h,0DBh,0DFh, 66h,0CCh
		db	 86h,0DBh,0DFh, 76h,0C5h,0D8h
		db	 85h,0C3h, 46h,0CCh, 83h, 82h
		db	0C3h,0C7h,0C8h, 46h, 01h, 18h
		db	 89h,0DAh,0DFh,0C7h, 02h, 18h
		db	 86h,0DBh,0DFh, 66h,0CCh, 86h
		db	0DBh,0DFh, 76h,0CCh, 86h,0C4h
		db	0C7h,0CCh,0C8h,0D8h, 82h, 82h
		db	0C4h, 56h, 01h, 18h, 8Ah,0DCh
		db	0DFh,0C7h,0C8h,0D8h, 87h,0DBh
		db	0DFh, 56h,0C6h,0CCh, 86h,0DBh
		db	0DFh, 05h, 07h, 01h, 18h, 84h
		db	0C3h, 46h,0D8h,0C7h, 82h, 81h
		db	0C4h, 66h,0CCh, 8Bh,0DBh,0DFh
		db	0C7h,0CCh, 88h,0DBh,0DFh, 66h
		db	 01h, 18h, 85h,0DBh,0DFh,0C9h
		db	 66h,0C8h,0C7h,0D8h, 84h,0C3h
		db	 56h,0CAh,0C7h,0C6h, 46h,0C5h
		db	 66h, 01h, 18h, 89h,0DBh,0DFh
		db	0C9h,0CCh, 88h,0DBh,0DFh, 46h
		db	0C8h, 01h, 18h, 86h,0DBh,0DFh
		db	 56h,0CCh,0C7h,0C5h,0D8h, 85h
		db	0C3h, 46h,0C5h, 56h, 06h, 07h
		db	0C8h,0CAh, 02h, 18h, 86h,0DBh
		db	0E0h,0C7h,0CCh, 88h,0DBh,0DFh
		db	 76h,0D8h, 85h,0DBh,0DFh, 56h
		db	 01h, 18h, 87h,0C3h,0C7h,0C8h
		db	 66h, 08h, 07h, 01h, 18h, 87h
		db	0DBh,0DEh,0C7h, 02h, 18h, 86h
		db	0DBh,0DFh, 66h,0C6h, 86h,0DBh
		db	0DFh, 46h,0C1h, 41h, 40h,0C2h
		db	 50h, 81h,0C3h, 46h,0CCh, 81h
		db	0C3h,0C5h, 06h, 07h,0CCh, 8Ah
		db	0DBh,0DFh,0C7h,0C6h, 88h,0DBh
		db	0DFh,0C7h,0C9h,0C6h,0C8h,0C6h
		db	 86h,0DBh,0DFh, 56h, 01h, 18h
		db	 87h,0C4h,0CCh, 83h,0C4h,0C7h
		db	0C4h, 06h, 07h,0CCh, 89h,0DBh
		db	0DFh,0C7h,0C8h, 02h, 18h, 85h
		db	0DBh,0DFh, 56h, 45h, 86h,0DBh
		db	0DFh, 56h, 50h,0C2h, 40h,0C2h
		db	 40h, 87h,0C3h, 07h, 07h, 03h
		db	 18h, 85h,0DBh,0DFh,0C9h,0C7h
		db	0D8h, 87h,0DBh,0DFh, 56h, 4Bh
		db	 86h,0DBh,0DFh, 46h,0C8h, 01h
		db	 18h, 8Eh,0C3h, 76h,0CCh,0C8h
		db	0CCh, 01h, 18h, 87h,0DBh,0DFh
		db	0C7h,0CCh, 88h,0DBh,0DFh, 56h
		db	0C6h, 87h,0DBh,0DFh, 66h,0C1h
		db	0C2h, 40h,0C2h,0C1h,0C2h,0C1h
		db	 87h,0C4h, 06h, 07h,0CCh, 89h
		db	0DDh,0E0h,0C7h, 01h, 18h, 87h
		db	0DBh,0DFh,0C9h, 46h, 01h, 18h
		db	 86h,0DBh,0DFh,0C7h,0CCh,0CAh
		db	0D9h, 01h, 18h, 8Dh,0C3h, 06h
		db	 07h,0CCh, 95h,0DBh,0DFh, 66h
		db	 01h, 18h, 85h,0DBh,0DFh, 56h
		db	0C2h, 40h,0C2h, 50h,0C2h,0C1h
		db	 87h,0C3h,0C7h,0C5h, 76h,0CCh
		db	 40h,0C2h, 60h,0C2h, 40h,0C2h
		db	 50h,0C2h,0C1h,0C2h,0C1h,0C2h
		db	0C1h, 81h,0DBh,0DFh, 66h,0C6h
		db	 86h,0DBh,0DFh, 46h,0C8h,0D8h
		db	 8Fh,0C3h, 06h, 07h, 96h,0DDh
		db	0DFh, 46h,0C6h,0CAh,0D9h, 01h
		db	 18h, 84h,0DDh,0E0h,0CCh,0C7h
		db	0C1h,0C2h, 60h, 41h, 40h, 87h
		db	0C3h, 07h, 07h, 02h, 18h, 86h
		db	0DAh,0DEh, 46h, 02h, 18h, 85h
		db	0C4h, 76h,0C6h, 9Bh,0C3h,0C5h
		db	 05h, 07h,0CAh,0C7h, 02h, 18h
		db	 85h,0DBh,0E0h, 66h, 01h, 18h
		db	 82h,0C3h, 07h, 07h,0C1h,0C2h
		db	 40h, 41h, 40h,0C2h, 70h,0C2h
		db	0C1h, 8Bh,0C3h, 06h, 07h,0CCh
		db	 89h,0DBh,0DEh, 05h, 07h, 01h
		db	 18h,0C3h, 06h, 07h,0C8h, 02h
		db	 18h, 98h,0C3h, 07h, 07h, 01h
		db	 18h, 87h,0DBh,0DFh,0C7h,0C9h
		db	 76h, 01h, 18h,0C7h,0CAh, 66h
		db	0CAh,0C7h,0C6h, 9Ah,0C3h, 66h
		db	0C9h,0C7h,0CCh,0C8h,0C7h, 88h
		db	0DBh,0DFh, 0Dh, 07h,0ECh, 66h
		db	 02h, 18h, 96h,0C4h, 05h, 07h
		db	 5Bh, 02h, 18h, 85h,0DBh,0DFh
		db	 05h, 07h,0CCh, 06h, 07h,0ECh
		db	 56h,0C6h,0C8h, 46h,0D8h, 95h
		db	0C3h, 76h,0CCh, 8Bh,0DBh,0DFh
		db	0C9h, 56h,0C8h,0CCh,0C8h, 06h
		db	 07h,0ECh, 66h,0C8h,0CAh,0CCh
		db	 66h, 01h, 18h, 90h,0C3h, 06h
		db	 07h, 8Ah,0DBh,0E0h, 05h, 07h
		db	 01h, 18h,0C3h,0C7h,0C8h, 46h
		db	0ECh, 56h,0C8h,0CCh,0C7h,0D9h
		db	 46h, 01h, 18h, 93h,0C3h, 76h
		db	0CAh,0CCh, 03h, 18h, 86h,0DBh
		db	0DEh, 76h,0CCh, 82h,0C4h, 56h
		db	0CAh,0ECh, 56h,0D9h, 01h, 18h
		db	 8Eh,0C4h, 89h,0C3h,0C7h,0C5h
		db	 56h,0CCh,0C8h, 02h, 18h, 87h
		db	0DBh,0E0h, 66h,0CBh,0CCh, 83h
		db	0C3h,0CCh, 46h,0ECh, 66h,0C1h
		db	0C2h, 40h,0C2h, 40h, 41h, 40h
		db	0C2h, 50h, 81h,0C4h,0C7h,0D8h
		db	 87h,0C4h, 66h,0C8h, 4Bh, 8Ah
		db	0DBh,0DFh, 66h,0C8h, 02h, 18h
		db	 83h,0C4h, 46h,0ECh,0C7h,0CAh
		db	0D8h, 90h,0C3h, 46h, 01h, 18h
		db	 85h,0C4h,0C7h, 4Bh,0D8h,0CCh
		db	 02h, 18h, 89h,0DBh,0DFh,0C7h
		db	0ECh, 46h, 02h, 18h, 84h,0C4h
		db	 76h, 02h, 18h, 84h,0C4h,0C7h
		db	 01h, 18h, 86h,0C3h,0C8h,0C7h
		db	 02h, 18h, 84h, 92h,0DBh,0DEh
		db	0C7h,0ECh,0C7h,0CCh, 87h,0C3h
		db	 66h,0CCh, 87h,0C3h,0C7h,0C6h
		db	 01h, 18h, 85h,0C3h,0C7h,0CCh
		db	 87h, 40h,0C2h,0C1h,0C2h, 50h
		db	0C2h,0C1h,0C2h, 50h,0C2h, 40h
		db	 81h,0DBh,0DFh, 56h, 01h, 18h
		db	 86h,0C3h,0C5h, 56h,0D9h, 01h
		db	 18h, 85h,0C3h,0C5h,0C7h,0C8h
		db	0D8h, 85h,0C3h,0C5h, 46h, 40h
		db	 41h, 40h, 92h,0DBh,0DFh, 56h
		db	0C8h, 02h, 18h, 84h,0C3h, 66h
		db	0CCh, 87h,0C4h, 46h,0CCh, 86h
		db	0C3h, 46h,0C8h, 01h, 18h, 84h
		db	 92h,0DBh,0DEh,0C7h,0C9h,0CBh
		db	0CCh, 87h,0C3h, 66h,0CCh, 87h
		db	0C3h, 46h,0CCh, 86h,0C3h, 76h
		db	 01h, 18h, 82h, 92h,0DBh,0E0h
		db	 56h,0CCh, 87h,0C4h, 46h,0C5h
		db	0C7h,0CCh, 87h,0C4h,0C7h,0CCh
		db	0C8h, 01h, 18h, 84h,0C4h, 46h
		db	0C5h,0C8h, 46h, 02h, 18h, 92h
		db	0DBh,0DFh, 46h,0C8h,0CCh, 87h
		db	0C3h,0C5h, 56h, 01h, 18h, 86h
		db	0C3h,0C7h,0C8h, 01h, 18h, 85h
		db	0C3h,0C7h, 4Bh, 02h, 18h, 83h
		db	 92h,0DBh,0DFh, 56h,0CCh, 87h
		db	0C3h, 56h,0D9h, 02h, 18h, 85h
		db	0C3h, 46h,0CCh, 86h,0C3h,0C7h
		db	0CCh,0C8h,0C7h, 85h, 92h,0DBh
		db	0DFh, 46h,0CAh, 01h, 18h, 86h
		db	0C4h, 66h,0CCh, 87h,0C3h, 46h
		db	0CCh, 86h,0C3h, 56h, 01h, 18h
		db	 84h, 92h,0DCh,0DFh,0C9h,0C7h
		db	0CCh, 88h,0DAh,0DFh, 56h,0CCh
		db	 87h,0C3h, 56h, 01h, 18h, 84h
		db	0C3h,0C5h, 01h, 18h, 86h, 92h
		db	0DDh,0DFh, 66h, 02h, 18h, 84h
		db	0DBh,0DFh,0CAh,0C7h,0C6h, 88h
		db	0C4h, 46h,0CAh, 02h, 18h, 83h
		db	0C3h,0C7h,0CCh, 87h, 92h,0C4h
		db	 56h,0C8h,0C7h, 01h, 18h, 85h
		db	0DBh,0E0h, 56h,0C6h, 87h,0DAh
		db	0DFh, 46h, 01h, 18h, 84h,0C4h
		db	 4Bh, 87h, 92h,0C3h, 66h,0CCh
		db	 87h,0DBh,0DEh, 66h,0D9h, 01h
		db	 18h, 84h,0DBh,0DFh,0CAh, 01h
		db	 18h, 8Fh, 41h, 60h,0C2h, 50h
		db	0C2h, 50h,0C2h, 40h, 81h,0C3h
		db	 56h,0CCh, 88h,0DBh,0DFh,0C9h
		db	0C7h,0C8h, 01h, 18h, 86h,0DBh
		db	0DFh, 46h, 50h,0C2h, 40h,0C2h
		db	 40h,0C2h, 50h,0C2h, 40h, 92h
		db	0C4h,0C5h, 56h,0CCh, 87h,0DBh
		db	0DFh, 56h,0CCh, 87h,0DBh,0DFh
		db	 56h, 01h, 18h, 8Dh, 82h,0C4h
		db	 45h, 8Eh,0C3h,0C8h, 46h,0CAh
		db	 01h, 18h, 85h,0DBh,0DFh, 46h
		db	0C6h, 88h,0DBh,0DFh,0C9h, 46h
		db	0CAh, 02h, 18h, 8Bh, 82h,0C4h
		db	 47h,0C6h, 8Dh,0C4h,0C6h, 56h
		db	 02h, 18h, 84h,0DBh,0DFh,0C7h
		db	0CAh,0C7h,0C6h, 01h, 18h, 85h
		db	0DBh,0DFh, 76h,0CAh, 03h, 18h
		db	 88h, 82h,0C3h, 46h,0C6h, 01h
		db	 18h, 8Bh,0DBh,0DFh, 46h,0CCh
		db	 87h,0DDh,0DEh, 56h,0CCh,0C7h
		db	 02h, 18h, 83h,0DBh,0DFh, 07h
		db	 07h,0C8h, 01h, 18h, 87h, 82h
		db	0C3h, 56h,0C8h,0C7h, 01h, 18h
		db	 89h,0DBh,0DFh,0C6h,0C7h,0CCh
		db	 87h,0C3h, 56h,0C8h, 01h, 18h
		db	 86h,0DBh,0DFh, 0Bh, 07h, 02h
		db	 18h, 83h, 82h,0C3h,0C7h,0CBh
		db	0CCh,0C7h,0CCh, 8Bh,0DDh,0E0h
		db	0C6h,0C7h, 01h, 18h, 86h,0C3h
		db	0C7h,0CCh,0C8h, 02h, 18h, 86h
		db	0DBh,0DFh, 56h,0C9h,0C7h, 4Bh
		db	 76h,0C8h, 02h, 18h, 82h, 82h
		db	0DAh,0DFh,0CCh, 01h, 18h, 8Dh
		db	0DBh,0DFh,0CBh, 46h, 01h, 18h
		db	 84h,0C4h,0C7h,0C8h,0D8h, 89h
		db	0DBh,0DFh,0C9h, 56h,0D8h, 82h
		db	0C4h,0CCh, 76h,0C8h, 01h, 18h
		db	 81h, 82h,0DBh,0E0h, 46h,0C8h
		db	0C6h,0D8h, 8Bh,0DDh,0E0h,0CCh
		db	 88h,0C4h,0CCh, 01h, 18h, 89h
		db	0DBh,0DFh, 56h, 01h, 18h, 83h
		db	0C4h, 46h,0C5h, 46h,0D8h, 83h
		db	 82h,0DBh,0DEh, 46h,0C6h,0C8h
		db	 45h,0A2h,0DBh,0DFh, 46h,0CCh
		db	 85h,0C4h, 56h,0CCh, 85h, 82h
		db	0DBh,0DFh, 46h,0CBh,0C6h, 47h
		db	 4Bh, 40h, 41h, 60h,0C2h, 40h
		db	0C2h,0C1h,0C2h, 40h, 41h, 40h
		db	0C2h,0C1h,0C2h, 50h,0C2h, 40h
		db	0C2h,0C1h, 81h,0DBh,0DFh, 46h
		db	0CCh, 85h,0C3h, 76h,0D8h, 83h
		db	 82h,0DBh,0DFh,0C7h,0CAh,0C7h
		db	0CBh, 01h, 18h,0A2h,0DBh,0DFh
		db	 56h,0D8h, 84h,0C3h, 56h,0C8h
		db	0D8h,0D9h,0D8h, 82h, 82h,0DBh
		db	0E0h, 46h,0C6h, 8Ch,0DAh,0DEh
		db	0C6h, 8Bh,0C4h, 45h, 88h,0DBh
		db	0E0h, 46h,0C8h, 01h, 18h, 83h
		db	0C3h,0C5h, 56h,0D9h, 84h, 82h
		db	0DBh,0DEh,0C7h,0C8h,0C6h, 8Ch
		db	0DBh,0DFh,0C7h,0C6h, 8Ah,0C4h
		db	 46h, 45h, 86h,0DBh,0DEh, 46h
		db	0D8h, 85h,0C3h, 66h,0CCh, 84h
		db	 82h,0DDh,0DFh,0C7h,0C6h,0C8h
		db	0C6h, 8Bh,0DBh,0DFh,0C9h,0CCh
		db	 02h, 18h, 87h,0C3h,0C7h,0C6h
		db	 81h,0CCh,0C8h, 46h, 45h, 66h
		db	0CCh, 86h,0C3h, 56h,0C6h, 85h
		db	 82h,0C3h, 76h, 02h, 18h, 88h
		db	0DCh,0DFh,0C7h,0D8h, 8Ah,0C3h
		db	0CCh, 81h, 5Bh,0C8h, 46h,0C9h
		db	 76h, 01h, 18h, 84h,0C3h, 66h
		db	0D9h, 01h, 18h, 82h, 82h,0C3h
		db	 66h,0CCh, 8Bh,0DBh,0DFh,0C7h
		db	0C6h, 8Ah,0C3h, 46h, 45h,0C8h
		db	 66h, 4Bh,0C8h,0C7h,0CCh, 86h
		db	0C4h, 46h,0C8h, 01h, 18h, 84h
		db	 81h,0CDh,0CEh,0D6h, 56h, 01h
		db	 18h, 89h,0DAh,0DEh, 46h, 01h
		db	 18h, 88h,0E1h,0C7h, 4Bh, 82h
		db	0C4h, 44h,0CCh,0C7h,0C8h, 56h
		db	0CCh, 86h,0C4h, 56h,0CCh, 85h
		db	 81h,0D0h,0D1h,0D6h,0C9h,0CAh
		db	0C7h,0C8h, 01h, 18h, 88h,0DBh
		db	0DFh,0C7h,0CCh, 89h,0E1h, 56h
		db	0C6h, 87h,0C3h, 56h,0CCh, 86h
		db	0C3h, 56h,0CCh, 85h, 82h,0D7h
		db	0D2h, 66h,0C8h,0C7h, 01h, 18h
		db	 86h,0DBh,0DFh,0CAh,0C6h, 88h
		db	0E1h, 66h,0CCh, 01h, 18h, 85h
		db	0C3h, 56h, 01h, 18h, 85h,0C3h
		db	 66h, 01h, 18h, 83h, 82h,0D4h
		db	0D6h, 56h,0CAh,0CCh, 89h,0DBh
		db	0DFh,0C7h,0CCh, 01h, 18h, 85h
		db	0E1h, 56h,0C8h,0C7h,0CCh, 87h
		db	0C3h, 56h,0C8h, 01h, 18h, 84h
		db	0C4h, 66h,0CCh, 84h, 82h,0C3h
		db	 66h,0D8h, 8Ah,0DBh,0DFh,0C7h
		db	0CBh,0D8h, 86h,0C4h, 66h,0C6h
		db	 88h,0C4h, 56h,0CCh, 86h,0C4h
		db	 56h,0C6h, 85h, 82h,0C3h, 56h
		db	0C8h, 02h, 18h, 88h,0C4h, 46h
		db	 45h, 86h,0C4h, 46h,0C6h,0C8h
		db	0C6h, 88h,0C3h, 56h,0D8h, 86h
		db	0C3h, 66h, 02h, 18h, 82h, 82h
		db	0C3h, 66h,0CCh, 8Ah,0C3h, 46h
		db	 4Bh, 01h, 18h, 84h,0C4h,0C5h
		db	 46h,0C6h,0C8h,0C6h, 01h, 18h
		db	 85h,0C3h, 46h,0CCh, 87h,0C4h
		db	 56h,0CAh,0D9h,0D8h, 83h, 82h
		db	0C3h, 56h,0CAh,0CCh, 8Ah,0C3h
		db	0C9h,0C7h,0CCh,0D8h, 86h,0C4h
		db	 66h, 4Bh, 87h,0C4h, 46h,0C6h
		db	 87h,0C3h, 66h,0CCh, 84h, 82h
		db	0C3h, 56h, 01h, 18h, 8Ah,0C3h
		db	 46h,0CCh, 87h,0C3h, 56h,0CCh
		db	 01h, 18h, 87h,0C4h, 46h,0CAh
		db	 01h, 18h, 85h,0C3h, 66h, 01h
		db	 18h, 83h, 82h,0C3h, 56h,0C6h
		db	 8Bh,0C3h, 46h,0C6h, 87h,0C3h
		db	 46h,0C8h,0C6h, 89h,0C3h, 56h
		db	0CAh, 02h, 18h, 83h,0C3h,0C9h
		db	 56h,0CCh, 84h, 82h,0C3h, 66h
		db	 03h, 18h, 87h,0C3h, 46h,0CCh
		db	0D8h, 86h,0C4h, 46h,0C6h,0C8h
		db	0C6h, 88h,0C3h, 56h,0CCh, 01h
		db	 18h, 84h,0C3h, 56h,0CAh,0CCh
		db	 84h, 82h,0C3h,0C7h,0C9h,0C7h
		db	 02h, 18h, 89h,0C3h, 46h,0CBh
		db	0D9h, 01h, 18h, 84h,0C4h, 66h
		db	0C6h, 02h, 18h, 85h,0C3h, 46h
		db	0CCh, 87h,0C3h, 56h,0C6h, 85h
		db	 82h,0C3h, 56h,0CCh, 8Bh,0C4h
		db	0C7h,0C9h,0C6h, 88h,0C4h,0C5h
		db	 46h, 4Bh,0D8h, 86h,0C3h,0C7h
		db	0C8h,0C7h, 01h, 18h, 85h,0C3h
		db	 66h,0CCh, 84h, 82h,0C3h, 56h
		db	0CCh, 8Bh,0DAh,0DFh,0C7h,0CCh
		db	 01h, 18h, 86h,0C4h, 46h,0CCh
		db	 89h,0C3h, 46h, 01h, 18h, 86h
		db	0C3h, 56h,0C6h,0CCh, 84h, 82h
		db	0C3h, 46h,0CAh,0C7h, 02h, 18h
		db	 88h,0DBh,0E0h,0C7h,0CCh, 88h
		db	0C4h, 46h, 01h, 18h, 88h,0C3h
		db	 46h,0CCh, 87h,0C3h, 66h,0CCh
		db	 84h, 82h,0C3h, 56h, 02h, 18h
		db	 89h,0DBh,0DEh,0C7h,0C6h, 88h
		db	0C3h, 46h,0C6h, 89h,0C4h, 46h
		db	0CCh, 87h,0C3h, 56h,0C8h, 02h
		db	 18h, 82h, 82h,0C3h, 46h,0CCh
		db	 8Ch,0DBh,0DEh, 46h,0D9h, 01h
		db	 18h, 85h,0C3h,0C7h,0C6h, 8Ah
		db	0C3h, 46h,0CAh, 01h, 18h, 85h
		db	0C3h, 66h, 01h, 18h, 83h, 82h
		db	0C3h, 56h, 01h, 18h, 8Ah,0DBh
		db	0E0h,0C7h,0CAh,0CCh, 87h,0C3h
		db	0C7h, 45h, 89h,0C4h,0C9h, 46h
		db	0C6h, 86h,0C4h, 66h,0CCh, 84h
		db	 82h,0C3h, 46h,0C6h, 8Ch,0DCh
		db	0DEh, 46h, 01h, 18h, 86h,0C3h
		db	 46h,0C6h, 01h, 18h, 87h,0C3h
		db	 66h, 01h, 18h, 84h,0C4h, 66h
		db	 01h, 18h, 83h, 82h,0C3h, 46h
		db	0CCh, 8Ch,0DDh,0DFh,0C7h,0C5h
		db	0C7h, 02h, 18h, 84h,0C4h, 46h
		db	0CCh, 89h,0C3h, 46h,0C8h, 01h
		db	 18h, 85h,0C3h, 66h,0D9h, 01h
		db	 18h, 82h, 82h,0C3h, 46h,0CCh
		db	 8Bh,0CDh,0D7h, 46h, 4Bh, 87h
		db	0C3h,0C7h,0C6h, 8Ah,0C4h, 46h
		db	0CCh, 87h,0C3h, 46h,0CAh,0D9h
		db	 01h, 18h, 83h, 82h,0C3h,0C7h
		db	0C9h,0CCh, 8Bh,0D0h,0D7h, 46h
		db	 89h,0C4h, 46h,0C6h, 89h,0C4h
		db	0C7h,0CAh, 01h, 18h, 86h,0C3h
		db	 66h,0CCh, 84h, 82h,0C3h, 56h
		db	 01h, 18h, 89h,0D3h,0D6h, 56h
		db	0D9h, 01h, 18h, 85h,0C3h,0C5h
		db	 46h, 01h, 18h, 92h,0C4h, 56h
		db	0CAh, 85h, 82h,0C3h, 46h,0CCh
		db	 02h, 18h, 89h,0C4h, 46h,0CCh
		db	 88h,0C3h, 56h, 40h,0C2h, 40h
		db	 41h, 40h,0C2h, 40h,0C2h, 50h
		db	0C2h, 40h, 81h,0C3h, 66h,0CCh
		db	 84h, 82h,0C3h, 46h,0CAh,0D8h
		db	 8Bh,0C4h, 46h,0C6h, 88h,0C4h
		db	 46h,0CCh, 94h,0C3h, 66h,0CCh
		db	 84h, 82h,0C3h, 46h,0CCh, 8Bh
		db	0CEh,0D6h, 56h,0C6h,0D8h, 86h
		db	0C4h,0CCh, 87h,0C4h, 46h, 45h
		db	 8Ah,0C3h,0C9h,0C7h,0CCh,0C8h
		db	 02h, 18h, 82h, 82h,0C3h, 46h
		db	0CCh, 8Ah,0CDh,0D1h,0D6h, 76h
		db	 01h, 18h, 8Dh,0C3h,0C7h,0C5h
		db	 56h, 02h, 18h, 86h,0C3h, 66h
		db	0D9h,0D8h, 83h, 82h,0C3h, 46h
		db	0CCh, 8Ah,0D0h,0D1h,0D2h, 56h
		db	0C8h,0CCh, 50h, 41h, 50h, 41h
		db	 40h,0C2h,0C1h, 81h,0C4h, 76h
		db	0C8h,0C7h, 01h, 18h, 85h,0C3h
		db	 66h,0CCh, 84h, 82h,0C3h, 46h
		db	 01h, 18h, 89h,0D3h,0D7h,0D6h
		db	 56h,0CCh, 90h,0C3h, 05h, 07h
		db	0CCh, 87h,0C3h, 46h,0CCh,0CAh
		db	 01h, 18h, 83h, 82h,0C3h, 46h
		db	0CCh, 8Bh,0D4h,0C4h,0C7h,0D6h
		db	0C7h,0CBh,0C6h, 01h, 18h, 8Dh
		db	0C3h, 05h, 07h,0CAh, 02h, 18h
		db	 84h,0C4h, 56h, 01h, 18h, 84h
		db	 82h,0C3h, 56h, 02h, 18h, 89h
		db	0C4h, 46h,0CCh, 91h,0C3h,0C5h
		db	 56h,0C9h, 46h, 01h, 18h, 85h
		db	0C3h,0C7h,0C8h,0D8h, 86h, 82h
		db	0C3h, 46h,0CAh,0C7h, 03h, 18h
		db	 87h,0C3h,0D6h, 46h, 91h,0C4h
		db	 4Bh, 66h,0CCh, 87h,0C3h,0C7h
		db	 02h, 18h, 85h, 82h,0C3h, 66h
		db	0D8h, 8Ah,0C4h, 66h, 01h, 18h
		db	 91h,0C4h, 56h, 88h,0C4h,0CCh
		db	 88h, 82h,0C3h, 56h,0C8h,0CCh
		db	 8Ah,0C3h, 66h,0C8h,0C6h, 91h
		db	0C3h,0C7h,0C8h,0C7h, 02h, 18h
		db	 8Fh, 82h,0C3h, 66h,0CCh, 8Ah
		db	0C4h, 05h, 07h,0C6h, 01h, 18h
		db	 8Eh,0C3h, 56h,0CCh, 91h, 82h
		db	0C3h, 76h,0CCh, 89h,0C3h, 06h
		db	 07h, 45h, 03h, 18h, 8Ah,0C3h
		db	 46h,0C8h,0CCh, 86h,0C3h,0C7h
		db	 02h, 18h, 86h, 82h,0C4h, 66h
		db	0CAh,0CCh, 89h,0C3h, 56h,0C5h
		db	 09h, 07h,0D8h,0D9h, 01h, 18h
		db	 85h,0C4h, 66h, 02h, 18h, 83h
		db	0C3h, 46h,0D9h, 87h, 83h,0C4h
		db	 66h, 01h, 18h, 88h,0C3h, 08h
		db	 07h,0D8h, 46h, 02h, 18h, 88h
		db	0C3h, 46h,0CCh, 02h, 18h, 84h
		db	0C3h,0C7h,0C9h,0C7h, 02h, 18h
		db	 84h, 83h,0C4h, 76h, 02h, 18h
		db	 86h,0C3h, 66h,0C9h,0CBh,0CCh
		db	 90h,0C3h, 46h,0C6h, 87h,0C3h
		db	 56h,0C8h,0C7h,0D8h, 84h, 2Dh
		db	 00h, 31h, 3Ch, 00h, 35h, 3Fh
		db	 00h, 35h, 42h, 00h, 35h,0FFh
		db	0FFh,0FFh,0FFh, 53h, 80h, 2Fh
		db	 4Ch, 00h, 5Ah, 00h, 64h, 80h
		db	0AFh, 5Dh, 00h, 6Bh, 00h,0FFh
		db	0FFh, 09h, 00h, 19h,0C2h, 0Ch
		db	 09h, 00h, 19h, 00h,0FFh,0FFh
		db	0FFh, 19h, 00h, 0Eh,0C2h, 0Ah
		db	 2Fh, 00h, 0Eh, 00h,0FFh,0FFh
		db	0FFh, 58h, 00h, 22h,0C3h, 0Ch
		db	 58h, 00h, 22h, 00h,0FFh,0FFh
		db	0FFh, 5Eh, 00h, 0Ah, 80h, 85h
		db	 04h, 00h,0FFh, 00h,0FFh,0FFh
		db	0FFh, 64h, 00h, 3Bh,0C4h, 0Ch
		db	 64h, 00h, 3Bh, 00h,0FFh,0FFh
		db	0FFh, 83h, 00h, 09h,0C0h, 85h
		db	 08h, 01h,0FFh, 00h,0FFh,0FFh
		db	0FFh, 83h, 00h, 35h, 42h, 0Ch
		db	 83h, 00h, 35h, 00h, 23h, 00h
		db	 80h, 8Dh, 00h, 3Eh,0C2h, 0Ch
		db	 8Dh, 00h, 3Eh, 00h,0FFh,0FFh
		db	0FFh,0CEh, 00h, 27h,0C4h, 0Ch
		db	0CEh, 00h, 27h, 00h,0FFh,0FFh
		db	0FFh,0FFh,0FFh, 22h, 00h, 80h
		db	 12h,0D9h, 00h,0FFh, 1Dh,0D9h
		db	0FFh,0FFh,0FFh,0FFh, 22h, 00h
		db	 40h, 2Bh,0DAh, 00h, 00h,0FFh
		db	0FFh, 22h, 00h, 20h,0E2h,0DAh
		db	 00h,0FFh,0EDh,0DAh,0FFh,0FFh
		db	0FFh,0FFh, 22h, 00h, 10h,0C2h
		db	0DBh, 00h,0FFh,0CDh,0DBh,0FFh
		db	0FFh,0FFh,0FFh, 22h, 00h, 08h
		db	0D2h,0DBh, 00h,0FFh,0DDh,0DBh
		db	0FFh,0FFh,0FFh,0FFh, 22h, 00h
		db	 04h, 22h,0DCh, 00h,0FFh, 2Dh
		db	0DCh,0FFh,0FFh,0FFh,0FFh, 22h
		db	 00h, 02h, 52h,0DCh, 00h,0FFh
		db	 5Dh,0DCh,0FFh,0FFh,0FFh,0FFh
		db	 22h, 00h, 01h, 82h,0DCh, 00h
		db	0FFh, 8Dh,0DCh,0FFh,0FFh,0FFh
		db	0FFh, 23h, 00h, 80h, 56h,0D8h
		db	0C2h, 0Ch,0FFh,0FFh,0FFh,0FFh
		db	 16h,0AFh, 02h, 11h
		db	'Cavern of Corroer'
		db	 11h, 00h, 04h, 08h, 08h, 03h
		db	 00h, 2Fh,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 03h, 00h
		db	 2Fh, 04h, 00h, 07h, 00h, 33h
		db	0FFh, 73h, 00h, 00h, 20h, 00h
		db	 18h, 00h, 22h, 00h, 80h, 00h
		db	 00h, 09h, 00h, 10h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 09h, 00h, 10h, 02h, 00h, 0Bh
		db	 00h, 00h,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 0Bh, 00h
		db	 00h, 00h, 00h, 0Bh, 00h, 02h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 0Bh, 00h, 02h, 01h
		db	 00h, 0Bh, 00h, 15h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 0Bh, 00h, 15h, 04h, 00h, 0Eh
		db	 00h, 22h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 0Eh, 00h
		db	 22h, 04h, 00h, 0Eh, 00h, 28h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 0Eh, 00h, 28h, 03h
		db	 00h, 16h, 00h, 02h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 16h, 00h, 02h, 03h, 00h, 1Ah
		db	 00h, 28h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 1Ah, 00h
		db	 28h, 02h, 00h, 1Bh, 00h, 19h
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 1Bh, 00h, 19h, 00h
		db	 00h, 1Bh, 00h, 1Bh,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 1Bh, 00h, 1Bh, 01h, 00h, 1Bh
		db	 00h, 33h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 1Bh, 00h
		db	 33h, 03h, 00h, 1Eh, 00h, 22h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 1Eh, 00h, 22h, 04h
		db	 00h, 20h, 00h, 3Ah,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 20h, 00h, 3Ah, 04h, 00h, 28h
		db	 00h, 3Ah,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 28h, 00h
		db	 3Ah, 04h, 00h, 2Fh, 00h, 10h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 2Fh, 00h, 10h, 03h
		db	 00h, 31h, 00h, 02h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 31h, 00h, 02h, 03h, 00h, 41h
		db	 00h, 1Bh,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 18h, 00h, 22h, 00h
		db	 40h, 00h, 00h, 4Ah, 00h, 1Fh
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 4Ah, 00h, 1Fh, 04h
		db	 00h, 4Eh, 00h, 0Eh,0FFh,0F1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh,0FFh, 00h, 00h, 52h
		db	 00h, 16h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 52h, 00h
		db	 16h, 02h, 00h, 54h, 00h, 0Eh
		db	0FFh,0F1h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh,0FFh, 00h
		db	 00h, 56h, 00h, 04h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 56h, 00h, 04h, 04h, 00h, 57h
		db	 00h, 1Fh,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 57h, 00h
		db	 1Fh, 04h, 00h, 58h, 00h, 33h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 58h, 00h, 33h, 02h
		db	 00h, 5Ah, 00h, 39h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 5Ah, 00h, 39h, 04h, 00h, 5Eh
		db	 00h, 16h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 5Eh, 00h
		db	 16h, 02h, 00h, 65h, 00h, 33h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 65h, 00h, 33h, 02h
		db	 00h, 6Eh, 00h, 07h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 6Eh, 00h, 07h, 04h, 00h, 73h
		db	 00h, 2Bh,0FFh, 73h, 00h, 04h
		db	 20h, 00h, 00h, 00h, 22h, 00h
		db	 20h, 00h, 00h, 81h, 00h, 16h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 81h, 00h, 16h, 04h
		db	 00h, 82h, 00h, 00h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 82h, 00h, 00h, 03h, 00h, 86h
		db	 00h, 00h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 86h, 00h
		db	 00h, 02h, 00h, 86h, 00h, 1Dh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 86h, 00h, 1Dh, 02h
		db	 00h, 88h, 00h, 2Ah,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 88h, 00h, 2Ah, 02h, 00h, 8Ah
		db	 00h, 15h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 8Ah, 00h
		db	 15h, 04h, 00h, 8Dh, 00h, 1Dh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 8Dh, 00h, 1Dh, 03h
		db	 00h, 90h, 00h, 2Ah,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 90h, 00h, 2Ah, 02h, 00h, 95h
		db	 00h, 16h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 95h, 00h
		db	 16h, 04h, 00h, 98h, 00h, 09h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 98h, 00h, 09h, 04h
		db	 00h, 9Bh, 00h, 3Eh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 9Bh, 00h, 3Eh, 02h, 00h,0A6h
		db	 00h, 08h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0A6h, 00h
		db	 08h, 04h, 00h,0A9h, 00h, 11h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0A9h, 00h, 11h, 02h
		db	 00h,0AAh, 00h, 1Dh,0FFh, 73h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 22h, 00h, 10h, 00h, 00h,0AFh
		db	 00h, 34h,0FFh, 73h, 00h, 04h
		db	 20h, 00h, 00h, 00h, 22h, 00h
		db	 08h, 00h, 00h,0B3h, 00h, 11h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0B3h, 00h, 11h, 02h
		db	 00h,0B3h, 00h, 25h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0B3h, 00h, 25h, 04h, 00h,0B6h
		db	 00h, 1Eh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0B6h, 00h
		db	 1Eh, 02h, 00h,0BFh, 00h, 2Bh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0BFh, 00h, 2Bh, 02h
		db	 00h,0C0h, 00h, 34h,0FFh, 73h
		db	 00h, 01h, 20h, 00h, 00h, 00h
		db	 22h, 00h, 04h, 00h, 00h,0C1h
		db	 00h, 01h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C1h, 00h
		db	 01h, 02h, 00h,0D0h, 00h, 00h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0D0h, 00h, 00h, 03h
		db	 00h,0D0h, 00h, 1Bh,0FFh, 73h
		db	 00h, 00h, 20h, 00h, 1Ah, 00h
		db	 22h, 00h, 02h, 00h, 00h,0D0h
		db	 00h, 32h,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h,0D0h, 00h
		db	 32h, 00h, 00h,0D0h, 00h, 34h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0D0h, 00h, 34h, 01h
		db	 00h,0D1h, 00h, 10h,0FFh, 73h
		db	 00h, 02h, 20h, 00h, 00h, 00h
		db	 22h, 00h, 01h, 00h, 00h,0D6h
		db	 00h, 1Ch,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0D6h, 00h
		db	 1Ch, 03h, 00h,0D8h, 00h, 11h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0D8h, 00h, 11h, 02h
		db	 00h,0E0h, 00h, 00h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0E0h, 00h, 00h, 03h, 00h,0E9h
		db	 00h, 0Eh,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h,0E9h, 00h
		db	 0Eh, 00h, 00h,0E9h, 00h, 10h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0E9h, 00h, 10h, 01h
		db	 00h,0E9h, 00h, 26h,0FFh, 00h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	0E9h, 00h, 26h, 00h, 00h,0E9h
		db	 00h, 28h,0FFh, 01h, 00h, 00h
		db	 10h, 00h, 00h, 00h,0E9h, 00h
		db	 28h, 01h, 00h, 00h,0FFh, 00h
		db	0FFh
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
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h,0FFh
		db	0FFh

seg_a		ends



		end	start
