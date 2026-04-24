
PAGE  59,132

;==========================================================================
;
;  321MP1D - Map Data Table: Cavern of Malicia, level 1, floor D (dungeon/exit)
;
;  Cavern/labyrinth map resource file loaded as MP1D.MDT (zelres3).
;  Part of the 16-file MP{level}{floor} dungeon-map set (320..335) covering
;  levels 1-6 of the Zeliard labyrinth.
;
;  NOT executable code -- Sourcer mis-decoded the header bytes and data
;  tables as x86 instructions (the first two bytes are really the file
;  size word, not 'cmp [bp+si],al' etc).  The bogus mnemonics below all
;  re-emit the same byte sequence.
;
;  General MDT layout (all files in this group share this pattern):
;    [0x00]   file-size word + flag/reserved word
;    [0x04+]  pointer table (WORDs 0xCNNN - runtime segment 0xC000)
;            -> tile grid, event table, exit table, script trailer
;    [mid]    tile_grid            - column/row-strip tile-index data
;                                    (values like 0x3F06, 0xC4NN, 0xC5NN)
;    [later]  event_records        - NPC/door/exit records (FF-terminated)
;    [late]   cavern_name          - pascal-encoded 'Cavern of Malicia'
;    [end]    exit/trigger records - door warp coords + script bytes
;    [eof]    terminator           - 0xFFFFFFFF (header_1 label)
;
;  Runtime segment base = 0xC000.  Pointer 0xCNNN resolves to file_off NNN.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_321MP1D	proc	far


_321MP1D	endp


strategy_1	proc	far
		cmp	[bp+si],al
		add	[bx+si],al

; ------------------------------------------------------------------
; mdt_header -- file-size word, flag byte, and table of WORD pointers
; into the runtime 0xC000 segment.  Sourcer mis-decoded the leading
; bytes as instructions; they are actually: size word + flag word
; + attributes pointer + offset of 'strategy' (tile grid start) + ...
; ------------------------------------------------------------------
attributes	dw	0C20Ah
pointers	dw	offset strategy
		dw	0C1A4h
char_dev	db	'╕а╗абада'
		db	0F5h,0C1h, 36h,0C2h, 01h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h,0A4h
		db	0C1h, 3Fh, 06h, 3Fh, 06h, 3Fh
		db	 06h, 3Fh, 06h, 3Fh, 06h, 3Fh
		db	 06h, 3Fh, 06h, 3Fh, 06h, 3Fh
		db	 06h, 3Fh, 06h, 3Fh, 06h, 3Fh
		db	 06h, 3Fh, 06h, 3Fh, 06h, 3Fh
		db	 06h, 09h, 06h,0C5h, 45h, 64h
		db	 2Eh, 06h, 06h, 06h,0C5h,0C8h
		db	46h
strategy_1	endp



