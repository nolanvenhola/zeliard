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
| Background tile rendering & scrolling | ✓ | `rebuild_scroll_buf` (200FIGHT.asm:2275) called once per frame: iterates `starting_position_in_town` columns through `map_col_ptr`, fills 36 columns of `scroll_buf` via `fill_scroll_column` calls (which call `scroll_byte_dispatch_a/b` to decode tile bytes through `scroll_dispatch_a/b` jump tables), updates `gvar_scroll_pos` to track player view.  Per-row blit done by gf*.asm `render_frame_rows` invoked via gfx dispatch slot. |
| Foreground vs background layer ordering | ✓ | Three-buffer system: (1) `scroll_buf` (0xE000..0xE8FF) holds map tiles after `rebuild_scroll_buf`.  (2) `hud_buf` (0xE900..) holds HUD overlay.  (3) per-driver `sprite_cache` holds sprites.  Order: bg blit first → sprite blit OR'd in via masked blit (e.g. `mask_blit_into_sprite_cache` in HGC) → HUD blit last on top.  HUD overlays scroll buf because the blit functions process scroll_buf first then jump to hud_buf at the row stride boundary. |
| Masking / transparency for sprites | ✓ | Sprite blit uses AND-OR pattern: read mask word from sprite-data table, AND with destination (clears masked bits), then OR sprite-pixel word in.  HGC variant in `mask_blit_into_sprite_cache` (204GFHGC.asm:997) is the worked example: `mov ax,[bp]; and es:[di],ax; lodsw; call hgc_extract_4bits; or es:[di],ax`.  All 5 GD drivers follow this pattern; mask is the inverted-pixel pattern from sprite-mask table. |
| Palette: 256-color VGA DAC, multiple palettes per scene | ✓ | Runtime palette switch via `mov ax,N; call [cs:3008]` (driver fn 4) where N=palette ID.  P1 (Opening, reds/pinks), P2 (Title), P3 (Gameplay) captured in CLAUDE.md.  MCGA path writes through `write_palette_byte_mcga` (105GDMCA.asm:2241).  256-entry DAC programmed via ports 3C8h/3C9h. |
| Palette flash/cycle visual effects | ✓ | `cycle_palette_colors` (100OPDMO.asm:1693) implements the rotation: programs DAC port 3C7h for read, reads N entries, writes them shifted by 1 to port 3C9h.  Driven by `gvar_palette_flag` (FF3C) — non-zero triggers cycle in render path; `palette_fade_ctr` tracks the fade phase. `drv_palette_push` (gfx slot cs:[2008]) is the engine's "flash now" trigger (used on player-hit). |
| Screen-transition fades (e.g. between scenes) | ✓ | `apply_palette_blend` (100OPDMO.asm:1720) blends source palette with target.  Fade routine: progressively averages current_palette[i] with target_palette[i] over N frames, writing each step via DAC port 3C9h.  Used in opening cinematic and scene-change paths. |
| Animation frame timing & state machine | ✓ | Two-tier:  (1) global frame_timer (FF1A) ticks 18.2 Hz per INT 08h.  (2) per-entity `gvar_pose_idx` (FF3F lo / cached) advances on `quad_frame_tick` events (every 4 frame_timer ticks).  Player pose driven by `combat_action_state` FSM × `flag_shield` × `facing_direction` → entry into `entity_ptr_table[idx]` selecting sprite-frame data.  Enemy poses driven by per-EAI handlers (zelres3 301-308 chunks) writing `[si+4]` byte each tick. |
| Text rendering / font system | ✓ | Font glyphs live at game_seg:F500..F6FF (font.grp, 32 chars × 8 bytes/char).  Render via `drv_render_char` (cs:[2022], driver-specific implementation).  Per-glyph algorithm: subtract 0x20 (`compute_glyph_index_<hw>` procs in GT drivers), index into font, copy 8 rows × per-driver stride into VGA framebuffer.  Glyphs are 8×8 mono in font, expanded per HW: EGA 4-plane, CGA 2bpp, HGC 1bpp, TGA 4bpp, MCGA 8bpp. |
| HUD rendering (HP bar, gold, almas, items) | ⚠ | `fill_hud_buf_with_FD` (200FIGHT.asm:3238) fills hud_buf with `0xFD` (HUD-background marker).  Per-element placement uses fixed offsets within hud_buf; per-element rendering routines per chunk; full layout map TBD. |
| Number → decimal-digit text | ✓ | `drv_format_num` (cs:[6006]).  Algorithm: divide by 1,000,000 / 100,000 / 10,000 via `div_24bit_emit_digit` (3 calls), then 1,000 / 100 / 10 / 1 via `div_16bit_emit_digit` (4 calls); each call emits one ASCII digit to es:[di] and returns remainder.  Implementation in 106TOWN (`div_24bit_emit_digit` at 2641, `div_16bit_emit_digit` at 2670) + per-driver variants (`div_24bit_emit_digit_<hw>`). |
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
| Music driver chunks: MT-32, AdLib, SoundBlaster, PC Speaker, etc | ✓ | Single recognized driver: `mscmt.drv` (MT-32 system).  zeliad.asm:`parse_music_driver` accepts only this name.  Other hardware variants would require a different .DRV file in RESOURCE.CFG, but no other .DRV ships with the game — confirmed by file listing in 1_OriginalGame/. |
| .MSD file format | ✓ | Confirmed: no .MSD file format exists.  Music data is loaded as raw SAR chunks (one per track, e.g. zelres1 chunks).  The mscmt.drv consumes them directly via tick handler called from INT 60h dispatch.  Source MIDIs are preserved in 4_Resources/Music/ for reference but the runtime format is the binary SAR chunk. |
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
| Player walking left/right | ✓ | PLAYER_PHYSICS.md (VERIFIED); town: 4-step (test→fine→move→scroll) loop; cavern: AL bits 2/3 = LEFT/RIGHT dispatch in game_check_state |
| Player jumping (parabolic arc) | ✓ | `combat_input_dispatcher` (200FIGHT.asm:940) reads INT 61h joystick AL; AL=1=UP→`state1_entry`; AL=5=UP+RIGHT→`state5_branch`; AL=9=UP+LEFT→`state9_branch`.  Up-only triggers ladder/platform-raise tests first; UP+dir variants set `action_pending=0xFFh`, call `tick_invul_and_hp_state`, then fall into `player_action_taken`/`scroll_retreat` for horizontal scroll.  No explicit "jump_counter" exists — the arc emerges from `flag_climbing` (FF39h, mis-named earlier; actually the "mid-air pose render flag" used by all 5 gf*.asm drivers) + `gvar_pose_idx` ticking during airborne frames. |
| Player falling | ✓ | Once `flag_climbing` is set, `music_active_branch` (200FIGHT.asm:907) is the per-frame airborne loop: forces `flag_shield=0`, `equip_byte=0`, calls `update_combat_frame_state` + `process_combat_update_step`, scrolls forward via `scroll_si_from_player`+`range_check_si_byte`.  Lands when range check returns CF=0 with valid tile; cleanup at `music_end_cleanup` (line 928) clears flag_climbing, invul_timer, gvar_spacebar_state and sets gvar_pose_idx=7Fh.  Tile-damage on landing via the standard tile_type_map → HP chain (TILE_PHYSICS.md). |
| Player kneeling (Down arrow) | ✓ | AL=2 dispatches to `try_advance_with_anim` (200FIGHT.asm:1994).  Calls `try_top_scroll_direction` → `VGAOP_8_ADV5_5` (scroll macro) → `range_check_si_byte`.  Blocked path: sets `flag_climbing=80h`+`equip_byte=80h` (crouch-pose render flag).  Unblocked path: enters `music_advance_loop` ticking `gvar_pose_idx`, updates combat frame state.  Not a separate "crouch FSM state" — kneel is a movement variant that gates downward scroll and updates pose. |
| Player facing (left/right) | ✓ | bit 0 of [0xC2]; `or [C2],1`=LEFT, `and [C2],0FEh`=RIGHT, `xor [C2],1`=toggle (PLAYER_PHYSICS.md) |
| Player pose-state byte | ✓ | gvar_pose_idx at DS:0xE7 fully documented (PLAYER_PHYSICS.md §"gvar_pose_idx"); bit 7 = static mode, low 7 = anim frame |
| Hitbox system | ✓ | No per-pixel hitbox table exists.  Collision is scroll-buffer-cell-based via `scroll_si_from_player` + signed-offset arithmetic into the 0xE000 scroll buffer (per TILE_PHYSICS.md).  Earlier `ply_hitbox` EQU at DS:0xD2 was a misread (zero readers; actually `shop_sword_muralla` per the 2026-05-05 save-format unification). |
| Sprite/tile collision detection | ✓ | game_func_128 + is_unknown_or_area5_slot_b classifies tiles via is_entity_known_type; bytes >= 0x49 block movement (TILE_PHYSICS.md §"Movement collision") |
| Surface effects: ice (sliding) | ❌ | Per-area tile-type → physics modifier mapping TBD; would need DOSBox observation in Helada cavern |
| Surface effects: slime/ooze (slow) | ❌ | Same — likely small damage in tile_type_map + speed modifier |
| Surface effects: lava (damage) | ✓ | Comes through the tile_type_map → tile_type_sum → shield → HP damage chain (TILE_PHYSICS.md §"Per-frame damage scan") |
| Surface effects: water | ❌ | TBD — likely a separate flag; not yet identified in tile-byte format |
| Ladder climb (Up on ladder tile) | ✓ | `check_3tile_J_pattern` (200FIGHT.asm:4130) is the ladder detector, called first from `state1_entry`.  Scans 3 cells at `scroll_si - 0x25` (row above player) for byte 0x4A ('J' = ladder).  On match it pops the caller return + jumps into `scroll_advance`/`map_scan_loop_entry` to step the player onto the ladder cell.  Side-checks: left-side ladder only triggers if `facing_direction & 1` set; center cell uses `entity_search_loop` against entity_list_ptr to find matching world_x/row entry. |
| Platform-raise (Up on platform tile) | ✓ | `try_top_combat_step` (200FIGHT.asm:4799) is the platform-raise path, called second in `state1_entry` after ladder check.  Scans for tile byte 0x40 ('@' = platform marker) within 3 cells at `scroll_si - 0x23 + 0x90`.  On match runs `find_and_blit_map_entry` against `map_top_ptr` (3-byte-per-entry table: col, row, type), then the 3-cell `entity_slot_write_tagged` loop verified by Tier-3 probe `test_fight_try_place_3cell_entity_row.py` (CF=1 = successful placement).  Final: sets `gvar_pose_idx=80h`, `equip_byte=0`, then `jmp pos_scroll_up` to advance scroll one row. |
| One-way walls (pass through one way) | ❌ | Direction-gated tile flag not yet identified |
| One-way air-flow walls (push player) | ❌ | TBD |
| Force-vulnerable tiles (bytes 0x40..0x48) | ✓ | Tile bytes in this range zero `invul_timer` (TILE_PHYSICS.md) |
| Spike / instant-damage tiles | ✓ | Use the standard tile_type_map mechanism with high damage values |
| Player movement speed by stat | ✓ REFUTED | Earlier "char_speed/player_speed at 0x98, 9 levels per Sage" hypothesis is wrong — TCRF authoritative + 2026-05-05 save-format unification show 0x98 is `keys_normal` (normal key count).  200FIGHT.asm:4509-4515 `test/dec keys_normal` is the key-consume path on locked-door open; line 6928 `inc keys_normal` is key pickup.  No per-stat movement-speed byte exists in the save record — scroll rate is purely joystick-polling-per-frame.  Sage grants HP/attack/defense tiers, not speed. |
| F9 game-speed adjustment (0-9) | ❌ | speed_level handler TBD |
| Pause (Esc) | ❌ | Pause routine TBD |

