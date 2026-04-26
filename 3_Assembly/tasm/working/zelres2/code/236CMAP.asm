
PAGE  59,132

;==========================================================================
;
;  236CMAP.BIN - Felishika Castle Town Map Data (zelres2 chunk 0x25)
;
;  Castle map data file loaded by stick.bin as "CMAP.MDT" (chunk_ref entry
;  1,0x25 in stick.asm at line ~1972). This is the very first town/castle
;  the player visits -- King Felishika's palace on the outskirts of Muralla.
;
;  Unlike the later MRMP/STMP/BSMP/etc. MDT files which follow the stock
;  8-tile-tall town map format, CMAP has a single-location-specific layout:
;
;    +0x00  hdr_ptr_tbl    - WORD pointers / small descriptors (16 bytes)
;    +0x20  <padding zeros>
;    +0x34  castle_tile_grid - tile-index column strips rendering the
;                              castle facade (ASCII-range values 0x20-0x6F
;                              map to tile cells in the VGA font/tileset)
;    +0xC3  npc_and_door_cells - per-NPC/door cell records (8 bytes each)
;                              referencing the tile grid positions
;    +0x2C3 secondary_tile_grid - same castle rendering data duplicated for
;                              a second display mode / day-night variant
;    +0x3A7 castle_hdr      - pascal name 'Felishika\s Castle' + door entries
;    +0x3CA door_coord_tbl  - warp coordinates (x,y) for each castle door
;    +0x3D2 event_record_tbl - event / exit record entries (variable length,
;                              terminated by 0xFFFF)
;    +0x3F9 npc_text_ptr_tbl - WORD-pointer array, one per dialog line
;    +0x40C dialog_strings  - packed dialog strings, 0xFF-terminated
;    +0x898 script_trailer  - script / event trigger bytes (FF-FF end)
;
;  The module has NO executable code -- Sourcer's attempt to decode the
;  header bytes as x86 instructions (mov si,8; add ss:data_17e[bp+di],ch)
;  produced bogus mnemonics that are re-emitted here as `db` data.
;
;  Runtime segment base is 0xC000 (used by CMAP.MDT reader in game code).
;  Pointers in tables like 0xC3AB resolve to (value - 0xC000) as file offset.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

zr2_36		proc	far

start:
; ------------------------------------------------------------------
; Header pointer area (16 bytes): small descriptor fields + pointers
; into the castle_hdr / event_record_tbl / dialog_strings tables.
; Runtime segment 0xC000 -- 0xC3AB resolves to file_off 0x03AB, etc.
; ------------------------------------------------------------------

hdr_ptr_tbl	label	word
		db	0BEh, 008h			; 0x08BE -- desc/end marker
		db	000h, 000h			; reserved / zero
		dw	0C3ABh				; -> castle_hdr_a (0x03AB)
		db	072h, 000h			; field (count?)
		db	0B0h, 0C2h			; 0xC2B0 -- possibly map ptr (0x02B0)
		db	001h, 0B3h			; field
		dw	0C3CAh				; -> door_coord_tbl (0x03CA)
		db	000h, 000h			; reserved
		dw	0C3F6h				; -> event_table_end (0x03F6)
		dw	0C89Ch				; -> script_trailer offset (0x089C)
		dw	0C3A7h				; -> castle_hdr_b (0x03A7)
		db	022h, 000h			; field
		dw	0C3D2h				; -> event_record_tbl (0x03D2)
		db	000h, 000h			; reserved (0x1A..0x1B)

		db	24 dup (0)			; zero padding (0x1C..0x33)

; ------------------------------------------------------------------
; castle_tile_grid -- ASCII-range tile indices that render the castle
; facade. Values 0x20-0x6F are indices into the VGA font/tile bank;
; 0x00 bytes are empty cells. Organised as short column-strips of
; varying length, null-terminated between strips.
; ------------------------------------------------------------------

castle_tile_grid:
		db	'<=====UX\ldeimVZ]aeflnWZ^bfgkoTX'
		db	'\`ddimUY]alejmVZ^bfglnW[_cghioVX'
		db	'X^\`imVY\_]aooVZ_`ddim', 0
		db	'WYbceln', 0
		db	'VZdgimo', 0
		db	'U`ceglm', 0
		db	'?B`ddhm'
		db	 00h, 00h, 46h, 49h, 60h, 49h	; +0x076
		db	 51h, 53h, 00h, 00h, 00h, 00h	; +0x07C
		db	 4Dh, 4Ah	; +0x082
		db	11 dup (0)

