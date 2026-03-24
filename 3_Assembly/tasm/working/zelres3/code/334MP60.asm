
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR3_34	                                 лл
;лл					                                 лл
;лл      Created:   16-Feb-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	2001h			;*
data_2e		equ	53C3h			;*
data_9e		equ	2FD9h			;*
data_10e	equ	43C3h			;*
data_11e	equ	53C3h			;*
data_12e	equ	63C3h			;*
data_13e	equ	69D7h			;*
data_14e	equ	0C4C3h			;*
data_15e	equ	0DDC3h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr3_34		proc	far

start:
		add	[di],bx
		add	[bx+si],al
		sub	bl,cl
		inc	ax
		add	[di-29h],ax
		pop	cx
		xlat				; al=[al+[bx]] table
		pop	bx
		xlat				; al=[al+[bx]] table
		mov	di,data_13e
;*		fcom	dword ptr ds:data_9e	; Compare with st
		db	0D8h, 16h,0D9h, 2Fh	;  Fixup - byte match
;*		fld	dword ptr data_3	; Push onto stack
		db	0D9h, 06h, 35h, 01h	;  Fixup - byte match
		sub	cl,[bp+si]
		add	[bx+si],al
		inc	bp
		xlat				; al=[al+[bx]] table
		les	cx,dword ptr ds:data_14e[bx+si]	; Load seg:offset ptr
		db	0C7h,0C9h,0CAh, 8Ah,0C3h, 53h
		db	 85h,0C3h, 63h, 87h,0C3h,0C4h
		db	 85h,0C3h, 43h, 86h,0C3h, 43h
		db	0C4h, 02h, 20h, 53h, 01h, 20h
		db	 43h,0C9h,0CAh,0C9h,0CBh, 89h
		db	0C3h, 53h, 85h,0C3h, 53h,0DDh
		db	 87h,0C3h,0C4h, 85h,0C3h, 43h
		db	 86h,0C3h, 43h, 63h,0DDh, 05h
		db	 04h,0C7h, 59h, 89h,0C3h, 53h
		db	 85h,0C3h, 08h, 04h,0E0h, 53h
		db	 85h,0C3h,0C4h,0E0h, 86h,0C3h
		db	 43h, 43h,0DDh, 08h, 04h,0C7h
		db	0C9h,0CBh, 89h,0C3h,0C4h, 87h
		db	0C3h, 0Ch, 04h, 8Eh,0C3h, 43h
		db	 0Bh, 04h,0C7h,0CAh,0CBh, 89h
		db	0C3h,0C4h, 87h,0C3h, 0Ch, 04h
		db	 51h,0C1h, 51h, 60h, 41h, 81h
		db	0C3h, 43h, 06h, 04h,0DDh, 53h
		db	0C7h, 48h,0CAh,0CBh, 88h,0C3h
		db	0C4h, 87h,0C3h, 05h, 04h,0E0h
		db	 63h,0E0h,0C4h, 8Eh,0C3h, 43h
		db	 73h,0DDh, 05h, 04h,0C7h,0C8h
		db	0CAh,0CBh, 88h,0C3h,0C4h, 87h
		db	0C3h, 63h, 97h,0C3h, 43h,0C4h
		db	 01h, 20h, 63h, 01h, 20h, 63h
		db	0C7h,0CAh,0CBh, 88h,0C3h,0C4h
		db	 85h,0C3h, 63h, 01h, 1Dh, 97h
		db	0C3h, 43h,0C4h, 88h,0C3h, 43h
		db	0C7h,0C9h,0CAh,0CBh, 88h,0C8h
		db	0C4h, 85h,0C3h, 05h, 04h, 87h
		db	0C3h,0C4h,0E0h,0C4h,0E0h, 43h
		db	0E0h,0C4h, 87h,0C3h, 43h,0DDh
		db	 88h,0C3h, 53h,0C9h, 49h, 88h
		db	0C9h,0C4h, 85h,0C3h, 05h, 04h
		db	 87h,0C3h, 07h, 04h, 87h,0C3h
		db	 43h,0C4h, 88h,0C3h,0C4h,0C7h
		db	0C8h,0C7h,0CAh,0CBh, 84h,0C3h
		db	 82h,0CCh,0C8h,0C4h, 85h,0C3h
		db	 05h, 04h, 87h,0C3h, 07h, 04h
		db	 87h,0C3h, 43h,0C4h, 88h,0C3h
		db	 63h,0C8h,0C9h, 84h,0C3h,0CAh
		db	0CBh,0C9h,0C8h,0C4h, 85h,0C3h
		db	 63h,0DDh,0C4h, 87h,0C3h, 07h
		db	 04h, 87h,0C3h, 43h,0C4h, 88h
		db	0C3h,0C4h,0DDh,0C4h,0C7h,0C8h
		db	 43h, 83h,0C3h,0C7h
data_3		dw	0C848h, 85C4h
		db	0C3h, 05h, 04h, 87h,0C3h, 63h
		db	0DDh, 43h,0DDh, 87h,0C3h, 43h
		db	0C4h, 88h,0C3h, 73h, 85h,0C3h
		db	0C8h,0CDh, 48h,0C4h, 85h,0C3h
		db	 05h, 04h, 87h,0C3h, 63h,0DDh
		db	 53h, 87h,0C3h, 43h,0C4h, 88h
		db	0C3h, 63h, 89h,0CDh,0C8h,0C4h
		db	 85h,0C3h, 05h, 04h, 87h,0C3h
		db	 63h,0DDh, 53h, 87h,0C3h, 43h
		db	0C4h, 88h,0C3h, 43h, 8Ch,0C9h
		db	0C4h, 85h,0C3h, 05h, 04h, 87h
		db	0C3h, 07h, 04h, 87h,0C3h, 43h
		db	0C4h, 88h,0C3h, 43h, 8Ch,0CDh
		db	0C4h, 85h

loc_ret_1:
		retn
			                        ;* No entry point to code
		add	ax,8704h
		retn
			                        ;* No entry point to code
		pop	es
		add	al,87h
		retn
			                        ;* No entry point to code
		inc	bx
		les	cx,dword ptr ds:data_12e[bx+si]	; Load seg:offset ptr
		mov	ax,sp
		test	ax,bx
		db	0C4h,0DDh, 53h,0DDh, 87h,0C3h
		db	 05h, 04h, 89h,0C3h, 43h,0C4h
		db	 88h,0C3h, 63h, 8Ah,0CCh,0C4h
		db	 85h,0C3h, 05h, 04h, 87h,0C3h
		db	 43h,0DDh, 53h, 89h,0C3h, 43h
		db	0DDh, 88h,0C3h, 43h,0DDh,0C4h
		db	 8Ah,0C3h,0C4h, 85h
data_4		dw	5C3h, 8704h, 7D8h	; Data table (indexed access)
		dw	8704h
		db	0C3h, 43h,0C4h, 88h,0C3h, 43h
		db	 8Ch,0C3h,0C4h, 85h,0C3h, 05h
		db	 04h, 88h,0D8h, 63h,0DDh, 43h
		db	 87h,0C3h, 43h,0C4h, 88h,0C3h
		db	0DDh,0C4h, 8Ch,0C3h,0DDh, 85h
		db	0C3h, 05h, 04h, 89h,0D8h, 05h
		db	 04h, 87h,0C3h, 43h,0C4h, 88h
		db	0C3h,0DDh,0C4h, 8Bh,0C3h, 0Dh
		db	 04h,0E0h, 53h, 86h,0D8h, 73h
		db	 87h,0C3h, 43h,0C4h, 88h,0C3h
		db	 43h, 85h,0C3h, 85h,0C3h, 0Ah
		db	 04h,0DDh, 05h, 04h, 87h,0D8h
		db	 63h, 87h,0C3h, 01h, 1Dh, 89h
		db	0C3h, 43h, 85h,0C3h,0C4h, 84h
		db	0C3h, 73h,0E0h, 73h,0DDh, 05h
		db	 04h, 88h,0C3h, 53h, 8Ah,0C2h
		db	 40h, 51h, 40h, 81h,0C3h, 43h
		db	 85h,0C3h,0C4h, 84h,0C3h, 53h
		db	 85h,0C3h, 08h, 04h, 88h,0C3h
		db	0DDh, 43h, 50h, 51h, 60h, 89h
		db	0C3h, 43h, 85h,0C3h,0C4h, 84h
		db	0C3h, 53h, 85h,0C3h, 05h, 04h
		db	0E0h, 43h, 88h,0C3h, 53h, 8Ah
		db	 89h,0C3h, 43h, 8Bh,0C3h, 53h
		db	 85h,0C3h, 53h, 85h,0C3h, 88h
		db	0C3h, 43h,0E0h, 8Ah, 89h,0C3h
		db	 43h,0C1h,0C2h, 50h,0C2h, 60h
		db	 81h,0C3h, 53h, 85h,0C3h, 53h
		db	 85h,0C3h, 88h,0C3h, 43h,0E0h
		db	 8Ah, 89h,0C3h, 43h, 8Bh,0C3h
		db	 53h, 85h,0C3h, 43h,0DDh, 85h
		db	0C3h, 53h, 85h,0C3h, 43h,0E0h
		db	 8Ah, 89h,0C3h, 43h, 8Bh,0C3h
		db	 53h, 85h,0C3h, 53h, 85h

locloop_2:
		retn
		db	 53h, 85h,0C3h, 53h, 8Ah, 89h
		db	0C3h, 43h, 8Bh,0C3h, 53h, 85h
		db	0C3h,0DDh, 87h,0C3h, 53h, 85h
		db	0C3h, 53h, 8Ah, 89h,0C3h, 43h
		db	 8Bh,0C3h, 53h, 85h,0C3h,0C4h
		db	 87h,0C3h,0C4h,0DDh,0C4h, 85h
		db	0C3h, 43h,0E0h, 8Ah, 89h,0C3h
		db	 43h, 8Bh,0C3h,0C4h,0DDh,0C4h
		db	 85h,0C3h,0C4h, 87h,0C3h, 43h
		db	0E0h, 85h,0C3h, 53h, 8Ah, 89h
		db	0C3h,0C4h,0DDh, 8Bh,0C3h, 53h
		db	 85h,0C3h,0C4h, 87h,0C3h, 53h
		db	 85h,0C3h, 53h, 8Ah, 89h,0C3h
		db	 43h, 8Bh,0C3h, 53h, 85h,0C3h
		db	0C4h, 87h,0C3h, 53h, 85h,0C3h
		db	 53h, 8Ah, 43h, 87h,0C3h, 8Dh
		db	0C3h, 53h, 85h,0E0h,0C4h, 87h
		db	0C3h, 73h,0E0h, 05h, 04h,0E0h
		db	 53h, 84h,0C3h

