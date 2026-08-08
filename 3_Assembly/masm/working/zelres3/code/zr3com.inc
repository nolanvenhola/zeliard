;==========================================================================
;
;  zr3com.inc - Shared runtime addresses for zelres3 enemy AI handlers
;               and sprite/arena modules (300-319).
;
;  Each chunk in zelres3 is loaded into the game segment at runtime by
;  the SAR loader.  The values below are STABLE INTERFACE addresses owned
;  by 200FIGHT.bin (loaded at game_seg:0xC000) and zeliad.bin (game state
;  at 0xFFxx).  They never shift even if individual chunks are recompiled
;  -- this is the original developers' cross-chunk linking convention.
;
;  Aliases: where a single address has multiple historical / semantic
;  names, both are kept here as `equ` aliases.  TASM accepts multiple
;  symbols at the same value.
;
;==========================================================================

;-- stick.bin dispatch slots (function pointers in driver_init_data) -------
;   Canonical home is zr1com.inc / zr2com.inc; mirrored here for zelres3
;   chunks that call into stick.bin (300ROKAD, 314LEGA, ...).
sar_loader_fn                equ 10Ch ; SAR chunk loader entry
stick_subsample_tick_handler equ 11Ah ; per-tick subsample accumulator update

;-- Game-state globals (DS=game_seg, FFxx zone, owned by zeliad/game) ------
gvar_death_flag         equ     0FF2Eh  ; enemy/object death flag
gvar_dir_toggle         equ     0FF2Fh  ; direction toggle / facing flip
gvar_completion         equ     0FF30h  ; level completion state
gvar_frame_cnt          equ     0FF35h  ; frame counter (EAI context)
gvar_enemy_cnt          equ     0FF36h  ; active enemy count
; The byte at 0FF4Ah is the object-scan loop index used by 200FIGHT's
; entity scans (set + inc inside obj_list_loop, indexed into
; enemy_data_ext[]).  The "sub-frame counter" name was a guess — the
; canonical name is `obj_scan_index` (see 200FIGHT.asm line 130 EQU).
; Kept as alias for the 2 enemy-chunk reads (304EAI4, 305EAI5).
gvar_sub_frame          equ     0FF4Ah  ; alias for obj_scan_index
gvar_spawn_fx_flag      equ     0FF75h  ; spawn FX trigger
                                        ; (NOTE: same byte as gvar_volume_b
                                        ;  in zeliad/game context -- repurposed
                                        ;  during fight phase)

;-- Fight-engine state (DS=game_seg, 0xC000+ = fight.bin load region) ------
fight_state_max         equ     0C002h  ; max state index for wrap
gvar_proj_cnt           equ     0C002h  ; alias: projectile count
enemy_attr_base         equ     0C010h  ; base of enemy attribute records
fight_slot_list         equ     0C010h  ; alias: enemy slot list base

;-- Sprite tables (DS=game_seg) --------------------------------------------
sprite_xlat_tbl         equ     0ED20h  ; sprite index xlat table base
sprite_idx_table        equ     0ED20h  ; alias: sprite index lookup
enemy_data_ext          equ     0ED20h  ; alias: enemy data extension table

;-- Sprite source bases (DS=game_seg, in fight.bin region) -----------------
sprite_src_alt          equ     8080h   ; alternate sprite-source base
sprite_src_aux          equ     80A1h   ; auxiliary sprite-source base

;-- Fight-engine callback vectors (DS=game_seg, fight.bin export table) ----
;  Stable dispatch slots called via `call word ptr ds:[<vec>]`.  The same
;  physical address has one canonical name shared by every chunk that
;  references it -- this used to be a chaotic mess of file-local aliases
;  (ai_fn_tbl_a..N, akma_cb_*, drgn_cb_*, lega_cb_*, mao1_cb_*, mao2_cb_*,
;  meda_cb_*, zel2_cb_*, zela_cb_*, fight_cb_rng, etc.) all pointing at
;  the same fight.bin export table.  Names below are the standardized
;  semantic names; `equ` aliases at the bottom preserve a few old labels
;  that conveyed distinct semantic intent at the same address.

