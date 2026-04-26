PAGE  59,132

;==========================================================================
;
;  239BSMP - Bosque Village Map Data Table (BSMP.MDT)
;
;  Data-only resource file referenced by stick.asm entry 'BSMP.MDT'
;  (zelres1 chunk 0x28).  Loaded by the town engine when the player
;  enters Bosque Village.
;
;  NOT code.  Original Sourcer disassembly (ZR2_39.ASM) produced 7000+
;  errors because the bytes are pure data, not x86 instructions.
;
;  File layout:
;    [0x000]  header (size word + section word + exec-segment ptr table)
;    [0x01C]  zero padding
;    [0x034]  tilemap pages (forest/village tiles, fountain, walls)
;    [0x4DB]  event/door header
;    [0x4E8]  town name "Bosque village" (length-prefixed, 0x0E = 14)
;    [0x4F6]  door/exit + dialog-header bytes
;    [0x51C]  dialog pointer table (15 word offsets into dialog block)
;    [0x53A]  NPC dialog strings (separated by 0xFF terminators)
;    [0xCFA]  event trigger script (ends in FF FF)
;
;==========================================================================

target		EQU	'T2'

include  srmacros.inc

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

bsmp_start:

; --------------------------------------------------------------------------
; File header + exec-segment pointer table
;   dw  0x0D56  = data size (file_size - 4 = 3414)
;   dw  0x0000  = flag/section word
;   followed by word pointers into code segment 0xC4xx / 0xC5xx / 0xCCxx
;   (handler addresses inside the town program 209BOSQE)
; --------------------------------------------------------------------------

mdt_header:
		db	056h, 00Dh, 000h, 000h			; size = 0x0D56, flags = 0
		db	0DBh, 0C4h, 098h, 000h			; exec ptr table
		db	0E0h, 0C4h, 003h, 0F2h	; +0x008
		db	0C4h, 0F2h, 0C4h, 009h	; +0x00C
		db	0C5h, 020h, 0C5h, 0F4h	; +0x010
		db	0CCh, 0D7h, 0C4h, 03Ch	; +0x014
		db	000h, 013h, 0C5h, 000h	; +0x018

; --------------------------------------------------------------------------
; Zero padding before first tilemap page
; --------------------------------------------------------------------------

header_pad:
		db	20 dup (0)
		db	000h, 000h, 000h	; +0x014

; --------------------------------------------------------------------------
; Tilemap page 0 - village fountain / archway tiles
;   16 cols x 11 rows, indices into tile graphics set
; --------------------------------------------------------------------------

tilemap_page_0:
		db	096h, 097h, 097h, 097h, 097h, 097h, 097h, 097h	; +0x000
		db	0A8h, 0BCh, 0BEh, 0C0h, 0C2h, 0C4h, 0C6h, 0C8h	; +0x008
		db	0A9h, 0BDh, 0BFh, 0C1h, 0C3h, 0C5h, 0C7h, 0C9h	; +0x010
		db	0AAh, 0C9h, 0CBh, 0BCh, 0CCh, 0CCh, 0CCh, 0CCh	; +0x018
		db	0B0h, 0CAh, 0CAh, 0BCh, 0CCh, 0D3h, 0D4h, 0D4h	; +0x020
		db	0B1h, 0A7h, 0C1h, 0BCh, 0CCh, 0D1h, 0D2h, 0D2h	; +0x028
		db	000h, 0B6h, 0C6h, 0BDh, 0CCh, 0CCh, 0CCh, 0CCh	; +0x030
		db	000h, 0B7h, 0AEh, 0BEh, 0C5h, 0C6h, 0C0h, 0C2h	; +0x038
		db	000h, 000h, 0B1h, 0BAh, 0C8h, 0C3h, 0C9h, 0CAh	; +0x040
		db	000h, 000h, 000h, 0B5h, 0C3h, 0C9h, 0BEh, 0C5h	; +0x048
		db	000h, 000h, 000h, 000h, 09Ch, 0C9h, 0BFh, 0C6h	; +0x050
		db	000h, 000h, 000h, 000h, 0B2h, 0B4h, 0C0h, 0C7h	; +0x058
		db	000h, 000h, 000h, 000h, 0B3h, 0B5h, 0C1h, 0C8h	; +0x060
		db	000h, 000h, 000h, 000h, 000h, 000h, 09Ch, 0C9h	; +0x068
		db	000h, 000h, 000h, 000h, 000h, 000h, 0BBh, 0BAh	; +0x070
		db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 0B9h	; +0x078
		db	000h	; +0x080