locloop_3:
		les	ax,dword ptr [bp+di-79h]	; Load seg:offset ptr
		retn
		db	 8Dh,0C3h, 53h, 8Eh,0C3h, 0Fh
		db	 04h, 84h,0C3h,0C4h, 43h, 87h
		db	0C3h, 43h, 8Bh,0C3h, 53h, 8Eh
		db	0C3h, 0Fh, 04h, 84h,0C3h,0C4h
		db	 43h, 87h,0C3h, 43h, 8Bh,0C3h
		db	 53h, 8Eh,0C3h, 0Eh, 04h,0DDh
		db	 84h,0C3h,0C4h, 43h, 87h,0C3h
		db	 43h, 8Bh,0C3h, 53h, 8Eh,0C3h
		db	 05h, 04h,0E0h, 08h, 04h, 84h
		db	0C3h,0C4h, 43h, 87h,0C3h,0C4h
		db	0DDh, 8Bh,0C3h, 53h, 8Eh,0C3h
		db	 53h, 89h,0C3h, 53h, 84h,0C3h
		db	0DDh, 43h, 87h,0C3h, 43h, 84h
		db	0C3h, 43h, 84h,0C3h, 53h, 8Eh
		db	0C3h, 53h, 89h,0C3h, 53h, 84h
		db	0C3h,0C4h, 43h, 8Eh,0C3h,0C4h
		db	0DDh, 84h,0C3h, 53h, 85h,0C3h
		db	0E0h, 87h,0C3h, 53h, 89h,0C3h
		db	 43h,0DDh, 84h,0C3h,0C4h, 43h
		db	0C2h, 40h, 51h, 40h, 41h, 50h
		db	 81h,0C3h,0C4h,0DDh, 84h,0C3h
		db	 53h, 85h,0C3h,0C4h, 87h,0C3h
		db	0C4h, 01h, 1Dh, 89h,0C3h,0DDh
		db	 43h, 84h,0C3h,0C4h, 43h, 8Eh
		db	0C3h, 43h, 84h,0C3h, 53h, 85h
		db	0C3h,0C4h, 87h,0C3h,0C4h,0DDh
		db	0C4h, 89h,0C3h, 53h, 84h,0C3h
		db	0C4h, 43h, 87h,0C3h, 43h, 84h
		db	0C3h, 43h, 84h,0C3h, 53h, 85h
		db	0C3h, 43h,0E0h, 85h,0C3h, 53h
		db	 89h,0C3h, 53h, 84h,0C3h,0C4h
		db	0C4h,0DDh, 87h,0C3h, 43h, 84h
		db	0C3h, 43h, 84h,0C3h, 43h,0DDh
		db	 85h,0C3h, 53h, 85h,0C3h,0C4h
		db	 8Bh,0C3h,0C4h,0DDh,0C4h, 84h
		db	0C3h,0C4h, 43h, 87h,0C3h,0E0h
		db	0C4h, 84h,0C3h,0C4h,0DDh, 84h
		db	0C3h, 53h, 85h,0C3h, 53h, 85h
		db	0C3h,0C4h, 8Bh,0C3h,0C4h, 86h
		db	0C3h,0C4h, 43h, 8Eh,0C3h, 43h
		db	 84h,0C3h, 53h, 85h,0C3h, 53h
		db	 85h,0C3h,0C4h, 40h, 71h, 40h
		db	0C2h, 81h,0C3h,0C4h, 86h,0C3h
		db	0C4h, 43h, 8Eh,0C3h, 43h, 84h
		db	0C3h, 53h, 85h,0C3h,0C4h,0DDh
		db	0C4h, 85h,0C3h, 8Ch,0C3h,0C4h
		db	 86h,0C3h,0C4h, 43h, 8Eh,0C3h
		db	 43h, 84h,0C3h,0C4h, 87h,0C3h
		db	 53h, 85h,0C3h, 85h,0C3h,0C5h
		db	0C4h, 8Ch,0C3h,0C4h, 43h, 8Eh
		db	0C3h, 43h, 84h,0C3h,0C4h, 87h
		db	0C3h, 53h, 85h,0C5h, 85h,0C3h
		db	 43h, 8Ch,0C3h,0C4h, 43h, 8Eh
		db	0C3h, 43h, 84h,0C3h, 53h, 85h
		db	0C3h, 53h, 8Bh,0C3h, 43h, 8Ch
		db	0C3h,0C4h, 43h, 8Eh,0C3h, 43h
		db	 84h,0C3h, 53h, 85h,0C3h, 53h
		db	 8Bh,0C3h, 43h, 8Ch,0C3h,0C4h
		db	 43h, 8Eh,0C3h, 43h, 84h,0C3h
		db	 53h, 85h,0C3h,0DDh, 43h, 8Bh
		db	0C3h, 43h, 8Ch,0C3h,0C4h, 43h
		db	 8Eh,0C3h,0DDh,0C4h, 84h,0C3h
		db	 53h, 85h,0C3h, 53h, 8Bh,0C3h
		db	 43h, 8Ch,0C3h,0C4h, 43h, 8Eh
		db	0C3h, 43h, 84h,0C3h,0E0h, 43h
		db	 85h,0C3h, 53h, 8Bh,0C3h, 43h
		db	 8Ch,0C3h,0C4h, 43h, 87h,0C3h
		db	 96h,0C3h, 53h, 8Bh,0C3h, 43h
		db	 8Ch,0C3h,0DDh, 43h, 87h,0C3h
		db	 40h, 41h, 50h,0C2h, 60h, 51h
		db	 60h, 41h, 81h,0C3h, 53h, 8Bh
		db	0C3h,0C4h,0DDh, 8Ch,0C3h,0C4h
		db	 43h, 87h,0C3h, 96h,0C3h, 53h
		db	 8Bh,0C3h, 43h, 8Ch,0C3h,0C4h
		db	0DDh,0C4h, 87h,0C3h, 53h, 8Ah
		db	0C3h, 53h, 85h,0C3h, 53h, 8Bh
		db	0C3h, 43h, 8Ch,0C3h,0C4h, 43h
		db	 87h,0C3h, 53h, 8Ah,0C3h, 53h
		db	 85h,0C3h, 53h, 8Bh,0C3h, 43h
		db	 8Ch,0C3h,0C4h, 89h,0C3h, 53h
		db	 8Ah,0C3h, 53h, 85h,0C3h, 53h
		db	 8Bh,0C3h, 43h, 8Ch,0C3h,0C4h
		db	 89h,0C3h, 53h, 8Ah,0C3h, 53h
		db	 85h,0C3h, 53h, 8Bh,0C3h, 43h
		db	 8Ch,0C3h,0C4h, 43h, 87h,0C3h
		db	0C4h,0DDh,0C4h, 8Ah,0C3h, 53h
		db	 85h,0C3h, 43h,0DDh, 8Bh,0C3h
		db	 43h, 8Ch,0C3h,0C4h, 43h, 87h
		db	0C3h, 53h, 8Ah,0C3h, 53h, 85h
		db	0C3h, 53h, 8Bh,0C3h, 43h, 8Ch
		db	0C3h,0C4h, 43h, 87h,0C3h,0C4h
		db	 8Ch,0C3h, 01h, 20h,0C4h, 85h
		db	0C3h, 53h, 8Bh,0C3h, 43h, 8Ch
		db	0C3h,0C4h, 43h, 87h,0C3h,0C4h
		db	 95h,0C3h, 53h, 8Bh,0C3h, 43h
		db	 8Ch,0C3h,0C4h, 43h, 87h,0C3h
		db	0C4h, 95h,0C3h, 53h, 85h,0C3h
		db	 85h,0C3h, 43h, 8Ch,0C3h,0C4h
		db	 43h, 87h,0C3h,0C4h, 95h,0C3h
		db	 53h, 85h,0C3h, 85h,0C5h, 43h
		db	 8Ch,0C3h,0DDh, 43h, 9Eh,0C3h
		db	 53h, 85h,0C3h,0C4h, 8Bh,0C5h
		db	0C4h, 86h,0C3h,0C4h,0DDh,0C4h
		db	 9Eh,0C3h, 53h, 85h,0C3h,0C4h
		db	 8Bh,0C3h,0C4h, 86h,0C3h,0C4h
		db	 43h, 9Eh,0C3h, 53h, 85h,0C3h
		db	0C4h, 8Bh,0C3h, 43h, 85h,0C3h
		db	0C4h,0C5h,0C4h, 92h,0D9h,0C4h
		db	 8Ah,0C3h,0C4h,0E0h,0C4h, 85h
		db	0C3h,0C4h, 8Bh,0C3h, 43h, 85h
		db	0C3h,0C4h, 93h,0D9h,0C8h,0C4h
		db	0C7h, 92h,0C3h, 73h, 87h,0C3h
		db	 43h, 87h, 70h, 51h,0C1h,0C2h
		db	 88h,0D9h, 48h, 43h,0C7h,0CAh
		db	 40h,0C2h, 50h, 41h, 50h,0C2h
		db	 50h, 81h,0C3h, 63h,0DDh, 87h
		db	0C3h, 43h,0C2h, 40h, 61h, 91h
		db	0D9h,0C9h, 47h,0C4h, 49h, 4Ah
		db	 8Fh,0C3h, 73h, 87h,0C3h, 43h
		db	 87h,0C5h,0C4h, 8Eh,0D9h, 58h
		db	0C8h,0C4h,0C7h,0C9h, 49h, 86h
		db	0C3h,0C4h,0E0h,0C4h, 85h,0C3h
		db	 73h, 87h,0C3h,0C4h,0DDh, 85h
		db	0C3h,0C4h, 43h, 8Dh,0D9h,0CCh
		db	0C9h,0C8h,0C7h,0C8h,0C4h, 46h
		db	0C9h,0CAh,0CBh, 85h,0C3h, 53h
		db	 85h,0C3h, 73h, 87h,0C3h, 43h
		db	 85h,0C3h,0C4h, 43h, 8Ch,0D9h
		db	0CCh, 48h, 57h,0C4h,0DDh,0C7h
		db	 48h,0CAh,0CBh, 84h,0C3h, 63h
		db	0E0h, 63h,0DDh, 63h, 87h,0C3h
		db	 43h, 85h,0C3h,0C4h, 43h,0CBh
		db	 8Ah,0D9h,0CCh, 68h,0C8h,0C7h
		db	0C4h,0C7h, 48h,0CAh, 81h,0CBh
		db	 84h,0C3h, 0Dh, 04h, 87h,0C3h
		db	0C4h,0DDh, 85h,0C3h,0C4h,0C4h
		db	0C7h,0CAh, 8Dh,0C8h,0C4h,0C8h
		db	 43h,0C7h, 48h, 49h, 86h,0C3h
		db	 0Dh, 04h, 87h,0C3h, 43h, 85h
		db	0C3h,0C4h,0CAh,0C9h,0CAh,0CBh
		db	 8Ch,0C3h, 63h, 46h, 48h,0CAh
		db	 81h,0CBh, 84h,0C3h, 05h, 04h
		db	0E0h, 06h, 04h, 87h,0C3h, 43h
		db	 85h,0C3h,0C4h,0C7h,0C9h,0CBh
		db	0CAh,0CBh, 8Eh,0C3h, 43h, 46h
		db	 49h, 86h,0C3h, 43h,0DDh, 85h
		db	0C3h, 73h, 87h,0C3h, 07h, 04h
		db	0CAh, 68h,0CAh,0CBh, 8Dh,0C3h
		db	 63h, 88h,0C3h, 43h,0DDh, 85h
		db	0C3h, 53h, 89h,0C3h, 07h, 04h
		db	0C7h,0C8h,0C7h,0C9h,0CAh, 8Fh
		db	0C3h,0C4h,0DDh, 43h, 88h,0C3h
		db	 53h, 85h,0C3h, 53h, 89h,0C3h
		db	 06h, 04h, 81h,0C9h,0C9h, 49h
		db	0CBh, 8Fh,0C3h, 63h, 88h,0C3h
		db	 53h, 85h,0C3h,0C4h,0DDh, 53h
		db	 87h,0C3h, 06h, 04h, 81h,0C9h
		db	0CAh, 4Ah, 90h,0C3h, 63h, 88h
		db	0C3h,0DDh, 43h, 85h,0C3h, 73h
		db	 87h,0C3h, 43h,0DDh, 43h,0C5h
		db	0CAh,0C8h,0C7h, 48h,0CAh, 90h
		db	0C3h, 63h, 88h,0C3h, 53h, 85h
		db	0C3h, 63h,0DDh, 87h,0C3h, 43h
		db	0E0h,0C4h, 44h,0C7h,0C8h,0C9h
		db	0C9h, 47h,0C7h, 40h,0C2h,0C1h
		db	0C2h,0C1h, 89h,0C3h, 63h, 88h
		db	0C3h, 53h, 85h,0C3h, 73h, 87h
		db	0C3h, 53h, 44h,0C4h,0CAh, 48h
		db	 68h,0CAh,0CBh, 8Dh,0C3h, 53h
		db	0DDh, 88h,0C3h, 53h, 85h,0C3h
		db	 73h, 87h,0C3h, 43h, 44h,0C4h
		db	0C5h,0C7h, 48h, 05h, 09h,0CAh
		db	 8Ch,0C3h, 43h, 8Ah,0C3h,0DDh
		db	 43h, 85h,0C3h, 73h, 87h,0C3h
		db	0C4h, 44h,0C4h,0C5h,0C4h,0C7h
		db	0C8h,0C9h, 58h,0C8h,0C7h, 48h
		db	0C8h,0C4h, 8Ah,0C3h, 43h, 8Ah
		db	0C3h, 53h, 85h,0C3h, 73h, 87h
		db	0C3h,0C5h, 73h,0C7h, 47h, 68h
		db	0CAh,0CBh,0CDh,0C8h, 43h, 89h
		db	0C3h, 63h, 88h,0C3h, 53h, 85h
		db	0C3h, 73h, 87h,0C3h, 53h,0DDh
		db	 43h, 46h,0C8h, 48h,0CAh,0CBh
		db	 8Fh,0C3h, 63h, 88h,0C3h, 53h
		db	 85h,0C3h, 73h, 87h,0C3h, 05h
		db	 04h, 46h,0C9h, 93h,0C3h, 63h
		db	 88h,0C3h, 53h, 85h,0C3h, 73h
		db	 87h,0C3h, 05h, 04h,0C7h, 82h
		db	0C1h, 41h, 40h,0C2h, 40h, 8Bh
		db	0C3h,0C4h,0DDh, 43h, 88h,0C3h
		db	 53h, 87h,0C3h, 53h, 87h,0C3h
		db	 05h, 04h, 40h,0C2h, 93h,0C3h
		db	 63h, 88h,0C3h, 53h, 87h,0C3h
		db	 53h, 87h,0C3h, 05h, 04h, 83h
		db	 84h,0C3h,0C4h, 8Dh,0C3h, 63h
		db	 88h,0C3h, 53h, 87h,0C3h,0C4h
		db	0DDh,0C4h, 87h,0C3h,0C4h,0E0h
		db	 63h, 83h, 84h,0C3h,0C4h, 8Dh
		db	0C3h, 43h,0DDh,0C4h, 88h,0C3h
		db	 43h,0DDh, 87h,0C3h, 53h, 8Bh
		db	0C3h, 43h, 83h, 84h,0C3h,0C4h
		db	 8Dh,0C3h
		db	63h
