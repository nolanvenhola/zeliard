
PAGE  59,132

;==========================================================================
;
;  337MP6D.BIN - Level 6 Floor D (town/checkpoint)
;
;  Zeliard dungeon map data file (MP6D). Loaded by stick.bin as an
;  MDT (map data table). This is town map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x02fe = 766)
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

map_mp6d	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	02FEh		; total_size field
		dw	0000h		; reserved / zero
		dw	0C2D0h		; hdr ptr[0] (runtime addr)
		dw	0049h		; hdr ptr[1] (runtime addr)
		dw	0C26Fh		; hdr ptr[2] (runtime addr)
		dw	0C271h		; hdr ptr[3] (runtime addr)
		dw	0C273h		; hdr ptr[4] (runtime addr)
		dw	0C28Dh		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	8Fh, 0C2h, 0BCh, 0C2h, 0FCh, 0C2h, 06h, 0FFh, 0FFh, 00h, 0Ch, 00h
		db	00h, 6Fh, 0C2h, 83h, 0C9h, 0C8h, 53h, 0C5h, 53h, 0C5h, 53h, 4Bh
		db	4Ch, 0C9h, 0ABh, 83h, 0C9h, 0C8h, 43h, 0C5h, 53h, 0C5h, 53h, 0C7h
		db	4Ch, 81h, 48h, 0ABh, 83h, 0C8h, 43h, 0C5h, 53h, 0C5h, 0E0h, 43h
		db	0C7h, 5Bh, 0CAh, 0CDh, 0C9h, 0ABh, 83h, 0C8h, 0C4h, 0C5h, 53h, 0C5h
		db	53h, 0C7h, 0CCh, 0CDh, 0CCh, 0CBh, 0CAh, 48h, 0ABh, 83h, 0C8h, 0E0h
		db	43h, 0C5h, 05h, 04h, 4Bh, 49h, 58h, 0ABh, 83h, 53h, 0C5h, 0E0h
		db	73h, 0C7h, 0CCh, 0CDh, 4Ah, 0CDh, 0CBh, 0C9h, 0ABh, 83h, 0C3h, 0C4h
		db	0C5h, 05h, 04h, 0C7h, 4Bh, 0C9h, 0CBh, 0C8h, 0CBh, 0CAh, 0C8h, 0ABh
		db	84h, 0C3h, 05h, 04h, 0C7h, 4Bh, 49h, 0C9h, 0C7h, 0CDh, 0CCh, 0C8h
		db	0ABh, 85h, 0C3h, 53h, 0C7h, 0C9h, 0CCh, 49h, 0CCh, 0C8h, 0CCh, 0C5h
		db	47h, 0C4h, 0ABh, 85h, 42h, 43h, 0C7h, 0C9h, 4Bh, 0C7h, 0CAh, 0CBh
		db	0CAh, 0C9h, 0C8h, 43h, 0ABh, 86h, 0C3h, 43h, 0C7h, 48h, 0CCh, 0C9h
		db	49h, 0CCh, 0CAh, 43h, 0C5h, 0ABh, 83h, 0CEh, 0CFh, 0D0h, 0C3h, 0C4h
		db	0E0h, 0C4h, 0C7h, 0C9h, 0CBh, 0C9h, 0CAh, 0CCh, 0CAh, 0CCh, 0C8h, 0C5h
		db	0C4h, 0ABh, 86h, 0C3h, 0C4h, 0E0h, 0C9h, 5Bh, 0C9h, 0CCh, 0CAh, 47h
		db	43h, 0C5h, 0ABh, 87h, 0C3h, 68h, 0CAh, 0C9h, 0CAh, 0C8h, 53h, 0C5h
		db	0C4h, 0ABh, 83h, 0D2h, 01h, 13h, 0D4h, 0C3h, 0C9h, 0CCh, 49h, 0CCh
		db	0CAh, 0CCh, 0C8h, 43h, 0C5h, 0E0h, 0C4h, 0ABh, 88h, 0CDh, 6Bh, 0CAh
		db	0CCh, 0C8h, 0C5h, 0E0h, 0C5h, 43h, 0ABh, 89h, 49h, 0CCh, 0CAh, 0CDh
		db	0CCh, 0C5h, 0C4h, 0C5h, 0C4h, 0C5h, 0C4h, 0ABh, 92h, 0C3h, 43h, 0ABh
		db	92h, 0C3h, 0C5h, 0C4h, 0ABh, 92h, 0C3h, 0E0h, 0C4h, 0ABh, 92h, 0C3h
		db	0C5h, 0E0h, 0ABh, 92h, 0C3h, 43h, 0ABh, 92h, 0C3h, 0E0h, 0C4h, 0ABh
		db	92h, 0C3h, 0E0h, 0C4h, 0ABh, 92h, 0C3h, 0E0h, 0C4h, 0ABh, 92h, 0C3h
		db	0C5h, 0C4h, 0ABh, 92h, 0C3h, 0E0h, 0C4h, 0ABh, 92h, 0C3h, 0E0h, 0C4h
		db	0ABh, 92h, 0C3h, 0C5h, 0C4h, 0ABh, 92h, 0C3h, 0C4h, 0C7h, 0ABh, 92h
		db	0C3h, 0C5h, 0C4h, 0ABh, 92h, 0C3h, 0C5h, 0E0h, 0ABh, 92h, 0C3h, 0E0h
		db	0C4h, 0ABh, 92h, 0C3h, 0C5h, 0C7h, 0ABh, 92h, 0C3h, 0C5h, 0C7h, 0ABh
		db	92h, 0C3h, 0C5h, 0CAh, 0ABh, 92h, 0C3h, 0C7h, 0C9h, 0ABh, 92h, 0C3h
		db	0C5h, 0CAh, 0ABh, 92h, 0C3h, 0C7h, 0CAh, 0ABh, 92h, 0C3h, 0C4h, 0C8h
		db	0ABh, 92h, 0C3h, 0C5h, 0E0h, 0ABh, 92h, 0C3h, 0C5h, 0C4h, 0ABh, 92h
		db	0C3h, 0E0h, 0C4h, 0ABh, 92h, 0C3h, 0C5h, 0C4h, 0ABh, 92h, 0C3h, 0C5h
		db	0C4h, 0ABh, 92h, 0C3h, 0E0h, 0C4h, 0ABh, 92h, 0C3h, 0C5h, 0C4h, 0ABh
		db	92h, 0C3h, 0C5h, 0E0h, 0ABh, 92h, 0C3h, 0E0h, 0C4h, 0ABh, 92h, 0C3h
		db	43h, 0ABh, 92h, 0C3h, 43h, 0ABh, 92h, 0C3h, 0C5h, 0C4h, 0ABh, 92h
		db	0C3h, 0C5h, 0C4h, 0ABh, 92h, 0C3h, 0E0h, 0C4h, 0ABh, 92h, 0C3h, 0C5h
		db	0C4h, 0ABh, 92h, 0C3h, 0C5h, 0E0h, 0ABh, 92h, 0C3h, 0C5h, 0C4h, 0ABh
		db	92h, 0C3h, 0C5h, 0C4h, 0ABh, 92h, 0C3h, 0C5h, 0C4h, 0ABh, 83h, 0CEh
		db	06h, 0Fh, 0D0h, 5Bh, 0C8h, 43h, 0E0h, 43h, 0ABh, 8Ah, 0CCh, 48h
		db	0C8h, 53h, 0C5h, 53h, 0ABh, 83h, 0CEh, 6Eh, 0D0h, 0CAh, 48h, 47h
		db	43h, 0C5h, 63h, 0ABh, 88h, 0CCh, 0C9h, 0C8h, 43h, 0E0h, 0C4h, 0C5h
		db	73h, 0ABh, 87h, 4Bh, 0C9h, 0C8h, 53h, 0C5h, 0C4h, 0E0h, 63h, 0ABh
		db	83h, 0D2h, 0D3h, 0D4h, 0CCh, 0C9h, 0CAh, 0C8h, 0Ah, 04h, 0ABh, 85h
		db	0CCh, 0C9h, 0CBh, 0C9h, 0C8h, 43h, 0E0h, 07h, 04h, 0ABh, 85h, 0CDh
		db	48h, 0C8h, 73h, 0C5h, 0C4h, 0C5h, 0E0h, 53h, 0ABh, 85h, 0CCh, 0CBh
		db	0C8h, 43h, 0E0h, 43h, 0C5h, 0C4h, 0E0h, 73h, 0ABh, 84h, 0CCh, 48h
		db	73h, 0C5h, 0C4h, 0C5h, 05h, 04h, 0ABh, 83h, 0CCh, 0CAh, 0CBh, 0C9h
		db	0C8h, 53h, 0C5h, 0C4h, 44h, 05h, 04h, 0ABh, 83h, 0C9h, 0CAh, 0C9h
		db	0C8h, 53h, 0C5h, 06h, 04h, 0E0h, 0C7h, 0CCh, 0ABh, 83h, 0CAh, 0CBh
		db	0C8h, 05h, 04h, 0E0h, 73h, 0C7h, 0CCh, 0C9h, 0ABh, 83h, 0CBh, 0CDh
		db	0C8h, 0C4h, 0E0h, 07h, 04h, 0C7h, 0CDh, 0CCh, 0C9h, 0CDh, 0ABh, 0FFh
		db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 1Bh, 00h, 0Eh, 0C1h, 0Eh, 35h, 01h
		db	29h, 00h, 0FFh, 0FFh, 0FFh, 2Fh, 00h, 0Eh, 82h, 0Eh, 1Ch, 00h
		db	2Eh, 80h, 2Dh, 00h, 10h, 0FFh, 0FFh, 2Dh, 00h, 20h, 0EAh, 0C2h
		db	0FFh, 0FFh, 0FFh, 0FFh, 2Dh, 00h, 10h, 89h, 0C2h, 00h, 0FFh, 8Bh
		db	0C2h, 0FFh, 0FFh, 0FFh, 0FFh, 28h, 00h, 0FFh, 10h, 0C0h, 0EAh, 0C2h
		db	0Ah, 0C0h, 75h, 0C2h, 0D3h, 0C2h, 0Ah, 0Ah, 0D0h, 0C2h, 13h, 00h
		db	0FFh, 0FFh, 0FFh, 0FFh, 17h, 0AFh, 00h, 10h

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'Cavern of Tesoro'

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	99h, 00h, 05h, 0Bh, 0FFh, 0Bh, 0Ah, 0Ah, 10h, 0C0h, 0EAh, 0C2h
		db	0Ah, 0C0h, 81h, 0C2h, 0ECh, 0C2h, 05h, 0FFh, 28h, 00h, 0FFh, 0FFh
		db	0FFh, 0FFh, 26h, 00h, 10h, 0FFh, 76h, 00h, 00h, 20h, 00h, 00h
		db	00h, 2Dh, 00h, 20h, 00h, 00h, 0FFh, 0FFh, 0FFh, 0FFh

map_mp6d	endp

seg_a		ends

		end	start
