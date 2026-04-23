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
		db	0E0h, 0C4h, 003h, 0F2h
		db	0C4h, 0F2h, 0C4h, 009h
		db	0C5h, 020h, 0C5h, 0F4h
		db	0CCh, 0D7h, 0C4h, 03Ch
		db	000h, 013h, 0C5h, 000h

; --------------------------------------------------------------------------
; Zero padding before first tilemap page
; --------------------------------------------------------------------------

header_pad:
		db	20 dup (0)
		db	000h, 000h, 000h

; --------------------------------------------------------------------------
; Tilemap page 0 - village fountain / archway tiles
;   16 cols x 11 rows, indices into tile graphics set
; --------------------------------------------------------------------------

tilemap_page_0:
		db	096h, 097h, 097h, 097h, 097h, 097h, 097h, 097h
		db	0A8h, 0BCh, 0BEh, 0C0h, 0C2h, 0C4h, 0C6h, 0C8h
		db	0A9h, 0BDh, 0BFh, 0C1h, 0C3h, 0C5h, 0C7h, 0C9h
		db	0AAh, 0C9h, 0CBh, 0BCh, 0CCh, 0CCh, 0CCh, 0CCh
		db	0B0h, 0CAh, 0CAh, 0BCh, 0CCh, 0D3h, 0D4h, 0D4h
		db	0B1h, 0A7h, 0C1h, 0BCh, 0CCh, 0D1h, 0D2h, 0D2h
		db	000h, 0B6h, 0C6h, 0BDh, 0CCh, 0CCh, 0CCh, 0CCh
		db	000h, 0B7h, 0AEh, 0BEh, 0C5h, 0C6h, 0C0h, 0C2h
		db	000h, 000h, 0B1h, 0BAh, 0C8h, 0C3h, 0C9h, 0CAh
		db	000h, 000h, 000h, 0B5h, 0C3h, 0C9h, 0BEh, 0C5h
		db	000h, 000h, 000h, 000h, 09Ch, 0C9h, 0BFh, 0C6h
		db	000h, 000h, 000h, 000h, 0B2h, 0B4h, 0C0h, 0C7h
		db	000h, 000h, 000h, 000h, 0B3h, 0B5h, 0C1h, 0C8h
		db	000h, 000h, 000h, 000h, 000h, 000h, 09Ch, 0C9h
		db	000h, 000h, 000h, 000h, 000h, 000h, 0BBh, 0BAh
		db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 0B9h
		db	000h

; --------------------------------------------------------------------------
; Tilemap page 1 - character glyph row ('e','h','l','l','p','t'...)
; Used as a template row for one of the village houses.
; --------------------------------------------------------------------------

tilemap_page_1:
		db	'ehllpt', 0
		db	'cfimmquw'
		db	 64h				; 'd'
		db	 85h, 89h, 85h, 89h, 8Eh, 8Eh
		db	 92h
		db	 79h, 7Dh, 81h, 85h, 8Ah, 85h
		db	 91h, 93h
		db	 7Ah, 7Eh, 82h, 86h, 8Bh, 8Fh
		db	 8Eh, 94h
		db	 7Bh, 7Fh, 83h, 87h, 8Ch, 8Ch
		db	 8Eh, 92h
		db	 7Ch, 80h, 84h, 88h, 8Dh, 8Dh
		db	 91h, 93h
		db	 7Ah, 7Eh, 84h, 85h, 89h, 8Dh
		db	 8Eh, 94h
		db	 7Bh, 81h, 85h, 86h, 8Ah, 90h
		db	 8Eh, 92h
		db	 64h, 6Ah, 86h, 87h, 8Bh, 88h
		db	 91h, 93h, 00h
		db	 6Bh, 6Ah, 88h, 8Ch, 8Bh
		db	'vx', 0
		db	 00h, 6Bh, 6Fh, 72h, 6Fh
		db	 00h, 00h, 00h, 00h

; --------------------------------------------------------------------------
; Tilemap page 2 - interior walls (11 wall tiles)
; --------------------------------------------------------------------------