; --------------------------------------------------------------------------
; Tilemap page 1 - character glyph row ('e','h','l','l','p','t'...)
; Used as a template row for one of the village houses.
; --------------------------------------------------------------------------

tilemap_page_1:
		db	'ehllpt', 0
		db	'cfimmquw'
		db	 64h				; 'd'
		db	 85h, 89h, 85h, 89h, 8Eh, 8Eh	; +0x010
		db	 92h	; +0x016
		db	 79h, 7Dh, 81h, 85h, 8Ah, 85h	; +0x017
		db	 91h, 93h	; +0x01D
		db	 7Ah, 7Eh, 82h, 86h, 8Bh, 8Fh	; +0x01F
		db	 8Eh, 94h	; +0x025
		db	 7Bh, 7Fh, 83h, 87h, 8Ch, 8Ch	; +0x027
		db	 8Eh, 92h	; +0x02D
		db	 7Ch, 80h, 84h, 88h, 8Dh, 8Dh	; +0x02F
		db	 91h, 93h	; +0x035
		db	 7Ah, 7Eh, 84h, 85h, 89h, 8Dh	; +0x037
		db	 8Eh, 94h	; +0x03D
		db	 7Bh, 81h, 85h, 86h, 8Ah, 90h	; +0x03F
		db	 8Eh, 92h	; +0x045
		db	 64h, 6Ah, 86h, 87h, 8Bh, 88h	; +0x047
		db	 91h, 93h, 00h	; +0x04D
		db	 6Bh, 6Ah, 88h, 8Ch, 8Bh	; +0x050
		db	'vx', 0
		db	 00h, 6Bh, 6Fh, 72h, 6Fh	; +0x058
		db	 00h, 00h, 00h, 00h	; +0x05D

; --------------------------------------------------------------------------
; Tilemap page 2 - interior walls (11 wall tiles)
; --------------------------------------------------------------------------

tilemap_page_2:
		db	 0Bh, 14h, 14h, 14h, 14h, 14h, 00h	; +0x000
		db	 03h, 0Ch, 15h, 15h, 15h, 15h, 15h, 00h	; +0x007
		db	 04h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h	; +0x00F
		db	 05h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h	; +0x017
		db	 06h, 0Dh, 16h, 51h, 16h, 16h, 16h, 00h	; +0x01F
		db	 06h, 0Dh, 16h, 52h, 1Ch, 1Ch, 1Ch, 00h	; +0x027
		db	 06h, 0Dh, 16h, 53h, 01h, 01h, 01h, 00h	; +0x02F
		db	 06h, 0Dh, 16h, 54h, 16h, 16h, 16h, 00h	; +0x037
		db	 06h, 0Eh, 18h, 18h, 18h, 18h, 18h, 00h	; +0x03F
		db	 07h, 0Fh, 19h, 19h, 19h, 19h, 19h, 00h	; +0x047
		db	 08h, 10h, 19h, 19h, 19h, 19h, 19h, 00h	; +0x04F
		db	 09h, 11h, 19h, 1Dh, 1Dh, 19h, 19h, 00h	; +0x057
		db	 5Eh, 5Dh, 19h, 19h, 19h, 19h, 19h, 00h	; +0x05F
		db	 00h, 13h, 1Bh, 1Bh, 1Bh, 1Bh, 1Bh, 00h	; +0x067

; --------------------------------------------------------------------------
; Tilemap page 3 - column/column-alt glyph row
; --------------------------------------------------------------------------

