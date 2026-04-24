
PAGE  59,132

;==========================================================================
;
;  349MP90.BIN - Level 9 Floor 0
;
;  Zeliard dungeon map data file (MP90). Loaded by stick.bin as an
;  MDT (map data table). This is labyrinth/cavern map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x01dc = 476)
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

map_mp90	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	01DCh		; total_size field
		dw	0000h		; reserved / zero
		dw	0C1D5h		; hdr ptr[0] (runtime addr)
		dw	002Ah		; hdr ptr[1] (runtime addr)
		dw	0C1B9h		; hdr ptr[2] (runtime addr)
		dw	0C1BBh		; hdr ptr[3] (runtime addr)
		dw	0C1BDh		; hdr ptr[4] (runtime addr)
		dw	0C1BFh		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	0C1h, 0C1h, 0C3h, 0C1h, 0DAh, 0C1h, 09h, 0FFh, 0FFh, 0FFh, 0Dh, 00h
		db	00h, 0B9h, 0C1h, 0C1h, 07h, 09h, 0C1h, 58h, 81h, 0CAh, 0CCh, 0AEh
		db	48h, 0C2h, 07h, 09h, 0C8h, 48h, 82h, 0CBh, 0CDh, 0AEh, 48h, 0C3h
		db	0C7h, 48h, 81h, 0C9h, 0C1h, 48h, 0C5h, 81h, 0C9h, 82h, 0CAh, 0CCh
		db	0AEh, 0C9h, 0C6h, 0C4h, 78h, 0C2h, 05h, 09h, 81h, 0CBh, 0CDh, 0AEh
		db	48h, 0C5h, 0C9h, 0C1h, 48h, 0C6h, 0C3h, 0C7h, 81h, 48h, 0C1h, 82h
		db	0CAh, 0CCh, 0AEh, 48h, 48h, 0C8h, 58h, 0C4h, 81h, 0C1h, 82h, 0C8h
		db	82h, 0CBh, 0CDh, 0AEh, 48h, 0C9h, 81h, 0C5h, 81h, 0C9h, 81h, 0C5h
		db	0C9h, 0C8h, 82h, 0C5h, 82h, 0CAh, 0CCh, 0AEh, 0C9h, 0C1h, 0C9h, 0C1h
		db	48h, 81h, 0C1h, 82h, 0C5h, 81h, 0C9h, 83h, 0CBh, 0CDh, 0AEh, 0C9h
		db	0C8h, 0C9h, 0C2h, 81h, 0C9h, 81h, 0C2h, 81h, 0C9h, 86h, 0CAh, 0CCh
		db	0AEh, 0C9h, 0C5h, 0C6h, 0C3h, 0C7h, 81h, 0C6h, 0C3h, 0C7h, 87h, 0CBh
		db	0CDh, 0AEh, 48h, 81h, 0C4h, 81h, 0C9h, 81h, 0C4h, 81h, 0C9h, 86h
		db	0CAh, 0CCh, 0AEh, 48h, 0C1h, 0C5h, 0C9h, 0C1h, 81h, 0C5h, 88h, 0CBh
		db	0CDh, 0AEh, 48h, 0C2h, 81h, 0C9h, 0C8h, 0C9h, 89h, 0CAh, 0CCh, 0AEh
		db	0C9h, 81h, 0C3h, 0C7h, 81h, 0C5h, 82h, 0C9h, 87h, 0CBh, 0CDh, 0AEh
		db	0C9h, 0C6h, 0C4h, 83h, 0C9h, 89h, 0CAh, 0CCh, 0AEh, 48h, 0C5h, 58h
		db	89h, 0CEh, 0CBh, 0CDh, 0AEh, 0C9h, 81h, 8Dh, 0CFh, 0CAh, 0CCh, 0AEh
		db	0C9h, 0C1h, 81h, 0C9h, 81h, 0C9h, 89h, 0CFh, 0CBh, 0CDh, 0AEh, 0C9h
		db	0C2h, 0C7h, 81h, 0C9h, 8Ah, 0CFh, 0CAh, 0CCh, 0AEh, 0C6h, 0C3h, 81h
		db	0C1h, 8Bh, 0D0h, 0CBh, 0CDh, 0AEh, 0C9h, 0C4h, 81h, 0C8h, 8Bh, 0CFh
		db	0CAh, 0CCh, 0AEh, 0C9h, 0C5h, 0C1h, 0C5h, 8Ah, 0E2h, 0D0h, 0CBh, 0CDh
		db	0AEh, 48h, 0C2h, 8Ah, 0DFh, 0E3h, 0CFh, 0CAh, 0CCh, 0AEh, 48h, 0C3h
		db	0C7h, 81h, 0C9h, 86h, 0DCh, 0E0h, 0D7h, 0CFh, 0CBh, 0CDh, 0AEh, 0C9h
		db	0C6h, 0C4h, 89h, 0DCh, 0E1h, 0D7h, 0D0h, 0CAh, 0CCh, 0AEh, 48h, 0C5h
		db	0C9h, 88h, 0DCh, 01h, 17h, 0D0h, 0CBh, 0CDh, 0AEh, 48h, 84h, 0D1h
		db	85h, 0E2h, 0D7h, 0E4h, 0CFh, 0CAh, 0CCh, 0AEh, 0C9h, 81h, 81h, 0C9h
		db	82h, 0D2h, 0D3h, 83h, 0DBh, 0DEh, 0E4h, 0E5h, 0CFh, 0CBh, 0CDh, 0AEh
		db	0C9h, 0C1h, 82h, 0D1h, 82h, 0D4h, 0D5h, 01h, 18h, 01h, 17h, 0E4h
		db	0E6h, 0D0h, 0CAh, 0CCh, 0AEh, 0C9h, 0C8h, 0C9h, 81h, 0D2h, 0D3h, 82h
		db	0D6h, 0D9h, 01h, 17h, 0E4h, 01h, 26h, 0CFh, 0CBh, 0CDh, 0AEh, 0C9h
		db	0C5h, 83h, 0D4h, 0D5h, 04h, 17h, 02h, 26h, 0D0h, 0CAh, 0CCh, 0AEh
		db	48h, 8Eh, 0CBh, 0CDh, 0B0h, 8Eh, 0CAh, 0CCh, 0B0h, 8Eh, 0CBh, 0CDh
		db	0B0h, 8Eh, 0CAh, 0CCh, 0B0h, 8Eh, 0CBh, 0CDh, 0B0h, 8Eh, 0CAh, 0CCh
		db	0B0h, 8Eh, 0CBh, 0CDh, 0B0h, 8Eh, 0CAh, 0CCh, 0B0h, 8Eh, 0CBh, 0CDh
		db	0B0h, 8Eh, 0CAh, 0CCh, 0B0h, 8Eh, 0CBh, 0CDh, 0B0h, 0FFh, 0FFh, 0FFh
		db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 18h, 0AFh, 04h, 0Eh

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'Jashiin\s room['

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	00h, 08h, 10h, 10h, 0FFh, 0FFh

map_mp90	endp

seg_a		ends

		end	start
