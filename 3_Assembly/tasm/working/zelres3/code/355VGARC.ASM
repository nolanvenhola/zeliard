
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_355VGARC                                лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	5F00h			;*
data_2e		equ	7F01h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_355VGARC	proc	far

start:
;*		jge	loc_1			;*Jump if > or =
		db	 7Dh, 03h		;  Fixup - byte match
		add	[bx+si],al
		add	[bx+di],al
		db	 60h,0FFh, 90h, 00h,0FFh, 00h
		db	 20h, 00h, 20h, 00h, 20h, 00h
		db	 20h, 00h, 20h, 00h, 20h, 00h
		db	 20h, 00h, 20h, 8Ah,0AFh, 8Ah
		db	0AFh, 8Ah,0AFh, 8Ah,0AFh, 8Ah
		db	0AFh, 8Ah,0AFh, 8Ah,0AFh, 8Ah
		db	0AFh, 6Fh, 40h,0FFh, 40h,0FFh
		db	 40h,0FFh, 40h,0FFh, 40h,0FFh
		db	 40h,0FFh, 40h,0FFh, 40h,0FFh
		db	0F4h,0FFh,0F4h,0FFh,0F4h,0FFh
		db	0F4h,0FFh,0F4h,0FFh,0F4h,0FFh
		db	0F4h,0FFh,0F4h,0FDh, 00h,0FDh
		db	 00h,0FDh, 00h,0FDh, 00h,0FDh
		db	 00h,0FDh, 00h,0FDh, 00h,0FDh
		db	 9Fh, 2Fh,0FEh, 2Fh,0FFh, 2Fh
		db	0FFh, 2Fh,0FFh, 2Fh,0FFh, 2Fh
		db	0FFh, 2Fh,0FFh, 2Fh,0FFh, 2Fh
		db	0FFh, 2Fh,0FFh, 2Fh,0FFh, 2Fh
		db	0FFh, 2Fh,0FFh, 2Fh,0FFh, 2Fh
		db	0FFh, 2Fh,0FFh, 82h,0FFh, 42h
		db	0FFh,0A2h,0FFh,0D2h,0FFh,0EAh
		db	0FFh,0F2h,0FFh,0FAh,0FFh,0FCh
		db	0FFh,0FEh, 6Fh, 6Ah, 7Fh,0FFh
		db	 3Fh,0FFh, 5Fh,0FFh, 4Fh,0FFh
		db	 57h,0FFh, 4Bh,0FFh, 45h,0FFh
		db	 42h,0FFh, 41h, 7Fh,0F4h, 00h
		db	0F4h, 05h,0F4h, 0Bh,0F4h, 17h
		db	0F4h, 17h,0F4h, 2Fh,0F4h, 2Fh
		db	0F4h, 2Fh,0F4h, 2Fh,0F4h, 2Fh
		db	0F4h, 2Fh,0F4h, 2Fh,0F4h, 2Fh
		db	0F4h, 2Fh,0F4h, 2Fh,0F4h, 2Fh
		db	0F4h, 2Fh,0F4h, 2Fh,0F4h, 2Fh
		db	0F4h, 17h,0F4h, 17h,0F4h, 0Bh
		db	0F4h, 05h,0F4h, 00h,0BFh, 6Eh
		db	0D0h,0FFh,0A0h,0FFh, 40h,0FFh
		db	 40h,0FFh, 40h,0FFh, 40h,0FFh
		db	 40h,0FFh, 40h,0FFh, 40h,0FFh
		db	 40h,0FFh, 40h,0FFh, 40h,0FFh
		db	 40h,0FFh, 40h,0FFh, 40h,0FFh
		db	 40h,0FFh, 40h,0FFh, 40h,0FFh
		db	 40h,0FFh, 40h,0FFh, 40h,0FFh
		db	 40h,0FFh,0A0h,0FFh,0D0h, 6Ch
		db	0BFh,0FFh, 00h,0BFh, 05h,0FFh
		db	 0Bh,0FFh, 17h,0FFh, 17h,0FFh
		db	 2Fh,0FFh, 2Fh,0FFh, 2Fh,0FFh
		db	 2Fh,0FFh, 2Fh,0FFh, 2Fh,0FFh
		db	 17h,0FFh, 17h,0FFh, 0Bh,0FFh
		db	 05h,0FFh, 00h,0BFh,0FFh,0FDh
		db	 6Ch,0C3h,0FFh,0A5h,0FFh, 42h
		db	0FFh, 42h,0FFh, 42h,0FFh, 42h
		db	0FFh, 42h,0FFh, 42h,0FFh, 42h
		db	0FFh, 42h,0FFh, 42h,0FFh, 42h
		db	0FFh, 42h,0FFh, 42h,0FFh, 42h
		db	0FFh, 42h,0FFh, 42h,0FFh, 42h
		db	0FFh, 42h,0FFh, 42h,0FFh, 42h
		db	0FFh, 42h,0FFh,0A5h,0FFh,0C3h
		db	 6Eh,0FDh, 00h, 2Fh,0A0h, 2Fh
		db	0D0h, 2Fh,0E8h, 2Fh,0E8h, 2Fh
		db	0F4h, 2Fh,0F4h, 2Fh,0F4h, 2Fh
		db	0F4h, 2Fh,0F4h, 2Fh,0F4h, 2Fh
		db	0E8h, 17h,0E8h, 17h,0D0h, 0Bh
		db	0A0h, 05h, 90h,0FFh, 42h,0FFh
		db	 42h,0FFh, 42h,0FFh, 42h,0FFh
		db	 42h,0FFh, 42h,0FFh, 42h,0FFh
		db	 42h,0FFh, 42h,0FFh, 42h,0FFh
		db	 42h,0FFh, 42h,0FFh, 42h,0FFh
		db	 42h,0FFh,0A5h,0FFh,0C3h, 6Ch
		db	0BFh, 60h,0F4h,0FFh,0F4h,0FFh
		db	0F4h,0FFh,0E8h,0FFh,0E8h,0FFh
		db	0D0h,0FFh,0A0h,0FDh, 00h,0F4h
		db	0BFh,0F4h,0BFh,0F4h,0BFh,0F4h
		db	0BFh,0F4h,0BFh,0F4h,0BFh,0F4h
		db	0BFh,0F4h,0BFh,0F4h, 00h,0F4h
		db	 00h,0F4h, 00h,0F4h, 00h,0F4h
		db	 00h,0F4h, 00h,0F4h, 00h,0F4h
		db	 00h, 0Bh,0FFh, 0Bh,0FFh, 0Bh
		db	0FFh, 0Bh,0FFh, 0Bh,0FFh, 0Bh
		db	0FFh, 0Bh,0FFh, 0Bh, 60h,0FDh
		db	0FFh,0FDh,0FFh,0FDh,0FFh,0FDh
		db	0FFh,0FDh,0FFh,0FDh,0FFh,0FDh
		db	0FFh,0FDh,0D0h, 00h,0D0h, 00h
		db	0D0h, 00h,0D0h, 00h,0D0h, 00h
		db	0D0h, 00h,0D0h, 00h,0D0h, 00h
		db	 40h, 00h, 40h, 00h, 40h, 00h
		db	 40h, 00h, 40h, 00h, 40h, 00h
		db	 40h, 00h, 40h, 00h,0F4h, 2Fh
		db	0F4h, 2Fh,0F4h, 2Fh,0F4h, 2Fh
		db	0F4h, 2Fh,0F4h, 2Fh,0F4h, 2Fh
		db	0F4h, 2Fh, 00h, 2Fh, 00h, 2Fh
		db	 00h, 2Fh, 00h, 2Fh, 00h, 2Fh
		db	 00h, 2Fh, 00h, 2Fh, 00h, 2Fh
		db	0FFh, 45h,0FFh, 42h,0FFh, 42h
		db	0FFh, 42h,0FFh, 42h,0FFh, 42h
		db	0FFh, 42h,0FFh, 45h,0FFh, 3Fh
		db	0FFh, 3Fh,0FFh, 5Fh,0FFh, 5Fh
		db	0FFh, 4Fh,0FFh, 4Fh,0FFh, 57h
		db	0FFh, 57h,0FFh, 4Bh,0FFh, 4Bh
		db	0FFh, 45h,0FFh, 45h,0FFh, 42h
		db	0FFh, 42h,0FFh, 41h,0FFh, 41h
		db	0FDh, 00h,0FFh,0A0h,0FFh,0D0h
		db	0FFh,0E8h,0FFh,0E8h,0FFh,0F4h
		db	0FFh,0F4h,0FFh,0F4h,0FFh,0F4h
		db	0FFh,0F4h,0FFh,0F4h,0FFh,0E8h
		db	0FFh,0E8h,0FFh,0D0h,0FFh,0A0h
		db	0FDh, 00h,0FDh, 00h,0FDh, 00h
		db	0FEh, 80h,0FEh, 80h,0FFh, 40h
		db	0FFh, 40h,0FFh,0A0h,0FFh,0A0h
		db	0FFh,0D0h,0FFh,0D0h,0FFh,0E8h
		db	0FFh,0E8h
