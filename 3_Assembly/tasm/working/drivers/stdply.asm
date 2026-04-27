
PAGE  59,132

;==========================================================================
;
;  STDPLY.BIN - Hero Stat Record + Player Config (Data-Only Module)
;
;  Loaded by zeliad.exe at game_entry_seg:0000h (before stick.bin at 0100h
;  and game.bin at A000h). game.bin reads this data via CS-relative addresses
;  since it shares the same segment. No executable code -- pure config tables.
;
;  If a save file is present at startup, zeliad loads the save instead of this
;  file (same load address), restoring the player's persistent state.
;
;  CORRECTED 2026-04-26 — the 0x85-0x9D block was previously interpreted as
;  driver state but is actually the HERO STAT RECORD. Initial byte values
;  match documented game mechanics (HP=80=0x50, sword=1=TRAINING, gold=0).
;  See evidence_check.py and EVIDENCE_REPORT.md for the per-byte verdict.
;
;  Memory layout (all addresses are CS-relative):
;    0x0000-0x007F  key_map_table (128 bytes, 64 word entries)
;    0x0080-0x0084  Player config (walk_speed, accel — purpose inconclusive)
;    0x0085-0x009D  Hero stat record (gold, HP, sword/shield, magic spell)
;    0x009E-0x00AA  Reserved
;    0x00AB-0x00C3  Animation color LUT (purpose inconclusive)
;    0x00C4-0x00E8  Player sprite / hitbox data
;
;  Connections:
;    Loads:        none (pure data; no executable code)
;    Calls into:   none (data-only)
;    Called by:    not directly — zeliad.exe loads this file at
;                  game_seg:0x0000 before stick.bin / game.bin. Active save
;                  files override this with the player's saved state at the
;                  same load address. Read by gm*.bin graphics drivers
;                  (CS-relative offsets) and by game.bin / fight.bin via
;                  the same shared segment.
;    Reads/writes: provides initial values for hero_gold_hi/lo, hero_almas,
;                  hero_HP, sword_type, shield_type, shield_HP,
;                  current_magic_spell at game_seg:0x0085-0x009D, plus
;                  ply_walk_speed/ply_accel and the animation color LUT.
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
;  Key Mapping Table  [CS:0x0000 - CS:0x007F]
;  64 word entries; each word = action ID for that scancode index.
;  All zero at default: key assignments are written at runtime by the
;  key-config screen, or restored from a save file on startup.
;--------------------------------------------------------------------------

key_map_table	dw	64 dup (0)

;--------------------------------------------------------------------------
;  Hero Stat Record  [CS:0x0085 - CS:0x009D]
;
;  The hero's persistent state — gold, HP, equipment, magic spell. Validated
;  against the game manual (max HP = 80) and IDA's enum constants
;  (SWORD_TRAINING = 1).
;
;  Note: drv_frame_idx (formerly named) is now current_magic_spell — the
;  byte at 0x9D init=0 (no spell at start), not an animation frame index.
;--------------------------------------------------------------------------

ply_walk_speed	db	1Eh		; [80h] init 0x1E=30 (purpose inconclusive)
		db	00h, 00h	; [81h-82h] reserved
ply_accel	db	0Ah, 0Ah	; [83h-84h] init 0x0A,0x0A (purpose inconclusive)
hero_gold_hi	db	0		; [85h] gold high byte (init 0x00 = no gold)
hero_gold_lo	db	0		; [86h] gold low byte
		db	4 dup (0)	; [87h-8Ah] reserved
hero_almas	db	0		; [8Bh] alternate currency (init 0)
		db	4 dup (0)	; [8Ch-8Fh] reserved
hero_HP		db	50h		; [90h] current HP (init 0x50=80, max per manual)
		db	0		; [91h] reserved
sword_type	db	1		; [92h] sword type (init 1 = SWORD_TRAINING)
shield_type	db	0		; [93h] shield type (init 0 = no shield)
shield_HP	db	0		; [94h] shield HP (init 0; no shield)
		db	8 dup (0)	; [95h-9Ch] reserved
current_magic_spell db	0		; [9Dh] magic spell id (init 0 = no spell)
		db	13 dup (0)	; [9Eh-0AAh] reserved

;--------------------------------------------------------------------------
;  Animation Color LUT  [CS:0x00AB - CS:0x00C3]  (drv_color_lut base = ABh)
;
;  Indexed as cs:[bx-1] where bx = current_magic_spell + 1 (or similar).
;  Each byte is the palette/color index for that frame.
;  17 active entries + 8 reserved zeros.
;
;  NOTE: previously labeled as anim_color_lut — IDA names this
;  spells_espada (Spanish 'espada' = sword/spell). Purpose
;  remains inconclusive until further evidence.
;--------------------------------------------------------------------------

anim_color_lut	db	0Ch		; frame  1: color 12
		db	06h		; frame  2: color  6
		db	08h		; frame  3: color  8
		db	04h		; frame  4: color  4
		db	03h		; frame  5: color  3
		db	04h		; frame  6: color  4
		db	03h		; frame  7: color  3
		db	50h		; frame  8: color 80
		db	00h		; frame  9: color  0
		db	0Ch		; frame 10: color 12
		db	06h		; frame 11: color  6
		db	08h		; frame 12: color  8
		db	04h		; frame 13: color  4
		db	03h		; frame 14: color  3
		db	04h		; frame 15: color  4
		db	03h		; frame 16: color  3
		db	00h		; frame 17: color  0
		db	8 dup (0)	; [0BCh-0C3h] reserved

;--------------------------------------------------------------------------
;  Player State / Hitbox Data  [CS:0x00C4 - CS:0x00E8]
;
;  CS:[0C4h] = level/area number (read by game.bin at startup)
;  CS:[0C8h] = level tileset index (written by game.bin at runtime)
;  CS:[0D2h-0E3h] = 9-row ?? 2-byte collision bitmask (left half | right half)
;--------------------------------------------------------------------------

ply_level	db	80h		; [0C4h] level/area number (init 0x80)
		db	81h		; [0C5h] unknown player state byte
		db	00h, 00h	; [0C6h-0C7h] reserved

ply_tileset	db	00h		; [0C8h] tileset index (written at runtime)
		db	8Ah		; [0C9h] unknown player state byte
		db	0A6h, 6Bh	; [0CAh-0CBh] unknown (166, 107)
		db	75h, 42h	; [0CCh-0CDh] unknown (117,  66)
		db	4Ch, 4Bh	; [0CEh-0CFh] unknown ( 76,  75)

		db	01h, 0FFh	; [0D0h-0D1h] mask header (count=1, fill=FFh)

; 9-row collision bitmask  (left-byte | right-byte per row):
ply_hitbox	db	0C0h, 0C0h	; row 0  ##......  ##......
		db	0E0h, 0E0h	; row 1  ###.....  ###.....
		db	70h,  38h	; row 2  .###....  ..###...
		db	38h,  0F8h	; row 3  ..###...  #####...
		db	0F8h, 0C0h	; row 4  #####...  ##......
		db	0E0h, 0E0h	; row 5  ###.....  ###.....
		db	70h,  30h	; row 6  .###....  ..##....
		db	38h,  1Ch	; row 7  ..###...  ...###..
		db	1Ch,  0FCh	; row 8  ...###..  ######..

		db	5 dup (0)	; [0E4h-0E8h] end padding

stdply		endp

seg_a		ends

		end	start
