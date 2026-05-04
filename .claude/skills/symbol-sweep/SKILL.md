---
name: symbol-sweep
description: Cross-file symbol audit and bulk hardcoded-reference cleanup for the Zeliard tasm source. Picks up where /asm-cleanup (per-file) and /label-audit (per-address) leave off — sweeps related symbols across many chunks at once, detects drift between speculative names, replaces raw `ds:[NNh]`/`cs:[NNNh]` operands with symbolic EQUs, maps driver dispatch slots, and resolves conflicting evidence between chunks. Use when many chunks reference the same address with different speculative names, when a chunk has dozens of unresolved hardcoded operands, or when you need to consolidate an entire driver-dispatch table or player-record byte map.
---

You are running a symbol-sweep across the Zeliard tasm source.  This is the
**multi-file** companion to two earlier skills:

- `/asm-cleanup` cleans **one file at a time** — Sourcer artefacts, db
  decoding, label renaming inside a chunk.
- `/label-audit` resolves **one address at a time** — finds the canonical
  name, alias EQUs, and rewrites use sites for that single address.

Symbol-sweep handles work that neither of those covers cleanly:

- **Cross-file symbol drift** — same address referenced by 4 different
  speculative names in 4 different chunks.  No single label-audit run
  catches them all because they're spread across files.
- **Bulk hardcoded-reference replacement** — a chunk has 200+ raw
  `ds:[NNh]` and `cs:[NNNh]` operands and you want to replace them all
  with symbolic EQUs in one pass, across many chunks at once.
- **Driver dispatch tables** — `cs:[10Ch]`, `cs:[110h]`, ... `cs:[120h]`
  are stick.bin INT 60h game-state slots; `cs:[2000h]`..`cs:[2044h]`
  are graphics-driver function pointers.  Mapping every slot at once
  is more efficient than auditing each address individually.
- **Cross-include propagation** — when an EQU is added to one shared
  `.inc`, deciding which other shared includes it also needs to land in.
- **Conflicting evidence resolution** — when two chunks operate on the
  same byte and imply different semantics (e.g. 200FIGHT
  damage-absorption vs 201SELCT icon-draw both reading `[93h]`), pick
  the canonical interpretation by ranking evidence weight.

Verification is the same two-tier system as the prior skills:

1. **Per-edit** — `python verify1.py <changed-file.asm>` after every batch.
2. **End-of-batch** — `python build_all.py --verify` once at the end.
   Required output: **all 3 SARs BIT-PERFECT**.

---

## Step 0 — Decide the sweep scope

Symbol-sweeps come in five common shapes.  Identify which one you're
running before doing anything else — the workflow differs.

| Shape | Trigger | Example |
|---|---|---|
| **Player-record sweep** | Want every byte of player record (game_seg:0x80..0xE8) to have a canonical name across all chunks that touch it | The `shield_type/shield_HP/shield_max_HP` pass at 0x93/94/95 |
| **gvar_* sweep** | Want to confirm every game-segment global (FF00..FFFF) name is consistent against the canonical `.inc` | The "audit all gvars in game.asm" pass |
| **Driver-dispatch sweep** | Want every slot in a function-pointer table named after the proc it points to | The stick.bin `cs:[10Ch..120h]` slot mapping |
| **Hardcoded-ref sweep** | A chunk has many raw `ds:[NNh]`/`cs:[NNNh]` operands → want them all symbolic | The 200FIGHT `~250 hardcoded refs` cleanup |
| **Placeholder-proc sweep** | A chunk has many auto-generated `loc_NN`, `proc_NN`, `game_func_NN` labels | The 200FIGHT 51-proc rename |

For each shape, the inventory step is different (Step 1).  The remaining
steps (evidence, rename, propagate, verify) are mostly the same.

State the shape explicitly to the user when you start a sweep, and quote
the inventory size: "Player-record sweep: 14 unresolved bytes across
0x80..0xE8" or "Hardcoded-ref sweep: 247 raw operands in 200FIGHT.asm".
This sets expectations on how big the change will be.

---

## Step 1 — Inventory

Run the right inventory tool for the sweep shape.

### 1a — Player-record / gvar sweep

```bash
cd 3_Assembly/tasm
python find_missing_equs.py
```