data_5		dw	0C388h, 8753h, 53C3h	; Data table (indexed access)
		dw	4160h
		db	 40h,0C2h,0C1h, 81h,0C3h, 43h
		db	 83h, 84h,0C3h,0C4h, 8Dh,0C3h
		db	 63h, 88h,0C3h, 53h, 87h,0C3h
		db	 53h, 8Bh,0C3h, 43h, 83h, 84h
		db	0C3h,0C4h, 8Dh,0C3h, 63h, 88h
		db	0C3h, 53h, 87h,0C3h, 53h, 8Bh
		db	0C3h, 43h, 83h, 84h,0C3h,0DDh
		db	 85h,0C3h, 43h, 85h,0C3h,0E0h
		db	 43h,0E0h, 88h,0C3h, 53h, 87h
		db	0C3h, 53h, 8Bh,0C3h,0C4h,0DDh
		db	 83h, 84h,0C3h,0DDh, 85h,0C3h
		db	 43h, 92h,0C3h, 53h, 87h,0C3h
		db	 53h, 8Bh,0C3h, 43h, 83h, 84h
		db	0C3h, 43h, 84h,0C3h, 43h, 40h
		db	0C2h,0C1h, 07h, 02h, 40h, 51h
		db	 81h,0C3h,0DDh, 43h, 87h,0C3h
		db	 53h, 8Bh,0C3h, 43h, 83h, 84h
		db	0C3h, 43h, 84h,0C3h, 43h, 92h
		db	0C3h, 53h, 87h,0C3h, 53h, 8Bh
		db	0C3h, 43h, 83h, 85h,0C3h, 53h
		db	 82h,0C3h, 43h, 85h,0C3h,0E0h
		db	 43h,0E0h, 88h,0C3h,0C4h,0DDh
		db	0C4h, 87h,0C3h, 53h, 8Bh,0C3h
		db	 43h, 83h, 85h,0C3h, 53h, 8Ah
		db	0C3h, 63h, 88h,0C3h, 53h, 87h
		db	0C3h, 53h, 8Bh,0C3h, 43h, 83h
		db	 85h,0C3h, 53h, 8Ah,0C3h, 63h
		db	 88h,0C3h, 53h, 87h,0C3h, 53h
		db	 8Bh,0C3h, 43h, 83h, 85h,0C3h
		db	 53h, 8Ah,0C3h, 43h,0DDh,0C4h
		db	 88h,0C3h,0C4h, 89h,0C3h,0DDh
		db	 43h, 8Bh,0C3h, 01h, 1Dh, 83h
		db	 85h,0C3h, 43h,0DDh, 8Ah,0C3h
		db	 63h, 88h,0C3h,0C4h, 89h,0C3h
		db	0DDh, 43h, 8Bh,0C3h, 43h, 83h
		db	 85h,0C3h, 53h, 8Ah,0C3h, 63h
		db	 88h,0C3h, 53h, 87h,0C3h,0DDh
		db	 43h, 87h,0C3h,0E0h, 73h, 83h
		db	 85h,0C3h, 53h, 8Ah,0C3h, 63h
		db	 88h,0C3h,0DDh, 43h, 87h,0C3h
		db	 53h, 87h,0C3h, 05h, 04h, 83h
		db	 85h,0C3h, 53h, 8Ah,0C3h, 63h
		db	 88h,0C3h, 53h, 87h,0C3h, 53h
		db	 87h,0C3h, 05h, 04h, 83h, 85h
		db	0C3h, 73h,0E0h, 0Bh, 04h, 88h
		db	0C3h, 53h, 87h,0C3h, 53h, 87h
		db	0C3h, 05h, 04h, 83h, 85h,0C3h
		db	 10h, 04h,0DDh, 88h,0C3h, 53h
		db	 87h,0C3h, 53h, 87h,0C3h,0C4h
		db	0E0h, 63h, 83h, 85h,0C3h, 06h
		db	 04h, 01h, 20h, 08h, 04h, 88h
		db	0C3h, 53h, 87h,0C3h, 53h, 91h
		db	0C1h,0C2h, 40h, 81h,0C3h, 53h
		db	 86h,0C3h, 06h, 04h,0DDh, 88h
		db	0C3h, 53h, 87h,0C3h, 53h, 41h
		db	0C1h, 41h, 60h,0C2h, 40h, 41h
		db	0C1h,0C2h,0C1h, 85h,0C3h, 53h
		db	 86h,0C3h, 0Dh, 04h,0E0h, 73h
		db	 87h,0C3h, 43h,0DDh, 91h, 85h
		db	0C3h, 53h, 86h,0C3h, 13h, 04h
		db	 87h,0C3h, 53h, 87h,0C3h,0C4h
		db	0E0h, 63h, 83h, 85h,0C3h,0C4h
		db	0DDh,0C4h, 86h,0C3h, 08h, 04h
		db	0E0h, 09h, 04h, 87h,0C3h, 53h
		db	 87h,0C3h, 05h, 04h, 83h, 85h
		db	0C3h, 53h, 86h,0C3h, 08h, 04h
		db	0E0h, 08h, 04h,0DDh, 87h,0C3h
		db	 53h, 87h,0C3h, 05h, 04h, 83h
		db	 85h,0C3h, 53h, 86h,0C3h, 63h
		db	 97h,0C3h, 53h, 87h,0C3h, 05h
		db	 04h, 83h, 85h,0C3h, 53h, 86h
		db	0C3h, 63h, 97h,0C3h,0C4h, 89h
		db	0C3h,0E0h, 73h, 83h, 85h,0C3h
		db	 43h,0DDh, 86h,0C3h, 53h,0DDh
		db	 97h,0C3h,0C4h, 8Dh,0C3h, 43h
		db	 83h, 85h,0C3h, 43h,0DDh, 86h
		db	0C3h, 63h, 85h,0C3h, 53h, 85h
		db	0C3h,0C4h, 87h,0C3h, 53h, 8Bh
		db	0C3h, 43h, 83h, 85h,0C3h, 53h
		db	 86h,0C3h, 63h, 85h,0C3h, 53h
		db	 85h,0C3h,0C4h, 87h,0C3h,0DDh
		db	 43h, 8Bh,0C3h, 01h, 1Dh, 83h
		db	 85h,0C3h, 53h, 86h,0C3h,0C4h
		db	0E0h, 43h, 85h,0C3h, 53h, 85h
		db	0C3h,0C4h, 87h,0C3h, 53h, 8Bh
		db	0C3h, 43h, 83h, 85h,0C3h, 53h
		db	 90h,0C3h, 43h,0DDh, 85h,0C3h
		db	0DDh, 87h,0C3h, 53h, 8Bh,0C3h
		db	 43h, 83h, 85h,0C3h, 53h, 40h
		db	0C2h, 40h,0C2h, 40h, 41h,0C1h
		db	0C2h, 40h, 81h,0C3h, 63h, 85h
		db	0C3h,0C4h, 87h,0C3h, 53h, 8Bh
		db	0C3h, 43h, 83h, 85h,0C3h, 53h
		db	 8Fh,0C3h,0DDh, 53h, 85h,0C3h
		db	0C4h, 87h,0C3h,0C4h,0DDh,0C4h
		db	 8Bh,0C3h, 43h, 83h, 85h,0C3h
		db	 53h, 85h,0C3h, 53h, 86h,0C3h
		db	 63h, 85h,0C3h,0C4h, 87h,0C3h
		db	 53h, 8Bh,0C3h, 43h, 83h, 85h
		db	0C3h, 53h, 85h,0C3h, 53h, 86h
		db	0C3h, 63h, 85h,0C3h,0C4h, 87h
		db	0C3h, 53h, 8Bh,0C3h,0C4h,0DDh
		db	 83h, 53h,0DDh, 53h,0C5h,0DDh
		db	 85h,0C3h, 53h, 86h,0C3h, 63h
		db	 85h,0C3h,0C4h, 87h,0C3h, 53h
		db	 8Bh,0C3h, 73h, 73h, 44h, 73h
		db	0E0h, 63h,0DDh, 86h,0C3h, 63h
		db	 85h,0C3h,0DDh, 87h,0C3h, 43h
		db	0DDh, 8Bh,0C3h, 73h, 63h, 44h
		db	 0Bh, 04h, 86h,0C3h, 63h, 85h
		db	0C3h,0C4h, 87h,0C3h, 53h, 8Bh
		db	0C3h, 73h,0C4h,0DDh,0C4h, 44h
		db	 0Dh, 04h,0E0h, 08h, 04h, 85h
		db	0C3h,0C4h, 89h,0C3h,0C4h, 8Dh
		db	0C3h, 53h,0C5h,0C4h, 44h, 08h
		db	 04h,0E0h, 11h, 04h,0E0h, 53h
		db	 89h,0C3h,0C4h, 50h, 41h, 50h
		db	 41h, 40h, 81h,0C3h, 53h,0C4h
		db	0C5h, 63h,0DDh, 53h, 86h,0C3h
		db	 73h,0DDh, 0Ch, 04h, 89h,0C3h
		db	0C4h, 8Dh,0C3h, 43h,0C5h,0C5h
		db	 08h, 04h, 86h,0C3h, 08h, 04h
		db	0DDh, 53h,0E0h, 73h, 89h,0C3h
		db	0C4h, 85h,0C3h, 43h, 85h,0C3h
		db	0C4h,0C5h,0C4h, 09h, 04h, 86h
		db	0C3h, 63h, 85h,0C3h, 43h, 90h
		db	0C3h,0C4h, 85h,0C3h, 43h, 85h
		db	0C3h,0C5h, 43h,0C4h, 01h, 1Dh
		db	 06h, 04h, 86h,0C3h, 43h,0DDh
		db	0C4h, 85h,0C3h, 43h, 90h,0C3h
		db	0C4h, 85h,0C3h,0C5h,0DDh, 85h
		db	0C3h, 53h, 07h, 04h,0DDh,0C4h
		db	 86h,0C3h, 63h, 85h,0C3h, 43h
		db	 90h,0C3h,0DDh, 8Dh,0C3h, 53h
		db	 08h, 04h,0DDh, 86h,0C3h, 63h
		db	 85h,0C3h, 01h, 1Dh, 85h,0C3h
		db	0C4h, 98h,0C3h, 53h, 09h, 04h
		db	 86h,0C3h, 63h, 85h,0C3h, 43h
		db	 85h,0C3h,0C4h, 98h,0C3h, 53h
		db	 07h, 04h, 88h,0C3h, 63h, 85h
		db	0C3h, 43h, 85h,0C3h,0C4h, 98h
		db	0C3h, 53h, 07h, 04h, 88h,0C3h
		db	0C4h, 88h,0C3h, 43h, 85h,0C3h
		db	0C4h, 50h,0C2h, 40h, 41h, 40h
		db	0C2h, 40h, 8Bh,0C3h, 53h, 43h
		db	 01h, 20h, 05h, 04h, 86h,0C3h
		db	0C4h, 87h,0C3h, 53h, 85h,0C3h
		db	0C4h, 98h,0C3h,0C4h,0E0h,0C4h
		db	 85h,0C3h, 63h, 86h,0C3h,0C4h
		db	 87h,0C3h, 53h, 85h,0C3h,0C4h
		db	 86h,0C3h, 43h,0E0h, 73h, 8Dh
		db	 85h,0C3h, 53h,0DDh, 86h,0C3h
		db	0DDh, 87h,0C3h, 53h, 85h,0C3h
		db	0DDh, 86h,0C3h, 73h,0DDh, 43h
		db	 8Dh, 85h,0C3h, 63h, 8Fh,0C3h
		db	0C4h,0DDh,0C4h, 85h,0C3h,0DDh
		db	 86h,0C3h, 07h, 04h, 8Dh, 85h
		db	0C3h, 63h, 50h, 51h,0C1h,0C2h
		db	 50h,0C2h, 40h, 81h,0C3h, 53h
		db	 85h,0C3h,0C4h, 86h,0C3h, 07h
		db	 04h, 8Dh, 85h,0C3h, 63h, 8Fh
		db	0C3h, 53h, 85h,0C3h,0C4h, 86h
		db	0C3h, 73h,0E0h, 43h, 8Dh, 85h
		db	0C3h, 63h, 87h,0C3h,0C4h, 86h
		db	0C3h,0E0h, 43h, 85h,0C3h, 87h
		db	0C3h, 63h, 85h,0C3h, 43h, 89h
		db	 85h,0C3h, 73h, 86h,0C3h,0DDh
		db	 8Fh,0C3h, 87h,0C3h, 63h, 85h
		db	0C3h, 43h, 89h, 85h,0C3h, 05h
		db	 04h, 85h,0C3h,0C4h, 50h,0C2h
		db	 60h,0C2h, 40h, 51h, 81h,0C3h
		db	 43h, 85h,0C3h,0DDh, 53h, 85h
		db	0C3h, 43h, 89h, 85h,0C3h,0C4h
		db	0DDh, 63h,0E0h, 05h, 04h, 8Fh
		db	0C3h, 43h, 85h,0C3h, 63h, 85h
		db	0C3h, 43h, 89h, 85h,0C3h, 0Fh
		db	 04h, 83h,0C3h, 63h, 83h,0C3h
		db	 63h, 01h, 20h, 06h, 04h, 85h
		db	0C3h,0C4h,0DDh, 89h, 85h,0C3h
		db	 08h, 04h,0DDh, 63h,0DDh, 0Ah
		db	 04h,0E0h, 0Dh, 04h, 85h,0C3h
		db	 43h, 89h, 85h,0C3h, 11h, 04h
		db	0E0h, 0Eh, 04h, 82h

