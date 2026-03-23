
PAGE  59,132

;==========================================================================
;
;  STDPLY.BIN - Standard Player Input Driver (Data-Only Module)
;
;  Loaded by zeliad.exe as the default player input configuration.
;  Contains key mappings, movement parameters, and player sprite masks.
;  No executable code - purely configuration data tables.
;
;  Code type: zero start
;  Created:   16-Feb-26
;  Passes:    9          Analysis Options on: none
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

stdply		proc	far

start:

;--------------------------------------------------------------------------
;  Key Mapping Table (128 bytes)
;  64 word entries mapping scancodes to game actions
;  Indexed by keyboard scancode, value = action ID
;--------------------------------------------------------------------------

key_map_table	dw	64 dup (0)

;--------------------------------------------------------------------------
;  Player Movement Parameters
;  Walk speed, acceleration, jump height, etc.
;--------------------------------------------------------------------------

movement_params	db	 1Eh, 00h, 00h, 0Ah, 0Ah
		db	11 dup (0)
		db	 50h, 00h, 01h
		db	24 dup (0)

;--------------------------------------------------------------------------
;  Attack/Combat Parameters
;  Sword reach, attack speed, damage frames, etc.
;--------------------------------------------------------------------------

combat_params	db	 0Ch, 06h, 08h, 04h, 03h, 04h
		db	 03h, 50h, 00h, 0Ch, 06h, 08h
		db	 04h, 03h, 04h, 03h, 00h
		db	8 dup (0)

;--------------------------------------------------------------------------
;  Player Sprite Mask / Collision Data
;  Bitmask data for player hitbox and sprite rendering
;--------------------------------------------------------------------------

sprite_masks	db	 80h, 81h, 00h, 00h, 00h, 8Ah
		db	0A6h, 6Bh, 75h, 42h, 4Ch, 4Bh
		db	 01h,0FFh,0C0h,0C0h,0E0h,0E0h
		db	 70h, 38h, 38h,0F8h,0F8h,0C0h
		db	0E0h,0E0h, 70h, 30h, 38h, 1Ch
		db	 1Ch,0FCh, 00h, 00h, 00h, 00h
		db	 00h

stdply		endp

seg_a		ends



		end	start