tilemap_page_3:
		db	'ehlps', 0, 0
		db	'cfimqqt', 0
		db	 64h, 67h, 89h, 89h, 89h	; +0x00F
		db	 6Eh, 75h, 77h	; +0x014
		db	 79h, 7Dh, 81h, 85h, 8Ah, 8Eh, 92h, 92h	; +0x017
		db	 7Ah, 7Eh, 82h, 86h, 8Bh, 8Dh, 91h, 93h	; +0x01F
		db	 7Bh, 7Fh, 83h, 87h, 8Ch, 8Eh, 8Eh, 92h	; +0x027
		db	 7Ch, 80h, 84h, 88h, 8Ch, 8Ah, 91h, 92h, 00h	; +0x02F
		db	 80h, 85h, 81h, 86h, 8Bh, 90h, 94h	; +0x038
		db	 63h, 66h, 85h, 84h, 88h, 8Dh, 91h, 95h	; +0x03F
		db	 64h, 67h, 6Ah, 6Eh, 6Eh, 6Eh	; +0x047
		db	'vx', 0, 0
		db	 6Bh, 6Fh, 72h, 6Fh, 72h	; +0x051
		db	 00h, 00h, 00h	; +0x056

; --------------------------------------------------------------------------
; Tilemap page 4 - waterfall / blue tiles
; --------------------------------------------------------------------------

tilemap_page_4:
		db	0D7h, 0DDh, 000h	; +0x000
		db	000h, 000h, 000h, 000h, 000h	; +0x003
		db	0D8h, 0DEh, 0E6h, 0E6h, 0E6h, 0E4h, 000h, 000h	; +0x008
		db	0D8h, 0DFh, 0E6h, 0E6h, 0E6h, 0E5h, 000h, 000h	; +0x010
		db	0D8h, 0DEh, 0E4h, 0E6h, 0E6h, 0E6h, 000h, 000h	; +0x018
		db	0D8h, 0DFh, 0E5h, 0E8h, 0E8h, 0E8h, 000h, 000h	; +0x020
		db	0D8h, 0DEh, 0E4h, 001h, 001h, 001h, 000h, 000h	; +0x028
		db	0D8h, 0DFh, 0E5h, 001h, 001h, 001h, 000h, 000h	; +0x030
		db	0D8h, 0DEh, 0E4h, 0E9h, 0E9h, 0E9h, 000h	; +0x038
		db	002h, 0D9h, 0E0h, 0E5h, 0EAh, 0EAh, 0EAh, 000h	; +0x03F
		db	000h, 0DAh, 0E1h, 0EFh, 0EFh, 0EEh, 0ECh, 000h	; +0x047
		db	000h, 0DBh, 0E1h, 0EFh, 0EEh, 0EFh, 0EDh, 000h	; +0x04F
		db	000h, 0DBh, 0E1h, 0EFh, 0EFh, 0EFh, 0EEh, 000h	; +0x057
		db	000h, 0DCh, 0E3h, 000h, 000h, 000h, 000h, 000h	; +0x05F

; --------------------------------------------------------------------------
; Tilemap page 5 - char glyph row with embedded partial path/tiles
; --------------------------------------------------------------------------

tilemap_page_5:
		db	'eh', 0, 'lps', 0
		db	'cfip', 6Dh, 8Dh
		db	 75h, 77h, 79h, 7Dh, 81h, 8Bh, 85h, 88h	; +0x00D
		db	 8Eh, 94h	; +0x015
		db	 7Ah, 7Eh, 82h, 86h, 8Bh, 8Fh, 8Eh, 94h	; +0x017
		db	 7Bh, 7Fh, 83h, 87h, 8Ch, 90h, 91h, 95h	; +0x01F
		db	 7Ch, 80h, 84h, 88h, 8Dh, 88h, 8Eh, 92h	; +0x027
		db	 64h, 81h, 85h, 6Eh, 89h, 89h	; +0x02F
		db	'vx', 0, 0
		db	 6Bh, 6Fh, 72h, 72h, 00h, 00h, 00h, 00h	; +0x039

; --------------------------------------------------------------------------
; Tilemap page 6 - walls with door sprite markers (0x55-0x58 = 'U'-'X')
; --------------------------------------------------------------------------

