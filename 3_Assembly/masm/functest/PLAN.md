# Runtime Functional-Test Coverage Plan

Counterpart to `INDEX.md` (live test catalog) and `working/AUDIT_TODO.md`
(static-side TODO).  This file is the multi-phase roadmap for taking
runtime coverage from "5 spot tests" to "every proc that's worth proving
has a verdict logged".

Invariant: tests consume committed `bin/*.bin` artifacts directly; no SAR
rebuilds are required to run any test.  The `build_all.py --verify`
bit-perfect contract is orthogonal to this work.

---

## 0. Corpus shape (measured 2026-04-29)

* **888** `proc near` declarations under `working/zelres{1,2,3}/code/*.asm`
  (the cleaned tree).  Of those:
  * **88**  start with `game_func_` — the Sourcer-numbered placeholders
    that need identity.
  * **6**   start with `sub_` — Sourcer raw, mostly cleaned up already.
  * **~794** have semantic names already; most are regression candidates.
* **792** `sub_NN` procs in the raw `source/*.ASM` Sourcer tree — out of
  scope for this plan (those get cleaned by `/asm-cleanup`, not probed).
* **27** dispatch-slot symbolic names (`fight_cb_*`, `town_cb_*`) under
  the 0x6000–0x603E range; 8 already classified by behavioral fingerprint.
* **2** placeholder bytes still flagged "Functional-probe required":
  `stat_X9C`, `stat_X9F`.
* **2** speculative bytes with thin evidence: `ply_accel`, `stat_X88_hi/lo`.
* **1** single-site placeholder: `state_byte_C017`.

When this plan refers to "the corpus", it means the 888 procs in
`working/zelres{1,2,3}/code/`.

---

## 1. Triage — classifier

Goal: produce a CSV row per proc with a category, so we never wonder
"is this one worth a test" again.  A proc either gets a test, gets
explicitly skipped (with reason), or is flagged "needs deeper static
work first".

### 1.1 Classifier inputs (all from static analysis of cleaned .asm)

For each proc, we extract:

| Feature | How |
|---|---|
| `size_bytes` | byte distance from `name proc near` to matching `endp` (use the .LST byte-offset column, or count assembled bytes from the corresponding `.bin` chunk slice using the proc's address) |
| `n_calls_out` | count of `call foo` / `call near ptr foo` lines in body |
| `n_calls_in`  | count of references in any `call <this-name>` site across the whole tree |
| `int_count`   | count of `int <imm>` instructions in body |
| `port_io`     | count of `in al, dx` / `out dx, al` etc. |
| `mem_writes_to_ds` | count of distinct `[xxh]` / `[bx+yy]` write targets |
| `far_calls`   | count of `call dword ptr cs:[xxh]` (driver dispatch) |
| `loops`       | count of `rep`/`loop`/conditional-jump-back patterns |
| `has_placeholder_name` | `True` iff name matches `game_func_\d+` or `sub_\d+` |
| `chunk` | which .bin file the proc lives in |
| `entry_addr` | absolute CPU address (so a Unicorn test can call it) |

`callgraph.py` already counts `call foo` references — extend it (don't
rewrite) to emit one CSV row per `proc near` declaration with the above
columns.

### 1.2 Classifier rules (applied to the CSV)

| Category | Rule (first match wins) | What we do with it |
|---|---|---|
| **D — untestable in isolation** | `int_count > 0` OR `port_io > 0` OR `far_calls >= 3` OR `n_calls_out >= 8` | Mark `skip_reason=driver_or_dos`; integration test only |
| **C — needs deep stubbing** | `n_calls_out >= 3` AND not D | proc_equivalence with a stub-budget test; defer to phase 4 |
| **B — high-value identity probe** | `has_placeholder_name=True` AND not C/D | proc_equivalence; phase 3 priority queue |
| **A — trivial regression candidate** | `size_bytes <= 64` AND `mem_writes_to_ds <= 3` AND not B/C/D | regression test; auto-generate via template |
| **E — pure init/data thunk** | `size_bytes <= 8` AND `mem_writes_to_ds == 0` AND `n_calls_out <= 1` | skip; one-line stub or jmp |

Tunables (`--max-size`, `--call-threshold`) live in the classifier
script so we can re-bin without touching the rules.

Expected distribution (from the 888 procs, eyeballed):

| Category | Approx count | Action |
|---|---|---|
| A — trivial regression | ~300 | template-generate, low cost |
| B — placeholder identity | ~88  | hand-write probes, high value |
| C — deep stubbing | ~150 | phase 4, costly |
| D — untestable in isolation | ~250 | skip + integration tracking |
| E — pure thunk | ~100 | skip, log reason |

Numbers are estimates; the real distribution comes out of phase 1.

---

## 2. Tooling pre-work (Phase 1)

Before writing 100+ tests we extend `harness.py` and add three small
modules so each test is ~30 lines, not ~80.

### 2.1 Shared fixtures (new file `functest/fixtures.py`)

Things every test re-derives today:

* `make_player_record(hp=100, almas=0, gold=0, sword=2, shield=1, ...)`
  → returns a list of `(offset, value, kind)` ds-setup tuples covering
  the canonical player struct (DS:0x80..0xCF), so tests don't have to
  remember which byte is which field.
* `make_monster_record(x_tile=10, y_tile=10, slot=0, ...)` → 32 bytes
  from research notes on entity struct.
* `seed_dispatch_table(harness, slots: dict[int, str])` → install RETF
  thunks at every CS dispatch slot the test names; replaces the
  hand-rolled `install_farcall_thunk` calls.
* `stub_video_drivers(harness)` → install passive-RETF thunks at the
  ~30 CS:[2000h..204Eh] slots so a test can call ANY proc that touches
  the gfx driver dispatch without crashing.
* `BIN_PATHS` dict mapping `'fight'`, `'town'`, `'select'`, ... to
  `(path, load_base)`.  Mirrors the `FLAT_BIN_HINTS` table in
  `evidence_check.py` — extract that into one shared constant.

### 2.2 Fingerprint helpers (extend `harness.py`)

Today every test re-implements byte-delta formatting and fingerprint
hashing.  Add:

* `TasmHarness.fingerprint(result)` — returns a stable hash tuple of
  `(sorted_diffs, regs_changed_set, flag_changes)`.
* `TasmHarness.format_diffs(result, base=0)` — single canonical string
  format for diffs (`+0x3: 0x00->0x0A`).  Reused by all reports.
* `TasmHarness.snapshot()` / `restore()` — for tests that call the same
  function with N input perturbations without paying the cost of
  re-mapping memory each time.

### 2.3 Test runner (`functest/run.py`)

Today each test is a `__main__` script that prints to stdout.  Add:

* CLI: `python run.py [--filter glob] [--ci]`
* Discovers `test_*.py` recursively, runs each as a subprocess, captures
  stdout, looks for the canonical PASS/FAIL token (defined in INDEX.md
  conventions; we're going to formalize it as a final-line `VERDICT:
  PASS|FAIL|REFUTED|INCONCLUSIVE: <message>`).
* `--ci` mode emits a one-line-per-test status table and exit-codes
  non-zero if any FAIL.
* Aggregates into `functest/STATUS.md` (regenerated, not hand-edited):
  one row per test with verdict + summary.

### 2.4 Classifier (`functest/classify.py`)

* Reads every `working/zelres*/code/*.asm`.
* For each `proc near` declaration, extracts the features in §1.1 and
  emits `functest/coverage.csv` with one row per proc, plus computed
  category column.
* Re-runnable; no side effects beyond writing the CSV.
* Stretch: cross-reference with `functest/INDEX.md` so the CSV gains a
  "covered=yes/no" column — instantly tells us what's left.

### 2.5 Test template (`functest/_template_proc_equivalence.py.tmpl`)

A skeleton with the boilerplate from §3 of `INDEX.md` filled in: import
block, BIN path, harness setup, "probe N" comment blocks, `VERDICT:`
print at the bottom.  `functest/new.py <chunk> <addr>` stamps a fresh
test out of the template with the right paths.

### 2.6 Phase-1 deliverable

* `functest/coverage.csv` exists and lists all 888 procs with category.
* `functest/run.py --ci` runs the existing 5 tests and prints a status
  table.
* `harness.py` has `fingerprint()` + `format_diffs()` + `snapshot()`.
* `functest/fixtures.py` exists with `make_player_record` and
  `BIN_PATHS`.

**Cost estimate: ~6–8 hrs.**  Bulk is the classifier extracting
features cleanly across 888 procs (weird sourcer artefacts + multi-
chunk addr collisions).

---

## 3. Phase 2 — Close out byte-level placeholders

These are tiny, isolated, and feed directly back into AUDIT_TODO.

| Target | Test type | Effort |
|---|---|---|
| `stat_X9C` (0x9C) | placeholder_id — find any writer/reader, 3 input perturbations | 30m |
| `stat_X9F` (0x9F) | placeholder_id — same recipe | 30m |
| `state_byte_C017` (0xC017) | placeholder_id — only 1 read site, probe context: what proc reads it and what does control flow do with the value? | 45m |
| `ply_accel` (0x83/0x84) | placeholder_id — set `[83]=10/[84]=10`, run the tile-grid arithmetic site, observe what AX/DI carry into | 1 h |
| `stat_X88_hi/lo` (0x88..0x8A) | placeholder_id — find writer's caller chain via callgraph; if writer is testable, run gold-style probe (carry propagation between bytes) | 1 h |

**Phase-2 deliverable**: 5 new files in `placeholder_id/`, each ending in
a `VERDICT: …` line; AUDIT_TODO.md rows for these 5 marked Done or
explicitly closed as "kept (insufficient runtime evidence)".

**Cost estimate: ~4 hrs.**

---

## 4. Phase 3 — `game_func_N` identity sweep (88 procs)

This is the bulk of the value.  Each `game_func_N` is a Sourcer-numbered
placeholder whose actual semantics we want to pin down.  We process them
in priority order (most callers first — those have the most leverage).

### 4.1 Pre-work (1 h)

* Sort coverage.csv by `n_calls_in DESC` filtered to category B.
* Cross-reference each `game_func_N` against `IDA_NAME_DELTA.md` — if
  IDA has a name for that address (most do, because IDA-derived names
  exist for ~200 procs), the test's job becomes "confirm or refute the
  IDA hypothesis"; if not, the test names it from observed behavior.
* Bucket by chunk: doing all of 200FIGHT's `game_func_*` in one session
  amortizes the harness setup cost.

### 4.2 Authoring loop (per proc, ~20 min average)

For each entry from the priority list:

1. Pull the proc's first ~32 bytes from the chunk; eyeball entry
   prologue (does it read [SI+N]? [BP+N]? does it `cmp` against a
   constant?).  This is exactly the prologue inspection done in
   `test_fight_dispatch_slot_6008.py`.
2. Pick 2–4 input perturbations that exercise distinct branches:
   below/above the constant; CF=0/CF=1 from a stubbed callee; a
   no-op control input.
3. Stamp `functest/new.py` template, edit, run.
4. Verdict line: confirm IDA name, refute it, or assert "function does
   X to byte at DS:Y given input Z" if we have no prior hypothesis.
5. Update `INDEX.md` row.

### 4.3 Cost calibration

* ~20 procs are isolated arithmetic on a single struct (the directional
  movers and similar).  These go in batches of 8 with one fingerprint
  test (precedent: `test_fight_dispatch_8slots_fingerprint.py`).  ~5h
  for the whole 20 in 3 batches.
* ~40 procs are mid-complexity (3–5 callees, need stubbing).  ~25m each
  → ~17h.
* ~28 procs are deep — they call into the gfx driver, music driver, or
  the SAR loader.  Two options: (a) full stub all of CS:[2000h..204Eh]
  via `stub_video_drivers()` and accept that the test only proves
  control flow, not pixel output; (b) defer to phase 5 integration.
  Plan: do (a) for ~15 of them, defer the gnarliest 13.  ~10h for the 15.

**Phase-3 deliverable**: ~75 new tests in `proc_equivalence/`; 75
verdicts logged.  ~13 game_func_N procs explicitly deferred with a row
in PLAN.md §6 ("not worth testing this regime") or §7 ("integration
candidate").

**Cost estimate: ~32 hrs.**

---

## 5. Phase 4 — Regression coverage of the 33 already-renamed procs/bytes

Cheap, template-driven, high-leverage protection against future static
refactors silently breaking semantics.  AUDIT_TODO §"Already done"
lists the addresses; for each one with a known function (writer or
reader), generate a regression test that:

1. Sets the relevant DS bytes to a known input.
2. Calls the function.
3. Asserts the exact post-state matches a stored golden output.

The golden output is captured by running the function once today, with
a comment explaining what the input represents.  Future divergence
fails the test.  These ARE allowed to be silent passes (no printed
verdict logic) because the test name itself is the verdict — but they
must print the diff on FAIL.

Proposed batches:

| Batch | Targets | Effort |
|---|---|---|
| 4a — gold/almas/HP arithmetic | 4 functions touching 0x85/0x86/0x90/0x8B | 1.5h |
| 4b — flag setters/clearers (death, completion, frame) | ~10 functions | 3h |
| 4c — direction movers (already fingerprinted) | 8 functions | 2h |
| 4d — entity-list iteration helpers | ~6 functions | 2h |
| 4e — input-FSM (combat_action_state etc.) | ~5 functions | 2h |

**Phase-4 deliverable**: ~33 tests in `regression/`, runnable in CI via
`run.py --ci`, all green.  Status row in STATUS.md.

**Cost estimate: ~10 hrs.**

---

## 6. Explicit skip list

Categories not worth a runtime test in this regime.  Listed here so
we don't relitigate.

* **Sourcer-generated `sub_NN` / `loc_NN`** — mechanical decoration; gets
  cleaned by a separate `/asm-cleanup` pass.
* **DOS/BIOS interrupt thunks** — anything `int 21h`, `int 10h`, `int 16h`
  shaped is OS surface, not game semantics.  The harness can't fake DOS.
* **Hardware port I/O** — joystick polls, PIC programming, PIT setup.
  Belongs in DOSBox integration tests, not Unicorn.
* **Music tracker tick handlers** — too many far calls, too much state.
* **Pure data-init thunks** (`size_bytes <= 8`, no mem writes) — the
  classifier's category E.
* **Driver-internal blit/decode helpers** — these are interesting to RE
  but their semantics are "bytes at A become pixels at B" and that
  doesn't fit byte-delta probing.  Categorize with `chunk in {gfcga,
  gfega, gfhgc, gftga, gfmcga, gmcga, ...}` and add an integration
  pixel-diff test in a separate, future regime.

---

## 7. Integration candidates (deferred, not part of this plan)

Functions that need the actual game running to verify.  Tracked here so
they're not lost; not addressed by this plan.

* SAR loader (`sar_loader_fn` at 0x10C) — touches DOS file I/O.
* Per-frame main-loop dispatcher (200FIGHT entry).
* Music chunk loader.
* The 13 deferred game_func_* from §4.3.

These are handled by the `mcp__dosbox__*` tools, not Unicorn — separate
workflow, separate plan.

---

## 8. Phase summary + cumulative cost

| Phase | DOD | Hours |
|---|---|---|
| 1 — Tooling pre-work | coverage.csv exists; run.py works; harness has fingerprint+snapshot; fixtures.py shipped | 6–8 |
| 2 — Byte placeholder probes | 5 tests in placeholder_id/; AUDIT_TODO closed for those addrs | 4 |
| 3 — game_func_N identity sweep | ~75 tests in proc_equivalence/; ~13 deferred to §7 | 32 |
| 4 — Regression net | ~33 tests in regression/; CI green | 10 |
| **Total to "fully covered"** | | **~52–54 hrs** |

This is solo-developer hours, not calendar time.  At a sustainable
4–6 hrs/week it's a 9–13 week effort.  Phase 1 alone unblocks parallel
contribution if anyone else picks the project up — given the CSV they
can pick a row and write a test without re-deriving the fixtures.

---

## 9. What "done" looks like

* `functest/coverage.csv` shows every proc has a category.
* `functest/STATUS.md` shows every proc in category A or B has a
  test, every test has a verdict.
* `working/AUDIT_TODO.md` "Functional-probe required" section is empty
  or every row says "kept (insufficient runtime evidence)".
* `python run.py --ci` exits 0 in CI; introducing a behavior change to
  any covered proc fails at least one regression test.
* No proc renamed without either (a) an existing static-evidence trail
  or (b) a runtime probe in `proc_equivalence/`.

That's the bar.  Below that bar, runtime tests are decoration; above
it, they're the safety net the static audit pass has been missing.