locloop_4:
		push	bx
;*		ffree	st(4)			; Set tag to empty
		db	0DDh,0C4h		;  Fixup - byte match
		test	ax,bx
		inc	bx
		mov	data_7[di],ax
		add	al,83h
		retn
		db	 43h, 01h, 20h, 83h,0C3h, 63h
		db	 01h, 20h, 82h, 73h, 85h,0C5h
		db	 43h, 89h, 85h,0C3h, 07h, 04h
		db	0E0h, 53h,0DDh, 8Fh,0C3h,0C4h
		db	 86h,0C3h, 63h, 91h,0C1h,0C2h
		db	 40h, 81h,0C3h, 05h, 04h, 85h
		db	0C3h,0C4h, 50h,0C2h, 60h,0C2h
		db	 40h, 51h, 81h,0C3h,0C4h, 86h
		db	0C3h, 53h,0C5h,0C1h, 51h, 60h
		db	 41h, 50h,0C2h, 40h,0C2h, 85h
		db	0C3h, 73h, 86h,0C3h,0C4h, 8Fh
		db	0C3h,0C4h, 86h,0C3h, 43h,0C5h
		db	0C4h, 91h, 85h,0C3h, 63h, 87h
		db	0C3h,0C4h, 86h,0C3h, 53h, 85h
		db	0C3h,0C4h, 86h,0C3h, 63h, 86h
		db	0C3h, 73h, 85h, 85h,0C3h, 63h
		db	 8Fh,0C3h, 53h, 85h,0C3h,0C4h
		db	 86h,0C3h, 63h, 86h,0C3h, 73h
		db	 85h, 85h,0C3h,0C4h,0DDh, 43h
		db	 50h, 41h, 40h,0C2h, 50h,0C2h
		db	 40h, 81h,0C3h,0DDh, 43h, 85h
		db	0C3h,0DDh, 86h,0C3h, 43h, 88h
		db	0C3h,0C4h,0DDh, 53h, 85h, 85h
		db	0C3h, 63h, 8Fh,0C3h, 43h,0DDh
		db	 85h,0C3h,0C4h, 86h,0C3h, 43h
		db	 88h,0C3h, 53h,0DDh,0C4h, 85h
		db	 85h,0C3h, 63h, 86h,0C3h,0C4h
		db	 87h,0C3h, 53h, 85h,0C3h,0C4h
		db	 86h,0C3h, 63h, 86h,0C3h, 73h
		db	 85h, 85h,0C3h, 63h, 86h,0C3h
		db	0C4h, 87h,0C3h, 53h, 85h,0C3h
		db	0C4h, 86h,0C3h, 53h,0DDh, 86h
		db	0C3h, 73h, 85h, 85h,0C3h, 63h
		db	 86h,0C3h,0DDh, 87h,0C3h, 53h
		db	 85h,0C3h,0C4h, 86h,0C3h, 63h
		db	 86h,0C3h, 73h, 85h, 85h,0C3h
		db	 43h, 88h,0C3h,0C4h, 88h,0C3h
		db	 43h, 85h,0C3h,0DDh, 86h,0C3h
		db	 53h,0C5h, 86h,0C3h, 53h, 87h
		db	 85h,0C3h, 43h, 88h,0C3h, 63h
		db	 85h,0C3h, 43h, 85h,0C3h,0C4h
		db	 86h,0C3h, 43h,0C5h,0C4h, 86h
		db	0C3h, 53h, 87h, 85h,0C3h, 53h
		db	0DDh, 86h,0C3h, 43h,0DDh,0C4h
		db	 85h,0C3h, 43h, 85h,0C3h,0C4h
		db	 86h,0C3h,0C4h,0DDh, 43h, 86h
		db	0C3h,0DDh, 63h, 85h, 85h,0C3h
		db	 63h, 86h,0C3h, 63h, 85h,0C3h
		db	 43h, 85h,0C3h,0C4h, 86h,0C3h
		db	 63h, 86h,0C3h, 73h, 85h, 85h
		db	0C3h, 63h, 86h,0C3h, 63h, 85h
		db	0C3h,0C4h,0DDh, 8Dh,0C3h, 53h
		db	0C5h, 86h,0C3h, 73h, 85h, 85h
		db	0C3h, 63h, 86h,0C3h, 53h,0DDh
		db	 85h,0C3h, 43h, 8Dh,0C3h, 43h
		db	 44h, 86h,0C3h, 63h,0DDh, 85h
		db	 85h,0C3h, 63h, 86h,0C3h, 63h
		db	 85h,0C3h, 43h, 8Dh,0C3h,0C4h
		db	 44h,0C4h, 86h,0C3h, 73h, 85h
		db	 85h,0C3h, 63h, 86h,0C3h, 0Eh
		db	 04h,0E0h, 53h, 86h,0C3h,0C5h
		db	 53h, 86h,0C3h, 73h, 85h, 85h
		db	0C3h, 63h, 86h,0C3h, 12h, 04h
		db	 86h,0C3h, 53h,0C5h, 86h,0C3h
		db	 73h, 85h, 85h,0C3h, 73h,0E0h
		db	 0Ch, 04h,0E0h, 63h,0E0h, 53h
		db	0DDh,0C4h, 86h,0C3h, 43h,0C5h
		db	0C4h, 86h,0C3h, 43h,0DDh, 43h
		db	 85h, 85h,0C3h, 09h, 04h,0DDh
		db	 43h, 01h, 20h, 53h,0E0h
