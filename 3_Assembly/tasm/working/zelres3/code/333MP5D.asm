
PAGE  59,132

;==========================================================================
;
;  333MP5D - Map Data Table: Cavern of Cementar, level 5, floor D (dungeon/exit)
;
;  Cavern/labyrinth map resource file loaded as MP5D.MDT (zelres3).
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
;    [late]   cavern_name          - pascal-encoded 'Cavern of Cementar'
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

zr3_33		proc	far


zr3_33		endp


strategy_1	proc	far
		db	 6Bh, 02h, 00h, 00h

; ------------------------------------------------------------------
; mdt_header -- file-size word, flag byte, and table of WORD pointers
; into the runtime 0xC000 segment.  Sourcer mis-decoded the leading
; bytes as instructions; they are actually: size word + flag word
; + attributes pointer + offset of 'strategy' (tile grid start) + ...
; ------------------------------------------------------------------
attributes	dw	0C23Dh
pointers	dw	offset strategy
		dw	0C1DEh
char_dev	db	'‡¡‚¡¸¡˛¡'
		db	 27h,0C2h, 69h,0C2h, 05h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h,0DEh
		db	0C1h, 8Dh,0D0h,0D1h,0D6h,0C7h
		db	0CBh, 76h,0C6h, 46h,0CBh,0C7h
		db	0A4h, 8Dh,0D0h,0D7h,0C3h,0C4h
		db	0CBh,0C5h,0C9h, 07h, 07h,0A4h
		db	 8Dh,0C3h,0C7h, 4Ah,0C8h,0C7h
		db	 4Ah,0C7h,0CBh,0C7h,0CBh, 56h
		db	0A4h, 8Dh,0C4h, 66h,0C9h, 08h
		db	 07h
strategy_1	endp



