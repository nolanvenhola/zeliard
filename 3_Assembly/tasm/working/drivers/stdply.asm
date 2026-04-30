
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

; The 16-bit word at [80h..81h] is the cavern's X scroll column (tile
; units; wraps at map_width).  The byte at [82h] is the Y scroll row,
; paired with gvar_scroll_pos which holds the byte-offset into a
; 36-bytes-per-row tile buffer (so [82h] increments alongside
; gvar_scroll_pos by ±0x24).  Init values 0x001E and 0x00 = level 1
; starts at column 30, row 0.  Verified by static cross-reference
; against 200FIGHT.asm: 54 word ptr refs to [80h] (zero standalone refs
; to [81h]), 19 byte refs to [82h], all in scroll routines
; (scroll_pos_dec at 0x6D31, scroll_pos_inc at 0x77AC, pos_scroll_up at
; 0x67B5, process_loop_end at 0x7BC8).  See analyze_stat_layout.py.
map_scroll_col	dw	001Eh		; [80h-81h] cavern X scroll column (16-bit; init col 30)
map_scroll_row	db	0		; [82h]     cavern Y scroll row (paired with gvar_scroll_pos)
; [83h-84h]: static analysis shows BOTH are byte-only fields (no word
; access), used together in vga_operation8 to compute a tile-grid offset:
;   addr = [84h]*36 + ([83h] + 4) + gvar_scroll_pos
; Both have substantial activity (0x83: 76 refs; 0x84: 49 refs).
; 0x84 increments in `decrement_hp` (line 848-851) when hero HP decrements,
; and is capped at 7 in line 969.  0x83 is set to constants 5 (line 504)
; or 0Ch (line 542) at scene transitions.  Together they likely encode a
; sub-tile or animation-cursor position — NOT acceleration.  Keeping the
; original speculative label until functional probe pins down semantics.
; [83h-84h]: TWO INDEPENDENT screen-column counters, not a 16-bit pair.
; Runtime probe (functest/.../test_town_player_col_X83.py, 2026-04-29)
; confirms walk_right_move increments [83h] by exactly 1 within bounds.
; The earlier `ply_accel db 0Ah, 0Ah` declaration was a misread —
; init values are independent, not paired.
town_player_col	db	0Ah		; [83h] player screen column in town (range 0..0x10)
fight_player_col db	0Ah		; [84h] player screen column in fight (range 0..7)
; Gold is a 24-bit field at [85h..87h]: high byte at 0x85 + little-endian
; low word at 0x86..0x87.  Verified functionally by the harness probe of
; town.bin's add_gold_to_hero (slot 0x600C) and check_gold_sufficient
; (slot 0x600A).  See functest/test_town_dispatch_slot_60{0A,0C}.py.
hero_gold_hi	db	0		; [85h] gold high byte (24-bit field)
hero_gold_lo	db	0		; [86h] gold low byte (start of low word)
hero_gold_mid	db	0		; [87h] gold low word's high byte
;
; [88h..8Ah]: 24-bit hero_bank balance, mirrors hero_gold layout.  Used
; by 213BANKP (the bank shop chunk) — `add [89h], ax; adc [88h], dl` is
; the deposit pattern.  Runtime probe (functest/.../test_stdply_hero_bank_X88.py)
; confirmed carry propagation 0xFFFE+5 → hi=1, lo=0x0003.
hero_bank_hi	db	0		; [88h] banked-gold high byte (24-bit)
hero_bank_lo	dw	0		; [89h-8Ah] banked-gold low word
;
; hero_almas — 16-bit, NOT 8-bit.  Functional probe (fight.bin 0x917C,
; "almas-add"): add AX to word at [8Bh], cap at 0xFFFFh on carry.  See
; functest/test_player_stats_word_layout.py.
hero_almas	dw	0		; [8Bh-8Ch] alternate currency (16-bit)
;
; [8Dh..8Fh]: 201SELCT (character-select chunk) names these item_qty_count
; (byte) and item_effect_val (word).  Static analyzer matches.
item_qty_count	db	0		; [8Dh] item quantity counter
item_effect_val	dw	0		; [8Eh-8Fh] item effect value (16-bit)
;
; hero_HP — 16-bit, NOT 8-bit.  Functional probe (fight.bin 0x7685,
; HP-damage): sub AX from word at [90h], clamp to 0 on underflow.  Probe
; HP3 (HP=257, dmg=1 -> [90]=0,[91]=1) decisively confirms word storage.
; The manual's "max HP = 80" reflects gameplay balance; the storage is
; 16-bit so designers had headroom for buffs / boss multipliers.
hero_HP		dw	0050h		; [90h-91h] current HP (16-bit; init=80)
sword_type	db	1		; [92h] sword type (init 1 = SWORD_TRAINING)
shield_type	db	0		; [93h] shield type (init 0 = no shield)
;
; shield_HP — 16-bit per static analysis (word_read/word_write at 0x94).
; No functional probe yet (shield-damage at fight.bin 0x75D6 is multi-step).
shield_HP	dw	0		; [94h-95h] shield HP (16-bit; 0 = no shield)
;
; [96h..9Ch]: 201SELCT (character-select chunk) names the leading entries
; as char_exp_cap (word), char_speed/power/abilities.  Trailing 9Bh/9Ch
; have no canonical name from any chunk — left as placeholders.
char_exp_cap	dw	0		; [96h-97h] character experience cap (16-bit)
char_speed	db	0		; [98h] character speed stat
char_power	db	0		; [99h] character power stat
char_abilities	db	0		; [9Ah] character abilities flags
trade_marker_flag db	0	; [9Bh] trade-event marker (set in 200FIGHT, tested by 212ARMRP)
stat_X9C	db	0		; [9Ch] VESTIGIAL — write-only flag, no reader observed (functest 2026-04-29)
;
current_magic_spell db	0		; [9Dh] magic spell id (init 0 = no spell)
;
; [9Eh..0AAh]: 201SELCT names 0x9E as cur_magic_idx (currently selected
; magic).  0x9F has no canonical name; 0xA0 has 5 cross-segment competing
; names (likely segment-aliasing collision) — left as placeholder.
cur_magic_idx	db	0		; [9Eh] currently selected magic index (from 201SELCT)
stat_X9F	db	0		; [9Fh] VESTIGIAL — per-frame zero-clear, no reader observed (functest 2026-04-29)
music_track_count db 0		; [music_track_count] music track count (read by load_music_tracks in game.asm)
		db	10 dup (0)	; [A1h-AAh] reserved (no genuine refs found)

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
;
; OVERLAY: byte at [B2h] doubles as char_hp_max (HP ceiling).  The value
; 0x50=80 simultaneously supplies frame 8's color index AND the HP cap
; per the game manual.  Read by gm*.bin drivers as `mov bx, cs:[char_hp_max]`.
		db	50h		; [B2h] frame 8: color 80  /  char_hp_max=80 (overlay)
		db	00h		; [B3h] frame 9: color  0