data_6		dw	8563h, 0C4C3h		; Data table (indexed access)
		db	 86h,0C3h, 63h, 86h,0C3h, 73h
		db	 85h, 85h,0C3h, 0Bh, 04h, 87h
		db	0C3h, 53h, 85h,0C3h,0C4h, 86h
		db	0C3h,0E0h, 43h,0E0h, 86h,0C3h
		db	0C4h,0DDh, 53h, 85h, 85h,0C3h
		db	 53h,0E0h, 53h,0E0h, 63h, 87h
		db	0C3h, 53h, 85h,0C3h,0C4h, 91h
		db	0C3h, 73h, 85h, 85h,0C3h, 53h
		db	 85h,0C3h, 53h, 87h,0C3h, 53h
		db	 85h,0C3h,0C4h, 91h,0C3h, 73h
		db	 85h, 85h,0C3h, 53h, 85h,0C3h
		db	0DDh, 43h, 87h,0C3h, 53h, 85h
		db	0C3h,0C4h, 91h,0C3h, 43h, 88h
		db	 85h,0C3h, 53h, 85h,0C3h, 53h
		db	 87h,0C3h, 53h, 85h,0C3h,0C4h
		db	 86h,0C3h,0C4h,0E0h, 43h, 86h
		db	0C3h, 43h, 88h, 85h,0C3h, 53h
		db	 90h,0C3h,0DDh, 43h, 85h,0C3h
		db	0C4h, 86h,0C3h, 63h, 86h,0C3h
		db	 43h, 88h, 85h,0C3h, 53h, 40h
		db	0C2h, 70h, 41h,0C1h,0C2h, 40h
		db	 82h,0C3h, 53h, 85h,0C3h,0C4h
		db	 86h,0C3h, 63h, 86h,0C3h, 43h
		db	 88h, 85h,0C3h,0DDh, 43h, 90h
		db	0C3h, 53h, 85h,0C3h,0C4h, 86h
		db	0E0h, 53h,0DDh, 86h,0C3h, 01h
		db	 1Dh, 88h, 85h,0C3h, 53h, 86h
		db	0C3h, 63h, 85h,0C3h, 53h, 85h
		db	0C3h,0DDh, 87h,0C3h, 53h, 86h
		db	0C3h, 43h, 88h, 85h,0C3h, 53h
		db	 86h,0C3h, 63h, 85h,0C3h, 53h
		db	 85h,0C3h,0C4h, 87h,0C3h,0C4h
		db	0C7h,0C8h,0C4h, 85h,0E0h, 43h
		db	 88h, 85h,0C3h, 53h, 86h,0C3h
		db	 63h, 85h,0C3h, 43h,0DDh, 85h
		db	0C3h,0C4h, 87h,0C3h,0C4h,0C9h
		db	 43h, 90h, 85h,0C3h,0C4h, 88h
		db	0C3h, 63h, 97h,0C3h,0C7h,0C9h
		db	0C8h,0C4h,0C1h, 41h, 40h,0C2h
		db	0C1h, 89h, 85h,0C3h,0C4h, 88h
		db	0C3h, 53h,0DDh, 97h,0C3h,0CBh
		db	0C9h,0C8h,0C4h, 90h, 85h,0C3h
		db	 43h,0DDh, 86h,0C3h, 63h, 97h
		db	0CCh, 48h,0C8h,0C7h, 90h, 85h
		db	0C3h, 53h, 86h,0C3h,0DDh, 06h
		db	 04h, 54h, 08h, 04h, 86h,0D9h
		db	 58h, 49h,0CBh, 8Ah,0C3h,0E0h
		db	0C4h, 82h, 85h,0C3h, 53h, 86h
		db	0C3h, 06h, 04h, 54h, 73h,0C5h
		db	 63h, 85h,0D9h,0CCh, 58h, 49h
		db	0CBh, 8Ah,0C3h, 43h, 82h, 85h
		db	0C3h, 53h, 86h,0C3h, 05h, 04h
		db	 44h, 05h, 04h,0C5h, 63h,0DDh
		db	 84h,0D9h,0CCh, 68h,0CAh, 8Ch
		db	0C3h, 43h, 82h, 85h,0C3h, 53h
		db	 86h,0C3h, 73h,0C5h, 05h, 04h
		db	 44h,0C4h,0C5h, 63h, 84h,0CCh
		db	 68h,0CAh, 8Dh,0C3h,0C4h,0DDh
		db	 82h, 85h,0C3h, 53h, 86h,0C3h
		db	 0Ah, 04h, 44h,0C4h,0C5h, 73h
		db	 84h, 78h, 49h, 8Ch,0C3h, 43h
		db	 82h, 85h,0C3h, 53h,0E0h, 07h
		db	 04h,0E0h, 43h, 8Bh,0C3h, 53h
		db	 84h, 05h, 09h, 49h, 8Bh,0C3h
		db	 84h, 85h,0C3h, 0Bh, 04h, 8Eh
		db	0C3h, 53h, 84h, 05h, 09h, 49h
		db	0CBh, 8Ah,0C3h, 84h, 85h,0C3h
		db	0DDh, 05h, 04h,0E0h, 63h, 8Eh
		db	0C3h, 53h, 84h, 05h, 09h, 49h
		db	0CBh, 8Ah,0C3h, 43h, 82h, 85h
		db	0C3h, 63h, 96h,0C3h, 53h, 84h
		db	0CDh, 78h, 49h, 8Bh,0C3h, 43h
		db	 82h, 85h,0C3h, 63h, 96h,0C3h
		db	 53h, 85h, 78h, 49h, 8Bh,0C3h
		db	 43h, 82h, 85h,0C3h, 63h, 40h
		db	0C2h, 40h, 41h,0C1h,0C2h, 40h
		db	 8Bh,0C3h, 43h,0DDh, 85h,0CDh
		db	 68h,0CAh, 8Ch,0C3h, 01h, 20h
		db	 82h, 83h,0C3h, 05h, 04h, 96h
		db	0C3h, 53h, 86h,0CDh, 58h, 81h
		db	0C8h, 53h, 88h,0C3h,0C4h, 83h
		db	 83h,0C3h, 05h, 04h, 84h,0C3h
		db	0C4h, 90h,0C3h, 53h, 81h,0CEh
		db	 5Eh,0D0h, 81h, 68h, 63h, 88h
		db	0C3h,0C4h, 83h, 83h
data_7		dw	0DDC3h			; Data table (indexed access)
		db	 73h, 96h,0C3h,0C4h, 89h, 68h
		db	0C8h, 53h, 88h,0C3h,0C4h, 83h
		db	 83h,0C3h, 73h,0DDh, 85h,0C3h
		db	0E0h, 8Fh,0C3h,0C4h, 89h,0CDh
		db	 58h,0C8h, 53h, 88h,0C3h, 84h
		db	 81h,0C3h,0E0h, 06h, 04h, 85h
		db	0C3h, 43h, 8Eh,0C3h, 53h, 81h
		db	0D2h, 03h, 13h,0D4h, 81h, 58h
		db	0C8h, 53h, 88h,0C3h, 84h, 81h
		db	0C3h, 07h, 04h, 85h,0C3h,0C4h
		db	0DDh, 43h, 8Ch,0C3h, 53h, 88h
		db	 58h,0C8h, 43h, 8Eh, 81h,0C3h
		db	 07h, 04h, 85h,0C3h, 53h,0DDh
		db	 84h,0C3h,0C4h, 86h,0C3h, 01h
		db	 20h,0C4h, 88h,0CDh, 48h,0C8h
		db	0C4h, 8Fh, 81h,0C3h, 53h,0E0h
		db	 63h, 85h,0C3h, 63h, 84h,0C3h
		db	0C4h, 93h,0C9h,0C8h, 43h, 8Fh
		db	 53h, 85h,0C3h,0C4h, 85h,0C3h
		db	0C4h,0E0h, 86h,0C3h,0C4h, 93h
		db	 53h, 8Fh,0C3h, 53h, 85h,0C3h
		db	0E0h, 85h,0C3h,0C4h, 87h,0C3h
		db	0C4h, 93h,0C4h, 88h,0C3h,0C4h
		db	 87h,0C3h, 53h, 8Ch,0C3h,0E0h
		db	 87h,0C3h,0C4h, 86h,0C3h, 01h
		db	 20h,0C4h, 92h,0C3h,0C4h, 87h
		db	0C3h, 43h,0DDh, 41h,0C1h, 61h
		db	0C1h, 51h, 88h,0C3h, 53h, 86h
		db	0C3h,0E0h, 43h,0C1h,0C2h,0C1h
		db	 41h, 50h,0C2h, 40h, 87h,0C3h
		db	 43h, 86h,0C3h, 53h, 93h,0C3h
		db	 53h, 86h,0C3h, 53h, 92h,0C3h
		db	 43h, 86h,0C3h, 53h, 85h,0C3h
		db	0C4h,0E0h,0C4h, 8Ah,0C3h, 53h
		db	 86h,0C3h, 53h, 92h,0C3h, 43h
		db	 86h,0C3h, 53h, 85h,0C3h, 53h
		db	 8Ah,0C3h,0C4h,0DDh,0C4h, 86h
		db	0C3h, 53h, 81h,0CEh, 07h, 0Fh
		db	0D0h, 87h,0C3h, 43h, 86h,0C3h
		db	 53h, 85h,0C3h, 53h, 8Ah,0C3h
		db	 53h, 86h,0C3h, 53h, 92h,0C3h
		db	 43h, 86h,0C3h, 53h, 85h,0C3h
		db	 53h, 8Ah,0DDh, 53h, 86h,0C3h
		db	 53h, 92h,0C3h, 43h, 86h,0C3h
		db	 53h, 85h,0C3h, 43h,0DDh, 85h
		db	0C3h, 05h, 04h, 88h,0C3h, 43h
		db	0DDh, 81h,0D2h, 07h, 13h,0D4h
		db	 87h,0C3h, 43h, 86h,0C3h,0DDh
		db	 43h, 85h,0C3h, 43h,0DDh, 85h
		db	0C3h, 05h, 04h, 88h,0C3h, 53h
		db	 92h,0C3h,0C4h, 87h,0C3h, 53h
		db	 85h,0C3h, 53h, 85h,0C3h, 07h
		db	 04h, 86h,0C3h, 53h, 92h,0C3h
		db	 88h,0C3h, 53h, 85h,0C3h, 53h
		db	 85h,0C3h, 73h,0E0h, 43h, 86h
		db	0C3h, 53h, 92h,0C3h, 88h,0C3h
		db	 53h, 85h,0C3h,0DDh, 87h,0C3h
		db	0C4h, 8Dh,0C3h,0DDh, 43h, 40h
		db	 41h, 50h, 41h, 40h, 90h,0C3h
		db	 53h, 85h,0C3h,0C4h, 87h,0C3h
		db	0C4h, 8Dh,0C3h, 53h, 9Bh,0C3h
		db	 53h, 85h,0C3h, 53h, 85h,0C3h
		db	0DDh, 43h, 8Bh,0C3h, 53h, 9Bh
		db	0C3h, 53h, 85h,0C3h, 53h, 85h
		db	0C3h, 53h, 8Bh,0C3h, 53h, 9Bh
		db	0C3h,0C4h, 01h, 1Dh, 85h,0C3h
		db	 53h, 85h,0C3h, 53h, 8Bh,0C3h
		db	 53h, 9Bh,0C3h, 53h, 85h,0C3h
		db	 53h, 85h,0C3h,0C4h,0DDh,0C4h
		db	 8Bh,0C3h, 53h, 9Bh,0C3h, 53h
		db	 85h,0C3h, 53h, 85h,0C3h, 53h
		db	 8Bh,0E0h, 53h, 9Bh,0C3h, 53h
		db	 85h,0C3h, 53h,0B3h,0C3h, 53h
		db	 85h,0C3h, 43h,0DDh,0C2h
		db	'PqPapAPap'
		db	90h

