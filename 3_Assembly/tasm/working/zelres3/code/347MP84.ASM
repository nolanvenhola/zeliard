
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_347MP84                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	38C5h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_347MP84	proc	far

start:
		xchg	sp,ax
		add	ax,0
		jge	$-39h			; Jump if > or =
		inc	ax
		add	ds:data_1e,dh
		lds	di,dword ptr [bp+si]	; Load seg:offset ptr
		lds	di,dword ptr [si]	; Load seg:offset ptr
		lds	dx,dword ptr [bp-3Bh]	; Load seg:offset ptr
		db	 6Ah,0C5h, 82h,0C5h, 08h, 1Eh
		db	 00h, 06h, 0Ah, 00h, 00h, 36h
		db	0C5h,0CAh, 4Bh,0CBh,0CCh,0CAh
		db	0C7h,0C8h,0E5h,0C8h, 82h,0E5h
		db	 83h,0E5h, 81h,0E5h, 8Bh,0E5h
		db	 98h,0C4h,0C9h, 66h, 4Bh,0C9h
		db	0CCh,0CBh,0C9h,0CCh,0C7h, 81h
		db	 47h, 83h,0E5h,0ABh,0C5h,0C7h
		db	0C9h,0CCh,0CBh, 46h, 4Bh,0CCh
		db	0CBh,0CAh, 81h, 47h, 86h,0E5h
		db	0AAh,0C5h,0C7h,0CAh,0CCh,0C7h
		db	0CCh,0C7h,0C9h,0CAh, 4Bh,0CBh
		db	0CCh,0C7h, 81h,0C8h, 84h,0E5h
		db	 81h,0E5h,0A9h,0C4h, 66h, 4Bh
		db	 49h,0CAh,0C9h,0CCh,0CAh, 81h
		db	 57h,0AFh,0C4h, 05h, 07h,0CCh
		db	0CBh, 4Bh,0CBh,0CCh, 49h,0C7h
		db	0C9h,0C8h,0AEh,0C4h, 66h,0C9h
		db	 56h,0CAh, 46h,0CCh,0CBh,0CCh
		db	 81h,0CCh,0CAh,0C7h,0ADh,0C4h
		db	 05h, 07h,0CCh,0CAh,0C9h, 5Bh
		db	0C7h,0C9h, 4Bh,0C7h, 57h,0ABh
		db	0C5h,0CAh,0CCh, 66h, 4Bh, 5Bh
		db	0CBh,0CCh,0CAh, 81h,0C8h, 81h
		db	0C8h,0ADh,0C4h, 46h, 4Bh,0C7h
		db	0C9h,0C7h,0CAh,0CAh,0CBh,0CCh
		db	0CAh, 81h, 57h, 81h,0C8h,0ADh
		db	0C4h,0CAh,0C9h,0CCh,0C7h, 4Bh
		db	0CBh,0C7h, 5Bh,0CBh, 47h,0B1h
		db	0C4h, 05h, 07h,0CBh,0CAh,0CAh
		db	0CCh,0CBh,0C7h, 81h,0C8h,0B1h
		db	0C4h, 06h, 07h,0CCh, 6Bh,0C7h
		db	 81h,0C8h,0B0h,0C4h,0C7h,0C9h
		db	0CCh,0CAh,0CCh, 49h,0CCh,0C9h
		db	 49h, 6Bh,0C8h, 81h,0C8h,0ADh
		db	0C5h, 46h,0C9h, 46h, 4Bh,0C7h
		db	 56h,0C9h,0CCh, 49h, 4Bh,0C7h
		db	0C8h,0ACh,0C5h, 76h,0CAh,0CCh
		db	0CBh, 4Bh,0C7h,0CAh, 46h,0C9h
		db	0C7h,0AFh,0C4h, 46h,0CAh, 4Bh
		db	0CBh,0CAh,0CCh,0C7h,0CBh, 46h
		db	0CCh, 47h, 82h,0C3h,0C7h, 81h
		db	0C7h,0AAh,0C4h,0C7h,0CBh,0C7h
		db	0CCh, 66h,0CCh,0CAh,0CCh, 49h
		db	 81h,0C8h, 82h,0C5h, 49h,0C7h
		db	 81h,0C8h,0A8h,0C4h,0C7h,0C9h
		db	 66h,0CCh,0C9h, 66h, 47h, 83h
		db	0C5h,0C7h, 4Bh, 81h,0C8h,0A8h
		db	0C4h, 46h, 4Bh,0C7h,0CCh,0C7h
		db	0CCh,0C7h,0C9h,0CBh,0C7h, 81h
		db	0C8h, 83h,0C4h,0CCh,0C9h, 81h
		db	 46h,0C8h,0A7h,0C4h, 46h,0CAh
		db	0CCh,0CAh,0CBh,0C7h,0CBh,0C7h
		db	0CCh,0CAh,0C7h,0C8h, 84h,0C5h
		db	0CCh,0C9h, 5Bh,0A8h,0C5h, 66h
		db	0CCh,0CBh,0CCh,0C7h,0CBh,0CAh
		db	0CBh, 81h,0C8h, 84h,0C5h,0CAh
		db	 4Bh,0CAh,0C7h,0CCh, 56h,0A4h
		db	0C5h, 46h,0C9h,0C7h,0CAh, 48h
		db	0CBh,0CCh,0C7h,0CBh,0C8h, 85h
		db	0C5h,0C9h, 4Bh,0CBh,0CCh, 46h
		db	0A6h,0C4h, 76h, 5Bh,0CAh, 4Bh
		db	0C8h, 85h,0C4h,0CAh, 81h, 4Bh
		db	0CBh, 81h,0CCh,0A6h,0C4h,0CAh
		db	0CCh, 56h, 4Bh,0CBh,0C7h,0C9h
		db	 56h,0C8h, 83h,0C5h,0CCh,0C9h
		db	0CAh, 6Bh,0A6h,0C4h,0C7h,0CAh
		db	 4Bh,0CAh,0C9h,0CCh,0C7h,0CAh
		db	0CBh,0CCh,0C9h,0C8h, 84h,0C5h
		db	0CAh, 4Bh,0CBh, 81h,0CCh,0A7h
		db	0C4h, 46h,0CCh,0C7h,0CCh,0CAh
		db	0CCh,0C9h,0CCh,0C7h,0C8h, 86h
		db	0C4h,0CAh, 4Bh,0C7h, 4Bh,0CBh
		db	0A6h,0C4h,0C7h,0C9h, 46h, 4Ah
		db	0CCh,0CAh,0CCh,0C7h,0C8h, 86h
		db	0C5h,0CCh, 81h,0CCh, 81h,0C7h
		db	0CCh,0CBh,0A6h,0C5h, 76h,0C9h
		db	0CCh,0CBh,0CAh,0C8h, 87h,0C5h
		db	 59h,0CCh,0CBh,0C7h,0CBh,0A6h
		db	0C4h, 66h, 5Bh,0CAh,0CCh,0C8h
		db	 81h,0C8h, 85h,0C5h,0CAh,0C9h
		db	0CCh, 56h, 4Bh,0CBh,0C7h,0A3h
		db	0C4h, 46h, 49h,0C7h,0CCh,0C7h
		db	0C9h,0C7h,0C8h, 87h,0C5h,0CCh
		db	0CAh,0CCh,0C9h,0CCh, 56h,0CCh
		db	 46h,0A2h,0C4h, 56h,0CCh,0C7h
		db	0CCh, 46h,0CAh,0C8h, 81h,0C8h
		db	 85h,0C5h,0CAh,0CCh,0CBh, 4Bh
		db	0CBh, 81h,0C7h, 81h,0C8h,0A3h
		db	0C4h, 66h,0CCh, 4Ah,0C7h,0C7h
		db	 47h, 86h,0C5h,0CBh,0CAh,0CCh
		db	 82h,0CCh, 81h, 47h,0A4h,0C4h
		db	0CAh, 4Bh, 46h,0CAh,0C9h,0CCh
		db	0CAh, 4Bh,0C7h, 85h,0C4h,0CAh
		db	0C9h, 76h,0CBh, 81h,0C8h,0A3h
		db	0C4h,0C7h, 4Bh, 56h,0CCh,0CBh
		db	 46h,0C9h,0C8h, 85h,0C5h, 49h
		db	 5Bh,0C7h,0CBh,0C7h, 81h, 47h
		db	 89h,0E5h, 98h,0C4h,0C7h,0C9h
		db	0C7h, 4Bh,0C9h,0CAh,0CCh,0C7h
		db	 81h,0C8h, 86h,0C5h, 4Bh, 56h
		db	0CBh,0C8h, 81h,0C8h, 8Ah,0E5h
		db	 99h,0C4h, 56h,0CBh,0C7h,0CBh
		db	0CCh,0C7h,0CBh,0C7h, 47h, 85h
		db	0C4h,0CCh, 49h,0C7h,0CCh, 81h
		db	 47h, 8Ch,0E5h, 98h,0C5h, 56h
		db	0C9h,0C7h,0CAh, 4Bh,0CCh,0CAh
		db	0C8h, 86h,0C5h,0CCh,0CAh,0C7h
		db	0CCh, 81h, 57h,0A5h,0C5h, 56h
		db	0CAh,0C7h,0CCh,0C9h,0CAh, 46h
		db	0C8h, 81h,0C8h, 84h,0C5h,0CAh
		db	 4Bh, 46h, 4Bh, 47h,0A4h,0C4h
		db	 76h, 4Bh,0C7h, 46h,0CAh, 47h
		db	 84h,0C5h,0C9h,0CBh,0CAh, 46h
		db	0CCh,0C7h,0CBh, 67h, 89h,0E5h
		db	 97h,0C4h, 56h,0CAh, 56h,0C9h
		db	0CCh,0C9h, 4Bh,0C8h, 84h,0C5h
		db	 49h,0CCh,0CAh, 66h, 81h,0C8h
		db	 83h,0E5h, 88h,0E5h, 96h,0C4h
		db	0C9h, 46h,0CAh,0CBh,0C9h,0CCh
		db	0CAh, 46h,0CCh,0C8h,0C7h,0C8h
		db	 83h,0C4h,0CCh,0C9h,0CCh,0CBh
		db	0CCh, 82h,0CBh,0E5h, 83h,0E5h
		db	 89h,0E9h, 96h,0C4h, 76h,0CBh
		db	0CAh,0CCh, 46h,0CBh, 81h,0C8h
		db	 84h,0C5h,0CBh,0CAh, 46h,0CCh
		db	 46h,0C8h, 81h,0E5h, 82h,0E9h
		db	0E5h, 8Ah,0E5h, 94h,0C4h,0C7h
		db	0CAh, 4Bh,0C7h,0CBh,0CAh,0C9h
		db	0CAh, 46h,0C8h, 85h,0C4h, 46h
		db	0CAh,0CBh,0C8h,0CCh,0C7h,0C8h
		db	0E5h, 47h, 81h,0E5h, 86h,0E5h
		db	 99h,0C4h,0C7h, 4Bh, 46h,0CCh
		db	 46h, 4Bh, 81h, 47h, 84h,0C5h
		db	0C9h, 4Bh,0C7h, 81h,0CCh,0C8h
		db	0E5h,0C8h,0E5h, 81h,0E5h,0E9h
		db	 81h,0E9h,0E5h, 84h,0E5h, 98h
		db	0C5h,0C7h,0CCh, 66h,0CCh,0CAh
		db	 46h,0CBh,0C7h,0C8h, 84h,0C5h
		db	0C7h,0CCh,0CAh,0CCh,0C7h, 47h
		db	0E9h,0E5h,0E9h,0E5h,0E9h,0E5h
		db	 81h,0E5h,0E9h,0E5h, 83h,0E9h
		db	0E5h, 97h,0C4h, 76h,0C9h, 46h
		db	0C9h,0CAh,0CCh,0C9h, 81h,0C8h
		db	 83h,0C5h, 49h, 47h,0CBh,0C8h
		db	 81h,0E5h,0E9h,0E5h, 81h,0E5h
		db	0E9h,0E5h, 85h,0E9h,0E5h, 81h
		db	0E5h, 96h,0C5h,0C7h,0CAh, 76h
		db	0CCh, 56h,0CAh, 81h,0C8h, 83h
		db	0C6h,0C7h, 57h, 82h,0E5h, 81h
		db	0E5h,0E9h, 82h,0E5h, 86h,0E5h
		db	 99h,0C4h, 46h,0CCh,0CAh,0C7h
		db	 49h,0C9h,0CAh,0CCh,0CBh,0C7h
		db	0C8h,0B2h,0C4h,0C7h,0C9h,0CCh
		db	0CAh,0CBh,0C7h,0CCh,0CBh,0C7h
		db	0CAh, 4Bh, 40h,0C2h, 40h, 51h
		db	0C1h, 41h, 40h, 51h, 60h, 41h
		db	0C1h,0C2h,0C1h, 71h, 50h, 51h
		db	 40h,0C2h,0C1h,0C2h,0C1h, 51h
		db	0C1h, 85h,0C4h, 56h,0CCh,0C7h
		db	0CAh,0C7h,0C9h,0CAh,0CCh,0CAh
		db	0CBh,0CAh, 47h,0B0h,0C4h, 07h
		db	 07h, 56h,0CCh,0CBh, 46h,0CAh
		db	 83h,0E5h, 81h,0E5h, 81h,0E5h
		db	 89h,0E5h, 85h,0E5h, 97h,0C4h
		db	 76h,0CCh, 49h,0C7h,0C9h,0CAh
		db	0C7h,0CBh,0C7h,0CCh,0CBh,0C7h
		db	0C8h, 82h,0E5h,0E9h,0E5h, 81h
		db	0E5h, 81h,0E5h, 87h,0E5h,0E9h
		db	0E5h, 81h,0E5h, 98h,0C5h, 05h
		db	 07h, 4Bh,0CAh, 5Bh,0C9h, 81h
		db	0C8h,0CCh,0C8h, 82h,0E5h,0E9h
		db	0E5h,0E9h,0E5h,0E9h,0E5h,0E9h
		db	0E5h,0E9h, 86h,0E5h, 9Bh,0C4h
		db	 76h,0C9h,0CCh,0CBh, 4Bh,0CBh
		db	 81h, 57h, 82h,0C8h,0E5h, 81h
		db	0E5h,0E9h,0E5h, 81h,0E5h,0E9h
		db	0E5h,0E9h, 92h,0E5h, 90h,0C4h
		db	0C7h,0CAh, 4Bh,0CAh,0CBh,0CAh
		db	0CCh, 4Bh, 47h, 83h, 47h,0E5h
		db	0E9h,0E5h, 81h,0E5h,0E9h,0E5h
		db	0E9h,0E5h,0E9h,0E5h, 81h,0E5h
		db	0E9h,0E5h, 83h,0E5h, 9Bh,0C5h
		db	0C9h, 56h,0CCh,0CBh,0C7h,0CCh
		db	0CAh,0CBh, 57h, 83h,0E5h,0C8h
		db	0E5h,0E9h,0E5h,0E9h,0E5h, 81h
		db	0E5h, 81h,0E5h,0E9h,0E5h, 82h
		db	0E9h,0E5h, 82h,0E9h,0E5h, 9Ah
		db	0C4h, 66h,0CCh,0C7h,0CAh,0C9h
		db	 5Bh,0C9h, 57h,0E5h,0E9h, 81h
		db	0E9h,0C8h, 81h,0E5h, 81h,0E5h
		db	0E9h,0E5h, 85h,0E5h,0E9h, 82h
		db	0E5h, 81h,0E5h, 99h,0C4h,0C7h
		db	0CAh,0CBh,0C7h,0CAh, 4Bh,0CAh
		db	0CAh,0CCh,0CBh, 5Bh,0C7h,0C8h
		db	0E5h, 81h,0E5h,0E9h,0E5h, 81h
		db	0E5h,0E9h,0E5h, 81h,0E5h, 81h
		db	0E5h, 83h,0E5h,0E9h,0E5h, 85h
		db	0E5h, 96h,0C4h, 46h,0C9h,0CCh
		db	0C7h,0CAh,0CBh,0CAh,0CCh, 49h
		db	0CCh,0C9h,0CAh, 81h,0E5h,0E9h
		db	0E5h,0E9h,0E5h,0E9h,0E5h, 81h
		db	0E5h,0E9h,0E5h,0E9h,0E5h, 85h
		db	0E5h, 85h,0E5h, 97h,0C4h, 56h
		db	 4Bh,0C9h,0C7h,0CCh, 4Bh,0CAh
		db	 47h, 81h,0C8h, 81h,0E5h,0E9h
		db	0E5h, 81h,0E5h,0E9h,0E5h, 81h
		db	0E5h, 81h,0E5h,0A4h,0C4h, 66h
		db	 4Bh,0C7h,0C9h,0CBh,0CCh, 82h
		db	0C8h, 88h,0E5h,0E9h,0E5h,0E9h
		db	0E5h,0E9h,0E5h, 81h,0E5h,0A1h
		db	0C4h, 05h, 07h,0CCh,0CAh,0CAh
		db	0C7h, 81h, 47h, 83h,0E5h, 81h
		db	0E5h, 81h,0E5h, 81h,0E5h, 81h
		db	0E5h, 81h,0E5h, 81h,0E5h, 87h
		db	0E5h, 9Ah,0C5h, 66h,0CCh,0C9h
		db	 4Bh, 4Bh, 49h, 81h,0C8h, 81h
		db	0E5h,0E9h,0E5h,0C8h,0E5h,0E9h
		db	0E5h, 81h,0E5h,0E9h,0E5h,0E9h
		db	0E5h,0A3h,0C5h, 76h, 4Bh,0CBh
		db	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 10h, 00h, 33h, 42h, 1Ch, 32h
		db	 00h, 0Eh, 01h,0FFh,0FFh,0FFh
		db	 1Eh, 00h, 05h, 00h, 1Dh, 08h
		db	 00h, 0Ah, 00h, 45h, 00h, 20h
		db	0FFh,0FFh, 45h, 00h, 10h, 82h
		db	0C5h,0FFh,0FFh,0FFh,0FFh, 45h
		db	 00h, 20h, 4Bh,0C5h, 80h, 1Dh
		db	0FFh,0FFh,0FFh,0FFh, 17h,0AFh
		db	 04h, 0Fh
		db	'Cavern of Final'
		db	 17h, 00h, 07h, 0Eh, 0Eh, 3Ch
		db	 00h, 35h,0FFh, 76h, 00h, 00h
		db	 20h, 00h, 00h, 00h, 45h, 00h
		db	 10h, 00h, 00h,0FFh,0FFh

_347MP84	endp

seg_a		ends



		end	start
