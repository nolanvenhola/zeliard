---
name: label-audit
description: Audit and decode a single label or address in the Zeliard tasm source. Gathers static evidence (access pattern, all names at the address, ref counts), traces usage to find the canonical owner, applies an evidence-supported rename or annotation, and verifies SAR builds bit-perfect. Use when a label looks speculative ("ply_walk_speed", "gvar_flag_FFNN", "reserved", "unknown player state byte") or when multiple files name the same address differently.
---

You are auditing a single label or address in the Zeliard tasm source. The goal is to either:

- Confirm the existing label is correct (with evidence cited), OR
- Replace it with a name backed by access patterns and code semantics, OR
- Annotate it as vestigial / inconclusive when evidence is genuinely absent.

Every change must preserve the byte image.  Verification is two-tiered:

1. **Per-edit** — run `python verify1.py <changed-file.asm>` for each
   `.asm` you touched.  Compiles only that file and byte-compares against
   the expected `.bin`.  Fast (<2s).  Use this after every edit.
2. **End-of-batch** — run `python build_all.py --verify` once at the end.
   Full clean rebuild + SAR pack + byte-compare against the original
   archives.  Required output: **all 3 SARs BIT-PERFECT**.

This skill is the address-level counterpart of `/asm-cleanup` (which
works file-at-a-time).

---

## Step 0 — Identify the target

The user gives you EITHER:
- An address: `0x80`, `0xFF44`, `0xC9..0xCF`
- A label name: `ply_walk_speed`, `gvar_flag_FF44`, `restore_pending`
- A code excerpt with a suspicious comment: `db 8Ah ; unknown player state byte`

If the user gives a label, resolve it to an address first with:

```bash
grep -rn "^\s*<name>\s\+equ\b" 3_Assembly/tasm/working
```

Multiple definitions are normal — note them all; one of them is likely the canonical one.

---

## Step 1 — Static access-pattern audit

Run the segment-aware analyzer over the address (or a tight range covering it):

```bash
cd 3_Assembly/tasm
python analyze_stat_layout.py --range 0xADDR 0xADDR --segment game_seg
```

Substitute `--segment enemy_seg` or `--segment town_npc_seg` if the address lives in one of those segments. For player-record addresses (0x80..0xE8) and game globals (0xFF00..0xFFFF), use `game_seg`.

Read off:

| Signal | What it tells you |
|---|---|
| `word_read` / `word_write` count, **zero refs at addr+1** | 16-bit field at `addr..addr+1` |
| `byte_read` / `byte_write` only | 8-bit field |
| `byte_adc` at addr + `word_add` at addr−2 | High byte of multi-precision arithmetic; field is 24-bit |
| `byte_test` of `0FFh` + writes of `0` and `0FFh` | Boolean flag |
| Many `byte_inc` / `byte_dec` + `byte_cmp` | Counter (note the comparison value — that's the wrap point) |
| `word_cmp` against another addr | Index/pointer compared to a buffer size |
| **Zero refs at all** | Vestigial — see Step 4d |

Also run the missing-EQU check:

```bash
python find_missing_equs.py
```

This produces `working/MISSING_EQUS.md`. Find your address in it and note whether it's UNUSED (has an EQU but raw hex is used at call sites) or MISSING (no EQU at all).

---

## Step 2 — Find every name at this address

```bash
grep -rn "^\s*\w\+\s\+equ\s\+0\?<HEX>h" 3_Assembly/tasm/working
```

Multiple names at the same address is the most common case in this codebase — different files have different guesses. Tabulate them with their owning file:

```
Names equating to 0xFF44:
  gvar_joy_data        core/game.asm:53
  gvar_flag_FF44       zelres2/code/200FIGHT.asm:96
  restore_pending      zelres2/code/zr2com.inc:61
```

---

## Step 3 — Find usage sites for each name

For every name, count its non-EQU references:

```bash
grep -rn "\b<name>\b" 3_Assembly/tasm/working | grep -v "equ\b"
```

The name with the most usage sites + the clearest set/test/clear or arithmetic pattern is almost always the canonical owner. The others are speculative guesses that earlier passes left behind.

**Heuristics to pick the canonical name:**

- A name with **20+ uses across multiple files** beats a name with **1 use that's a zero-init in a "clear all flags" sequence**. Zero-init sites are diagnostic of *nothing* — every flag gets cleared during reset.
- A name that participates in **set/test/clear cycles within one function** is real (e.g. `bg_save` sets, `bg_restore` tests/clears).
- A name that participates in **arithmetic chains** (e.g. one add followed by an adc to the high byte) is real (multi-precision counter).
- A name that participates in **wrap-around comparisons** (e.g. `cmp ax, map_width; jne .next; mov [addr], 0`) is real (modular index).
- A name with `gvar_flag_FFNN` form is **always a placeholder** — search for a non-placeholder name at the same address before applying.

---

## Step 4 — Categorize and decide

Match the address to one of these archetypes:

### 4a — Multi-name address: pick the canonical, alias the others

Like 0xFF44 (`gvar_joy_data` / `gvar_flag_FF44` / `restore_pending`):
1. Update the EQU at the canonical owner's file:
   ```asm
   ; <one-paragraph evidence comment citing N usage sites and the
   ; specific set/test/clear pattern that fixes the name>
   restore_pending  equ  0FF44h   ; bg_restore pending flag (gf*.asm)
   gvar_joy_data    equ  0FF44h   ; alias — deprecated misnomer
   ```
2. Update the use site to use the canonical name (one-line comment noting the rename).
3. Leave aliases in place so any unrenamed call site still resolves.

### 4b — Speculative single name: rename if evidence supports

Like `ply_walk_speed db 1Eh` at 0x80 (renamed to `map_scroll_col dw 001Eh`):

Find a procedure that *operates* on the field and has a self-explanatory label (e.g. `scroll_pos_inc:`). Quote 4–8 lines from it in the rename's comment as evidence. Preserve the byte image — change `db` to `dw` if the field is actually 16-bit, but keep the same value (`1Eh` → `001Eh` is the same two bytes).

### 4c — Heavy use, no semantic name yet (gvar_flag_FFNN)

Like 0xFF45/46/47 (renamed to `gvar_combat_action_state` / `gvar_combat_anim_subindex` / `gvar_combat_audio_latch`):

1. Read all write sites and tabulate the values written + conditions for each.
2. Read all read sites and tabulate the comparisons.
3. Look for a **transition table** — when does the field change value, and what are the inputs that drive each transition?
4. Build a one-sentence summary: "FSM with N states, transitions on event X, drives effect Y."
5. Rename based on the role you identified.
6. Keep the placeholder name as a deprecation alias.

### 4d — Vestigial (zero refs anywhere)

Like 0xC9..0xCF in stdply (no refs across all 3 segments):

1. Verify thoroughly — run a permissive grep that includes **indexed access patterns**:
   ```bash
   grep -rn "\b0\?<HEX>h\b" 3_Assembly/tasm/working
   ```
   The hits will mostly be immediate values (`mov dl, 0C9h` is loading the constant, not the address); read each one to confirm it's not actually a memory ref through `[bx+N]` etc.
2. Check whether `zeliad.exe` (outside the cleaned chunks) might read it — note this as a possibility but don't claim it.
3. Annotate honestly:
   ```asm
   ; [C9h..CFh]: 7 bytes with NO genuine memory references anywhere in
   ; the cleaned source.  The non-zero values are stable signatures from
   ; original development, possibly read by zeliad.exe's save/load code
   ; (outside cleaned chunks).  Treat as vestigial.
   ```

### 4e — Single low-volume use, ambiguous

Like 0x83/0x84 in stdply (`ply_accel db 0Ah, 0Ah`):

If the access pattern is clear (e.g. `[84h]*36 + [83h] + 4 + gvar_scroll_pos` is tile-grid arithmetic) but the **role** is not (sub-tile offset? animation cursor? damage flash?), keep the existing label and **rewrite the comment** to record exactly what the access pattern shows. Don't rename without confidence — a wrong rename is worse than a stale-but-honest "purpose inconclusive."

---

## Step 5 — Apply the change

There are **THREE places** where the canonical name has to land.  Missing
any one of them leaves the source in a half-renamed state where the EQU
table claims a new name but the actual data declaration or call sites
still display the old placeholder.

**5.1 — The EQU declaration(s).** Add the canonical name as the primary
EQU; demote any prior placeholder to an alias EQU on the very next line
with a `; alias — deprecated` comment.  Multiple EQUs can resolve to the
same address; TASM accepts that as long as the values match.

```asm
; <evidence comment>
gvar_pose_idx           equ     0E7h    ; player pose state (canonical)
stat_XE7                equ     0E7h    ; alias — deprecated placeholder
```

**The canonical EQU MUST live in a SHARED include file** (one of
`stdply.inc`, `zeliard.inc`, `zr1com.inc`, `zr2com.inc`, `zr3com.inc`,
or another file that the consumers include) — not buried inside a single
`.asm` chunk.  If the field is read or written from more than one chunk,
the EQU has to be reachable from every chunk that uses the symbolic
name; otherwise TASM raises "undefined symbol" and Step 5.3 stops being
applicable in those files.

Concretely: identify which chunks reference the address (Step 3 already
listed them), determine which common `.inc` each chunk includes, and add
the canonical EQU to whichever common include covers them all.  If
chunks span archives (e.g. some in zelres1, others in zelres2), the EQU
needs to be added to BOTH `zr1com.inc` AND `zr2com.inc` as duplicates —
TASM accepts duplicate equates with matching values.  Comment the
duplicates as "canonical home is <stdply.inc>; redeclared here so this
archive's chunks can reference symbolically."

A canonical EQU sitting only in `stdply.inc` is invisible to
`200FIGHT.asm` (which includes `zr2com.inc`, not `stdply.inc`) — so the
work in 5.3 will fail compile.  Add the duplicate EQU to `zr2com.inc`
in that case.

**5.2 — The actual `db` / `dw` label at the data declaration site.**  If
the field is declared in stdply.asm or a similar data file with a `db`
or `dw`, the LABEL on that line must be the canonical name too — not
the placeholder.  This is the most commonly missed step.  Bad / good:

```asm
;  BAD — EQU is renamed but the data declaration still shows the placeholder
stat_XE7        db      0       ; [E7h] = gvar_pose_idx (player pose state)

;  GOOD — declaration uses the canonical label
gvar_pose_idx   db      0       ; [E7h] player pose state
```

The byte image is unchanged either way — the rename is purely textual —
but the declaration label is what readers see when they look at the
field's home, and it must agree with the EQU.

**5.3 — Replace EVERY use site, both placeholder-symbol AND raw-hex.**

Two flavours of use site exist; **both** must be replaced — leaving raw
hex defeats the readability gain that motivated the rename in the first
place.

a) Placeholder-symbol sites (`mov ds:stat_XE7, ...`): replace with
   `mov ds:gvar_pose_idx, ...`.

