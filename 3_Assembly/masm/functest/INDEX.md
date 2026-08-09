## Functional-test index

Catalog of harness-driven tests.  Counterpart to `working/AUDIT_TODO.md`
(static-audit todos) — this file tracks what has been **functionally
verified at runtime** via the Unicorn harness in `harness.py`.

Each test file is a self-contained probe: setup state → call function →
observe byte-level mutations → derive (or refute) a label.  No SAR
rebuilds; no source edits.  Verdicts here can feed back into AUDIT_TODO
as evidence for follow-up renames.

---

### Categories

- **`placeholder_id/`** — pin down the identity of a placeholder byte by
  watching what mutates it / what reads it.  Each test answers "is this
  byte at DS:`<addr>` actually `<hypothesized name>`?" or "is this an
  N-bit field, not a 1-byte field?".

- **`proc_equivalence/`** — pin down what a procedure DOES at a known
  address (or at a dispatch-slot target).  Validates / refutes IDA-
  derived names by behavioral fingerprint, independent of any label.

- **`regression/`** — fixed-input fixed-output tests for procs whose
  semantics are already pinned down.  Lock in golden byte-deltas /
  flag values via `fixtures.check_regression()`.  Each file batches
  multiple scenarios; aggregate VERDICT fails on any divergence.

---

### Index