Open `working/MISSING_EQUS.md`.  The "MISSING" section lists raw-hex
operands without an EQU; the "UNUSED" section lists EQUs that exist but
nothing references symbolically.  Both are leverage points.

For specifically the gvar range (FF00..FFFF):

```bash
grep -rEn '\b0?FF[0-9A-Fa-f]{2}h\b' 3_Assembly/tasm/working \
  | grep -vE '\bequ\b' \
  | grep -vE '^\S*\.(inc|asm):\s*(db|dw|dd)\b' \
  > /tmp/raw_gvar_refs.txt
```

Count distinct addresses:

```bash
grep -oE '0?FF[0-9A-Fa-f]{2}h' /tmp/raw_gvar_refs.txt | sort -u | wc -l
```

### 1b — Driver-dispatch sweep

The function-pointer table lives in the driver's source (`stick.asm` for
INT 60h slots, `gm*.asm` for graphics slots).  Find the table:

```bash
grep -nE '^\s*driver_init_data|^\s*dispatch_tbl|^\s*fn_table' \
     3_Assembly/tasm/working/drivers/*.asm
```

Read the table's `dw` entries — each entry is a near-pointer to a proc
in the same segment.  The slot index → proc mapping is what you'll use
to rename `cs:[NNh]` references in the chunks that call into the driver.

### 1c — Hardcoded-ref sweep (single chunk)

Pick the busiest patterns first — ranking by frequency tells you where
the readability win is biggest:

```bash
grep -oE '(ds|cs|es|ss):\[0?[0-9A-Fa-f]+h\]' \
     3_Assembly/tasm/working/zelres2/code/200FIGHT.asm \
  | sort | uniq -c | sort -rn | head -40
```

The output gives you a ranked list of `(count, operand)` pairs.  Plan
the rename in descending-count order — high-count operands have the
largest readability impact and the smallest risk because their semantic
role is over-determined by the volume of evidence.

### 1d — Placeholder-proc sweep

```bash
grep -nE '^(loc|proc|sub|game_func)_[0-9]+\s+(proc|:|\bnear\b)' \
     3_Assembly/tasm/working/<chunk>.asm \
  | head -100
```

Tabulate them with their **callers** (one grep per name):

```bash
for n in $(grep -oE '^(loc|proc|sub|game_func)_[0-9]+' <chunk>.asm | sort -u); do
  count=$(grep -cE "\b$n\b" <chunk>.asm)
  echo "$count  $n"
done | sort -rn
```

Procs called from many sites are higher value to rename — their name
shows up in many places once renamed.  Procs called from one site are
lower priority but should still be done if their behaviour is clear.

---

## Step 2 — Detect symbol drift

For each address in the inventory, list **every name** that resolves to
it across the codebase.

```bash
HEX=93   # the address you're investigating
grep -rnE "^\s*\w+\s+equ\s+0?${HEX}h\b" 3_Assembly/tasm/working
```

Tabulate the hits.  Classic drift looks like:

```
0x93 names found:
  shield_type            stdply.inc:142   ; canonical (matches DOS overlay)
  equipped_magic         zr2com.inc:88    ; misnomer — only set in 201SELCT
  player_ability_a       zr1com.inc:54    ; misnomer — alias from a wrong functest probe
  stat_X93               zr2com.inc:171   ; placeholder
```

When 3+ names resolve to the same address, you have drift.  Don't
rename anything yet — go to Step 3 to weigh evidence.

**A symptom of recent drift**: a name that exists in only one `.inc`
and is referenced by zero `.asm` files outside that include's scope.
That name is almost certainly a guess from a single chunk's narrow
view; the canonical name lives elsewhere.

---

## Step 3 — Weight the evidence

Not all evidence is equal.  When two chunks imply different semantics
for the same byte, rank the evidence types:

