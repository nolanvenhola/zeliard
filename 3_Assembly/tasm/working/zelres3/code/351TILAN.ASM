
PAGE  59,132

;==========================================================================
;
;  351TILAN.BIN - Tile Animation Data (zelres3 chunk 51, tileani.bin)
;
;  Packed tile animation sequences used by the level/map renderer.
;  5463 bytes of raw data; not executable code despite Sourcer's
;  "zero start" decoding of the leading bytes and a few interior
;  "fixup" byte groups. Content appears to be:
;    - Sequences of tile index bytes (e.g. 00..FF, A0..BB ranges)
;    - ASCII-range pseudo-strings ('abcdefg', 'hij', etc.) that are
;      simply tile glyph indices in the 0x60..0x7F range
;    - Frequent 0E6h marker bytes followed by a length byte, suggesting
;      a simple RLE / section-break encoding
;  The file is consumed by the tile renderer; exact format is TBD.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; Data references outside this 5463-byte blob. Retained from Sourcer's
; interpretation of the faux-code bytes at the head/tail; most are
; artefacts of data bytes being decoded as instructions.

data_1e		equ	0E6h
data_2e		equ	5000h			;*
data_3e		equ	5400h			;*
data_4e		equ	7C00h			;*
data_5e		equ	8000h			;*
data_11e	equ	2D00h			;*
data_12e	equ	80D4h			;*
data_13e	equ	0E6D5h			;*
data_14e	equ	0FC07h			;*
data_15e	equ	1			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_351TILAN	proc	far

start:
tile_anim_data	label	byte
		push	bx
		adc	ax,0
		add	data_6,al
		out	40h,ax			; port 40h, 8253 timer 0 clock
		db	0FFh,0FFh, 00h, 01h, 00h, 02h
		db	 03h, 00h, 04h, 05h, 06h, 00h
		db	 07h, 00h, 08h, 09h, 00h, 0Ah
		db	 0Bh,0E6h, 00h, 01h, 00h, 02h
		db	 0Ch, 00h, 0Dh, 0Eh, 0Fh, 00h
		db	 07h, 00h, 08h, 10h, 00h, 11h
		db	 12h,0E6h, 00h, 13h,0E6h, 00h
		db	 14h, 00h, 15h, 16h, 17h,0E6h
		db	 02h, 18h, 00h, 19h, 1Ah, 1Bh
		db	 00h, 07h, 00h, 1Ch, 1Dh, 00h
		db	 1Eh, 1Fh, 20h, 00h, 18h, 00h
		db	 21h, 22h, 23h, 00h, 24h, 25h
		db	 00h, 07h, 00h, 26h, 27h, 28h
		db	 00h, 29h, 2Ah, 00h, 07h, 00h
		db	 2Bh, 2Ch, 2Dh, 2Eh, 2Fh,0E6h
		db	 00h,0A0h,0A1h, 00h,0A2h,0A3h
		db	0A4h,0A5h,0A6h,0E6h, 02h,0A7h
		db	0A8h,0A9h,0AAh,0ABh,0E6h, 04h
		db	0A9h,0ACh,0ADh, 00h, 30h,0E6h
		db	 00h, 31h, 32h, 33h, 34h, 35h
		db	 00h, 36h,0E6h, 00h, 37h, 38h
		db	 00h, 39h, 3Ah, 00h, 30h,0E6h
		db	 00h, 3Bh, 32h, 3Ch, 3Dh, 3Eh
		db	 00h, 36h,0E6h, 00h, 3Fh, 40h
		db	 00h, 41h, 42h, 00h, 43h,0E6h
		db	 00h, 44h, 00h, 45h, 46h, 47h
		db	0E6h, 02h, 48h, 00h, 49h, 4Ah
		db	 4Bh, 00h, 36h,0E6h, 00h, 4Ch
		db	 4Dh, 4Eh, 4Fh, 50h, 00h, 48h
		db	 00h, 51h, 52h, 53h, 54h, 55h
		db	0E6h, 00h, 36h, 00h, 56h, 57h
		db	 58h, 00h, 59h, 5Ah, 00h, 36h
		db	 00h, 5Bh, 5Ch, 5Dh, 5Eh, 5Fh
		db	 00h,0AEh,0AFh, 00h,0B0h,0B1h
		db	 00h,0B2h,0B3h,0B4h,0E6h, 01h
		db	0B5h,0B6h, 00h,0B7h,0B8h,0B9h
		db	0E6h, 04h,0BAh,0BBh