tilemap_page_6:
		db	0D7h	; +0x000
		db	 23h, 23h, 23h, 23h, 23h, 00h, 00h	; +0x001
		db	0D8h	; +0x008
		db	 22h, 22h, 22h, 22h, 22h, 00h, 00h	; +0x009
		db	0D8h	; +0x010
		db	 22h, 22h, 22h, 22h, 22h, 00h, 00h	; +0x011
		db	0D8h	; +0x018
		db	 22h, 55h, 22h, 22h, 22h, 00h, 00h	; +0x019
		db	0D8h	; +0x020
		db	 22h, 56h, 1Ch, 1Ch, 1Ch, 00h, 00h	; +0x021
		db	0D8h	; +0x028
		db	 22h, 57h, 01h, 01h, 01h, 00h, 00h	; +0x029
		db	0D9h	; +0x030
		db	 22h, 58h, 22h, 22h, 22h, 00h, 00h	; +0x031
		db	0DAh	; +0x038
		db	 24h, 24h, 24h, 24h, 24h, 00h, 00h	; +0x039
		db	0DBh	; +0x040
		db	 24h, 24h, 24h, 24h, 24h, 00h, 00h	; +0x041
		db	0DBh	; +0x048
		db	 24h, 24h, 24h, 24h, 24h, 00h, 00h	; +0x049
		db	0DCh	; +0x050
		db	 25h, 25h, 25h, 25h, 25h, 00h	; +0x051

; --------------------------------------------------------------------------
; Tilemap page 7 - short row: 'lpt' partial
; --------------------------------------------------------------------------

tilemap_page_7:
		db	 00h, 00h, 00h, 6Ch, 70h, 74h, 00h, 00h	; +0x000
		db	 00h, 63h, 6Dh, 6Dh, 71h, 75h, 77h, 00h	; +0x008
		db	 00h, 64h, 6Eh, 6Eh, 89h	; +0x010
		db	'vx', 0, 0, 0, 0
		db	 6Fh, 72h, 00h, 00h, 00h, 00h, 00h	; +0x01B

; --------------------------------------------------------------------------
; Tilemap page 8 - interior wall pattern (duplicate of page 2 with variants)
; --------------------------------------------------------------------------

tilemap_page_8:
		db	 5Fh, 14h, 14h, 14h, 14h, 00h	; +0x000
		db	 00h, 03h, 62h, 1Fh, 1Fh, 1Fh, 20h, 00h	; +0x006
		db	 00h, 04h, 0Dh, 1Fh, 1Fh, 1Fh, 20h, 00h	; +0x00E
		db	 00h, 05h, 0Dh, 4Dh, 1Fh, 1Fh, 20h, 00h	; +0x016
		db	 00h, 06h, 0Dh, 4Eh, 1Ch, 1Ch, 1Ch, 00h	; +0x01E
		db	 00h, 06h, 0Dh, 4Fh, 01h, 01h, 01h, 00h	; +0x026
		db	 00h, 06h, 0Dh, 50h, 1Fh, 1Fh, 20h, 00h	; +0x02E
		db	 00h, 06h, 0Eh, 18h, 18h, 18h, 18h, 00h	; +0x036
		db	 00h, 07h, 0Fh, 19h, 19h, 19h, 19h, 00h	; +0x03E
		db	 00h, 08h, 10h, 19h, 19h, 19h, 19h, 00h	; +0x046
		db	 00h, 09h, 11h, 19h, 19h, 19h, 19h, 00h	; +0x04E
		db	 00h, 05Eh, 060h, 19h, 19h, 19h, 19h, 00h	; +0x056
		db	 00h, 00h, 61h, 1Bh, 1Bh, 1Bh, 1Ah, 00h	; +0x05E

; --------------------------------------------------------------------------
; Tilemap page 9 - character glyph rows (short entries)
; --------------------------------------------------------------------------

tilemap_page_9:
		db	 63h, 66h, 6Dh, 6Dh, 71h, 75h, 77h, 00h	; +0x000
		db	 64h, 67h, 6Eh, 71h, 71h, 76h, 78h, 00h	; +0x008
		db	 00h, 00h, 6Fh, 72h, 6Fh, 72h, 00h, 00h	; +0x010

; --------------------------------------------------------------------------
; Tilemap page 10 - interior walls (matches page 2 layout)
; --------------------------------------------------------------------------