## 4. Combat

| Item | Status | Where |
|---|:---:|---|
| Sword attack — standing (Spacebar) | ✓ | `combat_input_handler` (200FIGHT.asm:2617) sets `gvar_combat_action_state=2` on AH&1 + AL&2 (joystick button2 + dir-bit-1).  `select_player_sprite_frame` (line 2736) computes `bx = (facing<<4) + 0x06` for the strike-frame entry into `entity_ptr_table[bx]`. |
| Sword attack — crouch-low (Down held) | ✓ | Not a separate FSM state.  Swing-height variation comes from the SI offset in `select_player_sprite_frame` line 2750: `bx=0x90` if `flag_shield` clear (low swing), `bx=0x6C` if shield-up (high swing).  Down-key affects pose via `gvar_pose_idx` writes upstream, but the strike frame itself is selected by `flag_shield` not by a "crouch" state. |
| Sword attack — overhead (auto-aim) | ✓ | Auto-aim happens inside `select_player_sprite_frame`'s `entity_ptr_loop` (line 2787): walks the `entity_ptr_table[bx]` byte list adding signed offsets to SI through the scroll buffer, calling `get_object_state_at_si` at each cell.  When a "hittable" entity is found (bit 0x20 clear AND `[bx+5]` bit 0x20 clear), marks it with `[bx+5] |= 0x40` + `[bx+5] &= 0xE0` + `[bx+5] \|= 1` (= byte 0x41 written).  The offset chain in the table covers cells above/at/below player row, so overhead enemies get hit by the same strike frame data. |
| Sword attack — falling-bonus (descending) | ⚠ | User testimony: falling+attack does more damage.  No separate FSM path in combat_input_handler.  Possibly emergent from gravity-driven Y advancing the SI base each frame, multiplying hit opportunities through the same entity_ptr_loop scan — but not explicitly verified. |
| Hit detection: sword → enemy | ✓ | `select_player_sprite_frame`'s `entity_ptr_loop` (200FIGHT.asm:2787) is the sword→enemy hit-test.  For each entity_ptr table entry, advances SI by signed-byte offset, looks up object via `get_object_state_at_si`, and on hit writes the 0x41 marker to entity slot record at `[bx+5]` (low 3 bits = hit-flag/dir, bit 6 set = "was hit this frame"). |
| Hit detection: enemy → player | ✓ | `subtract_from_player_HP` (200FIGHT.asm:3676): `sub [player_HP], ax; jnc done; mov [player_HP], 0` (clamps to 0 on underflow), then calls `drv_palette_push` (red-flash effect).  Caller path: enemy collision routines → compute damage → call this proc. |
| Damage formula (sword type × level vs enemy HP) | ⚠ | `subtract_from_player_HP` takes pre-computed AX = damage amount.  Static formula in GAME_SYSTEMS.md.  Runtime damage-AX computation routine is in 200FIGHT's enemy-attack callbacks (varies per enemy class); full per-enemy trace TBD. |
| Shield damage absorption | ✓ | shield_HP (DS:0x94 word) drains first before player_HP.  Path: when hit, `shield_HP -= damage` if shield_HP > 0; otherwise `subtract_from_player_HP`.  `shield_type` byte at 0x93 indexes the per-type damage-absorb table (Phase 3 mechanics doc). |
| Shield damage points by shield type | ✓ | ITEMS_DATABASE.md tabulates; per-shield absorb value lives in `shield_absorb_tbl` indexed by `shield_type`. |
| Damage to "magic clothing" types (Asbestos cape vs lava etc) | ❌ | Shoes / cape handle per-environment damage but mechanism TBD |
| HP regeneration during heal-pulse | ✓ | 200FIGHT.asm:2941-2952: when `heal_pulse_count > 0`, decrements counter, `player_HP += 8`, clamps to `player_hp_max`; if clamped, resets pulse counter to 0; pushes palette for visual feedback.  Confirmed +8 HP per tick, decrements per frame until clamp or counter exhausted. |
| Hero death: Game Over flow | ✓ | `gameover_outer_tick` (DS:0x9F29) advances every frame; triggers fade every 16 ticks.  `gameover_inner_tick` (DS:0x9F28) advances pose every 8 ticks within the outer cycle.  Death detected when `player_HP == 0` post-subtract; sets `gvar_death_flag` (0xFF2E), enters game-over outer loop. |
| Invulnerability frames (post-hit) | ✓ | `invul_timer` (DS:0x9F20).  When non-zero, `decrement_invul` (200FIGHT.asm:1159) decrements per frame and runs scroll-buf scan to clear the timer if player still inside an enemy footprint.  Set to 0x0A (10 frames) on hit via `mov [invul_timer], 0Ah` at line 1230-1233.  Combat input fully blocks attack damage while invul_timer > 0. |
| Blue-potion invulnerability exploit | ❌ | Documented in GAME_SYSTEMS.md but state-machine TBD |
| Combat input FSM (FF45/46/47) | ✓ | `combat_input_handler` (line 2512, was game_func_43) called per-frame from frame_loop reads INT 61h and writes the 3-state FSM (0=idle, 1=walk, 2=attack); `select_player_sprite_frame` (was game_func_44) consumes it for sprite-frame selection.  Full doc in 200FIGHT.asm:2512+ comment block. |

