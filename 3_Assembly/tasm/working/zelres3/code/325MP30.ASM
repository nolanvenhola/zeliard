
PAGE  59,132

;==========================================================================
;
;  325MP30 - Map Data Table: Cavern of Madera, level 3, floor 0 (entrance)
;
;  Cavern/labyrinth map resource file loaded as MP30.MDT (zelres3).
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
;    [late]   cavern_name          - pascal-encoded 'Cavern of Madera'
;    [end]    exit/trigger records - door warp coords + script bytes
;    [eof]    terminator           - 0xFFFFFFFF (header_1 label)
;
;  Runtime segment base = 0xC000.  Pointer 0xCNNN resolves to file_off NNN.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_5e		equ	0DAC4h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_325MP30	proc	far


; ------------------------------------------------------------------
; mdt_header -- file-size word, flag byte, and table of WORD pointers
; into the runtime 0xC000 segment.  Sourcer mis-decoded the leading
; bytes as instructions; they are actually: size word + flag word
; + attributes pointer + offset of 'strategy' (tile grid start) + ...
; ------------------------------------------------------------------
start:
		xor	[bx],cx
		add	[bx+si],al
		pop	dx
		int	3			; Debug breakpoint
		int	3			; Debug breakpoint
		add	[bx],bh
		retf
			                        ;* No entry point to code
		inc	di
		retf
			                        ;* No entry point to code
		dec	cx
		retf
			                        ;* No entry point to code
		jo	$-33h			; Jump if overflow=1
		add	cl,ah
		inc	si
		int	3			; Debug breakpoint
		pop	di
		int	3			; Debug breakpoint
		add	di,di
		inc	word ptr [bx+si]
		or	dl,[bp+si-35h]
		aas				; Ascii adjust
		retf
			                        ;* No entry point to code
		adc	word ptr [bp+di-36h],0C386h
		mov	sp,es
;*		aad	98h			; undocumented inst

; ------------------------------------------------------------------
; tile_grid -- main cavern/map tile-index data.  Encoded as column
; or row strips of 1-byte tile indices.  Common runs: 0x3F06 (wall
; boundary), 0x2C06 (column separator), plus palette-range values
; (0xC4-0xCC) that select tile rows in the tile bank.  Originally
; labeled 'strategy' by Sourcer because the header pointer landed
; on this offset.
; ------------------------------------------------------------------
		db	0D5h, 98h		;  Fixup - byte match
		push	bx
		add	[di],dx
		add	di,8187h
		push	bx
