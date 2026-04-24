
PAGE  59,132

;==========================================================================
;
;  347MP84.BIN - Level 8 Floor 4
;
;  Zeliard dungeon map data file (MP84). Loaded by stick.bin as an
;  MDT (map data table). This is labyrinth/cavern map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x0594 = 1428)
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

map_mp84	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	0594h		; total_size field
		dw	0000h		; reserved / zero
		dw	0C57Dh		; hdr ptr[0] (runtime addr)
		dw	0040h		; hdr ptr[1] (runtime addr)
		dw	0C536h		; hdr ptr[2] (runtime addr)
		dw	0C538h		; hdr ptr[3] (runtime addr)
		dw	0C53Ah		; hdr ptr[4] (runtime addr)
		dw	0C53Ch		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	56h, 0C5h, 6Ah, 0C5h, 82h, 0C5h, 08h, 1Eh, 00h, 06h, 0Ah, 00h
		db	00h, 36h, 0C5h, 0CAh, 4Bh, 0CBh, 0CCh, 0CAh, 0C7h, 0C8h, 0E5h, 0C8h
		db	82h, 0E5h, 83h, 0E5h, 81h, 0E5h, 8Bh, 0E5h, 98h, 0C4h, 0C9h, 66h
		db	4Bh, 0C9h, 0CCh, 0CBh, 0C9h, 0CCh, 0C7h, 81h, 47h, 83h, 0E5h, 0ABh
		db	0C5h, 0C7h, 0C9h, 0CCh, 0CBh, 46h, 4Bh, 0CCh, 0CBh, 0CAh, 81h, 47h
		db	86h, 0E5h, 0AAh, 0C5h, 0C7h, 0CAh, 0CCh, 0C7h, 0CCh, 0C7h, 0C9h, 0CAh
		db	4Bh, 0CBh, 0CCh, 0C7h, 81h, 0C8h, 84h, 0E5h, 81h, 0E5h, 0A9h, 0C4h
		db	66h, 4Bh, 49h, 0CAh, 0C9h, 0CCh, 0CAh, 81h, 57h, 0AFh, 0C4h, 05h
		db	07h, 0CCh, 0CBh, 4Bh, 0CBh, 0CCh, 49h, 0C7h, 0C9h, 0C8h, 0AEh, 0C4h
		db	66h, 0C9h, 56h, 0CAh, 46h, 0CCh, 0CBh, 0CCh, 81h, 0CCh, 0CAh, 0C7h
		db	0ADh, 0C4h, 05h, 07h, 0CCh, 0CAh, 0C9h, 5Bh, 0C7h, 0C9h, 4Bh, 0C7h
		db	57h, 0ABh, 0C5h, 0CAh, 0CCh, 66h, 4Bh, 5Bh, 0CBh, 0CCh, 0CAh, 81h
		db	0C8h, 81h, 0C8h, 0ADh, 0C4h, 46h, 4Bh, 0C7h, 0C9h, 0C7h, 0CAh, 0CAh
		db	0CBh, 0CCh, 0CAh, 81h, 57h, 81h, 0C8h, 0ADh, 0C4h, 0CAh, 0C9h, 0CCh
		db	0C7h, 4Bh, 0CBh, 0C7h, 5Bh, 0CBh, 47h, 0B1h, 0C4h, 05h, 07h, 0CBh
		db	0CAh, 0CAh, 0CCh, 0CBh, 0C7h, 81h, 0C8h, 0B1h, 0C4h, 06h, 07h, 0CCh
		db	6Bh, 0C7h, 81h, 0C8h, 0B0h, 0C4h, 0C7h, 0C9h, 0CCh, 0CAh, 0CCh, 49h
		db	0CCh, 0C9h, 49h, 6Bh, 0C8h, 81h, 0C8h, 0ADh, 0C5h, 46h, 0C9h, 46h
		db	4Bh, 0C7h, 56h, 0C9h, 0CCh, 49h, 4Bh, 0C7h, 0C8h, 0ACh, 0C5h, 76h
		db	0CAh, 0CCh, 0CBh, 4Bh, 0C7h, 0CAh, 46h, 0C9h, 0C7h, 0AFh, 0C4h, 46h
		db	0CAh, 4Bh, 0CBh, 0CAh, 0CCh, 0C7h, 0CBh, 46h, 0CCh, 47h, 82h, 0C3h
		db	0C7h, 81h, 0C7h, 0AAh, 0C4h, 0C7h, 0CBh, 0C7h, 0CCh, 66h, 0CCh, 0CAh
		db	0CCh, 49h, 81h, 0C8h, 82h, 0C5h, 49h, 0C7h, 81h, 0C8h, 0A8h, 0C4h
		db	0C7h, 0C9h, 66h, 0CCh, 0C9h, 66h, 47h, 83h, 0C5h, 0C7h, 4Bh, 81h
		db	0C8h, 0A8h, 0C4h, 46h, 4Bh, 0C7h, 0CCh, 0C7h, 0CCh, 0C7h, 0C9h, 0CBh
		db	0C7h, 81h, 0C8h, 83h, 0C4h, 0CCh, 0C9h, 81h, 46h, 0C8h, 0A7h, 0C4h
		db	46h, 0CAh, 0CCh, 0CAh, 0CBh, 0C7h, 0CBh, 0C7h, 0CCh, 0CAh, 0C7h, 0C8h
		db	84h, 0C5h, 0CCh, 0C9h, 5Bh, 0A8h, 0C5h, 66h, 0CCh, 0CBh, 0CCh, 0C7h
		db	0CBh, 0CAh, 0CBh, 81h, 0C8h, 84h, 0C5h, 0CAh, 4Bh, 0CAh, 0C7h, 0CCh
		db	56h, 0A4h, 0C5h, 46h, 0C9h, 0C7h, 0CAh, 48h, 0CBh, 0CCh, 0C7h, 0CBh
		db	0C8h, 85h, 0C5h, 0C9h, 4Bh, 0CBh, 0CCh, 46h, 0A6h, 0C4h, 76h, 5Bh
		db	0CAh, 4Bh, 0C8h, 85h, 0C4h, 0CAh, 81h, 4Bh, 0CBh, 81h, 0CCh, 0A6h
		db	0C4h, 0CAh, 0CCh, 56h, 4Bh, 0CBh, 0C7h, 0C9h, 56h, 0C8h, 83h, 0C5h
		db	0CCh, 0C9h, 0CAh, 6Bh, 0A6h, 0C4h, 0C7h, 0CAh, 4Bh, 0CAh, 0C9h, 0CCh
		db	0C7h, 0CAh, 0CBh, 0CCh, 0C9h, 0C8h, 84h, 0C5h, 0CAh, 4Bh, 0CBh, 81h
		db	0CCh, 0A7h, 0C4h, 46h, 0CCh, 0C7h, 0CCh, 0CAh, 0CCh, 0C9h, 0CCh, 0C7h
		db	0C8h, 86h, 0C4h, 0CAh, 4Bh, 0C7h, 4Bh, 0CBh, 0A6h, 0C4h, 0C7h, 0C9h
		db	46h, 4Ah, 0CCh, 0CAh, 0CCh, 0C7h, 0C8h, 86h, 0C5h, 0CCh, 81h, 0CCh
		db	81h, 0C7h, 0CCh, 0CBh, 0A6h, 0C5h, 76h, 0C9h, 0CCh, 0CBh, 0CAh, 0C8h
		db	87h, 0C5h, 59h, 0CCh, 0CBh, 0C7h, 0CBh, 0A6h, 0C4h, 66h, 5Bh, 0CAh
		db	0CCh, 0C8h, 81h, 0C8h, 85h, 0C5h, 0CAh, 0C9h, 0CCh, 56h, 4Bh, 0CBh
		db	0C7h, 0A3h, 0C4h, 46h, 49h, 0C7h, 0CCh, 0C7h, 0C9h, 0C7h, 0C8h, 87h
		db	0C5h, 0CCh, 0CAh, 0CCh, 0C9h, 0CCh, 56h, 0CCh, 46h, 0A2h, 0C4h, 56h
		db	0CCh, 0C7h, 0CCh, 46h, 0CAh, 0C8h, 81h, 0C8h, 85h, 0C5h, 0CAh, 0CCh
		db	0CBh, 4Bh, 0CBh, 81h, 0C7h, 81h, 0C8h, 0A3h, 0C4h, 66h, 0CCh, 4Ah
		db	0C7h, 0C7h, 47h, 86h, 0C5h, 0CBh, 0CAh, 0CCh, 82h, 0CCh, 81h, 47h
		db	0A4h, 0C4h, 0CAh, 4Bh, 46h, 0CAh, 0C9h, 0CCh, 0CAh, 4Bh, 0C7h, 85h
		db	0C4h, 0CAh, 0C9h, 76h, 0CBh, 81h, 0C8h, 0A3h, 0C4h, 0C7h, 4Bh, 56h
		db	0CCh, 0CBh, 46h, 0C9h, 0C8h, 85h, 0C5h, 49h, 5Bh, 0C7h, 0CBh, 0C7h
		db	81h, 47h, 89h, 0E5h, 98h, 0C4h, 0C7h, 0C9h, 0C7h, 4Bh, 0C9h, 0CAh
		db	0CCh, 0C7h, 81h, 0C8h, 86h, 0C5h, 4Bh, 56h, 0CBh, 0C8h, 81h, 0C8h
		db	8Ah, 0E5h, 99h, 0C4h, 56h, 0CBh, 0C7h, 0CBh, 0CCh, 0C7h, 0CBh, 0C7h
		db	47h, 85h, 0C4h, 0CCh, 49h, 0C7h, 0CCh, 81h, 47h, 8Ch, 0E5h, 98h
		db	0C5h, 56h, 0C9h, 0C7h, 0CAh, 4Bh, 0CCh, 0CAh, 0C8h, 86h, 0C5h, 0CCh
		db	0CAh, 0C7h, 0CCh, 81h, 57h, 0A5h, 0C5h, 56h, 0CAh, 0C7h, 0CCh, 0C9h
		db	0CAh, 46h, 0C8h, 81h, 0C8h, 84h, 0C5h, 0CAh, 4Bh, 46h, 4Bh, 47h
		db	0A4h, 0C4h, 76h, 4Bh, 0C7h, 46h, 0CAh, 47h, 84h, 0C5h, 0C9h, 0CBh
		db	0CAh, 46h, 0CCh, 0C7h, 0CBh, 67h, 89h, 0E5h, 97h, 0C4h, 56h, 0CAh
		db	56h, 0C9h, 0CCh, 0C9h, 4Bh, 0C8h, 84h, 0C5h, 49h, 0CCh, 0CAh, 66h
		db	81h, 0C8h, 83h, 0E5h, 88h, 0E5h, 96h, 0C4h, 0C9h, 46h, 0CAh, 0CBh
		db	0C9h, 0CCh, 0CAh, 46h, 0CCh, 0C8h, 0C7h, 0C8h, 83h, 0C4h, 0CCh, 0C9h
		db	0CCh, 0CBh, 0CCh, 82h, 0CBh, 0E5h, 83h, 0E5h, 89h, 0E9h, 96h, 0C4h
		db	76h, 0CBh, 0CAh, 0CCh, 46h, 0CBh, 81h, 0C8h, 84h, 0C5h, 0CBh, 0CAh
		db	46h, 0CCh, 46h, 0C8h, 81h, 0E5h, 82h, 0E9h, 0E5h, 8Ah, 0E5h, 94h
		db	0C4h, 0C7h, 0CAh, 4Bh, 0C7h, 0CBh, 0CAh, 0C9h, 0CAh, 46h, 0C8h, 85h
		db	0C4h, 46h, 0CAh, 0CBh, 0C8h, 0CCh, 0C7h, 0C8h, 0E5h, 47h, 81h, 0E5h
		db	86h, 0E5h, 99h, 0C4h, 0C7h, 4Bh, 46h, 0CCh, 46h, 4Bh, 81h, 47h
		db	84h, 0C5h, 0C9h, 4Bh, 0C7h, 81h, 0CCh, 0C8h, 0E5h, 0C8h, 0E5h, 81h
		db	0E5h, 0E9h, 81h, 0E9h, 0E5h, 84h, 0E5h, 98h, 0C5h, 0C7h, 0CCh, 66h
		db	0CCh, 0CAh, 46h, 0CBh, 0C7h, 0C8h, 84h, 0C5h, 0C7h, 0CCh, 0CAh, 0CCh
		db	0C7h, 47h, 0E9h, 0E5h, 0E9h, 0E5h, 0E9h, 0E5h, 81h, 0E5h, 0E9h, 0E5h
		db	83h, 0E9h, 0E5h, 97h, 0C4h, 76h, 0C9h, 46h, 0C9h, 0CAh, 0CCh, 0C9h
		db	81h, 0C8h, 83h, 0C5h, 49h, 47h, 0CBh, 0C8h, 81h, 0E5h, 0E9h, 0E5h
		db	81h, 0E5h, 0E9h, 0E5h, 85h, 0E9h, 0E5h, 81h, 0E5h, 96h, 0C5h, 0C7h
		db	0CAh, 76h, 0CCh, 56h, 0CAh, 81h, 0C8h, 83h, 0C6h, 0C7h, 57h, 82h
		db	0E5h, 81h, 0E5h, 0E9h, 82h, 0E5h, 86h, 0E5h, 99h, 0C4h, 46h, 0CCh
		db	0CAh, 0C7h, 49h, 0C9h, 0CAh, 0CCh, 0CBh, 0C7h, 0C8h, 0B2h, 0C4h, 0C7h
		db	0C9h, 0CCh, 0CAh, 0CBh, 0C7h, 0CCh, 0CBh, 0C7h, 0CAh, 4Bh, 40h, 0C2h
		db	40h, 51h, 0C1h, 41h, 40h, 51h, 60h, 41h, 0C1h, 0C2h, 0C1h, 71h
		db	50h, 51h, 40h, 0C2h, 0C1h, 0C2h, 0C1h, 51h, 0C1h, 85h, 0C4h, 56h
		db	0CCh, 0C7h, 0CAh, 0C7h, 0C9h, 0CAh, 0CCh, 0CAh, 0CBh, 0CAh, 47h, 0B0h
		db	0C4h, 07h, 07h, 56h, 0CCh, 0CBh, 46h, 0CAh, 83h, 0E5h, 81h, 0E5h
		db	81h, 0E5h, 89h, 0E5h, 85h, 0E5h, 97h, 0C4h, 76h, 0CCh, 49h, 0C7h
		db	0C9h, 0CAh, 0C7h, 0CBh, 0C7h, 0CCh, 0CBh, 0C7h, 0C8h, 82h, 0E5h, 0E9h
		db	0E5h, 81h, 0E5h, 81h, 0E5h, 87h, 0E5h, 0E9h, 0E5h, 81h, 0E5h, 98h
		db	0C5h, 05h, 07h, 4Bh, 0CAh, 5Bh, 0C9h, 81h, 0C8h, 0CCh, 0C8h, 82h
		db	0E5h, 0E9h, 0E5h, 0E9h, 0E5h, 0E9h, 0E5h, 0E9h, 0E5h, 0E9h, 86h, 0E5h
		db	9Bh, 0C4h, 76h, 0C9h, 0CCh, 0CBh, 4Bh, 0CBh, 81h, 57h, 82h, 0C8h
		db	0E5h, 81h, 0E5h, 0E9h, 0E5h, 81h, 0E5h, 0E9h, 0E5h, 0E9h, 92h, 0E5h
		db	90h, 0C4h, 0C7h, 0CAh, 4Bh, 0CAh, 0CBh, 0CAh, 0CCh, 4Bh, 47h, 83h
		db	47h, 0E5h, 0E9h, 0E5h, 81h, 0E5h, 0E9h, 0E5h, 0E9h, 0E5h, 0E9h, 0E5h
		db	81h, 0E5h, 0E9h, 0E5h, 83h, 0E5h, 9Bh, 0C5h, 0C9h, 56h, 0CCh, 0CBh
		db	0C7h, 0CCh, 0CAh, 0CBh, 57h, 83h, 0E5h, 0C8h, 0E5h, 0E9h, 0E5h, 0E9h
		db	0E5h, 81h, 0E5h, 81h, 0E5h, 0E9h, 0E5h, 82h, 0E9h, 0E5h, 82h, 0E9h
		db	0E5h, 9Ah, 0C4h, 66h, 0CCh, 0C7h, 0CAh, 0C9h, 5Bh, 0C9h, 57h, 0E5h
		db	0E9h, 81h, 0E9h, 0C8h, 81h, 0E5h, 81h, 0E5h, 0E9h, 0E5h, 85h, 0E5h
		db	0E9h, 82h, 0E5h, 81h, 0E5h, 99h, 0C4h, 0C7h, 0CAh, 0CBh, 0C7h, 0CAh
		db	4Bh, 0CAh, 0CAh, 0CCh, 0CBh, 5Bh, 0C7h, 0C8h, 0E5h, 81h, 0E5h, 0E9h
		db	0E5h, 81h, 0E5h, 0E9h, 0E5h, 81h, 0E5h, 81h, 0E5h, 83h, 0E5h, 0E9h
		db	0E5h, 85h, 0E5h, 96h, 0C4h, 46h, 0C9h, 0CCh, 0C7h, 0CAh, 0CBh, 0CAh
		db	0CCh, 49h, 0CCh, 0C9h, 0CAh, 81h, 0E5h, 0E9h, 0E5h, 0E9h, 0E5h, 0E9h
		db	0E5h, 81h, 0E5h, 0E9h, 0E5h, 0E9h, 0E5h, 85h, 0E5h, 85h, 0E5h, 97h
		db	0C4h, 56h, 4Bh, 0C9h, 0C7h, 0CCh, 4Bh, 0CAh, 47h, 81h, 0C8h, 81h
		db	0E5h, 0E9h, 0E5h, 81h, 0E5h, 0E9h, 0E5h, 81h, 0E5h, 81h, 0E5h, 0A4h
		db	0C4h, 66h, 4Bh, 0C7h, 0C9h, 0CBh, 0CCh, 82h, 0C8h, 88h, 0E5h, 0E9h
		db	0E5h, 0E9h, 0E5h, 0E9h, 0E5h, 81h, 0E5h, 0A1h, 0C4h, 05h, 07h, 0CCh
		db	0CAh, 0CAh, 0C7h, 81h, 47h, 83h, 0E5h, 81h, 0E5h, 81h, 0E5h, 81h
		db	0E5h, 81h, 0E5h, 81h, 0E5h, 81h, 0E5h, 87h, 0E5h, 9Ah, 0C5h, 66h
		db	0CCh, 0C9h, 4Bh, 4Bh, 49h, 81h, 0C8h, 81h, 0E5h, 0E9h, 0E5h, 0C8h
		db	0E5h, 0E9h, 0E5h, 81h, 0E5h, 0E9h, 0E5h, 0E9h, 0E5h, 0A3h, 0C5h, 76h
		db	4Bh, 0CBh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 10h, 00h, 33h, 42h
		db	1Ch, 32h, 00h, 0Eh, 01h, 0FFh, 0FFh, 0FFh, 1Eh, 00h, 05h, 00h
		db	1Dh, 08h, 00h, 0Ah, 00h, 45h, 00h, 20h, 0FFh, 0FFh, 45h, 00h
		db	10h, 82h, 0C5h, 0FFh, 0FFh, 0FFh, 0FFh, 45h, 00h, 20h, 4Bh, 0C5h
		db	80h, 1Dh, 0FFh, 0FFh, 0FFh, 0FFh, 17h, 0AFh, 04h, 0Fh

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'Cavern of Final'

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	17h, 00h, 07h, 0Eh, 0Eh, 3Ch, 00h, 35h, 0FFh, 76h, 00h, 00h
		db	20h, 00h, 00h, 00h, 45h, 00h, 10h, 00h, 00h, 0FFh, 0FFh

map_mp84	endp

seg_a		ends

		end	start
