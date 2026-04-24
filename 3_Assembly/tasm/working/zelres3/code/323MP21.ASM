
PAGE  59,132

;==========================================================================
;
;  323MP21 - Map Data Table: Cavern of Peligro, level 2, floor 1
;
;  Cavern/labyrinth map resource file loaded as MP21.MDT (zelres3).
;  Part of the 16-file MP{level}{floor} dungeon-map set (320..335) covering
;  levels 1-6 of the Zeliard labyrinth.
;
;  NOT executable code -- Sourcer mis-decoded the header bytes and data
;  tables as x86 instructions (the first two bytes are really the file
;  size word, not 'cmp [bp+si],al' etc).  The bogus mnemonics below all
;  re-emit the same byte sequence.
;
;  General MDT layout (all files in this group share this pattern):
;    [0x00]   file-size word + flag/reserved word
;    [0x04+]  pointer table (WORDs 0xCNNN - runtime segment 0xC000)
;            -> tile grid, event table, exit table, script trailer
;    [mid]    tile_grid            - column/row-strip tile-index data
;                                    (values like 0x3F06, 0xC4NN, 0xC5NN)
;    [later]  event_records        - NPC/door/exit records (FF-terminated)
;    [late]   cavern_name          - pascal-encoded 'Cavern of Peligro'
;    [end]    exit/trigger records - door warp coords + script bytes
;    [eof]    terminator           - 0xFFFFFFFF (header_1 label)
;
;  Runtime segment base = 0xC000.  Pointer 0xCNNN resolves to file_off NNN.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_2e		equ	0C5CAh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_323MP21	proc	far


; ------------------------------------------------------------------
; mdt_header -- file-size word, flag byte, and table of WORD pointers
; into the runtime 0xC000 segment.  Sourcer mis-decoded the leading
; bytes as instructions; they are actually: size word + flag word
; + attributes pointer + offset of 'strategy' (tile grid start) + ...
; ------------------------------------------------------------------
start:
;*		aam	0Bh			; undocumented inst

