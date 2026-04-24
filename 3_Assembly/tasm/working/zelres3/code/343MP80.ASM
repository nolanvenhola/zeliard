
PAGE  59,132

;==========================================================================
;
;  343MP80.BIN - Level 8 Floor 0
;
;  Zeliard dungeon map data file (MP80). Loaded by stick.bin as an
;  MDT (map data table). This is labyrinth/cavern map data -- not executable code.
;
;  Sourcer mis-decoded the bytes as x86 instructions; this file re-emits
;  them as labeled `db` data blocks matching the original binary exactly.
;
;  Layout (16-byte header + pointer table, then tilemap/NPC/dialog/script):
;
;    +0x00  size_word         - total size field (0x1c7e = 7294)
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

map_mp80	proc	far

start:

; ------------------------------------------------------------------
; Header: 16-byte map descriptor
;   +0x00 WORD  total_size_field (= map_size - 1 or similar)
;   +0x02 WORD  reserved (zero)
;   +0x04..+0x0F  runtime pointer table into this file
; ------------------------------------------------------------------

map_header	label	word
		dw	1C7Eh		; total_size field
		dw	0000h		; reserved / zero
		dw	0D8B7h		; hdr ptr[0] (runtime addr)
		dw	0100h		; hdr ptr[1] (runtime addr)
		dw	0D748h		; hdr ptr[2] (runtime addr)
		dw	0D762h		; hdr ptr[3] (runtime addr)
		dw	0D770h		; hdr ptr[4] (runtime addr)
		dw	0D7AAh		; hdr ptr[5] (runtime addr)

; ------------------------------------------------------------------
; map_data -- tile-grid / NPC records / door cells / event entries
;
; Tile indices, cell coordinates, and interactive-object records for
; this floor. Exact sub-structure depends on map variant; Sourcer
; mis-decoded these bytes as x86 mnemonics. Bytes are 1:1 with binary.
; ------------------------------------------------------------------

map_data:
		db	30h, 0D8h, 0A4h, 0D8h, 0BCh, 0D8h, 08h, 0FFh, 0FFh, 0FFh, 0Ah, 00h
		db	00h, 48h, 0D7h, 46h, 85h, 0C5h, 0C7h, 0CCh, 0C9h, 46h, 84h, 0C4h
		db	46h, 0CCh, 81h, 46h, 8Bh, 0C6h, 06h, 07h, 8Ah, 0C4h, 56h, 0CCh
		db	84h, 0C5h, 0C7h, 46h, 85h, 0C4h, 46h, 0CCh, 0C7h, 81h, 0C8h, 83h
		db	0C4h, 0CAh, 0C7h, 94h, 0C4h, 0CCh, 0CAh, 8Ah, 0C4h, 46h, 0CBh, 0C8h
		db	84h, 0C4h, 0C7h, 46h, 85h, 0C4h, 0C7h, 0C9h, 0C7h, 0CCh, 85h, 0C5h
		db	46h, 94h, 0C4h, 46h, 8Ah, 0C5h, 56h, 85h, 0C4h, 0CCh, 46h, 85h
		db	0C4h, 0CCh, 0C7h, 81h, 0C7h, 85h, 0C4h, 0C7h, 95h, 0C4h, 0CAh, 0CCh
		db	8Ah, 0C4h, 56h, 85h, 0C4h, 0C7h, 0CAh, 0CCh, 85h, 0C4h, 0C7h, 0C9h
		db	46h, 85h, 0C4h, 0C7h, 85h, 0C3h, 06h, 07h, 88h, 0C4h, 46h, 8Ah
		db	0C5h, 56h, 85h, 0C4h, 0CCh, 46h, 85h, 0C4h, 0CCh, 0C7h, 87h, 0C6h
		db	86h, 0C5h, 49h, 46h, 4Bh, 0C9h, 0C7h, 0C8h, 86h, 0C4h, 46h, 8Ah
		db	0C4h, 0C9h, 0C7h, 0C8h, 85h, 0C4h, 0C7h, 0C7h, 0C9h, 85h, 0C5h, 0CAh
		db	0CBh, 8Eh, 0C4h, 07h, 07h, 0C8h, 86h, 0C4h, 46h, 8Ah, 0C4h, 0C7h
		db	0CCh, 0C8h, 85h, 0C4h, 0CAh, 46h, 85h, 0C4h, 0C7h, 50h, 51h, 0C1h
		db	41h, 40h, 51h, 81h, 0C5h, 0CCh, 76h, 0CCh, 0C9h, 0C7h, 86h, 0C4h
		db	0CCh, 0C7h, 0C8h, 89h, 0C4h, 56h, 85h, 0C4h, 0C7h, 46h, 85h, 0C4h
		db	0C7h, 8Fh, 0C5h, 0CAh, 07h, 07h, 86h, 0C4h, 0C7h, 0C8h, 8Ah, 0C4h
		db	0C7h, 0C9h, 0CCh, 85h, 0C4h, 0C7h, 46h, 85h, 0C6h, 86h, 0C3h, 46h
		db	81h, 46h, 82h, 56h, 0C9h, 06h, 07h, 0C8h, 86h, 0C4h, 46h, 40h
		db	51h, 40h, 0C2h, 0C1h, 81h, 0C5h, 56h, 85h, 0C4h, 0C7h, 46h, 8Ch
		db	0C5h, 09h, 07h, 0CCh, 66h, 0CAh, 0CCh, 0C7h, 87h, 0C4h, 0C7h, 0C8h
		db	8Ah, 0C4h, 46h, 0CCh, 85h, 0C4h, 0C7h, 56h, 8Bh, 0C4h, 66h, 6Bh
		db	0CAh, 46h, 0CCh, 66h, 0CBh, 0C7h, 87h, 0C4h, 0CCh, 0C7h, 85h, 0C3h
		db	81h, 06h, 07h, 85h, 0C5h, 0C7h, 5Bh, 0C8h, 8Ah, 0C6h, 56h, 0C9h
		db	46h, 0CBh, 0C8h, 0CBh, 66h, 8Ch, 0C4h, 0CAh, 0CBh, 85h, 0C5h, 07h
		db	07h, 85h, 0C5h, 0CAh, 46h, 81h, 46h, 87h, 07h, 07h, 94h, 0C4h
		db	46h, 85h, 0C5h, 4Bh, 46h, 0CCh, 46h, 47h, 84h, 0C4h, 0C9h, 05h
		db	07h, 81h, 0C7h, 0CCh, 81h, 06h, 07h, 0CCh, 0C7h, 41h, 50h, 41h
		db	50h, 0C2h, 0C1h, 0C2h, 50h, 41h, 40h, 81h, 0C4h, 0C7h, 86h, 0C4h
		db	56h, 0C8h, 0C7h, 0CCh, 0C9h, 0C8h, 85h, 0C4h, 0C7h, 05h, 07h, 0CCh
		db	0Bh, 07h, 95h, 0C4h, 46h, 85h, 0C4h, 0CAh, 0C9h, 05h, 07h, 85h
		db	0C4h, 0C7h, 0CCh, 46h, 0C9h, 56h, 0CCh, 0CAh, 56h, 0C9h, 56h, 0CCh
		db	0C9h, 0C7h, 85h, 0C3h, 46h, 81h, 46h, 88h, 0C3h, 5Bh, 0C7h, 85h
		db	0C4h, 0CCh, 06h, 07h, 85h, 0C4h, 0C7h, 0C9h, 09h, 07h, 81h, 06h
		db	07h, 85h, 0C5h, 66h, 0CAh, 56h, 85h, 0C4h, 66h, 85h, 0C4h, 56h
		db	0C9h, 0CCh, 49h, 0CBh, 85h, 0C4h, 0CAh, 56h, 0C8h, 81h, 0C4h, 66h
		db	84h, 0C4h, 66h, 85h, 0C5h, 0C9h, 0CAh, 05h, 07h, 0C8h, 84h, 0C5h
		db	66h, 85h, 0C5h, 0C7h, 0C9h, 05h, 07h, 85h, 0C5h, 0C7h, 0C7h, 84h
		db	0C4h, 66h, 84h, 0C5h, 76h, 84h, 0C4h, 0C7h, 0CCh, 46h, 0CAh, 0CCh
		db	0C9h, 46h, 84h, 0C4h, 46h, 0CBh, 0C7h, 85h, 0C4h, 0C7h, 0CCh, 05h
		db	07h, 85h, 0C4h, 0C7h, 0C7h, 84h, 0C5h, 46h, 0C9h, 0C7h, 84h, 0C4h
		db	76h, 84h, 0C5h, 08h, 07h, 84h, 0C5h, 46h, 81h, 0C8h, 85h, 0C4h
		db	0C7h, 0CAh, 0CBh, 66h, 0C8h, 85h, 0C4h, 0C7h, 85h, 0C5h, 0C7h, 87h
		db	0C5h, 76h, 84h, 0C4h, 66h, 0CBh, 0CAh, 0C7h, 0CBh, 0C8h, 84h, 0C5h
		db	56h, 0C8h, 85h, 0C5h, 07h, 07h, 85h, 0C4h, 0C7h, 85h, 0C4h, 0C7h
		db	87h, 0C5h, 49h, 0C7h, 0C9h, 0C7h, 84h, 0C4h, 0C7h, 0CCh, 46h, 81h
		db	56h, 85h, 0C4h, 66h, 85h, 0C4h, 07h, 07h, 85h, 0C6h, 81h, 85h
		db	0C4h, 0CAh, 4Bh, 85h, 0C4h, 56h, 0CCh, 0C7h, 84h, 0C6h, 8Dh, 0C4h
		db	0C9h, 4Bh, 0C7h, 85h, 0C4h, 0CCh, 0C9h, 46h, 0CCh, 0C7h, 0C9h, 88h
		db	40h, 0C2h, 0C1h, 81h, 0C4h, 0C9h, 0C7h, 0CCh, 0C7h, 84h, 0C5h, 0CBh
		db	56h, 93h, 0C4h, 56h, 0CBh, 0C8h, 84h, 0C4h, 06h, 07h, 40h, 61h
		db	40h, 85h, 0C4h, 56h, 85h, 0C4h, 66h, 93h, 0C4h, 46h, 87h, 0C5h
		db	0CAh, 0CCh, 56h, 81h, 0CBh, 0C8h, 87h, 85h, 0C5h, 46h, 0C9h, 0CCh
		db	84h, 0C4h, 66h, 0C8h, 92h, 0C4h, 0CAh, 0CBh, 0CCh, 81h, 0C8h, 84h
		db	0C4h, 46h, 0CBh, 0C7h, 0CBh, 0C7h, 0C8h, 85h, 0C3h, 82h, 85h, 0C4h
		db	66h, 84h, 0C4h, 0CAh, 56h, 85h, 0C3h, 81h, 0C7h, 0C8h, 8Ah, 0C5h
		db	66h, 85h, 0C6h, 81h, 46h, 81h, 0C7h, 0CAh, 86h, 0C4h, 46h, 0C7h
		db	84h, 0C4h, 0C7h, 0CCh, 0C7h, 85h, 0C5h, 56h, 0CBh, 85h, 0C5h, 0C9h
		db	0CCh, 0C7h, 8Ah, 0C4h, 0CCh, 0C9h, 46h, 92h, 0C5h, 0CAh, 0CCh, 0C7h
		db	84h, 0C5h, 66h, 84h, 0C5h, 4Bh, 46h, 85h, 0C5h, 66h, 89h, 0C5h
		db	0CAh, 56h, 92h, 0C5h, 46h, 0C7h, 84h, 0C4h, 56h, 85h, 0C4h, 0C9h
		db	0C7h, 0CBh, 86h, 0C4h, 66h, 89h, 0C4h, 56h, 0CCh, 92h, 0C4h, 0CCh
		db	0C7h, 0C8h, 84h, 0C6h, 81h, 46h, 85h, 0C6h, 46h, 0C8h, 86h, 0C4h
		db	0C7h, 0CAh, 0C9h, 0CCh, 89h, 0C4h, 0C7h, 81h, 0CBh, 93h, 0C4h, 0C7h
		db	0CCh, 98h, 0C4h, 66h, 89h, 0C6h, 96h, 0C4h, 0C9h, 0C7h

