# Per-boss state-machine reference

Companion to BOSS_AI.md (architecture + TAKO worked-example).  This
doc catalogs the state-variable inventory for each of the remaining
9 bosses, so a reader knows which bytes drive each boss's behavior
and where in source to look for the dispatch logic.

Each boss chunk in `working/zelres3/code/` follows the same template:
1. File-internal data tables (animation sequences, frame ptrs)
2. Boss-specific state variables (phase, sub-phase, anim, dir flags)
3. `run_<boss>_main` far entry (called from 200FIGHT boss-fight
   dispatch on arena entry)
4. Per-frame `scan_slot_loop` over the fight slot list
5. Callbacks into 200FIGHT's `fight_cb_*` dispatch slots
   (prep/anim_step/hit_check/record_ofs)
6. Death-anim chain → `gvar_death_flag` → `fight_cb_shutdown`

Per-state graphs (which state transitions to which on what input)
are NOT enumerated below — those require per-chunk runtime tracing.
The variable inventory + entry-proc citation is the starting point
for that work.

For TAKO worked example see BOSS_AI.md §"TAKO worked example".

---

## CRAB (Cangrejo) — 309CRAB.asm

**Arena**: Muralla cavern (area 1).  **Spanish**: cangrejo = crab.

| Variable | Addr | Purpose |
|---|---:|---|
| `fight_hp` | 0xA7C3 | Current boss HP |
| `crab_spawn_limit` | 0xA481 | Max simultaneous crab-minion spawns |
| `crab_phase_base` | 0xA7C5 | Phase-base byte (current phase index) |
| `crab_phase_limit` | 0xA7C6 | Phase-limit byte (max phase number) |
| `crab_state_bits` | 0xA7DD | Packed state bits (bit 7 = death-imminent gate) |
| `crab_slot_idx` | 0xA7DC | Current slot index in scan |
| `crab_frame_idx` | 0xA7DE | Frame index (0..5) |
| `crab_flag_d` | 0xA7DF | Phase selector flag |
| `crab_dir_flag` | 0xA7E0 | Direction (left/right) |
| `crab_sub_phase` | 0xA7E1 | Sub-phase counter |
| `crab_flag_g` | 0xA7E2 | Activity flag (gate spawn_subloop at loc_24) |
| `crab_flag_h` | 0xA7E3 | Persistent spawn counter (cap=8) |
| `crab_alt_phase` | 0xA7E4 | Alt-phase flag (idle/alternate) |
| `crab_anim_idx` | 0xA7E6 | Animation step index |
| `crab_anim_frame` | 0xA7E7 | Current animation frame |
| `crab_anim_base` | 0xA7EA | Animation base (word ptr) |

**Entry**: `run_crab_main` (line 102).  Self-contained — has own AI
and own sprite frame data (frames_body_walk0..5, descent0..2,
recoil0..2, hit, dead).  NOT paired with 301EAI1.

**Spawn behavior**: Each pass increments `crab_flag_h`; max 8
simultaneous (line 590).  `crab_flag_g` gates the spawn subroutine.

---

## TAKO (Octopus) — 310TAKO.asm

See BOSS_AI.md §"TAKO worked example" — fully documented.

---

## TORI (Bird) — 311TORI.asm

**Arena**: Satono cavern.  **Spanish**: pollo = chicken, but TORI is
Japanese for bird (Game Arts Japanese internal name).

| Variable | Addr | Purpose |
|---|---:|---|
| `tori_hp` | 0xA773 | Current boss HP |
| `tori_dir_state` | 0xA78A | Direction state byte |
| `tori_phase_a` | 0xA78B | Phase byte A |
| `tori_glide_flag` | 0xA78C | Gliding-active flag |
| `tori_sub_phase` | 0xA78D | Sub-phase counter |
| `tori_attack_flag` | 0xA78E | Attack-mode flag |
| `tori_turn_flag` | 0xA790 | Turning flag |
| `tori_anim_state` | 0xA793 | Animation state byte |
| `tori_anim_timer` | 0xA795 | Anim-timer byte |

**Behavior**: glide-swoop attack — `tori_glide_flag` controls
horizontal sweep; `tori_attack_flag` gates dive at player.

---

## ZELA — 312ZELA.asm

**Arena**: Bosque village area.  Demonic plant-like boss.

| Variable | Addr | Purpose |
|---|---:|---|
| `zela_scroll_phase` | 0xA5F0 | Scroll phase counter byte |
| `zela_tile_phase` | 0xA603 | Tile phase counter (mod 8) |
| `zela_walk_state` | 0xA604 | Walk/state flag byte |
| `zela_phase_started` | 0xA605 | Phase-started flag |
| `zela_phase_active` | 0xA606 | Phase-active flag |
| `zela_phase_subflag` | 0xA607 | Phase sub-flag |
| `zela_phase_step` | 0xA608 | Phase step counter |
| `zela_phase_subcnt` | 0xA609 | Phase sub-counter |