; ------------------------------------------------------------------
; ------------------------------------------------------------------
; tile_grid -- main cavern/map tile-index data.  Encoded as column
; or row strips of 1-byte tile indices.  Common runs: 0x3F06 (wall
; boundary), 0x2C06 (column separator), plus palette-range values
; (0xC4-0xCC) that select tile rows in the tile bank.  Originally
; labeled 'strategy' by Sourcer because the header pointer landed
; on this offset.
; ------------------------------------------------------------------
strategy	proc	far
		dec	cx
		db	0C9h, 69h,0C4h, 2Ch, 06h, 05h
		db	 06h,0C7h, 59h,0C9h,0CAh, 48h
		db	 83h,0CAh,0C4h, 2Ch, 06h, 75h
		db	 46h, 69h, 87h,0C4h, 2Ch, 06h
		db	 65h,0C5h, 69h, 89h,0C4h, 2Ch
		db	 06h, 65h,0C7h,0C9h,0CAh, 8Bh
		db	0C4h, 2Ch, 06h, 65h,0C7h,0C9h
		db	 8Ch,0C4h, 2Ch, 06h, 65h,0C8h
		db	0C9h, 8Ch,0C5h, 2Ch, 06h, 65h
		db	0C8h,0C9h, 8Ch,0C4h, 2Ch, 06h
		db	 65h,0C8h,0C9h, 8Ch,0C4h, 2Ch
		db	 06h, 65h,0C8h,0C9h, 8Ch,0C4h
		db	 2Ch, 06h, 55h,0C5h,0C8h,0C9h
		db	 8Ch,0C5h, 2Ch, 06h, 55h,0C8h
		db	 48h, 8Ch,0C5h, 2Ch, 06h, 55h
		db	0C8h,0C9h, 8Dh,0C4h, 2Ch, 06h
		db	 55h,0C8h,0C9h, 8Dh,0C4h, 2Ch
		db	 06h, 55h,0C8h,0CAh, 8Dh,0C4h
		db	 2Ch, 06h, 55h,0C7h,0CAh, 8Dh
		db	0C4h, 2Ch, 06h, 55h,0C7h,0CAh
		db	 8Dh,0C4h, 2Ch, 06h, 55h,0C7h
		db	0CAh, 8Dh,0C5h, 2Ch, 06h, 45h
		db	0C5h,0C8h,0CAh, 8Dh,0C4h, 2Ch
		db	 06h, 45h,0C8h, 49h, 8Dh,0C4h
		db	 2Ch, 06h, 45h,0C8h, 49h, 8Dh
		db	0C4h, 2Ch, 06h, 45h,0C7h, 49h
		db	 8Dh,0C4h, 2Ch, 06h, 45h,0C7h
		db	 49h, 8Dh,0C4h, 2Ch, 06h, 45h
		db	0C8h, 49h, 8Dh,0C4h, 2Ch, 06h
		db	 45h,0C3h,0C8h, 49h, 8Ch,0C5h
		db	 2Ch, 06h, 55h,0C7h, 49h, 8Ch
		db	 2Dh, 06h, 55h,0C7h, 49h, 8Ch
		db	0C4h, 2Ch, 06h, 55h,0C8h, 49h
		db	 8Ch, 2Dh, 06h, 55h,0C8h, 49h
		db	 8Ch,0C4h, 2Ch, 06h, 55h,0C3h
		db	0C8h,0CAh, 8Ch,0C4h, 2Ch, 06h
		db	 65h,0C8h,0CAh, 8Ch, 2Dh, 06h
		db	 65h,0C8h,0CAh, 8Ch,0C4h, 2Ch
		db	 06h, 65h,0C8h,0CAh, 8Ch,0C4h
		db	 2Ch, 06h, 65h,0C8h, 49h, 8Bh
		db	0C4h, 2Ch, 06h, 65h,0C7h, 49h
		db	 8Bh,0C4h, 2Ch, 06h, 65h,0C7h
		db	 49h, 8Bh,0C4h, 2Ch, 06h, 65h
		db	0C8h, 49h, 8Bh,0C4h, 2Ch, 06h
		db	 65h,0C3h,0C7h,0CAh, 8Bh,0C4h
		db	 2Ch, 06h, 75h,0C7h,0CAh, 8Bh
		db	 2Dh, 06h, 75h,0C8h,0CAh,0C9h
		db	0CAh, 89h,0C4h, 2Ch, 06h, 05h
		db	 06h,0CAh, 48h, 59h, 86h,0C4h
		db	 2Ch, 06h, 05h, 06h,0C3h,0C8h
		db	 46h, 58h, 79h,0C4h, 2Ch, 06h
		db	 08h, 06h, 42h,0C6h,0C8h,0C7h
		db	0C9h, 59h,0C4h, 2Ch, 06h, 0Bh
		db	 06h,0C3h, 55h, 42h, 2Dh, 06h
		db	 3Fh, 06h, 3Fh, 06h, 3Fh, 06h
		db	 3Fh, 06h, 3Fh, 06h, 3Fh, 06h
		db	 3Fh, 06h, 3Fh, 06h, 3Fh, 06h
		db	 3Fh, 06h, 3Fh, 06h, 3Fh, 06h
		db	 3Fh, 06h,0FFh,0FFh,0FFh,0FFh
		db	0FFh,0FFh, 1Bh, 00h, 0Eh,0C1h
		db	 00h, 1Ah, 00h, 0Fh, 00h,0FFh
		db	0FFh,0FFh, 2Fh, 00h, 0Eh, 82h
		db	 00h, 8Dh, 00h, 20h, 80h, 03h
		db	 00h, 20h,0FFh,0FFh, 02h, 00h
		db	 08h, 24h,0C2h, 00h,0FFh, 2Fh
		db	0C2h,0FFh,0FFh,0FFh,0FFh, 03h
		db	 00h, 20h,0BEh,0C1h, 00h,0FFh
		db	0C0h,0C1h,0FFh,0FFh,0FFh,0FFh
		db	 00h, 00h,0FFh, 10h,0C0h, 24h
		db	0C2h, 0Ah,0C0h,0AAh,0C1h, 0Dh
		db	0C2h, 00h, 00h, 0Ah,0C2h, 09h
		db	 00h,0FFh,0FFh,0FFh,0FFh, 16h
		db	0AFh, 00h, 11h

; ------------------------------------------------------------------
; cavern_name -- pascal-encoded cavern/area name 'Cavern of Malicia'.
; Preceded by small descriptor bytes; the length byte just before
; the quoted string matches the string length (0x11/0x0E/etc).
; ------------------------------------------------------------------
		db	'Cavern of Malicia'
		db	 99h, 00h, 00h, 01h,0FFh, 01h
		db	 00h, 00h, 10h,0C0h, 24h,0C2h
		db	 0Ah,0C0h,0B6h,0C1h, 26h,0C2h
		db	 05h,0FFh, 00h, 00h,0FFh,0FFh
		db	0FFh,0FFh, 26h, 00h, 10h,0FFh
		db	 76h, 00h, 00h, 20h, 00h, 00h
		db	 00h, 02h, 00h, 08h, 00h, 00h

; ------------------------------------------------------------------
; exit_records -- trailing event/exit/door records and script bytes
; triggered on cavern load.  Ends with 0xFFFFFFFF (header_1 label).
; ------------------------------------------------------------------
header_1	dd	0FFFFFFFFh
strategy	endp


seg_a		ends


		end