;*		aad	86h			; undocumented inst
		db	0D5h, 86h		;  Fixup - byte match
		les	cx,dword ptr ds:data_5e[si]	; Load seg:offset ptr
		cbw				; Convrt byte to word
		db	 63h,0C8h, 81h, 46h, 86h, 81h
		db	0C4h,0C6h,0C4h,0DAh,0C7h, 85h
		db	0C4h,0C8h, 8Bh,0CAh, 99h, 05h
		db	 04h, 82h,0C7h, 85h, 81h, 43h
		db	0CAh,0C7h, 86h, 43h,0C9h, 8Ah
		db	0CAh, 99h, 06h, 04h,0CAh, 86h
		db	 81h, 43h,0DAh,0C7h, 86h, 53h
		db	0C8h,0A3h, 73h, 44h, 4Ah, 85h
		db	 81h, 43h, 81h, 46h, 85h, 73h
		db	 51h, 60h, 41h, 0Ch, 01h,0C2h
		db	 40h,0C2h, 40h, 86h,0C6h, 43h
		db	0C6h, 53h, 57h, 84h, 81h, 43h
		db	0C8h, 87h, 63h,0CAh,0A3h, 07h
		db	 04h,0CAh, 84h, 81h, 53h,0C7h
		db	 85h,0C3h, 63h,0A4h, 63h,0C9h
		db	 43h,0CAh, 85h, 81h, 53h,0CCh
		db	 85h, 73h,0A4h, 05h, 04h,0CAh
		db	 86h, 81h, 43h,0CAh, 86h, 43h
		db	0CAh, 43h,0A4h, 73h,0CAh, 87h
		db	 81h,0C6h,0C4h, 87h, 43h,0D5h
		db	0C6h,0CAh, 8Ch,0C8h, 97h, 73h
		db	0D5h, 87h, 82h,0CAh, 87h, 63h
		db	 8Dh,0C3h,0D4h, 96h, 05h, 04h
		db	 87h, 8Ah, 63h, 8Dh,0C4h,0C8h
		db	 96h,0C6h, 05h, 04h, 86h,0C2h
		db	0C1h,0C2h, 70h, 82h,0C4h,0C6h
		db	 43h,0C7h, 8Ch,0C4h,0C9h,0D4h
		db	 96h, 43h,0C9h, 63h, 41h, 50h
		db	 8Ah, 63h, 8Dh, 43h,0D5h,0C8h
		db	 95h,0CAh, 05h, 04h, 85h, 8Ah
		db	 63h, 46h, 8Bh, 43h,0D5h,0C5h
		db	 4Ah, 94h, 73h, 86h, 8Ah, 53h
		db	 46h, 8Ch, 43h,0C6h,0C4h,0C7h
		db	 95h, 73h,0C7h, 85h, 8Ah, 53h
		db	0C7h, 8Dh, 53h,0C7h, 96h, 53h
		db	0C5h, 4Ah,0C7h, 84h, 8Ah, 53h
		db	0C7h, 8Dh, 63h,0C7h, 95h, 63h
		db	0D4h,0C7h, 85h, 8Ah, 63h,0C7h
		db	 8Ch, 63h, 96h, 63h,0D5h,0CCh
		db	 85h, 8Ah, 63h, 46h, 8Bh, 63h
		db	0C7h, 95h, 53h,0CAh,0D5h, 86h
		db	 8Ah, 53h,0C5h, 4Ah, 8Bh,0C4h
		db	0C6h,0C4h,0CAh, 96h, 53h, 01h
		db	 15h,0C7h, 85h, 8Ah, 53h,0CBh
		db	 46h, 8Bh, 53h,0C7h, 96h, 53h
		db	 01h, 15h, 81h,0C7h, 84h, 8Ah
		db	 43h,0C6h,0C4h,0C7h, 8Ch, 43h
		db	0CAh, 46h, 95h, 43h,0CAh, 01h
		db	 15h,0C7h, 85h, 8Ah, 53h,0CAh
		db	 8Dh,0C4h,0CAh,0D5h,0CCh, 96h
		db	0C4h,0CAh, 02h, 15h,0CCh, 46h
		db	 83h, 8Ah, 43h,0CAh, 46h, 8Ch
		db	0C4h, 01h, 15h,0C7h, 96h,0C4h
		db	 03h, 15h,0CCh,0C7h, 84h, 8Ah
		db	 43h,0D5h,0C7h, 8Dh,0C4h, 01h
		db	 15h, 97h,0C4h,0C5h, 02h, 15h
		db	0C7h, 85h, 8Ah,0C4h,0CAh,0D5h
		db	0CCh, 8Dh,0C4h, 01h, 15h, 97h
		db	0C6h,0CAh, 02h, 15h, 86h, 8Ah
		db	0CAh, 01h, 15h, 8Eh,0CAh, 01h
		db	 15h, 97h,0C6h, 03h, 15h, 86h
		db	 8Ah, 02h, 15h,0D4h, 8Dh, 02h
		db	 15h, 98h, 03h, 15h, 86h, 8Ah
		db	0D6h, 02h, 15h, 8Dh,0D6h, 01h
		db	 15h, 98h,0D6h, 02h, 15h, 86h
		db	 09h, 0Dh,0D7h, 0Fh, 0Dh,0D7h
		db	 19h, 0Dh,0D7h, 08h, 0Dh, 3Fh
		db	 0Eh, 0Ch, 0Fh,0D2h,0D3h, 30h
		db	 0Fh, 3Fh, 0Fh, 17h, 0Fh,0D2h
		db	0D3h, 25h, 0Fh, 3Fh, 10h, 11h
		db	 11h,0D8h, 15h, 11h,0D8h, 14h
		db	 11h,0D8h, 02h, 15h, 8Fh,0D9h
		db	 02h, 15h, 93h,0D9h, 02h, 15h
		db	 92h,0D9h, 01h, 15h,0DAh, 8Fh
		db	 03h, 15h, 93h, 03h, 15h, 92h
		db	0D5h, 01h, 15h, 90h, 03h, 15h
		db	 93h, 03h, 15h,0CCh, 91h,0D5h
		db	 01h, 15h, 90h, 03h, 15h, 93h
		db	 03h, 15h, 46h, 90h,0D5h, 01h
		db	 15h,0C7h, 8Fh,0C3h, 02h, 15h
		db	 93h,0C3h, 02h, 15h,0C7h, 91h
		db	0C3h, 01h, 15h, 90h,0C4h,0C8h
		db	 01h, 15h,0CCh, 92h,0C4h, 01h
		db	 15h,0C5h, 51h, 70h,0C2h,0C1h
		db	0C2h, 05h, 01h, 81h,0C4h, 01h
		db	 15h,0C7h, 8Fh, 43h,0C8h,0D5h
		db	 93h,0C4h, 02h, 15h,0C7h, 91h
		db	0C4h,0C8h,0D5h, 90h, 43h,0CAh
		db	0DAh, 93h,0C4h, 01h, 15h,0DAh
		db	 86h,0C3h, 8Bh,0C4h, 43h,0C8h
		db	 8Fh, 43h,0D5h, 94h,0C4h,0C8h
		db	0D5h,0C7h, 86h,0C4h, 8Bh,0C4h
		db	0C9h, 43h,0C8h, 8Eh, 53h, 94h
		db	 43h,0D5h, 46h, 85h,0C4h, 8Bh
		db	0C4h, 53h, 8Fh, 53h,0C8h,0CAh
		db	 92h, 43h,0D5h, 87h,0C4h, 8Bh
		db	0C4h,0C4h,0D5h, 90h, 63h, 93h
		db	 43h,0D5h,0C7h
