
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_384UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_384UNKN	proc	far

start:
		retn
		db	 00h, 00h, 00h, 00h, 01h, 90h
		db	 00h,0D0h,0FFh,0FFh, 9Fh, 9Fh
		db	 9Eh, 03h,0FFh, 03h,0FFh, 90h
		db	 0Fh,0FFh, 0Fh,0FAh, 90h, 1Fh
		db	0FFh, 1Eh,0AAh, 90h, 3Fh,0FFh
		db	 3Ah,0AAh, 90h, 3Fh,0FFh, 3Eh
		db	0AAh, 90h, 1Bh,0AEh, 12h, 08h
		db	 90h, 0Ah,0AAh, 92h, 02h,0AAh
		db	 92h,0FFh, 3Fh,0FEh, 3Ah, 90h
		db	0FCh,0EAh,0B8h,0C0h, 90h,0F3h
		db	0AFh,0E3h, 0Fh, 90h,0F3h,0BBh
		db	0E3h, 33h, 90h,0F3h,0B6h,0A2h
		db	 34h, 90h,0B3h,0ADh, 22h, 0Dh
		db	 90h,0A8h,0EAh, 00h, 80h, 90h
		db	0AAh, 3Fh, 00h, 2Ah, 90h,0D2h
		db	 90h,0D0h,0BBh,0FAh, 90h,0D0h
		db	0AEh,0AAh, 90h,0D0h,0BAh,0AAh
		db	 90h,0D0h,0AEh,0AAh, 90h,0FBh
		db	0AEh,0A2h, 08h, 90h,0AAh,0AAh
		db	 92h,0AAh,0AAh, 90h, 0Fh,0A0h
		db	 0Fh,0A0h, 90h, 3Fh,0ECh, 30h
		db	0ECh, 90h,0FFh,0EAh,0C0h, 2Ah
		db	 90h,0BFh,0AAh,0B0h,0AAh, 90h
		db	0AAh,0AAh,0AAh,0AAh, 90h,0ABh
		db	0EAh,0ABh,0EAh, 90h, 2Fh,0F8h
		db	 2Dh, 58h, 90h, 0Bh,0E0h, 09h
		db	 60h, 90h, 0Fh,0F0h, 05h, 50h
		db	 90h, 3Fh,0FCh, 10h, 74h, 90h
		db	0FFh,0FEh, 40h, 1Eh, 90h,0FFh
		db	0FAh, 50h, 7Ah, 90h,0FFh,0FAh
		db	 75h,0FAh, 90h,0FFh,0EAh,0FFh
		db	0EAh, 90h, 2Eh,0A8h, 2Eh,0A8h
		db	 90h, 0Ah,0A0h, 0Ah,0A0h, 90h

_384UNKN	endp

seg_a		ends



		end	start