; ------------------------------------------------------------------
; tile_grid -- main cavern/map tile-index data.  Encoded as column
; or row strips of 1-byte tile indices.  Common runs: 0x3F06 (wall
; boundary), 0x2C06 (column separator), plus palette-range values
; (0xC4-0xCC) that select tile rows in the tile bank.  Originally
; labeled 'strategy' by Sourcer because the header pointer landed
; on this offset.
; ------------------------------------------------------------------
		db	0D4h, 0Bh		;  Fixup - byte match
		add	[bx+si],al
		cmp	ax,60CBh
		add	ds:data_2e[di],bh
		retf	0CAC7h
		db	0DEh,0CAh, 10h,0CBh, 28h,0CBh
		db	 42h,0CBh, 02h,0FFh,0FFh, 00h
		db	 0Ah, 00h, 00h,0BDh,0CAh, 88h
		db	0C5h, 47h,0C9h,0CCh, 84h,0C5h
		db	0C9h,0C8h, 58h,0CCh, 8Ah,0C5h
		db	 78h, 47h,0C9h,0C7h, 58h,0CBh
		db	0CCh, 8Bh,0C6h,0CCh, 82h, 82h
		db	0C3h,0CCh, 84h,0C4h,0C9h,0CBh
		db	0C9h,0CCh, 84h,0C5h, 47h,0C7h
		db	0C9h,0CCh, 8Bh,0C5h,0C8h,0C9h
		db	0CBh,0CCh,0C9h,0CAh, 68h,0CBh
		db	0CDh, 91h, 82h,0C4h,0CCh, 84h
		db	0C4h,0CCh,0C3h,0CCh,0CEh, 84h
		db	0C5h,0C8h, 48h,0CCh,0C9h,0CCh
		db	0CEh, 89h,0C6h,0CDh, 83h,0C9h
		db	 49h,0C9h,0C8h,0C9h,0CCh, 81h
		db	0CEh, 90h, 82h,0C4h,0CCh, 84h
		db	0C4h, 58h,0CCh, 84h,0C4h, 78h
		db	0CCh, 8Fh,0C4h, 59h, 47h,0C9h
		db	0CCh, 91h, 82h,0C4h,0CCh, 84h
		db	0C4h,0C8h,0C7h,0C9h,0CCh, 84h
		db	0C4h, 58h, 47h,0CDh, 40h, 41h
		db	 60h,0C2h, 40h,0C2h,0C1h, 82h
		db	0C4h,0CAh, 67h, 58h,0CCh,0CEh
		db	 8Eh, 82h,0C4h,0CCh, 84h,0C4h
		db	 57h,0CCh, 84h,0C4h,0C9h, 47h
		db	0C9h,0CCh, 90h,0C4h,0CAh,0C9h
		db	0CAh, 58h,0C7h, 48h,0CCh, 81h
		db	0CEh, 8Ch, 82h,0C5h,0CCh, 84h
		db	0C4h, 47h,0CCh, 85h,0C4h, 57h
		db	 48h,0CCh, 81h,0CEh, 8Dh,0C4h
		db	0C8h, 48h,0C8h, 06h, 09h,0CDh
		db	 8Ch, 82h,0C5h,0CCh, 84h,0C4h
		db	0C9h,0CCh, 81h,0CEh, 84h,0C4h
		db	0C9h,0C7h,0C8h, 78h,0CCh, 8Ch
		db	0C4h,0C8h, 58h,0C7h, 05h, 09h
		db	0C8h,0C9h,0CCh, 8Ah, 82h,0C4h
		db	0CDh, 84h,0C5h,0CCh,0C3h,0CDh
		db	 85h,0C4h, 47h, 78h,0C7h,0C9h
		db	0CCh,0CEh, 8Ah,0C4h,0CAh, 07h
		db	 09h, 77h,0C9h,0CDh, 88h, 81h
		db	0C3h,0C4h,0CCh, 84h,0C5h,0C7h
		db	0C8h,0CCh,0CEh, 84h,0C5h, 47h
		db	 48h, 47h, 06h, 09h,0CDh, 87h
		db	0C4h, 48h,0C8h, 48h,0CBh, 58h
		db	 47h,0C7h,0C8h,0C9h,0C4h,0CCh
		db	 88h,0C3h, 49h,0CDh, 84h,0C5h
		db	0C8h,0C9h,0CDh, 85h,0C5h, 0Ah
		db	 09h,0CBh,0CDh, 88h,0C5h, 08h
		db	 09h,0CCh, 83h,0C6h,0C5h,0C9h
		db	0CDh, 87h,0C4h,0CAh,0CCh, 85h
		db	0C5h, 58h,0CCh, 84h,0C5h, 48h
		db	0C7h, 78h, 47h,0C9h,0CCh, 89h
		db	0C5h, 57h, 78h,0CCh, 85h,0C5h
		db	0CBh,0CCh, 87h,0C4h,0CAh,0CCh
		db	 85h,0C5h,0C8h, 48h,0CDh, 84h
		db	0C5h,0C7h, 68h,0C8h,0C7h,0C8h
		db	0C9h,0CCh,0CEh, 8Ah,0C5h,0C8h
		db	 06h, 09h,0CCh, 85h,0C5h,0CCh
		db	 88h,0C6h,0C9h,0CBh,0CCh, 84h
		db	0C5h,0C8h,0C9h,0C7h,0CCh, 84h
		db	0C5h, 78h,0C8h,0C9h,0C8h,0CCh
		db	 8Ch,0C5h,0C9h,0C7h, 78h,0C8h
		db	0CCh, 85h,0C4h,0CDh, 40h,0C2h
		db	0C1h, 84h, 81h,0C6h,0CBh,0CCh
		db	 84h,0C5h, 47h,0C9h,0CCh,0CEh
		db	 83h,0C5h, 68h,0C7h,0C8h,0CCh
		db	 8Eh,0C5h, 06h, 09h,0C8h,0CCh
		db	 85h,0C4h,0C9h,0CCh, 87h, 82h
		db	0C5h,0CCh, 84h,0C4h, 47h,0CCh
		db	 85h,0C5h, 48h, 67h,0C9h,0CDh
		db	 8Dh,0C5h,0C9h,0C8h,0C9h,0C8h
		db	 58h,0CCh, 86h,0C4h,0CCh,0C9h
		db	0CAh,0CCh, 85h, 82h,0C6h,0CDh
		db	 84h,0C4h,0C8h, 48h,0CDh, 84h
		db	0C5h, 48h, 57h, 58h,0CDh, 8Ch
		db	0C4h, 07h, 09h,0CCh, 85h,0C5h
		db	 48h,0C8h,0CAh,0CCh, 84h, 88h
		db	0C4h, 47h,0C9h,0CCh, 84h,0C5h
		db	 48h,0C7h,0C8h, 48h,0CCh, 81h
		db	0CEh, 8Ch,0C5h,0C8h, 48h, 82h
		db	0C9h, 47h,0CCh, 85h,0C5h, 57h
		db	0C7h,0CAh,0CBh,0CCh, 82h, 88h
		db	0C4h,0C8h,0CCh,0CEh, 85h,0C5h
		db	 47h, 58h,0CCh,0CEh, 8Eh,0C5h
		db	0C8h, 48h, 82h,0C9h,0C8h,0C7h
		db	0C9h,0CCh, 84h,0C5h,0C8h,0C9h
		db	0C7h, 48h,0CCh, 83h, 88h,0C4h
		db	 47h,0C7h,0CCh, 84h,0C4h, 68h
		db	0CCh, 90h,0C4h,0C9h,0CCh, 83h
		db	0C5h, 48h,0CCh, 85h,0C5h, 48h
		db	0CAh,0CCh,0CEh, 84h, 84h,0C3h
		db	0C8h,0CAh, 57h,0C9h,0CCh, 85h
		db	0C4h,0C9h,0C7h,0C9h,0C8h,0CCh
		db	0CEh, 8Fh,0C4h,0C9h,0CCh, 83h
		db	0C5h, 48h,0CCh, 85h,0C5h,0C8h
		db	 58h,0CDh, 84h, 84h,0C4h,0CAh
		db	0C7h,0CAh,0C8h,0C9h,0CCh, 81h
		db	0CEh, 84h,0C4h, 58h,0C8h,0C9h
		db	0CCh, 8Fh,0C4h,0CCh, 84h,0C5h
		db	0C9h,0CCh,0CEh, 85h,0C5h, 67h
		db	0CDh, 84h, 84h,0C4h, 59h,0C8h
		db	 46h,0CCh, 85h,0C4h, 05h, 09h
		db	0CCh, 8Eh,0C4h,0CCh, 84h,0C5h
		db	0C9h,0CCh, 86h,0C5h, 57h,0CCh
		db	 85h, 84h,0C4h, 59h,0C8h, 48h
		db	0CCh, 85h,0C4h,0CAh,0C8h, 78h
		db	0CBh,0CDh, 8Bh,0C3h,0C9h,0CDh
		db	 84h,0C4h,0C9h,0CCh,0CEh, 85h
		db	0C4h,0C8h,0C7h,0CAh,0CCh, 85h
		db	 84h,0C4h,0C8h, 49h,0C8h,0C9h
		db	0CCh, 86h,0C4h,0CAh,0C9h,0C8h
		db	0C7h,0C8h, 48h,0CCh, 8Ch,0C4h
		db	0CAh,0CCh, 84h,0C4h, 48h,0CCh
		db	 85h,0C4h,0C8h,0C9h,0CAh,0CCh
		db	0CEh, 84h, 84h, 47h,0C9h,0CAh
		db	0C9h,0CDh, 81h,0CEh, 85h,0C4h
		db	0CAh,0C8h,0C7h,0C8h,0C9h,0CCh
		db	0CEh, 8Ch,0C3h,0C4h,0CDh, 81h
		db	0CEh, 83h,0C4h,0C9h,0C8h,0CCh
		db	 85h,0C4h, 48h,0CAh,0CBh,0CCh
		db	 84h, 84h, 68h,0CDh, 88h,0C4h
		db	0CAh,0C8h,0C9h,0CCh,0CEh, 8Eh
		db	0C4h,0C9h,0CDh, 85h,0C4h,0C9h
		db	0C8h,0CCh, 85h,0C4h, 48h, 59h
		db	0CCh, 83h, 84h