data_6		db	0B9h
		db	'`abcdefg', 0
		db	'hij', 0
		db	'klmn', 0
		db	'`abcdefg', 0
		db	'opqrs', 0
		db	'tu', 0
		db	 80h, 81h, 82h, 83h, 84h, 85h
		db	 86h, 87h,0E6h, 02h, 76h, 77h
		db	0E6h, 06h, 78h,0E6h, 06h, 79h
		db	 7Ah,0E6h, 05h, 78h,0E6h, 02h
		db	 88h,0E6h, 00h, 89h, 8Ah,0E6h
		db	 06h, 8Bh, 8Ch,0E6h, 05h, 8Bh
		db	 8Ch,0E6h, 05h, 8Bh, 8Ch,0E6h
		db	 02h, 8Dh,0E6h, 00h, 8Eh,0E6h
		db	 04h, 8Fh, 00h, 90h, 91h,0E6h
		db	 05h, 92h,0E6h, 06h, 93h, 94h
		db	0E6h, 03h,0BCh, 00h,0BDh,0BEh
		db	0E6h, 03h,0BCh, 00h,0BDh,0BEh
		db	0E6h, 04h,0D1h,0D2h,0E6h, 04h
		db	0C3h, 00h,0BDh,0C4h,0E6h, 00h
		db	0C5h,0E6h, 00h,0C6h, 00h,0C7h
		db	0C8h,0E6h, 01h,0DCh,0DDh, 00h
		db	0DEh,0DFh, 00h,0E0h,0E1h,0E6h
		db	 03h, 7Bh, 7Ch,0E6h, 05h, 7Dh
		db	0E6h, 05h, 7Eh, 7Fh,0E6h, 06h
		db	 7Dh,0E6h, 04h, 95h, 00h, 96h
		db	 91h,0E6h, 04h, 97h, 98h,0E6h
		db	 05h, 97h, 98h,0E6h, 05h, 97h
		db	 98h,0E6h, 03h, 99h,0E6h, 00h
		db	 9Ah,0E6h, 02h, 9Bh,0E6h, 00h
		db	 89h, 9Ch,0E6h, 06h, 9Dh,0E6h
		db	 05h, 9Eh, 9Fh,0E6h, 02h,0D3h
		db	0E6h, 00h,0D4h,0D5h,0E6h, 02h
		db	0D3h,0E6h, 00h,0D4h,0D5h,0E6h
		db	 05h,0D1h,0D2h,0E6h, 02h,0D6h
		db	0E6h, 00h,0D7h,0D5h, 00h,0D8h
		db	0E6h, 00h,0D9h,0E6h, 00h,0DAh
		db	0DBh,0E6h, 02h,0DCh,0DDh, 00h
		db	0DEh,0DFh, 00h,0E0h,0E1h,0E6h
		db	 03h, 7Dh,0E6h, 03h,0E2h,0E6h
		db	 00h,0E3h,0E6h, 03h,0E2h,0E6h
		db	 00h,0E3h,0E6h, 03h,0E2h,0E6h
		db	 00h,0E3h,0E6h, 02h,0D3h,0E6h
		db	 00h,0D4h,0D5h,0E6h, 06h,0C1h
		db	0C2h,0E6h, 05h,0C1h,0C2h,0E6h
		db	 05h,0C1h,0C2h,0E6h, 01h,0D9h
		db	0E6h, 00h,0DAh,0DBh,0E6h, 03h
		db	0CDh,0CEh, 00h,0CFh,0D0h,0E6h
		db	 02h,0CDh,0CEh, 00h,0CFh,0D0h
		db	0E6h, 02h,0CDh,0CEh, 00h,0CFh
		db	0D0h,0E6h, 05h, 78h,0E6h, 03h
		db	0E4h,0E6h, 00h,0E5h,0E6h, 03h
		db	0E4h,0E6h, 00h,0E5h,0E6h, 03h
		db	0E4h,0E6h, 00h,0E5h,0E6h, 04h
		db	0BCh, 00h,0BDh,0BEh,0E6h, 04h
		db	0BFh,0C0h,0E6h, 05h,0BFh,0C0h
		db	0E6h, 05h,0BFh,0C0h,0E6h, 04h
		db	0C6h, 00h,0C7h,0C8h,0E6h, 01h
		db	0C9h,0CAh, 00h,0CBh,0CCh,0E6h
		db	 02h,0C9h,0CAh, 00h,0CBh,0CCh
		db	0E6h, 02h,0C9h,0CAh, 00h,0CBh
		db	0CCh,0E6h, 26h, 30h, 40h,0E6h
		db	 00h,0F0h, 00h, 0Fh,0FCh,0D4h
		db	 00h, 03h, 55h, 74h, 44h, 01h
		db	 88h, 1Ch, 88h, 01h, 44h, 00h
		db	 55h, 35h, 2Ah, 00h, 28h, 15h
		db	 54h,0E6h, 0Fh, 03h, 00h, 03h
		db	 00h, 01h, 00h, 02h, 00h, 0Fh
		db	 00h, 0Fh, 00h, 5Fh, 00h, 0Fh
		db	0E6h, 00h, 3Fh,0C0h,0E6h, 00h
		db	0F5h, 50h,0E6h, 00h,0F5h, 50h
		db	0C0h, 00h,0D5h, 40h,0D5h, 30h
		db	0D5h, 40h, 05h, 50h,0D5h, 00h
		db	0D0h, 00h,0D5h, 00h,0F4h, 00h
		db	0F4h, 00h, 05h,0D7h, 00h, 07h
		db	 0Dh, 01h, 00h, 01h, 00h, 05h
		db	 3Fh,0F5h, 00h, 05h, 35h, 55h
		db	0E6h, 00h, 14h,0E6h, 01h, 10h
		db	0E6h, 07h,0FCh, 00h,0FCh, 00h
		db	 7Fh, 00h, 7Fh, 00h, 4Fh,0C0h
		db	 4Fh,0C0h, 03h, 00h, 03h, 70h
		db	0E6h, 01h, 7Ch,0E6h, 01h, 57h
		db	0E6h, 01h, 15h,0E6h, 01h, 05h
		db	0E6h, 18h, 70h,0E6h, 01h, 40h
		db	 00h, 30h, 40h,0E6h, 00h,0F0h
		db	 00h, 0Fh,0FCh,0D4h, 00h, 03h
		db	 55h, 74h, 44h, 01h, 88h, 1Ch
		db	 88h, 01h, 44h, 00h, 55h, 35h
		db	 2Ah, 00h, 28h, 15h, 54h,0E6h
		db	 00h, 3Fh,0C0h,0E6h, 0Bh, 03h
		db	 00h, 03h, 00h, 01h, 00h, 02h
		db	 00h, 0Fh, 00h, 0Fh, 00h, 5Fh
		db	 00h, 0Fh, 05h,0D5h, 00h, 05h
		db	0E6h, 00h,0F5h, 50h,0E6h, 00h
		db	0F5h, 50h,0C0h, 00h,0D5h, 40h
		db	0D5h, 30h,0D5h, 40h, 05h, 50h
		db	0D5h, 00h,0F0h, 00h,0F5h, 00h
		db	0FDh, 00h,0FDh, 00h,0FFh, 00h
		db	0FFh, 00h, 0Dh,0E6h, 04h, 35h
		db	0E6h, 01h, 35h,0E6h, 01h, 35h
		db	0E6h, 01h, 30h,0E6h, 01h, 03h
		db	0E6h, 01h, 03h,0E6h, 02h, 5Fh
		db	0C0h, 5Fh,0C0h, 37h,0C0h, 77h
		db	0C0h, 0Fh, 00h, 7Fh,0E6h, 01h
		db	0FCh,0E6h, 01h,0FCh,0E6h, 01h
		db	0F0h,0E6h, 01h,0FCh,0E6h, 01h
		db	 3Fh,0E6h, 01h, 3Fh,0C0h,0E6h
		db	 00h,0F5h, 50h,0E6h, 00h,0F5h
		db	 50h,0C0h, 00h,0D5h, 40h,0D5h
		db	 30h,0D5h, 40h, 05h, 50h,0D5h
		db	 00h,0F0h, 00h,0F5h, 00h,0FCh
		db	 00h,0FCh, 00h, 05h,0D7h, 00h
		db	 07h, 0Dh, 03h, 00h, 03h, 00h
		db	 0Fh, 3Fh,0FFh, 00h, 0Fh, 3Fh
		db	0FFh,0E6h, 00h, 34h,0E6h, 01h
		db	 10h,0E6h, 07h,0F5h, 00h,0F5h
		db	 00h,0F5h, 00h,0F5h, 00h,0C5h
		db	 40h,0C5h, 40h, 01h, 00h, 01h
		db	 50h,0E6h, 01h,0D4h,0E6h, 01h
		db	 55h,0E6h, 01h, 15h,0E6h, 01h
		db	 05h,0E6h, 18h, 50h,0E6h, 01h
		db	 40h,0E6h, 01h,0F5h, 50h,0E6h
		db	 00h,0F5h, 50h,0C0h, 00h,0D5h
		db	 40h,0D5h, 30h,0D5h, 40h, 05h
		db	 50h,0D5h, 00h,0F0h, 00h,0F5h
		db	 00h,0FDh, 00h,0FDh, 00h,0F5h
		db	 00h,0F5h, 00h, 0Dh,0E6h, 04h
		db	 3Fh,0E6h, 01h, 3Fh,0E6h, 01h
		db	 3Fh,0E6h, 01h, 30h,0E6h, 01h
		db	 01h,0E6h, 01h, 01h,0E6h, 02h
		db	 5Fh, 40h, 5Fh, 40h, 0Dh, 40h
		db	0FDh, 40h, 05h, 00h,0F5h,0E6h
		db	 01h,0D4h,0E6h, 01h, 54h,0E6h
		db	 01h, 50h,0E6h, 01h, 54h,0E6h
		db	 01h, 15h, 00h, 30h, 40h,0E6h
		db	 00h,0F0h, 00h, 0Fh,0FCh,0D4h
		db	 00h, 03h, 55h, 74h, 44h, 01h
		db	 88h, 1Ch, 88h, 01h, 44h, 00h
		db	 55h, 35h, 2Ah, 00h, 28h, 15h
		db	 54h,0E6h, 00h, 0Fh,0D0h,0E6h
		db	 00h, 3Fh,0D4h,0E6h, 00h, 3Fh
		db	0D4h,0E6h, 00h, 3Fh, 54h,0E6h
		db	 00h, 15h, 50h, 3Dh, 50h, 3Dh
		db	 50h, 30h, 07h,0FDh, 50h,0FFh
		db	 55h,0FFh, 50h,0FFh,0A0h,0FFh
		db	0A0h, 00h, 05h,0E6h, 01h, 5Dh
		db	0E6h, 01h,0D0h,0E6h, 07h, 03h
		db	0E6h, 01h, 0Fh,0E6h, 01h, 3Fh
		db	0E6h, 01h, 3Fh,0FFh,0A0h,0FFh
		db	0A0h,0FDh, 68h,0FDh, 68h,0FCh
		db	 6Ah,0FCh, 6Ah, 00h, 18h,0F4h
		db	 1Ah,0E6h, 00h,0E4h, 0Ah,0E6h
		db	 00h, 90h, 0Ah,0E6h, 00h, 80h
		db	 0Ah,0E6h, 00h,0E0h, 0Ah,0E6h
		db	 0Ch, 80h,0E6h, 01h, 80h,0E6h
		db	 01h, 80h,0E6h, 01h, 80h,0E6h
		db	 01h,0A0h, 00h, 30h, 40h,0E6h
		db	 00h,0F0h, 00h, 0Fh,0FCh,0D4h
		db	 00h, 03h, 55h, 74h, 44h, 01h
		db	 88h, 1Ch, 88h, 01h, 44h, 00h
		db	 55h, 35h, 2Ah, 00h, 28h, 15h
		db	 54h,0E6h, 00h,0FFh, 40h,0E6h
		db	 01h, 03h,0E6h, 01h, 03h,0E6h
		db	 01h, 03h, 00h, 03h, 00h, 03h
		db	 00h, 01h, 00h, 02h, 00h, 3Ch
		db	 00h, 03h, 0Fh,0A8h, 00h, 03h
		db	 0Ah, 80h, 00h, 03h,0E6h, 00h
		db	0FDh, 50h, 00h, 05h,0FDh, 55h
		db	 00h, 15h, 55h, 55h,0D5h, 14h
		db	0D5h, 15h, 00h, 40h,0D5h, 41h
		db	 03h,0D8h,0D3h,0D9h, 00h, 74h
		db	 55h, 75h, 00h, 14h, 15h, 55h
		db	0E6h, 06h, 80h, 00h, 80h,0E6h
		db	 01h, 40h,0E6h, 01h, 40h,0E6h
		db	 05h, 40h,0E6h, 01h, 50h,0E6h
		db	 0Ch, 03h, 00h, 02h, 00h, 01h
		db	 00h, 02h, 00h, 07h, 00h, 02h
		db	 00h, 57h, 00h, 02h, 05h,0D0h
		db	0E6h, 02h,0F5h, 50h,0E6h, 00h
		db	0F5h, 50h,0C0h, 00h, 95h, 40h
		db	0D5h, 30h,0D5h, 40h, 05h, 50h
		db	0D5h, 00h,0F0h, 00h,0F5h, 00h
		db	0FFh, 40h,0FAh, 40h,0DFh, 54h
		db	0DEh, 54h, 0Dh,0E6h, 1Dh, 3Fh
		db	0D5h, 3Fh, 95h, 0Fh,0D0h, 0Bh
		db	0D5h, 0Fh,0C0h, 0Bh,0F5h, 03h
		db	 00h, 02h,0FDh,0E6h, 01h,0FFh
		db	0E6h, 01h, 3Fh,0E6h, 01h, 3Fh
		db	0E6h, 01h, 0Fh,0E6h, 00h, 40h
		db	0E6h, 01h, 40h,0E6h, 09h, 1Ch
		db	0E6h, 01h,0F0h,0E6h, 01h,0C0h
		db	0E6h, 06h, 03h,0E6h, 01h, 03h
		db	0E6h, 01h, 03h, 00h, 03h, 00h
		db	 03h, 00h, 01h, 00h, 02h, 00h
		db	 3Fh, 00h, 03h, 0Fh,0A8h,0E6h
		db	 00h, 0Ah, 80h,0E6h, 02h,0FDh
		db	 50h,0E6h, 00h,0FDh, 50h, 00h
		db	 03h, 55h, 43h,0D5h, 3Dh,0D5h
		db	 3Dh, 0Fh,0F4h,0DFh,0F7h,0FFh
		db	0D0h,0FFh,0D0h,0FFh, 54h,0FFh
		db	 54h, 35h, 55h, 35h, 55h,0E6h
		db	 06h,0C0h, 00h,0C0h,0E6h, 01h
		db	0D0h,0E6h, 01h,0D0h,0E6h, 01h
		db	0D7h,0C0h,0E6h, 00h,0F5h,0E6h
		db	 01h, 14h,0E6h, 00h, 55h, 00h
		db	 55h, 00h, 01h, 00h, 15h,0E6h
		db	 00h, 05h, 55h,0E6h, 00h, 05h
		db	 50h,0E6h, 00h, 01h, 40h,0E6h
		db	 01h, 50h,0E6h, 06h, 40h, 00h
		db	 50h, 00h, 40h, 00h, 40h,0E6h
		db	 1Fh, 03h, 5Eh,0E6h, 01h, 15h
		db	0E6h, 09h, 01h, 00h, 01h,0E6h
		db	 04h,0F5h, 50h,0E6h, 00h,0F5h
		db	 50h,0C0h, 00h, 95h, 40h,0D5h
		db	 00h,0D5h, 40h, 05h, 40h,0D5h
		db	 00h,0F0h,0A0h,0F5h, 00h,0FFh
		db	 17h,0FAh, 17h,0DFh,0EDh,0DEh
		db	 6Dh,0E6h, 1Ah, 80h, 00h, 80h
		db	 00h, 3Bh,0F7h, 3Bh,0C7h, 03h
		db	 7Ch, 03h, 70h, 00h,0BEh, 03h
		db	0BCh,0E6h, 00h, 01h,0DFh,0E6h
		db	 01h, 3Fh,0E6h, 01h, 7Fh,0E6h
		db	 01h, 0Fh,0E6h, 01h, 03h,0E6h
		db	 18h, 80h,0E6h, 01h,0C0h,0E6h
		db	 0Ch, 03h, 00h, 02h, 00h, 01h
		db	 00h, 02h, 00h, 07h, 00h, 02h
		db	 00h, 57h, 00h, 01h, 05h,0D1h
		db	 00h, 01h,0E6h, 00h,0F5h, 50h
		db	0E6h, 00h,0F5h, 50h,0C0h, 0Fh
		db	 95h, 4Fh,0D5h, 2Bh,0D5h, 4Bh
		db	 05h, 55h,0D5h, 15h,0F0h, 80h
		db	0F5h, 97h,0FAh, 00h,0BAh, 1Eh
		db	0F8h, 00h,0B8h, 5Ch,0E6h, 06h
		db	 80h, 00h, 80h, 00h,0C0h, 00h
		db	0C0h, 00h, 80h, 00h, 80h,0E6h
		db	 0Bh, 0Eh, 01h, 00h, 01h, 00h
		db	 01h, 00h, 01h, 00h, 01h, 00h
		db	 03h,0E6h

