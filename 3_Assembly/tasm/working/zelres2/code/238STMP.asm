PAGE  59,132

;==========================================================================
;
;  238STMP - Satono Town Map Data Table (STMP.MDT)
;
;  Data-only resource file referenced by stick.asm entry 'STMP.MDT'
;  (zelres1 chunk 0x27).  Loaded by the town engine when the player
;  enters Satono Town.
;
;  NOT code.  Sourcer mis-decoded the first 3 bytes as instructions
;  (lodsb / or al,0 / add bl,dl) but those bytes are actually the
;  file header (size word 0x0CAC + section-count word 0x0002 + ...).
;
;  File layout:
;    [0x000]  header + exec-segment pointer table
;    [0x01C]  tilemap layers (8 background pages, ~0xD0 bytes each)
;    [0x6D4]  event/door header
;    [0x6E1]  town name "Satono Town" (length-prefixed)
;    [0x6EC]  door/exit table
;    [0x710]  dialog pointer table (word offsets)
;    [0x72B]  NPC dialog strings (separated by 0xFF)
;    [0xC75]  event trigger script (ends in FF FF)
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

stmp_start:

; --------------------------------------------------------------------------
; File header + exec-segment pointer table
;   dw  0x0CAC  = data size (file_size - 4)
;   dw  0x0200  = section/flag word
;   followed by 20 bytes of word pointers into code segment 0xC6xx
;   (these reference handler addresses in the town program 208SATNO)
; --------------------------------------------------------------------------

mdt_header:
		db	0ACh, 0Ch			; size word = 0x0CAC = 3244
		db	 00h, 02h			; flag/section word
		db	0DAh,0C6h, 0D7h, 00h		; exec ptr table start
		db	0D8h,0C6h, 02h,0E7h, 0C6h,0EFh	; +0x008
		db	0C6h, 00h,0C7h, 0Ch,0C7h, 72h	; +0x00E
		db	0CCh,0CFh,0C6h, 5Ch, 00h, 0Ah	; +0x014
		db	0C7h	; +0x01A
		db	 00h, 00h, 00h			; pad

; --------------------------------------------------------------------------
; Tilemap layer tables (8 pages of background tile indices)
; Format: 16-column rows, typically 11 rows per page.
; Padding zero-runs separate pages.
; --------------------------------------------------------------------------

tilemap_page_0:
		db	29 dup (0)
		db	 89h, 8Dh, 82h, 00h, 00h, 00h	; +0x01D
		db	 00h, 00h, 8Ah, 8Eh, 83h, 00h	; +0x023
		db	 00h, 00h, 00h, 00h, 74h, 7Bh	; +0x029
		db	 82h, 00h, 00h, 00h, 00h, 00h	; +0x02F
		db	 75h, 7Ch, 83h, 00h, 00h, 00h	; +0x035
		db	 00h, 00h, 74h, 7Bh, 82h, 00h	; +0x03B
		db	 00h, 00h, 95h, 98h, 75h, 7Ch	; +0x041
		db	 83h, 00h, 00h, 00h, 00h, 00h	; +0x047
		db	 74h, 7Bh, 82h, 00h, 00h, 95h	; +0x04D
		db	 97h, 99h, 75h, 7Ch, 83h, 00h	; +0x053
		db	 00h, 00h, 00h, 00h, 8Bh, 8Fh	; +0x059
		db	 82h, 00h, 95h, 97h, 96h, 99h	; +0x05F
		db	 8Ch, 90h, 83h, 00h, 00h, 00h	; +0x065
		db	 00h, 00h, 00h, 91h, 93h, 95h	; +0x06B
		db	 96h, 96h, 96h, 99h, 00h, 92h	; +0x071
		db	 94h, 00h	; +0x077
		db	77 dup (0)

tilemap_page_1:
		db	 0Eh, 14h, 19h, 1Bh, 1Bh, 1Bh	; +0x000
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh	; +0x006
		db	 1Bh, 1Bh, 1Bh, 00h, 00h, 00h	; +0x00C
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x012
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x018
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x01E
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x024
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x02A
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x030
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x036
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x03C
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x042
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x048
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x04E
		db	 1Ch, 1Ch, 1Ch, 00h, 0Dh, 13h	; +0x054
		db	 19h, 1Bh, 1Bh, 1Bh, 1Bh, 00h	; +0x05A
		db	 01h, 07h, 1Ah, 1Bh, 1Bh, 1Bh	; +0x060
		db	 1Bh, 00h	; +0x066
		db	24 dup (0)