tilemap_page_10:
		db	 00h, 0Bh, 14h, 14h, 14h, 14h, 14h, 00h	; +0x000
		db	 03h, 0Ch, 15h, 15h, 15h, 15h, 15h, 00h	; +0x008
		db	 04h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h	; +0x010
		db	 05h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h	; +0x018
		db	 06h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h	; +0x020
		db	 06h, 0Dh, 16h, 59h, 17h, 17h, 17h, 00h	; +0x028
		db	 06h, 0Dh, 16h, 5Ah, 1Ch, 1Ch, 1Ch, 00h	; +0x030
		db	 06h, 0Dh, 16h, 5Bh, 01h, 01h, 01h, 00h	; +0x038
		db	 06h, 0Dh, 16h, 5Ch, 16h, 16h, 16h, 00h	; +0x040
		db	 06h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h	; +0x048
		db	 06h, 0Eh, 18h, 18h, 18h, 18h, 18h, 00h	; +0x050
		db	 07h, 0Fh, 19h, 19h, 19h, 19h, 19h, 00h	; +0x058
		db	 08h, 10h, 19h, 1Ah, 1Ah, 19h, 19h, 00h	; +0x060
		db	 09h, 11h, 19h, 1Dh, 1Dh, 19h, 19h	; +0x068
		db	 02h, 0Ah, 12h, 19h, 19h, 19h, 19h, 19h, 00h	; +0x06F
		db	 00h, 13h, 1Bh, 1Bh, 1Bh, 1Bh, 1Bh, 00h	; +0x078

; --------------------------------------------------------------------------
; Tilemap page 11 - short glyph row (sparse)
; --------------------------------------------------------------------------

tilemap_page_11:
		db	 00h, 00h, 6Ch, 6Ch, 73h, 00h, 00h, 00h	; +0x000
		db	 65h, 69h, 6Dh, 6Dh, 8Dh, 74h, 00h, 00h	; +0x008
		db	 66h, 89h, 85h, 8Dh, 8Dh	; +0x010
		db	 75h, 77h	; +0x015
		db	 7Ch, 80h, 84h, 88h, 89h, 8Eh, 8Eh, 94h, 00h	; +0x017
		db	 64h, 6Ah, 8Ch, 89h, 87h, 8Bh, 93h, 00h	; +0x020
		db	 00h, 6Bh, 6Eh, 8Ch, 6Eh	; +0x028
		db	'vx', 0, 0, 0, 0
		db	 72h, 6Fh, 72h	; +0x033
		db	 00h, 00h, 00h, 00h, 00h	; +0x036

; --------------------------------------------------------------------------
; Tilemap page 12 - complex fountain/statue tilemap
; --------------------------------------------------------------------------

tilemap_page_12:
		db	 00h, 00h, 9Bh, 99h, 00h, 00h, 00h, 00h	; +0x000
		db	 00h, 00h, 9Ch, 9Ah, 00h, 00h, 00h, 00h	; +0x008
		db	 00h, 99h, 0BCh, 0BEh, 00h, 00h, 00h	; +0x010
		db	 00h, 99h, 0BCh, 0BDh, 0BFh, 00h, 00h, 00h	; +0x017
		db	 99h, 09Ah, 0BCh, 0C0h, 0C2h, 00h, 00h, 0A2h	; +0x01F
		db	 9Ah, 0BCh, 0BEh, 0C1h, 0C3h, 00h, 00h, 0A3h	; +0x027
		db	 0C0h, 0BDh, 0BFh, 0C1h, 0C6h, 00h	; +0x02F
		db	 0ACh, 0ADh, 0C1h, 0C2h, 0C2h, 0C5h, 0C7h, 00h	; +0x035
		db	 0A9h, 0C8h, 0C2h, 0C6h, 0C3h, 0C8h, 0BFh, 00h	; +0x03D
		db	 0A8h, 0C9h, 0CBh, 0BFh, 0C4h, 0C9h, 0CBh, 00h	; +0x045
		db	 0A9h, 0BCh, 0BEh, 0CCh, 0CCh, 0CCh, 0CCh, 00h	; +0x04D
		db	 0A6h, 0BDh, 0BFh, 0CCh, 0CDh, 0CEh, 0CEh, 0A5h	; +0x055
		db	 0A7h, 0C0h, 0C2h, 0CCh, 0CFh, 0D0h, 0D0h, 00h	; +0x05D
		db	 0A0h, 0C1h, 0C3h, 0CCh, 0CCh, 0CCh, 0CCh, 0A2h	; +0x065
		db	 0A4h, 0C4h, 0C6h, 0BFh, 0CAh, 0BFh, 0C5h, 09Fh	; +0x06D
		db	 0A1h, 0C5h, 0C7h, 0C6h, 0C5h, 0C5h, 0CAh, 0A0h	; +0x075
		db	 0C4h, 0C8h, 0CAh, 0CAh, 0BFh, 0CAh, 0CAh	; +0x07D
		db	 96h, 97h, 97h, 97h, 97h, 97h, 97h, 97h	; +0x084
		db	 00h	; +0x08C
		db	18 dup (0)