data_1		db	86h
		db	0C4h,0D4h, 8Ah,0C4h,0C4h,0C5h
		db	 4Ah, 8Eh, 63h, 93h, 43h,0C8h
		db	 87h,0C4h,0D5h, 89h,0DBh,0C5h
		db	0C5h,0CAh, 90h,0C4h,0C9h,0C4h
		db	0CAh, 93h, 53h, 87h,0C4h,0C8h
		db	 88h,0DBh,0C5h,0C4h,0DAh, 91h
		db	 53h, 94h,0C4h,0C9h,0C4h,0C8h
		db	 86h, 43h,0CCh, 86h,0DBh,0C5h
		db	 43h,0C5h,0CBh, 90h,0C9h, 53h
		db	0C8h, 92h, 63h, 86h, 43h, 86h
		db	0DBh,0C5h,0C4h,0C6h,0C4h, 92h
		db	 05h, 04h,0CAh, 90h, 63h,0C8h
		db	 85h, 43h,0D4h, 85h, 63h,0CAh
		db	0C7h, 91h, 73h,0CAh, 51h, 06h
		db	 01h, 87h, 63h,0CAh, 85h,0C9h
		db	0C4h,0D5h, 85h, 53h,0CAh,0C7h
		db	 92h, 43h, 44h, 5Ah, 90h, 53h
		db	0CAh, 86h, 43h,0C8h, 85h, 53h
		db	0D5h,0C7h, 92h, 63h, 88h,0C8h
		db	 8Ah,0C9h,0C4h,0CAh, 87h, 53h
		db	 85h,0C6h, 43h,0C8h, 81h, 61h
		db	 05h, 01h,0C2h, 40h, 41h, 40h
		db	 81h, 53h,0CAh, 88h,0C4h, 8Ah
		db	 43h,0D5h, 87h, 53h,0C8h, 84h
		db	 53h, 41h, 92h, 43h,0D5h, 89h
		db	0C4h, 8Ah, 43h, 47h, 86h, 63h
		db	 84h, 63h,0C8h, 8Ah,0C8h, 87h
		db	 43h,0C8h, 89h,0C4h, 8Ah,0C6h
		db	 53h,0C8h, 85h, 63h, 84h, 43h
		db	0C9h,0C4h, 81h,0C4h,0CAh, 88h
		db	0C4h, 87h,0C6h, 43h,0C8h, 87h
		db	0C6h,0C4h, 8Ah, 53h,0CAh, 86h
		db	 53h,0CAh, 84h, 73h,0CAh, 89h
		db	0C4h,0C8h, 86h,0C9h, 53h,0C5h
		db	0CBh, 85h, 43h,0C8h, 89h, 53h
		db	 87h,0C4h,0C6h,0CAh, 85h, 73h
		db	0C7h, 89h, 43h, 86h, 53h,0CAh
		db	 87h, 53h, 89h, 53h,0C8h, 86h
		db	 43h,0D5h, 85h, 63h,0C7h, 8Ah
		db	0C4h,0CAh, 86h, 43h,0CAh, 88h
		db	 43h,0CAh, 89h, 43h,0C9h,0C4h
		db	0C8h, 85h, 43h,0C8h, 85h, 43h
		db	0C9h, 43h,0CAh, 89h,0C4h,0D5h
		db	 86h, 43h,0DAh, 88h, 53h, 89h
		db	0C4h,0C9h, 43h,0CAh, 85h,0C6h
		db	 43h,0C8h, 84h, 73h, 8Ah,0C4h
		db	0C9h,0C8h, 85h, 53h, 88h,0C4h
		db	0C9h,0C4h,0D4h, 88h, 63h, 86h
		db	 53h,0CAh, 84h,0C6h, 53h,0CAh
		db	0C7h, 89h, 53h, 85h, 43h,0CAh
		db	 88h, 53h,0D5h, 88h, 53h,0CAh
		db	 86h, 53h, 86h, 43h,0D5h,0C7h
		db	 8Ah, 43h,0CAh, 85h, 43h, 89h
		db	 53h,0C8h, 88h, 43h,0CAh, 87h
		db	 43h,0CAh, 86h, 43h,0D5h,0C7h
		db	 8Ah,0C4h,0CAh,0D4h, 85h,0C6h
		db	0C4h, 89h, 63h,0C8h, 87h, 43h
		db	0D5h, 87h, 43h,0D5h, 86h,0C4h
		db	0CAh,0D5h, 81h, 8Ah,0C4h, 01h
		db	 15h, 85h,0C4h,0DAh, 89h, 53h
		db	0CAh, 88h, 43h,0DAh, 87h, 43h
		db	0D5h, 86h,0C4h, 01h, 15h, 81h
		db	 8Ah,0C4h,0C8h,0D5h, 85h,0E0h
		db	 8Ah, 53h,0D5h,0C7h, 87h, 43h
		db	 88h, 43h,0D5h, 86h, 43h,0D5h
