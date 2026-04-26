# Zeliard ASM Cleanup Roadmap

Remaining work to make the disassembled source as close to the original TASM/MASM source as the 1989-1990 Game Arts developers would have written it.

**Invariant for every step**: all 63 .asm files must remain bit-perfect against `bin/` references. Verify after each batch with:

```bash
cd 3_Assembly/tasm
python verify1.py <subpath>/file.asm   # single file
# OR full sweep:
for f in working/{core,drivers,zelres1/code,zelres2/code,zelres3/code}/*.asm; do
    out=$(python verify1.py "${f#working/}" 2>&1 | tail -1)
    echo "$out" | grep -q "BIT-PERFECT" || echo "FAIL: $f -- $out"
done
```

---

## High-fidelity items (closest to original-dev style)

### Item 1 — Apply db-review pass to zelres1 + zelres2

**Status:** done for zelres3 (20 files). zelres1 (12 files) and zelres2 (15 files) still in baseline state with hundreds of bare `db` lines.

**Goal:** every `db` line must be either an alt-encoding with comment, sprite/bitmap data inside a labeled block with `; row N` comments, a labeled lookup table, a string/dup, or explicitly annotated as unexplainable.

**Process per file:**
1. `python verify1.py <path>` → BIT-PERFECT baseline
2. Find labels wrapping multi-type content; split at boundaries (frame ptrs vs frame data, code vs trailing data, etc.)
3. For sprite/tile data, group by frame using existing pointer tables to find frame-start addresses
4. Add per-row `; row N` comments to bare lines
5. Verify after each batch
6. Final grep — must return 0:
   ```bash
   awk '/^[[:space:]]+db[[:space:]]+/ { if (!/;/ && !/dup/ && !/\047/) print }' <file> | wc -l
   ```

**Reference for style:** any zelres3 file post-cleanup, e.g. [301EAI1.asm](zelres3/code/301EAI1.asm), [310TAKO.asm](zelres3/code/310TAKO.asm).

**Per-file priority** (highest db-line count first):
- zelres2: 200FIGHT, 215DRUGP, 213BANKP, 217KENJP, 212ARMRP, 216INNAP, 211OMOYP, 214CHURP, 210KINGP, 201SELCT, 207MOLEB, 208SATNO, 209BOSQE, 236CMAP, 239BSMP, 250ENDMO
- zelres1: 100OPDMO, 101GDEGA, 102GDCGA, 103GDHGC, 104GDTGA, 105GDMCA, 106TOWN, 107GTEGA, 108GTCGA, 109GTHGC, 110GTTGA, 111GTMCA

**Effort:** ~10-30 min per file via agent. ~12 hours total.

**Risk:** low. Mechanical work; bit-perfect check catches any byte-level mistake.

---

### Item 2 — `proc near` / `endp` wrapping

**Status:** ~2 files have no proc/endp; many use bare `:`-style labels for what should be procedures.

**Goal:** every callable function wrapped in:
```asm
foo_bar         proc    near
                ; ... body ...
                retn
foo_bar         endp
```

Original TASM/MASM idiom; gives function-scope visibility when reading.

**Process per file:**
1. Identify each label that's a call target (search for `call X` references)
2. Convert label → `proc near` block ending at the next `retn` or fall-through boundary
3. Add `endp` and update consumers if the proc/label name changed
4. Verify bit-perfect (proc/endp emit no bytes; only labels do)

**Caveat:** labels reached via `jmp` or fall-through (not `call`) should stay as bare labels — they're not separate procedures.

**Effort:** ~5-15 min per file via agent.

**Risk:** low. Labels and procs assemble identically; just metadata.

---

### Item 3 — Strip remaining Sourcer SUBROUTINE banner boilerplate

**Status:** 5 files still contain non-ASCII `;████████████████████████████` separator blocks Sourcer emits.

**Goal:** all 5 files cleaned. Find with:
```bash
grep -l "SUBROUTINE" working/{core,drivers,zelres1/code,zelres2/code,zelres3/code}/*.asm
```

**Process:**
- `fmt_asm.py` is supposed to handle this — investigate why it missed these
- Manual delete of the 3-line banner blocks if fmt_asm can't be fixed
- Replace with single-line section banner like `; --- function name ---`

**Effort:** ~30 min total.

**Risk:** none — comment-only edits.

---

