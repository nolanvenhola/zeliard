
PAGE  59,132

;==========================================================================
;
;  330MP4D - Map Data Table: Cavern of Glacial, level 4, floor D (dungeon/exit)
;
;  Cavern/labyrinth map resource file loaded as MP4D.MDT (zelres3).
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
;    [late]   cavern_name          - pascal-encoded 'Cavern of Glacial'
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

_330MP4D	proc	far


_330MP4D	endp


strategy_1	proc	far
		dec	bp
		add	al,[bx+si]
		add	[bp+di],dh
		retn	49h
strategy_1	endp

		db	0DEh,0C1h
char_dev	db	'‡¡‚¡¸¡˛¡'
		db	 1Eh,0C2h, 4Bh,0C2h, 04h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h,0DEh
		db	0C1h, 14h, 07h,0ABh, 0Ah, 07h
		db	0C6h, 08h, 07h,0ABh, 14h, 07h
		db	0ABh, 06h, 07h,0C3h, 05h, 07h
		db	0C8h, 05h, 07h,0ABh, 66h,0C8h
		db	 0Fh, 07h,0ABh, 14h, 07h,0ABh
		db	 08h, 07h,0C3h,0C7h,0C6h, 56h
		db	0C6h, 76h,0ABh, 14h, 07h,0ABh
		db	 0Fh



