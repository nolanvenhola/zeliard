
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
;    0x0000-0x007F  Persistent world/scene flags (cavern objects, town state)
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
;    Reads/writes: provides initial values for gold_carried_x65536/lo, player_almas,
;                  player_HP, sword, shield, shield_HP,
;                  shield_max_HP, cur_weapon_idx at game_seg:0x0085-0x009D, plus
;                  player_walk_speed/player_accel and the animation color LUT.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

; MASM/TLINK needs a FAR entry envelope to emit the raw binary.  This is a
; packaging declaration only: zeliad loads these bytes as data and never calls
; this label.  functest/classify.py therefore excludes the whole module.
run_stdply_main		proc	far
start:

;--------------------------------------------------------------------------
;  Persistent Cavern Object State  [CS:0x0000 - CS:0x007F]
;  Saved bitfields for collected map items and opened hidden stashes/doors.
;  Authored 200FIGHT entity records carry a destination pointer at +0Bh and
;  a mask at +0Dh; entity_deactivate ORs that mask here.  On every cavern
;  load, process_map_seg_updates reads these bytes and reapplies the linked
;  object/tile mutations, so consumed objects do not respawn.
;--------------------------------------------------------------------------

cavern_object_state	label	byte
key_map_table	dw	64 dup (0)	; legacy alias; bytes are shared persistent flags

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
starting_position_in_town	dw	001Eh		; [80h-81h] cavern X scroll column (16-bit; init col 30)
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
screen_position	db	0Ah		; [83h] player screen column in town (range 0..0x10)
fight_player_col db	0Ah		; [84h] player screen column in fight (range 0..7)
; Gold is a 24-bit field at [85h..87h]: high byte at 0x85 + little-endian
; low word at 0x86..0x87.  Verified functionally by the harness probe of
; town.bin's add_gold_to_hero (slot 0x600C) and check_gold_sufficient
; (slot 0x600A).  See functest/test_town_dispatch_slot_60{0A,0C}.py.
gold_carried_x65536	db	0		; [85h] gold high byte (24-bit field)
gold_carried_x1	db	0		; [86h] gold low byte (start of low word)
gold_carried_x256	db	0		; [87h] gold low word's high byte
;
; [88h..8Ah]: 24-bit player_bank balance, mirrors player_gold layout.  Used
; by 213BANKP (the bank shop chunk) — `add [89h], ax; adc [88h], dl` is
; the deposit pattern.  Runtime probe (functest/.../test_stdply_hero_bank_X88.py)
; confirmed carry propagation 0xFFFE+5 → hi=1, lo=0x0003.
gold_in_bank_x65536	db	0		; [88h] banked-gold high byte (24-bit)
gold_in_bank_x1	dw	0		; [89h-8Ah] banked-gold low word
;
; player_almas — 16-bit, NOT 8-bit.  Functional probe (fight.bin 0x917C,
; "almas-add"): add AX to word at [8Bh], cap at 0xFFFFh on carry.  See
; functest/test_player_stats_word_layout.py.
player_almas	dw	0		; [8Bh-8Ch] alternate currency (16-bit)
;
; [8Dh..8Fh]: 201SELCT (character-select chunk) names these item_qty_count
; (byte) and item_effect_val (word).  Static analyzer matches.
; 0x8D = HERO LEVEL.  TCRF authoritative: bonus damage tier in DOS version.
hero_level	db	0		; [8Dh] hero level (TCRF: bonus damage tier)
; 0x8E..0x8F = EXPERIENCE points (16-bit LE).  TCRF.
experience	dw	0		; [8Eh-8Fh] experience points (TCRF)
;
; player_HP — 16-bit, NOT 8-bit.  Functional probe (fight.bin 0x7685,
; HP-damage): sub AX from word at [90h], clamp to 0 on underflow.  Probe
; HP3 (HP=257, dmg=1 -> [90]=0,[91]=1) decisively confirms word storage.
; The manual's "max HP = 80" reflects gameplay balance; the storage is
; 16-bit so designers had headroom for buffs / boss multipliers.
player_HP		dw	0050h		; [90h-91h] current HP (16-bit; init=80)
sword	db	1		; [92h] equipped weapon idx (1-based; init 1 = SWORD_TRAINING)
shield	db	0		; [93h] shield tier (1-based; init 0 = no shield)
;
; shield_HP (16-bit word) — current shield HP.  200FIGHT
; apply_combat_damage_with_absorb (line 3501) subtracts damage scaled
; by shield tier from this word; on underflow, clears both [93h]
; and [94h] = "shield broken".  201SELCT's use_holy_water adds an
; effect-tbl[shield] amount to this word and clamps to shield_max_HP
; — consistent with Holy Water being the shield-repair item.
shield_HP	dw	0		; [94h-95h] current shield HP (16-bit; init=0)
;
; [96h..9Ch]: shield_max_HP (16-bit cap), then player_speed/power, then
; the 3-byte player_abilities table at 9A-9C — 201SELCT draw_abilities
; reads abilities as a unit (`mov si, player_abilities; lodsb x3`).
; Specific ability semantics for each slot are TBD; tracked in AUDIT_TODO.md.
shield_max_HP	dw	0		; [96h-97h] shield max HP cap (16-bit)
; 0x98 = NORMAL key count, 0x99 = LION'S HEAD key count.  TCRF authoritative.
keys_normal	db	0		; [98h] normal key count (TCRF)
keys_lion	db	0		; [99h] Lion's Head Key count (TCRF; opens Tesoro/Final special doors)
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
; 0x9E = SELECTED WEARABLE.  User-confirmed: ID of the shoe-or-cape
; the player has currently equipped (0=none, 1..5 per wear_* enum).
selected_accessory db	0		; [9Eh] currently equipped wearable
stat_X9F	db	0		; [9Fh] VESTIGIAL — per-frame zero-clear, no reader observed
;
; 0xA0 = TEARS OF ESMESANTI count (0..9).  TCRF authoritative.  Each
; main cavern hides one Tear; collecting all is the win condition.
; game.asm's load_music_tracks reads this same byte to drive its 9-track
; loader loop — coincident with Tear count rather than music-specific.
tears_of_esmesanti_count db 0	; [A0h] Tears collected (0..9)
;
; 0xA1..0xA5: WEARABLE acquisition list (4 shoes + 1 cape).  Each byte
; holds the ID of the Nth wearable acquired (0=empty).  ID mapping (user-
; confirmed): 1=Feruza, 2=Pirika, 3=Silkarn, 4=Ruzeria, 5=AsbestosCape.
; Earlier names "magic_flags" / "spell_slot_1..5" were misleading
; (these track wearables, not spells).
accessory_slot_1		db	0		; [A1h] 1st wearable acquired
accessory_slot_2		db	0		; [A2h] 2nd wearable acquired
accessory_slot_3		db	0		; [A3h] 3rd wearable acquired
accessory_slot_4		db	0		; [A4h] 4th wearable acquired
accessory_slot_5		db	0		; [A5h] 5th wearable acquired
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
;  SPELL CHARGES + LIFE max + spell-charge MAXES  [CS:0x00AB - CS:0x00C3]
;
;  Per TCRF authoritative save-format reference: this region holds
;  spell charges (current at AB-B1, max at B4-BA) plus LIFE max at B2-B3.
;  IDA's "spells_espada" / "anim_color_lut" naming was wrong — these
;  bytes ARE the current spell charges.  TCRF's defaults (Espada=0Ch,
;  Saeta=06h, Fuego=08h, Lanzar=04h, Rascar=03h, Agua=04h, Guerra=03h)
;  match the historical "anim_color_lut" values exactly because those
;  values WERE the charge defaults (the LUT interpretation was
;  speculation that happened to use the same byte values).
;--------------------------------------------------------------------------