| Evidence type | Weight | Example |
|---|---|---|
| **Damage / arithmetic / state-write that drives gameplay** | Highest | `apply_combat_damage_with_absorb` reads `[93h]`, conditionally subtracts from `[94h]`, writes back |
| **FSM transitions in main game loop** | Highest | `[E7h]` switches on `cmp [0E7h], 80h` across 5 driver chunks |
| **Set/test/clear cycle inside one function** | High | `bg_save` sets `[FF44h]`, `bg_restore` tests/clears it |
| **Address used as table index / dispatch key** | High | `mov bx, [9Ah]; jmp [bx*2 + dispatch_tbl]` |
| **Counter / wrap-around comparison** | Medium | `inc [80h]; cmp [80h], map_width; jne …` |
| **Icon-draw / text-format / display read** | Low | 201SELCT reads `[93h]` to pick which icon to draw — only proves it's *some* index, not which one |
| **Single zero-init in a "clear all flags" sequence** | None | A reset path that writes 0 to dozens of bytes proves nothing |
| **User testimony alone** | None | "I think this is the magic stat" — still needs an asm trace |

**The decisive case from this codebase**: at byte 0x93, both
`apply_combat_damage_with_absorb` (200FIGHT) and `draw_abilities`
(201SELCT) read the byte.  The combat path *modifies* `[94h]` based
on the value at `[93h]` — that's load-bearing semantics.  The selcт
path uses `[93h]` to pick an icon — that just proves it's an index.
Combat path wins; the byte is `shield_type`, not `equipped_magic`.

When you adopt the winning name, retain the loser as a deprecated
alias EQU **with a comment explaining why it was wrong** — so a future
reader doesn't re-litigate the same conflict.

```asm
shield_type      equ  93h     ; type of equipped shield (drives damage absorb in 200FIGHT)
equipped_magic   equ  93h     ; alias — deprecated; was a misread of 201SELCT's icon-draw use
```

---

## Step 4 — Validate against indirect access

Static analyzers can miss a use site if the code reaches the byte
**indirectly** — through SI/DI/BX after a `lea` or arithmetic, or
through a structure offset.  Before declaring a byte vestigial, run a
broader probe.

### 4a — Direct grep (catches `mov al, ds:[NNh]` etc.)

```bash
grep -rEn "(ds|cs|es|ss):\[0?<HEX>h\]" 3_Assembly/tasm/working
```

### 4b — `lea` / pointer-load grep

```bash
grep -rEn "\b(lea|mov)\s+\w+\s*,\s*(\[)?<HEX>h" 3_Assembly/tasm/working
```

If the address is the target of a `lea bx, [93h]` followed by indirect
reads through `[bx]`, the direct grep misses it.  Also check for
`mov si, OFFSET <known_label_at_or_near_addr>` — scrolling past via SI
also escapes the direct grep.

### 4c — Range-of-bytes probe via Unicorn

Use `functest/harness.py` to set up a representative call into a
suspect proc with controlled register/memory state, then read which
bytes it touches.  This is the gold standard for "does anything in
this function actually touch byte X?"

The point: **"VESTIGIAL — no reader" claims are wrong about 30% of
the time** in this codebase because the reader uses `lodsb` or
`mov al, [si+offset]` after SI was set elsewhere.  Always run 4a/4b
before claiming vestigial; run 4c if the static evidence is split.

---

## Step 5 — Apply the renames

The order of operations matters because of `replace_all` prefix
collisions.  This is the most common source of broken builds during
a sweep.

### 5a — Reverse-numeric order for prefix-overlapping labels

If you're renaming `loc_3` and also `loc_30`, `loc_31`, ..., `loc_39`,
**rename `loc_3` LAST**.  Otherwise the `replace_all` for `loc_3`
clobbers references to `loc_30..loc_39` because the substring `loc_3`
appears inside them.

```python
# WRONG — clobbers loc_30..loc_39 references
for n in [3, 30, 31, 32, 35]:
    edit.replace_all(f"loc_{n}", new_names[n])

# RIGHT — descending numeric order
for n in [35, 32, 31, 30, 3]:
    edit.replace_all(f"loc_{n}", new_names[n])
```

The same pattern hits any `prefix_N` family where N spans single and
multi-digit values: `game_func_7` collides with `game_func_70..79`,
`proc_1` collides with `proc_10..19` and `proc_100..199`.

If the names span multiple orders of magnitude (`proc_1` and
`proc_100`), consider using a regex with a word-boundary or
end-of-line anchor instead of `replace_all`:

```python
# Match loc_3 only when followed by non-digit (end of token)
re.sub(r'\bloc_3(?!\d)', new_name, content)
```

### 5b — Bracket sensitivity in TASM

