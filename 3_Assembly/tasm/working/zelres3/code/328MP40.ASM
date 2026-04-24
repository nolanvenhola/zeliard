
PAGE  59,132

;==========================================================================
;
;  328MP40 - Map Data Table: Cavern of Glacial, level 4, floor 0 (entrance)
;
;  Cavern/labyrinth map resource file loaded as MP40.MDT (zelres3).
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
;    [late]   cavern_name          - pascal-encoded 'Cavern of Glacial'
;    [end]    exit/trigger records - door warp coords + script bytes
;    [eof]    terminator           - 0xFFFFFFFF (header_1 label)
;
;  Runtime segment base = 0xC000.  Pointer 0xCNNN resolves to file_off NNN.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_328MP40	proc	far


; ------------------------------------------------------------------
; mdt_header -- file-size word, flag byte, and table of WORD pointers
; into the runtime 0xC000 segment.  Sourcer mis-decoded the leading
; bytes as instructions; they are actually: size word + flag word
; + attributes pointer + offset of 'strategy' (tile grid start) + ...
; ------------------------------------------------------------------
start:
		jz	loc_1			; Jump if zero
		add	[bx+si],al
		sbb	ax,40D9h
		add	[bx+di],bx

; ------------------------------------------------------------------
; tile_grid -- main cavern/map tile-index data.  Encoded as column
; or row strips of 1-byte tile indices.  Common runs: 0x3F06 (wall
; boundary), 0x2C06 (column separator), plus palette-range values
; (0xC4-0xCC) that select tile rows in the tile bank.  Originally
; labeled 'strategy' by Sourcer because the header pointer landed
; on this offset.
; ------------------------------------------------------------------
		db	0D8h, 1Bh,0D8h, 1Dh,0D8h, 49h
		db	0D8h, 93h,0D8h, 08h,0D9h, 22h
		db	0D9h, 04h,0E0h, 00h, 13h, 0Ah
		db	 00h, 00h, 19h,0D8h
loc_1:
		mov	word ptr [bx-76h],0C8C4h
		inc	si
		xchg	al,ah
		push	si
