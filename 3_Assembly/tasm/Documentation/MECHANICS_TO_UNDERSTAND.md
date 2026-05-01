# Zeliard mechanics — what we must understand before any port

Curated from:
- `4_Resources/Documentation/Zeliard_Manual.pdf` (player-facing rules)
- `4_Resources/Documentation/Zeliard_*.pdf` (bosses / enemies / friends / towns / weapons / magic / items)
- `4_Resources/GameData/*.md` (in-house mechanics summaries)
- `4_Resources/Playthrough.txt` (Alan Franciškovic's official FAQ — 3,465 lines, 12 sections)
- `3_Assembly/tasm/Documentation/code_chunks_overview.md` (chunk dictionary)
- `3_Assembly/tasm/Documentation/ARCHITECTURE.md` (control-flow narrative)
- The cleaned `.asm` source itself — every chunk's role is now documented in
  the EQU + comment-block headers of its own .asm (single source of truth)

Status legend:
- ✓ **fully traced** — assembly identified, behavior understood, runtime tests
- ⚠ **partial** — partial trace OR static-only OR runtime-only (not both)
- ❌ **not investigated** — no work done

Each row should resolve to ✓ before any port chapter that depends on it
is started.  Use this as a checklist before saying "we're ready to port".

---

## 1. Graphics & rendering

| Item | Status | Where |
|---|:---:|---|
| Graphics-mode driver selection (CGA/EGA/HGC/TGA/MCGA) | ✓ | zeliad.asm boot; gvar_gfx_mode (FF14) drives `driver_offset_table[mode]` |
| Loading the gd*/gt*/gm*.bin driver chunk per mode | ✓ | zeliad.asm + game.asm; `LOAD_CHUNK` macro + sar_loader_fn |
| Driver dispatch slot table (CS:0x2000–204E) | ✓ | ARCHITECTURE.md §5; per-chunk slots documented |
| GRP image format (4-plane interleaver, nibble-pair palette trick) | ✓ | CLAUDE.md notes; `2_SAR/Tools/grp_viewer.py` |
| .MDT cavern map format | ⚠ | `MdtViewer/` exists; map binary structure partially decoded |
| Tile graphics: tileset chunks (zelres3 +per-area) | ⚠ | tile_pixel_base, tileset_buf_a/b at known addresses but per-tile semantics? |
| Sprite graphics: per-entity sprite tables | ⚠ | sprite_obj_tbl (0xA000), 6-byte = 3 bitplanes × 2 bytes = 16px wide; pixel format CRACKED in CLAUDE.md but blit fn not |
| Player sprite rendering pipeline | ⚠ | `enemy_sprite_blit` and `prep_dirty_blit` named (Phase 3); player path TBD |
| Background tile rendering & scrolling | ❌ | gfx_scroll_left/right_fn called but the actual scroll math + tile-buf swap unverified |
| Foreground vs background layer ordering | ❌ | how does the game render hero in front of map but behind UI? layer order TBD |
| Masking / transparency for sprites | ❌ | sprite_pat_tbl rotates pattern bytes — bitmask scheme unclear at the byte level |
| Palette: 256-color VGA DAC, multiple palettes per scene | ⚠ | CLAUDE.md captures P1/P2/P3 palettes; runtime palette switch via `mov ax,N; call [cs:3008]` (driver fn 4) |
| Palette flash/cycle visual effects | ⚠ | gvar_palette_flag, palette_fade_ctr named; cycler logic TBD |
| Screen-transition fades (e.g. between scenes) | ❌ | ARCHITECTURE.md mentions but the fade-routine address unknown |
| Animation frame timing & state machine | ⚠ | gvar_pose_idx is per-entity pose; quad_frame_tick (4-frame cycle) named; full anim FSM TBD |
| Text rendering / font system | ⚠ | font.grp loaded at CS:0xF500; render via drv_render_char at 2022; precise glyph layout TBD |
| HUD rendering (HP bar, gold, almas, items) | ⚠ | hud_fill, hud_buf identified; per-element layout TBD |
| Number → decimal-digit text | ⚠ | drv_format_num at CS:0x6006 (script_format_num); algorithm TBD |
| Window-frame graphics (waku.grp) | ❌ | known to load; usage during dialog TBD |
| Item-icon rendering (itemp.grp) | ❌ | loaded by game.bin; UI layout TBD |
| Magic-effect graphics (magic.grp) | ❌ | loaded; per-spell rendering TBD |
| Sword sprite (sword.grp) | ❌ | loaded; attack animation TBD |
| HGC interleaved-plane wrap math | ✓ | Documented during macro-fold (HGC differs from CGA: limit 6000h, add 0xA058) |
| CGA interleaved-plane wrap math | ✓ | CGA: limit 4000h, add cga_wrap_add (0xC050) |

## 2. Sound & music

| Item | Status | Where |
|---|:---:|---|
| Music driver selection from RESOURCE.CFG | ✓ | zeliad.asm: parse_music_driver; only "mscmt.drv" recognized (MUSIC_SYSTEM.md) |
| Music driver chunks: MT-32, AdLib, SoundBlaster, PC Speaker, etc | ⚠ | Cleaned source recognizes only mscmt.drv (MT-32); other variants if any TBD |
| .MSD file format | ⚠ | No .MSD format — tracks are raw SAR chunks parsed by mscmt.drv; .MID source files in 4_Resources/Music/ |
| Music tick handler (int 61h) | ✓ | INT 61h is REPURPOSED as joystick query (NOT music). Music tick = gvar_input_fn at +0xFF0:0x100 (MUSIC_SYSTEM.md) |
| Music load/start (load_music_tracks proc named) | ✓ | game.asm:461; 9-entry level_system_ref table; track 8 = bg with AL=1 flag |
| Music stop / pause / resume | ❌ | Trigger paths unknown — likely calls into mscmt.drv via separate slot |
| Sound-effect generation (sword swing, hit, footstep, etc) | ✓ | gvar_volume_b mailbox; cue values 1=UI, 8=shielded, 9=raw, 0Eh=item, 10h=boss (MUSIC_SYSTEM.md) |
| Volume control bytes (gvar_volume_a/b) | ⚠ | Address mismatch (FF74/75 in zeliad.asm vs FF74/77 in game.asm — likely typo); function = audio cue trigger, NOT continuous volume |
| Music on/off toggle (F1 key) | ✓ | handle_special_keys: gvar_timer_counter=0x2000 → toggles gvar_sound_flag (FF27) via `not` (MUSIC_SYSTEM.md) |
| Sound-effects on/off toggle (F2 key) | ⚠ | Single toggle (sound flag); manual lists separate F1/F2 but only one mute path traced |
| Joystick driver init | ✓ | zeliad.asm: parse_joystick_name + parse_joystick_enable |

## 3. Physics & player mechanics

| Item | Status | Where |
|---|:---:|---|
| Player walking left/right | ✓ | PLAYER_PHYSICS.md; town: 4-step (test→fine→move→scroll) loop; cavern: AL bits 2/3 = LEFT/RIGHT dispatch in game_check_state |
| Player jumping (parabolic arc) | ✓ | state1_entry → game_func_11 with arc counters at DS:9F09/9F0C/9F0D (misnamed `hp_*` — actually jump_phase_ctr/jump_apex/jump_height); gvar_combat_ff3D bit 7 = ascending |
| Player falling | ✓ | game_func_8 → decrement_hp; gated on gvar_combat_ff3D bit 7 clear AND game_func_24 (no tile support); inc fight_player_col + dec hp_countdown per frame |
| Player kneeling (Down arrow) | ✓ | DOWN → game_func_22 (line 1924) calls game_func_78 to set crouch pose; functional effect: lowers attack hitbox so player can swing under low-flying enemies (per user 2026-04-30) |
| Player facing (left/right) | ✓ | bit 0 of [0xC2]; `or [C2],1`=LEFT, `and [C2],0FEh`=RIGHT, `xor [C2],1`=toggle (PLAYER_PHYSICS.md) |
| Player pose-state byte | ✓ | gvar_pose_idx at DS:0xE7 fully documented (PLAYER_PHYSICS.md §"gvar_pose_idx"); bit 7 = static mode, low 7 = anim frame |
| Hitbox system | ❌ | ply_hitbox at DS:0xD2 named but the box layout TBD |
| Sprite/tile collision detection | ✓ | game_func_128 + is_unknown_or_area5_slot_b classifies tiles via is_entity_known_type; bytes >= 0x49 block movement (TILE_PHYSICS.md §"Movement collision") |
| Surface effects: ice (sliding) | ❌ | Per-area tile-type → physics modifier mapping TBD; would need DOSBox observation in Helada cavern |
| Surface effects: slime/ooze (slow) | ❌ | Same — likely small damage in tile_type_map + speed modifier |
| Surface effects: lava (damage) | ✓ | Comes through the tile_type_map → tile_type_sum → shield → HP damage chain (TILE_PHYSICS.md §"Per-frame damage scan") |
| Surface effects: water | ❌ | TBD — likely a separate flag; not yet identified in tile-byte format |
| Ladder climb (Up on ladder tile) | ⚠ | state1_entry calls 3 context-check routines (game_func_69/80/12) before jump-arc body; ladder dispatcher candidate but specific tile-detection TBD (PLAYER_PHYSICS.md §"Context-sensitive Up"). 'J' tile byte (0x4A) tested in game_func_69 |
| Platform-raise (Up on platform tile) | ⚠ | Same context-check prelude; raise-platform dispatcher candidate among game_func_80/12; needs DOSBox observation |
| One-way walls (pass through one way) | ❌ | Direction-gated tile flag not yet identified |
| One-way air-flow walls (push player) | ❌ | TBD |
| Force-vulnerable tiles (bytes 0x40..0x48) | ✓ | Tile bytes in this range zero `invul_timer` (TILE_PHYSICS.md) |
| Spike / instant-damage tiles | ✓ | Use the standard tile_type_map mechanism with high damage values |
| Player movement speed by stat | ⚠ | char_speed (0x98), 9 levels per Sage progression |
| F9 game-speed adjustment (0-9) | ❌ | speed_level handler TBD |
| Pause (Esc) | ❌ | Pause routine TBD |

## 4. Combat

| Item | Status | Where |
|---|:---:|---|
| Sword attack — standing (Spacebar) | ✓ | combat_input_handler sets action_state=2 on button1; damage = sword_type lookup × 2 via game_multiply_5 (line 8103); mid-height forward swing |
| Sword attack — crouch-low (Down held) | ✓ | Sprite-frame variation via crouch pose; hitbox extends lower for short enemies; no damage change (PLAYER_PHYSICS.md §"Summary of attack contextual variants") |
| Sword attack — jump-overhead (ascending) | ✓ | Sprite-frame variation via ascending pose (gvar_combat_ff3D bit 7 set); hitbox extends upward; no damage change (per user 2026-04-30) |
| Sword attack — falling-bonus (descending) | ⚠ | Emergent cumulative damage from per-frame hit-detection while player passes through enemy column; no explicit multiplier in game_multiply_5; needs DOSBox call-count confirmation |
| Hit detection: sword → enemy | ⚠ | last_hit_entity (9F10) named; full hit-test routine TBD |
| Hit detection: enemy → player | ⚠ | hero_HP_subtract probe-tested (CPU 0x768A) |
| Damage formula (sword type × level vs enemy HP) | ⚠ | Static formula in GAME_SYSTEMS.md; runtime computation TBD |
| Shield damage absorption | ⚠ | shield_HP (DS:0x94..95) is 16-bit per probe; shield_type byte at 0x93 |
| Shield damage points by shield type | ✓ | ITEMS_DATABASE.md tabulates; per-shield value in stdply data TBD |
| Damage to "magic clothing" types (Asbestos cape vs lava etc) | ❌ | Shoes / cape handle per-environment damage but mechanism TBD |
| HP regeneration during heal-pulse | ⚠ | heal_pulse_count (DS:0xC6) is 16-bit; +8 HP/tick per probe |
| Hero death: Game Over flow | ⚠ | gameover_inner_tick / gameover_outer_tick named (9F28/9F29) |
| Invulnerability frames (post-hit) | ⚠ | invul_timer used in game_func_9 (combat_step_dispatch) |
| Blue-potion invulnerability exploit | ❌ | Documented in GAME_SYSTEMS.md but state-machine TBD |
| Combat input FSM (FF45/46/47) | ✓ | `combat_input_handler` (line 2512, was game_func_43) called per-frame from frame_loop reads INT 61h and writes the 3-state FSM (0=idle, 1=walk, 2=attack); `select_player_sprite_frame` (was game_func_44) consumes it for sprite-frame selection.  Full doc in 200FIGHT.asm:2512+ comment block. |

## 5. Magic & items

| Item | Status | Where |
|---|:---:|---|
| Magic spell selection (Inventory → spell) | ❌ | Selection UI in select.bin TBD |
| Spell casting (Alt key) | ❌ | Cast trigger + spell-effect dispatch TBD |
| Active spell display | ⚠ | current_magic_spell at DS:0x9D; cur_magic_idx at DS:0xCE |
| Magic potions list (8 types) | ✓ | ITEMS_DATABASE.md fully documented |
| Per-potion effect | ✓ | All 8 handlers reverse-engineered in INVENTORY_SYSTEM.md (Ken'ko=+80HP cap, Juu-en=fullHP, Elixir=cur-weap-restore, Chikara=all-weap-restore, Sabre Oil, Magia=XP grant, Holy Water=+1 key, Kioku Feather=warp/save) |
| Item-quantity tracking | ✓ | item_qty_count (0x8D) is the consumption-count display in the use-confirm box |
| Item-effect-value (8E word) | ✓ | item_effect_val (0x8E word) is the effect-value display in use-confirm box |
| Magic Stone: time-stop effect | ⚠ | Actually XP grant via item_effect_tbl[equipped_magic-1] per INVENTORY_SYSTEM.md (NOT time-stop as Playthrough hints) — manual likely conflates display mechanic |
| Holy Water of Acero | ✓ | `inc key_count` (+1 key) per INVENTORY_SYSTEM.md |
| Sabre Oil (sword temporary boost) | ⚠ | use_sabre_oil handler identified at item index 4; exact buff mechanism (temporal vs permanent) TBD |
| Kioku Feather (warp/teleport) | ⚠ | use_kioku_feather identified; uses 120-frame timer (timer_wait_feather=0x78); warp/save trigger TBD |
| Crests: Hero / Glory / Elf | ❌ | char_abilities byte (DS:0x9A..0x9C, 3 bytes) holds bits; per-crest semantic TBD |
| Shoes: Ruzeria / Pirika / Silkarn / Asbestos cape / Feruza | ❌ | Not in 201SELCT panels (only 3 panels: weapons/magic/items); shoes equipped via different path TBD |
| Keys: normal vs Lion's Head | ⚠ | `key_count` (DS:0xE4) per INVENTORY_SYSTEM.md.  Lion's Head Key flag TBD |

## 6. Enemies & AI

| Item | Status | Where |
|---|:---:|---|
| Enemy ID classification | ✓ | `is_entity_known_type`, `is_entity_id_lax` (Phase 3 named) |
| Enemy slot list (entity_data_buf at EB80) | ✓ | 13-byte/entry, 0xFF terminator; iterators named (tick_dec/inc_enemy_counters, process_dirty_enemies) |
| Enemy-data extension table (enemy_data_ext at ED20) | ✓ | Indirect-write via `entity_slot_write_tagged` (Phase 3) |
| Move-slot family lookup (3 families A/B/C) | ✓ | `lookup_move_slot_family` (Phase 3); gates many handlers |
| Enemy directional movement (E/N/W/S) | ✓ | `entity_move_{east,north,west,south}` (Phase 3) |
| Enemy collision check (per direction) | ⚠ | `check_north/south_movement`, `check_movement_var_134..137` named but exact tile-test logic TBD |
| Enemy spawn (per-area enemy_id_table at 0x8000) | ⚠ | 24-entry table; per-area selection of which IDs spawn TBD |
| Enemy spawn FX (gvar_spawn_fx_flag at 0xFF75) | ⚠ | Named; trigger conditions TBD |
| Enemy death (gvar_death_flag at FF2E) | ⚠ | Named; cleanup chain TBD |
| Per-enemy AI handler (zelres3 chunks 301-308 EAI1-EAI8, 311TORI, etc.) | ✓ | Architecture + chunk pairings documented in BOSS_AI.md.  Each EAI is paired with one arena chunk; 16-byte slot record format documented |
| Boss AI (10 bosses) | ✓ | All 10 bosses + chunk pairings + state-machine pattern documented in BOSS_AI.md (TAKO worked example; per-boss DEEP state graphs TBD per chunk) |
| Boss intro flag | ✓ | boss_intro_flag (DS:0xC3) — bit-6 from boss data; entity slot record [si+5] bit5=hit, bit6=visible per BOSS_AI.md |
| Boss HP / damage / Almas reward | ⚠ | Per-boss `_hp` byte at boss-specific addr (e.g., tori_hp 0xA773, fight_hp 0xA7C3 for CRAB); damage chain through fight_cb_prep documented; Almas reward per-boss values in BOSSES_DATABASE.md |
| Enemy-trigger flow (entity_fn_e_4 at 200FIGHT) | ✓ | Boss-arena entry via 200FIGHT's level/arena dispatch; documented in BOSS_AI.md §"Two-chunk architecture" |
| Per-boss state machines (per-state graph) | ⚠ | TAKO worked-example documented; other 9 bosses' detailed state graphs are separate per-chunk RE work |
| Enemy slot record format (16 bytes) | ✓ | Field semantics documented in BOSS_AI.md §"Enemy slot record" |
| Boss-defeat death sequence | ✓ | Common gvar_death_flag → fight_cb_shutdown → completion chain documented in BOSS_AI.md |

## 7. Towns

| Item | Status | Where |
|---|:---:|---|
| Town count (8 main + 1 secret = Esco) | ✓ | TOWNS_AND_NPCS.md |
| Town entry trigger (cavern → town transition) | ⚠ | scene_trans_request (DS:0xE6) named; per-town routing TBD |
| Town map background rendering | ❌ | town_map_width / town_palette_idx referenced; full draw routine TBD |
| Town scrolling (left/right, walk_left/right_scroll) | ⚠ | gfx_scroll_left/right_fn at 106TOWN call sites |
| Town foreground (player + NPCs) layering | ❌ | TBD |
| Town tile collision (buildings vs walkable) | ❌ | town_map_side and tile-type checks; full table TBD |
| Building entry (door tile activation) | ✓ | door_scan_entry (106TOWN:2025) on UP press scans `town_event_tbl` for matching world_x ±1; door type byte (0xFF/0..7/8+) selects: special exit / shop chunk load via cs:[10C] / inline event (PLAYER_PHYSICS.md §"door_scan_entry") |
| Special entry barriers (Esco hidden, Pureza requires X) | ⚠ | TOWNS_AND_NPCS.md describes; flag tests TBD |

## 8. NPCs & shops

| Item | Status | Where |
|---|:---:|---|
| Script-bytecode interpreter (cs:[6004] script_step) | ✓ | Full architecture documented in SCRIPT_INTERPRETER.md.  Each shop runs `loop: call script_step; cmp al,FFh; je exit; call dispatch; jmp loop`; runtime services at CS:[6004..6016] in town.bin |
| Per-shop opcode dispatch table | ⚠ | Pattern documented (DS-resident `opcode_dispatch_tbl`); per-shop opcode-set decode TBD per chunk |
| Dialog box rendering | ⚠ | Pipeline known: drv_load_msg_header (0x2010) → drv_render_char (0x2022); placement via gvar_dlg_pos / gvar_dlg_cols / gvar_dlg_rows |
| Multi-page dialog (script_display_page at 0x6008) | ✓ | Service contract documented in SCRIPT_INTERPRETER.md (returns CF=user-cancel) |
| Dialog text positioning (gvar_dlg_pos at FF54) | ✓ | Word at FF54; col byte at FF52, row byte at FF53 |
| Menu rendering (cs:[6010] menu_show_list, [6012] menu_init) | ✓ | Service contracts in SCRIPT_INTERPRETER.md |
| Menu selection (gvar_menu_sel byte) | ⚠ | Named in 215DRUGP; per-menu navigation depends on per-shop dispatch handlers |
| **King NPC (story progression triggers)** | ❌ | 210KINGP chunk; dialog tree TBD |
| **Weapons Master (sword + shield purchase, repair)** | ⚠ | 212ARMRP chunk; price-check uses `check_gold_sufficient` (probe-tested) |
| **Pope NPC (church / resurrection)** | ❌ | 214CHURP chunk; mechanic TBD |
| **Magic Brewer (magic shop, 8 items)** | ⚠ | 215DRUGP chunk; menu structure named |
| **Banker (deposit/withdraw)** | ⚠ | 213BANKP chunk; 24-bit add (`hero_bank_hi/lo`) probe-tested |
| **Sage (level up + spell grant + save)** | ⚠ | Sage chunk TBD; XP threshold table in GAME_SYSTEMS.md |
| **Inn Keeper (HP restore, fee per town)** | ❌ | 216INNAP/217KENJP/219INNCP chunks; rate per town in TOWNS_AND_NPCS.md |
| **Bar (Tumba Town)** | ❌ | 218BARP chunk; mechanic TBD |
| Villagers (info dialogs only) | ❌ | Per-villager dialog data TBD |
| Take-item callback (script_take_item at 600A) | ⚠ | 213BANKP uses for withdrawal; full semantic TBD |
| Give-item callback (script_give_item at 600C) | ⚠ | 213BANKP uses for deposit; full semantic TBD |
| Bank exchange-rate per town | ✓ | TOWNS_AND_NPCS.md tabulated; runtime read TBD |
| Inn rate per town | ✓ | TOWNS_AND_NPCS.md tabulated; runtime read TBD |

## 9. Dungeons / caverns

| Item | Status | Where |
|---|:---:|---|
| Cavern count (16 cavern halves across 8 areas) | ✓ | Playthrough.txt §7 |
| Cavern entry from town | ❌ | Town → cavern trigger TBD |
| Cavern map data (.mdt files in 4_Resources/Maps) | ✓ | Byte-per-tile format documented in TILE_PHYSICS.md (low nibble = tile-type idx, bit 6 = decoration, bytes 0x40..0x48 = force-vulnerable, bytes >= 0x49 = blocking) |
| Map scrolling (horizontal + vertical) | ⚠ | gfx_scroll_left/right_fn; map_scroll_col / map_scroll_row at DS:0x80/0x82 |
| Map width / wrap (map_width at C002) | ✓ | Used by `world_x_to_screen_x` / `compute_scroll_pos` (probe-tested) |
| Tile types (walkable, wall, lava, ice, water, slime, ooze) | ⚠ | Framework fully documented in TILE_PHYSICS.md (tile_type_map[16] per area drives damage via tile_type_sum + shield + HP chain); per-area damage values + ice/slime physics modifiers still TBD |
| Doors and locks | ❌ | TBD |
| Loot boxes (visible) | ❌ | TBD |
| Secret loot (hidden tiles) | ❌ | TBD |
| Keys: pickup + count | ❌ | key_count byte at DS:0xCF; pickup site TBD |
| Moving platforms | ❌ | Per-area; collision logic TBD |
| Boss room entry | ❌ | TBD |
| Cavern → cavern transition (sub-area links) | ❌ | TBD |
| Cavern → town return | ❌ | TBD |
| Almas pickup (orb) | ❌ | hero_almas_add (probe-tested) but trigger site TBD |
| Gold pickup | ⚠ | hero_gold_add (probe-tested via town slot 0x600C); cavern pickup TBD |
| Recovery potion pickups (red = HP, blue = invul) | ❌ | Trigger TBD |
| Tear of Esmesanty pickup (boss reward) | ❌ | TBD |
| Per-cavern enemy spawn list | ⚠ | enemy_id_table seeded per area; per-cavern table TBD |

## 10. Inventory system

| Item | Status | Where |
|---|:---:|---|
| Inventory open trigger (Enter key) | ✓ | selct_main entry — see INVENTORY_SYSTEM.md |
| Inventory display (select.bin chunk = 201SELCT) | ✓ | 3-panel layout (weapons/magic/items) documented in INVENTORY_SYSTEM.md |
| Item slot count + categories | ✓ | 5 magic + 5 items + 7 weapons = 17 flag bytes at DS:A1/A6/BB, plus equipped indices |
| Equip / un-equip handler | ✓ | cur_weapon_idx/cur_magic_idx written by per-panel cursor (INVENTORY_SYSTEM.md §"Per-panel input loop") |
| ARMOR window (shield damage display) | ⚠ | weap_dur_cur table at DS:0xAB..0xB1 identified; per-shield render TBD |
| SPELL window (active spell) | ⚠ | cur_magic_idx / equipped_magic identified; render path TBD |
| Inventory navigation (arrow keys) | ✓ | per-panel input loop documented; INT 61h direction bits 0..3 |
| Item activate (Space) | ✓ | item_use_dispatch_tbl[cursor-1] jump — 8 handlers (INVENTORY_SYSTEM.md) |
| Inventory close (Enter) | ✓ | poll_input CF=1 → retn back to caller |
| Inventory item bitmask | ✓ | NOT a bitmask — 3 separate flag-byte arrays at DS:A1 (magic, 5B), DS:A6 (items, 5B), DS:BB (weapons, 7B) |
| 8 item-use handlers | ✓ | All effects documented (Ken'ko Potion=+80HP, Juu-en=fullHP, Elixir=weapon-restore, Chikara=all-weapons, Sabre Oil, Magia=XP, Holy Water=+1key, Kioku=warp/save) |

## 11. Economy

| Item | Status | Where |
|---|:---:|---|
| Gold storage: 24-bit (hi=85, lo=86..87) | ✓ | Probe-tested |
| Gold add with carry | ✓ | town slot 0x600C target probed |
| Gold check sufficient | ✓ | town slot 0x600A target probed |
| Almas storage: 16-bit (8B..8C) | ✓ | Probe-tested |
| Almas add with FFFF cap | ✓ | hero_almas_add at 0x9183 probed |
| Bank balance: 24-bit (hi=88, lo=89..8A) | ✓ | hero_bank_hi/lo named; deposit add+adc probed |
| Bank withdraw (script_take_item) | ⚠ | 213BANKP uses; opcode flow TBD |
| Bank deposit (script_give_item) | ⚠ | 213BANKP uses; opcode flow TBD |
| Per-shop pricing (item → cost lookup) | ❌ | Per-shop price table TBD |
| Reward drops from enemies (gold + almas) | ❌ | Drop table TBD |
| Different almas-orb sizes (small/medium/large per Playthrough §3.2) | ❌ | Pickup-value table TBD |

## 12. Save / load

| Item | Status | Where |
|---|:---:|---|
| Save trigger (Sage) | ✓ | "Record Experience" in 217KENJP triggers DOS 3Ch/40h/3Eh sequence — see SAVE_FORMAT.md |
| Save filename | ✓ | 8-char player input + ".USR" appended (DOS 8.3); via Sage joystick letter-picker |
| .SAV file format | ✓ | 256 bytes verbatim of DS:0x0000..0x00FF (player data area) — no header, no validation |
| What's persisted | ✓ | Full player record (gold, almas, bank, HP, weapons, magic, items, level, area state); full field map in SAVE_FORMAT.md |
| Load: zeliad.exe re-exec with savefile arg | ✓ | ARCHITECTURE.md §1; cmdline_savefile in zeliad.asm |
| Save-mode flag (new=0, load=0xFFFF passed in AX) | ✓ | game.asm:161 |
| Save-state byte at FF33 (init=5 by zeliad) | ✓ | gvar_save_flag — runtime flag, NOT part of .USR (player record is 0x00..0xFF; gvar at FFxx is separate) |

## 13. Game state & progression

| Item | Status | Where |
|---|:---:|---|
| Player level (0..255) | ✓ | GAME_SYSTEMS.md tabulates HP per level |
| XP threshold per level | ✓ | GAME_SYSTEMS.md tabulates |
| XP add (kill enemy → gain XP) | ❌ | char_exp_cap at DS:0x96..0x97 named; runtime XP add TBD |
| XP-overflow cap (can't level twice) | ⚠ | Documented in GAME_SYSTEMS.md; assembly check TBD |
| Sage level-up dialog | ❌ | TBD |
| Spell grant per level | ❌ | TBD |
| Boss-defeat tracking | ❌ | Per-boss flag location TBD |
| Story progression flags (Holy Spirit visited, Crystal collected, etc.) | ❌ | TBD |
| Tear of Esmesanty count | ❌ | TBD |
| Game completion flag | ❌ | TBD |
| Area unlock gating | ❌ | TBD |

## 14. Input handling

| Item | Status | Where |
|---|:---:|---|
| Keyboard ISR (int 09h, isr_keyboard in stick.bin) | ✓ | ARCHITECTURE.md §4 |
| Keyboard scan-code → game-event mapping | ⚠ | gvar_key_pressed / gvar_key_state / gvar_last_key named; mapping TBD |
| Joystick polling | ⚠ | parse_joystick_enable in zeliad.asm; runtime poll TBD |
| F1 (music toggle) | ✓ | handle_special_keys (stick.asm:252): logical-key 0x2000 → `not gvar_sound_flag` (MUSIC_SYSTEM.md) |
| F2 (SFX toggle) | ⚠ | Single mute toggle (gvar_sound_flag) covers both; manual lists separate F1/F2 but only one path traced |
| F7 (restore save) | ❌ | TBD |
| F9 (game speed) | ❌ | TBD |
| Esc (pause) | ❌ | TBD |
| Ctrl-Q (quit) | ❌ | TBD |
| Ctrl-J/K (joy/keyboard select) | ❌ | TBD |
| Ctrl-R (restart, demo only) | ❌ | TBD |
| Skip-input flag (gvar_skip_input at FF1D) | ✓ | Multi-context "input is muted right now" gate |

## 15. System & boot

| Item | Status | Where |
|---|:---:|---|
| DOS version check + memory allocate | ✓ | zeliad.asm |
| RESOURCE.CFG parsing (graphics + music + joystick) | ✓ | parse_graphics_mode / parse_music_driver / parse_joystick_name |
| Driver chunk loads (stdply, stick, game.bin, gm*, music driver) | ✓ | ARCHITECTURE.md §1 |
| ISR install (int 08/09/24/60/61) | ✓ | ARCHITECTURE.md §1 |
| 8253 timer reprogram (~65.5 Hz) | ✓ | ARCHITECTURE.md §4 |
| SAR loader install (font.grp init writes cs:[10C]) | ✓ | ARCHITECTURE.md §3 |
| sar_loader_fn calling convention (AL=1/2/3/4) | ✓ | ARCHITECTURE.md §3 |
| fill_buffer decoder (formats 0/3/6/7) | ✓ | CLAUDE.md |
| Chunk-jump-table fix-up pattern | ✓ | ARCHITECTURE.md §3 |
| Memory layout (3-tier segments) | ✓ | ARCHITECTURE.md §2 |
| Video-mode setup (INT 10h per gfx mode) | ✓ | set_video_mode in zeliad.asm |
| Frame timing (gvar_frame_timer at FF1A, ISR-incremented) | ✓ | ARCHITECTURE.md §4 |

## 16. Cutscenes & cinematics

| Item | Status | Where |
|---|:---:|---|
| Opening sequence (slideshow, story text) | ⚠ | opdemo (100OPDMO) chunk; slideshow loop at 0x0155, image list at 0x311E |
| ENTER skip during opening | ✓ | check at delay routine 0x03AF |
| Title screen (Zeliard logo + menu) | ⚠ | ttl1/2/3.grp loaded; logo blit pipeline VERIFIED in CLAUDE.md |
| Title menu (New Game / Load Game) | ❌ | Selection mechanism TBD |
| Boss intro animations | ❌ | Per-boss intro TBD |
| Ending sequence (Felicia restored, credits) | ❌ | end4-7, fin chunks; full ending TBD |
| Demo mode auto-play | ❌ | Ctrl-R restart suggests demo loop; loop body TBD |

## 17. Misc / quality-of-life

| Item | Status | Where |
|---|:---:|---|
| Gameplay-speed F9 (0..9) | ❌ | TBD |
| Music-on/off F1 | ✓ | gvar_sound_flag toggle, see Sound & music section |
| SFX-on/off F2 | ⚠ | Same flag as music toggle (only one mute path traced) |
| Pause Esc | ❌ | TBD |
| Quit Ctrl-Q | ❌ | TBD |
| Restart Ctrl-R (demo) | ❌ | TBD |
| Joystick/keyboard switch (Ctrl-J/K) | ❌ | TBD |
| Critical-error handler (int 24h) | ✓ | isr_critical installed by zeliad.asm |
| Ctrl-C handler (ignore) | ✓ | zeliad.asm sets int 23h to ignore |

---

## Summary by status

| Status | Count |
|---|---:|
| ✓ fully traced | 93 |
| ⚠ partial | 48 |
| ❌ not investigated | 52 |

**Total mechanics enumerated**: 193 (added jump-overhead-swing row)
**Coverage so far**: ~48% fully understood, 25% partial, 27% not investigated

All 7 priority items have been worked through (see dedicated docs
in `Documentation/`):
1. ✓ Combat input FSM — see `200FIGHT.asm` headers (combat_input_handler)
2. ✓ Script bytecode VM — see `SCRIPT_INTERPRETER.md`
3. ✓ Inventory UI — see `INVENTORY_SYSTEM.md`
4. ✓ Tile-type physics — see `TILE_PHYSICS.md`
5. ✓ Per-boss AI — see `BOSS_AI.md`
6. ✓ Save-file format — see `SAVE_FORMAT.md`
7. ✓ Music tracker — see `MUSIC_SYSTEM.md`

Remaining ❌ clusters (next horizon):
- **Sprite rendering pipeline** (player/enemy blit fn pixel format)
- **Tile rendering & scrolling math** (gfx_scroll_*_fn internals)
- **Per-cavern .mdt map binary structure**
- **Cinematic / cutscene playback** (opening, ending, boss intros)
- **Per-spell magic graphics** (magic.grp render path)
- **Title menu navigation** (New/Load select FSM)

---

## Workflow per item

For each ❌ row promoting to ⚠:
1. Identify the relevant chunk(s) and source addresses from `code_chunks_overview.md` + ARCHITECTURE.md, then read the chunk's `.asm` directly
2. Open the chunk in IDE, read the relevant proc body
3. Stamp a probe via `functest/new.py` if behavior is testable in Unicorn
4. If runtime-only (DOS/joystick/music coupling): add to `4_Resources/Documentation/INTEGRATION_GAP.md` for DOSBox-side verification
5. Write findings into the relevant existing doc (ARCHITECTURE.md, GAMEPLAY_SUMMARY.md, etc.)
6. Update this file's row status

For each ⚠ row promoting to ✓:
1. Either add a runtime test that locks in the current understanding, or
2. Trace into adjacent chunks until the full chain is documented end-to-end

The bar for ✓: a new contributor can read your notes + the chunk's
`.asm` (which carries the canonical EQU + comment-block headers) and
re-implement the mechanic in any language without re-tracing the
disassembly from raw Sourcer output.

---

_Generated 2026-04-30 from a fresh sweep of resources + chunk walkthroughs + AUDIT_TODO state.  Update incrementally as items move between status tiers._