tilemap_page_2:
		db	 0Bh, 14h, 14h, 14h, 14h, 14h, 00h
		db	 03h, 0Ch, 15h, 15h, 15h, 15h, 15h, 00h
		db	 04h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h
		db	 05h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h
		db	 06h, 0Dh, 16h, 51h, 16h, 16h, 16h, 00h
		db	 06h, 0Dh, 16h, 52h, 1Ch, 1Ch, 1Ch, 00h
		db	 06h, 0Dh, 16h, 53h, 01h, 01h, 01h, 00h
		db	 06h, 0Dh, 16h, 54h, 16h, 16h, 16h, 00h
		db	 06h, 0Eh, 18h, 18h, 18h, 18h, 18h, 00h
		db	 07h, 0Fh, 19h, 19h, 19h, 19h, 19h, 00h
		db	 08h, 10h, 19h, 19h, 19h, 19h, 19h, 00h
		db	 09h, 11h, 19h, 1Dh, 1Dh, 19h, 19h, 00h
		db	 5Eh, 5Dh, 19h, 19h, 19h, 19h, 19h, 00h
		db	 00h, 13h, 1Bh, 1Bh, 1Bh, 1Bh, 1Bh, 00h

; --------------------------------------------------------------------------
; Tilemap page 3 - column/column-alt glyph row
; --------------------------------------------------------------------------

tilemap_page_3:
		db	'ehlps', 0, 0
		db	'cfimqqt', 0
		db	 64h, 67h, 89h, 89h, 89h
		db	 6Eh, 75h, 77h
		db	 79h, 7Dh, 81h, 85h, 8Ah, 8Eh, 92h, 92h
		db	 7Ah, 7Eh, 82h, 86h, 8Bh, 8Dh, 91h, 93h
		db	 7Bh, 7Fh, 83h, 87h, 8Ch, 8Eh, 8Eh, 92h
		db	 7Ch, 80h, 84h, 88h, 8Ch, 8Ah, 91h, 92h, 00h
		db	 80h, 85h, 81h, 86h, 8Bh, 90h, 94h
		db	 63h, 66h, 85h, 84h, 88h, 8Dh, 91h, 95h
		db	 64h, 67h, 6Ah, 6Eh, 6Eh, 6Eh
		db	'vx', 0, 0
		db	 6Bh, 6Fh, 72h, 6Fh, 72h
		db	 00h, 00h, 00h

; --------------------------------------------------------------------------
; Tilemap page 4 - waterfall / blue tiles
; --------------------------------------------------------------------------

tilemap_page_4:
		db	0D7h, 0DDh, 000h
		db	000h, 000h, 000h, 000h, 000h
		db	0D8h, 0DEh, 0E6h, 0E6h, 0E6h, 0E4h, 000h, 000h
		db	0D8h, 0DFh, 0E6h, 0E6h, 0E6h, 0E5h, 000h, 000h
		db	0D8h, 0DEh, 0E4h, 0E6h, 0E6h, 0E6h, 000h, 000h
		db	0D8h, 0DFh, 0E5h, 0E8h, 0E8h, 0E8h, 000h, 000h
		db	0D8h, 0DEh, 0E4h, 001h, 001h, 001h, 000h, 000h
		db	0D8h, 0DFh, 0E5h, 001h, 001h, 001h, 000h, 000h
		db	0D8h, 0DEh, 0E4h, 0E9h, 0E9h, 0E9h, 000h
		db	002h, 0D9h, 0E0h, 0E5h, 0EAh, 0EAh, 0EAh, 000h
		db	000h, 0DAh, 0E1h, 0EFh, 0EFh, 0EEh, 0ECh, 000h
		db	000h, 0DBh, 0E1h, 0EFh, 0EEh, 0EFh, 0EDh, 000h
		db	000h, 0DBh, 0E1h, 0EFh, 0EFh, 0EFh, 0EEh, 000h
		db	000h, 0DCh, 0E3h, 000h, 000h, 000h, 000h, 000h

; --------------------------------------------------------------------------
; Tilemap page 5 - char glyph row with embedded partial path/tiles
; --------------------------------------------------------------------------

tilemap_page_5:
		db	'eh', 0, 'lps', 0
		db	'cfip', 6Dh, 8Dh
		db	 75h, 77h, 79h, 7Dh, 81h, 8Bh, 85h, 88h
		db	 8Eh, 94h
		db	 7Ah, 7Eh, 82h, 86h, 8Bh, 8Fh, 8Eh, 94h
		db	 7Bh, 7Fh, 83h, 87h, 8Ch, 90h, 91h, 95h
		db	 7Ch, 80h, 84h, 88h, 8Dh, 88h, 8Eh, 92h
		db	 64h, 81h, 85h, 6Eh, 89h, 89h
		db	'vx', 0, 0
		db	 6Bh, 6Fh, 72h, 72h, 00h, 00h, 00h, 00h

; --------------------------------------------------------------------------
; Tilemap page 6 - walls with door sprite markers (0x55-0x58 = 'U'-'X')
; --------------------------------------------------------------------------