;*		mov	bx,cx
		db	 89h,0CBh		;  Fixup - byte match
		int	3			; Debug breakpoint
		lds	ax,dword ptr [bp-38h]	; Load seg:offset ptr
		mov	ax,sp
		push	si
		retf	84C9h
		db	0C4h,0C7h,0C8h, 8Bh,0C4h, 66h
		db	 85h,0C4h, 46h,0C8h, 89h,0CBh
		db	0CCh,0C5h,0C7h,0C8h, 8Ch,0C4h
		db	0C7h,0C8h, 87h,0C4h, 66h, 89h
		db	0C4h, 56h,0C8h, 85h,0C4h,0C8h
		db	0C7h, 8Bh,0CBh,0C5h,0C7h, 8Dh
		db	0C4h, 46h,0C8h, 86h,0C4h, 05h
		db	 07h, 87h,0C4h,0C7h,0C8h,0C7h
		db	 86h,0C4h,0C7h,0C8h,0C7h, 85h
		db	0C3h, 85h,0C4h, 8Eh,0C4h, 56h
		db	0C8h, 85h,0C4h, 66h, 89h,0C4h
		db	0C8h,0C7h,0C8h, 86h,0C4h, 66h
		db	 84h,0C4h, 85h,0C6h, 84h,0C3h
		db	 89h,0C4h, 66h, 85h,0C4h,0C7h
		db	0C8h,0C7h,0C8h, 89h,0C4h, 66h
		db	 85h,0C4h, 46h,0C8h, 85h,0C4h
		db	0C7h, 89h,0C4h, 89h,0C4h,0C7h
		db	0C8h,0C7h,0C8h, 85h,0C4h,0C7h
		db	 47h, 8Ah,0C4h,0C7h,0C8h,0C7h
		db	 86h,0C4h,0C7h, 47h, 85h,0C4h
		db	0C8h, 89h,0C4h,0C7h, 88h,0C4h
		db	 46h, 47h, 85h,0C4h,0C8h, 46h
		db	 8Ah,0C4h, 46h,0C8h, 86h,0C4h
		db	0C8h,0C7h, 86h,0C4h,0C7h, 89h
		db	0C4h,0C7h,0C8h, 87h,0C4h,0C7h
		db	0C8h,0C7h, 86h,0C4h, 76h, 88h
		db	0C4h,0C8h,0C7h, 87h,0C4h,0C7h
		db	0C8h, 86h,0C4h, 46h, 88h,0C4h
		db	0C7h,0C8h, 87h,0C4h, 56h, 86h
		db	0C4h,0C7h,0C8h,0C7h,0C8h, 89h
		db	0C4h,0C7h,0CAh,0C9h, 86h,0C4h
		db	 46h,0C8h, 85h,0C4h,0C7h,0C8h
		db	 88h,0C4h, 46h, 87h,0C4h, 46h
		db	 47h, 85h,0C4h, 46h,0C8h, 8Ah
		db	0C4h,0C8h, 88h,0C4h, 56h,0CAh
		db	0C9h, 83h,0C4h, 66h, 86h,0C4h
		db	 56h,0C8h, 85h,0C4h, 46h,0C8h
		db	 86h,0C4h,0C7h,0C8h, 8Bh,0C4h
		db	0C7h,0C8h, 87h,0C4h, 47h,0CAh
		db	0C9h, 84h,0C4h,0C8h,0C7h,0C8h
		db	 87h,0C4h, 46h,0C8h,0C7h, 85h
		db	0C4h,0C7h,0C8h,0C7h, 86h,0C4h
		db	 56h,0CAh,0C9h, 88h,0C4h, 46h
		db	 87h,0C4h, 46h,0CAh,0C9h, 84h
		db	0C4h,0C7h,0C8h, 88h,0C4h, 76h
		db	 84h,0C4h, 46h, 47h, 85h,0C4h
		db	 56h,0CAh,0C9h, 88h,0C4h, 46h
		db	0C8h, 86h,0C4h, 46h,0CAh,0C9h
		db	 84h,0C4h,0C7h, 89h,0C4h, 76h
		db	 84h,0C4h, 56h, 86h,0C4h, 66h
		db	0CAh,0C9h, 87h,0C4h, 56h,0C8h
		db	 85h,0C4h,0C7h,0C8h,0CAh,0C9h
		db	 84h,0C4h, 8Ah,0C4h,0C8h, 56h
		db	0C8h, 84h,0C4h, 66h, 85h,0C4h
		db	0C7h,0C8h,0C7h,0C8h, 89h,0C4h
		db	0C8h,0C7h,0C8h, 86h,0C4h, 56h
		db	 85h,0C6h, 8Ah,0C4h, 66h, 85h
		db	0C4h,0C7h,0C8h, 46h, 85h,0C4h
		db	 46h,0C8h, 8Ah,0C4h,0C7h,0C8h
		db	0C7h, 86h,0C4h, 66h,0C8h, 8Eh
		db	0C4h, 46h, 47h, 85h,0C4h, 56h
		db	 86h,0C4h,0C7h,0C8h, 56h, 88h
		db	0C4h, 66h, 85h,0C4h, 46h,0C8h
		db	0C7h, 8Fh,0C4h, 66h, 85h,0C4h
		db	 46h,0C8h, 86h,0C4h, 56h,0C8h
		db	0C7h, 88h,0C4h, 66h,0C8h, 84h
		db	0C4h, 56h,0C8h, 8Fh,0C4h, 56h
		db	0C8h, 85h,0C4h,0C7h,0C8h,0C7h
		db	 86h,0C4h, 66h, 47h, 87h,0C4h
		db	 46h,0C8h, 46h, 84h,0C4h,0C8h
		db	0C7h,0C8h, 90h,0C4h,0C7h,0C8h
		db	0C7h, 86h,0C4h, 46h, 87h,0C4h
		db	 05h, 07h,0C8h, 86h,0C4h,0C7h
		db	0C8h,0C7h,0C8h, 85h,0C4h, 66h
		db	 8Fh,0C4h, 46h, 47h, 85h,0C4h
		db	0C7h, 47h, 86h,0C4h, 07h, 07h
		db	 85h,0C4h, 46h,0CAh,0C9h, 85h
		db	0C4h, 56h,0C8h, 8Fh,0C4h, 46h
		db	0C8h, 86h,0C4h,0C8h,0C7h, 87h
		db	0C4h, 56h, 47h, 46h, 86h,0C4h
		db	0C7h,0CAh,0C9h, 86h,0C4h,0C7h
		db	 47h, 90h,0C4h,0C7h,0C8h,0CAh
		db	0C9h, 85h,0C4h, 46h, 87h,0C4h
		db	 46h, 47h,0C7h, 47h, 86h,0C4h
		db	 56h,0C8h, 85h,0C4h, 46h, 91h
		db	0C4h, 46h,0CAh,0C9h, 85h,0C4h
		db	0C7h, 47h, 86h,0C4h,0C7h,0C8h
		db	 46h,0CAh,0C9h, 87h,0C4h,0C8h
		db	0C7h,0C8h, 86h,0C4h,0C7h,0C8h
		db	 86h,0C3h, 8Ah,0C4h,0C7h,0C8h
		db	 87h,0C4h, 46h, 87h,0C4h, 56h
		db	0CAh,0C9h, 88h,0C4h, 46h, 87h
		db	0C4h,0C7h, 87h,0C4h, 8Ah,0C4h
		db	0C8h,0C7h, 87h,0C4h,0C7h, 47h
		db	 86h,0C4h,0C7h,0C8h,0C7h,0CAh
		db	0C9h, 88h,0C4h,0C7h,0CAh,0C9h
		db	 86h,0C4h,0C7h, 87h,0C4h,0C7h
		db	0CAh,0C9h, 87h,0C4h, 46h,0C8h
		db	 86h,0C4h,0C8h,0C7h, 87h,0C4h
		db	 46h,0C8h,0C7h,0CAh,0C9h, 87h
		db	0C4h, 46h, 87h,0C4h, 88h,0C4h
		db	0C7h,0CAh,0C9h, 87h,0C4h, 56h
		db	0C8h, 85h,0C4h, 56h, 86h,0C4h
		db	0C7h,0C8h, 66h, 87h,0C4h, 47h
		db	 87h,0C4h, 88h,0C4h,0C8h,0C7h
		db	 88h,0C4h, 66h,0C8h, 84h,0C4h
		db	 46h,0C8h, 86h,0C4h, 06h, 07h
		db	 86h,0C4h, 46h,0C8h, 86h,0C6h
		db	 87h,0CBh,0C5h,0C7h, 47h, 87h
		db	0C4h, 56h,0C8h, 85h,0C4h,0C7h
		db	0C8h, 87h,0C4h, 76h,0C8h, 87h
		db	0C4h,0C7h,0C8h,0C7h,0C8h, 8Ch
		db	0CBh,0CCh,0C5h, 46h,0C8h, 87h
		db	0C4h, 56h, 86h,0C4h,0C8h, 88h
		db	0C4h, 56h,0C8h,0C7h, 88h,0C4h
		db	 56h, 8Ch,0CBh, 4Bh,0C5h, 56h
		db	0C8h, 86h,0C4h,0C7h, 47h, 86h
		db	0C4h,0C7h, 88h,0C4h,0C7h, 47h
		db	0C7h,0C8h, 88h,0C4h, 66h, 8Bh
		db	0CBh, 4Bh,0C5h, 66h,0C8h, 85h
		db	0C4h, 46h, 87h,0C4h, 89h,0C4h
		db	 56h,0C8h, 89h,0C4h,0C7h,0C8h
		db	0C7h,0C8h, 8Bh,0CBh, 4Bh,0C5h
		db	0C8h,0C7h,0C8h, 46h, 85h,0C4h
		db	0C7h,0C8h, 87h,0C6h, 89h,0C4h
		db	 46h,0C8h, 8Ah,0C4h, 46h,0C8h
		db	 8Ch,0CBh, 4Bh,0C5h, 56h, 87h
		db	0C4h,0C7h, 92h,0C4h,0C7h,0C8h
		db	 46h,0CAh,0C9h, 87h,0C4h, 56h
		db	 8Ch,0CBh, 4Bh,0C5h, 46h,0C8h
		db	 87h,0C4h, 06h, 01h,0C2h, 06h
		db	 01h,0C2h, 40h, 81h,0C4h, 66h
		db	0CAh,0C9h, 87h,0C4h, 46h,0C8h
		db	0C7h,0C8h, 8Ah,0CBh, 4Bh,0C5h
		db	0C7h,0C8h,0C7h, 87h,0C4h, 93h
		db	0C4h, 05h, 07h,0CAh,0C9h, 85h
		db	0C4h, 56h,0C8h, 8Bh,0CBh, 4Bh
		db	0C5h, 56h,0C8h, 86h,0C6h, 85h
		db	0C3h, 8Dh,0C4h, 56h,0C8h,0C7h
		db	0C8h, 87h,0C4h, 46h,0C8h, 8Ch
		db	0CBh, 4Bh,0C5h,0C8h, 56h, 8Ch
		db	0C4h, 8Dh,0C4h,0C7h, 47h,0C7h
		db	0C8h, 88h,0C4h, 66h, 8Bh,0CBh
		db	 4Bh,0C5h, 66h,0CAh,0C1h,0C2h
		db	 07h, 01h, 81h,0C4h, 81h,0C7h
		db	 8Bh,0C4h, 46h,0C8h, 8Ah,0C4h
		db	0C7h,0C8h,0C7h,0C8h, 8Bh,0CBh
		db	 4Bh,0C5h, 56h,0C8h, 8Ch,0C4h
		db	 56h, 8Ah,0C4h,0C8h, 8Ch,0C4h
		db	 46h,0C8h, 8Ch,0CBh, 4Bh,0C5h
		db	0C7h,0C8h,0C7h, 8Dh,0C4h,0C7h
		db	 57h, 89h,0C4h, 8Dh,0C4h, 46h
		db	 8Dh,0CBh, 4Bh,0C5h, 46h,0C8h
		db	 8Dh,0C4h, 46h, 47h, 89h,0C6h
		db	 8Dh,0C4h, 46h,0C8h, 8Ch,0CBh
		db	 4Bh,0C5h, 46h, 8Eh,0C4h, 66h
		db	 8Ah, 60h,0C2h, 05h, 01h, 82h
		db	0C4h,0C7h,0C8h, 86h,0C3h, 87h
		db	0CBh,0CCh,0C5h, 56h, 47h, 8Bh
		db	0C4h, 56h,0CAh, 40h,0C2h, 06h
		db	 01h, 8Dh,0C4h,0C7h,0C8h, 86h
		db	0C4h,0C7h, 87h,0CBh,0C5h,0C7h
		db	 47h, 8Dh,0C4h, 66h, 8Ah, 8Dh
		db	0C4h, 56h, 85h,0C4h,0C7h, 88h
		db	0C4h,0C7h,0C8h, 8Eh,0C4h,0C7h
		db	0C8h,0C7h,0C8h, 8Ah, 8Dh,0C4h
		db	0C8h,0C7h,0C8h, 85h,0C4h, 46h
		db	 87h,0C6h, 90h,0C4h, 56h, 47h
		db	 89h, 8Dh,0C4h,0C7h,0C8h, 84h
		db	0C3h, 81h,0C4h,0C8h,0C7h, 98h
		db	0C4h,0C8h, 66h, 89h, 8Dh,0C4h
		db	0C7h, 85h,0C4h, 66h,0CAh, 40h
		db	 41h, 06h, 01h,0C2h, 50h, 41h
		db	 60h, 82h,0C4h,0C7h,0C8h, 46h
		db	 8Ah, 8Dh,0C4h, 86h,0C4h, 66h
		db	0C8h, 97h,0C4h, 46h, 47h, 8Ah
		db	 8Dh,0C6h, 86h,0C4h,0C7h,0C8h
		db	 66h, 88h,0C3h, 8Dh,0C4h,0C7h
		db	 47h, 85h,0C3h, 85h, 92h,0C3h
		db	 81h,0C4h, 56h, 57h, 88h,0C4h
		db	 8Dh,0C4h, 56h, 85h,0C4h, 85h
		db	 92h,0C4h, 81h,0C4h, 66h, 8Ah
		db	0C4h,0C7h, 8Bh,0CDh, 56h, 86h
		db	0C4h, 85h, 92h,0C4h, 56h, 47h
		db	0C7h, 87h,0C3h, 82h,0C4h, 46h
		db	0C8h, 88h,0CDh, 46h, 47h, 86h
		db	0C4h,0C7h, 84h, 92h,0C4h,0C7h
		db	0C8h, 56h,0C8h, 87h,0C4h, 82h
		db	0C4h, 56h,0C8h, 86h,0CDh, 46h
		db	0C8h, 46h, 86h,0C4h, 46h, 83h
		db	 92h,0C4h, 66h,0C8h, 88h,0C4h
		db	 66h,0C8h, 87h,0CDh, 76h, 87h
		db	0C4h, 56h, 82h, 92h,0C4h, 56h
		db	0C8h,0C7h, 88h,0C4h, 46h,0C8h
		db	0C7h, 87h,0CDh, 66h, 47h, 87h
		db	0C4h,0C7h, 57h, 81h, 92h,0C4h
		db	 46h,0C8h, 46h, 88h,0C4h, 56h
		db	 88h,0C4h, 76h,0C8h, 87h,0C4h
		db	 46h,0C8h, 82h, 92h,0C4h, 56h
		db	0C8h, 89h,0C4h, 56h,0C8h, 87h
		db	0C4h, 46h,0C8h,0C7h, 47h, 87h
		db	0C4h,0C7h,0C8h, 83h, 92h,0C4h
		db	 56h, 47h, 87h,0CBh,0C5h,0C8h
		db	 56h, 87h,0C4h,0C7h,0C8h,0C7h
		db	0C8h, 89h,0C4h,0C7h,0C8h, 83h
		db	 92h,0C4h, 76h, 86h,0CBh,0CCh
		db	0C5h, 76h,0C8h, 85h,0C4h,0C7h
		db	 8Ch,0C4h, 46h,0CAh,0C9h, 81h
		db	 92h,0C4h, 46h,0C8h, 46h, 86h
		db	0CBh,0CCh,0C5h, 46h,0C8h,0C7h
		db	0C8h, 86h,0C6h, 8Dh,0C4h, 46h
		db	0CAh,0C9h, 81h, 92h,0C4h, 66h
		db	0C8h, 87h,0CBh,0C5h, 56h, 47h
		db	 94h,0C4h,0C7h,0C8h, 83h, 92h
		db	0C4h, 76h, 88h,0C4h, 46h,0C8h
		db	 96h,0C4h,0C7h,0C8h, 83h, 92h
		db	0C4h, 56h,0C8h, 89h,0C4h,0C7h
		db	0C8h, 46h,0C8h, 94h,0C4h,0C8h
		db	0C7h,0C8h, 82h, 92h,0C4h, 66h
		db	0C8h, 88h,0C4h, 76h,0C8h, 93h
		db	0C4h, 56h, 82h, 92h,0C4h, 46h
		db	0C8h, 56h, 87h,0C4h, 46h,0C8h
		db	0CAh,0C9h, 89h,0C3h, 8Ah,0C4h
		db	 56h, 82h, 92h,0C4h, 06h, 07h
		db	 86h,0C4h,0C7h,0C8h,0CAh,0C9h
		db	 8Ah,0C4h, 8Ah,0C4h, 46h, 47h
		db	 81h, 8Dh,0C3h, 84h,0C4h, 76h
		db	0C8h, 87h,0C4h, 56h,0C8h, 8Ah
		db	0C4h,0C7h, 89h,0C4h, 46h,0C8h
		db	 82h, 8Dh,0C4h,0C7h,0C8h, 82h
		db	 66h, 47h, 88h,0C4h,0C8h,0C7h
		db	0C8h, 8Bh,0C4h,0C7h, 89h,0C4h
		db	0C8h,0C7h, 83h, 82h,0C3h, 8Ah
		db	0C4h, 46h, 82h, 46h,0C8h, 56h
		db	 88h,0C4h, 46h,0C8h, 8Bh,0C4h
		db	 46h, 88h,0C4h,0C7h,0C8h, 83h
		db	 82h,0C4h, 8Ah,0C4h, 76h,0C8h
		db	0C7h, 8Bh,0C4h,0C7h,0C8h,0C7h
		db	0C8h, 8Ah,0C4h, 56h,0C8h, 86h
		db	0C4h,0C7h, 84h, 82h,0C4h,0C7h
		db	 89h,0C4h, 56h,0CAh, 60h,0C2h
		db	 05h, 01h,0C2h,0C1h, 81h,0C4h
		db	 66h,0C8h, 89h,0C4h,0C7h, 47h
		db	 87h,0C4h, 85h, 82h,0C4h,0C8h
		db	 89h,0C4h, 56h,0C8h,0C7h, 8Dh
		db	0C4h, 76h,0C8h, 88h,0C4h, 46h
		db	 88h,0C4h, 85h, 82h,0C4h,0C7h
		db	0C8h, 88h,0C4h,0C7h,0C8h, 46h
		db	0C8h, 86h,0C3h, 86h,0C4h, 46h
		db	0C8h,0C7h,0C8h, 89h,0C4h,0C7h
		db	 89h,0C6h, 85h, 82h,0C4h,0C7h
		db	 89h,0C4h, 46h,0C8h, 88h,0C4h
		db	 86h,0C4h,0C7h,0C8h, 8Ch,0C4h
		db	0C7h, 8Fh, 82h,0C4h,0C7h,0C8h
		db	 88h,0C4h,0C7h,0C8h, 89h,0C4h
		db	0C8h, 85h,0C4h,0C7h, 8Dh,0C4h
		db	0CAh,0C1h,0C2h, 70h,0C2h, 50h
		db	0C2h, 50h, 82h,0C4h, 46h, 88h
		db	0C4h,0C7h,0C8h, 89h,0C4h,0C7h
		db	0C8h, 84h,0C6h, 8Eh,0C4h,0C7h
		db	0C8h, 8Eh, 82h,0C4h, 46h,0C8h
		db	 87h,0C4h, 56h, 88h,0C4h,0C8h
		db	 94h,0C4h,0C7h, 84h,0C3h,0C8h
		db	 89h, 82h,0C4h,0C7h,0C8h, 88h
		db	0C4h,0C8h,0C7h,0C8h, 88h,0C4h
		db	0CAh,0C1h,0C2h, 07h, 01h,0C2h
		db	 40h,0C2h, 40h, 84h,0C4h,0C7h
		db	 84h,0C4h,0C7h, 89h, 82h,0C4h
		db	 56h, 87h,0C4h,0C7h,0C8h, 89h
		db	0C4h,0C7h,0C8h, 93h,0C4h,0C7h
		db	 84h,0C4h,0C7h,0C8h, 88h, 82h
		db	0C4h, 56h,0C8h, 86h,0C4h,0C7h
		db	0C8h, 89h,0C4h, 46h,0C8h, 92h
		db	0C4h, 85h,0C4h,0C7h,0C8h, 88h
		db	 82h,0C4h, 46h,0C8h,0C7h, 86h
		db	0C4h, 46h,0C8h, 88h,0C4h, 46h
		db	 47h, 91h,0C6h, 85h,0C6h,0C8h
		db	0C7h, 88h, 82h,0C4h, 66h, 86h
		db	0C4h, 46h,0C8h, 88h,0C4h, 56h
		db	 99h,0C4h,0C7h,0C8h, 87h, 82h
		db	0C4h, 56h,0C8h, 86h,0C4h,0C7h
		db	0C8h, 84h,0CFh, 84h,0C4h, 66h
		db	 98h,0C4h, 46h,0C8h, 86h, 82h
		db	0C4h,0C7h,0C8h,0C7h, 87h,0C4h
		db	 56h,0C8h, 82h,0D0h, 84h,0C4h
		db	 46h, 47h, 98h,0C4h,0C8h, 46h
		db	 86h, 82h,0C4h, 46h,0C8h,0C7h
		db	 86h,0C4h, 46h,0C8h,0C7h,0C8h
		db	 81h,0D1h, 84h,0C4h, 56h,0C8h
		db	 98h,0C4h, 56h,0C8h, 85h, 82h
		db	0C4h, 76h, 85h,0C4h, 66h, 82h
		db	0D2h, 84h,0C4h, 46h,0CAh,0C9h
		db	 98h,0C4h, 46h, 47h, 85h, 82h
		db	0C4h, 46h, 47h, 86h,0C4h, 46h
		db	 47h, 82h,0D3h, 84h,0C4h, 56h
		db	 99h,0C4h,0C7h,0C8h, 56h, 84h
		db	 82h,0C4h, 56h, 87h,0C4h, 66h
		db	0C8h, 86h,0C4h,0C8h,0C7h,0C8h
		db	 99h,0C4h, 05h, 07h, 83h, 82h
		db	0C4h, 46h, 47h, 86h,0C4h, 76h
		db	 86h,0C4h, 46h,0C8h, 99h,0C4h
		db	 76h,0C8h, 83h, 82h,0C4h,0C7h
		db	0C8h, 46h, 86h,0C4h, 46h,0C8h
		db	0C7h, 87h,0C4h,0C7h,0C8h, 9Ah
		db	0C4h,0C7h,0C8h,0C7h,0C8h,0C7h
		db	 84h, 82h,0C4h, 76h, 85h,0C4h
		db	 56h,0C8h, 87h,0C4h, 46h, 9Ah
		db	0C4h, 66h,0C8h, 84h, 82h,0C4h
		db	 66h,0C8h, 85h,0C4h,0C7h, 47h
		db	 88h,0C4h,0C7h,0C8h, 9Ah,0C4h
		db	 46h, 57h, 84h, 82h,0C4h, 46h
		db	 47h, 46h,0C8h, 83h,0C4h, 46h
		db	 89h,0C4h, 9Ch,0C4h, 46h, 47h
		db	 85h, 82h,0C4h,0C7h,0C8h, 09h
		db	 07h, 8Ah,0C6h, 9Ch,0C4h,0C7h
		db	0C8h,0C7h, 86h, 82h,0C4h, 56h
		db	0C8h, 07h, 07h,0C8h,0A6h,0C4h
		db	0C8h,0C7h,0C8h, 86h, 82h,0C4h
		db	 76h,0C8h, 46h,0C8h,0AAh,0C4h
		db	 46h,0CAh,0C9h, 85h, 82h,0C4h
		db	 05h, 07h,0C8h,0ACh,0C4h, 56h
		db	0CAh,0C9h, 84h, 82h,0C4h, 46h
		db	0C8h,0C7h,0AFh,0C4h,0C7h,0C8h
		db	0C7h,0CAh,0C9h, 84h, 82h,0C4h
		db	 56h,0C8h,0AFh,0C4h, 76h,0C8h
		db	 83h, 82h,0C4h, 46h,0C8h,0B0h
		db	0C4h, 66h, 85h, 82h,0C4h, 66h
		db	0AFh,0C4h, 46h, 47h, 85h, 82h
		db	0C4h,0C7h,0C8h,0C7h,0CAh, 40h
		db	0C2h,0C1h,0C2h, 08h, 01h,0C2h
		db	 40h, 9Eh,0C4h, 46h,0C8h, 86h
		db	 82h,0C4h, 56h, 98h,0C3h, 97h
		db	0C4h,0C7h,0C8h, 87h, 82h,0C4h
		db	 46h, 47h, 85h,0C3h, 91h,0C4h
		db	 97h,0C4h, 46h, 87h, 82h,0C4h
		db	 56h,0C8h, 85h,0C4h,0C7h, 90h
		db	0C4h,0C7h, 96h,0C4h, 56h, 86h
		db	 82h,0C4h, 46h,0C8h, 86h,0C4h
		db	 46h, 8Fh,0C4h,0C7h, 47h, 94h
		db	0C4h,0C7h,0C8h,0C7h,0C8h, 85h
		db	 82h,0C4h,0C7h,0C8h, 46h, 85h
		db	0C4h, 05h, 07h, 8Bh,0C4h, 66h
		db	 47h, 91h,0C4h, 66h, 85h, 82h
		db	0C4h, 46h, 47h, 85h,0C4h, 66h
		db	0C8h, 8Ch,0C4h, 56h, 47h, 92h
		db	0C4h, 76h, 84h, 82h,0C4h,0C7h
		db	0C8h, 87h,0C4h, 46h, 47h, 8Dh
		db	0C4h,0C7h, 57h, 93h,0C4h, 56h
		db	 47h, 84h, 82h,0C4h,0C7h,0C8h
		db	 87h,0C4h,0C7h,0C8h,0C7h, 89h
		db	0C3h, 84h,0C4h, 56h,0C8h, 93h
		db	0C4h,0C7h,0C8h,0C7h,0C8h, 85h
		db	 82h,0C4h,0C7h, 88h,0C4h, 56h
		db	0C8h, 88h,0C4h, 05h, 07h,0C8h
		db	 95h,0C4h, 46h,0C8h, 86h, 82h
		db	0C4h, 89h,0C4h, 66h, 88h,0C4h
		db	 56h,0C8h, 98h,0C4h, 56h, 86h
		db	 82h,0C6h, 89h,0C4h,0C7h,0C8h
		db	0C7h,0C8h, 88h,0C4h, 46h,0CAh
		db	 50h,0C2h, 05h, 01h,0C2h, 50h
		db	 8Bh,0C4h,0C7h,0C8h,0C7h,0C8h
		db	 85h, 8Ch,0C4h, 46h,0C8h, 89h
		db	0C4h,0C8h,0C7h, 9Ah,0C4h, 46h
		db	0C8h, 86h,0C1h,0C2h, 60h,0C2h
		db	 40h, 82h,0C3h, 56h, 47h, 88h
		db	0C4h,0C7h,0C8h,0C7h, 87h,0C3h
		db	 91h,0C4h,0C7h,0C8h, 46h,0CAh
		db	 50h,0C2h, 8Bh,0C4h, 66h, 89h
		db	0C4h,0C8h,0C7h,0C8h,0C7h, 86h
		db	0C4h, 91h,0C4h, 76h, 84h, 8Bh
		db	0C4h, 76h,0C8h, 87h,0C4h, 56h
		db	 87h,0C4h,0C7h, 90h,0C4h, 66h
		db	0C8h, 84h, 8Bh,0C4h,0C7h,0C8h
		db	 76h, 86h,0C4h,0C7h, 47h, 87h
		db	0C4h, 46h, 8Fh,0C4h,0C7h,0C8h
		db	0C7h, 86h, 8Bh,0C4h, 56h, 47h
		db	 88h,0C4h, 76h, 85h,0C4h, 46h
		db	 8Fh,0C4h, 56h,0C8h, 85h, 8Bh
		db	0C4h, 76h,0CAh,0C9h, 86h,0C4h
		db	0C8h,0C7h,0C8h, 87h,0C4h,0C7h
		db	0C8h,0C7h, 8Eh,0C4h, 46h, 47h
		db	 85h, 8Bh,0C4h, 66h,0C8h,0CAh
		db	0C9h, 86h,0C4h, 46h, 88h,0C4h
		db	 56h,0C8h, 8Dh,0C4h,0C7h,0C8h
		db	0C7h,0C8h, 85h, 8Bh,0C4h, 05h
		db	 07h,0CAh,0C9h, 85h,0C4h, 46h
		db	0C8h, 87h,0C4h, 66h, 8Dh,0C4h
		db	0C8h, 46h,0C8h, 85h, 8Bh,0C4h
		db	 56h,0C8h,0C7h,0C8h,0CAh,0C9h
		db	 85h,0C4h,0C7h,0C8h,0CAh,0C9h
		db	 86h,0C4h, 76h, 8Ch,0C4h, 76h
		db	 84h, 8Bh,0C4h, 05h, 07h,0C8h
		db	0CAh,0C9h, 84h,0C4h,0C8h,0C7h
		db	0CAh,0C9h, 86h,0C4h, 07h, 07h
		db	 89h,0C4h, 46h,0C8h,0C7h,0C8h
		db	 84h, 8Bh,0C4h, 46h,0C8h, 76h
		db	 85h,0C4h, 46h,0C8h, 87h,0C4h
		db	 56h,0C8h, 66h,0C8h, 46h,0C8h
		db	 85h,0C4h, 56h,0C8h, 85h, 8Bh
		db	0C4h, 56h,0C8h,0C7h,0C8h,0C7h
		db	0C8h, 85h,0C4h,0C7h,0C8h, 88h
		db	0C4h, 66h,0C8h, 06h, 07h,0C8h
		db	 84h,0C4h,0C7h,0C8h,0C7h, 86h
		db	 8Bh,0C4h, 46h,0C8h, 76h,0C8h
		db	 76h, 47h, 88h,0C4h, 05h, 07h
		db	0C8h, 82h,0C4h, 56h,0C8h, 83h
		db	0C4h, 46h,0C8h, 86h, 8Bh,0C4h
		db	 09h, 07h,0C8h, 46h, 47h, 89h
		db	0C4h, 46h,0C8h,0C7h, 47h, 83h
		db	0C4h,0C7h,0C8h, 85h,0C4h, 56h
		db	0C8h, 85h, 8Bh,0C6h, 81h,0C4h
		db	 0Ch, 07h,0C8h,0C7h, 87h,0C4h
		db	 56h,0C8h, 85h,0C6h, 87h,0C4h
		db	0C7h,0C8h,0C7h, 86h, 8Dh,0C4h
		db	 46h,0C8h, 56h, 47h, 82h,0C4h
		db	0C7h,0C8h, 56h, 86h,0C4h, 56h
		db	0C8h, 8Dh,0C4h, 46h, 47h, 85h
		db	 8Dh,0C6h,0C7h,0C8h, 46h,0C8h
		db	 46h,0C8h, 82h,0C4h, 56h,0C8h
		db	 87h,0C4h, 46h,0C8h, 8Eh,0C4h
		db	 46h,0C8h, 86h, 8Fh,0C4h,0C7h
		db	0C8h, 46h,0C8h, 83h,0C4h, 46h
		db	0C8h, 88h,0C4h, 66h, 8Dh,0C4h
		db	0C7h,0C8h, 87h, 8Fh,0C4h,0C7h
		db	 87h,0C4h, 57h, 88h,0C4h, 56h
		db	 8Eh,0C4h,0C8h, 88h, 8Fh,0C4h
		db	 88h,0C4h, 56h, 88h,0C4h, 46h
		db	0C8h, 8Eh,0C4h, 89h, 8Fh,0C6h
		db	 88h,0C4h, 76h, 86h,0C4h,0C8h
		db	 46h,0C8h, 85h,0C3h, 87h,0C6h
		db	 89h, 98h,0C4h,0C7h,0C8h,0C7h
		db	0C8h, 87h,0C4h, 76h, 84h,0C4h
		db	 91h, 0Ah, 01h,0C2h,0C1h,0C2h
		db	 05h, 01h,0C2h, 40h, 81h,0C4h
		db	 46h, 89h,0C4h,0C7h,0C8h,0C7h
		db	0C8h, 85h,0C4h,0C7h,0CAh, 50h
		db	0C2h, 06h, 01h,0C2h, 50h, 98h
		db	0C4h,0C7h, 47h, 88h,0C4h, 46h
		db	0C8h, 86h,0C4h,0C7h, 90h, 98h
		db	0C4h,0C7h,0C8h, 89h,0C4h, 46h
		db	 47h, 85h,0C4h,0C7h,0C8h, 8Eh
		db	0C3h, 98h,0C4h,0C8h, 46h, 88h
		db	0C4h,0C7h,0C8h, 87h,0C4h,0C8h
		db	0C7h,0C8h, 8Dh,0C4h,0C8h, 97h
		db	0C4h, 46h,0C8h, 88h,0C4h, 47h
		db	 87h,0C4h, 56h, 8Dh,0C4h,0C7h
		db	 97h,0C4h, 66h, 87h,0C4h, 46h
		db	 87h,0C4h, 66h, 8Ch,0C4h,0C7h
		db	0C8h, 96h,0C4h, 56h, 88h,0C4h
		db	 56h, 86h,0C4h,0C7h,0C8h,0C7h
		db	0C8h, 8Ch,0C4h,0C7h,0C8h, 96h
		db	0C4h, 46h,0C8h, 88h,0C4h, 46h
		db	0C8h, 86h,0C4h,0C7h,0C8h, 8Eh
		db	0C4h,0C8h,0C7h, 85h,0C3h, 90h
		db	0C4h,0C7h,0C8h, 89h,0C4h,0C7h
		db	0C8h, 87h,0C4h, 46h,0C8h, 88h
		db	0C3h, 84h,0C4h, 46h, 85h,0C4h
		db	 90h,0C4h, 56h, 88h,0C4h, 47h
		db	 87h,0C4h, 56h, 88h,0C4h, 84h
		db	0C4h,0C7h, 47h, 84h,0C4h, 90h
		db	0C4h, 66h, 87h,0C4h, 46h, 87h
		db	0C4h, 66h,0C8h, 86h,0C4h,0C8h
		db	 46h, 81h,0C4h,0C7h,0CAh,0C9h
		db	 84h,0C4h,0C7h, 8Fh,0C4h,0C7h
		db	 47h, 88h,0C4h, 46h,0C8h, 86h
		db	0C4h, 46h,0C8h, 88h,0C4h,0C7h
		db	0C8h, 56h,0C8h, 86h,0C4h,0C7h
		db	0C8h, 8Eh,0C4h, 46h,0C8h, 88h
		db	0C4h, 56h, 86h,0C4h,0C7h,0C8h
		db	0C7h,0C8h, 87h,0C4h, 76h, 87h
		db	0C4h,0C7h, 47h, 8Dh,0C4h,0C7h
		db	0C8h,0C7h, 88h,0C4h,0C8h,0C7h
		db	0C8h, 86h,0C4h, 46h,0C8h, 88h
		db	0C4h, 66h,0C8h, 87h,0C4h, 46h
		db	 8Eh,0C4h, 66h, 87h,0C4h, 47h
		db	 87h,0C4h,0C7h,0C8h, 89h,0C4h
		db	 46h,0C8h, 46h, 87h,0C4h,0C7h
		db	 47h, 8Dh,0C4h,0C8h,0C7h,0C8h
		db	 46h, 86h,0C4h,0C7h, 88h,0C4h
		db	0C7h,0C8h, 89h,0C4h, 56h,0CAh
		db	0C9h, 87h,0C4h, 46h,0C8h, 8Dh
		db	0C4h, 46h,0C8h, 88h,0C4h, 89h
		db	0C4h, 46h, 89h,0C4h,0C7h, 57h
		db	 81h, 87h,0C4h, 66h, 8Ch,0C4h
		db	0C7h,0C8h, 89h,0C6h, 89h,0C4h
		db	 56h,0C8h, 87h,0C4h, 56h,0C8h
		db	 81h, 87h,0C4h, 46h, 57h, 8Bh
		db	0C4h, 46h, 93h,0C4h, 66h, 87h
		db	0C4h, 46h, 47h, 81h, 87h,0C4h
		db	 56h,0C8h, 8Ch,0C4h,0C7h,0C8h
		db	0C7h,0CAh, 50h, 41h, 06h, 01h
		db	0C2h, 50h, 81h,0C4h,0C8h,0C7h
		db	0C8h, 88h,0C4h, 66h,0C8h, 87h
		db	0C4h, 46h,0C8h, 8Dh,0C4h, 56h
		db	0C8h, 46h, 8Fh,0C4h,0C7h,0C8h
		db	 89h,0C4h, 56h,0CAh,0C9h, 87h
		db	0C4h,0C7h,0C8h, 8Eh,0C4h, 66h
		db	 91h,0C4h,0C7h,0C8h, 89h,0C4h
		db	0C7h,0C8h,0C7h,0CAh,0C9h, 87h
		db	0C4h, 56h, 8Dh,0C4h, 46h, 47h
		db	 91h,0C4h, 46h,0C8h, 88h,0C4h
		db	 46h,0C8h, 82h, 87h,0C4h, 56h
		db	0C8h, 8Ch,0C4h,0C7h, 47h,0C7h
		db	 91h,0C4h,0C7h,0C8h, 89h,0C4h
		db	0C7h,0C8h, 83h, 87h,0C4h, 46h
		db	 47h, 8Ch,0C4h, 76h, 90h,0C4h
		db	 46h, 89h,0C4h,0C7h,0C8h, 83h
		db	 87h,0C4h, 66h,0C8h, 8Bh,0C4h
		db	 56h,0C8h, 91h,0C4h, 56h, 88h
		db	0C4h,0C8h, 84h, 87h,0C4h, 76h
		db	 8Bh,0C4h, 46h,0C8h, 92h,0C4h
		db	0C7h,0C8h, 46h, 87h,0C4h,0C7h
		db	 84h, 87h,0C4h, 46h,0C8h,0C7h
		db	0C8h, 8Bh,0C4h,0C8h,0C7h,0C8h
		db	 92h,0C4h, 46h,0C8h, 88h,0C6h
		db	 85h, 87h,0C4h, 56h,0C8h, 8Ch
		db	0C4h, 46h,0C8h,0C7h,0C8h, 90h
		db	0C4h,0C8h, 46h, 8Eh, 40h,0C2h
		db	0C1h,0C2h,0C1h, 81h,0C4h,0C7h
		db	0C8h, 85h,0C3h, 88h,0C4h, 56h
		db	0C8h, 91h,0C4h, 66h,0CAh, 40h
		db	0C2h,0C1h,0C2h, 06h, 01h, 87h
		db	0C4h, 46h,0C8h, 84h,0C4h, 88h
		db	0C4h, 46h,0C8h, 92h,0C4h, 56h
		db	0C8h, 8Dh, 87h,0C4h, 46h,0C8h
		db	 84h,0C4h,0C7h,0C8h, 86h,0C4h
		db	0C7h,0C8h,0C7h, 92h,0C4h,0C7h
		db	 47h, 87h,0C3h, 86h, 87h,0C4h
		db	0C7h,0C8h, 85h,0C4h, 46h, 86h
		db	0C4h,0C8h, 56h, 91h,0C4h,0C7h
		db	0C8h, 88h,0C4h, 86h, 87h,0C4h
		db	0C7h, 86h,0C4h, 46h,0C8h, 85h
		db	0C4h, 56h,0C8h, 91h,0C4h, 56h
		db	 87h,0C4h,0C8h, 85h, 87h,0C4h
		db	 87h,0C4h, 56h,0C8h, 84h,0C4h
		db	 46h,0C8h,0C7h, 91h,0C4h, 46h
		db	0C8h, 87h,0C4h,0C7h, 85h, 87h
		db	0C6h, 87h,0C4h, 66h, 84h,0C4h
		db	 76h,0CAh,0C1h,0C2h, 05h, 01h
		db	0C2h, 70h, 81h,0C4h,0C7h,0C8h
		db	0C7h, 87h,0C4h, 47h, 84h, 8Fh
		db	0C4h, 46h,0C8h,0C7h,0C8h, 83h
		db	0C4h,0C8h, 46h,0C8h, 91h,0C4h
		db	 66h,0C8h, 85h,0C4h,0C7h,0C8h
		db	 84h, 8Fh,0C4h, 76h,0CAh,0C9h
		db	 81h,0C4h, 56h, 8Ah,0C3h, 87h
		db	0C4h, 76h, 85h,0C4h, 46h,0C8h
		db	 83h, 8Fh,0C4h, 66h,0C8h, 66h
		db	 57h, 8Ah,0C4h,0C7h, 86h,0C4h
		db	0C7h,0C8h,0C7h,0C8h, 86h,0C4h
		db	 46h,0C8h, 83h, 8Fh,0C4h, 09h
		db	 07h,0C8h, 8Bh,0C4h,0C7h, 86h
		db	0C4h, 46h,0C8h, 87h,0C4h, 56h
		db	0C8h, 82h, 8Fh,0C4h, 66h,0C8h
		db	 07h, 07h, 89h,0C4h, 46h, 85h
		db	0C4h,0C7h,0C8h, 88h,0C4h,0C7h
		db	0C8h, 46h,0C8h, 81h, 8Fh,0C4h
		db	 76h,0CAh,0C9h, 81h,0C4h, 76h
		db	 88h,0C4h, 56h, 84h,0C4h,0C7h
		db	 84h,0C3h, 84h,0C4h, 56h,0C8h
		db	 82h, 8Fh,0C4h, 46h,0C8h,0C7h
		db	0C8h, 83h,0C4h,0C8h,0C7h, 47h
		db	 89h,0C4h,0C8h, 46h,0C8h, 83h
		db	0C4h, 85h,0C4h, 83h,0C3h, 46h
		db	0C8h,0C7h,0C8h, 82h, 8Fh,0C4h
		db	 66h, 84h,0C4h, 46h,0C8h, 8Ah
		db	0C4h, 46h, 47h, 83h,0C6h, 85h
		db	0C4h, 06h, 07h,0C8h, 83h, 8Fh
		db	0C4h, 56h,0C8h, 84h,0C4h,0C7h
		db	 47h, 8Ah,0C4h,0C7h,0C8h, 46h
		db	 89h,0C4h, 56h,0CAh,0C9h,0C4h
		db	 47h, 83h, 8Fh,0C4h, 46h,0C8h
		db	 85h,0C4h, 46h,0C8h, 8Ah,0C4h
		db	 56h,0C8h,0C7h, 88h,0C4h, 56h
		db	0C8h, 66h, 83h, 87h,0C3h, 87h
		db	0C4h, 46h, 86h,0C4h, 66h, 89h
		db	0C4h, 06h, 07h, 86h,0C4h,0C8h
		db	 06h, 07h,0C8h, 82h, 87h,0C4h
		db	 87h,0C4h,0C7h,0C8h, 86h,0C4h
		db	 46h, 47h, 89h,0C4h, 66h, 47h
		db	 87h,0C4h, 83h,0C6h, 46h,0C8h
		db	 46h, 82h, 87h,0C4h,0C7h, 86h
		db	0C4h, 88h,0C4h,0C8h,0C7h,0C8h
		db	 8Ah,0C4h,0C7h,0C8h,0C7h,0C8h
		db	 89h,0C6h, 84h,0C4h, 46h, 47h
		db	 82h, 87h,0C4h, 46h, 85h,0C6h
		db	 88h,0C4h,0C7h, 8Ch,0C4h, 46h
		db	0C8h, 46h,0C8h, 8Ch,0C4h,0C7h
		db	0C8h, 84h, 87h,0C4h,0C7h, 57h
		db	 8Ch,0C4h, 8Dh,0C4h,0C7h,0C8h
		db	 66h, 8Ch,0C4h, 47h, 84h, 87h
		db	0C4h, 66h,0C8h, 8Bh,0C6h, 8Dh
		db	0C4h, 56h, 57h, 8Ch,0C4h,0C7h
		db	0C8h, 84h, 87h,0C4h, 56h,0C8h
		db	 46h, 98h,0C4h, 66h,0C8h, 8Dh
		db	0C4h, 46h,0C8h, 83h, 87h,0CEh
		db	 76h,0C8h, 46h,0CAh,0C1h,0C2h
		db	 60h,0C2h,0C1h,0C2h, 06h, 01h
		db	0C2h, 50h, 81h,0C4h, 56h,0C8h
		db	 8Eh,0C4h,0C7h,0C8h,0C7h,0C8h
		db	 82h, 88h,0CEh, 05h, 07h,0C8h
		db	 96h,0C4h, 46h,0C8h,0C7h,0C8h
		db	 8Dh,0C4h, 66h,0C8h, 81h, 89h
		db	0CEh, 06h, 07h,0C8h, 84h,0C3h
		db	 8Fh,0C4h, 05h, 07h, 8Ch,0C4h
		db	 56h,0C8h, 82h, 8Ah,0CEh,0C7h
		db	0C8h, 76h,0C8h, 83h,0C4h, 8Fh
		db	0C4h, 56h,0C8h, 8Eh,0C4h,0C7h
		db	 47h, 83h, 8Bh,0C4h, 66h,0C8h
		db	 85h,0C4h, 8Fh,0C4h,0C7h,0C8h
		db	 46h,0C8h, 8Dh,0C4h, 56h,0C8h
		db	 82h, 8Bh,0C4h, 46h,0C8h, 46h
		db	0C8h, 84h,0C4h,0C7h, 8Eh,0C4h
		db	 46h, 47h, 8Eh,0C4h,0C7h,0C8h
		db	 56h,0C8h,0C7h, 8Ah,0C4h, 56h
		db	 47h, 85h,0C4h,0C7h,0C8h, 8Dh
		db	0C4h, 66h,0C8h, 8Dh,0C4h, 05h
		db	 07h, 8Bh,0C4h, 05h, 07h, 84h
		db	0C4h, 46h, 8Dh,0C4h, 76h,0CAh
		db	 50h, 41h, 05h, 01h, 81h,0C4h
		db	0C7h, 47h,0C7h, 47h, 8Bh,0C4h
		db	0C8h, 46h,0C8h,0C7h, 85h,0C4h
		db	0C7h,0C8h, 8Dh,0C4h, 46h,0C8h
		db	0C7h,0C8h, 8Dh,0C4h, 46h,0C8h
		db	 83h, 8Bh,0C4h, 46h,0C8h,0C7h
		db	0C8h, 85h,0C4h,0C7h, 47h, 8Ch
		db	0C4h,0C7h, 47h, 88h,0C3h, 86h
		db	0C4h,0C7h,0C8h, 84h, 8Bh,0C4h
		db	 66h,0C8h, 85h,0C4h, 46h, 47h
		db	 8Bh,0C4h,0C7h, 8Ah,0C4h, 86h
		db	0C4h, 46h,0C8h, 83h, 8Bh,0C4h
		db	 46h, 47h, 86h,0C4h,0C7h,0C8h
		db	0C7h, 47h, 8Ah,0C6h, 8Bh,0C4h
		db	0C7h, 85h,0C4h, 56h,0C8h, 82h
		db	 8Bh,0C4h, 56h, 47h, 85h,0C4h
		db	 76h, 96h,0C4h, 47h, 84h,0C4h
		db	 76h,0C8h, 8Bh,0C4h,0C7h,0C8h
		db	0C7h,0C8h, 86h,0C4h, 46h,0C8h
		db	 46h,0CAh, 40h,0C2h, 40h,0C2h
		db	 09h, 01h,0C2h, 50h, 81h,0C4h
		db	 46h,0C8h, 83h,0C4h, 56h, 47h
		db	 81h, 82h,0C3h, 46h, 86h,0C6h
		db	 8Ah,0C4h,0C7h, 47h, 98h,0C4h
		db	 46h,0C8h,0C7h, 82h, 46h,0C8h
		db	 46h, 82h,0C7h,0C8h, 56h, 91h
		db	0C4h, 66h,0C8h, 8Ch,0C3h, 89h
		db	0C4h, 66h, 82h, 66h,0C8h, 46h
		db	 46h,0C8h, 46h,0CAh, 0Eh, 01h
		db	 81h,0C4h, 46h,0C8h, 8Eh,0C4h
		db	 89h,0C4h, 08h, 07h,0C8h, 56h
		db	0C8h, 76h,0CAh,0C9h, 8Eh,0C4h
		db	0C7h,0C8h, 8Fh,0C4h,0C7h, 88h
		db	0C4h, 07h, 07h,0C8h, 66h, 81h
		db	0C6h, 07h, 07h, 81h,0C3h, 8Ah
		db	0C4h,0C7h,0C8h, 8Fh,0C4h,0C7h
		db	0C8h, 87h,0C4h, 56h, 47h, 46h
		db	0CAh,0C9h, 84h, 84h,0C4h, 46h
		db	0C8h,0C7h,0C8h, 81h,0C4h,0C8h
		db	 89h,0C4h, 46h,0CAh,0C9h, 8Dh
		db	0C4h,0C7h,0C8h, 87h,0C4h, 76h
		db	 88h, 84h,0C4h, 76h,0C8h, 46h
		db	0C8h, 88h,0C4h,0C7h, 47h, 8Eh
		db	0C4h, 46h, 87h,0C4h,0C7h,0C8h
		db	 46h,0C8h, 88h, 84h,0C4h, 56h
		db	0C8h,0C7h,0C8h,0C7h,0C8h, 89h
		db	0C4h, 66h,0C8h, 8Ch,0C4h, 46h
		db	0C8h, 86h,0C4h, 46h, 47h, 89h
		db	 84h,0C4h,0C7h,0C8h, 66h,0C8h
		db	 8Ah,0C4h, 46h, 47h, 8Dh,0C4h
		db	0C7h,0C8h,0C7h, 86h,0C4h,0C7h
		db	0C8h,0C7h, 8Ah, 84h,0C6h, 84h
		db	0C4h, 46h,0C8h, 84h,0C3h, 83h
		db	0C3h, 56h, 8Fh,0C4h, 66h, 85h
		db	0C4h, 76h, 88h, 89h,0C4h,0C7h
		db	0C8h, 46h, 83h,0C4h, 05h, 07h
		db	0C8h,0CAh,0C9h, 8Dh,0C4h, 56h
		db	0C8h, 85h,0C4h, 66h,0C8h, 88h
		db	 89h,0C4h, 56h,0C8h, 83h,0C4h
		db	 06h, 07h,0CAh,0C9h, 8Dh,0C4h
		db	0C7h, 47h, 86h,0C4h, 47h,0C7h
		db	0C8h, 89h, 89h,0C4h,0C7h,0C8h
		db	0C7h, 84h,0C6h, 83h,0C6h, 46h
		db	0C8h, 46h,0C8h, 46h, 8Ah,0C4h
		db	 46h,0C8h, 86h,0C4h, 46h, 47h
		db	 89h, 89h,0C4h,0C7h, 57h, 88h
		db	0C4h, 05h, 07h,0C8h, 8Ah,0C4h
		db	0C7h, 47h, 86h,0C4h, 56h,0C8h
		db	 89h, 89h,0C4h, 46h,0C8h, 89h
		db	0C4h, 56h,0C8h,0C7h,0C8h, 8Bh
		db	0C4h, 46h, 87h,0C4h, 56h,0C8h
		db	 89h, 89h,0C4h,0C8h, 8Bh,0C4h
		db	0C8h,0C7h, 47h, 81h,0C8h, 8Bh
		db	0C4h,0C7h,0C8h,0C7h, 86h,0C4h
		db	 46h,0C8h,0C7h, 89h, 05h, 01h
		db	0C2h,0C1h, 81h,0C4h,0C7h, 47h
		db	 89h,0C4h,0C7h,0C8h, 46h, 47h
		db	 8Bh,0C4h, 66h, 85h,0C4h, 66h
		db	0CAh, 50h,0C2h,0C1h,0C2h,0C1h
		db	0C2h, 89h,0C4h,0C7h,0C8h, 8Ah
		db	0C4h, 46h,0C8h, 56h,0C8h, 8Ah
		db	0C4h,0C7h,0C8h,0C7h,0C8h, 85h
		db	0C4h, 56h,0C8h, 89h, 84h,0C3h
		db	 84h,0C4h,0C7h,0C8h, 8Ah,0C4h
		db	 76h,0C8h, 8Bh,0C4h, 46h,0C8h
		db	 86h,0C4h,0C8h, 56h,0C8h, 88h
		db	 84h,0C4h,0C7h, 83h,0C4h, 8Ch
		db	0C4h, 56h,0C8h,0C7h, 8Ch,0C4h
		db	 46h,0C8h, 86h,0C4h, 46h, 47h
		db	 89h, 84h,0C4h, 46h, 82h,0C6h
		db	 8Ch,0C4h, 46h,0C8h, 56h, 47h
		db	 89h,0C4h,0C7h,0C8h, 87h,0C4h
		db	0C7h, 47h, 8Ah, 84h,0C4h, 46h
		db	 8Fh,0C4h,0C7h, 47h,0C7h,0C8h
		db	 56h,0C8h,0C7h, 87h,0C4h, 56h
		db	0C8h, 85h,0C4h, 46h,0C8h, 8Ah
		db	 84h,0C4h, 46h, 8Fh,0C4h, 46h
		db	0C8h, 56h,0C8h, 56h, 87h,0C4h
		db	0C7h,0C8h, 46h, 85h,0C4h,0C7h
		db	0C8h, 46h,0C8h, 88h, 84h,0C4h
		db	 46h,0C8h, 8Eh,0C4h, 56h,0C8h
		db	 46h,0C8h, 76h, 85h,0C4h, 46h
		db	 47h, 85h,0C4h, 56h,0C8h, 89h
		db	 84h,0C4h, 05h, 07h, 8Bh,0C4h
		db	 46h,0C8h,0C7h,0C8h, 83h,0C4h
		db	 66h, 84h,0C4h,0C7h,0C8h, 87h
		db	0C4h, 46h,0C8h, 46h,0C8h, 87h
		db	 84h,0C4h, 66h,0C8h, 8Ch,0C4h
		db	0C8h,0C7h,0C8h, 85h,0C4h,0C7h
		db	 57h, 46h, 82h, 56h, 87h,0C4h
		db	 66h, 47h, 87h, 84h,0C4h,0C7h
		db	0C8h,0C7h,0C8h, 8Dh,0C4h, 88h
		db	0C4h, 66h,0C8h,0C7h, 82h, 46h
		db	0C8h, 87h,0C4h, 56h,0C8h,0C7h
		db	0C8h, 87h, 84h,0C4h,0C7h,0C8h
		db	 8Fh,0C6h, 88h,0C4h, 09h, 07h
		db	 47h, 85h,0C3h, 56h, 47h, 89h
		db	 50h, 81h,0C4h, 46h,0C8h, 97h
		db	0C4h,0C8h, 0Ah, 07h,0C8h, 84h
		db	0C4h,0C7h,0CAh,0C1h,0C2h, 06h
		db	 01h,0C2h, 40h, 84h,0C4h, 66h
		db	 96h,0C4h,0C7h,0C8h,0C7h,0C8h
		db	0C7h,0C8h, 56h,0C8h,0C7h, 47h
		db	 83h,0C3h, 46h,0C8h, 8Ch, 84h
		db	0C4h, 56h, 97h,0C4h, 76h,0C8h
		db	 66h,0C8h, 56h, 82h, 46h,0C8h
		db	0C7h,0C8h, 84h,0C3h, 86h, 84h
		db	0C4h, 46h, 98h,0C4h, 66h,0C8h
		db	 66h,0C8h, 66h, 82h, 46h, 47h
		db	 85h,0C4h, 86h, 84h,0C4h, 46h
		db	0C8h, 97h,0C4h, 56h, 67h, 0Ah
		db	 07h,0C8h, 86h,0C4h, 86h, 84h
		db	0C4h, 46h, 98h,0C4h, 46h,0C8h
		db	 06h, 07h,0C8h, 46h,0C8h, 56h
		db	 47h, 86h,0C4h, 86h, 84h,0C4h
		db	0C7h,0C8h, 98h,0C4h,0C7h,0C8h
		db	 66h, 47h,0C7h,0CAh,0C9h, 83h
		db	0C4h, 56h,0C8h, 86h,0C4h,0C7h
		db	0C8h, 84h, 84h,0C4h, 46h, 98h
		db	0C4h, 76h,0C8h,0CAh,0C9h, 86h
		db	0C4h, 56h, 47h, 85h,0C4h,0C7h
		db	0C8h, 84h, 84h,0C4h, 46h,0C8h
		db	 97h,0C4h, 56h, 57h, 88h,0C4h
		db	 46h,0C8h, 87h,0C4h,0C7h,0C8h
		db	0C7h, 83h, 84h,0C4h,0C7h,0C8h
		db	0C7h, 97h,0C4h,0C7h,0C8h, 46h
		db	 47h, 88h,0C4h, 46h,0C8h, 87h
		db	0C4h, 56h, 83h, 84h,0C4h, 76h
		db	0CAh,0C1h,0C2h, 70h,0C2h,0C1h
		db	0C2h, 70h,0C2h, 50h, 81h,0C4h
		db	0C8h, 66h, 89h,0C4h, 56h,0CAh
		db	0C9h, 85h,0C4h, 46h,0C8h, 83h
		db	 84h,0C4h, 76h, 95h,0C4h,0C7h
		db	0C8h,0C7h,0C8h, 8Ah,0C4h, 56h
		db	0CAh,0C9h, 85h,0C4h, 56h, 83h
		db	 84h,0C4h, 56h,0C8h, 88h,0C3h
		db	 8Dh,0C4h, 46h,0C8h,0C7h, 8Ah
		db	0C4h, 56h,0CAh,0C9h, 85h,0C4h
		db	0C7h,0C8h,0C7h,0C8h, 82h, 84h
		db	0C4h,0C7h, 47h, 89h,0C4h,0C8h
		db	 8Ch,0C4h,0C7h, 8Dh,0C4h,0C7h
		db	0C8h,0C7h,0CAh,0C9h, 85h,0C4h
		db	 56h, 47h, 81h, 84h,0C4h, 46h
		db	 8Ah,0C4h,0C7h, 8Ch,0C4h, 8Eh
		db	0C4h, 56h,0CAh,0C9h, 85h,0C4h
		db	 46h,0C8h, 83h, 84h,0C4h, 46h
		db	 8Ah,0C4h,0C8h, 8Ch,0C6h, 8Eh
		db	0C4h, 56h, 87h,0C4h, 56h, 83h
		db	 84h,0C4h,0C7h, 8Bh,0C4h,0C7h
		db	 9Bh,0C4h, 46h,0C8h,0C7h, 86h
		db	0C4h, 56h, 83h, 84h,0C4h, 46h
		db	 8Ah,0C4h,0C7h,0C8h, 9Ah,0C4h
		db	0C7h,0C8h, 46h, 86h,0C4h, 56h
		db	0C8h, 82h, 84h,0C4h,0C7h, 47h
		db	 89h,0C4h, 46h,0C8h, 99h,0C4h
		db	 56h, 47h, 85h,0C4h,0C7h, 47h
		db	 83h, 82h,0C3h, 81h,0C4h, 66h
		db	 88h,0C4h,0C7h, 47h, 99h,0C4h
		db	 66h, 47h, 84h,0C4h, 46h, 84h
		db	 82h,0C4h, 05h, 07h, 88h,0C4h
		db	 56h,0C8h, 98h,0C4h, 06h, 07h
		db	0C8h, 82h,0C4h, 56h, 83h, 81h
		db	0CBh,0C4h,0C7h,0C8h, 46h, 47h
		db	 88h,0C4h, 56h, 8Ah,0C3h, 8Eh
		db	0C4h, 76h,0C8h, 07h, 07h,0C8h
		db	 82h,0CBh,0CCh,0C4h, 46h,0C8h
		db	0C7h,0C8h, 89h,0C4h, 76h, 88h
		db	0C4h, 8Eh,0C4h, 0Bh, 07h, 47h
		db	 83h,0CBh,0CCh,0C4h, 46h, 47h
		db	 8Ah,0C4h,0C7h,0C8h,0C7h,0C8h
		db	 89h,0C4h, 46h, 8Ch,0C4h,0C7h
		db	 88h,0C4h, 56h,0C8h, 83h,0CBh
		db	0CCh,0C4h, 05h, 07h,0C8h, 87h
		db	0C4h, 46h,0C8h, 8Ah,0C4h, 76h
		db	 89h,0C6h, 89h,0C4h, 66h, 83h
		db	0CBh,0CCh,0C4h, 56h,0C8h, 46h
		db	 47h, 86h,0C4h,0C7h, 47h, 8Ah
		db	0C4h, 56h,0C8h, 46h, 92h,0C4h
		db	 66h, 83h,0CBh,0CCh,0C4h,0C7h
		db	 47h, 76h,0C8h,0C7h,0C8h, 83h
		db	0C4h, 46h,0C8h, 8Ah,0C4h,0C7h
		db	 47h, 46h,0C8h, 92h,0C4h, 56h
		db	0C8h, 83h,0CBh,0CCh,0C4h, 56h
		db	 47h, 76h,0C8h, 83h,0C4h, 66h
		db	0C8h, 88h,0C4h,0C8h, 46h,0CAh
		db	0C9h, 93h,0C4h,0C7h, 47h, 84h
		db	0CBh,0CCh,0C4h, 56h, 83h,0C4h
		db	0C7h,0C8h,0C7h, 84h,0C4h, 56h
		db	0C8h, 89h,0C4h, 56h,0CAh,0C9h
		db	 93h,0C4h, 46h,0C8h, 84h,0CBh
		db	0CCh,0C4h, 46h, 84h,0C4h, 56h
		db	 84h,0C4h, 57h, 8Ah,0C4h, 56h
		db	0CAh, 50h, 41h, 08h, 01h,0C2h
		db	 60h, 81h,0C4h, 66h,0C8h, 82h
		db	0CBh,0CCh,0C4h, 46h, 84h,0C4h
		db	 46h,0C8h, 84h,0C4h,0C7h,0C8h
		db	 8Bh,0C4h, 05h, 07h, 92h,0C4h
		db	 56h,0C8h, 83h, 81h,0CBh,0C4h
		db	 86h,0C4h, 46h,0C8h, 84h,0C4h
		db	0C7h,0C8h, 8Bh,0C4h, 46h,0C8h
		db	0C7h,0C8h, 88h,0C3h, 8Ah,0C4h
		db	 46h,0C8h,0C7h, 83h, 82h,0C6h
		db	 86h,0C4h,0C7h,0C8h, 85h,0C4h
		db	0C8h, 8Ch,0C4h, 56h,0C8h, 89h
		db	0C4h, 8Ah,0C4h, 56h, 84h, 89h
		db	0C4h, 46h, 85h,0C4h,0C7h,0C8h
		db	 8Bh,0C4h, 66h, 89h,0C4h, 8Ah
		db	0C4h, 66h, 83h, 89h,0C4h, 46h
		db	0C8h, 84h,0C4h,0C7h,0C8h, 8Bh
		db	0C4h,0C7h,0C8h,0C7h,0C8h, 89h
		db	0C4h,0C7h, 89h,0C4h, 66h,0C8h
		db	 82h, 89h,0C4h,0C7h,0C8h, 85h
		db	0C4h, 46h,0C8h, 8Ah,0C4h, 46h
		db	0C8h,0C7h,0C8h, 88h,0C4h,0C7h
		db	0C8h, 88h,0C4h, 46h,0C8h,0C7h
		db	 83h, 89h,0C4h, 46h,0C8h, 84h
		db	0C4h, 56h,0C8h, 89h,0C4h, 56h
		db	0C8h, 89h,0C4h, 46h,0C8h, 87h
		db	0C4h, 66h, 83h, 89h,0C4h, 56h
		db	 84h,0C4h, 46h,0C8h, 8Ah,0C4h
		db	 46h, 47h, 89h,0C4h, 56h, 87h
		db	0C4h, 56h,0C8h, 83h, 89h,0C4h
		db	 56h,0C8h, 83h,0C4h,0C7h,0C8h
		db	 8Bh,0C4h,0C7h,0C8h,0C7h,0C8h
		db	 89h,0C4h,0C7h,0C8h,0C7h,0CAh
		db	0C9h, 85h,0C4h, 66h,0C8h, 82h
		db	 89h,0C4h, 56h,0C8h, 83h,0C4h
		db	 46h,0C8h, 8Ah,0C4h,0C8h, 46h
		db	 47h, 88h,0C4h, 66h,0C8h, 85h
		db	0C4h, 46h, 47h, 83h, 89h,0C4h
		db	0C7h, 47h, 84h,0C4h,0C7h,0C8h
		db	 8Bh,0C4h, 56h, 47h, 88h,0C4h
		db	 46h, 47h, 86h,0C4h,0C7h, 47h
		db	 84h, 89h,0C4h, 46h, 85h,0C4h
		db	 46h, 47h, 89h,0C4h, 66h, 89h
		db	0C4h, 76h, 85h,0C4h, 56h, 84h
		db	 89h,0C4h,0C7h,0C8h, 85h,0C4h
		db	0C7h,0C8h,0C7h, 8Ah,0C4h, 66h
		db	0C8h, 88h,0C4h, 56h, 47h, 85h
		db	0C4h, 66h,0C8h, 82h, 89h,0C4h
		db	 46h,0C8h, 84h,0C4h, 56h, 8Ah
		db	0C4h, 56h,0C8h,0C7h, 88h,0C4h
		db	 66h, 86h,0C4h, 66h, 83h, 89h
		db	0C4h,0C7h, 57h, 83h,0C4h, 46h
		db	 47h, 89h,0C4h, 56h,0C8h, 89h
		db	0C4h,0C7h,0C8h,0C7h,0C8h, 86h
		db	0C4h, 46h,0C8h,0C7h,0C8h, 82h
		db	 89h,0C4h, 46h, 47h, 83h,0C4h
		db	 56h, 8Ah,0C4h,0C8h, 56h,0C8h
		db	 88h,0C4h, 56h, 87h,0C4h, 46h
		db	0C8h,0C7h, 83h, 89h,0C4h, 56h
		db	0C8h, 83h,0C4h,0C7h, 47h, 8Ah
		db	0C4h, 47h, 46h,0C8h, 88h,0C4h
		db	0C7h,0C8h, 88h,0C4h, 56h, 47h
		db	 82h, 89h,0C4h, 56h,0C8h, 83h
		db	0C4h,0C7h,0C2h, 05h, 01h,0C2h
		db	 40h, 82h,0C4h, 46h,0C8h, 46h
		db	 88h,0C4h, 46h,0C8h, 87h,0C4h
		db	 56h, 47h, 82h, 89h,0C4h,0C7h
		db	 47h, 84h,0C4h,0C7h,0C8h, 8Bh
		db	0C4h,0C7h,0C8h, 56h,0C8h, 87h
		db	0C4h, 56h,0C8h, 86h,0C4h,0C7h
		db	0C8h,0C7h,0C8h, 83h, 89h,0C4h
		db	 46h, 85h,0C4h,0C7h,0C8h, 83h
		db	0C3h, 87h,0C4h, 76h, 88h,0C4h
		db	0C8h,0C7h,0C8h,0C7h, 86h,0C4h
		db	 46h,0C8h, 84h, 89h,0C4h,0C7h
		db	 47h, 84h,0C4h,0C8h, 84h,0C4h
		db	 87h,0C4h, 66h,0C8h, 88h,0C4h
		db	 66h,0C8h, 85h,0C4h,0C7h,0C8h
		db	 85h, 89h,0C4h, 46h, 85h,0C4h
		db	 85h,0C4h, 87h,0C4h, 66h,0C8h
		db	 88h,0C4h, 76h, 85h,0C4h, 87h
		db	 89h,0C4h,0C7h,0C8h, 85h,0C6h
		db	 85h,0C4h,0C7h, 86h,0C4h, 56h
		db	0C8h, 89h,0C4h, 76h, 85h,0C4h
		db	 87h, 89h,0C4h, 46h,0C8h, 8Ah
		db	0C4h,0C7h, 86h,0C4h, 56h,0C8h
		db	 89h,0C4h, 46h,0C8h,0C7h,0C8h
		db	 85h,0C6h, 87h, 89h,0C4h, 46h
		db	0CAh, 70h,0C2h, 50h, 81h,0C4h
		db	0C7h,0CAh,0C9h, 84h,0C4h, 56h
		db	0C8h, 89h,0C4h, 56h, 8Fh, 89h
		db	0C4h, 46h, 8Bh,0C4h, 46h, 85h
		db	0C4h, 56h,0C8h, 89h,0C4h, 56h
		db	0C8h, 8Eh, 89h,0C4h,0C7h, 47h
		db	 8Ah,0C4h,0C7h,0C8h, 85h,0C4h
		db	0C7h,0C8h,0C7h,0C8h, 89h,0C4h
		db	 46h, 47h, 8Eh, 89h,0C4h, 46h
		db	0C8h, 8Ah,0C4h, 46h, 85h,0C4h
		db	 66h, 89h,0C4h, 46h,0C8h, 8Fh
		db	 89h,0C4h,0C8h,0C7h, 8Bh,0C4h
		db	 46h,0C8h, 84h,0C4h, 46h,0C8h
		db	0C7h, 47h, 87h,0C4h, 46h,0C8h
		db	 8Fh, 89h,0C4h,0C7h,0C8h, 8Bh
		db	0C4h, 56h, 84h,0C4h,0C7h,0C8h
		db	 46h,0C8h, 88h,0C4h,0C7h,0C8h
		db	0C7h, 8Fh, 89h,0C4h, 46h, 8Bh
		db	0C4h,0C7h,0C8h,0C7h, 84h,0C4h
		db	 56h, 47h, 88h,0C4h, 56h, 8Fh
		db	 89h,0C4h,0C7h, 47h, 8Ah,0C4h
		db	 56h,0C8h, 83h,0C4h, 46h,0C8h
		db	 46h, 88h,0C4h, 66h,0C8h, 8Dh
		db	 89h,0C4h, 46h,0C8h, 8Ah,0C4h
		db	 46h,0C8h, 84h,0C4h, 05h, 07h
		db	 87h,0C4h, 76h,0C8h, 8Ch, 89h
		db	0C4h, 46h, 8Bh,0C4h, 56h, 84h
		db	0C4h, 66h,0C8h, 88h,0C4h,0C7h
		db	0C8h, 46h,0C8h, 8Dh, 89h,0C4h
		db	 56h, 8Ah,0C4h, 46h,0C8h, 84h
		db	0C4h,0C7h,0C8h,0C7h,0CAh,0C9h
		db	 88h,0C4h, 46h,0C8h,0C7h, 8Eh
		db	 89h,0C4h,0C7h, 47h, 8Ah,0C4h
		db	0C7h,0C8h, 85h,0C4h, 46h,0C8h
		db	 8Ah,0C4h, 56h,0C8h, 8Eh, 89h
		db	0C4h, 46h, 8Bh,0C4h, 56h, 84h
		db	0C4h,0C7h,0C8h,0C7h, 8Ah,0C4h
		db	 56h, 8Fh, 89h,0C4h,0C7h,0C8h
		db	 8Bh,0C4h,0C7h,0C8h,0C7h, 84h
		db	0C4h, 46h, 8Bh,0C4h,0C7h, 47h
		db	 8Fh, 89h,0C4h,0C8h, 8Ch,0C4h
		db	 56h,0C8h, 83h,0C4h,0C7h, 47h
		db	 8Ah,0C4h, 46h, 90h, 89h,0C4h
		db	0C7h,0C8h, 8Bh,0C4h, 46h,0C8h
		db	 84h,0C4h,0C8h, 56h, 89h,0C4h
		db	0C7h,0C8h, 8Fh,0C3h, 89h,0C4h
		db	0C8h, 8Ch,0C4h,0C7h,0C8h, 85h
		db	0C4h,0CAh, 06h, 01h,0C2h, 50h
		db	 81h,0C4h,0CAh, 50h,0C2h, 05h
		db	 01h, 41h, 50h, 81h,0C4h,0C7h
		db	 88h,0C4h, 8Dh,0C4h, 56h, 84h
		db	0C4h,0C7h,0C8h, 8Bh,0C4h, 91h
		db	0C4h,0C7h, 88h,0C6h, 8Dh,0C4h
		db	 56h,0C8h, 83h,0C4h, 86h,0C3h
		db	 86h,0C4h, 87h,0C3h, 89h,0C4h
		db	 46h, 95h,0C4h,0C7h,0C8h,0C7h
		db	0C8h, 83h,0C6h, 86h,0C4h, 86h
		db	0C6h, 87h,0C4h, 89h,0C4h, 56h
		db	0CAh, 05h, 01h,0C2h, 07h, 01h
		db	0C2h, 40h, 81h,0C4h, 46h,0C8h
		db	 8Ah,0CBh,0C5h,0C7h, 8Dh,0C4h
		db	 46h,0C8h, 86h,0C4h, 46h,0C8h
		db	 94h,0C4h, 46h,0C8h, 89h,0CBh
		db	0CCh,0C5h, 46h, 8Ch,0C4h, 56h
		db	0C8h, 85h,0C4h,0C7h,0C8h, 8Bh
		db	0C3h, 89h,0C4h, 56h, 89h,0CBh
		db	0CCh,0C5h, 46h,0C8h, 8Bh,0C4h
		db	0C7h, 47h, 86h,0C4h, 47h, 8Bh
		db	0C4h, 89h,0C4h, 66h, 88h,0CBh
		db	0CCh,0C5h, 66h, 8Ah,0C4h, 46h
		db	0C8h, 86h,0C4h, 46h, 8Bh,0C4h
		db	0C8h, 88h,0C4h,0C7h,0C8h,0C7h
		db	0C8h, 88h,0CBh,0CCh,0C5h, 56h
		db	0C8h, 8Ah,0C4h, 56h,0C8h, 85h
		db	0C4h,0C8h, 46h, 8Ah,0C4h,0C7h
		db	 88h,0C4h, 56h, 89h,0CBh,0CCh
		db	0C5h,0C7h, 47h, 8Bh,0C4h,0C7h
		db	 47h,0C7h, 85h,0C4h, 76h, 88h
		db	0C4h,0C7h,0C8h, 87h,0C4h, 46h
		db	0C8h, 89h,0CBh,0CCh,0C5h, 46h
		db	0CAh,0C9h, 8Ah,0C4h, 56h,0C8h
		db	0C7h, 84h,0C4h, 46h, 47h, 89h
		db	0C4h, 46h,0C8h, 86h,0C4h,0C7h
		db	0C8h, 8Ah,0CBh,0CCh,0C5h,0C7h
		db	0CAh,0C9h, 8Bh,0C4h, 66h,0C8h
		db	 84h,0C4h,0C7h,0C8h,0C7h,0C8h
		db	 89h,0C4h,0C8h, 46h,0C8h, 85h
		db	0C4h, 46h, 47h, 88h,0CBh,0CCh
		db	0C5h, 46h,0C8h, 8Bh,0C4h, 66h
		db	 85h,0C4h, 56h, 8Ah,0C4h,0C7h
		db	0C8h, 87h,0C4h, 56h, 89h,0CBh
		db	0CCh,0C5h, 56h,0C8h, 8Ah,0C4h
		db	 46h, 47h, 85h,0C4h, 46h,0C8h
		db	 46h, 88h,0C4h, 46h, 87h,0C4h
		db	0C7h,0C8h,0C7h, 89h,0CBh,0CCh
		db	0C5h, 46h,0C8h, 8Bh,0C4h, 46h
		db	0CAh,0C9h, 85h,0C4h, 56h,0C8h
		db	 89h,0C4h,0C7h,0C8h, 87h,0C4h
		db	0C8h,0C7h, 47h, 88h,0CBh,0CCh
		db	0C5h,0C7h,0C8h, 46h, 8Ah,0C4h
		db	0C7h,0C8h,0C7h,0CAh,0C9h, 84h
		db	0C4h,0FFh,0FFh,0FFh,0FFh, 23h
		db	 40h, 97h, 1Eh, 00h, 2Ah, 00h
		db	 3Bh, 40h, 8Dh, 34h, 00h, 42h
		db	 00h, 5Eh, 40h, 2Ch, 3Fh, 00h
		db	 7Bh, 00h, 67h, 80h, 9Ah, 5Fh
		db	 00h, 6Eh, 00h,0B2h, 40h, 88h
		db	0ADh, 00h,0B8h, 00h, 38h, 81h
		db	0A0h, 32h, 01h, 00h, 00h,0FFh
		db	0FFh, 16h, 00h, 09h, 83h, 09h
		db	 38h, 00h, 37h, 00h,0FFh,0FFh
		db	0FFh, 56h, 00h, 09h, 02h, 09h
		db	 10h, 00h, 09h, 00h, 1Bh, 00h
		db	 80h, 56h, 00h, 15h, 80h, 04h
		db	 04h, 00h,0FFh, 00h,0FFh,0FFh
		db	0FFh, 77h, 00h, 15h, 83h, 09h
		db	 10h, 00h, 22h, 00h,0FFh,0FFh
		db	0FFh,0E0h, 00h, 12h, 01h, 0Ah
		db	 1Bh, 00h, 0Eh, 00h, 1Bh, 00h
		db	 40h,0F5h, 00h, 35h, 84h, 09h
		db	0AEh, 00h, 33h, 00h,0FFh,0FFh
		db	0FFh,0FFh,0FFh, 18h, 00h,0FFh
		db	 13h,0C0h,0FFh,0FFh,0FFh,0FFh
		db	 1Ah, 00h, 80h, 22h,0D9h, 00h
		db	0FFh, 2Dh,0D9h,0FFh,0FFh,0FFh
		db	0FFh, 1Ah, 00h, 40h, 8Bh,0D9h
		db	 00h, 00h,0FFh,0FFh, 1Ah, 00h
		db	 20h, 0Bh,0DAh, 00h, 00h,0FFh
		db	0FFh, 1Ah, 00h, 10h,0C2h,0DAh
		db	 00h,0FFh,0CDh,0DAh,0FFh,0FFh
		db	0FFh,0FFh, 1Ah, 00h, 08h, 1Bh
		db	0DBh, 00h, 00h,0FFh,0FFh, 1Ah
		db	 00h, 04h, 82h,0DBh, 00h,0FFh
		db	 8Dh,0DBh,0FFh,0FFh,0FFh,0FFh
		db	 1Ah, 00h, 02h,0CBh,0DBh, 00h
		db	 00h,0FFh,0FFh, 1Ah, 00h, 01h
		db	0F2h,0DBh, 00h,0FFh,0FDh,0DBh
		db	0FFh,0FFh,0FFh,0FFh, 1Bh, 00h
		db	 80h, 58h,0D8h, 82h, 09h,0FFh
		db	0FFh, 1Bh, 00h, 40h, 7Ch,0D8h
		db	 80h, 0Ah,0FFh,0FFh,0FFh,0FFh
		db	 16h,0AFh, 02h, 11h