data_2		dw	8A81h
		db	 43h,0C8h, 85h,0C4h, 8Ah, 53h
		db	0D5h, 46h, 86h,0CAh,0C4h, 88h
		db	 43h,0C8h, 86h, 43h,0DAh, 81h
		db	 8Ah,0C4h,0C9h,0C4h,0C8h, 84h
		db	0E0h, 8Ah, 53h,0C8h, 89h,0CAh
		db	 88h, 53h,0C8h, 85h, 43h, 82h
		db	 8Ah, 63h, 84h,0C4h, 8Ah, 73h
		db	 91h,0C4h,0C9h, 43h,0C8h, 84h
		db	 43h, 82h, 8Ah, 53h,0CAh, 84h
		db	0E0h, 8Ah, 63h,0CAh, 41h, 60h
		db	0C2h, 60h, 41h, 50h, 81h, 63h
		db	0CAh, 84h, 43h, 82h, 8Ah, 43h
		db	0CAh, 85h,0C4h, 8Ah, 43h,0C6h
		db	0D5h, 92h, 63h, 86h,0CAh, 82h
		db	 8Ah,0C9h,0C4h,0D5h,0C7h, 84h
		db	0C4h, 8Ah, 63h,0C8h, 91h, 53h
		db	0CAh, 89h,0C1h, 41h,0C1h,0C2h
		db	 50h, 82h, 43h,0C8h, 90h, 63h
		db	 49h, 90h, 53h, 61h, 05h, 01h
		db	 8Ah, 53h, 61h, 05h, 01h,0C2h
		db	0C1h,0C2h, 40h, 81h,0C4h,0C6h
		db	 43h, 92h, 63h,0CAh, 88h, 8Ah
		db	 43h, 49h, 8Fh, 73h, 91h, 53h
		db	0CAh, 89h, 8Ah, 43h,0D5h,0C7h
		db	 8Fh, 63h,0CAh, 91h, 43h, 44h
		db	 4Ah, 87h, 8Ah, 43h,0C8h, 46h
		db	 8Eh, 53h,0CAh, 92h,0C9h, 53h
		db	0C8h, 88h, 8Ah, 53h,0C8h, 8Fh
		db	 43h, 01h, 15h, 92h, 63h,0CAh
		db	 88h, 8Ah,0C4h, 44h, 5Ah, 8Dh
		db	 43h,0C8h,0D5h,0CCh, 91h, 53h
		db	0D5h, 89h, 8Ah, 43h,0C8h, 46h
		db	 8Eh, 53h,0C8h, 92h,0C4h,0C6h
		db	0C4h,0D5h, 89h, 8Ah,0C9h, 43h
		db	0C8h, 8Fh, 63h,0C8h, 91h, 53h
		db	0C8h, 89h, 8Ah, 63h,0C8h, 8Eh
		db	0C9h, 43h, 44h, 4Ah, 8Fh, 53h
		db	0CAh, 89h, 8Ah, 63h, 8Fh,0C6h
		db	 53h,0CAh, 91h, 53h,0D5h, 89h
		db	 8Ah, 53h,0CAh, 90h, 53h, 92h
		db	 43h,0CAh,0D5h,0D4h, 88h, 8Ah
		db	 53h, 91h, 43h,0CAh, 92h, 43h
		db	 02h, 15h, 88h, 8Ah, 53h, 91h
		db	 43h,0D5h, 92h, 43h, 02h, 15h
		db	 88h, 8Ah, 43h,0CAh, 91h,0C4h
		db	0CAh,0D5h, 92h, 43h, 02h, 15h
		db	0CCh, 87h, 8Ah,0C4h,0CAh,0D5h
		db	 91h,0CAh, 01h, 15h,0D4h, 91h
		db	0C4h,0CAh, 02h, 15h, 88h, 8Ah
		db	0C4h, 01h, 15h, 91h,0C6h, 02h
		db	 15h, 91h,0C4h, 03h, 15h, 88h
		db	 8Ah,0CAh, 01h, 15h, 91h, 03h
		db	 15h, 91h,0CAh, 03h, 15h, 88h
		db	 8Ah, 02h, 15h, 91h, 03h, 15h
		db	0CCh, 90h, 04h, 15h, 88h, 8Ah
		db	 02h, 15h, 91h, 03h, 15h, 91h
		db	 04h, 15h, 88h, 8Ah,0D6h, 01h
		db	 15h, 91h,0D6h, 02h, 15h, 91h
		db	0D6h, 03h, 15h, 88h, 09h, 0Dh
		db	0D7h, 10h, 0Dh, 82h,0D7h, 13h
		db	 0Dh,0D7h, 0Bh, 0Dh, 1Bh, 0Eh
		db	 82h, 21h, 0Eh, 1Fh, 0Fh,0D2h
		db	0D3h, 1Dh, 0Fh, 09h, 0Fh,0D2h
		db	0D3h, 33h, 0Fh, 26h, 0Fh,0D2h
		db	0D3h, 0Ch, 0Fh,0D2h,0D3h, 07h
		db	 0Fh, 3Fh, 10h, 09h, 11h,0D8h
		db	 15h, 11h,0D8h, 16h, 11h,0D8h
		db	 05h, 11h, 8Ah,0D9h, 01h, 15h
		db	 94h,0D9h, 02h, 15h, 94h,0D9h
		db	 02h, 15h, 83h, 8Ah, 02h, 15h
		db	 94h, 02h, 15h,0CBh, 94h, 03h
		db	 15h, 83h, 8Ah, 02h, 15h, 94h
		db	 03h, 15h,0CCh, 93h, 03h, 15h
		db	0CCh, 82h, 8Ah,0C8h, 01h, 15h
		db	 94h,0C3h, 02h, 15h, 94h,0C3h
		db	 02h, 15h, 83h, 8Ah,0C4h, 01h
		db	 15h, 94h,0C4h, 01h, 15h,0DAh
		db	 94h,0C4h, 02h, 15h, 83h, 8Ah
		db	0C4h,0C8h,0D5h, 94h,0C4h,0C8h
		db	0D5h, 95h,0C4h, 02h, 15h,0CCh
		db	 82h, 8Ah, 43h,0C8h, 93h,0C3h
		db	 43h,0C8h, 95h,0C4h,0C8h, 01h
		db	 15h, 83h, 8Ah, 53h, 93h, 73h
		db	0CAh, 61h, 06h, 01h,0C2h,0C1h
		db	0C2h, 50h, 82h, 43h, 01h, 15h
		db	 83h, 8Ah, 53h,0C8h, 92h, 43h
		db	0CAh,0D5h,0C5h,0CBh, 93h, 43h
		db	0C8h,0D5h, 83h, 8Ah, 53h,0CAh
		db	 92h, 43h, 01h, 15h,0C9h, 8Ch
		db	0C3h, 87h, 53h,0C8h, 83h, 8Ah
		db	 43h,0CAh, 93h, 43h,0D5h,0C6h
		db	0C4h, 8Ch,0C4h, 87h, 43h, 44h
		db	 4Ah, 81h, 8Ah, 43h,0D5h, 93h
		db	 43h, 01h, 15h,0C9h,0CAh, 8Bh
		db	0C4h, 87h,0C9h, 53h,0C8h, 82h
		db	 8Ah,0C4h,0C9h,0C4h,0C8h,0CCh
		db	 91h, 43h,0C8h,0D5h,0C6h, 8Ah
		db	0C3h, 81h,0C4h,0C8h, 86h, 63h
		db	0CAh, 82h, 8Ah, 53h,0CAh, 92h
		db	 53h,0D5h,0C4h, 8Ah, 63h,0C8h
		db	 85h, 43h, 01h, 15h, 83h, 8Ah
		db	 43h,0CAh, 93h, 73h, 8Ah, 43h
		db	 49h, 86h, 53h,0D5h, 83h, 8Ah
		db	0C4h, 44h, 4Ah, 91h, 73h, 8Ah
		db	 43h,0D5h, 87h, 63h, 83h, 8Ah
		db	 53h,0C8h, 92h, 43h,0CAh, 43h
		db	 8Ah, 43h,0C8h,0D4h, 86h,0C4h
		db	0C6h, 43h,0C8h, 82h, 8Ah, 53h
		db	0CAh, 92h, 43h,0D5h,0C9h,0CAh
		db	 8Ah, 53h,0C8h, 86h, 73h,0C8h
		db	 81h, 8Ah,0C4h, 49h, 93h, 43h
		db	0C8h,0C4h, 8Bh, 63h,0C8h, 85h
		db	 63h,0CAh, 82h, 8Ah,0C9h,0D5h
		db	0DAh, 93h, 53h,0CAh, 8Bh, 43h
		db	0C6h,0C4h, 86h, 53h,0DAh, 83h
		db	 8Ah,0C4h,0C8h, 94h, 53h,0D5h
		db	 8Bh, 63h,0C8h, 85h,0C6h,0C4h
		db	0D5h, 84h, 8Ah, 43h,0CAh, 93h
		db	 43h,0DAh,0D5h, 8Bh, 63h,0CAh
		db	 85h, 53h,0C8h, 83h, 8Ah, 43h
		db	 94h,0C4h,0CAh, 8Dh,0C4h,0C9h
		db	0C4h,0CAh, 86h, 53h,0C6h, 83h
		db	 8Ah, 43h, 84h,0C3h, 8Fh,0CAh
		db	0D5h, 8Dh, 43h, 01h, 15h, 86h
		db	 73h,0CAh, 81h, 8Ah, 43h, 84h
		db	0C4h,0C8h, 9Dh,0C9h, 43h,0D5h
		db	 86h,0C4h,0C6h, 43h,0CAh, 82h
		db	 8Ah,0C4h,0CAh, 84h, 43h, 41h
		db	 0Ah, 01h, 41h, 05h, 01h,0C2h
		db	0C1h,0C2h, 60h, 81h, 53h,0C8h
		db	 86h, 63h, 83h, 8Ah,0C4h, 85h
		db	 43h, 9Dh, 43h, 44h, 4Ah, 84h
		db	 63h, 83h,0C1h,0C2h, 06h, 01h
		db	 81h,0C4h, 85h,0C4h,0C3h, 8Eh
		db	0C3h,0D5h, 8Bh,0DDh,0DFh, 63h
		db	0C8h, 85h, 43h,0C6h,0C4h,0CAh
		db	 41h, 8Ah,0C4h, 85h,0C4h,0D5h
		db	 8Eh, 43h,0D5h, 89h,0DDh,0DEh
		db	0DFh, 73h,0C8h, 84h,0C6h, 53h
		db	 83h, 84h,0C3h,0C8h, 84h,0CAh
		db	 85h,0C4h,0C8h, 8Eh, 53h,0CBh
		db	 88h,0DDh,0DEh,0DFh, 43h,0C9h
		db	 53h, 6Ch,0C4h,0C5h,0C4h,0CAh
		db	0CBh, 82h, 84h, 43h, 8Ah, 43h
		db	0C8h, 8Dh, 43h,0DAh, 89h,0DDh
		db	0DEh,0DFh, 05h, 04h, 6Dh, 43h
		db	0C5h, 4Ah, 82h, 84h, 43h, 8Ah
		db	 53h, 8Dh,0C4h,0D5h, 8Ah,0DDh
		db	0DEh,0DFh, 05h, 04h, 6Eh, 53h
		db	 5Ah, 81h, 84h, 43h,0D4h, 88h
		db	0C3h, 53h, 8Dh,0C4h,0D5h,0D4h
		db	 89h,0DDh,0DEh,0DFh, 53h,0C6h
		db	 43h, 6Eh,0C4h,0C5h,0C4h, 84h
		db	 84h,0C4h, 44h,0CBh, 87h, 53h
		db	 44h, 4Ah, 8Ah, 43h,0D5h, 89h
		db	0DDh,0DEh,0DFh,0C4h,0C6h, 63h
		db	 6Fh,0C4h, 44h, 4Ah, 82h, 84h
		db	 43h,0CAh, 88h, 53h,0C3h, 8Dh
		db	0C4h, 44h, 4Ah, 87h,0DDh,0DEh
		db	0DFh, 73h, 04h, 11h,0C4h,0C6h
		db	0CAh, 84h, 84h,0C4h, 01h, 15h
		db	 88h, 63h,0C8h, 8Ch, 43h,0D5h
		db	0D4h, 88h,0DDh,0DEh,0DFh, 63h
		db	0CAh, 85h,0C4h,0CAh, 4Ah, 83h
		db	 84h,0C4h,0C8h,0D5h,0CCh, 87h
		db	0C6h, 53h,0CAh, 8Ch, 43h, 01h
		db	 15h, 89h,0DDh,0DFh, 53h,0CAh
		db	0CCh, 85h,0C4h, 86h, 84h, 43h
		db	0C8h,0D4h, 87h, 53h,0CAh, 8Dh
		db	 63h, 8Bh, 53h,0D5h, 86h,0C6h
		db	 86h, 84h, 53h,0D5h, 87h, 53h
		db	 8Eh,0C6h, 43h,0DAh, 8Bh, 53h
		db	0C8h, 8Dh, 50h, 81h,0C4h,0C9h
		db	 43h,0CAh, 86h, 53h,0C3h,0C8h
		db	 8Ch, 43h,0C5h,0CBh, 8Bh,0C6h
		db	0C4h,0C9h, 43h, 41h, 70h,0C2h
		db	 40h, 41h, 84h, 43h,0CAh,0D5h
		db	 87h,0C4h,0C9h, 43h,0CAh, 8Ch
		db	 53h, 8Ch, 53h,0CAh, 8Dh, 84h
		db	 43h, 01h, 15h, 87h, 53h,0CAh
		db	 8Dh, 43h,0CAh, 8Ch, 43h,0CAh
		db	0D5h, 86h,0C8h, 86h, 84h, 43h
		db	0C8h,0D5h, 87h, 43h,0D5h,0D4h
		db	 8Dh,0C4h,0CAh, 8Dh, 43h, 01h
		db	 15h, 86h,0C4h,0C8h, 85h, 84h
		db	 53h, 47h, 86h, 43h,0C8h,0D5h
		db	 8Dh,0C4h, 85h,0C8h, 88h, 43h
		db	0C8h,0D5h, 86h, 43h, 85h, 84h
		db	 63h,0CAh, 86h, 53h,0C8h, 8Dh
		db	0CAh, 85h,0C4h, 88h, 63h,0C8h
		db	 85h, 43h,0C8h, 84h, 84h,0C6h
		db	 43h,0CAh, 87h,0C4h,0C9h, 43h
		db	0C8h, 92h,0C4h,0C8h,0CCh, 86h
		db	 73h, 85h, 43h, 49h, 83h, 84h
		db	0C9h,0C4h,0CAh, 88h, 63h,0CAh
		db	 91h,0C8h,0C4h,0CAh, 87h, 63h
		db	 86h,0C9h,0C4h,0D5h, 84h, 84h
		db	 43h,0D5h, 88h, 63h, 92h, 43h
		db	 88h,0C9h,0C4h,0C9h,0C4h,0D4h
		db	 85h, 43h,0CAh, 84h, 84h, 43h
		db	0C8h, 88h, 43h, 44h, 4Ah, 90h
		db	 53h, 87h, 63h,0D5h, 85h,0C4h
		db	 01h, 15h,0CCh, 83h, 84h,0C4h
		db	0C9h, 44h, 4Ah, 85h, 53h,0D5h
		db	 92h,0C4h, 44h,0CBh, 86h,0C4h
		db	0C6h,0C4h,0CAh,0D5h, 85h,0C4h
		db	0C8h,0D5h, 84h, 84h, 53h,0CAh
		db	 87h, 43h, 01h, 15h, 91h,0C8h
		db	0C4h,0C9h, 88h, 53h, 01h, 15h
		db	 85h, 43h,0C8h, 84h, 84h, 53h
		db	 88h, 43h, 01h, 15h, 91h, 53h
		db	0C8h, 87h, 43h,0CAh, 01h, 15h
		db	 85h,0C4h,0C9h,0C4h, 84h, 84h
		db	 43h,0CAh, 88h,0C4h,0CAh, 01h
		db	 15h, 91h,0C4h,0C9h,0C4h,0CAh
		db	 87h, 43h, 02h, 15h, 85h, 43h
		db	0CAh, 84h, 84h, 43h,0D5h, 88h
		db	0C4h, 02h, 15h, 91h,0CAh, 43h
		db	0D5h, 87h, 43h, 02h, 15h, 85h
		db	 43h,0D5h, 84h, 84h, 43h,0D5h
		db	 88h,0C9h, 02h, 15h,0CCh, 91h
		db	0CAh, 43h,0D4h, 86h, 49h, 02h
		db	 15h, 85h, 43h,0CAh, 84h, 84h
		db	0C4h,0CAh,0D5h,0D4h, 87h,0CAh
		db	 02h, 15h, 93h,0C4h, 01h, 15h
		db	 86h,0C6h, 03h, 15h, 85h,0C4h
		db	0CAh,0D5h, 84h, 84h,0C4h, 02h
		db	 15h, 87h, 03h, 15h, 93h,0CAh
		db	 01h, 15h, 87h, 03h, 15h, 85h
		db	0C4h, 01h, 15h,0CCh, 83h, 84h
		db	0CAh, 02h, 15h, 87h, 03h, 15h
		db	 93h, 02h, 15h,0CCh, 86h, 03h
		db	 15h, 85h,0C6h, 01h, 15h, 84h
		db	 84h, 03h, 15h, 87h, 03h, 15h
		db	 93h, 02h, 15h, 87h, 03h, 15h
		db	 85h, 02h, 15h, 84h, 84h,0D6h
		db	 02h, 15h, 87h,0D6h, 02h, 15h
		db	 93h,0D6h, 01h, 15h, 87h,0D6h
		db	 02h, 15h, 85h,0D6h, 01h, 15h
		db	 84h, 6Ch,0D7h, 09h, 0Dh,0D7h
		db	 0Eh, 0Dh, 82h, 7Ch,0D7h, 08h
		db	 0Dh,0D7h, 7Ch, 82h,0CDh,0D7h
		db	 05h, 0Dh, 0Fh, 0Eh,0D1h,0D3h
		db	 0Ch, 0Eh, 82h, 14h, 0Eh, 82h
		db	 07h, 0Eh, 3Fh, 0Fh, 19h, 0Fh
		db	0D2h,0D3h, 23h, 0Fh, 3Fh, 0Fh
		db	 3Dh, 0Fh,0D2h,0D3h, 0Eh, 0Fh
		db	0D2h,0D3h, 2Eh, 0Fh, 3Fh, 0Fh
		db	 3Fh, 10h, 01h, 11h,0D8h, 12h
		db	 11h,0D8h, 1Dh, 11h,0D8h, 09h
		db	 11h, 82h,0D9h, 02h, 15h, 90h
		db	0D9h, 03h, 15h, 9Ah,0D9h, 01h
		db	 15h, 88h, 82h,0C8h, 02h, 15h
		db	 90h,0C3h, 03h, 15h, 9Ah, 02h
		db	 15h,0CCh, 87h, 82h,0C4h, 02h
		db	 15h, 90h,0C4h, 02h, 15h,0DAh
		db	 9Ah, 02h, 15h, 88h, 82h,0C4h
		db	0C8h, 01h, 15h, 90h,0C4h,0D5h
		db	0C3h,0D5h, 9Bh, 02h, 15h, 88h
		db	 81h,0C9h, 43h,0C8h,0D5h, 90h
		db	 53h,0D5h, 9Ah,0C9h, 02h, 15h
		db	 88h, 81h, 63h,0DAh, 90h, 43h
		db	 44h, 4Ah, 98h,0C4h, 02h, 15h
		db	 88h, 81h, 63h,0C8h, 90h, 53h
		db	0D5h, 99h,0C9h,0C4h,0C8h,0D5h
		db	0DAh, 88h, 81h, 73h, 90h, 43h
		db	 01h, 15h, 46h, 97h, 53h,0D5h
		db	0CCh, 88h, 81h, 43h,0C6h, 43h
		db	0C8h, 8Ah,0E2h, 84h, 53h,0D5h
		db	0C7h, 97h,0C9h, 53h,0D5h, 89h
		db	 81h, 43h,0C3h, 53h,0C8h, 89h
		db	0E3h, 84h, 63h, 98h,0C4h,0C9h
		db	 43h,0DAh,0C7h, 88h, 81h, 63h
		db	 44h, 5Ah, 87h,0E4h, 84h,0C4h
		db	0C9h, 53h, 97h, 63h, 81h,0C7h
		db	 88h, 81h,0C9h, 63h,0CAh, 8Ah
		db	0E5h, 84h, 73h, 46h, 95h, 63h
		db	 81h, 46h, 87h, 81h, 53h,0CAh
		db	 8Ch,0E6h, 84h, 73h,0C7h, 96h
		db	 63h,0C7h, 89h, 81h, 53h,0D5h
		db	 91h, 73h, 97h, 53h,0CAh, 81h
		db	0C7h, 88h, 81h, 43h,0CAh,0D5h
		db	 91h, 63h, 98h, 53h,0D5h, 8Ah
		db	 81h, 43h, 01h, 15h,0C7h, 90h
		db	0C4h,0C6h,0C4h,0D5h, 46h, 96h
		db	 53h,0D5h,0CCh, 89h, 81h, 43h
		db	 01h, 15h, 91h, 53h,0D5h,0C7h
		db	 97h, 53h,0D5h, 8Ah, 81h, 43h
		db	 01h, 15h, 46h, 8Fh, 53h,0D5h
		db	 98h, 53h,0D5h, 8Ah, 81h, 43h
		db	 01h, 15h,0C7h, 90h,0C6h, 43h
		db	0D5h, 98h, 43h,0CAh,0D5h, 8Ah
		db	 81h, 43h,0C8h,0D5h, 92h, 53h
		db	0C7h, 97h, 43h,0D5h,0DAh, 8Ah
		db	 81h, 53h,0C8h, 46h, 90h, 53h
		db	 98h, 43h,0C6h, 8Bh, 81h,0C6h
		db	 53h,0C7h, 91h, 63h, 97h, 53h
		db	 8Bh, 81h, 63h, 92h,0CAh, 53h
		db	 97h,0C4h,0C6h,0C4h, 8Bh, 81h
		db	 63h,0C8h, 92h, 43h,0CAh, 97h
		db	 53h,0D4h, 8Ah, 81h, 73h, 92h
		db	0C4h,0C9h, 98h,0CAh, 43h,0D5h
		db	0D4h, 89h, 81h, 43h,0C6h, 43h
		db	0C8h, 91h, 43h, 98h,0C3h, 53h
		db	0D5h,0C8h, 88h, 81h, 73h,0CAh
		db	 41h, 0Ch, 01h, 82h, 43h, 98h
		db	 73h,0CAh, 88h, 81h, 63h,0CAh
		db	 92h,0C4h,0CAh, 98h, 63h,0CAh
		db	0CCh, 88h, 07h, 00h, 32h, 92h
		db	 00h, 2Eh,0FFh,0FFh,0FFh,0FFh
		db	 9Ah, 40h,0A2h, 94h, 00h,0A3h
		db	 00h,0FFh,0FFh, 54h,0CBh, 03h
		db	 02h
		db	'$'
		db	'It is the/'
		db	16h
		db	'biggest tree.'
		db	0FFh, 13h, 00h, 31h, 81h, 06h
		db	 13h, 00h, 31h, 00h,0FFh,0FFh
		db	0FFh, 15h, 00h, 06h, 80h, 02h
		db	0CDh, 00h, 2Fh, 00h,0FFh,0FFh
		db	0FFh, 16h, 00h, 17h, 83h, 06h
		db	 16h, 00h, 17h, 00h,0FFh,0FFh
		db	0FFh, 2Fh, 00h, 0Eh, 81h, 06h
		db	 2Fh, 00h, 0Eh, 00h,0FFh,0FFh
		db	0FFh, 34h, 00h, 25h, 82h, 06h
		db	 34h, 00h, 25h, 00h,0FFh,0FFh
		db	0FFh, 56h, 00h, 2Fh, 84h, 06h
		db	 56h, 00h, 2Fh, 00h,0FFh,0FFh
		db	0FFh, 58h, 00h, 06h, 83h, 06h
		db	 58h, 00h, 06h, 00h,0FFh,0FFh
		db	0FFh, 72h, 00h, 06h, 83h, 06h
		db	 72h, 00h, 06h, 00h,0FFh,0FFh
		db	0FFh, 76h, 00h, 1Ch, 84h, 06h
		db	 76h, 00h, 1Ch, 00h,0FFh,0FFh
		db	0FFh, 99h, 00h, 2Bh, 82h, 06h
		db	 99h, 00h, 2Bh, 00h,0FFh,0FFh
		db	0FFh,0B9h, 00h, 12h,0C0h, 03h
		db	 8Eh, 00h,0FFh, 00h,0FFh,0FFh
		db	0FFh,0BAh, 00h, 2Eh, 82h, 06h
		db	0BAh, 00h, 2Eh, 00h,0FFh,0FFh
		db	0FFh,0FFh,0FFh, 12h, 00h, 80h
		db	 98h,0CDh, 00h, 00h,0FFh,0FFh
		db	 12h, 00h, 40h, 0Fh,0CEh, 00h
		db	0FFh, 1Ah,0CEh,0FFh,0FFh,0FFh
		db	0FFh, 12h, 00h, 20h, 2Fh,0CEh
		db	 00h,0FFh, 3Ah,0CEh,0FFh,0FFh
		db	0FFh,0FFh, 12h, 00h, 10h,0D8h
		db	0CEh, 00h, 00h,0FFh,0FFh, 12h
		db	 00h, 08h,0E8h,0CEh, 00h, 00h
		db	0FFh,0FFh, 12h, 00h, 04h,0EFh
		db	0CEh, 00h,0FFh,0FAh,0CEh,0FFh
		db	0FFh,0FFh,0FFh,0FFh,0FFh, 17h
		db	0AFh, 00h, 10h

