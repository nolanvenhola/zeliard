
PAGE  59,132

;==========================================================================
;
;  339MP71.BIN - Level 7 Floor 1
;
;  Zeliard dungeon map data file (MP71). Loaded by stick.bin as an
;  MDT (map data table). This is labyrinth/cavern map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x19ff = 6655)
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

map_mp71	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	19FFh		; total_size field
		dw	0000h		; reserved / zero
		dw	0D7C8h		; hdr ptr[0] (runtime addr)
		dw	00C4h		; hdr ptr[1] (runtime addr)
		dw	0D6CEh		; hdr ptr[2] (runtime addr)
		dw	0D6D3h		; hdr ptr[3] (runtime addr)
		dw	0D6E1h		; hdr ptr[4] (runtime addr)
		dw	0D737h		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	8Dh, 0D7h, 0B2h, 0D7h, 0CDh, 0D7h, 07h, 0FFh, 0FFh, 0FFh, 0Ah, 00h
		db	00h, 0CEh, 0D6h, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0CDh, 0D0h, 0D1h, 0D4h, 8Fh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h
		db	86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh
		db	5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h
		db	0D1h, 0D4h, 8Fh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 5Dh, 0D0h, 0D1h
		db	0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0D4h, 8Fh
		db	0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h
		db	85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h
		db	0C5h, 0D6h, 0CBh, 4Eh, 0D0h, 0D1h, 0D4h, 8Fh, 0C5h, 0D6h, 0CBh, 0D1h
		db	0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C6h, 0D3h, 49h, 0CBh
		db	0D0h, 0D1h, 0D4h, 8Fh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h
		db	0D6h, 0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 5Dh, 0D0h
		db	0D1h, 0CAh, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0D4h, 8Fh, 0C5h
		db	0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 89h, 0C6h
		db	01h, 13h, 0D2h, 0CAh, 0D4h, 8Fh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h
		db	86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh
		db	5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C6h, 0D6h, 0CAh, 0D4h, 8Fh, 0C5h
		db	0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 8Ch, 0C5h
		db	0CAh, 0DAh, 8Fh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 5Dh, 0D0h, 0D1h
		db	0CAh, 0D4h, 8Ch, 0C6h, 0D3h, 0DBh, 8Fh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 9Eh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 9Eh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 9Eh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 9Eh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0DAh, 85h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0C3h, 0C1h, 0C2h, 50h, 41h, 0C1h, 91h
		db	0C4h, 0D4h, 83h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 5Dh, 0D0h, 0D1h
		db	0CAh, 0D4h, 98h, 0C4h, 0D6h, 0DAh, 83h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0DBh, 85h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0DAh, 86h, 0C4h, 46h, 0D4h, 8Dh, 43h
		db	0CAh, 0D4h, 83h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0D4h, 85h, 0E3h, 0D3h, 0CAh, 0CBh, 0CCh, 6Eh, 0D1h, 0D3h
		db	0D9h, 86h, 0C5h, 0D6h, 0D5h, 0D4h, 8Dh, 0C6h, 0C5h, 0D6h, 0D4h, 83h
		db	0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h
		db	86h, 0E3h, 0D3h, 0CBh, 0CFh, 03h, 12h, 0CAh, 0D4h, 87h, 0C5h, 0D6h
		db	0D5h, 0D4h, 8Eh, 0C6h, 0D3h, 0D9h, 83h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 87h, 0E3h, 0D3h, 0D2h, 04h
		db	13h, 0D9h, 87h, 0C5h, 01h, 16h, 0D4h, 94h, 0C5h, 0D6h, 0CBh, 0D1h
		db	0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 88h, 0E3h, 0D3h, 76h
		db	0D8h, 87h, 0C5h, 0D6h, 0CAh, 0Ah, 07h, 0D8h, 89h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C4h, 0D6h
		db	0CAh, 0C9h, 49h, 0D4h, 87h, 0C5h, 0D6h, 0CAh, 09h, 09h, 0CAh, 0C7h
		db	0D8h, 88h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h
		db	0D6h, 0CBh, 0CCh, 08h, 0Dh, 0D1h, 0CAh, 0DAh, 88h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h
		db	0CBh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 07h, 0Eh
		db	0D0h, 0D1h, 0CAh, 0D4h, 88h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h
		db	0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0CAh
		db	0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 6Dh, 0D0h, 5Dh, 0D0h, 0D1h, 0CAh
		db	0D4h, 88h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h
		db	0D6h, 0CBh, 0CCh, 07h, 0Eh, 0D0h, 0D1h, 0CAh, 56h, 0D8h, 85h, 0C5h
		db	0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h
		db	0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh
		db	08h, 0Eh, 4Ch, 0D1h, 49h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h
		db	0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 0Ah, 0Eh, 0D0h, 0D1h
		db	0CAh, 0DAh, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0CAh, 0D4h, 87h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0Ah, 0Eh, 0D0h, 0D1h, 0CAh, 0D8h, 85h, 0C5h
		db	0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h
		db	0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh
		db	07h, 0Eh, 0CFh, 4Dh, 0D0h, 0D1h, 0D3h, 0D9h, 85h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h
		db	0CBh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0CCh
		db	06h, 0Eh, 0D0h, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h
		db	0D1h, 0CAh, 0D4h, 06h, 28h, 0C5h, 0D6h, 0CBh, 0CCh, 08h, 0Eh, 0D0h
		db	0D1h, 0CAh, 0D3h, 0DAh, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h
		db	0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0CAh
		db	0D4h, 06h, 28h, 0C5h, 0D6h, 0CBh, 0CCh, 09h, 0Fh, 0D1h, 0CAh, 0DAh
		db	87h, 0C5h, 0D6h, 0CBh, 0D1h, 0D3h, 0D9h, 86h, 0C5h, 0D6h, 0CBh, 0D1h
		db	0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0CAh, 0D4h, 06h, 28h, 0C5h
		db	0D6h, 0C8h, 0Ah, 12h, 0CAh, 0D3h, 0D8h, 87h, 0C5h, 0D6h, 49h, 0DAh
		db	87h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h
		db	0D3h, 0D4h, 06h, 28h, 0C5h, 0Dh, 13h, 0D9h, 88h, 0C6h, 02h, 13h
		db	0DBh, 87h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h
		db	0D1h, 0D4h, 9Fh, 0C4h, 46h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h
		db	89h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0D4h, 9Fh, 0C5h, 0D6h, 0CAh, 46h
		db	0D4h, 87h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D0h
		db	0D1h, 0D4h, 9Fh, 0C5h, 0D6h, 0C9h, 0C8h, 0CAh, 0C7h, 0D4h, 86h, 0C5h
		db	0D6h, 0CBh, 0D1h, 0D4h, 89h, 0C5h, 0D6h, 01h, 12h, 0CAh, 0D4h, 85h
		db	0C4h, 05h, 07h, 0D4h, 90h, 0C4h, 46h, 0CBh, 0CCh, 0CDh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0DAh, 89h, 0C5h, 03h, 13h, 0D9h
		db	84h, 0C4h, 0D6h, 0CAh, 68h, 0CAh, 0C7h, 0D4h, 8Fh, 0C5h, 0D6h, 0CBh
		db	0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CAh, 0D3h, 0DBh
		db	89h, 0C6h, 01h, 28h, 01h, 2Ah, 85h, 0C5h, 0D6h, 0CBh, 6Ch, 0D0h
		db	0D1h, 0D5h, 0D4h, 0Dh, 28h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h
		db	0CAh, 0D4h, 86h, 0C6h, 01h, 13h, 0DAh, 0D7h, 89h, 0E8h, 01h, 28h
		db	01h, 2Ah, 85h, 0C5h, 0D5h, 0CBh, 7Dh, 0D0h, 0D1h, 0D4h, 0Dh, 28h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C4h, 0D6h
		db	46h, 0D8h, 88h, 0E8h, 01h, 28h, 01h, 2Ah, 85h, 0C6h, 0C5h, 0CBh
		db	7Dh, 0D0h, 0D1h, 0D4h, 8Eh, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h
		db	0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CAh, 0C9h, 46h, 0D8h, 86h, 0E8h, 01h
		db	28h, 01h, 2Ah, 86h, 0C5h, 0CBh, 0CFh, 6Dh, 0D0h, 0D1h, 0C7h, 0C3h
		db	0C1h, 41h, 60h, 0C2h, 0C1h, 0C2h, 40h, 81h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CDh, 0D1h, 0CAh
		db	0D4h, 86h, 0E8h, 01h, 28h, 01h, 2Ah, 86h, 0C6h, 0C5h, 0CBh, 0CFh
		db	4Dh, 0D0h, 0D1h, 0D3h, 0DBh, 8Eh, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h
		db	0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0D4h, 86h
		db	0E8h, 01h, 28h, 01h, 2Ah, 87h, 0C5h, 0D6h, 0CBh, 4Dh, 0D1h, 0D5h
		db	0C3h, 0C2h, 0C1h, 41h, 50h, 0C2h, 0C1h, 86h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 4Eh, 0D1h, 0D4h
		db	86h, 0E8h, 01h, 28h, 01h, 2Ah, 87h, 0C6h, 0D6h, 0CBh, 4Eh, 0D1h
		db	0DAh, 90h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 87h
		db	0C5h, 0D6h, 0CAh, 01h, 12h, 0D3h, 0D9h, 86h, 0E8h, 01h, 28h, 01h
		db	2Ah, 88h, 0C6h, 0D3h, 01h, 12h, 0C8h, 0DBh, 88h, 0C4h, 0C7h, 0D4h
		db	85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C6h
		db	03h, 13h, 0D9h, 87h, 0E8h, 01h, 28h, 01h, 2Ah, 8Ah, 0C6h, 01h
		db	13h, 0D9h, 87h, 0C4h, 0D6h, 0CAh, 0C7h, 0D4h, 84h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 87h
		db	0E8h, 01h, 28h, 01h, 2Ah, 95h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 84h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 88h, 02h, 28h
		db	01h, 2Ah, 87h, 0E8h, 01h, 28h, 01h, 2Ah, 95h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0D4h, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h
		db	88h, 02h, 28h, 01h, 2Ah, 87h, 0E8h, 01h, 28h, 01h, 2Ah, 95h
		db	0C5h, 0D6h, 0CBh, 0D1h, 0DAh, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h
		db	0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 87h, 0E8h, 01h, 28h
		db	01h, 2Ah, 95h, 0C6h, 02h, 13h, 0D9h, 84h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 87h, 0E8h
		db	01h, 28h, 01h, 2Ah, 9Eh, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h
		db	0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 87h, 0E8h, 01h, 28h, 01h
		db	2Ah, 02h, 28h, 01h, 2Ah, 99h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h
		db	0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 87h, 0E8h, 01h, 28h
		db	01h, 2Ah, 02h, 28h, 01h, 2Ah, 99h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh
		db	0D0h, 0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 87h, 0E8h, 01h
		db	28h, 82h, 02h, 28h, 01h, 2Ah, 99h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh
		db	0D0h, 0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 87h, 0E8h, 01h
		db	28h, 82h, 02h, 28h, 01h, 2Ah, 99h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh
		db	0D0h, 0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 87h, 0E8h, 84h
		db	02h, 28h, 01h, 2Ah, 99h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h
		db	0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 88h, 84h, 02h, 28h, 01h
		db	2Ah, 85h, 0C4h, 0D4h, 92h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h
		db	0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 88h, 84h, 02h, 28h, 01h
		db	2Ah, 85h, 0C5h, 66h, 0D8h, 8Eh, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h
		db	0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 88h, 84h, 02h, 28h
		db	01h, 2Ah, 85h, 0C6h, 02h, 13h, 0CAh, 0DAh, 8Eh, 0C5h, 0D6h, 0CBh
		db	0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 88h
		db	84h, 02h, 28h, 01h, 2Ah, 88h, 0C6h, 0D3h, 0DBh, 8Eh, 0C5h, 0D6h
		db	0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah
		db	88h, 84h, 02h, 28h, 01h, 2Ah, 99h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh
		db	0D0h, 0D1h, 0CAh, 0D4h, 88h, 02h, 28h, 01h, 2Ah, 88h, 84h, 02h
		db	28h, 01h, 2Ah, 99h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh
		db	0D4h, 88h, 02h, 28h, 01h, 2Ah, 88h, 84h, 02h, 28h, 01h, 2Ah
		db	99h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 88h, 02h
		db	28h, 01h, 2Ah, 82h, 03h, 28h, 01h, 2Ah, 84h, 02h, 28h, 01h
		db	2Ah, 99h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0DBh, 88h
		db	02h, 28h, 01h, 2Ah, 82h, 03h, 28h, 01h, 2Ah, 84h, 02h, 28h
		db	01h, 2Ah, 99h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0CFh, 0D1h, 0D3h, 0D9h
		db	88h, 02h, 28h, 01h, 2Ah, 82h, 03h, 28h, 01h, 2Ah, 84h, 02h
		db	28h, 01h, 2Ah, 85h, 0C4h, 0D4h, 92h, 0C5h, 0D6h, 0CBh, 0CFh, 0D0h
		db	0D1h, 0D3h, 0D9h, 89h, 02h, 28h, 84h, 03h, 28h, 01h, 2Ah, 84h
		db	02h, 28h, 01h, 2Ah, 99h, 0C5h, 0D6h, 69h, 0DAh, 88h, 0C4h, 0D8h
		db	02h, 28h, 84h, 03h, 28h, 01h, 2Ah, 84h, 02h, 28h, 01h, 2Ah
		db	99h, 0C6h, 04h, 13h, 0D9h, 88h, 0C5h, 0D4h, 02h, 28h, 84h, 03h
		db	28h, 01h, 2Ah, 84h, 02h, 28h, 01h, 2Ah, 90h, 0C4h, 0Dh, 07h
		db	0DAh, 88h, 0C5h, 0D6h, 0D4h, 0C4h, 46h, 0D8h, 82h, 03h, 28h, 01h
		db	2Ah, 84h, 02h, 28h, 01h, 2Ah, 90h, 0C5h, 0D6h, 79h, 05h, 09h
		db	49h, 0DBh, 88h, 0C5h, 01h, 16h, 59h, 0D4h, 82h, 03h, 28h, 01h
		db	2Ah, 84h, 02h, 28h, 01h, 2Ah, 90h, 0C5h, 0D6h, 0CAh, 58h, 0CBh
		db	0CCh, 6Ch, 0D0h, 0D1h, 0CAh, 46h, 0D8h, 86h, 0C5h, 01h, 16h, 58h
		db	0C7h, 0D4h, 81h, 03h, 28h, 01h, 2Ah, 84h, 02h, 28h, 01h, 2Ah
		db	90h, 0C5h, 0D6h, 0CBh, 6Ch, 6Dh, 0CFh, 0CEh, 0CDh, 0D0h, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 4Ch, 0D0h, 0D1h, 0C7h, 0D8h, 03h, 28h
		db	01h, 2Ah, 84h, 02h, 28h, 01h, 2Ah, 90h, 0C5h, 0D6h, 0CBh, 0CCh
		db	09h, 0Eh, 0D0h, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh
		db	0D0h, 0D1h, 0CAh, 0DAh, 03h, 28h, 01h, 2Ah, 84h, 02h, 28h, 01h
		db	2Ah, 84h, 0C4h, 76h, 0D8h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0CCh
		db	07h, 0Eh, 0D0h, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0CFh, 0CEh
		db	0D0h, 0D1h, 0CAh, 0D4h, 03h, 28h, 01h, 2Ah, 84h, 02h, 28h, 01h
		db	2Ah, 84h, 0C5h, 0D5h, 0CAh, 48h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh
		db	0CCh, 09h, 0Eh, 0D0h, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 01h, 16h, 0CBh
		db	0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 03h, 28h, 01h, 2Ah, 84h, 02h, 28h
		db	86h, 0C5h, 0D5h, 0CBh, 4Ch, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh
		db	7Dh, 0D0h, 6Dh, 0D0h, 0D1h, 0CAh, 0D4h, 86h, 0C6h, 01h, 16h, 0CBh
		db	0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 03h, 28h, 01h, 2Ah, 84h, 02h, 28h
		db	86h, 0C5h, 0D5h, 0CBh, 0CCh, 0D0h, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh
		db	0CCh, 08h, 0Eh, 0CFh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 03h, 28h, 01h, 2Ah, 84h, 02h, 28h
		db	86h, 0C5h, 0D5h, 0CBh, 0CCh, 0D0h, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0CEh, 05h, 0Fh, 0D0h, 0D1h, 01h, 12h, 0CAh, 0D3h, 0D9h, 87h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 03h, 28h, 01h, 2Ah
		db	8Dh, 0C5h, 0D5h, 0CBh, 0CCh, 0D0h, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0D0h, 0D1h, 05h, 12h, 49h, 01h, 13h, 0D9h, 88h, 0C5h, 0D6h
		db	0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 03h, 28h, 01h, 2Ah, 8Dh, 0C5h
		db	0D5h, 0CBh, 0CCh, 0D0h, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h
		db	0D1h, 0CAh, 06h, 13h, 0D9h, 8Ah, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h
		db	0CAh, 0D4h, 03h, 28h, 01h, 2Ah, 8Dh, 0C5h, 0D5h, 0CBh, 4Eh, 0D1h
		db	0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 04h, 28h
		db	03h, 2Ah, 88h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 03h
		db	28h, 01h, 2Ah, 8Dh, 0C5h, 0D5h, 0CAh, 01h, 12h, 0D3h, 0D9h, 85h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 04h, 28h, 07h, 2Ah
		db	84h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 03h, 28h, 01h
		db	2Ah, 0C4h, 66h, 0D8h, 87h, 0C6h, 03h, 13h, 0D9h, 86h, 0C5h, 0D6h
		db	0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0DAh, 04h, 28h, 07h, 2Ah, 84h, 0C5h
		db	0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 03h, 28h, 01h, 2Ah, 0C5h
		db	0D6h, 59h, 0D4h, 93h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0D3h, 0D9h
		db	04h, 28h, 07h, 2Ah, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh
		db	0D4h, 03h, 28h, 01h, 2Ah, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0C3h, 0C1h
		db	41h, 0C1h, 0C2h, 60h, 0C2h, 50h, 41h, 50h, 81h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0D0h, 0D1h, 0D4h, 05h, 28h, 07h, 2Ah, 84h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 03h, 28h, 01h, 2Ah, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 46h, 0D8h, 91h, 0C5h, 0D6h, 0CBh, 4Eh, 0D1h, 0D4h, 05h
		db	28h, 03h, 2Ah, 88h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h
		db	86h, 0C5h, 0D6h, 0CBh, 0CCh, 0D1h, 49h, 0D4h, 91h, 0C6h, 04h, 13h
		db	0D9h, 05h, 28h, 01h, 2Ah, 0C4h, 46h, 0D8h, 86h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0D0h, 0D1h, 0CAh, 0C7h, 0D8h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h
		db	0D1h, 0CAh, 14h, 07h, 0D8h, 08h, 28h, 01h, 2Ah, 0C5h, 0D6h, 0CAh
		db	0DAh, 86h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0DAh, 85h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 14h, 09h, 0CAh, 0C7h, 0D8h, 07h
		db	28h, 01h, 2Ah, 0C5h, 0D6h, 0CAh, 0DBh, 86h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 14h
		db	0Dh, 0D0h, 0D1h, 0CAh, 0DAh, 88h, 0C4h, 0C7h, 59h, 0D7h, 86h, 0C5h
		db	0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0Dh, 0Eh, 0CDh, 06h, 0Eh, 0D0h, 0D1h, 0CAh, 0D4h, 88h, 0C5h
		db	0D6h, 0CBh, 0D1h, 0CAh, 0D7h, 86h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h
		db	0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 6Eh, 6Dh, 0CFh, 0Dh, 0Eh
		db	0D0h, 0D1h, 0CAh, 0D4h, 88h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 46h, 0D8h
		db	84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h
		db	0D6h, 0CAh, 02h, 12h, 0CBh, 0CCh, 0Dh, 0Fh, 4Dh, 0CFh, 0CEh, 0D0h
		db	0D1h, 0CAh, 0D4h, 87h, 0C4h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh
		db	0D4h, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 85h
		db	0C6h, 04h, 13h, 0CAh, 0Dh, 12h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh
		db	0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 84h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 85h, 0C6h
		db	0Dh, 13h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h
		db	0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 84h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 93h, 0C5h, 0D6h, 0CBh, 0CCh
		db	5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0D0h
		db	0D1h, 0D4h, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h
		db	85h, 93h, 0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h
		db	0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0D0h, 0D1h, 0D4h, 84h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 93h, 0C5h, 0D6h, 0CBh, 0CCh
		db	5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h
		db	0D1h, 0CAh, 0D4h, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh
		db	0D4h, 85h, 93h, 0C5h, 0D6h, 0CBh, 6Eh, 0D0h, 0D1h, 0CAh, 0D4h, 87h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 84h, 0C5h, 0D6h
		db	0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 93h, 0C6h, 0D3h, 0CAh
		db	02h, 12h, 0CBh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h
		db	0D1h, 0CAh, 0D4h, 85h, 0Ah, 07h, 0D8h, 89h, 0C6h, 0D3h, 49h, 0CBh
		db	0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h
		db	0CAh, 0D4h, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h
		db	82h, 0C4h, 46h, 0Ah, 0Ah, 0C7h, 0D8h, 8Ah, 0C5h, 0D6h, 0CBh, 0D0h
		db	0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh
		db	0DAh, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0DAh, 0C4h
		db	0C7h, 59h, 09h, 09h, 49h, 0DAh, 8Ah, 0C5h, 0D6h, 0C8h, 0D2h, 0C9h
		db	0CAh, 0DAh, 87h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h
		db	84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0D3h, 0DBh, 0C5h, 0D6h
		db	0CAh, 48h, 09h, 0Dh, 0D1h, 0CAh, 0D4h, 8Ah, 0C6h, 04h, 13h, 0D9h
		db	87h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0D3h, 0D9h, 84h, 0C5h
		db	0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0DAh, 0D7h, 0C5h, 0D6h, 0CBh, 4Ch
		db	08h, 0Eh, 0D0h, 0D1h, 0CAh, 0D4h, 8Ch, 0C4h, 46h, 0DAh, 88h, 0C5h
		db	0D6h, 0CBh, 5Eh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h
		db	0D1h, 0C7h, 0D4h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 08h, 0Eh, 0D0h, 0D1h
		db	0CAh, 0D4h, 8Ch, 0C5h, 0D6h, 0CAh, 46h, 0D8h, 86h, 0C5h, 0D6h, 0CAh
		db	02h, 12h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h
		db	0CAh, 0D4h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 08h, 0Eh, 0D0h, 0D1h, 0CAh
		db	0D4h, 8Ch, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C6h, 0D5h, 79h
		db	0DAh, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 0C5h
		db	0D6h, 0CBh, 0CCh, 0CEh, 09h, 0Fh, 0D1h, 0CAh, 0D4h, 8Ch, 0C5h, 0D6h
		db	0CBh, 0D1h, 0CAh, 0D4h, 87h, 0C6h, 04h, 13h, 0D9h, 85h, 0C5h, 0D6h
		db	0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 0C5h, 0D6h, 0CBh, 4Eh, 08h
		db	12h, 59h, 0D4h, 8Ch, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 93h, 0C5h
		db	0D6h, 0CBh, 0CEh, 4Eh, 0D1h, 0CAh, 0D4h, 0C5h, 0D6h, 0CAh, 01h, 12h
		db	06h, 0Ah, 04h, 13h, 0DBh, 8Ch, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h
		db	93h, 0C5h, 0D6h, 0CBh, 0CFh, 0D1h, 0D2h, 0C8h, 0D3h, 0D4h, 0C6h, 01h
		db	13h, 49h, 06h, 13h, 0DAh, 0D7h, 0C4h, 07h, 07h, 0D4h, 86h, 0C5h
		db	0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 93h, 0C5h, 0D6h, 0CAh, 0D2h, 0C8h, 49h
		db	0DBh, 0D4h, 83h, 0C6h, 0D3h, 89h, 0C5h, 0D6h, 05h, 09h, 0CAh, 0C7h
		db	0D8h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 93h, 0C5h, 0D6h, 0C8h
		db	03h, 13h, 0D9h, 86h, 89h, 0C5h, 0D6h, 0CBh, 7Ch, 0D1h, 0CAh, 0D4h
		db	85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C4h, 76h, 0D8h, 86h
		db	0C5h, 0D6h, 0CAh, 0DAh, 8Ah, 40h, 41h, 40h, 0C2h, 0C1h, 81h, 0C5h
		db	0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 06h, 07h, 0CAh, 48h, 0CAh, 0C9h, 0CAh, 0D9h, 0C4h, 05h
		db	07h, 0D6h, 0CAh, 0C3h, 0C1h, 0C2h, 0C1h, 41h, 40h, 0C2h, 40h, 89h
		db	0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0CAh, 05h, 13h, 0D6h, 0CBh, 6Ch, 0D1h, 0DAh, 0D6h, 0CBh
		db	0CCh, 6Ch, 0CEh, 0D1h, 0D9h, 8Ah, 46h, 0D8h, 86h, 0C5h, 0D6h, 0CBh
		db	0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C6h, 01h, 13h, 49h, 0D4h
		db	84h, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0D0h, 0D1h, 0CBh, 0CCh, 06h, 0Eh
		db	0D1h, 0C7h, 0D9h, 87h, 0C4h, 0C7h, 49h, 0C7h, 0D9h, 85h, 0C5h, 0D6h
		db	0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CAh, 0D4h
		db	84h, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0D0h, 0D1h, 02h, 13h, 0CBh, 0CCh
		db	6Eh, 0D0h, 0D1h, 0DAh, 87h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0DAh, 85h
		db	0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h
		db	0CAh, 0DAh, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0D0h, 0D1h, 0DAh, 0D7h
		db	0C6h, 04h, 13h, 0D6h, 0CBh, 0D1h, 0DBh, 87h, 0C5h, 0D6h, 0CBh, 0D1h
		db	0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h
		db	87h, 0C6h, 0C5h, 0CAh, 0DBh, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0D0h
		db	0D1h, 0DBh, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 87h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh
		db	0D4h, 88h, 0C5h, 0DAh, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0D0h, 0D1h
		db	0C7h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0C7h, 0DAh, 86h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h
		db	0CAh, 0D4h, 88h, 0C5h, 0DBh, 85h, 0C6h, 0D6h, 0CBh, 0CCh, 4Dh, 0D0h
		db	0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h
		db	0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h
		db	0D1h, 0CAh, 0D4h, 88h, 0C6h, 0D9h, 86h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh
		db	0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h
		db	0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 7Eh, 0D1h
		db	0CAh, 0D4h, 90h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h
		db	85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h
		db	0CAh, 0D4h, 85h, 0C5h, 0D6h, 05h, 12h, 01h, 13h, 0C3h, 40h, 41h
		db	50h, 0C2h, 0C1h, 0C2h, 40h, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h
		db	0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h
		db	0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 85h, 0C6h, 06h, 13h, 0D9h, 92h, 0C5h
		db	0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 97h, 0C4h
		db	56h, 0D8h, 84h, 0C6h, 01h, 16h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h
		db	85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h
		db	0CAh, 0D4h, 97h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h
		db	86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 97h, 0C5h, 0D6h, 0CBh, 0D1h
		db	0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h
		db	0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h
		db	97h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 85h, 0C6h, 0D6h, 0CBh, 4Eh, 0D1h
		db	0CAh, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0CAh, 0D4h, 97h, 0C5h, 0D6h, 0CBh, 0D1h, 0C7h, 0D4h, 85h
		db	0C5h, 0CAh, 01h, 12h, 49h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 97h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0C7h, 0D4h, 84h, 0C6h, 79h, 0DAh, 85h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0DAh, 86h, 0C4h
		db	06h, 07h, 0D8h, 86h, 0C4h, 0C7h, 0CAh, 0CBh, 0CDh, 0D1h, 0CAh, 0D3h
		db	0DAh, 84h, 0C6h, 04h, 13h, 0D9h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CAh
		db	68h, 0CAh, 0C7h, 0D8h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh
		db	0DAh, 91h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0CCh, 5Ch, 0D1h, 0CAh, 0DAh
		db	85h, 0C5h, 0D6h, 0CBh, 4Eh, 0D1h, 0D3h, 0D4h, 91h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h
		db	0D6h, 0CBh, 0CCh, 4Dh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h, 69h
		db	0D4h, 92h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0D0h, 0D1h, 0CAh
		db	0D4h, 85h, 0C6h, 04h, 13h, 0D4h, 86h, 0C4h, 05h, 07h, 0D8h, 84h
		db	0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 86h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 01h, 13h, 0D4h
		db	92h, 0C5h, 0D6h, 0CAh, 58h, 0CAh, 0DAh, 84h, 0C5h, 0D6h, 0CBh, 0D1h
		db	0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h
		db	0CBh, 0CFh, 0D0h, 0D1h, 0CAh, 0DAh, 94h, 0C5h, 0D6h, 0CBh, 5Ch, 0D1h
		db	0DBh, 84h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 86h, 0C6h, 0D5h, 0CAh, 01h, 12h, 0CAh, 0D3h, 0DBh
		db	94h, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0D1h, 0D4h, 84h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 87h, 0C6h
		db	03h, 13h, 0D9h, 95h, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0D1h, 0D4h, 84h
		db	0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0D4h, 0A2h, 0C5h, 0D6h, 0CBh, 4Eh, 0CEh, 0D1h, 0D4h, 84h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0C3h, 0C1h
		db	0C2h, 0C1h, 0C2h, 0C1h, 0C2h, 40h, 9Ah, 0C6h, 0D3h, 0CAh, 0D2h, 0CBh
		db	0CCh, 0D1h, 0D4h, 84h, 0C5h, 0D6h, 0CBh, 0D1h, 0D3h, 0DAh, 86h, 0C5h
		db	0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 97h, 0C4h, 56h, 0D4h, 86h, 0ECh, 0EBh
		db	0C5h, 0D6h, 0CBh, 0CCh, 0D1h, 0C7h, 0D4h, 83h, 0C6h, 0D6h, 0CBh, 0D1h
		db	0D8h, 87h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0C3h, 40h, 0C2h, 50h, 0C2h
		db	40h, 8Eh, 0C5h, 0D6h, 0CBh, 0D1h, 0C7h, 0DAh, 85h, 0ECh, 0EBh, 0C5h
		db	0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 46h, 0D8h, 82h, 0C6h, 01h, 13h, 0D9h
		db	87h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0DAh, 97h, 0C5h, 0D6h, 0CBh, 0D1h
		db	0CAh, 0D4h, 85h, 0ECh, 0EBh, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 49h
		db	0D4h, 8Dh, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 46h, 0C3h, 0C2h, 50h, 41h
		db	50h, 8Ch, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 85h, 0ECh, 0EBh, 0C5h
		db	0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 8Dh, 0C5h, 0D6h, 0CBh
		db	0D1h, 0C9h, 49h, 0DAh, 95h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 85h
		db	0ECh, 0EBh, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 8Dh
		db	0C5h, 0D6h, 0CBh, 4Ch, 0D1h, 0CAh, 56h, 0C3h, 40h, 0C2h, 40h, 0C2h
		db	60h, 88h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 85h, 0ECh, 0EBh, 0C5h
		db	0D6h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 8Dh, 0C5h, 0D6h, 0CBh
		db	4Dh, 0CDh, 0D1h, 59h, 0D4h, 92h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h
		db	85h, 0ECh, 0EBh, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0C8h, 0D3h, 0D9h
		db	8Dh, 0C5h, 0D6h, 0CBh, 5Dh, 0CDh, 0D1h, 48h, 56h, 0C3h, 40h, 0C2h
		db	0C1h, 0C2h, 70h, 41h, 40h, 81h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h
		db	85h, 0ECh, 0EBh, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0DAh, 8Eh
		db	0C5h, 0D6h, 0CBh, 6Dh, 5Ch, 0D1h, 0C9h, 0CAh, 46h, 0D4h, 8Dh, 0C5h
		db	0D6h, 0CBh, 0D1h, 0D3h, 0D9h, 85h, 0ECh, 0EBh, 0C5h, 0D6h, 0CBh, 0CCh
		db	0D0h, 0D1h, 0CAh, 0D4h, 8Eh, 0C5h, 0D6h, 0CBh, 06h, 0Eh, 5Ch, 0D1h
		db	0CAh, 09h, 07h, 0DAh, 83h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 86h, 0ECh
		db	0EBh, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0D3h, 0D9h, 8Eh, 0C5h, 0D6h
		db	0CBh, 09h, 0Eh, 0D0h, 0D1h, 08h, 09h, 0CAh, 0C7h, 0D4h, 82h, 0C6h
		db	02h, 13h, 0D9h, 86h, 0ECh, 0EBh, 0C5h, 0D6h, 0CAh, 01h, 12h, 0CAh
		db	0D8h, 8Fh, 0C5h, 0D6h, 0CBh, 0Ah, 0Eh, 0Ah, 0Dh, 0D1h, 46h, 0D4h
		db	8Bh, 0ECh, 0EBh, 0C6h, 04h, 13h, 0D9h, 8Fh, 0C5h, 0D6h, 0CBh, 15h
		db	0Fh, 0D1h, 49h, 0DAh, 8Ch, 0C4h, 0C7h, 0D4h, 93h, 0DEh, 0C5h, 0D6h
		db	0C8h, 15h, 12h, 49h, 0D3h, 0DBh, 8Ah, 0C4h, 0C7h, 0C8h, 0CAh, 46h
		db	0D8h, 90h, 0DEh, 0C4h, 0C5h, 0D6h, 0CAh, 17h, 13h, 0D9h, 8Ah, 0C4h
		db	0D6h, 58h, 49h, 0DAh, 8Fh, 0DEh, 0D5h, 0C7h, 48h, 0CAh, 0D4h, 82h
		db	04h, 28h, 11h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh
		db	0D4h, 8Eh, 0DEh, 0D5h, 0CBh, 0CDh, 0D0h, 0D1h, 0CAh, 0D4h, 82h, 04h
		db	28h, 11h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h
		db	8Dh, 0DEh, 0C5h, 0CBh, 0CCh, 0CEh, 0D0h, 0D1h, 0CAh, 0D4h, 82h, 04h
		db	28h, 11h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h
		db	8Ch, 0DEh, 0DFh, 4Ch, 4Dh, 0D0h, 0D1h, 0CAh, 0D4h, 82h, 04h, 28h
		db	11h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh
		db	0DEh, 0E1h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 82h, 04h, 28h
		db	0Ah, 2Ah, 04h, 29h, 01h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h
		db	0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh
		db	46h, 0DAh, 8Ah, 0C4h, 56h, 0D8h, 81h, 04h, 29h, 01h, 2Ah, 89h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh
		db	0CCh, 5Dh, 0D0h, 0D1h, 0C9h, 49h, 0DBh, 8Ah, 0C5h, 0D6h, 0CBh, 0D1h
		db	0C7h, 0D4h, 04h, 29h, 01h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h
		db	0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0D0h
		db	0D1h, 49h, 0D4h, 89h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 04h, 29h
		db	01h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh
		db	0C5h, 0D6h, 0CBh, 0CCh, 6Dh, 0CDh, 0CEh, 0D0h, 0D1h, 0CAh, 0C7h, 0D4h
		db	88h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0DAh, 04h, 29h, 01h, 2Ah, 89h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh
		db	0CCh, 7Dh, 0CEh, 0D0h, 0D1h, 49h, 0C7h, 0D8h, 87h, 0C6h, 03h, 13h
		db	0D9h, 04h, 29h, 01h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h
		db	0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 7Dh, 4Dh, 4Ch, 0D1h, 0CAh
		db	0D4h, 8Dh, 04h, 29h, 01h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h
		db	0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 7Dh, 5Dh, 0D0h, 0D1h
		db	0CAh, 0DAh, 8Dh, 04h, 29h, 01h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0CEh
		db	5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 8Dh, 04h, 29h, 01h, 2Ah, 89h, 0C5h
		db	0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh
		db	7Dh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 8Dh, 04h, 29h, 01h, 2Ah, 89h
		db	0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh
		db	0CCh, 7Dh, 5Dh, 0D0h, 0D1h, 0CAh, 46h, 0D8h, 8Bh, 04h, 29h, 01h
		db	2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h
		db	0D6h, 0CBh, 0CCh, 0CEh, 0CDh, 5Dh, 6Dh, 0D0h, 0D1h, 0C9h, 0CAh, 0C7h
		db	0D8h, 8Ah, 04h, 29h, 01h, 2Ah, 89h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h
		db	0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 7Dh, 7Dh, 4Ch, 0D1h
		db	0CAh, 0DAh, 8Ah, 04h, 29h, 0C4h, 76h, 0D8h, 84h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 7Dh, 05h
		db	0Eh, 0D0h, 0D1h, 0CAh, 0D4h, 8Fh, 0C5h, 0D6h, 0CAh, 48h, 0CAh, 0DAh
		db	84h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h
		db	0CBh, 0CCh, 7Dh, 4Dh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0C7h, 0D4h, 8Eh
		db	0C5h, 0D6h, 0CBh, 4Ch, 0D1h, 0D4h, 84h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h
		db	0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 7Dh, 06h, 0Eh, 0CDh
		db	0D1h, 0CAh, 0DAh, 8Eh, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 56h, 0D8h
		db	81h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h
		db	0CBh, 0CCh, 7Dh, 07h, 0Eh, 0D1h, 0CAh, 56h, 0D4h, 8Bh, 0C5h, 0D6h
		db	0CBh, 0CCh, 0CEh, 0D1h, 48h, 0CAh, 0C7h, 0D8h, 0C5h, 0D6h, 0CBh, 0CCh
		db	0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 7Dh, 07h, 0Eh
		db	0D0h, 0D1h, 02h, 13h, 0DAh, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 4Dh, 0CDh
		db	0D0h, 0D1h, 0CAh, 0DAh, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h
		db	8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 7Dh, 06h, 0Eh, 0CFh, 0D1h, 0CAh, 0D3h
		db	0DAh, 8Dh, 0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 0C5h
		db	0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh
		db	7Dh, 05h, 0Eh, 0D0h, 0D1h, 0CAh, 0D3h, 0D9h, 8Eh, 0C5h, 0D6h, 0CBh
		db	0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h
		db	0CAh, 0D4h, 8Bh, 0C5h, 0D6h, 0CBh, 0CCh, 7Dh, 7Dh, 0CFh, 0D1h, 49h
		db	0DBh, 8Fh, 0C5h, 0D6h, 0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 0C5h
		db	0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 8Ah, 0DEh, 0C5h, 0D6h, 0CBh
		db	0CCh, 7Dh, 6Dh, 0D0h, 0D1h, 0CAh, 01h, 13h, 0D9h, 8Fh, 0C5h, 0D6h
		db	0CBh, 0CCh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h
		db	0D1h, 0CAh, 0D4h, 89h, 0DEh, 0C5h, 01h, 16h, 0CBh, 0CCh, 7Dh, 5Dh
		db	0D0h, 0D1h, 0CAh, 0D3h, 0D9h, 91h, 0C5h, 0D6h, 0CBh, 0CCh, 5Eh, 0D0h
		db	0D1h, 0D3h, 0DAh, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 88h
		db	0DEh, 0C4h, 0DAh, 0D7h, 0C5h, 0CBh, 0CCh, 0CEh, 0CCh, 5Dh, 5Dh, 0D0h
		db	0D1h, 0CAh, 0D4h, 92h, 0C5h, 0D6h, 0CAh, 02h, 12h, 0CBh, 0CFh, 0D1h
		db	0DAh, 0D7h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0DEh
		db	0C4h, 0CAh, 0DAh, 0D7h, 0C5h, 0CBh, 0CCh, 7Dh, 0CCh, 4Dh, 0D0h, 0D1h
		db	0CAh, 0D4h, 8Ch, 02h, 29h, 01h, 2Ah, 81h, 0C6h, 04h, 13h, 0CAh
		db	0D2h, 0C8h, 0C7h, 0D8h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h
		db	86h, 0DEh, 0D5h, 49h, 0D4h, 0C5h, 0D6h, 0CBh, 0CCh, 7Dh, 5Dh, 0D0h
		db	0D1h, 0CAh, 0D4h, 8Ch, 02h, 29h, 01h, 2Ah, 85h, 0C6h, 02h, 13h
		db	49h, 0D4h, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0DEh
		db	0D5h, 0CBh, 0D1h, 0CAh, 0D4h, 0C5h, 0D6h, 0CBh, 0CCh, 7Dh, 5Dh, 0D0h
		db	0D1h, 0CAh, 0D4h, 8Ch, 02h, 29h, 01h, 2Ah, 88h, 0C6h, 01h, 13h
		db	0DAh, 0C5h, 0D6h, 0CBh, 0CCh, 0D0h, 0D1h, 0CAh, 0D4h, 85h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0CAh, 0D7h, 0C5h, 0D6h, 0CBh, 6Eh, 4Dh, 5Dh, 0D0h, 0D1h
		db	0CAh, 0D4h, 87h, 0C4h, 56h, 0D4h, 02h, 29h, 01h, 2Ah, 8Ah, 0C6h
		db	0DBh, 0C5h, 0D6h, 0CBh, 4Eh, 0D1h, 0CAh, 0DAh, 85h, 0C5h, 0D6h, 0CBh
		db	0D1h, 0CAh, 44h, 0D6h, 03h, 12h, 0CBh, 0CCh, 0CEh, 5Dh, 0D0h, 0D1h
		db	0CAh, 0D4h, 87h, 0C5h, 0D6h, 49h, 0C3h, 06h, 01h, 8Ah, 0C6h, 0D6h
		db	0CAh, 01h, 12h, 01h, 13h, 0D9h, 85h, 0C5h, 0D6h, 0CBh, 0D1h, 0CAh
		db	0DAh, 0C6h, 04h, 13h, 0CBh, 0CCh, 0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h
		db	87h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h, 92h, 0C5h, 0D6h, 0CBh, 0D1h, 0DAh
		db	0D7h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D3h, 0DBh, 84h, 0C5h, 0D6h, 0CBh
		db	0CCh, 0CEh, 5Dh, 0D0h, 0D1h, 0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0D1h
		db	56h, 0D8h, 8Fh, 0C5h, 0D6h, 0CBh, 0D1h, 0C7h, 0D9h, 86h, 0C5h, 0D6h
		db	0CBh, 0D1h, 0D4h, 85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 5Dh, 0D0h, 0D1h
		db	0CAh, 0D4h, 87h, 0C5h, 0D6h, 0CBh, 0D0h, 0D1h, 0C9h, 0CAh, 0D4h, 8Fh
		db	0C5h, 0D6h, 0CBh, 0D1h, 0CAh, 0D4h, 86h, 0C5h, 0D6h, 0CBh, 0D1h, 0D4h
		db	85h, 0C5h, 0D6h, 0CBh, 0CCh, 0CEh, 23h, 00h, 09h, 0FFh, 0FFh, 80h
		db	00h, 09h, 83h, 00h, 09h, 8Bh, 00h, 19h, 8Eh, 00h, 1Ah, 0FFh
		db	0FFh, 05h, 80h, 9Dh, 0BEh, 00h, 16h, 00h, 05h, 40h, 0A0h, 0BFh
		db	00h, 0Bh, 00h, 0Ch, 80h, 91h, 07h, 00h, 11h, 00h, 2Dh, 40h
		db	31h, 29h, 00h, 34h, 00h, 35h, 80h, 90h, 31h, 00h, 39h, 00h
		db	39h, 80h, 1Bh, 35h, 00h, 3Dh, 00h, 3Eh, 40h, 0B1h, 37h, 00h
		db	42h, 00h, 42h, 40h, 9Bh, 40h, 00h, 44h, 00h, 44h, 40h, 90h
		db	3Eh, 00h, 49h, 00h, 7Dh, 40h, 0A1h, 76h, 00h, 82h, 00h, 0B3h
		db	80h, 8Fh, 0AAh, 00h, 0BCh, 00h, 0B3h, 40h, 91h, 0AAh, 00h, 0BCh
		db	00h, 0FFh, 0FFh, 09h, 00h, 37h, 82h, 12h, 0CAh, 00h, 3Ch, 00h
		db	0FFh, 0FFh, 0FFh, 14h, 00h, 09h, 0C3h, 14h, 19h, 00h, 28h, 00h
		db	0FFh, 0FFh, 0FFh, 67h, 00h, 21h, 02h, 12h, 31h, 00h, 3Bh, 00h
		db	35h, 00h, 20h, 6Dh, 00h, 2Eh, 84h, 12h, 68h, 00h, 35h, 00h
		db	0FFh, 0FFh, 0FFh, 7Fh, 00h, 2Eh, 83h, 12h, 78h, 00h, 16h, 00h
		db	0FFh, 0FFh, 0FFh, 95h, 00h, 3Ah, 81h, 12h, 5Eh, 00h, 11h, 00h
		db	0FFh, 0FFh, 0FFh, 0ABh, 00h, 20h, 81h, 12h, 0A5h, 00h, 2Bh, 00h
		db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 35h, 00h, 20h, 52h, 0D7h, 82h, 12h
		db	0FFh, 0FFh, 35h, 00h, 10h, 5Dh, 0D8h, 00h, 0FFh, 68h, 0D8h, 0FFh
		db	0FFh, 0FFh, 0FFh, 35h, 00h, 08h, 0CDh, 0D9h, 00h, 0FFh, 0D8h, 0D9h
		db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 15h, 0AFh, 02h, 12h

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'Cavern of Reaccion'

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	15h, 00h, 06h, 0Ch, 0Ch, 05h, 00h, 2Dh, 0FFh, 02h, 00h, 00h
		db	10h, 00h, 00h, 00h, 05h, 00h, 2Dh, 02h, 00h, 05h, 00h, 2Fh
		db	0FFh, 03h, 00h, 00h, 10h, 00h, 00h, 00h, 05h, 00h, 2Fh, 03h
		db	00h, 14h, 00h, 21h, 0FFh, 02h, 00h, 00h, 10h, 00h, 00h, 00h
		db	14h, 00h, 21h, 02h, 00h, 14h, 00h, 23h, 0FFh, 03h, 00h, 00h
		db	10h, 00h, 00h, 00h, 14h, 00h, 23h, 03h, 00h, 17h, 00h, 3Bh
		db	0FFh, 00h, 00h, 00h, 10h, 00h, 00h, 00h, 17h, 00h, 3Bh, 00h
		db	00h, 17h, 00h, 3Dh, 0FFh, 01h, 00h, 00h, 10h, 00h, 00h, 00h
		db	17h, 00h, 3Dh, 01h, 00h, 19h, 00h, 2Dh, 0FFh, 02h, 00h, 00h
		db	10h, 00h, 00h, 00h, 19h, 00h, 2Dh, 02h, 00h, 19h, 00h, 2Fh
		db	0FFh, 03h, 00h, 00h, 10h, 00h, 00h, 00h, 19h, 00h, 2Fh, 03h
		db	00h, 1Eh, 00h, 23h, 0FFh, 04h, 00h, 00h, 00h, 00h, 00h, 00h
		db	1Eh, 00h, 23h, 04h, 00h, 28h, 00h, 07h, 0FFh, 73h, 00h, 00h
		db	20h, 00h, 19h, 00h, 35h, 00h, 10h, 00h, 00h, 3Dh, 00h, 20h
		db	0FFh, 04h, 00h, 00h, 00h, 00h, 00h, 00h, 3Dh, 00h, 20h, 04h
		db	00h, 45h, 00h, 1Eh, 0FFh, 02h, 00h, 00h, 10h, 00h, 00h, 00h
		db	45h, 00h, 1Eh, 02h, 00h, 45h, 00h, 20h, 0FFh, 03h, 00h, 00h
		db	10h, 00h, 00h, 00h, 45h, 00h, 20h, 03h, 00h, 52h, 00h, 15h
		db	0FFh, 00h, 00h, 00h, 10h, 00h, 00h, 00h, 52h, 00h, 15h, 00h
		db	00h, 52h, 00h, 17h, 0FFh, 01h, 00h, 00h, 10h, 00h, 00h, 00h
		db	52h, 00h, 17h, 01h, 00h, 59h, 00h, 3Ch, 0FFh, 02h, 00h, 00h
		db	10h, 00h, 00h, 00h, 59h, 00h, 3Ch, 02h, 00h, 59h, 00h, 3Eh
		db	0FFh, 03h, 00h, 00h, 10h, 00h, 00h, 00h, 59h, 00h, 3Eh, 03h
		db	00h, 5Ch, 00h, 2Eh, 0FFh, 00h, 00h, 00h, 10h, 00h, 00h, 00h
		db	5Ch, 00h, 2Eh, 00h, 00h, 5Ch, 00h, 30h, 0FFh, 01h, 00h, 00h
		db	10h, 00h, 00h, 00h, 5Ch, 00h, 30h, 01h, 00h, 6Fh, 00h, 15h
		db	0FFh, 00h, 00h, 00h, 10h, 00h, 00h, 00h, 6Fh, 00h, 15h, 00h
		db	00h, 6Fh, 00h, 17h, 0FFh, 01h, 00h, 00h, 10h, 00h, 00h, 00h
		db	6Fh, 00h, 17h, 01h, 00h, 7Bh, 00h, 05h, 0FFh, 00h, 00h, 00h
		db	10h, 00h, 00h, 00h, 7Bh, 00h, 05h, 00h, 00h, 7Bh, 00h, 07h
		db	0FFh, 01h, 00h, 00h, 10h, 00h, 00h, 00h, 7Bh, 00h, 07h, 01h
		db	00h, 7Fh, 00h, 3Ah, 0FFh, 02h, 00h, 00h, 10h, 00h, 00h, 00h
		db	7Fh, 00h, 3Ah, 02h, 00h, 7Fh, 00h, 3Ch, 0FFh, 03h, 00h, 00h
		db	10h, 00h, 00h, 00h, 7Fh, 00h, 3Ch, 03h, 00h, 8Bh, 00h, 30h
		db	0FFh, 04h, 00h, 00h, 00h, 00h, 00h, 00h, 8Bh, 00h, 30h, 04h
		db	00h, 94h, 00h, 17h, 0FFh, 00h, 00h, 00h, 10h, 00h, 00h, 00h
		db	94h, 00h, 17h, 00h, 00h, 94h, 00h, 19h, 0FFh, 01h, 00h, 00h
		db	10h, 00h, 00h, 00h, 94h, 00h, 19h, 01h, 00h, 0A5h, 00h, 22h
		db	0FFh, 04h, 00h, 00h, 00h, 00h, 00h, 00h, 0A5h, 00h, 22h, 04h
		db	00h, 0AEh, 00h, 33h, 0FFh, 00h, 00h, 00h, 10h, 00h, 00h, 00h
		db	0AEh, 00h, 33h, 00h, 00h, 0AEh, 00h, 35h, 0FFh, 01h, 00h, 00h
		db	10h, 00h, 00h, 00h, 0AEh, 00h, 35h, 01h, 00h, 0B3h, 00h, 17h
		db	0FFh, 04h, 00h, 00h, 00h, 00h, 00h, 00h, 0B3h, 00h, 17h, 04h
		db	00h, 0C1h, 00h, 39h, 0FFh, 73h, 00h, 04h, 20h, 00h, 00h, 00h
		db	35h, 00h, 08h, 00h, 00h, 0C2h, 00h, 21h, 0FFh, 00h, 00h, 00h
		db	10h, 00h, 00h, 00h, 0C2h, 00h, 21h, 00h, 00h, 0C2h, 00h, 23h
		db	0FFh, 01h, 00h, 00h, 10h, 00h, 00h, 00h, 0C2h, 00h, 23h, 01h
		db	00h, 0FFh, 0FFh

map_mp71	endp

seg_a		ends

		end	start