fight_cb_prep           equ     200Ch   ; prep / init / scroll dispatch callback
fight_cb_range          equ     6004h   ; range / RNG / aim probe
fight_cb_alt_b          equ     6006h   ; alt-pathing slot (301 only)
fight_cb_step_neg       equ     6008h   ; step in -ve direction
fight_cb_step_neg_2     equ     600Ah   ; step in -ve direction (alt)
fight_cb_map_fwd        equ     600Ch   ; map-fwd move callback
fight_cb_map_back       equ     600Eh   ; map-back move callback
fight_cb_step_pos       equ     6010h   ; step in +ve direction
fight_cb_step_pos_2     equ     6012h   ; step in +ve direction (alt)
fight_cb_blocked        equ     6014h   ; blocked-check
fight_cb_dist_check     equ     6016h   ; distance / range check
fight_cb_aux_18         equ     6018h   ; aux probe slot (301 only)
fight_cb_aux_1a         equ     601Ah   ; aux probe slot (301 only)
fight_cb_aux_1c         equ     601Ch   ; aux probe slot (303 only)
fight_cb_record_ofs     equ     6028h   ; compute record addr from tile
fight_cb_mark_adj       equ     602Ah   ; mark adjacent tile
fight_cb_tile_index     equ     602Ch   ; query tile index
fight_cb_cmp_tile       equ     602Eh   ; compare tile / tile match
fight_cb_alt            equ     6030h   ; alternate dispatch callback
fight_cb_spawn          equ     6032h   ; spawn projectile/effect
fight_cb_fire           equ     6034h   ; fire / projectile spawn
fight_cb_anim_step      equ     6036h   ; animation step
fight_cb_hit_check      equ     6038h   ; hit / collision query
fight_cb_despawn        equ     603Ah   ; despawn slot
fight_cb_shutdown       equ     603Ch   ; shutdown / finalize callback
fight_cb_spawn_alt      equ     603Eh   ; spawn alt (e.g. body-segment)
fight_cb_aux_40         equ     6040h   ; aux probe slot (305 only)

;-- Semantic aliases at same address as canonical name ---------------------
;  These capture different semantic intents; kept as aliases.
ai_hide_fn              equ     fight_cb_fire        ; AI fn: hide / remove enemy
ai_attack_fn            equ     fight_cb_despawn     ; AI fn: attack / projectile release
ai_spawn_fn             equ     fight_cb_spawn_alt   ; AI fn: spawn body segment

; --- Canonical player-record EQUs (mirrored from stdply.inc for chunk-side use) ---
starting_position_in_town                 equ     080h
map_scroll_row                 equ     082h
screen_position                equ     083h
fight_player_col               equ     084h
gold_carried_x65536                 equ     085h
gold_carried_x1                 equ     086h
gold_carried_x256                equ     087h
gold_in_bank_x65536                 equ     088h
gold_in_bank_x1                 equ     089h
player_almas                   equ     08Bh
player_almas_hi                equ     08Ch
hero_level                     equ     08Dh
experience                     equ     08Eh
player_HP                      equ     090h
sword                equ     092h
shield                    equ     093h
shield_HP                      equ     094h
shield_max_HP                  equ     096h
keys_normal                    equ     098h
keys_lion                      equ     099h
crest_elf                      equ     09Ah
crest_glory                    equ     09Bh
crest_hero                     equ     09Ch
selected_spell                 equ     09Dh
selected_accessory              equ     09Eh
tears_of_esmesanti_count       equ     0A0h
accessory_slot_1                         equ     0A1h
accessory_slot_2                         equ     0A2h
accessory_slot_3                         equ     0A3h
accessory_slot_4                         equ     0A4h
accessory_slot_5                         equ     0A5h
item_slot_1                    equ     0A6h
player_hp_max                  equ     0B2h
facing_direction                  equ     0C2h
boss_intro_flag                equ     0C3h
save_sage                      equ     0C4h
last_sage_visited              equ     0C5h
heal_pulse_count               equ     0C6h
current_level_idx              equ     0C8h
sabre_oil_power                equ     0E4h    ; temporary Sabre Oil sword-power stack
key_count                      equ     0E4h    ; compatibility alias — earlier wrong name
sages_spoken_bitmap                   equ     0E5h
scene_trans_request            equ     0E6h
gvar_pose_idx                  equ     0E7h
init_complete_flag             equ     0E8h

