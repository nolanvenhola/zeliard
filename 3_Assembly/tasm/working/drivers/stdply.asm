
PAGE  59,132

;==========================================================================
;
;  STDPLY.BIN - Player Stat Record + Player Config (Data-Only Module)
;
;  Loaded by zeliad.exe at game_entry_seg:0000h (before stick.bin at 0100h
;  and game.bin at A000h). game.bin reads this data via CS-relative addresses
;  since it shares the same segment. No executable code -- pure config tables.
;
;  If a save file is present at startup, zeliad loads the save instead of this
;  file (same load address), restoring the player's persistent state.
;
;  CORRECTED 2026-04-26 — the 0x85-0x9D block was previously interpreted as
;  driver state but is actually the PLAYER STAT RECORD. Initial byte values
;  match documented game mechanics (HP=80=0x50, sword=1=TRAINING, gold=0).
;  See evidence_check.py and EVIDENCE_REPORT.md for the per-byte verdict.
;
;  Memory layout (all addresses are CS-relative):
;    0x0000-0x007F  key_map_table (128 bytes, 64 word entries)
;    0x0080-0x0084  Player config (walk_speed, accel — purpose inconclusive)
;    0x0085-0x009D  Player stat record (gold, HP, equipped weapon/magic, XP, stats)
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
;    Reads/writes: provides initial values for player_gold_hi/lo, player_almas,
;                  player_HP, equipped_weapon, shield_type, shield_HP,
;                  shield_max_HP, cur_weapon_idx at game_seg:0x0085-0x009D, plus
;                  player_walk_speed/player_accel and the animation color LUT.
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
;  Player Stat Record  [CS:0x0085 - CS:0x009D]
;
;  The player's persistent state — gold, HP, equipment, magic spell. Validated
;  against the game manual (max HP = 80) and IDA's enum constants
;  (SWORD_TRAINING = 1).
;
;  Note: drv_frame_idx (formerly named) is now cur_weapon_idx — the
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
; 0x84 increments in `decrement_hp` (line 848-851) when player HP decrements,
; and is capped at 7 in line 969.  0x83 is set to constants 5 (line 504)
; or 0Ch (line 542) at scene transitions.  Together they likely encode a
; sub-tile or animation-cursor position — NOT acceleration.  Keeping the
; original speculative label until functional probe pins down semantics.
; [83h-84h]: TWO INDEPENDENT screen-column counters, not a 16-bit pair.
; Runtime probe (functest/.../test_town_player_col_X83.py, 2026-04-29)
; confirms walk_right_move increments [83h] by exactly 1 within bounds.
; The earlier `player_accel db 0Ah, 0Ah` declaration was a misread —
; init values are independent, not paired.
town_player_col	db	0Ah		; [83h] player screen column in town (range 0..0x10)
fight_player_col db	0Ah		; [84h] player screen column in fight (range 0..7)
; Gold is a 24-bit field at [85h..87h]: high byte at 0x85 + little-endian
; low word at 0x86..0x87.  Verified functionally by the harness probe of
; town.bin's add_gold_to_hero (slot 0x600C) and check_gold_sufficient
; (slot 0x600A).  See functest/test_town_dispatch_slot_60{0A,0C}.py.
player_gold_hi	db	0		; [85h] gold high byte (24-bit field)
player_gold_lo	db	0		; [86h] gold low byte (start of low word)
player_gold_mid	db	0		; [87h] gold low word's high byte
;
; [88h..8Ah]: 24-bit player_bank balance, mirrors player_gold layout.  Used
; by 213BANKP (the bank shop chunk) — `add [89h], ax; adc [88h], dl` is
; the deposit pattern.  Runtime probe (functest/.../test_stdply_hero_bank_X88.py)
; confirmed carry propagation 0xFFFE+5 → hi=1, lo=0x0003.
player_bank_hi	db	0		; [88h] banked-gold high byte (24-bit)
player_bank_lo	dw	0		; [89h-8Ah] banked-gold low word
;
; player_almas — 16-bit, NOT 8-bit.  Functional probe (fight.bin 0x917C,
; "almas-add"): add AX to word at [8Bh], cap at 0xFFFFh on carry.  See
; functest/test_player_stats_word_layout.py.
player_almas	dw	0		; [8Bh-8Ch] alternate currency (16-bit)
;
; [8Dh..8Fh]: 201SELCT (character-select chunk) names these item_qty_count
; (byte) and item_effect_val (word).  Static analyzer matches.
item_qty_count	db	0		; [8Dh] item quantity counter
item_effect_val	dw	0		; [8Eh-8Fh] item effect value (16-bit)
;
; player_HP — 16-bit, NOT 8-bit.  Functional probe (fight.bin 0x7685,
; HP-damage): sub AX from word at [90h], clamp to 0 on underflow.  Probe
; HP3 (HP=257, dmg=1 -> [90]=0,[91]=1) decisively confirms word storage.
; The manual's "max HP = 80" reflects gameplay balance; the storage is
; 16-bit so designers had headroom for buffs / boss multipliers.
player_HP		dw	0050h		; [90h-91h] current HP (16-bit; init=80)
equipped_weapon	db	1		; [92h] equipped weapon idx (1-based; init 1 = SWORD_TRAINING)
shield_type	db	0		; [93h] shield tier (1-based; init 0 = no shield)
;
; shield_HP (16-bit word) — current shield HP.  200FIGHT
; apply_combat_damage_with_absorb (line 3501) subtracts damage scaled
; by shield_type tier from this word; on underflow, clears both [93h]
; and [94h] = "shield broken".  201SELCT's use_magia_stone adds an
; effect-tbl[shield_type] amount to this word and clamps to shield_max_HP
; — consistent with the magia stone being a shield-repair item.
shield_HP	dw	0		; [94h-95h] current shield HP (16-bit; init=0)
;
; [96h..9Ch]: shield_max_HP (16-bit cap), then player_speed/power, then
; the 3-byte player_abilities table at 9A-9C — 201SELCT draw_abilities
; reads abilities as a unit (`mov si, player_abilities; lodsb x3`).
; Specific ability semantics for each slot are TBD; tracked in AUDIT_TODO.md.
shield_max_HP	dw	0		; [96h-97h] shield max HP cap (16-bit)
player_speed	db	0		; [98h] character speed stat
player_power	db	0		; [99h] character power stat
crest_elf db	0		; [9Ah] ability slot 1 (= player_abilities table base)
crest_glory db	0		; [9Bh] ability slot 2 (212ARMRP gates trade dialog when set)
crest_hero db	0		; [9Ch] ability slot 3 (set by 200FIGHT entity_fn_e_4 on 9AF3 trigger)
;
; 0x9D = SELECTED SPELL.  User correction: this byte holds the ID of
; the currently selected spell (0=none, 1=Espada..7=Guerra).  No
; spell-slot mechanic — just one selected spell at a time.  Earlier
; names cur_weapon_idx / weapon_tier_max were wrong (this is not
; weapon-related at all).
selected_spell	db	0		; [9Dh] currently selected spell ID
;
; 0x9E = TBD (was cur_magic_idx, briefly mislabelled selected_spell).
; Values 0..5 across saves — possibly magic-menu cursor position.
stat_X9E	db	0		; [9Eh] TBD — was cur_magic_idx
stat_X9F	db	0		; [9Fh] VESTIGIAL — per-frame zero-clear, no reader observed
;
; 0xA0 = count of spells learned (cached popcount of spell_known_*
; @ 0xBB..0xC1).  Earlier "music_track_count" was a misnomer.
spells_learned_count db 0	; [A0h] count of spells learned (== popcount(0xBB..0xC1))
;
; 0xA1..0xA5: WEARABLE acquisition list (4 shoes + 1 cape).  Each byte
; holds the ID of the Nth wearable acquired (0=empty).  ID mapping (user-
; confirmed): 1=Feruza, 2=Pirika, 3=Silkarn, 4=Ruzeria, 5=AsbestosCape.
; Earlier names "magic_flags" / "spell_slot_1..5" were misleading
; (these track wearables, not spells).
wear_1		db	0		; [A1h] 1st wearable acquired
wear_2		db	0		; [A2h] 2nd wearable acquired
wear_3		db	0		; [A3h] 3rd wearable acquired
wear_4		db	0		; [A4h] 4th wearable acquired
wear_5		db	0		; [A5h] 5th wearable acquired
;
; 0xA6..0xAA: 5-slot item inventory.  User-confirmed: items DO have a
; slot mechanic.  Each byte = ID of item in that slot (0=empty; 1..8
; per §5.3.1: Ken'ko, Juu-en, Elixir, Chikara, Magia, Holy Water,
; Sabre Oil, Kioku Feather).  Same item can occupy multiple slots
; (Helada=5,5,5,5,0 → 4 Magia Stones).
item_slot_1	db	0		; [A6h] inventory slot 1
item_slot_2	db	0		; [A7h] inventory slot 2
item_slot_3	db	0		; [A8h] inventory slot 3
item_slot_4	db	0		; [A9h] inventory slot 4
item_slot_5	db	0		; [AAh] inventory slot 5

