;==========================================================================
;
;  eai_common.inc - Shared runtime addresses for zelres3 enemy AI handlers
;                   and sprite/arena modules (300-319).
;
;  Each chunk in zelres3 is loaded into the game segment at runtime by
;  the SAR loader.  The values below are STABLE INTERFACE addresses owned
;  by 200FIGHT.bin (loaded at game_seg:0xC000) and zeliad.bin (game state
;  at 0xFFxx).  They never shift even if individual chunks are recompiled
;  — this is the original developers' cross-chunk linking convention.
;
;  Aliases: where a single address has multiple historical names in
;  different chunks, both are kept here.  TASM accepts multiple symbols
;  at the same value.
;
;==========================================================================

;-- Game-state globals (DS=game_seg, FFxx zone, owned by zeliad/game) ------
gvar_death_flag         equ     0FF2Eh  ; enemy/object death flag
gvar_dir_toggle         equ     0FF2Fh  ; direction toggle / facing flip
gvar_completion         equ     0FF30h  ; level completion state
gvar_frame_cnt          equ     0FF35h  ; frame counter (EAI context)
gvar_enemy_cnt          equ     0FF36h  ; active enemy count
gvar_sub_frame          equ     0FF4Ah  ; sub-frame counter
gvar_spawn_fx_flag      equ     0FF75h  ; spawn FX trigger
                                        ; (NOTE: same byte as gvar_volume_b
                                        ;  in zeliad/game context — repurposed
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
;  Stable dispatch slots called via `call word ptr ds:[<vec>]`.
;  Used directly by sprite modules (309-311) and EAI 6/7/8 (306-308).
;  EAI 1-5 (301-305) call the same physical addresses but treat them as
;  a positional `ai_fn_tbl_a..N` table — those names stay file-local.
fight_cb_prep           equ     200Ch   ; prep / init callback
fight_cb_step_neg       equ     6008h   ; step in -ve direction
fight_cb_blocked        equ     6014h   ; blocked-check
fight_cb_record_ofs     equ     6028h   ; compute record addr from tile
fight_cb_mark_adj       equ     602Ah   ; mark adjacent tile
fight_cb_tile_index     equ     602Ch   ; query tile index
fight_cb_cmp_tile       equ     602Eh   ; compare tile / tile match
fight_cb_fire           equ     6034h   ; fire / projectile spawn
fight_cb_anim_step      equ     6036h   ; animation step
fight_cb_hit_check      equ     6038h   ; hit / collision query
fight_cb_despawn        equ     603Ah   ; despawn slot