tilemap_page_6:
		db	0D7h
		db	 23h, 23h, 23h, 23h, 23h, 00h, 00h
		db	0D8h
		db	 22h, 22h, 22h, 22h, 22h, 00h, 00h
		db	0D8h
		db	 22h, 22h, 22h, 22h, 22h, 00h, 00h
		db	0D8h
		db	 22h, 55h, 22h, 22h, 22h, 00h, 00h
		db	0D8h
		db	 22h, 56h, 1Ch, 1Ch, 1Ch, 00h, 00h
		db	0D8h
		db	 22h, 57h, 01h, 01h, 01h, 00h, 00h
		db	0D9h
		db	 22h, 58h, 22h, 22h, 22h, 00h, 00h
		db	0DAh
		db	 24h, 24h, 24h, 24h, 24h, 00h, 00h
		db	0DBh
		db	 24h, 24h, 24h, 24h, 24h, 00h, 00h
		db	0DBh
		db	 24h, 24h, 24h, 24h, 24h, 00h, 00h
		db	0DCh
		db	 25h, 25h, 25h, 25h, 25h, 00h

; --------------------------------------------------------------------------
; Tilemap page 7 - short row: 'lpt' partial
; --------------------------------------------------------------------------

tilemap_page_7:
		db	 00h, 00h, 00h, 6Ch, 70h, 74h, 00h, 00h
		db	 00h, 63h, 6Dh, 6Dh, 71h, 75h, 77h, 00h
		db	 00h, 64h, 6Eh, 6Eh, 89h
		db	'vx', 0, 0, 0, 0
		db	 6Fh, 72h, 00h, 00h, 00h, 00h, 00h

; --------------------------------------------------------------------------
; Tilemap page 8 - interior wall pattern (duplicate of page 2 with variants)
; --------------------------------------------------------------------------

tilemap_page_8:
		db	 5Fh, 14h, 14h, 14h, 14h, 00h
		db	 00h, 03h, 62h, 1Fh, 1Fh, 1Fh, 20h, 00h
		db	 00h, 04h, 0Dh, 1Fh, 1Fh, 1Fh, 20h, 00h
		db	 00h, 05h, 0Dh, 4Dh, 1Fh, 1Fh, 20h, 00h
		db	 00h, 06h, 0Dh, 4Eh, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 06h, 0Dh, 4Fh, 01h, 01h, 01h, 00h
		db	 00h, 06h, 0Dh, 50h, 1Fh, 1Fh, 20h, 00h
		db	 00h, 06h, 0Eh, 18h, 18h, 18h, 18h, 00h
		db	 00h, 07h, 0Fh, 19h, 19h, 19h, 19h, 00h
		db	 00h, 08h, 10h, 19h, 19h, 19h, 19h, 00h
		db	 00h, 09h, 11h, 19h, 19h, 19h, 19h, 00h
		db	 00h, 05Eh, 060h, 19h, 19h, 19h, 19h, 00h
		db	 00h, 00h, 61h, 1Bh, 1Bh, 1Bh, 1Ah, 00h

; --------------------------------------------------------------------------
; Tilemap page 9 - character glyph rows (short entries)
; --------------------------------------------------------------------------

tilemap_page_9:
		db	 63h, 66h, 6Dh, 6Dh, 71h, 75h, 77h, 00h
		db	 64h, 67h, 6Eh, 71h, 71h, 76h, 78h, 00h
		db	 00h, 00h, 6Fh, 72h, 6Fh, 72h, 00h, 00h

; --------------------------------------------------------------------------
; Tilemap page 10 - interior walls (matches page 2 layout)
; --------------------------------------------------------------------------

tilemap_page_10:
		db	 00h, 0Bh, 14h, 14h, 14h, 14h, 14h, 00h
		db	 03h, 0Ch, 15h, 15h, 15h, 15h, 15h, 00h
		db	 04h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h
		db	 05h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h
		db	 06h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h
		db	 06h, 0Dh, 16h, 59h, 17h, 17h, 17h, 00h
		db	 06h, 0Dh, 16h, 5Ah, 1Ch, 1Ch, 1Ch, 00h
		db	 06h, 0Dh, 16h, 5Bh, 01h, 01h, 01h, 00h
		db	 06h, 0Dh, 16h, 5Ch, 16h, 16h, 16h, 00h
		db	 06h, 0Dh, 16h, 16h, 16h, 16h, 16h, 00h
		db	 06h, 0Eh, 18h, 18h, 18h, 18h, 18h, 00h
		db	 07h, 0Fh, 19h, 19h, 19h, 19h, 19h, 00h
		db	 08h, 10h, 19h, 1Ah, 1Ah, 19h, 19h, 00h
		db	 09h, 11h, 19h, 1Dh, 1Dh, 19h, 19h
		db	 02h, 0Ah, 12h, 19h, 19h, 19h, 19h, 19h, 00h
		db	 00h, 13h, 1Bh, 1Bh, 1Bh, 1Bh, 1Bh, 00h