| Category | File | Verifies |
|---|---|---|
| proc_equivalence | [test_zeliad_load_order.py](proc_equivalence/test_zeliad_load_order.py) | `zeliad.asm` driver/file load sequence - stdply or save, stick, game, graphics-mode driver, music driver, joystick driver, including packed driver table resolution |
| proc_equivalence | [test_zeliad_init_game_globals.py](proc_equivalence/test_zeliad_init_game_globals.py) | `zeliad.asm` pre-`game.bin` global initialization - chunk callback pointer, saved INT vectors, startup flags, gfx/music/joystick propagation, `gvar_game_seg`, and uppercase 8-byte save-name copy |
| proc_equivalence | [test_zeliad_command_line.py](proc_equivalence/test_zeliad_command_line.py) | `zeliad.asm` PSP command-line save-file parser - empty/space-only tails ignored, non-space chars compacted, `.USR` appended, input case preserved |
| proc_equivalence | [test_zeliad_config_parsers.py](proc_equivalence/test_zeliad_config_parsers.py) | `zeliad.asm` RESOURCE.CFG parser helpers - graphics token mapping, MT-32 driver flag, music/joystick driver name copy, joystick enable yes/no |
| proc_equivalence | [test_zeliad_set_video_mode.py](proc_equivalence/test_zeliad_set_video_mode.py) | `zeliad.asm` `set_video_mode` - EGA/CGA/CGA2/MCGA/TGA INT 10h AX dispatch plus HGC B000 clear side effect |
| proc_equivalence | [test_game_bootstrap_sequence.py](proc_equivalence/test_game_bootstrap_sequence.py) | `game.asm` `run_game_main` - boot state clear block, all-mode GD/GT/GF driver tables, compressed-table relocations, `game_init_fn` segment patch, new-game/saved-game SAR/control-flow sequence, optional music/equipment driver calls, and SAR loader stubbed |
| proc_equivalence | [test_gmmcga_equipped_sword_oracle.py](proc_equivalence/test_gmmcga_equipped_sword_oracle.py) | Release `GMMCGA.bin` equipped-sword renderer at `254Ch` - verifies all six fixed-stride ITEMP sword sprites with exact MCGA rectangle hashes |
| proc_equivalence | [test_game_load_music_tracks.py](proc_equivalence/test_game_load_music_tracks.py) | `game.asm` `load_music_tracks` - count gate, 9-entry music track reference table, and track-8 background flag |
| proc_equivalence | [test_game_set_vga_palette.py](proc_equivalence/test_game_set_vga_palette.py) | `game.asm` `set_vga_palette` - EGA INT 10h table, no-op modes, and MCGA 64-entry DAC write plan |
| proc_equivalence | [test_stick_continuous_input_oracle.py](proc_equivalence/test_stick_continuous_input_oracle.py) | Release `stick.bin` `process_scancode`, `handle_pause_key`, and `handle_special_keys` - held direction make/break, Enter/Space action bytes, and sampled F1/F2 latches |
| proc_equivalence | [test_opdemo_opening_sequence.py](proc_equivalence/test_opdemo_opening_sequence.py) | `100OPDMO.asm` `run_opening_demo_main` - title/NEC/HOU/DMAOU resource load, decode, palette, blit, input-clear, volume checkpoint, sprite script summaries, and title asset reload before `int 60h` |
| proc_equivalence | [test_town_walk_left_col.py](proc_equivalence/test_town_walk_left_col.py) | `walk_left_move` column/scroll body - town column decrement, no-scroll edge, and scroll-side effects |
| proc_equivalence | [test_town_live_loop_primitives.py](proc_equivalence/test_town_live_loop_primitives.py) | `106TOWN` live-loop primitives - event writes, NPC restore/tick/stamp, passability-list ZF, and player dirty-cursor bytes |
| proc_equivalence | [test_town_first_castle_frame_oracle.py](proc_equivalence/test_town_first_castle_frame_oracle.py) | Release-MASM Felishika castle composition - CPAT conversion, actor scratch/cursor state, initial VGA, and two persistent NPC idle frames |
| proc_equivalence | [test_town_first_muralla_frame_oracle.py](proc_equivalence/test_town_first_muralla_frame_oracle.py) | Release-MASM Muralla composition - MPAT banks, descriptor/door/NPC records, first stable VGA frame, and Felishika return frame |
| proc_equivalence | [test_town_first_satono_frame_oracle.py](proc_equivalence/test_town_first_satono_frame_oracle.py) | Release-MASM Satono composition - UGM1/CMAN/DPAT selectors, descriptor/door/NPC records, equipment HUD wrapper calls, and exact first stable VGA frame |
| proc_equivalence | [test_town_bosque_resources_oracle.py](proc_equivalence/test_town_bosque_resources_oracle.py) | Release Bosque descriptor, doors, Riza/Pollo routes, Hero Crest sentry mutation/dialogs, 50-gold inn tier, and 1:8 Almas exchange tier |
| proc_equivalence | [test_town_helada_resources_oracle.py](proc_equivalence/test_town_helada_resources_oracle.py) | Release Helada descriptor, Ice Cavern routes, Percel/Ruzeria story mutation, 70-gold inn tier, and 1:4 Almas exchange tier |
| proc_equivalence | [test_town_tumba_resources_oracle.py](proc_equivalence/test_town_tumba_resources_oracle.py) | Release Tumba descriptor, graveyard routes, Pirika/Glory Crest story mutations, Knight's Sword exchange, 100-gold inn tier, and 1:2 Almas exchange tier |
| proc_equivalence | [test_town_dorado_resources_oracle.py](proc_equivalence/test_town_dorado_resources_oracle.py) | Release Dorado descriptor, Tesoro/Burata routes, Shirukaano story mutation, merchant inventories, 150-gold inn tier, and 1:4 Almas exchange tier |
| proc_equivalence | [test_town_llama_resources_oracle.py](proc_equivalence/test_town_llama_resources_oracle.py) | Release Llama descriptor, Paguro/Inferno routes, Elf Crest and Asbestos Cape story controls, merchant inventories, 200-gold inn tier, and authored 4:2 Almas exchange tier |
| proc_equivalence | [test_town_pureza_resources_oracle.py](proc_equivalence/test_town_pureza_resources_oracle.py) | Release Pureza descriptor, final-cavern route, Lion Head Key mutations, Jashiin/Dorado trap, merchant inventories, 400-gold inn tier, and 1:6 Almas exchange tier |
| proc_equivalence | [test_town_esco_resources_oracle.py](proc_equivalence/test_town_esco_resources_oracle.py) | Release Esco descriptor, shared Pureza-tunnel/Helada boundary records, authored rooms and NPCs, hidden-village control flag, discounted merchant catalogs, and 1:8 Almas exchange tier |
| proc_equivalence | [test_town_first_dialog_oracle.py](proc_equivalence/test_town_first_dialog_oracle.py) | Release-MASM first Felishika dialog - exact script PC, 161 glyph calls, MCGA page hash, `0x1E` sound mailbox, NPC mutation, and restored framebuffer |
| proc_equivalence | [test_town_muralla_dialog_oracle.py](proc_equivalence/test_town_muralla_dialog_oracle.py) | Release-MASM first Muralla NPC dialog - two page hashes, 206 content glyphs plus prompt, exact script PC, and framebuffer restoration |
| proc_equivalence | [test_muralla_room_frames_oracle.py](proc_equivalence/test_muralla_room_frames_oracle.py) | Release-MASM Armor, Drugstore, Church, and Bank first frames plus Armor/Drugstore/Bank main-menu frames |
| proc_equivalence | [test_satono_inn_frame_oracle.py](proc_equivalence/test_satono_inn_frame_oracle.py) | Release-MASM Satono Inn first stable frame/artwork and authored 30-gold price-table tier |
| proc_equivalence | [test_felishika_room_frames_oracle.py](proc_equivalence/test_felishika_room_frames_oracle.py) | Release-MASM Felishika room frames, sage progression, and room-return playfield/HUD preservation contract |
| proc_equivalence | [test_gtmcga_town_scroll.py](proc_equivalence/test_gtmcga_town_scroll.py) | Release `111GTMCA.bin` horizontal scroll routines - exact full-VGA hashes for both directions |
| proc_equivalence | [test_town_measure_word_width.py](proc_equivalence/test_town_measure_word_width.py) | `measure_word_width` dialog helper - glyph-width sum, space/slash/high-bit stop bytes, and control-byte skip |
| proc_equivalence | [test_town_count_wrapped_lines.py](proc_equivalence/test_town_count_wrapped_lines.py) | `count_wrapped_lines` dialog helper - high-bit terminator, slash line breaks, and 0xA8 space-wrap threshold |
| proc_equivalence | [test_town_draw_cursor_at_dlg_row.py](proc_equivalence/test_town_draw_cursor_at_dlg_row.py) | `draw_cursor_at_dlg_row` menu helper - computes graphics cursor BX as `gvar_dlg_pos + 0x100 + 10*row`, including word wrap |
| proc_equivalence | [test_town_cursor_anim.py](proc_equivalence/test_town_cursor_anim.py) | `animate_cursor_left_10cols` / `animate_cursor_right_10cols` menu helpers - ten 1-column graphics cursor calls from the dialog row base |
| proc_equivalence | [test_town_selection_scroll.py](proc_equivalence/test_town_selection_scroll.py) | `poll_menu_input` selection scroll branches - top-row mutation, xlat redraw value, and ten scroll-frame graphics-call params |
| proc_equivalence | [test_town_menu_input_decision.py](proc_equivalence/test_town_menu_input_decision.py) | `poll_menu_input` post-joystick branch table - visible cursor move, selection-window scroll, and no-op edge decisions |
| proc_equivalence | [test_town_menu_result_flags.py](proc_equivalence/test_town_menu_result_flags.py) | `poll_menu_input` post-frame result flags - skip returns carry, spacebar accepts and sets volume |
| proc_equivalence | [test_town_menu_entry_setup.py](proc_equivalence/test_town_menu_entry_setup.py) | `poll_menu_input` entry setup - clears stale flags, draws/ticks with preserved row, clears frame timer, then exits through result branch |
| proc_equivalence | [test_town_menu_entry_joystick.py](proc_equivalence/test_town_menu_entry_joystick.py) | `poll_menu_input` full entry through patched joystick poll - visible up/down cursor moves, bounded no-op, and neutral no-op |
| proc_equivalence | [test_town_menu_entry_scroll.py](proc_equivalence/test_town_menu_entry_scroll.py) | `poll_menu_input` full entry through patched joystick poll - top/bottom selection-window scroll paths and graphics-call params |
| proc_equivalence | [test_town_prompt_yes_no.py](proc_equivalence/test_town_prompt_yes_no.py) | `prompt_yes_no` wrapper - temporary 2x2 dialog state, clear/poll calls, restore, and carry yes/no result |
| proc_equivalence | [test_town_clear_n_dialog_rows.py](proc_equivalence/test_town_clear_n_dialog_rows.py) | `clear_n_dialog_rows` - gfx clear-row call sequence, computed row positions, and loop register aftermath |
| proc_equivalence | [test_town_shop_selection_anim_loop.py](proc_equivalence/test_town_shop_selection_anim_loop.py) | shop selection animation loop - per-item `gfx_sel_init` lookup and `gfx_sel_draw` row call params |
| proc_equivalence | [test_town_draw_menu_items_column.py](proc_equivalence/test_town_draw_menu_items_column.py) | `draw_menu_items_column` - direct per-item `gfx_sel_init` values and `gfx_sel_draw` row call params |
| proc_equivalence | [test_town_save_name_new_flag.py](proc_equivalence/test_town_save_name_new_flag.py) | save-name helpers - `Re-Start` hyphen detection and new-name buffer blanking behavior |
| proc_equivalence | [test_town_save_name_cursor.py](proc_equivalence/test_town_save_name_cursor.py) | save-name cursor helpers - clear/draw graphics params and cursor length clamp/update behavior |
| proc_equivalence | [test_town_save_name_backspace.py](proc_equivalence/test_town_save_name_backspace.py) | save-name backspace path - buffer shift, max-length decrement, cursor update, and redraw calls |
| proc_equivalence | [test_town_save_name_append_char.py](proc_equivalence/test_town_save_name_append_char.py) | save-name typed-character path - buffer write, max-length growth on blank slot, redraw, and cursor advance |
| proc_equivalence | [test_fight_entity_step_dispatch_c.py](proc_equivalence/test_fight_entity_step_dispatch_c.py) | `entity_step_dispatch_c` - optional bit-6 path update gate; CF=1 from update returns early, otherwise dispatches through `entity_fn_tbl_c` and masks `[si+1]&=0x3F` |
| proc_equivalence | [test_fight_entity_fn_dispatch_b.py](proc_equivalence/test_fight_entity_fn_dispatch_b.py) | `entity_fn_dispatch_b` - computes `BX=2*([si+5]&7)`, masks `AL&=0x3F`, then dispatches through `entity_fn_tbl_b` |
| proc_equivalence | [test_fight_prep_boss_dirty_blit.py](proc_equivalence/test_fight_prep_boss_dirty_blit.py) | `prep_boss_dirty_blit` - boss/sprite-work dirty flag sibling of `prep_dirty_blit`; gates on bit-15 of `[si+3]`, clears it, loads DX/AH/AL for shared blit loop |
| proc_equivalence | [test_fight_level_handoff_oracle.py](proc_equivalence/test_fight_level_handoff_oracle.py) | Release `200FIGHT.bin` exit-trigger handoff - loader `AL=1`, door targets become selectors `0x80/0x81`, ordinary cavern targets retain their low selector, and the full persistent pre-selector record `0x00..0xC1` (including cavern object masks) is unchanged |
| proc_equivalence | [test_fight_death_sage_handoff_oracle.py](proc_equivalence/test_fight_death_sage_handoff_oracle.py) | Release `200FIGHT.bin` game-over tail - writes fade interval 8, performs 30 alternating redraw-lock wipe passes, calls the final MCGA fade-to-black, restores HP, copies last-sage byte `C5` to current-area byte `C4`, calls loader 1, and executes `level_start` against the release Muralla MDT to prove spawn `009B/0E/0D` at sage target `00AC` |
| proc_equivalence | [test_sage_death_entry_oracle.py](proc_equivalence/test_sage_death_entry_oracle.py) | Release `217KENJP.bin` dispatch table - slot `A000` points to normal entry `A027`, slot `A004` points to death entry `A006`, which selects centered origin `0E17` and fixed script `BA67` ("While you were unconscious...") |
| proc_equivalence | [test_fight_transition_music_boundary_oracle.py](proc_equivalence/test_fight_transition_music_boundary_oracle.py) | Release `106TOWN.bin`/`200FIGHT.bin` ROKA timing - town transitions write MSCADLIB fade interval `4` to `FF24h`, the run contains no `INT 60h`, then `level_start` executes `AX=1 / INT 60h` before loading the destination score |
| proc_equivalence | [test_fight_damage_sound_oracle.py](proc_equivalence/test_fight_damage_sound_oracle.py) | Release `200FIGHT.bin` damage event stores - shield damage writes `08h`, direct/environment damage writes `09h`, and entity hits write `16h` once per executed damage path; hazard repetition comes from later tile-damage scans, not a held `FF75h` value |
| proc_equivalence | [test_select_magia_sabre_oil_oracle.py](proc_equivalence/test_select_magia_sabre_oil_oracle.py) | Release `201SELCT.bin`/`200FIGHT.bin` item contract - item 5 seeds four seven-byte Magia orbit records at `EB60h`, item 7 increments temporary Sabre Oil power at `E4h`, and combat advances/draws the orbit while multiplying sword offense by `E4h+1` |
| proc_equivalence | [test_fight_peligro_resources_oracle.py](proc_equivalence/test_fight_peligro_resources_oracle.py) | Release `200FIGHT.bin` Area 2 refs plus verified `MP10/MP21/MP20/MP2D` descriptors - proves the bidirectional Malicia/Peligro connector doors, linked persistent item/stash masks, Peligro's 45/11 object roster and four enemy families, Pulpo resource selection, the directional 26-step `355ENCNT` boss entrance contract, and the `300ROKAD` raised-sword/crystal/fanfare reward contract |
| proc_equivalence | [test_fight_madera_resources_oracle.py](proc_equivalence/test_fight_madera_resources_oracle.py) | Release `200FIGHT.bin` Area 3 refs plus verified `MP20/MP30/MP31` descriptors - proves Peligro/Madera forward and reverse doors, Madera/Riza handoff, Bosque exit, Madera's 30/15 roster and enemy families, and all six `stdply.asm` persistent object links |
| proc_equivalence | [test_fight_riza_resources_oracle.py](proc_equivalence/test_fight_riza_resources_oracle.py) | Release `200FIGHT.bin` forest/Pollo refs plus verified `MP30/MP31/MP3D` descriptors - proves bidirectional Madera/Riza doors, Bosque and next-region exits, Riza's 36/12 roster, Hero's Crest coordinate, six persistent links, both directional Pollo doors, and the exact TORI completion contract |
| proc_equivalence | [test_fight_escarcha_resources_oracle.py](proc_equivalence/test_fight_escarcha_resources_oracle.py) | Release `200FIGHT.bin` Area 4 refs plus verified `MP40/MP41` descriptors - proves Helada entry, all three bidirectional Escarcha/Glacial routes, Escarcha's 14/22 roster, persistent item/stash masks, and the exact Area-4/Ruzeria movement gate |
| proc_equivalence | [test_select_ruzeria_oracle.py](proc_equivalence/test_select_ruzeria_oracle.py) | Release `201SELCT.bin` wearable ownership/equip flow plus `200FIGHT.bin` Ruzeria pickup and Area-4 ice-traction gate |
| proc_equivalence | [test_fight_glacial_resources_oracle.py](proc_equivalence/test_fight_glacial_resources_oracle.py) | Release `200FIGHT.bin` Glacial/Agar refs plus verified `MP40/MP4D` descriptors - proves Glacial's 38/31 roster, Helada and Escarcha topology, eight persistent item/stash masks, and the exact ZELA/ENCOUNTER boss-door handoff |
| proc_equivalence | [test_fight_cementar_resources_oracle.py](proc_equivalence/test_fight_cementar_resources_oracle.py) | Release `200FIGHT.bin` Cementar/Vista refs plus verified `MP50/MP51/MP5D` descriptors - proves Cementar's 36/34 roster, five Corroer reverse routes, ten persistent item/stash masks, and the exact MEDA/ENCOUNTER boss-door handoff |
| proc_equivalence | [test_fight_corroer_resources_oracle.py](proc_equivalence/test_fight_corroer_resources_oracle.py) | Release `200FIGHT.bin` Corroer refs plus verified `MP50/MP51` descriptors - proves all nine Corroer routes, eight persistent item/stash masks, Area-5 Gelroid slot handling, and Pirika wearable-ID-2 contact protection |
| proc_equivalence | [test_select_pirika_oracle.py](proc_equivalence/test_select_pirika_oracle.py) | Release `201SELCT.bin` wearable ownership/equip flow plus `200FIGHT.bin` Pirika pickup and ID-2 contact-hazard protection gate |
| proc_equivalence | [test_fight_plata_resources_oracle.py](proc_equivalence/test_fight_plata_resources_oracle.py) | Release `200FIGHT.bin` Area-6 refs plus verified `MP60/MP61` descriptors - proves Plata's exact 15-door topology, eight Tesoro reverse links, Dorado town exit, six persistent item/stash masks, and authored enemy roster |
| proc_equivalence | [test_fight_tesoro_resources_oracle.py](proc_equivalence/test_fight_tesoro_resources_oracle.py) | Release `200FIGHT.bin` Area-6/Tarso refs plus verified `MP60/MP61/MP6D` descriptors - proves Tesoro's exact 14-door topology, Plata reverse routes, Dorado exit, ten persistent item/stash masks, enemy roster, and the Tarso boss-door handoff |
| proc_equivalence | [test_fight_arrugia_resources_oracle.py](proc_equivalence/test_fight_arrugia_resources_oracle.py) | Release `200FIGHT.bin` Area-6 reward handlers plus verified `MP60/MP62` descriptors - proves Arrugia's Lion-keyed entrance/free return pair, forward boundary, six persistent treasure/stash records, Silkarn wearable reward, and Enchantment Sword handler |
| proc_equivalence | [test_select_silkarn_oracle.py](proc_equivalence/test_select_silkarn_oracle.py) | Release `201SELCT.bin` wearable ownership/equip flow plus `200FIGHT.bin` Area-6 Silkarn reward and ID-3 slope-traversal gate |
| proc_equivalence | [test_fight_caliente_resources_oracle.py](proc_equivalence/test_fight_caliente_resources_oracle.py) | Release `200FIGHT.bin` Area-7/Dragon refs and heat gate plus verified `MP70/MP7D` descriptors - proves Caliente topology, Llama/Tesoro/Correr routes, six persistent item/stash masks, Asbestos Cape protection, and Dragon chamber handoff |
| proc_equivalence | [test_select_asbestos_oracle.py](proc_equivalence/test_select_asbestos_oracle.py) | Release Llama 2500-almas Cape offer, `201SELCT.bin` wearable ownership/equip flow, and `200FIGHT.bin` ID-5 Area-7 periodic heat-damage bypass |
| proc_equivalence | [test_fight_correr_resources_oracle.py](proc_equivalence/test_fight_correr_resources_oracle.py) | Release `200FIGHT.bin` Area-7 refs plus verified `EAI7/MP70/MP71/MP72` bytes - proves Correr's family-4 double-step movement, five-door topology, three persistent item/stash masks, and exact Reaccion/Caliente reverse routes |
| proc_equivalence | [test_fight_environmental_mechanics_oracle.py](proc_equivalence/test_fight_environmental_mechanics_oracle.py) | Release `MPP5/MPP7` movement-family tables and decoded `MP31/MP50/MP51/MP70/MP72` topology - enumerates all 19 wrap-aware Correr one-way-wall components, all four Corroer hidden wall paths, and the exact Caliente/Cementar/Riza platform and concealed-floor records |
| placeholder_id | [test_player_stats_word_layout.py](placeholder_id/test_player_stats_word_layout.py) | DS:0x90/0x8B/0x94 are 16-bit fields (`hero_HP`, `hero_almas`, `shield_HP`), not bytes |
| placeholder_id | [test_stdply_stat_X9C.py](placeholder_id/test_stdply_stat_X9C.py) | DS:0x9C is **VESTIGIAL** — `entity_fn_e_4` writes 0xFF, no reader observed in writer subtree |
| placeholder_id | [test_stdply_stat_X9F.py](placeholder_id/test_stdply_stat_X9F.py) | DS:0x9F is **VESTIGIAL** — town frame_update zero-clears it every frame, no reader |
| placeholder_id | [test_fight_state_byte_C017.py](placeholder_id/test_fight_state_byte_C017.py) | DS:0xC017 is a **data-table base word** (`bx = 2*idx + word_at_C017` in start_boss_scroll); rename → `world_tile_base` |
| placeholder_id | [test_town_player_col_X83.py](placeholder_id/test_town_player_col_X83.py) | DS:0x83 is **`screen_position`** (screen column counter, walk_right_move increments by 1); the `ply_accel db 0Ah,0Ah` declaration was bogus |
| placeholder_id | [test_stdply_hero_bank_X88.py](placeholder_id/test_stdply_hero_bank_X88.py) | DS:0x88..0x8A is **`hero_bank_hi/lo`** — 24-bit banked gold accumulator (add+adc+carry confirmed in BANKPRO.BIN) |
| proc_equivalence | [test_fight_dispatch_8slots_fingerprint.py](proc_equivalence/test_fight_dispatch_8slots_fingerprint.py) | All 8 fight-bin move-monster slots (0x600C..0x601A) grouped into N/S/E/W families by mutation fingerprint |
| proc_equivalence | [test_fight_dispatch_slot_6008.py](proc_equivalence/test_fight_dispatch_slot_6008.py) | Current fight slot 0x600C target (`move_monster_E`) reads `[SI+3]`, branches on `<34`, and mutates only when collision CF=0 |
| proc_equivalence | [test_town_dispatch_slot_600A.py](proc_equivalence/test_town_dispatch_slot_600A.py) | Town slot 0x600A target (0x7570) reads gold at DS:0x85+0x86..0x87 — confirms hero_gold_hi/_lo layout |
| proc_equivalence | [test_town_dispatch_slot_600C.py](proc_equivalence/test_town_dispatch_slot_600C.py) | Town slot 0x600C target adds AX into DS:0x86 word, propagates carry into DS:0x85 byte |
| regression | [test_arithmetic_24bit_and_word.py](regression/test_arithmetic_24bit_and_word.py) | Phase-4 batch 4a — 14 scenarios across hero_HP_subtract, hero_almas_add, hero_gold_add, check_gold_sufficient, hero_bank_add (24-bit + 16-bit arithmetic with carry/overflow/clamp behaviors) |
| regression | [test_reset_combat_state.py](regression/test_reset_combat_state.py) | Phase-4 batch 4b — `reset_combat_state` zeroes 11 flags + sets 4 sentinels to 0xFF + writes 0xFFFF word, exactly as captured |
| regression | [test_movement_helpers.py](regression/test_movement_helpers.py) | Phase-4 batch 4c — 8 scenarios across inc/dec_map_pos and inc/dec_row primitives (column with map-wrap, row with 0x3F mask) |
| regression | [test_enemy_tick_iterators.py](regression/test_enemy_tick_iterators.py) | Phase-4 batch 4d — 5 scenarios across tick_decrement / tick_increment_enemy_counters (enemy_data_buf scan, zeros skipped, 0xFF terminator) |
| regression | [test_gate_classifier_procs.py](regression/test_gate_classifier_procs.py) | Phase-4 batch 4e — 14 scenarios across gate_spell_fx_active, is_non_area7_slot_b_entity, is_unknown_or_area5_slot_{b,c} (gate / classifier procs adjacent to combat-FSM bytes) |
| proc_equivalence | [test_fight_game_func_138.py](proc_equivalence/test_fight_game_func_138.py) | `game_func_138` → **`is_entity_known_type`** — entity-ID classifier; ZF=1 iff AL is in enemy_id_table OR in 0x49..0x7F. 18 callers. |
| proc_equivalence | [test_fight_game_func_89.py](proc_equivalence/test_fight_game_func_89.py) | `game_func_89` → **`entity_slot_write_tagged`** — bit-7 tagged slot write to [di] direct or `enemy_data_ext[idx]`. 8 callers. |
| proc_equivalence | [test_fight_game_func_141.py](proc_equivalence/test_fight_game_func_141.py) | `game_func_141` → **`world_x_to_screen_x`** — world-X → screen-X with map-wrap (constant 0x23 = 35-tile width). 6 callers. |
| proc_equivalence | [test_fight_game_func_42.py](proc_equivalence/test_fight_game_func_42.py) | `game_func_42` → **`is_entity_id_lax`** — variant of is_entity_known_type that accepts AL>=0x80 as known. 5 callers. |
| proc_equivalence | [test_fight_game_func_87.py](proc_equivalence/test_fight_game_func_87.py) | `game_func_87` → **`world_x_to_inner_screen_x`** — same shape as world_x_to_screen_x but constant 0x21 (33-tile inner region). 5 callers. |
| proc_equivalence | [test_fight_game_func_63.py](proc_equivalence/test_fight_game_func_63.py) | `game_func_63` → **`lookup_move_slot_family`** — scan AL across 3 4-entry tables; CL = family idx 0/1/2 or 0xFF. 5 callers. |
| proc_equivalence | [test_fight_game_func_120.py](proc_equivalence/test_fight_game_func_120.py) | `game_func_120` → **`hero_almas_add`** — adds AX to hero_almas with 0xFFFF cap + HUD redraw. 4 callers. |
| proc_equivalence | [test_fight_game_func_93.py](proc_equivalence/test_fight_game_func_93.py) | `game_func_93` → **`enemy_sprite_blit`** — gates on [di]>=0xFC, then game_multiply_4 + vga_operation4 + gfx_fn_78. 4 callers. |
| proc_equivalence | [test_fight_game_func_60.py](proc_equivalence/test_fight_game_func_60.py) | `game_func_60` → **`hero_HP_subtract`** — subtract AX from hero_HP word with 0-clamp + HP-bar HUD redraw. 4 callers. |
| proc_equivalence | [test_fight_game_func_19.py](proc_equivalence/test_fight_game_func_19.py) | `game_func_19` → **`is_non_area7_slot_b_entity`** — CF=1 iff area_num != 7 AND entity in move_slot_b. 2 callers. |
| proc_equivalence | [test_fight_game_func_82.py](proc_equivalence/test_fight_game_func_82.py) | `game_func_82` → **`match_dl_within_3`** — match [si] against {DL, DL+1, DL+2}; DH = (1, 0, -1). 3 callers. |
| proc_equivalence | [test_fight_game_func_92.py](proc_equivalence/test_fight_game_func_92.py) | `game_func_92` → **`prep_dirty_blit`** — gates on bit-15 of [si+7]; clears flag + falls through to enemy_sprite_blit. 2 callers. |
| proc_equivalence | [test_fight_game_func_106.py](proc_equivalence/test_fight_game_func_106.py) | `game_func_106` → **`try_place_tile_id_49`** — 4-gate tile placement (counter + vga_op9 + 2 bit-5 flags). 3 callers. |
| proc_equivalence | [test_fight_game_func_70.py](proc_equivalence/test_fight_game_func_70.py) | `game_func_70` → **`compute_scroll_pos`** — derive starting_position_in_town/row from scroll_count, scroll_dir, player_y. 2 callers. |
| proc_equivalence | [test_fight_game_func_129.py](proc_equivalence/test_fight_game_func_129.py) | `game_func_129` → **`is_unknown_or_area5_slot_b`** — CF=1 iff entity unknown OR (area==5 AND in slot_b). 2 callers. |
| proc_equivalence | [test_fight_game_func_131.py](proc_equivalence/test_fight_game_func_131.py) | `game_func_131` → **`is_unknown_or_area5_slot_c`** — twin of 129 but slot_c family. 2 callers. |