; ------------------------------------------------------------------
; tile_grid -- main cavern/map tile-index data.  Encoded as column
; or row strips of 1-byte tile indices.  Common runs: 0x3F06 (wall
; boundary), 0x2C06 (column separator), plus palette-range values
; (0xC4-0xCC) that select tile rows in the tile bank.  Originally
; labeled 'strategy' by Sourcer because the header pointer landed
; on this offset.
; ------------------------------------------------------------------
strategy	proc	far
		movsb				; Mov [si] to es:[di]
		db	 8Dh,0C3h,0CBh, 46h, 4Ah,0C5h
		db	0CBh, 56h,0CBh, 56h,0A4h, 8Dh
		db	0C3h, 46h,0C8h, 01h, 19h, 81h
		db	0C4h, 46h,0C9h, 46h,0C5h,0C7h
		db	0A4h, 8Eh,0C4h,0CBh,0D8h,0D9h
		db	 82h,0C4h,0C7h,0C9h,0C7h,0CBh
		db	 56h,0A4h, 94h,0C3h, 66h,0C6h
		db	 46h,0A4h, 94h,0C3h,0C6h, 05h
		db	 07h,0A4h, 94h,0C4h, 46h,0C5h
		db	 46h,0C9h,0C7h,0A4h, 94h,0C4h
		db	0CCh, 01h, 19h,0D8h, 46h,0CBh
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C4h,0C9h,0C7h,0A4h
		db	 99h,0C3h,0C7h,0C9h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C3h,0C5h,0C7h,0A4h
		db	 99h,0C3h, 46h,0A4h, 99h,0C4h
		db	 46h,0A4h, 99h,0C3h, 46h,0A4h
		db	 99h,0C3h, 46h,0A4h, 99h,0C3h
		db	0C7h,0C9h,0A4h, 99h,0C3h,0C5h
		db	0C7h,0A4h, 99h,0C3h, 46h,0A4h
		db	 99h,0C3h,0C9h,0C7h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C4h, 46h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h,0C7h,0C5h,0A4h, 99h,0C3h
		db	 46h,0A4h, 99h,0C4h, 46h,0A4h
		db	 99h,0C3h, 46h,0A4h, 99h,0C3h
		db	0C7h,0C9h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h, 46h,0A4h, 99h,0C3h,0C5h
		db	0C7h,0A4h, 99h,0C3h, 46h,0A4h
		db	 99h,0C3h,0C9h,0C7h,0A4h, 99h
		db	0C4h, 46h,0A4h, 99h,0C3h, 46h
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h,0C7h,0C5h,0A4h, 99h,0C3h
		db	 46h,0A4h, 99h,0C3h, 46h,0A4h
		db	 99h,0C3h, 46h,0A4h, 99h,0C3h
		db	 46h,0A4h, 99h,0C4h,0C7h,0C9h
		db	0A4h, 99h,0C3h, 46h,0A4h, 99h
		db	0C3h,0C9h,0C7h,0A4h, 99h,0C3h
		db	 46h,0A4h, 99h,0C3h, 46h,0A4h
		db	 99h,0C3h,0C5h,0C7h,0A4h, 94h
		db	0C3h,0C6h,0D9h,0D8h, 81h, 56h
		db	0A4h, 94h,0C4h,0C7h,0C8h,0D8h
		db	 66h,0A4h, 94h,0C3h,0C7h,0D8h
		db	0C9h, 66h,0A4h, 94h,0C3h,0C7h
		db	0C9h,0C7h, 4Ah, 46h,0A4h, 8Dh
		db	0CDh,0CEh,0CFh,0C3h,0D9h,0D8h
		db	 81h,0C4h, 06h, 07h,0A4h, 8Dh
		db	0D0h,0D1h,0D2h,0C3h,0CBh,0C5h
		db	0CBh, 46h,0CBh,0C6h,0C5h, 56h
		db	0A4h, 8Dh,0D0h,0D1h,0D6h, 46h
		db	0C5h,0CBh, 05h, 07h,0CBh,0C7h
		db	0A4h, 8Dh,0D0h,0D1h,0D2h,0C5h
		db	0CBh, 46h,0CBh, 66h,0C8h, 46h
		db	0A4h, 8Dh,0D0h,0D1h,0D6h,0C7h
		db	 4Ah,0C6h, 46h,0CBh,0C9h, 46h
		db	0C5h,0C7h,0A4h, 8Dh,0D0h,0D1h
		db	0D2h,0C5h,0CBh, 46h,0C9h, 06h
		db	 07h,0A4h, 8Dh,0D0h,0D7h,0D6h
		db	0C4h, 05h, 07h,0C5h, 66h,0A4h
		db	 8Dh,0D0h,0D1h,0D2h,0C3h,0C5h
		db	0CBh, 46h,0CBh, 05h, 07h,0A4h
		db	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 11h, 00h, 15h,0C1h, 0Ch, 9Dh
		db	 00h, 10h, 00h,0FFh,0FFh,0FFh
		db	 34h, 00h, 15h, 82h, 0Eh, 0Eh
		db	 00h, 05h, 80h, 24h, 00h, 04h
		db	0FFh,0FFh, 24h, 00h, 08h, 57h
		db	0C2h,0FFh,0FFh,0FFh,0FFh, 24h
		db	 00h, 04h,0F7h,0C1h, 05h, 00h
		db	0FFh,0FFh, 20h, 00h,0FFh, 10h
		db	0C0h, 57h,0C2h, 0Ah,0C0h,0E4h
		db	0C1h, 40h,0C2h, 08h, 08h, 3Dh
		db	0C2h, 11h, 00h,0FFh,0FFh,0FFh
		db	0FFh, 16h,0AFh, 00h, 12h

; ------------------------------------------------------------------
; cavern_name -- pascal-encoded cavern/area name 'Cavern of Cementar'.
; Preceded by small descriptor bytes; the length byte just before
; the quoted string matches the string length (0x11/0x0E/etc).
; ------------------------------------------------------------------
		db	'Cavern of Cementar'
		db	 99h, 00h, 04h, 09h,0FFh, 09h
		db	 08h, 08h, 10h,0C0h, 57h,0C2h
		db	 0Ah,0C0h,0F0h,0C1h, 59h,0C2h
		db	 0Dh,0FFh, 20h, 00h,0FFh,0FFh
		db	0FFh,0FFh, 21h, 00h, 17h,0FFh
		db	 79h, 00h, 00h, 20h, 00h, 00h
		db	 00h, 24h, 00h, 08h, 00h, 00h

; ------------------------------------------------------------------
; exit_records -- trailing event/exit/door records and script bytes
; triggered on cavern load.  Ends with 0xFFFFFFFF (header_1 label).
; ------------------------------------------------------------------
header_1	dd	0FFFFFFFFh
strategy	endp


seg_a		ends


		end