;--------------------------------------------------------------------------
;  Animation Color LUT  [CS:0x00AB - CS:0x00C3]  (drv_color_lut base = ABh)
;
;  Each byte is a palette/color index for an animation frame.
;  17 active entries + 8 reserved zeros.  Bytes at B2 and B4 do double
;  duty as player_hp_max / weap_dur_max (overlay; their numeric values
;  satisfy both the LUT-color role and the stat-cap role).
;
;  NOTE: IDA names this `spells_espada` (Spanish 'espada' = sword/spell).
;  Indexing relationship to cur_weapon_idx / equipped_weapon not yet
;  pinned down by functional probe; treat as inconclusive.
;--------------------------------------------------------------------------

anim_color_lut	db	0Ch		; frame  1: color 12
		db	06h		; frame  2: color  6
		db	08h		; frame  3: color  8
		db	04h		; frame  4: color  4
		db	03h		; frame  5: color  3
		db	04h		; frame  6: color  4
		db	03h		; frame  7: color  3
;
; OVERLAY: byte at [B2h] doubles as player_hp_max (HP ceiling).  The value
; 0x50=80 simultaneously supplies frame 8's color index AND the HP cap
; per the game manual.  Read by gm*.bin drivers as `mov bx, cs:[player_hp_max]`.
		db	50h		; [B2h] frame 8: color 80  /  player_hp_max=80 (overlay)
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
;
; OVERLAY: byte at [BBh] is anim_color_lut frame 17 (init=0x00) AND the
; spell_known_espada flag at runtime.  Set to 0FFh by zeliad.exe when
; the player learns Espada from a Sage.
;
; [BBh..C1h]: 7 spell-availability flags, one per spell (Espada, Saeta,
; Fuego, Lanzar, Rascar, Agua, Guerra — playthrough.txt §6.1).  Each
; toggles 0->FF when that spell is learned from a Sage.  Distinct from
; magic_flags at [A1h..A5h] which is the 5-slot current spell inventory.
;
; Earlier interpretation as "boss_kill_<name>" was based on the per-
; town progression pattern matching boss-defeat order; user-corrected
; (spell-learning and boss-kills both progress at every town transition,
; so save data alone can't distinguish them).  Mapping below is the
; playthrough §6.1 spell-list order; in-game validation pending via
; save_editor_gui.py byte-toggle tests.
spell_known_espada db 0	; [BBh] spell 1: weak sword throw  (also: anim_color_lut frame 17 = color 0)
spell_known_saeta  db 0	; [BCh] spell 2: arrow shot
spell_known_fuego  db 0	; [BDh] spell 3: fire
spell_known_lanzar db 0	; [BEh] spell 4: flame jet
spell_known_rascar db 0	; [BFh] spell 5: falling rocks
spell_known_agua   db 0	; [C0h] spell 6: water
spell_known_guerra db 0	; [C1h] spell 7: lightning ultimate
player_facing	db	0		; [C2h] facing/anim flag bits (87 byte_tests)
boss_intro_flag db 0		; [boss_intro_flag] boss intro-side flag (bit-6 from boss data; gates intro_left_loop)

;--------------------------------------------------------------------------
;  Player State / Hitbox Data  [CS:0x00C4 - CS:0x00E8]
;
;  CS:[0C4h] = level/area number (read by game.bin at startup)
;  CS:[0C8h] = level tileset index (written by game.bin at runtime)
;  CS:[0D2h-0E3h] = 9-row ?? 2-byte collision bitmask (left half | right half)
;--------------------------------------------------------------------------

current_area_id	db	80h		; [0C4h] level/area number (init 0x80)
		db	81h		; [0C5h] unknown player state byte
;
; [C6h..C7h]: 16-bit field (analyzer: 3 word_reads, 1 word_add).  Currently
; labelled "reserved" but actually accessed.  Purpose TBD.
heal_pulse_count dw 0		; [0C6h-0C7h] HP heal-pulse counter (16-bit; +8 HP/tick)

player_tileset	db	00h		; [0C8h] tileset index (written at runtime)
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
player_hitbox	db	0C0h, 0C0h	; row 0  ##......  ##......
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
