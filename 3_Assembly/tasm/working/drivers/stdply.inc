;==========================================================================
;
;  stdply.inc - Player stat record + driver state shared with gm*.bin drivers
;
;  stdply.bin loads at game_entry_seg:0000h. All graphics drivers (gm*.bin)
;  run in the same segment and access these fields via CS-relative addresses.
;
;  CORRECTED 2026-04-26 against IDA decompilation evidence:
;  the 0x85-0x9D block was previously interpreted as driver state
;  (drv_timer_flag, drv_text_src, etc.), but the initial byte values are
;  consistent with the player stat record:
;    0x90 init = 0x50 = 80  -> matches manual's max HP
;    0x92 init = 0x01       -> matches SWORD_TRAINING (starting weapon)
;    0x85/86 init = 0x00,00 -> consistent with starting gold = 0
;  See evidence_check.py / EVIDENCE_REPORT.md for the per-byte verdict.
;
;  Fields at 0x80, 0x83, 0xAB remain INCONCLUSIVE — left as-is until
;  more evidence emerges.
;
;==========================================================================

; Map scroll position  [0x0080-0x0082]  (validated 2026-04-27 by static
; cross-reference: 54 word ptr ds:[80h] refs, 19 byte ptr ds:[82h] refs,
; all in 200FIGHT.asm scroll routines).
map_scroll_col          equ     80h     ; cavern X scroll column (16-bit; 80h..81h)
map_scroll_row          equ     82h     ; cavern Y scroll row (8-bit, paired with gvar_scroll_pos)

; Player screen-column counters  [0x0083-0x0084]  — runtime probe
; (functest/placeholder_id/test_town_player_col_X83.py, 2026-04-29)
; confirmed these are TWO INDEPENDENT counters, not a 16-bit pair:
;   0x83 — town_player_col: walk_left/right inc/dec, range 0..0x10,
;          used in 106TOWN tile-lookup arithmetic (`bl=[83]; bx=(bl+6)*8+tile_ptr`)
;   0x84 — fight_player_col: independent counter in 200FIGHT, range 0..7
; The earlier `player_accel db 0Ah, 0Ah` declaration was a misread.
town_player_col         equ     83h     ; player screen column in town (range 0..0x10)
fight_player_col        equ     84h     ; player screen column in fight (range 0..7)
player_accel               equ     83h     ; alias — deprecated placeholder (was bogus 2-byte declaration)

; Player stat record  [0x0085-0x00AA]  — layout established by functional
; harness probes plus static access-pattern analysis (analyze_stat_layout.py).
; Field types reflect actual byte/word access from the cleaned source.
;
; Gold (24-bit):  high byte at 0x85, little-endian low word at 0x86..0x87.
; Verified by functest/test_town_dispatch_slot_60{0A,0C}.py.
player_gold_hi            equ     85h     ; gold high byte (24-bit)
player_gold_lo            equ     86h     ; gold low byte (start of low word)
player_gold_mid           equ     87h     ; gold low word's high byte
;
; Player bank balance (24-bit, mirrors player_gold layout).  Used by 213BANKP
; (the bank shop chunk) — `add [89h], ax; adc [88h], dl` is the deposit
; pattern; 213BANKP also reads [88h]:[89h] for balance display.  Verified
; by functest/placeholder_id/test_stdply_hero_bank_X88.py (2026-04-29):
; carry propagation 0xFFFE+5 → hi=1, lo=0x0003 confirmed.
player_bank_hi            equ     88h     ; banked-gold high byte (24-bit)
player_bank_lo            equ     89h     ; banked-gold low word (89h..8Ah)
stat_X88_hi             equ     88h     ; alias — deprecated placeholder
stat_X88_lo             equ     89h     ; alias — deprecated placeholder
;
; player_almas (16-bit, NOT 8-bit).  Verified by
; functest/test_player_stats_word_layout.py probe AL3 (almas=257, add=1
; -> [0x8B]=2, [0x8C]=1; high byte preserved).
player_almas              equ     8Bh     ; alt currency low byte (16-bit field)
player_almas_hi           equ     8Ch     ; alt currency high byte
;
; 0x8D / 0x8E come from 201SELCT.asm (character-select chunk) which reads
; them with semantic names: item_qty_count (byte) and item_effect_val
; (word_read at 0x8E).  Static analyzer matches: 0x8D byte-only,
; 0x8E word-only.  Adopted as canonical, placeholders kept as aliases.
item_qty_count          equ     8Dh     ; item quantity counter (canonical, from 201SELCT)
stat_X8D                equ     8Dh     ; alias — deprecated placeholder
item_effect_val         equ     8Eh     ; item effect value (16-bit, 8Eh..8Fh; canonical from 201SELCT)
stat_X8E                equ     8Eh     ; alias — deprecated placeholder
;
; player_HP (16-bit, NOT 8-bit).  Verified by probe HP3 in
; functest/test_player_stats_word_layout.py.  Manual's max-80 is gameplay
; balance; storage is 16-bit.
player_HP                 equ     90h     ; current HP low byte (16-bit field)
player_HP_hi              equ     91h     ; current HP high byte
;
equipped_weapon         equ     92h     ; currently equipped weapon idx (1-based; init 1 = SWORD_TRAINING).
                                        ; Functional evidence in 201SELCT (test/read as weapon index).
                                        ; Was misnamed `sword_type` — sword is just one weapon kind.