**Pattern**: Two-byte phase encoding (active flag + sub-flag) lets
ZELA chain through multi-step attack patterns.

---

## MEDA — 313MEDA.asm

**Arena**: Helada cavern (ice area).

| Variable | Addr | Purpose |
|---|---:|---|
| `meda_anim_xlat_tbl` | 0xA6ED | Per-state animation xlat table |
| `meda_cell_phase` | 0xA6E1 | Cell phase byte |
| `meda_scroll_phase` | 0xA718 | Scroll phase counter byte |
| `meda_phase_dir` | 0xA72F | Phase direction selector |
| `meda_phase_step` | 0xA730 | Phase step counter (mod 5) |
| `meda_anim_byte` | 0xA732 | Current animation/speaker byte |
| `meda_phase_active` | 0xA734 | Phase-active flag |
| `meda_phase_subflag` | 0xA735 | Phase sub-flag |

---

## LEGA — 314LEGA.asm

**Arena**: Tumba cavern (graveyard).

| Variable | Addr | Purpose |
|---|---:|---|
| `lega_anim_dx_tbl` | 0xA5D8 | Per-phase ΔX table base |
| `lega_anim_dy_tbl` | 0xA5D9 | Per-phase ΔY table base |
| `lega_phase_xlat_a` | 0xA69B | Phase-A xlat table (xlat-indexed) |
| `lega_phase_xlat_b` | 0xA6BC | Phase-B xlat table |
| `lega_npc_state_a` | 0xA41F | Cell-state scan table A (5 bytes, scasb) |
| `lega_npc_state_b` | 0xA424 | Cell-state scan table B (5 bytes, scasb) |
| `lega_scroll_phase` | 0xA7A2 | Scroll phase counter byte |

**Pattern**: Dual scan tables (A/B) — LEGA likely splits into two
sub-bosses that share the chunk.

---

## ZEL2 — 315ZEL2.asm

**Arena**: Dorado cavern (gold caverns).  "Zela mark 2" — upgraded
form of ZELA.

| Variable | Addr | Purpose |
|---|---:|---|
| `zel2_state_ff30` | 0xFF30 | Per-map state flag (idle-out marker) — overlays gvar_completion |
| `zel2_anim_dispatch_tbl` | 0xA2F8 | Per-anim dispatch table base (call ds:[base+bx]) |
| `zel2_phase_xlat_tbl` | 0xA4DB | Phase xlat / index table base |
| `zel2_anim_state_a` | 0xA32F | Anim state slot A (word, AND-masked to 0x2FA3 bit pattern) |
| `zel2_anim_state_b` | 0xA334 | Anim state slot B (via [bp+di]) |
| `zel2_anim_state_c` | 0xA339 | Anim state slot C (word) |
| `zel2_anim_seg_a` | 0xA543 | Anim segment slot base (idx*0Dh added) |

**Pattern**: 13-byte stride per anim segment (idx × 0x0D) — likely
each segment holds {x, y, frame, type, ...} for sub-component sprites.

---

## DRGN (Dragon) — 316DRGN.asm

**Arena**: Llama cavern.  Spanish/draconic boss.

| Variable | Addr | Purpose |
|---|---:|---|
| `gvar_state_ff30` | 0xFF30 | Per-map state byte (overlay of gvar_completion) |
| `drgn_phase_si_tbl` | 0xA783 | SI per-phase table base (indexed by `drgn_phase_dir<<1`) |
| `drgn_phase_bp_tbl` | 0xA810 | BP per-phase table base |
| `drgn_phase_si_tbl_b` | 0xA881 | SI per-phase table B (`drgn_phase_substep<<1`) |
| `drgn_phase_bp_tbl_b` | 0xA89A | BP per-phase table B |
| `drgn_phase_si_tbl_c` | 0xA8B7 | SI per-phase table C (mid-stage) |
| `drgn_phase_si_tbl_d` | 0xA8DE | SI per-phase table D (`drgn_phase_step&1<<1`) |
| `drgn_phase_bp_tbl_d` | 0xA8FD | BP per-phase table D |

**Pattern**: 4 pairs of SI/BP per-phase tables (A/B/C/D) — DRGN has
4 distinct attack patterns, each phase swaps the table pair used
for the per-frame render+move dispatch.

---

## AKMA — 317AKMA.asm

**Arena**: Pureza cavern (acid pools, requires Asbestos Cape).