;
; OVERLAY: byte at [B4h] doubles as weap_dur_max (weapon durability cap = 12).
		db	0Ch		; [B4h] frame 10: color 12 /  weap_dur_max=12 (overlay)
		db	06h		; frame 11: color  6
		db	08h		; frame 12: color  8
		db	04h		; frame 13: color  4
		db	03h		; frame 14: color  3
		db	04h		; frame 15: color  4
		db	03h		; frame 16: color  3
		db	00h		; frame 17: color  0
;
; [BCh..C3h]: 8-byte run originally labelled "reserved", but the static
; analyzer found 0xC2 is the most-tested byte in the whole stdply chunk
; (87 byte_tests as `player_facing`).  Split out C2 and C3 explicitly.
		db	6 dup (0)	; [0BCh-0C1h] reserved (no genuine refs)
player_facing	db	0		; [C2h] facing/anim flag bits (87 byte_tests)
boss_intro_flag db 0		; [boss_intro_flag] boss intro-side flag (bit-6 from boss data; gates intro_left_loop)

;--------------------------------------------------------------------------
;  Player State / Hitbox Data  [CS:0x00C4 - CS:0x00E8]
;
;  CS:[0C4h] = level/area number (read by game.bin at startup)
;  CS:[0C8h] = level tileset index (written by game.bin at runtime)
;  CS:[0D2h-0E3h] = 9-row ?? 2-byte collision bitmask (left half | right half)
;--------------------------------------------------------------------------

ply_level	db	80h		; [0C4h] level/area number (init 0x80)
		db	81h		; [0C5h] unknown player state byte
;
; [C6h..C7h]: 16-bit field (analyzer: 3 word_reads, 1 word_add).  Currently
; labelled "reserved" but actually accessed.  Purpose TBD.
heal_pulse_count dw 0		; [0C6h-0C7h] HP heal-pulse counter (16-bit; +8 HP/tick)

ply_tileset	db	00h		; [0C8h] tileset index (written at runtime)
;
; [C9h..CFh]: 7 bytes with NO genuine memory references anywhere in the
; cleaned source — verified by analyze_stat_layout.py + permissive grep
; across all 3 segment groups (game/enemy/town-npc).  The non-zero values
; are stable signatures left from original development, possibly read by
; zeliad.exe's save/load code (outside the cleaned chunks).  Treat as
; vestigial: do not write, do not assume meaning, but preserve byte image.
		db	8Ah		; [0C9h] vestigial (no refs found)
		db	0A6h, 6Bh	; [0CAh-0CBh] vestigial word (no refs)
		db	75h, 42h	; [0CCh-0CDh] vestigial word (no refs)
		db	4Ch, 4Bh	; [0CEh-0CFh] vestigial word (no refs)

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

; [E4h..E8h]: previously labelled "end padding" but the analyzer found these
; bytes are heavily used.  0xE7 is the single most-accessed byte in the whole
; stdply chunk (38 reads + 7 inc + 7 cmp + 5 or + 4 and; called "Unknown
; state var" in game.asm).  0xE6 and 0xE8 are flag bytes (test FFh).
key_count	db	0		; [E4h] player's collected-key count (from 201SELCT)
		db	0		; [E5h] truly unused (no genuine refs)
scene_trans_request db 0	; [scene_trans_request] scene-transition request (polled in main_loop_body)
gvar_pose_idx	db	0		; [E7h] player pose state (bit7=mode flag, low7=pose idx)
init_complete_flag db 0		; [init_complete_flag] post-init steady-state (cleared on area_load_flag)

stdply		endp

seg_a		ends

		end	start