; 0x93..0x96: shield_type + shield_HP (16-bit) + shield_max_HP (16-bit).
; Strong functional evidence in 200FIGHT.asm `apply_combat_damage_with_absorb`
; (line 3501): when [93h] is non-zero, damage AX is shifted right by
; ((shield_type+1)/2 + 1) — classic shield-tier absorption — then subtracted
; from word [94h] (shield_HP).  On underflow, both [93h] and [94h] are
; cleared (= "shield broken") and the remainder is dealt to player_HP with
; sound cue 8; otherwise sound cue 9.
;
; 201SELCT.asm `use_magia_stone` (line 775+) reads [93h] as a 1-based
; index into item_effect_tbl, ADDS the looked-up effect to word [94h],
; and clamps to word [96h].  Consistent with the magia stone being a
; shield-repair item: repair amount depends on shield tier, capped at
; shield_max_HP.
;
; (Earlier rename to equipped_magic / player_exp / player_exp_cap was based
;  solely on 201SELCT's icon-draw context, which mistook the shield-repair
;  handler for an XP-gain handler.  200FIGHT's combat-damage logic is the
;  decisive evidence.)
shield_type             equ     93h     ; shield tier (1-based; 0 = no shield equipped)
shield_HP               equ     94h     ; current shield HP, low byte (16-bit field)
shield_HP_hi            equ     95h     ; current shield HP, high byte
;
; 0x96..0x9A: character-stat block named by 201SELCT (character-select
; chunk).  All stat names below match its read patterns; placeholders
; aliased.  static analyzer matches: 0x96 word, 0x98..0x9A all byte/test.
shield_max_HP             equ     96h     ; shield max HP cap (16-bit, 96h..97h; used by 201SELCT use_magia_stone clamp)
stat_X96                equ     96h     ; alias — deprecated placeholder
player_speed              equ     98h     ; character speed stat
stat_X98                equ     98h     ; alias — deprecated placeholder
player_power              equ     99h     ; character power stat
stat_X99                equ     99h     ; alias — deprecated placeholder
; 0x9A..0x9C: 3-byte player abilities table.  201SELCT.asm:1141
; (`draw_abilities`) iterates `mov si, player_abilities; lodsb x3` —
; for each non-zero slot it draws an ability icon at a different row.
; Specific ability semantics (which slot = which gameplay ability) are
; not yet identified; tracked in AUDIT_TODO.md.
player_ability_1        equ     9Ah     ; ability slot 1 (specific ability TBD)
player_abilities        equ     9Ah     ; alias — base of the 3-byte table (used by 201SELCT loop)
stat_X9A                equ     9Ah     ; alias — deprecated placeholder
; 0x9B (slot 2): set to 0xFF by 200FIGHT line 6774 after the 9B2Ch
; scripted trigger (parallel pattern to slot 3 at line 6898 with 9AF3).
; 212ARMRP (armor shop) tests it at line 199 to gate a special trade
; dialog branch when `town_npc_state == 5 && [24h] bit 1 clear`, then
; clears it in reset_after_trade (line 913).  The "trade marker" name
; was a guess based solely on the 212ARMRP usage; the underlying byte
; is the ability_2 flag and "trade gating" is one specific game-design
; consequence of that ability being set.
player_ability_2        equ     9Bh     ; ability slot 2 (set on 9B2Ch trigger; specific ability TBD)
stat_X9B                equ     9Bh     ; alias — deprecated placeholder
; 0x9C (slot 3): set to 0xFF by 200FIGHT entity_fn_e_4 (line 6898) when
; the scripted trigger at game_func_118(DX=9AF3h) succeeds.  Read by
; 201SELCT draw_abilities loop above (the functest_stat_X9C probe missed
; this read because lodsb-via-SI is indirect).  Specific ability TBD.
player_ability_3        equ     9Ch     ; ability slot 3 (set on 9AF3 trigger; specific ability TBD)
stat_X9C                equ     9Ch     ; alias — deprecated placeholder
cur_weapon_idx          equ     9Dh     ; cached selected weapon idx (1-based; init 0).
                                        ; Functional evidence in 201SELCT line 315/320
                                        ; (`mov ds:cur_weapon_idx, al / mov bl, ds:cur_weapon_idx`).
                                        ; Was misnamed `current_magic_spell` (proximity guess).
