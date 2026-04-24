
PAGE  59,132

;==========================================================================
;
;  342MP7D.BIN - Level 7 Floor D (town/checkpoint)
;
;  Zeliard dungeon map data file (MP7D). Loaded by stick.bin as an
;  MDT (map data table). This is town map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x02d0 = 720)
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

map_mp7d	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	02D0h		; total_size field
		dw	0000h		; reserved / zero
		dw	0C2B6h		; hdr ptr[0] (runtime addr)
		dw	0046h		; hdr ptr[1] (runtime addr)
		dw	0C25Ch		; hdr ptr[2] (runtime addr)
		dw	0C25Eh		; hdr ptr[3] (runtime addr)
		dw	0C260h		; hdr ptr[4] (runtime addr)
		dw	0C27Ah		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	7Ch, 0C2h, 0A0h, 0C2h, 0CEh, 0C2h, 07h, 0FFh, 0FFh, 00h, 0Ch, 00h
		db	00h, 5Ch, 0C2h, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h, 57h, 0C9h
		db	57h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h, 57h, 0D2h
		db	57h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h, 47h, 48h
		db	57h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h, 0C8h, 0DFh
		db	0CCh, 0D0h, 0D1h, 0C8h, 0E1h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh
		db	0D0h, 0D1h, 0C8h, 0CBh, 0CCh, 0D0h, 0D1h, 0C8h, 0D2h, 0CBh, 0ABh, 83h
		db	0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h, 0C8h, 0CBh, 0CCh, 0D0h, 0D1h, 47h
		db	0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h, 0C8h, 0CBh, 0CCh
		db	0D0h, 0D1h, 47h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h
		db	0C8h, 0CBh, 0CCh, 0D0h, 0D1h, 47h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h
		db	0Eh, 0D0h, 0D1h, 47h, 01h, 12h, 57h, 0CBh, 0ABh, 83h, 0E0h, 0CCh
		db	05h, 0Eh, 0D0h, 0D1h, 06h, 08h, 0CBh, 0ABh, 83h, 0C8h, 0CBh, 5Eh
		db	5Dh, 0D0h, 0D1h, 06h, 08h, 0CBh, 0ABh, 83h, 57h, 0D2h, 0E0h, 0CCh
		db	0CEh, 0D0h, 0D1h, 77h, 0CAh, 47h, 0CBh, 0ABh, 83h, 0CAh, 0C8h, 01h
		db	13h, 0C8h, 0CBh, 0CFh, 0D0h, 0D1h, 0C8h, 0CBh, 0D1h, 77h, 0CBh, 0ABh
		db	83h, 47h, 0DAh, 0D7h, 0C5h, 0C8h, 02h, 12h, 0CAh, 47h, 0CAh, 67h
		db	0CBh, 0ABh, 83h, 0CAh, 0C8h, 0DAh, 0DCh, 0C6h, 0C9h, 0C8h, 49h, 0C8h
		db	0CAh, 05h, 08h, 0CBh, 0ABh, 83h, 01h, 13h, 0DBh, 0DDh, 81h, 0C6h
		db	67h, 0CAh, 57h, 02h, 13h, 0CBh, 0ABh, 89h, 0C6h, 06h, 13h, 0DBh
		db	0C5h, 0D3h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h
		db	0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C4h, 0D6h, 0CBh, 0ABh
		db	92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h
		db	0D6h, 0CBh, 0ABh, 92h, 0C7h, 0D6h, 0CBh, 0ABh, 92h, 0C4h, 0D6h, 0CBh
		db	0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h
		db	0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h
		db	0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 01h, 16h, 0CBh, 0ABh
		db	92h, 0C7h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h
		db	0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh
		db	0ABh, 92h, 0C4h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h
		db	0C4h, 0D6h, 0CBh, 0ABh, 92h, 0C4h, 0D6h, 0CBh, 0ABh, 92h, 0C4h, 0D6h
		db	0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh
		db	92h, 0C4h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h
		db	0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh
		db	0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C4h, 0D6h, 0CBh, 0ABh, 92h
		db	0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h
		db	0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh, 92h, 0C5h, 0D6h, 0CBh, 0ABh
		db	92h, 0C5h, 0D6h, 0CBh, 0ABh, 8Ah, 0C4h, 0C7h, 0D4h, 0D7h, 0C4h, 66h
		db	0D6h, 0CBh, 0ABh, 85h, 0C4h, 66h, 0CAh, 0C8h, 46h, 67h, 0CAh, 0C7h
		db	0CBh, 0ABh, 84h, 0C4h, 0C8h, 0CAh, 07h, 08h, 0CAh, 0C8h, 0CAh, 47h
		db	0CBh, 0ABh, 83h, 0C4h, 57h, 58h, 67h, 49h, 57h, 0CAh, 0CBh, 0ABh
		db	83h, 47h, 0C9h, 0CBh, 0CCh, 0CDh, 0D0h, 0D1h, 47h, 49h, 47h, 0C9h
		db	47h, 0CBh, 0ABh, 83h, 0C8h, 0CBh, 0CCh, 6Dh, 0D0h, 0D1h, 47h, 0CAh
		db	47h, 0D2h, 47h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h
		db	47h, 0CBh, 0D1h, 57h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h
		db	0D1h, 06h, 08h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h
		db	77h, 0C9h, 0C8h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h
		db	77h, 0D2h, 0C8h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h
		db	0C8h, 0CAh, 77h, 0CBh, 0ABh, 83h, 0CBh, 0CCh, 05h, 0Eh, 0D0h, 0D1h
		db	06h, 08h, 0CBh, 0ABh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 15h, 00h
		db	0Eh, 0C1h, 12h, 0C7h, 00h, 21h, 00h, 0FFh, 0FFh, 0FFh, 32h, 00h
		db	0Eh, 82h, 17h, 39h, 00h, 05h, 80h, 36h, 00h, 80h, 0FFh, 0FFh
		db	36h, 00h, 80h, 76h, 0C2h, 00h, 0FFh, 78h, 0C2h, 0FFh, 0FFh, 0FFh
		db	0FFh, 32h, 00h, 0FFh, 10h, 0C0h, 0CCh, 0C2h, 0Ah, 0C0h, 62h, 0C2h
		db	0B9h, 0C2h, 0Ch, 0Ch, 0B6h, 0C2h, 15h, 00h, 0FFh, 0FFh, 0FFh, 0FFh
		db	15h, 0AFh, 02h, 12h

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'Cavern of Caliente'

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	99h, 00h, 06h, 0Dh, 0FFh, 0Dh, 0Ch, 0Ch, 10h, 0C0h, 0CCh, 0C2h
		db	0Ah, 0C0h, 6Eh, 0C2h, 32h, 00h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		db	0FFh, 0FFh

map_mp7d	endp

seg_a		ends

		end	start