; ------------------------------------------------------------------
; tile_grid -- main cavern/map tile-index data.  Encoded as column
; or row strips of 1-byte tile indices.  Common runs: 0x3F06 (wall
; boundary), 0x2C06 (column separator), plus palette-range values
; (0xC4-0xCC) that select tile rows in the tile bank.  Originally
; labeled 'strategy' by Sourcer because the header pointer landed
; on this offset.
; ------------------------------------------------------------------
strategy	proc	far
		pop	es
		db	0C8h, 66h,0ABh, 14h, 07h,0ABh
		db	 14h, 07h,0ABh, 07h, 07h,0C6h
		db	 66h,0C6h, 06h, 07h,0ABh, 14h
		db	 07h,0ABh, 66h,0C8h, 05h, 07h
		db	0C8h, 08h, 07h,0ABh, 14h, 07h
		db	0ABh, 14h, 07h,0ABh, 07h, 07h
		db	0C8h, 56h,0CAh,0C9h,0C8h, 83h
		db	0C4h, 46h,0ABh, 07h, 07h,0CAh
		db	0C9h, 88h,0C4h, 46h,0ABh, 06h
		db	 07h,0CAh,0C9h, 89h,0C4h, 46h
		db	0ABh, 76h,0CAh,0C9h, 8Bh,0C4h
		db	 46h,0ABh, 76h,0C8h, 8Ch,0C4h
		db	 46h,0ABh, 76h, 8Dh,0C4h,0C8h
		db	0C7h,0ABh, 66h,0C8h, 8Dh,0C5h
		db	 46h,0ABh, 56h,0C6h,0C8h, 8Dh
		db	0C4h, 46h,0ABh, 66h,0C8h, 8Dh
		db	0C4h, 46h,0ABh, 66h,0C8h, 8Dh
		db	0C4h, 46h,0ABh, 66h,0C8h, 8Dh
		db	0C5h, 46h,0ABh, 56h,0CAh,0C9h
		db	 8Dh,0C5h, 46h,0ABh, 56h,0CAh
		db	0C9h, 8Dh,0C4h, 46h,0ABh, 56h
		db	0CAh,0C9h, 8Dh,0C4h, 46h,0ABh
		db	 56h,0CAh,0C9h, 8Dh,0C6h, 46h
		db	0ABh, 66h,0C8h, 8Dh,0C4h, 46h
		db	0ABh, 66h,0C8h, 8Dh,0C4h, 46h
		db	0ABh, 66h, 8Eh,0C5h, 46h,0ABh
		db	 56h,0C8h, 8Eh,0C4h,0C7h,0C8h
		db	0ABh, 46h,0CAh,0C9h, 8Eh,0C4h
		db	 46h,0ABh, 46h,0C8h, 8Fh,0C4h
		db	 46h,0ABh, 56h, 8Fh,0C4h, 46h
		db	0ABh, 56h,0CAh,0C9h, 8Dh,0C4h
		db	 46h,0ABh, 46h,0C8h,0CAh,0C9h
		db	 8Dh,0C4h, 46h,0ABh, 56h,0C8h
		db	0CAh,0C9h, 8Ch,0C5h, 46h,0ABh
		db	 66h,0CAh,0C9h, 8Ch,0C5h, 46h
		db	0ABh, 66h,0CAh,0C9h, 8Ch,0C4h
		db	 46h,0ABh, 56h,0C8h,0CAh,0C9h
		db	 8Ch,0C6h, 46h,0ABh, 56h,0C8h
		db	0CAh,0C9h, 8Ch,0C4h, 46h,0ABh
		db	 66h,0C8h, 8Dh,0C4h, 46h,0ABh
		db	 66h, 8Eh,0C5h, 46h,0ABh, 76h
		db	 8Dh,0C4h,0C7h,0C8h,0ABh, 66h
		db	0C8h, 8Dh,0C4h, 46h,0ABh, 66h
		db	0C8h, 8Dh,0C4h, 46h,0ABh, 76h
		db	0C8h, 8Ch,0C4h, 46h,0ABh, 76h
		db	0C8h, 8Ch,0C4h, 46h,0ABh, 66h
		db	0C8h,0CAh,0C9h, 8Bh,0C4h,0C8h
		db	0C7h,0ABh, 05h, 07h,0CAh,0C9h
		db	 8Ah,0C4h, 46h,0ABh, 05h, 07h
		db	0CAh,0C9h, 8Ah,0C5h, 46h,0ABh
		db	 56h,0C8h,0C7h,0C8h,0CAh,0C9h
		db	 8Ah,0C4h, 46h,0ABh, 06h, 07h
		db	0CAh,0C9h, 89h,0C4h, 46h,0ABh
		db	 09h, 07h,0CAh,0C9h, 86h,0C4h
		db	 46h,0ABh, 06h, 07h,0C8h, 76h
		db	0CAh,0C9h, 83h,0C4h, 46h,0ABh
		db	 0Ah, 07h,0C8h, 05h, 07h,0C6h
		db	 46h,0ABh, 08h, 07h,0C6h, 0Ah
		db	 07h,0ABh, 66h,0C6h, 0Fh, 07h
		db	0ABh, 0Bh, 07h,0C3h, 07h, 07h
		db	0ABh, 0Eh, 07h,0C8h, 76h,0ABh
		db	 0Fh, 07h,0C6h,0C7h,0C6h, 46h
		db	0ABh, 08h, 07h,0C6h, 05h, 07h
		db	0C6h, 66h,0ABh, 06h, 07h,0C8h
		db	 0Ch, 07h,0ABh, 0Dh, 07h,0C8h
		db	 05h, 07h,0ABh, 14h, 07h,0ABh
		db	 14h, 07h,0ABh, 14h, 07h,0ABh
		db	 14h, 07h,0ABh, 14h, 07h,0ABh
		db	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 1Bh, 00h, 0Eh,0C1h, 08h,0E0h
		db	 00h, 12h, 00h,0FFh,0FFh,0FFh
		db	 2Fh, 00h, 0Eh, 82h, 0Bh, 19h
		db	 00h, 0Eh, 80h, 1Ch, 00h, 10h
		db	0FFh,0FFh, 1Ch, 00h, 10h,0F7h
		db	0C1h, 0Eh, 00h,0FFh,0FFh, 18h
		db	 00h,0FFh, 10h,0C0h, 49h,0C2h
		db	 0Ah,0C0h,0E4h,0C1h, 36h,0C2h
		db	 06h, 06h, 33h,0C2h, 0Fh, 00h
		db	0FFh,0FFh,0FFh,0FFh, 16h,0AFh
		db	 02h, 11h

; ------------------------------------------------------------------
; cavern_name -- pascal-encoded cavern/area name 'Cavern of Glacial'.
; Preceded by small descriptor bytes; the length byte just before
; the quoted string matches the string length (0x11/0x0E/etc).
; ------------------------------------------------------------------
		db	'Cavern of Glacial'
		db	 99h, 00h, 03h, 07h,0FFh, 07h
		db	 06h, 06h, 10h,0C0h, 49h,0C2h
		db	 0Ah,0C0h,0F0h,0C1h, 18h, 00h
		db	0FFh,0FFh,0FFh,0FFh

; ------------------------------------------------------------------
; exit_records -- trailing event/exit/door records and script bytes
; triggered on cavern load.  Ends with 0xFFFFFFFF (header_1 label).
; ------------------------------------------------------------------
header_1	dd	0FFFFFFFFh
strategy	endp


seg_a		ends


		end