These two are NOT equivalent in TASM 2.01 emitted bytes:

```asm
mov word ptr ds:boss_entry_tbl, ax       ; (no brackets)
mov word ptr ds:[boss_entry_tbl], ax     ; (with brackets)
```

The first form sometimes emits a different ModR/M byte than the second.
**Always preserve the original brackets** when rewriting raw-hex
operands to symbolic operands:

```asm
; Original
mov word ptr ds:[0EB15h], ax

; Correct rename (brackets preserved)
mov word ptr ds:[boss_entry_tbl], ax

; INCORRECT — drops brackets, may change emitted bytes
mov word ptr ds:boss_entry_tbl, ax
```

If `verify1.py` reports a 1-2 byte mismatch right after a sweep, this
is the first thing to check.

### 5c — Cross-include propagation

Adding an EQU to one `.inc` doesn't make it visible to chunks that
include a different `.inc`.  Map the include relationships before you
edit:

```
working/drivers/stdply.asm        → includes stdply.inc, zeliard.inc
working/drivers/gm*.asm           → includes stdply.inc, srmacros.inc
working/zelres1/code/100OPDMO.asm → includes zr1com.inc
working/zelres1/code/106TOWN.asm  → includes zr1com.inc
working/zelres2/code/200FIGHT.asm → includes zr2com.inc
working/zelres2/code/213BANKP.asm → includes zr2com.inc
working/zelres3/code/3*.asm       → includes zr3com.inc
working/core/game.asm             → has its own EQU section + zeliard.inc
working/core/zeliad.asm           → has its own EQU section + zeliard.inc
```

If a canonical EQU lives in `stdply.inc` but `200FIGHT.asm` uses the
symbolic name, TASM raises "undefined symbol" because 200FIGHT doesn't
include stdply.inc.  Add the EQU as a duplicate in `zr2com.inc`:

```asm
; canonical home is stdply.inc; redeclared here so chunks in zelres2
; can reference shield_type symbolically.  TASM accepts duplicate
; EQUs with matching values.
shield_type      equ  93h
```

The shared `.inc` files for player-record and gvar EQUs are:

| Include | Used by | Canonical home for |
|---|---|---|
| `drivers/stdply.inc` | stdply.asm + gm*.asm | player record bytes (0x80..0xE8) |
| `core/zeliard.inc` | zeliad.asm + game.asm | gvar_* (FF00..FFFF) |
| `zelres1/code/zr1com.inc` | zelres1 chunks | duplicates of stdply.inc + gvar_* names referenced by zelres1 chunks |
| `zelres2/code/zr2com.inc` | zelres2 chunks | duplicates of stdply.inc + gvar_* names referenced by zelres2 chunks |
| `zelres3/code/zr3com.inc` | zelres3 chunks | duplicates of stdply.inc + gvar_* names referenced by zelres3 chunks |

When in doubt: add the EQU to **every common include the address is
referenced from**.  TASM accepts duplicates with matching values, and
duplication beats compile failures.

### 5d — Multi-purpose byte aliases

Some bytes are reused for unrelated purposes by different code paths.
Both names can coexist if they EQU to the same value:

```asm
drv_color_lut    equ  78h      ; gm*.asm: color lookup base in graphics dispatch
weap_dur_cur     equ  78h      ; alias — same byte, holds current weapon durability
                               ; in 200FIGHT.  Treat as separate logical fields
                               ; that happen to share storage; rename each call
                               ; site to whichever name fits its role.
```

The rule: **rename each use site to the name that matches its
semantic role**, not to a single canonical name.  Multi-purpose bytes
in this codebase are often genuine — RAM was scarce, the original
authors aliased fields whose lifetimes didn't overlap.

### 5e — Comment maintenance

After a rename, the surrounding comments often reference the old name.
If your `replace_all` was scoped to just the symbol, the comment is
now stale and misleading.  Two failure modes:

1. **Stale reference comment**: `; sets gvar_volume_a (FF44)` survives
   after `gvar_volume_a` was renamed to `gvar_input_lock`.  Hunt these
   down with a grep for the old name and rewrite.
2. **Self-referential rename bug**: a comment like
   `; renamed from gvar_volume_a to gvar_input_lock — was a misnomer`
   gets clobbered by a global `replace_all gvar_volume_a → gvar_input_lock`,
   becoming `; renamed from gvar_input_lock to gvar_input_lock`.