---

### Conventions for adding a new test

1. **Pick the category by what the test PROVES**, not where the code
   lives.  A probe that touches fight.bin to disambiguate a stdply byte
   goes in `placeholder_id/`, not `proc_equivalence/`.

2. **Filename**: `test_<area>_<short-noun>.py` — area is the chunk family
   or symbol prefix, short-noun is the thing being verified.  Examples:
   `test_stdply_init_complete_flag.py`, `test_fight_arena_setup.py`.

3. **Imports**: at the top of every test (paths are 1 level deep):

   ```python
   import sys
   from pathlib import Path
   HERE = Path(__file__).parent
   sys.path.insert(0, str(HERE.parent))   # find harness.py at functest root
   from harness import TasmHarness  # noqa: E402
   ```

4. **Output format**: human-readable PASS/FAIL with the byte deltas
   that justified the verdict.  No silent passes.  Tests should print
   the diff (e.g. `DS:0x86 0x00->0x64`) so a reader who doesn't trust
   the verdict can re-derive it from the trace.

5. **Update this index** when the test lands.  One row per file.

6. **Feed verdicts back to `working/AUDIT_TODO.md`** — when a runtime
   probe confirms or refutes a static guess, mark the relevant row
   there (or move it from "Functional-probe required" to "Done").