; ------------------------------------------------------------------
; npc_and_door_cells -- 8-byte records for NPCs and interactive cells.
; Each record encodes a grid position (x,y) + state/palette bytes.
; Exact layout depends on cell type (NPC / door / decoration).
; Runs through 0x1FA (terminator-like `3B 00 ...` and 02 separators).
; ------------------------------------------------------------------

npc_and_door_cells:
		db	 38h, 06h, 00h, 00h, 00h, 00h	; +0x000
		db	 00h, 00h, 39h, 07h, 13h, 13h	; +0x006
		db	 13h, 13h, 13h, 02h, 3Ah, 08h	; +0x00C
		db	 14h, 14h, 14h, 14h, 14h, 00h	; +0x012
		db	 3Bh, 09h, 00h, 0Eh, 32h, 34h	; +0x018
		db	 36h, 00h, 00h, 00h, 0Dh, 0Eh	; +0x01E
		db	 33h, 35h, 37h, 00h, 00h, 00h	; +0x024
		db	 0Eh, 11h, 33h, 34h, 36h, 00h	; +0x02A
		db	 00h, 02h, 0Eh, 17h, 33h, 34h	; +0x030
		db	 37h, 00h, 00h, 00h, 0Fh, 15h	; +0x036
		db	 33h, 34h, 36h, 00h, 00h, 38h	; +0x03C
		db	 00h, 0Eh, 33h, 34h, 37h, 00h	; +0x042
		db	 00h, 39h, 0Ah, 11h, 33h, 34h	; +0x048
		db	 36h, 00h, 02h, 3Ah, 0Bh, 11h	; +0x04E
		db	 32h, 34h, 37h, 00h, 00h, 39h	; +0x054
		db	 0Bh, 11h, 32h, 34h, 36h, 00h	; +0x05A
		db	 00h, 3Ah, 0Bh, 17h, 32h, 34h	; +0x060
		db	 37h, 00h, 00h, 3Ah, 0Bh, 11h	; +0x066
		db	 32h, 35h, 36h, 00h, 00h, 3Ah	; +0x06C
		db	 0Bh, 11h, 33h, 35h, 37h, 00h	; +0x072
		db	 00h, 3Ah, 0Bh, 17h, 33h, 35h	; +0x078
		db	 36h, 00h, 02h, 39h, 0Bh, 11h	; +0x07E
		db	 33h, 35h, 37h, 00h, 00h, 39h	; +0x084
		db	 0Bh, 17h, 33h, 35h, 36h, 00h	; +0x08A
		db	 00h, 3Ah, 0Bh, 11h, 33h, 34h	; +0x090
		db	 37h, 00h, 00h, 3Ah, 0Bh, 11h	; +0x096
		db	 32h, 34h, 36h, 00h, 00h, 39h	; +0x09C
		db	 0Bh, 17h, 32h, 34h, 37h, 00h	; +0x0A2
		db	 00h, 3Ah, 0Bh, 11h, 33h, 34h	; +0x0A8
		db	 36h, 00h, 02h, 39h, 0Ch, 11h	; +0x0AE
		db	 33h, 34h, 37h, 00h, 00h, 3Bh	; +0x0B4
		db	 00h, 15h, 33h, 35h, 36h, 00h	; +0x0BA
		db	 38h, 00h, 00h, 0Eh, 33h, 35h	; +0x0C0
		db	 37h, 00h, 39h, 0Ah, 10h, 17h	; +0x0C6
		db	 33h, 35h, 36h, 02h, 3Ah, 0Bh	; +0x0CC
		db	 11h, 18h, 18h, 18h, 19h, 00h	; +0x0D2
		db	 3Ah, 0Bh, 11h, 18h, 18h, 18h	; +0x0D8
		db	 19h, 00h, 3Ah, 0Bh, 11h, 18h	; +0x0DE
		db	 18h, 18h, 19h, 00h, 39h, 0Bh	; +0x0E4
		db	 11h, 1Bh, 20h, 26h, 2Ch, 00h	; +0x0EA
		db	 39h, 0Bh, 11h, 1Ch, 21h, 27h	; +0x0F0
		db	 2Dh, 00h, 3Ah, 0Bh, 11h, 1Dh	; +0x0F6
		db	 22h, 28h, 2Eh	; +0x0FC