; ------------------------------------------------------------------
; cavern_name -- pascal-encoded cavern/area name 'Cavern of Glacial'.
; Preceded by small descriptor bytes; the length byte just before
; the quoted string matches the string length (0x11/0x0E/etc).
; ------------------------------------------------------------------
		db	'Cavern of Glacial'
		db	 0Fh, 00h, 03h, 06h, 06h, 07h
		db	 00h, 1Eh,0FFh, 76h, 00h, 00h
		db	 20h, 00h, 00h, 00h, 1Ah, 00h
		db	 80h, 00h, 00h, 09h, 00h, 33h
		db	0FFh
		db	7 dup (0)
		db	 09h, 00h, 33h, 00h, 00h, 18h
		db	 00h, 29h,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 18h, 00h
		db	 29h, 00h, 00h, 18h, 00h, 2Eh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 18h, 00h, 2Eh, 02h
		db	 00h, 3Dh, 00h, 38h,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 3Dh, 00h, 38h, 04h, 00h, 44h
		db	 00h, 1Eh,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 44h, 00h
		db	 1Eh, 00h, 00h, 46h, 00h, 10h
		db	0FFh,0D0h, 00h, 00h, 20h, 00h
		db	 18h, 00h, 1Ah, 00h, 40h, 00h
		db	 00h, 4Ch, 00h, 2Dh,0FFh, 04h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 4Ch, 00h, 2Dh, 04h, 00h, 66h
		db	 00h, 34h,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 66h, 00h
		db	 34h, 01h, 00h, 6Fh, 00h, 05h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 6Fh, 00h, 05h, 03h
		db	 00h, 72h, 00h, 34h,0FFh
		db	7 dup (0)
		db	 72h, 00h, 34h, 00h, 00h, 7Ah
		db	 00h, 09h,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 7Ah, 00h
		db	 09h, 01h, 00h, 7Bh, 00h, 3Bh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 7Bh, 00h, 3Bh, 03h
		db	 00h, 80h, 00h, 1Ch,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 80h, 00h, 1Ch, 03h, 00h, 84h
		db	 00h, 16h,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 18h, 00h, 1Ah, 00h
		db	 20h, 00h, 00h, 88h, 00h, 16h
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 88h, 00h, 16h, 00h
		db	 00h, 89h, 00h, 22h,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 89h, 00h, 22h, 01h, 00h, 93h
		db	 00h, 27h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 93h, 00h
		db	 27h, 02h, 00h, 96h, 00h, 1Ch
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 96h, 00h, 1Ch, 03h
		db	 00h, 98h, 00h, 16h,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 98h, 00h, 16h, 01h, 00h, 99h
		db	 00h, 31h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 99h, 00h
		db	 31h, 02h, 00h, 9Ah, 00h, 0Bh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 9Ah, 00h, 0Bh, 02h
		db	 00h, 9Ch, 00h, 3Fh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 9Ch, 00h, 3Fh, 03h, 00h, 9Fh
		db	 00h, 05h,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 9Fh, 00h
		db	 05h, 01h, 00h,0A5h, 00h, 1Ch
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0A5h, 00h, 1Ch, 03h
		db	 00h,0A8h, 00h, 2Ch,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0A8h, 00h, 2Ch, 01h, 00h,0B1h
		db	 00h, 0Dh,0FFh, 7Ah, 00h, 00h
		db	 20h, 00h, 00h, 00h, 1Ah, 00h
		db	 10h, 00h, 00h,0B4h, 00h, 3Eh
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0B4h, 00h, 3Eh, 03h
		db	 00h,0B6h, 00h, 1Ch,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0B6h, 00h, 1Ch, 03h, 00h,0BEh
		db	 00h, 24h,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0BEh, 00h
		db	 24h, 00h, 00h,0C9h, 00h, 37h
		db	0FFh, 01h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0C9h, 00h, 37h, 01h
		db	 00h,0CEh, 00h, 37h,0FFh,0D0h
		db	 00h, 00h, 20h, 00h, 19h, 00h
		db	 1Ah, 00h, 08h, 00h, 00h,0D1h
		db	 00h, 19h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0D1h, 00h
		db	 19h, 03h, 00h,0D2h, 00h, 2Bh
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0D2h, 00h, 2Bh, 02h
		db	 00h,0D5h, 00h, 14h,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0D5h, 00h, 14h, 01h, 00h,0DAh
		db	 00h, 37h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0DAh, 00h
		db	 37h, 03h, 00h,0DCh, 00h, 30h
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0DCh, 00h, 30h, 00h
		db	 00h,0DEh, 00h, 26h,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0DEh, 00h, 26h, 01h, 00h,0E6h
		db	 00h, 1Dh,0FFh, 73h, 00h, 00h
		db	 20h, 00h, 19h, 00h, 1Ah, 00h
		db	 04h, 00h, 00h,0E6h, 00h, 39h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0E6h, 00h, 39h, 02h
		db	 00h,0E7h, 00h, 26h,0FFh,0D0h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh,0FFh, 00h, 00h,0E7h
		db	 00h, 30h,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0E7h, 00h
		db	 30h, 01h, 00h,0ECh, 00h, 2Eh
		db	0FFh,0D0h, 00h, 00h, 20h, 00h
		db	 18h, 00h, 1Ah, 00h, 02h, 00h
		db	 00h,0EFh, 00h, 07h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0EFh, 00h, 07h, 02h, 00h,0EFh
		db	 00h, 1Dh,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0EFh, 00h
		db	 1Dh, 00h, 00h,0F0h, 00h, 2Ch
		db	0FFh, 73h, 00h, 02h, 20h, 00h
		db	 00h, 00h, 1Ah, 00h, 01h, 00h
		db	 00h,0F0h, 00h, 3Ch,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0F0h, 00h, 3Ch, 02h, 00h,0F2h
		db	 00h, 26h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0F2h, 00h
		db	 26h, 03h, 00h,0F5h, 00h, 24h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0F5h, 00h, 24h, 02h
		db	 00h,0F8h, 00h, 2Ch,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0F8h, 00h, 2Ch, 01h, 00h, 01h
		db	 01h, 36h,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 01h, 01h
		db	 36h, 00h, 00h, 06h, 01h, 0Fh
		db	0FFh, 04h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 06h, 01h, 0Fh, 04h
		db	 00h, 0Bh, 01h, 07h,0FFh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 0Bh, 01h, 07h, 00h, 00h, 0Eh
		db	 01h, 1Dh,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 0Eh, 01h
		db	 1Dh, 00h, 00h, 12h, 01h, 3Ch
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 12h, 01h, 3Ch, 03h
		db	 00h, 17h, 01h, 2Bh,0FFh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 17h, 01h, 2Bh, 00h, 00h, 18h
		db	 01h, 31h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 18h, 01h
		db	 31h, 03h, 00h, 1Eh, 01h, 24h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 1Eh, 01h, 24h, 03h
		db	 00h, 24h, 01h, 31h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 24h, 01h, 31h, 02h, 00h, 26h
		db	 01h, 15h,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 26h, 01h
		db	 15h, 00h, 00h, 3Eh, 01h, 3Dh
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 3Eh, 01h, 3Dh, 00h
		db	 00h, 00h,0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h, 00h
		db	0FFh, 00h,0FFh
		db	7 dup (0)
		db	0FFh,0FFh, 00h, 00h, 00h,0FFh
		db	0FFh

_328MP40	endp

seg_a		ends


		end	start