; --------------------------------------------------------------------------
; Zero padding between final tilemap page and event header
; --------------------------------------------------------------------------
		db	5 dup (0)

; --------------------------------------------------------------------------
; Event/door header + town name + door table
; --------------------------------------------------------------------------

event_header:
		db	 43h, 00h, 7Bh, 00h, 04h, 00h,0FFh, 00h	; +0x000
		db	 01h, 18h,0AFh, 00h	; +0x008

town_name_len:
		db	 0Eh				; length prefix (14)

town_name:
		db	'Bosque village'

door_table:
		db	 07h, 00h, 09h, 24h, 00h, 06h, 3Dh, 00h	; +0x000
		db	 02h, 51h, 00h, 04h, 60h, 00h, 03h, 72h	; +0x008
		db	 00h, 07h, 8Eh, 00h, 08h,0FFh,0FFh,0B9h	; +0x010
		db	 00h, 13h, 00h, 05h, 95h, 00h, 0Eh, 01h	; +0x018
		db	 06h, 12h, 00h, 08h,0FAh,0CCh, 80h,0FBh	; +0x020
		db	0CCh, 0Eh,0FFh,0FFh,0FFh,0FFh	; +0x028

; --------------------------------------------------------------------------
; NPC dialog pointer table (15 word offsets into dialog block)
; --------------------------------------------------------------------------

dialog_ptr_tbl:
		db	 3Eh,0C5h, 05h,0C6h, 93h,0C6h, 95h,0C7h	; +0x000
		db	0FAh,0C7h, 46h,0C8h,0F9h,0C8h,0B3h,0C9h	; +0x008
		db	 3Eh,0CAh, 19h,0CBh, 8Dh,0CBh,0FAh,0CBh	; +0x010
		db	 28h,0CCh, 5Ah,0CCh,0B5h,0CCh	; +0x018

; --------------------------------------------------------------------------
; NPC dialog strings (separated by 0xFF terminators).
; Each block is one NPC's speech.
; --------------------------------------------------------------------------

dialog_0_welcome:
		db	'Welcome to Bosque Village, brave'
		db	' warrior. This once was a forest'
		db	' surrounding a temple, but the t'
		db	'emple was destroyed by Jashiin. '
		db	'Now the village of Bosque is des'
		db	'olate. I hope you are here to he'
		db	'lp us.'
		db	0FFh	; +0x0C6

dialog_1_sentry_warning:
		db	'Listen, stranger, a sentry is po'
		db	'sted on the outskirts of the cit'
		db	'y. I\m telling you this for your'
		db	' own good; it\s best to stay awa'
		db	'y from there.'
		db	0FFh	; +0x06E

dialog_2_temple_history:
		db	'The temple that once stood here '
		db	'had the crest of the Warrior God'
		db	' carved into it. Winners of the '
		db	'martial arts competitions held '
		db	'in front of the temple were awa'
		db	'rded with such crests. Thus the '
		db	'crest, the symbol of a true her'
		db	'o, became known as the Hero\s C'
		db	'rest.'
		db	0FFh	; +0x101

dialog_3_crest_stolen:
		db	'When he destroyed the temple, Ja'
		db	'shiin stole the Hero\s Crest.  N'
		db	'o one has any idea where to fin'
		db	'd it.'
		db	0FFh	; +0x064