; ------------------------------------------------------------------
; Alternate section marker -- the lone `2` byte at offset 0x5F behaves
; as an inline section delimiter between castle_tile_grid passes.
; Was auto-named data_4 by Sourcer; renamed but value unchanged.
; ------------------------------------------------------------------
cell_boundary	db	2
		db	 3Ah, 0Bh, 11h, 1Dh, 23h, 29h	; +0x100
		db	 2Fh, 00h, 3Ah, 0Bh, 11h, 1Eh	; +0x106
		db	 24h, 2Ah, 30h, 00h, 39h, 0Bh	; +0x10C
		db	 11h, 1Fh, 25h, 2Bh, 31h, 00h	; +0x112
		db	 3Ah, 0Bh, 11h, 18h, 18h, 18h	; +0x118
		db	 1Ah, 00h, 3Ah, 0Bh, 11h, 18h	; +0x11E
		db	 18h, 18h, 1Ah, 00h, 39h, 0Bh	; +0x124
		db	 11h, 18h, 18h, 18h, 1Ah, 02h	; +0x12A
		db	 39h, 0Ch, 12h, 16h, 01h, 01h	; +0x130
		db	 01h, 00h, 3Bh, 00h, 00h, 0Eh	; +0x136
		db	 32h, 33h, 36h, 00h, 00h, 38h	; +0x13C
		db	 00h, 0Eh, 33h, 35h, 37h, 00h	; +0x142
		db	 00h, 3Ah, 0Ah, 11h, 33h, 35h	; +0x148
		db	 36h, 00h, 02h, 3Ah, 0Bh, 17h	; +0x14E
		db	 33h, 35h, 37h, 00h, 00h, 39h	; +0x154
		db	 0Bh, 11h, 33h, 35h, 36h, 00h	; +0x15A
		db	 00h, 3Ah, 0Bh, 17h, 33h, 35h	; +0x160
		db	 37h, 00h, 00h, 39h, 0Bh, 11h	; +0x166
		db	 33h, 35h, 36h, 00h, 00h, 39h	; +0x16C
		db	 0Bh, 17h, 33h, 35h, 37h, 00h	; +0x172
		db	 00h, 39h, 0Bh, 11h, 33h, 35h	; +0x178
		db	 36h, 00h, 02h, 3Ah, 0Bh, 17h	; +0x17E
		db	 33h, 35h, 37h, 00h, 00h, 3Ah	; +0x184
		db	 0Bh, 11h, 33h, 35h, 36h, 00h	; +0x18A
		db	 00h, 39h, 0Bh, 11h, 33h, 35h	; +0x190
		db	 37h, 00h, 00h, 3Ah, 0Bh, 11h	; +0x196
		db	 33h, 35h, 36h, 00h, 00h, 39h	; +0x19C
		db	 0Bh, 11h, 33h, 35h, 37h, 00h	; +0x1A2
		db	 00h, 3Ah, 0Bh, 11h, 33h, 35h	; +0x1A8
		db	 36h, 00h, 02h, 3Ah, 0Ch, 11h	; +0x1AE
		db	 33h, 35h, 37h, 00h, 00h, 3Bh	; +0x1B4
		db	 00h, 0Eh, 33h, 35h, 36h, 00h	; +0x1BA
		db	 00h, 00h, 0Dh, 15h, 33h, 35h	; +0x1C0
		db	 37h, 00h, 00h, 00h, 0Eh, 11h	; +0x1C6
		db	 33h, 35h, 36h, 00h, 00h, 02h	; +0x1CC
		db	 15h, 11h, 32h, 34h, 37h, 00h	; +0x1D2
		db	 00h, 00h, 0Fh, 15h, 32h, 34h	; +0x1D8
		db	 36h, 00h, 38h, 06h, 00h, 0Eh	; +0x1DE
		db	 32h, 34h, 37h, 00h, 39h, 07h	; +0x1E4
		db	 13h, 13h, 13h, 13h, 13h, 02h	; +0x1EA
		db	 3Ah, 08h, 14h, 14h, 14h, 14h	; +0x1F0
		db	 14h, 00h, 3Bh, 09h, 00h, 00h	; +0x1F6
		db	 00h, 00h, 00h, 00h	; +0x1FC

; ------------------------------------------------------------------
; secondary_tile_grid -- second pass of castle tile strips.
; Same castle-facade tile-index columns, likely a day/night or
; before/after-event variant of castle_tile_grid above.
; ------------------------------------------------------------------

