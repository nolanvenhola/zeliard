
PAGE  59,132

;==========================================================================
;
;  341MP73.BIN - Level 7 Floor 3
;
;  Zeliard dungeon map data file (MP73). Loaded by stick.bin as an
;  MDT (map data table). This is labyrinth/cavern map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x01ab = 427)
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

map_mp73	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	01ABh		; total_size field
		dw	0000h		; reserved / zero
		dw	0C191h		; hdr ptr[0] (runtime addr)
		dw	0049h		; hdr ptr[1] (runtime addr)
		dw	0C16Dh		; hdr ptr[2] (runtime addr)
		dw	0C16Fh		; hdr ptr[3] (runtime addr)
		dw	0C171h		; hdr ptr[4] (runtime addr)
		dw	0C17Fh		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	81h, 0C1h, 83h, 0C1h, 0A9h, 0C1h, 01h, 0FFh, 0FFh, 00h, 0Ch, 00h
		db	00h, 6Dh, 0C1h, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h
		db	11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h
		db	11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h
		db	11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h
		db	11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h
		db	11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h, 52h, 0Bh, 02h, 52h
		db	0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h
		db	52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch
		db	52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh
		db	83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h
		db	8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h
		db	0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h
		db	42h, 0C2h, 8Ch, 52h, 0ABh, 83h, 42h, 8Dh, 52h, 0ABh, 83h, 42h
		db	8Dh, 52h, 0ABh, 83h, 42h, 8Dh, 52h, 0ABh, 83h, 42h, 8Dh, 52h
		db	0ABh, 83h, 42h, 8Dh, 52h, 0ABh, 83h, 42h, 8Dh, 52h, 0ABh, 83h
		db	42h, 8Dh, 52h, 0ABh, 83h, 42h, 8Dh, 52h, 0ABh, 83h, 42h, 8Dh
		db	52h, 0ABh, 83h, 42h, 8Dh, 52h, 0ABh, 83h, 42h, 8Dh, 52h, 0ABh
		db	83h, 42h, 8Dh, 52h, 0ABh, 83h, 42h, 0C1h, 8Ch, 52h, 0ABh, 83h
		db	52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch
		db	52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh
		db	83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h
		db	8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h
		db	0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h, 52h, 8Ch, 52h, 0ABh, 83h
		db	52h, 0Bh, 01h, 52h, 0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h
		db	0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h
		db	0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h
		db	0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h
		db	0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h, 0ABh, 83h, 11h, 03h
		db	0ABh, 83h, 11h, 03h, 0ABh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 1Bh
		db	00h, 0Eh, 0C0h, 07h, 0DEh, 00h, 0FFh, 00h, 0FFh, 0FFh, 0FFh, 0FFh
		db	0FFh, 0FFh, 0FFh, 19h, 0AFh, 02h, 0Ah

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'In the Hut'

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	99h, 00h, 0Ah, 12h, 0FFh, 07h, 00h, 00h, 10h, 0C0h, 0A7h, 0C1h
		db	0Ah, 0C0h, 73h, 0C1h, 30h, 00h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		db	0FFh, 0FFh

map_mp73	endp

seg_a		ends

		end	start