; --------------------------------------------------------------------------
; Tilemap page 11 - short glyph row (sparse)
; --------------------------------------------------------------------------

tilemap_page_11:
		db	 00h, 00h, 6Ch, 6Ch, 73h, 00h, 00h, 00h
		db	 65h, 69h, 6Dh, 6Dh, 8Dh, 74h, 00h, 00h
		db	 66h, 89h, 85h, 8Dh, 8Dh
		db	 75h, 77h
		db	 7Ch, 80h, 84h, 88h, 89h, 8Eh, 8Eh, 94h, 00h
		db	 64h, 6Ah, 8Ch, 89h, 87h, 8Bh, 93h, 00h
		db	 00h, 6Bh, 6Eh, 8Ch, 6Eh
		db	'vx', 0, 0, 0, 0
		db	 72h, 6Fh, 72h
		db	 00h, 00h, 00h, 00h, 00h

; --------------------------------------------------------------------------
; Tilemap page 12 - complex fountain/statue tilemap
; --------------------------------------------------------------------------

tilemap_page_12:
		db	 00h, 00h, 9Bh, 99h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 9Ch, 9Ah, 00h, 00h, 00h, 00h
		db	 00h, 99h, 0BCh, 0BEh, 00h, 00h, 00h
		db	 00h, 99h, 0BCh, 0BDh, 0BFh, 00h, 00h, 00h
		db	 99h, 09Ah, 0BCh, 0C0h, 0C2h, 00h, 00h, 0A2h
		db	 9Ah, 0BCh, 0BEh, 0C1h, 0C3h, 00h, 00h, 0A3h
		db	 0C0h, 0BDh, 0BFh, 0C1h, 0C6h, 00h
		db	 0ACh, 0ADh, 0C1h, 0C2h, 0C2h, 0C5h, 0C7h, 00h
		db	 0A9h, 0C8h, 0C2h, 0C6h, 0C3h, 0C8h, 0BFh, 00h
		db	 0A8h, 0C9h, 0CBh, 0BFh, 0C4h, 0C9h, 0CBh, 00h
		db	 0A9h, 0BCh, 0BEh, 0CCh, 0CCh, 0CCh, 0CCh, 00h
		db	 0A6h, 0BDh, 0BFh, 0CCh, 0CDh, 0CEh, 0CEh, 0A5h
		db	 0A7h, 0C0h, 0C2h, 0CCh, 0CFh, 0D0h, 0D0h, 00h
		db	 0A0h, 0C1h, 0C3h, 0CCh, 0CCh, 0CCh, 0CCh, 0A2h
		db	 0A4h, 0C4h, 0C6h, 0BFh, 0CAh, 0BFh, 0C5h, 09Fh
		db	 0A1h, 0C5h, 0C7h, 0C6h, 0C5h, 0C5h, 0CAh, 0A0h
		db	 0C4h, 0C8h, 0CAh, 0CAh, 0BFh, 0CAh, 0CAh
		db	 96h, 97h, 97h, 97h, 97h, 97h, 97h, 97h
		db	 00h
		db	18 dup (0)

; --------------------------------------------------------------------------
; Zero padding between final tilemap page and event header
; --------------------------------------------------------------------------
		db	5 dup (0)

; --------------------------------------------------------------------------
; Event/door header + town name + door table
; --------------------------------------------------------------------------

event_header:
		db	 43h, 00h, 7Bh, 00h, 04h, 00h,0FFh, 00h
		db	 01h, 18h,0AFh, 00h

town_name_len:
		db	 0Eh				; length prefix (14)

town_name:
		db	'Bosque village'

door_table:
		db	 07h, 00h, 09h, 24h, 00h, 06h, 3Dh, 00h
		db	 02h, 51h, 00h, 04h, 60h, 00h, 03h, 72h
		db	 00h, 07h, 8Eh, 00h, 08h,0FFh,0FFh,0B9h
		db	 00h, 13h, 00h, 05h, 95h, 00h, 0Eh, 01h
		db	 06h, 12h, 00h, 08h,0FAh,0CCh, 80h,0FBh
		db	0CCh, 0Eh,0FFh,0FFh,0FFh,0FFh

; --------------------------------------------------------------------------
; NPC dialog pointer table (15 word offsets into dialog block)
; --------------------------------------------------------------------------