cur_magic_idx           equ     9Eh     ; currently selected magic index (canonical, from 201SELCT)
stat_X9E                equ     9Eh     ; alias — deprecated placeholder
; 0x9F: VESTIGIAL.  1 write site (106TOWN frame_update prologue zero-
; clears it every frame, alongside gvar_spacebar_state/skip_flag2/cur_magic_idx)
; and 0 reads anywhere.  Runtime probe (functest/.../test_stdply_stat_X9F.py)
; confirms no reader.  Kept declared to preserve byte position.
stat_X9F                equ     9Fh     ; VESTIGIAL — per-frame zero-clear, no reader observed
;
; 0xA0: music track count.  game.asm line 460 (`load_music_tracks` proc)
; comment is explicit: "Reads music track count from [ds:0xA0]".  Reads it
; into CL and iterates through track table at music_track_ref_tbl.
music_track_count       equ     0A0h    ; music track count (canonical, per game.asm comment)
stat_XA0                equ     0A0h    ; alias — deprecated placeholder

; Animation color LUT overlay  [0x00B2, 0x00B4]
; Two bytes inside the 17-entry anim_color_lut do double duty as gameplay
; stat caps (the byte values are intentionally chosen to satisfy both roles).
; player_hp_max and weap_dur_max are also defined locally in gm*.inc files —
; this declaration documents the canonical address.
player_hp_max             equ     0B2h    ; HP ceiling = 80 (overlays LUT frame 8)
weap_dur_max            equ     0B4h    ; weapon durability cap = 12 (overlays frame 10)

; Player flags / hitbox section  [0x00C2-0x00E8]
player_facing           equ     0C2h    ; facing/anim flags (87 byte_tests — most-tested byte)
; 0xC3: boss-intro flag.  200FIGHT line 4068 sets it as `[si+3] & 40h`
; (bit 6 from boss-init data).  Tested in `check_c3` (line 4153):
; `test [C3h], 0FFh; jnz c3_set_loop` — controls which intro animation
; path runs (intro_left_loop vs not).
boss_intro_flag         equ     0C3h    ; boss intro-side flag (canonical, bit-6 from boss data)
stat_XC3                equ     0C3h    ; alias — deprecated placeholder
player_level               equ     0C4h    ; level/area number (matches stdply.asm label)
stat_XC5                equ     0C5h    ; byte field used by 200FIGHT/game.asm
player_tileset             equ     0C8h    ; level tileset index (matches stdply.asm label)
player_hitbox              equ     0D2h    ; base of 9-row collision bitmask (matches stdply.asm label)