; --- Tile animation data continues. Labels locloop_1/locloop_2 below
;     are Sourcer artefacts; the bytes are tile-pattern / palette data.
;     Retained mnemonics assemble to the original data bytes exactly.
locloop_1:
		add	[bx],ax			; data 01 07
		out	1,al			; data E6 01
		pop	es			; data 07
		out	1,al			; data E6 01
		pop	es			; data 07
		out	1,al			; data E6 01
		db	0Fh			; data (Sourcer: pop cs)
		out	1,al			; data E6 01
		db	0Fh			; data (Sourcer: pop cs)
		clc				; data F8
		db	 00h,0F8h		; data (Sourcer: add al,bh)
		cld				; data FC
                           lock	add	[bx+si+3Eh],dh
		loopnz	locloop_2		; Loop if zf=0, cx>0


locloop_2:
		loopnz	locloop_1		; Loop if zf=0, cx>0

;*		add	ax,si
		db	 01h,0F0h		; data (Sourcer fake instr)
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		; data (Sourcer fake instr)
		db	0A0h,0E6h, 01h,0E0h,0E6h, 01h
		db	0C0h,0E6h, 07h, 02h, 0Ch,0E6h
		db	 01h, 0Fh, 3Fh,0F0h, 00h, 1Dh
		db	0FFh,0C0h, 22h, 35h, 11h,0C0h
		db	 11h, 14h, 22h,0C0h,0AAh, 00h
		db	 55h,0E4h, 14h, 00h, 2Bh,0A8h
		db	0E6h, 00h, 03h,0F4h, 01h, 00h
		db	 0Eh,0D5h,0E6h, 00h, 0Fh,0D5h
		db	 00h, 03h, 03h,0D7h, 0Dh, 6Bh
		db	 00h
		db	2Bh

_351TILAN	endp

;                              SUBROUTINE