spell_charge_espada	db	0Ch		; [ABh] Espada current charges (default 12)
spell_charge_saeta	db	06h		; [ACh] Saeta current charges  (default 6)
spell_charge_fuego	db	08h		; [ADh] Fuego current charges  (default 8)
spell_charge_lanzar	db	04h		; [AEh] Lanzar current charges (default 4)
spell_charge_rascar	db	03h		; [AFh] Rascar current charges (default 3)
spell_charge_agua	db	04h		; [B0h] Agua current charges   (default 4)
spell_charge_guerra	db	03h		; [B1h] Guerra current charges (default 3)

;
; 0xB2..0xB3 = LIFE max (16-bit; init=80).  TCRF.
		db	50h		; [B2h] LIFE max low byte (80 = manual cap)
		db	00h		; [B3h] LIFE max high byte
;
; 0xB4..0xBA = MAX spell charges (TCRF; matches default current charges).
spell_charge_max_espada db	0Ch	; [B4h] Espada max charges
spell_charge_max_saeta  db	06h	; [B5h] Saeta max
spell_charge_max_fuego  db	08h	; [B6h] Fuego max
spell_charge_max_lanzar db	04h	; [B7h] Lanzar max
spell_charge_max_rascar db	03h	; [B8h] Rascar max
spell_charge_max_agua   db	04h	; [B9h] Agua max
spell_charge_max_guerra db	03h	; [BAh] Guerra max
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
facing_direction	db	0		; [C2h] facing/anim flag bits (87 byte_tests)
boss_intro_flag db 0		; [boss_intro_flag] boss intro-side flag (bit-6 from boss data; gates intro_left_loop)

;--------------------------------------------------------------------------
;  Player State / Hitbox Data  [CS:0x00C4 - CS:0x00E8]
;
;  CS:[0C4h] = level/area number (read by game.bin at startup)
;  CS:[0C8h] = level tileset index (written by game.bin at runtime)
;  CS:[0D2h-0E3h] = 9-row ?? 2-byte collision bitmask (left half | right half)
;--------------------------------------------------------------------------