data_1		db	0CAh
		db	0C9h,0CBh,0CDh, 89h,0C4h,0CAh
		db	 47h,0CCh, 8Eh,0C3h,0C9h,0C8h
		db	0CDh, 85h,0C5h,0C8h,0C7h,0C9h
		db	0CCh, 84h,0C4h, 48h, 49h,0CCh
		db	0CEh, 83h, 84h,0C8h,0C9h,0CCh
		db	 89h,0C3h,0C9h,0CAh,0C8h, 48h
		db	0CCh, 8Dh,0C4h,0C8h,0C9h,0CCh
		db	 85h,0C5h, 58h,0CCh, 84h,0C4h
		db	 57h,0CAh,0CDh, 84h, 84h,0C6h
		db	0CCh, 8Ah,0C4h, 48h,0C8h,0CAh
		db	0CDh, 81h,0CEh, 8Ch,0C4h,0C8h
		db	0C9h,0CDh,0CEh, 84h,0C5h, 58h
		db	0CCh, 84h,0C4h,0C9h,0C7h,0CAh
		db	0CCh, 85h, 90h,0C5h, 48h,0C8h
		db	0CAh, 68h,0CBh,0CDh, 89h,0C4h
		db	0C9h, 4Bh, 85h,0C5h,0C9h,0C8h
		db	0CCh,0CEh, 84h,0C4h, 47h,0CCh
		db	 86h, 90h,0C5h,0C8h,0C9h,0C8h
		db	0CAh,0C7h, 48h,0CCh, 8Bh,0C4h
		db	0C9h,0C8h,0CCh,0CEh, 84h,0C5h
		db	 48h,0CCh, 85h,0C4h,0C8h,0C9h
		db	0CDh, 86h, 90h,0C6h,0C4h,0C8h
		db	0C7h,0CAh,0C8h,0C9h,0CCh, 81h
		db	0CEh, 8Ah,0C4h,0C8h,0C9h,0CCh
		db	 85h,0C5h,0C8h,0C9h,0CCh, 85h
		db	0C4h, 48h,0CCh,0CEh, 85h, 8Eh
		db	0D2h,0D3h,0D4h,0C4h,0C9h,0C8h
		db	0CAh,0CBh,0CCh,0CEh, 8Ch,0C5h
		db	 58h,0CDh, 84h,0C5h,0C9h,0CCh
		db	 86h,0C4h, 48h,0CCh, 86h, 8Eh
		db	0D2h,0D3h,0D4h,0C4h,0C9h,0CAh
		db	0C9h,0CCh, 8Eh,0C5h,0C9h,0C8h
		db	0CCh, 85h,0C6h,0CCh, 87h,0C4h
		db	0C9h,0C7h,0CCh, 86h, 8Eh,0D2h
		db	0D3h,0D4h,0C4h, 49h,0C8h,0CDh
		db	0C1h, 41h, 50h,0C2h, 40h,0C2h
		db	0C1h, 82h,0C3h, 48h,0C8h,0CCh
		db	 8Eh,0C4h, 48h,0CAh,0CCh,0CEh
		db	 84h, 8Eh,0D2h,0D3h,0D4h,0C4h
		db	 49h,0C9h,0CCh, 8Dh,0C4h,0C9h
		db	0C7h,0C9h,0CDh, 40h,0C2h, 70h
		db	 41h,0C1h,0C2h,0C1h, 81h,0C4h
		db	0CCh,0C8h,0CAh,0CCh, 85h, 8Eh
		db	0D2h,0D3h,0D4h,0C4h, 49h,0C8h
		db	0CBh,0CCh, 86h,0D0h, 48h,0CCh
		db	 81h,0C3h,0C9h, 47h,0CBh,0CDh
		db	 8Eh,0C4h, 48h,0CAh,0CDh, 85h
		db	 8Eh,0D2h,0D3h,0D4h,0C4h, 49h
		db	0C8h,0CCh,0CEh, 85h,0D0h, 48h
		db	0C8h, 06h, 09h,0CDh,0CEh, 84h
		db	0C3h,0CCh, 87h,0C4h, 48h,0CCh
		db	 86h, 8Eh,0D2h,0D3h,0D4h,0C4h
		db	 49h,0C9h,0CCh, 85h,0D0h,0C9h
		db	 67h,0CAh,0C9h, 47h, 58h,0CDh
		db	 84h,0C4h, 48h,0CCh, 85h,0C4h
		db	0C9h,0C7h,0CCh, 81h,0CEh, 84h
		db	 8Eh,0D2h,0D3h,0D4h,0C5h, 49h
		db	0C9h,0CCh, 84h,0D0h,0C9h,0CAh
		db	0C9h,0CAh, 47h,0CAh,0C7h,0C8h
		db	 68h,0CCh, 84h,0C5h,0C9h,0C8h
		db	0CCh, 85h,0C4h, 48h,0CAh,0CCh
		db	 85h, 8Eh,0D2h,0D3h,0D4h,0C5h
		db	0CAh,0C9h,0CCh,0CEh, 84h,0C4h
		db	0C9h,0CAh,0C9h,0CAh,0C7h,0C9h
		db	 47h, 48h,0C7h,0C8h,0C9h,0CDh
		db	0CEh, 83h,0C4h,0C9h,0CCh,0CEh
		db	 85h,0C4h,0CBh,0CCh,0C3h, 49h
		db	0CCh, 83h, 8Eh,0D2h,0D3h,0D4h
		db	0C5h,0CAh,0C9h,0CCh, 85h,0C4h
		db	0C9h,0CAh, 58h,0CCh, 81h,0C6h
		db	 48h,0C8h,0C7h,0C9h,0CCh, 84h
		db	0C4h, 48h,0CCh, 85h,0C4h, 48h
		db	 49h,0CCh, 84h, 8Eh,0D2h,0D3h
		db	0D4h,0C5h,0CAh,0C8h,0CCh, 85h
		db	0C4h,0C9h,0C8h,0C9h,0CCh, 84h
		db	0C6h,0C9h, 47h,0CDh, 85h,0C4h
		db	 48h,0CCh,0CEh, 84h,0C4h, 48h
		db	0CAh,0CCh,0CEh, 84h, 8Eh,0D2h
		db	0D3h,0D4h,0C4h,0CAh,0C9h,0C8h
		db	0CCh, 84h,0C4h, 58h,0CCh, 85h
		db	0C5h,0C8h,0C9h,0CCh, 85h,0C5h
		db	 48h,0CCh, 85h,0C4h,0C9h, 47h
		db	0CCh, 85h, 84h,0C3h, 46h,0CDh
		db	 86h,0D2h,0D3h,0D4h,0C4h,0CAh
		db	0C8h, 4Bh, 84h,0C4h,0CAh,0C9h
		db	0CDh, 81h,0CEh, 84h,0C5h, 48h
		db	0CDh,0CEh, 84h,0C5h,0C9h,0CCh
		db	0CEh, 85h,0C5h,0C9h,0C8h,0CCh
		db	0CEh, 85h, 84h,0C4h, 58h,0CCh
		db	 85h,0D2h,0D3h,0D4h,0C4h,0CAh
		db	0C8h,0C9h,0CCh, 84h,0C4h,0CAh
		db	0C9h,0CCh, 86h,0C4h,0C9h,0CCh
		db	 86h,0C5h,0C9h,0CBh,0CCh, 85h
		db	0C5h, 47h, 48h,0CCh, 84h, 84h
		db	0C4h, 58h,0CDh,0CEh, 86h,0C4h
		db	0C9h,0CAh,0C8h,0C9h,0CCh,0CEh
		db	 83h,0C4h,0CAh, 58h,0CCh, 8Dh
		db	0C5h, 48h,0CCh, 85h,0C5h,0C9h
		db	0C8h,0CAh,0C9h,0CCh, 84h, 84h
		db	0C5h,0CAh, 58h,0CDh, 86h,0C5h
		db	0C9h,0C8h,0C9h,0CDh, 85h,0C4h
		db	0CAh,0C7h,0C8h,0C9h,0CDh, 8Dh
		db	0C5h,0C9h,0C8h,0C9h,0CCh, 84h
		db	0C5h,0C8h,0C9h, 49h,0C9h,0C7h
		db	0C9h,0CCh, 81h, 84h,0C4h,0CAh
		db	 48h,0C7h,0CDh,0CEh, 85h,0C6h
		db	 48h,0CCh, 81h,0CEh, 84h,0C4h
		db	0CAh, 47h,0CCh, 8Eh,0C4h, 48h
		db	0CCh, 85h,0C5h,0C8h,0C9h,0CCh
		db	0CAh, 68h,0CCh, 84h,0C6h,0CAh
		db	0C9h, 47h,0C9h,0CDh, 86h,0C4h
		db	0CAh,0C9h,0CCh, 85h,0C5h,0CAh
		db	0C8h,0CCh, 86h,0C5h,0C9h,0CDh
		db	 86h,0C4h,0C9h,0CCh,0CEh, 85h
		db	0C5h, 48h,0CAh, 4Ah,0C8h,0CAh
		db	0C8h,0CCh, 85h, 48h, 47h,0C9h
		db	0CDh,0CEh, 85h,0C5h, 49h,0CCh
		db	 85h,0C5h,0CAh, 48h,0CDh, 85h
		db	0C4h,0C9h,0CCh, 86h,0C4h,0C9h
		db	0CCh, 86h,0C5h, 48h, 49h,0CCh
		db	 81h,0C5h,0CAh,0CCh,0CDh, 84h
		db	0C6h, 78h,0CDh,0CEh, 84h,0C5h
		db	 49h,0CCh,0CEh, 84h,0C5h,0CAh
		db	0C9h,0C8h,0CBh,0CCh, 84h,0C4h
		db	0C9h,0CDh,0CEh, 85h,0C4h, 48h
		db	0CCh,0CEh, 84h,0C6h, 48h,0CBh
		db	0CCh,0CEh, 81h,0C6h, 49h,0CDh
		db	 85h,0C4h,0C9h,0C7h,0C8h,0CDh
		db	 86h,0C6h, 48h,0CCh, 85h,0C5h
		db	0CAh, 48h,0CCh, 85h,0C4h, 48h
		db	0CDh, 85h,0C4h, 48h,0C8h,0CCh
		db	 85h,0C6h,0CBh,0CCh, 84h,0C6h
		db	0C9h,0CAh,0CCh, 84h,0C6h,0C5h
		db	 47h, 48h,0CDh, 85h,0C6h,0C8h
		db	0CAh,0CCh, 84h,0C5h,0C9h,0C7h
		db	0C8h,0CCh,0CEh, 84h,0C4h,0C9h
		db	0CBh,0CCh, 85h,0C5h,0C9h,0C8h
		db	0C9h,0CCh, 8Dh,0C5h,0C8h,0CCh
		db	 85h,0C6h,0C5h, 58h,0CCh, 86h
		db	0C5h,0CAh,0CCh, 84h,0C5h, 57h
		db	0CCh, 85h,0C5h,0C9h,0CDh, 81h
		db	0CEh, 84h,0C5h, 48h,0CBh,0CDh
		db	0C1h, 41h, 40h, 41h, 40h,0C2h
		db	 40h, 81h,0C5h,0C8h,0CAh,0CDh
		db	 85h,0C6h,0C8h,0C9h,0C7h,0C9h
		db	0CCh, 85h,0C5h,0CAh,0CCh, 84h
		db	0C5h,0C8h,0C9h,0CCh, 86h,0C5h
		db	 48h,0CBh,0CCh, 84h,0C5h, 48h
		db	0CCh, 8Eh,0C5h,0CAh,0CDh, 88h
		db	0C6h,0C5h,0C9h,0CBh,0CDh, 84h
		db	0C5h,0CAh,0CCh, 84h,0C4h,0C9h
		db	0CDh, 87h,0C6h, 48h,0CDh, 85h
		db	0C5h,0C9h,0CCh, 87h,0C3h,0CAh
		db	0CCh, 85h,0C4h, 49h,0CCh, 88h
		db	0C6h,0CAh,0CDh, 85h,0C6h,0CCh
		db	 85h,0C4h, 58h,0CCh, 86h,0C5h
		db	0C9h,0CDh, 85h,0C4h,0C9h,0CCh
		db	0CEh, 85h,0C3h, 48h,0CCh, 85h
		db	0C4h,0C9h,0CAh,0CCh, 89h,0C5h
		db	0CCh, 8Ch,0C4h,0C9h,0C8h,0CDh
		db	 87h,0C6h,0C9h,0C8h,0CDh, 84h
		db	0C4h,0C9h,0CCh, 86h,0C4h, 48h
		db	0CCh,0CEh, 84h,0C4h, 47h,0C9h
		db	0CCh, 88h,0C6h,0CCh, 8Ch,0C4h
		db	0C9h,0CCh, 81h,0CEh, 87h,0C5h
		db	0C9h,0CDh, 84h,0C4h,0C9h,0C8h
		db	0CCh, 85h,0C4h,0C9h,0C7h,0CBh
		db	0CCh, 84h,0C4h, 47h,0C9h,0CCh
		db	 96h,0C4h,0C9h,0CCh, 81h,0C3h
		db	0CCh, 86h,0C6h,0C4h,0CDh, 84h
		db	0C5h,0C9h,0C8h,0C9h,0CCh, 84h
		db	0C4h, 48h,0CCh, 85h,0C5h, 47h
		db	 48h,0CCh,0C2h, 11h, 01h, 81h
		db	0C3h, 78h,0CCh,0CEh, 86h,0C4h
		db	0CDh, 81h,0CEh, 82h,0C5h,0C8h
		db	0C9h,0C8h,0CCh, 84h,0C4h, 48h
		db	0CCh,0CEh, 84h,0C5h,0C8h,0C7h
		db	0C8h, 48h,0CCh, 93h,0C4h, 48h
		db	 47h, 48h,0CCh, 86h,0C5h,0CDh
		db	 84h,0C5h,0C9h,0CCh,0CEh, 85h
		db	0C5h, 48h,0CCh, 85h,0C5h,0C9h
		db	0CAh, 58h,0CBh,0C7h, 58h,0CCh
		db	0CEh, 8Dh,0C4h,0C9h, 47h, 58h
		db	0CCh, 86h,0C4h,0CDh, 81h,0CEh
		db	 82h,0C5h,0C8h,0CCh, 86h,0C5h
		db	0C8h,0C9h,0CCh, 85h,0C5h,0C9h
		db	0CAh,0C8h, 78h, 47h, 48h,0CCh
		db	0C3h,0C9h,0CCh, 89h,0C4h, 57h
		db	 48h,0C8h,0CCh, 86h,0C4h,0CDh
		db	 84h,0C6h,0CCh, 87h,0C5h,0C8h
		db	0C7h,0CCh,0CEh, 84h,0C5h,0C9h
		db	0CAh,0C9h,0C8h, 58h, 77h, 48h
		db	0C8h,0C9h,0CCh, 88h,0C4h,0C8h
		db	 58h, 47h,0CCh,0CEh, 85h,0C5h
		db	0CDh, 8Dh,0C4h, 48h,0CCh, 85h
		db	0C5h,0C9h,0CAh,0C8h, 78h,0C7h
		db	0C8h,0C9h,0C7h,0C9h, 47h,0CBh
		db	 48h,0CCh, 86h,0C4h, 68h,0C8h
		db	0C9h,0CCh, 86h,0C5h,0CDh, 8Dh
		db	0C4h, 48h,0C8h,0CCh, 84h,0C5h
		db	 49h,0C9h,0C7h, 58h, 47h, 58h
		db	0C8h, 58h,0CBh,0CDh,0CEh, 86h
		db	0C4h, 48h,0C7h,0C9h,0C8h,0C9h
		db	0CCh, 86h,0C5h,0C9h,0CBh,0CCh
		db	 82h,0C3h,0CCh, 87h,0C4h,0C9h
		db	 47h,0CCh, 84h,0C5h, 57h, 48h
		db	0C7h, 08h, 09h,0CCh, 89h,0C5h
		db	 48h, 47h,0C7h,0C8h,0CCh, 86h
		db	0C5h, 06h, 09h,0CCh, 86h,0C4h
		db	 47h,0CCh, 85h,0C5h, 47h, 08h
		db	 09h,0CBh, 68h,0CCh,0CEh, 87h
		db	0C5h,0C9h, 47h, 68h,0CCh, 85h
		db	0C4h, 68h,0C8h, 48h,0CCh, 86h
		db	0C4h,0C8h,0C9h,0CCh,0CEh, 84h
		db	0C5h,0CAh,0C8h, 0Ah, 09h,0C7h
		db	 58h,0CCh, 87h,0C5h,0C9h,0CCh
		db	 81h,0C6h, 58h,0CCh, 85h,0C4h
		db	 78h,0CBh,0CDh, 87h,0C4h,0C9h
		db	 4Bh, 85h,0C4h, 49h, 0Ah, 09h
		db	 57h, 48h,0CCh, 86h,0C6h,0CCh
		db	 83h,0C5h, 48h,0CCh, 85h,0C4h
		db	 05h, 09h, 49h,0CCh, 85h,0C4h
		db	 48h,0CCh, 85h,0C4h, 49h, 78h
		db	0CBh,0CCh,0C9h,0C8h,0C7h, 57h
		db	 58h,0CCh, 8Bh,0C5h,0CBh,0C9h
		db	0CDh, 85h,0C4h, 78h, 47h,0CAh
		db	0CCh, 85h,0C4h,0C9h,0C7h,0CDh
		db	 85h,0C4h, 49h, 58h,0C7h,0CCh
		db	0C3h,0C8h, 48h, 57h, 58h,0CCh
		db	 8Ch,0C5h, 48h,0CCh,0CEh, 84h
		db	0C6h, 78h,0C8h,0C9h,0CBh,0CCh
		db	 85h,0C4h, 48h,0CCh, 85h,0C4h
		db	 49h,0C9h,0C7h, 78h,0C8h,0CBh
		db	0CDh,0C6h, 48h, 47h,0CDh, 81h
		db	0CEh, 8Ah,0C6h, 58h,0CCh, 85h
		db	0C6h, 68h,0C8h,0CAh,0CCh, 86h
		db	0C4h, 48h,0CCh,0CEh, 84h,0C4h
		db	 49h,0C8h, 58h,0C7h, 48h,0CCh
		db	 95h,0C6h, 48h,0CAh,0CCh, 85h
		db	0C5h, 47h,0C9h,0C8h,0CAh,0CCh
		db	0CEh, 85h,0C4h,0C9h,0C8h,0CBh
		db	0CCh, 84h,0C4h,0CAh, 47h, 58h
		db	 47h,0CBh,0CCh, 96h,0C5h, 58h
		db	0CCh, 84h,0C6h,0C8h, 48h,0CBh
		db	0CCh, 87h,0C4h,0C9h, 4Bh,0CEh
		db	 84h,0C4h, 47h, 48h, 67h,0CCh
		db	 97h,0C5h, 48h,0CCh,0CEh, 85h
		db	 48h,0CAh,0CCh, 81h,0CEh, 86h
		db	0C4h,0C8h,0C9h,0CDh, 85h,0C4h
		db	0C8h, 58h, 47h,0CCh, 81h,0CEh
		db	 97h,0C5h, 47h,0C9h,0CCh, 85h
		db	0C5h,0C9h,0C8h,0CAh,0CCh, 87h
		db	0C4h, 48h,0CCh, 85h,0C5h,0CAh
		db	 78h,0CCh,0CEh, 8Ah,0C3h,0CCh
		db	 8Ch,0C5h,0C9h,0C7h,0C9h,0CCh
		db	 85h,0C5h,0C9h,0C8h, 49h,0CDh
		db	0CEh, 85h,0C5h, 48h,0CCh,0CEh
		db	 84h,0C5h,0CAh, 05h, 09h,0CCh
		db	 8Ah,0C4h,0C9h,0CCh, 8Bh,0C5h
		db	 47h,0C9h,0CCh, 85h,0C5h, 47h
		db	0C9h,0CAh,0CBh,0CCh, 85h,0C5h
		db	0C7h,0C9h,0CCh, 85h,0C5h,0CAh
		db	 58h,0CCh, 48h, 47h,0CCh,0CEh
		db	 86h,0C3h, 48h,0CCh, 84h,0C3h
		db	0CCh, 85h,0C4h,0C8h, 48h,0CCh
		db	 85h,0C4h, 48h,0C7h,0CAh,0CCh
		db	 86h,0C5h, 48h,0C8h,0CDh, 82h
		db	0C3h,0CAh,0C9h,0C9h,0C8h, 78h
		db	 47h,0C9h,0CCh, 86h,0C5h, 47h
		db	0CCh, 84h,0C4h,0C9h,0CCh, 84h
		db	0C4h,0C9h,0CBh,0CCh, 81h,0CEh
		db	 84h,0C4h, 58h,0CAh,0CCh, 86h
		db	0C5h, 57h, 49h,0CCh, 59h,0C8h
		db	0CCh, 47h, 58h,0C8h, 48h,0CCh
		db	 86h,0C5h,0C7h,0C9h,0CCh, 84h
		db	0C5h,0C8h,0CCh, 84h,0C4h, 58h
		db	0CCh, 85h,0C4h, 58h,0CAh,0CCh
		db	0CEh, 85h,0C5h, 47h, 59h,0C9h
		db	0CAh, 48h, 48h,0C8h,0C7h, 58h
		db	0C8h, 48h,0CCh, 86h,0C5h,0C9h
		db	0CCh, 81h,0CEh, 83h,0C6h,0C8h
		db	0CDh, 84h,0C4h, 48h,0C8h,0C9h
		db	0CCh, 84h,0C5h, 58h,0C8h,0CAh
		db	0CCh, 85h,0C4h, 48h, 49h, 57h
		db	 48h,0CCh, 83h,0C6h, 48h,0C8h
		db	 48h,0CCh,0CEh, 85h,0C4h, 48h
		db	0CCh, 8Bh,0C4h, 48h,0C8h,0C9h
		db	0CDh, 84h,0C5h,0C8h, 68h,0CAh
		db	0CCh, 83h,0C3h,0C4h, 58h, 47h
		db	0CDh, 81h,0C6h,0C9h, 85h,0C5h
		db	0C9h, 47h, 48h,0CCh, 85h,0C4h
		db	0C9h,0C8h,0CCh,0C2h, 50h,0C2h
		db	 70h, 81h,0C4h,0C9h,0C7h,0C8h
		db	0CCh, 85h,0C5h, 57h, 48h, 47h
		db	0CAh,0C7h,0CAh, 78h,0CDh, 85h
		db	 85h,0C5h, 57h, 48h,0CCh,0CEh
		db	 84h,0C4h,0C8h, 48h,0CCh, 8Ah
		db	0C5h,0C8h,0C9h,0CCh, 86h,0C6h
		db	 47h, 48h, 47h, 58h,0C8h, 68h
		db	0C8h,0C9h,0CCh, 84h, 85h,0C5h
		db	 67h,0C9h,0CCh, 85h,0C4h,0C8h
		db	 46h,0CBh,0CCh, 89h,0C5h, 47h
		db	0C9h,0CCh, 8Ah,0C6h, 58h, 57h
		db	0C9h, 47h, 48h,0CCh,0CEh, 83h
		db	 85h,0C6h, 47h,0C9h,0C8h,0C9h
		db	0CCh, 85h,0C4h, 68h,0CCh,0CEh
		db	 88h,0C6h,0C8h, 48h,0CCh,0C1h
		db	0C2h,0C1h,0C2h, 40h,0C2h, 40h
		db	 87h,0C6h, 47h,0C9h,0C8h,0C9h
		db	0CBh, 48h,0CCh, 81h, 86h,0C5h
		db	0C8h,0C9h,0C8h,0C9h,0CCh, 85h
		db	0C5h, 48h,0C8h,0C9h,0C8h,0CCh
		db	 89h,0C6h, 48h,0CBh,0C9h,0CDh
		db	 93h,0C5h,0C8h,0CBh,0CCh, 82h
		db	 86h,0C6h, 57h,0C9h,0CCh, 85h
		db	0C5h, 48h,0C7h, 58h,0CCh, 89h
		db	 58h,0C8h,0CBh,0CCh,0C1h, 41h
		db	 50h,0C2h, 40h, 89h,0C6h,0CAh
		db	0CCh, 83h, 87h,0C5h, 47h,0CCh
		db	0CEh, 85h,0C5h,0C9h,0C8h, 58h
		db	0CCh, 8Ah,0C5h,0C8h,0C7h,0C8h
		db	 48h,0CCh, 92h,0C4h,0CDh, 83h
		db	 87h,0C6h, 57h,0CCh, 85h,0C5h
		db	0C8h, 58h,0CCh, 8Bh,0C5h, 47h
		db	 78h,0CDh, 50h, 41h, 60h,0C2h
		db	 60h, 82h,0C5h,0C8h,0CCh, 82h
		db	 05h, 01h, 82h,0C8h,0C7h,0C8h
		db	0C9h,0CCh,0CEh, 83h,0C5h,0C9h
		db	 47h, 48h,0CCh,0CEh, 89h,0C5h
		db	 48h,0CCh, 58h,0C8h, 58h,0CCh
		db	 8Dh,0C6h,0C8h,0CCh, 40h, 2Fh
		db	 00h, 24h, 3Bh, 00h, 19h,0FFh
		db	0FFh,0FFh,0FFh, 07h, 40h, 3Dh
		db	 01h, 00h, 0Eh, 00h, 26h, 40h
		db	 84h, 1Eh, 00h, 2Ah, 00h, 4Ch
		db	 80h, 19h, 49h, 00h, 4Fh, 00h
		db	0FFh,0FFh, 0Fh, 00h, 23h, 82h
		db	 02h, 5Fh, 00h, 23h, 00h,0FFh
		db	0FFh,0FFh, 0Fh, 00h, 32h,0C3h
		db	 00h, 5Fh, 00h, 32h, 00h,0FFh
		db	0FFh,0FFh, 42h, 00h, 23h,0C2h
		db	 02h, 92h, 00h, 23h, 00h,0FFh
		db	0FFh,0FFh, 4Fh, 00h, 32h, 83h
		db	 00h, 9Fh, 00h, 32h, 00h,0FFh
		db	0FFh,0FFh,0FFh,0FFh, 0Ah, 00h
		db	 02h, 7Bh,0CBh, 00h, 00h,0FFh
		db	0FFh, 0Ah, 00h, 01h,0B2h,0CBh
		db	 00h,0FFh,0BDh,0CBh,0FFh,0FFh
		db	0FFh,0FFh,0FFh,0FFh, 16h,0AFh
		db	 02h, 11h