secondary_tile_grid:
		db	 40h, 43h	; +0x000
		db	'GKNO', 0
		db	'>ADHLLPRTX\``eimUY]aaflmVZ^bbgkm'
		db	'W[_ccfimTX^`dfi'
		db	 95h, 55h, 59h, 5Dh, 81h, 85h	; +0x036
		db	 86h, 87h, 99h, 56h, 5Ah, 71h	; +0x03C
		db	 82h, 64h, 68h, 6Ch, 96h, 54h	; +0x042
		db	 71h, 79h, 81h, 01h, 88h, 8Fh	; +0x048
		db	 97h, 55h, 72h, 7Ah, 82h, 01h	; +0x04E
		db	 89h, 90h, 98h, 56h, 73h, 7Bh	; +0x054
		db	 81h, 01h, 8Ah, 91h, 99h, 57h	; +0x05A
		db	 74h, 7Ch, 82h, 01h, 8Bh, 92h	; +0x060
		db	 99h, 54h, 75h, 7Dh, 83h, 85h	; +0x066
		db	 86h, 87h, 9Ah, 55h, 76h, 7Eh	; +0x06C
		db	 84h, 01h, 8Ch, 93h, 9Bh, 56h	; +0x072
		db	 77h, 7Fh, 83h, 01h, 8Dh, 8Dh	; +0x078
		db	 9Bh, 54h, 78h, 80h, 84h, 01h	; +0x07E
		db	 8Eh, 94h, 9Bh, 55h, 59h, 78h	; +0x084
		db	 83h, 64h, 64h, 69h, 9Bh, 56h	; +0x08A
		db	 5Ah, 5Ch, 84h, 85h, 86h, 87h	; +0x090
		db	 9Bh, 57h, 5Bh, 5Dh, 60h, 63h	; +0x096
		db	 68h, 6Ch, 9Ch	; +0x09C
		db	'T\\`diimUY]adgimVZ^behkmW[_cfcln'
		db	'TX\`'
		db	 60h, 63h, 69h, 6Dh	; +0x0C3
		db	32 dup (0)

; ------------------------------------------------------------------
; castle_hdr -- castle descriptor: small count/flag bytes followed
; by the pascal-encoded town name 'Felishika\s Castle'.
; Word at +04 in hdr_ptr_tbl (0xC3AB) points into this record at 0x3AB.
; ------------------------------------------------------------------

castle_hdr_b:					; hdr_ptr_tbl +0x14 -> here (0x3A7)
		db	 33h, 00h, 6Dh, 00h, 00h, 00h	; +0x000
		db	0FFh, 00h, 00h, 16h,0AFh, 00h	; +0x006

castle_hdr_a:					; hdr_ptr_tbl +0x04 -> here (0x3AB), +3 -> name
		db	 12h				; pascal string length = 18
		db	'Felishika\s Castle'
		db	 00h, 01h, 00h, 01h, 5Fh, 00h	; +0x013
		db	 01h, 34h, 00h, 00h	; +0x019

; ------------------------------------------------------------------
; door_coord_tbl -- castle door warp coordinates (3-byte entries),
; terminated by 0xFFFF. hdr_ptr_tbl +0x08 (word 0xC3CA) points here.
; ------------------------------------------------------------------

door_coord_tbl:
		db	0FFh,0FFh	; +0x000
		db	 49h, 00h,0FFh	; +0x002

; ------------------------------------------------------------------
; event_record_tbl -- event/exit table with target addresses, variable
; length records separated by FF / terminated by FF FF sequences.
; Each 0xCNNN value is a runtime pointer to either castle_hdr or a
; string in dialog_strings (subtract 0xC000 for file offset).
; hdr_ptr_tbl +0x18 (word 0xC3D2) points here (0x3D2).
; ------------------------------------------------------------------

event_record_tbl:
		db	 0Fh,0C0h, 94h, 10h,0C0h,0C8h	; +0x000
		db	 8Eh,0C3h, 3Dh,0A3h,0C8h, 06h	; +0x006
		db	0ABh,0C8h, 07h,0B3h,0C8h, 08h	; +0x00C
		db	0BBh,0C8h, 09h	; +0x012
		db	0FFh,0FFh			; terminator

		db	 04h, 00h,0FFh			; extra record
		db	 9Bh,0C8h, 05h	; +0x01A
		db	0FFh,0FFh,0FFh,0FFh		; double terminator