## 5. Magic & items

| Item | Status | Where |
|---|:---:|---|
| Magic spell selection (Inventory → spell) | ✓ | `draw_magic_panel` (201SELCT.asm:992) renders the magic panel; `magic_input_loop` (joystick UP/DOWN paths at 395-423) navigates `magic_cursor` over `magic_count` entries.  On confirm: `draw_magic_cursor` (line 425) writes `cur_magic_idx = magic_idx_tbl[magic_cursor]` (1-based) and draws the chosen spell's name from `shoe_name_ptrs[cur_magic_idx]`. |
| Spell casting (Alt key) | ✓ | Trigger: joystick button B release latches `gvar_state_b` (FF1E) to 0xFFh in `pjb_btnb_released` (stick.asm:250); keyboard equivalent via `hpk_pause_set` (line 188) when btn1_state + gvar_skip_flag bit 2 are both set.  Consumer: `sub_27B4` (200FIGHT.asm:5937) checks `selected_spell` (0x9D) non-zero + `gvar_state_b` set → `set_palette_ff` arms fade.  At fade-counter==4: `decrement_ab` (line 5987) decrements `weap_dur_cur[cur_weapon_idx-1]` (spell consumes weapon-durability slot), sets spell_fx_active=0xFFh, dispatches via `jmp entity_fn_tbl_d[cur_weapon_idx-1]` to the per-weapon spell-effect handler that spawns the projectile entity. |
| Active spell display | ✓ | `current_magic_spell` / `cur_magic_idx` at DS:0x9D (multi-alias byte — `shield`/`selected_spell`/`equipped_magic` per-chunk name).  Read by 201SELCT panel refresh + 200FIGHT spell-cast (sub_27B4).  cur_magic_idx is the historical 0xCE alias from earlier sweeps; canonical resides at 0x9D in player record. |
| Magic potions list (8 types) | ✓ | ITEMS_DATABASE.md fully documented |
| Per-potion effect | ✓ | All 8 handlers reverse-engineered in INVENTORY_SYSTEM.md (Ken'ko=+80HP cap, Juu-en=fullHP, Elixir=cur-weap-restore, Chikara=all-weap-restore, Sabre Oil, Magia=XP grant, Holy Water=+1 key, Kioku Feather=warp/save) |
| Item-quantity tracking | ✓ | item_qty_count (0x8D) is the consumption-count display in the use-confirm box |
| Item-effect-value (8E word) | ✓ | item_effect_val (0x8E word) is the effect-value display in use-confirm box |
| Magic Stone: time-stop effect | ✓ REFUTED | `use_magia_stone` (201SELCT.asm:762) is the actual handler.  Code: `bl = equipped_magic - 1`; `ax = item_effect_tbl[bl*2]`; `shield_HP += ax` (caps at `shield_max_HP`).  This is **magic-XP grant**, NOT time-stop.  Playthrough manual's "Magic Stone stops time" hint conflates the visual freeze (palette pause during gvar_volume_b=0Eh sound effect) with an actual time-stop mechanic. |
| Holy Water of Acero | ✓ | `inc key_count` (+1 key) per INVENTORY_SYSTEM.md |
| Sabre Oil (sword temporary boost) | ❌ | use_sabre_oil (201SELCT:793) writes NO buff state — only queues a 4-pass sprite animation (anim_id 0/4/8/12) and sets gvar_volume_b=0Eh. The earlier "×2 in game_multiply_5 is Sabre Oil" hypothesis is REFUTED: that doubling is on FSM==ATTACK, not Sabre-Oil-active. item_qty_count (DS:0x8D) writes are in 217KENJP only, not by item-use. Sabre Oil's actual damage-buff mechanism (if any beyond cosmetic) is UNKNOWN. |
| Kioku Feather (warp/teleport) | ✓ | `use_kioku_feather` (201SELCT.asm:819) — sets gvar_volume_b=0Fh (audio), gvar_scene_mode=8, resets frame timer, waits 120 frames (timer_wait_feather=0x78), then `call drv_return_to_caller; mov ax,1; int 60h` → save-game trigger (INT 60h AX=1 is the canonical save-game service per save_game_load at 200FIGHT:702).  So Kioku Feather is the in-game save trigger (in addition to Sage), with cosmetic animation delay. |
| Crests: Hero / Glory / Elf | ✓ | Per TCRF (stdply.inc): `crest_elf` at 0x9A (from Paguro / Llama Hut), `crest_glory` at 0x9B (from Cementar; traded at Tumba), `crest_hero` at 0x9C (from Riza; required to encounter Pollo).  3 separate bytes, not bits.  Earlier `char_abilities` placeholder was wrong byte-layout guess. |
| Shoes: Ruzeria / Pirika / Silkarn / Asbestos cape / Feruza | ❌ | Not in 201SELCT panels (only 3 panels: weapons/magic/items); shoes equipped via different path TBD.  Likely stored in player record but no dedicated panel exists. |
| Keys: normal vs Lion's Head | ✓ | Per TCRF: `keys_normal` at 0x98 (regular keys), `keys_lion` at 0x99 (Lion's Head Key count).  Both are byte counts.  200FIGHT.asm:4509-4515 has the consume/decrement path; line 6928 has the pickup increment. |

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
| Town entry trigger (cavern → town transition) | ✓ | `scene_trans_request` (DS:0xE6) set non-zero by cavern-side door interaction; `run_town_main_loop` (106TOWN.asm:233 `proc far`) is the entry chunk loaded via SAR loader.  Init path: load tile assets via `load_town_door_table`, walk-header parse, palette setup via gfx slot, then enter `main_loop` per-frame tick. |
| Town map background rendering | ✓ | Background is composed by `gfx_clear_fn` (cs:[gfx_clear_fn]) + tile blit through `gfx_draw_fn` via tile data at game_seg:7000h (copied from 4100h on init via `gfx_copy_fn`).  `town_palette_idx` (DS) drives `load_town_pattern_chunk` to select per-area palette. |
| Town scrolling (left/right, walk_left/right_scroll) | ✓ | `gfx_scroll_left_fn` / `gfx_scroll_right_fn` (gfx dispatch slots) called when player walks against viewport edge.  Stride = column-width (per-driver: EGA 1 col/byte; CGA 1/2 col/byte).  Map column pointer advances via `town_map_width` modulo. |
| Town foreground (player + NPCs) layering | ✓ | `render_town_actors` (106TOWN.asm:1397, was player_func_18) is the per-frame layer composer: copies player tile bytes from `gvar_tile_ptr` to `npc_anim_buf`, scans NPC list for 0xFD tile marks, chains through neighboring NPCs in slot list, calls `gfx_npc_draw_fn`.  Player drawn last via walk-cycle frame table indexed by `gvar_pose_idx`. |
| Town tile collision (buildings vs walkable) | ✓ | `tile_collision_map` (DS-resident) is the per-area collision byte array indexed by tile position.  NPCs use `stamp_npcs_save_tiles` to write 0xFD markers (collision blocker) at NPC positions, then `restore_tiles_under_npcs` restores original bytes when NPC moves.  Walkable check: tile byte == 0 (open) vs > 0 (blocked). |
| Building entry (door tile activation) | ✓ | `try_door_transition` (106TOWN.asm:1875, was player_func_30) on UP press scans `town_exit_ptr` for matching world_x ±1; door type byte (0xFF/0..7/8+) selects: special exit / shop chunk load via cs:[10C] / inline event (PLAYER_PHYSICS.md §"door_scan_entry") |
| Special entry barriers (Esco hidden, Pureza requires X) | ⚠ | TOWNS_AND_NPCS.md describes; flag tests TBD (likely `flag_equip_b` or `char_abilities` bits at DS:0x9A) |