sub_1		proc	near
		or	dl,ch
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		pop	ss
		add	ds:data_11e[bx+si],al
		add	[si],ch
		out	0Eh,al			; port 0Eh, DMA-1 clr mask reg
		db	0C0h, 00h,0C0h,0E6h, 01h, 40h
		db	 00h, 50h,0E6h, 01h, 7Ah,0E6h
		db	 1Ch, 0Eh,0E6h, 01h, 02h, 00h
		db	 3Fh, 00h, 3Fh, 00h,0FEh, 00h
		db	0FEh, 03h,0F2h, 03h,0F2h, 00h
		db	0C0h, 0Eh,0C0h,0E6h, 00h, 3Eh
		db	0E6h, 01h,0EAh,0E6h, 01h,0A8h
		db	0E6h, 01h,0A0h, 00h,0EBh,0A0h
		db	0E0h, 00h, 80h,0B0h, 80h, 00h
		db	0A0h, 00h,0AFh,0FCh,0A0h, 00h
		db	0AAh,0ACh,0E6h, 01h, 28h,0E6h
		db	 01h, 08h,0E6h, 06h, 02h, 0Ch
		db	0E6h, 01h, 0Fh, 3Fh,0F0h, 00h
		db	 1Dh,0FFh,0C0h, 22h, 35h, 11h
		db	0C0h, 11h, 14h, 22h,0C0h,0AAh
		db	 00h, 55h,0E4h, 14h, 00h, 2Bh
		db	0A8h,0E6h, 00h, 03h,0F4h, 01h
		db	 00h, 0Eh,0D5h,0E6h, 00h, 0Fh
		db	0D5h, 00h, 03h, 03h,0D7h, 0Dh
		db	 6Bh, 00h, 2Bh, 0Ah,0D5h,0E6h
		db	 01h, 17h, 00h, 80h, 00h,0BDh
		db	 00h,0BCh, 00h,0FFh, 00h,0FFh
		db	0E6h, 0Ah,0C0h, 00h,0C0h,0E6h
		db	 01h, 40h, 00h, 50h,0E6h, 01h
		db	 7Ah,0E6h, 01h,0ABh,0A0h,0A0h
		db	 00h, 03h,0FAh, 03h,0FAh, 03h
		db	0ECh, 03h,0EEh, 00h,0F0h, 00h
		db	0FEh,0E6h, 01h, 3Fh,0E6h, 01h
		db	 3Fh,0E6h, 01h, 0Fh,0E6h, 01h
		db	 3Fh,0E6h, 01h,0FCh, 00h,0B0h
		db	0E6h, 02h,0A8h,0E6h, 01h,0A8h
		db	0E6h, 01h,0A8h,0E6h, 01h, 08h
		db	0E6h, 01h,0C0h,0E6h, 01h,0C0h
		db	0E6h, 05h, 03h,0F4h, 01h, 00h
		db	 0Eh,0D5h,0E6h, 00h, 0Fh,0D5h
		db	 00h, 03h, 03h,0D7h, 0Dh, 6Bh
		db	 00h, 2Bh, 0Ah,0D5h,0E6h, 01h
		db	 17h, 00h, 80h, 00h, 3Dh, 00h
		db	 3Ch,0E6h, 19h, 0Ah,0E6h, 01h
		db	 02h, 00h,0AFh, 00h,0AFh, 00h
		db	0AFh, 00h,0AFh, 02h,0A3h, 02h
		db	0A3h, 00h, 80h, 0Ah, 80h,0E6h
		db	 00h, 2Bh,0E6h, 01h,0AAh,0E6h
		db	 01h,0A8h,0E6h, 01h,0A0h, 00h
		db	0EBh,0A0h,0E0h, 00h,0C0h,0B0h
		db	0C0h, 00h,0F0h, 00h,0FFh,0F8h
		db	0F0h, 00h,0FFh,0E8h,0E6h, 01h
		db	 28h,0E6h, 01h, 08h,0E6h, 06h
		db	 01h, 00h, 0Eh,0D5h,0E6h, 00h
		db	 0Fh,0D5h, 00h, 03h, 03h,0DBh
		db	 0Dh, 6Bh, 00h, 2Bh, 0Ah,0D5h
		db	0E6h, 01h, 17h, 00h, 80h, 00h
		db	0BDh, 00h,0BCh, 00h,0AFh, 00h
		db	0AFh,0E6h, 0Ah,0C0h, 00h,0C0h
		db	 00h, 80h, 00h, 40h, 00h, 50h
		db	0E6h, 01h, 7Ah,0E6h, 01h,0BBh
		db	0A0h,0B0h, 00h, 02h,0FAh, 02h
		db	0FAh, 02h,0B0h, 02h,0BFh, 00h
		db	0A0h, 00h,0AFh,0E6h, 01h, 2Bh
		db	0E6h, 01h, 2Ah,0E6h, 01h, 0Ah
		db	0E6h, 01h, 2Ah,0E6h, 01h,0A8h
		db	 00h,0B0h,0E6h, 02h,0F4h,0E6h
		db	 01h,0F4h,0E6h, 01h,0D4h,0E6h
		db	 01h, 04h,0E6h, 01h, 80h,0E6h
		db	 01h, 80h,0E6h, 03h, 02h, 0Ch
		db	0E6h, 01h, 0Fh, 3Fh,0F0h, 00h
		db	 1Dh,0FFh,0C0h, 22h, 35h, 11h
		db	0C0h, 11h, 14h, 22h,0C0h,0AAh
		db	 00h, 55h,0E4h, 14h, 00h, 2Bh
		db	0A8h,0E6h, 00h, 0Fh,0F0h, 04h
		db	 00h, 0Bh,0E8h,0E6h, 00h, 3Fh
		db	0E8h,0E6h, 00h, 3Fh,0A8h,0E6h
		db	 00h, 0Ah,0A8h, 0Fh, 54h, 0Fh
		db	 54h,0E5h, 00h, 02h,0D5h,0ADh
		db	 5Ah, 00h, 0Ah, 0Dh, 75h, 0Ch
		db	0E6h, 0Eh, 03h,0E6h, 01h, 03h
		db	0E6h, 01h, 03h,0E6h, 01h, 03h
		db	0E6h, 01h, 0Dh, 0Eh,0D7h, 0Eh
		db	0C0h, 3Ah,0BEh, 3Ah,0BEh,0EAh
		db	 3Eh,0EAh, 3Eh, 28h, 00h, 68h
		db	 3Fh,0E6h, 00h, 50h, 2Fh,0E6h
		db	 00h, 50h, 0Ah,0E6h, 00h, 50h
		db	 02h,0E6h, 00h, 50h, 0Fh,0A0h
		db	0E6h, 01h,0BAh,0E6h, 01h, 0Bh
		db	0E6h, 07h,0C0h,0E6h, 01h,0E0h
		db	0E6h, 01h,0B8h,0E6h, 01h,0E8h
		db	 00h, 02h, 0Ch,0E6h, 01h, 0Fh
		db	 3Fh,0F0h, 00h, 2Eh,0FFh,0C0h
		db	 22h, 3Ah, 11h,0C0h, 11h, 28h
		db	 22h,0C0h,0AAh, 00h, 55h,0E4h
		db	 14h, 00h, 2Bh,0A8h,0E6h, 00h
		db	 03h,0FDh,0E6h, 07h, 03h, 00h
		db	 03h,0E6h, 01h, 03h,0E6h, 01h
		db	 03h,0E6h, 05h, 02h,0E6h, 01h
		db	 0Ah, 01h, 00h, 0Eh,0D5h,0F0h
		db	 00h,0FFh,0D5h,0E8h, 00h,0EBh
		db	0D5h,0E8h,0F9h,0E8h,0F9h, 02h
		db	 3Fh, 92h, 80h, 1Fh, 55h, 9Fh
		db	 00h, 3Eh, 80h,0BEh,0AAh, 2Ah
		db	 00h,0AAh,0A8h,0E6h, 00h, 40h
		db	0E6h, 01h, 40h,0E6h, 01h, 40h
		db	 00h, 40h, 00h, 40h,0E6h, 01h
		db	 80h, 00h,0FCh,0E6h, 01h, 15h
		db	0F0h, 40h, 00h, 01h, 50h, 40h
		db	 00h, 01h, 00h, 0Eh,0D5h,0E6h
		db	 00h, 0Fh,0D5h, 00h, 01h, 03h
		db	 59h, 0Dh, 75h, 00h, 35h, 05h
		db	 54h, 00h, 01h, 00h, 75h,0E6h
		db	 00h, 01h,0FDh, 01h, 5Ch, 3Eh
		db	0F9h, 3Eh, 79h,0E6h, 0Ah, 40h
		db	 00h, 40h,0E6h, 01h, 40h, 00h
		db	 50h,0E6h, 01h, 55h,0E6h, 01h
		db	 07h, 50h,0E6h, 03h, 03h,0E6h
		db	 01h, 03h,0E6h, 09h, 38h,0E6h
		db	 01h, 0Fh,0E6h, 01h, 03h,0E6h
		db	 02h,0EBh,0F4h,0E9h,0F4h, 0Bh
		db	0D0h
loc_3:
		stosw				; Store ax to es:[di]
		rol	byte ptr [bp+di],1	; Rotate
		shr	bh,1			; Shift w/zeros fill
		rol	byte ptr [bx+si],1	; Rotate
		inc	ax
		inc	word ptr [bx+si-1Ah]
;*		add	ch,bh
		db	 00h,0FDh		; data (Sourcer fake instr)
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		hlt				; Halt processor
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		hlt				; Halt processor
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		push	ax
		out	0,al			; port 0, DMA-1 bas&add ch 0
		jo	loc_3			; Jump if overflow=1
		and	ax,3
		add	ax,[bx+si]
		add	[bx+si],ax
		or	ax,1E6h
		or	ax,0E6h
		add	di,bp
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		cmc				; Complement carry
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
;*		aam	1			; undocumented inst
		db	0D4h, 01h		; data (Sourcer fake instr)
		add	ds:data_13e,cl
		add	[bx],cl
;*		aad	0C0h			; undocumented inst
		db	0D5h,0C0h		; data (Sourcer fake instr)
;*		add	bl,al
		db	 00h,0C3h		; data (Sourcer fake instr)
;*		aad	7Ch			; '|' undocumented inst
		db	0D5h, 7Ch		; data (Sourcer fake instr)
loc_4:
		std				; Set direction flag
		js	loc_4			; Jump if sign=1
		pop	di
		cmc				; Complement carry
		pop	si
		mov	al,ds:data_14e
		pop	es
		std				; Set direction flag
		xor	ax,35D5h
;*		aad	0D5h			; undocumented inst
		db	0D5h,0D5h		; data (Sourcer fake instr)
		push	sp
;*		aad	54h			; 'T' undocumented inst
		db	0D5h, 54h		; data (Sourcer fake instr)
		out	0,al			; port 0, DMA-1 bas&add ch 0
		inc	ax
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		inc	ax
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		inc	ax
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		; data (Sourcer fake instr)
		db	 40h, 00h, 40h,0E6h, 01h, 5Ch
		db	0E6h, 01h, 15h,0F0h,0E6h, 00h
		db	 01h, 50h,0E6h, 01h, 03h, 00h
		db	 17h, 00h, 03h, 00h, 03h,0E6h
		db	 16h, 55h, 00h, 55h, 00h, 40h
		db	 00h, 68h,0E6h, 01h,0AAh,0A0h
		db	0E6h, 00h, 0Ah,0A0h,0E6h, 00h
		db	 02h, 80h,0E6h, 00h, 0Ah,0E6h
		db	 10h, 03h, 00h, 03h, 00h, 03h
		db	 00h, 03h,0E6h, 0Eh, 01h, 00h
		db	 0Eh,0D5h,0C0h, 00h,0CFh,0D5h
		db	0F8h, 01h,0FBh, 59h,0ADh,0F5h
		db	0A0h, 35h,0D5h, 5Ch,0D0h, 01h
		db	 02h,0D5h, 32h, 80h, 01h, 55h
		db	 2Bh, 54h, 00h, 2Fh, 15h, 2Fh
		db	0E6h
		db	 0Ah, 40h
loc_5:
		add	[bx+si-1Ah],al
;*		add	[bx+si+0],ax
		db	 01h, 40h, 00h		; data (Sourcer fake instr)
		db	0D0h,0E6h, 01h, 55h,0E6h, 01h
		db	 07h, 50h,0E6h, 01h, 17h, 32h
		db	 96h, 00h, 0Fh, 7Ah, 0Eh, 00h
		db	 05h, 00h, 05h,0E6h, 01h, 0Fh
		db	0E6h, 01h, 07h, 00h, 01h, 00h
		db	 06h,0E6h, 01h, 03h,0E6h, 02h
		db	 80h, 70h, 80h, 00h, 80h, 00h
		db	 80h, 00h, 80h, 00h,0C0h,0E6h
		db	 01h,0C0h,0E6h, 01h,0E0h,0E6h
		db	 01h,0F0h,0E6h, 01h,0F0h,0E6h
		db	 01h,0F8h,0E6h, 1Ch, 01h, 00h
		db	 01h, 01h, 00h, 0Eh,0D5h,0E6h
		db	 00h, 0Fh