### Item 4 — Module-header cross-reference summaries

**Status:** every file has a header describing what the module IS; few describe its CONNECTIONS.

**Goal:** each header has a "Connections" section listing:
- `Calls into:` other chunks via shared dispatch slots (`fight_cb_record_ofs`, `script_step`, etc.)
- `Called by:` who invokes this chunk (DS-resident dispatch tables, jmp targets, etc.)
- `Loads:` which other chunks it pulls via SAR loader
- `Reads/writes:` which `gvar_*` globals

**Example template:**
```asm
;==========================================================================
;
;  309CRAB.BIN - Crab Enemy Sprite/Logic Module
;
;  Loaded by 200FIGHT (zelres2 ch1) into game_seg via SAR chunk loader.
;
;  Connections:
;    Calls into:  fight_cb_record_ofs (0x6028) for tile→record mapping
;                 fight_cb_anim_step  (0x6036) for animation tick
;                 fight_cb_hit_check  (0x6038) for collision queries
;                 fight_cb_despawn    (0x603A) for slot cleanup
;    Called by:   200FIGHT enemy AI dispatch table (DS-resident at runtime)
;    Loads:       (none directly — sprite frames reside in this chunk)
;    State:       fight_slot_list (DS:0xC010), fight_state_max (DS:0xC002),
;                 sprite_xlat_tbl (DS:0xED20)
;
;==========================================================================
```

**Effort:** ~5-10 min per file (mostly mechanical scan for `call ds:[fight_cb_*]`, then summarize). 63 files = ~6-10 hours.

**Risk:** none — comment-only.

---

## Medium-fidelity items

### Item 5 — Strip "; was loc_N" cross-reference comments

**Status:** 3 files have lingering breadcrumbs. Originally added to track renames; no longer useful.

**Find:**
```bash
grep -l "; was loc_" working/{zelres1,zelres2,zelres3}/code/*.asm
grep -nc "; was loc_" $files
```

**Process:** sed replace `\s*;\s*was\s+loc_[a-f0-9]+\s*$` → empty line. Run fmt_asm to collapse blank lines.

**Effort:** 10 min total.

**Risk:** none.

---

### Item 6 — Per-file fmt_asm.py pass

**Status:** files have inconsistent blank-line spacing, some leftover from agent edits.

**Process:** run `fmt_asm.py` on every file:
```bash
for f in working/{core,drivers,zelres1/code,zelres2/code,zelres3/code}/*.asm; do
    python fmt_asm.py "$f"
done
# then full verify1.py sweep
```

**Effort:** 30 min including verify.

**Risk:** low — fmt_asm only edits whitespace/comments. Verify catches any byte change.

---

### Item 7 — EQU section ordering within each file

**Status:** within a single file, EQU declarations are scattered: shared-include refs interleaved with local data EQUs interleaved with constants.

**Goal:** organize each file's EQUs into stable sections in this order:
1. `target equ 'T2'` + includes
2. Module-local exports (anything other modules might want to know about — though none currently do)
3. Game-segment globals (gvar_*) — NOTE: most should now come from zr*com.inc; only file-specific gvar_* here
4. Shared dispatch slot references (NOTE: usually now in inc; only file-local overrides)
5. File-internal data table addresses (label-based EQUs, sometimes mid-file)
6. File-internal state variables (per-module byte/word state)
7. Constants (numeric literals, control codes)

**Process per file:**
1. Read all EQUs
2. Categorize each
3. Reorder into 7 sections with banner comments
4. Verify bit-perfect

**Effort:** ~10-15 min per file. 63 files = 10-15 hours.

**Risk:** medium. EQU order matters when one EQU references another (`X equ Y + 4`); reordering must respect dependency. Use a topological sort.

---

### Item 8 — Macro factoring within files

**Status:** many files repeat 3-5-instruction sequences without macros (e.g. EAI handler dispatch preroll, fight callback wrappers).

**Goal:** factor sequences appearing 3+ times in a file into a local macro defined at top.

**Common patterns to look for:**
- LOAD_CHUNK_REF-like wrappers
- Dispatch-table jump prologue (`mov bl, [si+N]; and bl, 0Fh; xor bh, bh; add bx, bx; jmp [...]`)
- Hit-check + despawn sequences

**Process per file:**
1. Scan for repeated 3+ instruction sequences
2. Define macro at file top (after EQUs)
3. Replace each occurrence (must produce same byte output)
4. Verify bit-perfect