dialog_ptr_tbl:
		db	 3Eh,0C5h, 05h,0C6h, 93h,0C6h, 95h,0C7h
		db	0FAh,0C7h, 46h,0C8h,0F9h,0C8h,0B3h,0C9h
		db	 3Eh,0CAh, 19h,0CBh, 8Dh,0CBh,0FAh,0CBh
		db	 28h,0CCh, 5Ah,0CCh,0B5h,0CCh

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
		db	0FFh

dialog_1_sentry_warning:
		db	'Listen, stranger, a sentry is po'
		db	'sted on the outskirts of the cit'
		db	'y. I\m telling you this for your'
		db	' own good; it\s best to stay awa'
		db	'y from there.'
		db	0FFh

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
		db	0FFh

dialog_3_crest_stolen:
		db	'When he destroyed the temple, Ja'
		db	'shiin stole the Hero\s Crest.  N'
		db	'o one has any idea where to fin'
		db	'd it.'
		db	0FFh

dialog_4_crest_hint:
		db	'The crest must be hidden somewhe'
		db	're in the forest, but I couldn'
		db	'\t say where.'
		db	0FFh

dialog_5_crest_tree:
		db	'When the temple was destroyed I '
		db	'heard Jashiin ordering his unde'
		db	'rlings to hide the crest in the'
		db	' trunk of the biggest tree. Tha'
		db	't must be where it is hidden. I'
		db	' hope you can find it.'
		db	0FFh

dialog_6_spirit_cross:
		db	'A spirit appeared and told me t'
		db	'o say this if I met a brave man'
		db	': "If you go through the door t'
		db	'o the right of the tree that fo'
		db	'rms a cross, you will be able t'
		db	'o go up."/I&hope it helps you.'
		db	0FFh

dialog_7_thin_ground:
		db	'I have some advice for you: Be '
		db	'careful if you come to a place '
		db	'where the leaves of the trees a'
		db	're thin. The ground there is n'
		db	'ot very strong.'
		db	0FFh

dialog_8_spirit_sentry:
		db	'The sentry at the edge of town '
		db	'says the Spirits came to him i'
		db	'n a dream, and told him not to '
		db	'allow anyone to pass unless th'
		db	'ey bear the Hero\s Crest. I wo'
		db	'nder if the Spirits really ord'
		db	'ered such a thing? Perhaps he\'
		db	's mad.'
		db	0FFh

dialog_9_monster:
		db	'A few have slipped by the sent'
		db	'ry undetected, but none have r'
		db	'eturned. There must be some te'
		db	'rrible monster out there.'
		db	0FFh

dialog_10_sold_soul:
		db	'That sentry must have sold his '
		db	'soul to Jashiin. Why else woul'
		db	'd he interfere with brave men '
		db	'such as yourself?'
		db	0FFh

dialog_11_sentry_challenge:
		db	'Hold on there! Do you have the '
		db	'Hero\s Crest? '
		db	 81h				; portrait/anim code
		db	'Don'
		db	'\t lie, it won\t do any good. G'
		db	'et out of here!'
		db	0FFh

dialog_12_cannot_pass:
		db	'You cannot pass here without th'
		db	'e Hero\s Crest. My orders are f'
		db	'rom the Spirits themselves! '
		db	0FFh

dialog_13_may_pass:
		db	'Hold on there! You have the Her'
		db	'o\s Crest, I see. You may pass.'
		db	0FFh

; --------------------------------------------------------------------------
; Event trigger script (sentry placement / doors / shop entrances).
; Ends in FF FF.
; --------------------------------------------------------------------------

event_script:
		db	 09h, 00h, 01h,0CCh, 00h, 04h,0C0h, 0Bh
		db	 65h, 00h, 81h, 19h, 00h, 00h, 00h, 02h
		db	 15h, 00h, 04h, 8Eh, 00h, 05h, 00h, 0Ah
		db	 6Bh, 00h, 04h, 6Fh, 00h, 05h, 00h, 06h
		db	 57h, 00h, 84h, 25h, 00h, 06h, 00h, 04h
		db	 83h, 00h, 00h, 00h, 03h, 03h, 00h, 00h
		db	 4Fh, 00h, 00h, 22h, 00h, 01h, 00h, 01h
		db	 5Ah, 00h, 00h, 89h, 00h, 02h, 00h, 07h
		db	 2Ch, 00h, 00h, 1Bh, 03h, 03h, 00h, 08h
		db	 44h, 00h, 00h, 00h, 00h, 05h, 00h, 05h
		db	 59h, 00h, 02h, 8Bh, 03h, 03h, 00h, 03h
		db	 20h, 00h, 02h, 15h, 00h, 06h, 00h, 09h
		db	0FFh,0FFh

seg_a		ends

		end	bsmp_start
