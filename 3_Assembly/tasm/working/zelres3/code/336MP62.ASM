
PAGE  59,132

;==========================================================================
;
;  336MP62.BIN - Level 6 Floor 2
;
;  Zeliard dungeon map data file (MP62). Loaded by stick.bin as an
;  MDT (map data table). This is labyrinth/cavern map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x06d6 = 1750)
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

map_mp62	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	06D6h		; total_size field
		dw	0000h		; reserved / zero
		dw	0C50Fh		; hdr ptr[0] (runtime addr)
		dw	0049h		; hdr ptr[1] (runtime addr)
		dw	0C48Ah		; hdr ptr[2] (runtime addr)
		dw	0C48Ch		; hdr ptr[3] (runtime addr)
		dw	0C48Eh		; hdr ptr[4] (runtime addr)
		dw	0C490h		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	0AAh, 0C4h, 0FAh, 0C4h, 14h, 0C5h, 06h, 0FFh, 0FFh, 00h, 0Ah, 00h
		db	00h, 8Ah, 0C4h, 0E0h, 2Fh, 04h, 0E0h, 84h, 0E0h, 63h, 0E0h, 84h
		db	0E0h, 2Fh, 04h, 0E0h, 84h, 0E0h, 63h, 0E0h, 84h, 0E0h, 2Fh, 04h
		db	0E0h, 84h, 0E0h, 63h, 0E0h, 84h, 0E0h, 2Fh, 04h, 0E0h, 84h, 0E0h
		db	63h, 0E0h, 84h, 0E0h, 2Fh, 04h, 0E0h, 84h, 0E0h, 63h, 0E0h, 84h
		db	0E0h, 2Fh, 04h, 0E0h, 84h, 0E0h, 63h, 0E0h, 84h, 0E0h, 2Fh, 04h
		db	0E0h, 84h, 0E0h, 63h, 0E0h, 84h, 0E0h, 22h, 04h, 0Dh, 20h, 84h
		db	0E0h, 63h, 0E0h, 84h, 0E0h, 12h, 04h, 0A2h, 0E0h, 63h, 0E0h, 84h
		db	03h, 20h, 0Fh, 04h, 0A2h, 0E0h, 63h, 0E0h, 84h, 83h, 0E0h, 0Fh
		db	04h, 0A2h, 0E0h, 63h, 0E0h, 84h, 83h, 0E0h, 0Fh, 04h, 0A2h, 0E0h
		db	63h, 0E0h, 84h, 83h, 0E0h, 0Fh, 04h, 84h, 0Bh, 04h, 0Ch, 20h
		db	85h, 0E0h, 63h, 0E0h, 84h, 83h, 0E0h, 0Fh, 04h, 84h, 0C4h, 01h
		db	20h, 14h, 04h, 0E0h, 85h, 0E0h, 63h, 03h, 20h, 81h, 83h, 0E0h
		db	0Fh, 04h, 84h, 03h, 20h, 13h, 04h, 0E0h, 85h, 0E0h, 06h, 04h
		db	0E0h, 81h, 83h, 0E0h, 0Fh, 04h, 84h, 03h, 20h, 13h, 04h, 0E0h
		db	85h, 0E0h, 06h, 04h, 0E0h, 81h, 83h, 0E0h, 0Fh, 04h, 84h, 03h
		db	20h, 13h, 04h, 0E0h, 85h, 08h, 20h, 81h, 83h, 0E0h, 0Fh, 04h
		db	84h, 03h, 20h, 13h, 04h, 0E0h, 8Fh, 83h, 0E0h, 0Fh, 04h, 88h
		db	0C3h, 12h, 04h, 0E0h, 8Fh, 83h, 0E0h, 0Fh, 04h, 88h, 0C3h, 12h
		db	04h, 0E0h, 8Fh, 83h, 0E0h, 0Fh, 04h, 88h, 0C3h, 12h, 04h, 0E0h
		db	8Fh, 83h, 0E0h, 0Fh, 04h, 88h, 0C3h, 12h, 04h, 0E0h, 8Fh, 83h
		db	0E0h, 0Fh, 04h, 88h, 0C3h, 12h, 04h, 0E0h, 8Fh, 83h, 0E0h, 0Fh
		db	04h, 88h, 0C3h, 12h, 04h, 0E0h, 8Fh, 83h, 0E0h, 0Fh, 04h, 88h
		db	0C3h, 12h, 04h, 0E0h, 85h, 08h, 20h, 81h, 83h, 0E0h, 0Fh, 04h
		db	88h, 0C3h, 12h, 04h, 0E0h, 85h, 0E0h, 06h, 04h, 0E0h, 81h, 83h
		db	0E0h, 0Fh, 04h, 88h, 0C3h, 06h, 04h, 0Ch, 20h, 85h, 0E0h, 06h
		db	04h, 0E0h, 81h, 83h, 0E0h, 0Fh, 04h, 88h, 0C3h, 06h, 04h, 0E0h
		db	91h, 0E0h, 63h, 03h, 20h, 81h, 83h, 0E0h, 0Fh, 04h, 88h, 0C3h
		db	06h, 04h, 0E0h, 0C2h, 0C1h, 51h, 40h, 0C2h, 0C1h, 0C2h, 0C1h, 41h
		db	0C1h, 41h, 81h, 0E0h, 63h, 0E0h, 84h, 83h, 0E0h, 0Fh, 04h, 88h
		db	0C3h, 06h, 04h, 0E0h, 91h, 0E0h, 63h, 0E0h, 84h, 83h, 0E0h, 0Fh
		db	04h, 88h, 0C3h, 06h, 04h, 0E0h, 84h, 08h, 20h, 84h, 0E0h, 63h
		db	0E0h, 84h, 03h, 20h, 0Fh, 04h, 88h, 0C3h, 06h, 04h, 0E0h, 84h
		db	0E0h, 06h, 04h, 0E0h, 84h, 0E0h, 63h, 0E0h, 84h, 0E0h, 12h, 04h
		db	88h, 0C3h, 06h, 04h, 0E0h, 84h, 0E0h, 06h, 04h, 0E0h, 84h, 0E0h
		db	63h, 0E0h, 84h, 0E0h, 12h, 04h, 88h, 0C3h, 06h, 04h, 0E0h, 84h
		db	0E0h, 06h, 04h, 0E0h, 84h, 0E0h, 63h, 0E0h, 84h, 0E0h, 12h, 04h
		db	88h, 0C3h, 06h, 04h, 0E0h, 84h, 0E0h, 06h, 04h, 0E0h, 84h, 0E0h
		db	63h, 0E0h, 84h, 0E0h, 12h, 04h, 88h, 0C3h, 06h, 04h, 0E0h, 84h
		db	0E0h, 06h, 04h, 0E0h, 84h, 0E0h, 63h, 0E0h, 84h, 0E0h, 0Bh, 04h
		db	8Fh, 0C3h, 06h, 04h, 0E0h, 84h, 0E0h, 06h, 04h, 0E0h, 84h, 0E0h
		db	63h, 0E0h, 84h, 0E0h, 0Bh, 04h, 0C2h, 40h, 51h, 0C1h, 41h, 0C1h
		db	0C2h, 0C1h, 41h, 81h, 0C3h, 06h, 04h, 0E0h, 84h, 0E0h, 53h, 04h
		db	20h, 84h, 0E0h, 63h, 0E0h, 84h, 0E0h, 0Bh, 04h, 8Fh, 0C3h, 06h
		db	04h, 0E0h, 84h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h, 0E0h
		db	0Bh, 04h, 84h, 0C3h, 01h, 20h, 43h, 01h, 20h, 43h, 01h, 20h
		db	07h, 04h, 0E0h, 84h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h
		db	0E0h, 0Bh, 04h, 84h, 0C3h, 01h, 20h, 43h, 01h, 20h, 43h, 01h
		db	20h, 07h, 04h, 0E0h, 84h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h
		db	84h, 0E0h, 0Bh, 04h, 84h, 0C3h, 43h, 01h, 20h, 43h, 01h, 20h
		db	09h, 04h, 0E0h, 84h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h
		db	0E0h, 0Bh, 04h, 84h, 0C3h, 43h, 01h, 20h, 43h, 01h, 20h, 09h
		db	04h, 0E0h, 84h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h, 0E0h
		db	0Bh, 04h, 84h, 0C3h, 01h, 20h, 43h, 01h, 20h, 43h, 01h, 20h
		db	07h, 04h, 0E0h, 84h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h
		db	0E0h, 0Bh, 04h, 84h, 0C3h, 01h, 20h, 43h, 01h, 20h, 43h, 01h
		db	20h, 07h, 04h, 0E0h, 84h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h
		db	84h, 0E0h, 06h, 04h, 89h, 0C3h, 43h, 01h, 20h, 43h, 01h, 20h
		db	09h, 04h, 0E0h, 84h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h
		db	0E0h, 06h, 04h, 89h, 0C3h, 43h, 01h, 20h, 43h, 01h, 20h, 09h
		db	04h, 0E0h, 84h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h, 0E0h
		db	06h, 04h, 89h, 0C3h, 63h, 01h, 20h, 08h, 04h, 03h, 20h, 84h
		db	0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h, 0E0h, 06h, 04h, 89h
		db	0C3h, 63h, 01h, 20h, 08h, 04h, 0E0h, 87h, 0E0h, 53h, 0E0h, 88h
		db	0E0h, 63h, 0E0h, 84h, 0E0h, 06h, 04h, 89h, 0C3h, 0Eh, 04h, 0E0h
		db	87h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h, 0E0h, 06h, 04h
		db	89h, 0C3h, 0Eh, 04h, 0E0h, 87h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h
		db	0E0h, 84h, 0E0h, 06h, 04h, 89h, 0C3h, 63h, 01h, 20h, 08h, 04h
		db	0E0h, 87h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h, 0E0h, 06h
		db	04h, 89h, 0C3h, 63h, 01h, 20h, 08h, 04h, 0E0h, 87h, 0E0h, 53h
		db	0E0h, 88h, 0E0h, 63h, 0E0h, 84h, 0E0h, 06h, 04h, 89h, 0C3h, 0Eh
		db	04h, 0E0h, 87h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h, 0E0h
		db	06h, 04h, 89h, 0C3h, 0Eh, 04h, 0E0h, 87h, 0E0h, 53h, 0E0h, 88h
		db	0E0h, 63h, 0E0h, 84h, 0E0h, 06h, 04h, 89h, 0C3h, 0Eh, 04h, 0E0h
		db	87h, 0E0h, 53h, 0E0h, 88h, 0E0h, 63h, 0E0h, 84h, 0E0h, 06h, 04h
		db	89h, 0C3h, 0Eh, 04h, 0E0h, 87h, 0E0h, 53h, 04h, 20h, 84h, 0E0h
		db	63h, 0E0h, 84h, 0E0h, 06h, 04h, 89h, 0C3h, 0Eh, 04h, 0E0h, 87h
		db	0E0h, 06h, 04h, 0E0h, 84h, 0E0h, 63h, 0E0h, 84h, 0E0h, 06h, 04h
		db	89h, 0C3h, 0Eh, 04h, 0E0h, 87h, 0E0h, 06h, 04h, 0E0h, 84h, 0E0h
		db	63h, 0E0h, 84h, 0E0h, 06h, 04h, 89h, 0C3h, 0Eh, 04h, 0E0h, 87h
		db	0E0h, 06h, 04h, 0E0h, 84h, 0E0h, 63h, 0E0h, 84h, 0E0h, 06h, 04h
		db	89h, 0C3h, 0Eh, 04h, 0E0h, 87h, 0E0h, 06h, 04h, 0E0h, 84h, 0E0h
		db	63h, 0E0h, 84h, 0E0h, 06h, 04h, 89h, 0C3h, 0Eh, 04h, 0E0h, 87h
		db	0E0h, 06h, 04h, 0E0h, 84h, 05h, 20h, 84h, 0E0h, 06h, 04h, 89h
		db	0C3h, 0Eh, 04h, 0E0h, 87h, 0E0h, 06h, 04h, 0E0h, 8Eh, 0E0h, 06h
		db	04h, 89h, 0C3h, 0Eh, 04h, 0E0h, 87h, 0E0h, 06h, 04h, 0E0h, 40h
		db	41h, 0C1h, 41h, 0C1h, 41h, 0C1h, 0C2h, 0C1h, 81h, 0E0h, 06h, 04h
		db	89h, 0C3h, 0Eh, 04h, 0E0h, 87h, 0E0h, 06h, 04h, 0E0h, 8Eh, 0E0h
		db	06h, 04h, 89h, 0C3h, 0Eh, 04h, 03h, 20h, 84h, 0E0h, 06h, 04h
		db	0Ah, 20h, 84h, 0E0h, 06h, 04h, 89h, 0C3h, 11h, 04h, 0E0h, 84h
		db	0E0h, 10h, 04h, 0E0h, 84h, 0E0h, 06h, 04h, 89h, 0C3h, 11h, 04h
		db	0E0h, 84h, 0E0h, 10h, 04h, 0E0h, 84h, 0E0h, 06h, 04h, 89h, 0C3h
		db	11h, 04h, 0E0h, 84h, 0Dh, 20h, 63h, 0E0h, 84h, 0E0h, 22h, 04h
		db	0E0h, 91h, 0E0h, 63h, 0E0h, 84h, 0E0h, 22h, 04h, 0E0h, 91h, 0E0h
		db	63h, 0E0h, 84h, 0E0h, 22h, 04h, 0E0h, 91h, 0E0h, 63h, 0E0h, 84h
		db	0E0h, 22h, 04h, 0Dh, 20h, 84h, 0E0h, 63h, 0E0h, 84h, 0FFh, 0FFh
		db	0FFh, 0FFh, 0FFh, 0FFh, 28h, 00h, 25h, 80h, 17h, 39h, 00h, 39h
		db	00h, 0FFh, 0FFh, 0FFh, 3Eh, 00h, 0Dh, 83h, 0Eh, 1Fh, 00h, 05h
		db	00h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 2Ch, 00h, 08h, 74h, 0C6h, 00h
		db	0FFh, 7Fh, 0C6h, 0FFh, 0FFh, 0FFh, 0FFh, 2Ch, 00h, 04h, 84h, 0C6h
		db	00h, 0FFh, 8Fh, 0C6h, 0FFh, 0FFh, 0FFh, 0FFh, 2Ch, 00h, 02h, 94h
		db	0C6h, 00h, 0FFh, 9Fh, 0C6h, 0FFh, 0FFh, 0FFh, 0FFh, 2Ch, 00h, 01h
		db	0A4h, 0C6h, 00h, 0FFh, 0AFh, 0C6h, 0FFh, 0FFh, 0FFh, 0FFh, 2Dh, 00h
		db	80h, 0B4h, 0C6h, 00h, 0FFh, 0BFh, 0C6h, 0FFh, 0FFh, 0FFh, 0FFh, 2Dh
		db	00h, 40h, 0C4h, 0C6h, 00h, 0FFh, 0CFh, 0C6h, 0FFh, 0FFh, 0FFh, 0FFh
		db	0FFh, 0FFh, 16h, 0AFh, 00h, 11h

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'Cavern of Arrugia'

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	13h, 00h, 05h, 0Ah, 0Ah, 08h, 00h, 14h, 0FFh, 0D0h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h, 00h, 08h, 00h, 16h
		db	0FFh, 0D0h, 00h, 00h, 00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h
		db	00h, 08h, 00h, 18h, 0FFh, 0F1h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh, 0FFh, 00h, 00h, 00h, 08h, 00h, 1Ah, 0FFh, 0F1h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h, 00h, 08h, 00h, 1Ch
		db	0FFh, 0F1h, 00h, 00h, 00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h
		db	00h, 08h, 00h, 1Eh, 0FFh, 0F1h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh, 0FFh, 00h, 00h, 00h, 08h, 00h, 20h, 0FFh, 0F1h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h, 00h, 08h, 00h, 22h
		db	0FFh, 0F1h, 00h, 00h, 00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h
		db	00h, 0Ah, 00h, 14h, 0FFh, 0D0h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh, 0FFh, 00h, 00h, 00h, 0Ah, 00h, 16h, 0FFh, 0D0h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h, 00h, 0Ah, 00h, 18h
		db	0FFh, 0F1h, 00h, 00h, 00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h
		db	00h, 0Ah, 00h, 1Ah, 0FFh, 0F1h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh, 0FFh, 00h, 00h, 00h, 0Ah, 00h, 1Ch, 0FFh, 0F1h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h, 00h, 0Ah, 00h, 1Eh
		db	0FFh, 0F1h, 00h, 00h, 00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h
		db	00h, 0Ah, 00h, 20h, 0FFh, 0F1h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh, 0FFh, 00h, 00h, 00h, 0Ah, 00h, 22h, 0FFh, 0F1h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h, 00h, 0Ch, 00h, 14h
		db	0FFh, 0D0h, 00h, 00h, 00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h
		db	00h, 0Ch, 00h, 16h, 0FFh, 0D0h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh, 0FFh, 00h, 00h, 00h, 0Eh, 00h, 14h, 0FFh, 0D0h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h, 00h, 0Eh, 00h, 16h
		db	0FFh, 0D0h, 00h, 00h, 00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h
		db	00h, 10h, 00h, 14h, 0FFh, 0D0h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh, 0FFh, 00h, 00h, 00h, 10h, 00h, 16h, 0FFh, 0D0h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0FFh, 0FFh, 00h, 00h, 00h, 12h, 00h, 1Ah
		db	0FFh, 73h, 00h, 07h, 20h, 00h, 00h, 00h, 2Ch, 00h, 08h, 00h
		db	00h, 1Bh, 00h, 1Ah, 0FFh, 73h, 00h, 00h, 20h, 00h, 1Eh, 00h
		db	2Ch, 00h, 04h, 00h, 00h, 2Ch, 00h, 34h, 0FFh, 73h, 00h, 05h
		db	20h, 00h, 00h, 00h, 2Ch, 00h, 02h, 00h, 00h, 2Eh, 00h, 34h
		db	0FFh, 73h, 00h, 05h, 20h, 00h, 00h, 00h, 2Ch, 00h, 01h, 00h
		db	00h, 30h, 00h, 34h, 0FFh, 73h, 00h, 05h, 20h, 00h, 00h, 00h
		db	2Dh, 00h, 80h, 00h, 00h, 37h, 00h, 27h, 0FFh, 73h, 00h, 00h
		db	20h, 00h, 19h, 00h, 2Dh, 00h, 40h, 00h, 00h, 0FFh, 0FFh

map_mp62	endp

seg_a		ends

		end	start