loc_6:
;*		aad	0			; undocumented inst
		db	0D5h, 00h		; data (Sourcer fake instr)
		add	[bp+di],ax
		pop	cx
;*		add	bx,si
		db	 01h,0F3h		; data (Sourcer fake instr)
;*		add	ax,si
		db	 01h,0F0h		; data (Sourcer fake instr)
		add	ds:data_15e,di
		pop	es
		cmc				; Complement carry
		add	[si],al
		jmp	short loc_5
sub_1		endp

			                        ; (data -- Sourcer: no entry point)
		call	sub_1
		stc				; Set carry flag
		cld				; Clear direction
		jns	loc_6			; Jump if not sign
		push	es
		pop	ds
		inc	ax
		out	0,al			; port 0, DMA-1 bas&add ch 0
                           lock	out	2Ch,al			; port 2Ch ??I/O Non-standard
;*		add	si,sp
		db	 01h,0E6h		; data (Sourcer fake instr)
		add	[bp+di],ax
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
;*		aam	0E3h			; undocumented inst
		db	0D4h,0E3h		; data (Sourcer fake instr)
;*		aam	3Eh			; '>' undocumented inst
		db	0D4h, 3Eh		; data (Sourcer fake instr)
		db	0C0h, 0Eh,0C0h, 7Dh, 00h, 3Dh
		db	0C0h,0E6h, 00h,0FBh,0E6h, 01h
		db	0FCh,0E6h, 01h,0FCh,0E6h, 01h
		db	0F8h,0E6h, 01h,0C0h,0E6h, 04h
		db	 03h,0E6h, 01h, 03h,0E6h, 01h
		db	 03h,0E6h, 01h, 01h,0E6h, 09h
		db	 01h, 00h, 02h,0E6h, 08h, 0Fh
		db	0F0h, 44h, 03h, 3Bh,0F4h,0C0h
		db	 01h, 3Fh,0F4h, 40h, 01h, 3Fh
		db	0D4h,0E6h, 00h, 3Fh, 54h, 40h
		db	 01h, 95h, 56h,0E6h, 02h,0C0h
		db	0E6h, 01h,0C0h,0E6h, 01h, 40h
		db	0E6h, 01h, 40h,0E6h, 09h, 40h
		db	 00h, 80h,0E6h, 02h, 0Fh,0E6h
		db	 01h, 01h,0E6h, 11h, 01h, 00h
		db	 02h,0E6h, 00h, 05h, 50h,0D0h
		db	 07h,0E6h, 00h, 7Fh,0D5h, 40h
		db	 01h, 3Fh,0D4h,0E6h, 00h, 3Fh
		db	 54h,0C0h, 01h,0F5h, 55h,0FFh
		db	 55h,0FFh, 55h,0CFh, 51h, 3Fh
		db	 55h,0B0h, 04h, 3Dh, 55h,0E6h
		db	 00h, 50h,0E6h, 01h, 40h,0E6h
		db	 18h, 02h,0E6h, 01h, 03h,0E6h
		db	 01h, 0Bh,0E6h, 01h, 0Eh,0E6h
		db	 01h, 0Eh,0E6h, 01h, 08h,0E6h
		db	 08h,0BFh,0D4h, 3Fh,0D4h, 8Dh
		db	 50h, 0Dh, 50h,0E6h, 27h, 01h
		db	0E6h, 01h, 01h,0E6h, 03h, 01h
		db	0E6h, 01h, 01h, 41h, 00h, 02h
		db	 80h,0C2h, 80h, 05h, 00h,0C8h
		db	 00h, 13h,0FCh,0D1h, 00h
loc_7:
		push	cs
		std				; Set direction flag
		jo	$+2			; delay for I/O
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			; data (Sourcer fake instr)
		std				; Set direction flag
		adc	[bx+si],al
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			; data (Sourcer fake instr)
		cmc				; Complement carry
		inc	ax
		add	ds:data_13e[bx],cl
;*		add	ch,dh
		db	 00h,0F5h		; data (Sourcer fake instr)
		push	sp
		out	2,al			; port 2, DMA-1 bas&add ch 1
;*		xor	dh,ah
		db	 30h,0E6h		; data (Sourcer fake instr)
		add	[bx+si],si
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		shl	dh,1			; Shift w/zeros fill
		add	[bx+si-1Ah],dx
		add	[bx+si-1Ah],ax
		or	[di],ax
		push	ax
		rol	byte ptr [bx],1		; Rotate
		out	0,al			; port 0, DMA-1 bas&add ch 0
		jg	loc_7			; Jump if >
		add	[bx+di],al
		aas				; Ascii adjust
;*		aam	0E6h			; undocumented inst
		db	0D4h,0E6h		; data (Sourcer fake instr)
		add	[di],bh
		push	bp
		add	[si],al
		xor	ax,3F54h
		push	sp
		aas				; Ascii adjust
		push	sp
		std				; Set direction flag
		add	[di],bh
		push	sp
		test	dh,ah
		cmp	si,sp
		out	0,al			; port 0, DMA-1 bas&add ch 0
		push	ax
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		inc	ax
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		; data (Sourcer fake instr)
		db	 80h,0E6h, 14h, 02h,0E6h, 01h
		db	 03h,0E6h, 01h, 0Ah,0E6h, 01h
		db	 0Eh,0E6h, 01h, 08h,0E6h, 0Ch
		db	0BFh,0F4h, 3Fh,0F4h, 95h,0F4h
		db	 15h,0F4h, 00h, 54h, 00h, 54h
		db	 01h, 50h, 01h, 50h,0E6h, 00h
		db	 03h, 50h,0E6h, 00h, 03h, 54h
		db	0E6h, 00h, 03h, 54h,0E6h, 00h
		db	 03h, 50h,0E6h, 03h, 0Ch,0E6h
		db	 01h, 0Ch,0E6h, 01h, 0Dh,0E6h
		db	 01h, 07h,0E6h, 01h, 01h,0E6h
		db	 09h, 84h, 01h, 40h, 01h, 46h
		db	 00h,0A0h, 00h, 13h, 3Fh,0E0h
		db	 10h, 0Dh,0EFh, 50h, 00h, 05h
		db	0FFh, 50h, 00h, 04h,0FFh
loc_8:
		push	dx
		add	[bx+di],al
		std				; Set direction flag
		push	dx
		out	0,al			; port 0, DMA-1 bas&add ch 0
		adc	ax,0E655h
		adc	al,80h
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		inc	ax
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		inc	ax
		out	2,al			; port 2, DMA-1 bas&add ch 1
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			; data (Sourcer fake instr)
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		add	ax,[bx+si]
		add	[bx+si],ax
		add	ah,dh
		or	ax,[bp+di]
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		add	ah,dh
		add	[di],al
		push	ax
		rol	byte ptr [di],1		; Rotate
		out	0,al			; port 0, DMA-1 bas&add ch 0
		jg	loc_8			; Jump if >
		inc	ax
		add	ds:data_12e[bx],bh
		add	[bx+54h],bh
		xor	[bx+si],al
		xor	ax,3F54h
		push	sp
		aas				; Ascii adjust
		push	sp
		les	dx,dword ptr [di-5]	; Load seg:offset ptr
		push	bp
		inc	word ptr [bx+di]
		aas				; Ascii adjust
		push	bp
		add	[bp+si],al
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		add	sp,si
		add	[bp+si],ax
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		add	ah,dh
		add	[bp+si],ax
		out	0Ch,al			; port 0Ch, DMA-1 clr byte ptr
		lahf				; Load ah from flags
		cmc				; Complement carry
		pop	ds
		cmc				; Complement carry
		mov	ch,54h			; 'T'
		xor	ax,0BF54h
		add	[bx],bh
;*		add	bh,cl
		db	 00h,0CFh		; data (Sourcer fake instr)
		or	byte ptr [bx],80h
		add	byte ptr [bx+si],0Fh
		inc	ax
		add	byte ptr [bx+si],3Fh	; '?'
		inc	ax
		out	0,al			; port 0, DMA-1 bas&add ch 0
		sbb	ax,0E640h
		add	[di],al
		inc	ax
		add	[bp+si],al
		add	[bx+di],al
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		or	ax,1E6h
		or	ax,1400h
		add	[bx+di],ch
		add	[bx+si],ch
		add	[si],dl
		out	0Ah,al			; port 0Ah, DMA-1 mask reg bit
		mov	al,ds:data_3e
