
PAGE  59,132

;==========================================================================
;
;  348MP8D.BIN - Level 8 Floor D (town/checkpoint)
;
;  Zeliard dungeon map data file (MP8D). Loaded by stick.bin as an
;  MDT (map data table). This is town map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x0291 = 657)
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

map_mp8d	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	0291h		; total_size field
		dw	0000h		; reserved / zero
		dw	0C267h		; hdr ptr[0] (runtime addr)
		dw	0046h		; hdr ptr[1] (runtime addr)
		dw	0C229h		; hdr ptr[2] (runtime addr)
		dw	0C22Bh		; hdr ptr[3] (runtime addr)
		dw	0C22Dh		; hdr ptr[4] (runtime addr)
		dw	0C247h		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	49h, 0C2h, 54h, 0C2h, 8Fh, 0C2h, 08h, 0FFh, 0FFh, 0FFh, 0Ch, 00h
		db	00h, 29h, 0C2h, 83h, 0C5h, 05h, 07h, 0C8h, 0CBh, 46h, 47h, 0C7h
		db	0C8h, 0C9h, 56h, 0AAh, 83h, 0C4h, 05h, 07h, 47h, 46h, 47h, 46h
		db	0C8h, 56h, 0AAh, 83h, 0C4h, 46h, 0CAh, 46h, 0C9h, 47h, 66h, 0C8h
		db	0C7h, 0C8h, 56h, 0AAh, 83h, 0C4h, 05h, 07h, 57h, 0C7h, 0C9h, 0C7h
		db	0C8h, 46h, 0CAh, 46h, 0AAh, 83h, 0C4h, 06h, 07h, 67h, 0C7h, 0C8h
		db	0C7h, 0C8h, 56h, 0AAh, 83h, 0C6h, 46h, 0CAh, 66h, 77h, 46h, 0C8h
		db	56h, 0AAh, 84h, 0C4h, 66h, 0CAh, 46h, 67h, 46h, 0C8h, 56h, 0AAh
		db	84h, 0C5h, 0C7h, 0C9h, 0C7h, 0C8h, 0CBh, 0C8h, 0CBh, 0CAh, 0C7h, 0C8h
		db	56h, 0C8h, 56h, 0AAh, 84h, 0C4h, 76h, 0CBh, 0C7h, 0CCh, 56h, 0C9h
		db	0C7h, 0C8h, 56h, 0AAh, 84h, 0C4h, 66h, 0CAh, 0C8h, 0CBh, 0C7h, 0CAh
		db	07h, 07h, 0AAh, 84h, 0C4h, 0C8h, 0C7h, 0CAh, 0CCh, 06h, 07h, 0C8h
		db	76h, 0AAh, 84h, 0C6h, 66h, 0CBh, 0C7h, 0CBh, 0C8h, 0C7h, 0C8h, 76h
		db	0C9h, 0C7h, 0AAh, 86h, 0C4h, 56h, 0C9h, 0C7h, 0CBh, 46h, 4Ah, 76h
		db	0AAh, 86h, 0C6h, 0C7h, 0C8h, 56h, 0C8h, 0C7h, 47h, 4Ah, 66h, 0AAh
		db	8Ah, 0C4h, 05h, 07h, 0CAh, 0CBh, 56h, 0AAh, 8Ah, 0C6h, 46h, 47h
		db	06h, 07h, 0AAh, 92h, 0C4h, 0C9h, 46h, 0AAh, 92h, 0C5h, 0C7h, 0C8h
		db	0C7h, 0AAh, 92h, 0C4h, 0C8h, 46h, 0AAh, 92h, 0C4h, 0CAh, 46h, 0AAh
		db	92h, 0C5h, 0CCh, 46h, 0AAh, 92h, 0C4h, 0C7h, 0CCh, 0C7h, 0AAh, 92h
		db	0C4h, 0C7h, 0C8h, 0C7h, 0AAh, 92h, 0C5h, 0C7h, 0CAh, 0C7h, 0AAh, 92h
		db	0C4h, 0C8h, 0C9h, 0C7h, 0AAh, 92h, 0C4h, 56h, 0AAh, 92h, 0C4h, 0CAh
		db	46h, 0AAh, 92h, 0C4h, 0C7h, 0CCh, 0C7h, 0AAh, 92h, 0C4h, 46h, 0CCh
		db	0AAh, 92h, 0C4h, 56h, 0AAh, 92h, 0C5h, 0C8h, 0C9h, 0C7h, 0AAh, 92h
		db	0C4h, 0C7h, 0C8h, 0C7h, 0AAh, 92h, 0C4h, 0CAh, 46h, 0AAh, 92h, 0C5h
		db	56h, 0AAh, 92h, 0C4h, 0C7h, 0CAh, 0C7h, 0AAh, 92h, 0C4h, 56h, 0AAh
		db	92h, 0C4h, 0C7h, 0CCh, 0C7h, 0AAh, 92h, 0C5h, 0C9h, 0C7h, 0CBh, 0AAh
		db	92h, 0C5h, 56h, 0AAh, 92h, 0C5h, 56h, 0AAh, 92h, 0C5h, 56h, 0AAh
		db	92h, 0C4h, 0C7h, 0C9h, 0C7h, 0AAh, 92h, 0C4h, 56h, 0AAh, 92h, 0C4h
		db	0CAh, 46h, 0AAh, 92h, 0C4h, 0C7h, 0C8h, 0C7h, 0AAh, 92h, 0C5h, 0C8h
		db	46h, 0AAh, 92h, 0C4h, 0C7h, 0C9h, 0C7h, 0AAh, 92h, 0C4h, 56h, 0AAh
		db	92h, 0C4h, 0CCh, 46h, 0AAh, 92h, 0C5h, 0C7h, 0CBh, 0C7h, 0AAh, 92h
		db	0C4h, 56h, 0AAh, 92h, 0C4h, 0C9h, 46h, 0AAh, 92h, 0C4h, 0CAh, 46h
		db	0AAh, 92h, 0C4h, 56h, 0AAh, 92h, 0C5h, 0C7h, 0CAh, 0C7h, 0AAh, 92h
		db	0C5h, 0CAh, 46h, 0AAh, 92h, 0C4h, 56h, 0AAh, 92h, 0C4h, 56h, 0AAh
		db	8Ah, 0C3h, 0CAh, 0C7h, 0CAh, 0C7h, 0C8h, 05h, 07h, 0AAh, 8Ah, 0C4h
		db	66h, 0C8h, 05h, 07h, 0AAh, 86h, 0C3h, 0CAh, 81h, 76h, 0CBh, 0C8h
		db	0CBh, 0C9h, 66h, 0AAh, 86h, 0C4h, 0C8h, 0C7h, 0C8h, 46h, 0C9h, 46h
		db	0CBh, 0C8h, 0CBh, 0C7h, 0CAh, 46h, 0AAh, 84h, 0C3h, 0C8h, 46h, 0C9h
		db	0CAh, 0C7h, 0CBh, 05h, 07h, 0CBh, 56h, 0AAh, 84h, 0C4h, 06h, 07h
		db	0CBh, 46h, 0CAh, 05h, 07h, 0AAh, 84h, 0C5h, 0C8h, 0C7h, 0C9h, 76h
		db	0CCh, 05h, 07h, 0CAh, 0C7h, 0AAh, 84h, 0C4h, 0CAh, 0Ah, 07h, 0CAh
		db	66h, 0AAh, 84h, 0C4h, 05h, 07h, 0CAh, 0C7h, 0CBh, 46h, 0C8h, 76h
		db	0AAh, 83h, 0C3h, 0C7h, 0C8h, 46h, 0C8h, 0CBh, 0CAh, 56h, 4Ah, 0C8h
		db	76h, 0AAh, 83h, 0C4h, 66h, 0C8h, 0C7h, 0CBh, 66h, 0C8h, 0CCh, 76h
		db	0AAh, 83h, 0C4h, 0C7h, 0C9h, 46h, 0CAh, 0C8h, 0CCh, 56h, 57h, 76h
		db	0AAh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 15h, 00h, 0Eh, 0C1h, 18h
		db	0DEh, 00h, 13h, 00h, 0FFh, 0FFh, 0FFh, 32h, 00h, 0Eh, 82h, 1Bh
		db	10h, 00h, 33h, 80h, 45h, 00h, 40h, 0FFh, 0FFh, 45h, 00h, 40h
		db	42h, 0C2h, 33h, 00h, 0FFh, 0FFh, 0FFh, 0FFh, 16h, 0AFh, 04h, 0Fh

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'Cavern of Absor'

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	99h, 00h, 07h, 0Fh, 0FFh, 0Fh, 0Eh, 0Eh, 10h, 0C0h, 7Dh, 0C2h
		db	0Ah, 0C0h, 3Bh, 0C2h, 7Fh, 0C2h, 00h, 0FFh, 0FFh, 0FFh, 24h, 00h
		db	10h, 0FFh, 79h, 00h, 00h, 20h, 00h, 00h, 00h, 0FFh, 0FFh, 0FFh
		db	00h, 00h, 0FFh, 0FFh, 0FFh, 0FFh

map_mp8d	endp

seg_a		ends

		end	start