| Variable | Addr | Purpose |
|---|---:|---|
| `gvar_state_ff30` | 0xFF30 | Per-map state byte |
| `akma_phase_si_tbl_a` | 0xA7EE | SI per-phase tbl A (phase-A render path) |
| `akma_phase_di_tbl_a` | 0xA870 | DI per-phase tbl A |
| `akma_phase_si_tbl_b` | 0xA918 | SI per-phase tbl B (active-mode swap) |
| `akma_phase_si_tbl_c` | 0xA940 | SI per-phase tbl C (mid-stage) |
| `akma_anim_byte` | 0xAA1F | Current animation/speaker byte |
| `akma_phase_dir` | 0xAA20 | Phase direction byte |
| `akma_phase_active` | 0xAA21 | Phase active flag |

---

## MAO1 (Demon Form 1) — 318MAO1.asm

**Arena**: First Jashiin encounter (penultimate boss).  Spanish-style
demon-king transformation form.

| Variable | Addr | Purpose |
|---|---:|---|
| `mao1_gvar_state_byte` | 0xFF75 | Global state byte (per-map; shared with gvar_spawn_fx_flag) |
| `mao1_phase_tbl_a39f` | 0xA39F | Phase table base A |
| `mao1_phase_tbl_a3bb` | 0xA3BB | Phase table base B |
| `mao1_phase_di_tbl` | 0xA495 | DI per-phase table |
| `mao1_phase_bp_tbl` | 0xA52F | BP per-phase table |
| `mao1_phase_dir` | 0xA59A | Phase direction byte (BL-saved cell attr) |
| `mao1_phase_step` | 0xA59B | Phase step counter (incremented per-frame) |
| `mao1_phase_substate` | 0xA59C | Phase substate (xlat result, signed dispatch) |

---

## MAO2 (Demon Form 2 / Final) — 319MAO2.asm

**Arena**: Final Jashiin form.  Multi-component boss with dialog state.

| Variable | Addr | Purpose |
|---|---:|---|
| `mao2_drv_anim_cb` | 0x2F2E | Driver callback (boss anim) |
| `mao2_gvar_state_a` | 0xFF21 | Module-local state byte A |
| `mao2_gvar_state_b` | 0xFF2E | Alias for `gvar_death_flag` |
| `mao2_gvar_state_c` | 0xFF2F | Global state byte C |
| `mao2_gvar_phase_byte` | 0xFF75 | Alias for `gvar_spawn_fx_flag` (zr3com.inc canonical) |
| `mao2_phase_ofs_tbl` | 0xA46F | Per-phase substate offset xlat table |
| `mao2_handler_step_tbl` | 0xA666 | Phase-handler 3-byte step table base |
| `mao2_dlg_state_word_a` | 0xA8A9 | Dialog-state word (trailer-data region) |

**Pattern**: 3-byte step table (handler_step_tbl) — each entry is
likely `{action_op:BYTE, param1:BYTE, param2:BYTE}` driving a
3-instruction step in the death-of-Jashiin cinematic sequence.

---

## Common boss-side dispatch pattern

Every boss chunk implements the same per-frame scan:

```asm
scan_slot_loop:
    mov si, fight_slot_list             ; ES:SI = enemy slot array (0xC010 in fight engine)
slot_loop_body:
    cmp byte ptr [si], 0FFh             ; FF = terminator
    je scan_done
    call word ptr cs:fight_cb_prep      ; CS:[200C] → 200FIGHT prep callback
    test byte ptr [si+5], 80h           ; alive bit
    jz next_slot
    ; ... per-boss state dispatch (uses {boss}_phase, {boss}_anim, {boss}_dir bytes)
    call word ptr cs:fight_cb_anim_step ; CS:[6036] → anim tick
    call word ptr cs:fight_cb_hit_check ; CS:[6038] → check sword strike marker
    ; ... per-boss damage/death handling
    call word ptr cs:fight_cb_record_ofs; CS:[6028] → record render offset
next_slot:
    add si, 0x10                        ; 16B slot stride
    jmp scan_loop_body
scan_done:
    ret
```

The per-boss differences are in:
- State variable byte addresses (catalogued above)
- Phase-table SI/DI/BP lookups (per-phase action selection)
- Per-attack frame data (sprite source bytes in trailing data)
- Death-anim chain (length + frame sequence)

---

## Next steps (deferred RE work)

For each boss to upgrade from "variable inventory" to "full state
graph" requires:

1. Identify all distinct values written to phase/substate bytes
2. Identify all `cmp <phase>, N; je/jne <state_label>` chains
3. Document trigger conditions for state transitions (HP threshold,
   sub-phase counter, frame count, hit-marker received)
4. Cross-reference with playthrough notes for which attacks correspond
   to which state values

Each boss is ~2-4 hours of per-chunk RE work.  TAKO is the worked
example in BOSS_AI.md; replicate that depth for any boss that needs
porting.