;*		add	[si+0],dl
		db	 00h, 54h, 00h		; data (Sourcer fake instr)
		db	0A9h,0E6h, 01h, 05h,0E6h, 13h
		db	 0Ch, 00h, 03h, 00h, 14h, 00h
		db	 2Bh, 00h, 28h, 00h, 14h,0E6h
		db	 01h, 34h,0E6h, 01h, 1Dh, 00h
		db	 02h, 80h, 05h, 40h, 01h, 40h
		db	 02h, 80h,0E6h, 06h, 0Ch, 00h
		db	 03h, 40h, 01h, 50h, 0Eh,0AFh
		db	 00h,0A8h, 00h, 55h,0E6h, 12h
		db	 50h, 00h,0A0h, 00h, 20h, 00h
		db	 50h,0E6h, 14h, 05h, 00h, 2Ah
		db	 00h, 2Ah, 00h, 95h,0E6h, 01h
		db	0A0h,0E6h, 12h, 40h, 00h, 80h
		db	0E6h, 01h,0B0h,0E6h, 01h,0B0h
		db	 00h, 28h, 00h, 94h, 00h, 14h
		db	 00h, 28h,0E6h, 0Ch, 30h, 00h
		db	0C0h, 00h, 28h, 00h,0D4h, 00h
		db	 14h, 00h, 28h,0E6h, 01h, 2Ch
		db	0E6h, 01h,0B8h, 01h, 40h, 02h
		db	0A0h, 02h, 80h, 01h, 40h,0E6h
		db	 07h, 0Ah, 00h, 05h, 00h, 04h
		db	 00h, 0Ah,0E6h, 17h, 30h, 02h
		db	0C0h, 0Ah, 80h,0F5h, 70h, 15h
		db	 00h,0AAh,0E6h, 10h, 03h,0E6h
		db	 01h, 03h,0E6h, 01h, 03h,0E6h
		db	 01h, 01h,0E6h, 0Dh, 0Ch, 00h
		db	 33h,0E6h, 04h, 0Fh,0F0h, 44h
		db	 03h, 3Bh,0F4h,0C0h, 01h, 3Fh
		db	0F4h, 40h, 01h, 3Fh,0D4h,0E6h
		db	 00h, 3Fh, 54h,0E6h, 00h, 15h
		db	 54h, 05h, 50h,0E6h, 00h,0C0h
		db	0E6h, 01h,0C0h,0E6h, 01h, 40h
		db	0E6h, 01h, 40h,0E6h, 0Dh, 40h
		db	 00h, 94h,0E6h, 02h, 0Fh, 00h
		db	 01h, 00h, 02h, 00h, 0Ah, 00h
		db	 05h, 00h, 05h, 00h, 0Ah, 00h
		db	 02h, 00h, 01h,0E6h, 01h, 01h
		db	0E6h, 08h,0FFh,0D5h, 00h, 01h
		db	0FFh,0D6h,0E6h, 00h,0FFh, 55h
		db	0E6h, 00h, 35h, 55h, 95h, 54h
		db	 55h, 54h, 3Fh, 54h, 7Fh, 54h
		db	 04h, 00h, 3Bh, 5Ch, 7Fh, 74h
		db	 3Fh, 74h,0E6h, 00h, 50h, 00h
		db	 40h, 00h, 80h, 00h,0A0h, 00h
		db	 50h, 00h, 50h, 00h,0A0h,0E6h
		db	 01h,0F0h, 00h, 40h, 00h, 90h
		db	 00h,0A0h, 00h, 50h, 00h, 50h
		db	 00h,0A0h,0E6h, 04h, 01h,0E6h
		db	 01h, 01h,0E6h, 01h, 07h,0E6h
		db	 01h
data_8		db	5			; Data table (indexed access)
		db	0E6h, 01h, 04h,0E6h, 08h, 75h
		db	 55h, 35h, 55h,0FDh, 15h, 3Dh
		db	 15h, 7Fh, 34h, 3Fh, 34h, 10h
		db	 00h, 15h, 14h,0E6h, 00h, 0Dh
		db	 3Ch,0E6h, 00h, 0Dh, 75h,0E6h
		db	 00h, 0Dh, 45h,0E6h, 00h, 3Dh
		db	 40h,0E6h, 17h, 28h, 00h, 14h
		db	 00h, 14h, 00h, 2Bh, 00h, 04h
		db	 00h, 09h,0E6h, 01h, 03h,0E6h
		db	 16h, 2Bh, 00h,0D4h, 00h, 54h
		db	 00h,0ABh,0E6h, 18h, 30h, 00h
		db	0C0h, 00h, 8Ah, 00h, 75h, 00h
		db	 01h, 00h, 02h,0E6h, 16h, 82h
		db	 80h, 79h, 40h, 41h, 00h,0AAh
		db	0E6h, 1Bh, 15h, 00h, 0Ah, 00h
		db	 0Ah, 00h, 05h, 40h,0E6h, 01h
		db	0E0h,0E6h, 01h,0A0h, 01h, 40h
		db	 00h,0A0h, 00h, 80h, 03h, 40h
		db	 0Ch, 00h, 03h, 80h,0E6h, 00h
		db	 0Eh,0E6h, 33h, 50h, 00h,0A0h
		db	0E6h, 02h, 07h, 0Ch, 50h, 02h
		db	0A6h, 00h,0A0h, 0Eh, 58h,0E6h
		db	 12h, 20h, 00h, 90h,0E6h, 01h
		db	0C0h,0E6h, 1Bh, 0Ch, 00h, 02h
		db	0E6h, 01h, 0Fh,0E6h, 00h, 80h
		db	 05h, 00h, 05h, 00h, 02h, 80h
		db	 02h, 00h, 01h,0E0h,0E6h, 01h
		db	0F0h, 00h, 14h, 00h, 2Ah, 02h
		db	 28h, 05h,0D0h, 00h, 50h, 07h
		db	0ABh,0E6h, 01h, 07h,0E6h, 16h
		db	 40h, 00h, 80h, 00h, 50h, 00h
		db	0A0h, 00h, 20h, 00h, 50h,0E6h
		db	 27h, 14h, 00h, 28h, 00h, 28h
		db	 00h,0D4h,0E6h, 00h,0D4h, 00h
		db	 2Bh, 00h, 2Ah, 00h,0D5h,0E6h
		db	 1Ah, 01h, 41h, 02h, 9Eh, 00h
		db	 82h, 00h, 7Dh,0E6h, 12h, 0Ch
		db	 00h, 03h, 00h, 51h, 00h,0AEh
		db	 00h, 80h, 00h, 40h,0E6h, 1Ch
		db	0A8h, 00h, 50h, 00h
		db	50h
loc_9:
		add	ah,ds:data_1e[bx+si]
		pop	es
		and	dh,0
		add	ax,200h
		add	byte ptr [di],0
		add	[bx+si],ax
		add	al,al
		add	[bx+si],dh
;*		add	ax,ax
		db	 01h,0C0h		; data (Sourcer fake instr)
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		jo	loc_9			; Jump if overflow=1
		xor	cx,[bp+si]
		add	[di],al
		out	0,al			; port 0, DMA-1 bas&add ch 0
		loopnz	$+2			; Loop if zf=0, cx>0

		or	dh,[bx+si]
		db	 65h, 40h, 05h, 00h, 3Ah, 70h
		db	0E6h, 17h, 30h, 00h, 40h,0E6h
		db	 01h,0F0h, 01h,0E6h, 00h,0A0h
		db	 00h,0A0h, 01h, 40h, 00h, 40h
		db	 07h, 80h,0E6h, 00h, 0Fh, 00h
		db	 28h, 00h, 54h,0E6h

locloop_10:
		add	al,2
		add	[bx+di],al
		add	[bp+si],cl
		add	[di],al
		add	[si],al
		add	[bp+si],cl
		out	0Eh,al			; port 0Eh, DMA-1 clr mask reg
		adc	al,40h			; '@'
		or	sp,[bx+si]
		or	al,[bx+si]
		mov	ch,0E0h
		out	0,al			; port 0, DMA-1 bas&add ch 0
		loopnz	locloop_10		; Loop if zf=0, cx>0

		sbb	ax,[bp+di]
		add	al,0E6h
		add	[bx],cl
		out	0,al			; port 0, DMA-1 bas&add ch 0
		dec	word ptr [di]
		inc	ax
		add	[bx],dh
		pop	es
		inc	bp
		add	[bp+si],bl
;*		add	dx,cx
		db	 01h,0CAh		; data (Sourcer fake instr)
		add	[di],dl
		add	[bx+di],al
		add	dx,si
		out	0Ch,al			; port 0Ch, DMA-1 clr byte ptr
		inc	ax
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		rol	byte ptr [bx+si],1	; Rotate
		inc	ax
		add	ds:data_5e[bx+si],al