tilemap_page_2:
		db	 1Dh, 1Fh, 1Fh, 1Fh, 1Fh, 1Fh	; +0x000
		db	 1Fh, 1Dh, 1Eh, 21h, 21h, 21h	; +0x006
		db	 21h, 21h, 21h, 1Eh, 1Eh, 21h	; +0x00C
		db	 6Ch, 2Fh, 31h, 31h, 31h, 1Eh	; +0x012
		db	 1Eh, 20h, 6Dh, 30h, 32h, 32h	; +0x018
		db	 32h, 1Eh, 1Eh, 1Fh, 6Eh, 30h	; +0x01E
		db	 00h, 00h, 00h, 1Eh, 1Eh, 21h	; +0x024
		db	 6Fh, 2Fh, 31h, 31h, 31h, 1Eh	; +0x02A
		db	 1Eh, 21h, 21h, 1Fh, 21h, 21h	; +0x030
		db	 21h, 1Eh, 1Eh, 21h, 21h, 1Fh	; +0x036
		db	 20h, 21h, 1Fh	; +0x03C
		db	'cc""""""cc""#%""Pc""$'
		db	'&""'
		db	 00h, 50h, 22h, 22h, 22h, 22h	; +0x057
		db	 22h, 22h, 00h	; +0x05D
		db	40 dup (0)

tilemap_page_3:
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh	; +0x000
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh	; +0x006
		db	 1Bh, 1Bh, 1Bh, 00h, 00h, 00h	; +0x00C
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x012
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x018
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x01E
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x024
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x02A
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x030
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x036
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x03C
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x042
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x048
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x04E
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x054
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x05A
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x060
		db	 1Ch, 00h, 0Dh, 13h, 19h, 1Bh	; +0x066
		db	 1Bh, 1Bh, 1Bh, 00h, 01h, 07h	; +0x06C
		db	 1Ah, 1Bh, 1Bh, 1Bh, 1Bh, 00h	; +0x072
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x078
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x07E
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x084
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x08A
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x090
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x096
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x09C
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x0A2
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x0A8
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x0AE
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x0B4
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x0BA
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x0C0
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x0C6
		db	 1Ch, 1Ch, 1Ch, 00h, 0Dh, 13h	; +0x0CC
		db	 19h, 1Bh, 1Bh, 1Bh, 1Bh, 00h	; +0x0D2
		db	 01h, 07h, 1Ah, 1Bh, 1Bh, 1Bh	; +0x0D8
		db	 1Bh, 00h	; +0x0DE
		db	17 dup (0)

tilemap_page_4:					; fountain tiles ('Z','[','\\' etc)
		db	59h	; +0x000
		db	7 dup (0)
		db	'Z]____5;Z]____6<Z]____6<Z]_aaa6<'
		db	'Z]_'
		db	 00h, 00h, 00h, 36h, 3Ch, 5Ah	; +0x00C
		db	']____6<Z]____6<Z]____8=Z]____9>['
		db	'^````9>[^````9>[^````:;[^````'
		db	 00h, 00h, 5Bh, 5Eh, 60h, 60h	; +0x033
		db	 60h, 60h, 00h, 00h	; +0x039
		db	5Ch	; +0x03D
		db	38 dup (0)

tilemap_page_5:
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh	; +0x000
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh	; +0x006
		db	 1Bh, 1Bh, 1Bh, 00h, 00h, 00h	; +0x00C
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x012
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x018
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x01E
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x024
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x02A
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x030
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x036
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x03C
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x042
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x048
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x04E
		db	 1Ch, 1Ch, 1Ch, 00h, 0Dh, 13h	; +0x054
		db	 19h, 1Bh, 1Bh, 1Bh, 1Bh, 00h	; +0x05A
		db	 01h, 07h, 19h, 1Bh, 1Bh, 1Bh	; +0x060
		db	 1Bh, 00h	; +0x066
		db	24 dup (0)

tilemap_page_6:					; shop/building tiles 'F','G','H'...
		db	'F', 27h, 27h, 27h, 27h, 27h, 27h
		db	'?G(', 27h, 27h, 27h, 27h, 27h, '@'
		db	'H', 27h, 27h, '(', 27h, 27h, 27h
		db	'AG', 27h, 'pbbbb@H', 27h, 'qb222'
		db	'AG(rb'
		db	 00h, 00h, 00h, 40h, 48h	; +0x02C
		db	27h, 'sbbbbAG', 27h, 27h, 27h, 27h
		db	27h, '(@H', 27h, 27h, '(', 27h, 27h
		db	27h, 'AG', 27h, 27h, 27h, 27h, 27h
		db	27h, '@I))))))AJ))*)*)DK))))))EL)'
		db	')))))'
		db	25 dup (0)

tilemap_page_7:
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh	; +0x000
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh	; +0x006
		db	 1Bh, 1Bh, 1Bh, 00h	; +0x00C
		db	17 dup (0)

