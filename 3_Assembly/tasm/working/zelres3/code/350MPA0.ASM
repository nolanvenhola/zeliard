
PAGE  59,132

;==========================================================================
;
;  350MPA0.BIN - Level 10 (A) Floor 0 (final area)
;
;  Zeliard dungeon map data file (MPA0). Loaded by stick.bin as an
;  MDT (map data table). This is labyrinth/cavern map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x03f3 = 1011)
;    +0x02  reserved          - zero pad
;    +0x04..+0x0F  ptr table - runtime addresses (subtract map base seg for file offset)
;    +0x10  map_data          - tile grid + NPC/door cells
;    ...    dialog_strings    - 0xFF-terminated NPC dialog text
;    ...    script_trailer    - event trigger bytes (FFFF terminated)
;
;  Runtime load base varies per map; pointer high-byte indicates the segment.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

map_mpa0	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	03F3h		; total_size field
		dw	0000h		; reserved / zero
		dw	0C3D9h		; hdr ptr[0] (runtime addr)
		dw	0049h		; hdr ptr[1] (runtime addr)
		dw	0C3A0h		; hdr ptr[2] (runtime addr)
		dw	0C3A2h		; hdr ptr[3] (runtime addr)
		dw	0C3A4h		; hdr ptr[4] (runtime addr)
		dw	0C3B2h		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	0B4h, 0C3h, 0C7h, 0C3h, 0F1h, 0C3h, 0Ah, 0FFh, 0FFh, 0FFh, 0Ch, 00h
		db	00h, 0A0h, 0C3h, 82h, 01h, 11h, 0D2h, 0D1h, 0D2h, 0D1h, 0D3h, 0C3h
		db	53h, 0C3h, 0C4h, 42h, 0C4h, 0C3h, 40h, 0ABh, 82h, 02h, 11h, 0D2h
		db	0D1h, 0D2h, 0D3h, 0C4h, 08h, 03h, 41h, 0ABh, 82h, 0D1h, 0D2h, 02h
		db	11h, 0D2h, 0D3h, 0C3h, 0C4h, 0C3h, 0C4h, 52h, 0C4h, 0C3h, 0C4h, 40h
		db	0ABh, 82h, 03h, 11h, 0D2h, 0D1h, 0D3h, 42h, 0C4h, 0C3h, 0C4h, 0C3h
		db	0C4h, 0C3h, 0C4h, 0C3h, 41h, 0ABh, 82h, 01h, 11h, 0D2h, 02h, 11h
		db	0D3h, 06h, 03h, 0C4h, 0C3h, 0C4h, 40h, 0ABh, 82h, 0D1h, 0D2h, 0D1h
		db	02h, 12h, 0D3h, 05h, 03h, 0C4h, 52h, 41h, 0ABh, 82h, 05h, 11h
		db	0D3h, 72h, 0C4h, 62h, 0C2h, 0C1h, 0ABh, 82h, 01h, 11h, 01h, 12h
		db	0D1h, 0D2h, 0D3h, 52h, 0C4h, 62h, 0C4h, 0C3h, 0C2h, 0C1h, 0ABh, 82h
		db	03h, 11h, 0D2h, 0D1h, 0D3h, 0C3h, 0C4h, 07h, 03h, 41h, 0ABh, 82h
		db	0D1h, 02h, 12h, 0D1h, 0D2h, 0D3h, 52h, 43h, 62h, 0C4h, 40h, 0ABh
		db	82h, 03h, 11h, 0D2h, 01h, 11h, 42h, 0C4h, 42h, 0C4h, 42h, 0C4h
		db	0C3h, 41h, 0ABh, 82h, 01h, 11h, 03h, 12h, 0D3h, 05h, 03h, 0C4h
		db	42h, 0C4h, 40h, 0ABh, 82h, 06h, 11h, 62h, 0C4h, 72h, 41h, 0ABh
		db	82h, 01h, 11h, 0C5h, 0C7h, 0C9h, 0CBh, 0C9h, 0CBh, 0C9h, 62h, 0C4h
		db	42h, 0C4h, 40h, 0ABh, 82h, 01h, 11h, 0C6h, 0C8h, 0CAh, 0CCh, 0CAh
		db	0CCh, 0CAh, 72h, 0C4h, 42h, 41h, 0ABh, 82h, 0D1h, 0D2h, 03h, 11h
		db	01h, 13h, 81h, 07h, 03h, 40h, 0ABh, 82h, 01h, 11h, 01h, 12h
		db	0D1h, 02h, 13h, 88h, 0C4h, 41h, 0ABh, 82h, 0D1h, 0D2h, 01h, 11h
		db	01h, 13h, 8Ah, 0C4h, 0C1h, 0C2h, 0ABh, 82h, 0D1h, 02h, 12h, 0D1h
		db	0D3h, 8Ah, 0C3h, 41h, 0ABh, 82h, 03h, 11h, 8Ch, 0C4h, 0C2h, 0C1h
		db	0ABh, 82h, 02h, 11h, 02h, 13h, 8Ah, 0C4h, 0C1h, 0C2h, 0ABh, 82h
		db	0D1h, 01h, 12h, 0D3h, 81h, 0D3h, 8Ah, 0C3h, 0C2h, 0C1h, 0ABh, 82h
		db	03h, 11h, 0D3h, 8Bh, 0C4h, 41h, 0ABh, 82h, 0C5h, 0C7h, 0C9h, 0CBh
		db	0C9h, 0CDh, 8Ah, 0C4h, 40h, 0ABh, 82h, 0C6h, 0C8h, 0CAh, 0CCh, 0CAh
		db	0CEh, 8Ah, 0C3h, 0C1h, 0C2h, 0ABh, 82h, 0D1h, 0D2h, 0D1h, 0D3h, 8Ch
		db	0C4h, 0C2h, 0C1h, 0ABh, 82h, 01h, 11h, 0D2h, 0D1h, 01h, 13h, 8Ah
		db	0C4h, 0C1h, 0C2h, 0ABh, 82h, 02h, 11h, 81h, 0D3h, 8Bh, 0C3h, 0C2h
		db	0C1h, 0ABh, 82h, 0D1h, 0D2h, 0D1h, 0D3h, 8Ch, 0C3h, 0C1h, 0C2h, 0ABh
		db	82h, 01h, 11h, 01h, 12h, 8Ch, 0C4h, 0C2h, 0C1h, 0ABh, 82h, 0D1h
		db	0D2h, 0D1h, 01h, 13h, 8Bh, 0C4h, 0C1h, 0C2h, 0ABh, 82h, 01h, 11h
		db	0D2h, 0D3h, 8Ch, 0C3h, 0C2h, 0C1h, 0ABh, 82h, 02h, 11h, 81h, 0D3h
		db	8Bh, 0C4h, 0C2h, 0C1h, 0ABh, 82h, 01h, 11h, 01h, 13h, 8Ch, 0C3h
		db	0C1h, 0C2h, 8Fh, 06h, 14h, 95h, 82h, 01h, 11h, 0D2h, 0D1h, 0D3h
		db	8Bh, 0C3h, 40h, 8Fh, 0D4h, 85h, 0D4h, 95h, 82h, 0D1h, 0D2h, 0D1h
		db	81h, 0D3h, 8Bh, 0C4h, 0C2h, 0C1h, 8Fh, 0D4h, 85h, 0D4h, 95h, 82h
		db	01h, 11h, 0D2h, 0D3h, 8Ch, 0C3h, 40h, 8Fh, 0D4h, 85h, 0D4h, 95h
		db	82h, 03h, 11h, 0D3h, 8Bh, 0C4h, 40h, 8Fh, 0D4h, 85h, 0D4h, 95h
		db	82h, 02h, 11h, 0D3h, 81h, 0D3h, 8Ah, 0C3h, 41h, 8Fh, 0D4h, 85h
		db	0D4h, 95h, 82h, 0D1h, 01h, 12h, 0D1h, 0D3h, 8Bh, 0C4h, 40h, 8Fh
		db	0D4h, 85h, 0D4h, 95h, 82h, 02h, 11h, 0D2h, 01h, 13h, 8Ah, 0C3h
		db	0C1h, 0C2h, 8Fh, 0D4h, 85h, 0D4h, 95h, 82h, 02h, 11h, 0D3h, 8Ch
		db	0C4h, 0C2h, 0C1h, 8Fh, 0D4h, 85h, 0D4h, 95h, 82h, 01h, 11h, 0D2h
		db	0D3h, 8Ch, 0C3h, 40h, 8Fh, 06h, 14h, 95h, 82h, 0D1h, 0D2h, 0D1h
		db	01h, 13h, 8Bh, 0C4h, 0C1h, 0C2h, 0ABh, 82h, 01h, 11h, 01h, 12h
		db	0D3h, 8Bh, 0C4h, 0C2h, 0C1h, 0ABh, 82h, 02h, 11h, 0D3h, 8Ch, 0C3h
		db	40h, 0ABh, 82h, 01h, 11h, 0D2h, 01h, 13h, 8Bh, 0C4h, 41h, 0ABh
		db	82h, 0D1h, 02h, 12h, 0D3h, 8Bh, 0C3h, 0C2h, 0C1h, 0ABh, 82h, 02h
		db	11h, 0D3h, 8Ch, 0C4h, 40h, 0ABh, 82h, 0C5h, 0C7h, 0C9h, 0CBh, 0C9h
		db	0CDh, 8Ah, 0C4h, 41h, 0ABh, 82h, 0C6h, 0C8h, 0CAh, 0CCh, 0CAh, 0CEh
		db	8Ah, 0C3h, 40h, 0ABh, 82h, 02h, 11h, 01h, 13h, 8Bh, 0C4h, 0C1h
		db	0C2h, 0ABh, 82h, 0D1h, 01h, 12h, 0D1h, 81h, 0D3h, 8Ah, 0C4h, 0C2h
		db	0C1h, 0ABh, 82h, 01h, 11h, 0D2h, 02h, 13h, 8Ah, 0C3h, 41h, 0ABh
		db	82h, 01h, 11h, 0D2h, 0D1h, 0D3h, 8Bh, 0C4h, 40h, 0ABh, 82h, 0D1h
		db	0D2h, 02h, 11h, 0D3h, 8Ah, 0C3h, 0C1h, 0C2h, 0ABh, 82h, 01h, 11h
		db	01h, 12h, 02h, 13h, 89h, 0C4h, 0C2h, 0C1h, 0ABh, 82h, 05h, 11h
		db	81h, 0D3h, 88h, 0C4h, 40h, 0ABh, 82h, 02h, 11h, 0D2h, 0D1h, 02h
		db	13h, 88h, 0C3h, 41h, 0ABh, 82h, 0D1h, 01h, 12h, 02h, 11h, 01h
		db	13h, 81h, 07h, 03h, 40h, 0ABh, 82h, 01h, 11h, 0C5h, 0C7h, 0C9h
		db	0CBh, 0C9h, 0CBh, 0C9h, 0C3h, 0C4h, 42h, 0C4h, 52h, 41h, 0ABh, 82h
		db	01h, 11h, 0C6h, 0C8h, 0CAh, 0CCh, 0CAh, 0CCh, 0CAh, 52h, 0C4h, 62h
		db	40h, 0ABh, 82h, 02h, 11h, 0D2h, 0D1h, 0D2h, 0D1h, 06h, 03h, 0C4h
		db	0C3h, 0C4h, 0C1h, 0C2h, 0ABh, 82h, 0D1h, 01h, 12h, 02h, 11h, 0D2h
		db	52h, 0C4h, 62h, 0C4h, 0C3h, 0C2h, 0C1h, 0ABh, 82h, 03h, 11h, 01h
		db	12h, 0D1h, 42h, 0C4h, 0C3h, 0C4h, 42h, 0C4h, 42h, 0C1h, 0C2h, 0ABh
		db	82h, 02h, 11h, 0D2h, 01h, 11h, 0D2h, 0C4h, 0C3h, 0C4h, 0C3h, 0C4h
		db	72h, 0C2h, 0C1h, 0ABh, 82h, 01h, 11h, 0D2h, 02h, 11h, 0D3h, 08h
		db	03h, 0C4h, 0C1h, 0C2h, 0ABh, 82h, 0D1h, 0D2h, 0D1h, 0D2h, 0D1h, 01h
		db	12h, 07h, 03h, 0C4h, 0C3h, 0C2h, 0C1h, 0ABh, 82h, 01h, 11h, 0D2h
		db	0D1h, 0D2h, 0D1h, 0D3h, 0C4h, 08h, 03h, 0C1h, 0C2h, 0ABh, 82h, 0D1h
		db	0D2h, 0D1h, 0D2h, 01h, 11h, 0D3h, 0C3h, 53h, 0C3h, 0C4h, 62h, 0C2h
		db	0C1h, 0ABh, 82h, 01h, 11h, 0D2h, 0D1h, 0D2h, 0D1h, 0D3h, 06h, 03h
		db	0C4h, 42h, 41h, 0ABh, 82h, 03h, 11h, 0D2h, 0D1h, 0D3h, 0C4h, 08h
		db	03h, 40h, 0ABh, 82h, 02h, 11h, 0D2h, 0D1h, 0D2h, 0D3h, 0C4h, 07h
		db	03h, 0C4h, 41h, 0ABh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 25h, 00h
		db	0Eh, 0C0h, 1Eh, 24h, 00h, 26h, 80h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		db	47h, 00h, 0FFh, 0D9h, 0C3h, 1Bh, 00h, 0DCh, 0C3h, 0Eh, 0Eh, 49h
		db	00h, 0FFh, 00h, 0FFh, 0FFh, 0FFh, 0FFh, 18h, 0AFh, 04h, 0Eh

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'Jashiin\s room'

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	0BBh, 00h, 09h, 11h, 11h, 0FFh, 0Eh, 0Eh, 10h, 0C0h, 0EFh, 0C3h
		db	0Ah, 0C0h, 0A6h, 0C3h, 47h, 00h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		db	0FFh, 0FFh

map_mpa0	endp

seg_a		ends

		end	start