; ------------------------------------------------------------------
; dialog_strings -- NPC / sign / event text. Each string is
; terminated by 0xFF. Embedded bytes < 0x20 are control codes
; (color, speaker, animation) processed by the script interpreter.
; ------------------------------------------------------------------

dialog_strings:
		db	'A@a@q`A@'
		db	81h, 0C5h, 0C9h, 56h, 0A0h, 0C4h, 46h, 98h, 0C4h, 66h, 0A0h, 0C5h
		db	46h, 0CAh, 88h, 0C3h, 81h, 46h, 8Ah, 0CFh, 0C7h, 0CAh, 0C9h, 46h
		db	0A0h, 0C4h, 46h, 46h, 87h, 0C5h, 56h, 89h, 0CFh, 66h, 0CAh, 8Ah
		db	0C3h, 0CCh, 0C8h, 94h, 0C4h, 46h, 0CCh, 0C7h, 87h, 0C4h, 0C7h, 0C9h
		db	46h, 87h, 0CFh, 56h, 8Dh, 0C5h, 56h, 0C8h, 92h, 0C4h, 0CAh, 0CCh
		db	46h, 87h, 0C4h, 46h, 0CBh, 87h, 0CFh, 0C7h, 0C9h, 0C1h, 0C2h, 0C1h
		db	0C2h, 60h, 0C2h, 86h, 0C4h, 0C7h, 0CCh, 0C9h, 0C7h, 92h, 0C4h, 46h
		db	0CCh, 0C7h, 87h, 0C5h, 66h, 85h, 0CFh, 56h, 8Fh, 0C4h, 66h, 92h
		db	0C5h, 46h, 0CAh, 0CCh, 87h, 0C4h, 0C7h, 0CBh, 0C7h, 0CCh, 85h, 0C5h
		db	0CAh, 46h, 85h, 0C3h, 81h, 0C7h, 87h, 0C5h, 0C7h, 0CAh, 0C7h, 0C8h
		db	92h, 0C5h, 46h, 0C9h, 0C7h, 87h, 0C4h, 76h, 84h, 0C4h, 0C7h, 0CAh
		db	0C7h, 85h, 0C4h, 46h, 87h, 0C5h, 0C7h, 0CCh, 0C7h, 0C8h, 92h, 0C4h
		db	46h, 46h, 87h, 0C4h, 0C7h, 4Bh, 0C7h, 0C8h, 84h, 0C4h, 0C9h, 4Bh
		db	0C8h, 84h, 0C5h, 0C9h, 46h, 86h, 0C5h, 0C7h, 0CAh, 0C9h, 0C7h, 87h
		db	0C3h, 81h, 46h, 87h, 0C4h, 46h, 46h, 0C8h, 86h, 0C4h, 66h, 85h
		db	0C4h, 66h, 84h, 0C4h, 56h, 86h, 0C4h, 66h, 87h, 0C4h, 0CAh, 0CCh
		db	0C7h, 82h, 57h, 81h, 0CAh, 56h, 56h, 86h, 0C5h, 66h, 85h, 0C4h
		db	46h, 0CCh, 85h, 0C4h, 0CCh, 0C9h, 0C7h, 0C8h, 85h, 0C4h, 0C7h, 0CCh
		db	46h, 87h, 0C4h, 0CAh, 4Bh, 46h, 0C9h, 5Bh, 66h, 56h, 86h, 0C5h
		db	0C9h, 0C7h, 0CCh, 0CBh, 85h, 0C4h, 66h, 84h, 0C4h, 46h, 0CCh, 0C7h
		db	85h, 0C4h, 66h, 87h, 0C4h, 0C9h, 0CCh, 0Ah, 07h, 0C7h, 88h, 0C4h
		db	66h, 85h, 0C4h, 56h, 85h, 0C4h, 66h, 85h, 0C5h, 0CAh, 0C9h, 0C7h
		db	88h, 0C4h, 46h, 0C9h, 0CAh, 56h, 0CAh, 0C9h, 66h, 0C8h, 88h, 0C4h
		db	66h, 85h, 0C5h, 0CCh, 0C9h, 0C7h, 85h, 0C4h, 0CAh, 66h, 84h, 0C4h
		db	56h, 88h, 0C4h, 0Ch, 07h, 46h, 87h, 0C5h, 46h, 0CCh, 0C7h, 85h
		db	0C4h, 56h, 85h, 0C4h, 76h, 0CCh, 07h, 07h, 87h, 0C5h, 0Ch, 07h
		db	46h, 87h, 0C4h, 56h, 0CBh, 0C8h, 84h, 0C4h, 46h, 0CBh, 0CCh, 84h
		db	0C5h, 0C7h, 0C9h, 0CAh, 56h, 0CBh, 0C9h, 06h, 07h, 86h, 0C5h, 08h
		db	07h, 0C9h, 0CAh, 0CCh, 0CAh, 0C7h, 88h, 0C4h, 66h, 0C8h, 84h, 0C5h
		db	0C7h, 0CAh, 46h, 84h, 0C4h, 0Ah, 07h, 0CAh, 46h, 0C8h, 86h, 0C4h
		db	76h, 0CCh, 0C7h, 82h, 46h, 0C9h, 0C7h, 0C7h, 88h, 0C4h, 56h, 0CAh
		db	85h, 0C5h, 46h, 0C9h, 0C7h, 84h, 0C4h, 0Dh, 07h, 87h, 0C4h, 0CCh
		db	76h, 84h, 0C4h, 46h, 0C7h, 88h, 0C4h, 66h, 85h, 0C4h, 56h, 85h
		db	0C4h, 0C7h, 0CBh, 0CCh, 0C9h, 56h, 0C8h, 46h, 0C9h, 0CCh, 0C7h, 0C8h
		db	87h, 0C4h, 76h, 85h, 0C4h, 46h, 0C7h, 88h, 0C4h, 0C9h, 0C7h, 0CCh
		db	0C7h, 85h, 0C4h, 66h, 84h, 0C4h, 56h, 0CCh, 0C7h, 84h, 0C4h, 56h
		db	0C8h, 87h, 0C4h, 0CAh, 0C9h, 0CCh, 46h, 85h, 0C4h, 46h, 0C7h, 0C8h
		db	87h, 0C5h, 46h, 0C9h, 0CCh, 85h, 0C4h, 56h, 85h, 0C5h, 0C7h, 0C9h
		db	46h, 85h, 0C4h, 0C7h, 0CBh, 0C9h, 0C7h, 87h, 0C4h, 56h, 87h, 0C4h
		db	46h, 0C7h, 0CAh, 0C7h, 86h, 0C5h, 66h, 0C8h, 84h, 0C4h, 0C9h, 46h
		db	85h, 0C5h, 0C7h, 0CAh, 46h, 85h, 0C4h, 5Bh, 0C7h, 87h, 0C4h, 56h
		db	87h, 0C5h, 0C9h, 0C7h, 46h, 87h, 0C4h, 0C7h, 0CAh, 0C7h, 0CCh, 0C8h
		db	84h, 0C4h, 0CCh, 56h, 84h, 0C4h, 0CAh, 46h, 0C8h, 85h, 0C5h, 66h
		db	0C8h, 86h, 0C4h, 46h, 0C9h, 0C7h, 86h, 0C4h, 46h, 0C7h, 0CCh, 87h
		db	0C4h, 66h, 85h, 0C4h, 0CBh, 0CAh, 46h, 84h, 0C4h, 0C9h, 56h, 85h
		db	0C5h, 0C7h, 0C9h, 0C7h, 0CCh, 0C7h, 86h, 0C4h, 66h, 86h, 0C4h, 0C7h
		db	0CAh, 46h, 0C8h, 86h, 0C4h, 66h, 85h, 0C5h, 56h, 85h, 0C4h, 0CBh
		db	46h, 0C8h, 85h, 0C4h, 0C9h, 66h, 0C9h, 85h, 0C4h, 56h, 87h, 0C4h
		db	46h, 0CCh, 0C7h, 87h, 0C5h, 46h, 0CAh, 0C8h, 85h, 0C4h, 56h, 0C8h
		db	84h, 0C4h, 0C7h, 0CCh, 0C7h, 86h, 0C4h, 76h, 0C8h, 85h, 0C5h, 66h
		db	86h, 0C5h, 46h, 46h, 87h, 0C4h, 56h, 0C8h, 85h, 0C4h, 0C7h, 0CCh
		db	0C7h, 0C8h, 84h, 0C4h, 56h, 86h, 0C5h, 46h, 0CBh, 0C7h, 0C8h, 86h
		db	0C4h, 46h, 0CCh, 0C7h, 86h, 0C5h, 46h, 56h, 86h, 0C5h, 66h, 85h
		db	0C4h, 46h, 0C9h, 0C7h, 84h, 0C4h, 56h, 0C8h, 85h, 0C4h, 66h, 87h
		db	0C4h, 66h, 86h, 0C4h, 46h, 0CCh, 56h, 85h, 0C5h, 0C9h, 56h, 85h
		db	0C4h, 0C7h, 0C9h, 46h, 84h, 0C4h, 46h, 0CCh, 86h, 0C4h, 66h, 87h
		db	0C4h, 76h, 85h, 0C4h, 46h, 56h, 86h, 0C4h, 0C7h, 0C9h, 46h, 85h
		db	0C4h, 46h, 0CBh, 0C7h, 84h, 0C5h, 0CAh, 0C9h, 46h, 0C8h, 84h, 0C4h
		db	0C9h, 0CCh, 0CBh, 0C8h, 87h, 0C4h, 0C7h, 0C9h, 0CCh, 0CBh, 0CCh, 85h
		db	0C5h, 46h, 0CAh, 0C7h, 81h, 0C8h, 85h, 0C4h, 66h, 85h, 0C5h, 56h
		db	0CCh, 0C8h, 83h, 0C4h, 66h, 85h, 0C4h, 56h, 0C8h, 87h, 0C4h, 76h
		db	85h, 0C4h, 0C9h, 0C7h, 0C7h, 0CAh, 0CCh, 86h, 0C4h, 46h, 0CAh, 0CBh
		db	85h, 0C5h, 56h, 0C8h, 84h, 0C4h, 56h, 0C8h, 85h, 0C4h, 66h, 87h
		db	0C4h, 46h, 4Bh, 86h, 0C4h, 46h, 46h, 0CCh, 0CBh, 85h, 0C5h, 66h
		db	85h, 0C4h, 56h, 85h, 0C5h, 0C7h, 0CAh, 0C7h, 86h, 0C4h, 56h, 0CAh
		db	0CCh, 86h, 0C4h, 76h, 85h, 0C5h, 46h, 0C7h, 0CCh, 0C8h, 86h, 0C4h
		db	56h, 0CCh, 85h, 0C4h, 46h, 0CCh, 0C8h, 84h, 0C4h, 46h, 0C9h, 0C7h
		db	85h, 0C5h, 76h, 86h, 0C4h, 56h, 0C9h, 86h, 0C4h, 46h, 66h, 0C8h
		db	84h, 0C4h, 66h, 85h, 0C4h, 56h, 85h, 0C4h, 56h, 0C8h, 85h, 0C4h
		db	05h, 07h, 85h, 0C5h, 76h, 85h, 0C4h, 46h, 0CBh, 0CCh, 0C7h, 0C8h
		db	85h, 0C5h, 56h, 0C8h, 85h, 0C4h, 0CAh, 0C9h, 0C7h, 85h, 0C4h, 56h
		db	86h, 0C4h, 0C7h, 0C9h, 46h, 0CCh, 0C7h, 85h, 0C5h, 76h, 85h, 0C5h
		db	46h, 0C9h, 0CBh, 87h, 0C4h, 66h, 85h, 0C4h, 46h, 0CBh, 0C8h, 84h
		db	0C5h, 56h, 86h, 0C6h, 0C7h, 81h, 0C5h, 0CBh, 0C7h, 86h, 0C4h, 46h
		db	4Bh, 0C7h, 85h, 0C6h, 46h, 46h, 87h, 0C4h, 46h, 0CCh, 0C7h, 85h
		db	0C4h, 56h, 0C8h, 84h, 0C6h, 81h, 46h, 89h, 0C4h, 56h, 85h, 0C4h
		db	46h, 0C9h, 0C7h, 0CCh, 0C7h, 87h, 89h, 0C4h, 0C9h, 0CAh, 0CBh, 0CCh
		db	0C8h, 84h, 0C4h, 0C9h, 0CCh, 0C7h, 92h, 0C4h, 46h, 0CAh, 85h, 0C4h
		db	05h, 07h, 87h, 89h, 0C4h, 66h, 0C8h, 84h, 0C4h, 56h, 92h, 0C4h
		db	0C7h, 87h, 0C4h, 05h, 07h, 87h, 89h, 0C4h, 66h, 85h, 0C4h, 0C7h
		db	0C9h, 0C7h, 92h, 0C4h, 0C7h, 87h, 0C4h, 0C7h, 0CAh, 0C9h, 66h, 83h
		db	56h, 0C7h, 88h, 0C5h, 0C7h, 0CAh, 0C9h, 0C7h, 85h, 0C5h, 46h, 93h
		db	0C4h, 0C9h, 46h, 85h, 0C4h, 0C9h, 0CCh, 0C7h, 0CCh, 66h, 0CCh, 66h
		db	0C7h, 88h, 0C5h, 46h, 0CAh, 0C7h, 85h, 0C4h, 56h, 92h, 0C4h, 0C7h
		db	0C9h, 0CBh, 85h, 0C4h, 07h, 07h, 0CCh, 0C9h, 56h, 0C7h, 88h, 0C5h
		db	0C9h, 0C7h, 0CBh, 0C7h, 85h, 0C4h, 0C9h, 0CAh, 0C7h, 92h, 0C5h, 46h
		db	86h, 0C4h, 0Ch, 07h, 46h, 87h, 0C4h, 66h, 85h, 0C4h, 56h, 92h
		db	0C5h, 56h, 85h, 0C5h, 0Ah, 07h, 0CCh, 0C7h, 0C9h, 0C7h, 87h, 0C4h
		db	66h, 85h, 0C4h, 56h, 92h, 0C4h, 46h, 86h, 0C4h, 76h, 0C9h, 0C7h
		db	4Bh, 0C7h, 0CCh, 46h, 0C7h, 88h, 0C4h, 0C7h, 0C9h, 0CAh, 0CBh, 85h
		db	0C5h, 46h, 0CBh, 0C8h, 91h, 0C4h, 0C9h, 0CAh, 0C7h, 85h, 0C4h, 0CCh
		db	0C7h, 0C9h, 0CCh, 46h, 0CAh, 05h, 07h, 81h, 0C7h, 87h, 0C4h, 56h
		db	0CCh, 85h, 0C5h, 0C7h, 0C9h, 0C7h, 0CCh, 88h, 0C3h, 88h, 0C4h, 4Bh
		db	0C7h, 85h, 0C4h, 76h, 84h, 0E9h, 0E5h, 46h, 0C7h, 88h, 0C4h, 56h
		db	0C8h, 85h, 0D0h, 66h, 81h, 0C8h, 86h, 0C4h, 0CAh, 46h, 85h, 0C4h
		db	56h, 85h, 0C5h, 66h, 85h, 0E5h, 0CAh, 46h, 0C9h, 0C7h, 87h, 0C5h
		db	0C7h, 0CAh, 0CCh, 87h, 0D0h, 0CAh, 4Bh, 46h, 0C8h, 85h, 0C5h, 56h
		db	85h, 0C4h, 0CAh, 46h, 85h, 0C5h, 46h, 0CCh, 0C7h, 85h, 0E9h, 0E5h
		db	0CAh, 0CCh, 46h, 87h, 0C4h, 66h, 87h, 0D0h, 66h, 81h, 0C8h, 84h
		db	0C5h, 0C7h, 0CBh, 0CCh, 0C8h, 84h, 0C4h, 46h, 86h, 0C4h, 56h, 86h
		db	0E5h, 0C9h, 46h, 0CCh, 0C7h, 87h, 0C4h, 0C7h, 0CCh, 0CBh, 0C7h, 88h
		db	0D0h, 0C7h, 0CAh, 0C9h, 0C7h, 85h, 0C4h, 66h, 84h, 0C5h, 0C7h, 0C9h
		db	0C8h, 85h, 0C4h, 0C7h, 88h, 0E9h, 0E5h, 46h, 46h, 87h, 0C4h, 56h
		db	0C8h, 89h, 0D0h, 56h, 85h, 0C4h, 0C7h, 0C9h, 0C8h, 85h, 0C4h, 56h
		db	85h, 0C6h, 89h, 0E5h, 56h, 46h, 87h, 0C4h, 0C9h, 46h, 8Bh, 0C5h
		db	46h, 0C8h, 84h, 0C4h, 56h, 85h, 0C4h, 0CCh, 46h, 03h, 12h, 01h
		db	13h, 89h, 0E9h, 0E5h, 46h, 0CAh, 0CCh, 87h, 0C4h, 46h, 8Ch, 0C4h
		db	0CCh, 0C9h, 85h, 0C4h, 66h, 84h, 0C4h, 56h, 03h, 12h, 01h, 13h
		db	89h, 0E5h, 56h, 0C9h, 0C7h, 87h, 0C6h, 8Eh, 0C4h, 0C7h, 0CCh, 85h
		db	0C5h, 48h, 0CCh, 85h, 0C4h, 46h, 0C8h, 03h, 12h, 01h, 13h, 89h
		db	0E9h, 0E5h, 0C9h, 0C7h, 0CCh, 46h, 95h, 0C5h, 46h, 85h, 0C4h, 66h
		db	84h, 0C5h, 0C7h, 0C9h, 0C8h, 03h, 12h, 01h, 13h, 89h, 0E5h, 0CAh
		db	46h, 46h, 0CAh, 0C1h, 51h, 50h, 0C2h, 0C1h, 51h, 50h, 41h, 50h
		db	81h, 0C4h, 0C9h, 0C7h, 85h, 0C4h, 0CAh, 0C9h, 0CCh, 85h, 0C5h, 46h
		db	81h, 03h, 12h, 01h, 13h, 89h, 0E9h, 0E5h, 46h, 56h, 95h, 0C4h
		db	46h, 85h, 0C4h, 56h, 85h, 0C6h, 83h, 03h, 12h, 01h, 13h, 01h
		db	11h, 87h, 0E5h, 0C9h, 46h, 0C7h, 0CCh, 8Bh, 0C3h, 8Ah, 0C6h, 0C7h
		db	81h, 04h, 11h, 0C4h, 66h, 88h, 02h, 12h, 04h, 13h, 87h, 0E9h
		db	0E5h, 0CAh, 0CCh, 46h, 8Bh, 0C4h, 0C8h, 46h, 87h, 07h, 13h, 0C5h
		db	66h, 86h, 04h, 12h, 04h, 13h, 87h, 0E5h, 56h, 0C9h, 0C7h, 8Bh
		db	0C4h, 0C9h, 0C7h, 0C8h, 86h, 08h, 13h, 0C5h, 0C7h, 0CCh, 0C7h, 0CBh
		db	0C8h, 83h, 06h, 12h, 04h, 13h, 87h, 0E9h, 0E5h, 46h, 46h, 8Bh
		db	0C4h, 4Bh, 88h, 07h, 13h, 0C4h, 46h, 0CCh, 0CAh, 0C9h, 0C7h, 82h
		db	06h, 12h, 04h, 13h, 87h, 0E5h, 56h, 0C7h, 8Ch, 0C5h, 46h, 0CAh
		db	87h, 0C3h, 0C7h, 81h, 04h, 12h, 0C6h, 82h, 0C4h, 46h, 0C9h, 0C7h
		db	0C8h, 0Bh, 12h, 87h, 0E9h, 0E5h, 4Bh, 0CCh, 8Ch, 0C5h, 56h, 87h
		db	0C4h, 56h, 87h, 0C4h, 76h, 83h, 0C3h, 81h, 46h, 8Ch, 0E5h, 49h
		db	0CCh, 0C7h, 8Ch, 0C4h, 56h, 0CBh, 86h, 0C4h, 56h, 87h, 0C4h, 0CBh
		db	56h, 0C8h, 83h, 0C4h, 0C7h, 0C9h, 0CAh, 0C7h, 8Bh, 0E9h, 0E5h, 46h
		db	8Dh, 0C4h, 0CCh, 46h, 0C8h, 86h, 0C4h, 0C7h, 0C9h, 0C7h, 87h, 0C5h
		db	4Bh, 0C7h, 0C8h, 84h, 0C5h, 0C7h, 4Bh, 0C7h, 8Bh, 0E5h, 0C9h, 0C7h
		db	0CCh, 0C7h, 8Ch, 0C4h, 0CAh, 0CCh, 0C7h, 87h, 0C5h, 66h, 86h, 0C4h
		db	46h, 0C8h, 81h, 0C8h, 83h, 0C4h, 76h, 0C8h, 89h, 0E9h, 0E5h, 46h
		db	0C7h, 8Ch, 0C4h, 66h, 86h, 0C5h, 56h, 87h, 0C6h, 88h, 0C4h, 0C7h
		db	0CCh, 0C7h, 0CCh, 0C7h, 8Ah, 0E5h, 56h, 0C7h, 8Ch, 0C5h, 46h, 0CCh
		db	0C7h, 86h, 0C4h, 0C7h, 0CAh, 0C9h, 46h, 8Eh, 0C4h, 56h, 0CAh, 0CBh
		db	0C8h, 89h, 0E9h, 0E5h, 0CCh, 0C7h, 0C7h, 8Ch, 0C4h, 56h, 0C8h, 86h
		db	0C4h, 76h, 60h, 05h, 02h, 40h, 0C2h, 81h, 0C4h, 0C7h, 0C9h, 56h
		db	0C8h, 89h, 0E5h, 56h, 0CAh, 8Ch, 0C4h, 0CCh, 56h, 86h, 0C4h, 46h
		db	4Bh, 0C7h, 8Eh, 0C5h, 66h, 0C8h, 8Ah, 0E9h, 0E5h, 46h, 0C7h, 8Ch
		db	0C5h, 56h, 0CCh, 86h, 0C4h, 66h, 88h, 46h, 85h, 0C5h, 46h, 0C8h
		db	0C7h, 81h, 0C8h, 8Ah, 0C4h, 46h, 0C7h, 8Ch, 0C4h, 46h, 0CBh, 0C7h
		db	0CBh, 85h, 0C4h, 46h, 0CCh, 0CAh, 46h, 84h, 66h, 85h, 0C5h, 0C9h
		db	66h, 8Bh, 0C4h, 0C7h, 0CAh, 0C7h, 8Ch, 0C4h, 66h, 86h, 0C5h, 0Dh
		db	07h, 85h, 0C4h, 0C7h, 0CCh, 56h, 8Bh, 0C4h, 0C7h, 0C9h, 0C7h, 8Ch
		db	0C4h, 56h, 0C8h, 86h, 0C4h, 56h, 0CCh, 0C7h, 0CCh, 66h, 0CCh, 46h
		db	86h, 0C4h, 0C9h, 0C7h, 5Bh, 0C7h, 50h, 41h, 60h, 81h, 0C6h, 82h
		db	8Dh, 0C4h, 0C9h, 46h, 0C8h, 81h, 0DDh, 84h, 0C4h, 06h, 07h, 0C9h
		db	0CAh, 0CBh, 66h, 85h, 0C4h, 56h, 0CAh, 0CCh, 46h, 8Ch, 60h, 51h
		db	50h, 0C2h, 82h, 0C4h, 0CAh, 0C9h, 46h, 81h, 0DEh, 84h, 0C4h, 66h
		db	0C9h, 05h, 07h, 0C9h, 0CCh, 0C7h, 85h, 0C4h, 0C9h, 0C7h, 0CCh, 46h
		db	0CBh, 0CCh, 56h, 41h, 50h, 61h, 8Dh, 0C4h, 4Bh, 0CBh, 0C7h, 0C8h
		db	0DFh, 84h, 0C5h, 56h, 0CCh, 46h, 82h, 05h, 07h, 85h, 0C4h, 09h
		db	07h, 89h, 82h, 0C3h, 8Ah, 0C5h, 0C9h, 56h, 81h, 0E0h, 84h, 0C5h
		db	56h, 0C9h, 0CCh, 85h, 0C4h, 56h, 85h, 0C4h, 0Ah, 07h, 81h, 0C7h
		db	0C8h, 85h, 82h, 0C4h, 0C7h, 89h, 0C5h, 46h, 0CAh, 0CCh, 81h, 0E1h
		db	84h, 0C4h, 76h, 85h, 0C4h, 0CAh, 0CCh, 0C7h, 85h, 0C4h, 76h, 0CCh
		db	0C7h, 0CBh, 46h, 0CCh, 66h, 0C8h, 83h, 82h, 0C4h, 56h, 87h, 0C4h
		db	66h, 86h, 0C4h, 66h, 86h, 0C4h, 56h, 85h, 0C4h, 76h, 0C8h, 83h
		db	0C4h, 05h, 07h, 0C8h, 82h, 82h, 0C4h, 0C7h, 0C9h, 0CCh, 81h, 0C7h
		db	85h, 0C4h, 66h, 86h, 0C4h, 4Bh, 46h, 86h, 0C4h, 46h, 0CCh, 85h
		db	0C4h, 0C7h, 0C9h, 46h, 85h, 0C4h, 0C9h, 46h, 0CCh, 0C9h, 46h, 82h
		db	82h, 0C4h, 76h, 85h, 0C4h, 0CCh, 46h, 0CCh, 86h, 0C4h, 0CAh, 0C9h
		db	0CBh, 0C7h, 86h, 0C4h, 56h, 85h, 0C5h, 66h, 0C8h, 84h, 0C5h, 0C7h
		db	0CCh, 0CAh, 0C7h, 0C9h, 0CCh, 0C7h, 82h, 82h, 0C4h, 0C7h, 0CCh, 46h
		db	0CBh, 85h, 0C5h, 66h, 86h, 0C4h, 76h, 85h, 0C4h, 56h, 85h, 0C4h
		db	0C7h, 0C9h, 0C7h, 81h, 0C8h, 84h, 0C5h, 05h, 07h, 81h, 0C8h, 81h
		db	82h, 0C5h, 46h, 0C9h, 46h, 85h, 0C4h, 0C9h, 0C7h, 0CBh, 0C8h, 86h
		db	0C5h, 46h, 0C9h, 0CBh, 0C7h, 85h, 0C4h, 0C7h, 0CAh, 0C7h, 85h, 0C4h
		db	66h, 85h, 0C4h, 0C9h, 05h, 07h, 82h, 82h, 0C5h, 76h, 85h, 0C5h
		db	56h, 87h, 0C4h, 76h, 85h, 0C4h, 46h, 86h, 0C4h, 66h, 85h, 0C4h
		db	76h, 81h, 0C8h, 82h, 82h, 0C4h, 76h, 85h, 0C5h, 56h, 87h, 0C4h
		db	66h, 86h, 0C4h, 0C7h, 0CCh, 0CAh, 85h, 0C4h, 0C7h, 0CAh, 0CBh, 0C7h
		db	0C8h, 84h, 0C4h, 56h, 0CAh, 46h, 83h, 82h, 0C4h, 76h, 85h, 0C4h
		db	46h, 88h, 0C4h, 66h, 86h, 0C4h, 56h, 85h, 0C5h, 56h, 0CCh, 85h
		db	0C5h, 05h, 07h, 83h, 82h, 0C4h, 0C7h, 0CAh, 0CCh, 46h, 85h, 0C4h
		db	8Ah, 0C4h, 0CCh, 0CAh, 0C7h, 87h, 0C4h, 0C7h, 0C9h, 0CCh, 85h, 0C4h
		db	66h, 85h, 0C4h, 56h, 0CBh, 0CCh, 84h, 82h, 0C4h, 56h, 4Bh, 85h
		db	0C6h, 86h, 0C3h, 83h, 0C4h, 0C7h, 0CCh, 88h, 0C6h, 46h, 86h, 0C4h
		db	0C7h, 0C9h, 56h, 84h, 0C6h, 0C8h, 81h, 0C7h, 0C8h, 85h, 82h, 0C4h
		db	56h, 0CAh, 0CCh, 8Ch, 0C4h, 46h, 81h, 56h, 0CBh, 90h, 0C4h, 46h
		db	0CCh, 0C7h, 8Fh, 82h, 0C4h, 46h, 0C9h, 0C7h, 8Dh, 0C4h, 0C7h, 0CCh
		db	66h, 91h, 0C4h, 0C7h, 0C9h, 46h, 8Fh, 82h, 0C4h, 76h, 8Ch, 0C4h
		db	06h, 07h, 90h, 0C4h, 66h, 8Fh, 82h, 0C5h, 76h, 8Ch, 0C5h, 0CAh
		db	0C9h, 76h, 87h, 0C3h, 46h, 86h, 0C4h, 56h, 90h, 82h, 0C4h, 76h
		db	8Ch, 0C4h, 56h, 0C9h, 0C7h, 0CAh, 0C9h, 0C7h, 86h, 0C4h, 0CAh, 0C9h
		db	0C7h, 85h, 0C4h, 66h, 8Fh, 82h, 0C4h, 0C7h, 0CAh, 0CCh, 46h, 8Ch
		db	0C4h, 4Bh, 05h, 07h, 86h, 0C4h, 0C7h, 0CBh, 0CCh, 85h, 0C4h, 0C9h
		db	0C7h, 0CAh, 46h, 8Eh, 82h, 0C4h, 76h, 8Ch, 0C4h, 76h, 4Bh, 46h
		db	85h, 0C4h, 56h, 85h, 0C4h, 76h, 8Eh, 82h, 0C4h, 46h, 4Bh, 0CBh
		db	8Ch, 0C5h, 0C7h, 0CAh, 0CCh, 05h, 07h, 85h, 0C4h, 46h, 0CAh, 85h
		db	0C4h, 66h, 8Fh, 82h, 0C4h, 0C7h, 0CAh, 0C7h, 0CAh, 8Dh, 0C4h, 56h
		db	0CBh, 0C7h, 0C9h, 0C7h, 0CAh, 0C9h, 0CCh, 84h, 0C4h, 46h, 86h, 0C5h
		db	0C7h, 0CAh, 0C7h, 0CBh, 8Fh, 82h, 0C4h, 66h, 8Dh, 0C4h, 09h, 07h
		db	01h, 1Ah, 01h, 1Ch, 66h, 85h, 0C5h, 76h, 8Eh, 82h, 0C5h, 66h
		db	8Dh, 0C4h, 06h, 07h, 0C9h, 0C7h, 0CCh, 0DBh, 01h, 1Ah, 0DBh, 0CBh
		db	0C7h, 0C9h, 0CAh, 85h, 0C4h, 0C7h, 0C9h, 46h, 8Fh, 82h, 0C5h, 0CAh
		db	0C7h, 0C9h, 46h, 8Ch, 0C4h, 09h, 07h, 02h, 1Ah, 0DCh, 0CCh, 56h
		db	85h, 0C4h, 0CAh, 4Bh, 0C7h, 8Fh, 82h, 0C4h, 0C7h, 0CCh, 56h, 8Ch
		db	0C4h, 0CAh, 0C9h, 0CCh, 05h, 07h, 0CAh, 0DAh, 0DBh, 01h, 1Ah, 0C7h
		db	0CCh, 0C7h, 86h, 0C4h, 66h, 8Fh, 82h, 0C4h, 0C7h, 0CAh, 4Bh, 0C7h
		db	85h, 0C3h, 56h, 0C9h, 0Ch, 07h, 0DAh, 02h, 12h, 81h, 0C7h, 87h
		db	0C4h, 76h, 8Eh, 82h, 0C4h, 46h, 0CBh, 46h, 85h, 0C4h, 0C7h, 4Bh
		db	05h, 07h, 0CCh, 46h, 49h, 0C9h, 0C7h, 8Eh, 0C4h, 46h, 0CBh, 0CCh
		db	0C8h, 8Eh, 82h, 0C4h, 56h, 0CCh, 0C7h, 85h, 0C5h, 06h, 07h, 0CAh
		db	0C9h, 0CCh, 46h, 0C9h, 0CCh, 0C7h, 50h, 41h, 60h, 0C2h, 0C1h, 51h
		db	81h, 0C4h, 66h, 0CCh, 8Eh, 82h, 0C5h, 76h, 85h, 0C6h, 66h, 0CBh
		db	0CAh, 81h, 46h, 81h, 0C5h, 66h, 8Fh, 0C4h, 0C9h, 56h, 8Fh, 82h
		db	0C4h, 76h, 90h, 0C4h, 56h, 86h, 0C3h, 0C7h, 81h, 0C7h, 86h, 0C4h
		db	66h, 8Fh, 82h, 0C4h, 0C9h
		db	'fQ@A@A'
		db	0C1h, 0C2h, 40h, 81h, 0C4h, 66h, 85h, 0C4h, 49h, 0C7h, 86h, 0C4h
		db	56h, 90h, 81h, 0C3h, 76h, 91h, 0C4h, 0C7h, 0CAh, 56h, 84h, 0C4h
		db	66h, 85h, 0C4h, 56h, 90h, 81h, 0C4h, 56h, 89h, 0C3h, 89h, 0C4h
		db	4Bh, 0C9h, 46h, 84h, 0C4h, 0CAh, 0CCh, 46h, 85h, 0C4h, 56h, 90h
		db	0C3h, 0C7h, 4Bh, 8Ah, 0C4h, 0CAh, 88h, 0C4h, 66h, 85h, 0C5h, 0C9h
		db	0C7h, 0CCh, 0C7h, 85h, 0C5h, 46h, 91h, 0CAh, 56h, 85h, 0C3h, 84h
		db	0C4h, 0C7h, 0CAh, 81h, 0C7h, 85h, 0C5h, 0C7h, 0CCh, 0C7h, 0CAh, 85h
		db	0C4h, 66h, 85h, 0C4h, 56h, 8Bh, 0C3h, 66h, 0C7h, 0CCh, 0C7h, 86h
		db	0C5h, 46h, 82h, 0C4h, 0CAh, 4Bh, 0C7h, 85h, 0C4h, 46h, 0CCh, 86h
		db	0C6h, 0C7h, 81h, 0C7h, 86h, 0C4h, 56h, 8Bh, 0C6h, 46h, 0C9h, 0C7h
		db	89h, 0C5h, 76h, 0C9h, 56h, 85h, 0C5h, 66h, 8Fh, 0C4h, 0C7h, 0C9h
		db	0C7h, 90h, 89h, 0C4h, 56h, 0CCh, 76h, 85h, 0C4h, 0C7h, 0CAh, 0CCh
		db	0C7h, 8Fh, 0C4h, 0C7h, 0CAh, 0C7h, 90h, 89h, 0C4h, 0C7h, 0C9h, 4Bh
		db	56h, 0C9h, 86h, 0C4h, 46h, 0C9h, 0C7h, 8Fh, 0C5h, 56h, 0C8h, 8Fh
		db	0C7h, 0C9h, 0C7h, 86h, 0C4h, 46h, 82h, 0C4h, 0CAh, 4Bh, 0C7h, 85h
		db	0C4h, 0C9h, 56h, 85h, 0C3h, 0C7h, 81h, 0C7h, 85h, 0C3h, 0C7h, 0CBh
		db	46h, 8Bh, 0C3h, 46h, 0CCh, 0C7h, 66h, 85h, 0C6h, 84h, 0C5h, 0CAh
		db	48h, 0CBh, 85h, 0C4h, 56h, 86h, 0C4h, 66h, 84h, 0C4h, 76h, 8Ah
		db	0C6h, 46h, 0CAh, 0CCh, 0C6h, 56h, 8Ah, 0C4h, 0C9h, 0C7h, 0CBh, 86h
		db	0C4h, 66h, 85h, 0C4h, 0CAh, 0CCh, 0C9h, 0C7h, 84h, 0C4h, 0C7h, 0C9h
		db	0C7h, 4Bh, 0CBh, 8Eh, 81h, 0C4h, 0C7h, 0CAh, 0C7h, 89h, 0C6h, 46h
		db	87h, 0C4h, 0C9h, 0CCh, 0C7h, 86h, 0C5h, 56h, 0C8h, 84h, 0C5h, 66h
		db	0CBh, 8Fh, 81h, 0C6h, 76h, 91h, 0C5h, 66h, 85h, 0C5h, 66h, 84h
		db	0C4h, 76h, 8Fh, 82h, 0C4h, 0C7h, 0C9h, 0CCh
		db	'F@Q`a@'
		db	81h, 0C4h, 0C7h, 0CAh, 0CCh, 0C7h, 85h, 0C4h, 0C9h, 56h, 84h, 0C4h
		db	76h, 0C8h, 8Eh, 82h, 0C4h, 66h, 91h, 0C4h, 46h, 0C9h, 0C7h, 85h
		db	0C4h, 56h, 0C8h, 84h, 0C4h, 0C9h, 46h, 0CAh, 0C7h, 8Fh, 82h, 0C4h
		db	76h, 86h, 0C3h, 46h, 0CAh, 0C7h, 81h, 0C7h, 0CAh, 56h, 0C9h, 56h
		db	85h, 0C5h, 0C7h, 0CCh, 0C7h, 85h, 0C4h, 05h, 07h, 8Eh, 82h, 0C5h
		db	0C9h, 66h, 86h, 0C4h, 0CAh, 0C9h, 0CCh, 05h, 07h, 4Bh, 46h, 86h
		db	0C4h, 56h, 85h, 0C5h, 66h, 90h, 82h, 0C4h, 76h, 86h, 0C4h, 66h
		db	0CCh, 0C9h, 07h, 07h, 85h, 0C4h, 56h, 85h, 0C4h, 76h, 8Fh, 82h
		db	0C4h, 0CAh, 0CCh, 56h, 86h, 0C4h, 56h, 0C9h, 0CCh, 0CBh, 0CAh, 66h
		db	0CCh, 0C7h, 86h, 0C4h, 56h, 85h, 0C4h, 46h, 0CCh, 0C7h, 81h, 0C7h
		db	8Eh, 82h, 0C5h, 76h, 86h, 0C4h, 66h, 82h, 06h, 07h, 86h, 0C4h
		db	0C7h, 0CAh, 0CBh, 85h, 0C4h, 56h, 0CCh, 90h, 82h, 0C4h, 76h, 86h
		db	0C5h, 46h, 0C8h, 84h, 0C4h, 76h, 86h, 0C4h, 56h, 85h, 0C4h, 0C7h
		db	48h, 0C7h, 0CBh, 8Fh, 82h, 0C4h, 46h, 0CAh, 0CCh, 87h, 0C4h, 0CAh
		db	0CCh, 0C8h, 84h, 0C5h, 0C7h, 4Bh, 0C9h, 0C7h, 86h, 0C5h, 56h, 85h
		db	0C5h, 76h, 8Fh, 82h, 0C4h, 0C7h, 0CCh, 0C9h, 46h, 86h, 0C4h, 46h
		db	85h, 0C4h, 0C7h, 0CAh, 4Bh, 0C7h, 86h, 0C5h, 56h, 0C8h, 84h, 0C5h
		db	66h, 90h, 82h, 0C4h, 76h, 86h, 0C4h, 0C9h, 0CCh, 0CBh, 84h, 0C4h
		db	46h, 0C9h, 0CCh, 87h, 0C4h, 0C9h, 0CBh, 0C7h, 85h, 0C4h, 66h, 85h
		db	0C3h, 46h, 0CAh, 0CCh, 46h, 84h, 82h, 0C5h, 76h, 86h, 0C4h, 46h
		db	0CCh, 84h, 0C4h, 66h, 0CCh, 0C7h, 85h, 0C5h, 56h, 85h, 0C4h, 56h
		db	86h, 0C4h, 0C9h, 0CCh, 46h, 0CCh, 85h, 82h, 0C4h, 66h, 87h, 0C4h
		db	56h, 84h, 0C4h, 0C7h, 0C9h, 56h, 86h, 0C4h, 46h, 0CCh, 0C7h, 84h
		db	0C4h, 66h, 85h, 0C5h, 05h, 07h, 84h, 82h, 0C4h, 56h, 88h, 0C4h
		db	56h, 84h, 0C5h, 0C7h, 0CAh, 0CCh, 0CAh, 0C7h, 86h, 0C4h, 46h, 0CAh
		db	0CCh, 84h, 0C4h, 0C9h, 0CCh, 0CBh, 0CCh, 85h, 0C5h, 0C7h, 0CAh, 0C9h
		db	0CCh, 0C7h, 85h, 82h, 0C6h, 82h, 0C7h, 88h, 0C4h, 56h, 84h, 0C5h
		db	56h, 4Bh, 86h, 0C4h, 66h, 84h, 0C4h, 46h, 0C8h, 86h, 0C4h, 76h
		db	85h, 8Eh, 0C5h, 56h, 84h, 0C4h, 05h, 07h, 85h, 0C4h, 0C9h, 46h
		db	0CAh, 0CCh, 46h, 0CCh, 56h, 87h, 0C4h, 66h, 86h, 51h, 70h, 51h
		db	0C1h, 0C2h, 81h, 0C5h, 0CAh, 0C9h, 0C7h, 84h, 0C4h, 05h, 07h, 85h
		db	0C5h, 0Ch, 07h, 85h, 0C5h, 0CCh, 0C7h, 61h, 0C1h, 0C2h, 40h, 8Eh
		db	0C4h, 46h, 0C8h, 84h, 0C4h, 46h, 48h, 0C7h, 86h, 0C5h, 66h, 0CAh
		db	0C9h, 0CCh, 76h, 0C9h, 0C8h, 84h, 0C4h, 0CAh, 0CBh, 88h, 0C7h, 81h
		db	0C7h, 81h, 0C7h, 89h, 0C4h, 0C7h, 0C8h, 85h, 0C4h, 0C7h, 0CAh, 4Bh
		db	46h, 85h, 0C4h, 08h, 07h, 0CCh, 0C9h, 46h, 47h, 83h, 0C6h, 46h
		db	85h, 0C3h, 82h, 0C9h, 4Bh, 0CAh, 46h, 88h, 0C4h, 0C7h, 0C8h, 85h
		db	0C4h, 56h, 0CAh, 0CCh, 86h, 0C4h, 06h, 07h, 0CBh, 0C9h, 0CBh, 56h
		db	0CAh, 0C7h, 84h, 0C4h, 0C7h, 85h, 0C4h, 46h, 46h, 0CCh, 66h, 87h
		db	0C4h, 0C7h, 86h, 0C4h, 66h, 0CCh, 0C7h, 85h, 0C4h, 56h, 0CBh, 8Fh
		db	0C4h, 0C9h, 0C7h, 84h, 0C5h, 46h, 08h, 07h, 85h, 0C4h, 0CCh, 0C7h
		db	85h, 0C4h, 76h, 0C9h, 0C7h, 84h, 0C4h, 0CCh, 48h, 0C7h, 8Dh, 0C3h
		db	81h, 0C5h, 46h, 84h, 0C5h, 46h, 0CAh, 0CBh, 06h, 07h, 85h, 0C4h
		db	46h, 85h, 0C4h, 0CAh, 0CCh, 76h, 84h, 0C4h, 66h, 8Dh, 0C5h, 66h
		db	84h, 0C4h, 0C7h, 0CBh, 46h, 83h, 0C4h, 56h, 85h, 0C4h, 0CAh, 0C9h
		db	0CBh, 84h, 0C5h, 0C7h, 0C9h, 0CAh, 5Bh, 0CAh, 84h, 0C5h, 0C7h, 4Bh
		db	0C8h, 84h, 0C3h, 46h, 84h, 0C3h, 81h, 0C4h, 56h, 85h, 0C5h, 46h
		db	0C7h, 84h, 0C5h, 56h, 85h, 0C4h, 46h, 0CCh, 84h, 0C4h, 66h, 0CCh
		db	46h, 84h, 0C4h, 66h, 84h, 0C4h, 0CBh, 0C7h, 84h, 0C5h, 46h, 0CCh
		db	0C9h, 0CCh, 85h, 0C4h, 46h, 0C7h, 84h, 0C4h, 0CCh, 46h, 85h, 0C4h
		db	56h, 84h, 0C6h, 81h, 0C7h, 82h, 0C5h, 0C7h, 85h, 0C4h, 66h, 84h
		db	0C4h, 46h, 84h, 0C5h, 56h, 87h, 0C4h, 0CBh, 0CAh, 0C7h, 84h, 0C4h
		db	4Bh, 0C7h, 85h, 0C4h, 46h, 91h, 0C4h, 66h, 84h, 0C4h, 46h, 84h
		db	0C4h, 46h, 88h, 0C5h, 46h, 0C7h, 84h, 0C4h, 56h, 85h, 0C4h, 46h
		db	91h, 0C4h, 0C7h, 0C9h, 0C7h, 85h, 0C5h, 0C9h, 0CCh, 84h, 0C4h, 46h
		db	88h, 0C4h, 46h, 0C8h, 84h, 0C4h, 0C9h, 0C7h, 0CCh, 85h, 0C4h, 56h
		db	90h, 0C4h, 0C7h, 0CAh, 46h, 84h, 0C4h, 0CAh, 0C7h, 0C8h, 83h, 0C5h
		db	0C9h, 0CCh, 84h, 0C3h, 83h, 46h, 0CCh, 0CBh, 84h, 0C5h, 56h, 85h
		db	0C4h, 0C9h, 0CCh, 0CBh, 89h, 0C3h, 56h, 0CAh, 06h, 07h, 84h, 0C4h
		db	46h, 84h, 0C4h, 46h, 84h, 0C4h, 0C7h, 81h, 56h, 0C8h, 0C8h, 84h
		db	0C5h, 56h, 85h, 0C5h, 0CAh, 0CCh, 46h, 88h, 0C5h, 0C9h, 66h, 0CBh
		db	0CCh, 66h, 84h, 0C4h, 0C9h, 0C7h, 84h, 0C6h, 81h, 0C7h, 84h, 0C4h
		db	0C7h, 0CAh, 4Bh, 46h, 85h, 0C4h, 66h, 84h, 0C4h, 56h, 89h, 0C4h
		db	56h, 81h, 46h, 0C9h, 46h, 0CBh, 0CCh, 84h, 0C5h, 0C7h, 8Ch, 0C5h
		db	05h, 07h, 85h, 0C4h, 66h, 84h, 0C4h, 56h, 89h, 0C4h, 0C7h, 84h
		db	0C3h, 76h, 84h, 0C4h, 0C7h, 0C1h, 41h, 40h, 41h, 40h, 41h, 81h
		db	0C5h, 05h, 07h, 0C8h, 84h, 0C4h, 66h, 82h, 46h, 0CAh, 0CCh, 0C7h
		db	8Ah, 0C6h, 85h, 0C4h, 66h, 85h, 0C5h, 0CCh, 0C7h, 8Bh, 0C4h, 05h
		db	07h, 0C8h, 84h, 0C5h, 0C7h, 0CAh, 0CCh, 07h, 07h, 90h, 0C4h, 76h
		db	84h, 0C5h, 56h, 0C8h, 0C7h, 81h, 46h, 85h, 0C4h, 76h, 0CCh, 0C8h
		db	84h, 0C4h, 56h, 4Bh, 76h, 91h, 0C4h, 0CAh, 0CCh, 0C7h, 0C9h, 0C7h
		db	84h, 0C4h, 0CCh, 0C9h, 0CBh, 05h, 07h, 84h, 0C4h, 0C9h, 76h, 0C7h
		db	84h, 0C4h, 46h, 0C9h, 0CAh, 05h, 07h, 91h, 0C5h, 76h, 84h, 0C4h
		db	08h, 07h, 84h, 0C5h, 46h, 0CAh, 56h, 0C8h, 84h, 0C6h, 0Ah, 07h
		db	90h, 0C4h, 66h, 85h, 0C5h, 46h, 0CAh, 0C9h, 0CCh, 46h, 4Bh, 84h
		db	0C4h, 66h, 0C9h, 0C7h, 0C7h, 85h, 0C4h, 46h, 0C9h, 0C7h, 0CCh, 76h
		db	90h, 0C4h, 0C9h, 0CBh, 56h, 84h, 0C4h, 56h, 0CBh, 47h, 0C4h, 0C9h
		db	0CBh, 84h, 0C6h, 0C7h, 82h, 56h, 0C7h, 85h, 0C5h, 66h, 82h, 56h
		db	91h, 0C5h, 76h, 0C8h, 83h, 0C4h, 0C7h, 0C9h, 84h, 0C4h, 46h, 89h
		db	0C4h, 0CCh, 0C7h, 85h, 0C5h, 56h, 97h, 0C5h, 0C7h, 0CBh, 0C7h, 0CCh
		db	81h, 0C8h, 83h, 0C4h, 46h, 84h, 0C5h, 56h, 88h, 0C4h, 0C7h, 0C7h
		db	85h, 0C4h, 46h, 0C1h, 41h, 0C1h, 0C2h, 50h, 0C2h, 40h, 0C2h, 0C1h
		db	0C2h, 0C1h, 0C2h, 0C1h, 87h, 0C4h, 66h, 0CBh, 84h, 0C6h, 86h, 0C6h
		db	0C7h, 81h, 0C7h, 88h, 0C5h, 0C7h, 46h, 84h, 0C4h, 46h, 98h, 0C4h
		db	56h, 81h, 0C8h, 97h, 0C5h, 0C7h, 0C9h, 85h, 0C4h, 0C7h, 86h, 0C3h
		db	83h, 0C7h, 8Eh, 0C4h, 66h, 51h, 40h, 51h, 0C1h, 41h, 50h, 51h
		db	50h, 51h, 81h, 0C4h, 0CAh, 46h, 84h, 0C4h, 0CCh, 0C7h, 85h, 0C5h
		db	46h, 0CCh, 46h, 8Dh, 0C4h, 76h, 97h, 0C4h, 0C7h, 4Bh, 84h, 0C4h
		db	0C7h, 0CCh, 0C7h, 84h, 0C4h, 56h, 0CCh, 46h, 8Ch, 0C5h, 0CAh, 0CCh
		db	0CAh, 46h, 85h, 0C3h, 0C7h, 0CCh, 0C7h, 85h, 0C3h, 88h, 0C4h, 0CCh
		db	0C7h, 0CCh, 84h, 0C4h, 0C7h, 4Bh, 84h, 0C4h, 46h, 0CAh, 0CCh, 66h
		db	89h, 0C3h, 05h, 07h, 85h, 0C4h, 0CAh, 0CCh, 0C8h, 85h, 0C4h, 0C7h
		db	81h, 0C7h, 85h, 0C4h, 0C7h, 46h, 84h, 0C4h, 0C7h, 0CAh, 0C7h, 84h
		db	0C4h, 05h, 07h, 0C9h, 46h, 88h, 0C4h, 76h, 86h, 0C5h, 46h, 0CCh
		db	85h, 0C4h, 46h, 86h, 0C4h, 0C7h, 46h, 84h, 0C5h, 56h, 84h, 0C4h
		db	05h, 07h, 0CCh, 0C7h, 0CBh, 88h, 0C6h, 76h, 0CCh, 85h, 0C4h, 56h
		db	85h, 0C5h, 0C7h, 0CCh, 0C7h, 85h, 0C4h, 0C9h, 46h, 84h, 0C4h, 0CAh
		db	46h, 84h, 0C5h, 0CAh, 07h, 07h, 89h, 0C4h, 0C9h, 0CCh, 0C7h, 0C9h
		db	0C7h, 85h, 0C4h, 0C9h, 0C7h, 86h, 0C4h, 0C9h, 46h, 85h, 0C5h, 0C7h
		db	0C7h, 0C8h, 84h, 0C4h, 56h, 84h, 0C5h, 0C7h, 0CCh, 05h, 07h, 0CCh
		db	89h, 0C5h, 0C7h, 4Bh, 46h, 85h, 0C4h, 56h, 85h, 0C4h, 0CAh, 0CCh
		db	0C7h, 85h, 0C5h, 0C7h, 46h, 84h, 0C4h, 0CCh, 0C8h, 85h, 0C4h, 0C9h
		db	0C7h, 0CCh, 0C7h, 83h, 0C4h, 0D7h, 0D9h, 0D1h, 87h, 0C4h, 76h, 85h
		db	0C5h, 46h, 86h, 0C4h, 56h, 85h, 0C4h, 0CAh, 46h, 84h, 0C4h, 56h
		db	84h, 0C4h, 56h, 84h, 0D4h, 01h, 15h, 0D3h, 87h, 0C4h, 0C7h, 0C9h
		db	46h, 86h, 0C5h, 46h, 86h, 0C4h, 0C7h, 0CAh, 0CCh, 85h, 0C4h, 0C7h
		db	46h, 84h, 0C4h, 0C7h, 0CCh, 85h, 0C4h, 56h, 84h, 0D4h, 01h, 15h
		db	0D3h, 87h, 0C5h, 76h, 0C8h, 84h, 0C4h, 0C7h, 0CCh, 0C7h, 85h, 0C4h
		db	56h, 85h, 0C5h, 0C7h, 0C7h, 85h, 0C4h, 56h, 84h, 0C4h, 0C7h, 0C9h
		db	0C7h, 84h, 0D4h, 0D6h, 0D5h, 0D3h, 87h, 0C4h, 66h, 0CAh, 4Bh, 0C8h
		db	82h, 0C4h, 4Bh, 0C7h, 85h, 0C4h, 56h, 85h, 0C4h, 0C7h, 46h, 84h
		db	0C4h, 56h, 84h, 0C4h, 46h, 0CAh, 84h, 0D4h, 02h, 15h, 87h, 0C6h
		db	0Dh, 07h, 85h, 0C4h, 56h, 85h, 0C4h, 0C7h, 0C9h, 85h, 0C4h, 0CCh
		db	46h, 84h, 0C4h, 56h, 84h, 0C4h, 02h, 1Ah, 0C9h, 88h, 0C5h, 0C7h
		db	0C9h, 0CBh, 0C7h, 0C9h, 06h, 07h, 85h, 0C4h, 46h, 0CAh, 85h, 0C4h
		db	0CCh, 46h, 84h, 0C4h, 0C7h, 0C9h, 0C7h, 84h, 0C4h, 0CCh, 46h, 84h
		db	0C4h, 46h, 0C9h, 46h, 87h, 0C6h, 06h, 07h, 0CCh, 46h, 0C9h, 0C7h
		db	85h, 0C5h, 56h, 85h, 0C4h, 0C7h, 0C9h, 0CCh, 84h, 0C5h, 46h, 85h
		db	0C4h, 0C7h, 0CCh, 0C7h, 84h, 0C4h, 0C7h, 0CAh, 0C7h, 0CCh, 46h, 88h
		db	0C4h, 09h, 07h, 85h, 0C5h, 56h, 85h, 0C4h, 0CAh, 46h, 84h, 0C4h
		db	56h, 84h, 0C4h, 56h, 84h, 0C5h, 46h, 0CBh, 0C9h, 0CCh, 46h, 87h
		db	0C6h, 0C7h, 85h, 0C5h, 0C7h, 0CAh, 0C7h, 85h, 0C4h, 0C9h, 0CCh, 86h
		db	0C4h, 0C7h, 46h, 84h, 0C5h, 56h, 84h, 0C4h, 46h, 0CCh, 84h, 0C4h
		db	56h, 0CCh, 0C7h, 0CAh, 46h, 8Dh, 0C5h, 46h, 86h, 0C4h, 56h, 85h
		db	0C4h, 0C7h, 0C7h, 85h, 0C4h, 0CCh, 46h, 84h, 0C4h, 56h, 84h, 0C4h
		db	46h, 0CAh, 0C7h, 0CBh, 0C7h, 0CCh, 46h, 50h, 51h, 50h, 41h, 81h
		db	0C4h, 56h, 85h, 0C4h, 0CAh, 0CCh, 0C7h, 85h, 0C4h, 0C7h, 0C7h, 85h
		db	0C4h, 0CAh, 46h, 84h, 0C4h, 0C7h, 0CAh, 0C7h, 84h, 0C4h, 07h, 07h
		db	8Dh, 0C4h, 46h, 0CAh, 85h, 0C4h, 56h, 85h, 0C5h, 0C7h, 46h, 84h
		db	0C4h, 0C9h, 46h, 84h, 0C4h, 0C9h, 46h, 84h, 0C5h, 0C7h, 0C9h, 06h
		db	07h, 0CCh, 56h, 0CAh, 46h, 85h, 0C4h, 46h, 86h, 0C4h, 56h, 85h
		db	0C4h, 0C7h, 46h, 84h, 0C4h, 46h, 85h, 0C5h, 56h, 84h, 0C4h, 46h
		db	0CCh, 66h, 0C9h, 08h, 07h, 84h, 0C4h, 46h, 86h, 0C4h, 56h, 85h
		db	0C4h, 0C7h, 0C7h, 0C8h, 84h, 0C4h, 56h, 84h, 0C4h, 4Bh, 0C7h, 84h
		db	0C4h, 76h, 0CCh, 05h, 07h, 0CCh, 0C9h, 46h, 0CAh, 84h, 0C4h, 4Bh
		db	0C8h, 85h, 0C4h, 46h, 86h, 0C4h, 0C9h, 0CAh, 0C7h, 84h, 0C4h, 56h
		db	84h, 0C4h, 0C7h, 0CCh, 0CBh, 84h, 0C6h, 0C7h, 81h, 46h, 84h, 46h
		db	0CAh, 0C9h, 0CCh, 56h, 85h, 0C4h, 56h, 85h, 0C4h, 56h, 85h, 0C4h
		db	0C7h, 46h, 84h, 0C4h, 56h, 84h, 0C4h, 46h, 94h, 0C4h, 46h, 84h
		db	0C4h, 46h, 0C8h, 85h, 0C5h, 0C9h, 0CCh, 0C7h, 85h, 0C4h, 0C7h, 46h
		db	84h, 0C4h, 56h, 84h, 0C4h, 46h, 0C1h, 41h, 40h, 51h, 40h, 0C2h
		db	50h, 41h, 0C1h, 41h, 81h, 0C4h, 0CCh, 85h, 0C4h, 0C9h, 0C7h, 86h
		db	0C4h, 0CAh, 4Bh, 85h, 0C4h, 0C7h, 0C7h, 0CCh, 84h, 0C4h, 0C7h, 0C9h
		db	0C7h, 84h, 0C6h, 81h, 0C7h, 94h, 0C4h, 46h, 84h, 0C4h, 46h, 86h
		db	0C4h, 56h, 85h, 0C4h, 0CAh, 46h, 84h, 0C4h, 0C7h, 0CAh, 0C7h, 9Bh
		db	0C4h, 46h, 84h, 0C5h, 56h, 85h, 0C4h, 46h, 86h, 0C4h, 0C7h, 46h
		db	84h, 0C5h, 0CCh, 46h, 9Bh, 0C4h, 0C7h, 85h, 0C4h, 4Bh, 0C7h, 85h
		db	0C4h, 56h, 85h, 0C5h, 0C7h, 46h, 84h, 0C4h, 0CCh, 46h, 9Bh, 0C6h
		db	86h, 0C4h, 56h, 85h, 0C4h, 56h, 85h, 0C5h, 0C7h, 46h, 84h, 0C4h
		db	56h, 81h, 56h, 0C9h, 83h, 0C9h, 56h, 96h, 0C4h, 56h, 85h, 0C4h
		db	0C9h, 0CCh, 0CAh, 85h, 0C4h, 0C7h, 0C9h, 0C8h, 84h, 0C4h, 0C7h, 4Bh
		db	09h, 07h, 0C9h, 46h, 95h, 0C4h, 49h, 0CCh, 85h, 0C4h, 56h, 85h
		db	0C4h, 0CAh, 46h, 84h, 0C4h, 46h, 0CCh, 0C7h, 0CAh, 56h, 0CBh, 06h
		db	07h, 95h, 0C5h, 46h, 81h, 0CBh, 84h, 0C5h, 46h, 0CCh, 85h, 0C4h
		db	0C7h, 46h, 84h, 0C4h, 0C9h, 06h, 07h, 0C9h, 0C7h, 0CCh, 46h, 0CBh
		db	0C7h, 86h, 0C3h, 46h, 8Dh, 0C4h, 0C7h, 0C9h, 0C7h, 0C8h, 84h, 0C4h
		db	56h, 85h, 0C4h, 0C7h, 46h, 84h, 0C4h, 08h, 07h, 0CCh, 66h, 87h
		db	0C4h, 56h, 8Ch, 0C4h, 56h, 85h, 0C4h, 56h, 85h, 0C4h, 0C9h, 46h
		db	84h, 0C5h, 0CCh, 08h, 07h, 0CAh, 66h, 86h, 0C4h, 0C9h, 0CCh, 8Dh
		db	0C5h, 46h, 0CCh, 0C8h, 84h, 0C6h, 81h, 0C7h, 0C8h, 85h, 0C4h, 0C7h
		db	0C7h, 0C8h, 84h, 0C5h, 66h, 0C9h, 07h, 07h, 88h, 0C5h, 56h, 8Ch
		db	0C5h, 66h, 8Dh, 0C4h, 0C7h, 4Bh, 84h, 0C4h, 0Ah, 07h, 8Ah, 0C4h
		db	46h, 0CCh, 8Ch, 0C4h, 0C7h, 0CCh, 0C7h, 8Eh, 0C4h, 0CAh, 0C7h, 0CCh
		db	84h, 0C4h, 0C7h, 81h, 46h, 0CAh, 0CCh, 66h, 81h, 0C7h, 89h, 0C4h
		db	56h, 8Ch, 0C4h, 56h, 8Eh, 0C5h, 0C7h, 46h, 84h, 0C6h, 83h, 0C4h
		db	46h, 0CCh, 0C7h, 0CCh, 46h, 8Ah, 0C4h, 46h, 8Dh, 0C4h, 0CAh, 46h
		db	8Eh, 0C4h, 0C7h, 46h, 88h, 0C4h, 66h, 0C9h, 0C7h, 8Bh, 0C4h, 56h
		db	8Ch, 0C4h, 56h, 8Eh, 0C4h, 0C7h, 46h, 88h, 0C5h, 05h, 07h, 8Bh
		db	0C4h, 0C9h, 0CCh, 0CBh, 8Ch, 0C4h, 0C7h, 0C9h, 0C8h, 8Eh, 0C4h, 0C7h
		db	46h, 88h, 0C4h, 05h, 07h, 8Bh, 0C5h, 46h, 0C8h, 8Ch, 0C4h, 46h
		db	0C8h, 8Eh, 0C4h, 0C7h, 0CAh, 89h, 0C4h, 05h, 07h, 8Bh, 0C5h, 46h
		db	0C8h, 83h, 0C3h, 46h, 0C8h, 85h, 0C4h, 0C9h, 46h, 8Eh, 0C4h, 0CCh
		db	46h, 88h, 0C4h, 0CCh, 56h, 0CCh, 0C7h, 41h, 0C1h, 0C2h, 40h, 41h
		db	40h, 81h, 0C4h, 46h, 84h, 0C5h, 0CCh, 46h, 0C8h, 84h, 0C5h, 56h
		db	0C8h, 8Dh, 0C5h, 0C7h, 46h, 88h, 0C5h, 0CCh, 76h, 8Bh, 0C4h, 46h
		db	84h, 0C4h, 0CAh, 0CCh, 0C7h, 85h, 0C4h, 66h, 8Dh, 0C4h, 0C7h, 0C9h
		db	0C7h, 88h, 0C4h, 0C7h, 0CCh, 56h, 86h, 0C3h, 85h, 0CAh, 0C7h, 85h
		db	0C4h, 56h, 0C8h, 84h, 0C4h, 0C7h, 0CAh, 0CBh, 8Eh, 0C5h, 0C7h, 46h
		db	88h, 0C4h, 76h, 86h, 0C4h, 0C7h, 81h, 05h, 07h, 84h, 0C5h, 66h
		db	84h, 0C5h, 56h, 8Eh, 0C4h, 0C7h, 46h, 88h, 0C4h, 0C7h, 0C9h, 46h
		db	87h, 0C4h, 56h, 0C9h, 56h, 0C8h, 84h, 0C4h, 0C7h, 0CAh, 0CCh, 0CBh
		db	84h, 0C4h, 56h, 8Eh, 0C4h, 0C7h, 46h, 88h, 0C6h, 46h, 81h, 0C7h
		db	87h, 0C4h, 0CAh, 4Bh, 66h, 85h, 0C4h, 46h, 0C9h, 0C7h, 84h, 0C4h
		db	0C7h, 0C9h, 0CCh, 8Eh, 0C4h, 0C7h, 0CCh, 0C7h, 94h, 0C4h, 06h, 07h
		db	85h, 0C4h, 0C9h, 56h, 84h, 0C6h, 81h, 0C7h, 86h, 0C3h, 81h, 46h
		db	85h, 0C4h, 0C9h, 0CCh, 0C7h, 94h, 0C5h, 66h, 0C9h, 0C7h, 0C8h, 85h
		db	0C4h, 0CCh, 46h, 0C9h, 8Dh, 0C4h, 46h, 0CCh, 85h, 0C4h, 0CCh, 46h
		db	85h, 0C3h, 0C7h, 81h, 46h, 8Ah, 0C4h, 46h, 0CAh, 0CCh, 0C7h, 0C8h
		db	86h, 0C5h, 66h, 8Dh, 0C5h, 0CCh, 46h, 85h, 0C4h, 0C7h, 46h, 85h
		db	0C4h, 76h, 83h, 0C3h, 46h, 81h, 56h, 0C9h, 46h, 89h, 0C5h, 0CAh
		db	0CCh, 46h, 8Dh, 0C5h, 0C7h, 0C9h, 0C7h, 85h, 0C4h, 0C7h, 0C9h, 0C7h
		db	85h, 0C4h, 56h, 0CAh, 46h, 82h, 0C6h, 0C7h, 0CCh, 0C7h, 0C9h, 66h
		db	8Ah, 0C4h, 05h, 07h, 0C8h, 8Ah, 0C4h, 0C7h, 4Bh, 85h, 0C4h, 0C7h
		db	0CAh, 0CCh, 85h, 0C5h, 0CAh, 0CCh, 56h, 0C8h, 83h, 0C4h, 0C7h, 4Bh
		db	0C7h, 0CAh, 46h, 8Ah, 0C4h, 06h, 07h, 8Ah, 0C4h, 56h, 85h, 0C4h
		db	0C7h, 01h, 00h, 22h, 7Dh, 00h, 23h, 95h, 00h, 2Bh, 0B6h, 00h
		db	3Ch, 0B7h, 00h, 16h, 0E3h, 00h, 0Eh, 0FAh, 00h, 15h, 0FBh, 00h
		db	2Ch, 0FFh, 0FFh, 48h, 00h, 1Dh, 4Bh, 00h, 1Eh, 4Eh, 00h, 1Fh
		db	0B1h, 00h, 2Bh, 0FFh, 0FFh, 19h, 80h, 0A1h, 16h, 00h, 2Ch, 00h
		db	5Eh, 80h, 0B8h, 51h, 00h, 6Ah, 00h, 81h, 80h, 8Fh, 7Bh, 00h
		db	87h, 00h, 90h, 80h, 0B6h, 7Dh, 00h, 0A4h, 00h, 0CAh, 80h, 9Eh
		db	0BDh, 00h, 0D6h, 00h, 0E8h, 40h, 0A5h, 0E6h, 00h, 0F0h, 00h, 0F1h
		db	40h, 0B6h, 0EBh, 00h, 0F8h, 00h, 0F4h, 40h, 88h, 0EEh, 00h, 0F9h
		db	00h, 0FFh, 0FFh, 39h, 00h, 05h, 0C2h, 16h, 32h, 00h, 0Eh, 00h
		db	0FFh, 0FFh, 0FFh, 39h, 00h, 0Fh, 03h, 19h, 66h, 00h, 35h, 00h
		db	43h, 00h, 40h, 39h, 00h, 22h, 81h, 18h, 23h, 00h, 2Bh, 00h
		db	0FFh, 0FFh, 0FFh, 39h, 00h, 2Eh, 84h, 18h, 0Ah, 00h, 34h, 00h
		db	0FFh, 0FFh, 0FFh, 39h, 00h, 39h, 0C0h, 10h, 28h, 00h, 25h, 00h
		db	0FFh, 0FFh, 0FFh, 6Fh, 00h, 14h, 80h, 08h, 04h, 00h, 0FFh, 00h
		db	0FFh, 0FFh, 0FFh, 75h, 00h, 1Fh, 83h, 18h, 99h, 00h, 2Ch, 00h
		db	0FFh, 0FFh, 0FFh, 0A6h, 00h, 1Eh, 84h, 19h, 1Ah, 00h, 12h, 00h
		db	0FFh, 0FFh, 0FFh, 0A9h, 00h, 12h, 80h, 18h, 0ECh, 00h, 04h, 00h
		db	0FFh, 0FFh, 0FFh, 0B9h, 00h, 01h, 81h, 1Ah, 1Dh, 00h, 34h, 00h
		db	0FFh, 0FFh, 0FFh, 0FAh, 00h, 1Fh, 80h, 19h, 14h, 00h, 09h, 00h
		db	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 42h, 00h, 80h, 35h, 0D9h, 00h, 00h
		db	0FFh, 0FFh, 42h, 00h, 40h, 95h, 0D9h, 00h, 00h, 0FFh, 0FFh, 42h
		db	00h, 20h, 05h, 0DAh, 00h, 00h, 0FFh, 0FFh, 42h, 00h, 10h, 3Ch
		db	0DAh, 00h, 0FFh, 47h, 0DAh, 0FFh, 0FFh, 0FFh, 0FFh, 42h, 00h, 08h
		db	0BCh, 0DAh, 00h, 0FFh, 0C7h, 0DAh, 0FFh, 0FFh, 0FFh, 0FFh, 42h, 00h
		db	04h, 0FCh, 0DAh, 00h, 0FFh, 07h, 0DBh, 0FFh, 0FFh, 0FFh, 0FFh, 42h
		db	00h, 02h, 4Ch, 0DBh, 00h, 0FFh, 57h, 0DBh, 0FFh, 0FFh, 0FFh, 0FFh
		db	42h, 00h, 01h, 0BCh, 0DBh, 00h, 0FFh, 0C7h, 0DBh, 0FFh, 0FFh, 0FFh
		db	0FFh, 43h, 00h, 80h, 0CCh, 0DBh, 00h, 0FFh, 0D7h, 0DBh, 0FFh, 0FFh
		db	0FFh, 0FFh, 43h, 00h, 40h, 0B9h, 0D7h, 83h, 19h, 0FFh, 0FFh, 0FFh
		db	0FFh, 16h, 0AFh, 04h, 0Fh
		db	'Cavern of Absor'