tilemap_page_8:					; fountain area alt
		db	'MNNRNN5;NNQQRS6<Nh/1116<Ri02226<'
		db	'Oj0'
		db	 00h, 00h, 00h, 36h, 3Ch, 52h	; +0x004
		db	'k/1116<OSRNNR7<NSRNRN8=TUTTTV9>V'
		db	'UTUTT:;TTTTVT'
		db	0, 0	; +0x02B
		db	 58h, 54h, 56h, 54h, 54h, 56h	; +0x02D
		db	25 dup (0)

tilemap_page_9:
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh	; +0x000
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh	; +0x006
		db	 1Bh, 1Bh, 1Bh, 00h, 00h, 00h	; +0x00C
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x012
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x018
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x01E
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x024
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x02A
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x030
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x036
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x03C
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x042
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh	; +0x048
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh	; +0x04E
		db	 1Bh, 1Bh, 1Bh, 00h, 00h, 00h	; +0x054
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x05A
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x060
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x066
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x06C
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x072
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch	; +0x078
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch	; +0x07E
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h	; +0x084
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h	; +0x08A
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh	; +0x090
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh	; +0x096
		db	 1Bh, 1Bh, 1Bh, 00h	; +0x09C
		db	17 dup (0)

tilemap_page_10:				; building decoration (shutters/counters)
		db	 46h, 9Ah, 9Ah, 9Ah, 9Bh, 9Ah	; +0x000
		db	 00h, 3Fh, 47h, 9Bh, 9Ah, 9Bh	; +0x006
		db	 9Bh, 9Bh, 00h, 40h, 48h, 64h	; +0x00C
		db	 62h, 62h, 62h, 62h, 00h, 41h	; +0x012
		db	 47h, 65h, 62h, 61h, 61h, 61h	; +0x018
		db	 00h, 42h, 48h, 66h, 62h, 00h	; +0x01E
		db	 00h, 00h, 00h, 41h, 47h, 67h	; +0x024
		db	 62h, 62h, 62h, 62h, 00h, 42h	; +0x02A
		db	 48h, 9Bh, 9Ah, 9Ah, 9Bh, 9Ah	; +0x030
		db	 00h, 41h, 47h, 9Bh, 9Bh, 9Bh	; +0x036
		db	 9Bh, 9Bh, 00h, 42h, 49h, 9Dh	; +0x03C
		db	 9Dh, 9Dh, 9Dh, 9Dh, 00h, 43h	; +0x042
		db	 4Ah, 9Dh, 9Dh, 9Dh, 9Dh, 9Dh	; +0x048
		db	 00h, 44h, 4Bh, 9Dh, 9Dh, 9Dh	; +0x04E
		db	 9Dh, 9Dh, 00h, 45h, 4Ch, 9Dh	; +0x054
		db	 9Dh, 9Dh, 9Dh, 9Dh	; +0x05A
		db	41 dup (0)

tilemap_page_11:				; top-area sprite layer
		db	 79h, 80h, 00h, 00h, 00h, 00h	; +0x000
		db	 00h, 00h, 7Ah, 81h, 84h, 85h	; +0x006
		db	 85h, 85h, 87h, 74h, 7Bh, 82h	; +0x00C
		db	 00h, 00h, 00h, 00h, 00h, 75h	; +0x012
		db	 7Ch, 83h, 00h, 84h, 86h, 85h	; +0x018
		db	 87h, 74h, 7Bh, 82h, 00h, 00h	; +0x01E
		db	 00h, 00h, 00h, 75h, 7Ch, 83h	; +0x024
		db	 00h, 00h, 84h, 86h, 87h, 74h	; +0x02A
		db	 7Bh, 82h, 00h, 00h, 00h, 00h	; +0x030
		db	 00h, 75h, 7Ch, 83h, 00h, 00h	; +0x036
		db	 00h, 84h, 88h, 74h, 7Dh, 82h	; +0x03C
		db	 00h, 00h, 00h, 00h, 00h, 76h	; +0x042
		db	 7Eh, 83h, 00h, 00h, 00h, 00h	; +0x048
		db	 00h, 77h, 7Fh, 82h, 00h, 00h	; +0x04E
		db	 00h, 00h, 00h, 78h, 7Fh, 83h	; +0x054
		db	 00h, 00h	; +0x05A
		db	35 dup (0)

; --------------------------------------------------------------------------
; Event/door header + town name + door table
; --------------------------------------------------------------------------

event_header:
		db	 24h, 00h,0B4h, 00h, 02h, 01h	; +0x000
		db	0FFh, 01h, 02h, 19h,0AFh, 03h	; +0x006

town_name_len:
		db	 0Bh				; length prefix (11)

town_name:
		db	'Satono Town'