;*		add	[bx+si+0],al
		db	 00h, 40h, 00h		; data (Sourcer fake instr)
		db	 50h, 00h,0A0h,0E6h, 00h, 02h
		db	 0Fh, 55h, 01h, 00h, 3Eh,0D4h
		db	0E6h, 00h, 7Bh,0D4h, 01h, 40h
		db	0EAh, 90h,0FAh,0A8h,0F9h, 57h
		db	 0Eh, 50h,0FEh,0AFh,0FEh, 00h
		db	0BEh, 80h,0FEh,0A0h,0BEh,0A0h
		db	 80h, 00h, 40h,0E6h, 07h, 10h
		db	 00h, 20h, 00h, 40h, 00h, 80h
		db	 00h,0A8h, 00h, 54h, 00h, 10h
		db	 00h, 20h,0E6h, 04h, 02h,0E6h
		db	 01h, 0Bh,0E6h, 01h, 2Eh,0E6h
		db	 01h, 28h,0E6h, 03h, 03h,0E6h
		db	 01h, 0Fh,0E6h, 01h, 02h,0E6h
		db	 02h, 6Eh,0A8h, 66h,0A8h,0B9h
		db	0A8h, 31h,0A8h, 0Ch, 2Ah,0ECh
		db	 2Ah, 00h, 20h,0F4h, 25h,0E6h
		db	 00h,0F4h, 15h,0E6h, 00h,0D0h
		db	 15h,0E6h, 00h, 40h, 15h,0E6h
		db	 00h, 90h, 05h,0E6h, 18h, 50h
		db	0E6h, 04h,0D0h, 00h, 0Fh, 03h
		db	0E0h, 00h, 1Fh, 03h, 74h, 00h
		db	 02h, 00h,0D0h, 03h, 06h, 00h
		db	 31h, 0Dh, 46h, 0Ch, 02h, 31h
		db	0A5h, 00h, 45h, 7Bh,0BAh, 03h
		db	 50h,0E8h,0A0h,0E6h, 00h,0C0h
		db	0E6h, 01h,0D0h,0E6h, 01h, 54h
		db	 00h, 40h, 00h,0A4h, 00h, 40h
		db	 00h,0A4h, 00h, 80h, 00h, 40h
		db	 00h, 40h, 00h, 80h,0E6h, 14h
		db	 02h,0E6h, 01h, 0Bh,0E6h, 01h
		db	 2Eh,0E6h, 01h, 28h,0E6h, 00h
		db	0F8h,0ABh,0FAh, 54h, 0Bh,0C3h
		db	0FBh,0F4h,0FAh, 0Dh,0F0h, 8Dh
		db	0EEh,0AAh,0C0h,0AAh,0ABh,0FAh
		db	 0Bh,0FAh, 82h,0FCh, 36h,0FDh
		db	 00h,0B6h,0F5h,0B6h, 00h, 28h
		db	0D4h,0E9h,0E6h, 02h, 40h, 00h
		db	 80h,0E6h, 01h, 50h, 00h, 45h
		db	 00h, 5Ah, 00h, 04h, 40h, 48h
		db	 80h,0E6h, 00h, 40h,0E6h, 01h
		db	 40h,0E6h, 01h, 50h, 00h, 0Fh
		db	 54h, 3Fh, 6Bh, 72h, 41h, 7Eh
		db	 7Eh,0FAh, 00h,0F0h, 29h,0EEh
		db	0A1h,0C0h,0AAh,0ABh,0D5h, 0Bh
		db	0DAh, 82h, 6Ah, 3Eh, 55h, 00h
		db	0A0h,0F5h,0ADh, 00h, 20h, 94h
		db	0E9h,0E6h, 00h,0C0h,0E6h, 00h
		db	0ECh, 50h, 00h, 03h,0BBh, 78h
		db	 00h, 02h,0E0h,0E8h, 0Ch, 40h
		db	 00h,0AAh,0BCh, 85h, 43h, 2Ah
		db	0ACh, 2Ah,0A0h, 15h, 48h, 45h
		db	 40h, 8Ah,0A0h,0E6h, 0Dh, 03h
		db	0E6h, 01h, 0Fh, 00h, 01h,0E6h
		db	 03h, 01h, 00h, 05h, 00h, 02h
		db	0E6h, 06h, 20h,0C0h,0E6h, 01h
		db	0F0h,0FFh, 00h, 02h,0B0h,0FCh
		db	 00h, 52h,0E0h,0ACh, 00h,0ABh
		db	 80h, 54h, 00h, 50h, 00h,0AEh
		db	 40h,0E6h, 01h, 01h,0E6h, 07h
		db	 04h, 00h, 08h, 00h, 01h, 00h
		db	 02h, 00h, 2Ah, 00h, 15h, 00h
		db	 04h, 00h, 08h,0E6h, 02h,0A0h
		db	 00h, 5Ah, 90h, 01h, 00h, 3Eh
		db	0D4h,0E6h, 00h, 3Fh,0D4h, 01h
		db	 40h, 0Eh, 95h, 0Ah, 95h,0F5h
		db	 55h, 85h, 70h, 7Ah, 75h, 00h
		db	 55h, 01h, 05h, 05h, 75h, 05h
		db	 01h,0E6h, 19h, 0Dh,0E6h, 02h
		db	 17h,0F5h, 17h,0F0h, 15h,0FDh
		db	 15h,0FCh, 54h, 30h, 54h, 35h
		db	 04h, 00h,0D4h, 3Dh,0E6h, 00h
		db	0D4h, 3Fh,0E6h, 00h,0D4h, 0Fh
		db	0E6h, 00h, 50h, 03h,0E6h, 00h
		db	 50h, 0Dh, 40h,0E6h, 01h,0D0h
		db	0E6h, 01h, 74h,0E6h, 01h, 14h
		db	0E6h, 03h, 40h,0E6h, 01h,0D0h
		db	0E6h, 01h, 40h,0E6h, 06h, 03h
		db	0E6h, 01h, 0Fh,0E6h, 01h, 3Fh
		db	 00h, 01h, 00h, 36h, 00h, 01h
		db	 00h, 36h, 00h, 02h, 00h, 01h
		db	 00h, 01h, 00h, 02h,0E6h, 02h
		db	 0Eh, 00h,0F0h, 00h, 0Ah, 80h
		db	0F0h, 00h, 2Eh, 80h, 40h, 00h
		db	 0Bh, 00h, 70h, 40h, 4Ch, 00h
		db	0B2h, 90h,0A0h,0C0h, 55h, 14h
		db	 51h, 00h,0AEh,0D4h, 0Dh, 40h
		db	 02h, 95h,0E6h, 03h, 01h, 00h
		db	 02h,0E6h, 01h, 0Fh, 00h, 53h
		db	 00h,0AFh, 01h, 10h, 02h, 23h
		db	0E6h, 01h, 03h,0E6h, 01h, 03h
		db	0E6h, 01h, 0Fh,0C5h, 15h, 3Ah
		db	 55h,0C3h,0D0h, 3Fh,0D5h,0F0h
		db	 55h,0F1h, 05h, 55h, 75h, 55h
		db	 01h, 5Fh,0D5h, 5Fh,0D0h, 3Fh
		db	 41h,0FFh, 7Ch, 7Dh, 00h, 7Dh
		db	0F5h, 14h, 00h,0D7h, 3Dh,0E6h
		db	 0Eh, 40h,0E6h, 01h,0D0h,0E6h
		db	 01h, 74h,0E6h, 01h, 14h,0E6h
		db	 02h, 01h, 00h, 02h, 37h,0E6h
		db	 00h, 0Fh,0DDh, 44h, 00h, 1Bh
		db	 07h, 40h, 30h, 17h, 00h, 01h
		db	 3Dh, 56h,0C1h, 50h, 36h,0A5h
		db	 00h,0A8h, 17h, 54h, 01h, 51h
		db	 06h,0A2h, 03h,0D0h,0F7h,0DCh
		db	 03h, 44h,0F7h, 74h, 00h, 55h
		db	0D4h, 05h, 45h, 75h, 95h, 01h
		db	 5Fh,0D5h,0AFh,0D0h,0ABh, 41h
		db	 57h, 7Ch, 05h, 00h,0F5h,0F5h
		db	 04h, 00h,0D7h, 3Dh,0E6h, 1Ah
		db	 3Dh, 40h, 3Dh, 40h,0E6h, 03h
		db	 0Ch, 00h, 31h, 00h, 01h, 00h
		db	 36h, 00h, 01h, 00h, 02h,0E6h
		db	 0Eh, 30h, 00h, 3Fh, 40h, 30h
		db	 00h, 3Fh, 40h, 73h, 40h,0BFh
		db	 40h, 7Ch, 00h,0BDh, 40h, 30h
		db	 00h
		db	3Fh
		db	'@'
		db	'0', 0
		db	'?@0', 0
		db	'?@', 0Dh, '@', 0Dh, '@', 0
		db	'?', 0
		db	'?', 0
		db	'5', 0
		db	'5', 0
		db	'*', 0
		db	'*', 0
		db	'5', 0
		db	'5', 0
		db	'*', 0
		db	'*', 0
		db	'5', 0
		db	'5', 0
		db	'*', 0
		db	'*', 0
		db	 0Fh, 00h, 0Fh,0FFh, 00h,0FFh
		db	 00h, 55h, 00h, 55h, 00h,0ABh
		db	 00h
loc_11:
		stosw				; Store ax to es:[di]