---

### Static-evidence renames (no test artifact)

These were renamed based on static analysis only (small/trivial procs
where a runtime test would be ceremonial).  Listed for traceability.

| Old name | New name | Chunk | Notes |
|---|---|---|---|
| `game_func_27` | `process_map_seg_updates` | 200FIGHT | map_seg_ptr scanner with conditional copy |
| `game_func_41` | `is_entity_known_type_alt` | 200FIGHT | third variant of entity classifier (handles 0x9F mask) |
| `game_func_51` | `init_combat_arena` | 200FIGHT | sets anim_ctr_x/y + enemy_scroll_flag, gfx fill/clear |
| `game_func_59` | `accumulate_tile_type` | 200FIGHT | tile-type lookup → adds to tile_type_sum |
| `game_func_62` | `tail_dispatch_by_slot_family` | 200FIGHT | pops 2 frames + tail-dispatch via entity_dispatch_tbl |
| `game_func_65` | `enter_level_via_ref_a` | 200FIGHT | trivial wrapper: `mov bx, level_ref_a; jmp level_start` |
| `game_func_68` | `world_x_to_screen_x_w27` | 200FIGHT | coord transform variant (constant 0x27) |
| `game_func_71` | `compute_scroll_offset_b` | 200FIGHT | scroll-position calc variant |
| `game_func_72` | `decrement_speed_or_power` | 200FIGHT | dual-state counter decrementer (char_speed/_power) |
| `game_func_73` | `reset_combat_state` | 200FIGHT | zeros ~15 game-state flags + jmp hud_fill |
| `game_func_81` | `find_and_blit_map_entry` | 200FIGHT | 3-byte-entry map-table search + vga_operation4 blit |
| `game_func_84` | `bot_path_check` | 200FIGHT | match_dl_within_3 + game_process_loop_3 chain |
| `game_func_88` | `world_x_to_screen_x_w25` | 200FIGHT | coord transform variant (constant 0x25) |
| `game_func_91` | `process_dirty_enemies` | 200FIGHT | scan enemy_data_buf calling prep_dirty_blit |
| `game_func_96` | `entity_fn_dispatch_b` | 200FIGHT | jmp via entity_fn_tbl_b[[si+5]&7] |
| `game_func_97` | `entity_step_dispatch_c` | 200FIGHT | gates [si+5] bit-6 + dispatch via entity_fn_tbl_c |
| `game_func_98` | `update_entity_dir_from_path` | 200FIGHT | reads path-table byte, updates [si+5] direction bits |
| `game_func_99` | `tick_decrement_enemy_counters` | 200FIGHT | scan enemy_data_buf decrementing first byte |
| `game_func_100` | `tick_increment_enemy_counters` | 200FIGHT | sibling that increments instead |
| `game_func_102` | `process_active_sprites` | 200FIGHT | sprite_work_buf scanner with prep_boss_dirty_blit |
| `game_func_103` | `prep_boss_dirty_blit` | 200FIGHT | bit-15 dirty flag prep for boss-sprite blit |
| `game_func_111` | `gate_spell_fx_active` | 200FIGHT | trivial guard: `test [spell_fx_active]; jnz +3; retn` |
| `game_func_112` | `cycle_dir_and_advance` | 200FIGHT | inc [si+5] mod 3, advance column with map-wrap |
| `game_func_115` | `try_paint_obj_cell` | 200FIGHT | 3x3 cell renderer worker (vga_operation9 + bit checks) |
| `game_func_122` | `entity_move_east` | 200FIGHT | bounded col=0x22, jmp inc_map_pos |
| `game_func_123` | `entity_move_north` | 200FIGHT | bounded AL!={0,0x23}, jmp dec_row |
| `game_func_124` | `entity_move_west` | 200FIGHT | bounded col>=2, jmp dec_map_pos |
| `game_func_125` | `entity_move_south` | 200FIGHT | bounded AL!={0,0x23}, jmp inc_row |
| `game_func_126` | `inc_map_pos_helper` | 200FIGHT | column++ with map-width wrap |
| `game_func_127` | `dec_map_pos_helper` | 200FIGHT | column-- + inc/dec_row helpers (multi-fragment) |
| `game_func_132`–`137` | `check_north_movement`, `check_south_movement`, `check_movement_var_134`–`137` | 200FIGHT | tile-collision checks called by entity_move_* family |
| `game_func_143` | `item_effect_val_add` | 200FIGHT | adds AX to item_effect_val with 0xFFFF cap |

### Documented placeholders (kept by design)

`game_func_56` and `game_func_23` retained as Sourcer-glued multi-
fragment clusters with explanatory comment blocks in 200FIGHT.asm.
Renaming would obscure their cross-proc-jump-target nature.