door_table:
		db	 81h, 00h,0FFh,0FFh, 80h, 01h	; +0x000
		db	0FFh,0FFh, 2Ch, 00h, 04h, 5Ch	; +0x006
		db	 00h, 02h, 80h, 00h, 07h, 94h	; +0x00C
		db	 00h, 06h,0B9h, 00h, 03h,0FFh	; +0x012
		db	0FFh, 80h, 00h, 21h, 01h, 00h	; +0x018
		db	 06h, 00h, 3Eh, 00h, 02h,0FFh	; +0x01E
		db	0FFh	; +0x024

; --------------------------------------------------------------------------
; NPC dialog pointer table (word offsets into dialog block)
; --------------------------------------------------------------------------

dialog_ptr_tbl:
		db	 1Ah,0C7h,0FBh,0C7h,0C2h	; +0x000
		db	0C8h, 98h,0C9h, 6Fh,0CAh, 02h	; +0x005
		db	0CBh, 9Dh,0CBh	; +0x00B

; --------------------------------------------------------------------------
; NPC dialog strings (separated by 0xFF terminators).
; Each block is one NPC's speech.  Embedded 0xFF = end-of-page.
; --------------------------------------------------------------------------

dialog_0_welcome:
		db	'Welcome, stranger. You must have'
		db	' come through the labyrinths fro'
		db	'm the outside world. We have not'
		db	' encountered such a brave person'
		db	' in a very long time. You should'
		db	' visit the great sage Yasmin -- '
		db	'she will be anxious to meet you.'
		db	0FFh	; +0x0E0

dialog_1_tip:
		db	 53h, 6Fh			; 'So'
		db	' you\re the brave one I\ve heard'
		db	' about. Well, if you\re going to'
		db	' go on from here, I\ll give you '
		db	'a tip.  When you come to a stopp'
		db	'ing place, dig a hole. The demon'
		db	's have hidden jewels in many pla'
		db	'ces.'
		db	0FFh	; +0x0C6

dialog_2_garland:
		db	 41h, 72h			; 'Ar'
		db	'e you Duke Garland? Thank the Sp'
		db	'irits you\ve come. We escaped fr'
		db	'om Jashiin through the power of '
		db	'the Spirits. However, if his pow'
		db	'er should become so strong that '
		db	'the Spirits\ can\t protect us, t'
		db	'his town is doomed.'
		db	0FFh	; +0x0D5

dialog_3_advice:
		db	 4Ch, 65h			; 'Le'
		db	't me give you some advice, stran'
		db	'ger. If you fall down the stone '
		db	'slab in front of the blue door, '
		db	'you will see a green door nearby'
		db	'. Don\t go through that door und'
		db	'er any circumstances -- it is a '
		db	'doorway to the past.'
		db	0FFh	; +0x0D6

dialog_4_beware:
		db	 42h, 65h			; 'Be'
		db	'ware! I went into the caverns an'
		db	'd saw an awful creature -- a gia'
		db	'nt demon octopus. It was terrify'
		db	'ing, but I escaped. I hope you w'
		db	'ill be as lucky.'
		db	0FFh	; +0x092

dialog_5_almas:
		db	 41h, 72h			; 'Ar'
		db	'e you the brave one? I&hope you '
		db	'have brought almas for us. The a'
		db	'lmas are part of Jashiin\s power'
		db	'. We use them to make medicine, '
		db	'and other useful things.'
		db	0FFh	; +0x09A

dialog_6_wall:
		db	 44h, 75h			; 'Du'
		db	'ke Garland, when you go into the'
		db	' caverns again, please try to br'
		db	'ing back more almas. To suppleme'
		db	'nt the protective power of the S'
		db	'pirits we must build a wall of a'
		db	'lmas. Unless we get more, Satono'
		db	' Town is in peril.'
		db	0FFh	; +0x0D4

; --------------------------------------------------------------------------
; Event trigger script (npc placement / shop-entrance definitions)
; Ends in FF FF.
; --------------------------------------------------------------------------

event_script:
		db	 25h, 00h, 03h, 1Ch, 00h	; +0x000
		db	 01h, 00h, 02h,0C4h, 00h, 00h	; +0x005
		db	 00h, 03h, 03h, 00h, 04h, 16h	; +0x00B
		db	 00h, 01h, 00h, 03h, 03h, 00h	; +0x011
		db	 00h, 56h, 00h, 04h, 00h, 00h	; +0x017
		db	 01h, 00h, 01h, 79h, 00h, 82h	; +0x01D
		db	 00h, 00h, 02h, 00h, 03h, 9Dh	; +0x023
		db	 00h, 02h, 00h, 00h, 01h, 00h	; +0x029
		db	 05h,0A3h, 00h, 83h, 1Ch, 00h	; +0x02F
		db	 02h, 00h, 06h,0FFh,0FFh	; +0x035

seg_a		ends

		end	stmp_start