; ------------------------------------------------------------------
; cavern_name -- pascal-encoded cavern/area name 'Cavern of Madera'.
; Preceded by small descriptor bytes; the length byte just before
; the quoted string matches the string length (0x11/0x0E/etc).
; ------------------------------------------------------------------
		db	'Cavern of Madera', 0Dh
		db	 00h, 02h, 04h, 04h, 0Ah, 00h
		db	 31h,0FFh, 01h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 0Ah, 00h, 31h
		db	 01h, 00h, 0Dh, 00h, 19h,0FFh
		db	 02h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 0Dh, 00h, 19h, 02h, 00h
		db	 1Dh, 00h, 34h,0FFh, 03h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 1Dh
		db	 00h, 34h, 03h, 00h, 26h, 00h
		db	 27h,0FFh, 03h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 26h, 00h, 27h
		db	 03h, 00h, 26h, 00h, 2Dh,0FFh
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 26h, 00h, 2Dh, 00h, 00h
		db	 26h, 00h, 3Dh,0FFh, 03h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 26h
		db	 00h, 3Dh, 03h, 00h, 28h, 00h
		db	 02h,0FFh
		db	7 dup (0)
		db	 28h, 00h, 02h, 00h, 00h, 38h
		db	 00h, 39h,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 38h, 00h
		db	 39h, 01h, 00h, 3Eh, 00h, 10h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 3Eh, 00h, 10h, 02h
		db	 00h, 3Fh, 00h, 27h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 3Fh, 00h, 27h, 02h, 00h, 40h
		db	 00h, 1Bh,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 40h, 00h
		db	 1Bh, 01h, 00h, 43h, 00h, 3Ah
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 43h, 00h, 3Ah, 02h
		db	 00h, 45h, 00h, 08h,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 45h, 00h, 08h, 02h, 00h, 47h
		db	 00h, 31h,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 47h, 00h
		db	 31h, 03h, 00h, 4Ch, 00h, 10h
		db	0FFh, 01h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 4Ch, 00h, 10h, 01h
		db	 00h, 60h, 00h, 0Dh,0FFh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 60h, 00h, 0Dh, 00h, 00h, 61h
		db	 00h, 1Ch,0FFh, 03h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 61h, 00h
		db	 1Ch, 03h, 00h, 61h, 00h, 31h
		db	0FFh, 03h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 61h, 00h, 31h, 03h
		db	 00h, 61h, 00h, 38h,0FFh
		db	7 dup (0)
		db	 61h, 00h, 38h, 00h, 00h, 63h
		db	 00h, 1Ch,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 18h, 00h, 12h, 00h
		db	 80h, 00h, 00h, 6Ah, 00h, 0Dh
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 6Ah, 00h, 0Dh, 00h
		db	 00h, 6Ah, 00h, 1Fh,0FFh, 03h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 6Ah, 00h, 1Fh, 03h, 00h, 6Ah
		db	 00h, 25h,0FFh, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 6Ah, 00h
		db	 25h, 00h, 00h, 6Ah, 00h, 3Dh
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 6Ah, 00h, 3Dh, 00h
		db	 00h, 76h, 00h, 37h,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 76h, 00h, 37h, 01h, 00h, 79h
		db	 00h, 2Dh,0FFh, 01h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 79h, 00h
		db	 2Dh, 01h, 00h, 7Eh, 00h, 08h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 7Eh, 00h, 08h, 02h
		db	 00h, 85h, 00h, 37h,0FFh, 76h
		db	 00h, 00h, 20h, 00h, 00h, 00h
		db	 12h, 00h, 40h, 00h, 00h, 8Bh
		db	 00h, 1Eh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 8Bh, 00h
		db	 1Eh, 02h, 00h, 8Dh, 00h, 37h
		db	0FFh, 73h, 00h, 00h, 20h, 00h
		db	 18h, 00h, 12h, 00h, 20h, 00h
		db	 00h, 8Eh, 00h, 0Dh,0FFh, 02h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 8Eh, 00h, 0Dh, 02h, 00h, 96h
		db	 00h, 02h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 96h, 00h
		db	 02h, 02h, 00h, 9Dh, 00h, 02h
		db	0FFh, 01h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 9Dh, 00h, 02h, 01h
		db	 00h, 9Dh, 00h, 07h,0FFh, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 9Dh, 00h, 07h, 00h, 00h, 9Eh
		db	 00h, 37h,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 9Eh, 00h
		db	 37h, 02h, 00h,0A2h, 00h, 34h
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0A2h, 00h, 34h, 00h
		db	 00h,0A3h, 00h, 0Dh,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0A3h, 00h, 0Dh, 01h, 00h,0A4h
		db	 00h, 2Eh,0FFh, 7Ch, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	0FFh, 0Fh, 00h,0A4h, 00h, 3Ch
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0A4h, 00h, 3Ch, 00h
		db	 00h,0A6h, 00h, 1Fh,0FFh,0D0h
		db	 00h, 00h, 20h, 00h, 18h, 00h
		db	 12h, 00h, 10h, 00h, 00h,0A6h
		db	 00h, 36h,0FFh,0D0h, 00h, 00h
		db	 20h, 00h, 1Dh, 00h, 12h, 00h
		db	 08h, 0Fh, 00h,0B0h, 00h, 33h
		db	0FFh, 73h, 00h, 01h, 20h, 00h
		db	 00h, 00h, 12h, 00h, 04h, 00h
		db	 00h,0BCh, 00h, 3Fh,0FFh, 01h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0BCh, 00h, 3Fh, 01h, 00h,0C6h
		db	 00h, 3Fh,0FFh, 02h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0C6h, 00h
		db	 3Fh, 02h, 00h,0C9h, 00h, 30h
		db	0FFh, 02h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0C9h, 00h, 30h, 02h
		db	 00h,0FFh,0FFh

_325MP30	endp

seg_a		ends


		end	start