loc_2:
;*		push	sp
		db	0FFh,0F4h		;  Fixup - byte match
loc_3:
;*		push	sp
		db	0FFh,0F4h		;  Fixup - byte match
		jg	loc_2			; Jump if >
		jg	loc_3			; Jump if >
		add	ds:data_2e[bx],bh
		add	bh,bh
		add	bh,bh
		add	bh,bh
		add	[bx+1],di
;*		jg	loc_4			;*Jump if >
		db	 7Fh, 01h		;  Fixup - byte match
		jg	$+2			; delay for I/O
		mov	di,0BF00h
		add	ds:data_1e[bx],bh
;*		add	[bx+0],bl
		db	 00h, 5Fh, 00h		;  Fixup - byte match
		db	 5Fh, 00h, 2Fh, 00h, 2Fh, 00h
		db	 2Fh, 00h, 17h, 00h, 17h, 00h
		db	 17h, 00h, 0Bh, 00h, 0Bh, 00h
		db	 0Bh, 00h, 05h, 00h, 05h, 00h
		db	 05h, 00h, 02h, 00h, 02h, 00h
		db	 01h, 95h, 02h, 00h, 0Bh, 00h
		db	 2Fh, 00h, 2Fh, 00h, 2Fh, 00h
		db	 2Fh, 00h, 0Bh, 00h, 02h,0FFh
		db	0FDh,0FFh,0FEh, 65h,0FEh,0FFh
		db	0FEh,0FFh,0FEh,0FFh,0FDh,0FFh
		db	0FDh,0FFh,0FDh,0FFh,0FAh,0FFh
		db	0FAh,0FFh,0FAh,0FFh,0F5h,0FFh
		db	0F5h,0FFh,0F5h,0FFh,0EAh,0FFh
		db	0EAh,0FFh,0EAh,0FFh,0D5h,0FFh
		db	0D5h,0FFh,0D5h,0FFh,0AAh,0FFh
		db	0AAh,0FFh,0AAh,0FFh, 55h,0FFh
		db	 55h, 7Eh,0AAh, 94h,0FFh, 55h
		db	0FFh,0D5h,0FFh,0F5h,0FFh,0F5h
		db	0FFh,0F5h,0FFh,0F5h,0FFh,0D5h
		db	0FFh, 55h, 54h, 41h,0AAh, 20h
		db	 55h, 10h, 55h, 10h, 55h, 10h
		db	0AAh, 20h,0AAh, 20h,0AAh, 20h
		db	 54h, 41h, 54h, 41h, 54h, 41h
		db	0A8h, 82h,0A8h, 82h,0A8h, 82h
		db	 51h, 04h, 51h, 04h, 51h, 04h
		db	0A2h, 08h,0A2h, 08h,0A2h, 08h
		db	 44h, 10h, 44h, 10h, 44h, 10h
		db	 88h, 20h, 88h, 20h, 88h, 20h
		db	 10h, 40h, 10h, 40h, 20h, 80h
		db	 94h, 10h, 40h, 44h, 10h, 51h
		db	 04h, 51h, 04h, 51h, 04h, 51h
		db	 04h, 44h, 10h, 10h, 40h, 90h
		db	 80h, 00h, 40h, 00h, 40h, 00h
		db	 40h, 00h, 80h, 00h, 80h, 00h
		db	 80h, 00h

_355VGARC	endp

seg_a		ends



		end	start