; ------------------------------------------------------------------
; cavern_name -- pascal-encoded cavern/area name 'Cavern of Peligro'.
; Preceded by small descriptor bytes; the length byte just before
; the quoted string matches the string length (0x11/0x0E/etc).
; ------------------------------------------------------------------
		db	'Cavern of Peligro'
		db	 0Bh, 00h, 01h, 02h, 02h, 07h
		db	 00h, 06h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 07h, 00h
		db	 06h, 02h, 00h, 0Eh, 00h, 1Ah
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 0Eh, 00h, 1Ah, 04h
		db	 00h, 0Fh, 00h, 0Fh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 0Fh, 00h, 0Fh, 02h, 00h, 11h
		db	 00h, 2Bh,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 1Bh, 00h, 0Ah, 00h
		db	 02h, 00h, 00h, 2Bh, 00h, 1Fh
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 2Bh, 00h, 1Fh, 04h
		db	 00h, 2Eh, 00h, 18h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 2Eh, 00h, 18h, 02h, 00h, 4Eh
		db	 00h, 1Eh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 4Eh, 00h
		db	 1Eh, 02h, 00h, 50h, 00h, 3Dh
		db	0FFh, 73h, 00h, 00h, 20h, 00h
		db	 18h, 00h, 0Ah, 00h, 01h, 00h
		db	 00h, 58h, 00h, 03h,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 58h, 00h, 03h, 03h, 00h,0FFh
		db	0FFh

_323MP21	endp

seg_a		ends


		end	start