Avoid both by:

- Doing the rename FIRST.
- Then writing the explanatory comment.
- Never the other way around.

If you wrote the comment first, scope the `replace_all` with a regex
that excludes comment lines (`^[^;]*\bold_name\b` matches only outside
comments — but check for inline `; ...` after the symbol, those are
inside comments too).

### 5f — Re-grep for missed sites

After a batch of renames, both forms must come up empty:

```bash
# Did any old placeholder symbols survive?
grep -rEn "\b(stat_X<HEX>|gvar_flag_FF<HEX>|loc_<N>)\b" 3_Assembly/tasm/working

# Did any raw-hex operands survive at the renamed addresses?
grep -rEn "(ds|cs|es|ss):\[0?<HEX>h\]" 3_Assembly/tasm/working
```

The first should return only the alias-EQU line(s).  The second should
return only the EQU declarations themselves.  Anything in `mov`/`cmp`/
`test`/`or`/`and` instructions is a missed site.

---

## Step 6 — Verify

### 6.1 — Per-batch fast verify

Run after every batch of related renames:

```bash
cd 3_Assembly/tasm
python verify1.py drivers/stdply.asm
python verify1.py zelres2/code/200FIGHT.asm
python verify1.py zelres2/code/201SELCT.asm
# ... one per changed .asm
```

Each takes <2 seconds.  Required output per file:

```
BIT-PERFECT — drivers/stdply.bin matches expected (3344 bytes)
```

If a file fails, the most likely causes are:

- **Bracket sensitivity** (5b above) — restore `[]` around the operand.
- **Prefix collision** (5a above) — a `replace_all` clobbered a longer
  symbol; revert and redo in reverse-numeric order.
- **Missing EQU in scope** (5c above) — TASM raises "undefined symbol"
  because the EQU is in stdply.inc but the file includes zr2com.inc
  only.  Add the duplicate EQU.
- **Stale `.lst` confusion** — a previous failed build left a `.lst`
  file showing unrelated errors.  Delete `.lst` and `.bin` for the
  changed file before re-running:
  ```bash
  rm -f 3_Assembly/tasm/working/<path>/<file>.lst \
        3_Assembly/tasm/working/<path>/<file>.bin
  ```

### 6.2 — End-of-batch full verify

Once all `verify1.py` runs are bit-perfect, run the full SAR rebuild:

```bash
cd 3_Assembly/tasm
python build_all.py --verify
```

Required output:

```
zelres1.sar: BIT-PERFECT (256,952 bytes)
zelres2.sar: BIT-PERFECT (345,218 bytes)
zelres3.sar: BIT-PERFECT (342,434 bytes)
```

If a SAR fails despite per-file verifies passing, the issue is at the
SAR-pack level (chunk ordering, archive header, padding).  Renames
rarely cause this — but a delete or insert of a line can shift
something.  Bisect by reverting half the changes and rebuilding.

---

## Step 7 — Document the sweep

Update one or more of:

- `working/IDA_NAME_DELTA.md` — record renames where the IDA name
  differed from the cleaned-source name and which one won.
- `working/AUDIT_TODO.md` — list any names you renamed to a
  generic placeholder (like `player_ability_1/2/3`) where the
  specific role is still TBD.
- `working/EVIDENCE_REPORT.md` — append a paragraph for each
  significant rename with the evidence weight (Step 3 table) and the
  procs/files cited.

In the user-facing reply, state:

1. The sweep shape (player-record / gvar / driver-dispatch / hardcoded /
   placeholder-proc) and inventory size.
2. The renames applied, grouped by canonical home.
3. SAR verification status (line per archive).
4. Any audit-todo items left for follow-up.

---

## Common pitfalls

These are the failure modes that bit me during this codebase's sweeps.
Watch for them.

### Prefix collision in `replace_all`

The single most common build-breaker.  If you're renaming `loc_3` and
`loc_3X` exists, `loc_3` will clobber `loc_3X` references.  **Always
rename in reverse numeric order**, or use word-boundary regex.

### Bracket sensitivity

`mov ds:label, ax` and `mov ds:[label], ax` can emit different bytes.
Preserve original brackets.