; ------------------------------------------------------------------
; npc_text_ptr_tbl -- array of WORD pointers (one per NPC dialog line).
; Each word is a runtime address 0xCNNN that points into the
; dialog_strings block below (file_off = value - 0xC000).
; hdr_ptr_tbl +0x10 (word 0xC3F6) marks end/entry of this table.
; ------------------------------------------------------------------

npc_text_ptr_tbl:
		dw	0C40Ah			; -> dialog_str_if_brave   (0x040A)
		dw	0C4ACh			; -> dialog_str_according  (0x04AC)
		dw	0C553h			; -> dialog_str_i_have     (0x0553)
		dw	0C5C3h			; -> dialog_str_chamber    (0x05C3)
		dw	0C62Ch			; -> dialog_str_brave_kn   (0x062C)
		dw	0C6C4h			; -> dialog_str_quickly_g  (0x06C4)
		dw	0C6E1h			; -> dialog_str_ah_nine    (0x06E1)
		dw	0C752h			; -> dialog_str_this_will  (0x0752)
		dw	0C7ABh			; -> dialog_str_peace_we   (0x07AB)
		dw	0C81Fh			; -> dialog_str_quickly_e  (0x081F)

; ------------------------------------------------------------------
; dialog_strings -- castle NPC dialog, each string terminated by 0xFF.
; ------------------------------------------------------------------

dialog_str_if_brave:
		db	'If you are the brave warrior we '
		db	'have awaited, we have something '
		db	'to tell you: throughout the ages'
		db	', many young men have entered th'
		db	'e caverns, but few have returned'
		db	'.'
		db	0FFh	; +0x0A1

dialog_str_according:
		db	'According to legend, there may sti'
		db	'll be underground places that ha'
		db	've not been destroyed by Jashiin'
		db	'. People may still be living the'
		db	're, and will surely lend you a h'
		db	'and.'
		db	0FFh	; +0x0A6

dialog_str_i_have:
		db	'I have been in the underground tow'
		db	'n. After I fled, they put a lock'
		db	' on the door. If the town is sti'
		db	'll there.... '
		db	0FFh	; +0x06F

dialog_str_chamber:
		db	'This is the chamber of poor Prince'
		db	'ss Felicia, who has been turned '
		db	'to stone. You may enter, Duke Ga'
		db	'rland.'
		db	0FFh	; +0x068

dialog_str_brave_kn:
		db	'Brave knight, you have awakened. W'
		db	'hen you fell at the hand of Jash'
		db	'iin, the Spirits brought you her'
		db	'e. Now make haste to the aid of '
		db	'the Princess Felicia.'
		db	0FFh	; +0x097

dialog_str_quickly_g:
		db	'Quickly, go to the Princess!'
		db	0FFh	; +0x01C

dialog_str_ah_nine:
		db	'Ah, the Nine Tears of Esmesanti.'
		db	' Jashiin exists no more and the '
		db	'light of peace shines once again'
		db	' on our land... '
		db	0FFh	; +0x070

dialog_str_this_will:
		db	'This will benefit the people livin'
		db	'g underground, as well. Hurry to'
		db	' the Princess Felicia.'
		db	0FFh	; +0x058

dialog_str_peace_we:
		db	'The peace we dared not hope for ha'
		db	's come. I\ll get my things toget'
		db	'her and be on my way. I\ve a fam'
		db	'ily to attend to.'
		db	0FFh	; +0x073

dialog_str_quickly_e:
		db	'Quickly, enter this chamber. The h'
		db	'oly crystals will break the evil'
		db	' spell which has turned Princess'
		db	' Felicia to stone.'
		db	0FFh	; +0x074

; ------------------------------------------------------------------
; script_trailer -- event / script-byte sequence at the end of the
; file. Triggered by specific castle events; exact byte semantics
; parallel the townscript interpreter. hdr_ptr_tbl +0x12 (0xC89C)
; points into this block.
; ------------------------------------------------------------------

script_trailer:
		db	 24h, 00h, 82h, 00h, 03h	; +0x000
		db	 03h, 80h, 04h, 30h, 00h, 81h	; +0x005
		db	 18h, 00h, 00h, 00h, 00h, 38h	; +0x00B
		db	 00h, 81h, 18h, 00h, 00h, 00h	; +0x011
		db	 01h, 54h, 00h, 80h, 00h, 01h	; +0x017
		db	 03h, 00h, 02h, 5Ch, 00h, 81h	; +0x01D
		db	 18h, 00h, 00h, 00h, 03h,0FFh	; +0x023
		db	0FFh	; +0x029

zr2_36		endp

seg_a		ends

		end	start