**Effort:** ~15-30 min per file where applicable. Maybe 30 of 63 files have factorable patterns.

**Risk:** medium. Macros must produce IDENTICAL byte output. Operand order, register usage, addressing mode all matter.

---

## Low-priority items

### Item 9 — Sprite/animation semantic decoding

**Status:** sprite data labeled as `tako_frame_NN ; row N` — positional only.

**Goal:** annotate each frame with its semantic role (walk/attack/death/etc.) by tracing pointer-table indices into game logic.

**Process per chunk:**
1. Find which dispatch states load each frame (e.g., `dispatch_phase[0]` → frame 03)
2. Find which game state activates each dispatch state (idle/walk/attack/etc.)
3. Annotate frame label with role

**Effort:** ~30-60 min per sprite-bearing file. ~10 sprite modules = 5-10 hours.

**Risk:** none — comment-only.

**Priority:** low. Original devs had separate art-tool source files; they wouldn't have annotated bytes.

---

### Item 10 — Document state machines in EAI handlers

**Status:** EAI handlers have N-state dispatch (state_bit0..3 × sub01..sub04). Logic is decodable but not documented.

**Goal:** each EAI handler has an ASCII-art state diagram in the header showing transitions:

```
;  State machine for crab AI:
;
;     ┌─────┐  visible    ┌─────────┐
;     │ s00 │ ──────────→ │ s02_atk │ ──┐
;     └──┬──┘             └─────────┘   │
;        │ hit_check                    │ despawn
;        ↓                              ↓
;     ┌─────┐                       ┌────────┐
;     │ s01 │                       │ s_dead │
;     └─────┘                       └────────┘
```

(or simpler text-only transition tables)

**Effort:** ~30-60 min per EAI handler. 8 handlers = 4-8 hours.

**Risk:** none — comment-only.

**Priority:** low-medium. Improves reader onboarding significantly.

---

### Item 11 — Global symbol cross-reference (.MAP-like)

**Status:** no global directory of which file defines which symbol.

**Goal:** generate a `working/SYMBOL_INDEX.md` listing every label/EQU, where defined, where called from. Like a TASM `.MAP` file but for cross-file.

**Process:** Python script walking all .asm files, parsing labels/EQUs, indexing call sites. Auto-regenerated; checked into the repo as a static reference.

**Effort:** ~2 hours one-time + regenerate as needed.

**Risk:** none — pure documentation.

**Priority:** low. Original devs didn't have one; useful to us as RE aid.

---

## Suggested execution order

If working through this systematically with bit-perfect at every step:

1. **Item 6** (fmt_asm pass) — quick clean baseline. 30 min.
2. **Item 5** (strip "was loc_N") — 10 min.
3. **Item 3** (Sourcer banner cleanup) — 30 min.
4. **Item 1** (db-review on zelres1 + zelres2) — 12 hours, biggest impact. Do this with parallelizable agent batches.
5. **Item 2** (proc/endp wrapping) — 5-10 hours. After db-review so labels are stable.
6. **Item 4** (module-header cross-references) — 6-10 hours. After dispatch standardization is final.
7. **Item 7** (EQU section ordering) — 10-15 hours. Needs care w/ dependency sort.
8. **Item 8** (macro factoring) — 5-10 hours. After everything else stable.
9. **Item 11** (symbol index generator) — 2 hours one-time tool.
10. **Item 9 + 10** (semantic decoding) — optional polish, 10-20 hours.

**Total realistic effort to "looks like original developer source":** 50-80 agent-hours, mostly parallelizable.

---

## What NOT to do (would HURT fidelity to original)

- **Do not add `EXTRN`/`PUBLIC` declarations.** The original devs didn't TLINK chunks together — each compiled to its own .bin and runtime dispatch handled cross-file calls. Adding linker artifacts would diverge from the actual game build model.
- **Do not retain "; was loc_N" or "; (alt-encoding: …)" comments long-term.** These are RE breadcrumbs, not original-dev style. Keep only "what / why" comments.
- **Do not rewrite numeric data tables as `dw`/`dd` constants when the original was clearly hand-laid `db` tile data.** The byte-level layout matters.
- **Do not unify modules into one mega-file.** Each chunk corresponds to a SAR archive entry — that file boundary is part of the architecture.