### Self-referential comment clobber

`replace_all old_name → new_name` will rewrite a comment that mentions
both names: `; renamed from old_name to new_name` becomes
`; renamed from new_name to new_name`.  Write the comment *after* the
rename, not before.

### Global rename of a multi-purpose byte

If `[78h]` is `drv_color_lut` in graphics drivers and `weap_dur_cur` in
combat code, a global `[78h] → drv_color_lut` rename makes the combat
code unreadable.  **Multi-purpose bytes need site-by-site decisions**,
not a global sweep.

### Trusting "no readers" claims from a static probe

`functest/harness.py` and `analyze_stat_layout.py` see direct
addressing modes only.  They miss `lodsb` and `mov al, [si+N]` accesses
where SI was loaded with the address in a different proc.  Run 4a/4b/4c
before annotating a byte as vestigial.

### Trusting one chunk's narrow interpretation

201SELCT reads `[93h]` to pick a shield icon.  That proves `[93h]` is
some kind of shield index — but it doesn't prove it's the *equipped
magic ID* (which was the early guess).  200FIGHT's
`apply_combat_damage_with_absorb` proves it's specifically the *shield
type that drives absorption* — the icon read happens to use the same
byte because the icon represents the absorbing shield.  Always cross-
reference at least one combat or game-loop chunk before adopting a name
sourced from a UI/menu chunk.

### Conflicting evidence: damage write beats icon-draw read

Default precedence rule when two chunks imply different semantics for
the same byte:

```
damage / arithmetic / FSM-write  >  set/test/clear pair  >  display read
```

The chunk that *modifies* the byte based on its value is the one whose
naming convention wins.  The chunk that just *displays* the byte adopts
the canonical name even if its narrow read suggests something simpler.

### Stale `.lst` files after a failed build

TASM leaves a `.lst` from the last successful compile.  If a build
fails midway, the `.lst` you read may be from before the change.
Delete `.lst` (and `.bin`) for the changed file before re-running
`verify1.py`.

### EQU in the wrong common include

A canonical EQU added to `stdply.inc` is invisible to `200FIGHT.asm`,
which includes `zr2com.inc`.  **Always add the EQU to every common
include whose chunks reference the symbol** — TASM accepts duplicates
with matching values.  See Step 5c for the include map.

### Auto-generated label names hiding renames

`game_func_7` may have been renamed to `apply_combat_damage_with_absorb`,
but a stale `loc_700` reference in another chunk wasn't updated.  After
each batch, grep for the *full set* of pre-rename names — not just the
ones you remember touching.

### Don't promote a name from one chunk's use without verifying
the address shows the same access pattern in other chunks

A name like `trade_marker_flag` may have made sense in 212ARMRP because
that's where the byte is set.  But if 200FIGHT also reads the byte and
its access pattern there is unrelated to trading, the name is wrong.
Trace **at least two distinct call sites** before adopting a name —
ideally one write and one read in different chunks.

---

## Tooling reference

Same scripts as `/label-audit`, plus:

| Script | Purpose |
|---|---|
| `analyze_stat_layout.py --range LO HI --segment SEG` | Per-address access-pattern classifier; resolves EQU symbols |
| `find_missing_equs.py` | Lists raw-hex operands without an EQU (MISSING) and EQUs that aren't being used at call sites (UNUSED).  Output: `working/MISSING_EQUS.md` |
| `survey_full_address_space.py` | Bucketed wide-net survey across all addresses; useful for prioritising a sweep |
| `evidence_check.py` | Phase 1/2/3 verifier for a proposed rename batch |
| `compare_ida_names.py` | Diffs cleaned-source names against IDA's; useful for finding drift between the two |
| `verify1.py <subpath/file.asm>` | Per-edit fast verify; <2s per file |
| `build_all.py --verify` | End-of-batch full SAR rebuild + bit-perfect comparison |

Common include files for cross-include propagation:

| Include | Scope |
|---|---|
| `drivers/stdply.inc` | Player record (0x80..0xE8) — canonical home |
| `core/zeliard.inc` | gvar_* (FF00..FFFF) — canonical home |
| `zelres1/code/zr1com.inc` | zelres1-chunk duplicates of stdply.inc + zeliard.inc |
| `zelres2/code/zr2com.inc` | zelres2-chunk duplicates of stdply.inc + zeliard.inc |
| `zelres3/code/zr3com.inc` | zelres3-chunk duplicates of stdply.inc + zeliard.inc |

