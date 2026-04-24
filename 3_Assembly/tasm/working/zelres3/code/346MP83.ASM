
PAGE  59,132

;==========================================================================
;
;  346MP83.BIN - Level 8 Floor 3
;
;  Zeliard dungeon map data file (MP83). Loaded by stick.bin as an
;  MDT (map data table). This is labyrinth/cavern map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x0caf = 3247)
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

map_mp83	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	0CAFh		; total_size field
		dw	0000h		; reserved / zero
		dw	0CC38h		; hdr ptr[0] (runtime addr)
		dw	0080h		; hdr ptr[1] (runtime addr)
		dw	0CB76h		; hdr ptr[2] (runtime addr)
		dw	0CB7Bh		; hdr ptr[3] (runtime addr)
		dw	0CB98h		; hdr ptr[4] (runtime addr)
		dw	0CBFCh		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	22h, 0CCh, 24h, 0CCh, 3Dh, 0CCh, 08h, 0FFh, 0FFh, 0FFh, 0Ah, 00h
		db	00h, 76h, 0CBh, 10h, 13h, 0C5h, 66h, 89h, 0C4h
		db	'fQ@Q@Q'
		db	87h, 0C4h, 0C7h, 0CCh, 85h, 82h, 09h, 13h, 04h, 12h, 0C4h, 56h
		db	8Ah, 0C4h, 4Bh, 0C7h, 95h, 0C5h, 46h, 0C9h, 84h, 82h, 0C3h, 83h
		db	03h, 12h, 01h, 13h, 85h, 0C4h, 0CAh, 66h, 88h, 0C5h, 0CAh, 0CCh
		db	46h, 87h, 0C3h, 46h, 81h, 46h, 87h, 0C4h, 0C7h, 4Bh, 84h, 82h
		db	0C4h, 0C7h, 82h, 03h, 12h, 01h, 13h, 85h, 0C4h, 0CCh, 0C7h, 0CAh
		db	0CCh, 89h, 0C5h, 46h, 0CCh, 88h, 0C5h, 0CAh, 0CCh, 0C9h, 0CCh, 0C7h
		db	87h, 0C4h, 46h, 0CCh, 84h, 82h, 0C4h, 46h, 81h, 03h, 12h, 01h
		db	13h, 85h, 0C4h, 0CAh, 5Bh, 89h, 0C4h, 66h, 87h, 0C5h, 46h, 0CCh
		db	0CAh, 0CBh, 0C7h, 86h, 0C4h, 0CAh, 0C7h, 0CBh, 84h, 82h, 0C4h, 0CAh
		db	0C7h, 81h, 03h, 12h, 01h, 13h, 85h, 0C4h, 0C7h, 0C9h, 0CCh, 0CBh
		db	89h, 0C4h, 0C7h, 0CAh, 0C9h, 0C7h, 87h, 0C4h, 0C7h, 0C9h, 0C7h, 0CCh
		db	0C7h, 87h, 0C4h, 46h, 85h, 82h, 0C5h, 46h, 81h, 03h, 12h, 01h
		db	13h, 85h, 0C4h, 0CAh, 56h, 89h, 0C6h, 56h, 88h, 0C4h, 56h, 0CAh
		db	0C7h, 87h, 0C4h, 0CCh, 0C9h, 85h, 82h, 0C4h, 56h, 03h, 12h, 01h
		db	13h, 85h, 0C5h, 76h, 94h, 0C4h, 05h, 07h, 86h, 0C4h, 0C7h, 0CCh
		db	0CBh, 84h, 82h, 0C4h, 0C7h, 0C9h, 0C7h, 03h, 12h, 01h, 13h, 85h
		db	0C4h, 66h, 95h, 0C4h, 0C7h, 0CAh, 0C7h, 0C9h, 56h, 85h, 0C4h, 46h
		db	85h, 82h, 0C4h, 0CCh, 46h, 03h, 12h, 01h, 13h, 85h, 0C4h, 0C7h
		db	0CAh, 0CCh, 0C9h, 95h, 0C4h, 46h, 0CCh, 66h, 85h, 0C6h, 0C7h, 0CAh
		db	0C8h, 84h, 82h, 0C4h, 0CAh, 0C7h, 81h, 03h, 12h, 01h, 13h, 85h
		db	0C4h, 0C9h, 0C7h, 0CCh, 46h, 88h, 0C3h, 0C7h, 0CCh, 0C7h, 88h, 0C5h
		db	0C7h, 0C9h, 0CBh, 0CCh, 46h, 8Eh, 0C2h, 81h, 0C4h, 0C9h, 0CCh, 0C7h
		db	03h, 12h, 01h, 13h, 85h, 0C4h, 0C7h, 0C9h, 0C7h, 0CCh, 89h, 0C4h
		db	0CCh, 0C7h, 0CBh, 88h, 0C4h, 46h, 0CCh, 66h, 51h, 0C1h, 41h, 40h
		db	41h, 40h, 0C2h, 82h, 0C5h, 0C7h, 0CBh, 0C7h, 03h, 12h, 01h, 13h
		db	85h, 0C4h, 46h, 49h, 0CBh, 88h, 0C4h, 66h, 87h, 0C4h, 56h, 0CCh
		db	46h, 8Eh, 82h, 0C6h, 46h, 81h, 03h, 12h, 01h, 13h, 85h, 0C4h
		db	0C9h, 0CBh, 0C7h, 0CCh, 89h, 0C5h, 46h, 0CAh, 0C7h, 87h, 0C4h, 46h
		db	8Ah, 0C3h, 0CAh, 0CCh, 46h, 83h, 86h, 03h, 12h, 01h, 13h, 85h
		db	0C5h, 76h, 88h, 0C5h, 0C7h, 0C9h, 0CBh, 0C7h, 87h, 0C6h, 0C7h, 81h
		db	0C7h, 89h, 0C4h, 0C7h, 0CCh, 0C9h, 46h, 82h, 86h, 03h, 12h, 01h
		db	13h, 85h, 0C5h, 66h, 89h, 0C4h, 46h, 0CAh, 0CBh, 94h, 0C4h, 46h
		db	0CCh, 46h, 82h, 86h, 03h, 12h, 01h, 13h, 85h, 0C4h, 0CCh, 0C7h
		db	8Bh, 0C4h, 66h, 0C1h, 41h, 40h, 0C2h, 60h, 8Ah, 0C4h, 0C7h, 0CCh
		db	0CAh, 0C7h, 83h, 86h, 03h, 12h, 01h, 13h, 85h, 0C4h, 0C7h, 0C9h
		db	8Bh, 0C4h, 0CBh, 0CCh, 46h, 94h, 0C4h, 56h, 84h, 86h, 03h, 12h
		db	01h, 13h, 85h, 0C4h, 46h, 8Bh, 0C5h, 46h, 96h, 0C5h, 46h, 81h
		db	0C8h, 83h, 86h, 03h, 12h, 0C3h, 0C7h, 85h, 0C4h, 0CAh, 0C7h, 8Bh
		db	0C4h, 0C7h, 97h, 0C5h, 56h, 81h, 0C8h, 82h, 86h, 03h, 12h, 0C4h
		db	0C7h, 0CCh, 84h, 0C4h, 0C7h, 0CBh, 84h, 0C3h, 0C7h, 85h, 0C4h, 0C8h
		db	97h, 0C4h, 56h, 81h, 0C8h, 82h, 86h, 03h, 12h, 0C5h, 0C9h, 0C7h
		db	84h, 0C6h, 0C7h, 85h, 0C5h, 0C9h, 0C7h, 84h, 0C4h, 0C9h, 97h, 0C4h
		db	46h, 0C9h, 0C7h, 83h, 86h, 03h, 12h, 0C4h, 0C7h, 8Ch, 0C4h, 0CCh
		db	0C7h, 84h, 0C6h, 0C8h, 97h, 0C4h, 0C7h, 0CAh, 4Bh, 0C7h, 82h, 86h
		db	03h, 12h, 0C4h, 0CAh, 41h, 0C1h, 51h, 40h, 0C2h, 40h, 81h, 0C4h
		db	0CAh, 0CCh, 9Dh, 0C4h, 0C9h, 0CCh, 0C7h, 0CBh, 83h, 86h, 03h, 12h
		db	0C4h, 0C7h, 0CBh, 8Bh, 0C5h, 46h, 0CBh, 9Ch, 0C4h, 49h, 0CCh, 0C7h
		db	83h, 86h, 03h, 12h, 0C4h, 0CCh, 85h, 0C3h, 0C7h, 85h, 0C4h, 56h
		db	92h, 0C3h, 81h, 0C7h, 87h, 0C4h, 66h, 83h, 86h, 03h, 12h, 0C4h
		db	0C7h, 0CCh, 84h, 0C4h, 0C9h, 0C7h, 84h, 0C4h, 0CAh, 0CCh, 66h, 8Fh
		db	0C4h, 81h, 46h, 86h, 0C4h, 46h, 81h, 0C8h, 83h, 86h, 03h, 12h
		db	0C5h, 46h, 84h, 0C4h, 4Bh, 84h, 0C4h, 0C7h, 4Bh, 56h, 0C9h, 8Eh
		db	0C4h, 46h, 0C9h, 0C7h, 85h, 0C5h, 56h, 84h, 86h, 03h, 12h, 0C4h
		db	46h, 84h, 0C5h, 0CAh, 0CBh, 84h, 0C5h, 56h, 0CCh, 0C9h, 56h, 8Dh
		db	0C4h, 0C7h, 0CCh, 0C7h, 86h, 0C4h, 0C7h, 0C9h, 46h, 83h, 86h, 03h
		db	12h, 0C4h, 0C9h, 0C7h, 84h, 0C4h, 46h, 84h, 0C4h, 83h, 0C7h, 0CAh
		db	46h, 8Eh, 0C5h, 0CAh, 0C7h, 0CCh, 86h, 0C4h, 46h, 0CCh, 81h, 0C8h
		db	82h, 86h, 03h, 12h, 0C6h, 0CAh, 85h, 0C4h, 0C7h, 85h, 0C4h, 83h
		db	46h, 90h, 0C4h, 56h, 86h, 0C4h, 76h, 82h, 86h, 03h, 12h, 01h
		db	13h, 85h, 0C4h, 46h, 84h, 0C6h, 89h, 0C3h, 81h, 0C7h, 81h, 46h
		db	86h, 0C4h, 0C7h, 0C9h, 46h, 85h, 0C4h, 66h, 83h, 86h, 03h, 12h
		db	01h, 13h, 85h, 0C4h, 0C7h, 8Fh, 0C4h, 0C7h, 0C9h, 66h, 85h, 0C4h
		db	56h, 86h, 0C4h, 56h, 81h, 0C7h, 82h, 86h, 03h, 12h, 01h, 13h
		db	85h, 0C4h, 0C7h, 8Fh, 0C4h, 0C7h, 0CAh, 4Bh, 46h, 85h, 0C4h, 0CAh
		db	0CCh, 87h, 0C4h, 0CAh, 0CCh, 46h, 83h, 86h, 03h, 12h, 01h, 13h
		db	85h, 0C4h, 46h, 8Eh, 0C4h, 0C9h, 46h, 0CCh, 0C9h, 0C7h, 85h, 0C5h
		db	0C7h, 0CCh, 0CBh, 86h, 0C4h, 0C7h, 0C9h, 0CCh, 84h, 86h, 03h, 12h
		db	01h, 13h, 85h, 0C4h, 0CAh, 0C9h, 8Eh, 0C5h, 56h, 0CAh, 0CCh, 86h
		db	0C4h, 0C9h, 0C7h, 0CCh, 86h, 0C5h, 46h, 0CCh, 84h, 86h, 03h, 12h
		db	01h, 13h, 85h, 0C4h, 46h, 0CCh, 0CAh, 8Ch, 0C4h, 0C7h, 0C9h, 46h
		db	0CBh, 0C7h, 85h, 0C6h, 56h, 86h, 0C4h, 46h, 0CAh, 0CBh, 83h, 86h
		db	03h, 12h, 01h, 13h, 85h, 0C4h, 56h, 0C9h, 0C7h, 8Bh, 0C5h, 76h
		db	90h, 0C4h, 46h, 0C9h, 0C7h, 83h, 82h, 0C3h, 46h, 81h, 03h, 12h
		db	01h, 13h, 85h, 0C4h, 0CAh, 0CCh, 0C7h, 0CBh, 0CCh, 0C8h, 8Ah, 0C4h
		db	05h, 07h, 05h, 01h, 61h, 60h, 81h, 0C5h, 76h, 82h, 82h, 0C4h
		db	0C7h, 0C9h, 8Ch, 0C5h, 0C7h, 0CCh, 46h, 8Ch, 0C4h, 0C7h, 0C9h, 0C7h
		db	0CCh, 0C7h, 90h, 0C4h, 0C7h, 0CAh, 0CCh, 0C7h, 83h, 82h, 0C5h, 0C7h
		db	0CCh, 8Ch, 0C4h, 0C7h, 0CBh, 0C9h, 0C7h, 8Ch, 0C4h, 0CAh, 0C7h, 0CCh
		db	0CAh, 0CCh, 0C7h, 86h, 0C3h, 46h, 86h, 0C4h, 46h, 4Ah, 83h, 82h
		db	0C4h, 0CAh, 0C7h, 0CBh, 8Bh, 0C5h, 46h, 0CBh, 8Dh, 0C4h, 0CCh, 46h
		db	0C9h, 0C7h, 87h, 0C4h, 0CBh, 0CCh, 0C7h, 85h, 0C4h, 56h, 84h, 81h
		db	0E5h, 66h, 8Bh, 0C4h, 0C7h, 0CCh, 0C7h, 8Dh, 0C4h, 0CAh, 0CBh, 0C7h
		db	0CCh, 0C7h, 87h, 0C4h, 0C7h, 0C9h, 0C7h, 85h, 0C4h, 0C7h, 0C8h, 0CAh
		db	84h, 0E5h, 0C8h, 0CAh, 0C7h, 8Dh, 0C4h, 0CCh, 0CAh, 0C7h, 8Dh, 0C5h
		db	46h, 0CAh, 0CBh, 46h, 86h, 0C4h, 0CAh, 0CCh, 0CBh, 85h, 0C5h, 81h
		db	46h, 84h, 0E9h, 0E5h, 0C7h, 0CBh, 0C7h, 60h, 61h, 50h, 81h, 0C4h
		db	0CAh, 0CCh, 84h, 0C3h, 89h, 0C4h, 56h, 0CAh, 0C7h, 87h, 0C4h, 46h
		db	86h, 0C6h, 81h, 0C7h, 84h, 0E5h, 0E5h, 56h, 8Dh, 0C4h, 46h, 84h
		db	0C4h, 89h, 0C6h, 81h, 66h, 87h, 0C4h, 0C7h, 0C9h, 0C7h, 8Bh, 0E5h
		db	0E9h, 0E9h, 0E5h, 56h, 86h, 0C3h, 0C7h, 84h, 0C4h, 0C7h, 85h, 0C5h
		db	96h, 0C5h, 0CCh, 0C7h, 8Ch, 0E9h, 0E5h, 0E5h, 0C7h, 4Bh, 87h, 0C4h
		db	0CAh, 84h, 0C5h, 46h, 84h, 0C5h, 0C7h, 95h, 0C4h, 0C7h, 0CCh, 0C7h
		db	8Bh, 0E5h, 0E9h, 0E9h, 0E5h, 0C7h, 0C9h, 87h, 0C4h, 0C7h, 84h, 0C6h
		db	0C7h, 85h, 0C4h, 0CAh, 0CCh, 94h, 0C4h, 0C9h, 0CAh, 0C7h, 8Bh, 0E9h
		db	0E5h, 0E5h, 56h, 0CBh, 86h, 0C4h, 0C7h, 8Bh, 0C4h, 0CCh, 0C7h, 94h
		db	0C6h, 46h, 8Ch, 0E5h, 0E9h, 0E9h, 0E5h, 56h, 86h, 0C5h, 0C7h, 8Bh
		db	0C4h, 0CBh, 0CCh, 46h, 9Bh, 0CFh, 85h, 0E9h, 0E5h, 0E5h, 0CAh, 0CCh
		db	56h, 85h, 0C4h, 0C9h, 0C7h, 8Ah, 0C4h, 0CCh, 0CAh, 0CCh, 0C7h, 0C1h
		db	51h, 40h, 41h, 40h, 41h, 8Eh, 0CFh, 0C7h, 85h, 0E5h, 0E9h, 0E9h
		db	0E5h, 0CCh, 46h, 86h, 0C5h, 76h, 87h, 0C4h, 56h, 9Bh, 0C4h, 0C7h
		db	85h, 0E9h, 0E5h, 0E5h, 46h, 0CAh, 0C9h, 86h, 0C4h, 0CCh, 56h, 0CCh
		db	0C7h, 86h, 0C5h, 0C7h, 0C9h, 9Ch, 0D0h, 0CAh, 85h, 0E5h, 0E9h, 0C9h
		db	0E5h, 56h, 86h, 0C4h, 0CAh, 0CBh, 0C9h, 46h, 0CCh, 86h, 0C4h, 0C7h
		db	0CCh, 9Dh, 0D0h, 85h, 0E9h, 0E5h, 0E5h, 46h, 88h, 0C4h, 56h, 0CAh
		db	0CCh, 0CBh, 86h, 0C6h, 46h, 0A3h, 0E5h, 0E9h, 0E9h, 0E5h, 46h, 87h
		db	0C4h, 0C7h, 81h, 56h, 0CAh, 0ACh, 0E9h, 0E5h, 0E5h, 0C7h, 0C9h, 46h
		db	86h, 0C4h, 0C9h, 46h, 0CCh, 46h, 40h, 0C2h, 0C1h, 41h, 40h, 0A4h
		db	0E5h, 0E9h, 0C7h, 0E5h, 0C7h, 0C9h, 0C7h, 86h, 0C4h, 0C7h, 0C9h, 46h
		db	0CBh, 0ADh, 0E9h, 0E5h, 0E5h, 0CBh, 0CAh, 0CCh, 87h, 0C5h, 0C7h, 0CAh
		db	0CCh, 0C9h, 0C7h, 86h, 0C3h, 46h, 90h, 0C3h, 0C7h, 81h, 46h, 8Fh
		db	0E5h, 0E9h, 46h, 0CCh, 46h, 86h, 0C4h, 56h, 0CCh, 0C7h, 86h, 0C4h
		db	0CAh, 0C9h, 0C7h, 8Fh, 0C4h, 46h, 0CAh, 46h, 8Eh, 0E9h, 0E5h, 0E5h
		db	46h, 88h, 0C6h, 56h, 81h, 0CBh, 86h, 0C5h, 0C7h, 0CBh, 0C9h, 8Fh
		db	0C4h, 0CAh, 4Bh, 46h, 8Eh, 0E5h, 0E9h, 0C7h, 0E5h, 95h, 0C4h, 0C7h
		db	0C9h, 0CCh, 8Fh, 0C4h, 46h, 0C9h, 0CCh, 56h, 8Ch, 0E9h, 0E5h, 0E5h
		db	0C9h, 0C1h, 51h, 40h, 51h, 0C1h, 0C2h, 50h, 0C2h, 86h, 0C4h, 0CAh
		db	0CCh, 0C7h, 8Fh, 0C5h, 56h, 0C9h, 0C7h, 8Eh, 0E5h, 0E9h, 0C7h, 0E5h
		db	95h, 0C4h, 0C7h, 0C9h, 0CBh, 8Fh, 0C5h, 0C7h, 0C9h, 0C7h, 0CAh, 0CCh
		db	8Eh, 0E9h, 0E5h, 0E5h, 0CAh, 8Dh, 0C3h, 46h, 85h, 0C5h, 0CAh, 0CCh
		db	90h, 0C4h, 0C7h, 0CAh, 0CCh, 56h, 87h, 0CFh, 85h, 0E5h, 0E9h, 0CAh
		db	0E5h, 0C7h, 8Ch, 0C4h, 0CAh, 0C9h, 0C7h, 84h, 0C6h, 46h, 84h, 0C3h
		db	82h, 0C7h, 88h, 0C4h, 0C9h, 0CCh, 0C7h, 0CCh, 0C9h, 46h, 85h, 0CFh
		db	0C9h, 85h, 0E9h, 0E5h, 0E5h, 0C7h, 0E5h, 0C7h, 8Bh, 0C4h, 0CAh, 0CBh
		db	0CCh, 8Bh, 0C4h, 0C7h, 81h, 46h, 87h, 0C4h, 66h, 0CCh, 0C7h, 86h
		db	0C4h, 0C7h, 85h, 0E5h, 0E9h, 0C7h, 0E5h, 0CCh, 0C7h, 8Bh, 0C5h, 46h
		db	0C9h, 0C7h, 8Ah, 0C4h, 0C9h, 0C7h, 0CCh, 0C7h, 87h, 0C4h, 66h, 0C9h
		db	0C7h, 86h, 0D0h, 0C7h, 85h, 0E9h, 0E5h, 0E5h, 0C7h, 0E5h, 0CBh, 8Bh
		db	0C4h, 0CCh, 46h, 0CCh, 8Ah, 0C5h, 56h, 0CCh, 0C7h, 86h, 0C5h, 46h
		db	0CAh, 46h, 88h, 0D0h, 85h, 0E5h, 0E9h, 0C8h, 0E5h, 46h, 8Bh, 0C5h
		db	0C9h, 56h, 8Ah, 0C4h, 0CAh, 0C7h, 0CCh, 0C7h, 0CBh, 86h, 0C4h, 0C7h
		db	0C9h, 0C7h, 0CCh, 0C7h, 8Eh, 0E9h, 0E5h, 0E5h, 0C9h, 46h, 8Bh, 0C4h
		db	0CAh, 4Bh, 0C7h, 8Ah, 0C4h, 0C7h, 0C9h, 0CAh, 0CBh, 0C7h, 86h, 0C5h
		db	46h, 0C9h, 0C7h, 0CCh, 0C7h, 8Dh, 0E5h, 0E9h, 0C7h, 0E5h, 0CCh, 0C7h
		db	8Bh, 0C4h, 46h, 0CCh, 0C9h, 0C7h, 89h, 0C4h, 46h, 0C9h, 46h, 86h
		db	0C4h, 56h, 0CCh, 0C7h, 8Eh, 0E9h, 0E5h, 0E5h, 0C8h, 0E5h, 0CCh, 8Bh
		db	0C4h, 0C9h, 0CBh, 0CAh, 56h, 88h, 0C4h, 66h, 87h, 0C6h, 46h, 0CAh
		db	0CCh, 0C7h, 8Eh, 0E5h, 0E9h, 0E9h, 0E5h, 0CCh, 0CAh, 8Bh, 0C5h, 46h
		db	0C9h, 0C7h, 8Ah, 0C5h, 0C7h, 0CCh, 0CAh, 0CCh, 0C7h, 9Bh, 0E5h, 0E5h
		db	46h, 0CCh, 8Bh, 0C4h, 0CCh, 46h, 0CBh, 0C7h, 89h, 0C4h, 0C9h, 66h
		db	0C2h, 0C1h, 41h, 70h, 71h, 0C1h, 0C2h, 60h, 88h, 81h, 0E5h, 56h
		db	8Ah, 0C4h, 0C7h, 0CBh, 46h, 0C9h, 89h, 0C5h, 46h, 0CCh, 0CAh, 0CCh
		db	9Ch, 82h, 0C4h, 46h, 85h, 0C3h, 46h, 81h, 46h, 0C9h, 0CBh, 66h
		db	88h, 0C6h, 56h, 0CCh, 0C7h, 8Ch, 0C3h, 81h, 56h, 81h, 05h, 07h
		db	84h, 82h, 0C4h, 0C7h, 0CAh, 85h, 0C4h, 46h, 0CAh, 46h, 0CAh, 0C7h
		db	82h, 03h, 11h, 05h, 12h, 04h, 13h, 8Dh, 0C4h, 56h, 0CAh, 4Bh
		db	0C7h, 0CAh, 0CCh, 46h, 84h, 82h, 0C4h, 56h, 84h, 0C5h, 0C7h, 0C9h
		db	46h, 0C9h, 0C7h, 83h, 03h, 11h, 05h, 12h, 04h, 13h, 8Dh, 0C4h
		db	46h, 0C9h, 0C7h, 0C9h, 56h, 0CAh, 0CBh, 85h, 82h, 0C5h, 0C9h, 0CCh
		db	85h, 0C4h, 46h, 0CCh, 46h, 84h, 01h, 11h, 0Ch, 13h, 8Dh, 0C4h
		db	0CAh, 66h, 0CAh, 0C9h, 0CCh, 46h, 0CCh, 84h, 82h, 0C4h, 4Bh, 85h
		db	0C4h, 0CAh, 46h, 0CCh, 0C7h, 84h, 01h, 11h, 0Ch, 13h, 8Dh, 0C5h
		db	0CCh, 0CAh, 56h, 0CCh, 81h, 0C7h, 0C9h, 0C7h, 0CBh, 84h, 82h, 0C4h
		db	0C7h, 0CBh, 0CAh, 84h, 0C4h, 46h, 0C9h, 0C7h, 0CBh, 8Ah, 0C3h, 0C7h
		db	0CAh, 0CCh, 46h, 90h, 0C5h, 0C7h, 0CCh, 56h, 0C9h, 0CCh, 66h, 84h
		db	82h, 0C4h, 46h, 0CCh, 84h, 0C5h, 0CAh, 0CCh, 0C7h, 8Ch, 0C5h, 56h
		db	0CCh, 0C7h, 90h, 0C4h, 0CAh, 0C7h, 0CCh, 46h, 0C9h, 46h, 87h, 82h
		db	0C4h, 0C7h, 81h, 0C7h, 84h, 0C5h, 46h, 0CCh, 8Ch, 0C4h, 0C7h, 0C9h
		db	46h, 0CCh, 0C7h, 8Fh, 0C6h, 0C7h, 81h, 56h, 8Ah, 82h, 0C4h, 46h
		db	85h, 0C4h, 0C9h, 56h, 8Bh, 0C4h, 0C7h, 0CAh, 0CCh, 0CBh, 46h, 9Fh
		db	82h, 0C4h, 0CBh, 86h, 0C4h, 46h, 0CAh, 46h, 8Ah, 0C4h, 0C9h, 46h
		db	0CAh, 0CCh, 0C7h, 9Fh, 82h, 0C4h, 0CAh, 0CCh, 85h, 0C4h, 46h, 0CCh
		db	0C7h, 8Bh, 0C4h, 76h, 90h, 0C3h, 81h, 46h, 8Ch, 82h, 0C4h, 0C7h
		db	86h, 0C4h, 56h, 0CCh, 8Bh, 0C4h, 66h, 87h, 0C3h, 0CAh, 0C7h, 87h
		db	0C4h, 0CAh, 0CCh, 46h, 8Bh, 82h, 0C5h, 56h, 84h, 0C4h, 66h, 8Bh
		db	0C5h, 46h, 0CCh, 0CBh, 0CCh, 0C7h, 85h, 0C4h, 0C7h, 0CAh, 0C7h, 86h
		db	0C4h, 0C7h, 0CAh, 4Bh, 8Bh, 82h, 0C4h, 46h, 85h, 0C4h, 05h, 07h
		db	89h, 0C4h, 46h, 0CAh, 0CCh, 0C7h, 86h, 0C4h, 0C7h, 0CCh, 46h, 85h
		db	0C5h, 0C7h, 0CCh, 0C9h, 0C7h, 8Bh, 82h, 0C5h, 0C7h, 86h, 0C5h, 0C7h
		db	0C9h, 0CCh, 0C7h, 8Bh, 0C4h, 05h, 07h, 85h, 0C5h, 0CCh, 0C9h, 0CCh
		db	0C7h, 85h, 0C4h, 56h, 8Ch, 0C2h, 81h, 0C4h, 0C7h, 0CCh, 0C7h, 84h
		db	0C4h, 0CAh, 0CCh, 0C7h, 0CBh, 8Bh, 0C4h, 0C7h, 0C9h, 0C7h, 0CAh, 0CCh
		db	0C7h, 85h, 0C5h, 56h, 0CBh, 85h, 0C4h, 76h, 0C2h, 0C1h, 51h, 40h
		db	41h, 0C1h, 82h, 0C4h, 0CCh, 0C9h, 81h, 03h, 11h, 0C4h, 46h, 8Dh
		db	0C4h, 05h, 07h, 85h, 0C4h, 56h, 0C9h, 85h, 0C4h, 0C9h, 0CCh, 46h
		db	8Bh, 82h, 0C4h, 46h, 81h, 03h, 11h, 0C4h, 0C7h, 8Eh, 0C5h, 56h
		db	0CCh, 0C9h, 0CBh, 85h, 0C4h, 0CCh, 0C7h, 0CAh, 81h, 0C7h, 03h, 11h
		db	0C4h, 0CAh, 0CBh, 46h, 86h, 0C3h, 46h, 82h, 82h, 0C4h, 0C7h, 82h
		db	03h, 11h, 0C4h, 0CAh, 40h, 41h, 50h, 61h, 40h, 81h, 0C5h, 46h
		db	0C9h, 0CCh, 46h, 85h, 0C4h, 0CAh, 0CBh, 46h, 81h, 03h, 11h, 0C5h
		db	46h, 0CCh, 81h, 0C7h, 85h, 0C4h, 0C7h, 83h, 82h, 0C6h, 81h, 0C7h
		db	81h, 03h, 11h, 0C4h, 0C7h, 8Eh, 0C4h, 0C7h, 0CAh, 0CCh, 0CBh, 46h
		db	85h, 0C4h, 76h, 03h, 11h, 0C4h, 0C7h, 0C9h, 0C7h, 0CCh, 86h, 0C4h
		db	0C9h, 0C7h, 82h, 86h, 03h, 11h, 0C5h, 46h, 84h, 0C3h, 0C7h, 0C9h
		db	0C7h, 85h, 0C4h, 0C7h, 81h, 46h, 0CBh, 0C7h, 85h, 0C4h, 76h, 03h
		db	11h, 0C5h, 46h, 0C9h, 0C7h, 86h, 0C4h, 46h, 82h, 86h, 03h, 11h
		db	0C4h, 0CCh, 0C7h, 84h, 0C4h, 46h, 0CCh, 85h, 0C6h, 82h, 56h, 86h
		db	0C5h, 46h, 0CCh, 0C7h, 81h, 03h, 11h, 0C4h, 0CAh, 0CCh, 46h, 86h
		db	0C4h, 0C7h, 0CAh, 0C7h, 81h, 86h, 03h, 11h, 0C4h, 0C9h, 0CCh, 84h
		db	0C4h, 56h, 91h, 0C4h, 56h, 0CCh, 85h, 0C4h, 0CCh, 0C9h, 46h, 86h
		db	0C4h, 0CCh, 0C9h, 0C7h, 81h, 86h, 03h, 11h, 0C6h, 0C7h, 85h, 0C4h
		db	0CAh, 0CCh, 0CBh, 91h, 0C4h, 0CCh, 0C9h, 46h, 85h, 0C6h, 81h, 46h
		db	87h, 0C4h, 0C7h, 0CCh, 0C7h, 0C8h, 0C7h, 85h, 03h, 11h, 01h, 13h
		db	85h, 0C4h, 46h, 0CCh, 0C7h, 90h, 0C4h, 56h, 91h, 0C5h, 0CAh, 0CBh
		db	46h, 86h, 03h, 11h, 01h, 13h, 85h, 0C4h, 66h, 90h, 0C4h, 56h
		db	41h, 05h, 01h, 61h, 60h, 81h, 0C4h, 0C7h, 4Bh, 0C7h, 86h, 03h
		db	11h, 01h, 13h, 85h, 0C4h, 66h, 90h, 0C4h, 0CAh, 46h, 91h, 0C4h
		db	46h, 82h, 86h, 03h, 11h, 01h, 13h, 85h, 0C5h, 46h, 0C9h, 0C7h
		db	90h, 0C4h, 0CCh, 0CBh, 0C7h, 85h, 0C3h, 81h, 46h, 88h, 0C6h, 0C7h
		db	83h, 86h, 03h, 11h, 01h, 13h, 85h, 0C5h, 0C7h, 4Bh, 85h, 0C3h
		db	82h, 0C7h, 88h, 0C4h, 0C9h, 0CAh, 0CCh, 85h, 0C4h, 46h, 8Eh, 86h
		db	03h, 11h, 01h, 13h, 85h, 0C5h, 0C7h, 0CAh, 0CBh, 0C7h, 84h, 0C4h
		db	0C7h, 81h, 46h, 87h, 0C4h, 56h, 85h, 0C4h, 0C9h, 46h, 8Dh, 86h
		db	03h, 11h, 01h, 13h, 85h, 0C4h, 56h, 0CCh, 84h, 0C5h, 0CAh, 0C7h
		db	0C9h, 0C7h, 87h, 0C5h, 46h, 86h, 0C4h, 0C7h, 0C9h, 86h, 46h, 86h
		db	86h, 03h, 11h, 01h, 13h, 85h, 0C4h, 56h, 85h, 0C4h, 0C9h, 4Bh
		db	0C7h, 87h, 0C4h, 56h, 85h, 0C5h, 0CAh, 0CCh, 85h, 0C3h, 0C9h, 0C7h
		db	86h, 86h, 03h, 11h, 01h, 13h, 85h, 0C4h, 0C9h, 46h, 85h, 0C4h
		db	49h, 0CCh, 0C7h, 87h, 0C4h, 56h, 85h, 0C4h, 46h, 0CBh, 84h, 0C5h
		db	0CCh, 0C7h, 86h, 86h, 03h, 11h, 01h, 13h, 85h, 0C4h, 0C7h, 0CAh
		db	0CCh, 0C7h, 84h, 0C5h, 56h, 0CBh, 87h, 0C4h, 0C7h, 0CCh, 0C9h, 0C7h
		db	84h, 0C5h, 56h, 84h, 0C4h, 0C7h, 0CBh, 0C7h, 85h, 86h, 03h, 11h
		db	01h, 13h, 85h, 0C4h, 46h, 0CAh, 0CCh, 84h, 0C4h, 0CAh, 0C9h, 0C7h
		db	88h, 0C4h, 0CAh, 0CCh, 0C7h, 85h, 0C4h, 46h, 85h, 0C4h, 56h, 85h
		db	86h, 03h, 11h, 01h, 13h, 85h, 0C4h, 46h, 0CCh, 0CBh, 84h, 0C6h
		db	46h, 0CBh, 0C7h, 87h, 0C4h, 0CBh, 0C7h, 0CCh, 0C7h, 84h, 0C4h, 46h
		db	85h, 0C4h, 46h, 86h, 86h, 03h, 11h, 01h, 13h, 85h, 0C4h, 46h
		db	92h, 0C5h, 0C7h, 0CCh, 46h, 84h, 0C4h, 4Bh, 85h, 0C4h, 0CBh, 0CAh
		db	86h, 86h, 03h, 11h, 01h, 13h, 85h, 0C4h, 56h, 50h, 41h, 40h
		db	41h, 0C1h, 41h, 60h, 81h, 0C4h, 0C9h, 46h, 85h, 0C4h, 0CAh, 0CCh
		db	85h, 0C6h, 0CCh, 0CBh, 86h, 86h, 03h, 11h, 01h, 13h, 85h, 0C4h
		db	0CAh, 46h, 91h, 0C6h, 46h, 0CBh, 85h, 0C4h, 0C9h, 0CAh, 8Eh, 86h
		db	03h, 11h, 01h, 13h, 85h, 0C4h, 0C7h, 4Bh, 8Ah, 0C3h, 46h, 8Dh
		db	0C4h, 0C7h, 0CCh, 0C7h, 8Dh, 86h, 03h, 11h, 01h, 13h, 85h, 0C4h
		db	66h, 89h, 0C4h, 0C9h, 0CCh, 8Dh, 0C5h, 56h, 89h, 0C3h, 83h, 86h
		db	03h, 11h, 01h, 13h, 85h, 0C4h, 0C9h, 0C7h, 4Bh, 0C7h, 88h, 0C4h
		db	46h, 0CBh, 8Ch, 0C4h, 46h, 0CAh, 89h, 0C4h, 0C7h, 82h, 0CCh, 85h
		db	03h, 11h, 01h, 13h, 85h, 0C4h, 0C7h, 0CAh, 0C7h, 0CBh, 89h, 0C5h
		db	56h, 8Ch, 0C4h, 0C7h, 0CCh, 8Ah, 0C4h, 46h, 0CAh, 4Bh, 84h, 03h
		db	11h, 01h, 13h, 85h, 0C4h, 66h, 89h, 0C4h, 0C7h, 0C9h, 46h, 8Bh
		db	0C6h, 0CAh, 0C7h, 0CBh, 89h, 0C4h, 56h, 46h, 0CBh, 83h, 03h, 11h
		db	01h, 13h, 85h, 0C5h, 46h, 0C9h, 0C7h, 89h, 0C4h, 56h, 99h, 0C5h
		db	0C7h, 0C9h, 0C7h, 81h, 0C4h, 0C7h, 0C8h, 0C7h, 81h, 03h, 11h, 01h
		db	13h, 85h, 0C4h, 66h, 89h, 0C5h, 0CCh, 0CAh, 46h, 41h, 40h, 61h
		db	0C1h, 0C2h, 0C1h, 51h, 0C1h, 89h, 0C4h, 0C7h, 82h, 81h, 0C6h, 46h
		db	0C8h, 81h, 03h, 11h, 01h, 13h, 85h, 0C4h, 0C7h, 0C9h, 0C7h, 0CCh
		db	89h, 0C4h, 0C7h, 0CCh, 0C7h, 99h, 0C6h, 83h, 82h, 0C4h, 56h, 03h
		db	11h, 01h, 13h, 85h, 0C4h, 46h, 0CCh, 8Ah, 0C4h, 0CAh, 46h, 9Dh
		db	82h, 0C6h, 81h, 46h, 03h, 11h, 01h, 13h, 04h, 11h, 0C4h, 46h
		db	0CAh, 0CBh, 89h, 0C4h, 0CCh, 56h, 94h, 0C3h, 0C9h, 86h, 82h, 0Eh
		db	13h, 0C5h, 0C7h, 0C9h, 0C7h, 8Ah, 0C4h, 0C7h, 0C9h, 46h, 94h, 0C4h
		db	0C7h, 86h, 10h, 13h, 0C4h, 0C7h, 0CCh, 0C7h, 8Ah, 0C4h, 56h, 95h
		db	0C5h, 46h, 85h, 11h, 00h, 18h, 0FFh, 0FFh, 07h, 00h, 1Eh, 32h
		db	00h, 2Eh, 35h, 00h, 2Ch, 38h, 00h, 2Ah, 41h, 00h, 07h, 44h
		db	00h, 08h, 47h, 00h, 09h, 4Ah, 00h, 0Ah, 7Ch, 00h, 29h, 0FFh
		db	0FFh, 13h, 80h, 0AFh, 0Dh, 00h, 18h, 00h, 18h, 80h, 84h, 0Eh
		db	00h, 23h, 00h, 18h, 40h, 0A3h, 12h, 00h, 1Dh, 00h, 20h, 80h
		db	21h, 13h, 00h, 30h, 00h, 25h, 80h, 99h, 1Dh, 00h, 2Ch, 00h
		db	25h, 40h, 9Bh, 1Dh, 00h, 2Fh, 00h, 32h, 40h, 0B9h, 2Bh, 00h
		db	39h, 00h, 36h, 80h, 9Eh, 34h, 00h, 3Bh, 00h, 3Eh, 40h, 0A0h
		db	3Bh, 00h, 41h, 00h, 43h, 40h, 0B9h, 3Ch, 00h, 4Ah, 00h, 50h
		db	40h, 26h, 4Ch, 00h, 55h, 00h, 65h, 40h, 9Ch, 61h, 00h, 68h
		db	00h, 6Eh, 40h, 0BDh, 68h, 00h, 73h, 00h, 77h, 80h, 0BAh, 70h
		db	00h, 7Ch, 00h, 0FFh, 0FFh, 06h, 00h, 0Dh, 0C2h, 18h, 0E4h, 00h
		db	31h, 00h, 0FFh, 0FFh, 0FFh, 1Dh, 00h, 34h, 0C1h, 17h, 0B9h, 00h
		db	01h, 00h, 0FFh, 0FFh, 0FFh, 56h, 00h, 06h, 0C2h, 18h, 0B3h, 00h
		db	23h, 00h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 15h, 0AFh, 02h
		db	10h

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'Cavern of Falter'

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	17h, 00h, 07h, 0Eh, 0Eh, 06h, 00h, 00h, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 06h, 00h, 00h, 03h, 00h, 0Ch, 00h, 1Dh
		db	0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h, 0Ch, 00h, 1Dh, 03h
		db	00h, 15h, 00h, 36h, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	15h, 00h, 36h, 03h, 00h, 21h, 00h, 0Fh, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 21h, 00h, 0Fh, 03h, 00h, 46h, 00h, 0Dh
		db	0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h, 46h, 00h, 0Dh, 03h
		db	00h, 63h, 00h, 24h, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	63h, 00h, 24h, 03h, 00h, 71h, 00h, 0Fh, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 71h, 00h, 0Fh, 03h, 00h, 0FFh, 0FFh

map_mp83	endp

seg_a		ends

		end	start