locloop_5:
		retn
		db	 53h, 85h,0C3h, 53h,0B3h,0C3h
		db	 53h, 85h,0C3h, 63h,0E0h, 63h
		db	0E0h, 43h, 85h,0C3h,0E0h, 43h
		db	 97h,0C3h,0E0h, 88h,0C3h, 53h
		db	 85h,0C3h, 0Bh, 04h, 85h,0C3h
		db	 53h, 97h,0C3h,0C4h, 88h,0C3h
		db	 53h, 85h,0C3h, 53h,0C5h, 07h
		db	 04h, 85h,0C3h, 53h, 97h,0C3h
		db	 53h, 86h,0C3h, 53h, 85h,0C3h
		db	 43h,0C5h
data_8		dw	407h			; Data table (indexed access)
		db	0DDh, 85h,0C3h, 53h, 81h,0CEh
		db	 0Ch, 0Fh,0D0h, 87h,0C3h, 53h
		db	 86h,0C3h, 43h,0DDh, 85h,0C3h
		db	0C4h,0C5h, 63h,0E0h, 05h

locloop_6:
		add	al,0E0h
		push	es
		add	al,97h
		retn
		db	 53h, 86h,0C3h, 53h, 85h,0C3h
		db	 8Ah,0C3h, 08h, 04h,0DDh, 97h
		db	0C3h, 53h, 86h,0C3h, 53h, 85h
		db	0C3h, 8Ah,0C3h, 09h, 04h, 81h
		db	0D2h
		db	0Ch

locloop_8:
		adc	dx,sp
;*		xchg	ax,bx
		db	 87h,0C3h		;  Fixup - byte match
		loopnz	locloop_5		; Loop if zf=0, cx>0

		retn
		db	 53h, 85h,0C3h, 8Ah,0C3h, 63h
		db	0E0h, 73h, 97h,0C3h,0E0h, 88h
		db	0C3h,0C4h,0DDh,0C4h, 85h,0DDh
		db	 8Ah,0C3h,0C4h, 85h,0C3h, 53h
		db	0A1h,0C3h, 53h, 90h,0C3h,0C4h
		db	 85h,0C3h, 53h,0A1h,0C3h, 53h
		db	 90h,0C3h,0C4h, 85h,0C3h
		db	53h

locloop_9:
		mov	ax,ds:data_11e
		nop
		retn
		db	0DDh, 85h,0C3h,0C4h,0E0h,0C4h
		db	0A1h,0C3h, 53h, 90h,0C3h,0C4h
		db	0AAh,0C3h, 53h, 90h,0C3h,0C4h
		db	 40h, 51h, 60h, 05h, 02h, 60h
		db	0C2h, 40h,0C2h, 50h, 90h,0C3h
		db	 53h, 90h,0C3h,0DDh,0AAh,0C3h
		db	 53h, 90h,0C3h,0DDh, 88h,0C3h
		db	 73h,0E0h, 73h, 96h,0C3h, 53h
		db	 90h,0C3h,0DDh, 88h,0C3h, 0Ah
		db	 04h, 96h,0C3h, 53h, 85h,0C3h
		db	 94h,0C3h, 05h, 04h,0DDh, 53h
		db	0DDh, 96h,0C3h,0DDh, 43h, 85h
		db	0C3h, 94h,0C3h, 0Ah, 04h, 96h
		db	0C3h, 53h, 85h,0C3h, 94h,0C3h
		db	 43h,0E0h, 07h, 04h, 96h,0C3h
		db	 53h, 85h,0C3h, 94h,0C3h, 43h
		db	 85h,0C3h, 53h, 96h,0C3h, 43h
		db	0DDh, 85h,0C3h, 94h,0C3h, 43h
		db	 85h,0C3h, 53h, 8Ch,0C3h,0E0h
		db	 88h,0C3h, 53h, 85h,0C3h,0C8h
		db	0C7h, 92h,0C3h, 43h, 85h,0C3h
		db	 53h, 8Ch,0C3h,0C4h, 88h,0C3h
		db	 53h, 85h,0C3h, 43h, 92h,0C3h
		db	 43h, 85h,0C3h, 53h, 8Ch,0C3h
		db	0DDh,0E0h,0C4h, 86h,0C3h, 53h
		db	 85h,0C3h, 43h,0C7h, 40h, 51h
		db	 40h,0C2h, 60h, 41h, 40h, 81h
		db	0C3h, 43h, 85h,0C3h, 53h, 8Ch
		db	0C3h, 53h, 86h,0C3h, 53h, 85h
		db	0C3h,0C4h,0C7h,0CAh, 91h,0C3h
		db	0C4h,0DDh, 85h,0C3h, 53h, 8Ch
		db	0C3h, 53h, 86h,0C3h, 53h, 85h
		db	0C9h,0C8h,0C4h,0CAh, 84h,0C3h
		db	0DDh,0C7h, 84h,0C3h, 85h,0C3h
		db	 43h, 85h,0C3h, 53h, 8Ch,0C3h
		db	 53h, 86h,0C3h, 53h, 85h,0D8h
		db	0C9h,0C8h,0C7h,0CAh, 83h,0C3h
		db	 43h, 84h,0C3h,0C4h, 84h,0C3h
		db	 43h, 85h,0C3h, 53h, 8Ch,0C3h
		db	 53h, 86h,0C3h, 53h, 86h,0D8h
		db	 48h,0CAh, 83h,0C3h,0DDh,0C4h
		db	 84h,0C3h,0C4h, 84h,0E0h, 43h
		db	 85h,0C3h, 53h, 8Ch,0C3h, 53h
		db	 86h,0C3h, 53h, 87h,0D8h, 48h
		db	0CAh, 82h, 43h,0C7h, 84h,0C3h
		db	0C4h, 8Ch,0C3h, 53h, 8Ch,0C3h
		db	 53h, 86h,0C3h, 01h, 20h,0C4h
		db	 88h,0D8h, 48h, 49h, 43h,0CAh
		db	 84h,0C3h,0C7h, 8Ch,0C3h, 53h
		db	 8Ch,0C3h, 43h,0DDh, 86h,0C3h
		db	 8Ch,0D8h, 58h,0C8h,0C7h,0C9h
		db	0CBh, 83h,0C3h,0C7h, 8Ch,0C3h
		db	 53h, 8Ch,0C3h, 53h, 87h, 05h
		db	 01h, 51h,0C1h, 83h,0D8h, 48h
		db	0C8h,0C7h,0C9h,0CAh,0CBh, 82h
		db	0C3h,0CAh,0CBh, 8Bh,0C3h,0C4h
		db	0DDh,0C4h, 8Ch,0C3h, 53h, 06h
		db	 01h, 8Eh,0D8h,0C9h, 43h,0C7h
		db	0CAh,0CBh, 82h,0C3h,0C7h,0C9h
		db	0CBh, 8Ah,0C3h, 53h, 8Ch,0C3h
		db	 53h, 87h, 8Fh,0D8h,0C8h,0C4h
		db	0C7h,0C9h,0CAh, 82h,0C3h,0C9h
		db	 49h,0CBh, 89h,0C3h, 53h, 8Ch
		db	0C3h

locloop_10:
		db	0C4h,0DDh, 63h,0E0h, 83h, 90h
		db	0C4h,0C7h,0C9h,0CAh, 83h,0C3h
		db	 48h, 49h,0CBh, 88h,0C3h, 53h
		db	 8Ch,0C3h, 06h, 04h, 83h, 90h
		db	0C8h, 43h,0CAh,0CBh, 82h,0C3h
		db	0C7h, 58h,0CAh,0CBh, 87h,0C3h
		db	 53h, 8Ch,0C3h, 06h, 04h, 83h
		db	 90h,0E0h,0C4h,0C7h,0CBh, 83h
		db	 58h,0C7h,0CAh,0CBh, 88h,0C3h
		db	 53h, 8Ch,0C3h

locloop_11:
		inc	bx
		loopnz	locloop_10		; Loop if zf=0, cx>0

;*		fld	qword ptr [bp+di-7Dh]	; Push onto stack
		db	0DDh, 43h, 83h		;  Fixup - byte match
		nop
		retn
			                        ;* No entry point to code
		inc	bx
		test	bl,al
		db	 68h,0CAh,0CBh, 87h,0C3h, 53h
		db	 86h, 01h, 1Dh, 88h,0C3h, 53h
		db	 83h, 90h,0C3h, 43h, 85h,0D8h
		db	 58h,0C8h,0CAh, 4Ah, 85h,0C3h
		db	 53h, 86h, 01h, 1Dh, 88h,0C3h
		db	0C4h, 85h, 90h,0C3h, 43h, 86h
		db	0D8h,0C9h,0C8h, 46h,0C9h,0CAh
		db	 85h,0C3h, 53h, 86h, 01h, 1Dh
		db	 88h,0C3h,0C4h, 85h, 90h,0C3h
		db	 43h, 87h,0C3h,0C7h, 43h,0C9h
		db	0CAh,0CBh, 84h,0C3h,0C4h,0DDh
		db	0C4h, 86h, 01h, 1Dh, 88h,0C3h
		db	 53h, 83h, 90h,0C3h,0C4h,0DDh
		db	 87h,0C3h, 53h,0CAh,0CBh, 85h
		db	0C3h,0C4h,0DDh,0C4h, 86h, 01h
		db	 1Dh, 88h,0C3h, 53h, 83h, 90h

locloop_12:
		retn
			                        ;* No entry point to code
		inc	bx
;*		xchg	ax,bx
		db	 87h,0C3h		;  Fixup - byte match
		push	bx
		retf
			                        ;* No entry point to code
		xchg	al,bl
		push	bx
		xchg	bl,ch
		loopnz	locloop_11		; Loop if zf=0, cx>0

		retn
			                        ;* No entry point to code
		push	bx
;*		adc	word ptr ds:data_10e[bx+si],0FF87h
		db	 83h, 90h,0C3h, 43h, 87h	;  Fixup - byte match
		retn
			                        ;* No entry point to code
		inc	bx
;*		fld	qword ptr ds:data_11e[bx]	; Push onto stack
		db	0DDh, 87h,0C3h, 53h	;  Fixup - byte match
		xchg	[bx+di],al
		and	ds:data_11e[bx+si],cl
;*		adc	word ptr ds:data_15e[bx+si],0FFC4h
		db	 83h, 90h,0C3h,0DDh,0C4h	;  Fixup - byte match
;*		xchg	ax,bx
		db	 87h,0C3h		;  Fixup - byte match
		push	bx