; Player state / hitbox tail  [0x00C4-0x00E8]
; Refinements found by analyze_stat_layout.py: 0xC6..0xC7 is a 16-bit field
; (formerly "reserved"), and 0xE4..0xE8 was mis-labelled "end padding" but
; contains the most-accessed byte (0xE7) plus two flag bytes (0xE6, 0xE8).
; 0xC6..0xC7: HP-heal-pulse counter (16-bit).  Used in `call_combat_fx`
; (200FIGHT line 2806): while [C6h] != 0 and [E8h] is clear, decrement
; [C6h] and ADD 8 to player_HP each tick; clamp to player_hp_max (0xB2);
; clear [C6h] when HP reaches max.  Set/incremented at line 6774
; (`add [C6h], ax` after a healing-event computation).  Drives the
; HP-trickle restoration animation when player consumes healing.
heal_pulse_count        equ     0C6h    ; HP heal-pulse counter (canonical, 16-bit; +8 HP/tick)
stat_XC6                equ     0C6h    ; alias — deprecated placeholder
; 0xE4 is the player's KEY COUNT — 201SELCT names it `key_count` (3 sites:
; inc + test + read).  Matches static analyzer's byte-only access pattern.
key_count               equ     0E4h    ; player's collected-key count (canonical, from 201SELCT)
stat_XE4                equ     0E4h    ; alias — deprecated placeholder
; 0xE6: scene-transition request flag.  200FIGHT main_loop_body (line 712)
; polls `test [E6h], 0FFh; jnz scene_transition`; on transition,
; scene_exit_wait (line 723-726) spin-waits for [E6h] to clear.
; Distinct from `scene_trans_flag` (200FIGHT's own state-machine flag);
; [E6h] is the EXTERNAL trigger that an event/interrupt can set.
scene_trans_request     equ     0E6h    ; scene-transition request (canonical)
stat_XE6                equ     0E6h    ; alias — deprecated placeholder
; The byte at 0xE7 is the PLAYER POSE STATE — the most-accessed byte in
; the entire stdply chunk (64 raw [0E7h] memory refs across 8 files).
; Bit 7 (0x80) is a "special-mode" flag; low 7 bits hold the pose index.
; Concrete value patterns:
;   - 200FIGHT writes 0x00 (idle), 0x01 (or-bit-0), 0x7F (max pose),
;     0x80 (special-mode entry, e.g. pop_and_reset at line 1894 on
;     combat exit), 0xFF / various others; 31 sites total.
;   - 106TOWN writes 0 and `or 1` during town entry (12 sites).
;   - All 5 gf*.asm graphics drivers read it and `cmp [0E7h], 80h` to
;     switch sprite rendering mode (4 sites each, 20 total).
;   - game.asm initialises it to 0 in the per-frame state-clear sequence.
;   - 300ROKAD already names this byte `gvar_pose_idx` (12 refs) and
;     uses it as a 0..9 pose index (inc + `and 3` for mod-4 cycle,
;     direct `mov 4/5/8`, `cmp 9` upper bound) — that's the only chunk
;     with a semantic name and it's the closest English description.
; Adopting `gvar_pose_idx` as canonical; placeholder kept as alias.
gvar_pose_idx           equ     0E7h    ; player pose state (canonical, bit7=mode flag, low7=index)
stat_XE7                equ     0E7h    ; alias — deprecated placeholder
; 0xE8: init-complete flag.  Pattern across 29 sites in 106TOWN +
; 200FIGHT: set to 0FFh after first frame's init work; tested at top of
; main_loop bodies to skip the heavy init path (`test [E8h]; jnz
; frame_update`); cleared on area_load_flag set ([49h]).  Acts as
; "post-init steady-state achieved" gate — engine takes the lighter
; per-frame update path while it's set.
init_complete_flag      equ     0E8h    ; post-init steady-state flag (canonical)
stat_XE8                equ     0E8h    ; alias — deprecated placeholder

; Animation color LUT  [0x00AB-0x00C3]  (NOT YET VALIDATED)
; IDA names this 'spells_espada' (Spanish 'espada' = sword/magic spells list).
; Init byte = 0x0C; could be a color value or a spell-list start. Inconclusive.
drv_color_lut           equ     0ABh    ; (purpose inconclusive — IDA "spells_espada")
weap_dur_cur            equ     0ABh    ; alias — per 201SELCT functional evidence: 7-byte
                                        ; weapon-durability table (DS:0ABh..0B1h); used by
                                        ; gm* drivers and 200FIGHT for durability lookups