b) Raw-hex sites (`mov ds:[0E7h], ...`, `cmp byte ptr ds:[0E7h], 80h`,
   `or [0E7h], 1`, etc.): replace with the symbolic form
   (`mov ds:gvar_pose_idx, ...`).  This is the step the skill used
   to defer "for later" but doing it now is correct: the whole point
   of canonicalising the name is so the source reads
   `cmp gvar_pose_idx, 80h` instead of `cmp [0E7h], 80h`.

A regex sweep covers both:

```bash
# Replace ds:[0E7h] / es:[0E7h] / cs:[0E7h] / ss:[0E7h]
sed -i -E 's/(ds|cs|es|ss):\[0?E7h\]/\1:gvar_pose_idx/gi' \
       working/<file1>.asm working/<file2>.asm ...

# And any bare [0E7h] outside db/dw lines
sed -i -E '/^\s*(db|dw|dd)\b/!s/\[0?E7h\]/[gvar_pose_idx]/gi' \
       working/<file1>.asm ...
```

Or do it in Python with a per-line check that skips `db`/`dw`/`dd`
declarations (raw hex inside data tables is a payload, not an address):

```python
for line in lines:
    stripped = re.sub(r';.*', '', line).strip().lower()
    if stripped.startswith(('db ', 'dw ', 'dd ', 'db\t', 'dw\t', 'dd\t')):
        out.append(line)        # data declaration — leave alone
        continue
    out.append(re.sub(r'(?P<seg>ds|cs|es|ss):\[0?<HEX>h\]',
                      r'\g<seg>:<canonical>', line, flags=re.I))
```

**Cross-include propagation.**  The replacement only compiles if every
file using the canonical name has the EQU in scope.  Common cases:

- A canonical name added to `stdply.inc` is visible in `gm*.asm`
  drivers (which include stdply.inc) but **not** in `200FIGHT.asm`,
  `106TOWN.asm`, `gf*.asm`, or `game.asm`.  Those files include
  different common headers (`zr1com.inc`, `zr2com.inc`, `srmacros.inc`).