---

## Worked examples (from this codebase)

- **shield_type / shield_HP / shield_max_HP at 0x93/0x94/0x95**:
  early speculative names `equipped_magic`, `player_exp`, `player_exp_cap`
  promoted from a 201SELCT-only read.  Reverted after
  `apply_combat_damage_with_absorb` in 200FIGHT was traced — that proc
  reads `[93h]` to pick an absorb table entry, then conditionally
  decrements `[94h]` (shield HP) by damage taken, capped at `[95h]`
  (shield max HP).  Decisive evidence rule: damage-write beats
  icon-draw read.

- **stick.bin INT 60h dispatch slots `cs:[10Ch..120h]`**: each slot is
  a near-pointer to a stick.asm proc.  Mapped by reading the
  `driver_init_data` block in stick.asm and matching each slot index
  to its target proc.  Renamed `cs:[10Ch]` → `sar_loader_fn`,
  `cs:[110h]..cs:[120h]` → `stick_*_handler` series with descriptive
  names per their actual role.  Cross-include propagation: added the
  full `stick_*_handler` set to `zr1com.inc` AND `zr2com.inc` because
  both archive groups dispatch through stick.

- **graphics-driver dispatch slots `cs:[2000h..2044h]`**: same pattern
  as the stick dispatch.  Mapped from the `gm*.asm` driver dispatch
  table.  Renamed `drv_fn_2/3/5/6/7/10/13/14/21/22` and
  `drv2_fn_2/15/20`.  Multi-purpose: `[78h]` is `drv_color_lut` in the
  graphics path and `weap_dur_cur` in the combat path — kept both EQUs
  with explanatory comments.

- **player_ability_1/2/3 at 0x9B/0x9C/0x9D**: previously named
  `trade_marker_flag` (0x9B, from 212ARMRP) and `stat_X9C/stat_X9D`
  placeholders.  After functest probing showed all three are read
  together by 201SELCT's `draw_abilities` proc via `lodsb` from a
  3-byte stride, renamed to `player_ability_1/2/3` with an
  AUDIT_TODO entry — specific abilities still TBD pending more
  evidence.  Indirect-access lesson: the static analyzer reported
  `[9Ch]` and `[9Dh]` as having zero readers because the read goes
  through SI after a `mov si, OFFSET 9Bh` in a different proc.

- **200FIGHT 51-proc rename**: largest single-chunk sweep.
  Inventory: 51 procs named `loc_NN`, `proc_NN`, `game_func_NN`.
  Rename order chosen carefully (reverse-numeric for digit-overlapping
  families) to avoid prefix collisions.  Outcome: every proc named
  after its semantic role with one-line evidence comments at the
  proc header.  Bit-perfect verified after each batch of ~8 procs.

---

## Don'ts

- **Don't rename in forward numeric order** if the family has
  digit-overlapping names (`loc_3` and `loc_30..39`).  Reverse order.
- **Don't drop brackets** when rewriting raw-hex operands to symbolic.
  `ds:[X]` and `ds:X` can emit different bytes.
- **Don't trust "no readers" claims** from static probes — check for
  `lodsb`/`mov [si+N]` indirect access first.
- **Don't promote a name from one chunk's narrow use** — cross-
  reference at least one other chunk's access pattern before adopting.
- **Don't write the rationale comment before the rename** — the
  `replace_all` will clobber the old name in your own comment.
- **Don't add the canonical EQU to only one chunk's local source** —
  it has to live in the shared `.inc` files used by every consuming
  chunk, even if that means duplicating the EQU across `zr1com.inc`,
  `zr2com.inc`, `zr3com.inc`.
- **Don't skip verify1.py between batches** — the longer the gap
  between a build break and noticing it, the harder the bisect.
- **Don't accept a global rename for a multi-purpose byte** — site-by-
  site decisions are required when the byte's role differs by call
  context.
- **Don't trust user testimony alone** as evidence — every promotion
  still needs an asm trace.  User testimony is hypothesis-quality; the
  bytes are ground truth.