; 0xC4 = save_sage (per TCRF: 0x80 | town_index, where game was saved).
; 0xC5 = last_sage_visited (Kioku Feather destination; DOS doesn't update on save).
save_sage	db	80h		; [0C4h] save sage (init = Castle / 0x80)
last_sage_visited db	81h		; [0C5h] last sage visited (init = Muralla)
;
; [C6h..C7h]: 16-bit field (analyzer: 3 word_reads, 1 word_add).  Currently
; labelled "reserved" but actually accessed.  Purpose TBD.
heal_pulse_count dw 0		; [0C6h-0C7h] HP heal-pulse counter (16-bit; +8 HP/tick)

				; drives bg+music+sprite+tileset+map loading via 11B/entry chunk-ref table)
current_level_idx	db	00h		; [0C8h] current level/cavern chunk index (0..31
;
;--------------------------------------------------------------------------
;  Shop inventory bitfields  [0x00C9-0x00E3]  (TCRF authoritative).
;
;  These bytes are the per-town shop stock bitfields.  The defaults below
;  match TCRF Notes:Zeliard exactly.  The previous "9-row collision
;  bitmask" + "vestigial word" comments were misinterpretations of the
;  bit pattern; no asm code reads any of these bytes as a hitbox or word.
;
;  Each byte = bitfield: bit set => that item is in stock.  Magic-shop
;  bits per TCRF: +128=Ken'ko +64=Juu-en +32=Elixir +16=Chikara +8=Magia
;  +4=HolyWater +2=SabreOil +1=Kioku.  Sword/shield bits are 6-item
;  versions of the same scheme.
;--------------------------------------------------------------------------

; Magic shop stock per town (TCRF defaults).
magic_shop_inventory_muralla	db	8Ah	; [0C9h] Muralla magic shop default
magic_shop_inventory_satono	db	0A6h	; [0CAh] Satono
magic_shop_inventory_bosque	db	6Bh	; [0CBh] Bosque
magic_shop_inventory_helada	db	75h	; [0CCh] Helada
magic_shop_inventory_tumba	db	42h	; [0CDh] Tumba
magic_shop_inventory_dorado	db	4Ch	; [0CEh] Dorado
magic_shop_inventory_llama	db	4Bh	; [0CFh] Llama
magic_shop_inventory_pureza	db	01h	; [0D0h] Pureza
magic_shop_inventory_esco		db	0FFh	; [0D1h] Esco (full stock)

; Weapon shop sword stock per town (TCRF defaults).
;   Note: the previous `player_hitbox db 0C0h, 0C0h ...` 9-row
;   declaration sat at exactly this offset.  Zero readers — see git log.
weapon_shop_swords_muralla	db	0C0h	; [0D2h] Muralla sword shop default
weapon_shop_swords_satono	db	0C0h	; [0D3h] Satono
weapon_shop_swords_bosque	db	0E0h	; [0D4h] Bosque
weapon_shop_swords_helada	db	0E0h	; [0D5h] Helada
weapon_shop_swords_tumba	db	70h	; [0D6h] Tumba (-16 after Glory-Crest trade)
weapon_shop_swords_dorado	db	38h	; [0D7h] Dorado
weapon_shop_swords_llama	db	38h	; [0D8h] Llama
weapon_shop_swords_pureza	db	0F8h	; [0D9h] Pureza (full minus Enchantment)
weapon_shop_swords_esco		db	0F8h	; [0DAh] Esco

; Weapon shop shield stock per town (TCRF defaults).
weapon_shop_shields_muralla	db	0C0h	; [0DBh] Muralla shield shop default
weapon_shop_shields_satono	db	0E0h	; [0DCh] Satono
weapon_shop_shields_bosque	db	0E0h	; [0DDh] Bosque
weapon_shop_shields_helada	db	70h	; [0DEh] Helada
weapon_shop_shields_tumba	db	30h	; [0DFh] Tumba
weapon_shop_shields_dorado	db	38h	; [0E0h] Dorado
weapon_shop_shields_llama	db	1Ch	; [0E1h] Llama
weapon_shop_shields_pureza	db	1Ch	; [0E2h] Pureza
weapon_shop_shields_esco	db	0FCh	; [0E3h] Esco (full)

; [E4h..E8h]: previously labelled "end padding" but the analyzer found these
; bytes are heavily used.  0xE7 is the single most-accessed byte in the whole
; stdply chunk (38 reads + 7 inc + 7 cmp + 5 or + 4 and; called "Unknown
; state var" in game.asm).  0xE6 and 0xE8 are flag bytes (test FFh).
sabre_oil_power db	0	; [E4h] temporary Sabre Oil sword-power stack
sages_spoken_bitmap	db	0		; [E5h] sages spoken-with bitmap (TCRF: +128=Muralla..+1=Pureza)
scene_trans_request db 0	; [scene_trans_request] scene-transition request (polled in main_loop_body)
gvar_pose_idx	db	0		; [E7h] player pose state (bit7=mode flag, low7=pose idx)
init_complete_flag db 0		; [init_complete_flag] post-init steady-state (cleared on area_load_flag)

run_stdply_main		endp

seg_a		ends

		end	start