- Add the canonical EQU as a duplicate in each common include the
  consuming chunks use (e.g. add `gvar_pose_idx equ 0E7h` to
  `zr1com.inc`, `zr2com.inc`, and `game.asm`'s local section).
- TASM accepts duplicate EQUs that resolve to the same value.  Comment
  the duplicate as "canonical home is stdply.inc; redeclared so chunks
  in this archive can reference symbolically."

**Always re-grep both forms after the edits**:

```bash
# Did any placeholder-symbol references survive?
grep -rn "\b<placeholder_name>\b" 3_Assembly/tasm/working

# Did any raw-hex memory operands survive?
grep -rEn "(ds|cs|es|ss):\[0?<HEX>h\]|\[0?<HEX>h\]" 3_Assembly/tasm/working
```

The placeholder grep should return only the alias-EQU line.  The raw-hex
grep should return only `db`/`dw`/`dd` payloads (data tables where
`<HEX>` is a value, not an address) and the EQU declarations themselves.
**Anything in actual `mov`/`cmp`/`test`/`or`/`and` instructions is a
miss.**

After the edits, run `verify1.py` on each changed `.asm` file (Step 6.1).
If TASM fails with "undefined symbol", the canonical EQU isn't visible
in that file's include scope — go back and add it to the relevant
common include (zr1com.inc / zr2com.inc / etc.).

---

### Byte-image preservation rules

- A `db` → `dw` change is a noop if the byte values are the same (`db 1Eh, 0` and `dw 001Eh` both lay down `1E 00`).
- Splitting `db 4 dup (0)` into individual named bytes (`field_a db 0; field_b db 0; ...`) is a noop.
- Removing/adding **comments** is a noop.
- Replacing `[<addr>h]` with `[<name>]` at use sites is a noop if the EQU resolves to the same value.
- Renaming a `db`/`dw` LABEL is a noop — the label is just a name TASM resolves to an offset; changing the name doesn't shift the offset.

What is **not** noop — never do these unless explicitly authorized:

- Changing `db` to `dw` while also changing the value.
- Deleting "vestigial" bytes (they affect file size).
- Reordering fields.
- Combining adjacent `db`s into a single `db` with multiple values (this can change SAR padding behaviour — verify before claiming it's safe).

---

## Step 6 — Verify

Two verification levels.  Use the fast path for every iteration, the full
path only when finishing a multi-file batch or before reporting results.

### 6.1 — Fast path (per-edit): `verify1.py`

Most label-audit edits change exactly one or two `.asm` files (e.g.
`stdply.asm` for the data declaration + `stdply.inc` for the EQU).
`verify1.py` compiles a single ASM file and byte-compares its output
against the expected `.bin`/`.mdt` — no SAR pack, no full-tree rebuild.

```bash
cd 3_Assembly/tasm
python verify1.py drivers/stdply.asm
```

Run this for **every** changed `.asm` file (run it once per file).  An
edit to a `.inc` file alone doesn't need its own check — its effect is
seen in the file that includes it, so verify the includer.  If
`verify1.py` reports BIT-PERFECT for every changed file, the change is
safe at the chunk level; you can move on without running the full
build.  Typical run: **<2 seconds per file**.

### 6.2 — Full path (end of batch): `build_all.py --verify`

Run this when you've finished a session of related audits and want to
confirm the SAR-level invariants still hold.  It does a clean rebuild
of every chunk, packs all three SARs, and byte-compares each SAR
against the original archive.

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

The full path is the only way to catch issues that show up at SAR pack
time — chunk ordering, archive headers, padding alignment.  In practice
those rarely break from a label rename, so save it for end-of-batch.

### When verification fails

If any SAR is not bit-perfect, **revert the change immediately** and re-investigate. The most common causes:

- Editing a `dw` literal that the assembler now lays out at a different offset because of alignment. Move the change inside the same field width.
- Adding a comment with a tab character that TASM treats as significant whitespace. Use spaces in comments.
- Renaming a label that's referenced by an indexed addressing mode (`[label+bx]` may compute differently than `[addr+bx]` in certain TASM versions). Restore the literal addressing.

---

## Step 7 — Document the finding

In the user-facing reply, state:

1. The address and what was claimed about it.
2. The evidence that disproved or refined the claim (cite line numbers — `200FIGHT.asm:1170` etc.).
3. The final name + a one-sentence semantic summary.
4. SAR verification status.

Match the format of past audits in this session — they're concise, table-driven where applicable, and always cite the specific procedures or value patterns that nail down semantics.

---

## Tooling reference

Scripts available under `3_Assembly/tasm/`:

| Script | Purpose |
|---|---|
| `analyze_stat_layout.py` | Per-address access-pattern classifier (byte/word, read/write/test/arithmetic). Supports `--range LO HI` and `--segment game_seg/enemy_seg/town_npc_seg`. Resolves EQU symbols. |
| `find_missing_equs.py` | Lists raw-hex memory operands without EQUates (MISSING) or with EQUates that aren't being used at call sites (UNUSED). |
| `survey_full_address_space.py` | Bucketed wide-net survey across all addresses. Top-N hot addresses, top-N unnamed, per-256-byte-page summary. |
| `evidence_check.py` | Phase 1 (data fields) / Phase 2 (code-pointer signatures) / Phase 3 (structural family cohesion) verifier. |
| `functest/harness.py` + `functest/test_*.py` | Unicorn-based behavioural probes — run a function with controlled inputs and observe register/memory effects. Use when static evidence is ambiguous. |
| `compare_ida_names.py` | Diffs symbol names between cleaned source and the IDA decompilation in `3_Assembly/ida/`. |
| `verify1.py <subpath/to/file.asm>` | **Per-edit fast verify** — compiles ONE asm file and byte-compares its `.bin`/`.mdt` against the expected output.  Run after each edit; <2s per file. |
| `build_all.py --verify` | **End-of-batch full verify** — clean rebuild of all chunks, packs SARs, byte-compares all 3 SARs against originals.  Run once at the end of a session, not after every edit. |

## Worked examples (in this codebase)

Refer to recent audits for the prose pattern of a good rename:

- **0x80..0x82**: `ply_walk_speed db 1Eh; db 00h, 00h ; reserved` → `map_scroll_col dw 001Eh; map_scroll_row db 0`. Evidence: 54 `word ptr ds:[80h]` refs (zero standalone at 0x81), `scroll_pos_dec` / `scroll_pos_inc` procs in 200FIGHT.asm with wrap-at-`map_width`.
- **0x88..0x8A**: `db 3 dup (0) ; reserved` → `stat_X88_hi db 0; stat_X88_lo dw 0`. Evidence: byte_adc + word_add same shape as gold, semantics TBD.
- **0xFF44**: `gvar_joy_data` / `gvar_flag_FF44` (1 ref each, zero-init) → `restore_pending` (21 refs across 5 gf*.asm files with set/test/clear pattern in `bg_save` / `bg_restore` procs).
- **0xC9..0xCF**: `db 8Ah ; unknown player state byte` → `db 8Ah ; vestigial (no refs)`. Evidence: zero refs across all 3 segment groups + permissive grep.
- **0xE7**: `stat_XE7 db 0 ; heavily-used state byte` → `gvar_pose_idx db 0 ; player pose state` AND EQU consolidation in stdply.inc + alias for old name. Evidence: 64 raw `[0E7h]` refs across 8 files; all 5 gf*.asm drivers `cmp [0E7h], 80h` to switch sprite mode; 300ROKAD already named it `gvar_pose_idx`. **The label at the `db` declaration site must be renamed too — leaving it as `stat_XE7` while the EQU table says `gvar_pose_idx` is a half-rename.**

---

## Don'ts

- Don't trust placeholder names like `gvar_flag_FFNN` or `stat_X??` as semantic — they're known guesses.
- Don't trust IDA's names as ground truth either — they're another LLM/human's interpretation. Use them as hypotheses, validate against bytes.
- Don't rename without finding the procedure that *uses* the field (a write-only audit gives a misleading answer).
- Don't merge addresses across segments — `cs:[8Bh]` in `gmega.asm` and `cs:[8Bh]` in `309CRAB.asm` are different bytes (different runtime CS).
- Don't skip bit-perfect verification. A passing TASM compile is **not** the same as a bit-perfect SAR.
- **Don't leave raw `[<HEX>h]` memory operands behind** after a rename.  Every site of the form `mov ... ds:[NNh]` for the renamed address must become `mov ... ds:<canonical>` — same byte image, immeasurably better source readability.  Step 5.3's grep must come up clean.
- **Don't put the canonical EQU in a single chunk's local source** when the field is shared across chunks.  The EQU has to live in a shared `.inc` file (or be duplicated across the relevant common includes — `zr1com.inc`, `zr2com.inc`, `zr3com.inc`, etc.) so every chunk that uses the symbolic name can resolve it at compile time.  An EQU that's only visible to one chunk is not a rename — it's a chunk-local alias that fragments the codebase.
