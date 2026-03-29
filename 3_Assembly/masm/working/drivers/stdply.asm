
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				STDPLY	                                 лл
;лл					                                 лл
;лл      Created:   29-Mar-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'M4'                      ; Target assembler: MASM-4.0

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

stdply		proc	far

start:
		dw	64 dup (0)		; Data table (indexed access)
		db	 1Eh, 00h, 00h, 0Ah, 0Ah
		db	11 dup (0)
		db	 50h, 00h, 01h
		db	24 dup (0)
		db	 0Ch, 06h, 08h, 04h, 03h, 04h
		db	 03h, 50h, 00h, 0Ch, 06h, 08h
		db	 04h, 03h, 04h, 03h, 00h
		db	8 dup (0)
		db	 80h, 81h, 00h, 00h, 00h, 8Ah
		db	0A6h, 6Bh, 75h, 42h, 4Ch, 4Bh
		db	 01h,0FFh,0C0h,0C0h,0E0h,0E0h
		db	 70h, 38h, 38h,0F8h,0F8h,0C0h
		db	0E0h,0E0h, 70h, 30h, 38h, 1Ch
		db	 1Ch,0FCh, 00h, 00h, 00h, 00h
		db	 00h

stdply		endp

seg_a		ends



		end	start