;*		xchg	ax,bx
		db	 87h,0C3h		;  Fixup - byte match
		push	bx
		xchg	[bx+di],al
		and	ds:data_11e[bx+si],cl
;*		adc	word ptr ds:data_10e[bx+si],0FF87h
		db	 83h, 90h,0C3h, 43h, 87h	;  Fixup - byte match
		retn
			                        ;* No entry point to code
		lds	ax,dword ptr [bp+di-79h]	; Load seg:offset ptr
		loopnz	locloop_12		; Loop if zf=0, cx>0

		add	[bx+si],sp
		xchg	[bx+di],al
		and	ds:data_2e[bx+si],cl
;*		sub	word ptr ds:data_1e[bx],0FF88h
		db	 83h,0AFh, 01h, 20h, 88h	;  Fixup - byte match
		retn
			                        ;* No entry point to code
;*		fld	qword ptr [bp+di-7Dh]	; Push onto stack
		db	0DDh, 43h, 83h		;  Fixup - byte match
		db	 60h,0C2h,0C1h, 41h, 50h, 05h
		db	 02h, 07h, 01h, 51h, 70h, 51h
		db	 60h, 51h,0C1h, 41h, 81h, 01h
		db	 20h,0C4h, 87h,0C3h, 53h, 41h
		db	0C1h,0AFh,0E0h, 43h, 87h,0C3h
		db	 53h, 83h, 85h,0C3h, 01h, 20h
		db	0C4h, 87h,0C3h,0C4h, 8Fh,0C3h
		db	0E0h,0C4h, 8Bh,0E0h,0C4h,0DDh
		db	 87h,0C3h, 53h, 83h, 85h,0C3h
		db	 53h, 87h,0C3h,0C4h,0C7h,0CBh
		db	 8Dh,0C3h, 43h,0C7h, 4Ah, 88h
		db	0C3h, 43h, 87h,0C3h, 53h, 83h
		db	 85h,0C3h, 53h, 87h,0C3h, 43h
		db	0CAh, 8Dh,0C3h, 43h,0C7h,0C9h
		db	0CAh, 88h,0C3h, 43h, 87h,0C3h
		db	 53h, 83h, 85h,0C3h, 53h, 87h
		db	0C3h, 43h,0C7h,0CBh, 8Ch,0C3h
		db	 43h,0C7h,0C9h,0CAh,0CBh, 87h
		db	0C3h, 43h, 87h,0C3h,0C4h,0DDh
		db	0C4h, 83h, 85h,0C3h, 43h,0DDh
		db	 87h,0C3h, 53h,0CAh, 8Ch,0C3h
		db	 43h,0C7h, 48h,0CAh, 87h,0C3h
		db	 43h, 87h,0C3h, 53h, 83h, 85h
		db	0C3h, 53h, 87h,0C3h, 43h,0C7h
		db	0CAh,0CBh, 8Bh,0C3h, 43h,0C7h
		db	 49h,0CBh, 87h,0C3h,0DDh,0C4h
		db	 87h,0C3h, 53h, 83h, 85h,0C3h
		db	 53h, 87h,0C3h, 53h, 49h,0CBh
		db	 8Ah,0C3h, 53h,0C7h,0C9h,0CAh
		db	 4Ah, 85h,0C3h, 43h, 87h,0C3h
		db	 53h, 83h, 85h,0C3h, 53h, 87h
		db	0C3h, 43h,0C7h,0CAh,0C9h,0CAh
		db	0CBh, 89h,0C3h, 53h,0C7h,0C9h
		db	0C7h,0C9h,0CAh, 8Fh,0C3h, 43h
		db	0DDh, 83h, 85h,0C3h, 53h, 87h
		db	0C3h,0C4h,0C7h, 47h,0C7h,0C9h
		db	0CAh, 89h,0C3h, 53h, 46h, 48h
		db	0CAh, 8Fh,0C3h, 43h,0DDh, 83h
		db	 85h,0C3h, 53h, 87h,0C3h, 53h
		db	0C7h,0C9h,0CAh, 8Ah,0C3h, 63h
		db	 46h,0CAh,0CBh, 8Fh,0C3h, 53h
		db	 83h, 85h,0C3h, 53h, 87h,0C3h
		db	 43h,0C8h,0C7h, 48h,0CAh,0CBh
		db	 88h,0C3h, 08h, 04h,0E0h, 05h
		db	 04h, 87h,0C3h, 53h, 83h, 85h
		db	0C3h, 53h, 84h,0C3h, 05h, 04h
		db	0CAh,0C8h,0C7h,0CBh, 89h,0C3h
		db	 43h,0DDh, 05h, 04h,0DDh, 53h
		db	0DDh, 43h, 87h,0C3h, 53h, 83h
		db	 85h,0C3h, 53h, 84h,0C3h, 73h
		db	0C7h, 49h,0CBh, 8Ah,0C3h, 0Fh
		db	 04h, 87h,0C3h, 53h, 83h, 85h
		db	0C3h,0C4h,0DDh,0C4h, 84h,0C3h
		db	 43h,0DDh,0C4h,0C7h,0C8h,0CAh
		db	0CBh, 8Bh,0C3h, 43h,0DDh, 63h
		db	0E0h, 07h, 04h, 87h,0E0h, 53h
		db	 83h, 85h,0C3h, 53h, 84h,0D6h
		db	0E1h, 63h,0C7h,0CAh, 8Ch,0C3h
		db	 73h, 86h,0C3h, 53h,0DDh, 8Eh
		db	 51h, 82h,0C3h, 53h, 84h,0D6h
		db	0E1h, 53h,0C7h,0CCh, 40h, 41h
		db	 60h, 41h, 40h, 81h,0C3h, 73h
		db	 86h,0C3h, 63h, 09h, 02h,0C1h
		db	 41h,0C1h, 85h,0C3h, 53h, 84h
		db	0D6h,0E1h,0E0h, 43h,0C7h,0C9h
		db	0CAh, 8Ch,0DDh, 73h, 86h,0C3h
		db	 63h, 8Eh,0E0h, 07h, 04h, 84h
		db	0D6h,0E1h,0E0h, 53h,0C8h,0CBh
		db	 84h,0C8h, 0Ch, 04h, 86h,0C3h
		db	 05h, 04h,0E0h, 43h, 86h,0C3h
		db	0C4h,0E0h, 07h, 04h,0DDh, 84h
		db	0D6h,0E1h, 73h, 85h,0C3h, 0Ch
		db	 04h, 86h,0C3h, 08h, 04h, 86h
		db	0C3h, 43h, 53h,0DDh, 73h, 84h
		db	0D6h,0E1h, 73h, 85h,0C3h, 0Ch
		db	 04h, 86h,0C3h,0C4h,0E0h, 06h
		db	 04h, 86h,0C3h, 43h,0C4h,0E0h
		db	 06h, 04h, 84h,0C3h,0E0h, 73h
		db	 84h,0C8h, 63h,0E0h, 63h,0E0h
		db	 63h, 86h,0C3h,0C4h, 85h,0C3h
		db	 43h, 86h,0C3h, 43h,0C4h, 86h
		db	0C3h,0E0h, 84h,0C3h, 43h,0DDh
		db	 43h,0DDh, 84h,0C3h, 53h, 87h
		db	0C3h, 43h,0DDh, 86h,0C3h,0C4h
		db	 85h,0C3h,0C4h,0DDh, 86h,0C3h
		db	 43h,0C4h, 86h,0C3h,0E0h, 84h
		db	0C3h, 05h, 04h, 84h,0C3h, 53h
		db	 87h,0C3h, 53h, 86h,0C3h,0C4h
		db	 85h,0C3h, 43h, 86h,0C3h, 43h
		db	0C4h, 90h,0C3h, 43h, 84h,0C3h
		db	 53h, 87h,0C3h, 53h, 86h,0C3h
		db	0C4h, 85h,0C3h, 43h, 86h,0C3h
		db	 43h,0DDh, 50h,0C2h, 05h, 01h
		db	0C2h, 60h, 81h,0C3h, 86h,0C3h
		db	 53h, 87h,0E0h, 53h, 86h,0C3h
		db	0C4h,0DAh, 84h,0C3h, 43h, 86h
		db	0C3h, 43h,0C4h, 90h,0DDh, 86h
		db	0C3h,0DDh, 43h, 91h,0C3h,0DDh
		db	0DBh, 84h,0C3h, 43h, 86h,0C3h
		db	 43h,0C4h, 88h,0C3h, 8Eh,0C3h
		db	 53h, 50h,0C2h,0C1h, 41h, 60h
		db	 41h, 50h, 81h,0C3h,0C4h,0DCh
		db	 84h,0C3h,0DDh,0C4h, 86h,0C3h
		db	 43h,0C4h, 88h,0C3h, 8Eh,0C3h
		db	 53h, 91h,0C3h,0C4h,0D7h, 84h
		db	0C3h, 43h, 86h,0C3h, 43h,0C4h
		db	 88h,0C3h,0C7h,0CAh,0CBh, 8Bh
		db	0C3h, 53h, 85h,0C3h, 43h,0E0h
		db	0C4h, 87h,0C3h,0C4h,0C6h, 84h
		db	0C3h, 43h, 86h,0C3h, 43h,0C4h
		db	 88h,0C3h,0C7h,0C9h,0CAh,0CBh
		db	 8Ah,0C3h, 43h,0DDh, 85h,0C3h
		db	 63h, 87h,0C3h,0C4h, 85h,0C3h
		db	 43h, 86h,0C3h,0C4h,0DDh, 7Ch
		db	 00h, 22h, 8Eh, 00h, 22h,0B1h
		db	 00h, 22h,0C3h, 00h, 22h, 29h
		db	 01h, 2Fh, 2Ah, 01h, 0Dh,0FFh
		db	0FFh,0FFh,0FFh, 0Bh, 40h, 12h
		db	 3Ah, 01h, 15h, 00h, 25h, 40h
		db	0A2h, 1Fh, 00h, 2Bh, 00h, 35h
		db	 80h, 89h, 31h, 00h, 37h, 00h
		db	 3Ah, 80h,0B8h, 30h, 00h, 46h
		db	 00h, 3Ch, 80h,0AAh, 32h, 00h
		db	 44h, 00h, 4Fh, 80h, 8Bh, 43h
		db	 00h, 65h, 00h, 5Dh, 80h, 0Dh
		db	 52h, 00h, 65h, 00h, 95h, 80h
		db	0B4h, 90h, 00h, 98h, 00h,0C2h
		db	 40h,0B8h,0BBh, 00h,0D9h, 00h
		db	0D1h, 80h, 97h,0CBh, 00h,0D9h
		db	 00h,0EBh, 40h,0B7h,0E4h, 00h
		db	0EFh, 00h,0F7h, 40h,0B1h,0D7h
		db	 00h, 1Dh, 01h,0FCh, 40h, 89h
		db	0F5h, 00h, 03h, 01h,0FDh, 40h
		db	0B7h,0F6h, 00h, 04h, 01h,0FFh
		db	0FFh, 0Bh, 00h, 29h, 40h, 12h
		db	 7Fh, 00h, 07h, 00h, 2Bh, 00h
		db	 20h, 0Ch, 00h, 1Bh,0C1h, 0Fh
		db	 0Ch, 00h, 1Bh, 00h,0FFh,0FFh
		db	0FFh, 0Eh, 00h, 05h,0C2h, 0Dh
		db	 34h, 00h, 15h, 00h,0FFh,0FFh
		db	0FFh, 1Ch, 00h, 2Eh,0C2h, 11h
		db	 2Fh, 00h, 0Eh, 00h,0FFh,0FFh
		db	0FFh, 1Eh, 00h, 1Ch,0C4h, 0Fh
		db	 1Eh, 00h, 1Ch, 00h,0FFh,0FFh
		db	0FFh, 1Fh, 00h, 05h, 43h, 10h
		db	 3Eh, 00h, 0Dh, 01h, 2Bh, 00h
		db	 10h, 5Ah, 00h, 25h,0C4h, 0Fh
		db	 5Ah, 00h, 25h, 00h,0FFh,0FFh
		db	0FFh, 83h, 00h, 1Eh,0C2h, 0Fh
		db	0DDh, 00h, 01h, 00h,0FFh,0FFh
		db	0FFh, 96h, 00h, 1Eh,0C2h, 0Fh
		db	 96h, 00h, 1Eh, 00h,0FFh,0FFh
		db	0FFh,0A9h, 00h, 1Eh,0C2h, 0Fh
		db	0A9h, 00h, 1Eh, 00h,0FFh,0FFh
		db	0FFh,0BCh, 00h, 1Eh,0C1h, 0Fh
		db	0BCh, 00h, 1Eh, 00h,0FFh,0FFh
		db	0FFh,0F9h, 00h, 0Fh,0C4h, 0Fh
		db	0F9h, 00h, 0Fh, 00h,0FFh,0FFh
		db	0FFh, 35h, 01h, 29h, 01h, 11h
		db	 1Bh, 00h, 0Eh, 00h, 2Bh, 00h
		db	 08h, 3Bh, 01h, 30h, 40h, 06h
		db	0D1h, 00h,0FFh, 00h, 2Bh, 00h
		db	 04h,0FFh,0FFh, 28h, 00h,0FFh
		db	 13h,0C0h,0FFh,0FFh,0FFh,0FFh
		db	 2Ah, 00h, 80h, 6Fh,0D9h, 00h
		db	0FFh, 7Ah,0D9h,0FFh,0FFh,0FFh
		db	0FFh, 2Ah, 00h, 40h, 4Fh,0DAh
		db	 00h,0FFh, 5Ah,0DAh,0FFh,0FFh
		db	0FFh,0FFh, 2Ah, 00h, 20h,0AFh
		db	0DAh, 00h,0FFh,0BAh,0DAh,0FFh
		db	0FFh,0FFh,0FFh, 2Ah, 00h, 10h
		db	 18h,0DBh, 00h, 00h,0FFh,0FFh
		db	 2Ah, 00h, 08h, 9Fh,0DBh, 00h
		db	0FFh,0AAh,0DBh,0FFh,0FFh,0FFh
		db	0FFh, 2Ah, 00h, 04h,0CFh,0DBh
		db	 00h,0FFh,0DAh,0DBh,0FFh,0FFh
		db	0FFh,0FFh, 2Ah, 00h, 02h, 7Fh
		db	0DCh, 00h,0FFh, 8Ah,0DCh,0FFh
		db	0FFh,0FFh,0FFh, 2Ah, 00h, 01h
		db	 8Fh,0DCh, 00h,0FFh, 9Ah,0DCh
		db	0FFh,0FFh,0FFh,0FFh, 2Bh, 00h
		db	 80h, 9Fh,0DCh, 00h,0FFh,0AAh
		db	0DCh,0FFh,0FFh,0FFh,0FFh, 2Bh
		db	 00h, 40h,0EFh,0DCh, 00h,0FFh
		db	0FAh,0DCh,0FFh,0FFh,0FFh,0FFh
		db	 2Bh, 00h, 20h,0C2h,0D7h,0C0h
		db	 12h,0FFh,0FFh, 2Bh, 00h, 10h
		db	0FEh,0D7h,0C3h, 10h,0FFh,0FFh
		db	 2Bh, 00h, 08h, 52h,0D8h, 81h
		db	 11h,0FFh,0FFh, 2Bh, 00h, 04h
		db	 5Eh,0D8h,0C0h, 06h,0FFh,0FFh
		db	0FFh,0FFh, 17h,0AFh, 00h, 10h
		db	'Cavern of Tesoro'
		db	 13h, 00h, 05h, 0Ah, 0Ah, 09h
		db	 00h, 3Bh,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 09h, 00h
		db	 3Bh, 03h, 00h, 0Fh, 00h, 0Ch
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 0Fh, 00h, 0Ch, 04h
		db	 00h, 11h, 00h, 34h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 11h, 00h, 34h, 04h, 00h, 24h
		db	 00h, 0Ah,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 24h, 00h
		db	 0Ah, 04h, 00h, 29h, 00h, 34h
		db	0FFh, 73h, 00h, 00h, 20h, 00h
		db	 18h, 00h, 2Ah, 00h, 80h, 00h
		db	 00h, 33h, 00h, 19h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 33h, 00h, 19h, 04h, 00h, 38h
		db	 00h, 3Ch,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 38h, 00h
		db	 3Ch, 02h, 00h, 3Fh, 00h, 00h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 3Fh, 00h, 00h, 04h
		db	 00h, 55h, 00h, 2Dh,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 55h, 00h, 2Dh, 04h, 00h, 56h
		db	 00h, 11h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 56h, 00h
		db	 11h, 03h, 00h, 5Ch, 00h, 16h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 5Ch, 00h, 16h, 04h
		db	 00h, 61h, 00h, 29h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 61h, 00h, 29h, 03h, 00h, 64h
		db	 00h, 1Eh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 64h, 00h
		db	 1Eh, 02h, 00h, 6Dh, 00h, 38h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 6Dh, 00h, 38h, 02h
		db	 00h, 6Fh, 00h, 22h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 6Fh, 00h, 22h, 04h, 00h, 72h
		db	 00h, 0Fh,0FFh, 00h, 00h, 00h
		db	 10h, 00h, 00h, 00h, 72h, 00h
		db	 0Fh, 00h, 00h, 72h, 00h, 11h
		db	0FFh, 01h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 72h, 00h, 11h, 01h
		db	 00h, 76h, 00h, 1Eh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 76h, 00h, 1Eh, 02h, 00h, 77h
		db	 00h, 0Dh,0FFh, 73h, 00h, 03h
		db	 20h, 00h, 00h, 00h, 2Ah, 00h
		db	 40h, 00h, 00h, 7Dh, 00h, 29h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 7Dh, 00h, 29h, 03h
		db	 00h, 7Dh, 00h, 2Dh,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 7Dh, 00h, 2Dh, 04h, 00h, 83h
		db	 00h, 38h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 83h, 00h
		db	 38h, 02h, 00h, 85h, 00h, 01h
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 85h, 00h, 01h, 00h
		db	 00h, 85h, 00h, 03h,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 85h, 00h, 03h, 01h, 00h, 8Ch
		db	 00h, 0Eh,0FFh, 76h, 00h, 00h
		db	 20h, 00h, 00h, 00h, 2Ah, 00h
		db	 20h, 00h, 00h, 8Eh, 00h, 16h
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 8Eh, 00h, 16h, 00h
		db	 00h, 8Eh, 00h, 18h,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	 8Eh, 00h, 18h, 01h, 00h, 93h
		db	 00h, 08h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 93h, 00h
		db	 08h, 04h, 00h, 96h, 00h, 03h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 96h, 00h, 03h, 02h
		db	 00h, 9Bh, 00h, 23h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 9Bh, 00h, 23h, 04h, 00h,0A1h
		db	 00h, 28h,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 19h, 00h, 2Ah, 00h
		db	 10h, 00h, 00h,0A3h, 00h, 26h
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0A3h, 00h, 26h, 00h
		db	 00h,0A3h, 00h, 28h,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	0A3h, 00h, 28h, 01h, 00h,0A8h
		db	 00h, 2Dh,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0A8h, 00h
		db	 2Dh, 04h, 00h,0ADh, 00h, 08h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0ADh, 00h, 08h, 04h
		db	 00h,0ADh, 00h, 39h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0ADh, 00h, 39h, 04h, 00h,0AEh
		db	 00h, 33h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0AEh, 00h
		db	 33h, 02h, 00h,0B3h, 00h, 16h
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0B3h, 00h, 16h, 00h
		db	 00h,0B3h, 00h, 18h,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	0B3h, 00h, 18h, 01h, 00h,0B4h
		db	 00h, 0Eh,0FFh, 73h, 00h, 05h
		db	 20h, 00h, 00h, 00h, 2Ah, 00h
		db	 08h, 00h, 00h,0BEh, 00h, 03h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0BEh, 00h, 03h, 02h
		db	 00h,0C3h, 00h, 07h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0C3h, 00h, 07h, 04h, 00h,0C9h
		db	 00h, 0Dh,0FFh, 73h, 00h, 00h
		db	 20h, 00h, 1Ah, 00h, 2Ah, 00h
		db	 04h, 00h, 00h,0CBh, 00h, 1Ch
		db	0FFh, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h,0CBh, 00h, 1Ch, 00h
		db	 00h,0CBh, 00h, 1Eh,0FFh, 01h
		db	 00h, 00h, 10h, 00h, 00h, 00h
		db	0CBh, 00h, 1Eh, 01h, 00h,0CBh
		db	 00h, 3Ch,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0CBh, 00h
		db	 3Ch, 04h, 00h,0D3h, 00h, 22h
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0D3h, 00h, 22h, 04h
		db	 00h,0DAh, 00h, 3Dh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0DAh, 00h, 3Dh, 02h, 00h,0E2h
		db	 00h, 18h,0FFh, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0E2h, 00h
		db	 18h, 04h, 00h,0E6h, 00h, 0Ah
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0E6h, 00h, 0Ah, 04h
		db	 00h,0E6h, 00h, 13h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0E6h, 00h, 13h, 04h, 00h,0EAh
		db	 00h, 06h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0EAh, 00h
		db	 06h, 03h, 00h,0EEh, 00h, 3Dh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0EEh, 00h, 3Dh, 03h
		db	 00h,0F2h, 00h, 18h,0FFh, 73h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 2Ah, 00h, 02h, 00h, 00h, 04h
		db	 01h, 23h,0FFh, 73h, 00h, 00h
		db	 20h, 00h, 19h, 00h, 2Ah, 00h
		db	 01h, 00h, 00h, 0Bh, 01h, 0Eh
		db	0FFh, 73h, 00h, 05h, 20h, 00h
		db	 00h, 00h, 2Bh, 00h, 80h, 00h
		db	 00h, 17h, 01h, 3Bh,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 17h, 01h, 3Bh, 04h, 00h, 19h
		db	 01h, 37h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 19h, 01h
		db	 37h, 02h, 00h, 2Dh, 01h, 1Fh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 2Dh, 01h, 1Fh, 02h
		db	 00h, 2Fh, 01h, 03h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 2Fh, 01h, 03h, 02h, 00h, 3Fh
		db	 01h, 07h,0FFh, 76h, 00h, 00h
		db	 20h, 00h, 00h, 00h, 2Bh, 00h
		db	 40h, 00h, 00h,0FFh,0FFh

zr3_34		endp

seg_a		ends



		end	start