;*		add	[di+0],dl
		db	 00h, 55h, 00h		; data (Sourcer fake instr)
		db	 55h, 00h,0ABh, 00h,0ABh, 00h
		db	 55h, 00h, 55h, 00h,0ABh, 00h
		db	0ABh, 00h,0FCh, 00h,0FCh,0E6h
		db	 00h,0FFh, 00h, 0Ah, 00h,0C4h
		db	 00h, 1Bh, 00h,0C4h, 00h, 5Bh
		db	 00h,0CFh, 00h, 55h, 00h,0F4h
		db	 00h,0FBh, 00h, 44h, 00h, 5Bh
		db	 00h, 44h, 00h, 5Bh, 00h, 15h
		db	 00h, 15h,0F4h, 00h,0F4h, 00h
		db	 04h, 00h, 54h, 00h, 04h, 00h
		db	 54h, 00h, 44h, 00h, 54h, 00h
		db	 14h, 00h, 54h, 00h, 04h, 00h
		db	 54h, 00h, 04h, 00h, 54h, 00h
		db	 50h, 00h, 50h,0E6h, 13h, 3Fh
		db	0C0h, 15h, 40h,0FAh, 00h, 7Fh
		db	0C0h,0EAh, 00h, 7Eh,0C0h,0EAh
		db	 00h, 7Eh,0C0h,0EAh, 00h, 7Eh
		db	0C0h,0E0h, 00h, 6Fh,0C0h,0E0h
		db	 00h, 6Fh,0C0h,0EAh, 00h, 7Eh
		db	0C0h,0EAh, 00h, 7Eh,0C0h, 3Ah
		db	 00h, 1Eh,0C0h, 3Ah, 00h, 1Eh
		db	0C0h, 0Eh, 00h, 07h,0C0h, 03h
		db	0C0h, 01h, 40h,0E6h, 22h, 3Fh
		db	0C0h, 15h, 40h,0FAh, 00h, 7Fh
		db	0C0h,0EAh, 00h, 7Eh,0C0h,0EAh
		db	 00h, 7Eh,0C0h,0EAh, 00h, 7Eh
		db	0C0h, 00h, 01h, 00h, 02h, 00h
		db	 0Ch, 00h, 31h, 00h, 01h, 00h
		db	 36h,0E6h, 12h,0E0h, 00h, 6Fh
		db	0C0h,0E0h, 00h, 6Fh,0C0h,0EAh
		db	 00h, 7Eh,0C0h,0EAh, 00h, 7Eh
		db	0C0h, 3Ah, 00h, 1Eh,0C0h, 3Ah
		db	 00h, 1Eh,0C0h, 0Eh, 00h, 07h
		db	0C0h, 03h,0C0h, 01h, 40h,0E6h
		db	 0Bh, 0Fh, 00h, 0Fh, 00h, 35h
		db	 00h, 35h, 00h, 2Ah, 00h, 2Ah
		db	 00h, 35h, 00h, 35h, 00h, 2Ah
		db	 00h, 2Ah,0E6h, 0Ah,0FFh, 00h
		db	0FFh, 00h, 55h, 40h, 55h, 40h
		db	0AAh,0C0h,0AAh,0C0h, 55h, 40h
		db	 55h, 40h,0AAh,0C0h,0AAh,0C0h
		db	 00h, 35h, 00h, 35h, 00h, 2Ah
		db	 00h, 2Ah, 00h, 35h, 00h, 35h
		db	 00h, 2Ah, 00h, 2Ah, 00h, 15h
		db	 00h, 15h, 00h, 0Ah, 00h, 0Ah
		db	 00h, 03h, 00h, 03h,0E6h, 02h
		db	 55h, 40h, 55h, 40h,0AAh,0C0h
		db	0AAh,0C0h, 55h, 40h, 55h, 40h
		db	0AAh,0C0h,0AAh,0C0h, 55h, 80h
		db	 55h, 80h,0ABh, 00h,0ABh, 00h
		db	 5Ch, 00h
		db	5Ch
loc_12:
;*		add	al,dh
		db	 00h,0F0h		; data (Sourcer fake instr)
;*		add	al,dh
		db	 00h,0F0h		; data (Sourcer fake instr)
		out	0Ch,al			; port 0Ch, DMA-1 clr byte ptr
		inc	word ptr [bx+si]
		stosb				; Store al to es:[di]
		add	dx,ax
		add	bl,bh
		add	dx,[bx+si+2]
;*		jg	loc_13			;*Jump if >
		db	 7Fh, 03h		; data (Sourcer fake instr)
		push	ax
		add	bh,[bx+3]
		push	ax
		add	bh,[bx-1Ah]
		or	dh,al
		add	ds:data_4e[bx+si],ah
;*		add	[bx+si+0],bh
		db	 00h, 78h, 00h		; data (Sourcer fake instr)
		db	 5Ch, 00h, 78h, 00h, 5Ch, 00h
		db	 78h, 00h, 5Ch, 00h, 78h, 00h
		db	 03h, 00h, 02h,0FFh, 03h, 00h
		db	 02h,0FFh, 03h, 50h, 02h, 7Fh
		db	 03h, 50h, 02h, 7Fh, 00h,0D0h
		db	 00h,0BFh, 00h,0D0h, 00h, 9Fh
		db	 00h, 30h, 00h, 2Fh, 00h, 0Fh
		db	 00h, 0Ah, 0Ch, 00h,0F8h, 00h
		db	 0Ch, 00h,0F8h, 00h, 5Ch, 00h
		db	 78h, 00h, 5Ch, 00h, 78h, 00h
		db	 70h, 00h, 60h, 00h, 70h, 00h
		db	 60h, 00h,0C0h, 00h, 80h,0E6h
		db	 04h, 0Fh,0E6h, 01h, 0Ch, 00h
		db	 01h, 00h, 0Ch, 00h, 05h, 00h
		db	 0Ch, 00h, 05h, 00h, 0Fh, 00h
		db	 0Fh, 00h, 04h, 00h, 05h, 00h
		db	 04h, 00h, 05h, 00h, 01h, 00h
		db	 01h,0FFh, 40h,0AFh,0E7h, 01h
		db	0B5h,0E7h, 01h,0B5h, 40h,0F4h
		db	 40h, 55h, 40h, 41h, 40h,0B5h
		db	0E7h, 01h,0B5h,0E7h, 01h,0B5h
		db	 40h, 55h, 00h, 55h,0E6h, 1Bh
		db	 03h,0F8h, 00h, 78h, 02h, 04h
		db	 01h, 54h, 02h, 0Ch, 01h,0DCh
		db	 03h,0CEh, 02h,0DDh, 02h, 36h
		db	 01h, 75h, 02h, 04h, 01h,0D4h
		db	 02h, 04h, 01h,0D4h, 02h, 08h
		db	 01h,0D8h, 03h,0E0h, 03h,0E0h
		db	0E6h, 02h, 30h, 00h, 8Ch, 00h
		db	 80h, 00h, 6Ch, 00h, 80h, 00h
		db	 40h,0E6h, 23h, 03h,0FCh, 02h
		db	0A8h, 00h, 5Fh, 03h,0FEh, 00h
		db	 57h, 03h, 7Eh, 00h, 57h, 03h
		db	 7Eh, 00h, 57h, 03h, 7Eh, 00h
		db	 07h, 03h,0F6h, 00h, 07h, 03h
		db	0F6h, 00h, 57h, 03h, 7Eh, 00h
		db	 57h, 03h, 7Eh, 00h, 5Ch, 03h
		db	 78h, 00h, 5Ch, 03h, 78h, 00h
		db	 70h, 03h,0E0h, 03h,0C0h, 02h
		db	 80h,0E6h, 22h, 03h,0FCh, 02h
		db	0A8h, 00h, 5Fh, 03h,0FEh, 00h
		db	 57h, 03h, 7Eh, 00h, 57h, 03h
		db	 7Eh, 00h, 57h, 03h, 7Eh, 00h
		db	 07h, 03h,0F6h, 00h, 07h, 03h
		db	0F6h, 00h, 57h, 03h, 7Eh, 00h
		db	 57h, 03h, 7Eh, 00h, 5Ch, 03h
		db	 78h, 00h, 5Ch, 03h, 78h, 00h
		db	 70h, 03h,0E0h, 03h,0C0h, 02h
		db	 80h, 80h, 00h, 40h, 00h, 30h
		db	 00h, 8Ch, 00h, 80h, 00h, 6Ch
		db	0E6h, 2Ch, 0Fh, 00h, 0Ah, 00h
		db	 3Dh, 00h, 2Dh,0E6h, 16h,0FFh
		db	 00h,0AAh, 00h, 07h,0C0h,0F7h
		db	 80h, 00h, 35h, 00h, 27h, 00h
		db	 35h, 00h, 27h, 00h, 35h, 00h
		db	 27h, 00h, 30h, 00h, 2Fh, 00h
		db	 30h, 00h, 2Fh, 00h, 35h, 00h
		db	 27h, 00h, 35h, 00h, 27h, 00h
		db	 0Dh, 00h, 0Bh, 05h,0C0h,0F7h
		db	 80h, 05h,0C0h,0F7h, 80h, 05h
		db	0C0h,0F7h, 80h, 00h,0C0h,0FFh
		db	 80h, 00h,0C0h,0FFh, 80h, 05h
		db	0C0h,0F7h, 80h, 05h,0C0h,0F7h
		db	 80h, 07h, 00h,0F6h,0E6h, 00h
		db	 0Dh, 00h, 09h, 00h, 03h, 00h
		db	 02h,0E6h, 16h, 07h, 00h,0F6h
		db	 00h, 0Ch, 00h,0F8h, 00h,0F0h
		db	 00h,0A0h,0E6h, 32h,0F8h, 00h
		db	 0Ah, 00h,0F4h, 00h, 05h, 00h
		db	 0Ah,0E6h, 01h, 07h,0E6h, 01h

locloop_14:
		push	cs
		add	[bx+si],ch
		add	[si],dl
		add	[bx+si],dl
		add	[bx+si],ch
		out	22h,al			; port 22h ??I/O Non-standard
		add	ax,[bx+si]
		sbb	al,0
		push	ax
		add	[bx],ch
		add	ds:data_2e[bx+si],ah
		out	1,al			; port 1, DMA-1 bas&cnt ch 0
		loopnz	locloop_14		; Loop if zf=0, cx>0

;*		add	[bx+si+0],si
		db	 01h, 70h, 00h		; data (Sourcer fake instr)
		db	 14h, 00h, 28h, 00h, 08h, 00h
		db	 14h,0E6h, 04h

seg_a		ends



		end	start
