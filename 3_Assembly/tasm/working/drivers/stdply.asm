
PAGE  59,132

;==========================================================================
;
;  STDPLY.BIN - Standard Player Input Driver (Data-Only Module)
;
;  Loaded by zeliad.exe at game_entry_seg:0000h (before stick.bin at 0100h
;  and game.bin at A000h). game.bin reads this data via CS-relative addresses
;  since it shares the same segment. No executable code ?-- pure config tables.
;
;  If a save file is present at startup, zeliad loads the save instead of this
;  file (same load address), restoring the player's key assignments.
;
;  Memory layout (all addresses are CS-relative):
;    0x0000-0x007F  key_map_table (128 bytes, 64 word entries)
;    0x0080-0x00AA  Player + driver state block (init values)
;    0x00AB-0x00C3  Animation color LUT (drv_color_lut base = 0xAB)
;    0x00C4-0x00E8  Player sprite / hitbox data
;
;  Connections:
;    Loads:        none (pure data; no executable code)
;    Calls into:   none (data-only)
;    Called by:    not directly — zeliad.exe loads this file at
;                  game_seg:0x0000 before stick.bin / game.bin. Active save
;                  files override this with the player's saved state at the
;                  same load address. Read by gm*.bin graphics drivers
;                  (CS-relative offsets into ply_*/drv_* fields) and by
;                  game.bin / fight.bin via the same shared segment.
;    Reads/writes: provides initial values for ply_walk_speed, ply_accel,
;                  ply_jump_flag, drv_timer_flag, drv_time_param_a/b/c,
;                  drv_text_src, drv_sprite_flag, drv_color_lut at
;                  game_seg:0x0080-0x00C3 (stdply-owned slots)
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
;  Player + Driver State Block  [CS:0x0080 - CS:0x00AA]
;
;  The graphics driver (gm*.bin) reads/writes named fields in this block
;  at their exact CS-relative offsets. Driver EQU names are shown in brackets.
;  Bytes between named fields are reserved (must be 0 at startup).
;
;  0x0080 [ply_walk_speed]:  initial walk speed
;  0x0083 [ply_accel]:       movement acceleration (x then y)
;  0x0085 [drv_timer_flag]:  timer display active flag
;  0x0086 [drv_time_param_a]:timestamp word, low byte
;  0x008B [drv_time_param_b]:timestamp word, high byte
;  0x0090 [drv_text_src]:    text source stride (0x50 = 80 = EGA row width)
;  0x0092 [ply_jump_flag]:   jump enable flag
;  0x0093 [drv_sprite_flag]: sprite display active flag
;  0x0094 [drv_time_param_c]:time counter byte
;  0x009D [drv_frame_idx]:   current animation frame index (1-based)
;--------------------------------------------------------------------------

ply_walk_speed	db	1Eh		; [80h] walk speed (30)
		db	00h, 00h	; [81h-82h] reserved
ply_accel	db	0Ah, 0Ah	; [83h-84h] movement acceleration (x, y = 10)
drv_timer_flag	db	0		; [85h] timer display active (0=off)
drv_time_param_a db	0		; [86h] timestamp low byte
		db	4 dup (0)	; [87h-8Ah] reserved
drv_time_param_b db	0		; [8Bh] timestamp high byte
		db	4 dup (0)	; [8Ch-8Fh] reserved
drv_text_src	db	50h		; [90h] text source stride (80 = EGA row width)
		db	0		; [91h] reserved
ply_jump_flag	db	1		; [92h] jump enable flag
drv_sprite_flag	db	0		; [93h] sprite display active (0=off)
drv_time_param_c db	0		; [94h] time counter
		db	8 dup (0)	; [95h-9Ch] reserved
drv_frame_idx	db	0		; [9Dh] animation frame index (1-based; 0=none)
		db	13 dup (0)	; [9Eh-0AAh] reserved

;--------------------------------------------------------------------------
;  Animation Color LUT  [CS:0x00AB - CS:0x00C3]  (drv_color_lut base = ABh)
;
;  Indexed as cs:[drv_frame_idx - 1] by the graphics driver.
;  Each byte is the palette/color index for that animation frame.
;  17 active entries + 8 reserved zeros.
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