dialog_4_crest_hint:
		db	'The crest must be hidden somewhe'
		db	're in the forest, but I couldn'
		db	'\t say where.'
		db	0FFh	; +0x04B

dialog_5_crest_tree:
		db	'When the temple was destroyed I '
		db	'heard Jashiin ordering his unde'
		db	'rlings to hide the crest in the'
		db	' trunk of the biggest tree. Tha'
		db	't must be where it is hidden. I'
		db	' hope you can find it.'
		db	0FFh	; +0x0B2

dialog_6_spirit_cross:
		db	'A spirit appeared and told me t'
		db	'o say this if I met a brave man'
		db	': "If you go through the door t'
		db	'o the right of the tree that fo'
		db	'rms a cross, you will be able t'
		db	'o go up."/I&hope it helps you.'
		db	0FFh	; +0x0B9

dialog_7_thin_ground:
		db	'I have some advice for you: Be '
		db	'careful if you come to a place '
		db	'where the leaves of the trees a'
		db	're thin. The ground there is n'
		db	'ot very strong.'
		db	0FFh	; +0x08A

dialog_8_spirit_sentry:
		db	'The sentry at the edge of town '
		db	'says the Spirits came to him i'
		db	'n a dream, and told him not to '
		db	'allow anyone to pass unless th'
		db	'ey bear the Hero\s Crest. I wo'
		db	'nder if the Spirits really ord'
		db	'ered such a thing? Perhaps he\'
		db	's mad.'
		db	0FFh	; +0x0DA

dialog_9_monster:
		db	'A few have slipped by the sent'
		db	'ry undetected, but none have r'
		db	'eturned. There must be some te'
		db	'rrible monster out there.'
		db	0FFh	; +0x073

dialog_10_sold_soul:
		db	'That sentry must have sold his '
		db	'soul to Jashiin. Why else woul'
		db	'd he interfere with brave men '
		db	'such as yourself?'
		db	0FFh	; +0x06C

dialog_11_sentry_challenge:
		db	'Hold on there! Do you have the '
		db	'Hero\s Crest? '
		db	 81h				; portrait/anim code
		db	'Don'
		db	'\t lie, it won\t do any good. G'
		db	'et out of here!'
		db	0FFh	; +0x05F

dialog_12_cannot_pass:
		db	'You cannot pass here without th'
		db	'e Hero\s Crest. My orders are f'
		db	'rom the Spirits themselves! '
		db	0FFh	; +0x05A

dialog_13_may_pass:
		db	'Hold on there! You have the Her'
		db	'o\s Crest, I see. You may pass.'
		db	0FFh	; +0x03E

; --------------------------------------------------------------------------
; Event trigger script (sentry placement / doors / shop entrances).
; Ends in FF FF.
; --------------------------------------------------------------------------

event_script:
		db	 09h, 00h, 01h,0CCh, 00h, 04h,0C0h, 0Bh	; +0x000
		db	 65h, 00h, 81h, 19h, 00h, 00h, 00h, 02h	; +0x008
		db	 15h, 00h, 04h, 8Eh, 00h, 05h, 00h, 0Ah	; +0x010
		db	 6Bh, 00h, 04h, 6Fh, 00h, 05h, 00h, 06h	; +0x018
		db	 57h, 00h, 84h, 25h, 00h, 06h, 00h, 04h	; +0x020
		db	 83h, 00h, 00h, 00h, 03h, 03h, 00h, 00h	; +0x028
		db	 4Fh, 00h, 00h, 22h, 00h, 01h, 00h, 01h	; +0x030
		db	 5Ah, 00h, 00h, 89h, 00h, 02h, 00h, 07h	; +0x038
		db	 2Ch, 00h, 00h, 1Bh, 03h, 03h, 00h, 08h	; +0x040
		db	 44h, 00h, 00h, 00h, 00h, 05h, 00h, 05h	; +0x048
		db	 59h, 00h, 02h, 8Bh, 03h, 03h, 00h, 03h	; +0x050
		db	 20h, 00h, 02h, 15h, 00h, 06h, 00h, 09h	; +0x058
		db	0FFh,0FFh	; +0x060

seg_a		ends

		end	bsmp_start