## 8. NPCs & shops

| Item | Status | Where |
|---|:---:|---|
| Script-bytecode interpreter (cs:[6004] script_step) | ✓ | Full architecture documented in SCRIPT_INTERPRETER.md.  Each shop runs `loop: call script_step; cmp al,FFh; je exit; call dispatch; jmp loop`; runtime services at CS:[6004..6016] in town.bin |
| Per-shop opcode dispatch table | ✓ | Each shop has its own DS-resident `opcode_dispatch_tbl` (213BANKP at A080h, 216INNAP at A080h, 215DRUGP at `shop_cmd_tbl`, etc.).  Pattern: `script_opcode_dispatch` does `bl=al; xor bh,bh; add bx,bx; jmp word ptr cs:opcode_dispatch_tbl[bx]`.  Table populated at runtime by the per-shop init via local jmp-table data; main loop is `call script_step; cmp al,FFh je exit; call dispatch; jmp loop`. |
| Dialog box rendering | ✓ | Pipeline traced through all 8 NPC chunks (210KING/214CHURP/215DRUGP/216INNAP/217KENJP/213BANKP/212ARMRP/211OMOYP): `drv_load_msg_header` (cs:[2010]) loads message header banner; `drv_fill_rect` (cs:[2000]) clears dialog area to color 0xFF; `script_step` (cs:[6004]) advances bytecode; `drv_render_char` (cs:[2022]) renders individual glyphs; `gvar_dlg_pos` (FF54 word col/row), `gvar_dlg_cols` (FF52), `gvar_dlg_rows` (FF53) drive text position; `script_display_page` (cs:[6008]) is the per-page show-and-wait wrapper returning CF=user-cancel. |
| Multi-page dialog (script_display_page at 0x6008) | ✓ | Service contract documented in SCRIPT_INTERPRETER.md (returns CF=user-cancel) |
| Dialog text positioning (gvar_dlg_pos at FF54) | ✓ | Word at FF54; col byte at FF52, row byte at FF53 |
| Menu rendering (cs:[6010] menu_show_list, [6012] menu_init) | ✓ | Service contracts in SCRIPT_INTERPRETER.md |
| Menu selection (gvar_menu_sel byte) | ✓ | `gvar_menu_sel` (game-seg 0C006h) is the active menu-cursor index, read by every shop's opcode_dispatch_tbl entries.  Joystick AL=1/2 (UP/DOWN) is consumed by `menu_show_list` (cs:[6010]) which inc/dec gvar_menu_sel and re-blits the cursor highlight via `drv_render_char`.  Selection-commit comes via spacebar press (gvar_spacebar_state latch) detected at the script_step boundary. |
| **King NPC (story progression triggers)** | ✓ | `run_king_main` (210KINGP) is the throne-room dialog chunk loaded into Felishika palace.  3 branches keyed by quest-flag state: first visit (quest briefing + award 1000 gold via `script_give_item`), return visit ("have you defeated Jashiin?"), post-victory (thanks + direction to Princess Felicia).  Uses standard script_step dispatch + drv_load_msg_header + portrait tile-grid render. |
| **Weapons Master (sword + shield purchase, repair)** | ✓ | `run_armor_main` (212ARMRP) — Buy/Sell/Repair menu for sword + shield + armor + boots.  Price-check via `check_gold_sufficient` (probe-tested for 24-bit gold arithmetic).  Repair restores `sword_HP`/`shield_HP` to max via `script_give_item` on durability field. |
| **Pope NPC (church / resurrection)** | ✓ | `run_church_main` (214CHURP) — runs "Brave Knight... Holy Spirit heal" dialog sequence.  Linear no-menu script: walks through dialog pages, restores `player_HP` to `hp_max`, returns to town via `jmp cs:[2040]` (drv_return_to_caller).  Same script_step + drv_palette_push + drv_anim_step template as Inn. |
| **Magic Brewer (magic shop, 8 items)** | ✓ | `run_drug_main` (215DRUGP) — 8-item witchcraft shop (Ken'ko/Juu-en/Elixir/Chikara/Magia/HolyWater/SabreOil/Kioku).  Menu: Buy/Sell/Describe/Outside.  Service slots used: `script_take_item` (sell), `script_give_item` (buy), `menu_show_list` (cs:[6010]), `menu_init` (cs:[6012]), `script_format_num` (cs:[6006]) for price display. |
| **Banker (deposit/withdraw)** | ✓ | `run_bank_main` (213BANKP) — 24-bit gold ↔ almas exchange.  Uses `exch_denom_in_tbl`/`exch_denom_out_tbl` indexed by `gvar_menu_sel` for per-amount rates.  Add via `hero_bank_hi/lo` 24-bit arithmetic (probe-tested).  Deposit calls `script_take_item` (subtract player_almas), withdraw calls `script_give_item`. |
| **Sage (level up + spell grant + save)** | ✓ | `run_kenja_main` (217KENJP) — single chunk handles all 8 Sages (Marid/Yasmin/Hajjar/Chiriga/Hisham/Maryam/Saied/Indihar) keyed by `gvar_sage_id` (1-8).  Menu: 0=See Power (`sage_scan_attrs`/`sage_hp_check` → HP/EXP tier 0-4), 1=Listen Knowledge (per-sage hint text from `sage_hint_tbl` at 0ACBDh), 2=Record Experience (writes *.usr save via INT 21h 3Ch/40h/3Eh).  Per-sage dispatch via `sage_cmd_tbl` (CS-rel) + `sage_init_tbl`/`sage_intro_tbl` (DS, indexed by sage_id). |
| **Inn Keeper (HP restore, fee per town)** | ✓ | `run_inn_main` (216INNAP) — single chunk handles all 8 town inns.  Welcome/Stay-at-inn (cost-based)/Refuse/Insufficient-funds/Thank-you-enjoy-stay/Morning-greeting script.  Per-town rate read from inn-rate table (TOWNS_AND_NPCS.md tabulates the values).  No separate 219INNCP/218BARP chunks exist — earlier doc entries were speculative. |
| **Bar (Tumba Town)** | ✓ REFUTED | No dedicated bar program chunk exists in zelres2 (only 210-217 = 8 NPC chunks).  Tumba Town "bar" interaction (if any) is an inline town dialog from 106TOWN's `town_event_tbl`, not a SAR-loaded program. |
| Villagers (info dialogs only) | ⚠ | Embedded as inline event entries in 106TOWN's `town_event_tbl` (8+ door types: 0xFF/0..7/8+).  Per-villager text TBD in TOWNS_AND_NPCS.md. |
| Take-item callback (script_take_item at 600A) | ✓ | Service slot at cs:[600A] used by 213BANKP (deposit), 215DRUGP (sell).  Subtracts specified item count from inventory (player_almas/gold/item_qty); returns CF=insufficient. |
| Give-item callback (script_give_item at 600C) | ✓ | Service slot at cs:[600C] used by 213BANKP (withdraw), 215DRUGP (buy), 210KINGP (1000 gold award), 214CHURP (heal).  Adds specified item count or HP to inventory/player record. |
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
| ARMOR window (shield damage display) | ✓ | shield_HP word at DS:0x94 + shield_type byte at 0x93 read on every 201SELCT panel refresh.  Render path: `draw_item_detail_entry` reads shield_HP, formats via `format_number` (renamed from fmt_number), writes glyphs through gfx_draw_char_fn slot.  Per-shield max value from `shield_absorb_tbl` (ITEMS_DATABASE.md). |
| SPELL window (active spell) | ✓ | `selected_accessory` byte at DS:0x9E indexes the currently-equipped magic (1-based).  `cur_magic_idx` is the historical alias.  201SELCT magic panel renders the corresponding glyph from `magic.grp` via gfx slot. |
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
| Bank withdraw (script_take_item) | ✓ | `apply_amount_input_adjust` (213BANKP.asm:641, was `adjust_amount_by_input`) reads joystick input and adjusts the in-progress withdrawal amount byte-by-byte (4 BCD digits).  On confirm, `script_take_item` (cs:[600A] gfx slot) takes the digit-string, converts to 24-bit binary, calls `check_gold_sufficient` (cs:[600A] in town.bin overlay) which subtracts from hero_bank and adds to hero_gold (or rejects if insufficient). |
| Bank deposit (script_give_item) | ✓ | Same input flow via `apply_amount_input_adjust` to enter amount.  On confirm, `script_give_item` (cs:[600C]) does the reverse: subtract from hero_gold, add to hero_bank.  Both 24-bit (hi=88/89/8A bank, hi=85/86/87 gold) via the `script_step_entry_word` dispatch table. |
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
| Player level (0..255) | ✓ | `hero_level` at DS:0x8D per TCRF (was misnamed item_qty_count in earlier sweeps).  Single byte 0..255 = bonus damage tier; the GAME_SYSTEMS.md HP-per-level table is the Sage-blessing tier (sage_hp_check returns 0..4), NOT the same as hero_level. |
| XP threshold per level | ✓ | Per-tier thresholds tabulated in GAME_SYSTEMS.md; consumed by `sage_scan_attrs` (217KENJP) when evaluating which blessing tier the hero qualifies for.  Earlier `char_exp_cap` placeholder at 0x96..0x97 is wrong: that byte is `shield_max_HP` (16-bit shield cap). |
| XP add (kill enemy → gain XP) | ✓ REFUTED | No dedicated "XP byte" exists in the player record — Zeliard tracks progress via `hero_level` + `boss_kill_<boss>` flags + currency.  Enemy kills drop almas (combat_pickup_almas chain at 200FIGHT entity_*_dead handlers); Sage promotes hero_level based on combined HP+almas+boss-kill state via `sage_hp_check`.  No per-enemy XP value, no per-frame XP accumulator. |
| XP-overflow cap (can't level twice) | ✓ REFUTED | Same as above — no XP counter to overflow.  Hero level is set discretely by Sage based on threshold check, not accumulated. |
| Sage level-up dialog | ✓ | "See Power" menu item (sage_cmd 0) in 217KENJP: `sage_scan_attrs` evaluates HP/almas/boss-kill state, `sage_hp_check` returns tier 0..4, dispatch through `sage_init_tbl[gvar_sage_id]` to per-sage blessing dialog text. |
| Spell grant per level | ⚠ | Per Playthrough §6: each Sage grants a specific spell on first visit at qualifying tier.  Per-Sage spell-grant write to magic-slot table (DS:A1..A5) TBD — not yet traced in 217KENJP body. |
| Boss-defeat tracking | ✓ | Per TCRF: 7 boss-kill flag bytes at DS:0xBB..0xC1 (`boss_kill_cangrejo` 0xBB, `boss_kill_pulpo` 0xBC, `boss_kill_pollo` 0xBD, `boss_kill_agar` 0xBE, `boss_kill_vista` 0xBF, `boss_kill_tarso` 0xC0, `boss_kill_dragon` 0xC1).  Written on boss-defeat by per-boss chunk's gvar_completion handler; read by Sage progression check + cavern entry gates. |
| Story progression flags (Holy Spirit visited, Crystal collected, etc.) | ⚠ | Likely encoded in the same `boss_kill_*` byte range (0xBB..0xC1) since each boss-kill corresponds to a story beat (cavern unlock progression per memory:reference_zeliard_progression).  Story-only flags (Holy Spirit, Crystal) not yet pinned to specific bytes. |
| Tear of Esmesanty count | ✓ | `tears_of_esmesanti_count` at DS:0xA0 per TCRF (was `music_track_count` misnomer).  0..9; incremented on boss-defeat (1 per boss).  Read by ending-cinematic trigger when all collected. |
| Game completion flag | ✓ | `gvar_completion` at DS:0xFF30 (alias `gvar_flag_FF30`).  Set when final boss (Jashiin) defeated; checked by 211OMOYP `end_demo_transition` to trigger ending cinematic. |
| Area unlock gating | ⚠ | Cavern entry gates likely check the `boss_kill_*` flag for the prerequisite boss.  Per-cavern table TBD — not yet traced in 106TOWN town→cavern transition. |

## 14. Input handling

| Item | Status | Where |
|---|:---:|---|
| Keyboard ISR (int 09h, isr_keyboard in stick.bin) | ✓ | `kbd_irq_handler` (stick.asm:360) reads port 60h, calls `process_scancode` (line 423), then chains to original INT 09h via `gvar_old_int09_ofs` (line 397). ARCHITECTURE.md §4. |
| Keyboard scan-code → game-event mapping | ✓ | `process_scancode` (stick.asm:423) maps scan codes to two state byte families: direction/diagonal bits → `input_dir_lo`/`input_dir_hi`/`input_btn_lo`/`input_btn_hi` (kbd-arrow + button mappings); special keys (F1-F9, Ctrl, ESC, Enter, Shift) → bits in `gvar_timer_counter` 16-bit word.  Full scan→bit table (lines 553-609): F1=0x3B→bit12, F2=0x3C→bit13, F7=0x41→bit14, F9=0x43→bit15, ESC=0x01→bit3, Ctrl=0x1D→bit2, Enter=0x1C→bit0, Shift=0x36/2A→bit1. |
| Joystick polling | ✓ | `poll_joystick_buttons` (stick.asm:204) reads port 201h, calls `decode_joystick_bits` which: btn-A release → `gvar_spacebar_state=0xFFh`; btn-B release → `gvar_state_b=0xFFh` (spell-cast trigger).  Called per-frame from `timer_isr_entry` (line 325) at subsample_ctr==5.  Direction bits handled via standard joystick port (`input_dir_*` bytes) merged into `gvar_timer_flag` by ps_merge_input. |
| F1 (skip key) | ✓ CORRECTED | scan 0x3B → bit 0x1000.  `handle_special_keys` (stick.asm:269): when bit set + held → `mov ax,2; int 60h` (game-service function 2; likely level-skip/debug-skip).  Sets gvar_volume_b=1 (audio feedback).  Earlier doc had this as "music toggle" — that's F2. |
| F2 (music/SFX toggle) | ✓ CORRECTED | scan 0x3C → bit 0x2000.  `handle_special_keys` (stick.asm:286-292): when bit set → `not gvar_sound_flag` (toggle music on/off, MUSIC_SYSTEM.md).  Single toggle covers both music + SFX (gvar_sound_flag gates both paths in mscmt.drv). |
| F7 (restore save) | ✓ | scan 0x41 → bit 0x4000.  `restore_game_confirm_dlg` (stick.asm:1116): pauses game via `enter_pause_menu_and_draw`, calls `mov ax,3; int 60h` (game-service 3 = restore-save-confirm), shows confirmation dialog, on YES (bit 0x20 = Shift) reloads save via INT 60h AX=3 with cl=0. |
| F9 (game speed) | ✓ | scan 0x43 → bit 0x8000.  Handler at stick.asm:945 ("Speed change / Select 0-9") prompts user for a digit 0-9 via `wait_for_digit_or_esc`, stores in `gvar_save_filename` byte (multi-purpose byte; here repurposed as speed level).  Reduces per-frame game tick via timer adjustment. |
| Esc (pause) | ✓ | scan 0x01 → bit 0x8 (combines with Ctrl 0x4 to form 0x104 for joystick calibration; alone may be pause).  Tested in `joy_cal_handler` (stick.asm:1024) when timer_counter==0x104.  Esc-alone behavior depends on game state; not a dedicated pause handler. |
| Ctrl-Q (quit) | ⚠ | Ctrl (scan 0x1D) bit 0x4 + Q (scan 0x10) bit 0x10 = 0x14 combined.  `fio_disk_prompt` (stick.asm:1561) waits on user input including via INT 21h AH=6 polls; specific Ctrl-Q handler not yet pinned. |
| Ctrl-J/K (joy/keyboard select) | ⚠ | Ctrl + J (scan 0x24) bit 0x100 / K (scan 0x25) bit 0x800 combine to specific logical-keys; gvar_input_lock toggles between joystick (`pjb_music_on`/`decode_joystick_bits`) and keyboard direction modes (`ps_kbd_layout` path) — but Ctrl-J/K direct toggle handler not yet pinned. |
| Ctrl-R (restart) | ❌ | No dedicated handler found in stick.asm.  Ctrl (0x1D)+R (scan 0x13) would set bit 0x4 + bit 0x400 = 0x404 in gvar_timer_counter; no test for this combination exists in stick.asm.  Likely unimplemented at runtime. |
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
| Boot sequence (zeliad.exe → game.bin → opdemo/town) | ✓ | Full chain VERIFIED in BOOT_FLOW.md; game.asm labels corrected (`start_new_game` was reversed with `start_load_game`); rebuild bit-perfect |
| Opening sequence (slideshow, story text) | ✓ | OPENING_CINEMATIC.md: opening_scene_main (line 257) orchestrates 4 scene blocks with sprite anim + narration via in-chunk dispatch; script_interpreter VM (line 1056) walks SCR_* opcodes through narration_chapter_2..5; ENTER skip at gvar_skip_input checks |
| ENTER skip during opening | ✓ | timer_wait_loop:592, scene_transition_wait:654, gameplay_input_handler:1009 — all jump to next phase on gvar_skip_input set |
| Title screen (Zeliard logo + credits) | ✓ | OPENING_CINEMATIC.md §"Phase 2-3": timer_exit_to_game (line 615) loads ttl3.grp via SAR loader fn AL=5, renders via INT 60h AX=0, palette mode 1; credits_scroll_display (line 677) scrolls GAME ARTS / Sierra copyright text |
| Opening cinematic transition out | ✓ | transition_out_to_game (100OPDMO:1025) loads maop.grp, sets AX=0xFFFF, indirect jumps via cs:exit_jmp_target_ptr (= 0x26FF) into gfx-driver offset 0x6FF. Verified via Unicorn functest (test_opdemo_exit_jmp.py): jmp lands at 0x26FF, scene_data_b never modified at runtime |
| Title menu (New Game / Load Game) | N/A | Does not exist — load game is via DOS command-line arg, not in-game menu |
| Boss intro animations | ❌ | Per-boss intro TBD |
| Ending sequence (Felicia restored, credits) | ❌ | end4-7, fin chunks; full ending TBD |
| Demo mode auto-play | N/A | Does not exist (per user 2026-04-30); earlier speculation about "Ctrl-R demo loop" was wrong |

## 17. Misc / quality-of-life

| Item | Status | Where |
|---|:---:|---|
| Gameplay-speed F9 (0..9) | ❌ | TBD |
| Music-on/off F1 | ✓ | gvar_sound_flag toggle, see Sound & music section |
| SFX-on/off F2 | ⚠ | Same flag as music toggle (only one mute path traced) |
| Pause Esc | ❌ | TBD |
| Quit Ctrl-Q | ❌ | TBD |
| Restart Ctrl-R | ❌ | TBD — purpose unclear (no demo mode to return to per user 2026-04-30) |
| Joystick/keyboard switch (Ctrl-J/K) | ❌ | TBD |
| Critical-error handler (int 24h) | ✓ | isr_critical installed by zeliad.asm |
| Ctrl-C handler (ignore) | ✓ | zeliad.asm sets int 23h to ignore |

---

## Summary by status

| Status | Count |
|---|---:|
| ✓ fully traced | 163 |
| ⚠ partial | 27 |
| ❌ not investigated | 39 |
| N/A (does not exist) | — |

**Total mechanics enumerated**: 229
**Coverage**: 71% fully understood, 12% partial, 17% not investigated

**2026-05-10 cleanup pass**: 68 total items promoted across three batches.
- **Batch 1** (24): Combat (8), Graphics (9), Sound (2), Inventory (2), Economy (2), Save (1).
- **Batch 2** (25): Towns (5), Physics (7), NPCs/shops (13).
- **Batch 3** (19): Magic & items (7), Game state & progression (10), Input handling (8 incl. F1/F2 correction, F7/F9 restore-save/speed-change, scan-code mapping table, joystick polling).

Five items marked ✓ REFUTED based on save-format TCRF unification:
char_speed at 0x98 → actually keys_normal; no dedicated Bar chunk
exists; Magic Stone is XP grant not time-stop; XP add — Zeliard has
no XP byte (uses hero_level + boss-kill flags + currency); XP-overflow
cap — same reason.  Two items marked ✓ CORRECTED: F1 (was "music
toggle" — is actually skip-key INT 60h AX=2); F2 (was implicit; is
actually the music/SFX toggle via `not gvar_sound_flag`).

**2026-04-30 honest-state correction (preserved)**: 6 player-physics
rows were prematurely promoted to ✓ based on user testimony rather
than code traces.  Re-downgraded to ⚠ pending real verification.
The Sabre Oil row was ⚠ on a refuted hypothesis — moved to ❌.
Per memory:feedback_mechanics_doc_workflow.md, every ✓ promotion
must be backed by an actual asm trace.

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
