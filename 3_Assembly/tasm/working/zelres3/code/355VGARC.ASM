
PAGE  59,132

;==========================================================================
;
;  355VGARC.BIN - VGA Register / Palette Data (zelres3 chunk 55)
;
;  Extracted as "vgareg55.bin" -- packed VGA palette + register data used
;  by level/background rendering code in other zelres3 chunks. 897 bytes
;  of raw data; not executable code, despite Sourcer's "zero start" mode
;  decoding the leading and trailing bytes as jge/jg/add/push instructions.
;  Those bytes are palette RGB values and VGA register state.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; The following equates are retained from Sourcer's analysis of the faux
; "code" at the head/tail of the file. They are effectively unreferenced
; because the file is pure data; kept so the assembly reproduces the
; original bytes exactly.

data_1e		equ	5F00h			;*
data_2e		equ	7F01h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

_355VGARC	proc	far

start:

vga_reg_palette_data	label	byte
		db	 7Dh, 03h		; data (Sourcer: jge +3)
		db	 00h, 00h		; data (Sourcer: add [bx+si],al)
		db	 00h, 01h		; data (Sourcer: add [bx+di],al)
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
; --- From here to end: still data. Sourcer decoded the following bytes
;     as push/jg/add/mov instructions, but they are palette/register
;     values. The mnemonics below assemble to the exact original bytes.

loc_2:
			db	0FFh,0F4h		; data (Sourcer: push sp)

loc_3:
				db	0FFh,0F4h		; data (Sourcer: push sp)
				jg	loc_2			; data 7F FA (Sourcer: jg -6)
			jg	loc_3			; data 7F FA (Sourcer: jg -6)
		add	ds:data_2e[bx],bh	; data 00 BF 01 7F
		add	bh,bh			; data 02 FF
		add	bh,bh			; data 02 FF
		add	bh,bh			; data 02 FF
		add	[bx+1],di		; data 01 7F 01
		db	 7Fh, 01h		; data (Sourcer: jg +1 fixup)
		jg	$+2			; data 7F 00
		mov	di,0BF00h		; data BF 00 BF
		add	ds:data_1e[bx],bh	; data 00 BF 00 5F
		db	 00h, 5Fh, 00h		; data (Sourcer: add [bx+0],bl fixup)
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