; ------------------------------------------------------------------
; script_trailer -- event / exit-trigger script bytes.
; Processed by the map-event interpreter when the player steps on
; a trigger cell. Variable-length records terminated by 0xFFFF.
; ------------------------------------------------------------------

script_trailer:
		db	17h, 00h, 07h, 0Eh, 0Eh, 02h, 00h, 26h, 0FFh, 02h, 00h, 00h
		db	00h, 00h, 00h, 00h, 02h, 00h, 26h, 02h, 00h, 04h, 00h, 02h
		db	0FFh, 00h, 00h, 00h, 10h, 00h, 00h, 00h, 04h, 00h, 02h, 00h
		db	00h, 04h, 00h, 04h, 0FFh, 01h, 00h, 00h, 10h, 00h, 00h, 00h
		db	04h, 00h, 04h, 01h, 00h, 0Ah, 00h, 26h, 0FFh, 02h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0Ah, 00h, 26h, 02h, 00h, 12h, 00h, 14h
		db	0FFh, 00h, 00h, 00h, 10h, 00h, 00h, 00h, 12h, 00h, 14h, 00h
		db	00h, 12h, 00h, 16h, 0FFh, 01h, 00h, 00h, 10h, 00h, 00h, 00h
		db	12h, 00h, 16h, 01h, 00h, 13h, 00h, 0Ch, 0FFh, 02h, 00h, 00h
		db	00h, 00h, 00h, 00h, 13h, 00h, 0Ch, 02h, 00h, 15h, 00h, 07h
		db	0FFh, 0D0h, 00h, 00h, 20h, 00h, 19h, 00h, 42h, 00h, 80h, 0Dh
		db	00h, 15h, 00h, 24h, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	15h, 00h, 24h, 03h, 00h, 21h, 00h, 3Bh, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 21h, 00h, 3Bh, 03h, 00h, 27h, 00h, 37h
		db	0FFh, 04h, 00h, 00h, 00h, 00h, 00h, 00h, 27h, 00h, 37h, 04h
		db	00h, 29h, 00h, 24h, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	29h, 00h, 24h, 03h, 00h, 29h, 00h, 3Bh, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 29h, 00h, 3Bh, 03h, 00h, 2Eh, 00h, 01h
		db	0FFh, 0D0h, 00h, 00h, 20h, 00h, 19h, 00h, 42h, 00h, 40h, 0Dh
		db	00h, 2Fh, 00h, 2Eh, 0FFh, 00h, 00h, 00h, 10h, 00h, 00h, 00h
		db	2Fh, 00h, 2Eh, 00h, 00h, 2Fh, 00h, 30h, 0FFh, 01h, 00h, 00h
		db	10h, 00h, 00h, 00h, 2Fh, 00h, 30h, 01h, 00h, 30h, 00h, 11h
		db	0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h, 30h, 00h, 11h, 03h
		db	00h, 33h, 00h, 1Ah, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	33h, 00h, 1Ah, 03h, 00h, 3Bh, 00h, 1Ah, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 3Bh, 00h, 1Ah, 03h, 00h, 44h, 00h, 11h
		db	0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h, 44h, 00h, 11h, 03h
		db	00h, 49h, 00h, 2Bh, 0FFh, 0D0h, 00h, 00h, 20h, 00h, 19h, 00h
		db	42h, 00h, 20h, 00h, 00h, 4Dh, 00h, 27h, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 4Dh, 00h, 27h, 03h, 00h, 55h, 00h, 27h
		db	0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h, 55h, 00h, 27h, 03h
		db	00h, 68h, 00h, 0Bh, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	68h, 00h, 0Bh, 03h, 00h, 75h, 00h, 34h, 0FFh, 73h, 00h, 04h
		db	20h, 00h, 00h, 00h, 42h, 00h, 10h, 00h, 00h, 77h, 00h, 28h
		db	0FFh, 04h, 00h, 00h, 00h, 00h, 00h, 00h, 77h, 00h, 28h, 04h
		db	00h, 79h, 00h, 16h, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	79h, 00h, 16h, 03h, 00h, 7Dh, 00h, 21h, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 7Dh, 00h, 21h, 03h, 00h, 80h, 00h, 00h
		db	0FFh, 02h, 00h, 00h, 00h, 00h, 00h, 00h, 80h, 00h, 00h, 02h
		db	00h, 83h, 00h, 2Ah, 0FFh, 04h, 00h, 00h, 00h, 00h, 00h, 00h
		db	83h, 00h, 2Ah, 04h, 00h, 88h, 00h, 00h, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 88h, 00h, 00h, 03h, 00h, 93h, 00h, 16h
		db	0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h, 93h, 00h, 16h, 03h
		db	00h, 96h, 00h, 07h, 0FFh, 77h, 00h, 00h, 20h, 00h, 00h, 00h
		db	42h, 00h, 08h, 00h, 00h, 99h, 00h, 16h, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 99h, 00h, 16h, 03h, 00h, 0A2h, 00h, 00h
		db	0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h, 0A2h, 00h, 00h, 03h
		db	00h, 0A9h, 00h, 33h, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0A9h, 00h, 33h, 03h, 00h, 0AAh, 00h, 29h, 0FFh, 73h, 00h, 05h
		db	20h, 00h, 00h, 00h, 42h, 00h, 04h, 00h, 00h, 0B3h, 00h, 20h
		db	0FFh, 02h, 00h, 00h, 00h, 00h, 00h, 00h, 0B3h, 00h, 20h, 02h
		db	00h, 0B7h, 00h, 20h, 0FFh, 02h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0B7h, 00h, 20h, 02h, 00h, 0BAh, 00h, 0Ah, 0FFh, 00h, 00h, 00h
		db	10h, 00h, 00h, 00h, 0BAh, 00h, 0Ah, 00h, 00h, 0BAh, 00h, 0Ch
		db	0FFh, 01h, 00h, 00h, 10h, 00h, 00h, 00h, 0BAh, 00h, 0Ch, 01h
		db	00h, 0BBh, 00h, 19h, 0FFh, 73h, 00h, 05h, 20h, 00h, 00h, 00h
		db	42h, 00h, 02h, 00h, 00h, 0BBh, 00h, 29h, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0BBh, 00h, 29h, 03h, 00h, 0BFh, 00h, 1Fh
		db	0FFh, 02h, 00h, 00h, 00h, 00h, 00h, 00h, 0BFh, 00h, 1Fh, 02h
		db	00h, 0C5h, 00h, 04h, 0FFh, 02h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0C5h, 00h, 04h, 02h, 00h, 0C7h, 00h, 1Fh, 0FFh, 02h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0C7h, 00h, 1Fh, 02h, 00h, 0CBh, 00h, 04h
		db	0FFh, 02h, 00h, 00h, 00h, 00h, 00h, 00h, 0CBh, 00h, 04h, 02h
		db	00h, 0D0h, 00h, 31h, 0FFh, 04h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0D0h, 00h, 31h, 04h, 00h, 0D1h, 00h, 14h, 0FFh, 73h, 00h, 03h
		db	20h, 00h, 00h, 00h, 42h, 00h, 01h, 00h, 00h, 0D1h, 00h, 2Ah
		db	0FFh, 73h, 00h, 04h, 20h, 00h, 00h, 00h, 43h, 00h, 80h, 00h
		db	00h, 0D3h, 00h, 0Ch, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0D3h, 00h, 0Ch, 03h, 00h, 0D5h, 00h, 02h, 0FFh, 00h, 00h, 00h
		db	10h, 00h, 00h, 00h, 0D5h, 00h, 02h, 00h, 00h, 0D5h, 00h, 04h
		db	0FFh, 01h, 00h, 00h, 10h, 00h, 00h, 00h, 0D5h, 00h, 04h, 01h
		db	00h, 0DBh, 00h, 33h, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0DBh, 00h, 33h, 03h, 00h, 0E4h, 00h, 3Ah, 0FFh, 00h, 00h, 00h
		db	10h, 00h, 00h, 00h, 0E4h, 00h, 3Ah, 00h, 00h, 0E4h, 00h, 3Ch
		db	0FFh, 01h, 00h, 00h, 10h, 00h, 00h, 00h, 0E4h, 00h, 3Ch, 01h
		db	00h, 0E5h, 00h, 16h, 0FFh, 0D0h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh, 0FFh, 0FFh, 00h, 00h, 0EBh, 00h, 2Ah, 0FFh, 03h, 00h, 00h
		db	00h, 00h, 00h, 00h, 0EBh, 00h, 2Ah, 03h, 00h, 0FCh, 00h, 0Dh
		db	0FFh, 0D0h, 00h, 00h, 00h, 00h, 00h, 00h, 0FFh, 0FFh, 0FFh, 00h
		db	00h, 0FFh, 00h, 33h, 0FFh, 03h, 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh, 00h, 33h, 03h, 00h, 0FFh, 0FFh

map_mp80	endp

seg_a		ends

		end	start
